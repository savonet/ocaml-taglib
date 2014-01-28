AC_INIT([ocaml-taglib],[0.3.1],[savonet-users@lists.sourceforge.net])

VERSION=$PACKAGE_VERSION
AC_MSG_RESULT([configuring $PACKAGE_STRING])

AC_BASE_CHECKS()

AC_PROG_CXX()
AC_CONFIG_HEADERS([config.h])
CPPFLAGS="$CPPFLAGS -I .."

PKG_PROG_PKG_CONFIG()
PKG_CONFIG_CHECK_MODULE([taglib],[1.6])

# Need to add -lstdc++
LIBS="$LIBS stdc++"

case "$host" in
   *-mingw*) LIBS="$LIBS pthread gcc_s";
esac

# Now testing for recent classes:
AC_CPP_CHECK_CLASS([tag],[tpropertymap.h],[TagLib::PropertyMap],[HAVE_PROPERTIES])
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
