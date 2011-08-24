(*
 * Copyright 2007-2011 Romain Beauxis
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
 * Library as distributed by The Savonet Team, or a modified version of the Library that is
 * distributed under the conditions defined in clause 3 of the GNU Library General
 * Public License. This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU Library General Public License.
 *
 *)

(* @author Romain Beauxis *)

(** Ocaml bindings to taglib *)

(** This library provides a set/get interface for several audio file format's tags informations.

    All strings used in this module should be UTF8-encoded. *)

(** {1 Types } *)

type 'a t

(** {1 Functions } *)

(** Library's version. *)
val version : string

(** {2 Generic tag interface } *)

val tag_title : 'a t -> string

val tag_artist : 'a t -> string

val tag_album : 'a t -> string

val tag_comment : 'a t -> string

val tag_genre : 'a t -> string

val tag_year : 'a t -> int

val tag_track : 'a t -> int

(** {2 Set tag interface } *)

val tag_set_title : 'a t -> string -> unit

val tag_set_artist : 'a t -> string -> unit

val tag_set_album : 'a t -> string -> unit

val tag_set_comment : 'a t -> string -> unit

val tag_set_genre : 'a t -> string -> unit

val tag_set_year : 'a t -> int -> unit

val tag_set_track : 'a t -> int -> unit

(** {2 File interface } *)

module File :
sig
  (** Supported file types. Warning, types: [WavPack],
    * [Speex] and [TrueAudio] are only supported in
    * Taglib >= 1.5.
    * Types: [Mp4], [Asf] are only supported with
    * Taglib >= 1.6. *)
  type file_type =
    [ `Autodetect |
      `Mpeg |
      `OggVorbis |
      `Flac |
      `Mpc |
      `OggFlac |
      `WavPack |
      `Speex |
      `TrueAudio |
      `Mp4 |
      `Asf ]

  (** Type for a file. *)
  type 'a file

  (** Raised when using a file that has been closed *)
  exception Closed

  (** Raised when using a file format not supported by
    * the system's taglib library. *)
  exception Not_implemented

  (** Raised when taglib cannot parse a file. *)
  exception Invalid_file

  (** Open a file.

     Raises [Not_found] if file does not exist or could not be opened.

     Raises [Invalid_file] if taglib could not parse the file.

     Raises [Not_implemented] if taglib could not get a valid file. *)
  val open_file : file_type -> string -> (file_type file) t

  val close_file : ('a file) t -> unit

  val file_save : ('a file) t -> bool

  (** {2 Get audio properties interface } *)

  val audioproperties_length : ('a file) t -> int

  val audioproperties_bitrate : ('a file) t -> int

  val audioproperties_samplerate : ('a file) t -> int

  val audioproperties_channels : ('a file) t -> int
end

(** {2 Inline interface } *)

(** This module provides an API to manipulate tags not
  * attached to a file. *)
module Inline :
sig
  (** Parse and generate id3v2 binary tags. 
    *
    * This module provides ways to manipulate id3v2 tags
    * not attached to a file. It is quite low-level and,
    * despite good care in tightening its API, it is possible
    * to generate invalid id3v2 tags using it. The user is thus
    * advised to read about the id3v2 standard before using this
    * module.
    *
    * Currently, only attaching text-based frames are supported. 
    * Reading tag's frames can only be done currently through the
    * common [tag_title], ... API. *)
  module Id3v2 : 
  sig
    type 'a id3v2
    (** State of the tag. This is used to enforce validity of 
      * the generated tag. 
      * 
      * A tag is valid iff it has been properly parsed or
      * at least one frame has been added to it. *)
    type state = [ `Invalid | `Parsed | `Valid ]

    (** A frame type is the id3v2 identifier, e.g. TIT2, TALB, ... *)
    type frame_type = string

    (** Text content of a frame. *)
    type frame_text = string

    val init : unit -> ([`Invalid] id3v2) t

    val header_size : int

    val parse_header : ([`Invalid] id3v2) t -> string -> ([`Parsed] id3v2) t

    val tag_size : ([< `Parsed | `Valid] id3v2) t -> int

    val parse_tag : ([`Parsed] id3v2) t -> string -> ([`Valid] id3v2) t

    val attach_frame : ([< `Invalid | `Valid ] id3v2) t -> frame_type -> frame_text -> ([`Valid] id3v2) t

    val render : ([`Valid] id3v2) t -> string

    (** {2 Generic set functions} *)
    
    (** These functions perform the same operations as their counter-part from [Taglib]. 
      * The only difference here is that they return a valid tag. *)

    val tag_set_title : ([< `Invalid | `Valid ] id3v2) t -> string -> ([`Valid] id3v2) t

    val tag_set_artist : ([< `Invalid | `Valid ] id3v2) t -> string -> ([`Valid] id3v2) t

    val tag_set_album : ([< `Invalid | `Valid ] id3v2) t -> string -> ([`Valid] id3v2) t

    val tag_set_comment : ([< `Invalid | `Valid ] id3v2) t -> string -> ([`Valid] id3v2) t

    val tag_set_genre : ([< `Invalid | `Valid ] id3v2) t -> string -> ([`Valid] id3v2) t

    val tag_set_year : ([< `Invalid | `Valid ] id3v2) t -> int -> ([`Valid] id3v2) t

    val tag_set_track : ([< `Invalid | `Valid ] id3v2) t -> int -> ([`Valid] id3v2) t
  end
end
