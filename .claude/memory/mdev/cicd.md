# CI/CD Pipeline

Created 2026-04-09 per ADR-007.

## Files
- `.github/workflows/ci.yml` — runs on every push/PR, unit + UI tests on iPad Air simulator
- `.github/workflows/release.yml` — runs on push to main, test job + release job (archive, export IPA, upload to TestFlight)
- `ExportOptions.plist` — app-store export config, team ID PDG55XDJMV, automatic signing
- `README.md` — status badges (OWNER placeholder)

## Key decisions
- Runner: macos-15
- Xcode: 16.2 pinned via DEVELOPER_DIR
- Simulator: iPad Air (5th generation), OS 17.5, explicitly booted before tests
- No xcpretty/xcbeautify — raw xcodebuild output
- set -o pipefail on all xcodebuild steps
- API key cleanup runs with `if: always()`
- Concurrency groups cancel superseded runs

## Required GitHub Secrets
- APP_STORE_CONNECT_API_KEY — the .p8 key content
- API_KEY_ID — App Store Connect API key ID
- API_ISSUER_ID — App Store Connect issuer ID
