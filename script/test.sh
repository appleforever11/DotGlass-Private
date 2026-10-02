#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p /tmp/dot-glass-tests
swiftc Widgets/DotGlass/DotModels.swift Widgets/DotGlass/DotDirectory.swift Tests/URLPolicyTests.swift -o /tmp/dot-glass-tests/url-policy
/tmp/dot-glass-tests/url-policy
node --test Tests/adapter.test.mjs
