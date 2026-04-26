# Test Handoff - 2026-04-22

## Scope
- Implemented progressive PIN lockout flow in authentication.
- Added persistent lockout state storage to preferences layer.
- Added localization keys/messages for lockout screen in 4 languages.

## Functional Changes
- After 5 wrong PIN attempts, user is locked for 30 seconds.
- After lock expiry, each next wrong attempt escalates lock duration.
- Lockout durations now escalate as:
  - 30 seconds
  - 1 minute
  - 30 minutes
  - 1 hour
  - 1 day
  - 1 week
  - 1 month (cap)
- Lockout state is persistent across app close/open and screen re-entry.
- On successful PIN or biometric authentication, lockout state resets.
- During lockout, dedicated screen is shown with live countdown.


## Suggested Test Cases
- Verify first lock after exactly 5 wrong attempts.
- Verify lock timer continues correctly after app restart.
- Verify escalation sequence after each post-lock wrong attempt.
- Verify lock UI prevents PIN input and back navigation.
- Verify successful PIN resets all lock counters/levels.
- Verify biometric success also resets lock counters/levels.
- Verify lockout messages render correctly in EN/AR/KU/TR.



1. Financial Ledger Filter by Asset
- Select a currency on Home (example: USD).
- Confirm transactions reload with asset filter (assetSymbol=USD).
- Deselect currency and confirm full unfiltered transactions return.
- Confirm pagination still works before and after filter change.

2. Shimmer on Reload and Filter Change
- Change selected currency while transactions are visible.
- Confirm transactions shimmer appears during reload.
- Confirm old list is not shown while loading.
- Confirm load-more still shows bottom loader only (not full shimmer).

3. Persist Hide Balance State
- Hide balances using eye icon on Home.
- Close and reopen app.
- Confirm hidden state is restored.
- Show balances again, reopen app, confirm shown state is restored.

4. Manual Account Input Auto Hyphen
- Open Send Transfer modal in Account input mode.
- Type 00125555 and confirm it becomes 0012-5555 automatically.
- Continue editing and confirm only one hyphen remains after first 4 digits.
- Switch to Phone input and confirm auto hyphen is not applied.

5. Realtime Wallet Events (WebSocket) - 2026-04-26
- Start app and confirm socket connects/authenticates (`Connected...` then `Authenticated by server`).
- Send `ledger:created` for a new id and confirm transaction appears at top of list.
- Send duplicate `ledger:created` with same id and confirm no duplicate row is added.
- With asset filter active (example: USD), send `ledger:created` for another asset (example: SYP) and confirm it is ignored.
- Send `ledger:completed` / `ledger:failed` / `ledger:cancelled` for an existing id and confirm only `status` updates.
- Send `ledger:completed` / `ledger:failed` / `ledger:cancelled` for a non-existing id and confirm no row is created.
- Send `balance:updated` and confirm balance card values refresh without full page reload.
- Change app language (EN/AR) and confirm realtime transaction title/metadata text follows active language with fallback.

