# TPU Container
## General
Integrate:
 - Google TPU in TPU VM
 - Container applications, such as Jupter Notebook
 - Machine Learning frameworks, such as TensorFlow

## Notes
**Doesn't work with Docker, use Podman.**

Because some container applications use a regular user (instead of the root user) to run applications, we can't get this user in container access to TPU devices in TPU VM, not yet.

## [Knowledge Base](kb.md)

## Setup
### step 1: select
- TensorFlow version: 2.7.3 to 2.14.0 at time of writing (https://cloud.google.com/tpu/docs/supported-tpu-configurations#tpu_vm_with_tpu_v4)
- Container application: for example, Jupyer Notebook has multiple setups available (https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html)
  - Choose one version that uses Python version matches with chosen TensorFlow version

### step 2: update Dockerfile
- TensorFlow, libtpu.so (links listed here: https://cloud.google.com/tpu/docs/supported-tpu-configurations#tpu_vm_with_tpu_v4)
- Container base image

### step 3: build image
```bash
# add "--format=docker" for jupyter/scipy-notebook
podman build --format=docker -t "$IMAGE_NAME" ./
```
### step 4: prepare container volumes
Here we use "/data" as the main folder:
  - Jupyter Notebook work dir: `/data/work` -> `/home/jovyan/work`
  - Jupyter Notebook configs: `/data/.jupyter` -> `/home/jovyan/.jupyter`

> 'jovyan' is the application user in containers from Jupyter, its user id is 1000

```bash
podman unshare chown -R 1000:1000 /data
```

### step 5: run container
```bash
# add the 4 TPU devices in TPU VM, more secure than --privileged
# grant notebook application user sudo access so that we can install system packages in notebook
# generate certificates and enable htpps access
podman run -it -p $EXTERNAL_PORT:8888 \
  -v $HOME/work:/home/jovyan/work:Z \
  -v $HOME/.jupyter:/home/jovyan/.jupyter:Z \
  --device=/dev/accel{0..3} --shm-size=8G \
  --user root -e GRANT_SUDO=yes -e GEN_CERT=yes \
  --name $CONTAINER_NAME localhost/$IMAGE_NAME
```

## Tips

You may use `jupyter server password` to add a password to the config file `.jupyter/jupyter_server_config.json`.

## Todo
### Features
- [ ] Reduce image size
- [ ] Support for other machine learning frameworks such as PyTorch, JAX, etc.
- [ ] Test automatically.
- [ ] Evaluate and add support for different versions: Python, ML frameworks, and applications.
- [ ] Script for generating Dockerfile
- [ ] Smooth deploy: podman compose, auto start after host reboot
- [ ] Publish ready-to-run container images, maybe use Github workflows
- [ ] Add support for more useful container applications
- [ ] Evaluate support for TPU pod.

### Issues
- [ ] With docker, can't get the regular user in container access to TPU devices in TPU VM.

## References
- docker-stacks from Jupyter: https://github.com/jupyter/docker-stacks
- gpu-jupyter: https://github.com/iot-salzburg/gpu-jupyter

## Acknowledgements
- Thanks to the TPU Research Cloud team at Google for providing TPU resources and support!
- Special thanks to Tolun Çerkeş for his invaluable support. Tolun is an archaeologist offering tours in Turkey and is passionate about vegetarianism. If you're planning a visit to Turkey and are interested in guided tours, consider checking out his website: https://privatetourturkey.com