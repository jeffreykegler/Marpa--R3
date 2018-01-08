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

if test -f "$1"
then :
else
   echo $1 is not a file 1>&2
   exit 1
fi
if test -d engine/cf
then :
else
   (echo engine/cf is not a directory;
   echo Are you running this script in the cpan/ directory\?) 1>&2
   exit 1
fi
if test -r "libmarpa/LIB_VERSION"
then :
else
   (echo libmarpa/LIB_VERSION is not a readable file;
   echo Are you running this script in the cpan/ directory\?) 1>&2
   exit 1
fi
lib_version=`cat libmarpa/LIB_VERSION`
cat $1 | (cd engine; tar -xvzf -)
(cd engine; test -d read_only.bak && rm -rf read_only.bak)
(cd engine; test -d read_only && mv read_only read_only.bak)
(cd engine; mv libmarpa-$lib_version read_only)
date > engine/read_only.time-stamp
