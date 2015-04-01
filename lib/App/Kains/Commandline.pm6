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

	method print-long-help {
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

	method print-short-help {
		say 'Usage: kains [options] ... [command]';
		say '';

		my @items;
		for @.parameters {
			@items.push: {	switch		=> .switches[0],
					params		=> .callback.signature.params».name,
					description	=> .description.lines[0] }
		}

		my $first-row-length = max(@items.map({ .<switch>.chars + .<params>.chars + 1}));

		for @items {
			my $first-row = .<switch> ~ do { ' ' ~ .<params> if .<params>.chars };

			print $first-row;
			print ' ' xx ($first-row-length - $first-row.chars);
			print '  ';
			say .<description>;
		}
	}
}
