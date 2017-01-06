<!--
Copyright 2016 Jeffrey Kegler
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
-->

# The Perl-to-Kollos glue code

# Table of contents
<!--
../lua/lua ../kollos/toc.lua < glue.lua.md
-->
* [About the glue code](#about-the-glue-code)
* [The by-tag code cache](#the-by-tag-code-cache)
* [The main Lua code file](#the-main-lua-code-file)
  * [Preliminaries to the main code](#preliminaries-to-the-main-code)

## About the glue code

This is the code for the glue
code between Perl and Kollos.
Kollos is the "middle layer" of Marpa.

This document is evolving.
In particular, the boundard between Kollos and its glue
code has not solidified yet.

Also undetermined is how to deal with Lua name space.
Can I assume this "glue" code is in charge of the global
namespace, or should it be organized as a package?
For now, I am just dumping everything into the global namespace.

## The by-tag code cache

Caches functions by "tag".
This is done to avoid the overhead of repeatedly compiling
the Lua code.
Eventually all such code should be named and
moved into Kollos,
or into these "glue" routines.
But that may take a while, and in the meantime
we may want meaningful performance numbers.

```
    -- miranda: section+ Lua declarations
    pkglue.code_by_tag = {}

```

## The main Lua code file

```
    -- miranda: section main
    -- miranda: insert legal preliminaries
    -- miranda: insert luacheck declarations
    -- miranda: insert enforce strict globals

    -- pkglue, that is, Perl-to-Kollos Glue
    local pkglue = {}

    -- miranda: insert Lua declarations
    -- comment out miranda: insert most Lua function declarations

    return pkglue

    -- vim: set expandtab shiftwidth=4:
```

### Preliminaries to the main code

Licensing, etc.

```

    -- miranda: section legal preliminaries

    -- Copyright 2016 Jeffrey Kegler
    -- Permission is hereby granted, free of charge, to any person obtaining a
    -- copy of this software and associated documentation files (the "Software"),
    -- to deal in the Software without restriction, including without limitation
    -- the rights to use, copy, modify, merge, publish, distribute, sublicense,
    -- and/or sell copies of the Software, and to permit persons to whom the
    -- Software is furnished to do so, subject to the following conditions:
    --
    -- The above copyright notice and this permission notice shall be included
    -- in all copies or substantial portions of the Software.
    --
    -- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    -- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    -- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    -- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    -- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    -- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    -- OTHER DEALINGS IN THE SOFTWARE.
    --
    -- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
```

Luacheck declarations

```

    -- miranda: section luacheck declarations

    -- luacheck: std lua53
    -- luacheck: globals bit
    -- luacheck: globals __FILE__ __LINE__

```

Set "strict" globals, using code taken from strict.lua.

```

    -- miranda: section enforce strict globals
    do
        local mt = getmetatable(_G)
        if mt == nil then
          mt = {}
          setmetatable(_G, mt)
        end

        mt.__declared = {}

        local function what ()
          local d = debug.getinfo(3, "S")
          return d and d.what or "C"
        end

        mt.__newindex = function (t, n, v)
          if not mt.__declared[n] then
            local w = what()
            if w ~= "main" and w ~= "C" then
              error("assign to undeclared variable '"..n.."'", 2)
            end
            mt.__declared[n] = true
          end
          rawset(t, n, v)
        end

        mt.__index = function (t, n)
          if not mt.__declared[n] and what() ~= "C" then
            error("variable '"..n.."' is not declared", 2)
          end
          return rawget(t, n)
        end
    end

```

<!--
vim: expandtab shiftwidth=4:
-->
