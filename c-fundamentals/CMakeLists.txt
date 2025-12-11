cmake_minimum_required(VERSION 3.15)
project(c_fundamentals C)

# Requerir C99 y opciones de compilación similares a las del Makefile original
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
add_compile_options(-Wall -Wextra -Werror -pedantic -g)

# Buscar recursivamente todos los .c en src/
file(GLOB_RECURSE SRC_FILES CONFIGURE_DEPENDS ${CMAKE_SOURCE_DIR}/src/*.c)

# Para cada fuente, crear un ejecutable con nombre seguro basado en la ruta relativa
foreach(src IN LISTS SRC_FILES)
  file(RELATIVE_PATH rel ${CMAKE_SOURCE_DIR}/src ${src})
  # Reemplazar separadores por '_' y quitar la extensión
  string(REGEX REPLACE "[/\\\\]" "_" target_name ${rel})
  string(REGEX REPLACE "\\.c$" "" target_name ${target_name})
  # Reemplazar guiones por '_' para evitar posibles problemas en nombres de targets
  string(REGEX REPLACE "-" "_" target_name ${target_name})
  add_executable(${target_name} ${src})
  # Volcar binarios en el directorio bin/ del proyecto (no en build/)
  set_target_properties(${target_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
endforeach()

# Target de conveniencia para compilar todo rápidamente
add_custom_target(build_all DEPENDS ${PROJECT_NAME} ALL)
