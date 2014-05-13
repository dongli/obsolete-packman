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
openblas_url="https://codeload.github.com/xianyi/OpenBLAS/zip/v0.2.9.rc2"
openblas_shasum="2c6b50bfdcb2c2568fd8574b0c3b3d8e07f12b4a"
openblas_package="OpenBLAS-0.2.9.rc2.zip"
openblas_src_root="$build_root/OpenBLAS-0.2.9.rc2"
openblas_install_root="$install_root/openblas/\$fortran_compiler/0.2.9.rc2"
openblas_bashrc="$install_root/openblas/bashrc"
# ------------------------------------------------------------------------------
# untar package
check_package "$openblas_package" "$openblas_shasum"
cd "$build_root"
if [[ ! -d "$openblas_src_root" ]]; then
    unzip -qq "$PACKMAN_PACKAGES/$openblas_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d openblas_build ]]; then
    rm -rf openblas_build
fi
cd $openblas_src_root
openblas_stdout="$build_root/openblas_stdout"
openblas_stderr="$build_root/openblas_stderr"
temp_notice "See $openblas_stdout and $openblas_stderr for output."
make -j 4 CC=$c_compiler FC=$fortran_compiler 1> "$openblas_stdout" 2> "$openblas_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make OPENBLAS! See $openblas_stderr."
fi
make install PREFIX="$(eval echo $openblas_install_root)" \
     1> "$openblas_stdout" 2> "$openblas_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install OPENBLAS! See $openblas_stderr."
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm $openblas_stdout $openblas_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$openblas_bashrc"
export OPENBLAS_ROOT=$openblas_install_root
export LD_LIBRARY_PATH=\$OPENBLAS_ROOT/lib:\$LD_LIBRARY_PATH
EOF
