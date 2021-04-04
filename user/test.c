#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/perf.h"

int main(int argc, char** argv)
{
    int xst;
  
  for(int i = 0; i < 100; i++)
  {
    printf("fork in main\n");
    int pid1 = fork();
    if(pid1 < 0){
      printf("fork failed\n");
      exit(1);
    }
    if(pid1 == 0){
      while(1) {
        getpid();
      }
      exit(0);
    }
    printf("father after if\n");
    sleep(1);
    printf("father after sleep\n");
    kill(pid1);
    printf("father after kill\n");
    wait(&xst);
    printf("father after wait\n");
    if(xst != -1) {
       printf("status should be -1\n");
       exit(1);
    }
  }
  exit(0);
}