```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int preorder[35];
int inorder[35];
int postorder[35];

typedef struct stack_ {
	int* stackNodes;
	int tail;
	int capacity;
}stack;

void traversal(int n);
stack* createStack(int n);
void buildPostorder(int preL, int inL, int postL, int len);

int main() {
	int n;
	scanf("%d", &n);
	traversal(n);
	buildPostorder(0, 0, 0, n);
	int i;
	int isFirst = 1;
	for (i = 0; i < n; i++) {
		if (isFirst) {
			isFirst = 0;
		}
		else printf(" ");
		printf("%d", postorder[i]);
	}
	return 0;
}

void traversal(int n) {
	int i;
	char input[50];
	int value;
	stack* S = createStack(n);
	int preCnt = 0, inCnt = 0;
	for (i = 0; i < 2 * n; i++) {
		scanf("%s", input);
		if (strcmp(input, "Push") == 0) {
			scanf("%d", &value);
			S->stackNodes[++S->tail] = value;
			preorder[preCnt++] = value;
		}
		else if (strcmp(input, "Pop") == 0) {
			inorder[inCnt++]=S->stackNodes[S->tail--];
		}
	}
}

stack* createStack(int n) {
	stack* S = (stack*)malloc(sizeof(stack));
	S->stackNodes = (int*)malloc(sizeof(int) * n);
	S->tail = -1;
	S->capacity = n;
	return S;
}

void buildPostorder(int preL,int inL,int postL,int len) {
	if (!len)return;
	if (len == 1) { postorder[postL] = preorder[preL]; return; }
	int root = preorder[preL];
	postorder[postL + len - 1] = root;
	int i;
	for (i = 0; i < len; i++) {
		if (inorder[inL + i] == root)break;
	}
	int lenL = i, lenR = len - i - 1;
	buildPostorder(preL + 1, inL, postL, lenL);
	buildPostorder(preL + 1 + lenL, inL + lenL + 1, postL + lenL, lenR);
}
```