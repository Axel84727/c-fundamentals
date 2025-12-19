/**
 * Exercise 5: Celsius a Fahrenheit
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
    printf("enter the temperature in celsius: ");
    float celsius;
    scanf("%f", &celsius);
    float fahrenheit = (celsius * 9 / 5) + 32;
    printf("the temperature in fahrenheit is: %.2f\n", fahrenheit);
    return 0;
}
