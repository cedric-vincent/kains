module Glibc::Errno;

use NativeCall;

constant EPERM		is export	= 1;
constant ENOENT		is export	= 2;
constant ESRCH		is export	= 3;
constant EINTR		is export	= 4;
constant EIO		is export	= 5;
constant ENXIO		is export	= 6;
constant E2BIG		is export	= 7;
constant ENOEXEC	is export	= 8;
constant EBADF		is export	= 9;
constant ECHILD		is export	= 10;
constant EAGAIN		is export	= 11;
constant ENOMEM		is export	= 12;
constant EACCES		is export	= 13;
constant EFAULT		is export	= 14;
constant ENOTBLK	is export	= 15;
constant EBUSY		is export	= 16;
constant EEXIST		is export	= 17;
constant EXDEV		is export	= 18;
constant ENODEV		is export	= 19;
constant ENOTDIR	is export	= 20;
constant EISDIR		is export	= 21;
constant EINVAL		is export	= 22;
constant ENFILE		is export	= 23;
constant EMFILE		is export	= 24;
constant ENOTTY		is export	= 25;
constant ETXTBSY	is export	= 26;
constant EFBIG		is export	= 27;
constant ENOSPC		is export	= 28;
constant ESPIPE		is export	= 29;
constant EROFS		is export	= 30;
constant EMLINK		is export	= 31;
constant EPIPE		is export	= 32;
constant EDOM		is export	= 33;
constant ERANGE		is export	= 34;

class X::Errno is Exception is export {
	has $.function;
	has @.arguments;
	has $.errno;

	method message {
		sub strerror(int $errno --> Str) is native { * }

		my @arguments = @!arguments.map: {
			when Str { qq/"$_"/		}
			when Int { '0x' ~ $_.base(16)	}
			default	 { $_			}
		}

		$!function.name ~ '(' ~ @arguments.join(', ') ~ '): ' ~ strerror($!errno);
	}
}

our $errno is export = cglobal('libc.so.6', 'errno', int);

sub raise-errno-on(Callable $condition, $function, *@arguments) is export {
	my $result = $function(|@arguments);

	if $condition($result) {
		die X::Errno.new(:$function, :@arguments, :$errno);
	}

	return $result;
}
