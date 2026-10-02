#!/bin/bash
# Prepares a notarized archive and signed appcast. Never publishes automatically.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${DOT_GLASS_SIGNING_IDENTITY:?Set a Developer ID Application identity}"
: "${DOT_GLASS_NOTARY_PROFILE:?Set an existing notarytool credential profile}"
[[ "$DOT_GLASS_SIGNING_IDENTITY" != '-' ]] || exit 1
bash script/build-personal.sh
app="${DOT_GLASS_COMPANION_ROOT:-/tmp/dot-glass-personal-companion}/Dot Glass Personal.app"
version="$(tr -d '\n' < VERSION)"
zip="dist/DotGlassPersonal-$version.zip"
ditto -c -k --keepParent "$app" "$zip"
xcrun notarytool submit "$zip" --keychain-profile "$DOT_GLASS_NOTARY_PROFILE" --wait
xcrun stapler staple "$app"
xcrun stapler validate "$app"
spctl --assess --type execute --verbose "$app"
ditto -c -k --keepParent "$app" "$zip"
signature="$(build/sparkle/bin/sign_update --account dot-glass-personal -p "$zip")"
python3 - "$zip" "$version" "$signature" <<'PY'
from pathlib import Path
import sys,xml.etree.ElementTree as E
archive,version,signature=sys.argv[1:];ns='http://www.andymatuschak.org/xml-namespaces/sparkle';E.register_namespace('sparkle',ns)
r=E.Element('rss',version='2.0');c=E.SubElement(r,'channel');E.SubElement(c,'title').text='Dot Glass Personal';i=E.SubElement(c,'item');E.SubElement(i,'title').text='Dot Glass Personal '+version
for key,value in [('version',version),('shortVersionString',version),('minimumSystemVersion','14.0')]:E.SubElement(i,'{'+ns+'}'+key).text=value
E.SubElement(i,'enclosure',{'url':f'https://github.com/appleforever11/DotGlass-Private/releases/download/v{version}/DotGlassPersonal-{version}.zip','length':str(Path(archive).stat().st_size),'type':'application/octet-stream','{'+ns+'}edSignature':signature})
E.indent(r);E.ElementTree(r).write('dist/appcast.xml',encoding='utf-8',xml_declaration=True)
PY
echo 'Prepared dist archive and appcast. Publish the archive before updating the live feed.'
