# https://nixos.wiki/wiki/Packaging/Binaries
{
  lib,
  stdenv,
  autoPatchelfHook,
  version,
}: let
  inherit (stdenv.hostPlatform) system;
  platforms = {
    x86_64-linux = "linux_amd64";
    aarch64-linux = "linux_arm64";
    x86_64-darwin = "darwin_amd64";
    aarch64-darwin = "darwin_arm64";
  };
  platform = platforms.${system};
  pname = "hkknx";
  repo = "https://github.com/brutella/hkknx-public";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = builtins.fetchurl "${repo}/releases/download/${version}/${pname}-${version}_${platform}.tar.gz";

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
      downloadPage = "${repo}/releases";
      mainProgram = pname;
      platforms = builtins.attrNames platforms;
      changelog = "${repo}/releases/tag/${version}";
      maintainers = with lib.maintainers; [mirkolenz];
    };
  }
