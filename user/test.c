#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main()
{

    printf("test\n");

    char* a =(char*) malloc(102400);
    printf("malloc returned:%p\n",a);
    for (int i=0; i<102400 ; i++)
         a[i] = '1';
    printf("%d",a[0]);
    exit(0);
    return 0;
}