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
uuid_url="https://gnome-build-stage-1.googlecode.com/files/uuid-1.6.2.tar.gz"
uuid_shasum="3e22126f0842073f4ea6a50b1f59dcb9d094719f"
uuid_package="uuid-1.6.2.tar.gz"
uuid_src_root="$build_root/uuid-1.6.2"
uuid_install_root="$install_root/uuid/1.6.2"
uuid_bashrc="$install_root/uuid/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$uuid_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$uuid_package"
fi
# ------------------------------------------------------------------------------
# compile package
uuid_stdout="$build_root/uuid_stdout"
uuid_stderr="$build_root/uuid_stderr"
temp_notice "See $uuid_stdout and $uuid_stderr for output."
cd $uuid_src_root
$uuid_src_root/configure --prefix="$uuid_install_root" \
                         CC=$c_compiler CXX=$cxx_compiler \
                         1> "$uuid_stdout" 2> "$uuid_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure UUID! See $uuid_stderr."
    exit 1
fi
make 1> "$uuid_stdout" 2> "$uuid_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make UUID! See $uuid_stderr."
    exit 1
fi
make check 1> "$uuid_stdout" 2> "$uuid_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check UUID! See $uuid_stderr."
    exit 1
fi
make install 1> "$uuid_stdout" 2> "$uuid_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install UUID! See $uuid_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm $uuid_stdout $uuid_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$uuid_bashrc"
export UUID_ROOT=$uuid_install_root
export PATH=\$UUID_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$UUID_ROOT/lib:\$LD_LIBRARY_PATH
EOF
