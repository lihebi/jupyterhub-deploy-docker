# Nix + Jupyter

## References

## Build

To experiment with the shell:

```
nix-shell --pure
```

But this would creates TLS problems, thus not able to use git. Remove the
`--pure` will work using the host's certs.

To build the docker image:

```
nix-build mydocker.nix
docker load < result
sudo docker run -it --rm -p 8888:8888 nixlab
```

I'll install IJulia kernel and packages inside the container. To save the work,
I would start the container with volume to store julia artifacts:

```
sudo docker run -it --rm -p 8888:8888 -v ~/.julia:/root/.julia nixlab
```


## Integrate with JupyterHub

The hub requries:
- specify the container name for `c.DockerSpawner.container_image`
- the spawn cmd? But the container has a CMD, so I think this is not necessary
- c.DockerSpawner.notebook_dir: /root
- c.DockerSpawner.volumes:
- what is the port then? It seems to be default to 8888
- Do I need to use tini?
