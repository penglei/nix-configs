# deprecated
{ lib, stdenv, MacOSX-SDK, buildPackages }:
let
  mkDepsRewrites = deps:
    let
      mergeRewrites = x: y: {
        prefix = lib.mergeAttrs (x.prefix or { }) (y.prefix or { });
        const = lib.mergeAttrs (x.const or { }) (y.const or { });
      };

      rewriteArgs = { prefix ? { }, const ? { } }:
        lib.concatLists
        ((lib.mapAttrsToList (from: to: [ "-p" "${from}:${to}" ]) prefix)
          ++ (lib.mapAttrsToList (from: to: [ "-c" "${from}:${to}" ]) const));

      rewrites = depList:
        lib.fold mergeRewrites { } (map (dep: dep.tbdRewrites)
          (lib.filter (dep: dep ? tbdRewrites) depList));
    in lib.escapeShellArgs (rewriteArgs (rewrites (builtins.attrValues deps)));

  standardFrameworkPath = name: private:
    "/System/Library/${
      lib.optionalString private "Private"
    }Frameworks/${name}.framework";

  mkFramework = { name, deps, private ? false }:
    let
      self = stdenv.mkDerivation {
        pname =
          "apple-${lib.optionalString private "private-"}framework-${name}";
        version = MacOSX-SDK.version;

        dontUnpack = true;

        # because we copy files from the system
        preferLocalBuild = true;

        disallowedRequisites = [ MacOSX-SDK ];

        nativeBuildInputs = [ buildPackages.darwin.rewrite-tbd ];

        installPhase = ''
          mkdir -p $out/Library/Frameworks

          cp -r ${MacOSX-SDK}${
            standardFrameworkPath name private
          } $out/Library/Frameworks

          if [[ -d ${MacOSX-SDK}/usr/lib/swift/${name}.swiftmodule ]]; then
            mkdir -p $out/lib/swift
            cp -r -t $out/lib/swift \
              ${MacOSX-SDK}/usr/lib/swift/${name}.swiftmodule \
              ${MacOSX-SDK}/usr/lib/swift/libswift${name}.tbd
          fi

          # Fix and check tbd re-export references
          chmod u+w -R $out
          find $out -name '*.tbd' -type f | while read tbd; do
            echo "Fixing re-exports in $tbd"
            rewrite-tbd \
              -p ${
                standardFrameworkPath name private
              }/:$out/Library/Frameworks/${name}.framework/ \
              -p /usr/lib/swift/:$out/lib/swift/ \
              ${mkDepsRewrites deps} \
              -r ${builtins.storeDir} \
              "$tbd"
          done
        '';
        propagatedBuildInputs = builtins.attrValues deps;
        meta = with lib; {
          description = "Apple SDK framework ${name}";
          platforms = platforms.darwin;
        };
      };
    in self;

  framework = name: deps:
    mkFramework {
      inherit name deps;
      private = false;
    };
  privateFramework = name: deps:
    mkFramework {
      inherit name deps;
      private = true;
    };

in {
  inherit framework privateFramework;
}

#(privateFramework "MediaRemote" {})

