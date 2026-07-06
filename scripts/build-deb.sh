#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "==> Cleaning previous builds..."
rm -rf build/ dist/ *.deb *.changes *.buildinfo *.dsc *.tar.gz

echo "==> Building Python packages..."
python -m build

echo "==> Building Debian package..."
dpkg-buildpackage -us -uc -b

echo "==> Build completed successfully!"
echo ""
echo "Artifacts:"
ls -la dist/
ls -la ../*.deb 2>/dev/null || true
