{ pkgs ? import <nixpkgs> {} }:

let
  myMkDockerImage = { name ? "jupyterwith", jupyterlab, extraPackages }:
    let
      # nix run nixpkgs.nix-prefetch-docker -c nix-prefetch-docker --image-name mysql --image-tag 5
      ubuntu = pkgs.dockerTools.pullImage {
        imageName = "ubuntu";
        imageDigest = "sha256:05a58ded9a2c792598e8f4aa8ffe300318eac6f294bf4f49a7abae7544918592";
        sha256 = "03slilh35al9jf9pr8mr7v31d0g7qiv92cn783lr776vxb0qc927";
        finalImageName = "ubuntu";
        finalImageTag = "18.04";
      };
      nix = pkgs.dockerTools.pullImage {
        imageName = "nixos/nix";
        imageDigest = "sha256:7dc094113023d3e8ffd29ea8ca9930f89044270b72e381817a0ca6b1547a76f2";
        sha256 = "1p349r7syqbzvzmz3j1bs1gggr0r5l0w1gql40ls2zvngakjrcs8";
        finalImageName = "nixos/nix";
        finalImageTag = "2.3.6";
      };
      # nvidia/cuda:10.1-runtime-ubuntu18.04
      nvidia = pkgs.dockerTools.pullImage {
        imageName = "nvidia/cuda";
        imageDigest = "sha256:1fefce67570c92aa1e3075ae750efc835f1235bfb7cd73c9b7f3d887167eca28";
        sha256 = "0p7z1mqbhpwzxmkhl83ywk4m57483pxy552a4989ishmp9y849km";
        finalImageName = "nvidia/cuda";
        finalImageTag = "10.1-runtime-ubuntu18.04";
      };
    in
      pkgs.dockerTools.buildImage {
        inherit name;
        tag = "latest";
        # using ubuntu so that:
        # 1. providing basic utitlities
        # 2. users can install packages using apt
        # TODO maybe from nvidia/cuda image?
        # TODO maybe just provide nix as pkg manager?
        # fromImage = ubuntu;
        # fromImageTag = "18.04";

        # using nix
        # fromImage = nix;
        # fromImageTag = "2.3.6";

        # using nvidia
        fromImage = nvidia;
        fromImageTag = "10.1-runtime-ubuntu18.04";

        created = "now";
        contents = [ jupyterlab pkgs.glibcLocales ]
                   ++ (extraPackages pkgs)
        ;
        config = {
          Env = [
            "LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive"
            "LANG=en_US.UTF-8"
            "LANGUAGE=en_US:en"
            "LC_ALL=en_US.UTF-8"
          ];
          CMD = [ "/bin/jupyter-lab" "--ip=0.0.0.0" "--no-browser" "--allow-root" ];
          WorkingDir = "/data";
          ExposedPorts = {
            "8888" = {};
          };
          Volumes = {
            "/data" = {};
          };
        };
      };
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
    # probably cuda made the images 6G+?
    # cuda = true;
    # FIXME 10_2 is slow to download
    # cudaVersion = pkgs.cudatoolkit_10_1;
    # nvidiaVersion = pkgs.linuxPackages.nvidia_x11;
  };

  jupyterEnvironment = jupyter.jupyterlabWith {
    kernels = [ ipython ijulia ];
    # it does not seem to contain a shell by default
    #
    # FIXME These do not work, probably because these are used as input. to jupyter, and thus not added to the image itself.
    extraPackages = p: [
      # p.bash
      ijulia.runtimePackages
      # pkgs.bash
      # pkgs.bash-completion
    ];
    # extraInputsFrom = p: [ p.bash ];
    # extraJupyterPath = pkgs:
    #   "${pkgs.python3Packages.jupytext}/lib/python3.7/site-packages";
    # paths = [ ijulia.runtimePackages ];
    # buildInputs = [ ijulia.runtimePackages ];
  };
in
myMkDockerImage {
  name = "nixlab";
  # created = "now";
  jupyterlab = jupyterEnvironment;
}


  # To build
  # nix-build nixlab.nix
  #
  # To load into docker
  # docker load < result
  #
  # To run docker
  # sudo docker run -it --rm -p 8888:8888 nixlab
