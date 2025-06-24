#!/usr/bin/env bash

set -exu

export PATH=/Applications/Godot.app/Contents/MacOS:$PATH

outdir=$1
version=$2
echo "Exporting Ziplign version $version to output dir: $outdir"

Godot --headless --export-release macOS $outdir/ziplign.$version.mac.dmg
Godot --headless --export-release "Linux/X11 arm64" $outdir/ziplign.$version.linux.arm64
Godot --headless --export-release "Linux/X11 x86_64" $outdir/ziplign.$version.linux.x86_64
Godot --headless --export-release "Windows Desktop" $outdir/ziplign.$version.windows.exe
