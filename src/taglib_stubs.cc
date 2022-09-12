/*
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
 * link, statically or dynamically, a "work that uses the Library" with a
 * publicly distributed version of the Library to produce an executable file
 * containing portions of the Library, and distribute that executable file under
 * terms of your choice, without any of the additional requirements listed in
 * clause 6 of the GNU Library General Public License. By "a publicly
 * distributed version of the Library", we mean either the unmodified Library as
 * distributed by The Savonet Team, or a modified version of the Library that is
 * distributed under the conditions defined in clause 3 of the GNU Library
 * General Public License. This exception does not however invalidate any other
 * reasons why the executable file might be covered by the GNU Library General
 * Public License.
 *
 */

/*
 * Ocaml interface to taglib
 *
 * @author Romain Beauxis
 */

#include "config.h"

#include <stdlib.h>

#include <fileref.h>
#include <tfile.h>

#ifdef HAS_ASF
#include <asffile.h>
#endif

#include <flacfile.h>
#include <mpegfile.h>
#include <oggflacfile.h>
#include <vorbisfile.h>

#ifdef HAS_OPUS
#include <opusfile.h>
#endif

#ifdef HAS_MP4
#include <mp4file.h>
#endif

#ifdef HAS_MPC
#include <mpcfile.h>
#endif

#ifdef HAS_WAVPACK
#include <wavpackfile.h>
#endif

#ifdef HAS_SPEEX
#include <speexfile.h>
#endif

#ifdef HAS_TRUEAUDIO
#include <trueaudiofile.h>
#endif

#ifdef HAS_PROPERTIES
#include <tpropertymap.h>
#else
#include <stdio.h>
#endif

#include <id3v2framefactory.h>
#include <id3v2tag.h>
#include <string.h>
#include <tag.h>
#include <textidentificationframe.h>

using namespace TagLib;

/* Declaring the functions which should be accessible on the C side. */
extern "C" {
#define CAML_INTERNALS
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/misc.h>
#include <caml/signals.h>

#ifdef WIN32
#include <caml/osdeps.h>
#endif

/* Use new thread syntax in a backward fashion. */
#define caml_acquire_runtime_system caml_leave_blocking_section
#define caml_release_runtime_system caml_enter_blocking_section

#include <caml/custom.h>
CAMLprim value caml_taglib_version(value unit);
CAMLprim value caml_taglib_init(value unit);
CAMLprim value caml_taglib_file_new(value type, value name);
CAMLprim value caml_taglib_file_free(value f);
CAMLprim value caml_taglib_file_tag(value f);
CAMLprim value caml_taglib_file_audioproperties(value f);
CAMLprim value caml_taglib_file_save(value f);
CAMLprim value caml_taglib_tag_get_string(value t, value name);
CAMLprim value caml_taglib_tag_get_int(value t, value name);
CAMLprim value caml_taglib_file_get_properties(value f, value fn);
CAMLprim value caml_taglib_tag_set_string(value t, value name, value v);
CAMLprim value caml_taglib_tag_set_int(value t, value name, value v);
CAMLprim value caml_taglib_file_set_properties(value t, value properties);
CAMLprim value caml_taglib_audioproperties_get_int(value p, value name);
CAMLprim value caml_taglib_id3v2_init(value unit);
CAMLprim value caml_taglib_id3v2_clean(value t);
CAMLprim value caml_taglib_id3v2_header_len(value t);
CAMLprim value caml_taglib_id3v2_parse_header(value t, value h);
CAMLprim value caml_taglib_id3v2_tag_size(value t);
CAMLprim value caml_taglib_id3v2_parse_tag(value t, value h);
CAMLprim value caml_taglib_id3v2_render(value t);
CAMLprim value caml_taglib_id3v2_attach_frame(value t, value l, value c);
}

CAMLprim value caml_taglib_version(value unit) {
  return caml_copy_string(
      "TAGLIB_MAJOR_VERSION.TAGLIB_MINOR_VERSION.TAGLIB_PATCH_VERSION");
}

/* polymorphic variant utility macros */
#define decl_var(x) static value var_##x
#define import_var(x) var_##x = caml_hash_variant(#x)
#define get_var(x) var_##x

/* cached polymorphic variants */
decl_var(Autodetect);
decl_var(Mpeg);
decl_var(OggVorbis);
decl_var(OggOpus);
decl_var(Flac);
decl_var(Mpc);
decl_var(OggFlac);
decl_var(WavPack);
decl_var(Speex);
decl_var(TrueAudio);
decl_var(Mp4);
decl_var(Asf);

