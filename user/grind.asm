
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <__global_pointer$+0x1d40c>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <__global_pointer$+0x2296>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <__global_pointer$+0xffffffffffffd5db>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00001517          	auipc	a0,0x1
      64:	6b850513          	addi	a0,a0,1720 # 1718 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e5e080e7          	jalr	-418(ra) # eee <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	37650513          	addi	a0,a0,886 # 1410 <malloc+0xe8>
      a2:	00001097          	auipc	ra,0x1
      a6:	e2c080e7          	jalr	-468(ra) # ece <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	36650513          	addi	a0,a0,870 # 1410 <malloc+0xe8>
      b2:	00001097          	auipc	ra,0x1
      b6:	e24080e7          	jalr	-476(ra) # ed6 <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	35c50513          	addi	a0,a0,860 # 1418 <malloc+0xf0>
      c4:	00001097          	auipc	ra,0x1
      c8:	1a6080e7          	jalr	422(ra) # 126a <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	d98080e7          	jalr	-616(ra) # e66 <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	36250513          	addi	a0,a0,866 # 1438 <malloc+0x110>
      de:	00001097          	auipc	ra,0x1
      e2:	df8080e7          	jalr	-520(ra) # ed6 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	36298993          	addi	s3,s3,866 # 1448 <malloc+0x120>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	35098993          	addi	s3,s3,848 # 1440 <malloc+0x118>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      fc:	00001a17          	auipc	s4,0x1
     100:	62ca0a13          	addi	s4,s4,1580 # 1728 <buf.0>
     104:	a825                	j	13c <go+0xc4>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	34650513          	addi	a0,a0,838 # 1450 <malloc+0x128>
     112:	00001097          	auipc	ra,0x1
     116:	d94080e7          	jalr	-620(ra) # ea6 <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	d74080e7          	jalr	-652(ra) # e8e <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d52080e7          	jalr	-686(ra) # e86 <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	4789                	li	a5,2
     152:	18f50563          	beq	a0,a5,2dc <go+0x264>
    } else if(what == 3){
     156:	478d                	li	a5,3
     158:	1af50163          	beq	a0,a5,2fa <go+0x282>
    } else if(what == 4){
     15c:	4791                	li	a5,4
     15e:	1af50763          	beq	a0,a5,30c <go+0x294>
    } else if(what == 5){
     162:	4795                	li	a5,5
     164:	1ef50b63          	beq	a0,a5,35a <go+0x2e2>
    } else if(what == 6){
     168:	4799                	li	a5,6
     16a:	20f50963          	beq	a0,a5,37c <go+0x304>
    } else if(what == 7){
     16e:	479d                	li	a5,7
     170:	22f50763          	beq	a0,a5,39e <go+0x326>
    } else if(what == 8){
     174:	47a1                	li	a5,8
     176:	22f50d63          	beq	a0,a5,3b0 <go+0x338>
    } else if(what == 9){
     17a:	47a5                	li	a5,9
     17c:	24f50363          	beq	a0,a5,3c2 <go+0x34a>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     180:	47a9                	li	a5,10
     182:	26f50f63          	beq	a0,a5,400 <go+0x388>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     186:	47ad                	li	a5,11
     188:	2af50b63          	beq	a0,a5,43e <go+0x3c6>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     18c:	47b1                	li	a5,12
     18e:	2cf50d63          	beq	a0,a5,468 <go+0x3f0>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     192:	47b5                	li	a5,13
     194:	2ef50f63          	beq	a0,a5,492 <go+0x41a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     198:	47b9                	li	a5,14
     19a:	32f50a63          	beq	a0,a5,4ce <go+0x456>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     19e:	47bd                	li	a5,15
     1a0:	36f50e63          	beq	a0,a5,51c <go+0x4a4>
      sbrk(6011);
    } else if(what == 16){
     1a4:	47c1                	li	a5,16
     1a6:	38f50363          	beq	a0,a5,52c <go+0x4b4>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1aa:	47c5                	li	a5,17
     1ac:	3af50363          	beq	a0,a5,552 <go+0x4da>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid,SIGKILL);
      wait(0);
    } else if(what == 18){
     1b0:	47c9                	li	a5,18
     1b2:	42f50a63          	beq	a0,a5,5e6 <go+0x56e>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     1b6:	47cd                	li	a5,19
     1b8:	46f50f63          	beq	a0,a5,636 <go+0x5be>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     1bc:	47d1                	li	a5,20
     1be:	56f50063          	beq	a0,a5,71e <go+0x6a6>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     1c2:	47d5                	li	a5,21
     1c4:	5ef50e63          	beq	a0,a5,7c0 <go+0x748>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c8:	47d9                	li	a5,22
     1ca:	f4f51ce3          	bne	a0,a5,122 <go+0xaa>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1ce:	f9840513          	addi	a0,s0,-104
     1d2:	00001097          	auipc	ra,0x1
     1d6:	ca4080e7          	jalr	-860(ra) # e76 <pipe>
     1da:	6e054763          	bltz	a0,8c8 <go+0x850>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1de:	fa040513          	addi	a0,s0,-96
     1e2:	00001097          	auipc	ra,0x1
     1e6:	c94080e7          	jalr	-876(ra) # e76 <pipe>
     1ea:	6e054d63          	bltz	a0,8e4 <go+0x86c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ee:	00001097          	auipc	ra,0x1
     1f2:	c70080e7          	jalr	-912(ra) # e5e <fork>
      if(pid1 == 0){
     1f6:	70050563          	beqz	a0,900 <go+0x888>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1fa:	7a054d63          	bltz	a0,9b4 <go+0x93c>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	c60080e7          	jalr	-928(ra) # e5e <fork>
      if(pid2 == 0){
     206:	7c050563          	beqz	a0,9d0 <go+0x958>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     20a:	0a0541e3          	bltz	a0,aac <go+0xa34>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20e:	f9842503          	lw	a0,-104(s0)
     212:	00001097          	auipc	ra,0x1
     216:	c7c080e7          	jalr	-900(ra) # e8e <close>
      close(aa[1]);
     21a:	f9c42503          	lw	a0,-100(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	c70080e7          	jalr	-912(ra) # e8e <close>
      close(bb[1]);
     226:	fa442503          	lw	a0,-92(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	c64080e7          	jalr	-924(ra) # e8e <close>
      char buf[4] = { 0, 0, 0, 0 };
     232:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     236:	4605                	li	a2,1
     238:	f9040593          	addi	a1,s0,-112
     23c:	fa042503          	lw	a0,-96(s0)
     240:	00001097          	auipc	ra,0x1
     244:	c3e080e7          	jalr	-962(ra) # e7e <read>
      read(bb[0], buf+1, 1);
     248:	4605                	li	a2,1
     24a:	f9140593          	addi	a1,s0,-111
     24e:	fa042503          	lw	a0,-96(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c2c080e7          	jalr	-980(ra) # e7e <read>
      read(bb[0], buf+2, 1);
     25a:	4605                	li	a2,1
     25c:	f9240593          	addi	a1,s0,-110
     260:	fa042503          	lw	a0,-96(s0)
     264:	00001097          	auipc	ra,0x1
     268:	c1a080e7          	jalr	-998(ra) # e7e <read>
      close(bb[0]);
     26c:	fa042503          	lw	a0,-96(s0)
     270:	00001097          	auipc	ra,0x1
     274:	c1e080e7          	jalr	-994(ra) # e8e <close>
      int st1, st2;
      wait(&st1);
     278:	f9440513          	addi	a0,s0,-108
     27c:	00001097          	auipc	ra,0x1
     280:	bf2080e7          	jalr	-1038(ra) # e6e <wait>
      wait(&st2);
     284:	fa840513          	addi	a0,s0,-88
     288:	00001097          	auipc	ra,0x1
     28c:	be6080e7          	jalr	-1050(ra) # e6e <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     290:	f9442783          	lw	a5,-108(s0)
     294:	fa842703          	lw	a4,-88(s0)
     298:	8fd9                	or	a5,a5,a4
     29a:	2781                	sext.w	a5,a5
     29c:	ef89                	bnez	a5,2b6 <go+0x23e>
     29e:	00001597          	auipc	a1,0x1
     2a2:	42a58593          	addi	a1,a1,1066 # 16c8 <malloc+0x3a0>
     2a6:	f9040513          	addi	a0,s0,-112
     2aa:	00001097          	auipc	ra,0x1
     2ae:	96a080e7          	jalr	-1686(ra) # c14 <strcmp>
     2b2:	e60508e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2b6:	f9040693          	addi	a3,s0,-112
     2ba:	fa842603          	lw	a2,-88(s0)
     2be:	f9442583          	lw	a1,-108(s0)
     2c2:	00001517          	auipc	a0,0x1
     2c6:	40e50513          	addi	a0,a0,1038 # 16d0 <malloc+0x3a8>
     2ca:	00001097          	auipc	ra,0x1
     2ce:	fa0080e7          	jalr	-96(ra) # 126a <printf>
        exit(1);
     2d2:	4505                	li	a0,1
     2d4:	00001097          	auipc	ra,0x1
     2d8:	b92080e7          	jalr	-1134(ra) # e66 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2dc:	20200593          	li	a1,514
     2e0:	00001517          	auipc	a0,0x1
     2e4:	18050513          	addi	a0,a0,384 # 1460 <malloc+0x138>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bbe080e7          	jalr	-1090(ra) # ea6 <open>
     2f0:	00001097          	auipc	ra,0x1
     2f4:	b9e080e7          	jalr	-1122(ra) # e8e <close>
     2f8:	b52d                	j	122 <go+0xaa>
      unlink("grindir/../a");
     2fa:	00001517          	auipc	a0,0x1
     2fe:	15650513          	addi	a0,a0,342 # 1450 <malloc+0x128>
     302:	00001097          	auipc	ra,0x1
     306:	bb4080e7          	jalr	-1100(ra) # eb6 <unlink>
     30a:	bd21                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     30c:	00001517          	auipc	a0,0x1
     310:	10450513          	addi	a0,a0,260 # 1410 <malloc+0xe8>
     314:	00001097          	auipc	ra,0x1
     318:	bc2080e7          	jalr	-1086(ra) # ed6 <chdir>
     31c:	e115                	bnez	a0,340 <go+0x2c8>
      unlink("../b");
     31e:	00001517          	auipc	a0,0x1
     322:	15a50513          	addi	a0,a0,346 # 1478 <malloc+0x150>
     326:	00001097          	auipc	ra,0x1
     32a:	b90080e7          	jalr	-1136(ra) # eb6 <unlink>
      chdir("/");
     32e:	00001517          	auipc	a0,0x1
     332:	10a50513          	addi	a0,a0,266 # 1438 <malloc+0x110>
     336:	00001097          	auipc	ra,0x1
     33a:	ba0080e7          	jalr	-1120(ra) # ed6 <chdir>
     33e:	b3d5                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     340:	00001517          	auipc	a0,0x1
     344:	0d850513          	addi	a0,a0,216 # 1418 <malloc+0xf0>
     348:	00001097          	auipc	ra,0x1
     34c:	f22080e7          	jalr	-222(ra) # 126a <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00001097          	auipc	ra,0x1
     356:	b14080e7          	jalr	-1260(ra) # e66 <exit>
      close(fd);
     35a:	854a                	mv	a0,s2
     35c:	00001097          	auipc	ra,0x1
     360:	b32080e7          	jalr	-1230(ra) # e8e <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     364:	20200593          	li	a1,514
     368:	00001517          	auipc	a0,0x1
     36c:	11850513          	addi	a0,a0,280 # 1480 <malloc+0x158>
     370:	00001097          	auipc	ra,0x1
     374:	b36080e7          	jalr	-1226(ra) # ea6 <open>
     378:	892a                	mv	s2,a0
     37a:	b365                	j	122 <go+0xaa>
      close(fd);
     37c:	854a                	mv	a0,s2
     37e:	00001097          	auipc	ra,0x1
     382:	b10080e7          	jalr	-1264(ra) # e8e <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     386:	20200593          	li	a1,514
     38a:	00001517          	auipc	a0,0x1
     38e:	10650513          	addi	a0,a0,262 # 1490 <malloc+0x168>
     392:	00001097          	auipc	ra,0x1
     396:	b14080e7          	jalr	-1260(ra) # ea6 <open>
     39a:	892a                	mv	s2,a0
     39c:	b359                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     39e:	3e700613          	li	a2,999
     3a2:	85d2                	mv	a1,s4
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	ae0080e7          	jalr	-1312(ra) # e86 <write>
     3ae:	bb95                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3b0:	3e700613          	li	a2,999
     3b4:	85d2                	mv	a1,s4
     3b6:	854a                	mv	a0,s2
     3b8:	00001097          	auipc	ra,0x1
     3bc:	ac6080e7          	jalr	-1338(ra) # e7e <read>
     3c0:	b38d                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3c2:	00001517          	auipc	a0,0x1
     3c6:	08e50513          	addi	a0,a0,142 # 1450 <malloc+0x128>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	b04080e7          	jalr	-1276(ra) # ece <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3d2:	20200593          	li	a1,514
     3d6:	00001517          	auipc	a0,0x1
     3da:	0d250513          	addi	a0,a0,210 # 14a8 <malloc+0x180>
     3de:	00001097          	auipc	ra,0x1
     3e2:	ac8080e7          	jalr	-1336(ra) # ea6 <open>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	aa8080e7          	jalr	-1368(ra) # e8e <close>
      unlink("a/a");
     3ee:	00001517          	auipc	a0,0x1
     3f2:	0ca50513          	addi	a0,a0,202 # 14b8 <malloc+0x190>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	ac0080e7          	jalr	-1344(ra) # eb6 <unlink>
     3fe:	b315                	j	122 <go+0xaa>
      mkdir("/../b");
     400:	00001517          	auipc	a0,0x1
     404:	0c050513          	addi	a0,a0,192 # 14c0 <malloc+0x198>
     408:	00001097          	auipc	ra,0x1
     40c:	ac6080e7          	jalr	-1338(ra) # ece <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     410:	20200593          	li	a1,514
     414:	00001517          	auipc	a0,0x1
     418:	0b450513          	addi	a0,a0,180 # 14c8 <malloc+0x1a0>
     41c:	00001097          	auipc	ra,0x1
     420:	a8a080e7          	jalr	-1398(ra) # ea6 <open>
     424:	00001097          	auipc	ra,0x1
     428:	a6a080e7          	jalr	-1430(ra) # e8e <close>
      unlink("b/b");
     42c:	00001517          	auipc	a0,0x1
     430:	0ac50513          	addi	a0,a0,172 # 14d8 <malloc+0x1b0>
     434:	00001097          	auipc	ra,0x1
     438:	a82080e7          	jalr	-1406(ra) # eb6 <unlink>
     43c:	b1dd                	j	122 <go+0xaa>
      unlink("b");
     43e:	00001517          	auipc	a0,0x1
     442:	06250513          	addi	a0,a0,98 # 14a0 <malloc+0x178>
     446:	00001097          	auipc	ra,0x1
     44a:	a70080e7          	jalr	-1424(ra) # eb6 <unlink>
      link("../grindir/./../a", "../b");
     44e:	00001597          	auipc	a1,0x1
     452:	02a58593          	addi	a1,a1,42 # 1478 <malloc+0x150>
     456:	00001517          	auipc	a0,0x1
     45a:	08a50513          	addi	a0,a0,138 # 14e0 <malloc+0x1b8>
     45e:	00001097          	auipc	ra,0x1
     462:	a68080e7          	jalr	-1432(ra) # ec6 <link>
     466:	b975                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     468:	00001517          	auipc	a0,0x1
     46c:	09050513          	addi	a0,a0,144 # 14f8 <malloc+0x1d0>
     470:	00001097          	auipc	ra,0x1
     474:	a46080e7          	jalr	-1466(ra) # eb6 <unlink>
      link(".././b", "/grindir/../a");
     478:	00001597          	auipc	a1,0x1
     47c:	00858593          	addi	a1,a1,8 # 1480 <malloc+0x158>
     480:	00001517          	auipc	a0,0x1
     484:	08850513          	addi	a0,a0,136 # 1508 <malloc+0x1e0>
     488:	00001097          	auipc	ra,0x1
     48c:	a3e080e7          	jalr	-1474(ra) # ec6 <link>
     490:	b949                	j	122 <go+0xaa>
      int pid = fork();
     492:	00001097          	auipc	ra,0x1
     496:	9cc080e7          	jalr	-1588(ra) # e5e <fork>
      if(pid == 0){
     49a:	c909                	beqz	a0,4ac <go+0x434>
      } else if(pid < 0){
     49c:	00054c63          	bltz	a0,4b4 <go+0x43c>
      wait(0);
     4a0:	4501                	li	a0,0
     4a2:	00001097          	auipc	ra,0x1
     4a6:	9cc080e7          	jalr	-1588(ra) # e6e <wait>
     4aa:	b9a5                	j	122 <go+0xaa>
        exit(0);
     4ac:	00001097          	auipc	ra,0x1
     4b0:	9ba080e7          	jalr	-1606(ra) # e66 <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	05c50513          	addi	a0,a0,92 # 1510 <malloc+0x1e8>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	dae080e7          	jalr	-594(ra) # 126a <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	9a0080e7          	jalr	-1632(ra) # e66 <exit>
      int pid = fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	990080e7          	jalr	-1648(ra) # e5e <fork>
      if(pid == 0){
     4d6:	c909                	beqz	a0,4e8 <go+0x470>
      } else if(pid < 0){
     4d8:	02054563          	bltz	a0,502 <go+0x48a>
      wait(0);
     4dc:	4501                	li	a0,0
     4de:	00001097          	auipc	ra,0x1
     4e2:	990080e7          	jalr	-1648(ra) # e6e <wait>
     4e6:	b935                	j	122 <go+0xaa>
        fork();
     4e8:	00001097          	auipc	ra,0x1
     4ec:	976080e7          	jalr	-1674(ra) # e5e <fork>
        fork();
     4f0:	00001097          	auipc	ra,0x1
     4f4:	96e080e7          	jalr	-1682(ra) # e5e <fork>
        exit(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	96c080e7          	jalr	-1684(ra) # e66 <exit>
        printf("grind: fork failed\n");
     502:	00001517          	auipc	a0,0x1
     506:	00e50513          	addi	a0,a0,14 # 1510 <malloc+0x1e8>
     50a:	00001097          	auipc	ra,0x1
     50e:	d60080e7          	jalr	-672(ra) # 126a <printf>
        exit(1);
     512:	4505                	li	a0,1
     514:	00001097          	auipc	ra,0x1
     518:	952080e7          	jalr	-1710(ra) # e66 <exit>
      sbrk(6011);
     51c:	6505                	lui	a0,0x1
     51e:	77b50513          	addi	a0,a0,1915 # 177b <buf.0+0x53>
     522:	00001097          	auipc	ra,0x1
     526:	9cc080e7          	jalr	-1588(ra) # eee <sbrk>
     52a:	bee5                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     52c:	4501                	li	a0,0
     52e:	00001097          	auipc	ra,0x1
     532:	9c0080e7          	jalr	-1600(ra) # eee <sbrk>
     536:	beaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     53a:	4501                	li	a0,0
     53c:	00001097          	auipc	ra,0x1
     540:	9b2080e7          	jalr	-1614(ra) # eee <sbrk>
     544:	40aa853b          	subw	a0,s5,a0
     548:	00001097          	auipc	ra,0x1
     54c:	9a6080e7          	jalr	-1626(ra) # eee <sbrk>
     550:	bec9                	j	122 <go+0xaa>
      int pid = fork();
     552:	00001097          	auipc	ra,0x1
     556:	90c080e7          	jalr	-1780(ra) # e5e <fork>
     55a:	8b2a                	mv	s6,a0
      if(pid == 0){
     55c:	c905                	beqz	a0,58c <go+0x514>
      } else if(pid < 0){
     55e:	04054a63          	bltz	a0,5b2 <go+0x53a>
      if(chdir("../grindir/..") != 0){
     562:	00001517          	auipc	a0,0x1
     566:	fc650513          	addi	a0,a0,-58 # 1528 <malloc+0x200>
     56a:	00001097          	auipc	ra,0x1
     56e:	96c080e7          	jalr	-1684(ra) # ed6 <chdir>
     572:	ed29                	bnez	a0,5cc <go+0x554>
      kill(pid,SIGKILL);
     574:	45a5                	li	a1,9
     576:	855a                	mv	a0,s6
     578:	00001097          	auipc	ra,0x1
     57c:	91e080e7          	jalr	-1762(ra) # e96 <kill>
      wait(0);
     580:	4501                	li	a0,0
     582:	00001097          	auipc	ra,0x1
     586:	8ec080e7          	jalr	-1812(ra) # e6e <wait>
     58a:	be61                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     58c:	20200593          	li	a1,514
     590:	00001517          	auipc	a0,0x1
     594:	f6050513          	addi	a0,a0,-160 # 14f0 <malloc+0x1c8>
     598:	00001097          	auipc	ra,0x1
     59c:	90e080e7          	jalr	-1778(ra) # ea6 <open>
     5a0:	00001097          	auipc	ra,0x1
     5a4:	8ee080e7          	jalr	-1810(ra) # e8e <close>
        exit(0);
     5a8:	4501                	li	a0,0
     5aa:	00001097          	auipc	ra,0x1
     5ae:	8bc080e7          	jalr	-1860(ra) # e66 <exit>
        printf("grind: fork failed\n");
     5b2:	00001517          	auipc	a0,0x1
     5b6:	f5e50513          	addi	a0,a0,-162 # 1510 <malloc+0x1e8>
     5ba:	00001097          	auipc	ra,0x1
     5be:	cb0080e7          	jalr	-848(ra) # 126a <printf>
        exit(1);
     5c2:	4505                	li	a0,1
     5c4:	00001097          	auipc	ra,0x1
     5c8:	8a2080e7          	jalr	-1886(ra) # e66 <exit>
        printf("grind: chdir failed\n");
     5cc:	00001517          	auipc	a0,0x1
     5d0:	f6c50513          	addi	a0,a0,-148 # 1538 <malloc+0x210>
     5d4:	00001097          	auipc	ra,0x1
     5d8:	c96080e7          	jalr	-874(ra) # 126a <printf>
        exit(1);
     5dc:	4505                	li	a0,1
     5de:	00001097          	auipc	ra,0x1
     5e2:	888080e7          	jalr	-1912(ra) # e66 <exit>
      int pid = fork();
     5e6:	00001097          	auipc	ra,0x1
     5ea:	878080e7          	jalr	-1928(ra) # e5e <fork>
      if(pid == 0){
     5ee:	c909                	beqz	a0,600 <go+0x588>
      } else if(pid < 0){
     5f0:	02054663          	bltz	a0,61c <go+0x5a4>
      wait(0);
     5f4:	4501                	li	a0,0
     5f6:	00001097          	auipc	ra,0x1
     5fa:	878080e7          	jalr	-1928(ra) # e6e <wait>
     5fe:	b615                	j	122 <go+0xaa>
        kill(getpid(),SIGKILL);
     600:	00001097          	auipc	ra,0x1
     604:	8e6080e7          	jalr	-1818(ra) # ee6 <getpid>
     608:	45a5                	li	a1,9
     60a:	00001097          	auipc	ra,0x1
     60e:	88c080e7          	jalr	-1908(ra) # e96 <kill>
        exit(0);
     612:	4501                	li	a0,0
     614:	00001097          	auipc	ra,0x1
     618:	852080e7          	jalr	-1966(ra) # e66 <exit>
        printf("grind: fork failed\n");
     61c:	00001517          	auipc	a0,0x1
     620:	ef450513          	addi	a0,a0,-268 # 1510 <malloc+0x1e8>
     624:	00001097          	auipc	ra,0x1
     628:	c46080e7          	jalr	-954(ra) # 126a <printf>
        exit(1);
     62c:	4505                	li	a0,1
     62e:	00001097          	auipc	ra,0x1
     632:	838080e7          	jalr	-1992(ra) # e66 <exit>
      if(pipe(fds) < 0){
     636:	fa840513          	addi	a0,s0,-88
     63a:	00001097          	auipc	ra,0x1
     63e:	83c080e7          	jalr	-1988(ra) # e76 <pipe>
     642:	02054b63          	bltz	a0,678 <go+0x600>
      int pid = fork();
     646:	00001097          	auipc	ra,0x1
     64a:	818080e7          	jalr	-2024(ra) # e5e <fork>
      if(pid == 0){
     64e:	c131                	beqz	a0,692 <go+0x61a>
      } else if(pid < 0){
     650:	0a054a63          	bltz	a0,704 <go+0x68c>
      close(fds[0]);
     654:	fa842503          	lw	a0,-88(s0)
     658:	00001097          	auipc	ra,0x1
     65c:	836080e7          	jalr	-1994(ra) # e8e <close>
      close(fds[1]);
     660:	fac42503          	lw	a0,-84(s0)
     664:	00001097          	auipc	ra,0x1
     668:	82a080e7          	jalr	-2006(ra) # e8e <close>
      wait(0);
     66c:	4501                	li	a0,0
     66e:	00001097          	auipc	ra,0x1
     672:	800080e7          	jalr	-2048(ra) # e6e <wait>
     676:	b475                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     678:	00001517          	auipc	a0,0x1
     67c:	ed850513          	addi	a0,a0,-296 # 1550 <malloc+0x228>
     680:	00001097          	auipc	ra,0x1
     684:	bea080e7          	jalr	-1046(ra) # 126a <printf>
        exit(1);
     688:	4505                	li	a0,1
     68a:	00000097          	auipc	ra,0x0
     68e:	7dc080e7          	jalr	2012(ra) # e66 <exit>
        fork();
     692:	00000097          	auipc	ra,0x0
     696:	7cc080e7          	jalr	1996(ra) # e5e <fork>
        fork();
     69a:	00000097          	auipc	ra,0x0
     69e:	7c4080e7          	jalr	1988(ra) # e5e <fork>
        if(write(fds[1], "x", 1) != 1)
     6a2:	4605                	li	a2,1
     6a4:	00001597          	auipc	a1,0x1
     6a8:	ec458593          	addi	a1,a1,-316 # 1568 <malloc+0x240>
     6ac:	fac42503          	lw	a0,-84(s0)
     6b0:	00000097          	auipc	ra,0x0
     6b4:	7d6080e7          	jalr	2006(ra) # e86 <write>
     6b8:	4785                	li	a5,1
     6ba:	02f51363          	bne	a0,a5,6e0 <go+0x668>
        if(read(fds[0], &c, 1) != 1)
     6be:	4605                	li	a2,1
     6c0:	fa040593          	addi	a1,s0,-96
     6c4:	fa842503          	lw	a0,-88(s0)
     6c8:	00000097          	auipc	ra,0x0
     6cc:	7b6080e7          	jalr	1974(ra) # e7e <read>
     6d0:	4785                	li	a5,1
     6d2:	02f51063          	bne	a0,a5,6f2 <go+0x67a>
        exit(0);
     6d6:	4501                	li	a0,0
     6d8:	00000097          	auipc	ra,0x0
     6dc:	78e080e7          	jalr	1934(ra) # e66 <exit>
          printf("grind: pipe write failed\n");
     6e0:	00001517          	auipc	a0,0x1
     6e4:	e9050513          	addi	a0,a0,-368 # 1570 <malloc+0x248>
     6e8:	00001097          	auipc	ra,0x1
     6ec:	b82080e7          	jalr	-1150(ra) # 126a <printf>
     6f0:	b7f9                	j	6be <go+0x646>
          printf("grind: pipe read failed\n");
     6f2:	00001517          	auipc	a0,0x1
     6f6:	e9e50513          	addi	a0,a0,-354 # 1590 <malloc+0x268>
     6fa:	00001097          	auipc	ra,0x1
     6fe:	b70080e7          	jalr	-1168(ra) # 126a <printf>
     702:	bfd1                	j	6d6 <go+0x65e>
        printf("grind: fork failed\n");
     704:	00001517          	auipc	a0,0x1
     708:	e0c50513          	addi	a0,a0,-500 # 1510 <malloc+0x1e8>
     70c:	00001097          	auipc	ra,0x1
     710:	b5e080e7          	jalr	-1186(ra) # 126a <printf>
        exit(1);
     714:	4505                	li	a0,1
     716:	00000097          	auipc	ra,0x0
     71a:	750080e7          	jalr	1872(ra) # e66 <exit>
      int pid = fork();
     71e:	00000097          	auipc	ra,0x0
     722:	740080e7          	jalr	1856(ra) # e5e <fork>
      if(pid == 0){
     726:	c909                	beqz	a0,738 <go+0x6c0>
      } else if(pid < 0){
     728:	06054f63          	bltz	a0,7a6 <go+0x72e>
      wait(0);
     72c:	4501                	li	a0,0
     72e:	00000097          	auipc	ra,0x0
     732:	740080e7          	jalr	1856(ra) # e6e <wait>
     736:	b2f5                	j	122 <go+0xaa>
        unlink("a");
     738:	00001517          	auipc	a0,0x1
     73c:	db850513          	addi	a0,a0,-584 # 14f0 <malloc+0x1c8>
     740:	00000097          	auipc	ra,0x0
     744:	776080e7          	jalr	1910(ra) # eb6 <unlink>
        mkdir("a");
     748:	00001517          	auipc	a0,0x1
     74c:	da850513          	addi	a0,a0,-600 # 14f0 <malloc+0x1c8>
     750:	00000097          	auipc	ra,0x0
     754:	77e080e7          	jalr	1918(ra) # ece <mkdir>
        chdir("a");
     758:	00001517          	auipc	a0,0x1
     75c:	d9850513          	addi	a0,a0,-616 # 14f0 <malloc+0x1c8>
     760:	00000097          	auipc	ra,0x0
     764:	776080e7          	jalr	1910(ra) # ed6 <chdir>
        unlink("../a");
     768:	00001517          	auipc	a0,0x1
     76c:	cf050513          	addi	a0,a0,-784 # 1458 <malloc+0x130>
     770:	00000097          	auipc	ra,0x0
     774:	746080e7          	jalr	1862(ra) # eb6 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     778:	20200593          	li	a1,514
     77c:	00001517          	auipc	a0,0x1
     780:	dec50513          	addi	a0,a0,-532 # 1568 <malloc+0x240>
     784:	00000097          	auipc	ra,0x0
     788:	722080e7          	jalr	1826(ra) # ea6 <open>
        unlink("x");
     78c:	00001517          	auipc	a0,0x1
     790:	ddc50513          	addi	a0,a0,-548 # 1568 <malloc+0x240>
     794:	00000097          	auipc	ra,0x0
     798:	722080e7          	jalr	1826(ra) # eb6 <unlink>
        exit(0);
     79c:	4501                	li	a0,0
     79e:	00000097          	auipc	ra,0x0
     7a2:	6c8080e7          	jalr	1736(ra) # e66 <exit>
        printf("grind: fork failed\n");
     7a6:	00001517          	auipc	a0,0x1
     7aa:	d6a50513          	addi	a0,a0,-662 # 1510 <malloc+0x1e8>
     7ae:	00001097          	auipc	ra,0x1
     7b2:	abc080e7          	jalr	-1348(ra) # 126a <printf>
        exit(1);
     7b6:	4505                	li	a0,1
     7b8:	00000097          	auipc	ra,0x0
     7bc:	6ae080e7          	jalr	1710(ra) # e66 <exit>
      unlink("c");
     7c0:	00001517          	auipc	a0,0x1
     7c4:	df050513          	addi	a0,a0,-528 # 15b0 <malloc+0x288>
     7c8:	00000097          	auipc	ra,0x0
     7cc:	6ee080e7          	jalr	1774(ra) # eb6 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7d0:	20200593          	li	a1,514
     7d4:	00001517          	auipc	a0,0x1
     7d8:	ddc50513          	addi	a0,a0,-548 # 15b0 <malloc+0x288>
     7dc:	00000097          	auipc	ra,0x0
     7e0:	6ca080e7          	jalr	1738(ra) # ea6 <open>
     7e4:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7e6:	04054f63          	bltz	a0,844 <go+0x7cc>
      if(write(fd1, "x", 1) != 1){
     7ea:	4605                	li	a2,1
     7ec:	00001597          	auipc	a1,0x1
     7f0:	d7c58593          	addi	a1,a1,-644 # 1568 <malloc+0x240>
     7f4:	00000097          	auipc	ra,0x0
     7f8:	692080e7          	jalr	1682(ra) # e86 <write>
     7fc:	4785                	li	a5,1
     7fe:	06f51063          	bne	a0,a5,85e <go+0x7e6>
      if(fstat(fd1, &st) != 0){
     802:	fa840593          	addi	a1,s0,-88
     806:	855a                	mv	a0,s6
     808:	00000097          	auipc	ra,0x0
     80c:	6b6080e7          	jalr	1718(ra) # ebe <fstat>
     810:	e525                	bnez	a0,878 <go+0x800>
      if(st.size != 1){
     812:	fb843583          	ld	a1,-72(s0)
     816:	4785                	li	a5,1
     818:	06f59d63          	bne	a1,a5,892 <go+0x81a>
      if(st.ino > 200){
     81c:	fac42583          	lw	a1,-84(s0)
     820:	0c800793          	li	a5,200
     824:	08b7e563          	bltu	a5,a1,8ae <go+0x836>
      close(fd1);
     828:	855a                	mv	a0,s6
     82a:	00000097          	auipc	ra,0x0
     82e:	664080e7          	jalr	1636(ra) # e8e <close>
      unlink("c");
     832:	00001517          	auipc	a0,0x1
     836:	d7e50513          	addi	a0,a0,-642 # 15b0 <malloc+0x288>
     83a:	00000097          	auipc	ra,0x0
     83e:	67c080e7          	jalr	1660(ra) # eb6 <unlink>
     842:	b0c5                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     844:	00001517          	auipc	a0,0x1
     848:	d7450513          	addi	a0,a0,-652 # 15b8 <malloc+0x290>
     84c:	00001097          	auipc	ra,0x1
     850:	a1e080e7          	jalr	-1506(ra) # 126a <printf>
        exit(1);
     854:	4505                	li	a0,1
     856:	00000097          	auipc	ra,0x0
     85a:	610080e7          	jalr	1552(ra) # e66 <exit>
        printf("grind: write c failed\n");
     85e:	00001517          	auipc	a0,0x1
     862:	d7250513          	addi	a0,a0,-654 # 15d0 <malloc+0x2a8>
     866:	00001097          	auipc	ra,0x1
     86a:	a04080e7          	jalr	-1532(ra) # 126a <printf>
        exit(1);
     86e:	4505                	li	a0,1
     870:	00000097          	auipc	ra,0x0
     874:	5f6080e7          	jalr	1526(ra) # e66 <exit>
        printf("grind: fstat failed\n");
     878:	00001517          	auipc	a0,0x1
     87c:	d7050513          	addi	a0,a0,-656 # 15e8 <malloc+0x2c0>
     880:	00001097          	auipc	ra,0x1
     884:	9ea080e7          	jalr	-1558(ra) # 126a <printf>
        exit(1);
     888:	4505                	li	a0,1
     88a:	00000097          	auipc	ra,0x0
     88e:	5dc080e7          	jalr	1500(ra) # e66 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     892:	2581                	sext.w	a1,a1
     894:	00001517          	auipc	a0,0x1
     898:	d6c50513          	addi	a0,a0,-660 # 1600 <malloc+0x2d8>
     89c:	00001097          	auipc	ra,0x1
     8a0:	9ce080e7          	jalr	-1586(ra) # 126a <printf>
        exit(1);
     8a4:	4505                	li	a0,1
     8a6:	00000097          	auipc	ra,0x0
     8aa:	5c0080e7          	jalr	1472(ra) # e66 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8ae:	00001517          	auipc	a0,0x1
     8b2:	d7a50513          	addi	a0,a0,-646 # 1628 <malloc+0x300>
     8b6:	00001097          	auipc	ra,0x1
     8ba:	9b4080e7          	jalr	-1612(ra) # 126a <printf>
        exit(1);
     8be:	4505                	li	a0,1
     8c0:	00000097          	auipc	ra,0x0
     8c4:	5a6080e7          	jalr	1446(ra) # e66 <exit>
        fprintf(2, "grind: pipe failed\n");
     8c8:	00001597          	auipc	a1,0x1
     8cc:	c8858593          	addi	a1,a1,-888 # 1550 <malloc+0x228>
     8d0:	4509                	li	a0,2
     8d2:	00001097          	auipc	ra,0x1
     8d6:	96a080e7          	jalr	-1686(ra) # 123c <fprintf>
        exit(1);
     8da:	4505                	li	a0,1
     8dc:	00000097          	auipc	ra,0x0
     8e0:	58a080e7          	jalr	1418(ra) # e66 <exit>
        fprintf(2, "grind: pipe failed\n");
     8e4:	00001597          	auipc	a1,0x1
     8e8:	c6c58593          	addi	a1,a1,-916 # 1550 <malloc+0x228>
     8ec:	4509                	li	a0,2
     8ee:	00001097          	auipc	ra,0x1
     8f2:	94e080e7          	jalr	-1714(ra) # 123c <fprintf>
        exit(1);
     8f6:	4505                	li	a0,1
     8f8:	00000097          	auipc	ra,0x0
     8fc:	56e080e7          	jalr	1390(ra) # e66 <exit>
        close(bb[0]);
     900:	fa042503          	lw	a0,-96(s0)
     904:	00000097          	auipc	ra,0x0
     908:	58a080e7          	jalr	1418(ra) # e8e <close>
        close(bb[1]);
     90c:	fa442503          	lw	a0,-92(s0)
     910:	00000097          	auipc	ra,0x0
     914:	57e080e7          	jalr	1406(ra) # e8e <close>
        close(aa[0]);
     918:	f9842503          	lw	a0,-104(s0)
     91c:	00000097          	auipc	ra,0x0
     920:	572080e7          	jalr	1394(ra) # e8e <close>
        close(1);
     924:	4505                	li	a0,1
     926:	00000097          	auipc	ra,0x0
     92a:	568080e7          	jalr	1384(ra) # e8e <close>
        if(dup(aa[1]) != 1){
     92e:	f9c42503          	lw	a0,-100(s0)
     932:	00000097          	auipc	ra,0x0
     936:	5ac080e7          	jalr	1452(ra) # ede <dup>
     93a:	4785                	li	a5,1
     93c:	02f50063          	beq	a0,a5,95c <go+0x8e4>
          fprintf(2, "grind: dup failed\n");
     940:	00001597          	auipc	a1,0x1
     944:	d1058593          	addi	a1,a1,-752 # 1650 <malloc+0x328>
     948:	4509                	li	a0,2
     94a:	00001097          	auipc	ra,0x1
     94e:	8f2080e7          	jalr	-1806(ra) # 123c <fprintf>
          exit(1);
     952:	4505                	li	a0,1
     954:	00000097          	auipc	ra,0x0
     958:	512080e7          	jalr	1298(ra) # e66 <exit>
        close(aa[1]);
     95c:	f9c42503          	lw	a0,-100(s0)
     960:	00000097          	auipc	ra,0x0
     964:	52e080e7          	jalr	1326(ra) # e8e <close>
        char *args[3] = { "echo", "hi", 0 };
     968:	00001797          	auipc	a5,0x1
     96c:	d0078793          	addi	a5,a5,-768 # 1668 <malloc+0x340>
     970:	faf43423          	sd	a5,-88(s0)
     974:	00001797          	auipc	a5,0x1
     978:	cfc78793          	addi	a5,a5,-772 # 1670 <malloc+0x348>
     97c:	faf43823          	sd	a5,-80(s0)
     980:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     984:	fa840593          	addi	a1,s0,-88
     988:	00001517          	auipc	a0,0x1
     98c:	cf050513          	addi	a0,a0,-784 # 1678 <malloc+0x350>
     990:	00000097          	auipc	ra,0x0
     994:	50e080e7          	jalr	1294(ra) # e9e <exec>
        fprintf(2, "grind: echo: not found\n");
     998:	00001597          	auipc	a1,0x1
     99c:	cf058593          	addi	a1,a1,-784 # 1688 <malloc+0x360>
     9a0:	4509                	li	a0,2
     9a2:	00001097          	auipc	ra,0x1
     9a6:	89a080e7          	jalr	-1894(ra) # 123c <fprintf>
        exit(2);
     9aa:	4509                	li	a0,2
     9ac:	00000097          	auipc	ra,0x0
     9b0:	4ba080e7          	jalr	1210(ra) # e66 <exit>
        fprintf(2, "grind: fork failed\n");
     9b4:	00001597          	auipc	a1,0x1
     9b8:	b5c58593          	addi	a1,a1,-1188 # 1510 <malloc+0x1e8>
     9bc:	4509                	li	a0,2
     9be:	00001097          	auipc	ra,0x1
     9c2:	87e080e7          	jalr	-1922(ra) # 123c <fprintf>
        exit(3);
     9c6:	450d                	li	a0,3
     9c8:	00000097          	auipc	ra,0x0
     9cc:	49e080e7          	jalr	1182(ra) # e66 <exit>
        close(aa[1]);
     9d0:	f9c42503          	lw	a0,-100(s0)
     9d4:	00000097          	auipc	ra,0x0
     9d8:	4ba080e7          	jalr	1210(ra) # e8e <close>
        close(bb[0]);
     9dc:	fa042503          	lw	a0,-96(s0)
     9e0:	00000097          	auipc	ra,0x0
     9e4:	4ae080e7          	jalr	1198(ra) # e8e <close>
        close(0);
     9e8:	4501                	li	a0,0
     9ea:	00000097          	auipc	ra,0x0
     9ee:	4a4080e7          	jalr	1188(ra) # e8e <close>
        if(dup(aa[0]) != 0){
     9f2:	f9842503          	lw	a0,-104(s0)
     9f6:	00000097          	auipc	ra,0x0
     9fa:	4e8080e7          	jalr	1256(ra) # ede <dup>
     9fe:	cd19                	beqz	a0,a1c <go+0x9a4>
          fprintf(2, "grind: dup failed\n");
     a00:	00001597          	auipc	a1,0x1
     a04:	c5058593          	addi	a1,a1,-944 # 1650 <malloc+0x328>
     a08:	4509                	li	a0,2
     a0a:	00001097          	auipc	ra,0x1
     a0e:	832080e7          	jalr	-1998(ra) # 123c <fprintf>
          exit(4);
     a12:	4511                	li	a0,4
     a14:	00000097          	auipc	ra,0x0
     a18:	452080e7          	jalr	1106(ra) # e66 <exit>
        close(aa[0]);
     a1c:	f9842503          	lw	a0,-104(s0)
     a20:	00000097          	auipc	ra,0x0
     a24:	46e080e7          	jalr	1134(ra) # e8e <close>
        close(1);
     a28:	4505                	li	a0,1
     a2a:	00000097          	auipc	ra,0x0
     a2e:	464080e7          	jalr	1124(ra) # e8e <close>
        if(dup(bb[1]) != 1){
     a32:	fa442503          	lw	a0,-92(s0)
     a36:	00000097          	auipc	ra,0x0
     a3a:	4a8080e7          	jalr	1192(ra) # ede <dup>
     a3e:	4785                	li	a5,1
     a40:	02f50063          	beq	a0,a5,a60 <go+0x9e8>
          fprintf(2, "grind: dup failed\n");
     a44:	00001597          	auipc	a1,0x1
     a48:	c0c58593          	addi	a1,a1,-1012 # 1650 <malloc+0x328>
     a4c:	4509                	li	a0,2
     a4e:	00000097          	auipc	ra,0x0
     a52:	7ee080e7          	jalr	2030(ra) # 123c <fprintf>
          exit(5);
     a56:	4515                	li	a0,5
     a58:	00000097          	auipc	ra,0x0
     a5c:	40e080e7          	jalr	1038(ra) # e66 <exit>
        close(bb[1]);
     a60:	fa442503          	lw	a0,-92(s0)
     a64:	00000097          	auipc	ra,0x0
     a68:	42a080e7          	jalr	1066(ra) # e8e <close>
        char *args[2] = { "cat", 0 };
     a6c:	00001797          	auipc	a5,0x1
     a70:	c3478793          	addi	a5,a5,-972 # 16a0 <malloc+0x378>
     a74:	faf43423          	sd	a5,-88(s0)
     a78:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a7c:	fa840593          	addi	a1,s0,-88
     a80:	00001517          	auipc	a0,0x1
     a84:	c2850513          	addi	a0,a0,-984 # 16a8 <malloc+0x380>
     a88:	00000097          	auipc	ra,0x0
     a8c:	416080e7          	jalr	1046(ra) # e9e <exec>
        fprintf(2, "grind: cat: not found\n");
     a90:	00001597          	auipc	a1,0x1
     a94:	c2058593          	addi	a1,a1,-992 # 16b0 <malloc+0x388>
     a98:	4509                	li	a0,2
     a9a:	00000097          	auipc	ra,0x0
     a9e:	7a2080e7          	jalr	1954(ra) # 123c <fprintf>
        exit(6);
     aa2:	4519                	li	a0,6
     aa4:	00000097          	auipc	ra,0x0
     aa8:	3c2080e7          	jalr	962(ra) # e66 <exit>
        fprintf(2, "grind: fork failed\n");
     aac:	00001597          	auipc	a1,0x1
     ab0:	a6458593          	addi	a1,a1,-1436 # 1510 <malloc+0x1e8>
     ab4:	4509                	li	a0,2
     ab6:	00000097          	auipc	ra,0x0
     aba:	786080e7          	jalr	1926(ra) # 123c <fprintf>
        exit(7);
     abe:	451d                	li	a0,7
     ac0:	00000097          	auipc	ra,0x0
     ac4:	3a6080e7          	jalr	934(ra) # e66 <exit>

0000000000000ac8 <iter>:
  }
}

void
iter()
{
     ac8:	7179                	addi	sp,sp,-48
     aca:	f406                	sd	ra,40(sp)
     acc:	f022                	sd	s0,32(sp)
     ace:	ec26                	sd	s1,24(sp)
     ad0:	e84a                	sd	s2,16(sp)
     ad2:	1800                	addi	s0,sp,48
  unlink("a");
     ad4:	00001517          	auipc	a0,0x1
     ad8:	a1c50513          	addi	a0,a0,-1508 # 14f0 <malloc+0x1c8>
     adc:	00000097          	auipc	ra,0x0
     ae0:	3da080e7          	jalr	986(ra) # eb6 <unlink>
  unlink("b");
     ae4:	00001517          	auipc	a0,0x1
     ae8:	9bc50513          	addi	a0,a0,-1604 # 14a0 <malloc+0x178>
     aec:	00000097          	auipc	ra,0x0
     af0:	3ca080e7          	jalr	970(ra) # eb6 <unlink>
  
  int pid1 = fork();
     af4:	00000097          	auipc	ra,0x0
     af8:	36a080e7          	jalr	874(ra) # e5e <fork>
  if(pid1 < 0){
     afc:	00054e63          	bltz	a0,b18 <iter+0x50>
     b00:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     b02:	e905                	bnez	a0,b32 <iter+0x6a>
    rand_next = 31;
     b04:	47fd                	li	a5,31
     b06:	00001717          	auipc	a4,0x1
     b0a:	c0f73923          	sd	a5,-1006(a4) # 1718 <rand_next>
    go(0);
     b0e:	4501                	li	a0,0
     b10:	fffff097          	auipc	ra,0xfffff
     b14:	568080e7          	jalr	1384(ra) # 78 <go>
    printf("grind: fork failed\n");
     b18:	00001517          	auipc	a0,0x1
     b1c:	9f850513          	addi	a0,a0,-1544 # 1510 <malloc+0x1e8>
     b20:	00000097          	auipc	ra,0x0
     b24:	74a080e7          	jalr	1866(ra) # 126a <printf>
    exit(1);
     b28:	4505                	li	a0,1
     b2a:	00000097          	auipc	ra,0x0
     b2e:	33c080e7          	jalr	828(ra) # e66 <exit>
    exit(0);
  }

  int pid2 = fork();
     b32:	00000097          	auipc	ra,0x0
     b36:	32c080e7          	jalr	812(ra) # e5e <fork>
     b3a:	892a                	mv	s2,a0
  if(pid2 < 0){
     b3c:	00054f63          	bltz	a0,b5a <iter+0x92>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b40:	e915                	bnez	a0,b74 <iter+0xac>
    rand_next = 7177;
     b42:	6789                	lui	a5,0x2
     b44:	c0978793          	addi	a5,a5,-1015 # 1c09 <__BSS_END__+0xe9>
     b48:	00001717          	auipc	a4,0x1
     b4c:	bcf73823          	sd	a5,-1072(a4) # 1718 <rand_next>
    go(1);
     b50:	4505                	li	a0,1
     b52:	fffff097          	auipc	ra,0xfffff
     b56:	526080e7          	jalr	1318(ra) # 78 <go>
    printf("grind: fork failed\n");
     b5a:	00001517          	auipc	a0,0x1
     b5e:	9b650513          	addi	a0,a0,-1610 # 1510 <malloc+0x1e8>
     b62:	00000097          	auipc	ra,0x0
     b66:	708080e7          	jalr	1800(ra) # 126a <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00000097          	auipc	ra,0x0
     b70:	2fa080e7          	jalr	762(ra) # e66 <exit>
    exit(0);
  }

  int st1 = -1;
     b74:	57fd                	li	a5,-1
     b76:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b7a:	fdc40513          	addi	a0,s0,-36
     b7e:	00000097          	auipc	ra,0x0
     b82:	2f0080e7          	jalr	752(ra) # e6e <wait>
  if(st1 != 0){
     b86:	fdc42783          	lw	a5,-36(s0)
     b8a:	ef99                	bnez	a5,ba8 <iter+0xe0>
    kill(pid1,SIGKILL);
    kill(pid2,SIGKILL);
  }
  int st2 = -1;
     b8c:	57fd                	li	a5,-1
     b8e:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b92:	fd840513          	addi	a0,s0,-40
     b96:	00000097          	auipc	ra,0x0
     b9a:	2d8080e7          	jalr	728(ra) # e6e <wait>

  exit(0);
     b9e:	4501                	li	a0,0
     ba0:	00000097          	auipc	ra,0x0
     ba4:	2c6080e7          	jalr	710(ra) # e66 <exit>
    kill(pid1,SIGKILL);
     ba8:	45a5                	li	a1,9
     baa:	8526                	mv	a0,s1
     bac:	00000097          	auipc	ra,0x0
     bb0:	2ea080e7          	jalr	746(ra) # e96 <kill>
    kill(pid2,SIGKILL);
     bb4:	45a5                	li	a1,9
     bb6:	854a                	mv	a0,s2
     bb8:	00000097          	auipc	ra,0x0
     bbc:	2de080e7          	jalr	734(ra) # e96 <kill>
     bc0:	b7f1                	j	b8c <iter+0xc4>

0000000000000bc2 <main>:
}

int
main()
{
     bc2:	1141                	addi	sp,sp,-16
     bc4:	e406                	sd	ra,8(sp)
     bc6:	e022                	sd	s0,0(sp)
     bc8:	0800                	addi	s0,sp,16
     bca:	a811                	j	bde <main+0x1c>
  while(1){
    int pid = fork();
    if(pid == 0){
      iter();
     bcc:	00000097          	auipc	ra,0x0
     bd0:	efc080e7          	jalr	-260(ra) # ac8 <iter>
      exit(0);
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
     bd4:	4551                	li	a0,20
     bd6:	00000097          	auipc	ra,0x0
     bda:	320080e7          	jalr	800(ra) # ef6 <sleep>
    int pid = fork();
     bde:	00000097          	auipc	ra,0x0
     be2:	280080e7          	jalr	640(ra) # e5e <fork>
    if(pid == 0){
     be6:	d17d                	beqz	a0,bcc <main+0xa>
    if(pid > 0){
     be8:	fea056e3          	blez	a0,bd4 <main+0x12>
      wait(0);
     bec:	4501                	li	a0,0
     bee:	00000097          	auipc	ra,0x0
     bf2:	280080e7          	jalr	640(ra) # e6e <wait>
     bf6:	bff9                	j	bd4 <main+0x12>

0000000000000bf8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     bf8:	1141                	addi	sp,sp,-16
     bfa:	e422                	sd	s0,8(sp)
     bfc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bfe:	87aa                	mv	a5,a0
     c00:	0585                	addi	a1,a1,1
     c02:	0785                	addi	a5,a5,1
     c04:	fff5c703          	lbu	a4,-1(a1)
     c08:	fee78fa3          	sb	a4,-1(a5)
     c0c:	fb75                	bnez	a4,c00 <strcpy+0x8>
    ;
  return os;
}
     c0e:	6422                	ld	s0,8(sp)
     c10:	0141                	addi	sp,sp,16
     c12:	8082                	ret

0000000000000c14 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c14:	1141                	addi	sp,sp,-16
     c16:	e422                	sd	s0,8(sp)
     c18:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c1a:	00054783          	lbu	a5,0(a0)
     c1e:	cb91                	beqz	a5,c32 <strcmp+0x1e>
     c20:	0005c703          	lbu	a4,0(a1)
     c24:	00f71763          	bne	a4,a5,c32 <strcmp+0x1e>
    p++, q++;
     c28:	0505                	addi	a0,a0,1
     c2a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c2c:	00054783          	lbu	a5,0(a0)
     c30:	fbe5                	bnez	a5,c20 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c32:	0005c503          	lbu	a0,0(a1)
}
     c36:	40a7853b          	subw	a0,a5,a0
     c3a:	6422                	ld	s0,8(sp)
     c3c:	0141                	addi	sp,sp,16
     c3e:	8082                	ret

0000000000000c40 <strlen>:

uint
strlen(const char *s)
{
     c40:	1141                	addi	sp,sp,-16
     c42:	e422                	sd	s0,8(sp)
     c44:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c46:	00054783          	lbu	a5,0(a0)
     c4a:	cf91                	beqz	a5,c66 <strlen+0x26>
     c4c:	0505                	addi	a0,a0,1
     c4e:	87aa                	mv	a5,a0
     c50:	4685                	li	a3,1
     c52:	9e89                	subw	a3,a3,a0
     c54:	00f6853b          	addw	a0,a3,a5
     c58:	0785                	addi	a5,a5,1
     c5a:	fff7c703          	lbu	a4,-1(a5)
     c5e:	fb7d                	bnez	a4,c54 <strlen+0x14>
    ;
  return n;
}
     c60:	6422                	ld	s0,8(sp)
     c62:	0141                	addi	sp,sp,16
     c64:	8082                	ret
  for(n = 0; s[n]; n++)
     c66:	4501                	li	a0,0
     c68:	bfe5                	j	c60 <strlen+0x20>

0000000000000c6a <memset>:

void*
memset(void *dst, int c, uint n)
{
     c6a:	1141                	addi	sp,sp,-16
     c6c:	e422                	sd	s0,8(sp)
     c6e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c70:	ca19                	beqz	a2,c86 <memset+0x1c>
     c72:	87aa                	mv	a5,a0
     c74:	1602                	slli	a2,a2,0x20
     c76:	9201                	srli	a2,a2,0x20
     c78:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c7c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c80:	0785                	addi	a5,a5,1
     c82:	fee79de3          	bne	a5,a4,c7c <memset+0x12>
  }
  return dst;
}
     c86:	6422                	ld	s0,8(sp)
     c88:	0141                	addi	sp,sp,16
     c8a:	8082                	ret

0000000000000c8c <strchr>:

char*
strchr(const char *s, char c)
{
     c8c:	1141                	addi	sp,sp,-16
     c8e:	e422                	sd	s0,8(sp)
     c90:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c92:	00054783          	lbu	a5,0(a0)
     c96:	cb99                	beqz	a5,cac <strchr+0x20>
    if(*s == c)
     c98:	00f58763          	beq	a1,a5,ca6 <strchr+0x1a>
  for(; *s; s++)
     c9c:	0505                	addi	a0,a0,1
     c9e:	00054783          	lbu	a5,0(a0)
     ca2:	fbfd                	bnez	a5,c98 <strchr+0xc>
      return (char*)s;
  return 0;
     ca4:	4501                	li	a0,0
}
     ca6:	6422                	ld	s0,8(sp)
     ca8:	0141                	addi	sp,sp,16
     caa:	8082                	ret
  return 0;
     cac:	4501                	li	a0,0
     cae:	bfe5                	j	ca6 <strchr+0x1a>

0000000000000cb0 <gets>:

char*
gets(char *buf, int max)
{
     cb0:	711d                	addi	sp,sp,-96
     cb2:	ec86                	sd	ra,88(sp)
     cb4:	e8a2                	sd	s0,80(sp)
     cb6:	e4a6                	sd	s1,72(sp)
     cb8:	e0ca                	sd	s2,64(sp)
     cba:	fc4e                	sd	s3,56(sp)
     cbc:	f852                	sd	s4,48(sp)
     cbe:	f456                	sd	s5,40(sp)
     cc0:	f05a                	sd	s6,32(sp)
     cc2:	ec5e                	sd	s7,24(sp)
     cc4:	1080                	addi	s0,sp,96
     cc6:	8baa                	mv	s7,a0
     cc8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cca:	892a                	mv	s2,a0
     ccc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cce:	4aa9                	li	s5,10
     cd0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cd2:	89a6                	mv	s3,s1
     cd4:	2485                	addiw	s1,s1,1
     cd6:	0344d863          	bge	s1,s4,d06 <gets+0x56>
    cc = read(0, &c, 1);
     cda:	4605                	li	a2,1
     cdc:	faf40593          	addi	a1,s0,-81
     ce0:	4501                	li	a0,0
     ce2:	00000097          	auipc	ra,0x0
     ce6:	19c080e7          	jalr	412(ra) # e7e <read>
    if(cc < 1)
     cea:	00a05e63          	blez	a0,d06 <gets+0x56>
    buf[i++] = c;
     cee:	faf44783          	lbu	a5,-81(s0)
     cf2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cf6:	01578763          	beq	a5,s5,d04 <gets+0x54>
     cfa:	0905                	addi	s2,s2,1
     cfc:	fd679be3          	bne	a5,s6,cd2 <gets+0x22>
  for(i=0; i+1 < max; ){
     d00:	89a6                	mv	s3,s1
     d02:	a011                	j	d06 <gets+0x56>
     d04:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d06:	99de                	add	s3,s3,s7
     d08:	00098023          	sb	zero,0(s3)
  return buf;
}
     d0c:	855e                	mv	a0,s7
     d0e:	60e6                	ld	ra,88(sp)
     d10:	6446                	ld	s0,80(sp)
     d12:	64a6                	ld	s1,72(sp)
     d14:	6906                	ld	s2,64(sp)
     d16:	79e2                	ld	s3,56(sp)
     d18:	7a42                	ld	s4,48(sp)
     d1a:	7aa2                	ld	s5,40(sp)
     d1c:	7b02                	ld	s6,32(sp)
     d1e:	6be2                	ld	s7,24(sp)
     d20:	6125                	addi	sp,sp,96
     d22:	8082                	ret

0000000000000d24 <stat>:

int
stat(const char *n, struct stat *st)
{
     d24:	1101                	addi	sp,sp,-32
     d26:	ec06                	sd	ra,24(sp)
     d28:	e822                	sd	s0,16(sp)
     d2a:	e426                	sd	s1,8(sp)
     d2c:	e04a                	sd	s2,0(sp)
     d2e:	1000                	addi	s0,sp,32
     d30:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d32:	4581                	li	a1,0
     d34:	00000097          	auipc	ra,0x0
     d38:	172080e7          	jalr	370(ra) # ea6 <open>
  if(fd < 0)
     d3c:	02054563          	bltz	a0,d66 <stat+0x42>
     d40:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d42:	85ca                	mv	a1,s2
     d44:	00000097          	auipc	ra,0x0
     d48:	17a080e7          	jalr	378(ra) # ebe <fstat>
     d4c:	892a                	mv	s2,a0
  close(fd);
     d4e:	8526                	mv	a0,s1
     d50:	00000097          	auipc	ra,0x0
     d54:	13e080e7          	jalr	318(ra) # e8e <close>
  return r;
}
     d58:	854a                	mv	a0,s2
     d5a:	60e2                	ld	ra,24(sp)
     d5c:	6442                	ld	s0,16(sp)
     d5e:	64a2                	ld	s1,8(sp)
     d60:	6902                	ld	s2,0(sp)
     d62:	6105                	addi	sp,sp,32
     d64:	8082                	ret
    return -1;
     d66:	597d                	li	s2,-1
     d68:	bfc5                	j	d58 <stat+0x34>

0000000000000d6a <atoi>:

int
atoi(const char *s)
{
     d6a:	1141                	addi	sp,sp,-16
     d6c:	e422                	sd	s0,8(sp)
     d6e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d70:	00054603          	lbu	a2,0(a0)
     d74:	fd06079b          	addiw	a5,a2,-48
     d78:	0ff7f793          	andi	a5,a5,255
     d7c:	4725                	li	a4,9
     d7e:	02f76963          	bltu	a4,a5,db0 <atoi+0x46>
     d82:	86aa                	mv	a3,a0
  n = 0;
     d84:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d86:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d88:	0685                	addi	a3,a3,1
     d8a:	0025179b          	slliw	a5,a0,0x2
     d8e:	9fa9                	addw	a5,a5,a0
     d90:	0017979b          	slliw	a5,a5,0x1
     d94:	9fb1                	addw	a5,a5,a2
     d96:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d9a:	0006c603          	lbu	a2,0(a3)
     d9e:	fd06071b          	addiw	a4,a2,-48
     da2:	0ff77713          	andi	a4,a4,255
     da6:	fee5f1e3          	bgeu	a1,a4,d88 <atoi+0x1e>
  return n;
}
     daa:	6422                	ld	s0,8(sp)
     dac:	0141                	addi	sp,sp,16
     dae:	8082                	ret
  n = 0;
     db0:	4501                	li	a0,0
     db2:	bfe5                	j	daa <atoi+0x40>

0000000000000db4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     db4:	1141                	addi	sp,sp,-16
     db6:	e422                	sd	s0,8(sp)
     db8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     dba:	02b57463          	bgeu	a0,a1,de2 <memmove+0x2e>
    while(n-- > 0)
     dbe:	00c05f63          	blez	a2,ddc <memmove+0x28>
     dc2:	1602                	slli	a2,a2,0x20
     dc4:	9201                	srli	a2,a2,0x20
     dc6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     dca:	872a                	mv	a4,a0
      *dst++ = *src++;
     dcc:	0585                	addi	a1,a1,1
     dce:	0705                	addi	a4,a4,1
     dd0:	fff5c683          	lbu	a3,-1(a1)
     dd4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dd8:	fee79ae3          	bne	a5,a4,dcc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ddc:	6422                	ld	s0,8(sp)
     dde:	0141                	addi	sp,sp,16
     de0:	8082                	ret
    dst += n;
     de2:	00c50733          	add	a4,a0,a2
    src += n;
     de6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     de8:	fec05ae3          	blez	a2,ddc <memmove+0x28>
     dec:	fff6079b          	addiw	a5,a2,-1
     df0:	1782                	slli	a5,a5,0x20
     df2:	9381                	srli	a5,a5,0x20
     df4:	fff7c793          	not	a5,a5
     df8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dfa:	15fd                	addi	a1,a1,-1
     dfc:	177d                	addi	a4,a4,-1
     dfe:	0005c683          	lbu	a3,0(a1)
     e02:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e06:	fee79ae3          	bne	a5,a4,dfa <memmove+0x46>
     e0a:	bfc9                	j	ddc <memmove+0x28>

0000000000000e0c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e0c:	1141                	addi	sp,sp,-16
     e0e:	e422                	sd	s0,8(sp)
     e10:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e12:	ca05                	beqz	a2,e42 <memcmp+0x36>
     e14:	fff6069b          	addiw	a3,a2,-1
     e18:	1682                	slli	a3,a3,0x20
     e1a:	9281                	srli	a3,a3,0x20
     e1c:	0685                	addi	a3,a3,1
     e1e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e20:	00054783          	lbu	a5,0(a0)
     e24:	0005c703          	lbu	a4,0(a1)
     e28:	00e79863          	bne	a5,a4,e38 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e2c:	0505                	addi	a0,a0,1
    p2++;
     e2e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e30:	fed518e3          	bne	a0,a3,e20 <memcmp+0x14>
  }
  return 0;
     e34:	4501                	li	a0,0
     e36:	a019                	j	e3c <memcmp+0x30>
      return *p1 - *p2;
     e38:	40e7853b          	subw	a0,a5,a4
}
     e3c:	6422                	ld	s0,8(sp)
     e3e:	0141                	addi	sp,sp,16
     e40:	8082                	ret
  return 0;
     e42:	4501                	li	a0,0
     e44:	bfe5                	j	e3c <memcmp+0x30>

0000000000000e46 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e46:	1141                	addi	sp,sp,-16
     e48:	e406                	sd	ra,8(sp)
     e4a:	e022                	sd	s0,0(sp)
     e4c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e4e:	00000097          	auipc	ra,0x0
     e52:	f66080e7          	jalr	-154(ra) # db4 <memmove>
}
     e56:	60a2                	ld	ra,8(sp)
     e58:	6402                	ld	s0,0(sp)
     e5a:	0141                	addi	sp,sp,16
     e5c:	8082                	ret

0000000000000e5e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e5e:	4885                	li	a7,1
 ecall
     e60:	00000073          	ecall
 ret
     e64:	8082                	ret

0000000000000e66 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e66:	4889                	li	a7,2
 ecall
     e68:	00000073          	ecall
 ret
     e6c:	8082                	ret

0000000000000e6e <wait>:
.global wait
wait:
 li a7, SYS_wait
     e6e:	488d                	li	a7,3
 ecall
     e70:	00000073          	ecall
 ret
     e74:	8082                	ret

0000000000000e76 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e76:	4891                	li	a7,4
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <read>:
.global read
read:
 li a7, SYS_read
     e7e:	4895                	li	a7,5
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <write>:
.global write
write:
 li a7, SYS_write
     e86:	48c1                	li	a7,16
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <close>:
.global close
close:
 li a7, SYS_close
     e8e:	48d5                	li	a7,21
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e96:	4899                	li	a7,6
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <exec>:
.global exec
exec:
 li a7, SYS_exec
     e9e:	489d                	li	a7,7
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <open>:
.global open
open:
 li a7, SYS_open
     ea6:	48bd                	li	a7,15
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     eae:	48c5                	li	a7,17
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     eb6:	48c9                	li	a7,18
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ebe:	48a1                	li	a7,8
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <link>:
.global link
link:
 li a7, SYS_link
     ec6:	48cd                	li	a7,19
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ece:	48d1                	li	a7,20
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ed6:	48a5                	li	a7,9
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <dup>:
.global dup
dup:
 li a7, SYS_dup
     ede:	48a9                	li	a7,10
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ee6:	48ad                	li	a7,11
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     eee:	48b1                	li	a7,12
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ef6:	48b5                	li	a7,13
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     efe:	48b9                	li	a7,14
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
     f06:	48d9                	li	a7,22
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
     f0e:	48dd                	li	a7,23
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
     f16:	48e1                	li	a7,24
 ecall
     f18:	00000073          	ecall
 ret
     f1c:	8082                	ret

0000000000000f1e <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
     f1e:	48e5                	li	a7,25
 ecall
     f20:	00000073          	ecall
 ret
     f24:	8082                	ret

0000000000000f26 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
     f26:	48e9                	li	a7,26
 ecall
     f28:	00000073          	ecall
 ret
     f2c:	8082                	ret

0000000000000f2e <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
     f2e:	48ed                	li	a7,27
 ecall
     f30:	00000073          	ecall
 ret
     f34:	8082                	ret

0000000000000f36 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
     f36:	48f1                	li	a7,28
 ecall
     f38:	00000073          	ecall
 ret
     f3c:	8082                	ret

0000000000000f3e <bsem_alloc>:
.global bsem_alloc
bsem_alloc:
 li a7, SYS_bsem_alloc
     f3e:	48f5                	li	a7,29
 ecall
     f40:	00000073          	ecall
 ret
     f44:	8082                	ret

0000000000000f46 <bsem_free>:
.global bsem_free
bsem_free:
 li a7, SYS_bsem_free
     f46:	48f9                	li	a7,30
 ecall
     f48:	00000073          	ecall
 ret
     f4c:	8082                	ret

0000000000000f4e <bsem_down>:
.global bsem_down
bsem_down:
 li a7, SYS_bsem_down
     f4e:	48fd                	li	a7,31
 ecall
     f50:	00000073          	ecall
 ret
     f54:	8082                	ret

0000000000000f56 <bsem_up>:
.global bsem_up
bsem_up:
 li a7, SYS_bsem_up
     f56:	02000893          	li	a7,32
 ecall
     f5a:	00000073          	ecall
 ret
     f5e:	8082                	ret

0000000000000f60 <csem_alloc>:
.global csem_alloc
csem_alloc:
 li a7, SYS_csem_alloc
     f60:	02100893          	li	a7,33
 ecall
     f64:	00000073          	ecall
 ret
     f68:	8082                	ret

0000000000000f6a <csem_free>:
.global csem_free
csem_free:
 li a7, SYS_csem_free
     f6a:	02200893          	li	a7,34
 ecall
     f6e:	00000073          	ecall
 ret
     f72:	8082                	ret

0000000000000f74 <csem_down>:
.global csem_down
csem_down:
 li a7, SYS_csem_down
     f74:	02300893          	li	a7,35
 ecall
     f78:	00000073          	ecall
 ret
     f7c:	8082                	ret

0000000000000f7e <csem_up>:
.global csem_up
csem_up:
 li a7, SYS_csem_up
     f7e:	02400893          	li	a7,36
 ecall
     f82:	00000073          	ecall
 ret
     f86:	8082                	ret

0000000000000f88 <print_ptable>:
.global print_ptable
print_ptable:
 li a7, SYS_print_ptable
     f88:	02500893          	li	a7,37
 ecall
     f8c:	00000073          	ecall
 ret
     f90:	8082                	ret

0000000000000f92 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f92:	1101                	addi	sp,sp,-32
     f94:	ec06                	sd	ra,24(sp)
     f96:	e822                	sd	s0,16(sp)
     f98:	1000                	addi	s0,sp,32
     f9a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f9e:	4605                	li	a2,1
     fa0:	fef40593          	addi	a1,s0,-17
     fa4:	00000097          	auipc	ra,0x0
     fa8:	ee2080e7          	jalr	-286(ra) # e86 <write>
}
     fac:	60e2                	ld	ra,24(sp)
     fae:	6442                	ld	s0,16(sp)
     fb0:	6105                	addi	sp,sp,32
     fb2:	8082                	ret

0000000000000fb4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fb4:	7139                	addi	sp,sp,-64
     fb6:	fc06                	sd	ra,56(sp)
     fb8:	f822                	sd	s0,48(sp)
     fba:	f426                	sd	s1,40(sp)
     fbc:	f04a                	sd	s2,32(sp)
     fbe:	ec4e                	sd	s3,24(sp)
     fc0:	0080                	addi	s0,sp,64
     fc2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fc4:	c299                	beqz	a3,fca <printint+0x16>
     fc6:	0805c863          	bltz	a1,1056 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     fca:	2581                	sext.w	a1,a1
  neg = 0;
     fcc:	4881                	li	a7,0
     fce:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fd2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fd4:	2601                	sext.w	a2,a2
     fd6:	00000517          	auipc	a0,0x0
     fda:	72a50513          	addi	a0,a0,1834 # 1700 <digits>
     fde:	883a                	mv	a6,a4
     fe0:	2705                	addiw	a4,a4,1
     fe2:	02c5f7bb          	remuw	a5,a1,a2
     fe6:	1782                	slli	a5,a5,0x20
     fe8:	9381                	srli	a5,a5,0x20
     fea:	97aa                	add	a5,a5,a0
     fec:	0007c783          	lbu	a5,0(a5)
     ff0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     ff4:	0005879b          	sext.w	a5,a1
     ff8:	02c5d5bb          	divuw	a1,a1,a2
     ffc:	0685                	addi	a3,a3,1
     ffe:	fec7f0e3          	bgeu	a5,a2,fde <printint+0x2a>
  if(neg)
    1002:	00088b63          	beqz	a7,1018 <printint+0x64>
    buf[i++] = '-';
    1006:	fd040793          	addi	a5,s0,-48
    100a:	973e                	add	a4,a4,a5
    100c:	02d00793          	li	a5,45
    1010:	fef70823          	sb	a5,-16(a4)
    1014:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    1018:	02e05863          	blez	a4,1048 <printint+0x94>
    101c:	fc040793          	addi	a5,s0,-64
    1020:	00e78933          	add	s2,a5,a4
    1024:	fff78993          	addi	s3,a5,-1
    1028:	99ba                	add	s3,s3,a4
    102a:	377d                	addiw	a4,a4,-1
    102c:	1702                	slli	a4,a4,0x20
    102e:	9301                	srli	a4,a4,0x20
    1030:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1034:	fff94583          	lbu	a1,-1(s2)
    1038:	8526                	mv	a0,s1
    103a:	00000097          	auipc	ra,0x0
    103e:	f58080e7          	jalr	-168(ra) # f92 <putc>
  while(--i >= 0)
    1042:	197d                	addi	s2,s2,-1
    1044:	ff3918e3          	bne	s2,s3,1034 <printint+0x80>
}
    1048:	70e2                	ld	ra,56(sp)
    104a:	7442                	ld	s0,48(sp)
    104c:	74a2                	ld	s1,40(sp)
    104e:	7902                	ld	s2,32(sp)
    1050:	69e2                	ld	s3,24(sp)
    1052:	6121                	addi	sp,sp,64
    1054:	8082                	ret
    x = -xx;
    1056:	40b005bb          	negw	a1,a1
    neg = 1;
    105a:	4885                	li	a7,1
    x = -xx;
    105c:	bf8d                	j	fce <printint+0x1a>

000000000000105e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    105e:	7119                	addi	sp,sp,-128
    1060:	fc86                	sd	ra,120(sp)
    1062:	f8a2                	sd	s0,112(sp)
    1064:	f4a6                	sd	s1,104(sp)
    1066:	f0ca                	sd	s2,96(sp)
    1068:	ecce                	sd	s3,88(sp)
    106a:	e8d2                	sd	s4,80(sp)
    106c:	e4d6                	sd	s5,72(sp)
    106e:	e0da                	sd	s6,64(sp)
    1070:	fc5e                	sd	s7,56(sp)
    1072:	f862                	sd	s8,48(sp)
    1074:	f466                	sd	s9,40(sp)
    1076:	f06a                	sd	s10,32(sp)
    1078:	ec6e                	sd	s11,24(sp)
    107a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    107c:	0005c903          	lbu	s2,0(a1)
    1080:	18090f63          	beqz	s2,121e <vprintf+0x1c0>
    1084:	8aaa                	mv	s5,a0
    1086:	8b32                	mv	s6,a2
    1088:	00158493          	addi	s1,a1,1
  state = 0;
    108c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    108e:	02500a13          	li	s4,37
      if(c == 'd'){
    1092:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1096:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    109a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    109e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10a2:	00000b97          	auipc	s7,0x0
    10a6:	65eb8b93          	addi	s7,s7,1630 # 1700 <digits>
    10aa:	a839                	j	10c8 <vprintf+0x6a>
        putc(fd, c);
    10ac:	85ca                	mv	a1,s2
    10ae:	8556                	mv	a0,s5
    10b0:	00000097          	auipc	ra,0x0
    10b4:	ee2080e7          	jalr	-286(ra) # f92 <putc>
    10b8:	a019                	j	10be <vprintf+0x60>
    } else if(state == '%'){
    10ba:	01498f63          	beq	s3,s4,10d8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    10be:	0485                	addi	s1,s1,1
    10c0:	fff4c903          	lbu	s2,-1(s1)
    10c4:	14090d63          	beqz	s2,121e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    10c8:	0009079b          	sext.w	a5,s2
    if(state == 0){
    10cc:	fe0997e3          	bnez	s3,10ba <vprintf+0x5c>
      if(c == '%'){
    10d0:	fd479ee3          	bne	a5,s4,10ac <vprintf+0x4e>
        state = '%';
    10d4:	89be                	mv	s3,a5
    10d6:	b7e5                	j	10be <vprintf+0x60>
      if(c == 'd'){
    10d8:	05878063          	beq	a5,s8,1118 <vprintf+0xba>
      } else if(c == 'l') {
    10dc:	05978c63          	beq	a5,s9,1134 <vprintf+0xd6>
      } else if(c == 'x') {
    10e0:	07a78863          	beq	a5,s10,1150 <vprintf+0xf2>
      } else if(c == 'p') {
    10e4:	09b78463          	beq	a5,s11,116c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10e8:	07300713          	li	a4,115
    10ec:	0ce78663          	beq	a5,a4,11b8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10f0:	06300713          	li	a4,99
    10f4:	0ee78e63          	beq	a5,a4,11f0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10f8:	11478863          	beq	a5,s4,1208 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10fc:	85d2                	mv	a1,s4
    10fe:	8556                	mv	a0,s5
    1100:	00000097          	auipc	ra,0x0
    1104:	e92080e7          	jalr	-366(ra) # f92 <putc>
        putc(fd, c);
    1108:	85ca                	mv	a1,s2
    110a:	8556                	mv	a0,s5
    110c:	00000097          	auipc	ra,0x0
    1110:	e86080e7          	jalr	-378(ra) # f92 <putc>
      }
      state = 0;
    1114:	4981                	li	s3,0
    1116:	b765                	j	10be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1118:	008b0913          	addi	s2,s6,8
    111c:	4685                	li	a3,1
    111e:	4629                	li	a2,10
    1120:	000b2583          	lw	a1,0(s6)
    1124:	8556                	mv	a0,s5
    1126:	00000097          	auipc	ra,0x0
    112a:	e8e080e7          	jalr	-370(ra) # fb4 <printint>
    112e:	8b4a                	mv	s6,s2
      state = 0;
    1130:	4981                	li	s3,0
    1132:	b771                	j	10be <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1134:	008b0913          	addi	s2,s6,8
    1138:	4681                	li	a3,0
    113a:	4629                	li	a2,10
    113c:	000b2583          	lw	a1,0(s6)
    1140:	8556                	mv	a0,s5
    1142:	00000097          	auipc	ra,0x0
    1146:	e72080e7          	jalr	-398(ra) # fb4 <printint>
    114a:	8b4a                	mv	s6,s2
      state = 0;
    114c:	4981                	li	s3,0
    114e:	bf85                	j	10be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1150:	008b0913          	addi	s2,s6,8
    1154:	4681                	li	a3,0
    1156:	4641                	li	a2,16
    1158:	000b2583          	lw	a1,0(s6)
    115c:	8556                	mv	a0,s5
    115e:	00000097          	auipc	ra,0x0
    1162:	e56080e7          	jalr	-426(ra) # fb4 <printint>
    1166:	8b4a                	mv	s6,s2
      state = 0;
    1168:	4981                	li	s3,0
    116a:	bf91                	j	10be <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    116c:	008b0793          	addi	a5,s6,8
    1170:	f8f43423          	sd	a5,-120(s0)
    1174:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1178:	03000593          	li	a1,48
    117c:	8556                	mv	a0,s5
    117e:	00000097          	auipc	ra,0x0
    1182:	e14080e7          	jalr	-492(ra) # f92 <putc>
  putc(fd, 'x');
    1186:	85ea                	mv	a1,s10
    1188:	8556                	mv	a0,s5
    118a:	00000097          	auipc	ra,0x0
    118e:	e08080e7          	jalr	-504(ra) # f92 <putc>
    1192:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1194:	03c9d793          	srli	a5,s3,0x3c
    1198:	97de                	add	a5,a5,s7
    119a:	0007c583          	lbu	a1,0(a5)
    119e:	8556                	mv	a0,s5
    11a0:	00000097          	auipc	ra,0x0
    11a4:	df2080e7          	jalr	-526(ra) # f92 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    11a8:	0992                	slli	s3,s3,0x4
    11aa:	397d                	addiw	s2,s2,-1
    11ac:	fe0914e3          	bnez	s2,1194 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    11b0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    11b4:	4981                	li	s3,0
    11b6:	b721                	j	10be <vprintf+0x60>
        s = va_arg(ap, char*);
    11b8:	008b0993          	addi	s3,s6,8
    11bc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    11c0:	02090163          	beqz	s2,11e2 <vprintf+0x184>
        while(*s != 0){
    11c4:	00094583          	lbu	a1,0(s2)
    11c8:	c9a1                	beqz	a1,1218 <vprintf+0x1ba>
          putc(fd, *s);
    11ca:	8556                	mv	a0,s5
    11cc:	00000097          	auipc	ra,0x0
    11d0:	dc6080e7          	jalr	-570(ra) # f92 <putc>
          s++;
    11d4:	0905                	addi	s2,s2,1
        while(*s != 0){
    11d6:	00094583          	lbu	a1,0(s2)
    11da:	f9e5                	bnez	a1,11ca <vprintf+0x16c>
        s = va_arg(ap, char*);
    11dc:	8b4e                	mv	s6,s3
      state = 0;
    11de:	4981                	li	s3,0
    11e0:	bdf9                	j	10be <vprintf+0x60>
          s = "(null)";
    11e2:	00000917          	auipc	s2,0x0
    11e6:	51690913          	addi	s2,s2,1302 # 16f8 <malloc+0x3d0>
        while(*s != 0){
    11ea:	02800593          	li	a1,40
    11ee:	bff1                	j	11ca <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11f0:	008b0913          	addi	s2,s6,8
    11f4:	000b4583          	lbu	a1,0(s6)
    11f8:	8556                	mv	a0,s5
    11fa:	00000097          	auipc	ra,0x0
    11fe:	d98080e7          	jalr	-616(ra) # f92 <putc>
    1202:	8b4a                	mv	s6,s2
      state = 0;
    1204:	4981                	li	s3,0
    1206:	bd65                	j	10be <vprintf+0x60>
        putc(fd, c);
    1208:	85d2                	mv	a1,s4
    120a:	8556                	mv	a0,s5
    120c:	00000097          	auipc	ra,0x0
    1210:	d86080e7          	jalr	-634(ra) # f92 <putc>
      state = 0;
    1214:	4981                	li	s3,0
    1216:	b565                	j	10be <vprintf+0x60>
        s = va_arg(ap, char*);
    1218:	8b4e                	mv	s6,s3
      state = 0;
    121a:	4981                	li	s3,0
    121c:	b54d                	j	10be <vprintf+0x60>
    }
  }
}
    121e:	70e6                	ld	ra,120(sp)
    1220:	7446                	ld	s0,112(sp)
    1222:	74a6                	ld	s1,104(sp)
    1224:	7906                	ld	s2,96(sp)
    1226:	69e6                	ld	s3,88(sp)
    1228:	6a46                	ld	s4,80(sp)
    122a:	6aa6                	ld	s5,72(sp)
    122c:	6b06                	ld	s6,64(sp)
    122e:	7be2                	ld	s7,56(sp)
    1230:	7c42                	ld	s8,48(sp)
    1232:	7ca2                	ld	s9,40(sp)
    1234:	7d02                	ld	s10,32(sp)
    1236:	6de2                	ld	s11,24(sp)
    1238:	6109                	addi	sp,sp,128
    123a:	8082                	ret

000000000000123c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    123c:	715d                	addi	sp,sp,-80
    123e:	ec06                	sd	ra,24(sp)
    1240:	e822                	sd	s0,16(sp)
    1242:	1000                	addi	s0,sp,32
    1244:	e010                	sd	a2,0(s0)
    1246:	e414                	sd	a3,8(s0)
    1248:	e818                	sd	a4,16(s0)
    124a:	ec1c                	sd	a5,24(s0)
    124c:	03043023          	sd	a6,32(s0)
    1250:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1254:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1258:	8622                	mv	a2,s0
    125a:	00000097          	auipc	ra,0x0
    125e:	e04080e7          	jalr	-508(ra) # 105e <vprintf>
}
    1262:	60e2                	ld	ra,24(sp)
    1264:	6442                	ld	s0,16(sp)
    1266:	6161                	addi	sp,sp,80
    1268:	8082                	ret

000000000000126a <printf>:

void
printf(const char *fmt, ...)
{
    126a:	711d                	addi	sp,sp,-96
    126c:	ec06                	sd	ra,24(sp)
    126e:	e822                	sd	s0,16(sp)
    1270:	1000                	addi	s0,sp,32
    1272:	e40c                	sd	a1,8(s0)
    1274:	e810                	sd	a2,16(s0)
    1276:	ec14                	sd	a3,24(s0)
    1278:	f018                	sd	a4,32(s0)
    127a:	f41c                	sd	a5,40(s0)
    127c:	03043823          	sd	a6,48(s0)
    1280:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1284:	00840613          	addi	a2,s0,8
    1288:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    128c:	85aa                	mv	a1,a0
    128e:	4505                	li	a0,1
    1290:	00000097          	auipc	ra,0x0
    1294:	dce080e7          	jalr	-562(ra) # 105e <vprintf>
}
    1298:	60e2                	ld	ra,24(sp)
    129a:	6442                	ld	s0,16(sp)
    129c:	6125                	addi	sp,sp,96
    129e:	8082                	ret

00000000000012a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12a0:	1141                	addi	sp,sp,-16
    12a2:	e422                	sd	s0,8(sp)
    12a4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12a6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12aa:	00000797          	auipc	a5,0x0
    12ae:	4767b783          	ld	a5,1142(a5) # 1720 <freep>
    12b2:	a805                	j	12e2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    12b4:	4618                	lw	a4,8(a2)
    12b6:	9db9                	addw	a1,a1,a4
    12b8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    12bc:	6398                	ld	a4,0(a5)
    12be:	6318                	ld	a4,0(a4)
    12c0:	fee53823          	sd	a4,-16(a0)
    12c4:	a091                	j	1308 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12c6:	ff852703          	lw	a4,-8(a0)
    12ca:	9e39                	addw	a2,a2,a4
    12cc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    12ce:	ff053703          	ld	a4,-16(a0)
    12d2:	e398                	sd	a4,0(a5)
    12d4:	a099                	j	131a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12d6:	6398                	ld	a4,0(a5)
    12d8:	00e7e463          	bltu	a5,a4,12e0 <free+0x40>
    12dc:	00e6ea63          	bltu	a3,a4,12f0 <free+0x50>
{
    12e0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12e2:	fed7fae3          	bgeu	a5,a3,12d6 <free+0x36>
    12e6:	6398                	ld	a4,0(a5)
    12e8:	00e6e463          	bltu	a3,a4,12f0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12ec:	fee7eae3          	bltu	a5,a4,12e0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12f0:	ff852583          	lw	a1,-8(a0)
    12f4:	6390                	ld	a2,0(a5)
    12f6:	02059813          	slli	a6,a1,0x20
    12fa:	01c85713          	srli	a4,a6,0x1c
    12fe:	9736                	add	a4,a4,a3
    1300:	fae60ae3          	beq	a2,a4,12b4 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1304:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1308:	4790                	lw	a2,8(a5)
    130a:	02061593          	slli	a1,a2,0x20
    130e:	01c5d713          	srli	a4,a1,0x1c
    1312:	973e                	add	a4,a4,a5
    1314:	fae689e3          	beq	a3,a4,12c6 <free+0x26>
  } else
    p->s.ptr = bp;
    1318:	e394                	sd	a3,0(a5)
  freep = p;
    131a:	00000717          	auipc	a4,0x0
    131e:	40f73323          	sd	a5,1030(a4) # 1720 <freep>
}
    1322:	6422                	ld	s0,8(sp)
    1324:	0141                	addi	sp,sp,16
    1326:	8082                	ret

0000000000001328 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1328:	7139                	addi	sp,sp,-64
    132a:	fc06                	sd	ra,56(sp)
    132c:	f822                	sd	s0,48(sp)
    132e:	f426                	sd	s1,40(sp)
    1330:	f04a                	sd	s2,32(sp)
    1332:	ec4e                	sd	s3,24(sp)
    1334:	e852                	sd	s4,16(sp)
    1336:	e456                	sd	s5,8(sp)
    1338:	e05a                	sd	s6,0(sp)
    133a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    133c:	02051493          	slli	s1,a0,0x20
    1340:	9081                	srli	s1,s1,0x20
    1342:	04bd                	addi	s1,s1,15
    1344:	8091                	srli	s1,s1,0x4
    1346:	0014899b          	addiw	s3,s1,1
    134a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    134c:	00000517          	auipc	a0,0x0
    1350:	3d453503          	ld	a0,980(a0) # 1720 <freep>
    1354:	c515                	beqz	a0,1380 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1356:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1358:	4798                	lw	a4,8(a5)
    135a:	02977f63          	bgeu	a4,s1,1398 <malloc+0x70>
    135e:	8a4e                	mv	s4,s3
    1360:	0009871b          	sext.w	a4,s3
    1364:	6685                	lui	a3,0x1
    1366:	00d77363          	bgeu	a4,a3,136c <malloc+0x44>
    136a:	6a05                	lui	s4,0x1
    136c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1370:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1374:	00000917          	auipc	s2,0x0
    1378:	3ac90913          	addi	s2,s2,940 # 1720 <freep>
  if(p == (char*)-1)
    137c:	5afd                	li	s5,-1
    137e:	a895                	j	13f2 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    1380:	00000797          	auipc	a5,0x0
    1384:	79078793          	addi	a5,a5,1936 # 1b10 <base>
    1388:	00000717          	auipc	a4,0x0
    138c:	38f73c23          	sd	a5,920(a4) # 1720 <freep>
    1390:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1392:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1396:	b7e1                	j	135e <malloc+0x36>
      if(p->s.size == nunits)
    1398:	02e48c63          	beq	s1,a4,13d0 <malloc+0xa8>
        p->s.size -= nunits;
    139c:	4137073b          	subw	a4,a4,s3
    13a0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    13a2:	02071693          	slli	a3,a4,0x20
    13a6:	01c6d713          	srli	a4,a3,0x1c
    13aa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    13ac:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    13b0:	00000717          	auipc	a4,0x0
    13b4:	36a73823          	sd	a0,880(a4) # 1720 <freep>
      return (void*)(p + 1);
    13b8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    13bc:	70e2                	ld	ra,56(sp)
    13be:	7442                	ld	s0,48(sp)
    13c0:	74a2                	ld	s1,40(sp)
    13c2:	7902                	ld	s2,32(sp)
    13c4:	69e2                	ld	s3,24(sp)
    13c6:	6a42                	ld	s4,16(sp)
    13c8:	6aa2                	ld	s5,8(sp)
    13ca:	6b02                	ld	s6,0(sp)
    13cc:	6121                	addi	sp,sp,64
    13ce:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13d0:	6398                	ld	a4,0(a5)
    13d2:	e118                	sd	a4,0(a0)
    13d4:	bff1                	j	13b0 <malloc+0x88>
  hp->s.size = nu;
    13d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13da:	0541                	addi	a0,a0,16
    13dc:	00000097          	auipc	ra,0x0
    13e0:	ec4080e7          	jalr	-316(ra) # 12a0 <free>
  return freep;
    13e4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13e8:	d971                	beqz	a0,13bc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13ec:	4798                	lw	a4,8(a5)
    13ee:	fa9775e3          	bgeu	a4,s1,1398 <malloc+0x70>
    if(p == freep)
    13f2:	00093703          	ld	a4,0(s2)
    13f6:	853e                	mv	a0,a5
    13f8:	fef719e3          	bne	a4,a5,13ea <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    13fc:	8552                	mv	a0,s4
    13fe:	00000097          	auipc	ra,0x0
    1402:	af0080e7          	jalr	-1296(ra) # eee <sbrk>
  if(p == (char*)-1)
    1406:	fd5518e3          	bne	a0,s5,13d6 <malloc+0xae>
        return 0;
    140a:	4501                	li	a0,0
    140c:	bf45                	j	13bc <malloc+0x94>
