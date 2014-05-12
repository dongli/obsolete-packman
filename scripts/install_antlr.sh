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
antlr_url="http://www.antlr2.org/download/antlr-2.7.7.tar.gz"
antlr_shasum="802655c343cc7806aaf1ec2177a0e663ff209de1"
antlr_package="antlr-2.7.7.tar.gz"
antlr_src_root="$build_root/antlr-2.7.7"
antlr_install_root="$install_root/antlr/2.7.7"
antlr_bashrc="$install_root/antlr/bashrc"
# ------------------------------------------------------------------------------
# untar package
cd "$build_root"
if [[ ! -d "$antlr_src_root" ]]; then
    rm -rf "$antlr_src_root"
fi
tar xf "$PACKMAN_PACKAGES/$antlr_package"
# ------------------------------------------------------------------------------
# compile package
cd $antlr_src_root
# Fix bugs in ANTLR
perl -ni -e 'print; print "#include <strings.h>\n" if $. == 13' \
    "$antlr_src_root/lib/cpp/antlr/CharScanner.hpp"
perl -ni -e 'print; print "#include <cstdio>\n" if $. == 14' \
    "$antlr_src_root/lib/cpp/antlr/CharScanner.hpp"
antlr_stdout="$build_root/antlr_stdout"
antlr_stderr="$build_root/antlr_stderr"
temp_notice "See $antlr_stdout and $antlr_stderr for output."
$antlr_src_root/configure --prefix="$(eval echo $antlr_install_root)" \
                          --disable-csharp \
                          --disable-java \
                          --disable-python \
                          1> "$antlr_stdout" 2> "$antlr_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to configure ANTLR! See $antlr_stderr."
    exit 1
fi
make -j 4 1> "$antlr_stdout" 2> "$antlr_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to make ANTLR! See $antlr_stderr."
    exit 1
fi
make install 1> "$antlr_stdout" 2> "$antlr_stderr"
if [[ $? != 0 ]]; then
    report_error "Failed to install ANTLR! See $antlr_stderr."
    exit 1
fi
# ------------------------------------------------------------------------------
# clean up
cd - > /dev/null
rm -rf antlr_build
rm $antlr_stdout $antlr_stderr
erase_temp_notice
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$antlr_bashrc"
export ANTLR_ROOT=$antlr_install_root
export PATH=\$ANTLR_ROOT/bin:\$PATH
export LD_LIBRARY_PATH=\$ANTLR_ROOT/lib:\$LD_LIBRARY_PATH
EOF
