/*
 * Copyright 2007-2010 Romain Beauxis
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
 */


/*
 * Ocaml interface to taglib
 *
 * @author Romain Beauxis
 */

#include <taglib/tag_c.h>
#include <string.h>

#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/signals.h>

CAMLprim value caml_taglib_init()
{
  CAMLparam0();
  /* Desactivates string memory management */
  taglib_set_string_management_enabled(0) ;
  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_set_strings_unicode(value b)
{
  CAMLparam1(b);

  taglib_set_strings_unicode(Bool_val(b)) ;

  CAMLreturn(Val_unit);
}

/* Returns #defined values that are used for C functions
 * remove initial Taglib_ to avoid define :) */
CAMLprim value caml_taglib_priv_value_int(value name)
{
  CAMLparam1(name);
  char *s = String_val(name);
    if (!strcmp(s,"File_MPEG"))
      CAMLreturn(Val_int(TagLib_File_MPEG)) ;
    if (!strcmp(s,"File_OggVorbis"))
      CAMLreturn(Val_int(TagLib_File_OggVorbis)) ;
    if (!strcmp(s,"File_FLAC"))
      CAMLreturn(Val_int(TagLib_File_FLAC)) ;
    if (!strcmp(s,"File_MPC"))
      CAMLreturn(Val_int(TagLib_File_MPC)) ;
    if (!strcmp(s,"File_OggFlac"))
      CAMLreturn(Val_int(TagLib_File_OggFlac)) ;
#ifdef TagLib_File_WavPack
    if (!strcmp(s,"File_WavPack"))
      CAMLreturn(Val_int(TagLib_File_WavPack)) ;
#endif
#ifdef TagLib_File_Speex
    if (!strcmp(s,"File_Speex"))
      CAMLreturn(Val_int(TagLib_File_Speex)) ;
#endif
#ifdef TagLib_File_TrueAudio
    if (!strcmp(s,"File_TrueAudio"))
      CAMLreturn(Val_int(TagLib_File_TrueAudio)) ;
#endif
#ifdef TagLib_File_MP4
    if (!strcmp(s,"File_MP4"))
      CAMLreturn(Val_int(TagLib_File_MP4)) ;
#endif
#ifdef TagLib_File_ASF
    if (!strcmp(s,"File_ASF"))
      CAMLreturn(Val_int(TagLib_File_ASF)) ;
#endif

  caml_raise_constant(*caml_named_value("taglib_exn_not_implemented"));
}

#define Taglib_file_val(v) ((TagLib_File *)v)
#define Taglib_file_const_val(v) ((const TagLib_File *)v)
#define Taglib_tag_val(v) ((TagLib_Tag *)v)
#define Taglib_tag_const_val(v) ((const TagLib_Tag *)v)
#define Taglib_audioproperties_val(v) ((const TagLib_AudioProperties *)v)

CAMLprim value caml_taglib_file_new(value name)
{
  CAMLparam1(name);

  TagLib_File *f = taglib_file_new(String_val(name)) ;

  if (f == NULL)
    caml_raise_constant(*caml_named_value("taglib_exn_not_found"));

  CAMLreturn((value)f);
}

CAMLprim value caml_taglib_file_new_type(value name, value type)
{
  CAMLparam2(name,type);

  TagLib_File *f =
    taglib_file_new_type(String_val(name),Int_val(type)) ;

  if (f == NULL)
    caml_raise_constant(*caml_named_value("taglib_exn_not_found"));

  CAMLreturn((value)f);
}

CAMLprim value caml_taglib_file_free(value f)
{
  CAMLparam1(f);
  taglib_file_free(Taglib_file_val(f));

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_file_tag(value f)
{
  CAMLparam1(f);
  TagLib_Tag *t = taglib_file_tag(Taglib_file_val(f)) ;

  if (t == NULL)
    caml_raise_constant(*caml_named_value("taglib_exn_not_found"));

  CAMLreturn((value)t);
}

CAMLprim value caml_taglib_file_audioproperties(value f)
{
  CAMLparam1(f);
  const TagLib_AudioProperties *p = taglib_file_audioproperties(Taglib_file_val(f)) ;

  if (p == NULL)
    caml_raise_constant(*caml_named_value("taglib_exn_not_found"));


  CAMLreturn((value)p);
}

CAMLprim value caml_taglib_file_save(value f)
{
  CAMLparam1(f);
  CAMLreturn(Val_bool(taglib_file_save(Taglib_file_val(f))));
}

CAMLprim value caml_taglib_tag_get_string(value t, value name)
{
  CAMLparam2(t,name);
  CAMLlocal1(ans);
  const TagLib_Tag *tag = Taglib_tag_const_val(t) ;
  char *s = String_val(name);
  char *tmp;

    if (!strcmp(s,"title"))
      tmp = taglib_tag_title(tag) ;
    else if (!strcmp(s,"artist"))
      tmp = taglib_tag_artist(tag) ;
    else if (!strcmp(s,"album"))
      tmp = taglib_tag_album(tag) ;
    else if (!strcmp(s,"comment"))
      tmp = taglib_tag_comment(tag) ;
    else if (!strcmp(s,"genre"))
      tmp = taglib_tag_genre(tag) ;
    else
      caml_failwith("Invalid value");

  ans = caml_copy_string(tmp) ; 
  free(tmp) ;
  CAMLreturn(ans);
}

CAMLprim value caml_taglib_tag_get_int(value t, value name)
{
  CAMLparam2(t,name);
  const TagLib_Tag *tag = Taglib_tag_const_val(t) ;
  char *s = String_val(name);
  int tmp;

    if (!strcmp(s,"year"))
      tmp = taglib_tag_year(tag) ;
    else if (!strcmp(s,"track"))
      tmp = taglib_tag_track(tag) ;
    else
      caml_failwith("Invalid value");

  CAMLreturn(Val_int(tmp));
}

CAMLprim value caml_taglib_tag_set_string(value t, value name, value v)
{
  CAMLparam3(t,name, v);
  TagLib_Tag *tag = Taglib_tag_val(t) ;
  char *s = String_val(name);
  char *x = String_val(v) ;

    if (!strcmp(s,"title"))
      taglib_tag_set_title(tag,x) ;
    else if (!strcmp(s,"artist"))
      taglib_tag_set_artist(tag,x) ;
    else if (!strcmp(s,"album"))
      taglib_tag_set_album(tag,x) ;
    else if (!strcmp(s,"comment"))
      taglib_tag_set_comment(tag,x) ;
    else if (!strcmp(s,"genre"))
      taglib_tag_set_genre(tag,x) ;
    else
      caml_failwith("Invalid value");

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_tag_set_int(value t, value name, value v)
{
  CAMLparam3(t,name, v);
  TagLib_Tag *tag = Taglib_tag_val(t) ;
  char *s = String_val(name);
  int x = Int_val(v) ;

    if (!strcmp(s,"year"))
      taglib_tag_set_year(tag,x) ;
    else if (!strcmp(s,"track"))
      taglib_tag_set_track(tag,x) ;
    else
      caml_failwith("Invalid value");

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_audioproperties_get_int(value p, value name)
{
  CAMLparam2(p,name);
  const TagLib_AudioProperties *prop = Taglib_audioproperties_val(p) ;
  char *s = String_val(name);
  int tmp;

    if (!strcmp(s,"length"))
      tmp = taglib_audioproperties_length(prop) ;
    else if (!strcmp(s,"bitrate"))
      tmp = taglib_audioproperties_bitrate(prop) ;
    else if (!strcmp(s,"samplerate"))
      tmp = taglib_audioproperties_samplerate(prop) ;
    else if (!strcmp(s,"channels"))
      tmp = taglib_audioproperties_channels(prop) ;
    else
      caml_failwith("Invalid value");

  CAMLreturn(Val_int(tmp));
}




