{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.qt.style.catppuccin;
  enable = cfg.enable && config.qt.enable;

  flavorCapitalized = lib.ctp.mkUpper cfg.flavor;
  accentCapitalized = lib.ctp.mkUpper cfg.accent;

  theme =
    if (lib.versionAtLeast lib.ctp.getModuleRelease "24.11") then
      pkgs.catppuccin-kvantum.override {
        accent = cfg.accent;
        variant = cfg.flavor;
      }
    else
      pkgs.catppuccin-kvantum.override {
        accent = accentCapitalized;
        variant = flavorCapitalized;
      };

  themeName =
    if (lib.versionAtLeast lib.ctp.getModuleRelease "24.11") then
      "catppuccin-${cfg.flavor}-${cfg.accent}"
    else
      "Catppuccin-${flavorCapitalized}-${accentCapitalized}";
in
{
  options.qt.style.catppuccin = lib.ctp.mkCatppuccinOpt { name = "Kvantum"; } // {
    accent = lib.ctp.mkAccentOpt "Kvantum";

    apply = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Applies the theme by overwriting `$XDG_CONFIG_HOME/Kvantum/kvantum.kvconfig`.
        If this is disabled, you must manually set the theme (e.g. by using `kvantummanager`).
      '';
    };
  };

  config = lib.mkIf enable {
    assertions = [
      {
        assertion = lib.elem config.qt.style.name [
          "kvantum"
          "Kvantum"
        ];
        message = ''`qt.style.name` must be `"kvantum"` to use `qt.style.catppuccin`'';
      }
      {
        assertion = lib.elem (config.qt.platformTheme.name or null) [ "kvantum" ];
        message = ''`qt.platformTheme.name` must be set to `"kvantum"` to use `qt.style.catppuccin`'';
      }
    ];

    xdg.configFile = {
      "Kvantum/${themeName}".source = "${theme}/share/Kvantum/${themeName}";
      "Kvantum/kvantum.kvconfig" = lib.mkIf cfg.apply {
        text = ''
          [General]
          theme=${themeName}
        '';
      };
    };
  };
}
