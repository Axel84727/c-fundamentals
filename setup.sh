#!/bin/bash
# Setup script para c-fundamentals repo (actualizado para CMake)

set -euo pipefail

ROOT_DIR="$(pwd)"
CF_DIR="${ROOT_DIR}/c-fundamentals"

echo "🚀 Setting up c-fundamentals repository with CMake..."

# Crear estructura de directorios
mkdir -p "${CF_DIR}/src" "${CF_DIR}/tests" "${CF_DIR}/bin" "${CF_DIR}/docs" "${CF_DIR}/scripts"

# Crear subdirectorios por nivel si no existen
mkdir -p "${CF_DIR}/src/01-basics" "${CF_DIR}/src/02-loops" "${CF_DIR}/src/03-arrays" \
         "${CF_DIR}/src/04-strings" "${CF_DIR}/src/05-functions" "${CF_DIR}/src/06-pointers" "${CF_DIR}/src/07-structs"

# Copiar/crear CMakeLists.txt si no existe (si el usuario ya lo tiene, no sobrescribimos)
if [ ! -f "${CF_DIR}/CMakeLists.txt" ]; then
  cat > "${CF_DIR}/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.16)
project(c_fundamentals C)

# Opciones configurables
option(ENABLE_LTO "Enable link-time optimization (LTO)" ON)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type (Debug/Release)" FORCE)
endif()

# Estándar C
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Flags recomendados
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0 -DDEBUG -Wall -Wextra -pedantic")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -march=native -pipe -Wall -Wextra -pedantic")
if(ENABLE_LTO)
  string(APPEND CMAKE_C_FLAGS_RELEASE " -flto")
endif()

# Helper: normalizar nombres a un identificador seguro para targets
function(make_safe_name out input)
  string(TOLOWER "${input}" _tmp)
  # Reemplazar cualquier caracter no alfanumérico por '_'
  string(REGEX REPLACE "[^a-z0-9]+" "_" _tmp "${_tmp}")
  # Eliminar guiones bajos iniciales/finales
  string(REGEX REPLACE "^_+|_+$" "" _tmp "${_tmp}")
  set(${out} "${_tmp}" PARENT_SCOPE)
endfunction()

# Recolectar fuentes por sección (solo subdirectorios inmediatos de src/ y tests/)
set(PROJECT_ROOT ${CMAKE_SOURCE_DIR})
set(SRC_ROOT ${PROJECT_ROOT}/src)
set(TESTS_ROOT ${PROJECT_ROOT}/tests)

# Lista para targets por sección
set(ALL_SECTION_TARGETS "")
set(ALL_EXERCISE_TARGETS "")

# Función para procesar un directorio de sección dado (base puede ser src o tests)
function(process_section base_dir rel_dir)
  set(section_dir "${base_dir}/${rel_dir}")
  if(NOT IS_DIRECTORY ${section_dir})
    return()
  endif()

  # Obtener todos los .c en la sección
  file(GLOB SECTION_SOURCES CONFIGURE_DEPENDS "${section_dir}/*.c")
  if(SECTION_SOURCES)
    # Normalizar nombre de sección
    make_safe_name(section_safe "${rel_dir}")
    set(section_target_name "section_${section_safe}")
    set(section_bin_dir "${PROJECT_ROOT}/bin/${rel_dir}")

    set(section_exercise_targets "")
    foreach(src IN LISTS SECTION_SOURCES)
      # Nombre seguro del archivo (incluye sección para evitar colisiones)
      get_filename_component(src_basename ${src} NAME_WE)
      make_safe_name(src_safe "${src_basename}")
      make_safe_name(sec_safe_for_name "${rel_dir}")
      set(exercise_target "exercise_${sec_safe_for_name}_${src_safe}")

      add_executable(${exercise_target} "${src}")

      # Establecer directorio de salida por sección
      set_target_properties(${exercise_target} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_ROOT}/bin/${rel_dir}"
        RUNTIME_OUTPUT_DIRECTORY_DEBUG "${PROJECT_ROOT}/bin/${rel_dir}"
        RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PROJECT_ROOT}/bin/${rel_dir}"
      )

      list(APPEND section_exercise_targets ${exercise_target})
      list(APPEND ALL_EXERCISE_TARGETS ${exercise_target})
    endforeach()

    # Target de sección que depende de todos los ejecutables de la sección
    add_custom_target(${section_target_name} DEPENDS ${section_exercise_targets})
    list(APPEND ALL_SECTION_TARGETS ${section_target_name})
  endif()
