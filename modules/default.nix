{ lib, ... }:
let
  channels = {
    latest = "https://api.github.com/repos/brutella/hkknx-public/releases/latest";
    pre = "https://api.github.com/repos/brutella/hkknx-public/releases?per_page=1";
  };
  mkChannel = channelName: channelUrl: import ./channel.nix { inherit channelName channelUrl; };
in
{
  imports = lib.mapAttrsToList mkChannel channels;
  perSystem =
    {
      pkgs,
      system,
      self',
      ...
    }:
    {
      formatter = pkgs.alejandra;
      packages.default = self'.packages.hkknx-latest;
      apps.manifest = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "manifest";
          text = lib.concatLines (
            lib.mapAttrsToList (
              channelName: _: (lib.getExe self'.legacyPackages."manifest-${channelName}")
            ) channels
          );
        };
      };
    };
}
