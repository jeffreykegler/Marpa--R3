

.PHONY: all test test_suite undoc_tests

all: test

test: test_suite undoc_tests

test_suite:
	prove -I. -I../../cpan/lib/ -I../../cpan/blib/arch idlit_ex2.t

undoc_tests:
	perl -I. -I../../cpan/lib/ -I../../cpan/blib/arch idlit_ex.pl

