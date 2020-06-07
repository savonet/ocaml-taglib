(lang dune 2.0)
(version 0.3.7)
(name taglib)
(source (github savonet/ocaml-taglib))
(license LGPL+link-exception)
(authors "The Savonet Team <savonet-users@lists.sourceforge.net>")
(maintainers "The Savonet Team <savonet-users@lists.sourceforge.net>")

(generate_opam_files true)

(package
 (name taglib)
 (synopsis "Bindings for the taglib library")
 (description "Bindings for the taglib library which provides functions for reading tags in headers of audio files")
 (depends
  (dune (> 2.0))
  dune-configurator)
)
