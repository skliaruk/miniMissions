# REQ-010: Freemium — Free and Premium Tiers

**Status:** Approved
**Priority:** Must
**Effort:** L

## Description

The app has two tiers: Free and Premium. Free users can use the app with limited features. Premium is unlocked with a one-time in-app purchase.

## Free Tier (default)

- Add children (max 6, same as before)
- **One topic only** — user can create and use exactly one topic
- Tasks within that one topic work normally (task bank, assignments, completion)
- All existing task bank and child management features work within the one-topic limit

## Premium Tier (paid, one-time purchase)

Unlocks everything in the free tier plus:
- **Unlimited topics** — add as many topics as needed
- All other current features remain accessible

## Paywall Behaviour

- When a free user tries to **add a second topic**, a paywall sheet appears
- Paywall shows: app name, premium benefit list, one-time price, "Unlock Premium" button, "Restore Purchase" button, "Not now" dismiss
- After successful purchase or restore, the action proceeds immediately (topic is added)
- Existing users who already have >1 topic (e.g. migrated from old version) are treated as Premium

## In-App Purchase

- Product type: **Non-consumable** (one-time purchase, permanent unlock)
- Product ID: `com.morningroutine.premium`
- StoreKit 2 API (iOS 15+)
- Purchase state persisted via StoreKit's built-in transaction verification (no custom server)
- Restore Purchases available in paywall and in Settings section of parent management

## Acceptance Criteria

1. Free user sees one topic working normally
2. Free user tapping "+ Add Topic" when one topic exists sees paywall sheet
3. Paywall shows localized price and "Unlock Premium" button
4. Successful purchase dismisses paywall and adds the topic
5. "Restore Purchase" restores a previous purchase and unlocks premium
6. Premium user can add unlimited topics normally
7. "Restore Purchase" button appears in Settings section of parent management
8. All three languages (fi, en, ru) show correct paywall text
9. Existing users with >1 topic are not locked out (treated as premium)

## Out of Scope

- Subscription model
- Server-side receipt validation
- Analytics or paywall A/B testing
- Free trial