CAMLprim value caml_taglib_init(value unit) {
  CAMLparam0();
  /* initialize polymorphic variants */
  import_var(Autodetect);
  import_var(Mpeg);
  import_var(OggVorbis);
  import_var(OggOpus);
  import_var(Flac);
  import_var(Mpc);
  import_var(OggFlac);
  import_var(WavPack);
  import_var(Speex);
  import_var(TrueAudio);
  import_var(Mp4);
  import_var(Asf);
  CAMLreturn(Val_unit);
}

#define Taglib_file_val(v) (*((File **)Data_abstract_val(v)))

static inline value value_of_taglib_file(value v, File *f) {
  v = caml_alloc(1, Abstract_tag);
  *((File **)Data_abstract_val(v)) = f;
  return v;
}

#define Taglib_tag_val(v) (*((Tag **)Data_custom_val(v)))

// tag are implemented as custom val in the id3v2 case so we need
// to be consistent here.
static struct custom_operations tag_ops = {
    (char *)"ocaml_taglib_tag", custom_finalize_default,
    custom_compare_default,     custom_hash_default,
    custom_serialize_default,   custom_deserialize_default};

static inline value value_of_taglib_tag(value v, Tag *tag) {
  v = caml_alloc_custom(&tag_ops, sizeof(Tag *), 1, 0);
  Taglib_tag_val(v) = tag;
  return v;
}

#define Taglib_audioproperties_val(v)                                          \
  (*((AudioProperties **)Data_abstract_val(v)))

static inline value value_of_taglib_audioproperties(value v,
                                                    AudioProperties *f) {
  v = caml_alloc(1, Abstract_tag);
  *((AudioProperties **)Data_abstract_val(v)) = f;
  return v;
}

CAMLprim value caml_taglib_file_new(value type, value name) {
  CAMLparam2(name, type);
  CAMLlocal1(ret);

  File *f = NULL;

#ifdef WIN32
  wchar_t *filename = caml_stat_strdup_to_os(String_val(name));
#else
  char *filename = strdup(String_val(name));
#endif

  if (filename == NULL)
    caml_raise_out_of_memory();

  caml_release_runtime_system();

  if (type == get_var(Autodetect))
    f = FileRef::create(filename);
  else if (type == get_var(Mpeg))
    f = new MPEG::File(filename);
  else if (type == get_var(OggVorbis))
    f = new Ogg::Vorbis::File(filename);
#ifdef HAS_OPUS
  else if (type == get_var(OggOpus))
    f = new Ogg::Opus::File(filename);
#endif
  else if (type == get_var(Flac))
    f = new FLAC::File(filename);
#ifdef HAS_MPC
  else if (type == get_var(Mpc))
    f = new MPC::File(filename);
#endif
  else if (type == get_var(OggFlac))
    f = new Ogg::FLAC::File(filename);
#ifdef HAS_WAVPACK
  else if (type == get_var(WavPack))
    f = new MPEG::File(filename);
#endif
#ifdef HAS_SPEEX
  else if (type == get_var(Speex))
    f = new Ogg::Speex::File(filename);
#endif
#ifdef HAS_TRUEAUDIO
  else if (type == get_var(TrueAudio))
    f = new TrueAudio::File(filename);
#endif
#ifdef HAS_MP4
  else if (type == get_var(Mp4))
    f = new MP4::File(filename);
#endif
#ifdef HAS_ASF
  else if (type == get_var(Mpeg))
    f = new MPEG::File(filename);
#endif
  else {
    free(filename);
    caml_acquire_runtime_system();
    caml_raise_constant(*caml_named_value("taglib_exn_not_implemented"));
  }

  free(filename);
  caml_acquire_runtime_system();

  if (!(f && f->isValid())) {
    delete f;
    caml_raise_constant(*caml_named_value("taglib_exn_invalid_file"));
  }

  CAMLreturn(value_of_taglib_file(ret, f));
}

