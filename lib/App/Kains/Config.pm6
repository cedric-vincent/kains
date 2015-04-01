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

module App::Kains::Config;

class Config is export {
	has Str $.rootfs	= '/';
	has Enum @.bindings	= ();
	has Str $.cwd is rw	= ~$*CWD;
	has Bool $.root-id is rw = False;
	has Bool $.mode32 is rw  = False;
	has Str @.command	= < /bin/sh -l >;

	method set-rootfs(Str $path) {
		given $path.IO {
			die qq/"$_" doesn't exist/ if ! .e;
			die qq/"$_" isn't a directory/ if ! .d;
			die qq/"$_" isn't accessible ('x' permission denied)/ if ! .x;
			die qq/"$_" isn't accessible ('r' permission denied)/ if ! .r;
		}

		$!rootfs = $path;
	}

	method add-binding(Str $source, Str $destination = $source) {
		die qq/"$source" doesn't exist/ if ! $source.IO.e;

		# $destination path can't be checked now because
		# symlinks have to be resolved respectively to the
		# virtual rootfs.

		# $source path have to be resolved before changing the
		# root directory.

		@.bindings.push: $source.IO.resolve => $destination;
	}

	method add-bindings(*@paths) {
		for @paths {
			$.add-binding($_);
		}
	}
}
