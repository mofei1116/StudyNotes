```Cpp
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int a[100005];

void bubble_sort(int a[], int n);
void insertation_sort(int a[], int n);
void shell_sort(int a[], int n);
void selection_sort(int a[], int n);
void heap_sort(int a[], int n);
void merge_sort_1(int a[], int n);
void Msort_1(int a[], int tempA[], int l, int rEnd);
void merge_1(int a[], int tempA[], int l, int r, int rEnd);
void merge_2(int a[], int tempA[], int l, int r, int rEnd);
void Msort_2(int a[], int tempA[], int n, int length);
void merge_sort_2(int a[], int n);

int main() {
	int n;
	scanf("%d", &n);
	for (int i = 0; i < n; i++) {
		scanf("%d", &a[i]);
	}
	//bubble_sort(a, n);
	//insertation_sort(a, n);
	//shell_sort(a, n);
	//selection_sort(a, n);
	//heap_sort(a, n);
	//merge_sort_1(a, n);
	merge_sort_2(a, n);
	printf("%d", a[0]);
	for (int i = 1; i < n; i++)printf(" %d", a[i]);
	return 0;
}

void bubble_sort(int a[], int n) {
	int p, i;
	for (p = n - 1; p >= 0; p--) {
		int flag = 0;
		for (i = 0; i < p; i++) {
			if (a[i] > a[i + 1]) {
				int temp = a[i];
				a[i] = a[i + 1];
				a[i + 1] = temp;
				flag = 1;
			}
		}
		if (!flag)break;
	}
}

void insertation_sort(int a[], int n) {
	int p, i;
	for (p = 1; p < n; p++) {
		int temp = a[p];
		for (i = p; i >= 1 && a[i - 1] > temp; i--) {
			a[i] = a[i - 1];
		}
		a[i] = temp;
	}
}

void shell_sort(int a[], int n) {
	int d, p, i;
	for (d = n / 2; d > 0; d /= 2) {
		for (p = d; p < n; p++) {
			int temp = a[p];
			for (i = p; i >= d && a[i - d] > temp; i -= d) {
				a[i] = a[i - d];
			}
			a[i] = temp;
		}
	}
}

void selection_sort(int a[], int n) {
	int i, j, temp, p;
	for (i = 0; i < n; i++) {
		double min = INFINITY;
		for (j = i; j < n; j++) {
			if (a[j] < min) {
				min = a[j];
				p = j;
			}
		}
		temp = a[p];
		a[p] = a[i];
		a[i] = temp;
	}
}

void heap_sort(int a[], int n) {
	int parent, child, p, i;
	//建最大堆
	for (p = (n - 1 - 1) / 2; p >= 0; p--) {
		//向下过滤
		int temp = a[p];
		for (parent = p; parent * 2 + 1 <= n - 1; parent = child) {
			child = parent * 2 + 1;
			if (child + 1 <= n - 1 && a[child] < a[child + 1])child++;
			if (temp > a[child])break;
			a[parent] = a[child];
		}
		a[parent] = temp;
	}
	int size = n - 1;
	for (p = n - 1; p > 0; p--) {
		//最大的与最后的交换
		int temp = a[p];
		a[p] = a[0];
		a[0] = temp;
		//将最后一个排出最大堆
		size--;
		//向下过滤
		for (parent = 0; parent * 2 + 1 <= size; parent = child) {
			child = parent * 2 + 1;
			if (child + 1 <= size && a[child] < a[child + 1])child++;
			if (temp > a[child])break;
			a[parent] = a[child];
		}
		a[parent] = temp;
	}
}

void merge_sort_1(int a[], int n) {    //统一函数接口
	int* tempA = (int*)malloc(sizeof(int) * n);
	if (tempA != NULL) {
		Msort_1(a, tempA, 0, n - 1);
		free(tempA);
	}
	else printf("Lack of space\n");
}

void Msort_1(int a[], int tempA[], int l, int rEnd) {    //递归算法
	if (l < rEnd) {
		int center = (l + rEnd) / 2;
		Msort_1(a, tempA, l, center);
		Msort_1(a, tempA, center + 1, rEnd);
		merge_1(a, tempA, l, center + 1, rEnd);
	}
}

void merge_1(int a[], int tempA[], int l, int r, int rEnd) {
	int lEnd = r - 1;
	int number = rEnd - l + 1;
	int temp = l;
	while (l <= lEnd && r <= rEnd) {
		if (a[l] <= a[r])tempA[temp++] = a[l++];
		else tempA[temp++] = a[r++];
	}
	while (l <= lEnd)tempA[temp++] = a[l++];
	while (r <= rEnd)tempA[temp++] = a[r++];
	for (int i = 0; i < number; i++, rEnd--) {
		a[rEnd] = tempA[rEnd];
	}
}

void merge_2(int a[], int tempA[], int l, int r, int rEnd) {
	int lEnd = r - 1;
	int number = rEnd - l + 1;
	int temp = l;
	while (l <= lEnd && r <= rEnd) {
		if (a[l] <= a[r])tempA[temp++] = a[l++];
		else tempA[temp++] = a[r++];
	}
	while (l <= lEnd)tempA[temp++] = a[l++];
	while (r <= rEnd)tempA[temp++] = a[r++];
	//不需要将tempA导回a
	/*for (int i = 0; i < number; i++, rEnd--) {
		a[rEnd] = tempA[rEnd];
	}*/
}

void Msort_2(int a[], int tempA[], int n, int length) {    //非递归算法
	int i, j;
	for (i = 0; i <= n - length * 2; i += length * 2) {
		merge_2(a, tempA, i, i + length, i + length * 2 - 1);
	}
	if (i + length < n)merge_2(a, tempA, i, i + length, n - 1);
	else {
		for (j = i; j < n; j++)tempA[j] = a[j];
	}
}

void merge_sort_2(int a[], int n) {    //统一函数接口
	int length = 1;
	int* tempA = (int*)malloc(sizeof(int) * n);
	if (tempA != NULL) {
		while (length < n) {
			Msort_2(a, tempA, n, length);
			length *= 2;
			Msort_2(tempA, a, n, length);
			length *= 2;
		}
		free(tempA);
	}
	else printf("Lack of space\n");
}
```