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
#	mk_autobuild.sh -- generate Makefile.am for pkgtasks
#
# SYNOPSIS
#	mk_autobuild.sh [-a]
#
# DESCRIPTION
#	mk_autobuild.sh writes a Makefile.am file for the pkgtasks source
#	tree.  It MUST be run from the top-level source directory, and will
#	overwrite any existing Makefile.am in the top-level source
#	directory.
#
#	The options are as follows:
#
#	-a	If configure.ac is present, then run autoreconf(1) to
#		generate all necessary GNU autotools build infrastructure.
#
# EXIT STATUS
#	The script exits with a value of 0 on success, and >0 if an error
#	occurs.
#

if [ ! -f "COPYING" ]; then
	echo 1>&2 "${0##*/}: must be run from the top-level directory."
	exit 1
fi

###
# gen_append_var <varname> <value> ...
#
# Write to standard output a line that either sets or appends "<value> ..."
# to the make(1) variable <varname>.
#
gen_append_var()
{
	local varname="$1"; shift
	local seen_varname="__${varname}_seen"
	local seen
	if eval test -z "\$$seen_varname"; then
		eval $seen_varname="yes"
	else
		seen="yes"
	fi
	if [ $# -eq 0 ]; then
		if [ -z "$seen" ]; then
			echo "$varname ="
		fi
	elif [ -z "$seen" ]; then
		echo "$varname = $@"
	else
		echo "$varname += $@"
	fi
}

gen_license()
{
	local save_IFS="$IFS"; IFS=
	local line
	while read line; do
		IFS=$save_IFS
		case $line in
		"")	echo "#" ;;
		*)	echo "# $line" ;;
		esac
		save_IFS=$IFS; IFS=
	done < COPYING
}

gen_doc()
{
	: ${CAT:=cat}

	gen_append_var doc_DATA AUTHORS COPYING README.md
	gen_append_var noinst_DATA README.md
	gen_append_var EXTRA_DIST "\$(doc_DATA)"
}

gen_build()
{
	: ${CAT:=cat}
	gen_append_var PHONY_TARGETS ""
	${CAT} << 'EOF'

CHMOD = chmod
MV = mv

# Assume that $source and $target are in the same directory.
BUILD_FILE = \
	$(SED)	-e "s,__POSIX_SHELL__,$(POSIX_SHELL),g" \
		-e "s,__TASK_MODULE_DIR__,$(pkgdatadir),g" \
		-e "s,__TASK_TESTS_DIR__,$(pkgtestsdir),g" \
		-e "s,__TASK_VERSION__,$(PACKAGE_VERSION),g" \
		< "$$source" > "$$target.tmp" && \
	$(MV) -f "$$target.tmp" "$$target"

BUILD_SCRIPT = $(BUILD_FILE) && $(CHMOD) +x "$$target"

EOF
	local file
	for file in *.subr; do
		gen_append_var dist_pkgdata_DATA "$file"
	done
	local source target dir
	for source in *.subr.in; do
		echo
		target=${source%.in}
		dir=${source%/*}
		case $dir in "$source") dir= ;; *) dir="/$dir" ;; esac
		gen_append_var pkgdata_DATA "$target"
		gen_append_var CLEANFILES "$target"
		gen_append_var EXTRA_DIST "$source"
		${CAT} << EOF
$target: $source
	-\$(MKDIR_P) \$(builddir)$dir
	\$(AM_V_GEN)target="\$(builddir)/$target" source="\$(srcdir)/$source"; \\
	\$(BUILD_FILE)
EOF
	done
}

gen_test_scripts()
{
	: ${CAT:=cat}

	${CAT} << 'EOF'
# Build a test script.
BUILD_TEST = \
	TASK_MODULE_DIR="$(top_srcdir)" TASK_TESTS_DIR="$(top_srcdir)/t" \
	$(builddir)/t/build_test -o "$$target" "$$source"
EOF
	gen_append_var dist_pkgtests_DATA t/Kyuafile
	echo
	local source="t/build_test.sh"
	local target="${source%.sh}"
	local dir="${source%/*}"
	case $dir in "$source") dir= ;; *) dir="/$dir" ;; esac
	gen_append_var noinst_SCRIPTS "$target"
	gen_append_var CLEANFILES "$target"
	gen_append_var EXTRA_DIST "$source"
	${CAT} << EOF
$target: $source
	-\$(MKDIR_P) \$(builddir)$dir
	\$(AM_V_GEN)target="\$(builddir)/$target" source="\$(srcdir)/$source"; \\
	\$(BUILD_SCRIPT)
EOF
	echo
	source="t/run_tests.sh"
	target="${source%.sh}"
	dir=${source%/*}
	case $dir in "$source") dir= ;; *) dir="/$dir" ;; esac
	gen_append_var pkgtests_SCRIPTS "$target"
	gen_append_var CLEANFILES "$target"
	gen_append_var EXTRA_DIST "$source"
	${CAT} << EOF
$target: $source
	-\$(MKDIR_P) \$(builddir)$dir
	\$(AM_V_GEN)target="\$(builddir)/$target" source="\$(srcdir)/$source"; \\
	\$(BUILD_SCRIPT)
EOF
}

gen_tests()
{
	: ${CAT:=cat}

	local first="yes"
	local source target dir depend
	for source in t/t_*.sh; do
		[ -n "$first" ] || echo		# blank line
		first=
		target=${source%.sh}
		dir=${source%/*}
		case $dir in "$source") dir= ;; *) dir="/$dir" ;; esac
		gen_append_var pkgtests_SCRIPTS "$target"
		gen_append_var CLEANFILES "$target"
		gen_append_var EXTRA_DIST "$source"
		depend="$source"
		case $source in
		*/t_version*)
			# version.subr has its own target
			depend="$depend version.subr" ;;
		esac
		depend="$depend \$(builddir)/t/build_test"
		${CAT} << EOF
$target: $depend
	-\$(MKDIR_P) \$(builddir)$dir
	\$(AM_V_GEN)target="\$(builddir)/$target" source="\$(srcdir)/$source"; \\
	\$(BUILD_TEST)
EOF
	done
}

