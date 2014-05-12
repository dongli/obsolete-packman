#!/bin/bash

trap "exit 1" TERM
export top_pid=$$

if [[ -t 1 ]]; then
    console_redirected=false
else
    console_redirected=true
fi

function get_os_type
{
    uname_result=$(uname -a)
    OS=$(echo $uname_result | cut -d ' ' -f 1)
    echo $OS
}

function get_arch_type
{
    uname_result=$(uname -a)
    if echo $uname_result | grep -i "X86_64" 1> /dev/null; then
        ARCH="X86_64"
    fi
    echo $ARCH
}

function get_linux_type
{
    version_info=$(cat /proc/version)
    if echo $version_info | grep -i "Red Hat" 1> /dev/null; then
        if echo $version_info | grep -i "el5" 1> /dev/null; then
            echo "RHEL5"
        elif echo $version_info | grep -i "el6" 1> /dev/null; then
            echo "RHEL6"
        else
            echo "Unknown Red Hat"
        fi
    else
        echo "Unknown"
    fi
}

function notice
{
    message=$1
    echo -e "\r[$(add_color Notice "green bold")]: $message"
}

function temp_notice
{
    message=$1
    tput sc
    echo "[$(add_color Notice "green bold")]: $message"
}

function erase_temp_notice
{
    tput rc
    tput ed
}

function report_warning
{
    message=$1
    echo "[$(add_color Warning "yellow bold")]: $message"
}

function report_error
{
    message=$1
    echo "[$(add_color Error "red bold")]: $message" >&2
    kill -s TERM $top_pid
}

function report_error_noexit
{
    message=$1
    echo -e "[$(add_color Error "red bold")]: $message" >&2
}

function get_answer
{
    read -e -p "> " ans
    echo $ans
}

function check_file_existence
{
    if [[ -z $1 ]]; then
        report_error "check_file_existence: Empty argument!"
    fi
    file=$1
    if [[ ! -f $file ]]; then
        report_error "File \"$file\" does not exist!"
    fi
}

function check_directory_existence
{
    dir=$1
    if [ ! -d $dir ]; then
        report_error "Directory \"$dir\" does not exist!"
    fi
}

function add_color
{
    if [[ $console_redirected == true ]]; then
        echo -n $1
    else
        if [[ $2 == *red* ]]; then
            colored_message="$colored_message$(tput setaf 1)"
        elif [[ $2 == *green* ]]; then
            colored_message="$colored_message$(tput setaf 2)"
        elif [[ $2 == *yellow* ]]; then
            colored_message="$colored_message$(tput setaf 3)"
        elif [[ $2 == *blue* ]]; then
            colored_message="$colored_message$(tput setaf 4)"
        elif [[ $2 == *magenta* ]]; then
            colored_message="$colored_message$(tput setaf 5)"
        fi
        if [[ $2 == *bold* ]]; then
            colored_message="$colored_message$(tput bold)"
        fi
        if [[ $2 == *underline* ]]; then
            colored_message="$colored_message$(tput smul)"
        fi
        colored_message="$colored_message$1$(tput sgr0)"
        echo -n $colored_message
    fi
}

function get_config_entry
{
    config_file=$1
    entry_name=$2
    default=$3
    tmp=$(grep "^$entry_name" $config_file)
    if [[ "$tmp" == "" ]]; then
        if [[ "$default" == "" ]]; then
            report_error "No match entry for \"$entry_name\" in $config_file!"
        else
            echo $default
            return
        fi
    fi
    entry_value=$(echo $tmp | cut -d '=' -f 2)
    echo ${entry_value/^ */}
}
