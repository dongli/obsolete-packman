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
source "$install_root/openblas/bashrc"
# ------------------------------------------------------------------------------
# some pacakage parameters
armadillo_url="http://jaist.dl.sourceforge.net/project/arma/armadillo-4.100.2.tar.gz"
armadillo_shasum="4cf8cb82c8197dda08f019455d006cbc2b093fcf"
armadillo_package="armadillo-4.100.2.tar.gz"
armadillo_src_root="$build_root/armadillo-4.100.2"
armadillo_install_root="$install_root/armadillo/4.100.2"
armadillo_bashrc="$install_root/armadillo/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ -d "$armadillo_src_root" ]]; then
    rm -rf "$armadillo_src_root"
fi
tar xf "$PACKMAN_PACKAGES/$armadillo_package"
# fix a cmake bug
perl -pi -e 's/$/ $ENV{OPENBLAS_ROOT}\/lib/ if $. == 11' \
    "$armadillo_src_root/build_aux/cmake/Modules/ARMA_FindOpenBLAS.cmake"
# ------------------------------------------------------------------------------
# compile package
if [[ -d armadillo_build ]]; then
    rm -rf armadillo_build
fi
mkdir armadillo_build
cd armadillo_build
armadillo_stdout="$build_root/armadillo_stdout"
armadillo_stderr="$build_root/armadillo_stderr"
temp_notice "See $armadillo_stdout and $armadillo_stderr for output."
cmake "$armadillo_src_root" \
    -DCMAKE_INSTALL_PREFIX="$armadillo_install_root" \
    -DCMAKE_BUILD_TYPE="Release" \
    1> "$armadillo_stdout" 2> "$armadillo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure ARMADILLO! See $armadillo_stderr."
    exit 1
fi
make -j 4 1> "$armadillo_stdout" 2> "$armadillo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make ARMADILLO! See $armadillo_stderr."
    exit 1
fi
make install 1> "$armadillo_stdout" 2> "$armadillo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install ARMADILLO! See $armadillo_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf armadillo_build
rm $armadillo_stdout $armadillo_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$armadillo_bashrc"
export ARMADILLO_ROOT=$armadillo_install_root
export LD_LIBRARY_PATH=\$ARMADILLO_ROOT/lib:\$LD_LIBRARY_PATH
EOF
