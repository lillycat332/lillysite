let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  # Workaround for https://github.com/NixOS/nixpkgs/issues/140774
  fixCyclicReference = drv:
    pkgs.haskell.lib.overrideCabal drv (_: {
      enableSeparateBinOutput = false;
    });
  hpkgs = pkgs.haskellPackages;
  hls = fixCyclicReference hpkgs.haskell-language-server;
  # packages' = map fixCyclicReference packages;
in
pkgs.mkShell {
  buildInputs = [
    hls
    pkgs.zlib
    pkgs.ghc
    pkgs.cabal-install
  ];
}
