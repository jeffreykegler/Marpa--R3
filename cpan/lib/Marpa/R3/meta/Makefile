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

dummy:
	@echo 'The main target is "metag"'

metag:
	-test -r metag-g3.pl && mv metag-g3.pl metag-g4.pl
	-test -r metag-g2.pl && mv metag-g2.pl metag-g3.pl
	-test -r metag-g1.pl && mv metag-g1.pl metag-g2.pl
	-mv metag.pl metag-g1.pl
	perl sl_to_hash.pl < metag.bnf > metag.pl

bak:
	for f in metag*.pl; do cp $$f $$f.bak; done

diff:
	diff metag.pl metag-g1.pl || true

