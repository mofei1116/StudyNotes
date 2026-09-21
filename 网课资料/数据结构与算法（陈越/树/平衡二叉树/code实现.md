```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>

typedef struct treenode_ {
	int value;    //值
	int BF;    //平衡因子：左子树高度-右子树高度
	struct treenode_* left, * right;
}treeNode;

treeNode* finder, * p;    //发现者，发现者的父节点
//int tag;    //1表示发现者是其父节点的左儿子，2表示发现者是其父节点的右儿子

treeNode* insertNode(treeNode* tree, int value, treeNode* parent);
treeNode* solveProblem();
treeNode* LL();
treeNode* RR();
treeNode* LR();
treeNode* RL();
treeNode* buildAVLTree(int n);
void traversal(treeNode* t);
int getheight(treeNode* t);

int main() {
	int n;
	scanf("%d", &n);
	treeNode* tree = buildAVLTree(n);
	printf("%d\n", tree->value);
	return 0;
}

treeNode* insertNode(treeNode* tree,int value,treeNode* parent) {
	if (!tree) {
		tree = (treeNode*)malloc(sizeof(treeNode));
		tree->BF = 0;
		tree->left = tree->right = NULL;
		tree->value = value;
	}
	else {
		if (value < tree->value) {
			tree->BF++;
			if (tree->BF > 1) {
				finder = tree;
				p = parent;
			}
			tree->left = insertNode(tree->left, value,tree);
		}
		else if (value > tree->value) {
			tree->BF--;
			if (tree->BF < -1) {
				finder = tree;
				p = parent;
			}
			tree->right = insertNode(tree->right, value,tree);
		}
		else {
			printf("error\n"); return NULL;
		}
	}
	return tree;
}

treeNode* solveProblem() {
	if (finder->BF > 1) {
		if (finder->left->BF > 0)return LL();
		else if (finder->left->BF < 0)return LR();
	}
	else if (finder->BF < -1) {
		if (finder->right->BF < 0)return RR();
		else if (finder->right->BF > 0)return RL();
	}
}

treeNode* LL() {
	treeNode* mid, * a;
	mid = finder->left;
	a = mid->right;
	finder->left = a;
	mid->right = finder;
	//mid->BF = 0;
	return mid;
}

treeNode* RR() {
	treeNode* mid, * a;
	mid = finder->right;
	a = mid->left;
	finder->right = a;
	//finder->BF = 0;
	mid->left = finder;
	//mid->BF = 0;
	return mid;
}

treeNode* LR() {
	treeNode* mid, * a, * b, * problem;
	a = b = NULL;
	mid = finder->left;
	problem = mid->right;
	a = problem->right;
	b = problem->right;
	mid->right = a;
	finder->left = b;
	/*if (problem->BF == 1) {
		mid->BF = 0;
		finder->BF = -1;
	}
	else if (problem->BF == -1) {
		mid->BF = 1;
		finder->BF = 0;
	}*/
	problem->left = mid;
	problem->right = finder;
	//problem->BF = 0;
	return problem;
}

treeNode* RL() {
	treeNode* mid, * a, * b, * problem;
	mid = finder->right;
	problem = mid->left;
	a = problem->left;
	b = problem->right;
	finder->right = a;
	mid->left = b;
	/*if (problem->BF == 1) {
		finder->BF = 0;
		mid->BF = -1;
	}
	else if (problem->BF == -1) {
		finder->BF = 1;
		mid->BF = 0;
	}*/
	problem->left = finder;
	problem->right = mid;
	//problem->BF = 0;
	return problem;
}

treeNode* buildAVLTree(int n) {
	treeNode* tree = NULL;
	int value;
	while (n--) {
		finder = NULL;
		p = NULL;
		scanf("%d", &value);
		tree=insertNode(tree, value,NULL);
		if (finder != NULL) {
			if (!p)tree = solveProblem();
			else {
				if (p->left == finder) {
					p->left = solveProblem();
				}
				else if (p->right == finder) {
					p->right = solveProblem();
				}
			}
			traversal(tree);
		}
		//traversal(tree);
	}
	return tree;
}

void traversal(treeNode* t) {
	if (t) {
		int lH, rH;
		lH = getheight(t->left);
		rH = getheight(t->right);
		t->BF = lH - rH;
		traversal(t->left);
		traversal(t->right);
	}
}

int getheight(treeNode* t) {
	int lH, rH, maxH;
	if (t) {
		lH = getheight(t->left);
		rH = getheight(t->right);
		maxH = lH > rH ? lH : rH;
		return (maxH + 1);
	}
	else return 0;
}
```