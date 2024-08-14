open Caqti_type
open Caqti_request.Infix

module type Conn = Caqti_lwt.CONNECTION

let create_user (module Db : Conn) =
  let query =
    (tup2 string string ->* tup2 string string)
    @@ {|
    INSERT INTO users (username, password)
    VALUES (?, ?) RETURNING *
  |}
  in
  Db.collect_list query
