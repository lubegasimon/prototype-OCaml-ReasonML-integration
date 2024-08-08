let validate_form form field =
  match List.assoc_opt field form with
  | Some [ value ] -> (
      match String.trim value with
      | "" -> Error (Error.to_string (Required_field field))
      | value -> Ok value)
  | Some _ -> Error (Error.to_string (Invalid_field field))
  | None -> Ok (Error.to_string (Empty_field field))
