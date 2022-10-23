{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-filter.url = "github:numtide/nix-filter";
  };
  # dev
  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: (
    flake-utils.lib.eachDefaultSystem (
      system: let
        inherit (pkgs) lib;
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = with inputs; [
            nix-filter.overlays.default
            devshell.overlay
          ];
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "CCFinderSW-build";
          version = "1.0";
          src = pkgs.nix-filter {
            root = ./.;
            include = with pkgs.nix-filter; [
              "build.gradle"
              "settings.gradle"
              (inDirectory "src")
              (inDirectory "lib")
            ];
          };

          nativeBuildInputs = with pkgs; [
            unzip
            gradle_4
          ];
          buildInputs = with pkgs; [
            jdk8
          ];
          buildPhase = ''
            gradle distZip
          '';
          installPhase = ''
            unzip ./build/distributions/CCFinderSW-1.0.zip
            cp -r ./CCFinderSW-1.0 $out
          '';
        };

        devShells.default = pkgs.devshell.mkShell {
          packages = (
            with pkgs; [
              jdk8
              gradle_4
            ]
          );
        };
      }
    )
  );
}
