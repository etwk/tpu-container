# Knowledge Base
## TPU Library
### TPU VM
Different `libtpu.so` been used:
- TensorFlow: `/lib/libtpu.so` downloaded directly
- JAX:
  - pip installed from https://storage.googleapis.com/jax-releases/libtpu_releases.html
  - shown as `libtpu-nightly`

### Cases
Run failed with error:
```log
2023-10-07 10:01:10.345418: F ./tensorflow/compiler/xla/stream_executor/tpu/tpu_executor_init_fns.inc:36] TpuExecutor_AllocateTimer not available in this library.
```
possible solutions:
- Simplify setup, reduce ML libraries installed, for example if only JAX needed then remove TensorFlow.
- Try different version of libtpu.so

## Cloud Notebooks
Kaggle notebook TPU instance use setup below (at 2023.10.07):
- Python 3.8.16
- TensorFlow version: 2.12.0
- JAX version: 0.4.6
- PyTorch version: 2.0.0+cu117