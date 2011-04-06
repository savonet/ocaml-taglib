
# check for one particular file of the sources 
AC_INIT(ocaml-taglib, 0.1.4, savonet-users@lists.sourceforge.net)

VERSION=$PACKAGE_VERSION
AC_MSG_RESULT([configuring $PACKAGE_STRING])

# Add prefix to compilation variables
# if passed
if test "x$prefix" != "xNONE"; then
        CFLAGS="$CFLAGS -I$prefix/include"
        LDFLAGS="$LDFLAGS -L$prefix/lib"
        CPPFLAGS="$CPPFLAGS -I$prefix/include"
fi

AC_CHECK_OCAML_COMPILERS()

AC_PROG_CC()
AC_PROG_CXX()
AC_CHECK_TOOL([AR],[ar],no)
PKG_PROG_PKG_CONFIG()
#PKG_CHECK_MODULES(taglib, taglib_c, , [AC_MSG_ERROR(taglib not found.)])

# PKG_CHECK_MODULES loses when you need --libs-only-[lL]
if ! $PKG_CONFIG --exists taglib_c; then
        AC_MSG_ERROR([taglib not found])
fi
taglib_CFLAGS=`$PKG_CONFIG --cflags taglib_c`
AC_SUBST([taglib_CFLAGS])
taglib_LIBS=`$PKG_CONFIG --libs-only-l taglib_c`
AC_SUBST([taglib_LIBS])
taglib_LDFLAGS=`$PKG_CONFIG --libs-only-L taglib_c`
AC_SUBST([taglib_LDFLAGS])

CPPFLAGS="$CPPFLAGS -fPIC"

# substitutions to perform
AC_SUBST(VERSION)
AC_SUBST(INC)
AC_SUBST(requires)

# Finally create the Makefile and samples
AC_CONFIG_FILES([Makefile],[chmod a-w Makefile])
AC_CONFIG_FILES([src/META])
AC_CONFIG_FILES([src/Makefile])
AC_OUTPUT
