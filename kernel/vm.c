#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "spinlock.h"
#include "proc.h"

/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S

// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // map kernel stacks
  proc_mapstacks(kpgtbl);
  
  return kpgtbl;
}

// Initialize the one kernel_pagetable
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
  w_satp(MAKE_SATP(kernel_pagetable));
  sfence_vma();
}

// Return the address of the PTE in page table pagetable
// that corresponds to virtual address va.  If alloc!=0,
// create any required page-table pages.
//
// The risc-v Sv39 scheme has three levels of page-table
// pages. A page-table page contains 512 64-bit PTEs.
// A 64-bit virtual address is split into five fields:
//   39..63 -- must be zero.
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}

// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if(pte == 0)
    return 0;
  if((*pte & PTE_V) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}

// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
  last = PGROUNDDOWN(va + size - 1);
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;  
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if(((*pte & PTE_V) == 0) && ((*pte & PTE_PG) == 0))
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
      panic("uvmunmap: not a leaf");
    if(do_free)
    {
      
      if ((*pte & PTE_PG) == 0)
      {
        uint64 pa = PTE2PA(*pte);
        kfree((void*)pa);
      }
    }
    remove_page(pagetable, a);
    *pte = 0;
    
  }
}

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
  memmove(mem, src, sz);
}

// Allocate PTEs and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  char *mem;
  uint64 a;
  struct proc* p = myproc();

  if(newsz < oldsz)
    return oldsz;

  oldsz = PGROUNDUP(oldsz);
  for(a = oldsz; a < newsz; a += PGSIZE)
  {
    if ((p->pid > 2) && (countmemory(pagetable) >= MAX_PSYC_PAGES))
      page_swap_out(pagetable);
    mem = kalloc();
    if(mem == 0)
    {
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
      kfree(mem);
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }

    if (a % PGSIZE != 0)
      panic("a is not aligned");
    add_page(pagetable, a);
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}

// Given a parent process's page table, copy
// its memory into a child's page table.
// Copies both the page table and the
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    {
      kfree(mem);
      goto err;
    }
    if ( *pte & PTE_PG)
    {
      pte_t* pte2 = walk(new , i , 0);
      *pte2 = (*pte2) ^ PTE_V;
      kfree(mem);
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
  if(pte == 0)
    panic("uvmclear");
  *pte &= ~PTE_U;
}

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}

// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);

    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
  }
  return 0;
}

// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
        got_null = 1;
        break;
      } else {
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
  } else {
    return -1;
  }
}

int countmemory(pagetable_t pagetable)
{
  int counter=0;
  for(int i = 0; i < 512; i++)
  {
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      uint64 child = PTE2PA(pte);
      counter += countmemory((pagetable_t)child);
    } 
    else if((pte & PTE_V) && ((pte & PTE_PG) == 0))
    {
      counter++;
    }
  }
  return counter;
}

int counttotal(pagetable_t pagetable)
{
  int counter=0;
  for(int i = 0; i < 512; i++)
  {
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      uint64 child = PTE2PA(pte);
      counter += counttotal((pagetable_t)child);
    } 
    else if((pte & PTE_V) || (pte & PTE_PG))
    {
      counter++;
    }
  }
  return counter;
}

// returns free offset in swapFile that can be written 
uint get_offset()
{   
  struct proc* p = myproc();
  for (uint offset = 0 ; offset < MAX_PSYC_PAGES* PGSIZE ; offset+= PGSIZE)
  {
    int offset_taken = 0;
    for (struct page* pg = p->pages ; pg< &p->pages[MAX_TOTAL_PAGES] && !offset_taken; pg++)
    {
      if(pg->on_disk) //if the page is on disk
        if (pg->offset == offset) // and its written in offset
          offset_taken = 1;
    }
    if (!offset_taken)
      return offset;
  }
  panic("all offsets taken");
  return 0;
}

void page_swap_out(pagetable_t pagetable)
{
  struct proc* p = myproc();

  struct page* pg_to_swap = pick_page_to_swap(pagetable);
  //printf("swapping out page starting in:%d\n", pg_to_swap->va);
  uint offset = get_offset();

  uint64 pa = walkaddr(pagetable, pg_to_swap->va);

  writeToSwapFile(p, (char*) pa, offset, PGSIZE);
  pg_to_swap->on_disk = 1;
  pg_to_swap->offset = offset;

  // free physical memory
  kfree((void*)pa);

  // mark page as swapped out
  pte_t* pte = walk(pagetable, pg_to_swap->va, 0);
  *pte = (*pte | PTE_PG) ^ PTE_V;
  
  // refresh TLB
  sfence_vma();
}

