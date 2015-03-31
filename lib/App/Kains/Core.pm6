module App::Kains::Core;

use App::Kains::Native;
use App::Kains::Config;

sub set-uid-mapping(int :$old-uid, int :$new-uid) {
	spurt('/proc/self/uid_map', "$new-uid $old-uid 1");

	CATCH {	default { note "Warning: can't map user identity: { .message }" } }
}

sub set-gid-mapping(int :$old-gid, int :$new-gid) {
	# This is not required on all Linux versions.
	try spurt('/proc/self/setgroups', 'deny');

	spurt('/proc/self/gid_map', "$new-gid $old-gid 1");

	CATCH {	default { note "Warning: can't map group identity: { .message }" } }
}

sub mount-host-rootfs(Config $config --> Str) {
	return '/' but False if $config.rootfs === '/';

	my Str $host-rootfs = '/.kains-' ~ getpid;

	mkdir($config.rootfs ~ $host-rootfs);
	mount('/', $config.rootfs ~ $host-rootfs, '', MS_PRIVATE +| MS_BIND +| MS_REC, '');

	return $host-rootfs;
}

class X::Kains is Exception is export {
	has Str $.message;
	has Bool $.works-with-proot = False;

	method message {
		my $message = "$!message";
		if $!works-with-proot {
			$message ~= "Although, this should work with PRoot (http://proot.me)."
		}
		return $message;
	}
};

sub mount-bindings(Str $host-rootfs, Config $config) {
	for $config.bindings {
		my IO::Path $source	 .= new($host-rootfs ~ .key);
		my IO::Path $destination .= new(.value);

		if ! $destination.IO.e {
			given $source {
				when .f { open(~$destination, :a).close }
				when .d { mkdir(~$destination) }
				default { !!! }
			}

			CATCH {
				die X::Kains.new(:works-with-proot, message => .message);
			}
		}
		else {
			if $destination.f && ! $source.f
			|| $destination.d && ! $source.d {
				die X::Kains.new(:works-with-proot, message => qq:to/END/
					Can't bind "$destination", its type in the guest rootfs doesn't match
					its type in the host rootfs.
					END
				);
			}
		}

		mount($source, $destination, '', MS_PRIVATE +| MS_BIND +| MS_REC, '');
	}
}

our sub launch(Config $config --> Proc::Status) is export {
	my ($new-uid, $old-uid) = getuid() xx 2;
	my ($new-gid, $old-gid) = getgid() xx 2;

	if $config.root-id {
		$new-uid = 0;
		$new-gid = 0;
	}

	unshare(CLONE_NEWUSER +| CLONE_NEWNS);

	set-uid-mapping(:$old-uid, :$new-uid);
	set-gid-mapping(:$old-gid, :$new-gid);

	my $host-rootfs = mount-host-rootfs($config);

	chroot($config.rootfs);

	mount-bindings($host-rootfs, $config);

	if $host-rootfs {
		try umount2($host-rootfs, MNT_DETACH);
		try rmdir($host-rootfs);
	}

	try chdir($config.cwd);
	if $! ~~ X::IO::Chdir {
		note $!.message ~ ' (in the new rootfs).';
		note 'Changing the current working directory to "/".';
		chdir('/');
	}

	personality(PER_LINUX32) if $config.mode32;

	given run(|$config.command) {
		when -1 { die X::Kains.new(message => "{ $config.command[0] } can't be found or can't be executed.") }
		default { return $_ }
	}

	CATCH {
		when X::Errno {
			my Str $message = "Error: { .message }\n";

			if .errno == EPERM
			or .errno == EINVAL and .function.name eq 'unshare' {
				$message ~= "It seems your system doesn't support user namespaces."
			}

			die X::Kains.new(:$message, :works-with-proot);
		}
	}
}
