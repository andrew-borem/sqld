{
  description = "Build sqld";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
  };

  outputs =
    { self, nixpkgs, ... }:
    {

      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      default = self.pkgs.rustPlatform.buildRustPackage rec {
        pname = "sqld";
        version = "0.24.17";

        src = builtins.fetchGit {
          url = "https://github.com/tursodatabase/libsql/";
          ref = "main";
          rev = "6122f5e5b7d1746c48cb6442e798ed320a3da2d0";
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
          self.pkgs.pkg-config
          self.pkgs.protobuf
          self.pkgs.rustPlatform.bindgenHook
        ];

        buildInputs =
          [
            self.pkgs.openssl
            self.pkgs.sqlite
            self.pkgs.zstd
          ]
          ++ self.pkgs.lib.optionals self.pkgs.stdenv.isDarwin [
            self.pkgs.darwin.apple_sdk.frameworks.Security
          ];

        env.ZSTD_SYS_USE_PKG_CONFIG = true;

        # requires a complex setup with podman for the end-to-end tests
        doCheck = false;
      };
    };
}
