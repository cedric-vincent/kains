# This file is part of Kains.
#
# Copyright (C) 2015 STMicroelectronics
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 USA.

unit module App::Kains::Native;

use NativeCall;

class X::Errno is Exception is export {
	has $.function;
	has @.arguments;
	has $.errno;

	method message {
		sub strerror(int $errno --> Str) is native { * }

		my @arguments = @!arguments.map: {
			when Str { qq<"$_">		}
			when Int { '0x' ~ .base(16)	}
			default	 { $_			}
		}

		$!function.name ~ '(' ~ @arguments.join(', ') ~ '): ' ~ strerror $!errno;
	}
}

sub raise-errno-on(Code $condition, Code $function, *@arguments --> Any) {
	my $result = $function(|@arguments);
	if $condition($result) {
		my $errno = cglobal('libc.so.6', 'errno', int);
		die X::Errno.new: :$function, :@arguments, :$errno;
	}
	$result;
}

sub unshare(int $flags) is export {
	sub unshare(int --> int) is native { * }
	raise-errno-on * < 0, &unshare, $flags;
}

sub mount(Str() $source, Str() $target, Str $type, int $flags, Str $data) is export {
	sub mount(Str, Str, Str, int, Str --> int) is native { * }
	raise-errno-on * < 0, &mount, $source, $target, $type, $flags, $data;
}

sub umount2(Str() $path, int $flags) is export {
	sub umount2(Str, int --> int) is native { * }
	raise-errno-on * < 0, &umount2, $path, $flags;
}

sub chroot(Str() $path) is export {
	sub chroot(Str --> int) is native { * }
	raise-errno-on * < 0, &chroot, $path;
}

sub personality(int $flags --> int) is export {
	sub personality(int --> int) is native { * }
	raise-errno-on * < 0, &personality, $flags;
}

sub getuid(--> int) is native is export { * }
sub getgid(--> int) is native is export { * }
sub getpid(--> int) is native is export { * }

constant CLONE_NEWNS	is export = 0x00020000;
constant CLONE_NEWUSER	is export = 0x10000000;
constant MS_BIND	is export = 0x00001000;
constant MS_REC		is export = 0x00004000;
constant MS_PRIVATE	is export = 0x00040000;
constant MNT_DETACH	is export = 2;
constant PER_LINUX32	is export = 0x0008;
constant EPERM		is export = 1;
constant EINVAL		is export = 22;

