#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/perf.h"

int main(int argc,char** argv)
{
    int flag = 0;
    int pid = fork();
    if (pid == 0)
    {
        printf("in child"); 
    }
    else 
    {
        while(1)
        {
            flag++;
        }
    }
    pid = flag;
    exit(0);
    return 0;
}