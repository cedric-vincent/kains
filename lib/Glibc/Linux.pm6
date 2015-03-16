module Glibc::Linux;

use NativeCall;
use Glibc::Errno;

sub unshare(int $flags) is export(:unshare) {
	sub unshare(int --> int) is native { * }
	raise-errno-on(* < 0, &unshare, $flags);
}

sub mount(Str $source, Str $target, Str $type, int $flags, Str $data) is export(:mount) {
	sub mount(Str, Str, Str, int, Str --> int) is native { * }
	raise-errno-on(* < 0, &mount, $source, $target, $type, $flags, $data);
}

sub chroot(Str $path) is export(:chroot) {
	sub chroot(Str --> int) is native { * }
	raise-errno-on(* < 0, &chroot, $path);
}

constant CLONE_VM	is export(:clone, :unshare)	::= 0x00000100;
constant CLONE_FS	is export(:clone, :unshare)	::= 0x00000200;
constant CLONE_FILES	is export(:clone, :unshare)	::= 0x00000400;
constant CLONE_SIGHAND	is export(:clone, :unshare)	::= 0x00000800;
constant CLONE_PTRACE	is export(:clone, :unshare)	::= 0x00002000;
constant CLONE_VFORK	is export(:clone, :unshare)	::= 0x00004000;
constant CLONE_PARENT	is export(:clone, :unshare)	::= 0x00008000;
constant CLONE_THREAD	is export(:clone, :unshare)	::= 0x00010000;
constant CLONE_NEWNS	is export(:clone, :unshare)	::= 0x00020000;
constant CLONE_SYSVSEM	is export(:clone, :unshare)	::= 0x00040000;
constant CLONE_SETTLS	is export(:clone, :unshare)	::= 0x00080000;
constant CLONE_DETACHED	is export(:clone, :unshare)	::= 0x00400000;
constant CLONE_UNTRACED	is export(:clone, :unshare)	::= 0x00800000;
constant CLONE_NEWUTS	is export(:clone, :unshare)	::= 0x04000000;
constant CLONE_NEWIPC	is export(:clone, :unshare)	::= 0x08000000;
constant CLONE_NEWUSER	is export(:clone, :unshare)	::= 0x10000000;
constant CLONE_NEWPID	is export(:clone, :unshare)	::= 0x20000000;
constant CLONE_NEWNET	is export(:clone, :unshare)	::= 0x40000000;
constant CLONE_IO	is export(:clone, :unshare)	::= 0x80000000;
constant CLONE_PARENT_SETTID	is export(:clone, :unshare)	::=  0x00100000;
constant CLONE_CHILD_CLEARTID	is export(:clone, :unshare)	::=  0x00200000;
constant CLONE_CHILD_SETTID	is export(:clone, :unshare)	::=  0x01000000;

constant MS_RDONLY	is export(:mount)	::= 0x00000001;
constant MS_NOSUID	is export(:mount)	::= 0x00000002;
constant MS_NODEV	is export(:mount)	::= 0x00000004;
constant MS_NOEXEC	is export(:mount)	::= 0x00000008;
constant MS_SYNCHRONOUS	is export(:mount)	::= 0x00000010;
constant MS_REMOUNT	is export(:mount)	::= 0x00000020;
constant MS_MANDLOCK	is export(:mount)	::= 0x00000040;
constant MS_DIRSYNC	is export(:mount)	::= 0x00000080;
constant MS_NOATIME	is export(:mount)	::= 0x00000400;
constant MS_NODIRATIME	is export(:mount)	::= 0x00000800;
constant MS_BIND	is export(:mount)	::= 0x00001000;
constant MS_MOVE	is export(:mount)	::= 0x00002000;
constant MS_REC		is export(:mount)	::= 0x00004000;
constant MS_VERBOSE	is export(:mount)	::= 0x00008000;
constant MS_SILENT	is export(:mount)	::= 0x00008000;
constant MS_POSIXACL	is export(:mount)	::= 0x00010000;
constant MS_UNBINDABLE	is export(:mount)	::= 0x00020000;
constant MS_PRIVATE	is export(:mount)	::= 0x00040000;
constant MS_SLAVE	is export(:mount)	::= 0x00080000;
constant MS_SHARED	is export(:mount)	::= 0x00100000;
constant MS_RELATIME	is export(:mount)	::= 0x00200000;
constant MS_KERNMOUNT	is export(:mount)	::= 0x00400000;
constant MS_I_VERSION	is export(:mount)	::= 0x00800000;
constant MS_STRICTATIME	is export(:mount)	::= 0x01000000;
constant MS_NOSEC	is export(:mount)	::= 0x10000000;
constant MS_BORN	is export(:mount)	::= 0x20000000;
constant MS_ACTIVE	is export(:mount)	::= 0x40000000;
constant MS_NOUSER	is export(:mount)	::= 0x80000000;
