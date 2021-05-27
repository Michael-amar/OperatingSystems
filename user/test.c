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
    // allocate 2 user pages
    char* a = malloc(8092);
    
    // only access first page
    for(int i=0 ; i<4096; i++)
        a[i] = '1';
    sleep(3);
    printf("a[500]:%d\n",a[500]);
    sleep(3);
    printf("a[600]:%d\n", a[600]);
    printf("a[5000]:%d\n",a[5000]);
    // expect the second page ->NFUA_counter to be only 0's
    ppages();
}

int main()
{
    printf("hello");
    nfua_test();
    exit(0);
    return 0;
}