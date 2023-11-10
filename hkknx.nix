# https://nixos.wiki/wiki/Packaging/Binaries
{
  lib,
  stdenv,
  autoPatchelfHook,
  asset,
  version,
  ...
}:
stdenv.mkDerivation {
  name = "hkknx";
  inherit version;

  src = builtins.fetchurl {
    url = asset.browser_download_url;
  };

  nativeBuildInputs = lib.optional (!stdenv.isDarwin) autoPatchelfHook;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -m755 -D hkknx $out/bin/hkknx
    runHook postInstall
  '';

  meta = {
    description = "HomeKit Bridge for KNX";
    homepage = "https://hochgatterer.me/hkknx";
    downloadPage = "https://github.com/brutella/hkknx-public/releases";
    mainProgram = "hkknx";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    changelog = "https://github.com/brutella/hkknx-public/releases/tag/v${version}";
  };
}
