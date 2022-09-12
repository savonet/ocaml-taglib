let () =
  let fname = Sys.argv.(1) in
  let f = Taglib.File.open_file `Autodetect fname in
  let t fn f = try fn f with _ -> "(none)" in
  let td fn f = try string_of_int (fn f) with _ -> "(none)" in
  Taglib.(
    Printf.printf
      "Track: %s, Artist: %s, Title: %s, Album: %s, Comment: %s, Genre: %s, \
       Year: %s\n\
       %!"
      (td tag_track f) (t tag_artist f) (t tag_title f) (t tag_album f)
      (t tag_comment f) (t tag_genre f) (td tag_year f));
  Taglib.File.close_file f
