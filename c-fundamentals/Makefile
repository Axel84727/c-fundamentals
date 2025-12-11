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
