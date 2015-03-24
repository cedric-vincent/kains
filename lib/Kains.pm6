module Kains;

use Kains::Config;
use Kains::Command-line;

use Glibc::Linux :unshare, :mount, :chroot;
use Glibc :getuid, :getgid;

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

class X::Kains is Exception { has $.message };

sub launch-command-in-new-namespace(Kains::Config $config --> Proc::Status) {
	my $old-uid = getuid;
	my $old-gid = getgid;

	unshare(CLONE_NEWUSER +| CLONE_NEWNS);

	set-uid-mapping(:$old-uid, :new-uid($config.root-id ?? 0 !! $old-uid));
	set-gid-mapping(:$old-gid, :new-gid($config.root-id ?? 0 !! $old-gid));

	for $config.bindings {
		mount(.key, $config.rootfs ~ "/" ~ .value, '', MS_PRIVATE +| MS_BIND +| MS_REC, '');
	}

	chroot($config.rootfs);

	chdir('/');

	return run(|$config.command);

	CATCH {
		use Glibc::Errno;

		when X::Errno {
			my Str $message = "Error: { .message }\n";

			if .errno == EPERM
			or .errno == EINVAL and .function.name eq 'unshare' {
				$message ~= q:to/END/;
					It seems your system doesn't support user namespaces.
					You might want to try PRoot instead: http://proot.me.
					END
			}

			die X::Kains.new(:$message);
		}
	}
}

our sub start(--> Int) {
	my $config = Kains::Command-line::parse(@*ARGS);

	return launch-command-in-new-namespace($config).exit;

	CATCH {
		when X::Command-line {
			die X::Kains.new(message => qq:to/END/
				{ .message }
				Please have a look at the --help option
				END
			);
		}
	}
}
