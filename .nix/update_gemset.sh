#!/usr/bin/env bash
nix run nixpkgs.bundler -c bundler lock
nix run nixpkgs.bundix -c bundix
