/**
 * Exercise 6: Área de círculo
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
    const float pi = 3.14159;
    printf("Ingrese el radio del circulo: ");
    float radio;
    scanf("%f", &radio);
    float area = pi * radio * radio;
    printf("El area del circulo es: %.2f\n", area);
    printf("el perimetro del circulo es: %.2f\n", 2 * pi * radio);
    return 0;
}
