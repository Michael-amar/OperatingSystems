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
        printf("first child\n");
        for (int i=0; i<50000 ; i++)
        {
            for (int j=0 ; j<40000 ; j++)
            {
                flag+= (i + j)/2;
            }
        }
        sleep(3);
    }
    else 
    {
        if (fork() == 0 )
        {
            printf("second child\n");
        }
        else
        {
            if (fork() == 0)
            {
                printf("third child\n");
            }
            else
            {
                printf("father\n");
                sleep(1);
                printf("father\n");
            }
        }
    }
    pid = flag;
    exit(0);
    return 0;
}
//run command: make clean qemu SCHEDFLAG=FCFS CPUS=1
//this test is for fcfs scheduling policy!
//the output should be:
// father
// first child
// father
// second child
// third child
