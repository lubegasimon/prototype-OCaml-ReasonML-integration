type error =
  | Empty_field of string
  | Required_field of string
  | Invalid_field of string

let to_string = function
  | Empty_field field -> Format.sprintf "Field %s is empty!" field
  | Required_field field -> Format.sprintf "Field %s is required!" field
  | Invalid_field field -> Format.sprintf "Field %s is invalid!" field
