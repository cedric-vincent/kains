use v6;
use Test;

plan 6;

{
	use App::Kains;
	throws_like { App::Kains::start('/this/does/not/exist') }, X::Kains, 'top level error';
}

{
	use App::Kains::Commandline;

	throws_like { Interface.new.parse(['-a']) }, X::Command-line, 'unknown switch';

	throws_like { Interface.new(parameters =>
			( Param.new(callback => sub ($a) { !!! } ))).parse(['-a']) },
			X::Command-line, 'missing parameter';
}

{
	use App::Kains::Config;

	dies_ok { Config.new.set-rootfs('/this/does/not/exist') }, 'invalid rootfs';
	dies_ok { Config.new.add-binding('/this/does/not/exist', 'whatever') }, 'invalid mount source';
}

{
	use App::Kains::Native;
	throws_like { chroot('/this/does/not/exist') }, X::Errno, 'native error';
}
