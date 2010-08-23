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

type t

(** Supported file types. Warning, types: [OggFlac],
  * [WavPack], [Speex], [TrueAudio], [Mp4], [Asf]
  * only supported with taglib version 1.6 or greater. *)
type file_type = 
  Mpeg | 
  OggVorbis | 
  Flac |
  Mpc  |
  OggFlac |
  WavPack |
  Speex |
  TrueAudio |
  Mp4 |
  Asf 

(** Raised when using a file that has been closed *)
exception Closed

(** Raised when using a file format not supported by 
  * the system's taglib library. *)
exception Not_implemented

(** {1 Functions } *)

(** {2 Settings } *)

(** All strings supplied to the library are supposed to be UTF-8. 
    Set this to [true] to use strings in latin1 (ISO-8859-1)
    format *)
val set_strings_unicode : bool -> unit

(** {2 File interface } *)

(** Open a file. 
  
   Raises [Not_found] if file does not exist or could not be opened. 

   Raises [Not_implemented] if using a [file_type] that is not implemented
   in the system's taglib library. *)
val open_file : ?file_type:file_type -> string -> t

val close_file : t -> unit

val file_save : t -> bool

(** {2 Get tag interface } *)

val tag_title : t -> string

val tag_artist : t -> string

val tag_album : t -> string

val tag_comment : t -> string

val tag_genre : t -> string

val tag_year : t -> int

val tag_track : t -> int

(** {2 Set tag interface } *)

val tag_set_title : t -> string -> unit

val tag_set_artist : t -> string -> unit

val tag_set_album : t -> string -> unit

val tag_set_comment : t -> string -> unit

val tag_set_genre : t -> string -> unit

val tag_set_year : t -> int -> unit

val tag_set_track : t -> int -> unit

(** {2 Get audio properties interface } *)

val audioproperties_length : t -> int

val audioproperties_bitrate : t -> int

val audioproperties_samplerate : t -> int

val audioproperties_channels : t -> int


