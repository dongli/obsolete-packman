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
source scripts/bash_utils.sh
# ------------------------------------------------------------------------------
# some pacakage parameters
szip_url="http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz"
szip_shasum="d241c9acc26426a831765d660b683b853b83c131"
szip_package="szip-2.1.tar.gz"
szip_src_root="$build_root/szip-2.1"
szip_install_root="$install_root/szip/\$fortran_compiler/2.1"
szip_bashrc="$install_root/szip/bashrc"
# ------------------------------------------------------------------------------
# untar package
check_package "$szip_package" "$szip_shasum"
cd "$build_root"
if [[ ! -d "$szip_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$szip_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d szip_build ]]; then
    rm -rf szip_build
fi
mkdir szip_build
cd szip_build
szip_stdout="$build_root/szip_stdout"
szip_stderr="$build_root/szip_stderr"
temp_notice "See $szip_stdout and $szip_stderr for output."
$szip_src_root/configure --prefix="$(eval echo $szip_install_root)" \
                         FC=$fortran_compiler \
                         1> "$szip_stdout" 2> "$szip_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure SZIP! See $szip_stderr."
fi
make -j 4 1> "$szip_stdout" 2> "$szip_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make SZIP! See $szip_stderr."
fi
make check 1> "$szip_stdout" 2> "$szip_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check SZIP! See $szip_stderr."
fi
make install 1> "$szip_stdout" 2> "$szip_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install SZIP! See $szip_stderr."
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf szip_build
rm $szip_stdout $szip_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$szip_bashrc"
export SZIP_ROOT=$szip_install_root
export LD_LIBRARY_PATH=\$SZIP_ROOT/lib:\$LD_LIBRARY_PATH
EOF
