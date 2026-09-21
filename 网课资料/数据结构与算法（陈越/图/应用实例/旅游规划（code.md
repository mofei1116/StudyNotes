```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>
#define MaxNumber 1000

typedef struct road_ {
    int length;
    int cost;
}Road;

typedef struct mgraph_ {
    int n;
    int m;
    Road** graph;
}mGraph;

typedef int Vertex;

mGraph* createGraph(int n, int m);
mGraph* buildGraph(int n, int m);
void Dijkstra(int s, int d, mGraph* G);
int findMinDist(mGraph* G, int dist[], int collected[], int s);

int main() {
    int n, m, s, d;
    scanf("%d %d %d %d", &n, &m, &s, &d);
    mGraph* G = buildGraph(n, m);
    Dijkstra(s, d, G);
    return 0;
}

mGraph* createGraph(int n, int m) {
    mGraph* G = (mGraph*)malloc(sizeof(mGraph));
    G->n = n;
    G->m = m;
    Road** graph = (Road**)malloc(sizeof(Road*) * n);
    for (int i = 0; i < n; i++) {
        graph[i] = (Road*)malloc(sizeof(Road) * n);
    }
    G->graph = graph;
    //初始化
    for (Vertex i = 0; i < n; i++) {
        for (Vertex j = 0; j < n; j++) {
            G->graph[i][j].length = G->graph[i][j].cost = MaxNumber;
        }
    }
    return G;
}

mGraph* buildGraph(int n, int m) {
    mGraph* G = createGraph(n, m);
    Vertex v1, v2, w;
    int length, cost;
    for (w = 0; w < m; w++) {
        scanf("%d %d %d %d", &v1, &v2, &length, &cost);
        G->graph[v1][v2].length = length;
        G->graph[v1][v2].cost = cost;
        G->graph[v2][v1].length = length;
        G->graph[v2][v1].cost = cost;
    }
    for (Vertex i = 0; i < n; i++) {
        G->graph[i][i].length = G->graph[i][i].cost = 0;
    }
    //debug
    /*for (Vertex i = 0; i < n; i++) {
        for (Vertex j = 0; j < n; j++) {
            G->graph[i][j] = G->graph[i][j];
        }
    }*/
    return G;
}

void Dijkstra(int s,int d,mGraph* G) {
    int* dist = (int*)malloc(sizeof(int) * (G->n));
    int* cost = (int*)malloc(sizeof(int) * (G->n));
    int* collected = (int*)malloc(sizeof(int) * (G->n));
    //初始化dist
    for (Vertex i = 0; i < G->n; i++) {
        dist[i] = G->graph[s][i].length;
    }
    //初始化cost
    for (Vertex i = 0; i < G->n; i++) {
        cost[i] = G->graph[s][i].cost;
    }
    //初始collected
    for (Vertex i = 0; i < G->n; i++) {
        collected[i] = 0;
    }
    collected[s] = 1;
    Vertex v;
    do {
        v = findMinDist(G, dist,collected, s);
        if (v == -1)break;
        collected[v] = 1;
        for (Vertex i = 0; i < G->n; i++) {
            if (G->graph[v][i].length != MaxNumber && collected[i] == 0) {
                if (dist[v] + G->graph[v][i].length < dist[i]) {
                    dist[i] = dist[v] + G->graph[v][i].length;
                    cost[i] = cost[v] + G->graph[v][i].cost;
                }
                else if (dist[v] + G->graph[v][i].length == dist[i]) {
                    if (cost[v] + G->graph[v][i].cost < cost[i]) {
                        cost[i] = cost[v] + G->graph[v][i].cost;
                    }
                }
            }
        }
    } while (v != d);
    printf("%d %d", dist[d], cost[d]);
}

int findMinDist(mGraph* G, int dist[],int collected[], int s) {
    Vertex v = -1;
    int min = MaxNumber;
    for (Vertex i = 0; i < G->n; i++) {
        if (collected[i] == 0) {
            if (dist[i] < min && dist[i] != 0) {
                v = i;
                min = dist[i];
            }
            //??
            /*else if (dist[i] == min && min != MaxNumber) {
                if (G->graph[s][i].cost < G->graph[s][v].cost)
                    v = i;
            }*/
        }
    }
    return v;
}
```