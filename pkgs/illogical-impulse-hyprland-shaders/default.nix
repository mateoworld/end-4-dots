{ lib, fetchFromGitHub, stdenv }:

stdenv.mkDerivation {
  pname = "illogical-impulse-hyprland-shaders";
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
    if [ -d $src/dots/.config/hypr/shaders ]; then
      cp -r $src/dots/.config/hypr/shaders/. $out/
    fi
    runHook postInstall
  '';

  meta = {
    description = "Hyprland Shaders from end-4/dots-hyprland";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = lib.licenses.gpl3;
  };
}
