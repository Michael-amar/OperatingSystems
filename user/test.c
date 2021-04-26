#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"
#include "kernel/sigaction.h"
void test_sigprocmask1()
{
    uint a = sigprocmask(6);
    uint b = sigprocmask(7);
    if ((a == 0) && (b == 6))
    {
        printf("test_sigprocmask1:OK\n");
    }
    else{
        printf("test_sigprocmask1:FAIL\n");
        printf("a:%d , b:%d\n" , a,b);
    }
}

void test_sigprocmask2()
{
    uint a = sigaction(SIGKILL,0,0);
    uint b = sigaction(SIGSTOP,0,0);
    if ((a == -1) && (b == -1))
    {
        printf("test_sigprocmask2:OK\n");
    }
    else{
        printf("test_sigprocmask2:FAIL\n");
        printf("a:%d , b:%d\n" , a,b);
    }
}

void test_sigkill()
{
    //int pid = fork();

}
void test_sigaction()
{
    struct sigaction a;
    struct sigaction b;
    a.sa_handler = (void*) 1234;
    a.sigmask = 789;
    sigaction(6,&a,0);
    sigaction(6,0,&b);
    if(b.sa_handler == (void*) 1234 && b.sigmask == 789)
    {
      printf("test_sigaction:OK\n");
    }
    else{
        printf("test_sigaction:FAIL\n");
    }
}


int main()
{
    // test_sigprocmask1();
    // test_sigprocmask2();
    // test_sigaction();
    int pid = fork();
    if (pid == 0)
    {
        while(1)
        {
            sleep(20);
            printf("child\n");
        }
    }
    else{
        printf("child:%d\n",pid);
    }

    exit(0);
    return 0;
}