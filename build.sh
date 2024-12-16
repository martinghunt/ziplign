#!/usr/bin/env bash

set -exu

export PATH=/Applications/Godot.app/Contents/MacOS:$PATH

outdir=$1
version=$2
echo "Exporting TNA version $version to output dir: $outdir"

Godot --headless --export-release macOS $outdir/tna.$version.mac.dmg
Godot --headless --export-release "Linux/X11 arm64" $outdir/tna.$version.linux.arm64
Godot --headless --export-release "Linux/X11 x86_64" $outdir/tna.$version.linux.x86_64
Godot --headless --export-release "Windows Desktop" $outdir/tna.$version.windows.exe
