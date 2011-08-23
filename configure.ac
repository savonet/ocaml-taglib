
# check for one particular file of the sources 
AC_INIT(ocaml-taglib, 0.2.0, savonet-users@lists.sourceforge.net)

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

AC_PROG_CXX()
AC_CONFIG_HEADERS([config.h])
CPPFLAGS="$CPPFLAGS -I .."
AC_CHECK_TOOL([AR],[ar],no)
AC_SUBST(AR)
PKG_PROG_PKG_CONFIG()
#PKG_CHECK_MODULES(taglib, taglib_c, , [AC_MSG_ERROR(taglib not found.)])

# PKG_CHECK_MODULES loses when you need --libs-only-[lL]
if ! $PKG_CONFIG --exists taglib; then
        AC_MSG_ERROR([taglib not found])
fi
CPPFLAGS="$CPPFLAGS `$PKG_CONFIG --cflags taglib` -fPIC"
LIBS="`$LIBS $PKG_CONFIG --libs-only-l taglib` -lstdc++"
LDFLAGS=`$LDFLAGS $PKG_CONFIG --libs-only-L taglib`

# Now testing for recent classes:
AC_CPP_CHECK_CLASS([tag],[wavpackfile.h],[TagLib::WavPack::File],[HAVE_WAVPACK])
AC_CPP_CHECK_CLASS([tag],[speexfile.h],[TagLib::Ogg::Speex::File],[HAVE_SPEEX])
AC_CPP_CHECK_CLASS([tag],[mp4file.h],[TagLib::MP4::File],[HAVE_MP4])
AC_CPP_CHECK_CLASS([tag],[asffile.h],[TagLib::ASF::File],[HAVE_ASF])
AC_CPP_CHECK_CLASS([tag],[trueaudiofile.h],[TagLib::TrueAudio::File],[HAVE_TRUEAUDIO])

# substitutions to perform
AC_SUBST(VERSION)
AC_SUBST(INC)
AC_SUBST(requires)
AC_SUBST([CFLAGS])
AC_SUBST([LIBS])
AC_SUBST([LDFLAGS])

# Finally create the Makefile and samples
AC_CONFIG_FILES([Makefile],[chmod a-w Makefile])
AC_CONFIG_FILES([src/META])
AC_CONFIG_FILES([src/Makefile])
AC_OUTPUT
