{ pkgs ? import <nixpkgs> {} }:

let
  jupyter = import (builtins.fetchGit {
    # url = https://github.com/tweag/jupyterWith;
    url = https://github.com/lihebi/jupyterWith;
    # rev = "10d64ee254050de69d0dc51c9c39fdadf1398c38";
  }) {};

  # ihaskell = jupyter.kernels.iHaskellWith {
  #   name = "haskell";
  #   packages = p: with p; [ hvega formatting ];
  # };

  ipython = jupyter.kernels.iPythonWith {
    name = "python";
    packages = p: with p; [ numpy ];
  };

  currentDir = builtins.getEnv "PWD";
  ijulia = jupyter.kernels.iJuliaWith {
    name = "julia";
    packages = p: with p; [  ];
    directory = currentDir + "/.julia_pkgs";
    extraPackages = p: with p; [
      gzip
      zlib
      hdf5
      cairo
    ];
    NUM_THREADS = 8;
    cuda = true;
    # FIXME 10_2 is slow to download
    cudaVersion = pkgs.cudatoolkit_10_1;
    nvidiaVersion = pkgs.linuxPackages.nvidia_x11;
  };

  jupyterlab = jupyter.jupyterlabWith {
    kernels = [ ipython ijulia ];
    extraPackages = p: [ p.which
                         # add nix for user to install packages
                         p.nix
                         # other package managers, apt and pacman
                         p.pacman
                         # this does not seem to work, need config
                         p.sudo
                         p.git
                         # for ping
                         p.iputils
                       ];
  };
in
jupyterlab.env
# pkgs.mkShell {
#   name = "jupyterlab-shell";
#   inputsFrom = extraInputsFrom pkgs;
#   buildInputs =
#     [ jupyterlab generateDirectory generateLockFile pkgs.nodejs ] ++
#     (map (k: k.runtimePackages) kernels) ++
#     (extraPackages pkgs);
#   shellHook = ''
#           export JUPYTER_PATH=${kernelsString kernels}
#           export JUPYTERLAB=${jupyterlab}
#         '';

  # CAUTION need this to success in git
  #   GIT_SSL_CAINFO="/etc/ssl/certs/ca-certificates.crt";

  # FIXME julia-1.3 has bugs that cause git clone to fail. Julia is not well
  # supported on Nix, I'm thus suspending this and use Dockerfile instead.
  #
  # the latest effort: https://github.com/NixOS/nixpkgs/pull/98043


# }
