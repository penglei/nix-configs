{ config, lib, ... }: {
  home.activation.setDarwinDefaults =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      #plistfile=$HOME/Library/Preferences/com.apple.Terminal.plist
      #/usr/libexec/PlistBuddy -c "Set 'Window Settings':'Man Page':rowCount 50" "$plistfile"
      #(/usr/libexec/PlistBuddy -c "Delete 'Window Settings':'Man Page':columnCount" "$plistfile" || true)
      #/usr/libexec/PlistBuddy -c "Add 'Window Settings':'Man Page':columnCount integer 190" "$plistfile"
      defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
    '';
}

