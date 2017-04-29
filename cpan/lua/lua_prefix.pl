#!perl
# Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

use 5.10.1;
use strict;
use warnings;
use English qw( -no_match_vars );

my @targets = qw(
lua_absindex
lua_arith
lua_atpanic
lua_call
lua_callk
lua_checkstack
lua_close
lua_compare
lua_concat
lua_copy
lua_cpcall
lua_createtable
lua_dump
lua_equal
lua_error
lua_gc
lua_getallocf
lua_getextraspace
lua_getfield
lua_getglobal
lua_gethook
lua_gethookcount
lua_gethookmask
lua_geti
lua_getinfo
lua_getlocal
lua_getlocaledecpoint
lua_getmetatable
lua_getstack
lua_gettable
lua_gettop
lua_getupvalue
lua_getuservalue
lua_ident
lua_insert
lua_integer2str
lua_isboolean
lua_iscfunction
lua_isfunction
lua_isinteger
lua_islightuserdata
lua_isnil
lua_isnone
lua_isnoneornil
lua_isnumber
lua_isstring
lua_istable
lua_isthread
lua_isuserdata
lua_isyieldable
luaL_addchar
luaL_addlstring
luaL_addsize
luaL_addstring
luaL_addvalue
luaL_argcheck
luaL_argerror
luaL_buffinit
luaL_buffinitsize
luaL_callmeta
luaL_checkany
luaL_checkint
luaL_checkinteger
luaL_checklong
luaL_checklstring
luaL_checknumber
luaL_checkoption
luaL_checkstack
luaL_checkstring
luaL_checktype
luaL_checkudata
luaL_checkunsigned
luaL_checkversion
luaL_checkversion_
luaL_dofile
luaL_dostring
lua_len
luaL_error
lua_lessthan
luaL_execresult
luaL_fileresult
luaL_getmetafield
luaL_getmetatable
luaL_getsubtable
luaL_gsub
luaL_len
luaL_loadbuffer
luaL_loadbufferx
luaL_loadfile
luaL_loadfilex
luaL_loadstring
luaL_newlib
luaL_newlibtable
luaL_newmetatable
luaL_newstate
lua_load
luaL_openlibs
luaL_opt
luaL_optint
luaL_optinteger
luaL_optlong
luaL_optlstring
luaL_optnumber
luaL_optstring
luaL_optunsigned
luaL_prepbuffer
luaL_prepbuffsize
luaL_pushresult
luaL_pushresultsize
luaL_ref
luaL_register
luaL_requiref
luaL_setfuncs
luaL_setmetatable
luaL_testudata
luaL_tolstring
luaL_traceback
luaL_typename
luaL_unref
luaL_where
lua_newstate
lua_newtable
lua_newthread
lua_newuserdata
lua_next
lua_number2str
lua_number2strx
lua_numbertointeger
lua_objlen
luaopen_base
luaopen_bit32
luaopen_coroutine
luaopen_debug
luaopen_io
luaopen_math
luaopen_os
luaopen_package
luaopen_string
luaopen_table
luaopen_utf8
lua_pcall
lua_pcallk
lua_pop
lua_pushboolean
lua_pushcclosure
lua_pushcfunction
lua_pushfstring
lua_pushglobaltable
lua_pushinteger
lua_pushlightuserdata
lua_pushliteral
lua_pushlstring
lua_pushnil
lua_pushnumber
lua_pushstring
lua_pushthread
lua_pushunsigned
lua_pushvalue
lua_pushvfstring
lua_rawequal
lua_rawget
lua_rawgeti
lua_rawgetp
lua_rawlen
lua_rawset
lua_rawseti
lua_rawsetp
lua_register
lua_remove
lua_replace
lua_resume
lua_rotate
lua_setallocf
lua_setfield
lua_setglobal
lua_sethook
lua_seti
lua_setlocal
lua_setmetatable
lua_settable
lua_settop
lua_setupvalue
lua_setuservalue
lua_status
lua_str2number
lua_stringtonumber
lua_strlen
lua_strx2number
lua_toboolean
lua_tocfunction
lua_tointeger
lua_tointegerx
lua_tolstring
lua_tonumber
lua_tonumberx
lua_topointer
lua_tostring
lua_tothread
lua_tounsigned
lua_tounsignedx
lua_touserdata
lua_type
lua_typename
lua_upvalueid
lua_upvalueindex
lua_upvaluejoin
lua_version
lua_writeline
lua_writestring
lua_writestringerror
lua_xmove
lua_yield
lua_yieldk
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
