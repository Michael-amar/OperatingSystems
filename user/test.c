#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

void scfifo_test()
{
    // alocate 13 user pages
    char* a = malloc(13*4096);
    printf("allocated va : %d\n" ,a);
    // access pages 0-11
    for (int i = 0 ; i < 13*4096 ; i++)
        a[i] = '1';

    for (int i = 0 ; i < 13*4096 ; i++)
        a[i] = '1';

    // print pages - one of the pages 0-11 should be pages out
}

void nfua_test()
{
    fork();
    fork();
    printf("hello");
    // allocate 2 user pages
    char* a = malloc(56000);
    
    // only access first page
    for(int i=0 ; i<56000; i++)
        a[i] = '1';
    sleep(3);
    // expect the second page ->NFUA_counter to be only 0's
    //ppages();
}

int main()
{
    printf("hello");
    nfua_test();
    exit(0);
    return 0;
}