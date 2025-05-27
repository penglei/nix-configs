{ pkgs, lib, config, ... }:
#https://github.com/jeffreytse/zsh-vi-mode#lazy-keybindings
with lib;
let cfg = config.zsh-vi-mode;
in {
  options.zsh-vi-mode = {
    enable = mkEnableOption "zsh vi mode plugin";
    package = mkOption {
      type = types.package;
      default = pkgs.zsh-vi-mode;
      defaultText = literalExpression "pkgs.zsh-vi-mode";
    };
  };
  config = mkIf cfg.enable {

    #`bindkey -e` enables the Emacs-style key binding mode in zsh,
    # allowing users to use Emacs-like shortcuts for editing the command line.
    # In this mode, you can use:
    # Ctrl+A to jump to the beginning of the line,
    # Ctrl+E to jump to the end of the line,
    # Ctrl+K to delete text from the cursor to the end of the line, and so on.

    #this plugin should init between `bindkey -e` and fzf plugin initialization that order is 200.
    programs.zsh.initContent = mkOrder 199 ''

      ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

      function zvm_goto_line_end() {
        zle vi-end-of-line
      }

      # The plugin will auto execute this zvm_after_lazy_keybindings function
      function zvm_after_lazy_keybindings() {
        # Here we define the custom widget
        zvm_define_widget zvm_goto_line_end

        zvm_bindkey vicmd 'gl' zvm_goto_line_end

      }

      ##In sourcing mode, zsh-vi-mode should be placed after the zsh-syntax-highlighting plugin,
      ##but the zsh hm module does not yet support adding plugins after it.
      #ZVM_INIT_MODE=sourcing
      . ${cfg.package}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      #unset ZVM_INIT_MODE
    '';
  };
}

# function zvm_forward_blank_word() {
#   zle vi-forward-word #zle vi-forward-blank-word
# }
# zvm_define_widget zvm_forward_blank_word
# zvm_bindkey vicmd 'f' zvm_forward_blank_word
