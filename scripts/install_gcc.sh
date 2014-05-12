#!/bin/bash
# ------------------------------------------------------------------------------
# arguments
build_root=$1
install_root=$2
# ------------------------------------------------------------------------------
# internal script library
source scripts/bash_utils.sh
# ------------------------------------------------------------------------------
# some pacakage parameters
gcc_url="ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.8.2/gcc-4.8.2.tar.bz2"
gcc_shasum="810fb70bd721e1d9f446b6503afe0a9088b62986"
gcc_package="gcc-4.8.2.tar.bz2"
gcc_src_root="$build_root/gcc-4.8.2"
gcc_install_root="$install_root/gcc/4.8.2"
gcc_bashrc="$install_root/gcc/bashrc"
gmp_url="ftp://ftp.gmplib.org/pub/gmp-4.3.2/gmp-4.3.2.tar.bz2"
gmp_shasum="c011e8feaf1bb89158bd55eaabd7ef8fdd101a2c"
gmp_package="gmp-4.3.2.tar.bz2"
gmp_src_root="$build_root/gmp-4.3.2"
mpfr_url="http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.bz2"
mpfr_shasum="7ca93006e38ae6e53a995af836173cf10ee7c18c"
mpfr_package="mpfr-2.4.2.tar.bz2"
mpfr_src_root="$build_root/mpfr-2.4.2"
mpc_url="http://multiprecision.org/mpc/download/mpc-0.8.1.tar.gz"
mpc_shasum="5ef03ca7aee134fe7dfecb6c9d048799f0810278"
mpc_package="mpc-0.8.1.tar.gz"
mpc_src_root="$build_root/mpc-0.8.1"
# ------------------------------------------------------------------------------
# untar packages
cd "$build_root"
if [[ ! -d "$gcc_src_root" ]]; then
    temp_notice "Untar $gcc_package ..."
    tar xf "$PACKMAN_PACKAGES/$gcc_package"
    erase_temp_notice
    temp_notice "Untar $gmp_package ..."
    tar xf "$PACKMAN_PACKAGES/$gmp_package"
    ln -s "$gmp_src_root" "$gcc_src_root/gmp"
    erase_temp_notice
    temp_notice "Untar $mpfr_package ..."
    tar xf "$PACKMAN_PACKAGES/$mpfr_package"
    ln -s "$mpfr_src_root" "$gcc_src_root/mpfr"
    erase_temp_notice
    temp_notice "Untar $mpc_package ..."
    tar xf "$PACKMAN_PACKAGES/$mpc_package"
    ln -s "$mpc_src_root" "$gcc_src_root/mpc"
    erase_temp_notice
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d gcc_build ]]; then
    rm -rf gcc_build
fi
mkdir gcc_build
cd gcc_build
gcc_stdout="$build_root/gcc_stdout"
gcc_stderr="$build_root/gcc_stderr"
temp_notice "See $gcc_stdout and $gcc_stderr for output."
$gcc_src_root/configure --prefix="$gcc_install_root" \
                        1> $gcc_stdout 2> $gcc_stderr
if [[ $? != 0 ]]; then
    report_error "Failed to configure GCC!"
    exit 1
fi
make -j 4 1> $gcc_stdout 2> $gcc_stderr
if [[ $? != 0 ]]; then
    report_error "Failed to make GCC!"
    exit 1
fi
report_warning "GCC is not checked."
#make -k check 1> $gcc_stdout 2> $gcc_stderr
#if [[ $? != 0 ]]; then
#    report_error "Failed to check GCC!"
#    exit 1
#fi
make install 1> "$gcc_stdout" 2> "$gcc_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install GCC!"
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf "gcc_build" "$gcc_stdout" "$gcc_stderr"
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$gcc_bashrc"
export GCC_ROOT=$gcc_install_root
export PATH=\$GCC_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$GCC_ROOT/lib:\$GCC_ROOT/lib64:\$LD_LIBRARY_PATH
export CC=gcc
export CXX=g++
export FC=gfortran
EOF
