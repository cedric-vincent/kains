module Glibc;

use NativeCall;

sub getuid returns int is native is export(:getuid) { * }
sub getgid returns int is native is export(:getgid) { * }
