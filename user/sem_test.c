#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"

void func1(int s1)
{
    bsem_down(s1);
    for(int i=0 ; i<20 ; i++)
    {
        printf("func1\n");
    }
    bsem_up(s1);
}   

void func2(int s1)
{
    bsem_down(s1);
    for(int i=0 ; i<20 ; i++)
    {
        printf("------------func2------------- \n");
    }
    bsem_up(s1);
}

int main(){
    int s1 = bsem_alloc();
    if (s1 < 0 )
    {
        printf("bsem_alloc failed\n");
    }

    int pid = fork();

    if(pid == 0)
    {
        //child
        func1(s1);
    }
    else
    {
        //parent
        func2(s1);
    }
    exit(0);
}