gen_check()
{
	: ${CAT:=cat}

	${CAT} << 'EOF'
PHONY_TARGETS += check-run-tets
check-run-tests:
	@cd $(srcdir)/t && $(SHELL) run_tests.sh

PHONY_TARGETS += installcheck-run-tests
installcheck-run-tests:
	@cd $(pkgtestsdir) && ./run_tests

if HAVE_KYUA
# CHECK_ENVIRONMENT
#	This is used to set variables before calling kyua on the tests in
#	the build directory.
#
# TESTS_ENVIRONMENT
#	This is used to set variables before calling kyua, regardless of
#	whether the tests are installed or in the build directory.

CHECK_ENVIRONMENT = \
	TASK_MODULE_DIR=$(abs_top_srcdir) \
	TASK_TESTS_DIR=$(abs_top_srcdir)/t

PHONY_TARGETS += check-kyua
check-local: check-kyua
check-kyua:
	@failed=no; \
	$(CHECK_ENVIRONMENT) $(TESTS_ENVIRONMENT) $(KYUA) test \
		--kyuafile='$(top_srcdir)/t/Kyuafile' \
		--build-root='$(top_builddir)/t' || failed=yes; \
	if [ "$$failed" = yes ]; then \
		$(CHECK_ENVIRONMENT) $(TESTS_ENVIRONMENT) $(KYUA) report \
			--results-file='$(abs_top_srcdir)' \
			--verbose --results-filter=broken,failed; \
		exit 1; \
	fi

PHONY_TARGETS += installcheck-kyua
installcheck-local: installcheck-kyua
installcheck-kyua:
	@failed=no; \
	cd $(pkgtestsdir) && $(TESTS_ENVIRONMENT) $(KYUA) test  || failed=yes; \
	if [ "$$failed" = yes ]; then \
		cd $(pkgtestsdir) && $(TESTS_ENVIRONMENT) $(KYUA) report \
			--verbose --results-filter=broken,failed; \
		exit 1; \
	fi
else  # HAVE_KYUA
check-local: check-run-tests
installcheck-local: installcheck-run-tests
endif # HAVE_KYUA
EOF
}

gen_clean()
{
	: ${CAT:=cat}

	${CAT} << 'EOF'
maintainer-clean-local:
	-rm -f Makefile.in aclocal.m4 configure
	-rm -f build-aux/install-sh build-aux/missing
	-rm -f $(PACKAGE)-*.tar.*
EOF
}

generate()
{
	gen_license
	echo
	gen_doc
	echo
	gen_build
	echo
	gen_test_scripts
	echo
	gen_tests
	echo
	gen_check
	echo
	gen_clean
}

invoke_autoreconf=
OPTIND=1
while getopts ":a" arg "$@"; do
	case $arg in
	a)	invoke_autoreconf="yes" ;;
	*)	return 127 ;;
	esac
done
shift $(( ${OPTIND} - 1 ))

generate "$@" > "Makefile.am.tmp" &&
mv -f "Makefile.am.tmp" "Makefile.am"
if [ -n "$invoke_autoreconf" -a -f "configure.ac" ]; then
	# Invoke with "-i" so that missing scripts are copied into ./admin.
	autoreconf -i
fi
