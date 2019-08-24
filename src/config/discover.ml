module C = Configurator.V1

let ld_flags = ["-ltaglib"]

let has_class klass header = "
#include <" ^ header ^ ">

int main()
{
  " ^ klass ^ " *x = NULL;
  return 0;
}
"

let check_class c (klass, header, define) =
Printf.printf "%s\n%!" (has_class klass header);
  let has_class = C.c_test c (has_class klass header) ~link_flags:ld_flags in
  define, C.C_define.Value.Switch has_class

let optional_classes = [
  "TagLib::PropertyMap",      "tpropertymap.h",  "HAS_PROPERTIES";
  "TagLib::WavPack::File",    "wavpackfile.h",   "HAS_WAVPACK";
  "TagLib::Ogg::Speex::File", "speexfile.h",     "HAS_SPEEX";
  "TagLib::MP4::File",        "mp4file.h",       "HAS_MP4";
  "TagLib::ASF::File",        "asffile.h",       "HAS_ASF";
  "TagLib::TrueAudio::File",  "trueaudiofile.h", "HAS_TRUEAUDIO"
]

let () =
  C.main ~name:"taglib-pkg-config" (fun c ->
  let default : C.Pkg_config.package_conf =
    { libs   = ld_flags
    ; cflags = ["-fPIC"]
    }
  in
  let conf =
    match C.Pkg_config.get c with
    | None -> default
    | Some pc ->
       match (C.Pkg_config.query pc ~package:"taglib") with
       | None -> default
       | Some deps -> { deps with cflags = "-fPIC"::deps.cflags }
  in
  C.Flags.write_sexp "c_flags.sexp"         conf.cflags;
  C.Flags.write_sexp "c_library_flags.sexp" conf.libs);

  C.main ~name:"config.h" (fun c ->
    C.C_define.gen_header_file c ~fname:"config.h"
      (List.map (check_class c) optional_classes))
