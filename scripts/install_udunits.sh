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
udunits_url="ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-2.1.24.tar.gz"
udunits_shasum="64bbb4b852146fb5d476baf4d37c9d673cfa42f9"
udunits_package="udunits-2.1.24.tar.gz"
udunits_src_root="$build_root/udunits-2.1.24"
udunits_install_root="$install_root/udunits/\$fortran_compiler/2.1.24"
udunits_bashrc="$install_root/udunits/bashrc"
# ------------------------------------------------------------------------------
# untar package
check_package "$package_root/$udunits_package" "$udunits_shasum"
cd "$build_root"
if [[ ! -d "$udunits_src_root" ]]; then
    tar xf "$package_root/$udunits_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d udunits_build ]]; then
    rm -rf udunits_build
fi
mkdir udunits_build
cd udunits_build
udunits_stdout="$build_root/udunits_stdout"
udunits_stderr="$build_root/udunits_stderr"
temp_notice "See $udunits_stdout and $udunits_stderr for output."
$udunits_src_root/configure --prefix="$(eval echo $udunits_install_root)" \
                            CC=$c_compiler CXX=$cxx_compiler \
                            FC=$fortran_compiler \
                            1> "$udunits_stdout" 2> "$udunits_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure UDUNITS! See $udunits_stderr."
fi
make -j 4 1> "$udunits_stdout" 2> "$udunits_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make UDUNITS! See $udunits_stderr."
fi
make check 1> "$udunits_stdout" 2> "$udunits_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check UDUNITS! See $udunits_stderr."
fi
make install 1> "$udunits_stdout" 2> "$udunits_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install UDUNITS! See $udunits_stderr."
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf udunits_build
rm $udunits_stdout $udunits_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$udunits_bashrc"
export UDUNITS_ROOT=$udunits_install_root
export PATH=\$UDUNITS_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$UDUNITS_ROOT/lib:\$LD_LIBRARY_PATH
EOF
