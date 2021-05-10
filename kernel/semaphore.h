enum semaphore_state{
    UNUSED_SEM,
    USED_SEM
};

struct semaphore {
    enum semaphore_state state;
    void *chan;                  // If non-zero, sleeping on chan
    int taken;
    struct spinlock lk;
};
