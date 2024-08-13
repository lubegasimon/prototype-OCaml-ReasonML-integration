open Lwt
open Cohttp_lwt_unix

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

let server =
  Lwt.catch
    (fun () ->
      (*FIXME: this is not printed on terminal when the server starts *)
      let server =
        Server.create ~mode:(`TCP (`Port 8000)) (Server.make ~callback ())
      in
      server >>= fun _ ->
      Format.printf "Server listening on port 8000\n" |> Lwt.return)
    (function
      | Unix.Unix_error (err, func, arg) ->
          Lwt_io.eprintf "Error starting server: %s in %s(%s)"
            (Unix.error_message err) func arg
      | exn -> Lwt_io.eprintlf "Unexpected error: %s" (Printexc.to_string exn))

let () =
  Log.log;
  Lwt_main.run (Lwt_io.printf "Application starting...\n" >>= fun () -> server)
