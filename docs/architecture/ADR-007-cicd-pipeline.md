# ADR-007: CI/CD Pipeline

**Status:** Proposed
**Date:** 2026-04-09
**Deciders:** ARCH, PO

## Context

REQ-009 requires an automated CI/CD pipeline that runs tests on every push to `main`, builds a release-signed IPA, and uploads it to TestFlight. The project currently has no CI/CD setup: no GitHub Actions workflows, no Fastlane configuration, and no Xcode Cloud connection.

The app is a SwiftUI + SwiftData iPadOS 17+ application (see ADR-001) with three Xcode targets:

- `MiniMissions` (app)
- `MiniMissionsTests` (unit tests, XCTest)
- `MiniMissionsUITests` (E2E tests, XCUITest)

Bundle ID: `fi.minimissions.app`. Development team: `PDG55XDJMV`.

Key constraints:

1. Code signing for App Store distribution requires a certificate and provisioning profile
2. App Store Connect upload requires an API key (Issuer ID, Key ID, private key `.p8` file)
3. UI tests require a simulator runtime (iPadOS 17+)
4. No existing CI infrastructure to migrate from
5. The project uses zero third-party dependencies (ADR-001), so no package resolution step is needed beyond Swift Package Manager defaults

Three decisions must be made:

- **CI platform:** GitHub Actions vs Xcode Cloud
- **Code signing strategy:** Fastlane Match vs manual certificate management vs Xcode automatic signing with API key
- **Build tooling:** Fastlane lanes vs raw `xcodebuild` commands

## Decision

### 1. CI Platform: GitHub Actions

GitHub Actions is selected over Xcode Cloud.

### 2. Code Signing: Xcode Automatic Signing with App Store Connect API Key

The pipeline uses Xcode's built-in automatic signing with an App Store Connect API key, avoiding Fastlane Match and manual certificate management entirely.

### 3. Build Tooling: Raw `xcodebuild` Commands (No Fastlane)

The pipeline uses `xcodebuild` directly, consistent with the project's zero-dependency philosophy (ADR-001).

## Rationale

### GitHub Actions vs Xcode Cloud

| Criterion | GitHub Actions | Xcode Cloud |
|---|---|---|
| Integration with GitHub repo | Native (workflows live in repo) | Requires Apple Developer portal setup; status checks via webhook |
| macOS runner availability | `macos-14` and `macos-15` runners with Xcode 15+/16+ pre-installed | Apple-hosted, always latest Xcode |
| Visibility | Workflow YAML in repo, status badges, PR checks | Status visible in Xcode and App Store Connect, not natively in GitHub |
| Customisability | Full control over every step | Limited to predefined workflow types |
| Cost | 2,000 free minutes/month for private repos (macOS 10x multiplier = 200 effective min); public repos unlimited | 25 compute hours/month free |
| Secret management | GitHub Secrets (encrypted, scoped) | Xcode Cloud manages signing automatically but offers less control for custom steps |
| UI test support | Full control over simulator boot and test execution | Automatic but opaque |
| Pipeline-as-code | YAML checked into `.github/workflows/` | Configured in Xcode/App Store Connect UI |

**Decision rationale:** GitHub Actions is chosen because:

1. **Pipeline-as-code** — the workflow YAML lives in the repository, is version-controlled, and reviewable in PRs. This aligns with the project's transparency principle.
2. **REQ-009 AC6** requires pipeline status visible in the repository. GitHub Actions provides native status badges and PR check integration. Xcode Cloud requires additional webhook configuration to achieve comparable visibility.
3. **Full customisability** — the pipeline can include custom steps (e.g., linting, badge generation, Slack notifications) without being constrained by a predefined workflow structure.
4. **Secret management** — GitHub Secrets provides a well-understood, auditable mechanism for storing signing credentials and API keys.
5. **Cost** — for a single-developer project with infrequent pushes, GitHub Actions free tier is sufficient. Xcode Cloud's 25 hours/month is also adequate, but the visibility and customisability advantages of GitHub Actions outweigh the minor cost difference.

### Xcode Automatic Signing vs Fastlane Match vs Manual Certificates

| Criterion | Xcode Automatic Signing + API Key | Fastlane Match | Manual Certificates |
|---|---|---|---|
| Setup complexity | Low — one API key, no certificate repo | Medium — requires a private Git repo or cloud storage for certificates | Medium — manual export/import of `.p12` and `.mobileprovision` |
| Maintenance | Apple manages certificate rotation | Match manages rotation; requires periodic re-encryption | Fully manual; certificates expire annually |
| Dependencies | None (built into Xcode) | Ruby + Fastlane gem | None |
| Security model | API key as single secret | Encrypted certificate repo + passphrase | Raw certificate + password as secrets |
| Compatibility | Xcode 14+ native support | Mature, well-tested | Always works |

