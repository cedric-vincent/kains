==================================================
 Kains — container tool based on Linux namespaces
==================================================


Synopsis
========

kains [options] ... [command]


Description
===========

Kains's main purpose is to confine programs within a virtual rootfs.
However it is possible to selectively make files of the actual rootfs
visible from the virtual rootfs.  Kains can also be used to make files
and directories accessible elsewhere in the file-system hierarchy.
Kains does not need any privileges or setup, although it requires
Perl 6 runtime and a Linux kernel that supports user namespaces.


Options
=======

The command-line interface is composed of two parts: first Kains's
parameters, then the command to launch (the default is "/bin/sh -l" if
none is specified).  This section describes the parameters supported
by Kains, that is, the first part of its command-line interface:

-r $path
--rootfs $path
    Use $path as the new root file-system, aka. virtual rootfs.

    Programs will be executed from, and confined within the virtual
    rootfs specified by $path.  Although, files and directories of the
    actual rootfs can be made visible from the virtual rootfs by using
    "-b" and "-B".  By default the virtual rootfs is "/", this makes
    sense when using "-B" to relocate files within the actual rootfs,
    or when using "-0" to fake root privileges.

    It is recommended to use "-R" or "-S" instead.

    Some examples:

        -r ~/rootfs/centos-6-x86
        -r /tmp/ubuntu-12.04-x86_64
        -r /  (default)

-b $path
-m $path
--bind $path
--mount $path
    Make $path visible from the virtual rootfs, at the same location.

    The content of $path will be made visible from the virtual rootfs.
    Unlike with "-B", the location isn't changed, that is, it will be
    accessible as $path within the virtual rootfs too.

    Some examples:

        -b /proc
        -b /dev
        -b $HOME

-B $path $location
-M $path $location
--bind-elsewhere $path $location
--mount-elsewhere $path $location
    Make $path visible from the virtual rootfs, at the given $location.

    The content of $path will be made visible at the given $location
    from the virtual rootfs.  This is especially useful when using "/"
    as the virtual rootfs to make the content of $path accessible
    somewhere else in the file-system hierarchy.

    Some examples:

        -B ~/my_hosts /etc/hosts
        -B /tmp/opt /opt
        -B /bin/bash /bin/sh

-w $path
--pwd $path
--cwd $path
--working-directory $path
    Set the initial working directory to $path.

    Some programs expect to be launched from a specific directory but
    they do not move to it by themselves.  This option avoids the need
    for running a shell only to change the current working directory.

    Some examples:

        -w /tmp
        -w $PWD  (first default)
        -w /  (second default)

-0
--root-id
    Set user and group identities virtually to "root/root".

    Some programs will refuse to work if they are not run with "root"
    privileges, even if there is no strong reasons for that.  This is
    typically the case with package managers.  This option changes the
    user and group identities to "root/root" in order to bypass this
    kind of limitation, however all operations are still performed
    with the original user and group identities.

--32
--32bit
--32bit-mode
    Make Linux declare itself and behave as a 32-bit kernel.

    Some programs launched within a 32-bit virtual rootfs might get
    confused if they detect they are run by a 64-bit kernel.  This
    option makes Linux declare itself and behave as a 32-bit kernel.

-R $path
    Use $path as virtual rootfs + bind some files/directories.

    Programs will be executed from, and confined within the virtual
    rootfs specified by $path.  Although a set of files and
    directories of the actual rootfs will still be visible from the
    virtual rootfs.  These files and directories contain information
    that are likely required by virtual programs:

        - /etc/host.conf
        - /etc/hosts
        - /etc/hosts.equiv
        - /etc/mtab
        - /etc/netgroup
        - /etc/networks
        - /etc/passwd
        - /etc/group
        - /etc/nsswitch.conf
        - /etc/resolv.conf
        - /etc/localtime
        - /dev/
        - /sys/
        - /proc/
        - /tmp/
        - /run/
        - $HOME

-S $path
    Use $path as virtual rootfs + bind some files/directories + fake "root".

    This option is similar to "-0 -R" but it makes visible from the
    virtual rootfs a smaller set of files and directories of the
    actual rootfs (to avoid unexpected changes):

        - /etc/host.conf
        - /etc/hosts
        - /etc/nsswitch.conf
        - /etc/resolv.conf
        - /dev/
        - /sys/
        - /proc/
        - /tmp/
        - /run/shm
        - $HOME

    This option is useful to create and install packages into the virtual
    rootfs.

-h
--help
--usage
    Print the help message, then exit.

-- @command
    Launch @command in the virtual environment.

    This option is only syntactic sugar since it is possible to
    specify the @command at the very end of the command-line,
    ie. after all other options.

    Some examples:

        -- emacs
        -- /usr/bin/wget
        -- /bin/sh -l  (default)


Exit Status
===========

If an internal error occurs, Kains returns a non-zero exit status,
otherwise it returns the exit status of the last terminated program.
When an error occurs, the only way to know if it comes from the
confined program or from Kains itself is to have a look at the error
message.


Tutorial
========

In this tutorial, it is assumed "~/rootfs/ubuntu-12.04/" contains
files from an Ubuntu 12.04 system.  See section "Download" to obtain
such a rootfs easily.

To confine a program using Kains, specify the path to the virtual
rootfs using the "-r" option, followed by the program name and its
arguments.  For instance, the command below executes "cat /etc/motd"
confined into "~/rootfs/ubuntu-12.04":

    $ kains -r ~/rootfs/ubuntu-12.04/ cat /etc/motd

    Welcome to Ubuntu 12.04.5 LTS

