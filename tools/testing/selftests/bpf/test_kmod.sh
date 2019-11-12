#!/bin/sh
# SPDX-License-Identifier: GPL-2.0

# Kselftest framework requirement - SKIP code is 4.
ksft_skip=4

msg="skip all tests:"
if [ "$(id -u)" != "0" ]; then
	echo $msg please run this as root >&2
	exit $ksft_skip
fi

SRC_TREE=../../../../

test_run()
{
	sysctl -w net.core.bpf_jit_enable=$1 2>&1 > /dev/null
	sysctl -w net.core.bpf_jit_harden=$2 2>&1 > /dev/null

	echo "[ JIT enabled:$1 hardened:$2 ]"
	dmesg -C
	insmod $SRC_TREE/lib/test_bpf.ko 2> /dev/null
	if [ $? -ne 0 ]; then
		rc=1
	fi
	rmmod  test_bpf 2> /dev/null
	dmesg | grep FAIL
}

test_save()
{
	JE=`sysctl -n net.core.bpf_jit_enable`
	JH=`sysctl -n net.core.bpf_jit_harden`
}

test_restore()
{
	sysctl -w net.core.bpf_jit_enable=$JE 2>&1 > /dev/null
	sysctl -w net.core.bpf_jit_harden=$JH 2>&1 > /dev/null
}

rc=0
test_save
test_run 0 0
test_run 1 0
test_run 1 1
test_run 1 2
test_restore
exit $rc