**Decision rationale:** Xcode automatic signing with an App Store Connect API key is chosen because:

1. **Zero dependencies** — no Ruby, no Fastlane gem installation, no certificate repository. This is consistent with ADR-001's zero-dependency philosophy.
2. **Simplicity** — a single `.p8` API key file plus Issuer ID and Key ID are the only secrets needed for signing. Xcode resolves certificates and provisioning profiles automatically.
3. **Apple-supported path** — this is Apple's recommended approach for CI/CD environments since Xcode 14.
4. **No certificate rotation burden** — Apple manages the distribution certificate lifecycle; the API key does not expire (unless revoked).

### Raw `xcodebuild` vs Fastlane

| Criterion | `xcodebuild` | Fastlane |
|---|---|---|
| Dependencies | None (ships with Xcode) | Ruby runtime + gems |
| Learning curve | Higher for complex invocations | Lower (declarative `Fastfile`) |
| Maintenance | Shell commands, explicit flags | Gem updates, Ruby version management |
| Flexibility | Complete control | Abstractions may hide issues |
| Community patterns | Standard Apple documentation | Large community, many plugins |

**Decision rationale:** Raw `xcodebuild` is chosen because:

1. **Zero dependencies** — consistent with ADR-001.
2. **Transparency** — every build flag is explicit and visible in the workflow YAML. No abstraction layer hides what Xcode is actually doing.
3. **Simplicity of this project** — with a single target, single scheme, and no complex multi-environment setup, Fastlane's abstractions provide marginal value.
4. **`altool` / `notarytool` replacement** — Apple's `xcodebuild` now includes `altool` functionality for TestFlight upload, and the newer `xcrun altool` or the App Store Connect API can handle uploads directly.

## Implementation Overview

### Files to Create

```
.github/
  workflows/
    ci.yml              # Test workflow (runs on all pushes and PRs)
    release.yml         # Build + TestFlight upload (runs on push to main)
```

### Workflow 1: `ci.yml` — Test Pipeline

**Trigger:** Push to any branch, pull request to `main`.

**Steps:**

1. Check out repository
2. Select Xcode version (`xcode-select`)
3. Run unit tests:
   ```
   xcodebuild test \
     -project MiniMissions.xcodeproj \
     -scheme MiniMissions \
     -destination 'platform=iOS Simulator,name=iPad Air (5th generation),OS=17.5' \
     -only-testing:MiniMissionsTests \
     -resultBundlePath TestResults/unit.xcresult
   ```
4. Run UI tests:
   ```
   xcodebuild test \
     -project MiniMissions.xcodeproj \
     -scheme MiniMissions \
     -destination 'platform=iOS Simulator,name=iPad Air (5th generation),OS=17.5' \
     -only-testing:MiniMissionsUITests \
     -resultBundlePath TestResults/ui.xcresult
   ```
5. Upload test results as build artifacts (for debugging failures)

### Workflow 2: `release.yml` — Build and Deploy to TestFlight

**Trigger:** Push to `main` branch only (after `ci.yml` tests pass).

**Steps:**

1. Check out repository
2. Select Xcode version
3. Install App Store Connect API key from secrets:
   ```
   mkdir -p ~/.private_keys
   echo "$APP_STORE_CONNECT_API_KEY" > ~/.private_keys/AuthKey_${API_KEY_ID}.p8
   ```
4. Build archive with automatic signing:
   ```
   xcodebuild archive \
     -project MiniMissions.xcodeproj \
     -scheme MiniMissions \
     -destination 'generic/platform=iOS' \
     -archivePath build/MiniMissions.xcarchive \
     -allowProvisioningUpdates \
     -authenticationKeyPath ~/.private_keys/AuthKey_${API_KEY_ID}.p8 \
     -authenticationKeyID $API_KEY_ID \
     -authenticationKeyIssuerID $API_ISSUER_ID
   ```
5. Export IPA for App Store distribution:
   ```
   xcodebuild -exportArchive \
     -archivePath build/MiniMissions.xcarchive \
     -exportPath build/ipa \
     -exportOptionsPlist ExportOptions.plist \
     -allowProvisioningUpdates \
     -authenticationKeyPath ~/.private_keys/AuthKey_${API_KEY_ID}.p8 \
     -authenticationKeyID $API_KEY_ID \
     -authenticationKeyIssuerID $API_ISSUER_ID
   ```
