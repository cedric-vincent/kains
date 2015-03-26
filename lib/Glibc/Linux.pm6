module Glibc::Linux;

use NativeCall;
use Glibc::Errno;

sub unshare(int $flags) is export(:unshare) {
	sub unshare(int --> int) is native { * }
	raise-errno-on(* < 0, &unshare, $flags);
}

sub mount(Str() $source, Str() $target, Str $type, int $flags, Str $data) is export(:mount) {
	sub mount(Str, Str, Str, int, Str --> int) is native { * }
	raise-errno-on(* < 0, &mount, $source, $target, $type, $flags, $data);
}

sub umount(Str() $path) is export(:mount) {
	sub umount(Str --> int) is native { * }
	raise-errno-on(* < 0, &umount, $path);
}

sub umount2(Str() $path, int $flags) is export(:mount) {
	sub umount2(Str, int --> int) is native { * }
	raise-errno-on(* < 0, &umount2, $path, $flags);
}

sub chroot(Str() $path) is export(:chroot) {
	sub chroot(Str --> int) is native { * }
	raise-errno-on(* < 0, &chroot, $path);
}

sub personality(int $flags --> int) is export(:chroot) {
	sub personality(int --> int) is native { * }
	raise-errno-on(* < 0, &personality, $$flags);
}

constant CLONE_VM	is export(:clone, :unshare)	= 0x00000100;
constant CLONE_FS	is export(:clone, :unshare)	= 0x00000200;
constant CLONE_FILES	is export(:clone, :unshare)	= 0x00000400;
constant CLONE_SIGHAND	is export(:clone, :unshare)	= 0x00000800;
constant CLONE_PTRACE	is export(:clone, :unshare)	= 0x00002000;
constant CLONE_VFORK	is export(:clone, :unshare)	= 0x00004000;
constant CLONE_PARENT	is export(:clone, :unshare)	= 0x00008000;
constant CLONE_THREAD	is export(:clone, :unshare)	= 0x00010000;
constant CLONE_NEWNS	is export(:clone, :unshare)	= 0x00020000;
constant CLONE_SYSVSEM	is export(:clone, :unshare)	= 0x00040000;
constant CLONE_SETTLS	is export(:clone, :unshare)	= 0x00080000;
constant CLONE_DETACHED	is export(:clone, :unshare)	= 0x00400000;
constant CLONE_UNTRACED	is export(:clone, :unshare)	= 0x00800000;
constant CLONE_NEWUTS	is export(:clone, :unshare)	= 0x04000000;
constant CLONE_NEWIPC	is export(:clone, :unshare)	= 0x08000000;
constant CLONE_NEWUSER	is export(:clone, :unshare)	= 0x10000000;
constant CLONE_NEWPID	is export(:clone, :unshare)	= 0x20000000;
constant CLONE_NEWNET	is export(:clone, :unshare)	= 0x40000000;
constant CLONE_IO	is export(:clone, :unshare)	= 0x80000000;
constant CLONE_PARENT_SETTID	is export(:clone, :unshare)	=  0x00100000;
constant CLONE_CHILD_CLEARTID	is export(:clone, :unshare)	=  0x00200000;
constant CLONE_CHILD_SETTID	is export(:clone, :unshare)	=  0x01000000;

constant MS_RDONLY	is export(:mount)	= 0x00000001;
constant MS_NOSUID	is export(:mount)	= 0x00000002;
constant MS_NODEV	is export(:mount)	= 0x00000004;
constant MS_NOEXEC	is export(:mount)	= 0x00000008;
constant MS_SYNCHRONOUS	is export(:mount)	= 0x00000010;
constant MS_REMOUNT	is export(:mount)	= 0x00000020;
constant MS_MANDLOCK	is export(:mount)	= 0x00000040;
constant MS_DIRSYNC	is export(:mount)	= 0x00000080;
constant MS_NOATIME	is export(:mount)	= 0x00000400;
constant MS_NODIRATIME	is export(:mount)	= 0x00000800;
constant MS_BIND	is export(:mount)	= 0x00001000;
constant MS_MOVE	is export(:mount)	= 0x00002000;
constant MS_REC		is export(:mount)	= 0x00004000;
constant MS_VERBOSE	is export(:mount)	= 0x00008000;
constant MS_SILENT	is export(:mount)	= 0x00008000;
constant MS_POSIXACL	is export(:mount)	= 0x00010000;
constant MS_UNBINDABLE	is export(:mount)	= 0x00020000;
constant MS_PRIVATE	is export(:mount)	= 0x00040000;
constant MS_SLAVE	is export(:mount)	= 0x00080000;
constant MS_SHARED	is export(:mount)	= 0x00100000;
constant MS_RELATIME	is export(:mount)	= 0x00200000;
constant MS_KERNMOUNT	is export(:mount)	= 0x00400000;
constant MS_I_VERSION	is export(:mount)	= 0x00800000;
constant MS_STRICTATIME	is export(:mount)	= 0x01000000;
constant MS_NOSEC	is export(:mount)	= 0x10000000;
constant MS_BORN	is export(:mount)	= 0x20000000;
constant MS_ACTIVE	is export(:mount)	= 0x40000000;
constant MS_NOUSER	is export(:mount)	= 0x80000000;

