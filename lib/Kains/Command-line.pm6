module Kains::Command-line;

use Kains::Config;
use Command-line;

=begin R-bindings
=item /etc/host.conf
=item /etc/hosts
=item /etc/hosts.equiv
=item /etc/mtab
=item /etc/netgroup
=item /etc/networks
=item /etc/passwd
=item /etc/group
=item /etc/nsswitch.conf
=item /etc/resolv.conf
=item /etc/localtime
=item /dev/
=item /sys/
=item /proc/
=item /tmp/
=item $HOME
=end R-bindings

=begin S-bindings
=item /etc/host.conf
=item /etc/hosts
=item /etc/nsswitch.conf
=item /dev/
=item /sys/
=item /proc/
=item /tmp/
=item $HOME
=end S-bindings

sub add-named-bindings(Kains::Config $config, Str $name) {
	my $doc = $=pod.first: *.name === $name ~ '-bindings';

	for $doc.contents {
		next if $_ !~~ Pod::Item;
		warn if .contents != 1;
		warn if .contents[0] !~~ Pod::Block::Para;

		my Str $path = ~$_.contents[0].contents;

		if $path ~~ m/^\$(.*)/ {
			$path = %*ENV{$0};
		}

		$config.add-binding($path);
	}
}

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
			callback	=> sub { $config.add-binding($^a) },
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
			switches	=> < -w --pwd --cwd --working-directory >,
			callback	=> sub { $config.cwd = $^a },
			examples	=> ( '/tmp',
					     $config.cwd ~ '  (first default)',
					     '/  (second default)' )
		),
		Command-line::Option.new(
			switches	=> < -0 --root-id >,
			callback	=> sub { $config.root-id = True },
		),
		Command-line::Option.new(
			switches	=> < --32 --32bit --32bit-mode >,
			callback	=> sub { $config.mode32 = True },
		),
		Command-line::Option.new(
			switches	=> < -R >,
			callback	=> sub { $config.set-rootfs($^a);
						 add-named-bindings($config, 'R') },
		),
		Command-line::Option.new(
			switches	=> < -S >,
			callback	=> sub { $config.set-rootfs($^a);
						 add-named-bindings($config, 'S');
						 $config.root-id = True },
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
		when $_ < +@arguments { $config.command = @*ARGS[$_ ... *] }
	}

	return $config;
}
