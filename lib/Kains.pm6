module Kains;

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

our sub start {
	my $rootfs	::= '/usr/local/cedric/rootfs/stage3-amd64-hardened+nomultilib-20141120';
	my @bindings	::= < /dev /sys /proc /tmp /etc/passwd >, %*ENV<HOME>;

	my $old-uid = getuid;
	my $old-gid = getgid;

	unshare(CLONE_NEWUSER +| CLONE_NEWNS);

	set-uid-mapping(:$old-uid, :new-uid(0));
	set-gid-mapping(:$old-gid, :new-gid(0));

	for @bindings {
		mount($_, "$rootfs/$_", '', MS_PRIVATE +| MS_BIND +| MS_REC, '');
	}

	chroot($rootfs);

	chdir('/');

	run('/bin/bash');

	CATCH {
		use Glibc::Errno;

		when X::Errno {
			say 'FATAL: ', .message;

			if .errno == EPERM {
				say "INFO: it seems your system doesn't support user namespaces; "
				  ~ "you might want to try PRoot instead: http://proot.me";
			}
		}
	}
}
