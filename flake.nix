{
  description = "console: guest console helper for penguin, cross-built for every guest arch";

  nixConfig = {
    extra-substituters = [ "https://rehosting-tools.cachix.org" ];
    extra-trusted-public-keys = [
      "rehosting-tools.cachix.org-1:iNKSaFwG7MfGn6Fk7oTmIcLHqfffQ+cQIE5gWc6MlY0="
    ];
  };

  # Pinned to the same nixpkgs commit as penguin / penguin-tools so the cross
  # toolchains are byte-identical and shared through Cachix.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/b6067cc0127d4db9c26c79e4de0513e58d0c40c9";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      archMatrix = import ./src/archs.nix;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnsupportedSystem = true;
      };
      lib = pkgs.lib;

      mkMuslCrossPkgs = archKey:
        import nixpkgs {
          inherit system;
          config.allowUnsupportedSystem = true;
          crossSystem = archMatrix.${archKey}.muslCrossSystem;
        };

      # Built as static-musl binaries. console's Makefile hardcodes -march on
      # MIPS, but archs.nix already pins gcc.arch per arch (mips32r2/mips64r2),
      # so we let the cross stdenv set -march rather than fighting it.
      mkConsole = archKey:
        import ./src/mk-guest-c-tool.nix {
          crossPkgs = mkMuslCrossPkgs archKey;
          src = self;
          pname = "console-${archMatrix.${archKey}.penguinName}";
          sources = [ "console.c" ];
          outName = "console";
          defines = {
            SHELL = "/igloo/utils/sh";
            SERIAL = "/igloo/serial";
          };
        };
      consoleBins = lib.mapAttrs (archKey: _: mkConsole archKey) archMatrix;

      perArchPackages = builtins.listToAttrs (
        lib.mapAttrsToList
          (archKey: _: {
            name = "console-${archMatrix.${archKey}.penguinName}";
            value = consoleBins.${archKey};
          })
          archMatrix
      );

      # dist: the /igloo_static fragment this tool owns -- the per-arch console
      # in the melting-pot dir penguin globs (penguin's staging loop then makes
      # the flat console/console.<arch> links). Mirrors penguin-tools mk-dist-root.
      dist = pkgs.runCommand "console-dist"
        {
          nativeBuildInputs = with pkgs.buildPackages; [ coreutils ];
        }
        ''
          set -euo pipefail
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList
              (archKey: _:
                let
                  pn = archMatrix.${archKey}.penguinName;
                  console = consoleBins.${archKey};
                in
                ''
                  mkdir -p "$out/${pn}"
                  cp ${console}/bin/console "$out/${pn}/console"
                '')
              archMatrix
          )}
          chmod -R u+w "$out"
        '';
    in
    {
      packages.${system} = perArchPackages // {
        inherit dist;
        default = dist;
      };

      checks.${system} = {
        inherit dist;
      };
    };
}
