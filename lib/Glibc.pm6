module Glibc;

use NativeCall;

sub getuid(--> int) is native is export(:getuid) { * }
sub getgid(--> int) is native is export(:getgid) { * }
