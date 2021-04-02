#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/perf.h"

void long_time_method()
{
    printf("long time method\n");
    int counter;
    for (int i=0 ; i<3000 ; i++)
    {
        for (int j=0 ; j<50000 ; j++)
        {
            counter+= (i+j)/2+(j*i);
        }
    }
}

int main(int argc, char** argv)
{
    long_time_method();
    set_priority(5);
    int pid = fork();
    if(!pid)
    {
        set_priority(3);
        long_time_method();

        if(!fork())
        {
            long_time_method();
            set_priority(1);
            sleep(2);
            printf("second_child\n");
        }
        else
        {
            sleep(2);
            printf("first_child\n");
            long_time_method();
        }
    }
    else
    {
        sleep(2);
        printf("father\n");
        // struct perf perf;
        // wait_stat(&pid,&perf);
        // printf("ctime:%d\n",perf.ctime);
        // printf("ttime:%d\n",perf.ttime);
        // printf("stime:%d\n",perf.stime);
        // printf("retime:%d\n",perf.retime);
        // printf("rutime:%d\n",perf.rutime);
    }
    
    exit(0);
    return 1;

}
