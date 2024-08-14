open Lwt

let uri db_uri =
  match Sys.getenv_opt db_uri with
  | Some uri -> Uri.of_string uri
  | None -> Uri.of_string "Postgresql://"

(* establishes a database connection *)
let connect db_uri = Caqti_lwt.connect (uri db_uri)

(* passes a database connection to a client [f] *)
let with_connection f db_uri =
  connect db_uri >>= function
  | Ok conn -> f conn
  | Error err -> Lwt.return (Error err)
