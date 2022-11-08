{ lib, ... }:
let
  identities = ''
    #       Serial: 17662224, Slot: 1
    #         Name: passage-primary
    #      Created: Tue, 23 May 2023 12:10:13 +0000
    #   PIN policy: Once   (A PIN is required once per session, if set)
    # Touch policy: Never  (A physical touch is NOT required to decrypt)
    #    Recipient: age1yubikey1qg6xrnsngrcr6gc6p8h4pu4urdhsnug9hy638h9nrxl4c77nwujgkm99gvv
    AGE-PLUGIN-YUBIKEY-1ZZQS6QVZ5RT93CCTDFPMS

    #I don't like prompt...
    #       Serial: 23500203, Slot: 1
    #         Name: passage-secondary
    #      Created: Tue, 23 May 2023 12:15:07 +0000
    #   PIN policy: Once   (A PIN is required once per session, if set)
    # Touch policy: Never  (A physical touch is NOT required to decrypt)
    #    Recipient: age1yubikey1qwhq846h3rey4vqyw05smv0wrsad2a5hnfhjtrve6hme6rr60337c9a4k56
    AGE-PLUGIN-YUBIKEY-14W2KVQVZRHWF7UGK5KCA9
  '';

in {
  home.activation.WritePassageIdentities =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cat <<EOF > $HOME/.passage/identities
      ${identities}
      EOF
    '';
}
