# Dot Glass Personal

Personal build of the independent Dot Glass widget for DockDoor Pro. This repository is public at the owner's request; “Private” in its name identifies the personal release channel, not its visibility.

Native glass conversation UI, six ring/chat themes, and real ChatGPT Dot voice through an embedded owned WebKit session. Requires ChatGPT Dot access and microphone permission for calls. Unofficial UI integration; not affiliated with OpenAI. Site changes can affect compatibility.

Marketplace source is maintained separately at https://github.com/appleforever11/DotGlass-Marketplace. The personal widget uses `dot-glass-personal`, a separate website store, and separate preferences. It does not update or depend on Codex Tracker or marketplace Dot Glass.

## Build and test

- `bash script/test.sh`
- `bash script/build-personal.sh` builds a universal personal companion and widget under `/tmp/dot-glass-personal-companion`.
- `bash script/build_and_run.sh --build-only` builds the standalone widget preview.
- `bash script/prepare-release.sh` requires `DOT_GLASS_SIGNING_IDENTITY` and `DOT_GLASS_NOTARY_PROFILE`, validates notarization, then prepares the archive and signed feed in `dist/`. It never publishes.

The companion installs only DotGlassPersonal.bundle and retains a previous copy. Restart DockDoor manually after installation. Sparkle updates the companion; use its Install / update button to apply the bundled widget afterward. No background agent or hidden host restart is installed.

## Personal update channel

Feed: https://raw.githubusercontent.com/appleforever11/DotGlass-Private/main/distribution/appcast.xml

`Config/release.json` declares this channel. Sparkle 2.9.6 is checksum-pinned. A unique Ed25519 key is stored in the local Keychain account `dot-glass-personal`; only the public key is committed. Never export private signing material into this repository.

The initial feed is intentionally empty. The current build is locally ad-hoc signed; there is no notarized downloadable release yet. A Developer ID identity was unavailable during preparation. Publish a verified archive at the feed's enclosure URL before replacing the live feed with `dist/appcast.xml`. Do not advertise an empty channel as a completed update delivery test.

## Privacy

Messages and drafts stay in memory. WebKit owns normal authenticated website storage. The adapter neither reads nor exports credentials, tokens or cookies, and does not call private backend APIs. It invokes visible ChatGPT controls, using guarded message acknowledgment. Voice animation uses inbound WebRTC level metadata; no audio recordings or Apple speech synthesis are made.
