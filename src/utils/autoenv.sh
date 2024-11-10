#!/usr/bin/env bash

autoenv() {
    if [ -n "$(_autoenv_exist_file ".env")" ]; then
        return
    fi

    local ostype=$(_autoenv_ostype)
    if [ -n "${ostype}" -a -n "$(_autoenv_exist_file ".env.example.${ostype}")" ]; then
        cp ".env.example.${ostype}" ".env"
    elif [ -n "$(_autoenv_exist_file ".env.example")" ]; then
        cp ".env.example" ".env"
    fi
}

_autoenv_exist_file() {
    [ -f "${1}" ] && echo "yes"
}

_autoenv_ostype() {
    case "${OSTYPE}" in
    linux*) echo "linux";;
    darwin*) echo "mac";;
    win32*) echo "win";;
    cygwin*) echo "cygwin";;
    msys*) echo "mingw";;
    *) echo "";;
    esac
}

if [ ! "${1}" = "--no-auto" ]; then
    autoenv
fi
