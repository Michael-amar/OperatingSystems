#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"
#include "sigaction.h"
#include "Csemaphore.h"

struct counting_semaphore* sem;

void func1()
{
  csem_down(sem);
  for (int i=0 ;i<100; i++)
  {
    printf("thread1 func\n");
  }
  csem_up(sem);
  while(1);
  exit(1);
}

void func2()
{
  csem_down(sem);
  for (int i=0 ;i<100; i++)
  {
    printf("thread2 func\n");
  }
  csem_up(sem);
  while(1);
  exit(1);
}

void func3()
{
  csem_down(sem);
  for (int i=0 ;i<100; i++)
  {
    printf("thread3 func\n");
  }
  csem_up(sem);
  while(1);
  exit(1);
}


int main()
{
    sem = malloc(sizeof(struct counting_semaphore));
    csem_alloc(sem,2);
    void* stack1 = malloc(STACK_SIZE);
    void* stack2 = malloc(STACK_SIZE);
    void* stack3 = malloc(STACK_SIZE);
    kthread_create(func1,stack1);
    kthread_create(func2,stack2);
    kthread_create(func3,stack3);
    while(1)
    {
      sleep(150);
    }
    exit(1);
}