"""Real HTTP/WebSocket/PostgreSQL integration in a new disposable local database."""
import argparse
from contextlib import ExitStack
import http.cookiejar
import json
import math
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

def exercise_world(stack, client, jar, ws, character):
    """Use real intents/exits, not privileged teleports, across all public maps."""
    state = {"sequence": 0, "position": character["position"]}

    def move(intent):
        state["sequence"] += 1
        send(ws, "move", sequence=state["sequence"], intent=intent)

    def walk_to(x, z, timeout=15):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            px, _, pz = state["position"]
            dx, dz = x - px, z - pz
            distance = math.hypot(dx, dz)
            if distance < .22:
                move([0, 0])
                state["position"] = receive(ws, "snapshot")["position"]
                return
            scale = min(1, distance * 2) / distance
            move([dx * scale, dz * scale])
            state["position"] = receive(ws, "snapshot")["position"]
        raise AssertionError(("Route blocked", state["position"], [x, z]))

    def travel(destination):
        send(ws, "travel", destination=destination, position=[999, 999, 999])
        message = receive(ws, "travelled")
        assert message["place"] == destination
        state["position"] = message["position"]
        return message

    def cross_portal(x, z, entering):
        deadline = time.monotonic() + 8
        while time.monotonic() < deadline:
            message = json.loads(ws.recv(timeout=8))
            assert message["type"] != "error", message
            if message["type"] == "travelled":
                assert message["place"] == "lourizan"
                state["position"] = message["position"]
                assert (state["position"][0] < -70) == entering
                return
            if message["type"] == "snapshot":
                state["position"] = message["position"]
                dx, dz = x - state["position"][0], z - state["position"][2]
                length = math.hypot(dx, dz)
                move([dx / max(length, .01), dz / max(length, .01)])
        raise AssertionError(("Portal did not commit", state["position"]))

    send(ws, "travel", destination="home")
    assert receive(ws, "travel_error")["error"] == "unknown_destination"
    send(ws, "travel", destination="scandale")
    assert receive(ws, "travel_error")["error"] == "exit_required"
    send(ws, "talk", speaker="../arbitrary")
    assert receive(ws, "talk_error")["error"] == "unknown_speaker"
    snapshot = receive(ws, "snapshot")
    assert set(snapshot["npcs"]) == {"LucasMaconheiro", "InesBotanica", "NarciVisitante", "Salon/BraisAnfitrion"}
    # A connected but frozen guide must not pass merely because it was spawned.
    first_guide = snapshot["npcs"]["LucasMaconheiro"]["position"]
    deadline = time.monotonic() + 6
    while time.monotonic() < deadline:
        guide = receive(ws, "snapshot")["npcs"]["LucasMaconheiro"]
        if guide["walking"] and math.dist(first_guide, guide["position"]) > .1:
            break
    else:
        raise AssertionError("Lucas Maconheiro patrol is frozen")
    for x, z in [
        (8.4, 15.6),
        (8.4, 10.8),
        (8.0, 9.0),
        (6.0, 9.0),
        (3.5, 9.0),
        (.5, 9.0),
        (-2.82, 4.56),
    ]:
        walk_to(x, z)
    cross_portal(-2.82, 4.56, True)
    walk_to(-88.3, 5.8)
    send(ws, "talk", speaker="Salon/BraisAnfitrion")
    assert receive(ws, "talked")["pages"]
    send(ws, "talk_end")
    walk_to(-90, 5.9)
    cross_portal(-90, 7.95, False)
    for x, z in [(3.5, 9.0), (6.0, 9.0), (8.0, 9.0), (8.0, -4.0), (6.0, -4.0)]:
        walk_to(x, z)
    walk_to(7.2, -4.8)
    travel("street")
    for x, z in [(4.2, -5), (4.1, -10), (3.5, -15), (2.5, -20), (2.5, -25), (2.5, -30)]:
        walk_to(x * 1.45, z * 1.45)
    travel("scandale")
    send(ws, "talk", speaker="Bartender")
    assert receive(ws, "talk_error")["error"] == "out_of_reach"
    walk_to(1, -.5)
    walk_to(.05, -.5)
    send(ws, "talk", speaker="Bartender")
    first_joke = receive(ws, "talked")["pages"]
    assert first_joke
    send(ws, "talk_end")
    send(ws, "talk", speaker="Bartender")
    assert receive(ws, "talked")["pages"] != first_joke
    send(ws, "talk_end")
    send(ws, "leave")
    receive(ws, "left")
    ws.close()
    ws, resumed, _ = join(stack, client, jar)
    assert resumed["id"] == character["id"] and resumed["appearance"] == character["appearance"]
    assert resumed["place"] == "scandale"
    assert all(abs(a-b) < .02 for a, b in zip(resumed["position"], state["position"]))
    state.update(sequence=0, position=resumed["position"])
    walk_to(1, -.5)
    walk_to(1, 3.5)
    walk_to(0, 4.6)
    travel("lourizan")
    print("PASS: server-validated exits, street/Scandale/Pazo travel, salon entry/return and Brais,")
    print("all NPC spawns,")
    print("Casa/forged destinations rejected, reachable non-repeating bartender dialogue,")
    print("and fresh-connection destination/position/identity/appearance resume.")
    return ws

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
        assert -25 <= restored["position"][0] <= 29.8 and restored["revision"] > 0
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
        post(fresh, fresh_jar, "/character/edit/", {"name": "Viajero Nuevo", "face": "freckles", "hair": "short",
             "skin_palette": "olive", "hair_palette": "ink", "upper_palette": "ochre", "lower_palette": "earth"})
        edited_ws, edited, _ = join(stack, fresh, fresh_jar)
        assert edited["id"] == final["id"] and edited["appearance"]["hair"] == "short"
        assert edited["name"] == "Viajero Nuevo"
        assert all(abs(a - b) < .01 for a, b in zip(edited["position"], final["position"]))
        edited_ws = exercise_world(stack, fresh, fresh_jar, edited_ws, edited)
        send(edited_ws, "leave")
        receive(edited_ws, "left")
        edited_ws.close()
        post(fresh, fresh_jar, "/logout/")
        returning, _ = login()
        assert b'value="Viajero Nuevo"' in returning.open(origin).read()
        print("PASS: first creation, fresh-browser resume, appearance, movement, save acknowledgement,")
        print("ticket replay, forged position, duplicate session fencing, authority restart, invalid command,")
        print("appearance/name editing, preserved position and return to personalization.")
finally:
    for process in reversed(processes):
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=10)
    admin.execute(sql.SQL("DROP DATABASE {} WITH (FORCE)").format(sql.Identifier(database)))
    admin.close()
