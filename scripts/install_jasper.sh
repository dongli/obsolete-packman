#!/bin/bash
# ------------------------------------------------------------------------------
# arguments
package_root=$1
build_root=$2
install_root=$3
fortran_compiler=$4
cxx_compiler=$5
c_compiler=$6
# ------------------------------------------------------------------------------
# internal script library
source "$PACKMAN_SCRIPTS/bash_utils.sh"
# ------------------------------------------------------------------------------
# some pacakage parameters
jasper_url="http://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip"
jasper_shasum="9c5735f773922e580bf98c7c7dfda9bbed4c5191"
jasper_package="jasper-1.900.1.zip"
jasper_src_root="$build_root/jasper-1.900.1"
jasper_install_root="$install_root/jasper/\$fortran_compiler/1.900.1"
jasper_bashrc="$install_root/jasper/bashrc"
# ------------------------------------------------------------------------------
# unzip package
check_package "$package_root/$jasper_package" "$jasper_shasum"
cd "$build_root"
if [[ ! -d "$jasper_src_root" ]]; then
    unzip -qq "$package_root/$jasper_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d jasper_build ]]; then
    rm -rf jasper_build
fi
mkdir jasper_build
cd jasper_build
jasper_stdout="$build_root/jasper_stdout"
jasper_stderr="$build_root/jasper_stderr"
temp_notice "See $jasper_stdout and $jasper_stderr for output."
$jasper_src_root/configure --prefix="$(eval echo $jasper_install_root)" \
                           CC=$c_compiler CXX=$cxx_compiler \
                           F77=$fortran_compiler \
                           1> "$jasper_stdout" 2> "$jasper_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure JASPER! See $jasper_stderr."
fi
make -j 4 1> "$jasper_stdout" 2> "$jasper_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make JASPER! See $jasper_stderr."
fi
make check 1> "$jasper_stdout" 2> "$jasper_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check JASPER! See $jasper_stderr."
fi
make install 1> "$jasper_stdout" 2> "$jasper_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install JASPER! See $jasper_stderr."
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf jasper_build
rm $jasper_stdout $jasper_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$jasper_bashrc"
export JASPER_ROOT=$jasper_install_root
export PATH=\$JASPER_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$JASPER_ROOT/lib:\$LD_LIBRARY_PATH
EOF
