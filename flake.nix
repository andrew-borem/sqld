{
  description = "Build sqld";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
  };

  outputs =
    { self, nixpkgs, ... }:
    {

      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      sqld = self.pkgs.rustPlatform.buildRustPackage rec {
        pname = "sqld";
        version = "0.24.17";

        src = self.pkgs.fetchFromGitHub {
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
          self.pkgs.pkg-config
          self.pkgs.protobuf
          self.pkgs.rustPlatform.bindgenHook
          self.pkgs.sqlite
          self.pkgs.cmake
          self.pkgs.libclang
        ];

        buildInputs =
          [ self.pkgs.openssl ]
          ++ self.pkgs.lib.optionals self.pkgs.stdenv.isDarwin [
            self.pkgs.darwin.apple_sdk.frameworks.Security
          ];

        # requires a complex setup with podman for the end-to-end tests
        doCheck = false;
      };
      /*
            php-extension = self.pkgs.rustPlatform.buildRustPackage rec {
              pname = "sqld";
              version = "0.24.17";

              src = self.pkgs.fetchFromGitHub {
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
                self.pkgs.pkg-config
                self.pkgs.protobuf
                self.pkgs.rustPlatform.bindgenHook
                self.pkgs.sqlite
                self.pkgs.cmake
                self.pkgs.libclang
              ];

              buildInputs =
                [ self.pkgs.openssl ]
                ++ self.pkgs.lib.optionals self.pkgs.stdenv.isDarwin [
                  self.pkgs.darwin.apple_sdk.frameworks.Security
                ];

              # requires a complex setup with podman for the end-to-end tests
              doCheck = false;
            };
      */
      cli = self.pkgs.buildGoModule rec {
        pname = "turso-cli";
        version = "0.96.2";

        src = self.pkgs.fetchFromGitHub {
          owner = "tursodatabase";
          repo = "turso-cli";
          rev = "v${version}";
          hash = "sha256-G8rYCjGkk0/bVnp0A74HIduYuC5lLvlzAoaOLaQfhG4=";
        };

        vendorHash = "sha256-G8rYCjGkk0/bVnp0A74HIduYuC5lLvlzAoaOLaQfhG4=";

        nativeBuildInputs = [ self.pkgs.installShellFiles ];

        ldflags = [ "-X github.com/tursodatabase/turso-cli/internal/cmd.version=v${version}" ];

        preCheck = ''
          export HOME=$(mktemp -d)
        '';

        postInstall = self.pkgs.lib.optionalString (self.pkgs.stdenv.buildPlatform.canExecute self.pkgs.stdenv.hostPlatform) ''
          installShellCompletion --cmd turso \
            --bash <($out/bin/turso completion bash) \
            --fish <($out/bin/turso completion fish) \
            --zsh <($out/bin/turso completion zsh)
        '';

        passthru.updateScript = self.pkgs.nix-update-script { };

      };

      default = self.pkgs.stdenv.mkDerivation {
        name = "turso";

        buildInputs = [
          self.cli
          self.sqld
        ];
        src = ./.;
      };
    };
}
