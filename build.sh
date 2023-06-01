#!/bin/bash -e

# define variables
ROOT=$PWD
STAGE=${2:-1}
if [ $STAGE == 1 ]; then
    PREFIX=$ROOT/tools
elif [ $STAGE == 2 ]; then
    PREFIX=$ROOT/sysroot
elif [ $STAGE == 3 ]; then
    PREFIX=/
fi
J=$(grep -c '^processor' /proc/cpuinfo)

# config and helper functions
source config.sh
source scripts/utils.sh
linuxarch=""
case $ARCH in
    riscv*)
        linuxarch="riscv"
        ;;
    x86_64*)
        linuxarch="x86_64"
        ;;
    x86*)
        linuxarch="x86"
        ;;
    aarch64*)
        linuxarch="aarch64"
        ;;
    armv7hl*)
        linuxarch="arm"
        ;;
    *)
        linuxarch=""
        ;;
esac

# get dependencies recursively
get_dependencies() {
    local varname=$1
    local pkg=$2
    local dir=$(dirname $2)
    local depends=$(source $pkg; echo ${DEPENDS[@]})
    for dep in $depends; do
        get_dependencies $varname $dir/$dep
    done
    contains $varname $pkg || eval "$varname+=($pkg)"
}

# main program
case "$1" in
    "" )
        # collect all packages
        builds=()
        for pkg in $ROOT/stage$STAGE/*; do
            get_dependencies builds $pkg
        done

        # to build
        for build in ${builds[@]}; do
            echo $build
            # $(realpath $0) $build $STAGE
        done
        ;;
    * )
        PATH=$ROOT/tools/bin:$PATH
        source $1
        echo "===== build $PKGNAME.$STAGE start ====="
        source scripts/pkg.sh
        echo "===== build $PKGNAME.$STAGE done ====="
esac
