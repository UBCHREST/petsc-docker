# from the prebuilt chrest base image
ARG CHREST_BASE_IMAGE=ghcr.io/ubchrest/chrest-base-image/chrest-base-image:latest
FROM $CHREST_BASE_IMAGE AS builder

# Define Constants
ENV PETSC_URL https://gitlab.com/petsc/petsc.git

# Pass in required arguments
ARG PETSC_BUILD_COMMIT=main

# Clone PETSc
WORKDIR /
RUN git clone --depth 5 ${PETSC_URL} /petsc
WORKDIR /petsc
RUN git checkout $PETSC_BUILD_COMMIT

# Set build options
ARG CC=gcc
ARG CXX=g++
ARG Index64Bit=0

# These are extra flags
ARG DEBUGFLAGS="-g -O0"
ARG OPTFLAGS="-g -O"

# Setup shared configuration
ENV PETSC_SETUP_ARGS --with-cc=$CC \
	--with-cxx=$CXX \
	--with-64-bit-indices=$Index64Bit \
	--download-mpich \
	--download-ctetgen \
	--download-tetgen \
	--download-metis \
	--download-parmetis \
	--download-egads \
	--download-opencascade \
	--download-superlu_dist \
	# commit needed for zerork
 	--download-superlu_dist-commit=v6.4.0 \
 	--download-superlu_dist-cmake-arguments='-DXSDK_ENABLE_Fortran=OFF' \ 
	--download-hdf5 \
	--download-triangle \
	--download-slepc \
    --download-kokkos \
    # commit needed for tchem
    --download-kokkos-commit=3.7.01 

# Configure & Build PETSc Debug Build
ENV PETSC_ARCH=arch-ablate-debug
run ./configure \
	--with-debugging=1 COPTFLAGS="${DEBUGFLAGS}" CXXOPTFLAGS="${DEBUGFLAGS}" FOPTFLAGS="${DEBUGFLAGS}" \
	--prefix=/petsc-install/${PETSC_ARCH} \
	${PETSC_SETUP_ARGS} && \
	make PETSC_DIR=/petsc all install 

# Configure & Build PETSc Release Build
ENV PETSC_ARCH=arch-ablate-opt
run ./configure \
	--with-debugging=0 COPTFLAGS="${OPTFLAGS}" CXXOPTFLAGS="${OPTFLAGS}" FOPTFLAGS="${OPTFLAGS}" \
	--prefix=/petsc-install/${PETSC_ARCH} \
	${PETSC_SETUP_ARGS} && \
	make PETSC_DIR=/petsc all install 

# Now create a new image from the base and copy over only what we need
FROM $CHREST_BASE_IMAGE
COPY --from=builder /petsc-install /petsc-install

ENV PETSC_DIR=/petsc-install


