```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct treenode_ {
	int value;
	struct treenode_* parent, * left, * right;
}treeNode;

treeNode* current = NULL;    //指向当前操作的节点
treeNode* last = NULL;    //指向pop之前的节点

treeNode* buildTree();
void treePush(treeNode** t);
void treePop();
void postorderTraversal(treeNode* tree);

int main_0() {
	treeNode* tree = buildTree();
	postorderTraversal(tree);
	return 0;
}

treeNode* buildTree() {
	int n;
	scanf("%d", &n);
	n *= 2;
	treeNode* tree = NULL;
	char input[10];
	while (n) {
		scanf("%s", input);
		if (!strcmp(input, "Push")) {
			treePush(&tree);
		}
		else if (!strcmp(input, "Pop")) {
			treePop();
		}
		n--;
	}
	return tree;
}

void treePush(treeNode** t) {
	treeNode* p = (treeNode*)malloc(sizeof(treeNode));
	scanf("%d", &(p->value));
	p->left = p->right = NULL;
	if (*t == NULL) {
		*t = p;
		p->parent = NULL;
	}
	else {
		if (last->left == NULL) {
			last->left = p;
			p->parent = last;
		}
		else if (last->right == NULL) {
			last->right = p;
			p->parent = last;
		}
		else if (current->left == NULL) {
			current->left = p;
			p->parent = current;
		}
		else if (current->right == NULL) {
			current->right = p;
			p->parent = current;
		}
	}
	current = last = p;
}

void treePop() {
	last = current;
	current = current->parent;
}

void postorderTraversal(treeNode* tree) {
	if (tree->left != NULL)postorderTraversal(tree->left);
	if (tree->right != NULL)postorderTraversal(tree->right);
	printf("%d", tree->value);
	if (tree->parent != NULL)printf(" ");
}
```