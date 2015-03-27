MODULES = lib/Kains.pm6			\
	  lib/Kains/Config.pm6		\
	  lib/Kains/Command-line.pm6	\
	  lib/Kains/Linux/Syscall.pm6	\
	  lib/Command-line.pm6

PRECOMPILED_MODULES = $(MODULES:.pm6=.pm6.moarvm)

.PHONY: precompile clean
precompile: $(PRECOMPILED_MODULES)

clean:
	rm -f $(PRECOMPILED_MODULES)

%.moarvm: %
	perl6 -Ilib --target=mbc --output=$@ $*

# Why the pre-compilation order matters?  How to know the dependency automatically?
lib/Kains.pm6.moarvm: lib/Kains/Config.pm6.moarvm lib/Kains/Command-line.pm6.moarvm lib/Kains/Linux/Syscall.pm6.moarvm
lib/Kains/Command-line.pm6.moarvm: lib/Kains/Config.pm6.moarvm lib/Command-line.pm6.moarvm
