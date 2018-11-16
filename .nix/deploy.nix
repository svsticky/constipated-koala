{ pkgs, ... }:
{
  config = {
    networking.extraHosts = ''
      127.0.0.1 koala.rails.local intro.rails.local
    '';
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureUsers = [
        {
          name = "root";
          ensurePermissions = { "*.*" = "all privileges"; };
        }
        # TODO make this more fine-grained
        {
          name = "arian";
          ensurePermissions = { "*.*" = "all privileges"; };
        }
      ];
    };
  };
}
