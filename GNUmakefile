MODULES = lib/Kains.pm6		\
	  lib/Glibc.pm6		\
	  lib/Glibc/Linux.pm6	\
	  lib/Glibc/Errno.pm6

PRECOMPILED_MODULES = $(MODULES:.pm6=.pm6.moarvm)

precompile: $(PRECOMPILED_MODULES)

%.moarvm: %
	perl6 -Ilib --target=mbc --output=$@ $*

# Why the pre-compilation order matters?
lib/Glibc/Linux.pm6.moarvm: lib/Glibc/Errno.pm6.moarvm
lib/Kains.pm6.moarvm: lib/Glibc/Errno.pm6.moarvm lib/Glibc/Linux.pm6.moarvm lib/Glibc.pm6.moarvm

clean:
	rm -f $(PRECOMPILED_MODULES)
