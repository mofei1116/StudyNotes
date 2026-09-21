```
#include <stdio.h>
#include <stdlib.h>
#define MaxVertexNum 10

typedef struct matrixgraph_ {
    int nVertex;
    int nedge;
    int graph[MaxVertexNum][MaxVertexNum];
    int visited[MaxVertexNum];
} mGraph;

typedef int Vertex;
//typedef int weight;

typedef struct edge_{
    Vertex v1,v2;
    //weight w;
}edge;

typedef struct queuenode_{
    Vertex v;
    struct queuenode* next;
}queueNode;

typedef struct queue_{
    queueNode *head,*rear;
}Queue;

mGraph *createGraph(int vertexNum);
void insertGraph(mGraph* G,edge* E);
mGraph* buildGraph();
void searchGraph(mGraph* G,void (*fp)(mGraph* G,Vertex v));
void initVisited(mGraph* G);
void DFS(mGraph* G,Vertex v);
Queue* createQueue();
void addQueueNode(Queue* Q,Vertex v);
Vertex deleteQueueNode(Queue* Q);
void BFS(mGraph* G,Vertex v);

int main() {
    setbuf(stdout,NULL);
    mGraph* G=buildGraph();
    searchGraph(G,DFS);
    searchGraph(G,BFS);
    return 0;
}

mGraph *createGraph(int vertexNum) {
    Vertex v, w;
    mGraph* G=(mGraph*)malloc(sizeof(mGraph));
    //初始化G
    G->nVertex=vertexNum;
    G->nedge=0;
    for(v=0;v<vertexNum;v++){
        for(w=0;w<vertexNum;w++){
            G->graph[v][w]=0;
        }
    }
    return G;
}

void insertGraph(mGraph* G,edge* E){
    G->graph[E->v1][E->v2]=1;
    G->graph[E->v2][E->v1]=1;
}

mGraph* buildGraph(){
    mGraph* G;
    edge* E=(edge*)malloc(sizeof(edge));
    Vertex V;
    int i;
    scanf("%d",&V);
    G=createGraph(V);
    scanf("%d",&(G->nedge));
    if(G->nedge!=0){
        for(i=0;i<G->nedge;i++){
            scanf("%d %d",&(E->v1),&(E->v2));
            insertGraph(G,E);
        }
    }
    free(E);
    return G;
}

void searchGraph(mGraph* G,void (*fp)(mGraph* G,Vertex v)){
    initVisited(G);
    Vertex v;
    for(v=0;v<G->nVertex;v++){
        if(G->visited[v]==0){
            printf("{ ");
            fp(G,v);
            printf("}\n");
        }
    }
}

void initVisited(mGraph* G){
    Vertex v;
    for(v=0;v<G->nVertex;v++){
        G->visited[v]=0;
    }
}

void DFS(mGraph* G,Vertex v){
    G->visited[v]=1;
    printf("%d ",v);
    Vertex w;
    for(w=0;w<G->nVertex;w++){
        if(G->graph[v][w]&&G->visited[w]==0){
            DFS(G,w);
        }
    }
}

void BFS(mGraph* G,Vertex v){
    Queue* Q=createQueue();
    addQueueNode(Q,v);
    G->visited[v]=1;
    Vertex w,x;
    while(Q->head->next){
        w=deleteQueueNode(Q);
        printf("%d ",w);
        for(x=0;x<G->nVertex;x++){
            if(G->graph[w][x]&&G->visited[x]==0){
                G->visited[x]=1;
                addQueueNode(Q,x);
            }
        }
    }
}

Queue* createQueue(){
    Queue* Q=(Queue*)malloc(sizeof(Queue));
    Q->head=(queueNode*)malloc(sizeof(queueNode));
    Q->head->next=Q->rear=NULL;
    return Q;
}

void addQueueNode(Queue* Q,Vertex v){
    queueNode* p=(queueNode*)malloc(sizeof(queueNode));
    p->v=v;
    p->next=NULL;
    if(Q->head->next==NULL){
        Q->head->next=Q->rear=p;
    }
    else {
        Q->rear->next=p;
        Q->rear=p;
    }
}

Vertex deleteQueueNode(Queue* Q){
    if(Q->head->next==NULL)return -1;
    queueNode* p=Q->head->next;
    Vertex w=p->v;
    Q->head->next=p->next;
    free(p);
    return w;
}
```