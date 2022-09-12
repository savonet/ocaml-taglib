(lang dune 2.8)
(version 0.3.10)
(name taglib)
(source (github savonet/ocaml-taglib))
(license "LGPL-2.1-only WITH OCaml-LGPL-linking-exception")
(authors "The Savonet Team <savonet-users@lists.sourceforge.net>")
(maintainers "The Savonet Team <savonet-users@lists.sourceforge.net>")

(generate_opam_files true)
(use_standard_c_and_cxx_flags false)

(package
 (name taglib)
 (synopsis "Bindings for the taglib library")
 (description "Bindings for the taglib library which provides functions for reading tags in headers of audio files")
 (depends
  dune
  (ocaml (>= 4.07))
  conf-taglib
  dune-configurator)
)
