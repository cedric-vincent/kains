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

plan 30;

use App::Kains;

is App::Kains::start('true'), 0, 'execute "true"';

is App::Kains::start('false'), 1, 'execute "false"';

is App::Kains::start(« sh -c 'exit 123' »), 123, 'execute a shell';

is App::Kains::start(« -- sh -c 'exit 123' »), 123, 'use -- option';

for < -B -M --bind-elsewhere --mount-elsewhere > {
	is App::Kains::start(« $_ /usr/bin/true /usr/bin/false /usr/bin/false »), 0, "use $_ option"
}

for < -r --rootfs > {
	is App::Kains::start(« $_ / true »), 0, "use $_ option"
}

for < -b -m --bind --mount > {
	is App::Kains::start(« $_ /dev true »), 0, "use $_ option"
}

for < -w --pwd --cwd --working-directory > {
	is App::Kains::start(« $_ /dev sh -c 'pwd | grep -qx /dev' »), 0, "use $_ option"
}

for < -0 --root-id > {
	is App::Kains::start(« $_ sh -c 'id -u | grep -qx 0' »), 0, "use $_ option";
	is App::Kains::start(« $_ sh -c 'id -g | grep -qx 0' »), 0, "use $_ option";
}

for < -v --verbose > {
	is App::Kains::start(« $_ true' »), 0, "use $_ option";
	is App::Kains::start(« $_ true' »), 0, "use $_ option";
}

for < --32 --32bit --32bit-mode > {
	is App::Kains::start(« $_ sh -c 'uname -m | grep -qx i686' »), 0, "use $_ option"
}

is App::Kains::start(< -R / true >), 0, "use -R option";

is App::Kains::start(« -S / sh -c 'id -g | grep -qx 0' »), 0, "use -S option";

my $nonexistent-path = '/tmp/kains-' ~ (('a'..'z', 'A'..'Z', 0..9).pick xx 30).join;
is App::Kains::start(« -B /dev $nonexistent-path test -d $nonexistent-path »), 0,
	'mount/bind to nonexistent location';