6. Upload to TestFlight:
   ```
   xcrun altool --upload-app \
     -f build/ipa/MiniMissions.ipa \
     --type ios \
     --apiKey $API_KEY_ID \
     --apiIssuer $API_ISSUER_ID
   ```
7. Upload archive and IPA as build artifacts

### `ExportOptions.plist`

A static file checked into the repository root:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>PDG55XDJMV</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

### GitHub Secrets Required

| Secret Name | Description | How to Obtain |
|---|---|---|
| `APP_STORE_CONNECT_API_KEY` | Contents of the `.p8` private key file | App Store Connect > Users and Access > Integrations > App Store Connect API > Generate |
| `API_KEY_ID` | Key ID from App Store Connect | Shown when API key is created (e.g., `ABC1234DEF`) |
| `API_ISSUER_ID` | Issuer ID from App Store Connect | Users and Access > Integrations > Issuer ID (UUID format) |

All three secrets are configured in GitHub repository Settings > Secrets and variables > Actions.

No signing certificate or provisioning profile secrets are needed. Xcode automatic signing with the API key handles certificate and profile resolution at build time.

### Status Badge

Add to `README.md`:

```markdown
![CI](https://github.com/<owner>/MiniMissions/actions/workflows/ci.yml/badge.svg)
![Release](https://github.com/<owner>/MiniMissions/actions/workflows/release.yml/badge.svg)
```

This satisfies REQ-009 AC6 (pipeline status visible in the repository).

### Runner and Xcode Version

The workflows use `macos-15` runner with Xcode 16.x (which includes iPadOS 17+ simulator runtimes). The Xcode version is pinned using:

```yaml
env:
  DEVELOPER_DIR: /Applications/Xcode_16.2.app/Contents/Developer
```

This ensures reproducible builds regardless of runner image updates.

## Consequences

### Positive

- **Zero new dependencies** — no Ruby, no Fastlane, no certificate repository. The CI/CD pipeline uses only tools that ship with Xcode and the GitHub Actions runner.
- **Pipeline-as-code** — both workflows are YAML files checked into the repository, version-controlled and reviewable.
- **Minimal secret surface** — only three secrets (API key contents, Key ID, Issuer ID). No certificates, passwords, or provisioning profiles to manage.
- **Native GitHub integration** — status checks on PRs, badges in README, artifact uploads for debugging test failures.
- **Automatic certificate management** — Xcode resolves and renews distribution certificates and provisioning profiles via the API key, eliminating manual certificate rotation.

### Negative

- **macOS runner cost** — GitHub Actions macOS runners consume minutes at 10x the Linux rate. For a low-frequency project this is within the free tier, but high-frequency pushes could exceed it. Mitigation: the test workflow uses `concurrency` groups to cancel superseded runs.
- **Runner image lag** — GitHub-hosted runners may not have the latest Xcode version on day one of a new release. Mitigation: pin a known-good Xcode version and update deliberately.
- **No Fastlane ecosystem** — advanced Fastlane features (screenshots, metadata upload, changelog automation) are not available. These are out of scope for REQ-009 and can be added later if needed.
- **UI test flakiness on CI** — XCUITest on GitHub Actions simulators can occasionally be flaky due to simulator boot timing or resource contention. Mitigation: add `xcrun simctl boot` as a pre-step with a wait for boot completion, and use `retry` on the test step if needed.
- **`altool` deprecation** — Apple has announced that `altool` will eventually be replaced by `notarytool` and the App Store Connect API for uploads. Mitigation: the workflow can be updated to use `xcrun notarytool` or direct API upload when `altool` is removed. Currently `altool` remains functional for TestFlight uploads.

## Acceptance Criteria Impact

| REQ-009 AC | How Satisfied |
|---|---|
| AC1: All unit + UI tests run automatically; fail = pipeline fail | `ci.yml` runs `xcodebuild test` for both test targets; non-zero exit code fails the workflow |
| AC2: Release build signed for App Store distribution | `release.yml` archives with automatic signing via API key; `ExportOptions.plist` specifies `app-store` method |
| AC3: Signed IPA uploaded to TestFlight | `xcrun altool --upload-app` uploads to App Store Connect / TestFlight |
| AC4: Pipeline runs on push to `main` | Both workflows trigger on `push: branches: [main]`; `ci.yml` also triggers on PRs |
| AC5: Secrets stored as CI secrets, never in repo | Three GitHub Secrets; `.p8` key written to runner filesystem at runtime and cleaned up after |
| AC6: Pipeline status visible in repo | GitHub Actions status badges in README; native PR check integration |
