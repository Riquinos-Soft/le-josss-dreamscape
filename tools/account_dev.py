"""Run the isolated account slice locally; all generated credentials stay in build/."""
import json
import os
from pathlib import Path
import secrets
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
STATE = ROOT / "build/account-dev.json"
if not STATE.exists():
    STATE.parent.mkdir(exist_ok=True)
    descriptor = os.open(STATE, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(descriptor, "w") as stream:
        json.dump({key: secrets.token_urlsafe(40) for key in ["DJANGO_SECRET_KEY", "PGPASSWORD", "AUTHORITY_SECRET"]}, stream)
env = {**os.environ, **json.loads(STATE.read_text()), "DREAMSCAPE_DEV": "1", "PGDATABASE": "dreamscape_accounts_dev",
       "PGUSER": "dreamscape_dev", "PGHOST": "127.0.0.1", "PGPORT": "55432", "REGISTRATION_ENABLED": "0"}


def supervise(command):
    """Restart the local authority after a lost lease, including Mac sleep/wake."""
    child = None
    stopping = False

    def stop(signum, frame):
        nonlocal stopping
        stopping = True
        if child is not None and child.poll() is None:
            child.terminate()

    for event in (signal.SIGINT, signal.SIGTERM):
        signal.signal(event, stop)
    while not stopping:
        child = subprocess.Popen(command, env=env, cwd=ROOT)
        result = child.wait()
        if stopping or result == 0:
            return result
        print(f"Local authority exited ({result}); restarting in 2 seconds", flush=True)
        time.sleep(2)
    return 0


command = sys.argv[1:]
if command and command[0] == "authority":
    if len(command) > 2:
        raise SystemExit("Usage: account_dev.py authority [godot]")
    godot = command[1] if len(command) == 2 else "godot"
    raise SystemExit(supervise([godot, "--headless", "--path", str(ROOT / "game"),
                                "res://v2/network/authority.tscn"]))
if command == ["database"]:
    env["POSTGRES_PASSWORD"] = env["PGPASSWORD"]
    command = ["docker", "run", "--name", "dreamscape-accounts-dev", "-d", "--restart", "unless-stopped",
               "-p", "127.0.0.1:55432:5432", "-e", "POSTGRES_PASSWORD", "-e", "POSTGRES_USER=dreamscape_dev",
               "-e", "POSTGRES_DB=dreamscape_accounts_dev", "-v", "dreamscape_accounts_dev:/var/lib/postgresql",
               "postgres:18.4-alpine"]
elif command and command[0] == "manage":
    command = [str(ROOT / "build/account-venv/bin/python"), str(ROOT / "backend/manage.py"), *command[1:]]
elif not command:
    raise SystemExit("Usage: account_dev.py database | manage <args> | authority [godot] | <command> [args]")
raise SystemExit(subprocess.call(command, env=env, cwd=ROOT))
