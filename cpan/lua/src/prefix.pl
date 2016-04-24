#!perl

use 5.10.1;
use strict;
use warnings;
use English qw( -no_match_vars );

my @targets = qw(
luaI_openlib
luaL_addlstring
luaL_addstring
luaL_addvalue
luaL_argerror
luaL_buffinit
luaL_callmeta
luaL_checkany
luaL_checkinteger
luaL_checklstring
luaL_checknumber
luaL_checkoption
luaL_checkstack
luaL_checktype
luaL_checkudata
luaL_error
luaL_findtable
luaL_getmetafield
luaL_getn
luaL_gsub
luaL_loadbuffer
luaL_loadfile
luaL_loadstring
luaL_newmetatable
luaL_newstate
luaL_openlib
luaL_openlibs
luaL_optinteger
luaL_optlstring
luaL_optnumber
luaL_prepbuffer
luaL_pushresult
luaL_ref
luaL_register
luaL_setn
luaL_typerror
luaL_unref
luaL_where
luaO_nilobject_
luaP_opmodes
luaP_opnames
luaT_typenames
luaX_tokens
lua_atpanic
lua_call
lua_checkstack
lua_close
lua_concat
lua_cpcall
lua_createtable
lua_dump
lua_equal
lua_error
lua_gc
lua_getallocf
lua_getfenv
lua_getfield
lua_gethook
lua_gethookcount
lua_gethookmask
lua_getinfo
lua_getlocal
lua_getmetatable
lua_getstack
lua_gettable
lua_gettop
lua_getupvalue
lua_ident
lua_insert
lua_iscfunction
lua_isnumber
lua_isstring
lua_isuserdata
lua_lessthan
lua_load
lua_newstate
lua_newthread
lua_newuserdata
lua_next
lua_objlen
lua_pcall
lua_pushboolean
lua_pushcclosure
lua_pushfstring
lua_pushinteger
lua_pushlightuserdata
lua_pushlstring
lua_pushnil
lua_pushnumber
lua_pushstring
lua_pushthread
lua_pushvalue
lua_pushvfstring
lua_rawequal
lua_rawget
lua_rawgeti
lua_rawset
lua_rawseti
lua_remove
lua_replace
lua_resume
lua_setallocf
lua_setfenv
lua_setfield
lua_sethook
lua_setlevel
lua_setlocal
lua_setmetatable
lua_settable
lua_settop
lua_setupvalue
lua_status
lua_toboolean
lua_tocfunction
lua_tointeger
lua_tolstring
lua_tonumber
lua_topointer
lua_tothread
lua_touserdata
lua_type
lua_typename
lua_xmove
lua_yield
luaopen_base
luaopen_debug
luaopen_io
luaopen_math
luaopen_os
luaopen_package
luaopen_string
luaopen_table
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
