open Cohttp_lwt_unix

let root req headers =
  let cookies = Cohttp.Cookie.Cookie_hdr.extract (Request.headers req) in
  let session_id = List.assoc_opt "session_id" cookies in
  match session_id with
  | Some _ ->
      let body = "Logged in" in
      Server.respond_string ~headers ~status:`OK ~body ()
  | None ->
      let body = "Welcome to expense tracker" in
      Server.respond_string ~headers ~status:`OK ~body ()
