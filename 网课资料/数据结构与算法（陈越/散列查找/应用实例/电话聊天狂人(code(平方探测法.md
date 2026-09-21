```
#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <stdlib.h>
#define MaxN 200000
#define getHash(a) (int)((a)%H->tableSize)

typedef struct hashcell_ {
	long long phoneN;
	int count;    //通话次数
	//int info;    //该题没有删除操作
}hashCell;

typedef struct hashtable_ {
	hashCell* table;
	int tableSize;
}hashTable;

hashTable* initTable() {
	hashTable* H = (hashTable*)malloc(sizeof(hashTable));
	if (!H) {
		printf("lack of space!\n");
		exit(0);
	}
	H->tableSize = getTableSize();
	hashCell* table = (hashCell*)malloc(sizeof(hashCell) * H->tableSize);
	for (int i = 0; i < H->tableSize; i++) {    //初始化
		table[i].phoneN = -1;
	}
	H->table = table;
	return H;
}

int getTableSize() {
	int tableSize = MaxN;
	while (1) {
		tableSize++;
		if (isPrime(tableSize)) {
			if ((tableSize - 3) % 4 == 0)break;
		}
	}
	return tableSize;
}

int isPrime(int a) {
	int i;
	int ret = 1;
	for (i = 3; i * i <= a; i += 2) {
		if (a % i == 0) {
			ret = 0;
			break;
		}
	}
	return ret;
}

int findHashTable(long long key, hashTable* H) {
	int position = getHash(key);
	int Cnum = 0;    //记录冲突次数
	while (H->table[position].phoneN != -1 && H->table[position].phoneN != key) {
		Cnum++;
		if (Cnum % 2) {    //奇数次冲突
			position += (Cnum + 1) / 2 * (Cnum + 1) / 2;
		}
		else position -= Cnum / 2 * Cnum / 2;    //偶数次冲突
		if (position >= H->tableSize)position %= H->tableSize;
		while (position < 0) {
			position += H->tableSize;
		}
	}
	//printf("position:%d\n", position);   //debug
	return position;
}

void findNuts(hashTable* H) {
	int i, maxCnt = 0, nutsCnt = 1;
	long long K = 0;
	for (i = 0; i < H->tableSize; i++) {
		if (H->table[i].phoneN != -1) {
			if (maxCnt < H->table[i].count) {
				maxCnt = H->table[i].count;
				K = H->table[i].phoneN;
				nutsCnt = 1;
			}
			else if (maxCnt == H->table[i].count) {
				nutsCnt++;
				if (H->table[i].phoneN < K)K = H->table[i].phoneN;
			}
		}
		
	}
	printf("%lld %d", K, maxCnt);
	if (nutsCnt > 1)printf(" %d", nutsCnt);
}

void freeHashTable(hashTable* H) {
	free(H->table);
	free(H);
}

int main() {
	int n, i;
	long long key;
	scanf("%d", &n);
	hashTable* H = initTable();
	int position;
	for (i = 0; i < 2 * n; i++) {
		scanf("%lld", &key);
		position = findHashTable(key, H);
		if (H->table[position].phoneN != -1)H->table[position].count++;    //找到key
		else {    //未找到key
			H->table[position].count = 1;
			H->table[position].phoneN = key;
		}
	}
	findNuts(H);
	freeHashTable(H);
	return 0;
}
```