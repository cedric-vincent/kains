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

use v6;
use Test;

plan 7;

{
	use App::Kains;
	throws-like { App::Kains::start('/this/does/not/exist') }, X::Kains, 'not such file';
	throws-like { App::Kains::start(< -B /etc /etc/fstab >) }, X::Kains, 'incompatible file type';
}

{
	use App::Kains::Commandline;

	throws-like { Interface.new.parse(['-a']) }, X::Command-line, 'unknown switch';

	throws-like { Interface.new(parameters =>
			( Param.new(callback => sub ($a) { !!! } ))).parse(['-a']) },
			X::Command-line, 'missing parameter';
}

{
	use App::Kains::Config;

	dies-ok { Config.new.set-rootfs('/this/does/not/exist') }, 'invalid rootfs';
	dies-ok { Config.new.add-binding('/this/does/not/exist', 'whatever') }, 'invalid mount source';
}

{
	use App::Kains::Native;
	throws-like { chroot('/this/does/not/exist') }, X::Errno, 'native error';
}
