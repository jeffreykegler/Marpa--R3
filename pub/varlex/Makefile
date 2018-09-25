

.PHONY: all test test_suite undoc_tests

all: test

test: test_suite undoc_tests

test_suite:
	@echo NYI
	# prove -I. long.t short.t semis.t note1.t short13.t idlit.t

undoc_tests:
	@echo NYI
	perl -I. -I../../cpan/lib/ -I../../cpan/blib/arch idlit_ex.pl >idlit_ex.pl.out 2>&1
	# diff idliidlitl.out idlit_trace.out || echo 'Trace example FAILED'

