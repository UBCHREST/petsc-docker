FROM ubuntu:hirsute

# Define Constants
ENV PETSC_URL https://gitlab.com/petsc/petsc.git

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get -y install build-essential gfortran git cmake autoconf automake git python3 python3-distutils libtool clang-format pkg-config libpng-dev

# Clone PETSc
WORKDIR /
RUN git clone ${PETSC_URL} /petsc
WORKDIR /petsc
RUN git checkout main

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
	--download-tchem \
	--download-opencascade \
	--with-libpng \
	--download-zlib

# Configure & Build PETSc a 32-bit indices Debug Build
ENV PETSC_ARCH=arch-debug
run ./configure \
	PETSC_ARCH=arch-debug \
	--with-64-bit-indices=0 \
	--with-debugging=1 \
	${PETSC_SETUP_ARGS}

run make PETSC_DIR=/petsc PETSC_ARCH=arch-debug all check

# Configure & Build PETSc a 32-bit indices Release Build
ENV PETSC_ARCH=arch-opt
run ./configure \
	PETSC_ARCH=arch-opt \
	--with-64-bit-indices=0 \
	--with-debugging=0 \
	${PETSC_SETUP_ARGS}

run make PETSC_DIR=/petsc PETSC_ARCH=arch-opt all check

# Configure & Build PETSc a 64-bit indices Debug Build
ENV PETSC_ARCH=arch-debug
run ./configure \
	PETSC_ARCH=arch-debug-64 \
	--with-64-bit-indices=1 \
	--with-debugging=1 \
	${PETSC_SETUP_ARGS}

run make PETSC_DIR=/petsc PETSC_ARCH=arch-debug-64 all check

# Configure & Build PETSc a 64-bit indices Release Build
ENV PETSC_ARCH=arch-opt
run ./configure \
	PETSC_ARCH=arch-opt-64 \
	--with-64-bit-indices=1 \
	--with-debugging=0 \
	${PETSC_SETUP_ARGS}

run make PETSC_DIR=/petsc PETSC_ARCH=arch-opt-64 all check


# Set default values
ENV PETSC_DIR=/petsc
