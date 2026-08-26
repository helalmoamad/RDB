# Testable Features — Ramaaz Digital Bank (RDB)

> Quick reference for QA. Each numbered line is one testable feature.
>
> **Scope:** this document covers **only the `rdb` repository** (the native shell:
> onboarding, authentication, passcode, app lock, device security).
> Features delivered by the `trydos_wallet` package (wallet, balances, transfers,
> QR, deposits, transactions, KYC, profile, settings, sessions) are **out of scope
> here** — they are covered by a separate test document owned by another developer.

---

## 1. App Startup & Splash

1. Splash screen appears on launch and navigates automatically.
2. New user (not registered) → lands on the Registration / Welcome screen.
3. Registered user with a passcode set → lands on the Passcode Entry screen.
4. Registered user without a passcode → lands on the Set Passcode screen.
5. Rooted / jailbroken device is detected → security warning screen blocks usage.
6. App backgrounded during splash, then resumed → resolves to the correct screen.

## 2. Registration (New Account)

7. Select country from the available-countries list.
8. Enter phone number; invalid formats are rejected.
9. Choose OTP delivery channel: **WhatsApp** or **SMS**.
10. Receive and enter the OTP code.
11. Resend OTP after the countdown expires.
12. Wrong OTP shows an error message.
13. Expired OTP shows an "code expired" message and allows resend.
14. Already-registered number → "number already in use" with a Login option.
15. Unregistered number → "number not registered" with a Create Account option.
16. Enter full name (first + last).
17. Wallet is created automatically once registration completes.
18. "Registration completed" screen, then redirect to Set Passcode.

## 3. Login

19. Log in with phone number + OTP.
20. "Login successful" screen is shown.
21. Step-passcode verification is requested after login.
22. Access token is refreshed automatically when it expires.
23. Session expiry redirects the user back to login.
24. Token is refreshed proactively when the app returns from background.

## 4. Passcode (PIN)

25. Create a new passcode and confirm it.
26. Mismatched confirmation is rejected.
27. Enter passcode to unlock the app.
28. Wrong passcode shows an error message.
29. Change passcode.
30. Input direction is correct for RTL (Arabic / Kurdish) and LTR (English / Turkish).
31. Focus lands automatically on the first empty box.
32. Tapping a later box while an earlier one is empty jumps focus back.
33. Focus returns to the first empty box after the keyboard is dismissed and reopened.

## 5. Progressive Lockout

34. Lock triggers after **5 wrong attempts** → 30 seconds.
35. Each subsequent wrong attempt escalates: 30 s → 1 min → 30 min → 1 h → 1 day → 1 week → 1 month (cap).
36. Countdown survives app close/reopen (state is persisted).
37. Passcode input and back navigation are blocked while locked.
38. A correct passcode resets all counters and the lockout level.
39. A successful biometric unlock also resets all counters and the level.
40. Lockout messages render correctly in all four languages (EN / AR / KU / TR).

## 6. Forgot Passcode (Reset Flow)

41. Start the "forgot passcode" flow.
42. Enter and validate the phone number.
43. Choose a verification method (OTP / security questions / face re-verification).
44. Verify via OTP.
45. Answer security questions.
46. Face re-verification (liveness selfie).
47. Set a new passcode after successful verification.
48. Success / failure result screens.
49. Flow works from the **idle-lock** entry point (app locked, access token).
50. Flow works from the **mid-login step** entry point (step token).
51. Expired reset session is handled gracefully and returns the user to a safe screen.

## 7. Biometric Authentication

52. Enable fingerprint / Face ID.
53. Unlock the app with biometrics instead of the passcode.
54. Biometric failure falls back to passcode entry.
55. Registered passkeys are listed correctly.

## 8. App Lock & Background Behaviour

56. App content is hidden when moving to background (no preview in the task switcher).
57. Passcode is requested when returning from background.
58. The lock layer covers every route, including inner wallet/KYC screens.
59. Web↔App switch screen appears with its countdown.
60. The switch countdown continues (is not reset) when the event repeats or the app resumes.
61. Third-party keyboard warning on Android, with an option to switch to a secure keyboard.
62. Logout clears all local state: passcode, tokens, name, verification flags.

## 9. Notifications (RDB Side)

63. Notification permission is requested once the app is unlocked.
64. FCM token is registered on login.
65. FCM token is unregistered on logout.
66. Notification received while the app is in the foreground.
67. Notification received while the app is in the background or terminated.
68. Tapping a notification opens the correct screen.
69. A pending approval request received in the background is consumed on next unlock.

## 10. Network & Error Handling

70. No internet → "No internet connection" screen/alert is shown.
71. Connection restored → the app resumes normally.
72. API errors surface as readable user-facing messages.
73. Retry action works after a failed request.
74. Loading indicators / shimmers show while data is being fetched.

## 11. Localization

75. Switch language: English / Arabic / Kurdish / Turkish.
76. UI direction (RTL/LTR) applies immediately after the switch.
77. Selected language persists across app restarts.
78. A language change triggered from the wallet layer is applied and persisted by the app shell.

## 12. Deep Links

79. App opens from a deep link on the allowed host only.
80. Links from a non-allowed host are ignored.
81. The correct screen is opened based on the link payload.

## 13. Device & App Security

82. Screenshot / screen-recording protection is active on sensitive screens.
83. No sensitive data (tokens, passcode) is written to logs in release builds.
84. No token or passcode leaks after logout.
85. Root/jailbreak check runs on every cold start, not only the first launch.

---

**Total: 85 features**
