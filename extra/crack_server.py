# language: Python 3.10+, file: crack_server.py
# Local license mock for Clarity Makcu v2.8 (PlatoBoost + KeyAuth layers).
# Patches both auth URLs to http://127.0.0.1:8443 and answers every endpoint
# with a forged VALID response.
import http.server
import hashlib
import json
import os
import sys
import time
from urllib.parse import urlparse, parse_qs

SECRET = "5bebe11a-ac4e-42f9-9f0c-5f1a11efa17b"
OWNERID = "LumfhGswLC"
PORT = 8443
LOGFILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "crack_server.log")


def _log(*parts):
    line = " ".join(str(p) for p in parts)
    try:
        with open(LOGFILE, "a", encoding="utf-8") as f:
            f.write(f"[{time.strftime('%H:%M:%S')}] {line}\n")
    except Exception:
        pass
    sys.stderr.write(f"[mock] {line}\n")


def sig(valid: str, nonce: str) -> str:
    return hashlib.sha256(f"{valid}-{nonce}-{SECRET}".encode()).hexdigest()


def keyauth_init():
    return {
        "success": True,
        "code": 68,
        "message": "Initialized",
        "sessionid": "mocksession",
        "appinfo": {
            "numUsers": "1",
            "numOnlineUsers": "1",
            "numKeys": "1",
            "version": "1.0",
            "customerPanelLink": "https://keyauth.cc/panel/",
        },
        "newSession": True,
        "nonce": "mocknonce",
        "ownerid": OWNERID,
    }


def keyauth_license():
    return {
        "success": True,
        "message": "Successfully Authenticated",
        "info": {
            "username": "cracked",
            "subscriptions": ["default"],
            "subscriptions_expiry": "2099-01-01T00:00:00",
            "ip": "127.0.0.1",
            "hwid": "mock-hwid",
            "createdate": "2026-01-01",
            "lastlogin": "2026-10-07",
        },
        "nonce": "mocknonce",
    }


class Handler(http.server.BaseHTTPRequestHandler):
    def _send(self, obj, status=200):
        body = json.dumps(obj).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _route(self, path):
        idx = path.find("/public/")
        return path[idx:] if idx >= 0 else path

    def _keyauth(self, body: bytes):
        """Handle KeyAuth POSTs: form-encoded data with a `type` field."""
        try:
            text = body.decode("utf-8", "replace")
        except Exception:
            text = ""
        try:
            form = parse_qs(text)
        except Exception:
            form = {}
        ktype = form.get("type", [""])[0]
        _log("KEYAUTH", "type=", ktype, "body=", text[:400])
        if ktype == "init":
            return self._send(keyauth_init())
        if ktype in ("license", "login"):
            return self._send(keyauth_license())
        if ktype == "check":
            return self._send({"success": True, "message": "Success", "sessionid": form.get("sessionid", ["mocksession"])[0]})
        # any other KeyAuth type -> harmless success
        return self._send({"success": True, "message": "Success"})

    def do_GET(self):
        u = urlparse(self.path)
        q = parse_qs(u.query)
        nonce = q.get("nonce", [""])[0]
        p = self._route(u.path)
        _log("GET", self.path)

        if p == "/public/connectivity":
            return self._send({"success": True})

        if p.startswith("/public/whitelist"):
            return self._send({"success": True,
                               "data": {"valid": True, "hash": sig("true", nonce)}})

        if p.startswith("/public/flag"):
            return self._send({"success": True, "data": {"value": True}})

        return self._send({"success": True, "data": {}})

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0) or 0)
        body = self.rfile.read(length) if length else b""
        u = urlparse(self.path)
        q = parse_qs(u.query)
        nonce = q.get("nonce", [""])[0]
        p = self._route(u.path)
        _log("POST", self.path, "body=", body[:300])

        # KeyAuth layer: form-encoded, no /public/ path
        if "/public/" not in u.path:
            return self._keyauth(body)

        if p == "/public/start":
            return self._send({"success": True, "data": {"url": ""}})

        if p.startswith("/public/redeem"):
            return self._send({"success": True,
                               "data": {"valid": True, "hash": sig("true", nonce)}})

        return self._send({"success": True, "data": {}})

    def log_message(self, fmt, *args):
        sys.stderr.write("[mock] %s %s\n" % (self.command, self.path))


if __name__ == "__main__":
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    print(f"crack server listening on http://127.0.0.1:{PORT}")
    srv.serve_forever()
