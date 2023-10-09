{
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
  meta.mainProgram = "hkknx";
}
