module App::Kains::Config;

class Config is export {
	has Str $.rootfs	= '/';
	has Enum @.bindings	= ();
	has Str $.cwd is rw	= ~$*CWD;
	has Bool $.root-id is rw = False;
	has Bool $.mode32 is rw  = False;
	has Str @.command	= < /bin/sh -l >;

	method set-rootfs(Str $path) {
		given $path.IO {
			die qq/"$_" doesn't exist/ if ! .e;
			die qq/"$_" isn't a directory/ if ! .d;
			die qq/"$_" isn't accessible ('x' permission denied)/ if ! .x;
			die qq/"$_" isn't accessible ('r' permission denied)/ if ! .r;
		}

		$!rootfs = $path;
	}

	method add-binding(Str $source, Str $destination = $source) {
		die qq/"$source" doesn't exist/ if ! $source.IO.e;

		# $destination path can't be checked now because
		# symlinks have to be resolved respectively to the
		# guest rootfs.

		# $source path have to be resolved before changing the
		# root directory.

		@.bindings.push: $source.IO.resolve => $destination;
	}

	method add-bindings(*@paths) {
		for @paths {
			$.add-binding($_);
		}
	}
}
