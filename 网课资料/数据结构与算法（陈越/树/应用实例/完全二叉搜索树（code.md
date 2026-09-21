```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void inputNumber(int n,int number[]);
void reSort(int n, int number[]);
void buildCBST(int number[], int treeNode[], int root, int left, int right);
void levelorderTraversal(int treeNode[], int n);
int compare(const void* a, const void* b);
int getLeftSubTreeNumber(int n);

int main() {
	//int number[1005] = { 0 };
	//int treeNode[1005] = { 0 };
	int n;
	scanf("%d",&n);
	int* number = (int*)malloc(sizeof(int) * n);
	int* treeNode = (int*)malloc(sizeof(int) * (n + 1));
	inputNumber(n,number);
	//reSort(n, number);
	qsort(number, n, sizeof(int), compare);
	buildCBST(number, treeNode, 1, 0, n - 1);
	levelorderTraversal(treeNode, n);
	return 0;
}

void inputNumber(int n,int number[]) {
	int i;
	for (i = 0; i < n; i++) {
		scanf("%d", &number[i]);
	}
}

void reSort(int n,int number[]) {
	int i, j;
	for (i = 0; i < n; i++) {
		for (j = i + 1; j < n; j++) {
			if (number[i] > number[j]) {
				int temp = number[j];
				number[j] = number[i];
				number[i] = temp;
			}
		}
	}
} 

void buildCBST(int number[], int treeNode[], int root, int left, int right) {
	if (left > right)return;
	int L = getLeftSubTreeNumber(right - left + 1);
	treeNode[root] = number[left + L];
	buildCBST(number, treeNode, root * 2, left, left + L - 1);   //左子树
	buildCBST(number, treeNode, root * 2 + 1, left + L + 1, right);    //右子树
}

void levelorderTraversal(int treeNode[], int n) {
	int i;
	for (i = 1; i <= n; i++) {
		printf("%d", treeNode[i]);
		if (i != n)printf(" ");
	}
}

int compare(const void* a, const void* b) {
	return (*(int*)a - *(int*)b);
}

int getLeftSubTreeNumber(int n) {
	int deepth = (log(n + 1) / log(2));
	int x = n - (int)pow(2, deepth) + 1;
	if (x > (int)pow(2, deepth-1))x =(int)pow(2, deepth-1);
	return (int)pow(2, deepth - 1) - 1 + x;
}
```