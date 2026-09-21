```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#define MAXn 105
#define MAXstring 105

int Graph[MAXn][MAXn] = { 0 };
int SP[MAXn][MAXn] = { 0 };
int maxPath[MAXn] = { 0 };

typedef int Vertex;

void buildEdge(int m);
void initSP(int n);
int Floyd(int n);
void getMaxPath(int n);
void findMinMaxPath(int n);
void findMinMaxPath_1(int n);

int main() {
	int n, m;
	scanf("%d %d", &n, &m);
	buildEdge(m);
	Floyd(n);
	//getMaxPath(n);
	//findMinMaxPath(n);
	findMinMaxPath_1(n);
	return 0;
}

void buildEdge(int m) {
	Vertex v1, v2, weight;
	for (int i = 0; i < m; i++) {
		scanf("%d %d %d", &v1, &v2, &weight);
		Graph[v1][v2] = Graph[v2][v1] = weight;
	}
}

void initSP(int n) {
	for (Vertex i = 1; i <= n; i++) {
		for (Vertex j = 1; j <= n; j++) {
			if (Graph[i][j])SP[i][j] = Graph[i][j];
			else {
				if (i != j)SP[i][j] = MAXstring * n;
			}
		}
	}
}

int Floyd(int n) {
	initSP(n);
	Vertex i, j, k;
	for (k = 1; k <= n; k++) {
		for (i = 1; i <= n; i++) {
			for (j = 1; j <= n; j++) {
				if (SP[i][k] + SP[k][j] < SP[i][j]) {
					SP[i][j] = SP[i][k] + SP[k][j];
					//if (i == j && SP[i][j] < 0)return 0;    //发现负值圈
				}
			}
		}
	}
	return 1;
}

void getMaxPath(int n) {
	Vertex i, j;
	for (i = 1; i <= n; i++) {
		int maxLen = -1;
		for (j = 1; j <= n; j++) {
			if (SP[i][j] > maxLen)maxLen = SP[i][j];
		}
		maxPath[i] = maxLen;
	}
}

void findMinMaxPath(int n) {
	int minLen = MAXstring * n;
	Vertex x = 0;
	for (Vertex i = 1; i <= n; i++) {
		if (maxPath[i] < minLen) {
			minLen = maxPath[i];
			x = i;
		}
	}
	if (x)printf("%d %d", x, minLen);
	else printf("%d", x);
}

void findMinMaxPath_1(int n) {
	Vertex i, j, x = 0;
	int minMaxP = MAXstring * n;
	for (i = 1; i <= n; i++) {
		int maxPath = -1;
		for (j = 1; j <= n; j++) {
			if (SP[i][j] > maxPath)maxPath = SP[i][j];
		}
		if (maxPath < minMaxP) {
			minMaxP = maxPath;
			x = i;
		}
	}
	if (x)printf("%d %d", x, minMaxP);
	else printf("%d", x);
}
```