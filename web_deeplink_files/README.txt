Upload these files to your web server exactly under:
/.well-known/assetlinks.json
/.well-known/apple-app-site-association

Domain:
https://staging-ramaaz-digital-banking.yazan-adnof.workers.dev

Important:
1) assetlinks.json is already filled with current Android debug SHA-256:
	12:5B:32:A9:84:51:66:50:B6:E9:DD:07:95:41:8B:F6:0C:C0:2F:E5:64:6F:99:C6:23:B2:41:0F:62:7D:AC:97
2) In apple-app-site-association, replace PUT_YOUR_APPLE_TEAM_ID with your Apple Developer Team ID.
	Example: ABC123DEF4.com.example.rdb
3) If you use a release keystore on Android, replace SHA-256 with release fingerprint before production.
4) Serve both files with HTTP 200 and without redirects.
5) For apple-app-site-association, do not add .json extension.
