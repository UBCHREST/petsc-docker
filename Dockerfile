# ubuntu:latest points to the latest LTS
FROM ubuntu:latest

# Define Constants
ENV PETSC_URL https://gitlab.com/petsc/petsc.git

# Pass in required arguments
ARG PETSC_BUILD_COMMIT=main

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install build-essential gfortran git cmake autoconf automake git python3 python3-distutils libtool clang libomp-dev clang-format pkg-config libpng-dev valgrind

# Clone PETSc
WORKDIR /
RUN git clone ${PETSC_URL} /petsc
WORKDIR /petsc
RUN git checkout $PETSC_BUILD_COMMIT

# Set build options
ARG CC=gcc
ARG CXX=g++
ARG Index64Bit=0

# Setup shared configuration
ENV PETSC_SETUP_ARGS --with-cc=$CC \
	--with-cxx=$CXX \
	--with-fc=gfortran \
	--with-64-bit-indices=$Index64Bit \
	--download-mpich \
	--download-fblaslapack \
	--download-ctetgen \
	--download-egads \
	--download-fftw \
	--download-hdf5 \
	--download-metis \
	--download-mumps \
	--download-p4est \
	--download-parmetis \
	--download-scalapack \
	--download-suitesparse \
	--download-superlu_dist \
	--download-triangle \
	--download-slepc \
    --download-kokkos \
    --download-kokkos-commit=3.7.01 \
	--download-opencascade \
	--with-libpng \
	--download-zlib \
	--download-tetgen

# Configure & Build PETSc Debug Build
ENV PETSC_ARCH=arch-ablate-debug
run ./configure \
	--with-debugging=1 COPTFLAGS="-g -O0 -fsanitize=address" CXXOPTFLAGS="-g -O0 -fsanitize=address" FOPTFLAGS="-g -O0 -fsanitize=address" \
	--prefix=/petsc-install/${PETSC_ARCH} \
	${PETSC_SETUP_ARGS} && \
	make PETSC_DIR=/petsc all install && \
	rm -rf /petsc/${PETSC_ARCH} && \
	make SLEPC_DIR=/petsc-install/${PETSC_ARCH} PETSC_DIR=/petsc-install/${PETSC_ARCH} PETSC_ARCH="" check

# Configure & Build PETSc Release Build
ENV PETSC_ARCH=arch-ablate-opt
run ./configure \
	--with-debugging=0 COPTFLAGS="-g -O3 -fsanitize=address" CXXOPTFLAGS="-g -O3 -fsanitize=address" FOPTFLAGS="-g -O3 -fsanitize=address" \
	--prefix=/petsc-install/${PETSC_ARCH} \
	${PETSC_SETUP_ARGS} && \
	make PETSC_DIR=/petsc all install && \
	rm -rf /petsc/${PETSC_ARCH} && \
	make SLEPC_DIR=/petsc-install/${PETSC_ARCH} PETSC_DIR=/petsc-install/${PETSC_ARCH} PETSC_ARCH="" check

ENV PETSC_DIR=/petsc-install


