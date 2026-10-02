#!/bin/bash
set -euo pipefail
root_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_dir"
build_dir="${DOT_GLASS_PACKAGE_ROOT:-/tmp/dot-glass-personal-package}"
bundle="$build_dir/DotGlassPersonal.bundle"
version="$(tr -d '\n' < VERSION)"
mkdir -p "$bundle/Contents/MacOS" "$build_dir/sdk"
for arch in arm64 x86_64; do
  mkdir -p "$build_dir/sdk/$arch"
  swiftc -target "$arch-apple-macosx14.0" -module-name DockDoorWidgetSDK -emit-module -emit-module-path "$build_dir/sdk/$arch/DockDoorWidgetSDK.swiftmodule" -parse-as-library Sources/DockDoorWidgetSDK/*.swift
  swiftc -target "$arch-apple-macosx14.0" -O -emit-library -module-name DotGlass -I "$build_dir/sdk/$arch" -Xlinker -undefined -Xlinker dynamic_lookup Widgets/DotGlass/*.swift -o "$build_dir/DotGlass-$arch"
done
lipo -create "$build_dir/DotGlass-arm64" "$build_dir/DotGlass-x86_64" -output "$bundle/Contents/MacOS/DotGlass"
export DOT_GLASS_PACKAGE_BUNDLE="$bundle" DOT_GLASS_VERSION="$version"
python3 - <<'PY'
import os,plistlib
from pathlib import Path
p=Path(os.environ['DOT_GLASS_PACKAGE_BUNDLE'])/'Contents/Info.plist'
p.write_bytes(plistlib.dumps(dict(CFBundleIdentifier='dot-glass-personal',CFBundleName='DotGlass',CFBundleDisplayName='Dot Glass',CFBundleExecutable='DotGlass',CFBundlePackageType='BNDL',NSPrincipalClass='DotGlass.DotGlassPlugin',CFBundleShortVersionString=os.environ['DOT_GLASS_VERSION'],CFBundleVersion=os.environ['DOT_GLASS_VERSION'],LSMinimumSystemVersion='14.0')))
PY
xattr -cr "$bundle"
codesign --force --sign - "$bundle"
codesign --verify --deep --strict "$bundle"
mkdir -p "$root_dir/dist"
ditto --norsrc --noextattr --noqtn -c -k --keepParent "$bundle" "$root_dir/dist/DotGlassPersonal.bundle.zip"
echo "Built $bundle"
