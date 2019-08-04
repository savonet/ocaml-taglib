AC_INIT([ocaml-taglib],[0.3.5],[savonet-users@lists.sourceforge.net])

VERSION=$PACKAGE_VERSION
AC_MSG_RESULT([configuring $PACKAGE_STRING])

AC_BASE_CHECKS()

min_ocaml_version=4.02.0

OCAML_VERSION="`$OCAMLC -version`"
OCAML_MAJOR="`echo $OCAML_VERSION | cut -d'.' -f 1`"
AC_SUBST(OCAML_MAJOR)
OCAML_MINOR="`echo $OCAML_VERSION | cut -d'.' -f 2`"
AC_SUBST(OCAML_MINOR)
OCAML_REVISION="`echo $OCAML_VERSION | cut -d'.' -f 3`"
AC_SUBST(OCAML_REVISION)
AC_MSG_CHECKING([for ocamlc version])
AC_MSG_RESULT([$OCAML_MAJOR.$OCAML_MINOR.$OCAML_REVISION])

AS_VERSION_COMPARE([$OCAML_MAJOR.$OCAML_MINOR.$OCAML_REVISION],[$min_ocaml_version],
  [VERSION_OK=],
  [VERSION_OK=yes],
  [VERSION_OK=yes]
)
if test -z "${VERSION_OK}"; then
  AC_MSG_ERROR([version $min_ocaml_version or greater of the OCaml compiler is required to build liquidsoap])
fi

AC_PROG_CXX()
AC_CONFIG_HEADERS([config.h])
CPPFLAGS="$CPPFLAGS -I .."

PKG_PROG_PKG_CONFIG()
PKG_CONFIG_CHECK_MODULE([taglib],[1.6])

# Now testing for recent classes:
AC_CPP_CHECK_CLASS([tag],[tpropertymap.h],[TagLib::PropertyMap],[HAVE_PROPERTIES])
AC_CPP_CHECK_CLASS([tag],[wavpackfile.h],[TagLib::WavPack::File],[HAVE_WAVPACK])
AC_CPP_CHECK_CLASS([tag],[speexfile.h],[TagLib::Ogg::Speex::File],[HAVE_SPEEX])
AC_CPP_CHECK_CLASS([tag],[mp4file.h],[TagLib::MP4::File],[HAVE_MP4])
AC_CPP_CHECK_CLASS([tag],[asffile.h],[TagLib::ASF::File],[HAVE_ASF])
AC_CPP_CHECK_CLASS([tag],[trueaudiofile.h],[TagLib::TrueAudio::File],[HAVE_TRUEAUDIO])

if [[ "${TARGET_TOOLCHAIN}" = "mingw" ]]; then
  LIBS="$LIBS pthread z";
fi

# Need to add -lstdc++
LIBS="$LIBS stdc++"

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