constant MNT_FORCE	is export(:mount)	= 1;
constant MNT_DETACH	is export(:mount)	= 2;
constant MNT_EXPIRE	is export(:mount)	= 4;
constant UMOUNT_NOFOLLOW is export(:mount)	= 8;

constant UNAME26		is export(:personality)	= 0x0020000;
constant ADDR_NO_RANDOMIZE 	is export(:personality)	= 0x0040000;
constant FDPIC_FUNCPTRS		is export(:personality) = 0x0080000;
constant MMAP_PAGE_ZERO		is export(:personality) = 0x0100000;
constant ADDR_COMPAT_LAYOUT	is export(:personality) = 0x0200000;
constant READ_IMPLIES_EXEC	is export(:personality) = 0x0400000;
constant ADDR_LIMIT_32BIT	is export(:personality) = 0x0800000;
constant SHORT_INODE		is export(:personality) = 0x1000000;
constant WHOLE_SECONDS		is export(:personality) = 0x2000000;
constant STICKY_TIMEOUTS	is export(:personality)	= 0x4000000;
constant ADDR_LIMIT_3GB		is export(:personality) = 0x8000000;

constant PER_LINUX		is export(:personality) = 0x0000;
constant PER_LINUX_32BIT	is export(:personality) = 0x0000 +| ADDR_LIMIT_32BIT;
constant PER_LINUX_FDPIC	is export(:personality) = 0x0000 +| FDPIC_FUNCPTRS;
constant PER_SVR4		is export(:personality) = 0x0001 +| STICKY_TIMEOUTS +| MMAP_PAGE_ZERO;
constant PER_SVR3		is export(:personality) = 0x0002 +| STICKY_TIMEOUTS +| SHORT_INODE;
constant PER_SCOSVR3		is export(:personality) = 0x0003 +| STICKY_TIMEOUTS +| WHOLE_SECONDS +| SHORT_INODE;
constant PER_OSR5		is export(:personality) = 0x0003 +| STICKY_TIMEOUTS +| WHOLE_SECONDS;
constant PER_WYSEV386		is export(:personality) = 0x0004 +| STICKY_TIMEOUTS +| SHORT_INODE;
constant PER_ISCR4		is export(:personality) = 0x0005 +| STICKY_TIMEOUTS;
constant PER_BSD		is export(:personality) = 0x0006;
constant PER_SUNOS		is export(:personality) = 0x0006 +| STICKY_TIMEOUTS;
constant PER_XENIX		is export(:personality) = 0x0007 +| STICKY_TIMEOUTS +| SHORT_INODE;
constant PER_LINUX32		is export(:personality) = 0x0008;
constant PER_LINUX32_3GB	is export(:personality) = 0x0008 +| ADDR_LIMIT_3GB;
constant PER_IRIX32		is export(:personality) = 0x0009 +| STICKY_TIMEOUTS;
constant PER_IRIXN32		is export(:personality) = 0x000a +| STICKY_TIMEOUTS;
constant PER_IRIX64		is export(:personality) = 0x000b +| STICKY_TIMEOUTS;
constant PER_RISCOS		is export(:personality) = 0x000c;
constant PER_SOLARIS		is export(:personality) = 0x000d +| STICKY_TIMEOUTS;
constant PER_UW7		is export(:personality) = 0x000e +| STICKY_TIMEOUTS +| MMAP_PAGE_ZERO;
constant PER_OSF4		is export(:personality) = 0x000f;
constant PER_HPUX		is export(:personality) = 0x0010;
constant PER_MASK		is export(:personality) = 0x00ff;

constant PER_CLEAR_ON_SETID	is export(:personality) = READ_IMPLIES_EXEC +| ADDR_NO_RANDOMIZE +| ADDR_COMPAT_LAYOUT +| MMAP_PAGE_ZERO;
