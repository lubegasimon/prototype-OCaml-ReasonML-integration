open Lwt

type signup_form = { username : string; password : string }

let validate_form form =
  let open Mw.Validate in
  let username = validate_form form "username" in
  let password = validate_form form "password" in
  Result.bind username (fun username ->
      Result.bind password (fun password -> Ok { username; password }))

let signup _req headers body =
  Cohttp_lwt.Body.to_string body >>= fun body ->
  let form = Uri.query_of_encoded body in
  match validate_form form with
  | Error err ->
      Cohttp_lwt_unix.Server.respond_error ~headers ~status:`Bad_request
        ~body:err ()
  | Ok { username; _ } ->
      let body = Format.sprintf "Logged in as %s" username in
      Cohttp_lwt_unix.Server.respond_string ~headers ~status:`OK ~body ()
