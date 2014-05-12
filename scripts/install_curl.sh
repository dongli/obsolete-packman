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
curl_url="http://curl.haxx.se/download/curl-7.36.0.tar.gz"
curl_shasum="35e9fb187c7512ee0206aad8ffeb4cdbf3ed80b2"
curl_package="curl-7.36.0.tar.gz"
curl_src_root="$build_root/curl-7.36.0"
curl_install_root="$install_root/curl/7.36.0"
curl_bashrc="$install_root/curl/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$curl_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$curl_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d curl_build ]]; then
    rm -rf curl_build
fi
mkdir curl_build
cd curl_build
curl_stdout="$build_root/curl_stdout"
curl_stderr="$build_root/curl_stderr"
temp_notice "See $curl_stdout and $curl_stderr for output."
$curl_src_root/configure --prefix="$(eval echo $curl_install_root)" \
                         1> "$curl_stdout" 2> "$curl_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure CURL! See $curl_stderr."
    exit 1
fi
make -j 4 1> "$curl_stdout" 2> "$curl_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make CURL! See $curl_stderr."
    exit 1
fi
make install 1> "$curl_stdout" 2> "$curl_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install CURL! See $curl_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf curl_build
rm $curl_stdout $curl_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$curl_bashrc"
export CURL_ROOT=$curl_install_root
export PATH=\$CURL_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$CURL_ROOT/lib:\$LD_LIBRARY_PATH
EOF
