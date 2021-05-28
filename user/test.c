#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

void scfifo_test()
{
    printf("scfifo_test\n");

    // at the beginning of the test we have 3 user pages: stack, guard page, and text
    // we use sleep after each sbrk so pages wont be created with same time stamp
    sleep(2);
    int PGSIZE = 4096;
    char* page4  = sbrk(PGSIZE); sleep(1);
    char* page5  = sbrk(PGSIZE); sleep(1);
    char* page6  = sbrk(PGSIZE); sleep(1);
    char* page7  = sbrk(PGSIZE); sleep(1);
    char* page8  = sbrk(PGSIZE); sleep(1);
    char* page9  = sbrk(PGSIZE); sleep(1);
    char* page10 = sbrk(PGSIZE); sleep(1);
    char* page11 = sbrk(PGSIZE); sleep(1);
    char* page12 = sbrk(PGSIZE); sleep(1);
    char* page13 = sbrk(PGSIZE); sleep(1);
    char* page14 = sbrk(PGSIZE); sleep(1);
    char* page15 = sbrk(PGSIZE); sleep(1);
    char* page16 = sbrk(PGSIZE); sleep(1);

    // access all pages but page 13
    page4[1]  = '1'; page5[1]  = '1'; page6[1]  = '1'; page7[1] = '1';
    page8[1]  = '1'; page9[1]  = '1'; page10[1] = '1'; page11[1] = '1';
    page12[1] = '1'; page14[1] = '1'; page15[1] = '1'; page16[1] = '1';

    // this should swap out guard page because guard page and page13 are the only unaccesses pages and guard page came first
    char* page17 = sbrk(PGSIZE); sleep(1);
    page17[1] = '1';

    // this should swap out page 13
    char* page18 = sbrk(PGSIZE); sleep(1);
    page18[1] = '1';

    // this should cause page fault
    page13[1] = '1';
    
    // in trap.c there is a print of page fault address
    // we expect the va of the print in trap.c to be equal to page13
    printf("page13:%d\n",(long)page13);
}

void nfua_test()
{
   printf("nfua_test\n");
   int pid = fork();
   if(pid == 0)
   {//child
        while(1)
        {
            printf("");
        }
   }
   else
   {//parent
        int PGSIZE = 4096;
        char* page4  = sbrk(PGSIZE);
        char* page5  = sbrk(PGSIZE);
        char* page6  = sbrk(PGSIZE);
        char* page7  = sbrk(PGSIZE);
        char* page8  = sbrk(PGSIZE);
        char* page9  = sbrk(PGSIZE);
        char* page10 = sbrk(PGSIZE);
        char* page11 = sbrk(PGSIZE);
        char* page12 = sbrk(PGSIZE);
        char* page13 = sbrk(PGSIZE);
        char* page14 = sbrk(PGSIZE);
        char* page15 = sbrk(PGSIZE);
        char* page16 = sbrk(PGSIZE);

        // access all pages but pages 13,14
        page4[1]  = '1'; page5[1]  = '1'; page6[1]  = '1'; page7[1] = '1';
        page8[1]  = '1'; page9[1]  = '1'; page10[1] = '1'; page11[1] = '1';
        page12[1] = '1'; page15[1] = '1'; page16[1] = '1';
        sleep(3);

        // access all pages but pages 13
        page4[1]  = '1'; page5[1]  = '1'; page6[1]  = '1'; page7[1] = '1';
        page8[1]  = '1'; page9[1]  = '1'; page10[1] = '1'; page11[1] = '1';
        page12[1] = '1'; page14[1] = '1'; page15[1] = '1'; page16[1] = '1';
        sleep(3);

        // this should swap out guard page because it wasnt accessed at all
        char* page17 = sbrk(PGSIZE); 
        page17[1] = '1';
        sleep(3);

        // this should swap out page 13 becuase its counter is the smallest
        char* page18 = sbrk(PGSIZE); sleep(1);
        page18[1] = '1';

        // this should cause page fault
        page13[1] = '1';
        
        // in trap.c there is a print of page fault address
        // we expect the va of the print in trap.c to be equal to page13
        // the sleeps in this test is to let the proccess yield and the counters to be updated
        printf("page13:%d\n",(long)page13);
   }

}

void lapa_test()
{
   printf("lapa_test\n");
   int pid = fork();
   if(pid == 0)
   {//child
        while(1)
        {
            printf("");
        }
   }
   else
   {//parent
        int PGSIZE = 4096;
        char* page4  = sbrk(PGSIZE);
        char* page5  = sbrk(PGSIZE);
        char* page6  = sbrk(PGSIZE);
        char* page7  = sbrk(PGSIZE);
        char* page8  = sbrk(PGSIZE);
        char* page9  = sbrk(PGSIZE);
        char* page10 = sbrk(PGSIZE);
        char* page11 = sbrk(PGSIZE);
        char* page12 = sbrk(PGSIZE);
        char* page13 = sbrk(PGSIZE);
        char* page14 = sbrk(PGSIZE);
        char* page15 = sbrk(PGSIZE);
        char* page16 = sbrk(PGSIZE);

        // access all pages but page 14
        page4[1]  = '1'; page5[1]  = '1'; page6[1]  = '1'; page7[1] = '1';
        page8[1]  = '1'; page9[1]  = '1'; page10[1] = '1'; page11[1] = '1';
        page12[1] = '1'; page13[1] = '1'; page15[1] = '1'; page16[1] = '1';
        sleep(3);

        // access all pages but page 14
        page4[1]  = '1'; page5[1]  = '1'; page6[1]  = '1'; page7[1] = '1';
        page8[1]  = '1'; page9[1]  = '1'; page10[1] = '1'; page11[1] = '1';
        page12[1] = '1'; page13[1] = '1'; page15[1] = '1'; page16[1] = '1';
        sleep(3);

        // access all pages but page 13
        page4[1]  = '1'; page5[1]  = '1'; page6[1]  = '1'; page7[1] = '1';
        page8[1]  = '1'; page9[1]  = '1'; page10[1] = '1'; page11[1] = '1';
        page12[1] = '1'; page14[1] = '1'; page15[1] = '1'; page16[1] = '1';
        sleep(3);

        // access all pages but page 13
        page4[1]  = '1'; page5[1]  = '1'; page6[1]  = '1'; page7[1] = '1';
        page8[1]  = '1'; page9[1]  = '1'; page10[1] = '1'; page11[1] = '1';
        page12[1] = '1'; page14[1] = '1'; page15[1] = '1'; page16[1] = '1';
        sleep(3);



        // this should swap out guard page because it wasnt accessed at all
        char* page17 = sbrk(PGSIZE); 
        page17[1] = '1';
        sleep(3);

        //page 13 and 14 have same number of 1's but page13 counter is smaller
        // because 14 was accessed after so page 13 needs to be swapped out
        char* page18 = sbrk(PGSIZE); sleep(1);
        page18[1] = '1';

        // this should cause page fault
        page13[1] = '1';
        
        // in trap.c there is a print of page fault address
        // we expect the va of the print in trap.c to be equal to page13
        // the sleeps in this test is to let the proccess yield and the counters to be updated
        printf("page13:%d\n",(long)page13);
   }

}

int main()
{
    //scfifo_test();
    //nfua_test();
    //lapa_test();
    ppages();
    exit(0);
    return 0;
}