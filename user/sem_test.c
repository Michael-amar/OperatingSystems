#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"

void func1(int s1, int s2){
//    printf("1 ");
//    bsem_up(s1);
//    bsem_down(s1);
//    printf("4 ");
//    printf("5 ");
//    bsem_up(s1);
      bsem_down(s1);
      printf("woke up\n");
}

void func2(int s1, int s2){
    // bsem_down(s1);
    // printf("2 ");
    // printf("3 ");
    // bsem_down(s1);
    // printf("6 ");
    printf("func2\n");
}

int main(){
    int s1 = bsem_alloc();
    int s2 = bsem_alloc();
    bsem_down(s1);
    bsem_down(s2);
    // printf("S1: %d S2: %d\n", s1, s2);

    if (s1 < 0 || s2 < 0){
        printf("bsem_alloc failed\n");
    }

    int pid = fork();

    if(pid == 0){
        func1(s1, s2);
    }
    else{
        func2(s1, s2);
        //printf("need to print: 1 5 8 9 2 3 6 7 4\n");
    }
    exit(0);
}