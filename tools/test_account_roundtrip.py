"""Real HTTP/WebSocket/PostgreSQL integration in a new disposable local database."""
import argparse
from contextlib import ExitStack
import http.cookiejar
import json
import os
from pathlib import Path
import secrets
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

import psycopg
from psycopg import sql
from websockets.sync.client import connect

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--godot", default="godot")
args = parser.parse_args()
allowed_hosts = ("127.0.0.1", "localhost", "postgres") if os.environ.get("CI") == "true" else ("127.0.0.1", "localhost")
if os.environ.get("PGHOST", "127.0.0.1") not in allowed_hosts:
    raise SystemExit("Integration test requires a local disposable PostgreSQL server")
database = "dreamscape_accounts_test_" + uuid.uuid4().hex[:12]
origin = "http://127.0.0.1:8018"
env = {**os.environ, "PGDATABASE": database, "DREAMSCAPE_DEV": "1", "REGISTRATION_ENABLED": "0",
       "DJANGO_SECRET_KEY": secrets.token_urlsafe(40), "AUTHORITY_SECRET": secrets.token_urlsafe(40),
       "PUBLIC_ORIGIN": origin, "GAME_SOCKET_URL": "ws://127.0.0.1:9090", "GAME_PORT": "9090",
       "ACCOUNT_INTERNAL_URL": origin + "/internal/"}
logs = ROOT / "build/verification/v2/accounts"
logs.mkdir(parents=True, exist_ok=True)
processes = []

def wait_for(check, timeout=20):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            if check(): return
        except (OSError, urllib.error.URLError): pass
        time.sleep(.1)
    raise AssertionError("Service startup timeout")

def browser():
    jar = http.cookiejar.CookieJar()
    client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))
    client.open(origin).close()
    return client, jar

def post(client, jar, path, data=None):
    token = next(c.value for c in jar if c.name == "csrftoken")
    body = urllib.parse.urlencode({**(data or {}), "csrfmiddlewaretoken": token}).encode()
    return client.open(urllib.request.Request(origin + path, body, headers={"Referer": origin + path})).read()

def login():
    client, jar = browser()
    post(client, jar, "/", {"email": "test", "password": "test"})
    return client, jar

def join(stack, client, jar):
    ticket = json.loads(post(client, jar, "/api/ticket/"))
    ws = stack.enter_context(connect(ticket["socket_url"], origin=origin))
    ws.send(json.dumps({"version": 1, "type": "hello", "ticket": ticket["ticket"]}))
    message = receive(ws, "welcome")
    return ws, message["character"], ticket["ticket"]

def receive(ws, wanted):
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        message = json.loads(ws.recv(timeout=10))
        if message["type"] == wanted: return message
        assert message["type"] != "error", message
    raise AssertionError("Missing " + wanted)

def send(ws, kind, **payload):
    ws.send(json.dumps({"version": 1, "type": kind, **payload}))

def start_authority(stack):
    stream = stack.enter_context(open(logs / "roundtrip-authority.log", "a"))
    process = subprocess.Popen([args.godot, "--headless", "--path", str(ROOT / "game"),
                                "res://v2/network/authority.tscn"], env=env, stdout=stream, stderr=subprocess.STDOUT)
    processes.append(process)
    import socket
    def probe():
        with socket.create_connection(("127.0.0.1", 9090), timeout=.1): return True
    wait_for(probe)
    return process

admin = psycopg.connect(dbname="postgres", autocommit=True)
admin.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(database)))
try:
    with ExitStack() as stack:
        import sys
        manage = [sys.executable, str(ROOT / "backend/manage.py")]
        for command in (["migrate", "--noinput"], ["seed_test_account"]):
            subprocess.run(manage + command, env=env, check=True, stdout=subprocess.DEVNULL)
        service_log = stack.enter_context(open(logs / "roundtrip-service.log", "w"))
        service = subprocess.Popen(manage + ["runserver", "127.0.0.1:8018", "--noreload"], env=env,
                                   stdout=service_log, stderr=subprocess.STDOUT)
        processes.append(service)
        wait_for(lambda: urllib.request.urlopen(origin).status == 200)
        authority = start_authority(stack)
        client, jar = login()
        assert b'Crea tu personaje' in client.open(origin).read()
        post(client, jar, "/character/create/", {"name": "Test Viajero", "face": "freckles", "hair": "tied",
             "skin_palette": "olive", "hair_palette": "ink", "upper_palette": "ochre", "lower_palette": "earth"})
        ws, first, ticket = join(stack, client, jar)
        # Replay is rejected, and supplying a position cannot change the simulation.
        replay = stack.enter_context(connect("ws://127.0.0.1:9090", origin=origin))
        send(replay, "hello", ticket=ticket)
        assert receive(replay, "error")["error"] == "invalid_ticket"
        for sequence in range(1, 19):
            send(ws, "move", sequence=sequence, intent=[0, 1], position=[500, 500, 500])
            time.sleep(.05)
        send(ws, "move", sequence=19, intent=[0, 0])
        send(ws, "leave")
        receive(ws, "left")
        ws.close()
        post(client, jar, "/logout/")
        fresh, fresh_jar = login()
        restored_ws, restored, _ = join(stack, fresh, fresh_jar)
        assert restored["id"] == first["id"] and restored["appearance"] == first["appearance"]
        assert restored["position"][2] > first["position"][2] + 1, (first, restored)
        assert abs(restored["position"][0]) < 7 and restored["revision"] > 0
        # A new connection fences the previous one immediately.
        replacement, newest, _ = join(stack, fresh, fresh_jar)
        assert receive(restored_ws, "error")["error"] == "session_replaced"
        send(replacement, "leave")
        receive(replacement, "left")
        replacement.close()
        authority.terminate()
        authority.wait(timeout=10)
        start_authority(stack)
        final_ws, final, _ = join(stack, fresh, fresh_jar)
        assert final["id"] == restored["id"]
        assert all(abs(a - b) < .01 for a, b in zip(final["position"], restored["position"]))
        # Unsupported mutation never reaches a persistence endpoint.
        send(final_ws, "teleport", position=[100, 10, 100])
        assert receive(final_ws, "error")["error"] == "unknown_command"
        print("PASS: first creation, fresh-browser resume, appearance, movement, save acknowledgement,")
        print("ticket replay, forged position, duplicate session fencing, authority restart, invalid command.")
finally:
    for process in reversed(processes):
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=10)
    admin.execute(sql.SQL("DROP DATABASE {} WITH (FORCE)").format(sql.Identifier(database)))
    admin.close()