endfunction()

# Procesar subdirectorios inmediatos dentro de src/
if(EXISTS ${SRC_ROOT})
  file(GLOB SRCDIRS RELATIVE ${SRC_ROOT} ${SRC_ROOT}/*)
  foreach(d IN LISTS SRCDIRS)
    if(IS_DIRECTORY ${SRC_ROOT}/${d})
      process_section(${SRC_ROOT} ${d})
    endif()
  endforeach()
endif()

# Procesar subdirectorios inmediatos dentro de tests/
if(EXISTS ${TESTS_ROOT})
  file(GLOB TESTDIRS RELATIVE ${TESTS_ROOT} ${TESTS_ROOT}/*)
  foreach(d IN LISTS TESTDIRS)
    if(IS_DIRECTORY ${TESTS_ROOT}/${d})
      process_section(${TESTS_ROOT} ${d})
    endif()
  endforeach()
  # También procesar archivos sueltos en tests/ (sin subdir)
  file(GLOB TEST_FILES CONFIGURE_DEPENDS "${TESTS_ROOT}/*.c")
  foreach(tf IN LISTS TEST_FILES)
    get_filename_component(tf_basename ${tf} NAME_WE)
    make_safe_name(tf_safe "${tf_basename}")
    set(ex_target "exercise_tests_${tf_safe}")
    add_executable(${ex_target} "${tf}")
    set_target_properties(${ex_target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_ROOT}/bin/tests")
    list(APPEND ALL_EXERCISE_TARGETS ${ex_target})
  endforeach()
endif()

# Target global que construye todas las secciones encontradas
if(ALL_SECTION_TARGETS)
  add_custom_target(all_exercises DEPENDS ${ALL_SECTION_TARGETS})
else()
  # Si no hay secciones, crear target que dependa de todos los ejercicios encontrados
  if(ALL_EXERCISE_TARGETS)
    add_custom_target(all_exercises DEPENDS ${ALL_EXERCISE_TARGETS})
  endif()
endif()

# Target para limpiar binarios (invoca script seguro)
add_custom_target(clean_bins
  COMMAND ${CMAKE_COMMAND} -E echo "Cleaning binaries in ${PROJECT_ROOT}/bin/..."
  COMMAND ${CMAKE_COMMAND} -E env bash "${PROJECT_ROOT}/scripts/clean_bins.sh"
  WORKING_DIRECTORY ${PROJECT_ROOT}
)

message(STATUS "Configured c-fundamentals: found ${ALL_EXERCISE_TARGETS} exercises and ${ALL_SECTION_TARGETS} section targets")

# Nota: cuando se añaden/ eliminan archivos .c puede ser necesario volver a ejecutar 'cmake -S . -B build' para actualizar la lista de targets.
EOF
else
  echo "CMakeLists.txt already exists in ${CF_DIR}, skipping overwrite"
fi

# Crear README.md si no existe (actualizaremos después si ya existe)
if [ ! -f "${CF_DIR}/README.md" ]; then
  cat > "${CF_DIR}/README.md" << 'EOF'
# C Fundamentals - Build & Usage

Este proyecto usa CMake para compilar ejercicios individuales o por secciones.

Quick start:

```bash
./setup.sh           # configura build/ y crea PROGRESS_TRACKER.md
./build.sh           # compila todos los ejercicios (equivalente a "all_exercises")
./build.sh src/01-basics           # compila la sección 01-basics
./build.sh src/01-basics/ex01.c   # compila ese archivo específico
cmake --build build --target clean_bins   # elimina binarios generados
```

Los binarios se colocan en `c-fundamentals/bin/<section>/` según la carpeta del archivo.

Para más detalles, edita o revisa este README.
EOF
else
  echo "README.md already exists in ${CF_DIR}, skipping overwrite"
fi

# Crear scripts/clean_bins.sh si no existe
if [ ! -f "${CF_DIR}/scripts/clean_bins.sh" ]; then
  cat > "${CF_DIR}/scripts/clean_bins.sh" << 'EOF'
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
# Encontrar y borrar archivos regulares con bit ejecutable
# -maxdepth 3 limita alcance por seguridad
find "${BIN_DIR}" -type f -perm /111 -print -delete || true

echo "Done."
EOF
  chmod +x "${CF_DIR}/scripts/clean_bins.sh"
else
  echo "scripts/clean_bins.sh already exists, skipping"
fi

# Crear build helper simple si no existe
if [ ! -f "${ROOT_DIR}/build.sh" ]; then
  cat > "${ROOT_DIR}/build.sh" << 'EOF'
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
  # If arg is a directory inside c-fundamentals/src or c-fundamentals/tests -> section
  if [ -d "${PROJECT_DIR}/${ARG}" ]; then
    # ARG puede ser como src/01-basics o 01-basics
    # Normalizar a la ruta relativa dentro de project
    REL=$(realpath --relative-to="${PROJECT_DIR}" "${PROJECT_DIR}/${ARG}" 2>/dev/null || echo "${ARG}")
    # Reemplazar '/' por '_' y limpiar caracteres no alfanuméricos para mapear al target
    SAFE=$(echo "${REL}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')
    TARGET="section_${SAFE}"
  elif [ -f "${PROJECT_DIR}/${ARG}" ]; then
    # Archivo específico
    BASENAME=$(basename "${ARG}" .c)
    DIRNAME=$(dirname "${ARG}")
    RELDIR=$(realpath --relative-to="${PROJECT_DIR}" "${PROJECT_DIR}/${DIRNAME}" 2>/dev/null || echo "${DIRNAME}")
    SAFE_DIR=$(echo "${RELDIR}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')
    SAFE_FILE=$(echo "${BASENAME}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')
    TARGET="exercise_${SAFE_DIR}_${SAFE_FILE}"
  else
    # Fallback: intentar mapear input como sección nombre solo
    SAFE=$(echo "${ARG}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')
    TARGET="section_${SAFE}"
  fi
fi

echo "Building target: ${TARGET}"
cmake --build "${BUILD_DIR}" --target "${TARGET}" -- -j${NUM_CORES}
EOF
  chmod +x "${ROOT_DIR}/build.sh"
else
  echo "build.sh already exists, skipping"
fi

# Crear PROGRESS_TRACKER.md en la raíz del proyecto (no sobrescribir si existe)
if [ ! -f "${CF_DIR}/PROGRESS_TRACKER.md" ]; then
  cat > "${CF_DIR}/PROGRESS_TRACKER.md" << 'EOF'
# PROGRESS_TRACKER / ANOTACIONES

Usa este archivo para llevar un registro ligero de tu progreso.

Formato sugerido:

| Fecha | Sección | Ejercicio | Estado | Notas |
|-------|---------|-----------|--------|-------|
| 2025-12-11 | 01-basics | ex01 | hecho | Implementado "Hello World" |

Puedes mantener notas por sección en `docs/PROGRESS.md` si necesitas más detalle.
EOF
else
  echo "PROGRESS_TRACKER.md already exists, skipping"
fi

# Mensaje final
cat << EOF

✅ Setup complete!

Siguientes pasos rápidos:
  1) ./build.sh            # compila todo
  2) ./build.sh src/01-basics         # compila sección
  3) ./build.sh src/01-basics/ex01.c # compila archivo específico
  4) cmake --build build --target clean_bins  # limpia binarios

Los binarios se colocan en: c-fundamentals/bin/<section>/*. Ejecutables tienen permisos de ejecución.

Si añades o eliminas archivos .c, vuelve a ejecutar: cmake -S c-fundamentals -B build

EOF

