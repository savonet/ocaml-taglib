ocaml-taglib
============

This package contains an O'Caml interface for 
TagLib Audio Meta-Data Library, otherwise known as taglib.

Please read the COPYING file before using this software.

Prerequisites
--------------

* ocaml >= 4.00.1
* Taglib >= 1.8
* findlib >= 1.3.3

Compilation
-----------

```sh
$ make all
```

This should build both the native and the byte-code version of the
extension library.

Installation
------------

```sh
$ make install
```

This should install the library file (using ocamlfind) in the
appropriate place.

Known Issues
------------

File opening is somewhat unsafe. This has been wrapped in a unix stat test,
but you should ensure that your file is really valid before opening it.
See: http://bugs.debian.org/454732

Author
------

This author of this software may be contacted by electronic mail
at the following address: savonet-users@lists.sourceforge.net.
