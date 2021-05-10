
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_handler>:
char buf[BUFSZ];


int wait_sig = 0;

void test_handler(int signum){
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
    wait_sig = 1;
       8:	4785                	li	a5,1
       a:	00008717          	auipc	a4,0x8
       e:	0af72723          	sw	a5,174(a4) # 80b8 <wait_sig>
    printf("Received sigtest\n");
      12:	00006517          	auipc	a0,0x6
      16:	e5650513          	addi	a0,a0,-426 # 5e68 <malloc+0x1ea>
      1a:	00006097          	auipc	ra,0x6
      1e:	ba6080e7          	jalr	-1114(ra) # 5bc0 <printf>
}
      22:	60a2                	ld	ra,8(sp)
      24:	6402                	ld	s0,0(sp)
      26:	0141                	addi	sp,sp,16
      28:	8082                	ret

000000000000002a <exitwait>:
}

// try to find any races between exit and wait
void
exitwait(char *s)
{
      2a:	7139                	addi	sp,sp,-64
      2c:	fc06                	sd	ra,56(sp)
      2e:	f822                	sd	s0,48(sp)
      30:	f426                	sd	s1,40(sp)
      32:	f04a                	sd	s2,32(sp)
      34:	ec4e                	sd	s3,24(sp)
      36:	e852                	sd	s4,16(sp)
      38:	0080                	addi	s0,sp,64
      3a:	8a2a                	mv	s4,a0
  int i, pid;

  for(i = 0; i < 100; i++){
      3c:	4901                	li	s2,0
      3e:	06400993          	li	s3,100
    pid = fork();
      42:	00005097          	auipc	ra,0x5
      46:	772080e7          	jalr	1906(ra) # 57b4 <fork>
      4a:	84aa                	mv	s1,a0
    if(pid < 0){
      4c:	02054a63          	bltz	a0,80 <exitwait+0x56>
      printf("%s: fork failed\n", s);
      exit(1);
    }
    if(pid){
      50:	c151                	beqz	a0,d4 <exitwait+0xaa>
      int xstate;
      if(wait(&xstate) != pid){
      52:	fcc40513          	addi	a0,s0,-52
      56:	00005097          	auipc	ra,0x5
      5a:	76e080e7          	jalr	1902(ra) # 57c4 <wait>
      5e:	02951f63          	bne	a0,s1,9c <exitwait+0x72>
        printf("%s: wait wrong pid\n", s);
        exit(1);
      }
      if(i != xstate) {
      62:	fcc42783          	lw	a5,-52(s0)
      66:	05279963          	bne	a5,s2,b8 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
      6a:	2905                	addiw	s2,s2,1
      6c:	fd391be3          	bne	s2,s3,42 <exitwait+0x18>
      }
    } else {
      exit(i);
    }
  }
}
      70:	70e2                	ld	ra,56(sp)
      72:	7442                	ld	s0,48(sp)
      74:	74a2                	ld	s1,40(sp)
      76:	7902                	ld	s2,32(sp)
      78:	69e2                	ld	s3,24(sp)
      7a:	6a42                	ld	s4,16(sp)
      7c:	6121                	addi	sp,sp,64
      7e:	8082                	ret
      printf("%s: fork failed\n", s);
      80:	85d2                	mv	a1,s4
      82:	00006517          	auipc	a0,0x6
      86:	dfe50513          	addi	a0,a0,-514 # 5e80 <malloc+0x202>
      8a:	00006097          	auipc	ra,0x6
      8e:	b36080e7          	jalr	-1226(ra) # 5bc0 <printf>
      exit(1);
      92:	4505                	li	a0,1
      94:	00005097          	auipc	ra,0x5
      98:	728080e7          	jalr	1832(ra) # 57bc <exit>
        printf("%s: wait wrong pid\n", s);
      9c:	85d2                	mv	a1,s4
      9e:	00006517          	auipc	a0,0x6
      a2:	dfa50513          	addi	a0,a0,-518 # 5e98 <malloc+0x21a>
      a6:	00006097          	auipc	ra,0x6
      aa:	b1a080e7          	jalr	-1254(ra) # 5bc0 <printf>
        exit(1);
      ae:	4505                	li	a0,1
      b0:	00005097          	auipc	ra,0x5
      b4:	70c080e7          	jalr	1804(ra) # 57bc <exit>
        printf("%s: wait wrong exit status\n", s);
      b8:	85d2                	mv	a1,s4
      ba:	00006517          	auipc	a0,0x6
      be:	df650513          	addi	a0,a0,-522 # 5eb0 <malloc+0x232>
      c2:	00006097          	auipc	ra,0x6
      c6:	afe080e7          	jalr	-1282(ra) # 5bc0 <printf>
        exit(1);
      ca:	4505                	li	a0,1
      cc:	00005097          	auipc	ra,0x5
      d0:	6f0080e7          	jalr	1776(ra) # 57bc <exit>
      exit(i);
      d4:	854a                	mv	a0,s2
      d6:	00005097          	auipc	ra,0x5
      da:	6e6080e7          	jalr	1766(ra) # 57bc <exit>

00000000000000de <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(char *s)
{
      de:	7179                	addi	sp,sp,-48
      e0:	f406                	sd	ra,40(sp)
      e2:	f022                	sd	s0,32(sp)
      e4:	ec26                	sd	s1,24(sp)
      e6:	e84a                	sd	s2,16(sp)
      e8:	e44e                	sd	s3,8(sp)
      ea:	1800                	addi	s0,sp,48
      ec:	89aa                	mv	s3,a0
  enum{ N = 1000 };
  int n, pid;

  for(n=0; n<N; n++){
      ee:	4481                	li	s1,0
      f0:	3e800913          	li	s2,1000
    pid = fork();
      f4:	00005097          	auipc	ra,0x5
      f8:	6c0080e7          	jalr	1728(ra) # 57b4 <fork>
    if(pid < 0)
      fc:	02054863          	bltz	a0,12c <forktest+0x4e>
      break;
    if(pid == 0)
     100:	c115                	beqz	a0,124 <forktest+0x46>
  for(n=0; n<N; n++){
     102:	2485                	addiw	s1,s1,1
     104:	ff2498e3          	bne	s1,s2,f4 <forktest+0x16>
    printf("%s: no fork at all!\n", s);
    exit(1);
  }

  if(n == N){
    printf("%s: fork claimed to work 1000 times!\n", s);
     108:	85ce                	mv	a1,s3
     10a:	00006517          	auipc	a0,0x6
     10e:	dde50513          	addi	a0,a0,-546 # 5ee8 <malloc+0x26a>
     112:	00006097          	auipc	ra,0x6
     116:	aae080e7          	jalr	-1362(ra) # 5bc0 <printf>
    exit(1);
     11a:	4505                	li	a0,1
     11c:	00005097          	auipc	ra,0x5
     120:	6a0080e7          	jalr	1696(ra) # 57bc <exit>
      exit(0);
     124:	00005097          	auipc	ra,0x5
     128:	698080e7          	jalr	1688(ra) # 57bc <exit>
  if (n == 0) {
     12c:	cc9d                	beqz	s1,16a <forktest+0x8c>
  if(n == N){
     12e:	3e800793          	li	a5,1000
     132:	fcf48be3          	beq	s1,a5,108 <forktest+0x2a>
  }

  for(; n > 0; n--){
     136:	00905b63          	blez	s1,14c <forktest+0x6e>
    if(wait(0) < 0){
     13a:	4501                	li	a0,0
     13c:	00005097          	auipc	ra,0x5
     140:	688080e7          	jalr	1672(ra) # 57c4 <wait>
     144:	04054163          	bltz	a0,186 <forktest+0xa8>
  for(; n > 0; n--){
     148:	34fd                	addiw	s1,s1,-1
     14a:	f8e5                	bnez	s1,13a <forktest+0x5c>
      printf("%s: wait stopped early\n", s);
      exit(1);
    }
  }

  if(wait(0) != -1){
     14c:	4501                	li	a0,0
     14e:	00005097          	auipc	ra,0x5
     152:	676080e7          	jalr	1654(ra) # 57c4 <wait>
     156:	57fd                	li	a5,-1
     158:	04f51563          	bne	a0,a5,1a2 <forktest+0xc4>
    printf("%s: wait got too many\n", s);
    exit(1);
  }
}
     15c:	70a2                	ld	ra,40(sp)
     15e:	7402                	ld	s0,32(sp)
     160:	64e2                	ld	s1,24(sp)
     162:	6942                	ld	s2,16(sp)
     164:	69a2                	ld	s3,8(sp)
     166:	6145                	addi	sp,sp,48
     168:	8082                	ret
    printf("%s: no fork at all!\n", s);
     16a:	85ce                	mv	a1,s3
     16c:	00006517          	auipc	a0,0x6
     170:	d6450513          	addi	a0,a0,-668 # 5ed0 <malloc+0x252>
     174:	00006097          	auipc	ra,0x6
     178:	a4c080e7          	jalr	-1460(ra) # 5bc0 <printf>
    exit(1);
     17c:	4505                	li	a0,1
     17e:	00005097          	auipc	ra,0x5
     182:	63e080e7          	jalr	1598(ra) # 57bc <exit>
      printf("%s: wait stopped early\n", s);
     186:	85ce                	mv	a1,s3
     188:	00006517          	auipc	a0,0x6
     18c:	d8850513          	addi	a0,a0,-632 # 5f10 <malloc+0x292>
     190:	00006097          	auipc	ra,0x6
     194:	a30080e7          	jalr	-1488(ra) # 5bc0 <printf>
      exit(1);
     198:	4505                	li	a0,1
     19a:	00005097          	auipc	ra,0x5
     19e:	622080e7          	jalr	1570(ra) # 57bc <exit>
    printf("%s: wait got too many\n", s);
     1a2:	85ce                	mv	a1,s3
     1a4:	00006517          	auipc	a0,0x6
     1a8:	d8450513          	addi	a0,a0,-636 # 5f28 <malloc+0x2aa>
     1ac:	00006097          	auipc	ra,0x6
     1b0:	a14080e7          	jalr	-1516(ra) # 5bc0 <printf>
    exit(1);
     1b4:	4505                	li	a0,1
     1b6:	00005097          	auipc	ra,0x5
     1ba:	606080e7          	jalr	1542(ra) # 57bc <exit>

00000000000001be <opentest>:
{
     1be:	1101                	addi	sp,sp,-32
     1c0:	ec06                	sd	ra,24(sp)
     1c2:	e822                	sd	s0,16(sp)
     1c4:	e426                	sd	s1,8(sp)
     1c6:	1000                	addi	s0,sp,32
     1c8:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     1ca:	4581                	li	a1,0
     1cc:	00006517          	auipc	a0,0x6
     1d0:	d7450513          	addi	a0,a0,-652 # 5f40 <malloc+0x2c2>
     1d4:	00005097          	auipc	ra,0x5
     1d8:	628080e7          	jalr	1576(ra) # 57fc <open>
  if(fd < 0){
     1dc:	02054663          	bltz	a0,208 <opentest+0x4a>
  close(fd);
     1e0:	00005097          	auipc	ra,0x5
     1e4:	604080e7          	jalr	1540(ra) # 57e4 <close>
  fd = open("doesnotexist", 0);
     1e8:	4581                	li	a1,0
     1ea:	00006517          	auipc	a0,0x6
     1ee:	d7650513          	addi	a0,a0,-650 # 5f60 <malloc+0x2e2>
     1f2:	00005097          	auipc	ra,0x5
     1f6:	60a080e7          	jalr	1546(ra) # 57fc <open>
  if(fd >= 0){
     1fa:	02055563          	bgez	a0,224 <opentest+0x66>
}
     1fe:	60e2                	ld	ra,24(sp)
     200:	6442                	ld	s0,16(sp)
     202:	64a2                	ld	s1,8(sp)
     204:	6105                	addi	sp,sp,32
     206:	8082                	ret
    printf("%s: open echo failed!\n", s);
     208:	85a6                	mv	a1,s1
     20a:	00006517          	auipc	a0,0x6
     20e:	d3e50513          	addi	a0,a0,-706 # 5f48 <malloc+0x2ca>
     212:	00006097          	auipc	ra,0x6
     216:	9ae080e7          	jalr	-1618(ra) # 5bc0 <printf>
    exit(1);
     21a:	4505                	li	a0,1
     21c:	00005097          	auipc	ra,0x5
     220:	5a0080e7          	jalr	1440(ra) # 57bc <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     224:	85a6                	mv	a1,s1
     226:	00006517          	auipc	a0,0x6
     22a:	d4a50513          	addi	a0,a0,-694 # 5f70 <malloc+0x2f2>
     22e:	00006097          	auipc	ra,0x6
     232:	992080e7          	jalr	-1646(ra) # 5bc0 <printf>
    exit(1);
     236:	4505                	li	a0,1
     238:	00005097          	auipc	ra,0x5
     23c:	584080e7          	jalr	1412(ra) # 57bc <exit>

0000000000000240 <createtest>:
{
     240:	7179                	addi	sp,sp,-48
     242:	f406                	sd	ra,40(sp)
     244:	f022                	sd	s0,32(sp)
     246:	ec26                	sd	s1,24(sp)
     248:	e84a                	sd	s2,16(sp)
     24a:	1800                	addi	s0,sp,48
  name[0] = 'a';
     24c:	06100793          	li	a5,97
     250:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     254:	fc040d23          	sb	zero,-38(s0)
     258:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     25c:	06400913          	li	s2,100
    name[1] = '0' + i;
     260:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     264:	20200593          	li	a1,514
     268:	fd840513          	addi	a0,s0,-40
     26c:	00005097          	auipc	ra,0x5
     270:	590080e7          	jalr	1424(ra) # 57fc <open>
    close(fd);
     274:	00005097          	auipc	ra,0x5
     278:	570080e7          	jalr	1392(ra) # 57e4 <close>
  for(i = 0; i < N; i++){
     27c:	2485                	addiw	s1,s1,1
     27e:	0ff4f493          	andi	s1,s1,255
     282:	fd249fe3          	bne	s1,s2,260 <createtest+0x20>
  name[0] = 'a';
     286:	06100793          	li	a5,97
     28a:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     28e:	fc040d23          	sb	zero,-38(s0)
     292:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     296:	06400913          	li	s2,100
    name[1] = '0' + i;
     29a:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     29e:	fd840513          	addi	a0,s0,-40
     2a2:	00005097          	auipc	ra,0x5
     2a6:	56a080e7          	jalr	1386(ra) # 580c <unlink>
  for(i = 0; i < N; i++){
     2aa:	2485                	addiw	s1,s1,1
     2ac:	0ff4f493          	andi	s1,s1,255
     2b0:	ff2495e3          	bne	s1,s2,29a <createtest+0x5a>
}
     2b4:	70a2                	ld	ra,40(sp)
     2b6:	7402                	ld	s0,32(sp)
     2b8:	64e2                	ld	s1,24(sp)
     2ba:	6942                	ld	s2,16(sp)
     2bc:	6145                	addi	sp,sp,48
     2be:	8082                	ret

00000000000002c0 <writetest>:
{
     2c0:	7139                	addi	sp,sp,-64
     2c2:	fc06                	sd	ra,56(sp)
     2c4:	f822                	sd	s0,48(sp)
     2c6:	f426                	sd	s1,40(sp)
     2c8:	f04a                	sd	s2,32(sp)
     2ca:	ec4e                	sd	s3,24(sp)
     2cc:	e852                	sd	s4,16(sp)
     2ce:	e456                	sd	s5,8(sp)
     2d0:	e05a                	sd	s6,0(sp)
     2d2:	0080                	addi	s0,sp,64
     2d4:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     2d6:	20200593          	li	a1,514
     2da:	00006517          	auipc	a0,0x6
     2de:	cbe50513          	addi	a0,a0,-834 # 5f98 <malloc+0x31a>
     2e2:	00005097          	auipc	ra,0x5
     2e6:	51a080e7          	jalr	1306(ra) # 57fc <open>
  if(fd < 0){
     2ea:	0a054d63          	bltz	a0,3a4 <writetest+0xe4>
     2ee:	892a                	mv	s2,a0
     2f0:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     2f2:	00006997          	auipc	s3,0x6
     2f6:	cce98993          	addi	s3,s3,-818 # 5fc0 <malloc+0x342>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     2fa:	00006a97          	auipc	s5,0x6
     2fe:	cfea8a93          	addi	s5,s5,-770 # 5ff8 <malloc+0x37a>
  for(i = 0; i < N; i++){
     302:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     306:	4629                	li	a2,10
     308:	85ce                	mv	a1,s3
     30a:	854a                	mv	a0,s2
     30c:	00005097          	auipc	ra,0x5
     310:	4d0080e7          	jalr	1232(ra) # 57dc <write>
     314:	47a9                	li	a5,10
     316:	0af51563          	bne	a0,a5,3c0 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     31a:	4629                	li	a2,10
     31c:	85d6                	mv	a1,s5
     31e:	854a                	mv	a0,s2
     320:	00005097          	auipc	ra,0x5
     324:	4bc080e7          	jalr	1212(ra) # 57dc <write>
     328:	47a9                	li	a5,10
     32a:	0af51a63          	bne	a0,a5,3de <writetest+0x11e>
  for(i = 0; i < N; i++){
     32e:	2485                	addiw	s1,s1,1
     330:	fd449be3          	bne	s1,s4,306 <writetest+0x46>
  close(fd);
     334:	854a                	mv	a0,s2
     336:	00005097          	auipc	ra,0x5
     33a:	4ae080e7          	jalr	1198(ra) # 57e4 <close>
  fd = open("small", O_RDONLY);
     33e:	4581                	li	a1,0
     340:	00006517          	auipc	a0,0x6
     344:	c5850513          	addi	a0,a0,-936 # 5f98 <malloc+0x31a>
     348:	00005097          	auipc	ra,0x5
     34c:	4b4080e7          	jalr	1204(ra) # 57fc <open>
     350:	84aa                	mv	s1,a0
  if(fd < 0){
     352:	0a054563          	bltz	a0,3fc <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     356:	7d000613          	li	a2,2000
     35a:	0000b597          	auipc	a1,0xb
     35e:	58658593          	addi	a1,a1,1414 # b8e0 <buf>
     362:	00005097          	auipc	ra,0x5
     366:	472080e7          	jalr	1138(ra) # 57d4 <read>
  if(i != N*SZ*2){
     36a:	7d000793          	li	a5,2000
     36e:	0af51563          	bne	a0,a5,418 <writetest+0x158>
  close(fd);
     372:	8526                	mv	a0,s1
     374:	00005097          	auipc	ra,0x5
     378:	470080e7          	jalr	1136(ra) # 57e4 <close>
  if(unlink("small") < 0){
     37c:	00006517          	auipc	a0,0x6
     380:	c1c50513          	addi	a0,a0,-996 # 5f98 <malloc+0x31a>
     384:	00005097          	auipc	ra,0x5
     388:	488080e7          	jalr	1160(ra) # 580c <unlink>
     38c:	0a054463          	bltz	a0,434 <writetest+0x174>
}
     390:	70e2                	ld	ra,56(sp)
     392:	7442                	ld	s0,48(sp)
     394:	74a2                	ld	s1,40(sp)
     396:	7902                	ld	s2,32(sp)
     398:	69e2                	ld	s3,24(sp)
     39a:	6a42                	ld	s4,16(sp)
     39c:	6aa2                	ld	s5,8(sp)
     39e:	6b02                	ld	s6,0(sp)
     3a0:	6121                	addi	sp,sp,64
     3a2:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     3a4:	85da                	mv	a1,s6
     3a6:	00006517          	auipc	a0,0x6
     3aa:	bfa50513          	addi	a0,a0,-1030 # 5fa0 <malloc+0x322>
     3ae:	00006097          	auipc	ra,0x6
     3b2:	812080e7          	jalr	-2030(ra) # 5bc0 <printf>
    exit(1);
     3b6:	4505                	li	a0,1
     3b8:	00005097          	auipc	ra,0x5
     3bc:	404080e7          	jalr	1028(ra) # 57bc <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     3c0:	8626                	mv	a2,s1
     3c2:	85da                	mv	a1,s6
     3c4:	00006517          	auipc	a0,0x6
     3c8:	c0c50513          	addi	a0,a0,-1012 # 5fd0 <malloc+0x352>
     3cc:	00005097          	auipc	ra,0x5
     3d0:	7f4080e7          	jalr	2036(ra) # 5bc0 <printf>
      exit(1);
     3d4:	4505                	li	a0,1
     3d6:	00005097          	auipc	ra,0x5
     3da:	3e6080e7          	jalr	998(ra) # 57bc <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     3de:	8626                	mv	a2,s1
     3e0:	85da                	mv	a1,s6
     3e2:	00006517          	auipc	a0,0x6
     3e6:	c2650513          	addi	a0,a0,-986 # 6008 <malloc+0x38a>
     3ea:	00005097          	auipc	ra,0x5
     3ee:	7d6080e7          	jalr	2006(ra) # 5bc0 <printf>
      exit(1);
     3f2:	4505                	li	a0,1
     3f4:	00005097          	auipc	ra,0x5
     3f8:	3c8080e7          	jalr	968(ra) # 57bc <exit>
    printf("%s: error: open small failed!\n", s);
     3fc:	85da                	mv	a1,s6
     3fe:	00006517          	auipc	a0,0x6
     402:	c3250513          	addi	a0,a0,-974 # 6030 <malloc+0x3b2>
     406:	00005097          	auipc	ra,0x5
     40a:	7ba080e7          	jalr	1978(ra) # 5bc0 <printf>
    exit(1);
     40e:	4505                	li	a0,1
     410:	00005097          	auipc	ra,0x5
     414:	3ac080e7          	jalr	940(ra) # 57bc <exit>
    printf("%s: read failed\n", s);
     418:	85da                	mv	a1,s6
     41a:	00006517          	auipc	a0,0x6
     41e:	c3650513          	addi	a0,a0,-970 # 6050 <malloc+0x3d2>
     422:	00005097          	auipc	ra,0x5
     426:	79e080e7          	jalr	1950(ra) # 5bc0 <printf>
    exit(1);
     42a:	4505                	li	a0,1
     42c:	00005097          	auipc	ra,0x5
     430:	390080e7          	jalr	912(ra) # 57bc <exit>
    printf("%s: unlink small failed\n", s);
     434:	85da                	mv	a1,s6
     436:	00006517          	auipc	a0,0x6
     43a:	c3250513          	addi	a0,a0,-974 # 6068 <malloc+0x3ea>
     43e:	00005097          	auipc	ra,0x5
     442:	782080e7          	jalr	1922(ra) # 5bc0 <printf>
    exit(1);
     446:	4505                	li	a0,1
     448:	00005097          	auipc	ra,0x5
     44c:	374080e7          	jalr	884(ra) # 57bc <exit>

0000000000000450 <writebig>:
{
     450:	7139                	addi	sp,sp,-64
     452:	fc06                	sd	ra,56(sp)
     454:	f822                	sd	s0,48(sp)
     456:	f426                	sd	s1,40(sp)
     458:	f04a                	sd	s2,32(sp)
     45a:	ec4e                	sd	s3,24(sp)
     45c:	e852                	sd	s4,16(sp)
     45e:	e456                	sd	s5,8(sp)
     460:	0080                	addi	s0,sp,64
     462:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     464:	20200593          	li	a1,514
     468:	00006517          	auipc	a0,0x6
     46c:	c2050513          	addi	a0,a0,-992 # 6088 <malloc+0x40a>
     470:	00005097          	auipc	ra,0x5
     474:	38c080e7          	jalr	908(ra) # 57fc <open>
     478:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     47a:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     47c:	0000b917          	auipc	s2,0xb
     480:	46490913          	addi	s2,s2,1124 # b8e0 <buf>
  for(i = 0; i < MAXFILE; i++){
     484:	10c00a13          	li	s4,268
  if(fd < 0){
     488:	06054c63          	bltz	a0,500 <writebig+0xb0>
    ((int*)buf)[0] = i;
     48c:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     490:	40000613          	li	a2,1024
     494:	85ca                	mv	a1,s2
     496:	854e                	mv	a0,s3
     498:	00005097          	auipc	ra,0x5
     49c:	344080e7          	jalr	836(ra) # 57dc <write>
     4a0:	40000793          	li	a5,1024
     4a4:	06f51c63          	bne	a0,a5,51c <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     4a8:	2485                	addiw	s1,s1,1
     4aa:	ff4491e3          	bne	s1,s4,48c <writebig+0x3c>
  close(fd);
     4ae:	854e                	mv	a0,s3
     4b0:	00005097          	auipc	ra,0x5
     4b4:	334080e7          	jalr	820(ra) # 57e4 <close>
  fd = open("big", O_RDONLY);
     4b8:	4581                	li	a1,0
     4ba:	00006517          	auipc	a0,0x6
     4be:	bce50513          	addi	a0,a0,-1074 # 6088 <malloc+0x40a>
     4c2:	00005097          	auipc	ra,0x5
     4c6:	33a080e7          	jalr	826(ra) # 57fc <open>
     4ca:	89aa                	mv	s3,a0
  n = 0;
     4cc:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     4ce:	0000b917          	auipc	s2,0xb
     4d2:	41290913          	addi	s2,s2,1042 # b8e0 <buf>
  if(fd < 0){
     4d6:	06054263          	bltz	a0,53a <writebig+0xea>
    i = read(fd, buf, BSIZE);
     4da:	40000613          	li	a2,1024
     4de:	85ca                	mv	a1,s2
     4e0:	854e                	mv	a0,s3
     4e2:	00005097          	auipc	ra,0x5
     4e6:	2f2080e7          	jalr	754(ra) # 57d4 <read>
    if(i == 0){
     4ea:	c535                	beqz	a0,556 <writebig+0x106>
    } else if(i != BSIZE){
     4ec:	40000793          	li	a5,1024
     4f0:	0af51f63          	bne	a0,a5,5ae <writebig+0x15e>
    if(((int*)buf)[0] != n){
     4f4:	00092683          	lw	a3,0(s2)
     4f8:	0c969a63          	bne	a3,s1,5cc <writebig+0x17c>
    n++;
     4fc:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     4fe:	bff1                	j	4da <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     500:	85d6                	mv	a1,s5
     502:	00006517          	auipc	a0,0x6
     506:	b8e50513          	addi	a0,a0,-1138 # 6090 <malloc+0x412>
     50a:	00005097          	auipc	ra,0x5
     50e:	6b6080e7          	jalr	1718(ra) # 5bc0 <printf>
    exit(1);
     512:	4505                	li	a0,1
     514:	00005097          	auipc	ra,0x5
     518:	2a8080e7          	jalr	680(ra) # 57bc <exit>
      printf("%s: error: write big file failed\n", s, i);
     51c:	8626                	mv	a2,s1
     51e:	85d6                	mv	a1,s5
     520:	00006517          	auipc	a0,0x6
     524:	b9050513          	addi	a0,a0,-1136 # 60b0 <malloc+0x432>
     528:	00005097          	auipc	ra,0x5
     52c:	698080e7          	jalr	1688(ra) # 5bc0 <printf>
      exit(1);
     530:	4505                	li	a0,1
     532:	00005097          	auipc	ra,0x5
     536:	28a080e7          	jalr	650(ra) # 57bc <exit>
    printf("%s: error: open big failed!\n", s);
     53a:	85d6                	mv	a1,s5
     53c:	00006517          	auipc	a0,0x6
     540:	b9c50513          	addi	a0,a0,-1124 # 60d8 <malloc+0x45a>
     544:	00005097          	auipc	ra,0x5
     548:	67c080e7          	jalr	1660(ra) # 5bc0 <printf>
    exit(1);
     54c:	4505                	li	a0,1
     54e:	00005097          	auipc	ra,0x5
     552:	26e080e7          	jalr	622(ra) # 57bc <exit>
      if(n == MAXFILE - 1){
     556:	10b00793          	li	a5,267
     55a:	02f48a63          	beq	s1,a5,58e <writebig+0x13e>
  close(fd);
     55e:	854e                	mv	a0,s3
     560:	00005097          	auipc	ra,0x5
     564:	284080e7          	jalr	644(ra) # 57e4 <close>
  if(unlink("big") < 0){
     568:	00006517          	auipc	a0,0x6
     56c:	b2050513          	addi	a0,a0,-1248 # 6088 <malloc+0x40a>
     570:	00005097          	auipc	ra,0x5
     574:	29c080e7          	jalr	668(ra) # 580c <unlink>
     578:	06054963          	bltz	a0,5ea <writebig+0x19a>
}
     57c:	70e2                	ld	ra,56(sp)
     57e:	7442                	ld	s0,48(sp)
     580:	74a2                	ld	s1,40(sp)
     582:	7902                	ld	s2,32(sp)
     584:	69e2                	ld	s3,24(sp)
     586:	6a42                	ld	s4,16(sp)
     588:	6aa2                	ld	s5,8(sp)
     58a:	6121                	addi	sp,sp,64
     58c:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     58e:	10b00613          	li	a2,267
     592:	85d6                	mv	a1,s5
     594:	00006517          	auipc	a0,0x6
     598:	b6450513          	addi	a0,a0,-1180 # 60f8 <malloc+0x47a>
     59c:	00005097          	auipc	ra,0x5
     5a0:	624080e7          	jalr	1572(ra) # 5bc0 <printf>
        exit(1);
     5a4:	4505                	li	a0,1
     5a6:	00005097          	auipc	ra,0x5
     5aa:	216080e7          	jalr	534(ra) # 57bc <exit>
      printf("%s: read failed %d\n", s, i);
     5ae:	862a                	mv	a2,a0
     5b0:	85d6                	mv	a1,s5
     5b2:	00006517          	auipc	a0,0x6
     5b6:	b6e50513          	addi	a0,a0,-1170 # 6120 <malloc+0x4a2>
     5ba:	00005097          	auipc	ra,0x5
     5be:	606080e7          	jalr	1542(ra) # 5bc0 <printf>
      exit(1);
     5c2:	4505                	li	a0,1
     5c4:	00005097          	auipc	ra,0x5
     5c8:	1f8080e7          	jalr	504(ra) # 57bc <exit>
      printf("%s: read content of block %d is %d\n", s,
     5cc:	8626                	mv	a2,s1
     5ce:	85d6                	mv	a1,s5
     5d0:	00006517          	auipc	a0,0x6
     5d4:	b6850513          	addi	a0,a0,-1176 # 6138 <malloc+0x4ba>
     5d8:	00005097          	auipc	ra,0x5
     5dc:	5e8080e7          	jalr	1512(ra) # 5bc0 <printf>
      exit(1);
     5e0:	4505                	li	a0,1
     5e2:	00005097          	auipc	ra,0x5
     5e6:	1da080e7          	jalr	474(ra) # 57bc <exit>
    printf("%s: unlink big failed\n", s);
     5ea:	85d6                	mv	a1,s5
     5ec:	00006517          	auipc	a0,0x6
     5f0:	b7450513          	addi	a0,a0,-1164 # 6160 <malloc+0x4e2>
     5f4:	00005097          	auipc	ra,0x5
     5f8:	5cc080e7          	jalr	1484(ra) # 5bc0 <printf>
    exit(1);
     5fc:	4505                	li	a0,1
     5fe:	00005097          	auipc	ra,0x5
     602:	1be080e7          	jalr	446(ra) # 57bc <exit>

0000000000000606 <pipe1>:
{
     606:	711d                	addi	sp,sp,-96
     608:	ec86                	sd	ra,88(sp)
     60a:	e8a2                	sd	s0,80(sp)
     60c:	e4a6                	sd	s1,72(sp)
     60e:	e0ca                	sd	s2,64(sp)
     610:	fc4e                	sd	s3,56(sp)
     612:	f852                	sd	s4,48(sp)
     614:	f456                	sd	s5,40(sp)
     616:	f05a                	sd	s6,32(sp)
     618:	ec5e                	sd	s7,24(sp)
     61a:	1080                	addi	s0,sp,96
     61c:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
     61e:	fa840513          	addi	a0,s0,-88
     622:	00005097          	auipc	ra,0x5
     626:	1aa080e7          	jalr	426(ra) # 57cc <pipe>
     62a:	ed25                	bnez	a0,6a2 <pipe1+0x9c>
     62c:	84aa                	mv	s1,a0
  pid = fork();
     62e:	00005097          	auipc	ra,0x5
     632:	186080e7          	jalr	390(ra) # 57b4 <fork>
     636:	8a2a                	mv	s4,a0
  if(pid == 0){
     638:	c159                	beqz	a0,6be <pipe1+0xb8>
  } else if(pid > 0){
     63a:	16a05e63          	blez	a0,7b6 <pipe1+0x1b0>
    close(fds[1]);
     63e:	fac42503          	lw	a0,-84(s0)
     642:	00005097          	auipc	ra,0x5
     646:	1a2080e7          	jalr	418(ra) # 57e4 <close>
    total = 0;
     64a:	8a26                	mv	s4,s1
    cc = 1;
     64c:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
     64e:	0000ba97          	auipc	s5,0xb
     652:	292a8a93          	addi	s5,s5,658 # b8e0 <buf>
      if(cc > sizeof(buf))
     656:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
     658:	864e                	mv	a2,s3
     65a:	85d6                	mv	a1,s5
     65c:	fa842503          	lw	a0,-88(s0)
     660:	00005097          	auipc	ra,0x5
     664:	174080e7          	jalr	372(ra) # 57d4 <read>
     668:	10a05263          	blez	a0,76c <pipe1+0x166>
      for(i = 0; i < n; i++){
     66c:	0000b717          	auipc	a4,0xb
     670:	27470713          	addi	a4,a4,628 # b8e0 <buf>
     674:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     678:	00074683          	lbu	a3,0(a4)
     67c:	0ff4f793          	andi	a5,s1,255
     680:	2485                	addiw	s1,s1,1
     682:	0cf69163          	bne	a3,a5,744 <pipe1+0x13e>
      for(i = 0; i < n; i++){
     686:	0705                	addi	a4,a4,1
     688:	fec498e3          	bne	s1,a2,678 <pipe1+0x72>
      total += n;
     68c:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
     690:	0019979b          	slliw	a5,s3,0x1
     694:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
     698:	013b7363          	bgeu	s6,s3,69e <pipe1+0x98>
        cc = sizeof(buf);
     69c:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     69e:	84b2                	mv	s1,a2
     6a0:	bf65                	j	658 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
     6a2:	85ca                	mv	a1,s2
     6a4:	00006517          	auipc	a0,0x6
     6a8:	ad450513          	addi	a0,a0,-1324 # 6178 <malloc+0x4fa>
     6ac:	00005097          	auipc	ra,0x5
     6b0:	514080e7          	jalr	1300(ra) # 5bc0 <printf>
    exit(1);
     6b4:	4505                	li	a0,1
     6b6:	00005097          	auipc	ra,0x5
     6ba:	106080e7          	jalr	262(ra) # 57bc <exit>
    close(fds[0]);
     6be:	fa842503          	lw	a0,-88(s0)
     6c2:	00005097          	auipc	ra,0x5
     6c6:	122080e7          	jalr	290(ra) # 57e4 <close>
    for(n = 0; n < N; n++){
     6ca:	0000bb17          	auipc	s6,0xb
     6ce:	216b0b13          	addi	s6,s6,534 # b8e0 <buf>
     6d2:	416004bb          	negw	s1,s6
     6d6:	0ff4f493          	andi	s1,s1,255
     6da:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
     6de:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
     6e0:	6a85                	lui	s5,0x1
     6e2:	42da8a93          	addi	s5,s5,1069 # 142d <bigfile+0x67>
{
     6e6:	87da                	mv	a5,s6
        buf[i] = seq++;
     6e8:	0097873b          	addw	a4,a5,s1
     6ec:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
     6f0:	0785                	addi	a5,a5,1
     6f2:	fef99be3          	bne	s3,a5,6e8 <pipe1+0xe2>
        buf[i] = seq++;
     6f6:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
     6fa:	40900613          	li	a2,1033
     6fe:	85de                	mv	a1,s7
     700:	fac42503          	lw	a0,-84(s0)
     704:	00005097          	auipc	ra,0x5
     708:	0d8080e7          	jalr	216(ra) # 57dc <write>
     70c:	40900793          	li	a5,1033
     710:	00f51c63          	bne	a0,a5,728 <pipe1+0x122>
    for(n = 0; n < N; n++){
     714:	24a5                	addiw	s1,s1,9
     716:	0ff4f493          	andi	s1,s1,255
     71a:	fd5a16e3          	bne	s4,s5,6e6 <pipe1+0xe0>
    exit(0);
     71e:	4501                	li	a0,0
     720:	00005097          	auipc	ra,0x5
     724:	09c080e7          	jalr	156(ra) # 57bc <exit>
        printf("%s: pipe1 oops 1\n", s);
     728:	85ca                	mv	a1,s2
     72a:	00006517          	auipc	a0,0x6
     72e:	a6650513          	addi	a0,a0,-1434 # 6190 <malloc+0x512>
     732:	00005097          	auipc	ra,0x5
     736:	48e080e7          	jalr	1166(ra) # 5bc0 <printf>
        exit(1);
     73a:	4505                	li	a0,1
     73c:	00005097          	auipc	ra,0x5
     740:	080080e7          	jalr	128(ra) # 57bc <exit>
          printf("%s: pipe1 oops 2\n", s);
     744:	85ca                	mv	a1,s2
     746:	00006517          	auipc	a0,0x6
     74a:	a6250513          	addi	a0,a0,-1438 # 61a8 <malloc+0x52a>
     74e:	00005097          	auipc	ra,0x5
     752:	472080e7          	jalr	1138(ra) # 5bc0 <printf>
}
     756:	60e6                	ld	ra,88(sp)
     758:	6446                	ld	s0,80(sp)
     75a:	64a6                	ld	s1,72(sp)
     75c:	6906                	ld	s2,64(sp)
     75e:	79e2                	ld	s3,56(sp)
     760:	7a42                	ld	s4,48(sp)
     762:	7aa2                	ld	s5,40(sp)
     764:	7b02                	ld	s6,32(sp)
     766:	6be2                	ld	s7,24(sp)
     768:	6125                	addi	sp,sp,96
     76a:	8082                	ret
    if(total != N * SZ){
     76c:	6785                	lui	a5,0x1
     76e:	42d78793          	addi	a5,a5,1069 # 142d <bigfile+0x67>
     772:	02fa0063          	beq	s4,a5,792 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
     776:	85d2                	mv	a1,s4
     778:	00006517          	auipc	a0,0x6
     77c:	a4850513          	addi	a0,a0,-1464 # 61c0 <malloc+0x542>
     780:	00005097          	auipc	ra,0x5
     784:	440080e7          	jalr	1088(ra) # 5bc0 <printf>
      exit(1);
     788:	4505                	li	a0,1
     78a:	00005097          	auipc	ra,0x5
     78e:	032080e7          	jalr	50(ra) # 57bc <exit>
    close(fds[0]);
     792:	fa842503          	lw	a0,-88(s0)
     796:	00005097          	auipc	ra,0x5
     79a:	04e080e7          	jalr	78(ra) # 57e4 <close>
    wait(&xstatus);
     79e:	fa440513          	addi	a0,s0,-92
     7a2:	00005097          	auipc	ra,0x5
     7a6:	022080e7          	jalr	34(ra) # 57c4 <wait>
    exit(xstatus);
     7aa:	fa442503          	lw	a0,-92(s0)
     7ae:	00005097          	auipc	ra,0x5
     7b2:	00e080e7          	jalr	14(ra) # 57bc <exit>
    printf("%s: fork() failed\n", s);
     7b6:	85ca                	mv	a1,s2
     7b8:	00006517          	auipc	a0,0x6
     7bc:	a2850513          	addi	a0,a0,-1496 # 61e0 <malloc+0x562>
     7c0:	00005097          	auipc	ra,0x5
     7c4:	400080e7          	jalr	1024(ra) # 5bc0 <printf>
    exit(1);
     7c8:	4505                	li	a0,1
     7ca:	00005097          	auipc	ra,0x5
     7ce:	ff2080e7          	jalr	-14(ra) # 57bc <exit>

00000000000007d2 <bigdir>:
{
     7d2:	715d                	addi	sp,sp,-80
     7d4:	e486                	sd	ra,72(sp)
     7d6:	e0a2                	sd	s0,64(sp)
     7d8:	fc26                	sd	s1,56(sp)
     7da:	f84a                	sd	s2,48(sp)
     7dc:	f44e                	sd	s3,40(sp)
     7de:	f052                	sd	s4,32(sp)
     7e0:	ec56                	sd	s5,24(sp)
     7e2:	e85a                	sd	s6,16(sp)
     7e4:	0880                	addi	s0,sp,80
     7e6:	89aa                	mv	s3,a0
  unlink("bd");
     7e8:	00006517          	auipc	a0,0x6
     7ec:	a1050513          	addi	a0,a0,-1520 # 61f8 <malloc+0x57a>
     7f0:	00005097          	auipc	ra,0x5
     7f4:	01c080e7          	jalr	28(ra) # 580c <unlink>
  fd = open("bd", O_CREATE);
     7f8:	20000593          	li	a1,512
     7fc:	00006517          	auipc	a0,0x6
     800:	9fc50513          	addi	a0,a0,-1540 # 61f8 <malloc+0x57a>
     804:	00005097          	auipc	ra,0x5
     808:	ff8080e7          	jalr	-8(ra) # 57fc <open>
  if(fd < 0){
     80c:	0c054963          	bltz	a0,8de <bigdir+0x10c>
  close(fd);
     810:	00005097          	auipc	ra,0x5
     814:	fd4080e7          	jalr	-44(ra) # 57e4 <close>
  for(i = 0; i < N; i++){
     818:	4901                	li	s2,0
    name[0] = 'x';
     81a:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     81e:	00006a17          	auipc	s4,0x6
     822:	9daa0a13          	addi	s4,s4,-1574 # 61f8 <malloc+0x57a>
  for(i = 0; i < N; i++){
     826:	1f400b13          	li	s6,500
    name[0] = 'x';
     82a:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     82e:	41f9579b          	sraiw	a5,s2,0x1f
     832:	01a7d71b          	srliw	a4,a5,0x1a
     836:	012707bb          	addw	a5,a4,s2
     83a:	4067d69b          	sraiw	a3,a5,0x6
     83e:	0306869b          	addiw	a3,a3,48
     842:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     846:	03f7f793          	andi	a5,a5,63
     84a:	9f99                	subw	a5,a5,a4
     84c:	0307879b          	addiw	a5,a5,48
     850:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     854:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     858:	fb040593          	addi	a1,s0,-80
     85c:	8552                	mv	a0,s4
     85e:	00005097          	auipc	ra,0x5
     862:	fbe080e7          	jalr	-66(ra) # 581c <link>
     866:	84aa                	mv	s1,a0
     868:	e949                	bnez	a0,8fa <bigdir+0x128>
  for(i = 0; i < N; i++){
     86a:	2905                	addiw	s2,s2,1
     86c:	fb691fe3          	bne	s2,s6,82a <bigdir+0x58>
  unlink("bd");
     870:	00006517          	auipc	a0,0x6
     874:	98850513          	addi	a0,a0,-1656 # 61f8 <malloc+0x57a>
     878:	00005097          	auipc	ra,0x5
     87c:	f94080e7          	jalr	-108(ra) # 580c <unlink>
    name[0] = 'x';
     880:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
     884:	1f400a13          	li	s4,500
    name[0] = 'x';
     888:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
     88c:	41f4d79b          	sraiw	a5,s1,0x1f
     890:	01a7d71b          	srliw	a4,a5,0x1a
     894:	009707bb          	addw	a5,a4,s1
     898:	4067d69b          	sraiw	a3,a5,0x6
     89c:	0306869b          	addiw	a3,a3,48
     8a0:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     8a4:	03f7f793          	andi	a5,a5,63
     8a8:	9f99                	subw	a5,a5,a4
     8aa:	0307879b          	addiw	a5,a5,48
     8ae:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     8b2:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
     8b6:	fb040513          	addi	a0,s0,-80
     8ba:	00005097          	auipc	ra,0x5
     8be:	f52080e7          	jalr	-174(ra) # 580c <unlink>
     8c2:	ed21                	bnez	a0,91a <bigdir+0x148>
  for(i = 0; i < N; i++){
     8c4:	2485                	addiw	s1,s1,1
     8c6:	fd4491e3          	bne	s1,s4,888 <bigdir+0xb6>
}
     8ca:	60a6                	ld	ra,72(sp)
     8cc:	6406                	ld	s0,64(sp)
     8ce:	74e2                	ld	s1,56(sp)
     8d0:	7942                	ld	s2,48(sp)
     8d2:	79a2                	ld	s3,40(sp)
     8d4:	7a02                	ld	s4,32(sp)
     8d6:	6ae2                	ld	s5,24(sp)
     8d8:	6b42                	ld	s6,16(sp)
     8da:	6161                	addi	sp,sp,80
     8dc:	8082                	ret
    printf("%s: bigdir create failed\n", s);
     8de:	85ce                	mv	a1,s3
     8e0:	00006517          	auipc	a0,0x6
     8e4:	92050513          	addi	a0,a0,-1760 # 6200 <malloc+0x582>
     8e8:	00005097          	auipc	ra,0x5
     8ec:	2d8080e7          	jalr	728(ra) # 5bc0 <printf>
    exit(1);
     8f0:	4505                	li	a0,1
     8f2:	00005097          	auipc	ra,0x5
     8f6:	eca080e7          	jalr	-310(ra) # 57bc <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
     8fa:	fb040613          	addi	a2,s0,-80
     8fe:	85ce                	mv	a1,s3
     900:	00006517          	auipc	a0,0x6
     904:	92050513          	addi	a0,a0,-1760 # 6220 <malloc+0x5a2>
     908:	00005097          	auipc	ra,0x5
     90c:	2b8080e7          	jalr	696(ra) # 5bc0 <printf>
      exit(1);
     910:	4505                	li	a0,1
     912:	00005097          	auipc	ra,0x5
     916:	eaa080e7          	jalr	-342(ra) # 57bc <exit>
      printf("%s: bigdir unlink failed", s);
     91a:	85ce                	mv	a1,s3
     91c:	00006517          	auipc	a0,0x6
     920:	92450513          	addi	a0,a0,-1756 # 6240 <malloc+0x5c2>
     924:	00005097          	auipc	ra,0x5
     928:	29c080e7          	jalr	668(ra) # 5bc0 <printf>
      exit(1);
     92c:	4505                	li	a0,1
     92e:	00005097          	auipc	ra,0x5
     932:	e8e080e7          	jalr	-370(ra) # 57bc <exit>

0000000000000936 <openiputtest>:
{
     936:	7179                	addi	sp,sp,-48
     938:	f406                	sd	ra,40(sp)
     93a:	f022                	sd	s0,32(sp)
     93c:	ec26                	sd	s1,24(sp)
     93e:	1800                	addi	s0,sp,48
     940:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
     942:	00006517          	auipc	a0,0x6
     946:	91e50513          	addi	a0,a0,-1762 # 6260 <malloc+0x5e2>
     94a:	00005097          	auipc	ra,0x5
     94e:	eda080e7          	jalr	-294(ra) # 5824 <mkdir>
     952:	04054263          	bltz	a0,996 <openiputtest+0x60>
  pid = fork();
     956:	00005097          	auipc	ra,0x5
     95a:	e5e080e7          	jalr	-418(ra) # 57b4 <fork>
  if(pid < 0){
     95e:	04054a63          	bltz	a0,9b2 <openiputtest+0x7c>
  if(pid == 0){
     962:	e93d                	bnez	a0,9d8 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
     964:	4589                	li	a1,2
     966:	00006517          	auipc	a0,0x6
     96a:	8fa50513          	addi	a0,a0,-1798 # 6260 <malloc+0x5e2>
     96e:	00005097          	auipc	ra,0x5
     972:	e8e080e7          	jalr	-370(ra) # 57fc <open>
    if(fd >= 0){
     976:	04054c63          	bltz	a0,9ce <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
     97a:	85a6                	mv	a1,s1
     97c:	00006517          	auipc	a0,0x6
     980:	90450513          	addi	a0,a0,-1788 # 6280 <malloc+0x602>
     984:	00005097          	auipc	ra,0x5
     988:	23c080e7          	jalr	572(ra) # 5bc0 <printf>
      exit(1);
     98c:	4505                	li	a0,1
     98e:	00005097          	auipc	ra,0x5
     992:	e2e080e7          	jalr	-466(ra) # 57bc <exit>
    printf("%s: mkdir oidir failed\n", s);
     996:	85a6                	mv	a1,s1
     998:	00006517          	auipc	a0,0x6
     99c:	8d050513          	addi	a0,a0,-1840 # 6268 <malloc+0x5ea>
     9a0:	00005097          	auipc	ra,0x5
     9a4:	220080e7          	jalr	544(ra) # 5bc0 <printf>
    exit(1);
     9a8:	4505                	li	a0,1
     9aa:	00005097          	auipc	ra,0x5
     9ae:	e12080e7          	jalr	-494(ra) # 57bc <exit>
    printf("%s: fork failed\n", s);
     9b2:	85a6                	mv	a1,s1
     9b4:	00005517          	auipc	a0,0x5
     9b8:	4cc50513          	addi	a0,a0,1228 # 5e80 <malloc+0x202>
     9bc:	00005097          	auipc	ra,0x5
     9c0:	204080e7          	jalr	516(ra) # 5bc0 <printf>
    exit(1);
     9c4:	4505                	li	a0,1
     9c6:	00005097          	auipc	ra,0x5
     9ca:	df6080e7          	jalr	-522(ra) # 57bc <exit>
    exit(0);
     9ce:	4501                	li	a0,0
     9d0:	00005097          	auipc	ra,0x5
     9d4:	dec080e7          	jalr	-532(ra) # 57bc <exit>
  sleep(1);
     9d8:	4505                	li	a0,1
     9da:	00005097          	auipc	ra,0x5
     9de:	e72080e7          	jalr	-398(ra) # 584c <sleep>
  if(unlink("oidir") != 0){
     9e2:	00006517          	auipc	a0,0x6
     9e6:	87e50513          	addi	a0,a0,-1922 # 6260 <malloc+0x5e2>
     9ea:	00005097          	auipc	ra,0x5
     9ee:	e22080e7          	jalr	-478(ra) # 580c <unlink>
     9f2:	cd19                	beqz	a0,a10 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
     9f4:	85a6                	mv	a1,s1
     9f6:	00006517          	auipc	a0,0x6
     9fa:	8b250513          	addi	a0,a0,-1870 # 62a8 <malloc+0x62a>
     9fe:	00005097          	auipc	ra,0x5
     a02:	1c2080e7          	jalr	450(ra) # 5bc0 <printf>
    exit(1);
     a06:	4505                	li	a0,1
     a08:	00005097          	auipc	ra,0x5
     a0c:	db4080e7          	jalr	-588(ra) # 57bc <exit>
  wait(&xstatus);
     a10:	fdc40513          	addi	a0,s0,-36
     a14:	00005097          	auipc	ra,0x5
     a18:	db0080e7          	jalr	-592(ra) # 57c4 <wait>
  exit(xstatus);
     a1c:	fdc42503          	lw	a0,-36(s0)
     a20:	00005097          	auipc	ra,0x5
     a24:	d9c080e7          	jalr	-612(ra) # 57bc <exit>

0000000000000a28 <fourteen>:
{
     a28:	1101                	addi	sp,sp,-32
     a2a:	ec06                	sd	ra,24(sp)
     a2c:	e822                	sd	s0,16(sp)
     a2e:	e426                	sd	s1,8(sp)
     a30:	1000                	addi	s0,sp,32
     a32:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
     a34:	00006517          	auipc	a0,0x6
     a38:	a5c50513          	addi	a0,a0,-1444 # 6490 <malloc+0x812>
     a3c:	00005097          	auipc	ra,0x5
     a40:	de8080e7          	jalr	-536(ra) # 5824 <mkdir>
     a44:	e165                	bnez	a0,b24 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
     a46:	00006517          	auipc	a0,0x6
     a4a:	8a250513          	addi	a0,a0,-1886 # 62e8 <malloc+0x66a>
     a4e:	00005097          	auipc	ra,0x5
     a52:	dd6080e7          	jalr	-554(ra) # 5824 <mkdir>
     a56:	e56d                	bnez	a0,b40 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
     a58:	20000593          	li	a1,512
     a5c:	00006517          	auipc	a0,0x6
     a60:	8e450513          	addi	a0,a0,-1820 # 6340 <malloc+0x6c2>
     a64:	00005097          	auipc	ra,0x5
     a68:	d98080e7          	jalr	-616(ra) # 57fc <open>
  if(fd < 0){
     a6c:	0e054863          	bltz	a0,b5c <fourteen+0x134>
  close(fd);
     a70:	00005097          	auipc	ra,0x5
     a74:	d74080e7          	jalr	-652(ra) # 57e4 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
     a78:	4581                	li	a1,0
     a7a:	00006517          	auipc	a0,0x6
     a7e:	93e50513          	addi	a0,a0,-1730 # 63b8 <malloc+0x73a>
     a82:	00005097          	auipc	ra,0x5
     a86:	d7a080e7          	jalr	-646(ra) # 57fc <open>
  if(fd < 0){
     a8a:	0e054763          	bltz	a0,b78 <fourteen+0x150>
  close(fd);
     a8e:	00005097          	auipc	ra,0x5
     a92:	d56080e7          	jalr	-682(ra) # 57e4 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
     a96:	00006517          	auipc	a0,0x6
     a9a:	99250513          	addi	a0,a0,-1646 # 6428 <malloc+0x7aa>
     a9e:	00005097          	auipc	ra,0x5
     aa2:	d86080e7          	jalr	-634(ra) # 5824 <mkdir>
     aa6:	c57d                	beqz	a0,b94 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
     aa8:	00006517          	auipc	a0,0x6
     aac:	9d850513          	addi	a0,a0,-1576 # 6480 <malloc+0x802>
     ab0:	00005097          	auipc	ra,0x5
     ab4:	d74080e7          	jalr	-652(ra) # 5824 <mkdir>
     ab8:	cd65                	beqz	a0,bb0 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
     aba:	00006517          	auipc	a0,0x6
     abe:	9c650513          	addi	a0,a0,-1594 # 6480 <malloc+0x802>
     ac2:	00005097          	auipc	ra,0x5
     ac6:	d4a080e7          	jalr	-694(ra) # 580c <unlink>
  unlink("12345678901234/12345678901234");
     aca:	00006517          	auipc	a0,0x6
     ace:	95e50513          	addi	a0,a0,-1698 # 6428 <malloc+0x7aa>
     ad2:	00005097          	auipc	ra,0x5
     ad6:	d3a080e7          	jalr	-710(ra) # 580c <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
     ada:	00006517          	auipc	a0,0x6
     ade:	8de50513          	addi	a0,a0,-1826 # 63b8 <malloc+0x73a>
     ae2:	00005097          	auipc	ra,0x5
     ae6:	d2a080e7          	jalr	-726(ra) # 580c <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
     aea:	00006517          	auipc	a0,0x6
     aee:	85650513          	addi	a0,a0,-1962 # 6340 <malloc+0x6c2>
     af2:	00005097          	auipc	ra,0x5
     af6:	d1a080e7          	jalr	-742(ra) # 580c <unlink>
  unlink("12345678901234/123456789012345");
     afa:	00005517          	auipc	a0,0x5
     afe:	7ee50513          	addi	a0,a0,2030 # 62e8 <malloc+0x66a>
     b02:	00005097          	auipc	ra,0x5
     b06:	d0a080e7          	jalr	-758(ra) # 580c <unlink>
  unlink("12345678901234");
     b0a:	00006517          	auipc	a0,0x6
     b0e:	98650513          	addi	a0,a0,-1658 # 6490 <malloc+0x812>
     b12:	00005097          	auipc	ra,0x5
     b16:	cfa080e7          	jalr	-774(ra) # 580c <unlink>
}
     b1a:	60e2                	ld	ra,24(sp)
     b1c:	6442                	ld	s0,16(sp)
     b1e:	64a2                	ld	s1,8(sp)
     b20:	6105                	addi	sp,sp,32
     b22:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
     b24:	85a6                	mv	a1,s1
     b26:	00005517          	auipc	a0,0x5
     b2a:	79a50513          	addi	a0,a0,1946 # 62c0 <malloc+0x642>
     b2e:	00005097          	auipc	ra,0x5
     b32:	092080e7          	jalr	146(ra) # 5bc0 <printf>
    exit(1);
     b36:	4505                	li	a0,1
     b38:	00005097          	auipc	ra,0x5
     b3c:	c84080e7          	jalr	-892(ra) # 57bc <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
     b40:	85a6                	mv	a1,s1
     b42:	00005517          	auipc	a0,0x5
     b46:	7c650513          	addi	a0,a0,1990 # 6308 <malloc+0x68a>
     b4a:	00005097          	auipc	ra,0x5
     b4e:	076080e7          	jalr	118(ra) # 5bc0 <printf>
    exit(1);
     b52:	4505                	li	a0,1
     b54:	00005097          	auipc	ra,0x5
     b58:	c68080e7          	jalr	-920(ra) # 57bc <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
     b5c:	85a6                	mv	a1,s1
     b5e:	00006517          	auipc	a0,0x6
     b62:	81250513          	addi	a0,a0,-2030 # 6370 <malloc+0x6f2>
     b66:	00005097          	auipc	ra,0x5
     b6a:	05a080e7          	jalr	90(ra) # 5bc0 <printf>
    exit(1);
     b6e:	4505                	li	a0,1
     b70:	00005097          	auipc	ra,0x5
     b74:	c4c080e7          	jalr	-948(ra) # 57bc <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
     b78:	85a6                	mv	a1,s1
     b7a:	00006517          	auipc	a0,0x6
     b7e:	86e50513          	addi	a0,a0,-1938 # 63e8 <malloc+0x76a>
     b82:	00005097          	auipc	ra,0x5
     b86:	03e080e7          	jalr	62(ra) # 5bc0 <printf>
    exit(1);
     b8a:	4505                	li	a0,1
     b8c:	00005097          	auipc	ra,0x5
     b90:	c30080e7          	jalr	-976(ra) # 57bc <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
     b94:	85a6                	mv	a1,s1
     b96:	00006517          	auipc	a0,0x6
     b9a:	8b250513          	addi	a0,a0,-1870 # 6448 <malloc+0x7ca>
     b9e:	00005097          	auipc	ra,0x5
     ba2:	022080e7          	jalr	34(ra) # 5bc0 <printf>
    exit(1);
     ba6:	4505                	li	a0,1
     ba8:	00005097          	auipc	ra,0x5
     bac:	c14080e7          	jalr	-1004(ra) # 57bc <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
     bb0:	85a6                	mv	a1,s1
     bb2:	00006517          	auipc	a0,0x6
     bb6:	8ee50513          	addi	a0,a0,-1810 # 64a0 <malloc+0x822>
     bba:	00005097          	auipc	ra,0x5
     bbe:	006080e7          	jalr	6(ra) # 5bc0 <printf>
    exit(1);
     bc2:	4505                	li	a0,1
     bc4:	00005097          	auipc	ra,0x5
     bc8:	bf8080e7          	jalr	-1032(ra) # 57bc <exit>

0000000000000bcc <iputtest>:
{
     bcc:	1101                	addi	sp,sp,-32
     bce:	ec06                	sd	ra,24(sp)
     bd0:	e822                	sd	s0,16(sp)
     bd2:	e426                	sd	s1,8(sp)
     bd4:	1000                	addi	s0,sp,32
     bd6:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
     bd8:	00006517          	auipc	a0,0x6
     bdc:	90050513          	addi	a0,a0,-1792 # 64d8 <malloc+0x85a>
     be0:	00005097          	auipc	ra,0x5
     be4:	c44080e7          	jalr	-956(ra) # 5824 <mkdir>
     be8:	04054563          	bltz	a0,c32 <iputtest+0x66>
  if(chdir("iputdir") < 0){
     bec:	00006517          	auipc	a0,0x6
     bf0:	8ec50513          	addi	a0,a0,-1812 # 64d8 <malloc+0x85a>
     bf4:	00005097          	auipc	ra,0x5
     bf8:	c38080e7          	jalr	-968(ra) # 582c <chdir>
     bfc:	04054963          	bltz	a0,c4e <iputtest+0x82>
  if(unlink("../iputdir") < 0){
     c00:	00006517          	auipc	a0,0x6
     c04:	91850513          	addi	a0,a0,-1768 # 6518 <malloc+0x89a>
     c08:	00005097          	auipc	ra,0x5
     c0c:	c04080e7          	jalr	-1020(ra) # 580c <unlink>
     c10:	04054d63          	bltz	a0,c6a <iputtest+0x9e>
  if(chdir("/") < 0){
     c14:	00006517          	auipc	a0,0x6
     c18:	93450513          	addi	a0,a0,-1740 # 6548 <malloc+0x8ca>
     c1c:	00005097          	auipc	ra,0x5
     c20:	c10080e7          	jalr	-1008(ra) # 582c <chdir>
     c24:	06054163          	bltz	a0,c86 <iputtest+0xba>
}
     c28:	60e2                	ld	ra,24(sp)
     c2a:	6442                	ld	s0,16(sp)
     c2c:	64a2                	ld	s1,8(sp)
     c2e:	6105                	addi	sp,sp,32
     c30:	8082                	ret
    printf("%s: mkdir failed\n", s);
     c32:	85a6                	mv	a1,s1
     c34:	00006517          	auipc	a0,0x6
     c38:	8ac50513          	addi	a0,a0,-1876 # 64e0 <malloc+0x862>
     c3c:	00005097          	auipc	ra,0x5
     c40:	f84080e7          	jalr	-124(ra) # 5bc0 <printf>
    exit(1);
     c44:	4505                	li	a0,1
     c46:	00005097          	auipc	ra,0x5
     c4a:	b76080e7          	jalr	-1162(ra) # 57bc <exit>
    printf("%s: chdir iputdir failed\n", s);
     c4e:	85a6                	mv	a1,s1
     c50:	00006517          	auipc	a0,0x6
     c54:	8a850513          	addi	a0,a0,-1880 # 64f8 <malloc+0x87a>
     c58:	00005097          	auipc	ra,0x5
     c5c:	f68080e7          	jalr	-152(ra) # 5bc0 <printf>
    exit(1);
     c60:	4505                	li	a0,1
     c62:	00005097          	auipc	ra,0x5
     c66:	b5a080e7          	jalr	-1190(ra) # 57bc <exit>
    printf("%s: unlink ../iputdir failed\n", s);
     c6a:	85a6                	mv	a1,s1
     c6c:	00006517          	auipc	a0,0x6
     c70:	8bc50513          	addi	a0,a0,-1860 # 6528 <malloc+0x8aa>
     c74:	00005097          	auipc	ra,0x5
     c78:	f4c080e7          	jalr	-180(ra) # 5bc0 <printf>
    exit(1);
     c7c:	4505                	li	a0,1
     c7e:	00005097          	auipc	ra,0x5
     c82:	b3e080e7          	jalr	-1218(ra) # 57bc <exit>
    printf("%s: chdir / failed\n", s);
     c86:	85a6                	mv	a1,s1
     c88:	00006517          	auipc	a0,0x6
     c8c:	8c850513          	addi	a0,a0,-1848 # 6550 <malloc+0x8d2>
     c90:	00005097          	auipc	ra,0x5
     c94:	f30080e7          	jalr	-208(ra) # 5bc0 <printf>
    exit(1);
     c98:	4505                	li	a0,1
     c9a:	00005097          	auipc	ra,0x5
     c9e:	b22080e7          	jalr	-1246(ra) # 57bc <exit>

0000000000000ca2 <exitiputtest>:
{
     ca2:	7179                	addi	sp,sp,-48
     ca4:	f406                	sd	ra,40(sp)
     ca6:	f022                	sd	s0,32(sp)
     ca8:	ec26                	sd	s1,24(sp)
     caa:	1800                	addi	s0,sp,48
     cac:	84aa                	mv	s1,a0
  pid = fork();
     cae:	00005097          	auipc	ra,0x5
     cb2:	b06080e7          	jalr	-1274(ra) # 57b4 <fork>
  if(pid < 0){
     cb6:	04054663          	bltz	a0,d02 <exitiputtest+0x60>
  if(pid == 0){
     cba:	ed45                	bnez	a0,d72 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
     cbc:	00006517          	auipc	a0,0x6
     cc0:	81c50513          	addi	a0,a0,-2020 # 64d8 <malloc+0x85a>
     cc4:	00005097          	auipc	ra,0x5
     cc8:	b60080e7          	jalr	-1184(ra) # 5824 <mkdir>
     ccc:	04054963          	bltz	a0,d1e <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
     cd0:	00006517          	auipc	a0,0x6
     cd4:	80850513          	addi	a0,a0,-2040 # 64d8 <malloc+0x85a>
     cd8:	00005097          	auipc	ra,0x5
     cdc:	b54080e7          	jalr	-1196(ra) # 582c <chdir>
     ce0:	04054d63          	bltz	a0,d3a <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
     ce4:	00006517          	auipc	a0,0x6
     ce8:	83450513          	addi	a0,a0,-1996 # 6518 <malloc+0x89a>
     cec:	00005097          	auipc	ra,0x5
     cf0:	b20080e7          	jalr	-1248(ra) # 580c <unlink>
     cf4:	06054163          	bltz	a0,d56 <exitiputtest+0xb4>
    exit(0);
     cf8:	4501                	li	a0,0
     cfa:	00005097          	auipc	ra,0x5
     cfe:	ac2080e7          	jalr	-1342(ra) # 57bc <exit>
    printf("%s: fork failed\n", s);
     d02:	85a6                	mv	a1,s1
     d04:	00005517          	auipc	a0,0x5
     d08:	17c50513          	addi	a0,a0,380 # 5e80 <malloc+0x202>
     d0c:	00005097          	auipc	ra,0x5
     d10:	eb4080e7          	jalr	-332(ra) # 5bc0 <printf>
    exit(1);
     d14:	4505                	li	a0,1
     d16:	00005097          	auipc	ra,0x5
     d1a:	aa6080e7          	jalr	-1370(ra) # 57bc <exit>
      printf("%s: mkdir failed\n", s);
     d1e:	85a6                	mv	a1,s1
     d20:	00005517          	auipc	a0,0x5
     d24:	7c050513          	addi	a0,a0,1984 # 64e0 <malloc+0x862>
     d28:	00005097          	auipc	ra,0x5
     d2c:	e98080e7          	jalr	-360(ra) # 5bc0 <printf>
      exit(1);
     d30:	4505                	li	a0,1
     d32:	00005097          	auipc	ra,0x5
     d36:	a8a080e7          	jalr	-1398(ra) # 57bc <exit>
      printf("%s: child chdir failed\n", s);
     d3a:	85a6                	mv	a1,s1
     d3c:	00006517          	auipc	a0,0x6
     d40:	82c50513          	addi	a0,a0,-2004 # 6568 <malloc+0x8ea>
     d44:	00005097          	auipc	ra,0x5
     d48:	e7c080e7          	jalr	-388(ra) # 5bc0 <printf>
      exit(1);
     d4c:	4505                	li	a0,1
     d4e:	00005097          	auipc	ra,0x5
     d52:	a6e080e7          	jalr	-1426(ra) # 57bc <exit>
      printf("%s: unlink ../iputdir failed\n", s);
     d56:	85a6                	mv	a1,s1
     d58:	00005517          	auipc	a0,0x5
     d5c:	7d050513          	addi	a0,a0,2000 # 6528 <malloc+0x8aa>
     d60:	00005097          	auipc	ra,0x5
     d64:	e60080e7          	jalr	-416(ra) # 5bc0 <printf>
      exit(1);
     d68:	4505                	li	a0,1
     d6a:	00005097          	auipc	ra,0x5
     d6e:	a52080e7          	jalr	-1454(ra) # 57bc <exit>
  wait(&xstatus);
     d72:	fdc40513          	addi	a0,s0,-36
     d76:	00005097          	auipc	ra,0x5
     d7a:	a4e080e7          	jalr	-1458(ra) # 57c4 <wait>
  exit(xstatus);
     d7e:	fdc42503          	lw	a0,-36(s0)
     d82:	00005097          	auipc	ra,0x5
     d86:	a3a080e7          	jalr	-1478(ra) # 57bc <exit>

0000000000000d8a <rmdot>:
{
     d8a:	1101                	addi	sp,sp,-32
     d8c:	ec06                	sd	ra,24(sp)
     d8e:	e822                	sd	s0,16(sp)
     d90:	e426                	sd	s1,8(sp)
     d92:	1000                	addi	s0,sp,32
     d94:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
     d96:	00005517          	auipc	a0,0x5
     d9a:	7ea50513          	addi	a0,a0,2026 # 6580 <malloc+0x902>
     d9e:	00005097          	auipc	ra,0x5
     da2:	a86080e7          	jalr	-1402(ra) # 5824 <mkdir>
     da6:	e549                	bnez	a0,e30 <rmdot+0xa6>
  if(chdir("dots") != 0){
     da8:	00005517          	auipc	a0,0x5
     dac:	7d850513          	addi	a0,a0,2008 # 6580 <malloc+0x902>
     db0:	00005097          	auipc	ra,0x5
     db4:	a7c080e7          	jalr	-1412(ra) # 582c <chdir>
     db8:	e951                	bnez	a0,e4c <rmdot+0xc2>
  if(unlink(".") == 0){
     dba:	00005517          	auipc	a0,0x5
     dbe:	7fe50513          	addi	a0,a0,2046 # 65b8 <malloc+0x93a>
     dc2:	00005097          	auipc	ra,0x5
     dc6:	a4a080e7          	jalr	-1462(ra) # 580c <unlink>
     dca:	cd59                	beqz	a0,e68 <rmdot+0xde>
  if(unlink("..") == 0){
     dcc:	00006517          	auipc	a0,0x6
     dd0:	80c50513          	addi	a0,a0,-2036 # 65d8 <malloc+0x95a>
     dd4:	00005097          	auipc	ra,0x5
     dd8:	a38080e7          	jalr	-1480(ra) # 580c <unlink>
     ddc:	c545                	beqz	a0,e84 <rmdot+0xfa>
  if(chdir("/") != 0){
     dde:	00005517          	auipc	a0,0x5
     de2:	76a50513          	addi	a0,a0,1898 # 6548 <malloc+0x8ca>
     de6:	00005097          	auipc	ra,0x5
     dea:	a46080e7          	jalr	-1466(ra) # 582c <chdir>
     dee:	e94d                	bnez	a0,ea0 <rmdot+0x116>
  if(unlink("dots/.") == 0){
     df0:	00006517          	auipc	a0,0x6
     df4:	80850513          	addi	a0,a0,-2040 # 65f8 <malloc+0x97a>
     df8:	00005097          	auipc	ra,0x5
     dfc:	a14080e7          	jalr	-1516(ra) # 580c <unlink>
     e00:	cd55                	beqz	a0,ebc <rmdot+0x132>
  if(unlink("dots/..") == 0){
     e02:	00006517          	auipc	a0,0x6
     e06:	81e50513          	addi	a0,a0,-2018 # 6620 <malloc+0x9a2>
     e0a:	00005097          	auipc	ra,0x5
     e0e:	a02080e7          	jalr	-1534(ra) # 580c <unlink>
     e12:	c179                	beqz	a0,ed8 <rmdot+0x14e>
  if(unlink("dots") != 0){
     e14:	00005517          	auipc	a0,0x5
     e18:	76c50513          	addi	a0,a0,1900 # 6580 <malloc+0x902>
     e1c:	00005097          	auipc	ra,0x5
     e20:	9f0080e7          	jalr	-1552(ra) # 580c <unlink>
     e24:	e961                	bnez	a0,ef4 <rmdot+0x16a>
}
     e26:	60e2                	ld	ra,24(sp)
     e28:	6442                	ld	s0,16(sp)
     e2a:	64a2                	ld	s1,8(sp)
     e2c:	6105                	addi	sp,sp,32
     e2e:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
     e30:	85a6                	mv	a1,s1
     e32:	00005517          	auipc	a0,0x5
     e36:	75650513          	addi	a0,a0,1878 # 6588 <malloc+0x90a>
     e3a:	00005097          	auipc	ra,0x5
     e3e:	d86080e7          	jalr	-634(ra) # 5bc0 <printf>
    exit(1);
     e42:	4505                	li	a0,1
     e44:	00005097          	auipc	ra,0x5
     e48:	978080e7          	jalr	-1672(ra) # 57bc <exit>
    printf("%s: chdir dots failed\n", s);
     e4c:	85a6                	mv	a1,s1
     e4e:	00005517          	auipc	a0,0x5
     e52:	75250513          	addi	a0,a0,1874 # 65a0 <malloc+0x922>
     e56:	00005097          	auipc	ra,0x5
     e5a:	d6a080e7          	jalr	-662(ra) # 5bc0 <printf>
    exit(1);
     e5e:	4505                	li	a0,1
     e60:	00005097          	auipc	ra,0x5
     e64:	95c080e7          	jalr	-1700(ra) # 57bc <exit>
    printf("%s: rm . worked!\n", s);
     e68:	85a6                	mv	a1,s1
     e6a:	00005517          	auipc	a0,0x5
     e6e:	75650513          	addi	a0,a0,1878 # 65c0 <malloc+0x942>
     e72:	00005097          	auipc	ra,0x5
     e76:	d4e080e7          	jalr	-690(ra) # 5bc0 <printf>
    exit(1);
     e7a:	4505                	li	a0,1
     e7c:	00005097          	auipc	ra,0x5
     e80:	940080e7          	jalr	-1728(ra) # 57bc <exit>
    printf("%s: rm .. worked!\n", s);
     e84:	85a6                	mv	a1,s1
     e86:	00005517          	auipc	a0,0x5
     e8a:	75a50513          	addi	a0,a0,1882 # 65e0 <malloc+0x962>
     e8e:	00005097          	auipc	ra,0x5
     e92:	d32080e7          	jalr	-718(ra) # 5bc0 <printf>
    exit(1);
     e96:	4505                	li	a0,1
     e98:	00005097          	auipc	ra,0x5
     e9c:	924080e7          	jalr	-1756(ra) # 57bc <exit>
    printf("%s: chdir / failed\n", s);
     ea0:	85a6                	mv	a1,s1
     ea2:	00005517          	auipc	a0,0x5
     ea6:	6ae50513          	addi	a0,a0,1710 # 6550 <malloc+0x8d2>
     eaa:	00005097          	auipc	ra,0x5
     eae:	d16080e7          	jalr	-746(ra) # 5bc0 <printf>
    exit(1);
     eb2:	4505                	li	a0,1
     eb4:	00005097          	auipc	ra,0x5
     eb8:	908080e7          	jalr	-1784(ra) # 57bc <exit>
    printf("%s: unlink dots/. worked!\n", s);
     ebc:	85a6                	mv	a1,s1
     ebe:	00005517          	auipc	a0,0x5
     ec2:	74250513          	addi	a0,a0,1858 # 6600 <malloc+0x982>
     ec6:	00005097          	auipc	ra,0x5
     eca:	cfa080e7          	jalr	-774(ra) # 5bc0 <printf>
    exit(1);
     ece:	4505                	li	a0,1
     ed0:	00005097          	auipc	ra,0x5
     ed4:	8ec080e7          	jalr	-1812(ra) # 57bc <exit>
    printf("%s: unlink dots/.. worked!\n", s);
     ed8:	85a6                	mv	a1,s1
     eda:	00005517          	auipc	a0,0x5
     ede:	74e50513          	addi	a0,a0,1870 # 6628 <malloc+0x9aa>
     ee2:	00005097          	auipc	ra,0x5
     ee6:	cde080e7          	jalr	-802(ra) # 5bc0 <printf>
    exit(1);
     eea:	4505                	li	a0,1
     eec:	00005097          	auipc	ra,0x5
     ef0:	8d0080e7          	jalr	-1840(ra) # 57bc <exit>
    printf("%s: unlink dots failed!\n", s);
     ef4:	85a6                	mv	a1,s1
     ef6:	00005517          	auipc	a0,0x5
     efa:	75250513          	addi	a0,a0,1874 # 6648 <malloc+0x9ca>
     efe:	00005097          	auipc	ra,0x5
     f02:	cc2080e7          	jalr	-830(ra) # 5bc0 <printf>
    exit(1);
     f06:	4505                	li	a0,1
     f08:	00005097          	auipc	ra,0x5
     f0c:	8b4080e7          	jalr	-1868(ra) # 57bc <exit>

0000000000000f10 <dirfile>:
{
     f10:	1101                	addi	sp,sp,-32
     f12:	ec06                	sd	ra,24(sp)
     f14:	e822                	sd	s0,16(sp)
     f16:	e426                	sd	s1,8(sp)
     f18:	e04a                	sd	s2,0(sp)
     f1a:	1000                	addi	s0,sp,32
     f1c:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
     f1e:	20000593          	li	a1,512
     f22:	00005517          	auipc	a0,0x5
     f26:	f1e50513          	addi	a0,a0,-226 # 5e40 <malloc+0x1c2>
     f2a:	00005097          	auipc	ra,0x5
     f2e:	8d2080e7          	jalr	-1838(ra) # 57fc <open>
  if(fd < 0){
     f32:	0e054d63          	bltz	a0,102c <dirfile+0x11c>
  close(fd);
     f36:	00005097          	auipc	ra,0x5
     f3a:	8ae080e7          	jalr	-1874(ra) # 57e4 <close>
  if(chdir("dirfile") == 0){
     f3e:	00005517          	auipc	a0,0x5
     f42:	f0250513          	addi	a0,a0,-254 # 5e40 <malloc+0x1c2>
     f46:	00005097          	auipc	ra,0x5
     f4a:	8e6080e7          	jalr	-1818(ra) # 582c <chdir>
     f4e:	cd6d                	beqz	a0,1048 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
     f50:	4581                	li	a1,0
     f52:	00005517          	auipc	a0,0x5
     f56:	75650513          	addi	a0,a0,1878 # 66a8 <malloc+0xa2a>
     f5a:	00005097          	auipc	ra,0x5
     f5e:	8a2080e7          	jalr	-1886(ra) # 57fc <open>
  if(fd >= 0){
     f62:	10055163          	bgez	a0,1064 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
     f66:	20000593          	li	a1,512
     f6a:	00005517          	auipc	a0,0x5
     f6e:	73e50513          	addi	a0,a0,1854 # 66a8 <malloc+0xa2a>
     f72:	00005097          	auipc	ra,0x5
     f76:	88a080e7          	jalr	-1910(ra) # 57fc <open>
  if(fd >= 0){
     f7a:	10055363          	bgez	a0,1080 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
     f7e:	00005517          	auipc	a0,0x5
     f82:	72a50513          	addi	a0,a0,1834 # 66a8 <malloc+0xa2a>
     f86:	00005097          	auipc	ra,0x5
     f8a:	89e080e7          	jalr	-1890(ra) # 5824 <mkdir>
     f8e:	10050763          	beqz	a0,109c <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
     f92:	00005517          	auipc	a0,0x5
     f96:	71650513          	addi	a0,a0,1814 # 66a8 <malloc+0xa2a>
     f9a:	00005097          	auipc	ra,0x5
     f9e:	872080e7          	jalr	-1934(ra) # 580c <unlink>
     fa2:	10050b63          	beqz	a0,10b8 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
     fa6:	00005597          	auipc	a1,0x5
     faa:	70258593          	addi	a1,a1,1794 # 66a8 <malloc+0xa2a>
     fae:	00005517          	auipc	a0,0x5
     fb2:	78250513          	addi	a0,a0,1922 # 6730 <malloc+0xab2>
     fb6:	00005097          	auipc	ra,0x5
     fba:	866080e7          	jalr	-1946(ra) # 581c <link>
     fbe:	10050b63          	beqz	a0,10d4 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
     fc2:	00005517          	auipc	a0,0x5
     fc6:	e7e50513          	addi	a0,a0,-386 # 5e40 <malloc+0x1c2>
     fca:	00005097          	auipc	ra,0x5
     fce:	842080e7          	jalr	-1982(ra) # 580c <unlink>
     fd2:	10051f63          	bnez	a0,10f0 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
     fd6:	4589                	li	a1,2
     fd8:	00005517          	auipc	a0,0x5
     fdc:	5e050513          	addi	a0,a0,1504 # 65b8 <malloc+0x93a>
     fe0:	00005097          	auipc	ra,0x5
     fe4:	81c080e7          	jalr	-2020(ra) # 57fc <open>
  if(fd >= 0){
     fe8:	12055263          	bgez	a0,110c <dirfile+0x1fc>
  fd = open(".", 0);
     fec:	4581                	li	a1,0
     fee:	00005517          	auipc	a0,0x5
     ff2:	5ca50513          	addi	a0,a0,1482 # 65b8 <malloc+0x93a>
     ff6:	00005097          	auipc	ra,0x5
     ffa:	806080e7          	jalr	-2042(ra) # 57fc <open>
     ffe:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    1000:	4605                	li	a2,1
    1002:	00005597          	auipc	a1,0x5
    1006:	7a658593          	addi	a1,a1,1958 # 67a8 <malloc+0xb2a>
    100a:	00004097          	auipc	ra,0x4
    100e:	7d2080e7          	jalr	2002(ra) # 57dc <write>
    1012:	10a04b63          	bgtz	a0,1128 <dirfile+0x218>
  close(fd);
    1016:	8526                	mv	a0,s1
    1018:	00004097          	auipc	ra,0x4
    101c:	7cc080e7          	jalr	1996(ra) # 57e4 <close>
}
    1020:	60e2                	ld	ra,24(sp)
    1022:	6442                	ld	s0,16(sp)
    1024:	64a2                	ld	s1,8(sp)
    1026:	6902                	ld	s2,0(sp)
    1028:	6105                	addi	sp,sp,32
    102a:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    102c:	85ca                	mv	a1,s2
    102e:	00005517          	auipc	a0,0x5
    1032:	63a50513          	addi	a0,a0,1594 # 6668 <malloc+0x9ea>
    1036:	00005097          	auipc	ra,0x5
    103a:	b8a080e7          	jalr	-1142(ra) # 5bc0 <printf>
    exit(1);
    103e:	4505                	li	a0,1
    1040:	00004097          	auipc	ra,0x4
    1044:	77c080e7          	jalr	1916(ra) # 57bc <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    1048:	85ca                	mv	a1,s2
    104a:	00005517          	auipc	a0,0x5
    104e:	63e50513          	addi	a0,a0,1598 # 6688 <malloc+0xa0a>
    1052:	00005097          	auipc	ra,0x5
    1056:	b6e080e7          	jalr	-1170(ra) # 5bc0 <printf>
    exit(1);
    105a:	4505                	li	a0,1
    105c:	00004097          	auipc	ra,0x4
    1060:	760080e7          	jalr	1888(ra) # 57bc <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    1064:	85ca                	mv	a1,s2
    1066:	00005517          	auipc	a0,0x5
    106a:	65250513          	addi	a0,a0,1618 # 66b8 <malloc+0xa3a>
    106e:	00005097          	auipc	ra,0x5
    1072:	b52080e7          	jalr	-1198(ra) # 5bc0 <printf>
    exit(1);
    1076:	4505                	li	a0,1
    1078:	00004097          	auipc	ra,0x4
    107c:	744080e7          	jalr	1860(ra) # 57bc <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    1080:	85ca                	mv	a1,s2
    1082:	00005517          	auipc	a0,0x5
    1086:	63650513          	addi	a0,a0,1590 # 66b8 <malloc+0xa3a>
    108a:	00005097          	auipc	ra,0x5
    108e:	b36080e7          	jalr	-1226(ra) # 5bc0 <printf>
    exit(1);
    1092:	4505                	li	a0,1
    1094:	00004097          	auipc	ra,0x4
    1098:	728080e7          	jalr	1832(ra) # 57bc <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    109c:	85ca                	mv	a1,s2
    109e:	00005517          	auipc	a0,0x5
    10a2:	64250513          	addi	a0,a0,1602 # 66e0 <malloc+0xa62>
    10a6:	00005097          	auipc	ra,0x5
    10aa:	b1a080e7          	jalr	-1254(ra) # 5bc0 <printf>
    exit(1);
    10ae:	4505                	li	a0,1
    10b0:	00004097          	auipc	ra,0x4
    10b4:	70c080e7          	jalr	1804(ra) # 57bc <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    10b8:	85ca                	mv	a1,s2
    10ba:	00005517          	auipc	a0,0x5
    10be:	64e50513          	addi	a0,a0,1614 # 6708 <malloc+0xa8a>
    10c2:	00005097          	auipc	ra,0x5
    10c6:	afe080e7          	jalr	-1282(ra) # 5bc0 <printf>
    exit(1);
    10ca:	4505                	li	a0,1
    10cc:	00004097          	auipc	ra,0x4
    10d0:	6f0080e7          	jalr	1776(ra) # 57bc <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    10d4:	85ca                	mv	a1,s2
    10d6:	00005517          	auipc	a0,0x5
    10da:	66250513          	addi	a0,a0,1634 # 6738 <malloc+0xaba>
    10de:	00005097          	auipc	ra,0x5
    10e2:	ae2080e7          	jalr	-1310(ra) # 5bc0 <printf>
    exit(1);
    10e6:	4505                	li	a0,1
    10e8:	00004097          	auipc	ra,0x4
    10ec:	6d4080e7          	jalr	1748(ra) # 57bc <exit>
    printf("%s: unlink dirfile failed!\n", s);
    10f0:	85ca                	mv	a1,s2
    10f2:	00005517          	auipc	a0,0x5
    10f6:	66e50513          	addi	a0,a0,1646 # 6760 <malloc+0xae2>
    10fa:	00005097          	auipc	ra,0x5
    10fe:	ac6080e7          	jalr	-1338(ra) # 5bc0 <printf>
    exit(1);
    1102:	4505                	li	a0,1
    1104:	00004097          	auipc	ra,0x4
    1108:	6b8080e7          	jalr	1720(ra) # 57bc <exit>
    printf("%s: open . for writing succeeded!\n", s);
    110c:	85ca                	mv	a1,s2
    110e:	00005517          	auipc	a0,0x5
    1112:	67250513          	addi	a0,a0,1650 # 6780 <malloc+0xb02>
    1116:	00005097          	auipc	ra,0x5
    111a:	aaa080e7          	jalr	-1366(ra) # 5bc0 <printf>
    exit(1);
    111e:	4505                	li	a0,1
    1120:	00004097          	auipc	ra,0x4
    1124:	69c080e7          	jalr	1692(ra) # 57bc <exit>
    printf("%s: write . succeeded!\n", s);
    1128:	85ca                	mv	a1,s2
    112a:	00005517          	auipc	a0,0x5
    112e:	68650513          	addi	a0,a0,1670 # 67b0 <malloc+0xb32>
    1132:	00005097          	auipc	ra,0x5
    1136:	a8e080e7          	jalr	-1394(ra) # 5bc0 <printf>
    exit(1);
    113a:	4505                	li	a0,1
    113c:	00004097          	auipc	ra,0x4
    1140:	680080e7          	jalr	1664(ra) # 57bc <exit>

0000000000001144 <iref>:
{
    1144:	7139                	addi	sp,sp,-64
    1146:	fc06                	sd	ra,56(sp)
    1148:	f822                	sd	s0,48(sp)
    114a:	f426                	sd	s1,40(sp)
    114c:	f04a                	sd	s2,32(sp)
    114e:	ec4e                	sd	s3,24(sp)
    1150:	e852                	sd	s4,16(sp)
    1152:	e456                	sd	s5,8(sp)
    1154:	e05a                	sd	s6,0(sp)
    1156:	0080                	addi	s0,sp,64
    1158:	8b2a                	mv	s6,a0
    115a:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    115e:	00005a17          	auipc	s4,0x5
    1162:	66aa0a13          	addi	s4,s4,1642 # 67c8 <malloc+0xb4a>
    mkdir("");
    1166:	00006497          	auipc	s1,0x6
    116a:	45248493          	addi	s1,s1,1106 # 75b8 <malloc+0x193a>
    link("README", "");
    116e:	00005a97          	auipc	s5,0x5
    1172:	5c2a8a93          	addi	s5,s5,1474 # 6730 <malloc+0xab2>
    fd = open("xx", O_CREATE);
    1176:	00005997          	auipc	s3,0x5
    117a:	53a98993          	addi	s3,s3,1338 # 66b0 <malloc+0xa32>
    117e:	a891                	j	11d2 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    1180:	85da                	mv	a1,s6
    1182:	00005517          	auipc	a0,0x5
    1186:	64e50513          	addi	a0,a0,1614 # 67d0 <malloc+0xb52>
    118a:	00005097          	auipc	ra,0x5
    118e:	a36080e7          	jalr	-1482(ra) # 5bc0 <printf>
      exit(1);
    1192:	4505                	li	a0,1
    1194:	00004097          	auipc	ra,0x4
    1198:	628080e7          	jalr	1576(ra) # 57bc <exit>
      printf("%s: chdir irefd failed\n", s);
    119c:	85da                	mv	a1,s6
    119e:	00005517          	auipc	a0,0x5
    11a2:	64a50513          	addi	a0,a0,1610 # 67e8 <malloc+0xb6a>
    11a6:	00005097          	auipc	ra,0x5
    11aa:	a1a080e7          	jalr	-1510(ra) # 5bc0 <printf>
      exit(1);
    11ae:	4505                	li	a0,1
    11b0:	00004097          	auipc	ra,0x4
    11b4:	60c080e7          	jalr	1548(ra) # 57bc <exit>
      close(fd);
    11b8:	00004097          	auipc	ra,0x4
    11bc:	62c080e7          	jalr	1580(ra) # 57e4 <close>
    11c0:	a889                	j	1212 <iref+0xce>
    unlink("xx");
    11c2:	854e                	mv	a0,s3
    11c4:	00004097          	auipc	ra,0x4
    11c8:	648080e7          	jalr	1608(ra) # 580c <unlink>
  for(i = 0; i < NINODE + 1; i++){
    11cc:	397d                	addiw	s2,s2,-1
    11ce:	06090063          	beqz	s2,122e <iref+0xea>
    if(mkdir("irefd") != 0){
    11d2:	8552                	mv	a0,s4
    11d4:	00004097          	auipc	ra,0x4
    11d8:	650080e7          	jalr	1616(ra) # 5824 <mkdir>
    11dc:	f155                	bnez	a0,1180 <iref+0x3c>
    if(chdir("irefd") != 0){
    11de:	8552                	mv	a0,s4
    11e0:	00004097          	auipc	ra,0x4
    11e4:	64c080e7          	jalr	1612(ra) # 582c <chdir>
    11e8:	f955                	bnez	a0,119c <iref+0x58>
    mkdir("");
    11ea:	8526                	mv	a0,s1
    11ec:	00004097          	auipc	ra,0x4
    11f0:	638080e7          	jalr	1592(ra) # 5824 <mkdir>
    link("README", "");
    11f4:	85a6                	mv	a1,s1
    11f6:	8556                	mv	a0,s5
    11f8:	00004097          	auipc	ra,0x4
    11fc:	624080e7          	jalr	1572(ra) # 581c <link>
    fd = open("", O_CREATE);
    1200:	20000593          	li	a1,512
    1204:	8526                	mv	a0,s1
    1206:	00004097          	auipc	ra,0x4
    120a:	5f6080e7          	jalr	1526(ra) # 57fc <open>
    if(fd >= 0)
    120e:	fa0555e3          	bgez	a0,11b8 <iref+0x74>
    fd = open("xx", O_CREATE);
    1212:	20000593          	li	a1,512
    1216:	854e                	mv	a0,s3
    1218:	00004097          	auipc	ra,0x4
    121c:	5e4080e7          	jalr	1508(ra) # 57fc <open>
    if(fd >= 0)
    1220:	fa0541e3          	bltz	a0,11c2 <iref+0x7e>
      close(fd);
    1224:	00004097          	auipc	ra,0x4
    1228:	5c0080e7          	jalr	1472(ra) # 57e4 <close>
    122c:	bf59                	j	11c2 <iref+0x7e>
    122e:	03300493          	li	s1,51
    chdir("..");
    1232:	00005997          	auipc	s3,0x5
    1236:	3a698993          	addi	s3,s3,934 # 65d8 <malloc+0x95a>
    unlink("irefd");
    123a:	00005917          	auipc	s2,0x5
    123e:	58e90913          	addi	s2,s2,1422 # 67c8 <malloc+0xb4a>
    chdir("..");
    1242:	854e                	mv	a0,s3
    1244:	00004097          	auipc	ra,0x4
    1248:	5e8080e7          	jalr	1512(ra) # 582c <chdir>
    unlink("irefd");
    124c:	854a                	mv	a0,s2
    124e:	00004097          	auipc	ra,0x4
    1252:	5be080e7          	jalr	1470(ra) # 580c <unlink>
  for(i = 0; i < NINODE + 1; i++){
    1256:	34fd                	addiw	s1,s1,-1
    1258:	f4ed                	bnez	s1,1242 <iref+0xfe>
  chdir("/");
    125a:	00005517          	auipc	a0,0x5
    125e:	2ee50513          	addi	a0,a0,750 # 6548 <malloc+0x8ca>
    1262:	00004097          	auipc	ra,0x4
    1266:	5ca080e7          	jalr	1482(ra) # 582c <chdir>
}
    126a:	70e2                	ld	ra,56(sp)
    126c:	7442                	ld	s0,48(sp)
    126e:	74a2                	ld	s1,40(sp)
    1270:	7902                	ld	s2,32(sp)
    1272:	69e2                	ld	s3,24(sp)
    1274:	6a42                	ld	s4,16(sp)
    1276:	6aa2                	ld	s5,8(sp)
    1278:	6b02                	ld	s6,0(sp)
    127a:	6121                	addi	sp,sp,64
    127c:	8082                	ret

000000000000127e <killstatus>:
{
    127e:	7139                	addi	sp,sp,-64
    1280:	fc06                	sd	ra,56(sp)
    1282:	f822                	sd	s0,48(sp)
    1284:	f426                	sd	s1,40(sp)
    1286:	f04a                	sd	s2,32(sp)
    1288:	ec4e                	sd	s3,24(sp)
    128a:	e852                	sd	s4,16(sp)
    128c:	0080                	addi	s0,sp,64
    128e:	8a2a                	mv	s4,a0
    1290:	06400913          	li	s2,100
    if(xst != -1) {
    1294:	59fd                	li	s3,-1
    int pid1 = fork();
    1296:	00004097          	auipc	ra,0x4
    129a:	51e080e7          	jalr	1310(ra) # 57b4 <fork>
    129e:	84aa                	mv	s1,a0
    if(pid1 < 0){
    12a0:	04054063          	bltz	a0,12e0 <killstatus+0x62>
    if(pid1 == 0){
    12a4:	cd21                	beqz	a0,12fc <killstatus+0x7e>
    sleep(1);
    12a6:	4505                	li	a0,1
    12a8:	00004097          	auipc	ra,0x4
    12ac:	5a4080e7          	jalr	1444(ra) # 584c <sleep>
    kill(pid1, SIGKILL);
    12b0:	45a5                	li	a1,9
    12b2:	8526                	mv	a0,s1
    12b4:	00004097          	auipc	ra,0x4
    12b8:	538080e7          	jalr	1336(ra) # 57ec <kill>
    wait(&xst);
    12bc:	fcc40513          	addi	a0,s0,-52
    12c0:	00004097          	auipc	ra,0x4
    12c4:	504080e7          	jalr	1284(ra) # 57c4 <wait>
    if(xst != -1) {
    12c8:	fcc42783          	lw	a5,-52(s0)
    12cc:	03379d63          	bne	a5,s3,1306 <killstatus+0x88>
  for(int i = 0; i < 100; i++){
    12d0:	397d                	addiw	s2,s2,-1
    12d2:	fc0912e3          	bnez	s2,1296 <killstatus+0x18>
  exit(0);
    12d6:	4501                	li	a0,0
    12d8:	00004097          	auipc	ra,0x4
    12dc:	4e4080e7          	jalr	1252(ra) # 57bc <exit>
      printf("%s: fork failed\n", s);
    12e0:	85d2                	mv	a1,s4
    12e2:	00005517          	auipc	a0,0x5
    12e6:	b9e50513          	addi	a0,a0,-1122 # 5e80 <malloc+0x202>
    12ea:	00005097          	auipc	ra,0x5
    12ee:	8d6080e7          	jalr	-1834(ra) # 5bc0 <printf>
      exit(1);
    12f2:	4505                	li	a0,1
    12f4:	00004097          	auipc	ra,0x4
    12f8:	4c8080e7          	jalr	1224(ra) # 57bc <exit>
        getpid();
    12fc:	00004097          	auipc	ra,0x4
    1300:	540080e7          	jalr	1344(ra) # 583c <getpid>
      while(1) {
    1304:	bfe5                	j	12fc <killstatus+0x7e>
       printf("%s: status should be -1\n", s);
    1306:	85d2                	mv	a1,s4
    1308:	00005517          	auipc	a0,0x5
    130c:	4f850513          	addi	a0,a0,1272 # 6800 <malloc+0xb82>
    1310:	00005097          	auipc	ra,0x5
    1314:	8b0080e7          	jalr	-1872(ra) # 5bc0 <printf>
       exit(1);
    1318:	4505                	li	a0,1
    131a:	00004097          	auipc	ra,0x4
    131e:	4a2080e7          	jalr	1186(ra) # 57bc <exit>

0000000000001322 <mem>:
{
    1322:	7139                	addi	sp,sp,-64
    1324:	fc06                	sd	ra,56(sp)
    1326:	f822                	sd	s0,48(sp)
    1328:	f426                	sd	s1,40(sp)
    132a:	f04a                	sd	s2,32(sp)
    132c:	ec4e                	sd	s3,24(sp)
    132e:	0080                	addi	s0,sp,64
    1330:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    1332:	00004097          	auipc	ra,0x4
    1336:	482080e7          	jalr	1154(ra) # 57b4 <fork>
    m1 = 0;
    133a:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    133c:	6909                	lui	s2,0x2
    133e:	71190913          	addi	s2,s2,1809 # 2711 <preempt+0x18f>
  if((pid = fork()) == 0){
    1342:	c115                	beqz	a0,1366 <mem+0x44>
    wait(&xstatus);
    1344:	fcc40513          	addi	a0,s0,-52
    1348:	00004097          	auipc	ra,0x4
    134c:	47c080e7          	jalr	1148(ra) # 57c4 <wait>
    if(xstatus == -1){
    1350:	fcc42503          	lw	a0,-52(s0)
    1354:	57fd                	li	a5,-1
    1356:	06f50363          	beq	a0,a5,13bc <mem+0x9a>
    exit(xstatus);
    135a:	00004097          	auipc	ra,0x4
    135e:	462080e7          	jalr	1122(ra) # 57bc <exit>
      *(char**)m2 = m1;
    1362:	e104                	sd	s1,0(a0)
      m1 = m2;
    1364:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    1366:	854a                	mv	a0,s2
    1368:	00005097          	auipc	ra,0x5
    136c:	916080e7          	jalr	-1770(ra) # 5c7e <malloc>
    1370:	f96d                	bnez	a0,1362 <mem+0x40>
    while(m1){
    1372:	c881                	beqz	s1,1382 <mem+0x60>
      m2 = *(char**)m1;
    1374:	8526                	mv	a0,s1
    1376:	6084                	ld	s1,0(s1)
      free(m1);
    1378:	00005097          	auipc	ra,0x5
    137c:	87e080e7          	jalr	-1922(ra) # 5bf6 <free>
    while(m1){
    1380:	f8f5                	bnez	s1,1374 <mem+0x52>
    m1 = malloc(1024*20);
    1382:	6515                	lui	a0,0x5
    1384:	00005097          	auipc	ra,0x5
    1388:	8fa080e7          	jalr	-1798(ra) # 5c7e <malloc>
    if(m1 == 0){
    138c:	c911                	beqz	a0,13a0 <mem+0x7e>
    free(m1);
    138e:	00005097          	auipc	ra,0x5
    1392:	868080e7          	jalr	-1944(ra) # 5bf6 <free>
    exit(0);
    1396:	4501                	li	a0,0
    1398:	00004097          	auipc	ra,0x4
    139c:	424080e7          	jalr	1060(ra) # 57bc <exit>
      printf("couldn't allocate mem?!!\n", s);
    13a0:	85ce                	mv	a1,s3
    13a2:	00005517          	auipc	a0,0x5
    13a6:	47e50513          	addi	a0,a0,1150 # 6820 <malloc+0xba2>
    13aa:	00005097          	auipc	ra,0x5
    13ae:	816080e7          	jalr	-2026(ra) # 5bc0 <printf>
      exit(1);
    13b2:	4505                	li	a0,1
    13b4:	00004097          	auipc	ra,0x4
    13b8:	408080e7          	jalr	1032(ra) # 57bc <exit>
      exit(0);
    13bc:	4501                	li	a0,0
    13be:	00004097          	auipc	ra,0x4
    13c2:	3fe080e7          	jalr	1022(ra) # 57bc <exit>

00000000000013c6 <bigfile>:
{
    13c6:	7139                	addi	sp,sp,-64
    13c8:	fc06                	sd	ra,56(sp)
    13ca:	f822                	sd	s0,48(sp)
    13cc:	f426                	sd	s1,40(sp)
    13ce:	f04a                	sd	s2,32(sp)
    13d0:	ec4e                	sd	s3,24(sp)
    13d2:	e852                	sd	s4,16(sp)
    13d4:	e456                	sd	s5,8(sp)
    13d6:	0080                	addi	s0,sp,64
    13d8:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    13da:	00005517          	auipc	a0,0x5
    13de:	46650513          	addi	a0,a0,1126 # 6840 <malloc+0xbc2>
    13e2:	00004097          	auipc	ra,0x4
    13e6:	42a080e7          	jalr	1066(ra) # 580c <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    13ea:	20200593          	li	a1,514
    13ee:	00005517          	auipc	a0,0x5
    13f2:	45250513          	addi	a0,a0,1106 # 6840 <malloc+0xbc2>
    13f6:	00004097          	auipc	ra,0x4
    13fa:	406080e7          	jalr	1030(ra) # 57fc <open>
    13fe:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    1400:	4481                	li	s1,0
    memset(buf, i, SZ);
    1402:	0000a917          	auipc	s2,0xa
    1406:	4de90913          	addi	s2,s2,1246 # b8e0 <buf>
  for(i = 0; i < N; i++){
    140a:	4a51                	li	s4,20
  if(fd < 0){
    140c:	0a054063          	bltz	a0,14ac <bigfile+0xe6>
    memset(buf, i, SZ);
    1410:	25800613          	li	a2,600
    1414:	85a6                	mv	a1,s1
    1416:	854a                	mv	a0,s2
    1418:	00004097          	auipc	ra,0x4
    141c:	1a8080e7          	jalr	424(ra) # 55c0 <memset>
    if(write(fd, buf, SZ) != SZ){
    1420:	25800613          	li	a2,600
    1424:	85ca                	mv	a1,s2
    1426:	854e                	mv	a0,s3
    1428:	00004097          	auipc	ra,0x4
    142c:	3b4080e7          	jalr	948(ra) # 57dc <write>
    1430:	25800793          	li	a5,600
    1434:	08f51a63          	bne	a0,a5,14c8 <bigfile+0x102>
  for(i = 0; i < N; i++){
    1438:	2485                	addiw	s1,s1,1
    143a:	fd449be3          	bne	s1,s4,1410 <bigfile+0x4a>
  close(fd);
    143e:	854e                	mv	a0,s3
    1440:	00004097          	auipc	ra,0x4
    1444:	3a4080e7          	jalr	932(ra) # 57e4 <close>
  fd = open("bigfile.dat", 0);
    1448:	4581                	li	a1,0
    144a:	00005517          	auipc	a0,0x5
    144e:	3f650513          	addi	a0,a0,1014 # 6840 <malloc+0xbc2>
    1452:	00004097          	auipc	ra,0x4
    1456:	3aa080e7          	jalr	938(ra) # 57fc <open>
    145a:	8a2a                	mv	s4,a0
  total = 0;
    145c:	4981                	li	s3,0
  for(i = 0; ; i++){
    145e:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    1460:	0000a917          	auipc	s2,0xa
    1464:	48090913          	addi	s2,s2,1152 # b8e0 <buf>
  if(fd < 0){
    1468:	06054e63          	bltz	a0,14e4 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    146c:	12c00613          	li	a2,300
    1470:	85ca                	mv	a1,s2
    1472:	8552                	mv	a0,s4
    1474:	00004097          	auipc	ra,0x4
    1478:	360080e7          	jalr	864(ra) # 57d4 <read>
    if(cc < 0){
    147c:	08054263          	bltz	a0,1500 <bigfile+0x13a>
    if(cc == 0)
    1480:	c971                	beqz	a0,1554 <bigfile+0x18e>
    if(cc != SZ/2){
    1482:	12c00793          	li	a5,300
    1486:	08f51b63          	bne	a0,a5,151c <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    148a:	01f4d79b          	srliw	a5,s1,0x1f
    148e:	9fa5                	addw	a5,a5,s1
    1490:	4017d79b          	sraiw	a5,a5,0x1
    1494:	00094703          	lbu	a4,0(s2)
    1498:	0af71063          	bne	a4,a5,1538 <bigfile+0x172>
    149c:	12b94703          	lbu	a4,299(s2)
    14a0:	08f71c63          	bne	a4,a5,1538 <bigfile+0x172>
    total += cc;
    14a4:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    14a8:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    14aa:	b7c9                	j	146c <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    14ac:	85d6                	mv	a1,s5
    14ae:	00005517          	auipc	a0,0x5
    14b2:	3a250513          	addi	a0,a0,930 # 6850 <malloc+0xbd2>
    14b6:	00004097          	auipc	ra,0x4
    14ba:	70a080e7          	jalr	1802(ra) # 5bc0 <printf>
    exit(1);
    14be:	4505                	li	a0,1
    14c0:	00004097          	auipc	ra,0x4
    14c4:	2fc080e7          	jalr	764(ra) # 57bc <exit>
      printf("%s: write bigfile failed\n", s);
    14c8:	85d6                	mv	a1,s5
    14ca:	00005517          	auipc	a0,0x5
    14ce:	3a650513          	addi	a0,a0,934 # 6870 <malloc+0xbf2>
    14d2:	00004097          	auipc	ra,0x4
    14d6:	6ee080e7          	jalr	1774(ra) # 5bc0 <printf>
      exit(1);
    14da:	4505                	li	a0,1
    14dc:	00004097          	auipc	ra,0x4
    14e0:	2e0080e7          	jalr	736(ra) # 57bc <exit>
    printf("%s: cannot open bigfile\n", s);
    14e4:	85d6                	mv	a1,s5
    14e6:	00005517          	auipc	a0,0x5
    14ea:	3aa50513          	addi	a0,a0,938 # 6890 <malloc+0xc12>
    14ee:	00004097          	auipc	ra,0x4
    14f2:	6d2080e7          	jalr	1746(ra) # 5bc0 <printf>
    exit(1);
    14f6:	4505                	li	a0,1
    14f8:	00004097          	auipc	ra,0x4
    14fc:	2c4080e7          	jalr	708(ra) # 57bc <exit>
      printf("%s: read bigfile failed\n", s);
    1500:	85d6                	mv	a1,s5
    1502:	00005517          	auipc	a0,0x5
    1506:	3ae50513          	addi	a0,a0,942 # 68b0 <malloc+0xc32>
    150a:	00004097          	auipc	ra,0x4
    150e:	6b6080e7          	jalr	1718(ra) # 5bc0 <printf>
      exit(1);
    1512:	4505                	li	a0,1
    1514:	00004097          	auipc	ra,0x4
    1518:	2a8080e7          	jalr	680(ra) # 57bc <exit>
      printf("%s: short read bigfile\n", s);
    151c:	85d6                	mv	a1,s5
    151e:	00005517          	auipc	a0,0x5
    1522:	3b250513          	addi	a0,a0,946 # 68d0 <malloc+0xc52>
    1526:	00004097          	auipc	ra,0x4
    152a:	69a080e7          	jalr	1690(ra) # 5bc0 <printf>
      exit(1);
    152e:	4505                	li	a0,1
    1530:	00004097          	auipc	ra,0x4
    1534:	28c080e7          	jalr	652(ra) # 57bc <exit>
      printf("%s: read bigfile wrong data\n", s);
    1538:	85d6                	mv	a1,s5
    153a:	00005517          	auipc	a0,0x5
    153e:	3ae50513          	addi	a0,a0,942 # 68e8 <malloc+0xc6a>
    1542:	00004097          	auipc	ra,0x4
    1546:	67e080e7          	jalr	1662(ra) # 5bc0 <printf>
      exit(1);
    154a:	4505                	li	a0,1
    154c:	00004097          	auipc	ra,0x4
    1550:	270080e7          	jalr	624(ra) # 57bc <exit>
  close(fd);
    1554:	8552                	mv	a0,s4
    1556:	00004097          	auipc	ra,0x4
    155a:	28e080e7          	jalr	654(ra) # 57e4 <close>
  if(total != N*SZ){
    155e:	678d                	lui	a5,0x3
    1560:	ee078793          	addi	a5,a5,-288 # 2ee0 <createdelete+0x6c>
    1564:	02f99363          	bne	s3,a5,158a <bigfile+0x1c4>
  unlink("bigfile.dat");
    1568:	00005517          	auipc	a0,0x5
    156c:	2d850513          	addi	a0,a0,728 # 6840 <malloc+0xbc2>
    1570:	00004097          	auipc	ra,0x4
    1574:	29c080e7          	jalr	668(ra) # 580c <unlink>
}
    1578:	70e2                	ld	ra,56(sp)
    157a:	7442                	ld	s0,48(sp)
    157c:	74a2                	ld	s1,40(sp)
    157e:	7902                	ld	s2,32(sp)
    1580:	69e2                	ld	s3,24(sp)
    1582:	6a42                	ld	s4,16(sp)
    1584:	6aa2                	ld	s5,8(sp)
    1586:	6121                	addi	sp,sp,64
    1588:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    158a:	85d6                	mv	a1,s5
    158c:	00005517          	auipc	a0,0x5
    1590:	37c50513          	addi	a0,a0,892 # 6908 <malloc+0xc8a>
    1594:	00004097          	auipc	ra,0x4
    1598:	62c080e7          	jalr	1580(ra) # 5bc0 <printf>
    exit(1);
    159c:	4505                	li	a0,1
    159e:	00004097          	auipc	ra,0x4
    15a2:	21e080e7          	jalr	542(ra) # 57bc <exit>

00000000000015a6 <test_thread>:
void test_thread(){
    15a6:	1141                	addi	sp,sp,-16
    15a8:	e422                	sd	s0,8(sp)
    15aa:	0800                	addi	s0,sp,16
}
    15ac:	6422                	ld	s0,8(sp)
    15ae:	0141                	addi	sp,sp,16
    15b0:	8082                	ret

00000000000015b2 <signal_test>:
void signal_test(char *s){
    15b2:	715d                	addi	sp,sp,-80
    15b4:	e486                	sd	ra,72(sp)
    15b6:	e0a2                	sd	s0,64(sp)
    15b8:	fc26                	sd	s1,56(sp)
    15ba:	0880                	addi	s0,sp,80
    printf("test_handler:%p",test_handler);
    15bc:	fffff597          	auipc	a1,0xfffff
    15c0:	a4458593          	addi	a1,a1,-1468 # 0 <test_handler>
    15c4:	00005517          	auipc	a0,0x5
    15c8:	36450513          	addi	a0,a0,868 # 6928 <malloc+0xcaa>
    15cc:	00004097          	auipc	ra,0x4
    15d0:	5f4080e7          	jalr	1524(ra) # 5bc0 <printf>
    struct sigaction act = {test_handler, (uint)(1 << 29)};
    15d4:	fffff797          	auipc	a5,0xfffff
    15d8:	a2c78793          	addi	a5,a5,-1492 # 0 <test_handler>
    15dc:	fcf43423          	sd	a5,-56(s0)
    15e0:	200007b7          	lui	a5,0x20000
    15e4:	fcf42823          	sw	a5,-48(s0)
    sigprocmask(0);
    15e8:	4501                	li	a0,0
    15ea:	00004097          	auipc	ra,0x4
    15ee:	272080e7          	jalr	626(ra) # 585c <sigprocmask>
    sigaction(testsig, &act, &old);
    15f2:	fb840613          	addi	a2,s0,-72
    15f6:	fc840593          	addi	a1,s0,-56
    15fa:	453d                	li	a0,15
    15fc:	00004097          	auipc	ra,0x4
    1600:	268080e7          	jalr	616(ra) # 5864 <sigaction>
    if((pid = fork()) == 0){
    1604:	00004097          	auipc	ra,0x4
    1608:	1b0080e7          	jalr	432(ra) # 57b4 <fork>
    160c:	fca42e23          	sw	a0,-36(s0)
    1610:	c90d                	beqz	a0,1642 <signal_test+0x90>
    kill(pid, testsig);
    1612:	45bd                	li	a1,15
    1614:	00004097          	auipc	ra,0x4
    1618:	1d8080e7          	jalr	472(ra) # 57ec <kill>
    wait(&pid);
    161c:	fdc40513          	addi	a0,s0,-36
    1620:	00004097          	auipc	ra,0x4
    1624:	1a4080e7          	jalr	420(ra) # 57c4 <wait>
    printf("Finished testing signals\n");
    1628:	00005517          	auipc	a0,0x5
    162c:	31050513          	addi	a0,a0,784 # 6938 <malloc+0xcba>
    1630:	00004097          	auipc	ra,0x4
    1634:	590080e7          	jalr	1424(ra) # 5bc0 <printf>
}
    1638:	60a6                	ld	ra,72(sp)
    163a:	6406                	ld	s0,64(sp)
    163c:	74e2                	ld	s1,56(sp)
    163e:	6161                	addi	sp,sp,80
    1640:	8082                	ret
        while(!wait_sig)
    1642:	00007797          	auipc	a5,0x7
    1646:	a767a783          	lw	a5,-1418(a5) # 80b8 <wait_sig>
    164a:	ef81                	bnez	a5,1662 <signal_test+0xb0>
    164c:	00007497          	auipc	s1,0x7
    1650:	a6c48493          	addi	s1,s1,-1428 # 80b8 <wait_sig>
            sleep(1);
    1654:	4505                	li	a0,1
    1656:	00004097          	auipc	ra,0x4
    165a:	1f6080e7          	jalr	502(ra) # 584c <sleep>
        while(!wait_sig)
    165e:	409c                	lw	a5,0(s1)
    1660:	dbf5                	beqz	a5,1654 <signal_test+0xa2>
        exit(0);
    1662:	4501                	li	a0,0
    1664:	00004097          	auipc	ra,0x4
    1668:	158080e7          	jalr	344(ra) # 57bc <exit>

000000000000166c <thread_test>:
void thread_test(char *s){
    166c:	1141                	addi	sp,sp,-16
    166e:	e422                	sd	s0,8(sp)
    1670:	0800                	addi	s0,sp,16
}
    1672:	6422                	ld	s0,8(sp)
    1674:	0141                	addi	sp,sp,16
    1676:	8082                	ret

0000000000001678 <bsem_test>:
void bsem_test(char *s){
    1678:	1141                	addi	sp,sp,-16
    167a:	e422                	sd	s0,8(sp)
    167c:	0800                	addi	s0,sp,16
}
    167e:	6422                	ld	s0,8(sp)
    1680:	0141                	addi	sp,sp,16
    1682:	8082                	ret

0000000000001684 <Csem_test>:
void Csem_test(char *s){
    1684:	1141                	addi	sp,sp,-16
    1686:	e422                	sd	s0,8(sp)
    1688:	0800                	addi	s0,sp,16
}
    168a:	6422                	ld	s0,8(sp)
    168c:	0141                	addi	sp,sp,16
    168e:	8082                	ret

0000000000001690 <copyin>:
{
    1690:	715d                	addi	sp,sp,-80
    1692:	e486                	sd	ra,72(sp)
    1694:	e0a2                	sd	s0,64(sp)
    1696:	fc26                	sd	s1,56(sp)
    1698:	f84a                	sd	s2,48(sp)
    169a:	f44e                	sd	s3,40(sp)
    169c:	f052                	sd	s4,32(sp)
    169e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
    16a0:	4785                	li	a5,1
    16a2:	07fe                	slli	a5,a5,0x1f
    16a4:	fcf43023          	sd	a5,-64(s0)
    16a8:	57fd                	li	a5,-1
    16aa:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
    16ae:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
    16b2:	00005a17          	auipc	s4,0x5
    16b6:	2a6a0a13          	addi	s4,s4,678 # 6958 <malloc+0xcda>
    uint64 addr = addrs[ai];
    16ba:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
    16be:	20100593          	li	a1,513
    16c2:	8552                	mv	a0,s4
    16c4:	00004097          	auipc	ra,0x4
    16c8:	138080e7          	jalr	312(ra) # 57fc <open>
    16cc:	84aa                	mv	s1,a0
    if(fd < 0){
    16ce:	08054863          	bltz	a0,175e <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
    16d2:	6609                	lui	a2,0x2
    16d4:	85ce                	mv	a1,s3
    16d6:	00004097          	auipc	ra,0x4
    16da:	106080e7          	jalr	262(ra) # 57dc <write>
    if(n >= 0){
    16de:	08055d63          	bgez	a0,1778 <copyin+0xe8>
    close(fd);
    16e2:	8526                	mv	a0,s1
    16e4:	00004097          	auipc	ra,0x4
    16e8:	100080e7          	jalr	256(ra) # 57e4 <close>
    unlink("copyin1");
    16ec:	8552                	mv	a0,s4
    16ee:	00004097          	auipc	ra,0x4
    16f2:	11e080e7          	jalr	286(ra) # 580c <unlink>
    n = write(1, (char*)addr, 8192);
    16f6:	6609                	lui	a2,0x2
    16f8:	85ce                	mv	a1,s3
    16fa:	4505                	li	a0,1
    16fc:	00004097          	auipc	ra,0x4
    1700:	0e0080e7          	jalr	224(ra) # 57dc <write>
    if(n > 0){
    1704:	08a04963          	bgtz	a0,1796 <copyin+0x106>
    if(pipe(fds) < 0){
    1708:	fb840513          	addi	a0,s0,-72
    170c:	00004097          	auipc	ra,0x4
    1710:	0c0080e7          	jalr	192(ra) # 57cc <pipe>
    1714:	0a054063          	bltz	a0,17b4 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
    1718:	6609                	lui	a2,0x2
    171a:	85ce                	mv	a1,s3
    171c:	fbc42503          	lw	a0,-68(s0)
    1720:	00004097          	auipc	ra,0x4
    1724:	0bc080e7          	jalr	188(ra) # 57dc <write>
    if(n > 0){
    1728:	0aa04363          	bgtz	a0,17ce <copyin+0x13e>
    close(fds[0]);
    172c:	fb842503          	lw	a0,-72(s0)
    1730:	00004097          	auipc	ra,0x4
    1734:	0b4080e7          	jalr	180(ra) # 57e4 <close>
    close(fds[1]);
    1738:	fbc42503          	lw	a0,-68(s0)
    173c:	00004097          	auipc	ra,0x4
    1740:	0a8080e7          	jalr	168(ra) # 57e4 <close>
  for(int ai = 0; ai < 2; ai++){
    1744:	0921                	addi	s2,s2,8
    1746:	fd040793          	addi	a5,s0,-48
    174a:	f6f918e3          	bne	s2,a5,16ba <copyin+0x2a>
}
    174e:	60a6                	ld	ra,72(sp)
    1750:	6406                	ld	s0,64(sp)
    1752:	74e2                	ld	s1,56(sp)
    1754:	7942                	ld	s2,48(sp)
    1756:	79a2                	ld	s3,40(sp)
    1758:	7a02                	ld	s4,32(sp)
    175a:	6161                	addi	sp,sp,80
    175c:	8082                	ret
      printf("open(copyin1) failed\n");
    175e:	00005517          	auipc	a0,0x5
    1762:	20250513          	addi	a0,a0,514 # 6960 <malloc+0xce2>
    1766:	00004097          	auipc	ra,0x4
    176a:	45a080e7          	jalr	1114(ra) # 5bc0 <printf>
      exit(1);
    176e:	4505                	li	a0,1
    1770:	00004097          	auipc	ra,0x4
    1774:	04c080e7          	jalr	76(ra) # 57bc <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
    1778:	862a                	mv	a2,a0
    177a:	85ce                	mv	a1,s3
    177c:	00005517          	auipc	a0,0x5
    1780:	1fc50513          	addi	a0,a0,508 # 6978 <malloc+0xcfa>
    1784:	00004097          	auipc	ra,0x4
    1788:	43c080e7          	jalr	1084(ra) # 5bc0 <printf>
      exit(1);
    178c:	4505                	li	a0,1
    178e:	00004097          	auipc	ra,0x4
    1792:	02e080e7          	jalr	46(ra) # 57bc <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
    1796:	862a                	mv	a2,a0
    1798:	85ce                	mv	a1,s3
    179a:	00005517          	auipc	a0,0x5
    179e:	20e50513          	addi	a0,a0,526 # 69a8 <malloc+0xd2a>
    17a2:	00004097          	auipc	ra,0x4
    17a6:	41e080e7          	jalr	1054(ra) # 5bc0 <printf>
      exit(1);
    17aa:	4505                	li	a0,1
    17ac:	00004097          	auipc	ra,0x4
    17b0:	010080e7          	jalr	16(ra) # 57bc <exit>
      printf("pipe() failed\n");
    17b4:	00005517          	auipc	a0,0x5
    17b8:	22450513          	addi	a0,a0,548 # 69d8 <malloc+0xd5a>
    17bc:	00004097          	auipc	ra,0x4
    17c0:	404080e7          	jalr	1028(ra) # 5bc0 <printf>
      exit(1);
    17c4:	4505                	li	a0,1
    17c6:	00004097          	auipc	ra,0x4
    17ca:	ff6080e7          	jalr	-10(ra) # 57bc <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
    17ce:	862a                	mv	a2,a0
    17d0:	85ce                	mv	a1,s3
    17d2:	00005517          	auipc	a0,0x5
    17d6:	21650513          	addi	a0,a0,534 # 69e8 <malloc+0xd6a>
    17da:	00004097          	auipc	ra,0x4
    17de:	3e6080e7          	jalr	998(ra) # 5bc0 <printf>
      exit(1);
    17e2:	4505                	li	a0,1
    17e4:	00004097          	auipc	ra,0x4
    17e8:	fd8080e7          	jalr	-40(ra) # 57bc <exit>

00000000000017ec <copyout>:
{
    17ec:	711d                	addi	sp,sp,-96
    17ee:	ec86                	sd	ra,88(sp)
    17f0:	e8a2                	sd	s0,80(sp)
    17f2:	e4a6                	sd	s1,72(sp)
    17f4:	e0ca                	sd	s2,64(sp)
    17f6:	fc4e                	sd	s3,56(sp)
    17f8:	f852                	sd	s4,48(sp)
    17fa:	f456                	sd	s5,40(sp)
    17fc:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
    17fe:	4785                	li	a5,1
    1800:	07fe                	slli	a5,a5,0x1f
    1802:	faf43823          	sd	a5,-80(s0)
    1806:	57fd                	li	a5,-1
    1808:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
    180c:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
    1810:	00005a17          	auipc	s4,0x5
    1814:	f20a0a13          	addi	s4,s4,-224 # 6730 <malloc+0xab2>
    n = write(fds[1], "x", 1);
    1818:	00005a97          	auipc	s5,0x5
    181c:	f90a8a93          	addi	s5,s5,-112 # 67a8 <malloc+0xb2a>
    uint64 addr = addrs[ai];
    1820:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
    1824:	4581                	li	a1,0
    1826:	8552                	mv	a0,s4
    1828:	00004097          	auipc	ra,0x4
    182c:	fd4080e7          	jalr	-44(ra) # 57fc <open>
    1830:	84aa                	mv	s1,a0
    if(fd < 0){
    1832:	08054663          	bltz	a0,18be <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
    1836:	6609                	lui	a2,0x2
    1838:	85ce                	mv	a1,s3
    183a:	00004097          	auipc	ra,0x4
    183e:	f9a080e7          	jalr	-102(ra) # 57d4 <read>
    if(n > 0){
    1842:	08a04b63          	bgtz	a0,18d8 <copyout+0xec>
    close(fd);
    1846:	8526                	mv	a0,s1
    1848:	00004097          	auipc	ra,0x4
    184c:	f9c080e7          	jalr	-100(ra) # 57e4 <close>
    if(pipe(fds) < 0){
    1850:	fa840513          	addi	a0,s0,-88
    1854:	00004097          	auipc	ra,0x4
    1858:	f78080e7          	jalr	-136(ra) # 57cc <pipe>
    185c:	08054d63          	bltz	a0,18f6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
    1860:	4605                	li	a2,1
    1862:	85d6                	mv	a1,s5
    1864:	fac42503          	lw	a0,-84(s0)
    1868:	00004097          	auipc	ra,0x4
    186c:	f74080e7          	jalr	-140(ra) # 57dc <write>
    if(n != 1){
    1870:	4785                	li	a5,1
    1872:	08f51f63          	bne	a0,a5,1910 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
    1876:	6609                	lui	a2,0x2
    1878:	85ce                	mv	a1,s3
    187a:	fa842503          	lw	a0,-88(s0)
    187e:	00004097          	auipc	ra,0x4
    1882:	f56080e7          	jalr	-170(ra) # 57d4 <read>
    if(n > 0){
    1886:	0aa04263          	bgtz	a0,192a <copyout+0x13e>
    close(fds[0]);
    188a:	fa842503          	lw	a0,-88(s0)
    188e:	00004097          	auipc	ra,0x4
    1892:	f56080e7          	jalr	-170(ra) # 57e4 <close>
    close(fds[1]);
    1896:	fac42503          	lw	a0,-84(s0)
    189a:	00004097          	auipc	ra,0x4
    189e:	f4a080e7          	jalr	-182(ra) # 57e4 <close>
  for(int ai = 0; ai < 2; ai++){
    18a2:	0921                	addi	s2,s2,8
    18a4:	fc040793          	addi	a5,s0,-64
    18a8:	f6f91ce3          	bne	s2,a5,1820 <copyout+0x34>
}
    18ac:	60e6                	ld	ra,88(sp)
    18ae:	6446                	ld	s0,80(sp)
    18b0:	64a6                	ld	s1,72(sp)
    18b2:	6906                	ld	s2,64(sp)
    18b4:	79e2                	ld	s3,56(sp)
    18b6:	7a42                	ld	s4,48(sp)
    18b8:	7aa2                	ld	s5,40(sp)
    18ba:	6125                	addi	sp,sp,96
    18bc:	8082                	ret
      printf("open(README) failed\n");
    18be:	00005517          	auipc	a0,0x5
    18c2:	15a50513          	addi	a0,a0,346 # 6a18 <malloc+0xd9a>
    18c6:	00004097          	auipc	ra,0x4
    18ca:	2fa080e7          	jalr	762(ra) # 5bc0 <printf>
      exit(1);
    18ce:	4505                	li	a0,1
    18d0:	00004097          	auipc	ra,0x4
    18d4:	eec080e7          	jalr	-276(ra) # 57bc <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
    18d8:	862a                	mv	a2,a0
    18da:	85ce                	mv	a1,s3
    18dc:	00005517          	auipc	a0,0x5
    18e0:	15450513          	addi	a0,a0,340 # 6a30 <malloc+0xdb2>
    18e4:	00004097          	auipc	ra,0x4
    18e8:	2dc080e7          	jalr	732(ra) # 5bc0 <printf>
      exit(1);
    18ec:	4505                	li	a0,1
    18ee:	00004097          	auipc	ra,0x4
    18f2:	ece080e7          	jalr	-306(ra) # 57bc <exit>
      printf("pipe() failed\n");
    18f6:	00005517          	auipc	a0,0x5
    18fa:	0e250513          	addi	a0,a0,226 # 69d8 <malloc+0xd5a>
    18fe:	00004097          	auipc	ra,0x4
    1902:	2c2080e7          	jalr	706(ra) # 5bc0 <printf>
      exit(1);
    1906:	4505                	li	a0,1
    1908:	00004097          	auipc	ra,0x4
    190c:	eb4080e7          	jalr	-332(ra) # 57bc <exit>
      printf("pipe write failed\n");
    1910:	00005517          	auipc	a0,0x5
    1914:	15050513          	addi	a0,a0,336 # 6a60 <malloc+0xde2>
    1918:	00004097          	auipc	ra,0x4
    191c:	2a8080e7          	jalr	680(ra) # 5bc0 <printf>
      exit(1);
    1920:	4505                	li	a0,1
    1922:	00004097          	auipc	ra,0x4
    1926:	e9a080e7          	jalr	-358(ra) # 57bc <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
    192a:	862a                	mv	a2,a0
    192c:	85ce                	mv	a1,s3
    192e:	00005517          	auipc	a0,0x5
    1932:	14a50513          	addi	a0,a0,330 # 6a78 <malloc+0xdfa>
    1936:	00004097          	auipc	ra,0x4
    193a:	28a080e7          	jalr	650(ra) # 5bc0 <printf>
      exit(1);
    193e:	4505                	li	a0,1
    1940:	00004097          	auipc	ra,0x4
    1944:	e7c080e7          	jalr	-388(ra) # 57bc <exit>

0000000000001948 <copyinstr1>:
{
    1948:	1141                	addi	sp,sp,-16
    194a:	e406                	sd	ra,8(sp)
    194c:	e022                	sd	s0,0(sp)
    194e:	0800                	addi	s0,sp,16
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
    1950:	20100593          	li	a1,513
    1954:	4505                	li	a0,1
    1956:	057e                	slli	a0,a0,0x1f
    1958:	00004097          	auipc	ra,0x4
    195c:	ea4080e7          	jalr	-348(ra) # 57fc <open>
    if(fd >= 0){
    1960:	02055063          	bgez	a0,1980 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
    1964:	20100593          	li	a1,513
    1968:	557d                	li	a0,-1
    196a:	00004097          	auipc	ra,0x4
    196e:	e92080e7          	jalr	-366(ra) # 57fc <open>
    uint64 addr = addrs[ai];
    1972:	55fd                	li	a1,-1
    if(fd >= 0){
    1974:	00055863          	bgez	a0,1984 <copyinstr1+0x3c>
}
    1978:	60a2                	ld	ra,8(sp)
    197a:	6402                	ld	s0,0(sp)
    197c:	0141                	addi	sp,sp,16
    197e:	8082                	ret
    uint64 addr = addrs[ai];
    1980:	4585                	li	a1,1
    1982:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
    1984:	862a                	mv	a2,a0
    1986:	00005517          	auipc	a0,0x5
    198a:	12250513          	addi	a0,a0,290 # 6aa8 <malloc+0xe2a>
    198e:	00004097          	auipc	ra,0x4
    1992:	232080e7          	jalr	562(ra) # 5bc0 <printf>
      exit(1);
    1996:	4505                	li	a0,1
    1998:	00004097          	auipc	ra,0x4
    199c:	e24080e7          	jalr	-476(ra) # 57bc <exit>

00000000000019a0 <copyinstr2>:
{
    19a0:	7155                	addi	sp,sp,-208
    19a2:	e586                	sd	ra,200(sp)
    19a4:	e1a2                	sd	s0,192(sp)
    19a6:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    19a8:	f6840793          	addi	a5,s0,-152
    19ac:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    19b0:	07800713          	li	a4,120
    19b4:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    19b8:	0785                	addi	a5,a5,1
    19ba:	fed79de3          	bne	a5,a3,19b4 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    19be:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    19c2:	f6840513          	addi	a0,s0,-152
    19c6:	00004097          	auipc	ra,0x4
    19ca:	e46080e7          	jalr	-442(ra) # 580c <unlink>
  if(ret != -1){
    19ce:	57fd                	li	a5,-1
    19d0:	0ef51063          	bne	a0,a5,1ab0 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    19d4:	20100593          	li	a1,513
    19d8:	f6840513          	addi	a0,s0,-152
    19dc:	00004097          	auipc	ra,0x4
    19e0:	e20080e7          	jalr	-480(ra) # 57fc <open>
  if(fd != -1){
    19e4:	57fd                	li	a5,-1
    19e6:	0ef51563          	bne	a0,a5,1ad0 <copyinstr2+0x130>
  ret = link(b, b);
    19ea:	f6840593          	addi	a1,s0,-152
    19ee:	852e                	mv	a0,a1
    19f0:	00004097          	auipc	ra,0x4
    19f4:	e2c080e7          	jalr	-468(ra) # 581c <link>
  if(ret != -1){
    19f8:	57fd                	li	a5,-1
    19fa:	0ef51b63          	bne	a0,a5,1af0 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    19fe:	00005797          	auipc	a5,0x5
    1a02:	cb278793          	addi	a5,a5,-846 # 66b0 <malloc+0xa32>
    1a06:	f4f43c23          	sd	a5,-168(s0)
    1a0a:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1a0e:	f5840593          	addi	a1,s0,-168
    1a12:	f6840513          	addi	a0,s0,-152
    1a16:	00004097          	auipc	ra,0x4
    1a1a:	dde080e7          	jalr	-546(ra) # 57f4 <exec>
  if(ret != -1){
    1a1e:	57fd                	li	a5,-1
    1a20:	0ef51963          	bne	a0,a5,1b12 <copyinstr2+0x172>
  int pid = fork();
    1a24:	00004097          	auipc	ra,0x4
    1a28:	d90080e7          	jalr	-624(ra) # 57b4 <fork>
  if(pid < 0){
    1a2c:	10054363          	bltz	a0,1b32 <copyinstr2+0x192>
  if(pid == 0){
    1a30:	12051463          	bnez	a0,1b58 <copyinstr2+0x1b8>
    1a34:	00006797          	auipc	a5,0x6
    1a38:	79478793          	addi	a5,a5,1940 # 81c8 <big.0>
    1a3c:	00007697          	auipc	a3,0x7
    1a40:	78c68693          	addi	a3,a3,1932 # 91c8 <__global_pointer$+0x920>
      big[i] = 'x';
    1a44:	07800713          	li	a4,120
    1a48:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1a4c:	0785                	addi	a5,a5,1
    1a4e:	fed79de3          	bne	a5,a3,1a48 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1a52:	00007797          	auipc	a5,0x7
    1a56:	76078b23          	sb	zero,1910(a5) # 91c8 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1a5a:	00006797          	auipc	a5,0x6
    1a5e:	4de78793          	addi	a5,a5,1246 # 7f38 <malloc+0x22ba>
    1a62:	6390                	ld	a2,0(a5)
    1a64:	6794                	ld	a3,8(a5)
    1a66:	6b98                	ld	a4,16(a5)
    1a68:	6f9c                	ld	a5,24(a5)
    1a6a:	f2c43823          	sd	a2,-208(s0)
    1a6e:	f2d43c23          	sd	a3,-200(s0)
    1a72:	f4e43023          	sd	a4,-192(s0)
    1a76:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1a7a:	f3040593          	addi	a1,s0,-208
    1a7e:	00004517          	auipc	a0,0x4
    1a82:	4c250513          	addi	a0,a0,1218 # 5f40 <malloc+0x2c2>
    1a86:	00004097          	auipc	ra,0x4
    1a8a:	d6e080e7          	jalr	-658(ra) # 57f4 <exec>
    if(ret != -1){
    1a8e:	57fd                	li	a5,-1
    1a90:	0af50e63          	beq	a0,a5,1b4c <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1a94:	55fd                	li	a1,-1
    1a96:	00005517          	auipc	a0,0x5
    1a9a:	0ba50513          	addi	a0,a0,186 # 6b50 <malloc+0xed2>
    1a9e:	00004097          	auipc	ra,0x4
    1aa2:	122080e7          	jalr	290(ra) # 5bc0 <printf>
      exit(1);
    1aa6:	4505                	li	a0,1
    1aa8:	00004097          	auipc	ra,0x4
    1aac:	d14080e7          	jalr	-748(ra) # 57bc <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1ab0:	862a                	mv	a2,a0
    1ab2:	f6840593          	addi	a1,s0,-152
    1ab6:	00005517          	auipc	a0,0x5
    1aba:	01250513          	addi	a0,a0,18 # 6ac8 <malloc+0xe4a>
    1abe:	00004097          	auipc	ra,0x4
    1ac2:	102080e7          	jalr	258(ra) # 5bc0 <printf>
    exit(1);
    1ac6:	4505                	li	a0,1
    1ac8:	00004097          	auipc	ra,0x4
    1acc:	cf4080e7          	jalr	-780(ra) # 57bc <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1ad0:	862a                	mv	a2,a0
    1ad2:	f6840593          	addi	a1,s0,-152
    1ad6:	00005517          	auipc	a0,0x5
    1ada:	01250513          	addi	a0,a0,18 # 6ae8 <malloc+0xe6a>
    1ade:	00004097          	auipc	ra,0x4
    1ae2:	0e2080e7          	jalr	226(ra) # 5bc0 <printf>
    exit(1);
    1ae6:	4505                	li	a0,1
    1ae8:	00004097          	auipc	ra,0x4
    1aec:	cd4080e7          	jalr	-812(ra) # 57bc <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1af0:	86aa                	mv	a3,a0
    1af2:	f6840613          	addi	a2,s0,-152
    1af6:	85b2                	mv	a1,a2
    1af8:	00005517          	auipc	a0,0x5
    1afc:	01050513          	addi	a0,a0,16 # 6b08 <malloc+0xe8a>
    1b00:	00004097          	auipc	ra,0x4
    1b04:	0c0080e7          	jalr	192(ra) # 5bc0 <printf>
    exit(1);
    1b08:	4505                	li	a0,1
    1b0a:	00004097          	auipc	ra,0x4
    1b0e:	cb2080e7          	jalr	-846(ra) # 57bc <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1b12:	567d                	li	a2,-1
    1b14:	f6840593          	addi	a1,s0,-152
    1b18:	00005517          	auipc	a0,0x5
    1b1c:	01850513          	addi	a0,a0,24 # 6b30 <malloc+0xeb2>
    1b20:	00004097          	auipc	ra,0x4
    1b24:	0a0080e7          	jalr	160(ra) # 5bc0 <printf>
    exit(1);
    1b28:	4505                	li	a0,1
    1b2a:	00004097          	auipc	ra,0x4
    1b2e:	c92080e7          	jalr	-878(ra) # 57bc <exit>
    printf("fork failed\n");
    1b32:	00006517          	auipc	a0,0x6
    1b36:	17650513          	addi	a0,a0,374 # 7ca8 <malloc+0x202a>
    1b3a:	00004097          	auipc	ra,0x4
    1b3e:	086080e7          	jalr	134(ra) # 5bc0 <printf>
    exit(1);
    1b42:	4505                	li	a0,1
    1b44:	00004097          	auipc	ra,0x4
    1b48:	c78080e7          	jalr	-904(ra) # 57bc <exit>
    exit(747); // OK
    1b4c:	2eb00513          	li	a0,747
    1b50:	00004097          	auipc	ra,0x4
    1b54:	c6c080e7          	jalr	-916(ra) # 57bc <exit>
  int st = 0;
    1b58:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1b5c:	f5440513          	addi	a0,s0,-172
    1b60:	00004097          	auipc	ra,0x4
    1b64:	c64080e7          	jalr	-924(ra) # 57c4 <wait>
  if(st != 747){
    1b68:	f5442703          	lw	a4,-172(s0)
    1b6c:	2eb00793          	li	a5,747
    1b70:	00f71663          	bne	a4,a5,1b7c <copyinstr2+0x1dc>
}
    1b74:	60ae                	ld	ra,200(sp)
    1b76:	640e                	ld	s0,192(sp)
    1b78:	6169                	addi	sp,sp,208
    1b7a:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    1b7c:	00005517          	auipc	a0,0x5
    1b80:	ffc50513          	addi	a0,a0,-4 # 6b78 <malloc+0xefa>
    1b84:	00004097          	auipc	ra,0x4
    1b88:	03c080e7          	jalr	60(ra) # 5bc0 <printf>
    exit(1);
    1b8c:	4505                	li	a0,1
    1b8e:	00004097          	auipc	ra,0x4
    1b92:	c2e080e7          	jalr	-978(ra) # 57bc <exit>

0000000000001b96 <copyinstr3>:
{
    1b96:	7179                	addi	sp,sp,-48
    1b98:	f406                	sd	ra,40(sp)
    1b9a:	f022                	sd	s0,32(sp)
    1b9c:	ec26                	sd	s1,24(sp)
    1b9e:	1800                	addi	s0,sp,48
  sbrk(8192);
    1ba0:	6509                	lui	a0,0x2
    1ba2:	00004097          	auipc	ra,0x4
    1ba6:	ca2080e7          	jalr	-862(ra) # 5844 <sbrk>
  uint64 top = (uint64) sbrk(0);
    1baa:	4501                	li	a0,0
    1bac:	00004097          	auipc	ra,0x4
    1bb0:	c98080e7          	jalr	-872(ra) # 5844 <sbrk>
  if((top % PGSIZE) != 0){
    1bb4:	03451793          	slli	a5,a0,0x34
    1bb8:	e3c9                	bnez	a5,1c3a <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    1bba:	4501                	li	a0,0
    1bbc:	00004097          	auipc	ra,0x4
    1bc0:	c88080e7          	jalr	-888(ra) # 5844 <sbrk>
  if(top % PGSIZE){
    1bc4:	03451793          	slli	a5,a0,0x34
    1bc8:	e3d9                	bnez	a5,1c4e <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    1bca:	fff50493          	addi	s1,a0,-1 # 1fff <truncate1+0x1c3>
  *b = 'x';
    1bce:	07800793          	li	a5,120
    1bd2:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1bd6:	8526                	mv	a0,s1
    1bd8:	00004097          	auipc	ra,0x4
    1bdc:	c34080e7          	jalr	-972(ra) # 580c <unlink>
  if(ret != -1){
    1be0:	57fd                	li	a5,-1
    1be2:	08f51363          	bne	a0,a5,1c68 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    1be6:	20100593          	li	a1,513
    1bea:	8526                	mv	a0,s1
    1bec:	00004097          	auipc	ra,0x4
    1bf0:	c10080e7          	jalr	-1008(ra) # 57fc <open>
  if(fd != -1){
    1bf4:	57fd                	li	a5,-1
    1bf6:	08f51863          	bne	a0,a5,1c86 <copyinstr3+0xf0>
  ret = link(b, b);
    1bfa:	85a6                	mv	a1,s1
    1bfc:	8526                	mv	a0,s1
    1bfe:	00004097          	auipc	ra,0x4
    1c02:	c1e080e7          	jalr	-994(ra) # 581c <link>
  if(ret != -1){
    1c06:	57fd                	li	a5,-1
    1c08:	08f51e63          	bne	a0,a5,1ca4 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    1c0c:	00005797          	auipc	a5,0x5
    1c10:	aa478793          	addi	a5,a5,-1372 # 66b0 <malloc+0xa32>
    1c14:	fcf43823          	sd	a5,-48(s0)
    1c18:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1c1c:	fd040593          	addi	a1,s0,-48
    1c20:	8526                	mv	a0,s1
    1c22:	00004097          	auipc	ra,0x4
    1c26:	bd2080e7          	jalr	-1070(ra) # 57f4 <exec>
  if(ret != -1){
    1c2a:	57fd                	li	a5,-1
    1c2c:	08f51c63          	bne	a0,a5,1cc4 <copyinstr3+0x12e>
}
    1c30:	70a2                	ld	ra,40(sp)
    1c32:	7402                	ld	s0,32(sp)
    1c34:	64e2                	ld	s1,24(sp)
    1c36:	6145                	addi	sp,sp,48
    1c38:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1c3a:	0347d513          	srli	a0,a5,0x34
    1c3e:	6785                	lui	a5,0x1
    1c40:	40a7853b          	subw	a0,a5,a0
    1c44:	00004097          	auipc	ra,0x4
    1c48:	c00080e7          	jalr	-1024(ra) # 5844 <sbrk>
    1c4c:	b7bd                	j	1bba <copyinstr3+0x24>
    printf("oops\n");
    1c4e:	00005517          	auipc	a0,0x5
    1c52:	f5a50513          	addi	a0,a0,-166 # 6ba8 <malloc+0xf2a>
    1c56:	00004097          	auipc	ra,0x4
    1c5a:	f6a080e7          	jalr	-150(ra) # 5bc0 <printf>
    exit(1);
    1c5e:	4505                	li	a0,1
    1c60:	00004097          	auipc	ra,0x4
    1c64:	b5c080e7          	jalr	-1188(ra) # 57bc <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1c68:	862a                	mv	a2,a0
    1c6a:	85a6                	mv	a1,s1
    1c6c:	00005517          	auipc	a0,0x5
    1c70:	e5c50513          	addi	a0,a0,-420 # 6ac8 <malloc+0xe4a>
    1c74:	00004097          	auipc	ra,0x4
    1c78:	f4c080e7          	jalr	-180(ra) # 5bc0 <printf>
    exit(1);
    1c7c:	4505                	li	a0,1
    1c7e:	00004097          	auipc	ra,0x4
    1c82:	b3e080e7          	jalr	-1218(ra) # 57bc <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1c86:	862a                	mv	a2,a0
    1c88:	85a6                	mv	a1,s1
    1c8a:	00005517          	auipc	a0,0x5
    1c8e:	e5e50513          	addi	a0,a0,-418 # 6ae8 <malloc+0xe6a>
    1c92:	00004097          	auipc	ra,0x4
    1c96:	f2e080e7          	jalr	-210(ra) # 5bc0 <printf>
    exit(1);
    1c9a:	4505                	li	a0,1
    1c9c:	00004097          	auipc	ra,0x4
    1ca0:	b20080e7          	jalr	-1248(ra) # 57bc <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1ca4:	86aa                	mv	a3,a0
    1ca6:	8626                	mv	a2,s1
    1ca8:	85a6                	mv	a1,s1
    1caa:	00005517          	auipc	a0,0x5
    1cae:	e5e50513          	addi	a0,a0,-418 # 6b08 <malloc+0xe8a>
    1cb2:	00004097          	auipc	ra,0x4
    1cb6:	f0e080e7          	jalr	-242(ra) # 5bc0 <printf>
    exit(1);
    1cba:	4505                	li	a0,1
    1cbc:	00004097          	auipc	ra,0x4
    1cc0:	b00080e7          	jalr	-1280(ra) # 57bc <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1cc4:	567d                	li	a2,-1
    1cc6:	85a6                	mv	a1,s1
    1cc8:	00005517          	auipc	a0,0x5
    1ccc:	e6850513          	addi	a0,a0,-408 # 6b30 <malloc+0xeb2>
    1cd0:	00004097          	auipc	ra,0x4
    1cd4:	ef0080e7          	jalr	-272(ra) # 5bc0 <printf>
    exit(1);
    1cd8:	4505                	li	a0,1
    1cda:	00004097          	auipc	ra,0x4
    1cde:	ae2080e7          	jalr	-1310(ra) # 57bc <exit>

0000000000001ce2 <rwsbrk>:
{
    1ce2:	1101                	addi	sp,sp,-32
    1ce4:	ec06                	sd	ra,24(sp)
    1ce6:	e822                	sd	s0,16(sp)
    1ce8:	e426                	sd	s1,8(sp)
    1cea:	e04a                	sd	s2,0(sp)
    1cec:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    1cee:	6509                	lui	a0,0x2
    1cf0:	00004097          	auipc	ra,0x4
    1cf4:	b54080e7          	jalr	-1196(ra) # 5844 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    1cf8:	57fd                	li	a5,-1
    1cfa:	06f50363          	beq	a0,a5,1d60 <rwsbrk+0x7e>
    1cfe:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    1d00:	7579                	lui	a0,0xffffe
    1d02:	00004097          	auipc	ra,0x4
    1d06:	b42080e7          	jalr	-1214(ra) # 5844 <sbrk>
    1d0a:	57fd                	li	a5,-1
    1d0c:	06f50763          	beq	a0,a5,1d7a <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    1d10:	20100593          	li	a1,513
    1d14:	00005517          	auipc	a0,0x5
    1d18:	ed450513          	addi	a0,a0,-300 # 6be8 <malloc+0xf6a>
    1d1c:	00004097          	auipc	ra,0x4
    1d20:	ae0080e7          	jalr	-1312(ra) # 57fc <open>
    1d24:	892a                	mv	s2,a0
  if(fd < 0){
    1d26:	06054763          	bltz	a0,1d94 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    1d2a:	6505                	lui	a0,0x1
    1d2c:	94aa                	add	s1,s1,a0
    1d2e:	40000613          	li	a2,1024
    1d32:	85a6                	mv	a1,s1
    1d34:	854a                	mv	a0,s2
    1d36:	00004097          	auipc	ra,0x4
    1d3a:	aa6080e7          	jalr	-1370(ra) # 57dc <write>
    1d3e:	862a                	mv	a2,a0
  if(n >= 0){
    1d40:	06054763          	bltz	a0,1dae <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    1d44:	85a6                	mv	a1,s1
    1d46:	00005517          	auipc	a0,0x5
    1d4a:	ec250513          	addi	a0,a0,-318 # 6c08 <malloc+0xf8a>
    1d4e:	00004097          	auipc	ra,0x4
    1d52:	e72080e7          	jalr	-398(ra) # 5bc0 <printf>
    exit(1);
    1d56:	4505                	li	a0,1
    1d58:	00004097          	auipc	ra,0x4
    1d5c:	a64080e7          	jalr	-1436(ra) # 57bc <exit>
    printf("sbrk(rwsbrk) failed\n");
    1d60:	00005517          	auipc	a0,0x5
    1d64:	e5050513          	addi	a0,a0,-432 # 6bb0 <malloc+0xf32>
    1d68:	00004097          	auipc	ra,0x4
    1d6c:	e58080e7          	jalr	-424(ra) # 5bc0 <printf>
    exit(1);
    1d70:	4505                	li	a0,1
    1d72:	00004097          	auipc	ra,0x4
    1d76:	a4a080e7          	jalr	-1462(ra) # 57bc <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    1d7a:	00005517          	auipc	a0,0x5
    1d7e:	e4e50513          	addi	a0,a0,-434 # 6bc8 <malloc+0xf4a>
    1d82:	00004097          	auipc	ra,0x4
    1d86:	e3e080e7          	jalr	-450(ra) # 5bc0 <printf>
    exit(1);
    1d8a:	4505                	li	a0,1
    1d8c:	00004097          	auipc	ra,0x4
    1d90:	a30080e7          	jalr	-1488(ra) # 57bc <exit>
    printf("open(rwsbrk) failed\n");
    1d94:	00005517          	auipc	a0,0x5
    1d98:	e5c50513          	addi	a0,a0,-420 # 6bf0 <malloc+0xf72>
    1d9c:	00004097          	auipc	ra,0x4
    1da0:	e24080e7          	jalr	-476(ra) # 5bc0 <printf>
    exit(1);
    1da4:	4505                	li	a0,1
    1da6:	00004097          	auipc	ra,0x4
    1daa:	a16080e7          	jalr	-1514(ra) # 57bc <exit>
  close(fd);
    1dae:	854a                	mv	a0,s2
    1db0:	00004097          	auipc	ra,0x4
    1db4:	a34080e7          	jalr	-1484(ra) # 57e4 <close>
  unlink("rwsbrk");
    1db8:	00005517          	auipc	a0,0x5
    1dbc:	e3050513          	addi	a0,a0,-464 # 6be8 <malloc+0xf6a>
    1dc0:	00004097          	auipc	ra,0x4
    1dc4:	a4c080e7          	jalr	-1460(ra) # 580c <unlink>
  fd = open("README", O_RDONLY);
    1dc8:	4581                	li	a1,0
    1dca:	00005517          	auipc	a0,0x5
    1dce:	96650513          	addi	a0,a0,-1690 # 6730 <malloc+0xab2>
    1dd2:	00004097          	auipc	ra,0x4
    1dd6:	a2a080e7          	jalr	-1494(ra) # 57fc <open>
    1dda:	892a                	mv	s2,a0
  if(fd < 0){
    1ddc:	02054963          	bltz	a0,1e0e <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    1de0:	4629                	li	a2,10
    1de2:	85a6                	mv	a1,s1
    1de4:	00004097          	auipc	ra,0x4
    1de8:	9f0080e7          	jalr	-1552(ra) # 57d4 <read>
    1dec:	862a                	mv	a2,a0
  if(n >= 0){
    1dee:	02054d63          	bltz	a0,1e28 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    1df2:	85a6                	mv	a1,s1
    1df4:	00005517          	auipc	a0,0x5
    1df8:	e4450513          	addi	a0,a0,-444 # 6c38 <malloc+0xfba>
    1dfc:	00004097          	auipc	ra,0x4
    1e00:	dc4080e7          	jalr	-572(ra) # 5bc0 <printf>
    exit(1);
    1e04:	4505                	li	a0,1
    1e06:	00004097          	auipc	ra,0x4
    1e0a:	9b6080e7          	jalr	-1610(ra) # 57bc <exit>
    printf("open(rwsbrk) failed\n");
    1e0e:	00005517          	auipc	a0,0x5
    1e12:	de250513          	addi	a0,a0,-542 # 6bf0 <malloc+0xf72>
    1e16:	00004097          	auipc	ra,0x4
    1e1a:	daa080e7          	jalr	-598(ra) # 5bc0 <printf>
    exit(1);
    1e1e:	4505                	li	a0,1
    1e20:	00004097          	auipc	ra,0x4
    1e24:	99c080e7          	jalr	-1636(ra) # 57bc <exit>
  close(fd);
    1e28:	854a                	mv	a0,s2
    1e2a:	00004097          	auipc	ra,0x4
    1e2e:	9ba080e7          	jalr	-1606(ra) # 57e4 <close>
  exit(0);
    1e32:	4501                	li	a0,0
    1e34:	00004097          	auipc	ra,0x4
    1e38:	988080e7          	jalr	-1656(ra) # 57bc <exit>

0000000000001e3c <truncate1>:
{
    1e3c:	711d                	addi	sp,sp,-96
    1e3e:	ec86                	sd	ra,88(sp)
    1e40:	e8a2                	sd	s0,80(sp)
    1e42:	e4a6                	sd	s1,72(sp)
    1e44:	e0ca                	sd	s2,64(sp)
    1e46:	fc4e                	sd	s3,56(sp)
    1e48:	f852                	sd	s4,48(sp)
    1e4a:	f456                	sd	s5,40(sp)
    1e4c:	1080                	addi	s0,sp,96
    1e4e:	8aaa                	mv	s5,a0
  unlink("truncfile");
    1e50:	00005517          	auipc	a0,0x5
    1e54:	e1050513          	addi	a0,a0,-496 # 6c60 <malloc+0xfe2>
    1e58:	00004097          	auipc	ra,0x4
    1e5c:	9b4080e7          	jalr	-1612(ra) # 580c <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    1e60:	60100593          	li	a1,1537
    1e64:	00005517          	auipc	a0,0x5
    1e68:	dfc50513          	addi	a0,a0,-516 # 6c60 <malloc+0xfe2>
    1e6c:	00004097          	auipc	ra,0x4
    1e70:	990080e7          	jalr	-1648(ra) # 57fc <open>
    1e74:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
    1e76:	4611                	li	a2,4
    1e78:	00005597          	auipc	a1,0x5
    1e7c:	df858593          	addi	a1,a1,-520 # 6c70 <malloc+0xff2>
    1e80:	00004097          	auipc	ra,0x4
    1e84:	95c080e7          	jalr	-1700(ra) # 57dc <write>
  close(fd1);
    1e88:	8526                	mv	a0,s1
    1e8a:	00004097          	auipc	ra,0x4
    1e8e:	95a080e7          	jalr	-1702(ra) # 57e4 <close>
  int fd2 = open("truncfile", O_RDONLY);
    1e92:	4581                	li	a1,0
    1e94:	00005517          	auipc	a0,0x5
    1e98:	dcc50513          	addi	a0,a0,-564 # 6c60 <malloc+0xfe2>
    1e9c:	00004097          	auipc	ra,0x4
    1ea0:	960080e7          	jalr	-1696(ra) # 57fc <open>
    1ea4:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
    1ea6:	02000613          	li	a2,32
    1eaa:	fa040593          	addi	a1,s0,-96
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	926080e7          	jalr	-1754(ra) # 57d4 <read>
  if(n != 4){
    1eb6:	4791                	li	a5,4
    1eb8:	0cf51e63          	bne	a0,a5,1f94 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
    1ebc:	40100593          	li	a1,1025
    1ec0:	00005517          	auipc	a0,0x5
    1ec4:	da050513          	addi	a0,a0,-608 # 6c60 <malloc+0xfe2>
    1ec8:	00004097          	auipc	ra,0x4
    1ecc:	934080e7          	jalr	-1740(ra) # 57fc <open>
    1ed0:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
    1ed2:	4581                	li	a1,0
    1ed4:	00005517          	auipc	a0,0x5
    1ed8:	d8c50513          	addi	a0,a0,-628 # 6c60 <malloc+0xfe2>
    1edc:	00004097          	auipc	ra,0x4
    1ee0:	920080e7          	jalr	-1760(ra) # 57fc <open>
    1ee4:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
    1ee6:	02000613          	li	a2,32
    1eea:	fa040593          	addi	a1,s0,-96
    1eee:	00004097          	auipc	ra,0x4
    1ef2:	8e6080e7          	jalr	-1818(ra) # 57d4 <read>
    1ef6:	8a2a                	mv	s4,a0
  if(n != 0){
    1ef8:	ed4d                	bnez	a0,1fb2 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
    1efa:	02000613          	li	a2,32
    1efe:	fa040593          	addi	a1,s0,-96
    1f02:	8526                	mv	a0,s1
    1f04:	00004097          	auipc	ra,0x4
    1f08:	8d0080e7          	jalr	-1840(ra) # 57d4 <read>
    1f0c:	8a2a                	mv	s4,a0
  if(n != 0){
    1f0e:	e971                	bnez	a0,1fe2 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
    1f10:	4619                	li	a2,6
    1f12:	00005597          	auipc	a1,0x5
    1f16:	dc658593          	addi	a1,a1,-570 # 6cd8 <malloc+0x105a>
    1f1a:	854e                	mv	a0,s3
    1f1c:	00004097          	auipc	ra,0x4
    1f20:	8c0080e7          	jalr	-1856(ra) # 57dc <write>
  n = read(fd3, buf, sizeof(buf));
    1f24:	02000613          	li	a2,32
    1f28:	fa040593          	addi	a1,s0,-96
    1f2c:	854a                	mv	a0,s2
    1f2e:	00004097          	auipc	ra,0x4
    1f32:	8a6080e7          	jalr	-1882(ra) # 57d4 <read>
  if(n != 6){
    1f36:	4799                	li	a5,6
    1f38:	0cf51d63          	bne	a0,a5,2012 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
    1f3c:	02000613          	li	a2,32
    1f40:	fa040593          	addi	a1,s0,-96
    1f44:	8526                	mv	a0,s1
    1f46:	00004097          	auipc	ra,0x4
    1f4a:	88e080e7          	jalr	-1906(ra) # 57d4 <read>
  if(n != 2){
    1f4e:	4789                	li	a5,2
    1f50:	0ef51063          	bne	a0,a5,2030 <truncate1+0x1f4>
  unlink("truncfile");
    1f54:	00005517          	auipc	a0,0x5
    1f58:	d0c50513          	addi	a0,a0,-756 # 6c60 <malloc+0xfe2>
    1f5c:	00004097          	auipc	ra,0x4
    1f60:	8b0080e7          	jalr	-1872(ra) # 580c <unlink>
  close(fd1);
    1f64:	854e                	mv	a0,s3
    1f66:	00004097          	auipc	ra,0x4
    1f6a:	87e080e7          	jalr	-1922(ra) # 57e4 <close>
  close(fd2);
    1f6e:	8526                	mv	a0,s1
    1f70:	00004097          	auipc	ra,0x4
    1f74:	874080e7          	jalr	-1932(ra) # 57e4 <close>
  close(fd3);
    1f78:	854a                	mv	a0,s2
    1f7a:	00004097          	auipc	ra,0x4
    1f7e:	86a080e7          	jalr	-1942(ra) # 57e4 <close>
}
    1f82:	60e6                	ld	ra,88(sp)
    1f84:	6446                	ld	s0,80(sp)
    1f86:	64a6                	ld	s1,72(sp)
    1f88:	6906                	ld	s2,64(sp)
    1f8a:	79e2                	ld	s3,56(sp)
    1f8c:	7a42                	ld	s4,48(sp)
    1f8e:	7aa2                	ld	s5,40(sp)
    1f90:	6125                	addi	sp,sp,96
    1f92:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
    1f94:	862a                	mv	a2,a0
    1f96:	85d6                	mv	a1,s5
    1f98:	00005517          	auipc	a0,0x5
    1f9c:	ce050513          	addi	a0,a0,-800 # 6c78 <malloc+0xffa>
    1fa0:	00004097          	auipc	ra,0x4
    1fa4:	c20080e7          	jalr	-992(ra) # 5bc0 <printf>
    exit(1);
    1fa8:	4505                	li	a0,1
    1faa:	00004097          	auipc	ra,0x4
    1fae:	812080e7          	jalr	-2030(ra) # 57bc <exit>
    printf("aaa fd3=%d\n", fd3);
    1fb2:	85ca                	mv	a1,s2
    1fb4:	00005517          	auipc	a0,0x5
    1fb8:	ce450513          	addi	a0,a0,-796 # 6c98 <malloc+0x101a>
    1fbc:	00004097          	auipc	ra,0x4
    1fc0:	c04080e7          	jalr	-1020(ra) # 5bc0 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
    1fc4:	8652                	mv	a2,s4
    1fc6:	85d6                	mv	a1,s5
    1fc8:	00005517          	auipc	a0,0x5
    1fcc:	ce050513          	addi	a0,a0,-800 # 6ca8 <malloc+0x102a>
    1fd0:	00004097          	auipc	ra,0x4
    1fd4:	bf0080e7          	jalr	-1040(ra) # 5bc0 <printf>
    exit(1);
    1fd8:	4505                	li	a0,1
    1fda:	00003097          	auipc	ra,0x3
    1fde:	7e2080e7          	jalr	2018(ra) # 57bc <exit>
    printf("bbb fd2=%d\n", fd2);
    1fe2:	85a6                	mv	a1,s1
    1fe4:	00005517          	auipc	a0,0x5
    1fe8:	ce450513          	addi	a0,a0,-796 # 6cc8 <malloc+0x104a>
    1fec:	00004097          	auipc	ra,0x4
    1ff0:	bd4080e7          	jalr	-1068(ra) # 5bc0 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
    1ff4:	8652                	mv	a2,s4
    1ff6:	85d6                	mv	a1,s5
    1ff8:	00005517          	auipc	a0,0x5
    1ffc:	cb050513          	addi	a0,a0,-848 # 6ca8 <malloc+0x102a>
    2000:	00004097          	auipc	ra,0x4
    2004:	bc0080e7          	jalr	-1088(ra) # 5bc0 <printf>
    exit(1);
    2008:	4505                	li	a0,1
    200a:	00003097          	auipc	ra,0x3
    200e:	7b2080e7          	jalr	1970(ra) # 57bc <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
    2012:	862a                	mv	a2,a0
    2014:	85d6                	mv	a1,s5
    2016:	00005517          	auipc	a0,0x5
    201a:	cca50513          	addi	a0,a0,-822 # 6ce0 <malloc+0x1062>
    201e:	00004097          	auipc	ra,0x4
    2022:	ba2080e7          	jalr	-1118(ra) # 5bc0 <printf>
    exit(1);
    2026:	4505                	li	a0,1
    2028:	00003097          	auipc	ra,0x3
    202c:	794080e7          	jalr	1940(ra) # 57bc <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
    2030:	862a                	mv	a2,a0
    2032:	85d6                	mv	a1,s5
    2034:	00005517          	auipc	a0,0x5
    2038:	ccc50513          	addi	a0,a0,-820 # 6d00 <malloc+0x1082>
    203c:	00004097          	auipc	ra,0x4
    2040:	b84080e7          	jalr	-1148(ra) # 5bc0 <printf>
    exit(1);
    2044:	4505                	li	a0,1
    2046:	00003097          	auipc	ra,0x3
    204a:	776080e7          	jalr	1910(ra) # 57bc <exit>

000000000000204e <truncate2>:
{
    204e:	7179                	addi	sp,sp,-48
    2050:	f406                	sd	ra,40(sp)
    2052:	f022                	sd	s0,32(sp)
    2054:	ec26                	sd	s1,24(sp)
    2056:	e84a                	sd	s2,16(sp)
    2058:	e44e                	sd	s3,8(sp)
    205a:	1800                	addi	s0,sp,48
    205c:	89aa                	mv	s3,a0
  unlink("truncfile");
    205e:	00005517          	auipc	a0,0x5
    2062:	c0250513          	addi	a0,a0,-1022 # 6c60 <malloc+0xfe2>
    2066:	00003097          	auipc	ra,0x3
    206a:	7a6080e7          	jalr	1958(ra) # 580c <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
    206e:	60100593          	li	a1,1537
    2072:	00005517          	auipc	a0,0x5
    2076:	bee50513          	addi	a0,a0,-1042 # 6c60 <malloc+0xfe2>
    207a:	00003097          	auipc	ra,0x3
    207e:	782080e7          	jalr	1922(ra) # 57fc <open>
    2082:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
    2084:	4611                	li	a2,4
    2086:	00005597          	auipc	a1,0x5
    208a:	bea58593          	addi	a1,a1,-1046 # 6c70 <malloc+0xff2>
    208e:	00003097          	auipc	ra,0x3
    2092:	74e080e7          	jalr	1870(ra) # 57dc <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
    2096:	40100593          	li	a1,1025
    209a:	00005517          	auipc	a0,0x5
    209e:	bc650513          	addi	a0,a0,-1082 # 6c60 <malloc+0xfe2>
    20a2:	00003097          	auipc	ra,0x3
    20a6:	75a080e7          	jalr	1882(ra) # 57fc <open>
    20aa:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
    20ac:	4605                	li	a2,1
    20ae:	00004597          	auipc	a1,0x4
    20b2:	6fa58593          	addi	a1,a1,1786 # 67a8 <malloc+0xb2a>
    20b6:	8526                	mv	a0,s1
    20b8:	00003097          	auipc	ra,0x3
    20bc:	724080e7          	jalr	1828(ra) # 57dc <write>
  if(n != -1){
    20c0:	57fd                	li	a5,-1
    20c2:	02f51b63          	bne	a0,a5,20f8 <truncate2+0xaa>
  unlink("truncfile");
    20c6:	00005517          	auipc	a0,0x5
    20ca:	b9a50513          	addi	a0,a0,-1126 # 6c60 <malloc+0xfe2>
    20ce:	00003097          	auipc	ra,0x3
    20d2:	73e080e7          	jalr	1854(ra) # 580c <unlink>
  close(fd1);
    20d6:	8526                	mv	a0,s1
    20d8:	00003097          	auipc	ra,0x3
    20dc:	70c080e7          	jalr	1804(ra) # 57e4 <close>
  close(fd2);
    20e0:	854a                	mv	a0,s2
    20e2:	00003097          	auipc	ra,0x3
    20e6:	702080e7          	jalr	1794(ra) # 57e4 <close>
}
    20ea:	70a2                	ld	ra,40(sp)
    20ec:	7402                	ld	s0,32(sp)
    20ee:	64e2                	ld	s1,24(sp)
    20f0:	6942                	ld	s2,16(sp)
    20f2:	69a2                	ld	s3,8(sp)
    20f4:	6145                	addi	sp,sp,48
    20f6:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
    20f8:	862a                	mv	a2,a0
    20fa:	85ce                	mv	a1,s3
    20fc:	00005517          	auipc	a0,0x5
    2100:	c2450513          	addi	a0,a0,-988 # 6d20 <malloc+0x10a2>
    2104:	00004097          	auipc	ra,0x4
    2108:	abc080e7          	jalr	-1348(ra) # 5bc0 <printf>
    exit(1);
    210c:	4505                	li	a0,1
    210e:	00003097          	auipc	ra,0x3
    2112:	6ae080e7          	jalr	1710(ra) # 57bc <exit>

0000000000002116 <truncate3>:
{
    2116:	7159                	addi	sp,sp,-112
    2118:	f486                	sd	ra,104(sp)
    211a:	f0a2                	sd	s0,96(sp)
    211c:	eca6                	sd	s1,88(sp)
    211e:	e8ca                	sd	s2,80(sp)
    2120:	e4ce                	sd	s3,72(sp)
    2122:	e0d2                	sd	s4,64(sp)
    2124:	fc56                	sd	s5,56(sp)
    2126:	1880                	addi	s0,sp,112
    2128:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    212a:	60100593          	li	a1,1537
    212e:	00005517          	auipc	a0,0x5
    2132:	b3250513          	addi	a0,a0,-1230 # 6c60 <malloc+0xfe2>
    2136:	00003097          	auipc	ra,0x3
    213a:	6c6080e7          	jalr	1734(ra) # 57fc <open>
    213e:	00003097          	auipc	ra,0x3
    2142:	6a6080e7          	jalr	1702(ra) # 57e4 <close>
  pid = fork();
    2146:	00003097          	auipc	ra,0x3
    214a:	66e080e7          	jalr	1646(ra) # 57b4 <fork>
  if(pid < 0){
    214e:	08054063          	bltz	a0,21ce <truncate3+0xb8>
  if(pid == 0){
    2152:	e969                	bnez	a0,2224 <truncate3+0x10e>
    2154:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    2158:	00005a17          	auipc	s4,0x5
    215c:	b08a0a13          	addi	s4,s4,-1272 # 6c60 <malloc+0xfe2>
      int n = write(fd, "1234567890", 10);
    2160:	00005a97          	auipc	s5,0x5
    2164:	c00a8a93          	addi	s5,s5,-1024 # 6d60 <malloc+0x10e2>
      int fd = open("truncfile", O_WRONLY);
    2168:	4585                	li	a1,1
    216a:	8552                	mv	a0,s4
    216c:	00003097          	auipc	ra,0x3
    2170:	690080e7          	jalr	1680(ra) # 57fc <open>
    2174:	84aa                	mv	s1,a0
      if(fd < 0){
    2176:	06054a63          	bltz	a0,21ea <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    217a:	4629                	li	a2,10
    217c:	85d6                	mv	a1,s5
    217e:	00003097          	auipc	ra,0x3
    2182:	65e080e7          	jalr	1630(ra) # 57dc <write>
      if(n != 10){
    2186:	47a9                	li	a5,10
    2188:	06f51f63          	bne	a0,a5,2206 <truncate3+0xf0>
      close(fd);
    218c:	8526                	mv	a0,s1
    218e:	00003097          	auipc	ra,0x3
    2192:	656080e7          	jalr	1622(ra) # 57e4 <close>
      fd = open("truncfile", O_RDONLY);
    2196:	4581                	li	a1,0
    2198:	8552                	mv	a0,s4
    219a:	00003097          	auipc	ra,0x3
    219e:	662080e7          	jalr	1634(ra) # 57fc <open>
    21a2:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    21a4:	02000613          	li	a2,32
    21a8:	f9840593          	addi	a1,s0,-104
    21ac:	00003097          	auipc	ra,0x3
    21b0:	628080e7          	jalr	1576(ra) # 57d4 <read>
      close(fd);
    21b4:	8526                	mv	a0,s1
    21b6:	00003097          	auipc	ra,0x3
    21ba:	62e080e7          	jalr	1582(ra) # 57e4 <close>
    for(int i = 0; i < 100; i++){
    21be:	39fd                	addiw	s3,s3,-1
    21c0:	fa0994e3          	bnez	s3,2168 <truncate3+0x52>
    exit(0);
    21c4:	4501                	li	a0,0
    21c6:	00003097          	auipc	ra,0x3
    21ca:	5f6080e7          	jalr	1526(ra) # 57bc <exit>
    printf("%s: fork failed\n", s);
    21ce:	85ca                	mv	a1,s2
    21d0:	00004517          	auipc	a0,0x4
    21d4:	cb050513          	addi	a0,a0,-848 # 5e80 <malloc+0x202>
    21d8:	00004097          	auipc	ra,0x4
    21dc:	9e8080e7          	jalr	-1560(ra) # 5bc0 <printf>
    exit(1);
    21e0:	4505                	li	a0,1
    21e2:	00003097          	auipc	ra,0x3
    21e6:	5da080e7          	jalr	1498(ra) # 57bc <exit>
        printf("%s: open failed\n", s);
    21ea:	85ca                	mv	a1,s2
    21ec:	00005517          	auipc	a0,0x5
    21f0:	b5c50513          	addi	a0,a0,-1188 # 6d48 <malloc+0x10ca>
    21f4:	00004097          	auipc	ra,0x4
    21f8:	9cc080e7          	jalr	-1588(ra) # 5bc0 <printf>
        exit(1);
    21fc:	4505                	li	a0,1
    21fe:	00003097          	auipc	ra,0x3
    2202:	5be080e7          	jalr	1470(ra) # 57bc <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    2206:	862a                	mv	a2,a0
    2208:	85ca                	mv	a1,s2
    220a:	00005517          	auipc	a0,0x5
    220e:	b6650513          	addi	a0,a0,-1178 # 6d70 <malloc+0x10f2>
    2212:	00004097          	auipc	ra,0x4
    2216:	9ae080e7          	jalr	-1618(ra) # 5bc0 <printf>
        exit(1);
    221a:	4505                	li	a0,1
    221c:	00003097          	auipc	ra,0x3
    2220:	5a0080e7          	jalr	1440(ra) # 57bc <exit>
    2224:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    2228:	00005a17          	auipc	s4,0x5
    222c:	a38a0a13          	addi	s4,s4,-1480 # 6c60 <malloc+0xfe2>
    int n = write(fd, "xxx", 3);
    2230:	00005a97          	auipc	s5,0x5
    2234:	b60a8a93          	addi	s5,s5,-1184 # 6d90 <malloc+0x1112>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    2238:	60100593          	li	a1,1537
    223c:	8552                	mv	a0,s4
    223e:	00003097          	auipc	ra,0x3
    2242:	5be080e7          	jalr	1470(ra) # 57fc <open>
    2246:	84aa                	mv	s1,a0
    if(fd < 0){
    2248:	04054763          	bltz	a0,2296 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    224c:	460d                	li	a2,3
    224e:	85d6                	mv	a1,s5
    2250:	00003097          	auipc	ra,0x3
    2254:	58c080e7          	jalr	1420(ra) # 57dc <write>
    if(n != 3){
    2258:	478d                	li	a5,3
    225a:	04f51c63          	bne	a0,a5,22b2 <truncate3+0x19c>
    close(fd);
    225e:	8526                	mv	a0,s1
    2260:	00003097          	auipc	ra,0x3
    2264:	584080e7          	jalr	1412(ra) # 57e4 <close>
  for(int i = 0; i < 150; i++){
    2268:	39fd                	addiw	s3,s3,-1
    226a:	fc0997e3          	bnez	s3,2238 <truncate3+0x122>
  wait(&xstatus);
    226e:	fbc40513          	addi	a0,s0,-68
    2272:	00003097          	auipc	ra,0x3
    2276:	552080e7          	jalr	1362(ra) # 57c4 <wait>
  unlink("truncfile");
    227a:	00005517          	auipc	a0,0x5
    227e:	9e650513          	addi	a0,a0,-1562 # 6c60 <malloc+0xfe2>
    2282:	00003097          	auipc	ra,0x3
    2286:	58a080e7          	jalr	1418(ra) # 580c <unlink>
  exit(xstatus);
    228a:	fbc42503          	lw	a0,-68(s0)
    228e:	00003097          	auipc	ra,0x3
    2292:	52e080e7          	jalr	1326(ra) # 57bc <exit>
      printf("%s: open failed\n", s);
    2296:	85ca                	mv	a1,s2
    2298:	00005517          	auipc	a0,0x5
    229c:	ab050513          	addi	a0,a0,-1360 # 6d48 <malloc+0x10ca>
    22a0:	00004097          	auipc	ra,0x4
    22a4:	920080e7          	jalr	-1760(ra) # 5bc0 <printf>
      exit(1);
    22a8:	4505                	li	a0,1
    22aa:	00003097          	auipc	ra,0x3
    22ae:	512080e7          	jalr	1298(ra) # 57bc <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    22b2:	862a                	mv	a2,a0
    22b4:	85ca                	mv	a1,s2
    22b6:	00005517          	auipc	a0,0x5
    22ba:	ae250513          	addi	a0,a0,-1310 # 6d98 <malloc+0x111a>
    22be:	00004097          	auipc	ra,0x4
    22c2:	902080e7          	jalr	-1790(ra) # 5bc0 <printf>
      exit(1);
    22c6:	4505                	li	a0,1
    22c8:	00003097          	auipc	ra,0x3
    22cc:	4f4080e7          	jalr	1268(ra) # 57bc <exit>

00000000000022d0 <dirtest>:
{
    22d0:	1101                	addi	sp,sp,-32
    22d2:	ec06                	sd	ra,24(sp)
    22d4:	e822                	sd	s0,16(sp)
    22d6:	e426                	sd	s1,8(sp)
    22d8:	1000                	addi	s0,sp,32
    22da:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    22dc:	00005517          	auipc	a0,0x5
    22e0:	adc50513          	addi	a0,a0,-1316 # 6db8 <malloc+0x113a>
    22e4:	00003097          	auipc	ra,0x3
    22e8:	540080e7          	jalr	1344(ra) # 5824 <mkdir>
    22ec:	04054563          	bltz	a0,2336 <dirtest+0x66>
  if(chdir("dir0") < 0){
    22f0:	00005517          	auipc	a0,0x5
    22f4:	ac850513          	addi	a0,a0,-1336 # 6db8 <malloc+0x113a>
    22f8:	00003097          	auipc	ra,0x3
    22fc:	534080e7          	jalr	1332(ra) # 582c <chdir>
    2300:	04054963          	bltz	a0,2352 <dirtest+0x82>
  if(chdir("..") < 0){
    2304:	00004517          	auipc	a0,0x4
    2308:	2d450513          	addi	a0,a0,724 # 65d8 <malloc+0x95a>
    230c:	00003097          	auipc	ra,0x3
    2310:	520080e7          	jalr	1312(ra) # 582c <chdir>
    2314:	04054d63          	bltz	a0,236e <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2318:	00005517          	auipc	a0,0x5
    231c:	aa050513          	addi	a0,a0,-1376 # 6db8 <malloc+0x113a>
    2320:	00003097          	auipc	ra,0x3
    2324:	4ec080e7          	jalr	1260(ra) # 580c <unlink>
    2328:	06054163          	bltz	a0,238a <dirtest+0xba>
}
    232c:	60e2                	ld	ra,24(sp)
    232e:	6442                	ld	s0,16(sp)
    2330:	64a2                	ld	s1,8(sp)
    2332:	6105                	addi	sp,sp,32
    2334:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2336:	85a6                	mv	a1,s1
    2338:	00004517          	auipc	a0,0x4
    233c:	1a850513          	addi	a0,a0,424 # 64e0 <malloc+0x862>
    2340:	00004097          	auipc	ra,0x4
    2344:	880080e7          	jalr	-1920(ra) # 5bc0 <printf>
    exit(1);
    2348:	4505                	li	a0,1
    234a:	00003097          	auipc	ra,0x3
    234e:	472080e7          	jalr	1138(ra) # 57bc <exit>
    printf("%s: chdir dir0 failed\n", s);
    2352:	85a6                	mv	a1,s1
    2354:	00005517          	auipc	a0,0x5
    2358:	a6c50513          	addi	a0,a0,-1428 # 6dc0 <malloc+0x1142>
    235c:	00004097          	auipc	ra,0x4
    2360:	864080e7          	jalr	-1948(ra) # 5bc0 <printf>
    exit(1);
    2364:	4505                	li	a0,1
    2366:	00003097          	auipc	ra,0x3
    236a:	456080e7          	jalr	1110(ra) # 57bc <exit>
    printf("%s: chdir .. failed\n", s);
    236e:	85a6                	mv	a1,s1
    2370:	00005517          	auipc	a0,0x5
    2374:	a6850513          	addi	a0,a0,-1432 # 6dd8 <malloc+0x115a>
    2378:	00004097          	auipc	ra,0x4
    237c:	848080e7          	jalr	-1976(ra) # 5bc0 <printf>
    exit(1);
    2380:	4505                	li	a0,1
    2382:	00003097          	auipc	ra,0x3
    2386:	43a080e7          	jalr	1082(ra) # 57bc <exit>
    printf("%s: unlink dir0 failed\n", s);
    238a:	85a6                	mv	a1,s1
    238c:	00005517          	auipc	a0,0x5
    2390:	a6450513          	addi	a0,a0,-1436 # 6df0 <malloc+0x1172>
    2394:	00004097          	auipc	ra,0x4
    2398:	82c080e7          	jalr	-2004(ra) # 5bc0 <printf>
    exit(1);
    239c:	4505                	li	a0,1
    239e:	00003097          	auipc	ra,0x3
    23a2:	41e080e7          	jalr	1054(ra) # 57bc <exit>

00000000000023a6 <exectest>:
{
    23a6:	715d                	addi	sp,sp,-80
    23a8:	e486                	sd	ra,72(sp)
    23aa:	e0a2                	sd	s0,64(sp)
    23ac:	fc26                	sd	s1,56(sp)
    23ae:	f84a                	sd	s2,48(sp)
    23b0:	0880                	addi	s0,sp,80
    23b2:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    23b4:	00004797          	auipc	a5,0x4
    23b8:	b8c78793          	addi	a5,a5,-1140 # 5f40 <malloc+0x2c2>
    23bc:	fcf43023          	sd	a5,-64(s0)
    23c0:	00005797          	auipc	a5,0x5
    23c4:	a4878793          	addi	a5,a5,-1464 # 6e08 <malloc+0x118a>
    23c8:	fcf43423          	sd	a5,-56(s0)
    23cc:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    23d0:	00005517          	auipc	a0,0x5
    23d4:	a4050513          	addi	a0,a0,-1472 # 6e10 <malloc+0x1192>
    23d8:	00003097          	auipc	ra,0x3
    23dc:	434080e7          	jalr	1076(ra) # 580c <unlink>
  pid = fork();
    23e0:	00003097          	auipc	ra,0x3
    23e4:	3d4080e7          	jalr	980(ra) # 57b4 <fork>
  if(pid < 0) {
    23e8:	04054663          	bltz	a0,2434 <exectest+0x8e>
    23ec:	84aa                	mv	s1,a0
  if(pid == 0) {
    23ee:	e959                	bnez	a0,2484 <exectest+0xde>
    close(1);
    23f0:	4505                	li	a0,1
    23f2:	00003097          	auipc	ra,0x3
    23f6:	3f2080e7          	jalr	1010(ra) # 57e4 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    23fa:	20100593          	li	a1,513
    23fe:	00005517          	auipc	a0,0x5
    2402:	a1250513          	addi	a0,a0,-1518 # 6e10 <malloc+0x1192>
    2406:	00003097          	auipc	ra,0x3
    240a:	3f6080e7          	jalr	1014(ra) # 57fc <open>
    if(fd < 0) {
    240e:	04054163          	bltz	a0,2450 <exectest+0xaa>
    if(fd != 1) {
    2412:	4785                	li	a5,1
    2414:	04f50c63          	beq	a0,a5,246c <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    2418:	85ca                	mv	a1,s2
    241a:	00005517          	auipc	a0,0x5
    241e:	a1650513          	addi	a0,a0,-1514 # 6e30 <malloc+0x11b2>
    2422:	00003097          	auipc	ra,0x3
    2426:	79e080e7          	jalr	1950(ra) # 5bc0 <printf>
      exit(1);
    242a:	4505                	li	a0,1
    242c:	00003097          	auipc	ra,0x3
    2430:	390080e7          	jalr	912(ra) # 57bc <exit>
     printf("%s: fork failed\n", s);
    2434:	85ca                	mv	a1,s2
    2436:	00004517          	auipc	a0,0x4
    243a:	a4a50513          	addi	a0,a0,-1462 # 5e80 <malloc+0x202>
    243e:	00003097          	auipc	ra,0x3
    2442:	782080e7          	jalr	1922(ra) # 5bc0 <printf>
     exit(1);
    2446:	4505                	li	a0,1
    2448:	00003097          	auipc	ra,0x3
    244c:	374080e7          	jalr	884(ra) # 57bc <exit>
      printf("%s: create failed\n", s);
    2450:	85ca                	mv	a1,s2
    2452:	00005517          	auipc	a0,0x5
    2456:	9c650513          	addi	a0,a0,-1594 # 6e18 <malloc+0x119a>
    245a:	00003097          	auipc	ra,0x3
    245e:	766080e7          	jalr	1894(ra) # 5bc0 <printf>
      exit(1);
    2462:	4505                	li	a0,1
    2464:	00003097          	auipc	ra,0x3
    2468:	358080e7          	jalr	856(ra) # 57bc <exit>
    if(exec("echo", echoargv) < 0){
    246c:	fc040593          	addi	a1,s0,-64
    2470:	00004517          	auipc	a0,0x4
    2474:	ad050513          	addi	a0,a0,-1328 # 5f40 <malloc+0x2c2>
    2478:	00003097          	auipc	ra,0x3
    247c:	37c080e7          	jalr	892(ra) # 57f4 <exec>
    2480:	02054163          	bltz	a0,24a2 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    2484:	fdc40513          	addi	a0,s0,-36
    2488:	00003097          	auipc	ra,0x3
    248c:	33c080e7          	jalr	828(ra) # 57c4 <wait>
    2490:	02951763          	bne	a0,s1,24be <exectest+0x118>
  if(xstatus != 0)
    2494:	fdc42503          	lw	a0,-36(s0)
    2498:	cd0d                	beqz	a0,24d2 <exectest+0x12c>
    exit(xstatus);
    249a:	00003097          	auipc	ra,0x3
    249e:	322080e7          	jalr	802(ra) # 57bc <exit>
      printf("%s: exec echo failed\n", s);
    24a2:	85ca                	mv	a1,s2
    24a4:	00005517          	auipc	a0,0x5
    24a8:	99c50513          	addi	a0,a0,-1636 # 6e40 <malloc+0x11c2>
    24ac:	00003097          	auipc	ra,0x3
    24b0:	714080e7          	jalr	1812(ra) # 5bc0 <printf>
      exit(1);
    24b4:	4505                	li	a0,1
    24b6:	00003097          	auipc	ra,0x3
    24ba:	306080e7          	jalr	774(ra) # 57bc <exit>
    printf("%s: wait failed!\n", s);
    24be:	85ca                	mv	a1,s2
    24c0:	00005517          	auipc	a0,0x5
    24c4:	99850513          	addi	a0,a0,-1640 # 6e58 <malloc+0x11da>
    24c8:	00003097          	auipc	ra,0x3
    24cc:	6f8080e7          	jalr	1784(ra) # 5bc0 <printf>
    24d0:	b7d1                	j	2494 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    24d2:	4581                	li	a1,0
    24d4:	00005517          	auipc	a0,0x5
    24d8:	93c50513          	addi	a0,a0,-1732 # 6e10 <malloc+0x1192>
    24dc:	00003097          	auipc	ra,0x3
    24e0:	320080e7          	jalr	800(ra) # 57fc <open>
  if(fd < 0) {
    24e4:	02054a63          	bltz	a0,2518 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    24e8:	4609                	li	a2,2
    24ea:	fb840593          	addi	a1,s0,-72
    24ee:	00003097          	auipc	ra,0x3
    24f2:	2e6080e7          	jalr	742(ra) # 57d4 <read>
    24f6:	4789                	li	a5,2
    24f8:	02f50e63          	beq	a0,a5,2534 <exectest+0x18e>
    printf("%s: read failed\n", s);
    24fc:	85ca                	mv	a1,s2
    24fe:	00004517          	auipc	a0,0x4
    2502:	b5250513          	addi	a0,a0,-1198 # 6050 <malloc+0x3d2>
    2506:	00003097          	auipc	ra,0x3
    250a:	6ba080e7          	jalr	1722(ra) # 5bc0 <printf>
    exit(1);
    250e:	4505                	li	a0,1
    2510:	00003097          	auipc	ra,0x3
    2514:	2ac080e7          	jalr	684(ra) # 57bc <exit>
    printf("%s: open failed\n", s);
    2518:	85ca                	mv	a1,s2
    251a:	00005517          	auipc	a0,0x5
    251e:	82e50513          	addi	a0,a0,-2002 # 6d48 <malloc+0x10ca>
    2522:	00003097          	auipc	ra,0x3
    2526:	69e080e7          	jalr	1694(ra) # 5bc0 <printf>
    exit(1);
    252a:	4505                	li	a0,1
    252c:	00003097          	auipc	ra,0x3
    2530:	290080e7          	jalr	656(ra) # 57bc <exit>
  unlink("echo-ok");
    2534:	00005517          	auipc	a0,0x5
    2538:	8dc50513          	addi	a0,a0,-1828 # 6e10 <malloc+0x1192>
    253c:	00003097          	auipc	ra,0x3
    2540:	2d0080e7          	jalr	720(ra) # 580c <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    2544:	fb844703          	lbu	a4,-72(s0)
    2548:	04f00793          	li	a5,79
    254c:	00f71863          	bne	a4,a5,255c <exectest+0x1b6>
    2550:	fb944703          	lbu	a4,-71(s0)
    2554:	04b00793          	li	a5,75
    2558:	02f70063          	beq	a4,a5,2578 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    255c:	85ca                	mv	a1,s2
    255e:	00005517          	auipc	a0,0x5
    2562:	91250513          	addi	a0,a0,-1774 # 6e70 <malloc+0x11f2>
    2566:	00003097          	auipc	ra,0x3
    256a:	65a080e7          	jalr	1626(ra) # 5bc0 <printf>
    exit(1);
    256e:	4505                	li	a0,1
    2570:	00003097          	auipc	ra,0x3
    2574:	24c080e7          	jalr	588(ra) # 57bc <exit>
    exit(0);
    2578:	4501                	li	a0,0
    257a:	00003097          	auipc	ra,0x3
    257e:	242080e7          	jalr	578(ra) # 57bc <exit>

0000000000002582 <preempt>:
{
    2582:	7139                	addi	sp,sp,-64
    2584:	fc06                	sd	ra,56(sp)
    2586:	f822                	sd	s0,48(sp)
    2588:	f426                	sd	s1,40(sp)
    258a:	f04a                	sd	s2,32(sp)
    258c:	ec4e                	sd	s3,24(sp)
    258e:	e852                	sd	s4,16(sp)
    2590:	0080                	addi	s0,sp,64
    2592:	892a                	mv	s2,a0
  pid1 = fork();
    2594:	00003097          	auipc	ra,0x3
    2598:	220080e7          	jalr	544(ra) # 57b4 <fork>
  if(pid1 < 0) {
    259c:	00054563          	bltz	a0,25a6 <preempt+0x24>
    25a0:	84aa                	mv	s1,a0
  if(pid1 == 0)
    25a2:	e105                	bnez	a0,25c2 <preempt+0x40>
    for(;;)
    25a4:	a001                	j	25a4 <preempt+0x22>
    printf("%s: fork failed", s);
    25a6:	85ca                	mv	a1,s2
    25a8:	00005517          	auipc	a0,0x5
    25ac:	8e050513          	addi	a0,a0,-1824 # 6e88 <malloc+0x120a>
    25b0:	00003097          	auipc	ra,0x3
    25b4:	610080e7          	jalr	1552(ra) # 5bc0 <printf>
    exit(1);
    25b8:	4505                	li	a0,1
    25ba:	00003097          	auipc	ra,0x3
    25be:	202080e7          	jalr	514(ra) # 57bc <exit>
  pid2 = fork();
    25c2:	00003097          	auipc	ra,0x3
    25c6:	1f2080e7          	jalr	498(ra) # 57b4 <fork>
    25ca:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    25cc:	00054463          	bltz	a0,25d4 <preempt+0x52>
  if(pid2 == 0)
    25d0:	e105                	bnez	a0,25f0 <preempt+0x6e>
    for(;;)
    25d2:	a001                	j	25d2 <preempt+0x50>
    printf("%s: fork failed\n", s);
    25d4:	85ca                	mv	a1,s2
    25d6:	00004517          	auipc	a0,0x4
    25da:	8aa50513          	addi	a0,a0,-1878 # 5e80 <malloc+0x202>
    25de:	00003097          	auipc	ra,0x3
    25e2:	5e2080e7          	jalr	1506(ra) # 5bc0 <printf>
    exit(1);
    25e6:	4505                	li	a0,1
    25e8:	00003097          	auipc	ra,0x3
    25ec:	1d4080e7          	jalr	468(ra) # 57bc <exit>
  pipe(pfds);
    25f0:	fc840513          	addi	a0,s0,-56
    25f4:	00003097          	auipc	ra,0x3
    25f8:	1d8080e7          	jalr	472(ra) # 57cc <pipe>
  pid3 = fork();
    25fc:	00003097          	auipc	ra,0x3
    2600:	1b8080e7          	jalr	440(ra) # 57b4 <fork>
    2604:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    2606:	02054e63          	bltz	a0,2642 <preempt+0xc0>
  if(pid3 == 0){
    260a:	e525                	bnez	a0,2672 <preempt+0xf0>
    close(pfds[0]);
    260c:	fc842503          	lw	a0,-56(s0)
    2610:	00003097          	auipc	ra,0x3
    2614:	1d4080e7          	jalr	468(ra) # 57e4 <close>
    if(write(pfds[1], "x", 1) != 1)
    2618:	4605                	li	a2,1
    261a:	00004597          	auipc	a1,0x4
    261e:	18e58593          	addi	a1,a1,398 # 67a8 <malloc+0xb2a>
    2622:	fcc42503          	lw	a0,-52(s0)
    2626:	00003097          	auipc	ra,0x3
    262a:	1b6080e7          	jalr	438(ra) # 57dc <write>
    262e:	4785                	li	a5,1
    2630:	02f51763          	bne	a0,a5,265e <preempt+0xdc>
    close(pfds[1]);
    2634:	fcc42503          	lw	a0,-52(s0)
    2638:	00003097          	auipc	ra,0x3
    263c:	1ac080e7          	jalr	428(ra) # 57e4 <close>
    for(;;)
    2640:	a001                	j	2640 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    2642:	85ca                	mv	a1,s2
    2644:	00004517          	auipc	a0,0x4
    2648:	83c50513          	addi	a0,a0,-1988 # 5e80 <malloc+0x202>
    264c:	00003097          	auipc	ra,0x3
    2650:	574080e7          	jalr	1396(ra) # 5bc0 <printf>
     exit(1);
    2654:	4505                	li	a0,1
    2656:	00003097          	auipc	ra,0x3
    265a:	166080e7          	jalr	358(ra) # 57bc <exit>
      printf("%s: preempt write error", s);
    265e:	85ca                	mv	a1,s2
    2660:	00005517          	auipc	a0,0x5
    2664:	83850513          	addi	a0,a0,-1992 # 6e98 <malloc+0x121a>
    2668:	00003097          	auipc	ra,0x3
    266c:	558080e7          	jalr	1368(ra) # 5bc0 <printf>
    2670:	b7d1                	j	2634 <preempt+0xb2>
  close(pfds[1]);
    2672:	fcc42503          	lw	a0,-52(s0)
    2676:	00003097          	auipc	ra,0x3
    267a:	16e080e7          	jalr	366(ra) # 57e4 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    267e:	660d                	lui	a2,0x3
    2680:	00009597          	auipc	a1,0x9
    2684:	26058593          	addi	a1,a1,608 # b8e0 <buf>
    2688:	fc842503          	lw	a0,-56(s0)
    268c:	00003097          	auipc	ra,0x3
    2690:	148080e7          	jalr	328(ra) # 57d4 <read>
    2694:	4785                	li	a5,1
    2696:	02f50363          	beq	a0,a5,26bc <preempt+0x13a>
    printf("%s: preempt read error", s);
    269a:	85ca                	mv	a1,s2
    269c:	00005517          	auipc	a0,0x5
    26a0:	81450513          	addi	a0,a0,-2028 # 6eb0 <malloc+0x1232>
    26a4:	00003097          	auipc	ra,0x3
    26a8:	51c080e7          	jalr	1308(ra) # 5bc0 <printf>
}
    26ac:	70e2                	ld	ra,56(sp)
    26ae:	7442                	ld	s0,48(sp)
    26b0:	74a2                	ld	s1,40(sp)
    26b2:	7902                	ld	s2,32(sp)
    26b4:	69e2                	ld	s3,24(sp)
    26b6:	6a42                	ld	s4,16(sp)
    26b8:	6121                	addi	sp,sp,64
    26ba:	8082                	ret
  close(pfds[0]);
    26bc:	fc842503          	lw	a0,-56(s0)
    26c0:	00003097          	auipc	ra,0x3
    26c4:	124080e7          	jalr	292(ra) # 57e4 <close>
  printf("kill... ");
    26c8:	00005517          	auipc	a0,0x5
    26cc:	80050513          	addi	a0,a0,-2048 # 6ec8 <malloc+0x124a>
    26d0:	00003097          	auipc	ra,0x3
    26d4:	4f0080e7          	jalr	1264(ra) # 5bc0 <printf>
  kill(pid1, SIGKILL);
    26d8:	45a5                	li	a1,9
    26da:	8526                	mv	a0,s1
    26dc:	00003097          	auipc	ra,0x3
    26e0:	110080e7          	jalr	272(ra) # 57ec <kill>
  kill(pid2, SIGKILL);
    26e4:	45a5                	li	a1,9
    26e6:	854e                	mv	a0,s3
    26e8:	00003097          	auipc	ra,0x3
    26ec:	104080e7          	jalr	260(ra) # 57ec <kill>
  kill(pid3, SIGKILL);
    26f0:	45a5                	li	a1,9
    26f2:	8552                	mv	a0,s4
    26f4:	00003097          	auipc	ra,0x3
    26f8:	0f8080e7          	jalr	248(ra) # 57ec <kill>
  printf("wait... ");
    26fc:	00004517          	auipc	a0,0x4
    2700:	7dc50513          	addi	a0,a0,2012 # 6ed8 <malloc+0x125a>
    2704:	00003097          	auipc	ra,0x3
    2708:	4bc080e7          	jalr	1212(ra) # 5bc0 <printf>
  wait(0);
    270c:	4501                	li	a0,0
    270e:	00003097          	auipc	ra,0x3
    2712:	0b6080e7          	jalr	182(ra) # 57c4 <wait>
  wait(0);
    2716:	4501                	li	a0,0
    2718:	00003097          	auipc	ra,0x3
    271c:	0ac080e7          	jalr	172(ra) # 57c4 <wait>
  wait(0);
    2720:	4501                	li	a0,0
    2722:	00003097          	auipc	ra,0x3
    2726:	0a2080e7          	jalr	162(ra) # 57c4 <wait>
    272a:	b749                	j	26ac <preempt+0x12a>

000000000000272c <reparent>:
{
    272c:	7179                	addi	sp,sp,-48
    272e:	f406                	sd	ra,40(sp)
    2730:	f022                	sd	s0,32(sp)
    2732:	ec26                	sd	s1,24(sp)
    2734:	e84a                	sd	s2,16(sp)
    2736:	e44e                	sd	s3,8(sp)
    2738:	e052                	sd	s4,0(sp)
    273a:	1800                	addi	s0,sp,48
    273c:	89aa                	mv	s3,a0
  int master_pid = getpid();
    273e:	00003097          	auipc	ra,0x3
    2742:	0fe080e7          	jalr	254(ra) # 583c <getpid>
    2746:	8a2a                	mv	s4,a0
    2748:	0c800913          	li	s2,200
    int pid = fork();
    274c:	00003097          	auipc	ra,0x3
    2750:	068080e7          	jalr	104(ra) # 57b4 <fork>
    2754:	84aa                	mv	s1,a0
    if(pid < 0){
    2756:	02054263          	bltz	a0,277a <reparent+0x4e>
    if(pid){
    275a:	cd21                	beqz	a0,27b2 <reparent+0x86>
      if(wait(0) != pid){
    275c:	4501                	li	a0,0
    275e:	00003097          	auipc	ra,0x3
    2762:	066080e7          	jalr	102(ra) # 57c4 <wait>
    2766:	02951863          	bne	a0,s1,2796 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    276a:	397d                	addiw	s2,s2,-1
    276c:	fe0910e3          	bnez	s2,274c <reparent+0x20>
  exit(0);
    2770:	4501                	li	a0,0
    2772:	00003097          	auipc	ra,0x3
    2776:	04a080e7          	jalr	74(ra) # 57bc <exit>
      printf("%s: fork failed\n", s);
    277a:	85ce                	mv	a1,s3
    277c:	00003517          	auipc	a0,0x3
    2780:	70450513          	addi	a0,a0,1796 # 5e80 <malloc+0x202>
    2784:	00003097          	auipc	ra,0x3
    2788:	43c080e7          	jalr	1084(ra) # 5bc0 <printf>
      exit(1);
    278c:	4505                	li	a0,1
    278e:	00003097          	auipc	ra,0x3
    2792:	02e080e7          	jalr	46(ra) # 57bc <exit>
        printf("%s: wait wrong pid\n", s);
    2796:	85ce                	mv	a1,s3
    2798:	00003517          	auipc	a0,0x3
    279c:	70050513          	addi	a0,a0,1792 # 5e98 <malloc+0x21a>
    27a0:	00003097          	auipc	ra,0x3
    27a4:	420080e7          	jalr	1056(ra) # 5bc0 <printf>
        exit(1);
    27a8:	4505                	li	a0,1
    27aa:	00003097          	auipc	ra,0x3
    27ae:	012080e7          	jalr	18(ra) # 57bc <exit>
      int pid2 = fork();
    27b2:	00003097          	auipc	ra,0x3
    27b6:	002080e7          	jalr	2(ra) # 57b4 <fork>
      if(pid2 < 0){
    27ba:	00054763          	bltz	a0,27c8 <reparent+0x9c>
      exit(0);
    27be:	4501                	li	a0,0
    27c0:	00003097          	auipc	ra,0x3
    27c4:	ffc080e7          	jalr	-4(ra) # 57bc <exit>
        kill(master_pid, SIGKILL);
    27c8:	45a5                	li	a1,9
    27ca:	8552                	mv	a0,s4
    27cc:	00003097          	auipc	ra,0x3
    27d0:	020080e7          	jalr	32(ra) # 57ec <kill>
        exit(1);
    27d4:	4505                	li	a0,1
    27d6:	00003097          	auipc	ra,0x3
    27da:	fe6080e7          	jalr	-26(ra) # 57bc <exit>

00000000000027de <twochildren>:
{
    27de:	1101                	addi	sp,sp,-32
    27e0:	ec06                	sd	ra,24(sp)
    27e2:	e822                	sd	s0,16(sp)
    27e4:	e426                	sd	s1,8(sp)
    27e6:	e04a                	sd	s2,0(sp)
    27e8:	1000                	addi	s0,sp,32
    27ea:	892a                	mv	s2,a0
    27ec:	3e800493          	li	s1,1000
    int pid1 = fork();
    27f0:	00003097          	auipc	ra,0x3
    27f4:	fc4080e7          	jalr	-60(ra) # 57b4 <fork>
    if(pid1 < 0){
    27f8:	02054c63          	bltz	a0,2830 <twochildren+0x52>
    if(pid1 == 0){
    27fc:	c921                	beqz	a0,284c <twochildren+0x6e>
      int pid2 = fork();
    27fe:	00003097          	auipc	ra,0x3
    2802:	fb6080e7          	jalr	-74(ra) # 57b4 <fork>
      if(pid2 < 0){
    2806:	04054763          	bltz	a0,2854 <twochildren+0x76>
      if(pid2 == 0){
    280a:	c13d                	beqz	a0,2870 <twochildren+0x92>
        wait(0);
    280c:	4501                	li	a0,0
    280e:	00003097          	auipc	ra,0x3
    2812:	fb6080e7          	jalr	-74(ra) # 57c4 <wait>
        wait(0);
    2816:	4501                	li	a0,0
    2818:	00003097          	auipc	ra,0x3
    281c:	fac080e7          	jalr	-84(ra) # 57c4 <wait>
  for(int i = 0; i < 1000; i++){
    2820:	34fd                	addiw	s1,s1,-1
    2822:	f4f9                	bnez	s1,27f0 <twochildren+0x12>
}
    2824:	60e2                	ld	ra,24(sp)
    2826:	6442                	ld	s0,16(sp)
    2828:	64a2                	ld	s1,8(sp)
    282a:	6902                	ld	s2,0(sp)
    282c:	6105                	addi	sp,sp,32
    282e:	8082                	ret
      printf("%s: fork failed\n", s);
    2830:	85ca                	mv	a1,s2
    2832:	00003517          	auipc	a0,0x3
    2836:	64e50513          	addi	a0,a0,1614 # 5e80 <malloc+0x202>
    283a:	00003097          	auipc	ra,0x3
    283e:	386080e7          	jalr	902(ra) # 5bc0 <printf>
      exit(1);
    2842:	4505                	li	a0,1
    2844:	00003097          	auipc	ra,0x3
    2848:	f78080e7          	jalr	-136(ra) # 57bc <exit>
      exit(0);
    284c:	00003097          	auipc	ra,0x3
    2850:	f70080e7          	jalr	-144(ra) # 57bc <exit>
        printf("%s: fork failed\n", s);
    2854:	85ca                	mv	a1,s2
    2856:	00003517          	auipc	a0,0x3
    285a:	62a50513          	addi	a0,a0,1578 # 5e80 <malloc+0x202>
    285e:	00003097          	auipc	ra,0x3
    2862:	362080e7          	jalr	866(ra) # 5bc0 <printf>
        exit(1);
    2866:	4505                	li	a0,1
    2868:	00003097          	auipc	ra,0x3
    286c:	f54080e7          	jalr	-172(ra) # 57bc <exit>
        exit(0);
    2870:	00003097          	auipc	ra,0x3
    2874:	f4c080e7          	jalr	-180(ra) # 57bc <exit>

0000000000002878 <forkfork>:
{
    2878:	7179                	addi	sp,sp,-48
    287a:	f406                	sd	ra,40(sp)
    287c:	f022                	sd	s0,32(sp)
    287e:	ec26                	sd	s1,24(sp)
    2880:	1800                	addi	s0,sp,48
    2882:	84aa                	mv	s1,a0
    int pid = fork();
    2884:	00003097          	auipc	ra,0x3
    2888:	f30080e7          	jalr	-208(ra) # 57b4 <fork>
    if(pid < 0){
    288c:	04054163          	bltz	a0,28ce <forkfork+0x56>
    if(pid == 0){
    2890:	cd29                	beqz	a0,28ea <forkfork+0x72>
    int pid = fork();
    2892:	00003097          	auipc	ra,0x3
    2896:	f22080e7          	jalr	-222(ra) # 57b4 <fork>
    if(pid < 0){
    289a:	02054a63          	bltz	a0,28ce <forkfork+0x56>
    if(pid == 0){
    289e:	c531                	beqz	a0,28ea <forkfork+0x72>
    wait(&xstatus);
    28a0:	fdc40513          	addi	a0,s0,-36
    28a4:	00003097          	auipc	ra,0x3
    28a8:	f20080e7          	jalr	-224(ra) # 57c4 <wait>
    if(xstatus != 0) {
    28ac:	fdc42783          	lw	a5,-36(s0)
    28b0:	ebbd                	bnez	a5,2926 <forkfork+0xae>
    wait(&xstatus);
    28b2:	fdc40513          	addi	a0,s0,-36
    28b6:	00003097          	auipc	ra,0x3
    28ba:	f0e080e7          	jalr	-242(ra) # 57c4 <wait>
    if(xstatus != 0) {
    28be:	fdc42783          	lw	a5,-36(s0)
    28c2:	e3b5                	bnez	a5,2926 <forkfork+0xae>
}
    28c4:	70a2                	ld	ra,40(sp)
    28c6:	7402                	ld	s0,32(sp)
    28c8:	64e2                	ld	s1,24(sp)
    28ca:	6145                	addi	sp,sp,48
    28cc:	8082                	ret
      printf("%s: fork failed", s);
    28ce:	85a6                	mv	a1,s1
    28d0:	00004517          	auipc	a0,0x4
    28d4:	5b850513          	addi	a0,a0,1464 # 6e88 <malloc+0x120a>
    28d8:	00003097          	auipc	ra,0x3
    28dc:	2e8080e7          	jalr	744(ra) # 5bc0 <printf>
      exit(1);
    28e0:	4505                	li	a0,1
    28e2:	00003097          	auipc	ra,0x3
    28e6:	eda080e7          	jalr	-294(ra) # 57bc <exit>
{
    28ea:	0c800493          	li	s1,200
        int pid1 = fork();
    28ee:	00003097          	auipc	ra,0x3
    28f2:	ec6080e7          	jalr	-314(ra) # 57b4 <fork>
        if(pid1 < 0){
    28f6:	00054f63          	bltz	a0,2914 <forkfork+0x9c>
        if(pid1 == 0){
    28fa:	c115                	beqz	a0,291e <forkfork+0xa6>
        wait(0);
    28fc:	4501                	li	a0,0
    28fe:	00003097          	auipc	ra,0x3
    2902:	ec6080e7          	jalr	-314(ra) # 57c4 <wait>
      for(int j = 0; j < 200; j++){
    2906:	34fd                	addiw	s1,s1,-1
    2908:	f0fd                	bnez	s1,28ee <forkfork+0x76>
      exit(0);
    290a:	4501                	li	a0,0
    290c:	00003097          	auipc	ra,0x3
    2910:	eb0080e7          	jalr	-336(ra) # 57bc <exit>
          exit(1);
    2914:	4505                	li	a0,1
    2916:	00003097          	auipc	ra,0x3
    291a:	ea6080e7          	jalr	-346(ra) # 57bc <exit>
          exit(0);
    291e:	00003097          	auipc	ra,0x3
    2922:	e9e080e7          	jalr	-354(ra) # 57bc <exit>
      printf("%s: fork in child failed", s);
    2926:	85a6                	mv	a1,s1
    2928:	00004517          	auipc	a0,0x4
    292c:	5c050513          	addi	a0,a0,1472 # 6ee8 <malloc+0x126a>
    2930:	00003097          	auipc	ra,0x3
    2934:	290080e7          	jalr	656(ra) # 5bc0 <printf>
      exit(1);
    2938:	4505                	li	a0,1
    293a:	00003097          	auipc	ra,0x3
    293e:	e82080e7          	jalr	-382(ra) # 57bc <exit>

0000000000002942 <forkforkfork>:
{
    2942:	1101                	addi	sp,sp,-32
    2944:	ec06                	sd	ra,24(sp)
    2946:	e822                	sd	s0,16(sp)
    2948:	e426                	sd	s1,8(sp)
    294a:	1000                	addi	s0,sp,32
    294c:	84aa                	mv	s1,a0
  unlink("stopforking");
    294e:	00004517          	auipc	a0,0x4
    2952:	5ba50513          	addi	a0,a0,1466 # 6f08 <malloc+0x128a>
    2956:	00003097          	auipc	ra,0x3
    295a:	eb6080e7          	jalr	-330(ra) # 580c <unlink>
  int pid = fork();
    295e:	00003097          	auipc	ra,0x3
    2962:	e56080e7          	jalr	-426(ra) # 57b4 <fork>
  if(pid < 0){
    2966:	04054563          	bltz	a0,29b0 <forkforkfork+0x6e>
  if(pid == 0){
    296a:	c12d                	beqz	a0,29cc <forkforkfork+0x8a>
  sleep(20); // two seconds
    296c:	4551                	li	a0,20
    296e:	00003097          	auipc	ra,0x3
    2972:	ede080e7          	jalr	-290(ra) # 584c <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    2976:	20200593          	li	a1,514
    297a:	00004517          	auipc	a0,0x4
    297e:	58e50513          	addi	a0,a0,1422 # 6f08 <malloc+0x128a>
    2982:	00003097          	auipc	ra,0x3
    2986:	e7a080e7          	jalr	-390(ra) # 57fc <open>
    298a:	00003097          	auipc	ra,0x3
    298e:	e5a080e7          	jalr	-422(ra) # 57e4 <close>
  wait(0);
    2992:	4501                	li	a0,0
    2994:	00003097          	auipc	ra,0x3
    2998:	e30080e7          	jalr	-464(ra) # 57c4 <wait>
  sleep(10); // one second
    299c:	4529                	li	a0,10
    299e:	00003097          	auipc	ra,0x3
    29a2:	eae080e7          	jalr	-338(ra) # 584c <sleep>
}
    29a6:	60e2                	ld	ra,24(sp)
    29a8:	6442                	ld	s0,16(sp)
    29aa:	64a2                	ld	s1,8(sp)
    29ac:	6105                	addi	sp,sp,32
    29ae:	8082                	ret
    printf("%s: fork failed", s);
    29b0:	85a6                	mv	a1,s1
    29b2:	00004517          	auipc	a0,0x4
    29b6:	4d650513          	addi	a0,a0,1238 # 6e88 <malloc+0x120a>
    29ba:	00003097          	auipc	ra,0x3
    29be:	206080e7          	jalr	518(ra) # 5bc0 <printf>
    exit(1);
    29c2:	4505                	li	a0,1
    29c4:	00003097          	auipc	ra,0x3
    29c8:	df8080e7          	jalr	-520(ra) # 57bc <exit>
      int fd = open("stopforking", 0);
    29cc:	00004497          	auipc	s1,0x4
    29d0:	53c48493          	addi	s1,s1,1340 # 6f08 <malloc+0x128a>
    29d4:	4581                	li	a1,0
    29d6:	8526                	mv	a0,s1
    29d8:	00003097          	auipc	ra,0x3
    29dc:	e24080e7          	jalr	-476(ra) # 57fc <open>
      if(fd >= 0){
    29e0:	02055463          	bgez	a0,2a08 <forkforkfork+0xc6>
      if(fork() < 0){
    29e4:	00003097          	auipc	ra,0x3
    29e8:	dd0080e7          	jalr	-560(ra) # 57b4 <fork>
    29ec:	fe0554e3          	bgez	a0,29d4 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    29f0:	20200593          	li	a1,514
    29f4:	8526                	mv	a0,s1
    29f6:	00003097          	auipc	ra,0x3
    29fa:	e06080e7          	jalr	-506(ra) # 57fc <open>
    29fe:	00003097          	auipc	ra,0x3
    2a02:	de6080e7          	jalr	-538(ra) # 57e4 <close>
    2a06:	b7f9                	j	29d4 <forkforkfork+0x92>
        exit(0);
    2a08:	4501                	li	a0,0
    2a0a:	00003097          	auipc	ra,0x3
    2a0e:	db2080e7          	jalr	-590(ra) # 57bc <exit>

0000000000002a12 <reparent2>:
{
    2a12:	1101                	addi	sp,sp,-32
    2a14:	ec06                	sd	ra,24(sp)
    2a16:	e822                	sd	s0,16(sp)
    2a18:	e426                	sd	s1,8(sp)
    2a1a:	1000                	addi	s0,sp,32
    2a1c:	32000493          	li	s1,800
    int pid1 = fork();
    2a20:	00003097          	auipc	ra,0x3
    2a24:	d94080e7          	jalr	-620(ra) # 57b4 <fork>
    if(pid1 < 0){
    2a28:	00054f63          	bltz	a0,2a46 <reparent2+0x34>
    if(pid1 == 0){
    2a2c:	c915                	beqz	a0,2a60 <reparent2+0x4e>
    wait(0);
    2a2e:	4501                	li	a0,0
    2a30:	00003097          	auipc	ra,0x3
    2a34:	d94080e7          	jalr	-620(ra) # 57c4 <wait>
  for(int i = 0; i < 800; i++){
    2a38:	34fd                	addiw	s1,s1,-1
    2a3a:	f0fd                	bnez	s1,2a20 <reparent2+0xe>
  exit(0);
    2a3c:	4501                	li	a0,0
    2a3e:	00003097          	auipc	ra,0x3
    2a42:	d7e080e7          	jalr	-642(ra) # 57bc <exit>
      printf("fork failed\n");
    2a46:	00005517          	auipc	a0,0x5
    2a4a:	26250513          	addi	a0,a0,610 # 7ca8 <malloc+0x202a>
    2a4e:	00003097          	auipc	ra,0x3
    2a52:	172080e7          	jalr	370(ra) # 5bc0 <printf>
      exit(1);
    2a56:	4505                	li	a0,1
    2a58:	00003097          	auipc	ra,0x3
    2a5c:	d64080e7          	jalr	-668(ra) # 57bc <exit>
      fork();
    2a60:	00003097          	auipc	ra,0x3
    2a64:	d54080e7          	jalr	-684(ra) # 57b4 <fork>
      fork();
    2a68:	00003097          	auipc	ra,0x3
    2a6c:	d4c080e7          	jalr	-692(ra) # 57b4 <fork>
      exit(0);
    2a70:	4501                	li	a0,0
    2a72:	00003097          	auipc	ra,0x3
    2a76:	d4a080e7          	jalr	-694(ra) # 57bc <exit>

0000000000002a7a <sharedfd>:
{
    2a7a:	7159                	addi	sp,sp,-112
    2a7c:	f486                	sd	ra,104(sp)
    2a7e:	f0a2                	sd	s0,96(sp)
    2a80:	eca6                	sd	s1,88(sp)
    2a82:	e8ca                	sd	s2,80(sp)
    2a84:	e4ce                	sd	s3,72(sp)
    2a86:	e0d2                	sd	s4,64(sp)
    2a88:	fc56                	sd	s5,56(sp)
    2a8a:	f85a                	sd	s6,48(sp)
    2a8c:	f45e                	sd	s7,40(sp)
    2a8e:	1880                	addi	s0,sp,112
    2a90:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    2a92:	00004517          	auipc	a0,0x4
    2a96:	48650513          	addi	a0,a0,1158 # 6f18 <malloc+0x129a>
    2a9a:	00003097          	auipc	ra,0x3
    2a9e:	d72080e7          	jalr	-654(ra) # 580c <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    2aa2:	20200593          	li	a1,514
    2aa6:	00004517          	auipc	a0,0x4
    2aaa:	47250513          	addi	a0,a0,1138 # 6f18 <malloc+0x129a>
    2aae:	00003097          	auipc	ra,0x3
    2ab2:	d4e080e7          	jalr	-690(ra) # 57fc <open>
  if(fd < 0){
    2ab6:	04054a63          	bltz	a0,2b0a <sharedfd+0x90>
    2aba:	892a                	mv	s2,a0
  pid = fork();
    2abc:	00003097          	auipc	ra,0x3
    2ac0:	cf8080e7          	jalr	-776(ra) # 57b4 <fork>
    2ac4:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    2ac6:	06300593          	li	a1,99
    2aca:	c119                	beqz	a0,2ad0 <sharedfd+0x56>
    2acc:	07000593          	li	a1,112
    2ad0:	4629                	li	a2,10
    2ad2:	fa040513          	addi	a0,s0,-96
    2ad6:	00003097          	auipc	ra,0x3
    2ada:	aea080e7          	jalr	-1302(ra) # 55c0 <memset>
    2ade:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    2ae2:	4629                	li	a2,10
    2ae4:	fa040593          	addi	a1,s0,-96
    2ae8:	854a                	mv	a0,s2
    2aea:	00003097          	auipc	ra,0x3
    2aee:	cf2080e7          	jalr	-782(ra) # 57dc <write>
    2af2:	47a9                	li	a5,10
    2af4:	02f51963          	bne	a0,a5,2b26 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    2af8:	34fd                	addiw	s1,s1,-1
    2afa:	f4e5                	bnez	s1,2ae2 <sharedfd+0x68>
  if(pid == 0) {
    2afc:	04099363          	bnez	s3,2b42 <sharedfd+0xc8>
    exit(0);
    2b00:	4501                	li	a0,0
    2b02:	00003097          	auipc	ra,0x3
    2b06:	cba080e7          	jalr	-838(ra) # 57bc <exit>
    printf("%s: cannot open sharedfd for writing", s);
    2b0a:	85d2                	mv	a1,s4
    2b0c:	00004517          	auipc	a0,0x4
    2b10:	41c50513          	addi	a0,a0,1052 # 6f28 <malloc+0x12aa>
    2b14:	00003097          	auipc	ra,0x3
    2b18:	0ac080e7          	jalr	172(ra) # 5bc0 <printf>
    exit(1);
    2b1c:	4505                	li	a0,1
    2b1e:	00003097          	auipc	ra,0x3
    2b22:	c9e080e7          	jalr	-866(ra) # 57bc <exit>
      printf("%s: write sharedfd failed\n", s);
    2b26:	85d2                	mv	a1,s4
    2b28:	00004517          	auipc	a0,0x4
    2b2c:	42850513          	addi	a0,a0,1064 # 6f50 <malloc+0x12d2>
    2b30:	00003097          	auipc	ra,0x3
    2b34:	090080e7          	jalr	144(ra) # 5bc0 <printf>
      exit(1);
    2b38:	4505                	li	a0,1
    2b3a:	00003097          	auipc	ra,0x3
    2b3e:	c82080e7          	jalr	-894(ra) # 57bc <exit>
    wait(&xstatus);
    2b42:	f9c40513          	addi	a0,s0,-100
    2b46:	00003097          	auipc	ra,0x3
    2b4a:	c7e080e7          	jalr	-898(ra) # 57c4 <wait>
    if(xstatus != 0)
    2b4e:	f9c42983          	lw	s3,-100(s0)
    2b52:	00098763          	beqz	s3,2b60 <sharedfd+0xe6>
      exit(xstatus);
    2b56:	854e                	mv	a0,s3
    2b58:	00003097          	auipc	ra,0x3
    2b5c:	c64080e7          	jalr	-924(ra) # 57bc <exit>
  close(fd);
    2b60:	854a                	mv	a0,s2
    2b62:	00003097          	auipc	ra,0x3
    2b66:	c82080e7          	jalr	-894(ra) # 57e4 <close>
  fd = open("sharedfd", 0);
    2b6a:	4581                	li	a1,0
    2b6c:	00004517          	auipc	a0,0x4
    2b70:	3ac50513          	addi	a0,a0,940 # 6f18 <malloc+0x129a>
    2b74:	00003097          	auipc	ra,0x3
    2b78:	c88080e7          	jalr	-888(ra) # 57fc <open>
    2b7c:	8baa                	mv	s7,a0
  nc = np = 0;
    2b7e:	8ace                	mv	s5,s3
  if(fd < 0){
    2b80:	02054563          	bltz	a0,2baa <sharedfd+0x130>
    2b84:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    2b88:	06300493          	li	s1,99
      if(buf[i] == 'p')
    2b8c:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    2b90:	4629                	li	a2,10
    2b92:	fa040593          	addi	a1,s0,-96
    2b96:	855e                	mv	a0,s7
    2b98:	00003097          	auipc	ra,0x3
    2b9c:	c3c080e7          	jalr	-964(ra) # 57d4 <read>
    2ba0:	02a05f63          	blez	a0,2bde <sharedfd+0x164>
    2ba4:	fa040793          	addi	a5,s0,-96
    2ba8:	a01d                	j	2bce <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    2baa:	85d2                	mv	a1,s4
    2bac:	00004517          	auipc	a0,0x4
    2bb0:	3c450513          	addi	a0,a0,964 # 6f70 <malloc+0x12f2>
    2bb4:	00003097          	auipc	ra,0x3
    2bb8:	00c080e7          	jalr	12(ra) # 5bc0 <printf>
    exit(1);
    2bbc:	4505                	li	a0,1
    2bbe:	00003097          	auipc	ra,0x3
    2bc2:	bfe080e7          	jalr	-1026(ra) # 57bc <exit>
        nc++;
    2bc6:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    2bc8:	0785                	addi	a5,a5,1
    2bca:	fd2783e3          	beq	a5,s2,2b90 <sharedfd+0x116>
      if(buf[i] == 'c')
    2bce:	0007c703          	lbu	a4,0(a5)
    2bd2:	fe970ae3          	beq	a4,s1,2bc6 <sharedfd+0x14c>
      if(buf[i] == 'p')
    2bd6:	ff6719e3          	bne	a4,s6,2bc8 <sharedfd+0x14e>
        np++;
    2bda:	2a85                	addiw	s5,s5,1
    2bdc:	b7f5                	j	2bc8 <sharedfd+0x14e>
  close(fd);
    2bde:	855e                	mv	a0,s7
    2be0:	00003097          	auipc	ra,0x3
    2be4:	c04080e7          	jalr	-1020(ra) # 57e4 <close>
  unlink("sharedfd");
    2be8:	00004517          	auipc	a0,0x4
    2bec:	33050513          	addi	a0,a0,816 # 6f18 <malloc+0x129a>
    2bf0:	00003097          	auipc	ra,0x3
    2bf4:	c1c080e7          	jalr	-996(ra) # 580c <unlink>
  if(nc == N*SZ && np == N*SZ){
    2bf8:	6789                	lui	a5,0x2
    2bfa:	71078793          	addi	a5,a5,1808 # 2710 <preempt+0x18e>
    2bfe:	00f99763          	bne	s3,a5,2c0c <sharedfd+0x192>
    2c02:	6789                	lui	a5,0x2
    2c04:	71078793          	addi	a5,a5,1808 # 2710 <preempt+0x18e>
    2c08:	02fa8063          	beq	s5,a5,2c28 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    2c0c:	85d2                	mv	a1,s4
    2c0e:	00004517          	auipc	a0,0x4
    2c12:	38a50513          	addi	a0,a0,906 # 6f98 <malloc+0x131a>
    2c16:	00003097          	auipc	ra,0x3
    2c1a:	faa080e7          	jalr	-86(ra) # 5bc0 <printf>
    exit(1);
    2c1e:	4505                	li	a0,1
    2c20:	00003097          	auipc	ra,0x3
    2c24:	b9c080e7          	jalr	-1124(ra) # 57bc <exit>
    exit(0);
    2c28:	4501                	li	a0,0
    2c2a:	00003097          	auipc	ra,0x3
    2c2e:	b92080e7          	jalr	-1134(ra) # 57bc <exit>

0000000000002c32 <fourfiles>:
{
    2c32:	7171                	addi	sp,sp,-176
    2c34:	f506                	sd	ra,168(sp)
    2c36:	f122                	sd	s0,160(sp)
    2c38:	ed26                	sd	s1,152(sp)
    2c3a:	e94a                	sd	s2,144(sp)
    2c3c:	e54e                	sd	s3,136(sp)
    2c3e:	e152                	sd	s4,128(sp)
    2c40:	fcd6                	sd	s5,120(sp)
    2c42:	f8da                	sd	s6,112(sp)
    2c44:	f4de                	sd	s7,104(sp)
    2c46:	f0e2                	sd	s8,96(sp)
    2c48:	ece6                	sd	s9,88(sp)
    2c4a:	e8ea                	sd	s10,80(sp)
    2c4c:	e4ee                	sd	s11,72(sp)
    2c4e:	1900                	addi	s0,sp,176
    2c50:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    2c54:	00003797          	auipc	a5,0x3
    2c58:	11478793          	addi	a5,a5,276 # 5d68 <malloc+0xea>
    2c5c:	f6f43823          	sd	a5,-144(s0)
    2c60:	00003797          	auipc	a5,0x3
    2c64:	11078793          	addi	a5,a5,272 # 5d70 <malloc+0xf2>
    2c68:	f6f43c23          	sd	a5,-136(s0)
    2c6c:	00003797          	auipc	a5,0x3
    2c70:	10c78793          	addi	a5,a5,268 # 5d78 <malloc+0xfa>
    2c74:	f8f43023          	sd	a5,-128(s0)
    2c78:	00003797          	auipc	a5,0x3
    2c7c:	10878793          	addi	a5,a5,264 # 5d80 <malloc+0x102>
    2c80:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    2c84:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    2c88:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    2c8a:	4481                	li	s1,0
    2c8c:	4a11                	li	s4,4
    fname = names[pi];
    2c8e:	00093983          	ld	s3,0(s2)
    unlink(fname);
    2c92:	854e                	mv	a0,s3
    2c94:	00003097          	auipc	ra,0x3
    2c98:	b78080e7          	jalr	-1160(ra) # 580c <unlink>
    pid = fork();
    2c9c:	00003097          	auipc	ra,0x3
    2ca0:	b18080e7          	jalr	-1256(ra) # 57b4 <fork>
    if(pid < 0){
    2ca4:	04054463          	bltz	a0,2cec <fourfiles+0xba>
    if(pid == 0){
    2ca8:	c12d                	beqz	a0,2d0a <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    2caa:	2485                	addiw	s1,s1,1
    2cac:	0921                	addi	s2,s2,8
    2cae:	ff4490e3          	bne	s1,s4,2c8e <fourfiles+0x5c>
    2cb2:	4491                	li	s1,4
    wait(&xstatus);
    2cb4:	f6c40513          	addi	a0,s0,-148
    2cb8:	00003097          	auipc	ra,0x3
    2cbc:	b0c080e7          	jalr	-1268(ra) # 57c4 <wait>
    if(xstatus != 0)
    2cc0:	f6c42b03          	lw	s6,-148(s0)
    2cc4:	0c0b1e63          	bnez	s6,2da0 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    2cc8:	34fd                	addiw	s1,s1,-1
    2cca:	f4ed                	bnez	s1,2cb4 <fourfiles+0x82>
    2ccc:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2cd0:	00009a17          	auipc	s4,0x9
    2cd4:	c10a0a13          	addi	s4,s4,-1008 # b8e0 <buf>
    2cd8:	00009a97          	auipc	s5,0x9
    2cdc:	c09a8a93          	addi	s5,s5,-1015 # b8e1 <buf+0x1>
    if(total != N*SZ){
    2ce0:	6d85                	lui	s11,0x1
    2ce2:	770d8d93          	addi	s11,s11,1904 # 1770 <copyin+0xe0>
  for(i = 0; i < NCHILD; i++){
    2ce6:	03400d13          	li	s10,52
    2cea:	aa1d                	j	2e20 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    2cec:	f5843583          	ld	a1,-168(s0)
    2cf0:	00005517          	auipc	a0,0x5
    2cf4:	fb850513          	addi	a0,a0,-72 # 7ca8 <malloc+0x202a>
    2cf8:	00003097          	auipc	ra,0x3
    2cfc:	ec8080e7          	jalr	-312(ra) # 5bc0 <printf>
      exit(1);
    2d00:	4505                	li	a0,1
    2d02:	00003097          	auipc	ra,0x3
    2d06:	aba080e7          	jalr	-1350(ra) # 57bc <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    2d0a:	20200593          	li	a1,514
    2d0e:	854e                	mv	a0,s3
    2d10:	00003097          	auipc	ra,0x3
    2d14:	aec080e7          	jalr	-1300(ra) # 57fc <open>
    2d18:	892a                	mv	s2,a0
      if(fd < 0){
    2d1a:	04054763          	bltz	a0,2d68 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    2d1e:	1f400613          	li	a2,500
    2d22:	0304859b          	addiw	a1,s1,48
    2d26:	00009517          	auipc	a0,0x9
    2d2a:	bba50513          	addi	a0,a0,-1094 # b8e0 <buf>
    2d2e:	00003097          	auipc	ra,0x3
    2d32:	892080e7          	jalr	-1902(ra) # 55c0 <memset>
    2d36:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    2d38:	00009997          	auipc	s3,0x9
    2d3c:	ba898993          	addi	s3,s3,-1112 # b8e0 <buf>
    2d40:	1f400613          	li	a2,500
    2d44:	85ce                	mv	a1,s3
    2d46:	854a                	mv	a0,s2
    2d48:	00003097          	auipc	ra,0x3
    2d4c:	a94080e7          	jalr	-1388(ra) # 57dc <write>
    2d50:	85aa                	mv	a1,a0
    2d52:	1f400793          	li	a5,500
    2d56:	02f51863          	bne	a0,a5,2d86 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    2d5a:	34fd                	addiw	s1,s1,-1
    2d5c:	f0f5                	bnez	s1,2d40 <fourfiles+0x10e>
      exit(0);
    2d5e:	4501                	li	a0,0
    2d60:	00003097          	auipc	ra,0x3
    2d64:	a5c080e7          	jalr	-1444(ra) # 57bc <exit>
        printf("create failed\n", s);
    2d68:	f5843583          	ld	a1,-168(s0)
    2d6c:	00004517          	auipc	a0,0x4
    2d70:	24450513          	addi	a0,a0,580 # 6fb0 <malloc+0x1332>
    2d74:	00003097          	auipc	ra,0x3
    2d78:	e4c080e7          	jalr	-436(ra) # 5bc0 <printf>
        exit(1);
    2d7c:	4505                	li	a0,1
    2d7e:	00003097          	auipc	ra,0x3
    2d82:	a3e080e7          	jalr	-1474(ra) # 57bc <exit>
          printf("write failed %d\n", n);
    2d86:	00004517          	auipc	a0,0x4
    2d8a:	23a50513          	addi	a0,a0,570 # 6fc0 <malloc+0x1342>
    2d8e:	00003097          	auipc	ra,0x3
    2d92:	e32080e7          	jalr	-462(ra) # 5bc0 <printf>
          exit(1);
    2d96:	4505                	li	a0,1
    2d98:	00003097          	auipc	ra,0x3
    2d9c:	a24080e7          	jalr	-1500(ra) # 57bc <exit>
      exit(xstatus);
    2da0:	855a                	mv	a0,s6
    2da2:	00003097          	auipc	ra,0x3
    2da6:	a1a080e7          	jalr	-1510(ra) # 57bc <exit>
          printf("wrong char\n", s);
    2daa:	f5843583          	ld	a1,-168(s0)
    2dae:	00004517          	auipc	a0,0x4
    2db2:	22a50513          	addi	a0,a0,554 # 6fd8 <malloc+0x135a>
    2db6:	00003097          	auipc	ra,0x3
    2dba:	e0a080e7          	jalr	-502(ra) # 5bc0 <printf>
          exit(1);
    2dbe:	4505                	li	a0,1
    2dc0:	00003097          	auipc	ra,0x3
    2dc4:	9fc080e7          	jalr	-1540(ra) # 57bc <exit>
      total += n;
    2dc8:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2dcc:	660d                	lui	a2,0x3
    2dce:	85d2                	mv	a1,s4
    2dd0:	854e                	mv	a0,s3
    2dd2:	00003097          	auipc	ra,0x3
    2dd6:	a02080e7          	jalr	-1534(ra) # 57d4 <read>
    2dda:	02a05363          	blez	a0,2e00 <fourfiles+0x1ce>
    2dde:	00009797          	auipc	a5,0x9
    2de2:	b0278793          	addi	a5,a5,-1278 # b8e0 <buf>
    2de6:	fff5069b          	addiw	a3,a0,-1
    2dea:	1682                	slli	a3,a3,0x20
    2dec:	9281                	srli	a3,a3,0x20
    2dee:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    2df0:	0007c703          	lbu	a4,0(a5)
    2df4:	fa971be3          	bne	a4,s1,2daa <fourfiles+0x178>
      for(j = 0; j < n; j++){
    2df8:	0785                	addi	a5,a5,1
    2dfa:	fed79be3          	bne	a5,a3,2df0 <fourfiles+0x1be>
    2dfe:	b7e9                	j	2dc8 <fourfiles+0x196>
    close(fd);
    2e00:	854e                	mv	a0,s3
    2e02:	00003097          	auipc	ra,0x3
    2e06:	9e2080e7          	jalr	-1566(ra) # 57e4 <close>
    if(total != N*SZ){
    2e0a:	03b91863          	bne	s2,s11,2e3a <fourfiles+0x208>
    unlink(fname);
    2e0e:	8566                	mv	a0,s9
    2e10:	00003097          	auipc	ra,0x3
    2e14:	9fc080e7          	jalr	-1540(ra) # 580c <unlink>
  for(i = 0; i < NCHILD; i++){
    2e18:	0c21                	addi	s8,s8,8
    2e1a:	2b85                	addiw	s7,s7,1
    2e1c:	03ab8d63          	beq	s7,s10,2e56 <fourfiles+0x224>
    fname = names[i];
    2e20:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    2e24:	4581                	li	a1,0
    2e26:	8566                	mv	a0,s9
    2e28:	00003097          	auipc	ra,0x3
    2e2c:	9d4080e7          	jalr	-1580(ra) # 57fc <open>
    2e30:	89aa                	mv	s3,a0
    total = 0;
    2e32:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    2e34:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2e38:	bf51                	j	2dcc <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    2e3a:	85ca                	mv	a1,s2
    2e3c:	00004517          	auipc	a0,0x4
    2e40:	1ac50513          	addi	a0,a0,428 # 6fe8 <malloc+0x136a>
    2e44:	00003097          	auipc	ra,0x3
    2e48:	d7c080e7          	jalr	-644(ra) # 5bc0 <printf>
      exit(1);
    2e4c:	4505                	li	a0,1
    2e4e:	00003097          	auipc	ra,0x3
    2e52:	96e080e7          	jalr	-1682(ra) # 57bc <exit>
}
    2e56:	70aa                	ld	ra,168(sp)
    2e58:	740a                	ld	s0,160(sp)
    2e5a:	64ea                	ld	s1,152(sp)
    2e5c:	694a                	ld	s2,144(sp)
    2e5e:	69aa                	ld	s3,136(sp)
    2e60:	6a0a                	ld	s4,128(sp)
    2e62:	7ae6                	ld	s5,120(sp)
    2e64:	7b46                	ld	s6,112(sp)
    2e66:	7ba6                	ld	s7,104(sp)
    2e68:	7c06                	ld	s8,96(sp)
    2e6a:	6ce6                	ld	s9,88(sp)
    2e6c:	6d46                	ld	s10,80(sp)
    2e6e:	6da6                	ld	s11,72(sp)
    2e70:	614d                	addi	sp,sp,176
    2e72:	8082                	ret

0000000000002e74 <createdelete>:
{
    2e74:	7175                	addi	sp,sp,-144
    2e76:	e506                	sd	ra,136(sp)
    2e78:	e122                	sd	s0,128(sp)
    2e7a:	fca6                	sd	s1,120(sp)
    2e7c:	f8ca                	sd	s2,112(sp)
    2e7e:	f4ce                	sd	s3,104(sp)
    2e80:	f0d2                	sd	s4,96(sp)
    2e82:	ecd6                	sd	s5,88(sp)
    2e84:	e8da                	sd	s6,80(sp)
    2e86:	e4de                	sd	s7,72(sp)
    2e88:	e0e2                	sd	s8,64(sp)
    2e8a:	fc66                	sd	s9,56(sp)
    2e8c:	0900                	addi	s0,sp,144
    2e8e:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    2e90:	4901                	li	s2,0
    2e92:	4991                	li	s3,4
    pid = fork();
    2e94:	00003097          	auipc	ra,0x3
    2e98:	920080e7          	jalr	-1760(ra) # 57b4 <fork>
    2e9c:	84aa                	mv	s1,a0
    if(pid < 0){
    2e9e:	02054f63          	bltz	a0,2edc <createdelete+0x68>
    if(pid == 0){
    2ea2:	c939                	beqz	a0,2ef8 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    2ea4:	2905                	addiw	s2,s2,1
    2ea6:	ff3917e3          	bne	s2,s3,2e94 <createdelete+0x20>
    2eaa:	4491                	li	s1,4
    wait(&xstatus);
    2eac:	f7c40513          	addi	a0,s0,-132
    2eb0:	00003097          	auipc	ra,0x3
    2eb4:	914080e7          	jalr	-1772(ra) # 57c4 <wait>
    if(xstatus != 0)
    2eb8:	f7c42903          	lw	s2,-132(s0)
    2ebc:	0e091263          	bnez	s2,2fa0 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    2ec0:	34fd                	addiw	s1,s1,-1
    2ec2:	f4ed                	bnez	s1,2eac <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    2ec4:	f8040123          	sb	zero,-126(s0)
    2ec8:	03000993          	li	s3,48
    2ecc:	5a7d                	li	s4,-1
    2ece:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    2ed2:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    2ed4:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    2ed6:	07400a93          	li	s5,116
    2eda:	a29d                	j	3040 <createdelete+0x1cc>
      printf("fork failed\n", s);
    2edc:	85e6                	mv	a1,s9
    2ede:	00005517          	auipc	a0,0x5
    2ee2:	dca50513          	addi	a0,a0,-566 # 7ca8 <malloc+0x202a>
    2ee6:	00003097          	auipc	ra,0x3
    2eea:	cda080e7          	jalr	-806(ra) # 5bc0 <printf>
      exit(1);
    2eee:	4505                	li	a0,1
    2ef0:	00003097          	auipc	ra,0x3
    2ef4:	8cc080e7          	jalr	-1844(ra) # 57bc <exit>
      name[0] = 'p' + pi;
    2ef8:	0709091b          	addiw	s2,s2,112
    2efc:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    2f00:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    2f04:	4951                	li	s2,20
    2f06:	a015                	j	2f2a <createdelete+0xb6>
          printf("%s: create failed\n", s);
    2f08:	85e6                	mv	a1,s9
    2f0a:	00004517          	auipc	a0,0x4
    2f0e:	f0e50513          	addi	a0,a0,-242 # 6e18 <malloc+0x119a>
    2f12:	00003097          	auipc	ra,0x3
    2f16:	cae080e7          	jalr	-850(ra) # 5bc0 <printf>
          exit(1);
    2f1a:	4505                	li	a0,1
    2f1c:	00003097          	auipc	ra,0x3
    2f20:	8a0080e7          	jalr	-1888(ra) # 57bc <exit>
      for(i = 0; i < N; i++){
    2f24:	2485                	addiw	s1,s1,1
    2f26:	07248863          	beq	s1,s2,2f96 <createdelete+0x122>
        name[1] = '0' + i;
    2f2a:	0304879b          	addiw	a5,s1,48
    2f2e:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    2f32:	20200593          	li	a1,514
    2f36:	f8040513          	addi	a0,s0,-128
    2f3a:	00003097          	auipc	ra,0x3
    2f3e:	8c2080e7          	jalr	-1854(ra) # 57fc <open>
        if(fd < 0){
    2f42:	fc0543e3          	bltz	a0,2f08 <createdelete+0x94>
        close(fd);
    2f46:	00003097          	auipc	ra,0x3
    2f4a:	89e080e7          	jalr	-1890(ra) # 57e4 <close>
        if(i > 0 && (i % 2 ) == 0){
    2f4e:	fc905be3          	blez	s1,2f24 <createdelete+0xb0>
    2f52:	0014f793          	andi	a5,s1,1
    2f56:	f7f9                	bnez	a5,2f24 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    2f58:	01f4d79b          	srliw	a5,s1,0x1f
    2f5c:	9fa5                	addw	a5,a5,s1
    2f5e:	4017d79b          	sraiw	a5,a5,0x1
    2f62:	0307879b          	addiw	a5,a5,48
    2f66:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    2f6a:	f8040513          	addi	a0,s0,-128
    2f6e:	00003097          	auipc	ra,0x3
    2f72:	89e080e7          	jalr	-1890(ra) # 580c <unlink>
    2f76:	fa0557e3          	bgez	a0,2f24 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    2f7a:	85e6                	mv	a1,s9
    2f7c:	00003517          	auipc	a0,0x3
    2f80:	32c50513          	addi	a0,a0,812 # 62a8 <malloc+0x62a>
    2f84:	00003097          	auipc	ra,0x3
    2f88:	c3c080e7          	jalr	-964(ra) # 5bc0 <printf>
            exit(1);
    2f8c:	4505                	li	a0,1
    2f8e:	00003097          	auipc	ra,0x3
    2f92:	82e080e7          	jalr	-2002(ra) # 57bc <exit>
      exit(0);
    2f96:	4501                	li	a0,0
    2f98:	00003097          	auipc	ra,0x3
    2f9c:	824080e7          	jalr	-2012(ra) # 57bc <exit>
      exit(1);
    2fa0:	4505                	li	a0,1
    2fa2:	00003097          	auipc	ra,0x3
    2fa6:	81a080e7          	jalr	-2022(ra) # 57bc <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    2faa:	f8040613          	addi	a2,s0,-128
    2fae:	85e6                	mv	a1,s9
    2fb0:	00004517          	auipc	a0,0x4
    2fb4:	05050513          	addi	a0,a0,80 # 7000 <malloc+0x1382>
    2fb8:	00003097          	auipc	ra,0x3
    2fbc:	c08080e7          	jalr	-1016(ra) # 5bc0 <printf>
        exit(1);
    2fc0:	4505                	li	a0,1
    2fc2:	00002097          	auipc	ra,0x2
    2fc6:	7fa080e7          	jalr	2042(ra) # 57bc <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    2fca:	054b7163          	bgeu	s6,s4,300c <createdelete+0x198>
      if(fd >= 0)
    2fce:	02055a63          	bgez	a0,3002 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    2fd2:	2485                	addiw	s1,s1,1
    2fd4:	0ff4f493          	andi	s1,s1,255
    2fd8:	05548c63          	beq	s1,s5,3030 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    2fdc:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    2fe0:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    2fe4:	4581                	li	a1,0
    2fe6:	f8040513          	addi	a0,s0,-128
    2fea:	00003097          	auipc	ra,0x3
    2fee:	812080e7          	jalr	-2030(ra) # 57fc <open>
      if((i == 0 || i >= N/2) && fd < 0){
    2ff2:	00090463          	beqz	s2,2ffa <createdelete+0x186>
    2ff6:	fd2bdae3          	bge	s7,s2,2fca <createdelete+0x156>
    2ffa:	fa0548e3          	bltz	a0,2faa <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    2ffe:	014b7963          	bgeu	s6,s4,3010 <createdelete+0x19c>
        close(fd);
    3002:	00002097          	auipc	ra,0x2
    3006:	7e2080e7          	jalr	2018(ra) # 57e4 <close>
    300a:	b7e1                	j	2fd2 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    300c:	fc0543e3          	bltz	a0,2fd2 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    3010:	f8040613          	addi	a2,s0,-128
    3014:	85e6                	mv	a1,s9
    3016:	00004517          	auipc	a0,0x4
    301a:	01250513          	addi	a0,a0,18 # 7028 <malloc+0x13aa>
    301e:	00003097          	auipc	ra,0x3
    3022:	ba2080e7          	jalr	-1118(ra) # 5bc0 <printf>
        exit(1);
    3026:	4505                	li	a0,1
    3028:	00002097          	auipc	ra,0x2
    302c:	794080e7          	jalr	1940(ra) # 57bc <exit>
  for(i = 0; i < N; i++){
    3030:	2905                	addiw	s2,s2,1
    3032:	2a05                	addiw	s4,s4,1
    3034:	2985                	addiw	s3,s3,1
    3036:	0ff9f993          	andi	s3,s3,255
    303a:	47d1                	li	a5,20
    303c:	02f90a63          	beq	s2,a5,3070 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    3040:	84e2                	mv	s1,s8
    3042:	bf69                	j	2fdc <createdelete+0x168>
  for(i = 0; i < N; i++){
    3044:	2905                	addiw	s2,s2,1
    3046:	0ff97913          	andi	s2,s2,255
    304a:	2985                	addiw	s3,s3,1
    304c:	0ff9f993          	andi	s3,s3,255
    3050:	03490863          	beq	s2,s4,3080 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    3054:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    3056:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    305a:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    305e:	f8040513          	addi	a0,s0,-128
    3062:	00002097          	auipc	ra,0x2
    3066:	7aa080e7          	jalr	1962(ra) # 580c <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    306a:	34fd                	addiw	s1,s1,-1
    306c:	f4ed                	bnez	s1,3056 <createdelete+0x1e2>
    306e:	bfd9                	j	3044 <createdelete+0x1d0>
    3070:	03000993          	li	s3,48
    3074:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    3078:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    307a:	08400a13          	li	s4,132
    307e:	bfd9                	j	3054 <createdelete+0x1e0>
}
    3080:	60aa                	ld	ra,136(sp)
    3082:	640a                	ld	s0,128(sp)
    3084:	74e6                	ld	s1,120(sp)
    3086:	7946                	ld	s2,112(sp)
    3088:	79a6                	ld	s3,104(sp)
    308a:	7a06                	ld	s4,96(sp)
    308c:	6ae6                	ld	s5,88(sp)
    308e:	6b46                	ld	s6,80(sp)
    3090:	6ba6                	ld	s7,72(sp)
    3092:	6c06                	ld	s8,64(sp)
    3094:	7ce2                	ld	s9,56(sp)
    3096:	6149                	addi	sp,sp,144
    3098:	8082                	ret

000000000000309a <unlinkread>:
{
    309a:	7179                	addi	sp,sp,-48
    309c:	f406                	sd	ra,40(sp)
    309e:	f022                	sd	s0,32(sp)
    30a0:	ec26                	sd	s1,24(sp)
    30a2:	e84a                	sd	s2,16(sp)
    30a4:	e44e                	sd	s3,8(sp)
    30a6:	1800                	addi	s0,sp,48
    30a8:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
    30aa:	20200593          	li	a1,514
    30ae:	00004517          	auipc	a0,0x4
    30b2:	fa250513          	addi	a0,a0,-94 # 7050 <malloc+0x13d2>
    30b6:	00002097          	auipc	ra,0x2
    30ba:	746080e7          	jalr	1862(ra) # 57fc <open>
  if(fd < 0){
    30be:	0e054563          	bltz	a0,31a8 <unlinkread+0x10e>
    30c2:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
    30c4:	4615                	li	a2,5
    30c6:	00004597          	auipc	a1,0x4
    30ca:	fba58593          	addi	a1,a1,-70 # 7080 <malloc+0x1402>
    30ce:	00002097          	auipc	ra,0x2
    30d2:	70e080e7          	jalr	1806(ra) # 57dc <write>
  close(fd);
    30d6:	8526                	mv	a0,s1
    30d8:	00002097          	auipc	ra,0x2
    30dc:	70c080e7          	jalr	1804(ra) # 57e4 <close>
  fd = open("unlinkread", O_RDWR);
    30e0:	4589                	li	a1,2
    30e2:	00004517          	auipc	a0,0x4
    30e6:	f6e50513          	addi	a0,a0,-146 # 7050 <malloc+0x13d2>
    30ea:	00002097          	auipc	ra,0x2
    30ee:	712080e7          	jalr	1810(ra) # 57fc <open>
    30f2:	84aa                	mv	s1,a0
  if(fd < 0){
    30f4:	0c054863          	bltz	a0,31c4 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
    30f8:	00004517          	auipc	a0,0x4
    30fc:	f5850513          	addi	a0,a0,-168 # 7050 <malloc+0x13d2>
    3100:	00002097          	auipc	ra,0x2
    3104:	70c080e7          	jalr	1804(ra) # 580c <unlink>
    3108:	ed61                	bnez	a0,31e0 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    310a:	20200593          	li	a1,514
    310e:	00004517          	auipc	a0,0x4
    3112:	f4250513          	addi	a0,a0,-190 # 7050 <malloc+0x13d2>
    3116:	00002097          	auipc	ra,0x2
    311a:	6e6080e7          	jalr	1766(ra) # 57fc <open>
    311e:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
    3120:	460d                	li	a2,3
    3122:	00004597          	auipc	a1,0x4
    3126:	fa658593          	addi	a1,a1,-90 # 70c8 <malloc+0x144a>
    312a:	00002097          	auipc	ra,0x2
    312e:	6b2080e7          	jalr	1714(ra) # 57dc <write>
  close(fd1);
    3132:	854a                	mv	a0,s2
    3134:	00002097          	auipc	ra,0x2
    3138:	6b0080e7          	jalr	1712(ra) # 57e4 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
    313c:	660d                	lui	a2,0x3
    313e:	00008597          	auipc	a1,0x8
    3142:	7a258593          	addi	a1,a1,1954 # b8e0 <buf>
    3146:	8526                	mv	a0,s1
    3148:	00002097          	auipc	ra,0x2
    314c:	68c080e7          	jalr	1676(ra) # 57d4 <read>
    3150:	4795                	li	a5,5
    3152:	0af51563          	bne	a0,a5,31fc <unlinkread+0x162>
  if(buf[0] != 'h'){
    3156:	00008717          	auipc	a4,0x8
    315a:	78a74703          	lbu	a4,1930(a4) # b8e0 <buf>
    315e:	06800793          	li	a5,104
    3162:	0af71b63          	bne	a4,a5,3218 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
    3166:	4629                	li	a2,10
    3168:	00008597          	auipc	a1,0x8
    316c:	77858593          	addi	a1,a1,1912 # b8e0 <buf>
    3170:	8526                	mv	a0,s1
    3172:	00002097          	auipc	ra,0x2
    3176:	66a080e7          	jalr	1642(ra) # 57dc <write>
    317a:	47a9                	li	a5,10
    317c:	0af51c63          	bne	a0,a5,3234 <unlinkread+0x19a>
  close(fd);
    3180:	8526                	mv	a0,s1
    3182:	00002097          	auipc	ra,0x2
    3186:	662080e7          	jalr	1634(ra) # 57e4 <close>
  unlink("unlinkread");
    318a:	00004517          	auipc	a0,0x4
    318e:	ec650513          	addi	a0,a0,-314 # 7050 <malloc+0x13d2>
    3192:	00002097          	auipc	ra,0x2
    3196:	67a080e7          	jalr	1658(ra) # 580c <unlink>
}
    319a:	70a2                	ld	ra,40(sp)
    319c:	7402                	ld	s0,32(sp)
    319e:	64e2                	ld	s1,24(sp)
    31a0:	6942                	ld	s2,16(sp)
    31a2:	69a2                	ld	s3,8(sp)
    31a4:	6145                	addi	sp,sp,48
    31a6:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
    31a8:	85ce                	mv	a1,s3
    31aa:	00004517          	auipc	a0,0x4
    31ae:	eb650513          	addi	a0,a0,-330 # 7060 <malloc+0x13e2>
    31b2:	00003097          	auipc	ra,0x3
    31b6:	a0e080e7          	jalr	-1522(ra) # 5bc0 <printf>
    exit(1);
    31ba:	4505                	li	a0,1
    31bc:	00002097          	auipc	ra,0x2
    31c0:	600080e7          	jalr	1536(ra) # 57bc <exit>
    printf("%s: open unlinkread failed\n", s);
    31c4:	85ce                	mv	a1,s3
    31c6:	00004517          	auipc	a0,0x4
    31ca:	ec250513          	addi	a0,a0,-318 # 7088 <malloc+0x140a>
    31ce:	00003097          	auipc	ra,0x3
    31d2:	9f2080e7          	jalr	-1550(ra) # 5bc0 <printf>
    exit(1);
    31d6:	4505                	li	a0,1
    31d8:	00002097          	auipc	ra,0x2
    31dc:	5e4080e7          	jalr	1508(ra) # 57bc <exit>
    printf("%s: unlink unlinkread failed\n", s);
    31e0:	85ce                	mv	a1,s3
    31e2:	00004517          	auipc	a0,0x4
    31e6:	ec650513          	addi	a0,a0,-314 # 70a8 <malloc+0x142a>
    31ea:	00003097          	auipc	ra,0x3
    31ee:	9d6080e7          	jalr	-1578(ra) # 5bc0 <printf>
    exit(1);
    31f2:	4505                	li	a0,1
    31f4:	00002097          	auipc	ra,0x2
    31f8:	5c8080e7          	jalr	1480(ra) # 57bc <exit>
    printf("%s: unlinkread read failed", s);
    31fc:	85ce                	mv	a1,s3
    31fe:	00004517          	auipc	a0,0x4
    3202:	ed250513          	addi	a0,a0,-302 # 70d0 <malloc+0x1452>
    3206:	00003097          	auipc	ra,0x3
    320a:	9ba080e7          	jalr	-1606(ra) # 5bc0 <printf>
    exit(1);
    320e:	4505                	li	a0,1
    3210:	00002097          	auipc	ra,0x2
    3214:	5ac080e7          	jalr	1452(ra) # 57bc <exit>
    printf("%s: unlinkread wrong data\n", s);
    3218:	85ce                	mv	a1,s3
    321a:	00004517          	auipc	a0,0x4
    321e:	ed650513          	addi	a0,a0,-298 # 70f0 <malloc+0x1472>
    3222:	00003097          	auipc	ra,0x3
    3226:	99e080e7          	jalr	-1634(ra) # 5bc0 <printf>
    exit(1);
    322a:	4505                	li	a0,1
    322c:	00002097          	auipc	ra,0x2
    3230:	590080e7          	jalr	1424(ra) # 57bc <exit>
    printf("%s: unlinkread write failed\n", s);
    3234:	85ce                	mv	a1,s3
    3236:	00004517          	auipc	a0,0x4
    323a:	eda50513          	addi	a0,a0,-294 # 7110 <malloc+0x1492>
    323e:	00003097          	auipc	ra,0x3
    3242:	982080e7          	jalr	-1662(ra) # 5bc0 <printf>
    exit(1);
    3246:	4505                	li	a0,1
    3248:	00002097          	auipc	ra,0x2
    324c:	574080e7          	jalr	1396(ra) # 57bc <exit>

0000000000003250 <linktest>:
{
    3250:	1101                	addi	sp,sp,-32
    3252:	ec06                	sd	ra,24(sp)
    3254:	e822                	sd	s0,16(sp)
    3256:	e426                	sd	s1,8(sp)
    3258:	e04a                	sd	s2,0(sp)
    325a:	1000                	addi	s0,sp,32
    325c:	892a                	mv	s2,a0
  unlink("lf1");
    325e:	00004517          	auipc	a0,0x4
    3262:	ed250513          	addi	a0,a0,-302 # 7130 <malloc+0x14b2>
    3266:	00002097          	auipc	ra,0x2
    326a:	5a6080e7          	jalr	1446(ra) # 580c <unlink>
  unlink("lf2");
    326e:	00004517          	auipc	a0,0x4
    3272:	eca50513          	addi	a0,a0,-310 # 7138 <malloc+0x14ba>
    3276:	00002097          	auipc	ra,0x2
    327a:	596080e7          	jalr	1430(ra) # 580c <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    327e:	20200593          	li	a1,514
    3282:	00004517          	auipc	a0,0x4
    3286:	eae50513          	addi	a0,a0,-338 # 7130 <malloc+0x14b2>
    328a:	00002097          	auipc	ra,0x2
    328e:	572080e7          	jalr	1394(ra) # 57fc <open>
  if(fd < 0){
    3292:	10054763          	bltz	a0,33a0 <linktest+0x150>
    3296:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    3298:	4615                	li	a2,5
    329a:	00004597          	auipc	a1,0x4
    329e:	de658593          	addi	a1,a1,-538 # 7080 <malloc+0x1402>
    32a2:	00002097          	auipc	ra,0x2
    32a6:	53a080e7          	jalr	1338(ra) # 57dc <write>
    32aa:	4795                	li	a5,5
    32ac:	10f51863          	bne	a0,a5,33bc <linktest+0x16c>
  close(fd);
    32b0:	8526                	mv	a0,s1
    32b2:	00002097          	auipc	ra,0x2
    32b6:	532080e7          	jalr	1330(ra) # 57e4 <close>
  if(link("lf1", "lf2") < 0){
    32ba:	00004597          	auipc	a1,0x4
    32be:	e7e58593          	addi	a1,a1,-386 # 7138 <malloc+0x14ba>
    32c2:	00004517          	auipc	a0,0x4
    32c6:	e6e50513          	addi	a0,a0,-402 # 7130 <malloc+0x14b2>
    32ca:	00002097          	auipc	ra,0x2
    32ce:	552080e7          	jalr	1362(ra) # 581c <link>
    32d2:	10054363          	bltz	a0,33d8 <linktest+0x188>
  unlink("lf1");
    32d6:	00004517          	auipc	a0,0x4
    32da:	e5a50513          	addi	a0,a0,-422 # 7130 <malloc+0x14b2>
    32de:	00002097          	auipc	ra,0x2
    32e2:	52e080e7          	jalr	1326(ra) # 580c <unlink>
  if(open("lf1", 0) >= 0){
    32e6:	4581                	li	a1,0
    32e8:	00004517          	auipc	a0,0x4
    32ec:	e4850513          	addi	a0,a0,-440 # 7130 <malloc+0x14b2>
    32f0:	00002097          	auipc	ra,0x2
    32f4:	50c080e7          	jalr	1292(ra) # 57fc <open>
    32f8:	0e055e63          	bgez	a0,33f4 <linktest+0x1a4>
  fd = open("lf2", 0);
    32fc:	4581                	li	a1,0
    32fe:	00004517          	auipc	a0,0x4
    3302:	e3a50513          	addi	a0,a0,-454 # 7138 <malloc+0x14ba>
    3306:	00002097          	auipc	ra,0x2
    330a:	4f6080e7          	jalr	1270(ra) # 57fc <open>
    330e:	84aa                	mv	s1,a0
  if(fd < 0){
    3310:	10054063          	bltz	a0,3410 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    3314:	660d                	lui	a2,0x3
    3316:	00008597          	auipc	a1,0x8
    331a:	5ca58593          	addi	a1,a1,1482 # b8e0 <buf>
    331e:	00002097          	auipc	ra,0x2
    3322:	4b6080e7          	jalr	1206(ra) # 57d4 <read>
    3326:	4795                	li	a5,5
    3328:	10f51263          	bne	a0,a5,342c <linktest+0x1dc>
  close(fd);
    332c:	8526                	mv	a0,s1
    332e:	00002097          	auipc	ra,0x2
    3332:	4b6080e7          	jalr	1206(ra) # 57e4 <close>
  if(link("lf2", "lf2") >= 0){
    3336:	00004597          	auipc	a1,0x4
    333a:	e0258593          	addi	a1,a1,-510 # 7138 <malloc+0x14ba>
    333e:	852e                	mv	a0,a1
    3340:	00002097          	auipc	ra,0x2
    3344:	4dc080e7          	jalr	1244(ra) # 581c <link>
    3348:	10055063          	bgez	a0,3448 <linktest+0x1f8>
  unlink("lf2");
    334c:	00004517          	auipc	a0,0x4
    3350:	dec50513          	addi	a0,a0,-532 # 7138 <malloc+0x14ba>
    3354:	00002097          	auipc	ra,0x2
    3358:	4b8080e7          	jalr	1208(ra) # 580c <unlink>
  if(link("lf2", "lf1") >= 0){
    335c:	00004597          	auipc	a1,0x4
    3360:	dd458593          	addi	a1,a1,-556 # 7130 <malloc+0x14b2>
    3364:	00004517          	auipc	a0,0x4
    3368:	dd450513          	addi	a0,a0,-556 # 7138 <malloc+0x14ba>
    336c:	00002097          	auipc	ra,0x2
    3370:	4b0080e7          	jalr	1200(ra) # 581c <link>
    3374:	0e055863          	bgez	a0,3464 <linktest+0x214>
  if(link(".", "lf1") >= 0){
    3378:	00004597          	auipc	a1,0x4
    337c:	db858593          	addi	a1,a1,-584 # 7130 <malloc+0x14b2>
    3380:	00003517          	auipc	a0,0x3
    3384:	23850513          	addi	a0,a0,568 # 65b8 <malloc+0x93a>
    3388:	00002097          	auipc	ra,0x2
    338c:	494080e7          	jalr	1172(ra) # 581c <link>
    3390:	0e055863          	bgez	a0,3480 <linktest+0x230>
}
    3394:	60e2                	ld	ra,24(sp)
    3396:	6442                	ld	s0,16(sp)
    3398:	64a2                	ld	s1,8(sp)
    339a:	6902                	ld	s2,0(sp)
    339c:	6105                	addi	sp,sp,32
    339e:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    33a0:	85ca                	mv	a1,s2
    33a2:	00004517          	auipc	a0,0x4
    33a6:	d9e50513          	addi	a0,a0,-610 # 7140 <malloc+0x14c2>
    33aa:	00003097          	auipc	ra,0x3
    33ae:	816080e7          	jalr	-2026(ra) # 5bc0 <printf>
    exit(1);
    33b2:	4505                	li	a0,1
    33b4:	00002097          	auipc	ra,0x2
    33b8:	408080e7          	jalr	1032(ra) # 57bc <exit>
    printf("%s: write lf1 failed\n", s);
    33bc:	85ca                	mv	a1,s2
    33be:	00004517          	auipc	a0,0x4
    33c2:	d9a50513          	addi	a0,a0,-614 # 7158 <malloc+0x14da>
    33c6:	00002097          	auipc	ra,0x2
    33ca:	7fa080e7          	jalr	2042(ra) # 5bc0 <printf>
    exit(1);
    33ce:	4505                	li	a0,1
    33d0:	00002097          	auipc	ra,0x2
    33d4:	3ec080e7          	jalr	1004(ra) # 57bc <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    33d8:	85ca                	mv	a1,s2
    33da:	00004517          	auipc	a0,0x4
    33de:	d9650513          	addi	a0,a0,-618 # 7170 <malloc+0x14f2>
    33e2:	00002097          	auipc	ra,0x2
    33e6:	7de080e7          	jalr	2014(ra) # 5bc0 <printf>
    exit(1);
    33ea:	4505                	li	a0,1
    33ec:	00002097          	auipc	ra,0x2
    33f0:	3d0080e7          	jalr	976(ra) # 57bc <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    33f4:	85ca                	mv	a1,s2
    33f6:	00004517          	auipc	a0,0x4
    33fa:	d9a50513          	addi	a0,a0,-614 # 7190 <malloc+0x1512>
    33fe:	00002097          	auipc	ra,0x2
    3402:	7c2080e7          	jalr	1986(ra) # 5bc0 <printf>
    exit(1);
    3406:	4505                	li	a0,1
    3408:	00002097          	auipc	ra,0x2
    340c:	3b4080e7          	jalr	948(ra) # 57bc <exit>
    printf("%s: open lf2 failed\n", s);
    3410:	85ca                	mv	a1,s2
    3412:	00004517          	auipc	a0,0x4
    3416:	dae50513          	addi	a0,a0,-594 # 71c0 <malloc+0x1542>
    341a:	00002097          	auipc	ra,0x2
    341e:	7a6080e7          	jalr	1958(ra) # 5bc0 <printf>
    exit(1);
    3422:	4505                	li	a0,1
    3424:	00002097          	auipc	ra,0x2
    3428:	398080e7          	jalr	920(ra) # 57bc <exit>
    printf("%s: read lf2 failed\n", s);
    342c:	85ca                	mv	a1,s2
    342e:	00004517          	auipc	a0,0x4
    3432:	daa50513          	addi	a0,a0,-598 # 71d8 <malloc+0x155a>
    3436:	00002097          	auipc	ra,0x2
    343a:	78a080e7          	jalr	1930(ra) # 5bc0 <printf>
    exit(1);
    343e:	4505                	li	a0,1
    3440:	00002097          	auipc	ra,0x2
    3444:	37c080e7          	jalr	892(ra) # 57bc <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    3448:	85ca                	mv	a1,s2
    344a:	00004517          	auipc	a0,0x4
    344e:	da650513          	addi	a0,a0,-602 # 71f0 <malloc+0x1572>
    3452:	00002097          	auipc	ra,0x2
    3456:	76e080e7          	jalr	1902(ra) # 5bc0 <printf>
    exit(1);
    345a:	4505                	li	a0,1
    345c:	00002097          	auipc	ra,0x2
    3460:	360080e7          	jalr	864(ra) # 57bc <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
    3464:	85ca                	mv	a1,s2
    3466:	00004517          	auipc	a0,0x4
    346a:	db250513          	addi	a0,a0,-590 # 7218 <malloc+0x159a>
    346e:	00002097          	auipc	ra,0x2
    3472:	752080e7          	jalr	1874(ra) # 5bc0 <printf>
    exit(1);
    3476:	4505                	li	a0,1
    3478:	00002097          	auipc	ra,0x2
    347c:	344080e7          	jalr	836(ra) # 57bc <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    3480:	85ca                	mv	a1,s2
    3482:	00004517          	auipc	a0,0x4
    3486:	dbe50513          	addi	a0,a0,-578 # 7240 <malloc+0x15c2>
    348a:	00002097          	auipc	ra,0x2
    348e:	736080e7          	jalr	1846(ra) # 5bc0 <printf>
    exit(1);
    3492:	4505                	li	a0,1
    3494:	00002097          	auipc	ra,0x2
    3498:	328080e7          	jalr	808(ra) # 57bc <exit>

000000000000349c <concreate>:
{
    349c:	7135                	addi	sp,sp,-160
    349e:	ed06                	sd	ra,152(sp)
    34a0:	e922                	sd	s0,144(sp)
    34a2:	e526                	sd	s1,136(sp)
    34a4:	e14a                	sd	s2,128(sp)
    34a6:	fcce                	sd	s3,120(sp)
    34a8:	f8d2                	sd	s4,112(sp)
    34aa:	f4d6                	sd	s5,104(sp)
    34ac:	f0da                	sd	s6,96(sp)
    34ae:	ecde                	sd	s7,88(sp)
    34b0:	1100                	addi	s0,sp,160
    34b2:	89aa                	mv	s3,a0
  file[0] = 'C';
    34b4:	04300793          	li	a5,67
    34b8:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    34bc:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    34c0:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    34c2:	4b0d                	li	s6,3
    34c4:	4a85                	li	s5,1
      link("C0", file);
    34c6:	00004b97          	auipc	s7,0x4
    34ca:	d9ab8b93          	addi	s7,s7,-614 # 7260 <malloc+0x15e2>
  for(i = 0; i < N; i++){
    34ce:	02800a13          	li	s4,40
    34d2:	acc1                	j	37a2 <concreate+0x306>
      link("C0", file);
    34d4:	fa840593          	addi	a1,s0,-88
    34d8:	855e                	mv	a0,s7
    34da:	00002097          	auipc	ra,0x2
    34de:	342080e7          	jalr	834(ra) # 581c <link>
    if(pid == 0) {
    34e2:	a45d                	j	3788 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    34e4:	4795                	li	a5,5
    34e6:	02f9693b          	remw	s2,s2,a5
    34ea:	4785                	li	a5,1
    34ec:	02f90b63          	beq	s2,a5,3522 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    34f0:	20200593          	li	a1,514
    34f4:	fa840513          	addi	a0,s0,-88
    34f8:	00002097          	auipc	ra,0x2
    34fc:	304080e7          	jalr	772(ra) # 57fc <open>
      if(fd < 0){
    3500:	26055b63          	bgez	a0,3776 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    3504:	fa840593          	addi	a1,s0,-88
    3508:	00004517          	auipc	a0,0x4
    350c:	d6050513          	addi	a0,a0,-672 # 7268 <malloc+0x15ea>
    3510:	00002097          	auipc	ra,0x2
    3514:	6b0080e7          	jalr	1712(ra) # 5bc0 <printf>
        exit(1);
    3518:	4505                	li	a0,1
    351a:	00002097          	auipc	ra,0x2
    351e:	2a2080e7          	jalr	674(ra) # 57bc <exit>
      link("C0", file);
    3522:	fa840593          	addi	a1,s0,-88
    3526:	00004517          	auipc	a0,0x4
    352a:	d3a50513          	addi	a0,a0,-710 # 7260 <malloc+0x15e2>
    352e:	00002097          	auipc	ra,0x2
    3532:	2ee080e7          	jalr	750(ra) # 581c <link>
      exit(0);
    3536:	4501                	li	a0,0
    3538:	00002097          	auipc	ra,0x2
    353c:	284080e7          	jalr	644(ra) # 57bc <exit>
        exit(1);
    3540:	4505                	li	a0,1
    3542:	00002097          	auipc	ra,0x2
    3546:	27a080e7          	jalr	634(ra) # 57bc <exit>
  memset(fa, 0, sizeof(fa));
    354a:	02800613          	li	a2,40
    354e:	4581                	li	a1,0
    3550:	f8040513          	addi	a0,s0,-128
    3554:	00002097          	auipc	ra,0x2
    3558:	06c080e7          	jalr	108(ra) # 55c0 <memset>
  fd = open(".", 0);
    355c:	4581                	li	a1,0
    355e:	00003517          	auipc	a0,0x3
    3562:	05a50513          	addi	a0,a0,90 # 65b8 <malloc+0x93a>
    3566:	00002097          	auipc	ra,0x2
    356a:	296080e7          	jalr	662(ra) # 57fc <open>
    356e:	892a                	mv	s2,a0
  n = 0;
    3570:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3572:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    3576:	02700b13          	li	s6,39
      fa[i] = 1;
    357a:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    357c:	4641                	li	a2,16
    357e:	f7040593          	addi	a1,s0,-144
    3582:	854a                	mv	a0,s2
    3584:	00002097          	auipc	ra,0x2
    3588:	250080e7          	jalr	592(ra) # 57d4 <read>
    358c:	08a05163          	blez	a0,360e <concreate+0x172>
    if(de.inum == 0)
    3590:	f7045783          	lhu	a5,-144(s0)
    3594:	d7e5                	beqz	a5,357c <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3596:	f7244783          	lbu	a5,-142(s0)
    359a:	ff4791e3          	bne	a5,s4,357c <concreate+0xe0>
    359e:	f7444783          	lbu	a5,-140(s0)
    35a2:	ffe9                	bnez	a5,357c <concreate+0xe0>
      i = de.name[1] - '0';
    35a4:	f7344783          	lbu	a5,-141(s0)
    35a8:	fd07879b          	addiw	a5,a5,-48
    35ac:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    35b0:	00eb6f63          	bltu	s6,a4,35ce <concreate+0x132>
      if(fa[i]){
    35b4:	fb040793          	addi	a5,s0,-80
    35b8:	97ba                	add	a5,a5,a4
    35ba:	fd07c783          	lbu	a5,-48(a5)
    35be:	eb85                	bnez	a5,35ee <concreate+0x152>
      fa[i] = 1;
    35c0:	fb040793          	addi	a5,s0,-80
    35c4:	973e                	add	a4,a4,a5
    35c6:	fd770823          	sb	s7,-48(a4)
      n++;
    35ca:	2a85                	addiw	s5,s5,1
    35cc:	bf45                	j	357c <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    35ce:	f7240613          	addi	a2,s0,-142
    35d2:	85ce                	mv	a1,s3
    35d4:	00004517          	auipc	a0,0x4
    35d8:	cb450513          	addi	a0,a0,-844 # 7288 <malloc+0x160a>
    35dc:	00002097          	auipc	ra,0x2
    35e0:	5e4080e7          	jalr	1508(ra) # 5bc0 <printf>
        exit(1);
    35e4:	4505                	li	a0,1
    35e6:	00002097          	auipc	ra,0x2
    35ea:	1d6080e7          	jalr	470(ra) # 57bc <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    35ee:	f7240613          	addi	a2,s0,-142
    35f2:	85ce                	mv	a1,s3
    35f4:	00004517          	auipc	a0,0x4
    35f8:	cb450513          	addi	a0,a0,-844 # 72a8 <malloc+0x162a>
    35fc:	00002097          	auipc	ra,0x2
    3600:	5c4080e7          	jalr	1476(ra) # 5bc0 <printf>
        exit(1);
    3604:	4505                	li	a0,1
    3606:	00002097          	auipc	ra,0x2
    360a:	1b6080e7          	jalr	438(ra) # 57bc <exit>
  close(fd);
    360e:	854a                	mv	a0,s2
    3610:	00002097          	auipc	ra,0x2
    3614:	1d4080e7          	jalr	468(ra) # 57e4 <close>
  if(n != N){
    3618:	02800793          	li	a5,40
    361c:	00fa9763          	bne	s5,a5,362a <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    3620:	4a8d                	li	s5,3
    3622:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    3624:	02800a13          	li	s4,40
    3628:	a8c9                	j	36fa <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    362a:	85ce                	mv	a1,s3
    362c:	00004517          	auipc	a0,0x4
    3630:	ca450513          	addi	a0,a0,-860 # 72d0 <malloc+0x1652>
    3634:	00002097          	auipc	ra,0x2
    3638:	58c080e7          	jalr	1420(ra) # 5bc0 <printf>
    exit(1);
    363c:	4505                	li	a0,1
    363e:	00002097          	auipc	ra,0x2
    3642:	17e080e7          	jalr	382(ra) # 57bc <exit>
      printf("%s: fork failed\n", s);
    3646:	85ce                	mv	a1,s3
    3648:	00003517          	auipc	a0,0x3
    364c:	83850513          	addi	a0,a0,-1992 # 5e80 <malloc+0x202>
    3650:	00002097          	auipc	ra,0x2
    3654:	570080e7          	jalr	1392(ra) # 5bc0 <printf>
      exit(1);
    3658:	4505                	li	a0,1
    365a:	00002097          	auipc	ra,0x2
    365e:	162080e7          	jalr	354(ra) # 57bc <exit>
      close(open(file, 0));
    3662:	4581                	li	a1,0
    3664:	fa840513          	addi	a0,s0,-88
    3668:	00002097          	auipc	ra,0x2
    366c:	194080e7          	jalr	404(ra) # 57fc <open>
    3670:	00002097          	auipc	ra,0x2
    3674:	174080e7          	jalr	372(ra) # 57e4 <close>
      close(open(file, 0));
    3678:	4581                	li	a1,0
    367a:	fa840513          	addi	a0,s0,-88
    367e:	00002097          	auipc	ra,0x2
    3682:	17e080e7          	jalr	382(ra) # 57fc <open>
    3686:	00002097          	auipc	ra,0x2
    368a:	15e080e7          	jalr	350(ra) # 57e4 <close>
      close(open(file, 0));
    368e:	4581                	li	a1,0
    3690:	fa840513          	addi	a0,s0,-88
    3694:	00002097          	auipc	ra,0x2
    3698:	168080e7          	jalr	360(ra) # 57fc <open>
    369c:	00002097          	auipc	ra,0x2
    36a0:	148080e7          	jalr	328(ra) # 57e4 <close>
      close(open(file, 0));
    36a4:	4581                	li	a1,0
    36a6:	fa840513          	addi	a0,s0,-88
    36aa:	00002097          	auipc	ra,0x2
    36ae:	152080e7          	jalr	338(ra) # 57fc <open>
    36b2:	00002097          	auipc	ra,0x2
    36b6:	132080e7          	jalr	306(ra) # 57e4 <close>
      close(open(file, 0));
    36ba:	4581                	li	a1,0
    36bc:	fa840513          	addi	a0,s0,-88
    36c0:	00002097          	auipc	ra,0x2
    36c4:	13c080e7          	jalr	316(ra) # 57fc <open>
    36c8:	00002097          	auipc	ra,0x2
    36cc:	11c080e7          	jalr	284(ra) # 57e4 <close>
      close(open(file, 0));
    36d0:	4581                	li	a1,0
    36d2:	fa840513          	addi	a0,s0,-88
    36d6:	00002097          	auipc	ra,0x2
    36da:	126080e7          	jalr	294(ra) # 57fc <open>
    36de:	00002097          	auipc	ra,0x2
    36e2:	106080e7          	jalr	262(ra) # 57e4 <close>
    if(pid == 0)
    36e6:	08090363          	beqz	s2,376c <concreate+0x2d0>
      wait(0);
    36ea:	4501                	li	a0,0
    36ec:	00002097          	auipc	ra,0x2
    36f0:	0d8080e7          	jalr	216(ra) # 57c4 <wait>
  for(i = 0; i < N; i++){
    36f4:	2485                	addiw	s1,s1,1
    36f6:	0f448563          	beq	s1,s4,37e0 <concreate+0x344>
    file[1] = '0' + i;
    36fa:	0304879b          	addiw	a5,s1,48
    36fe:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    3702:	00002097          	auipc	ra,0x2
    3706:	0b2080e7          	jalr	178(ra) # 57b4 <fork>
    370a:	892a                	mv	s2,a0
    if(pid < 0){
    370c:	f2054de3          	bltz	a0,3646 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    3710:	0354e73b          	remw	a4,s1,s5
    3714:	00a767b3          	or	a5,a4,a0
    3718:	2781                	sext.w	a5,a5
    371a:	d7a1                	beqz	a5,3662 <concreate+0x1c6>
    371c:	01671363          	bne	a4,s6,3722 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    3720:	f129                	bnez	a0,3662 <concreate+0x1c6>
      unlink(file);
    3722:	fa840513          	addi	a0,s0,-88
    3726:	00002097          	auipc	ra,0x2
    372a:	0e6080e7          	jalr	230(ra) # 580c <unlink>
      unlink(file);
    372e:	fa840513          	addi	a0,s0,-88
    3732:	00002097          	auipc	ra,0x2
    3736:	0da080e7          	jalr	218(ra) # 580c <unlink>
      unlink(file);
    373a:	fa840513          	addi	a0,s0,-88
    373e:	00002097          	auipc	ra,0x2
    3742:	0ce080e7          	jalr	206(ra) # 580c <unlink>
      unlink(file);
    3746:	fa840513          	addi	a0,s0,-88
    374a:	00002097          	auipc	ra,0x2
    374e:	0c2080e7          	jalr	194(ra) # 580c <unlink>
      unlink(file);
    3752:	fa840513          	addi	a0,s0,-88
    3756:	00002097          	auipc	ra,0x2
    375a:	0b6080e7          	jalr	182(ra) # 580c <unlink>
      unlink(file);
    375e:	fa840513          	addi	a0,s0,-88
    3762:	00002097          	auipc	ra,0x2
    3766:	0aa080e7          	jalr	170(ra) # 580c <unlink>
    376a:	bfb5                	j	36e6 <concreate+0x24a>
      exit(0);
    376c:	4501                	li	a0,0
    376e:	00002097          	auipc	ra,0x2
    3772:	04e080e7          	jalr	78(ra) # 57bc <exit>
      close(fd);
    3776:	00002097          	auipc	ra,0x2
    377a:	06e080e7          	jalr	110(ra) # 57e4 <close>
    if(pid == 0) {
    377e:	bb65                	j	3536 <concreate+0x9a>
      close(fd);
    3780:	00002097          	auipc	ra,0x2
    3784:	064080e7          	jalr	100(ra) # 57e4 <close>
      wait(&xstatus);
    3788:	f6c40513          	addi	a0,s0,-148
    378c:	00002097          	auipc	ra,0x2
    3790:	038080e7          	jalr	56(ra) # 57c4 <wait>
      if(xstatus != 0)
    3794:	f6c42483          	lw	s1,-148(s0)
    3798:	da0494e3          	bnez	s1,3540 <concreate+0xa4>
  for(i = 0; i < N; i++){
    379c:	2905                	addiw	s2,s2,1
    379e:	db4906e3          	beq	s2,s4,354a <concreate+0xae>
    file[1] = '0' + i;
    37a2:	0309079b          	addiw	a5,s2,48
    37a6:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    37aa:	fa840513          	addi	a0,s0,-88
    37ae:	00002097          	auipc	ra,0x2
    37b2:	05e080e7          	jalr	94(ra) # 580c <unlink>
    pid = fork();
    37b6:	00002097          	auipc	ra,0x2
    37ba:	ffe080e7          	jalr	-2(ra) # 57b4 <fork>
    if(pid && (i % 3) == 1){
    37be:	d20503e3          	beqz	a0,34e4 <concreate+0x48>
    37c2:	036967bb          	remw	a5,s2,s6
    37c6:	d15787e3          	beq	a5,s5,34d4 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    37ca:	20200593          	li	a1,514
    37ce:	fa840513          	addi	a0,s0,-88
    37d2:	00002097          	auipc	ra,0x2
    37d6:	02a080e7          	jalr	42(ra) # 57fc <open>
      if(fd < 0){
    37da:	fa0553e3          	bgez	a0,3780 <concreate+0x2e4>
    37de:	b31d                	j	3504 <concreate+0x68>
}
    37e0:	60ea                	ld	ra,152(sp)
    37e2:	644a                	ld	s0,144(sp)
    37e4:	64aa                	ld	s1,136(sp)
    37e6:	690a                	ld	s2,128(sp)
    37e8:	79e6                	ld	s3,120(sp)
    37ea:	7a46                	ld	s4,112(sp)
    37ec:	7aa6                	ld	s5,104(sp)
    37ee:	7b06                	ld	s6,96(sp)
    37f0:	6be6                	ld	s7,88(sp)
    37f2:	610d                	addi	sp,sp,160
    37f4:	8082                	ret

00000000000037f6 <linkunlink>:
{
    37f6:	711d                	addi	sp,sp,-96
    37f8:	ec86                	sd	ra,88(sp)
    37fa:	e8a2                	sd	s0,80(sp)
    37fc:	e4a6                	sd	s1,72(sp)
    37fe:	e0ca                	sd	s2,64(sp)
    3800:	fc4e                	sd	s3,56(sp)
    3802:	f852                	sd	s4,48(sp)
    3804:	f456                	sd	s5,40(sp)
    3806:	f05a                	sd	s6,32(sp)
    3808:	ec5e                	sd	s7,24(sp)
    380a:	e862                	sd	s8,16(sp)
    380c:	e466                	sd	s9,8(sp)
    380e:	1080                	addi	s0,sp,96
    3810:	84aa                	mv	s1,a0
  unlink("x");
    3812:	00003517          	auipc	a0,0x3
    3816:	f9650513          	addi	a0,a0,-106 # 67a8 <malloc+0xb2a>
    381a:	00002097          	auipc	ra,0x2
    381e:	ff2080e7          	jalr	-14(ra) # 580c <unlink>
  pid = fork();
    3822:	00002097          	auipc	ra,0x2
    3826:	f92080e7          	jalr	-110(ra) # 57b4 <fork>
  if(pid < 0){
    382a:	02054b63          	bltz	a0,3860 <linkunlink+0x6a>
    382e:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    3830:	4c85                	li	s9,1
    3832:	e119                	bnez	a0,3838 <linkunlink+0x42>
    3834:	06100c93          	li	s9,97
    3838:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    383c:	41c659b7          	lui	s3,0x41c65
    3840:	e6d9899b          	addiw	s3,s3,-403
    3844:	690d                	lui	s2,0x3
    3846:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    384a:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    384c:	4b05                	li	s6,1
      unlink("x");
    384e:	00003a97          	auipc	s5,0x3
    3852:	f5aa8a93          	addi	s5,s5,-166 # 67a8 <malloc+0xb2a>
      link("cat", "x");
    3856:	00004b97          	auipc	s7,0x4
    385a:	ab2b8b93          	addi	s7,s7,-1358 # 7308 <malloc+0x168a>
    385e:	a825                	j	3896 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    3860:	85a6                	mv	a1,s1
    3862:	00002517          	auipc	a0,0x2
    3866:	61e50513          	addi	a0,a0,1566 # 5e80 <malloc+0x202>
    386a:	00002097          	auipc	ra,0x2
    386e:	356080e7          	jalr	854(ra) # 5bc0 <printf>
    exit(1);
    3872:	4505                	li	a0,1
    3874:	00002097          	auipc	ra,0x2
    3878:	f48080e7          	jalr	-184(ra) # 57bc <exit>
      close(open("x", O_RDWR | O_CREATE));
    387c:	20200593          	li	a1,514
    3880:	8556                	mv	a0,s5
    3882:	00002097          	auipc	ra,0x2
    3886:	f7a080e7          	jalr	-134(ra) # 57fc <open>
    388a:	00002097          	auipc	ra,0x2
    388e:	f5a080e7          	jalr	-166(ra) # 57e4 <close>
  for(i = 0; i < 100; i++){
    3892:	34fd                	addiw	s1,s1,-1
    3894:	c88d                	beqz	s1,38c6 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    3896:	033c87bb          	mulw	a5,s9,s3
    389a:	012787bb          	addw	a5,a5,s2
    389e:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    38a2:	0347f7bb          	remuw	a5,a5,s4
    38a6:	dbf9                	beqz	a5,387c <linkunlink+0x86>
    } else if((x % 3) == 1){
    38a8:	01678863          	beq	a5,s6,38b8 <linkunlink+0xc2>
      unlink("x");
    38ac:	8556                	mv	a0,s5
    38ae:	00002097          	auipc	ra,0x2
    38b2:	f5e080e7          	jalr	-162(ra) # 580c <unlink>
    38b6:	bff1                	j	3892 <linkunlink+0x9c>
      link("cat", "x");
    38b8:	85d6                	mv	a1,s5
    38ba:	855e                	mv	a0,s7
    38bc:	00002097          	auipc	ra,0x2
    38c0:	f60080e7          	jalr	-160(ra) # 581c <link>
    38c4:	b7f9                	j	3892 <linkunlink+0x9c>
  if(pid)
    38c6:	020c0463          	beqz	s8,38ee <linkunlink+0xf8>
    wait(0);
    38ca:	4501                	li	a0,0
    38cc:	00002097          	auipc	ra,0x2
    38d0:	ef8080e7          	jalr	-264(ra) # 57c4 <wait>
}
    38d4:	60e6                	ld	ra,88(sp)
    38d6:	6446                	ld	s0,80(sp)
    38d8:	64a6                	ld	s1,72(sp)
    38da:	6906                	ld	s2,64(sp)
    38dc:	79e2                	ld	s3,56(sp)
    38de:	7a42                	ld	s4,48(sp)
    38e0:	7aa2                	ld	s5,40(sp)
    38e2:	7b02                	ld	s6,32(sp)
    38e4:	6be2                	ld	s7,24(sp)
    38e6:	6c42                	ld	s8,16(sp)
    38e8:	6ca2                	ld	s9,8(sp)
    38ea:	6125                	addi	sp,sp,96
    38ec:	8082                	ret
    exit(0);
    38ee:	4501                	li	a0,0
    38f0:	00002097          	auipc	ra,0x2
    38f4:	ecc080e7          	jalr	-308(ra) # 57bc <exit>

00000000000038f8 <subdir>:
{
    38f8:	1101                	addi	sp,sp,-32
    38fa:	ec06                	sd	ra,24(sp)
    38fc:	e822                	sd	s0,16(sp)
    38fe:	e426                	sd	s1,8(sp)
    3900:	e04a                	sd	s2,0(sp)
    3902:	1000                	addi	s0,sp,32
    3904:	892a                	mv	s2,a0
  unlink("ff");
    3906:	00004517          	auipc	a0,0x4
    390a:	b3a50513          	addi	a0,a0,-1222 # 7440 <malloc+0x17c2>
    390e:	00002097          	auipc	ra,0x2
    3912:	efe080e7          	jalr	-258(ra) # 580c <unlink>
  if(mkdir("dd") != 0){
    3916:	00004517          	auipc	a0,0x4
    391a:	9fa50513          	addi	a0,a0,-1542 # 7310 <malloc+0x1692>
    391e:	00002097          	auipc	ra,0x2
    3922:	f06080e7          	jalr	-250(ra) # 5824 <mkdir>
    3926:	38051663          	bnez	a0,3cb2 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    392a:	20200593          	li	a1,514
    392e:	00004517          	auipc	a0,0x4
    3932:	a0250513          	addi	a0,a0,-1534 # 7330 <malloc+0x16b2>
    3936:	00002097          	auipc	ra,0x2
    393a:	ec6080e7          	jalr	-314(ra) # 57fc <open>
    393e:	84aa                	mv	s1,a0
  if(fd < 0){
    3940:	38054763          	bltz	a0,3cce <subdir+0x3d6>
  write(fd, "ff", 2);
    3944:	4609                	li	a2,2
    3946:	00004597          	auipc	a1,0x4
    394a:	afa58593          	addi	a1,a1,-1286 # 7440 <malloc+0x17c2>
    394e:	00002097          	auipc	ra,0x2
    3952:	e8e080e7          	jalr	-370(ra) # 57dc <write>
  close(fd);
    3956:	8526                	mv	a0,s1
    3958:	00002097          	auipc	ra,0x2
    395c:	e8c080e7          	jalr	-372(ra) # 57e4 <close>
  if(unlink("dd") >= 0){
    3960:	00004517          	auipc	a0,0x4
    3964:	9b050513          	addi	a0,a0,-1616 # 7310 <malloc+0x1692>
    3968:	00002097          	auipc	ra,0x2
    396c:	ea4080e7          	jalr	-348(ra) # 580c <unlink>
    3970:	36055d63          	bgez	a0,3cea <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    3974:	00004517          	auipc	a0,0x4
    3978:	a1450513          	addi	a0,a0,-1516 # 7388 <malloc+0x170a>
    397c:	00002097          	auipc	ra,0x2
    3980:	ea8080e7          	jalr	-344(ra) # 5824 <mkdir>
    3984:	38051163          	bnez	a0,3d06 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3988:	20200593          	li	a1,514
    398c:	00004517          	auipc	a0,0x4
    3990:	a2450513          	addi	a0,a0,-1500 # 73b0 <malloc+0x1732>
    3994:	00002097          	auipc	ra,0x2
    3998:	e68080e7          	jalr	-408(ra) # 57fc <open>
    399c:	84aa                	mv	s1,a0
  if(fd < 0){
    399e:	38054263          	bltz	a0,3d22 <subdir+0x42a>
  write(fd, "FF", 2);
    39a2:	4609                	li	a2,2
    39a4:	00004597          	auipc	a1,0x4
    39a8:	a3c58593          	addi	a1,a1,-1476 # 73e0 <malloc+0x1762>
    39ac:	00002097          	auipc	ra,0x2
    39b0:	e30080e7          	jalr	-464(ra) # 57dc <write>
  close(fd);
    39b4:	8526                	mv	a0,s1
    39b6:	00002097          	auipc	ra,0x2
    39ba:	e2e080e7          	jalr	-466(ra) # 57e4 <close>
  fd = open("dd/dd/../ff", 0);
    39be:	4581                	li	a1,0
    39c0:	00004517          	auipc	a0,0x4
    39c4:	a2850513          	addi	a0,a0,-1496 # 73e8 <malloc+0x176a>
    39c8:	00002097          	auipc	ra,0x2
    39cc:	e34080e7          	jalr	-460(ra) # 57fc <open>
    39d0:	84aa                	mv	s1,a0
  if(fd < 0){
    39d2:	36054663          	bltz	a0,3d3e <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    39d6:	660d                	lui	a2,0x3
    39d8:	00008597          	auipc	a1,0x8
    39dc:	f0858593          	addi	a1,a1,-248 # b8e0 <buf>
    39e0:	00002097          	auipc	ra,0x2
    39e4:	df4080e7          	jalr	-524(ra) # 57d4 <read>
  if(cc != 2 || buf[0] != 'f'){
    39e8:	4789                	li	a5,2
    39ea:	36f51863          	bne	a0,a5,3d5a <subdir+0x462>
    39ee:	00008717          	auipc	a4,0x8
    39f2:	ef274703          	lbu	a4,-270(a4) # b8e0 <buf>
    39f6:	06600793          	li	a5,102
    39fa:	36f71063          	bne	a4,a5,3d5a <subdir+0x462>
  close(fd);
    39fe:	8526                	mv	a0,s1
    3a00:	00002097          	auipc	ra,0x2
    3a04:	de4080e7          	jalr	-540(ra) # 57e4 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3a08:	00004597          	auipc	a1,0x4
    3a0c:	a3058593          	addi	a1,a1,-1488 # 7438 <malloc+0x17ba>
    3a10:	00004517          	auipc	a0,0x4
    3a14:	9a050513          	addi	a0,a0,-1632 # 73b0 <malloc+0x1732>
    3a18:	00002097          	auipc	ra,0x2
    3a1c:	e04080e7          	jalr	-508(ra) # 581c <link>
    3a20:	34051b63          	bnez	a0,3d76 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3a24:	00004517          	auipc	a0,0x4
    3a28:	98c50513          	addi	a0,a0,-1652 # 73b0 <malloc+0x1732>
    3a2c:	00002097          	auipc	ra,0x2
    3a30:	de0080e7          	jalr	-544(ra) # 580c <unlink>
    3a34:	34051f63          	bnez	a0,3d92 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3a38:	4581                	li	a1,0
    3a3a:	00004517          	auipc	a0,0x4
    3a3e:	97650513          	addi	a0,a0,-1674 # 73b0 <malloc+0x1732>
    3a42:	00002097          	auipc	ra,0x2
    3a46:	dba080e7          	jalr	-582(ra) # 57fc <open>
    3a4a:	36055263          	bgez	a0,3dae <subdir+0x4b6>
  if(chdir("dd") != 0){
    3a4e:	00004517          	auipc	a0,0x4
    3a52:	8c250513          	addi	a0,a0,-1854 # 7310 <malloc+0x1692>
    3a56:	00002097          	auipc	ra,0x2
    3a5a:	dd6080e7          	jalr	-554(ra) # 582c <chdir>
    3a5e:	36051663          	bnez	a0,3dca <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    3a62:	00004517          	auipc	a0,0x4
    3a66:	a6e50513          	addi	a0,a0,-1426 # 74d0 <malloc+0x1852>
    3a6a:	00002097          	auipc	ra,0x2
    3a6e:	dc2080e7          	jalr	-574(ra) # 582c <chdir>
    3a72:	36051a63          	bnez	a0,3de6 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    3a76:	00004517          	auipc	a0,0x4
    3a7a:	a8a50513          	addi	a0,a0,-1398 # 7500 <malloc+0x1882>
    3a7e:	00002097          	auipc	ra,0x2
    3a82:	dae080e7          	jalr	-594(ra) # 582c <chdir>
    3a86:	36051e63          	bnez	a0,3e02 <subdir+0x50a>
  if(chdir("./..") != 0){
    3a8a:	00004517          	auipc	a0,0x4
    3a8e:	aa650513          	addi	a0,a0,-1370 # 7530 <malloc+0x18b2>
    3a92:	00002097          	auipc	ra,0x2
    3a96:	d9a080e7          	jalr	-614(ra) # 582c <chdir>
    3a9a:	38051263          	bnez	a0,3e1e <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3a9e:	4581                	li	a1,0
    3aa0:	00004517          	auipc	a0,0x4
    3aa4:	99850513          	addi	a0,a0,-1640 # 7438 <malloc+0x17ba>
    3aa8:	00002097          	auipc	ra,0x2
    3aac:	d54080e7          	jalr	-684(ra) # 57fc <open>
    3ab0:	84aa                	mv	s1,a0
  if(fd < 0){
    3ab2:	38054463          	bltz	a0,3e3a <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3ab6:	660d                	lui	a2,0x3
    3ab8:	00008597          	auipc	a1,0x8
    3abc:	e2858593          	addi	a1,a1,-472 # b8e0 <buf>
    3ac0:	00002097          	auipc	ra,0x2
    3ac4:	d14080e7          	jalr	-748(ra) # 57d4 <read>
    3ac8:	4789                	li	a5,2
    3aca:	38f51663          	bne	a0,a5,3e56 <subdir+0x55e>
  close(fd);
    3ace:	8526                	mv	a0,s1
    3ad0:	00002097          	auipc	ra,0x2
    3ad4:	d14080e7          	jalr	-748(ra) # 57e4 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3ad8:	4581                	li	a1,0
    3ada:	00004517          	auipc	a0,0x4
    3ade:	8d650513          	addi	a0,a0,-1834 # 73b0 <malloc+0x1732>
    3ae2:	00002097          	auipc	ra,0x2
    3ae6:	d1a080e7          	jalr	-742(ra) # 57fc <open>
    3aea:	38055463          	bgez	a0,3e72 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3aee:	20200593          	li	a1,514
    3af2:	00004517          	auipc	a0,0x4
    3af6:	ace50513          	addi	a0,a0,-1330 # 75c0 <malloc+0x1942>
    3afa:	00002097          	auipc	ra,0x2
    3afe:	d02080e7          	jalr	-766(ra) # 57fc <open>
    3b02:	38055663          	bgez	a0,3e8e <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3b06:	20200593          	li	a1,514
    3b0a:	00004517          	auipc	a0,0x4
    3b0e:	ae650513          	addi	a0,a0,-1306 # 75f0 <malloc+0x1972>
    3b12:	00002097          	auipc	ra,0x2
    3b16:	cea080e7          	jalr	-790(ra) # 57fc <open>
    3b1a:	38055863          	bgez	a0,3eaa <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3b1e:	20000593          	li	a1,512
    3b22:	00003517          	auipc	a0,0x3
    3b26:	7ee50513          	addi	a0,a0,2030 # 7310 <malloc+0x1692>
    3b2a:	00002097          	auipc	ra,0x2
    3b2e:	cd2080e7          	jalr	-814(ra) # 57fc <open>
    3b32:	38055a63          	bgez	a0,3ec6 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3b36:	4589                	li	a1,2
    3b38:	00003517          	auipc	a0,0x3
    3b3c:	7d850513          	addi	a0,a0,2008 # 7310 <malloc+0x1692>
    3b40:	00002097          	auipc	ra,0x2
    3b44:	cbc080e7          	jalr	-836(ra) # 57fc <open>
    3b48:	38055d63          	bgez	a0,3ee2 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3b4c:	4585                	li	a1,1
    3b4e:	00003517          	auipc	a0,0x3
    3b52:	7c250513          	addi	a0,a0,1986 # 7310 <malloc+0x1692>
    3b56:	00002097          	auipc	ra,0x2
    3b5a:	ca6080e7          	jalr	-858(ra) # 57fc <open>
    3b5e:	3a055063          	bgez	a0,3efe <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3b62:	00004597          	auipc	a1,0x4
    3b66:	b1e58593          	addi	a1,a1,-1250 # 7680 <malloc+0x1a02>
    3b6a:	00004517          	auipc	a0,0x4
    3b6e:	a5650513          	addi	a0,a0,-1450 # 75c0 <malloc+0x1942>
    3b72:	00002097          	auipc	ra,0x2
    3b76:	caa080e7          	jalr	-854(ra) # 581c <link>
    3b7a:	3a050063          	beqz	a0,3f1a <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3b7e:	00004597          	auipc	a1,0x4
    3b82:	b0258593          	addi	a1,a1,-1278 # 7680 <malloc+0x1a02>
    3b86:	00004517          	auipc	a0,0x4
    3b8a:	a6a50513          	addi	a0,a0,-1430 # 75f0 <malloc+0x1972>
    3b8e:	00002097          	auipc	ra,0x2
    3b92:	c8e080e7          	jalr	-882(ra) # 581c <link>
    3b96:	3a050063          	beqz	a0,3f36 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3b9a:	00004597          	auipc	a1,0x4
    3b9e:	89e58593          	addi	a1,a1,-1890 # 7438 <malloc+0x17ba>
    3ba2:	00003517          	auipc	a0,0x3
    3ba6:	78e50513          	addi	a0,a0,1934 # 7330 <malloc+0x16b2>
    3baa:	00002097          	auipc	ra,0x2
    3bae:	c72080e7          	jalr	-910(ra) # 581c <link>
    3bb2:	3a050063          	beqz	a0,3f52 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3bb6:	00004517          	auipc	a0,0x4
    3bba:	a0a50513          	addi	a0,a0,-1526 # 75c0 <malloc+0x1942>
    3bbe:	00002097          	auipc	ra,0x2
    3bc2:	c66080e7          	jalr	-922(ra) # 5824 <mkdir>
    3bc6:	3a050463          	beqz	a0,3f6e <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3bca:	00004517          	auipc	a0,0x4
    3bce:	a2650513          	addi	a0,a0,-1498 # 75f0 <malloc+0x1972>
    3bd2:	00002097          	auipc	ra,0x2
    3bd6:	c52080e7          	jalr	-942(ra) # 5824 <mkdir>
    3bda:	3a050863          	beqz	a0,3f8a <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3bde:	00004517          	auipc	a0,0x4
    3be2:	85a50513          	addi	a0,a0,-1958 # 7438 <malloc+0x17ba>
    3be6:	00002097          	auipc	ra,0x2
    3bea:	c3e080e7          	jalr	-962(ra) # 5824 <mkdir>
    3bee:	3a050c63          	beqz	a0,3fa6 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3bf2:	00004517          	auipc	a0,0x4
    3bf6:	9fe50513          	addi	a0,a0,-1538 # 75f0 <malloc+0x1972>
    3bfa:	00002097          	auipc	ra,0x2
    3bfe:	c12080e7          	jalr	-1006(ra) # 580c <unlink>
    3c02:	3c050063          	beqz	a0,3fc2 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3c06:	00004517          	auipc	a0,0x4
    3c0a:	9ba50513          	addi	a0,a0,-1606 # 75c0 <malloc+0x1942>
    3c0e:	00002097          	auipc	ra,0x2
    3c12:	bfe080e7          	jalr	-1026(ra) # 580c <unlink>
    3c16:	3c050463          	beqz	a0,3fde <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3c1a:	00003517          	auipc	a0,0x3
    3c1e:	71650513          	addi	a0,a0,1814 # 7330 <malloc+0x16b2>
    3c22:	00002097          	auipc	ra,0x2
    3c26:	c0a080e7          	jalr	-1014(ra) # 582c <chdir>
    3c2a:	3c050863          	beqz	a0,3ffa <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3c2e:	00004517          	auipc	a0,0x4
    3c32:	ba250513          	addi	a0,a0,-1118 # 77d0 <malloc+0x1b52>
    3c36:	00002097          	auipc	ra,0x2
    3c3a:	bf6080e7          	jalr	-1034(ra) # 582c <chdir>
    3c3e:	3c050c63          	beqz	a0,4016 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3c42:	00003517          	auipc	a0,0x3
    3c46:	7f650513          	addi	a0,a0,2038 # 7438 <malloc+0x17ba>
    3c4a:	00002097          	auipc	ra,0x2
    3c4e:	bc2080e7          	jalr	-1086(ra) # 580c <unlink>
    3c52:	3e051063          	bnez	a0,4032 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3c56:	00003517          	auipc	a0,0x3
    3c5a:	6da50513          	addi	a0,a0,1754 # 7330 <malloc+0x16b2>
    3c5e:	00002097          	auipc	ra,0x2
    3c62:	bae080e7          	jalr	-1106(ra) # 580c <unlink>
    3c66:	3e051463          	bnez	a0,404e <subdir+0x756>
  if(unlink("dd") == 0){
    3c6a:	00003517          	auipc	a0,0x3
    3c6e:	6a650513          	addi	a0,a0,1702 # 7310 <malloc+0x1692>
    3c72:	00002097          	auipc	ra,0x2
    3c76:	b9a080e7          	jalr	-1126(ra) # 580c <unlink>
    3c7a:	3e050863          	beqz	a0,406a <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3c7e:	00004517          	auipc	a0,0x4
    3c82:	bc250513          	addi	a0,a0,-1086 # 7840 <malloc+0x1bc2>
    3c86:	00002097          	auipc	ra,0x2
    3c8a:	b86080e7          	jalr	-1146(ra) # 580c <unlink>
    3c8e:	3e054c63          	bltz	a0,4086 <subdir+0x78e>
  if(unlink("dd") < 0){
    3c92:	00003517          	auipc	a0,0x3
    3c96:	67e50513          	addi	a0,a0,1662 # 7310 <malloc+0x1692>
    3c9a:	00002097          	auipc	ra,0x2
    3c9e:	b72080e7          	jalr	-1166(ra) # 580c <unlink>
    3ca2:	40054063          	bltz	a0,40a2 <subdir+0x7aa>
}
    3ca6:	60e2                	ld	ra,24(sp)
    3ca8:	6442                	ld	s0,16(sp)
    3caa:	64a2                	ld	s1,8(sp)
    3cac:	6902                	ld	s2,0(sp)
    3cae:	6105                	addi	sp,sp,32
    3cb0:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3cb2:	85ca                	mv	a1,s2
    3cb4:	00003517          	auipc	a0,0x3
    3cb8:	66450513          	addi	a0,a0,1636 # 7318 <malloc+0x169a>
    3cbc:	00002097          	auipc	ra,0x2
    3cc0:	f04080e7          	jalr	-252(ra) # 5bc0 <printf>
    exit(1);
    3cc4:	4505                	li	a0,1
    3cc6:	00002097          	auipc	ra,0x2
    3cca:	af6080e7          	jalr	-1290(ra) # 57bc <exit>
    printf("%s: create dd/ff failed\n", s);
    3cce:	85ca                	mv	a1,s2
    3cd0:	00003517          	auipc	a0,0x3
    3cd4:	66850513          	addi	a0,a0,1640 # 7338 <malloc+0x16ba>
    3cd8:	00002097          	auipc	ra,0x2
    3cdc:	ee8080e7          	jalr	-280(ra) # 5bc0 <printf>
    exit(1);
    3ce0:	4505                	li	a0,1
    3ce2:	00002097          	auipc	ra,0x2
    3ce6:	ada080e7          	jalr	-1318(ra) # 57bc <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3cea:	85ca                	mv	a1,s2
    3cec:	00003517          	auipc	a0,0x3
    3cf0:	66c50513          	addi	a0,a0,1644 # 7358 <malloc+0x16da>
    3cf4:	00002097          	auipc	ra,0x2
    3cf8:	ecc080e7          	jalr	-308(ra) # 5bc0 <printf>
    exit(1);
    3cfc:	4505                	li	a0,1
    3cfe:	00002097          	auipc	ra,0x2
    3d02:	abe080e7          	jalr	-1346(ra) # 57bc <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3d06:	85ca                	mv	a1,s2
    3d08:	00003517          	auipc	a0,0x3
    3d0c:	68850513          	addi	a0,a0,1672 # 7390 <malloc+0x1712>
    3d10:	00002097          	auipc	ra,0x2
    3d14:	eb0080e7          	jalr	-336(ra) # 5bc0 <printf>
    exit(1);
    3d18:	4505                	li	a0,1
    3d1a:	00002097          	auipc	ra,0x2
    3d1e:	aa2080e7          	jalr	-1374(ra) # 57bc <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3d22:	85ca                	mv	a1,s2
    3d24:	00003517          	auipc	a0,0x3
    3d28:	69c50513          	addi	a0,a0,1692 # 73c0 <malloc+0x1742>
    3d2c:	00002097          	auipc	ra,0x2
    3d30:	e94080e7          	jalr	-364(ra) # 5bc0 <printf>
    exit(1);
    3d34:	4505                	li	a0,1
    3d36:	00002097          	auipc	ra,0x2
    3d3a:	a86080e7          	jalr	-1402(ra) # 57bc <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3d3e:	85ca                	mv	a1,s2
    3d40:	00003517          	auipc	a0,0x3
    3d44:	6b850513          	addi	a0,a0,1720 # 73f8 <malloc+0x177a>
    3d48:	00002097          	auipc	ra,0x2
    3d4c:	e78080e7          	jalr	-392(ra) # 5bc0 <printf>
    exit(1);
    3d50:	4505                	li	a0,1
    3d52:	00002097          	auipc	ra,0x2
    3d56:	a6a080e7          	jalr	-1430(ra) # 57bc <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3d5a:	85ca                	mv	a1,s2
    3d5c:	00003517          	auipc	a0,0x3
    3d60:	6bc50513          	addi	a0,a0,1724 # 7418 <malloc+0x179a>
    3d64:	00002097          	auipc	ra,0x2
    3d68:	e5c080e7          	jalr	-420(ra) # 5bc0 <printf>
    exit(1);
    3d6c:	4505                	li	a0,1
    3d6e:	00002097          	auipc	ra,0x2
    3d72:	a4e080e7          	jalr	-1458(ra) # 57bc <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3d76:	85ca                	mv	a1,s2
    3d78:	00003517          	auipc	a0,0x3
    3d7c:	6d050513          	addi	a0,a0,1744 # 7448 <malloc+0x17ca>
    3d80:	00002097          	auipc	ra,0x2
    3d84:	e40080e7          	jalr	-448(ra) # 5bc0 <printf>
    exit(1);
    3d88:	4505                	li	a0,1
    3d8a:	00002097          	auipc	ra,0x2
    3d8e:	a32080e7          	jalr	-1486(ra) # 57bc <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3d92:	85ca                	mv	a1,s2
    3d94:	00003517          	auipc	a0,0x3
    3d98:	6dc50513          	addi	a0,a0,1756 # 7470 <malloc+0x17f2>
    3d9c:	00002097          	auipc	ra,0x2
    3da0:	e24080e7          	jalr	-476(ra) # 5bc0 <printf>
    exit(1);
    3da4:	4505                	li	a0,1
    3da6:	00002097          	auipc	ra,0x2
    3daa:	a16080e7          	jalr	-1514(ra) # 57bc <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3dae:	85ca                	mv	a1,s2
    3db0:	00003517          	auipc	a0,0x3
    3db4:	6e050513          	addi	a0,a0,1760 # 7490 <malloc+0x1812>
    3db8:	00002097          	auipc	ra,0x2
    3dbc:	e08080e7          	jalr	-504(ra) # 5bc0 <printf>
    exit(1);
    3dc0:	4505                	li	a0,1
    3dc2:	00002097          	auipc	ra,0x2
    3dc6:	9fa080e7          	jalr	-1542(ra) # 57bc <exit>
    printf("%s: chdir dd failed\n", s);
    3dca:	85ca                	mv	a1,s2
    3dcc:	00003517          	auipc	a0,0x3
    3dd0:	6ec50513          	addi	a0,a0,1772 # 74b8 <malloc+0x183a>
    3dd4:	00002097          	auipc	ra,0x2
    3dd8:	dec080e7          	jalr	-532(ra) # 5bc0 <printf>
    exit(1);
    3ddc:	4505                	li	a0,1
    3dde:	00002097          	auipc	ra,0x2
    3de2:	9de080e7          	jalr	-1570(ra) # 57bc <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3de6:	85ca                	mv	a1,s2
    3de8:	00003517          	auipc	a0,0x3
    3dec:	6f850513          	addi	a0,a0,1784 # 74e0 <malloc+0x1862>
    3df0:	00002097          	auipc	ra,0x2
    3df4:	dd0080e7          	jalr	-560(ra) # 5bc0 <printf>
    exit(1);
    3df8:	4505                	li	a0,1
    3dfa:	00002097          	auipc	ra,0x2
    3dfe:	9c2080e7          	jalr	-1598(ra) # 57bc <exit>
    printf("chdir dd/../../dd failed\n", s);
    3e02:	85ca                	mv	a1,s2
    3e04:	00003517          	auipc	a0,0x3
    3e08:	70c50513          	addi	a0,a0,1804 # 7510 <malloc+0x1892>
    3e0c:	00002097          	auipc	ra,0x2
    3e10:	db4080e7          	jalr	-588(ra) # 5bc0 <printf>
    exit(1);
    3e14:	4505                	li	a0,1
    3e16:	00002097          	auipc	ra,0x2
    3e1a:	9a6080e7          	jalr	-1626(ra) # 57bc <exit>
    printf("%s: chdir ./.. failed\n", s);
    3e1e:	85ca                	mv	a1,s2
    3e20:	00003517          	auipc	a0,0x3
    3e24:	71850513          	addi	a0,a0,1816 # 7538 <malloc+0x18ba>
    3e28:	00002097          	auipc	ra,0x2
    3e2c:	d98080e7          	jalr	-616(ra) # 5bc0 <printf>
    exit(1);
    3e30:	4505                	li	a0,1
    3e32:	00002097          	auipc	ra,0x2
    3e36:	98a080e7          	jalr	-1654(ra) # 57bc <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3e3a:	85ca                	mv	a1,s2
    3e3c:	00003517          	auipc	a0,0x3
    3e40:	71450513          	addi	a0,a0,1812 # 7550 <malloc+0x18d2>
    3e44:	00002097          	auipc	ra,0x2
    3e48:	d7c080e7          	jalr	-644(ra) # 5bc0 <printf>
    exit(1);
    3e4c:	4505                	li	a0,1
    3e4e:	00002097          	auipc	ra,0x2
    3e52:	96e080e7          	jalr	-1682(ra) # 57bc <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3e56:	85ca                	mv	a1,s2
    3e58:	00003517          	auipc	a0,0x3
    3e5c:	71850513          	addi	a0,a0,1816 # 7570 <malloc+0x18f2>
    3e60:	00002097          	auipc	ra,0x2
    3e64:	d60080e7          	jalr	-672(ra) # 5bc0 <printf>
    exit(1);
    3e68:	4505                	li	a0,1
    3e6a:	00002097          	auipc	ra,0x2
    3e6e:	952080e7          	jalr	-1710(ra) # 57bc <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3e72:	85ca                	mv	a1,s2
    3e74:	00003517          	auipc	a0,0x3
    3e78:	71c50513          	addi	a0,a0,1820 # 7590 <malloc+0x1912>
    3e7c:	00002097          	auipc	ra,0x2
    3e80:	d44080e7          	jalr	-700(ra) # 5bc0 <printf>
    exit(1);
    3e84:	4505                	li	a0,1
    3e86:	00002097          	auipc	ra,0x2
    3e8a:	936080e7          	jalr	-1738(ra) # 57bc <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3e8e:	85ca                	mv	a1,s2
    3e90:	00003517          	auipc	a0,0x3
    3e94:	74050513          	addi	a0,a0,1856 # 75d0 <malloc+0x1952>
    3e98:	00002097          	auipc	ra,0x2
    3e9c:	d28080e7          	jalr	-728(ra) # 5bc0 <printf>
    exit(1);
    3ea0:	4505                	li	a0,1
    3ea2:	00002097          	auipc	ra,0x2
    3ea6:	91a080e7          	jalr	-1766(ra) # 57bc <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3eaa:	85ca                	mv	a1,s2
    3eac:	00003517          	auipc	a0,0x3
    3eb0:	75450513          	addi	a0,a0,1876 # 7600 <malloc+0x1982>
    3eb4:	00002097          	auipc	ra,0x2
    3eb8:	d0c080e7          	jalr	-756(ra) # 5bc0 <printf>
    exit(1);
    3ebc:	4505                	li	a0,1
    3ebe:	00002097          	auipc	ra,0x2
    3ec2:	8fe080e7          	jalr	-1794(ra) # 57bc <exit>
    printf("%s: create dd succeeded!\n", s);
    3ec6:	85ca                	mv	a1,s2
    3ec8:	00003517          	auipc	a0,0x3
    3ecc:	75850513          	addi	a0,a0,1880 # 7620 <malloc+0x19a2>
    3ed0:	00002097          	auipc	ra,0x2
    3ed4:	cf0080e7          	jalr	-784(ra) # 5bc0 <printf>
    exit(1);
    3ed8:	4505                	li	a0,1
    3eda:	00002097          	auipc	ra,0x2
    3ede:	8e2080e7          	jalr	-1822(ra) # 57bc <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3ee2:	85ca                	mv	a1,s2
    3ee4:	00003517          	auipc	a0,0x3
    3ee8:	75c50513          	addi	a0,a0,1884 # 7640 <malloc+0x19c2>
    3eec:	00002097          	auipc	ra,0x2
    3ef0:	cd4080e7          	jalr	-812(ra) # 5bc0 <printf>
    exit(1);
    3ef4:	4505                	li	a0,1
    3ef6:	00002097          	auipc	ra,0x2
    3efa:	8c6080e7          	jalr	-1850(ra) # 57bc <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3efe:	85ca                	mv	a1,s2
    3f00:	00003517          	auipc	a0,0x3
    3f04:	76050513          	addi	a0,a0,1888 # 7660 <malloc+0x19e2>
    3f08:	00002097          	auipc	ra,0x2
    3f0c:	cb8080e7          	jalr	-840(ra) # 5bc0 <printf>
    exit(1);
    3f10:	4505                	li	a0,1
    3f12:	00002097          	auipc	ra,0x2
    3f16:	8aa080e7          	jalr	-1878(ra) # 57bc <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3f1a:	85ca                	mv	a1,s2
    3f1c:	00003517          	auipc	a0,0x3
    3f20:	77450513          	addi	a0,a0,1908 # 7690 <malloc+0x1a12>
    3f24:	00002097          	auipc	ra,0x2
    3f28:	c9c080e7          	jalr	-868(ra) # 5bc0 <printf>
    exit(1);
    3f2c:	4505                	li	a0,1
    3f2e:	00002097          	auipc	ra,0x2
    3f32:	88e080e7          	jalr	-1906(ra) # 57bc <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3f36:	85ca                	mv	a1,s2
    3f38:	00003517          	auipc	a0,0x3
    3f3c:	78050513          	addi	a0,a0,1920 # 76b8 <malloc+0x1a3a>
    3f40:	00002097          	auipc	ra,0x2
    3f44:	c80080e7          	jalr	-896(ra) # 5bc0 <printf>
    exit(1);
    3f48:	4505                	li	a0,1
    3f4a:	00002097          	auipc	ra,0x2
    3f4e:	872080e7          	jalr	-1934(ra) # 57bc <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3f52:	85ca                	mv	a1,s2
    3f54:	00003517          	auipc	a0,0x3
    3f58:	78c50513          	addi	a0,a0,1932 # 76e0 <malloc+0x1a62>
    3f5c:	00002097          	auipc	ra,0x2
    3f60:	c64080e7          	jalr	-924(ra) # 5bc0 <printf>
    exit(1);
    3f64:	4505                	li	a0,1
    3f66:	00002097          	auipc	ra,0x2
    3f6a:	856080e7          	jalr	-1962(ra) # 57bc <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3f6e:	85ca                	mv	a1,s2
    3f70:	00003517          	auipc	a0,0x3
    3f74:	79850513          	addi	a0,a0,1944 # 7708 <malloc+0x1a8a>
    3f78:	00002097          	auipc	ra,0x2
    3f7c:	c48080e7          	jalr	-952(ra) # 5bc0 <printf>
    exit(1);
    3f80:	4505                	li	a0,1
    3f82:	00002097          	auipc	ra,0x2
    3f86:	83a080e7          	jalr	-1990(ra) # 57bc <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3f8a:	85ca                	mv	a1,s2
    3f8c:	00003517          	auipc	a0,0x3
    3f90:	79c50513          	addi	a0,a0,1948 # 7728 <malloc+0x1aaa>
    3f94:	00002097          	auipc	ra,0x2
    3f98:	c2c080e7          	jalr	-980(ra) # 5bc0 <printf>
    exit(1);
    3f9c:	4505                	li	a0,1
    3f9e:	00002097          	auipc	ra,0x2
    3fa2:	81e080e7          	jalr	-2018(ra) # 57bc <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3fa6:	85ca                	mv	a1,s2
    3fa8:	00003517          	auipc	a0,0x3
    3fac:	7a050513          	addi	a0,a0,1952 # 7748 <malloc+0x1aca>
    3fb0:	00002097          	auipc	ra,0x2
    3fb4:	c10080e7          	jalr	-1008(ra) # 5bc0 <printf>
    exit(1);
    3fb8:	4505                	li	a0,1
    3fba:	00002097          	auipc	ra,0x2
    3fbe:	802080e7          	jalr	-2046(ra) # 57bc <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3fc2:	85ca                	mv	a1,s2
    3fc4:	00003517          	auipc	a0,0x3
    3fc8:	7ac50513          	addi	a0,a0,1964 # 7770 <malloc+0x1af2>
    3fcc:	00002097          	auipc	ra,0x2
    3fd0:	bf4080e7          	jalr	-1036(ra) # 5bc0 <printf>
    exit(1);
    3fd4:	4505                	li	a0,1
    3fd6:	00001097          	auipc	ra,0x1
    3fda:	7e6080e7          	jalr	2022(ra) # 57bc <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3fde:	85ca                	mv	a1,s2
    3fe0:	00003517          	auipc	a0,0x3
    3fe4:	7b050513          	addi	a0,a0,1968 # 7790 <malloc+0x1b12>
    3fe8:	00002097          	auipc	ra,0x2
    3fec:	bd8080e7          	jalr	-1064(ra) # 5bc0 <printf>
    exit(1);
    3ff0:	4505                	li	a0,1
    3ff2:	00001097          	auipc	ra,0x1
    3ff6:	7ca080e7          	jalr	1994(ra) # 57bc <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3ffa:	85ca                	mv	a1,s2
    3ffc:	00003517          	auipc	a0,0x3
    4000:	7b450513          	addi	a0,a0,1972 # 77b0 <malloc+0x1b32>
    4004:	00002097          	auipc	ra,0x2
    4008:	bbc080e7          	jalr	-1092(ra) # 5bc0 <printf>
    exit(1);
    400c:	4505                	li	a0,1
    400e:	00001097          	auipc	ra,0x1
    4012:	7ae080e7          	jalr	1966(ra) # 57bc <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    4016:	85ca                	mv	a1,s2
    4018:	00003517          	auipc	a0,0x3
    401c:	7c050513          	addi	a0,a0,1984 # 77d8 <malloc+0x1b5a>
    4020:	00002097          	auipc	ra,0x2
    4024:	ba0080e7          	jalr	-1120(ra) # 5bc0 <printf>
    exit(1);
    4028:	4505                	li	a0,1
    402a:	00001097          	auipc	ra,0x1
    402e:	792080e7          	jalr	1938(ra) # 57bc <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    4032:	85ca                	mv	a1,s2
    4034:	00003517          	auipc	a0,0x3
    4038:	43c50513          	addi	a0,a0,1084 # 7470 <malloc+0x17f2>
    403c:	00002097          	auipc	ra,0x2
    4040:	b84080e7          	jalr	-1148(ra) # 5bc0 <printf>
    exit(1);
    4044:	4505                	li	a0,1
    4046:	00001097          	auipc	ra,0x1
    404a:	776080e7          	jalr	1910(ra) # 57bc <exit>
    printf("%s: unlink dd/ff failed\n", s);
    404e:	85ca                	mv	a1,s2
    4050:	00003517          	auipc	a0,0x3
    4054:	7a850513          	addi	a0,a0,1960 # 77f8 <malloc+0x1b7a>
    4058:	00002097          	auipc	ra,0x2
    405c:	b68080e7          	jalr	-1176(ra) # 5bc0 <printf>
    exit(1);
    4060:	4505                	li	a0,1
    4062:	00001097          	auipc	ra,0x1
    4066:	75a080e7          	jalr	1882(ra) # 57bc <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    406a:	85ca                	mv	a1,s2
    406c:	00003517          	auipc	a0,0x3
    4070:	7ac50513          	addi	a0,a0,1964 # 7818 <malloc+0x1b9a>
    4074:	00002097          	auipc	ra,0x2
    4078:	b4c080e7          	jalr	-1204(ra) # 5bc0 <printf>
    exit(1);
    407c:	4505                	li	a0,1
    407e:	00001097          	auipc	ra,0x1
    4082:	73e080e7          	jalr	1854(ra) # 57bc <exit>
    printf("%s: unlink dd/dd failed\n", s);
    4086:	85ca                	mv	a1,s2
    4088:	00003517          	auipc	a0,0x3
    408c:	7c050513          	addi	a0,a0,1984 # 7848 <malloc+0x1bca>
    4090:	00002097          	auipc	ra,0x2
    4094:	b30080e7          	jalr	-1232(ra) # 5bc0 <printf>
    exit(1);
    4098:	4505                	li	a0,1
    409a:	00001097          	auipc	ra,0x1
    409e:	722080e7          	jalr	1826(ra) # 57bc <exit>
    printf("%s: unlink dd failed\n", s);
    40a2:	85ca                	mv	a1,s2
    40a4:	00003517          	auipc	a0,0x3
    40a8:	7c450513          	addi	a0,a0,1988 # 7868 <malloc+0x1bea>
    40ac:	00002097          	auipc	ra,0x2
    40b0:	b14080e7          	jalr	-1260(ra) # 5bc0 <printf>
    exit(1);
    40b4:	4505                	li	a0,1
    40b6:	00001097          	auipc	ra,0x1
    40ba:	706080e7          	jalr	1798(ra) # 57bc <exit>

00000000000040be <bigwrite>:
{
    40be:	715d                	addi	sp,sp,-80
    40c0:	e486                	sd	ra,72(sp)
    40c2:	e0a2                	sd	s0,64(sp)
    40c4:	fc26                	sd	s1,56(sp)
    40c6:	f84a                	sd	s2,48(sp)
    40c8:	f44e                	sd	s3,40(sp)
    40ca:	f052                	sd	s4,32(sp)
    40cc:	ec56                	sd	s5,24(sp)
    40ce:	e85a                	sd	s6,16(sp)
    40d0:	e45e                	sd	s7,8(sp)
    40d2:	0880                	addi	s0,sp,80
    40d4:	8baa                	mv	s7,a0
  unlink("bigwrite");
    40d6:	00003517          	auipc	a0,0x3
    40da:	7aa50513          	addi	a0,a0,1962 # 7880 <malloc+0x1c02>
    40de:	00001097          	auipc	ra,0x1
    40e2:	72e080e7          	jalr	1838(ra) # 580c <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
    40e6:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
    40ea:	00003a97          	auipc	s5,0x3
    40ee:	796a8a93          	addi	s5,s5,1942 # 7880 <malloc+0x1c02>
      int cc = write(fd, buf, sz);
    40f2:	00007a17          	auipc	s4,0x7
    40f6:	7eea0a13          	addi	s4,s4,2030 # b8e0 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
    40fa:	6b0d                	lui	s6,0x3
    40fc:	1c9b0b13          	addi	s6,s6,457 # 31c9 <unlinkread+0x12f>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    4100:	20200593          	li	a1,514
    4104:	8556                	mv	a0,s5
    4106:	00001097          	auipc	ra,0x1
    410a:	6f6080e7          	jalr	1782(ra) # 57fc <open>
    410e:	892a                	mv	s2,a0
    if(fd < 0){
    4110:	04054d63          	bltz	a0,416a <bigwrite+0xac>
      int cc = write(fd, buf, sz);
    4114:	8626                	mv	a2,s1
    4116:	85d2                	mv	a1,s4
    4118:	00001097          	auipc	ra,0x1
    411c:	6c4080e7          	jalr	1732(ra) # 57dc <write>
    4120:	89aa                	mv	s3,a0
      if(cc != sz){
    4122:	06a49463          	bne	s1,a0,418a <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
    4126:	8626                	mv	a2,s1
    4128:	85d2                	mv	a1,s4
    412a:	854a                	mv	a0,s2
    412c:	00001097          	auipc	ra,0x1
    4130:	6b0080e7          	jalr	1712(ra) # 57dc <write>
      if(cc != sz){
    4134:	04951963          	bne	a0,s1,4186 <bigwrite+0xc8>
    close(fd);
    4138:	854a                	mv	a0,s2
    413a:	00001097          	auipc	ra,0x1
    413e:	6aa080e7          	jalr	1706(ra) # 57e4 <close>
    unlink("bigwrite");
    4142:	8556                	mv	a0,s5
    4144:	00001097          	auipc	ra,0x1
    4148:	6c8080e7          	jalr	1736(ra) # 580c <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
    414c:	1d74849b          	addiw	s1,s1,471
    4150:	fb6498e3          	bne	s1,s6,4100 <bigwrite+0x42>
}
    4154:	60a6                	ld	ra,72(sp)
    4156:	6406                	ld	s0,64(sp)
    4158:	74e2                	ld	s1,56(sp)
    415a:	7942                	ld	s2,48(sp)
    415c:	79a2                	ld	s3,40(sp)
    415e:	7a02                	ld	s4,32(sp)
    4160:	6ae2                	ld	s5,24(sp)
    4162:	6b42                	ld	s6,16(sp)
    4164:	6ba2                	ld	s7,8(sp)
    4166:	6161                	addi	sp,sp,80
    4168:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
    416a:	85de                	mv	a1,s7
    416c:	00003517          	auipc	a0,0x3
    4170:	72450513          	addi	a0,a0,1828 # 7890 <malloc+0x1c12>
    4174:	00002097          	auipc	ra,0x2
    4178:	a4c080e7          	jalr	-1460(ra) # 5bc0 <printf>
      exit(1);
    417c:	4505                	li	a0,1
    417e:	00001097          	auipc	ra,0x1
    4182:	63e080e7          	jalr	1598(ra) # 57bc <exit>
    4186:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
    4188:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
    418a:	86ce                	mv	a3,s3
    418c:	8626                	mv	a2,s1
    418e:	85de                	mv	a1,s7
    4190:	00003517          	auipc	a0,0x3
    4194:	72050513          	addi	a0,a0,1824 # 78b0 <malloc+0x1c32>
    4198:	00002097          	auipc	ra,0x2
    419c:	a28080e7          	jalr	-1496(ra) # 5bc0 <printf>
        exit(1);
    41a0:	4505                	li	a0,1
    41a2:	00001097          	auipc	ra,0x1
    41a6:	61a080e7          	jalr	1562(ra) # 57bc <exit>

00000000000041aa <manywrites>:
{
    41aa:	711d                	addi	sp,sp,-96
    41ac:	ec86                	sd	ra,88(sp)
    41ae:	e8a2                	sd	s0,80(sp)
    41b0:	e4a6                	sd	s1,72(sp)
    41b2:	e0ca                	sd	s2,64(sp)
    41b4:	fc4e                	sd	s3,56(sp)
    41b6:	f852                	sd	s4,48(sp)
    41b8:	f456                	sd	s5,40(sp)
    41ba:	f05a                	sd	s6,32(sp)
    41bc:	ec5e                	sd	s7,24(sp)
    41be:	1080                	addi	s0,sp,96
    41c0:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    41c2:	4981                	li	s3,0
    41c4:	4911                	li	s2,4
    int pid = fork();
    41c6:	00001097          	auipc	ra,0x1
    41ca:	5ee080e7          	jalr	1518(ra) # 57b4 <fork>
    41ce:	84aa                	mv	s1,a0
    if(pid < 0){
    41d0:	02054963          	bltz	a0,4202 <manywrites+0x58>
    if(pid == 0){
    41d4:	c521                	beqz	a0,421c <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    41d6:	2985                	addiw	s3,s3,1
    41d8:	ff2997e3          	bne	s3,s2,41c6 <manywrites+0x1c>
    41dc:	4491                	li	s1,4
    int st = 0;
    41de:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    41e2:	fa840513          	addi	a0,s0,-88
    41e6:	00001097          	auipc	ra,0x1
    41ea:	5de080e7          	jalr	1502(ra) # 57c4 <wait>
    if(st != 0)
    41ee:	fa842503          	lw	a0,-88(s0)
    41f2:	ed6d                	bnez	a0,42ec <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    41f4:	34fd                	addiw	s1,s1,-1
    41f6:	f4e5                	bnez	s1,41de <manywrites+0x34>
  exit(0);
    41f8:	4501                	li	a0,0
    41fa:	00001097          	auipc	ra,0x1
    41fe:	5c2080e7          	jalr	1474(ra) # 57bc <exit>
      printf("fork failed\n");
    4202:	00004517          	auipc	a0,0x4
    4206:	aa650513          	addi	a0,a0,-1370 # 7ca8 <malloc+0x202a>
    420a:	00002097          	auipc	ra,0x2
    420e:	9b6080e7          	jalr	-1610(ra) # 5bc0 <printf>
      exit(1);
    4212:	4505                	li	a0,1
    4214:	00001097          	auipc	ra,0x1
    4218:	5a8080e7          	jalr	1448(ra) # 57bc <exit>
      name[0] = 'b';
    421c:	06200793          	li	a5,98
    4220:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    4224:	0619879b          	addiw	a5,s3,97
    4228:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    422c:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    4230:	fa840513          	addi	a0,s0,-88
    4234:	00001097          	auipc	ra,0x1
    4238:	5d8080e7          	jalr	1496(ra) # 580c <unlink>
    423c:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    423e:	00007b17          	auipc	s6,0x7
    4242:	6a2b0b13          	addi	s6,s6,1698 # b8e0 <buf>
        for(int i = 0; i < ci+1; i++){
    4246:	8a26                	mv	s4,s1
    4248:	0209ce63          	bltz	s3,4284 <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    424c:	20200593          	li	a1,514
    4250:	fa840513          	addi	a0,s0,-88
    4254:	00001097          	auipc	ra,0x1
    4258:	5a8080e7          	jalr	1448(ra) # 57fc <open>
    425c:	892a                	mv	s2,a0
          if(fd < 0){
    425e:	04054763          	bltz	a0,42ac <manywrites+0x102>
          int cc = write(fd, buf, sz);
    4262:	660d                	lui	a2,0x3
    4264:	85da                	mv	a1,s6
    4266:	00001097          	auipc	ra,0x1
    426a:	576080e7          	jalr	1398(ra) # 57dc <write>
          if(cc != sz){
    426e:	678d                	lui	a5,0x3
    4270:	04f51e63          	bne	a0,a5,42cc <manywrites+0x122>
          close(fd);
    4274:	854a                	mv	a0,s2
    4276:	00001097          	auipc	ra,0x1
    427a:	56e080e7          	jalr	1390(ra) # 57e4 <close>
        for(int i = 0; i < ci+1; i++){
    427e:	2a05                	addiw	s4,s4,1
    4280:	fd49d6e3          	bge	s3,s4,424c <manywrites+0xa2>
        unlink(name);
    4284:	fa840513          	addi	a0,s0,-88
    4288:	00001097          	auipc	ra,0x1
    428c:	584080e7          	jalr	1412(ra) # 580c <unlink>
      for(int iters = 0; iters < howmany; iters++){
    4290:	3bfd                	addiw	s7,s7,-1
    4292:	fa0b9ae3          	bnez	s7,4246 <manywrites+0x9c>
      unlink(name);
    4296:	fa840513          	addi	a0,s0,-88
    429a:	00001097          	auipc	ra,0x1
    429e:	572080e7          	jalr	1394(ra) # 580c <unlink>
      exit(0);
    42a2:	4501                	li	a0,0
    42a4:	00001097          	auipc	ra,0x1
    42a8:	518080e7          	jalr	1304(ra) # 57bc <exit>
            printf("%s: cannot create %s\n", s, name);
    42ac:	fa840613          	addi	a2,s0,-88
    42b0:	85d6                	mv	a1,s5
    42b2:	00003517          	auipc	a0,0x3
    42b6:	61650513          	addi	a0,a0,1558 # 78c8 <malloc+0x1c4a>
    42ba:	00002097          	auipc	ra,0x2
    42be:	906080e7          	jalr	-1786(ra) # 5bc0 <printf>
            exit(1);
    42c2:	4505                	li	a0,1
    42c4:	00001097          	auipc	ra,0x1
    42c8:	4f8080e7          	jalr	1272(ra) # 57bc <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    42cc:	86aa                	mv	a3,a0
    42ce:	660d                	lui	a2,0x3
    42d0:	85d6                	mv	a1,s5
    42d2:	00003517          	auipc	a0,0x3
    42d6:	5de50513          	addi	a0,a0,1502 # 78b0 <malloc+0x1c32>
    42da:	00002097          	auipc	ra,0x2
    42de:	8e6080e7          	jalr	-1818(ra) # 5bc0 <printf>
            exit(1);
    42e2:	4505                	li	a0,1
    42e4:	00001097          	auipc	ra,0x1
    42e8:	4d8080e7          	jalr	1240(ra) # 57bc <exit>
      exit(st);
    42ec:	00001097          	auipc	ra,0x1
    42f0:	4d0080e7          	jalr	1232(ra) # 57bc <exit>

00000000000042f4 <sbrkbasic>:

void
sbrkbasic(char *s)
{
    42f4:	7139                	addi	sp,sp,-64
    42f6:	fc06                	sd	ra,56(sp)
    42f8:	f822                	sd	s0,48(sp)
    42fa:	f426                	sd	s1,40(sp)
    42fc:	f04a                	sd	s2,32(sp)
    42fe:	ec4e                	sd	s3,24(sp)
    4300:	e852                	sd	s4,16(sp)
    4302:	0080                	addi	s0,sp,64
    4304:	8a2a                	mv	s4,a0
  enum { TOOMUCH=1024*1024*1024};
  int i, pid, xstatus;
  char *c, *a, *b;

  // does sbrk() return the expected failure value?
  pid = fork();
    4306:	00001097          	auipc	ra,0x1
    430a:	4ae080e7          	jalr	1198(ra) # 57b4 <fork>
  if(pid < 0){
    430e:	02054c63          	bltz	a0,4346 <sbrkbasic+0x52>
    printf("fork failed in sbrkbasic\n");
    exit(1);
  }
  if(pid == 0){
    4312:	ed21                	bnez	a0,436a <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    4314:	40000537          	lui	a0,0x40000
    4318:	00001097          	auipc	ra,0x1
    431c:	52c080e7          	jalr	1324(ra) # 5844 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    4320:	57fd                	li	a5,-1
    4322:	02f50f63          	beq	a0,a5,4360 <sbrkbasic+0x6c>
      // it's OK if this fails.
      exit(0);
    }
    
    for(b = a; b < a+TOOMUCH; b += 4096){
    4326:	400007b7          	lui	a5,0x40000
    432a:	97aa                	add	a5,a5,a0
      *b = 99;
    432c:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    4330:	6705                	lui	a4,0x1
      *b = 99;
    4332:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1710>
    for(b = a; b < a+TOOMUCH; b += 4096){
    4336:	953a                	add	a0,a0,a4
    4338:	fef51de3          	bne	a0,a5,4332 <sbrkbasic+0x3e>
    }
    
    // we should not get here! either sbrk(TOOMUCH)
    // should have failed, or (with lazy allocation)
    // a pagefault should have killed this process.
    exit(1);
    433c:	4505                	li	a0,1
    433e:	00001097          	auipc	ra,0x1
    4342:	47e080e7          	jalr	1150(ra) # 57bc <exit>
    printf("fork failed in sbrkbasic\n");
    4346:	00003517          	auipc	a0,0x3
    434a:	59a50513          	addi	a0,a0,1434 # 78e0 <malloc+0x1c62>
    434e:	00002097          	auipc	ra,0x2
    4352:	872080e7          	jalr	-1934(ra) # 5bc0 <printf>
    exit(1);
    4356:	4505                	li	a0,1
    4358:	00001097          	auipc	ra,0x1
    435c:	464080e7          	jalr	1124(ra) # 57bc <exit>
      exit(0);
    4360:	4501                	li	a0,0
    4362:	00001097          	auipc	ra,0x1
    4366:	45a080e7          	jalr	1114(ra) # 57bc <exit>
  }

  wait(&xstatus);
    436a:	fcc40513          	addi	a0,s0,-52
    436e:	00001097          	auipc	ra,0x1
    4372:	456080e7          	jalr	1110(ra) # 57c4 <wait>
  if(xstatus == 1){
    4376:	fcc42703          	lw	a4,-52(s0)
    437a:	4785                	li	a5,1
    437c:	00f70d63          	beq	a4,a5,4396 <sbrkbasic+0xa2>
    printf("%s: too much memory allocated!\n", s);
    exit(1);
  }

  // can one sbrk() less than a page?
  a = sbrk(0);
    4380:	4501                	li	a0,0
    4382:	00001097          	auipc	ra,0x1
    4386:	4c2080e7          	jalr	1218(ra) # 5844 <sbrk>
    438a:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    438c:	4901                	li	s2,0
    438e:	6985                	lui	s3,0x1
    4390:	38898993          	addi	s3,s3,904 # 1388 <mem+0x66>
    4394:	a005                	j	43b4 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    4396:	85d2                	mv	a1,s4
    4398:	00003517          	auipc	a0,0x3
    439c:	56850513          	addi	a0,a0,1384 # 7900 <malloc+0x1c82>
    43a0:	00002097          	auipc	ra,0x2
    43a4:	820080e7          	jalr	-2016(ra) # 5bc0 <printf>
    exit(1);
    43a8:	4505                	li	a0,1
    43aa:	00001097          	auipc	ra,0x1
    43ae:	412080e7          	jalr	1042(ra) # 57bc <exit>
    if(b != a){
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
      exit(1);
    }
    *b = 1;
    a = b + 1;
    43b2:	84be                	mv	s1,a5
    b = sbrk(1);
    43b4:	4505                	li	a0,1
    43b6:	00001097          	auipc	ra,0x1
    43ba:	48e080e7          	jalr	1166(ra) # 5844 <sbrk>
    if(b != a){
    43be:	04951c63          	bne	a0,s1,4416 <sbrkbasic+0x122>
    *b = 1;
    43c2:	4785                	li	a5,1
    43c4:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    43c8:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    43cc:	2905                	addiw	s2,s2,1
    43ce:	ff3912e3          	bne	s2,s3,43b2 <sbrkbasic+0xbe>
  }
  pid = fork();
    43d2:	00001097          	auipc	ra,0x1
    43d6:	3e2080e7          	jalr	994(ra) # 57b4 <fork>
    43da:	892a                	mv	s2,a0
  if(pid < 0){
    43dc:	04054d63          	bltz	a0,4436 <sbrkbasic+0x142>
    printf("%s: sbrk test fork failed\n", s);
    exit(1);
  }
  c = sbrk(1);
    43e0:	4505                	li	a0,1
    43e2:	00001097          	auipc	ra,0x1
    43e6:	462080e7          	jalr	1122(ra) # 5844 <sbrk>
  c = sbrk(1);
    43ea:	4505                	li	a0,1
    43ec:	00001097          	auipc	ra,0x1
    43f0:	458080e7          	jalr	1112(ra) # 5844 <sbrk>
  if(c != a + 1){
    43f4:	0489                	addi	s1,s1,2
    43f6:	04a48e63          	beq	s1,a0,4452 <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    43fa:	85d2                	mv	a1,s4
    43fc:	00003517          	auipc	a0,0x3
    4400:	56450513          	addi	a0,a0,1380 # 7960 <malloc+0x1ce2>
    4404:	00001097          	auipc	ra,0x1
    4408:	7bc080e7          	jalr	1980(ra) # 5bc0 <printf>
    exit(1);
    440c:	4505                	li	a0,1
    440e:	00001097          	auipc	ra,0x1
    4412:	3ae080e7          	jalr	942(ra) # 57bc <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    4416:	86aa                	mv	a3,a0
    4418:	8626                	mv	a2,s1
    441a:	85ca                	mv	a1,s2
    441c:	00003517          	auipc	a0,0x3
    4420:	50450513          	addi	a0,a0,1284 # 7920 <malloc+0x1ca2>
    4424:	00001097          	auipc	ra,0x1
    4428:	79c080e7          	jalr	1948(ra) # 5bc0 <printf>
      exit(1);
    442c:	4505                	li	a0,1
    442e:	00001097          	auipc	ra,0x1
    4432:	38e080e7          	jalr	910(ra) # 57bc <exit>
    printf("%s: sbrk test fork failed\n", s);
    4436:	85d2                	mv	a1,s4
    4438:	00003517          	auipc	a0,0x3
    443c:	50850513          	addi	a0,a0,1288 # 7940 <malloc+0x1cc2>
    4440:	00001097          	auipc	ra,0x1
    4444:	780080e7          	jalr	1920(ra) # 5bc0 <printf>
    exit(1);
    4448:	4505                	li	a0,1
    444a:	00001097          	auipc	ra,0x1
    444e:	372080e7          	jalr	882(ra) # 57bc <exit>
  }
  if(pid == 0)
    4452:	00091763          	bnez	s2,4460 <sbrkbasic+0x16c>
    exit(0);
    4456:	4501                	li	a0,0
    4458:	00001097          	auipc	ra,0x1
    445c:	364080e7          	jalr	868(ra) # 57bc <exit>
  wait(&xstatus);
    4460:	fcc40513          	addi	a0,s0,-52
    4464:	00001097          	auipc	ra,0x1
    4468:	360080e7          	jalr	864(ra) # 57c4 <wait>
  exit(xstatus);
    446c:	fcc42503          	lw	a0,-52(s0)
    4470:	00001097          	auipc	ra,0x1
    4474:	34c080e7          	jalr	844(ra) # 57bc <exit>

0000000000004478 <sbrkmuch>:
}

void
sbrkmuch(char *s)
{
    4478:	7179                	addi	sp,sp,-48
    447a:	f406                	sd	ra,40(sp)
    447c:	f022                	sd	s0,32(sp)
    447e:	ec26                	sd	s1,24(sp)
    4480:	e84a                	sd	s2,16(sp)
    4482:	e44e                	sd	s3,8(sp)
    4484:	e052                	sd	s4,0(sp)
    4486:	1800                	addi	s0,sp,48
    4488:	89aa                	mv	s3,a0
  enum { BIG=100*1024*1024 };
  char *c, *oldbrk, *a, *lastaddr, *p;
  uint64 amt;

  oldbrk = sbrk(0);
    448a:	4501                	li	a0,0
    448c:	00001097          	auipc	ra,0x1
    4490:	3b8080e7          	jalr	952(ra) # 5844 <sbrk>
    4494:	892a                	mv	s2,a0

  // can one grow address space to something big?
  a = sbrk(0);
    4496:	4501                	li	a0,0
    4498:	00001097          	auipc	ra,0x1
    449c:	3ac080e7          	jalr	940(ra) # 5844 <sbrk>
    44a0:	84aa                	mv	s1,a0
  amt = BIG - (uint64)a;
  p = sbrk(amt);
    44a2:	06400537          	lui	a0,0x6400
    44a6:	9d05                	subw	a0,a0,s1
    44a8:	00001097          	auipc	ra,0x1
    44ac:	39c080e7          	jalr	924(ra) # 5844 <sbrk>
  if (p != a) {
    44b0:	0ca49863          	bne	s1,a0,4580 <sbrkmuch+0x108>
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    exit(1);
  }

  // touch each page to make sure it exists.
  char *eee = sbrk(0);
    44b4:	4501                	li	a0,0
    44b6:	00001097          	auipc	ra,0x1
    44ba:	38e080e7          	jalr	910(ra) # 5844 <sbrk>
    44be:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    44c0:	00a4f963          	bgeu	s1,a0,44d2 <sbrkmuch+0x5a>
    *pp = 1;
    44c4:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    44c6:	6705                	lui	a4,0x1
    *pp = 1;
    44c8:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    44cc:	94ba                	add	s1,s1,a4
    44ce:	fef4ede3          	bltu	s1,a5,44c8 <sbrkmuch+0x50>

  lastaddr = (char*) (BIG-1);
  *lastaddr = 99;
    44d2:	064007b7          	lui	a5,0x6400
    44d6:	06300713          	li	a4,99
    44da:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f170f>

  // can one de-allocate?
  a = sbrk(0);
    44de:	4501                	li	a0,0
    44e0:	00001097          	auipc	ra,0x1
    44e4:	364080e7          	jalr	868(ra) # 5844 <sbrk>
    44e8:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    44ea:	757d                	lui	a0,0xfffff
    44ec:	00001097          	auipc	ra,0x1
    44f0:	358080e7          	jalr	856(ra) # 5844 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    44f4:	57fd                	li	a5,-1
    44f6:	0af50363          	beq	a0,a5,459c <sbrkmuch+0x124>
    printf("%s: sbrk could not deallocate\n", s);
    exit(1);
  }
  c = sbrk(0);
    44fa:	4501                	li	a0,0
    44fc:	00001097          	auipc	ra,0x1
    4500:	348080e7          	jalr	840(ra) # 5844 <sbrk>
  if(c != a - PGSIZE){
    4504:	77fd                	lui	a5,0xfffff
    4506:	97a6                	add	a5,a5,s1
    4508:	0af51863          	bne	a0,a5,45b8 <sbrkmuch+0x140>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    exit(1);
  }

  // can one re-allocate that page?
  a = sbrk(0);
    450c:	4501                	li	a0,0
    450e:	00001097          	auipc	ra,0x1
    4512:	336080e7          	jalr	822(ra) # 5844 <sbrk>
    4516:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    4518:	6505                	lui	a0,0x1
    451a:	00001097          	auipc	ra,0x1
    451e:	32a080e7          	jalr	810(ra) # 5844 <sbrk>
    4522:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    4524:	0aa49a63          	bne	s1,a0,45d8 <sbrkmuch+0x160>
    4528:	4501                	li	a0,0
    452a:	00001097          	auipc	ra,0x1
    452e:	31a080e7          	jalr	794(ra) # 5844 <sbrk>
    4532:	6785                	lui	a5,0x1
    4534:	97a6                	add	a5,a5,s1
    4536:	0af51163          	bne	a0,a5,45d8 <sbrkmuch+0x160>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    exit(1);
  }
  if(*lastaddr == 99){
    453a:	064007b7          	lui	a5,0x6400
    453e:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f170f>
    4542:	06300793          	li	a5,99
    4546:	0af70963          	beq	a4,a5,45f8 <sbrkmuch+0x180>
    // should be zero
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    exit(1);
  }

  a = sbrk(0);
    454a:	4501                	li	a0,0
    454c:	00001097          	auipc	ra,0x1
    4550:	2f8080e7          	jalr	760(ra) # 5844 <sbrk>
    4554:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    4556:	4501                	li	a0,0
    4558:	00001097          	auipc	ra,0x1
    455c:	2ec080e7          	jalr	748(ra) # 5844 <sbrk>
    4560:	40a9053b          	subw	a0,s2,a0
    4564:	00001097          	auipc	ra,0x1
    4568:	2e0080e7          	jalr	736(ra) # 5844 <sbrk>
  if(c != a){
    456c:	0aa49463          	bne	s1,a0,4614 <sbrkmuch+0x19c>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    exit(1);
  }
}
    4570:	70a2                	ld	ra,40(sp)
    4572:	7402                	ld	s0,32(sp)
    4574:	64e2                	ld	s1,24(sp)
    4576:	6942                	ld	s2,16(sp)
    4578:	69a2                	ld	s3,8(sp)
    457a:	6a02                	ld	s4,0(sp)
    457c:	6145                	addi	sp,sp,48
    457e:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    4580:	85ce                	mv	a1,s3
    4582:	00003517          	auipc	a0,0x3
    4586:	3fe50513          	addi	a0,a0,1022 # 7980 <malloc+0x1d02>
    458a:	00001097          	auipc	ra,0x1
    458e:	636080e7          	jalr	1590(ra) # 5bc0 <printf>
    exit(1);
    4592:	4505                	li	a0,1
    4594:	00001097          	auipc	ra,0x1
    4598:	228080e7          	jalr	552(ra) # 57bc <exit>
    printf("%s: sbrk could not deallocate\n", s);
    459c:	85ce                	mv	a1,s3
    459e:	00003517          	auipc	a0,0x3
    45a2:	42a50513          	addi	a0,a0,1066 # 79c8 <malloc+0x1d4a>
    45a6:	00001097          	auipc	ra,0x1
    45aa:	61a080e7          	jalr	1562(ra) # 5bc0 <printf>
    exit(1);
    45ae:	4505                	li	a0,1
    45b0:	00001097          	auipc	ra,0x1
    45b4:	20c080e7          	jalr	524(ra) # 57bc <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    45b8:	86aa                	mv	a3,a0
    45ba:	8626                	mv	a2,s1
    45bc:	85ce                	mv	a1,s3
    45be:	00003517          	auipc	a0,0x3
    45c2:	42a50513          	addi	a0,a0,1066 # 79e8 <malloc+0x1d6a>
    45c6:	00001097          	auipc	ra,0x1
    45ca:	5fa080e7          	jalr	1530(ra) # 5bc0 <printf>
    exit(1);
    45ce:	4505                	li	a0,1
    45d0:	00001097          	auipc	ra,0x1
    45d4:	1ec080e7          	jalr	492(ra) # 57bc <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    45d8:	86d2                	mv	a3,s4
    45da:	8626                	mv	a2,s1
    45dc:	85ce                	mv	a1,s3
    45de:	00003517          	auipc	a0,0x3
    45e2:	44a50513          	addi	a0,a0,1098 # 7a28 <malloc+0x1daa>
    45e6:	00001097          	auipc	ra,0x1
    45ea:	5da080e7          	jalr	1498(ra) # 5bc0 <printf>
    exit(1);
    45ee:	4505                	li	a0,1
    45f0:	00001097          	auipc	ra,0x1
    45f4:	1cc080e7          	jalr	460(ra) # 57bc <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    45f8:	85ce                	mv	a1,s3
    45fa:	00003517          	auipc	a0,0x3
    45fe:	45e50513          	addi	a0,a0,1118 # 7a58 <malloc+0x1dda>
    4602:	00001097          	auipc	ra,0x1
    4606:	5be080e7          	jalr	1470(ra) # 5bc0 <printf>
    exit(1);
    460a:	4505                	li	a0,1
    460c:	00001097          	auipc	ra,0x1
    4610:	1b0080e7          	jalr	432(ra) # 57bc <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    4614:	86aa                	mv	a3,a0
    4616:	8626                	mv	a2,s1
    4618:	85ce                	mv	a1,s3
    461a:	00003517          	auipc	a0,0x3
    461e:	47650513          	addi	a0,a0,1142 # 7a90 <malloc+0x1e12>
    4622:	00001097          	auipc	ra,0x1
    4626:	59e080e7          	jalr	1438(ra) # 5bc0 <printf>
    exit(1);
    462a:	4505                	li	a0,1
    462c:	00001097          	auipc	ra,0x1
    4630:	190080e7          	jalr	400(ra) # 57bc <exit>

0000000000004634 <kernmem>:

// can we read the kernel's memory?
void
kernmem(char *s)
{
    4634:	715d                	addi	sp,sp,-80
    4636:	e486                	sd	ra,72(sp)
    4638:	e0a2                	sd	s0,64(sp)
    463a:	fc26                	sd	s1,56(sp)
    463c:	f84a                	sd	s2,48(sp)
    463e:	f44e                	sd	s3,40(sp)
    4640:	f052                	sd	s4,32(sp)
    4642:	ec56                	sd	s5,24(sp)
    4644:	0880                	addi	s0,sp,80
    4646:	8a2a                	mv	s4,a0
  char *a;
  int pid;

  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    4648:	4485                	li	s1,1
    464a:	04fe                	slli	s1,s1,0x1f
      printf("%s: oops could read %x = %x\n", s, a, *a);
      exit(1);
    }
    int xstatus;
    wait(&xstatus);
    if(xstatus != -1)  // did kernel kill child?
    464c:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    464e:	69b1                	lui	s3,0xc
    4650:	35098993          	addi	s3,s3,848 # c350 <buf+0xa70>
    4654:	1003d937          	lui	s2,0x1003d
    4658:	090e                	slli	s2,s2,0x3
    465a:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002eb90>
    pid = fork();
    465e:	00001097          	auipc	ra,0x1
    4662:	156080e7          	jalr	342(ra) # 57b4 <fork>
    if(pid < 0){
    4666:	02054963          	bltz	a0,4698 <kernmem+0x64>
    if(pid == 0){
    466a:	c529                	beqz	a0,46b4 <kernmem+0x80>
    wait(&xstatus);
    466c:	fbc40513          	addi	a0,s0,-68
    4670:	00001097          	auipc	ra,0x1
    4674:	154080e7          	jalr	340(ra) # 57c4 <wait>
    if(xstatus != -1)  // did kernel kill child?
    4678:	fbc42783          	lw	a5,-68(s0)
    467c:	05579d63          	bne	a5,s5,46d6 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    4680:	94ce                	add	s1,s1,s3
    4682:	fd249ee3          	bne	s1,s2,465e <kernmem+0x2a>
      exit(1);
  }
}
    4686:	60a6                	ld	ra,72(sp)
    4688:	6406                	ld	s0,64(sp)
    468a:	74e2                	ld	s1,56(sp)
    468c:	7942                	ld	s2,48(sp)
    468e:	79a2                	ld	s3,40(sp)
    4690:	7a02                	ld	s4,32(sp)
    4692:	6ae2                	ld	s5,24(sp)
    4694:	6161                	addi	sp,sp,80
    4696:	8082                	ret
      printf("%s: fork failed\n", s);
    4698:	85d2                	mv	a1,s4
    469a:	00001517          	auipc	a0,0x1
    469e:	7e650513          	addi	a0,a0,2022 # 5e80 <malloc+0x202>
    46a2:	00001097          	auipc	ra,0x1
    46a6:	51e080e7          	jalr	1310(ra) # 5bc0 <printf>
      exit(1);
    46aa:	4505                	li	a0,1
    46ac:	00001097          	auipc	ra,0x1
    46b0:	110080e7          	jalr	272(ra) # 57bc <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    46b4:	0004c683          	lbu	a3,0(s1)
    46b8:	8626                	mv	a2,s1
    46ba:	85d2                	mv	a1,s4
    46bc:	00003517          	auipc	a0,0x3
    46c0:	3fc50513          	addi	a0,a0,1020 # 7ab8 <malloc+0x1e3a>
    46c4:	00001097          	auipc	ra,0x1
    46c8:	4fc080e7          	jalr	1276(ra) # 5bc0 <printf>
      exit(1);
    46cc:	4505                	li	a0,1
    46ce:	00001097          	auipc	ra,0x1
    46d2:	0ee080e7          	jalr	238(ra) # 57bc <exit>
      exit(1);
    46d6:	4505                	li	a0,1
    46d8:	00001097          	auipc	ra,0x1
    46dc:	0e4080e7          	jalr	228(ra) # 57bc <exit>

00000000000046e0 <sbrkfail>:

// if we run the system out of memory, does it clean up the last
// failed allocation?
void
sbrkfail(char *s)
{
    46e0:	7119                	addi	sp,sp,-128
    46e2:	fc86                	sd	ra,120(sp)
    46e4:	f8a2                	sd	s0,112(sp)
    46e6:	f4a6                	sd	s1,104(sp)
    46e8:	f0ca                	sd	s2,96(sp)
    46ea:	ecce                	sd	s3,88(sp)
    46ec:	e8d2                	sd	s4,80(sp)
    46ee:	e4d6                	sd	s5,72(sp)
    46f0:	0100                	addi	s0,sp,128
    46f2:	8aaa                	mv	s5,a0
  char scratch;
  char *c, *a;
  int pids[10];
  int pid;
 
  if(pipe(fds) != 0){
    46f4:	fb040513          	addi	a0,s0,-80
    46f8:	00001097          	auipc	ra,0x1
    46fc:	0d4080e7          	jalr	212(ra) # 57cc <pipe>
    4700:	e901                	bnez	a0,4710 <sbrkfail+0x30>
    4702:	f8040493          	addi	s1,s0,-128
    4706:	fa840993          	addi	s3,s0,-88
    470a:	8926                	mv	s2,s1
      sbrk(BIG - (uint64)sbrk(0));
      write(fds[1], "x", 1);
      // sit around until killed
      for(;;) sleep(1000);
    }
    if(pids[i] != -1)
    470c:	5a7d                	li	s4,-1
    470e:	a085                	j	476e <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    4710:	85d6                	mv	a1,s5
    4712:	00002517          	auipc	a0,0x2
    4716:	a6650513          	addi	a0,a0,-1434 # 6178 <malloc+0x4fa>
    471a:	00001097          	auipc	ra,0x1
    471e:	4a6080e7          	jalr	1190(ra) # 5bc0 <printf>
    exit(1);
    4722:	4505                	li	a0,1
    4724:	00001097          	auipc	ra,0x1
    4728:	098080e7          	jalr	152(ra) # 57bc <exit>
      sbrk(BIG - (uint64)sbrk(0));
    472c:	00001097          	auipc	ra,0x1
    4730:	118080e7          	jalr	280(ra) # 5844 <sbrk>
    4734:	064007b7          	lui	a5,0x6400
    4738:	40a7853b          	subw	a0,a5,a0
    473c:	00001097          	auipc	ra,0x1
    4740:	108080e7          	jalr	264(ra) # 5844 <sbrk>
      write(fds[1], "x", 1);
    4744:	4605                	li	a2,1
    4746:	00002597          	auipc	a1,0x2
    474a:	06258593          	addi	a1,a1,98 # 67a8 <malloc+0xb2a>
    474e:	fb442503          	lw	a0,-76(s0)
    4752:	00001097          	auipc	ra,0x1
    4756:	08a080e7          	jalr	138(ra) # 57dc <write>
      for(;;) sleep(1000);
    475a:	3e800513          	li	a0,1000
    475e:	00001097          	auipc	ra,0x1
    4762:	0ee080e7          	jalr	238(ra) # 584c <sleep>
    4766:	bfd5                	j	475a <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4768:	0911                	addi	s2,s2,4
    476a:	03390563          	beq	s2,s3,4794 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    476e:	00001097          	auipc	ra,0x1
    4772:	046080e7          	jalr	70(ra) # 57b4 <fork>
    4776:	00a92023          	sw	a0,0(s2)
    477a:	d94d                	beqz	a0,472c <sbrkfail+0x4c>
    if(pids[i] != -1)
    477c:	ff4506e3          	beq	a0,s4,4768 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4780:	4605                	li	a2,1
    4782:	faf40593          	addi	a1,s0,-81
    4786:	fb042503          	lw	a0,-80(s0)
    478a:	00001097          	auipc	ra,0x1
    478e:	04a080e7          	jalr	74(ra) # 57d4 <read>
    4792:	bfd9                	j	4768 <sbrkfail+0x88>
  }

  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(PGSIZE);
    4794:	6505                	lui	a0,0x1
    4796:	00001097          	auipc	ra,0x1
    479a:	0ae080e7          	jalr	174(ra) # 5844 <sbrk>
    479e:	8a2a                	mv	s4,a0
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if(pids[i] == -1)
    47a0:	597d                	li	s2,-1
    47a2:	a021                	j	47aa <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    47a4:	0491                	addi	s1,s1,4
    47a6:	03348063          	beq	s1,s3,47c6 <sbrkfail+0xe6>
    if(pids[i] == -1)
    47aa:	4088                	lw	a0,0(s1)
    47ac:	ff250ce3          	beq	a0,s2,47a4 <sbrkfail+0xc4>
      continue;
    kill(pids[i], SIGKILL);
    47b0:	45a5                	li	a1,9
    47b2:	00001097          	auipc	ra,0x1
    47b6:	03a080e7          	jalr	58(ra) # 57ec <kill>
    wait(0);
    47ba:	4501                	li	a0,0
    47bc:	00001097          	auipc	ra,0x1
    47c0:	008080e7          	jalr	8(ra) # 57c4 <wait>
    47c4:	b7c5                	j	47a4 <sbrkfail+0xc4>
  }
  if(c == (char*)0xffffffffffffffffL){
    47c6:	57fd                	li	a5,-1
    47c8:	04fa0163          	beq	s4,a5,480a <sbrkfail+0x12a>
    printf("%s: failed sbrk leaked memory\n", s);
    exit(1);
  }

  // test running fork with the above allocated page 
  pid = fork();
    47cc:	00001097          	auipc	ra,0x1
    47d0:	fe8080e7          	jalr	-24(ra) # 57b4 <fork>
    47d4:	84aa                	mv	s1,a0
  if(pid < 0){
    47d6:	04054863          	bltz	a0,4826 <sbrkfail+0x146>
    printf("%s: fork failed\n", s);
    exit(1);
  }
  if(pid == 0){
    47da:	c525                	beqz	a0,4842 <sbrkfail+0x162>
    // print n so the compiler doesn't optimize away
    // the for loop.
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    exit(1);
  }
  wait(&xstatus);
    47dc:	fbc40513          	addi	a0,s0,-68
    47e0:	00001097          	auipc	ra,0x1
    47e4:	fe4080e7          	jalr	-28(ra) # 57c4 <wait>
  if(xstatus != -1 && xstatus != 2)
    47e8:	fbc42783          	lw	a5,-68(s0)
    47ec:	577d                	li	a4,-1
    47ee:	00e78563          	beq	a5,a4,47f8 <sbrkfail+0x118>
    47f2:	4709                	li	a4,2
    47f4:	08e79d63          	bne	a5,a4,488e <sbrkfail+0x1ae>
    exit(1);
}
    47f8:	70e6                	ld	ra,120(sp)
    47fa:	7446                	ld	s0,112(sp)
    47fc:	74a6                	ld	s1,104(sp)
    47fe:	7906                	ld	s2,96(sp)
    4800:	69e6                	ld	s3,88(sp)
    4802:	6a46                	ld	s4,80(sp)
    4804:	6aa6                	ld	s5,72(sp)
    4806:	6109                	addi	sp,sp,128
    4808:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    480a:	85d6                	mv	a1,s5
    480c:	00003517          	auipc	a0,0x3
    4810:	2cc50513          	addi	a0,a0,716 # 7ad8 <malloc+0x1e5a>
    4814:	00001097          	auipc	ra,0x1
    4818:	3ac080e7          	jalr	940(ra) # 5bc0 <printf>
    exit(1);
    481c:	4505                	li	a0,1
    481e:	00001097          	auipc	ra,0x1
    4822:	f9e080e7          	jalr	-98(ra) # 57bc <exit>
    printf("%s: fork failed\n", s);
    4826:	85d6                	mv	a1,s5
    4828:	00001517          	auipc	a0,0x1
    482c:	65850513          	addi	a0,a0,1624 # 5e80 <malloc+0x202>
    4830:	00001097          	auipc	ra,0x1
    4834:	390080e7          	jalr	912(ra) # 5bc0 <printf>
    exit(1);
    4838:	4505                	li	a0,1
    483a:	00001097          	auipc	ra,0x1
    483e:	f82080e7          	jalr	-126(ra) # 57bc <exit>
    a = sbrk(0);
    4842:	4501                	li	a0,0
    4844:	00001097          	auipc	ra,0x1
    4848:	000080e7          	jalr	ra # 5844 <sbrk>
    484c:	892a                	mv	s2,a0
    sbrk(10*BIG);
    484e:	3e800537          	lui	a0,0x3e800
    4852:	00001097          	auipc	ra,0x1
    4856:	ff2080e7          	jalr	-14(ra) # 5844 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    485a:	87ca                	mv	a5,s2
    485c:	3e800737          	lui	a4,0x3e800
    4860:	993a                	add	s2,s2,a4
    4862:	6705                	lui	a4,0x1
      n += *(a+i);
    4864:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f1710>
    4868:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    486a:	97ba                	add	a5,a5,a4
    486c:	ff279ce3          	bne	a5,s2,4864 <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4870:	8626                	mv	a2,s1
    4872:	85d6                	mv	a1,s5
    4874:	00003517          	auipc	a0,0x3
    4878:	28450513          	addi	a0,a0,644 # 7af8 <malloc+0x1e7a>
    487c:	00001097          	auipc	ra,0x1
    4880:	344080e7          	jalr	836(ra) # 5bc0 <printf>
    exit(1);
    4884:	4505                	li	a0,1
    4886:	00001097          	auipc	ra,0x1
    488a:	f36080e7          	jalr	-202(ra) # 57bc <exit>
    exit(1);
    488e:	4505                	li	a0,1
    4890:	00001097          	auipc	ra,0x1
    4894:	f2c080e7          	jalr	-212(ra) # 57bc <exit>

0000000000004898 <sbrkarg>:

  
// test reads/writes from/to allocated memory
void
sbrkarg(char *s)
{
    4898:	7179                	addi	sp,sp,-48
    489a:	f406                	sd	ra,40(sp)
    489c:	f022                	sd	s0,32(sp)
    489e:	ec26                	sd	s1,24(sp)
    48a0:	e84a                	sd	s2,16(sp)
    48a2:	e44e                	sd	s3,8(sp)
    48a4:	1800                	addi	s0,sp,48
    48a6:	89aa                	mv	s3,a0
  char *a;
  int fd, n;

  a = sbrk(PGSIZE);
    48a8:	6505                	lui	a0,0x1
    48aa:	00001097          	auipc	ra,0x1
    48ae:	f9a080e7          	jalr	-102(ra) # 5844 <sbrk>
    48b2:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    48b4:	20100593          	li	a1,513
    48b8:	00003517          	auipc	a0,0x3
    48bc:	27050513          	addi	a0,a0,624 # 7b28 <malloc+0x1eaa>
    48c0:	00001097          	auipc	ra,0x1
    48c4:	f3c080e7          	jalr	-196(ra) # 57fc <open>
    48c8:	84aa                	mv	s1,a0
  unlink("sbrk");
    48ca:	00003517          	auipc	a0,0x3
    48ce:	25e50513          	addi	a0,a0,606 # 7b28 <malloc+0x1eaa>
    48d2:	00001097          	auipc	ra,0x1
    48d6:	f3a080e7          	jalr	-198(ra) # 580c <unlink>
  if(fd < 0)  {
    48da:	0404c163          	bltz	s1,491c <sbrkarg+0x84>
    printf("%s: open sbrk failed\n", s);
    exit(1);
  }
  if ((n = write(fd, a, PGSIZE)) < 0) {
    48de:	6605                	lui	a2,0x1
    48e0:	85ca                	mv	a1,s2
    48e2:	8526                	mv	a0,s1
    48e4:	00001097          	auipc	ra,0x1
    48e8:	ef8080e7          	jalr	-264(ra) # 57dc <write>
    48ec:	04054663          	bltz	a0,4938 <sbrkarg+0xa0>
    printf("%s: write sbrk failed\n", s);
    exit(1);
  }
  close(fd);
    48f0:	8526                	mv	a0,s1
    48f2:	00001097          	auipc	ra,0x1
    48f6:	ef2080e7          	jalr	-270(ra) # 57e4 <close>

  // test writes to allocated memory
  a = sbrk(PGSIZE);
    48fa:	6505                	lui	a0,0x1
    48fc:	00001097          	auipc	ra,0x1
    4900:	f48080e7          	jalr	-184(ra) # 5844 <sbrk>
  if(pipe((int *) a) != 0){
    4904:	00001097          	auipc	ra,0x1
    4908:	ec8080e7          	jalr	-312(ra) # 57cc <pipe>
    490c:	e521                	bnez	a0,4954 <sbrkarg+0xbc>
    printf("%s: pipe() failed\n", s);
    exit(1);
  } 
}
    490e:	70a2                	ld	ra,40(sp)
    4910:	7402                	ld	s0,32(sp)
    4912:	64e2                	ld	s1,24(sp)
    4914:	6942                	ld	s2,16(sp)
    4916:	69a2                	ld	s3,8(sp)
    4918:	6145                	addi	sp,sp,48
    491a:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    491c:	85ce                	mv	a1,s3
    491e:	00003517          	auipc	a0,0x3
    4922:	21250513          	addi	a0,a0,530 # 7b30 <malloc+0x1eb2>
    4926:	00001097          	auipc	ra,0x1
    492a:	29a080e7          	jalr	666(ra) # 5bc0 <printf>
    exit(1);
    492e:	4505                	li	a0,1
    4930:	00001097          	auipc	ra,0x1
    4934:	e8c080e7          	jalr	-372(ra) # 57bc <exit>
    printf("%s: write sbrk failed\n", s);
    4938:	85ce                	mv	a1,s3
    493a:	00003517          	auipc	a0,0x3
    493e:	20e50513          	addi	a0,a0,526 # 7b48 <malloc+0x1eca>
    4942:	00001097          	auipc	ra,0x1
    4946:	27e080e7          	jalr	638(ra) # 5bc0 <printf>
    exit(1);
    494a:	4505                	li	a0,1
    494c:	00001097          	auipc	ra,0x1
    4950:	e70080e7          	jalr	-400(ra) # 57bc <exit>
    printf("%s: pipe() failed\n", s);
    4954:	85ce                	mv	a1,s3
    4956:	00002517          	auipc	a0,0x2
    495a:	82250513          	addi	a0,a0,-2014 # 6178 <malloc+0x4fa>
    495e:	00001097          	auipc	ra,0x1
    4962:	262080e7          	jalr	610(ra) # 5bc0 <printf>
    exit(1);
    4966:	4505                	li	a0,1
    4968:	00001097          	auipc	ra,0x1
    496c:	e54080e7          	jalr	-428(ra) # 57bc <exit>

0000000000004970 <validatetest>:

void
validatetest(char *s)
{
    4970:	7139                	addi	sp,sp,-64
    4972:	fc06                	sd	ra,56(sp)
    4974:	f822                	sd	s0,48(sp)
    4976:	f426                	sd	s1,40(sp)
    4978:	f04a                	sd	s2,32(sp)
    497a:	ec4e                	sd	s3,24(sp)
    497c:	e852                	sd	s4,16(sp)
    497e:	e456                	sd	s5,8(sp)
    4980:	e05a                	sd	s6,0(sp)
    4982:	0080                	addi	s0,sp,64
    4984:	8b2a                	mv	s6,a0
  int hi;
  uint64 p;

  hi = 1100*1024;
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    4986:	4481                	li	s1,0
    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    4988:	00003997          	auipc	s3,0x3
    498c:	1d898993          	addi	s3,s3,472 # 7b60 <malloc+0x1ee2>
    4990:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    4992:	6a85                	lui	s5,0x1
    4994:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    4998:	85a6                	mv	a1,s1
    499a:	854e                	mv	a0,s3
    499c:	00001097          	auipc	ra,0x1
    49a0:	e80080e7          	jalr	-384(ra) # 581c <link>
    49a4:	01251f63          	bne	a0,s2,49c2 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    49a8:	94d6                	add	s1,s1,s5
    49aa:	ff4497e3          	bne	s1,s4,4998 <validatetest+0x28>
      printf("%s: link should not succeed\n", s);
      exit(1);
    }
  }
}
    49ae:	70e2                	ld	ra,56(sp)
    49b0:	7442                	ld	s0,48(sp)
    49b2:	74a2                	ld	s1,40(sp)
    49b4:	7902                	ld	s2,32(sp)
    49b6:	69e2                	ld	s3,24(sp)
    49b8:	6a42                	ld	s4,16(sp)
    49ba:	6aa2                	ld	s5,8(sp)
    49bc:	6b02                	ld	s6,0(sp)
    49be:	6121                	addi	sp,sp,64
    49c0:	8082                	ret
      printf("%s: link should not succeed\n", s);
    49c2:	85da                	mv	a1,s6
    49c4:	00003517          	auipc	a0,0x3
    49c8:	1ac50513          	addi	a0,a0,428 # 7b70 <malloc+0x1ef2>
    49cc:	00001097          	auipc	ra,0x1
    49d0:	1f4080e7          	jalr	500(ra) # 5bc0 <printf>
      exit(1);
    49d4:	4505                	li	a0,1
    49d6:	00001097          	auipc	ra,0x1
    49da:	de6080e7          	jalr	-538(ra) # 57bc <exit>

00000000000049de <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
    49de:	00004797          	auipc	a5,0x4
    49e2:	7f278793          	addi	a5,a5,2034 # 91d0 <uninit>
    49e6:	00007697          	auipc	a3,0x7
    49ea:	efa68693          	addi	a3,a3,-262 # b8e0 <buf>
    if(uninit[i] != '\0'){
    49ee:	0007c703          	lbu	a4,0(a5)
    49f2:	e709                	bnez	a4,49fc <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
    49f4:	0785                	addi	a5,a5,1
    49f6:	fed79ce3          	bne	a5,a3,49ee <bsstest+0x10>
    49fa:	8082                	ret
{
    49fc:	1141                	addi	sp,sp,-16
    49fe:	e406                	sd	ra,8(sp)
    4a00:	e022                	sd	s0,0(sp)
    4a02:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
    4a04:	85aa                	mv	a1,a0
    4a06:	00003517          	auipc	a0,0x3
    4a0a:	18a50513          	addi	a0,a0,394 # 7b90 <malloc+0x1f12>
    4a0e:	00001097          	auipc	ra,0x1
    4a12:	1b2080e7          	jalr	434(ra) # 5bc0 <printf>
      exit(1);
    4a16:	4505                	li	a0,1
    4a18:	00001097          	auipc	ra,0x1
    4a1c:	da4080e7          	jalr	-604(ra) # 57bc <exit>

0000000000004a20 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(char *s)
{
    4a20:	7179                	addi	sp,sp,-48
    4a22:	f406                	sd	ra,40(sp)
    4a24:	f022                	sd	s0,32(sp)
    4a26:	ec26                	sd	s1,24(sp)
    4a28:	1800                	addi	s0,sp,48
    4a2a:	84aa                	mv	s1,a0
  int pid, fd, xstatus;

  unlink("bigarg-ok");
    4a2c:	00003517          	auipc	a0,0x3
    4a30:	17c50513          	addi	a0,a0,380 # 7ba8 <malloc+0x1f2a>
    4a34:	00001097          	auipc	ra,0x1
    4a38:	dd8080e7          	jalr	-552(ra) # 580c <unlink>
  pid = fork();
    4a3c:	00001097          	auipc	ra,0x1
    4a40:	d78080e7          	jalr	-648(ra) # 57b4 <fork>
  if(pid == 0){
    4a44:	c121                	beqz	a0,4a84 <bigargtest+0x64>
    args[MAXARG-1] = 0;
    exec("echo", args);
    fd = open("bigarg-ok", O_CREATE);
    close(fd);
    exit(0);
  } else if(pid < 0){
    4a46:	0a054063          	bltz	a0,4ae6 <bigargtest+0xc6>
    printf("%s: bigargtest: fork failed\n", s);
    exit(1);
  }
  
  wait(&xstatus);
    4a4a:	fdc40513          	addi	a0,s0,-36
    4a4e:	00001097          	auipc	ra,0x1
    4a52:	d76080e7          	jalr	-650(ra) # 57c4 <wait>
  if(xstatus != 0)
    4a56:	fdc42503          	lw	a0,-36(s0)
    4a5a:	e545                	bnez	a0,4b02 <bigargtest+0xe2>
    exit(xstatus);
  fd = open("bigarg-ok", 0);
    4a5c:	4581                	li	a1,0
    4a5e:	00003517          	auipc	a0,0x3
    4a62:	14a50513          	addi	a0,a0,330 # 7ba8 <malloc+0x1f2a>
    4a66:	00001097          	auipc	ra,0x1
    4a6a:	d96080e7          	jalr	-618(ra) # 57fc <open>
  if(fd < 0){
    4a6e:	08054e63          	bltz	a0,4b0a <bigargtest+0xea>
    printf("%s: bigarg test failed!\n", s);
    exit(1);
  }
  close(fd);
    4a72:	00001097          	auipc	ra,0x1
    4a76:	d72080e7          	jalr	-654(ra) # 57e4 <close>
}
    4a7a:	70a2                	ld	ra,40(sp)
    4a7c:	7402                	ld	s0,32(sp)
    4a7e:	64e2                	ld	s1,24(sp)
    4a80:	6145                	addi	sp,sp,48
    4a82:	8082                	ret
    4a84:	00003797          	auipc	a5,0x3
    4a88:	64478793          	addi	a5,a5,1604 # 80c8 <args.1>
    4a8c:	00003697          	auipc	a3,0x3
    4a90:	73468693          	addi	a3,a3,1844 # 81c0 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    4a94:	00003717          	auipc	a4,0x3
    4a98:	12470713          	addi	a4,a4,292 # 7bb8 <malloc+0x1f3a>
    4a9c:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    4a9e:	07a1                	addi	a5,a5,8
    4aa0:	fed79ee3          	bne	a5,a3,4a9c <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    4aa4:	00003597          	auipc	a1,0x3
    4aa8:	62458593          	addi	a1,a1,1572 # 80c8 <args.1>
    4aac:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    4ab0:	00001517          	auipc	a0,0x1
    4ab4:	49050513          	addi	a0,a0,1168 # 5f40 <malloc+0x2c2>
    4ab8:	00001097          	auipc	ra,0x1
    4abc:	d3c080e7          	jalr	-708(ra) # 57f4 <exec>
    fd = open("bigarg-ok", O_CREATE);
    4ac0:	20000593          	li	a1,512
    4ac4:	00003517          	auipc	a0,0x3
    4ac8:	0e450513          	addi	a0,a0,228 # 7ba8 <malloc+0x1f2a>
    4acc:	00001097          	auipc	ra,0x1
    4ad0:	d30080e7          	jalr	-720(ra) # 57fc <open>
    close(fd);
    4ad4:	00001097          	auipc	ra,0x1
    4ad8:	d10080e7          	jalr	-752(ra) # 57e4 <close>
    exit(0);
    4adc:	4501                	li	a0,0
    4ade:	00001097          	auipc	ra,0x1
    4ae2:	cde080e7          	jalr	-802(ra) # 57bc <exit>
    printf("%s: bigargtest: fork failed\n", s);
    4ae6:	85a6                	mv	a1,s1
    4ae8:	00003517          	auipc	a0,0x3
    4aec:	1b050513          	addi	a0,a0,432 # 7c98 <malloc+0x201a>
    4af0:	00001097          	auipc	ra,0x1
    4af4:	0d0080e7          	jalr	208(ra) # 5bc0 <printf>
    exit(1);
    4af8:	4505                	li	a0,1
    4afa:	00001097          	auipc	ra,0x1
    4afe:	cc2080e7          	jalr	-830(ra) # 57bc <exit>
    exit(xstatus);
    4b02:	00001097          	auipc	ra,0x1
    4b06:	cba080e7          	jalr	-838(ra) # 57bc <exit>
    printf("%s: bigarg test failed!\n", s);
    4b0a:	85a6                	mv	a1,s1
    4b0c:	00003517          	auipc	a0,0x3
    4b10:	1ac50513          	addi	a0,a0,428 # 7cb8 <malloc+0x203a>
    4b14:	00001097          	auipc	ra,0x1
    4b18:	0ac080e7          	jalr	172(ra) # 5bc0 <printf>
    exit(1);
    4b1c:	4505                	li	a0,1
    4b1e:	00001097          	auipc	ra,0x1
    4b22:	c9e080e7          	jalr	-866(ra) # 57bc <exit>

0000000000004b26 <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    4b26:	7171                	addi	sp,sp,-176
    4b28:	f506                	sd	ra,168(sp)
    4b2a:	f122                	sd	s0,160(sp)
    4b2c:	ed26                	sd	s1,152(sp)
    4b2e:	e94a                	sd	s2,144(sp)
    4b30:	e54e                	sd	s3,136(sp)
    4b32:	e152                	sd	s4,128(sp)
    4b34:	fcd6                	sd	s5,120(sp)
    4b36:	f8da                	sd	s6,112(sp)
    4b38:	f4de                	sd	s7,104(sp)
    4b3a:	f0e2                	sd	s8,96(sp)
    4b3c:	ece6                	sd	s9,88(sp)
    4b3e:	e8ea                	sd	s10,80(sp)
    4b40:	e4ee                	sd	s11,72(sp)
    4b42:	1900                	addi	s0,sp,176
  int nfiles;
  int fsblocks = 0;

  printf("fsfull test\n");
    4b44:	00003517          	auipc	a0,0x3
    4b48:	19450513          	addi	a0,a0,404 # 7cd8 <malloc+0x205a>
    4b4c:	00001097          	auipc	ra,0x1
    4b50:	074080e7          	jalr	116(ra) # 5bc0 <printf>

  for(nfiles = 0; ; nfiles++){
    4b54:	4481                	li	s1,0
    char name[64];
    name[0] = 'f';
    4b56:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4b5a:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4b5e:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4b62:	4b29                	li	s6,10
    name[4] = '0' + (nfiles % 10);
    name[5] = '\0';
    printf("writing %s\n", name);
    4b64:	00003c97          	auipc	s9,0x3
    4b68:	184c8c93          	addi	s9,s9,388 # 7ce8 <malloc+0x206a>
    int fd = open(name, O_CREATE|O_RDWR);
    if(fd < 0){
      printf("open %s failed\n", name);
      break;
    }
    int total = 0;
    4b6c:	4d81                	li	s11,0
    while(1){
      int cc = write(fd, buf, BSIZE);
    4b6e:	00007a17          	auipc	s4,0x7
    4b72:	d72a0a13          	addi	s4,s4,-654 # b8e0 <buf>
    name[0] = 'f';
    4b76:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4b7a:	0384c7bb          	divw	a5,s1,s8
    4b7e:	0307879b          	addiw	a5,a5,48
    4b82:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4b86:	0384e7bb          	remw	a5,s1,s8
    4b8a:	0377c7bb          	divw	a5,a5,s7
    4b8e:	0307879b          	addiw	a5,a5,48
    4b92:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4b96:	0374e7bb          	remw	a5,s1,s7
    4b9a:	0367c7bb          	divw	a5,a5,s6
    4b9e:	0307879b          	addiw	a5,a5,48
    4ba2:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4ba6:	0364e7bb          	remw	a5,s1,s6
    4baa:	0307879b          	addiw	a5,a5,48
    4bae:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4bb2:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4bb6:	f5040593          	addi	a1,s0,-176
    4bba:	8566                	mv	a0,s9
    4bbc:	00001097          	auipc	ra,0x1
    4bc0:	004080e7          	jalr	4(ra) # 5bc0 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4bc4:	20200593          	li	a1,514
    4bc8:	f5040513          	addi	a0,s0,-176
    4bcc:	00001097          	auipc	ra,0x1
    4bd0:	c30080e7          	jalr	-976(ra) # 57fc <open>
    4bd4:	892a                	mv	s2,a0
    if(fd < 0){
    4bd6:	0a055663          	bgez	a0,4c82 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4bda:	f5040593          	addi	a1,s0,-176
    4bde:	00003517          	auipc	a0,0x3
    4be2:	11a50513          	addi	a0,a0,282 # 7cf8 <malloc+0x207a>
    4be6:	00001097          	auipc	ra,0x1
    4bea:	fda080e7          	jalr	-38(ra) # 5bc0 <printf>
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    4bee:	0604c363          	bltz	s1,4c54 <fsfull+0x12e>
    char name[64];
    name[0] = 'f';
    4bf2:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4bf6:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4bfa:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4bfe:	4929                	li	s2,10
  while(nfiles >= 0){
    4c00:	5afd                	li	s5,-1
    name[0] = 'f';
    4c02:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c06:	0344c7bb          	divw	a5,s1,s4
    4c0a:	0307879b          	addiw	a5,a5,48
    4c0e:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c12:	0344e7bb          	remw	a5,s1,s4
    4c16:	0337c7bb          	divw	a5,a5,s3
    4c1a:	0307879b          	addiw	a5,a5,48
    4c1e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c22:	0334e7bb          	remw	a5,s1,s3
    4c26:	0327c7bb          	divw	a5,a5,s2
    4c2a:	0307879b          	addiw	a5,a5,48
    4c2e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c32:	0324e7bb          	remw	a5,s1,s2
    4c36:	0307879b          	addiw	a5,a5,48
    4c3a:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c3e:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4c42:	f5040513          	addi	a0,s0,-176
    4c46:	00001097          	auipc	ra,0x1
    4c4a:	bc6080e7          	jalr	-1082(ra) # 580c <unlink>
    nfiles--;
    4c4e:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4c50:	fb5499e3          	bne	s1,s5,4c02 <fsfull+0xdc>
  }

  printf("fsfull test finished\n");
    4c54:	00003517          	auipc	a0,0x3
    4c58:	0c450513          	addi	a0,a0,196 # 7d18 <malloc+0x209a>
    4c5c:	00001097          	auipc	ra,0x1
    4c60:	f64080e7          	jalr	-156(ra) # 5bc0 <printf>
}
    4c64:	70aa                	ld	ra,168(sp)
    4c66:	740a                	ld	s0,160(sp)
    4c68:	64ea                	ld	s1,152(sp)
    4c6a:	694a                	ld	s2,144(sp)
    4c6c:	69aa                	ld	s3,136(sp)
    4c6e:	6a0a                	ld	s4,128(sp)
    4c70:	7ae6                	ld	s5,120(sp)
    4c72:	7b46                	ld	s6,112(sp)
    4c74:	7ba6                	ld	s7,104(sp)
    4c76:	7c06                	ld	s8,96(sp)
    4c78:	6ce6                	ld	s9,88(sp)
    4c7a:	6d46                	ld	s10,80(sp)
    4c7c:	6da6                	ld	s11,72(sp)
    4c7e:	614d                	addi	sp,sp,176
    4c80:	8082                	ret
    int total = 0;
    4c82:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4c84:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4c88:	40000613          	li	a2,1024
    4c8c:	85d2                	mv	a1,s4
    4c8e:	854a                	mv	a0,s2
    4c90:	00001097          	auipc	ra,0x1
    4c94:	b4c080e7          	jalr	-1204(ra) # 57dc <write>
      if(cc < BSIZE)
    4c98:	00aad563          	bge	s5,a0,4ca2 <fsfull+0x17c>
      total += cc;
    4c9c:	00a989bb          	addw	s3,s3,a0
    while(1){
    4ca0:	b7e5                	j	4c88 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4ca2:	85ce                	mv	a1,s3
    4ca4:	00003517          	auipc	a0,0x3
    4ca8:	06450513          	addi	a0,a0,100 # 7d08 <malloc+0x208a>
    4cac:	00001097          	auipc	ra,0x1
    4cb0:	f14080e7          	jalr	-236(ra) # 5bc0 <printf>
    close(fd);
    4cb4:	854a                	mv	a0,s2
    4cb6:	00001097          	auipc	ra,0x1
    4cba:	b2e080e7          	jalr	-1234(ra) # 57e4 <close>
    if(total == 0)
    4cbe:	f20988e3          	beqz	s3,4bee <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4cc2:	2485                	addiw	s1,s1,1
    4cc4:	bd4d                	j	4b76 <fsfull+0x50>

0000000000004cc6 <argptest>:

void argptest(char *s)
{
    4cc6:	1101                	addi	sp,sp,-32
    4cc8:	ec06                	sd	ra,24(sp)
    4cca:	e822                	sd	s0,16(sp)
    4ccc:	e426                	sd	s1,8(sp)
    4cce:	e04a                	sd	s2,0(sp)
    4cd0:	1000                	addi	s0,sp,32
    4cd2:	892a                	mv	s2,a0
  int fd;
  fd = open("init", O_RDONLY);
    4cd4:	4581                	li	a1,0
    4cd6:	00003517          	auipc	a0,0x3
    4cda:	05a50513          	addi	a0,a0,90 # 7d30 <malloc+0x20b2>
    4cde:	00001097          	auipc	ra,0x1
    4ce2:	b1e080e7          	jalr	-1250(ra) # 57fc <open>
  if (fd < 0) {
    4ce6:	02054b63          	bltz	a0,4d1c <argptest+0x56>
    4cea:	84aa                	mv	s1,a0
    printf("%s: open failed\n", s);
    exit(1);
  }
  read(fd, sbrk(0) - 1, -1);
    4cec:	4501                	li	a0,0
    4cee:	00001097          	auipc	ra,0x1
    4cf2:	b56080e7          	jalr	-1194(ra) # 5844 <sbrk>
    4cf6:	567d                	li	a2,-1
    4cf8:	fff50593          	addi	a1,a0,-1
    4cfc:	8526                	mv	a0,s1
    4cfe:	00001097          	auipc	ra,0x1
    4d02:	ad6080e7          	jalr	-1322(ra) # 57d4 <read>
  close(fd);
    4d06:	8526                	mv	a0,s1
    4d08:	00001097          	auipc	ra,0x1
    4d0c:	adc080e7          	jalr	-1316(ra) # 57e4 <close>
}
    4d10:	60e2                	ld	ra,24(sp)
    4d12:	6442                	ld	s0,16(sp)
    4d14:	64a2                	ld	s1,8(sp)
    4d16:	6902                	ld	s2,0(sp)
    4d18:	6105                	addi	sp,sp,32
    4d1a:	8082                	ret
    printf("%s: open failed\n", s);
    4d1c:	85ca                	mv	a1,s2
    4d1e:	00002517          	auipc	a0,0x2
    4d22:	02a50513          	addi	a0,a0,42 # 6d48 <malloc+0x10ca>
    4d26:	00001097          	auipc	ra,0x1
    4d2a:	e9a080e7          	jalr	-358(ra) # 5bc0 <printf>
    exit(1);
    4d2e:	4505                	li	a0,1
    4d30:	00001097          	auipc	ra,0x1
    4d34:	a8c080e7          	jalr	-1396(ra) # 57bc <exit>

0000000000004d38 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    4d38:	1141                	addi	sp,sp,-16
    4d3a:	e422                	sd	s0,8(sp)
    4d3c:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4d3e:	00003717          	auipc	a4,0x3
    4d42:	37270713          	addi	a4,a4,882 # 80b0 <randstate>
    4d46:	6308                	ld	a0,0(a4)
    4d48:	001967b7          	lui	a5,0x196
    4d4c:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187d1d>
    4d50:	02f50533          	mul	a0,a0,a5
    4d54:	3c6ef7b7          	lui	a5,0x3c6ef
    4d58:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e0a6f>
    4d5c:	953e                	add	a0,a0,a5
    4d5e:	e308                	sd	a0,0(a4)
  return randstate;
}
    4d60:	2501                	sext.w	a0,a0
    4d62:	6422                	ld	s0,8(sp)
    4d64:	0141                	addi	sp,sp,16
    4d66:	8082                	ret

0000000000004d68 <stacktest>:

// check that there's an invalid page beneath
// the user stack, to catch stack overflow.
void
stacktest(char *s)
{
    4d68:	7179                	addi	sp,sp,-48
    4d6a:	f406                	sd	ra,40(sp)
    4d6c:	f022                	sd	s0,32(sp)
    4d6e:	ec26                	sd	s1,24(sp)
    4d70:	1800                	addi	s0,sp,48
    4d72:	84aa                	mv	s1,a0
  int pid;
  int xstatus;
  
  pid = fork();
    4d74:	00001097          	auipc	ra,0x1
    4d78:	a40080e7          	jalr	-1472(ra) # 57b4 <fork>
  if(pid == 0) {
    4d7c:	c115                	beqz	a0,4da0 <stacktest+0x38>
    char *sp = (char *) r_sp();
    sp -= PGSIZE;
    // the *sp should cause a trap.
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    exit(1);
  } else if(pid < 0){
    4d7e:	04054463          	bltz	a0,4dc6 <stacktest+0x5e>
    printf("%s: fork failed\n", s);
    exit(1);
  }
  wait(&xstatus);
    4d82:	fdc40513          	addi	a0,s0,-36
    4d86:	00001097          	auipc	ra,0x1
    4d8a:	a3e080e7          	jalr	-1474(ra) # 57c4 <wait>
  if(xstatus == -1)  // kernel killed child?
    4d8e:	fdc42503          	lw	a0,-36(s0)
    4d92:	57fd                	li	a5,-1
    4d94:	04f50763          	beq	a0,a5,4de2 <stacktest+0x7a>
    exit(0);
  else
    exit(xstatus);
    4d98:	00001097          	auipc	ra,0x1
    4d9c:	a24080e7          	jalr	-1500(ra) # 57bc <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    4da0:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    4da2:	77fd                	lui	a5,0xfffff
    4da4:	97ba                	add	a5,a5,a4
    4da6:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0710>
    4daa:	85a6                	mv	a1,s1
    4dac:	00003517          	auipc	a0,0x3
    4db0:	f8c50513          	addi	a0,a0,-116 # 7d38 <malloc+0x20ba>
    4db4:	00001097          	auipc	ra,0x1
    4db8:	e0c080e7          	jalr	-500(ra) # 5bc0 <printf>
    exit(1);
    4dbc:	4505                	li	a0,1
    4dbe:	00001097          	auipc	ra,0x1
    4dc2:	9fe080e7          	jalr	-1538(ra) # 57bc <exit>
    printf("%s: fork failed\n", s);
    4dc6:	85a6                	mv	a1,s1
    4dc8:	00001517          	auipc	a0,0x1
    4dcc:	0b850513          	addi	a0,a0,184 # 5e80 <malloc+0x202>
    4dd0:	00001097          	auipc	ra,0x1
    4dd4:	df0080e7          	jalr	-528(ra) # 5bc0 <printf>
    exit(1);
    4dd8:	4505                	li	a0,1
    4dda:	00001097          	auipc	ra,0x1
    4dde:	9e2080e7          	jalr	-1566(ra) # 57bc <exit>
    exit(0);
    4de2:	4501                	li	a0,0
    4de4:	00001097          	auipc	ra,0x1
    4de8:	9d8080e7          	jalr	-1576(ra) # 57bc <exit>

0000000000004dec <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    4dec:	7179                	addi	sp,sp,-48
    4dee:	f406                	sd	ra,40(sp)
    4df0:	f022                	sd	s0,32(sp)
    4df2:	ec26                	sd	s1,24(sp)
    4df4:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    4df6:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    4dfa:	00003497          	auipc	s1,0x3
    4dfe:	2ae4b483          	ld	s1,686(s1) # 80a8 <__SDATA_BEGIN__>
    4e02:	fd840593          	addi	a1,s0,-40
    4e06:	8526                	mv	a0,s1
    4e08:	00001097          	auipc	ra,0x1
    4e0c:	9ec080e7          	jalr	-1556(ra) # 57f4 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    4e10:	8526                	mv	a0,s1
    4e12:	00001097          	auipc	ra,0x1
    4e16:	9ba080e7          	jalr	-1606(ra) # 57cc <pipe>

  exit(0);
    4e1a:	4501                	li	a0,0
    4e1c:	00001097          	auipc	ra,0x1
    4e20:	9a0080e7          	jalr	-1632(ra) # 57bc <exit>

0000000000004e24 <sbrkbugs>:
// regression test. does the kernel panic if a process sbrk()s its
// size to be less than a page, or zero, or reduces the break by an
// amount too small to cause a page to be freed?
void
sbrkbugs(char *s)
{
    4e24:	1141                	addi	sp,sp,-16
    4e26:	e406                	sd	ra,8(sp)
    4e28:	e022                	sd	s0,0(sp)
    4e2a:	0800                	addi	s0,sp,16
  int pid = fork();
    4e2c:	00001097          	auipc	ra,0x1
    4e30:	988080e7          	jalr	-1656(ra) # 57b4 <fork>
  if(pid < 0){
    4e34:	02054263          	bltz	a0,4e58 <sbrkbugs+0x34>
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
    4e38:	ed0d                	bnez	a0,4e72 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    4e3a:	00001097          	auipc	ra,0x1
    4e3e:	a0a080e7          	jalr	-1526(ra) # 5844 <sbrk>
    // free all user memory; there used to be a bug that
    // would not adjust p->sz correctly in this case,
    // causing exit() to panic.
    sbrk(-sz);
    4e42:	40a0053b          	negw	a0,a0
    4e46:	00001097          	auipc	ra,0x1
    4e4a:	9fe080e7          	jalr	-1538(ra) # 5844 <sbrk>
    // user page fault here.
    exit(0);
    4e4e:	4501                	li	a0,0
    4e50:	00001097          	auipc	ra,0x1
    4e54:	96c080e7          	jalr	-1684(ra) # 57bc <exit>
    printf("fork failed\n");
    4e58:	00003517          	auipc	a0,0x3
    4e5c:	e5050513          	addi	a0,a0,-432 # 7ca8 <malloc+0x202a>
    4e60:	00001097          	auipc	ra,0x1
    4e64:	d60080e7          	jalr	-672(ra) # 5bc0 <printf>
    exit(1);
    4e68:	4505                	li	a0,1
    4e6a:	00001097          	auipc	ra,0x1
    4e6e:	952080e7          	jalr	-1710(ra) # 57bc <exit>
  }
  wait(0);
    4e72:	4501                	li	a0,0
    4e74:	00001097          	auipc	ra,0x1
    4e78:	950080e7          	jalr	-1712(ra) # 57c4 <wait>

  pid = fork();
    4e7c:	00001097          	auipc	ra,0x1
    4e80:	938080e7          	jalr	-1736(ra) # 57b4 <fork>
  if(pid < 0){
    4e84:	02054563          	bltz	a0,4eae <sbrkbugs+0x8a>
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
    4e88:	e121                	bnez	a0,4ec8 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    4e8a:	00001097          	auipc	ra,0x1
    4e8e:	9ba080e7          	jalr	-1606(ra) # 5844 <sbrk>
    // set the break to somewhere in the very first
    // page; there used to be a bug that would incorrectly
    // free the first page.
    sbrk(-(sz - 3500));
    4e92:	6785                	lui	a5,0x1
    4e94:	dac7879b          	addiw	a5,a5,-596
    4e98:	40a7853b          	subw	a0,a5,a0
    4e9c:	00001097          	auipc	ra,0x1
    4ea0:	9a8080e7          	jalr	-1624(ra) # 5844 <sbrk>
    exit(0);
    4ea4:	4501                	li	a0,0
    4ea6:	00001097          	auipc	ra,0x1
    4eaa:	916080e7          	jalr	-1770(ra) # 57bc <exit>
    printf("fork failed\n");
    4eae:	00003517          	auipc	a0,0x3
    4eb2:	dfa50513          	addi	a0,a0,-518 # 7ca8 <malloc+0x202a>
    4eb6:	00001097          	auipc	ra,0x1
    4eba:	d0a080e7          	jalr	-758(ra) # 5bc0 <printf>
    exit(1);
    4ebe:	4505                	li	a0,1
    4ec0:	00001097          	auipc	ra,0x1
    4ec4:	8fc080e7          	jalr	-1796(ra) # 57bc <exit>
  }
  wait(0);
    4ec8:	4501                	li	a0,0
    4eca:	00001097          	auipc	ra,0x1
    4ece:	8fa080e7          	jalr	-1798(ra) # 57c4 <wait>

  pid = fork();
    4ed2:	00001097          	auipc	ra,0x1
    4ed6:	8e2080e7          	jalr	-1822(ra) # 57b4 <fork>
  if(pid < 0){
    4eda:	02054a63          	bltz	a0,4f0e <sbrkbugs+0xea>
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
    4ede:	e529                	bnez	a0,4f28 <sbrkbugs+0x104>
    // set the break in the middle of a page.
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    4ee0:	00001097          	auipc	ra,0x1
    4ee4:	964080e7          	jalr	-1692(ra) # 5844 <sbrk>
    4ee8:	67ad                	lui	a5,0xb
    4eea:	8007879b          	addiw	a5,a5,-2048
    4eee:	40a7853b          	subw	a0,a5,a0
    4ef2:	00001097          	auipc	ra,0x1
    4ef6:	952080e7          	jalr	-1710(ra) # 5844 <sbrk>

    // reduce the break a bit, but not enough to
    // cause a page to be freed. this used to cause
    // a panic.
    sbrk(-10);
    4efa:	5559                	li	a0,-10
    4efc:	00001097          	auipc	ra,0x1
    4f00:	948080e7          	jalr	-1720(ra) # 5844 <sbrk>

    exit(0);
    4f04:	4501                	li	a0,0
    4f06:	00001097          	auipc	ra,0x1
    4f0a:	8b6080e7          	jalr	-1866(ra) # 57bc <exit>
    printf("fork failed\n");
    4f0e:	00003517          	auipc	a0,0x3
    4f12:	d9a50513          	addi	a0,a0,-614 # 7ca8 <malloc+0x202a>
    4f16:	00001097          	auipc	ra,0x1
    4f1a:	caa080e7          	jalr	-854(ra) # 5bc0 <printf>
    exit(1);
    4f1e:	4505                	li	a0,1
    4f20:	00001097          	auipc	ra,0x1
    4f24:	89c080e7          	jalr	-1892(ra) # 57bc <exit>
  }
  wait(0);
    4f28:	4501                	li	a0,0
    4f2a:	00001097          	auipc	ra,0x1
    4f2e:	89a080e7          	jalr	-1894(ra) # 57c4 <wait>

  exit(0);
    4f32:	4501                	li	a0,0
    4f34:	00001097          	auipc	ra,0x1
    4f38:	888080e7          	jalr	-1912(ra) # 57bc <exit>

0000000000004f3c <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
    4f3c:	7179                	addi	sp,sp,-48
    4f3e:	f406                	sd	ra,40(sp)
    4f40:	f022                	sd	s0,32(sp)
    4f42:	ec26                	sd	s1,24(sp)
    4f44:	e84a                	sd	s2,16(sp)
    4f46:	e44e                	sd	s3,8(sp)
    4f48:	e052                	sd	s4,0(sp)
    4f4a:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
    4f4c:	00003517          	auipc	a0,0x3
    4f50:	e1450513          	addi	a0,a0,-492 # 7d60 <malloc+0x20e2>
    4f54:	00001097          	auipc	ra,0x1
    4f58:	8b8080e7          	jalr	-1864(ra) # 580c <unlink>
    4f5c:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
    4f60:	00003997          	auipc	s3,0x3
    4f64:	e0098993          	addi	s3,s3,-512 # 7d60 <malloc+0x20e2>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
    4f68:	5a7d                	li	s4,-1
    4f6a:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4f6e:	20100593          	li	a1,513
    4f72:	854e                	mv	a0,s3
    4f74:	00001097          	auipc	ra,0x1
    4f78:	888080e7          	jalr	-1912(ra) # 57fc <open>
    4f7c:	84aa                	mv	s1,a0
    if(fd < 0){
    4f7e:	06054b63          	bltz	a0,4ff4 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4f82:	4605                	li	a2,1
    4f84:	85d2                	mv	a1,s4
    4f86:	00001097          	auipc	ra,0x1
    4f8a:	856080e7          	jalr	-1962(ra) # 57dc <write>
    close(fd);
    4f8e:	8526                	mv	a0,s1
    4f90:	00001097          	auipc	ra,0x1
    4f94:	854080e7          	jalr	-1964(ra) # 57e4 <close>
    unlink("junk");
    4f98:	854e                	mv	a0,s3
    4f9a:	00001097          	auipc	ra,0x1
    4f9e:	872080e7          	jalr	-1934(ra) # 580c <unlink>
  for(int i = 0; i < assumed_free; i++){
    4fa2:	397d                	addiw	s2,s2,-1
    4fa4:	fc0915e3          	bnez	s2,4f6e <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
    4fa8:	20100593          	li	a1,513
    4fac:	00003517          	auipc	a0,0x3
    4fb0:	db450513          	addi	a0,a0,-588 # 7d60 <malloc+0x20e2>
    4fb4:	00001097          	auipc	ra,0x1
    4fb8:	848080e7          	jalr	-1976(ra) # 57fc <open>
    4fbc:	84aa                	mv	s1,a0
  if(fd < 0){
    4fbe:	04054863          	bltz	a0,500e <badwrite+0xd2>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
    4fc2:	4605                	li	a2,1
    4fc4:	00001597          	auipc	a1,0x1
    4fc8:	7e458593          	addi	a1,a1,2020 # 67a8 <malloc+0xb2a>
    4fcc:	00001097          	auipc	ra,0x1
    4fd0:	810080e7          	jalr	-2032(ra) # 57dc <write>
    4fd4:	4785                	li	a5,1
    4fd6:	04f50963          	beq	a0,a5,5028 <badwrite+0xec>
    printf("write failed\n");
    4fda:	00003517          	auipc	a0,0x3
    4fde:	da650513          	addi	a0,a0,-602 # 7d80 <malloc+0x2102>
    4fe2:	00001097          	auipc	ra,0x1
    4fe6:	bde080e7          	jalr	-1058(ra) # 5bc0 <printf>
    exit(1);
    4fea:	4505                	li	a0,1
    4fec:	00000097          	auipc	ra,0x0
    4ff0:	7d0080e7          	jalr	2000(ra) # 57bc <exit>
      printf("open junk failed\n");
    4ff4:	00003517          	auipc	a0,0x3
    4ff8:	d7450513          	addi	a0,a0,-652 # 7d68 <malloc+0x20ea>
    4ffc:	00001097          	auipc	ra,0x1
    5000:	bc4080e7          	jalr	-1084(ra) # 5bc0 <printf>
      exit(1);
    5004:	4505                	li	a0,1
    5006:	00000097          	auipc	ra,0x0
    500a:	7b6080e7          	jalr	1974(ra) # 57bc <exit>
    printf("open junk failed\n");
    500e:	00003517          	auipc	a0,0x3
    5012:	d5a50513          	addi	a0,a0,-678 # 7d68 <malloc+0x20ea>
    5016:	00001097          	auipc	ra,0x1
    501a:	baa080e7          	jalr	-1110(ra) # 5bc0 <printf>
    exit(1);
    501e:	4505                	li	a0,1
    5020:	00000097          	auipc	ra,0x0
    5024:	79c080e7          	jalr	1948(ra) # 57bc <exit>
  }
  close(fd);
    5028:	8526                	mv	a0,s1
    502a:	00000097          	auipc	ra,0x0
    502e:	7ba080e7          	jalr	1978(ra) # 57e4 <close>
  unlink("junk");
    5032:	00003517          	auipc	a0,0x3
    5036:	d2e50513          	addi	a0,a0,-722 # 7d60 <malloc+0x20e2>
    503a:	00000097          	auipc	ra,0x0
    503e:	7d2080e7          	jalr	2002(ra) # 580c <unlink>

  exit(0);
    5042:	4501                	li	a0,0
    5044:	00000097          	auipc	ra,0x0
    5048:	778080e7          	jalr	1912(ra) # 57bc <exit>

000000000000504c <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    504c:	7139                	addi	sp,sp,-64
    504e:	fc06                	sd	ra,56(sp)
    5050:	f822                	sd	s0,48(sp)
    5052:	f426                	sd	s1,40(sp)
    5054:	f04a                	sd	s2,32(sp)
    5056:	ec4e                	sd	s3,24(sp)
    5058:	0080                	addi	s0,sp,64
    505a:	64b1                	lui	s1,0xc
    505c:	35048493          	addi	s1,s1,848 # c350 <buf+0xa70>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    5060:	597d                	li	s2,-1
    5062:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    5066:	00001997          	auipc	s3,0x1
    506a:	eda98993          	addi	s3,s3,-294 # 5f40 <malloc+0x2c2>
    argv[0] = (char*)0xffffffff;
    506e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    5072:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    5076:	fc040593          	addi	a1,s0,-64
    507a:	854e                	mv	a0,s3
    507c:	00000097          	auipc	ra,0x0
    5080:	778080e7          	jalr	1912(ra) # 57f4 <exec>
  for(int i = 0; i < 50000; i++){
    5084:	34fd                	addiw	s1,s1,-1
    5086:	f4e5                	bnez	s1,506e <badarg+0x22>
  }
  
  exit(0);
    5088:	4501                	li	a0,0
    508a:	00000097          	auipc	ra,0x0
    508e:	732080e7          	jalr	1842(ra) # 57bc <exit>

0000000000005092 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    5092:	715d                	addi	sp,sp,-80
    5094:	e486                	sd	ra,72(sp)
    5096:	e0a2                	sd	s0,64(sp)
    5098:	fc26                	sd	s1,56(sp)
    509a:	f84a                	sd	s2,48(sp)
    509c:	f44e                	sd	s3,40(sp)
    509e:	f052                	sd	s4,32(sp)
    50a0:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    50a2:	4901                	li	s2,0
    50a4:	49bd                	li	s3,15
    int pid = fork();
    50a6:	00000097          	auipc	ra,0x0
    50aa:	70e080e7          	jalr	1806(ra) # 57b4 <fork>
    50ae:	84aa                	mv	s1,a0
    if(pid < 0){
    50b0:	02054063          	bltz	a0,50d0 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    50b4:	c91d                	beqz	a0,50ea <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    50b6:	4501                	li	a0,0
    50b8:	00000097          	auipc	ra,0x0
    50bc:	70c080e7          	jalr	1804(ra) # 57c4 <wait>
  for(int avail = 0; avail < 15; avail++){
    50c0:	2905                	addiw	s2,s2,1
    50c2:	ff3912e3          	bne	s2,s3,50a6 <execout+0x14>
    }
  }

  exit(0);
    50c6:	4501                	li	a0,0
    50c8:	00000097          	auipc	ra,0x0
    50cc:	6f4080e7          	jalr	1780(ra) # 57bc <exit>
      printf("fork failed\n");
    50d0:	00003517          	auipc	a0,0x3
    50d4:	bd850513          	addi	a0,a0,-1064 # 7ca8 <malloc+0x202a>
    50d8:	00001097          	auipc	ra,0x1
    50dc:	ae8080e7          	jalr	-1304(ra) # 5bc0 <printf>
      exit(1);
    50e0:	4505                	li	a0,1
    50e2:	00000097          	auipc	ra,0x0
    50e6:	6da080e7          	jalr	1754(ra) # 57bc <exit>
        if(a == 0xffffffffffffffffLL)
    50ea:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    50ec:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    50ee:	6505                	lui	a0,0x1
    50f0:	00000097          	auipc	ra,0x0
    50f4:	754080e7          	jalr	1876(ra) # 5844 <sbrk>
        if(a == 0xffffffffffffffffLL)
    50f8:	01350763          	beq	a0,s3,5106 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    50fc:	6785                	lui	a5,0x1
    50fe:	953e                	add	a0,a0,a5
    5100:	ff450fa3          	sb	s4,-1(a0) # fff <dirfile+0xef>
      while(1){
    5104:	b7ed                	j	50ee <execout+0x5c>
      for(int i = 0; i < avail; i++)
    5106:	01205a63          	blez	s2,511a <execout+0x88>
        sbrk(-4096);
    510a:	757d                	lui	a0,0xfffff
    510c:	00000097          	auipc	ra,0x0
    5110:	738080e7          	jalr	1848(ra) # 5844 <sbrk>
      for(int i = 0; i < avail; i++)
    5114:	2485                	addiw	s1,s1,1
    5116:	ff249ae3          	bne	s1,s2,510a <execout+0x78>
      close(1);
    511a:	4505                	li	a0,1
    511c:	00000097          	auipc	ra,0x0
    5120:	6c8080e7          	jalr	1736(ra) # 57e4 <close>
      char *args[] = { "echo", "x", 0 };
    5124:	00001517          	auipc	a0,0x1
    5128:	e1c50513          	addi	a0,a0,-484 # 5f40 <malloc+0x2c2>
    512c:	faa43c23          	sd	a0,-72(s0)
    5130:	00001797          	auipc	a5,0x1
    5134:	67878793          	addi	a5,a5,1656 # 67a8 <malloc+0xb2a>
    5138:	fcf43023          	sd	a5,-64(s0)
    513c:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    5140:	fb840593          	addi	a1,s0,-72
    5144:	00000097          	auipc	ra,0x0
    5148:	6b0080e7          	jalr	1712(ra) # 57f4 <exec>
      exit(0);
    514c:	4501                	li	a0,0
    514e:	00000097          	auipc	ra,0x0
    5152:	66e080e7          	jalr	1646(ra) # 57bc <exit>

0000000000005156 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    5156:	7139                	addi	sp,sp,-64
    5158:	fc06                	sd	ra,56(sp)
    515a:	f822                	sd	s0,48(sp)
    515c:	f426                	sd	s1,40(sp)
    515e:	f04a                	sd	s2,32(sp)
    5160:	ec4e                	sd	s3,24(sp)
    5162:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    5164:	fc840513          	addi	a0,s0,-56
    5168:	00000097          	auipc	ra,0x0
    516c:	664080e7          	jalr	1636(ra) # 57cc <pipe>
    5170:	06054763          	bltz	a0,51de <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    5174:	00000097          	auipc	ra,0x0
    5178:	640080e7          	jalr	1600(ra) # 57b4 <fork>

  if(pid < 0){
    517c:	06054e63          	bltz	a0,51f8 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    5180:	ed51                	bnez	a0,521c <countfree+0xc6>
    close(fds[0]);
    5182:	fc842503          	lw	a0,-56(s0)
    5186:	00000097          	auipc	ra,0x0
    518a:	65e080e7          	jalr	1630(ra) # 57e4 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    518e:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5190:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5192:	00001997          	auipc	s3,0x1
    5196:	61698993          	addi	s3,s3,1558 # 67a8 <malloc+0xb2a>
      uint64 a = (uint64) sbrk(4096);
    519a:	6505                	lui	a0,0x1
    519c:	00000097          	auipc	ra,0x0
    51a0:	6a8080e7          	jalr	1704(ra) # 5844 <sbrk>
      if(a == 0xffffffffffffffff){
    51a4:	07250763          	beq	a0,s2,5212 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    51a8:	6785                	lui	a5,0x1
    51aa:	953e                	add	a0,a0,a5
    51ac:	fe950fa3          	sb	s1,-1(a0) # fff <dirfile+0xef>
      if(write(fds[1], "x", 1) != 1){
    51b0:	8626                	mv	a2,s1
    51b2:	85ce                	mv	a1,s3
    51b4:	fcc42503          	lw	a0,-52(s0)
    51b8:	00000097          	auipc	ra,0x0
    51bc:	624080e7          	jalr	1572(ra) # 57dc <write>
    51c0:	fc950de3          	beq	a0,s1,519a <countfree+0x44>
        printf("write() failed in countfree()\n");
    51c4:	00003517          	auipc	a0,0x3
    51c8:	c0c50513          	addi	a0,a0,-1012 # 7dd0 <malloc+0x2152>
    51cc:	00001097          	auipc	ra,0x1
    51d0:	9f4080e7          	jalr	-1548(ra) # 5bc0 <printf>
        exit(1);
    51d4:	4505                	li	a0,1
    51d6:	00000097          	auipc	ra,0x0
    51da:	5e6080e7          	jalr	1510(ra) # 57bc <exit>
    printf("pipe() failed in countfree()\n");
    51de:	00003517          	auipc	a0,0x3
    51e2:	bb250513          	addi	a0,a0,-1102 # 7d90 <malloc+0x2112>
    51e6:	00001097          	auipc	ra,0x1
    51ea:	9da080e7          	jalr	-1574(ra) # 5bc0 <printf>
    exit(1);
    51ee:	4505                	li	a0,1
    51f0:	00000097          	auipc	ra,0x0
    51f4:	5cc080e7          	jalr	1484(ra) # 57bc <exit>
    printf("fork failed in countfree()\n");
    51f8:	00003517          	auipc	a0,0x3
    51fc:	bb850513          	addi	a0,a0,-1096 # 7db0 <malloc+0x2132>
    5200:	00001097          	auipc	ra,0x1
    5204:	9c0080e7          	jalr	-1600(ra) # 5bc0 <printf>
    exit(1);
    5208:	4505                	li	a0,1
    520a:	00000097          	auipc	ra,0x0
    520e:	5b2080e7          	jalr	1458(ra) # 57bc <exit>
      }
    }

    exit(0);
    5212:	4501                	li	a0,0
    5214:	00000097          	auipc	ra,0x0
    5218:	5a8080e7          	jalr	1448(ra) # 57bc <exit>
  }

  close(fds[1]);
    521c:	fcc42503          	lw	a0,-52(s0)
    5220:	00000097          	auipc	ra,0x0
    5224:	5c4080e7          	jalr	1476(ra) # 57e4 <close>

  int n = 0;
    5228:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    522a:	4605                	li	a2,1
    522c:	fc740593          	addi	a1,s0,-57
    5230:	fc842503          	lw	a0,-56(s0)
    5234:	00000097          	auipc	ra,0x0
    5238:	5a0080e7          	jalr	1440(ra) # 57d4 <read>
    if(cc < 0){
    523c:	00054563          	bltz	a0,5246 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5240:	c105                	beqz	a0,5260 <countfree+0x10a>
      break;
    n += 1;
    5242:	2485                	addiw	s1,s1,1
  while(1){
    5244:	b7dd                	j	522a <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5246:	00003517          	auipc	a0,0x3
    524a:	baa50513          	addi	a0,a0,-1110 # 7df0 <malloc+0x2172>
    524e:	00001097          	auipc	ra,0x1
    5252:	972080e7          	jalr	-1678(ra) # 5bc0 <printf>
      exit(1);
    5256:	4505                	li	a0,1
    5258:	00000097          	auipc	ra,0x0
    525c:	564080e7          	jalr	1380(ra) # 57bc <exit>
  }

  close(fds[0]);
    5260:	fc842503          	lw	a0,-56(s0)
    5264:	00000097          	auipc	ra,0x0
    5268:	580080e7          	jalr	1408(ra) # 57e4 <close>
  wait((int*)0);
    526c:	4501                	li	a0,0
    526e:	00000097          	auipc	ra,0x0
    5272:	556080e7          	jalr	1366(ra) # 57c4 <wait>
  
  return n;
}
    5276:	8526                	mv	a0,s1
    5278:	70e2                	ld	ra,56(sp)
    527a:	7442                	ld	s0,48(sp)
    527c:	74a2                	ld	s1,40(sp)
    527e:	7902                	ld	s2,32(sp)
    5280:	69e2                	ld	s3,24(sp)
    5282:	6121                	addi	sp,sp,64
    5284:	8082                	ret

0000000000005286 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    5286:	7179                	addi	sp,sp,-48
    5288:	f406                	sd	ra,40(sp)
    528a:	f022                	sd	s0,32(sp)
    528c:	ec26                	sd	s1,24(sp)
    528e:	e84a                	sd	s2,16(sp)
    5290:	1800                	addi	s0,sp,48
    5292:	84aa                	mv	s1,a0
    5294:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    5296:	00003517          	auipc	a0,0x3
    529a:	b7a50513          	addi	a0,a0,-1158 # 7e10 <malloc+0x2192>
    529e:	00001097          	auipc	ra,0x1
    52a2:	922080e7          	jalr	-1758(ra) # 5bc0 <printf>
  if((pid = fork()) < 0) {
    52a6:	00000097          	auipc	ra,0x0
    52aa:	50e080e7          	jalr	1294(ra) # 57b4 <fork>
    52ae:	02054e63          	bltz	a0,52ea <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    52b2:	c929                	beqz	a0,5304 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    52b4:	fdc40513          	addi	a0,s0,-36
    52b8:	00000097          	auipc	ra,0x0
    52bc:	50c080e7          	jalr	1292(ra) # 57c4 <wait>
    if(xstatus != 0) 
    52c0:	fdc42783          	lw	a5,-36(s0)
    52c4:	c7b9                	beqz	a5,5312 <run+0x8c>
      printf("FAILED\n");
    52c6:	00003517          	auipc	a0,0x3
    52ca:	b7250513          	addi	a0,a0,-1166 # 7e38 <malloc+0x21ba>
    52ce:	00001097          	auipc	ra,0x1
    52d2:	8f2080e7          	jalr	-1806(ra) # 5bc0 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    52d6:	fdc42503          	lw	a0,-36(s0)
  }
}
    52da:	00153513          	seqz	a0,a0
    52de:	70a2                	ld	ra,40(sp)
    52e0:	7402                	ld	s0,32(sp)
    52e2:	64e2                	ld	s1,24(sp)
    52e4:	6942                	ld	s2,16(sp)
    52e6:	6145                	addi	sp,sp,48
    52e8:	8082                	ret
    printf("runtest: fork error\n");
    52ea:	00003517          	auipc	a0,0x3
    52ee:	b3650513          	addi	a0,a0,-1226 # 7e20 <malloc+0x21a2>
    52f2:	00001097          	auipc	ra,0x1
    52f6:	8ce080e7          	jalr	-1842(ra) # 5bc0 <printf>
    exit(1);
    52fa:	4505                	li	a0,1
    52fc:	00000097          	auipc	ra,0x0
    5300:	4c0080e7          	jalr	1216(ra) # 57bc <exit>
    f(s);
    5304:	854a                	mv	a0,s2
    5306:	9482                	jalr	s1
    exit(0);
    5308:	4501                	li	a0,0
    530a:	00000097          	auipc	ra,0x0
    530e:	4b2080e7          	jalr	1202(ra) # 57bc <exit>
      printf("OK\n");
    5312:	00003517          	auipc	a0,0x3
    5316:	b2e50513          	addi	a0,a0,-1234 # 7e40 <malloc+0x21c2>
    531a:	00001097          	auipc	ra,0x1
    531e:	8a6080e7          	jalr	-1882(ra) # 5bc0 <printf>
    5322:	bf55                	j	52d6 <run+0x50>

0000000000005324 <main>:

int
main(int argc, char *argv[])
{
    5324:	7149                	addi	sp,sp,-368
    5326:	f686                	sd	ra,360(sp)
    5328:	f2a2                	sd	s0,352(sp)
    532a:	eea6                	sd	s1,344(sp)
    532c:	eaca                	sd	s2,336(sp)
    532e:	e6ce                	sd	s3,328(sp)
    5330:	e2d2                	sd	s4,320(sp)
    5332:	fe56                	sd	s5,312(sp)
    5334:	fa5a                	sd	s6,304(sp)
    5336:	1a80                	addi	s0,sp,368
    5338:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    533a:	4789                	li	a5,2
    533c:	08f50b63          	beq	a0,a5,53d2 <main+0xae>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5340:	4785                	li	a5,1
  char *justone = 0;
    5342:	4901                	li	s2,0
  } else if(argc > 1){
    5344:	0ca7c563          	blt	a5,a0,540e <main+0xea>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    5348:	00003797          	auipc	a5,0x3
    534c:	c1078793          	addi	a5,a5,-1008 # 7f58 <malloc+0x22da>
    5350:	e9040713          	addi	a4,s0,-368
    5354:	00003817          	auipc	a6,0x3
    5358:	d2480813          	addi	a6,a6,-732 # 8078 <malloc+0x23fa>
    535c:	6388                	ld	a0,0(a5)
    535e:	678c                	ld	a1,8(a5)
    5360:	6b90                	ld	a2,16(a5)
    5362:	6f94                	ld	a3,24(a5)
    5364:	e308                	sd	a0,0(a4)
    5366:	e70c                	sd	a1,8(a4)
    5368:	eb10                	sd	a2,16(a4)
    536a:	ef14                	sd	a3,24(a4)
    536c:	02078793          	addi	a5,a5,32
    5370:	02070713          	addi	a4,a4,32
    5374:	ff0794e3          	bne	a5,a6,535c <main+0x38>
    5378:	6394                	ld	a3,0(a5)
    537a:	679c                	ld	a5,8(a5)
    537c:	e314                	sd	a3,0(a4)
    537e:	e71c                	sd	a5,8(a4)
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    5380:	00003517          	auipc	a0,0x3
    5384:	b7850513          	addi	a0,a0,-1160 # 7ef8 <malloc+0x227a>
    5388:	00001097          	auipc	ra,0x1
    538c:	838080e7          	jalr	-1992(ra) # 5bc0 <printf>
  int free0 = countfree();
    5390:	00000097          	auipc	ra,0x0
    5394:	dc6080e7          	jalr	-570(ra) # 5156 <countfree>
    5398:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    539a:	e9843503          	ld	a0,-360(s0)
    539e:	e9040493          	addi	s1,s0,-368
  int fail = 0;
    53a2:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    53a4:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    53a6:	e55d                	bnez	a0,5454 <main+0x130>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    53a8:	00000097          	auipc	ra,0x0
    53ac:	dae080e7          	jalr	-594(ra) # 5156 <countfree>
    53b0:	85aa                	mv	a1,a0
    53b2:	0f455163          	bge	a0,s4,5494 <main+0x170>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    53b6:	8652                	mv	a2,s4
    53b8:	00003517          	auipc	a0,0x3
    53bc:	af850513          	addi	a0,a0,-1288 # 7eb0 <malloc+0x2232>
    53c0:	00001097          	auipc	ra,0x1
    53c4:	800080e7          	jalr	-2048(ra) # 5bc0 <printf>
    exit(1);
    53c8:	4505                	li	a0,1
    53ca:	00000097          	auipc	ra,0x0
    53ce:	3f2080e7          	jalr	1010(ra) # 57bc <exit>
    53d2:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    53d4:	00003597          	auipc	a1,0x3
    53d8:	a7458593          	addi	a1,a1,-1420 # 7e48 <malloc+0x21ca>
    53dc:	6488                	ld	a0,8(s1)
    53de:	00000097          	auipc	ra,0x0
    53e2:	18c080e7          	jalr	396(ra) # 556a <strcmp>
    53e6:	10050563          	beqz	a0,54f0 <main+0x1cc>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    53ea:	00003597          	auipc	a1,0x3
    53ee:	b4658593          	addi	a1,a1,-1210 # 7f30 <malloc+0x22b2>
    53f2:	6488                	ld	a0,8(s1)
    53f4:	00000097          	auipc	ra,0x0
    53f8:	176080e7          	jalr	374(ra) # 556a <strcmp>
    53fc:	c97d                	beqz	a0,54f2 <main+0x1ce>
  } else if(argc == 2 && argv[1][0] != '-'){
    53fe:	0084b903          	ld	s2,8(s1)
    5402:	00094703          	lbu	a4,0(s2)
    5406:	02d00793          	li	a5,45
    540a:	f2f71fe3          	bne	a4,a5,5348 <main+0x24>
    printf("Usage: usertests [-c] [testname]\n");
    540e:	00003517          	auipc	a0,0x3
    5412:	a4250513          	addi	a0,a0,-1470 # 7e50 <malloc+0x21d2>
    5416:	00000097          	auipc	ra,0x0
    541a:	7aa080e7          	jalr	1962(ra) # 5bc0 <printf>
    exit(1);
    541e:	4505                	li	a0,1
    5420:	00000097          	auipc	ra,0x0
    5424:	39c080e7          	jalr	924(ra) # 57bc <exit>
          exit(1);
    5428:	4505                	li	a0,1
    542a:	00000097          	auipc	ra,0x0
    542e:	392080e7          	jalr	914(ra) # 57bc <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5432:	40a905bb          	subw	a1,s2,a0
    5436:	855a                	mv	a0,s6
    5438:	00000097          	auipc	ra,0x0
    543c:	788080e7          	jalr	1928(ra) # 5bc0 <printf>
        if(continuous != 2)
    5440:	09498463          	beq	s3,s4,54c8 <main+0x1a4>
          exit(1);
    5444:	4505                	li	a0,1
    5446:	00000097          	auipc	ra,0x0
    544a:	376080e7          	jalr	886(ra) # 57bc <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    544e:	04c1                	addi	s1,s1,16
    5450:	6488                	ld	a0,8(s1)
    5452:	c115                	beqz	a0,5476 <main+0x152>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5454:	00090863          	beqz	s2,5464 <main+0x140>
    5458:	85ca                	mv	a1,s2
    545a:	00000097          	auipc	ra,0x0
    545e:	110080e7          	jalr	272(ra) # 556a <strcmp>
    5462:	f575                	bnez	a0,544e <main+0x12a>
      if(!run(t->f, t->s))
    5464:	648c                	ld	a1,8(s1)
    5466:	6088                	ld	a0,0(s1)
    5468:	00000097          	auipc	ra,0x0
    546c:	e1e080e7          	jalr	-482(ra) # 5286 <run>
    5470:	fd79                	bnez	a0,544e <main+0x12a>
        fail = 1;
    5472:	89d6                	mv	s3,s5
    5474:	bfe9                	j	544e <main+0x12a>
  if(fail){
    5476:	f20989e3          	beqz	s3,53a8 <main+0x84>
    printf("SOME TESTS FAILED\n");
    547a:	00003517          	auipc	a0,0x3
    547e:	a1e50513          	addi	a0,a0,-1506 # 7e98 <malloc+0x221a>
    5482:	00000097          	auipc	ra,0x0
    5486:	73e080e7          	jalr	1854(ra) # 5bc0 <printf>
    exit(1);
    548a:	4505                	li	a0,1
    548c:	00000097          	auipc	ra,0x0
    5490:	330080e7          	jalr	816(ra) # 57bc <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    5494:	00003517          	auipc	a0,0x3
    5498:	a4c50513          	addi	a0,a0,-1460 # 7ee0 <malloc+0x2262>
    549c:	00000097          	auipc	ra,0x0
    54a0:	724080e7          	jalr	1828(ra) # 5bc0 <printf>
    exit(0);
    54a4:	4501                	li	a0,0
    54a6:	00000097          	auipc	ra,0x0
    54aa:	316080e7          	jalr	790(ra) # 57bc <exit>
        printf("SOME TESTS FAILED\n");
    54ae:	8556                	mv	a0,s5
    54b0:	00000097          	auipc	ra,0x0
    54b4:	710080e7          	jalr	1808(ra) # 5bc0 <printf>
        if(continuous != 2)
    54b8:	f74998e3          	bne	s3,s4,5428 <main+0x104>
      int free1 = countfree();
    54bc:	00000097          	auipc	ra,0x0
    54c0:	c9a080e7          	jalr	-870(ra) # 5156 <countfree>
      if(free1 < free0){
    54c4:	f72547e3          	blt	a0,s2,5432 <main+0x10e>
      int free0 = countfree();
    54c8:	00000097          	auipc	ra,0x0
    54cc:	c8e080e7          	jalr	-882(ra) # 5156 <countfree>
    54d0:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    54d2:	e9843583          	ld	a1,-360(s0)
    54d6:	d1fd                	beqz	a1,54bc <main+0x198>
    54d8:	e9040493          	addi	s1,s0,-368
        if(!run(t->f, t->s)){
    54dc:	6088                	ld	a0,0(s1)
    54de:	00000097          	auipc	ra,0x0
    54e2:	da8080e7          	jalr	-600(ra) # 5286 <run>
    54e6:	d561                	beqz	a0,54ae <main+0x18a>
      for (struct test *t = tests; t->s != 0; t++) {
    54e8:	04c1                	addi	s1,s1,16
    54ea:	648c                	ld	a1,8(s1)
    54ec:	f9e5                	bnez	a1,54dc <main+0x1b8>
    54ee:	b7f9                	j	54bc <main+0x198>
    continuous = 1;
    54f0:	4985                	li	s3,1
  } tests[] = {
    54f2:	00003797          	auipc	a5,0x3
    54f6:	a6678793          	addi	a5,a5,-1434 # 7f58 <malloc+0x22da>
    54fa:	e9040713          	addi	a4,s0,-368
    54fe:	00003817          	auipc	a6,0x3
    5502:	b7a80813          	addi	a6,a6,-1158 # 8078 <malloc+0x23fa>
    5506:	6388                	ld	a0,0(a5)
    5508:	678c                	ld	a1,8(a5)
    550a:	6b90                	ld	a2,16(a5)
    550c:	6f94                	ld	a3,24(a5)
    550e:	e308                	sd	a0,0(a4)
    5510:	e70c                	sd	a1,8(a4)
    5512:	eb10                	sd	a2,16(a4)
    5514:	ef14                	sd	a3,24(a4)
    5516:	02078793          	addi	a5,a5,32
    551a:	02070713          	addi	a4,a4,32
    551e:	ff0794e3          	bne	a5,a6,5506 <main+0x1e2>
    5522:	6394                	ld	a3,0(a5)
    5524:	679c                	ld	a5,8(a5)
    5526:	e314                	sd	a3,0(a4)
    5528:	e71c                	sd	a5,8(a4)
    printf("continuous usertests starting\n");
    552a:	00003517          	auipc	a0,0x3
    552e:	9e650513          	addi	a0,a0,-1562 # 7f10 <malloc+0x2292>
    5532:	00000097          	auipc	ra,0x0
    5536:	68e080e7          	jalr	1678(ra) # 5bc0 <printf>
        printf("SOME TESTS FAILED\n");
    553a:	00003a97          	auipc	s5,0x3
    553e:	95ea8a93          	addi	s5,s5,-1698 # 7e98 <malloc+0x221a>
        if(continuous != 2)
    5542:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5544:	00003b17          	auipc	s6,0x3
    5548:	934b0b13          	addi	s6,s6,-1740 # 7e78 <malloc+0x21fa>
    554c:	bfb5                	j	54c8 <main+0x1a4>

000000000000554e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    554e:	1141                	addi	sp,sp,-16
    5550:	e422                	sd	s0,8(sp)
    5552:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5554:	87aa                	mv	a5,a0
    5556:	0585                	addi	a1,a1,1
    5558:	0785                	addi	a5,a5,1
    555a:	fff5c703          	lbu	a4,-1(a1)
    555e:	fee78fa3          	sb	a4,-1(a5)
    5562:	fb75                	bnez	a4,5556 <strcpy+0x8>
    ;
  return os;
}
    5564:	6422                	ld	s0,8(sp)
    5566:	0141                	addi	sp,sp,16
    5568:	8082                	ret

000000000000556a <strcmp>:

int
strcmp(const char *p, const char *q)
{
    556a:	1141                	addi	sp,sp,-16
    556c:	e422                	sd	s0,8(sp)
    556e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5570:	00054783          	lbu	a5,0(a0)
    5574:	cb91                	beqz	a5,5588 <strcmp+0x1e>
    5576:	0005c703          	lbu	a4,0(a1)
    557a:	00f71763          	bne	a4,a5,5588 <strcmp+0x1e>
    p++, q++;
    557e:	0505                	addi	a0,a0,1
    5580:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5582:	00054783          	lbu	a5,0(a0)
    5586:	fbe5                	bnez	a5,5576 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5588:	0005c503          	lbu	a0,0(a1)
}
    558c:	40a7853b          	subw	a0,a5,a0
    5590:	6422                	ld	s0,8(sp)
    5592:	0141                	addi	sp,sp,16
    5594:	8082                	ret

0000000000005596 <strlen>:

uint
strlen(const char *s)
{
    5596:	1141                	addi	sp,sp,-16
    5598:	e422                	sd	s0,8(sp)
    559a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    559c:	00054783          	lbu	a5,0(a0)
    55a0:	cf91                	beqz	a5,55bc <strlen+0x26>
    55a2:	0505                	addi	a0,a0,1
    55a4:	87aa                	mv	a5,a0
    55a6:	4685                	li	a3,1
    55a8:	9e89                	subw	a3,a3,a0
    55aa:	00f6853b          	addw	a0,a3,a5
    55ae:	0785                	addi	a5,a5,1
    55b0:	fff7c703          	lbu	a4,-1(a5)
    55b4:	fb7d                	bnez	a4,55aa <strlen+0x14>
    ;
  return n;
}
    55b6:	6422                	ld	s0,8(sp)
    55b8:	0141                	addi	sp,sp,16
    55ba:	8082                	ret
  for(n = 0; s[n]; n++)
    55bc:	4501                	li	a0,0
    55be:	bfe5                	j	55b6 <strlen+0x20>

00000000000055c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
    55c0:	1141                	addi	sp,sp,-16
    55c2:	e422                	sd	s0,8(sp)
    55c4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    55c6:	ca19                	beqz	a2,55dc <memset+0x1c>
    55c8:	87aa                	mv	a5,a0
    55ca:	1602                	slli	a2,a2,0x20
    55cc:	9201                	srli	a2,a2,0x20
    55ce:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    55d2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    55d6:	0785                	addi	a5,a5,1
    55d8:	fee79de3          	bne	a5,a4,55d2 <memset+0x12>
  }
  return dst;
}
    55dc:	6422                	ld	s0,8(sp)
    55de:	0141                	addi	sp,sp,16
    55e0:	8082                	ret

00000000000055e2 <strchr>:

char*
strchr(const char *s, char c)
{
    55e2:	1141                	addi	sp,sp,-16
    55e4:	e422                	sd	s0,8(sp)
    55e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
    55e8:	00054783          	lbu	a5,0(a0)
    55ec:	cb99                	beqz	a5,5602 <strchr+0x20>
    if(*s == c)
    55ee:	00f58763          	beq	a1,a5,55fc <strchr+0x1a>
  for(; *s; s++)
    55f2:	0505                	addi	a0,a0,1
    55f4:	00054783          	lbu	a5,0(a0)
    55f8:	fbfd                	bnez	a5,55ee <strchr+0xc>
      return (char*)s;
  return 0;
    55fa:	4501                	li	a0,0
}
    55fc:	6422                	ld	s0,8(sp)
    55fe:	0141                	addi	sp,sp,16
    5600:	8082                	ret
  return 0;
    5602:	4501                	li	a0,0
    5604:	bfe5                	j	55fc <strchr+0x1a>

0000000000005606 <gets>:

char*
gets(char *buf, int max)
{
    5606:	711d                	addi	sp,sp,-96
    5608:	ec86                	sd	ra,88(sp)
    560a:	e8a2                	sd	s0,80(sp)
    560c:	e4a6                	sd	s1,72(sp)
    560e:	e0ca                	sd	s2,64(sp)
    5610:	fc4e                	sd	s3,56(sp)
    5612:	f852                	sd	s4,48(sp)
    5614:	f456                	sd	s5,40(sp)
    5616:	f05a                	sd	s6,32(sp)
    5618:	ec5e                	sd	s7,24(sp)
    561a:	1080                	addi	s0,sp,96
    561c:	8baa                	mv	s7,a0
    561e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5620:	892a                	mv	s2,a0
    5622:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5624:	4aa9                	li	s5,10
    5626:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5628:	89a6                	mv	s3,s1
    562a:	2485                	addiw	s1,s1,1
    562c:	0344d863          	bge	s1,s4,565c <gets+0x56>
    cc = read(0, &c, 1);
    5630:	4605                	li	a2,1
    5632:	faf40593          	addi	a1,s0,-81
    5636:	4501                	li	a0,0
    5638:	00000097          	auipc	ra,0x0
    563c:	19c080e7          	jalr	412(ra) # 57d4 <read>
    if(cc < 1)
    5640:	00a05e63          	blez	a0,565c <gets+0x56>
    buf[i++] = c;
    5644:	faf44783          	lbu	a5,-81(s0)
    5648:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    564c:	01578763          	beq	a5,s5,565a <gets+0x54>
    5650:	0905                	addi	s2,s2,1
    5652:	fd679be3          	bne	a5,s6,5628 <gets+0x22>
  for(i=0; i+1 < max; ){
    5656:	89a6                	mv	s3,s1
    5658:	a011                	j	565c <gets+0x56>
    565a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    565c:	99de                	add	s3,s3,s7
    565e:	00098023          	sb	zero,0(s3)
  return buf;
}
    5662:	855e                	mv	a0,s7
    5664:	60e6                	ld	ra,88(sp)
    5666:	6446                	ld	s0,80(sp)
    5668:	64a6                	ld	s1,72(sp)
    566a:	6906                	ld	s2,64(sp)
    566c:	79e2                	ld	s3,56(sp)
    566e:	7a42                	ld	s4,48(sp)
    5670:	7aa2                	ld	s5,40(sp)
    5672:	7b02                	ld	s6,32(sp)
    5674:	6be2                	ld	s7,24(sp)
    5676:	6125                	addi	sp,sp,96
    5678:	8082                	ret

000000000000567a <stat>:

int
stat(const char *n, struct stat *st)
{
    567a:	1101                	addi	sp,sp,-32
    567c:	ec06                	sd	ra,24(sp)
    567e:	e822                	sd	s0,16(sp)
    5680:	e426                	sd	s1,8(sp)
    5682:	e04a                	sd	s2,0(sp)
    5684:	1000                	addi	s0,sp,32
    5686:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5688:	4581                	li	a1,0
    568a:	00000097          	auipc	ra,0x0
    568e:	172080e7          	jalr	370(ra) # 57fc <open>
  if(fd < 0)
    5692:	02054563          	bltz	a0,56bc <stat+0x42>
    5696:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5698:	85ca                	mv	a1,s2
    569a:	00000097          	auipc	ra,0x0
    569e:	17a080e7          	jalr	378(ra) # 5814 <fstat>
    56a2:	892a                	mv	s2,a0
  close(fd);
    56a4:	8526                	mv	a0,s1
    56a6:	00000097          	auipc	ra,0x0
    56aa:	13e080e7          	jalr	318(ra) # 57e4 <close>
  return r;
}
    56ae:	854a                	mv	a0,s2
    56b0:	60e2                	ld	ra,24(sp)
    56b2:	6442                	ld	s0,16(sp)
    56b4:	64a2                	ld	s1,8(sp)
    56b6:	6902                	ld	s2,0(sp)
    56b8:	6105                	addi	sp,sp,32
    56ba:	8082                	ret
    return -1;
    56bc:	597d                	li	s2,-1
    56be:	bfc5                	j	56ae <stat+0x34>

00000000000056c0 <atoi>:

int
atoi(const char *s)
{
    56c0:	1141                	addi	sp,sp,-16
    56c2:	e422                	sd	s0,8(sp)
    56c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    56c6:	00054603          	lbu	a2,0(a0)
    56ca:	fd06079b          	addiw	a5,a2,-48
    56ce:	0ff7f793          	andi	a5,a5,255
    56d2:	4725                	li	a4,9
    56d4:	02f76963          	bltu	a4,a5,5706 <atoi+0x46>
    56d8:	86aa                	mv	a3,a0
  n = 0;
    56da:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    56dc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    56de:	0685                	addi	a3,a3,1
    56e0:	0025179b          	slliw	a5,a0,0x2
    56e4:	9fa9                	addw	a5,a5,a0
    56e6:	0017979b          	slliw	a5,a5,0x1
    56ea:	9fb1                	addw	a5,a5,a2
    56ec:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    56f0:	0006c603          	lbu	a2,0(a3)
    56f4:	fd06071b          	addiw	a4,a2,-48
    56f8:	0ff77713          	andi	a4,a4,255
    56fc:	fee5f1e3          	bgeu	a1,a4,56de <atoi+0x1e>
  return n;
}
    5700:	6422                	ld	s0,8(sp)
    5702:	0141                	addi	sp,sp,16
    5704:	8082                	ret
  n = 0;
    5706:	4501                	li	a0,0
    5708:	bfe5                	j	5700 <atoi+0x40>

000000000000570a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    570a:	1141                	addi	sp,sp,-16
    570c:	e422                	sd	s0,8(sp)
    570e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5710:	02b57463          	bgeu	a0,a1,5738 <memmove+0x2e>
    while(n-- > 0)
    5714:	00c05f63          	blez	a2,5732 <memmove+0x28>
    5718:	1602                	slli	a2,a2,0x20
    571a:	9201                	srli	a2,a2,0x20
    571c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5720:	872a                	mv	a4,a0
      *dst++ = *src++;
    5722:	0585                	addi	a1,a1,1
    5724:	0705                	addi	a4,a4,1
    5726:	fff5c683          	lbu	a3,-1(a1)
    572a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    572e:	fee79ae3          	bne	a5,a4,5722 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5732:	6422                	ld	s0,8(sp)
    5734:	0141                	addi	sp,sp,16
    5736:	8082                	ret
    dst += n;
    5738:	00c50733          	add	a4,a0,a2
    src += n;
    573c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    573e:	fec05ae3          	blez	a2,5732 <memmove+0x28>
    5742:	fff6079b          	addiw	a5,a2,-1
    5746:	1782                	slli	a5,a5,0x20
    5748:	9381                	srli	a5,a5,0x20
    574a:	fff7c793          	not	a5,a5
    574e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5750:	15fd                	addi	a1,a1,-1
    5752:	177d                	addi	a4,a4,-1
    5754:	0005c683          	lbu	a3,0(a1)
    5758:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    575c:	fee79ae3          	bne	a5,a4,5750 <memmove+0x46>
    5760:	bfc9                	j	5732 <memmove+0x28>

0000000000005762 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5762:	1141                	addi	sp,sp,-16
    5764:	e422                	sd	s0,8(sp)
    5766:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5768:	ca05                	beqz	a2,5798 <memcmp+0x36>
    576a:	fff6069b          	addiw	a3,a2,-1
    576e:	1682                	slli	a3,a3,0x20
    5770:	9281                	srli	a3,a3,0x20
    5772:	0685                	addi	a3,a3,1
    5774:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5776:	00054783          	lbu	a5,0(a0)
    577a:	0005c703          	lbu	a4,0(a1)
    577e:	00e79863          	bne	a5,a4,578e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5782:	0505                	addi	a0,a0,1
    p2++;
    5784:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5786:	fed518e3          	bne	a0,a3,5776 <memcmp+0x14>
  }
  return 0;
    578a:	4501                	li	a0,0
    578c:	a019                	j	5792 <memcmp+0x30>
      return *p1 - *p2;
    578e:	40e7853b          	subw	a0,a5,a4
}
    5792:	6422                	ld	s0,8(sp)
    5794:	0141                	addi	sp,sp,16
    5796:	8082                	ret
  return 0;
    5798:	4501                	li	a0,0
    579a:	bfe5                	j	5792 <memcmp+0x30>

000000000000579c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    579c:	1141                	addi	sp,sp,-16
    579e:	e406                	sd	ra,8(sp)
    57a0:	e022                	sd	s0,0(sp)
    57a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    57a4:	00000097          	auipc	ra,0x0
    57a8:	f66080e7          	jalr	-154(ra) # 570a <memmove>
}
    57ac:	60a2                	ld	ra,8(sp)
    57ae:	6402                	ld	s0,0(sp)
    57b0:	0141                	addi	sp,sp,16
    57b2:	8082                	ret

00000000000057b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    57b4:	4885                	li	a7,1
 ecall
    57b6:	00000073          	ecall
 ret
    57ba:	8082                	ret

00000000000057bc <exit>:
.global exit
exit:
 li a7, SYS_exit
    57bc:	4889                	li	a7,2
 ecall
    57be:	00000073          	ecall
 ret
    57c2:	8082                	ret

00000000000057c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
    57c4:	488d                	li	a7,3
 ecall
    57c6:	00000073          	ecall
 ret
    57ca:	8082                	ret

00000000000057cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    57cc:	4891                	li	a7,4
 ecall
    57ce:	00000073          	ecall
 ret
    57d2:	8082                	ret

00000000000057d4 <read>:
.global read
read:
 li a7, SYS_read
    57d4:	4895                	li	a7,5
 ecall
    57d6:	00000073          	ecall
 ret
    57da:	8082                	ret

00000000000057dc <write>:
.global write
write:
 li a7, SYS_write
    57dc:	48c1                	li	a7,16
 ecall
    57de:	00000073          	ecall
 ret
    57e2:	8082                	ret

00000000000057e4 <close>:
.global close
close:
 li a7, SYS_close
    57e4:	48d5                	li	a7,21
 ecall
    57e6:	00000073          	ecall
 ret
    57ea:	8082                	ret

00000000000057ec <kill>:
.global kill
kill:
 li a7, SYS_kill
    57ec:	4899                	li	a7,6
 ecall
    57ee:	00000073          	ecall
 ret
    57f2:	8082                	ret

00000000000057f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
    57f4:	489d                	li	a7,7
 ecall
    57f6:	00000073          	ecall
 ret
    57fa:	8082                	ret

00000000000057fc <open>:
.global open
open:
 li a7, SYS_open
    57fc:	48bd                	li	a7,15
 ecall
    57fe:	00000073          	ecall
 ret
    5802:	8082                	ret

0000000000005804 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5804:	48c5                	li	a7,17
 ecall
    5806:	00000073          	ecall
 ret
    580a:	8082                	ret

000000000000580c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    580c:	48c9                	li	a7,18
 ecall
    580e:	00000073          	ecall
 ret
    5812:	8082                	ret

0000000000005814 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5814:	48a1                	li	a7,8
 ecall
    5816:	00000073          	ecall
 ret
    581a:	8082                	ret

000000000000581c <link>:
.global link
link:
 li a7, SYS_link
    581c:	48cd                	li	a7,19
 ecall
    581e:	00000073          	ecall
 ret
    5822:	8082                	ret

0000000000005824 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5824:	48d1                	li	a7,20
 ecall
    5826:	00000073          	ecall
 ret
    582a:	8082                	ret

000000000000582c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    582c:	48a5                	li	a7,9
 ecall
    582e:	00000073          	ecall
 ret
    5832:	8082                	ret

0000000000005834 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5834:	48a9                	li	a7,10
 ecall
    5836:	00000073          	ecall
 ret
    583a:	8082                	ret

000000000000583c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    583c:	48ad                	li	a7,11
 ecall
    583e:	00000073          	ecall
 ret
    5842:	8082                	ret

0000000000005844 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5844:	48b1                	li	a7,12
 ecall
    5846:	00000073          	ecall
 ret
    584a:	8082                	ret

000000000000584c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    584c:	48b5                	li	a7,13
 ecall
    584e:	00000073          	ecall
 ret
    5852:	8082                	ret

0000000000005854 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5854:	48b9                	li	a7,14
 ecall
    5856:	00000073          	ecall
 ret
    585a:	8082                	ret

000000000000585c <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
    585c:	48d9                	li	a7,22
 ecall
    585e:	00000073          	ecall
 ret
    5862:	8082                	ret

0000000000005864 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
    5864:	48dd                	li	a7,23
 ecall
    5866:	00000073          	ecall
 ret
    586a:	8082                	ret

000000000000586c <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
    586c:	48e1                	li	a7,24
 ecall
    586e:	00000073          	ecall
 ret
    5872:	8082                	ret

0000000000005874 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
    5874:	48e5                	li	a7,25
 ecall
    5876:	00000073          	ecall
 ret
    587a:	8082                	ret

000000000000587c <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
    587c:	48e9                	li	a7,26
 ecall
    587e:	00000073          	ecall
 ret
    5882:	8082                	ret

0000000000005884 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
    5884:	48ed                	li	a7,27
 ecall
    5886:	00000073          	ecall
 ret
    588a:	8082                	ret

000000000000588c <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
    588c:	48f1                	li	a7,28
 ecall
    588e:	00000073          	ecall
 ret
    5892:	8082                	ret

0000000000005894 <bsem_alloc>:
.global bsem_alloc
bsem_alloc:
 li a7, SYS_bsem_alloc
    5894:	48f5                	li	a7,29
 ecall
    5896:	00000073          	ecall
 ret
    589a:	8082                	ret

000000000000589c <bsem_free>:
.global bsem_free
bsem_free:
 li a7, SYS_bsem_free
    589c:	48f9                	li	a7,30
 ecall
    589e:	00000073          	ecall
 ret
    58a2:	8082                	ret

00000000000058a4 <bsem_down>:
.global bsem_down
bsem_down:
 li a7, SYS_bsem_down
    58a4:	48fd                	li	a7,31
 ecall
    58a6:	00000073          	ecall
 ret
    58aa:	8082                	ret

00000000000058ac <bsem_up>:
.global bsem_up
bsem_up:
 li a7, SYS_bsem_up
    58ac:	02000893          	li	a7,32
 ecall
    58b0:	00000073          	ecall
 ret
    58b4:	8082                	ret

00000000000058b6 <csem_alloc>:
.global csem_alloc
csem_alloc:
 li a7, SYS_csem_alloc
    58b6:	02100893          	li	a7,33
 ecall
    58ba:	00000073          	ecall
 ret
    58be:	8082                	ret

00000000000058c0 <csem_free>:
.global csem_free
csem_free:
 li a7, SYS_csem_free
    58c0:	02200893          	li	a7,34
 ecall
    58c4:	00000073          	ecall
 ret
    58c8:	8082                	ret

00000000000058ca <csem_down>:
.global csem_down
csem_down:
 li a7, SYS_csem_down
    58ca:	02300893          	li	a7,35
 ecall
    58ce:	00000073          	ecall
 ret
    58d2:	8082                	ret

00000000000058d4 <csem_up>:
.global csem_up
csem_up:
 li a7, SYS_csem_up
    58d4:	02400893          	li	a7,36
 ecall
    58d8:	00000073          	ecall
 ret
    58dc:	8082                	ret

00000000000058de <print_ptable>:
.global print_ptable
print_ptable:
 li a7, SYS_print_ptable
    58de:	02500893          	li	a7,37
 ecall
    58e2:	00000073          	ecall
 ret
    58e6:	8082                	ret

00000000000058e8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    58e8:	1101                	addi	sp,sp,-32
    58ea:	ec06                	sd	ra,24(sp)
    58ec:	e822                	sd	s0,16(sp)
    58ee:	1000                	addi	s0,sp,32
    58f0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    58f4:	4605                	li	a2,1
    58f6:	fef40593          	addi	a1,s0,-17
    58fa:	00000097          	auipc	ra,0x0
    58fe:	ee2080e7          	jalr	-286(ra) # 57dc <write>
}
    5902:	60e2                	ld	ra,24(sp)
    5904:	6442                	ld	s0,16(sp)
    5906:	6105                	addi	sp,sp,32
    5908:	8082                	ret

000000000000590a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    590a:	7139                	addi	sp,sp,-64
    590c:	fc06                	sd	ra,56(sp)
    590e:	f822                	sd	s0,48(sp)
    5910:	f426                	sd	s1,40(sp)
    5912:	f04a                	sd	s2,32(sp)
    5914:	ec4e                	sd	s3,24(sp)
    5916:	0080                	addi	s0,sp,64
    5918:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    591a:	c299                	beqz	a3,5920 <printint+0x16>
    591c:	0805c863          	bltz	a1,59ac <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5920:	2581                	sext.w	a1,a1
  neg = 0;
    5922:	4881                	li	a7,0
    5924:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5928:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    592a:	2601                	sext.w	a2,a2
    592c:	00002517          	auipc	a0,0x2
    5930:	76450513          	addi	a0,a0,1892 # 8090 <digits>
    5934:	883a                	mv	a6,a4
    5936:	2705                	addiw	a4,a4,1
    5938:	02c5f7bb          	remuw	a5,a1,a2
    593c:	1782                	slli	a5,a5,0x20
    593e:	9381                	srli	a5,a5,0x20
    5940:	97aa                	add	a5,a5,a0
    5942:	0007c783          	lbu	a5,0(a5)
    5946:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    594a:	0005879b          	sext.w	a5,a1
    594e:	02c5d5bb          	divuw	a1,a1,a2
    5952:	0685                	addi	a3,a3,1
    5954:	fec7f0e3          	bgeu	a5,a2,5934 <printint+0x2a>
  if(neg)
    5958:	00088b63          	beqz	a7,596e <printint+0x64>
    buf[i++] = '-';
    595c:	fd040793          	addi	a5,s0,-48
    5960:	973e                	add	a4,a4,a5
    5962:	02d00793          	li	a5,45
    5966:	fef70823          	sb	a5,-16(a4)
    596a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    596e:	02e05863          	blez	a4,599e <printint+0x94>
    5972:	fc040793          	addi	a5,s0,-64
    5976:	00e78933          	add	s2,a5,a4
    597a:	fff78993          	addi	s3,a5,-1
    597e:	99ba                	add	s3,s3,a4
    5980:	377d                	addiw	a4,a4,-1
    5982:	1702                	slli	a4,a4,0x20
    5984:	9301                	srli	a4,a4,0x20
    5986:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    598a:	fff94583          	lbu	a1,-1(s2)
    598e:	8526                	mv	a0,s1
    5990:	00000097          	auipc	ra,0x0
    5994:	f58080e7          	jalr	-168(ra) # 58e8 <putc>
  while(--i >= 0)
    5998:	197d                	addi	s2,s2,-1
    599a:	ff3918e3          	bne	s2,s3,598a <printint+0x80>
}
    599e:	70e2                	ld	ra,56(sp)
    59a0:	7442                	ld	s0,48(sp)
    59a2:	74a2                	ld	s1,40(sp)
    59a4:	7902                	ld	s2,32(sp)
    59a6:	69e2                	ld	s3,24(sp)
    59a8:	6121                	addi	sp,sp,64
    59aa:	8082                	ret
    x = -xx;
    59ac:	40b005bb          	negw	a1,a1
    neg = 1;
    59b0:	4885                	li	a7,1
    x = -xx;
    59b2:	bf8d                	j	5924 <printint+0x1a>

00000000000059b4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    59b4:	7119                	addi	sp,sp,-128
    59b6:	fc86                	sd	ra,120(sp)
    59b8:	f8a2                	sd	s0,112(sp)
    59ba:	f4a6                	sd	s1,104(sp)
    59bc:	f0ca                	sd	s2,96(sp)
    59be:	ecce                	sd	s3,88(sp)
    59c0:	e8d2                	sd	s4,80(sp)
    59c2:	e4d6                	sd	s5,72(sp)
    59c4:	e0da                	sd	s6,64(sp)
    59c6:	fc5e                	sd	s7,56(sp)
    59c8:	f862                	sd	s8,48(sp)
    59ca:	f466                	sd	s9,40(sp)
    59cc:	f06a                	sd	s10,32(sp)
    59ce:	ec6e                	sd	s11,24(sp)
    59d0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    59d2:	0005c903          	lbu	s2,0(a1)
    59d6:	18090f63          	beqz	s2,5b74 <vprintf+0x1c0>
    59da:	8aaa                	mv	s5,a0
    59dc:	8b32                	mv	s6,a2
    59de:	00158493          	addi	s1,a1,1
  state = 0;
    59e2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    59e4:	02500a13          	li	s4,37
      if(c == 'd'){
    59e8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    59ec:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    59f0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    59f4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    59f8:	00002b97          	auipc	s7,0x2
    59fc:	698b8b93          	addi	s7,s7,1688 # 8090 <digits>
    5a00:	a839                	j	5a1e <vprintf+0x6a>
        putc(fd, c);
    5a02:	85ca                	mv	a1,s2
    5a04:	8556                	mv	a0,s5
    5a06:	00000097          	auipc	ra,0x0
    5a0a:	ee2080e7          	jalr	-286(ra) # 58e8 <putc>
    5a0e:	a019                	j	5a14 <vprintf+0x60>
    } else if(state == '%'){
    5a10:	01498f63          	beq	s3,s4,5a2e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5a14:	0485                	addi	s1,s1,1
    5a16:	fff4c903          	lbu	s2,-1(s1)
    5a1a:	14090d63          	beqz	s2,5b74 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5a1e:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5a22:	fe0997e3          	bnez	s3,5a10 <vprintf+0x5c>
      if(c == '%'){
    5a26:	fd479ee3          	bne	a5,s4,5a02 <vprintf+0x4e>
        state = '%';
    5a2a:	89be                	mv	s3,a5
    5a2c:	b7e5                	j	5a14 <vprintf+0x60>
      if(c == 'd'){
    5a2e:	05878063          	beq	a5,s8,5a6e <vprintf+0xba>
      } else if(c == 'l') {
    5a32:	05978c63          	beq	a5,s9,5a8a <vprintf+0xd6>
      } else if(c == 'x') {
    5a36:	07a78863          	beq	a5,s10,5aa6 <vprintf+0xf2>
      } else if(c == 'p') {
    5a3a:	09b78463          	beq	a5,s11,5ac2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5a3e:	07300713          	li	a4,115
    5a42:	0ce78663          	beq	a5,a4,5b0e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5a46:	06300713          	li	a4,99
    5a4a:	0ee78e63          	beq	a5,a4,5b46 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5a4e:	11478863          	beq	a5,s4,5b5e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5a52:	85d2                	mv	a1,s4
    5a54:	8556                	mv	a0,s5
    5a56:	00000097          	auipc	ra,0x0
    5a5a:	e92080e7          	jalr	-366(ra) # 58e8 <putc>
        putc(fd, c);
    5a5e:	85ca                	mv	a1,s2
    5a60:	8556                	mv	a0,s5
    5a62:	00000097          	auipc	ra,0x0
    5a66:	e86080e7          	jalr	-378(ra) # 58e8 <putc>
      }
      state = 0;
    5a6a:	4981                	li	s3,0
    5a6c:	b765                	j	5a14 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5a6e:	008b0913          	addi	s2,s6,8
    5a72:	4685                	li	a3,1
    5a74:	4629                	li	a2,10
    5a76:	000b2583          	lw	a1,0(s6)
    5a7a:	8556                	mv	a0,s5
    5a7c:	00000097          	auipc	ra,0x0
    5a80:	e8e080e7          	jalr	-370(ra) # 590a <printint>
    5a84:	8b4a                	mv	s6,s2
      state = 0;
    5a86:	4981                	li	s3,0
    5a88:	b771                	j	5a14 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5a8a:	008b0913          	addi	s2,s6,8
    5a8e:	4681                	li	a3,0
    5a90:	4629                	li	a2,10
    5a92:	000b2583          	lw	a1,0(s6)
    5a96:	8556                	mv	a0,s5
    5a98:	00000097          	auipc	ra,0x0
    5a9c:	e72080e7          	jalr	-398(ra) # 590a <printint>
    5aa0:	8b4a                	mv	s6,s2
      state = 0;
    5aa2:	4981                	li	s3,0
    5aa4:	bf85                	j	5a14 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5aa6:	008b0913          	addi	s2,s6,8
    5aaa:	4681                	li	a3,0
    5aac:	4641                	li	a2,16
    5aae:	000b2583          	lw	a1,0(s6)
    5ab2:	8556                	mv	a0,s5
    5ab4:	00000097          	auipc	ra,0x0
    5ab8:	e56080e7          	jalr	-426(ra) # 590a <printint>
    5abc:	8b4a                	mv	s6,s2
      state = 0;
    5abe:	4981                	li	s3,0
    5ac0:	bf91                	j	5a14 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5ac2:	008b0793          	addi	a5,s6,8
    5ac6:	f8f43423          	sd	a5,-120(s0)
    5aca:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5ace:	03000593          	li	a1,48
    5ad2:	8556                	mv	a0,s5
    5ad4:	00000097          	auipc	ra,0x0
    5ad8:	e14080e7          	jalr	-492(ra) # 58e8 <putc>
  putc(fd, 'x');
    5adc:	85ea                	mv	a1,s10
    5ade:	8556                	mv	a0,s5
    5ae0:	00000097          	auipc	ra,0x0
    5ae4:	e08080e7          	jalr	-504(ra) # 58e8 <putc>
    5ae8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5aea:	03c9d793          	srli	a5,s3,0x3c
    5aee:	97de                	add	a5,a5,s7
    5af0:	0007c583          	lbu	a1,0(a5)
    5af4:	8556                	mv	a0,s5
    5af6:	00000097          	auipc	ra,0x0
    5afa:	df2080e7          	jalr	-526(ra) # 58e8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5afe:	0992                	slli	s3,s3,0x4
    5b00:	397d                	addiw	s2,s2,-1
    5b02:	fe0914e3          	bnez	s2,5aea <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5b06:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5b0a:	4981                	li	s3,0
    5b0c:	b721                	j	5a14 <vprintf+0x60>
        s = va_arg(ap, char*);
    5b0e:	008b0993          	addi	s3,s6,8
    5b12:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5b16:	02090163          	beqz	s2,5b38 <vprintf+0x184>
        while(*s != 0){
    5b1a:	00094583          	lbu	a1,0(s2)
    5b1e:	c9a1                	beqz	a1,5b6e <vprintf+0x1ba>
          putc(fd, *s);
    5b20:	8556                	mv	a0,s5
    5b22:	00000097          	auipc	ra,0x0
    5b26:	dc6080e7          	jalr	-570(ra) # 58e8 <putc>
          s++;
    5b2a:	0905                	addi	s2,s2,1
        while(*s != 0){
    5b2c:	00094583          	lbu	a1,0(s2)
    5b30:	f9e5                	bnez	a1,5b20 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5b32:	8b4e                	mv	s6,s3
      state = 0;
    5b34:	4981                	li	s3,0
    5b36:	bdf9                	j	5a14 <vprintf+0x60>
          s = "(null)";
    5b38:	00002917          	auipc	s2,0x2
    5b3c:	55090913          	addi	s2,s2,1360 # 8088 <malloc+0x240a>
        while(*s != 0){
    5b40:	02800593          	li	a1,40
    5b44:	bff1                	j	5b20 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5b46:	008b0913          	addi	s2,s6,8
    5b4a:	000b4583          	lbu	a1,0(s6)
    5b4e:	8556                	mv	a0,s5
    5b50:	00000097          	auipc	ra,0x0
    5b54:	d98080e7          	jalr	-616(ra) # 58e8 <putc>
    5b58:	8b4a                	mv	s6,s2
      state = 0;
    5b5a:	4981                	li	s3,0
    5b5c:	bd65                	j	5a14 <vprintf+0x60>
        putc(fd, c);
    5b5e:	85d2                	mv	a1,s4
    5b60:	8556                	mv	a0,s5
    5b62:	00000097          	auipc	ra,0x0
    5b66:	d86080e7          	jalr	-634(ra) # 58e8 <putc>
      state = 0;
    5b6a:	4981                	li	s3,0
    5b6c:	b565                	j	5a14 <vprintf+0x60>
        s = va_arg(ap, char*);
    5b6e:	8b4e                	mv	s6,s3
      state = 0;
    5b70:	4981                	li	s3,0
    5b72:	b54d                	j	5a14 <vprintf+0x60>
    }
  }
}
    5b74:	70e6                	ld	ra,120(sp)
    5b76:	7446                	ld	s0,112(sp)
    5b78:	74a6                	ld	s1,104(sp)
    5b7a:	7906                	ld	s2,96(sp)
    5b7c:	69e6                	ld	s3,88(sp)
    5b7e:	6a46                	ld	s4,80(sp)
    5b80:	6aa6                	ld	s5,72(sp)
    5b82:	6b06                	ld	s6,64(sp)
    5b84:	7be2                	ld	s7,56(sp)
    5b86:	7c42                	ld	s8,48(sp)
    5b88:	7ca2                	ld	s9,40(sp)
    5b8a:	7d02                	ld	s10,32(sp)
    5b8c:	6de2                	ld	s11,24(sp)
    5b8e:	6109                	addi	sp,sp,128
    5b90:	8082                	ret

0000000000005b92 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5b92:	715d                	addi	sp,sp,-80
    5b94:	ec06                	sd	ra,24(sp)
    5b96:	e822                	sd	s0,16(sp)
    5b98:	1000                	addi	s0,sp,32
    5b9a:	e010                	sd	a2,0(s0)
    5b9c:	e414                	sd	a3,8(s0)
    5b9e:	e818                	sd	a4,16(s0)
    5ba0:	ec1c                	sd	a5,24(s0)
    5ba2:	03043023          	sd	a6,32(s0)
    5ba6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5baa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5bae:	8622                	mv	a2,s0
    5bb0:	00000097          	auipc	ra,0x0
    5bb4:	e04080e7          	jalr	-508(ra) # 59b4 <vprintf>
}
    5bb8:	60e2                	ld	ra,24(sp)
    5bba:	6442                	ld	s0,16(sp)
    5bbc:	6161                	addi	sp,sp,80
    5bbe:	8082                	ret

0000000000005bc0 <printf>:

void
printf(const char *fmt, ...)
{
    5bc0:	711d                	addi	sp,sp,-96
    5bc2:	ec06                	sd	ra,24(sp)
    5bc4:	e822                	sd	s0,16(sp)
    5bc6:	1000                	addi	s0,sp,32
    5bc8:	e40c                	sd	a1,8(s0)
    5bca:	e810                	sd	a2,16(s0)
    5bcc:	ec14                	sd	a3,24(s0)
    5bce:	f018                	sd	a4,32(s0)
    5bd0:	f41c                	sd	a5,40(s0)
    5bd2:	03043823          	sd	a6,48(s0)
    5bd6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5bda:	00840613          	addi	a2,s0,8
    5bde:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5be2:	85aa                	mv	a1,a0
    5be4:	4505                	li	a0,1
    5be6:	00000097          	auipc	ra,0x0
    5bea:	dce080e7          	jalr	-562(ra) # 59b4 <vprintf>
}
    5bee:	60e2                	ld	ra,24(sp)
    5bf0:	6442                	ld	s0,16(sp)
    5bf2:	6125                	addi	sp,sp,96
    5bf4:	8082                	ret

0000000000005bf6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5bf6:	1141                	addi	sp,sp,-16
    5bf8:	e422                	sd	s0,8(sp)
    5bfa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5bfc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c00:	00002797          	auipc	a5,0x2
    5c04:	4c07b783          	ld	a5,1216(a5) # 80c0 <freep>
    5c08:	a805                	j	5c38 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5c0a:	4618                	lw	a4,8(a2)
    5c0c:	9db9                	addw	a1,a1,a4
    5c0e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5c12:	6398                	ld	a4,0(a5)
    5c14:	6318                	ld	a4,0(a4)
    5c16:	fee53823          	sd	a4,-16(a0)
    5c1a:	a091                	j	5c5e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5c1c:	ff852703          	lw	a4,-8(a0)
    5c20:	9e39                	addw	a2,a2,a4
    5c22:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5c24:	ff053703          	ld	a4,-16(a0)
    5c28:	e398                	sd	a4,0(a5)
    5c2a:	a099                	j	5c70 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c2c:	6398                	ld	a4,0(a5)
    5c2e:	00e7e463          	bltu	a5,a4,5c36 <free+0x40>
    5c32:	00e6ea63          	bltu	a3,a4,5c46 <free+0x50>
{
    5c36:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c38:	fed7fae3          	bgeu	a5,a3,5c2c <free+0x36>
    5c3c:	6398                	ld	a4,0(a5)
    5c3e:	00e6e463          	bltu	a3,a4,5c46 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c42:	fee7eae3          	bltu	a5,a4,5c36 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5c46:	ff852583          	lw	a1,-8(a0)
    5c4a:	6390                	ld	a2,0(a5)
    5c4c:	02059813          	slli	a6,a1,0x20
    5c50:	01c85713          	srli	a4,a6,0x1c
    5c54:	9736                	add	a4,a4,a3
    5c56:	fae60ae3          	beq	a2,a4,5c0a <free+0x14>
    bp->s.ptr = p->s.ptr;
    5c5a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5c5e:	4790                	lw	a2,8(a5)
    5c60:	02061593          	slli	a1,a2,0x20
    5c64:	01c5d713          	srli	a4,a1,0x1c
    5c68:	973e                	add	a4,a4,a5
    5c6a:	fae689e3          	beq	a3,a4,5c1c <free+0x26>
  } else
    p->s.ptr = bp;
    5c6e:	e394                	sd	a3,0(a5)
  freep = p;
    5c70:	00002717          	auipc	a4,0x2
    5c74:	44f73823          	sd	a5,1104(a4) # 80c0 <freep>
}
    5c78:	6422                	ld	s0,8(sp)
    5c7a:	0141                	addi	sp,sp,16
    5c7c:	8082                	ret

0000000000005c7e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5c7e:	7139                	addi	sp,sp,-64
    5c80:	fc06                	sd	ra,56(sp)
    5c82:	f822                	sd	s0,48(sp)
    5c84:	f426                	sd	s1,40(sp)
    5c86:	f04a                	sd	s2,32(sp)
    5c88:	ec4e                	sd	s3,24(sp)
    5c8a:	e852                	sd	s4,16(sp)
    5c8c:	e456                	sd	s5,8(sp)
    5c8e:	e05a                	sd	s6,0(sp)
    5c90:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5c92:	02051493          	slli	s1,a0,0x20
    5c96:	9081                	srli	s1,s1,0x20
    5c98:	04bd                	addi	s1,s1,15
    5c9a:	8091                	srli	s1,s1,0x4
    5c9c:	0014899b          	addiw	s3,s1,1
    5ca0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5ca2:	00002517          	auipc	a0,0x2
    5ca6:	41e53503          	ld	a0,1054(a0) # 80c0 <freep>
    5caa:	c515                	beqz	a0,5cd6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5cac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5cae:	4798                	lw	a4,8(a5)
    5cb0:	02977f63          	bgeu	a4,s1,5cee <malloc+0x70>
    5cb4:	8a4e                	mv	s4,s3
    5cb6:	0009871b          	sext.w	a4,s3
    5cba:	6685                	lui	a3,0x1
    5cbc:	00d77363          	bgeu	a4,a3,5cc2 <malloc+0x44>
    5cc0:	6a05                	lui	s4,0x1
    5cc2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5cc6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5cca:	00002917          	auipc	s2,0x2
    5cce:	3f690913          	addi	s2,s2,1014 # 80c0 <freep>
  if(p == (char*)-1)
    5cd2:	5afd                	li	s5,-1
    5cd4:	a895                	j	5d48 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    5cd6:	00009797          	auipc	a5,0x9
    5cda:	c0a78793          	addi	a5,a5,-1014 # e8e0 <base>
    5cde:	00002717          	auipc	a4,0x2
    5ce2:	3ef73123          	sd	a5,994(a4) # 80c0 <freep>
    5ce6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5ce8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5cec:	b7e1                	j	5cb4 <malloc+0x36>
      if(p->s.size == nunits)
    5cee:	02e48c63          	beq	s1,a4,5d26 <malloc+0xa8>
        p->s.size -= nunits;
    5cf2:	4137073b          	subw	a4,a4,s3
    5cf6:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5cf8:	02071693          	slli	a3,a4,0x20
    5cfc:	01c6d713          	srli	a4,a3,0x1c
    5d00:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5d02:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5d06:	00002717          	auipc	a4,0x2
    5d0a:	3aa73d23          	sd	a0,954(a4) # 80c0 <freep>
      return (void*)(p + 1);
    5d0e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5d12:	70e2                	ld	ra,56(sp)
    5d14:	7442                	ld	s0,48(sp)
    5d16:	74a2                	ld	s1,40(sp)
    5d18:	7902                	ld	s2,32(sp)
    5d1a:	69e2                	ld	s3,24(sp)
    5d1c:	6a42                	ld	s4,16(sp)
    5d1e:	6aa2                	ld	s5,8(sp)
    5d20:	6b02                	ld	s6,0(sp)
    5d22:	6121                	addi	sp,sp,64
    5d24:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5d26:	6398                	ld	a4,0(a5)
    5d28:	e118                	sd	a4,0(a0)
    5d2a:	bff1                	j	5d06 <malloc+0x88>
  hp->s.size = nu;
    5d2c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5d30:	0541                	addi	a0,a0,16
    5d32:	00000097          	auipc	ra,0x0
    5d36:	ec4080e7          	jalr	-316(ra) # 5bf6 <free>
  return freep;
    5d3a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5d3e:	d971                	beqz	a0,5d12 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5d40:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5d42:	4798                	lw	a4,8(a5)
    5d44:	fa9775e3          	bgeu	a4,s1,5cee <malloc+0x70>
    if(p == freep)
    5d48:	00093703          	ld	a4,0(s2)
    5d4c:	853e                	mv	a0,a5
    5d4e:	fef719e3          	bne	a4,a5,5d40 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    5d52:	8552                	mv	a0,s4
    5d54:	00000097          	auipc	ra,0x0
    5d58:	af0080e7          	jalr	-1296(ra) # 5844 <sbrk>
  if(p == (char*)-1)
    5d5c:	fd5518e3          	bne	a0,s5,5d2c <malloc+0xae>
        return 0;
    5d60:	4501                	li	a0,0
    5d62:	bf45                	j	5d12 <malloc+0x94>
