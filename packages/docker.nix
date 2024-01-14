{
  lib,
  dockerTools,
  cacert,
  tzdata,
  coreutils,
  hkknx,
  hkknxOptions ? {
    autoupdate = false;
    verbose = false;
    db = "/db";
    port = 8080;
  },
}: let
  mkCliOptions = lib.cli.toGNUCommandLine rec {
    mkOptionName = k: "--${k}";
    mkBool = k: v: [(mkOptionName k) (lib.boolToString v)];
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
    config.entrypoint =
      (lib.singleton (lib.getExe hkknx))
      ++ (mkCliOptions hkknxOptions);
  }
