module C = Configurator.V1

let check_class_code =
  Printf.sprintf {|
#include <%s>

int main()
{
  %s *x = NULL;
  return 0;
}
|}

let () =
  C.main ~name:"taglib-pkg-config" (fun c ->
      let default : C.Pkg_config.package_conf =
        { libs = ["-ltaglib"; "-lstdc++"]; cflags = ["-fPIC"] }
      in
      let conf =
        match C.Pkg_config.get c with
          | None -> default
          | Some pc -> (
              match
                C.Pkg_config.query_expr_err pc ~package:"taglib"
                  ~expr:"taglib >= 1.6"
              with
                | Error msg -> failwith msg
                | Ok deps -> deps )
      in
      C.Flags.write_sexp "c_flags.sexp" ("-fPIC" :: conf.cflags);
      C.Flags.write_sexp "c_library_flags.sexp" ("-lstdc++" :: conf.libs);

      let has_properties =
        C.c_test
          ~c_flags:(["-x"; "c++"] @ conf.cflags)
          ~link_flags:conf.libs c
          (check_class_code "tpropertymap.h" "TagLib::PropertyMap")
      in
      let has_wavpack =
        C.c_test
          ~c_flags:(["-x"; "c++"] @ conf.cflags)
          ~link_flags:conf.libs c
          (check_class_code "wavpackfile.h" "TagLib::WavPack::File")
      in
      let has_speex =
        C.c_test
          ~c_flags:(["-x"; "c++"] @ conf.cflags)
          ~link_flags:conf.libs c
          (check_class_code "speexfile.h" "TagLib::Ogg::Speex::File")
      in
      let has_mp4 =
        C.c_test
          ~c_flags:(["-x"; "c++"] @ conf.cflags)
          ~link_flags:conf.libs c
          (check_class_code "mp4file.h" "TagLib::MP4::File")
      in
      let has_asf =
        C.c_test
          ~c_flags:(["-x"; "c++"] @ conf.cflags)
          ~link_flags:conf.libs c
          (check_class_code "asffile.h" "TagLib::ASF::File")
      in
      let has_trueaudio =
        C.c_test
          ~c_flags:(["-x"; "c++"] @ conf.cflags)
          ~link_flags:conf.libs c
          (check_class_code "trueaudiofile.h" "TagLib::TrueAudio::File")
      in

      C.C_define.gen_header_file c ~fname:"config.h"
        [
          ("HAS_PROPERTIES", Switch has_properties);
          ("HAS_WAVPACK", Switch has_wavpack);
          ("HAS_SPEEX", Switch has_speex);
          ("HAS_MP4", Switch has_mp4);
          ("HAS_ASF", Switch has_asf);
          ("HAS_TRUEAUDIO", Switch has_trueaudio);
        ])
