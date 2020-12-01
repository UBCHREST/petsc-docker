FROM gcc:latest

# Define Constants
ENV PETSC_URL https://gitlab.com/petsc/petsc.git
ENV PETSC_VERSION v3.14.1

# Install dependencies 
RUN apt-get update
RUN apt-get install git

# Clone PETSc
run git clone --branch ${PETSC_VERSION} --depth 1 ${PETSC_URL} /petsc-build
WORKDIR /petsc-build

# Configure & Build PETSc
run ./configure --with-debugging=0 --with-cc=gcc --with-cxx=g++ --with-fc=gfortran --download-mpich --download-fblaslapack --prefix=/petsc
run make -j 8
run make install

# Share the package location
ENV PKG_CONFIG_PATH="/petsc/lib/pkgconfig:$PKG_CONFIG_PATH"
ENV PATH="/petsc/bin:$PATH"
