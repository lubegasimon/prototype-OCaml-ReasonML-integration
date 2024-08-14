type error =
  | Empty_field of string
  | Required_field of string
  | Invalid_field of string
  | Database_error of Caqti_error.t

let to_string = function
  | Empty_field field -> Format.sprintf "Field %s is empty!" field
  | Required_field field -> Format.sprintf "Field %s is required!" field
  | Invalid_field field -> Format.sprintf "Field %s is invalid!" field
  | Database_error err ->
      Format.sprintf "Database error: %s\n" (Caqti_error.show err)
