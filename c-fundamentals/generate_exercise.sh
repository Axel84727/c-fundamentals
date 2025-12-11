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
