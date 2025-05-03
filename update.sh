#!/usr/bin/env sh

set -e

repo="luleyleo/clapgrep"
tag=$(curl -s https://api.github.com/repos/$repo/releases/latest | grep tag_name | cut -d '"' -f 4)

echo "Updating to $tag"

tar_url="https://github.com/$repo/archive/refs/tags/$tag.tar.gz"

curl -s -L -O "$tar_url"

sha256sum=$(sha256sum "$tag.tar.gz" | cut -d ' ' -f 1)

mkdir "clapgrep-$tag"
tar -xf "$tag.tar.gz" -C "clapgrep-$tag" --strip-components=1

./flatpak-cargo-generator.py -o cargo-sources.json "clapgrep-${tag}/Cargo.lock"

rm -rf "clapgrep-${tag}"
rm -rf "$tag.tar.gz"

echo "url = $tar_url"
echo "sha256sum = $sha256sum"

old_url=$(cat de.leopoldluley.Clapgrep.json | grep url | cut -d '"' -f 4 | tail -n 1)
old_sha256sum=$(cat de.leopoldluley.Clapgrep.json | grep sha256 | cut -d '"' -f 4 | tail -n 1)

sed -i "s|\"url\": \"$old_url\"|\"url\": \"$tar_url\"|" de.leopoldluley.Clapgrep.json
sed -i "s|\"sha256\": \"$old_sha256sum\"|\"sha256\": \"$sha256sum\"|" de.leopoldluley.Clapgrep.json
