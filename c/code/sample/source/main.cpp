#include <stdio.h>
#include <stdlib.h>

#include "header.h"

int main(int argc, char *argv[])
{
	int a, b;
	a = 1; 
	b = 2;
	printf("%d\n", add(a,b));
	printf("%d\n", minus(a,b));
	return 0;
}
