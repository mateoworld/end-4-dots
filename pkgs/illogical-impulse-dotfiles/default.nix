{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "illogical-impulse-dotfiles";
  version = "latest";

  src = fetchFromGitHub {
    owner = "end-4";
    repo = "dots-hyprland";
    rev = "a7f1cddd45ae02e6a2ee4178d2f1e72d00fea7f3";
    sha256 = "sha256-Hubmivb84rXpoUHEtsJOxLOGw3w06OyEtkKYsI2zuBo=";
    fetchSubmodules = true;  # needed for quickshell/ii/modules/common/widgets/shapes
  };

  dontBuild = true;
  dontPatchShebangs = true;

  installPhase = ''
    mkdir -p $out
    cp -r $src/dots/.config/. $out/
  '';

  meta = {
    description = "Illogical Impulse dotfiles from end-4/dots-hyprland";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = lib.licenses.gpl3;
  };
}
