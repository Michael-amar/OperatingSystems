#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"
#include "sigaction.h"
#include "Csemaphore.h"

void func1(struct counting_semaphore* sem)
{
  csem_down(sem);
  for (int i=0 ; i<20 ; i++)
  {
    printf("---func1---%d\n", i);
  }
  sleep(10);
  csem_up(sem);
}

void func2(struct counting_semaphore* sem)
{
  csem_down(sem);
  for(int i = 0; i < 20; i++)
  {
    printf("****func2****%d\n",i);
  }
  sleep(10);
  csem_up(sem);
}

void func3(struct counting_semaphore* sem)
{
  csem_down(sem);
  for(int i = 0; i < 20; i++)
  {
      printf("^^^^func3^^^^%d\n",i);
  }  
  sleep(10);
  csem_up(sem);
}

void func4(struct counting_semaphore* sem)
{
  csem_down(sem);
  for(int i = 0; i < 100; i++)
  {
      printf("###func4###\n");
  }  
  csem_up(sem);
}

void func5(struct counting_semaphore* sem)
{
  csem_down(sem);
  for(int i = 0; i < 10; i++)
  {
      printf("&&&func5&&&\n");
  }  
  csem_up(sem);
}

int main()
{
    struct counting_semaphore sem;
    csem_alloc(&sem,2);
    int pid = fork();
    if(pid == 0)
    {
      //child
      func1(&sem);
    }
    else 
    {
      int pid2 = fork();
      if (pid2 == 0)
      {
        //child2
        func3(&sem);
      }
      else
      {
        //parent
        func2(&sem);
        int status;
        wait(&status);
      }
      
    } 
    exit(1);
}