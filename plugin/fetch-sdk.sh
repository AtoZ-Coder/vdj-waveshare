#!/bin/sh
# Downloads the VirtualDJ 8 SDK headers into plugin/sdk/.
# The headers are (c) Atomix Productions and are not stored in this repo.
set -e
cd "$(dirname "$0")"
[ -f sdk/vdjDsp8.h ] && { echo "SDK already in plugin/sdk"; exit 0; }
TMP=$(mktemp -d)
curl -fsSL https://virtualdj.com/developers/VirtualDJ8_SDK_20211003.zip -o "$TMP/sdk.zip"
unzip -q -o "$TMP/sdk.zip" -d "$TMP"
cp "$TMP"/vdjPlugin8.h "$TMP"/vdjDsp8.h sdk/
rm -rf "$TMP"
echo "SDK headers in plugin/sdk"
