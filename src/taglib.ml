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

(** Perform this *FIRST* *)
external init : unit -> unit = "caml_taglib_init"
let () = 
  Callback.register_exception "taglib_exn_not_found" Not_found ;
  init () ;


type _file
type tag
type audioproperties
type file = ((_file option)*(tag option)*(audioproperties option)) ref
type file_type = 
  Mpeg | 
  OggVorbis | 
  Flac |
  Mpc

exception Closed

external set_strings_unicode : bool -> unit = "caml_taglib_set_strings_unicode"

external priv_value_int : string -> int = "caml_taglib_priv_value_int"

external _open_file : string -> _file = "caml_taglib_file_new"

external _open_file_type : string -> int -> _file = "caml_taglib_file_new_type"

let int_of_type m = 
  let f = priv_value_int in
  match m with
    | Mpeg -> f "File_MPEG"
    | OggVorbis -> f "File_OggVorbis"
    | Flac -> f "File_FLAC"
    | Mpc -> f "File_MPC"

let open_file ?file_type name = 
  (* Test wether file exist to avoid library issue.
     See: http://bugs.debian.org/454732 *)
  begin
    try
      ignore(Unix.stat name)
    with
      | _ -> raise Not_found
  end ;
  let f = 
    match file_type with
      | None -> _open_file name
      | Some m -> _open_file_type name (int_of_type m)
  in
  ref (Some f,None,None)

external _close_file : _file -> unit = "caml_taglib_file_free"

let close_file d = 
  let (f,_,_) = !d in
  match f with
    | None -> ()
    | Some f -> _close_file f ; d := (None,None,None)

external file_tag : _file -> tag = "caml_taglib_file_tag"

external file_audioproperties : _file -> audioproperties = "caml_taglib_file_audioproperties"

external _file_save : _file -> bool = "caml_taglib_file_save"

let file_save d = 
  let (f,_,_) = !d in
  match f with
    | None -> raise Closed
    | Some f -> _file_save f

let tag_extract d = 
  let (f,t,p) = !d in
  match f,t with
    | None,_ -> raise Closed
    | Some file,None -> 
       let tmp = file_tag file in
       d := (f,Some tmp,p) ;
       tmp
    | Some _,Some t -> t

external _tag_get_string : tag -> string -> string = "caml_taglib_tag_get_string"

let tag_get_string d s = 
  _tag_get_string (tag_extract d) s

let tag_title t = 
  tag_get_string t "title"

let tag_artist t = 
  tag_get_string t "artist"

let tag_album t = 
  tag_get_string t "album"

let tag_comment t = 
  tag_get_string t "comment"

let tag_genre t = 
  tag_get_string t "genre"

external _tag_get_int : tag -> string -> int = "caml_taglib_tag_get_int"

let tag_get_int d s = 
  _tag_get_int (tag_extract d) s

let tag_year t = 
  tag_get_int t "year"

let tag_track t = 
  tag_get_int t "track"

external _tag_set_string : tag -> string -> string -> unit = "caml_taglib_tag_set_string"

let tag_set_string t s v = 
  _tag_set_string (tag_extract t) s v

let tag_set_title t = 
  tag_set_string t "title"

let tag_set_artist t = 
  tag_set_string t "artist"

let tag_set_album t = 
  tag_set_string t "album"

let tag_set_comment t = 
  tag_set_string t "comment"

let tag_set_genre t = 
  tag_set_string t "genre"

external _tag_set_int : tag -> string -> int -> unit = "caml_taglib_tag_set_int"

let tag_set_int t s v = 
  _tag_set_int (tag_extract t) s v

let tag_set_year t = 
  tag_set_int t "year"

let tag_set_track t = 
  tag_set_int t "track"

external _audioproperties_get_int : audioproperties -> string -> int = "caml_taglib_audioproperties_get_int"

let audioproperties_get_int d s = 
  let (f,t,p) = !d in
  let p = 
    match f,p with
      | None,_ -> raise Closed
      | Some file,None -> 
        let tmp = file_audioproperties file in
        d := (f,t,Some tmp) ;
        tmp
      | _,Some p -> p
  in
  _audioproperties_get_int p s

let audioproperties_length p = 
  audioproperties_get_int p "length"

let audioproperties_bitrate p = 
  audioproperties_get_int p "bitrate"

let audioproperties_samplerate p = 
  audioproperties_get_int p "samplerate"

let audioproperties_channels p = 
  audioproperties_get_int p "channels"


