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
source "$install_root/curl/bashrc"
# ------------------------------------------------------------------------------
# some pacakage parameters
netcdf_c_url="ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.1.1.tar.gz"
netcdf_c_shasum="6aed20fa906e4963017ce9d1591aab39d8a556e4"
netcdf_c_package="netcdf-4.3.1.1.tar.gz"
netcdf_c_src_root="$build_root/netcdf-4.3.1.1"
netcdf_cxx_url="https://codeload.github.com/Unidata/netcdf-cxx4/zip/v4.2.1"
netcdf_cxx_shasum="5e288c78b17666bbd3f2a732fafec92c09b484ac"
netcdf_cxx_package="netcdf-cxx4-4.2.1.zip"
netcdf_cxx_src_root="$build_root/netcdf-cxx4-4.2.1"
netcdf_fortran_url="http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz"
netcdf_fortran_shasum="f1887314455330f4057bc8eab432065f8f6f74ef"
netcdf_fortran_package="netcdf-fortran-4.2.tar.gz"
netcdf_fortran_src_root="$build_root/netcdf-fortran-4.2"
netcdf_install_root="$install_root/netcdf/$fortran_compiler/4.3.1.1"
netcdf_bashrc="$install_root/netcdf/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$netcdf_c_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$netcdf_c_package"
fi
if [[ ! -d "$netcdf_cxx_src_root" ]]; then
    unzip -qq "$PACKMAN_PACKAGES/$netcdf_cxx_package"
fi
if [[ ! -d "$netcdf_fortran_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$netcdf_fortran_package"
fi
# ------------------------------------------------------------------------------
# compile package
netcdf_stdout="$build_root/netcdf_stdout"
netcdf_stderr="$build_root/netcdf_stderr"
# ------------------------------------------------------------------------------
# install C interface
notice "--> Install $(add_color 'C' 'blue bold') interface"
temp_notice "See $netcdf_stdout and $netcdf_stderr for output."
if [[ -d netcdf_c_build ]]; then
    rm -rf netcdf_c_build
fi
mkdir netcdf_c_build
cd netcdf_c_build
# --disable-dap-remote-tests is only for 4.3.1.1
# See http://www.unidata.ucar.edu/support/help/MailArchives/netcdf/msg12416.html
$netcdf_c_src_root/configure --prefix="$netcdf_install_root" \
                             --enable-netcdf4 \
                             --disable-dap-remote-tests \
                             CFLAGS="-I$SZIP_ROOT/include -I$HDF5_ROOT/include -I$CURL_ROOT/include" \
                             LDFLAGS="-L$SZIP_ROOT/lib -L$HDF5_ROOT/lib -I$CURL_ROOT/lib" \
                             LIBS="-lsz -lhdf5 -lhdf5_hl -lcurl" \
                             CC=$c_compiler \
                             1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure NETCDF C interface! See $netcdf_stderr."
    exit 1
fi
make -j 4 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make NETCDF C interface! See $netcdf_stderr."
    exit 1
fi
make check 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check NETCDF C interface! See $netcdf_stderr."
    exit 1
fi
make install 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install NETCDF C interface! See $netcdf_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf netcdf_c_build
rm $netcdf_stdout $netcdf_stderr
erase_temp_notice
# See http://www.unidata.ucar.edu/support/help/MailArchives/netcdf/msg11939.html
export LD_LIBRARY_PATH=$netcdf_install_root/lib:$LD_LIBRARY_PATH
# ------------------------------------------------------------------------------
# install C++ interface
notice "--> Install $(add_color 'C++' 'blue bold') interface"
temp_notice "See $netcdf_stdout and $netcdf_stderr for output."
if [[ -d netcdf_cxx_build ]]; then
    rm -rf netcdf_cxx_build
fi
mkdir netcdf_cxx_build
cd netcdf_cxx_build
$netcdf_cxx_src_root/configure --prefix="$netcdf_install_root" \
                               CPPFLAGS="-I$netcdf_install_root/include" \
                               CXXFLAGS="-I$netcdf_install_root/include" \
                               LDFLAGS="-L$netcdf_install_root/lib" \
                               CC=$c_compiler \
                               CXX=$cxx_compiler \
                               1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure NETCDF C++ interface! See $netcdf_stderr."
    exit 1
fi
make -j 4 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make NETCDF C++ interface! See $netcdf_stderr."
    exit 1
fi
make check 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check NETCDF C++ interface! See $netcdf_stderr."
    exit 1
fi
make install 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install NETCDF C++ interface! See $netcdf_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf netcdf_cxx_build
rm $netcdf_stdout $netcdf_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# install Fortran interface
notice "--> Install $(add_color 'Fortran' 'blue bold') interface"
temp_notice "See $netcdf_stdout and $netcdf_stderr for output."
if [[ -d netcdf_fortran_build ]]; then
    rm -rf netcdf_fortran_build
fi
mkdir netcdf_fortran_build
cd netcdf_fortran_build
$netcdf_fortran_src_root/configure --prefix="$netcdf_install_root" \
                                   CPPFLAGS="-I$netcdf_install_root/include" \
                                   FCFLAGS="-I$netcdf_install_root/include" \
                                   LDFLAGS="-L$netcdf_install_root/lib" \
                                   CC=$c_compiler \
                                   FC=$fortran_compiler \
                                   1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure NETCDF Fortran interface! See $netcdf_stderr."
    exit 1
fi
make -j 4 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make NETCDF Fortran interface! See $netcdf_stderr."
    exit 1
fi
make check 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check NETCDF Fortran interface! See $netcdf_stderr."
    exit 1
fi
make install 1> "$netcdf_stdout" 2> "$netcdf_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install NETCDF Fortran interface! See $netcdf_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf netcdf_fortran_build
rm $netcdf_stdout $netcdf_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$netcdf_bashrc"
export NETCDF_ROOT=$netcdf_install_root
export PATH=\$NETCDF_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$NETCDF_ROOT/lib:\$LD_LIBRARY_PATH
EOF
