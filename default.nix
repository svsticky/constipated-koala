{ sources ? import ./nix
}:
let
  pkgs = sources.nixpkgs {};
  gitignore = sources.gitignore{ lib = pkgs.lib; };
  node = import ./nix/node.nix {};
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
      nokogiri = attrs: {
        # Stolen from nixpkgs 21.05 branch, can be removed after upgrade
        buildFlags = [
          "--use-system-libraries"
          "--with-zlib-lib=${pkgs.zlib.out}/lib"
          "--with-zlib-include=${pkgs.zlib.dev}/include"
          "--with-xml2-lib=${pkgs.libxml2.out}/lib"
          "--with-xml2-include=${pkgs.libxml2.dev}/include/libxml2"
          "--with-xslt-lib=${pkgs.libxslt.out}/lib"
          "--with-xslt-include=${pkgs.libxslt.dev}/include"
          "--with-exslt-lib=${pkgs.libxslt.out}/lib"
          "--with-exslt-include=${pkgs.libxslt.dev}/include"
        ];
      };
    };
  };
  node-path = "${(node.shell.override{src = node-jail;}).nodeDependencies}/lib/node_modules";
  node-jail = import ./nix/node-jail.nix {};
in
  pkgs.stdenv.mkDerivation {
    name = "koala";
    propagatedBuildInputs = [
      pkgs.shared-mime-info
      gems
      pkgs.nodejs
      pkgs.ruby
      pkgs.curl
      pkgs.imagemagick
      pkgs.ghostscript
      pkgs.mupdf
      pkgs.cacert
      pkgs.bundler
      pkgs.yarn
      pkgs.postgresql_13
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
        dotenv rails assets:precompile
      else
        echo "Existing node_modules directory detected, please remove this and restart your nix-shell"
      fi
    '';

    LC_ALL = "C.UTF-8";
  }
