{ pkgs ? import <nixpkgs> {} }:

let
  myMkDockerImage = { name ? "jupyterwith", extraPackages }:
    let
      # nix run nixpkgs.nix-prefetch-docker -c nix-prefetch-docker --image-name mysql --image-tag 5
      # nvidia/cuda:10.1-runtime-ubuntu18.04
      nvidia = pkgs.dockerTools.pullImage {
        imageName = "nvidia/cuda";
        imageDigest = "sha256:1fefce67570c92aa1e3075ae750efc835f1235bfb7cd73c9b7f3d887167eca28";
        sha256 = "0p7z1mqbhpwzxmkhl83ywk4m57483pxy552a4989ishmp9y849km";
        finalImageName = "nvidia/cuda";
        finalImageTag = "10.1-runtime-ubuntu18.04";
      };
      # nix run nixpkgs.nix-prefetch-docker -c nix-prefetch-docker --image-name lihebi/nixlab --image-tag latest
      nixlab-base = pkgs.dockerTools.pullImage {
        imageName = "lihebi/nixlab-base";
        imageDigest = "sha256:35d952238b0bc7776e429667ad09c5108fafff045a0226115b21e27f2bc0a706";
        sha256 = "1rf7axgam8j89pahzn8i307z75n8vyyg5f810asilvgddv3yp3nr";
        finalImageName = "lihebi/nixlab-base";
        finalImageTag = "latest";
      };
    in
      pkgs.dockerTools.buildImage {
        inherit name;
        tag = "latest";
        # fromImage = nvidia;
        # fromImageTag = "10.1-runtime-ubuntu18.04";
        # fromImage = ../mylab/nixlab-base.tar.gz;
        fromImage = nixlab-base;
        fromImageTag = "latest";

        created = "now";
        contents = [ pkgs.glibcLocales ]
                   # ++ (extraPackages pkgs)
                   ++ (extraPackages pkgs)
        ;
        config = {
          Env = [
            "LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive"
            "LANG=en_US.UTF-8"
            "LANGUAGE=en_US:en"
            "LC_ALL=en_US.UTF-8"
            "SHELL=/bin/bash"
          ];
          # CMD = [
          #   "/bin/jupyter-lab"
          #   # "/bin/jupyterhub-singleuser"
          #   "--ip=0.0.0.0" "--no-browser" "--allow-root" ];
          Entrypoint = [
            "tini" "-g" "--"
          ];
          # CMD = [
          # ];
          WorkingDir = "/root";
          ExposedPorts = {
            "8888" = {};
          };
          # Volumes = {
          #   # "/data" = {};
          #   "/root" = {};
          # };
        };
      };

  mylab = import ./mylab.nix {};
  myjulia = import ./myjuliapkg.nix {};
in
myMkDockerImage {
  name = "nixlab";
  extraPackages = p: [
    p.bash
    # p.bash-completion
    # FIXME this sudo is not working
    # p.sudo
    myjulia

    # these should be in base image
    # p.which
    # p.git
    # p.wget
    # p.curl

    p.silver-searcher
    p.tini

    # p.conda
    # p.python37Packages.conda
    # FIXME use python37With?
    # p.python37Packages.jupyterhub
    # p.python37Packages.jupyter
    # p.jupyter
    # p.python37Packages.jupyterlab
  ];
}
