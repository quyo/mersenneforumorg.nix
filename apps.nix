{ aliqueit
, aliqueit-unwrapped
, cado-nfs
, ecm-git
, ecmpy
, factmsievepy
, msieve-svn
, primecount
, primesieve
, primesum
, yafu
, yafu-unwrapped
, ysieve
}:

let
  apps = {
    aliqueit = { type = "app"; program = "${aliqueit}/bin/aliqueit"; };
    aliqueit-unwrapped = { type = "app"; program = "${aliqueit-unwrapped}/bin/aliqueit"; };
    cado-nfs = { type = "app"; program = "${cado-nfs}/bin/cado-nfs.py"; };
    cado-nfs-client = { type = "app"; program = "${cado-nfs}/bin/cado-nfs-client.py"; };
    ecm = { type = "app"; program = "${ecm-git}/bin/ecm"; };
    ecmpy = { type = "app"; program = "${ecmpy}/bin/ecm.py"; };
    factmsievepy = { type = "app"; program = "${factmsievepy}/bin/factmsieve.py"; };
    msieve = { type = "app"; program = "${msieve-svn}/bin/msieve"; };
    # primecount = { type = "app"; program = "${primecount}/bin/primecount"; };
    # primesieve = { type = "app"; program = "${primesieve}/bin/primesieve"; };
    # primesum = { type = "app"; program = "${primesum}/bin/primesum"; };
    yafu = { type = "app"; program = "${yafu}/bin/yafu"; };
    yafu-unwrapped = { type = "app"; program = "${yafu-unwrapped}/bin/yafu"; };
    ysieve = { type = "app"; program = "${ysieve}/bin/ysieve"; };
  };
in

apps //
{
  default = apps.yafu;
}
