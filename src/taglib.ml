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

external init : unit -> unit = "caml_taglib_init"

let () =
  Callback.register_exception "taglib_exn_not_found" Not_found;
  init ()

type tag
type 'a t = 'a * ('a -> tag)

external version : unit -> string = "caml_taglib_version"

let version = version ()

module File = struct
  type taglib_file
  type audioproperties

  type file_type =
    [ `Autodetect
    | `Mpeg
    | `OggVorbis
    | `OggOpus
    | `Flac
    | `Mpc
    | `OggFlac
    | `WavPack
    | `Speex
    | `TrueAudio
    | `Mp4
    | `Asf ]

  type 'a fileref = {
    file_type : 'a;
    mutable taglib_file : taglib_file option;
  }
    constraint 'a = [< file_type ]

  (** Type for a file. *)
  type 'a file_tag = 'a fileref

  type 'a file = 'a fileref t

  exception Invalid_file
  exception Closed
  exception Not_implemented

  let _ =
    Callback.register_exception "taglib_exn_invalid_file" Invalid_file;
    Callback.register_exception "taglib_exn_not_implemented" Not_implemented

  external open_file : file_type -> string -> taglib_file
    = "caml_taglib_file_new"

  external close_file : taglib_file -> unit = "caml_taglib_file_free"

  let close_file (d, _) =
    match d with
      | { taglib_file = None; _ } -> ()
      | { taglib_file = Some f; _ } ->
          close_file f;
          d.taglib_file <- None

  external file_tag : taglib_file -> tag = "caml_taglib_file_tag"

  external file_audioproperties : taglib_file -> audioproperties
    = "caml_taglib_file_audioproperties"

  let get_taglib_file f =
    match f with
      | { taglib_file = None; _ } -> raise Closed
      | { taglib_file = Some f; _ } -> f

  external file_save : taglib_file -> bool = "caml_taglib_file_save"

  let file_save (f, _) = file_save (get_taglib_file f)

  let file_type (d, _) =
    match d with { taglib_file = None; _ } -> raise Closed | _ -> d.file_type

  let open_file file_type name =
    (* Test whether file exist to avoid library issue.
       See: http://bugs.debian.org/454732 *)
    begin
      try ignore (Unix.stat name) with _ -> raise Not_found
    end;
    let f = open_file file_type name in
    let file = { taglib_file = Some f; file_type } in
    let file =
      ( file,
        fun f ->
          match f with
            | { taglib_file = None; _ } -> raise Closed
            | { taglib_file = Some f; _ } -> file_tag f )
    in
    Gc.finalise close_file file;
    file

  external properties : taglib_file -> (string -> string -> unit) -> unit
    = "caml_taglib_file_get_properties"

  let properties (f, _) =
    let f = get_taglib_file f in
    let props = Hashtbl.create 5 in
    let fn key value =
      let values = try Hashtbl.find props key with Not_found -> [] in
      Hashtbl.replace props key (value :: values)
    in
    properties f fn;
    props

  external set_properties : taglib_file -> (string * string array) array -> unit
    = "caml_taglib_file_set_properties"

  let set_properties (f, _) props =
    let f = get_taglib_file f in
    let props =
      Hashtbl.fold
        (fun key values props -> (key, Array.of_list values) :: props)
        props []
    in
    set_properties f (Array.of_list props)

  external audioproperties_get_int : audioproperties -> string -> int
    = "caml_taglib_audioproperties_get_int"

  let audioproperties_get_int (f, _) s =
    let f = get_taglib_file f in
    audioproperties_get_int (file_audioproperties f) s

  let audioproperties_length p = audioproperties_get_int p "length"
  let audioproperties_bitrate p = audioproperties_get_int p "bitrate"
  let audioproperties_samplerate p = audioproperties_get_int p "samplerate"
  let audioproperties_channels p = audioproperties_get_int p "channels"
end

let tag_extract (x, f) = f x

external tag_get_string : tag -> string -> string = "caml_taglib_tag_get_string"

let tag_get_string d s = tag_get_string (tag_extract d) s
let tag_title t = tag_get_string t "title"
let tag_artist t = tag_get_string t "artist"
let tag_album t = tag_get_string t "album"
let tag_comment t = tag_get_string t "comment"
let tag_genre t = tag_get_string t "genre"

external tag_get_int : tag -> string -> int = "caml_taglib_tag_get_int"

let tag_get_int d s = tag_get_int (tag_extract d) s
let tag_year t = tag_get_int t "year"
let tag_track t = tag_get_int t "track"

external tag_set_string : tag -> string -> string -> unit
  = "caml_taglib_tag_set_string"

let tag_set_string t s v = tag_set_string (tag_extract t) s v
let tag_set_title t = tag_set_string t "title"
let tag_set_artist t = tag_set_string t "artist"
let tag_set_album t = tag_set_string t "album"
let tag_set_comment t = tag_set_string t "comment"
let tag_set_genre t = tag_set_string t "genre"

external tag_set_int : tag -> string -> int -> unit = "caml_taglib_tag_set_int"

let tag_set_int t s v = tag_set_int (tag_extract t) s v
let tag_set_year t = tag_set_int t "year"
let tag_set_track t = tag_set_int t "track"

module Inline = struct
  module Id3v2 = struct
    type state = [ `Invalid | `Parsed | `Valid ]
    type 'a id3v2_tag = unit constraint 'a = [< state ]
    type 'a id3v2 = 'a id3v2_tag t
    type frame_type = string
    type frame_text = string

    external init : unit -> tag = "caml_taglib_id3v2_init"

    let init () =
      let t = init () in
      ((), fun () -> t)

    external header_size : unit -> int = "caml_taglib_id3v2_header_len"

    let header_size = header_size ()
    let grab_tag ((), f) = f ()

    external parse_header : tag -> string -> unit
      = "caml_taglib_id3v2_parse_header"

    external tag_size : tag -> int = "caml_taglib_id3v2_tag_size"

    let tag_size t = tag_size (grab_tag t)

    let parse_header t h =
      if String.length h < header_size then failwith "header string too short.";
      parse_header (grab_tag t) h;
      if tag_size t <= header_size then failwith "invalid header";
      t

    external parse_tag : tag -> string -> unit = "caml_taglib_id3v2_parse_tag"

    let parse_tag t h =
      if String.length h < tag_size t then failwith "tag data too short.";
      parse_tag (grab_tag t) h;
      t

    external render : tag -> bytes = "caml_taglib_id3v2_render"

    let render t = Bytes.unsafe_to_string (render (grab_tag t))

    external attach_frame : tag -> string -> string -> unit
      = "caml_taglib_id3v2_attach_frame"

    let attach_frame t l c =
      attach_frame (grab_tag t) l c;
      t

    let tag_set_title t s =
      tag_set_title t s;
      t

    let tag_set_artist t s =
      tag_set_artist t s;
      t

    let tag_set_album t s =
      tag_set_album t s;
      t

    let tag_set_comment t s =
      tag_set_comment t s;
      t

    let tag_set_genre t s =
      tag_set_genre t s;
      t

    let tag_set_year t s =
      tag_set_year t s;
      t

    let tag_set_track t s =
      tag_set_track t s;
      t
  end
end

type file_type =
  | Mpeg
  | OggVorbis
  | OggOpus
  | Flac
  | Mpc
  | OggFlac
  | WavPack
  | Speex
  | TrueAudio
  | Mp4
  | Asf

exception Closed
exception Not_implemented

let set_strings_unicode _ = ()

let open_file ?file_type f =
  let f x = File.open_file x f in
  match file_type with
    | None -> f `Autodetect
    | Some t -> (
        match t with
          | Mpeg -> f `Mpeg
          | OggVorbis -> f `OggVorbis
          | OggOpus -> f `OggOpus
          | Flac -> f `Flac
          | Mpc -> f `Mpc
          | OggFlac -> f `OggFlac
          | WavPack -> f `WavPack
          | Speex -> f `Speex
          | TrueAudio -> f `TrueAudio
          | Mp4 -> f `Mp4
          | Asf -> f `Asf)

let w f t =
  try f t with
    | File.Closed -> raise Closed
    | File.Not_implemented -> raise Not_implemented

let audioproperties_length = w File.audioproperties_length
let audioproperties_bitrate = w File.audioproperties_bitrate
let audioproperties_samplerate = w File.audioproperties_samplerate
let audioproperties_channels = w File.audioproperties_channels
let close_file = w File.close_file
let file_save = w File.file_save
