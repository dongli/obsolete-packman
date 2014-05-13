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
# dependencies
source "$install_root/uuid/bashrc"
source "$install_root/udunits/bashrc"
source "$install_root/netcdf/bashrc"
# ------------------------------------------------------------------------------
# some pacakage parameters
cmor_url="https://codeload.github.com/PCMDI/cmor/zip/CMOR-2.9.1"
cmor_shasum="c614afe629012f197801d3ee0f0a31544823f80e"
cmor_package="CMOR-2.9.1.zip"
cmor_src_root="$build_root/cmor-CMOR-2.9.1"
cmor_install_root="$install_root/cmor/\$fortran_compiler/2.9.1"
cmor_bashrc="$install_root/cmor/bashrc"
# ------------------------------------------------------------------------------
# unzip package
check_package "$cmor_package" "$cmor_shasum"
cd "$build_root"
if [[ ! -d "$cmor_src_root" ]]; then
    unzip -qq "$PACKMAN_PACKAGES/$cmor_package"
fi
# ------------------------------------------------------------------------------
# compile package
cd $cmor_src_root
cmor_stdout="$build_root/cmor_stdout"
cmor_stderr="$build_root/cmor_stderr"
temp_notice "See $cmor_stdout and $cmor_stderr for output."
$cmor_src_root/configure --prefix="$(eval echo $cmor_install_root)" \
                         --with-uuid="$UUID_ROOT" \
                         --with-udunits2="$UDUNITS_ROOT" \
                         --with-netcdf="$NETCDF_ROOT" \
                         CC=$c_compiler CXX=$cxx_compiler \
                         FC=$fortran_compiler \
                         1> "$cmor_stdout" 2> "$cmor_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure CMOR! See $cmor_stderr."
fi
make -j 4 1> "$cmor_stdout" 2> "$cmor_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make CMOR! See $cmor_stderr."
fi
make install 1> "$cmor_stdout" 2> "$cmor_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install CMOR! See $cmor_stderr."
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm $cmor_stdout $cmor_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$cmor_bashrc"
export CMOR_ROOT=$cmor_install_root
export LD_LIBRARY_PATH=\$CMOR_ROOT/lib:\$LD_LIBRARY_PATH
EOF
