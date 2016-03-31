# Copyright 2014 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

.PHONY: dummy basic_test rebuild single_test full_test etc_make install cpan_dist_files releng

dummy: 

releng: install full_test
	cd cpan && make distcheck
	cd cpan && make dist
	git status

basic_test:
	(cd cpan && make test) 2>&1 | tee basic_test.out

rebuild: etc_make
	(cd cpan; \
	    make; \
	    make test; \
	) 2>&1 | tee rebuild.out

single_test: etc_make
	(cd cpan; \
	    make; \
	    make test --test_files $(TEST); \
	) 2>&1 | tee single_test.out

full_test: etc_make
	(cd cpan; \
	    make realclean; \
	    perl Makefile.PL; \
	    make; \
	    make test; \
	    make disttest; \
	    MARPA_USE_PERL_AUTOCONF=1 make disttest; \
	) 2>&1 | tee full_test.out

install:
	(cd cpan/meta && make all)
	(cd cpan/xs && make -f meta_make)
	(cd cpan && perl Makefile.PL)
	(cd cpan && make)

