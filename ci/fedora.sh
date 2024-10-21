#!/bin/bash

set -e

DNFCMD="dnf"
SPECFLAG="--spec "
SUDOCMD="sudo"

if [ -z "$OSVERSION" ]; then
	eval "$(grep '^VERSION_ID=' /etc/os-release)"
	OSVERSION=$VERSION_ID
fi

if [ "$OSVERSION" = "rawhide" ] || [ "$((OSVERSION + 0))" -gt 40 ]; then
	DNFCMD="dnf5"
	SPECFLAG=""
fi

if [ "$(id -u)" = 0 ]; then
	SUDOCMD=""
fi
exit 0
# Note: Removed .x86_64 suffix from glibc-devel for aarch64 compatibility.
# Previously, it was included to ensure that the x86_64 version of glibc-devel
# was installed, particularly in cases where glibc-devel for i686 was present
# and would not trigger the x86_64 install. This situation is rare but could
# depend on specific user setups.
$SUDOCMD $DNFCMD install -y rpm-build make gcc gcc-c++ libdrm-devel systemd-rpm-macros glibc-devel wget git "$DNFCMD-command(builddep)"

$SUDOCMD $DNFCMD builddep -y $SPECFLAG./displaylink.spec

make $SPECIFICTARGET
