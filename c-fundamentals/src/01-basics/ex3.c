/**
 * Exercise 3: Suma de dos números
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
    float num1, num2 = 0.0;

    printf("Enter first number: ");
    scanf("%f", &num1);
    printf("Enter second number: ");
    scanf("%f", &num2);

    float sum = num1 + num2;
    printf("The sum of %.2f and %.2f is %.2f\n",num1,num2,sum);
    return 0;
}
