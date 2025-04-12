{
  case = fun cond value =>
    if cond then
      value
    else
      (
        if std.is_array value then
          []
        else if std.is_record then
          {}
        else if std.is_number then
          0
        else if std.is_string then
          ""
        else
          std.fail_with "invalid value type: %{std.typeof value}"
      ),
  sops_placeholder = fun name => "<SOPS:%{std.hash 'Sha256 name}:PLACEHOLDER>",
  placeholder = fun name => "<PLACEHOLDER:%{name}>",
  rawplaceholder = fun name => "<RAW-PLACEHOLDER:%{name}>",
}
