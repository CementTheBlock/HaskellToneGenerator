{ package ? "tones", compiler ? "ghc822" }:

let
  fetchNixpkgs = import ./nix/fetchNixpkgs.nix;
  nixpkgs = fetchNixpkgs {
    rev = "c65107068edae8d7ebdeeee4298c8df6be99fec4";
    sha256 = "0hfs5b4lha97sq7nclq8jh3flj1psfnxbjdj9hclnj3v484dq4x4";
  };
  pkgs = import nixpkgs { config = {}; };
  inherit (pkgs) haskell;

  filterPredicate = p: type:
    let path = baseNameOf p; in !(

         (type == "directory" && path == ".git")
      || (type == "directory" && pkgs.lib.hasPrefix "dist"   path)
      || (type == "symlink"   && pkgs.lib.hasPrefix "result" path)
      || pkgs.lib.hasSuffix "~" path
      || pkgs.lib.hasSuffix ".o" path
      || pkgs.lib.hasSuffix ".so" path
      || pkgs.lib.hasSuffix ".nix" path);

  overrides = haskell.packages.${compiler}.override {
    overrides = self: super:
    with haskell.lib;
    with { cp = file: (self.callPackage (./nix/haskell + "/${file}.nix") {});

           build = name: path: self.callCabal2nix name (builtins.filterSource filterPredicate path) {};
         };
    {
      mkDerivation = args: super.mkDerivation (args // {
        doCheck = pkgs.lib.elem args.pname [ ];
        doHaddock = false;
      });

      tones           = build "tones" ./.;
    };
  };
in rec {
  drv = overrides.${package};
  tones = if pkgs.lib.inNixShell then drv.env else drv;
}