struct page* pick_page_to_swap(pagetable_t pagetable)
{
  struct proc* p = myproc();
  struct page* pg = p->pages;
  for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
  {
    if (pg->used)
    {
      //printf("va %d\n", pg->va);  
      if (pg->va == 4096 || pg->va == 0)
        continue; //we dont want to swap text page
      pte_t* pte = walk(pagetable, pg->va, 0);
      if ((*pte & PTE_V)) // if valid page
      {
        if ((*pte & PTE_PG) == 0) // and page is not pages out
        {
          if(*pte & PTE_U)  // and its a user page
          {
            return pg;
          } 
        }
      }
    }
  }
  panic("no page returned");
  return 0;
}

struct page* pick_page_to_swap_(pagetable_t pagetable)
{
  //struct proc* p = myproc();
  #ifdef SELECTION
    switch(SELECTION)
    {
      case SCFIFO:
        return find_fifo_page(pagetable, p);
      case LAPA:
        return find_min_burst();
      case NFUA:
        return find_min_ratio();
    }
  #endif
  panic("no selection picked!");
  return 0;
}

// struct page* find_fifo_page(pagetable_t pagetable, struct proc *p)
// {


//   struct page* pg;
//   struct proc* p =myproc();
//     //printf("pick page\n");
//     struct page* first = 0;
//     uint min = -1;

//     // find first page
//     for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++ )
//     {
//       pte_t *pte = walk(pagetable, pg->va, 0);

//       if (pg->used && pg->on_disk == 0)
//       {

//         if ((*pte & PTE_V)) // if its valid page
//         {
//           if ((*pte & PTE_PG) == 0) // and not paged out
//           {
//             if(*pte & PTE_U)  // and user page
//             {
//               if (pg->time <= min)
//               {
//                 min = pg->time;
//                 first = pg;
//               }
//             }
//           }
//         }
//     }

//     if (first != 0)
//     {
//       // if accessed give it second change
//       if (*first->pte & PTE_A)
//       {
//         *first->pte = (*first->pte ^ PTE_A); 
//         printf("%d", (*first->pte & PTE_A));
//       }
//       else
//         return first->pte;
//     }

//   }
//   return 0;
// }


// returns 0 if success
// returns -1 if kalloc failed 
// returns -2 if va not on disk
// returns -3 if va not aligned
// va must be aligned to the first va of the requested page
int page_swap_in(pagetable_t pagetable, uint64 va, struct proc *p)
{
  //printf("pid:%d swapping in page starting at va:%d\n",p->pid,  va);
  struct page* pg;
  for ( pg =p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)  
  {
    if (pg->va == va) // found relevant page
    {
      if (pg->on_disk == 0)
        return -2;

      if (countmemory(p->pagetable) >= MAX_PSYC_PAGES)
          page_swap_out(pagetable);
      
      char* mem = kalloc();
      if(mem == 0)
        return -1;

      readFromSwapFile(p, mem, pg->offset, PGSIZE);
      pg->on_disk = 0;

      pte_t* pte = walk(pagetable, pg->va, 0);
      int perm = (*pte) & 1023; //gives me the lower 10bits (permissions)
      perm = (perm ^ PTE_PG) | PTE_V; // turn off pg flag and turn on valid
      *pte = (PA2PTE(mem) | perm);
      return 0;
  
    }
  }
  return -3;
}


void ppages()
{
  struct proc* p = myproc();
  printf("total pages:%d\n", counttotal(p->pagetable));
  printf("pages in memory:%d\n", countmemory(p->pagetable));
  print_pages(p->pagetable);
}

void print_pages(pagetable_t pagetable)
{
   struct proc* p = myproc();
   struct page* pg;
   for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
      printf("va : %d, on disk: %d ,  offset : %d , used : %d \n",pg->va , pg->on_disk , pg->offset , pg->used);

  // for(int i = 0; i < 512; i++)
  // {
  //   pte_t* pte = &pagetable[i];
  //   if((*pte & PTE_V) && (*pte & (PTE_R|PTE_W|PTE_X)) == 0){
  //     uint64 child = PTE2PA(*pte);
  //     print_pages((pagetable_t)child);
  //   } 
  //   else if((*pte & PTE_V) || ((*pte & PTE_PG)))
  //   {
  //     printf("pte address of pid %d = %p\n",myproc()->pid, pte);
  //   }
  // }
}


// find unused page struct in p->pages and set its va
void add_page(pagetable_t pagetable, uint64 va)
{
  struct proc* p = myproc();
  if (p->pid > 1) // we want the shell process to add pages to sub processes so > 1 and not > 2
  {
    struct page* pg;
    for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    {
      if (pg->used == 0)
      {
        pg->pagetable = pagetable;
        pg->used = 1;
        pg->va = va;
        pg->time = ticks;
        return;
      }
    } 
  }
}

void remove_page(pagetable_t pagetable, uint64 va)
{
  struct proc* p = myproc();
  if (p->pid > 2)
  {
  struct page* pg;
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
  {
    if (pg->used == 1)
    {
      if (pg->va == va)
      {
        
          pg->used = 0;
          pg->va = 0;
          pg->offset = 0;
          pg->on_disk = 0;
          pg->pagetable = 0;
          return;

      }
    }
  } 
  }
}