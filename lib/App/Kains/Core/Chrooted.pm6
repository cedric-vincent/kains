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

unit module App::Kains::Core::Chrooted;

use App::Kains::Config;
use App::Kains::Native;
use App::Kains::X;

multi sub create-placeholder(IO::Path $source, IO::Path $destination
	where {    $destination.f and $source.f
		or $destination.d and $source.d }) {
}

multi sub create-placeholder(IO::Path $source, IO::Path $destination
	where {    $destination.f and ! $source.f
		or $destination.d and ! $source.d }) {
	die X::Kains.new: :works-with-proot, message => q:to<END>;
		Error: can't mount/bind "$destination", its type in the virtual rootfs
		doesn't match its type in the actual rootfs.
		END
}

multi sub create-placeholder(IO::Path $source, IO::Path $destination)
{
	CATCH {
		when X::IO::Mkdir
		  or X::AdHoc
		  or X::NYI {
			die X::Kains.new: :works-with-proot, message =>
				"Error when creating placeholder '$source -> $destination': { .message }"
		}
	}

	multi sub paths(IO() $path where * cmp '/' === Same) { $path }
	multi sub paths(IO() $path) { |paths($path.parent), $path }

	.mkdir if ! .e for paths $destination.parent;

	given $source {
		when .f { close open ~$destination, :a }
		when .d { mkdir ~$destination }
		default { die X::NYI.new: feature => 'mounting/binding special file' }
	}
}

our sub mount-bindings(Str $actual-rootfs, Config $config) is export {
	my @sorted-bindings = sort *.value.chars,
				$config.bindings.map: {
					Pair.new: key   => IO::Path.new($actual-rootfs ~ .key),
						  value => IO::Path.new(.value.IO.resolve) };
	for @sorted-bindings {
		FIRST {
			say qq<Info: using "$actual-rootfs" as temporary mount point, bindings are:>
				if $config.verbose;
		}

		my $source	= .key;
		my $destination = .value;

		say "	$source -> $destination" if $config.verbose;

		create-placeholder $source, $destination;

		mount $source, $destination, '', MS_PRIVATE +| MS_BIND +| MS_REC, '';
	}
}

