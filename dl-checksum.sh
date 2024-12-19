#!/usr/bin/env sh
set -e
DIR=~/Downloads
MIRROR=https://github.com/ollama/ollama/releases/download
APP=ollama

dl()
{
    local ver=$1
    local lchecksums=$2
    local os=$3
    local arch=$4
    local archive_type=${5:-tgz}
    local platform="${os}-${arch}"
    local file="${APP}-${platform}.${archive_type}"

    # https://github.com/ollama/ollama/releases/download/v0.3.8/ollama-linux-amd64.tgz
    local url="${MIRROR}/v${ver}/${file}"

    printf "    # %s\n" $url
    printf "    %s: sha256:%s\n" $platform $(egrep -e "$file" $lchecksums | awk '{print $1}')
}

dl_ver () {
    local ver=$1
    # https://github.com/ollama/ollama/releases/download/v0.1.41/sha256sum.txt
    local checksums_url="${MIRROR}/v${ver}/sha256sum.txt"
    local lchecksums=$DIR/${APP}-checksums-${ver}.txt
    if [ ! -e $lchecksums ]
    then
        curl -sSLf -o $lchecksums $checksums_url
    fi

    printf "  # %s\n" $checksums_url
    printf "  '%s':\n" $ver
    dl $ver $lchecksums linux amd64
    dl $ver $lchecksums linux arm64
}

dl_ver ${1:-0.5.4}
