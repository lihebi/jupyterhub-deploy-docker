{ pkgs ? import <nixpkgs> {} }:

let
  mylab = import ./mylab.nix {};
in
mylab.env


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

