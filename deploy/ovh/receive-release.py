#!/usr/bin/python3
"""Forced SSH command: accept a Web export, verify it, then switch current."""

import fcntl
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import sys
import tarfile
import tempfile
import urllib.request

ROOT = Path('/opt/dreamscape/www')
MAX_BYTES = 256 * 1024 * 1024


def extract(stream, target):
    total = 0
    count = 0
    with tarfile.open(fileobj=stream, mode='r|gz') as archive:
        for member in archive:
            count += 1
            path = PurePosixPath(member.name)
            if path.is_absolute() or '..' in path.parts or count > 2048:
                raise ValueError('Invalid archive path or too many entries')
            destination = target.joinpath(*path.parts)
            if member.isdir():
                destination.mkdir(parents=True, exist_ok=True, mode=0o755)
                continue
            if not member.isfile() or member.size < 0:
                raise ValueError('Only regular files and directories are allowed')
            total += member.size
            if total > MAX_BYTES:
                raise ValueError('Export exceeds 256 MiB')
            destination.parent.mkdir(parents=True, exist_ok=True, mode=0o755)
            with archive.extractfile(member) as source, destination.open('xb') as out:
                shutil.copyfileobj(source, out)
            destination.chmod(0o644)
    for name in ('index.html', 'index.wasm', 'index.pck'):
        if not (target / name).is_file() or (target / name).stat().st_size == 0:
            raise ValueError(f'Missing or empty {name}')
    with (target / 'index.wasm').open('rb') as wasm:
        if wasm.read(4) != b'\0asm':
            raise ValueError('Invalid WebAssembly header')


def activate(root, release, sha, check):
    current = root / 'current'
    previous = os.readlink(current)
    pending = root / '.current-next'
    pending.unlink(missing_ok=True)
    pending.symlink_to(release.relative_to(root))
    os.replace(pending, current)
    try:
        check(sha)
    except BaseException:
        pending.symlink_to(previous)
        os.replace(pending, current)
        raise


def check_http(sha):
    with urllib.request.urlopen('http://127.0.0.1:8083/release.txt', timeout=15) as response:
        if response.read().decode().strip() != sha:
            raise RuntimeError('Release verification failed')
    for name in ('index.html', 'index.wasm', 'index.pck'):
        request = urllib.request.Request('http://127.0.0.1:8083/' + name, method='HEAD')
        with urllib.request.urlopen(request, timeout=15) as response:
            if response.status != 200:
                raise RuntimeError('Export is not available')


def main():
    match = re.fullmatch(r'deploy ([0-9a-f]{40}) ([0-9]+-[0-9]+)',
                         os.environ.get('SSH_ORIGINAL_COMMAND', ''))
    if not match:
        raise ValueError('Only deploy SHA RUN-ATTEMPT is permitted')
    sha, run = match.groups()
    os.umask(0o022)
    with (ROOT / '.deploy.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        releases = ROOT / 'releases'
        release = releases / f'{sha}-{run}'
        if release.exists():
            raise ValueError('Release already exists; rerun with a new attempt')
        with tempfile.TemporaryDirectory(prefix='.upload-', dir=releases) as work:
            staging = Path(work) / 'web'
            staging.mkdir(mode=0o755)
            extract(sys.stdin.buffer, staging)
            (staging / 'release.txt').write_text(sha + '\n')
            staging.rename(release)
        try:
            activate(ROOT, release, sha, check_http)
        except BaseException:
            shutil.rmtree(release)
            raise
        print(f'Deployed {sha} ({run})')


if __name__ == '__main__':
    main()
