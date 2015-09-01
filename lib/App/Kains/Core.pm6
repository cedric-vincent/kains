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

unit module App::Kains::Core;

use App::Kains::Core::Chrooted;
use App::Kains::Native;
use App::Kains::Config;
use App::Kains::X;

sub set-uid-mapping(int :$old-uid, int :$new-uid) {
	CATCH {	default { note "Warning: can't map user identity: { .message }" } }
	spurt '/proc/self/uid_map', "$new-uid $old-uid 1";
}

sub set-gid-mapping(int :$old-gid, int :$new-gid) {
	CATCH {	default { note "Warning: can't map group identity: { .message }" } }

	# This is not required on all Linux versions.
	try spurt '/proc/self/setgroups', 'deny';

	spurt '/proc/self/gid_map', "$new-gid $old-gid 1";
}

sub mount-actual-rootfs(Config $config --> Str) {
	return '' if $config.rootfs === '/';

	my Str $actual-rootfs = '/.kains-' ~ getpid;

	mkdir $config.rootfs ~ $actual-rootfs;
	mount '/', $config.rootfs ~ $actual-rootfs, '', MS_PRIVATE +| MS_BIND +| MS_REC, '';

	$actual-rootfs;
}

our sub launch(Config $config --> Proc) is export {
	CATCH {
		when X::Errno {
			my Str $message = "Error: { .message }";

			if .errno == EPERM
			or .errno == EINVAL and .function.name eq 'unshare' {
				$message ~= "\nIt seems your system doesn't support user namespaces."
			}

			die X::Kains.new: :$message, :works-with-proot;
		}
	}

	my ($new-uid, $old-uid) = getuid() xx 2;
	my ($new-gid, $old-gid) = getgid() xx 2;

	if $config.root-id {
		$new-uid = 0;
		$new-gid = 0;
	}

	unshare CLONE_NEWUSER +| CLONE_NEWNS;

	set-uid-mapping :$old-uid, :$new-uid;
	set-gid-mapping :$old-gid, :$new-gid;

	my $actual-rootfs = mount-actual-rootfs $config;

	chroot $config.rootfs;

	mount-bindings $actual-rootfs, $config;

	if $actual-rootfs {
		try umount2 $actual-rootfs, MNT_DETACH;
		try rmdir $actual-rootfs;
	}

	try chdir $config.cwd;
	if $! ~~ X::IO::Chdir {
		note $!.message ~ ' (in the new rootfs).';
		note 'Changing the current working directory to "/".';
		chdir '/';
	}

	personality(PER_LINUX32) if $config.mode32;

	my $status = run(|$config.command);
	if $status == -1 {
		die X::Kains.new: message =>
			"Error: { $config.command[0] } can't be found or can't be executed."
	}

	$status;
}
