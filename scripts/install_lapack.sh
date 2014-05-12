#!/bin/bash
# ------------------------------------------------------------------------------
# arguments
build_root=$1
install_root=$2
fortran_compiler=$3
cxx_compiler=$4
c_compiler=$5
# ------------------------------------------------------------------------------
# internal script library
source "$PACKMAN_SCRIPTS/bash_utils.sh"
# ------------------------------------------------------------------------------
# some pacakage parameters
lapack_url="http://www.netlib.org/lapack/lapack-3.5.0.tgz"
lapack_shasum="5870081889bf5d15fd977993daab29cf3c5ea970"
lapack_package="lapack-3.5.0.tgz"
lapack_src_root="$build_root/lapack-3.5.0"
lapack_install_root="$install_root/lapack/\$fortran_compiler/3.5.0"
lapack_bashrc="$install_root/lapack/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$lapack_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$lapack_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d lapack_build ]]; then
    rm -rf lapack_build
fi
mkdir lapack_build
cd lapack_build
lapack_stdout="$build_root/lapack_stdout"
lapack_stderr="$build_root/lapack_stderr"
temp_notice "See $lapack_stdout and $lapack_stderr for output."
CC=$c_compiler CXX=$cxx_compiler FC=$fortran_compiler cmake "$lapack_src_root" \
    -DCMAKE_INSTALL_PREFIX="$(eval echo $lapack_install_root)" \
    -DCMAKE_BUILD_TYPE="Release" \
    1> "$lapack_stdout" 2> "$lapack_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure LAPACK! See $lapack_stderr."
    exit 1
fi
make -j 4 1> "$lapack_stdout" 2> "$lapack_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make LAPACK! See $lapack_stderr."
    exit 1
fi
make test 1> "$lapack_stdout" 2> "$lapack_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to test LAPACK! See $lapack_stderr."
    exit 1
fi
make install 1> "$lapack_stdout" 2> "$lapack_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install LAPACK! See $lapack_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf lapack_build
rm $lapack_stdout $lapack_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$lapack_bashrc"
export LAPACK_ROOT=$lapack_install_root
export LD_LIBRARY_PATH=\$LAPACK_ROOT/lib:\$LD_LIBRARY_PATH
EOF
