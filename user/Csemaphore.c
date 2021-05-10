#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "Csemaphore.h"

int csem_alloc(struct counting_semaphore* sem, int initial_value)
{
    printf("csem alloc\n");
    if (initial_value < 0)
        return -1;
    int s1 = bsem_alloc();
    int s2 = bsem_alloc();

    sem->s1 = s1;
    sem->s2 = s2;
    sem->value = initial_value;

    if (initial_value == 0)
        bsem_down(s2);

    return 0;

}

void csem_free(struct counting_semaphore* sem)
{
    printf("csem free\n");
    bsem_free(sem->s1);
    bsem_free(sem->s2);
}


void csem_down(struct counting_semaphore* sem)
{
    printf("csem down\n");
    bsem_down(sem->s2);
    bsem_down(sem->s1);
    sem->value = (sem->value)-1;
    if(sem->value > 0)
    {
        printf("csem down:line 42\n");
        bsem_up(sem->s2);
    }
    bsem_up(sem->s1);
}

void csem_up(struct counting_semaphore* sem)
{
    printf("csem up\n");
    bsem_down(sem->s1);
    sem->value++;
    if(sem->value == 1)
    {
        bsem_up(sem->s2);
    }
    bsem_up(sem->s1);
}