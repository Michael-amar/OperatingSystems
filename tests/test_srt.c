#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/perf.h"

void long_method()
{
    printf("in long method\n");
    int counter = 0;
    for (int i=0; i<25000 ; i++)
    {
        for (int j=1 ; j<50000 ; j++)
        {
            counter += ((i+j)/2)*(j+i);
        }
    }
}

void longer_method()
{
    printf("in longer method\n");
    int counter = 0;
    for (int i=0; i<50000 ; i++)
    {
        for (int j=1 ; j<50000 ; j++)
        {
            counter += ((i+j)/2)*(j+i);
        }
    }
}

int main(int argc, char** argv)
{
    // int pid = fork();
    // if (pid == 0)
    // {
    //     long_method();
    // }
    // else
    // {
    //     struct perf perf;
    //     wait_stat(&pid,&perf);
    //     printf("burst: %d\n",perf.average_brusttime);
    // }
    long_method();
    if(!fork()){
        printf("first child\n");
        if(!fork())
        {
            printf("second child\n");
        }
        else
        {
            longer_method();
            sleep(1);
            printf("first child\n");
        }
    }
    else
    {
        sleep(1);
        printf("father\n");
    }
   
    exit(1);
    return 1;

}
// first
// second
// father
// first