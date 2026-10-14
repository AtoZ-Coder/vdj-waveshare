#!/bin/sh
# Builds WaveShare.bundle (universal arm64 + x86_64) and installs it into VirtualDJ.
# Close VirtualDJ first.   ./build.sh --no-install   builds only (used by CI).
set -e
cd "$(dirname "$0")"
./fetch-sdk.sh
B=WaveShare.bundle
rm -rf $B && mkdir -p $B/Contents/MacOS
cp Info.plist $B/Contents/
clang++ -std=c++17 -O2 -arch arm64 -arch x86_64 -bundle -fvisibility=hidden \
  -I sdk -framework CoreFoundation \
  -o $B/Contents/MacOS/WaveShare WaveShare.cpp
codesign --force --sign - $B
[ "$1" = "--no-install" ] && { echo "Built: plugin/$B"; exit 0; }
# VirtualDJ 2021+ keeps its home folder in Library; older versions in Documents.
HOME_VDJ="$HOME/Library/Application Support/VirtualDJ"
[ -d "$HOME_VDJ" ] || HOME_VDJ="$HOME/Documents/VirtualDJ"
[ -d "$HOME_VDJ" ] || { echo "VirtualDJ home folder not found"; exit 1; }
DEST="$HOME_VDJ/PluginsMacArm/SoundEffect"
mkdir -p "$DEST" && rm -rf "$DEST/$B" && cp -R $B "$DEST/"
echo "Installed: $DEST/$B"
