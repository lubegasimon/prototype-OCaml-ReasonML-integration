open Lwt
open Cohttp_lwt_unix

let root req headers =
  (* Definately set a necessary cookie *)
  let headers = Cohttp.Header.(to_list headers |> add_list Mw.Header.headers) in
  let cookies = Cohttp.Cookie.Cookie_hdr.extract (Request.headers req) in
  let session_id =
    match List.assoc_opt "session_id" cookies with Some id -> id | None -> ""
  in
  let open Mw in
  Redis.redis_conn >>= fun conn ->
  Redis.get_session ~conn ~session_id >>= function
  | Some session_data -> (
      match session_data with
      | `Assoc data ->
          let is_authenticated =
            (* TODO: user List.assoc_opt *)
            match List.assoc "is_authenticated" data with
            | `Bool b -> b
            | _ -> false
          in
          if is_authenticated then
            let body = "Logged in" in
            Server.respond_string ~headers ~status:`OK ~body ()
          else
            let body = "Welcome to expense tracker" in
            Server.respond_string ~headers ~status:`OK ~body ()
      | _ ->
          Server.respond_error ~headers ~status:`Bad_request
            ~body:"Invalid session data!" ())
  | None -> (
      Redis.create_session ~conn ~username:None ~is_authenticated:false
      >>= function
      | Ok _ ->
          let body = "Welcome to expense tracker" in
          Server.respond_string ~headers ~status:`OK ~body ()
      | Error err -> Server.respond_string ~headers ~status:`OK ~body:err ())
