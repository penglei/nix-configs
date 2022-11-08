{config, lib}:
with lib;
let
  cfg = config.programs.zsh;
  relToDotDir = file: (optionalString (cfg.dotDir != null) (cfg.dotDir + "/")) + file;
in {
  pluginsDir = if cfg.dotDir != null then relToDotDir "plugins" else ".zsh/plugins";
  plugins = cfg.plugins;
}
