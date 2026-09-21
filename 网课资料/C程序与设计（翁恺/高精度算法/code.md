```C
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1

#include <stdio.h>
#include <string.h>

char s1[505];
char s2[505];
int a[505] = { 0 };
int b[505] = { 0 };
int c[505] = { 0 };
int p[505] = { 0 };

void add();
void substruct();
void multiply();
void divide_1();
void divide_2();

int main() {
    substruct();
    return 0;
}

void add() {
    int la, lb, lc;
    scanf("%s", &s1);
    scanf("%s", &s2);
    la = strlen(s1);
    lb = strlen(s2);
    int i;
    for (i = 0; i < la; i++) {
        a[la - i - 1] = s1[i] - '0';
    }
    for (i = 0; i < lb; i++) {
        b[lb - i - 1] = s2[i] - '0';
    }
    lc = (la > lb) ? la : lb;
    for (i = 0; i < lc; i++) {
        c[i] += a[i] + b[i];
        c[i + 1] = c[i] / 10;
        c[i] = c[i] % 10;
    }
    while (!c[lc - 1])lc--;
    for (i = lc - 1; i >= 0; i--) {
        printf("%d", c[i]);
    }
}

int compare(int la,int lb,int a[],int b[]) {
    if (la > lb) {
        return 1;
    }
    else if (la < lb) {
        return -1;
    }
    else {
        int i;
        for (i = 0; i < la; i++) {
            if (a[i] > b[i]) {
                return 1;
            }
            else if (a[i] < b[i]) {
                return -1;
            }
        }
    }
    return 0;
}

//先默认s1[]的数字比s2[]大
void substruct() {
    int la, lb, lc;
    scanf("%s", &s1);
    scanf("%s", &s2);
    la = strlen(s1);
    lb = strlen(s2);
    int i;
    for (i = 0; i < la; i++) {
        a[la - i - 1] = s1[i] - '0';
    }
    for (i = 0; i < lb; i++) {
        b[lb - i - 1] = s2[i] - '0';
    }
    lc = (la > lb) ? la : lb;
    for (i = 0; i < lc; i++) {
        if (a[i] < b[i]) {
            a[i + 1]--;
            a[i] += 10;
        }
        c[i] = a[i] - b[i];
    }
    while (!c[lc - 1])lc--;
    for (i = lc - 1; i >= 0; i--) {
        printf("%d", c[i]);
    }
}

void multiply() {
    int i, j;
    int la, lb, lc;
    scanf("%s", &s1);
    scanf("%s", &s2);
    la = strlen(s1);
    lb = strlen(s2);
    for (i = 0; i < la; i++) {
        a[la - i - 1] = s1[i] - '0';
    }
    for (i = 0; i < lb; i++) {
        b[lb - i - 1] = s2[i] - '0';
    }
    lc = la + lb;   //积最多la+lb位
    for (i = 0; i < la; i++) {
        for (j = 0; j < lb; j++) {
            c[i + j] += a[i] * b[j];
            c[i + j + 1] += c[i + j] / 10;
            c[i + j] %= 10;
        }
    }
    while (!c[lc - 1])lc--;
    for (i = lc - 1; i >= 0; i--) {
        printf("%d", c[i]);
    }
}

//高精度除以低精度，逐位使商法
void divide_1() {
    int i, la, lc, b, x = 0;
    scanf("%s", &s1);
    scanf("%d", &b);
    la = strlen(s1);
    lc = la;    //商最多la位
    for (i = 0; i < la; i++) {
        a[i] = s1[i] - '0';   //不需要将数字倒序
    }
    for (i = 0; i < lc; i++) {
        c[i] = (x * 10 + a[i]) / b;
        x = (x * 10 + a[i]) % b;
    }
    while (!c[lc - 1])lc--;
    i = 0;
    while (!c[i])i++;
    for (i; i < lc; i++) {
        printf("%d", c[i]);
    }
    printf("----%d", x);
}

//高精度除以高精度，减法模拟除法
/*
void divide_2() {
    int i, j;
    int la, lb, lc;
    scanf("%s", &s1);   //被除数
    scanf("%s", &s2);   //除数
    la = strlen(s1);
    lb = strlen(s2);
    for (i = 0; i < la; i++) {
        a[la - i - 1] = s1[i] - '0';
    }
    for (i = 0; i < lb; i++) {
        b[lb - i - 1] = s2[i] - '0';
    }
    lc = la - lb + 1;
    for (i = la - 1; i > 0; i--) {
        for (j = 0; j < lb; j++) {
            p[i - j] = s2[i] - '0';
        }
    }
}
*/
```