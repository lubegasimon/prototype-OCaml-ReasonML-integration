open Lwt
open Redis_lwt

let redis_conn = Client.connect { host = "localhost"; port = 6379 }

let create_session ~conn ~username ~is_authenticated =
  let session_id = Header.session_id in
  let session_data =
    Yojson.to_string
    @@ `Assoc
         [
           ( "username",
             match username with
             | Some username -> `String username
             | None -> `Null );
           ("session_id", `String session_id);
           ("is_authenticated", `Bool is_authenticated);
         ]
  in
  Client.set conn session_id session_data >>= function
  | true -> Lwt.return_ok session_id
  | false -> Lwt.return_ok "Failed to create session!"

let get_session ~conn ~session_id =
  Client.get conn session_id >>= function
  | Some session_data ->
      let json_data = Yojson.Safe.from_string session_data in
      Lwt.return (Some json_data)
  | None -> Lwt.return None
