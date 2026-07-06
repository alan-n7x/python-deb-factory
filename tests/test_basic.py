import subprocess
import sys
from pathlib import Path

import pytest


@pytest.fixture
def project_root() -> Path:
    """Return the project root directory."""
    return Path(__file__).parent.parent


class TestHelloWorld:
    """Tests for the Hello World application."""

    def test_hello_world_output(self) -> None:
        """Test that the application outputs Hello, World!."""
        result = subprocess.run(
            [sys.executable, "-m", "hello_python_deb"],
            capture_output=True,
            text=True,
            check=True,
        )
        assert result.stdout.strip() == "Hello, World!"
        assert result.stderr == ""

    def test_hello_world_exit_code(self) -> None:
        """Test that the application exits with code 0."""
        result = subprocess.run(
            [sys.executable, "-m", "hello_python_deb"],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0

    def test_import_module(self) -> None:
        """Test that the module can be imported."""
        import hello_python_deb
        assert hello_python_deb is not None

    def test_main_function_exists(self) -> None:
        """Test that the main function is callable."""
        from hello_python_deb.__main__ import main
        assert callable(main)


class TestProjectStructure:
    """Tests for the project structure."""

    def test_src_layout_exists(self, project_root: Path) -> None:
        """Test that src layout is properly configured."""
        assert (project_root / "src").is_dir()
        assert (project_root / "src" / "hello_python_deb").is_dir()

    def test_pyproject_toml_exists(self, project_root: Path) -> None:
        """Test that pyproject.toml exists."""
        assert (project_root / "pyproject.toml").is_file()

    def test_debian_directory_exists(self, project_root: Path) -> None:
        """Test that debian directory exists."""
        assert (project_root / "debian").is_dir()
        assert (project_root / "debian" / "control").is_file()
        assert (project_root / "debian" / "rules").is_file()

    def test_tests_directory_exists(self, project_root: Path) -> None:
        """Test that tests directory exists."""
        assert (project_root / "tests").is_dir()

    def test_scripts_directory_exists(self, project_root: Path) -> None:
        """Test that scripts directory exists."""
        assert (project_root / "scripts").is_dir()


class TestPyprojectToml:
    """Tests for pyproject.toml configuration."""

    def test_pyproject_has_metadata(self, project_root: Path) -> None:
        """Test that pyproject.toml has required metadata."""
        content = (project_root / "pyproject.toml").read_text()
        assert "name = " in content
        assert "version = " in content
        assert "requires-python" in content

    def test_pyproject_has_scripts(self, project_root: Path) -> None:
        """Test that pyproject.toml has console scripts."""
        content = (project_root / "pyproject.toml").read_text()
        assert "hello-python-deb" in content

    def test_pyproject_has_dev_dependencies(self, project_root: Path) -> None:
        """Test that pyproject.toml has dev dependencies."""
        content = (project_root / "pyproject.toml").read_text()
        assert "pytest" in content
        assert "ruff" in content
        assert "mypy" in content
