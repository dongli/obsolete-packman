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
# dependencies
# ------------------------------------------------------------------------------
# some pacakage parameters
<name>_package="<package_file>"
<name>_src_root="$build_root/<package_dir>"
<name>_install_root="$install_root/<name>/..."
<name>_bashrc="$install_root/<name>/bashrc"
# ------------------------------------------------------------------------------
# untar package
check_package "$package_root/$<name>_package" "$<name>_shasum"
cd "$build_root"
if [[ ! -d "$<name>_src_root" ]]; then
    tar xf "$package_root/$<name>_package"
fi
# ------------------------------------------------------------------------------
# compile package
if [[ -d <name>_build ]]; then
    rm -rf <name>_build
fi
mkdir <name>_build
cd <name>_build
<name>_stdout="$build_root/<name>_stdout"
<name>_stderr="$build_root/<name>_stderr"
temp_notice "See $<name>_stdout and $<name>_stderr for output."
$<name>_src_root/configure --prefix="$(eval echo $<name>_install_root)" \
                           1> "$<name>_stdout" 2> "$<name>_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure <NAME>! See $<name>_stderr."
fi
make -j 4 1> "$<name>_stdout" 2> "$<name>_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make <NAME>! See $<name>_stderr."
fi
make check 1> "$<name>_stdout" 2> "$<name>_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check <NAME>! See $<name>_stderr."
fi
make install 1> "$<name>_stdout" 2> "$<name>_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install <NAME>! See $<name>_stderr."
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf <name>_build
rm $<name>_stdout $<name>_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$<name>_bashrc"
export <NAME>_ROOT=$<name>_install_root
export PATH=\$<NAME>_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$<NAME>_ROOT/lib:\$LD_LIBRARY_PATH
EOF
