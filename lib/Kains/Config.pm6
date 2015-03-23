class Kains::Config {
	has Str $.rootfs	= '/';
	has Enum @.bindings	= ();
	has Str $.cwd		= ~$*CWD;
	has Bool $.root-id	= False;
	has Str @.command	= < /bin/sh -l >;

	sub check-directory($path) {
		given $path.IO {
			die qq/"$path" doesn't exist/	  if $_ !~~ :e;
			die qq/"$path" isn't a directory/ if $_ !~~ :d;
			die qq/"$path" isn't accessible ('x' permission denied)/ if $_ !~~ :x;
			die qq/"$path" isn't accessible ('r' permission denied)/ if $_ !~~ :r;
		}
	}

	multi method set-rootfs(Str $path) {
		check-directory($path);
		$!rootfs = $path;
	}

	multi method add-binding(Str $host-path, Str $guest-path) {
		check-directory($host-path);

		# $guest-path can't be checked now because symlinks
		# have to be resolved respectively to the guest
		# rootfs.

		@.bindings.push: $host-path => $guest-path;
	}

	multi method set-cwd(Str $path) {
		check-directory($path);
		$!cwd = $path;
	}
}
