# My notebook/lab image

```
docker build -t lihebi/mylab mylab
```

To use it, set

DOCKER_NOTEBOOK_IMAGE=lihebi/mylab

Or use in `jupyterhub_config.py`

```
c.DockerSpawner.container_image = "lihebi/mylab"
```

## TODOs
- install nvidia driver and nvidia container runtime on host
- figure out how to spawn a container with `--gpus all`
- install emacs26
- use tsinghua mirror
