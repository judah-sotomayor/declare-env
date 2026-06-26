{
  description = "declare-env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
  let
    allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    lib = nixpkgs.lib;
    forAllSystems = f: lib.genAttrs allSystems
      (system: f {
        pkgs = import nixpkgs {
          inherit system;
        };
      });

  in {
    devShells = forAllSystems ({pkgs}:  {
      default = pkgs.mkShell {
        packages = with pkgs; [
          sbcl
        ];
      };
    });
  };
}
