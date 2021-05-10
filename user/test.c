#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"
#include "sigaction.h"
#include "Csemaphore.h"

struct counting_semaphore* sem;

void func1()
{
  for (int i=0 ;i<100; i++)
  {
    printf("thread1 func %d\n",i);
  }
  sleep(10);
  kthread_exit(22);
}




int main()
{
    sem = malloc(sizeof(struct counting_semaphore));
    csem_alloc(sem,2);
    void* stack1 = malloc(STACK_SIZE);
    int tid =  kthread_create(func1,stack1);
    // printf("hello");
    int status;
    kthread_join(tid,&status);
    printf("thread status:%d\n",status);
    kthread_exit(1);
    return 0;
}