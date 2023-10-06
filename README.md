# TPU Container
## General
Integrate:
 - Google TPU in TPU VM
 - Container applications, such as Jupter Notebook
 - Machine Learning frameworks, such as TensorFlow

## Notes
**Doesn't work with Docker, use Podman.**

Because some container applications use a regular user (instead of the root user) to run applications, we can't get this user in container access to TPU devices in TPU VM, not yet.

## Install
### Step 1: select
- TensorFlow version: 2.7.3 to 2.14.0 at time of writing (https://cloud.google.com/tpu/docs/supported-tpu-configurations#tpu_vm_with_tpu_v4)
- Container application: for example, Jupyer Notebook has multiple setups available (https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html)
  - Choose one version that uses Python version matches with chosen TensorFlow version

### Step 2: update Dockerfile
- TensorFlow, libtpu.so (links listed here: https://cloud.google.com/tpu/docs/supported-tpu-configurations#tpu_vm_with_tpu_v4)
- Container base image

### Step 3: build image
```bash
# add "--format=docker" for jupyter/scipy-notebook
podman build --format=docker -t "$IMAGE_NAME" ./
```
### Step 4: prepare container volumes
Here we use "/data" as the main folder:
  - Jupyter Notebook work dir: `/data/work` -> `/home/jovyan/work`
  - Jupyter Notebook configs: `/data/.jupyter` -> `/home/jovyan/.jupyter`

> 'jovyan' is the application user in containers from Jupyter, its user id is 1000

```bash
podman unshare chown -R 1000:1000 /data
```

### Step 5: run container
```bash
podman run -it -p $EXTERNAL_PORT:8888 \
  -v /data/work:/home/jovyan/work:Z \
  -v /data/.jupyter:/home/jovyan/.jupyter:Z \
  --device=/dev/accel{0..3} \  # add the 4 TPU devices in TPU VM, more secure than --privileged
  --user root -e GRANT_SUDO=yes \  # grant notebook application user sudo access so that we can install system packages in notebook
  -e GEN_CERT=yes \  # generate certificates and enable htpps access
  --name $CONTAINER_NAME localhost/$IMAGE_NAME
```

## Tips

You may use `jupyter server password` to add a password to the config file `.jupyter/jupyter_server_config.json`.

## Todo
### Features
- [ ] Reduce image size
- [ ] Smooth deploy: podman compose, auto start after host reboot
- [ ] Support for other machine learning frameworks such as PyTorch, JAX, etc.
- [ ] Choose and add support for different versions: Python, ML frameworks, and applications.
- [ ] Add support for more useful container applications
- [ ] Publish ready-to-run container images, maybe use Github workflows
- [ ] Script for generating Dockerfile
- [ ] Evaluate support for TPU pod.

### Issues
- [ ] With docker, can't get the regular user in container access to TPU devices in TPU VM.

## References
- docker-stacks from Jupyter: https://github.com/jupyter/docker-stacks
- gpu-jupyter: https://github.com/iot-salzburg/gpu-jupyter

## Thanks
- Thanks to the TPU Research Cloud team at Google for providing TPU resources and support!