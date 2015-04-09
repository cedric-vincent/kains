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

plan 2;

use App::Kains;

sub tmp-name {
	use App::Kains::Native;
	'kains-' ~ getpid() ~ ['a'...'z'].pick(9).join;
}

my $tmp-does-exist         = tmp-name;
my $tmp-does-not-exist     = tmp-name;
my $tmp-does-not-exist-too = tmp-name;

chdir $*SPEC.tmpdir;

die if $tmp-does-exist === $tmp-does-not-exist
    or $tmp-does-not-exist.IO.e
    or $tmp-does-not-exist-too.IO.e;

mkdir $tmp-does-exist;

is App::Kains::start(« -B $tmp-does-exist $tmp-does-not-exist true »), 0,
   'bind to non-existent local destination';

is App::Kains::start(« -B $tmp-does-exist "/tmp/$tmp-does-not-exist-too/whatever" true »), 0,
   'bind into non-existent parent directory';

rmdir $tmp-does-exist;
