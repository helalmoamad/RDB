# Reset Passcode — Face Re-Verify for Verified Users at the Login Passcode Step

**Type:** Feature + Bug fixes
**Priority:** High
**Mode:** high_risk (auth/session + KYC)
**Owner:** developer
**Created:** 2026-07-20
**Links:** ADR-012 · ADR-013 · ClickUp 86eyagcd6

---

## Summary

A KYC-verified user who taps "Forgot Passcode" at the **login passcode step**
(mid-login) is now sent through **face re-verification** instead of the security
questions. The security-question path stays unchanged for non-verified users and
for users who are already logged in (idle-lock).

Before this work the mid-login face branch was **completely broken** — the app
sent the wrong credential to the KYC Worker and every call returned 401. Six
additional dead-end paths were found and fixed during implementation.

---

## Background

Two integration guides drive this change:

| Guide | Covers |
|---|---|
| `RESET_PASSCODE_STEP_FACE_WEB_INTEGRATION.md` | NestJS contract — `step/init`, `step/complete`, failure matrix |
| `FLUTTER_KYC_INTEGRATION.md` | KYC Worker contract — auth headers, `reverify/verify`, error codes |

Key rule that drives most of the work: **the same session stepToken is sent in
two different headers depending on the server.**

| Server | Header |
|---|---|
| NestJS (`auth/reset-passcode/step/*`) | `Authorization: Bearer <stepToken>` |
| KYC Worker (`api/kyc/reverify/*`) | `X-Step-Token: <stepToken>` — Bearer explicitly forbidden |

---

## User Story

> As a KYC-verified user who forgot my passcode at the login screen,
> I want to prove my identity with my face instead of answering security questions,
> so that I can set a new passcode and finish signing in.

---

## Scope

### In scope
- Face branch for verified users at the mid-login entry point.
- Correct credential per server (Bearer vs `X-Step-Token`).
- Full failure-matrix handling: 401, 403, 409, 410, `locked_out`,
  `LIVENESS_FAILED`, `FACE_NOT_DETECTED`, `NO_ENROLLED_SELFIE`, 422, 502.
- Per-request header isolation (security fix, app-wide).

### Out of scope
- KYC onboarding / selfie enrolment (§3 of the Worker guide).
- AWS Amplify streaming liveness (§4) — the app uses the single-frame path.
- Backend/Worker fixes (see Known blockers).

---

## What changed

### 1. Blocking defect — wrong credential to the KYC Worker
Mid-login has no access token yet, so `walletToken` is an empty string. It was
still being sent as `Authorization: Bearer ` → every KYC call returned 401.
Now mid-login sends `X-Step-Token` and **no** Bearer at all.

### 2. Face proof separated from the quiz token
The backend calls three different things `stepToken`. The face proof was being
stored in the same field as the quiz `resetToken`. They are now separate fields
and travel in different places:

| Branch | Header | Body |
|---|---|---|
| Face | `X-Face-Step-Token` | `passcode` only |
| Questions | — | `passcode` + `resetToken` |

### 3. `reverify/start` no longer called
Per Worker guide §4 it exists only for the AWS Amplify streaming UI. It was
gating the capture button, so its failure (404/502) blocked a flow that never
needed it. `challengeId` comes from `step/init`, not from `start`.

### 4. Failure matrix

| Signal | Before | After |
|---|---|---|
| 401 on `step/*` | stuck on a screen using the dead token | clear token → back to phone/OTP |
| 401 on `reverify/verify` | — | invalid challenge → fresh challenge |
| 403 on `complete` | exit whole flow | restart from `init` |
| 409 "face required" | exit | switch to face branch |
| 409 "phone verification required" | exit with raw error | treated as expired session → re-login |
| 410 | generic error | fresh challenge |
| `locked_out` | "Try again" (useless) | terminal → fresh challenge |
| `NO_ENROLLED_SELFIE` | infinite retry loop | terminal → exit with reason |
| `LIVENESS_FAILED` / `FACE_NOT_DETECTED` | generic message | server message + retake |

### 5. Listener defects found during audit
Five stale-state bugs where a consumed status kept re-matching and blocking
later branches. Most severe: **face success never navigated to the new-passcode
screen**, via two separate entry paths.

### 6. Security — header leak (app-wide)
Headers were written into the shared Dio map, so any `extraHeaders` persisted on
every later request — a single-use face proof would have leaked to profile,
balance and notification calls. Each request now builds its own header map and
drops any earlier `Authorization`.

