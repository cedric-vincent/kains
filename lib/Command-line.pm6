
class Command-line::Option {
	has Str @.switches;
	has Callable $.callback;
	has Str @.examples;
	has Str $.description;
}

class X::Command-line is Exception {
	has Str $.argument;
	has Str $.message;
	has $.option;

	method message {
		my $message = "Error while processing $!argument option: $!message";

		if $!option.defined {
			for $!option.examples {
				FIRST { $message ~= "\nHere follow some examples for this option:" }
				$message ~= "\n\t$.argument $_";
			}
		}

		return $message;
	}
}

class Command-line::Interface {
	has Command-line::Option @.options;

	method parse(@arguments --> int) {
		my $index = 0;
		loop (; $index < @arguments; $index++) {
			my $current-argument ::= @arguments[$index];

			my $option = @.options.first({ any(.switches) === $current-argument });
			if ! $option.defined {
				die 'unknown switch' if $current-argument ~~ /^'-'/;
				return $index;
			}

			my @parameters = ();
			if $option.callback.count > 0 {
				my $old-index = $index;
				$index += $option.callback.count;

				@parameters = @arguments[$old-index + 1 ... $index];
				die 'missing parameter' if ! all(@parameters».defined) or @parameters == 0;
			}

			$option.callback.(|@parameters);

			CATCH {
				when X::AdHoc {
					die X::Command-line.new(:$option,
								message  => .message,
								argument => $current-argument);
				}
			}
		}

		return $index;
	}

	method print-help {
		...
	}
}
