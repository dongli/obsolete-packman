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
source "$install_root/netcdf/bashrc"
source "$install_root/udunits/bashrc"
source "$install_root/antlr/bashrc"
# ------------------------------------------------------------------------------
# some pacakage parameters
nco_url="http://jaist.dl.sourceforge.net/project/nco/nco-4.4.2.tar.gz"
nco_shasum="6253e0d3b00359e1ef2c95f0c86e940697286a10"
nco_package="nco-4.4.2.tar.gz"
nco_src_root="$build_root/nco-4.4.2"
nco_install_root="$install_root/nco/4.4.2"
nco_bashrc="$install_root/nco/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$nco_src_root" ]]; then
    rm -rf "$nco_src_root"
fi
tar xf "$PACKMAN_PACKAGES/$nco_package"
# ------------------------------------------------------------------------------
# compile package
cd $nco_src_root
nco_stdout="$build_root/nco_stdout"
nco_stderr="$build_root/nco_stderr"
temp_notice "See $nco_stdout and $nco_stderr for output."
CC=$c_compiler CXX=$cxx_compiler \
NETCDF_INC="$NETCDF_ROOT/include" \
NETCDF_LIB="$NETCDF_ROOT/lib" \
NETCDF4_ROOT="$NETCDF_ROOT" \
UDUNITS2_PATH="$UDUNITS_ROOT" \
ANTLR_ROOT="$ANTLR_ROOT" \
$nco_src_root/configure --prefix="$(eval echo $nco_install_root)" \
                        1> "$nco_stdout" 2> "$nco_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure NCO! See $nco_stderr."
    exit 1
fi
make -j 4 1> "$nco_stdout" 2> "$nco_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make NCO! See $nco_stderr."
    exit 1
fi
source "$install_root/gcc/bashrc" \
make check 1> "$nco_stdout" 2> "$nco_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check NCO! See $nco_stderr."
    exit 1
fi
make install 1> "$nco_stdout" 2> "$nco_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install NCO! See $nco_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm $nco_stdout $nco_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$nco_bashrc"
export NCO_ROOT=$nco_install_root
export PATH=\$NCO_ROOT/bin:\$PATH
EOF
