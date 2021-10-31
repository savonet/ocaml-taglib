(lang dune 2.7)
(version 0.3.7)
(name taglib)
(source (github savonet/ocaml-taglib))
(license "LGPL-2.1-only WITH OCaml-LGPL-linking-exception")
(authors "The Savonet Team <savonet-users@lists.sourceforge.net>")
(maintainers "The Savonet Team <savonet-users@lists.sourceforge.net>")

(generate_opam_files true)

(package
 (name taglib)
 (synopsis "Bindings for the taglib library")
 (description "Bindings for the taglib library which provides functions for reading tags in headers of audio files")
 (depends
  dune
  conf-taglib
  dune-configurator)
)