Kains executes "/bin/sh -l" if no program is specified, thus the
shortest way to confine an interactive shell is:

    $ kains -r ~/rootfs/ubuntu-12.04/

Once a program is confined, all its sub-programs are confined too.
For example, when executing "cat /etc/motd" from the interactive shell
above:

    $ cat /etc/motd

    Welcome to Ubuntu 12.04.5 LTS

Although, some programs needs to access files of the actual rootfs.
For instance:

    $ kains -r ~/rootfs/ubuntu-12.04/

    $ ps -o tty,command
    Cannot find /proc/version - is /proc mounted?

The solution is to tell Kains to make these files visible from the
virtual rootfs, using the "-b" option:

    $ kains -r ~/rootfs/ubuntu-12.04/ -b /proc

    $ ps -o tty,command
    TT       COMMAND
    ?        [...]
    ?        /bin/sh -l
    ?        ps -o tty,command
    ?        -bash

Actually there's a bunch of such required files, that's why Kains
provides an option that both confines and makes a predefined set of
files visible from the virtual rootfs:

    $ kains -R ~/rootfs/ubuntu-12.04/

    $ ps -o tty,command
    TT       COMMAND
    pts/0    [...]
    pts/0    /bin/sh -l
    pts/0    ps -o tty,command
    pts/0    -bash

It is possible that some programs will not work correctly if they are
not run by the "root" user, this is typically the case with package
managers.  In this case, Kains will fake the root identity and its
privileges if the "-0" (zero) option is specified:

    $ kains -r ~/rootfs/ubuntu-12.04/ -0

    # id
    uid=0(root) gid=0(root) [...]

    # mkdir /tmp/foo
    # chmod a-rwx /tmp/foo
    # echo 'I bypass file-system permissions.' > /tmp/foo/bar
    # cat /tmp/foo/bar
    I bypass file-system permissions.

This option is typically required to create or install packages into
the virtual rootfs.  However, it is not recommended to use the "-R"
option when installing a package since it may try to update files of
the host rootfs that were made visible from the virtual rootfs, like
"/etc/group" for instance.  Instead, it is highly recommended to use
the "-S" option.  This latter enables the "-0" option and make visible
a smaller set of files that are known to not be updated by packages:

    $ kains -S ~/rootfs/ubuntu-12.04/

    # apt-get install build-essential
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    The following extra packages will be installed:
    [...]

It is worth saying that the default path to virtual rootfs is "/" if
none is specified.  In this case, Kains is typically used to make
files accessible somewhere else in the actual rootfs.  This is useful
to trick programs that perform access to hard-coded locations, like
some installation scripts:

    $ kains -B /tmp/alternate_opt /opt

    $ cd to/sources
    $ make install
    [...]
    install -m 755 prog "/opt/bin"
    [...] # prog is installed in "/tmp/alternate_opt/bin" actually

As shown in the example above, it is possible to override files or
directories not even owned by the user.  This can be used to change
the system configuration temporally and locally, ie. without impacting
programs not executed by Kains.  For instance, with the DNS setting:

    $ ls -l /etc/hosts
    -rw-r--r-- 1 root root 675 Mar  4  2011 /etc/hosts

    $ touch ~/alternate_hosts
    $ kains -B ~/alternate_hosts /etc/hosts

    $ echo '1.2.3.4 google.com' > /etc/hosts
    $ resolveip google.com
    IP address of google.com is 1.2.3.4
    $ echo '5.6.7.8 google.com' > /etc/hosts
    $ resolveip google.com
    IP address of google.com is 5.6.7.8

Another example: on most Linux distributions "/bin/sh" is a symbolic
link to "/bin/bash", whereas it points to "/bin/dash" on Debian and
Ubuntu.  As a consequence a "#!/bin/sh" script tested with Bash might
not work with Dash.  In this case, Kains can be used to set
non-disruptively "/bin/bash" as the default "/bin/sh":

    $ kains -B /bin/bash /bin/sh [...]


Installation
============

Kains is written in Perl 6.  The easiest way to get a Perl 6 runtime
is to use rakudobrew:

    $ git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew
    [...]
    $ export PATH=~/.rakudobrew/bin:$PATH
    $ rakudobrew build moar
    [...]
    $ rakudobrew build-panda
    [...]

Then, Kains can be installed that way:

    $ panda install Kains
    [...]
    $ export PATH=~/.rakudobrew/moar-nom/install/share/perl6/site/bin:$PATH


Rootfs
======

Here follows a couple of URLs where some archived rootfs can be freely
downloaded.  Note that "mknod" errors reported by "tar" when
extracting these archives should be ignored since special files of the
actual rootfs can be made visible from the virtual rootfs (see "-R"
option for details).

- http://download.openvz.org/template/precreated/

- https://images.linuxcontainers.org/images/

- http://distfiles.gentoo.org/releases/

- http://cdimage.ubuntu.com/ubuntu-core/releases/

- http://archlinuxarm.org/developers/downloads

Technically such archived rootfs can be created by running the
following command on the expected Linux distribution:

    tar --one-file-system --create --gzip --file my_rootfs.tar.gz /


License
=======

The following copyright notice both applies to this file and to Kains
sources:

    Copyright (C) 2015 STMicroelectronics

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301 USA.
