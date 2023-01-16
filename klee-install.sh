#!/bin/bash
#############################################
### Script to install klee and build klee ###
#############################################

# Install dependencies
apt-get update && apt-get upgrade -y
apt-get install -y software-properties-common
apt-add-repository universe
apt-get update
apt-get install -y python-pip
apt-get install -y build-essential curl libcap-dev git \
	 cmake libncurses5-dev python2-minimal unzip \
	 libtcmalloc-minimal4 libgoogle-perftools-dev libsqlite3-dev doxygen \
	 sqlite3

pip3 install tabulate

#### Install LLVM 11.0 #####
apt-get install -y clang-6.0 llvm-6.0 llvm-6.0-dev llvm-6.0-tools

##### Install Solvers (STP and Z3) ####
# STP
apt-get install -y cmake bison flex libboost-all-dev python perl zlib1g-dev minisat
git clone https://github.com/stp/stp.git
cd stp && git checkout tags/2.3.3 && mkdir build && cd build && cmake .. && \
   make -j `nproc` && make -j `nproc` install
echo "ulimit -s unlimited" > /etc/security/limits.conf

cd ../..

# Z3
git clone https://github.com/Z3Prover/z3.git
cd z3 && git checkout tags/z3-4.8.10 && python scripts/mk_make.py --java && cd build && make -j `nproc` &&  make -j `nproc` install 

cd ../..

#### Download and build KLEE ####
git clone https://github.com/klee/klee.git
cd klee && git checkout tags/v2.1 && mkdir build && cd build && cmake .. -DLLVM_CONFIG_BINARY=/usr/bin/llvm-config-6.0 \
   -DLLVMCC=/usr/bin/clang-6.0 -DLLVMCXX=/usr/bin/clang++-6.0 -DENABLE_UNIT_TESTS=OFF \
   -DENABLE_SYSTEM_TESTS=OFF && make -j `nproc` 