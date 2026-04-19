#!/usr/bin/env python3
"""Probe common localhost ports for running HTTP dev servers.

Outputs JSON: [{"port": N, "url": "http://localhost:N", "server": "<hint>"}, ...]

Usage:
    python detect_dev_servers.py
    python detect_dev_servers.py --ports 3000,5173,8000
    python detect_dev_servers.py --host localhost --ports 8080
"""

import argparse
import json
import socket
import sys
import urllib.request

DEFAULT_PORTS = [3000, 3001, 4200, 5000, 5173, 5500, 8000, 8080, 8888, 9000]


def is_port_open(host: str, port: int, timeout: float = 0.3) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(timeout)
        try:
            s.connect((host, port))
            return True
        except (socket.timeout, ConnectionRefusedError, OSError):
            return False


def probe_http(url: str, timeout: float = 0.5) -> str | None:
    """Return a short hint about the server (e.g. its Server header), or None."""
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "detect_dev_servers"})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            server = resp.headers.get("Server", "")
            return server or "http"
    except Exception:
        return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--ports",
        default=",".join(str(p) for p in DEFAULT_PORTS),
        help="Comma-separated port list",
    )
    parser.add_argument("--host", default="localhost")
    args = parser.parse_args()

    try:
        ports = [int(p.strip()) for p in args.ports.split(",") if p.strip()]
    except ValueError as err:
        print(f"ERROR: bad --ports value: {err}", file=sys.stderr)
        return 2

    results = []
    for port in ports:
        if is_port_open(args.host, port):
            url = f"http://{args.host}:{port}"
            hint = probe_http(url)
            if hint is not None:
                results.append({"port": port, "url": url, "server": hint})

    print(json.dumps(results, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
