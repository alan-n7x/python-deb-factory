# Contributing

Thank you for considering contributing to Python Deb Factory!

## Development Setup

### Prerequisites

- Python 3.12+
- pip
- git
- debhelper (for Debian packaging)

### Setup

```bash
# Clone the repository
git clone https://github.com/alan-n7x/python-deb-factory.git
cd python-deb-factory

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install development dependencies
pip install -e ".[dev]"

# Install pre-commit hooks
pre-commit install
```

## Development Workflow

### Running Tests

```bash
# Run all tests and checks
./scripts/test.sh

# Run only tests
pytest tests/ -v

# Run only linter
ruff check .

# Run only type checker
mypy src/
```

### Building

```bash
# Build Python packages
python -m build

# Build Debian package
./scripts/build-deb.sh
```

### Creating a Release

```bash
./scripts/release.sh <version>
# Example: ./scripts/release.sh 1.0.0
```

## Code Style

- Follow PEP 8
- Use type hints
- Keep functions focused and small
- Write docstrings for public functions
- Run `ruff check .` before committing

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation changes
- `style:` formatting changes
- `refactor:` code refactoring
- `test:` adding tests
- `chore:` maintenance tasks

## Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Run tests (`./scripts/test.sh`)
5. Commit your changes
6. Push to your fork
7. Open a Pull Request

## Reporting Issues

Use the [GitHub Issues](https://github.com/alan-n7x/python-deb-factory/issues) page.

## License

By contributing, you agree that your contributions will be licensed under GPLv3.
