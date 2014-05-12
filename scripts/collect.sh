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

if [[ ! -d "$PACKMAN_PACKAGES" ]]; then
    mkdir "$PACKMAN_PACKAGES"
fi
cd "$PACKMAN_PACKAGES"

shasum_cmd=sha1sum

for file in $(ls $PACKMAN_SCRIPTS/install_*.sh); do
    i=0
    for tmp in $(echo $(grep '_url=' $file)); do
        url=$(echo $tmp | sed 's/\w\+_url="\?\([^"]*\)"\?/\1/')
        urls[$i]=$url
        i=$((i+1))
    done
    i=0
    for tmp in $(echo $(grep '_package=' $file)); do
        package=$(echo $tmp | sed 's/\w\+_package="\?\([^"]*\)"\?/\1/')
        packages[$i]=$package
        i=$((i+1))
    done
    i=0
    for tmp in $(echo $(grep '_shasum=' $file)); do
        shasum=$(echo $tmp | sed 's/\w\+_shasum="\?\([^"]*\)"\?/\1/')
        shasums[$i]=$shasum
        i=$((i+1))
    done
    for (( i = 0; i < ${#urls[@]}; ++i )); do
        if [[ -f "$PACKMAN_PACKAGES/${packages[$i]}" ]]; then
            shasum=$($shasum_cmd "$PACKMAN_PACKAGES/${packages[$i]}" | cut -d ' ' -f 1)
            if [[ $shasum == ${shasums[$i]} ]]; then
                notice "Package $(add_color ${packages[$i]} 'bold magenta') has already downloaded."
                continue
            else
                notice "Download $(add_color ${packages[$i]} 'bold green') again."
            fi
        else
            notice "Download $(add_color ${packages[$i]} 'bold green')."
        fi
        curl --progress-bar "${urls[$i]}" -o ${packages[$i]}
    done
    unset urls packages shasums
done
