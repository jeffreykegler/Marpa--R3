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

.PHONY: all all_tests critic display tidy misc

all: all_tests

critic.list: ../MANIFEST create_critic_list.pl
	perl ./create_critic_list.pl > critic.list

all_tests: critic.list
	-(cd ..; prove author.t/*.t ) 2>&1 | tee all.errs

misc:
	-(cd ..; prove author.t/ampersand.t)
	-(cd ..; prove author.t/meta_yaml.t)

tidy: critic.list
	-(cd ..; prove author.t/tidy.t) 2>&1 | tee tidy.errs

critic: critic.list
	-(cd ..; prove author.t/critic.t) 2>&1 | tee critic.errs

display:
	-(cd ..; prove author.t/display.t) 2>&1 | tee display.errs

pod:
	-(cd ..; prove author.t/pod.t)
