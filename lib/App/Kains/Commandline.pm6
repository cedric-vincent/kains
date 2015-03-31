module App::Kains::Command-line;

class Param is export {
	has Str @.switches;
	has Callable $.callback;
	has Str @.examples;
	has Str $.description;
}

class X::Command-line is Exception {
	has Str $.switch;
	has Str $.message;
	has $.parameter;

	method message {
		my Str $message = "Error while processing \"$!switch\": $!message";

		if $!parameter.defined {
			for $!parameter.examples {
				FIRST { $message ~= "\nHere follow some examples for this switch:" }
				$message ~= "\n\t$!switch $_";
			}
		}

		return $message;
	}
}

class Interface is export {
	has Param @.parameters;

	method parse(@arguments --> int) {
		my $index = 0;
		loop (; $index < @arguments; $index++) {
			my $switch = @arguments[$index];

			my $parameter = @.parameters.first({ any(.switches) === $switch });
			if ! $parameter.defined {
				die 'unknown switch' if $switch ~~ /^'-'/;
				return $index;
			}

			my @callback-args;
			if $parameter.callback.count > 0 {
				my $old-index = $index;
				$index += $parameter.callback.count;

				@callback-args = @arguments[$old-index + 1 ... $index];
				die 'missing parameter' if ! all(@callback-args».defined)
							or @callback-args == 0;
			}

			$parameter.callback.(|@callback-args);

			CATCH {
				when X::AdHoc {
					die X::Command-line.new(:$parameter, :$switch, message => .message);
				}
			}
		}

		return $index;
	}

	method print-help {
		say q:to/END/;
		    Command-line interface
		    ----------------------
		    END

		for @.parameters {
			for .switches -> $switch {
				say "$switch " ~ .callback.signature.params».name;
			}

			say "    $_" for .description.lines;

			for .examples -> $example {
				FIRST { say "\n    Some examples:" }
				say "        " ~ .switches[0] ~ " $example";
			}

			print "\n";
		}
	}
}
