```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

typedef struct charfre_ {
	char ch;
	int frequency;
}charFre;

typedef struct charcode_ {
	char ch;
	char code[70];
	int codeLength;
}charCode;

typedef struct huffmantreenode_ {
	int weight;
	struct huffmantreenode_* left, * right;
}HuffmanNode;

typedef struct minheap_ {
	HuffmanNode* heap;
	int size;
}minHeap;

int n, m;
int BPL;

charFre* getCharFre();
void getBPL(charFre* chF);
HuffmanNode* buildHuffamTree(charFre* chF);
minHeap* buildHeap(charFre* chF);
void insertHeap(minHeap* H, HuffmanNode p);
HuffmanNode* deleteHeap(minHeap* H);
void processSubmissions(charFre chF[]);
void getCharCode(charCode chC[]);
bool checkPrefixCode(charCode chC[]);
void preorderTraversal(int* BPL, HuffmanNode* tree);
bool checkBPL(charCode chC[], charFre chF[]);

int main() {
	charFre* chF=getCharFre();
	getBPL(chF);
	processSubmissions(chF);
	return 0;
}

charFre* getCharFre() {
	scanf("%d", &n);
	charFre* chF = (charFre*)malloc(sizeof(charFre) * n);
	int i;
	for (i = 0; i < n; i++) {
		getchar();
		//scanf("%c %d", &(chF[i].ch), &(chF[i].frequency));
		scanf("%c", &(chF[i].ch));
		scanf("%d", &(chF[i].frequency));
	}
	return chF;
}

void getBPL(charFre* chF) {
	BPL = 0;
	HuffmanNode* tree = buildHuffamTree(chF);
	preorderTraversal(&BPL, tree);
}

void preorderTraversal(int* BPL,HuffmanNode* tree) {
	static int cnt = 0;
	cnt++;
	if (tree == NULL) { cnt--; return; }
	if (tree->left == NULL && tree->right == NULL) {
		*BPL += (cnt - 1) * tree->weight;
	}
	preorderTraversal(BPL, tree->left);
	preorderTraversal(BPL, tree->right);
	cnt--; return;
}

HuffmanNode* buildHuffamTree(charFre* chF) {
	minHeap* H = buildHeap(chF);
	HuffmanNode* T = NULL;
	//for (int j = 1; j <= H->size; j++) {    //检查最小堆
	//	printf("%d ", H->heap[j].weight);
	//}
	//printf("\n");
	for (int i = 1; i < n; i++) {
		T = (HuffmanNode*)malloc(sizeof(HuffmanNode));
		T->left = deleteHeap(H);
		T->right = deleteHeap(H);
		T->weight = T->left->weight + T->right->weight;
		insertHeap(H, *T);
	}
	free(H);
	return T;
}

minHeap* buildHeap(charFre* chF) {
	minHeap* H = (minHeap*)malloc(sizeof(minHeap));
	HuffmanNode* heap = (HuffmanNode*)malloc(sizeof(HuffmanNode) * (n + 1));
	H->heap = heap;
	H->size = 0;
	int i;
	for (i = 0; i < n + 1; i++) {
		H->heap[i].left = H->heap[i].right = NULL;
	}
	H->heap[0].weight = -1;
	for (int i = 0; i < n; i++) {
		HuffmanNode p;
		p.weight = chF[i].frequency;
		p.left = p.right = NULL;
		insertHeap(H, p);
	}
	return H;
}

void insertHeap(minHeap* H, HuffmanNode p) {
	int i = ++H->size;
	for (; H->heap[i / 2].weight > p.weight; i /= 2) {
		H->heap[i] = H->heap[i / 2];
	}
	H->heap[i] = p;
}

HuffmanNode* deleteHeap(minHeap* H) {
	HuffmanNode* p = (HuffmanNode*)malloc(sizeof(HuffmanNode));
	*p = H->heap[1];
	HuffmanNode temp = H->heap[H->size--];
	int parent, child;
	for (parent = 1; parent * 2 <= H->size; parent = child) {
		child = parent * 2;
		if (child<H->size && H->heap[child].weight>H->heap[child + 1].weight)
			child++;
		if (temp.weight > H->heap[child].weight)
			H->heap[parent] = H->heap[child];
		else break;
	}
	H->heap[parent] = temp;
	return p;
}

void processSubmissions(charFre chF[]) {
	scanf("%d", &m);
	charCode* chC = (charCode*)malloc(sizeof(charCode) * n);
	while (m) {
		getCharCode(chC);
		if (checkBPL(chC, chF)&& checkPrefixCode(chC)) {
			printf("Yes\n");
		}
		else printf("No\n");
		m--;
	}
	free(chC);
}

void getCharCode(charCode chC[]) {
	int i;
	for (i = 0; i < n; i++) {
		getchar();
		scanf("%c %s", &(chC[i].ch), &(chC[i].code));
		chC[i].codeLength = strlen(chC[i].code);
	}
}

bool checkBPL(charCode chC[],charFre chF[]) {
	int thisPL = 0;
	for (int i = 0; i < n; i++) {
		thisPL += chC[i].codeLength * chF[i].frequency;
	}
	return (BPL == thisPL);
}

bool checkPrefixCode(charCode chC[]) {
	int i, j;
	bool ret = 1;
	for (i = 0; i < n; i++) {
		for (j = i + 1; j < n; j++) {
			int a = (chC[i].codeLength < chC[j].codeLength) ? chC[i].codeLength : chC[j].codeLength;
			if (strncmp(chC[i].code, chC[j].code, a) == 0)ret = 0;
		}
	}
	return ret;
}
```