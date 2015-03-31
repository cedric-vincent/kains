module App::Kains::Parameters;

use App::Kains::Config;
use App::Kains::Commandline;

my @R-bindings = <
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
	/tmp/ >,
	%*ENV<HOME>;

my @S-bindings = <
	/etc/host.conf
	/etc/hosts
	/etc/nsswitch.conf
	/dev/
	/sys/
	/proc/
	/tmp/ >,
	%*ENV<HOME>;

our sub parse-arguments(@arguments --> Config) is export {
	my Config $config .= new;

	my Interface $cli .= new(parameters => (
		Param.new(
			switches	=> < -r --rootfs >,
			callback	=> sub { $config.set-rootfs($^path) },
			examples	=> ( %*ENV<HOME> ~ '/rootfs/centos-6-x86',
					     '/tmp/ubuntu-12.04-x86_64',
					     $config.rootfs ~ '  (default)' ),
			description	=> q:to/END/,
Use $path as the new root file-system, aka. guest rootfs.

Programs will be executed from, and confined into the guest rootfs
specified by $path.  Although, files and directories from the host
rootfs can be made visible within the guest rootfs by using "-b" and
"-B".  By default the guest rootfs is "/", this makes sense when using
"-B" to relocate files within the host rootfs, or when using "-0" to
fake root privileges.

It is recommended to use "-R" or "-S" instead.
END
		),
		Param.new(
			switches	=> < -b -m --bind --mount >,
			callback	=> sub { $config.add-binding($^path) },
			examples	=> ( '/proc', '/dev' , %*ENV<HOME>),
			description	=> q:to/END/,
Make $path visible in the guest rootfs, at the same location.

The content of $path will be made visible within the guest rootfs.
Unlike with "-B", the location isn't changed, that is, it will be
accessible as $path within the guest rootfs too.
END
		),
		Param.new(
			switches	=> < -B -M --bind-elsewhere --mount-elsewhere >,
			callback	=> sub ($path, $location) { $config.add-binding($path, $location) },
			examples	=> ( %*ENV<HOME> ~ '/my_hosts /etc/hosts',
					     '/tmp/opt /opt',
					     '/bin/bash /bin/sh' ),
			description	=> q:to/END/,
Make $path visible in the guest rootfs, at the given $location.

The content of $path will be made visible at the given $location
within the guest rootfs.  This is especially useful when using "/" as
the guest rootfs to make the content of $path accessible somewhere
else in the file-system hierarchy.
END
		),
		Param.new(
			switches	=> < -w --pwd --cwd --working-directory >,
			callback	=> sub { $config.cwd = $^path },
			examples	=> ( '/tmp',
					     $config.cwd ~ '  (first default)',
					     '/  (second default)' ),
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

Some programs launched within a 32-bit guest rootfs might get confused
if they detect they are run by a 64-bit kernel.  This option makes
Linux declare itself and behave as a 32-bit kernel.
END
		),
		Param.new(
			switches	=> < -R >,
			callback	=> sub { $config.set-rootfs($^path);
						 $config.add-bindings(@R-bindings) },
			description	=> q:c:to/END/,
Use $path as guest rootfs and make some host files still visible.

Programs will be executed from, and confined into the guest rootfs
specified by $path.  Although a set of files and directories from the
host rootfs will still be visible within the guest rootfs.  These
files and directories typically contains information that are likely
required by guest programs: { do for @R-bindings { "\n    - $_" } }
END
		),
		Param.new(
			switches	=> < -S >,
			callback	=> sub { $config.set-rootfs($^path);
						 $config.add-bindings(@S-bindings);
						 $config.root-id = True },
			description	=> q:c:to/END/,
Use $path as guest rootfs and make some host files still visible + fake "root" privileges.

This option is similar to "-0 -R" but it makes visible within the
guest rootfs a smaller set of host files and directories (to avoid
unexpected changes): { do for @S-bindings { "\n    - $_" } }

This option is useful to create and install packages into the guest
rootfs.
END
		),
		Param.new(
			switches	=> < -h --help --usage >,
			callback	=> sub { $cli.print-help; exit 1 },
			description	=> q:to/END/,
Print the help message, then exit.
END
		),
		Param.new(
			switches	=> < -- >,
			callback	=> sub (*@command) { $config.command = @command },
			examples	=> ( 'emacs',
					     '/usr/bin/wget',
					     $config.command ~ '  (default)' ),
			description	=> q:to/END/,
Launch @command in the virtualized environment.

This option is only syntactic sugar since it is possible to specify
the @command at the very end of the command-line, ie. after all other
options.
END
		),
	));

	given $cli.parse(@arguments) {
		when $_ < +@arguments { $config.command = @arguments[$_ ... *] }
	}

	return $config;
}
