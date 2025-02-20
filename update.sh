#!/usr/bin/env sh

repo="luleyleo/clapgrep"
tag=$(curl -s https://api.github.com/repos/$repo/releases/latest | grep tag_name | cut -d '"' -f 4)

echo "Updating to $tag"

tar_url="https://github.com/$repo/archive/refs/tags/$tag.tar.gz"

curl -s -L -O "$tar_url"

sha256sum=$(sha256sum "$tag.tar.gz" | cut -d ' ' -f 1)

tar -xf "$tag.tar.gz"
./flatpak-cargo-generator.py -o cargo-sources.json "clapgrep-${tag:1}/Cargo.lock"

rm -rf "clapgrep-${tag:1}"
rm -rf "$tag.tar.gz"

echo "url = $tar_url"
echo "sha256sum = $sha256sum"

sed -i "s|\"url\": \".*$repo.*\"|\"url\": \"$tar_url\"|" de.leopoldluley.Clapgrep.json
sed -i "s|\"sha256\": \".*\"|\"sha256\": \"$sha256sum\"|" de.leopoldluley.Clapgrep.json
