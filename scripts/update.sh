#!/bin/bash
# ------------------------------------------------------------------------------
# Introduction:
#
#   This script update the packman managed by git.
#
# History:
#
#   2014-05-12
#
#       Li Dong     -   Initial commit.
# ------------------------------------------------------------------------------
source "$PACKMAN_SCRIPTS/bash_utils.sh"

cd $PACKMAN_ROOT
if [[ ! -d ".git" ]]; then
    report_error "The $(add_color packman 'bold green') is not cloned through $(add_color git 'bold'). You need to download the latest version manually!"
fi

git pull origin master
