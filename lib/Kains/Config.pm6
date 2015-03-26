class Kains::Config {
	has Str $.rootfs	= '/';
	has Enum @.bindings	= ();
	has Str $.cwd is rw	= ~$*CWD;
	has Bool $.root-id is rw = False;
	has Bool $.mode32 is rw  = False;
	has Str @.command	= < /bin/sh -l >;

	multi method set-rootfs(Str $path) {
		given $path.IO {
			die qq/"$_" doesn't exist/	  if ! .e;
			die qq/"$_" isn't a directory/ if ! .d;
			die qq/"$_" isn't accessible ('x' permission denied)/ if ! .x;
			die qq/"$_" isn't accessible ('r' permission denied)/ if ! .r;
		}

		$!rootfs = $path;
	}

	multi method add-binding(Str $host-path, Str $guest-path = $host-path) {
		die qq/"$host-path" doesn't exist/ if ! $host-path.IO.e;

		# $guest-path can't be checked now because symlinks
		# have to be resolved respectively to the guest
		# rootfs.

		# $host-path have to be resolved before changing the
		# root directory.

		@.bindings.push: $host-path.IO.resolve => $guest-path;
	}
}
