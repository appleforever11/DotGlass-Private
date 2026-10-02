#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
zsh script/fetch-sparkle.sh
bash script/package_widget.sh
stage="${DOT_GLASS_COMPANION_ROOT:-/tmp/dot-glass-personal-companion}"
app="$stage/Dot Glass Personal.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources" "$app/Contents/Frameworks"
for arch in arm64 x86_64; do
  swiftc -target "$arch-apple-macosx14.0" -parse-as-library -F build/sparkle -framework Sparkle -Xlinker -rpath -Xlinker @executable_path/../Frameworks Companion/*.swift -o "$stage/companion-$arch"
done
lipo -create "$stage/companion-arm64" "$stage/companion-x86_64" -output "$app/Contents/MacOS/DotGlassPersonal"
ditto build/sparkle/Sparkle.framework "$app/Contents/Frameworks/Sparkle.framework"
ditto /tmp/dot-glass-personal-package/DotGlassPersonal.bundle "$app/Contents/Resources/DotGlassPersonal.bundle"
python3 - "$app" <<'PY'
import sys,plistlib,json
from pathlib import Path
app=Path(sys.argv[1]);config=json.loads(Path('Config/release.json').read_text());version=Path('VERSION').read_text().strip()
(app/'Contents/Info.plist').write_bytes(plistlib.dumps(dict(CFBundleIdentifier='com.appleforever11.DotGlassPersonal',CFBundleName='Dot Glass Personal',CFBundleExecutable='DotGlassPersonal',CFBundlePackageType='APPL',CFBundleVersion=version,CFBundleShortVersionString=version,LSMinimumSystemVersion='14.0',NSPrincipalClass='NSApplication',SUFeedURL=config['feedURL'],SUPublicEDKey=Path('Config/sparkle-public-key.txt').read_text().strip(),SUEnableAutomaticChecks=False,SUVerifyUpdateBeforeExtraction=True)))
PY
xattr -cr "$app"
identity="${DOT_GLASS_SIGNING_IDENTITY:--}"
opts=()
if [[ "$identity" != '-' ]]; then opts=(--options runtime --timestamp); fi
framework="$app/Contents/Frameworks/Sparkle.framework"
for nested in "$framework/Versions/B/XPCServices/Downloader.xpc" "$framework/Versions/B/XPCServices/Installer.xpc" "$framework/Versions/B/Autoupdate" "$framework/Versions/B/Updater.app" "$framework" "$app/Contents/Resources/DotGlassPersonal.bundle" "$app"; do
 codesign --force "${opts[@]}" --sign "$identity" "$nested"
done
codesign --verify --deep --strict "$app"
echo "Built $app (signing identity: $identity)"
