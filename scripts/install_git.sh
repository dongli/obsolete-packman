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
git_url="https://www.kernel.org/pub/software/scm/git/git-1.9.2.tar.gz"
git_shasum="5181808d99ea959951ee55a083de3bce8603436b"
git_package="git-1.9.2.tar.gz"
git_src_root="$build_root/git-1.9.2"
git_install_root="$install_root/git/1.9.2"
git_bashrc="$install_root/git/bashrc"
# ------------------------------------------------------------------------------
# untar package
check_package "$package_root/$git_package" "$git_shasum"
cd "$build_root"
if [[ ! -d "$git_src_root" ]]; then
    tar xf "$package_root/$git_package"
fi
# ------------------------------------------------------------------------------
# compile package
cd $git_src_root
git_stdout="$build_root/git_stdout"
git_stderr="$build_root/git_stderr"
temp_notice "See $git_stdout and $git_stderr for output."
./configure --prefix="$(eval echo $git_install_root)" \
            CC=gcc 1> "$git_stdout" 2> "$git_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure GIT! See $git_stderr."
fi
make -j 4 1> "$git_stdout" 2> "$git_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make GIT! See $git_stderr."
fi
make install 1> "$git_stdout" 2> "$git_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install GIT! See $git_stderr."
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf $git_stdout $git_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$git_bashrc"
export GIT_ROOT=$git_install_root
export PATH=\$GIT_ROOT/bin:\$PATH
EOF
