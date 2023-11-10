{
  lib,
  dockerTools,
  entrypoint,
  cacert,
  tzdata,
  coreutils,
  ...
}: let
  options = {
    autoupdate = "false";
    verbose = "false";
    db = "/db";
    port = "8080";
  };
in
  dockerTools.buildLayeredImage {
    name = "hkknx";
    tag = "latest";
    created = "now";
    contents = [
      cacert
      tzdata
    ];
    # create /tmp for backup feature to work
    extraCommands = ''
      ${coreutils}/bin/mkdir -m 1777 tmp
    '';
    config = {
      entrypoint =
        [(lib.getExe entrypoint)]
        ++ (
          lib.mapAttrsToList
          (key: value: "--${key}=${value}")
          options
        );
    };
  }
