{ pkgs ? import <nixpkgs> {} }:

let
  myMkDockerImage = { name ? "jupyterwith", jupyterlab }:
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
        # tag = "1";
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
                   # ++ (extraPackages pkgs)
                   ++ (jupyterlab.extraPackages pkgs)
        ;
        # CAUTION this requires setting
        #     system-features = kvm
        # in ~/.config/nix/nix.conf
        #
        # Most likely your /tmp tmpfs is not big enough
        # (https://github.com/NixOS/nixpkgs/issues/54707), and you probably want
        # to do this:
        #
        #     sudo mount -o remount,size=40G /tmp
        #
        # FIXME I still cannot get it working. I'm using root instead
        #
        # runAsRoot = ''
        #     #!${pkgs.runtimeShell}
        #     ${pkgs.dockerTools.shadowSetup}
        # #     mkdir -p /data
        #     #
        #     useradd -aG admin -s /bin/bash myuser
        #     echo "myuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
        # '';
        config = {
          # TODO set user shell to bash
          # TODO enable sudo
          # User = "myuser";
          Env = [
            "LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive"
            "LANG=en_US.UTF-8"
            "LANGUAGE=en_US:en"
            "LC_ALL=en_US.UTF-8"
            "SHELL=/bin/bash"
          ];
          CMD = [
            "/bin/jupyter-lab"
            # "/bin/jupyterhub-singleuser"
            "--ip=0.0.0.0" "--no-browser" "--allow-root" ];
          WorkingDir = "/root";
          ExposedPorts = {
            "8888" = {};
          };
          Volumes = {
            # "/data" = {};
            "/root" = {};
          };
        };
      };

  mylab = import ./mylab.nix {};
in
myMkDockerImage {
  name = "nixlab";
  jupyterlab = mylab;
  # FIXME how to setup bash completion?
  # extraPackages = p: [ p.bash p.bash-completion ];
}
