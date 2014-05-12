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
source "$install_root/jasper/bashrc"
source "$install_root/netcdf/bashrc"
# ------------------------------------------------------------------------------
# some pacakage parameters
grib_url="https://software.ecmwf.int/wiki/download/attachments/3473437/grib_api-1.12.1.tar.gz"
grib_shasum="9224b8d4d7031c4b2a9b96494834c339b641942d"
grib_package="grib_api-1.12.1.tar.gz"
grib_src_root="$build_root/grib_api-1.12.1"
grib_install_root="$install_root/grib/\$fortran_compiler/1.12.1"
grib_bashrc="$install_root/grib/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$grib_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$grib_package"
fi
# ------------------------------------------------------------------------------
# compile package
cd "$grib_src_root"
grib_stdout="$build_root/grib_stdout"
grib_stderr="$build_root/grib_stderr"
temp_notice "See $grib_stdout and $grib_stderr for output."
# --disable-shared is needed to avoid link error with JASPER library
# See https://software.ecmwf.int/issues/browse/SUP-373
$grib_src_root/configure --prefix="$(eval echo $grib_install_root)" \
                         --disable-shared \
                         --with-jasper="$JASPER_ROOT" \
                         --with-netcdf="$NETCDF_ROOT" \
                         CC=$c_compiler \
                         FC=$fortran_compiler F77=$fortran_compiler \
                         1> "$grib_stdout" 2> "$grib_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure GRIB! See $grib_stderr."
    exit 1
fi
make -j 4 1> "$grib_stdout" 2> "$grib_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make GRIB! See $grib_stderr."
    exit 1
fi
make check 1> "$grib_stdout" 2> "$grib_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check GRIB! See $grib_stderr."
    exit 1
fi
make install 1> "$grib_stdout" 2> "$grib_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install GRIB! See $grib_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm $grib_stdout $grib_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$grib_bashrc"
export GRIB_ROOT=$grib_install_root
export PATH=\$GRIB_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$GRIB_ROOT/lib:\$LD_LIBRARY_PATH
EOF
