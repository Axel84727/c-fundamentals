#!/bin/bash
# Setup script para c-fundamentals repo
# Crea estructura completa de directorios y archivos

set -e

echo "🚀 Setting up c-fundamentals repository..."

# Crear estructura de directorios
mkdir -p c-fundamentals/{src,tests,bin,docs}

# Crear subdirectorios por nivel
mkdir -p c-fundamentals/src/{01-basics,02-loops,03-arrays,04-strings,05-functions,06-pointers,07-structs}

# Crear Makefile
cat > c-fundamentals/Makefile << 'EOF'
CC = gcc
CFLAGS = -Wall -Wextra -Werror -std=c99 -pedantic -g
SRC_DIR = src
BIN_DIR = bin
TEST_DIR = tests

# Find all .c files
SRCS = $(shell find $(SRC_DIR) -name '*.c')
BINS = $(patsubst $(SRC_DIR)/%.c,$(BIN_DIR)/%,$(SRCS))

.PHONY: all clean test help

all: $(BIN_DIR) $(BINS)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Compile each .c file to its own binary
$(BIN_DIR)/%: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@ -lm
	@echo "✓ Compiled: $@"

# Run specific exercise
run-%: $(BIN_DIR)/%
	@echo "Running $*..."
	@$(BIN_DIR)/$*

# Run all exercises in a level
run-level-%:
	@echo "Running all exercises in level $*..."
	@for exe in $(BIN_DIR)/$*-*/*; do \
		if [ -x "$$exe" ]; then \
			echo "=== Running $$exe ==="; \
			$$exe; \
			echo ""; \
		fi \
	done

# Clean build artifacts
clean:
	rm -rf $(BIN_DIR)
	@echo "✓ Cleaned build directory"

# Run tests (if you write them)
test:
	@if [ -d "$(TEST_DIR)" ]; then \
		$(MAKE) -C $(TEST_DIR); \
	else \
		echo "No tests directory found"; \
	fi

# Show help
help:
	@echo "c-fundamentals Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all              - Compile all exercises"
	@echo "  run-<name>       - Run specific exercise"
	@echo "  run-level-<num>  - Run all exercises in a level"
	@echo "  clean            - Remove compiled binaries"
	@echo "  test             - Run tests"
	@echo "  help             - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make                              # Compile everything"
	@echo "  make run-01-basics/ex01_hello     # Run exercise 1"
	@echo "  make run-level-01-basics          # Run all basic exercises"
	@echo "  make clean                        # Clean build"

# Compile with optimizations
release: CFLAGS = -Wall -Wextra -std=c99 -O3 -DNDEBUG
release: all

# Count lines of code
loc:
	@echo "Lines of code:"
	@find $(SRC_DIR) -name '*.c' | xargs wc -l | tail -1
EOF

# Crear README.md
cat > c-fundamentals/README.md << 'EOF'
# C Fundamentals - 108 Exercises

Complete collection of C programming exercises from basics to intermediate level.

## Structure

```
c-fundamentals/
├── src/
│   ├── 01-basics/      # Exercises 1-18
│   ├── 02-loops/       # Exercises 19-36
│   ├── 03-arrays/      # Exercises 37-56
│   ├── 04-strings/     # Exercises 57-72
│   ├── 05-functions/   # Exercises 73-86
│   ├── 06-pointers/    # Exercises 87-97
│   └── 07-structs/     # Exercises 98-108
├── bin/                # Compiled binaries
├── tests/              # Test files (optional)
└── docs/               # Notes and documentation
```

## Building

```bash
# Compile all exercises
make

# Compile specific level
make run-level-01-basics

# Run specific exercise
make run-01-basics/ex01_hello

# Clean
make clean
```

## Progress Tracking

- [x] Level 1: Basics (1-18)
- [ ] Level 2: Loops (19-36)
- [ ] Level 3: Arrays (37-56)
- [ ] Level 4: Strings (57-72)
- [ ] Level 5: Functions (73-86)
- [ ] Level 6: Pointers (87-97)
- [ ] Level 7: Structs (98-108)

## Exercises Completed: 0/108

### Level 1: Basics (0/18)
- [ ] 01. Hello World
- [ ] 02. Variables básicas
- [ ] 03. Suma de dos números
...

## Guidelines

1. **No copy-paste** - Write everything from scratch
2. **Compile with warnings** - Use `-Wall -Wextra -Werror`
3. **Test your code** - At least 3 test cases per exercise
4. **Comment your code** - Explain the logic
5. **Use valgrind** - For pointer/malloc exercises

## Resources

- `man` pages in terminal
- [cppreference.com](https://en.cppreference.com/w/c)
- Compiler warnings (`-Wall -Wextra`)
- `gdb` for debugging
- `valgrind` for memory leaks

---

**Time estimate:**
- Speed-run: 8 days (3-4 hours/day)
- Normal pace: 36 days (3 exercises/day)
EOF

# Crear .gitignore
cat > c-fundamentals/.gitignore << 'EOF'
# Compiled binaries
bin/
*.o
*.out
*.exe

# Debug files
*.dSYM/
*.gch
*.pch

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Test outputs
*.log
core
vgcore.*
EOF

# Crear template para ejercicios
cat > c-fundamentals/docs/TEMPLATE.c << 'EOF'
/**
 * Exercise XX: [Title]
 * 
 * Description:
 *   [What this exercise does]
 *
 * Input:
 *   [Expected input]
 *
 * Output:
 *   [Expected output]
 *
 * Example:
 *   Input:  [example input]
 *   Output: [example output]
 *
 * Difficulty: [Easy/Medium/Hard]
 * Time: [Estimated time to complete]
 */

