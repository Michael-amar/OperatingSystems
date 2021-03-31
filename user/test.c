#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/perf.h"

int main(int argc,char** argv)
{
    int primes[100];
    int primes_index = 0;
    struct perf perf;
    int flag = 0;
    int pid = fork();
    if (pid == 0)
    {
        for (int i=2; primes_index < 1500 ; i++)
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
            {
               primes[primes_index] = i;
               primes_index++;
            }
        }
        primes_index = primes[0];  //just so primes wont be unused variable 
    }
    else 
    {
        printf("%d pid of forked process:\n",pid);
        wait_stat(&pid,&perf);
        printf("ctime:%d\n",perf.ctime);
        printf("ttime:%d\n",perf.ttime);
        printf("stime:%d\n",perf.stime);
        printf("retime:%d\n",perf.retime);
        printf("rutime:%d\n",perf.rutime);
        printf("average_bursttime:%d\n",perf.average_brusttime);
        printf("num of bursts:%d\n",perf.num_of_bursts);
    }
    exit(0);
    return 0;
}