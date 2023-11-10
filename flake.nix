{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    flocken = {
      url = "github:mirkolenz/flocken/v2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    systems,
    flocken,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import systems;
      perSystem = {
        pkgs,
        system,
        lib,
        self',
        ...
      }: let
        releases = {
          latest = "https://api.github.com/repos/brutella/hkknx-public/releases/latest";
          pre = "https://api.github.com/repos/brutella/hkknx-public/releases?per_page=1";
        };
        mkRelease = channel: url: let
          file = builtins.fetchurl {
            inherit url;
          };
          apiResponse = builtins.fromJSON (builtins.readFile file);
          release =
            if builtins.isList apiResponse
            then builtins.head apiResponse
            else apiResponse;
          version = release.tag_name;
        in {
          packages = {
            "hkknx-${channel}" = pkgs.callPackage ./hkknx.nix {
              inherit version;
            };
            "docker-${channel}" = pkgs.callPackage ./docker.nix {
              entrypoint = self'.packages."hkknx-${channel}";
            };
          };
          legacyPackages = {
            "manifest-${channel}" = flocken.legacyPackages.${system}.mkDockerManifest {
              inherit version;
              github = {
                enable = true;
                token = builtins.getEnv "GH_TOKEN";
              };
              tags = [channel];
              autoTags = {
                branch = false;
                latest = false;
              };
              annotations.org.opencontainers.image = {
                created = null;
                revision = null;
              };
              images = with self.packages; [x86_64-linux."docker-${channel}" aarch64-linux."docker-${channel}"];
            };
          };
        };
      in
        builtins.foldl'
        lib.recursiveUpdate
        {
          formatter = pkgs.alejandra;
          packages.default = self'.packages.hkknx-latest;
          apps.manifest = {
            type = "app";
            program = lib.getExe (pkgs.writeShellApplication {
              name = "manifest";
              text = lib.concatLines (
                lib.mapAttrsToList
                (channel: _: (lib.getExe self'.legacyPackages."manifest-${channel}"))
                releases
              );
            });
          };
        }
        (lib.mapAttrsToList mkRelease releases);
    };
}
