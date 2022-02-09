let () =
  let fname = Sys.argv.(1) in
  let f = Taglib.File.open_file `Autodetect fname in
  let prop = Taglib.File.properties f in
  Hashtbl.iter
    (fun t v ->
      let v = String.concat " / " v in
      Printf.printf " - %s : %s\n%!" t v)
    prop;
  Hashtbl.replace prop "PUBLISHER" ["foobarlol"];
  Taglib.File.set_properties f prop;
  Taglib.tag_set_title f "Some title";
  ignore (Taglib.File.file_save f);
  Taglib.File.close_file f
