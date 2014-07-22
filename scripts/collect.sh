#!/bin/bash
# ------------------------------------------------------------------------------
# Introduction:
#
#   This script will collect packages from internet for offline use.
#
# History:
#
#   2014-05-12
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
package_root=$(get_config_entry "$config_file" "package_root" "./packman-packages")
package_root=$(get_absolute_path $package_root)
notice "Download packages into $(add_color $package_root 'bold')."
# ------------------------------------------------------------------------------
# create package root if necessary
if [[ ! -d "$package_root" ]]; then
    mkdir "$package_root"
fi
# ------------------------------------------------------------------------------
# download packages from internet
cd "$package_root"
for file in $(ls $PACKMAN_SCRIPTS/install_*.sh); do
    i=0
    for tmp in $(echo $(grep '_url=' $file)); do
        url=$(echo $tmp | perl -ne 's/\w+_url="?([^"]*)"?/\1/ and print')
        urls[$i]=$url
        i=$((i+1))
    done
    i=0
    for tmp in $(echo $(grep '_package=' $file)); do
        package=$(echo $tmp | perl -ne 's/\w+_package="?([^"]*)"?/\1/ and print')
        packages[$i]=$package
        i=$((i+1))
    done
    i=0
    for tmp in $(echo $(grep '_shasum=' $file)); do
        shasum=$(echo $tmp | perl -ne 's/\w+_shasum="?([^"]*)"?/\1/ and print')
        shasums[$i]=$shasum
        i=$((i+1))
    done
    for (( i = 0; i < ${#urls[@]}; ++i )); do
        if [[ -f "${packages[$i]}" ]]; then
            if check_shasum "${packages[$i]}" "${shasums[$i]}"; then
                notice "Package $(add_color ${packages[$i]} 'bold magenta') has already downloaded."
                continue
            else
                notice "Download $(add_color ${packages[$i]} 'bold green') again."
            fi
        else
            notice "Download $(add_color ${packages[$i]} 'bold green')."
        fi
        curl --Location --progress-bar "${urls[$i]}" -o ${packages[$i]}
    done
    unset urls packages shasums
done
