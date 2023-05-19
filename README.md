# petsc-docker
PETSc Docker Build

## To build locally

```
docker build . --file Dockerfile --tag=petsc-build
```

## To test against Ablate

```
docker build . --file DockerAblateFile --tag ablate-build --build-arg PETSC_BASE_IMAGE=petsc-build


## To run linux/arm64 builds on linux/amd64

...
sudo apt-get install qemu binfmt-support qemu-user-static # Install the qemu packages
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts
docker build . --platform linux/arm64 --file DockerAblateFile --tag ablate-build --build-arg PETSC_BASE_IMAGE=petsc-build
