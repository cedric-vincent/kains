module App::Kains;

use App::Kains::Parameters;
use App::Kains::Core;

our sub start(--> Int) {
	my $config = parse-arguments(@*ARGS);

	return launch($config).exit;

	CATCH {
		when X::Command-line {
			die X::Kains.new(message => qq:to/END/
				{ .message }
				Please have a look at the --help option.
				END
			);
		}
	}
}
