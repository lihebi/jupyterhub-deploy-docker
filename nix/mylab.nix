{ pkgs ? import <nixpkgs> {} }:

let
  # jupyter = import (builtins.fetchGit {
  #   # url = https://github.com/tweag/jupyterWith;
  #   url = https://github.com/lihebi/jupyterWith;
  #   # rev = "10d64ee254050de69d0dc51c9c39fdadf1398c38";
  # }) {};

  jupyter = import /home/hebi/git/jupyterWith {};

  # ihaskell = jupyter.kernels.iHaskellWith {
  #   name = "haskell";
  #   packages = p: with p; [ hvega formatting ];
  # };

  ipython = jupyter.kernels.iPythonWith {
    name = "python";
    packages = p: with p; [ numpy
                            # I probably don't need this
                            # jupyterhub
                          ];
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
      # UPDATE since I'm using nvidia/cuda docker image, I won't need these.
      #
      # TODO maybe I can just use these and remove the dependency of nvidia/cuda?
      #
      # TODO I still need to tell julia where to find cuda, so that I don't need
      # to download CUDA on julia's side. But this is not urgent, julia still
      # tends to manage its packages itself.
      #
      # cuda = true;
      # FIXME 10_2 is slow to download
      # cudaVersion = pkgs.cudatoolkit_10_1;
      # nvidiaVersion = pkgs.linuxPackages.nvidia_x11;
    };

  mylab = let
    myjulia = import ./myjuliapkg.nix {};
  in
    jupyter.jupyterlabWith {
      kernels = [ ipython ijulia];
      extraPackages = p: [
        p.which
        # add nix for user to install packages
        p.nix
        # other package managers, apt and pacman
        p.pacman
        # this does not seem to work, need config
        p.sudo
        p.git
        # for ping
        p.iputils
        # other
        # ijulia.runtimePackages
        myjulia
        p.wget
        p.curl
        p.silver-searcher
        # I need to start notebook server vis the command jupyterhub-singleuser
        #
        # FIXME I have to put it here for the jupyterhub-singleuser executable
        # to be available.
        p.python37Packages.jupyterhub
        p.tini
      ];
    };
in
mylab
