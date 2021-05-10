#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "user/sigaction.h"
#include "semaphore.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];


struct semaphore semaphores[MAX_BSEM];
struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;


extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;


//----------------------------threads------------------------------------
int nexttid = 1;
struct spinlock tid_lock;

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freethread(struct thread *t)
{
  if(t->tf_backup)
    kfree((void*)t->tf_backup);
  t->tid = 0;
  t->parent = 0;
  t->chan = 0;
  t->killed = 0;
  t->xstate = 0;
  t->state = UNUSED;
}

int
alloctid() {
  int tid;
  
  acquire(&tid_lock);
  tid = nexttid;
  nexttid = nexttid + 1;
  release(&tid_lock);

  return tid;
}


// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct thread*
allocthread(struct proc* p)
{
  struct thread *t;
  int index = 0;
  for(t = p->threads; t < &p->threads[NTHREAD]; t++) 
  {
    acquire(&t->lock);
    if(t->state == UNUSED) 
    {
      goto found;
    } 
    if(t->state == ZOMBIE)
    {
      freethread(t);
    }
    else 
    {
      release(&t->lock);
    }
    index++;
  }
  return 0;

found:
  t->tid = alloctid();
  t->state = USED;
  t->parent = p;

  t->trapframe = &(p->trapframes[index]);
  if((t->tf_backup = (struct trapframe *)kalloc()) == 0){
    freethread(t);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&t->context, 0, sizeof(t->context));
  t->context.sp = t->kstack + PGSIZE;
  t->context.ra = (uint64)forkret;

  return t;
}

void
exit_thread(int status)
{

  struct thread *t = mythread();
  struct proc* p = t->parent;

  acquire(&p->lock);
  p->alive_threads--;
  int alive_threads = p->alive_threads;
  release(&p->lock);

  acquire(&wait_lock);
  acquire(&t->lock);

  t->xstate = status;
  t->state = ZOMBIE;

  if (alive_threads == 0)
  {
    printf("killed proccess\n");
    // Close all open files.
    for(int fd = 0; fd < NOFILE; fd++){
      if(p->ofile[fd]){
        struct file *f = p->ofile[fd];
        fileclose(f);
        p->ofile[fd] = 0;
      }
    }

    begin_op();
    iput(p->cwd);
    end_op();
    p->cwd = 0;

    p->state = ZOMBIE_P;
    p->killed = 1;
  }
  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Return the current struct proc *, or zero if none.
struct thread*
mythread(void) {
  push_off();
  struct cpu *c = mycpu();
  struct thread *t = c->thread;
  pop_off();
  return t;
}


//-----------------------------------------end threads------------------------------------

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) 
{
  struct proc *p;
  struct thread* t;
  for(p = proc; p < &proc[NPROC]; p++) 
  {
    for (t =p->threads; t<&p->threads[NTHREAD] ; t++)
    {
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      uint64 va = KSTACK((((int) (p - proc))*8) + ((int) (t-p->threads)));
      // uint64 va = KSTACK2(((int) (p - proc)), ((int) (t-p->threads)));
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    }
  }
}

// initialize the proc table at boot time.
void
procinit(void)
{
  struct proc *p;
  struct thread* t;

  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) 
  {
      initlock(&p->lock, "proc");
      for( t = p->threads ; t < &p->threads[NTHREAD] ; t++)
      {
        initlock(&t->lock, "thread");
        t->kstack = KSTACK((int) (((p - proc)*8)+(((int) (t-p->threads)))));
        // t->kstack = KSTACK2(((int) (p - proc)), ((int) (t-p->threads)));
      }
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->thread->parent;
  pop_off();
  return p;
}

int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}




// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  struct thread* t;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED_P) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED_P;
  
  
  // Allocate a trapframes page.
  if((p->trapframes = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.

  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  //-----------------our additions----------------
  p->pending_signals = 0;
  p->proc_signal_mask = 0;
  for (int i=0 ; i<NUM_OF_SIGNALS ; i++)
  {
    p->signal_handlers[i] = SIG_DFL;
    p->signal_masks[i] = 0;
  }
  p->signal_handling = 0;
  p->freezed = 0;
  //----------------------------------------------


  t = allocthread(p);
  p->init_thread = t;
  p->alive_threads = 1;

  return p;
}




// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  for (struct thread* t = p->threads ; t<&p->threads[NTHREAD] ; t++)
    freethread(t);
  if(p->trapframes)
     kfree((void*)p->trapframes);
  p->trapframes = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  // p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED_P;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframes), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  printf("in user init\n");
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->init_thread->trapframe->epc = 0;      // user program counter
  p->init_thread->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->init_thread->state = RUNNABLE;
  p->state = ALIVE;

  release(&p->init_thread->lock);
  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  //-------------------our additions-----------------
  np->pending_signals = 0;
  np->proc_signal_mask = p->proc_signal_mask;
  for (int i=0 ; i<NUM_OF_SIGNALS ; i++)
  {
    np->signal_handlers[i] = p->signal_handlers[i];
    np->signal_masks[i] = p->signal_masks[i];
  }
  //-------------------------------------------------

  struct thread *t = mythread();
  // copy saved user registers.
  *(np->init_thread->trapframe) = *(t->trapframe);

  // Cause fork to return 0 in the child.
  np->init_thread->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  np->state = ALIVE;
  release(&np->lock);

  //acquire(&wait_lock);
  np->parent = p;
  //release(&wait_lock);

  np->init_thread->state = RUNNABLE;
  release(&np->init_thread->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");


  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  // p->state = ZOMBIE_P;

  release(&p->lock);

  for(struct thread* t = p->threads; t < &p->threads[NTHREAD]; t++)
  {
    acquire(&t->lock);
    if (t->state != UNUSED)
    {
      t->killed = 1;
      if(t->state == SLEEPING)
      {
        t->state = RUNNABLE;
      }
      }
    release(&t->lock);
  } 
  release(&wait_lock);
  exit_thread(status);

  
  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}



// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++)
    {
      if(np->parent == p)
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE_P)
        {
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) 
          {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed)
    {
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->thread = 0;
  for(;;)
  {
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for(p = proc; p < &proc[NPROC]; p++) 
    {
      if(p->state == ALIVE) 
      {

        // Switch to chosen thread.  It is the thread's job
        // to release its lock and then reacquire it
        // before jumping back to us.        
        for(struct thread* t = p->threads ; t< &p->threads[NTHREAD] ; t++)
        {

          acquire(&t->lock);
          if(t->state == RUNNABLE)
          {
            t->state = RUNNING;
            c->thread = t;
            swtch(&c->context, &t->context);
            // Process is done running for now.
            // It should have changed its p->state before coming back.
            c->thread = 0;
          }
          release(&t->lock);
        }     
      }
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct thread *t = mythread();
  
  if(!holding(&t->lock))
    panic("sched t->lock");
  if(mycpu()->noff != 1)
  {
    printf("noff:%d\n",mycpu()->noff);
    panic("sched locks");
  }
  if(t->state == RUNNING)
    panic("sched running");
  if(intr_get())
  panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&t->context, &mycpu()->context);

  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct thread *t = mythread();
  acquire(&t->lock);
  t->state = RUNNABLE;
  sched();
  release(&t->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->init_thread->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}


// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct thread *t = mythread();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&t->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  t->chan = chan;
  t->state = SLEEPING;

  sched();

  // Tidy up.
  t->chan = 0;

  // Reacquire original lock.
  release(&t->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;
  struct thread* t;

  for(p = proc; p < &proc[NPROC]; p++) 
  {
    for ( t = p->threads ; t<&p->threads[NTHREAD] ; t++)
    {
      if(t != mythread())
      {
        acquire(&t->lock);
        if(t->state == SLEEPING && t->chan == chan) 
        {
          t->state = RUNNABLE;
        }
        release(&t->lock);
      }
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid, int signum)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      uint new_mask = (1<<signum);
      p->pending_signals = p->pending_signals | new_mask ; 
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED_P]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED_P)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}


//change the proc signal mask to @param:sigmask and return the old one
uint sigprocmask(uint sigmask)
{
  struct proc *p = myproc();
  uint temp = p->proc_signal_mask;
  p->proc_signal_mask = sigmask;
  return temp;
}

//edit new signal handler when handeling the @param:signum signal 
int sigaction(int signum , uint64 act, uint64 old_act)
{
  struct proc *p = myproc();
  struct sigaction kold_act;
  struct sigaction kact;
  if((signum < 0 ) || (signum >= NUM_OF_SIGNALS) || (signum == SIGKILL) || (signum == SIGSTOP))
  {
    return -1;
  }
  if(old_act != 0)
  {
    kold_act.sa_handler = p->signal_handlers[signum];
    kold_act.sigmask = p->signal_masks[signum];
    copyout(p->pagetable, old_act, (char*) &kold_act, sizeof(struct sigaction));
  }
  if(act != 0)
  {
    copyin(p->pagetable, (char*) &kact, act, sizeof(struct sigaction));
    uint invalid_mask = (1<<SIGKILL) | (1<<SIGSTOP);
    if ((kact.sigmask & invalid_mask) != 0)
    {
      return -1;
    }
    p->signal_handlers[signum] = kact.sa_handler;
    p->signal_masks[signum] = kact.sigmask;
  }
  return 0;
}

void sigret(void)
{
  struct thread* t = mythread();
  struct proc* p = myproc();
  copy_tf(t->trapframe, t->tf_backup);
  p->proc_signal_mask = p->signal_mask_backup;
  p->signal_handling = 0; 
}


int kthread_create(uint64 func_addr ,uint64 stack ) 
{
  struct proc *p = myproc();
  struct thread *nt = allocthread(p);

  acquire(&p->lock);
  p->alive_threads++;
  release(&p->lock);

  struct thread *t = mythread();
  if(nt == 0)
    return -1;

  copy_tf(nt->trapframe, t->trapframe);
  nt->trapframe->epc = func_addr;
  nt->trapframe->sp = stack + STACK_SIZE - 16; //TODO:
  nt->state = RUNNABLE;
  nt->context.ra = (uint64) kthread_create_ret;

  //nt->lock held from allocthread
  release(&nt->lock);
  return nt->tid;
}

int kthread_id () 
{
  return mythread()->tid;
}

void kthread_exit(int status) 
{
  struct proc* p =myproc();
  if (p->alive_threads == 1)
    exit(status);
  exit_thread(status);
}

int kthread_join(int thread_id , uint64 status) 
{
  struct proc* p = myproc();

  for(struct thread *t = p->threads; t < &p->threads[NTHREAD]; t++)
  {
    if(t->tid == thread_id)
    {
      while(1)
      {

        printf("");
        if( t->state == ZOMBIE)
          break;
      }
      copyout(p->pagetable,status,(char*)&t->xstate,sizeof(t->xstate));
      return 0;

    }
  }
  return -1;
}

int garbage(uint64 a)
{
  return a+15;
}

void
kthread_create_ret(void)
{
  struct thread* t = mythread();
  t->killed=0;
  // still holding t->lock from scheduler
  release(&t->lock);

  usertrapret();
}

void  semaphoresinit(void)
{
  for(int i = 0; i < MAX_BSEM; i++)
  {
    semaphores[i].state = UNUSED_SEM;
    semaphores[i].taken = 0;
    initlock(&semaphores[i].lk, "sempaphore lock");
  }
}

int 
bsem_alloc(void)
{

  for(int i = 0; i < MAX_BSEM; i++)
  {
    if(semaphores[i].state == UNUSED_SEM)
    {
      semaphores[i].state = USED_SEM;
      semaphores[i].taken = 0;
      return i;
    }
  }
  return -1;
}

void
bsem_free(int fd)
{

  semaphores[fd].state = UNUSED_SEM;
  semaphores[fd].taken = 0;
}

void
bsem_down(int fd)
{
  struct semaphore* sem = &semaphores[fd];
  acquire(&sem->lk);
  while(__sync_lock_test_and_set(&sem->taken, 1) != 0)
  {
    sleep(sem->chan, &sem->lk);
  }
  release(&sem->lk);
  __sync_synchronize();
  return;
}

void
bsem_up(int fd)
{

  struct semaphore* sem = &semaphores[fd];
  acquire(&sem->lk);
  __sync_lock_test_and_set(&sem->taken, 0);
  wakeup(sem->chan);
  release(&sem->lk);

}






void print_ptable(void)
{
  for (int i=0 ; i<5 ; i++)
  {
    if (proc[i].pid == myproc()->pid)
      printf("pid(me):%d\n",proc[i].pid);
    else
      printf("pid:%d\n",proc[i].pid);
    printf("pstate:%s\n", proc[i].state == UNUSED_P ? "UNUSED" :
                           proc[i].state == USED_P ? "USED" :
                           proc[i].state == ALIVE ? "ALIVE" :
                           "ZOMBIE_P");
    printf("xstate:%d\n",proc[i].xstate);
    for (int j=0 ; j<NTHREAD ; j++)
    {
      if (proc[i].threads[j].tid == mythread()->tid)
        printf("\ttid(me):%d\n",proc[i].threads[j].tid);
      else
        printf("\ttid:%d\n",proc[i].threads[j].tid);
      printf("\ttstate:%s\n", proc[i].threads[j].state == UNUSED ? "UNUSED" :
                             proc[i].threads[j].state == USED ? "USED" :
                             proc[i].threads[j].state == SLEEPING ? "SLEEPING" :
                             proc[i].threads[j].state == RUNNABLE ? "RUNNABLE" :
                             proc[i].threads[j].state == RUNNING ? "RUNNING" : 
                             "ZOMBIE");
      printf("\tkilled:%d\n",proc[i].threads[j].killed);
    }
  }
}




  