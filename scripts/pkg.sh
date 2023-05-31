# call the function if it exists
call() {
    local func=$1
    shift
    local args=$@
    if type $func >/dev/null 2>&1; then
        $func $args
    fi
}

# download source
mkdir -p $ROOT/src
src=$ROOT/src/$SOURCE
if [ -v URL ]; then
    hash=$(sha256sum $src | cut -d " " -f 1) || ""
    if [ ! -e $src ] || [ "$hash" != "$SHA256SUM" ]; then
        download $URL $src
    fi
fi

# to build
workdir=$ROOT/build/${PKGNAME%-*}
mkdir -p $workdir && pushd $workdir
call EXTRACT $src
call PREPARE
call BUILD
call INSTALL
call POST
popd
