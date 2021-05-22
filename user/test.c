#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main()
{
    printf("test\n");
    ppages();
    char* a =(char*) malloc(102400);
    for (int i=0; i<102400 ; i++)
        a[i] = '1';
    printf("%c\n",a[0]);
    ppages();
    exit(0);
    return 0;
}