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

module App::Kains::Parameters;

use App::Kains::Config;
use App::Kains::Commandline;

sub R-bindings {
	my @bindings;
	@bindings.push($_) if .IO.e for <
		/etc/host.conf
		/etc/hosts
		/etc/hosts.equiv
		/etc/mtab
		/etc/netgroup
		/etc/networks
		/etc/passwd
		/etc/group
		/etc/nsswitch.conf
		/etc/resolv.conf
		/etc/localtime
		/dev/
		/sys/
		/proc/
		/tmp/
		/run/ >,
# NYI		/var/run/dbus/system_bus_socket	>,
		%*ENV<HOME>;

	@bindings;
}

sub S-bindings {
	my @bindings;
	@bindings.push($_) if .IO.e for <
		/etc/host.conf
		/etc/hosts
		/etc/nsswitch.conf
		/etc/resolv.conf
		/dev/
		/sys/
		/proc/
		/tmp/
		/run/shm >,
		%*ENV<HOME>;

	@bindings;
}

our sub new-config-from-arguments(@arguments --> Config) is export {
	my Config $config .= new;

	my Interface $cli .= new(parameters => (
		Param.new(
			switches	=> < -r --rootfs >,
			callback	=> sub { $config.set-rootfs($^path) },
			examples	=> « ~/rootfs/centos-6-x86
					     /tmp/ubuntu-12.04-x86_64
					     "{ $config.rootfs }  (default)" »,
			description	=> q:to/END/,
Use $path as the new root file-system, aka. virtual rootfs.

Programs will be executed from, and confined within the virtual rootfs
specified by $path.  Although, files and directories of the actual
rootfs can be made visible from the virtual rootfs by using "-b" and
"-B".  By default the virtual rootfs is "/", this makes sense when
using "-B" to relocate files within the actual rootfs, or when using
"-0" to fake root privileges.

It is recommended to use "-R" or "-S" instead.
END
		),
		Param.new(
			switches	=> < -b -m --bind --mount >,
			callback	=> sub { $config.add-binding($^path) },
			examples	=> < /proc /dev $HOME >,
			description	=> q:to/END/,
Make $path visible from the virtual rootfs, at the same location.

The content of $path will be made visible from the virtual rootfs.
Unlike with "-B", the location isn't changed, that is, it will be
accessible as $path within the virtual rootfs too.
END
		),
		Param.new(
			switches	=> < -B -M --bind-elsewhere --mount-elsewhere >,
			callback	=> sub ($path, $location) { $config.add-binding($path, $location) },
			examples	=> « '~/my_hosts /etc/hosts'
					     '/tmp/opt /opt'
					     '/bin/bash /bin/sh' »,
			description	=> q:to/END/,
Make $path visible from the virtual rootfs, at the given $location.

The content of $path will be made visible at the given $location from
the virtual rootfs.  This is especially useful when using "/" as the
virtual rootfs to make the content of $path accessible somewhere else
in the file-system hierarchy.
END
		),
		Param.new(
			switches	=> < -w --pwd --cwd --working-directory >,
			callback	=> sub { $config.cwd = $^path },
			examples	=> « /tmp
					     "{ $config.cwd }  (first default)"
					     '/  (second default)' »,
			description	=> q:to/END/,
Set the initial working directory to $path.

Some programs expect to be launched from a specific directory but they
do not move to it by themselves.  This option avoids the need for
running a shell only to change the current working directory.
END
		),
		Param.new(
			switches	=> < -0 --root-id >,
			callback	=> sub { $config.root-id = True },
			description	=> q:to/END/,
Set user and group identities virtually to "root/root".

Some programs will refuse to work if they are not run with "root"
privileges, even if there is no strong reasons for that.  This is
typically the case with package managers.  This option changes the
user and group identities to "root/root" in order to bypass this kind
of limitation, however all operations are still performed with the
original user and group identities.
END
		),
		Param.new(
			switches	=> < --32 --32bit --32bit-mode >,
			callback	=> sub { $config.mode32 = True },
			description	=> q:to/END/,
Make Linux declare itself and behave as a 32-bit kernel.

Some programs launched within a 32-bit virtual rootfs might get
confused if they detect they are run by a 64-bit kernel.  This option
makes Linux declare itself and behave as a 32-bit kernel.
END
		),
		Param.new(
			switches	=> < -R >,
			callback	=> sub { $config.set-rootfs($^path);
						 $config.add-bindings(R-bindings) },
			description	=> q:c:to/END/,
Use $path as virtual rootfs + bind some files/directories.

Programs will be executed from, and confined within the virtual rootfs
specified by $path.  Although a set of files and directories of the
actual rootfs will still be visible from the virtual rootfs.  These
files and directories contain information that are likely required by
virtual programs:
{ do for R-bindings() { "\n    * $_" } }
END
		),
		Param.new(
			switches	=> < -S >,
			callback	=> sub { $config.set-rootfs($^path);
						 $config.add-bindings(S-bindings);
						 $config.root-id = True },
			description	=> q:c:to/END/,
Use $path as virtual rootfs + bind some files/directories + fake "root".

This option is similar to "-0 -R" but it makes visible from the
virtual rootfs a smaller set of files and directories of the actual
rootfs (to avoid unexpected changes):
{ do for S-bindings() { "\n    * $_" } }

This option is useful to create and install packages into the virtual
rootfs.
END
		),
		Param.new(
			switches	=> < -h --help --usage >,
			callback	=> sub { $cli.print-long-help; exit 1 },
			description	=> q:to/END/,
Print the help message, then exit.
END
		),
		Param.new(
			switches	=> < -- >,
			callback	=> sub (*@command) { $config.command = @command },
			examples	=> « emacs
					     /usr/bin/wget
					     "{ $config.command }  (default)" »,
			description	=> q:to/END/,
Launch @command in the virtual environment.

This option is only syntactic sugar since it is possible to specify
the @command at the very end of the command-line, ie. after all other
options.
END
		),
	));

	if ! @arguments {
		$cli.print-short-help;
		exit 1;
	}

	given $cli.parse(@arguments) {
		when $_ < +@arguments { $config.command = @arguments[$_ ... *] }
	}

	$config;
}
