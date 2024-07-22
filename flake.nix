{
  description = "Build sqld";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
  };

  outputs =
    { self, nixpkgs, ... }:
    {

      default = nixpkgs.legacyPackages."x86_64-linux".rustPlatform.buildRustPackage rec {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        pname = "sqld";
        version = "0.24.17";

        src = pkgs.fetchFromGitHub {
          owner = "tursodatabase";
          repo = "libsql";
          rev = "libsql-server-v${version}";
          hash = "sha256-EPvrKUXCUwbM+VU7YbeoZK4PLjh5NgYnB18sCG5Eb3I=";
        };

        cargoLock = {
          lockFile = ./Cargo.lock;
          outputHashes = {
            "console-api-0.5.0" = "sha256-MfaxtzOqyblk6aTMqJGRP+123aK0Kq7ODNp/3lehkpQ=";
            "hyper-rustls-0.24.1" = "sha256-dYN42bnbY+4+etmimrnoyzmrKvCZ05fYr1qLQFvzRTk=";
            "rheaper-0.2.0" = "sha256-u5z6J1nmUbIQjDDqqdkT0axNBOvwbFBYghYW/r1rDHc=";
            "s3s-0.10.1-dev" = "sha256-y4DZnRsQzRNsCIp6vrppZkfXSP50LCHWYrKRoIHYPik=";
          };
        };

        nativeBuildInputs = [
          pkgs.pkg-config
          pkgs.protobuf
          pkgs.rustPlatform.bindgenHook
        ];

        buildInputs = [
          pkgs.openssl
          pkgs.sqlite
          pkgs.zstd
        ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.apple_sdk.frameworks.Security ];

        env.ZSTD_SYS_USE_PKG_CONFIG = true;

        # requires a complex setup with podman for the end-to-end tests
        doCheck = false;
      };
    };
}
