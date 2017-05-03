#!/bin/sh
#
# Copyright (c) 2017 The NetBSD Foundation, Inc.
# All rights reserved.
#
# This code is derived from software contributed to The NetBSD Foundation
# by Johnny C. Lam.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# NAME
#	shift_tests.sh -- shift test numbers up from a starting number
#
# SYNOPSIS
#	shift_tests.sh <script> <number> [<delta>]
#
# DESCRIPTION
#	shift_tests.sh is a helper script to help insert additional test
#	functions in the middle of a larger set of consecutively numbered
#	test functions.  It will rename test<number> to test<number+delta>
#	and all successive test numbers will also be shifted upward by
#	<delta>.
#
#	The <script> is the location of the script file to modify.  The
#	script should contain functions named "test1", "test2", etc., in
#	consecutive order with no gaps in the sequence.
#
#	The <number> argument is the starting test number to shift upward.
#
#	The <delta> argument is the amount to shift by, defaulting to 1.
#
# EXIT STATUS
#	The script exists with a value of 0 on success, and >0 if an error
#	occurs.
#

: ${TASK_MODULE_DIR:=..}
: ${TASK_TESTS_DIR:=.}

. ${TASK_MODULE_DIR}/load.subr

task_load unittest

shift_tests()
{
	: ${MV:=mv}
	: ${SED:=sed}

	[ $# -ge 2 ] || return 127
	local script="$1"; shift
	local number="$1"; shift
	local delta=${1:-1}

	# Load the script without executing the tests.
	task_load_test "$script" -s

	# Discover the maximum test number.
	local max=0
	local n=1
	local test_fn
	while : ; do
		test_fn="test$n"
		task_is_function "$test_fn" || break
		max=$n
		n=$(( $n + 1 ))
	done

	local newmax
	newmax=$(( $max + $delta ))

	# Output list of sed commands to shift all test numbers upward by
	# $delta and pipe to sed(1) to perform the shifts.
	#
	while [ $max -ge $number ]; do
		echo "s/test$max/test$newmax/g"
		max=$(( $max - 1 ))
		newmax=$(( $newmax - 1 ))
	done | ${SED} -f /dev/stdin "$script" > "$script.tmp"
	if [ $? -eq 0 ]; then
		${MV} -f "$script.tmp" "$script"
	fi
}

shift_tests "$@"
