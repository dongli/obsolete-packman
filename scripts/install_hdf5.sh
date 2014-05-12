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
# dependencies
source "$install_root/szip/bashrc"
# ------------------------------------------------------------------------------
# some pacakage parameters
hdf5_url="http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.12/src/hdf5-1.8.12.tar.bz2"
hdf5_shasum="8414ca0e6ff7d08e423955960d641ec5f309a55f"
hdf5_package="hdf5-1.8.12.tar.bz2"
hdf5_src_root="$build_root/hdf5-1.8.12"
hdf5_install_root="$install_root/hdf5/$fortran_compiler/1.8.12"
hdf5_bashrc="$install_root/hdf5/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$hdf5_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$hdf5_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d hdf5_build ]]; then
    rm -rf hdf5_build
fi
mkdir hdf5_build
cd hdf5_build
hdf5_stdout="$build_root/hdf5_stdout"
hdf5_stderr="$build_root/hdf5_stderr"
temp_notice "See $hdf5_stdout and $hdf5_stderr for output."
$hdf5_src_root/configure --prefix="$hdf5_install_root" \
                         --with-szlib="$SZIP_ROOT" \
                         --enable-fortran --enable-fortran2003 \
                         --enable-cxx \
                         CC="$c_compiler" \
                         CXX="$cxx_compiler" \
                         FC="$fortran_compiler" \
                         1> "$hdf5_stdout" 2> "$hdf5_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure HDF5! See $hdf5_stderr."
    exit 1
fi
make -j 4 1> "$hdf5_stdout" 2> "$hdf5_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make HDF5! See $hdf5_stderr."
    exit 1
fi
make check 1> "$hdf5_stdout" 2> "$hdf5_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check HDF5! See $hdf5_stderr."
    exit 1
fi
make install 1> "$hdf5_stdout" 2> "$hdf5_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install HDF5! See $hdf5_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf hdf5_build
rm $hdf5_stdout $hdf5_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$hdf5_bashrc"
export HDF5_ROOT=$hdf5_install_root
export PATH=\$HDF5_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$HDF5_ROOT/lib:\$LD_LIBRARY_PATH
EOF
