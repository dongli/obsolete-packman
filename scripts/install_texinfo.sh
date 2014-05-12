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
texinfo_url="http://ftp.gnu.org/gnu/texinfo/texinfo-5.2.tar.gz"
texinfo_shasum="dc54edfbb623d46fb400576b3da181f987e63516"
texinfo_package="texinfo-5.2.tar.gz"
texinfo_src_root="$build_root/texinfo-5.2"
texinfo_install_root="$install_root/texinfo/5.2"
texinfo_bashrc="$install_root/texinfo/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$texinfo_src_root" ]]; then
    tar xf "$PACKMAN_PACKAGES/$texinfo_package"
fi
# ------------------------------------------------------------------------------
# compile package
cd "$texinfo_src_root"
texinfo_stdout="$build_root/texinfo_stdout"
texinfo_stderr="$build_root/texinfo_stderr"
temp_notice "See $texinfo_stdout and $texinfo_stderr for output."
$texinfo_src_root/configure --prefix="$(eval echo $texinfo_install_root)" \
                            CC=$c_compiler \
                            1> "$texinfo_stdout" 2> "$texinfo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure TEXINFO! See $texinfo_stderr."
    exit 1
fi
make -j 4 1> "$texinfo_stdout" 2> "$texinfo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make TEXINFO! See $texinfo_stderr."
    exit 1
fi
make check 1> "$texinfo_stdout" 2> "$texinfo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to check TEXINFO! See $texinfo_stderr."
    exit 1
fi
make install 1> "$texinfo_stdout" 2> "$texinfo_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install TEXINFO! See $texinfo_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm $texinfo_stdout $texinfo_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$texinfo_bashrc"
export TEXINFO_ROOT=$texinfo_install_root
export PATH=\$TEXINFO_ROOT/bin:\$PATH
EOF
