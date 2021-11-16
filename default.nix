{ sources ? import ./nix
}:
let
  pkgs = sources.nixpkgs {};
  gitignore = sources.gitignore{ lib = pkgs.lib; };
  node = import ./nix/node.nix { inherit pkgs; };
  gems = pkgs.bundlerEnv {
    name = "koala";
    ruby = pkgs.ruby;
    gemdir = ./.;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemConfig = pkgs.defaultGemConfig // {
      mimemagic = attrs: {
        FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
      };
    };
  };
  node-path = "${(node.shell.override{src = node-jail;}).nodeDependencies}/lib/node_modules";
  node-jail = import ./nix/node-jail.nix {};
in
  pkgs.stdenv.mkDerivation {
    name = "koala";
    propagatedBuildInputs = with pkgs; [
      shared-mime-info
      gems
      nodejs
      ruby
      curl
      imagemagick
      ghostscript
      mupdf
      cacert
      bundler
      yarn
      postgresql_13
      jq
      nodePackages.node2nix
    ];

    rails_wrapper = pkgs.writeScript "rails" ''
      #!${pkgs.ruby}/bin/ruby
      APP_PATH = File.expand_path('../config/application', __dir__)
      require_relative '../config/boot'
      require 'rails/commands'
    '';

    buildPhase = ''
      ln -s -f ${node-path} node_modules
      rm bin/rails
      cp $rails_wrapper bin/rails
      bundle exec "bin/rails assets:precompile"
    '';

    koala_rails_wrapper = pkgs.writeScript "koala" ''
      #!/bin/bash
      export NODE_PATH=${node-path}
      ${gems.wrappedRuby}/bin/bundle exec rails $@
    '';

    installPhase = ''
      ln -s $koala_rails_wrapper /build/constipated-koala/bin/koala
      mv /build/constipated-koala $out
    '';

    src = builtins.path {
      name = "constipated-koala";
      path = ./.;
      filter = gitignore.gitignoreFilter ./.;
    };

    NODE_PATH = node-path;

    shellHook = ''
      if [[ ( ! -e node_modules ) || ( -h node_modules ) ]]; then
        rm node_modules
        ln -sf ${node-path} node_modules
      else
        echo "Existing node_modules directory detected, please remove this and restart your nix-shell"
      fi
    '';

    LC_ALL = "C.UTF-8";
  }
