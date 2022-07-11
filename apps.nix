self: system:

let

  pkgs = self.packages.${system};

  apps = with pkgs; {
    aliqueit           = { type = "app"; program = "${pkgs.aliqueit}/bin/aliqueit"; };
    aliqueit-unwrapped = { type = "app"; program = "${pkgs.aliqueit-unwrapped}/bin/aliqueit"; };
    cado-nfs           = { type = "app"; program = "${pkgs.cado-nfs}/bin/cado-nfs.py"; };
    cado-nfs-client    = { type = "app"; program = "${pkgs.cado-nfs}/bin/cado-nfs-client.py"; };
    ecm                = { type = "app"; program = "${pkgs.ecm-git}/bin/ecm"; };
    ecmpy              = { type = "app"; program = "${pkgs.ecmpy}/bin/ecm.py"; };
    factmsievepy       = { type = "app"; program = "${pkgs.factmsievepy}/bin/factmsieve.py"; };
    msieve             = { type = "app"; program = "${pkgs.msieve-svn}/bin/msieve"; };
    primecount         = { type = "app"; program = "${pkgs.primecount}/bin/primecount"; };
    primesieve         = { type = "app"; program = "${pkgs.primesieve}/bin/primesieve"; };
    primesum           = { type = "app"; program = "${pkgs.primesum}/bin/primesum"; };
    yafu               = { type = "app"; program = "${pkgs.yafu}/bin/yafu"; };
    yafu-unwrapped     = { type = "app"; program = "${pkgs.yafu-unwrapped}/bin/yafu"; };
    ysieve             = { type = "app"; program = "${pkgs.ysieve}/bin/ysieve"; };
  };

in

apps
//
{
  default = apps.yafu;
}
