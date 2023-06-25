{
  lib,
  dockerTools,
  entrypoint,
  version,
  ...
}: let
  options = {
    autoupdate = "false";
    verbose = "false";
    db = "/db";
    port = "8080";
  };
  hyphen =
    if version >= "2.7.0"
    then "--"
    else "-";
in
  dockerTools.buildLayeredImage {
    name = "hkknx";
    tag = "latest";
    created = "now";
    # Create /tmp for backup feature to work
    extraCommands = ''
      mkdir tmp
    '';
    config = {
      entrypoint =
        [(lib.getExe entrypoint)]
        ++ (
          lib.mapAttrsToList
          (name: value: "${hyphen}${name}=${value}")
          options
        );
    };
  }
