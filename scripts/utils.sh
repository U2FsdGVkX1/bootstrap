# whether the element is in the array
contains() {
    local varname=$1[@]
    local seeking=$2
    local in=1
    # echo ${!varname} - $seeking
    for element in "${!varname}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

# download file
download() {
    local url=$1
    local filename=$2
    if command -v wget &>/dev/null; then
	    wget "$url" -O "$filename"
    elif command -v curl &>/dev/null; then
	    curl -L "$url" -o "$filename"
    else
        echo "This script needs curl or wget" >&2
        exit 1
    fi
}