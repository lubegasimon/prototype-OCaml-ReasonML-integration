open Cohttp_lwt_unix
open Lwt

let sanitize_path path =
  let segments = String.split_on_char '/' path in
  List.filter (fun seg -> seg <> "") segments

let headers =
  Cohttp.Header.of_list
    [
      ("Access-Control-Allow-Origin", "*");
      ("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      ("Access-Control-Allow-Headers", "Content-Type");
    ]

let callback _conn req body =
  let uri = Request.uri req in
  let path = Uri.path uri in
  Lwt_io.printf "The path is %s\n" path >>= fun () ->
  let method_ = Request.meth req in
  match method_ with
  | `OPTIONS -> Server.respond_string ~headers ~status:`OK ~body:"" ()
  | `POST -> (
      match sanitize_path path with
      | [ "signup" ] -> Signup.signup req headers body
      | _ ->
          Server.respond_string ~headers ~status:`Not_found ~body:"Not found" ()
      )
  | _ -> Server.respond_string ~headers ~status:`Not_found ~body:"Not found" ()

let server = Server.create ~mode:(`TCP (`Port 8000)) (Server.make ~callback ())

let () =
  Log.log;
  Lwt_main.run (Lwt_io.printf "Application starting...\n" >>= fun () -> server)
