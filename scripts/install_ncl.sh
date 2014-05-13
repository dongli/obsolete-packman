#!/bin/bash
# ------------------------------------------------------------------------------
# arguments
package_root=$1
build_root=$2
install_root=$3
# ------------------------------------------------------------------------------
# internal script library
source "$PACKMAN_SCRIPTS/bash_utils.sh"
# ------------------------------------------------------------------------------
# dependencies
# ------------------------------------------------------------------------------
# some pacakage parameters
if [[ $(get_os_type) == "Linux" ]]; then
    if [[ $(get_linux_type) == "RHEL5" ]]; then
        ncl_package="ncl_ncarg-6.2.0.Linux_RHEL5.10_x86_64_gcc472.tar.gz"
        ncl_url="https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=5c732c30-ba18-11e3-b322-00c0f03d5b7c"
        ncl_shasum="2f9644c4ce8744cb75fb908ac9715b621ca6b476"
    elif [[ $(get_linux_type) == "RHEL6" ]]; then
        ncl_package="ncl_ncarg-6.2.0.Linux_RHEL6.2_x86_64_gcc472.tar.gz"
        ncl_url="https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=24afa5b9-ba14-11e3-b322-00c0f03d5b7c"
        ncl_shasum="fc56d45f246437fb90be98e74dcc0acd7468ac36"
    elif [[ $(get_linux_type) == "Debian6" ]]; then
        ncl_package="ncl_ncarg-6.2.0.Linux_Debian6.0_x86_64_gcc445.tar.gz"
        ncl_url="https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=5c77e723-ba18-11e3-b322-00c0f03d5b7c"
        ncl_shasum="e0b2d3404c7d56879b2aedf1b7e1811c251aae88"
    elif [[ $(get_linux_type) == "Debian7" ]]; then
        ncl_package="ncl_ncarg-6.2.0.Linux_Debian7.4_x86_64_gcc472.tar.gz"
        ncl_url="https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=5c76fcc2-ba18-11e3-b322-00c0f03d5b7c"
        ncl_shasum="c0b7252c6fd74cc0c5d415f68f37106ce520c7c2"
    fi
elif [[ $(get_os_type) == "Darwin" ]]; then
    ncl_package="ncl_ncarg-6.2.0.MacOS_10.9_64bit_gcc481.tar.gz"
    ncl_url="https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=24ac2346-ba14-11e3-b322-00c0f03d5b7c"
    ncl_shasum="2b7b1ce44b494d10a57ddce0e9405af53a9062d0"
fi
ncl_install_root="$install_root/ncl/6.2.0"
ncl_bashrc="$install_root/ncl/bashrc"
# ------------------------------------------------------------------------------
# untar pacakage
check_package "$package_root/$ncl_package" "$ncl_shasum"
if [[ ! -d "$ncl_install_root" ]]; then
    mkdir -p "$ncl_install_root"
fi
tar xf "$package_root/$ncl_package" -C "$ncl_install_root"
# ------------------------------------------------------------------------------
# export BASH configuration
cat <<EOF > "$ncl_bashrc"
export NCARG_ROOT=$ncl_install_root
export PATH=\$NCARG_ROOT/bin:\$PATH
EOF
