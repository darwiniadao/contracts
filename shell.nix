let
  sources = import ./nix/sources.nix;
  pkgs = import sources.dapptools { };
in
pkgs.mkShell {
  src = null;
  name = "dcdao-profile";
  buildInputs = with pkgs; [
    pkgs.dapp
    pkgs.seth
    pkgs.hevm
  ];
  LANG = "en_US.UTF-8";
}
