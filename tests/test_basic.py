import subprocess
import sys


def test_hello_world():
    result = subprocess.run(
        [sys.executable, "-m", "hello_python_deb"],
        capture_output=True,
        text=True,
        check=True,
    )
    assert result.stdout.strip() == "Hello, World!"
    assert result.stderr == ""


def test_import():
    import hello_python_deb
    assert hello_python_deb is not None