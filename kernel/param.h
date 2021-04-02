#define NPROC        64  // maximum number of processes
#define NCPU          8  // maximum number of CPUs
#define NOFILE       16  // open files per process
#define NFILE       100  // open files per system
#define NINODE       50  // maximum number of active i-nodes
#define NDEV         10  // maximum major device number
#define ROOTDEV       1  // device number of file system root disk
#define MAXARG       32  // max exec arguments
#define MAXOPBLOCKS  10  // max # of blocks any FS op writes
#define LOGSIZE      (MAXOPBLOCKS*3)  // max data blocks in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
#define FSSIZE       1000  // size of file system in blocks
#define MAXPATH      128   // maximum file path name
#define QUANTUM      1     // ticks between swapping process.
#define DEFAULT      1
#define FCFS         2
#define SRT          3
#define CFSD         4
#define ALPHA        50

#define TEST_HIGH    1
#define HIGH         2
#define NORMAL       3
#define LOW          4
#define TEST_LOW     5

#define TEST_HIGH_DECAY     1
#define HIGH_DECAY          3
#define NORMAL_DECAY        5
#define LOW_DECAY           7
#define TEST_LOW_DECAY      25
