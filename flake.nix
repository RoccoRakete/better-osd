{
  description = "Better OSD: KWin script to move the Plasma OSD and make it translucent";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.betterosd;
        betterosd = pkgs.stdenvNoCC.mkDerivation {
          pname = "betterosd";
          version = (builtins.fromJSON (builtins.readFile ./kwin-script/betterosd/metadata.json)).KPlugin.Version;
          src = ./kwin-script/betterosd;

          # KWin finds scripts in $XDG_DATA_DIRS/kwin/scripts/<Id>.
          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/kwin/scripts/betterosd
            cp -r metadata.json contents $out/share/kwin/scripts/betterosd/
            runHook postInstall
          '';

          meta = {
            description = "KWin script to move the Plasma OSD and make it translucent";
            license = pkgs.lib.licenses.gpl2Plus;
            platforms = pkgs.lib.platforms.linux;
          };
        };
      });

      checks = forAllSystems (pkgs: {
        tests =
          pkgs.runCommand "betterosd-tests"
            {
              nativeBuildInputs = [ pkgs.kdePackages.qtdeclarative ];
              QT_QPA_PLATFORM = "offscreen";
              QT_PLUGIN_PATH = "${pkgs.kdePackages.qtbase}/${pkgs.kdePackages.qtbase.qtPluginPrefix}";
            }
            ''
              export XDG_CACHE_HOME=$TMPDIR
              # The tests import ../contents/code/main.js, so keep the package layout.
              qmltestrunner \
                -import ${pkgs.kdePackages.qtdeclarative}/${pkgs.kdePackages.qtbase.qtQmlPrefix} \
                -input ${./kwin-script/betterosd}/tests
              touch $out
            '';
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
