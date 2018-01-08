# Copyright 2018 Jeffrey Kegler
# Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

.PHONY: dummy all

dummy:
	@echo '!!!' The main target is '"all"' '!!!'

all: ../lib/Marpa/R3/Internal.pm

../lib/Marpa/R3/Internal.pm: make_internal_pm.pl
	perl make_internal_pm.pl > $@

