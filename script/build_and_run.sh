#!/bin/bash
set -euo pipefail
root_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_dir"
mode="${1:-run}"
build_dir="${DOT_GLASS_BUILD_ROOT:-/tmp/dot-glass-personal-preview}"
app="$build_dir/Dot Glass.app"
sdk="$build_dir/preview-sdk"
# Only stop this project's exact executable when rebuilding a running preview.
while read -r pid command; do
  if [[ "$command" == "$app/Contents/MacOS/DotGlass" ]]; then kill "$pid"; fi
done < <(ps -axo pid=,comm=)
mkdir -p "$app/Contents/MacOS" "$app/Contents/Frameworks" "$sdk"
swiftc -target arm64-apple-macosx14.0 -emit-library -emit-module -module-name DockDoorWidgetSDK -emit-module-path "$sdk/DockDoorWidgetSDK.swiftmodule" Sources/DockDoorWidgetSDK/*.swift -o "$sdk/libDockDoorWidgetSDK.dylib"
install_name_tool -id @rpath/libDockDoorWidgetSDK.dylib "$sdk/libDockDoorWidgetSDK.dylib"
cp "$sdk/libDockDoorWidgetSDK.dylib" "$app/Contents/Frameworks/"
swiftc -parse-as-library -target arm64-apple-macosx14.0 -I "$sdk" -L "$sdk" -lDockDoorWidgetSDK -Xlinker -rpath -Xlinker @executable_path/../Frameworks Widgets/DotGlass/*.swift Preview/DotGlassApp.swift -o "$app/Contents/MacOS/DotGlass"
export DOT_GLASS_APP_PATH="$app"
python3 - <<'PY'
import os,plistlib
from pathlib import Path
p=Path(os.environ['DOT_GLASS_APP_PATH'])/'Contents/Info.plist'
p.write_bytes(plistlib.dumps(dict(CFBundleIdentifier='com.appleforever11.DotGlassPersonalPreview',CFBundleName='Dot Glass',CFBundleDisplayName='Dot Glass',CFBundleExecutable='DotGlass',CFBundlePackageType='APPL',CFBundleShortVersionString='0.9.0',CFBundleVersion='1',LSMinimumSystemVersion='14.0',NSPrincipalClass='NSApplication',NSMicrophoneUsageDescription='Allow a voice call when you choose Call your Dot.')))
PY
xattr -cr "$app"
codesign --force --sign - "$app/Contents/Frameworks/libDockDoorWidgetSDK.dylib"
codesign --force --sign - "$app"
if [[ "$mode" == '--build-only' ]]; then exit 0; fi
open -n "$app"
if [[ "$mode" == '--verify' ]]; then sleep 1; pgrep -x DotGlass >/dev/null; fi
