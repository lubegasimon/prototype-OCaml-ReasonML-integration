open Lwt
open Cohttp_lwt_unix

type signup_form = { username : string; password : string }

let validate_form form =
  let open Mw.Validate in
  let username = validate_form form "username" in
  let password = validate_form form "password" in
  Result.bind username (fun username ->
      Result.bind password (fun password -> Ok { username; password }))

let signup req headers body =
  let headers = Cohttp.Header.(to_list headers |> add_list Mw.Header.headers) in
  Cohttp_lwt.Body.to_string body >>= fun body ->
  let form = Uri.query_of_encoded body in
  let cookies = Cohttp.Cookie.Cookie_hdr.extract (Request.headers req) in
  let open Mw in
  match List.assoc_opt "session_id" cookies with
  | Some _ -> (
      match validate_form form with
      | Error err ->
          Server.respond_error ~headers ~status:`Bad_request ~body:err ()
      | Ok { username; password } -> (
          Db.with_connection
            (fun conn -> Model.User.create_user conn (username, password))
            "DATABASE_URI"
          >>= function
          | Ok _ -> (
              Mw.Redis.redis_conn >>= fun conn ->
              (* TODO: I think at this point we are instead supposed to update session data
                 that was served to the user on visiting the home...with username and email.
                 Perhaps it's is true that the user directly visited the signup page *)
              Mw.Redis.create_session ~conn ~username:(Some username)
                ~is_authenticated:true
              >>= function
              | Ok _ ->
                  Server.respond_redirect ~headers ~uri:(Uri.of_string "/") ()
              | Error err ->
                  Server.respond_error ~headers ~status:`Internal_server_error
                    ~body:err ())
          | Error err ->
              Server.respond_error ~headers ~status:`Internal_server_error
                ~body:(Mw.Error.to_string (Database_error err))
                ()))
  | None -> (
      (* Because of the necessary cookie that was a home visit, we guarantee this branch never to run.
         However, TODO: Handle a scenario visitor visits the signup page without being redirected from home,
         that is when they directly hit 'example.com/signup' *)
      Redis.redis_conn
      >>= fun conn ->
      Redis.create_session ~conn ~username:None ~is_authenticated:false
      >>= function
      | Ok _ ->
          (* TODO: problematic *)
          Server.respond_redirect ~headers ~uri:(Uri.of_string "/signup") ()
      | Error err ->
          Server.respond_error ~headers ~status:`Internal_server_error ~body:err
            ())
