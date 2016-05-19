/*
 * Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
 *
 * This module is free software; you can redistribute it and/or modify it
 * under the same terms as Perl 5.10.1. For more details, see the full text
 * of the licenses in the directory LICENSES.
 *
 * This program is distributed in the hope that it will be
 * useful, but it is provided “as is” and without any express
 * or implied warranties. For details, see the full text of
 * of the licenses in the directory LICENSES.
 */

#include "config.h"
#include "marpa_xs.h"

#define PERL_NO_GET_CONTEXT
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "ppport.h"

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static lua_State *marpa_L = NULL;

MODULE = Marpa::R3::Lua        PACKAGE = Marpa::R3::Lua

PROTOTYPES: DISABLE

void
exec( ... )
PPCODE:
{
  const char* hi = "salve, munde";
  XPUSHs (sv_2mortal (newSVpv (hi, 0)));
}

BOOT:

    /* Perl threads now discouraged, so we no longer worry about
     * safety
     */
     marpa_L = marpa_luaL_newstate();
     if (!marpa_L) {
      croak ("Marpa::R3 internal error: Lua interpreter failed to start");
       }
    marpa_luaL_openlibs(marpa_L);  /* open libraries */

    /* vim: set expandtab shiftwidth=2: */
