#!/usr/bin/env bats

setup() {
    source ${WORKSPACE_ROOT}/src/utils/autoenv.sh --no-auto
}

@test "auto env: linux" {
    OSTYPE=linux-test

    mv() {
        FROM="${1}"
        TO="${2}"
    }

    _autoenv_exist_file() {
        echo "yes"
    }

    autoenv

    [ "${FROM}" = ".env.example.linux" ]
    [ "${TO}" = ".env" ]
}

@test "auto env: no file fallback" {
    OSTYPE=linux

    mv() {
        FROM="${1}"
        TO="${2}"
    }

    _autoenv_exist_file() {
        [ "${1}" = ".env.example" ] && echo "yes"
    }

    autoenv

    [ "${FROM}" = ".env.example" ]
    [ "${TO}" = ".env" ]
}
