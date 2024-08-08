let reporter ppf =
  let report src level ~over k msgf =
    let k _ =
      over ();
      k ()
    in
    let with_metadata header _tags k ppf fmt =
      Format.kfprintf k ppf
        ("%a[%a]: " ^^ fmt ^^ "\n%!")
        Logs_fmt.pp_header (level, header)
        Fmt.(styled `Magenta string)
        (Logs.Src.name src)
    in
    msgf @@ fun ?header ?tags fmt -> with_metadata header tags k ppf fmt
  in
  { Logs.report }

let log =
  Fmt_tty.setup_std_outputs ~style_renderer:`Ansi_tty ~utf_8:true ();
  Logs.set_reporter (reporter Fmt.stderr);
  Logs.set_level ~all:true (Some Logs.Debug)
