```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1

#include <stdio.h>
#include <stdlib.h>

typedef struct treenode_ {
    char value;
    struct treenode_* left;
    struct treenode_* right;
}treeNode;

typedef struct stacknode_ {
    treeNode* Tnode;
    struct stacknode_* next;
}stackNode;

typedef struct queuenode_ {
    treeNode* Tnode;
    struct queuenode_* next;
}queueNode;

typedef struct queue_ {
    queueNode* front;//是一个空的头节点
    queueNode* rear;
}Q;

treeNode* createTree();
int isOmorphic(treeNode* tree1, treeNode* tree2);
void inOrder(treeNode* tree);
stackNode* createStack();
int isEmptyS(stackNode* stack);
void push(stackNode* stack, treeNode* p);
treeNode* pop(stackNode* stack);
void levelOrder(treeNode* tree);
Q* createQueue();
void addQ(Q* queue, treeNode* p);
treeNode* deleteQ(Q* queue);

int main() {
    treeNode* tree1 = createTree();
    treeNode* tree2 = createTree();
    //inOrder(tree1);
    levelOrder(tree1);
    printf("-----\n");
    //inOrder(tree2);
    levelOrder(tree2);
    (isOmorphic(tree1, tree2)) ? printf("Yes\n") : printf("No\n");
    return 0;
}

treeNode* createTree() {
    int nodeNumber = 0;
    scanf("%d", &nodeNumber);
    treeNode* tree = (treeNode*)malloc(sizeof(treeNode) * nodeNumber);
    int i;
    char letter,Lnum,Rnum;
    int* check = (int*)malloc(sizeof(int) * nodeNumber);
    for (i = 0; i < nodeNumber; i++)check[i] = 0;//初始化检查数组
    treeNode* root = NULL;
    if (nodeNumber) {
        for (i = 0; i < nodeNumber; i++) {
            getchar();
            scanf("%c %c %c", &letter, &Lnum, &Rnum);
            tree[i].value = letter;
            if (Lnum!='-') {
                tree[i].left = &tree[Lnum - '0'];
                check[Lnum - '0'] = 1;
            }
            else tree[i].left = NULL;
            if (Rnum != '-') {
                tree[i].right = &tree[Rnum - '0'];
                check[Rnum - '0'] = 1;
            }
            else tree[i].right = NULL;
        }
        for (i = 0; i < nodeNumber; i++) {
            if (!check[i])break;
        }
        root = &tree[i];
    }
    return root;
}

//判断是否是同构
int isOmorphic(treeNode* tree1, treeNode* tree2) {
    if (tree1 == NULL && tree2 == NULL)
        return 1;
    if ((tree1 == NULL && tree2 != NULL) || (tree1 != NULL && tree2 == NULL))
        return 0;
    if (tree1->value != tree2->value)
        return 0;
    if (tree1->left == NULL && tree2->left == NULL)
        return isOmorphic(tree1->right, tree2->right);
    if (tree1->left != NULL && tree2->left != NULL && tree1->left->value == tree2->left->value)
        return (isOmorphic(tree1->left, tree2->left) && isOmorphic(tree1->right, tree2->right));
    else return (isOmorphic(tree1->left, tree2->right) && isOmorphic(tree1->right, tree2->left));
}

//中序非递归遍历
void inOrder(treeNode* tree) {
    treeNode* p = tree;
    stackNode* stack = createStack();
    while (p || !isEmptyS(stack)) {
        while (p) {
            push(stack, p);
            p = p->left;
        }
        if (!isEmptyS(stack)) {
            p = pop(stack);
            printf("%c\n", p->value);
            p = p->right;
        }
    }
}

//层序遍历
void levelOrder(treeNode* tree) {
    treeNode* p = tree;
    if (!tree)return;
    Q* queue = createQueue();
    addQ(queue, p);
    while (queue->rear != NULL) {//队列不为空
        p = deleteQ(queue);
        printf("%c\n", p->value);
        if (p->left)addQ(queue, p->left);
        if (p->right)addQ(queue, p->right);
    }
}

stackNode* createStack() {
    stackNode* stack = (stackNode*)malloc(sizeof(stackNode));//头节点
    stack->next = NULL;
    return stack;
}

int isEmptyS(stackNode* stack) {
    return (stack->next == NULL);
}


//入栈操作
void push(stackNode* stack, treeNode* p) {
    stackNode* stackP = (stackNode*)malloc(sizeof(stackNode));
    stackP->Tnode = p;
    stackP->next = stack->next;
    stack->next = stackP;
}

//出栈操作
treeNode* pop(stackNode* stack) {
    treeNode* p = stack->next->Tnode;
    stackNode* stackP = stack->next;
    stack->next = stackP->next;
    free(stackP);
    return p;
}

//创建队列
Q* createQueue() {
    queueNode* p = (queueNode*)malloc(sizeof(queueNode));//头节点
    p->next = NULL;
    Q* queue = (Q*)malloc(sizeof(Q));
    queue->front = p;
    queue->rear = NULL;
    return queue;
}


//入队列
void addQ(Q* queue,treeNode* p) {
    queueNode* q = (queueNode*)malloc(sizeof(queueNode));
    q->Tnode = p;
    q->next = NULL;
    if (!queue->rear) {
        queue->front->next = q;
        queue->rear = q;
    }
    else {
        queue->rear->next = q;
        queue->rear = q;
    }
}

//出队列
treeNode* deleteQ(Q* queue) {
    queueNode* p = queue->front->next;
    treeNode* q = p->Tnode;
    if (queue->front->next == queue->rear)queue->rear = NULL;
    queue->front->next = queue->front->next->next;
    free(p);
    return q;
}
```