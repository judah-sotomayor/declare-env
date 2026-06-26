{
  description = "declare-env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cl-nix-lite.url = "github:hraban/cl-nix-lite/v0";
  };

  outputs = { nixpkgs, cl-nix-lite, ... }:
  let
    allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    lib = nixpkgs.lib;
    forAllSystems = f: lib.genAttrs allSystems
      (system: f {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            cl-nix-lite.overlays.default
          ];
        };
      });

  in {
    devShells = forAllSystems ({pkgs}:  {
      default = with pkgs.lispPackagesLite;
        lispDerivation {
          src = pkgs.lib.cleanSource ./.;
          lispSystems = [ "" ];
          lispDependencies = [ serapeum ];
          lispCheckDependencies = [ fiasco ];
        };
    });
  };
}