#include <stdio.h>
#include <stdlib.h>

int main(void) {
    // Your code here
    
    return 0;
}
EOF

# Generate ALL 108 exercise templates with correct titles
echo "Generating 108 exercise templates..."

# Define all exercise titles
declare -a exercises=(
    # Level 1: Basics (1-18)
    "Hello World"
    "Variables básicas"
    "Suma de dos números"
    "Calculadora básica"
    "Celsius a Fahrenheit"
    "Área de círculo"
    "Intercambiar variables"
    "Mayor de 3"
    "Par o impar"
    "Año bisiesto"
    "Calificación con letras"
    "Calculadora con switch"
    "Días del mes"
    "Calculadora de IMC"
    "Descuento en tienda"
    "Suma de 1 a N"
    "Tabla de multiplicar"
    "Factorial"
    # Level 2: Loops (19-36)
    "Número primo"
    "Fibonacci hasta N"
    "Invertir número"
    "Palíndromo numérico"
    "Suma de dígitos"
    "Número Armstrong"
    "MCD (Máximo Común Divisor)"
    "MCM (Mínimo Común Múltiplo)"
    "Potencia"
    "Patrón de asteriscos"
    "Patrón numérico"
    "Números perfectos"
    "Adivina el número"
    "Tabla ASCII"
    "Binario a decimal"
    "Decimal a binario"
    "Serie matemática"
    "Contar vocales y consonantes"
    # Level 3: Arrays (37-56)
    "Suma de elementos"
    "Máximo y mínimo"
    "Promedio"
    "Invertir array"
    "Búsqueda lineal"
    "Búsqueda binaria"
    "Ordenamiento burbuja"
    "Ordenamiento por selección"
    "Ordenamiento por inserción"
    "Eliminar duplicados"
    "Rotación de array"
    "Fusionar arrays ordenados"
    "Segundo elemento más grande"
    "Frecuencia de elementos"
    "Separar pares e impares"
    "Transponer matriz"
    "Suma de matrices"
    "Multiplicación de matrices"
    "Matriz identidad"
    "Determinante 2x2"
    # Level 4: Strings (57-72)
    "Longitud de string (sin strlen)"
    "Copiar string (sin strcpy)"
    "Concatenar strings (sin strcat)"
    "Comparar strings (sin strcmp)"
    "Invertir string"
    "Palíndromo de string"
    "Contar palabras"
    "Mayúsculas/minúsculas"
    "Eliminar espacios"
    "Anagrama"
    "Primer carácter no repetido"
    "Comprimir string"
    "Validar email"
    "Cifrado César"
    "Subcadena sin repetir"
    "Tokenizar string"
    # Level 5: Functions (73-86)
    "Factorial recursivo"
    "Fibonacci recursivo"
    "Suma de dígitos recursivo"
    "Torre de Hanoi"
    "Potencia recursiva"
    "MCD recursivo"
    "Búsqueda binaria recursiva"
    "Invertir string recursivo"
    "Binario recursivo"
    "Suma de array recursivo"
    "Palíndromo recursivo"
    "Caminos en cuadrícula"
    "Permutaciones"
    "Subsecuencia creciente"
    # Level 6: Pointers (87-97)
    "Swap con punteros"
    "Suma con punteros"
    "Invertir con punteros"
    "String length con punteros"
    "Copiar string con punteros"
    "Array dinámico"
    "Redimensionar array"
    "Calculadora con callbacks"
    "Array de strings"
    "Matriz dinámica 2D"
    "Punteros a estructuras"
    # Level 7: Structs (98-108)
    "Estructura Punto"
    "Estructura Fecha"
    "Estructura Estudiante"
    "Lista de contactos"
    "Sistema de inventario"
    "Escribir/leer archivo texto"
    "Contar líneas/palabras"
    "Copiar archivo"
    "Agenda con archivo"
    "Sistema de estudiantes con archivo"
    "Estadísticas de archivo"
)

# Function to create exercise file
create_exercise() {
    local num=$1
    local title=$2
    local dir=$3
    local filename=$4
    
    cat > "$filename" << EOF
/**
 * Exercise ${num}: ${title}
 * 
 * Description:
 *   See EXERCISES.md for detailed description
 *
 * TODO: Implement this exercise
 */

#include <stdio.h>
#include <stdlib.h>

int main(void) {
    // Your code here
    
    return 0;
}
EOF
}

