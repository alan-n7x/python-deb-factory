#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

NEW_VERSION="$1"

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must follow semantic versioning (e.g., 1.0.0)"
    exit 1
fi

echo "==> Validating environment..."
if ! command -v towncrier &> /dev/null; then
    echo "Error: towncrier not found. Install with: pip install towncrier"
    exit 1
fi

if ! command -v twine &> /dev/null; then
    echo "Error: twine not found. Install with: pip install twine"
    exit 1
fi

echo "==> Running tests..."
./scripts/test.sh

echo "==> Bumping version to $NEW_VERSION..."
sed -i "s/^version = .*/version = \"$NEW_VERSION\"/" pyproject.toml
sed -i "s/^Version: .*/Version: $NEW_VERSION/" debian/changelog

echo "==> Generating changelog..."
towncrier build --yes --version "$NEW_VERSION"

echo "==> Building Python packages..."
python -m build

echo "==> Building Debian package..."
dpkg-buildpackage -us -uc -b

echo "==> Running twine check..."
twine check dist/*

echo "==> Release $NEW_VERSION completed successfully!"
echo ""
echo "Artifacts:"
echo "  - dist/hello_python_deb-$NEW_VERSION-py3-none-any.whl"
echo "  - dist/hello-python-deb-$NEW_VERSION.tar.gz"
echo "  - ../hello-python-deb_${NEW_VERSION}_all.deb"
echo ""
echo "Next steps:"
echo "  1. Review the changes"
echo "  2. Commit: git add -A && git commit -m \"Release v$NEW_VERSION\""
echo "  3. Tag: git tag v$NEW_VERSION"
echo "  4. Push: git push origin main --tags"
