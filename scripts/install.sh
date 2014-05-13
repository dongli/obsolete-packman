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

if [[ -z "$1" ]]; then
    config_file="config.txt"
    if [[ ! -f $config_file ]]; then
        cat <<-EOF > $config_file
        install_root = <path_to_install_root>
        c_compiler = gcc
        cxx_compiler = g++
        fortran_compiler = gfortran
        #include_packages = all
        #exclude_packages = none
EOF
    fi
    notice "PACKMAN needs your instruction to install packages. Please fill in the $config_file."
fi
config_file=$1
check_file_existence "$config_file"
# ------------------------------------------------------------------------------
# check if packages have been collected
if [[ ! -d "$PACKMAN_PACKAGES" ]]; then
    report_error "Packages has not been collected! Run 'packman collect'."
fi
# ------------------------------------------------------------------------------
# parse configuration file
include_packages=$(get_config_entry "$config_file" "include_packages" "all")
exclude_packages=$(get_config_entry "$config_file" "exclude_packages" "none")
install_root=$(get_config_entry "$config_file" "install_root")
fortran_compiler=$(get_config_entry "$config_file" "fortran_compiler" "gfortran")
cxx_compiler=$(get_config_entry "$config_file" "cxx_compiler" "g++")
c_compiler=$(get_config_entry "$config_file" "c_compiler" "gcc")
if [[ "$include_packages" != "all" && "$exclude_packages" != "none" ]]; then
    report_error "Parameter $(add_color include_packages 'bold') and $(add_color exclude_packages 'bold') can not be set at the same time!"
fi
# ------------------------------------------------------------------------------
# create build directory
build_root="$PACKMAN_ROOT/build"
if [[ ! -d "$build_root" ]]; then
    notice "Create build directory."
    mkdir "$build_root"
fi
# ------------------------------------------------------------------------------
# common functions for building packages
function check_package
{
    package="$PACKMAN_PACKAGES/$1"
    shasum=$2
    if [[ ! -f "$package" ]]; then
        report_error "$(add_color $package 'bold green') is not downloaded!"
    elif ! check_shasum "$package" "$shasum"; then
        report_error "$(add_color $package 'bold green') is broken!"
    fi

}
export -f check_package
# ------------------------------------------------------------------------------
# build each package
for package in $(cat "$PACKMAN_SCRIPTS/install_order.txt"); do
    if [[ ( $exclude_packages == "all" ||   $exclude_packages =~ $package ) || \
          ( $include_packages != "all" && ! $include_packages =~ $package ) ]]; then
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
# ------------------------------------------------------------------------------
# export the global BASH configuration file
cat <<EOF > "$install_root/bashrc"
export c_compiler=$c_compiler
export cxx_compiler=$cxx_compiler
export fortran_compiler=$fortran_compiler

for package in $(ls "$install_root"); do
    if [[ $package == "bashrc" ]]; then
        # skip the global bashrc file
        continue
    fi
    if [[ ! -f "$install_root/$package/bashrc" ]]; then
        report_error "Package $(add_color $package 'green bold') does not have bashrc!"
    fi
    source "$install_root/$package/bashrc"
done
EOF
