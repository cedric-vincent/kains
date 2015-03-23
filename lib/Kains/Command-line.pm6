module Kains::Command-line;

use Kains::Config;
use Command-line;

our sub parse(@arguments --> Kains::Config) {
	my Kains::Config $config .= new;

	my Command-line::Interface $cli .= new(options => (
		Command-line::Option.new(
			switches	=> < -r --rootfs >,
			callback	=> sub { $config.set-rootfs($^a) },
			examples	=> ( %*ENV<HOME> ~ '/rootfs/centos-6-x86',
					     '/tmp/ubuntu-12.04-x86_64',
					     $config.rootfs ~ '  (default)' ),
		),
		Command-line::Option.new(
			switches	=> < -b --bind -m --mount >,
			callback	=> sub { $config.add-binding($^a, $^a) },
			examples	=> ( '/proc', '/dev', %*ENV<HOME> ),
		),
		Command-line::Option.new(
			switches	=> < -a --asymmetric-bind --asymmetric-mount >,
			callback	=> sub { $config.add-binding($^a, $^b) },
			examples	=> ( %*ENV<HOME> ~ '/my_hosts /etc/hosts',
					     '/tmp/opt /opt',
					     '/bin/bash /bin/sh' ),
		),
		Command-line::Option.new(
			switches	=> < -w --pwd --cwd >,
			callback	=> sub { $config.set-cwd($^a) },
			examples	=> ( '/tmp',
					     $config.cwd ~ '  (first default)',
					     '/  (second default)' )
		),
		Command-line::Option.new(
			switches	=> < -0 --root-id >,
			callback	=> sub { $config.root-id = True },
		),
		Command-line::Option.new(
			switches	=> < -h --help --usage >,
			callback	=> sub { $cli.print-help }, # last
		),
		Command-line::Option.new(
			switches	=> < -- >,
			callback	=> sub (*@command) { $config.command = @command },
			examples	=> ( 'emacs',
					     '/usr/bin/wget',
					     $config.command ~ '  (default)' ),
		),
	));

	given $cli.parse(@arguments) {
		when Inf { }
		default  { $config.command = @*ARGS[$_ ... *] }
	}

	return $config;
}
