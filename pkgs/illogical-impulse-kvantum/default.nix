{ lib, fetchFromGitHub, stdenv }:

stdenv.mkDerivation {
  pname = "illogical-impulse-kvantum";
  version = "latest";

  src = fetchFromGitHub {
    owner = "end-4";
    repo = "dots-hyprland";
    rev = "a7f1cddd45ae02e6a2ee4178d2f1e72d00fea7f3";
    sha256 = "sha256-Hubmivb84rXpoUHEtsJOxLOGw3w06OyEtkKYsI2zuBo=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r $src/dots/.config/Kvantum/. $out/
    runHook postInstall
  '';

  postInstall = ''
    chmod -R +w $out/MaterialAdw
    mv $out/MaterialAdw/MaterialAdw.svg $out/MaterialAdw/MaterialAdw.svg.sample
    mv $out/MaterialAdw/MaterialAdw.kvconfig $out/MaterialAdw/MaterialAdw.kvconfig.sample
  '';

  meta = {
    description = "Kvantum theme from end-4/dots-hyprland";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = lib.licenses.gpl3;
  };
}
