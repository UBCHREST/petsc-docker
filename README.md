# petsc-docker
PETSc Docker Build

## To build locally

```
docker build . --file Dockerfile --tag=petsc-build
```

## To test against Ablate

```
docker buildx build . --file DockerAblateFile --tag ablate-build --build-arg PETSC_BASE_IMAGE=petsc-build
