#!/usr/bin/env sh
set -e
DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT
MIRROR=https://github.com/ollama/ollama/releases/download
APP=ollama

dl()
{
    local ver=$1
    local lchecksums=$2
    local os=$3
    local arch=$4
    local archive_type=${5:-tar.zst}
    local platform="${os}-${arch}"
    local file="${APP}-${platform}.${archive_type}"

    # https://github.com/ollama/ollama/releases/download/v0.3.8/ollama-linux-amd64.tgz
    local url="${MIRROR}/v${ver}/${file}"

    local sum
    sum=$(awk -v f="$file" '{n = $2; sub(/^\.\//, "", n)} n == f || n == "*" f {print $1}' "$lchecksums")
    if ! printf '%s' "$sum" | grep -Eq '^[0-9a-f]{64}$'
    then
        echo "bad or missing checksum for $url: '$sum'" >&2
        exit 1
    fi
    printf "    # %s\n" "$url"
    printf "    %s: sha256:%s\n" "$platform" "$sum"
}

dl_ver () {
    local ver=$1
    # https://github.com/ollama/ollama/releases/download/v0.1.41/sha256sum.txt
    local checksums_url="${MIRROR}/v${ver}/sha256sum.txt"
    local lchecksums=$DIR/${APP}-checksums-${ver}.txt
    curl -fsSL --proto '=https' --tlsv1.2 -o "$lchecksums" "$checksums_url"

    printf "  # %s\n" $checksums_url
    printf "  '%s':\n" $ver
    dl $ver $lchecksums linux amd64
    dl $ver $lchecksums linux arm64
}

dl_ver ${1:-0.40.18}
