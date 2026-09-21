```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>

typedef int Vertex;

typedef struct vertexnode {
	Vertex v;
	struct vertexnode* next;
}vertexNode;

typedef struct listgraph_{
	int vertexNumber;
	int edgeNumber;
	//vertexNode* vNode;
	//int* visited;
	vertexNode vNode[1005];
	int visited[1005];
}Lgraph;

typedef struct edge_ {
	Vertex v1, v2;
}Edge;

typedef struct queuenode_ {
	Vertex w;
	struct queuenode_* next;
}queueNode;

typedef struct queue_ {
	queueNode* front, * rear;
}Queue;

int cnt;

Lgraph* createGraph(int vertexNumber, int edgeNumber);
void initVisited(Lgraph* G);
Lgraph* buildGraph();
void addEdge(Lgraph* G, Edge* E);
void DFS(Lgraph* G, Vertex v);
void checkVertexNode(Lgraph* G);
void printRate(Lgraph* G, Vertex v);
void BFS(Lgraph* G, Vertex v);
Queue* createQueue();
void addQueue(Queue* Q, Vertex v);
Vertex deleteQueue(Queue* Q);

int main_0() {
	Lgraph* G = buildGraph();
	checkVertexNode(G);
	return 0;
}

Lgraph* createGraph(int vertexNumber, int edgeNumber) {
	Lgraph* G = (Lgraph*)malloc(sizeof(Lgraph));
	G->vertexNumber = vertexNumber;
	G->edgeNumber = edgeNumber;
	//vertexNode* vNode = (vertexNode*)malloc(sizeof(vertexNode) * vertexNumber);
	Vertex v;
	for (v = 1; v <= vertexNumber; v++) {
		G->vNode[v].next = NULL;
	}
	//G->vNode = vNode;
	/*int* visited = (int*)malloc(sizeof(int) * vertexNumber);
	G->visited = visited;*/
	return G;
}

void initVisited(Lgraph* G) {
	Vertex v;
	for (v = 1; v <= G->vertexNumber; v++) {
		G->visited[v] = 0;
	}
}

Lgraph* buildGraph() {
	int vertexNumber, edgeNumber;
	scanf("%d %d", &vertexNumber, &edgeNumber);
	Lgraph* G = createGraph(vertexNumber,edgeNumber);
	Edge* E = (Edge*)malloc(sizeof(Edge));
	int e;
	for (e = 0; e < G->edgeNumber; e++) {
		scanf("%d %d", &(E->v1), &(E->v2));
		addEdge(G, E);
	}
	free(E);
	return G;
}

void addEdge(Lgraph* G, Edge* E) {
	vertexNode* w = (vertexNode*)malloc(sizeof(vertexNode));
	vertexNode* x = (vertexNode*)malloc(sizeof(vertexNode));
	w->v = E->v1;
	x->v = E->v2;
	x->next = G->vNode[E->v1].next;
	G->vNode[E->v1].next = x;
	w->next = G->vNode[E->v2].next;
	G->vNode[E->v2].next = w;
}

void DFS(Lgraph* G, Vertex v) {
	static int recursionCnt = 0;
	recursionCnt++;
	cnt++;
	G->visited[v] = 1;
	if (recursionCnt == 7) {
		recursionCnt--;
		return;
	}
	vertexNode* w = G->vNode[v].next;
	while (w) {
		if (G->visited[w->v] == 0) {
			DFS(G, w->v);
		}
		w = w->next;
	}
	recursionCnt--;
	return;
}

void checkVertexNode(Lgraph* G) {
	Vertex v;
	for (v = 1; v <= G->vertexNumber; v++) {
		cnt = 0;
		initVisited(G);
		//DFS(G, v);
		BFS(G, v);
		printRate(G,v);
	}
}

void printRate(Lgraph* G,Vertex v) {
	double rate = cnt / (double)G->vertexNumber;
	printf("%d: %.2f%%\n", v , rate*100);
}

void BFS(Lgraph* G,Vertex v) {
	Queue* Q = createQueue();
	cnt = 1;
	int level = 0;
	Vertex last = v, tail;
	addQueue(Q, v);
	G->visited[v] = 1;
	while (Q->front->next != NULL) {
		Vertex v = deleteQueue(Q);
		vertexNode* w = G->vNode[v].next;
		while (w) {
			if (G->visited[w->v] == 0) {
				G->visited[w->v] = 1;
				cnt++;
				addQueue(Q, w->v);
				tail = w->v;
			}
			w = w->next;
		}
		if (v == last) {
			level++;
			last = tail;
		}
		if (level == 6)break;
	}
}

Queue* createQueue() {
	Queue* Q = (Queue*)malloc(sizeof(Queue));
	Q->rear = NULL;
	queueNode* front = (queueNode*)malloc(sizeof(queueNode));
	front->next = NULL;
	Q->front = front;
	return Q;
}

void addQueue(Queue* Q, Vertex v) {
	queueNode* p = (queueNode*)malloc(sizeof(queueNode));
	p->w = v;
	p->next = NULL;
	if (Q->front->next == NULL) {
		Q->front->next = Q->rear = p;
	}
	else {
		Q->rear->next = p;
		Q->rear = p;
	}
}

Vertex deleteQueue(Queue* Q) {
	queueNode* q = Q->front->next;
	Vertex v = q->w;
	Q->front->next = q->next;
	free(q);
	return v;
}
```