### 7. Other
- 30 s timeout on KYC calls (backend hangs ~100 s otherwise).
- PostHog session-replay debug logging disabled (console noise).
- 6 new localization keys × 4 languages.

---

## Acceptance Criteria

- **AC-1** A verified user at the login passcode step who taps "Forgot Passcode" is shown the camera screen, not the questions.
- **AC-2** Mid-login KYC requests carry `X-Step-Token` and **no** `Authorization` header.
- **AC-3** Idle-lock KYC requests carry `Authorization: Bearer <accessToken>` and no `X-Step-Token`.
- **AC-4** `reverify/verify` body contains exactly `challengeId` and `liveFaceImageData` — no `sessionId`.
- **AC-5** `reverify/start` is never called.
- **AC-6** On face success, `step/complete` carries `X-Face-Step-Token` and the body holds only `passcode`.
- **AC-7** On questions success, `step/complete` body holds `passcode` + `resetToken` and carries no face-proof header.
- **AC-8** After a successful reset the user returns to the login passcode screen with a confirmation toast — never to Home.
- **AC-9** The old passcode is rejected and the new one is accepted afterwards.
- **AC-10** `locked_out` shows a terminal message and its button issues a **new** `challengeId`.
- **AC-11** An expired/invalid challenge (410 / 401) behaves the same as AC-10.
- **AC-12** A retryable failure (`LIVENESS_FAILED`, `FACE_NOT_DETECTED`, liveness, mismatch) shows the server message and allows another capture on the same challenge.
- **AC-13** `NO_ENROLLED_SELFIE` exits the flow with a reason — no retry loop.
- **AC-14** An expired session (401 on any `step/*`) clears the step token and returns to the phone screen.
- **AC-15** A non-verified user still gets the questions path, unchanged, at both entry points.
- **AC-16** No `X-Face-Step-Token` appears on any request after the flow completes.
- **AC-17** The capture button is enabled by camera readiness alone — no network call gates it.

---

## Test Cases

> **Setup:** account **A** = KYC-verified (selfie enrolled) · account **B** = not verified.
> A proxy (Charles / Proxyman) is **required** — most of these fixes are invisible in the UI.
>
> **Entry points:** *mid-login* = sign out, enter phone + OTP, stop at the passcode screen.
> *idle-lock* = already signed in, passcode screen after idle timeout.

### TC-1 — Happy path, mid-login + verified ⭐ (AC-1,2,4,5,6,8,9)
1. Account **A**, mid-login → tap "Forgot Passcode" → "Start".
2. Expect the **camera** screen (no questions).
3. **Proxy — `step/init`:** response contains `stepUp.method = "face"` and a `challengeId`.
4. **Proxy — no `reverify/start` request exists at all.**
5. Capture your face.
6. **Proxy — `reverify/verify`:** header `X-Step-Token` present · **no `Authorization` header** · body has only `challengeId` + `liveFaceImageData`.
7. On success the new-passcode screen appears.
8. Enter and confirm a new passcode.
9. **Proxy — `step/complete`:** header `X-Face-Step-Token` present · body is `{"passcode": "..."}` **without `resetToken`**.
10. Expect a toast, then the **login passcode screen** — not Home.
11. Sign in with the **new** passcode → succeeds.
12. Sign out, try the **old** passcode → rejected.

> Steps 6 and 9 are the core of this ticket. A Bearer header at step 6, or a
> `resetToken` in the body at step 9, means the fix regressed.

### TC-2 — Retryable face failure (AC-12,17)
1. Reach the camera screen.
2. Cover the lens, or have a different person capture.
3. Expect the server's message and a **"Try again"** button.
4. Tap it → captures again on the **same** challenge (no new `step/init`).

### TC-3 — Attempts exhausted ⭐ (AC-10)
1. Fail verification **3 times**.
2. Expect "You've used all available attempts" and a **"Start over"** button.
3. Confirm **no** security-questions fallback is offered.
4. Tap "Start over".
5. **Proxy:** a **`step/init`** request fires (not `reverify/start`) and returns a **different `challengeId`**.
6. The screen returns to normal capture state — it must not stay on the lockout message.

### TC-4 — Expired challenge (AC-11)
1. Reach the camera screen and wait > 10 minutes.
2. Capture.
3. Expect an expiry message + "Start over", and a new `challengeId` on tap (as TC-3 steps 5-6).

