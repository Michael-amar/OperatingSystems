#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"
#include "sigaction.h"
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

int wait_sig = 0;


void func(int signum)
{
    printf("test\n");
}


void func2(int signum)
{
    printf("got signal:%d\n" , signum);
    return;
}


void test_handler(int signum)
{
    wait_sig = 1;
    printf("Received sigtest\n");
}




int main()
{
    // test_sigprocmask1();
    // test_sigprocmask2();
    // test_sigaction();
    func(5);
    func2(2);
    int pid;
    int testsig;
    testsig=15;
    printf("test_handler:%p\nfunc:%d\nfunc2:%p\n",test_handler,func,func2);
    struct sigaction act = {test_handler, (uint)(1 << 29)};
    struct sigaction old;

    sigprocmask(0);
    sigaction(testsig, &act, &old);
    if((pid = fork()) == 0){
        while(!wait_sig)
            sleep(1);
        exit(0);
    }
    kill(pid, testsig);
    wait(&pid);
    printf("Finished testing signals\n");
    exit(0);
    return 1;
}