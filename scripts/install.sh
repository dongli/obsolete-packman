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
# ------------------------------------------------------------------------------
# check configuration file
if [[ -z "$1" ]]; then
    create_config_template "config.txt"
    notice "PACKMAN needs your instruction to install packages. Please fill in the $config_file."
    exit
fi
config_file=$1
check_file_existence "$config_file"
# ------------------------------------------------------------------------------
# parse configuration file
package_root=$(get_config_entry "$config_file" "package_root" "packman-packages")
package_root=$(get_absolute_path "$package_root")
notice "Packages are in $(add_color $package_root 'bold')."
build_root=$(get_config_entry "$config_file" "build_root" "packman-build")
build_root=$(get_absolute_path "$build_root")
notice "Build packages in $(add_color $build_root 'bold')."
install_root=$(get_config_entry "$config_file" "install_root")
install_root=$(get_absolute_path "$install_root")
notice "Install packages in $(add_color $install_root 'bold')."
c_compiler=$(get_config_entry "$config_file" "c_compiler" "gcc")
notice "C compiler is $(add_color $c_compiler 'bold')"
cxx_compiler=$(get_config_entry "$config_file" "cxx_compiler" "g++")
notice "C++ compiler is $(add_color $cxx_compiler 'bold')"
fortran_compiler=$(get_config_entry "$config_file" "fortran_compiler" "gfortran")
notice "Fortran compiler is $(add_color $fortran_compiler 'bold')"
include_packages=$(get_config_entry "$config_file" "include_packages" "all")
notice "Included packages are $(add_color "$include_packages" 'bold')"
exclude_packages=$(get_config_entry "$config_file" "exclude_packages" "none")
notice "Excluded packages are $(add_color "$exclude_packages" 'bold')"
if [[ "$include_packages" != "all" && "$exclude_packages" != "none" ]]; then
    report_error "Parameter $(add_color include_packages 'bold') and $(add_color exclude_packages 'bold') can not be set at the same time!"
fi
# ------------------------------------------------------------------------------
# check if packages have been collected
if [[ ! -d "$package_root" ]]; then
    report_error "Packages have not been collected! Run 'packman collect'."
fi
# ------------------------------------------------------------------------------
# create build directory
if [[ ! -d "$build_root" ]]; then
    notice "Create build directory."
    mkdir "$build_root"
fi
# ------------------------------------------------------------------------------
# common functions for building packages
function check_package
{
    package=$1
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
    bash "$PACKMAN_SCRIPTS/install_$package.sh" \
         "$package_root" "$build_root" "$install_root" \
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
