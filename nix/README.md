# Nix + Jupyter

## References

## Build

To experiment with the shell:

```
nix-shell --pure
```

To build the docker image:

```
nix-build mydocker.nix
docker load < result
sudo docker run -it --rm -p 8888:8888 nixlab
```

