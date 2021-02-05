dnl
AC_DEFUN(MUQ_GETRUSAGE,
[# SunOS 5.x keeps getrusage in /usr/ucblib/libucb.a:
LIBS_old="$LIBS"
# The following will only work for gcc under SunOS,
# I expect. (I don't have a manpage for cc under SunOS. 94Jun25Cynbe)
LIBS="$LIBS -L/usr/ucblib -Xlinker -R/usr/ucblib"
AC_CHECK_LIB(ucb, getrusage, LIBS="$LIBS -lucb",
	LIBS="$LIBS_old",-lc)
])dnl
dnl
dnl
dnl
dnl See bottom of Need.h for genealogy of following stuff.
dnl
dnl Wound up wanting a HEADER_CHECK below, and didn't
dnl want redundant AC_CHECKINGs in it, so cloned AC_HEADER_CHECK:
define(MUQ_HEADER_CHECK,
[ifelse([$3], , [AC_TRY_CPP([#include <$1>], [$2])],
[AC_TRY_CPP([#include <$1>], [$2], [$3])])
])dnl
dnl --------------------- BEGIN BORROWED SECTION -----------------------
dnl Process this file with autoconf to produce a configure script.
dnl Techne Research Limited macros
AC_REVISION($Revision: 1.3 $)dnl
dnl
dnl Macro to check if functions prototype is declared or not.
dnl Sets NEED_function_PROTO if it is needed.
dnl Replacement prototypes require inclusion of need.h
dnl
dnl Usage: TRL_PROTO_CHECK(cfsetispeed, termios.h sys/termios.h)
dnl Produces NEED_CFSETISPEED_PROTO if not located.
dnl
define(TRL_PROTO_CHECK,
[AC_PROVIDE([$0])dnl
AC_MSG_CHECKING(for $1 prototype)
dnl
ac_need=1
for h in [$2]; do
MUQ_HEADER_CHECK($h,
[dnl We use an expanded AC_HEADER_EGREP because its single quote stops expansion
echo "#include \"confdefs.h\"
#include <$h>" > conftest.c
eval "$ac_cpp conftest.c > conftest.out 2>&1"
changequote(,)dnl
if egrep "$1[^a-zA-Z0-9/.]" conftest.out >/dev/null 2>&1; then
changequote([,])dnl
  :
else
  rm -rf conftest*
  continue
fi
rm -f conftest*
cat > conftest.c <<EOF
#include <$h>
dnl This should be valid ;-)
extern char**** [$1](char****, int****);
main() { return 0; }
EOF
if eval $ac_compile >/dev/null 2>&1; then
  rm -f conftest*
else
  rm -f conftest*
  ac_need=0
  break
fi
])dnl
done
if test [$ac_need] = 1; then
  changequote(,)dnl
  name=NEED_`echo $1 | tr '[a-z]' '[A-Z]'`_PROTO
  changequote([,])dnl
  AC_DEFINE_UNQUOTED($name)
  AC_MSG_RESULT(ABSENT)
else
  AC_MSG_RESULT(present)
fi
])dnl
dnl --------------------- END BORROWED SECTION -----------------------
