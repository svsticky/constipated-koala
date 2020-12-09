{ pkgs ? import ./. {}
}:
pkgs.stdenv.mkDerivation {
  name = "package-json-jail";
  src = ../package.json;

  phases = ["buildPhase"];
  buildPhase = ''
    mkdir -p $out
    cp $src $out/package.json
  '';
}
