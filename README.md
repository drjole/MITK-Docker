# MITK-Docker

Dockerfiles for MITK.

## Usage (WORK IN PROGRESS!)

Use this Dockerfile to build your extension that is based on
the [MITK-ProjectTemplate](https://github.com/MITK/MITK-ProjectTemplate):

```dockerfile
FROM ghcr.io/drjole/mitk:latest

# Set the working directory
WORKDIR /work

# Copy your code into the extensions directory
COPY . ./extensions/

# Build MITK including your extension
RUN cd MITK-superbuild && \
    ninja
```

Now, build the image:

```shell
docker build -t my-mitk-extension .
```

To obtain a copy of the MITK build directory, run this command:

```shell
CONTAINER_NAME=$(docker run --rm -d my-mitk-extension) && \
  docker cp "$CONTAINER_NAME":/work/MITK-supberbuild/MITK-build ./MITK-build && \
  docker stop "$CONTAINER_NAME"
```
