# $NetBSD$
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

task_load unittest
task_load version 2>/dev/null || task_load -s ".subr.in" version

test1()
{
	describe="1 < 1+1"
	task_version_compare -v 1 1+1
}

test2()
{
	describe="1.0 < 1.0.1"
	task_version_compare -v 1.0 1.0.1
}

test3()
{
	describe="1.23.2 < 1.23.11"
	task_version_compare -v 1.23.2 1.23.11
}

test4()
{
	describe="1.2alpha < 1.2"
	task_version_compare -v 1.2alpha 1.2
}

test5()
{
	describe="1.2alpha < 1.2alpha1"
	task_version_compare -v 1.2alpha 1.2alpha1
}

test6()
{
	describe="1.2alpha2 < 1.2alpha11"
	task_version_compare -v 1.2alpha2 1.2alpha11
}

test7()
{
	describe="1.2alpha < 1.2beta"
	task_version_compare -v 1.2alpha 1.2beta
}

test8()
{
	describe="1.2alpha < 1.2rc"
	task_version_compare -v 1.2alpha 1.2rc
}

test9()
{
	describe="1.2beta < 1.2rc"
	task_version_compare -v 1.2beta 1.2rc
}

test10()
{
	describe="1.2alpha < 1.2e"
	task_version_compare -v 1.2alpha 1.2e
}

test11()
{
	describe="1.2a < 1.2b"
	task_version_compare -v 1.2a 1.2b
}

test12()
{
	describe="1.2a2 < 1.2a11"
	task_version_compare -v 1.2a2 1.2a11
}

test13()
{
	describe="1.2rc1 < 1.2a"
	task_version_compare -v 1.2rc1 1.2a
}

test14()
{
	describe="1.2 < 1.2+1"
	task_version_compare -v 1.2 1.2+1
}

test15()
{
	describe="1.2alpha99 < 1.2+1"
	task_version_compare -v 1.2alpha99 1.2+1
}

test16()
{
	describe="1.2+2 < 1.2+11"
	task_version_compare -v 1.2+2 1.2+11
}

test17()
{
	describe="(null) < 1.0"
	task_version_compare -v "" "1.0"
}

test18()
{
	describe="1.2.5 = 1.2e"
	task_version_compare -v 1.2.5 1.2e
	[ $? -eq 1 ]
}

test19()
{
	describe="1.0.0 = 1.0.0"
	task_version_compare -v 1.0.0 1.0.0
	[ $? -eq 1 ]
}

test20()
{
	describe="1.2.3 < 1abc2.3"
	task_version_compare -v 1.2.3 1abc2.3
}

test21()
{
	describe="Bravo < Charlie"
	task_version_compare -v Bravo Charlie
}

test22()
{
	describe="1.2+1 < 1.2.1"
	task_version_compare -v 1.2+1 1.2.1
}

test23()
{
	describe="1_2_0 = 1.2.0"
	task_version_compare -v 1_2_0 1.2.0
	[ $? -eq 1 ]
}

test24()
{
	describe="1.2alpha < 1.2alpha+1"
	task_version_compare -v 1.2alpha 1.2alpha+1
}

test25()
{
	describe="version_check 1.2 >= 1.0"
	task_version_check 1.2 ">=" 1.0
}

test26()
{
	describe="version_check 1.2 >= 2.0 is false"
	if task_version_check 1.2 ">=" 2.0; then
		return 1
	fi
}

test27()
{
	describe="version_check 1.2 > 1.0"
	task_version_check 1.2 ">" 1.0
}

test28()
{
	describe="version_check 1.2 > 2.0 is false"
	if task_version_check 1.2 ">" 2.0; then
		return 1
	fi
}

test29()
{
	describe="version_check 1.2 = 1.2"
	task_version_check 1.2 "=" 1.2
}

test30()
{
	describe="version_check 1.2 = 2.0 is false"
	if task_version_check 1.2 "=" 2.0; then
		return 1
	fi
}

test31()
{
	describe="version_check 1.2 < 2.0"
	task_version_check 1.2 "<" 2.0
}

test32()
{
	describe="version_check 1.2 < 1.0 is false"
	if task_version_check 1.2 "<" 1.0; then
		return 1
	fi
}

test33()
{
	describe="version_check 1.2 <= 2.0"
	task_version_check 1.2 "<=" 2.0
}

test34()
{
	describe="version_check 1.2 <= 1.0 is false"
	if task_version_check 1.2 "<=" 1.0; then
		return 1
	fi
}

test35()
{
	describe="version_check 1.2 *"
	task_version_check 1.2 "*" ""
}

test36()
{
	describe="version_check 1.2 >= 1.0 < 2.0"
	task_version_check 1.2 ">=" 1.0 "<" 2.0
}

test37()
{
	describe="version_check 1.2 >= 1.0 < 1.1 is false"
	if task_version_check 1.2 ">=" 1.0 "<" 1.1; then
		return 1
	fi
}

task_run_tests "$@"
