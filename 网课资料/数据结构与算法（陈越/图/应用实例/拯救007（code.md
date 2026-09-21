```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define MaxNumber 105
#define border 50

typedef struct coordinate_ {
	int x, y;
}XY;

int graph[MaxNumber][MaxNumber] = { 0 };   //0没有边，1有边
XY coord[MaxNumber];
int queue[MaxNumber];

void getCoordinate(int n);
void buildGraph(int n, int d);
int canJump(double d, int i, int j);
int BFS(int n);

int main() {
	int n, d;
	scanf("%d %d", &n, &d);
	getCoordinate(n);
	buildGraph(n, d);
	if (BFS(n))printf("Yes\n");
	else printf("No\n");
	return 0;
}

void getCoordinate(int n) {
	coord[0] = (XY){ 0,0 };
	for (int i = 1; i <= n; i++) {
		scanf("%d %d", &coord[i].x, &coord[i].y);
	}
}

void buildGraph(int n, int d) {
	//单独判断原点
	for (int j = 1; j <= n; j++) {
		if (canJump(d + 15.0 / 2, 0, j)) {
			graph[0][j] = graph[j][0] = 1;
		}
	}
	for (int i = 1; i <= n; i++) {
		for (int j = i + 1; j <= n; j++) {
			if (canJump((double)d, i, j)) {
				graph[i][j] = graph[j][i] = 1;
			}
		}
	}
	//单独判断边界
	for (int j = 0; j <= n; j++) {
		if (fabs(coord[j].x - border) <= d || fabs(coord[j].y - border) <= d) {
			graph[j][n + 1] = graph[n + 1][j] = 1;
		}
	}
}

int canJump(double d, int i, int j) {
	double dist = sqrt(pow(coord[i].x - coord[j].x, 2.0) + pow(coord[i].y - coord[j].y, 2.0));
	return (dist <= d);
}

int BFS(int n) {
	int answer = 0;
	int visited[MaxNumber] = { 0 };
	int head = -1, rear = -1;
	int v = 0;
	queue[++rear] = v; head++;
	visited[v] = 1;
	while (head <= rear) {
		v = queue[head++];
		if (v == n + 1)answer = 1;
		for (int i = 0; i <= n + 1; i++) {
			if (visited[i] == 0 && graph[v][i] == 1) {
				visited[i] = 1; queue[++rear] = i;
			}
		}
	}
	return answer;
}
```