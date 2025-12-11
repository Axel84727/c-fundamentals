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
    # Asegurar directorio (no se crea en configure, sino en build mediante custom command si se desea)

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
