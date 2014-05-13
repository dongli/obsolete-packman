#!/bin/bash
# ------------------------------------------------------------------------------
# Description:
#
#   This script is used to setup some environment variables or other things to
#   facilitate the running of PACKMAN.
#
# History:
#
#   2014-05-10
#
#       Li Dong     -   Initial creation.
# ------------------------------------------------------------------------------

export PACKMAN_ROOT=$(cd $(dirname $BASH_ARGV) && pwd)
export PACKMAN_SCRIPTS=$PACKMAN_ROOT/scripts
export PATH=$PACKMAN_ROOT:$PATH

source $PACKMAN_SCRIPTS/bash_utils.sh

# command line completion
function _packman_()
{
    local prev_argv=${COMP_WORDS[COMP_CWORD-1]}
    local curr_argv=${COMP_WORDS[COMP_CWORD]}
    completed_words=""
    case "${prev_argv##*/}" in
    "packman")
        completed_words="help collect install setup_env update"
        ;;
    esac
    COMPREPLY=($(compgen -W "$completed_words" -- $curr_argv))
}

complete -o default -F _packman_ packman
