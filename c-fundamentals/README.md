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
