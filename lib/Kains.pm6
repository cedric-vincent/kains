module Kains;

use Kains::Config;
use Kains::Command-line;

use Glibc::Linux :unshare, :mount, :chroot;
use Glibc :getuid, :getgid;

sub set-uid-mapping(int :$old-uid, int :$new-uid) {
	spurt('/proc/self/uid_map', "$new-uid $old-uid 1");

	CATCH {	default { say "WARNING: can't map user identity: { .message }" } }
}

sub set-gid-mapping(int :$old-gid, int :$new-gid) {
	# This is not required on all Linux versions.
	try spurt('/proc/self/setgroups', 'deny');

	spurt('/proc/self/gid_map', "$new-gid $old-gid 1");

	CATCH {	default { say "WARNING: can't map group identity: { .message }" } }
}

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
			say 'FATAL: ', .message;

			if .errno == EPERM
			or .errno == EINVAL and .function.name eq 'unshare' {
				say "INFO: it seems your system doesn't support user namespaces; "
				  ~ "you might want to try PRoot instead: http://proot.me";
			}
		}
	}
}

our sub start(--> Int) {
	my $config = Kains::Command-line::parse(@*ARGS);

	return launch-command-in-new-namespace($config).exit;

	CATCH {
		when X::Command-line {
			$*ERR.say: .message;
			$*ERR.say: 'Please have a look at the --help option';
		}
	}
}
