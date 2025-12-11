#!/usr/bin/env bash
# Simple build helper: usage ./build.sh [path|section|file]
set -euo pipefail

ROOT_DIR="$(pwd)"
PROJECT_DIR="${ROOT_DIR}/c-fundamentals"
BUILD_DIR="${ROOT_DIR}/build"

# Detect number of cores on macOS
NUM_CORES=1
if command -v sysctl >/dev/null 2>&1; then
  NUM_CORES=$(sysctl -n hw.ncpu || echo 1)
fi

# Ensure build directory is configured
function configure_cmake() {
  mkdir -p "${BUILD_DIR}"
  # Prefer Ninja if available
  if command -v ninja >/dev/null 2>&1; then
    cmake -S "${PROJECT_DIR}" -B "${BUILD_DIR}" -G Ninja -DCMAKE_BUILD_TYPE=Release
  else
    cmake -S "${PROJECT_DIR}" -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE=Release
  fi
}

if [ ! -d "${BUILD_DIR}" ] || [ ! -f "${BUILD_DIR}/CMakeCache.txt" ]; then
  echo "Configuring CMake..."
  configure_cmake
fi

ARG="${1:-all}"
if [ "${ARG}" = "all" ] || [ -z "${ARG}" ]; then
  TARGET="all_exercises"
else
  # Normalize slashes if user passed something like c-fundamentals/src/01-basics
  CLEAN_ARG="${ARG#c-fundamentals/}"
  # If arg is an existing directory inside project -> section
  if [ -d "${PROJECT_DIR}/${CLEAN_ARG}" ]; then
    REL=$(realpath --relative-to="${PROJECT_DIR}" "${PROJECT_DIR}/${CLEAN_ARG}" 2>/dev/null || echo "${CLEAN_ARG}")
    SAFE=$(echo "${REL}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')
    TARGET="section_${SAFE}"
  else
    # Try to resolve as a file. Accept variants: ex1, ex1.c, ex01.c, path/to/ex1.c
    FILEPATH=""
    # If the user passed a path that exists (absolute or relative), use it
    if [ -f "${ARG}" ]; then
      FILEPATH="${ARG}"
    elif [ -f "${PROJECT_DIR}/${ARG}" ]; then
      FILEPATH="${PROJECT_DIR}/${ARG}"
    else
      # Try adding .c
      if [ -f "${ARG}.c" ]; then
        FILEPATH="${ARG}.c"
      elif [ -f "${PROJECT_DIR}/${ARG}.c" ]; then
        FILEPATH="${PROJECT_DIR}/${ARG}.c"
      else
        # Search in src/ and tests/ for matching basename patterns
        BASENAME="${ARG}"
        BASENAME_NOEXT="${ARG%.*}"
        # Search exact basename match first
        MAP_RESULT=$(find "${PROJECT_DIR}/src" "${PROJECT_DIR}/tests" -type f -name "${BASENAME}" -o -name "${BASENAME}.c" -o -name "${BASENAME_NOEXT}.c" 2>/dev/null | sed -n '1,100p') || true
        if [ -z "${MAP_RESULT}" ]; then
          # Try broader match (any file that contains the arg)
          MAP_RESULT=$(find "${PROJECT_DIR}/src" "${PROJECT_DIR}/tests" -type f -iname "*${BASENAME}*.c" 2>/dev/null | sed -n '1,100p') || true
        fi
        if [ -n "${MAP_RESULT}" ]; then
          MATCHES=($MAP_RESULT)
          if [ ${#MATCHES[@]} -gt 1 ]; then
            echo "Multiple files matched '${ARG}':"
            for m in "${MATCHES[@]}"; do
              echo "  $m"
            done
            echo "Using first match: ${MATCHES[0]}"
          fi
          FILEPATH="${MATCHES[0]}"
        fi
      fi
    fi

    if [ -n "${FILEPATH}" ]; then
      # Compute safe names for target
      BASENAME_ONLY=$(basename "${FILEPATH}" .c)
      DIRNAME_ONLY=$(dirname "${FILEPATH}")
      # Try to compute path relative to project
      RELDIR=$(realpath --relative-to="${PROJECT_DIR}" "${DIRNAME_ONLY}" 2>/dev/null || true)
      if [ -z "${RELDIR}" ]; then
        # If realpath failed, strip project prefix if present
        if [[ "${DIRNAME_ONLY}" == "${PROJECT_DIR}"* ]]; then
          RELDIR="${DIRNAME_ONLY/#${PROJECT_DIR}\/}"
        else
          RELDIR="${DIRNAME_ONLY}"
        fi
      fi
      # Extract section name: if RELDIR contains src/<section>, take <section>
      if [[ "${RELDIR}" =~ ^src/([^/]+) ]]; then
        SECTION_NAME="${BASH_REMATCH[1]}"
      elif [[ "${RELDIR}" =~ ^tests/([^/]+) ]]; then
        SECTION_NAME="${BASH_REMATCH[1]}"
      else
        SECTION_NAME=$(basename "${RELDIR}")
      fi
      SAFE_DIR=$(echo "${SECTION_NAME}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')
      SAFE_FILE=$(echo "${BASENAME_ONLY}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')
      TARGET="exercise_${SAFE_DIR}_${SAFE_FILE}"
    else
      # Fallback: interpret argument as section name
      SAFE=$(echo "${ARG}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')
      TARGET="section_${SAFE}"
    fi
  fi
fi

echo "Building target: ${TARGET}"
cmake --build "${BUILD_DIR}" --target "${TARGET}" -- -j${NUM_CORES}
