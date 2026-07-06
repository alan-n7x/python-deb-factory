# hello-python-deb

A simple **Hello, World!** Python application packaged as a Debian package, ready for professional distribution via `pip`, `apt`, and GitHub Releases.

This repository serves as a **reusable template** for building professional Python applications that can be distributed as:

- `pip install hello-python-deb`
- `apt install hello-python-deb`
- GitHub Releases (standalone `.deb` and source tarball)

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
- [Development](#development)
  - [Running Tests](#running-tests)
  - [Code Quality](#code-quality)
  - [Building the Debian Package](#building-the-debian-package)
  - [Releasing](#releasing)
- [CI/CD](#ci-cd)
- [Packaging Details](#packaging-details)
  - [Python Packaging (PyPI)](#python-packaging-pypi)
  - [Debian Packaging (Deb/Ubuntu)](#debian-packaging-debubuntu)
  - [Launchpad PPA (Optional)](#launchpad-ppa-optional)
  - [GitHub Releases (Optional)](#github-releases-optional)
- [Versioning & Changelog](#versioning--changelog)
- [License](#license)

## Features

- ✅ Python 3.12+ compatible
- ✅ Modern packaging with `pyproject.toml` (setuptools)
- ✅ `src` layout for clean import structure
- ✅ Console script entry point (`hello-python-deb`)
- ✅ Comprehensive test suite with `pytest`
- ✅ Code quality with `ruff` (linting & formatting)
- ✅ Static type checking with `mypy`
- ✅ Pre‑commit hooks for consistent code quality
- ✅ GitHub Actions CI/CD for building, testing, and publishing
- ✅ Semantic versioning
- ✅ Automated changelog generation (via `towncrier` – optional)
- ✅ Debian packaging ready (`debian/` folder)
- ✅ Launchpad PPA publishing (optional)
- ✅ GitHub Releases publishing (optional)
- ✅ Template ready for daemons, CLI tools, libraries, or background services

## Project Structure

```
hello-python-deb/
├── src/
│   └── hello_python_deb/
│       ├── __init__.py
│       └── __main__.py          # Entry point: prints "Hello, World!"
├── tests/
│   └── test_basic.py
├── docs/
│   └── (documentation files)
├── scripts/
│   └── (helper scripts)
├── debian/
│   ├── control
│   ├── changelog
│   ├── compat
│   ├── rules
│   └── source/format
├── .github/
│   └── workflows/
│       └── ci.yml               # CI/CD pipeline
├── .pre-commit-config.yaml      # Pre‑commit hooks
├── pyproject.toml               # Project configuration
├── README.md
└── LICENSE
```

## Getting Started

### Prerequisites

- Python ≥ 3.12
- `pip` (latest)
- `git`
- For building Debian packages: `debhelper`, `devscripts`, `equivs`, `fakeroot`, `build-essential`
- (Optional) For publishing to Launchpad: `dput`, `gnupg`
- (Optional) For GitHub Releases: `gh` CLI (optional, actions handle it)

### Installation

#### From PyPI (via pip)

```bash
pip install hello-python-deb
```

#### From APT (after deploying to a Debian repository)

```bash
sudo apt update
sudo apt install hello-python-deb
```

#### From Source (development)

```bash
git clone https://github.com/alan-n7x/python-deb-factory.git
cd python-deb-factory
python -m pip install -e .
```

### Usage

After installation, run the command:

```bash
hello-python-deb
# Output: Hello, World!
```

You can also invoke via Python module:

```bash
python -m hello_python_deb
```

## Development

### Running Tests

```bash
pytest
```

### Code Quality

```bash
# Linting & auto‑fix
ruff check .
ruff check --fix .

# Type checking
mypy src
```

### Pre‑commit Hooks

Install the hooks once:

```bash
pre-commit install
```

They will run on every commit automatically.

### Building the Debian Package

Locally (for testing):

```bash
# Install build dependencies
sudo apt-get update
sudo apt-get install -y debhelper devscripts equivs fakeroot build-essential

# Build the source and binary packages
debuild -us -uc
# or, using dpkg-buildpackage
dpkg-buildpackage -us -uc
```

The resulting `.deb` file will be placed in the parent directory.

### Releasing

#### Versioning

We follow [Semantic Versioning](https://semver.org/). Update the version in `pyproject.toml` (and optionally in `debian/changelog`).

#### Changelog

We recommend using [towncrier](https://towncrier.readthedocs.io/) for automated changelog fragments.  
Create a `.townrak.toml` configuration and add change fragments under `changes/`.

#### Publishing to PyPI

```bash
# Build distribution
python -m build

# Upload to TestPyPI first (optional)
python -m twine upload --repository testpypi dist/*

# Upload to real PyPI
python -m twine upload dist/*
```

#### Publishing to Launchpad PPA (Optional)

1. Sign your GPG key and upload to Launchpad.
2. Build source package:
   ```bash
   debuild -S
   ```
3. Upload to your PPA:
   ```bash
   dput ppa:<lp-username>/<ppa-name> ../hello-python-deb_*.changes
   ```

#### Publishing to GitHub Releases (Optional)

The CI workflow (see below) can automatically create a GitHub Release and attach the built `.deb` and source tarball when a new tag is pushed.

## CI/CD

The repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that:

1. **Tests** the code on Ubuntu latest with Python 3.12.
2. **Lints** with `ruff` and checks types with `mypy`.
3. **Builds** the Python wheel and source distribution.
4. **Builds** the Debian package (`.deb`) using `dpkg-buildpackage`.
5. **(Optional)** Publishes to PyPI when a GitHub tag matching `v*` is pushed.
6. **(Optional)** Publishes to GitHub Releases (attaches `.deb` and tarball) on tags.
7. **(Optional)** Publishes to Launchpad PPA (requires configured secrets).

Secrets needed for optional pipelines:
- `PYPI_API_TOKEN` – PyPI API token
- `LAUNCHPAD_KEY` – GPG private key (ASCII-armored) for Launchpad
- `LAUNCHPAD_PASSPHRASE` – Passphrase for the GPG key
- `GH_TOKEN` – GitHub token with `repo` scope (automatically provided as `GITHUB_TOKEN`)

## Packaging Details

### Python Packaging (PyPI)

- Defined in `pyproject.toml` using [setuptools](https://setuptools.pypa.io/).
- The console script `hello-python-deb` points to `hello_python_deb.__main__:main`.
- Wheel and sdist are generated via `python -m build`.

### Debian Packaging (Deb/Ubuntu)

The `debian/` directory contains the minimal files needed to build a Debian package:

- `control` – Package metadata, dependencies, section, priority.
- `changelog` – Debian changelog (managed via `towncrier` or manual edits).
- `compat` – Debhelper compatibility level (currently `13`).
- `rules` – Simple Makefile using `dh` (debhelper) to build.
- `source/format` – Indicates source format `3.0 (quilt)`.

The resulting `.deb` installs the Python package into `/usr/lib/python3/dist-packages` and installs the `hello-python-deb` executable into `/usr/bin`.

### Launchpad PPA (Optional)

Launchpad builds the package from the uploaded source (`.changes`). Ensure you have a valid GPG‑signed upload.

### GitHub Releases (Optional)

The CI workflow uploads the generated `.deb` and source tarball (`hello-python-deb_<version>.tar.gz`) as assets to the release associated with a git tag.

## Versioning & Changelog

- **Version**: Specified in `pyproject.toml` (and mirrored in `debian/changelog`).
- **Changelog**: Keep a `changes/` directory with fragments named `<issue>.<type>.md` (e.g., `12.feature.md`, `13.bugfix.md`). Run `towncrier build --draft` to preview, `towncrier release --version 0.2.0` to apply.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Happy hacking! 🎉