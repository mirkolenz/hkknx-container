{
  lib,
  dockerTools,
  entrypoint,
  cacert,
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
    # https://shivjm.blog/perfect-docker-images-for-rust-with-nix/#4-addendum-ca-certificates-for-tls
    # https://gist.github.com/CMCDragonkai/1ae4f4b5edeb021ca7bb1d271caca999
    contents = [
      cacert
    ];
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
