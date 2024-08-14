open Lwt
open Cohttp_lwt_unix

type signup_form = { username : string; password : string }

let validate_form form =
  let open Mw.Validate in
  let username = validate_form form "username" in
  let password = validate_form form "password" in
  Result.bind username (fun username ->
      Result.bind password (fun password -> Ok { username; password }))

let signup headers body =
  let headers = Cohttp.Header.(to_list headers |> add_list Mw.Header.headers) in
  Cohttp_lwt.Body.to_string body >>= fun body ->
  let form = Uri.query_of_encoded body in
  match validate_form form with
  | Error err -> Server.respond_error ~headers ~status:`Bad_request ~body:err ()
  | Ok { username; password; _ } -> (
      Db.with_connection
        (fun conn -> Model.User.create_user conn (username, password))
        "DATABASE_URI"
      >>= function
      | Ok _ ->
          let _body = Format.sprintf "Logged in as %s" username in
          Server.respond_redirect ~headers ~uri:(Uri.of_string "/") ()
      | Error err ->
          Server.respond_error ~headers ~status:`Internal_server_error
            ~body:(Mw.Error.to_string (Database_error err))
            ())
