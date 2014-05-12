#!/bin/bash
# ------------------------------------------------------------------------------
# Introduction
#
#   This script will install the packages.
#
# History
#
#   2014-05-08
#
#       Li Dong     -       Initial creation.
# ------------------------------------------------------------------------------

source "$PACKMAN_SCRIPTS/bash_utils.sh"

#function clean
#{
#    notice "Clean the staffs."
#}
#trap clean EXIT

if [[ -z "$1" ]]; then
    report_error "Wrong usage! Please provide configuration file."
fi
config_file=$1

check_file_existence "$config_file"

exclude_packages=$(get_config_entry "$config_file" "exclude_packages" "none")
install_root=$(get_config_entry "$config_file" "install_root")
fortran_compiler=$(get_config_entry "$config_file" "fortran_compiler" "gfortran")
cxx_compiler=$(get_config_entry "$config_file" "cxx_compiler" "g++")
c_compiler=$(get_config_entry "$config_file" "c_compiler" "gcc")

package_root="$(pwd)/packages"
build_root="$(pwd)/build"

if [[ ! -d "$build_root" ]]; then
    notice "Create build directory."
    mkdir "$build_root"
fi

for package in $(cat "$PACKMAN_SCRIPTS/install_order.txt"); do
    if [[ $exclude_packages =~ $package ]]; then
        notice "Skip package $(add_color $package 'magenta bold')."
        if [[ -f "$install_root/$package/bashrc" ]]; then
            source "$install_root/$package/bashrc"
        fi
        continue
    fi
    notice "Install package $(add_color $package 'green bold') ..."
    bash "scripts/install_$package.sh" \
        "$build_root" "$install_root" \
        "$fortran_compiler" "$cxx_compiler" "$c_compiler"
    source "$install_root/$package/bashrc"
done
