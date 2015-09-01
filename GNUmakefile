sources = Commandline Config Core Core/Chrooted Native Parameters X

k = lib/App/Kains
o = .pm6.moarvm
objects = $k$o $(sources:%=$k/%$o)

######################################################################
# Rules

.PHONY: all clean test check

all: $(objects)

clean:
	rm -f $(objects)

test check: $(objects)
	prove -e 'perl6 -Ilib' t/

%.moarvm: %
	perl6 -Ilib --target=mbc --output=$@ $<

######################################################################
# Dependencies

$k$o:               $k/Parameters$o $k/Core$o
$k/Core$o:          $k/Core/Chrooted$o $k/Native$o $k/Config$o $k/X$o
$k/Core/Chrooted$o: $k/Config$o $k/Native$o $k/X$o
$k/Parameters$o:    $k/Config$o $k/Commandline$o

