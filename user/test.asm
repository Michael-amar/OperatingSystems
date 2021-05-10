
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <forkfork>:
#include "sigaction.h"

// concurrent forks to try to expose locking bugs.
void
forkfork(char *s)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
  enum { N=2 };
  
  for(int i = 0; i < N; i++){
    int pid = fork();
   c:	00000097          	auipc	ra,0x0
  10:	4ec080e7          	jalr	1260(ra) # 4f8 <fork>
    if(pid < 0){
  14:	04054163          	bltz	a0,56 <forkfork+0x56>
      printf("%s: fork failed", s);
      exit(1);
    }
    if(pid == 0){
  18:	cd29                	beqz	a0,72 <forkfork+0x72>
    int pid = fork();
  1a:	00000097          	auipc	ra,0x0
  1e:	4de080e7          	jalr	1246(ra) # 4f8 <fork>
    if(pid < 0){
  22:	02054a63          	bltz	a0,56 <forkfork+0x56>
    if(pid == 0){
  26:	c531                	beqz	a0,72 <forkfork+0x72>
    }
  }

  int xstatus;
  for(int i = 0; i < N; i++){
    wait(&xstatus);
  28:	fdc40513          	addi	a0,s0,-36
  2c:	00000097          	auipc	ra,0x0
  30:	4dc080e7          	jalr	1244(ra) # 508 <wait>
    if(xstatus != 0) {
  34:	fdc42783          	lw	a5,-36(s0)
  38:	ebbd                	bnez	a5,ae <forkfork+0xae>
    wait(&xstatus);
  3a:	fdc40513          	addi	a0,s0,-36
  3e:	00000097          	auipc	ra,0x0
  42:	4ca080e7          	jalr	1226(ra) # 508 <wait>
    if(xstatus != 0) {
  46:	fdc42783          	lw	a5,-36(s0)
  4a:	e3b5                	bnez	a5,ae <forkfork+0xae>
      printf("%s: fork in child failed", s);
      exit(1);
    }
  }
}
  4c:	70a2                	ld	ra,40(sp)
  4e:	7402                	ld	s0,32(sp)
  50:	64e2                	ld	s1,24(sp)
  52:	6145                	addi	sp,sp,48
  54:	8082                	ret
      printf("%s: fork failed", s);
  56:	85a6                	mv	a1,s1
  58:	00001517          	auipc	a0,0x1
  5c:	a5050513          	addi	a0,a0,-1456 # aa8 <malloc+0xe6>
  60:	00001097          	auipc	ra,0x1
  64:	8a4080e7          	jalr	-1884(ra) # 904 <printf>
      exit(1);
  68:	4505                	li	a0,1
  6a:	00000097          	auipc	ra,0x0
  6e:	496080e7          	jalr	1174(ra) # 500 <exit>
{
  72:	0c800493          	li	s1,200
        int pid1 = fork();
  76:	00000097          	auipc	ra,0x0
  7a:	482080e7          	jalr	1154(ra) # 4f8 <fork>
        if(pid1 < 0){
  7e:	00054f63          	bltz	a0,9c <forkfork+0x9c>
        if(pid1 == 0){
  82:	c115                	beqz	a0,a6 <forkfork+0xa6>
        wait(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	482080e7          	jalr	1154(ra) # 508 <wait>
      for(int j = 0; j < 200; j++){
  8e:	34fd                	addiw	s1,s1,-1
  90:	f0fd                	bnez	s1,76 <forkfork+0x76>
      exit(0);
  92:	4501                	li	a0,0
  94:	00000097          	auipc	ra,0x0
  98:	46c080e7          	jalr	1132(ra) # 500 <exit>
          exit(1);
  9c:	4505                	li	a0,1
  9e:	00000097          	auipc	ra,0x0
  a2:	462080e7          	jalr	1122(ra) # 500 <exit>
          exit(0);
  a6:	00000097          	auipc	ra,0x0
  aa:	45a080e7          	jalr	1114(ra) # 500 <exit>
      printf("%s: fork in child failed", s);
  ae:	85a6                	mv	a1,s1
  b0:	00001517          	auipc	a0,0x1
  b4:	a0850513          	addi	a0,a0,-1528 # ab8 <malloc+0xf6>
  b8:	00001097          	auipc	ra,0x1
  bc:	84c080e7          	jalr	-1972(ra) # 904 <printf>
      exit(1);
  c0:	4505                	li	a0,1
  c2:	00000097          	auipc	ra,0x0
  c6:	43e080e7          	jalr	1086(ra) # 500 <exit>

00000000000000ca <sbrkbugs>:

void
sbrkbugs(char *s)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e406                	sd	ra,8(sp)
  ce:	e022                	sd	s0,0(sp)
  d0:	0800                	addi	s0,sp,16
  int pid = fork();
  d2:	00000097          	auipc	ra,0x0
  d6:	426080e7          	jalr	1062(ra) # 4f8 <fork>
  if(pid < 0){
  da:	02054263          	bltz	a0,fe <sbrkbugs+0x34>
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
  de:	ed0d                	bnez	a0,118 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
  e0:	00000097          	auipc	ra,0x0
  e4:	4a8080e7          	jalr	1192(ra) # 588 <sbrk>
    // free all user memory; there used to be a bug that
    // would not adjust p->sz correctly in this case,
    // causing exit() to panic.
    sbrk(-sz);
  e8:	40a0053b          	negw	a0,a0
  ec:	00000097          	auipc	ra,0x0
  f0:	49c080e7          	jalr	1180(ra) # 588 <sbrk>
    // user page fault here.
    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	40a080e7          	jalr	1034(ra) # 500 <exit>
    printf("fork failed\n");
  fe:	00001517          	auipc	a0,0x1
 102:	9da50513          	addi	a0,a0,-1574 # ad8 <malloc+0x116>
 106:	00000097          	auipc	ra,0x0
 10a:	7fe080e7          	jalr	2046(ra) # 904 <printf>
    exit(1);
 10e:	4505                	li	a0,1
 110:	00000097          	auipc	ra,0x0
 114:	3f0080e7          	jalr	1008(ra) # 500 <exit>
  }
  wait(0);
 118:	4501                	li	a0,0
 11a:	00000097          	auipc	ra,0x0
 11e:	3ee080e7          	jalr	1006(ra) # 508 <wait>

  pid = fork();
 122:	00000097          	auipc	ra,0x0
 126:	3d6080e7          	jalr	982(ra) # 4f8 <fork>
  if(pid < 0){
 12a:	02054563          	bltz	a0,154 <sbrkbugs+0x8a>
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
 12e:	e121                	bnez	a0,16e <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
 130:	00000097          	auipc	ra,0x0
 134:	458080e7          	jalr	1112(ra) # 588 <sbrk>
    // set the break to somewhere in the very first
    // page; there used to be a bug that would incorrectly
    // free the first page.
    sbrk(-(sz - 3500));
 138:	6785                	lui	a5,0x1
 13a:	dac7879b          	addiw	a5,a5,-596
 13e:	40a7853b          	subw	a0,a5,a0
 142:	00000097          	auipc	ra,0x0
 146:	446080e7          	jalr	1094(ra) # 588 <sbrk>
    exit(0);
 14a:	4501                	li	a0,0
 14c:	00000097          	auipc	ra,0x0
 150:	3b4080e7          	jalr	948(ra) # 500 <exit>
    printf("fork failed\n");
 154:	00001517          	auipc	a0,0x1
 158:	98450513          	addi	a0,a0,-1660 # ad8 <malloc+0x116>
 15c:	00000097          	auipc	ra,0x0
 160:	7a8080e7          	jalr	1960(ra) # 904 <printf>
    exit(1);
 164:	4505                	li	a0,1
 166:	00000097          	auipc	ra,0x0
 16a:	39a080e7          	jalr	922(ra) # 500 <exit>
  }
  wait(0);
 16e:	4501                	li	a0,0
 170:	00000097          	auipc	ra,0x0
 174:	398080e7          	jalr	920(ra) # 508 <wait>

  pid = fork();
 178:	00000097          	auipc	ra,0x0
 17c:	380080e7          	jalr	896(ra) # 4f8 <fork>
  if(pid < 0){
 180:	02054a63          	bltz	a0,1b4 <sbrkbugs+0xea>
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
 184:	e529                	bnez	a0,1ce <sbrkbugs+0x104>
    // set the break in the middle of a page.
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
 186:	00000097          	auipc	ra,0x0
 18a:	402080e7          	jalr	1026(ra) # 588 <sbrk>
 18e:	67ad                	lui	a5,0xb
 190:	8007879b          	addiw	a5,a5,-2048
 194:	40a7853b          	subw	a0,a5,a0
 198:	00000097          	auipc	ra,0x0
 19c:	3f0080e7          	jalr	1008(ra) # 588 <sbrk>

    // reduce the break a bit, but not enough to
    // cause a page to be freed. this used to cause
    // a panic.
    sbrk(-10);
 1a0:	5559                	li	a0,-10
 1a2:	00000097          	auipc	ra,0x0
 1a6:	3e6080e7          	jalr	998(ra) # 588 <sbrk>

    exit(0);
 1aa:	4501                	li	a0,0
 1ac:	00000097          	auipc	ra,0x0
 1b0:	354080e7          	jalr	852(ra) # 500 <exit>
    printf("fork failed\n");
 1b4:	00001517          	auipc	a0,0x1
 1b8:	92450513          	addi	a0,a0,-1756 # ad8 <malloc+0x116>
 1bc:	00000097          	auipc	ra,0x0
 1c0:	748080e7          	jalr	1864(ra) # 904 <printf>
    exit(1);
 1c4:	4505                	li	a0,1
 1c6:	00000097          	auipc	ra,0x0
 1ca:	33a080e7          	jalr	826(ra) # 500 <exit>
  }
  wait(0);
 1ce:	4501                	li	a0,0
 1d0:	00000097          	auipc	ra,0x0
 1d4:	338080e7          	jalr	824(ra) # 508 <wait>

  exit(0);
 1d8:	4501                	li	a0,0
 1da:	00000097          	auipc	ra,0x0
 1de:	326080e7          	jalr	806(ra) # 500 <exit>

00000000000001e2 <tfunc>:
}

void tfunc()
{
 1e2:	7179                	addi	sp,sp,-48
 1e4:	f406                	sd	ra,40(sp)
 1e6:	f022                	sd	s0,32(sp)
 1e8:	ec26                	sd	s1,24(sp)
 1ea:	e84a                	sd	s2,16(sp)
 1ec:	e44e                	sd	s3,8(sp)
 1ee:	1800                	addi	s0,sp,48
    printf("id is: %d\n",kthread_id());
 1f0:	00000097          	auipc	ra,0x0
 1f4:	3d0080e7          	jalr	976(ra) # 5c0 <kthread_id>
 1f8:	85aa                	mv	a1,a0
 1fa:	00001517          	auipc	a0,0x1
 1fe:	8ee50513          	addi	a0,a0,-1810 # ae8 <malloc+0x126>
 202:	00000097          	auipc	ra,0x0
 206:	702080e7          	jalr	1794(ra) # 904 <printf>
    for(int i=0 ; i<10 ; i++)
 20a:	4481                	li	s1,0
  {
    printf("hello %d\n",i);
 20c:	00001997          	auipc	s3,0x1
 210:	8ec98993          	addi	s3,s3,-1812 # af8 <malloc+0x136>
    for(int i=0 ; i<10 ; i++)
 214:	4929                	li	s2,10
    printf("hello %d\n",i);
 216:	85a6                	mv	a1,s1
 218:	854e                	mv	a0,s3
 21a:	00000097          	auipc	ra,0x0
 21e:	6ea080e7          	jalr	1770(ra) # 904 <printf>
    for(int i=0 ; i<10 ; i++)
 222:	2485                	addiw	s1,s1,1
 224:	ff2499e3          	bne	s1,s2,216 <tfunc+0x34>
  }
  exit(0);
 228:	4501                	li	a0,0
 22a:	00000097          	auipc	ra,0x0
 22e:	2d6080e7          	jalr	726(ra) # 500 <exit>

0000000000000232 <main>:
}

int main()
{
 232:	1141                	addi	sp,sp,-16
 234:	e406                	sd	ra,8(sp)
 236:	e022                	sd	s0,0(sp)
 238:	0800                	addi	s0,sp,16
bsem_alloc();
 23a:	00000097          	auipc	ra,0x0
 23e:	39e080e7          	jalr	926(ra) # 5d8 <bsem_alloc>

bsem_free(0);
 242:	4501                	li	a0,0
 244:	00000097          	auipc	ra,0x0
 248:	39c080e7          	jalr	924(ra) # 5e0 <bsem_free>

bsem_down(0);
 24c:	4501                	li	a0,0
 24e:	00000097          	auipc	ra,0x0
 252:	39a080e7          	jalr	922(ra) # 5e8 <bsem_down>

bsem_up(0);
 256:	4501                	li	a0,0
 258:	00000097          	auipc	ra,0x0
 25c:	398080e7          	jalr	920(ra) # 5f0 <bsem_up>

csem_alloc(0);
 260:	4501                	li	a0,0
 262:	00000097          	auipc	ra,0x0
 266:	398080e7          	jalr	920(ra) # 5fa <csem_alloc>

csem_free(0);
 26a:	4501                	li	a0,0
 26c:	00000097          	auipc	ra,0x0
 270:	398080e7          	jalr	920(ra) # 604 <csem_free>

csem_down(0);
 274:	4501                	li	a0,0
 276:	00000097          	auipc	ra,0x0
 27a:	398080e7          	jalr	920(ra) # 60e <csem_down>

csem_up(0);
 27e:	4501                	li	a0,0
 280:	00000097          	auipc	ra,0x0
 284:	398080e7          	jalr	920(ra) # 618 <csem_up>
    // void* stack = malloc(STACK_SIZE);
    // kthread_create(&tfunc,stack);
    // printf("id is: %d\n",kthread_id());
    // //print_ptable();
    // sleep(10);
    exit(1);
 288:	4505                	li	a0,1
 28a:	00000097          	auipc	ra,0x0
 28e:	276080e7          	jalr	630(ra) # 500 <exit>

0000000000000292 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 298:	87aa                	mv	a5,a0
 29a:	0585                	addi	a1,a1,1
 29c:	0785                	addi	a5,a5,1
 29e:	fff5c703          	lbu	a4,-1(a1)
 2a2:	fee78fa3          	sb	a4,-1(a5) # afff <__global_pointer$+0x9cde>
 2a6:	fb75                	bnez	a4,29a <strcpy+0x8>
    ;
  return os;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret

00000000000002ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	cb91                	beqz	a5,2cc <strcmp+0x1e>
 2ba:	0005c703          	lbu	a4,0(a1)
 2be:	00f71763          	bne	a4,a5,2cc <strcmp+0x1e>
    p++, q++;
 2c2:	0505                	addi	a0,a0,1
 2c4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	fbe5                	bnez	a5,2ba <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2cc:	0005c503          	lbu	a0,0(a1)
}
 2d0:	40a7853b          	subw	a0,a5,a0
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <strlen>:

uint
strlen(const char *s)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e422                	sd	s0,8(sp)
 2de:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2e0:	00054783          	lbu	a5,0(a0)
 2e4:	cf91                	beqz	a5,300 <strlen+0x26>
 2e6:	0505                	addi	a0,a0,1
 2e8:	87aa                	mv	a5,a0
 2ea:	4685                	li	a3,1
 2ec:	9e89                	subw	a3,a3,a0
 2ee:	00f6853b          	addw	a0,a3,a5
 2f2:	0785                	addi	a5,a5,1
 2f4:	fff7c703          	lbu	a4,-1(a5)
 2f8:	fb7d                	bnez	a4,2ee <strlen+0x14>
    ;
  return n;
}
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
  for(n = 0; s[n]; n++)
 300:	4501                	li	a0,0
 302:	bfe5                	j	2fa <strlen+0x20>

0000000000000304 <memset>:

void*
memset(void *dst, int c, uint n)
{
 304:	1141                	addi	sp,sp,-16
 306:	e422                	sd	s0,8(sp)
 308:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 30a:	ca19                	beqz	a2,320 <memset+0x1c>
 30c:	87aa                	mv	a5,a0
 30e:	1602                	slli	a2,a2,0x20
 310:	9201                	srli	a2,a2,0x20
 312:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 316:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 31a:	0785                	addi	a5,a5,1
 31c:	fee79de3          	bne	a5,a4,316 <memset+0x12>
  }
  return dst;
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <strchr>:

char*
strchr(const char *s, char c)
{
 326:	1141                	addi	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 32c:	00054783          	lbu	a5,0(a0)
 330:	cb99                	beqz	a5,346 <strchr+0x20>
    if(*s == c)
 332:	00f58763          	beq	a1,a5,340 <strchr+0x1a>
  for(; *s; s++)
 336:	0505                	addi	a0,a0,1
 338:	00054783          	lbu	a5,0(a0)
 33c:	fbfd                	bnez	a5,332 <strchr+0xc>
      return (char*)s;
  return 0;
 33e:	4501                	li	a0,0
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
  return 0;
 346:	4501                	li	a0,0
 348:	bfe5                	j	340 <strchr+0x1a>

000000000000034a <gets>:

char*
gets(char *buf, int max)
{
 34a:	711d                	addi	sp,sp,-96
 34c:	ec86                	sd	ra,88(sp)
 34e:	e8a2                	sd	s0,80(sp)
 350:	e4a6                	sd	s1,72(sp)
 352:	e0ca                	sd	s2,64(sp)
 354:	fc4e                	sd	s3,56(sp)
 356:	f852                	sd	s4,48(sp)
 358:	f456                	sd	s5,40(sp)
 35a:	f05a                	sd	s6,32(sp)
 35c:	ec5e                	sd	s7,24(sp)
 35e:	1080                	addi	s0,sp,96
 360:	8baa                	mv	s7,a0
 362:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 364:	892a                	mv	s2,a0
 366:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 368:	4aa9                	li	s5,10
 36a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 36c:	89a6                	mv	s3,s1
 36e:	2485                	addiw	s1,s1,1
 370:	0344d863          	bge	s1,s4,3a0 <gets+0x56>
    cc = read(0, &c, 1);
 374:	4605                	li	a2,1
 376:	faf40593          	addi	a1,s0,-81
 37a:	4501                	li	a0,0
 37c:	00000097          	auipc	ra,0x0
 380:	19c080e7          	jalr	412(ra) # 518 <read>
    if(cc < 1)
 384:	00a05e63          	blez	a0,3a0 <gets+0x56>
    buf[i++] = c;
 388:	faf44783          	lbu	a5,-81(s0)
 38c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 390:	01578763          	beq	a5,s5,39e <gets+0x54>
 394:	0905                	addi	s2,s2,1
 396:	fd679be3          	bne	a5,s6,36c <gets+0x22>
  for(i=0; i+1 < max; ){
 39a:	89a6                	mv	s3,s1
 39c:	a011                	j	3a0 <gets+0x56>
 39e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3a0:	99de                	add	s3,s3,s7
 3a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 3a6:	855e                	mv	a0,s7
 3a8:	60e6                	ld	ra,88(sp)
 3aa:	6446                	ld	s0,80(sp)
 3ac:	64a6                	ld	s1,72(sp)
 3ae:	6906                	ld	s2,64(sp)
 3b0:	79e2                	ld	s3,56(sp)
 3b2:	7a42                	ld	s4,48(sp)
 3b4:	7aa2                	ld	s5,40(sp)
 3b6:	7b02                	ld	s6,32(sp)
 3b8:	6be2                	ld	s7,24(sp)
 3ba:	6125                	addi	sp,sp,96
 3bc:	8082                	ret

00000000000003be <stat>:

int
stat(const char *n, struct stat *st)
{
 3be:	1101                	addi	sp,sp,-32
 3c0:	ec06                	sd	ra,24(sp)
 3c2:	e822                	sd	s0,16(sp)
 3c4:	e426                	sd	s1,8(sp)
 3c6:	e04a                	sd	s2,0(sp)
 3c8:	1000                	addi	s0,sp,32
 3ca:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3cc:	4581                	li	a1,0
 3ce:	00000097          	auipc	ra,0x0
 3d2:	172080e7          	jalr	370(ra) # 540 <open>
  if(fd < 0)
 3d6:	02054563          	bltz	a0,400 <stat+0x42>
 3da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3dc:	85ca                	mv	a1,s2
 3de:	00000097          	auipc	ra,0x0
 3e2:	17a080e7          	jalr	378(ra) # 558 <fstat>
 3e6:	892a                	mv	s2,a0
  close(fd);
 3e8:	8526                	mv	a0,s1
 3ea:	00000097          	auipc	ra,0x0
 3ee:	13e080e7          	jalr	318(ra) # 528 <close>
  return r;
}
 3f2:	854a                	mv	a0,s2
 3f4:	60e2                	ld	ra,24(sp)
 3f6:	6442                	ld	s0,16(sp)
 3f8:	64a2                	ld	s1,8(sp)
 3fa:	6902                	ld	s2,0(sp)
 3fc:	6105                	addi	sp,sp,32
 3fe:	8082                	ret
    return -1;
 400:	597d                	li	s2,-1
 402:	bfc5                	j	3f2 <stat+0x34>

0000000000000404 <atoi>:

int
atoi(const char *s)
{
 404:	1141                	addi	sp,sp,-16
 406:	e422                	sd	s0,8(sp)
 408:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 40a:	00054603          	lbu	a2,0(a0)
 40e:	fd06079b          	addiw	a5,a2,-48
 412:	0ff7f793          	andi	a5,a5,255
 416:	4725                	li	a4,9
 418:	02f76963          	bltu	a4,a5,44a <atoi+0x46>
 41c:	86aa                	mv	a3,a0
  n = 0;
 41e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 420:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 422:	0685                	addi	a3,a3,1
 424:	0025179b          	slliw	a5,a0,0x2
 428:	9fa9                	addw	a5,a5,a0
 42a:	0017979b          	slliw	a5,a5,0x1
 42e:	9fb1                	addw	a5,a5,a2
 430:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 434:	0006c603          	lbu	a2,0(a3)
 438:	fd06071b          	addiw	a4,a2,-48
 43c:	0ff77713          	andi	a4,a4,255
 440:	fee5f1e3          	bgeu	a1,a4,422 <atoi+0x1e>
  return n;
}
 444:	6422                	ld	s0,8(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret
  n = 0;
 44a:	4501                	li	a0,0
 44c:	bfe5                	j	444 <atoi+0x40>

000000000000044e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 44e:	1141                	addi	sp,sp,-16
 450:	e422                	sd	s0,8(sp)
 452:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 454:	02b57463          	bgeu	a0,a1,47c <memmove+0x2e>
    while(n-- > 0)
 458:	00c05f63          	blez	a2,476 <memmove+0x28>
 45c:	1602                	slli	a2,a2,0x20
 45e:	9201                	srli	a2,a2,0x20
 460:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 464:	872a                	mv	a4,a0
      *dst++ = *src++;
 466:	0585                	addi	a1,a1,1
 468:	0705                	addi	a4,a4,1
 46a:	fff5c683          	lbu	a3,-1(a1)
 46e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 472:	fee79ae3          	bne	a5,a4,466 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 476:	6422                	ld	s0,8(sp)
 478:	0141                	addi	sp,sp,16
 47a:	8082                	ret
    dst += n;
 47c:	00c50733          	add	a4,a0,a2
    src += n;
 480:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 482:	fec05ae3          	blez	a2,476 <memmove+0x28>
 486:	fff6079b          	addiw	a5,a2,-1
 48a:	1782                	slli	a5,a5,0x20
 48c:	9381                	srli	a5,a5,0x20
 48e:	fff7c793          	not	a5,a5
 492:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 494:	15fd                	addi	a1,a1,-1
 496:	177d                	addi	a4,a4,-1
 498:	0005c683          	lbu	a3,0(a1)
 49c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4a0:	fee79ae3          	bne	a5,a4,494 <memmove+0x46>
 4a4:	bfc9                	j	476 <memmove+0x28>

00000000000004a6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e422                	sd	s0,8(sp)
 4aa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4ac:	ca05                	beqz	a2,4dc <memcmp+0x36>
 4ae:	fff6069b          	addiw	a3,a2,-1
 4b2:	1682                	slli	a3,a3,0x20
 4b4:	9281                	srli	a3,a3,0x20
 4b6:	0685                	addi	a3,a3,1
 4b8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4ba:	00054783          	lbu	a5,0(a0)
 4be:	0005c703          	lbu	a4,0(a1)
 4c2:	00e79863          	bne	a5,a4,4d2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4c6:	0505                	addi	a0,a0,1
    p2++;
 4c8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4ca:	fed518e3          	bne	a0,a3,4ba <memcmp+0x14>
  }
  return 0;
 4ce:	4501                	li	a0,0
 4d0:	a019                	j	4d6 <memcmp+0x30>
      return *p1 - *p2;
 4d2:	40e7853b          	subw	a0,a5,a4
}
 4d6:	6422                	ld	s0,8(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret
  return 0;
 4dc:	4501                	li	a0,0
 4de:	bfe5                	j	4d6 <memcmp+0x30>

00000000000004e0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e406                	sd	ra,8(sp)
 4e4:	e022                	sd	s0,0(sp)
 4e6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4e8:	00000097          	auipc	ra,0x0
 4ec:	f66080e7          	jalr	-154(ra) # 44e <memmove>
}
 4f0:	60a2                	ld	ra,8(sp)
 4f2:	6402                	ld	s0,0(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret

00000000000004f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f8:	4885                	li	a7,1
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exit>:
.global exit
exit:
 li a7, SYS_exit
 500:	4889                	li	a7,2
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <wait>:
.global wait
wait:
 li a7, SYS_wait
 508:	488d                	li	a7,3
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 510:	4891                	li	a7,4
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <read>:
.global read
read:
 li a7, SYS_read
 518:	4895                	li	a7,5
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <write>:
.global write
write:
 li a7, SYS_write
 520:	48c1                	li	a7,16
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <close>:
.global close
close:
 li a7, SYS_close
 528:	48d5                	li	a7,21
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <kill>:
.global kill
kill:
 li a7, SYS_kill
 530:	4899                	li	a7,6
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <exec>:
.global exec
exec:
 li a7, SYS_exec
 538:	489d                	li	a7,7
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <open>:
.global open
open:
 li a7, SYS_open
 540:	48bd                	li	a7,15
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 548:	48c5                	li	a7,17
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 550:	48c9                	li	a7,18
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 558:	48a1                	li	a7,8
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <link>:
.global link
link:
 li a7, SYS_link
 560:	48cd                	li	a7,19
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 568:	48d1                	li	a7,20
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 570:	48a5                	li	a7,9
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <dup>:
.global dup
dup:
 li a7, SYS_dup
 578:	48a9                	li	a7,10
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 580:	48ad                	li	a7,11
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 588:	48b1                	li	a7,12
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 590:	48b5                	li	a7,13
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 598:	48b9                	li	a7,14
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 5a0:	48d9                	li	a7,22
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 5a8:	48dd                	li	a7,23
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 5b0:	48e1                	li	a7,24
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 5b8:	48e5                	li	a7,25
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 5c0:	48e9                	li	a7,26
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 5c8:	48ed                	li	a7,27
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 5d0:	48f1                	li	a7,28
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <bsem_alloc>:
.global bsem_alloc
bsem_alloc:
 li a7, SYS_bsem_alloc
 5d8:	48f5                	li	a7,29
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <bsem_free>:
.global bsem_free
bsem_free:
 li a7, SYS_bsem_free
 5e0:	48f9                	li	a7,30
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <bsem_down>:
.global bsem_down
bsem_down:
 li a7, SYS_bsem_down
 5e8:	48fd                	li	a7,31
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <bsem_up>:
.global bsem_up
bsem_up:
 li a7, SYS_bsem_up
 5f0:	02000893          	li	a7,32
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <csem_alloc>:
.global csem_alloc
csem_alloc:
 li a7, SYS_csem_alloc
 5fa:	02100893          	li	a7,33
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <csem_free>:
.global csem_free
csem_free:
 li a7, SYS_csem_free
 604:	02200893          	li	a7,34
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <csem_down>:
.global csem_down
csem_down:
 li a7, SYS_csem_down
 60e:	02300893          	li	a7,35
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <csem_up>:
.global csem_up
csem_up:
 li a7, SYS_csem_up
 618:	02400893          	li	a7,36
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <print_ptable>:
.global print_ptable
print_ptable:
 li a7, SYS_print_ptable
 622:	02500893          	li	a7,37
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 62c:	1101                	addi	sp,sp,-32
 62e:	ec06                	sd	ra,24(sp)
 630:	e822                	sd	s0,16(sp)
 632:	1000                	addi	s0,sp,32
 634:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 638:	4605                	li	a2,1
 63a:	fef40593          	addi	a1,s0,-17
 63e:	00000097          	auipc	ra,0x0
 642:	ee2080e7          	jalr	-286(ra) # 520 <write>
}
 646:	60e2                	ld	ra,24(sp)
 648:	6442                	ld	s0,16(sp)
 64a:	6105                	addi	sp,sp,32
 64c:	8082                	ret

000000000000064e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 64e:	7139                	addi	sp,sp,-64
 650:	fc06                	sd	ra,56(sp)
 652:	f822                	sd	s0,48(sp)
 654:	f426                	sd	s1,40(sp)
 656:	f04a                	sd	s2,32(sp)
 658:	ec4e                	sd	s3,24(sp)
 65a:	0080                	addi	s0,sp,64
 65c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 65e:	c299                	beqz	a3,664 <printint+0x16>
 660:	0805c863          	bltz	a1,6f0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 664:	2581                	sext.w	a1,a1
  neg = 0;
 666:	4881                	li	a7,0
 668:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 66c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 66e:	2601                	sext.w	a2,a2
 670:	00000517          	auipc	a0,0x0
 674:	4a050513          	addi	a0,a0,1184 # b10 <digits>
 678:	883a                	mv	a6,a4
 67a:	2705                	addiw	a4,a4,1
 67c:	02c5f7bb          	remuw	a5,a1,a2
 680:	1782                	slli	a5,a5,0x20
 682:	9381                	srli	a5,a5,0x20
 684:	97aa                	add	a5,a5,a0
 686:	0007c783          	lbu	a5,0(a5)
 68a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 68e:	0005879b          	sext.w	a5,a1
 692:	02c5d5bb          	divuw	a1,a1,a2
 696:	0685                	addi	a3,a3,1
 698:	fec7f0e3          	bgeu	a5,a2,678 <printint+0x2a>
  if(neg)
 69c:	00088b63          	beqz	a7,6b2 <printint+0x64>
    buf[i++] = '-';
 6a0:	fd040793          	addi	a5,s0,-48
 6a4:	973e                	add	a4,a4,a5
 6a6:	02d00793          	li	a5,45
 6aa:	fef70823          	sb	a5,-16(a4)
 6ae:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6b2:	02e05863          	blez	a4,6e2 <printint+0x94>
 6b6:	fc040793          	addi	a5,s0,-64
 6ba:	00e78933          	add	s2,a5,a4
 6be:	fff78993          	addi	s3,a5,-1
 6c2:	99ba                	add	s3,s3,a4
 6c4:	377d                	addiw	a4,a4,-1
 6c6:	1702                	slli	a4,a4,0x20
 6c8:	9301                	srli	a4,a4,0x20
 6ca:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6ce:	fff94583          	lbu	a1,-1(s2)
 6d2:	8526                	mv	a0,s1
 6d4:	00000097          	auipc	ra,0x0
 6d8:	f58080e7          	jalr	-168(ra) # 62c <putc>
  while(--i >= 0)
 6dc:	197d                	addi	s2,s2,-1
 6de:	ff3918e3          	bne	s2,s3,6ce <printint+0x80>
}
 6e2:	70e2                	ld	ra,56(sp)
 6e4:	7442                	ld	s0,48(sp)
 6e6:	74a2                	ld	s1,40(sp)
 6e8:	7902                	ld	s2,32(sp)
 6ea:	69e2                	ld	s3,24(sp)
 6ec:	6121                	addi	sp,sp,64
 6ee:	8082                	ret
    x = -xx;
 6f0:	40b005bb          	negw	a1,a1
    neg = 1;
 6f4:	4885                	li	a7,1
    x = -xx;
 6f6:	bf8d                	j	668 <printint+0x1a>

00000000000006f8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6f8:	7119                	addi	sp,sp,-128
 6fa:	fc86                	sd	ra,120(sp)
 6fc:	f8a2                	sd	s0,112(sp)
 6fe:	f4a6                	sd	s1,104(sp)
 700:	f0ca                	sd	s2,96(sp)
 702:	ecce                	sd	s3,88(sp)
 704:	e8d2                	sd	s4,80(sp)
 706:	e4d6                	sd	s5,72(sp)
 708:	e0da                	sd	s6,64(sp)
 70a:	fc5e                	sd	s7,56(sp)
 70c:	f862                	sd	s8,48(sp)
 70e:	f466                	sd	s9,40(sp)
 710:	f06a                	sd	s10,32(sp)
 712:	ec6e                	sd	s11,24(sp)
 714:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 716:	0005c903          	lbu	s2,0(a1)
 71a:	18090f63          	beqz	s2,8b8 <vprintf+0x1c0>
 71e:	8aaa                	mv	s5,a0
 720:	8b32                	mv	s6,a2
 722:	00158493          	addi	s1,a1,1
  state = 0;
 726:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 728:	02500a13          	li	s4,37
      if(c == 'd'){
 72c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 730:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 734:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 738:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 73c:	00000b97          	auipc	s7,0x0
 740:	3d4b8b93          	addi	s7,s7,980 # b10 <digits>
 744:	a839                	j	762 <vprintf+0x6a>
        putc(fd, c);
 746:	85ca                	mv	a1,s2
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	ee2080e7          	jalr	-286(ra) # 62c <putc>
 752:	a019                	j	758 <vprintf+0x60>
    } else if(state == '%'){
 754:	01498f63          	beq	s3,s4,772 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 758:	0485                	addi	s1,s1,1
 75a:	fff4c903          	lbu	s2,-1(s1)
 75e:	14090d63          	beqz	s2,8b8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 762:	0009079b          	sext.w	a5,s2
    if(state == 0){
 766:	fe0997e3          	bnez	s3,754 <vprintf+0x5c>
      if(c == '%'){
 76a:	fd479ee3          	bne	a5,s4,746 <vprintf+0x4e>
        state = '%';
 76e:	89be                	mv	s3,a5
 770:	b7e5                	j	758 <vprintf+0x60>
      if(c == 'd'){
 772:	05878063          	beq	a5,s8,7b2 <vprintf+0xba>
      } else if(c == 'l') {
 776:	05978c63          	beq	a5,s9,7ce <vprintf+0xd6>
      } else if(c == 'x') {
 77a:	07a78863          	beq	a5,s10,7ea <vprintf+0xf2>
      } else if(c == 'p') {
 77e:	09b78463          	beq	a5,s11,806 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 782:	07300713          	li	a4,115
 786:	0ce78663          	beq	a5,a4,852 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 78a:	06300713          	li	a4,99
 78e:	0ee78e63          	beq	a5,a4,88a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 792:	11478863          	beq	a5,s4,8a2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 796:	85d2                	mv	a1,s4
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	e92080e7          	jalr	-366(ra) # 62c <putc>
        putc(fd, c);
 7a2:	85ca                	mv	a1,s2
 7a4:	8556                	mv	a0,s5
 7a6:	00000097          	auipc	ra,0x0
 7aa:	e86080e7          	jalr	-378(ra) # 62c <putc>
      }
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b765                	j	758 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7b2:	008b0913          	addi	s2,s6,8
 7b6:	4685                	li	a3,1
 7b8:	4629                	li	a2,10
 7ba:	000b2583          	lw	a1,0(s6)
 7be:	8556                	mv	a0,s5
 7c0:	00000097          	auipc	ra,0x0
 7c4:	e8e080e7          	jalr	-370(ra) # 64e <printint>
 7c8:	8b4a                	mv	s6,s2
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b771                	j	758 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ce:	008b0913          	addi	s2,s6,8
 7d2:	4681                	li	a3,0
 7d4:	4629                	li	a2,10
 7d6:	000b2583          	lw	a1,0(s6)
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	e72080e7          	jalr	-398(ra) # 64e <printint>
 7e4:	8b4a                	mv	s6,s2
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	bf85                	j	758 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7ea:	008b0913          	addi	s2,s6,8
 7ee:	4681                	li	a3,0
 7f0:	4641                	li	a2,16
 7f2:	000b2583          	lw	a1,0(s6)
 7f6:	8556                	mv	a0,s5
 7f8:	00000097          	auipc	ra,0x0
 7fc:	e56080e7          	jalr	-426(ra) # 64e <printint>
 800:	8b4a                	mv	s6,s2
      state = 0;
 802:	4981                	li	s3,0
 804:	bf91                	j	758 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 806:	008b0793          	addi	a5,s6,8
 80a:	f8f43423          	sd	a5,-120(s0)
 80e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 812:	03000593          	li	a1,48
 816:	8556                	mv	a0,s5
 818:	00000097          	auipc	ra,0x0
 81c:	e14080e7          	jalr	-492(ra) # 62c <putc>
  putc(fd, 'x');
 820:	85ea                	mv	a1,s10
 822:	8556                	mv	a0,s5
 824:	00000097          	auipc	ra,0x0
 828:	e08080e7          	jalr	-504(ra) # 62c <putc>
 82c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 82e:	03c9d793          	srli	a5,s3,0x3c
 832:	97de                	add	a5,a5,s7
 834:	0007c583          	lbu	a1,0(a5)
 838:	8556                	mv	a0,s5
 83a:	00000097          	auipc	ra,0x0
 83e:	df2080e7          	jalr	-526(ra) # 62c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 842:	0992                	slli	s3,s3,0x4
 844:	397d                	addiw	s2,s2,-1
 846:	fe0914e3          	bnez	s2,82e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 84a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 84e:	4981                	li	s3,0
 850:	b721                	j	758 <vprintf+0x60>
        s = va_arg(ap, char*);
 852:	008b0993          	addi	s3,s6,8
 856:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 85a:	02090163          	beqz	s2,87c <vprintf+0x184>
        while(*s != 0){
 85e:	00094583          	lbu	a1,0(s2)
 862:	c9a1                	beqz	a1,8b2 <vprintf+0x1ba>
          putc(fd, *s);
 864:	8556                	mv	a0,s5
 866:	00000097          	auipc	ra,0x0
 86a:	dc6080e7          	jalr	-570(ra) # 62c <putc>
          s++;
 86e:	0905                	addi	s2,s2,1
        while(*s != 0){
 870:	00094583          	lbu	a1,0(s2)
 874:	f9e5                	bnez	a1,864 <vprintf+0x16c>
        s = va_arg(ap, char*);
 876:	8b4e                	mv	s6,s3
      state = 0;
 878:	4981                	li	s3,0
 87a:	bdf9                	j	758 <vprintf+0x60>
          s = "(null)";
 87c:	00000917          	auipc	s2,0x0
 880:	28c90913          	addi	s2,s2,652 # b08 <malloc+0x146>
        while(*s != 0){
 884:	02800593          	li	a1,40
 888:	bff1                	j	864 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 88a:	008b0913          	addi	s2,s6,8
 88e:	000b4583          	lbu	a1,0(s6)
 892:	8556                	mv	a0,s5
 894:	00000097          	auipc	ra,0x0
 898:	d98080e7          	jalr	-616(ra) # 62c <putc>
 89c:	8b4a                	mv	s6,s2
      state = 0;
 89e:	4981                	li	s3,0
 8a0:	bd65                	j	758 <vprintf+0x60>
        putc(fd, c);
 8a2:	85d2                	mv	a1,s4
 8a4:	8556                	mv	a0,s5
 8a6:	00000097          	auipc	ra,0x0
 8aa:	d86080e7          	jalr	-634(ra) # 62c <putc>
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	b565                	j	758 <vprintf+0x60>
        s = va_arg(ap, char*);
 8b2:	8b4e                	mv	s6,s3
      state = 0;
 8b4:	4981                	li	s3,0
 8b6:	b54d                	j	758 <vprintf+0x60>
    }
  }
}
 8b8:	70e6                	ld	ra,120(sp)
 8ba:	7446                	ld	s0,112(sp)
 8bc:	74a6                	ld	s1,104(sp)
 8be:	7906                	ld	s2,96(sp)
 8c0:	69e6                	ld	s3,88(sp)
 8c2:	6a46                	ld	s4,80(sp)
 8c4:	6aa6                	ld	s5,72(sp)
 8c6:	6b06                	ld	s6,64(sp)
 8c8:	7be2                	ld	s7,56(sp)
 8ca:	7c42                	ld	s8,48(sp)
 8cc:	7ca2                	ld	s9,40(sp)
 8ce:	7d02                	ld	s10,32(sp)
 8d0:	6de2                	ld	s11,24(sp)
 8d2:	6109                	addi	sp,sp,128
 8d4:	8082                	ret

00000000000008d6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8d6:	715d                	addi	sp,sp,-80
 8d8:	ec06                	sd	ra,24(sp)
 8da:	e822                	sd	s0,16(sp)
 8dc:	1000                	addi	s0,sp,32
 8de:	e010                	sd	a2,0(s0)
 8e0:	e414                	sd	a3,8(s0)
 8e2:	e818                	sd	a4,16(s0)
 8e4:	ec1c                	sd	a5,24(s0)
 8e6:	03043023          	sd	a6,32(s0)
 8ea:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8ee:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8f2:	8622                	mv	a2,s0
 8f4:	00000097          	auipc	ra,0x0
 8f8:	e04080e7          	jalr	-508(ra) # 6f8 <vprintf>
}
 8fc:	60e2                	ld	ra,24(sp)
 8fe:	6442                	ld	s0,16(sp)
 900:	6161                	addi	sp,sp,80
 902:	8082                	ret

0000000000000904 <printf>:

void
printf(const char *fmt, ...)
{
 904:	711d                	addi	sp,sp,-96
 906:	ec06                	sd	ra,24(sp)
 908:	e822                	sd	s0,16(sp)
 90a:	1000                	addi	s0,sp,32
 90c:	e40c                	sd	a1,8(s0)
 90e:	e810                	sd	a2,16(s0)
 910:	ec14                	sd	a3,24(s0)
 912:	f018                	sd	a4,32(s0)
 914:	f41c                	sd	a5,40(s0)
 916:	03043823          	sd	a6,48(s0)
 91a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 91e:	00840613          	addi	a2,s0,8
 922:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 926:	85aa                	mv	a1,a0
 928:	4505                	li	a0,1
 92a:	00000097          	auipc	ra,0x0
 92e:	dce080e7          	jalr	-562(ra) # 6f8 <vprintf>
}
 932:	60e2                	ld	ra,24(sp)
 934:	6442                	ld	s0,16(sp)
 936:	6125                	addi	sp,sp,96
 938:	8082                	ret

000000000000093a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 93a:	1141                	addi	sp,sp,-16
 93c:	e422                	sd	s0,8(sp)
 93e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 940:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 944:	00000797          	auipc	a5,0x0
 948:	1e47b783          	ld	a5,484(a5) # b28 <freep>
 94c:	a805                	j	97c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 94e:	4618                	lw	a4,8(a2)
 950:	9db9                	addw	a1,a1,a4
 952:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 956:	6398                	ld	a4,0(a5)
 958:	6318                	ld	a4,0(a4)
 95a:	fee53823          	sd	a4,-16(a0)
 95e:	a091                	j	9a2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 960:	ff852703          	lw	a4,-8(a0)
 964:	9e39                	addw	a2,a2,a4
 966:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 968:	ff053703          	ld	a4,-16(a0)
 96c:	e398                	sd	a4,0(a5)
 96e:	a099                	j	9b4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 970:	6398                	ld	a4,0(a5)
 972:	00e7e463          	bltu	a5,a4,97a <free+0x40>
 976:	00e6ea63          	bltu	a3,a4,98a <free+0x50>
{
 97a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97c:	fed7fae3          	bgeu	a5,a3,970 <free+0x36>
 980:	6398                	ld	a4,0(a5)
 982:	00e6e463          	bltu	a3,a4,98a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 986:	fee7eae3          	bltu	a5,a4,97a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 98a:	ff852583          	lw	a1,-8(a0)
 98e:	6390                	ld	a2,0(a5)
 990:	02059813          	slli	a6,a1,0x20
 994:	01c85713          	srli	a4,a6,0x1c
 998:	9736                	add	a4,a4,a3
 99a:	fae60ae3          	beq	a2,a4,94e <free+0x14>
    bp->s.ptr = p->s.ptr;
 99e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9a2:	4790                	lw	a2,8(a5)
 9a4:	02061593          	slli	a1,a2,0x20
 9a8:	01c5d713          	srli	a4,a1,0x1c
 9ac:	973e                	add	a4,a4,a5
 9ae:	fae689e3          	beq	a3,a4,960 <free+0x26>
  } else
    p->s.ptr = bp;
 9b2:	e394                	sd	a3,0(a5)
  freep = p;
 9b4:	00000717          	auipc	a4,0x0
 9b8:	16f73a23          	sd	a5,372(a4) # b28 <freep>
}
 9bc:	6422                	ld	s0,8(sp)
 9be:	0141                	addi	sp,sp,16
 9c0:	8082                	ret

00000000000009c2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9c2:	7139                	addi	sp,sp,-64
 9c4:	fc06                	sd	ra,56(sp)
 9c6:	f822                	sd	s0,48(sp)
 9c8:	f426                	sd	s1,40(sp)
 9ca:	f04a                	sd	s2,32(sp)
 9cc:	ec4e                	sd	s3,24(sp)
 9ce:	e852                	sd	s4,16(sp)
 9d0:	e456                	sd	s5,8(sp)
 9d2:	e05a                	sd	s6,0(sp)
 9d4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9d6:	02051493          	slli	s1,a0,0x20
 9da:	9081                	srli	s1,s1,0x20
 9dc:	04bd                	addi	s1,s1,15
 9de:	8091                	srli	s1,s1,0x4
 9e0:	0014899b          	addiw	s3,s1,1
 9e4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9e6:	00000517          	auipc	a0,0x0
 9ea:	14253503          	ld	a0,322(a0) # b28 <freep>
 9ee:	c515                	beqz	a0,a1a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f2:	4798                	lw	a4,8(a5)
 9f4:	02977f63          	bgeu	a4,s1,a32 <malloc+0x70>
 9f8:	8a4e                	mv	s4,s3
 9fa:	0009871b          	sext.w	a4,s3
 9fe:	6685                	lui	a3,0x1
 a00:	00d77363          	bgeu	a4,a3,a06 <malloc+0x44>
 a04:	6a05                	lui	s4,0x1
 a06:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a0a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a0e:	00000917          	auipc	s2,0x0
 a12:	11a90913          	addi	s2,s2,282 # b28 <freep>
  if(p == (char*)-1)
 a16:	5afd                	li	s5,-1
 a18:	a895                	j	a8c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a1a:	00000797          	auipc	a5,0x0
 a1e:	11678793          	addi	a5,a5,278 # b30 <base>
 a22:	00000717          	auipc	a4,0x0
 a26:	10f73323          	sd	a5,262(a4) # b28 <freep>
 a2a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a2c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a30:	b7e1                	j	9f8 <malloc+0x36>
      if(p->s.size == nunits)
 a32:	02e48c63          	beq	s1,a4,a6a <malloc+0xa8>
        p->s.size -= nunits;
 a36:	4137073b          	subw	a4,a4,s3
 a3a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a3c:	02071693          	slli	a3,a4,0x20
 a40:	01c6d713          	srli	a4,a3,0x1c
 a44:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a46:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a4a:	00000717          	auipc	a4,0x0
 a4e:	0ca73f23          	sd	a0,222(a4) # b28 <freep>
      return (void*)(p + 1);
 a52:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a56:	70e2                	ld	ra,56(sp)
 a58:	7442                	ld	s0,48(sp)
 a5a:	74a2                	ld	s1,40(sp)
 a5c:	7902                	ld	s2,32(sp)
 a5e:	69e2                	ld	s3,24(sp)
 a60:	6a42                	ld	s4,16(sp)
 a62:	6aa2                	ld	s5,8(sp)
 a64:	6b02                	ld	s6,0(sp)
 a66:	6121                	addi	sp,sp,64
 a68:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a6a:	6398                	ld	a4,0(a5)
 a6c:	e118                	sd	a4,0(a0)
 a6e:	bff1                	j	a4a <malloc+0x88>
  hp->s.size = nu;
 a70:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a74:	0541                	addi	a0,a0,16
 a76:	00000097          	auipc	ra,0x0
 a7a:	ec4080e7          	jalr	-316(ra) # 93a <free>
  return freep;
 a7e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a82:	d971                	beqz	a0,a56 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a84:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a86:	4798                	lw	a4,8(a5)
 a88:	fa9775e3          	bgeu	a4,s1,a32 <malloc+0x70>
    if(p == freep)
 a8c:	00093703          	ld	a4,0(s2)
 a90:	853e                	mv	a0,a5
 a92:	fef719e3          	bne	a4,a5,a84 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a96:	8552                	mv	a0,s4
 a98:	00000097          	auipc	ra,0x0
 a9c:	af0080e7          	jalr	-1296(ra) # 588 <sbrk>
  if(p == (char*)-1)
 aa0:	fd5518e3          	bne	a0,s5,a70 <malloc+0xae>
        return 0;
 aa4:	4501                	li	a0,0
 aa6:	bf45                	j	a56 <malloc+0x94>
