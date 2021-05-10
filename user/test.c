#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"
#include "sigaction.h"
#include "Csemaphore.h"


struct counting_semaphore* sem;

void func1()
{
  printf("func1\n");
  csem_down(sem);
  for (int i=0 ; i<20 ; i++)
  {
    printf("---func1---%d\n", i);
  }
  sleep(10);
  csem_up(sem);
}

void func2()
{
  printf("func2\n");
  csem_down(sem);
  for(int i = 0; i < 20; i++)
  {
    printf("****func2****%d\n",i);
  }
  sleep(10);
  csem_up(sem);
}

void func3()
{
  printf("func3\n");
  csem_down(sem);
  for(int i = 0; i < 20; i++)
  {
      printf("^^^^func3^^^^%d\n",i);
  }  
  sleep(10);
  csem_up(sem);
}


int main()
{
    sem = malloc(sizeof(struct counting_semaphore));
    csem_alloc(sem,2);

    void* stack1 = malloc(STACK_SIZE);
    // void* stack2 = malloc(STACK_SIZE);
    // void* stack3 = malloc(STACK_SIZE);
    kthread_create(func1,stack1);
    // kthread_create(func2,stack2);
    // kthread_create(func3,stack3);
    exit(1);
}