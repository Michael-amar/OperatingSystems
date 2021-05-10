
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	18010113          	addi	sp,sp,384 # 8000a180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	0000a717          	auipc	a4,0xa
    80000056:	fee70713          	addi	a4,a4,-18 # 8000a040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00007797          	auipc	a5,0x7
    80000068:	b1c78793          	addi	a5,a5,-1252 # 80006b80 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb97ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	75e080e7          	jalr	1886(ra) # 8000287c <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00012517          	auipc	a0,0x12
    80000180:	00450513          	addi	a0,a0,4 # 80012180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00012497          	auipc	s1,0x12
    80000190:	ff448493          	addi	s1,s1,-12 # 80012180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00012917          	auipc	s2,0x12
    80000198:	08490913          	addi	s2,s2,132 # 80012218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	a42080e7          	jalr	-1470(ra) # 80001bf4 <myproc>
    800001ba:	4d5c                	lw	a5,28(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	264080e7          	jalr	612(ra) # 80002426 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	628080e7          	jalr	1576(ra) # 80002826 <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00012517          	auipc	a0,0x12
    80000216:	f6e50513          	addi	a0,a0,-146 # 80012180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00012517          	auipc	a0,0x12
    8000022c:	f5850513          	addi	a0,a0,-168 # 80012180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00012717          	auipc	a4,0x12
    80000262:	faf72d23          	sw	a5,-70(a4) # 80012218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00012517          	auipc	a0,0x12
    800002bc:	ec850513          	addi	a0,a0,-312 # 80012180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	5f4080e7          	jalr	1524(ra) # 800028d2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00012517          	auipc	a0,0x12
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80012180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00012717          	auipc	a4,0x12
    8000030e:	e7670713          	addi	a4,a4,-394 # 80012180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00012797          	auipc	a5,0x12
    80000338:	e4c78793          	addi	a5,a5,-436 # 80012180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00012797          	auipc	a5,0x12
    80000366:	eb67a783          	lw	a5,-330(a5) # 80012218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00012717          	auipc	a4,0x12
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80012180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00012497          	auipc	s1,0x12
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80012180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00012717          	auipc	a4,0x12
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80012180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00012717          	auipc	a4,0x12
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80012220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00012797          	auipc	a5,0x12
    80000402:	d8278793          	addi	a5,a5,-638 # 80012180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00012797          	auipc	a5,0x12
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001221c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00012517          	auipc	a0,0x12
    8000042e:	dee50513          	addi	a0,a0,-530 # 80012218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	17c080e7          	jalr	380(ra) # 800025ae <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00009597          	auipc	a1,0x9
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80009010 <etext+0x10>
    8000044c:	00012517          	auipc	a0,0x12
    80000450:	d3450513          	addi	a0,a0,-716 # 80012180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00040797          	auipc	a5,0x40
    80000468:	6cc78793          	addi	a5,a5,1740 # 80040b30 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00009617          	auipc	a2,0x9
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80009040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00012797          	auipc	a5,0x12
    8000053a:	d007a523          	sw	zero,-758(a5) # 80012240 <pr+0x18>
  printf("panic: ");
    8000053e:	00009517          	auipc	a0,0x9
    80000542:	ada50513          	addi	a0,a0,-1318 # 80009018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00009517          	auipc	a0,0x9
    8000055c:	b7050513          	addi	a0,a0,-1168 # 800090c8 <digits+0x88>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	0000a717          	auipc	a4,0xa
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 8000a000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00012d97          	auipc	s11,0x12
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80012240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00009b17          	auipc	s6,0x9
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80009040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00012517          	auipc	a0,0x12
    800005e8:	c4450513          	addi	a0,a0,-956 # 80012228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00009517          	auipc	a0,0x9
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80009028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00009497          	auipc	s1,0x9
    800006f4:	93048493          	addi	s1,s1,-1744 # 80009020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00012517          	auipc	a0,0x12
    80000746:	ae650513          	addi	a0,a0,-1306 # 80012228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00012497          	auipc	s1,0x12
    80000762:	aca48493          	addi	s1,s1,-1334 # 80012228 <pr>
    80000766:	00009597          	auipc	a1,0x9
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80009038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00009597          	auipc	a1,0x9
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80009058 <digits+0x18>
    800007be:	00012517          	auipc	a0,0x12
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80012248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	0000a797          	auipc	a5,0xa
    800007ee:	8167a783          	lw	a5,-2026(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00009797          	auipc	a5,0x9
    80000826:	7e67b783          	ld	a5,2022(a5) # 8000a008 <uart_tx_r>
    8000082a:	00009717          	auipc	a4,0x9
    8000082e:	7e673703          	ld	a4,2022(a4) # 8000a010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00012a17          	auipc	s4,0x12
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80012248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00009497          	auipc	s1,0x9
    80000858:	7b448493          	addi	s1,s1,1972 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00009997          	auipc	s3,0x9
    80000860:	7b498993          	addi	s3,s3,1972 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	d30080e7          	jalr	-720(ra) # 800025ae <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00012517          	auipc	a0,0x12
    800008be:	98e50513          	addi	a0,a0,-1650 # 80012248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00009797          	auipc	a5,0x9
    800008ce:	7367a783          	lw	a5,1846(a5) # 8000a000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00009717          	auipc	a4,0x9
    800008da:	73a73703          	ld	a4,1850(a4) # 8000a010 <uart_tx_w>
    800008de:	00009797          	auipc	a5,0x9
    800008e2:	72a7b783          	ld	a5,1834(a5) # 8000a008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00012997          	auipc	s3,0x12
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80012248 <uart_tx_lock>
    800008f6:	00009497          	auipc	s1,0x9
    800008fa:	71248493          	addi	s1,s1,1810 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00009917          	auipc	s2,0x9
    80000902:	71290913          	addi	s2,s2,1810 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	b1c080e7          	jalr	-1252(ra) # 80002426 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00012497          	auipc	s1,0x12
    80000924:	92848493          	addi	s1,s1,-1752 # 80012248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00009797          	auipc	a5,0x9
    80000938:	6ce7be23          	sd	a4,1756(a5) # 8000a010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80012248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	00044797          	auipc	a5,0x44
    800009ee:	61678793          	addi	a5,a5,1558 # 80045000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00012917          	auipc	s2,0x12
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80012280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00008517          	auipc	a0,0x8
    80000a40:	62450513          	addi	a0,a0,1572 # 80009060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00008597          	auipc	a1,0x8
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80009068 <digits+0x28>
    80000aa6:	00011517          	auipc	a0,0x11
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80012280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00044517          	auipc	a0,0x44
    80000abe:	54650513          	addi	a0,a0,1350 # 80045000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00011497          	auipc	s1,0x11
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80012280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	78c50513          	addi	a0,a0,1932 # 80012280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00011517          	auipc	a0,0x11
    80000b24:	76050513          	addi	a0,a0,1888 # 80012280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	07c080e7          	jalr	124(ra) # 80001bd8 <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	04a080e7          	jalr	74(ra) # 80001bd8 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	03e080e7          	jalr	62(ra) # 80001bd8 <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	026080e7          	jalr	38(ra) # 80001bd8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	fe6080e7          	jalr	-26(ra) # 80001bd8 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00008517          	auipc	a0,0x8
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80009070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	fba080e7          	jalr	-70(ra) # 80001bd8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00008517          	auipc	a0,0x8
    80000c5a:	42250513          	addi	a0,a0,1058 # 80009078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00008517          	auipc	a0,0x8
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80009090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00008517          	auipc	a0,0x8
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80009098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	d54080e7          	jalr	-684(ra) # 80001bc8 <cpuid>
    userinit();      // first user process
    semaphoresinit();
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00009717          	auipc	a4,0x9
    80000e80:	19c70713          	addi	a4,a4,412 # 8000a018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	d38080e7          	jalr	-712(ra) # 80001bc8 <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00008517          	auipc	a0,0x8
    80000e9e:	21e50513          	addi	a0,a0,542 # 800090b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0e0080e7          	jalr	224(ra) # 80000f8a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	136080e7          	jalr	310(ra) # 80002fe8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	d06080e7          	jalr	-762(ra) # 80006bc0 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	316080e7          	jalr	790(ra) # 800021d8 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	1ee50513          	addi	a0,a0,494 # 800090c8 <digits+0x88>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	1ce50513          	addi	a0,a0,462 # 800090c8 <digits+0x88>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	318080e7          	jalr	792(ra) # 8000122a <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	070080e7          	jalr	112(ra) # 80000f8a <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	b90080e7          	jalr	-1136(ra) # 80001ab2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	096080e7          	jalr	150(ra) # 80002fc0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	0b6080e7          	jalr	182(ra) # 80002fe8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	c70080e7          	jalr	-912(ra) # 80006baa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	c7e080e7          	jalr	-898(ra) # 80006bc0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00003097          	auipc	ra,0x3
    80000f4e:	e18080e7          	jalr	-488(ra) # 80003d62 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	4aa080e7          	jalr	1194(ra) # 800043fc <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	456080e7          	jalr	1110(ra) # 800053b0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	d80080e7          	jalr	-640(ra) # 80006ce2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	fd2080e7          	jalr	-46(ra) # 80001f3c <userinit>
    semaphoresinit();
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	c58080e7          	jalr	-936(ra) # 80002bca <semaphoresinit>
    __sync_synchronize();
    80000f7a:	0ff0000f          	fence
    started = 1;
    80000f7e:	4785                	li	a5,1
    80000f80:	00009717          	auipc	a4,0x9
    80000f84:	08f72c23          	sw	a5,152(a4) # 8000a018 <started>
    80000f88:	bf2d                	j	80000ec2 <main+0x56>

0000000080000f8a <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8a:	1141                	addi	sp,sp,-16
    80000f8c:	e422                	sd	s0,8(sp)
    80000f8e:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f90:	00009797          	auipc	a5,0x9
    80000f94:	0907b783          	ld	a5,144(a5) # 8000a020 <kernel_pagetable>
    80000f98:	83b1                	srli	a5,a5,0xc
    80000f9a:	577d                	li	a4,-1
    80000f9c:	177e                	slli	a4,a4,0x3f
    80000f9e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa0:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa4:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa8:	6422                	ld	s0,8(sp)
    80000faa:	0141                	addi	sp,sp,16
    80000fac:	8082                	ret

0000000080000fae <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fae:	7139                	addi	sp,sp,-64
    80000fb0:	fc06                	sd	ra,56(sp)
    80000fb2:	f822                	sd	s0,48(sp)
    80000fb4:	f426                	sd	s1,40(sp)
    80000fb6:	f04a                	sd	s2,32(sp)
    80000fb8:	ec4e                	sd	s3,24(sp)
    80000fba:	e852                	sd	s4,16(sp)
    80000fbc:	e456                	sd	s5,8(sp)
    80000fbe:	e05a                	sd	s6,0(sp)
    80000fc0:	0080                	addi	s0,sp,64
    80000fc2:	84aa                	mv	s1,a0
    80000fc4:	89ae                	mv	s3,a1
    80000fc6:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc8:	57fd                	li	a5,-1
    80000fca:	83e9                	srli	a5,a5,0x1a
    80000fcc:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fce:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd0:	04b7f263          	bgeu	a5,a1,80001014 <walk+0x66>
    panic("walk");
    80000fd4:	00008517          	auipc	a0,0x8
    80000fd8:	0fc50513          	addi	a0,a0,252 # 800090d0 <digits+0x90>
    80000fdc:	fffff097          	auipc	ra,0xfffff
    80000fe0:	54e080e7          	jalr	1358(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe4:	060a8663          	beqz	s5,80001050 <walk+0xa2>
    80000fe8:	00000097          	auipc	ra,0x0
    80000fec:	aea080e7          	jalr	-1302(ra) # 80000ad2 <kalloc>
    80000ff0:	84aa                	mv	s1,a0
    80000ff2:	c529                	beqz	a0,8000103c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff4:	6605                	lui	a2,0x1
    80000ff6:	4581                	li	a1,0
    80000ff8:	00000097          	auipc	ra,0x0
    80000ffc:	cc6080e7          	jalr	-826(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001000:	00c4d793          	srli	a5,s1,0xc
    80001004:	07aa                	slli	a5,a5,0xa
    80001006:	0017e793          	ori	a5,a5,1
    8000100a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000100e:	3a5d                	addiw	s4,s4,-9
    80001010:	036a0063          	beq	s4,s6,80001030 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001014:	0149d933          	srl	s2,s3,s4
    80001018:	1ff97913          	andi	s2,s2,511
    8000101c:	090e                	slli	s2,s2,0x3
    8000101e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001020:	00093483          	ld	s1,0(s2)
    80001024:	0014f793          	andi	a5,s1,1
    80001028:	dfd5                	beqz	a5,80000fe4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102a:	80a9                	srli	s1,s1,0xa
    8000102c:	04b2                	slli	s1,s1,0xc
    8000102e:	b7c5                	j	8000100e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001030:	00c9d513          	srli	a0,s3,0xc
    80001034:	1ff57513          	andi	a0,a0,511
    80001038:	050e                	slli	a0,a0,0x3
    8000103a:	9526                	add	a0,a0,s1
}
    8000103c:	70e2                	ld	ra,56(sp)
    8000103e:	7442                	ld	s0,48(sp)
    80001040:	74a2                	ld	s1,40(sp)
    80001042:	7902                	ld	s2,32(sp)
    80001044:	69e2                	ld	s3,24(sp)
    80001046:	6a42                	ld	s4,16(sp)
    80001048:	6aa2                	ld	s5,8(sp)
    8000104a:	6b02                	ld	s6,0(sp)
    8000104c:	6121                	addi	sp,sp,64
    8000104e:	8082                	ret
        return 0;
    80001050:	4501                	li	a0,0
    80001052:	b7ed                	j	8000103c <walk+0x8e>

0000000080001054 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001054:	57fd                	li	a5,-1
    80001056:	83e9                	srli	a5,a5,0x1a
    80001058:	00b7f463          	bgeu	a5,a1,80001060 <walkaddr+0xc>
    return 0;
    8000105c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000105e:	8082                	ret
{
    80001060:	1141                	addi	sp,sp,-16
    80001062:	e406                	sd	ra,8(sp)
    80001064:	e022                	sd	s0,0(sp)
    80001066:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001068:	4601                	li	a2,0
    8000106a:	00000097          	auipc	ra,0x0
    8000106e:	f44080e7          	jalr	-188(ra) # 80000fae <walk>
  if(pte == 0)
    80001072:	c105                	beqz	a0,80001092 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001074:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001076:	0117f693          	andi	a3,a5,17
    8000107a:	4745                	li	a4,17
    return 0;
    8000107c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000107e:	00e68663          	beq	a3,a4,8000108a <walkaddr+0x36>
}
    80001082:	60a2                	ld	ra,8(sp)
    80001084:	6402                	ld	s0,0(sp)
    80001086:	0141                	addi	sp,sp,16
    80001088:	8082                	ret
  pa = PTE2PA(*pte);
    8000108a:	00a7d513          	srli	a0,a5,0xa
    8000108e:	0532                	slli	a0,a0,0xc
  return pa;
    80001090:	bfcd                	j	80001082 <walkaddr+0x2e>
    return 0;
    80001092:	4501                	li	a0,0
    80001094:	b7fd                	j	80001082 <walkaddr+0x2e>

0000000080001096 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001096:	715d                	addi	sp,sp,-80
    80001098:	e486                	sd	ra,72(sp)
    8000109a:	e0a2                	sd	s0,64(sp)
    8000109c:	fc26                	sd	s1,56(sp)
    8000109e:	f84a                	sd	s2,48(sp)
    800010a0:	f44e                	sd	s3,40(sp)
    800010a2:	f052                	sd	s4,32(sp)
    800010a4:	ec56                	sd	s5,24(sp)
    800010a6:	e85a                	sd	s6,16(sp)
    800010a8:	e45e                	sd	s7,8(sp)
    800010aa:	0880                	addi	s0,sp,80
    800010ac:	8aaa                	mv	s5,a0
    800010ae:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010b0:	777d                	lui	a4,0xfffff
    800010b2:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010b6:	167d                	addi	a2,a2,-1
    800010b8:	00b609b3          	add	s3,a2,a1
    800010bc:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c0:	893e                	mv	s2,a5
    800010c2:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010c6:	6b85                	lui	s7,0x1
    800010c8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010cc:	4605                	li	a2,1
    800010ce:	85ca                	mv	a1,s2
    800010d0:	8556                	mv	a0,s5
    800010d2:	00000097          	auipc	ra,0x0
    800010d6:	edc080e7          	jalr	-292(ra) # 80000fae <walk>
    800010da:	c51d                	beqz	a0,80001108 <mappages+0x72>
    if(*pte & PTE_V)
    800010dc:	611c                	ld	a5,0(a0)
    800010de:	8b85                	andi	a5,a5,1
    800010e0:	ef81                	bnez	a5,800010f8 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e2:	80b1                	srli	s1,s1,0xc
    800010e4:	04aa                	slli	s1,s1,0xa
    800010e6:	0164e4b3          	or	s1,s1,s6
    800010ea:	0014e493          	ori	s1,s1,1
    800010ee:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f0:	03390863          	beq	s2,s3,80001120 <mappages+0x8a>
    a += PGSIZE;
    800010f4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f6:	bfc9                	j	800010c8 <mappages+0x32>
      panic("remap");
    800010f8:	00008517          	auipc	a0,0x8
    800010fc:	fe050513          	addi	a0,a0,-32 # 800090d8 <digits+0x98>
    80001100:	fffff097          	auipc	ra,0xfffff
    80001104:	42a080e7          	jalr	1066(ra) # 8000052a <panic>
      return -1;
    80001108:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000110a:	60a6                	ld	ra,72(sp)
    8000110c:	6406                	ld	s0,64(sp)
    8000110e:	74e2                	ld	s1,56(sp)
    80001110:	7942                	ld	s2,48(sp)
    80001112:	79a2                	ld	s3,40(sp)
    80001114:	7a02                	ld	s4,32(sp)
    80001116:	6ae2                	ld	s5,24(sp)
    80001118:	6b42                	ld	s6,16(sp)
    8000111a:	6ba2                	ld	s7,8(sp)
    8000111c:	6161                	addi	sp,sp,80
    8000111e:	8082                	ret
  return 0;
    80001120:	4501                	li	a0,0
    80001122:	b7e5                	j	8000110a <mappages+0x74>

0000000080001124 <kvmmap>:
{
    80001124:	1141                	addi	sp,sp,-16
    80001126:	e406                	sd	ra,8(sp)
    80001128:	e022                	sd	s0,0(sp)
    8000112a:	0800                	addi	s0,sp,16
    8000112c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000112e:	86b2                	mv	a3,a2
    80001130:	863e                	mv	a2,a5
    80001132:	00000097          	auipc	ra,0x0
    80001136:	f64080e7          	jalr	-156(ra) # 80001096 <mappages>
    8000113a:	e509                	bnez	a0,80001144 <kvmmap+0x20>
}
    8000113c:	60a2                	ld	ra,8(sp)
    8000113e:	6402                	ld	s0,0(sp)
    80001140:	0141                	addi	sp,sp,16
    80001142:	8082                	ret
    panic("kvmmap");
    80001144:	00008517          	auipc	a0,0x8
    80001148:	f9c50513          	addi	a0,a0,-100 # 800090e0 <digits+0xa0>
    8000114c:	fffff097          	auipc	ra,0xfffff
    80001150:	3de080e7          	jalr	990(ra) # 8000052a <panic>

0000000080001154 <kvmmake>:
{
    80001154:	1101                	addi	sp,sp,-32
    80001156:	ec06                	sd	ra,24(sp)
    80001158:	e822                	sd	s0,16(sp)
    8000115a:	e426                	sd	s1,8(sp)
    8000115c:	e04a                	sd	s2,0(sp)
    8000115e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001160:	00000097          	auipc	ra,0x0
    80001164:	972080e7          	jalr	-1678(ra) # 80000ad2 <kalloc>
    80001168:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000116a:	6605                	lui	a2,0x1
    8000116c:	4581                	li	a1,0
    8000116e:	00000097          	auipc	ra,0x0
    80001172:	b50080e7          	jalr	-1200(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001176:	4719                	li	a4,6
    80001178:	6685                	lui	a3,0x1
    8000117a:	10000637          	lui	a2,0x10000
    8000117e:	100005b7          	lui	a1,0x10000
    80001182:	8526                	mv	a0,s1
    80001184:	00000097          	auipc	ra,0x0
    80001188:	fa0080e7          	jalr	-96(ra) # 80001124 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000118c:	4719                	li	a4,6
    8000118e:	6685                	lui	a3,0x1
    80001190:	10001637          	lui	a2,0x10001
    80001194:	100015b7          	lui	a1,0x10001
    80001198:	8526                	mv	a0,s1
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	f8a080e7          	jalr	-118(ra) # 80001124 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011a2:	4719                	li	a4,6
    800011a4:	004006b7          	lui	a3,0x400
    800011a8:	0c000637          	lui	a2,0xc000
    800011ac:	0c0005b7          	lui	a1,0xc000
    800011b0:	8526                	mv	a0,s1
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	f72080e7          	jalr	-142(ra) # 80001124 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ba:	00008917          	auipc	s2,0x8
    800011be:	e4690913          	addi	s2,s2,-442 # 80009000 <etext>
    800011c2:	4729                	li	a4,10
    800011c4:	80008697          	auipc	a3,0x80008
    800011c8:	e3c68693          	addi	a3,a3,-452 # 9000 <_entry-0x7fff7000>
    800011cc:	4605                	li	a2,1
    800011ce:	067e                	slli	a2,a2,0x1f
    800011d0:	85b2                	mv	a1,a2
    800011d2:	8526                	mv	a0,s1
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	f50080e7          	jalr	-176(ra) # 80001124 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011dc:	4719                	li	a4,6
    800011de:	46c5                	li	a3,17
    800011e0:	06ee                	slli	a3,a3,0x1b
    800011e2:	412686b3          	sub	a3,a3,s2
    800011e6:	864a                	mv	a2,s2
    800011e8:	85ca                	mv	a1,s2
    800011ea:	8526                	mv	a0,s1
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	f38080e7          	jalr	-200(ra) # 80001124 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011f4:	4729                	li	a4,10
    800011f6:	6685                	lui	a3,0x1
    800011f8:	00007617          	auipc	a2,0x7
    800011fc:	e0860613          	addi	a2,a2,-504 # 80008000 <_trampoline>
    80001200:	040005b7          	lui	a1,0x4000
    80001204:	15fd                	addi	a1,a1,-1
    80001206:	05b2                	slli	a1,a1,0xc
    80001208:	8526                	mv	a0,s1
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f1a080e7          	jalr	-230(ra) # 80001124 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001212:	8526                	mv	a0,s1
    80001214:	00000097          	auipc	ra,0x0
    80001218:	7bc080e7          	jalr	1980(ra) # 800019d0 <proc_mapstacks>
}
    8000121c:	8526                	mv	a0,s1
    8000121e:	60e2                	ld	ra,24(sp)
    80001220:	6442                	ld	s0,16(sp)
    80001222:	64a2                	ld	s1,8(sp)
    80001224:	6902                	ld	s2,0(sp)
    80001226:	6105                	addi	sp,sp,32
    80001228:	8082                	ret

000000008000122a <kvminit>:
{
    8000122a:	1141                	addi	sp,sp,-16
    8000122c:	e406                	sd	ra,8(sp)
    8000122e:	e022                	sd	s0,0(sp)
    80001230:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001232:	00000097          	auipc	ra,0x0
    80001236:	f22080e7          	jalr	-222(ra) # 80001154 <kvmmake>
    8000123a:	00009797          	auipc	a5,0x9
    8000123e:	dea7b323          	sd	a0,-538(a5) # 8000a020 <kernel_pagetable>
}
    80001242:	60a2                	ld	ra,8(sp)
    80001244:	6402                	ld	s0,0(sp)
    80001246:	0141                	addi	sp,sp,16
    80001248:	8082                	ret

000000008000124a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000124a:	715d                	addi	sp,sp,-80
    8000124c:	e486                	sd	ra,72(sp)
    8000124e:	e0a2                	sd	s0,64(sp)
    80001250:	fc26                	sd	s1,56(sp)
    80001252:	f84a                	sd	s2,48(sp)
    80001254:	f44e                	sd	s3,40(sp)
    80001256:	f052                	sd	s4,32(sp)
    80001258:	ec56                	sd	s5,24(sp)
    8000125a:	e85a                	sd	s6,16(sp)
    8000125c:	e45e                	sd	s7,8(sp)
    8000125e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001260:	03459793          	slli	a5,a1,0x34
    80001264:	e795                	bnez	a5,80001290 <uvmunmap+0x46>
    80001266:	8a2a                	mv	s4,a0
    80001268:	892e                	mv	s2,a1
    8000126a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	0632                	slli	a2,a2,0xc
    8000126e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001272:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001274:	6b05                	lui	s6,0x1
    80001276:	0735e263          	bltu	a1,s3,800012da <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000127a:	60a6                	ld	ra,72(sp)
    8000127c:	6406                	ld	s0,64(sp)
    8000127e:	74e2                	ld	s1,56(sp)
    80001280:	7942                	ld	s2,48(sp)
    80001282:	79a2                	ld	s3,40(sp)
    80001284:	7a02                	ld	s4,32(sp)
    80001286:	6ae2                	ld	s5,24(sp)
    80001288:	6b42                	ld	s6,16(sp)
    8000128a:	6ba2                	ld	s7,8(sp)
    8000128c:	6161                	addi	sp,sp,80
    8000128e:	8082                	ret
    panic("uvmunmap: not aligned");
    80001290:	00008517          	auipc	a0,0x8
    80001294:	e5850513          	addi	a0,a0,-424 # 800090e8 <digits+0xa8>
    80001298:	fffff097          	auipc	ra,0xfffff
    8000129c:	292080e7          	jalr	658(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800012a0:	00008517          	auipc	a0,0x8
    800012a4:	e6050513          	addi	a0,a0,-416 # 80009100 <digits+0xc0>
    800012a8:	fffff097          	auipc	ra,0xfffff
    800012ac:	282080e7          	jalr	642(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012b0:	00008517          	auipc	a0,0x8
    800012b4:	e6050513          	addi	a0,a0,-416 # 80009110 <digits+0xd0>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	272080e7          	jalr	626(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012c0:	00008517          	auipc	a0,0x8
    800012c4:	e6850513          	addi	a0,a0,-408 # 80009128 <digits+0xe8>
    800012c8:	fffff097          	auipc	ra,0xfffff
    800012cc:	262080e7          	jalr	610(ra) # 8000052a <panic>
    *pte = 0;
    800012d0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012d4:	995a                	add	s2,s2,s6
    800012d6:	fb3972e3          	bgeu	s2,s3,8000127a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012da:	4601                	li	a2,0
    800012dc:	85ca                	mv	a1,s2
    800012de:	8552                	mv	a0,s4
    800012e0:	00000097          	auipc	ra,0x0
    800012e4:	cce080e7          	jalr	-818(ra) # 80000fae <walk>
    800012e8:	84aa                	mv	s1,a0
    800012ea:	d95d                	beqz	a0,800012a0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012ec:	6108                	ld	a0,0(a0)
    800012ee:	00157793          	andi	a5,a0,1
    800012f2:	dfdd                	beqz	a5,800012b0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012f4:	3ff57793          	andi	a5,a0,1023
    800012f8:	fd7784e3          	beq	a5,s7,800012c0 <uvmunmap+0x76>
    if(do_free){
    800012fc:	fc0a8ae3          	beqz	s5,800012d0 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001300:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001302:	0532                	slli	a0,a0,0xc
    80001304:	fffff097          	auipc	ra,0xfffff
    80001308:	6d2080e7          	jalr	1746(ra) # 800009d6 <kfree>
    8000130c:	b7d1                	j	800012d0 <uvmunmap+0x86>

000000008000130e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000130e:	1101                	addi	sp,sp,-32
    80001310:	ec06                	sd	ra,24(sp)
    80001312:	e822                	sd	s0,16(sp)
    80001314:	e426                	sd	s1,8(sp)
    80001316:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	7ba080e7          	jalr	1978(ra) # 80000ad2 <kalloc>
    80001320:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001322:	c519                	beqz	a0,80001330 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001324:	6605                	lui	a2,0x1
    80001326:	4581                	li	a1,0
    80001328:	00000097          	auipc	ra,0x0
    8000132c:	996080e7          	jalr	-1642(ra) # 80000cbe <memset>
  return pagetable;
}
    80001330:	8526                	mv	a0,s1
    80001332:	60e2                	ld	ra,24(sp)
    80001334:	6442                	ld	s0,16(sp)
    80001336:	64a2                	ld	s1,8(sp)
    80001338:	6105                	addi	sp,sp,32
    8000133a:	8082                	ret

000000008000133c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000133c:	7179                	addi	sp,sp,-48
    8000133e:	f406                	sd	ra,40(sp)
    80001340:	f022                	sd	s0,32(sp)
    80001342:	ec26                	sd	s1,24(sp)
    80001344:	e84a                	sd	s2,16(sp)
    80001346:	e44e                	sd	s3,8(sp)
    80001348:	e052                	sd	s4,0(sp)
    8000134a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000134c:	6785                	lui	a5,0x1
    8000134e:	04f67863          	bgeu	a2,a5,8000139e <uvminit+0x62>
    80001352:	8a2a                	mv	s4,a0
    80001354:	89ae                	mv	s3,a1
    80001356:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001358:	fffff097          	auipc	ra,0xfffff
    8000135c:	77a080e7          	jalr	1914(ra) # 80000ad2 <kalloc>
    80001360:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001362:	6605                	lui	a2,0x1
    80001364:	4581                	li	a1,0
    80001366:	00000097          	auipc	ra,0x0
    8000136a:	958080e7          	jalr	-1704(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000136e:	4779                	li	a4,30
    80001370:	86ca                	mv	a3,s2
    80001372:	6605                	lui	a2,0x1
    80001374:	4581                	li	a1,0
    80001376:	8552                	mv	a0,s4
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	d1e080e7          	jalr	-738(ra) # 80001096 <mappages>
  memmove(mem, src, sz);
    80001380:	8626                	mv	a2,s1
    80001382:	85ce                	mv	a1,s3
    80001384:	854a                	mv	a0,s2
    80001386:	00000097          	auipc	ra,0x0
    8000138a:	994080e7          	jalr	-1644(ra) # 80000d1a <memmove>
}
    8000138e:	70a2                	ld	ra,40(sp)
    80001390:	7402                	ld	s0,32(sp)
    80001392:	64e2                	ld	s1,24(sp)
    80001394:	6942                	ld	s2,16(sp)
    80001396:	69a2                	ld	s3,8(sp)
    80001398:	6a02                	ld	s4,0(sp)
    8000139a:	6145                	addi	sp,sp,48
    8000139c:	8082                	ret
    panic("inituvm: more than a page");
    8000139e:	00008517          	auipc	a0,0x8
    800013a2:	da250513          	addi	a0,a0,-606 # 80009140 <digits+0x100>
    800013a6:	fffff097          	auipc	ra,0xfffff
    800013aa:	184080e7          	jalr	388(ra) # 8000052a <panic>

00000000800013ae <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013ae:	1101                	addi	sp,sp,-32
    800013b0:	ec06                	sd	ra,24(sp)
    800013b2:	e822                	sd	s0,16(sp)
    800013b4:	e426                	sd	s1,8(sp)
    800013b6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013b8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ba:	00b67d63          	bgeu	a2,a1,800013d4 <uvmdealloc+0x26>
    800013be:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013c0:	6785                	lui	a5,0x1
    800013c2:	17fd                	addi	a5,a5,-1
    800013c4:	00f60733          	add	a4,a2,a5
    800013c8:	767d                	lui	a2,0xfffff
    800013ca:	8f71                	and	a4,a4,a2
    800013cc:	97ae                	add	a5,a5,a1
    800013ce:	8ff1                	and	a5,a5,a2
    800013d0:	00f76863          	bltu	a4,a5,800013e0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013d4:	8526                	mv	a0,s1
    800013d6:	60e2                	ld	ra,24(sp)
    800013d8:	6442                	ld	s0,16(sp)
    800013da:	64a2                	ld	s1,8(sp)
    800013dc:	6105                	addi	sp,sp,32
    800013de:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013e0:	8f99                	sub	a5,a5,a4
    800013e2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013e4:	4685                	li	a3,1
    800013e6:	0007861b          	sext.w	a2,a5
    800013ea:	85ba                	mv	a1,a4
    800013ec:	00000097          	auipc	ra,0x0
    800013f0:	e5e080e7          	jalr	-418(ra) # 8000124a <uvmunmap>
    800013f4:	b7c5                	j	800013d4 <uvmdealloc+0x26>

00000000800013f6 <uvmalloc>:
  if(newsz < oldsz)
    800013f6:	0ab66163          	bltu	a2,a1,80001498 <uvmalloc+0xa2>
{
    800013fa:	7139                	addi	sp,sp,-64
    800013fc:	fc06                	sd	ra,56(sp)
    800013fe:	f822                	sd	s0,48(sp)
    80001400:	f426                	sd	s1,40(sp)
    80001402:	f04a                	sd	s2,32(sp)
    80001404:	ec4e                	sd	s3,24(sp)
    80001406:	e852                	sd	s4,16(sp)
    80001408:	e456                	sd	s5,8(sp)
    8000140a:	0080                	addi	s0,sp,64
    8000140c:	8aaa                	mv	s5,a0
    8000140e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001410:	6985                	lui	s3,0x1
    80001412:	19fd                	addi	s3,s3,-1
    80001414:	95ce                	add	a1,a1,s3
    80001416:	79fd                	lui	s3,0xfffff
    80001418:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000141c:	08c9f063          	bgeu	s3,a2,8000149c <uvmalloc+0xa6>
    80001420:	894e                	mv	s2,s3
    mem = kalloc();
    80001422:	fffff097          	auipc	ra,0xfffff
    80001426:	6b0080e7          	jalr	1712(ra) # 80000ad2 <kalloc>
    8000142a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000142c:	c51d                	beqz	a0,8000145a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000142e:	6605                	lui	a2,0x1
    80001430:	4581                	li	a1,0
    80001432:	00000097          	auipc	ra,0x0
    80001436:	88c080e7          	jalr	-1908(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000143a:	4779                	li	a4,30
    8000143c:	86a6                	mv	a3,s1
    8000143e:	6605                	lui	a2,0x1
    80001440:	85ca                	mv	a1,s2
    80001442:	8556                	mv	a0,s5
    80001444:	00000097          	auipc	ra,0x0
    80001448:	c52080e7          	jalr	-942(ra) # 80001096 <mappages>
    8000144c:	e905                	bnez	a0,8000147c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000144e:	6785                	lui	a5,0x1
    80001450:	993e                	add	s2,s2,a5
    80001452:	fd4968e3          	bltu	s2,s4,80001422 <uvmalloc+0x2c>
  return newsz;
    80001456:	8552                	mv	a0,s4
    80001458:	a809                	j	8000146a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000145a:	864e                	mv	a2,s3
    8000145c:	85ca                	mv	a1,s2
    8000145e:	8556                	mv	a0,s5
    80001460:	00000097          	auipc	ra,0x0
    80001464:	f4e080e7          	jalr	-178(ra) # 800013ae <uvmdealloc>
      return 0;
    80001468:	4501                	li	a0,0
}
    8000146a:	70e2                	ld	ra,56(sp)
    8000146c:	7442                	ld	s0,48(sp)
    8000146e:	74a2                	ld	s1,40(sp)
    80001470:	7902                	ld	s2,32(sp)
    80001472:	69e2                	ld	s3,24(sp)
    80001474:	6a42                	ld	s4,16(sp)
    80001476:	6aa2                	ld	s5,8(sp)
    80001478:	6121                	addi	sp,sp,64
    8000147a:	8082                	ret
      kfree(mem);
    8000147c:	8526                	mv	a0,s1
    8000147e:	fffff097          	auipc	ra,0xfffff
    80001482:	558080e7          	jalr	1368(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001486:	864e                	mv	a2,s3
    80001488:	85ca                	mv	a1,s2
    8000148a:	8556                	mv	a0,s5
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f22080e7          	jalr	-222(ra) # 800013ae <uvmdealloc>
      return 0;
    80001494:	4501                	li	a0,0
    80001496:	bfd1                	j	8000146a <uvmalloc+0x74>
    return oldsz;
    80001498:	852e                	mv	a0,a1
}
    8000149a:	8082                	ret
  return newsz;
    8000149c:	8532                	mv	a0,a2
    8000149e:	b7f1                	j	8000146a <uvmalloc+0x74>

00000000800014a0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014a0:	7179                	addi	sp,sp,-48
    800014a2:	f406                	sd	ra,40(sp)
    800014a4:	f022                	sd	s0,32(sp)
    800014a6:	ec26                	sd	s1,24(sp)
    800014a8:	e84a                	sd	s2,16(sp)
    800014aa:	e44e                	sd	s3,8(sp)
    800014ac:	e052                	sd	s4,0(sp)
    800014ae:	1800                	addi	s0,sp,48
    800014b0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014b2:	84aa                	mv	s1,a0
    800014b4:	6905                	lui	s2,0x1
    800014b6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014b8:	4985                	li	s3,1
    800014ba:	a821                	j	800014d2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014bc:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014be:	0532                	slli	a0,a0,0xc
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	fe0080e7          	jalr	-32(ra) # 800014a0 <freewalk>
      pagetable[i] = 0;
    800014c8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014cc:	04a1                	addi	s1,s1,8
    800014ce:	03248163          	beq	s1,s2,800014f0 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014d2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	00f57793          	andi	a5,a0,15
    800014d8:	ff3782e3          	beq	a5,s3,800014bc <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014dc:	8905                	andi	a0,a0,1
    800014de:	d57d                	beqz	a0,800014cc <freewalk+0x2c>
      panic("freewalk: leaf");
    800014e0:	00008517          	auipc	a0,0x8
    800014e4:	c8050513          	addi	a0,a0,-896 # 80009160 <digits+0x120>
    800014e8:	fffff097          	auipc	ra,0xfffff
    800014ec:	042080e7          	jalr	66(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800014f0:	8552                	mv	a0,s4
    800014f2:	fffff097          	auipc	ra,0xfffff
    800014f6:	4e4080e7          	jalr	1252(ra) # 800009d6 <kfree>
}
    800014fa:	70a2                	ld	ra,40(sp)
    800014fc:	7402                	ld	s0,32(sp)
    800014fe:	64e2                	ld	s1,24(sp)
    80001500:	6942                	ld	s2,16(sp)
    80001502:	69a2                	ld	s3,8(sp)
    80001504:	6a02                	ld	s4,0(sp)
    80001506:	6145                	addi	sp,sp,48
    80001508:	8082                	ret

000000008000150a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000150a:	1101                	addi	sp,sp,-32
    8000150c:	ec06                	sd	ra,24(sp)
    8000150e:	e822                	sd	s0,16(sp)
    80001510:	e426                	sd	s1,8(sp)
    80001512:	1000                	addi	s0,sp,32
    80001514:	84aa                	mv	s1,a0
  if(sz > 0)
    80001516:	e999                	bnez	a1,8000152c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001518:	8526                	mv	a0,s1
    8000151a:	00000097          	auipc	ra,0x0
    8000151e:	f86080e7          	jalr	-122(ra) # 800014a0 <freewalk>
}
    80001522:	60e2                	ld	ra,24(sp)
    80001524:	6442                	ld	s0,16(sp)
    80001526:	64a2                	ld	s1,8(sp)
    80001528:	6105                	addi	sp,sp,32
    8000152a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000152c:	6605                	lui	a2,0x1
    8000152e:	167d                	addi	a2,a2,-1
    80001530:	962e                	add	a2,a2,a1
    80001532:	4685                	li	a3,1
    80001534:	8231                	srli	a2,a2,0xc
    80001536:	4581                	li	a1,0
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	d12080e7          	jalr	-750(ra) # 8000124a <uvmunmap>
    80001540:	bfe1                	j	80001518 <uvmfree+0xe>

0000000080001542 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001542:	c679                	beqz	a2,80001610 <uvmcopy+0xce>
{
    80001544:	715d                	addi	sp,sp,-80
    80001546:	e486                	sd	ra,72(sp)
    80001548:	e0a2                	sd	s0,64(sp)
    8000154a:	fc26                	sd	s1,56(sp)
    8000154c:	f84a                	sd	s2,48(sp)
    8000154e:	f44e                	sd	s3,40(sp)
    80001550:	f052                	sd	s4,32(sp)
    80001552:	ec56                	sd	s5,24(sp)
    80001554:	e85a                	sd	s6,16(sp)
    80001556:	e45e                	sd	s7,8(sp)
    80001558:	0880                	addi	s0,sp,80
    8000155a:	8b2a                	mv	s6,a0
    8000155c:	8aae                	mv	s5,a1
    8000155e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001560:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001562:	4601                	li	a2,0
    80001564:	85ce                	mv	a1,s3
    80001566:	855a                	mv	a0,s6
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	a46080e7          	jalr	-1466(ra) # 80000fae <walk>
    80001570:	c531                	beqz	a0,800015bc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001572:	6118                	ld	a4,0(a0)
    80001574:	00177793          	andi	a5,a4,1
    80001578:	cbb1                	beqz	a5,800015cc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000157a:	00a75593          	srli	a1,a4,0xa
    8000157e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001582:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001586:	fffff097          	auipc	ra,0xfffff
    8000158a:	54c080e7          	jalr	1356(ra) # 80000ad2 <kalloc>
    8000158e:	892a                	mv	s2,a0
    80001590:	c939                	beqz	a0,800015e6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001592:	6605                	lui	a2,0x1
    80001594:	85de                	mv	a1,s7
    80001596:	fffff097          	auipc	ra,0xfffff
    8000159a:	784080e7          	jalr	1924(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000159e:	8726                	mv	a4,s1
    800015a0:	86ca                	mv	a3,s2
    800015a2:	6605                	lui	a2,0x1
    800015a4:	85ce                	mv	a1,s3
    800015a6:	8556                	mv	a0,s5
    800015a8:	00000097          	auipc	ra,0x0
    800015ac:	aee080e7          	jalr	-1298(ra) # 80001096 <mappages>
    800015b0:	e515                	bnez	a0,800015dc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015b2:	6785                	lui	a5,0x1
    800015b4:	99be                	add	s3,s3,a5
    800015b6:	fb49e6e3          	bltu	s3,s4,80001562 <uvmcopy+0x20>
    800015ba:	a081                	j	800015fa <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015bc:	00008517          	auipc	a0,0x8
    800015c0:	bb450513          	addi	a0,a0,-1100 # 80009170 <digits+0x130>
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	f66080e7          	jalr	-154(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015cc:	00008517          	auipc	a0,0x8
    800015d0:	bc450513          	addi	a0,a0,-1084 # 80009190 <digits+0x150>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	f56080e7          	jalr	-170(ra) # 8000052a <panic>
      kfree(mem);
    800015dc:	854a                	mv	a0,s2
    800015de:	fffff097          	auipc	ra,0xfffff
    800015e2:	3f8080e7          	jalr	1016(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015e6:	4685                	li	a3,1
    800015e8:	00c9d613          	srli	a2,s3,0xc
    800015ec:	4581                	li	a1,0
    800015ee:	8556                	mv	a0,s5
    800015f0:	00000097          	auipc	ra,0x0
    800015f4:	c5a080e7          	jalr	-934(ra) # 8000124a <uvmunmap>
  return -1;
    800015f8:	557d                	li	a0,-1
}
    800015fa:	60a6                	ld	ra,72(sp)
    800015fc:	6406                	ld	s0,64(sp)
    800015fe:	74e2                	ld	s1,56(sp)
    80001600:	7942                	ld	s2,48(sp)
    80001602:	79a2                	ld	s3,40(sp)
    80001604:	7a02                	ld	s4,32(sp)
    80001606:	6ae2                	ld	s5,24(sp)
    80001608:	6b42                	ld	s6,16(sp)
    8000160a:	6ba2                	ld	s7,8(sp)
    8000160c:	6161                	addi	sp,sp,80
    8000160e:	8082                	ret
  return 0;
    80001610:	4501                	li	a0,0
}
    80001612:	8082                	ret

0000000080001614 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001614:	1141                	addi	sp,sp,-16
    80001616:	e406                	sd	ra,8(sp)
    80001618:	e022                	sd	s0,0(sp)
    8000161a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000161c:	4601                	li	a2,0
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	990080e7          	jalr	-1648(ra) # 80000fae <walk>
  if(pte == 0)
    80001626:	c901                	beqz	a0,80001636 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001628:	611c                	ld	a5,0(a0)
    8000162a:	9bbd                	andi	a5,a5,-17
    8000162c:	e11c                	sd	a5,0(a0)
}
    8000162e:	60a2                	ld	ra,8(sp)
    80001630:	6402                	ld	s0,0(sp)
    80001632:	0141                	addi	sp,sp,16
    80001634:	8082                	ret
    panic("uvmclear");
    80001636:	00008517          	auipc	a0,0x8
    8000163a:	b7a50513          	addi	a0,a0,-1158 # 800091b0 <digits+0x170>
    8000163e:	fffff097          	auipc	ra,0xfffff
    80001642:	eec080e7          	jalr	-276(ra) # 8000052a <panic>

0000000080001646 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001646:	c6bd                	beqz	a3,800016b4 <copyout+0x6e>
{
    80001648:	715d                	addi	sp,sp,-80
    8000164a:	e486                	sd	ra,72(sp)
    8000164c:	e0a2                	sd	s0,64(sp)
    8000164e:	fc26                	sd	s1,56(sp)
    80001650:	f84a                	sd	s2,48(sp)
    80001652:	f44e                	sd	s3,40(sp)
    80001654:	f052                	sd	s4,32(sp)
    80001656:	ec56                	sd	s5,24(sp)
    80001658:	e85a                	sd	s6,16(sp)
    8000165a:	e45e                	sd	s7,8(sp)
    8000165c:	e062                	sd	s8,0(sp)
    8000165e:	0880                	addi	s0,sp,80
    80001660:	8b2a                	mv	s6,a0
    80001662:	8c2e                	mv	s8,a1
    80001664:	8a32                	mv	s4,a2
    80001666:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001668:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000166a:	6a85                	lui	s5,0x1
    8000166c:	a015                	j	80001690 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000166e:	9562                	add	a0,a0,s8
    80001670:	0004861b          	sext.w	a2,s1
    80001674:	85d2                	mv	a1,s4
    80001676:	41250533          	sub	a0,a0,s2
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	6a0080e7          	jalr	1696(ra) # 80000d1a <memmove>

    len -= n;
    80001682:	409989b3          	sub	s3,s3,s1
    src += n;
    80001686:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001688:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000168c:	02098263          	beqz	s3,800016b0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001690:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001694:	85ca                	mv	a1,s2
    80001696:	855a                	mv	a0,s6
    80001698:	00000097          	auipc	ra,0x0
    8000169c:	9bc080e7          	jalr	-1604(ra) # 80001054 <walkaddr>
    if(pa0 == 0)
    800016a0:	cd01                	beqz	a0,800016b8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016a2:	418904b3          	sub	s1,s2,s8
    800016a6:	94d6                	add	s1,s1,s5
    if(n > len)
    800016a8:	fc99f3e3          	bgeu	s3,s1,8000166e <copyout+0x28>
    800016ac:	84ce                	mv	s1,s3
    800016ae:	b7c1                	j	8000166e <copyout+0x28>
  }
  return 0;
    800016b0:	4501                	li	a0,0
    800016b2:	a021                	j	800016ba <copyout+0x74>
    800016b4:	4501                	li	a0,0
}
    800016b6:	8082                	ret
      return -1;
    800016b8:	557d                	li	a0,-1
}
    800016ba:	60a6                	ld	ra,72(sp)
    800016bc:	6406                	ld	s0,64(sp)
    800016be:	74e2                	ld	s1,56(sp)
    800016c0:	7942                	ld	s2,48(sp)
    800016c2:	79a2                	ld	s3,40(sp)
    800016c4:	7a02                	ld	s4,32(sp)
    800016c6:	6ae2                	ld	s5,24(sp)
    800016c8:	6b42                	ld	s6,16(sp)
    800016ca:	6ba2                	ld	s7,8(sp)
    800016cc:	6c02                	ld	s8,0(sp)
    800016ce:	6161                	addi	sp,sp,80
    800016d0:	8082                	ret

00000000800016d2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016d2:	caa5                	beqz	a3,80001742 <copyin+0x70>
{
    800016d4:	715d                	addi	sp,sp,-80
    800016d6:	e486                	sd	ra,72(sp)
    800016d8:	e0a2                	sd	s0,64(sp)
    800016da:	fc26                	sd	s1,56(sp)
    800016dc:	f84a                	sd	s2,48(sp)
    800016de:	f44e                	sd	s3,40(sp)
    800016e0:	f052                	sd	s4,32(sp)
    800016e2:	ec56                	sd	s5,24(sp)
    800016e4:	e85a                	sd	s6,16(sp)
    800016e6:	e45e                	sd	s7,8(sp)
    800016e8:	e062                	sd	s8,0(sp)
    800016ea:	0880                	addi	s0,sp,80
    800016ec:	8b2a                	mv	s6,a0
    800016ee:	8a2e                	mv	s4,a1
    800016f0:	8c32                	mv	s8,a2
    800016f2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016f4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016f6:	6a85                	lui	s5,0x1
    800016f8:	a01d                	j	8000171e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	018505b3          	add	a1,a0,s8
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	412585b3          	sub	a1,a1,s2
    80001706:	8552                	mv	a0,s4
    80001708:	fffff097          	auipc	ra,0xfffff
    8000170c:	612080e7          	jalr	1554(ra) # 80000d1a <memmove>

    len -= n;
    80001710:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001714:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001716:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000171a:	02098263          	beqz	s3,8000173e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000171e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001722:	85ca                	mv	a1,s2
    80001724:	855a                	mv	a0,s6
    80001726:	00000097          	auipc	ra,0x0
    8000172a:	92e080e7          	jalr	-1746(ra) # 80001054 <walkaddr>
    if(pa0 == 0)
    8000172e:	cd01                	beqz	a0,80001746 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001730:	418904b3          	sub	s1,s2,s8
    80001734:	94d6                	add	s1,s1,s5
    if(n > len)
    80001736:	fc99f2e3          	bgeu	s3,s1,800016fa <copyin+0x28>
    8000173a:	84ce                	mv	s1,s3
    8000173c:	bf7d                	j	800016fa <copyin+0x28>
  }
  return 0;
    8000173e:	4501                	li	a0,0
    80001740:	a021                	j	80001748 <copyin+0x76>
    80001742:	4501                	li	a0,0
}
    80001744:	8082                	ret
      return -1;
    80001746:	557d                	li	a0,-1
}
    80001748:	60a6                	ld	ra,72(sp)
    8000174a:	6406                	ld	s0,64(sp)
    8000174c:	74e2                	ld	s1,56(sp)
    8000174e:	7942                	ld	s2,48(sp)
    80001750:	79a2                	ld	s3,40(sp)
    80001752:	7a02                	ld	s4,32(sp)
    80001754:	6ae2                	ld	s5,24(sp)
    80001756:	6b42                	ld	s6,16(sp)
    80001758:	6ba2                	ld	s7,8(sp)
    8000175a:	6c02                	ld	s8,0(sp)
    8000175c:	6161                	addi	sp,sp,80
    8000175e:	8082                	ret

0000000080001760 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001760:	c6c5                	beqz	a3,80001808 <copyinstr+0xa8>
{
    80001762:	715d                	addi	sp,sp,-80
    80001764:	e486                	sd	ra,72(sp)
    80001766:	e0a2                	sd	s0,64(sp)
    80001768:	fc26                	sd	s1,56(sp)
    8000176a:	f84a                	sd	s2,48(sp)
    8000176c:	f44e                	sd	s3,40(sp)
    8000176e:	f052                	sd	s4,32(sp)
    80001770:	ec56                	sd	s5,24(sp)
    80001772:	e85a                	sd	s6,16(sp)
    80001774:	e45e                	sd	s7,8(sp)
    80001776:	0880                	addi	s0,sp,80
    80001778:	8a2a                	mv	s4,a0
    8000177a:	8b2e                	mv	s6,a1
    8000177c:	8bb2                	mv	s7,a2
    8000177e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001780:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001782:	6985                	lui	s3,0x1
    80001784:	a035                	j	800017b0 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001786:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000178a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000178c:	0017b793          	seqz	a5,a5
    80001790:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001794:	60a6                	ld	ra,72(sp)
    80001796:	6406                	ld	s0,64(sp)
    80001798:	74e2                	ld	s1,56(sp)
    8000179a:	7942                	ld	s2,48(sp)
    8000179c:	79a2                	ld	s3,40(sp)
    8000179e:	7a02                	ld	s4,32(sp)
    800017a0:	6ae2                	ld	s5,24(sp)
    800017a2:	6b42                	ld	s6,16(sp)
    800017a4:	6ba2                	ld	s7,8(sp)
    800017a6:	6161                	addi	sp,sp,80
    800017a8:	8082                	ret
    srcva = va0 + PGSIZE;
    800017aa:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ae:	c8a9                	beqz	s1,80001800 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017b0:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017b4:	85ca                	mv	a1,s2
    800017b6:	8552                	mv	a0,s4
    800017b8:	00000097          	auipc	ra,0x0
    800017bc:	89c080e7          	jalr	-1892(ra) # 80001054 <walkaddr>
    if(pa0 == 0)
    800017c0:	c131                	beqz	a0,80001804 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017c2:	41790833          	sub	a6,s2,s7
    800017c6:	984e                	add	a6,a6,s3
    if(n > max)
    800017c8:	0104f363          	bgeu	s1,a6,800017ce <copyinstr+0x6e>
    800017cc:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ce:	955e                	add	a0,a0,s7
    800017d0:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017d4:	fc080be3          	beqz	a6,800017aa <copyinstr+0x4a>
    800017d8:	985a                	add	a6,a6,s6
    800017da:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017dc:	41650633          	sub	a2,a0,s6
    800017e0:	14fd                	addi	s1,s1,-1
    800017e2:	9b26                	add	s6,s6,s1
    800017e4:	00f60733          	add	a4,a2,a5
    800017e8:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffba000>
    800017ec:	df49                	beqz	a4,80001786 <copyinstr+0x26>
        *dst = *p;
    800017ee:	00e78023          	sb	a4,0(a5)
      --max;
    800017f2:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800017f6:	0785                	addi	a5,a5,1
    while(n > 0){
    800017f8:	ff0796e3          	bne	a5,a6,800017e4 <copyinstr+0x84>
      dst++;
    800017fc:	8b42                	mv	s6,a6
    800017fe:	b775                	j	800017aa <copyinstr+0x4a>
    80001800:	4781                	li	a5,0
    80001802:	b769                	j	8000178c <copyinstr+0x2c>
      return -1;
    80001804:	557d                	li	a0,-1
    80001806:	b779                	j	80001794 <copyinstr+0x34>
  int got_null = 0;
    80001808:	4781                	li	a5,0
  if(got_null){
    8000180a:	0017b793          	seqz	a5,a5
    8000180e:	40f00533          	neg	a0,a5
}
    80001812:	8082                	ret

0000000080001814 <freethread>:
// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freethread(struct thread *t)
{
    80001814:	1101                	addi	sp,sp,-32
    80001816:	ec06                	sd	ra,24(sp)
    80001818:	e822                	sd	s0,16(sp)
    8000181a:	e426                	sd	s1,8(sp)
    8000181c:	1000                	addi	s0,sp,32
    8000181e:	84aa                	mv	s1,a0
  if(t->tf_backup)
    80001820:	6928                	ld	a0,80(a0)
    80001822:	c509                	beqz	a0,8000182c <freethread+0x18>
    kfree((void*)t->tf_backup);
    80001824:	fffff097          	auipc	ra,0xfffff
    80001828:	1b2080e7          	jalr	434(ra) # 800009d6 <kfree>
  t->tid = 0;
    8000182c:	0204a823          	sw	zero,48(s1)
  t->parent = 0;
    80001830:	0204bc23          	sd	zero,56(s1)
  t->chan = 0;
    80001834:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001838:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    8000183c:	0204a623          	sw	zero,44(s1)
  t->state = UNUSED;
    80001840:	0004ac23          	sw	zero,24(s1)
}
    80001844:	60e2                	ld	ra,24(sp)
    80001846:	6442                	ld	s0,16(sp)
    80001848:	64a2                	ld	s1,8(sp)
    8000184a:	6105                	addi	sp,sp,32
    8000184c:	8082                	ret

000000008000184e <alloctid>:

int
alloctid() {
    8000184e:	1101                	addi	sp,sp,-32
    80001850:	ec06                	sd	ra,24(sp)
    80001852:	e822                	sd	s0,16(sp)
    80001854:	e426                	sd	s1,8(sp)
    80001856:	e04a                	sd	s2,0(sp)
    80001858:	1000                	addi	s0,sp,32
  int tid;
  
  acquire(&tid_lock);
    8000185a:	00011917          	auipc	s2,0x11
    8000185e:	a4690913          	addi	s2,s2,-1466 # 800122a0 <tid_lock>
    80001862:	854a                	mv	a0,s2
    80001864:	fffff097          	auipc	ra,0xfffff
    80001868:	35e080e7          	jalr	862(ra) # 80000bc2 <acquire>
  tid = nexttid;
    8000186c:	00008797          	auipc	a5,0x8
    80001870:	1a878793          	addi	a5,a5,424 # 80009a14 <nexttid>
    80001874:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001876:	0014871b          	addiw	a4,s1,1
    8000187a:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    8000187c:	854a                	mv	a0,s2
    8000187e:	fffff097          	auipc	ra,0xfffff
    80001882:	3f8080e7          	jalr	1016(ra) # 80000c76 <release>

  return tid;
}
    80001886:	8526                	mv	a0,s1
    80001888:	60e2                	ld	ra,24(sp)
    8000188a:	6442                	ld	s0,16(sp)
    8000188c:	64a2                	ld	s1,8(sp)
    8000188e:	6902                	ld	s2,0(sp)
    80001890:	6105                	addi	sp,sp,32
    80001892:	8082                	ret

0000000080001894 <allocthread>:
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct thread*
allocthread(struct proc* p)
{
    80001894:	7139                	addi	sp,sp,-64
    80001896:	fc06                	sd	ra,56(sp)
    80001898:	f822                	sd	s0,48(sp)
    8000189a:	f426                	sd	s1,40(sp)
    8000189c:	f04a                	sd	s2,32(sp)
    8000189e:	ec4e                	sd	s3,24(sp)
    800018a0:	e852                	sd	s4,16(sp)
    800018a2:	e456                	sd	s5,8(sp)
    800018a4:	0080                	addi	s0,sp,64
    800018a6:	8aaa                	mv	s5,a0
  struct thread *t;
  int index = 0;
  for(t = p->threads; t < &p->threads[NTHREAD]; t++) 
    800018a8:	0e050493          	addi	s1,a0,224
  int index = 0;
    800018ac:	4901                	li	s2,0
    acquire(&t->lock);
    if(t->state == UNUSED) 
    {
      goto found;
    } 
    if(t->state == ZOMBIE)
    800018ae:	4a15                	li	s4,5
  for(t = p->threads; t < &p->threads[NTHREAD]; t++) 
    800018b0:	49a1                	li	s3,8
    800018b2:	a88d                	j	80001924 <allocthread+0x90>
    index++;
  }
  return 0;

found:
  t->tid = alloctid();
    800018b4:	00000097          	auipc	ra,0x0
    800018b8:	f9a080e7          	jalr	-102(ra) # 8000184e <alloctid>
    800018bc:	d888                	sw	a0,48(s1)
  t->state = USED;
    800018be:	4785                	li	a5,1
    800018c0:	cc9c                	sw	a5,24(s1)
  t->parent = p;
    800018c2:	0354bc23          	sd	s5,56(s1)

  t->trapframe = &(p->trapframes[index]);
    800018c6:	6705                	lui	a4,0x1
    800018c8:	9756                	add	a4,a4,s5
    800018ca:	00391793          	slli	a5,s2,0x3
    800018ce:	993e                	add	s2,s2,a5
    800018d0:	0916                	slli	s2,s2,0x5
    800018d2:	8c073783          	ld	a5,-1856(a4) # 8c0 <_entry-0x7ffff740>
    800018d6:	993e                	add	s2,s2,a5
    800018d8:	0524b423          	sd	s2,72(s1)
  if((t->tf_backup = (struct trapframe *)kalloc()) == 0){
    800018dc:	fffff097          	auipc	ra,0xfffff
    800018e0:	1f6080e7          	jalr	502(ra) # 80000ad2 <kalloc>
    800018e4:	892a                	mv	s2,a0
    800018e6:	e8a8                	sd	a0,80(s1)
    800018e8:	c925                	beqz	a0,80001958 <allocthread+0xc4>
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&t->context, 0, sizeof(t->context));
    800018ea:	07000613          	li	a2,112
    800018ee:	4581                	li	a1,0
    800018f0:	05848513          	addi	a0,s1,88
    800018f4:	fffff097          	auipc	ra,0xfffff
    800018f8:	3ca080e7          	jalr	970(ra) # 80000cbe <memset>
  t->context.sp = t->kstack + PGSIZE;
    800018fc:	60bc                	ld	a5,64(s1)
    800018fe:	6705                	lui	a4,0x1
    80001900:	97ba                	add	a5,a5,a4
    80001902:	f0bc                	sd	a5,96(s1)
  t->context.ra = (uint64)forkret;
    80001904:	00000797          	auipc	a5,0x0
    80001908:	32a78793          	addi	a5,a5,810 # 80001c2e <forkret>
    8000190c:	ecbc                	sd	a5,88(s1)

  return t;
    8000190e:	a81d                	j	80001944 <allocthread+0xb0>
      release(&t->lock);
    80001910:	8526                	mv	a0,s1
    80001912:	fffff097          	auipc	ra,0xfffff
    80001916:	364080e7          	jalr	868(ra) # 80000c76 <release>
    index++;
    8000191a:	2905                	addiw	s2,s2,1
  for(t = p->threads; t < &p->threads[NTHREAD]; t++) 
    8000191c:	0c848493          	addi	s1,s1,200
    80001920:	03390163          	beq	s2,s3,80001942 <allocthread+0xae>
    acquire(&t->lock);
    80001924:	8526                	mv	a0,s1
    80001926:	fffff097          	auipc	ra,0xfffff
    8000192a:	29c080e7          	jalr	668(ra) # 80000bc2 <acquire>
    if(t->state == UNUSED) 
    8000192e:	4c9c                	lw	a5,24(s1)
    80001930:	d3d1                	beqz	a5,800018b4 <allocthread+0x20>
    if(t->state == ZOMBIE)
    80001932:	fd479fe3          	bne	a5,s4,80001910 <allocthread+0x7c>
      freethread(t);
    80001936:	8526                	mv	a0,s1
    80001938:	00000097          	auipc	ra,0x0
    8000193c:	edc080e7          	jalr	-292(ra) # 80001814 <freethread>
    80001940:	bfe9                	j	8000191a <allocthread+0x86>
  return 0;
    80001942:	4481                	li	s1,0
}
    80001944:	8526                	mv	a0,s1
    80001946:	70e2                	ld	ra,56(sp)
    80001948:	7442                	ld	s0,48(sp)
    8000194a:	74a2                	ld	s1,40(sp)
    8000194c:	7902                	ld	s2,32(sp)
    8000194e:	69e2                	ld	s3,24(sp)
    80001950:	6a42                	ld	s4,16(sp)
    80001952:	6aa2                	ld	s5,8(sp)
    80001954:	6121                	addi	sp,sp,64
    80001956:	8082                	ret
    freethread(t);
    80001958:	8526                	mv	a0,s1
    8000195a:	00000097          	auipc	ra,0x0
    8000195e:	eba080e7          	jalr	-326(ra) # 80001814 <freethread>
    release(&p->lock);
    80001962:	8556                	mv	a0,s5
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	312080e7          	jalr	786(ra) # 80000c76 <release>
    return 0;
    8000196c:	84ca                	mv	s1,s2
    8000196e:	bfd9                	j	80001944 <allocthread+0xb0>

0000000080001970 <mythread>:
  panic("zombie exit");
}

// Return the current struct proc *, or zero if none.
struct thread*
mythread(void) {
    80001970:	1101                	addi	sp,sp,-32
    80001972:	ec06                	sd	ra,24(sp)
    80001974:	e822                	sd	s0,16(sp)
    80001976:	e426                	sd	s1,8(sp)
    80001978:	1000                	addi	s0,sp,32
  push_off();
    8000197a:	fffff097          	auipc	ra,0xfffff
    8000197e:	1fc080e7          	jalr	508(ra) # 80000b76 <push_off>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001982:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct thread *t = c->thread;
    80001984:	2781                	sext.w	a5,a5
    80001986:	079e                	slli	a5,a5,0x7
    80001988:	00011717          	auipc	a4,0x11
    8000198c:	91870713          	addi	a4,a4,-1768 # 800122a0 <tid_lock>
    80001990:	97ba                	add	a5,a5,a4
    80001992:	6f84                	ld	s1,24(a5)
  pop_off();
    80001994:	fffff097          	auipc	ra,0xfffff
    80001998:	282080e7          	jalr	642(ra) # 80000c16 <pop_off>
  return t;
}
    8000199c:	8526                	mv	a0,s1
    8000199e:	60e2                	ld	ra,24(sp)
    800019a0:	6442                	ld	s0,16(sp)
    800019a2:	64a2                	ld	s1,8(sp)
    800019a4:	6105                	addi	sp,sp,32
    800019a6:	8082                	ret

00000000800019a8 <kthread_create_ret>:
  return 0;
}

void
kthread_create_ret(void)
{
    800019a8:	1141                	addi	sp,sp,-16
    800019aa:	e406                	sd	ra,8(sp)
    800019ac:	e022                	sd	s0,0(sp)
    800019ae:	0800                	addi	s0,sp,16
  release(&mythread()->lock);
    800019b0:	00000097          	auipc	ra,0x0
    800019b4:	fc0080e7          	jalr	-64(ra) # 80001970 <mythread>
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	2be080e7          	jalr	702(ra) # 80000c76 <release>
  usertrapret();
    800019c0:	00002097          	auipc	ra,0x2
    800019c4:	aa6080e7          	jalr	-1370(ra) # 80003466 <usertrapret>
}
    800019c8:	60a2                	ld	ra,8(sp)
    800019ca:	6402                	ld	s0,0(sp)
    800019cc:	0141                	addi	sp,sp,16
    800019ce:	8082                	ret

00000000800019d0 <proc_mapstacks>:
{
    800019d0:	711d                	addi	sp,sp,-96
    800019d2:	ec86                	sd	ra,88(sp)
    800019d4:	e8a2                	sd	s0,80(sp)
    800019d6:	e4a6                	sd	s1,72(sp)
    800019d8:	e0ca                	sd	s2,64(sp)
    800019da:	fc4e                	sd	s3,56(sp)
    800019dc:	f852                	sd	s4,48(sp)
    800019de:	f456                	sd	s5,40(sp)
    800019e0:	f05a                	sd	s6,32(sp)
    800019e2:	ec5e                	sd	s7,24(sp)
    800019e4:	e862                	sd	s8,16(sp)
    800019e6:	e466                	sd	s9,8(sp)
    800019e8:	e06a                	sd	s10,0(sp)
    800019ea:	1080                	addi	s0,sp,96
    800019ec:	8b2a                	mv	s6,a0
  for(p = proc; p < &proc[NPROC]; p++) 
    800019ee:	00012997          	auipc	s3,0x12
    800019f2:	41a98993          	addi	s3,s3,1050 # 80013e08 <proc+0x720>
    800019f6:	00035d17          	auipc	s10,0x35
    800019fa:	612d0d13          	addi	s10,s10,1554 # 80037008 <bcache+0x708>
      uint64 va = KSTACK((((int) (p - proc))*8) + ((int) (t-p->threads)));
    800019fe:	00012c97          	auipc	s9,0x12
    80001a02:	ceac8c93          	addi	s9,s9,-790 # 800136e8 <proc>
    80001a06:	00007c17          	auipc	s8,0x7
    80001a0a:	5fac3c03          	ld	s8,1530(s8) # 80009000 <etext>
    80001a0e:	00007b97          	auipc	s7,0x7
    80001a12:	5fab8b93          	addi	s7,s7,1530 # 80009008 <etext+0x8>
    80001a16:	04000ab7          	lui	s5,0x4000
    80001a1a:	1afd                	addi	s5,s5,-1
    80001a1c:	0ab2                	slli	s5,s5,0xc
    80001a1e:	a839                	j	80001a3c <proc_mapstacks+0x6c>
        panic("kalloc");
    80001a20:	00007517          	auipc	a0,0x7
    80001a24:	7a050513          	addi	a0,a0,1952 # 800091c0 <digits+0x180>
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	b02080e7          	jalr	-1278(ra) # 8000052a <panic>
  for(p = proc; p < &proc[NPROC]; p++) 
    80001a30:	6785                	lui	a5,0x1
    80001a32:	8c878793          	addi	a5,a5,-1848 # 8c8 <_entry-0x7ffff738>
    80001a36:	99be                	add	s3,s3,a5
    80001a38:	05a98f63          	beq	s3,s10,80001a96 <proc_mapstacks+0xc6>
    for (t =p->threads; t<&p->threads[NTHREAD] ; t++)
    80001a3c:	9c098a13          	addi	s4,s3,-1600
      uint64 va = KSTACK((((int) (p - proc))*8) + ((int) (t-p->threads)));
    80001a40:	8e098913          	addi	s2,s3,-1824
    80001a44:	41990933          	sub	s2,s2,s9
    80001a48:	40395913          	srai	s2,s2,0x3
    80001a4c:	03890933          	mul	s2,s2,s8
    80001a50:	0039191b          	slliw	s2,s2,0x3
    for (t =p->threads; t<&p->threads[NTHREAD] ; t++)
    80001a54:	84d2                	mv	s1,s4
      char *pa = kalloc();
    80001a56:	fffff097          	auipc	ra,0xfffff
    80001a5a:	07c080e7          	jalr	124(ra) # 80000ad2 <kalloc>
    80001a5e:	862a                	mv	a2,a0
      if(pa == 0)
    80001a60:	d161                	beqz	a0,80001a20 <proc_mapstacks+0x50>
      uint64 va = KSTACK((((int) (p - proc))*8) + ((int) (t-p->threads)));
    80001a62:	414485b3          	sub	a1,s1,s4
    80001a66:	858d                	srai	a1,a1,0x3
    80001a68:	000bb783          	ld	a5,0(s7)
    80001a6c:	02f585b3          	mul	a1,a1,a5
    80001a70:	012585bb          	addw	a1,a1,s2
    80001a74:	2585                	addiw	a1,a1,1
    80001a76:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a7a:	4719                	li	a4,6
    80001a7c:	6685                	lui	a3,0x1
    80001a7e:	40ba85b3          	sub	a1,s5,a1
    80001a82:	855a                	mv	a0,s6
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	6a0080e7          	jalr	1696(ra) # 80001124 <kvmmap>
    for (t =p->threads; t<&p->threads[NTHREAD] ; t++)
    80001a8c:	0c848493          	addi	s1,s1,200
    80001a90:	fd3493e3          	bne	s1,s3,80001a56 <proc_mapstacks+0x86>
    80001a94:	bf71                	j	80001a30 <proc_mapstacks+0x60>
}
    80001a96:	60e6                	ld	ra,88(sp)
    80001a98:	6446                	ld	s0,80(sp)
    80001a9a:	64a6                	ld	s1,72(sp)
    80001a9c:	6906                	ld	s2,64(sp)
    80001a9e:	79e2                	ld	s3,56(sp)
    80001aa0:	7a42                	ld	s4,48(sp)
    80001aa2:	7aa2                	ld	s5,40(sp)
    80001aa4:	7b02                	ld	s6,32(sp)
    80001aa6:	6be2                	ld	s7,24(sp)
    80001aa8:	6c42                	ld	s8,16(sp)
    80001aaa:	6ca2                	ld	s9,8(sp)
    80001aac:	6d02                	ld	s10,0(sp)
    80001aae:	6125                	addi	sp,sp,96
    80001ab0:	8082                	ret

0000000080001ab2 <procinit>:
{
    80001ab2:	7159                	addi	sp,sp,-112
    80001ab4:	f486                	sd	ra,104(sp)
    80001ab6:	f0a2                	sd	s0,96(sp)
    80001ab8:	eca6                	sd	s1,88(sp)
    80001aba:	e8ca                	sd	s2,80(sp)
    80001abc:	e4ce                	sd	s3,72(sp)
    80001abe:	e0d2                	sd	s4,64(sp)
    80001ac0:	fc56                	sd	s5,56(sp)
    80001ac2:	f85a                	sd	s6,48(sp)
    80001ac4:	f45e                	sd	s7,40(sp)
    80001ac6:	f062                	sd	s8,32(sp)
    80001ac8:	ec66                	sd	s9,24(sp)
    80001aca:	e86a                	sd	s10,16(sp)
    80001acc:	e46e                	sd	s11,8(sp)
    80001ace:	1880                	addi	s0,sp,112
  initlock(&pid_lock, "nextpid");
    80001ad0:	00007597          	auipc	a1,0x7
    80001ad4:	6f858593          	addi	a1,a1,1784 # 800091c8 <digits+0x188>
    80001ad8:	00011517          	auipc	a0,0x11
    80001adc:	be050513          	addi	a0,a0,-1056 # 800126b8 <pid_lock>
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	052080e7          	jalr	82(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001ae8:	00007597          	auipc	a1,0x7
    80001aec:	6e858593          	addi	a1,a1,1768 # 800091d0 <digits+0x190>
    80001af0:	00011517          	auipc	a0,0x11
    80001af4:	be050513          	addi	a0,a0,-1056 # 800126d0 <wait_lock>
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	03a080e7          	jalr	58(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) 
    80001b00:	00012997          	auipc	s3,0x12
    80001b04:	30898993          	addi	s3,s3,776 # 80013e08 <proc+0x720>
    80001b08:	00012c17          	auipc	s8,0x12
    80001b0c:	be0c0c13          	addi	s8,s8,-1056 # 800136e8 <proc>
        t->kstack = KSTACK((int) (((p - proc)*8)+(((int) (t-p->threads)))));
    80001b10:	8de2                	mv	s11,s8
    80001b12:	00007d17          	auipc	s10,0x7
    80001b16:	4eed0d13          	addi	s10,s10,1262 # 80009000 <etext>
        initlock(&t->lock, "thread");
    80001b1a:	00007b97          	auipc	s7,0x7
    80001b1e:	6ceb8b93          	addi	s7,s7,1742 # 800091e8 <digits+0x1a8>
        t->kstack = KSTACK((int) (((p - proc)*8)+(((int) (t-p->threads)))));
    80001b22:	00007b17          	auipc	s6,0x7
    80001b26:	4e6b0b13          	addi	s6,s6,1254 # 80009008 <etext+0x8>
    80001b2a:	04000ab7          	lui	s5,0x4000
    80001b2e:	1afd                	addi	s5,s5,-1
    80001b30:	0ab2                	slli	s5,s5,0xc
  for(p = proc; p < &proc[NPROC]; p++) 
    80001b32:	6c85                	lui	s9,0x1
    80001b34:	8c8c8c93          	addi	s9,s9,-1848 # 8c8 <_entry-0x7ffff738>
    80001b38:	a809                	j	80001b4a <procinit+0x98>
    80001b3a:	9c66                	add	s8,s8,s9
    80001b3c:	99e6                	add	s3,s3,s9
    80001b3e:	00035797          	auipc	a5,0x35
    80001b42:	daa78793          	addi	a5,a5,-598 # 800368e8 <tickslock>
    80001b46:	06fc0263          	beq	s8,a5,80001baa <procinit+0xf8>
      initlock(&p->lock, "proc");
    80001b4a:	00007597          	auipc	a1,0x7
    80001b4e:	69658593          	addi	a1,a1,1686 # 800091e0 <digits+0x1a0>
    80001b52:	8562                	mv	a0,s8
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	fde080e7          	jalr	-34(ra) # 80000b32 <initlock>
      for( t = p->threads ; t < &p->threads[NTHREAD] ; t++)
    80001b5c:	0e0c0a13          	addi	s4,s8,224
        t->kstack = KSTACK((int) (((p - proc)*8)+(((int) (t-p->threads)))));
    80001b60:	41bc0933          	sub	s2,s8,s11
    80001b64:	40395913          	srai	s2,s2,0x3
    80001b68:	000d3783          	ld	a5,0(s10)
    80001b6c:	02f90933          	mul	s2,s2,a5
    80001b70:	0039191b          	slliw	s2,s2,0x3
      for( t = p->threads ; t < &p->threads[NTHREAD] ; t++)
    80001b74:	84d2                	mv	s1,s4
        initlock(&t->lock, "thread");
    80001b76:	85de                	mv	a1,s7
    80001b78:	8526                	mv	a0,s1
    80001b7a:	fffff097          	auipc	ra,0xfffff
    80001b7e:	fb8080e7          	jalr	-72(ra) # 80000b32 <initlock>
        t->kstack = KSTACK((int) (((p - proc)*8)+(((int) (t-p->threads)))));
    80001b82:	414487b3          	sub	a5,s1,s4
    80001b86:	878d                	srai	a5,a5,0x3
    80001b88:	000b3703          	ld	a4,0(s6)
    80001b8c:	02e787b3          	mul	a5,a5,a4
    80001b90:	012787bb          	addw	a5,a5,s2
    80001b94:	2785                	addiw	a5,a5,1
    80001b96:	00d7979b          	slliw	a5,a5,0xd
    80001b9a:	40fa87b3          	sub	a5,s5,a5
    80001b9e:	e0bc                	sd	a5,64(s1)
      for( t = p->threads ; t < &p->threads[NTHREAD] ; t++)
    80001ba0:	0c848493          	addi	s1,s1,200
    80001ba4:	fd3499e3          	bne	s1,s3,80001b76 <procinit+0xc4>
    80001ba8:	bf49                	j	80001b3a <procinit+0x88>
}
    80001baa:	70a6                	ld	ra,104(sp)
    80001bac:	7406                	ld	s0,96(sp)
    80001bae:	64e6                	ld	s1,88(sp)
    80001bb0:	6946                	ld	s2,80(sp)
    80001bb2:	69a6                	ld	s3,72(sp)
    80001bb4:	6a06                	ld	s4,64(sp)
    80001bb6:	7ae2                	ld	s5,56(sp)
    80001bb8:	7b42                	ld	s6,48(sp)
    80001bba:	7ba2                	ld	s7,40(sp)
    80001bbc:	7c02                	ld	s8,32(sp)
    80001bbe:	6ce2                	ld	s9,24(sp)
    80001bc0:	6d42                	ld	s10,16(sp)
    80001bc2:	6da2                	ld	s11,8(sp)
    80001bc4:	6165                	addi	sp,sp,112
    80001bc6:	8082                	ret

0000000080001bc8 <cpuid>:
{
    80001bc8:	1141                	addi	sp,sp,-16
    80001bca:	e422                	sd	s0,8(sp)
    80001bcc:	0800                	addi	s0,sp,16
    80001bce:	8512                	mv	a0,tp
}
    80001bd0:	2501                	sext.w	a0,a0
    80001bd2:	6422                	ld	s0,8(sp)
    80001bd4:	0141                	addi	sp,sp,16
    80001bd6:	8082                	ret

0000000080001bd8 <mycpu>:
mycpu(void) {
    80001bd8:	1141                	addi	sp,sp,-16
    80001bda:	e422                	sd	s0,8(sp)
    80001bdc:	0800                	addi	s0,sp,16
    80001bde:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001be0:	2781                	sext.w	a5,a5
    80001be2:	079e                	slli	a5,a5,0x7
}
    80001be4:	00010517          	auipc	a0,0x10
    80001be8:	6d450513          	addi	a0,a0,1748 # 800122b8 <cpus>
    80001bec:	953e                	add	a0,a0,a5
    80001bee:	6422                	ld	s0,8(sp)
    80001bf0:	0141                	addi	sp,sp,16
    80001bf2:	8082                	ret

0000000080001bf4 <myproc>:
myproc(void) {
    80001bf4:	1101                	addi	sp,sp,-32
    80001bf6:	ec06                	sd	ra,24(sp)
    80001bf8:	e822                	sd	s0,16(sp)
    80001bfa:	e426                	sd	s1,8(sp)
    80001bfc:	1000                	addi	s0,sp,32
  push_off();
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	f78080e7          	jalr	-136(ra) # 80000b76 <push_off>
    80001c06:	8792                	mv	a5,tp
  struct proc *p = c->thread->parent;
    80001c08:	2781                	sext.w	a5,a5
    80001c0a:	079e                	slli	a5,a5,0x7
    80001c0c:	00010717          	auipc	a4,0x10
    80001c10:	69470713          	addi	a4,a4,1684 # 800122a0 <tid_lock>
    80001c14:	97ba                	add	a5,a5,a4
    80001c16:	6f9c                	ld	a5,24(a5)
    80001c18:	7f84                	ld	s1,56(a5)
  pop_off();
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	ffc080e7          	jalr	-4(ra) # 80000c16 <pop_off>
}
    80001c22:	8526                	mv	a0,s1
    80001c24:	60e2                	ld	ra,24(sp)
    80001c26:	6442                	ld	s0,16(sp)
    80001c28:	64a2                	ld	s1,8(sp)
    80001c2a:	6105                	addi	sp,sp,32
    80001c2c:	8082                	ret

0000000080001c2e <forkret>:
{
    80001c2e:	1141                	addi	sp,sp,-16
    80001c30:	e406                	sd	ra,8(sp)
    80001c32:	e022                	sd	s0,0(sp)
    80001c34:	0800                	addi	s0,sp,16
  release(&myproc()->init_thread->lock);
    80001c36:	00000097          	auipc	ra,0x0
    80001c3a:	fbe080e7          	jalr	-66(ra) # 80001bf4 <myproc>
    80001c3e:	6785                	lui	a5,0x1
    80001c40:	953e                	add	a0,a0,a5
    80001c42:	8b853503          	ld	a0,-1864(a0)
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	030080e7          	jalr	48(ra) # 80000c76 <release>
  if (first) {
    80001c4e:	00008797          	auipc	a5,0x8
    80001c52:	dc27a783          	lw	a5,-574(a5) # 80009a10 <first.1>
    80001c56:	eb89                	bnez	a5,80001c68 <forkret+0x3a>
  usertrapret();
    80001c58:	00002097          	auipc	ra,0x2
    80001c5c:	80e080e7          	jalr	-2034(ra) # 80003466 <usertrapret>
}
    80001c60:	60a2                	ld	ra,8(sp)
    80001c62:	6402                	ld	s0,0(sp)
    80001c64:	0141                	addi	sp,sp,16
    80001c66:	8082                	ret
    first = 0;
    80001c68:	00008797          	auipc	a5,0x8
    80001c6c:	da07a423          	sw	zero,-600(a5) # 80009a10 <first.1>
    fsinit(ROOTDEV);
    80001c70:	4505                	li	a0,1
    80001c72:	00002097          	auipc	ra,0x2
    80001c76:	70a080e7          	jalr	1802(ra) # 8000437c <fsinit>
    80001c7a:	bff9                	j	80001c58 <forkret+0x2a>

0000000080001c7c <allocpid>:
allocpid() {
    80001c7c:	1101                	addi	sp,sp,-32
    80001c7e:	ec06                	sd	ra,24(sp)
    80001c80:	e822                	sd	s0,16(sp)
    80001c82:	e426                	sd	s1,8(sp)
    80001c84:	e04a                	sd	s2,0(sp)
    80001c86:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c88:	00011917          	auipc	s2,0x11
    80001c8c:	a3090913          	addi	s2,s2,-1488 # 800126b8 <pid_lock>
    80001c90:	854a                	mv	a0,s2
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	f30080e7          	jalr	-208(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001c9a:	00008797          	auipc	a5,0x8
    80001c9e:	d7e78793          	addi	a5,a5,-642 # 80009a18 <nextpid>
    80001ca2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ca4:	0014871b          	addiw	a4,s1,1
    80001ca8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001caa:	854a                	mv	a0,s2
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	fca080e7          	jalr	-54(ra) # 80000c76 <release>
}
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	60e2                	ld	ra,24(sp)
    80001cb8:	6442                	ld	s0,16(sp)
    80001cba:	64a2                	ld	s1,8(sp)
    80001cbc:	6902                	ld	s2,0(sp)
    80001cbe:	6105                	addi	sp,sp,32
    80001cc0:	8082                	ret

0000000080001cc2 <proc_pagetable>:
{
    80001cc2:	1101                	addi	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	e04a                	sd	s2,0(sp)
    80001ccc:	1000                	addi	s0,sp,32
    80001cce:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	63e080e7          	jalr	1598(ra) # 8000130e <uvmcreate>
    80001cd8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001cda:	c131                	beqz	a0,80001d1e <proc_pagetable+0x5c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cdc:	4729                	li	a4,10
    80001cde:	00006697          	auipc	a3,0x6
    80001ce2:	32268693          	addi	a3,a3,802 # 80008000 <_trampoline>
    80001ce6:	6605                	lui	a2,0x1
    80001ce8:	040005b7          	lui	a1,0x4000
    80001cec:	15fd                	addi	a1,a1,-1
    80001cee:	05b2                	slli	a1,a1,0xc
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	3a6080e7          	jalr	934(ra) # 80001096 <mappages>
    80001cf8:	02054a63          	bltz	a0,80001d2c <proc_pagetable+0x6a>
              (uint64)(p->trapframes), PTE_R | PTE_W) < 0){
    80001cfc:	6505                	lui	a0,0x1
    80001cfe:	954a                	add	a0,a0,s2
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d00:	4719                	li	a4,6
    80001d02:	8c053683          	ld	a3,-1856(a0) # 8c0 <_entry-0x7ffff740>
    80001d06:	6605                	lui	a2,0x1
    80001d08:	020005b7          	lui	a1,0x2000
    80001d0c:	15fd                	addi	a1,a1,-1
    80001d0e:	05b6                	slli	a1,a1,0xd
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	384080e7          	jalr	900(ra) # 80001096 <mappages>
    80001d1a:	02054163          	bltz	a0,80001d3c <proc_pagetable+0x7a>
}
    80001d1e:	8526                	mv	a0,s1
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6902                	ld	s2,0(sp)
    80001d28:	6105                	addi	sp,sp,32
    80001d2a:	8082                	ret
    uvmfree(pagetable, 0);
    80001d2c:	4581                	li	a1,0
    80001d2e:	8526                	mv	a0,s1
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	7da080e7          	jalr	2010(ra) # 8000150a <uvmfree>
    return 0;
    80001d38:	4481                	li	s1,0
    80001d3a:	b7d5                	j	80001d1e <proc_pagetable+0x5c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d3c:	4681                	li	a3,0
    80001d3e:	4605                	li	a2,1
    80001d40:	040005b7          	lui	a1,0x4000
    80001d44:	15fd                	addi	a1,a1,-1
    80001d46:	05b2                	slli	a1,a1,0xc
    80001d48:	8526                	mv	a0,s1
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	500080e7          	jalr	1280(ra) # 8000124a <uvmunmap>
    uvmfree(pagetable, 0);
    80001d52:	4581                	li	a1,0
    80001d54:	8526                	mv	a0,s1
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	7b4080e7          	jalr	1972(ra) # 8000150a <uvmfree>
    return 0;
    80001d5e:	4481                	li	s1,0
    80001d60:	bf7d                	j	80001d1e <proc_pagetable+0x5c>

0000000080001d62 <proc_freepagetable>:
{
    80001d62:	1101                	addi	sp,sp,-32
    80001d64:	ec06                	sd	ra,24(sp)
    80001d66:	e822                	sd	s0,16(sp)
    80001d68:	e426                	sd	s1,8(sp)
    80001d6a:	e04a                	sd	s2,0(sp)
    80001d6c:	1000                	addi	s0,sp,32
    80001d6e:	84aa                	mv	s1,a0
    80001d70:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d72:	4681                	li	a3,0
    80001d74:	4605                	li	a2,1
    80001d76:	040005b7          	lui	a1,0x4000
    80001d7a:	15fd                	addi	a1,a1,-1
    80001d7c:	05b2                	slli	a1,a1,0xc
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	4cc080e7          	jalr	1228(ra) # 8000124a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d86:	4681                	li	a3,0
    80001d88:	4605                	li	a2,1
    80001d8a:	020005b7          	lui	a1,0x2000
    80001d8e:	15fd                	addi	a1,a1,-1
    80001d90:	05b6                	slli	a1,a1,0xd
    80001d92:	8526                	mv	a0,s1
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	4b6080e7          	jalr	1206(ra) # 8000124a <uvmunmap>
  uvmfree(pagetable, sz);
    80001d9c:	85ca                	mv	a1,s2
    80001d9e:	8526                	mv	a0,s1
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	76a080e7          	jalr	1898(ra) # 8000150a <uvmfree>
}
    80001da8:	60e2                	ld	ra,24(sp)
    80001daa:	6442                	ld	s0,16(sp)
    80001dac:	64a2                	ld	s1,8(sp)
    80001dae:	6902                	ld	s2,0(sp)
    80001db0:	6105                	addi	sp,sp,32
    80001db2:	8082                	ret

0000000080001db4 <freeproc>:
{
    80001db4:	7179                	addi	sp,sp,-48
    80001db6:	f406                	sd	ra,40(sp)
    80001db8:	f022                	sd	s0,32(sp)
    80001dba:	ec26                	sd	s1,24(sp)
    80001dbc:	e84a                	sd	s2,16(sp)
    80001dbe:	e44e                	sd	s3,8(sp)
    80001dc0:	1800                	addi	s0,sp,48
    80001dc2:	892a                	mv	s2,a0
  for (struct thread* t = p->threads ; t<&p->threads[NTHREAD] ; t++)
    80001dc4:	0e050493          	addi	s1,a0,224
    80001dc8:	72050993          	addi	s3,a0,1824
    freethread(t);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	a46080e7          	jalr	-1466(ra) # 80001814 <freethread>
  for (struct thread* t = p->threads ; t<&p->threads[NTHREAD] ; t++)
    80001dd6:	0c848493          	addi	s1,s1,200
    80001dda:	fe9999e3          	bne	s3,s1,80001dcc <freeproc+0x18>
  if(p->trapframes)
    80001dde:	6785                	lui	a5,0x1
    80001de0:	97ca                	add	a5,a5,s2
    80001de2:	8c07b503          	ld	a0,-1856(a5) # 8c0 <_entry-0x7ffff740>
    80001de6:	c509                	beqz	a0,80001df0 <freeproc+0x3c>
     kfree((void*)p->trapframes);
    80001de8:	fffff097          	auipc	ra,0xfffff
    80001dec:	bee080e7          	jalr	-1042(ra) # 800009d6 <kfree>
  p->trapframes = 0;
    80001df0:	6785                	lui	a5,0x1
    80001df2:	97ca                	add	a5,a5,s2
    80001df4:	8c07b023          	sd	zero,-1856(a5) # 8c0 <_entry-0x7ffff740>
  if(p->pagetable)
    80001df8:	04093503          	ld	a0,64(s2)
    80001dfc:	c519                	beqz	a0,80001e0a <freeproc+0x56>
    proc_freepagetable(p->pagetable, p->sz);
    80001dfe:	03893583          	ld	a1,56(s2)
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	f60080e7          	jalr	-160(ra) # 80001d62 <proc_freepagetable>
  p->pagetable = 0;
    80001e0a:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80001e0e:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80001e12:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001e16:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80001e1a:	0c090823          	sb	zero,208(s2)
  p->killed = 0;
    80001e1e:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001e22:	02092023          	sw	zero,32(s2)
  p->state = UNUSED_P;
    80001e26:	00092c23          	sw	zero,24(s2)
}
    80001e2a:	70a2                	ld	ra,40(sp)
    80001e2c:	7402                	ld	s0,32(sp)
    80001e2e:	64e2                	ld	s1,24(sp)
    80001e30:	6942                	ld	s2,16(sp)
    80001e32:	69a2                	ld	s3,8(sp)
    80001e34:	6145                	addi	sp,sp,48
    80001e36:	8082                	ret

0000000080001e38 <allocproc>:
{
    80001e38:	7179                	addi	sp,sp,-48
    80001e3a:	f406                	sd	ra,40(sp)
    80001e3c:	f022                	sd	s0,32(sp)
    80001e3e:	ec26                	sd	s1,24(sp)
    80001e40:	e84a                	sd	s2,16(sp)
    80001e42:	e44e                	sd	s3,8(sp)
    80001e44:	e052                	sd	s4,0(sp)
    80001e46:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e48:	00012497          	auipc	s1,0x12
    80001e4c:	8a048493          	addi	s1,s1,-1888 # 800136e8 <proc>
    80001e50:	6985                	lui	s3,0x1
    80001e52:	8c898993          	addi	s3,s3,-1848 # 8c8 <_entry-0x7ffff738>
    80001e56:	00035a17          	auipc	s4,0x35
    80001e5a:	a92a0a13          	addi	s4,s4,-1390 # 800368e8 <tickslock>
    acquire(&p->lock);
    80001e5e:	8526                	mv	a0,s1
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	d62080e7          	jalr	-670(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED_P) {
    80001e68:	4c9c                	lw	a5,24(s1)
    80001e6a:	cb99                	beqz	a5,80001e80 <allocproc+0x48>
      release(&p->lock);
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	e08080e7          	jalr	-504(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e76:	94ce                	add	s1,s1,s3
    80001e78:	ff4493e3          	bne	s1,s4,80001e5e <allocproc+0x26>
  return 0;
    80001e7c:	4481                	li	s1,0
    80001e7e:	a8b5                	j	80001efa <allocproc+0xc2>
  p->pid = allocpid();
    80001e80:	00000097          	auipc	ra,0x0
    80001e84:	dfc080e7          	jalr	-516(ra) # 80001c7c <allocpid>
    80001e88:	d0c8                	sw	a0,36(s1)
  p->state = USED_P;
    80001e8a:	4785                	li	a5,1
    80001e8c:	cc9c                	sw	a5,24(s1)
  if((p->trapframes = (struct trapframe *)kalloc()) == 0){
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	c44080e7          	jalr	-956(ra) # 80000ad2 <kalloc>
    80001e96:	89aa                	mv	s3,a0
    80001e98:	6785                	lui	a5,0x1
    80001e9a:	97a6                	add	a5,a5,s1
    80001e9c:	8ca7b023          	sd	a0,-1856(a5) # 8c0 <_entry-0x7ffff740>
    80001ea0:	c535                	beqz	a0,80001f0c <allocproc+0xd4>
  p->pagetable = proc_pagetable(p);
    80001ea2:	8526                	mv	a0,s1
    80001ea4:	00000097          	auipc	ra,0x0
    80001ea8:	e1e080e7          	jalr	-482(ra) # 80001cc2 <proc_pagetable>
    80001eac:	89aa                	mv	s3,a0
    80001eae:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80001eb0:	c935                	beqz	a0,80001f24 <allocproc+0xec>
  p->pending_signals = 0;
    80001eb2:	7204a023          	sw	zero,1824(s1)
  p->proc_signal_mask = 0;
    80001eb6:	7204a223          	sw	zero,1828(s1)
  for (int i=0 ; i<NUM_OF_SIGNALS ; i++)
    80001eba:	72848713          	addi	a4,s1,1832
    80001ebe:	6685                	lui	a3,0x1
    80001ec0:	82868793          	addi	a5,a3,-2008 # 828 <_entry-0x7ffff7d8>
    80001ec4:	97a6                	add	a5,a5,s1
    80001ec6:	8a868693          	addi	a3,a3,-1880
    80001eca:	96a6                	add	a3,a3,s1
    p->signal_handlers[i] = SIG_DFL;
    80001ecc:	00073023          	sd	zero,0(a4)
    p->signal_masks[i] = 0;
    80001ed0:	0007a023          	sw	zero,0(a5)
  for (int i=0 ; i<NUM_OF_SIGNALS ; i++)
    80001ed4:	0721                	addi	a4,a4,8
    80001ed6:	0791                	addi	a5,a5,4
    80001ed8:	fed79ae3          	bne	a5,a3,80001ecc <allocproc+0x94>
  p->signal_handling = 0;
    80001edc:	6905                	lui	s2,0x1
    80001ede:	9926                	add	s2,s2,s1
    80001ee0:	8a092823          	sw	zero,-1872(s2) # 8b0 <_entry-0x7ffff750>
  p->freezed = 0;
    80001ee4:	8a092423          	sw	zero,-1880(s2)
  t = allocthread(p);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	00000097          	auipc	ra,0x0
    80001eee:	9aa080e7          	jalr	-1622(ra) # 80001894 <allocthread>
  p->init_thread = t;
    80001ef2:	8aa93c23          	sd	a0,-1864(s2)
  p->alive_threads = 1;
    80001ef6:	4785                	li	a5,1
    80001ef8:	d49c                	sw	a5,40(s1)
}
    80001efa:	8526                	mv	a0,s1
    80001efc:	70a2                	ld	ra,40(sp)
    80001efe:	7402                	ld	s0,32(sp)
    80001f00:	64e2                	ld	s1,24(sp)
    80001f02:	6942                	ld	s2,16(sp)
    80001f04:	69a2                	ld	s3,8(sp)
    80001f06:	6a02                	ld	s4,0(sp)
    80001f08:	6145                	addi	sp,sp,48
    80001f0a:	8082                	ret
    freeproc(p);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	00000097          	auipc	ra,0x0
    80001f12:	ea6080e7          	jalr	-346(ra) # 80001db4 <freeproc>
    release(&p->lock);
    80001f16:	8526                	mv	a0,s1
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	d5e080e7          	jalr	-674(ra) # 80000c76 <release>
    return 0;
    80001f20:	84ce                	mv	s1,s3
    80001f22:	bfe1                	j	80001efa <allocproc+0xc2>
    freeproc(p);
    80001f24:	8526                	mv	a0,s1
    80001f26:	00000097          	auipc	ra,0x0
    80001f2a:	e8e080e7          	jalr	-370(ra) # 80001db4 <freeproc>
    release(&p->lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	d46080e7          	jalr	-698(ra) # 80000c76 <release>
    return 0;
    80001f38:	84ce                	mv	s1,s3
    80001f3a:	b7c1                	j	80001efa <allocproc+0xc2>

0000000080001f3c <userinit>:
{
    80001f3c:	1101                	addi	sp,sp,-32
    80001f3e:	ec06                	sd	ra,24(sp)
    80001f40:	e822                	sd	s0,16(sp)
    80001f42:	e426                	sd	s1,8(sp)
    80001f44:	e04a                	sd	s2,0(sp)
    80001f46:	1000                	addi	s0,sp,32
  printf("in user init\n");
    80001f48:	00007517          	auipc	a0,0x7
    80001f4c:	2a850513          	addi	a0,a0,680 # 800091f0 <digits+0x1b0>
    80001f50:	ffffe097          	auipc	ra,0xffffe
    80001f54:	624080e7          	jalr	1572(ra) # 80000574 <printf>
  p = allocproc();
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	ee0080e7          	jalr	-288(ra) # 80001e38 <allocproc>
    80001f60:	84aa                	mv	s1,a0
  initproc = p;
    80001f62:	00008797          	auipc	a5,0x8
    80001f66:	0ca7b323          	sd	a0,198(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f6a:	03400613          	li	a2,52
    80001f6e:	00008597          	auipc	a1,0x8
    80001f72:	ab258593          	addi	a1,a1,-1358 # 80009a20 <initcode>
    80001f76:	6128                	ld	a0,64(a0)
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	3c4080e7          	jalr	964(ra) # 8000133c <uvminit>
  p->sz = PGSIZE;
    80001f80:	6785                	lui	a5,0x1
    80001f82:	fc9c                	sd	a5,56(s1)
  p->init_thread->trapframe->epc = 0;      // user program counter
    80001f84:	00f48933          	add	s2,s1,a5
    80001f88:	8b893703          	ld	a4,-1864(s2)
    80001f8c:	6738                	ld	a4,72(a4)
    80001f8e:	00073c23          	sd	zero,24(a4)
  p->init_thread->trapframe->sp = PGSIZE;  // user stack pointer
    80001f92:	8b893703          	ld	a4,-1864(s2)
    80001f96:	6738                	ld	a4,72(a4)
    80001f98:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f9a:	4641                	li	a2,16
    80001f9c:	00007597          	auipc	a1,0x7
    80001fa0:	26458593          	addi	a1,a1,612 # 80009200 <digits+0x1c0>
    80001fa4:	0d048513          	addi	a0,s1,208
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	e68080e7          	jalr	-408(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001fb0:	00007517          	auipc	a0,0x7
    80001fb4:	26050513          	addi	a0,a0,608 # 80009210 <digits+0x1d0>
    80001fb8:	00003097          	auipc	ra,0x3
    80001fbc:	df0080e7          	jalr	-528(ra) # 80004da8 <namei>
    80001fc0:	e4e8                	sd	a0,200(s1)
  p->init_thread->state = RUNNABLE;
    80001fc2:	8b893783          	ld	a5,-1864(s2)
    80001fc6:	470d                	li	a4,3
    80001fc8:	cf98                	sw	a4,24(a5)
  p->state = ALIVE;
    80001fca:	4789                	li	a5,2
    80001fcc:	cc9c                	sw	a5,24(s1)
  release(&p->init_thread->lock);
    80001fce:	8b893503          	ld	a0,-1864(s2)
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	ca4080e7          	jalr	-860(ra) # 80000c76 <release>
  release(&p->lock);
    80001fda:	8526                	mv	a0,s1
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	c9a080e7          	jalr	-870(ra) # 80000c76 <release>
}
    80001fe4:	60e2                	ld	ra,24(sp)
    80001fe6:	6442                	ld	s0,16(sp)
    80001fe8:	64a2                	ld	s1,8(sp)
    80001fea:	6902                	ld	s2,0(sp)
    80001fec:	6105                	addi	sp,sp,32
    80001fee:	8082                	ret

0000000080001ff0 <growproc>:
{
    80001ff0:	1101                	addi	sp,sp,-32
    80001ff2:	ec06                	sd	ra,24(sp)
    80001ff4:	e822                	sd	s0,16(sp)
    80001ff6:	e426                	sd	s1,8(sp)
    80001ff8:	e04a                	sd	s2,0(sp)
    80001ffa:	1000                	addi	s0,sp,32
    80001ffc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	bf6080e7          	jalr	-1034(ra) # 80001bf4 <myproc>
    80002006:	892a                	mv	s2,a0
  sz = p->sz;
    80002008:	7d0c                	ld	a1,56(a0)
    8000200a:	0005861b          	sext.w	a2,a1
  if(n > 0){
    8000200e:	00904f63          	bgtz	s1,8000202c <growproc+0x3c>
  } else if(n < 0){
    80002012:	0204cc63          	bltz	s1,8000204a <growproc+0x5a>
  p->sz = sz;
    80002016:	1602                	slli	a2,a2,0x20
    80002018:	9201                	srli	a2,a2,0x20
    8000201a:	02c93c23          	sd	a2,56(s2)
  return 0;
    8000201e:	4501                	li	a0,0
}
    80002020:	60e2                	ld	ra,24(sp)
    80002022:	6442                	ld	s0,16(sp)
    80002024:	64a2                	ld	s1,8(sp)
    80002026:	6902                	ld	s2,0(sp)
    80002028:	6105                	addi	sp,sp,32
    8000202a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000202c:	9e25                	addw	a2,a2,s1
    8000202e:	1602                	slli	a2,a2,0x20
    80002030:	9201                	srli	a2,a2,0x20
    80002032:	1582                	slli	a1,a1,0x20
    80002034:	9181                	srli	a1,a1,0x20
    80002036:	6128                	ld	a0,64(a0)
    80002038:	fffff097          	auipc	ra,0xfffff
    8000203c:	3be080e7          	jalr	958(ra) # 800013f6 <uvmalloc>
    80002040:	0005061b          	sext.w	a2,a0
    80002044:	fa69                	bnez	a2,80002016 <growproc+0x26>
      return -1;
    80002046:	557d                	li	a0,-1
    80002048:	bfe1                	j	80002020 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000204a:	9e25                	addw	a2,a2,s1
    8000204c:	1602                	slli	a2,a2,0x20
    8000204e:	9201                	srli	a2,a2,0x20
    80002050:	1582                	slli	a1,a1,0x20
    80002052:	9181                	srli	a1,a1,0x20
    80002054:	6128                	ld	a0,64(a0)
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	358080e7          	jalr	856(ra) # 800013ae <uvmdealloc>
    8000205e:	0005061b          	sext.w	a2,a0
    80002062:	bf55                	j	80002016 <growproc+0x26>

0000000080002064 <fork>:
{
    80002064:	7139                	addi	sp,sp,-64
    80002066:	fc06                	sd	ra,56(sp)
    80002068:	f822                	sd	s0,48(sp)
    8000206a:	f426                	sd	s1,40(sp)
    8000206c:	f04a                	sd	s2,32(sp)
    8000206e:	ec4e                	sd	s3,24(sp)
    80002070:	e852                	sd	s4,16(sp)
    80002072:	e456                	sd	s5,8(sp)
    80002074:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002076:	00000097          	auipc	ra,0x0
    8000207a:	b7e080e7          	jalr	-1154(ra) # 80001bf4 <myproc>
    8000207e:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80002080:	00000097          	auipc	ra,0x0
    80002084:	db8080e7          	jalr	-584(ra) # 80001e38 <allocproc>
    80002088:	14050663          	beqz	a0,800021d4 <fork+0x170>
    8000208c:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000208e:	0389b603          	ld	a2,56(s3)
    80002092:	612c                	ld	a1,64(a0)
    80002094:	0409b503          	ld	a0,64(s3)
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	4aa080e7          	jalr	1194(ra) # 80001542 <uvmcopy>
    800020a0:	08054e63          	bltz	a0,8000213c <fork+0xd8>
  np->sz = p->sz;
    800020a4:	0389b783          	ld	a5,56(s3)
    800020a8:	02f93c23          	sd	a5,56(s2)
  np->pending_signals = 0;
    800020ac:	72092023          	sw	zero,1824(s2)
  np->proc_signal_mask = p->proc_signal_mask;
    800020b0:	7249a783          	lw	a5,1828(s3)
    800020b4:	72f92223          	sw	a5,1828(s2)
  for (int i=0 ; i<NUM_OF_SIGNALS ; i++)
    800020b8:	72898693          	addi	a3,s3,1832
    800020bc:	72890713          	addi	a4,s2,1832
  np->proc_signal_mask = p->proc_signal_mask;
    800020c0:	6785                	lui	a5,0x1
    800020c2:	82878793          	addi	a5,a5,-2008 # 828 <_entry-0x7ffff7d8>
  for (int i=0 ; i<NUM_OF_SIGNALS ; i++)
    800020c6:	6505                	lui	a0,0x1
    800020c8:	8a850513          	addi	a0,a0,-1880 # 8a8 <_entry-0x7ffff758>
    np->signal_handlers[i] = p->signal_handlers[i];
    800020cc:	6290                	ld	a2,0(a3)
    800020ce:	e310                	sd	a2,0(a4)
    np->signal_masks[i] = p->signal_masks[i];
    800020d0:	00f98633          	add	a2,s3,a5
    800020d4:	420c                	lw	a1,0(a2)
    800020d6:	00f90633          	add	a2,s2,a5
    800020da:	c20c                	sw	a1,0(a2)
  for (int i=0 ; i<NUM_OF_SIGNALS ; i++)
    800020dc:	06a1                	addi	a3,a3,8
    800020de:	0721                	addi	a4,a4,8
    800020e0:	0791                	addi	a5,a5,4
    800020e2:	fea795e3          	bne	a5,a0,800020cc <fork+0x68>
  struct thread *t = mythread();
    800020e6:	00000097          	auipc	ra,0x0
    800020ea:	88a080e7          	jalr	-1910(ra) # 80001970 <mythread>
  *(np->init_thread->trapframe) = *(t->trapframe);
    800020ee:	6534                	ld	a3,72(a0)
    800020f0:	6785                	lui	a5,0x1
    800020f2:	97ca                	add	a5,a5,s2
    800020f4:	8b87b703          	ld	a4,-1864(a5) # 8b8 <_entry-0x7ffff748>
    800020f8:	87b6                	mv	a5,a3
    800020fa:	6738                	ld	a4,72(a4)
    800020fc:	12068693          	addi	a3,a3,288
    80002100:	0007b803          	ld	a6,0(a5)
    80002104:	6788                	ld	a0,8(a5)
    80002106:	6b8c                	ld	a1,16(a5)
    80002108:	6f90                	ld	a2,24(a5)
    8000210a:	01073023          	sd	a6,0(a4)
    8000210e:	e708                	sd	a0,8(a4)
    80002110:	eb0c                	sd	a1,16(a4)
    80002112:	ef10                	sd	a2,24(a4)
    80002114:	02078793          	addi	a5,a5,32
    80002118:	02070713          	addi	a4,a4,32
    8000211c:	fed792e3          	bne	a5,a3,80002100 <fork+0x9c>
  np->init_thread->trapframe->a0 = 0;
    80002120:	6785                	lui	a5,0x1
    80002122:	97ca                	add	a5,a5,s2
    80002124:	8b87b783          	ld	a5,-1864(a5) # 8b8 <_entry-0x7ffff748>
    80002128:	67bc                	ld	a5,72(a5)
    8000212a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000212e:	04898493          	addi	s1,s3,72
    80002132:	04890a13          	addi	s4,s2,72
    80002136:	0c898a93          	addi	s5,s3,200
    8000213a:	a00d                	j	8000215c <fork+0xf8>
    freeproc(np);
    8000213c:	854a                	mv	a0,s2
    8000213e:	00000097          	auipc	ra,0x0
    80002142:	c76080e7          	jalr	-906(ra) # 80001db4 <freeproc>
    release(&np->lock);
    80002146:	854a                	mv	a0,s2
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	b2e080e7          	jalr	-1234(ra) # 80000c76 <release>
    return -1;
    80002150:	54fd                	li	s1,-1
    80002152:	a0bd                	j	800021c0 <fork+0x15c>
  for(i = 0; i < NOFILE; i++)
    80002154:	04a1                	addi	s1,s1,8
    80002156:	0a21                	addi	s4,s4,8
    80002158:	01548b63          	beq	s1,s5,8000216e <fork+0x10a>
    if(p->ofile[i])
    8000215c:	6088                	ld	a0,0(s1)
    8000215e:	d97d                	beqz	a0,80002154 <fork+0xf0>
      np->ofile[i] = filedup(p->ofile[i]);
    80002160:	00003097          	auipc	ra,0x3
    80002164:	2e2080e7          	jalr	738(ra) # 80005442 <filedup>
    80002168:	00aa3023          	sd	a0,0(s4)
    8000216c:	b7e5                	j	80002154 <fork+0xf0>
  np->cwd = idup(p->cwd);
    8000216e:	0c89b503          	ld	a0,200(s3)
    80002172:	00002097          	auipc	ra,0x2
    80002176:	444080e7          	jalr	1092(ra) # 800045b6 <idup>
    8000217a:	0ca93423          	sd	a0,200(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000217e:	4641                	li	a2,16
    80002180:	0d098593          	addi	a1,s3,208
    80002184:	0d090513          	addi	a0,s2,208
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	c88080e7          	jalr	-888(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002190:	02492483          	lw	s1,36(s2)
  np->state = ALIVE;
    80002194:	4789                	li	a5,2
    80002196:	00f92c23          	sw	a5,24(s2)
  release(&np->lock);
    8000219a:	854a                	mv	a0,s2
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	ada080e7          	jalr	-1318(ra) # 80000c76 <release>
  np->parent = p;
    800021a4:	03393823          	sd	s3,48(s2)
  np->init_thread->state = RUNNABLE;
    800021a8:	6785                	lui	a5,0x1
    800021aa:	993e                	add	s2,s2,a5
    800021ac:	8b893783          	ld	a5,-1864(s2)
    800021b0:	470d                	li	a4,3
    800021b2:	cf98                	sw	a4,24(a5)
  release(&np->init_thread->lock);
    800021b4:	8b893503          	ld	a0,-1864(s2)
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	abe080e7          	jalr	-1346(ra) # 80000c76 <release>
}
    800021c0:	8526                	mv	a0,s1
    800021c2:	70e2                	ld	ra,56(sp)
    800021c4:	7442                	ld	s0,48(sp)
    800021c6:	74a2                	ld	s1,40(sp)
    800021c8:	7902                	ld	s2,32(sp)
    800021ca:	69e2                	ld	s3,24(sp)
    800021cc:	6a42                	ld	s4,16(sp)
    800021ce:	6aa2                	ld	s5,8(sp)
    800021d0:	6121                	addi	sp,sp,64
    800021d2:	8082                	ret
    return -1;
    800021d4:	54fd                	li	s1,-1
    800021d6:	b7ed                	j	800021c0 <fork+0x15c>

00000000800021d8 <scheduler>:
{
    800021d8:	711d                	addi	sp,sp,-96
    800021da:	ec86                	sd	ra,88(sp)
    800021dc:	e8a2                	sd	s0,80(sp)
    800021de:	e4a6                	sd	s1,72(sp)
    800021e0:	e0ca                	sd	s2,64(sp)
    800021e2:	fc4e                	sd	s3,56(sp)
    800021e4:	f852                	sd	s4,48(sp)
    800021e6:	f456                	sd	s5,40(sp)
    800021e8:	f05a                	sd	s6,32(sp)
    800021ea:	ec5e                	sd	s7,24(sp)
    800021ec:	e862                	sd	s8,16(sp)
    800021ee:	e466                	sd	s9,8(sp)
    800021f0:	e06a                	sd	s10,0(sp)
    800021f2:	1080                	addi	s0,sp,96
    800021f4:	8792                	mv	a5,tp
  int id = r_tp();
    800021f6:	2781                	sext.w	a5,a5
  c->thread = 0;
    800021f8:	00779c13          	slli	s8,a5,0x7
    800021fc:	00010717          	auipc	a4,0x10
    80002200:	0a470713          	addi	a4,a4,164 # 800122a0 <tid_lock>
    80002204:	9762                	add	a4,a4,s8
    80002206:	00073c23          	sd	zero,24(a4)
            swtch(&c->context, &t->context);
    8000220a:	00010717          	auipc	a4,0x10
    8000220e:	0b670713          	addi	a4,a4,182 # 800122c0 <cpus+0x8>
    80002212:	9c3a                	add	s8,s8,a4
    80002214:	00035b17          	auipc	s6,0x35
    80002218:	df4b0b13          	addi	s6,s6,-524 # 80037008 <bcache+0x708>
            t->state = RUNNING;
    8000221c:	4c91                	li	s9,4
            c->thread = t;
    8000221e:	079e                	slli	a5,a5,0x7
    80002220:	00010b97          	auipc	s7,0x10
    80002224:	080b8b93          	addi	s7,s7,128 # 800122a0 <tid_lock>
    80002228:	9bbe                	add	s7,s7,a5
    for(p = proc; p < &proc[NPROC]; p++) 
    8000222a:	6a85                	lui	s5,0x1
    8000222c:	8c8a8a93          	addi	s5,s5,-1848 # 8c8 <_entry-0x7ffff738>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002230:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002234:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002238:	10079073          	csrw	sstatus,a5
    8000223c:	00012917          	auipc	s2,0x12
    80002240:	bcc90913          	addi	s2,s2,-1076 # 80013e08 <proc+0x720>
      if(p->state == ALIVE) 
    80002244:	4a09                	li	s4,2
    80002246:	a099                	j	8000228c <scheduler+0xb4>
          release(&t->lock);
    80002248:	8526                	mv	a0,s1
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	a2c080e7          	jalr	-1492(ra) # 80000c76 <release>
        for(struct thread* t = p->threads ; t< &p->threads[NTHREAD] ; t++)
    80002252:	0c848493          	addi	s1,s1,200
    80002256:	03348863          	beq	s1,s3,80002286 <scheduler+0xae>
          acquire(&t->lock);
    8000225a:	8526                	mv	a0,s1
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	966080e7          	jalr	-1690(ra) # 80000bc2 <acquire>
          if(t->state == RUNNABLE)
    80002264:	4c9c                	lw	a5,24(s1)
    80002266:	ffa791e3          	bne	a5,s10,80002248 <scheduler+0x70>
            t->state = RUNNING;
    8000226a:	0194ac23          	sw	s9,24(s1)
            c->thread = t;
    8000226e:	009bbc23          	sd	s1,24(s7)
            swtch(&c->context, &t->context);
    80002272:	05848593          	addi	a1,s1,88
    80002276:	8562                	mv	a0,s8
    80002278:	00001097          	auipc	ra,0x1
    8000227c:	cbe080e7          	jalr	-834(ra) # 80002f36 <swtch>
            c->thread = 0;
    80002280:	000bbc23          	sd	zero,24(s7)
    80002284:	b7d1                	j	80002248 <scheduler+0x70>
    for(p = proc; p < &proc[NPROC]; p++) 
    80002286:	9956                	add	s2,s2,s5
    80002288:	fb6904e3          	beq	s2,s6,80002230 <scheduler+0x58>
      if(p->state == ALIVE) 
    8000228c:	89ca                	mv	s3,s2
    8000228e:	8f892783          	lw	a5,-1800(s2)
    80002292:	ff479ae3          	bne	a5,s4,80002286 <scheduler+0xae>
        for(struct thread* t = p->threads ; t< &p->threads[NTHREAD] ; t++)
    80002296:	9c090493          	addi	s1,s2,-1600
          if(t->state == RUNNABLE)
    8000229a:	4d0d                	li	s10,3
    8000229c:	bf7d                	j	8000225a <scheduler+0x82>

000000008000229e <sched>:
{
    8000229e:	7179                	addi	sp,sp,-48
    800022a0:	f406                	sd	ra,40(sp)
    800022a2:	f022                	sd	s0,32(sp)
    800022a4:	ec26                	sd	s1,24(sp)
    800022a6:	e84a                	sd	s2,16(sp)
    800022a8:	e44e                	sd	s3,8(sp)
    800022aa:	1800                	addi	s0,sp,48
  struct thread *t = mythread();
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	6c4080e7          	jalr	1732(ra) # 80001970 <mythread>
    800022b4:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	892080e7          	jalr	-1902(ra) # 80000b48 <holding>
    800022be:	c93d                	beqz	a0,80002334 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022c0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800022c2:	2781                	sext.w	a5,a5
    800022c4:	079e                	slli	a5,a5,0x7
    800022c6:	00010717          	auipc	a4,0x10
    800022ca:	fda70713          	addi	a4,a4,-38 # 800122a0 <tid_lock>
    800022ce:	97ba                	add	a5,a5,a4
    800022d0:	0907a703          	lw	a4,144(a5) # 1090 <_entry-0x7fffef70>
    800022d4:	4785                	li	a5,1
    800022d6:	06f71763          	bne	a4,a5,80002344 <sched+0xa6>
  if(t->state == RUNNING)
    800022da:	4c98                	lw	a4,24(s1)
    800022dc:	4791                	li	a5,4
    800022de:	06f70b63          	beq	a4,a5,80002354 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022e2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022e6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022e8:	efb5                	bnez	a5,80002364 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022ea:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022ec:	00010917          	auipc	s2,0x10
    800022f0:	fb490913          	addi	s2,s2,-76 # 800122a0 <tid_lock>
    800022f4:	2781                	sext.w	a5,a5
    800022f6:	079e                	slli	a5,a5,0x7
    800022f8:	97ca                	add	a5,a5,s2
    800022fa:	0947a983          	lw	s3,148(a5)
    800022fe:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80002300:	2781                	sext.w	a5,a5
    80002302:	079e                	slli	a5,a5,0x7
    80002304:	00010597          	auipc	a1,0x10
    80002308:	fbc58593          	addi	a1,a1,-68 # 800122c0 <cpus+0x8>
    8000230c:	95be                	add	a1,a1,a5
    8000230e:	05848513          	addi	a0,s1,88
    80002312:	00001097          	auipc	ra,0x1
    80002316:	c24080e7          	jalr	-988(ra) # 80002f36 <swtch>
    8000231a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000231c:	2781                	sext.w	a5,a5
    8000231e:	079e                	slli	a5,a5,0x7
    80002320:	97ca                	add	a5,a5,s2
    80002322:	0937aa23          	sw	s3,148(a5)
}
    80002326:	70a2                	ld	ra,40(sp)
    80002328:	7402                	ld	s0,32(sp)
    8000232a:	64e2                	ld	s1,24(sp)
    8000232c:	6942                	ld	s2,16(sp)
    8000232e:	69a2                	ld	s3,8(sp)
    80002330:	6145                	addi	sp,sp,48
    80002332:	8082                	ret
    panic("sched t->lock");
    80002334:	00007517          	auipc	a0,0x7
    80002338:	ee450513          	addi	a0,a0,-284 # 80009218 <digits+0x1d8>
    8000233c:	ffffe097          	auipc	ra,0xffffe
    80002340:	1ee080e7          	jalr	494(ra) # 8000052a <panic>
    panic("sched locks");
    80002344:	00007517          	auipc	a0,0x7
    80002348:	ee450513          	addi	a0,a0,-284 # 80009228 <digits+0x1e8>
    8000234c:	ffffe097          	auipc	ra,0xffffe
    80002350:	1de080e7          	jalr	478(ra) # 8000052a <panic>
    panic("sched running");
    80002354:	00007517          	auipc	a0,0x7
    80002358:	ee450513          	addi	a0,a0,-284 # 80009238 <digits+0x1f8>
    8000235c:	ffffe097          	auipc	ra,0xffffe
    80002360:	1ce080e7          	jalr	462(ra) # 8000052a <panic>
  panic("sched interruptible");
    80002364:	00007517          	auipc	a0,0x7
    80002368:	ee450513          	addi	a0,a0,-284 # 80009248 <digits+0x208>
    8000236c:	ffffe097          	auipc	ra,0xffffe
    80002370:	1be080e7          	jalr	446(ra) # 8000052a <panic>

0000000080002374 <exit_thread>:
{
    80002374:	7179                	addi	sp,sp,-48
    80002376:	f406                	sd	ra,40(sp)
    80002378:	f022                	sd	s0,32(sp)
    8000237a:	ec26                	sd	s1,24(sp)
    8000237c:	e84a                	sd	s2,16(sp)
    8000237e:	e44e                	sd	s3,8(sp)
    80002380:	1800                	addi	s0,sp,48
    80002382:	892a                	mv	s2,a0
  struct thread *t = mythread();
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	5ec080e7          	jalr	1516(ra) # 80001970 <mythread>
    8000238c:	84aa                	mv	s1,a0
  acquire(&t->parent->lock);
    8000238e:	7d08                	ld	a0,56(a0)
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	832080e7          	jalr	-1998(ra) # 80000bc2 <acquire>
  int alive_threads = t->parent->alive_threads;
    80002398:	7c88                	ld	a0,56(s1)
    8000239a:	02852983          	lw	s3,40(a0)
  release(&t->parent->lock);
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	8d8080e7          	jalr	-1832(ra) # 80000c76 <release>
  acquire(&t->lock);
    800023a6:	8526                	mv	a0,s1
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	81a080e7          	jalr	-2022(ra) # 80000bc2 <acquire>
  t->xstate = status;
    800023b0:	0324a623          	sw	s2,44(s1)
  t->state = ZOMBIE;
    800023b4:	4795                	li	a5,5
    800023b6:	cc9c                	sw	a5,24(s1)
  if (alive_threads == 0)
    800023b8:	00099563          	bnez	s3,800023c2 <exit_thread+0x4e>
    t->parent->state = ZOMBIE_P;
    800023bc:	7c9c                	ld	a5,56(s1)
    800023be:	470d                	li	a4,3
    800023c0:	cf98                	sw	a4,24(a5)
  release(&wait_lock);
    800023c2:	00010517          	auipc	a0,0x10
    800023c6:	30e50513          	addi	a0,a0,782 # 800126d0 <wait_lock>
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	8ac080e7          	jalr	-1876(ra) # 80000c76 <release>
  sched();
    800023d2:	00000097          	auipc	ra,0x0
    800023d6:	ecc080e7          	jalr	-308(ra) # 8000229e <sched>
  panic("zombie exit");
    800023da:	00007517          	auipc	a0,0x7
    800023de:	e8650513          	addi	a0,a0,-378 # 80009260 <digits+0x220>
    800023e2:	ffffe097          	auipc	ra,0xffffe
    800023e6:	148080e7          	jalr	328(ra) # 8000052a <panic>

00000000800023ea <yield>:
{
    800023ea:	1101                	addi	sp,sp,-32
    800023ec:	ec06                	sd	ra,24(sp)
    800023ee:	e822                	sd	s0,16(sp)
    800023f0:	e426                	sd	s1,8(sp)
    800023f2:	1000                	addi	s0,sp,32
  struct thread *t = mythread();
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	57c080e7          	jalr	1404(ra) # 80001970 <mythread>
    800023fc:	84aa                	mv	s1,a0
  acquire(&t->lock);
    800023fe:	ffffe097          	auipc	ra,0xffffe
    80002402:	7c4080e7          	jalr	1988(ra) # 80000bc2 <acquire>
  t->state = RUNNABLE;
    80002406:	478d                	li	a5,3
    80002408:	cc9c                	sw	a5,24(s1)
  sched();
    8000240a:	00000097          	auipc	ra,0x0
    8000240e:	e94080e7          	jalr	-364(ra) # 8000229e <sched>
  release(&t->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	862080e7          	jalr	-1950(ra) # 80000c76 <release>
}
    8000241c:	60e2                	ld	ra,24(sp)
    8000241e:	6442                	ld	s0,16(sp)
    80002420:	64a2                	ld	s1,8(sp)
    80002422:	6105                	addi	sp,sp,32
    80002424:	8082                	ret

0000000080002426 <sleep>:
{
    80002426:	7179                	addi	sp,sp,-48
    80002428:	f406                	sd	ra,40(sp)
    8000242a:	f022                	sd	s0,32(sp)
    8000242c:	ec26                	sd	s1,24(sp)
    8000242e:	e84a                	sd	s2,16(sp)
    80002430:	e44e                	sd	s3,8(sp)
    80002432:	1800                	addi	s0,sp,48
    80002434:	89aa                	mv	s3,a0
    80002436:	892e                	mv	s2,a1
  struct thread *t = mythread();
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	538080e7          	jalr	1336(ra) # 80001970 <mythread>
    80002440:	84aa                	mv	s1,a0
  acquire(&t->lock);  //DOC: sleeplock1
    80002442:	ffffe097          	auipc	ra,0xffffe
    80002446:	780080e7          	jalr	1920(ra) # 80000bc2 <acquire>
  release(lk);
    8000244a:	854a                	mv	a0,s2
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	82a080e7          	jalr	-2006(ra) # 80000c76 <release>
  t->chan = chan;
    80002454:	0334b023          	sd	s3,32(s1)
  t->state = SLEEPING;
    80002458:	4789                	li	a5,2
    8000245a:	cc9c                	sw	a5,24(s1)
  sched();
    8000245c:	00000097          	auipc	ra,0x0
    80002460:	e42080e7          	jalr	-446(ra) # 8000229e <sched>
  t->chan = 0;
    80002464:	0204b023          	sd	zero,32(s1)
  release(&t->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	80c080e7          	jalr	-2036(ra) # 80000c76 <release>
  acquire(lk);
    80002472:	854a                	mv	a0,s2
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	74e080e7          	jalr	1870(ra) # 80000bc2 <acquire>
}
    8000247c:	70a2                	ld	ra,40(sp)
    8000247e:	7402                	ld	s0,32(sp)
    80002480:	64e2                	ld	s1,24(sp)
    80002482:	6942                	ld	s2,16(sp)
    80002484:	69a2                	ld	s3,8(sp)
    80002486:	6145                	addi	sp,sp,48
    80002488:	8082                	ret

000000008000248a <wait>:
{
    8000248a:	715d                	addi	sp,sp,-80
    8000248c:	e486                	sd	ra,72(sp)
    8000248e:	e0a2                	sd	s0,64(sp)
    80002490:	fc26                	sd	s1,56(sp)
    80002492:	f84a                	sd	s2,48(sp)
    80002494:	f44e                	sd	s3,40(sp)
    80002496:	f052                	sd	s4,32(sp)
    80002498:	ec56                	sd	s5,24(sp)
    8000249a:	e85a                	sd	s6,16(sp)
    8000249c:	e45e                	sd	s7,8(sp)
    8000249e:	0880                	addi	s0,sp,80
    800024a0:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	752080e7          	jalr	1874(ra) # 80001bf4 <myproc>
    800024aa:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024ac:	00010517          	auipc	a0,0x10
    800024b0:	22450513          	addi	a0,a0,548 # 800126d0 <wait_lock>
    800024b4:	ffffe097          	auipc	ra,0xffffe
    800024b8:	70e080e7          	jalr	1806(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE_P)
    800024bc:	4a8d                	li	s5,3
        havekids = 1;
    800024be:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++)
    800024c0:	6985                	lui	s3,0x1
    800024c2:	8c898993          	addi	s3,s3,-1848 # 8c8 <_entry-0x7ffff738>
    800024c6:	00034a17          	auipc	s4,0x34
    800024ca:	422a0a13          	addi	s4,s4,1058 # 800368e8 <tickslock>
    havekids = 0;
    800024ce:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++)
    800024d0:	00011497          	auipc	s1,0x11
    800024d4:	21848493          	addi	s1,s1,536 # 800136e8 <proc>
    800024d8:	a0b5                	j	80002544 <wait+0xba>
          pid = np->pid;
    800024da:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) 
    800024de:	000b8e63          	beqz	s7,800024fa <wait+0x70>
    800024e2:	4691                	li	a3,4
    800024e4:	02048613          	addi	a2,s1,32
    800024e8:	85de                	mv	a1,s7
    800024ea:	04093503          	ld	a0,64(s2)
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	158080e7          	jalr	344(ra) # 80001646 <copyout>
    800024f6:	02054563          	bltz	a0,80002520 <wait+0x96>
          freeproc(np);
    800024fa:	8526                	mv	a0,s1
    800024fc:	00000097          	auipc	ra,0x0
    80002500:	8b8080e7          	jalr	-1864(ra) # 80001db4 <freeproc>
          release(&np->lock);
    80002504:	8526                	mv	a0,s1
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	770080e7          	jalr	1904(ra) # 80000c76 <release>
          release(&wait_lock);
    8000250e:	00010517          	auipc	a0,0x10
    80002512:	1c250513          	addi	a0,a0,450 # 800126d0 <wait_lock>
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	760080e7          	jalr	1888(ra) # 80000c76 <release>
          return pid;
    8000251e:	a095                	j	80002582 <wait+0xf8>
            release(&np->lock);
    80002520:	8526                	mv	a0,s1
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	754080e7          	jalr	1876(ra) # 80000c76 <release>
            release(&wait_lock);
    8000252a:	00010517          	auipc	a0,0x10
    8000252e:	1a650513          	addi	a0,a0,422 # 800126d0 <wait_lock>
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	744080e7          	jalr	1860(ra) # 80000c76 <release>
            return -1;
    8000253a:	59fd                	li	s3,-1
    8000253c:	a099                	j	80002582 <wait+0xf8>
    for(np = proc; np < &proc[NPROC]; np++)
    8000253e:	94ce                	add	s1,s1,s3
    80002540:	03448463          	beq	s1,s4,80002568 <wait+0xde>
      if(np->parent == p)
    80002544:	789c                	ld	a5,48(s1)
    80002546:	ff279ce3          	bne	a5,s2,8000253e <wait+0xb4>
        acquire(&np->lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	676080e7          	jalr	1654(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE_P)
    80002554:	4c9c                	lw	a5,24(s1)
    80002556:	f95782e3          	beq	a5,s5,800024da <wait+0x50>
        release(&np->lock);
    8000255a:	8526                	mv	a0,s1
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	71a080e7          	jalr	1818(ra) # 80000c76 <release>
        havekids = 1;
    80002564:	875a                	mv	a4,s6
    80002566:	bfe1                	j	8000253e <wait+0xb4>
    if(!havekids || p->killed)
    80002568:	c701                	beqz	a4,80002570 <wait+0xe6>
    8000256a:	01c92783          	lw	a5,28(s2)
    8000256e:	c795                	beqz	a5,8000259a <wait+0x110>
      release(&wait_lock);
    80002570:	00010517          	auipc	a0,0x10
    80002574:	16050513          	addi	a0,a0,352 # 800126d0 <wait_lock>
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	6fe080e7          	jalr	1790(ra) # 80000c76 <release>
      return -1;
    80002580:	59fd                	li	s3,-1
}
    80002582:	854e                	mv	a0,s3
    80002584:	60a6                	ld	ra,72(sp)
    80002586:	6406                	ld	s0,64(sp)
    80002588:	74e2                	ld	s1,56(sp)
    8000258a:	7942                	ld	s2,48(sp)
    8000258c:	79a2                	ld	s3,40(sp)
    8000258e:	7a02                	ld	s4,32(sp)
    80002590:	6ae2                	ld	s5,24(sp)
    80002592:	6b42                	ld	s6,16(sp)
    80002594:	6ba2                	ld	s7,8(sp)
    80002596:	6161                	addi	sp,sp,80
    80002598:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000259a:	00010597          	auipc	a1,0x10
    8000259e:	13658593          	addi	a1,a1,310 # 800126d0 <wait_lock>
    800025a2:	854a                	mv	a0,s2
    800025a4:	00000097          	auipc	ra,0x0
    800025a8:	e82080e7          	jalr	-382(ra) # 80002426 <sleep>
    havekids = 0;
    800025ac:	b70d                	j	800024ce <wait+0x44>

00000000800025ae <wakeup>:
{
    800025ae:	715d                	addi	sp,sp,-80
    800025b0:	e486                	sd	ra,72(sp)
    800025b2:	e0a2                	sd	s0,64(sp)
    800025b4:	fc26                	sd	s1,56(sp)
    800025b6:	f84a                	sd	s2,48(sp)
    800025b8:	f44e                	sd	s3,40(sp)
    800025ba:	f052                	sd	s4,32(sp)
    800025bc:	ec56                	sd	s5,24(sp)
    800025be:	e85a                	sd	s6,16(sp)
    800025c0:	e45e                	sd	s7,8(sp)
    800025c2:	0880                	addi	s0,sp,80
    800025c4:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) 
    800025c6:	00012917          	auipc	s2,0x12
    800025ca:	84290913          	addi	s2,s2,-1982 # 80013e08 <proc+0x720>
    800025ce:	00035b17          	auipc	s6,0x35
    800025d2:	a3ab0b13          	addi	s6,s6,-1478 # 80037008 <bcache+0x708>
        if(t->state == SLEEPING && t->chan == chan) 
    800025d6:	4989                	li	s3,2
          t->state = RUNNABLE;
    800025d8:	4b8d                	li	s7,3
  for(p = proc; p < &proc[NPROC]; p++) 
    800025da:	6a85                	lui	s5,0x1
    800025dc:	8c8a8a93          	addi	s5,s5,-1848 # 8c8 <_entry-0x7ffff738>
    800025e0:	a089                	j	80002622 <wakeup+0x74>
        release(&t->lock);
    800025e2:	8526                	mv	a0,s1
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	692080e7          	jalr	1682(ra) # 80000c76 <release>
    for ( t = p->threads ; t<&p->threads[NTHREAD] ; t++)
    800025ec:	0c848493          	addi	s1,s1,200
    800025f0:	03248663          	beq	s1,s2,8000261c <wakeup+0x6e>
      if(t != mythread())
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	37c080e7          	jalr	892(ra) # 80001970 <mythread>
    800025fc:	fea488e3          	beq	s1,a0,800025ec <wakeup+0x3e>
        acquire(&t->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	5c0080e7          	jalr	1472(ra) # 80000bc2 <acquire>
        if(t->state == SLEEPING && t->chan == chan) 
    8000260a:	4c9c                	lw	a5,24(s1)
    8000260c:	fd379be3          	bne	a5,s3,800025e2 <wakeup+0x34>
    80002610:	709c                	ld	a5,32(s1)
    80002612:	fd4798e3          	bne	a5,s4,800025e2 <wakeup+0x34>
          t->state = RUNNABLE;
    80002616:	0174ac23          	sw	s7,24(s1)
    8000261a:	b7e1                	j	800025e2 <wakeup+0x34>
  for(p = proc; p < &proc[NPROC]; p++) 
    8000261c:	9956                	add	s2,s2,s5
    8000261e:	01690563          	beq	s2,s6,80002628 <wakeup+0x7a>
    for ( t = p->threads ; t<&p->threads[NTHREAD] ; t++)
    80002622:	9c090493          	addi	s1,s2,-1600
    80002626:	b7f9                	j	800025f4 <wakeup+0x46>
}
    80002628:	60a6                	ld	ra,72(sp)
    8000262a:	6406                	ld	s0,64(sp)
    8000262c:	74e2                	ld	s1,56(sp)
    8000262e:	7942                	ld	s2,48(sp)
    80002630:	79a2                	ld	s3,40(sp)
    80002632:	7a02                	ld	s4,32(sp)
    80002634:	6ae2                	ld	s5,24(sp)
    80002636:	6b42                	ld	s6,16(sp)
    80002638:	6ba2                	ld	s7,8(sp)
    8000263a:	6161                	addi	sp,sp,80
    8000263c:	8082                	ret

000000008000263e <reparent>:
{
    8000263e:	7139                	addi	sp,sp,-64
    80002640:	fc06                	sd	ra,56(sp)
    80002642:	f822                	sd	s0,48(sp)
    80002644:	f426                	sd	s1,40(sp)
    80002646:	f04a                	sd	s2,32(sp)
    80002648:	ec4e                	sd	s3,24(sp)
    8000264a:	e852                	sd	s4,16(sp)
    8000264c:	e456                	sd	s5,8(sp)
    8000264e:	0080                	addi	s0,sp,64
    80002650:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002652:	00011497          	auipc	s1,0x11
    80002656:	09648493          	addi	s1,s1,150 # 800136e8 <proc>
      pp->parent = initproc;
    8000265a:	00008a97          	auipc	s5,0x8
    8000265e:	9cea8a93          	addi	s5,s5,-1586 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002662:	6905                	lui	s2,0x1
    80002664:	8c890913          	addi	s2,s2,-1848 # 8c8 <_entry-0x7ffff738>
    80002668:	00034a17          	auipc	s4,0x34
    8000266c:	280a0a13          	addi	s4,s4,640 # 800368e8 <tickslock>
    80002670:	a021                	j	80002678 <reparent+0x3a>
    80002672:	94ca                	add	s1,s1,s2
    80002674:	01448d63          	beq	s1,s4,8000268e <reparent+0x50>
    if(pp->parent == p){
    80002678:	789c                	ld	a5,48(s1)
    8000267a:	ff379ce3          	bne	a5,s3,80002672 <reparent+0x34>
      pp->parent = initproc;
    8000267e:	000ab503          	ld	a0,0(s5)
    80002682:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    80002684:	00000097          	auipc	ra,0x0
    80002688:	f2a080e7          	jalr	-214(ra) # 800025ae <wakeup>
    8000268c:	b7dd                	j	80002672 <reparent+0x34>
}
    8000268e:	70e2                	ld	ra,56(sp)
    80002690:	7442                	ld	s0,48(sp)
    80002692:	74a2                	ld	s1,40(sp)
    80002694:	7902                	ld	s2,32(sp)
    80002696:	69e2                	ld	s3,24(sp)
    80002698:	6a42                	ld	s4,16(sp)
    8000269a:	6aa2                	ld	s5,8(sp)
    8000269c:	6121                	addi	sp,sp,64
    8000269e:	8082                	ret

00000000800026a0 <exit>:
{
    800026a0:	7139                	addi	sp,sp,-64
    800026a2:	fc06                	sd	ra,56(sp)
    800026a4:	f822                	sd	s0,48(sp)
    800026a6:	f426                	sd	s1,40(sp)
    800026a8:	f04a                	sd	s2,32(sp)
    800026aa:	ec4e                	sd	s3,24(sp)
    800026ac:	e852                	sd	s4,16(sp)
    800026ae:	e456                	sd	s5,8(sp)
    800026b0:	e05a                	sd	s6,0(sp)
    800026b2:	0080                	addi	s0,sp,64
    800026b4:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800026b6:	fffff097          	auipc	ra,0xfffff
    800026ba:	53e080e7          	jalr	1342(ra) # 80001bf4 <myproc>
    800026be:	892a                	mv	s2,a0
  if(p == initproc)
    800026c0:	00008797          	auipc	a5,0x8
    800026c4:	9687b783          	ld	a5,-1688(a5) # 8000a028 <initproc>
    800026c8:	04850493          	addi	s1,a0,72
    800026cc:	0c850993          	addi	s3,a0,200
    800026d0:	02a79363          	bne	a5,a0,800026f6 <exit+0x56>
    panic("init exiting");
    800026d4:	00007517          	auipc	a0,0x7
    800026d8:	b9c50513          	addi	a0,a0,-1124 # 80009270 <digits+0x230>
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	e4e080e7          	jalr	-434(ra) # 8000052a <panic>
      fileclose(f);
    800026e4:	00003097          	auipc	ra,0x3
    800026e8:	db0080e7          	jalr	-592(ra) # 80005494 <fileclose>
      p->ofile[fd] = 0;
    800026ec:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800026f0:	04a1                	addi	s1,s1,8
    800026f2:	01348563          	beq	s1,s3,800026fc <exit+0x5c>
    if(p->ofile[fd]){
    800026f6:	6088                	ld	a0,0(s1)
    800026f8:	f575                	bnez	a0,800026e4 <exit+0x44>
    800026fa:	bfdd                	j	800026f0 <exit+0x50>
  begin_op();
    800026fc:	00003097          	auipc	ra,0x3
    80002700:	8cc080e7          	jalr	-1844(ra) # 80004fc8 <begin_op>
  iput(p->cwd);
    80002704:	0c893503          	ld	a0,200(s2)
    80002708:	00002097          	auipc	ra,0x2
    8000270c:	0a6080e7          	jalr	166(ra) # 800047ae <iput>
  end_op();
    80002710:	00003097          	auipc	ra,0x3
    80002714:	938080e7          	jalr	-1736(ra) # 80005048 <end_op>
  p->cwd = 0;
    80002718:	0c093423          	sd	zero,200(s2)
  acquire(&wait_lock);
    8000271c:	00010517          	auipc	a0,0x10
    80002720:	fb450513          	addi	a0,a0,-76 # 800126d0 <wait_lock>
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	49e080e7          	jalr	1182(ra) # 80000bc2 <acquire>
  reparent(p);
    8000272c:	854a                	mv	a0,s2
    8000272e:	00000097          	auipc	ra,0x0
    80002732:	f10080e7          	jalr	-240(ra) # 8000263e <reparent>
  wakeup(p->parent);
    80002736:	03093503          	ld	a0,48(s2)
    8000273a:	00000097          	auipc	ra,0x0
    8000273e:	e74080e7          	jalr	-396(ra) # 800025ae <wakeup>
  acquire(&p->lock);
    80002742:	854a                	mv	a0,s2
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	47e080e7          	jalr	1150(ra) # 80000bc2 <acquire>
  p->xstate = status;
    8000274c:	03592023          	sw	s5,32(s2)
  p->state = ZOMBIE_P;
    80002750:	478d                	li	a5,3
    80002752:	00f92c23          	sw	a5,24(s2)
  release(&p->lock);
    80002756:	854a                	mv	a0,s2
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	51e080e7          	jalr	1310(ra) # 80000c76 <release>
  for(struct thread* t = p->threads; t < &p->threads[NTHREAD]; t++)
    80002760:	0e090493          	addi	s1,s2,224
    80002764:	72090913          	addi	s2,s2,1824
    t->killed = 1;
    80002768:	4a05                	li	s4,1
    if(t->state == SLEEPING)
    8000276a:	4989                	li	s3,2
      t->state = RUNNABLE;
    8000276c:	4b0d                	li	s6,3
    8000276e:	a811                	j	80002782 <exit+0xe2>
    release(&t->lock);
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	504080e7          	jalr	1284(ra) # 80000c76 <release>
  for(struct thread* t = p->threads; t < &p->threads[NTHREAD]; t++)
    8000277a:	0c848493          	addi	s1,s1,200
    8000277e:	00990f63          	beq	s2,s1,8000279c <exit+0xfc>
    acquire(&t->lock);
    80002782:	8526                	mv	a0,s1
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	43e080e7          	jalr	1086(ra) # 80000bc2 <acquire>
    t->killed = 1;
    8000278c:	0344a423          	sw	s4,40(s1)
    if(t->state == SLEEPING)
    80002790:	4c9c                	lw	a5,24(s1)
    80002792:	fd379fe3          	bne	a5,s3,80002770 <exit+0xd0>
      t->state = RUNNABLE;
    80002796:	0164ac23          	sw	s6,24(s1)
    8000279a:	bfd9                	j	80002770 <exit+0xd0>
  exit_thread(status);
    8000279c:	8556                	mv	a0,s5
    8000279e:	00000097          	auipc	ra,0x0
    800027a2:	bd6080e7          	jalr	-1066(ra) # 80002374 <exit_thread>

00000000800027a6 <kill>:
{
    800027a6:	7139                	addi	sp,sp,-64
    800027a8:	fc06                	sd	ra,56(sp)
    800027aa:	f822                	sd	s0,48(sp)
    800027ac:	f426                	sd	s1,40(sp)
    800027ae:	f04a                	sd	s2,32(sp)
    800027b0:	ec4e                	sd	s3,24(sp)
    800027b2:	e852                	sd	s4,16(sp)
    800027b4:	e456                	sd	s5,8(sp)
    800027b6:	0080                	addi	s0,sp,64
    800027b8:	892a                	mv	s2,a0
    800027ba:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    800027bc:	00011497          	auipc	s1,0x11
    800027c0:	f2c48493          	addi	s1,s1,-212 # 800136e8 <proc>
    800027c4:	6985                	lui	s3,0x1
    800027c6:	8c898993          	addi	s3,s3,-1848 # 8c8 <_entry-0x7ffff738>
    800027ca:	00034a17          	auipc	s4,0x34
    800027ce:	11ea0a13          	addi	s4,s4,286 # 800368e8 <tickslock>
    acquire(&p->lock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	3ee080e7          	jalr	1006(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    800027dc:	50dc                	lw	a5,36(s1)
    800027de:	01278c63          	beq	a5,s2,800027f6 <kill+0x50>
    release(&p->lock);
    800027e2:	8526                	mv	a0,s1
    800027e4:	ffffe097          	auipc	ra,0xffffe
    800027e8:	492080e7          	jalr	1170(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ec:	94ce                	add	s1,s1,s3
    800027ee:	ff4492e3          	bne	s1,s4,800027d2 <kill+0x2c>
  return -1;
    800027f2:	557d                	li	a0,-1
    800027f4:	a005                	j	80002814 <kill+0x6e>
      uint new_mask = (1<<signum);
    800027f6:	4585                	li	a1,1
    800027f8:	01559abb          	sllw	s5,a1,s5
      p->pending_signals = p->pending_signals | new_mask ; 
    800027fc:	7204a583          	lw	a1,1824(s1)
    80002800:	0155e5b3          	or	a1,a1,s5
    80002804:	72b4a023          	sw	a1,1824(s1)
      release(&p->lock);
    80002808:	8526                	mv	a0,s1
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	46c080e7          	jalr	1132(ra) # 80000c76 <release>
      return 0;
    80002812:	4501                	li	a0,0
}
    80002814:	70e2                	ld	ra,56(sp)
    80002816:	7442                	ld	s0,48(sp)
    80002818:	74a2                	ld	s1,40(sp)
    8000281a:	7902                	ld	s2,32(sp)
    8000281c:	69e2                	ld	s3,24(sp)
    8000281e:	6a42                	ld	s4,16(sp)
    80002820:	6aa2                	ld	s5,8(sp)
    80002822:	6121                	addi	sp,sp,64
    80002824:	8082                	ret

0000000080002826 <either_copyout>:
{
    80002826:	7179                	addi	sp,sp,-48
    80002828:	f406                	sd	ra,40(sp)
    8000282a:	f022                	sd	s0,32(sp)
    8000282c:	ec26                	sd	s1,24(sp)
    8000282e:	e84a                	sd	s2,16(sp)
    80002830:	e44e                	sd	s3,8(sp)
    80002832:	e052                	sd	s4,0(sp)
    80002834:	1800                	addi	s0,sp,48
    80002836:	84aa                	mv	s1,a0
    80002838:	892e                	mv	s2,a1
    8000283a:	89b2                	mv	s3,a2
    8000283c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000283e:	fffff097          	auipc	ra,0xfffff
    80002842:	3b6080e7          	jalr	950(ra) # 80001bf4 <myproc>
  if(user_dst){
    80002846:	c08d                	beqz	s1,80002868 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002848:	86d2                	mv	a3,s4
    8000284a:	864e                	mv	a2,s3
    8000284c:	85ca                	mv	a1,s2
    8000284e:	6128                	ld	a0,64(a0)
    80002850:	fffff097          	auipc	ra,0xfffff
    80002854:	df6080e7          	jalr	-522(ra) # 80001646 <copyout>
}
    80002858:	70a2                	ld	ra,40(sp)
    8000285a:	7402                	ld	s0,32(sp)
    8000285c:	64e2                	ld	s1,24(sp)
    8000285e:	6942                	ld	s2,16(sp)
    80002860:	69a2                	ld	s3,8(sp)
    80002862:	6a02                	ld	s4,0(sp)
    80002864:	6145                	addi	sp,sp,48
    80002866:	8082                	ret
    memmove((char *)dst, src, len);
    80002868:	000a061b          	sext.w	a2,s4
    8000286c:	85ce                	mv	a1,s3
    8000286e:	854a                	mv	a0,s2
    80002870:	ffffe097          	auipc	ra,0xffffe
    80002874:	4aa080e7          	jalr	1194(ra) # 80000d1a <memmove>
    return 0;
    80002878:	8526                	mv	a0,s1
    8000287a:	bff9                	j	80002858 <either_copyout+0x32>

000000008000287c <either_copyin>:
{
    8000287c:	7179                	addi	sp,sp,-48
    8000287e:	f406                	sd	ra,40(sp)
    80002880:	f022                	sd	s0,32(sp)
    80002882:	ec26                	sd	s1,24(sp)
    80002884:	e84a                	sd	s2,16(sp)
    80002886:	e44e                	sd	s3,8(sp)
    80002888:	e052                	sd	s4,0(sp)
    8000288a:	1800                	addi	s0,sp,48
    8000288c:	892a                	mv	s2,a0
    8000288e:	84ae                	mv	s1,a1
    80002890:	89b2                	mv	s3,a2
    80002892:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002894:	fffff097          	auipc	ra,0xfffff
    80002898:	360080e7          	jalr	864(ra) # 80001bf4 <myproc>
  if(user_src){
    8000289c:	c08d                	beqz	s1,800028be <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000289e:	86d2                	mv	a3,s4
    800028a0:	864e                	mv	a2,s3
    800028a2:	85ca                	mv	a1,s2
    800028a4:	6128                	ld	a0,64(a0)
    800028a6:	fffff097          	auipc	ra,0xfffff
    800028aa:	e2c080e7          	jalr	-468(ra) # 800016d2 <copyin>
}
    800028ae:	70a2                	ld	ra,40(sp)
    800028b0:	7402                	ld	s0,32(sp)
    800028b2:	64e2                	ld	s1,24(sp)
    800028b4:	6942                	ld	s2,16(sp)
    800028b6:	69a2                	ld	s3,8(sp)
    800028b8:	6a02                	ld	s4,0(sp)
    800028ba:	6145                	addi	sp,sp,48
    800028bc:	8082                	ret
    memmove(dst, (char*)src, len);
    800028be:	000a061b          	sext.w	a2,s4
    800028c2:	85ce                	mv	a1,s3
    800028c4:	854a                	mv	a0,s2
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	454080e7          	jalr	1108(ra) # 80000d1a <memmove>
    return 0;
    800028ce:	8526                	mv	a0,s1
    800028d0:	bff9                	j	800028ae <either_copyin+0x32>

00000000800028d2 <procdump>:
{
    800028d2:	715d                	addi	sp,sp,-80
    800028d4:	e486                	sd	ra,72(sp)
    800028d6:	e0a2                	sd	s0,64(sp)
    800028d8:	fc26                	sd	s1,56(sp)
    800028da:	f84a                	sd	s2,48(sp)
    800028dc:	f44e                	sd	s3,40(sp)
    800028de:	f052                	sd	s4,32(sp)
    800028e0:	ec56                	sd	s5,24(sp)
    800028e2:	e85a                	sd	s6,16(sp)
    800028e4:	e45e                	sd	s7,8(sp)
    800028e6:	e062                	sd	s8,0(sp)
    800028e8:	0880                	addi	s0,sp,80
  printf("\n");
    800028ea:	00006517          	auipc	a0,0x6
    800028ee:	7de50513          	addi	a0,a0,2014 # 800090c8 <digits+0x88>
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	c82080e7          	jalr	-894(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028fa:	00011497          	auipc	s1,0x11
    800028fe:	ebe48493          	addi	s1,s1,-322 # 800137b8 <proc+0xd0>
    80002902:	00034997          	auipc	s3,0x34
    80002906:	0b698993          	addi	s3,s3,182 # 800369b8 <bcache+0xb8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000290a:	4b95                	li	s7,5
      state = "???";
    8000290c:	00007a17          	auipc	s4,0x7
    80002910:	974a0a13          	addi	s4,s4,-1676 # 80009280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002914:	00007b17          	auipc	s6,0x7
    80002918:	974b0b13          	addi	s6,s6,-1676 # 80009288 <digits+0x248>
    printf("\n");
    8000291c:	00006a97          	auipc	s5,0x6
    80002920:	7aca8a93          	addi	s5,s5,1964 # 800090c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002924:	00007c17          	auipc	s8,0x7
    80002928:	b1cc0c13          	addi	s8,s8,-1252 # 80009440 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    8000292c:	6905                	lui	s2,0x1
    8000292e:	8c890913          	addi	s2,s2,-1848 # 8c8 <_entry-0x7ffff738>
    80002932:	a005                	j	80002952 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002934:	f546a583          	lw	a1,-172(a3)
    80002938:	855a                	mv	a0,s6
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	c3a080e7          	jalr	-966(ra) # 80000574 <printf>
    printf("\n");
    80002942:	8556                	mv	a0,s5
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	c30080e7          	jalr	-976(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000294c:	94ca                	add	s1,s1,s2
    8000294e:	03348263          	beq	s1,s3,80002972 <procdump+0xa0>
    if(p->state == UNUSED_P)
    80002952:	86a6                	mv	a3,s1
    80002954:	f484a783          	lw	a5,-184(s1)
    80002958:	dbf5                	beqz	a5,8000294c <procdump+0x7a>
      state = "???";
    8000295a:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000295c:	fcfbece3          	bltu	s7,a5,80002934 <procdump+0x62>
    80002960:	02079713          	slli	a4,a5,0x20
    80002964:	01d75793          	srli	a5,a4,0x1d
    80002968:	97e2                	add	a5,a5,s8
    8000296a:	6390                	ld	a2,0(a5)
    8000296c:	f661                	bnez	a2,80002934 <procdump+0x62>
      state = "???";
    8000296e:	8652                	mv	a2,s4
    80002970:	b7d1                	j	80002934 <procdump+0x62>
}
    80002972:	60a6                	ld	ra,72(sp)
    80002974:	6406                	ld	s0,64(sp)
    80002976:	74e2                	ld	s1,56(sp)
    80002978:	7942                	ld	s2,48(sp)
    8000297a:	79a2                	ld	s3,40(sp)
    8000297c:	7a02                	ld	s4,32(sp)
    8000297e:	6ae2                	ld	s5,24(sp)
    80002980:	6b42                	ld	s6,16(sp)
    80002982:	6ba2                	ld	s7,8(sp)
    80002984:	6c02                	ld	s8,0(sp)
    80002986:	6161                	addi	sp,sp,80
    80002988:	8082                	ret

000000008000298a <sigprocmask>:
{
    8000298a:	1101                	addi	sp,sp,-32
    8000298c:	ec06                	sd	ra,24(sp)
    8000298e:	e822                	sd	s0,16(sp)
    80002990:	e426                	sd	s1,8(sp)
    80002992:	1000                	addi	s0,sp,32
    80002994:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002996:	fffff097          	auipc	ra,0xfffff
    8000299a:	25e080e7          	jalr	606(ra) # 80001bf4 <myproc>
    8000299e:	87aa                	mv	a5,a0
  uint temp = p->proc_signal_mask;
    800029a0:	72452503          	lw	a0,1828(a0)
  p->proc_signal_mask = sigmask;
    800029a4:	7297a223          	sw	s1,1828(a5)
}
    800029a8:	60e2                	ld	ra,24(sp)
    800029aa:	6442                	ld	s0,16(sp)
    800029ac:	64a2                	ld	s1,8(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret

00000000800029b2 <sigaction>:
{
    800029b2:	715d                	addi	sp,sp,-80
    800029b4:	e486                	sd	ra,72(sp)
    800029b6:	e0a2                	sd	s0,64(sp)
    800029b8:	fc26                	sd	s1,56(sp)
    800029ba:	f84a                	sd	s2,48(sp)
    800029bc:	f44e                	sd	s3,40(sp)
    800029be:	f052                	sd	s4,32(sp)
    800029c0:	0880                	addi	s0,sp,80
    800029c2:	84aa                	mv	s1,a0
    800029c4:	89ae                	mv	s3,a1
    800029c6:	8a32                	mv	s4,a2
  struct proc *p = myproc();
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	22c080e7          	jalr	556(ra) # 80001bf4 <myproc>
  if((signum < 0 ) || (signum >= NUM_OF_SIGNALS) || (signum == SIGKILL) || (signum == SIGSTOP))
    800029d0:	0004879b          	sext.w	a5,s1
    800029d4:	477d                	li	a4,31
    800029d6:	08f76c63          	bltu	a4,a5,80002a6e <sigaction+0xbc>
    800029da:	892a                	mv	s2,a0
    800029dc:	37dd                	addiw	a5,a5,-9
    800029de:	9bdd                	andi	a5,a5,-9
    800029e0:	2781                	sext.w	a5,a5
    800029e2:	cbc1                	beqz	a5,80002a72 <sigaction+0xc0>
  if(old_act != 0)
    800029e4:	000a1d63          	bnez	s4,800029fe <sigaction+0x4c>
  return 0;
    800029e8:	4501                	li	a0,0
  if(act != 0)
    800029ea:	04099263          	bnez	s3,80002a2e <sigaction+0x7c>
}
    800029ee:	60a6                	ld	ra,72(sp)
    800029f0:	6406                	ld	s0,64(sp)
    800029f2:	74e2                	ld	s1,56(sp)
    800029f4:	7942                	ld	s2,48(sp)
    800029f6:	79a2                	ld	s3,40(sp)
    800029f8:	7a02                	ld	s4,32(sp)
    800029fa:	6161                	addi	sp,sp,80
    800029fc:	8082                	ret
    kold_act.sa_handler = p->signal_handlers[signum];
    800029fe:	0e448793          	addi	a5,s1,228
    80002a02:	078e                	slli	a5,a5,0x3
    80002a04:	97aa                	add	a5,a5,a0
    80002a06:	679c                	ld	a5,8(a5)
    80002a08:	fcf43023          	sd	a5,-64(s0)
    kold_act.sigmask = p->signal_masks[signum];
    80002a0c:	20848793          	addi	a5,s1,520
    80002a10:	078a                	slli	a5,a5,0x2
    80002a12:	97aa                	add	a5,a5,a0
    80002a14:	479c                	lw	a5,8(a5)
    80002a16:	fcf42423          	sw	a5,-56(s0)
    copyout(p->pagetable, old_act, (char*) &kold_act, sizeof(struct sigaction));
    80002a1a:	46c1                	li	a3,16
    80002a1c:	fc040613          	addi	a2,s0,-64
    80002a20:	85d2                	mv	a1,s4
    80002a22:	6128                	ld	a0,64(a0)
    80002a24:	fffff097          	auipc	ra,0xfffff
    80002a28:	c22080e7          	jalr	-990(ra) # 80001646 <copyout>
    80002a2c:	bf75                	j	800029e8 <sigaction+0x36>
    copyin(p->pagetable, (char*) &kact, act, sizeof(struct sigaction));
    80002a2e:	46c1                	li	a3,16
    80002a30:	864e                	mv	a2,s3
    80002a32:	fb040593          	addi	a1,s0,-80
    80002a36:	04093503          	ld	a0,64(s2)
    80002a3a:	fffff097          	auipc	ra,0xfffff
    80002a3e:	c98080e7          	jalr	-872(ra) # 800016d2 <copyin>
    if ((kact.sigmask & invalid_mask) != 0)
    80002a42:	fb842703          	lw	a4,-72(s0)
    80002a46:	000207b7          	lui	a5,0x20
    80002a4a:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002a4e:	8ff9                	and	a5,a5,a4
    80002a50:	e39d                	bnez	a5,80002a76 <sigaction+0xc4>
    p->signal_handlers[signum] = kact.sa_handler;
    80002a52:	0e448793          	addi	a5,s1,228
    80002a56:	078e                	slli	a5,a5,0x3
    80002a58:	97ca                	add	a5,a5,s2
    80002a5a:	fb043683          	ld	a3,-80(s0)
    80002a5e:	e794                	sd	a3,8(a5)
    p->signal_masks[signum] = kact.sigmask;
    80002a60:	20848493          	addi	s1,s1,520
    80002a64:	048a                	slli	s1,s1,0x2
    80002a66:	94ca                	add	s1,s1,s2
    80002a68:	c498                	sw	a4,8(s1)
  return 0;
    80002a6a:	4501                	li	a0,0
    80002a6c:	b749                	j	800029ee <sigaction+0x3c>
    return -1;
    80002a6e:	557d                	li	a0,-1
    80002a70:	bfbd                	j	800029ee <sigaction+0x3c>
    80002a72:	557d                	li	a0,-1
    80002a74:	bfad                	j	800029ee <sigaction+0x3c>
      return -1;
    80002a76:	557d                	li	a0,-1
    80002a78:	bf9d                	j	800029ee <sigaction+0x3c>

0000000080002a7a <sigret>:
{
    80002a7a:	1101                	addi	sp,sp,-32
    80002a7c:	ec06                	sd	ra,24(sp)
    80002a7e:	e822                	sd	s0,16(sp)
    80002a80:	e426                	sd	s1,8(sp)
    80002a82:	e04a                	sd	s2,0(sp)
    80002a84:	1000                	addi	s0,sp,32
  struct thread* t = mythread();
    80002a86:	fffff097          	auipc	ra,0xfffff
    80002a8a:	eea080e7          	jalr	-278(ra) # 80001970 <mythread>
    80002a8e:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80002a90:	fffff097          	auipc	ra,0xfffff
    80002a94:	164080e7          	jalr	356(ra) # 80001bf4 <myproc>
    80002a98:	84aa                	mv	s1,a0
  copy_tf(t->trapframe, t->tf_backup);
    80002a9a:	05093583          	ld	a1,80(s2)
    80002a9e:	04893503          	ld	a0,72(s2)
    80002aa2:	00000097          	auipc	ra,0x0
    80002aa6:	7f4080e7          	jalr	2036(ra) # 80003296 <copy_tf>
  p->proc_signal_mask = p->signal_mask_backup;
    80002aaa:	6785                	lui	a5,0x1
    80002aac:	97a6                	add	a5,a5,s1
    80002aae:	8ac7a703          	lw	a4,-1876(a5) # 8ac <_entry-0x7ffff754>
    80002ab2:	72e4a223          	sw	a4,1828(s1)
  p->signal_handling = 0; 
    80002ab6:	8a07a823          	sw	zero,-1872(a5)
}
    80002aba:	60e2                	ld	ra,24(sp)
    80002abc:	6442                	ld	s0,16(sp)
    80002abe:	64a2                	ld	s1,8(sp)
    80002ac0:	6902                	ld	s2,0(sp)
    80002ac2:	6105                	addi	sp,sp,32
    80002ac4:	8082                	ret

0000000080002ac6 <kthread_create>:
{
    80002ac6:	7179                	addi	sp,sp,-48
    80002ac8:	f406                	sd	ra,40(sp)
    80002aca:	f022                	sd	s0,32(sp)
    80002acc:	ec26                	sd	s1,24(sp)
    80002ace:	e84a                	sd	s2,16(sp)
    80002ad0:	e44e                	sd	s3,8(sp)
    80002ad2:	e052                	sd	s4,0(sp)
    80002ad4:	1800                	addi	s0,sp,48
    80002ad6:	8a2a                	mv	s4,a0
    80002ad8:	89ae                	mv	s3,a1
  printf("kthread_create\n");
    80002ada:	00006517          	auipc	a0,0x6
    80002ade:	7be50513          	addi	a0,a0,1982 # 80009298 <digits+0x258>
    80002ae2:	ffffe097          	auipc	ra,0xffffe
    80002ae6:	a92080e7          	jalr	-1390(ra) # 80000574 <printf>
  struct proc *p = myproc();
    80002aea:	fffff097          	auipc	ra,0xfffff
    80002aee:	10a080e7          	jalr	266(ra) # 80001bf4 <myproc>
    80002af2:	892a                	mv	s2,a0
  struct thread *nt = allocthread(p);
    80002af4:	fffff097          	auipc	ra,0xfffff
    80002af8:	da0080e7          	jalr	-608(ra) # 80001894 <allocthread>
    80002afc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002afe:	854a                	mv	a0,s2
    80002b00:	ffffe097          	auipc	ra,0xffffe
    80002b04:	0c2080e7          	jalr	194(ra) # 80000bc2 <acquire>
  p->alive_threads++;
    80002b08:	02892783          	lw	a5,40(s2)
    80002b0c:	2785                	addiw	a5,a5,1
    80002b0e:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    80002b12:	854a                	mv	a0,s2
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	162080e7          	jalr	354(ra) # 80000c76 <release>
  struct thread *t = mythread();
    80002b1c:	fffff097          	auipc	ra,0xfffff
    80002b20:	e54080e7          	jalr	-428(ra) # 80001970 <mythread>
  if(nt == 0)
    80002b24:	c0b1                	beqz	s1,80002b68 <kthread_create+0xa2>
  copy_tf(nt->trapframe, t->trapframe);
    80002b26:	652c                	ld	a1,72(a0)
    80002b28:	64a8                	ld	a0,72(s1)
    80002b2a:	00000097          	auipc	ra,0x0
    80002b2e:	76c080e7          	jalr	1900(ra) # 80003296 <copy_tf>
  nt->trapframe->epc = func_addr;
    80002b32:	64bc                	ld	a5,72(s1)
    80002b34:	0147bc23          	sd	s4,24(a5)
  nt->trapframe->sp = stack;
    80002b38:	64bc                	ld	a5,72(s1)
    80002b3a:	0337b823          	sd	s3,48(a5)
  nt->state = RUNNABLE;
    80002b3e:	478d                	li	a5,3
    80002b40:	cc9c                	sw	a5,24(s1)
  nt->context.ra = (uint64) kthread_create_ret;
    80002b42:	fffff797          	auipc	a5,0xfffff
    80002b46:	e6678793          	addi	a5,a5,-410 # 800019a8 <kthread_create_ret>
    80002b4a:	ecbc                	sd	a5,88(s1)
  release(&nt->lock);
    80002b4c:	8526                	mv	a0,s1
    80002b4e:	ffffe097          	auipc	ra,0xffffe
    80002b52:	128080e7          	jalr	296(ra) # 80000c76 <release>
  return nt->tid;
    80002b56:	5888                	lw	a0,48(s1)
}
    80002b58:	70a2                	ld	ra,40(sp)
    80002b5a:	7402                	ld	s0,32(sp)
    80002b5c:	64e2                	ld	s1,24(sp)
    80002b5e:	6942                	ld	s2,16(sp)
    80002b60:	69a2                	ld	s3,8(sp)
    80002b62:	6a02                	ld	s4,0(sp)
    80002b64:	6145                	addi	sp,sp,48
    80002b66:	8082                	ret
    return -1;
    80002b68:	557d                	li	a0,-1
    80002b6a:	b7fd                	j	80002b58 <kthread_create+0x92>

0000000080002b6c <kthread_id>:
{
    80002b6c:	1141                	addi	sp,sp,-16
    80002b6e:	e406                	sd	ra,8(sp)
    80002b70:	e022                	sd	s0,0(sp)
    80002b72:	0800                	addi	s0,sp,16
  return mythread()->tid;
    80002b74:	fffff097          	auipc	ra,0xfffff
    80002b78:	dfc080e7          	jalr	-516(ra) # 80001970 <mythread>
}
    80002b7c:	5908                	lw	a0,48(a0)
    80002b7e:	60a2                	ld	ra,8(sp)
    80002b80:	6402                	ld	s0,0(sp)
    80002b82:	0141                	addi	sp,sp,16
    80002b84:	8082                	ret

0000000080002b86 <kthread_exit>:
{
    80002b86:	1141                	addi	sp,sp,-16
    80002b88:	e406                	sd	ra,8(sp)
    80002b8a:	e022                	sd	s0,0(sp)
    80002b8c:	0800                	addi	s0,sp,16
  printf("kthread_exit\n");
    80002b8e:	00006517          	auipc	a0,0x6
    80002b92:	71a50513          	addi	a0,a0,1818 # 800092a8 <digits+0x268>
    80002b96:	ffffe097          	auipc	ra,0xffffe
    80002b9a:	9de080e7          	jalr	-1570(ra) # 80000574 <printf>
}
    80002b9e:	4501                	li	a0,0
    80002ba0:	60a2                	ld	ra,8(sp)
    80002ba2:	6402                	ld	s0,0(sp)
    80002ba4:	0141                	addi	sp,sp,16
    80002ba6:	8082                	ret

0000000080002ba8 <kthread_join>:
{
    80002ba8:	1141                	addi	sp,sp,-16
    80002baa:	e406                	sd	ra,8(sp)
    80002bac:	e022                	sd	s0,0(sp)
    80002bae:	0800                	addi	s0,sp,16
  printf("kthread_join\n");
    80002bb0:	00006517          	auipc	a0,0x6
    80002bb4:	70850513          	addi	a0,a0,1800 # 800092b8 <digits+0x278>
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	9bc080e7          	jalr	-1604(ra) # 80000574 <printf>
}
    80002bc0:	4501                	li	a0,0
    80002bc2:	60a2                	ld	ra,8(sp)
    80002bc4:	6402                	ld	s0,0(sp)
    80002bc6:	0141                	addi	sp,sp,16
    80002bc8:	8082                	ret

0000000080002bca <semaphoresinit>:

void  semaphoresinit(void)
{
    80002bca:	1141                	addi	sp,sp,-16
    80002bcc:	e422                	sd	s0,8(sp)
    80002bce:	0800                	addi	s0,sp,16
  for(int i = 0; i < MAX_BSEM; i++)
    80002bd0:	00010797          	auipc	a5,0x10
    80002bd4:	b1878793          	addi	a5,a5,-1256 # 800126e8 <semaphores>
    80002bd8:	00011717          	auipc	a4,0x11
    80002bdc:	b1070713          	addi	a4,a4,-1264 # 800136e8 <proc>
  {
    semaphores[i].state = UNUSED_SEM;
    80002be0:	0007a023          	sw	zero,0(a5)
    semaphores[i].taken = 0;
    80002be4:	0007a823          	sw	zero,16(a5)
  for(int i = 0; i < MAX_BSEM; i++)
    80002be8:	02078793          	addi	a5,a5,32
    80002bec:	fee79ae3          	bne	a5,a4,80002be0 <semaphoresinit+0x16>
  }
}
    80002bf0:	6422                	ld	s0,8(sp)
    80002bf2:	0141                	addi	sp,sp,16
    80002bf4:	8082                	ret

0000000080002bf6 <bsem_alloc>:

int 
bsem_alloc(void)
{
    80002bf6:	1141                	addi	sp,sp,-16
    80002bf8:	e406                	sd	ra,8(sp)
    80002bfa:	e022                	sd	s0,0(sp)
    80002bfc:	0800                	addi	s0,sp,16
  printf("bsem_alloc\n");
    80002bfe:	00006517          	auipc	a0,0x6
    80002c02:	6ca50513          	addi	a0,a0,1738 # 800092c8 <digits+0x288>
    80002c06:	ffffe097          	auipc	ra,0xffffe
    80002c0a:	96e080e7          	jalr	-1682(ra) # 80000574 <printf>

  for(int i = 0; i < MAX_BSEM; i++)
    80002c0e:	00010797          	auipc	a5,0x10
    80002c12:	ada78793          	addi	a5,a5,-1318 # 800126e8 <semaphores>
    80002c16:	4501                	li	a0,0
    80002c18:	08000693          	li	a3,128
  {
    if(semaphores[i].state == UNUSED_SEM)
    80002c1c:	4398                	lw	a4,0(a5)
    80002c1e:	cb01                	beqz	a4,80002c2e <bsem_alloc+0x38>
  for(int i = 0; i < MAX_BSEM; i++)
    80002c20:	2505                	addiw	a0,a0,1
    80002c22:	02078793          	addi	a5,a5,32
    80002c26:	fed51be3          	bne	a0,a3,80002c1c <bsem_alloc+0x26>
      semaphores[i].state = USED_SEM;
      semaphores[i].taken = 0;
      return i;
    }
  }
  return -1;
    80002c2a:	557d                	li	a0,-1
    80002c2c:	a821                	j	80002c44 <bsem_alloc+0x4e>
      semaphores[i].state = USED_SEM;
    80002c2e:	00551713          	slli	a4,a0,0x5
    80002c32:	00010797          	auipc	a5,0x10
    80002c36:	ab678793          	addi	a5,a5,-1354 # 800126e8 <semaphores>
    80002c3a:	97ba                	add	a5,a5,a4
    80002c3c:	4705                	li	a4,1
    80002c3e:	c398                	sw	a4,0(a5)
      semaphores[i].taken = 0;
    80002c40:	0007a823          	sw	zero,16(a5)
}
    80002c44:	60a2                	ld	ra,8(sp)
    80002c46:	6402                	ld	s0,0(sp)
    80002c48:	0141                	addi	sp,sp,16
    80002c4a:	8082                	ret

0000000080002c4c <bsem_free>:

void
bsem_free(int fd)
{
    80002c4c:	1101                	addi	sp,sp,-32
    80002c4e:	ec06                	sd	ra,24(sp)
    80002c50:	e822                	sd	s0,16(sp)
    80002c52:	e426                	sd	s1,8(sp)
    80002c54:	1000                	addi	s0,sp,32
    80002c56:	84aa                	mv	s1,a0
  printf("bsem_free\n");
    80002c58:	00006517          	auipc	a0,0x6
    80002c5c:	68050513          	addi	a0,a0,1664 # 800092d8 <digits+0x298>
    80002c60:	ffffe097          	auipc	ra,0xffffe
    80002c64:	914080e7          	jalr	-1772(ra) # 80000574 <printf>

  semaphores[fd].state = UNUSED_SEM;
    80002c68:	0496                	slli	s1,s1,0x5
    80002c6a:	00010517          	auipc	a0,0x10
    80002c6e:	a7e50513          	addi	a0,a0,-1410 # 800126e8 <semaphores>
    80002c72:	94aa                	add	s1,s1,a0
    80002c74:	0004a023          	sw	zero,0(s1)
  semaphores[fd].taken = 0;
    80002c78:	0004a823          	sw	zero,16(s1)
}
    80002c7c:	60e2                	ld	ra,24(sp)
    80002c7e:	6442                	ld	s0,16(sp)
    80002c80:	64a2                	ld	s1,8(sp)
    80002c82:	6105                	addi	sp,sp,32
    80002c84:	8082                	ret

0000000080002c86 <bsem_down>:

void
bsem_down(int fd)
{
    80002c86:	7179                	addi	sp,sp,-48
    80002c88:	f406                	sd	ra,40(sp)
    80002c8a:	f022                	sd	s0,32(sp)
    80002c8c:	ec26                	sd	s1,24(sp)
    80002c8e:	e84a                	sd	s2,16(sp)
    80002c90:	e44e                	sd	s3,8(sp)
    80002c92:	1800                	addi	s0,sp,48
  
  struct semaphore sem = semaphores[fd];
    80002c94:	00551793          	slli	a5,a0,0x5
    80002c98:	00010517          	auipc	a0,0x10
    80002c9c:	a5050513          	addi	a0,a0,-1456 # 800126e8 <semaphores>
    80002ca0:	953e                	add	a0,a0,a5
    80002ca2:	6504                	ld	s1,8(a0)
    80002ca4:	01052983          	lw	s3,16(a0)
    80002ca8:	01853903          	ld	s2,24(a0)
  // push_off();
  printf("bsem_down\n");
    80002cac:	00006517          	auipc	a0,0x6
    80002cb0:	63c50513          	addi	a0,a0,1596 # 800092e8 <digits+0x2a8>
    80002cb4:	ffffe097          	auipc	ra,0xffffe
    80002cb8:	8c0080e7          	jalr	-1856(ra) # 80000574 <printf>

  while(sem.taken)
    80002cbc:	02098263          	beqz	s3,80002ce0 <bsem_down+0x5a>
  {
    printf("going to sleep\n");
    80002cc0:	00006997          	auipc	s3,0x6
    80002cc4:	63898993          	addi	s3,s3,1592 # 800092f8 <digits+0x2b8>
    80002cc8:	854e                	mv	a0,s3
    80002cca:	ffffe097          	auipc	ra,0xffffe
    80002cce:	8aa080e7          	jalr	-1878(ra) # 80000574 <printf>
    sleep(sem.chan, sem.lk);
    80002cd2:	85ca                	mv	a1,s2
    80002cd4:	8526                	mv	a0,s1
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	750080e7          	jalr	1872(ra) # 80002426 <sleep>
  while(sem.taken)
    80002cde:	b7ed                	j	80002cc8 <bsem_down+0x42>
  }
  sem.taken = 1;
  // pop_off();
}
    80002ce0:	70a2                	ld	ra,40(sp)
    80002ce2:	7402                	ld	s0,32(sp)
    80002ce4:	64e2                	ld	s1,24(sp)
    80002ce6:	6942                	ld	s2,16(sp)
    80002ce8:	69a2                	ld	s3,8(sp)
    80002cea:	6145                	addi	sp,sp,48
    80002cec:	8082                	ret

0000000080002cee <bsem_up>:

void
bsem_up(int fd)
{
    80002cee:	1141                	addi	sp,sp,-16
    80002cf0:	e422                	sd	s0,8(sp)
    80002cf2:	0800                	addi	s0,sp,16
  //printf("bsem_up\n");
  semaphores[fd].taken = 0;
    80002cf4:	00551793          	slli	a5,a0,0x5
    80002cf8:	00010517          	auipc	a0,0x10
    80002cfc:	9f050513          	addi	a0,a0,-1552 # 800126e8 <semaphores>
    80002d00:	953e                	add	a0,a0,a5
    80002d02:	00052823          	sw	zero,16(a0)
}
    80002d06:	6422                	ld	s0,8(sp)
    80002d08:	0141                	addi	sp,sp,16
    80002d0a:	8082                	ret

0000000080002d0c <csem_alloc>:

int 
csem_alloc(uint64 sem)
{
    80002d0c:	1141                	addi	sp,sp,-16
    80002d0e:	e406                	sd	ra,8(sp)
    80002d10:	e022                	sd	s0,0(sp)
    80002d12:	0800                	addi	s0,sp,16
  printf("csem_alloc()\n");
    80002d14:	00006517          	auipc	a0,0x6
    80002d18:	5f450513          	addi	a0,a0,1524 # 80009308 <digits+0x2c8>
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	858080e7          	jalr	-1960(ra) # 80000574 <printf>
  return 0;
}
    80002d24:	4501                	li	a0,0
    80002d26:	60a2                	ld	ra,8(sp)
    80002d28:	6402                	ld	s0,0(sp)
    80002d2a:	0141                	addi	sp,sp,16
    80002d2c:	8082                	ret

0000000080002d2e <csem_free>:

void
csem_free(uint64 sem)
{
    80002d2e:	1141                	addi	sp,sp,-16
    80002d30:	e406                	sd	ra,8(sp)
    80002d32:	e022                	sd	s0,0(sp)
    80002d34:	0800                	addi	s0,sp,16
  printf("csem_free()\n");
    80002d36:	00006517          	auipc	a0,0x6
    80002d3a:	5e250513          	addi	a0,a0,1506 # 80009318 <digits+0x2d8>
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	836080e7          	jalr	-1994(ra) # 80000574 <printf>
}
    80002d46:	60a2                	ld	ra,8(sp)
    80002d48:	6402                	ld	s0,0(sp)
    80002d4a:	0141                	addi	sp,sp,16
    80002d4c:	8082                	ret

0000000080002d4e <csem_down>:

void
csem_down(uint64 sem)
{
    80002d4e:	1141                	addi	sp,sp,-16
    80002d50:	e406                	sd	ra,8(sp)
    80002d52:	e022                	sd	s0,0(sp)
    80002d54:	0800                	addi	s0,sp,16
  printf("csem_down()\n");
    80002d56:	00006517          	auipc	a0,0x6
    80002d5a:	5d250513          	addi	a0,a0,1490 # 80009328 <digits+0x2e8>
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	816080e7          	jalr	-2026(ra) # 80000574 <printf>
}
    80002d66:	60a2                	ld	ra,8(sp)
    80002d68:	6402                	ld	s0,0(sp)
    80002d6a:	0141                	addi	sp,sp,16
    80002d6c:	8082                	ret

0000000080002d6e <csem_up>:

void
csem_up(uint64 sem)
{
    80002d6e:	1141                	addi	sp,sp,-16
    80002d70:	e406                	sd	ra,8(sp)
    80002d72:	e022                	sd	s0,0(sp)
    80002d74:	0800                	addi	s0,sp,16
  printf("csem_up()\n");
    80002d76:	00006517          	auipc	a0,0x6
    80002d7a:	5c250513          	addi	a0,a0,1474 # 80009338 <digits+0x2f8>
    80002d7e:	ffffd097          	auipc	ra,0xffffd
    80002d82:	7f6080e7          	jalr	2038(ra) # 80000574 <printf>
}
    80002d86:	60a2                	ld	ra,8(sp)
    80002d88:	6402                	ld	s0,0(sp)
    80002d8a:	0141                	addi	sp,sp,16
    80002d8c:	8082                	ret

0000000080002d8e <print_ptable>:




void print_ptable(void)
{
    80002d8e:	7159                	addi	sp,sp,-112
    80002d90:	f486                	sd	ra,104(sp)
    80002d92:	f0a2                	sd	s0,96(sp)
    80002d94:	eca6                	sd	s1,88(sp)
    80002d96:	e8ca                	sd	s2,80(sp)
    80002d98:	e4ce                	sd	s3,72(sp)
    80002d9a:	e0d2                	sd	s4,64(sp)
    80002d9c:	fc56                	sd	s5,56(sp)
    80002d9e:	f85a                	sd	s6,48(sp)
    80002da0:	f45e                	sd	s7,40(sp)
    80002da2:	f062                	sd	s8,32(sp)
    80002da4:	ec66                	sd	s9,24(sp)
    80002da6:	e86a                	sd	s10,16(sp)
    80002da8:	e46e                	sd	s11,8(sp)
    80002daa:	1880                	addi	s0,sp,112
  for (int i=0 ; i<5 ; i++)
    80002dac:	00011a17          	auipc	s4,0x11
    80002db0:	074a0a13          	addi	s4,s4,116 # 80013e20 <proc+0x738>
    80002db4:	00014d97          	auipc	s11,0x14
    80002db8:	c54d8d93          	addi	s11,s11,-940 # 80016a08 <proc+0x3320>
  {
    if (proc[i].pid == myproc()->pid)
      printf("pid(me):%d\n",proc[i].pid);
    else
      printf("pid:%d\n",proc[i].pid);
    printf("pstate:%s\n", proc[i].state == UNUSED_P ? "UNUSED" :
    80002dbc:	00006a97          	auipc	s5,0x6
    80002dc0:	594a8a93          	addi	s5,s5,1428 # 80009350 <digits+0x310>
                           proc[i].state == USED_P ? "USED" :
    80002dc4:	00006b97          	auipc	s7,0x6
    80002dc8:	594b8b93          	addi	s7,s7,1428 # 80009358 <digits+0x318>
        printf("\ttid(me):%d\n",proc[i].threads[j].tid);
      else
        printf("\ttid:%d\n",proc[i].threads[j].tid);
      printf("\ttstate:%s\n", proc[i].threads[j].state == UNUSED ? "UNUSED" :
                             proc[i].threads[j].state == USED ? "USED" :
                             proc[i].threads[j].state == SLEEPING ? "SLEEPING" :
    80002dcc:	00006c97          	auipc	s9,0x6
    80002dd0:	5acc8c93          	addi	s9,s9,1452 # 80009378 <digits+0x338>
  for (int i=0 ; i<5 ; i++)
    80002dd4:	6d05                	lui	s10,0x1
    80002dd6:	8c8d0d13          	addi	s10,s10,-1848 # 8c8 <_entry-0x7ffff738>
    80002dda:	a85d                	j	80002e90 <print_ptable+0x102>
      printf("pid(me):%d\n",proc[i].pid);
    80002ddc:	8eca2583          	lw	a1,-1812(s4)
    80002de0:	00006517          	auipc	a0,0x6
    80002de4:	5c050513          	addi	a0,a0,1472 # 800093a0 <digits+0x360>
    80002de8:	ffffd097          	auipc	ra,0xffffd
    80002dec:	78c080e7          	jalr	1932(ra) # 80000574 <printf>
    80002df0:	a0e1                	j	80002eb8 <print_ptable+0x12a>
        printf("\ttid(me):%d\n",proc[i].threads[j].tid);
    80002df2:	4c8c                	lw	a1,24(s1)
    80002df4:	8562                	mv	a0,s8
    80002df6:	ffffd097          	auipc	ra,0xffffd
    80002dfa:	77e080e7          	jalr	1918(ra) # 80000574 <printf>
    80002dfe:	a0b9                	j	80002e4c <print_ptable+0xbe>
      printf("\ttstate:%s\n", proc[i].threads[j].state == UNUSED ? "UNUSED" :
    80002e00:	00006517          	auipc	a0,0x6
    80002e04:	5f850513          	addi	a0,a0,1528 # 800093f8 <digits+0x3b8>
    80002e08:	ffffd097          	auipc	ra,0xffffd
    80002e0c:	76c080e7          	jalr	1900(ra) # 80000574 <printf>
                             proc[i].threads[j].state == RUNNABLE ? "RUNNABLE" :
                             proc[i].threads[j].state == RUNNING ? "RUNNING" : 
                             "ZOMBIE");
      printf("\tkilled:%d\n",proc[i].threads[j].killed);
    80002e10:	01092583          	lw	a1,16(s2)
    80002e14:	00006517          	auipc	a0,0x6
    80002e18:	5f450513          	addi	a0,a0,1524 # 80009408 <digits+0x3c8>
    80002e1c:	ffffd097          	auipc	ra,0xffffd
    80002e20:	758080e7          	jalr	1880(ra) # 80000574 <printf>
    for (int j=0 ; j<NTHREAD ; j++)
    80002e24:	0c848493          	addi	s1,s1,200
    80002e28:	07448163          	beq	s1,s4,80002e8a <print_ptable+0xfc>
      if (proc[i].threads[j].tid == mythread()->tid)
    80002e2c:	8926                	mv	s2,s1
    80002e2e:	0184a983          	lw	s3,24(s1)
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	b3e080e7          	jalr	-1218(ra) # 80001970 <mythread>
    80002e3a:	591c                	lw	a5,48(a0)
    80002e3c:	fb378be3          	beq	a5,s3,80002df2 <print_ptable+0x64>
        printf("\ttid:%d\n",proc[i].threads[j].tid);
    80002e40:	4c8c                	lw	a1,24(s1)
    80002e42:	855a                	mv	a0,s6
    80002e44:	ffffd097          	auipc	ra,0xffffd
    80002e48:	730080e7          	jalr	1840(ra) # 80000574 <printf>
      printf("\ttstate:%s\n", proc[i].threads[j].state == UNUSED ? "UNUSED" :
    80002e4c:	00092783          	lw	a5,0(s2)
    80002e50:	85d6                	mv	a1,s5
    80002e52:	d7dd                	beqz	a5,80002e00 <print_ptable+0x72>
                             proc[i].threads[j].state == USED ? "USED" :
    80002e54:	4705                	li	a4,1
    80002e56:	85de                	mv	a1,s7
    80002e58:	fae784e3          	beq	a5,a4,80002e00 <print_ptable+0x72>
                             proc[i].threads[j].state == SLEEPING ? "SLEEPING" :
    80002e5c:	4709                	li	a4,2
    80002e5e:	85e6                	mv	a1,s9
    80002e60:	fae780e3          	beq	a5,a4,80002e00 <print_ptable+0x72>
                             proc[i].threads[j].state == RUNNABLE ? "RUNNABLE" :
    80002e64:	470d                	li	a4,3
    80002e66:	00006597          	auipc	a1,0x6
    80002e6a:	52258593          	addi	a1,a1,1314 # 80009388 <digits+0x348>
    80002e6e:	f8e789e3          	beq	a5,a4,80002e00 <print_ptable+0x72>
                             proc[i].threads[j].state == RUNNING ? "RUNNING" : 
    80002e72:	4711                	li	a4,4
    80002e74:	00006597          	auipc	a1,0x6
    80002e78:	4fc58593          	addi	a1,a1,1276 # 80009370 <digits+0x330>
    80002e7c:	f8e782e3          	beq	a5,a4,80002e00 <print_ptable+0x72>
    80002e80:	00006597          	auipc	a1,0x6
    80002e84:	51858593          	addi	a1,a1,1304 # 80009398 <digits+0x358>
    80002e88:	bfa5                	j	80002e00 <print_ptable+0x72>
  for (int i=0 ; i<5 ; i++)
    80002e8a:	9a6a                	add	s4,s4,s10
    80002e8c:	09ba0663          	beq	s4,s11,80002f18 <print_ptable+0x18a>
    if (proc[i].pid == myproc()->pid)
    80002e90:	84d2                	mv	s1,s4
    80002e92:	8eca2903          	lw	s2,-1812(s4)
    80002e96:	fffff097          	auipc	ra,0xfffff
    80002e9a:	d5e080e7          	jalr	-674(ra) # 80001bf4 <myproc>
    80002e9e:	515c                	lw	a5,36(a0)
    80002ea0:	f3278ee3          	beq	a5,s2,80002ddc <print_ptable+0x4e>
      printf("pid:%d\n",proc[i].pid);
    80002ea4:	8eca2583          	lw	a1,-1812(s4)
    80002ea8:	00006517          	auipc	a0,0x6
    80002eac:	50850513          	addi	a0,a0,1288 # 800093b0 <digits+0x370>
    80002eb0:	ffffd097          	auipc	ra,0xffffd
    80002eb4:	6c4080e7          	jalr	1732(ra) # 80000574 <printf>
    printf("pstate:%s\n", proc[i].state == UNUSED_P ? "UNUSED" :
    80002eb8:	8e04a783          	lw	a5,-1824(s1)
    80002ebc:	85d6                	mv	a1,s5
    80002ebe:	c385                	beqz	a5,80002ede <print_ptable+0x150>
                           proc[i].state == USED_P ? "USED" :
    80002ec0:	4705                	li	a4,1
    80002ec2:	85de                	mv	a1,s7
    80002ec4:	00e78d63          	beq	a5,a4,80002ede <print_ptable+0x150>
                           proc[i].state == ALIVE ? "ALIVE" :
    80002ec8:	4709                	li	a4,2
    80002eca:	00006597          	auipc	a1,0x6
    80002ece:	47e58593          	addi	a1,a1,1150 # 80009348 <digits+0x308>
    80002ed2:	00e78663          	beq	a5,a4,80002ede <print_ptable+0x150>
    80002ed6:	00006597          	auipc	a1,0x6
    80002eda:	48a58593          	addi	a1,a1,1162 # 80009360 <digits+0x320>
    printf("pstate:%s\n", proc[i].state == UNUSED_P ? "UNUSED" :
    80002ede:	00006517          	auipc	a0,0x6
    80002ee2:	4da50513          	addi	a0,a0,1242 # 800093b8 <digits+0x378>
    80002ee6:	ffffd097          	auipc	ra,0xffffd
    80002eea:	68e080e7          	jalr	1678(ra) # 80000574 <printf>
    printf("xstate:%d\n",proc[i].xstate);
    80002eee:	8e84a583          	lw	a1,-1816(s1)
    80002ef2:	00006517          	auipc	a0,0x6
    80002ef6:	4d650513          	addi	a0,a0,1238 # 800093c8 <digits+0x388>
    80002efa:	ffffd097          	auipc	ra,0xffffd
    80002efe:	67a080e7          	jalr	1658(ra) # 80000574 <printf>
    for (int j=0 ; j<NTHREAD ; j++)
    80002f02:	9c0a0493          	addi	s1,s4,-1600
        printf("\ttid:%d\n",proc[i].threads[j].tid);
    80002f06:	00006b17          	auipc	s6,0x6
    80002f0a:	4e2b0b13          	addi	s6,s6,1250 # 800093e8 <digits+0x3a8>
        printf("\ttid(me):%d\n",proc[i].threads[j].tid);
    80002f0e:	00006c17          	auipc	s8,0x6
    80002f12:	4cac0c13          	addi	s8,s8,1226 # 800093d8 <digits+0x398>
    80002f16:	bf19                	j	80002e2c <print_ptable+0x9e>
    }
  }
}
    80002f18:	70a6                	ld	ra,104(sp)
    80002f1a:	7406                	ld	s0,96(sp)
    80002f1c:	64e6                	ld	s1,88(sp)
    80002f1e:	6946                	ld	s2,80(sp)
    80002f20:	69a6                	ld	s3,72(sp)
    80002f22:	6a06                	ld	s4,64(sp)
    80002f24:	7ae2                	ld	s5,56(sp)
    80002f26:	7b42                	ld	s6,48(sp)
    80002f28:	7ba2                	ld	s7,40(sp)
    80002f2a:	7c02                	ld	s8,32(sp)
    80002f2c:	6ce2                	ld	s9,24(sp)
    80002f2e:	6d42                	ld	s10,16(sp)
    80002f30:	6da2                	ld	s11,8(sp)
    80002f32:	6165                	addi	sp,sp,112
    80002f34:	8082                	ret

0000000080002f36 <swtch>:
    80002f36:	00153023          	sd	ra,0(a0)
    80002f3a:	00253423          	sd	sp,8(a0)
    80002f3e:	e900                	sd	s0,16(a0)
    80002f40:	ed04                	sd	s1,24(a0)
    80002f42:	03253023          	sd	s2,32(a0)
    80002f46:	03353423          	sd	s3,40(a0)
    80002f4a:	03453823          	sd	s4,48(a0)
    80002f4e:	03553c23          	sd	s5,56(a0)
    80002f52:	05653023          	sd	s6,64(a0)
    80002f56:	05753423          	sd	s7,72(a0)
    80002f5a:	05853823          	sd	s8,80(a0)
    80002f5e:	05953c23          	sd	s9,88(a0)
    80002f62:	07a53023          	sd	s10,96(a0)
    80002f66:	07b53423          	sd	s11,104(a0)
    80002f6a:	0005b083          	ld	ra,0(a1)
    80002f6e:	0085b103          	ld	sp,8(a1)
    80002f72:	6980                	ld	s0,16(a1)
    80002f74:	6d84                	ld	s1,24(a1)
    80002f76:	0205b903          	ld	s2,32(a1)
    80002f7a:	0285b983          	ld	s3,40(a1)
    80002f7e:	0305ba03          	ld	s4,48(a1)
    80002f82:	0385ba83          	ld	s5,56(a1)
    80002f86:	0405bb03          	ld	s6,64(a1)
    80002f8a:	0485bb83          	ld	s7,72(a1)
    80002f8e:	0505bc03          	ld	s8,80(a1)
    80002f92:	0585bc83          	ld	s9,88(a1)
    80002f96:	0605bd03          	ld	s10,96(a1)
    80002f9a:	0685bd83          	ld	s11,104(a1)
    80002f9e:	8082                	ret

0000000080002fa0 <call_sigret>:
    }
  }
}

void call_sigret()
{
    80002fa0:	1141                	addi	sp,sp,-16
    80002fa2:	e422                	sd	s0,8(sp)
    80002fa4:	0800                	addi	s0,sp,16
  asm("li a7,24");
    80002fa6:	48e1                	li	a7,24
  asm("ecall");
    80002fa8:	00000073          	ecall
  asm("ret");
    80002fac:	8082                	ret
}
    80002fae:	6422                	ld	s0,8(sp)
    80002fb0:	0141                	addi	sp,sp,16
    80002fb2:	8082                	ret

0000000080002fb4 <end_call_sigret>:

void end_call_sigret(){}
    80002fb4:	1141                	addi	sp,sp,-16
    80002fb6:	e422                	sd	s0,8(sp)
    80002fb8:	0800                	addi	s0,sp,16
    80002fba:	6422                	ld	s0,8(sp)
    80002fbc:	0141                	addi	sp,sp,16
    80002fbe:	8082                	ret

0000000080002fc0 <trapinit>:
{
    80002fc0:	1141                	addi	sp,sp,-16
    80002fc2:	e406                	sd	ra,8(sp)
    80002fc4:	e022                	sd	s0,0(sp)
    80002fc6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002fc8:	00006597          	auipc	a1,0x6
    80002fcc:	4a858593          	addi	a1,a1,1192 # 80009470 <states.0+0x30>
    80002fd0:	00034517          	auipc	a0,0x34
    80002fd4:	91850513          	addi	a0,a0,-1768 # 800368e8 <tickslock>
    80002fd8:	ffffe097          	auipc	ra,0xffffe
    80002fdc:	b5a080e7          	jalr	-1190(ra) # 80000b32 <initlock>
}
    80002fe0:	60a2                	ld	ra,8(sp)
    80002fe2:	6402                	ld	s0,0(sp)
    80002fe4:	0141                	addi	sp,sp,16
    80002fe6:	8082                	ret

0000000080002fe8 <trapinithart>:
{
    80002fe8:	1141                	addi	sp,sp,-16
    80002fea:	e422                	sd	s0,8(sp)
    80002fec:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fee:	00004797          	auipc	a5,0x4
    80002ff2:	b0278793          	addi	a5,a5,-1278 # 80006af0 <kernelvec>
    80002ff6:	10579073          	csrw	stvec,a5
}
    80002ffa:	6422                	ld	s0,8(sp)
    80002ffc:	0141                	addi	sp,sp,16
    80002ffe:	8082                	ret

0000000080003000 <clockintr>:
{
    80003000:	1101                	addi	sp,sp,-32
    80003002:	ec06                	sd	ra,24(sp)
    80003004:	e822                	sd	s0,16(sp)
    80003006:	e426                	sd	s1,8(sp)
    80003008:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000300a:	00034497          	auipc	s1,0x34
    8000300e:	8de48493          	addi	s1,s1,-1826 # 800368e8 <tickslock>
    80003012:	8526                	mv	a0,s1
    80003014:	ffffe097          	auipc	ra,0xffffe
    80003018:	bae080e7          	jalr	-1106(ra) # 80000bc2 <acquire>
  ticks++;
    8000301c:	00007517          	auipc	a0,0x7
    80003020:	01450513          	addi	a0,a0,20 # 8000a030 <ticks>
    80003024:	411c                	lw	a5,0(a0)
    80003026:	2785                	addiw	a5,a5,1
    80003028:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000302a:	fffff097          	auipc	ra,0xfffff
    8000302e:	584080e7          	jalr	1412(ra) # 800025ae <wakeup>
  release(&tickslock);
    80003032:	8526                	mv	a0,s1
    80003034:	ffffe097          	auipc	ra,0xffffe
    80003038:	c42080e7          	jalr	-958(ra) # 80000c76 <release>
}
    8000303c:	60e2                	ld	ra,24(sp)
    8000303e:	6442                	ld	s0,16(sp)
    80003040:	64a2                	ld	s1,8(sp)
    80003042:	6105                	addi	sp,sp,32
    80003044:	8082                	ret

0000000080003046 <devintr>:
{
    80003046:	1101                	addi	sp,sp,-32
    80003048:	ec06                	sd	ra,24(sp)
    8000304a:	e822                	sd	s0,16(sp)
    8000304c:	e426                	sd	s1,8(sp)
    8000304e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003050:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80003054:	00074d63          	bltz	a4,8000306e <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80003058:	57fd                	li	a5,-1
    8000305a:	17fe                	slli	a5,a5,0x3f
    8000305c:	0785                	addi	a5,a5,1
    return 0;
    8000305e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003060:	06f70363          	beq	a4,a5,800030c6 <devintr+0x80>
}
    80003064:	60e2                	ld	ra,24(sp)
    80003066:	6442                	ld	s0,16(sp)
    80003068:	64a2                	ld	s1,8(sp)
    8000306a:	6105                	addi	sp,sp,32
    8000306c:	8082                	ret
     (scause & 0xff) == 9){
    8000306e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80003072:	46a5                	li	a3,9
    80003074:	fed792e3          	bne	a5,a3,80003058 <devintr+0x12>
    int irq = plic_claim();
    80003078:	00004097          	auipc	ra,0x4
    8000307c:	b80080e7          	jalr	-1152(ra) # 80006bf8 <plic_claim>
    80003080:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003082:	47a9                	li	a5,10
    80003084:	02f50763          	beq	a0,a5,800030b2 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003088:	4785                	li	a5,1
    8000308a:	02f50963          	beq	a0,a5,800030bc <devintr+0x76>
    return 1;
    8000308e:	4505                	li	a0,1
    } else if(irq){
    80003090:	d8f1                	beqz	s1,80003064 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003092:	85a6                	mv	a1,s1
    80003094:	00006517          	auipc	a0,0x6
    80003098:	3e450513          	addi	a0,a0,996 # 80009478 <states.0+0x38>
    8000309c:	ffffd097          	auipc	ra,0xffffd
    800030a0:	4d8080e7          	jalr	1240(ra) # 80000574 <printf>
      plic_complete(irq);
    800030a4:	8526                	mv	a0,s1
    800030a6:	00004097          	auipc	ra,0x4
    800030aa:	b76080e7          	jalr	-1162(ra) # 80006c1c <plic_complete>
    return 1;
    800030ae:	4505                	li	a0,1
    800030b0:	bf55                	j	80003064 <devintr+0x1e>
      uartintr();
    800030b2:	ffffe097          	auipc	ra,0xffffe
    800030b6:	8d4080e7          	jalr	-1836(ra) # 80000986 <uartintr>
    800030ba:	b7ed                	j	800030a4 <devintr+0x5e>
      virtio_disk_intr();
    800030bc:	00004097          	auipc	ra,0x4
    800030c0:	ff2080e7          	jalr	-14(ra) # 800070ae <virtio_disk_intr>
    800030c4:	b7c5                	j	800030a4 <devintr+0x5e>
    if(cpuid() == 0){
    800030c6:	fffff097          	auipc	ra,0xfffff
    800030ca:	b02080e7          	jalr	-1278(ra) # 80001bc8 <cpuid>
    800030ce:	c901                	beqz	a0,800030de <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800030d0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800030d4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800030d6:	14479073          	csrw	sip,a5
    return 2;
    800030da:	4509                	li	a0,2
    800030dc:	b761                	j	80003064 <devintr+0x1e>
      clockintr();
    800030de:	00000097          	auipc	ra,0x0
    800030e2:	f22080e7          	jalr	-222(ra) # 80003000 <clockintr>
    800030e6:	b7ed                	j	800030d0 <devintr+0x8a>

00000000800030e8 <kerneltrap>:
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030f6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030fa:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030fe:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003102:	1004f793          	andi	a5,s1,256
    80003106:	cb85                	beqz	a5,80003136 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003108:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000310c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000310e:	ef85                	bnez	a5,80003146 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003110:	00000097          	auipc	ra,0x0
    80003114:	f36080e7          	jalr	-202(ra) # 80003046 <devintr>
    80003118:	cd1d                	beqz	a0,80003156 <kerneltrap+0x6e>
  if(which_dev == 2 && mythread() != 0 && mythread()->state == RUNNING)
    8000311a:	4789                	li	a5,2
    8000311c:	06f50a63          	beq	a0,a5,80003190 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003120:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003124:	10049073          	csrw	sstatus,s1
}
    80003128:	70a2                	ld	ra,40(sp)
    8000312a:	7402                	ld	s0,32(sp)
    8000312c:	64e2                	ld	s1,24(sp)
    8000312e:	6942                	ld	s2,16(sp)
    80003130:	69a2                	ld	s3,8(sp)
    80003132:	6145                	addi	sp,sp,48
    80003134:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003136:	00006517          	auipc	a0,0x6
    8000313a:	36250513          	addi	a0,a0,866 # 80009498 <states.0+0x58>
    8000313e:	ffffd097          	auipc	ra,0xffffd
    80003142:	3ec080e7          	jalr	1004(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80003146:	00006517          	auipc	a0,0x6
    8000314a:	37a50513          	addi	a0,a0,890 # 800094c0 <states.0+0x80>
    8000314e:	ffffd097          	auipc	ra,0xffffd
    80003152:	3dc080e7          	jalr	988(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80003156:	85ce                	mv	a1,s3
    80003158:	00006517          	auipc	a0,0x6
    8000315c:	38850513          	addi	a0,a0,904 # 800094e0 <states.0+0xa0>
    80003160:	ffffd097          	auipc	ra,0xffffd
    80003164:	414080e7          	jalr	1044(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003168:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000316c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003170:	00006517          	auipc	a0,0x6
    80003174:	38050513          	addi	a0,a0,896 # 800094f0 <states.0+0xb0>
    80003178:	ffffd097          	auipc	ra,0xffffd
    8000317c:	3fc080e7          	jalr	1020(ra) # 80000574 <printf>
    panic("kerneltrap");
    80003180:	00006517          	auipc	a0,0x6
    80003184:	38850513          	addi	a0,a0,904 # 80009508 <states.0+0xc8>
    80003188:	ffffd097          	auipc	ra,0xffffd
    8000318c:	3a2080e7          	jalr	930(ra) # 8000052a <panic>
  if(which_dev == 2 && mythread() != 0 && mythread()->state == RUNNING)
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	7e0080e7          	jalr	2016(ra) # 80001970 <mythread>
    80003198:	d541                	beqz	a0,80003120 <kerneltrap+0x38>
    8000319a:	ffffe097          	auipc	ra,0xffffe
    8000319e:	7d6080e7          	jalr	2006(ra) # 80001970 <mythread>
    800031a2:	4d18                	lw	a4,24(a0)
    800031a4:	4791                	li	a5,4
    800031a6:	f6f71de3          	bne	a4,a5,80003120 <kerneltrap+0x38>
    yield();
    800031aa:	fffff097          	auipc	ra,0xfffff
    800031ae:	240080e7          	jalr	576(ra) # 800023ea <yield>
    800031b2:	b7bd                	j	80003120 <kerneltrap+0x38>

00000000800031b4 <kill_handler>:
{
    800031b4:	7139                	addi	sp,sp,-64
    800031b6:	fc06                	sd	ra,56(sp)
    800031b8:	f822                	sd	s0,48(sp)
    800031ba:	f426                	sd	s1,40(sp)
    800031bc:	f04a                	sd	s2,32(sp)
    800031be:	ec4e                	sd	s3,24(sp)
    800031c0:	e852                	sd	s4,16(sp)
    800031c2:	e456                	sd	s5,8(sp)
    800031c4:	e05a                	sd	s6,0(sp)
    800031c6:	0080                	addi	s0,sp,64
  struct proc* p = myproc();
    800031c8:	fffff097          	auipc	ra,0xfffff
    800031cc:	a2c080e7          	jalr	-1492(ra) # 80001bf4 <myproc>
    800031d0:	8aaa                	mv	s5,a0
  acquire(&p->lock);
    800031d2:	ffffe097          	auipc	ra,0xffffe
    800031d6:	9f0080e7          	jalr	-1552(ra) # 80000bc2 <acquire>
  for (struct thread* t=p->threads ; t<&p->threads[NTHREAD] ; t++)
    800031da:	0e0a8493          	addi	s1,s5,224
    800031de:	720a8a13          	addi	s4,s5,1824
    t->killed = 1;
    800031e2:	4985                	li	s3,1
    if(t->state == SLEEPING)
    800031e4:	4909                	li	s2,2
      t->state = RUNNABLE;
    800031e6:	4b0d                	li	s6,3
    800031e8:	a811                	j	800031fc <kill_handler+0x48>
    release(&t->lock);
    800031ea:	8526                	mv	a0,s1
    800031ec:	ffffe097          	auipc	ra,0xffffe
    800031f0:	a8a080e7          	jalr	-1398(ra) # 80000c76 <release>
  for (struct thread* t=p->threads ; t<&p->threads[NTHREAD] ; t++)
    800031f4:	0c848493          	addi	s1,s1,200
    800031f8:	009a0f63          	beq	s4,s1,80003216 <kill_handler+0x62>
    acquire(&t->lock);
    800031fc:	8526                	mv	a0,s1
    800031fe:	ffffe097          	auipc	ra,0xffffe
    80003202:	9c4080e7          	jalr	-1596(ra) # 80000bc2 <acquire>
    t->killed = 1;
    80003206:	0334a423          	sw	s3,40(s1)
    if(t->state == SLEEPING)
    8000320a:	4c9c                	lw	a5,24(s1)
    8000320c:	fd279fe3          	bne	a5,s2,800031ea <kill_handler+0x36>
      t->state = RUNNABLE;
    80003210:	0164ac23          	sw	s6,24(s1)
    80003214:	bfd9                	j	800031ea <kill_handler+0x36>
  release(&p->lock);
    80003216:	8556                	mv	a0,s5
    80003218:	ffffe097          	auipc	ra,0xffffe
    8000321c:	a5e080e7          	jalr	-1442(ra) # 80000c76 <release>
}
    80003220:	70e2                	ld	ra,56(sp)
    80003222:	7442                	ld	s0,48(sp)
    80003224:	74a2                	ld	s1,40(sp)
    80003226:	7902                	ld	s2,32(sp)
    80003228:	69e2                	ld	s3,24(sp)
    8000322a:	6a42                	ld	s4,16(sp)
    8000322c:	6aa2                	ld	s5,8(sp)
    8000322e:	6b02                	ld	s6,0(sp)
    80003230:	6121                	addi	sp,sp,64
    80003232:	8082                	ret

0000000080003234 <stop_handler>:
{
    80003234:	7179                	addi	sp,sp,-48
    80003236:	f406                	sd	ra,40(sp)
    80003238:	f022                	sd	s0,32(sp)
    8000323a:	ec26                	sd	s1,24(sp)
    8000323c:	e84a                	sd	s2,16(sp)
    8000323e:	e44e                	sd	s3,8(sp)
    80003240:	e052                	sd	s4,0(sp)
    80003242:	1800                	addi	s0,sp,48
  struct proc* p = myproc();
    80003244:	fffff097          	auipc	ra,0xfffff
    80003248:	9b0080e7          	jalr	-1616(ra) # 80001bf4 <myproc>
    8000324c:	84aa                	mv	s1,a0
  p->freezed = 1;
    8000324e:	6785                	lui	a5,0x1
    80003250:	97aa                	add	a5,a5,a0
    80003252:	4705                	li	a4,1
    80003254:	8ae7a423          	sw	a4,-1880(a5) # 8a8 <_entry-0x7ffff758>
    if ((p->pending_signals & (1<<SIGCONT)) != 0)
    80003258:	000809b7          	lui	s3,0x80
  while (p->freezed == 1)
    8000325c:	893e                	mv	s2,a5
    8000325e:	4a05                	li	s4,1
    80003260:	a809                	j	80003272 <stop_handler+0x3e>
      yield();
    80003262:	fffff097          	auipc	ra,0xfffff
    80003266:	188080e7          	jalr	392(ra) # 800023ea <yield>
  while (p->freezed == 1)
    8000326a:	8a892783          	lw	a5,-1880(s2)
    8000326e:	01479c63          	bne	a5,s4,80003286 <stop_handler+0x52>
    if ((p->pending_signals & (1<<SIGCONT)) != 0)
    80003272:	7204a783          	lw	a5,1824(s1)
    80003276:	0137f7b3          	and	a5,a5,s3
    8000327a:	2781                	sext.w	a5,a5
    8000327c:	d3fd                	beqz	a5,80003262 <stop_handler+0x2e>
      p->freezed = 0;
    8000327e:	6505                	lui	a0,0x1
    80003280:	94aa                	add	s1,s1,a0
    80003282:	8a04a423          	sw	zero,-1880(s1)
}
    80003286:	70a2                	ld	ra,40(sp)
    80003288:	7402                	ld	s0,32(sp)
    8000328a:	64e2                	ld	s1,24(sp)
    8000328c:	6942                	ld	s2,16(sp)
    8000328e:	69a2                	ld	s3,8(sp)
    80003290:	6a02                	ld	s4,0(sp)
    80003292:	6145                	addi	sp,sp,48
    80003294:	8082                	ret

0000000080003296 <copy_tf>:

void copy_tf(struct trapframe* dst,  struct trapframe* src)
{
    80003296:	1141                	addi	sp,sp,-16
    80003298:	e406                	sd	ra,8(sp)
    8000329a:	e022                	sd	s0,0(sp)
    8000329c:	0800                	addi	s0,sp,16
  memmove((void*)dst,(void*)src,sizeof(struct trapframe));
    8000329e:	12000613          	li	a2,288
    800032a2:	ffffe097          	auipc	ra,0xffffe
    800032a6:	a78080e7          	jalr	-1416(ra) # 80000d1a <memmove>
    800032aa:	60a2                	ld	ra,8(sp)
    800032ac:	6402                	ld	s0,0(sp)
    800032ae:	0141                	addi	sp,sp,16
    800032b0:	8082                	ret

00000000800032b2 <user_handler>:
{
    800032b2:	7139                	addi	sp,sp,-64
    800032b4:	fc06                	sd	ra,56(sp)
    800032b6:	f822                	sd	s0,48(sp)
    800032b8:	f426                	sd	s1,40(sp)
    800032ba:	f04a                	sd	s2,32(sp)
    800032bc:	ec4e                	sd	s3,24(sp)
    800032be:	e852                	sd	s4,16(sp)
    800032c0:	e456                	sd	s5,8(sp)
    800032c2:	0080                	addi	s0,sp,64
    800032c4:	89aa                	mv	s3,a0
  struct proc* p = myproc();
    800032c6:	fffff097          	auipc	ra,0xfffff
    800032ca:	92e080e7          	jalr	-1746(ra) # 80001bf4 <myproc>
    800032ce:	84aa                	mv	s1,a0
  struct thread* t = mythread();
    800032d0:	ffffe097          	auipc	ra,0xffffe
    800032d4:	6a0080e7          	jalr	1696(ra) # 80001970 <mythread>
  if (p->signal_handling == 0)
    800032d8:	6785                	lui	a5,0x1
    800032da:	97a6                	add	a5,a5,s1
    800032dc:	8b07a703          	lw	a4,-1872(a5) # 8b0 <_entry-0x7ffff750>
    800032e0:	c315                	beqz	a4,80003304 <user_handler+0x52>
    p->pending_signals = p->pending_signals ^ (1<<signum);
    800032e2:	4785                	li	a5,1
    800032e4:	013797bb          	sllw	a5,a5,s3
    800032e8:	7204a503          	lw	a0,1824(s1)
    800032ec:	8d3d                	xor	a0,a0,a5
    800032ee:	72a4a023          	sw	a0,1824(s1)
}
    800032f2:	70e2                	ld	ra,56(sp)
    800032f4:	7442                	ld	s0,48(sp)
    800032f6:	74a2                	ld	s1,40(sp)
    800032f8:	7902                	ld	s2,32(sp)
    800032fa:	69e2                	ld	s3,24(sp)
    800032fc:	6a42                	ld	s4,16(sp)
    800032fe:	6aa2                	ld	s5,8(sp)
    80003300:	6121                	addi	sp,sp,64
    80003302:	8082                	ret
    80003304:	892a                	mv	s2,a0
    copy_tf(t->tf_backup,t->trapframe);
    80003306:	652c                	ld	a1,72(a0)
    80003308:	6928                	ld	a0,80(a0)
    8000330a:	00000097          	auipc	ra,0x0
    8000330e:	f8c080e7          	jalr	-116(ra) # 80003296 <copy_tf>
    uint func_size = end_call_sigret - call_sigret;
    80003312:	00000a17          	auipc	s4,0x0
    80003316:	c8ea0a13          	addi	s4,s4,-882 # 80002fa0 <call_sigret>
    8000331a:	00000697          	auipc	a3,0x0
    8000331e:	c9a68693          	addi	a3,a3,-870 # 80002fb4 <end_call_sigret>
    80003322:	41468ab3          	sub	s5,a3,s4
    p->signal_mask_backup = p->proc_signal_mask;
    80003326:	6705                	lui	a4,0x1
    80003328:	9726                	add	a4,a4,s1
    8000332a:	7244a783          	lw	a5,1828(s1)
    8000332e:	8af72623          	sw	a5,-1876(a4) # 8ac <_entry-0x7ffff754>
    p->proc_signal_mask = p->signal_masks[signum];
    80003332:	20898793          	addi	a5,s3,520 # 80208 <_entry-0x7ff7fdf8>
    80003336:	078a                	slli	a5,a5,0x2
    80003338:	97a6                	add	a5,a5,s1
    8000333a:	479c                	lw	a5,8(a5)
    8000333c:	72f4a223          	sw	a5,1828(s1)
    p->signal_handling = 1;
    80003340:	4785                	li	a5,1
    80003342:	8af72823          	sw	a5,-1872(a4)
    t->trapframe->sp -= sizeof(struct trapframe);
    80003346:	04893703          	ld	a4,72(s2)
    8000334a:	7b1c                	ld	a5,48(a4)
    8000334c:	ee078793          	addi	a5,a5,-288
    80003350:	fb1c                	sd	a5,48(a4)
    t->tf_backup->sp = t->trapframe->sp;
    80003352:	05093783          	ld	a5,80(s2)
    80003356:	04893703          	ld	a4,72(s2)
    8000335a:	7b18                	ld	a4,48(a4)
    8000335c:	fb98                	sd	a4,48(a5)
    copyout(p->pagetable , t->tf_backup->sp , (char*) t->trapframe , sizeof(struct trapframe));
    8000335e:	05093783          	ld	a5,80(s2)
    80003362:	12000693          	li	a3,288
    80003366:	04893603          	ld	a2,72(s2)
    8000336a:	7b8c                	ld	a1,48(a5)
    8000336c:	60a8                	ld	a0,64(s1)
    8000336e:	ffffe097          	auipc	ra,0xffffe
    80003372:	2d8080e7          	jalr	728(ra) # 80001646 <copyout>
    t->trapframe->epc = (uint64) p->signal_handlers[signum];
    80003376:	04893703          	ld	a4,72(s2)
    8000337a:	0e498793          	addi	a5,s3,228
    8000337e:	078e                	slli	a5,a5,0x3
    80003380:	97a6                	add	a5,a5,s1
    80003382:	679c                	ld	a5,8(a5)
    80003384:	ef1c                	sd	a5,24(a4)
    t->trapframe->sp -= func_size;
    80003386:	04893703          	ld	a4,72(s2)
    8000338a:	020a9693          	slli	a3,s5,0x20
    8000338e:	9281                	srli	a3,a3,0x20
    80003390:	7b1c                	ld	a5,48(a4)
    80003392:	8f95                	sub	a5,a5,a3
    80003394:	fb1c                	sd	a5,48(a4)
    copyout(p->pagetable , t->trapframe->sp ,(char*) call_sigret , func_size);
    80003396:	04893783          	ld	a5,72(s2)
    8000339a:	8652                	mv	a2,s4
    8000339c:	7b8c                	ld	a1,48(a5)
    8000339e:	60a8                	ld	a0,64(s1)
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	2a6080e7          	jalr	678(ra) # 80001646 <copyout>
    t->trapframe->a0 = signum;
    800033a8:	04893783          	ld	a5,72(s2)
    800033ac:	0737b823          	sd	s3,112(a5)
    t->trapframe->ra = t->trapframe->sp;
    800033b0:	04893783          	ld	a5,72(s2)
    800033b4:	7b98                	ld	a4,48(a5)
    800033b6:	f798                	sd	a4,40(a5)
    800033b8:	bf2d                	j	800032f2 <user_handler+0x40>

00000000800033ba <handle_signals>:
{
    800033ba:	715d                	addi	sp,sp,-80
    800033bc:	e486                	sd	ra,72(sp)
    800033be:	e0a2                	sd	s0,64(sp)
    800033c0:	fc26                	sd	s1,56(sp)
    800033c2:	f84a                	sd	s2,48(sp)
    800033c4:	f44e                	sd	s3,40(sp)
    800033c6:	f052                	sd	s4,32(sp)
    800033c8:	ec56                	sd	s5,24(sp)
    800033ca:	e85a                	sd	s6,16(sp)
    800033cc:	e45e                	sd	s7,8(sp)
    800033ce:	e062                	sd	s8,0(sp)
    800033d0:	0880                	addi	s0,sp,80
  struct proc* p = myproc();
    800033d2:	fffff097          	auipc	ra,0xfffff
    800033d6:	822080e7          	jalr	-2014(ra) # 80001bf4 <myproc>
    800033da:	892a                	mv	s2,a0
    800033dc:	4485                	li	s1,1
    if ( (p->proc_signal_mask & (1<<signum)) == 0)
    800033de:	4985                	li	s3,1
  for (int signum=0 ; signum<NUM_OF_SIGNALS ; signum++)
    800033e0:	4a7d                	li	s4,31
        switch(signum)
    800033e2:	4ac5                	li	s5,17
    800033e4:	4c4d                	li	s8,19
    800033e6:	4b85                	li	s7,1
    800033e8:	4b25                	li	s6,9
    800033ea:	a821                	j	80003402 <handle_signals+0x48>
    800033ec:	01850a63          	beq	a0,s8,80003400 <handle_signals+0x46>
            user_handler(signum);
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	ec2080e7          	jalr	-318(ra) # 800032b2 <user_handler>
  for (int signum=0 ; signum<NUM_OF_SIGNALS ; signum++)
    800033f8:	0004879b          	sext.w	a5,s1
    800033fc:	04fa4963          	blt	s4,a5,8000344e <handle_signals+0x94>
    80003400:	2485                	addiw	s1,s1,1
    80003402:	fff4851b          	addiw	a0,s1,-1
    if ( (p->proc_signal_mask & (1<<signum)) == 0)
    80003406:	00a9973b          	sllw	a4,s3,a0
    8000340a:	72492783          	lw	a5,1828(s2)
    8000340e:	8ff9                	and	a5,a5,a4
    80003410:	2781                	sext.w	a5,a5
    80003412:	f3fd                	bnez	a5,800033f8 <handle_signals+0x3e>
      if ((p->pending_signals & (1 << signum)) != 0)
    80003414:	72092683          	lw	a3,1824(s2)
    80003418:	00e6f7b3          	and	a5,a3,a4
    8000341c:	2781                	sext.w	a5,a5
    8000341e:	dfe9                	beqz	a5,800033f8 <handle_signals+0x3e>
        p->pending_signals = p->pending_signals ^ (1<<signum);
    80003420:	8f35                	xor	a4,a4,a3
    80003422:	72e92023          	sw	a4,1824(s2)
        switch(signum)
    80003426:	01550e63          	beq	a0,s5,80003442 <handle_signals+0x88>
    8000342a:	fcaac1e3          	blt	s5,a0,800033ec <handle_signals+0x32>
    8000342e:	fd7509e3          	beq	a0,s7,80003400 <handle_signals+0x46>
    80003432:	fb651fe3          	bne	a0,s6,800033f0 <handle_signals+0x36>
            kill_handler(signum);
    80003436:	855a                	mv	a0,s6
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	d7c080e7          	jalr	-644(ra) # 800031b4 <kill_handler>
            break;
    80003440:	b7c1                	j	80003400 <handle_signals+0x46>
            stop_handler(signum);
    80003442:	8556                	mv	a0,s5
    80003444:	00000097          	auipc	ra,0x0
    80003448:	df0080e7          	jalr	-528(ra) # 80003234 <stop_handler>
            break;
    8000344c:	bf55                	j	80003400 <handle_signals+0x46>
}
    8000344e:	60a6                	ld	ra,72(sp)
    80003450:	6406                	ld	s0,64(sp)
    80003452:	74e2                	ld	s1,56(sp)
    80003454:	7942                	ld	s2,48(sp)
    80003456:	79a2                	ld	s3,40(sp)
    80003458:	7a02                	ld	s4,32(sp)
    8000345a:	6ae2                	ld	s5,24(sp)
    8000345c:	6b42                	ld	s6,16(sp)
    8000345e:	6ba2                	ld	s7,8(sp)
    80003460:	6c02                	ld	s8,0(sp)
    80003462:	6161                	addi	sp,sp,80
    80003464:	8082                	ret

0000000080003466 <usertrapret>:
{
    80003466:	1101                	addi	sp,sp,-32
    80003468:	ec06                	sd	ra,24(sp)
    8000346a:	e822                	sd	s0,16(sp)
    8000346c:	e426                	sd	s1,8(sp)
    8000346e:	e04a                	sd	s2,0(sp)
    80003470:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003472:	ffffe097          	auipc	ra,0xffffe
    80003476:	782080e7          	jalr	1922(ra) # 80001bf4 <myproc>
    8000347a:	892a                	mv	s2,a0
  struct thread* t =mythread();
    8000347c:	ffffe097          	auipc	ra,0xffffe
    80003480:	4f4080e7          	jalr	1268(ra) # 80001970 <mythread>
    80003484:	84aa                	mv	s1,a0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003486:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000348a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000348c:	10079073          	csrw	sstatus,a5
  handle_signals();
    80003490:	00000097          	auipc	ra,0x0
    80003494:	f2a080e7          	jalr	-214(ra) # 800033ba <handle_signals>
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003498:	00005617          	auipc	a2,0x5
    8000349c:	b6860613          	addi	a2,a2,-1176 # 80008000 <_trampoline>
    800034a0:	00005697          	auipc	a3,0x5
    800034a4:	b6068693          	addi	a3,a3,-1184 # 80008000 <_trampoline>
    800034a8:	8e91                	sub	a3,a3,a2
    800034aa:	040007b7          	lui	a5,0x4000
    800034ae:	17fd                	addi	a5,a5,-1
    800034b0:	07b2                	slli	a5,a5,0xc
    800034b2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800034b4:	10569073          	csrw	stvec,a3
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    800034b8:	64b8                	ld	a4,72(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800034ba:	180026f3          	csrr	a3,satp
    800034be:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    800034c0:	64b8                	ld	a4,72(s1)
    800034c2:	60b4                	ld	a3,64(s1)
    800034c4:	6585                	lui	a1,0x1
    800034c6:	96ae                	add	a3,a3,a1
    800034c8:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    800034ca:	64b8                	ld	a4,72(s1)
    800034cc:	00000697          	auipc	a3,0x0
    800034d0:	07668693          	addi	a3,a3,118 # 80003542 <usertrap>
    800034d4:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800034d6:	64b8                	ld	a4,72(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    800034d8:	8692                	mv	a3,tp
    800034da:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800034dc:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800034e0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800034e4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800034e8:	10069073          	csrw	sstatus,a3
  w_sepc(t->trapframe->epc);
    800034ec:	64b8                	ld	a4,72(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800034ee:	6f18                	ld	a4,24(a4)
    800034f0:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    800034f4:	04093583          	ld	a1,64(s2)
    800034f8:	81b1                	srli	a1,a1,0xc
  int t_index = (int) (t - p->threads);
    800034fa:	0e090513          	addi	a0,s2,224
    800034fe:	40a48533          	sub	a0,s1,a0
    80003502:	850d                	srai	a0,a0,0x3
  ((void (*)(uint64,uint64))fn)(TRAPFRAME+(t_index * sizeof(struct trapframe)), satp);
    80003504:	00006497          	auipc	s1,0x6
    80003508:	b044b483          	ld	s1,-1276(s1) # 80009008 <etext+0x8>
    8000350c:	0295053b          	mulw	a0,a0,s1
    80003510:	00351493          	slli	s1,a0,0x3
    80003514:	9526                	add	a0,a0,s1
    80003516:	0516                	slli	a0,a0,0x5
    80003518:	020006b7          	lui	a3,0x2000
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000351c:	00005717          	auipc	a4,0x5
    80003520:	b7470713          	addi	a4,a4,-1164 # 80008090 <userret>
    80003524:	8f11                	sub	a4,a4,a2
    80003526:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME+(t_index * sizeof(struct trapframe)), satp);
    80003528:	577d                	li	a4,-1
    8000352a:	177e                	slli	a4,a4,0x3f
    8000352c:	8dd9                	or	a1,a1,a4
    8000352e:	16fd                	addi	a3,a3,-1
    80003530:	06b6                	slli	a3,a3,0xd
    80003532:	9536                	add	a0,a0,a3
    80003534:	9782                	jalr	a5
}
    80003536:	60e2                	ld	ra,24(sp)
    80003538:	6442                	ld	s0,16(sp)
    8000353a:	64a2                	ld	s1,8(sp)
    8000353c:	6902                	ld	s2,0(sp)
    8000353e:	6105                	addi	sp,sp,32
    80003540:	8082                	ret

0000000080003542 <usertrap>:
{
    80003542:	1101                	addi	sp,sp,-32
    80003544:	ec06                	sd	ra,24(sp)
    80003546:	e822                	sd	s0,16(sp)
    80003548:	e426                	sd	s1,8(sp)
    8000354a:	e04a                	sd	s2,0(sp)
    8000354c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000354e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003552:	1007f793          	andi	a5,a5,256
    80003556:	e3ad                	bnez	a5,800035b8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003558:	00003797          	auipc	a5,0x3
    8000355c:	59878793          	addi	a5,a5,1432 # 80006af0 <kernelvec>
    80003560:	10579073          	csrw	stvec,a5
  struct thread *t = mythread();
    80003564:	ffffe097          	auipc	ra,0xffffe
    80003568:	40c080e7          	jalr	1036(ra) # 80001970 <mythread>
    8000356c:	84aa                	mv	s1,a0
  t->trapframe->epc = r_sepc();
    8000356e:	653c                	ld	a5,72(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003570:	14102773          	csrr	a4,sepc
    80003574:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003576:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000357a:	47a1                	li	a5,8
    8000357c:	04f71c63          	bne	a4,a5,800035d4 <usertrap+0x92>
    if(t->killed)
    80003580:	551c                	lw	a5,40(a0)
    80003582:	e3b9                	bnez	a5,800035c8 <usertrap+0x86>
    t->trapframe->epc += 4;
    80003584:	64b8                	ld	a4,72(s1)
    80003586:	6f1c                	ld	a5,24(a4)
    80003588:	0791                	addi	a5,a5,4
    8000358a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000358c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003590:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003594:	10079073          	csrw	sstatus,a5
    syscall();
    80003598:	00000097          	auipc	ra,0x0
    8000359c:	214080e7          	jalr	532(ra) # 800037ac <syscall>
  if(t->killed)
    800035a0:	549c                	lw	a5,40(s1)
    800035a2:	ebc1                	bnez	a5,80003632 <usertrap+0xf0>
  usertrapret();
    800035a4:	00000097          	auipc	ra,0x0
    800035a8:	ec2080e7          	jalr	-318(ra) # 80003466 <usertrapret>
}
    800035ac:	60e2                	ld	ra,24(sp)
    800035ae:	6442                	ld	s0,16(sp)
    800035b0:	64a2                	ld	s1,8(sp)
    800035b2:	6902                	ld	s2,0(sp)
    800035b4:	6105                	addi	sp,sp,32
    800035b6:	8082                	ret
    panic("usertrap: not from user mode");
    800035b8:	00006517          	auipc	a0,0x6
    800035bc:	f6050513          	addi	a0,a0,-160 # 80009518 <states.0+0xd8>
    800035c0:	ffffd097          	auipc	ra,0xffffd
    800035c4:	f6a080e7          	jalr	-150(ra) # 8000052a <panic>
      exit_thread(-1);
    800035c8:	557d                	li	a0,-1
    800035ca:	fffff097          	auipc	ra,0xfffff
    800035ce:	daa080e7          	jalr	-598(ra) # 80002374 <exit_thread>
    800035d2:	bf4d                	j	80003584 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800035d4:	00000097          	auipc	ra,0x0
    800035d8:	a72080e7          	jalr	-1422(ra) # 80003046 <devintr>
    800035dc:	892a                	mv	s2,a0
    800035de:	c501                	beqz	a0,800035e6 <usertrap+0xa4>
  if(t->killed)
    800035e0:	549c                	lw	a5,40(s1)
    800035e2:	c3a1                	beqz	a5,80003622 <usertrap+0xe0>
    800035e4:	a815                	j	80003618 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800035e6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p tid=%d\n", r_scause(), t->tid);
    800035ea:	5890                	lw	a2,48(s1)
    800035ec:	00006517          	auipc	a0,0x6
    800035f0:	f4c50513          	addi	a0,a0,-180 # 80009538 <states.0+0xf8>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	f80080e7          	jalr	-128(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800035fc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003600:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003604:	00006517          	auipc	a0,0x6
    80003608:	f6450513          	addi	a0,a0,-156 # 80009568 <states.0+0x128>
    8000360c:	ffffd097          	auipc	ra,0xffffd
    80003610:	f68080e7          	jalr	-152(ra) # 80000574 <printf>
    t->killed = 1;
    80003614:	4785                	li	a5,1
    80003616:	d49c                	sw	a5,40(s1)
    exit_thread(-1);
    80003618:	557d                	li	a0,-1
    8000361a:	fffff097          	auipc	ra,0xfffff
    8000361e:	d5a080e7          	jalr	-678(ra) # 80002374 <exit_thread>
  if(which_dev == 2)
    80003622:	4789                	li	a5,2
    80003624:	f8f910e3          	bne	s2,a5,800035a4 <usertrap+0x62>
    yield();
    80003628:	fffff097          	auipc	ra,0xfffff
    8000362c:	dc2080e7          	jalr	-574(ra) # 800023ea <yield>
    80003630:	bf95                	j	800035a4 <usertrap+0x62>
  int which_dev = 0;
    80003632:	4901                	li	s2,0
    80003634:	b7d5                	j	80003618 <usertrap+0xd6>

0000000080003636 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003636:	1101                	addi	sp,sp,-32
    80003638:	ec06                	sd	ra,24(sp)
    8000363a:	e822                	sd	s0,16(sp)
    8000363c:	e426                	sd	s1,8(sp)
    8000363e:	1000                	addi	s0,sp,32
    80003640:	84aa                	mv	s1,a0
  struct thread *t = mythread();
    80003642:	ffffe097          	auipc	ra,0xffffe
    80003646:	32e080e7          	jalr	814(ra) # 80001970 <mythread>
  switch (n) {
    8000364a:	4795                	li	a5,5
    8000364c:	0497e163          	bltu	a5,s1,8000368e <argraw+0x58>
    80003650:	048a                	slli	s1,s1,0x2
    80003652:	00006717          	auipc	a4,0x6
    80003656:	f5e70713          	addi	a4,a4,-162 # 800095b0 <states.0+0x170>
    8000365a:	94ba                	add	s1,s1,a4
    8000365c:	409c                	lw	a5,0(s1)
    8000365e:	97ba                	add	a5,a5,a4
    80003660:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    80003662:	653c                	ld	a5,72(a0)
    80003664:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003666:	60e2                	ld	ra,24(sp)
    80003668:	6442                	ld	s0,16(sp)
    8000366a:	64a2                	ld	s1,8(sp)
    8000366c:	6105                	addi	sp,sp,32
    8000366e:	8082                	ret
    return t->trapframe->a1;
    80003670:	653c                	ld	a5,72(a0)
    80003672:	7fa8                	ld	a0,120(a5)
    80003674:	bfcd                	j	80003666 <argraw+0x30>
    return t->trapframe->a2;
    80003676:	653c                	ld	a5,72(a0)
    80003678:	63c8                	ld	a0,128(a5)
    8000367a:	b7f5                	j	80003666 <argraw+0x30>
    return t->trapframe->a3;
    8000367c:	653c                	ld	a5,72(a0)
    8000367e:	67c8                	ld	a0,136(a5)
    80003680:	b7dd                	j	80003666 <argraw+0x30>
    return t->trapframe->a4;
    80003682:	653c                	ld	a5,72(a0)
    80003684:	6bc8                	ld	a0,144(a5)
    80003686:	b7c5                	j	80003666 <argraw+0x30>
    return t->trapframe->a5;
    80003688:	653c                	ld	a5,72(a0)
    8000368a:	6fc8                	ld	a0,152(a5)
    8000368c:	bfe9                	j	80003666 <argraw+0x30>
  panic("argraw");
    8000368e:	00006517          	auipc	a0,0x6
    80003692:	efa50513          	addi	a0,a0,-262 # 80009588 <states.0+0x148>
    80003696:	ffffd097          	auipc	ra,0xffffd
    8000369a:	e94080e7          	jalr	-364(ra) # 8000052a <panic>

000000008000369e <fetchaddr>:
{
    8000369e:	1101                	addi	sp,sp,-32
    800036a0:	ec06                	sd	ra,24(sp)
    800036a2:	e822                	sd	s0,16(sp)
    800036a4:	e426                	sd	s1,8(sp)
    800036a6:	e04a                	sd	s2,0(sp)
    800036a8:	1000                	addi	s0,sp,32
    800036aa:	84aa                	mv	s1,a0
    800036ac:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800036ae:	ffffe097          	auipc	ra,0xffffe
    800036b2:	546080e7          	jalr	1350(ra) # 80001bf4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800036b6:	7d1c                	ld	a5,56(a0)
    800036b8:	02f4f863          	bgeu	s1,a5,800036e8 <fetchaddr+0x4a>
    800036bc:	00848713          	addi	a4,s1,8
    800036c0:	02e7e663          	bltu	a5,a4,800036ec <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800036c4:	46a1                	li	a3,8
    800036c6:	8626                	mv	a2,s1
    800036c8:	85ca                	mv	a1,s2
    800036ca:	6128                	ld	a0,64(a0)
    800036cc:	ffffe097          	auipc	ra,0xffffe
    800036d0:	006080e7          	jalr	6(ra) # 800016d2 <copyin>
    800036d4:	00a03533          	snez	a0,a0
    800036d8:	40a00533          	neg	a0,a0
}
    800036dc:	60e2                	ld	ra,24(sp)
    800036de:	6442                	ld	s0,16(sp)
    800036e0:	64a2                	ld	s1,8(sp)
    800036e2:	6902                	ld	s2,0(sp)
    800036e4:	6105                	addi	sp,sp,32
    800036e6:	8082                	ret
    return -1;
    800036e8:	557d                	li	a0,-1
    800036ea:	bfcd                	j	800036dc <fetchaddr+0x3e>
    800036ec:	557d                	li	a0,-1
    800036ee:	b7fd                	j	800036dc <fetchaddr+0x3e>

00000000800036f0 <fetchstr>:
{
    800036f0:	7179                	addi	sp,sp,-48
    800036f2:	f406                	sd	ra,40(sp)
    800036f4:	f022                	sd	s0,32(sp)
    800036f6:	ec26                	sd	s1,24(sp)
    800036f8:	e84a                	sd	s2,16(sp)
    800036fa:	e44e                	sd	s3,8(sp)
    800036fc:	1800                	addi	s0,sp,48
    800036fe:	892a                	mv	s2,a0
    80003700:	84ae                	mv	s1,a1
    80003702:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003704:	ffffe097          	auipc	ra,0xffffe
    80003708:	4f0080e7          	jalr	1264(ra) # 80001bf4 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    8000370c:	86ce                	mv	a3,s3
    8000370e:	864a                	mv	a2,s2
    80003710:	85a6                	mv	a1,s1
    80003712:	6128                	ld	a0,64(a0)
    80003714:	ffffe097          	auipc	ra,0xffffe
    80003718:	04c080e7          	jalr	76(ra) # 80001760 <copyinstr>
  if(err < 0)
    8000371c:	00054763          	bltz	a0,8000372a <fetchstr+0x3a>
  return strlen(buf);
    80003720:	8526                	mv	a0,s1
    80003722:	ffffd097          	auipc	ra,0xffffd
    80003726:	720080e7          	jalr	1824(ra) # 80000e42 <strlen>
}
    8000372a:	70a2                	ld	ra,40(sp)
    8000372c:	7402                	ld	s0,32(sp)
    8000372e:	64e2                	ld	s1,24(sp)
    80003730:	6942                	ld	s2,16(sp)
    80003732:	69a2                	ld	s3,8(sp)
    80003734:	6145                	addi	sp,sp,48
    80003736:	8082                	ret

0000000080003738 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003738:	1101                	addi	sp,sp,-32
    8000373a:	ec06                	sd	ra,24(sp)
    8000373c:	e822                	sd	s0,16(sp)
    8000373e:	e426                	sd	s1,8(sp)
    80003740:	1000                	addi	s0,sp,32
    80003742:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003744:	00000097          	auipc	ra,0x0
    80003748:	ef2080e7          	jalr	-270(ra) # 80003636 <argraw>
    8000374c:	c088                	sw	a0,0(s1)
  return 0;
}
    8000374e:	4501                	li	a0,0
    80003750:	60e2                	ld	ra,24(sp)
    80003752:	6442                	ld	s0,16(sp)
    80003754:	64a2                	ld	s1,8(sp)
    80003756:	6105                	addi	sp,sp,32
    80003758:	8082                	ret

000000008000375a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000375a:	1101                	addi	sp,sp,-32
    8000375c:	ec06                	sd	ra,24(sp)
    8000375e:	e822                	sd	s0,16(sp)
    80003760:	e426                	sd	s1,8(sp)
    80003762:	1000                	addi	s0,sp,32
    80003764:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003766:	00000097          	auipc	ra,0x0
    8000376a:	ed0080e7          	jalr	-304(ra) # 80003636 <argraw>
    8000376e:	e088                	sd	a0,0(s1)
  return 0;
}
    80003770:	4501                	li	a0,0
    80003772:	60e2                	ld	ra,24(sp)
    80003774:	6442                	ld	s0,16(sp)
    80003776:	64a2                	ld	s1,8(sp)
    80003778:	6105                	addi	sp,sp,32
    8000377a:	8082                	ret

000000008000377c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000377c:	1101                	addi	sp,sp,-32
    8000377e:	ec06                	sd	ra,24(sp)
    80003780:	e822                	sd	s0,16(sp)
    80003782:	e426                	sd	s1,8(sp)
    80003784:	e04a                	sd	s2,0(sp)
    80003786:	1000                	addi	s0,sp,32
    80003788:	84ae                	mv	s1,a1
    8000378a:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000378c:	00000097          	auipc	ra,0x0
    80003790:	eaa080e7          	jalr	-342(ra) # 80003636 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003794:	864a                	mv	a2,s2
    80003796:	85a6                	mv	a1,s1
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	f58080e7          	jalr	-168(ra) # 800036f0 <fetchstr>
}
    800037a0:	60e2                	ld	ra,24(sp)
    800037a2:	6442                	ld	s0,16(sp)
    800037a4:	64a2                	ld	s1,8(sp)
    800037a6:	6902                	ld	s2,0(sp)
    800037a8:	6105                	addi	sp,sp,32
    800037aa:	8082                	ret

00000000800037ac <syscall>:
[SYS_print_ptable]        sys_print_ptable,
};

void
syscall(void)
{
    800037ac:	1101                	addi	sp,sp,-32
    800037ae:	ec06                	sd	ra,24(sp)
    800037b0:	e822                	sd	s0,16(sp)
    800037b2:	e426                	sd	s1,8(sp)
    800037b4:	e04a                	sd	s2,0(sp)
    800037b6:	1000                	addi	s0,sp,32
  int num;
  struct thread *t = mythread();
    800037b8:	ffffe097          	auipc	ra,0xffffe
    800037bc:	1b8080e7          	jalr	440(ra) # 80001970 <mythread>
    800037c0:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    800037c2:	04853903          	ld	s2,72(a0)
    800037c6:	0a893783          	ld	a5,168(s2)
    800037ca:	0007861b          	sext.w	a2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800037ce:	37fd                	addiw	a5,a5,-1
    800037d0:	02400713          	li	a4,36
    800037d4:	00f76f63          	bltu	a4,a5,800037f2 <syscall+0x46>
    800037d8:	00361713          	slli	a4,a2,0x3
    800037dc:	00006797          	auipc	a5,0x6
    800037e0:	dec78793          	addi	a5,a5,-532 # 800095c8 <syscalls>
    800037e4:	97ba                	add	a5,a5,a4
    800037e6:	639c                	ld	a5,0(a5)
    800037e8:	c789                	beqz	a5,800037f2 <syscall+0x46>
    t->trapframe->a0 = syscalls[num]();
    800037ea:	9782                	jalr	a5
    800037ec:	06a93823          	sd	a0,112(s2)
    800037f0:	a829                	j	8000380a <syscall+0x5e>
  } else {
    printf("%d: unknown sys call %d\n",
    800037f2:	588c                	lw	a1,48(s1)
    800037f4:	00006517          	auipc	a0,0x6
    800037f8:	d9c50513          	addi	a0,a0,-612 # 80009590 <states.0+0x150>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	d78080e7          	jalr	-648(ra) # 80000574 <printf>
            t->tid, num);
    t->trapframe->a0 = -1;
    80003804:	64bc                	ld	a5,72(s1)
    80003806:	577d                	li	a4,-1
    80003808:	fbb8                	sd	a4,112(a5)
  }
}
    8000380a:	60e2                	ld	ra,24(sp)
    8000380c:	6442                	ld	s0,16(sp)
    8000380e:	64a2                	ld	s1,8(sp)
    80003810:	6902                	ld	s2,0(sp)
    80003812:	6105                	addi	sp,sp,32
    80003814:	8082                	ret

0000000080003816 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003816:	1101                	addi	sp,sp,-32
    80003818:	ec06                	sd	ra,24(sp)
    8000381a:	e822                	sd	s0,16(sp)
    8000381c:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8000381e:	fec40593          	addi	a1,s0,-20
    80003822:	4501                	li	a0,0
    80003824:	00000097          	auipc	ra,0x0
    80003828:	f14080e7          	jalr	-236(ra) # 80003738 <argint>
    return -1;
    8000382c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000382e:	00054963          	bltz	a0,80003840 <sys_exit+0x2a>
  exit(n);
    80003832:	fec42503          	lw	a0,-20(s0)
    80003836:	fffff097          	auipc	ra,0xfffff
    8000383a:	e6a080e7          	jalr	-406(ra) # 800026a0 <exit>
  return 0;  // not reached
    8000383e:	4781                	li	a5,0
}
    80003840:	853e                	mv	a0,a5
    80003842:	60e2                	ld	ra,24(sp)
    80003844:	6442                	ld	s0,16(sp)
    80003846:	6105                	addi	sp,sp,32
    80003848:	8082                	ret

000000008000384a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000384a:	1141                	addi	sp,sp,-16
    8000384c:	e406                	sd	ra,8(sp)
    8000384e:	e022                	sd	s0,0(sp)
    80003850:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003852:	ffffe097          	auipc	ra,0xffffe
    80003856:	3a2080e7          	jalr	930(ra) # 80001bf4 <myproc>
}
    8000385a:	5148                	lw	a0,36(a0)
    8000385c:	60a2                	ld	ra,8(sp)
    8000385e:	6402                	ld	s0,0(sp)
    80003860:	0141                	addi	sp,sp,16
    80003862:	8082                	ret

0000000080003864 <sys_fork>:

uint64
sys_fork(void)
{
    80003864:	1141                	addi	sp,sp,-16
    80003866:	e406                	sd	ra,8(sp)
    80003868:	e022                	sd	s0,0(sp)
    8000386a:	0800                	addi	s0,sp,16
  return fork();
    8000386c:	ffffe097          	auipc	ra,0xffffe
    80003870:	7f8080e7          	jalr	2040(ra) # 80002064 <fork>
}
    80003874:	60a2                	ld	ra,8(sp)
    80003876:	6402                	ld	s0,0(sp)
    80003878:	0141                	addi	sp,sp,16
    8000387a:	8082                	ret

000000008000387c <sys_wait>:

uint64
sys_wait(void)
{
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003884:	fe840593          	addi	a1,s0,-24
    80003888:	4501                	li	a0,0
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	ed0080e7          	jalr	-304(ra) # 8000375a <argaddr>
    80003892:	87aa                	mv	a5,a0
    return -1;
    80003894:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003896:	0007c863          	bltz	a5,800038a6 <sys_wait+0x2a>
  return wait(p);
    8000389a:	fe843503          	ld	a0,-24(s0)
    8000389e:	fffff097          	auipc	ra,0xfffff
    800038a2:	bec080e7          	jalr	-1044(ra) # 8000248a <wait>
}
    800038a6:	60e2                	ld	ra,24(sp)
    800038a8:	6442                	ld	s0,16(sp)
    800038aa:	6105                	addi	sp,sp,32
    800038ac:	8082                	ret

00000000800038ae <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800038ae:	7179                	addi	sp,sp,-48
    800038b0:	f406                	sd	ra,40(sp)
    800038b2:	f022                	sd	s0,32(sp)
    800038b4:	ec26                	sd	s1,24(sp)
    800038b6:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800038b8:	fdc40593          	addi	a1,s0,-36
    800038bc:	4501                	li	a0,0
    800038be:	00000097          	auipc	ra,0x0
    800038c2:	e7a080e7          	jalr	-390(ra) # 80003738 <argint>
    return -1;
    800038c6:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800038c8:	00054f63          	bltz	a0,800038e6 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800038cc:	ffffe097          	auipc	ra,0xffffe
    800038d0:	328080e7          	jalr	808(ra) # 80001bf4 <myproc>
    800038d4:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    800038d6:	fdc42503          	lw	a0,-36(s0)
    800038da:	ffffe097          	auipc	ra,0xffffe
    800038de:	716080e7          	jalr	1814(ra) # 80001ff0 <growproc>
    800038e2:	00054863          	bltz	a0,800038f2 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800038e6:	8526                	mv	a0,s1
    800038e8:	70a2                	ld	ra,40(sp)
    800038ea:	7402                	ld	s0,32(sp)
    800038ec:	64e2                	ld	s1,24(sp)
    800038ee:	6145                	addi	sp,sp,48
    800038f0:	8082                	ret
    return -1;
    800038f2:	54fd                	li	s1,-1
    800038f4:	bfcd                	j	800038e6 <sys_sbrk+0x38>

00000000800038f6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800038f6:	7139                	addi	sp,sp,-64
    800038f8:	fc06                	sd	ra,56(sp)
    800038fa:	f822                	sd	s0,48(sp)
    800038fc:	f426                	sd	s1,40(sp)
    800038fe:	f04a                	sd	s2,32(sp)
    80003900:	ec4e                	sd	s3,24(sp)
    80003902:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003904:	fcc40593          	addi	a1,s0,-52
    80003908:	4501                	li	a0,0
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	e2e080e7          	jalr	-466(ra) # 80003738 <argint>
    return -1;
    80003912:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003914:	06054563          	bltz	a0,8000397e <sys_sleep+0x88>
  acquire(&tickslock);
    80003918:	00033517          	auipc	a0,0x33
    8000391c:	fd050513          	addi	a0,a0,-48 # 800368e8 <tickslock>
    80003920:	ffffd097          	auipc	ra,0xffffd
    80003924:	2a2080e7          	jalr	674(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003928:	00006917          	auipc	s2,0x6
    8000392c:	70892903          	lw	s2,1800(s2) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    80003930:	fcc42783          	lw	a5,-52(s0)
    80003934:	cf85                	beqz	a5,8000396c <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003936:	00033997          	auipc	s3,0x33
    8000393a:	fb298993          	addi	s3,s3,-78 # 800368e8 <tickslock>
    8000393e:	00006497          	auipc	s1,0x6
    80003942:	6f248493          	addi	s1,s1,1778 # 8000a030 <ticks>
    if(myproc()->killed){
    80003946:	ffffe097          	auipc	ra,0xffffe
    8000394a:	2ae080e7          	jalr	686(ra) # 80001bf4 <myproc>
    8000394e:	4d5c                	lw	a5,28(a0)
    80003950:	ef9d                	bnez	a5,8000398e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003952:	85ce                	mv	a1,s3
    80003954:	8526                	mv	a0,s1
    80003956:	fffff097          	auipc	ra,0xfffff
    8000395a:	ad0080e7          	jalr	-1328(ra) # 80002426 <sleep>
  while(ticks - ticks0 < n){
    8000395e:	409c                	lw	a5,0(s1)
    80003960:	412787bb          	subw	a5,a5,s2
    80003964:	fcc42703          	lw	a4,-52(s0)
    80003968:	fce7efe3          	bltu	a5,a4,80003946 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000396c:	00033517          	auipc	a0,0x33
    80003970:	f7c50513          	addi	a0,a0,-132 # 800368e8 <tickslock>
    80003974:	ffffd097          	auipc	ra,0xffffd
    80003978:	302080e7          	jalr	770(ra) # 80000c76 <release>
  return 0;
    8000397c:	4781                	li	a5,0
}
    8000397e:	853e                	mv	a0,a5
    80003980:	70e2                	ld	ra,56(sp)
    80003982:	7442                	ld	s0,48(sp)
    80003984:	74a2                	ld	s1,40(sp)
    80003986:	7902                	ld	s2,32(sp)
    80003988:	69e2                	ld	s3,24(sp)
    8000398a:	6121                	addi	sp,sp,64
    8000398c:	8082                	ret
      release(&tickslock);
    8000398e:	00033517          	auipc	a0,0x33
    80003992:	f5a50513          	addi	a0,a0,-166 # 800368e8 <tickslock>
    80003996:	ffffd097          	auipc	ra,0xffffd
    8000399a:	2e0080e7          	jalr	736(ra) # 80000c76 <release>
      return -1;
    8000399e:	57fd                	li	a5,-1
    800039a0:	bff9                	j	8000397e <sys_sleep+0x88>

00000000800039a2 <sys_kill>:

uint64
sys_kill(void)
{
    800039a2:	1101                	addi	sp,sp,-32
    800039a4:	ec06                	sd	ra,24(sp)
    800039a6:	e822                	sd	s0,16(sp)
    800039a8:	1000                	addi	s0,sp,32
  int pid;
  int signum; 

  if((argint(0, &pid) < 0) || (argint(1, &signum) < 0))
    800039aa:	fec40593          	addi	a1,s0,-20
    800039ae:	4501                	li	a0,0
    800039b0:	00000097          	auipc	ra,0x0
    800039b4:	d88080e7          	jalr	-632(ra) # 80003738 <argint>
    return -1;
    800039b8:	57fd                	li	a5,-1
  if((argint(0, &pid) < 0) || (argint(1, &signum) < 0))
    800039ba:	02054563          	bltz	a0,800039e4 <sys_kill+0x42>
    800039be:	fe840593          	addi	a1,s0,-24
    800039c2:	4505                	li	a0,1
    800039c4:	00000097          	auipc	ra,0x0
    800039c8:	d74080e7          	jalr	-652(ra) # 80003738 <argint>
    return -1;
    800039cc:	57fd                	li	a5,-1
  if((argint(0, &pid) < 0) || (argint(1, &signum) < 0))
    800039ce:	00054b63          	bltz	a0,800039e4 <sys_kill+0x42>
  return kill(pid,signum);
    800039d2:	fe842583          	lw	a1,-24(s0)
    800039d6:	fec42503          	lw	a0,-20(s0)
    800039da:	fffff097          	auipc	ra,0xfffff
    800039de:	dcc080e7          	jalr	-564(ra) # 800027a6 <kill>
    800039e2:	87aa                	mv	a5,a0
}
    800039e4:	853e                	mv	a0,a5
    800039e6:	60e2                	ld	ra,24(sp)
    800039e8:	6442                	ld	s0,16(sp)
    800039ea:	6105                	addi	sp,sp,32
    800039ec:	8082                	ret

00000000800039ee <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800039ee:	1101                	addi	sp,sp,-32
    800039f0:	ec06                	sd	ra,24(sp)
    800039f2:	e822                	sd	s0,16(sp)
    800039f4:	e426                	sd	s1,8(sp)
    800039f6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800039f8:	00033517          	auipc	a0,0x33
    800039fc:	ef050513          	addi	a0,a0,-272 # 800368e8 <tickslock>
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	1c2080e7          	jalr	450(ra) # 80000bc2 <acquire>
  xticks = ticks;
    80003a08:	00006497          	auipc	s1,0x6
    80003a0c:	6284a483          	lw	s1,1576(s1) # 8000a030 <ticks>
  release(&tickslock);
    80003a10:	00033517          	auipc	a0,0x33
    80003a14:	ed850513          	addi	a0,a0,-296 # 800368e8 <tickslock>
    80003a18:	ffffd097          	auipc	ra,0xffffd
    80003a1c:	25e080e7          	jalr	606(ra) # 80000c76 <release>
  return xticks;
}
    80003a20:	02049513          	slli	a0,s1,0x20
    80003a24:	9101                	srli	a0,a0,0x20
    80003a26:	60e2                	ld	ra,24(sp)
    80003a28:	6442                	ld	s0,16(sp)
    80003a2a:	64a2                	ld	s1,8(sp)
    80003a2c:	6105                	addi	sp,sp,32
    80003a2e:	8082                	ret

0000000080003a30 <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003a30:	1101                	addi	sp,sp,-32
    80003a32:	ec06                	sd	ra,24(sp)
    80003a34:	e822                	sd	s0,16(sp)
    80003a36:	1000                	addi	s0,sp,32
  int sigmask;
  if(argint(0, &sigmask) < 0)
    80003a38:	fec40593          	addi	a1,s0,-20
    80003a3c:	4501                	li	a0,0
    80003a3e:	00000097          	auipc	ra,0x0
    80003a42:	cfa080e7          	jalr	-774(ra) # 80003738 <argint>
    80003a46:	87aa                	mv	a5,a0
    return -1;
    80003a48:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003a4a:	0007ca63          	bltz	a5,80003a5e <sys_sigprocmask+0x2e>
  return sigprocmask(sigmask);
    80003a4e:	fec42503          	lw	a0,-20(s0)
    80003a52:	fffff097          	auipc	ra,0xfffff
    80003a56:	f38080e7          	jalr	-200(ra) # 8000298a <sigprocmask>
    80003a5a:	1502                	slli	a0,a0,0x20
    80003a5c:	9101                	srli	a0,a0,0x20
}
    80003a5e:	60e2                	ld	ra,24(sp)
    80003a60:	6442                	ld	s0,16(sp)
    80003a62:	6105                	addi	sp,sp,32
    80003a64:	8082                	ret

0000000080003a66 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003a66:	7179                	addi	sp,sp,-48
    80003a68:	f406                	sd	ra,40(sp)
    80003a6a:	f022                	sd	s0,32(sp)
    80003a6c:	1800                	addi	s0,sp,48
  int signum;
  uint64 new_act, old_act;

  if( (argint(0, &signum) < 0) || (argaddr(1, &new_act) < 0) ||(argaddr(2, &old_act) < 0 ))
    80003a6e:	fec40593          	addi	a1,s0,-20
    80003a72:	4501                	li	a0,0
    80003a74:	00000097          	auipc	ra,0x0
    80003a78:	cc4080e7          	jalr	-828(ra) # 80003738 <argint>
    return -1;
    80003a7c:	57fd                	li	a5,-1
  if( (argint(0, &signum) < 0) || (argaddr(1, &new_act) < 0) ||(argaddr(2, &old_act) < 0 ))
    80003a7e:	04054163          	bltz	a0,80003ac0 <sys_sigaction+0x5a>
    80003a82:	fe040593          	addi	a1,s0,-32
    80003a86:	4505                	li	a0,1
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	cd2080e7          	jalr	-814(ra) # 8000375a <argaddr>
    return -1;
    80003a90:	57fd                	li	a5,-1
  if( (argint(0, &signum) < 0) || (argaddr(1, &new_act) < 0) ||(argaddr(2, &old_act) < 0 ))
    80003a92:	02054763          	bltz	a0,80003ac0 <sys_sigaction+0x5a>
    80003a96:	fd840593          	addi	a1,s0,-40
    80003a9a:	4509                	li	a0,2
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	cbe080e7          	jalr	-834(ra) # 8000375a <argaddr>
    return -1;
    80003aa4:	57fd                	li	a5,-1
  if( (argint(0, &signum) < 0) || (argaddr(1, &new_act) < 0) ||(argaddr(2, &old_act) < 0 ))
    80003aa6:	00054d63          	bltz	a0,80003ac0 <sys_sigaction+0x5a>
  return sigaction(signum, new_act, old_act);
    80003aaa:	fd843603          	ld	a2,-40(s0)
    80003aae:	fe043583          	ld	a1,-32(s0)
    80003ab2:	fec42503          	lw	a0,-20(s0)
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	efc080e7          	jalr	-260(ra) # 800029b2 <sigaction>
    80003abe:	87aa                	mv	a5,a0
}
    80003ac0:	853e                	mv	a0,a5
    80003ac2:	70a2                	ld	ra,40(sp)
    80003ac4:	7402                	ld	s0,32(sp)
    80003ac6:	6145                	addi	sp,sp,48
    80003ac8:	8082                	ret

0000000080003aca <sys_sigret>:

uint64
sys_sigret(void)
{
    80003aca:	1141                	addi	sp,sp,-16
    80003acc:	e406                	sd	ra,8(sp)
    80003ace:	e022                	sd	s0,0(sp)
    80003ad0:	0800                	addi	s0,sp,16
  sigret();
    80003ad2:	fffff097          	auipc	ra,0xfffff
    80003ad6:	fa8080e7          	jalr	-88(ra) # 80002a7a <sigret>
  return 0;
}
    80003ada:	4501                	li	a0,0
    80003adc:	60a2                	ld	ra,8(sp)
    80003ade:	6402                	ld	s0,0(sp)
    80003ae0:	0141                	addi	sp,sp,16
    80003ae2:	8082                	ret

0000000080003ae4 <sys_kthread_create>:
uint64 sys_kthread_create(void)
{
    80003ae4:	1101                	addi	sp,sp,-32
    80003ae6:	ec06                	sd	ra,24(sp)
    80003ae8:	e822                	sd	s0,16(sp)
    80003aea:	1000                	addi	s0,sp,32
  uint64 start_func,stack;

  if(argaddr(0, &start_func) < 0|| argaddr(1, &stack) < 0)
    80003aec:	fe840593          	addi	a1,s0,-24
    80003af0:	4501                	li	a0,0
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	c68080e7          	jalr	-920(ra) # 8000375a <argaddr>
  {
    return -1;
    80003afa:	57fd                	li	a5,-1
  if(argaddr(0, &start_func) < 0|| argaddr(1, &stack) < 0)
    80003afc:	02054563          	bltz	a0,80003b26 <sys_kthread_create+0x42>
    80003b00:	fe040593          	addi	a1,s0,-32
    80003b04:	4505                	li	a0,1
    80003b06:	00000097          	auipc	ra,0x0
    80003b0a:	c54080e7          	jalr	-940(ra) # 8000375a <argaddr>
    return -1;
    80003b0e:	57fd                	li	a5,-1
  if(argaddr(0, &start_func) < 0|| argaddr(1, &stack) < 0)
    80003b10:	00054b63          	bltz	a0,80003b26 <sys_kthread_create+0x42>
  }
  return kthread_create(start_func, stack);
    80003b14:	fe043583          	ld	a1,-32(s0)
    80003b18:	fe843503          	ld	a0,-24(s0)
    80003b1c:	fffff097          	auipc	ra,0xfffff
    80003b20:	faa080e7          	jalr	-86(ra) # 80002ac6 <kthread_create>
    80003b24:	87aa                	mv	a5,a0
}
    80003b26:	853e                	mv	a0,a5
    80003b28:	60e2                	ld	ra,24(sp)
    80003b2a:	6442                	ld	s0,16(sp)
    80003b2c:	6105                	addi	sp,sp,32
    80003b2e:	8082                	ret

0000000080003b30 <sys_kthread_id>:

uint64 sys_kthread_id(void)
{
    80003b30:	1141                	addi	sp,sp,-16
    80003b32:	e406                	sd	ra,8(sp)
    80003b34:	e022                	sd	s0,0(sp)
    80003b36:	0800                	addi	s0,sp,16
  return kthread_id();
    80003b38:	fffff097          	auipc	ra,0xfffff
    80003b3c:	034080e7          	jalr	52(ra) # 80002b6c <kthread_id>
}
    80003b40:	60a2                	ld	ra,8(sp)
    80003b42:	6402                	ld	s0,0(sp)
    80003b44:	0141                	addi	sp,sp,16
    80003b46:	8082                	ret

0000000080003b48 <sys_kthread_exit>:
uint64 sys_kthread_exit(void)
{
    80003b48:	1101                	addi	sp,sp,-32
    80003b4a:	ec06                	sd	ra,24(sp)
    80003b4c:	e822                	sd	s0,16(sp)
    80003b4e:	1000                	addi	s0,sp,32
  int status;

  if(argint(0, &status) < 0)
    80003b50:	fec40593          	addi	a1,s0,-20
    80003b54:	4501                	li	a0,0
    80003b56:	00000097          	auipc	ra,0x0
    80003b5a:	be2080e7          	jalr	-1054(ra) # 80003738 <argint>
    80003b5e:	87aa                	mv	a5,a0
  {
    return -1;
    80003b60:	557d                	li	a0,-1
  if(argint(0, &status) < 0)
    80003b62:	0007c863          	bltz	a5,80003b72 <sys_kthread_exit+0x2a>
  }
  return kthread_exit(status);
    80003b66:	fec42503          	lw	a0,-20(s0)
    80003b6a:	fffff097          	auipc	ra,0xfffff
    80003b6e:	01c080e7          	jalr	28(ra) # 80002b86 <kthread_exit>
}
    80003b72:	60e2                	ld	ra,24(sp)
    80003b74:	6442                	ld	s0,16(sp)
    80003b76:	6105                	addi	sp,sp,32
    80003b78:	8082                	ret

0000000080003b7a <sys_kthread_join>:
uint64 sys_kthread_join(void)
{
    80003b7a:	1101                	addi	sp,sp,-32
    80003b7c:	ec06                	sd	ra,24(sp)
    80003b7e:	e822                	sd	s0,16(sp)
    80003b80:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0 || argaddr(1, &status) < 0)
    80003b82:	fec40593          	addi	a1,s0,-20
    80003b86:	4501                	li	a0,0
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	bb0080e7          	jalr	-1104(ra) # 80003738 <argint>
  {
    return -1;
    80003b90:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0 || argaddr(1, &status) < 0)
    80003b92:	02054563          	bltz	a0,80003bbc <sys_kthread_join+0x42>
    80003b96:	fe040593          	addi	a1,s0,-32
    80003b9a:	4505                	li	a0,1
    80003b9c:	00000097          	auipc	ra,0x0
    80003ba0:	bbe080e7          	jalr	-1090(ra) # 8000375a <argaddr>
    return -1;
    80003ba4:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0 || argaddr(1, &status) < 0)
    80003ba6:	00054b63          	bltz	a0,80003bbc <sys_kthread_join+0x42>
  }
  return kthread_join(thread_id, status);
    80003baa:	fe043583          	ld	a1,-32(s0)
    80003bae:	fec42503          	lw	a0,-20(s0)
    80003bb2:	fffff097          	auipc	ra,0xfffff
    80003bb6:	ff6080e7          	jalr	-10(ra) # 80002ba8 <kthread_join>
    80003bba:	87aa                	mv	a5,a0
}
    80003bbc:	853e                	mv	a0,a5
    80003bbe:	60e2                	ld	ra,24(sp)
    80003bc0:	6442                	ld	s0,16(sp)
    80003bc2:	6105                	addi	sp,sp,32
    80003bc4:	8082                	ret

0000000080003bc6 <sys_print_ptable>:

uint64
sys_print_ptable(void)
{
    80003bc6:	1141                	addi	sp,sp,-16
    80003bc8:	e406                	sd	ra,8(sp)
    80003bca:	e022                	sd	s0,0(sp)
    80003bcc:	0800                	addi	s0,sp,16
  print_ptable();
    80003bce:	fffff097          	auipc	ra,0xfffff
    80003bd2:	1c0080e7          	jalr	448(ra) # 80002d8e <print_ptable>
  return 0;
}
    80003bd6:	4501                	li	a0,0
    80003bd8:	60a2                	ld	ra,8(sp)
    80003bda:	6402                	ld	s0,0(sp)
    80003bdc:	0141                	addi	sp,sp,16
    80003bde:	8082                	ret

0000000080003be0 <sys_bsem_alloc>:


uint64
sys_bsem_alloc(void)
{
    80003be0:	1141                	addi	sp,sp,-16
    80003be2:	e406                	sd	ra,8(sp)
    80003be4:	e022                	sd	s0,0(sp)
    80003be6:	0800                	addi	s0,sp,16
  return bsem_alloc();
    80003be8:	fffff097          	auipc	ra,0xfffff
    80003bec:	00e080e7          	jalr	14(ra) # 80002bf6 <bsem_alloc>
}
    80003bf0:	60a2                	ld	ra,8(sp)
    80003bf2:	6402                	ld	s0,0(sp)
    80003bf4:	0141                	addi	sp,sp,16
    80003bf6:	8082                	ret

0000000080003bf8 <sys_bsem_free>:

uint64
sys_bsem_free(void)
{
    80003bf8:	1101                	addi	sp,sp,-32
    80003bfa:	ec06                	sd	ra,24(sp)
    80003bfc:	e822                	sd	s0,16(sp)
    80003bfe:	1000                	addi	s0,sp,32

  int fd;
  if(argint(0, &fd) < 0)
    80003c00:	fec40593          	addi	a1,s0,-20
    80003c04:	4501                	li	a0,0
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	b32080e7          	jalr	-1230(ra) # 80003738 <argint>
  {
    return -1;
    80003c0e:	57fd                	li	a5,-1
  if(argint(0, &fd) < 0)
    80003c10:	00054963          	bltz	a0,80003c22 <sys_bsem_free+0x2a>
  }
  bsem_free(fd);
    80003c14:	fec42503          	lw	a0,-20(s0)
    80003c18:	fffff097          	auipc	ra,0xfffff
    80003c1c:	034080e7          	jalr	52(ra) # 80002c4c <bsem_free>
  return 0;
    80003c20:	4781                	li	a5,0
}
    80003c22:	853e                	mv	a0,a5
    80003c24:	60e2                	ld	ra,24(sp)
    80003c26:	6442                	ld	s0,16(sp)
    80003c28:	6105                	addi	sp,sp,32
    80003c2a:	8082                	ret

0000000080003c2c <sys_bsem_down>:

uint64
sys_bsem_down(void)
{
    80003c2c:	1101                	addi	sp,sp,-32
    80003c2e:	ec06                	sd	ra,24(sp)
    80003c30:	e822                	sd	s0,16(sp)
    80003c32:	1000                	addi	s0,sp,32
  int fd;
  if(argint(0, &fd) < 0)
    80003c34:	fec40593          	addi	a1,s0,-20
    80003c38:	4501                	li	a0,0
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	afe080e7          	jalr	-1282(ra) # 80003738 <argint>
  {
    return -1;
    80003c42:	57fd                	li	a5,-1
  if(argint(0, &fd) < 0)
    80003c44:	00054963          	bltz	a0,80003c56 <sys_bsem_down+0x2a>
  }
  bsem_down(fd);
    80003c48:	fec42503          	lw	a0,-20(s0)
    80003c4c:	fffff097          	auipc	ra,0xfffff
    80003c50:	03a080e7          	jalr	58(ra) # 80002c86 <bsem_down>
  return 0;
    80003c54:	4781                	li	a5,0
}
    80003c56:	853e                	mv	a0,a5
    80003c58:	60e2                	ld	ra,24(sp)
    80003c5a:	6442                	ld	s0,16(sp)
    80003c5c:	6105                	addi	sp,sp,32
    80003c5e:	8082                	ret

0000000080003c60 <sys_bsem_up>:

uint64
sys_bsem_up(void)
{
    80003c60:	1101                	addi	sp,sp,-32
    80003c62:	ec06                	sd	ra,24(sp)
    80003c64:	e822                	sd	s0,16(sp)
    80003c66:	1000                	addi	s0,sp,32
  int fd;
  if(argint(0, &fd) < 0)
    80003c68:	fec40593          	addi	a1,s0,-20
    80003c6c:	4501                	li	a0,0
    80003c6e:	00000097          	auipc	ra,0x0
    80003c72:	aca080e7          	jalr	-1334(ra) # 80003738 <argint>
  {
    return -1;
    80003c76:	57fd                	li	a5,-1
  if(argint(0, &fd) < 0)
    80003c78:	00054963          	bltz	a0,80003c8a <sys_bsem_up+0x2a>
  }
  bsem_up(fd);
    80003c7c:	fec42503          	lw	a0,-20(s0)
    80003c80:	fffff097          	auipc	ra,0xfffff
    80003c84:	06e080e7          	jalr	110(ra) # 80002cee <bsem_up>
  return 0;
    80003c88:	4781                	li	a5,0
}
    80003c8a:	853e                	mv	a0,a5
    80003c8c:	60e2                	ld	ra,24(sp)
    80003c8e:	6442                	ld	s0,16(sp)
    80003c90:	6105                	addi	sp,sp,32
    80003c92:	8082                	ret

0000000080003c94 <sys_csem_alloc>:


uint64
sys_csem_alloc(void)
{
    80003c94:	1101                	addi	sp,sp,-32
    80003c96:	ec06                	sd	ra,24(sp)
    80003c98:	e822                	sd	s0,16(sp)
    80003c9a:	1000                	addi	s0,sp,32
  uint64 sem;
  if(argaddr(0, &sem) < 0)
    80003c9c:	fe840593          	addi	a1,s0,-24
    80003ca0:	4501                	li	a0,0
    80003ca2:	00000097          	auipc	ra,0x0
    80003ca6:	ab8080e7          	jalr	-1352(ra) # 8000375a <argaddr>
    80003caa:	87aa                	mv	a5,a0
  {
    return -1;
    80003cac:	557d                	li	a0,-1
  if(argaddr(0, &sem) < 0)
    80003cae:	0007c863          	bltz	a5,80003cbe <sys_csem_alloc+0x2a>
  }
  return csem_alloc(sem);
    80003cb2:	fe843503          	ld	a0,-24(s0)
    80003cb6:	fffff097          	auipc	ra,0xfffff
    80003cba:	056080e7          	jalr	86(ra) # 80002d0c <csem_alloc>
}
    80003cbe:	60e2                	ld	ra,24(sp)
    80003cc0:	6442                	ld	s0,16(sp)
    80003cc2:	6105                	addi	sp,sp,32
    80003cc4:	8082                	ret

0000000080003cc6 <sys_csem_free>:

uint64
sys_csem_free(void)
{
    80003cc6:	1101                	addi	sp,sp,-32
    80003cc8:	ec06                	sd	ra,24(sp)
    80003cca:	e822                	sd	s0,16(sp)
    80003ccc:	1000                	addi	s0,sp,32
  uint64 sem;
  if(argaddr(0, &sem) < 0)
    80003cce:	fe840593          	addi	a1,s0,-24
    80003cd2:	4501                	li	a0,0
    80003cd4:	00000097          	auipc	ra,0x0
    80003cd8:	a86080e7          	jalr	-1402(ra) # 8000375a <argaddr>
  {
    return -1;
    80003cdc:	57fd                	li	a5,-1
  if(argaddr(0, &sem) < 0)
    80003cde:	00054963          	bltz	a0,80003cf0 <sys_csem_free+0x2a>
  }
  csem_free(sem);
    80003ce2:	fe843503          	ld	a0,-24(s0)
    80003ce6:	fffff097          	auipc	ra,0xfffff
    80003cea:	048080e7          	jalr	72(ra) # 80002d2e <csem_free>
  return 0;
    80003cee:	4781                	li	a5,0
}
    80003cf0:	853e                	mv	a0,a5
    80003cf2:	60e2                	ld	ra,24(sp)
    80003cf4:	6442                	ld	s0,16(sp)
    80003cf6:	6105                	addi	sp,sp,32
    80003cf8:	8082                	ret

0000000080003cfa <sys_csem_down>:

uint64
sys_csem_down(void)
{
    80003cfa:	1101                	addi	sp,sp,-32
    80003cfc:	ec06                	sd	ra,24(sp)
    80003cfe:	e822                	sd	s0,16(sp)
    80003d00:	1000                	addi	s0,sp,32
  uint64 sem;
  if(argaddr(0, &sem) < 0)
    80003d02:	fe840593          	addi	a1,s0,-24
    80003d06:	4501                	li	a0,0
    80003d08:	00000097          	auipc	ra,0x0
    80003d0c:	a52080e7          	jalr	-1454(ra) # 8000375a <argaddr>
  {
    return -1;
    80003d10:	57fd                	li	a5,-1
  if(argaddr(0, &sem) < 0)
    80003d12:	00054963          	bltz	a0,80003d24 <sys_csem_down+0x2a>
  }
  csem_down(sem);
    80003d16:	fe843503          	ld	a0,-24(s0)
    80003d1a:	fffff097          	auipc	ra,0xfffff
    80003d1e:	034080e7          	jalr	52(ra) # 80002d4e <csem_down>
  return 0;
    80003d22:	4781                	li	a5,0
}
    80003d24:	853e                	mv	a0,a5
    80003d26:	60e2                	ld	ra,24(sp)
    80003d28:	6442                	ld	s0,16(sp)
    80003d2a:	6105                	addi	sp,sp,32
    80003d2c:	8082                	ret

0000000080003d2e <sys_csem_up>:

uint64
sys_csem_up(void)
{
    80003d2e:	1101                	addi	sp,sp,-32
    80003d30:	ec06                	sd	ra,24(sp)
    80003d32:	e822                	sd	s0,16(sp)
    80003d34:	1000                	addi	s0,sp,32
  uint64 sem;
  if(argaddr(0, &sem) < 0)
    80003d36:	fe840593          	addi	a1,s0,-24
    80003d3a:	4501                	li	a0,0
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	a1e080e7          	jalr	-1506(ra) # 8000375a <argaddr>
  {
    return -1;
    80003d44:	57fd                	li	a5,-1
  if(argaddr(0, &sem) < 0)
    80003d46:	00054963          	bltz	a0,80003d58 <sys_csem_up+0x2a>
  }
  csem_up(sem);
    80003d4a:	fe843503          	ld	a0,-24(s0)
    80003d4e:	fffff097          	auipc	ra,0xfffff
    80003d52:	020080e7          	jalr	32(ra) # 80002d6e <csem_up>
  return 0;
    80003d56:	4781                	li	a5,0
}
    80003d58:	853e                	mv	a0,a5
    80003d5a:	60e2                	ld	ra,24(sp)
    80003d5c:	6442                	ld	s0,16(sp)
    80003d5e:	6105                	addi	sp,sp,32
    80003d60:	8082                	ret

0000000080003d62 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003d62:	7179                	addi	sp,sp,-48
    80003d64:	f406                	sd	ra,40(sp)
    80003d66:	f022                	sd	s0,32(sp)
    80003d68:	ec26                	sd	s1,24(sp)
    80003d6a:	e84a                	sd	s2,16(sp)
    80003d6c:	e44e                	sd	s3,8(sp)
    80003d6e:	e052                	sd	s4,0(sp)
    80003d70:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003d72:	00006597          	auipc	a1,0x6
    80003d76:	98658593          	addi	a1,a1,-1658 # 800096f8 <syscalls+0x130>
    80003d7a:	00033517          	auipc	a0,0x33
    80003d7e:	b8650513          	addi	a0,a0,-1146 # 80036900 <bcache>
    80003d82:	ffffd097          	auipc	ra,0xffffd
    80003d86:	db0080e7          	jalr	-592(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003d8a:	0003b797          	auipc	a5,0x3b
    80003d8e:	b7678793          	addi	a5,a5,-1162 # 8003e900 <bcache+0x8000>
    80003d92:	0003b717          	auipc	a4,0x3b
    80003d96:	dd670713          	addi	a4,a4,-554 # 8003eb68 <bcache+0x8268>
    80003d9a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003d9e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003da2:	00033497          	auipc	s1,0x33
    80003da6:	b7648493          	addi	s1,s1,-1162 # 80036918 <bcache+0x18>
    b->next = bcache.head.next;
    80003daa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003dac:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003dae:	00006a17          	auipc	s4,0x6
    80003db2:	952a0a13          	addi	s4,s4,-1710 # 80009700 <syscalls+0x138>
    b->next = bcache.head.next;
    80003db6:	2b893783          	ld	a5,696(s2)
    80003dba:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003dbc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003dc0:	85d2                	mv	a1,s4
    80003dc2:	01048513          	addi	a0,s1,16
    80003dc6:	00001097          	auipc	ra,0x1
    80003dca:	4c0080e7          	jalr	1216(ra) # 80005286 <initsleeplock>
    bcache.head.next->prev = b;
    80003dce:	2b893783          	ld	a5,696(s2)
    80003dd2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003dd4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003dd8:	45848493          	addi	s1,s1,1112
    80003ddc:	fd349de3          	bne	s1,s3,80003db6 <binit+0x54>
  }
}
    80003de0:	70a2                	ld	ra,40(sp)
    80003de2:	7402                	ld	s0,32(sp)
    80003de4:	64e2                	ld	s1,24(sp)
    80003de6:	6942                	ld	s2,16(sp)
    80003de8:	69a2                	ld	s3,8(sp)
    80003dea:	6a02                	ld	s4,0(sp)
    80003dec:	6145                	addi	sp,sp,48
    80003dee:	8082                	ret

0000000080003df0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003df0:	7179                	addi	sp,sp,-48
    80003df2:	f406                	sd	ra,40(sp)
    80003df4:	f022                	sd	s0,32(sp)
    80003df6:	ec26                	sd	s1,24(sp)
    80003df8:	e84a                	sd	s2,16(sp)
    80003dfa:	e44e                	sd	s3,8(sp)
    80003dfc:	1800                	addi	s0,sp,48
    80003dfe:	892a                	mv	s2,a0
    80003e00:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003e02:	00033517          	auipc	a0,0x33
    80003e06:	afe50513          	addi	a0,a0,-1282 # 80036900 <bcache>
    80003e0a:	ffffd097          	auipc	ra,0xffffd
    80003e0e:	db8080e7          	jalr	-584(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003e12:	0003b497          	auipc	s1,0x3b
    80003e16:	da64b483          	ld	s1,-602(s1) # 8003ebb8 <bcache+0x82b8>
    80003e1a:	0003b797          	auipc	a5,0x3b
    80003e1e:	d4e78793          	addi	a5,a5,-690 # 8003eb68 <bcache+0x8268>
    80003e22:	02f48f63          	beq	s1,a5,80003e60 <bread+0x70>
    80003e26:	873e                	mv	a4,a5
    80003e28:	a021                	j	80003e30 <bread+0x40>
    80003e2a:	68a4                	ld	s1,80(s1)
    80003e2c:	02e48a63          	beq	s1,a4,80003e60 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003e30:	449c                	lw	a5,8(s1)
    80003e32:	ff279ce3          	bne	a5,s2,80003e2a <bread+0x3a>
    80003e36:	44dc                	lw	a5,12(s1)
    80003e38:	ff3799e3          	bne	a5,s3,80003e2a <bread+0x3a>
      b->refcnt++;
    80003e3c:	40bc                	lw	a5,64(s1)
    80003e3e:	2785                	addiw	a5,a5,1
    80003e40:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003e42:	00033517          	auipc	a0,0x33
    80003e46:	abe50513          	addi	a0,a0,-1346 # 80036900 <bcache>
    80003e4a:	ffffd097          	auipc	ra,0xffffd
    80003e4e:	e2c080e7          	jalr	-468(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003e52:	01048513          	addi	a0,s1,16
    80003e56:	00001097          	auipc	ra,0x1
    80003e5a:	46a080e7          	jalr	1130(ra) # 800052c0 <acquiresleep>
      return b;
    80003e5e:	a8b9                	j	80003ebc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003e60:	0003b497          	auipc	s1,0x3b
    80003e64:	d504b483          	ld	s1,-688(s1) # 8003ebb0 <bcache+0x82b0>
    80003e68:	0003b797          	auipc	a5,0x3b
    80003e6c:	d0078793          	addi	a5,a5,-768 # 8003eb68 <bcache+0x8268>
    80003e70:	00f48863          	beq	s1,a5,80003e80 <bread+0x90>
    80003e74:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003e76:	40bc                	lw	a5,64(s1)
    80003e78:	cf81                	beqz	a5,80003e90 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003e7a:	64a4                	ld	s1,72(s1)
    80003e7c:	fee49de3          	bne	s1,a4,80003e76 <bread+0x86>
  panic("bget: no buffers");
    80003e80:	00006517          	auipc	a0,0x6
    80003e84:	88850513          	addi	a0,a0,-1912 # 80009708 <syscalls+0x140>
    80003e88:	ffffc097          	auipc	ra,0xffffc
    80003e8c:	6a2080e7          	jalr	1698(ra) # 8000052a <panic>
      b->dev = dev;
    80003e90:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003e94:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003e98:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003e9c:	4785                	li	a5,1
    80003e9e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003ea0:	00033517          	auipc	a0,0x33
    80003ea4:	a6050513          	addi	a0,a0,-1440 # 80036900 <bcache>
    80003ea8:	ffffd097          	auipc	ra,0xffffd
    80003eac:	dce080e7          	jalr	-562(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003eb0:	01048513          	addi	a0,s1,16
    80003eb4:	00001097          	auipc	ra,0x1
    80003eb8:	40c080e7          	jalr	1036(ra) # 800052c0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003ebc:	409c                	lw	a5,0(s1)
    80003ebe:	cb89                	beqz	a5,80003ed0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	70a2                	ld	ra,40(sp)
    80003ec4:	7402                	ld	s0,32(sp)
    80003ec6:	64e2                	ld	s1,24(sp)
    80003ec8:	6942                	ld	s2,16(sp)
    80003eca:	69a2                	ld	s3,8(sp)
    80003ecc:	6145                	addi	sp,sp,48
    80003ece:	8082                	ret
    virtio_disk_rw(b, 0);
    80003ed0:	4581                	li	a1,0
    80003ed2:	8526                	mv	a0,s1
    80003ed4:	00003097          	auipc	ra,0x3
    80003ed8:	f52080e7          	jalr	-174(ra) # 80006e26 <virtio_disk_rw>
    b->valid = 1;
    80003edc:	4785                	li	a5,1
    80003ede:	c09c                	sw	a5,0(s1)
  return b;
    80003ee0:	b7c5                	j	80003ec0 <bread+0xd0>

0000000080003ee2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003ee2:	1101                	addi	sp,sp,-32
    80003ee4:	ec06                	sd	ra,24(sp)
    80003ee6:	e822                	sd	s0,16(sp)
    80003ee8:	e426                	sd	s1,8(sp)
    80003eea:	1000                	addi	s0,sp,32
    80003eec:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003eee:	0541                	addi	a0,a0,16
    80003ef0:	00001097          	auipc	ra,0x1
    80003ef4:	46a080e7          	jalr	1130(ra) # 8000535a <holdingsleep>
    80003ef8:	cd01                	beqz	a0,80003f10 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003efa:	4585                	li	a1,1
    80003efc:	8526                	mv	a0,s1
    80003efe:	00003097          	auipc	ra,0x3
    80003f02:	f28080e7          	jalr	-216(ra) # 80006e26 <virtio_disk_rw>
}
    80003f06:	60e2                	ld	ra,24(sp)
    80003f08:	6442                	ld	s0,16(sp)
    80003f0a:	64a2                	ld	s1,8(sp)
    80003f0c:	6105                	addi	sp,sp,32
    80003f0e:	8082                	ret
    panic("bwrite");
    80003f10:	00006517          	auipc	a0,0x6
    80003f14:	81050513          	addi	a0,a0,-2032 # 80009720 <syscalls+0x158>
    80003f18:	ffffc097          	auipc	ra,0xffffc
    80003f1c:	612080e7          	jalr	1554(ra) # 8000052a <panic>

0000000080003f20 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003f20:	1101                	addi	sp,sp,-32
    80003f22:	ec06                	sd	ra,24(sp)
    80003f24:	e822                	sd	s0,16(sp)
    80003f26:	e426                	sd	s1,8(sp)
    80003f28:	e04a                	sd	s2,0(sp)
    80003f2a:	1000                	addi	s0,sp,32
    80003f2c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003f2e:	01050913          	addi	s2,a0,16
    80003f32:	854a                	mv	a0,s2
    80003f34:	00001097          	auipc	ra,0x1
    80003f38:	426080e7          	jalr	1062(ra) # 8000535a <holdingsleep>
    80003f3c:	c92d                	beqz	a0,80003fae <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003f3e:	854a                	mv	a0,s2
    80003f40:	00001097          	auipc	ra,0x1
    80003f44:	3d6080e7          	jalr	982(ra) # 80005316 <releasesleep>

  acquire(&bcache.lock);
    80003f48:	00033517          	auipc	a0,0x33
    80003f4c:	9b850513          	addi	a0,a0,-1608 # 80036900 <bcache>
    80003f50:	ffffd097          	auipc	ra,0xffffd
    80003f54:	c72080e7          	jalr	-910(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003f58:	40bc                	lw	a5,64(s1)
    80003f5a:	37fd                	addiw	a5,a5,-1
    80003f5c:	0007871b          	sext.w	a4,a5
    80003f60:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003f62:	eb05                	bnez	a4,80003f92 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003f64:	68bc                	ld	a5,80(s1)
    80003f66:	64b8                	ld	a4,72(s1)
    80003f68:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003f6a:	64bc                	ld	a5,72(s1)
    80003f6c:	68b8                	ld	a4,80(s1)
    80003f6e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003f70:	0003b797          	auipc	a5,0x3b
    80003f74:	99078793          	addi	a5,a5,-1648 # 8003e900 <bcache+0x8000>
    80003f78:	2b87b703          	ld	a4,696(a5)
    80003f7c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003f7e:	0003b717          	auipc	a4,0x3b
    80003f82:	bea70713          	addi	a4,a4,-1046 # 8003eb68 <bcache+0x8268>
    80003f86:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003f88:	2b87b703          	ld	a4,696(a5)
    80003f8c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003f8e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003f92:	00033517          	auipc	a0,0x33
    80003f96:	96e50513          	addi	a0,a0,-1682 # 80036900 <bcache>
    80003f9a:	ffffd097          	auipc	ra,0xffffd
    80003f9e:	cdc080e7          	jalr	-804(ra) # 80000c76 <release>
}
    80003fa2:	60e2                	ld	ra,24(sp)
    80003fa4:	6442                	ld	s0,16(sp)
    80003fa6:	64a2                	ld	s1,8(sp)
    80003fa8:	6902                	ld	s2,0(sp)
    80003faa:	6105                	addi	sp,sp,32
    80003fac:	8082                	ret
    panic("brelse");
    80003fae:	00005517          	auipc	a0,0x5
    80003fb2:	77a50513          	addi	a0,a0,1914 # 80009728 <syscalls+0x160>
    80003fb6:	ffffc097          	auipc	ra,0xffffc
    80003fba:	574080e7          	jalr	1396(ra) # 8000052a <panic>

0000000080003fbe <bpin>:

void
bpin(struct buf *b) {
    80003fbe:	1101                	addi	sp,sp,-32
    80003fc0:	ec06                	sd	ra,24(sp)
    80003fc2:	e822                	sd	s0,16(sp)
    80003fc4:	e426                	sd	s1,8(sp)
    80003fc6:	1000                	addi	s0,sp,32
    80003fc8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003fca:	00033517          	auipc	a0,0x33
    80003fce:	93650513          	addi	a0,a0,-1738 # 80036900 <bcache>
    80003fd2:	ffffd097          	auipc	ra,0xffffd
    80003fd6:	bf0080e7          	jalr	-1040(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003fda:	40bc                	lw	a5,64(s1)
    80003fdc:	2785                	addiw	a5,a5,1
    80003fde:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003fe0:	00033517          	auipc	a0,0x33
    80003fe4:	92050513          	addi	a0,a0,-1760 # 80036900 <bcache>
    80003fe8:	ffffd097          	auipc	ra,0xffffd
    80003fec:	c8e080e7          	jalr	-882(ra) # 80000c76 <release>
}
    80003ff0:	60e2                	ld	ra,24(sp)
    80003ff2:	6442                	ld	s0,16(sp)
    80003ff4:	64a2                	ld	s1,8(sp)
    80003ff6:	6105                	addi	sp,sp,32
    80003ff8:	8082                	ret

0000000080003ffa <bunpin>:

void
bunpin(struct buf *b) {
    80003ffa:	1101                	addi	sp,sp,-32
    80003ffc:	ec06                	sd	ra,24(sp)
    80003ffe:	e822                	sd	s0,16(sp)
    80004000:	e426                	sd	s1,8(sp)
    80004002:	1000                	addi	s0,sp,32
    80004004:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004006:	00033517          	auipc	a0,0x33
    8000400a:	8fa50513          	addi	a0,a0,-1798 # 80036900 <bcache>
    8000400e:	ffffd097          	auipc	ra,0xffffd
    80004012:	bb4080e7          	jalr	-1100(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80004016:	40bc                	lw	a5,64(s1)
    80004018:	37fd                	addiw	a5,a5,-1
    8000401a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000401c:	00033517          	auipc	a0,0x33
    80004020:	8e450513          	addi	a0,a0,-1820 # 80036900 <bcache>
    80004024:	ffffd097          	auipc	ra,0xffffd
    80004028:	c52080e7          	jalr	-942(ra) # 80000c76 <release>
}
    8000402c:	60e2                	ld	ra,24(sp)
    8000402e:	6442                	ld	s0,16(sp)
    80004030:	64a2                	ld	s1,8(sp)
    80004032:	6105                	addi	sp,sp,32
    80004034:	8082                	ret

0000000080004036 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004036:	1101                	addi	sp,sp,-32
    80004038:	ec06                	sd	ra,24(sp)
    8000403a:	e822                	sd	s0,16(sp)
    8000403c:	e426                	sd	s1,8(sp)
    8000403e:	e04a                	sd	s2,0(sp)
    80004040:	1000                	addi	s0,sp,32
    80004042:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004044:	00d5d59b          	srliw	a1,a1,0xd
    80004048:	0003b797          	auipc	a5,0x3b
    8000404c:	f947a783          	lw	a5,-108(a5) # 8003efdc <sb+0x1c>
    80004050:	9dbd                	addw	a1,a1,a5
    80004052:	00000097          	auipc	ra,0x0
    80004056:	d9e080e7          	jalr	-610(ra) # 80003df0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000405a:	0074f713          	andi	a4,s1,7
    8000405e:	4785                	li	a5,1
    80004060:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004064:	14ce                	slli	s1,s1,0x33
    80004066:	90d9                	srli	s1,s1,0x36
    80004068:	00950733          	add	a4,a0,s1
    8000406c:	05874703          	lbu	a4,88(a4)
    80004070:	00e7f6b3          	and	a3,a5,a4
    80004074:	c69d                	beqz	a3,800040a2 <bfree+0x6c>
    80004076:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80004078:	94aa                	add	s1,s1,a0
    8000407a:	fff7c793          	not	a5,a5
    8000407e:	8ff9                	and	a5,a5,a4
    80004080:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80004084:	00001097          	auipc	ra,0x1
    80004088:	11c080e7          	jalr	284(ra) # 800051a0 <log_write>
  brelse(bp);
    8000408c:	854a                	mv	a0,s2
    8000408e:	00000097          	auipc	ra,0x0
    80004092:	e92080e7          	jalr	-366(ra) # 80003f20 <brelse>
}
    80004096:	60e2                	ld	ra,24(sp)
    80004098:	6442                	ld	s0,16(sp)
    8000409a:	64a2                	ld	s1,8(sp)
    8000409c:	6902                	ld	s2,0(sp)
    8000409e:	6105                	addi	sp,sp,32
    800040a0:	8082                	ret
    panic("freeing free block");
    800040a2:	00005517          	auipc	a0,0x5
    800040a6:	68e50513          	addi	a0,a0,1678 # 80009730 <syscalls+0x168>
    800040aa:	ffffc097          	auipc	ra,0xffffc
    800040ae:	480080e7          	jalr	1152(ra) # 8000052a <panic>

00000000800040b2 <balloc>:
{
    800040b2:	711d                	addi	sp,sp,-96
    800040b4:	ec86                	sd	ra,88(sp)
    800040b6:	e8a2                	sd	s0,80(sp)
    800040b8:	e4a6                	sd	s1,72(sp)
    800040ba:	e0ca                	sd	s2,64(sp)
    800040bc:	fc4e                	sd	s3,56(sp)
    800040be:	f852                	sd	s4,48(sp)
    800040c0:	f456                	sd	s5,40(sp)
    800040c2:	f05a                	sd	s6,32(sp)
    800040c4:	ec5e                	sd	s7,24(sp)
    800040c6:	e862                	sd	s8,16(sp)
    800040c8:	e466                	sd	s9,8(sp)
    800040ca:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800040cc:	0003b797          	auipc	a5,0x3b
    800040d0:	ef87a783          	lw	a5,-264(a5) # 8003efc4 <sb+0x4>
    800040d4:	cbd1                	beqz	a5,80004168 <balloc+0xb6>
    800040d6:	8baa                	mv	s7,a0
    800040d8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800040da:	0003bb17          	auipc	s6,0x3b
    800040de:	ee6b0b13          	addi	s6,s6,-282 # 8003efc0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800040e2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800040e4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800040e6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800040e8:	6c89                	lui	s9,0x2
    800040ea:	a831                	j	80004106 <balloc+0x54>
    brelse(bp);
    800040ec:	854a                	mv	a0,s2
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	e32080e7          	jalr	-462(ra) # 80003f20 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800040f6:	015c87bb          	addw	a5,s9,s5
    800040fa:	00078a9b          	sext.w	s5,a5
    800040fe:	004b2703          	lw	a4,4(s6)
    80004102:	06eaf363          	bgeu	s5,a4,80004168 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80004106:	41fad79b          	sraiw	a5,s5,0x1f
    8000410a:	0137d79b          	srliw	a5,a5,0x13
    8000410e:	015787bb          	addw	a5,a5,s5
    80004112:	40d7d79b          	sraiw	a5,a5,0xd
    80004116:	01cb2583          	lw	a1,28(s6)
    8000411a:	9dbd                	addw	a1,a1,a5
    8000411c:	855e                	mv	a0,s7
    8000411e:	00000097          	auipc	ra,0x0
    80004122:	cd2080e7          	jalr	-814(ra) # 80003df0 <bread>
    80004126:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004128:	004b2503          	lw	a0,4(s6)
    8000412c:	000a849b          	sext.w	s1,s5
    80004130:	8662                	mv	a2,s8
    80004132:	faa4fde3          	bgeu	s1,a0,800040ec <balloc+0x3a>
      m = 1 << (bi % 8);
    80004136:	41f6579b          	sraiw	a5,a2,0x1f
    8000413a:	01d7d69b          	srliw	a3,a5,0x1d
    8000413e:	00c6873b          	addw	a4,a3,a2
    80004142:	00777793          	andi	a5,a4,7
    80004146:	9f95                	subw	a5,a5,a3
    80004148:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000414c:	4037571b          	sraiw	a4,a4,0x3
    80004150:	00e906b3          	add	a3,s2,a4
    80004154:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    80004158:	00d7f5b3          	and	a1,a5,a3
    8000415c:	cd91                	beqz	a1,80004178 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000415e:	2605                	addiw	a2,a2,1
    80004160:	2485                	addiw	s1,s1,1
    80004162:	fd4618e3          	bne	a2,s4,80004132 <balloc+0x80>
    80004166:	b759                	j	800040ec <balloc+0x3a>
  panic("balloc: out of blocks");
    80004168:	00005517          	auipc	a0,0x5
    8000416c:	5e050513          	addi	a0,a0,1504 # 80009748 <syscalls+0x180>
    80004170:	ffffc097          	auipc	ra,0xffffc
    80004174:	3ba080e7          	jalr	954(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80004178:	974a                	add	a4,a4,s2
    8000417a:	8fd5                	or	a5,a5,a3
    8000417c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80004180:	854a                	mv	a0,s2
    80004182:	00001097          	auipc	ra,0x1
    80004186:	01e080e7          	jalr	30(ra) # 800051a0 <log_write>
        brelse(bp);
    8000418a:	854a                	mv	a0,s2
    8000418c:	00000097          	auipc	ra,0x0
    80004190:	d94080e7          	jalr	-620(ra) # 80003f20 <brelse>
  bp = bread(dev, bno);
    80004194:	85a6                	mv	a1,s1
    80004196:	855e                	mv	a0,s7
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	c58080e7          	jalr	-936(ra) # 80003df0 <bread>
    800041a0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800041a2:	40000613          	li	a2,1024
    800041a6:	4581                	li	a1,0
    800041a8:	05850513          	addi	a0,a0,88
    800041ac:	ffffd097          	auipc	ra,0xffffd
    800041b0:	b12080e7          	jalr	-1262(ra) # 80000cbe <memset>
  log_write(bp);
    800041b4:	854a                	mv	a0,s2
    800041b6:	00001097          	auipc	ra,0x1
    800041ba:	fea080e7          	jalr	-22(ra) # 800051a0 <log_write>
  brelse(bp);
    800041be:	854a                	mv	a0,s2
    800041c0:	00000097          	auipc	ra,0x0
    800041c4:	d60080e7          	jalr	-672(ra) # 80003f20 <brelse>
}
    800041c8:	8526                	mv	a0,s1
    800041ca:	60e6                	ld	ra,88(sp)
    800041cc:	6446                	ld	s0,80(sp)
    800041ce:	64a6                	ld	s1,72(sp)
    800041d0:	6906                	ld	s2,64(sp)
    800041d2:	79e2                	ld	s3,56(sp)
    800041d4:	7a42                	ld	s4,48(sp)
    800041d6:	7aa2                	ld	s5,40(sp)
    800041d8:	7b02                	ld	s6,32(sp)
    800041da:	6be2                	ld	s7,24(sp)
    800041dc:	6c42                	ld	s8,16(sp)
    800041de:	6ca2                	ld	s9,8(sp)
    800041e0:	6125                	addi	sp,sp,96
    800041e2:	8082                	ret

00000000800041e4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800041e4:	7179                	addi	sp,sp,-48
    800041e6:	f406                	sd	ra,40(sp)
    800041e8:	f022                	sd	s0,32(sp)
    800041ea:	ec26                	sd	s1,24(sp)
    800041ec:	e84a                	sd	s2,16(sp)
    800041ee:	e44e                	sd	s3,8(sp)
    800041f0:	e052                	sd	s4,0(sp)
    800041f2:	1800                	addi	s0,sp,48
    800041f4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800041f6:	47ad                	li	a5,11
    800041f8:	04b7fe63          	bgeu	a5,a1,80004254 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800041fc:	ff45849b          	addiw	s1,a1,-12
    80004200:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004204:	0ff00793          	li	a5,255
    80004208:	0ae7e463          	bltu	a5,a4,800042b0 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000420c:	08052583          	lw	a1,128(a0)
    80004210:	c5b5                	beqz	a1,8000427c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004212:	00092503          	lw	a0,0(s2)
    80004216:	00000097          	auipc	ra,0x0
    8000421a:	bda080e7          	jalr	-1062(ra) # 80003df0 <bread>
    8000421e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004220:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004224:	02049713          	slli	a4,s1,0x20
    80004228:	01e75593          	srli	a1,a4,0x1e
    8000422c:	00b784b3          	add	s1,a5,a1
    80004230:	0004a983          	lw	s3,0(s1)
    80004234:	04098e63          	beqz	s3,80004290 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004238:	8552                	mv	a0,s4
    8000423a:	00000097          	auipc	ra,0x0
    8000423e:	ce6080e7          	jalr	-794(ra) # 80003f20 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004242:	854e                	mv	a0,s3
    80004244:	70a2                	ld	ra,40(sp)
    80004246:	7402                	ld	s0,32(sp)
    80004248:	64e2                	ld	s1,24(sp)
    8000424a:	6942                	ld	s2,16(sp)
    8000424c:	69a2                	ld	s3,8(sp)
    8000424e:	6a02                	ld	s4,0(sp)
    80004250:	6145                	addi	sp,sp,48
    80004252:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004254:	02059793          	slli	a5,a1,0x20
    80004258:	01e7d593          	srli	a1,a5,0x1e
    8000425c:	00b504b3          	add	s1,a0,a1
    80004260:	0504a983          	lw	s3,80(s1)
    80004264:	fc099fe3          	bnez	s3,80004242 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80004268:	4108                	lw	a0,0(a0)
    8000426a:	00000097          	auipc	ra,0x0
    8000426e:	e48080e7          	jalr	-440(ra) # 800040b2 <balloc>
    80004272:	0005099b          	sext.w	s3,a0
    80004276:	0534a823          	sw	s3,80(s1)
    8000427a:	b7e1                	j	80004242 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000427c:	4108                	lw	a0,0(a0)
    8000427e:	00000097          	auipc	ra,0x0
    80004282:	e34080e7          	jalr	-460(ra) # 800040b2 <balloc>
    80004286:	0005059b          	sext.w	a1,a0
    8000428a:	08b92023          	sw	a1,128(s2)
    8000428e:	b751                	j	80004212 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004290:	00092503          	lw	a0,0(s2)
    80004294:	00000097          	auipc	ra,0x0
    80004298:	e1e080e7          	jalr	-482(ra) # 800040b2 <balloc>
    8000429c:	0005099b          	sext.w	s3,a0
    800042a0:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800042a4:	8552                	mv	a0,s4
    800042a6:	00001097          	auipc	ra,0x1
    800042aa:	efa080e7          	jalr	-262(ra) # 800051a0 <log_write>
    800042ae:	b769                	j	80004238 <bmap+0x54>
  panic("bmap: out of range");
    800042b0:	00005517          	auipc	a0,0x5
    800042b4:	4b050513          	addi	a0,a0,1200 # 80009760 <syscalls+0x198>
    800042b8:	ffffc097          	auipc	ra,0xffffc
    800042bc:	272080e7          	jalr	626(ra) # 8000052a <panic>

00000000800042c0 <iget>:
{
    800042c0:	7179                	addi	sp,sp,-48
    800042c2:	f406                	sd	ra,40(sp)
    800042c4:	f022                	sd	s0,32(sp)
    800042c6:	ec26                	sd	s1,24(sp)
    800042c8:	e84a                	sd	s2,16(sp)
    800042ca:	e44e                	sd	s3,8(sp)
    800042cc:	e052                	sd	s4,0(sp)
    800042ce:	1800                	addi	s0,sp,48
    800042d0:	89aa                	mv	s3,a0
    800042d2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800042d4:	0003b517          	auipc	a0,0x3b
    800042d8:	d0c50513          	addi	a0,a0,-756 # 8003efe0 <itable>
    800042dc:	ffffd097          	auipc	ra,0xffffd
    800042e0:	8e6080e7          	jalr	-1818(ra) # 80000bc2 <acquire>
  empty = 0;
    800042e4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800042e6:	0003b497          	auipc	s1,0x3b
    800042ea:	d1248493          	addi	s1,s1,-750 # 8003eff8 <itable+0x18>
    800042ee:	0003c697          	auipc	a3,0x3c
    800042f2:	79a68693          	addi	a3,a3,1946 # 80040a88 <log>
    800042f6:	a039                	j	80004304 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800042f8:	02090b63          	beqz	s2,8000432e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800042fc:	08848493          	addi	s1,s1,136
    80004300:	02d48a63          	beq	s1,a3,80004334 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004304:	449c                	lw	a5,8(s1)
    80004306:	fef059e3          	blez	a5,800042f8 <iget+0x38>
    8000430a:	4098                	lw	a4,0(s1)
    8000430c:	ff3716e3          	bne	a4,s3,800042f8 <iget+0x38>
    80004310:	40d8                	lw	a4,4(s1)
    80004312:	ff4713e3          	bne	a4,s4,800042f8 <iget+0x38>
      ip->ref++;
    80004316:	2785                	addiw	a5,a5,1
    80004318:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000431a:	0003b517          	auipc	a0,0x3b
    8000431e:	cc650513          	addi	a0,a0,-826 # 8003efe0 <itable>
    80004322:	ffffd097          	auipc	ra,0xffffd
    80004326:	954080e7          	jalr	-1708(ra) # 80000c76 <release>
      return ip;
    8000432a:	8926                	mv	s2,s1
    8000432c:	a03d                	j	8000435a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000432e:	f7f9                	bnez	a5,800042fc <iget+0x3c>
    80004330:	8926                	mv	s2,s1
    80004332:	b7e9                	j	800042fc <iget+0x3c>
  if(empty == 0)
    80004334:	02090c63          	beqz	s2,8000436c <iget+0xac>
  ip->dev = dev;
    80004338:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000433c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004340:	4785                	li	a5,1
    80004342:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004346:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000434a:	0003b517          	auipc	a0,0x3b
    8000434e:	c9650513          	addi	a0,a0,-874 # 8003efe0 <itable>
    80004352:	ffffd097          	auipc	ra,0xffffd
    80004356:	924080e7          	jalr	-1756(ra) # 80000c76 <release>
}
    8000435a:	854a                	mv	a0,s2
    8000435c:	70a2                	ld	ra,40(sp)
    8000435e:	7402                	ld	s0,32(sp)
    80004360:	64e2                	ld	s1,24(sp)
    80004362:	6942                	ld	s2,16(sp)
    80004364:	69a2                	ld	s3,8(sp)
    80004366:	6a02                	ld	s4,0(sp)
    80004368:	6145                	addi	sp,sp,48
    8000436a:	8082                	ret
    panic("iget: no inodes");
    8000436c:	00005517          	auipc	a0,0x5
    80004370:	40c50513          	addi	a0,a0,1036 # 80009778 <syscalls+0x1b0>
    80004374:	ffffc097          	auipc	ra,0xffffc
    80004378:	1b6080e7          	jalr	438(ra) # 8000052a <panic>

000000008000437c <fsinit>:
fsinit(int dev) {
    8000437c:	7179                	addi	sp,sp,-48
    8000437e:	f406                	sd	ra,40(sp)
    80004380:	f022                	sd	s0,32(sp)
    80004382:	ec26                	sd	s1,24(sp)
    80004384:	e84a                	sd	s2,16(sp)
    80004386:	e44e                	sd	s3,8(sp)
    80004388:	1800                	addi	s0,sp,48
    8000438a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000438c:	4585                	li	a1,1
    8000438e:	00000097          	auipc	ra,0x0
    80004392:	a62080e7          	jalr	-1438(ra) # 80003df0 <bread>
    80004396:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80004398:	0003b997          	auipc	s3,0x3b
    8000439c:	c2898993          	addi	s3,s3,-984 # 8003efc0 <sb>
    800043a0:	02000613          	li	a2,32
    800043a4:	05850593          	addi	a1,a0,88
    800043a8:	854e                	mv	a0,s3
    800043aa:	ffffd097          	auipc	ra,0xffffd
    800043ae:	970080e7          	jalr	-1680(ra) # 80000d1a <memmove>
  brelse(bp);
    800043b2:	8526                	mv	a0,s1
    800043b4:	00000097          	auipc	ra,0x0
    800043b8:	b6c080e7          	jalr	-1172(ra) # 80003f20 <brelse>
  if(sb.magic != FSMAGIC)
    800043bc:	0009a703          	lw	a4,0(s3)
    800043c0:	102037b7          	lui	a5,0x10203
    800043c4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800043c8:	02f71263          	bne	a4,a5,800043ec <fsinit+0x70>
  initlog(dev, &sb);
    800043cc:	0003b597          	auipc	a1,0x3b
    800043d0:	bf458593          	addi	a1,a1,-1036 # 8003efc0 <sb>
    800043d4:	854a                	mv	a0,s2
    800043d6:	00001097          	auipc	ra,0x1
    800043da:	b4c080e7          	jalr	-1204(ra) # 80004f22 <initlog>
}
    800043de:	70a2                	ld	ra,40(sp)
    800043e0:	7402                	ld	s0,32(sp)
    800043e2:	64e2                	ld	s1,24(sp)
    800043e4:	6942                	ld	s2,16(sp)
    800043e6:	69a2                	ld	s3,8(sp)
    800043e8:	6145                	addi	sp,sp,48
    800043ea:	8082                	ret
    panic("invalid file system");
    800043ec:	00005517          	auipc	a0,0x5
    800043f0:	39c50513          	addi	a0,a0,924 # 80009788 <syscalls+0x1c0>
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	136080e7          	jalr	310(ra) # 8000052a <panic>

00000000800043fc <iinit>:
{
    800043fc:	7179                	addi	sp,sp,-48
    800043fe:	f406                	sd	ra,40(sp)
    80004400:	f022                	sd	s0,32(sp)
    80004402:	ec26                	sd	s1,24(sp)
    80004404:	e84a                	sd	s2,16(sp)
    80004406:	e44e                	sd	s3,8(sp)
    80004408:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000440a:	00005597          	auipc	a1,0x5
    8000440e:	39658593          	addi	a1,a1,918 # 800097a0 <syscalls+0x1d8>
    80004412:	0003b517          	auipc	a0,0x3b
    80004416:	bce50513          	addi	a0,a0,-1074 # 8003efe0 <itable>
    8000441a:	ffffc097          	auipc	ra,0xffffc
    8000441e:	718080e7          	jalr	1816(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004422:	0003b497          	auipc	s1,0x3b
    80004426:	be648493          	addi	s1,s1,-1050 # 8003f008 <itable+0x28>
    8000442a:	0003c997          	auipc	s3,0x3c
    8000442e:	66e98993          	addi	s3,s3,1646 # 80040a98 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004432:	00005917          	auipc	s2,0x5
    80004436:	37690913          	addi	s2,s2,886 # 800097a8 <syscalls+0x1e0>
    8000443a:	85ca                	mv	a1,s2
    8000443c:	8526                	mv	a0,s1
    8000443e:	00001097          	auipc	ra,0x1
    80004442:	e48080e7          	jalr	-440(ra) # 80005286 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004446:	08848493          	addi	s1,s1,136
    8000444a:	ff3498e3          	bne	s1,s3,8000443a <iinit+0x3e>
}
    8000444e:	70a2                	ld	ra,40(sp)
    80004450:	7402                	ld	s0,32(sp)
    80004452:	64e2                	ld	s1,24(sp)
    80004454:	6942                	ld	s2,16(sp)
    80004456:	69a2                	ld	s3,8(sp)
    80004458:	6145                	addi	sp,sp,48
    8000445a:	8082                	ret

000000008000445c <ialloc>:
{
    8000445c:	715d                	addi	sp,sp,-80
    8000445e:	e486                	sd	ra,72(sp)
    80004460:	e0a2                	sd	s0,64(sp)
    80004462:	fc26                	sd	s1,56(sp)
    80004464:	f84a                	sd	s2,48(sp)
    80004466:	f44e                	sd	s3,40(sp)
    80004468:	f052                	sd	s4,32(sp)
    8000446a:	ec56                	sd	s5,24(sp)
    8000446c:	e85a                	sd	s6,16(sp)
    8000446e:	e45e                	sd	s7,8(sp)
    80004470:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004472:	0003b717          	auipc	a4,0x3b
    80004476:	b5a72703          	lw	a4,-1190(a4) # 8003efcc <sb+0xc>
    8000447a:	4785                	li	a5,1
    8000447c:	04e7fa63          	bgeu	a5,a4,800044d0 <ialloc+0x74>
    80004480:	8aaa                	mv	s5,a0
    80004482:	8bae                	mv	s7,a1
    80004484:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004486:	0003ba17          	auipc	s4,0x3b
    8000448a:	b3aa0a13          	addi	s4,s4,-1222 # 8003efc0 <sb>
    8000448e:	00048b1b          	sext.w	s6,s1
    80004492:	0044d793          	srli	a5,s1,0x4
    80004496:	018a2583          	lw	a1,24(s4)
    8000449a:	9dbd                	addw	a1,a1,a5
    8000449c:	8556                	mv	a0,s5
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	952080e7          	jalr	-1710(ra) # 80003df0 <bread>
    800044a6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800044a8:	05850993          	addi	s3,a0,88
    800044ac:	00f4f793          	andi	a5,s1,15
    800044b0:	079a                	slli	a5,a5,0x6
    800044b2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800044b4:	00099783          	lh	a5,0(s3)
    800044b8:	c785                	beqz	a5,800044e0 <ialloc+0x84>
    brelse(bp);
    800044ba:	00000097          	auipc	ra,0x0
    800044be:	a66080e7          	jalr	-1434(ra) # 80003f20 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800044c2:	0485                	addi	s1,s1,1
    800044c4:	00ca2703          	lw	a4,12(s4)
    800044c8:	0004879b          	sext.w	a5,s1
    800044cc:	fce7e1e3          	bltu	a5,a4,8000448e <ialloc+0x32>
  panic("ialloc: no inodes");
    800044d0:	00005517          	auipc	a0,0x5
    800044d4:	2e050513          	addi	a0,a0,736 # 800097b0 <syscalls+0x1e8>
    800044d8:	ffffc097          	auipc	ra,0xffffc
    800044dc:	052080e7          	jalr	82(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    800044e0:	04000613          	li	a2,64
    800044e4:	4581                	li	a1,0
    800044e6:	854e                	mv	a0,s3
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	7d6080e7          	jalr	2006(ra) # 80000cbe <memset>
      dip->type = type;
    800044f0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800044f4:	854a                	mv	a0,s2
    800044f6:	00001097          	auipc	ra,0x1
    800044fa:	caa080e7          	jalr	-854(ra) # 800051a0 <log_write>
      brelse(bp);
    800044fe:	854a                	mv	a0,s2
    80004500:	00000097          	auipc	ra,0x0
    80004504:	a20080e7          	jalr	-1504(ra) # 80003f20 <brelse>
      return iget(dev, inum);
    80004508:	85da                	mv	a1,s6
    8000450a:	8556                	mv	a0,s5
    8000450c:	00000097          	auipc	ra,0x0
    80004510:	db4080e7          	jalr	-588(ra) # 800042c0 <iget>
}
    80004514:	60a6                	ld	ra,72(sp)
    80004516:	6406                	ld	s0,64(sp)
    80004518:	74e2                	ld	s1,56(sp)
    8000451a:	7942                	ld	s2,48(sp)
    8000451c:	79a2                	ld	s3,40(sp)
    8000451e:	7a02                	ld	s4,32(sp)
    80004520:	6ae2                	ld	s5,24(sp)
    80004522:	6b42                	ld	s6,16(sp)
    80004524:	6ba2                	ld	s7,8(sp)
    80004526:	6161                	addi	sp,sp,80
    80004528:	8082                	ret

000000008000452a <iupdate>:
{
    8000452a:	1101                	addi	sp,sp,-32
    8000452c:	ec06                	sd	ra,24(sp)
    8000452e:	e822                	sd	s0,16(sp)
    80004530:	e426                	sd	s1,8(sp)
    80004532:	e04a                	sd	s2,0(sp)
    80004534:	1000                	addi	s0,sp,32
    80004536:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004538:	415c                	lw	a5,4(a0)
    8000453a:	0047d79b          	srliw	a5,a5,0x4
    8000453e:	0003b597          	auipc	a1,0x3b
    80004542:	a9a5a583          	lw	a1,-1382(a1) # 8003efd8 <sb+0x18>
    80004546:	9dbd                	addw	a1,a1,a5
    80004548:	4108                	lw	a0,0(a0)
    8000454a:	00000097          	auipc	ra,0x0
    8000454e:	8a6080e7          	jalr	-1882(ra) # 80003df0 <bread>
    80004552:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004554:	05850793          	addi	a5,a0,88
    80004558:	40c8                	lw	a0,4(s1)
    8000455a:	893d                	andi	a0,a0,15
    8000455c:	051a                	slli	a0,a0,0x6
    8000455e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004560:	04449703          	lh	a4,68(s1)
    80004564:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004568:	04649703          	lh	a4,70(s1)
    8000456c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004570:	04849703          	lh	a4,72(s1)
    80004574:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80004578:	04a49703          	lh	a4,74(s1)
    8000457c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004580:	44f8                	lw	a4,76(s1)
    80004582:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004584:	03400613          	li	a2,52
    80004588:	05048593          	addi	a1,s1,80
    8000458c:	0531                	addi	a0,a0,12
    8000458e:	ffffc097          	auipc	ra,0xffffc
    80004592:	78c080e7          	jalr	1932(ra) # 80000d1a <memmove>
  log_write(bp);
    80004596:	854a                	mv	a0,s2
    80004598:	00001097          	auipc	ra,0x1
    8000459c:	c08080e7          	jalr	-1016(ra) # 800051a0 <log_write>
  brelse(bp);
    800045a0:	854a                	mv	a0,s2
    800045a2:	00000097          	auipc	ra,0x0
    800045a6:	97e080e7          	jalr	-1666(ra) # 80003f20 <brelse>
}
    800045aa:	60e2                	ld	ra,24(sp)
    800045ac:	6442                	ld	s0,16(sp)
    800045ae:	64a2                	ld	s1,8(sp)
    800045b0:	6902                	ld	s2,0(sp)
    800045b2:	6105                	addi	sp,sp,32
    800045b4:	8082                	ret

00000000800045b6 <idup>:
{
    800045b6:	1101                	addi	sp,sp,-32
    800045b8:	ec06                	sd	ra,24(sp)
    800045ba:	e822                	sd	s0,16(sp)
    800045bc:	e426                	sd	s1,8(sp)
    800045be:	1000                	addi	s0,sp,32
    800045c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800045c2:	0003b517          	auipc	a0,0x3b
    800045c6:	a1e50513          	addi	a0,a0,-1506 # 8003efe0 <itable>
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	5f8080e7          	jalr	1528(ra) # 80000bc2 <acquire>
  ip->ref++;
    800045d2:	449c                	lw	a5,8(s1)
    800045d4:	2785                	addiw	a5,a5,1
    800045d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800045d8:	0003b517          	auipc	a0,0x3b
    800045dc:	a0850513          	addi	a0,a0,-1528 # 8003efe0 <itable>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	696080e7          	jalr	1686(ra) # 80000c76 <release>
}
    800045e8:	8526                	mv	a0,s1
    800045ea:	60e2                	ld	ra,24(sp)
    800045ec:	6442                	ld	s0,16(sp)
    800045ee:	64a2                	ld	s1,8(sp)
    800045f0:	6105                	addi	sp,sp,32
    800045f2:	8082                	ret

00000000800045f4 <ilock>:
{
    800045f4:	1101                	addi	sp,sp,-32
    800045f6:	ec06                	sd	ra,24(sp)
    800045f8:	e822                	sd	s0,16(sp)
    800045fa:	e426                	sd	s1,8(sp)
    800045fc:	e04a                	sd	s2,0(sp)
    800045fe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004600:	c115                	beqz	a0,80004624 <ilock+0x30>
    80004602:	84aa                	mv	s1,a0
    80004604:	451c                	lw	a5,8(a0)
    80004606:	00f05f63          	blez	a5,80004624 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000460a:	0541                	addi	a0,a0,16
    8000460c:	00001097          	auipc	ra,0x1
    80004610:	cb4080e7          	jalr	-844(ra) # 800052c0 <acquiresleep>
  if(ip->valid == 0){
    80004614:	40bc                	lw	a5,64(s1)
    80004616:	cf99                	beqz	a5,80004634 <ilock+0x40>
}
    80004618:	60e2                	ld	ra,24(sp)
    8000461a:	6442                	ld	s0,16(sp)
    8000461c:	64a2                	ld	s1,8(sp)
    8000461e:	6902                	ld	s2,0(sp)
    80004620:	6105                	addi	sp,sp,32
    80004622:	8082                	ret
    panic("ilock");
    80004624:	00005517          	auipc	a0,0x5
    80004628:	1a450513          	addi	a0,a0,420 # 800097c8 <syscalls+0x200>
    8000462c:	ffffc097          	auipc	ra,0xffffc
    80004630:	efe080e7          	jalr	-258(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004634:	40dc                	lw	a5,4(s1)
    80004636:	0047d79b          	srliw	a5,a5,0x4
    8000463a:	0003b597          	auipc	a1,0x3b
    8000463e:	99e5a583          	lw	a1,-1634(a1) # 8003efd8 <sb+0x18>
    80004642:	9dbd                	addw	a1,a1,a5
    80004644:	4088                	lw	a0,0(s1)
    80004646:	fffff097          	auipc	ra,0xfffff
    8000464a:	7aa080e7          	jalr	1962(ra) # 80003df0 <bread>
    8000464e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004650:	05850593          	addi	a1,a0,88
    80004654:	40dc                	lw	a5,4(s1)
    80004656:	8bbd                	andi	a5,a5,15
    80004658:	079a                	slli	a5,a5,0x6
    8000465a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000465c:	00059783          	lh	a5,0(a1)
    80004660:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004664:	00259783          	lh	a5,2(a1)
    80004668:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000466c:	00459783          	lh	a5,4(a1)
    80004670:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004674:	00659783          	lh	a5,6(a1)
    80004678:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000467c:	459c                	lw	a5,8(a1)
    8000467e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004680:	03400613          	li	a2,52
    80004684:	05b1                	addi	a1,a1,12
    80004686:	05048513          	addi	a0,s1,80
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	690080e7          	jalr	1680(ra) # 80000d1a <memmove>
    brelse(bp);
    80004692:	854a                	mv	a0,s2
    80004694:	00000097          	auipc	ra,0x0
    80004698:	88c080e7          	jalr	-1908(ra) # 80003f20 <brelse>
    ip->valid = 1;
    8000469c:	4785                	li	a5,1
    8000469e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800046a0:	04449783          	lh	a5,68(s1)
    800046a4:	fbb5                	bnez	a5,80004618 <ilock+0x24>
      panic("ilock: no type");
    800046a6:	00005517          	auipc	a0,0x5
    800046aa:	12a50513          	addi	a0,a0,298 # 800097d0 <syscalls+0x208>
    800046ae:	ffffc097          	auipc	ra,0xffffc
    800046b2:	e7c080e7          	jalr	-388(ra) # 8000052a <panic>

00000000800046b6 <iunlock>:
{
    800046b6:	1101                	addi	sp,sp,-32
    800046b8:	ec06                	sd	ra,24(sp)
    800046ba:	e822                	sd	s0,16(sp)
    800046bc:	e426                	sd	s1,8(sp)
    800046be:	e04a                	sd	s2,0(sp)
    800046c0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800046c2:	c905                	beqz	a0,800046f2 <iunlock+0x3c>
    800046c4:	84aa                	mv	s1,a0
    800046c6:	01050913          	addi	s2,a0,16
    800046ca:	854a                	mv	a0,s2
    800046cc:	00001097          	auipc	ra,0x1
    800046d0:	c8e080e7          	jalr	-882(ra) # 8000535a <holdingsleep>
    800046d4:	cd19                	beqz	a0,800046f2 <iunlock+0x3c>
    800046d6:	449c                	lw	a5,8(s1)
    800046d8:	00f05d63          	blez	a5,800046f2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800046dc:	854a                	mv	a0,s2
    800046de:	00001097          	auipc	ra,0x1
    800046e2:	c38080e7          	jalr	-968(ra) # 80005316 <releasesleep>
}
    800046e6:	60e2                	ld	ra,24(sp)
    800046e8:	6442                	ld	s0,16(sp)
    800046ea:	64a2                	ld	s1,8(sp)
    800046ec:	6902                	ld	s2,0(sp)
    800046ee:	6105                	addi	sp,sp,32
    800046f0:	8082                	ret
    panic("iunlock");
    800046f2:	00005517          	auipc	a0,0x5
    800046f6:	0ee50513          	addi	a0,a0,238 # 800097e0 <syscalls+0x218>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	e30080e7          	jalr	-464(ra) # 8000052a <panic>

0000000080004702 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004702:	7179                	addi	sp,sp,-48
    80004704:	f406                	sd	ra,40(sp)
    80004706:	f022                	sd	s0,32(sp)
    80004708:	ec26                	sd	s1,24(sp)
    8000470a:	e84a                	sd	s2,16(sp)
    8000470c:	e44e                	sd	s3,8(sp)
    8000470e:	e052                	sd	s4,0(sp)
    80004710:	1800                	addi	s0,sp,48
    80004712:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004714:	05050493          	addi	s1,a0,80
    80004718:	08050913          	addi	s2,a0,128
    8000471c:	a021                	j	80004724 <itrunc+0x22>
    8000471e:	0491                	addi	s1,s1,4
    80004720:	01248d63          	beq	s1,s2,8000473a <itrunc+0x38>
    if(ip->addrs[i]){
    80004724:	408c                	lw	a1,0(s1)
    80004726:	dde5                	beqz	a1,8000471e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004728:	0009a503          	lw	a0,0(s3)
    8000472c:	00000097          	auipc	ra,0x0
    80004730:	90a080e7          	jalr	-1782(ra) # 80004036 <bfree>
      ip->addrs[i] = 0;
    80004734:	0004a023          	sw	zero,0(s1)
    80004738:	b7dd                	j	8000471e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000473a:	0809a583          	lw	a1,128(s3)
    8000473e:	e185                	bnez	a1,8000475e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004740:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004744:	854e                	mv	a0,s3
    80004746:	00000097          	auipc	ra,0x0
    8000474a:	de4080e7          	jalr	-540(ra) # 8000452a <iupdate>
}
    8000474e:	70a2                	ld	ra,40(sp)
    80004750:	7402                	ld	s0,32(sp)
    80004752:	64e2                	ld	s1,24(sp)
    80004754:	6942                	ld	s2,16(sp)
    80004756:	69a2                	ld	s3,8(sp)
    80004758:	6a02                	ld	s4,0(sp)
    8000475a:	6145                	addi	sp,sp,48
    8000475c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000475e:	0009a503          	lw	a0,0(s3)
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	68e080e7          	jalr	1678(ra) # 80003df0 <bread>
    8000476a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000476c:	05850493          	addi	s1,a0,88
    80004770:	45850913          	addi	s2,a0,1112
    80004774:	a021                	j	8000477c <itrunc+0x7a>
    80004776:	0491                	addi	s1,s1,4
    80004778:	01248b63          	beq	s1,s2,8000478e <itrunc+0x8c>
      if(a[j])
    8000477c:	408c                	lw	a1,0(s1)
    8000477e:	dde5                	beqz	a1,80004776 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004780:	0009a503          	lw	a0,0(s3)
    80004784:	00000097          	auipc	ra,0x0
    80004788:	8b2080e7          	jalr	-1870(ra) # 80004036 <bfree>
    8000478c:	b7ed                	j	80004776 <itrunc+0x74>
    brelse(bp);
    8000478e:	8552                	mv	a0,s4
    80004790:	fffff097          	auipc	ra,0xfffff
    80004794:	790080e7          	jalr	1936(ra) # 80003f20 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004798:	0809a583          	lw	a1,128(s3)
    8000479c:	0009a503          	lw	a0,0(s3)
    800047a0:	00000097          	auipc	ra,0x0
    800047a4:	896080e7          	jalr	-1898(ra) # 80004036 <bfree>
    ip->addrs[NDIRECT] = 0;
    800047a8:	0809a023          	sw	zero,128(s3)
    800047ac:	bf51                	j	80004740 <itrunc+0x3e>

00000000800047ae <iput>:
{
    800047ae:	1101                	addi	sp,sp,-32
    800047b0:	ec06                	sd	ra,24(sp)
    800047b2:	e822                	sd	s0,16(sp)
    800047b4:	e426                	sd	s1,8(sp)
    800047b6:	e04a                	sd	s2,0(sp)
    800047b8:	1000                	addi	s0,sp,32
    800047ba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800047bc:	0003b517          	auipc	a0,0x3b
    800047c0:	82450513          	addi	a0,a0,-2012 # 8003efe0 <itable>
    800047c4:	ffffc097          	auipc	ra,0xffffc
    800047c8:	3fe080e7          	jalr	1022(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800047cc:	4498                	lw	a4,8(s1)
    800047ce:	4785                	li	a5,1
    800047d0:	02f70363          	beq	a4,a5,800047f6 <iput+0x48>
  ip->ref--;
    800047d4:	449c                	lw	a5,8(s1)
    800047d6:	37fd                	addiw	a5,a5,-1
    800047d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800047da:	0003b517          	auipc	a0,0x3b
    800047de:	80650513          	addi	a0,a0,-2042 # 8003efe0 <itable>
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	494080e7          	jalr	1172(ra) # 80000c76 <release>
}
    800047ea:	60e2                	ld	ra,24(sp)
    800047ec:	6442                	ld	s0,16(sp)
    800047ee:	64a2                	ld	s1,8(sp)
    800047f0:	6902                	ld	s2,0(sp)
    800047f2:	6105                	addi	sp,sp,32
    800047f4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800047f6:	40bc                	lw	a5,64(s1)
    800047f8:	dff1                	beqz	a5,800047d4 <iput+0x26>
    800047fa:	04a49783          	lh	a5,74(s1)
    800047fe:	fbf9                	bnez	a5,800047d4 <iput+0x26>
    acquiresleep(&ip->lock);
    80004800:	01048913          	addi	s2,s1,16
    80004804:	854a                	mv	a0,s2
    80004806:	00001097          	auipc	ra,0x1
    8000480a:	aba080e7          	jalr	-1350(ra) # 800052c0 <acquiresleep>
    release(&itable.lock);
    8000480e:	0003a517          	auipc	a0,0x3a
    80004812:	7d250513          	addi	a0,a0,2002 # 8003efe0 <itable>
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	460080e7          	jalr	1120(ra) # 80000c76 <release>
    itrunc(ip);
    8000481e:	8526                	mv	a0,s1
    80004820:	00000097          	auipc	ra,0x0
    80004824:	ee2080e7          	jalr	-286(ra) # 80004702 <itrunc>
    ip->type = 0;
    80004828:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000482c:	8526                	mv	a0,s1
    8000482e:	00000097          	auipc	ra,0x0
    80004832:	cfc080e7          	jalr	-772(ra) # 8000452a <iupdate>
    ip->valid = 0;
    80004836:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000483a:	854a                	mv	a0,s2
    8000483c:	00001097          	auipc	ra,0x1
    80004840:	ada080e7          	jalr	-1318(ra) # 80005316 <releasesleep>
    acquire(&itable.lock);
    80004844:	0003a517          	auipc	a0,0x3a
    80004848:	79c50513          	addi	a0,a0,1948 # 8003efe0 <itable>
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	376080e7          	jalr	886(ra) # 80000bc2 <acquire>
    80004854:	b741                	j	800047d4 <iput+0x26>

0000000080004856 <iunlockput>:
{
    80004856:	1101                	addi	sp,sp,-32
    80004858:	ec06                	sd	ra,24(sp)
    8000485a:	e822                	sd	s0,16(sp)
    8000485c:	e426                	sd	s1,8(sp)
    8000485e:	1000                	addi	s0,sp,32
    80004860:	84aa                	mv	s1,a0
  iunlock(ip);
    80004862:	00000097          	auipc	ra,0x0
    80004866:	e54080e7          	jalr	-428(ra) # 800046b6 <iunlock>
  iput(ip);
    8000486a:	8526                	mv	a0,s1
    8000486c:	00000097          	auipc	ra,0x0
    80004870:	f42080e7          	jalr	-190(ra) # 800047ae <iput>
}
    80004874:	60e2                	ld	ra,24(sp)
    80004876:	6442                	ld	s0,16(sp)
    80004878:	64a2                	ld	s1,8(sp)
    8000487a:	6105                	addi	sp,sp,32
    8000487c:	8082                	ret

000000008000487e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000487e:	1141                	addi	sp,sp,-16
    80004880:	e422                	sd	s0,8(sp)
    80004882:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004884:	411c                	lw	a5,0(a0)
    80004886:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004888:	415c                	lw	a5,4(a0)
    8000488a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000488c:	04451783          	lh	a5,68(a0)
    80004890:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004894:	04a51783          	lh	a5,74(a0)
    80004898:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000489c:	04c56783          	lwu	a5,76(a0)
    800048a0:	e99c                	sd	a5,16(a1)
}
    800048a2:	6422                	ld	s0,8(sp)
    800048a4:	0141                	addi	sp,sp,16
    800048a6:	8082                	ret

00000000800048a8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800048a8:	457c                	lw	a5,76(a0)
    800048aa:	0ed7e963          	bltu	a5,a3,8000499c <readi+0xf4>
{
    800048ae:	7159                	addi	sp,sp,-112
    800048b0:	f486                	sd	ra,104(sp)
    800048b2:	f0a2                	sd	s0,96(sp)
    800048b4:	eca6                	sd	s1,88(sp)
    800048b6:	e8ca                	sd	s2,80(sp)
    800048b8:	e4ce                	sd	s3,72(sp)
    800048ba:	e0d2                	sd	s4,64(sp)
    800048bc:	fc56                	sd	s5,56(sp)
    800048be:	f85a                	sd	s6,48(sp)
    800048c0:	f45e                	sd	s7,40(sp)
    800048c2:	f062                	sd	s8,32(sp)
    800048c4:	ec66                	sd	s9,24(sp)
    800048c6:	e86a                	sd	s10,16(sp)
    800048c8:	e46e                	sd	s11,8(sp)
    800048ca:	1880                	addi	s0,sp,112
    800048cc:	8baa                	mv	s7,a0
    800048ce:	8c2e                	mv	s8,a1
    800048d0:	8ab2                	mv	s5,a2
    800048d2:	84b6                	mv	s1,a3
    800048d4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800048d6:	9f35                	addw	a4,a4,a3
    return 0;
    800048d8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800048da:	0ad76063          	bltu	a4,a3,8000497a <readi+0xd2>
  if(off + n > ip->size)
    800048de:	00e7f463          	bgeu	a5,a4,800048e6 <readi+0x3e>
    n = ip->size - off;
    800048e2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800048e6:	0a0b0963          	beqz	s6,80004998 <readi+0xf0>
    800048ea:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800048ec:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800048f0:	5cfd                	li	s9,-1
    800048f2:	a82d                	j	8000492c <readi+0x84>
    800048f4:	020a1d93          	slli	s11,s4,0x20
    800048f8:	020ddd93          	srli	s11,s11,0x20
    800048fc:	05890793          	addi	a5,s2,88
    80004900:	86ee                	mv	a3,s11
    80004902:	963e                	add	a2,a2,a5
    80004904:	85d6                	mv	a1,s5
    80004906:	8562                	mv	a0,s8
    80004908:	ffffe097          	auipc	ra,0xffffe
    8000490c:	f1e080e7          	jalr	-226(ra) # 80002826 <either_copyout>
    80004910:	05950d63          	beq	a0,s9,8000496a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004914:	854a                	mv	a0,s2
    80004916:	fffff097          	auipc	ra,0xfffff
    8000491a:	60a080e7          	jalr	1546(ra) # 80003f20 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000491e:	013a09bb          	addw	s3,s4,s3
    80004922:	009a04bb          	addw	s1,s4,s1
    80004926:	9aee                	add	s5,s5,s11
    80004928:	0569f763          	bgeu	s3,s6,80004976 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000492c:	000ba903          	lw	s2,0(s7)
    80004930:	00a4d59b          	srliw	a1,s1,0xa
    80004934:	855e                	mv	a0,s7
    80004936:	00000097          	auipc	ra,0x0
    8000493a:	8ae080e7          	jalr	-1874(ra) # 800041e4 <bmap>
    8000493e:	0005059b          	sext.w	a1,a0
    80004942:	854a                	mv	a0,s2
    80004944:	fffff097          	auipc	ra,0xfffff
    80004948:	4ac080e7          	jalr	1196(ra) # 80003df0 <bread>
    8000494c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000494e:	3ff4f613          	andi	a2,s1,1023
    80004952:	40cd07bb          	subw	a5,s10,a2
    80004956:	413b073b          	subw	a4,s6,s3
    8000495a:	8a3e                	mv	s4,a5
    8000495c:	2781                	sext.w	a5,a5
    8000495e:	0007069b          	sext.w	a3,a4
    80004962:	f8f6f9e3          	bgeu	a3,a5,800048f4 <readi+0x4c>
    80004966:	8a3a                	mv	s4,a4
    80004968:	b771                	j	800048f4 <readi+0x4c>
      brelse(bp);
    8000496a:	854a                	mv	a0,s2
    8000496c:	fffff097          	auipc	ra,0xfffff
    80004970:	5b4080e7          	jalr	1460(ra) # 80003f20 <brelse>
      tot = -1;
    80004974:	59fd                	li	s3,-1
  }
  return tot;
    80004976:	0009851b          	sext.w	a0,s3
}
    8000497a:	70a6                	ld	ra,104(sp)
    8000497c:	7406                	ld	s0,96(sp)
    8000497e:	64e6                	ld	s1,88(sp)
    80004980:	6946                	ld	s2,80(sp)
    80004982:	69a6                	ld	s3,72(sp)
    80004984:	6a06                	ld	s4,64(sp)
    80004986:	7ae2                	ld	s5,56(sp)
    80004988:	7b42                	ld	s6,48(sp)
    8000498a:	7ba2                	ld	s7,40(sp)
    8000498c:	7c02                	ld	s8,32(sp)
    8000498e:	6ce2                	ld	s9,24(sp)
    80004990:	6d42                	ld	s10,16(sp)
    80004992:	6da2                	ld	s11,8(sp)
    80004994:	6165                	addi	sp,sp,112
    80004996:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004998:	89da                	mv	s3,s6
    8000499a:	bff1                	j	80004976 <readi+0xce>
    return 0;
    8000499c:	4501                	li	a0,0
}
    8000499e:	8082                	ret

00000000800049a0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800049a0:	457c                	lw	a5,76(a0)
    800049a2:	10d7e863          	bltu	a5,a3,80004ab2 <writei+0x112>
{
    800049a6:	7159                	addi	sp,sp,-112
    800049a8:	f486                	sd	ra,104(sp)
    800049aa:	f0a2                	sd	s0,96(sp)
    800049ac:	eca6                	sd	s1,88(sp)
    800049ae:	e8ca                	sd	s2,80(sp)
    800049b0:	e4ce                	sd	s3,72(sp)
    800049b2:	e0d2                	sd	s4,64(sp)
    800049b4:	fc56                	sd	s5,56(sp)
    800049b6:	f85a                	sd	s6,48(sp)
    800049b8:	f45e                	sd	s7,40(sp)
    800049ba:	f062                	sd	s8,32(sp)
    800049bc:	ec66                	sd	s9,24(sp)
    800049be:	e86a                	sd	s10,16(sp)
    800049c0:	e46e                	sd	s11,8(sp)
    800049c2:	1880                	addi	s0,sp,112
    800049c4:	8b2a                	mv	s6,a0
    800049c6:	8c2e                	mv	s8,a1
    800049c8:	8ab2                	mv	s5,a2
    800049ca:	8936                	mv	s2,a3
    800049cc:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800049ce:	00e687bb          	addw	a5,a3,a4
    800049d2:	0ed7e263          	bltu	a5,a3,80004ab6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800049d6:	00043737          	lui	a4,0x43
    800049da:	0ef76063          	bltu	a4,a5,80004aba <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800049de:	0c0b8863          	beqz	s7,80004aae <writei+0x10e>
    800049e2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800049e4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800049e8:	5cfd                	li	s9,-1
    800049ea:	a091                	j	80004a2e <writei+0x8e>
    800049ec:	02099d93          	slli	s11,s3,0x20
    800049f0:	020ddd93          	srli	s11,s11,0x20
    800049f4:	05848793          	addi	a5,s1,88
    800049f8:	86ee                	mv	a3,s11
    800049fa:	8656                	mv	a2,s5
    800049fc:	85e2                	mv	a1,s8
    800049fe:	953e                	add	a0,a0,a5
    80004a00:	ffffe097          	auipc	ra,0xffffe
    80004a04:	e7c080e7          	jalr	-388(ra) # 8000287c <either_copyin>
    80004a08:	07950263          	beq	a0,s9,80004a6c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004a0c:	8526                	mv	a0,s1
    80004a0e:	00000097          	auipc	ra,0x0
    80004a12:	792080e7          	jalr	1938(ra) # 800051a0 <log_write>
    brelse(bp);
    80004a16:	8526                	mv	a0,s1
    80004a18:	fffff097          	auipc	ra,0xfffff
    80004a1c:	508080e7          	jalr	1288(ra) # 80003f20 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004a20:	01498a3b          	addw	s4,s3,s4
    80004a24:	0129893b          	addw	s2,s3,s2
    80004a28:	9aee                	add	s5,s5,s11
    80004a2a:	057a7663          	bgeu	s4,s7,80004a76 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004a2e:	000b2483          	lw	s1,0(s6)
    80004a32:	00a9559b          	srliw	a1,s2,0xa
    80004a36:	855a                	mv	a0,s6
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	7ac080e7          	jalr	1964(ra) # 800041e4 <bmap>
    80004a40:	0005059b          	sext.w	a1,a0
    80004a44:	8526                	mv	a0,s1
    80004a46:	fffff097          	auipc	ra,0xfffff
    80004a4a:	3aa080e7          	jalr	938(ra) # 80003df0 <bread>
    80004a4e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004a50:	3ff97513          	andi	a0,s2,1023
    80004a54:	40ad07bb          	subw	a5,s10,a0
    80004a58:	414b873b          	subw	a4,s7,s4
    80004a5c:	89be                	mv	s3,a5
    80004a5e:	2781                	sext.w	a5,a5
    80004a60:	0007069b          	sext.w	a3,a4
    80004a64:	f8f6f4e3          	bgeu	a3,a5,800049ec <writei+0x4c>
    80004a68:	89ba                	mv	s3,a4
    80004a6a:	b749                	j	800049ec <writei+0x4c>
      brelse(bp);
    80004a6c:	8526                	mv	a0,s1
    80004a6e:	fffff097          	auipc	ra,0xfffff
    80004a72:	4b2080e7          	jalr	1202(ra) # 80003f20 <brelse>
  }

  if(off > ip->size)
    80004a76:	04cb2783          	lw	a5,76(s6)
    80004a7a:	0127f463          	bgeu	a5,s2,80004a82 <writei+0xe2>
    ip->size = off;
    80004a7e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004a82:	855a                	mv	a0,s6
    80004a84:	00000097          	auipc	ra,0x0
    80004a88:	aa6080e7          	jalr	-1370(ra) # 8000452a <iupdate>

  return tot;
    80004a8c:	000a051b          	sext.w	a0,s4
}
    80004a90:	70a6                	ld	ra,104(sp)
    80004a92:	7406                	ld	s0,96(sp)
    80004a94:	64e6                	ld	s1,88(sp)
    80004a96:	6946                	ld	s2,80(sp)
    80004a98:	69a6                	ld	s3,72(sp)
    80004a9a:	6a06                	ld	s4,64(sp)
    80004a9c:	7ae2                	ld	s5,56(sp)
    80004a9e:	7b42                	ld	s6,48(sp)
    80004aa0:	7ba2                	ld	s7,40(sp)
    80004aa2:	7c02                	ld	s8,32(sp)
    80004aa4:	6ce2                	ld	s9,24(sp)
    80004aa6:	6d42                	ld	s10,16(sp)
    80004aa8:	6da2                	ld	s11,8(sp)
    80004aaa:	6165                	addi	sp,sp,112
    80004aac:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004aae:	8a5e                	mv	s4,s7
    80004ab0:	bfc9                	j	80004a82 <writei+0xe2>
    return -1;
    80004ab2:	557d                	li	a0,-1
}
    80004ab4:	8082                	ret
    return -1;
    80004ab6:	557d                	li	a0,-1
    80004ab8:	bfe1                	j	80004a90 <writei+0xf0>
    return -1;
    80004aba:	557d                	li	a0,-1
    80004abc:	bfd1                	j	80004a90 <writei+0xf0>

0000000080004abe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004abe:	1141                	addi	sp,sp,-16
    80004ac0:	e406                	sd	ra,8(sp)
    80004ac2:	e022                	sd	s0,0(sp)
    80004ac4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004ac6:	4639                	li	a2,14
    80004ac8:	ffffc097          	auipc	ra,0xffffc
    80004acc:	2ce080e7          	jalr	718(ra) # 80000d96 <strncmp>
}
    80004ad0:	60a2                	ld	ra,8(sp)
    80004ad2:	6402                	ld	s0,0(sp)
    80004ad4:	0141                	addi	sp,sp,16
    80004ad6:	8082                	ret

0000000080004ad8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004ad8:	7139                	addi	sp,sp,-64
    80004ada:	fc06                	sd	ra,56(sp)
    80004adc:	f822                	sd	s0,48(sp)
    80004ade:	f426                	sd	s1,40(sp)
    80004ae0:	f04a                	sd	s2,32(sp)
    80004ae2:	ec4e                	sd	s3,24(sp)
    80004ae4:	e852                	sd	s4,16(sp)
    80004ae6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004ae8:	04451703          	lh	a4,68(a0)
    80004aec:	4785                	li	a5,1
    80004aee:	00f71a63          	bne	a4,a5,80004b02 <dirlookup+0x2a>
    80004af2:	892a                	mv	s2,a0
    80004af4:	89ae                	mv	s3,a1
    80004af6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004af8:	457c                	lw	a5,76(a0)
    80004afa:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004afc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004afe:	e79d                	bnez	a5,80004b2c <dirlookup+0x54>
    80004b00:	a8a5                	j	80004b78 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004b02:	00005517          	auipc	a0,0x5
    80004b06:	ce650513          	addi	a0,a0,-794 # 800097e8 <syscalls+0x220>
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	a20080e7          	jalr	-1504(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004b12:	00005517          	auipc	a0,0x5
    80004b16:	cee50513          	addi	a0,a0,-786 # 80009800 <syscalls+0x238>
    80004b1a:	ffffc097          	auipc	ra,0xffffc
    80004b1e:	a10080e7          	jalr	-1520(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004b22:	24c1                	addiw	s1,s1,16
    80004b24:	04c92783          	lw	a5,76(s2)
    80004b28:	04f4f763          	bgeu	s1,a5,80004b76 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b2c:	4741                	li	a4,16
    80004b2e:	86a6                	mv	a3,s1
    80004b30:	fc040613          	addi	a2,s0,-64
    80004b34:	4581                	li	a1,0
    80004b36:	854a                	mv	a0,s2
    80004b38:	00000097          	auipc	ra,0x0
    80004b3c:	d70080e7          	jalr	-656(ra) # 800048a8 <readi>
    80004b40:	47c1                	li	a5,16
    80004b42:	fcf518e3          	bne	a0,a5,80004b12 <dirlookup+0x3a>
    if(de.inum == 0)
    80004b46:	fc045783          	lhu	a5,-64(s0)
    80004b4a:	dfe1                	beqz	a5,80004b22 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004b4c:	fc240593          	addi	a1,s0,-62
    80004b50:	854e                	mv	a0,s3
    80004b52:	00000097          	auipc	ra,0x0
    80004b56:	f6c080e7          	jalr	-148(ra) # 80004abe <namecmp>
    80004b5a:	f561                	bnez	a0,80004b22 <dirlookup+0x4a>
      if(poff)
    80004b5c:	000a0463          	beqz	s4,80004b64 <dirlookup+0x8c>
        *poff = off;
    80004b60:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004b64:	fc045583          	lhu	a1,-64(s0)
    80004b68:	00092503          	lw	a0,0(s2)
    80004b6c:	fffff097          	auipc	ra,0xfffff
    80004b70:	754080e7          	jalr	1876(ra) # 800042c0 <iget>
    80004b74:	a011                	j	80004b78 <dirlookup+0xa0>
  return 0;
    80004b76:	4501                	li	a0,0
}
    80004b78:	70e2                	ld	ra,56(sp)
    80004b7a:	7442                	ld	s0,48(sp)
    80004b7c:	74a2                	ld	s1,40(sp)
    80004b7e:	7902                	ld	s2,32(sp)
    80004b80:	69e2                	ld	s3,24(sp)
    80004b82:	6a42                	ld	s4,16(sp)
    80004b84:	6121                	addi	sp,sp,64
    80004b86:	8082                	ret

0000000080004b88 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004b88:	711d                	addi	sp,sp,-96
    80004b8a:	ec86                	sd	ra,88(sp)
    80004b8c:	e8a2                	sd	s0,80(sp)
    80004b8e:	e4a6                	sd	s1,72(sp)
    80004b90:	e0ca                	sd	s2,64(sp)
    80004b92:	fc4e                	sd	s3,56(sp)
    80004b94:	f852                	sd	s4,48(sp)
    80004b96:	f456                	sd	s5,40(sp)
    80004b98:	f05a                	sd	s6,32(sp)
    80004b9a:	ec5e                	sd	s7,24(sp)
    80004b9c:	e862                	sd	s8,16(sp)
    80004b9e:	e466                	sd	s9,8(sp)
    80004ba0:	1080                	addi	s0,sp,96
    80004ba2:	84aa                	mv	s1,a0
    80004ba4:	8aae                	mv	s5,a1
    80004ba6:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004ba8:	00054703          	lbu	a4,0(a0)
    80004bac:	02f00793          	li	a5,47
    80004bb0:	02f70263          	beq	a4,a5,80004bd4 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004bb4:	ffffd097          	auipc	ra,0xffffd
    80004bb8:	040080e7          	jalr	64(ra) # 80001bf4 <myproc>
    80004bbc:	6568                	ld	a0,200(a0)
    80004bbe:	00000097          	auipc	ra,0x0
    80004bc2:	9f8080e7          	jalr	-1544(ra) # 800045b6 <idup>
    80004bc6:	89aa                	mv	s3,a0
  while(*path == '/')
    80004bc8:	02f00913          	li	s2,47
  len = path - s;
    80004bcc:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004bce:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004bd0:	4b85                	li	s7,1
    80004bd2:	a865                	j	80004c8a <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004bd4:	4585                	li	a1,1
    80004bd6:	4505                	li	a0,1
    80004bd8:	fffff097          	auipc	ra,0xfffff
    80004bdc:	6e8080e7          	jalr	1768(ra) # 800042c0 <iget>
    80004be0:	89aa                	mv	s3,a0
    80004be2:	b7dd                	j	80004bc8 <namex+0x40>
      iunlockput(ip);
    80004be4:	854e                	mv	a0,s3
    80004be6:	00000097          	auipc	ra,0x0
    80004bea:	c70080e7          	jalr	-912(ra) # 80004856 <iunlockput>
      return 0;
    80004bee:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004bf0:	854e                	mv	a0,s3
    80004bf2:	60e6                	ld	ra,88(sp)
    80004bf4:	6446                	ld	s0,80(sp)
    80004bf6:	64a6                	ld	s1,72(sp)
    80004bf8:	6906                	ld	s2,64(sp)
    80004bfa:	79e2                	ld	s3,56(sp)
    80004bfc:	7a42                	ld	s4,48(sp)
    80004bfe:	7aa2                	ld	s5,40(sp)
    80004c00:	7b02                	ld	s6,32(sp)
    80004c02:	6be2                	ld	s7,24(sp)
    80004c04:	6c42                	ld	s8,16(sp)
    80004c06:	6ca2                	ld	s9,8(sp)
    80004c08:	6125                	addi	sp,sp,96
    80004c0a:	8082                	ret
      iunlock(ip);
    80004c0c:	854e                	mv	a0,s3
    80004c0e:	00000097          	auipc	ra,0x0
    80004c12:	aa8080e7          	jalr	-1368(ra) # 800046b6 <iunlock>
      return ip;
    80004c16:	bfe9                	j	80004bf0 <namex+0x68>
      iunlockput(ip);
    80004c18:	854e                	mv	a0,s3
    80004c1a:	00000097          	auipc	ra,0x0
    80004c1e:	c3c080e7          	jalr	-964(ra) # 80004856 <iunlockput>
      return 0;
    80004c22:	89e6                	mv	s3,s9
    80004c24:	b7f1                	j	80004bf0 <namex+0x68>
  len = path - s;
    80004c26:	40b48633          	sub	a2,s1,a1
    80004c2a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004c2e:	099c5463          	bge	s8,s9,80004cb6 <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004c32:	4639                	li	a2,14
    80004c34:	8552                	mv	a0,s4
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	0e4080e7          	jalr	228(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004c3e:	0004c783          	lbu	a5,0(s1)
    80004c42:	01279763          	bne	a5,s2,80004c50 <namex+0xc8>
    path++;
    80004c46:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004c48:	0004c783          	lbu	a5,0(s1)
    80004c4c:	ff278de3          	beq	a5,s2,80004c46 <namex+0xbe>
    ilock(ip);
    80004c50:	854e                	mv	a0,s3
    80004c52:	00000097          	auipc	ra,0x0
    80004c56:	9a2080e7          	jalr	-1630(ra) # 800045f4 <ilock>
    if(ip->type != T_DIR){
    80004c5a:	04499783          	lh	a5,68(s3)
    80004c5e:	f97793e3          	bne	a5,s7,80004be4 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004c62:	000a8563          	beqz	s5,80004c6c <namex+0xe4>
    80004c66:	0004c783          	lbu	a5,0(s1)
    80004c6a:	d3cd                	beqz	a5,80004c0c <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004c6c:	865a                	mv	a2,s6
    80004c6e:	85d2                	mv	a1,s4
    80004c70:	854e                	mv	a0,s3
    80004c72:	00000097          	auipc	ra,0x0
    80004c76:	e66080e7          	jalr	-410(ra) # 80004ad8 <dirlookup>
    80004c7a:	8caa                	mv	s9,a0
    80004c7c:	dd51                	beqz	a0,80004c18 <namex+0x90>
    iunlockput(ip);
    80004c7e:	854e                	mv	a0,s3
    80004c80:	00000097          	auipc	ra,0x0
    80004c84:	bd6080e7          	jalr	-1066(ra) # 80004856 <iunlockput>
    ip = next;
    80004c88:	89e6                	mv	s3,s9
  while(*path == '/')
    80004c8a:	0004c783          	lbu	a5,0(s1)
    80004c8e:	05279763          	bne	a5,s2,80004cdc <namex+0x154>
    path++;
    80004c92:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004c94:	0004c783          	lbu	a5,0(s1)
    80004c98:	ff278de3          	beq	a5,s2,80004c92 <namex+0x10a>
  if(*path == 0)
    80004c9c:	c79d                	beqz	a5,80004cca <namex+0x142>
    path++;
    80004c9e:	85a6                	mv	a1,s1
  len = path - s;
    80004ca0:	8cda                	mv	s9,s6
    80004ca2:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004ca4:	01278963          	beq	a5,s2,80004cb6 <namex+0x12e>
    80004ca8:	dfbd                	beqz	a5,80004c26 <namex+0x9e>
    path++;
    80004caa:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004cac:	0004c783          	lbu	a5,0(s1)
    80004cb0:	ff279ce3          	bne	a5,s2,80004ca8 <namex+0x120>
    80004cb4:	bf8d                	j	80004c26 <namex+0x9e>
    memmove(name, s, len);
    80004cb6:	2601                	sext.w	a2,a2
    80004cb8:	8552                	mv	a0,s4
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	060080e7          	jalr	96(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004cc2:	9cd2                	add	s9,s9,s4
    80004cc4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004cc8:	bf9d                	j	80004c3e <namex+0xb6>
  if(nameiparent){
    80004cca:	f20a83e3          	beqz	s5,80004bf0 <namex+0x68>
    iput(ip);
    80004cce:	854e                	mv	a0,s3
    80004cd0:	00000097          	auipc	ra,0x0
    80004cd4:	ade080e7          	jalr	-1314(ra) # 800047ae <iput>
    return 0;
    80004cd8:	4981                	li	s3,0
    80004cda:	bf19                	j	80004bf0 <namex+0x68>
  if(*path == 0)
    80004cdc:	d7fd                	beqz	a5,80004cca <namex+0x142>
  while(*path != '/' && *path != 0)
    80004cde:	0004c783          	lbu	a5,0(s1)
    80004ce2:	85a6                	mv	a1,s1
    80004ce4:	b7d1                	j	80004ca8 <namex+0x120>

0000000080004ce6 <dirlink>:
{
    80004ce6:	7139                	addi	sp,sp,-64
    80004ce8:	fc06                	sd	ra,56(sp)
    80004cea:	f822                	sd	s0,48(sp)
    80004cec:	f426                	sd	s1,40(sp)
    80004cee:	f04a                	sd	s2,32(sp)
    80004cf0:	ec4e                	sd	s3,24(sp)
    80004cf2:	e852                	sd	s4,16(sp)
    80004cf4:	0080                	addi	s0,sp,64
    80004cf6:	892a                	mv	s2,a0
    80004cf8:	8a2e                	mv	s4,a1
    80004cfa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004cfc:	4601                	li	a2,0
    80004cfe:	00000097          	auipc	ra,0x0
    80004d02:	dda080e7          	jalr	-550(ra) # 80004ad8 <dirlookup>
    80004d06:	e93d                	bnez	a0,80004d7c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d08:	04c92483          	lw	s1,76(s2)
    80004d0c:	c49d                	beqz	s1,80004d3a <dirlink+0x54>
    80004d0e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d10:	4741                	li	a4,16
    80004d12:	86a6                	mv	a3,s1
    80004d14:	fc040613          	addi	a2,s0,-64
    80004d18:	4581                	li	a1,0
    80004d1a:	854a                	mv	a0,s2
    80004d1c:	00000097          	auipc	ra,0x0
    80004d20:	b8c080e7          	jalr	-1140(ra) # 800048a8 <readi>
    80004d24:	47c1                	li	a5,16
    80004d26:	06f51163          	bne	a0,a5,80004d88 <dirlink+0xa2>
    if(de.inum == 0)
    80004d2a:	fc045783          	lhu	a5,-64(s0)
    80004d2e:	c791                	beqz	a5,80004d3a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d30:	24c1                	addiw	s1,s1,16
    80004d32:	04c92783          	lw	a5,76(s2)
    80004d36:	fcf4ede3          	bltu	s1,a5,80004d10 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004d3a:	4639                	li	a2,14
    80004d3c:	85d2                	mv	a1,s4
    80004d3e:	fc240513          	addi	a0,s0,-62
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	090080e7          	jalr	144(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    80004d4a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d4e:	4741                	li	a4,16
    80004d50:	86a6                	mv	a3,s1
    80004d52:	fc040613          	addi	a2,s0,-64
    80004d56:	4581                	li	a1,0
    80004d58:	854a                	mv	a0,s2
    80004d5a:	00000097          	auipc	ra,0x0
    80004d5e:	c46080e7          	jalr	-954(ra) # 800049a0 <writei>
    80004d62:	872a                	mv	a4,a0
    80004d64:	47c1                	li	a5,16
  return 0;
    80004d66:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d68:	02f71863          	bne	a4,a5,80004d98 <dirlink+0xb2>
}
    80004d6c:	70e2                	ld	ra,56(sp)
    80004d6e:	7442                	ld	s0,48(sp)
    80004d70:	74a2                	ld	s1,40(sp)
    80004d72:	7902                	ld	s2,32(sp)
    80004d74:	69e2                	ld	s3,24(sp)
    80004d76:	6a42                	ld	s4,16(sp)
    80004d78:	6121                	addi	sp,sp,64
    80004d7a:	8082                	ret
    iput(ip);
    80004d7c:	00000097          	auipc	ra,0x0
    80004d80:	a32080e7          	jalr	-1486(ra) # 800047ae <iput>
    return -1;
    80004d84:	557d                	li	a0,-1
    80004d86:	b7dd                	j	80004d6c <dirlink+0x86>
      panic("dirlink read");
    80004d88:	00005517          	auipc	a0,0x5
    80004d8c:	a8850513          	addi	a0,a0,-1400 # 80009810 <syscalls+0x248>
    80004d90:	ffffb097          	auipc	ra,0xffffb
    80004d94:	79a080e7          	jalr	1946(ra) # 8000052a <panic>
    panic("dirlink");
    80004d98:	00005517          	auipc	a0,0x5
    80004d9c:	b8850513          	addi	a0,a0,-1144 # 80009920 <syscalls+0x358>
    80004da0:	ffffb097          	auipc	ra,0xffffb
    80004da4:	78a080e7          	jalr	1930(ra) # 8000052a <panic>

0000000080004da8 <namei>:

struct inode*
namei(char *path)
{
    80004da8:	1101                	addi	sp,sp,-32
    80004daa:	ec06                	sd	ra,24(sp)
    80004dac:	e822                	sd	s0,16(sp)
    80004dae:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004db0:	fe040613          	addi	a2,s0,-32
    80004db4:	4581                	li	a1,0
    80004db6:	00000097          	auipc	ra,0x0
    80004dba:	dd2080e7          	jalr	-558(ra) # 80004b88 <namex>
}
    80004dbe:	60e2                	ld	ra,24(sp)
    80004dc0:	6442                	ld	s0,16(sp)
    80004dc2:	6105                	addi	sp,sp,32
    80004dc4:	8082                	ret

0000000080004dc6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004dc6:	1141                	addi	sp,sp,-16
    80004dc8:	e406                	sd	ra,8(sp)
    80004dca:	e022                	sd	s0,0(sp)
    80004dcc:	0800                	addi	s0,sp,16
    80004dce:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004dd0:	4585                	li	a1,1
    80004dd2:	00000097          	auipc	ra,0x0
    80004dd6:	db6080e7          	jalr	-586(ra) # 80004b88 <namex>
}
    80004dda:	60a2                	ld	ra,8(sp)
    80004ddc:	6402                	ld	s0,0(sp)
    80004dde:	0141                	addi	sp,sp,16
    80004de0:	8082                	ret

0000000080004de2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004de2:	1101                	addi	sp,sp,-32
    80004de4:	ec06                	sd	ra,24(sp)
    80004de6:	e822                	sd	s0,16(sp)
    80004de8:	e426                	sd	s1,8(sp)
    80004dea:	e04a                	sd	s2,0(sp)
    80004dec:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004dee:	0003c917          	auipc	s2,0x3c
    80004df2:	c9a90913          	addi	s2,s2,-870 # 80040a88 <log>
    80004df6:	01892583          	lw	a1,24(s2)
    80004dfa:	02892503          	lw	a0,40(s2)
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	ff2080e7          	jalr	-14(ra) # 80003df0 <bread>
    80004e06:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004e08:	02c92683          	lw	a3,44(s2)
    80004e0c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004e0e:	02d05863          	blez	a3,80004e3e <write_head+0x5c>
    80004e12:	0003c797          	auipc	a5,0x3c
    80004e16:	ca678793          	addi	a5,a5,-858 # 80040ab8 <log+0x30>
    80004e1a:	05c50713          	addi	a4,a0,92
    80004e1e:	36fd                	addiw	a3,a3,-1
    80004e20:	02069613          	slli	a2,a3,0x20
    80004e24:	01e65693          	srli	a3,a2,0x1e
    80004e28:	0003c617          	auipc	a2,0x3c
    80004e2c:	c9460613          	addi	a2,a2,-876 # 80040abc <log+0x34>
    80004e30:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004e32:	4390                	lw	a2,0(a5)
    80004e34:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004e36:	0791                	addi	a5,a5,4
    80004e38:	0711                	addi	a4,a4,4
    80004e3a:	fed79ce3          	bne	a5,a3,80004e32 <write_head+0x50>
  }
  bwrite(buf);
    80004e3e:	8526                	mv	a0,s1
    80004e40:	fffff097          	auipc	ra,0xfffff
    80004e44:	0a2080e7          	jalr	162(ra) # 80003ee2 <bwrite>
  brelse(buf);
    80004e48:	8526                	mv	a0,s1
    80004e4a:	fffff097          	auipc	ra,0xfffff
    80004e4e:	0d6080e7          	jalr	214(ra) # 80003f20 <brelse>
}
    80004e52:	60e2                	ld	ra,24(sp)
    80004e54:	6442                	ld	s0,16(sp)
    80004e56:	64a2                	ld	s1,8(sp)
    80004e58:	6902                	ld	s2,0(sp)
    80004e5a:	6105                	addi	sp,sp,32
    80004e5c:	8082                	ret

0000000080004e5e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e5e:	0003c797          	auipc	a5,0x3c
    80004e62:	c567a783          	lw	a5,-938(a5) # 80040ab4 <log+0x2c>
    80004e66:	0af05d63          	blez	a5,80004f20 <install_trans+0xc2>
{
    80004e6a:	7139                	addi	sp,sp,-64
    80004e6c:	fc06                	sd	ra,56(sp)
    80004e6e:	f822                	sd	s0,48(sp)
    80004e70:	f426                	sd	s1,40(sp)
    80004e72:	f04a                	sd	s2,32(sp)
    80004e74:	ec4e                	sd	s3,24(sp)
    80004e76:	e852                	sd	s4,16(sp)
    80004e78:	e456                	sd	s5,8(sp)
    80004e7a:	e05a                	sd	s6,0(sp)
    80004e7c:	0080                	addi	s0,sp,64
    80004e7e:	8b2a                	mv	s6,a0
    80004e80:	0003ca97          	auipc	s5,0x3c
    80004e84:	c38a8a93          	addi	s5,s5,-968 # 80040ab8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e88:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004e8a:	0003c997          	auipc	s3,0x3c
    80004e8e:	bfe98993          	addi	s3,s3,-1026 # 80040a88 <log>
    80004e92:	a00d                	j	80004eb4 <install_trans+0x56>
    brelse(lbuf);
    80004e94:	854a                	mv	a0,s2
    80004e96:	fffff097          	auipc	ra,0xfffff
    80004e9a:	08a080e7          	jalr	138(ra) # 80003f20 <brelse>
    brelse(dbuf);
    80004e9e:	8526                	mv	a0,s1
    80004ea0:	fffff097          	auipc	ra,0xfffff
    80004ea4:	080080e7          	jalr	128(ra) # 80003f20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ea8:	2a05                	addiw	s4,s4,1
    80004eaa:	0a91                	addi	s5,s5,4
    80004eac:	02c9a783          	lw	a5,44(s3)
    80004eb0:	04fa5e63          	bge	s4,a5,80004f0c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004eb4:	0189a583          	lw	a1,24(s3)
    80004eb8:	014585bb          	addw	a1,a1,s4
    80004ebc:	2585                	addiw	a1,a1,1
    80004ebe:	0289a503          	lw	a0,40(s3)
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	f2e080e7          	jalr	-210(ra) # 80003df0 <bread>
    80004eca:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004ecc:	000aa583          	lw	a1,0(s5)
    80004ed0:	0289a503          	lw	a0,40(s3)
    80004ed4:	fffff097          	auipc	ra,0xfffff
    80004ed8:	f1c080e7          	jalr	-228(ra) # 80003df0 <bread>
    80004edc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004ede:	40000613          	li	a2,1024
    80004ee2:	05890593          	addi	a1,s2,88
    80004ee6:	05850513          	addi	a0,a0,88
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	e30080e7          	jalr	-464(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004ef2:	8526                	mv	a0,s1
    80004ef4:	fffff097          	auipc	ra,0xfffff
    80004ef8:	fee080e7          	jalr	-18(ra) # 80003ee2 <bwrite>
    if(recovering == 0)
    80004efc:	f80b1ce3          	bnez	s6,80004e94 <install_trans+0x36>
      bunpin(dbuf);
    80004f00:	8526                	mv	a0,s1
    80004f02:	fffff097          	auipc	ra,0xfffff
    80004f06:	0f8080e7          	jalr	248(ra) # 80003ffa <bunpin>
    80004f0a:	b769                	j	80004e94 <install_trans+0x36>
}
    80004f0c:	70e2                	ld	ra,56(sp)
    80004f0e:	7442                	ld	s0,48(sp)
    80004f10:	74a2                	ld	s1,40(sp)
    80004f12:	7902                	ld	s2,32(sp)
    80004f14:	69e2                	ld	s3,24(sp)
    80004f16:	6a42                	ld	s4,16(sp)
    80004f18:	6aa2                	ld	s5,8(sp)
    80004f1a:	6b02                	ld	s6,0(sp)
    80004f1c:	6121                	addi	sp,sp,64
    80004f1e:	8082                	ret
    80004f20:	8082                	ret

0000000080004f22 <initlog>:
{
    80004f22:	7179                	addi	sp,sp,-48
    80004f24:	f406                	sd	ra,40(sp)
    80004f26:	f022                	sd	s0,32(sp)
    80004f28:	ec26                	sd	s1,24(sp)
    80004f2a:	e84a                	sd	s2,16(sp)
    80004f2c:	e44e                	sd	s3,8(sp)
    80004f2e:	1800                	addi	s0,sp,48
    80004f30:	892a                	mv	s2,a0
    80004f32:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004f34:	0003c497          	auipc	s1,0x3c
    80004f38:	b5448493          	addi	s1,s1,-1196 # 80040a88 <log>
    80004f3c:	00005597          	auipc	a1,0x5
    80004f40:	8e458593          	addi	a1,a1,-1820 # 80009820 <syscalls+0x258>
    80004f44:	8526                	mv	a0,s1
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	bec080e7          	jalr	-1044(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004f4e:	0149a583          	lw	a1,20(s3)
    80004f52:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004f54:	0109a783          	lw	a5,16(s3)
    80004f58:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004f5a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004f5e:	854a                	mv	a0,s2
    80004f60:	fffff097          	auipc	ra,0xfffff
    80004f64:	e90080e7          	jalr	-368(ra) # 80003df0 <bread>
  log.lh.n = lh->n;
    80004f68:	4d34                	lw	a3,88(a0)
    80004f6a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004f6c:	02d05663          	blez	a3,80004f98 <initlog+0x76>
    80004f70:	05c50793          	addi	a5,a0,92
    80004f74:	0003c717          	auipc	a4,0x3c
    80004f78:	b4470713          	addi	a4,a4,-1212 # 80040ab8 <log+0x30>
    80004f7c:	36fd                	addiw	a3,a3,-1
    80004f7e:	02069613          	slli	a2,a3,0x20
    80004f82:	01e65693          	srli	a3,a2,0x1e
    80004f86:	06050613          	addi	a2,a0,96
    80004f8a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004f8c:	4390                	lw	a2,0(a5)
    80004f8e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004f90:	0791                	addi	a5,a5,4
    80004f92:	0711                	addi	a4,a4,4
    80004f94:	fed79ce3          	bne	a5,a3,80004f8c <initlog+0x6a>
  brelse(buf);
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	f88080e7          	jalr	-120(ra) # 80003f20 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004fa0:	4505                	li	a0,1
    80004fa2:	00000097          	auipc	ra,0x0
    80004fa6:	ebc080e7          	jalr	-324(ra) # 80004e5e <install_trans>
  log.lh.n = 0;
    80004faa:	0003c797          	auipc	a5,0x3c
    80004fae:	b007a523          	sw	zero,-1270(a5) # 80040ab4 <log+0x2c>
  write_head(); // clear the log
    80004fb2:	00000097          	auipc	ra,0x0
    80004fb6:	e30080e7          	jalr	-464(ra) # 80004de2 <write_head>
}
    80004fba:	70a2                	ld	ra,40(sp)
    80004fbc:	7402                	ld	s0,32(sp)
    80004fbe:	64e2                	ld	s1,24(sp)
    80004fc0:	6942                	ld	s2,16(sp)
    80004fc2:	69a2                	ld	s3,8(sp)
    80004fc4:	6145                	addi	sp,sp,48
    80004fc6:	8082                	ret

0000000080004fc8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004fc8:	1101                	addi	sp,sp,-32
    80004fca:	ec06                	sd	ra,24(sp)
    80004fcc:	e822                	sd	s0,16(sp)
    80004fce:	e426                	sd	s1,8(sp)
    80004fd0:	e04a                	sd	s2,0(sp)
    80004fd2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004fd4:	0003c517          	auipc	a0,0x3c
    80004fd8:	ab450513          	addi	a0,a0,-1356 # 80040a88 <log>
    80004fdc:	ffffc097          	auipc	ra,0xffffc
    80004fe0:	be6080e7          	jalr	-1050(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004fe4:	0003c497          	auipc	s1,0x3c
    80004fe8:	aa448493          	addi	s1,s1,-1372 # 80040a88 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004fec:	4979                	li	s2,30
    80004fee:	a039                	j	80004ffc <begin_op+0x34>
      sleep(&log, &log.lock);
    80004ff0:	85a6                	mv	a1,s1
    80004ff2:	8526                	mv	a0,s1
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	432080e7          	jalr	1074(ra) # 80002426 <sleep>
    if(log.committing){
    80004ffc:	50dc                	lw	a5,36(s1)
    80004ffe:	fbed                	bnez	a5,80004ff0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005000:	509c                	lw	a5,32(s1)
    80005002:	0017871b          	addiw	a4,a5,1
    80005006:	0007069b          	sext.w	a3,a4
    8000500a:	0027179b          	slliw	a5,a4,0x2
    8000500e:	9fb9                	addw	a5,a5,a4
    80005010:	0017979b          	slliw	a5,a5,0x1
    80005014:	54d8                	lw	a4,44(s1)
    80005016:	9fb9                	addw	a5,a5,a4
    80005018:	00f95963          	bge	s2,a5,8000502a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000501c:	85a6                	mv	a1,s1
    8000501e:	8526                	mv	a0,s1
    80005020:	ffffd097          	auipc	ra,0xffffd
    80005024:	406080e7          	jalr	1030(ra) # 80002426 <sleep>
    80005028:	bfd1                	j	80004ffc <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000502a:	0003c517          	auipc	a0,0x3c
    8000502e:	a5e50513          	addi	a0,a0,-1442 # 80040a88 <log>
    80005032:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005034:	ffffc097          	auipc	ra,0xffffc
    80005038:	c42080e7          	jalr	-958(ra) # 80000c76 <release>
      break;
    }
  }
}
    8000503c:	60e2                	ld	ra,24(sp)
    8000503e:	6442                	ld	s0,16(sp)
    80005040:	64a2                	ld	s1,8(sp)
    80005042:	6902                	ld	s2,0(sp)
    80005044:	6105                	addi	sp,sp,32
    80005046:	8082                	ret

0000000080005048 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005048:	7139                	addi	sp,sp,-64
    8000504a:	fc06                	sd	ra,56(sp)
    8000504c:	f822                	sd	s0,48(sp)
    8000504e:	f426                	sd	s1,40(sp)
    80005050:	f04a                	sd	s2,32(sp)
    80005052:	ec4e                	sd	s3,24(sp)
    80005054:	e852                	sd	s4,16(sp)
    80005056:	e456                	sd	s5,8(sp)
    80005058:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000505a:	0003c497          	auipc	s1,0x3c
    8000505e:	a2e48493          	addi	s1,s1,-1490 # 80040a88 <log>
    80005062:	8526                	mv	a0,s1
    80005064:	ffffc097          	auipc	ra,0xffffc
    80005068:	b5e080e7          	jalr	-1186(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    8000506c:	509c                	lw	a5,32(s1)
    8000506e:	37fd                	addiw	a5,a5,-1
    80005070:	0007891b          	sext.w	s2,a5
    80005074:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80005076:	50dc                	lw	a5,36(s1)
    80005078:	e7b9                	bnez	a5,800050c6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000507a:	04091e63          	bnez	s2,800050d6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000507e:	0003c497          	auipc	s1,0x3c
    80005082:	a0a48493          	addi	s1,s1,-1526 # 80040a88 <log>
    80005086:	4785                	li	a5,1
    80005088:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000508a:	8526                	mv	a0,s1
    8000508c:	ffffc097          	auipc	ra,0xffffc
    80005090:	bea080e7          	jalr	-1046(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005094:	54dc                	lw	a5,44(s1)
    80005096:	06f04763          	bgtz	a5,80005104 <end_op+0xbc>
    acquire(&log.lock);
    8000509a:	0003c497          	auipc	s1,0x3c
    8000509e:	9ee48493          	addi	s1,s1,-1554 # 80040a88 <log>
    800050a2:	8526                	mv	a0,s1
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	b1e080e7          	jalr	-1250(ra) # 80000bc2 <acquire>
    log.committing = 0;
    800050ac:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800050b0:	8526                	mv	a0,s1
    800050b2:	ffffd097          	auipc	ra,0xffffd
    800050b6:	4fc080e7          	jalr	1276(ra) # 800025ae <wakeup>
    release(&log.lock);
    800050ba:	8526                	mv	a0,s1
    800050bc:	ffffc097          	auipc	ra,0xffffc
    800050c0:	bba080e7          	jalr	-1094(ra) # 80000c76 <release>
}
    800050c4:	a03d                	j	800050f2 <end_op+0xaa>
    panic("log.committing");
    800050c6:	00004517          	auipc	a0,0x4
    800050ca:	76250513          	addi	a0,a0,1890 # 80009828 <syscalls+0x260>
    800050ce:	ffffb097          	auipc	ra,0xffffb
    800050d2:	45c080e7          	jalr	1116(ra) # 8000052a <panic>
    wakeup(&log);
    800050d6:	0003c497          	auipc	s1,0x3c
    800050da:	9b248493          	addi	s1,s1,-1614 # 80040a88 <log>
    800050de:	8526                	mv	a0,s1
    800050e0:	ffffd097          	auipc	ra,0xffffd
    800050e4:	4ce080e7          	jalr	1230(ra) # 800025ae <wakeup>
  release(&log.lock);
    800050e8:	8526                	mv	a0,s1
    800050ea:	ffffc097          	auipc	ra,0xffffc
    800050ee:	b8c080e7          	jalr	-1140(ra) # 80000c76 <release>
}
    800050f2:	70e2                	ld	ra,56(sp)
    800050f4:	7442                	ld	s0,48(sp)
    800050f6:	74a2                	ld	s1,40(sp)
    800050f8:	7902                	ld	s2,32(sp)
    800050fa:	69e2                	ld	s3,24(sp)
    800050fc:	6a42                	ld	s4,16(sp)
    800050fe:	6aa2                	ld	s5,8(sp)
    80005100:	6121                	addi	sp,sp,64
    80005102:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005104:	0003ca97          	auipc	s5,0x3c
    80005108:	9b4a8a93          	addi	s5,s5,-1612 # 80040ab8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000510c:	0003ca17          	auipc	s4,0x3c
    80005110:	97ca0a13          	addi	s4,s4,-1668 # 80040a88 <log>
    80005114:	018a2583          	lw	a1,24(s4)
    80005118:	012585bb          	addw	a1,a1,s2
    8000511c:	2585                	addiw	a1,a1,1
    8000511e:	028a2503          	lw	a0,40(s4)
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	cce080e7          	jalr	-818(ra) # 80003df0 <bread>
    8000512a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000512c:	000aa583          	lw	a1,0(s5)
    80005130:	028a2503          	lw	a0,40(s4)
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	cbc080e7          	jalr	-836(ra) # 80003df0 <bread>
    8000513c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000513e:	40000613          	li	a2,1024
    80005142:	05850593          	addi	a1,a0,88
    80005146:	05848513          	addi	a0,s1,88
    8000514a:	ffffc097          	auipc	ra,0xffffc
    8000514e:	bd0080e7          	jalr	-1072(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80005152:	8526                	mv	a0,s1
    80005154:	fffff097          	auipc	ra,0xfffff
    80005158:	d8e080e7          	jalr	-626(ra) # 80003ee2 <bwrite>
    brelse(from);
    8000515c:	854e                	mv	a0,s3
    8000515e:	fffff097          	auipc	ra,0xfffff
    80005162:	dc2080e7          	jalr	-574(ra) # 80003f20 <brelse>
    brelse(to);
    80005166:	8526                	mv	a0,s1
    80005168:	fffff097          	auipc	ra,0xfffff
    8000516c:	db8080e7          	jalr	-584(ra) # 80003f20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005170:	2905                	addiw	s2,s2,1
    80005172:	0a91                	addi	s5,s5,4
    80005174:	02ca2783          	lw	a5,44(s4)
    80005178:	f8f94ee3          	blt	s2,a5,80005114 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000517c:	00000097          	auipc	ra,0x0
    80005180:	c66080e7          	jalr	-922(ra) # 80004de2 <write_head>
    install_trans(0); // Now install writes to home locations
    80005184:	4501                	li	a0,0
    80005186:	00000097          	auipc	ra,0x0
    8000518a:	cd8080e7          	jalr	-808(ra) # 80004e5e <install_trans>
    log.lh.n = 0;
    8000518e:	0003c797          	auipc	a5,0x3c
    80005192:	9207a323          	sw	zero,-1754(a5) # 80040ab4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005196:	00000097          	auipc	ra,0x0
    8000519a:	c4c080e7          	jalr	-948(ra) # 80004de2 <write_head>
    8000519e:	bdf5                	j	8000509a <end_op+0x52>

00000000800051a0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800051a0:	1101                	addi	sp,sp,-32
    800051a2:	ec06                	sd	ra,24(sp)
    800051a4:	e822                	sd	s0,16(sp)
    800051a6:	e426                	sd	s1,8(sp)
    800051a8:	e04a                	sd	s2,0(sp)
    800051aa:	1000                	addi	s0,sp,32
    800051ac:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800051ae:	0003c917          	auipc	s2,0x3c
    800051b2:	8da90913          	addi	s2,s2,-1830 # 80040a88 <log>
    800051b6:	854a                	mv	a0,s2
    800051b8:	ffffc097          	auipc	ra,0xffffc
    800051bc:	a0a080e7          	jalr	-1526(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800051c0:	02c92603          	lw	a2,44(s2)
    800051c4:	47f5                	li	a5,29
    800051c6:	06c7c563          	blt	a5,a2,80005230 <log_write+0x90>
    800051ca:	0003c797          	auipc	a5,0x3c
    800051ce:	8da7a783          	lw	a5,-1830(a5) # 80040aa4 <log+0x1c>
    800051d2:	37fd                	addiw	a5,a5,-1
    800051d4:	04f65e63          	bge	a2,a5,80005230 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800051d8:	0003c797          	auipc	a5,0x3c
    800051dc:	8d07a783          	lw	a5,-1840(a5) # 80040aa8 <log+0x20>
    800051e0:	06f05063          	blez	a5,80005240 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800051e4:	4781                	li	a5,0
    800051e6:	06c05563          	blez	a2,80005250 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800051ea:	44cc                	lw	a1,12(s1)
    800051ec:	0003c717          	auipc	a4,0x3c
    800051f0:	8cc70713          	addi	a4,a4,-1844 # 80040ab8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800051f4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800051f6:	4314                	lw	a3,0(a4)
    800051f8:	04b68c63          	beq	a3,a1,80005250 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800051fc:	2785                	addiw	a5,a5,1
    800051fe:	0711                	addi	a4,a4,4
    80005200:	fef61be3          	bne	a2,a5,800051f6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005204:	0621                	addi	a2,a2,8
    80005206:	060a                	slli	a2,a2,0x2
    80005208:	0003c797          	auipc	a5,0x3c
    8000520c:	88078793          	addi	a5,a5,-1920 # 80040a88 <log>
    80005210:	963e                	add	a2,a2,a5
    80005212:	44dc                	lw	a5,12(s1)
    80005214:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005216:	8526                	mv	a0,s1
    80005218:	fffff097          	auipc	ra,0xfffff
    8000521c:	da6080e7          	jalr	-602(ra) # 80003fbe <bpin>
    log.lh.n++;
    80005220:	0003c717          	auipc	a4,0x3c
    80005224:	86870713          	addi	a4,a4,-1944 # 80040a88 <log>
    80005228:	575c                	lw	a5,44(a4)
    8000522a:	2785                	addiw	a5,a5,1
    8000522c:	d75c                	sw	a5,44(a4)
    8000522e:	a835                	j	8000526a <log_write+0xca>
    panic("too big a transaction");
    80005230:	00004517          	auipc	a0,0x4
    80005234:	60850513          	addi	a0,a0,1544 # 80009838 <syscalls+0x270>
    80005238:	ffffb097          	auipc	ra,0xffffb
    8000523c:	2f2080e7          	jalr	754(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80005240:	00004517          	auipc	a0,0x4
    80005244:	61050513          	addi	a0,a0,1552 # 80009850 <syscalls+0x288>
    80005248:	ffffb097          	auipc	ra,0xffffb
    8000524c:	2e2080e7          	jalr	738(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80005250:	00878713          	addi	a4,a5,8
    80005254:	00271693          	slli	a3,a4,0x2
    80005258:	0003c717          	auipc	a4,0x3c
    8000525c:	83070713          	addi	a4,a4,-2000 # 80040a88 <log>
    80005260:	9736                	add	a4,a4,a3
    80005262:	44d4                	lw	a3,12(s1)
    80005264:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005266:	faf608e3          	beq	a2,a5,80005216 <log_write+0x76>
  }
  release(&log.lock);
    8000526a:	0003c517          	auipc	a0,0x3c
    8000526e:	81e50513          	addi	a0,a0,-2018 # 80040a88 <log>
    80005272:	ffffc097          	auipc	ra,0xffffc
    80005276:	a04080e7          	jalr	-1532(ra) # 80000c76 <release>
}
    8000527a:	60e2                	ld	ra,24(sp)
    8000527c:	6442                	ld	s0,16(sp)
    8000527e:	64a2                	ld	s1,8(sp)
    80005280:	6902                	ld	s2,0(sp)
    80005282:	6105                	addi	sp,sp,32
    80005284:	8082                	ret

0000000080005286 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005286:	1101                	addi	sp,sp,-32
    80005288:	ec06                	sd	ra,24(sp)
    8000528a:	e822                	sd	s0,16(sp)
    8000528c:	e426                	sd	s1,8(sp)
    8000528e:	e04a                	sd	s2,0(sp)
    80005290:	1000                	addi	s0,sp,32
    80005292:	84aa                	mv	s1,a0
    80005294:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005296:	00004597          	auipc	a1,0x4
    8000529a:	5da58593          	addi	a1,a1,1498 # 80009870 <syscalls+0x2a8>
    8000529e:	0521                	addi	a0,a0,8
    800052a0:	ffffc097          	auipc	ra,0xffffc
    800052a4:	892080e7          	jalr	-1902(ra) # 80000b32 <initlock>
  lk->name = name;
    800052a8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800052ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800052b0:	0204a423          	sw	zero,40(s1)
}
    800052b4:	60e2                	ld	ra,24(sp)
    800052b6:	6442                	ld	s0,16(sp)
    800052b8:	64a2                	ld	s1,8(sp)
    800052ba:	6902                	ld	s2,0(sp)
    800052bc:	6105                	addi	sp,sp,32
    800052be:	8082                	ret

00000000800052c0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800052c0:	1101                	addi	sp,sp,-32
    800052c2:	ec06                	sd	ra,24(sp)
    800052c4:	e822                	sd	s0,16(sp)
    800052c6:	e426                	sd	s1,8(sp)
    800052c8:	e04a                	sd	s2,0(sp)
    800052ca:	1000                	addi	s0,sp,32
    800052cc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800052ce:	00850913          	addi	s2,a0,8
    800052d2:	854a                	mv	a0,s2
    800052d4:	ffffc097          	auipc	ra,0xffffc
    800052d8:	8ee080e7          	jalr	-1810(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800052dc:	409c                	lw	a5,0(s1)
    800052de:	cb89                	beqz	a5,800052f0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800052e0:	85ca                	mv	a1,s2
    800052e2:	8526                	mv	a0,s1
    800052e4:	ffffd097          	auipc	ra,0xffffd
    800052e8:	142080e7          	jalr	322(ra) # 80002426 <sleep>
  while (lk->locked) {
    800052ec:	409c                	lw	a5,0(s1)
    800052ee:	fbed                	bnez	a5,800052e0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800052f0:	4785                	li	a5,1
    800052f2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800052f4:	ffffd097          	auipc	ra,0xffffd
    800052f8:	900080e7          	jalr	-1792(ra) # 80001bf4 <myproc>
    800052fc:	515c                	lw	a5,36(a0)
    800052fe:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005300:	854a                	mv	a0,s2
    80005302:	ffffc097          	auipc	ra,0xffffc
    80005306:	974080e7          	jalr	-1676(ra) # 80000c76 <release>
}
    8000530a:	60e2                	ld	ra,24(sp)
    8000530c:	6442                	ld	s0,16(sp)
    8000530e:	64a2                	ld	s1,8(sp)
    80005310:	6902                	ld	s2,0(sp)
    80005312:	6105                	addi	sp,sp,32
    80005314:	8082                	ret

0000000080005316 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005316:	1101                	addi	sp,sp,-32
    80005318:	ec06                	sd	ra,24(sp)
    8000531a:	e822                	sd	s0,16(sp)
    8000531c:	e426                	sd	s1,8(sp)
    8000531e:	e04a                	sd	s2,0(sp)
    80005320:	1000                	addi	s0,sp,32
    80005322:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005324:	00850913          	addi	s2,a0,8
    80005328:	854a                	mv	a0,s2
    8000532a:	ffffc097          	auipc	ra,0xffffc
    8000532e:	898080e7          	jalr	-1896(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80005332:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005336:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000533a:	8526                	mv	a0,s1
    8000533c:	ffffd097          	auipc	ra,0xffffd
    80005340:	272080e7          	jalr	626(ra) # 800025ae <wakeup>
  release(&lk->lk);
    80005344:	854a                	mv	a0,s2
    80005346:	ffffc097          	auipc	ra,0xffffc
    8000534a:	930080e7          	jalr	-1744(ra) # 80000c76 <release>
}
    8000534e:	60e2                	ld	ra,24(sp)
    80005350:	6442                	ld	s0,16(sp)
    80005352:	64a2                	ld	s1,8(sp)
    80005354:	6902                	ld	s2,0(sp)
    80005356:	6105                	addi	sp,sp,32
    80005358:	8082                	ret

000000008000535a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000535a:	7179                	addi	sp,sp,-48
    8000535c:	f406                	sd	ra,40(sp)
    8000535e:	f022                	sd	s0,32(sp)
    80005360:	ec26                	sd	s1,24(sp)
    80005362:	e84a                	sd	s2,16(sp)
    80005364:	e44e                	sd	s3,8(sp)
    80005366:	1800                	addi	s0,sp,48
    80005368:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000536a:	00850913          	addi	s2,a0,8
    8000536e:	854a                	mv	a0,s2
    80005370:	ffffc097          	auipc	ra,0xffffc
    80005374:	852080e7          	jalr	-1966(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80005378:	409c                	lw	a5,0(s1)
    8000537a:	ef99                	bnez	a5,80005398 <holdingsleep+0x3e>
    8000537c:	4481                	li	s1,0
  release(&lk->lk);
    8000537e:	854a                	mv	a0,s2
    80005380:	ffffc097          	auipc	ra,0xffffc
    80005384:	8f6080e7          	jalr	-1802(ra) # 80000c76 <release>
  return r;
}
    80005388:	8526                	mv	a0,s1
    8000538a:	70a2                	ld	ra,40(sp)
    8000538c:	7402                	ld	s0,32(sp)
    8000538e:	64e2                	ld	s1,24(sp)
    80005390:	6942                	ld	s2,16(sp)
    80005392:	69a2                	ld	s3,8(sp)
    80005394:	6145                	addi	sp,sp,48
    80005396:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005398:	0284a983          	lw	s3,40(s1)
    8000539c:	ffffd097          	auipc	ra,0xffffd
    800053a0:	858080e7          	jalr	-1960(ra) # 80001bf4 <myproc>
    800053a4:	5144                	lw	s1,36(a0)
    800053a6:	413484b3          	sub	s1,s1,s3
    800053aa:	0014b493          	seqz	s1,s1
    800053ae:	bfc1                	j	8000537e <holdingsleep+0x24>

00000000800053b0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800053b0:	1141                	addi	sp,sp,-16
    800053b2:	e406                	sd	ra,8(sp)
    800053b4:	e022                	sd	s0,0(sp)
    800053b6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800053b8:	00004597          	auipc	a1,0x4
    800053bc:	4c858593          	addi	a1,a1,1224 # 80009880 <syscalls+0x2b8>
    800053c0:	0003c517          	auipc	a0,0x3c
    800053c4:	81050513          	addi	a0,a0,-2032 # 80040bd0 <ftable>
    800053c8:	ffffb097          	auipc	ra,0xffffb
    800053cc:	76a080e7          	jalr	1898(ra) # 80000b32 <initlock>
}
    800053d0:	60a2                	ld	ra,8(sp)
    800053d2:	6402                	ld	s0,0(sp)
    800053d4:	0141                	addi	sp,sp,16
    800053d6:	8082                	ret

00000000800053d8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800053d8:	1101                	addi	sp,sp,-32
    800053da:	ec06                	sd	ra,24(sp)
    800053dc:	e822                	sd	s0,16(sp)
    800053de:	e426                	sd	s1,8(sp)
    800053e0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800053e2:	0003b517          	auipc	a0,0x3b
    800053e6:	7ee50513          	addi	a0,a0,2030 # 80040bd0 <ftable>
    800053ea:	ffffb097          	auipc	ra,0xffffb
    800053ee:	7d8080e7          	jalr	2008(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800053f2:	0003b497          	auipc	s1,0x3b
    800053f6:	7f648493          	addi	s1,s1,2038 # 80040be8 <ftable+0x18>
    800053fa:	0003c717          	auipc	a4,0x3c
    800053fe:	78e70713          	addi	a4,a4,1934 # 80041b88 <ftable+0xfb8>
    if(f->ref == 0){
    80005402:	40dc                	lw	a5,4(s1)
    80005404:	cf99                	beqz	a5,80005422 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005406:	02848493          	addi	s1,s1,40
    8000540a:	fee49ce3          	bne	s1,a4,80005402 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000540e:	0003b517          	auipc	a0,0x3b
    80005412:	7c250513          	addi	a0,a0,1986 # 80040bd0 <ftable>
    80005416:	ffffc097          	auipc	ra,0xffffc
    8000541a:	860080e7          	jalr	-1952(ra) # 80000c76 <release>
  return 0;
    8000541e:	4481                	li	s1,0
    80005420:	a819                	j	80005436 <filealloc+0x5e>
      f->ref = 1;
    80005422:	4785                	li	a5,1
    80005424:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005426:	0003b517          	auipc	a0,0x3b
    8000542a:	7aa50513          	addi	a0,a0,1962 # 80040bd0 <ftable>
    8000542e:	ffffc097          	auipc	ra,0xffffc
    80005432:	848080e7          	jalr	-1976(ra) # 80000c76 <release>
}
    80005436:	8526                	mv	a0,s1
    80005438:	60e2                	ld	ra,24(sp)
    8000543a:	6442                	ld	s0,16(sp)
    8000543c:	64a2                	ld	s1,8(sp)
    8000543e:	6105                	addi	sp,sp,32
    80005440:	8082                	ret

0000000080005442 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005442:	1101                	addi	sp,sp,-32
    80005444:	ec06                	sd	ra,24(sp)
    80005446:	e822                	sd	s0,16(sp)
    80005448:	e426                	sd	s1,8(sp)
    8000544a:	1000                	addi	s0,sp,32
    8000544c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000544e:	0003b517          	auipc	a0,0x3b
    80005452:	78250513          	addi	a0,a0,1922 # 80040bd0 <ftable>
    80005456:	ffffb097          	auipc	ra,0xffffb
    8000545a:	76c080e7          	jalr	1900(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    8000545e:	40dc                	lw	a5,4(s1)
    80005460:	02f05263          	blez	a5,80005484 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005464:	2785                	addiw	a5,a5,1
    80005466:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005468:	0003b517          	auipc	a0,0x3b
    8000546c:	76850513          	addi	a0,a0,1896 # 80040bd0 <ftable>
    80005470:	ffffc097          	auipc	ra,0xffffc
    80005474:	806080e7          	jalr	-2042(ra) # 80000c76 <release>
  return f;
}
    80005478:	8526                	mv	a0,s1
    8000547a:	60e2                	ld	ra,24(sp)
    8000547c:	6442                	ld	s0,16(sp)
    8000547e:	64a2                	ld	s1,8(sp)
    80005480:	6105                	addi	sp,sp,32
    80005482:	8082                	ret
    panic("filedup");
    80005484:	00004517          	auipc	a0,0x4
    80005488:	40450513          	addi	a0,a0,1028 # 80009888 <syscalls+0x2c0>
    8000548c:	ffffb097          	auipc	ra,0xffffb
    80005490:	09e080e7          	jalr	158(ra) # 8000052a <panic>

0000000080005494 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005494:	7139                	addi	sp,sp,-64
    80005496:	fc06                	sd	ra,56(sp)
    80005498:	f822                	sd	s0,48(sp)
    8000549a:	f426                	sd	s1,40(sp)
    8000549c:	f04a                	sd	s2,32(sp)
    8000549e:	ec4e                	sd	s3,24(sp)
    800054a0:	e852                	sd	s4,16(sp)
    800054a2:	e456                	sd	s5,8(sp)
    800054a4:	0080                	addi	s0,sp,64
    800054a6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800054a8:	0003b517          	auipc	a0,0x3b
    800054ac:	72850513          	addi	a0,a0,1832 # 80040bd0 <ftable>
    800054b0:	ffffb097          	auipc	ra,0xffffb
    800054b4:	712080e7          	jalr	1810(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    800054b8:	40dc                	lw	a5,4(s1)
    800054ba:	06f05163          	blez	a5,8000551c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800054be:	37fd                	addiw	a5,a5,-1
    800054c0:	0007871b          	sext.w	a4,a5
    800054c4:	c0dc                	sw	a5,4(s1)
    800054c6:	06e04363          	bgtz	a4,8000552c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800054ca:	0004a903          	lw	s2,0(s1)
    800054ce:	0094ca83          	lbu	s5,9(s1)
    800054d2:	0104ba03          	ld	s4,16(s1)
    800054d6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800054da:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800054de:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800054e2:	0003b517          	auipc	a0,0x3b
    800054e6:	6ee50513          	addi	a0,a0,1774 # 80040bd0 <ftable>
    800054ea:	ffffb097          	auipc	ra,0xffffb
    800054ee:	78c080e7          	jalr	1932(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    800054f2:	4785                	li	a5,1
    800054f4:	04f90d63          	beq	s2,a5,8000554e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800054f8:	3979                	addiw	s2,s2,-2
    800054fa:	4785                	li	a5,1
    800054fc:	0527e063          	bltu	a5,s2,8000553c <fileclose+0xa8>
    begin_op();
    80005500:	00000097          	auipc	ra,0x0
    80005504:	ac8080e7          	jalr	-1336(ra) # 80004fc8 <begin_op>
    iput(ff.ip);
    80005508:	854e                	mv	a0,s3
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	2a4080e7          	jalr	676(ra) # 800047ae <iput>
    end_op();
    80005512:	00000097          	auipc	ra,0x0
    80005516:	b36080e7          	jalr	-1226(ra) # 80005048 <end_op>
    8000551a:	a00d                	j	8000553c <fileclose+0xa8>
    panic("fileclose");
    8000551c:	00004517          	auipc	a0,0x4
    80005520:	37450513          	addi	a0,a0,884 # 80009890 <syscalls+0x2c8>
    80005524:	ffffb097          	auipc	ra,0xffffb
    80005528:	006080e7          	jalr	6(ra) # 8000052a <panic>
    release(&ftable.lock);
    8000552c:	0003b517          	auipc	a0,0x3b
    80005530:	6a450513          	addi	a0,a0,1700 # 80040bd0 <ftable>
    80005534:	ffffb097          	auipc	ra,0xffffb
    80005538:	742080e7          	jalr	1858(ra) # 80000c76 <release>
  }
}
    8000553c:	70e2                	ld	ra,56(sp)
    8000553e:	7442                	ld	s0,48(sp)
    80005540:	74a2                	ld	s1,40(sp)
    80005542:	7902                	ld	s2,32(sp)
    80005544:	69e2                	ld	s3,24(sp)
    80005546:	6a42                	ld	s4,16(sp)
    80005548:	6aa2                	ld	s5,8(sp)
    8000554a:	6121                	addi	sp,sp,64
    8000554c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000554e:	85d6                	mv	a1,s5
    80005550:	8552                	mv	a0,s4
    80005552:	00000097          	auipc	ra,0x0
    80005556:	34c080e7          	jalr	844(ra) # 8000589e <pipeclose>
    8000555a:	b7cd                	j	8000553c <fileclose+0xa8>

000000008000555c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000555c:	715d                	addi	sp,sp,-80
    8000555e:	e486                	sd	ra,72(sp)
    80005560:	e0a2                	sd	s0,64(sp)
    80005562:	fc26                	sd	s1,56(sp)
    80005564:	f84a                	sd	s2,48(sp)
    80005566:	f44e                	sd	s3,40(sp)
    80005568:	0880                	addi	s0,sp,80
    8000556a:	84aa                	mv	s1,a0
    8000556c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000556e:	ffffc097          	auipc	ra,0xffffc
    80005572:	686080e7          	jalr	1670(ra) # 80001bf4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005576:	409c                	lw	a5,0(s1)
    80005578:	37f9                	addiw	a5,a5,-2
    8000557a:	4705                	li	a4,1
    8000557c:	04f76763          	bltu	a4,a5,800055ca <filestat+0x6e>
    80005580:	892a                	mv	s2,a0
    ilock(f->ip);
    80005582:	6c88                	ld	a0,24(s1)
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	070080e7          	jalr	112(ra) # 800045f4 <ilock>
    stati(f->ip, &st);
    8000558c:	fb840593          	addi	a1,s0,-72
    80005590:	6c88                	ld	a0,24(s1)
    80005592:	fffff097          	auipc	ra,0xfffff
    80005596:	2ec080e7          	jalr	748(ra) # 8000487e <stati>
    iunlock(f->ip);
    8000559a:	6c88                	ld	a0,24(s1)
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	11a080e7          	jalr	282(ra) # 800046b6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800055a4:	46e1                	li	a3,24
    800055a6:	fb840613          	addi	a2,s0,-72
    800055aa:	85ce                	mv	a1,s3
    800055ac:	04093503          	ld	a0,64(s2)
    800055b0:	ffffc097          	auipc	ra,0xffffc
    800055b4:	096080e7          	jalr	150(ra) # 80001646 <copyout>
    800055b8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800055bc:	60a6                	ld	ra,72(sp)
    800055be:	6406                	ld	s0,64(sp)
    800055c0:	74e2                	ld	s1,56(sp)
    800055c2:	7942                	ld	s2,48(sp)
    800055c4:	79a2                	ld	s3,40(sp)
    800055c6:	6161                	addi	sp,sp,80
    800055c8:	8082                	ret
  return -1;
    800055ca:	557d                	li	a0,-1
    800055cc:	bfc5                	j	800055bc <filestat+0x60>

00000000800055ce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800055ce:	7179                	addi	sp,sp,-48
    800055d0:	f406                	sd	ra,40(sp)
    800055d2:	f022                	sd	s0,32(sp)
    800055d4:	ec26                	sd	s1,24(sp)
    800055d6:	e84a                	sd	s2,16(sp)
    800055d8:	e44e                	sd	s3,8(sp)
    800055da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800055dc:	00854783          	lbu	a5,8(a0)
    800055e0:	c3d5                	beqz	a5,80005684 <fileread+0xb6>
    800055e2:	84aa                	mv	s1,a0
    800055e4:	89ae                	mv	s3,a1
    800055e6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800055e8:	411c                	lw	a5,0(a0)
    800055ea:	4705                	li	a4,1
    800055ec:	04e78963          	beq	a5,a4,8000563e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800055f0:	470d                	li	a4,3
    800055f2:	04e78d63          	beq	a5,a4,8000564c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800055f6:	4709                	li	a4,2
    800055f8:	06e79e63          	bne	a5,a4,80005674 <fileread+0xa6>
    ilock(f->ip);
    800055fc:	6d08                	ld	a0,24(a0)
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	ff6080e7          	jalr	-10(ra) # 800045f4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005606:	874a                	mv	a4,s2
    80005608:	5094                	lw	a3,32(s1)
    8000560a:	864e                	mv	a2,s3
    8000560c:	4585                	li	a1,1
    8000560e:	6c88                	ld	a0,24(s1)
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	298080e7          	jalr	664(ra) # 800048a8 <readi>
    80005618:	892a                	mv	s2,a0
    8000561a:	00a05563          	blez	a0,80005624 <fileread+0x56>
      f->off += r;
    8000561e:	509c                	lw	a5,32(s1)
    80005620:	9fa9                	addw	a5,a5,a0
    80005622:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005624:	6c88                	ld	a0,24(s1)
    80005626:	fffff097          	auipc	ra,0xfffff
    8000562a:	090080e7          	jalr	144(ra) # 800046b6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000562e:	854a                	mv	a0,s2
    80005630:	70a2                	ld	ra,40(sp)
    80005632:	7402                	ld	s0,32(sp)
    80005634:	64e2                	ld	s1,24(sp)
    80005636:	6942                	ld	s2,16(sp)
    80005638:	69a2                	ld	s3,8(sp)
    8000563a:	6145                	addi	sp,sp,48
    8000563c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000563e:	6908                	ld	a0,16(a0)
    80005640:	00000097          	auipc	ra,0x0
    80005644:	3c0080e7          	jalr	960(ra) # 80005a00 <piperead>
    80005648:	892a                	mv	s2,a0
    8000564a:	b7d5                	j	8000562e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000564c:	02451783          	lh	a5,36(a0)
    80005650:	03079693          	slli	a3,a5,0x30
    80005654:	92c1                	srli	a3,a3,0x30
    80005656:	4725                	li	a4,9
    80005658:	02d76863          	bltu	a4,a3,80005688 <fileread+0xba>
    8000565c:	0792                	slli	a5,a5,0x4
    8000565e:	0003b717          	auipc	a4,0x3b
    80005662:	4d270713          	addi	a4,a4,1234 # 80040b30 <devsw>
    80005666:	97ba                	add	a5,a5,a4
    80005668:	639c                	ld	a5,0(a5)
    8000566a:	c38d                	beqz	a5,8000568c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000566c:	4505                	li	a0,1
    8000566e:	9782                	jalr	a5
    80005670:	892a                	mv	s2,a0
    80005672:	bf75                	j	8000562e <fileread+0x60>
    panic("fileread");
    80005674:	00004517          	auipc	a0,0x4
    80005678:	22c50513          	addi	a0,a0,556 # 800098a0 <syscalls+0x2d8>
    8000567c:	ffffb097          	auipc	ra,0xffffb
    80005680:	eae080e7          	jalr	-338(ra) # 8000052a <panic>
    return -1;
    80005684:	597d                	li	s2,-1
    80005686:	b765                	j	8000562e <fileread+0x60>
      return -1;
    80005688:	597d                	li	s2,-1
    8000568a:	b755                	j	8000562e <fileread+0x60>
    8000568c:	597d                	li	s2,-1
    8000568e:	b745                	j	8000562e <fileread+0x60>

0000000080005690 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005690:	715d                	addi	sp,sp,-80
    80005692:	e486                	sd	ra,72(sp)
    80005694:	e0a2                	sd	s0,64(sp)
    80005696:	fc26                	sd	s1,56(sp)
    80005698:	f84a                	sd	s2,48(sp)
    8000569a:	f44e                	sd	s3,40(sp)
    8000569c:	f052                	sd	s4,32(sp)
    8000569e:	ec56                	sd	s5,24(sp)
    800056a0:	e85a                	sd	s6,16(sp)
    800056a2:	e45e                	sd	s7,8(sp)
    800056a4:	e062                	sd	s8,0(sp)
    800056a6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800056a8:	00954783          	lbu	a5,9(a0)
    800056ac:	10078663          	beqz	a5,800057b8 <filewrite+0x128>
    800056b0:	892a                	mv	s2,a0
    800056b2:	8aae                	mv	s5,a1
    800056b4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800056b6:	411c                	lw	a5,0(a0)
    800056b8:	4705                	li	a4,1
    800056ba:	02e78263          	beq	a5,a4,800056de <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800056be:	470d                	li	a4,3
    800056c0:	02e78663          	beq	a5,a4,800056ec <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800056c4:	4709                	li	a4,2
    800056c6:	0ee79163          	bne	a5,a4,800057a8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800056ca:	0ac05d63          	blez	a2,80005784 <filewrite+0xf4>
    int i = 0;
    800056ce:	4981                	li	s3,0
    800056d0:	6b05                	lui	s6,0x1
    800056d2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800056d6:	6b85                	lui	s7,0x1
    800056d8:	c00b8b9b          	addiw	s7,s7,-1024
    800056dc:	a861                	j	80005774 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800056de:	6908                	ld	a0,16(a0)
    800056e0:	00000097          	auipc	ra,0x0
    800056e4:	22e080e7          	jalr	558(ra) # 8000590e <pipewrite>
    800056e8:	8a2a                	mv	s4,a0
    800056ea:	a045                	j	8000578a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800056ec:	02451783          	lh	a5,36(a0)
    800056f0:	03079693          	slli	a3,a5,0x30
    800056f4:	92c1                	srli	a3,a3,0x30
    800056f6:	4725                	li	a4,9
    800056f8:	0cd76263          	bltu	a4,a3,800057bc <filewrite+0x12c>
    800056fc:	0792                	slli	a5,a5,0x4
    800056fe:	0003b717          	auipc	a4,0x3b
    80005702:	43270713          	addi	a4,a4,1074 # 80040b30 <devsw>
    80005706:	97ba                	add	a5,a5,a4
    80005708:	679c                	ld	a5,8(a5)
    8000570a:	cbdd                	beqz	a5,800057c0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000570c:	4505                	li	a0,1
    8000570e:	9782                	jalr	a5
    80005710:	8a2a                	mv	s4,a0
    80005712:	a8a5                	j	8000578a <filewrite+0xfa>
    80005714:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005718:	00000097          	auipc	ra,0x0
    8000571c:	8b0080e7          	jalr	-1872(ra) # 80004fc8 <begin_op>
      ilock(f->ip);
    80005720:	01893503          	ld	a0,24(s2)
    80005724:	fffff097          	auipc	ra,0xfffff
    80005728:	ed0080e7          	jalr	-304(ra) # 800045f4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000572c:	8762                	mv	a4,s8
    8000572e:	02092683          	lw	a3,32(s2)
    80005732:	01598633          	add	a2,s3,s5
    80005736:	4585                	li	a1,1
    80005738:	01893503          	ld	a0,24(s2)
    8000573c:	fffff097          	auipc	ra,0xfffff
    80005740:	264080e7          	jalr	612(ra) # 800049a0 <writei>
    80005744:	84aa                	mv	s1,a0
    80005746:	00a05763          	blez	a0,80005754 <filewrite+0xc4>
        f->off += r;
    8000574a:	02092783          	lw	a5,32(s2)
    8000574e:	9fa9                	addw	a5,a5,a0
    80005750:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005754:	01893503          	ld	a0,24(s2)
    80005758:	fffff097          	auipc	ra,0xfffff
    8000575c:	f5e080e7          	jalr	-162(ra) # 800046b6 <iunlock>
      end_op();
    80005760:	00000097          	auipc	ra,0x0
    80005764:	8e8080e7          	jalr	-1816(ra) # 80005048 <end_op>

      if(r != n1){
    80005768:	009c1f63          	bne	s8,s1,80005786 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000576c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005770:	0149db63          	bge	s3,s4,80005786 <filewrite+0xf6>
      int n1 = n - i;
    80005774:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005778:	84be                	mv	s1,a5
    8000577a:	2781                	sext.w	a5,a5
    8000577c:	f8fb5ce3          	bge	s6,a5,80005714 <filewrite+0x84>
    80005780:	84de                	mv	s1,s7
    80005782:	bf49                	j	80005714 <filewrite+0x84>
    int i = 0;
    80005784:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005786:	013a1f63          	bne	s4,s3,800057a4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000578a:	8552                	mv	a0,s4
    8000578c:	60a6                	ld	ra,72(sp)
    8000578e:	6406                	ld	s0,64(sp)
    80005790:	74e2                	ld	s1,56(sp)
    80005792:	7942                	ld	s2,48(sp)
    80005794:	79a2                	ld	s3,40(sp)
    80005796:	7a02                	ld	s4,32(sp)
    80005798:	6ae2                	ld	s5,24(sp)
    8000579a:	6b42                	ld	s6,16(sp)
    8000579c:	6ba2                	ld	s7,8(sp)
    8000579e:	6c02                	ld	s8,0(sp)
    800057a0:	6161                	addi	sp,sp,80
    800057a2:	8082                	ret
    ret = (i == n ? n : -1);
    800057a4:	5a7d                	li	s4,-1
    800057a6:	b7d5                	j	8000578a <filewrite+0xfa>
    panic("filewrite");
    800057a8:	00004517          	auipc	a0,0x4
    800057ac:	10850513          	addi	a0,a0,264 # 800098b0 <syscalls+0x2e8>
    800057b0:	ffffb097          	auipc	ra,0xffffb
    800057b4:	d7a080e7          	jalr	-646(ra) # 8000052a <panic>
    return -1;
    800057b8:	5a7d                	li	s4,-1
    800057ba:	bfc1                	j	8000578a <filewrite+0xfa>
      return -1;
    800057bc:	5a7d                	li	s4,-1
    800057be:	b7f1                	j	8000578a <filewrite+0xfa>
    800057c0:	5a7d                	li	s4,-1
    800057c2:	b7e1                	j	8000578a <filewrite+0xfa>

00000000800057c4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800057c4:	7179                	addi	sp,sp,-48
    800057c6:	f406                	sd	ra,40(sp)
    800057c8:	f022                	sd	s0,32(sp)
    800057ca:	ec26                	sd	s1,24(sp)
    800057cc:	e84a                	sd	s2,16(sp)
    800057ce:	e44e                	sd	s3,8(sp)
    800057d0:	e052                	sd	s4,0(sp)
    800057d2:	1800                	addi	s0,sp,48
    800057d4:	84aa                	mv	s1,a0
    800057d6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800057d8:	0005b023          	sd	zero,0(a1)
    800057dc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800057e0:	00000097          	auipc	ra,0x0
    800057e4:	bf8080e7          	jalr	-1032(ra) # 800053d8 <filealloc>
    800057e8:	e088                	sd	a0,0(s1)
    800057ea:	c551                	beqz	a0,80005876 <pipealloc+0xb2>
    800057ec:	00000097          	auipc	ra,0x0
    800057f0:	bec080e7          	jalr	-1044(ra) # 800053d8 <filealloc>
    800057f4:	00aa3023          	sd	a0,0(s4)
    800057f8:	c92d                	beqz	a0,8000586a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800057fa:	ffffb097          	auipc	ra,0xffffb
    800057fe:	2d8080e7          	jalr	728(ra) # 80000ad2 <kalloc>
    80005802:	892a                	mv	s2,a0
    80005804:	c125                	beqz	a0,80005864 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005806:	4985                	li	s3,1
    80005808:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000580c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005810:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005814:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005818:	00004597          	auipc	a1,0x4
    8000581c:	0a858593          	addi	a1,a1,168 # 800098c0 <syscalls+0x2f8>
    80005820:	ffffb097          	auipc	ra,0xffffb
    80005824:	312080e7          	jalr	786(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80005828:	609c                	ld	a5,0(s1)
    8000582a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000582e:	609c                	ld	a5,0(s1)
    80005830:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005834:	609c                	ld	a5,0(s1)
    80005836:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000583a:	609c                	ld	a5,0(s1)
    8000583c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005840:	000a3783          	ld	a5,0(s4)
    80005844:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005848:	000a3783          	ld	a5,0(s4)
    8000584c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005850:	000a3783          	ld	a5,0(s4)
    80005854:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005858:	000a3783          	ld	a5,0(s4)
    8000585c:	0127b823          	sd	s2,16(a5)
  return 0;
    80005860:	4501                	li	a0,0
    80005862:	a025                	j	8000588a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005864:	6088                	ld	a0,0(s1)
    80005866:	e501                	bnez	a0,8000586e <pipealloc+0xaa>
    80005868:	a039                	j	80005876 <pipealloc+0xb2>
    8000586a:	6088                	ld	a0,0(s1)
    8000586c:	c51d                	beqz	a0,8000589a <pipealloc+0xd6>
    fileclose(*f0);
    8000586e:	00000097          	auipc	ra,0x0
    80005872:	c26080e7          	jalr	-986(ra) # 80005494 <fileclose>
  if(*f1)
    80005876:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000587a:	557d                	li	a0,-1
  if(*f1)
    8000587c:	c799                	beqz	a5,8000588a <pipealloc+0xc6>
    fileclose(*f1);
    8000587e:	853e                	mv	a0,a5
    80005880:	00000097          	auipc	ra,0x0
    80005884:	c14080e7          	jalr	-1004(ra) # 80005494 <fileclose>
  return -1;
    80005888:	557d                	li	a0,-1
}
    8000588a:	70a2                	ld	ra,40(sp)
    8000588c:	7402                	ld	s0,32(sp)
    8000588e:	64e2                	ld	s1,24(sp)
    80005890:	6942                	ld	s2,16(sp)
    80005892:	69a2                	ld	s3,8(sp)
    80005894:	6a02                	ld	s4,0(sp)
    80005896:	6145                	addi	sp,sp,48
    80005898:	8082                	ret
  return -1;
    8000589a:	557d                	li	a0,-1
    8000589c:	b7fd                	j	8000588a <pipealloc+0xc6>

000000008000589e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000589e:	1101                	addi	sp,sp,-32
    800058a0:	ec06                	sd	ra,24(sp)
    800058a2:	e822                	sd	s0,16(sp)
    800058a4:	e426                	sd	s1,8(sp)
    800058a6:	e04a                	sd	s2,0(sp)
    800058a8:	1000                	addi	s0,sp,32
    800058aa:	84aa                	mv	s1,a0
    800058ac:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800058ae:	ffffb097          	auipc	ra,0xffffb
    800058b2:	314080e7          	jalr	788(ra) # 80000bc2 <acquire>
  if(writable){
    800058b6:	02090d63          	beqz	s2,800058f0 <pipeclose+0x52>
    pi->writeopen = 0;
    800058ba:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800058be:	21848513          	addi	a0,s1,536
    800058c2:	ffffd097          	auipc	ra,0xffffd
    800058c6:	cec080e7          	jalr	-788(ra) # 800025ae <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800058ca:	2204b783          	ld	a5,544(s1)
    800058ce:	eb95                	bnez	a5,80005902 <pipeclose+0x64>
    release(&pi->lock);
    800058d0:	8526                	mv	a0,s1
    800058d2:	ffffb097          	auipc	ra,0xffffb
    800058d6:	3a4080e7          	jalr	932(ra) # 80000c76 <release>
    kfree((char*)pi);
    800058da:	8526                	mv	a0,s1
    800058dc:	ffffb097          	auipc	ra,0xffffb
    800058e0:	0fa080e7          	jalr	250(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    800058e4:	60e2                	ld	ra,24(sp)
    800058e6:	6442                	ld	s0,16(sp)
    800058e8:	64a2                	ld	s1,8(sp)
    800058ea:	6902                	ld	s2,0(sp)
    800058ec:	6105                	addi	sp,sp,32
    800058ee:	8082                	ret
    pi->readopen = 0;
    800058f0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800058f4:	21c48513          	addi	a0,s1,540
    800058f8:	ffffd097          	auipc	ra,0xffffd
    800058fc:	cb6080e7          	jalr	-842(ra) # 800025ae <wakeup>
    80005900:	b7e9                	j	800058ca <pipeclose+0x2c>
    release(&pi->lock);
    80005902:	8526                	mv	a0,s1
    80005904:	ffffb097          	auipc	ra,0xffffb
    80005908:	372080e7          	jalr	882(ra) # 80000c76 <release>
}
    8000590c:	bfe1                	j	800058e4 <pipeclose+0x46>

000000008000590e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000590e:	711d                	addi	sp,sp,-96
    80005910:	ec86                	sd	ra,88(sp)
    80005912:	e8a2                	sd	s0,80(sp)
    80005914:	e4a6                	sd	s1,72(sp)
    80005916:	e0ca                	sd	s2,64(sp)
    80005918:	fc4e                	sd	s3,56(sp)
    8000591a:	f852                	sd	s4,48(sp)
    8000591c:	f456                	sd	s5,40(sp)
    8000591e:	f05a                	sd	s6,32(sp)
    80005920:	ec5e                	sd	s7,24(sp)
    80005922:	e862                	sd	s8,16(sp)
    80005924:	1080                	addi	s0,sp,96
    80005926:	84aa                	mv	s1,a0
    80005928:	8aae                	mv	s5,a1
    8000592a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000592c:	ffffc097          	auipc	ra,0xffffc
    80005930:	2c8080e7          	jalr	712(ra) # 80001bf4 <myproc>
    80005934:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005936:	8526                	mv	a0,s1
    80005938:	ffffb097          	auipc	ra,0xffffb
    8000593c:	28a080e7          	jalr	650(ra) # 80000bc2 <acquire>
  while(i < n){
    80005940:	0b405363          	blez	s4,800059e6 <pipewrite+0xd8>
  int i = 0;
    80005944:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005946:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005948:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000594c:	21c48b93          	addi	s7,s1,540
    80005950:	a089                	j	80005992 <pipewrite+0x84>
      release(&pi->lock);
    80005952:	8526                	mv	a0,s1
    80005954:	ffffb097          	auipc	ra,0xffffb
    80005958:	322080e7          	jalr	802(ra) # 80000c76 <release>
      return -1;
    8000595c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000595e:	854a                	mv	a0,s2
    80005960:	60e6                	ld	ra,88(sp)
    80005962:	6446                	ld	s0,80(sp)
    80005964:	64a6                	ld	s1,72(sp)
    80005966:	6906                	ld	s2,64(sp)
    80005968:	79e2                	ld	s3,56(sp)
    8000596a:	7a42                	ld	s4,48(sp)
    8000596c:	7aa2                	ld	s5,40(sp)
    8000596e:	7b02                	ld	s6,32(sp)
    80005970:	6be2                	ld	s7,24(sp)
    80005972:	6c42                	ld	s8,16(sp)
    80005974:	6125                	addi	sp,sp,96
    80005976:	8082                	ret
      wakeup(&pi->nread);
    80005978:	8562                	mv	a0,s8
    8000597a:	ffffd097          	auipc	ra,0xffffd
    8000597e:	c34080e7          	jalr	-972(ra) # 800025ae <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005982:	85a6                	mv	a1,s1
    80005984:	855e                	mv	a0,s7
    80005986:	ffffd097          	auipc	ra,0xffffd
    8000598a:	aa0080e7          	jalr	-1376(ra) # 80002426 <sleep>
  while(i < n){
    8000598e:	05495d63          	bge	s2,s4,800059e8 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005992:	2204a783          	lw	a5,544(s1)
    80005996:	dfd5                	beqz	a5,80005952 <pipewrite+0x44>
    80005998:	01c9a783          	lw	a5,28(s3)
    8000599c:	fbdd                	bnez	a5,80005952 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000599e:	2184a783          	lw	a5,536(s1)
    800059a2:	21c4a703          	lw	a4,540(s1)
    800059a6:	2007879b          	addiw	a5,a5,512
    800059aa:	fcf707e3          	beq	a4,a5,80005978 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800059ae:	4685                	li	a3,1
    800059b0:	01590633          	add	a2,s2,s5
    800059b4:	faf40593          	addi	a1,s0,-81
    800059b8:	0409b503          	ld	a0,64(s3)
    800059bc:	ffffc097          	auipc	ra,0xffffc
    800059c0:	d16080e7          	jalr	-746(ra) # 800016d2 <copyin>
    800059c4:	03650263          	beq	a0,s6,800059e8 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800059c8:	21c4a783          	lw	a5,540(s1)
    800059cc:	0017871b          	addiw	a4,a5,1
    800059d0:	20e4ae23          	sw	a4,540(s1)
    800059d4:	1ff7f793          	andi	a5,a5,511
    800059d8:	97a6                	add	a5,a5,s1
    800059da:	faf44703          	lbu	a4,-81(s0)
    800059de:	00e78c23          	sb	a4,24(a5)
      i++;
    800059e2:	2905                	addiw	s2,s2,1
    800059e4:	b76d                	j	8000598e <pipewrite+0x80>
  int i = 0;
    800059e6:	4901                	li	s2,0
  wakeup(&pi->nread);
    800059e8:	21848513          	addi	a0,s1,536
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	bc2080e7          	jalr	-1086(ra) # 800025ae <wakeup>
  release(&pi->lock);
    800059f4:	8526                	mv	a0,s1
    800059f6:	ffffb097          	auipc	ra,0xffffb
    800059fa:	280080e7          	jalr	640(ra) # 80000c76 <release>
  return i;
    800059fe:	b785                	j	8000595e <pipewrite+0x50>

0000000080005a00 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005a00:	715d                	addi	sp,sp,-80
    80005a02:	e486                	sd	ra,72(sp)
    80005a04:	e0a2                	sd	s0,64(sp)
    80005a06:	fc26                	sd	s1,56(sp)
    80005a08:	f84a                	sd	s2,48(sp)
    80005a0a:	f44e                	sd	s3,40(sp)
    80005a0c:	f052                	sd	s4,32(sp)
    80005a0e:	ec56                	sd	s5,24(sp)
    80005a10:	e85a                	sd	s6,16(sp)
    80005a12:	0880                	addi	s0,sp,80
    80005a14:	84aa                	mv	s1,a0
    80005a16:	892e                	mv	s2,a1
    80005a18:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005a1a:	ffffc097          	auipc	ra,0xffffc
    80005a1e:	1da080e7          	jalr	474(ra) # 80001bf4 <myproc>
    80005a22:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005a24:	8526                	mv	a0,s1
    80005a26:	ffffb097          	auipc	ra,0xffffb
    80005a2a:	19c080e7          	jalr	412(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a2e:	2184a703          	lw	a4,536(s1)
    80005a32:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005a36:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a3a:	02f71463          	bne	a4,a5,80005a62 <piperead+0x62>
    80005a3e:	2244a783          	lw	a5,548(s1)
    80005a42:	c385                	beqz	a5,80005a62 <piperead+0x62>
    if(pr->killed){
    80005a44:	01ca2783          	lw	a5,28(s4)
    80005a48:	ebc1                	bnez	a5,80005ad8 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005a4a:	85a6                	mv	a1,s1
    80005a4c:	854e                	mv	a0,s3
    80005a4e:	ffffd097          	auipc	ra,0xffffd
    80005a52:	9d8080e7          	jalr	-1576(ra) # 80002426 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a56:	2184a703          	lw	a4,536(s1)
    80005a5a:	21c4a783          	lw	a5,540(s1)
    80005a5e:	fef700e3          	beq	a4,a5,80005a3e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a62:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005a64:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a66:	05505363          	blez	s5,80005aac <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005a6a:	2184a783          	lw	a5,536(s1)
    80005a6e:	21c4a703          	lw	a4,540(s1)
    80005a72:	02f70d63          	beq	a4,a5,80005aac <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005a76:	0017871b          	addiw	a4,a5,1
    80005a7a:	20e4ac23          	sw	a4,536(s1)
    80005a7e:	1ff7f793          	andi	a5,a5,511
    80005a82:	97a6                	add	a5,a5,s1
    80005a84:	0187c783          	lbu	a5,24(a5)
    80005a88:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005a8c:	4685                	li	a3,1
    80005a8e:	fbf40613          	addi	a2,s0,-65
    80005a92:	85ca                	mv	a1,s2
    80005a94:	040a3503          	ld	a0,64(s4)
    80005a98:	ffffc097          	auipc	ra,0xffffc
    80005a9c:	bae080e7          	jalr	-1106(ra) # 80001646 <copyout>
    80005aa0:	01650663          	beq	a0,s6,80005aac <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005aa4:	2985                	addiw	s3,s3,1
    80005aa6:	0905                	addi	s2,s2,1
    80005aa8:	fd3a91e3          	bne	s5,s3,80005a6a <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005aac:	21c48513          	addi	a0,s1,540
    80005ab0:	ffffd097          	auipc	ra,0xffffd
    80005ab4:	afe080e7          	jalr	-1282(ra) # 800025ae <wakeup>
  release(&pi->lock);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffb097          	auipc	ra,0xffffb
    80005abe:	1bc080e7          	jalr	444(ra) # 80000c76 <release>
  return i;
}
    80005ac2:	854e                	mv	a0,s3
    80005ac4:	60a6                	ld	ra,72(sp)
    80005ac6:	6406                	ld	s0,64(sp)
    80005ac8:	74e2                	ld	s1,56(sp)
    80005aca:	7942                	ld	s2,48(sp)
    80005acc:	79a2                	ld	s3,40(sp)
    80005ace:	7a02                	ld	s4,32(sp)
    80005ad0:	6ae2                	ld	s5,24(sp)
    80005ad2:	6b42                	ld	s6,16(sp)
    80005ad4:	6161                	addi	sp,sp,80
    80005ad6:	8082                	ret
      release(&pi->lock);
    80005ad8:	8526                	mv	a0,s1
    80005ada:	ffffb097          	auipc	ra,0xffffb
    80005ade:	19c080e7          	jalr	412(ra) # 80000c76 <release>
      return -1;
    80005ae2:	59fd                	li	s3,-1
    80005ae4:	bff9                	j	80005ac2 <piperead+0xc2>

0000000080005ae6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005ae6:	de010113          	addi	sp,sp,-544
    80005aea:	20113c23          	sd	ra,536(sp)
    80005aee:	20813823          	sd	s0,528(sp)
    80005af2:	20913423          	sd	s1,520(sp)
    80005af6:	21213023          	sd	s2,512(sp)
    80005afa:	ffce                	sd	s3,504(sp)
    80005afc:	fbd2                	sd	s4,496(sp)
    80005afe:	f7d6                	sd	s5,488(sp)
    80005b00:	f3da                	sd	s6,480(sp)
    80005b02:	efde                	sd	s7,472(sp)
    80005b04:	ebe2                	sd	s8,464(sp)
    80005b06:	e7e6                	sd	s9,456(sp)
    80005b08:	e3ea                	sd	s10,448(sp)
    80005b0a:	ff6e                	sd	s11,440(sp)
    80005b0c:	1400                	addi	s0,sp,544
    80005b0e:	892a                	mv	s2,a0
    80005b10:	dea43423          	sd	a0,-536(s0)
    80005b14:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005b18:	ffffc097          	auipc	ra,0xffffc
    80005b1c:	0dc080e7          	jalr	220(ra) # 80001bf4 <myproc>
    80005b20:	84aa                	mv	s1,a0

  begin_op();
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	4a6080e7          	jalr	1190(ra) # 80004fc8 <begin_op>

  if((ip = namei(path)) == 0){
    80005b2a:	854a                	mv	a0,s2
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	27c080e7          	jalr	636(ra) # 80004da8 <namei>
    80005b34:	c93d                	beqz	a0,80005baa <exec+0xc4>
    80005b36:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	abc080e7          	jalr	-1348(ra) # 800045f4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005b40:	04000713          	li	a4,64
    80005b44:	4681                	li	a3,0
    80005b46:	e4840613          	addi	a2,s0,-440
    80005b4a:	4581                	li	a1,0
    80005b4c:	8556                	mv	a0,s5
    80005b4e:	fffff097          	auipc	ra,0xfffff
    80005b52:	d5a080e7          	jalr	-678(ra) # 800048a8 <readi>
    80005b56:	04000793          	li	a5,64
    80005b5a:	00f51a63          	bne	a0,a5,80005b6e <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005b5e:	e4842703          	lw	a4,-440(s0)
    80005b62:	464c47b7          	lui	a5,0x464c4
    80005b66:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005b6a:	04f70663          	beq	a4,a5,80005bb6 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005b6e:	8556                	mv	a0,s5
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	ce6080e7          	jalr	-794(ra) # 80004856 <iunlockput>
    end_op();
    80005b78:	fffff097          	auipc	ra,0xfffff
    80005b7c:	4d0080e7          	jalr	1232(ra) # 80005048 <end_op>
  }
  return -1;
    80005b80:	557d                	li	a0,-1
}
    80005b82:	21813083          	ld	ra,536(sp)
    80005b86:	21013403          	ld	s0,528(sp)
    80005b8a:	20813483          	ld	s1,520(sp)
    80005b8e:	20013903          	ld	s2,512(sp)
    80005b92:	79fe                	ld	s3,504(sp)
    80005b94:	7a5e                	ld	s4,496(sp)
    80005b96:	7abe                	ld	s5,488(sp)
    80005b98:	7b1e                	ld	s6,480(sp)
    80005b9a:	6bfe                	ld	s7,472(sp)
    80005b9c:	6c5e                	ld	s8,464(sp)
    80005b9e:	6cbe                	ld	s9,456(sp)
    80005ba0:	6d1e                	ld	s10,448(sp)
    80005ba2:	7dfa                	ld	s11,440(sp)
    80005ba4:	22010113          	addi	sp,sp,544
    80005ba8:	8082                	ret
    end_op();
    80005baa:	fffff097          	auipc	ra,0xfffff
    80005bae:	49e080e7          	jalr	1182(ra) # 80005048 <end_op>
    return -1;
    80005bb2:	557d                	li	a0,-1
    80005bb4:	b7f9                	j	80005b82 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005bb6:	8526                	mv	a0,s1
    80005bb8:	ffffc097          	auipc	ra,0xffffc
    80005bbc:	10a080e7          	jalr	266(ra) # 80001cc2 <proc_pagetable>
    80005bc0:	8b2a                	mv	s6,a0
    80005bc2:	d555                	beqz	a0,80005b6e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005bc4:	e6842783          	lw	a5,-408(s0)
    80005bc8:	e8045703          	lhu	a4,-384(s0)
    80005bcc:	c735                	beqz	a4,80005c38 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005bce:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005bd0:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005bd4:	6a05                	lui	s4,0x1
    80005bd6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005bda:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005bde:	6d85                	lui	s11,0x1
    80005be0:	7d7d                	lui	s10,0xfffff
    80005be2:	a4bd                	j	80005e50 <exec+0x36a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005be4:	00004517          	auipc	a0,0x4
    80005be8:	ce450513          	addi	a0,a0,-796 # 800098c8 <syscalls+0x300>
    80005bec:	ffffb097          	auipc	ra,0xffffb
    80005bf0:	93e080e7          	jalr	-1730(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005bf4:	874a                	mv	a4,s2
    80005bf6:	009c86bb          	addw	a3,s9,s1
    80005bfa:	4581                	li	a1,0
    80005bfc:	8556                	mv	a0,s5
    80005bfe:	fffff097          	auipc	ra,0xfffff
    80005c02:	caa080e7          	jalr	-854(ra) # 800048a8 <readi>
    80005c06:	2501                	sext.w	a0,a0
    80005c08:	1ea91463          	bne	s2,a0,80005df0 <exec+0x30a>
  for(i = 0; i < sz; i += PGSIZE){
    80005c0c:	009d84bb          	addw	s1,s11,s1
    80005c10:	013d09bb          	addw	s3,s10,s3
    80005c14:	2174fe63          	bgeu	s1,s7,80005e30 <exec+0x34a>
    pa = walkaddr(pagetable, va + i);
    80005c18:	02049593          	slli	a1,s1,0x20
    80005c1c:	9181                	srli	a1,a1,0x20
    80005c1e:	95e2                	add	a1,a1,s8
    80005c20:	855a                	mv	a0,s6
    80005c22:	ffffb097          	auipc	ra,0xffffb
    80005c26:	432080e7          	jalr	1074(ra) # 80001054 <walkaddr>
    80005c2a:	862a                	mv	a2,a0
    if(pa == 0)
    80005c2c:	dd45                	beqz	a0,80005be4 <exec+0xfe>
      n = PGSIZE;
    80005c2e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005c30:	fd49f2e3          	bgeu	s3,s4,80005bf4 <exec+0x10e>
      n = sz - i;
    80005c34:	894e                	mv	s2,s3
    80005c36:	bf7d                	j	80005bf4 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005c38:	4481                	li	s1,0
  iunlockput(ip);
    80005c3a:	8556                	mv	a0,s5
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	c1a080e7          	jalr	-998(ra) # 80004856 <iunlockput>
  end_op();
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	404080e7          	jalr	1028(ra) # 80005048 <end_op>
  p = myproc();
    80005c4c:	ffffc097          	auipc	ra,0xffffc
    80005c50:	fa8080e7          	jalr	-88(ra) # 80001bf4 <myproc>
    80005c54:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005c56:	03853d03          	ld	s10,56(a0)
  sz = PGROUNDUP(sz);
    80005c5a:	6785                	lui	a5,0x1
    80005c5c:	17fd                	addi	a5,a5,-1
    80005c5e:	94be                	add	s1,s1,a5
    80005c60:	77fd                	lui	a5,0xfffff
    80005c62:	8fe5                	and	a5,a5,s1
    80005c64:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005c68:	6609                	lui	a2,0x2
    80005c6a:	963e                	add	a2,a2,a5
    80005c6c:	85be                	mv	a1,a5
    80005c6e:	855a                	mv	a0,s6
    80005c70:	ffffb097          	auipc	ra,0xffffb
    80005c74:	786080e7          	jalr	1926(ra) # 800013f6 <uvmalloc>
    80005c78:	8c2a                	mv	s8,a0
  ip = 0;
    80005c7a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005c7c:	16050a63          	beqz	a0,80005df0 <exec+0x30a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005c80:	75f9                	lui	a1,0xffffe
    80005c82:	95aa                	add	a1,a1,a0
    80005c84:	855a                	mv	a0,s6
    80005c86:	ffffc097          	auipc	ra,0xffffc
    80005c8a:	98e080e7          	jalr	-1650(ra) # 80001614 <uvmclear>
  stackbase = sp - PGSIZE;
    80005c8e:	7afd                	lui	s5,0xfffff
    80005c90:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005c92:	df043783          	ld	a5,-528(s0)
    80005c96:	6388                	ld	a0,0(a5)
    80005c98:	c925                	beqz	a0,80005d08 <exec+0x222>
    80005c9a:	e8840993          	addi	s3,s0,-376
    80005c9e:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005ca2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005ca4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005ca6:	ffffb097          	auipc	ra,0xffffb
    80005caa:	19c080e7          	jalr	412(ra) # 80000e42 <strlen>
    80005cae:	0015079b          	addiw	a5,a0,1
    80005cb2:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005cb6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005cba:	15596f63          	bltu	s2,s5,80005e18 <exec+0x332>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005cbe:	df043d83          	ld	s11,-528(s0)
    80005cc2:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005cc6:	8552                	mv	a0,s4
    80005cc8:	ffffb097          	auipc	ra,0xffffb
    80005ccc:	17a080e7          	jalr	378(ra) # 80000e42 <strlen>
    80005cd0:	0015069b          	addiw	a3,a0,1
    80005cd4:	8652                	mv	a2,s4
    80005cd6:	85ca                	mv	a1,s2
    80005cd8:	855a                	mv	a0,s6
    80005cda:	ffffc097          	auipc	ra,0xffffc
    80005cde:	96c080e7          	jalr	-1684(ra) # 80001646 <copyout>
    80005ce2:	12054f63          	bltz	a0,80005e20 <exec+0x33a>
    ustack[argc] = sp;
    80005ce6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005cea:	0485                	addi	s1,s1,1
    80005cec:	008d8793          	addi	a5,s11,8
    80005cf0:	def43823          	sd	a5,-528(s0)
    80005cf4:	008db503          	ld	a0,8(s11)
    80005cf8:	c911                	beqz	a0,80005d0c <exec+0x226>
    if(argc >= MAXARG)
    80005cfa:	09a1                	addi	s3,s3,8
    80005cfc:	fb9995e3          	bne	s3,s9,80005ca6 <exec+0x1c0>
  sz = sz1;
    80005d00:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d04:	4a81                	li	s5,0
    80005d06:	a0ed                	j	80005df0 <exec+0x30a>
  sp = sz;
    80005d08:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005d0a:	4481                	li	s1,0
  ustack[argc] = 0;
    80005d0c:	00349793          	slli	a5,s1,0x3
    80005d10:	f9040713          	addi	a4,s0,-112
    80005d14:	97ba                	add	a5,a5,a4
    80005d16:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffb9ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005d1a:	00148693          	addi	a3,s1,1
    80005d1e:	068e                	slli	a3,a3,0x3
    80005d20:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005d24:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005d28:	01597663          	bgeu	s2,s5,80005d34 <exec+0x24e>
  sz = sz1;
    80005d2c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d30:	4a81                	li	s5,0
    80005d32:	a87d                	j	80005df0 <exec+0x30a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005d34:	e8840613          	addi	a2,s0,-376
    80005d38:	85ca                	mv	a1,s2
    80005d3a:	855a                	mv	a0,s6
    80005d3c:	ffffc097          	auipc	ra,0xffffc
    80005d40:	90a080e7          	jalr	-1782(ra) # 80001646 <copyout>
    80005d44:	0e054263          	bltz	a0,80005e28 <exec+0x342>
    80005d48:	728b8793          	addi	a5,s7,1832 # 1728 <_entry-0x7fffe8d8>
    80005d4c:	6705                	lui	a4,0x1
    80005d4e:	82870713          	addi	a4,a4,-2008 # 828 <_entry-0x7ffff7d8>
    80005d52:	975e                	add	a4,a4,s7
    80005d54:	85ba                	mv	a1,a4
    if ((p->signal_handlers[i] != SIG_DFL) && (p->signal_handlers[i] != (void*) SIG_IGN))
    80005d56:	4605                	li	a2,1
    80005d58:	a029                	j	80005d62 <exec+0x27c>
  for (int i=0; i<NUM_OF_SIGNALS ; i++)
    80005d5a:	07a1                	addi	a5,a5,8
    80005d5c:	0711                	addi	a4,a4,4
    80005d5e:	00b78a63          	beq	a5,a1,80005d72 <exec+0x28c>
    if ((p->signal_handlers[i] != SIG_DFL) && (p->signal_handlers[i] != (void*) SIG_IGN))
    80005d62:	6394                	ld	a3,0(a5)
    80005d64:	fed67be3          	bgeu	a2,a3,80005d5a <exec+0x274>
      p->signal_handlers[i] = SIG_DFL;
    80005d68:	0007b023          	sd	zero,0(a5)
      p->signal_masks[i] = 0;
    80005d6c:	00072023          	sw	zero,0(a4)
    80005d70:	b7ed                	j	80005d5a <exec+0x274>
  p->init_thread->trapframe->a1 = sp;
    80005d72:	6785                	lui	a5,0x1
    80005d74:	97de                	add	a5,a5,s7
    80005d76:	8b87b783          	ld	a5,-1864(a5) # 8b8 <_entry-0x7ffff748>
    80005d7a:	67bc                	ld	a5,72(a5)
    80005d7c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005d80:	de843783          	ld	a5,-536(s0)
    80005d84:	0007c703          	lbu	a4,0(a5)
    80005d88:	cf11                	beqz	a4,80005da4 <exec+0x2be>
    80005d8a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005d8c:	02f00693          	li	a3,47
    80005d90:	a039                	j	80005d9e <exec+0x2b8>
      last = s+1;
    80005d92:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005d96:	0785                	addi	a5,a5,1
    80005d98:	fff7c703          	lbu	a4,-1(a5)
    80005d9c:	c701                	beqz	a4,80005da4 <exec+0x2be>
    if(*s == '/')
    80005d9e:	fed71ce3          	bne	a4,a3,80005d96 <exec+0x2b0>
    80005da2:	bfc5                	j	80005d92 <exec+0x2ac>
  safestrcpy(p->name, last, sizeof(p->name));
    80005da4:	4641                	li	a2,16
    80005da6:	de843583          	ld	a1,-536(s0)
    80005daa:	0d0b8513          	addi	a0,s7,208
    80005dae:	ffffb097          	auipc	ra,0xffffb
    80005db2:	062080e7          	jalr	98(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005db6:	040bb503          	ld	a0,64(s7)
  p->pagetable = pagetable;
    80005dba:	056bb023          	sd	s6,64(s7)
  p->sz = sz;
    80005dbe:	038bbc23          	sd	s8,56(s7)
  p->init_thread->trapframe->epc = elf.entry;  // initial program counter = main
    80005dc2:	6785                	lui	a5,0x1
    80005dc4:	9bbe                	add	s7,s7,a5
    80005dc6:	8b8bb783          	ld	a5,-1864(s7)
    80005dca:	67bc                	ld	a5,72(a5)
    80005dcc:	e6043703          	ld	a4,-416(s0)
    80005dd0:	ef98                	sd	a4,24(a5)
  p->init_thread->trapframe->sp = sp; // initial stack pointer
    80005dd2:	8b8bb783          	ld	a5,-1864(s7)
    80005dd6:	67bc                	ld	a5,72(a5)
    80005dd8:	0327b823          	sd	s2,48(a5) # 1030 <_entry-0x7fffefd0>
  proc_freepagetable(oldpagetable, oldsz);
    80005ddc:	85ea                	mv	a1,s10
    80005dde:	ffffc097          	auipc	ra,0xffffc
    80005de2:	f84080e7          	jalr	-124(ra) # 80001d62 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005de6:	0004851b          	sext.w	a0,s1
    80005dea:	bb61                	j	80005b82 <exec+0x9c>
    80005dec:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005df0:	df843583          	ld	a1,-520(s0)
    80005df4:	855a                	mv	a0,s6
    80005df6:	ffffc097          	auipc	ra,0xffffc
    80005dfa:	f6c080e7          	jalr	-148(ra) # 80001d62 <proc_freepagetable>
  if(ip){
    80005dfe:	d60a98e3          	bnez	s5,80005b6e <exec+0x88>
  return -1;
    80005e02:	557d                	li	a0,-1
    80005e04:	bbbd                	j	80005b82 <exec+0x9c>
    80005e06:	de943c23          	sd	s1,-520(s0)
    80005e0a:	b7dd                	j	80005df0 <exec+0x30a>
    80005e0c:	de943c23          	sd	s1,-520(s0)
    80005e10:	b7c5                	j	80005df0 <exec+0x30a>
    80005e12:	de943c23          	sd	s1,-520(s0)
    80005e16:	bfe9                	j	80005df0 <exec+0x30a>
  sz = sz1;
    80005e18:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005e1c:	4a81                	li	s5,0
    80005e1e:	bfc9                	j	80005df0 <exec+0x30a>
  sz = sz1;
    80005e20:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005e24:	4a81                	li	s5,0
    80005e26:	b7e9                	j	80005df0 <exec+0x30a>
  sz = sz1;
    80005e28:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005e2c:	4a81                	li	s5,0
    80005e2e:	b7c9                	j	80005df0 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005e30:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005e34:	e0843783          	ld	a5,-504(s0)
    80005e38:	0017869b          	addiw	a3,a5,1
    80005e3c:	e0d43423          	sd	a3,-504(s0)
    80005e40:	e0043783          	ld	a5,-512(s0)
    80005e44:	0387879b          	addiw	a5,a5,56
    80005e48:	e8045703          	lhu	a4,-384(s0)
    80005e4c:	dee6d7e3          	bge	a3,a4,80005c3a <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005e50:	2781                	sext.w	a5,a5
    80005e52:	e0f43023          	sd	a5,-512(s0)
    80005e56:	03800713          	li	a4,56
    80005e5a:	86be                	mv	a3,a5
    80005e5c:	e1040613          	addi	a2,s0,-496
    80005e60:	4581                	li	a1,0
    80005e62:	8556                	mv	a0,s5
    80005e64:	fffff097          	auipc	ra,0xfffff
    80005e68:	a44080e7          	jalr	-1468(ra) # 800048a8 <readi>
    80005e6c:	03800793          	li	a5,56
    80005e70:	f6f51ee3          	bne	a0,a5,80005dec <exec+0x306>
    if(ph.type != ELF_PROG_LOAD)
    80005e74:	e1042783          	lw	a5,-496(s0)
    80005e78:	4705                	li	a4,1
    80005e7a:	fae79de3          	bne	a5,a4,80005e34 <exec+0x34e>
    if(ph.memsz < ph.filesz)
    80005e7e:	e3843603          	ld	a2,-456(s0)
    80005e82:	e3043783          	ld	a5,-464(s0)
    80005e86:	f8f660e3          	bltu	a2,a5,80005e06 <exec+0x320>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005e8a:	e2043783          	ld	a5,-480(s0)
    80005e8e:	963e                	add	a2,a2,a5
    80005e90:	f6f66ee3          	bltu	a2,a5,80005e0c <exec+0x326>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005e94:	85a6                	mv	a1,s1
    80005e96:	855a                	mv	a0,s6
    80005e98:	ffffb097          	auipc	ra,0xffffb
    80005e9c:	55e080e7          	jalr	1374(ra) # 800013f6 <uvmalloc>
    80005ea0:	dea43c23          	sd	a0,-520(s0)
    80005ea4:	d53d                	beqz	a0,80005e12 <exec+0x32c>
    if(ph.vaddr % PGSIZE != 0)
    80005ea6:	e2043c03          	ld	s8,-480(s0)
    80005eaa:	de043783          	ld	a5,-544(s0)
    80005eae:	00fc77b3          	and	a5,s8,a5
    80005eb2:	ff9d                	bnez	a5,80005df0 <exec+0x30a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005eb4:	e1842c83          	lw	s9,-488(s0)
    80005eb8:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005ebc:	f60b8ae3          	beqz	s7,80005e30 <exec+0x34a>
    80005ec0:	89de                	mv	s3,s7
    80005ec2:	4481                	li	s1,0
    80005ec4:	bb91                	j	80005c18 <exec+0x132>

0000000080005ec6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005ec6:	7179                	addi	sp,sp,-48
    80005ec8:	f406                	sd	ra,40(sp)
    80005eca:	f022                	sd	s0,32(sp)
    80005ecc:	ec26                	sd	s1,24(sp)
    80005ece:	e84a                	sd	s2,16(sp)
    80005ed0:	1800                	addi	s0,sp,48
    80005ed2:	892e                	mv	s2,a1
    80005ed4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005ed6:	fdc40593          	addi	a1,s0,-36
    80005eda:	ffffe097          	auipc	ra,0xffffe
    80005ede:	85e080e7          	jalr	-1954(ra) # 80003738 <argint>
    80005ee2:	04054063          	bltz	a0,80005f22 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005ee6:	fdc42703          	lw	a4,-36(s0)
    80005eea:	47bd                	li	a5,15
    80005eec:	02e7ed63          	bltu	a5,a4,80005f26 <argfd+0x60>
    80005ef0:	ffffc097          	auipc	ra,0xffffc
    80005ef4:	d04080e7          	jalr	-764(ra) # 80001bf4 <myproc>
    80005ef8:	fdc42703          	lw	a4,-36(s0)
    80005efc:	00870793          	addi	a5,a4,8
    80005f00:	078e                	slli	a5,a5,0x3
    80005f02:	953e                	add	a0,a0,a5
    80005f04:	651c                	ld	a5,8(a0)
    80005f06:	c395                	beqz	a5,80005f2a <argfd+0x64>
    return -1;
  if(pfd)
    80005f08:	00090463          	beqz	s2,80005f10 <argfd+0x4a>
    *pfd = fd;
    80005f0c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005f10:	4501                	li	a0,0
  if(pf)
    80005f12:	c091                	beqz	s1,80005f16 <argfd+0x50>
    *pf = f;
    80005f14:	e09c                	sd	a5,0(s1)
}
    80005f16:	70a2                	ld	ra,40(sp)
    80005f18:	7402                	ld	s0,32(sp)
    80005f1a:	64e2                	ld	s1,24(sp)
    80005f1c:	6942                	ld	s2,16(sp)
    80005f1e:	6145                	addi	sp,sp,48
    80005f20:	8082                	ret
    return -1;
    80005f22:	557d                	li	a0,-1
    80005f24:	bfcd                	j	80005f16 <argfd+0x50>
    return -1;
    80005f26:	557d                	li	a0,-1
    80005f28:	b7fd                	j	80005f16 <argfd+0x50>
    80005f2a:	557d                	li	a0,-1
    80005f2c:	b7ed                	j	80005f16 <argfd+0x50>

0000000080005f2e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005f2e:	1101                	addi	sp,sp,-32
    80005f30:	ec06                	sd	ra,24(sp)
    80005f32:	e822                	sd	s0,16(sp)
    80005f34:	e426                	sd	s1,8(sp)
    80005f36:	1000                	addi	s0,sp,32
    80005f38:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005f3a:	ffffc097          	auipc	ra,0xffffc
    80005f3e:	cba080e7          	jalr	-838(ra) # 80001bf4 <myproc>
    80005f42:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005f44:	04850793          	addi	a5,a0,72
    80005f48:	4501                	li	a0,0
    80005f4a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005f4c:	6398                	ld	a4,0(a5)
    80005f4e:	cb19                	beqz	a4,80005f64 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005f50:	2505                	addiw	a0,a0,1
    80005f52:	07a1                	addi	a5,a5,8
    80005f54:	fed51ce3          	bne	a0,a3,80005f4c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005f58:	557d                	li	a0,-1
}
    80005f5a:	60e2                	ld	ra,24(sp)
    80005f5c:	6442                	ld	s0,16(sp)
    80005f5e:	64a2                	ld	s1,8(sp)
    80005f60:	6105                	addi	sp,sp,32
    80005f62:	8082                	ret
      p->ofile[fd] = f;
    80005f64:	00850793          	addi	a5,a0,8
    80005f68:	078e                	slli	a5,a5,0x3
    80005f6a:	963e                	add	a2,a2,a5
    80005f6c:	e604                	sd	s1,8(a2)
      return fd;
    80005f6e:	b7f5                	j	80005f5a <fdalloc+0x2c>

0000000080005f70 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005f70:	715d                	addi	sp,sp,-80
    80005f72:	e486                	sd	ra,72(sp)
    80005f74:	e0a2                	sd	s0,64(sp)
    80005f76:	fc26                	sd	s1,56(sp)
    80005f78:	f84a                	sd	s2,48(sp)
    80005f7a:	f44e                	sd	s3,40(sp)
    80005f7c:	f052                	sd	s4,32(sp)
    80005f7e:	ec56                	sd	s5,24(sp)
    80005f80:	0880                	addi	s0,sp,80
    80005f82:	89ae                	mv	s3,a1
    80005f84:	8ab2                	mv	s5,a2
    80005f86:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005f88:	fb040593          	addi	a1,s0,-80
    80005f8c:	fffff097          	auipc	ra,0xfffff
    80005f90:	e3a080e7          	jalr	-454(ra) # 80004dc6 <nameiparent>
    80005f94:	892a                	mv	s2,a0
    80005f96:	12050e63          	beqz	a0,800060d2 <create+0x162>
    return 0;

  ilock(dp);
    80005f9a:	ffffe097          	auipc	ra,0xffffe
    80005f9e:	65a080e7          	jalr	1626(ra) # 800045f4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005fa2:	4601                	li	a2,0
    80005fa4:	fb040593          	addi	a1,s0,-80
    80005fa8:	854a                	mv	a0,s2
    80005faa:	fffff097          	auipc	ra,0xfffff
    80005fae:	b2e080e7          	jalr	-1234(ra) # 80004ad8 <dirlookup>
    80005fb2:	84aa                	mv	s1,a0
    80005fb4:	c921                	beqz	a0,80006004 <create+0x94>
    iunlockput(dp);
    80005fb6:	854a                	mv	a0,s2
    80005fb8:	fffff097          	auipc	ra,0xfffff
    80005fbc:	89e080e7          	jalr	-1890(ra) # 80004856 <iunlockput>
    ilock(ip);
    80005fc0:	8526                	mv	a0,s1
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	632080e7          	jalr	1586(ra) # 800045f4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005fca:	2981                	sext.w	s3,s3
    80005fcc:	4789                	li	a5,2
    80005fce:	02f99463          	bne	s3,a5,80005ff6 <create+0x86>
    80005fd2:	0444d783          	lhu	a5,68(s1)
    80005fd6:	37f9                	addiw	a5,a5,-2
    80005fd8:	17c2                	slli	a5,a5,0x30
    80005fda:	93c1                	srli	a5,a5,0x30
    80005fdc:	4705                	li	a4,1
    80005fde:	00f76c63          	bltu	a4,a5,80005ff6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005fe2:	8526                	mv	a0,s1
    80005fe4:	60a6                	ld	ra,72(sp)
    80005fe6:	6406                	ld	s0,64(sp)
    80005fe8:	74e2                	ld	s1,56(sp)
    80005fea:	7942                	ld	s2,48(sp)
    80005fec:	79a2                	ld	s3,40(sp)
    80005fee:	7a02                	ld	s4,32(sp)
    80005ff0:	6ae2                	ld	s5,24(sp)
    80005ff2:	6161                	addi	sp,sp,80
    80005ff4:	8082                	ret
    iunlockput(ip);
    80005ff6:	8526                	mv	a0,s1
    80005ff8:	fffff097          	auipc	ra,0xfffff
    80005ffc:	85e080e7          	jalr	-1954(ra) # 80004856 <iunlockput>
    return 0;
    80006000:	4481                	li	s1,0
    80006002:	b7c5                	j	80005fe2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006004:	85ce                	mv	a1,s3
    80006006:	00092503          	lw	a0,0(s2)
    8000600a:	ffffe097          	auipc	ra,0xffffe
    8000600e:	452080e7          	jalr	1106(ra) # 8000445c <ialloc>
    80006012:	84aa                	mv	s1,a0
    80006014:	c521                	beqz	a0,8000605c <create+0xec>
  ilock(ip);
    80006016:	ffffe097          	auipc	ra,0xffffe
    8000601a:	5de080e7          	jalr	1502(ra) # 800045f4 <ilock>
  ip->major = major;
    8000601e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006022:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006026:	4a05                	li	s4,1
    80006028:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000602c:	8526                	mv	a0,s1
    8000602e:	ffffe097          	auipc	ra,0xffffe
    80006032:	4fc080e7          	jalr	1276(ra) # 8000452a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006036:	2981                	sext.w	s3,s3
    80006038:	03498a63          	beq	s3,s4,8000606c <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000603c:	40d0                	lw	a2,4(s1)
    8000603e:	fb040593          	addi	a1,s0,-80
    80006042:	854a                	mv	a0,s2
    80006044:	fffff097          	auipc	ra,0xfffff
    80006048:	ca2080e7          	jalr	-862(ra) # 80004ce6 <dirlink>
    8000604c:	06054b63          	bltz	a0,800060c2 <create+0x152>
  iunlockput(dp);
    80006050:	854a                	mv	a0,s2
    80006052:	fffff097          	auipc	ra,0xfffff
    80006056:	804080e7          	jalr	-2044(ra) # 80004856 <iunlockput>
  return ip;
    8000605a:	b761                	j	80005fe2 <create+0x72>
    panic("create: ialloc");
    8000605c:	00004517          	auipc	a0,0x4
    80006060:	88c50513          	addi	a0,a0,-1908 # 800098e8 <syscalls+0x320>
    80006064:	ffffa097          	auipc	ra,0xffffa
    80006068:	4c6080e7          	jalr	1222(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    8000606c:	04a95783          	lhu	a5,74(s2)
    80006070:	2785                	addiw	a5,a5,1
    80006072:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006076:	854a                	mv	a0,s2
    80006078:	ffffe097          	auipc	ra,0xffffe
    8000607c:	4b2080e7          	jalr	1202(ra) # 8000452a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006080:	40d0                	lw	a2,4(s1)
    80006082:	00004597          	auipc	a1,0x4
    80006086:	87658593          	addi	a1,a1,-1930 # 800098f8 <syscalls+0x330>
    8000608a:	8526                	mv	a0,s1
    8000608c:	fffff097          	auipc	ra,0xfffff
    80006090:	c5a080e7          	jalr	-934(ra) # 80004ce6 <dirlink>
    80006094:	00054f63          	bltz	a0,800060b2 <create+0x142>
    80006098:	00492603          	lw	a2,4(s2)
    8000609c:	00004597          	auipc	a1,0x4
    800060a0:	86458593          	addi	a1,a1,-1948 # 80009900 <syscalls+0x338>
    800060a4:	8526                	mv	a0,s1
    800060a6:	fffff097          	auipc	ra,0xfffff
    800060aa:	c40080e7          	jalr	-960(ra) # 80004ce6 <dirlink>
    800060ae:	f80557e3          	bgez	a0,8000603c <create+0xcc>
      panic("create dots");
    800060b2:	00004517          	auipc	a0,0x4
    800060b6:	85650513          	addi	a0,a0,-1962 # 80009908 <syscalls+0x340>
    800060ba:	ffffa097          	auipc	ra,0xffffa
    800060be:	470080e7          	jalr	1136(ra) # 8000052a <panic>
    panic("create: dirlink");
    800060c2:	00004517          	auipc	a0,0x4
    800060c6:	85650513          	addi	a0,a0,-1962 # 80009918 <syscalls+0x350>
    800060ca:	ffffa097          	auipc	ra,0xffffa
    800060ce:	460080e7          	jalr	1120(ra) # 8000052a <panic>
    return 0;
    800060d2:	84aa                	mv	s1,a0
    800060d4:	b739                	j	80005fe2 <create+0x72>

00000000800060d6 <sys_dup>:
{
    800060d6:	7179                	addi	sp,sp,-48
    800060d8:	f406                	sd	ra,40(sp)
    800060da:	f022                	sd	s0,32(sp)
    800060dc:	ec26                	sd	s1,24(sp)
    800060de:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800060e0:	fd840613          	addi	a2,s0,-40
    800060e4:	4581                	li	a1,0
    800060e6:	4501                	li	a0,0
    800060e8:	00000097          	auipc	ra,0x0
    800060ec:	dde080e7          	jalr	-546(ra) # 80005ec6 <argfd>
    return -1;
    800060f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800060f2:	02054363          	bltz	a0,80006118 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800060f6:	fd843503          	ld	a0,-40(s0)
    800060fa:	00000097          	auipc	ra,0x0
    800060fe:	e34080e7          	jalr	-460(ra) # 80005f2e <fdalloc>
    80006102:	84aa                	mv	s1,a0
    return -1;
    80006104:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006106:	00054963          	bltz	a0,80006118 <sys_dup+0x42>
  filedup(f);
    8000610a:	fd843503          	ld	a0,-40(s0)
    8000610e:	fffff097          	auipc	ra,0xfffff
    80006112:	334080e7          	jalr	820(ra) # 80005442 <filedup>
  return fd;
    80006116:	87a6                	mv	a5,s1
}
    80006118:	853e                	mv	a0,a5
    8000611a:	70a2                	ld	ra,40(sp)
    8000611c:	7402                	ld	s0,32(sp)
    8000611e:	64e2                	ld	s1,24(sp)
    80006120:	6145                	addi	sp,sp,48
    80006122:	8082                	ret

0000000080006124 <sys_read>:
{
    80006124:	7179                	addi	sp,sp,-48
    80006126:	f406                	sd	ra,40(sp)
    80006128:	f022                	sd	s0,32(sp)
    8000612a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000612c:	fe840613          	addi	a2,s0,-24
    80006130:	4581                	li	a1,0
    80006132:	4501                	li	a0,0
    80006134:	00000097          	auipc	ra,0x0
    80006138:	d92080e7          	jalr	-622(ra) # 80005ec6 <argfd>
    return -1;
    8000613c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000613e:	04054163          	bltz	a0,80006180 <sys_read+0x5c>
    80006142:	fe440593          	addi	a1,s0,-28
    80006146:	4509                	li	a0,2
    80006148:	ffffd097          	auipc	ra,0xffffd
    8000614c:	5f0080e7          	jalr	1520(ra) # 80003738 <argint>
    return -1;
    80006150:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006152:	02054763          	bltz	a0,80006180 <sys_read+0x5c>
    80006156:	fd840593          	addi	a1,s0,-40
    8000615a:	4505                	li	a0,1
    8000615c:	ffffd097          	auipc	ra,0xffffd
    80006160:	5fe080e7          	jalr	1534(ra) # 8000375a <argaddr>
    return -1;
    80006164:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006166:	00054d63          	bltz	a0,80006180 <sys_read+0x5c>
  return fileread(f, p, n);
    8000616a:	fe442603          	lw	a2,-28(s0)
    8000616e:	fd843583          	ld	a1,-40(s0)
    80006172:	fe843503          	ld	a0,-24(s0)
    80006176:	fffff097          	auipc	ra,0xfffff
    8000617a:	458080e7          	jalr	1112(ra) # 800055ce <fileread>
    8000617e:	87aa                	mv	a5,a0
}
    80006180:	853e                	mv	a0,a5
    80006182:	70a2                	ld	ra,40(sp)
    80006184:	7402                	ld	s0,32(sp)
    80006186:	6145                	addi	sp,sp,48
    80006188:	8082                	ret

000000008000618a <sys_write>:
{
    8000618a:	7179                	addi	sp,sp,-48
    8000618c:	f406                	sd	ra,40(sp)
    8000618e:	f022                	sd	s0,32(sp)
    80006190:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006192:	fe840613          	addi	a2,s0,-24
    80006196:	4581                	li	a1,0
    80006198:	4501                	li	a0,0
    8000619a:	00000097          	auipc	ra,0x0
    8000619e:	d2c080e7          	jalr	-724(ra) # 80005ec6 <argfd>
    return -1;
    800061a2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800061a4:	04054163          	bltz	a0,800061e6 <sys_write+0x5c>
    800061a8:	fe440593          	addi	a1,s0,-28
    800061ac:	4509                	li	a0,2
    800061ae:	ffffd097          	auipc	ra,0xffffd
    800061b2:	58a080e7          	jalr	1418(ra) # 80003738 <argint>
    return -1;
    800061b6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800061b8:	02054763          	bltz	a0,800061e6 <sys_write+0x5c>
    800061bc:	fd840593          	addi	a1,s0,-40
    800061c0:	4505                	li	a0,1
    800061c2:	ffffd097          	auipc	ra,0xffffd
    800061c6:	598080e7          	jalr	1432(ra) # 8000375a <argaddr>
    return -1;
    800061ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800061cc:	00054d63          	bltz	a0,800061e6 <sys_write+0x5c>
  return filewrite(f, p, n);
    800061d0:	fe442603          	lw	a2,-28(s0)
    800061d4:	fd843583          	ld	a1,-40(s0)
    800061d8:	fe843503          	ld	a0,-24(s0)
    800061dc:	fffff097          	auipc	ra,0xfffff
    800061e0:	4b4080e7          	jalr	1204(ra) # 80005690 <filewrite>
    800061e4:	87aa                	mv	a5,a0
}
    800061e6:	853e                	mv	a0,a5
    800061e8:	70a2                	ld	ra,40(sp)
    800061ea:	7402                	ld	s0,32(sp)
    800061ec:	6145                	addi	sp,sp,48
    800061ee:	8082                	ret

00000000800061f0 <sys_close>:
{
    800061f0:	1101                	addi	sp,sp,-32
    800061f2:	ec06                	sd	ra,24(sp)
    800061f4:	e822                	sd	s0,16(sp)
    800061f6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800061f8:	fe040613          	addi	a2,s0,-32
    800061fc:	fec40593          	addi	a1,s0,-20
    80006200:	4501                	li	a0,0
    80006202:	00000097          	auipc	ra,0x0
    80006206:	cc4080e7          	jalr	-828(ra) # 80005ec6 <argfd>
    return -1;
    8000620a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000620c:	02054463          	bltz	a0,80006234 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006210:	ffffc097          	auipc	ra,0xffffc
    80006214:	9e4080e7          	jalr	-1564(ra) # 80001bf4 <myproc>
    80006218:	fec42783          	lw	a5,-20(s0)
    8000621c:	07a1                	addi	a5,a5,8
    8000621e:	078e                	slli	a5,a5,0x3
    80006220:	97aa                	add	a5,a5,a0
    80006222:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80006226:	fe043503          	ld	a0,-32(s0)
    8000622a:	fffff097          	auipc	ra,0xfffff
    8000622e:	26a080e7          	jalr	618(ra) # 80005494 <fileclose>
  return 0;
    80006232:	4781                	li	a5,0
}
    80006234:	853e                	mv	a0,a5
    80006236:	60e2                	ld	ra,24(sp)
    80006238:	6442                	ld	s0,16(sp)
    8000623a:	6105                	addi	sp,sp,32
    8000623c:	8082                	ret

000000008000623e <sys_fstat>:
{
    8000623e:	1101                	addi	sp,sp,-32
    80006240:	ec06                	sd	ra,24(sp)
    80006242:	e822                	sd	s0,16(sp)
    80006244:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006246:	fe840613          	addi	a2,s0,-24
    8000624a:	4581                	li	a1,0
    8000624c:	4501                	li	a0,0
    8000624e:	00000097          	auipc	ra,0x0
    80006252:	c78080e7          	jalr	-904(ra) # 80005ec6 <argfd>
    return -1;
    80006256:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006258:	02054563          	bltz	a0,80006282 <sys_fstat+0x44>
    8000625c:	fe040593          	addi	a1,s0,-32
    80006260:	4505                	li	a0,1
    80006262:	ffffd097          	auipc	ra,0xffffd
    80006266:	4f8080e7          	jalr	1272(ra) # 8000375a <argaddr>
    return -1;
    8000626a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000626c:	00054b63          	bltz	a0,80006282 <sys_fstat+0x44>
  return filestat(f, st);
    80006270:	fe043583          	ld	a1,-32(s0)
    80006274:	fe843503          	ld	a0,-24(s0)
    80006278:	fffff097          	auipc	ra,0xfffff
    8000627c:	2e4080e7          	jalr	740(ra) # 8000555c <filestat>
    80006280:	87aa                	mv	a5,a0
}
    80006282:	853e                	mv	a0,a5
    80006284:	60e2                	ld	ra,24(sp)
    80006286:	6442                	ld	s0,16(sp)
    80006288:	6105                	addi	sp,sp,32
    8000628a:	8082                	ret

000000008000628c <sys_link>:
{
    8000628c:	7169                	addi	sp,sp,-304
    8000628e:	f606                	sd	ra,296(sp)
    80006290:	f222                	sd	s0,288(sp)
    80006292:	ee26                	sd	s1,280(sp)
    80006294:	ea4a                	sd	s2,272(sp)
    80006296:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006298:	08000613          	li	a2,128
    8000629c:	ed040593          	addi	a1,s0,-304
    800062a0:	4501                	li	a0,0
    800062a2:	ffffd097          	auipc	ra,0xffffd
    800062a6:	4da080e7          	jalr	1242(ra) # 8000377c <argstr>
    return -1;
    800062aa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800062ac:	10054e63          	bltz	a0,800063c8 <sys_link+0x13c>
    800062b0:	08000613          	li	a2,128
    800062b4:	f5040593          	addi	a1,s0,-176
    800062b8:	4505                	li	a0,1
    800062ba:	ffffd097          	auipc	ra,0xffffd
    800062be:	4c2080e7          	jalr	1218(ra) # 8000377c <argstr>
    return -1;
    800062c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800062c4:	10054263          	bltz	a0,800063c8 <sys_link+0x13c>
  begin_op();
    800062c8:	fffff097          	auipc	ra,0xfffff
    800062cc:	d00080e7          	jalr	-768(ra) # 80004fc8 <begin_op>
  if((ip = namei(old)) == 0){
    800062d0:	ed040513          	addi	a0,s0,-304
    800062d4:	fffff097          	auipc	ra,0xfffff
    800062d8:	ad4080e7          	jalr	-1324(ra) # 80004da8 <namei>
    800062dc:	84aa                	mv	s1,a0
    800062de:	c551                	beqz	a0,8000636a <sys_link+0xde>
  ilock(ip);
    800062e0:	ffffe097          	auipc	ra,0xffffe
    800062e4:	314080e7          	jalr	788(ra) # 800045f4 <ilock>
  if(ip->type == T_DIR){
    800062e8:	04449703          	lh	a4,68(s1)
    800062ec:	4785                	li	a5,1
    800062ee:	08f70463          	beq	a4,a5,80006376 <sys_link+0xea>
  ip->nlink++;
    800062f2:	04a4d783          	lhu	a5,74(s1)
    800062f6:	2785                	addiw	a5,a5,1
    800062f8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800062fc:	8526                	mv	a0,s1
    800062fe:	ffffe097          	auipc	ra,0xffffe
    80006302:	22c080e7          	jalr	556(ra) # 8000452a <iupdate>
  iunlock(ip);
    80006306:	8526                	mv	a0,s1
    80006308:	ffffe097          	auipc	ra,0xffffe
    8000630c:	3ae080e7          	jalr	942(ra) # 800046b6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006310:	fd040593          	addi	a1,s0,-48
    80006314:	f5040513          	addi	a0,s0,-176
    80006318:	fffff097          	auipc	ra,0xfffff
    8000631c:	aae080e7          	jalr	-1362(ra) # 80004dc6 <nameiparent>
    80006320:	892a                	mv	s2,a0
    80006322:	c935                	beqz	a0,80006396 <sys_link+0x10a>
  ilock(dp);
    80006324:	ffffe097          	auipc	ra,0xffffe
    80006328:	2d0080e7          	jalr	720(ra) # 800045f4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000632c:	00092703          	lw	a4,0(s2)
    80006330:	409c                	lw	a5,0(s1)
    80006332:	04f71d63          	bne	a4,a5,8000638c <sys_link+0x100>
    80006336:	40d0                	lw	a2,4(s1)
    80006338:	fd040593          	addi	a1,s0,-48
    8000633c:	854a                	mv	a0,s2
    8000633e:	fffff097          	auipc	ra,0xfffff
    80006342:	9a8080e7          	jalr	-1624(ra) # 80004ce6 <dirlink>
    80006346:	04054363          	bltz	a0,8000638c <sys_link+0x100>
  iunlockput(dp);
    8000634a:	854a                	mv	a0,s2
    8000634c:	ffffe097          	auipc	ra,0xffffe
    80006350:	50a080e7          	jalr	1290(ra) # 80004856 <iunlockput>
  iput(ip);
    80006354:	8526                	mv	a0,s1
    80006356:	ffffe097          	auipc	ra,0xffffe
    8000635a:	458080e7          	jalr	1112(ra) # 800047ae <iput>
  end_op();
    8000635e:	fffff097          	auipc	ra,0xfffff
    80006362:	cea080e7          	jalr	-790(ra) # 80005048 <end_op>
  return 0;
    80006366:	4781                	li	a5,0
    80006368:	a085                	j	800063c8 <sys_link+0x13c>
    end_op();
    8000636a:	fffff097          	auipc	ra,0xfffff
    8000636e:	cde080e7          	jalr	-802(ra) # 80005048 <end_op>
    return -1;
    80006372:	57fd                	li	a5,-1
    80006374:	a891                	j	800063c8 <sys_link+0x13c>
    iunlockput(ip);
    80006376:	8526                	mv	a0,s1
    80006378:	ffffe097          	auipc	ra,0xffffe
    8000637c:	4de080e7          	jalr	1246(ra) # 80004856 <iunlockput>
    end_op();
    80006380:	fffff097          	auipc	ra,0xfffff
    80006384:	cc8080e7          	jalr	-824(ra) # 80005048 <end_op>
    return -1;
    80006388:	57fd                	li	a5,-1
    8000638a:	a83d                	j	800063c8 <sys_link+0x13c>
    iunlockput(dp);
    8000638c:	854a                	mv	a0,s2
    8000638e:	ffffe097          	auipc	ra,0xffffe
    80006392:	4c8080e7          	jalr	1224(ra) # 80004856 <iunlockput>
  ilock(ip);
    80006396:	8526                	mv	a0,s1
    80006398:	ffffe097          	auipc	ra,0xffffe
    8000639c:	25c080e7          	jalr	604(ra) # 800045f4 <ilock>
  ip->nlink--;
    800063a0:	04a4d783          	lhu	a5,74(s1)
    800063a4:	37fd                	addiw	a5,a5,-1
    800063a6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800063aa:	8526                	mv	a0,s1
    800063ac:	ffffe097          	auipc	ra,0xffffe
    800063b0:	17e080e7          	jalr	382(ra) # 8000452a <iupdate>
  iunlockput(ip);
    800063b4:	8526                	mv	a0,s1
    800063b6:	ffffe097          	auipc	ra,0xffffe
    800063ba:	4a0080e7          	jalr	1184(ra) # 80004856 <iunlockput>
  end_op();
    800063be:	fffff097          	auipc	ra,0xfffff
    800063c2:	c8a080e7          	jalr	-886(ra) # 80005048 <end_op>
  return -1;
    800063c6:	57fd                	li	a5,-1
}
    800063c8:	853e                	mv	a0,a5
    800063ca:	70b2                	ld	ra,296(sp)
    800063cc:	7412                	ld	s0,288(sp)
    800063ce:	64f2                	ld	s1,280(sp)
    800063d0:	6952                	ld	s2,272(sp)
    800063d2:	6155                	addi	sp,sp,304
    800063d4:	8082                	ret

00000000800063d6 <sys_unlink>:
{
    800063d6:	7151                	addi	sp,sp,-240
    800063d8:	f586                	sd	ra,232(sp)
    800063da:	f1a2                	sd	s0,224(sp)
    800063dc:	eda6                	sd	s1,216(sp)
    800063de:	e9ca                	sd	s2,208(sp)
    800063e0:	e5ce                	sd	s3,200(sp)
    800063e2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800063e4:	08000613          	li	a2,128
    800063e8:	f3040593          	addi	a1,s0,-208
    800063ec:	4501                	li	a0,0
    800063ee:	ffffd097          	auipc	ra,0xffffd
    800063f2:	38e080e7          	jalr	910(ra) # 8000377c <argstr>
    800063f6:	18054163          	bltz	a0,80006578 <sys_unlink+0x1a2>
  begin_op();
    800063fa:	fffff097          	auipc	ra,0xfffff
    800063fe:	bce080e7          	jalr	-1074(ra) # 80004fc8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006402:	fb040593          	addi	a1,s0,-80
    80006406:	f3040513          	addi	a0,s0,-208
    8000640a:	fffff097          	auipc	ra,0xfffff
    8000640e:	9bc080e7          	jalr	-1604(ra) # 80004dc6 <nameiparent>
    80006412:	84aa                	mv	s1,a0
    80006414:	c979                	beqz	a0,800064ea <sys_unlink+0x114>
  ilock(dp);
    80006416:	ffffe097          	auipc	ra,0xffffe
    8000641a:	1de080e7          	jalr	478(ra) # 800045f4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000641e:	00003597          	auipc	a1,0x3
    80006422:	4da58593          	addi	a1,a1,1242 # 800098f8 <syscalls+0x330>
    80006426:	fb040513          	addi	a0,s0,-80
    8000642a:	ffffe097          	auipc	ra,0xffffe
    8000642e:	694080e7          	jalr	1684(ra) # 80004abe <namecmp>
    80006432:	14050a63          	beqz	a0,80006586 <sys_unlink+0x1b0>
    80006436:	00003597          	auipc	a1,0x3
    8000643a:	4ca58593          	addi	a1,a1,1226 # 80009900 <syscalls+0x338>
    8000643e:	fb040513          	addi	a0,s0,-80
    80006442:	ffffe097          	auipc	ra,0xffffe
    80006446:	67c080e7          	jalr	1660(ra) # 80004abe <namecmp>
    8000644a:	12050e63          	beqz	a0,80006586 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000644e:	f2c40613          	addi	a2,s0,-212
    80006452:	fb040593          	addi	a1,s0,-80
    80006456:	8526                	mv	a0,s1
    80006458:	ffffe097          	auipc	ra,0xffffe
    8000645c:	680080e7          	jalr	1664(ra) # 80004ad8 <dirlookup>
    80006460:	892a                	mv	s2,a0
    80006462:	12050263          	beqz	a0,80006586 <sys_unlink+0x1b0>
  ilock(ip);
    80006466:	ffffe097          	auipc	ra,0xffffe
    8000646a:	18e080e7          	jalr	398(ra) # 800045f4 <ilock>
  if(ip->nlink < 1)
    8000646e:	04a91783          	lh	a5,74(s2)
    80006472:	08f05263          	blez	a5,800064f6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006476:	04491703          	lh	a4,68(s2)
    8000647a:	4785                	li	a5,1
    8000647c:	08f70563          	beq	a4,a5,80006506 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006480:	4641                	li	a2,16
    80006482:	4581                	li	a1,0
    80006484:	fc040513          	addi	a0,s0,-64
    80006488:	ffffb097          	auipc	ra,0xffffb
    8000648c:	836080e7          	jalr	-1994(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006490:	4741                	li	a4,16
    80006492:	f2c42683          	lw	a3,-212(s0)
    80006496:	fc040613          	addi	a2,s0,-64
    8000649a:	4581                	li	a1,0
    8000649c:	8526                	mv	a0,s1
    8000649e:	ffffe097          	auipc	ra,0xffffe
    800064a2:	502080e7          	jalr	1282(ra) # 800049a0 <writei>
    800064a6:	47c1                	li	a5,16
    800064a8:	0af51563          	bne	a0,a5,80006552 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800064ac:	04491703          	lh	a4,68(s2)
    800064b0:	4785                	li	a5,1
    800064b2:	0af70863          	beq	a4,a5,80006562 <sys_unlink+0x18c>
  iunlockput(dp);
    800064b6:	8526                	mv	a0,s1
    800064b8:	ffffe097          	auipc	ra,0xffffe
    800064bc:	39e080e7          	jalr	926(ra) # 80004856 <iunlockput>
  ip->nlink--;
    800064c0:	04a95783          	lhu	a5,74(s2)
    800064c4:	37fd                	addiw	a5,a5,-1
    800064c6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800064ca:	854a                	mv	a0,s2
    800064cc:	ffffe097          	auipc	ra,0xffffe
    800064d0:	05e080e7          	jalr	94(ra) # 8000452a <iupdate>
  iunlockput(ip);
    800064d4:	854a                	mv	a0,s2
    800064d6:	ffffe097          	auipc	ra,0xffffe
    800064da:	380080e7          	jalr	896(ra) # 80004856 <iunlockput>
  end_op();
    800064de:	fffff097          	auipc	ra,0xfffff
    800064e2:	b6a080e7          	jalr	-1174(ra) # 80005048 <end_op>
  return 0;
    800064e6:	4501                	li	a0,0
    800064e8:	a84d                	j	8000659a <sys_unlink+0x1c4>
    end_op();
    800064ea:	fffff097          	auipc	ra,0xfffff
    800064ee:	b5e080e7          	jalr	-1186(ra) # 80005048 <end_op>
    return -1;
    800064f2:	557d                	li	a0,-1
    800064f4:	a05d                	j	8000659a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800064f6:	00003517          	auipc	a0,0x3
    800064fa:	43250513          	addi	a0,a0,1074 # 80009928 <syscalls+0x360>
    800064fe:	ffffa097          	auipc	ra,0xffffa
    80006502:	02c080e7          	jalr	44(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006506:	04c92703          	lw	a4,76(s2)
    8000650a:	02000793          	li	a5,32
    8000650e:	f6e7f9e3          	bgeu	a5,a4,80006480 <sys_unlink+0xaa>
    80006512:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006516:	4741                	li	a4,16
    80006518:	86ce                	mv	a3,s3
    8000651a:	f1840613          	addi	a2,s0,-232
    8000651e:	4581                	li	a1,0
    80006520:	854a                	mv	a0,s2
    80006522:	ffffe097          	auipc	ra,0xffffe
    80006526:	386080e7          	jalr	902(ra) # 800048a8 <readi>
    8000652a:	47c1                	li	a5,16
    8000652c:	00f51b63          	bne	a0,a5,80006542 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006530:	f1845783          	lhu	a5,-232(s0)
    80006534:	e7a1                	bnez	a5,8000657c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006536:	29c1                	addiw	s3,s3,16
    80006538:	04c92783          	lw	a5,76(s2)
    8000653c:	fcf9ede3          	bltu	s3,a5,80006516 <sys_unlink+0x140>
    80006540:	b781                	j	80006480 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006542:	00003517          	auipc	a0,0x3
    80006546:	3fe50513          	addi	a0,a0,1022 # 80009940 <syscalls+0x378>
    8000654a:	ffffa097          	auipc	ra,0xffffa
    8000654e:	fe0080e7          	jalr	-32(ra) # 8000052a <panic>
    panic("unlink: writei");
    80006552:	00003517          	auipc	a0,0x3
    80006556:	40650513          	addi	a0,a0,1030 # 80009958 <syscalls+0x390>
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	fd0080e7          	jalr	-48(ra) # 8000052a <panic>
    dp->nlink--;
    80006562:	04a4d783          	lhu	a5,74(s1)
    80006566:	37fd                	addiw	a5,a5,-1
    80006568:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000656c:	8526                	mv	a0,s1
    8000656e:	ffffe097          	auipc	ra,0xffffe
    80006572:	fbc080e7          	jalr	-68(ra) # 8000452a <iupdate>
    80006576:	b781                	j	800064b6 <sys_unlink+0xe0>
    return -1;
    80006578:	557d                	li	a0,-1
    8000657a:	a005                	j	8000659a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000657c:	854a                	mv	a0,s2
    8000657e:	ffffe097          	auipc	ra,0xffffe
    80006582:	2d8080e7          	jalr	728(ra) # 80004856 <iunlockput>
  iunlockput(dp);
    80006586:	8526                	mv	a0,s1
    80006588:	ffffe097          	auipc	ra,0xffffe
    8000658c:	2ce080e7          	jalr	718(ra) # 80004856 <iunlockput>
  end_op();
    80006590:	fffff097          	auipc	ra,0xfffff
    80006594:	ab8080e7          	jalr	-1352(ra) # 80005048 <end_op>
  return -1;
    80006598:	557d                	li	a0,-1
}
    8000659a:	70ae                	ld	ra,232(sp)
    8000659c:	740e                	ld	s0,224(sp)
    8000659e:	64ee                	ld	s1,216(sp)
    800065a0:	694e                	ld	s2,208(sp)
    800065a2:	69ae                	ld	s3,200(sp)
    800065a4:	616d                	addi	sp,sp,240
    800065a6:	8082                	ret

00000000800065a8 <sys_open>:

uint64
sys_open(void)
{
    800065a8:	7131                	addi	sp,sp,-192
    800065aa:	fd06                	sd	ra,184(sp)
    800065ac:	f922                	sd	s0,176(sp)
    800065ae:	f526                	sd	s1,168(sp)
    800065b0:	f14a                	sd	s2,160(sp)
    800065b2:	ed4e                	sd	s3,152(sp)
    800065b4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800065b6:	08000613          	li	a2,128
    800065ba:	f5040593          	addi	a1,s0,-176
    800065be:	4501                	li	a0,0
    800065c0:	ffffd097          	auipc	ra,0xffffd
    800065c4:	1bc080e7          	jalr	444(ra) # 8000377c <argstr>
    return -1;
    800065c8:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800065ca:	0c054163          	bltz	a0,8000668c <sys_open+0xe4>
    800065ce:	f4c40593          	addi	a1,s0,-180
    800065d2:	4505                	li	a0,1
    800065d4:	ffffd097          	auipc	ra,0xffffd
    800065d8:	164080e7          	jalr	356(ra) # 80003738 <argint>
    800065dc:	0a054863          	bltz	a0,8000668c <sys_open+0xe4>

  begin_op();
    800065e0:	fffff097          	auipc	ra,0xfffff
    800065e4:	9e8080e7          	jalr	-1560(ra) # 80004fc8 <begin_op>

  if(omode & O_CREATE){
    800065e8:	f4c42783          	lw	a5,-180(s0)
    800065ec:	2007f793          	andi	a5,a5,512
    800065f0:	cbdd                	beqz	a5,800066a6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800065f2:	4681                	li	a3,0
    800065f4:	4601                	li	a2,0
    800065f6:	4589                	li	a1,2
    800065f8:	f5040513          	addi	a0,s0,-176
    800065fc:	00000097          	auipc	ra,0x0
    80006600:	974080e7          	jalr	-1676(ra) # 80005f70 <create>
    80006604:	892a                	mv	s2,a0
    if(ip == 0){
    80006606:	c959                	beqz	a0,8000669c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006608:	04491703          	lh	a4,68(s2)
    8000660c:	478d                	li	a5,3
    8000660e:	00f71763          	bne	a4,a5,8000661c <sys_open+0x74>
    80006612:	04695703          	lhu	a4,70(s2)
    80006616:	47a5                	li	a5,9
    80006618:	0ce7ec63          	bltu	a5,a4,800066f0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000661c:	fffff097          	auipc	ra,0xfffff
    80006620:	dbc080e7          	jalr	-580(ra) # 800053d8 <filealloc>
    80006624:	89aa                	mv	s3,a0
    80006626:	10050263          	beqz	a0,8000672a <sys_open+0x182>
    8000662a:	00000097          	auipc	ra,0x0
    8000662e:	904080e7          	jalr	-1788(ra) # 80005f2e <fdalloc>
    80006632:	84aa                	mv	s1,a0
    80006634:	0e054663          	bltz	a0,80006720 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006638:	04491703          	lh	a4,68(s2)
    8000663c:	478d                	li	a5,3
    8000663e:	0cf70463          	beq	a4,a5,80006706 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006642:	4789                	li	a5,2
    80006644:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006648:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000664c:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006650:	f4c42783          	lw	a5,-180(s0)
    80006654:	0017c713          	xori	a4,a5,1
    80006658:	8b05                	andi	a4,a4,1
    8000665a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000665e:	0037f713          	andi	a4,a5,3
    80006662:	00e03733          	snez	a4,a4
    80006666:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000666a:	4007f793          	andi	a5,a5,1024
    8000666e:	c791                	beqz	a5,8000667a <sys_open+0xd2>
    80006670:	04491703          	lh	a4,68(s2)
    80006674:	4789                	li	a5,2
    80006676:	08f70f63          	beq	a4,a5,80006714 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000667a:	854a                	mv	a0,s2
    8000667c:	ffffe097          	auipc	ra,0xffffe
    80006680:	03a080e7          	jalr	58(ra) # 800046b6 <iunlock>
  end_op();
    80006684:	fffff097          	auipc	ra,0xfffff
    80006688:	9c4080e7          	jalr	-1596(ra) # 80005048 <end_op>

  return fd;
}
    8000668c:	8526                	mv	a0,s1
    8000668e:	70ea                	ld	ra,184(sp)
    80006690:	744a                	ld	s0,176(sp)
    80006692:	74aa                	ld	s1,168(sp)
    80006694:	790a                	ld	s2,160(sp)
    80006696:	69ea                	ld	s3,152(sp)
    80006698:	6129                	addi	sp,sp,192
    8000669a:	8082                	ret
      end_op();
    8000669c:	fffff097          	auipc	ra,0xfffff
    800066a0:	9ac080e7          	jalr	-1620(ra) # 80005048 <end_op>
      return -1;
    800066a4:	b7e5                	j	8000668c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800066a6:	f5040513          	addi	a0,s0,-176
    800066aa:	ffffe097          	auipc	ra,0xffffe
    800066ae:	6fe080e7          	jalr	1790(ra) # 80004da8 <namei>
    800066b2:	892a                	mv	s2,a0
    800066b4:	c905                	beqz	a0,800066e4 <sys_open+0x13c>
    ilock(ip);
    800066b6:	ffffe097          	auipc	ra,0xffffe
    800066ba:	f3e080e7          	jalr	-194(ra) # 800045f4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800066be:	04491703          	lh	a4,68(s2)
    800066c2:	4785                	li	a5,1
    800066c4:	f4f712e3          	bne	a4,a5,80006608 <sys_open+0x60>
    800066c8:	f4c42783          	lw	a5,-180(s0)
    800066cc:	dba1                	beqz	a5,8000661c <sys_open+0x74>
      iunlockput(ip);
    800066ce:	854a                	mv	a0,s2
    800066d0:	ffffe097          	auipc	ra,0xffffe
    800066d4:	186080e7          	jalr	390(ra) # 80004856 <iunlockput>
      end_op();
    800066d8:	fffff097          	auipc	ra,0xfffff
    800066dc:	970080e7          	jalr	-1680(ra) # 80005048 <end_op>
      return -1;
    800066e0:	54fd                	li	s1,-1
    800066e2:	b76d                	j	8000668c <sys_open+0xe4>
      end_op();
    800066e4:	fffff097          	auipc	ra,0xfffff
    800066e8:	964080e7          	jalr	-1692(ra) # 80005048 <end_op>
      return -1;
    800066ec:	54fd                	li	s1,-1
    800066ee:	bf79                	j	8000668c <sys_open+0xe4>
    iunlockput(ip);
    800066f0:	854a                	mv	a0,s2
    800066f2:	ffffe097          	auipc	ra,0xffffe
    800066f6:	164080e7          	jalr	356(ra) # 80004856 <iunlockput>
    end_op();
    800066fa:	fffff097          	auipc	ra,0xfffff
    800066fe:	94e080e7          	jalr	-1714(ra) # 80005048 <end_op>
    return -1;
    80006702:	54fd                	li	s1,-1
    80006704:	b761                	j	8000668c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006706:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000670a:	04691783          	lh	a5,70(s2)
    8000670e:	02f99223          	sh	a5,36(s3)
    80006712:	bf2d                	j	8000664c <sys_open+0xa4>
    itrunc(ip);
    80006714:	854a                	mv	a0,s2
    80006716:	ffffe097          	auipc	ra,0xffffe
    8000671a:	fec080e7          	jalr	-20(ra) # 80004702 <itrunc>
    8000671e:	bfb1                	j	8000667a <sys_open+0xd2>
      fileclose(f);
    80006720:	854e                	mv	a0,s3
    80006722:	fffff097          	auipc	ra,0xfffff
    80006726:	d72080e7          	jalr	-654(ra) # 80005494 <fileclose>
    iunlockput(ip);
    8000672a:	854a                	mv	a0,s2
    8000672c:	ffffe097          	auipc	ra,0xffffe
    80006730:	12a080e7          	jalr	298(ra) # 80004856 <iunlockput>
    end_op();
    80006734:	fffff097          	auipc	ra,0xfffff
    80006738:	914080e7          	jalr	-1772(ra) # 80005048 <end_op>
    return -1;
    8000673c:	54fd                	li	s1,-1
    8000673e:	b7b9                	j	8000668c <sys_open+0xe4>

0000000080006740 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006740:	7175                	addi	sp,sp,-144
    80006742:	e506                	sd	ra,136(sp)
    80006744:	e122                	sd	s0,128(sp)
    80006746:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006748:	fffff097          	auipc	ra,0xfffff
    8000674c:	880080e7          	jalr	-1920(ra) # 80004fc8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006750:	08000613          	li	a2,128
    80006754:	f7040593          	addi	a1,s0,-144
    80006758:	4501                	li	a0,0
    8000675a:	ffffd097          	auipc	ra,0xffffd
    8000675e:	022080e7          	jalr	34(ra) # 8000377c <argstr>
    80006762:	02054963          	bltz	a0,80006794 <sys_mkdir+0x54>
    80006766:	4681                	li	a3,0
    80006768:	4601                	li	a2,0
    8000676a:	4585                	li	a1,1
    8000676c:	f7040513          	addi	a0,s0,-144
    80006770:	00000097          	auipc	ra,0x0
    80006774:	800080e7          	jalr	-2048(ra) # 80005f70 <create>
    80006778:	cd11                	beqz	a0,80006794 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000677a:	ffffe097          	auipc	ra,0xffffe
    8000677e:	0dc080e7          	jalr	220(ra) # 80004856 <iunlockput>
  end_op();
    80006782:	fffff097          	auipc	ra,0xfffff
    80006786:	8c6080e7          	jalr	-1850(ra) # 80005048 <end_op>
  return 0;
    8000678a:	4501                	li	a0,0
}
    8000678c:	60aa                	ld	ra,136(sp)
    8000678e:	640a                	ld	s0,128(sp)
    80006790:	6149                	addi	sp,sp,144
    80006792:	8082                	ret
    end_op();
    80006794:	fffff097          	auipc	ra,0xfffff
    80006798:	8b4080e7          	jalr	-1868(ra) # 80005048 <end_op>
    return -1;
    8000679c:	557d                	li	a0,-1
    8000679e:	b7fd                	j	8000678c <sys_mkdir+0x4c>

00000000800067a0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800067a0:	7135                	addi	sp,sp,-160
    800067a2:	ed06                	sd	ra,152(sp)
    800067a4:	e922                	sd	s0,144(sp)
    800067a6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800067a8:	fffff097          	auipc	ra,0xfffff
    800067ac:	820080e7          	jalr	-2016(ra) # 80004fc8 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800067b0:	08000613          	li	a2,128
    800067b4:	f7040593          	addi	a1,s0,-144
    800067b8:	4501                	li	a0,0
    800067ba:	ffffd097          	auipc	ra,0xffffd
    800067be:	fc2080e7          	jalr	-62(ra) # 8000377c <argstr>
    800067c2:	04054a63          	bltz	a0,80006816 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800067c6:	f6c40593          	addi	a1,s0,-148
    800067ca:	4505                	li	a0,1
    800067cc:	ffffd097          	auipc	ra,0xffffd
    800067d0:	f6c080e7          	jalr	-148(ra) # 80003738 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800067d4:	04054163          	bltz	a0,80006816 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800067d8:	f6840593          	addi	a1,s0,-152
    800067dc:	4509                	li	a0,2
    800067de:	ffffd097          	auipc	ra,0xffffd
    800067e2:	f5a080e7          	jalr	-166(ra) # 80003738 <argint>
     argint(1, &major) < 0 ||
    800067e6:	02054863          	bltz	a0,80006816 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800067ea:	f6841683          	lh	a3,-152(s0)
    800067ee:	f6c41603          	lh	a2,-148(s0)
    800067f2:	458d                	li	a1,3
    800067f4:	f7040513          	addi	a0,s0,-144
    800067f8:	fffff097          	auipc	ra,0xfffff
    800067fc:	778080e7          	jalr	1912(ra) # 80005f70 <create>
     argint(2, &minor) < 0 ||
    80006800:	c919                	beqz	a0,80006816 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006802:	ffffe097          	auipc	ra,0xffffe
    80006806:	054080e7          	jalr	84(ra) # 80004856 <iunlockput>
  end_op();
    8000680a:	fffff097          	auipc	ra,0xfffff
    8000680e:	83e080e7          	jalr	-1986(ra) # 80005048 <end_op>
  return 0;
    80006812:	4501                	li	a0,0
    80006814:	a031                	j	80006820 <sys_mknod+0x80>
    end_op();
    80006816:	fffff097          	auipc	ra,0xfffff
    8000681a:	832080e7          	jalr	-1998(ra) # 80005048 <end_op>
    return -1;
    8000681e:	557d                	li	a0,-1
}
    80006820:	60ea                	ld	ra,152(sp)
    80006822:	644a                	ld	s0,144(sp)
    80006824:	610d                	addi	sp,sp,160
    80006826:	8082                	ret

0000000080006828 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006828:	7135                	addi	sp,sp,-160
    8000682a:	ed06                	sd	ra,152(sp)
    8000682c:	e922                	sd	s0,144(sp)
    8000682e:	e526                	sd	s1,136(sp)
    80006830:	e14a                	sd	s2,128(sp)
    80006832:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006834:	ffffb097          	auipc	ra,0xffffb
    80006838:	3c0080e7          	jalr	960(ra) # 80001bf4 <myproc>
    8000683c:	892a                	mv	s2,a0
  
  begin_op();
    8000683e:	ffffe097          	auipc	ra,0xffffe
    80006842:	78a080e7          	jalr	1930(ra) # 80004fc8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006846:	08000613          	li	a2,128
    8000684a:	f6040593          	addi	a1,s0,-160
    8000684e:	4501                	li	a0,0
    80006850:	ffffd097          	auipc	ra,0xffffd
    80006854:	f2c080e7          	jalr	-212(ra) # 8000377c <argstr>
    80006858:	04054b63          	bltz	a0,800068ae <sys_chdir+0x86>
    8000685c:	f6040513          	addi	a0,s0,-160
    80006860:	ffffe097          	auipc	ra,0xffffe
    80006864:	548080e7          	jalr	1352(ra) # 80004da8 <namei>
    80006868:	84aa                	mv	s1,a0
    8000686a:	c131                	beqz	a0,800068ae <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000686c:	ffffe097          	auipc	ra,0xffffe
    80006870:	d88080e7          	jalr	-632(ra) # 800045f4 <ilock>
  if(ip->type != T_DIR){
    80006874:	04449703          	lh	a4,68(s1)
    80006878:	4785                	li	a5,1
    8000687a:	04f71063          	bne	a4,a5,800068ba <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000687e:	8526                	mv	a0,s1
    80006880:	ffffe097          	auipc	ra,0xffffe
    80006884:	e36080e7          	jalr	-458(ra) # 800046b6 <iunlock>
  iput(p->cwd);
    80006888:	0c893503          	ld	a0,200(s2)
    8000688c:	ffffe097          	auipc	ra,0xffffe
    80006890:	f22080e7          	jalr	-222(ra) # 800047ae <iput>
  end_op();
    80006894:	ffffe097          	auipc	ra,0xffffe
    80006898:	7b4080e7          	jalr	1972(ra) # 80005048 <end_op>
  p->cwd = ip;
    8000689c:	0c993423          	sd	s1,200(s2)
  return 0;
    800068a0:	4501                	li	a0,0
}
    800068a2:	60ea                	ld	ra,152(sp)
    800068a4:	644a                	ld	s0,144(sp)
    800068a6:	64aa                	ld	s1,136(sp)
    800068a8:	690a                	ld	s2,128(sp)
    800068aa:	610d                	addi	sp,sp,160
    800068ac:	8082                	ret
    end_op();
    800068ae:	ffffe097          	auipc	ra,0xffffe
    800068b2:	79a080e7          	jalr	1946(ra) # 80005048 <end_op>
    return -1;
    800068b6:	557d                	li	a0,-1
    800068b8:	b7ed                	j	800068a2 <sys_chdir+0x7a>
    iunlockput(ip);
    800068ba:	8526                	mv	a0,s1
    800068bc:	ffffe097          	auipc	ra,0xffffe
    800068c0:	f9a080e7          	jalr	-102(ra) # 80004856 <iunlockput>
    end_op();
    800068c4:	ffffe097          	auipc	ra,0xffffe
    800068c8:	784080e7          	jalr	1924(ra) # 80005048 <end_op>
    return -1;
    800068cc:	557d                	li	a0,-1
    800068ce:	bfd1                	j	800068a2 <sys_chdir+0x7a>

00000000800068d0 <sys_exec>:

uint64
sys_exec(void)
{
    800068d0:	7145                	addi	sp,sp,-464
    800068d2:	e786                	sd	ra,456(sp)
    800068d4:	e3a2                	sd	s0,448(sp)
    800068d6:	ff26                	sd	s1,440(sp)
    800068d8:	fb4a                	sd	s2,432(sp)
    800068da:	f74e                	sd	s3,424(sp)
    800068dc:	f352                	sd	s4,416(sp)
    800068de:	ef56                	sd	s5,408(sp)
    800068e0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800068e2:	08000613          	li	a2,128
    800068e6:	f4040593          	addi	a1,s0,-192
    800068ea:	4501                	li	a0,0
    800068ec:	ffffd097          	auipc	ra,0xffffd
    800068f0:	e90080e7          	jalr	-368(ra) # 8000377c <argstr>
    return -1;
    800068f4:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800068f6:	0c054a63          	bltz	a0,800069ca <sys_exec+0xfa>
    800068fa:	e3840593          	addi	a1,s0,-456
    800068fe:	4505                	li	a0,1
    80006900:	ffffd097          	auipc	ra,0xffffd
    80006904:	e5a080e7          	jalr	-422(ra) # 8000375a <argaddr>
    80006908:	0c054163          	bltz	a0,800069ca <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000690c:	10000613          	li	a2,256
    80006910:	4581                	li	a1,0
    80006912:	e4040513          	addi	a0,s0,-448
    80006916:	ffffa097          	auipc	ra,0xffffa
    8000691a:	3a8080e7          	jalr	936(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000691e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006922:	89a6                	mv	s3,s1
    80006924:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006926:	02000a13          	li	s4,32
    8000692a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000692e:	00391793          	slli	a5,s2,0x3
    80006932:	e3040593          	addi	a1,s0,-464
    80006936:	e3843503          	ld	a0,-456(s0)
    8000693a:	953e                	add	a0,a0,a5
    8000693c:	ffffd097          	auipc	ra,0xffffd
    80006940:	d62080e7          	jalr	-670(ra) # 8000369e <fetchaddr>
    80006944:	02054a63          	bltz	a0,80006978 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006948:	e3043783          	ld	a5,-464(s0)
    8000694c:	c3b9                	beqz	a5,80006992 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000694e:	ffffa097          	auipc	ra,0xffffa
    80006952:	184080e7          	jalr	388(ra) # 80000ad2 <kalloc>
    80006956:	85aa                	mv	a1,a0
    80006958:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000695c:	cd11                	beqz	a0,80006978 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000695e:	6605                	lui	a2,0x1
    80006960:	e3043503          	ld	a0,-464(s0)
    80006964:	ffffd097          	auipc	ra,0xffffd
    80006968:	d8c080e7          	jalr	-628(ra) # 800036f0 <fetchstr>
    8000696c:	00054663          	bltz	a0,80006978 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006970:	0905                	addi	s2,s2,1
    80006972:	09a1                	addi	s3,s3,8
    80006974:	fb491be3          	bne	s2,s4,8000692a <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006978:	10048913          	addi	s2,s1,256
    8000697c:	6088                	ld	a0,0(s1)
    8000697e:	c529                	beqz	a0,800069c8 <sys_exec+0xf8>
    kfree(argv[i]);
    80006980:	ffffa097          	auipc	ra,0xffffa
    80006984:	056080e7          	jalr	86(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006988:	04a1                	addi	s1,s1,8
    8000698a:	ff2499e3          	bne	s1,s2,8000697c <sys_exec+0xac>
  return -1;
    8000698e:	597d                	li	s2,-1
    80006990:	a82d                	j	800069ca <sys_exec+0xfa>
      argv[i] = 0;
    80006992:	0a8e                	slli	s5,s5,0x3
    80006994:	fc040793          	addi	a5,s0,-64
    80006998:	9abe                	add	s5,s5,a5
    8000699a:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffb9e80>
  int ret = exec(path, argv);
    8000699e:	e4040593          	addi	a1,s0,-448
    800069a2:	f4040513          	addi	a0,s0,-192
    800069a6:	fffff097          	auipc	ra,0xfffff
    800069aa:	140080e7          	jalr	320(ra) # 80005ae6 <exec>
    800069ae:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800069b0:	10048993          	addi	s3,s1,256
    800069b4:	6088                	ld	a0,0(s1)
    800069b6:	c911                	beqz	a0,800069ca <sys_exec+0xfa>
    kfree(argv[i]);
    800069b8:	ffffa097          	auipc	ra,0xffffa
    800069bc:	01e080e7          	jalr	30(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800069c0:	04a1                	addi	s1,s1,8
    800069c2:	ff3499e3          	bne	s1,s3,800069b4 <sys_exec+0xe4>
    800069c6:	a011                	j	800069ca <sys_exec+0xfa>
  return -1;
    800069c8:	597d                	li	s2,-1
}
    800069ca:	854a                	mv	a0,s2
    800069cc:	60be                	ld	ra,456(sp)
    800069ce:	641e                	ld	s0,448(sp)
    800069d0:	74fa                	ld	s1,440(sp)
    800069d2:	795a                	ld	s2,432(sp)
    800069d4:	79ba                	ld	s3,424(sp)
    800069d6:	7a1a                	ld	s4,416(sp)
    800069d8:	6afa                	ld	s5,408(sp)
    800069da:	6179                	addi	sp,sp,464
    800069dc:	8082                	ret

00000000800069de <sys_pipe>:

uint64
sys_pipe(void)
{
    800069de:	7139                	addi	sp,sp,-64
    800069e0:	fc06                	sd	ra,56(sp)
    800069e2:	f822                	sd	s0,48(sp)
    800069e4:	f426                	sd	s1,40(sp)
    800069e6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800069e8:	ffffb097          	auipc	ra,0xffffb
    800069ec:	20c080e7          	jalr	524(ra) # 80001bf4 <myproc>
    800069f0:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800069f2:	fd840593          	addi	a1,s0,-40
    800069f6:	4501                	li	a0,0
    800069f8:	ffffd097          	auipc	ra,0xffffd
    800069fc:	d62080e7          	jalr	-670(ra) # 8000375a <argaddr>
    return -1;
    80006a00:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006a02:	0e054063          	bltz	a0,80006ae2 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006a06:	fc840593          	addi	a1,s0,-56
    80006a0a:	fd040513          	addi	a0,s0,-48
    80006a0e:	fffff097          	auipc	ra,0xfffff
    80006a12:	db6080e7          	jalr	-586(ra) # 800057c4 <pipealloc>
    return -1;
    80006a16:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006a18:	0c054563          	bltz	a0,80006ae2 <sys_pipe+0x104>
  fd0 = -1;
    80006a1c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006a20:	fd043503          	ld	a0,-48(s0)
    80006a24:	fffff097          	auipc	ra,0xfffff
    80006a28:	50a080e7          	jalr	1290(ra) # 80005f2e <fdalloc>
    80006a2c:	fca42223          	sw	a0,-60(s0)
    80006a30:	08054c63          	bltz	a0,80006ac8 <sys_pipe+0xea>
    80006a34:	fc843503          	ld	a0,-56(s0)
    80006a38:	fffff097          	auipc	ra,0xfffff
    80006a3c:	4f6080e7          	jalr	1270(ra) # 80005f2e <fdalloc>
    80006a40:	fca42023          	sw	a0,-64(s0)
    80006a44:	06054863          	bltz	a0,80006ab4 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006a48:	4691                	li	a3,4
    80006a4a:	fc440613          	addi	a2,s0,-60
    80006a4e:	fd843583          	ld	a1,-40(s0)
    80006a52:	60a8                	ld	a0,64(s1)
    80006a54:	ffffb097          	auipc	ra,0xffffb
    80006a58:	bf2080e7          	jalr	-1038(ra) # 80001646 <copyout>
    80006a5c:	02054063          	bltz	a0,80006a7c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006a60:	4691                	li	a3,4
    80006a62:	fc040613          	addi	a2,s0,-64
    80006a66:	fd843583          	ld	a1,-40(s0)
    80006a6a:	0591                	addi	a1,a1,4
    80006a6c:	60a8                	ld	a0,64(s1)
    80006a6e:	ffffb097          	auipc	ra,0xffffb
    80006a72:	bd8080e7          	jalr	-1064(ra) # 80001646 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006a76:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006a78:	06055563          	bgez	a0,80006ae2 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006a7c:	fc442783          	lw	a5,-60(s0)
    80006a80:	07a1                	addi	a5,a5,8
    80006a82:	078e                	slli	a5,a5,0x3
    80006a84:	97a6                	add	a5,a5,s1
    80006a86:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006a8a:	fc042503          	lw	a0,-64(s0)
    80006a8e:	0521                	addi	a0,a0,8
    80006a90:	050e                	slli	a0,a0,0x3
    80006a92:	9526                	add	a0,a0,s1
    80006a94:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006a98:	fd043503          	ld	a0,-48(s0)
    80006a9c:	fffff097          	auipc	ra,0xfffff
    80006aa0:	9f8080e7          	jalr	-1544(ra) # 80005494 <fileclose>
    fileclose(wf);
    80006aa4:	fc843503          	ld	a0,-56(s0)
    80006aa8:	fffff097          	auipc	ra,0xfffff
    80006aac:	9ec080e7          	jalr	-1556(ra) # 80005494 <fileclose>
    return -1;
    80006ab0:	57fd                	li	a5,-1
    80006ab2:	a805                	j	80006ae2 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006ab4:	fc442783          	lw	a5,-60(s0)
    80006ab8:	0007c863          	bltz	a5,80006ac8 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006abc:	00878513          	addi	a0,a5,8
    80006ac0:	050e                	slli	a0,a0,0x3
    80006ac2:	9526                	add	a0,a0,s1
    80006ac4:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006ac8:	fd043503          	ld	a0,-48(s0)
    80006acc:	fffff097          	auipc	ra,0xfffff
    80006ad0:	9c8080e7          	jalr	-1592(ra) # 80005494 <fileclose>
    fileclose(wf);
    80006ad4:	fc843503          	ld	a0,-56(s0)
    80006ad8:	fffff097          	auipc	ra,0xfffff
    80006adc:	9bc080e7          	jalr	-1604(ra) # 80005494 <fileclose>
    return -1;
    80006ae0:	57fd                	li	a5,-1
}
    80006ae2:	853e                	mv	a0,a5
    80006ae4:	70e2                	ld	ra,56(sp)
    80006ae6:	7442                	ld	s0,48(sp)
    80006ae8:	74a2                	ld	s1,40(sp)
    80006aea:	6121                	addi	sp,sp,64
    80006aec:	8082                	ret
	...

0000000080006af0 <kernelvec>:
    80006af0:	7111                	addi	sp,sp,-256
    80006af2:	e006                	sd	ra,0(sp)
    80006af4:	e40a                	sd	sp,8(sp)
    80006af6:	e80e                	sd	gp,16(sp)
    80006af8:	ec12                	sd	tp,24(sp)
    80006afa:	f016                	sd	t0,32(sp)
    80006afc:	f41a                	sd	t1,40(sp)
    80006afe:	f81e                	sd	t2,48(sp)
    80006b00:	fc22                	sd	s0,56(sp)
    80006b02:	e0a6                	sd	s1,64(sp)
    80006b04:	e4aa                	sd	a0,72(sp)
    80006b06:	e8ae                	sd	a1,80(sp)
    80006b08:	ecb2                	sd	a2,88(sp)
    80006b0a:	f0b6                	sd	a3,96(sp)
    80006b0c:	f4ba                	sd	a4,104(sp)
    80006b0e:	f8be                	sd	a5,112(sp)
    80006b10:	fcc2                	sd	a6,120(sp)
    80006b12:	e146                	sd	a7,128(sp)
    80006b14:	e54a                	sd	s2,136(sp)
    80006b16:	e94e                	sd	s3,144(sp)
    80006b18:	ed52                	sd	s4,152(sp)
    80006b1a:	f156                	sd	s5,160(sp)
    80006b1c:	f55a                	sd	s6,168(sp)
    80006b1e:	f95e                	sd	s7,176(sp)
    80006b20:	fd62                	sd	s8,184(sp)
    80006b22:	e1e6                	sd	s9,192(sp)
    80006b24:	e5ea                	sd	s10,200(sp)
    80006b26:	e9ee                	sd	s11,208(sp)
    80006b28:	edf2                	sd	t3,216(sp)
    80006b2a:	f1f6                	sd	t4,224(sp)
    80006b2c:	f5fa                	sd	t5,232(sp)
    80006b2e:	f9fe                	sd	t6,240(sp)
    80006b30:	db8fc0ef          	jal	ra,800030e8 <kerneltrap>
    80006b34:	6082                	ld	ra,0(sp)
    80006b36:	6122                	ld	sp,8(sp)
    80006b38:	61c2                	ld	gp,16(sp)
    80006b3a:	7282                	ld	t0,32(sp)
    80006b3c:	7322                	ld	t1,40(sp)
    80006b3e:	73c2                	ld	t2,48(sp)
    80006b40:	7462                	ld	s0,56(sp)
    80006b42:	6486                	ld	s1,64(sp)
    80006b44:	6526                	ld	a0,72(sp)
    80006b46:	65c6                	ld	a1,80(sp)
    80006b48:	6666                	ld	a2,88(sp)
    80006b4a:	7686                	ld	a3,96(sp)
    80006b4c:	7726                	ld	a4,104(sp)
    80006b4e:	77c6                	ld	a5,112(sp)
    80006b50:	7866                	ld	a6,120(sp)
    80006b52:	688a                	ld	a7,128(sp)
    80006b54:	692a                	ld	s2,136(sp)
    80006b56:	69ca                	ld	s3,144(sp)
    80006b58:	6a6a                	ld	s4,152(sp)
    80006b5a:	7a8a                	ld	s5,160(sp)
    80006b5c:	7b2a                	ld	s6,168(sp)
    80006b5e:	7bca                	ld	s7,176(sp)
    80006b60:	7c6a                	ld	s8,184(sp)
    80006b62:	6c8e                	ld	s9,192(sp)
    80006b64:	6d2e                	ld	s10,200(sp)
    80006b66:	6dce                	ld	s11,208(sp)
    80006b68:	6e6e                	ld	t3,216(sp)
    80006b6a:	7e8e                	ld	t4,224(sp)
    80006b6c:	7f2e                	ld	t5,232(sp)
    80006b6e:	7fce                	ld	t6,240(sp)
    80006b70:	6111                	addi	sp,sp,256
    80006b72:	10200073          	sret
    80006b76:	00000013          	nop
    80006b7a:	00000013          	nop
    80006b7e:	0001                	nop

0000000080006b80 <timervec>:
    80006b80:	34051573          	csrrw	a0,mscratch,a0
    80006b84:	e10c                	sd	a1,0(a0)
    80006b86:	e510                	sd	a2,8(a0)
    80006b88:	e914                	sd	a3,16(a0)
    80006b8a:	6d0c                	ld	a1,24(a0)
    80006b8c:	7110                	ld	a2,32(a0)
    80006b8e:	6194                	ld	a3,0(a1)
    80006b90:	96b2                	add	a3,a3,a2
    80006b92:	e194                	sd	a3,0(a1)
    80006b94:	4589                	li	a1,2
    80006b96:	14459073          	csrw	sip,a1
    80006b9a:	6914                	ld	a3,16(a0)
    80006b9c:	6510                	ld	a2,8(a0)
    80006b9e:	610c                	ld	a1,0(a0)
    80006ba0:	34051573          	csrrw	a0,mscratch,a0
    80006ba4:	30200073          	mret
	...

0000000080006baa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006baa:	1141                	addi	sp,sp,-16
    80006bac:	e422                	sd	s0,8(sp)
    80006bae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006bb0:	0c0007b7          	lui	a5,0xc000
    80006bb4:	4705                	li	a4,1
    80006bb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006bb8:	c3d8                	sw	a4,4(a5)
}
    80006bba:	6422                	ld	s0,8(sp)
    80006bbc:	0141                	addi	sp,sp,16
    80006bbe:	8082                	ret

0000000080006bc0 <plicinithart>:

void
plicinithart(void)
{
    80006bc0:	1141                	addi	sp,sp,-16
    80006bc2:	e406                	sd	ra,8(sp)
    80006bc4:	e022                	sd	s0,0(sp)
    80006bc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006bc8:	ffffb097          	auipc	ra,0xffffb
    80006bcc:	000080e7          	jalr	ra # 80001bc8 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006bd0:	0085171b          	slliw	a4,a0,0x8
    80006bd4:	0c0027b7          	lui	a5,0xc002
    80006bd8:	97ba                	add	a5,a5,a4
    80006bda:	40200713          	li	a4,1026
    80006bde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006be2:	00d5151b          	slliw	a0,a0,0xd
    80006be6:	0c2017b7          	lui	a5,0xc201
    80006bea:	953e                	add	a0,a0,a5
    80006bec:	00052023          	sw	zero,0(a0)
}
    80006bf0:	60a2                	ld	ra,8(sp)
    80006bf2:	6402                	ld	s0,0(sp)
    80006bf4:	0141                	addi	sp,sp,16
    80006bf6:	8082                	ret

0000000080006bf8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006bf8:	1141                	addi	sp,sp,-16
    80006bfa:	e406                	sd	ra,8(sp)
    80006bfc:	e022                	sd	s0,0(sp)
    80006bfe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006c00:	ffffb097          	auipc	ra,0xffffb
    80006c04:	fc8080e7          	jalr	-56(ra) # 80001bc8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006c08:	00d5179b          	slliw	a5,a0,0xd
    80006c0c:	0c201537          	lui	a0,0xc201
    80006c10:	953e                	add	a0,a0,a5
  return irq;
}
    80006c12:	4148                	lw	a0,4(a0)
    80006c14:	60a2                	ld	ra,8(sp)
    80006c16:	6402                	ld	s0,0(sp)
    80006c18:	0141                	addi	sp,sp,16
    80006c1a:	8082                	ret

0000000080006c1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006c1c:	1101                	addi	sp,sp,-32
    80006c1e:	ec06                	sd	ra,24(sp)
    80006c20:	e822                	sd	s0,16(sp)
    80006c22:	e426                	sd	s1,8(sp)
    80006c24:	1000                	addi	s0,sp,32
    80006c26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006c28:	ffffb097          	auipc	ra,0xffffb
    80006c2c:	fa0080e7          	jalr	-96(ra) # 80001bc8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006c30:	00d5151b          	slliw	a0,a0,0xd
    80006c34:	0c2017b7          	lui	a5,0xc201
    80006c38:	97aa                	add	a5,a5,a0
    80006c3a:	c3c4                	sw	s1,4(a5)
}
    80006c3c:	60e2                	ld	ra,24(sp)
    80006c3e:	6442                	ld	s0,16(sp)
    80006c40:	64a2                	ld	s1,8(sp)
    80006c42:	6105                	addi	sp,sp,32
    80006c44:	8082                	ret

0000000080006c46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006c46:	1141                	addi	sp,sp,-16
    80006c48:	e406                	sd	ra,8(sp)
    80006c4a:	e022                	sd	s0,0(sp)
    80006c4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006c4e:	479d                	li	a5,7
    80006c50:	06a7c963          	blt	a5,a0,80006cc2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006c54:	0003b797          	auipc	a5,0x3b
    80006c58:	3ac78793          	addi	a5,a5,940 # 80042000 <disk>
    80006c5c:	00a78733          	add	a4,a5,a0
    80006c60:	6789                	lui	a5,0x2
    80006c62:	97ba                	add	a5,a5,a4
    80006c64:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006c68:	e7ad                	bnez	a5,80006cd2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006c6a:	00451793          	slli	a5,a0,0x4
    80006c6e:	0003d717          	auipc	a4,0x3d
    80006c72:	39270713          	addi	a4,a4,914 # 80044000 <disk+0x2000>
    80006c76:	6314                	ld	a3,0(a4)
    80006c78:	96be                	add	a3,a3,a5
    80006c7a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006c7e:	6314                	ld	a3,0(a4)
    80006c80:	96be                	add	a3,a3,a5
    80006c82:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006c86:	6314                	ld	a3,0(a4)
    80006c88:	96be                	add	a3,a3,a5
    80006c8a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006c8e:	6318                	ld	a4,0(a4)
    80006c90:	97ba                	add	a5,a5,a4
    80006c92:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006c96:	0003b797          	auipc	a5,0x3b
    80006c9a:	36a78793          	addi	a5,a5,874 # 80042000 <disk>
    80006c9e:	97aa                	add	a5,a5,a0
    80006ca0:	6509                	lui	a0,0x2
    80006ca2:	953e                	add	a0,a0,a5
    80006ca4:	4785                	li	a5,1
    80006ca6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006caa:	0003d517          	auipc	a0,0x3d
    80006cae:	36e50513          	addi	a0,a0,878 # 80044018 <disk+0x2018>
    80006cb2:	ffffc097          	auipc	ra,0xffffc
    80006cb6:	8fc080e7          	jalr	-1796(ra) # 800025ae <wakeup>
}
    80006cba:	60a2                	ld	ra,8(sp)
    80006cbc:	6402                	ld	s0,0(sp)
    80006cbe:	0141                	addi	sp,sp,16
    80006cc0:	8082                	ret
    panic("free_desc 1");
    80006cc2:	00003517          	auipc	a0,0x3
    80006cc6:	ca650513          	addi	a0,a0,-858 # 80009968 <syscalls+0x3a0>
    80006cca:	ffffa097          	auipc	ra,0xffffa
    80006cce:	860080e7          	jalr	-1952(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006cd2:	00003517          	auipc	a0,0x3
    80006cd6:	ca650513          	addi	a0,a0,-858 # 80009978 <syscalls+0x3b0>
    80006cda:	ffffa097          	auipc	ra,0xffffa
    80006cde:	850080e7          	jalr	-1968(ra) # 8000052a <panic>

0000000080006ce2 <virtio_disk_init>:
{
    80006ce2:	1101                	addi	sp,sp,-32
    80006ce4:	ec06                	sd	ra,24(sp)
    80006ce6:	e822                	sd	s0,16(sp)
    80006ce8:	e426                	sd	s1,8(sp)
    80006cea:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006cec:	00003597          	auipc	a1,0x3
    80006cf0:	c9c58593          	addi	a1,a1,-868 # 80009988 <syscalls+0x3c0>
    80006cf4:	0003d517          	auipc	a0,0x3d
    80006cf8:	43450513          	addi	a0,a0,1076 # 80044128 <disk+0x2128>
    80006cfc:	ffffa097          	auipc	ra,0xffffa
    80006d00:	e36080e7          	jalr	-458(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006d04:	100017b7          	lui	a5,0x10001
    80006d08:	4398                	lw	a4,0(a5)
    80006d0a:	2701                	sext.w	a4,a4
    80006d0c:	747277b7          	lui	a5,0x74727
    80006d10:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006d14:	0ef71163          	bne	a4,a5,80006df6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006d18:	100017b7          	lui	a5,0x10001
    80006d1c:	43dc                	lw	a5,4(a5)
    80006d1e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006d20:	4705                	li	a4,1
    80006d22:	0ce79a63          	bne	a5,a4,80006df6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006d26:	100017b7          	lui	a5,0x10001
    80006d2a:	479c                	lw	a5,8(a5)
    80006d2c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006d2e:	4709                	li	a4,2
    80006d30:	0ce79363          	bne	a5,a4,80006df6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006d34:	100017b7          	lui	a5,0x10001
    80006d38:	47d8                	lw	a4,12(a5)
    80006d3a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006d3c:	554d47b7          	lui	a5,0x554d4
    80006d40:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006d44:	0af71963          	bne	a4,a5,80006df6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d48:	100017b7          	lui	a5,0x10001
    80006d4c:	4705                	li	a4,1
    80006d4e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d50:	470d                	li	a4,3
    80006d52:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006d54:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006d56:	c7ffe737          	lui	a4,0xc7ffe
    80006d5a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb975f>
    80006d5e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006d60:	2701                	sext.w	a4,a4
    80006d62:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d64:	472d                	li	a4,11
    80006d66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d68:	473d                	li	a4,15
    80006d6a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006d6c:	6705                	lui	a4,0x1
    80006d6e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006d70:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006d74:	5bdc                	lw	a5,52(a5)
    80006d76:	2781                	sext.w	a5,a5
  if(max == 0)
    80006d78:	c7d9                	beqz	a5,80006e06 <virtio_disk_init+0x124>
  if(max < NUM)
    80006d7a:	471d                	li	a4,7
    80006d7c:	08f77d63          	bgeu	a4,a5,80006e16 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006d80:	100014b7          	lui	s1,0x10001
    80006d84:	47a1                	li	a5,8
    80006d86:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006d88:	6609                	lui	a2,0x2
    80006d8a:	4581                	li	a1,0
    80006d8c:	0003b517          	auipc	a0,0x3b
    80006d90:	27450513          	addi	a0,a0,628 # 80042000 <disk>
    80006d94:	ffffa097          	auipc	ra,0xffffa
    80006d98:	f2a080e7          	jalr	-214(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006d9c:	0003b717          	auipc	a4,0x3b
    80006da0:	26470713          	addi	a4,a4,612 # 80042000 <disk>
    80006da4:	00c75793          	srli	a5,a4,0xc
    80006da8:	2781                	sext.w	a5,a5
    80006daa:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006dac:	0003d797          	auipc	a5,0x3d
    80006db0:	25478793          	addi	a5,a5,596 # 80044000 <disk+0x2000>
    80006db4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006db6:	0003b717          	auipc	a4,0x3b
    80006dba:	2ca70713          	addi	a4,a4,714 # 80042080 <disk+0x80>
    80006dbe:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006dc0:	0003c717          	auipc	a4,0x3c
    80006dc4:	24070713          	addi	a4,a4,576 # 80043000 <disk+0x1000>
    80006dc8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006dca:	4705                	li	a4,1
    80006dcc:	00e78c23          	sb	a4,24(a5)
    80006dd0:	00e78ca3          	sb	a4,25(a5)
    80006dd4:	00e78d23          	sb	a4,26(a5)
    80006dd8:	00e78da3          	sb	a4,27(a5)
    80006ddc:	00e78e23          	sb	a4,28(a5)
    80006de0:	00e78ea3          	sb	a4,29(a5)
    80006de4:	00e78f23          	sb	a4,30(a5)
    80006de8:	00e78fa3          	sb	a4,31(a5)
}
    80006dec:	60e2                	ld	ra,24(sp)
    80006dee:	6442                	ld	s0,16(sp)
    80006df0:	64a2                	ld	s1,8(sp)
    80006df2:	6105                	addi	sp,sp,32
    80006df4:	8082                	ret
    panic("could not find virtio disk");
    80006df6:	00003517          	auipc	a0,0x3
    80006dfa:	ba250513          	addi	a0,a0,-1118 # 80009998 <syscalls+0x3d0>
    80006dfe:	ffff9097          	auipc	ra,0xffff9
    80006e02:	72c080e7          	jalr	1836(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006e06:	00003517          	auipc	a0,0x3
    80006e0a:	bb250513          	addi	a0,a0,-1102 # 800099b8 <syscalls+0x3f0>
    80006e0e:	ffff9097          	auipc	ra,0xffff9
    80006e12:	71c080e7          	jalr	1820(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006e16:	00003517          	auipc	a0,0x3
    80006e1a:	bc250513          	addi	a0,a0,-1086 # 800099d8 <syscalls+0x410>
    80006e1e:	ffff9097          	auipc	ra,0xffff9
    80006e22:	70c080e7          	jalr	1804(ra) # 8000052a <panic>

0000000080006e26 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006e26:	7119                	addi	sp,sp,-128
    80006e28:	fc86                	sd	ra,120(sp)
    80006e2a:	f8a2                	sd	s0,112(sp)
    80006e2c:	f4a6                	sd	s1,104(sp)
    80006e2e:	f0ca                	sd	s2,96(sp)
    80006e30:	ecce                	sd	s3,88(sp)
    80006e32:	e8d2                	sd	s4,80(sp)
    80006e34:	e4d6                	sd	s5,72(sp)
    80006e36:	e0da                	sd	s6,64(sp)
    80006e38:	fc5e                	sd	s7,56(sp)
    80006e3a:	f862                	sd	s8,48(sp)
    80006e3c:	f466                	sd	s9,40(sp)
    80006e3e:	f06a                	sd	s10,32(sp)
    80006e40:	ec6e                	sd	s11,24(sp)
    80006e42:	0100                	addi	s0,sp,128
    80006e44:	8aaa                	mv	s5,a0
    80006e46:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006e48:	00c52c83          	lw	s9,12(a0)
    80006e4c:	001c9c9b          	slliw	s9,s9,0x1
    80006e50:	1c82                	slli	s9,s9,0x20
    80006e52:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006e56:	0003d517          	auipc	a0,0x3d
    80006e5a:	2d250513          	addi	a0,a0,722 # 80044128 <disk+0x2128>
    80006e5e:	ffffa097          	auipc	ra,0xffffa
    80006e62:	d64080e7          	jalr	-668(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006e66:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006e68:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006e6a:	0003bc17          	auipc	s8,0x3b
    80006e6e:	196c0c13          	addi	s8,s8,406 # 80042000 <disk>
    80006e72:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006e74:	4b0d                	li	s6,3
    80006e76:	a0ad                	j	80006ee0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006e78:	00fc0733          	add	a4,s8,a5
    80006e7c:	975e                	add	a4,a4,s7
    80006e7e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006e82:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006e84:	0207c563          	bltz	a5,80006eae <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006e88:	2905                	addiw	s2,s2,1
    80006e8a:	0611                	addi	a2,a2,4
    80006e8c:	19690d63          	beq	s2,s6,80007026 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006e90:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006e92:	0003d717          	auipc	a4,0x3d
    80006e96:	18670713          	addi	a4,a4,390 # 80044018 <disk+0x2018>
    80006e9a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006e9c:	00074683          	lbu	a3,0(a4)
    80006ea0:	fee1                	bnez	a3,80006e78 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006ea2:	2785                	addiw	a5,a5,1
    80006ea4:	0705                	addi	a4,a4,1
    80006ea6:	fe979be3          	bne	a5,s1,80006e9c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006eaa:	57fd                	li	a5,-1
    80006eac:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006eae:	01205d63          	blez	s2,80006ec8 <virtio_disk_rw+0xa2>
    80006eb2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006eb4:	000a2503          	lw	a0,0(s4)
    80006eb8:	00000097          	auipc	ra,0x0
    80006ebc:	d8e080e7          	jalr	-626(ra) # 80006c46 <free_desc>
      for(int j = 0; j < i; j++)
    80006ec0:	2d85                	addiw	s11,s11,1
    80006ec2:	0a11                	addi	s4,s4,4
    80006ec4:	ffb918e3          	bne	s2,s11,80006eb4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006ec8:	0003d597          	auipc	a1,0x3d
    80006ecc:	26058593          	addi	a1,a1,608 # 80044128 <disk+0x2128>
    80006ed0:	0003d517          	auipc	a0,0x3d
    80006ed4:	14850513          	addi	a0,a0,328 # 80044018 <disk+0x2018>
    80006ed8:	ffffb097          	auipc	ra,0xffffb
    80006edc:	54e080e7          	jalr	1358(ra) # 80002426 <sleep>
  for(int i = 0; i < 3; i++){
    80006ee0:	f8040a13          	addi	s4,s0,-128
{
    80006ee4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006ee6:	894e                	mv	s2,s3
    80006ee8:	b765                	j	80006e90 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006eea:	0003d697          	auipc	a3,0x3d
    80006eee:	1166b683          	ld	a3,278(a3) # 80044000 <disk+0x2000>
    80006ef2:	96ba                	add	a3,a3,a4
    80006ef4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006ef8:	0003b817          	auipc	a6,0x3b
    80006efc:	10880813          	addi	a6,a6,264 # 80042000 <disk>
    80006f00:	0003d697          	auipc	a3,0x3d
    80006f04:	10068693          	addi	a3,a3,256 # 80044000 <disk+0x2000>
    80006f08:	6290                	ld	a2,0(a3)
    80006f0a:	963a                	add	a2,a2,a4
    80006f0c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006f10:	0015e593          	ori	a1,a1,1
    80006f14:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006f18:	f8842603          	lw	a2,-120(s0)
    80006f1c:	628c                	ld	a1,0(a3)
    80006f1e:	972e                	add	a4,a4,a1
    80006f20:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006f24:	20050593          	addi	a1,a0,512
    80006f28:	0592                	slli	a1,a1,0x4
    80006f2a:	95c2                	add	a1,a1,a6
    80006f2c:	577d                	li	a4,-1
    80006f2e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006f32:	00461713          	slli	a4,a2,0x4
    80006f36:	6290                	ld	a2,0(a3)
    80006f38:	963a                	add	a2,a2,a4
    80006f3a:	03078793          	addi	a5,a5,48
    80006f3e:	97c2                	add	a5,a5,a6
    80006f40:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006f42:	629c                	ld	a5,0(a3)
    80006f44:	97ba                	add	a5,a5,a4
    80006f46:	4605                	li	a2,1
    80006f48:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006f4a:	629c                	ld	a5,0(a3)
    80006f4c:	97ba                	add	a5,a5,a4
    80006f4e:	4809                	li	a6,2
    80006f50:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006f54:	629c                	ld	a5,0(a3)
    80006f56:	973e                	add	a4,a4,a5
    80006f58:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006f5c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006f60:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006f64:	6698                	ld	a4,8(a3)
    80006f66:	00275783          	lhu	a5,2(a4)
    80006f6a:	8b9d                	andi	a5,a5,7
    80006f6c:	0786                	slli	a5,a5,0x1
    80006f6e:	97ba                	add	a5,a5,a4
    80006f70:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006f74:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006f78:	6698                	ld	a4,8(a3)
    80006f7a:	00275783          	lhu	a5,2(a4)
    80006f7e:	2785                	addiw	a5,a5,1
    80006f80:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006f84:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006f88:	100017b7          	lui	a5,0x10001
    80006f8c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006f90:	004aa783          	lw	a5,4(s5)
    80006f94:	02c79163          	bne	a5,a2,80006fb6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006f98:	0003d917          	auipc	s2,0x3d
    80006f9c:	19090913          	addi	s2,s2,400 # 80044128 <disk+0x2128>
  while(b->disk == 1) {
    80006fa0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006fa2:	85ca                	mv	a1,s2
    80006fa4:	8556                	mv	a0,s5
    80006fa6:	ffffb097          	auipc	ra,0xffffb
    80006faa:	480080e7          	jalr	1152(ra) # 80002426 <sleep>
  while(b->disk == 1) {
    80006fae:	004aa783          	lw	a5,4(s5)
    80006fb2:	fe9788e3          	beq	a5,s1,80006fa2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006fb6:	f8042903          	lw	s2,-128(s0)
    80006fba:	20090793          	addi	a5,s2,512
    80006fbe:	00479713          	slli	a4,a5,0x4
    80006fc2:	0003b797          	auipc	a5,0x3b
    80006fc6:	03e78793          	addi	a5,a5,62 # 80042000 <disk>
    80006fca:	97ba                	add	a5,a5,a4
    80006fcc:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006fd0:	0003d997          	auipc	s3,0x3d
    80006fd4:	03098993          	addi	s3,s3,48 # 80044000 <disk+0x2000>
    80006fd8:	00491713          	slli	a4,s2,0x4
    80006fdc:	0009b783          	ld	a5,0(s3)
    80006fe0:	97ba                	add	a5,a5,a4
    80006fe2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006fe6:	854a                	mv	a0,s2
    80006fe8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006fec:	00000097          	auipc	ra,0x0
    80006ff0:	c5a080e7          	jalr	-934(ra) # 80006c46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006ff4:	8885                	andi	s1,s1,1
    80006ff6:	f0ed                	bnez	s1,80006fd8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006ff8:	0003d517          	auipc	a0,0x3d
    80006ffc:	13050513          	addi	a0,a0,304 # 80044128 <disk+0x2128>
    80007000:	ffffa097          	auipc	ra,0xffffa
    80007004:	c76080e7          	jalr	-906(ra) # 80000c76 <release>
}
    80007008:	70e6                	ld	ra,120(sp)
    8000700a:	7446                	ld	s0,112(sp)
    8000700c:	74a6                	ld	s1,104(sp)
    8000700e:	7906                	ld	s2,96(sp)
    80007010:	69e6                	ld	s3,88(sp)
    80007012:	6a46                	ld	s4,80(sp)
    80007014:	6aa6                	ld	s5,72(sp)
    80007016:	6b06                	ld	s6,64(sp)
    80007018:	7be2                	ld	s7,56(sp)
    8000701a:	7c42                	ld	s8,48(sp)
    8000701c:	7ca2                	ld	s9,40(sp)
    8000701e:	7d02                	ld	s10,32(sp)
    80007020:	6de2                	ld	s11,24(sp)
    80007022:	6109                	addi	sp,sp,128
    80007024:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007026:	f8042503          	lw	a0,-128(s0)
    8000702a:	20050793          	addi	a5,a0,512
    8000702e:	0792                	slli	a5,a5,0x4
  if(write)
    80007030:	0003b817          	auipc	a6,0x3b
    80007034:	fd080813          	addi	a6,a6,-48 # 80042000 <disk>
    80007038:	00f80733          	add	a4,a6,a5
    8000703c:	01a036b3          	snez	a3,s10
    80007040:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007044:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007048:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000704c:	7679                	lui	a2,0xffffe
    8000704e:	963e                	add	a2,a2,a5
    80007050:	0003d697          	auipc	a3,0x3d
    80007054:	fb068693          	addi	a3,a3,-80 # 80044000 <disk+0x2000>
    80007058:	6298                	ld	a4,0(a3)
    8000705a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000705c:	0a878593          	addi	a1,a5,168
    80007060:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007062:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007064:	6298                	ld	a4,0(a3)
    80007066:	9732                	add	a4,a4,a2
    80007068:	45c1                	li	a1,16
    8000706a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000706c:	6298                	ld	a4,0(a3)
    8000706e:	9732                	add	a4,a4,a2
    80007070:	4585                	li	a1,1
    80007072:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007076:	f8442703          	lw	a4,-124(s0)
    8000707a:	628c                	ld	a1,0(a3)
    8000707c:	962e                	add	a2,a2,a1
    8000707e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffb900e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007082:	0712                	slli	a4,a4,0x4
    80007084:	6290                	ld	a2,0(a3)
    80007086:	963a                	add	a2,a2,a4
    80007088:	058a8593          	addi	a1,s5,88
    8000708c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000708e:	6294                	ld	a3,0(a3)
    80007090:	96ba                	add	a3,a3,a4
    80007092:	40000613          	li	a2,1024
    80007096:	c690                	sw	a2,8(a3)
  if(write)
    80007098:	e40d19e3          	bnez	s10,80006eea <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000709c:	0003d697          	auipc	a3,0x3d
    800070a0:	f646b683          	ld	a3,-156(a3) # 80044000 <disk+0x2000>
    800070a4:	96ba                	add	a3,a3,a4
    800070a6:	4609                	li	a2,2
    800070a8:	00c69623          	sh	a2,12(a3)
    800070ac:	b5b1                	j	80006ef8 <virtio_disk_rw+0xd2>

00000000800070ae <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800070ae:	1101                	addi	sp,sp,-32
    800070b0:	ec06                	sd	ra,24(sp)
    800070b2:	e822                	sd	s0,16(sp)
    800070b4:	e426                	sd	s1,8(sp)
    800070b6:	e04a                	sd	s2,0(sp)
    800070b8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800070ba:	0003d517          	auipc	a0,0x3d
    800070be:	06e50513          	addi	a0,a0,110 # 80044128 <disk+0x2128>
    800070c2:	ffffa097          	auipc	ra,0xffffa
    800070c6:	b00080e7          	jalr	-1280(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800070ca:	10001737          	lui	a4,0x10001
    800070ce:	533c                	lw	a5,96(a4)
    800070d0:	8b8d                	andi	a5,a5,3
    800070d2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800070d4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800070d8:	0003d797          	auipc	a5,0x3d
    800070dc:	f2878793          	addi	a5,a5,-216 # 80044000 <disk+0x2000>
    800070e0:	6b94                	ld	a3,16(a5)
    800070e2:	0207d703          	lhu	a4,32(a5)
    800070e6:	0026d783          	lhu	a5,2(a3)
    800070ea:	06f70163          	beq	a4,a5,8000714c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800070ee:	0003b917          	auipc	s2,0x3b
    800070f2:	f1290913          	addi	s2,s2,-238 # 80042000 <disk>
    800070f6:	0003d497          	auipc	s1,0x3d
    800070fa:	f0a48493          	addi	s1,s1,-246 # 80044000 <disk+0x2000>
    __sync_synchronize();
    800070fe:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007102:	6898                	ld	a4,16(s1)
    80007104:	0204d783          	lhu	a5,32(s1)
    80007108:	8b9d                	andi	a5,a5,7
    8000710a:	078e                	slli	a5,a5,0x3
    8000710c:	97ba                	add	a5,a5,a4
    8000710e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007110:	20078713          	addi	a4,a5,512
    80007114:	0712                	slli	a4,a4,0x4
    80007116:	974a                	add	a4,a4,s2
    80007118:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000711c:	e731                	bnez	a4,80007168 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000711e:	20078793          	addi	a5,a5,512
    80007122:	0792                	slli	a5,a5,0x4
    80007124:	97ca                	add	a5,a5,s2
    80007126:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007128:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000712c:	ffffb097          	auipc	ra,0xffffb
    80007130:	482080e7          	jalr	1154(ra) # 800025ae <wakeup>

    disk.used_idx += 1;
    80007134:	0204d783          	lhu	a5,32(s1)
    80007138:	2785                	addiw	a5,a5,1
    8000713a:	17c2                	slli	a5,a5,0x30
    8000713c:	93c1                	srli	a5,a5,0x30
    8000713e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007142:	6898                	ld	a4,16(s1)
    80007144:	00275703          	lhu	a4,2(a4)
    80007148:	faf71be3          	bne	a4,a5,800070fe <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000714c:	0003d517          	auipc	a0,0x3d
    80007150:	fdc50513          	addi	a0,a0,-36 # 80044128 <disk+0x2128>
    80007154:	ffffa097          	auipc	ra,0xffffa
    80007158:	b22080e7          	jalr	-1246(ra) # 80000c76 <release>
}
    8000715c:	60e2                	ld	ra,24(sp)
    8000715e:	6442                	ld	s0,16(sp)
    80007160:	64a2                	ld	s1,8(sp)
    80007162:	6902                	ld	s2,0(sp)
    80007164:	6105                	addi	sp,sp,32
    80007166:	8082                	ret
      panic("virtio_disk_intr status");
    80007168:	00003517          	auipc	a0,0x3
    8000716c:	89050513          	addi	a0,a0,-1904 # 800099f8 <syscalls+0x430>
    80007170:	ffff9097          	auipc	ra,0xffff9
    80007174:	3ba080e7          	jalr	954(ra) # 8000052a <panic>
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