# Generate exercises for each level
idx=0

# Level 1: Basics (1-18)
for i in {01..18}; do
    num=$((10#$i))  # Remove leading zero for array index
    create_exercise "$i" "${exercises[$idx]}" "c-fundamentals/src/01-basics" "c-fundamentals/src/01-basics/ex${i}.c"
    ((idx++))
done

# Level 2: Loops (19-36)
for i in {19..36}; do
    create_exercise "$i" "${exercises[$idx]}" "c-fundamentals/src/02-loops" "c-fundamentals/src/02-loops/ex${i}.c"
    ((idx++))
done

# Level 3: Arrays (37-56)
for i in {37..56}; do
    create_exercise "$i" "${exercises[$idx]}" "c-fundamentals/src/03-arrays" "c-fundamentals/src/03-arrays/ex${i}.c"
    ((idx++))
done

# Level 4: Strings (57-72)
for i in {57..72}; do
    cat > "c-fundamentals/src/04-strings/ex${i}.c" << EOF
/**
 * Exercise ${i}: ${exercises[$idx]}
 * 
 * Description:
 *   See EXERCISES.md for detailed description
 *
 * TODO: Implement this exercise
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    // Your code here
    
    return 0;
}
EOF
    ((idx++))
done

# Level 5: Functions (73-86)
for i in {73..86}; do
    create_exercise "$i" "${exercises[$idx]}" "c-fundamentals/src/05-functions" "c-fundamentals/src/05-functions/ex${i}.c"
    ((idx++))
done

# Level 6: Pointers (87-97)
for i in {87..97}; do
    create_exercise "$i" "${exercises[$idx]}" "c-fundamentals/src/06-pointers" "c-fundamentals/src/06-pointers/ex${i}.c"
    ((idx++))
done

# Level 7: Structs (98-108)
for i in {98..108}; do
    num=$(printf "%03d" $i)
    create_exercise "$num" "${exercises[$idx]}" "c-fundamentals/src/07-structs" "c-fundamentals/src/07-structs/ex${num}.c"
    ((idx++))
done

echo "✓ Created ALL 108 exercise templates with titles!"
echo "  01-basics:    18 files (ex01.c - ex18.c)"
echo "  02-loops:     18 files (ex19.c - ex36.c)"
echo "  03-arrays:    20 files (ex37.c - ex56.c)"
echo "  04-strings:   16 files (ex57.c - ex72.c)"
echo "  05-functions: 14 files (ex73.c - ex86.c)"
echo "  06-pointers:  11 files (ex87.c - ex97.c)"
echo "  07-structs:   11 files (ex098.c - ex108.c)"

# Crear script generador de ejercicios
cat > c-fundamentals/generate_exercise.sh << 'EOF'
#!/bin/bash
# Generate template for new exercise

if [ $# -ne 3 ]; then
    echo "Usage: $0 <level> <number> <title>"
    echo "Example: $0 01-basics 04 calculator"
    exit 1
fi

LEVEL=$1
NUM=$2
TITLE=$3

FILENAME="src/${LEVEL}/ex${NUM}_${TITLE}.c"

if [ -f "$FILENAME" ]; then
    echo "Error: File $FILENAME already exists"
    exit 1
fi

cat > "$FILENAME" << TEMPLATE
/**
 * Exercise ${NUM}: ${TITLE^}
 * 
 * Description:
 *   TODO: Add description
 *
 * Input:
 *   TODO: Describe input
 *
 * Output:
 *   TODO: Describe output
 */

#include <stdio.h>
#include <stdlib.h>

int main(void) {
    // TODO: Implement exercise
    
    return 0;
}
TEMPLATE

echo "✓ Created: $FILENAME"
echo "Edit the file and implement the exercise!"
EOF

chmod +x c-fundamentals/generate_exercise.sh

# Copy exercises list to repo
cat > c-fundamentals/EXERCISES.md << 'EXLIST'
cat > c-fundamentals/docs/PROGRESS.md << 'EOF'
# Progress Tracker

## Week 1

### Day 1 (Exercises 1-10)
- [ ] 01. Hello World
- [ ] 02. Variables básicas
- [ ] 03. Suma de dos números
- [ ] 04. Calculadora básica
- [ ] 05. Celsius a Fahrenheit
- [ ] 06. Área de círculo
- [ ] 07. Intercambiar variables
- [ ] 08. Mayor de 3
- [ ] 09. Par o impar
- [ ] 10. Año bisiesto

### Day 2 (Exercises 11-20)
...

## Notes

### Lessons Learned
- 

### Challenges Faced
- 

### Next Steps
- 
EOF

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. cd c-fundamentals"
echo "2. make              # Compile example exercises"
echo "3. make run-01-basics/ex01_hello"
echo "4. ./generate_exercise.sh 01-basics 04 calculator"
echo ""
echo "Directory structure created in: ./c-fundamentals"
echo ""
echo "Happy coding! 🚀"