### TC-5 — Consumed proof, 403 (AC-11)
1. Pass face verification, then wait for the proof to expire (needs backend help or > 10 min).
2. Enter the new passcode.
3. Expect "verification expired, starting over" and a return to the **flow intro** — not a full exit.

### TC-6 — Expired session ⭐ (AC-14)
1. Sit on the login passcode screen > 10 minutes (stepToken lifetime).
2. Start the reset flow.
3. Expect "session expired, please sign in again".
4. Expect the **phone screen** — not the passcode screen.
5. Confirm phone + OTP sign-in still works.

### TC-7 — No enrolled selfie (AC-13)
1. Use a verified account whose selfie is missing (or reproduce the known backend gap).
2. Reach the camera and capture.
3. Expect the flow to **exit with a reason** — no endless "Try again".

### TC-8 — Non-verified regression, mid-login (AC-7,15)
1. Account **B**, mid-login → "Forgot Passcode" → "Start".
2. Expect the **questions** (no camera).
3. Answer correctly → new-passcode screen.
4. **Proxy — `step/complete`:** body contains **`resetToken`** · **no** `X-Face-Step-Token`.
5. Complete → toast → login passcode screen.
6. Repeat with wrong answers → "Try again" page showing remaining attempts.
7. Exhaust attempts → lockout page with countdown.

### TC-9 — Idle-lock regression ⭐ (AC-3,15)
1. Account **A**, idle-lock → face flow.
2. **Proxy — `reverify/verify`:** `Authorization: Bearer <accessToken>` · **no** `X-Step-Token`.
3. Complete the flow successfully.
4. Account **B**, idle-lock → phone → send-otp → OTP → questions → new passcode.

> TC-9 step 4 is the **longest existing path** — it must not regress.

### TC-10 — Header leak ⭐ (AC-16)
1. Complete a face flow successfully (TC-1).
2. Browse the app: profile, balances, notifications.
3. **Proxy:** confirm **no** later request carries `X-Face-Step-Token`.

> A leaked single-use proof on unrelated requests is a security defect.

### TC-11 — App-wide smoke test (header isolation)
The header fix touches **every** request in the app, not just this feature.
1. Sign in normally.
2. Exercise wallet, transfers, profile, notifications, country detection.
3. Expect no unexpected 401s.

### TC-12 — Localization
Switch between Arabic, English, Kurdish and Turkish and confirm the six new
messages render translated, not as raw keys:
`face_verify_locked_out` · `face_verify_expired` · `face_verify_restart` ·
`reset_proof_expired_restart` · `reset_session_expired_relogin` ·
`reset_passcode_updated`

### TC-13 — Camera permissions
1. Deny camera permission → clear message + settings button.
2. Grant from settings and return → preview works.
3. Background the app mid-capture and return → no crash.

---

## Test Priority

| Priority | Cases | Why |
|---|---|---|
| 🔴 Critical | TC-1, TC-10, TC-11 | Core flow · security · app-wide blast radius |
| 🟠 High | TC-3, TC-6, TC-8, TC-9 | Previously dead ends · regression of existing paths |
| 🟡 Medium | TC-2, TC-4, TC-5, TC-7 | Less frequent failure modes |
| 🟢 Low | TC-12, TC-13 | Localization · permissions |

---

## Known blockers (not client-side)

| Blocker | Owner | Effect |
|---|---|---|
| `/kyc/reverify/{id}/validate` does not return `selfieImageUrl` (ADR-013) | NestJS | `NO_ENROLLED_SELFIE` in mid-login for enrolled users — **blocks TC-1 until fixed** |
| `step/questions` returns 409 "Phone verification required first" for non-verified users, though the guide says they are unchanged | NestJS | Affects TC-8 |
| Error discrimination relies on message text (`face` / `phone` substrings) | NestJS | Fragile — a reworded message breaks it silently. Semantic codes requested. |

---

## Risks

- **Header isolation is app-wide.** A path that accidentally relied on a leaked
  token will now fail — TC-11 exists to catch that.
- **`X-Step-Token` removed from the idle-lock questions `complete`.** It was
  previously sent on every call; the guide indicates the backend reads
  `resetToken` from the body, but this is unproven — TC-9 covers it.
- **Message-text matching** for 409 discrimination (see blockers).

---

## Definition of Done

- All 17 acceptance criteria verified.
- 🔴 and 🟠 test cases pass on a real device against dev.
- No new 401s in the TC-11 smoke test.
- Known blockers either resolved or explicitly accepted.
