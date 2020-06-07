let usage = "usage: tagutil [ -s ]"

type mode = Strip | Generate

let strip = ref false
let args = [("-s", Arg.Set strip, "Switch to strip mode.")]

let gen_tag () =
  let tag = Taglib.Inline.Id3v2.init () in
  let tag = Taglib.Inline.Id3v2.attach_frame tag "TSSE" "tagutil example" in
  let read tag =
    Taglib.Inline.Id3v2.attach_frame tag (read_line ()) (read_line ())
  in
  let rec f tag = try f (read tag) with _ -> tag in
  let tag = f tag in
  output_string stdout (Taglib.Inline.Id3v2.render tag)

let strip_tag () =
  let buf = Buffer.create 1024 in
  let tmp = Bytes.create 1024 in
  while Buffer.length buf < Taglib.Inline.Id3v2.header_size do
    let ret = input stdin tmp 0 Taglib.Inline.Id3v2.header_size in
    Buffer.add_subbytes buf tmp 0 ret
  done;
  let tag_size =
    try
      let t = Taglib.Inline.Id3v2.init () in
      let t = Taglib.Inline.Id3v2.parse_header t (Buffer.contents buf) in
      Taglib.Inline.Id3v2.tag_size t
    with _ -> 0
  in
  while Buffer.length buf < tag_size do
    let ret = input stdin tmp 0 tag_size in
    Buffer.add_subbytes buf tmp 0 ret
  done;
  let len = Buffer.length buf in
  output_string stdout (Buffer.sub buf tag_size (len - tag_size));
  let rec f () =
    let ret = input stdin tmp 0 1024 in
    if ret > 0 then begin
      output_bytes stdout (Bytes.sub tmp 0 ret);
      f ()
    end
  in
  f ()

let () =
  Arg.parse args ignore usage;
  if !strip then strip_tag () else gen_tag ()
