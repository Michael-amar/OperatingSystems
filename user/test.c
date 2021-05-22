#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main()
{
    ppages();
    malloc(1);
    ppages();
    exit(0);
    return 0;
}