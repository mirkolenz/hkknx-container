{
  lib,
  stdenv,
  asset,
  ...
}:
stdenv.mkDerivation {
  name = "hkknx";
  src = builtins.fetchurl {
    url = asset.browser_download_url;
  };
  phases = ["unpackPhase" "installPhase"];
  sourceRoot = ".";
  installPhase = ''
    install -D hkknx $out/bin/hkknx
  '';
  meta = {
    description = "HomeKit Bridge for KNX";
    homepage = "https://hochgatterer.me/hkknx";
    downloadPage = "https://github.com/brutella/hkknx-public/releases";
    license = lib.licenses.unfree;
    mainProgram = "hkknx";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
