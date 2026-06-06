import base64
s = 'eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoidkgzUXkyMFc4S2hETG50T1R6aF9JVXNMaVM2TU0ya0ZWSWZPV0lDdmRwayIsIm9yaWdpbiI6ImFuZHJvaWQ6YXBrLWtleS1oYXNoOmZfcU9UX3R4ZzV3bE1LOXlIcmtuNU94bkluaFZCTENNTGlqdXNrY3VLdE0iLCJhbmRyb2lkUGFja2FnZU5hbWUiOiJjb20ucmRiLnd3dyJ9'
s += '=' * ((4 - len(s) % 4) % 4)
print(base64.urlsafe_b64decode(s).decode())
