{package ? "tones", compiler ? "ghc822"}:
(import ./default.nix {
  inherit package compiler;
}).tones
