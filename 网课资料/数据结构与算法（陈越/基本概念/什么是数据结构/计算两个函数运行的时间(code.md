```
#include <stdio.h>
#include <math.h>
#include <time.h>
#define MAXN 10//多项式最大项数，即最大阶数+1
#define MAXK 1e8//函数重复跑的次数

//n为阶数，a[]为x的系数数组，x为自变量
double f1(int n, double a[], double x) {
	int i;
	double p = a[0];
	for (i = 1; i <= n; i++) {
		//pow()函数为求x的i次方
		p += (a[i] * pow(x, i));
		return p;
	}
}

//n为阶数，a[]为x的系数数组，x为自变量
double f2(int n, double a[], double x) {
	int i;
	double p = a[n];
	for (i = n; i > 0; i--) {
		p = a[i - 1] + p * x;
	}
	return p;
}

int main(int argc, char* argv[])
{
	//构造多项式的系数的数组
	int i;
	double a[MAXN];
	for (i = 0; i < MAXN; i++) {
		a[i] = (double)i;
	}
	//给定一个x
	double x = 1.1;
	//----计算f1的时间
	clock_t start = clock();
	for (i = 0; i < MAXK; i++) {
		f1(MAXN - 1, a, x);
	}
	clock_t stop = clock();
	double duration = ((double)(stop - start)) / CLOCKS_PER_SEC;
	printf("ticks1=%f\n", (double)(stop - start));
	printf("duration1=%f\n", duration);
	//----计算f1的时间
	//----计算f2的时间
	start = clock();
	for (i = 0; i < MAXK; i++) {
		f1(MAXN - 1, a, x);
	}
	stop = clock();
	duration = ((double)(stop - start)) / CLK_TCK;
	printf("ticks2=%f\n", (double)(stop - start));
	printf("duration2=%f\n", duration);
	//----计算f2的时间
	return 0;
}
```