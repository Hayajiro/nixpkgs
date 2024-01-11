{ lib
, stdenv
, callPackage
, fetchFromGitHub

# install grid resource files from proj-data package
, withProjData ? false

, cmake
, pkg-config
, buildPackages
, sqlite
, libtiff
, curl
, gtest
, nlohmann_json
, python3
, cacert
, proj-data
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "proj";
  version = "9.3.1";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "PROJ";
    rev = version;
    hash = "sha256-M8Zgy5xnmZu7mzxXXGqaIfe7o7iMf/1sOJVOBsTvtdQ=";
  };

  patches = [
    # https://github.com/OSGeo/PROJ/pull/3252
    ./only-add-curl-for-static-builds.patch
  ];

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ sqlite libtiff curl nlohmann_json ];

  nativeCheckInputs = [ cacert gtest ];

  cmakeFlags = [
    "-DUSE_EXTERNAL_GTEST=ON"
    "-DRUN_NETWORK_DEPENDENT_TESTS=OFF"
    "-DNLOHMANN_JSON_ORIGIN=external"
    "-DEXE_SQLITE3=${buildPackages.sqlite}/bin/sqlite3"
  ];

  preCheck =
    let
      libPathEnvVar = if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in
      ''
        export HOME=$TMPDIR
        export TMP=$TMPDIR
        export ${libPathEnvVar}=$PWD/lib
      '';

  doCheck = true;

  postInstall = lib.optionalString withProjData ''
    cp --recursive ${proj-data}/* $out/share/proj/
  '';

  passthru.tests = {
    python = python3.pkgs.pyproj;
    proj = callPackage ./tests.nix { proj = finalAttrs.finalPackage; };
  };

  meta = with lib; {
    changelog = "https://github.com/OSGeo/PROJ/blob/${src.rev}/NEWS";
    description = "Cartographic Projections Library";
    homepage = "https://proj.org/";
    license = licenses.mit;
    maintainers = with maintainers; teams.geospatial.members ++ [ dotlambda ];
    platforms = platforms.unix;
  };
})
