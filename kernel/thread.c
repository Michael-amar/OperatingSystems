#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"


int nexttid = 1;
struct spinlock tid_lock;

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

//TODO: decide
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
//  guard page.
// void
// proc_mapstacks(pagetable_t kpgtbl) {
//   struct proc *p;
  
//   for(p = proc; p < &proc[NPROC]; p++) {
//     char *pa = kalloc();
//     if(pa == 0)
//       panic("kalloc");
//     uint64 va = KSTACK((int) (p - proc));
//     kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
//   }
// }

// Return the current struct proc *, or zero if none.
struct proc*
mythread(void) {
  push_off();
  struct cpu *c = mycpu();
  struct thread *t = c->thread;
  pop_off();
  return t;
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


//TODO: what is forkret? decide what to do with it in this function
// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct thread*
allocthread(struct proc* p)
{
  struct thread *t;
  int index = 0;
  for(t = p->threads; t < &p->threads[NTHREAD]; t++) {
    acquire(&t->lock);
    if(t->state == UNUSED) {
      goto found;
    } else {
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
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&t->context, 0, sizeof(t->context));
  t->context.sp = t->kstack + PGSIZE;

  return t;
}


// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freethread(struct thread *t)
{
  if(t->trapframe)
    kfree((void*)t->trapframe);
  if(t->tf_backup)
    kfree((void*)t->tf_backup);
  t->tid = 0;
  t->parent = 0;
  t->chan = 0;
  t->killed = 0;
  t->xstate = 0;
  t->state = UNUSED;
}
