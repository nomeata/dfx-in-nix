{ rev    ? "4c2e7becf1c942553dadd6527996d25dbf5a7136"
, sha256 ? "10dzi5xizgm9b3p5k963h5mmp0045nkcsabqyarpr7mj151f6jpm"
, pkgs   ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256; }) {
    config.allowUnfree = true;
    config.allowBroken = false;
  }
}:

rec {

dfx = pkgs.stdenv.mkDerivation rec {
  pname = "dfx";
  version = "0.8.4";

  src = fetchTarball {
    url = "https://sdk.dfinity.org/downloads/dfx/${version}/x86_64-linux/dfx-${version}.tar.gz";
    sha256 = "sha256:1cigpzxpk9aksbjbc8ma1yfl295pr23xd9a6wp509wh96pm7s6ya";
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  # dfx contains other binaries that need to be patched for nixos and that are
  # extracted at runtime. So let’s make dfx extract them now, and then wrap
  # it to use these files
  installPhase = ''
    mkdir -p $out/bin
    cp -v dfx $out/bin/

    # does not work well, DFX_CONFIG_ROOT changes too much

    # export DFX_CONFIG_ROOT=$out
    # export DFX_TELEMETRY_DISABLED=1
    # autoPatchelfFile $out/bin/dfx
    # $out/bin/dfx cache show
    # $out/bin/dfx cache install
    # wrapProgram $out/bin/dfx --set DFX_CONFIG_ROOT $out --set DFX_TELEMETRY_DISABLED 1

    mv $out/bin/dfx $out/bin/.dfx-orig
    makeWrapper ${pkgs.steam.run}/bin/steam-run $out/bin/dfx \
      --add-flags $out/bin/.dfx-orig \
      --argv0 dfx
  '';
};


dfx-native = pkgs.rustPlatform.buildRustPackage {
  name = "dfx";

  src = fetchTarball {
    url = "https://github.com/dfinity/sdk/archive/refs/tags/0.8.5-beta.0.tar.gz";
    sha256 = "sha256:17gixrs4gms685y74pgb783vpvl64y2gfvn0h4crfawp163rcsb0";
  };

  cargoSha256 = "sha256:0fv7mkb2d69d8gicsybyfxrrg9gi35ar9hxvh58wr34a9vn2pm2z";

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
  ];

  DFX_ASSETS=./.;

  buildInputs = with pkgs; [
    openssl
    # llvm_10
    # llvmPackages_10.libclang
    # lmdb
  ];

  # needed for bindgen
  # LIBCLANG_PATH = "${pkgs.llvmPackages_10.libclang.lib}/lib";
  # CLANG_PATH = "${pkgs.llvmPackages_10.clang}/bin/clang";

  # needed for ic-protobuf
  # PROTOC="${pkgs.protobuf}/bin/protoc";

  # doCheck = false;

  # buildAndTestSubdir = "drun";
};


shell = pkgs.mkShell {
  buildInputs = [ dfx ];
};

}
