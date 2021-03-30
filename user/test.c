#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/perf.h"

int main(int argc,char** argv)
{
    struct perf perf;
    int flag = 0;
    int pid = fork();
    if (pid == 0)
    {
        sleep(5);
        sleep(3);
        for (int i=2; i<100 ; i++)
        {
            flag = 0;
            for (int j=2 ; j <= i/2 ; ++j)
            {
                if (i%j == 0)
                {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0)
                printf("%d is prime number\n", i);
        }
    }
    else 
    {
        wait_stat(&pid,&perf);
        printf("ctime:%d\n",perf.ctime);
        printf("ttime:%d\n",perf.ttime);
        printf("stime:%d\n",perf.stime);
        printf("retime:%d\n",perf.retime);
        printf("rutime:%d\n",perf.rutime);
        printf("average_bursttime:%d\n",perf.average_brusttime);

    }
    exit(0);
    return 0;
}