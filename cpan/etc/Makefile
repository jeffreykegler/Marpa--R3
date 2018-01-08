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

build:
	(cd ..;perl Build.PL)
	(cd ..;./Build realclean)
	(cd ..;perl Build.PL)
	(cd ..;./Build)
	(cd ..;./Build distmeta)
	(cd ..;./Build test)
	(cd ..;./Build disttest)

update:
	(cd ..;perl Build.PL)
	(cd ..;./Build)
	(cd ..;./Build distmeta)
	(cd ..;./Build dist)
	(cd ..;perl Build.PL)

devlib:
	(cd ..;perl Build.PL)
	(cd ..;./Build install --install_base $$HOME/devlib)
