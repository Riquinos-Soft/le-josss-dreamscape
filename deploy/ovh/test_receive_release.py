import importlib.util
import io
from pathlib import Path
import tarfile
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('receiver', Path(__file__).with_name('receive-release.py'))
receiver = importlib.util.module_from_spec(spec)
spec.loader.exec_module(receiver)


def archive(extra=None):
    output = io.BytesIO()
    with tarfile.open(fileobj=output, mode='w:gz') as tar:
        for name, data in [('index.html', b'<html></html>'),
                           ('index.wasm', b'\0asmtest'), ('index.pck', b'pack')]:
            info = tarfile.TarInfo(name)
            info.size = len(data)
            tar.addfile(info, io.BytesIO(data))
        if extra:
            tar.addfile(extra, io.BytesIO(b'x' * extra.size))
    output.seek(0)
    return output


class ReleaseTests(unittest.TestCase):
    def test_valid_export(self):
        with tempfile.TemporaryDirectory() as work:
            receiver.extract(archive(), Path(work))
            self.assertEqual((Path(work) / 'index.pck').read_bytes(), b'pack')

    def test_rejects_unsafe_archives(self):
        for name, kind in [('../escape', tarfile.REGTYPE),
                           ('/tmp/escape', tarfile.REGTYPE),
                           ('link', tarfile.SYMTYPE), ('hardlink', tarfile.LNKTYPE),
                           ('index.html', tarfile.REGTYPE)]:
            with self.subTest(name=name), tempfile.TemporaryDirectory() as work:
                info = tarfile.TarInfo(name)
                info.type = kind
                info.linkname = '/etc/passwd'
                with self.assertRaises((ValueError, FileExistsError)):
                    receiver.extract(archive(info), Path(work))

    def test_failed_health_check_restores_previous(self):
        with tempfile.TemporaryDirectory() as work:
            root = Path(work)
            (root / 'current').symlink_to('releases/previous')
            release = root / 'releases/new'
            release.mkdir(parents=True)
            def fail(_):
                raise RuntimeError('unhealthy')
            with self.assertRaises(RuntimeError):
                receiver.activate(root, release, 'sha', fail)
            self.assertEqual((root / 'current').readlink(), Path('releases/previous'))

    def test_size_limit_preserves_target_boundary(self):
        original = receiver.MAX_BYTES
        try:
            receiver.MAX_BYTES = 1
            with tempfile.TemporaryDirectory() as work:
                with self.assertRaises(ValueError):
                    receiver.extract(archive(), Path(work))
        finally:
            receiver.MAX_BYTES = original

    def test_successful_activation(self):
        with tempfile.TemporaryDirectory() as work:
            root = Path(work)
            (root / 'current').symlink_to('releases/previous')
            release = root / 'releases/new'
            release.mkdir(parents=True)
            receiver.activate(root, release, 'sha', lambda sha: self.assertEqual(sha, 'sha'))
            self.assertEqual((root / 'current').readlink(), Path('releases/new'))


if __name__ == '__main__':
    unittest.main()
