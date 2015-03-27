module Kains;

need Kains::Config::Command-line;
need Kains::Core;

our sub start(--> Int) {
	my $config = Kains::Config::Command-line::parse(@*ARGS);

	return Kains::Core::launch($config).exit;

	CATCH {
		when X::Command-line {
			die X::Kains.new(message => qq:to/END/
				{ .message }
				Please have a look at the --help option
				END
			);
		}
	}
}
