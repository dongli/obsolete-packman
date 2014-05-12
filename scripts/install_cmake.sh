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
cmake_url="http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz"
cmake_shasum="cca70b307aa32a6a32c72e01fdfcecc84c1c2690"
cmake_package="cmake-2.8.12.2.tar.gz"
cmake_src_root="$build_root/cmake-2.8.12.2"
cmake_install_root="$install_root/cmake/2.8.12.2"
cmake_bashrc="$install_root/cmake/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$cmake_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$cmake_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d cmake_build ]]; then
    rm -rf cmake_build
fi
mkdir cmake_build
cd cmake_build
cmake_stdout="$build_root/cmake_stdout"
cmake_stderr="$build_root/cmake_stderr"
temp_notice "See $cmake_stdout and $cmake_stderr for output."
$cmake_src_root/configure --prefix="$(eval echo $cmake_install_root)" \
                          1> "$cmake_stdout" 2> "$cmake_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure CMAKE! See $cmake_stderr."
    exit 1
fi
make 1> "$cmake_stdout" 2> "$cmake_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make CMAKE! See $cmake_stderr."
    exit 1
fi
make install 1> "$cmake_stdout" 2> "$cmake_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install CMAKE! See $cmake_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf cmake_build
rm $cmake_stdout $cmake_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$cmake_bashrc"
export CMAKE_ROOT=$cmake_install_root
export PATH=\$CMAKE_ROOT/bin:\$PATH
EOF
