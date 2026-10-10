#include <stdio.h>

int fact(int n) {
    int i = 2;
    int result = 1;

    while (i <= n) {
        result = result * i;
        i = i + 1;
    }

    return result;
}

int main(void) {
    int n;

    if (scanf("%d", &n) != 1) {
        return 1;
    }

    printf("%d\n", fact(n));
    return 0;
}