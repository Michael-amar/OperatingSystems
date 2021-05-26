#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main()
{
    printf("test\n");

    char* a =(char*) malloc(102400);
    a[0] = '3';
    for (int i=1; i<102400 ; i++)
         a[i] = '1';
    
    int pid = fork();
    if (pid == 0)
    {
        printf("child: %c\n",a[0]);
        ppages();
    }
    else {
        //printf("%c\n",a[0]);
    }
    exit(0);
    return 0;
}