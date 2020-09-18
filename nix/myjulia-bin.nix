# reference: https://nixos.wiki/wiki/Packaging/Binaries
{ stdenv
, fetchurl
, alsaLib
, unzip
, openssl_1_0_2
, zlib
, libjack2
, autoPatchelfHook
}:

let
  majorVersion = "1";
  minorVersion = "5";
  maintenanceVersion = "1";
  version = "${majorVersion}.${minorVersion}.${maintenanceVersion}";
in

stdenv.mkDerivation rec {
  pname = "julia-bin";
  inherit version;

  src = fetchurl {
    # "https://github.com/JuliaLang/julia/releases/download/v${version}/julia-${version}-full.tar.gz"
    # "https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.1-linux-x86_64.tar.gz"
    url = "https://julialang-s3.julialang.org/bin/linux/x64/${majorVersion}.${minorVersion}/julia-${version}-linux-x86_64.tar.gz";
    sha256 = "1qw65v795y6q76cr880248rz2403wixqzni1ywqagqs0zsvprlzm";
  };

  nativeBuildInputs = [
    unzip
    # FIXME tar?
    # tar
    autoPatchelfHook
  ];

  buildInputs = [
    alsaLib
    # openssl_1_0_2
    zlib
    libjack2
  ];

  unpackPhase = ''
    tar zxvf $src
  '';

  installPhase = ''
    # install -m755 -d -D julia-${version} $out/julia-${version}
    # find julia-${version} -type f -exec 'install -m755 "{}" $out/julia-${version}'
    #
    # DEBUG why not just use cp?
    # mkdir -p $out/
    cp -r julia-${version} $out
  '';

  # link the executable to profile

  meta = with stdenv.lib; {
    homepage = https://julialang.org;
    description = "Julia binary";
    platforms = platforms.linux;
    maintainers = with maintainers; [ lihebi ];
  };
}
