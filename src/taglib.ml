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
  Callback.register_exception "taglib_exn_not_found" Not_found ;
  init ()

type tag
type 'a t = 'a * ('a -> tag)

external version : unit -> string = "caml_taglib_version"

let version = version ()

module File = 
struct
  type taglib_file
  type audioproperties
  type fileref = 
    { taglib_file : taglib_file;
      audioproperties : audioproperties;
      tag : tag }
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
  type 'a file = 'a * (fileref option ref)

  exception Invalid_file
  exception Closed
  exception Not_implemented

  let _ = 
    Callback.register_exception "taglib_exn_invalid_file" Invalid_file;
    Callback.register_exception "taglib_exn_not_implemented" Not_implemented

  external open_file : file_type -> string -> taglib_file = "caml_taglib_file_new"

  external close_file : taglib_file -> unit = "caml_taglib_file_free"

  let close_file ((_,d),_) = 
    match !d with
      | None -> ()
      | Some f -> 
          close_file f.taglib_file ; 
          d := None

  external file_tag : taglib_file -> tag = "caml_taglib_file_tag"

  external file_audioproperties : taglib_file -> audioproperties = "caml_taglib_file_audioproperties"

  external file_save : taglib_file -> bool = "caml_taglib_file_save"

  let file_save ((_,d),_) = 
    match !d with
      | None -> raise Closed
      | Some f -> file_save f.taglib_file

  let open_file file_type name =
    (* Test whether file exist to avoid library issue.
       See: http://bugs.debian.org/454732 *)
    begin
      try
        ignore(Unix.stat name)
      with
        | _ -> raise Not_found
    end ;
    let f = open_file file_type name in
    let tag = file_tag f in
    let prop = file_audioproperties f in
    let file = ref (Some { taglib_file = f;
                           audioproperties = prop;
                           tag = tag })
    in
    (file_type,file), (fun (_,f) -> 
                          match !f with
                            | None -> raise Closed
                            | Some f -> f.tag)

  external audioproperties_get_int : audioproperties -> string -> int = "caml_taglib_audioproperties_get_int"

  let audioproperties_get_int ((_,f),_) s =
    match !f with
      | None -> raise Closed;
      | Some f -> audioproperties_get_int f.audioproperties s

  let audioproperties_length p = audioproperties_get_int p "length"

  let audioproperties_bitrate p = audioproperties_get_int p "bitrate"

  let audioproperties_samplerate p = audioproperties_get_int p "samplerate"

  let audioproperties_channels p = audioproperties_get_int p "channels"
end

let tag_extract (x,f) = f x

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

external tag_set_string : tag -> string -> string -> unit = "caml_taglib_tag_set_string"

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

module Inline = 
struct
  module Id3v2 = 
  struct
    type 'a id3v2 = unit 
    type state = [ `Invalid | `Parsed | `Valid ]

    type frame_type = string

    type frame_text = string

    external init : unit -> tag = "caml_taglib_id3v2_init"

    let init () = 
      let t = init () in
      (), (fun () -> t)

    external header_size : unit -> int = "caml_taglib_id3v2_header_len"

    let header_size = header_size ()

    let grab_tag (_,f) = f () 

    external parse_header : tag -> string -> unit = "caml_taglib_id3v2_parse_header"

    external tag_size : tag -> int = "caml_taglib_id3v2_tag_size"

    let tag_size t = tag_size (grab_tag t)

    let parse_header t h =
      if String.length h < header_size then
        failwith "header string too short.";
      parse_header (grab_tag t) h ;
      if tag_size t <= header_size then
        failwith "invalid header" ;
      t

    external parse_tag : tag -> string -> unit = "caml_taglib_id3v2_parse_tag"

    let parse_tag t h = 
      if String.length h < tag_size t then
        failwith "tag data too short.";
      parse_tag (grab_tag t) h ;
      t
   
    external render : tag -> string = "caml_taglib_id3v2_render"

    let render t = render (grab_tag t)

    external attach_frame : tag -> string -> string -> unit = "caml_taglib_id3v2_attach_frame"

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
