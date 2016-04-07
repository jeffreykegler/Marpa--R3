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

.PHONY: dummy basic_test rebuild single_test full_test install releng \
  cpan_dir_full_test perl_ac_disttest gnu_ac_disttest

dummy: 

releng: 
	@echo === releng target ===
	@echo === releng: make full_test ===
	$(MAKE) full_test 2>&1 | tee full_test.out
	@echo === releng: make distcheck ===
	cd cpan && $(MAKE) distcheck
	@echo === releng: make dist ===
	cd cpan && $(MAKE) dist
	@echo === releng: git status ===
	git status

basic_test:
	(cd cpan && $(MAKE) test) 2>&1 | tee basic_test.out

rebuild:
	(cd cpan; \
	    $(MAKE); \
	    $(MAKE) test; \
	) 2>&1 | tee rebuild.out

single_test:
	(cd cpan; \
	    $(MAKE); \
	    $(MAKE) test TEST_FILES='$(TEST)'; \
	) 2>&1 | tee single_test.out

full_test: cpan_dir_full_test perl_ac_disttest gnu_ac_disttest

cpan_dir_full_test:
	@echo === cpan_dir_full_test target ===
	@echo === cpan_dir_full_test: make realclean ===
	cd cpan && $(MAKE) realclean
	@echo === cpan_dir_full_test: perl Makefile.PL ===
	cd cpan && perl Makefile.PL
	@echo === cpan_dir_full_test: make ===
	cd cpan && $(MAKE)
	@echo === cpan_dir_full_test: make test ===
	cd cpan && $(MAKE) test

perl_ac_disttest:
	@echo === perl_ac_disttest target ===
	cd cpan && MARPA_USE_PERL_AUTOCONF=1 $(MAKE) disttest

gnu_ac_disttest:
	@echo === gnu_ac_disttest target ===
	cd cpan && $(MAKE) disttest

install:
	@echo === install target ===
	(cd cpan/meta && $(MAKE) all)
	(cd cpan/xs && $(MAKE) -f meta_make)
	(cd cpan && perl Makefile.PL)
	(cd cpan && $(MAKE))

