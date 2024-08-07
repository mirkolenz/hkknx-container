{
  lib,
  dockerTools,
  cacert,
  tzdata,
  coreutils,
  hkknx,
}:
let
  mkCliOptions = lib.cli.toGNUCommandLine rec {
    mkOptionName = k: "--${k}";
    mkBool = k: v: [
      (mkOptionName k)
      (lib.boolToString v)
    ];
  };
  defaultOptions = mkCliOptions {
    autoupdate = false;
    verbose = false;
    db = "/db";
    port = 8080;
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
  config.entrypoint = [ (lib.getExe hkknx) ] ++ defaultOptions;
}
