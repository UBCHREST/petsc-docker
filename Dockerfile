FROM gcc:latest

# Define Constants
ENV PETSC_URL https://gitlab.com/petsc/petsc.git
ENV PETSC_VERSION 8e3dbcca

# Install dependencies 
RUN apt-get update
RUN apt-get install git
RUN apt-get install -y cmake

# Clone PETSc
run git clone ${PETSC_URL} /petsc
WORKDIR /petsc
run git checkout ${PETSC_VERSION}

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
	--download-ml \
	--download-mumps \
	--download-netcdf \
	--download-p4est \
	--download-parmetis \
	--download-pnetcdf \
	--download-scalapack \
	--download-slepc \
	--download-suitesparse \
	--download-superlu_dist \
	--download-triangle \
	--with-slepc \
	--withlibpng=1 \
	--with-zlib=1

# Configure & Build PETSc a Debug Build
ENV PETSC_ARCH=arch-debug
run ./configure \
	PETSC_ARCH=arch-debug \
	--with-debugging=1 \
	${PETSC_SETUP_ARGS}
	
run make PETSC_DIR=/petsc PETSC_ARCH=arch-debug all check

# Configure & Build PETSc a Release Build
ENV PETSC_ARCH=arch-opt
run ./configure \
	PETSC_ARCH=arch-opt \
	--with-debugging=0 \
	${PETSC_SETUP_ARGS}
	
run make PETSC_DIR=/petsc PETSC_ARCH=arch-opt all check

# Set default values
ENV PETSC_DIR=/petsc