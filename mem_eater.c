#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MB 10485760

int main()
{
	void	*s = NULL;
	int		c = 0;

	while (1)
	{
		if (!(s = (void*)malloc(MB)))
			break;
		memset(s, 10, MB);
		printf("Allocating %d MB\n", (++c * 10));
	}
	exit (0);
}