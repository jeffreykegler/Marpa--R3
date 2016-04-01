# Copyright 2016 Jeffrey Kegler
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
