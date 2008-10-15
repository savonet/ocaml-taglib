(*
 * Copyright 2007 Romain Beauxis
 *
 * This file is part of ocaml-taglib.
 *
 * ocaml-taglib is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * ocaml-taglib is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with ocaml-taglib; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * As a special exception to the GNU Library General Public License, you may
 * link, statically or dynamically, a "work that uses the Library" with a publicly
 * distributed version of the Library to produce an executable file containing
 * portions of the Library, and distribute that executable file under terms of
 * your choice, without any of the additional requirements listed in clause 6
 * of the GNU Library General Public License.
 * By "a publicly distributed version of the Library", we mean either the unmodified
 * Library as distributed by INRIA, or a modified version of the Library that is
 * distributed under the conditions defined in clause 3 of the GNU Library General
 * Public License. This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU Library General Public License.
 *
 *)

(* @author Romain Beauxis *)

(** Ocaml bindings to taglib *)

(** This library provides a set/get interface for several audio file format's tags informations.

    Usage is quite simple. All functions using a [file] type variable, except [close_file], 
    may raise [Closed] if given file was closed. *)

(** {1 Types } *)

type file
type file_type = 
  Mpeg | 
  OggVorbis | 
  Flac |
  Mpc

(** Raised when using a file that has been closed *)
exception Closed

(** {1 Functions } *)

(** {2 Settings } *)

(** All strings supplied to the library are supposed to be UTF-8. 
    Set this to [true] to use strings in latin1 (ISO-8859-1)
    format *)
val set_strings_unicode : bool -> unit

(** {2 File interface } *)

(** Open a file. 
  
   Raises [Not_found] if file does not exist or could not be opened. *)
val open_file : ?file_type:file_type -> string -> file

val close_file : file -> unit

val file_save : file -> bool

(** {2 Get tag interface } *)

val tag_title : file -> string

val tag_artist : file -> string

val tag_album : file -> string

val tag_comment : file -> string

val tag_genre : file -> string

val tag_year : file -> int

val tag_track : file -> int

(** {2 Set tag interface } *)

val tag_set_title : file -> string -> unit

val tag_set_artist : file -> string -> unit

val tag_set_album : file -> string -> unit

val tag_set_comment : file -> string -> unit

val tag_set_genre : file -> string -> unit

val tag_set_year : file -> int -> unit

val tag_set_track : file -> int -> unit

(** {2 Get audio properties interface } *)

val audioproperties_length : file -> int

val audioproperties_bitrate : file -> int

val audioproperties_samplerate : file -> int

val audioproperties_channels : file -> int


