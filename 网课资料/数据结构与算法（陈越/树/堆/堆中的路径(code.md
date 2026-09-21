```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1

#include <stdio.h>
#include <stdlib.h>

int* createMinHeap(int n);
void adjustHeap(int* H, int p, int n);
void printH(int* H, int p);

int main() {
    int n, m;
    scanf("%d %d", &n, &m);
    int* H = createMinHeap(n);
    int p;
    while (m) {
        scanf("%d", &p);
        printH(H, p);
    }
    return 0;
}

int* createMinHeap(int n) {
    int* H = (int*)malloc(sizeof(int) * (n + 1));
    H[0] = -10001;
    int i;
    for (i = 1; i <= n; i++) {
        scanf("%d", &H[i]);
    }
    int p = n / 2;
    while (p) {
        adjustHeap(H, p, n);
        /*int i;
        for (i = 1; i <= n; i++) {
            printf("%d ", H[i]);
        }
        printf("\n------\n");*/
        p--;
    }
    return H;
}

void adjustHeap(int* H, int p,int n) {
    int parent = p, child;
    while (parent * 2 <= n) {
        child = parent * 2;
        if ((child != n) && H[child] > H[child + 1])child += 1;
        if (H[parent] < H[child])break;
        else {
            int temp = H[parent];
            H[parent] = H[child];
            H[child] = temp;
        }
        parent = child;
    }
}

void printH(int* H,int p) {
    while (p) {
        if (p != 1) {
            printf("%d ", H[p]);
        }
        else printf("%d", H[p]);
        p /= 2;
    }
    printf("\n");
}
```