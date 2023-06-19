{ buildGoModule, fetchFromGitHub, lib, symlinkJoin }:
let
  generic = { modRoot, vendorSha256 }:
    buildGoModule rec {
      pname = "bird-lg-${modRoot}";
      version = "1.3.1";

      src = fetchFromGitHub {
        owner = "xddxdd";
        repo = "bird-lg-go";
        rev = "v${version}";
        hash = "sha256-ROMwgsKroxd9qkKX8ZoOuazBrnZytcTAPT9hR/v6a04=";
      };

      doDist = false;

      ldflags = [
        "-s"
        "-w"
      ];

      inherit modRoot vendorSha256;

      meta = with lib; {
        description = "Bird Looking Glass";
        homepage = "https://github.com/xddxdd/bird-lg-go";
        changelog = "https://github.com/xddxdd/bird-lg-go/releases/tag/v${version}";
        license = licenses.gpl3Plus;
        maintainers = with maintainers; [ tchekda ];
      };
    };

  bird-lg-frontend = generic {
    modRoot = "frontend";
    vendorSha256 = "sha256-yyH6McVzU0Qiod3yP5pGlF36fJQlf4g52wfDAem6KWs=";
  };

  bird-lg-proxy = generic {
    modRoot = "proxy";
    vendorSha256 = "sha256-JfHvDIVKQ7jdPocuh6AOwSQmP+a0/hXYrt5Ap/pEjug=";
  };
in
symlinkJoin {
  name = "bird-lg-${bird-lg-frontend.version}";
  paths = [ bird-lg-frontend bird-lg-proxy ];
} // {
  inherit (bird-lg-frontend) version meta;
}
