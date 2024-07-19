{ channelName, channelUrl }:
{ self, inputs, ... }:
let
  file = builtins.fetchurl channelUrl;
  apiResponse = builtins.fromJSON (builtins.readFile file);
  release = if builtins.isList apiResponse then builtins.head apiResponse else apiResponse;
  version = release.tag_name;
in
{
  perSystem =
    {
      pkgs,
      system,
      self',
      ...
    }:
    {
      checks = {
        "hkknx-${channelName}" = self'.packages."hkknx-${channelName}";
      };
      packages = {
        "hkknx-${channelName}" = pkgs.callPackage ../packages/hkknx.nix { inherit version; };
        "docker-${channelName}" = pkgs.callPackage ../packages/docker.nix {
          hkknx = self'.packages."hkknx-${channelName}";
        };
      };
      legacyPackages = {
        "manifest-${channelName}" = inputs.flocken.legacyPackages.${system}.mkDockerManifest {
          inherit version;
          github = {
            enable = true;
            token = "$GH_TOKEN";
          };
          tags = [ channelName ];
          autoTags = {
            branch = false;
            latest = false;
          };
          annotations.org.opencontainers.image = {
            created = null;
            revision = null;
          };
          images = with self.packages; [
            x86_64-linux."docker-${channelName}"
            aarch64-linux."docker-${channelName}"
          ];
        };
      };
    };
}
