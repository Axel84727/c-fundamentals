/**
 * Exercise 4: Calculadora básica
 * 
 * Description:
 *   See EXERCISES.md for detailed description
 *
 * TODO: Implement this exercise
 */

#include <stdio.h>
#include <stdlib.h>

float sumar(float a, float b) {
    return a + b;
}
float restar(float a, float b) {
    return a - b;
}
float multiplicar(float a, float b) {
    return a * b;
}
float dividir(float a, float b)
{
    if (b == 0) {
        printf("Error: Division by zero\n");
        exit(EXIT_FAILURE);
    }
    return a / b;
}
int main(void)
{
    // Your code here
    float num1, num2;
    char operador;
    printf("Ingrese la operacion (formato: numero1 operador numero2): ");
    scanf("%f %c %f", &num1, &operador, &num2);
    float resultado;
    switch (operador)
    {
    case '+':
        resultado = sumar(num1, num2);
        break;
    case '-':
        resultado = restar(num1, num2);
        break;
    case '*':
        return 0;

    case '/':
        resultado = dividir(num1, num2);
        break;
    default:

        printf("Error: Operador no valido\n");
    }
    printf("Resultado: %.2f\n", resultado);
}