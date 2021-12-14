FROM ubuntu:hirsute

# Define Constants
ENV PETSC_URL https://gitlab.com/petsc/petsc.git

# Pass in required arguments
ARG PETSC_BUILD_COMMIT=main

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install build-essential gfortran git cmake autoconf automake git python3 python3-distutils libtool clang-format pkg-config libpng-dev

# Clone PETSc
WORKDIR /
RUN git clone ${PETSC_URL} /petsc
WORKDIR /petsc
RUN git checkout $PETSC_BUILD_COMMIT

# Setup shared configuration
ENV PETSC_SETUP_ARGS --with-cc=gcc \
	--with-cxx=g++ \
	--with-fc=gfortran \
	--download-mpich \
	--download-fblaslapack \
	--download-ctetgen \
	--download-egads \
	--download-exodusii \
	--download-fftw \
	--download-hdf5 \
	--download-metis \
	--download-mumps \
	--download-netcdf \
	--download-p4est \
	--download-parmetis \
	--download-pnetcdf \
	--download-scalapack \
	--download-suitesparse \
	--download-superlu_dist \
	--download-triangle \
	--download-slepc \
	--download-tchem=https://github.com/UBCHREST/tchemv1.git \
	--download-tchem-commit=0354366 \
	--download-opencascade \
	--with-libpng \
	--download-zlib

# Configure & Build PETSc a 32-bit indices Release Build
ENV PETSC_ARCH=arch-opt
run ./configure \
	--with-64-bit-indices=0 \
	--with-debugging=0 \
  --prefix=/petsc-install/${PETSC_ARCH} \
	${PETSC_SETUP_ARGS} && \
  make PETSC_DIR=/petsc all install && \
  rm -rf /petsc/${PETSC_ARCH} && \
  make SLEPC_DIR=/petsc-install/${PETSC_ARCH} PETSC_DIR=/petsc-install/${PETSC_ARCH} PETSC_ARCH="" check

# Configure & Build PETSc a 64-bit indices Release Build
ENV PETSC_ARCH=arch-opt-64
run ./configure \
	--with-64-bit-indices=1 \
	--with-debugging=0 \
  --prefix=/petsc-install/${PETSC_ARCH} \
	${PETSC_SETUP_ARGS} && \
  make PETSC_DIR=/petsc all install && \
  rm -rf /petsc/${PETSC_ARCH} && \
  make SLEPC_DIR=/petsc-install/${PETSC_ARCH} PETSC_DIR=/petsc-install/${PETSC_ARCH} PETSC_ARCH="" check

ENV PETSC_DIR=/petsc-install


