use v6;
use Test;

plan 27;

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

for < --32 --32bit --32bit-mode > {
	is App::Kains::start(« $_ sh -c 'uname -m | grep -qx i686' »), 0, "use $_ option"
}

is App::Kains::start(< -R / true >), 0, "use -R option";

is App::Kains::start(« -S / sh -c 'id -g | grep -qx 0' »), 0, "use -S option";
