


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


