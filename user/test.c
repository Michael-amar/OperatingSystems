#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"
#include "sigaction.h"

// concurrent forks to try to expose locking bugs.
void
forkfork(char *s)
{
  enum { N=2 };
  
  for(int i = 0; i < N; i++){
    int pid = fork();
    if(pid < 0){
      printf("%s: fork failed", s);
      exit(1);
    }
    if(pid == 0){
      for(int j = 0; j < 200; j++){
        int pid1 = fork();
        if(pid1 < 0){
          exit(1);
        }
        if(pid1 == 0){
          exit(0);
        }
        wait(0);
      }
      exit(0);
    }
  }

  int xstatus;
  for(int i = 0; i < N; i++){
    wait(&xstatus);
    if(xstatus != 0) {
      printf("%s: fork in child failed", s);
      exit(1);
    }
  }
}

void
sbrkbugs(char *s)
{
  int pid = fork();
  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
    int sz = (uint64) sbrk(0);
    // free all user memory; there used to be a bug that
    // would not adjust p->sz correctly in this case,
    // causing exit() to panic.
    sbrk(-sz);
    // user page fault here.
    exit(0);
  }
  wait(0);

  pid = fork();
  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
    int sz = (uint64) sbrk(0);
    // set the break to somewhere in the very first
    // page; there used to be a bug that would incorrectly
    // free the first page.
    sbrk(-(sz - 3500));
    exit(0);
  }
  wait(0);

  pid = fork();
  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
    // set the break in the middle of a page.
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));

    // reduce the break a bit, but not enough to
    // cause a page to be freed. this used to cause
    // a panic.
    sbrk(-10);

    exit(0);
  }
  wait(0);

  exit(0);
}

void tfunc()
{
  printf("thread func\n");  
}

int main()
{

    //forkfork("");
    void* stack = malloc(STACK_SIZE);
    kthread_create(&tfunc,stack);
    sleep(10);
    exit(1);
}