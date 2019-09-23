# Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided “as is” and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

.PHONY: dummy basic_test rebuild single_test full_test install releng \
  cpan_dir_full_test perl_ac_disttest gnu_ac_disttest

dummy: 

releng: 
	@echo === releng target ===
	@echo === releng: make install ===
	$(MAKE) install
	@echo === releng: make full_test ===
	$(MAKE) full_test 2>&1 | tee full_test.out
	@echo === releng: make distcheck ===
	cd cpan && $(MAKE) distcheck
	@echo === releng: make dist ===
	cd cpan && $(MAKE) dist
	@echo === releng: make disttest ===
	cd cpan && $(MAKE) disttest
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
	date > cpan/engine/read_only.time-stamp
	(cd cpan/meta && $(MAKE) all)
	(cd cpan && perl Makefile.PL)
	(cd cpan && $(MAKE))

