set -x
make clean
perl Makefile.PL OPTIMIZE=-g
make
