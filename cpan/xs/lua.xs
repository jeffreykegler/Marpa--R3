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

MODULE = Marpa::R3        PACKAGE = Marpa::R3::Lua

void
exec( ... )
PPCODE:
{
  const char* hi = "salve, munde";
  XPUSHs (sv_2mortal (newSVpv (hi, 0)));
}
