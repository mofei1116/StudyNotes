```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#define cutOff 50

int a[100005];

void quick_sort(int a[], int n);
void quickSort(int a[], int left, int right);
void swap(int* a, int* b);
int choosePivot(int a[], int left, int right);
void insertSort(int a[], int left, int right);

int main() {
	int n;
	scanf("%d", &n);
	for (int i = 0; i < n; i++) {
		scanf("%d", &a[i]);
	}
	quick_sort(a, n);
	printf("%d", a[0]);
	for (int i = 1; i < n; i++)printf(" %d", a[i]);
	return 0;
}

void quick_sort(int a[], int n) {   //函数接口
	quickSort(a, 0, n - 1);
}

void quickSort(int a[], int left, int right) {
	if (right - left >= cutOff) {
		int pivot = choosePivot(a, left, right);
		int i = left, j = right - 1;
		while (1) {
			while (a[++i] < pivot);
			while (a[--j] > pivot);
			if (i < j)swap(&a[i], &a[j]);
			else break;
		}
		swap(&a[i], &a[right - 1]);
		quickSort(a, left, i - 1);
		quickSort(a, i + 1, right);
	}
	else insertSort(a, left, right);
}

void swap(int* a, int* b) {
	int temp = *a;
	*a = *b;
	*b = temp;
}

int choosePivot(int a[], int left, int right) {
	int center = (left + right) / 2;
	if (a[left] > a[center])swap(&a[left], &a[center]);
	if (a[left] > a[right])swap(&a[left], &a[right]);
	if (a[center] > a[right])swap(&a[center], &a[right]);
	swap(&a[center], &a[right - 1]);
	return a[right - 1];
}

void insertSort(int a[], int left, int right) {
	int i, p;
	for (p = left + 1; p <= right; p++) {
		int temp = a[p];
		for (i = p; i > left && a[i - 1] > temp; i--) {
			a[i] = a[i - 1];
		}
		a[i] = temp;
	}
}
```