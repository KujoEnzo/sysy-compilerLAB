int getint(void);
void putint(int);
void putch(int);

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
    int n = getint();
    putint(fact(n));
    putch(10);
    return 0;
}