{ config, lib, pkgs, ... }:

# Rust's LLDB formatters have no BTreeMap/BTreeSet provider: the generic
# struct summary reads the spare MaybeUninit slots of a B-tree node as
# initialized Strings/Vecs and allocates their garbage lengths. CodeLLDB grows
# until the host hangs. The formatter below walks only initialized slots and
# never descends into a MaybeUninit.
let
  btreeFormatter = "${config.xdg.configHome}/lldb/rust_btree.py";

  # Remote VS Code settings apply to every workspace opened on this machine.
  managedSettings = pkgs.writeText "vscode-machine-settings.json" (builtins.toJSON {
    "go.toolsGopath" = "";
    "go.formatTool" = "goimports";
    "github.copilot.nextEditSuggestions.enabled" = true;
    "lldb.launch.initCommands" = [ "command script import ${btreeFormatter}" ];
    "lldb.evaluateForHovers" = false;
  });

  settingsFile = "${config.home.homeDirectory}/.vscode-server/data/Machine/settings.json";
in
{
  xdg.configFile."lldb/rust_btree.py" = {
    source = ../files/lldb/rust_btree.py;
    force = true;
  };

  # VS Code must be able to write this file, so it can't be a store symlink.
  # Merge the managed keys over whatever is there: keys added in the Settings UI
  # survive, managed keys are reset on every switch. hjson reads the JSONC VS
  # Code allows (comments, trailing commas); comments don't survive the merge.
  # A file it still can't parse is backed up and replaced.
  home.activation.vscodeMachineSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    target=${lib.escapeShellArg settingsFile}
    run mkdir -p "$(dirname "$target")"
    if [ -e "$target" ] && merged=$(${pkgs.hjson-go}/bin/hjson-cli -c -preserveKeyOrder "$target" 2>/dev/null \
        | ${pkgs.jq}/bin/jq -s '.[0] * .[1]' - ${managedSettings} 2>/dev/null); then
      :
    else
      [ -e "$target" ] && run cp "$target" "$target.bak"
      merged=$(cat ${managedSettings})
    fi
    # Replace rather than write through: the target may still be the symlink
    # into the repo created by an earlier generation.
    run rm -f "$target"
    if [ -z "''${DRY_RUN:-}" ]; then
      printf '%s\n' "$merged" | ${pkgs.jq}/bin/jq . > "$target"
    fi
  '';
}
