#!/bin/bash
# ------------------------------------------------------------------------------
# Introduction
#
#   This script will setup the BASH environment.
#
# History
#
#   2014-05-10
#
#       Li Dong     -       Initial creation.
# ------------------------------------------------------------------------------

source "$PACKMAN_SCRIPTS/bash_utils.sh"

if [[ -z "$1" ]]; then
    report_error "Wrong usage! Please provide configuration file."
fi
config_file=$1

check_file_existence "$config_file"

install_root=$(get_config_entry "$config_file" "install_root")

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

notice "You are now in a new BASH session."
bash -i