CAMLprim value caml_taglib_file_free(value f) {
  CAMLparam1(f);

  delete Taglib_file_val(f);

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_file_tag(value f) {
  CAMLparam1(f);
  CAMLlocal1(ret);
  Tag *t = Taglib_file_val(f)->tag();

  if (t == NULL)
    caml_raise_constant(*caml_named_value("taglib_exn_not_found"));

  CAMLreturn(value_of_taglib_tag(ret, t));
}

CAMLprim value caml_taglib_file_audioproperties(value f) {
  CAMLparam1(f);
  CAMLlocal1(ret);
  AudioProperties *p = Taglib_file_val(f)->audioProperties();

  if (p == NULL)
    caml_raise_constant(*caml_named_value("taglib_exn_not_found"));

  CAMLreturn(value_of_taglib_audioproperties(ret, p));
}

CAMLprim value caml_taglib_file_save(value f) {
  CAMLparam1(f);

  int ret;

  caml_release_runtime_system();
  ret = Taglib_file_val(f)->save();
  caml_acquire_runtime_system();

  CAMLreturn(Val_bool(ret));
}

CAMLprim value caml_taglib_tag_get_string(value t, value name) {
  CAMLparam2(t, name);
  CAMLlocal1(ans);
  const Tag *tag = Taglib_tag_val(t);
  const char *s = String_val(name);
  String tmp = "";

  if (!strcmp(s, "title"))
    tmp = tag->title();
  else if (!strcmp(s, "artist"))
    tmp = tag->artist();
  else if (!strcmp(s, "album"))
    tmp = tag->album();
  else if (!strcmp(s, "comment"))
    tmp = tag->comment();
  else if (!strcmp(s, "genre"))
    tmp = tag->genre();
  else
    caml_failwith("Invalid value");

  if (tmp.isEmpty())
    caml_raise_constant(*caml_named_value("taglib_exn_not_found"));

  ans = caml_copy_string(tmp.toCString(bool(true)));
  CAMLreturn(ans);
}

CAMLprim value caml_taglib_tag_get_int(value t, value name) {
  CAMLparam2(t, name);
  const Tag *tag = Taglib_tag_val(t);
  const char *s = String_val(name);
  int tmp;

  if (!strcmp(s, "year"))
    tmp = tag->year();
  else if (!strcmp(s, "track"))
    tmp = tag->track();
  else
    caml_failwith("Invalid value");

  if (tmp == 0)
    caml_raise_constant(*caml_named_value("taglib_exn_not_found"));

  CAMLreturn(Val_int(tmp));
}

CAMLprim value caml_taglib_file_get_properties(value f, value fn) {
  CAMLparam2(f, fn);
  File *file = Taglib_file_val(f);

#ifdef HAS_PROPERTIES
  PropertyMap props = file->properties();
  PropertyMap::Iterator i;
  StringList l;
  const char *key;
  StringList::Iterator j;

  for (i = props.begin(); i != props.end(); i++) {
    key = (*i).first.toCString(bool(true));
    l = (*i).second;
    for (j = l.begin(); j != l.end(); j++) {
      caml_callback2(fn, caml_copy_string(key),
                     caml_copy_string((*j).toCString(bool(true))));
    }
  }
#else
  const Tag *tag = file->tag();
  caml_callback2(fn, caml_copy_string("title"),
                 caml_copy_string(tag->title().toCString(bool(true))));
  caml_callback2(fn, caml_copy_string("artist"),
                 caml_copy_string(tag->artist().toCString(bool(true))));
  caml_callback2(fn, caml_copy_string("album"),
                 caml_copy_string(tag->album().toCString(bool(true))));
  caml_callback2(fn, caml_copy_string("comment"),
                 caml_copy_string(tag->comment().toCString(bool(true))));
  caml_callback2(fn, caml_copy_string("genre"),
                 caml_copy_string(tag->genre().toCString(bool(true))));
  char s[16];
  snprintf(s, 16, "%d", tag->year());
  caml_callback2(fn, caml_copy_string("year"), caml_copy_string(s));
  snprintf(s, 16, "%d", tag->track());
  caml_callback2(fn, caml_copy_string("track"), caml_copy_string(s));
#endif

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_file_set_properties(value f, value properties) {
  CAMLparam2(f, properties);

#ifdef HAS_PROPERTIES
  CAMLlocal1(caml_values);
  File *file = Taglib_file_val(f);
  PropertyMap props;
  const char *caml_key, *caml_val;
  StringList *values;
  String *key, *val;
  int i, j;

  for (i = 0; i < Wosize_val(properties); i++) {
    caml_key = String_val(Field(Field(properties, i), 0));
    caml_values = Field(Field(properties, i), 1);

    key = new String(caml_key, String::UTF8);
    values = new StringList();
    for (j = 0; j < Wosize_val(caml_values); j++) {
      caml_val = String_val(Field(caml_values, j));
      val = new String(caml_val, String::UTF8);
      values->append(*val);
    }

    props.insert(*key, *values);

    delete key;
    delete values;
  }

  // TODO: Catch this:
  // This default implementation sets only the tags for which
  // setter methods exist in this class (artist, album, ...), and
  // only one value per key; the rest will be contained in the
  // returned PropertyMap.
  file->setProperties(props);
#else
  caml_failwith("Not implemented with taglib < 1.8.");
#endif

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_tag_set_string(value t, value name, value v) {
  CAMLparam3(t, name, v);
  Tag *tag = Taglib_tag_val(t);
  const char *s = String_val(name);
  const char *x = String_val(v);

  if (!strcmp(s, "title"))
    tag->setTitle(String(x, String::UTF8));
  else if (!strcmp(s, "artist"))
    tag->setArtist(String(x, String::UTF8));
  else if (!strcmp(s, "album"))
    tag->setAlbum(String(x, String::UTF8));
  else if (!strcmp(s, "comment"))
    tag->setComment(String(x, String::UTF8));
  else if (!strcmp(s, "genre"))
    tag->setGenre(String(x, String::UTF8));
  else
    caml_failwith("Invalid value");

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_tag_set_int(value t, value name, value v) {
  CAMLparam3(t, name, v);
  Tag *tag = Taglib_tag_val(t);
  const char *s = String_val(name);
  int x = Int_val(v);

  if (!strcmp(s, "year"))
    tag->setYear(x);
  else if (!strcmp(s, "track"))
    tag->setTrack(x);
  else
    caml_failwith("Invalid value");

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_audioproperties_get_int(value p, value name) {
  CAMLparam2(p, name);
  const AudioProperties *prop = Taglib_audioproperties_val(p);
  const char *s = String_val(name);
  int tmp;

  if (!strcmp(s, "length"))
    tmp = prop->length();
  else if (!strcmp(s, "bitrate"))
    tmp = prop->bitrate();
  else if (!strcmp(s, "samplerate"))
    tmp = prop->sampleRate();
  else if (!strcmp(s, "channels"))
    tmp = prop->channels();
  else
    caml_failwith("Invalid value");

  CAMLreturn(Val_int(tmp));
}

/* Id3v2 support. */
class myId3v2 : public TagLib::ID3v2::Tag {
public:
  void doParse(const TagLib::ByteVector &data) { parse(data); }
};

#define Id3v2_tag_val(v) (*((myId3v2 **)Data_custom_val(v)))

static void finalize_id3v2_tag(value t) {
  myId3v2 *tag = Id3v2_tag_val(t);
  delete tag;
}

static struct custom_operations id3v2_tag_ops = {
    (char *)"ocaml_taglib_id3v2_tag", finalize_id3v2_tag,
    custom_compare_default,           custom_hash_default,
    custom_serialize_default,         custom_deserialize_default};

CAMLprim value caml_taglib_id3v2_init(value unit) {
  CAMLparam0();
  CAMLlocal1(ret);

  myId3v2 *tag = new myId3v2();

  ret = caml_alloc_custom(&id3v2_tag_ops, sizeof(ID3v2::Tag *), 1, 0);
  Id3v2_tag_val(ret) = tag;

  CAMLreturn(ret);
}

CAMLprim value caml_taglib_id3v2_header_len(value unit) {
  CAMLparam0();
  CAMLreturn(Val_int(ID3v2::Header::size()));
}

#include <id3v2synchdata.h>
#include <stdio.h>

CAMLprim value caml_taglib_id3v2_parse_header(value t, value h) {
  CAMLparam2(t, h);
  myId3v2 *tag = Id3v2_tag_val(t);
  tag->header()->setData(ByteVector(String_val(h), caml_string_length(h)));

  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_id3v2_tag_size(value t) {
  CAMLparam1(t);
  myId3v2 *tag = Id3v2_tag_val(t);
  CAMLreturn(Val_int(tag->header()->completeTagSize()));
}

CAMLprim value caml_taglib_id3v2_parse_tag(value t, value h) {
  CAMLparam2(t, h);
  myId3v2 *tag = Id3v2_tag_val(t);
  const char *s = String_val(h);
  TagLib::uint size = ID3v2::Header::size();

  tag->doParse(ByteVector(s + size, caml_string_length(h) - size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_taglib_id3v2_render(value t) {
  CAMLparam1(t);
  CAMLlocal1(ret);
  myId3v2 *tag = Id3v2_tag_val(t);
  ByteVector r = tag->render();

  ret = caml_alloc_string(r.size());
#ifdef CAML_SAFE_STRING
  memcpy(Bytes_val(ret), r.data(), r.size());
#else
  memcpy(String_val(ret), r.data(), r.size());
#endif
  CAMLreturn(ret);
}

CAMLprim value caml_taglib_id3v2_attach_frame(value t, value l, value c) {
  CAMLparam3(t, l, c);
  myId3v2 *tag = Id3v2_tag_val(t);

  ByteVector label = ByteVector(String_val(l));
  ID3v2::TextIdentificationFrame *frame =
      new ID3v2::TextIdentificationFrame(label, TagLib::String::UTF8);
  frame->setText(TagLib::String(String_val(c)));
  tag->addFrame(frame);

  CAMLreturn(Val_unit);
}
