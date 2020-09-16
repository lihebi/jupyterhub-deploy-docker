{ pkgs ? import <nixpkgs> {} }:

pkgs.dockerTools.buildImage {
  name = "mylab";
  tag = "latest";
  created = "now";

  fromImage = "nvidia/cuda";
  fromImageTag = "10.1-devel-ubuntu18.04";

  contents = [""];

  config = {
    # Cmd = [ "${pkgs.hello}/bin/hello" ];
    Cmd = [ "start-notebook.sh" ];
  };
};


let
  jupyter = import (builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "";
  }) {};

  jupyterEnvironment = jupyter.jupyterlabWith {};
in
jupyter.mkDockerImage {
  name = "jupyter-image";
  jupyterlab = jupyterEnvironment;
}
