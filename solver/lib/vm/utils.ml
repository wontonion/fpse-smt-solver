open Core

let replace_non_alphanumeric (chars : char list) : char list =
  List.map chars ~f:(fun c ->
      if Char.is_alphanum c || Char.equal c '-' then c else ' ')

let list_words (s : string) : string list =
  s |> String.uppercase |> String.to_list |> replace_non_alphanumeric
  |> String.of_list |> String.split ~on:' '
  |> List.filter ~f:(fun s -> not (String.is_empty s))
