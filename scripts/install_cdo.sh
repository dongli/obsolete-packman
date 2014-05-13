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
source "$install_root/szip/bashrc"
source "$install_root/hdf5/bashrc"
source "$install_root/netcdf/bashrc"
source "$install_root/jasper/bashrc"
source "$install_root/grib/bashrc"
source "$install_root/udunits/bashrc"
# ------------------------------------------------------------------------------
# some pacakage parameters
cdo_url="https://code.zmaw.de/attachments/download/7220/cdo-1.6.3.tar.gz"
cdo_shasum="9aa9f2227247eee6e5a0d949f5189f9a0ce4f2f1"
cdo_package="cdo-1.6.3.tar.gz"
cdo_src_root="$build_root/cdo-1.6.3"
cdo_install_root="$install_root/cdo/1.6.3"
cdo_bashrc="$install_root/cdo/bashrc"
# ------------------------------------------------------------------------------
# untar package
check_package "$cdo_package" "$cdo_shasum"
cd "$build_root"
if [[ ! -d "$cdo_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$cdo_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d cdo_build ]]; then
    rm -rf cdo_build
fi
mkdir cdo_build
cd cdo_build
cdo_stdout="$build_root/cdo_stdout"
cdo_stderr="$build_root/cdo_stderr"
temp_notice "See $cdo_stdout and $cdo_stderr for output."
$cdo_src_root/configure --prefix="$(eval echo $cdo_install_root)" \
                        --with-szlib="$SZIP_ROOT" \
                        --with-hdf5="$HDF5_ROOT" \
                        --with-netcdf="$NETCDF_ROOT" \
                        --with-jasper="$JASPER_ROOT" \
                        --with-grib_api="$GRIB_ROOT" \
                        --with-udunits2="$UDUNITS_ROOT" \
                        CC=$c_compiler CXX=$cxx_compiler \
                        1> "$cdo_stdout" 2> "$cdo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure CDO! See $cdo_stderr."
fi
make 1> "$cdo_stdout" 2> "$cdo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make CDO! See $cdo_stderr."
fi
make check 1> "$cdo_stdout" 2> "$cdo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check CDO! See $cdo_stderr."
fi
make install 1> "$cdo_stdout" 2> "$cdo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install CDO! See $cdo_stderr."
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf cdo_build
rm $cdo_stdout $cdo_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$cdo_bashrc"
export CDO_ROOT=$cdo_install_root
export PATH=\$CDO_ROOT/bin:\$PATH
EOF
