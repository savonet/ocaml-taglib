let () =
  let fname = Sys.argv.(1) in
  let f = Taglib.File.open_file `Autodetect fname in
  let prop = Taglib.tag_properties f in
  Hashtbl.iter
    (fun t v ->
      let v = String.concat " / " v in
      Printf.printf " - %s : %s\n%!" t v)
    prop;
  Taglib.File.close_file f
