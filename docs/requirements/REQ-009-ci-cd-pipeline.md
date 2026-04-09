# REQ-009 — CI/CD Pipeline

## Summary
Automated pipeline that runs tests, builds the app, and publishes it to the App Store.

## Acceptance Criteria

1. **Test stage** — all unit tests and UI tests run automatically; pipeline fails if any test fails
2. **Build stage** — app is built with release configuration and signed for App Store distribution
3. **Publish stage** — signed IPA is uploaded to App Store Connect (TestFlight initially, then App Store review)
4. **Trigger** — pipeline runs automatically on push to `main` branch
5. **Secrets management** — signing credentials and App Store Connect API key stored as CI secrets, never in the repo
6. **Notifications** — pipeline status visible in the repository (pass/fail badge or check)

## Out of Scope
- Automatic App Store review submission (upload to TestFlight is sufficient for v1)
- Multiple environments / staging builds

## Story Points: 5
