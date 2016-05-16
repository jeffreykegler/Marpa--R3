#!perl
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

use 5.10.1;
use strict;
use warnings;
use English qw( -no_match_vars );

my @targets = qw(
lua_ident
lua_newstate
lua_checkstack
lua_xmove
lua_atpanic
lua_version
lua_absindex
lua_gettop
lua_settop
lua_rotate
lua_copy
lua_pushvalue
lua_type
lua_typename
lua_iscfunction
lua_isinteger
lua_isnumber
lua_isstring
lua_isuserdata
lua_rawequal
lua_arith
lua_compare
lua_stringtonumber
lua_tonumberx
lua_tointegerx
lua_toboolean
lua_tolstring
lua_rawlen
lua_tocfunction
lua_touserdata
lua_tothread
lua_topointer
lua_pushnil
lua_pushnumber
lua_pushinteger
lua_pushlstring
lua_pushstring
lua_pushvfstring
lua_pushfstring
lua_pushcclosure
lua_pushboolean
lua_pushlightuserdata
lua_pushthread
lua_getglobal
lua_gettable
lua_getfield
lua_geti
lua_rawget
lua_rawgeti
lua_rawgetp
lua_createtable
lua_getmetatable
lua_getuservalue
lua_setglobal
lua_settable
lua_setfield
lua_seti
lua_rawset
lua_rawseti
lua_rawsetp
lua_setmetatable
lua_setuservalue
lua_callk
lua_pcallk
lua_load
lua_dump
lua_status
lua_gc
lua_error
lua_next
lua_concat
lua_len
lua_getallocf
lua_setallocf
lua_newuserdata
lua_getupvalue
lua_setupvalue
lua_upvalueid
lua_upvaluejoin
lua_sethook
lua_gethook
lua_gethookmask
lua_gethookcount
lua_getstack
lua_getlocal
lua_setlocal
lua_getinfo
lua_resume
lua_isyieldable
lua_yieldk
lua_newthread
lua_close
luaL_where
luaL_error
luaL_argerror
luaL_fileresult
luaL_execresult
luaL_newmetatable
luaL_setmetatable
luaL_testudata
luaL_checkstack
luaL_traceback
luaL_checkany
luaL_prepbuffsize
luaL_addlstring
luaL_addstring
luaL_pushresult
luaL_pushresultsize
luaL_addvalue
luaL_buffinit
luaL_buffinitsize
luaL_ref
luaL_unref
luaL_loadfilex
luaL_loadbufferx
luaL_loadstring
luaL_getmetafield
luaL_checkudata
luaL_checktype
luaL_checklstring
luaL_optlstring
luaL_checkoption
luaL_checknumber
luaL_optnumber
luaL_checkinteger
luaL_optinteger
luaL_callmeta
luaL_len
luaL_tolstring
luaL_setfuncs
luaopen_base
luaL_getsubtable
luaL_requiref
luaL_gsub
luaL_newstate
luaL_checkversion_
luaopen_coroutine
luaopen_debug
luaopen_io
luaopen_math
luaopen_package
luaopen_os
luaopen_string
luaopen_table
luaopen_utf8
luaopen_bit32
luaL_openlibs
);

$RS = undef;
FILE: for my $file (<*.[ch]>)
{
  say STDERR "=== $file ===";
  open my $fh, q{<}, $file or die "$file: $ERRNO";
  my $filetext = <$fh>;
  close $fh or die "$file: $ERRNO";
  for my $match (@targets) {
      $filetext =~ s/\b$match\b/marpa_$match/xmsg;
  }
  open $fh, q{>}, $file or die "$file: $ERRNO";
  print {$fh} $filetext;
  close $fh or die "$file: $ERRNO";
}
