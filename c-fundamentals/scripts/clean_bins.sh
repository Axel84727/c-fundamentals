#!/usr/bin/env bash
# Eliminación segura de ficheros ejecutables dentro de bin/
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="${ROOT}/bin"

if [ ! -d "${BIN_DIR}" ]; then
  echo "No bin/ directory found, nothing to clean."
  exit 0
fi

echo "Cleaning executable files in ${BIN_DIR}..."
# Portable: iterar ficheros y borrar solo los ejecutables
find "${BIN_DIR}" -type f -print0 | while IFS= read -r -d '' file; do
  if [ -x "${file}" ]; then
    echo "Deleting: ${file}"
    rm -f "${file}"
  fi
done

echo "Done."
