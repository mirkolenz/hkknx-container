# https://nixos.wiki/wiki/Packaging/Binaries
{
  system,
  lib,
  stdenv,
  autoPatchelfHook,
  version,
}: let
  platforms = {
    x86_64-linux = "linux_amd64";
    aarch64-linux = "linux_arm64";
    x86_64-darwin = "darwin_amd64";
    aarch64-darwin = "darwin_arm64";
  };
  platform = platforms.${system};
in
  stdenv.mkDerivation rec {
    pname = "hkknx";
    inherit version;

    src = builtins.fetchurl {
      url = "https://github.com/brutella/hkknx-public/releases/download/${version}/${pname}-${version}_${platform}.tar.gz";
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
      mainProgram = pname;
      platforms = builtins.attrNames platforms;
      changelog = "https://github.com/brutella/hkknx-public/releases/tag/v${version}";
    };
  }
