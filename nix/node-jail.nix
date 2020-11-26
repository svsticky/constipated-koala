{ pkgs ? import ./. {}
}:
pkgs.stdenv.mkDerivation {
  name = "package-json-jail";
  src = ../package.json;

  phases = ["buildPhase"];
  buildPhase = ''
    mkdir -p $out
    mv $src $out/package.json
  '';
}
