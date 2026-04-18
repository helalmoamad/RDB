# Test Scenarios: PIN Authentication & App Navigation

This document outlines the test cases for the PIN authentication system, app lifecycle management, and navigation logic for Ramaaz Digital Bank.

## 1. Application Startup & Splash Screen
| # | Scenario | Expected Result |
|---|---|---|
| 1.1 | **First Launch (Not Logged In)** | App opens splash screen, stays for ~6.3s, then navigates to the **Registration/Welcome** page. |
| 1.2 | **Logged In Launch (PIN Set)** | App opens splash screen, then navigates directly to the **PIN Entry** screen. |
| 1.3 | **Logged In Launch (No PIN Set)** | App opens splash screen, then navigates to the **Set PIN** screen. |

## 2. Registration & Login Flow
| # | Scenario | Expected Result |
|---|---|---|
| 2.1 | **Login with Phone (WhatsApp)** | Enter valid phone, choose WhatsApp. Verify OTP is received. Enter correct OTP. |
| 2.2 | **Number Already Registered** | Enter a phone number that is **already in use**. Verify app shows "This number is already registered" and offers Login. |
| 2.3 | **Number Not Registered** | Enter a phone number that is **NOT in our system**. Verify app shows "Number not registered" and offers "Create Account". |
| 2.4 | **New User Registration** | Register with a new number. Enter OTP -> Add Full Name -> Redirect to Set PIN. |
| 2.5 | **Invalid OTP** | Enter wrong OTP 3 times. Verify error message and "Resend" button functionality. |
| 2.6 | **Expired OTP** | Wait until OTP expires. Verify "Code Expired" message and ability to resend. |

## 3. App Lifecycle (Background/Foreground)
| # | Scenario | Expected Result |
|---|---|---|
| 3.1 | **Resume while Logged In** | Open the app, log in, navigate to Home. Put app in background. Return to foreground. App must show the **PIN Entry** screen. |
| 3.2 | **Resume while Not Logged In** | Put app in background on the Registration page. Return to foreground. App stays on Registration. |
| 3.3 | **Resume from Splash** | Put app in background during the splash screen video. Return to foreground. App should eventually show the **PIN screen**. |

## 4. PIN Input Logic & UX
| # | Scenario | Expected Result |
|---|---|---|
| 4.1 | **LTR Layout (Arabic/English)** | Switch app language to Arabic. Open PIN page. Verify that boxes start from the **LEFT** and entries move left-to-right. |
| 4.2 | **Automated Focus** | Open PIN page. The cursor must automatically start in the **first box on the left**. |
| 4.3 | **Focus Redirection** | Tap on the 4th box while the 1st is empty. Focus should automatically jump back to the **1st box**. |
| 4.4 | **Loss of Focus** | Minimize the keyboard and re-tap the PIN area or type. Focus must always return to the **first empty box**. |

## 5. Wallet & Transactions
| # | Scenario | Expected Result |
|---|---|---|
| 5.1 | **View Balance** | Balance should be visible on the Home screen. Toggling "View/Hide" should work correctly. |
| 5.2 | **Send via Account Number** | Enter a valid Account Number, enter amount, and confirm. Verify success and deduction. |
| 5.3 | **Send via Barcode Scan** | Scan another user's static QR code, enter amount, and confirm payment. |
| 5.4 | **Create Deposit Request** | Create a fixed-amount QR code ("Request Money"). Set expiry time. |
| 5.5 | **Receive via Direct Barcode** | Scan a "Request Money" QR code from another user. Verify amount and expiry are pre-filled. |
| 5.6 | **Insufficient Balance** | Attempt a transaction greater than the current balance. App shows "Insufficient Credit" error. |
| 5.7 | **Transaction History** | Verify Income (green) and Outcome (red) transactions are listed with correct details. |

## 6. General Security & Error Handling
| # | Scenario | Expected Result |
|---|---|---|
| 6.1 | **No Internet Connection** | Turn off Wi-Fi/Data. App should show "No Internet Connected" alert. |
| 6.2 | **Session Expiry** | Force a token expiry (simulated). App should redirect to login/OTP verification. |
| 6.3 | **Logout** | Logout from settings. Verify all user data (passcode, token) is cleared. |
