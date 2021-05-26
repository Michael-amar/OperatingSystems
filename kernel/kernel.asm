
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
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
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
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
    80000064:	00006797          	auipc	a5,0x6
    80000068:	6dc78793          	addi	a5,a5,1756 # 80006740 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc87ff>
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
    8000011e:	00003097          	auipc	ra,0x3
    80000122:	918080e7          	jalr	-1768(ra) # 80002a36 <either_copyin>
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
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00011917          	auipc	s2,0x11
    80000198:	08490913          	addi	s2,s2,132 # 80011218 <cons+0x98>
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
    800001b6:	cb4080e7          	jalr	-844(ra) # 80001e66 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	45a080e7          	jalr	1114(ra) # 8000261c <sleep>
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
    80000202:	7e2080e7          	jalr	2018(ra) # 800029e0 <either_copyout>
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
    80000212:	00011517          	auipc	a0,0x11
    80000216:	f6e50513          	addi	a0,a0,-146 # 80011180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
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
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
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
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ec850513          	addi	a0,a0,-312 # 80011180 <cons>
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
    800002e2:	7ae080e7          	jalr	1966(ra) # 80002a8c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
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
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	e7670713          	addi	a4,a4,-394 # 80011180 <cons>
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
    80000334:	00011797          	auipc	a5,0x11
    80000338:	e4c78793          	addi	a5,a5,-436 # 80011180 <cons>
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
    80000362:	00011797          	auipc	a5,0x11
    80000366:	eb67a783          	lw	a5,-330(a5) # 80011218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00011717          	auipc	a4,0x11
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80011180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00011497          	auipc	s1,0x11
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80011180 <cons>
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
    800003c2:	00011717          	auipc	a4,0x11
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80011180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00011717          	auipc	a4,0x11
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80011220 <cons+0xa0>
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
    800003fe:	00011797          	auipc	a5,0x11
    80000402:	d8278793          	addi	a5,a5,-638 # 80011180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00011517          	auipc	a0,0x11
    8000042e:	dee50513          	addi	a0,a0,-530 # 80011218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	376080e7          	jalr	886(ra) # 800027a8 <wakeup>
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
    80000444:	00008597          	auipc	a1,0x8
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80008010 <etext+0x10>
    8000044c:	00011517          	auipc	a0,0x11
    80000450:	d3450513          	addi	a0,a0,-716 # 80011180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00031797          	auipc	a5,0x31
    80000468:	0b478793          	addi	a5,a5,180 # 80031518 <devsw>
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
    800004a6:	00008617          	auipc	a2,0x8
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80008040 <digits>
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
    80000536:	00011797          	auipc	a5,0x11
    8000053a:	d007a523          	sw	zero,-758(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000053e:	00008517          	auipc	a0,0x8
    80000542:	ada50513          	addi	a0,a0,-1318 # 80008018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	c4850513          	addi	a0,a0,-952 # 800081a0 <digits+0x160>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	00009717          	auipc	a4,0x9
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 80009000 <panicked>
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
    800005a6:	00011d97          	auipc	s11,0x11
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80011240 <pr+0x18>
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
    800005d2:	00008b17          	auipc	s6,0x8
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80008040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00011517          	auipc	a0,0x11
    800005e8:	c4450513          	addi	a0,a0,-956 # 80011228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00008517          	auipc	a0,0x8
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80008028 <etext+0x28>
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
    800006f0:	00008497          	auipc	s1,0x8
    800006f4:	93048493          	addi	s1,s1,-1744 # 80008020 <etext+0x20>
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
    80000742:	00011517          	auipc	a0,0x11
    80000746:	ae650513          	addi	a0,a0,-1306 # 80011228 <pr>
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
    8000075e:	00011497          	auipc	s1,0x11
    80000762:	aca48493          	addi	s1,s1,-1334 # 80011228 <pr>
    80000766:	00008597          	auipc	a1,0x8
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80008038 <etext+0x38>
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
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80008058 <digits+0x18>
    800007be:	00011517          	auipc	a0,0x11
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80011248 <uart_tx_lock>
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
    800007ea:	00009797          	auipc	a5,0x9
    800007ee:	8167a783          	lw	a5,-2026(a5) # 80009000 <panicked>
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
    80000822:	00008797          	auipc	a5,0x8
    80000826:	7e67b783          	ld	a5,2022(a5) # 80009008 <uart_tx_r>
    8000082a:	00008717          	auipc	a4,0x8
    8000082e:	7e673703          	ld	a4,2022(a4) # 80009010 <uart_tx_w>
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
    8000084c:	00011a17          	auipc	s4,0x11
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00008497          	auipc	s1,0x8
    80000858:	7b448493          	addi	s1,s1,1972 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00008997          	auipc	s3,0x8
    80000860:	7b498993          	addi	s3,s3,1972 # 80009010 <uart_tx_w>
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
    80000882:	f2a080e7          	jalr	-214(ra) # 800027a8 <wakeup>
    
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
    800008ba:	00011517          	auipc	a0,0x11
    800008be:	98e50513          	addi	a0,a0,-1650 # 80011248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00008797          	auipc	a5,0x8
    800008ce:	7367a783          	lw	a5,1846(a5) # 80009000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00008717          	auipc	a4,0x8
    800008da:	73a73703          	ld	a4,1850(a4) # 80009010 <uart_tx_w>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72a7b783          	ld	a5,1834(a5) # 80009008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00011997          	auipc	s3,0x11
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80011248 <uart_tx_lock>
    800008f6:	00008497          	auipc	s1,0x8
    800008fa:	71248493          	addi	s1,s1,1810 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00008917          	auipc	s2,0x8
    80000902:	71290913          	addi	s2,s2,1810 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	d12080e7          	jalr	-750(ra) # 8000261c <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00011497          	auipc	s1,0x11
    80000924:	92848493          	addi	s1,s1,-1752 # 80011248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6ce7be23          	sd	a4,1756(a5) # 80009010 <uart_tx_w>
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
    800009a8:	00011497          	auipc	s1,0x11
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80011248 <uart_tx_lock>
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
    800009ea:	00035797          	auipc	a5,0x35
    800009ee:	61678793          	addi	a5,a5,1558 # 80036000 <end>
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
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
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
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
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
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80008068 <digits+0x28>
    80000aa6:	00010517          	auipc	a0,0x10
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80011280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00035517          	auipc	a0,0x35
    80000abe:	54650513          	addi	a0,a0,1350 # 80036000 <end>
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
    80000adc:	00010497          	auipc	s1,0x10
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80011280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00010517          	auipc	a0,0x10
    80000af8:	78c50513          	addi	a0,a0,1932 # 80011280 <kmem>
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
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	76050513          	addi	a0,a0,1888 # 80011280 <kmem>
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
    80000b60:	2ee080e7          	jalr	750(ra) # 80001e4a <mycpu>
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
    80000b92:	2bc080e7          	jalr	700(ra) # 80001e4a <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	2b0080e7          	jalr	688(ra) # 80001e4a <mycpu>
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
    80000bb6:	298080e7          	jalr	664(ra) # 80001e4a <mycpu>
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
    80000bf6:	258080e7          	jalr	600(ra) # 80001e4a <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80008070 <digits+0x30>
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
    80000c22:	22c080e7          	jalr	556(ra) # 80001e4a <mycpu>
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
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	42250513          	addi	a0,a0,1058 # 80008078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80008090 <digits+0x50>
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
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80008098 <digits+0x58>
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
    80000e78:	fc6080e7          	jalr	-58(ra) # 80001e3a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00008717          	auipc	a4,0x8
    80000e80:	19c70713          	addi	a4,a4,412 # 80009018 <started>
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
    80000e94:	faa080e7          	jalr	-86(ra) # 80001e3a <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00007517          	auipc	a0,0x7
    80000e9e:	21e50513          	addi	a0,a0,542 # 800080b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	d1c080e7          	jalr	-740(ra) # 80002bce <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	8c6080e7          	jalr	-1850(ra) # 80006780 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	5a8080e7          	jalr	1448(ra) # 8000246a <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	2c650513          	addi	a0,a0,710 # 800081a0 <digits+0x160>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	2a650513          	addi	a0,a0,678 # 800081a0 <digits+0x160>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	e68080e7          	jalr	-408(ra) # 80001d8a <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	c7c080e7          	jalr	-900(ra) # 80002ba6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	c9c080e7          	jalr	-868(ra) # 80002bce <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	830080e7          	jalr	-2000(ra) # 8000676a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	83e080e7          	jalr	-1986(ra) # 80006780 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	498080e7          	jalr	1176(ra) # 800033e2 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	b2a080e7          	jalr	-1238(ra) # 80003a7c <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	e20080e7          	jalr	-480(ra) # 80004d7a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	940080e7          	jalr	-1728(ra) # 800068a2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	22c080e7          	jalr	556(ra) # 80002196 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00008717          	auipc	a4,0x8
    80000f7c:	0af72023          	sw	a5,160(a4) # 80009018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00008797          	auipc	a5,0x8
    80000f8c:	0987b783          	ld	a5,152(a5) # 80009020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00007517          	auipc	a0,0x7
    80000fd0:	10450513          	addi	a0,a0,260 # 800080d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;  
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00007517          	auipc	a0,0x7
    80001140:	fa450513          	addi	a0,a0,-92 # 800080e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00007917          	auipc	s2,0x7
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80008000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80007697          	auipc	a3,0x80007
    800011c0:	e4468693          	addi	a3,a3,-444 # 8000 <_entry-0x7fff8000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00006617          	auipc	a2,0x6
    800011f4:	e1060613          	addi	a2,a2,-496 # 80007000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00001097          	auipc	ra,0x1
    80001210:	ae8080e7          	jalr	-1304(ra) # 80001cf4 <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00008797          	auipc	a5,0x8
    80001236:	dea7b723          	sd	a0,-530(a5) # 80009020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001242:	1101                	addi	sp,sp,-32
    80001244:	ec06                	sd	ra,24(sp)
    80001246:	e822                	sd	s0,16(sp)
    80001248:	e426                	sd	s1,8(sp)
    8000124a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	886080e7          	jalr	-1914(ra) # 80000ad2 <kalloc>
    80001254:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001256:	c519                	beqz	a0,80001264 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001258:	6605                	lui	a2,0x1
    8000125a:	4581                	li	a1,0
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	a62080e7          	jalr	-1438(ra) # 80000cbe <memset>
  return pagetable;
}
    80001264:	8526                	mv	a0,s1
    80001266:	60e2                	ld	ra,24(sp)
    80001268:	6442                	ld	s0,16(sp)
    8000126a:	64a2                	ld	s1,8(sp)
    8000126c:	6105                	addi	sp,sp,32
    8000126e:	8082                	ret

0000000080001270 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001270:	7179                	addi	sp,sp,-48
    80001272:	f406                	sd	ra,40(sp)
    80001274:	f022                	sd	s0,32(sp)
    80001276:	ec26                	sd	s1,24(sp)
    80001278:	e84a                	sd	s2,16(sp)
    8000127a:	e44e                	sd	s3,8(sp)
    8000127c:	e052                	sd	s4,0(sp)
    8000127e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001280:	6785                	lui	a5,0x1
    80001282:	04f67863          	bgeu	a2,a5,800012d2 <uvminit+0x62>
    80001286:	8a2a                	mv	s4,a0
    80001288:	89ae                	mv	s3,a1
    8000128a:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	846080e7          	jalr	-1978(ra) # 80000ad2 <kalloc>
    80001294:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001296:	6605                	lui	a2,0x1
    80001298:	4581                	li	a1,0
    8000129a:	00000097          	auipc	ra,0x0
    8000129e:	a24080e7          	jalr	-1500(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012a2:	4779                	li	a4,30
    800012a4:	86ca                	mv	a3,s2
    800012a6:	6605                	lui	a2,0x1
    800012a8:	4581                	li	a1,0
    800012aa:	8552                	mv	a0,s4
    800012ac:	00000097          	auipc	ra,0x0
    800012b0:	de2080e7          	jalr	-542(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    800012b4:	8626                	mv	a2,s1
    800012b6:	85ce                	mv	a1,s3
    800012b8:	854a                	mv	a0,s2
    800012ba:	00000097          	auipc	ra,0x0
    800012be:	a60080e7          	jalr	-1440(ra) # 80000d1a <memmove>
}
    800012c2:	70a2                	ld	ra,40(sp)
    800012c4:	7402                	ld	s0,32(sp)
    800012c6:	64e2                	ld	s1,24(sp)
    800012c8:	6942                	ld	s2,16(sp)
    800012ca:	69a2                	ld	s3,8(sp)
    800012cc:	6a02                	ld	s4,0(sp)
    800012ce:	6145                	addi	sp,sp,48
    800012d0:	8082                	ret
    panic("inituvm: more than a page");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e1650513          	addi	a0,a0,-490 # 800080e8 <digits+0xa8>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	250080e7          	jalr	592(ra) # 8000052a <panic>

00000000800012e2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012e2:	7179                	addi	sp,sp,-48
    800012e4:	f406                	sd	ra,40(sp)
    800012e6:	f022                	sd	s0,32(sp)
    800012e8:	ec26                	sd	s1,24(sp)
    800012ea:	e84a                	sd	s2,16(sp)
    800012ec:	e44e                	sd	s3,8(sp)
    800012ee:	e052                	sd	s4,0(sp)
    800012f0:	1800                	addi	s0,sp,48
    800012f2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800012f4:	84aa                	mv	s1,a0
    800012f6:	6905                	lui	s2,0x1
    800012f8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012fa:	4985                	li	s3,1
    800012fc:	a821                	j	80001314 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012fe:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001300:	0532                	slli	a0,a0,0xc
    80001302:	00000097          	auipc	ra,0x0
    80001306:	fe0080e7          	jalr	-32(ra) # 800012e2 <freewalk>
      pagetable[i] = 0;
    8000130a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000130e:	04a1                	addi	s1,s1,8
    80001310:	03248163          	beq	s1,s2,80001332 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001314:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001316:	00f57793          	andi	a5,a0,15
    8000131a:	ff3782e3          	beq	a5,s3,800012fe <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000131e:	8905                	andi	a0,a0,1
    80001320:	d57d                	beqz	a0,8000130e <freewalk+0x2c>
      panic("freewalk: leaf");
    80001322:	00007517          	auipc	a0,0x7
    80001326:	de650513          	addi	a0,a0,-538 # 80008108 <digits+0xc8>
    8000132a:	fffff097          	auipc	ra,0xfffff
    8000132e:	200080e7          	jalr	512(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    80001332:	8552                	mv	a0,s4
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	6a2080e7          	jalr	1698(ra) # 800009d6 <kfree>
}
    8000133c:	70a2                	ld	ra,40(sp)
    8000133e:	7402                	ld	s0,32(sp)
    80001340:	64e2                	ld	s1,24(sp)
    80001342:	6942                	ld	s2,16(sp)
    80001344:	69a2                	ld	s3,8(sp)
    80001346:	6a02                	ld	s4,0(sp)
    80001348:	6145                	addi	sp,sp,48
    8000134a:	8082                	ret

000000008000134c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000134c:	1141                	addi	sp,sp,-16
    8000134e:	e406                	sd	ra,8(sp)
    80001350:	e022                	sd	s0,0(sp)
    80001352:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001354:	4601                	li	a2,0
    80001356:	00000097          	auipc	ra,0x0
    8000135a:	c50080e7          	jalr	-944(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000135e:	c901                	beqz	a0,8000136e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001360:	611c                	ld	a5,0(a0)
    80001362:	9bbd                	andi	a5,a5,-17
    80001364:	e11c                	sd	a5,0(a0)
}
    80001366:	60a2                	ld	ra,8(sp)
    80001368:	6402                	ld	s0,0(sp)
    8000136a:	0141                	addi	sp,sp,16
    8000136c:	8082                	ret
    panic("uvmclear");
    8000136e:	00007517          	auipc	a0,0x7
    80001372:	daa50513          	addi	a0,a0,-598 # 80008118 <digits+0xd8>
    80001376:	fffff097          	auipc	ra,0xfffff
    8000137a:	1b4080e7          	jalr	436(ra) # 8000052a <panic>

000000008000137e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000137e:	c6bd                	beqz	a3,800013ec <copyout+0x6e>
{
    80001380:	715d                	addi	sp,sp,-80
    80001382:	e486                	sd	ra,72(sp)
    80001384:	e0a2                	sd	s0,64(sp)
    80001386:	fc26                	sd	s1,56(sp)
    80001388:	f84a                	sd	s2,48(sp)
    8000138a:	f44e                	sd	s3,40(sp)
    8000138c:	f052                	sd	s4,32(sp)
    8000138e:	ec56                	sd	s5,24(sp)
    80001390:	e85a                	sd	s6,16(sp)
    80001392:	e45e                	sd	s7,8(sp)
    80001394:	e062                	sd	s8,0(sp)
    80001396:	0880                	addi	s0,sp,80
    80001398:	8b2a                	mv	s6,a0
    8000139a:	8c2e                	mv	s8,a1
    8000139c:	8a32                	mv	s4,a2
    8000139e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800013a0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800013a2:	6a85                	lui	s5,0x1
    800013a4:	a015                	j	800013c8 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800013a6:	9562                	add	a0,a0,s8
    800013a8:	0004861b          	sext.w	a2,s1
    800013ac:	85d2                	mv	a1,s4
    800013ae:	41250533          	sub	a0,a0,s2
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	968080e7          	jalr	-1688(ra) # 80000d1a <memmove>

    len -= n;
    800013ba:	409989b3          	sub	s3,s3,s1
    src += n;
    800013be:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800013c0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800013c4:	02098263          	beqz	s3,800013e8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800013c8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800013cc:	85ca                	mv	a1,s2
    800013ce:	855a                	mv	a0,s6
    800013d0:	00000097          	auipc	ra,0x0
    800013d4:	c7c080e7          	jalr	-900(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800013d8:	cd01                	beqz	a0,800013f0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800013da:	418904b3          	sub	s1,s2,s8
    800013de:	94d6                	add	s1,s1,s5
    if(n > len)
    800013e0:	fc99f3e3          	bgeu	s3,s1,800013a6 <copyout+0x28>
    800013e4:	84ce                	mv	s1,s3
    800013e6:	b7c1                	j	800013a6 <copyout+0x28>
  }
  return 0;
    800013e8:	4501                	li	a0,0
    800013ea:	a021                	j	800013f2 <copyout+0x74>
    800013ec:	4501                	li	a0,0
}
    800013ee:	8082                	ret
      return -1;
    800013f0:	557d                	li	a0,-1
}
    800013f2:	60a6                	ld	ra,72(sp)
    800013f4:	6406                	ld	s0,64(sp)
    800013f6:	74e2                	ld	s1,56(sp)
    800013f8:	7942                	ld	s2,48(sp)
    800013fa:	79a2                	ld	s3,40(sp)
    800013fc:	7a02                	ld	s4,32(sp)
    800013fe:	6ae2                	ld	s5,24(sp)
    80001400:	6b42                	ld	s6,16(sp)
    80001402:	6ba2                	ld	s7,8(sp)
    80001404:	6c02                	ld	s8,0(sp)
    80001406:	6161                	addi	sp,sp,80
    80001408:	8082                	ret

000000008000140a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000140a:	caa5                	beqz	a3,8000147a <copyin+0x70>
{
    8000140c:	715d                	addi	sp,sp,-80
    8000140e:	e486                	sd	ra,72(sp)
    80001410:	e0a2                	sd	s0,64(sp)
    80001412:	fc26                	sd	s1,56(sp)
    80001414:	f84a                	sd	s2,48(sp)
    80001416:	f44e                	sd	s3,40(sp)
    80001418:	f052                	sd	s4,32(sp)
    8000141a:	ec56                	sd	s5,24(sp)
    8000141c:	e85a                	sd	s6,16(sp)
    8000141e:	e45e                	sd	s7,8(sp)
    80001420:	e062                	sd	s8,0(sp)
    80001422:	0880                	addi	s0,sp,80
    80001424:	8b2a                	mv	s6,a0
    80001426:	8a2e                	mv	s4,a1
    80001428:	8c32                	mv	s8,a2
    8000142a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000142c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000142e:	6a85                	lui	s5,0x1
    80001430:	a01d                	j	80001456 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001432:	018505b3          	add	a1,a0,s8
    80001436:	0004861b          	sext.w	a2,s1
    8000143a:	412585b3          	sub	a1,a1,s2
    8000143e:	8552                	mv	a0,s4
    80001440:	00000097          	auipc	ra,0x0
    80001444:	8da080e7          	jalr	-1830(ra) # 80000d1a <memmove>

    len -= n;
    80001448:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000144c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000144e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001452:	02098263          	beqz	s3,80001476 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001456:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000145a:	85ca                	mv	a1,s2
    8000145c:	855a                	mv	a0,s6
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	bee080e7          	jalr	-1042(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001466:	cd01                	beqz	a0,8000147e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001468:	418904b3          	sub	s1,s2,s8
    8000146c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000146e:	fc99f2e3          	bgeu	s3,s1,80001432 <copyin+0x28>
    80001472:	84ce                	mv	s1,s3
    80001474:	bf7d                	j	80001432 <copyin+0x28>
  }
  return 0;
    80001476:	4501                	li	a0,0
    80001478:	a021                	j	80001480 <copyin+0x76>
    8000147a:	4501                	li	a0,0
}
    8000147c:	8082                	ret
      return -1;
    8000147e:	557d                	li	a0,-1
}
    80001480:	60a6                	ld	ra,72(sp)
    80001482:	6406                	ld	s0,64(sp)
    80001484:	74e2                	ld	s1,56(sp)
    80001486:	7942                	ld	s2,48(sp)
    80001488:	79a2                	ld	s3,40(sp)
    8000148a:	7a02                	ld	s4,32(sp)
    8000148c:	6ae2                	ld	s5,24(sp)
    8000148e:	6b42                	ld	s6,16(sp)
    80001490:	6ba2                	ld	s7,8(sp)
    80001492:	6c02                	ld	s8,0(sp)
    80001494:	6161                	addi	sp,sp,80
    80001496:	8082                	ret

0000000080001498 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001498:	c6c5                	beqz	a3,80001540 <copyinstr+0xa8>
{
    8000149a:	715d                	addi	sp,sp,-80
    8000149c:	e486                	sd	ra,72(sp)
    8000149e:	e0a2                	sd	s0,64(sp)
    800014a0:	fc26                	sd	s1,56(sp)
    800014a2:	f84a                	sd	s2,48(sp)
    800014a4:	f44e                	sd	s3,40(sp)
    800014a6:	f052                	sd	s4,32(sp)
    800014a8:	ec56                	sd	s5,24(sp)
    800014aa:	e85a                	sd	s6,16(sp)
    800014ac:	e45e                	sd	s7,8(sp)
    800014ae:	0880                	addi	s0,sp,80
    800014b0:	8a2a                	mv	s4,a0
    800014b2:	8b2e                	mv	s6,a1
    800014b4:	8bb2                	mv	s7,a2
    800014b6:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800014b8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014ba:	6985                	lui	s3,0x1
    800014bc:	a035                	j	800014e8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014be:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014c2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014c4:	0017b793          	seqz	a5,a5
    800014c8:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014cc:	60a6                	ld	ra,72(sp)
    800014ce:	6406                	ld	s0,64(sp)
    800014d0:	74e2                	ld	s1,56(sp)
    800014d2:	7942                	ld	s2,48(sp)
    800014d4:	79a2                	ld	s3,40(sp)
    800014d6:	7a02                	ld	s4,32(sp)
    800014d8:	6ae2                	ld	s5,24(sp)
    800014da:	6b42                	ld	s6,16(sp)
    800014dc:	6ba2                	ld	s7,8(sp)
    800014de:	6161                	addi	sp,sp,80
    800014e0:	8082                	ret
    srcva = va0 + PGSIZE;
    800014e2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800014e6:	c8a9                	beqz	s1,80001538 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800014e8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8552                	mv	a0,s4
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	b5c080e7          	jalr	-1188(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800014f8:	c131                	beqz	a0,8000153c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800014fa:	41790833          	sub	a6,s2,s7
    800014fe:	984e                	add	a6,a6,s3
    if(n > max)
    80001500:	0104f363          	bgeu	s1,a6,80001506 <copyinstr+0x6e>
    80001504:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001506:	955e                	add	a0,a0,s7
    80001508:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000150c:	fc080be3          	beqz	a6,800014e2 <copyinstr+0x4a>
    80001510:	985a                	add	a6,a6,s6
    80001512:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001514:	41650633          	sub	a2,a0,s6
    80001518:	14fd                	addi	s1,s1,-1
    8000151a:	9b26                	add	s6,s6,s1
    8000151c:	00f60733          	add	a4,a2,a5
    80001520:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffc9000>
    80001524:	df49                	beqz	a4,800014be <copyinstr+0x26>
        *dst = *p;
    80001526:	00e78023          	sb	a4,0(a5)
      --max;
    8000152a:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000152e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001530:	ff0796e3          	bne	a5,a6,8000151c <copyinstr+0x84>
      dst++;
    80001534:	8b42                	mv	s6,a6
    80001536:	b775                	j	800014e2 <copyinstr+0x4a>
    80001538:	4781                	li	a5,0
    8000153a:	b769                	j	800014c4 <copyinstr+0x2c>
      return -1;
    8000153c:	557d                	li	a0,-1
    8000153e:	b779                	j	800014cc <copyinstr+0x34>
  int got_null = 0;
    80001540:	4781                	li	a5,0
  if(got_null){
    80001542:	0017b793          	seqz	a5,a5
    80001546:	40f00533          	neg	a0,a5
}
    8000154a:	8082                	ret

000000008000154c <countmemory>:

int countmemory(pagetable_t pagetable)
{
    8000154c:	7179                	addi	sp,sp,-48
    8000154e:	f406                	sd	ra,40(sp)
    80001550:	f022                	sd	s0,32(sp)
    80001552:	ec26                	sd	s1,24(sp)
    80001554:	e84a                	sd	s2,16(sp)
    80001556:	e44e                	sd	s3,8(sp)
    80001558:	e052                	sd	s4,0(sp)
    8000155a:	1800                	addi	s0,sp,48
    8000155c:	84aa                	mv	s1,a0
  int counter=0;
  for(int i = 0; i < 512; i++)
    8000155e:	6985                	lui	s3,0x1
    80001560:	99aa                	add	s3,s3,a0
  int counter=0;
    80001562:	4a01                	li	s4,0
  {
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001564:	4905                	li	s2,1
    80001566:	a821                	j	8000157e <countmemory+0x32>
      uint64 child = PTE2PA(pte);
    80001568:	8129                	srli	a0,a0,0xa
      counter += countmemory((pagetable_t)child);
    8000156a:	0532                	slli	a0,a0,0xc
    8000156c:	00000097          	auipc	ra,0x0
    80001570:	fe0080e7          	jalr	-32(ra) # 8000154c <countmemory>
    80001574:	01450a3b          	addw	s4,a0,s4
  for(int i = 0; i < 512; i++)
    80001578:	04a1                	addi	s1,s1,8
    8000157a:	01348d63          	beq	s1,s3,80001594 <countmemory+0x48>
    pte_t pte = pagetable[i];
    8000157e:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001580:	00f57793          	andi	a5,a0,15
    80001584:	ff2782e3          	beq	a5,s2,80001568 <countmemory+0x1c>
    } 
    else if((pte & PTE_V) && ((pte & PTE_PG) == 0))
    80001588:	20157513          	andi	a0,a0,513
    8000158c:	ff2516e3          	bne	a0,s2,80001578 <countmemory+0x2c>
    {
      counter++;
    80001590:	2a05                	addiw	s4,s4,1
    80001592:	b7dd                	j	80001578 <countmemory+0x2c>
    }
  }
  return counter;
}
    80001594:	8552                	mv	a0,s4
    80001596:	70a2                	ld	ra,40(sp)
    80001598:	7402                	ld	s0,32(sp)
    8000159a:	64e2                	ld	s1,24(sp)
    8000159c:	6942                	ld	s2,16(sp)
    8000159e:	69a2                	ld	s3,8(sp)
    800015a0:	6a02                	ld	s4,0(sp)
    800015a2:	6145                	addi	sp,sp,48
    800015a4:	8082                	ret

00000000800015a6 <counttotal>:

int counttotal(pagetable_t pagetable)
{
    800015a6:	7179                	addi	sp,sp,-48
    800015a8:	f406                	sd	ra,40(sp)
    800015aa:	f022                	sd	s0,32(sp)
    800015ac:	ec26                	sd	s1,24(sp)
    800015ae:	e84a                	sd	s2,16(sp)
    800015b0:	e44e                	sd	s3,8(sp)
    800015b2:	e052                	sd	s4,0(sp)
    800015b4:	1800                	addi	s0,sp,48
    800015b6:	84aa                	mv	s1,a0
  int counter=0;
  for(int i = 0; i < 512; i++)
    800015b8:	6985                	lui	s3,0x1
    800015ba:	99aa                	add	s3,s3,a0
  int counter=0;
    800015bc:	4901                	li	s2,0
  {
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015be:	4a05                	li	s4,1
    800015c0:	a821                	j	800015d8 <counttotal+0x32>
      uint64 child = PTE2PA(pte);
    800015c2:	8129                	srli	a0,a0,0xa
      counter += counttotal((pagetable_t)child);
    800015c4:	0532                	slli	a0,a0,0xc
    800015c6:	00000097          	auipc	ra,0x0
    800015ca:	fe0080e7          	jalr	-32(ra) # 800015a6 <counttotal>
    800015ce:	0125093b          	addw	s2,a0,s2
  for(int i = 0; i < 512; i++)
    800015d2:	04a1                	addi	s1,s1,8
    800015d4:	01348c63          	beq	s1,s3,800015ec <counttotal+0x46>
    pte_t pte = pagetable[i];
    800015d8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015da:	00f57793          	andi	a5,a0,15
    800015de:	ff4782e3          	beq	a5,s4,800015c2 <counttotal+0x1c>
    } 
    else if((pte & PTE_V) || (pte & PTE_PG))
    800015e2:	20157513          	andi	a0,a0,513
    800015e6:	d575                	beqz	a0,800015d2 <counttotal+0x2c>
    {
      counter++;
    800015e8:	2905                	addiw	s2,s2,1
    800015ea:	b7e5                	j	800015d2 <counttotal+0x2c>
    }
  }
  return counter;
}
    800015ec:	854a                	mv	a0,s2
    800015ee:	70a2                	ld	ra,40(sp)
    800015f0:	7402                	ld	s0,32(sp)
    800015f2:	64e2                	ld	s1,24(sp)
    800015f4:	6942                	ld	s2,16(sp)
    800015f6:	69a2                	ld	s3,8(sp)
    800015f8:	6a02                	ld	s4,0(sp)
    800015fa:	6145                	addi	sp,sp,48
    800015fc:	8082                	ret

00000000800015fe <get_offset>:

// returns free offset in swapFile that can be written 
uint get_offset()
{   
    800015fe:	1141                	addi	sp,sp,-16
    80001600:	e406                	sd	ra,8(sp)
    80001602:	e022                	sd	s0,0(sp)
    80001604:	0800                	addi	s0,sp,16
  struct proc* p = myproc();
    80001606:	00001097          	auipc	ra,0x1
    8000160a:	860080e7          	jalr	-1952(ra) # 80001e66 <myproc>
    8000160e:	85aa                	mv	a1,a0
  for (uint offset = 0 ; offset < MAX_PSYC_PAGES* PGSIZE ; offset+= PGSIZE)
    80001610:	4501                	li	a0,0
    80001612:	57058613          	addi	a2,a1,1392 # 4000570 <_entry-0x7bfffa90>
    80001616:	6885                	lui	a7,0x1
    80001618:	6841                	lui	a6,0x10
    8000161a:	a099                	j	80001660 <get_offset+0x62>
    {
      if(pg->on_disk) //if the page is on disk
        if (pg->offset == offset) // and its written in offset
          offset_taken = 1;
    }
    if (!offset_taken)
    8000161c:	ef15                	bnez	a4,80001658 <get_offset+0x5a>
      return offset;
  }
  panic("all offsets taken");
  return 0;
}
    8000161e:	60a2                	ld	ra,8(sp)
    80001620:	6402                	ld	s0,0(sp)
    80001622:	0141                	addi	sp,sp,16
    80001624:	8082                	ret
  panic("all offsets taken");
    80001626:	00007517          	auipc	a0,0x7
    8000162a:	b0250513          	addi	a0,a0,-1278 # 80008128 <digits+0xe8>
    8000162e:	fffff097          	auipc	ra,0xfffff
    80001632:	efc080e7          	jalr	-260(ra) # 8000052a <panic>
    for (struct page* pg = p->pages ; pg< &p->pages[MAX_TOTAL_PAGES] && !offset_taken; pg++)
    80001636:	02078793          	addi	a5,a5,32
    8000163a:	fef601e3          	beq	a2,a5,8000161c <get_offset+0x1e>
      if(pg->on_disk) //if the page is on disk
    8000163e:	4b98                	lw	a4,16(a5)
    80001640:	db7d                	beqz	a4,80001636 <get_offset+0x38>
        if (pg->offset == offset) // and its written in offset
    80001642:	4bd4                	lw	a3,20(a5)
    80001644:	40a68733          	sub	a4,a3,a0
    80001648:	00173713          	seqz	a4,a4
    for (struct page* pg = p->pages ; pg< &p->pages[MAX_TOTAL_PAGES] && !offset_taken; pg++)
    8000164c:	02078793          	addi	a5,a5,32
    80001650:	fcc786e3          	beq	a5,a2,8000161c <get_offset+0x1e>
    80001654:	fea695e3          	bne	a3,a0,8000163e <get_offset+0x40>
  for (uint offset = 0 ; offset < MAX_PSYC_PAGES* PGSIZE ; offset+= PGSIZE)
    80001658:	00a8853b          	addw	a0,a7,a0
    8000165c:	fd0505e3          	beq	a0,a6,80001626 <get_offset+0x28>
    for (struct page* pg = p->pages ; pg< &p->pages[MAX_TOTAL_PAGES] && !offset_taken; pg++)
    80001660:	17058793          	addi	a5,a1,368
    80001664:	bfe9                	j	8000163e <get_offset+0x40>

0000000080001666 <pick_page_to_swap>:
  // refresh TLB
  sfence_vma();
}

struct page* pick_page_to_swap(pagetable_t pagetable)
{
    80001666:	7179                	addi	sp,sp,-48
    80001668:	f406                	sd	ra,40(sp)
    8000166a:	f022                	sd	s0,32(sp)
    8000166c:	ec26                	sd	s1,24(sp)
    8000166e:	e84a                	sd	s2,16(sp)
    80001670:	e44e                	sd	s3,8(sp)
    80001672:	e052                	sd	s4,0(sp)
    80001674:	1800                	addi	s0,sp,48
    80001676:	8a2a                	mv	s4,a0
  struct proc* p = myproc();
    80001678:	00000097          	auipc	ra,0x0
    8000167c:	7ee080e7          	jalr	2030(ra) # 80001e66 <myproc>
  struct page* pg = p->pages;
    80001680:	17050493          	addi	s1,a0,368
  for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80001684:	57050913          	addi	s2,a0,1392
  {
    if (pg->used)
    {
      //printf("va %d\n", pg->va);  
      if (pg->va == 4096 || pg->va == 0)
    80001688:	79fd                	lui	s3,0xfffff
    8000168a:	19fd                	addi	s3,s3,-1
    8000168c:	a029                	j	80001696 <pick_page_to_swap+0x30>
  for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    8000168e:	02048493          	addi	s1,s1,32
    80001692:	05248063          	beq	s1,s2,800016d2 <pick_page_to_swap+0x6c>
    if (pg->used)
    80001696:	4c9c                	lw	a5,24(s1)
    80001698:	dbfd                	beqz	a5,8000168e <pick_page_to_swap+0x28>
      if (pg->va == 4096 || pg->va == 0)
    8000169a:	648c                	ld	a1,8(s1)
    8000169c:	0135f7b3          	and	a5,a1,s3
    800016a0:	d7fd                	beqz	a5,8000168e <pick_page_to_swap+0x28>
        continue; //we dont want to swap text page
      pte_t* pte = walk(pagetable, pg->va, 0);
    800016a2:	4601                	li	a2,0
    800016a4:	8552                	mv	a0,s4
    800016a6:	00000097          	auipc	ra,0x0
    800016aa:	900080e7          	jalr	-1792(ra) # 80000fa6 <walk>
      if ((*pte & PTE_V)) // if valid page
    800016ae:	611c                	ld	a5,0(a0)
    800016b0:	0017f713          	andi	a4,a5,1
    800016b4:	df69                	beqz	a4,8000168e <pick_page_to_swap+0x28>
      {
        if ((*pte & PTE_PG) == 0) // and page is not pages out
    800016b6:	2007f713          	andi	a4,a5,512
    800016ba:	fb71                	bnez	a4,8000168e <pick_page_to_swap+0x28>
        {
          if(*pte & PTE_U)  // and its a user page
    800016bc:	8bc1                	andi	a5,a5,16
    800016be:	dbe1                	beqz	a5,8000168e <pick_page_to_swap+0x28>
      }
    }
  }
  panic("no page returned");
  return 0;
}
    800016c0:	8526                	mv	a0,s1
    800016c2:	70a2                	ld	ra,40(sp)
    800016c4:	7402                	ld	s0,32(sp)
    800016c6:	64e2                	ld	s1,24(sp)
    800016c8:	6942                	ld	s2,16(sp)
    800016ca:	69a2                	ld	s3,8(sp)
    800016cc:	6a02                	ld	s4,0(sp)
    800016ce:	6145                	addi	sp,sp,48
    800016d0:	8082                	ret
  panic("no page returned");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	a6e50513          	addi	a0,a0,-1426 # 80008140 <digits+0x100>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e50080e7          	jalr	-432(ra) # 8000052a <panic>

00000000800016e2 <page_swap_out>:
{
    800016e2:	7139                	addi	sp,sp,-64
    800016e4:	fc06                	sd	ra,56(sp)
    800016e6:	f822                	sd	s0,48(sp)
    800016e8:	f426                	sd	s1,40(sp)
    800016ea:	f04a                	sd	s2,32(sp)
    800016ec:	ec4e                	sd	s3,24(sp)
    800016ee:	e852                	sd	s4,16(sp)
    800016f0:	e456                	sd	s5,8(sp)
    800016f2:	0080                	addi	s0,sp,64
    800016f4:	892a                	mv	s2,a0
  struct proc* p = myproc();
    800016f6:	00000097          	auipc	ra,0x0
    800016fa:	770080e7          	jalr	1904(ra) # 80001e66 <myproc>
    800016fe:	8aaa                	mv	s5,a0
  struct page* pg_to_swap = pick_page_to_swap(pagetable);
    80001700:	854a                	mv	a0,s2
    80001702:	00000097          	auipc	ra,0x0
    80001706:	f64080e7          	jalr	-156(ra) # 80001666 <pick_page_to_swap>
    8000170a:	84aa                	mv	s1,a0
  uint offset = get_offset();
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	ef2080e7          	jalr	-270(ra) # 800015fe <get_offset>
    80001714:	00050a1b          	sext.w	s4,a0
  uint64 pa = walkaddr(pagetable, pg_to_swap->va);
    80001718:	648c                	ld	a1,8(s1)
    8000171a:	854a                	mv	a0,s2
    8000171c:	00000097          	auipc	ra,0x0
    80001720:	930080e7          	jalr	-1744(ra) # 8000104c <walkaddr>
    80001724:	89aa                	mv	s3,a0
  writeToSwapFile(p, (char*) pa, offset, PGSIZE);
    80001726:	6685                	lui	a3,0x1
    80001728:	8652                	mv	a2,s4
    8000172a:	85aa                	mv	a1,a0
    8000172c:	8556                	mv	a0,s5
    8000172e:	00003097          	auipc	ra,0x3
    80001732:	036080e7          	jalr	54(ra) # 80004764 <writeToSwapFile>
  pg_to_swap->on_disk = 1;
    80001736:	4785                	li	a5,1
    80001738:	c89c                	sw	a5,16(s1)
  pg_to_swap->offset = offset;
    8000173a:	0144aa23          	sw	s4,20(s1)
  kfree((void*)pa);
    8000173e:	854e                	mv	a0,s3
    80001740:	fffff097          	auipc	ra,0xfffff
    80001744:	296080e7          	jalr	662(ra) # 800009d6 <kfree>
  pte_t* pte = walk(pagetable, pg_to_swap->va, 0);
    80001748:	4601                	li	a2,0
    8000174a:	648c                	ld	a1,8(s1)
    8000174c:	854a                	mv	a0,s2
    8000174e:	00000097          	auipc	ra,0x0
    80001752:	858080e7          	jalr	-1960(ra) # 80000fa6 <walk>
  *pte = (*pte | PTE_PG) ^ PTE_V;
    80001756:	611c                	ld	a5,0(a0)
    80001758:	2007e793          	ori	a5,a5,512
    8000175c:	0017c793          	xori	a5,a5,1
    80001760:	e11c                	sd	a5,0(a0)
    80001762:	12000073          	sfence.vma
}
    80001766:	70e2                	ld	ra,56(sp)
    80001768:	7442                	ld	s0,48(sp)
    8000176a:	74a2                	ld	s1,40(sp)
    8000176c:	7902                	ld	s2,32(sp)
    8000176e:	69e2                	ld	s3,24(sp)
    80001770:	6a42                	ld	s4,16(sp)
    80001772:	6aa2                	ld	s5,8(sp)
    80001774:	6121                	addi	sp,sp,64
    80001776:	8082                	ret

0000000080001778 <pick_page_to_swap_>:

struct page* pick_page_to_swap_(pagetable_t pagetable)
{
    80001778:	1141                	addi	sp,sp,-16
    8000177a:	e406                	sd	ra,8(sp)
    8000177c:	e022                	sd	s0,0(sp)
    8000177e:	0800                	addi	s0,sp,16
        return find_min_burst();
      case NFUA:
        return find_min_ratio();
    }
  #endif
  panic("no selection picked!");
    80001780:	00007517          	auipc	a0,0x7
    80001784:	9d850513          	addi	a0,a0,-1576 # 80008158 <digits+0x118>
    80001788:	fffff097          	auipc	ra,0xfffff
    8000178c:	da2080e7          	jalr	-606(ra) # 8000052a <panic>

0000000080001790 <page_swap_in>:
// returns -1 if kalloc failed 
// returns -2 if va not on disk
// returns -3 if va not aligned
// va must be aligned to the first va of the requested page
int page_swap_in(pagetable_t pagetable, uint64 va, struct proc *p)
{
    80001790:	7179                	addi	sp,sp,-48
    80001792:	f406                	sd	ra,40(sp)
    80001794:	f022                	sd	s0,32(sp)
    80001796:	ec26                	sd	s1,24(sp)
    80001798:	e84a                	sd	s2,16(sp)
    8000179a:	e44e                	sd	s3,8(sp)
    8000179c:	e052                	sd	s4,0(sp)
    8000179e:	1800                	addi	s0,sp,48
    800017a0:	8a2a                	mv	s4,a0
    800017a2:	89b2                	mv	s3,a2
  //printf("pid:%d swapping in page starting at va:%d\n",p->pid,  va);
  struct page* pg;
  for ( pg =p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)  
    800017a4:	17060493          	addi	s1,a2,368 # 1170 <_entry-0x7fffee90>
    800017a8:	57060713          	addi	a4,a2,1392
  {
    if (pg->va == va) // found relevant page
    800017ac:	649c                	ld	a5,8(s1)
    800017ae:	00b78863          	beq	a5,a1,800017be <page_swap_in+0x2e>
  for ( pg =p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)  
    800017b2:	02048493          	addi	s1,s1,32
    800017b6:	fee49be3          	bne	s1,a4,800017ac <page_swap_in+0x1c>
      *pte = (PA2PTE(mem) | perm);
      return 0;
  
    }
  }
  return -3;
    800017ba:	5575                	li	a0,-3
    800017bc:	a085                	j	8000181c <page_swap_in+0x8c>
      if (pg->on_disk == 0)
    800017be:	489c                	lw	a5,16(s1)
    800017c0:	cfa5                	beqz	a5,80001838 <page_swap_in+0xa8>
      if (countmemory(p->pagetable) >= MAX_PSYC_PAGES)
    800017c2:	0509b503          	ld	a0,80(s3) # fffffffffffff050 <end+0xffffffff7ffc9050>
    800017c6:	00000097          	auipc	ra,0x0
    800017ca:	d86080e7          	jalr	-634(ra) # 8000154c <countmemory>
    800017ce:	47bd                	li	a5,15
    800017d0:	04a7ce63          	blt	a5,a0,8000182c <page_swap_in+0x9c>
      char* mem = kalloc();
    800017d4:	fffff097          	auipc	ra,0xfffff
    800017d8:	2fe080e7          	jalr	766(ra) # 80000ad2 <kalloc>
    800017dc:	892a                	mv	s2,a0
      if(mem == 0)
    800017de:	cd39                	beqz	a0,8000183c <page_swap_in+0xac>
      readFromSwapFile(p, mem, pg->offset, PGSIZE);
    800017e0:	6685                	lui	a3,0x1
    800017e2:	48d0                	lw	a2,20(s1)
    800017e4:	85aa                	mv	a1,a0
    800017e6:	854e                	mv	a0,s3
    800017e8:	00003097          	auipc	ra,0x3
    800017ec:	fa0080e7          	jalr	-96(ra) # 80004788 <readFromSwapFile>
      pg->on_disk = 0;
    800017f0:	0004a823          	sw	zero,16(s1)
      pte_t* pte = walk(pagetable, pg->va, 0);
    800017f4:	4601                	li	a2,0
    800017f6:	648c                	ld	a1,8(s1)
    800017f8:	8552                	mv	a0,s4
    800017fa:	fffff097          	auipc	ra,0xfffff
    800017fe:	7ac080e7          	jalr	1964(ra) # 80000fa6 <walk>
      int perm = (*pte) & 1023; //gives me the lower 10bits (permissions)
    80001802:	6118                	ld	a4,0(a0)
    80001804:	3ff77713          	andi	a4,a4,1023
      perm = (perm ^ PTE_PG) | PTE_V; // turn off pg flag and turn on valid
    80001808:	20074713          	xori	a4,a4,512
      *pte = (PA2PTE(mem) | perm);
    8000180c:	00c95793          	srli	a5,s2,0xc
    80001810:	07aa                	slli	a5,a5,0xa
    80001812:	00176713          	ori	a4,a4,1
    80001816:	8fd9                	or	a5,a5,a4
    80001818:	e11c                	sd	a5,0(a0)
      return 0;
    8000181a:	4501                	li	a0,0
}
    8000181c:	70a2                	ld	ra,40(sp)
    8000181e:	7402                	ld	s0,32(sp)
    80001820:	64e2                	ld	s1,24(sp)
    80001822:	6942                	ld	s2,16(sp)
    80001824:	69a2                	ld	s3,8(sp)
    80001826:	6a02                	ld	s4,0(sp)
    80001828:	6145                	addi	sp,sp,48
    8000182a:	8082                	ret
          page_swap_out(pagetable);
    8000182c:	8552                	mv	a0,s4
    8000182e:	00000097          	auipc	ra,0x0
    80001832:	eb4080e7          	jalr	-332(ra) # 800016e2 <page_swap_out>
    80001836:	bf79                	j	800017d4 <page_swap_in+0x44>
        return -2;
    80001838:	5579                	li	a0,-2
    8000183a:	b7cd                	j	8000181c <page_swap_in+0x8c>
        return -1;
    8000183c:	557d                	li	a0,-1
    8000183e:	bff9                	j	8000181c <page_swap_in+0x8c>

0000000080001840 <print_pages>:
  printf("pages in memory:%d\n", countmemory(p->pagetable));
  print_pages(p->pagetable);
}

void print_pages(pagetable_t pagetable)
{
    80001840:	7179                	addi	sp,sp,-48
    80001842:	f406                	sd	ra,40(sp)
    80001844:	f022                	sd	s0,32(sp)
    80001846:	ec26                	sd	s1,24(sp)
    80001848:	e84a                	sd	s2,16(sp)
    8000184a:	e44e                	sd	s3,8(sp)
    8000184c:	1800                	addi	s0,sp,48
   struct proc* p = myproc();
    8000184e:	00000097          	auipc	ra,0x0
    80001852:	618080e7          	jalr	1560(ra) # 80001e66 <myproc>
   struct page* pg;
   for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80001856:	17050493          	addi	s1,a0,368
    8000185a:	57050913          	addi	s2,a0,1392
      printf("va : %d, on disk: %d ,  offset : %d , used : %d \n",pg->va , pg->on_disk , pg->offset , pg->used);
    8000185e:	00007997          	auipc	s3,0x7
    80001862:	91298993          	addi	s3,s3,-1774 # 80008170 <digits+0x130>
    80001866:	4c98                	lw	a4,24(s1)
    80001868:	48d4                	lw	a3,20(s1)
    8000186a:	4890                	lw	a2,16(s1)
    8000186c:	648c                	ld	a1,8(s1)
    8000186e:	854e                	mv	a0,s3
    80001870:	fffff097          	auipc	ra,0xfffff
    80001874:	d04080e7          	jalr	-764(ra) # 80000574 <printf>
   for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80001878:	02048493          	addi	s1,s1,32
    8000187c:	fe9915e3          	bne	s2,s1,80001866 <print_pages+0x26>
  //   else if((*pte & PTE_V) || ((*pte & PTE_PG)))
  //   {
  //     printf("pte address of pid %d = %p\n",myproc()->pid, pte);
  //   }
  // }
}
    80001880:	70a2                	ld	ra,40(sp)
    80001882:	7402                	ld	s0,32(sp)
    80001884:	64e2                	ld	s1,24(sp)
    80001886:	6942                	ld	s2,16(sp)
    80001888:	69a2                	ld	s3,8(sp)
    8000188a:	6145                	addi	sp,sp,48
    8000188c:	8082                	ret

000000008000188e <ppages>:
{
    8000188e:	1101                	addi	sp,sp,-32
    80001890:	ec06                	sd	ra,24(sp)
    80001892:	e822                	sd	s0,16(sp)
    80001894:	e426                	sd	s1,8(sp)
    80001896:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	5ce080e7          	jalr	1486(ra) # 80001e66 <myproc>
    800018a0:	84aa                	mv	s1,a0
  printf("total pages:%d\n", counttotal(p->pagetable));
    800018a2:	6928                	ld	a0,80(a0)
    800018a4:	00000097          	auipc	ra,0x0
    800018a8:	d02080e7          	jalr	-766(ra) # 800015a6 <counttotal>
    800018ac:	85aa                	mv	a1,a0
    800018ae:	00007517          	auipc	a0,0x7
    800018b2:	8fa50513          	addi	a0,a0,-1798 # 800081a8 <digits+0x168>
    800018b6:	fffff097          	auipc	ra,0xfffff
    800018ba:	cbe080e7          	jalr	-834(ra) # 80000574 <printf>
  printf("pages in memory:%d\n", countmemory(p->pagetable));
    800018be:	68a8                	ld	a0,80(s1)
    800018c0:	00000097          	auipc	ra,0x0
    800018c4:	c8c080e7          	jalr	-884(ra) # 8000154c <countmemory>
    800018c8:	85aa                	mv	a1,a0
    800018ca:	00007517          	auipc	a0,0x7
    800018ce:	8ee50513          	addi	a0,a0,-1810 # 800081b8 <digits+0x178>
    800018d2:	fffff097          	auipc	ra,0xfffff
    800018d6:	ca2080e7          	jalr	-862(ra) # 80000574 <printf>
  print_pages(p->pagetable);
    800018da:	68a8                	ld	a0,80(s1)
    800018dc:	00000097          	auipc	ra,0x0
    800018e0:	f64080e7          	jalr	-156(ra) # 80001840 <print_pages>
}
    800018e4:	60e2                	ld	ra,24(sp)
    800018e6:	6442                	ld	s0,16(sp)
    800018e8:	64a2                	ld	s1,8(sp)
    800018ea:	6105                	addi	sp,sp,32
    800018ec:	8082                	ret

00000000800018ee <add_page>:


// find unused page struct in p->pages and set its va
void add_page(pagetable_t pagetable, uint64 va)
{
    800018ee:	1101                	addi	sp,sp,-32
    800018f0:	ec06                	sd	ra,24(sp)
    800018f2:	e822                	sd	s0,16(sp)
    800018f4:	e426                	sd	s1,8(sp)
    800018f6:	e04a                	sd	s2,0(sp)
    800018f8:	1000                	addi	s0,sp,32
    800018fa:	892a                	mv	s2,a0
    800018fc:	84ae                	mv	s1,a1
  struct proc* p = myproc();
    800018fe:	00000097          	auipc	ra,0x0
    80001902:	568080e7          	jalr	1384(ra) # 80001e66 <myproc>
  if (p->pid > 1) // we want the shell process to add pages to sub processes so > 1 and not > 2
    80001906:	5918                	lw	a4,48(a0)
    80001908:	4785                	li	a5,1
    8000190a:	02e7d763          	bge	a5,a4,80001938 <add_page+0x4a>
  {
    struct page* pg;
    for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    8000190e:	17050793          	addi	a5,a0,368
    80001912:	57050693          	addi	a3,a0,1392
    {
      if (pg->used == 0)
    80001916:	4f98                	lw	a4,24(a5)
    80001918:	c711                	beqz	a4,80001924 <add_page+0x36>
    for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    8000191a:	02078793          	addi	a5,a5,32
    8000191e:	fed79ce3          	bne	a5,a3,80001916 <add_page+0x28>
    80001922:	a819                	j	80001938 <add_page+0x4a>
      {
        pg->pagetable = pagetable;
    80001924:	0127b023          	sd	s2,0(a5)
        pg->used = 1;
    80001928:	4705                	li	a4,1
    8000192a:	cf98                	sw	a4,24(a5)
        pg->va = va;
    8000192c:	e784                	sd	s1,8(a5)
        pg->time = ticks;
    8000192e:	00007717          	auipc	a4,0x7
    80001932:	70272703          	lw	a4,1794(a4) # 80009030 <ticks>
    80001936:	cfd8                	sw	a4,28(a5)
        return;
      }
    } 
  }
}
    80001938:	60e2                	ld	ra,24(sp)
    8000193a:	6442                	ld	s0,16(sp)
    8000193c:	64a2                	ld	s1,8(sp)
    8000193e:	6902                	ld	s2,0(sp)
    80001940:	6105                	addi	sp,sp,32
    80001942:	8082                	ret

0000000080001944 <remove_page>:

void remove_page(pagetable_t pagetable, uint64 va)
{
    80001944:	1101                	addi	sp,sp,-32
    80001946:	ec06                	sd	ra,24(sp)
    80001948:	e822                	sd	s0,16(sp)
    8000194a:	e426                	sd	s1,8(sp)
    8000194c:	1000                	addi	s0,sp,32
    8000194e:	84ae                	mv	s1,a1
  struct proc* p = myproc();
    80001950:	00000097          	auipc	ra,0x0
    80001954:	516080e7          	jalr	1302(ra) # 80001e66 <myproc>
  if (p->pid > 2)
    80001958:	5918                	lw	a4,48(a0)
    8000195a:	4789                	li	a5,2
    8000195c:	02e7dc63          	bge	a5,a4,80001994 <remove_page+0x50>
  {
  struct page* pg;
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80001960:	17050793          	addi	a5,a0,368
    80001964:	57050693          	addi	a3,a0,1392
  {
    if (pg->used == 1)
    80001968:	4605                	li	a2,1
    8000196a:	a029                	j	80001974 <remove_page+0x30>
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    8000196c:	02078793          	addi	a5,a5,32
    80001970:	02d78263          	beq	a5,a3,80001994 <remove_page+0x50>
    if (pg->used == 1)
    80001974:	4f98                	lw	a4,24(a5)
    80001976:	fec71be3          	bne	a4,a2,8000196c <remove_page+0x28>
    {
      if (pg->va == va)
    8000197a:	6798                	ld	a4,8(a5)
    8000197c:	fe9718e3          	bne	a4,s1,8000196c <remove_page+0x28>
      {
        
          pg->used = 0;
    80001980:	0007ac23          	sw	zero,24(a5)
          pg->va = 0;
    80001984:	0007b423          	sd	zero,8(a5)
          pg->offset = 0;
    80001988:	0007aa23          	sw	zero,20(a5)
          pg->on_disk = 0;
    8000198c:	0007a823          	sw	zero,16(a5)
          pg->pagetable = 0;
    80001990:	0007b023          	sd	zero,0(a5)

      }
    }
  } 
  }
    80001994:	60e2                	ld	ra,24(sp)
    80001996:	6442                	ld	s0,16(sp)
    80001998:	64a2                	ld	s1,8(sp)
    8000199a:	6105                	addi	sp,sp,32
    8000199c:	8082                	ret

000000008000199e <uvmunmap>:
{
    8000199e:	715d                	addi	sp,sp,-80
    800019a0:	e486                	sd	ra,72(sp)
    800019a2:	e0a2                	sd	s0,64(sp)
    800019a4:	fc26                	sd	s1,56(sp)
    800019a6:	f84a                	sd	s2,48(sp)
    800019a8:	f44e                	sd	s3,40(sp)
    800019aa:	f052                	sd	s4,32(sp)
    800019ac:	ec56                	sd	s5,24(sp)
    800019ae:	e85a                	sd	s6,16(sp)
    800019b0:	e45e                	sd	s7,8(sp)
    800019b2:	0880                	addi	s0,sp,80
  if((va % PGSIZE) != 0)
    800019b4:	03459793          	slli	a5,a1,0x34
    800019b8:	e795                	bnez	a5,800019e4 <uvmunmap+0x46>
    800019ba:	89aa                	mv	s3,a0
    800019bc:	892e                	mv	s2,a1
    800019be:	8ab6                	mv	s5,a3
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800019c0:	0632                	slli	a2,a2,0xc
    800019c2:	00b60a33          	add	s4,a2,a1
    if(PTE_FLAGS(*pte) == PTE_V)
    800019c6:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800019c8:	6b05                	lui	s6,0x1
    800019ca:	0745ef63          	bltu	a1,s4,80001a48 <uvmunmap+0xaa>
}
    800019ce:	60a6                	ld	ra,72(sp)
    800019d0:	6406                	ld	s0,64(sp)
    800019d2:	74e2                	ld	s1,56(sp)
    800019d4:	7942                	ld	s2,48(sp)
    800019d6:	79a2                	ld	s3,40(sp)
    800019d8:	7a02                	ld	s4,32(sp)
    800019da:	6ae2                	ld	s5,24(sp)
    800019dc:	6b42                	ld	s6,16(sp)
    800019de:	6ba2                	ld	s7,8(sp)
    800019e0:	6161                	addi	sp,sp,80
    800019e2:	8082                	ret
    panic("uvmunmap: not aligned");
    800019e4:	00006517          	auipc	a0,0x6
    800019e8:	7ec50513          	addi	a0,a0,2028 # 800081d0 <digits+0x190>
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	b3e080e7          	jalr	-1218(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800019f4:	00006517          	auipc	a0,0x6
    800019f8:	7f450513          	addi	a0,a0,2036 # 800081e8 <digits+0x1a8>
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	b2e080e7          	jalr	-1234(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    80001a04:	00006517          	auipc	a0,0x6
    80001a08:	7f450513          	addi	a0,a0,2036 # 800081f8 <digits+0x1b8>
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	b1e080e7          	jalr	-1250(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    80001a14:	00006517          	auipc	a0,0x6
    80001a18:	7fc50513          	addi	a0,a0,2044 # 80008210 <digits+0x1d0>
    80001a1c:	fffff097          	auipc	ra,0xfffff
    80001a20:	b0e080e7          	jalr	-1266(ra) # 8000052a <panic>
        uint64 pa = PTE2PA(*pte);
    80001a24:	83a9                	srli	a5,a5,0xa
        kfree((void*)pa);
    80001a26:	00c79513          	slli	a0,a5,0xc
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	fac080e7          	jalr	-84(ra) # 800009d6 <kfree>
    remove_page(pagetable, a);
    80001a32:	85ca                	mv	a1,s2
    80001a34:	854e                	mv	a0,s3
    80001a36:	00000097          	auipc	ra,0x0
    80001a3a:	f0e080e7          	jalr	-242(ra) # 80001944 <remove_page>
    *pte = 0;
    80001a3e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001a42:	995a                	add	s2,s2,s6
    80001a44:	f94975e3          	bgeu	s2,s4,800019ce <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001a48:	4601                	li	a2,0
    80001a4a:	85ca                	mv	a1,s2
    80001a4c:	854e                	mv	a0,s3
    80001a4e:	fffff097          	auipc	ra,0xfffff
    80001a52:	558080e7          	jalr	1368(ra) # 80000fa6 <walk>
    80001a56:	84aa                	mv	s1,a0
    80001a58:	dd51                	beqz	a0,800019f4 <uvmunmap+0x56>
    if(((*pte & PTE_V) == 0) && ((*pte & PTE_PG) == 0))
    80001a5a:	611c                	ld	a5,0(a0)
    80001a5c:	2017f713          	andi	a4,a5,513
    80001a60:	d355                	beqz	a4,80001a04 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001a62:	3ff7f713          	andi	a4,a5,1023
    80001a66:	fb7707e3          	beq	a4,s7,80001a14 <uvmunmap+0x76>
    if(do_free)
    80001a6a:	fc0a84e3          	beqz	s5,80001a32 <uvmunmap+0x94>
      if ((*pte & PTE_PG) == 0)
    80001a6e:	2007f713          	andi	a4,a5,512
    80001a72:	f361                	bnez	a4,80001a32 <uvmunmap+0x94>
    80001a74:	bf45                	j	80001a24 <uvmunmap+0x86>

0000000080001a76 <uvmdealloc>:
{
    80001a76:	1101                	addi	sp,sp,-32
    80001a78:	ec06                	sd	ra,24(sp)
    80001a7a:	e822                	sd	s0,16(sp)
    80001a7c:	e426                	sd	s1,8(sp)
    80001a7e:	1000                	addi	s0,sp,32
    return oldsz;
    80001a80:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001a82:	00b67d63          	bgeu	a2,a1,80001a9c <uvmdealloc+0x26>
    80001a86:	84b2                	mv	s1,a2
  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001a88:	6785                	lui	a5,0x1
    80001a8a:	17fd                	addi	a5,a5,-1
    80001a8c:	00f60733          	add	a4,a2,a5
    80001a90:	767d                	lui	a2,0xfffff
    80001a92:	8f71                	and	a4,a4,a2
    80001a94:	97ae                	add	a5,a5,a1
    80001a96:	8ff1                	and	a5,a5,a2
    80001a98:	00f76863          	bltu	a4,a5,80001aa8 <uvmdealloc+0x32>
}
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	60e2                	ld	ra,24(sp)
    80001aa0:	6442                	ld	s0,16(sp)
    80001aa2:	64a2                	ld	s1,8(sp)
    80001aa4:	6105                	addi	sp,sp,32
    80001aa6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001aa8:	8f99                	sub	a5,a5,a4
    80001aaa:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001aac:	4685                	li	a3,1
    80001aae:	0007861b          	sext.w	a2,a5
    80001ab2:	85ba                	mv	a1,a4
    80001ab4:	00000097          	auipc	ra,0x0
    80001ab8:	eea080e7          	jalr	-278(ra) # 8000199e <uvmunmap>
    80001abc:	b7c5                	j	80001a9c <uvmdealloc+0x26>

0000000080001abe <uvmalloc>:
{
    80001abe:	715d                	addi	sp,sp,-80
    80001ac0:	e486                	sd	ra,72(sp)
    80001ac2:	e0a2                	sd	s0,64(sp)
    80001ac4:	fc26                	sd	s1,56(sp)
    80001ac6:	f84a                	sd	s2,48(sp)
    80001ac8:	f44e                	sd	s3,40(sp)
    80001aca:	f052                	sd	s4,32(sp)
    80001acc:	ec56                	sd	s5,24(sp)
    80001ace:	e85a                	sd	s6,16(sp)
    80001ad0:	e45e                	sd	s7,8(sp)
    80001ad2:	e062                	sd	s8,0(sp)
    80001ad4:	0880                	addi	s0,sp,80
    80001ad6:	89aa                	mv	s3,a0
    80001ad8:	8a2e                	mv	s4,a1
    80001ada:	8ab2                	mv	s5,a2
  struct proc* p = myproc();
    80001adc:	00000097          	auipc	ra,0x0
    80001ae0:	38a080e7          	jalr	906(ra) # 80001e66 <myproc>
  if(newsz < oldsz)
    80001ae4:	0b4ae963          	bltu	s5,s4,80001b96 <uvmalloc+0xd8>
    80001ae8:	8b2a                	mv	s6,a0
  oldsz = PGROUNDUP(oldsz);
    80001aea:	6585                	lui	a1,0x1
    80001aec:	15fd                	addi	a1,a1,-1
    80001aee:	9a2e                	add	s4,s4,a1
    80001af0:	77fd                	lui	a5,0xfffff
    80001af2:	00fa7a33          	and	s4,s4,a5
  for(a = oldsz; a < newsz; a += PGSIZE)
    80001af6:	0b5a7d63          	bgeu	s4,s5,80001bb0 <uvmalloc+0xf2>
    80001afa:	8952                	mv	s2,s4
    if ((p->pid > 2) && (countmemory(pagetable) >= MAX_PSYC_PAGES))
    80001afc:	4b89                	li	s7,2
    80001afe:	4c3d                	li	s8,15
    80001b00:	a089                	j	80001b42 <uvmalloc+0x84>
    mem = kalloc();
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	fd0080e7          	jalr	-48(ra) # 80000ad2 <kalloc>
    80001b0a:	84aa                	mv	s1,a0
    if(mem == 0)
    80001b0c:	cd21                	beqz	a0,80001b64 <uvmalloc+0xa6>
    memset(mem, 0, PGSIZE);
    80001b0e:	6605                	lui	a2,0x1
    80001b10:	4581                	li	a1,0
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	1ac080e7          	jalr	428(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001b1a:	4779                	li	a4,30
    80001b1c:	86a6                	mv	a3,s1
    80001b1e:	6605                	lui	a2,0x1
    80001b20:	85ca                	mv	a1,s2
    80001b22:	854e                	mv	a0,s3
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	56a080e7          	jalr	1386(ra) # 8000108e <mappages>
    80001b2c:	e529                	bnez	a0,80001b76 <uvmalloc+0xb8>
    add_page(pagetable, a);
    80001b2e:	85ca                	mv	a1,s2
    80001b30:	854e                	mv	a0,s3
    80001b32:	00000097          	auipc	ra,0x0
    80001b36:	dbc080e7          	jalr	-580(ra) # 800018ee <add_page>
  for(a = oldsz; a < newsz; a += PGSIZE)
    80001b3a:	6785                	lui	a5,0x1
    80001b3c:	993e                	add	s2,s2,a5
    80001b3e:	05597a63          	bgeu	s2,s5,80001b92 <uvmalloc+0xd4>
    if ((p->pid > 2) && (countmemory(pagetable) >= MAX_PSYC_PAGES))
    80001b42:	030b2783          	lw	a5,48(s6) # 1030 <_entry-0x7fffefd0>
    80001b46:	fafbdee3          	bge	s7,a5,80001b02 <uvmalloc+0x44>
    80001b4a:	854e                	mv	a0,s3
    80001b4c:	00000097          	auipc	ra,0x0
    80001b50:	a00080e7          	jalr	-1536(ra) # 8000154c <countmemory>
    80001b54:	faac57e3          	bge	s8,a0,80001b02 <uvmalloc+0x44>
      page_swap_out(pagetable);
    80001b58:	854e                	mv	a0,s3
    80001b5a:	00000097          	auipc	ra,0x0
    80001b5e:	b88080e7          	jalr	-1144(ra) # 800016e2 <page_swap_out>
    80001b62:	b745                	j	80001b02 <uvmalloc+0x44>
      uvmdealloc(pagetable, a, oldsz);
    80001b64:	8652                	mv	a2,s4
    80001b66:	85ca                	mv	a1,s2
    80001b68:	854e                	mv	a0,s3
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	f0c080e7          	jalr	-244(ra) # 80001a76 <uvmdealloc>
      return 0;
    80001b72:	4501                	li	a0,0
    80001b74:	a015                	j	80001b98 <uvmalloc+0xda>
      kfree(mem);
    80001b76:	8526                	mv	a0,s1
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	e5e080e7          	jalr	-418(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001b80:	8652                	mv	a2,s4
    80001b82:	85ca                	mv	a1,s2
    80001b84:	854e                	mv	a0,s3
    80001b86:	00000097          	auipc	ra,0x0
    80001b8a:	ef0080e7          	jalr	-272(ra) # 80001a76 <uvmdealloc>
      return 0;
    80001b8e:	4501                	li	a0,0
    80001b90:	a021                	j	80001b98 <uvmalloc+0xda>
  return newsz;
    80001b92:	8556                	mv	a0,s5
    80001b94:	a011                	j	80001b98 <uvmalloc+0xda>
    return oldsz;
    80001b96:	8552                	mv	a0,s4
}
    80001b98:	60a6                	ld	ra,72(sp)
    80001b9a:	6406                	ld	s0,64(sp)
    80001b9c:	74e2                	ld	s1,56(sp)
    80001b9e:	7942                	ld	s2,48(sp)
    80001ba0:	79a2                	ld	s3,40(sp)
    80001ba2:	7a02                	ld	s4,32(sp)
    80001ba4:	6ae2                	ld	s5,24(sp)
    80001ba6:	6b42                	ld	s6,16(sp)
    80001ba8:	6ba2                	ld	s7,8(sp)
    80001baa:	6c02                	ld	s8,0(sp)
    80001bac:	6161                	addi	sp,sp,80
    80001bae:	8082                	ret
  return newsz;
    80001bb0:	8556                	mv	a0,s5
    80001bb2:	b7dd                	j	80001b98 <uvmalloc+0xda>

0000000080001bb4 <uvmfree>:
{
    80001bb4:	1101                	addi	sp,sp,-32
    80001bb6:	ec06                	sd	ra,24(sp)
    80001bb8:	e822                	sd	s0,16(sp)
    80001bba:	e426                	sd	s1,8(sp)
    80001bbc:	1000                	addi	s0,sp,32
    80001bbe:	84aa                	mv	s1,a0
  if(sz > 0)
    80001bc0:	e999                	bnez	a1,80001bd6 <uvmfree+0x22>
  freewalk(pagetable);
    80001bc2:	8526                	mv	a0,s1
    80001bc4:	fffff097          	auipc	ra,0xfffff
    80001bc8:	71e080e7          	jalr	1822(ra) # 800012e2 <freewalk>
}
    80001bcc:	60e2                	ld	ra,24(sp)
    80001bce:	6442                	ld	s0,16(sp)
    80001bd0:	64a2                	ld	s1,8(sp)
    80001bd2:	6105                	addi	sp,sp,32
    80001bd4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001bd6:	6605                	lui	a2,0x1
    80001bd8:	167d                	addi	a2,a2,-1
    80001bda:	962e                	add	a2,a2,a1
    80001bdc:	4685                	li	a3,1
    80001bde:	8231                	srli	a2,a2,0xc
    80001be0:	4581                	li	a1,0
    80001be2:	00000097          	auipc	ra,0x0
    80001be6:	dbc080e7          	jalr	-580(ra) # 8000199e <uvmunmap>
    80001bea:	bfe1                	j	80001bc2 <uvmfree+0xe>

0000000080001bec <uvmcopy>:
{
    80001bec:	715d                	addi	sp,sp,-80
    80001bee:	e486                	sd	ra,72(sp)
    80001bf0:	e0a2                	sd	s0,64(sp)
    80001bf2:	fc26                	sd	s1,56(sp)
    80001bf4:	f84a                	sd	s2,48(sp)
    80001bf6:	f44e                	sd	s3,40(sp)
    80001bf8:	f052                	sd	s4,32(sp)
    80001bfa:	ec56                	sd	s5,24(sp)
    80001bfc:	e85a                	sd	s6,16(sp)
    80001bfe:	e45e                	sd	s7,8(sp)
    80001c00:	e062                	sd	s8,0(sp)
    80001c02:	0880                	addi	s0,sp,80
  for(i = 0; i < sz; i += PGSIZE){
    80001c04:	c675                	beqz	a2,80001cf0 <uvmcopy+0x104>
    80001c06:	8c2a                	mv	s8,a0
    80001c08:	8b2e                	mv	s6,a1
    80001c0a:	8bb2                	mv	s7,a2
    80001c0c:	4a01                	li	s4,0
    80001c0e:	a08d                	j	80001c70 <uvmcopy+0x84>
      panic("uvmcopy: pte should exist");
    80001c10:	00006517          	auipc	a0,0x6
    80001c14:	61850513          	addi	a0,a0,1560 # 80008228 <digits+0x1e8>
    80001c18:	fffff097          	auipc	ra,0xfffff
    80001c1c:	912080e7          	jalr	-1774(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    80001c20:	00006517          	auipc	a0,0x6
    80001c24:	62850513          	addi	a0,a0,1576 # 80008248 <digits+0x208>
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	902080e7          	jalr	-1790(ra) # 8000052a <panic>
      kfree(mem);
    80001c30:	8526                	mv	a0,s1
    80001c32:	fffff097          	auipc	ra,0xfffff
    80001c36:	da4080e7          	jalr	-604(ra) # 800009d6 <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001c3a:	4685                	li	a3,1
    80001c3c:	00ca5613          	srli	a2,s4,0xc
    80001c40:	4581                	li	a1,0
    80001c42:	855a                	mv	a0,s6
    80001c44:	00000097          	auipc	ra,0x0
    80001c48:	d5a080e7          	jalr	-678(ra) # 8000199e <uvmunmap>
  return -1;
    80001c4c:	597d                	li	s2,-1
}
    80001c4e:	854a                	mv	a0,s2
    80001c50:	60a6                	ld	ra,72(sp)
    80001c52:	6406                	ld	s0,64(sp)
    80001c54:	74e2                	ld	s1,56(sp)
    80001c56:	7942                	ld	s2,48(sp)
    80001c58:	79a2                	ld	s3,40(sp)
    80001c5a:	7a02                	ld	s4,32(sp)
    80001c5c:	6ae2                	ld	s5,24(sp)
    80001c5e:	6b42                	ld	s6,16(sp)
    80001c60:	6ba2                	ld	s7,8(sp)
    80001c62:	6c02                	ld	s8,0(sp)
    80001c64:	6161                	addi	sp,sp,80
    80001c66:	8082                	ret
  for(i = 0; i < sz; i += PGSIZE){
    80001c68:	6785                	lui	a5,0x1
    80001c6a:	9a3e                	add	s4,s4,a5
    80001c6c:	ff7a71e3          	bgeu	s4,s7,80001c4e <uvmcopy+0x62>
    if((pte = walk(old, i, 0)) == 0)
    80001c70:	4601                	li	a2,0
    80001c72:	85d2                	mv	a1,s4
    80001c74:	8562                	mv	a0,s8
    80001c76:	fffff097          	auipc	ra,0xfffff
    80001c7a:	330080e7          	jalr	816(ra) # 80000fa6 <walk>
    80001c7e:	89aa                	mv	s3,a0
    80001c80:	d941                	beqz	a0,80001c10 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
    80001c82:	6118                	ld	a4,0(a0)
    80001c84:	20177793          	andi	a5,a4,513
    80001c88:	dfc1                	beqz	a5,80001c20 <uvmcopy+0x34>
    pa = PTE2PA(*pte);
    80001c8a:	00a75593          	srli	a1,a4,0xa
    80001c8e:	00c59a93          	slli	s5,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001c92:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	e3c080e7          	jalr	-452(ra) # 80000ad2 <kalloc>
    80001c9e:	84aa                	mv	s1,a0
    80001ca0:	dd49                	beqz	a0,80001c3a <uvmcopy+0x4e>
    memmove(mem, (char*)pa, PGSIZE);
    80001ca2:	6605                	lui	a2,0x1
    80001ca4:	85d6                	mv	a1,s5
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	074080e7          	jalr	116(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001cae:	874a                	mv	a4,s2
    80001cb0:	86a6                	mv	a3,s1
    80001cb2:	6605                	lui	a2,0x1
    80001cb4:	85d2                	mv	a1,s4
    80001cb6:	855a                	mv	a0,s6
    80001cb8:	fffff097          	auipc	ra,0xfffff
    80001cbc:	3d6080e7          	jalr	982(ra) # 8000108e <mappages>
    80001cc0:	892a                	mv	s2,a0
    80001cc2:	f53d                	bnez	a0,80001c30 <uvmcopy+0x44>
    if ( *pte & PTE_PG)
    80001cc4:	0009b783          	ld	a5,0(s3)
    80001cc8:	2007f793          	andi	a5,a5,512
    80001ccc:	dfd1                	beqz	a5,80001c68 <uvmcopy+0x7c>
      pte_t* pte2 = walk(new , i , 0);
    80001cce:	4601                	li	a2,0
    80001cd0:	85d2                	mv	a1,s4
    80001cd2:	855a                	mv	a0,s6
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	2d2080e7          	jalr	722(ra) # 80000fa6 <walk>
      *pte2 = (*pte2) ^ PTE_V;
    80001cdc:	611c                	ld	a5,0(a0)
    80001cde:	0017c793          	xori	a5,a5,1
    80001ce2:	e11c                	sd	a5,0(a0)
      kfree(mem);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	cf0080e7          	jalr	-784(ra) # 800009d6 <kfree>
    80001cee:	bfad                	j	80001c68 <uvmcopy+0x7c>
  return 0;
    80001cf0:	4901                	li	s2,0
    80001cf2:	bfb1                	j	80001c4e <uvmcopy+0x62>

0000000080001cf4 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001cf4:	7139                	addi	sp,sp,-64
    80001cf6:	fc06                	sd	ra,56(sp)
    80001cf8:	f822                	sd	s0,48(sp)
    80001cfa:	f426                	sd	s1,40(sp)
    80001cfc:	f04a                	sd	s2,32(sp)
    80001cfe:	ec4e                	sd	s3,24(sp)
    80001d00:	e852                	sd	s4,16(sp)
    80001d02:	e456                	sd	s5,8(sp)
    80001d04:	e05a                	sd	s6,0(sp)
    80001d06:	0080                	addi	s0,sp,64
    80001d08:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d0a:	00010497          	auipc	s1,0x10
    80001d0e:	9c648493          	addi	s1,s1,-1594 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001d12:	8b26                	mv	s6,s1
    80001d14:	00006a97          	auipc	s5,0x6
    80001d18:	2eca8a93          	addi	s5,s5,748 # 80008000 <etext>
    80001d1c:	04000937          	lui	s2,0x4000
    80001d20:	197d                	addi	s2,s2,-1
    80001d22:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d24:	00025a17          	auipc	s4,0x25
    80001d28:	5aca0a13          	addi	s4,s4,1452 # 800272d0 <tickslock>
    char *pa = kalloc();
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	da6080e7          	jalr	-602(ra) # 80000ad2 <kalloc>
    80001d34:	862a                	mv	a2,a0
    if(pa == 0)
    80001d36:	c131                	beqz	a0,80001d7a <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001d38:	416485b3          	sub	a1,s1,s6
    80001d3c:	8591                	srai	a1,a1,0x4
    80001d3e:	000ab783          	ld	a5,0(s5)
    80001d42:	02f585b3          	mul	a1,a1,a5
    80001d46:	2585                	addiw	a1,a1,1
    80001d48:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001d4c:	4719                	li	a4,6
    80001d4e:	6685                	lui	a3,0x1
    80001d50:	40b905b3          	sub	a1,s2,a1
    80001d54:	854e                	mv	a0,s3
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	3c6080e7          	jalr	966(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d5e:	57048493          	addi	s1,s1,1392
    80001d62:	fd4495e3          	bne	s1,s4,80001d2c <proc_mapstacks+0x38>
  }
}
    80001d66:	70e2                	ld	ra,56(sp)
    80001d68:	7442                	ld	s0,48(sp)
    80001d6a:	74a2                	ld	s1,40(sp)
    80001d6c:	7902                	ld	s2,32(sp)
    80001d6e:	69e2                	ld	s3,24(sp)
    80001d70:	6a42                	ld	s4,16(sp)
    80001d72:	6aa2                	ld	s5,8(sp)
    80001d74:	6b02                	ld	s6,0(sp)
    80001d76:	6121                	addi	sp,sp,64
    80001d78:	8082                	ret
      panic("kalloc");
    80001d7a:	00006517          	auipc	a0,0x6
    80001d7e:	4ee50513          	addi	a0,a0,1262 # 80008268 <digits+0x228>
    80001d82:	ffffe097          	auipc	ra,0xffffe
    80001d86:	7a8080e7          	jalr	1960(ra) # 8000052a <panic>

0000000080001d8a <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001d8a:	7139                	addi	sp,sp,-64
    80001d8c:	fc06                	sd	ra,56(sp)
    80001d8e:	f822                	sd	s0,48(sp)
    80001d90:	f426                	sd	s1,40(sp)
    80001d92:	f04a                	sd	s2,32(sp)
    80001d94:	ec4e                	sd	s3,24(sp)
    80001d96:	e852                	sd	s4,16(sp)
    80001d98:	e456                	sd	s5,8(sp)
    80001d9a:	e05a                	sd	s6,0(sp)
    80001d9c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001d9e:	00006597          	auipc	a1,0x6
    80001da2:	4d258593          	addi	a1,a1,1234 # 80008270 <digits+0x230>
    80001da6:	0000f517          	auipc	a0,0xf
    80001daa:	4fa50513          	addi	a0,a0,1274 # 800112a0 <pid_lock>
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	d84080e7          	jalr	-636(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001db6:	00006597          	auipc	a1,0x6
    80001dba:	4c258593          	addi	a1,a1,1218 # 80008278 <digits+0x238>
    80001dbe:	0000f517          	auipc	a0,0xf
    80001dc2:	4fa50513          	addi	a0,a0,1274 # 800112b8 <wait_lock>
    80001dc6:	fffff097          	auipc	ra,0xfffff
    80001dca:	d6c080e7          	jalr	-660(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dce:	00010497          	auipc	s1,0x10
    80001dd2:	90248493          	addi	s1,s1,-1790 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001dd6:	00006b17          	auipc	s6,0x6
    80001dda:	4b2b0b13          	addi	s6,s6,1202 # 80008288 <digits+0x248>
      p->kstack = KSTACK((int) (p - proc));
    80001dde:	8aa6                	mv	s5,s1
    80001de0:	00006a17          	auipc	s4,0x6
    80001de4:	220a0a13          	addi	s4,s4,544 # 80008000 <etext>
    80001de8:	04000937          	lui	s2,0x4000
    80001dec:	197d                	addi	s2,s2,-1
    80001dee:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001df0:	00025997          	auipc	s3,0x25
    80001df4:	4e098993          	addi	s3,s3,1248 # 800272d0 <tickslock>
      initlock(&p->lock, "proc");
    80001df8:	85da                	mv	a1,s6
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	d36080e7          	jalr	-714(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001e04:	415487b3          	sub	a5,s1,s5
    80001e08:	8791                	srai	a5,a5,0x4
    80001e0a:	000a3703          	ld	a4,0(s4)
    80001e0e:	02e787b3          	mul	a5,a5,a4
    80001e12:	2785                	addiw	a5,a5,1
    80001e14:	00d7979b          	slliw	a5,a5,0xd
    80001e18:	40f907b3          	sub	a5,s2,a5
    80001e1c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e1e:	57048493          	addi	s1,s1,1392
    80001e22:	fd349be3          	bne	s1,s3,80001df8 <procinit+0x6e>
  }
}
    80001e26:	70e2                	ld	ra,56(sp)
    80001e28:	7442                	ld	s0,48(sp)
    80001e2a:	74a2                	ld	s1,40(sp)
    80001e2c:	7902                	ld	s2,32(sp)
    80001e2e:	69e2                	ld	s3,24(sp)
    80001e30:	6a42                	ld	s4,16(sp)
    80001e32:	6aa2                	ld	s5,8(sp)
    80001e34:	6b02                	ld	s6,0(sp)
    80001e36:	6121                	addi	sp,sp,64
    80001e38:	8082                	ret

0000000080001e3a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001e3a:	1141                	addi	sp,sp,-16
    80001e3c:	e422                	sd	s0,8(sp)
    80001e3e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e40:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001e42:	2501                	sext.w	a0,a0
    80001e44:	6422                	ld	s0,8(sp)
    80001e46:	0141                	addi	sp,sp,16
    80001e48:	8082                	ret

0000000080001e4a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001e4a:	1141                	addi	sp,sp,-16
    80001e4c:	e422                	sd	s0,8(sp)
    80001e4e:	0800                	addi	s0,sp,16
    80001e50:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001e52:	2781                	sext.w	a5,a5
    80001e54:	079e                	slli	a5,a5,0x7
  return c;
}
    80001e56:	0000f517          	auipc	a0,0xf
    80001e5a:	47a50513          	addi	a0,a0,1146 # 800112d0 <cpus>
    80001e5e:	953e                	add	a0,a0,a5
    80001e60:	6422                	ld	s0,8(sp)
    80001e62:	0141                	addi	sp,sp,16
    80001e64:	8082                	ret

0000000080001e66 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001e66:	1101                	addi	sp,sp,-32
    80001e68:	ec06                	sd	ra,24(sp)
    80001e6a:	e822                	sd	s0,16(sp)
    80001e6c:	e426                	sd	s1,8(sp)
    80001e6e:	1000                	addi	s0,sp,32
  push_off();
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	d06080e7          	jalr	-762(ra) # 80000b76 <push_off>
    80001e78:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001e7a:	2781                	sext.w	a5,a5
    80001e7c:	079e                	slli	a5,a5,0x7
    80001e7e:	0000f717          	auipc	a4,0xf
    80001e82:	42270713          	addi	a4,a4,1058 # 800112a0 <pid_lock>
    80001e86:	97ba                	add	a5,a5,a4
    80001e88:	7b84                	ld	s1,48(a5)
  pop_off();
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	d8c080e7          	jalr	-628(ra) # 80000c16 <pop_off>
  return p;
}
    80001e92:	8526                	mv	a0,s1
    80001e94:	60e2                	ld	ra,24(sp)
    80001e96:	6442                	ld	s0,16(sp)
    80001e98:	64a2                	ld	s1,8(sp)
    80001e9a:	6105                	addi	sp,sp,32
    80001e9c:	8082                	ret

0000000080001e9e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001e9e:	1141                	addi	sp,sp,-16
    80001ea0:	e406                	sd	ra,8(sp)
    80001ea2:	e022                	sd	s0,0(sp)
    80001ea4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001ea6:	00000097          	auipc	ra,0x0
    80001eaa:	fc0080e7          	jalr	-64(ra) # 80001e66 <myproc>
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	dc8080e7          	jalr	-568(ra) # 80000c76 <release>

  if (first) {
    80001eb6:	00007797          	auipc	a5,0x7
    80001eba:	a8a7a783          	lw	a5,-1398(a5) # 80008940 <first.1>
    80001ebe:	eb89                	bnez	a5,80001ed0 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ec0:	00001097          	auipc	ra,0x1
    80001ec4:	d26080e7          	jalr	-730(ra) # 80002be6 <usertrapret>
}
    80001ec8:	60a2                	ld	ra,8(sp)
    80001eca:	6402                	ld	s0,0(sp)
    80001ecc:	0141                	addi	sp,sp,16
    80001ece:	8082                	ret
    first = 0;
    80001ed0:	00007797          	auipc	a5,0x7
    80001ed4:	a607a823          	sw	zero,-1424(a5) # 80008940 <first.1>
    fsinit(ROOTDEV);
    80001ed8:	4505                	li	a0,1
    80001eda:	00002097          	auipc	ra,0x2
    80001ede:	b22080e7          	jalr	-1246(ra) # 800039fc <fsinit>
    80001ee2:	bff9                	j	80001ec0 <forkret+0x22>

0000000080001ee4 <allocpid>:
allocpid() {
    80001ee4:	1101                	addi	sp,sp,-32
    80001ee6:	ec06                	sd	ra,24(sp)
    80001ee8:	e822                	sd	s0,16(sp)
    80001eea:	e426                	sd	s1,8(sp)
    80001eec:	e04a                	sd	s2,0(sp)
    80001eee:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ef0:	0000f917          	auipc	s2,0xf
    80001ef4:	3b090913          	addi	s2,s2,944 # 800112a0 <pid_lock>
    80001ef8:	854a                	mv	a0,s2
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	cc8080e7          	jalr	-824(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001f02:	00007797          	auipc	a5,0x7
    80001f06:	a4278793          	addi	a5,a5,-1470 # 80008944 <nextpid>
    80001f0a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001f0c:	0014871b          	addiw	a4,s1,1
    80001f10:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001f12:	854a                	mv	a0,s2
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	d62080e7          	jalr	-670(ra) # 80000c76 <release>
}
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	60e2                	ld	ra,24(sp)
    80001f20:	6442                	ld	s0,16(sp)
    80001f22:	64a2                	ld	s1,8(sp)
    80001f24:	6902                	ld	s2,0(sp)
    80001f26:	6105                	addi	sp,sp,32
    80001f28:	8082                	ret

0000000080001f2a <proc_pagetable>:
{
    80001f2a:	1101                	addi	sp,sp,-32
    80001f2c:	ec06                	sd	ra,24(sp)
    80001f2e:	e822                	sd	s0,16(sp)
    80001f30:	e426                	sd	s1,8(sp)
    80001f32:	e04a                	sd	s2,0(sp)
    80001f34:	1000                	addi	s0,sp,32
    80001f36:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	30a080e7          	jalr	778(ra) # 80001242 <uvmcreate>
    80001f40:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001f42:	c931                	beqz	a0,80001f96 <proc_pagetable+0x6c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f44:	4729                	li	a4,10
    80001f46:	00005697          	auipc	a3,0x5
    80001f4a:	0ba68693          	addi	a3,a3,186 # 80007000 <_trampoline>
    80001f4e:	6605                	lui	a2,0x1
    80001f50:	040005b7          	lui	a1,0x4000
    80001f54:	15fd                	addi	a1,a1,-1
    80001f56:	05b2                	slli	a1,a1,0xc
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	136080e7          	jalr	310(ra) # 8000108e <mappages>
    80001f60:	04054263          	bltz	a0,80001fa4 <proc_pagetable+0x7a>
  if (p->pid >2 )
    80001f64:	03092703          	lw	a4,48(s2)
    80001f68:	4789                	li	a5,2
    80001f6a:	04e7c563          	blt	a5,a4,80001fb4 <proc_pagetable+0x8a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f6e:	4719                	li	a4,6
    80001f70:	05893683          	ld	a3,88(s2)
    80001f74:	6605                	lui	a2,0x1
    80001f76:	020005b7          	lui	a1,0x2000
    80001f7a:	15fd                	addi	a1,a1,-1
    80001f7c:	05b6                	slli	a1,a1,0xd
    80001f7e:	8526                	mv	a0,s1
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	10e080e7          	jalr	270(ra) # 8000108e <mappages>
    80001f88:	04054063          	bltz	a0,80001fc8 <proc_pagetable+0x9e>
  if (p->pid >2 )
    80001f8c:	03092703          	lw	a4,48(s2)
    80001f90:	4789                	li	a5,2
    80001f92:	04e7ce63          	blt	a5,a4,80001fee <proc_pagetable+0xc4>
}
    80001f96:	8526                	mv	a0,s1
    80001f98:	60e2                	ld	ra,24(sp)
    80001f9a:	6442                	ld	s0,16(sp)
    80001f9c:	64a2                	ld	s1,8(sp)
    80001f9e:	6902                	ld	s2,0(sp)
    80001fa0:	6105                	addi	sp,sp,32
    80001fa2:	8082                	ret
    uvmfree(pagetable, 0);
    80001fa4:	4581                	li	a1,0
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	00000097          	auipc	ra,0x0
    80001fac:	c0c080e7          	jalr	-1012(ra) # 80001bb4 <uvmfree>
    return 0;
    80001fb0:	4481                	li	s1,0
    80001fb2:	b7d5                	j	80001f96 <proc_pagetable+0x6c>
    add_page(pagetable, TRAMPOLINE);
    80001fb4:	040005b7          	lui	a1,0x4000
    80001fb8:	15fd                	addi	a1,a1,-1
    80001fba:	05b2                	slli	a1,a1,0xc
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	930080e7          	jalr	-1744(ra) # 800018ee <add_page>
    80001fc6:	b765                	j	80001f6e <proc_pagetable+0x44>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001fc8:	4681                	li	a3,0
    80001fca:	4605                	li	a2,1
    80001fcc:	040005b7          	lui	a1,0x4000
    80001fd0:	15fd                	addi	a1,a1,-1
    80001fd2:	05b2                	slli	a1,a1,0xc
    80001fd4:	8526                	mv	a0,s1
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	9c8080e7          	jalr	-1592(ra) # 8000199e <uvmunmap>
    uvmfree(pagetable, 0);
    80001fde:	4581                	li	a1,0
    80001fe0:	8526                	mv	a0,s1
    80001fe2:	00000097          	auipc	ra,0x0
    80001fe6:	bd2080e7          	jalr	-1070(ra) # 80001bb4 <uvmfree>
    return 0;
    80001fea:	4481                	li	s1,0
    80001fec:	b76d                	j	80001f96 <proc_pagetable+0x6c>
    add_page(pagetable, TRAPFRAME);
    80001fee:	020005b7          	lui	a1,0x2000
    80001ff2:	15fd                	addi	a1,a1,-1
    80001ff4:	05b6                	slli	a1,a1,0xd
    80001ff6:	8526                	mv	a0,s1
    80001ff8:	00000097          	auipc	ra,0x0
    80001ffc:	8f6080e7          	jalr	-1802(ra) # 800018ee <add_page>
    80002000:	bf59                	j	80001f96 <proc_pagetable+0x6c>

0000000080002002 <proc_freepagetable>:
{
    80002002:	1101                	addi	sp,sp,-32
    80002004:	ec06                	sd	ra,24(sp)
    80002006:	e822                	sd	s0,16(sp)
    80002008:	e426                	sd	s1,8(sp)
    8000200a:	e04a                	sd	s2,0(sp)
    8000200c:	1000                	addi	s0,sp,32
    8000200e:	84aa                	mv	s1,a0
    80002010:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002012:	4681                	li	a3,0
    80002014:	4605                	li	a2,1
    80002016:	040005b7          	lui	a1,0x4000
    8000201a:	15fd                	addi	a1,a1,-1
    8000201c:	05b2                	slli	a1,a1,0xc
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	980080e7          	jalr	-1664(ra) # 8000199e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80002026:	4681                	li	a3,0
    80002028:	4605                	li	a2,1
    8000202a:	020005b7          	lui	a1,0x2000
    8000202e:	15fd                	addi	a1,a1,-1
    80002030:	05b6                	slli	a1,a1,0xd
    80002032:	8526                	mv	a0,s1
    80002034:	00000097          	auipc	ra,0x0
    80002038:	96a080e7          	jalr	-1686(ra) # 8000199e <uvmunmap>
  uvmfree(pagetable, sz);
    8000203c:	85ca                	mv	a1,s2
    8000203e:	8526                	mv	a0,s1
    80002040:	00000097          	auipc	ra,0x0
    80002044:	b74080e7          	jalr	-1164(ra) # 80001bb4 <uvmfree>
}
    80002048:	60e2                	ld	ra,24(sp)
    8000204a:	6442                	ld	s0,16(sp)
    8000204c:	64a2                	ld	s1,8(sp)
    8000204e:	6902                	ld	s2,0(sp)
    80002050:	6105                	addi	sp,sp,32
    80002052:	8082                	ret

0000000080002054 <freeproc>:
{
    80002054:	1101                	addi	sp,sp,-32
    80002056:	ec06                	sd	ra,24(sp)
    80002058:	e822                	sd	s0,16(sp)
    8000205a:	e426                	sd	s1,8(sp)
    8000205c:	1000                	addi	s0,sp,32
    8000205e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80002060:	6d28                	ld	a0,88(a0)
    80002062:	c509                	beqz	a0,8000206c <freeproc+0x18>
    kfree((void*)p->trapframe);
    80002064:	fffff097          	auipc	ra,0xfffff
    80002068:	972080e7          	jalr	-1678(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    8000206c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80002070:	68a8                	ld	a0,80(s1)
    80002072:	c511                	beqz	a0,8000207e <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80002074:	64ac                	ld	a1,72(s1)
    80002076:	00000097          	auipc	ra,0x0
    8000207a:	f8c080e7          	jalr	-116(ra) # 80002002 <proc_freepagetable>
  p->pagetable = 0;
    8000207e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002082:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80002086:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000208a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000208e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002092:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002096:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000209a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    8000209e:	0004ac23          	sw	zero,24(s1)
}
    800020a2:	60e2                	ld	ra,24(sp)
    800020a4:	6442                	ld	s0,16(sp)
    800020a6:	64a2                	ld	s1,8(sp)
    800020a8:	6105                	addi	sp,sp,32
    800020aa:	8082                	ret

00000000800020ac <allocproc>:
{
    800020ac:	1101                	addi	sp,sp,-32
    800020ae:	ec06                	sd	ra,24(sp)
    800020b0:	e822                	sd	s0,16(sp)
    800020b2:	e426                	sd	s1,8(sp)
    800020b4:	e04a                	sd	s2,0(sp)
    800020b6:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800020b8:	0000f497          	auipc	s1,0xf
    800020bc:	61848493          	addi	s1,s1,1560 # 800116d0 <proc>
    800020c0:	00025917          	auipc	s2,0x25
    800020c4:	21090913          	addi	s2,s2,528 # 800272d0 <tickslock>
    acquire(&p->lock);
    800020c8:	8526                	mv	a0,s1
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	af8080e7          	jalr	-1288(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    800020d2:	4c9c                	lw	a5,24(s1)
    800020d4:	cf81                	beqz	a5,800020ec <allocproc+0x40>
      release(&p->lock);
    800020d6:	8526                	mv	a0,s1
    800020d8:	fffff097          	auipc	ra,0xfffff
    800020dc:	b9e080e7          	jalr	-1122(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e0:	57048493          	addi	s1,s1,1392
    800020e4:	ff2492e3          	bne	s1,s2,800020c8 <allocproc+0x1c>
  return 0;
    800020e8:	4481                	li	s1,0
    800020ea:	a0bd                	j	80002158 <allocproc+0xac>
  p->pid = allocpid();
    800020ec:	00000097          	auipc	ra,0x0
    800020f0:	df8080e7          	jalr	-520(ra) # 80001ee4 <allocpid>
    800020f4:	d888                	sw	a0,48(s1)
  p->state = USED;
    800020f6:	4785                	li	a5,1
    800020f8:	cc9c                	sw	a5,24(s1)
  for (struct page* pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    800020fa:	17048793          	addi	a5,s1,368
    800020fe:	57048713          	addi	a4,s1,1392
    pg->on_disk = 0;
    80002102:	0007a823          	sw	zero,16(a5)
    pg->used = 0;
    80002106:	0007ac23          	sw	zero,24(a5)
    pg->va = 0;
    8000210a:	0007b423          	sd	zero,8(a5)
  for (struct page* pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    8000210e:	02078793          	addi	a5,a5,32
    80002112:	fee798e3          	bne	a5,a4,80002102 <allocproc+0x56>
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	9bc080e7          	jalr	-1604(ra) # 80000ad2 <kalloc>
    8000211e:	892a                	mv	s2,a0
    80002120:	eca8                	sd	a0,88(s1)
    80002122:	c131                	beqz	a0,80002166 <allocproc+0xba>
  p->pagetable = proc_pagetable(p);
    80002124:	8526                	mv	a0,s1
    80002126:	00000097          	auipc	ra,0x0
    8000212a:	e04080e7          	jalr	-508(ra) # 80001f2a <proc_pagetable>
    8000212e:	892a                	mv	s2,a0
    80002130:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002132:	c531                	beqz	a0,8000217e <allocproc+0xd2>
  memset(&p->context, 0, sizeof(p->context));
    80002134:	07000613          	li	a2,112
    80002138:	4581                	li	a1,0
    8000213a:	06048513          	addi	a0,s1,96
    8000213e:	fffff097          	auipc	ra,0xfffff
    80002142:	b80080e7          	jalr	-1152(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80002146:	00000797          	auipc	a5,0x0
    8000214a:	d5878793          	addi	a5,a5,-680 # 80001e9e <forkret>
    8000214e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002150:	60bc                	ld	a5,64(s1)
    80002152:	6705                	lui	a4,0x1
    80002154:	97ba                	add	a5,a5,a4
    80002156:	f4bc                	sd	a5,104(s1)
}
    80002158:	8526                	mv	a0,s1
    8000215a:	60e2                	ld	ra,24(sp)
    8000215c:	6442                	ld	s0,16(sp)
    8000215e:	64a2                	ld	s1,8(sp)
    80002160:	6902                	ld	s2,0(sp)
    80002162:	6105                	addi	sp,sp,32
    80002164:	8082                	ret
    freeproc(p);
    80002166:	8526                	mv	a0,s1
    80002168:	00000097          	auipc	ra,0x0
    8000216c:	eec080e7          	jalr	-276(ra) # 80002054 <freeproc>
    release(&p->lock);
    80002170:	8526                	mv	a0,s1
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	b04080e7          	jalr	-1276(ra) # 80000c76 <release>
    return 0;
    8000217a:	84ca                	mv	s1,s2
    8000217c:	bff1                	j	80002158 <allocproc+0xac>
    freeproc(p);
    8000217e:	8526                	mv	a0,s1
    80002180:	00000097          	auipc	ra,0x0
    80002184:	ed4080e7          	jalr	-300(ra) # 80002054 <freeproc>
    release(&p->lock);
    80002188:	8526                	mv	a0,s1
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	aec080e7          	jalr	-1300(ra) # 80000c76 <release>
    return 0;
    80002192:	84ca                	mv	s1,s2
    80002194:	b7d1                	j	80002158 <allocproc+0xac>

0000000080002196 <userinit>:
{
    80002196:	1101                	addi	sp,sp,-32
    80002198:	ec06                	sd	ra,24(sp)
    8000219a:	e822                	sd	s0,16(sp)
    8000219c:	e426                	sd	s1,8(sp)
    8000219e:	1000                	addi	s0,sp,32
  p = allocproc();
    800021a0:	00000097          	auipc	ra,0x0
    800021a4:	f0c080e7          	jalr	-244(ra) # 800020ac <allocproc>
    800021a8:	84aa                	mv	s1,a0
  initproc = p;
    800021aa:	00007797          	auipc	a5,0x7
    800021ae:	e6a7bf23          	sd	a0,-386(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800021b2:	03400613          	li	a2,52
    800021b6:	00006597          	auipc	a1,0x6
    800021ba:	79a58593          	addi	a1,a1,1946 # 80008950 <initcode>
    800021be:	6928                	ld	a0,80(a0)
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	0b0080e7          	jalr	176(ra) # 80001270 <uvminit>
  p->sz = PGSIZE;
    800021c8:	6785                	lui	a5,0x1
    800021ca:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800021cc:	6cb8                	ld	a4,88(s1)
    800021ce:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800021d2:	6cb8                	ld	a4,88(s1)
    800021d4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800021d6:	4641                	li	a2,16
    800021d8:	00006597          	auipc	a1,0x6
    800021dc:	0b858593          	addi	a1,a1,184 # 80008290 <digits+0x250>
    800021e0:	15848513          	addi	a0,s1,344
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	c2c080e7          	jalr	-980(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    800021ec:	00006517          	auipc	a0,0x6
    800021f0:	0b450513          	addi	a0,a0,180 # 800082a0 <digits+0x260>
    800021f4:	00002097          	auipc	ra,0x2
    800021f8:	236080e7          	jalr	566(ra) # 8000442a <namei>
    800021fc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002200:	478d                	li	a5,3
    80002202:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	a70080e7          	jalr	-1424(ra) # 80000c76 <release>
}
    8000220e:	60e2                	ld	ra,24(sp)
    80002210:	6442                	ld	s0,16(sp)
    80002212:	64a2                	ld	s1,8(sp)
    80002214:	6105                	addi	sp,sp,32
    80002216:	8082                	ret

0000000080002218 <growproc>:
{
    80002218:	1101                	addi	sp,sp,-32
    8000221a:	ec06                	sd	ra,24(sp)
    8000221c:	e822                	sd	s0,16(sp)
    8000221e:	e426                	sd	s1,8(sp)
    80002220:	e04a                	sd	s2,0(sp)
    80002222:	1000                	addi	s0,sp,32
    80002224:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	c40080e7          	jalr	-960(ra) # 80001e66 <myproc>
    8000222e:	892a                	mv	s2,a0
  sz = p->sz;
    80002230:	652c                	ld	a1,72(a0)
    80002232:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002236:	00904f63          	bgtz	s1,80002254 <growproc+0x3c>
  } else if(n < 0){
    8000223a:	0204cc63          	bltz	s1,80002272 <growproc+0x5a>
  p->sz = sz;
    8000223e:	1602                	slli	a2,a2,0x20
    80002240:	9201                	srli	a2,a2,0x20
    80002242:	04c93423          	sd	a2,72(s2)
  return 0;
    80002246:	4501                	li	a0,0
}
    80002248:	60e2                	ld	ra,24(sp)
    8000224a:	6442                	ld	s0,16(sp)
    8000224c:	64a2                	ld	s1,8(sp)
    8000224e:	6902                	ld	s2,0(sp)
    80002250:	6105                	addi	sp,sp,32
    80002252:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002254:	9e25                	addw	a2,a2,s1
    80002256:	1602                	slli	a2,a2,0x20
    80002258:	9201                	srli	a2,a2,0x20
    8000225a:	1582                	slli	a1,a1,0x20
    8000225c:	9181                	srli	a1,a1,0x20
    8000225e:	6928                	ld	a0,80(a0)
    80002260:	00000097          	auipc	ra,0x0
    80002264:	85e080e7          	jalr	-1954(ra) # 80001abe <uvmalloc>
    80002268:	0005061b          	sext.w	a2,a0
    8000226c:	fa69                	bnez	a2,8000223e <growproc+0x26>
      return -1;
    8000226e:	557d                	li	a0,-1
    80002270:	bfe1                	j	80002248 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002272:	9e25                	addw	a2,a2,s1
    80002274:	1602                	slli	a2,a2,0x20
    80002276:	9201                	srli	a2,a2,0x20
    80002278:	1582                	slli	a1,a1,0x20
    8000227a:	9181                	srli	a1,a1,0x20
    8000227c:	6928                	ld	a0,80(a0)
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	7f8080e7          	jalr	2040(ra) # 80001a76 <uvmdealloc>
    80002286:	0005061b          	sext.w	a2,a0
    8000228a:	bf55                	j	8000223e <growproc+0x26>

000000008000228c <fork>:
{
    8000228c:	715d                	addi	sp,sp,-80
    8000228e:	e486                	sd	ra,72(sp)
    80002290:	e0a2                	sd	s0,64(sp)
    80002292:	fc26                	sd	s1,56(sp)
    80002294:	f84a                	sd	s2,48(sp)
    80002296:	f44e                	sd	s3,40(sp)
    80002298:	f052                	sd	s4,32(sp)
    8000229a:	ec56                	sd	s5,24(sp)
    8000229c:	e85a                	sd	s6,16(sp)
    8000229e:	e45e                	sd	s7,8(sp)
    800022a0:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    800022a2:	00000097          	auipc	ra,0x0
    800022a6:	bc4080e7          	jalr	-1084(ra) # 80001e66 <myproc>
    800022aa:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800022ac:	00000097          	auipc	ra,0x0
    800022b0:	e00080e7          	jalr	-512(ra) # 800020ac <allocproc>
    800022b4:	1a050963          	beqz	a0,80002466 <fork+0x1da>
    800022b8:	89aa                	mv	s3,a0
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    800022ba:	170a8493          	addi	s1,s5,368
    800022be:	570a8a13          	addi	s4,s5,1392
    800022c2:	8726                	mv	a4,s1
    int index = (int) (pg - p->pages);
    800022c4:	409707b3          	sub	a5,a4,s1
    800022c8:	8795                	srai	a5,a5,0x5
    800022ca:	2781                	sext.w	a5,a5
    np->pages[index].offset = pg->offset;
    800022cc:	4b54                	lw	a3,20(a4)
    800022ce:	0796                	slli	a5,a5,0x5
    800022d0:	97ce                	add	a5,a5,s3
    800022d2:	18d7a223          	sw	a3,388(a5) # 1184 <_entry-0x7fffee7c>
    np->pages[index].on_disk = pg->on_disk;
    800022d6:	4b14                	lw	a3,16(a4)
    800022d8:	18d7a023          	sw	a3,384(a5)
    np->pages[index].used = pg->used;
    800022dc:	4f14                	lw	a3,24(a4)
    800022de:	18d7a423          	sw	a3,392(a5)
    np->pages[index].va = pg->va;
    800022e2:	6714                	ld	a3,8(a4)
    800022e4:	16d7bc23          	sd	a3,376(a5)
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    800022e8:	02070713          	addi	a4,a4,32
    800022ec:	fd471ce3          	bne	a4,s4,800022c4 <fork+0x38>
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800022f0:	048ab603          	ld	a2,72(s5)
    800022f4:	0509b583          	ld	a1,80(s3)
    800022f8:	050ab503          	ld	a0,80(s5)
    800022fc:	00000097          	auipc	ra,0x0
    80002300:	8f0080e7          	jalr	-1808(ra) # 80001bec <uvmcopy>
    80002304:	04054863          	bltz	a0,80002354 <fork+0xc8>
  np->sz = p->sz;
    80002308:	048ab783          	ld	a5,72(s5)
    8000230c:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002310:	058ab683          	ld	a3,88(s5)
    80002314:	87b6                	mv	a5,a3
    80002316:	0589b703          	ld	a4,88(s3)
    8000231a:	12068693          	addi	a3,a3,288
    8000231e:	0007b803          	ld	a6,0(a5)
    80002322:	6788                	ld	a0,8(a5)
    80002324:	6b8c                	ld	a1,16(a5)
    80002326:	6f90                	ld	a2,24(a5)
    80002328:	01073023          	sd	a6,0(a4)
    8000232c:	e708                	sd	a0,8(a4)
    8000232e:	eb0c                	sd	a1,16(a4)
    80002330:	ef10                	sd	a2,24(a4)
    80002332:	02078793          	addi	a5,a5,32
    80002336:	02070713          	addi	a4,a4,32
    8000233a:	fed792e3          	bne	a5,a3,8000231e <fork+0x92>
  np->trapframe->a0 = 0;
    8000233e:	0589b783          	ld	a5,88(s3)
    80002342:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002346:	0d0a8913          	addi	s2,s5,208
    8000234a:	0d098b13          	addi	s6,s3,208
    8000234e:	150a8b93          	addi	s7,s5,336
    80002352:	a00d                	j	80002374 <fork+0xe8>
    freeproc(np);
    80002354:	854e                	mv	a0,s3
    80002356:	00000097          	auipc	ra,0x0
    8000235a:	cfe080e7          	jalr	-770(ra) # 80002054 <freeproc>
    release(&np->lock);
    8000235e:	854e                	mv	a0,s3
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	916080e7          	jalr	-1770(ra) # 80000c76 <release>
    return -1;
    80002368:	5b7d                	li	s6,-1
    8000236a:	a849                	j	800023fc <fork+0x170>
  for(i = 0; i < NOFILE; i++)
    8000236c:	0921                	addi	s2,s2,8
    8000236e:	0b21                	addi	s6,s6,8
    80002370:	01790c63          	beq	s2,s7,80002388 <fork+0xfc>
    if(p->ofile[i])
    80002374:	00093503          	ld	a0,0(s2)
    80002378:	d975                	beqz	a0,8000236c <fork+0xe0>
      np->ofile[i] = filedup(p->ofile[i]);
    8000237a:	00003097          	auipc	ra,0x3
    8000237e:	a92080e7          	jalr	-1390(ra) # 80004e0c <filedup>
    80002382:	00ab3023          	sd	a0,0(s6)
    80002386:	b7dd                	j	8000236c <fork+0xe0>
  np->cwd = idup(p->cwd);
    80002388:	150ab503          	ld	a0,336(s5)
    8000238c:	00002097          	auipc	ra,0x2
    80002390:	8aa080e7          	jalr	-1878(ra) # 80003c36 <idup>
    80002394:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002398:	4641                	li	a2,16
    8000239a:	158a8593          	addi	a1,s5,344
    8000239e:	15898513          	addi	a0,s3,344
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	a6e080e7          	jalr	-1426(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    800023aa:	0309ab03          	lw	s6,48(s3)
  release(&np->lock);
    800023ae:	854e                	mv	a0,s3
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8c6080e7          	jalr	-1850(ra) # 80000c76 <release>
  acquire(&wait_lock);
    800023b8:	0000f917          	auipc	s2,0xf
    800023bc:	f0090913          	addi	s2,s2,-256 # 800112b8 <wait_lock>
    800023c0:	854a                	mv	a0,s2
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	800080e7          	jalr	-2048(ra) # 80000bc2 <acquire>
  np->parent = p;
    800023ca:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800023ce:	854a                	mv	a0,s2
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	8a6080e7          	jalr	-1882(ra) # 80000c76 <release>
  if (np->pid > 2)
    800023d8:	0309a703          	lw	a4,48(s3)
    800023dc:	4789                	li	a5,2
    800023de:	02e7cb63          	blt	a5,a4,80002414 <fork+0x188>
  acquire(&np->lock);
    800023e2:	854e                	mv	a0,s3
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	7de080e7          	jalr	2014(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    800023ec:	478d                	li	a5,3
    800023ee:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800023f2:	854e                	mv	a0,s3
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	882080e7          	jalr	-1918(ra) # 80000c76 <release>
}
    800023fc:	855a                	mv	a0,s6
    800023fe:	60a6                	ld	ra,72(sp)
    80002400:	6406                	ld	s0,64(sp)
    80002402:	74e2                	ld	s1,56(sp)
    80002404:	7942                	ld	s2,48(sp)
    80002406:	79a2                	ld	s3,40(sp)
    80002408:	7a02                	ld	s4,32(sp)
    8000240a:	6ae2                	ld	s5,24(sp)
    8000240c:	6b42                	ld	s6,16(sp)
    8000240e:	6ba2                	ld	s7,8(sp)
    80002410:	6161                	addi	sp,sp,80
    80002412:	8082                	ret
    createSwapFile(np);
    80002414:	854e                	mv	a0,s3
    80002416:	00002097          	auipc	ra,0x2
    8000241a:	268080e7          	jalr	616(ra) # 8000467e <createSwapFile>
    for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    8000241e:	a029                	j	80002428 <fork+0x19c>
    80002420:	02048493          	addi	s1,s1,32
    80002424:	fb448fe3          	beq	s1,s4,800023e2 <fork+0x156>
      if (pg->used && pg->on_disk)
    80002428:	4c9c                	lw	a5,24(s1)
    8000242a:	dbfd                	beqz	a5,80002420 <fork+0x194>
    8000242c:	489c                	lw	a5,16(s1)
    8000242e:	dbed                	beqz	a5,80002420 <fork+0x194>
        char* mem = kalloc();
    80002430:	ffffe097          	auipc	ra,0xffffe
    80002434:	6a2080e7          	jalr	1698(ra) # 80000ad2 <kalloc>
    80002438:	892a                	mv	s2,a0
        readFromSwapFile(p, mem, pg->offset, PGSIZE);
    8000243a:	6685                	lui	a3,0x1
    8000243c:	48d0                	lw	a2,20(s1)
    8000243e:	85aa                	mv	a1,a0
    80002440:	8556                	mv	a0,s5
    80002442:	00002097          	auipc	ra,0x2
    80002446:	346080e7          	jalr	838(ra) # 80004788 <readFromSwapFile>
        writeToSwapFile(np, mem, pg->offset, PGSIZE);
    8000244a:	6685                	lui	a3,0x1
    8000244c:	48d0                	lw	a2,20(s1)
    8000244e:	85ca                	mv	a1,s2
    80002450:	854e                	mv	a0,s3
    80002452:	00002097          	auipc	ra,0x2
    80002456:	312080e7          	jalr	786(ra) # 80004764 <writeToSwapFile>
        kfree(mem);
    8000245a:	854a                	mv	a0,s2
    8000245c:	ffffe097          	auipc	ra,0xffffe
    80002460:	57a080e7          	jalr	1402(ra) # 800009d6 <kfree>
    80002464:	bf75                	j	80002420 <fork+0x194>
    return -1;
    80002466:	5b7d                	li	s6,-1
    80002468:	bf51                	j	800023fc <fork+0x170>

000000008000246a <scheduler>:
{
    8000246a:	7139                	addi	sp,sp,-64
    8000246c:	fc06                	sd	ra,56(sp)
    8000246e:	f822                	sd	s0,48(sp)
    80002470:	f426                	sd	s1,40(sp)
    80002472:	f04a                	sd	s2,32(sp)
    80002474:	ec4e                	sd	s3,24(sp)
    80002476:	e852                	sd	s4,16(sp)
    80002478:	e456                	sd	s5,8(sp)
    8000247a:	e05a                	sd	s6,0(sp)
    8000247c:	0080                	addi	s0,sp,64
    8000247e:	8792                	mv	a5,tp
  int id = r_tp();
    80002480:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002482:	00779a93          	slli	s5,a5,0x7
    80002486:	0000f717          	auipc	a4,0xf
    8000248a:	e1a70713          	addi	a4,a4,-486 # 800112a0 <pid_lock>
    8000248e:	9756                	add	a4,a4,s5
    80002490:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002494:	0000f717          	auipc	a4,0xf
    80002498:	e4470713          	addi	a4,a4,-444 # 800112d8 <cpus+0x8>
    8000249c:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    8000249e:	498d                	li	s3,3
        p->state = RUNNING;
    800024a0:	4b11                	li	s6,4
        c->proc = p;
    800024a2:	079e                	slli	a5,a5,0x7
    800024a4:	0000fa17          	auipc	s4,0xf
    800024a8:	dfca0a13          	addi	s4,s4,-516 # 800112a0 <pid_lock>
    800024ac:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800024ae:	00025917          	auipc	s2,0x25
    800024b2:	e2290913          	addi	s2,s2,-478 # 800272d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024b6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024ba:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024be:	10079073          	csrw	sstatus,a5
    800024c2:	0000f497          	auipc	s1,0xf
    800024c6:	20e48493          	addi	s1,s1,526 # 800116d0 <proc>
    800024ca:	a811                	j	800024de <scheduler+0x74>
      release(&p->lock);
    800024cc:	8526                	mv	a0,s1
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	7a8080e7          	jalr	1960(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800024d6:	57048493          	addi	s1,s1,1392
    800024da:	fd248ee3          	beq	s1,s2,800024b6 <scheduler+0x4c>
      acquire(&p->lock);
    800024de:	8526                	mv	a0,s1
    800024e0:	ffffe097          	auipc	ra,0xffffe
    800024e4:	6e2080e7          	jalr	1762(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    800024e8:	4c9c                	lw	a5,24(s1)
    800024ea:	ff3791e3          	bne	a5,s3,800024cc <scheduler+0x62>
        p->state = RUNNING;
    800024ee:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800024f2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800024f6:	06048593          	addi	a1,s1,96
    800024fa:	8556                	mv	a0,s5
    800024fc:	00000097          	auipc	ra,0x0
    80002500:	640080e7          	jalr	1600(ra) # 80002b3c <swtch>
        c->proc = 0;
    80002504:	020a3823          	sd	zero,48(s4)
    80002508:	b7d1                	j	800024cc <scheduler+0x62>

000000008000250a <sched>:
{
    8000250a:	7179                	addi	sp,sp,-48
    8000250c:	f406                	sd	ra,40(sp)
    8000250e:	f022                	sd	s0,32(sp)
    80002510:	ec26                	sd	s1,24(sp)
    80002512:	e84a                	sd	s2,16(sp)
    80002514:	e44e                	sd	s3,8(sp)
    80002516:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002518:	00000097          	auipc	ra,0x0
    8000251c:	94e080e7          	jalr	-1714(ra) # 80001e66 <myproc>
    80002520:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	626080e7          	jalr	1574(ra) # 80000b48 <holding>
    8000252a:	c93d                	beqz	a0,800025a0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000252c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000252e:	2781                	sext.w	a5,a5
    80002530:	079e                	slli	a5,a5,0x7
    80002532:	0000f717          	auipc	a4,0xf
    80002536:	d6e70713          	addi	a4,a4,-658 # 800112a0 <pid_lock>
    8000253a:	97ba                	add	a5,a5,a4
    8000253c:	0a87a703          	lw	a4,168(a5)
    80002540:	4785                	li	a5,1
    80002542:	06f71763          	bne	a4,a5,800025b0 <sched+0xa6>
  if(p->state == RUNNING)
    80002546:	4c98                	lw	a4,24(s1)
    80002548:	4791                	li	a5,4
    8000254a:	06f70b63          	beq	a4,a5,800025c0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000254e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002552:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002554:	efb5                	bnez	a5,800025d0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002556:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002558:	0000f917          	auipc	s2,0xf
    8000255c:	d4890913          	addi	s2,s2,-696 # 800112a0 <pid_lock>
    80002560:	2781                	sext.w	a5,a5
    80002562:	079e                	slli	a5,a5,0x7
    80002564:	97ca                	add	a5,a5,s2
    80002566:	0ac7a983          	lw	s3,172(a5)
    8000256a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000256c:	2781                	sext.w	a5,a5
    8000256e:	079e                	slli	a5,a5,0x7
    80002570:	0000f597          	auipc	a1,0xf
    80002574:	d6858593          	addi	a1,a1,-664 # 800112d8 <cpus+0x8>
    80002578:	95be                	add	a1,a1,a5
    8000257a:	06048513          	addi	a0,s1,96
    8000257e:	00000097          	auipc	ra,0x0
    80002582:	5be080e7          	jalr	1470(ra) # 80002b3c <swtch>
    80002586:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002588:	2781                	sext.w	a5,a5
    8000258a:	079e                	slli	a5,a5,0x7
    8000258c:	97ca                	add	a5,a5,s2
    8000258e:	0b37a623          	sw	s3,172(a5)
}
    80002592:	70a2                	ld	ra,40(sp)
    80002594:	7402                	ld	s0,32(sp)
    80002596:	64e2                	ld	s1,24(sp)
    80002598:	6942                	ld	s2,16(sp)
    8000259a:	69a2                	ld	s3,8(sp)
    8000259c:	6145                	addi	sp,sp,48
    8000259e:	8082                	ret
    panic("sched p->lock");
    800025a0:	00006517          	auipc	a0,0x6
    800025a4:	d0850513          	addi	a0,a0,-760 # 800082a8 <digits+0x268>
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	f82080e7          	jalr	-126(ra) # 8000052a <panic>
    panic("sched locks");
    800025b0:	00006517          	auipc	a0,0x6
    800025b4:	d0850513          	addi	a0,a0,-760 # 800082b8 <digits+0x278>
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	f72080e7          	jalr	-142(ra) # 8000052a <panic>
    panic("sched running");
    800025c0:	00006517          	auipc	a0,0x6
    800025c4:	d0850513          	addi	a0,a0,-760 # 800082c8 <digits+0x288>
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	f62080e7          	jalr	-158(ra) # 8000052a <panic>
    panic("sched interruptible");
    800025d0:	00006517          	auipc	a0,0x6
    800025d4:	d0850513          	addi	a0,a0,-760 # 800082d8 <digits+0x298>
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	f52080e7          	jalr	-174(ra) # 8000052a <panic>

00000000800025e0 <yield>:
{
    800025e0:	1101                	addi	sp,sp,-32
    800025e2:	ec06                	sd	ra,24(sp)
    800025e4:	e822                	sd	s0,16(sp)
    800025e6:	e426                	sd	s1,8(sp)
    800025e8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800025ea:	00000097          	auipc	ra,0x0
    800025ee:	87c080e7          	jalr	-1924(ra) # 80001e66 <myproc>
    800025f2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	5ce080e7          	jalr	1486(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    800025fc:	478d                	li	a5,3
    800025fe:	cc9c                	sw	a5,24(s1)
  sched();
    80002600:	00000097          	auipc	ra,0x0
    80002604:	f0a080e7          	jalr	-246(ra) # 8000250a <sched>
  release(&p->lock);
    80002608:	8526                	mv	a0,s1
    8000260a:	ffffe097          	auipc	ra,0xffffe
    8000260e:	66c080e7          	jalr	1644(ra) # 80000c76 <release>
}
    80002612:	60e2                	ld	ra,24(sp)
    80002614:	6442                	ld	s0,16(sp)
    80002616:	64a2                	ld	s1,8(sp)
    80002618:	6105                	addi	sp,sp,32
    8000261a:	8082                	ret

000000008000261c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000261c:	7179                	addi	sp,sp,-48
    8000261e:	f406                	sd	ra,40(sp)
    80002620:	f022                	sd	s0,32(sp)
    80002622:	ec26                	sd	s1,24(sp)
    80002624:	e84a                	sd	s2,16(sp)
    80002626:	e44e                	sd	s3,8(sp)
    80002628:	1800                	addi	s0,sp,48
    8000262a:	89aa                	mv	s3,a0
    8000262c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000262e:	00000097          	auipc	ra,0x0
    80002632:	838080e7          	jalr	-1992(ra) # 80001e66 <myproc>
    80002636:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	58a080e7          	jalr	1418(ra) # 80000bc2 <acquire>
  release(lk);
    80002640:	854a                	mv	a0,s2
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	634080e7          	jalr	1588(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    8000264a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000264e:	4789                	li	a5,2
    80002650:	cc9c                	sw	a5,24(s1)

  sched();
    80002652:	00000097          	auipc	ra,0x0
    80002656:	eb8080e7          	jalr	-328(ra) # 8000250a <sched>

  // Tidy up.
  p->chan = 0;
    8000265a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000265e:	8526                	mv	a0,s1
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	616080e7          	jalr	1558(ra) # 80000c76 <release>
  acquire(lk);
    80002668:	854a                	mv	a0,s2
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	558080e7          	jalr	1368(ra) # 80000bc2 <acquire>
}
    80002672:	70a2                	ld	ra,40(sp)
    80002674:	7402                	ld	s0,32(sp)
    80002676:	64e2                	ld	s1,24(sp)
    80002678:	6942                	ld	s2,16(sp)
    8000267a:	69a2                	ld	s3,8(sp)
    8000267c:	6145                	addi	sp,sp,48
    8000267e:	8082                	ret

0000000080002680 <wait>:
{
    80002680:	715d                	addi	sp,sp,-80
    80002682:	e486                	sd	ra,72(sp)
    80002684:	e0a2                	sd	s0,64(sp)
    80002686:	fc26                	sd	s1,56(sp)
    80002688:	f84a                	sd	s2,48(sp)
    8000268a:	f44e                	sd	s3,40(sp)
    8000268c:	f052                	sd	s4,32(sp)
    8000268e:	ec56                	sd	s5,24(sp)
    80002690:	e85a                	sd	s6,16(sp)
    80002692:	e45e                	sd	s7,8(sp)
    80002694:	e062                	sd	s8,0(sp)
    80002696:	0880                	addi	s0,sp,80
    80002698:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000269a:	fffff097          	auipc	ra,0xfffff
    8000269e:	7cc080e7          	jalr	1996(ra) # 80001e66 <myproc>
    800026a2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026a4:	0000f517          	auipc	a0,0xf
    800026a8:	c1450513          	addi	a0,a0,-1004 # 800112b8 <wait_lock>
    800026ac:	ffffe097          	auipc	ra,0xffffe
    800026b0:	516080e7          	jalr	1302(ra) # 80000bc2 <acquire>
    havekids = 0;
    800026b4:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800026b6:	4a15                	li	s4,5
        havekids = 1;
    800026b8:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800026ba:	00025997          	auipc	s3,0x25
    800026be:	c1698993          	addi	s3,s3,-1002 # 800272d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026c2:	0000fc17          	auipc	s8,0xf
    800026c6:	bf6c0c13          	addi	s8,s8,-1034 # 800112b8 <wait_lock>
    havekids = 0;
    800026ca:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800026cc:	0000f497          	auipc	s1,0xf
    800026d0:	00448493          	addi	s1,s1,4 # 800116d0 <proc>
    800026d4:	a0bd                	j	80002742 <wait+0xc2>
          pid = np->pid;
    800026d6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800026da:	000b0e63          	beqz	s6,800026f6 <wait+0x76>
    800026de:	4691                	li	a3,4
    800026e0:	02c48613          	addi	a2,s1,44
    800026e4:	85da                	mv	a1,s6
    800026e6:	05093503          	ld	a0,80(s2)
    800026ea:	fffff097          	auipc	ra,0xfffff
    800026ee:	c94080e7          	jalr	-876(ra) # 8000137e <copyout>
    800026f2:	02054563          	bltz	a0,8000271c <wait+0x9c>
          freeproc(np);
    800026f6:	8526                	mv	a0,s1
    800026f8:	00000097          	auipc	ra,0x0
    800026fc:	95c080e7          	jalr	-1700(ra) # 80002054 <freeproc>
          release(&np->lock);
    80002700:	8526                	mv	a0,s1
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	574080e7          	jalr	1396(ra) # 80000c76 <release>
          release(&wait_lock);
    8000270a:	0000f517          	auipc	a0,0xf
    8000270e:	bae50513          	addi	a0,a0,-1106 # 800112b8 <wait_lock>
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	564080e7          	jalr	1380(ra) # 80000c76 <release>
          return pid;
    8000271a:	a09d                	j	80002780 <wait+0x100>
            release(&np->lock);
    8000271c:	8526                	mv	a0,s1
    8000271e:	ffffe097          	auipc	ra,0xffffe
    80002722:	558080e7          	jalr	1368(ra) # 80000c76 <release>
            release(&wait_lock);
    80002726:	0000f517          	auipc	a0,0xf
    8000272a:	b9250513          	addi	a0,a0,-1134 # 800112b8 <wait_lock>
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	548080e7          	jalr	1352(ra) # 80000c76 <release>
            return -1;
    80002736:	59fd                	li	s3,-1
    80002738:	a0a1                	j	80002780 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000273a:	57048493          	addi	s1,s1,1392
    8000273e:	03348463          	beq	s1,s3,80002766 <wait+0xe6>
      if(np->parent == p){
    80002742:	7c9c                	ld	a5,56(s1)
    80002744:	ff279be3          	bne	a5,s2,8000273a <wait+0xba>
        acquire(&np->lock);
    80002748:	8526                	mv	a0,s1
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	478080e7          	jalr	1144(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002752:	4c9c                	lw	a5,24(s1)
    80002754:	f94781e3          	beq	a5,s4,800026d6 <wait+0x56>
        release(&np->lock);
    80002758:	8526                	mv	a0,s1
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	51c080e7          	jalr	1308(ra) # 80000c76 <release>
        havekids = 1;
    80002762:	8756                	mv	a4,s5
    80002764:	bfd9                	j	8000273a <wait+0xba>
    if(!havekids || p->killed){
    80002766:	c701                	beqz	a4,8000276e <wait+0xee>
    80002768:	02892783          	lw	a5,40(s2)
    8000276c:	c79d                	beqz	a5,8000279a <wait+0x11a>
      release(&wait_lock);
    8000276e:	0000f517          	auipc	a0,0xf
    80002772:	b4a50513          	addi	a0,a0,-1206 # 800112b8 <wait_lock>
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	500080e7          	jalr	1280(ra) # 80000c76 <release>
      return -1;
    8000277e:	59fd                	li	s3,-1
}
    80002780:	854e                	mv	a0,s3
    80002782:	60a6                	ld	ra,72(sp)
    80002784:	6406                	ld	s0,64(sp)
    80002786:	74e2                	ld	s1,56(sp)
    80002788:	7942                	ld	s2,48(sp)
    8000278a:	79a2                	ld	s3,40(sp)
    8000278c:	7a02                	ld	s4,32(sp)
    8000278e:	6ae2                	ld	s5,24(sp)
    80002790:	6b42                	ld	s6,16(sp)
    80002792:	6ba2                	ld	s7,8(sp)
    80002794:	6c02                	ld	s8,0(sp)
    80002796:	6161                	addi	sp,sp,80
    80002798:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000279a:	85e2                	mv	a1,s8
    8000279c:	854a                	mv	a0,s2
    8000279e:	00000097          	auipc	ra,0x0
    800027a2:	e7e080e7          	jalr	-386(ra) # 8000261c <sleep>
    havekids = 0;
    800027a6:	b715                	j	800026ca <wait+0x4a>

00000000800027a8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800027a8:	7139                	addi	sp,sp,-64
    800027aa:	fc06                	sd	ra,56(sp)
    800027ac:	f822                	sd	s0,48(sp)
    800027ae:	f426                	sd	s1,40(sp)
    800027b0:	f04a                	sd	s2,32(sp)
    800027b2:	ec4e                	sd	s3,24(sp)
    800027b4:	e852                	sd	s4,16(sp)
    800027b6:	e456                	sd	s5,8(sp)
    800027b8:	0080                	addi	s0,sp,64
    800027ba:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800027bc:	0000f497          	auipc	s1,0xf
    800027c0:	f1448493          	addi	s1,s1,-236 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800027c4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800027c6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800027c8:	00025917          	auipc	s2,0x25
    800027cc:	b0890913          	addi	s2,s2,-1272 # 800272d0 <tickslock>
    800027d0:	a811                	j	800027e4 <wakeup+0x3c>
      }
      release(&p->lock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	4a2080e7          	jalr	1186(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800027dc:	57048493          	addi	s1,s1,1392
    800027e0:	03248663          	beq	s1,s2,8000280c <wakeup+0x64>
    if(p != myproc()){
    800027e4:	fffff097          	auipc	ra,0xfffff
    800027e8:	682080e7          	jalr	1666(ra) # 80001e66 <myproc>
    800027ec:	fea488e3          	beq	s1,a0,800027dc <wakeup+0x34>
      acquire(&p->lock);
    800027f0:	8526                	mv	a0,s1
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	3d0080e7          	jalr	976(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800027fa:	4c9c                	lw	a5,24(s1)
    800027fc:	fd379be3          	bne	a5,s3,800027d2 <wakeup+0x2a>
    80002800:	709c                	ld	a5,32(s1)
    80002802:	fd4798e3          	bne	a5,s4,800027d2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002806:	0154ac23          	sw	s5,24(s1)
    8000280a:	b7e1                	j	800027d2 <wakeup+0x2a>
    }
  }
}
    8000280c:	70e2                	ld	ra,56(sp)
    8000280e:	7442                	ld	s0,48(sp)
    80002810:	74a2                	ld	s1,40(sp)
    80002812:	7902                	ld	s2,32(sp)
    80002814:	69e2                	ld	s3,24(sp)
    80002816:	6a42                	ld	s4,16(sp)
    80002818:	6aa2                	ld	s5,8(sp)
    8000281a:	6121                	addi	sp,sp,64
    8000281c:	8082                	ret

000000008000281e <reparent>:
{
    8000281e:	7179                	addi	sp,sp,-48
    80002820:	f406                	sd	ra,40(sp)
    80002822:	f022                	sd	s0,32(sp)
    80002824:	ec26                	sd	s1,24(sp)
    80002826:	e84a                	sd	s2,16(sp)
    80002828:	e44e                	sd	s3,8(sp)
    8000282a:	e052                	sd	s4,0(sp)
    8000282c:	1800                	addi	s0,sp,48
    8000282e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002830:	0000f497          	auipc	s1,0xf
    80002834:	ea048493          	addi	s1,s1,-352 # 800116d0 <proc>
      pp->parent = initproc;
    80002838:	00006a17          	auipc	s4,0x6
    8000283c:	7f0a0a13          	addi	s4,s4,2032 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002840:	00025997          	auipc	s3,0x25
    80002844:	a9098993          	addi	s3,s3,-1392 # 800272d0 <tickslock>
    80002848:	a029                	j	80002852 <reparent+0x34>
    8000284a:	57048493          	addi	s1,s1,1392
    8000284e:	01348d63          	beq	s1,s3,80002868 <reparent+0x4a>
    if(pp->parent == p){
    80002852:	7c9c                	ld	a5,56(s1)
    80002854:	ff279be3          	bne	a5,s2,8000284a <reparent+0x2c>
      pp->parent = initproc;
    80002858:	000a3503          	ld	a0,0(s4)
    8000285c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000285e:	00000097          	auipc	ra,0x0
    80002862:	f4a080e7          	jalr	-182(ra) # 800027a8 <wakeup>
    80002866:	b7d5                	j	8000284a <reparent+0x2c>
}
    80002868:	70a2                	ld	ra,40(sp)
    8000286a:	7402                	ld	s0,32(sp)
    8000286c:	64e2                	ld	s1,24(sp)
    8000286e:	6942                	ld	s2,16(sp)
    80002870:	69a2                	ld	s3,8(sp)
    80002872:	6a02                	ld	s4,0(sp)
    80002874:	6145                	addi	sp,sp,48
    80002876:	8082                	ret

0000000080002878 <exit>:
{
    80002878:	7179                	addi	sp,sp,-48
    8000287a:	f406                	sd	ra,40(sp)
    8000287c:	f022                	sd	s0,32(sp)
    8000287e:	ec26                	sd	s1,24(sp)
    80002880:	e84a                	sd	s2,16(sp)
    80002882:	e44e                	sd	s3,8(sp)
    80002884:	e052                	sd	s4,0(sp)
    80002886:	1800                	addi	s0,sp,48
    80002888:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000288a:	fffff097          	auipc	ra,0xfffff
    8000288e:	5dc080e7          	jalr	1500(ra) # 80001e66 <myproc>
    80002892:	89aa                	mv	s3,a0
  if(p == initproc)
    80002894:	00006797          	auipc	a5,0x6
    80002898:	7947b783          	ld	a5,1940(a5) # 80009028 <initproc>
    8000289c:	0d050493          	addi	s1,a0,208
    800028a0:	15050913          	addi	s2,a0,336
    800028a4:	00a79d63          	bne	a5,a0,800028be <exit+0x46>
    panic("init exiting");
    800028a8:	00006517          	auipc	a0,0x6
    800028ac:	a4850513          	addi	a0,a0,-1464 # 800082f0 <digits+0x2b0>
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	c7a080e7          	jalr	-902(ra) # 8000052a <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800028b8:	04a1                	addi	s1,s1,8
    800028ba:	01248b63          	beq	s1,s2,800028d0 <exit+0x58>
    if(p->ofile[fd]){
    800028be:	6088                	ld	a0,0(s1)
    800028c0:	dd65                	beqz	a0,800028b8 <exit+0x40>
      fileclose(f);
    800028c2:	00002097          	auipc	ra,0x2
    800028c6:	59c080e7          	jalr	1436(ra) # 80004e5e <fileclose>
      p->ofile[fd] = 0;
    800028ca:	0004b023          	sd	zero,0(s1)
    800028ce:	b7ed                	j	800028b8 <exit+0x40>
  for (struct page* pg = p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)
    800028d0:	17098793          	addi	a5,s3,368
    800028d4:	57098713          	addi	a4,s3,1392
    pg->offset = 0;
    800028d8:	0007aa23          	sw	zero,20(a5)
    pg->on_disk = 0;
    800028dc:	0007a823          	sw	zero,16(a5)
    pg->used = 0;
    800028e0:	0007ac23          	sw	zero,24(a5)
    pg->va = 0;
    800028e4:	0007b423          	sd	zero,8(a5)
  for (struct page* pg = p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)
    800028e8:	02078793          	addi	a5,a5,32
    800028ec:	fef716e3          	bne	a4,a5,800028d8 <exit+0x60>
  begin_op();
    800028f0:	00002097          	auipc	ra,0x2
    800028f4:	0a2080e7          	jalr	162(ra) # 80004992 <begin_op>
  iput(p->cwd);
    800028f8:	1509b503          	ld	a0,336(s3)
    800028fc:	00001097          	auipc	ra,0x1
    80002900:	532080e7          	jalr	1330(ra) # 80003e2e <iput>
  end_op();
    80002904:	00002097          	auipc	ra,0x2
    80002908:	10e080e7          	jalr	270(ra) # 80004a12 <end_op>
  p->cwd = 0;
    8000290c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002910:	0000f497          	auipc	s1,0xf
    80002914:	9a848493          	addi	s1,s1,-1624 # 800112b8 <wait_lock>
    80002918:	8526                	mv	a0,s1
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	2a8080e7          	jalr	680(ra) # 80000bc2 <acquire>
  reparent(p);
    80002922:	854e                	mv	a0,s3
    80002924:	00000097          	auipc	ra,0x0
    80002928:	efa080e7          	jalr	-262(ra) # 8000281e <reparent>
  wakeup(p->parent);
    8000292c:	0389b503          	ld	a0,56(s3)
    80002930:	00000097          	auipc	ra,0x0
    80002934:	e78080e7          	jalr	-392(ra) # 800027a8 <wakeup>
  acquire(&p->lock);
    80002938:	854e                	mv	a0,s3
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	288080e7          	jalr	648(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002942:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002946:	4795                	li	a5,5
    80002948:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000294c:	8526                	mv	a0,s1
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	328080e7          	jalr	808(ra) # 80000c76 <release>
  sched();
    80002956:	00000097          	auipc	ra,0x0
    8000295a:	bb4080e7          	jalr	-1100(ra) # 8000250a <sched>
  panic("zombie exit");
    8000295e:	00006517          	auipc	a0,0x6
    80002962:	9a250513          	addi	a0,a0,-1630 # 80008300 <digits+0x2c0>
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	bc4080e7          	jalr	-1084(ra) # 8000052a <panic>

000000008000296e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000296e:	7179                	addi	sp,sp,-48
    80002970:	f406                	sd	ra,40(sp)
    80002972:	f022                	sd	s0,32(sp)
    80002974:	ec26                	sd	s1,24(sp)
    80002976:	e84a                	sd	s2,16(sp)
    80002978:	e44e                	sd	s3,8(sp)
    8000297a:	1800                	addi	s0,sp,48
    8000297c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000297e:	0000f497          	auipc	s1,0xf
    80002982:	d5248493          	addi	s1,s1,-686 # 800116d0 <proc>
    80002986:	00025997          	auipc	s3,0x25
    8000298a:	94a98993          	addi	s3,s3,-1718 # 800272d0 <tickslock>
    acquire(&p->lock);
    8000298e:	8526                	mv	a0,s1
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	232080e7          	jalr	562(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002998:	589c                	lw	a5,48(s1)
    8000299a:	01278d63          	beq	a5,s2,800029b4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000299e:	8526                	mv	a0,s1
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	2d6080e7          	jalr	726(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800029a8:	57048493          	addi	s1,s1,1392
    800029ac:	ff3491e3          	bne	s1,s3,8000298e <kill+0x20>
  }
  return -1;
    800029b0:	557d                	li	a0,-1
    800029b2:	a829                	j	800029cc <kill+0x5e>
      p->killed = 1;
    800029b4:	4785                	li	a5,1
    800029b6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800029b8:	4c98                	lw	a4,24(s1)
    800029ba:	4789                	li	a5,2
    800029bc:	00f70f63          	beq	a4,a5,800029da <kill+0x6c>
      release(&p->lock);
    800029c0:	8526                	mv	a0,s1
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	2b4080e7          	jalr	692(ra) # 80000c76 <release>
      return 0;
    800029ca:	4501                	li	a0,0
}
    800029cc:	70a2                	ld	ra,40(sp)
    800029ce:	7402                	ld	s0,32(sp)
    800029d0:	64e2                	ld	s1,24(sp)
    800029d2:	6942                	ld	s2,16(sp)
    800029d4:	69a2                	ld	s3,8(sp)
    800029d6:	6145                	addi	sp,sp,48
    800029d8:	8082                	ret
        p->state = RUNNABLE;
    800029da:	478d                	li	a5,3
    800029dc:	cc9c                	sw	a5,24(s1)
    800029de:	b7cd                	j	800029c0 <kill+0x52>

00000000800029e0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800029e0:	7179                	addi	sp,sp,-48
    800029e2:	f406                	sd	ra,40(sp)
    800029e4:	f022                	sd	s0,32(sp)
    800029e6:	ec26                	sd	s1,24(sp)
    800029e8:	e84a                	sd	s2,16(sp)
    800029ea:	e44e                	sd	s3,8(sp)
    800029ec:	e052                	sd	s4,0(sp)
    800029ee:	1800                	addi	s0,sp,48
    800029f0:	84aa                	mv	s1,a0
    800029f2:	892e                	mv	s2,a1
    800029f4:	89b2                	mv	s3,a2
    800029f6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	46e080e7          	jalr	1134(ra) # 80001e66 <myproc>
  if(user_dst){
    80002a00:	c08d                	beqz	s1,80002a22 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002a02:	86d2                	mv	a3,s4
    80002a04:	864e                	mv	a2,s3
    80002a06:	85ca                	mv	a1,s2
    80002a08:	6928                	ld	a0,80(a0)
    80002a0a:	fffff097          	auipc	ra,0xfffff
    80002a0e:	974080e7          	jalr	-1676(ra) # 8000137e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a12:	70a2                	ld	ra,40(sp)
    80002a14:	7402                	ld	s0,32(sp)
    80002a16:	64e2                	ld	s1,24(sp)
    80002a18:	6942                	ld	s2,16(sp)
    80002a1a:	69a2                	ld	s3,8(sp)
    80002a1c:	6a02                	ld	s4,0(sp)
    80002a1e:	6145                	addi	sp,sp,48
    80002a20:	8082                	ret
    memmove((char *)dst, src, len);
    80002a22:	000a061b          	sext.w	a2,s4
    80002a26:	85ce                	mv	a1,s3
    80002a28:	854a                	mv	a0,s2
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	2f0080e7          	jalr	752(ra) # 80000d1a <memmove>
    return 0;
    80002a32:	8526                	mv	a0,s1
    80002a34:	bff9                	j	80002a12 <either_copyout+0x32>

0000000080002a36 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a36:	7179                	addi	sp,sp,-48
    80002a38:	f406                	sd	ra,40(sp)
    80002a3a:	f022                	sd	s0,32(sp)
    80002a3c:	ec26                	sd	s1,24(sp)
    80002a3e:	e84a                	sd	s2,16(sp)
    80002a40:	e44e                	sd	s3,8(sp)
    80002a42:	e052                	sd	s4,0(sp)
    80002a44:	1800                	addi	s0,sp,48
    80002a46:	892a                	mv	s2,a0
    80002a48:	84ae                	mv	s1,a1
    80002a4a:	89b2                	mv	s3,a2
    80002a4c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a4e:	fffff097          	auipc	ra,0xfffff
    80002a52:	418080e7          	jalr	1048(ra) # 80001e66 <myproc>
  if(user_src){
    80002a56:	c08d                	beqz	s1,80002a78 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002a58:	86d2                	mv	a3,s4
    80002a5a:	864e                	mv	a2,s3
    80002a5c:	85ca                	mv	a1,s2
    80002a5e:	6928                	ld	a0,80(a0)
    80002a60:	fffff097          	auipc	ra,0xfffff
    80002a64:	9aa080e7          	jalr	-1622(ra) # 8000140a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002a68:	70a2                	ld	ra,40(sp)
    80002a6a:	7402                	ld	s0,32(sp)
    80002a6c:	64e2                	ld	s1,24(sp)
    80002a6e:	6942                	ld	s2,16(sp)
    80002a70:	69a2                	ld	s3,8(sp)
    80002a72:	6a02                	ld	s4,0(sp)
    80002a74:	6145                	addi	sp,sp,48
    80002a76:	8082                	ret
    memmove(dst, (char*)src, len);
    80002a78:	000a061b          	sext.w	a2,s4
    80002a7c:	85ce                	mv	a1,s3
    80002a7e:	854a                	mv	a0,s2
    80002a80:	ffffe097          	auipc	ra,0xffffe
    80002a84:	29a080e7          	jalr	666(ra) # 80000d1a <memmove>
    return 0;
    80002a88:	8526                	mv	a0,s1
    80002a8a:	bff9                	j	80002a68 <either_copyin+0x32>

0000000080002a8c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002a8c:	715d                	addi	sp,sp,-80
    80002a8e:	e486                	sd	ra,72(sp)
    80002a90:	e0a2                	sd	s0,64(sp)
    80002a92:	fc26                	sd	s1,56(sp)
    80002a94:	f84a                	sd	s2,48(sp)
    80002a96:	f44e                	sd	s3,40(sp)
    80002a98:	f052                	sd	s4,32(sp)
    80002a9a:	ec56                	sd	s5,24(sp)
    80002a9c:	e85a                	sd	s6,16(sp)
    80002a9e:	e45e                	sd	s7,8(sp)
    80002aa0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002aa2:	00005517          	auipc	a0,0x5
    80002aa6:	6fe50513          	addi	a0,a0,1790 # 800081a0 <digits+0x160>
    80002aaa:	ffffe097          	auipc	ra,0xffffe
    80002aae:	aca080e7          	jalr	-1334(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ab2:	0000f497          	auipc	s1,0xf
    80002ab6:	d7648493          	addi	s1,s1,-650 # 80011828 <proc+0x158>
    80002aba:	00025917          	auipc	s2,0x25
    80002abe:	96e90913          	addi	s2,s2,-1682 # 80027428 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ac2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002ac4:	00006997          	auipc	s3,0x6
    80002ac8:	84c98993          	addi	s3,s3,-1972 # 80008310 <digits+0x2d0>
    printf("%d %s %s", p->pid, state, p->name);
    80002acc:	00006a97          	auipc	s5,0x6
    80002ad0:	84ca8a93          	addi	s5,s5,-1972 # 80008318 <digits+0x2d8>
    printf("\n");
    80002ad4:	00005a17          	auipc	s4,0x5
    80002ad8:	6cca0a13          	addi	s4,s4,1740 # 800081a0 <digits+0x160>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002adc:	00006b97          	auipc	s7,0x6
    80002ae0:	874b8b93          	addi	s7,s7,-1932 # 80008350 <states.0>
    80002ae4:	a00d                	j	80002b06 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002ae6:	ed86a583          	lw	a1,-296(a3) # ed8 <_entry-0x7ffff128>
    80002aea:	8556                	mv	a0,s5
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	a88080e7          	jalr	-1400(ra) # 80000574 <printf>
    printf("\n");
    80002af4:	8552                	mv	a0,s4
    80002af6:	ffffe097          	auipc	ra,0xffffe
    80002afa:	a7e080e7          	jalr	-1410(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002afe:	57048493          	addi	s1,s1,1392
    80002b02:	03248263          	beq	s1,s2,80002b26 <procdump+0x9a>
    if(p->state == UNUSED)
    80002b06:	86a6                	mv	a3,s1
    80002b08:	ec04a783          	lw	a5,-320(s1)
    80002b0c:	dbed                	beqz	a5,80002afe <procdump+0x72>
      state = "???";
    80002b0e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b10:	fcfb6be3          	bltu	s6,a5,80002ae6 <procdump+0x5a>
    80002b14:	02079713          	slli	a4,a5,0x20
    80002b18:	01d75793          	srli	a5,a4,0x1d
    80002b1c:	97de                	add	a5,a5,s7
    80002b1e:	6390                	ld	a2,0(a5)
    80002b20:	f279                	bnez	a2,80002ae6 <procdump+0x5a>
      state = "???";
    80002b22:	864e                	mv	a2,s3
    80002b24:	b7c9                	j	80002ae6 <procdump+0x5a>
  }
}
    80002b26:	60a6                	ld	ra,72(sp)
    80002b28:	6406                	ld	s0,64(sp)
    80002b2a:	74e2                	ld	s1,56(sp)
    80002b2c:	7942                	ld	s2,48(sp)
    80002b2e:	79a2                	ld	s3,40(sp)
    80002b30:	7a02                	ld	s4,32(sp)
    80002b32:	6ae2                	ld	s5,24(sp)
    80002b34:	6b42                	ld	s6,16(sp)
    80002b36:	6ba2                	ld	s7,8(sp)
    80002b38:	6161                	addi	sp,sp,80
    80002b3a:	8082                	ret

0000000080002b3c <swtch>:
    80002b3c:	00153023          	sd	ra,0(a0)
    80002b40:	00253423          	sd	sp,8(a0)
    80002b44:	e900                	sd	s0,16(a0)
    80002b46:	ed04                	sd	s1,24(a0)
    80002b48:	03253023          	sd	s2,32(a0)
    80002b4c:	03353423          	sd	s3,40(a0)
    80002b50:	03453823          	sd	s4,48(a0)
    80002b54:	03553c23          	sd	s5,56(a0)
    80002b58:	05653023          	sd	s6,64(a0)
    80002b5c:	05753423          	sd	s7,72(a0)
    80002b60:	05853823          	sd	s8,80(a0)
    80002b64:	05953c23          	sd	s9,88(a0)
    80002b68:	07a53023          	sd	s10,96(a0)
    80002b6c:	07b53423          	sd	s11,104(a0)
    80002b70:	0005b083          	ld	ra,0(a1)
    80002b74:	0085b103          	ld	sp,8(a1)
    80002b78:	6980                	ld	s0,16(a1)
    80002b7a:	6d84                	ld	s1,24(a1)
    80002b7c:	0205b903          	ld	s2,32(a1)
    80002b80:	0285b983          	ld	s3,40(a1)
    80002b84:	0305ba03          	ld	s4,48(a1)
    80002b88:	0385ba83          	ld	s5,56(a1)
    80002b8c:	0405bb03          	ld	s6,64(a1)
    80002b90:	0485bb83          	ld	s7,72(a1)
    80002b94:	0505bc03          	ld	s8,80(a1)
    80002b98:	0585bc83          	ld	s9,88(a1)
    80002b9c:	0605bd03          	ld	s10,96(a1)
    80002ba0:	0685bd83          	ld	s11,104(a1)
    80002ba4:	8082                	ret

0000000080002ba6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ba6:	1141                	addi	sp,sp,-16
    80002ba8:	e406                	sd	ra,8(sp)
    80002baa:	e022                	sd	s0,0(sp)
    80002bac:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002bae:	00005597          	auipc	a1,0x5
    80002bb2:	7d258593          	addi	a1,a1,2002 # 80008380 <states.0+0x30>
    80002bb6:	00024517          	auipc	a0,0x24
    80002bba:	71a50513          	addi	a0,a0,1818 # 800272d0 <tickslock>
    80002bbe:	ffffe097          	auipc	ra,0xffffe
    80002bc2:	f74080e7          	jalr	-140(ra) # 80000b32 <initlock>
}
    80002bc6:	60a2                	ld	ra,8(sp)
    80002bc8:	6402                	ld	s0,0(sp)
    80002bca:	0141                	addi	sp,sp,16
    80002bcc:	8082                	ret

0000000080002bce <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002bce:	1141                	addi	sp,sp,-16
    80002bd0:	e422                	sd	s0,8(sp)
    80002bd2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bd4:	00004797          	auipc	a5,0x4
    80002bd8:	adc78793          	addi	a5,a5,-1316 # 800066b0 <kernelvec>
    80002bdc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002be0:	6422                	ld	s0,8(sp)
    80002be2:	0141                	addi	sp,sp,16
    80002be4:	8082                	ret

0000000080002be6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002be6:	1141                	addi	sp,sp,-16
    80002be8:	e406                	sd	ra,8(sp)
    80002bea:	e022                	sd	s0,0(sp)
    80002bec:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bee:	fffff097          	auipc	ra,0xfffff
    80002bf2:	278080e7          	jalr	632(ra) # 80001e66 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002bfa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bfc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002c00:	00004617          	auipc	a2,0x4
    80002c04:	40060613          	addi	a2,a2,1024 # 80007000 <_trampoline>
    80002c08:	00004697          	auipc	a3,0x4
    80002c0c:	3f868693          	addi	a3,a3,1016 # 80007000 <_trampoline>
    80002c10:	8e91                	sub	a3,a3,a2
    80002c12:	040007b7          	lui	a5,0x4000
    80002c16:	17fd                	addi	a5,a5,-1
    80002c18:	07b2                	slli	a5,a5,0xc
    80002c1a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c1c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c20:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002c22:	180026f3          	csrr	a3,satp
    80002c26:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c28:	6d38                	ld	a4,88(a0)
    80002c2a:	6134                	ld	a3,64(a0)
    80002c2c:	6585                	lui	a1,0x1
    80002c2e:	96ae                	add	a3,a3,a1
    80002c30:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c32:	6d38                	ld	a4,88(a0)
    80002c34:	00000697          	auipc	a3,0x0
    80002c38:	13868693          	addi	a3,a3,312 # 80002d6c <usertrap>
    80002c3c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c3e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c40:	8692                	mv	a3,tp
    80002c42:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c44:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c48:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c4c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c50:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c54:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c56:	6f18                	ld	a4,24(a4)
    80002c58:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c5c:	692c                	ld	a1,80(a0)
    80002c5e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002c60:	00004717          	auipc	a4,0x4
    80002c64:	43070713          	addi	a4,a4,1072 # 80007090 <userret>
    80002c68:	8f11                	sub	a4,a4,a2
    80002c6a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002c6c:	577d                	li	a4,-1
    80002c6e:	177e                	slli	a4,a4,0x3f
    80002c70:	8dd9                	or	a1,a1,a4
    80002c72:	02000537          	lui	a0,0x2000
    80002c76:	157d                	addi	a0,a0,-1
    80002c78:	0536                	slli	a0,a0,0xd
    80002c7a:	9782                	jalr	a5
}
    80002c7c:	60a2                	ld	ra,8(sp)
    80002c7e:	6402                	ld	s0,0(sp)
    80002c80:	0141                	addi	sp,sp,16
    80002c82:	8082                	ret

0000000080002c84 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c84:	1101                	addi	sp,sp,-32
    80002c86:	ec06                	sd	ra,24(sp)
    80002c88:	e822                	sd	s0,16(sp)
    80002c8a:	e426                	sd	s1,8(sp)
    80002c8c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c8e:	00024497          	auipc	s1,0x24
    80002c92:	64248493          	addi	s1,s1,1602 # 800272d0 <tickslock>
    80002c96:	8526                	mv	a0,s1
    80002c98:	ffffe097          	auipc	ra,0xffffe
    80002c9c:	f2a080e7          	jalr	-214(ra) # 80000bc2 <acquire>
  ticks++;
    80002ca0:	00006517          	auipc	a0,0x6
    80002ca4:	39050513          	addi	a0,a0,912 # 80009030 <ticks>
    80002ca8:	411c                	lw	a5,0(a0)
    80002caa:	2785                	addiw	a5,a5,1
    80002cac:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002cae:	00000097          	auipc	ra,0x0
    80002cb2:	afa080e7          	jalr	-1286(ra) # 800027a8 <wakeup>
  release(&tickslock);
    80002cb6:	8526                	mv	a0,s1
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	fbe080e7          	jalr	-66(ra) # 80000c76 <release>
}
    80002cc0:	60e2                	ld	ra,24(sp)
    80002cc2:	6442                	ld	s0,16(sp)
    80002cc4:	64a2                	ld	s1,8(sp)
    80002cc6:	6105                	addi	sp,sp,32
    80002cc8:	8082                	ret

0000000080002cca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002cca:	1101                	addi	sp,sp,-32
    80002ccc:	ec06                	sd	ra,24(sp)
    80002cce:	e822                	sd	s0,16(sp)
    80002cd0:	e426                	sd	s1,8(sp)
    80002cd2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cd4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002cd8:	00074d63          	bltz	a4,80002cf2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002cdc:	57fd                	li	a5,-1
    80002cde:	17fe                	slli	a5,a5,0x3f
    80002ce0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ce2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ce4:	06f70363          	beq	a4,a5,80002d4a <devintr+0x80>
  }
}
    80002ce8:	60e2                	ld	ra,24(sp)
    80002cea:	6442                	ld	s0,16(sp)
    80002cec:	64a2                	ld	s1,8(sp)
    80002cee:	6105                	addi	sp,sp,32
    80002cf0:	8082                	ret
     (scause & 0xff) == 9){
    80002cf2:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002cf6:	46a5                	li	a3,9
    80002cf8:	fed792e3          	bne	a5,a3,80002cdc <devintr+0x12>
    int irq = plic_claim();
    80002cfc:	00004097          	auipc	ra,0x4
    80002d00:	abc080e7          	jalr	-1348(ra) # 800067b8 <plic_claim>
    80002d04:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002d06:	47a9                	li	a5,10
    80002d08:	02f50763          	beq	a0,a5,80002d36 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002d0c:	4785                	li	a5,1
    80002d0e:	02f50963          	beq	a0,a5,80002d40 <devintr+0x76>
    return 1;
    80002d12:	4505                	li	a0,1
    } else if(irq){
    80002d14:	d8f1                	beqz	s1,80002ce8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d16:	85a6                	mv	a1,s1
    80002d18:	00005517          	auipc	a0,0x5
    80002d1c:	67050513          	addi	a0,a0,1648 # 80008388 <states.0+0x38>
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	854080e7          	jalr	-1964(ra) # 80000574 <printf>
      plic_complete(irq);
    80002d28:	8526                	mv	a0,s1
    80002d2a:	00004097          	auipc	ra,0x4
    80002d2e:	ab2080e7          	jalr	-1358(ra) # 800067dc <plic_complete>
    return 1;
    80002d32:	4505                	li	a0,1
    80002d34:	bf55                	j	80002ce8 <devintr+0x1e>
      uartintr();
    80002d36:	ffffe097          	auipc	ra,0xffffe
    80002d3a:	c50080e7          	jalr	-944(ra) # 80000986 <uartintr>
    80002d3e:	b7ed                	j	80002d28 <devintr+0x5e>
      virtio_disk_intr();
    80002d40:	00004097          	auipc	ra,0x4
    80002d44:	f2e080e7          	jalr	-210(ra) # 80006c6e <virtio_disk_intr>
    80002d48:	b7c5                	j	80002d28 <devintr+0x5e>
    if(cpuid() == 0){
    80002d4a:	fffff097          	auipc	ra,0xfffff
    80002d4e:	0f0080e7          	jalr	240(ra) # 80001e3a <cpuid>
    80002d52:	c901                	beqz	a0,80002d62 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d54:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d58:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d5a:	14479073          	csrw	sip,a5
    return 2;
    80002d5e:	4509                	li	a0,2
    80002d60:	b761                	j	80002ce8 <devintr+0x1e>
      clockintr();
    80002d62:	00000097          	auipc	ra,0x0
    80002d66:	f22080e7          	jalr	-222(ra) # 80002c84 <clockintr>
    80002d6a:	b7ed                	j	80002d54 <devintr+0x8a>

0000000080002d6c <usertrap>:
{
    80002d6c:	7179                	addi	sp,sp,-48
    80002d6e:	f406                	sd	ra,40(sp)
    80002d70:	f022                	sd	s0,32(sp)
    80002d72:	ec26                	sd	s1,24(sp)
    80002d74:	e84a                	sd	s2,16(sp)
    80002d76:	e44e                	sd	s3,8(sp)
    80002d78:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d7a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d7e:	1007f793          	andi	a5,a5,256
    80002d82:	e3bd                	bnez	a5,80002de8 <usertrap+0x7c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d84:	00004797          	auipc	a5,0x4
    80002d88:	92c78793          	addi	a5,a5,-1748 # 800066b0 <kernelvec>
    80002d8c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	0d6080e7          	jalr	214(ra) # 80001e66 <myproc>
    80002d98:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d9a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d9c:	14102773          	csrr	a4,sepc
    80002da0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002da2:	14202773          	csrr	a4,scause
  if(r_scause() == 8)
    80002da6:	47a1                	li	a5,8
    80002da8:	04f71e63          	bne	a4,a5,80002e04 <usertrap+0x98>
    if(p->killed)
    80002dac:	551c                	lw	a5,40(a0)
    80002dae:	e7a9                	bnez	a5,80002df8 <usertrap+0x8c>
    p->trapframe->epc += 4;
    80002db0:	6cb8                	ld	a4,88(s1)
    80002db2:	6f1c                	ld	a5,24(a4)
    80002db4:	0791                	addi	a5,a5,4
    80002db6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002db8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002dbc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dc0:	10079073          	csrw	sstatus,a5
    syscall();
    80002dc4:	00000097          	auipc	ra,0x0
    80002dc8:	398080e7          	jalr	920(ra) # 8000315c <syscall>
  if(p->killed)
    80002dcc:	549c                	lw	a5,40(s1)
    80002dce:	14079463          	bnez	a5,80002f16 <usertrap+0x1aa>
  usertrapret();
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	e14080e7          	jalr	-492(ra) # 80002be6 <usertrapret>
}
    80002dda:	70a2                	ld	ra,40(sp)
    80002ddc:	7402                	ld	s0,32(sp)
    80002dde:	64e2                	ld	s1,24(sp)
    80002de0:	6942                	ld	s2,16(sp)
    80002de2:	69a2                	ld	s3,8(sp)
    80002de4:	6145                	addi	sp,sp,48
    80002de6:	8082                	ret
    panic("usertrap: not from user mode");
    80002de8:	00005517          	auipc	a0,0x5
    80002dec:	5c050513          	addi	a0,a0,1472 # 800083a8 <states.0+0x58>
    80002df0:	ffffd097          	auipc	ra,0xffffd
    80002df4:	73a080e7          	jalr	1850(ra) # 8000052a <panic>
      exit(-1);
    80002df8:	557d                	li	a0,-1
    80002dfa:	00000097          	auipc	ra,0x0
    80002dfe:	a7e080e7          	jalr	-1410(ra) # 80002878 <exit>
    80002e02:	b77d                	j	80002db0 <usertrap+0x44>
  else if((which_dev = devintr()) != 0)
    80002e04:	00000097          	auipc	ra,0x0
    80002e08:	ec6080e7          	jalr	-314(ra) # 80002cca <devintr>
    80002e0c:	892a                	mv	s2,a0
    80002e0e:	10051163          	bnez	a0,80002f10 <usertrap+0x1a4>
  else if ((p->pid > 2) && (r_scause() == 13 || r_scause() == 15 || r_scause() == 12))
    80002e12:	5890                	lw	a2,48(s1)
    80002e14:	4789                	li	a5,2
    80002e16:	02c7d163          	bge	a5,a2,80002e38 <usertrap+0xcc>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e1a:	14202773          	csrr	a4,scause
    80002e1e:	47b5                	li	a5,13
    80002e20:	06f70163          	beq	a4,a5,80002e82 <usertrap+0x116>
    80002e24:	14202773          	csrr	a4,scause
    80002e28:	47bd                	li	a5,15
    80002e2a:	04f70c63          	beq	a4,a5,80002e82 <usertrap+0x116>
    80002e2e:	14202773          	csrr	a4,scause
    80002e32:	47b1                	li	a5,12
    80002e34:	04f70763          	beq	a4,a5,80002e82 <usertrap+0x116>
    80002e38:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e3c:	00005517          	auipc	a0,0x5
    80002e40:	5b450513          	addi	a0,a0,1460 # 800083f0 <states.0+0xa0>
    80002e44:	ffffd097          	auipc	ra,0xffffd
    80002e48:	730080e7          	jalr	1840(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e4c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e50:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e54:	00005517          	auipc	a0,0x5
    80002e58:	5cc50513          	addi	a0,a0,1484 # 80008420 <states.0+0xd0>
    80002e5c:	ffffd097          	auipc	ra,0xffffd
    80002e60:	718080e7          	jalr	1816(ra) # 80000574 <printf>
    p->killed = 1;
    80002e64:	4785                	li	a5,1
    80002e66:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002e68:	557d                	li	a0,-1
    80002e6a:	00000097          	auipc	ra,0x0
    80002e6e:	a0e080e7          	jalr	-1522(ra) # 80002878 <exit>
  if(which_dev == 2)
    80002e72:	4789                	li	a5,2
    80002e74:	f4f91fe3          	bne	s2,a5,80002dd2 <usertrap+0x66>
    yield();
    80002e78:	fffff097          	auipc	ra,0xfffff
    80002e7c:	768080e7          	jalr	1896(ra) # 800025e0 <yield>
    80002e80:	bf89                	j	80002dd2 <usertrap+0x66>
    80002e82:	143029f3          	csrr	s3,stval
    pte_t* pte = walk(p->pagetable, fault_addr, 0);
    80002e86:	4601                	li	a2,0
    80002e88:	85ce                	mv	a1,s3
    80002e8a:	68a8                	ld	a0,80(s1)
    80002e8c:	ffffe097          	auipc	ra,0xffffe
    80002e90:	11a080e7          	jalr	282(ra) # 80000fa6 <walk>
    if ((*pte & PTE_PG))
    80002e94:	611c                	ld	a5,0(a0)
    80002e96:	2007f793          	andi	a5,a5,512
    80002e9a:	c39d                	beqz	a5,80002ec0 <usertrap+0x154>
      res = page_swap_in(p->pagetable, va, p);
    80002e9c:	8626                	mv	a2,s1
    80002e9e:	75fd                	lui	a1,0xfffff
    80002ea0:	00b9f5b3          	and	a1,s3,a1
    80002ea4:	68a8                	ld	a0,80(s1)
    80002ea6:	fffff097          	auipc	ra,0xfffff
    80002eaa:	8ea080e7          	jalr	-1814(ra) # 80001790 <page_swap_in>
      if (res != 0)
    80002eae:	dd19                	beqz	a0,80002dcc <usertrap+0x60>
        printf("swap_in failed\n");   
    80002eb0:	00005517          	auipc	a0,0x5
    80002eb4:	51850513          	addi	a0,a0,1304 # 800083c8 <states.0+0x78>
    80002eb8:	ffffd097          	auipc	ra,0xffffd
    80002ebc:	6bc080e7          	jalr	1724(ra) # 80000574 <printf>
      print_pages(p->pagetable);
    80002ec0:	68a8                	ld	a0,80(s1)
    80002ec2:	fffff097          	auipc	ra,0xfffff
    80002ec6:	97e080e7          	jalr	-1666(ra) # 80001840 <print_pages>
      printf("fault address:%p\n",(void*) fault_addr);
    80002eca:	85ce                	mv	a1,s3
    80002ecc:	00005517          	auipc	a0,0x5
    80002ed0:	50c50513          	addi	a0,a0,1292 # 800083d8 <states.0+0x88>
    80002ed4:	ffffd097          	auipc	ra,0xffffd
    80002ed8:	6a0080e7          	jalr	1696(ra) # 80000574 <printf>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002edc:	142025f3          	csrr	a1,scause
      printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ee0:	5890                	lw	a2,48(s1)
    80002ee2:	00005517          	auipc	a0,0x5
    80002ee6:	50e50513          	addi	a0,a0,1294 # 800083f0 <states.0+0xa0>
    80002eea:	ffffd097          	auipc	ra,0xffffd
    80002eee:	68a080e7          	jalr	1674(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ef2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ef6:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002efa:	00005517          	auipc	a0,0x5
    80002efe:	52650513          	addi	a0,a0,1318 # 80008420 <states.0+0xd0>
    80002f02:	ffffd097          	auipc	ra,0xffffd
    80002f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
      p->killed = 1;
    80002f0a:	4785                	li	a5,1
    80002f0c:	d49c                	sw	a5,40(s1)
    80002f0e:	bfa9                	j	80002e68 <usertrap+0xfc>
  if(p->killed)
    80002f10:	549c                	lw	a5,40(s1)
    80002f12:	d3a5                	beqz	a5,80002e72 <usertrap+0x106>
    80002f14:	bf91                	j	80002e68 <usertrap+0xfc>
    80002f16:	4901                	li	s2,0
    80002f18:	bf81                	j	80002e68 <usertrap+0xfc>

0000000080002f1a <kerneltrap>:
{
    80002f1a:	7179                	addi	sp,sp,-48
    80002f1c:	f406                	sd	ra,40(sp)
    80002f1e:	f022                	sd	s0,32(sp)
    80002f20:	ec26                	sd	s1,24(sp)
    80002f22:	e84a                	sd	s2,16(sp)
    80002f24:	e44e                	sd	s3,8(sp)
    80002f26:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f28:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f2c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f30:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f34:	1004f793          	andi	a5,s1,256
    80002f38:	cb85                	beqz	a5,80002f68 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f3e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f40:	ef85                	bnez	a5,80002f78 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002f42:	00000097          	auipc	ra,0x0
    80002f46:	d88080e7          	jalr	-632(ra) # 80002cca <devintr>
    80002f4a:	cd1d                	beqz	a0,80002f88 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f4c:	4789                	li	a5,2
    80002f4e:	06f50a63          	beq	a0,a5,80002fc2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f52:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f56:	10049073          	csrw	sstatus,s1
}
    80002f5a:	70a2                	ld	ra,40(sp)
    80002f5c:	7402                	ld	s0,32(sp)
    80002f5e:	64e2                	ld	s1,24(sp)
    80002f60:	6942                	ld	s2,16(sp)
    80002f62:	69a2                	ld	s3,8(sp)
    80002f64:	6145                	addi	sp,sp,48
    80002f66:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f68:	00005517          	auipc	a0,0x5
    80002f6c:	4d850513          	addi	a0,a0,1240 # 80008440 <states.0+0xf0>
    80002f70:	ffffd097          	auipc	ra,0xffffd
    80002f74:	5ba080e7          	jalr	1466(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002f78:	00005517          	auipc	a0,0x5
    80002f7c:	4f050513          	addi	a0,a0,1264 # 80008468 <states.0+0x118>
    80002f80:	ffffd097          	auipc	ra,0xffffd
    80002f84:	5aa080e7          	jalr	1450(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002f88:	85ce                	mv	a1,s3
    80002f8a:	00005517          	auipc	a0,0x5
    80002f8e:	4fe50513          	addi	a0,a0,1278 # 80008488 <states.0+0x138>
    80002f92:	ffffd097          	auipc	ra,0xffffd
    80002f96:	5e2080e7          	jalr	1506(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f9a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f9e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fa2:	00005517          	auipc	a0,0x5
    80002fa6:	4f650513          	addi	a0,a0,1270 # 80008498 <states.0+0x148>
    80002faa:	ffffd097          	auipc	ra,0xffffd
    80002fae:	5ca080e7          	jalr	1482(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002fb2:	00005517          	auipc	a0,0x5
    80002fb6:	4fe50513          	addi	a0,a0,1278 # 800084b0 <states.0+0x160>
    80002fba:	ffffd097          	auipc	ra,0xffffd
    80002fbe:	570080e7          	jalr	1392(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002fc2:	fffff097          	auipc	ra,0xfffff
    80002fc6:	ea4080e7          	jalr	-348(ra) # 80001e66 <myproc>
    80002fca:	d541                	beqz	a0,80002f52 <kerneltrap+0x38>
    80002fcc:	fffff097          	auipc	ra,0xfffff
    80002fd0:	e9a080e7          	jalr	-358(ra) # 80001e66 <myproc>
    80002fd4:	4d18                	lw	a4,24(a0)
    80002fd6:	4791                	li	a5,4
    80002fd8:	f6f71de3          	bne	a4,a5,80002f52 <kerneltrap+0x38>
    yield();
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	604080e7          	jalr	1540(ra) # 800025e0 <yield>
    80002fe4:	b7bd                	j	80002f52 <kerneltrap+0x38>

0000000080002fe6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002fe6:	1101                	addi	sp,sp,-32
    80002fe8:	ec06                	sd	ra,24(sp)
    80002fea:	e822                	sd	s0,16(sp)
    80002fec:	e426                	sd	s1,8(sp)
    80002fee:	1000                	addi	s0,sp,32
    80002ff0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ff2:	fffff097          	auipc	ra,0xfffff
    80002ff6:	e74080e7          	jalr	-396(ra) # 80001e66 <myproc>
  switch (n) {
    80002ffa:	4795                	li	a5,5
    80002ffc:	0497e163          	bltu	a5,s1,8000303e <argraw+0x58>
    80003000:	048a                	slli	s1,s1,0x2
    80003002:	00005717          	auipc	a4,0x5
    80003006:	4e670713          	addi	a4,a4,1254 # 800084e8 <states.0+0x198>
    8000300a:	94ba                	add	s1,s1,a4
    8000300c:	409c                	lw	a5,0(s1)
    8000300e:	97ba                	add	a5,a5,a4
    80003010:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003012:	6d3c                	ld	a5,88(a0)
    80003014:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003016:	60e2                	ld	ra,24(sp)
    80003018:	6442                	ld	s0,16(sp)
    8000301a:	64a2                	ld	s1,8(sp)
    8000301c:	6105                	addi	sp,sp,32
    8000301e:	8082                	ret
    return p->trapframe->a1;
    80003020:	6d3c                	ld	a5,88(a0)
    80003022:	7fa8                	ld	a0,120(a5)
    80003024:	bfcd                	j	80003016 <argraw+0x30>
    return p->trapframe->a2;
    80003026:	6d3c                	ld	a5,88(a0)
    80003028:	63c8                	ld	a0,128(a5)
    8000302a:	b7f5                	j	80003016 <argraw+0x30>
    return p->trapframe->a3;
    8000302c:	6d3c                	ld	a5,88(a0)
    8000302e:	67c8                	ld	a0,136(a5)
    80003030:	b7dd                	j	80003016 <argraw+0x30>
    return p->trapframe->a4;
    80003032:	6d3c                	ld	a5,88(a0)
    80003034:	6bc8                	ld	a0,144(a5)
    80003036:	b7c5                	j	80003016 <argraw+0x30>
    return p->trapframe->a5;
    80003038:	6d3c                	ld	a5,88(a0)
    8000303a:	6fc8                	ld	a0,152(a5)
    8000303c:	bfe9                	j	80003016 <argraw+0x30>
  panic("argraw");
    8000303e:	00005517          	auipc	a0,0x5
    80003042:	48250513          	addi	a0,a0,1154 # 800084c0 <states.0+0x170>
    80003046:	ffffd097          	auipc	ra,0xffffd
    8000304a:	4e4080e7          	jalr	1252(ra) # 8000052a <panic>

000000008000304e <fetchaddr>:
{
    8000304e:	1101                	addi	sp,sp,-32
    80003050:	ec06                	sd	ra,24(sp)
    80003052:	e822                	sd	s0,16(sp)
    80003054:	e426                	sd	s1,8(sp)
    80003056:	e04a                	sd	s2,0(sp)
    80003058:	1000                	addi	s0,sp,32
    8000305a:	84aa                	mv	s1,a0
    8000305c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000305e:	fffff097          	auipc	ra,0xfffff
    80003062:	e08080e7          	jalr	-504(ra) # 80001e66 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003066:	653c                	ld	a5,72(a0)
    80003068:	02f4f863          	bgeu	s1,a5,80003098 <fetchaddr+0x4a>
    8000306c:	00848713          	addi	a4,s1,8
    80003070:	02e7e663          	bltu	a5,a4,8000309c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003074:	46a1                	li	a3,8
    80003076:	8626                	mv	a2,s1
    80003078:	85ca                	mv	a1,s2
    8000307a:	6928                	ld	a0,80(a0)
    8000307c:	ffffe097          	auipc	ra,0xffffe
    80003080:	38e080e7          	jalr	910(ra) # 8000140a <copyin>
    80003084:	00a03533          	snez	a0,a0
    80003088:	40a00533          	neg	a0,a0
}
    8000308c:	60e2                	ld	ra,24(sp)
    8000308e:	6442                	ld	s0,16(sp)
    80003090:	64a2                	ld	s1,8(sp)
    80003092:	6902                	ld	s2,0(sp)
    80003094:	6105                	addi	sp,sp,32
    80003096:	8082                	ret
    return -1;
    80003098:	557d                	li	a0,-1
    8000309a:	bfcd                	j	8000308c <fetchaddr+0x3e>
    8000309c:	557d                	li	a0,-1
    8000309e:	b7fd                	j	8000308c <fetchaddr+0x3e>

00000000800030a0 <fetchstr>:
{
    800030a0:	7179                	addi	sp,sp,-48
    800030a2:	f406                	sd	ra,40(sp)
    800030a4:	f022                	sd	s0,32(sp)
    800030a6:	ec26                	sd	s1,24(sp)
    800030a8:	e84a                	sd	s2,16(sp)
    800030aa:	e44e                	sd	s3,8(sp)
    800030ac:	1800                	addi	s0,sp,48
    800030ae:	892a                	mv	s2,a0
    800030b0:	84ae                	mv	s1,a1
    800030b2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030b4:	fffff097          	auipc	ra,0xfffff
    800030b8:	db2080e7          	jalr	-590(ra) # 80001e66 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800030bc:	86ce                	mv	a3,s3
    800030be:	864a                	mv	a2,s2
    800030c0:	85a6                	mv	a1,s1
    800030c2:	6928                	ld	a0,80(a0)
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	3d4080e7          	jalr	980(ra) # 80001498 <copyinstr>
  if(err < 0)
    800030cc:	00054763          	bltz	a0,800030da <fetchstr+0x3a>
  return strlen(buf);
    800030d0:	8526                	mv	a0,s1
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	d70080e7          	jalr	-656(ra) # 80000e42 <strlen>
}
    800030da:	70a2                	ld	ra,40(sp)
    800030dc:	7402                	ld	s0,32(sp)
    800030de:	64e2                	ld	s1,24(sp)
    800030e0:	6942                	ld	s2,16(sp)
    800030e2:	69a2                	ld	s3,8(sp)
    800030e4:	6145                	addi	sp,sp,48
    800030e6:	8082                	ret

00000000800030e8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800030e8:	1101                	addi	sp,sp,-32
    800030ea:	ec06                	sd	ra,24(sp)
    800030ec:	e822                	sd	s0,16(sp)
    800030ee:	e426                	sd	s1,8(sp)
    800030f0:	1000                	addi	s0,sp,32
    800030f2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030f4:	00000097          	auipc	ra,0x0
    800030f8:	ef2080e7          	jalr	-270(ra) # 80002fe6 <argraw>
    800030fc:	c088                	sw	a0,0(s1)
  return 0;
}
    800030fe:	4501                	li	a0,0
    80003100:	60e2                	ld	ra,24(sp)
    80003102:	6442                	ld	s0,16(sp)
    80003104:	64a2                	ld	s1,8(sp)
    80003106:	6105                	addi	sp,sp,32
    80003108:	8082                	ret

000000008000310a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000310a:	1101                	addi	sp,sp,-32
    8000310c:	ec06                	sd	ra,24(sp)
    8000310e:	e822                	sd	s0,16(sp)
    80003110:	e426                	sd	s1,8(sp)
    80003112:	1000                	addi	s0,sp,32
    80003114:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003116:	00000097          	auipc	ra,0x0
    8000311a:	ed0080e7          	jalr	-304(ra) # 80002fe6 <argraw>
    8000311e:	e088                	sd	a0,0(s1)
  return 0;
}
    80003120:	4501                	li	a0,0
    80003122:	60e2                	ld	ra,24(sp)
    80003124:	6442                	ld	s0,16(sp)
    80003126:	64a2                	ld	s1,8(sp)
    80003128:	6105                	addi	sp,sp,32
    8000312a:	8082                	ret

000000008000312c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000312c:	1101                	addi	sp,sp,-32
    8000312e:	ec06                	sd	ra,24(sp)
    80003130:	e822                	sd	s0,16(sp)
    80003132:	e426                	sd	s1,8(sp)
    80003134:	e04a                	sd	s2,0(sp)
    80003136:	1000                	addi	s0,sp,32
    80003138:	84ae                	mv	s1,a1
    8000313a:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000313c:	00000097          	auipc	ra,0x0
    80003140:	eaa080e7          	jalr	-342(ra) # 80002fe6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003144:	864a                	mv	a2,s2
    80003146:	85a6                	mv	a1,s1
    80003148:	00000097          	auipc	ra,0x0
    8000314c:	f58080e7          	jalr	-168(ra) # 800030a0 <fetchstr>
}
    80003150:	60e2                	ld	ra,24(sp)
    80003152:	6442                	ld	s0,16(sp)
    80003154:	64a2                	ld	s1,8(sp)
    80003156:	6902                	ld	s2,0(sp)
    80003158:	6105                	addi	sp,sp,32
    8000315a:	8082                	ret

000000008000315c <syscall>:
[SYS_ppages]  sys_ppages,
};

void
syscall(void)
{
    8000315c:	1101                	addi	sp,sp,-32
    8000315e:	ec06                	sd	ra,24(sp)
    80003160:	e822                	sd	s0,16(sp)
    80003162:	e426                	sd	s1,8(sp)
    80003164:	e04a                	sd	s2,0(sp)
    80003166:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003168:	fffff097          	auipc	ra,0xfffff
    8000316c:	cfe080e7          	jalr	-770(ra) # 80001e66 <myproc>
    80003170:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003172:	05853903          	ld	s2,88(a0)
    80003176:	0a893783          	ld	a5,168(s2)
    8000317a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000317e:	37fd                	addiw	a5,a5,-1
    80003180:	4755                	li	a4,21
    80003182:	00f76f63          	bltu	a4,a5,800031a0 <syscall+0x44>
    80003186:	00369713          	slli	a4,a3,0x3
    8000318a:	00005797          	auipc	a5,0x5
    8000318e:	37678793          	addi	a5,a5,886 # 80008500 <syscalls>
    80003192:	97ba                	add	a5,a5,a4
    80003194:	639c                	ld	a5,0(a5)
    80003196:	c789                	beqz	a5,800031a0 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003198:	9782                	jalr	a5
    8000319a:	06a93823          	sd	a0,112(s2)
    8000319e:	a839                	j	800031bc <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800031a0:	15848613          	addi	a2,s1,344
    800031a4:	588c                	lw	a1,48(s1)
    800031a6:	00005517          	auipc	a0,0x5
    800031aa:	32250513          	addi	a0,a0,802 # 800084c8 <states.0+0x178>
    800031ae:	ffffd097          	auipc	ra,0xffffd
    800031b2:	3c6080e7          	jalr	966(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031b6:	6cbc                	ld	a5,88(s1)
    800031b8:	577d                	li	a4,-1
    800031ba:	fbb8                	sd	a4,112(a5)
  }
}
    800031bc:	60e2                	ld	ra,24(sp)
    800031be:	6442                	ld	s0,16(sp)
    800031c0:	64a2                	ld	s1,8(sp)
    800031c2:	6902                	ld	s2,0(sp)
    800031c4:	6105                	addi	sp,sp,32
    800031c6:	8082                	ret

00000000800031c8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031c8:	1101                	addi	sp,sp,-32
    800031ca:	ec06                	sd	ra,24(sp)
    800031cc:	e822                	sd	s0,16(sp)
    800031ce:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800031d0:	fec40593          	addi	a1,s0,-20
    800031d4:	4501                	li	a0,0
    800031d6:	00000097          	auipc	ra,0x0
    800031da:	f12080e7          	jalr	-238(ra) # 800030e8 <argint>
    return -1;
    800031de:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031e0:	00054963          	bltz	a0,800031f2 <sys_exit+0x2a>
  exit(n);
    800031e4:	fec42503          	lw	a0,-20(s0)
    800031e8:	fffff097          	auipc	ra,0xfffff
    800031ec:	690080e7          	jalr	1680(ra) # 80002878 <exit>
  return 0;  // not reached
    800031f0:	4781                	li	a5,0
}
    800031f2:	853e                	mv	a0,a5
    800031f4:	60e2                	ld	ra,24(sp)
    800031f6:	6442                	ld	s0,16(sp)
    800031f8:	6105                	addi	sp,sp,32
    800031fa:	8082                	ret

00000000800031fc <sys_getpid>:

uint64
sys_getpid(void)
{
    800031fc:	1141                	addi	sp,sp,-16
    800031fe:	e406                	sd	ra,8(sp)
    80003200:	e022                	sd	s0,0(sp)
    80003202:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003204:	fffff097          	auipc	ra,0xfffff
    80003208:	c62080e7          	jalr	-926(ra) # 80001e66 <myproc>
}
    8000320c:	5908                	lw	a0,48(a0)
    8000320e:	60a2                	ld	ra,8(sp)
    80003210:	6402                	ld	s0,0(sp)
    80003212:	0141                	addi	sp,sp,16
    80003214:	8082                	ret

0000000080003216 <sys_fork>:

uint64
sys_fork(void)
{
    80003216:	1141                	addi	sp,sp,-16
    80003218:	e406                	sd	ra,8(sp)
    8000321a:	e022                	sd	s0,0(sp)
    8000321c:	0800                	addi	s0,sp,16
  return fork();
    8000321e:	fffff097          	auipc	ra,0xfffff
    80003222:	06e080e7          	jalr	110(ra) # 8000228c <fork>
}
    80003226:	60a2                	ld	ra,8(sp)
    80003228:	6402                	ld	s0,0(sp)
    8000322a:	0141                	addi	sp,sp,16
    8000322c:	8082                	ret

000000008000322e <sys_wait>:

uint64
sys_wait(void)
{
    8000322e:	1101                	addi	sp,sp,-32
    80003230:	ec06                	sd	ra,24(sp)
    80003232:	e822                	sd	s0,16(sp)
    80003234:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003236:	fe840593          	addi	a1,s0,-24
    8000323a:	4501                	li	a0,0
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	ece080e7          	jalr	-306(ra) # 8000310a <argaddr>
    80003244:	87aa                	mv	a5,a0
    return -1;
    80003246:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003248:	0007c863          	bltz	a5,80003258 <sys_wait+0x2a>
  return wait(p);
    8000324c:	fe843503          	ld	a0,-24(s0)
    80003250:	fffff097          	auipc	ra,0xfffff
    80003254:	430080e7          	jalr	1072(ra) # 80002680 <wait>
}
    80003258:	60e2                	ld	ra,24(sp)
    8000325a:	6442                	ld	s0,16(sp)
    8000325c:	6105                	addi	sp,sp,32
    8000325e:	8082                	ret

0000000080003260 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003260:	7179                	addi	sp,sp,-48
    80003262:	f406                	sd	ra,40(sp)
    80003264:	f022                	sd	s0,32(sp)
    80003266:	ec26                	sd	s1,24(sp)
    80003268:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000326a:	fdc40593          	addi	a1,s0,-36
    8000326e:	4501                	li	a0,0
    80003270:	00000097          	auipc	ra,0x0
    80003274:	e78080e7          	jalr	-392(ra) # 800030e8 <argint>
    return -1;
    80003278:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000327a:	00054f63          	bltz	a0,80003298 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000327e:	fffff097          	auipc	ra,0xfffff
    80003282:	be8080e7          	jalr	-1048(ra) # 80001e66 <myproc>
    80003286:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003288:	fdc42503          	lw	a0,-36(s0)
    8000328c:	fffff097          	auipc	ra,0xfffff
    80003290:	f8c080e7          	jalr	-116(ra) # 80002218 <growproc>
    80003294:	00054863          	bltz	a0,800032a4 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003298:	8526                	mv	a0,s1
    8000329a:	70a2                	ld	ra,40(sp)
    8000329c:	7402                	ld	s0,32(sp)
    8000329e:	64e2                	ld	s1,24(sp)
    800032a0:	6145                	addi	sp,sp,48
    800032a2:	8082                	ret
    return -1;
    800032a4:	54fd                	li	s1,-1
    800032a6:	bfcd                	j	80003298 <sys_sbrk+0x38>

00000000800032a8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800032a8:	7139                	addi	sp,sp,-64
    800032aa:	fc06                	sd	ra,56(sp)
    800032ac:	f822                	sd	s0,48(sp)
    800032ae:	f426                	sd	s1,40(sp)
    800032b0:	f04a                	sd	s2,32(sp)
    800032b2:	ec4e                	sd	s3,24(sp)
    800032b4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800032b6:	fcc40593          	addi	a1,s0,-52
    800032ba:	4501                	li	a0,0
    800032bc:	00000097          	auipc	ra,0x0
    800032c0:	e2c080e7          	jalr	-468(ra) # 800030e8 <argint>
    return -1;
    800032c4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800032c6:	06054563          	bltz	a0,80003330 <sys_sleep+0x88>
  acquire(&tickslock);
    800032ca:	00024517          	auipc	a0,0x24
    800032ce:	00650513          	addi	a0,a0,6 # 800272d0 <tickslock>
    800032d2:	ffffe097          	auipc	ra,0xffffe
    800032d6:	8f0080e7          	jalr	-1808(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    800032da:	00006917          	auipc	s2,0x6
    800032de:	d5692903          	lw	s2,-682(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    800032e2:	fcc42783          	lw	a5,-52(s0)
    800032e6:	cf85                	beqz	a5,8000331e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800032e8:	00024997          	auipc	s3,0x24
    800032ec:	fe898993          	addi	s3,s3,-24 # 800272d0 <tickslock>
    800032f0:	00006497          	auipc	s1,0x6
    800032f4:	d4048493          	addi	s1,s1,-704 # 80009030 <ticks>
    if(myproc()->killed){
    800032f8:	fffff097          	auipc	ra,0xfffff
    800032fc:	b6e080e7          	jalr	-1170(ra) # 80001e66 <myproc>
    80003300:	551c                	lw	a5,40(a0)
    80003302:	ef9d                	bnez	a5,80003340 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003304:	85ce                	mv	a1,s3
    80003306:	8526                	mv	a0,s1
    80003308:	fffff097          	auipc	ra,0xfffff
    8000330c:	314080e7          	jalr	788(ra) # 8000261c <sleep>
  while(ticks - ticks0 < n){
    80003310:	409c                	lw	a5,0(s1)
    80003312:	412787bb          	subw	a5,a5,s2
    80003316:	fcc42703          	lw	a4,-52(s0)
    8000331a:	fce7efe3          	bltu	a5,a4,800032f8 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000331e:	00024517          	auipc	a0,0x24
    80003322:	fb250513          	addi	a0,a0,-78 # 800272d0 <tickslock>
    80003326:	ffffe097          	auipc	ra,0xffffe
    8000332a:	950080e7          	jalr	-1712(ra) # 80000c76 <release>
  return 0;
    8000332e:	4781                	li	a5,0
}
    80003330:	853e                	mv	a0,a5
    80003332:	70e2                	ld	ra,56(sp)
    80003334:	7442                	ld	s0,48(sp)
    80003336:	74a2                	ld	s1,40(sp)
    80003338:	7902                	ld	s2,32(sp)
    8000333a:	69e2                	ld	s3,24(sp)
    8000333c:	6121                	addi	sp,sp,64
    8000333e:	8082                	ret
      release(&tickslock);
    80003340:	00024517          	auipc	a0,0x24
    80003344:	f9050513          	addi	a0,a0,-112 # 800272d0 <tickslock>
    80003348:	ffffe097          	auipc	ra,0xffffe
    8000334c:	92e080e7          	jalr	-1746(ra) # 80000c76 <release>
      return -1;
    80003350:	57fd                	li	a5,-1
    80003352:	bff9                	j	80003330 <sys_sleep+0x88>

0000000080003354 <sys_kill>:

uint64
sys_kill(void)
{
    80003354:	1101                	addi	sp,sp,-32
    80003356:	ec06                	sd	ra,24(sp)
    80003358:	e822                	sd	s0,16(sp)
    8000335a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000335c:	fec40593          	addi	a1,s0,-20
    80003360:	4501                	li	a0,0
    80003362:	00000097          	auipc	ra,0x0
    80003366:	d86080e7          	jalr	-634(ra) # 800030e8 <argint>
    8000336a:	87aa                	mv	a5,a0
    return -1;
    8000336c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000336e:	0007c863          	bltz	a5,8000337e <sys_kill+0x2a>
  return kill(pid);
    80003372:	fec42503          	lw	a0,-20(s0)
    80003376:	fffff097          	auipc	ra,0xfffff
    8000337a:	5f8080e7          	jalr	1528(ra) # 8000296e <kill>
}
    8000337e:	60e2                	ld	ra,24(sp)
    80003380:	6442                	ld	s0,16(sp)
    80003382:	6105                	addi	sp,sp,32
    80003384:	8082                	ret

0000000080003386 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003386:	1101                	addi	sp,sp,-32
    80003388:	ec06                	sd	ra,24(sp)
    8000338a:	e822                	sd	s0,16(sp)
    8000338c:	e426                	sd	s1,8(sp)
    8000338e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003390:	00024517          	auipc	a0,0x24
    80003394:	f4050513          	addi	a0,a0,-192 # 800272d0 <tickslock>
    80003398:	ffffe097          	auipc	ra,0xffffe
    8000339c:	82a080e7          	jalr	-2006(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800033a0:	00006497          	auipc	s1,0x6
    800033a4:	c904a483          	lw	s1,-880(s1) # 80009030 <ticks>
  release(&tickslock);
    800033a8:	00024517          	auipc	a0,0x24
    800033ac:	f2850513          	addi	a0,a0,-216 # 800272d0 <tickslock>
    800033b0:	ffffe097          	auipc	ra,0xffffe
    800033b4:	8c6080e7          	jalr	-1850(ra) # 80000c76 <release>
  return xticks;
}
    800033b8:	02049513          	slli	a0,s1,0x20
    800033bc:	9101                	srli	a0,a0,0x20
    800033be:	60e2                	ld	ra,24(sp)
    800033c0:	6442                	ld	s0,16(sp)
    800033c2:	64a2                	ld	s1,8(sp)
    800033c4:	6105                	addi	sp,sp,32
    800033c6:	8082                	ret

00000000800033c8 <sys_ppages>:

uint64
sys_ppages(void)
{
    800033c8:	1141                	addi	sp,sp,-16
    800033ca:	e406                	sd	ra,8(sp)
    800033cc:	e022                	sd	s0,0(sp)
    800033ce:	0800                	addi	s0,sp,16
  ppages();
    800033d0:	ffffe097          	auipc	ra,0xffffe
    800033d4:	4be080e7          	jalr	1214(ra) # 8000188e <ppages>
  return 0;
}
    800033d8:	4501                	li	a0,0
    800033da:	60a2                	ld	ra,8(sp)
    800033dc:	6402                	ld	s0,0(sp)
    800033de:	0141                	addi	sp,sp,16
    800033e0:	8082                	ret

00000000800033e2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800033e2:	7179                	addi	sp,sp,-48
    800033e4:	f406                	sd	ra,40(sp)
    800033e6:	f022                	sd	s0,32(sp)
    800033e8:	ec26                	sd	s1,24(sp)
    800033ea:	e84a                	sd	s2,16(sp)
    800033ec:	e44e                	sd	s3,8(sp)
    800033ee:	e052                	sd	s4,0(sp)
    800033f0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033f2:	00005597          	auipc	a1,0x5
    800033f6:	1c658593          	addi	a1,a1,454 # 800085b8 <syscalls+0xb8>
    800033fa:	00024517          	auipc	a0,0x24
    800033fe:	eee50513          	addi	a0,a0,-274 # 800272e8 <bcache>
    80003402:	ffffd097          	auipc	ra,0xffffd
    80003406:	730080e7          	jalr	1840(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000340a:	0002c797          	auipc	a5,0x2c
    8000340e:	ede78793          	addi	a5,a5,-290 # 8002f2e8 <bcache+0x8000>
    80003412:	0002c717          	auipc	a4,0x2c
    80003416:	13e70713          	addi	a4,a4,318 # 8002f550 <bcache+0x8268>
    8000341a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000341e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003422:	00024497          	auipc	s1,0x24
    80003426:	ede48493          	addi	s1,s1,-290 # 80027300 <bcache+0x18>
    b->next = bcache.head.next;
    8000342a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000342c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000342e:	00005a17          	auipc	s4,0x5
    80003432:	192a0a13          	addi	s4,s4,402 # 800085c0 <syscalls+0xc0>
    b->next = bcache.head.next;
    80003436:	2b893783          	ld	a5,696(s2)
    8000343a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000343c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003440:	85d2                	mv	a1,s4
    80003442:	01048513          	addi	a0,s1,16
    80003446:	00002097          	auipc	ra,0x2
    8000344a:	80a080e7          	jalr	-2038(ra) # 80004c50 <initsleeplock>
    bcache.head.next->prev = b;
    8000344e:	2b893783          	ld	a5,696(s2)
    80003452:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003454:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003458:	45848493          	addi	s1,s1,1112
    8000345c:	fd349de3          	bne	s1,s3,80003436 <binit+0x54>
  }
}
    80003460:	70a2                	ld	ra,40(sp)
    80003462:	7402                	ld	s0,32(sp)
    80003464:	64e2                	ld	s1,24(sp)
    80003466:	6942                	ld	s2,16(sp)
    80003468:	69a2                	ld	s3,8(sp)
    8000346a:	6a02                	ld	s4,0(sp)
    8000346c:	6145                	addi	sp,sp,48
    8000346e:	8082                	ret

0000000080003470 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003470:	7179                	addi	sp,sp,-48
    80003472:	f406                	sd	ra,40(sp)
    80003474:	f022                	sd	s0,32(sp)
    80003476:	ec26                	sd	s1,24(sp)
    80003478:	e84a                	sd	s2,16(sp)
    8000347a:	e44e                	sd	s3,8(sp)
    8000347c:	1800                	addi	s0,sp,48
    8000347e:	892a                	mv	s2,a0
    80003480:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003482:	00024517          	auipc	a0,0x24
    80003486:	e6650513          	addi	a0,a0,-410 # 800272e8 <bcache>
    8000348a:	ffffd097          	auipc	ra,0xffffd
    8000348e:	738080e7          	jalr	1848(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003492:	0002c497          	auipc	s1,0x2c
    80003496:	10e4b483          	ld	s1,270(s1) # 8002f5a0 <bcache+0x82b8>
    8000349a:	0002c797          	auipc	a5,0x2c
    8000349e:	0b678793          	addi	a5,a5,182 # 8002f550 <bcache+0x8268>
    800034a2:	02f48f63          	beq	s1,a5,800034e0 <bread+0x70>
    800034a6:	873e                	mv	a4,a5
    800034a8:	a021                	j	800034b0 <bread+0x40>
    800034aa:	68a4                	ld	s1,80(s1)
    800034ac:	02e48a63          	beq	s1,a4,800034e0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034b0:	449c                	lw	a5,8(s1)
    800034b2:	ff279ce3          	bne	a5,s2,800034aa <bread+0x3a>
    800034b6:	44dc                	lw	a5,12(s1)
    800034b8:	ff3799e3          	bne	a5,s3,800034aa <bread+0x3a>
      b->refcnt++;
    800034bc:	40bc                	lw	a5,64(s1)
    800034be:	2785                	addiw	a5,a5,1
    800034c0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034c2:	00024517          	auipc	a0,0x24
    800034c6:	e2650513          	addi	a0,a0,-474 # 800272e8 <bcache>
    800034ca:	ffffd097          	auipc	ra,0xffffd
    800034ce:	7ac080e7          	jalr	1964(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800034d2:	01048513          	addi	a0,s1,16
    800034d6:	00001097          	auipc	ra,0x1
    800034da:	7b4080e7          	jalr	1972(ra) # 80004c8a <acquiresleep>
      return b;
    800034de:	a8b9                	j	8000353c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034e0:	0002c497          	auipc	s1,0x2c
    800034e4:	0b84b483          	ld	s1,184(s1) # 8002f598 <bcache+0x82b0>
    800034e8:	0002c797          	auipc	a5,0x2c
    800034ec:	06878793          	addi	a5,a5,104 # 8002f550 <bcache+0x8268>
    800034f0:	00f48863          	beq	s1,a5,80003500 <bread+0x90>
    800034f4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034f6:	40bc                	lw	a5,64(s1)
    800034f8:	cf81                	beqz	a5,80003510 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034fa:	64a4                	ld	s1,72(s1)
    800034fc:	fee49de3          	bne	s1,a4,800034f6 <bread+0x86>
  panic("bget: no buffers");
    80003500:	00005517          	auipc	a0,0x5
    80003504:	0c850513          	addi	a0,a0,200 # 800085c8 <syscalls+0xc8>
    80003508:	ffffd097          	auipc	ra,0xffffd
    8000350c:	022080e7          	jalr	34(ra) # 8000052a <panic>
      b->dev = dev;
    80003510:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003514:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003518:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000351c:	4785                	li	a5,1
    8000351e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003520:	00024517          	auipc	a0,0x24
    80003524:	dc850513          	addi	a0,a0,-568 # 800272e8 <bcache>
    80003528:	ffffd097          	auipc	ra,0xffffd
    8000352c:	74e080e7          	jalr	1870(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003530:	01048513          	addi	a0,s1,16
    80003534:	00001097          	auipc	ra,0x1
    80003538:	756080e7          	jalr	1878(ra) # 80004c8a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000353c:	409c                	lw	a5,0(s1)
    8000353e:	cb89                	beqz	a5,80003550 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003540:	8526                	mv	a0,s1
    80003542:	70a2                	ld	ra,40(sp)
    80003544:	7402                	ld	s0,32(sp)
    80003546:	64e2                	ld	s1,24(sp)
    80003548:	6942                	ld	s2,16(sp)
    8000354a:	69a2                	ld	s3,8(sp)
    8000354c:	6145                	addi	sp,sp,48
    8000354e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003550:	4581                	li	a1,0
    80003552:	8526                	mv	a0,s1
    80003554:	00003097          	auipc	ra,0x3
    80003558:	492080e7          	jalr	1170(ra) # 800069e6 <virtio_disk_rw>
    b->valid = 1;
    8000355c:	4785                	li	a5,1
    8000355e:	c09c                	sw	a5,0(s1)
  return b;
    80003560:	b7c5                	j	80003540 <bread+0xd0>

0000000080003562 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003562:	1101                	addi	sp,sp,-32
    80003564:	ec06                	sd	ra,24(sp)
    80003566:	e822                	sd	s0,16(sp)
    80003568:	e426                	sd	s1,8(sp)
    8000356a:	1000                	addi	s0,sp,32
    8000356c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000356e:	0541                	addi	a0,a0,16
    80003570:	00001097          	auipc	ra,0x1
    80003574:	7b4080e7          	jalr	1972(ra) # 80004d24 <holdingsleep>
    80003578:	cd01                	beqz	a0,80003590 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000357a:	4585                	li	a1,1
    8000357c:	8526                	mv	a0,s1
    8000357e:	00003097          	auipc	ra,0x3
    80003582:	468080e7          	jalr	1128(ra) # 800069e6 <virtio_disk_rw>
}
    80003586:	60e2                	ld	ra,24(sp)
    80003588:	6442                	ld	s0,16(sp)
    8000358a:	64a2                	ld	s1,8(sp)
    8000358c:	6105                	addi	sp,sp,32
    8000358e:	8082                	ret
    panic("bwrite");
    80003590:	00005517          	auipc	a0,0x5
    80003594:	05050513          	addi	a0,a0,80 # 800085e0 <syscalls+0xe0>
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	f92080e7          	jalr	-110(ra) # 8000052a <panic>

00000000800035a0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035a0:	1101                	addi	sp,sp,-32
    800035a2:	ec06                	sd	ra,24(sp)
    800035a4:	e822                	sd	s0,16(sp)
    800035a6:	e426                	sd	s1,8(sp)
    800035a8:	e04a                	sd	s2,0(sp)
    800035aa:	1000                	addi	s0,sp,32
    800035ac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035ae:	01050913          	addi	s2,a0,16
    800035b2:	854a                	mv	a0,s2
    800035b4:	00001097          	auipc	ra,0x1
    800035b8:	770080e7          	jalr	1904(ra) # 80004d24 <holdingsleep>
    800035bc:	c92d                	beqz	a0,8000362e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800035be:	854a                	mv	a0,s2
    800035c0:	00001097          	auipc	ra,0x1
    800035c4:	720080e7          	jalr	1824(ra) # 80004ce0 <releasesleep>

  acquire(&bcache.lock);
    800035c8:	00024517          	auipc	a0,0x24
    800035cc:	d2050513          	addi	a0,a0,-736 # 800272e8 <bcache>
    800035d0:	ffffd097          	auipc	ra,0xffffd
    800035d4:	5f2080e7          	jalr	1522(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800035d8:	40bc                	lw	a5,64(s1)
    800035da:	37fd                	addiw	a5,a5,-1
    800035dc:	0007871b          	sext.w	a4,a5
    800035e0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800035e2:	eb05                	bnez	a4,80003612 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800035e4:	68bc                	ld	a5,80(s1)
    800035e6:	64b8                	ld	a4,72(s1)
    800035e8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800035ea:	64bc                	ld	a5,72(s1)
    800035ec:	68b8                	ld	a4,80(s1)
    800035ee:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035f0:	0002c797          	auipc	a5,0x2c
    800035f4:	cf878793          	addi	a5,a5,-776 # 8002f2e8 <bcache+0x8000>
    800035f8:	2b87b703          	ld	a4,696(a5)
    800035fc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035fe:	0002c717          	auipc	a4,0x2c
    80003602:	f5270713          	addi	a4,a4,-174 # 8002f550 <bcache+0x8268>
    80003606:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003608:	2b87b703          	ld	a4,696(a5)
    8000360c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000360e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003612:	00024517          	auipc	a0,0x24
    80003616:	cd650513          	addi	a0,a0,-810 # 800272e8 <bcache>
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	65c080e7          	jalr	1628(ra) # 80000c76 <release>
}
    80003622:	60e2                	ld	ra,24(sp)
    80003624:	6442                	ld	s0,16(sp)
    80003626:	64a2                	ld	s1,8(sp)
    80003628:	6902                	ld	s2,0(sp)
    8000362a:	6105                	addi	sp,sp,32
    8000362c:	8082                	ret
    panic("brelse");
    8000362e:	00005517          	auipc	a0,0x5
    80003632:	fba50513          	addi	a0,a0,-70 # 800085e8 <syscalls+0xe8>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	ef4080e7          	jalr	-268(ra) # 8000052a <panic>

000000008000363e <bpin>:

void
bpin(struct buf *b) {
    8000363e:	1101                	addi	sp,sp,-32
    80003640:	ec06                	sd	ra,24(sp)
    80003642:	e822                	sd	s0,16(sp)
    80003644:	e426                	sd	s1,8(sp)
    80003646:	1000                	addi	s0,sp,32
    80003648:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000364a:	00024517          	auipc	a0,0x24
    8000364e:	c9e50513          	addi	a0,a0,-866 # 800272e8 <bcache>
    80003652:	ffffd097          	auipc	ra,0xffffd
    80003656:	570080e7          	jalr	1392(ra) # 80000bc2 <acquire>
  b->refcnt++;
    8000365a:	40bc                	lw	a5,64(s1)
    8000365c:	2785                	addiw	a5,a5,1
    8000365e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003660:	00024517          	auipc	a0,0x24
    80003664:	c8850513          	addi	a0,a0,-888 # 800272e8 <bcache>
    80003668:	ffffd097          	auipc	ra,0xffffd
    8000366c:	60e080e7          	jalr	1550(ra) # 80000c76 <release>
}
    80003670:	60e2                	ld	ra,24(sp)
    80003672:	6442                	ld	s0,16(sp)
    80003674:	64a2                	ld	s1,8(sp)
    80003676:	6105                	addi	sp,sp,32
    80003678:	8082                	ret

000000008000367a <bunpin>:

void
bunpin(struct buf *b) {
    8000367a:	1101                	addi	sp,sp,-32
    8000367c:	ec06                	sd	ra,24(sp)
    8000367e:	e822                	sd	s0,16(sp)
    80003680:	e426                	sd	s1,8(sp)
    80003682:	1000                	addi	s0,sp,32
    80003684:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003686:	00024517          	auipc	a0,0x24
    8000368a:	c6250513          	addi	a0,a0,-926 # 800272e8 <bcache>
    8000368e:	ffffd097          	auipc	ra,0xffffd
    80003692:	534080e7          	jalr	1332(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003696:	40bc                	lw	a5,64(s1)
    80003698:	37fd                	addiw	a5,a5,-1
    8000369a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000369c:	00024517          	auipc	a0,0x24
    800036a0:	c4c50513          	addi	a0,a0,-948 # 800272e8 <bcache>
    800036a4:	ffffd097          	auipc	ra,0xffffd
    800036a8:	5d2080e7          	jalr	1490(ra) # 80000c76 <release>
}
    800036ac:	60e2                	ld	ra,24(sp)
    800036ae:	6442                	ld	s0,16(sp)
    800036b0:	64a2                	ld	s1,8(sp)
    800036b2:	6105                	addi	sp,sp,32
    800036b4:	8082                	ret

00000000800036b6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036b6:	1101                	addi	sp,sp,-32
    800036b8:	ec06                	sd	ra,24(sp)
    800036ba:	e822                	sd	s0,16(sp)
    800036bc:	e426                	sd	s1,8(sp)
    800036be:	e04a                	sd	s2,0(sp)
    800036c0:	1000                	addi	s0,sp,32
    800036c2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036c4:	00d5d59b          	srliw	a1,a1,0xd
    800036c8:	0002c797          	auipc	a5,0x2c
    800036cc:	2fc7a783          	lw	a5,764(a5) # 8002f9c4 <sb+0x1c>
    800036d0:	9dbd                	addw	a1,a1,a5
    800036d2:	00000097          	auipc	ra,0x0
    800036d6:	d9e080e7          	jalr	-610(ra) # 80003470 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800036da:	0074f713          	andi	a4,s1,7
    800036de:	4785                	li	a5,1
    800036e0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800036e4:	14ce                	slli	s1,s1,0x33
    800036e6:	90d9                	srli	s1,s1,0x36
    800036e8:	00950733          	add	a4,a0,s1
    800036ec:	05874703          	lbu	a4,88(a4)
    800036f0:	00e7f6b3          	and	a3,a5,a4
    800036f4:	c69d                	beqz	a3,80003722 <bfree+0x6c>
    800036f6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036f8:	94aa                	add	s1,s1,a0
    800036fa:	fff7c793          	not	a5,a5
    800036fe:	8ff9                	and	a5,a5,a4
    80003700:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003704:	00001097          	auipc	ra,0x1
    80003708:	466080e7          	jalr	1126(ra) # 80004b6a <log_write>
  brelse(bp);
    8000370c:	854a                	mv	a0,s2
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	e92080e7          	jalr	-366(ra) # 800035a0 <brelse>
}
    80003716:	60e2                	ld	ra,24(sp)
    80003718:	6442                	ld	s0,16(sp)
    8000371a:	64a2                	ld	s1,8(sp)
    8000371c:	6902                	ld	s2,0(sp)
    8000371e:	6105                	addi	sp,sp,32
    80003720:	8082                	ret
    panic("freeing free block");
    80003722:	00005517          	auipc	a0,0x5
    80003726:	ece50513          	addi	a0,a0,-306 # 800085f0 <syscalls+0xf0>
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	e00080e7          	jalr	-512(ra) # 8000052a <panic>

0000000080003732 <balloc>:
{
    80003732:	711d                	addi	sp,sp,-96
    80003734:	ec86                	sd	ra,88(sp)
    80003736:	e8a2                	sd	s0,80(sp)
    80003738:	e4a6                	sd	s1,72(sp)
    8000373a:	e0ca                	sd	s2,64(sp)
    8000373c:	fc4e                	sd	s3,56(sp)
    8000373e:	f852                	sd	s4,48(sp)
    80003740:	f456                	sd	s5,40(sp)
    80003742:	f05a                	sd	s6,32(sp)
    80003744:	ec5e                	sd	s7,24(sp)
    80003746:	e862                	sd	s8,16(sp)
    80003748:	e466                	sd	s9,8(sp)
    8000374a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000374c:	0002c797          	auipc	a5,0x2c
    80003750:	2607a783          	lw	a5,608(a5) # 8002f9ac <sb+0x4>
    80003754:	cbd1                	beqz	a5,800037e8 <balloc+0xb6>
    80003756:	8baa                	mv	s7,a0
    80003758:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000375a:	0002cb17          	auipc	s6,0x2c
    8000375e:	24eb0b13          	addi	s6,s6,590 # 8002f9a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003762:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003764:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003766:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003768:	6c89                	lui	s9,0x2
    8000376a:	a831                	j	80003786 <balloc+0x54>
    brelse(bp);
    8000376c:	854a                	mv	a0,s2
    8000376e:	00000097          	auipc	ra,0x0
    80003772:	e32080e7          	jalr	-462(ra) # 800035a0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003776:	015c87bb          	addw	a5,s9,s5
    8000377a:	00078a9b          	sext.w	s5,a5
    8000377e:	004b2703          	lw	a4,4(s6)
    80003782:	06eaf363          	bgeu	s5,a4,800037e8 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003786:	41fad79b          	sraiw	a5,s5,0x1f
    8000378a:	0137d79b          	srliw	a5,a5,0x13
    8000378e:	015787bb          	addw	a5,a5,s5
    80003792:	40d7d79b          	sraiw	a5,a5,0xd
    80003796:	01cb2583          	lw	a1,28(s6)
    8000379a:	9dbd                	addw	a1,a1,a5
    8000379c:	855e                	mv	a0,s7
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	cd2080e7          	jalr	-814(ra) # 80003470 <bread>
    800037a6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037a8:	004b2503          	lw	a0,4(s6)
    800037ac:	000a849b          	sext.w	s1,s5
    800037b0:	8662                	mv	a2,s8
    800037b2:	faa4fde3          	bgeu	s1,a0,8000376c <balloc+0x3a>
      m = 1 << (bi % 8);
    800037b6:	41f6579b          	sraiw	a5,a2,0x1f
    800037ba:	01d7d69b          	srliw	a3,a5,0x1d
    800037be:	00c6873b          	addw	a4,a3,a2
    800037c2:	00777793          	andi	a5,a4,7
    800037c6:	9f95                	subw	a5,a5,a3
    800037c8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037cc:	4037571b          	sraiw	a4,a4,0x3
    800037d0:	00e906b3          	add	a3,s2,a4
    800037d4:	0586c683          	lbu	a3,88(a3)
    800037d8:	00d7f5b3          	and	a1,a5,a3
    800037dc:	cd91                	beqz	a1,800037f8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037de:	2605                	addiw	a2,a2,1
    800037e0:	2485                	addiw	s1,s1,1
    800037e2:	fd4618e3          	bne	a2,s4,800037b2 <balloc+0x80>
    800037e6:	b759                	j	8000376c <balloc+0x3a>
  panic("balloc: out of blocks");
    800037e8:	00005517          	auipc	a0,0x5
    800037ec:	e2050513          	addi	a0,a0,-480 # 80008608 <syscalls+0x108>
    800037f0:	ffffd097          	auipc	ra,0xffffd
    800037f4:	d3a080e7          	jalr	-710(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037f8:	974a                	add	a4,a4,s2
    800037fa:	8fd5                	or	a5,a5,a3
    800037fc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003800:	854a                	mv	a0,s2
    80003802:	00001097          	auipc	ra,0x1
    80003806:	368080e7          	jalr	872(ra) # 80004b6a <log_write>
        brelse(bp);
    8000380a:	854a                	mv	a0,s2
    8000380c:	00000097          	auipc	ra,0x0
    80003810:	d94080e7          	jalr	-620(ra) # 800035a0 <brelse>
  bp = bread(dev, bno);
    80003814:	85a6                	mv	a1,s1
    80003816:	855e                	mv	a0,s7
    80003818:	00000097          	auipc	ra,0x0
    8000381c:	c58080e7          	jalr	-936(ra) # 80003470 <bread>
    80003820:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003822:	40000613          	li	a2,1024
    80003826:	4581                	li	a1,0
    80003828:	05850513          	addi	a0,a0,88
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	492080e7          	jalr	1170(ra) # 80000cbe <memset>
  log_write(bp);
    80003834:	854a                	mv	a0,s2
    80003836:	00001097          	auipc	ra,0x1
    8000383a:	334080e7          	jalr	820(ra) # 80004b6a <log_write>
  brelse(bp);
    8000383e:	854a                	mv	a0,s2
    80003840:	00000097          	auipc	ra,0x0
    80003844:	d60080e7          	jalr	-672(ra) # 800035a0 <brelse>
}
    80003848:	8526                	mv	a0,s1
    8000384a:	60e6                	ld	ra,88(sp)
    8000384c:	6446                	ld	s0,80(sp)
    8000384e:	64a6                	ld	s1,72(sp)
    80003850:	6906                	ld	s2,64(sp)
    80003852:	79e2                	ld	s3,56(sp)
    80003854:	7a42                	ld	s4,48(sp)
    80003856:	7aa2                	ld	s5,40(sp)
    80003858:	7b02                	ld	s6,32(sp)
    8000385a:	6be2                	ld	s7,24(sp)
    8000385c:	6c42                	ld	s8,16(sp)
    8000385e:	6ca2                	ld	s9,8(sp)
    80003860:	6125                	addi	sp,sp,96
    80003862:	8082                	ret

0000000080003864 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003864:	7179                	addi	sp,sp,-48
    80003866:	f406                	sd	ra,40(sp)
    80003868:	f022                	sd	s0,32(sp)
    8000386a:	ec26                	sd	s1,24(sp)
    8000386c:	e84a                	sd	s2,16(sp)
    8000386e:	e44e                	sd	s3,8(sp)
    80003870:	e052                	sd	s4,0(sp)
    80003872:	1800                	addi	s0,sp,48
    80003874:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003876:	47ad                	li	a5,11
    80003878:	04b7fe63          	bgeu	a5,a1,800038d4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000387c:	ff45849b          	addiw	s1,a1,-12
    80003880:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003884:	0ff00793          	li	a5,255
    80003888:	0ae7e463          	bltu	a5,a4,80003930 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000388c:	08052583          	lw	a1,128(a0)
    80003890:	c5b5                	beqz	a1,800038fc <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003892:	00092503          	lw	a0,0(s2)
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	bda080e7          	jalr	-1062(ra) # 80003470 <bread>
    8000389e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038a0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038a4:	02049713          	slli	a4,s1,0x20
    800038a8:	01e75593          	srli	a1,a4,0x1e
    800038ac:	00b784b3          	add	s1,a5,a1
    800038b0:	0004a983          	lw	s3,0(s1)
    800038b4:	04098e63          	beqz	s3,80003910 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800038b8:	8552                	mv	a0,s4
    800038ba:	00000097          	auipc	ra,0x0
    800038be:	ce6080e7          	jalr	-794(ra) # 800035a0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038c2:	854e                	mv	a0,s3
    800038c4:	70a2                	ld	ra,40(sp)
    800038c6:	7402                	ld	s0,32(sp)
    800038c8:	64e2                	ld	s1,24(sp)
    800038ca:	6942                	ld	s2,16(sp)
    800038cc:	69a2                	ld	s3,8(sp)
    800038ce:	6a02                	ld	s4,0(sp)
    800038d0:	6145                	addi	sp,sp,48
    800038d2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800038d4:	02059793          	slli	a5,a1,0x20
    800038d8:	01e7d593          	srli	a1,a5,0x1e
    800038dc:	00b504b3          	add	s1,a0,a1
    800038e0:	0504a983          	lw	s3,80(s1)
    800038e4:	fc099fe3          	bnez	s3,800038c2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800038e8:	4108                	lw	a0,0(a0)
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	e48080e7          	jalr	-440(ra) # 80003732 <balloc>
    800038f2:	0005099b          	sext.w	s3,a0
    800038f6:	0534a823          	sw	s3,80(s1)
    800038fa:	b7e1                	j	800038c2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800038fc:	4108                	lw	a0,0(a0)
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	e34080e7          	jalr	-460(ra) # 80003732 <balloc>
    80003906:	0005059b          	sext.w	a1,a0
    8000390a:	08b92023          	sw	a1,128(s2)
    8000390e:	b751                	j	80003892 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003910:	00092503          	lw	a0,0(s2)
    80003914:	00000097          	auipc	ra,0x0
    80003918:	e1e080e7          	jalr	-482(ra) # 80003732 <balloc>
    8000391c:	0005099b          	sext.w	s3,a0
    80003920:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003924:	8552                	mv	a0,s4
    80003926:	00001097          	auipc	ra,0x1
    8000392a:	244080e7          	jalr	580(ra) # 80004b6a <log_write>
    8000392e:	b769                	j	800038b8 <bmap+0x54>
  panic("bmap: out of range");
    80003930:	00005517          	auipc	a0,0x5
    80003934:	cf050513          	addi	a0,a0,-784 # 80008620 <syscalls+0x120>
    80003938:	ffffd097          	auipc	ra,0xffffd
    8000393c:	bf2080e7          	jalr	-1038(ra) # 8000052a <panic>

0000000080003940 <iget>:
{
    80003940:	7179                	addi	sp,sp,-48
    80003942:	f406                	sd	ra,40(sp)
    80003944:	f022                	sd	s0,32(sp)
    80003946:	ec26                	sd	s1,24(sp)
    80003948:	e84a                	sd	s2,16(sp)
    8000394a:	e44e                	sd	s3,8(sp)
    8000394c:	e052                	sd	s4,0(sp)
    8000394e:	1800                	addi	s0,sp,48
    80003950:	89aa                	mv	s3,a0
    80003952:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003954:	0002c517          	auipc	a0,0x2c
    80003958:	07450513          	addi	a0,a0,116 # 8002f9c8 <itable>
    8000395c:	ffffd097          	auipc	ra,0xffffd
    80003960:	266080e7          	jalr	614(ra) # 80000bc2 <acquire>
  empty = 0;
    80003964:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003966:	0002c497          	auipc	s1,0x2c
    8000396a:	07a48493          	addi	s1,s1,122 # 8002f9e0 <itable+0x18>
    8000396e:	0002e697          	auipc	a3,0x2e
    80003972:	b0268693          	addi	a3,a3,-1278 # 80031470 <log>
    80003976:	a039                	j	80003984 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003978:	02090b63          	beqz	s2,800039ae <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000397c:	08848493          	addi	s1,s1,136
    80003980:	02d48a63          	beq	s1,a3,800039b4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003984:	449c                	lw	a5,8(s1)
    80003986:	fef059e3          	blez	a5,80003978 <iget+0x38>
    8000398a:	4098                	lw	a4,0(s1)
    8000398c:	ff3716e3          	bne	a4,s3,80003978 <iget+0x38>
    80003990:	40d8                	lw	a4,4(s1)
    80003992:	ff4713e3          	bne	a4,s4,80003978 <iget+0x38>
      ip->ref++;
    80003996:	2785                	addiw	a5,a5,1
    80003998:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000399a:	0002c517          	auipc	a0,0x2c
    8000399e:	02e50513          	addi	a0,a0,46 # 8002f9c8 <itable>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	2d4080e7          	jalr	724(ra) # 80000c76 <release>
      return ip;
    800039aa:	8926                	mv	s2,s1
    800039ac:	a03d                	j	800039da <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039ae:	f7f9                	bnez	a5,8000397c <iget+0x3c>
    800039b0:	8926                	mv	s2,s1
    800039b2:	b7e9                	j	8000397c <iget+0x3c>
  if(empty == 0)
    800039b4:	02090c63          	beqz	s2,800039ec <iget+0xac>
  ip->dev = dev;
    800039b8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039bc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039c0:	4785                	li	a5,1
    800039c2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039c6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800039ca:	0002c517          	auipc	a0,0x2c
    800039ce:	ffe50513          	addi	a0,a0,-2 # 8002f9c8 <itable>
    800039d2:	ffffd097          	auipc	ra,0xffffd
    800039d6:	2a4080e7          	jalr	676(ra) # 80000c76 <release>
}
    800039da:	854a                	mv	a0,s2
    800039dc:	70a2                	ld	ra,40(sp)
    800039de:	7402                	ld	s0,32(sp)
    800039e0:	64e2                	ld	s1,24(sp)
    800039e2:	6942                	ld	s2,16(sp)
    800039e4:	69a2                	ld	s3,8(sp)
    800039e6:	6a02                	ld	s4,0(sp)
    800039e8:	6145                	addi	sp,sp,48
    800039ea:	8082                	ret
    panic("iget: no inodes");
    800039ec:	00005517          	auipc	a0,0x5
    800039f0:	c4c50513          	addi	a0,a0,-948 # 80008638 <syscalls+0x138>
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	b36080e7          	jalr	-1226(ra) # 8000052a <panic>

00000000800039fc <fsinit>:
fsinit(int dev) {
    800039fc:	7179                	addi	sp,sp,-48
    800039fe:	f406                	sd	ra,40(sp)
    80003a00:	f022                	sd	s0,32(sp)
    80003a02:	ec26                	sd	s1,24(sp)
    80003a04:	e84a                	sd	s2,16(sp)
    80003a06:	e44e                	sd	s3,8(sp)
    80003a08:	1800                	addi	s0,sp,48
    80003a0a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a0c:	4585                	li	a1,1
    80003a0e:	00000097          	auipc	ra,0x0
    80003a12:	a62080e7          	jalr	-1438(ra) # 80003470 <bread>
    80003a16:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a18:	0002c997          	auipc	s3,0x2c
    80003a1c:	f9098993          	addi	s3,s3,-112 # 8002f9a8 <sb>
    80003a20:	02000613          	li	a2,32
    80003a24:	05850593          	addi	a1,a0,88
    80003a28:	854e                	mv	a0,s3
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	2f0080e7          	jalr	752(ra) # 80000d1a <memmove>
  brelse(bp);
    80003a32:	8526                	mv	a0,s1
    80003a34:	00000097          	auipc	ra,0x0
    80003a38:	b6c080e7          	jalr	-1172(ra) # 800035a0 <brelse>
  if(sb.magic != FSMAGIC)
    80003a3c:	0009a703          	lw	a4,0(s3)
    80003a40:	102037b7          	lui	a5,0x10203
    80003a44:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a48:	02f71263          	bne	a4,a5,80003a6c <fsinit+0x70>
  initlog(dev, &sb);
    80003a4c:	0002c597          	auipc	a1,0x2c
    80003a50:	f5c58593          	addi	a1,a1,-164 # 8002f9a8 <sb>
    80003a54:	854a                	mv	a0,s2
    80003a56:	00001097          	auipc	ra,0x1
    80003a5a:	e96080e7          	jalr	-362(ra) # 800048ec <initlog>
}
    80003a5e:	70a2                	ld	ra,40(sp)
    80003a60:	7402                	ld	s0,32(sp)
    80003a62:	64e2                	ld	s1,24(sp)
    80003a64:	6942                	ld	s2,16(sp)
    80003a66:	69a2                	ld	s3,8(sp)
    80003a68:	6145                	addi	sp,sp,48
    80003a6a:	8082                	ret
    panic("invalid file system");
    80003a6c:	00005517          	auipc	a0,0x5
    80003a70:	bdc50513          	addi	a0,a0,-1060 # 80008648 <syscalls+0x148>
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	ab6080e7          	jalr	-1354(ra) # 8000052a <panic>

0000000080003a7c <iinit>:
{
    80003a7c:	7179                	addi	sp,sp,-48
    80003a7e:	f406                	sd	ra,40(sp)
    80003a80:	f022                	sd	s0,32(sp)
    80003a82:	ec26                	sd	s1,24(sp)
    80003a84:	e84a                	sd	s2,16(sp)
    80003a86:	e44e                	sd	s3,8(sp)
    80003a88:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a8a:	00005597          	auipc	a1,0x5
    80003a8e:	bd658593          	addi	a1,a1,-1066 # 80008660 <syscalls+0x160>
    80003a92:	0002c517          	auipc	a0,0x2c
    80003a96:	f3650513          	addi	a0,a0,-202 # 8002f9c8 <itable>
    80003a9a:	ffffd097          	auipc	ra,0xffffd
    80003a9e:	098080e7          	jalr	152(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003aa2:	0002c497          	auipc	s1,0x2c
    80003aa6:	f4e48493          	addi	s1,s1,-178 # 8002f9f0 <itable+0x28>
    80003aaa:	0002e997          	auipc	s3,0x2e
    80003aae:	9d698993          	addi	s3,s3,-1578 # 80031480 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ab2:	00005917          	auipc	s2,0x5
    80003ab6:	bb690913          	addi	s2,s2,-1098 # 80008668 <syscalls+0x168>
    80003aba:	85ca                	mv	a1,s2
    80003abc:	8526                	mv	a0,s1
    80003abe:	00001097          	auipc	ra,0x1
    80003ac2:	192080e7          	jalr	402(ra) # 80004c50 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ac6:	08848493          	addi	s1,s1,136
    80003aca:	ff3498e3          	bne	s1,s3,80003aba <iinit+0x3e>
}
    80003ace:	70a2                	ld	ra,40(sp)
    80003ad0:	7402                	ld	s0,32(sp)
    80003ad2:	64e2                	ld	s1,24(sp)
    80003ad4:	6942                	ld	s2,16(sp)
    80003ad6:	69a2                	ld	s3,8(sp)
    80003ad8:	6145                	addi	sp,sp,48
    80003ada:	8082                	ret

0000000080003adc <ialloc>:
{
    80003adc:	715d                	addi	sp,sp,-80
    80003ade:	e486                	sd	ra,72(sp)
    80003ae0:	e0a2                	sd	s0,64(sp)
    80003ae2:	fc26                	sd	s1,56(sp)
    80003ae4:	f84a                	sd	s2,48(sp)
    80003ae6:	f44e                	sd	s3,40(sp)
    80003ae8:	f052                	sd	s4,32(sp)
    80003aea:	ec56                	sd	s5,24(sp)
    80003aec:	e85a                	sd	s6,16(sp)
    80003aee:	e45e                	sd	s7,8(sp)
    80003af0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003af2:	0002c717          	auipc	a4,0x2c
    80003af6:	ec272703          	lw	a4,-318(a4) # 8002f9b4 <sb+0xc>
    80003afa:	4785                	li	a5,1
    80003afc:	04e7fa63          	bgeu	a5,a4,80003b50 <ialloc+0x74>
    80003b00:	8aaa                	mv	s5,a0
    80003b02:	8bae                	mv	s7,a1
    80003b04:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b06:	0002ca17          	auipc	s4,0x2c
    80003b0a:	ea2a0a13          	addi	s4,s4,-350 # 8002f9a8 <sb>
    80003b0e:	00048b1b          	sext.w	s6,s1
    80003b12:	0044d793          	srli	a5,s1,0x4
    80003b16:	018a2583          	lw	a1,24(s4)
    80003b1a:	9dbd                	addw	a1,a1,a5
    80003b1c:	8556                	mv	a0,s5
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	952080e7          	jalr	-1710(ra) # 80003470 <bread>
    80003b26:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b28:	05850993          	addi	s3,a0,88
    80003b2c:	00f4f793          	andi	a5,s1,15
    80003b30:	079a                	slli	a5,a5,0x6
    80003b32:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b34:	00099783          	lh	a5,0(s3)
    80003b38:	c785                	beqz	a5,80003b60 <ialloc+0x84>
    brelse(bp);
    80003b3a:	00000097          	auipc	ra,0x0
    80003b3e:	a66080e7          	jalr	-1434(ra) # 800035a0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b42:	0485                	addi	s1,s1,1
    80003b44:	00ca2703          	lw	a4,12(s4)
    80003b48:	0004879b          	sext.w	a5,s1
    80003b4c:	fce7e1e3          	bltu	a5,a4,80003b0e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003b50:	00005517          	auipc	a0,0x5
    80003b54:	b2050513          	addi	a0,a0,-1248 # 80008670 <syscalls+0x170>
    80003b58:	ffffd097          	auipc	ra,0xffffd
    80003b5c:	9d2080e7          	jalr	-1582(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003b60:	04000613          	li	a2,64
    80003b64:	4581                	li	a1,0
    80003b66:	854e                	mv	a0,s3
    80003b68:	ffffd097          	auipc	ra,0xffffd
    80003b6c:	156080e7          	jalr	342(ra) # 80000cbe <memset>
      dip->type = type;
    80003b70:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b74:	854a                	mv	a0,s2
    80003b76:	00001097          	auipc	ra,0x1
    80003b7a:	ff4080e7          	jalr	-12(ra) # 80004b6a <log_write>
      brelse(bp);
    80003b7e:	854a                	mv	a0,s2
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	a20080e7          	jalr	-1504(ra) # 800035a0 <brelse>
      return iget(dev, inum);
    80003b88:	85da                	mv	a1,s6
    80003b8a:	8556                	mv	a0,s5
    80003b8c:	00000097          	auipc	ra,0x0
    80003b90:	db4080e7          	jalr	-588(ra) # 80003940 <iget>
}
    80003b94:	60a6                	ld	ra,72(sp)
    80003b96:	6406                	ld	s0,64(sp)
    80003b98:	74e2                	ld	s1,56(sp)
    80003b9a:	7942                	ld	s2,48(sp)
    80003b9c:	79a2                	ld	s3,40(sp)
    80003b9e:	7a02                	ld	s4,32(sp)
    80003ba0:	6ae2                	ld	s5,24(sp)
    80003ba2:	6b42                	ld	s6,16(sp)
    80003ba4:	6ba2                	ld	s7,8(sp)
    80003ba6:	6161                	addi	sp,sp,80
    80003ba8:	8082                	ret

0000000080003baa <iupdate>:
{
    80003baa:	1101                	addi	sp,sp,-32
    80003bac:	ec06                	sd	ra,24(sp)
    80003bae:	e822                	sd	s0,16(sp)
    80003bb0:	e426                	sd	s1,8(sp)
    80003bb2:	e04a                	sd	s2,0(sp)
    80003bb4:	1000                	addi	s0,sp,32
    80003bb6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bb8:	415c                	lw	a5,4(a0)
    80003bba:	0047d79b          	srliw	a5,a5,0x4
    80003bbe:	0002c597          	auipc	a1,0x2c
    80003bc2:	e025a583          	lw	a1,-510(a1) # 8002f9c0 <sb+0x18>
    80003bc6:	9dbd                	addw	a1,a1,a5
    80003bc8:	4108                	lw	a0,0(a0)
    80003bca:	00000097          	auipc	ra,0x0
    80003bce:	8a6080e7          	jalr	-1882(ra) # 80003470 <bread>
    80003bd2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bd4:	05850793          	addi	a5,a0,88
    80003bd8:	40c8                	lw	a0,4(s1)
    80003bda:	893d                	andi	a0,a0,15
    80003bdc:	051a                	slli	a0,a0,0x6
    80003bde:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003be0:	04449703          	lh	a4,68(s1)
    80003be4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003be8:	04649703          	lh	a4,70(s1)
    80003bec:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003bf0:	04849703          	lh	a4,72(s1)
    80003bf4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003bf8:	04a49703          	lh	a4,74(s1)
    80003bfc:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c00:	44f8                	lw	a4,76(s1)
    80003c02:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c04:	03400613          	li	a2,52
    80003c08:	05048593          	addi	a1,s1,80
    80003c0c:	0531                	addi	a0,a0,12
    80003c0e:	ffffd097          	auipc	ra,0xffffd
    80003c12:	10c080e7          	jalr	268(ra) # 80000d1a <memmove>
  log_write(bp);
    80003c16:	854a                	mv	a0,s2
    80003c18:	00001097          	auipc	ra,0x1
    80003c1c:	f52080e7          	jalr	-174(ra) # 80004b6a <log_write>
  brelse(bp);
    80003c20:	854a                	mv	a0,s2
    80003c22:	00000097          	auipc	ra,0x0
    80003c26:	97e080e7          	jalr	-1666(ra) # 800035a0 <brelse>
}
    80003c2a:	60e2                	ld	ra,24(sp)
    80003c2c:	6442                	ld	s0,16(sp)
    80003c2e:	64a2                	ld	s1,8(sp)
    80003c30:	6902                	ld	s2,0(sp)
    80003c32:	6105                	addi	sp,sp,32
    80003c34:	8082                	ret

0000000080003c36 <idup>:
{
    80003c36:	1101                	addi	sp,sp,-32
    80003c38:	ec06                	sd	ra,24(sp)
    80003c3a:	e822                	sd	s0,16(sp)
    80003c3c:	e426                	sd	s1,8(sp)
    80003c3e:	1000                	addi	s0,sp,32
    80003c40:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c42:	0002c517          	auipc	a0,0x2c
    80003c46:	d8650513          	addi	a0,a0,-634 # 8002f9c8 <itable>
    80003c4a:	ffffd097          	auipc	ra,0xffffd
    80003c4e:	f78080e7          	jalr	-136(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003c52:	449c                	lw	a5,8(s1)
    80003c54:	2785                	addiw	a5,a5,1
    80003c56:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c58:	0002c517          	auipc	a0,0x2c
    80003c5c:	d7050513          	addi	a0,a0,-656 # 8002f9c8 <itable>
    80003c60:	ffffd097          	auipc	ra,0xffffd
    80003c64:	016080e7          	jalr	22(ra) # 80000c76 <release>
}
    80003c68:	8526                	mv	a0,s1
    80003c6a:	60e2                	ld	ra,24(sp)
    80003c6c:	6442                	ld	s0,16(sp)
    80003c6e:	64a2                	ld	s1,8(sp)
    80003c70:	6105                	addi	sp,sp,32
    80003c72:	8082                	ret

0000000080003c74 <ilock>:
{
    80003c74:	1101                	addi	sp,sp,-32
    80003c76:	ec06                	sd	ra,24(sp)
    80003c78:	e822                	sd	s0,16(sp)
    80003c7a:	e426                	sd	s1,8(sp)
    80003c7c:	e04a                	sd	s2,0(sp)
    80003c7e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c80:	c115                	beqz	a0,80003ca4 <ilock+0x30>
    80003c82:	84aa                	mv	s1,a0
    80003c84:	451c                	lw	a5,8(a0)
    80003c86:	00f05f63          	blez	a5,80003ca4 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c8a:	0541                	addi	a0,a0,16
    80003c8c:	00001097          	auipc	ra,0x1
    80003c90:	ffe080e7          	jalr	-2(ra) # 80004c8a <acquiresleep>
  if(ip->valid == 0){
    80003c94:	40bc                	lw	a5,64(s1)
    80003c96:	cf99                	beqz	a5,80003cb4 <ilock+0x40>
}
    80003c98:	60e2                	ld	ra,24(sp)
    80003c9a:	6442                	ld	s0,16(sp)
    80003c9c:	64a2                	ld	s1,8(sp)
    80003c9e:	6902                	ld	s2,0(sp)
    80003ca0:	6105                	addi	sp,sp,32
    80003ca2:	8082                	ret
    panic("ilock");
    80003ca4:	00005517          	auipc	a0,0x5
    80003ca8:	9e450513          	addi	a0,a0,-1564 # 80008688 <syscalls+0x188>
    80003cac:	ffffd097          	auipc	ra,0xffffd
    80003cb0:	87e080e7          	jalr	-1922(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cb4:	40dc                	lw	a5,4(s1)
    80003cb6:	0047d79b          	srliw	a5,a5,0x4
    80003cba:	0002c597          	auipc	a1,0x2c
    80003cbe:	d065a583          	lw	a1,-762(a1) # 8002f9c0 <sb+0x18>
    80003cc2:	9dbd                	addw	a1,a1,a5
    80003cc4:	4088                	lw	a0,0(s1)
    80003cc6:	fffff097          	auipc	ra,0xfffff
    80003cca:	7aa080e7          	jalr	1962(ra) # 80003470 <bread>
    80003cce:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cd0:	05850593          	addi	a1,a0,88
    80003cd4:	40dc                	lw	a5,4(s1)
    80003cd6:	8bbd                	andi	a5,a5,15
    80003cd8:	079a                	slli	a5,a5,0x6
    80003cda:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003cdc:	00059783          	lh	a5,0(a1)
    80003ce0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ce4:	00259783          	lh	a5,2(a1)
    80003ce8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cec:	00459783          	lh	a5,4(a1)
    80003cf0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cf4:	00659783          	lh	a5,6(a1)
    80003cf8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003cfc:	459c                	lw	a5,8(a1)
    80003cfe:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d00:	03400613          	li	a2,52
    80003d04:	05b1                	addi	a1,a1,12
    80003d06:	05048513          	addi	a0,s1,80
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	010080e7          	jalr	16(ra) # 80000d1a <memmove>
    brelse(bp);
    80003d12:	854a                	mv	a0,s2
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	88c080e7          	jalr	-1908(ra) # 800035a0 <brelse>
    ip->valid = 1;
    80003d1c:	4785                	li	a5,1
    80003d1e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d20:	04449783          	lh	a5,68(s1)
    80003d24:	fbb5                	bnez	a5,80003c98 <ilock+0x24>
      panic("ilock: no type");
    80003d26:	00005517          	auipc	a0,0x5
    80003d2a:	96a50513          	addi	a0,a0,-1686 # 80008690 <syscalls+0x190>
    80003d2e:	ffffc097          	auipc	ra,0xffffc
    80003d32:	7fc080e7          	jalr	2044(ra) # 8000052a <panic>

0000000080003d36 <iunlock>:
{
    80003d36:	1101                	addi	sp,sp,-32
    80003d38:	ec06                	sd	ra,24(sp)
    80003d3a:	e822                	sd	s0,16(sp)
    80003d3c:	e426                	sd	s1,8(sp)
    80003d3e:	e04a                	sd	s2,0(sp)
    80003d40:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d42:	c905                	beqz	a0,80003d72 <iunlock+0x3c>
    80003d44:	84aa                	mv	s1,a0
    80003d46:	01050913          	addi	s2,a0,16
    80003d4a:	854a                	mv	a0,s2
    80003d4c:	00001097          	auipc	ra,0x1
    80003d50:	fd8080e7          	jalr	-40(ra) # 80004d24 <holdingsleep>
    80003d54:	cd19                	beqz	a0,80003d72 <iunlock+0x3c>
    80003d56:	449c                	lw	a5,8(s1)
    80003d58:	00f05d63          	blez	a5,80003d72 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d5c:	854a                	mv	a0,s2
    80003d5e:	00001097          	auipc	ra,0x1
    80003d62:	f82080e7          	jalr	-126(ra) # 80004ce0 <releasesleep>
}
    80003d66:	60e2                	ld	ra,24(sp)
    80003d68:	6442                	ld	s0,16(sp)
    80003d6a:	64a2                	ld	s1,8(sp)
    80003d6c:	6902                	ld	s2,0(sp)
    80003d6e:	6105                	addi	sp,sp,32
    80003d70:	8082                	ret
    panic("iunlock");
    80003d72:	00005517          	auipc	a0,0x5
    80003d76:	92e50513          	addi	a0,a0,-1746 # 800086a0 <syscalls+0x1a0>
    80003d7a:	ffffc097          	auipc	ra,0xffffc
    80003d7e:	7b0080e7          	jalr	1968(ra) # 8000052a <panic>

0000000080003d82 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d82:	7179                	addi	sp,sp,-48
    80003d84:	f406                	sd	ra,40(sp)
    80003d86:	f022                	sd	s0,32(sp)
    80003d88:	ec26                	sd	s1,24(sp)
    80003d8a:	e84a                	sd	s2,16(sp)
    80003d8c:	e44e                	sd	s3,8(sp)
    80003d8e:	e052                	sd	s4,0(sp)
    80003d90:	1800                	addi	s0,sp,48
    80003d92:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d94:	05050493          	addi	s1,a0,80
    80003d98:	08050913          	addi	s2,a0,128
    80003d9c:	a021                	j	80003da4 <itrunc+0x22>
    80003d9e:	0491                	addi	s1,s1,4
    80003da0:	01248d63          	beq	s1,s2,80003dba <itrunc+0x38>
    if(ip->addrs[i]){
    80003da4:	408c                	lw	a1,0(s1)
    80003da6:	dde5                	beqz	a1,80003d9e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003da8:	0009a503          	lw	a0,0(s3)
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	90a080e7          	jalr	-1782(ra) # 800036b6 <bfree>
      ip->addrs[i] = 0;
    80003db4:	0004a023          	sw	zero,0(s1)
    80003db8:	b7dd                	j	80003d9e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003dba:	0809a583          	lw	a1,128(s3)
    80003dbe:	e185                	bnez	a1,80003dde <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dc0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dc4:	854e                	mv	a0,s3
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	de4080e7          	jalr	-540(ra) # 80003baa <iupdate>
}
    80003dce:	70a2                	ld	ra,40(sp)
    80003dd0:	7402                	ld	s0,32(sp)
    80003dd2:	64e2                	ld	s1,24(sp)
    80003dd4:	6942                	ld	s2,16(sp)
    80003dd6:	69a2                	ld	s3,8(sp)
    80003dd8:	6a02                	ld	s4,0(sp)
    80003dda:	6145                	addi	sp,sp,48
    80003ddc:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dde:	0009a503          	lw	a0,0(s3)
    80003de2:	fffff097          	auipc	ra,0xfffff
    80003de6:	68e080e7          	jalr	1678(ra) # 80003470 <bread>
    80003dea:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003dec:	05850493          	addi	s1,a0,88
    80003df0:	45850913          	addi	s2,a0,1112
    80003df4:	a021                	j	80003dfc <itrunc+0x7a>
    80003df6:	0491                	addi	s1,s1,4
    80003df8:	01248b63          	beq	s1,s2,80003e0e <itrunc+0x8c>
      if(a[j])
    80003dfc:	408c                	lw	a1,0(s1)
    80003dfe:	dde5                	beqz	a1,80003df6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e00:	0009a503          	lw	a0,0(s3)
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	8b2080e7          	jalr	-1870(ra) # 800036b6 <bfree>
    80003e0c:	b7ed                	j	80003df6 <itrunc+0x74>
    brelse(bp);
    80003e0e:	8552                	mv	a0,s4
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	790080e7          	jalr	1936(ra) # 800035a0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e18:	0809a583          	lw	a1,128(s3)
    80003e1c:	0009a503          	lw	a0,0(s3)
    80003e20:	00000097          	auipc	ra,0x0
    80003e24:	896080e7          	jalr	-1898(ra) # 800036b6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e28:	0809a023          	sw	zero,128(s3)
    80003e2c:	bf51                	j	80003dc0 <itrunc+0x3e>

0000000080003e2e <iput>:
{
    80003e2e:	1101                	addi	sp,sp,-32
    80003e30:	ec06                	sd	ra,24(sp)
    80003e32:	e822                	sd	s0,16(sp)
    80003e34:	e426                	sd	s1,8(sp)
    80003e36:	e04a                	sd	s2,0(sp)
    80003e38:	1000                	addi	s0,sp,32
    80003e3a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e3c:	0002c517          	auipc	a0,0x2c
    80003e40:	b8c50513          	addi	a0,a0,-1140 # 8002f9c8 <itable>
    80003e44:	ffffd097          	auipc	ra,0xffffd
    80003e48:	d7e080e7          	jalr	-642(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e4c:	4498                	lw	a4,8(s1)
    80003e4e:	4785                	li	a5,1
    80003e50:	02f70363          	beq	a4,a5,80003e76 <iput+0x48>
  ip->ref--;
    80003e54:	449c                	lw	a5,8(s1)
    80003e56:	37fd                	addiw	a5,a5,-1
    80003e58:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e5a:	0002c517          	auipc	a0,0x2c
    80003e5e:	b6e50513          	addi	a0,a0,-1170 # 8002f9c8 <itable>
    80003e62:	ffffd097          	auipc	ra,0xffffd
    80003e66:	e14080e7          	jalr	-492(ra) # 80000c76 <release>
}
    80003e6a:	60e2                	ld	ra,24(sp)
    80003e6c:	6442                	ld	s0,16(sp)
    80003e6e:	64a2                	ld	s1,8(sp)
    80003e70:	6902                	ld	s2,0(sp)
    80003e72:	6105                	addi	sp,sp,32
    80003e74:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e76:	40bc                	lw	a5,64(s1)
    80003e78:	dff1                	beqz	a5,80003e54 <iput+0x26>
    80003e7a:	04a49783          	lh	a5,74(s1)
    80003e7e:	fbf9                	bnez	a5,80003e54 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e80:	01048913          	addi	s2,s1,16
    80003e84:	854a                	mv	a0,s2
    80003e86:	00001097          	auipc	ra,0x1
    80003e8a:	e04080e7          	jalr	-508(ra) # 80004c8a <acquiresleep>
    release(&itable.lock);
    80003e8e:	0002c517          	auipc	a0,0x2c
    80003e92:	b3a50513          	addi	a0,a0,-1222 # 8002f9c8 <itable>
    80003e96:	ffffd097          	auipc	ra,0xffffd
    80003e9a:	de0080e7          	jalr	-544(ra) # 80000c76 <release>
    itrunc(ip);
    80003e9e:	8526                	mv	a0,s1
    80003ea0:	00000097          	auipc	ra,0x0
    80003ea4:	ee2080e7          	jalr	-286(ra) # 80003d82 <itrunc>
    ip->type = 0;
    80003ea8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003eac:	8526                	mv	a0,s1
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	cfc080e7          	jalr	-772(ra) # 80003baa <iupdate>
    ip->valid = 0;
    80003eb6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003eba:	854a                	mv	a0,s2
    80003ebc:	00001097          	auipc	ra,0x1
    80003ec0:	e24080e7          	jalr	-476(ra) # 80004ce0 <releasesleep>
    acquire(&itable.lock);
    80003ec4:	0002c517          	auipc	a0,0x2c
    80003ec8:	b0450513          	addi	a0,a0,-1276 # 8002f9c8 <itable>
    80003ecc:	ffffd097          	auipc	ra,0xffffd
    80003ed0:	cf6080e7          	jalr	-778(ra) # 80000bc2 <acquire>
    80003ed4:	b741                	j	80003e54 <iput+0x26>

0000000080003ed6 <iunlockput>:
{
    80003ed6:	1101                	addi	sp,sp,-32
    80003ed8:	ec06                	sd	ra,24(sp)
    80003eda:	e822                	sd	s0,16(sp)
    80003edc:	e426                	sd	s1,8(sp)
    80003ede:	1000                	addi	s0,sp,32
    80003ee0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	e54080e7          	jalr	-428(ra) # 80003d36 <iunlock>
  iput(ip);
    80003eea:	8526                	mv	a0,s1
    80003eec:	00000097          	auipc	ra,0x0
    80003ef0:	f42080e7          	jalr	-190(ra) # 80003e2e <iput>
}
    80003ef4:	60e2                	ld	ra,24(sp)
    80003ef6:	6442                	ld	s0,16(sp)
    80003ef8:	64a2                	ld	s1,8(sp)
    80003efa:	6105                	addi	sp,sp,32
    80003efc:	8082                	ret

0000000080003efe <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003efe:	1141                	addi	sp,sp,-16
    80003f00:	e422                	sd	s0,8(sp)
    80003f02:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f04:	411c                	lw	a5,0(a0)
    80003f06:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f08:	415c                	lw	a5,4(a0)
    80003f0a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f0c:	04451783          	lh	a5,68(a0)
    80003f10:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f14:	04a51783          	lh	a5,74(a0)
    80003f18:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f1c:	04c56783          	lwu	a5,76(a0)
    80003f20:	e99c                	sd	a5,16(a1)
}
    80003f22:	6422                	ld	s0,8(sp)
    80003f24:	0141                	addi	sp,sp,16
    80003f26:	8082                	ret

0000000080003f28 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f28:	457c                	lw	a5,76(a0)
    80003f2a:	0ed7e963          	bltu	a5,a3,8000401c <readi+0xf4>
{
    80003f2e:	7159                	addi	sp,sp,-112
    80003f30:	f486                	sd	ra,104(sp)
    80003f32:	f0a2                	sd	s0,96(sp)
    80003f34:	eca6                	sd	s1,88(sp)
    80003f36:	e8ca                	sd	s2,80(sp)
    80003f38:	e4ce                	sd	s3,72(sp)
    80003f3a:	e0d2                	sd	s4,64(sp)
    80003f3c:	fc56                	sd	s5,56(sp)
    80003f3e:	f85a                	sd	s6,48(sp)
    80003f40:	f45e                	sd	s7,40(sp)
    80003f42:	f062                	sd	s8,32(sp)
    80003f44:	ec66                	sd	s9,24(sp)
    80003f46:	e86a                	sd	s10,16(sp)
    80003f48:	e46e                	sd	s11,8(sp)
    80003f4a:	1880                	addi	s0,sp,112
    80003f4c:	8baa                	mv	s7,a0
    80003f4e:	8c2e                	mv	s8,a1
    80003f50:	8ab2                	mv	s5,a2
    80003f52:	84b6                	mv	s1,a3
    80003f54:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f56:	9f35                	addw	a4,a4,a3
    return 0;
    80003f58:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f5a:	0ad76063          	bltu	a4,a3,80003ffa <readi+0xd2>
  if(off + n > ip->size)
    80003f5e:	00e7f463          	bgeu	a5,a4,80003f66 <readi+0x3e>
    n = ip->size - off;
    80003f62:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f66:	0a0b0963          	beqz	s6,80004018 <readi+0xf0>
    80003f6a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f6c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f70:	5cfd                	li	s9,-1
    80003f72:	a82d                	j	80003fac <readi+0x84>
    80003f74:	020a1d93          	slli	s11,s4,0x20
    80003f78:	020ddd93          	srli	s11,s11,0x20
    80003f7c:	05890793          	addi	a5,s2,88
    80003f80:	86ee                	mv	a3,s11
    80003f82:	963e                	add	a2,a2,a5
    80003f84:	85d6                	mv	a1,s5
    80003f86:	8562                	mv	a0,s8
    80003f88:	fffff097          	auipc	ra,0xfffff
    80003f8c:	a58080e7          	jalr	-1448(ra) # 800029e0 <either_copyout>
    80003f90:	05950d63          	beq	a0,s9,80003fea <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f94:	854a                	mv	a0,s2
    80003f96:	fffff097          	auipc	ra,0xfffff
    80003f9a:	60a080e7          	jalr	1546(ra) # 800035a0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f9e:	013a09bb          	addw	s3,s4,s3
    80003fa2:	009a04bb          	addw	s1,s4,s1
    80003fa6:	9aee                	add	s5,s5,s11
    80003fa8:	0569f763          	bgeu	s3,s6,80003ff6 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fac:	000ba903          	lw	s2,0(s7)
    80003fb0:	00a4d59b          	srliw	a1,s1,0xa
    80003fb4:	855e                	mv	a0,s7
    80003fb6:	00000097          	auipc	ra,0x0
    80003fba:	8ae080e7          	jalr	-1874(ra) # 80003864 <bmap>
    80003fbe:	0005059b          	sext.w	a1,a0
    80003fc2:	854a                	mv	a0,s2
    80003fc4:	fffff097          	auipc	ra,0xfffff
    80003fc8:	4ac080e7          	jalr	1196(ra) # 80003470 <bread>
    80003fcc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fce:	3ff4f613          	andi	a2,s1,1023
    80003fd2:	40cd07bb          	subw	a5,s10,a2
    80003fd6:	413b073b          	subw	a4,s6,s3
    80003fda:	8a3e                	mv	s4,a5
    80003fdc:	2781                	sext.w	a5,a5
    80003fde:	0007069b          	sext.w	a3,a4
    80003fe2:	f8f6f9e3          	bgeu	a3,a5,80003f74 <readi+0x4c>
    80003fe6:	8a3a                	mv	s4,a4
    80003fe8:	b771                	j	80003f74 <readi+0x4c>
      brelse(bp);
    80003fea:	854a                	mv	a0,s2
    80003fec:	fffff097          	auipc	ra,0xfffff
    80003ff0:	5b4080e7          	jalr	1460(ra) # 800035a0 <brelse>
      tot = -1;
    80003ff4:	59fd                	li	s3,-1
  }
  return tot;
    80003ff6:	0009851b          	sext.w	a0,s3
}
    80003ffa:	70a6                	ld	ra,104(sp)
    80003ffc:	7406                	ld	s0,96(sp)
    80003ffe:	64e6                	ld	s1,88(sp)
    80004000:	6946                	ld	s2,80(sp)
    80004002:	69a6                	ld	s3,72(sp)
    80004004:	6a06                	ld	s4,64(sp)
    80004006:	7ae2                	ld	s5,56(sp)
    80004008:	7b42                	ld	s6,48(sp)
    8000400a:	7ba2                	ld	s7,40(sp)
    8000400c:	7c02                	ld	s8,32(sp)
    8000400e:	6ce2                	ld	s9,24(sp)
    80004010:	6d42                	ld	s10,16(sp)
    80004012:	6da2                	ld	s11,8(sp)
    80004014:	6165                	addi	sp,sp,112
    80004016:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004018:	89da                	mv	s3,s6
    8000401a:	bff1                	j	80003ff6 <readi+0xce>
    return 0;
    8000401c:	4501                	li	a0,0
}
    8000401e:	8082                	ret

0000000080004020 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004020:	457c                	lw	a5,76(a0)
    80004022:	10d7e863          	bltu	a5,a3,80004132 <writei+0x112>
{
    80004026:	7159                	addi	sp,sp,-112
    80004028:	f486                	sd	ra,104(sp)
    8000402a:	f0a2                	sd	s0,96(sp)
    8000402c:	eca6                	sd	s1,88(sp)
    8000402e:	e8ca                	sd	s2,80(sp)
    80004030:	e4ce                	sd	s3,72(sp)
    80004032:	e0d2                	sd	s4,64(sp)
    80004034:	fc56                	sd	s5,56(sp)
    80004036:	f85a                	sd	s6,48(sp)
    80004038:	f45e                	sd	s7,40(sp)
    8000403a:	f062                	sd	s8,32(sp)
    8000403c:	ec66                	sd	s9,24(sp)
    8000403e:	e86a                	sd	s10,16(sp)
    80004040:	e46e                	sd	s11,8(sp)
    80004042:	1880                	addi	s0,sp,112
    80004044:	8b2a                	mv	s6,a0
    80004046:	8c2e                	mv	s8,a1
    80004048:	8ab2                	mv	s5,a2
    8000404a:	8936                	mv	s2,a3
    8000404c:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000404e:	00e687bb          	addw	a5,a3,a4
    80004052:	0ed7e263          	bltu	a5,a3,80004136 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004056:	00043737          	lui	a4,0x43
    8000405a:	0ef76063          	bltu	a4,a5,8000413a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000405e:	0c0b8863          	beqz	s7,8000412e <writei+0x10e>
    80004062:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004064:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004068:	5cfd                	li	s9,-1
    8000406a:	a091                	j	800040ae <writei+0x8e>
    8000406c:	02099d93          	slli	s11,s3,0x20
    80004070:	020ddd93          	srli	s11,s11,0x20
    80004074:	05848793          	addi	a5,s1,88
    80004078:	86ee                	mv	a3,s11
    8000407a:	8656                	mv	a2,s5
    8000407c:	85e2                	mv	a1,s8
    8000407e:	953e                	add	a0,a0,a5
    80004080:	fffff097          	auipc	ra,0xfffff
    80004084:	9b6080e7          	jalr	-1610(ra) # 80002a36 <either_copyin>
    80004088:	07950263          	beq	a0,s9,800040ec <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000408c:	8526                	mv	a0,s1
    8000408e:	00001097          	auipc	ra,0x1
    80004092:	adc080e7          	jalr	-1316(ra) # 80004b6a <log_write>
    brelse(bp);
    80004096:	8526                	mv	a0,s1
    80004098:	fffff097          	auipc	ra,0xfffff
    8000409c:	508080e7          	jalr	1288(ra) # 800035a0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040a0:	01498a3b          	addw	s4,s3,s4
    800040a4:	0129893b          	addw	s2,s3,s2
    800040a8:	9aee                	add	s5,s5,s11
    800040aa:	057a7663          	bgeu	s4,s7,800040f6 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040ae:	000b2483          	lw	s1,0(s6)
    800040b2:	00a9559b          	srliw	a1,s2,0xa
    800040b6:	855a                	mv	a0,s6
    800040b8:	fffff097          	auipc	ra,0xfffff
    800040bc:	7ac080e7          	jalr	1964(ra) # 80003864 <bmap>
    800040c0:	0005059b          	sext.w	a1,a0
    800040c4:	8526                	mv	a0,s1
    800040c6:	fffff097          	auipc	ra,0xfffff
    800040ca:	3aa080e7          	jalr	938(ra) # 80003470 <bread>
    800040ce:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040d0:	3ff97513          	andi	a0,s2,1023
    800040d4:	40ad07bb          	subw	a5,s10,a0
    800040d8:	414b873b          	subw	a4,s7,s4
    800040dc:	89be                	mv	s3,a5
    800040de:	2781                	sext.w	a5,a5
    800040e0:	0007069b          	sext.w	a3,a4
    800040e4:	f8f6f4e3          	bgeu	a3,a5,8000406c <writei+0x4c>
    800040e8:	89ba                	mv	s3,a4
    800040ea:	b749                	j	8000406c <writei+0x4c>
      brelse(bp);
    800040ec:	8526                	mv	a0,s1
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	4b2080e7          	jalr	1202(ra) # 800035a0 <brelse>
  }

  if(off > ip->size)
    800040f6:	04cb2783          	lw	a5,76(s6)
    800040fa:	0127f463          	bgeu	a5,s2,80004102 <writei+0xe2>
    ip->size = off;
    800040fe:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004102:	855a                	mv	a0,s6
    80004104:	00000097          	auipc	ra,0x0
    80004108:	aa6080e7          	jalr	-1370(ra) # 80003baa <iupdate>

  return tot;
    8000410c:	000a051b          	sext.w	a0,s4
}
    80004110:	70a6                	ld	ra,104(sp)
    80004112:	7406                	ld	s0,96(sp)
    80004114:	64e6                	ld	s1,88(sp)
    80004116:	6946                	ld	s2,80(sp)
    80004118:	69a6                	ld	s3,72(sp)
    8000411a:	6a06                	ld	s4,64(sp)
    8000411c:	7ae2                	ld	s5,56(sp)
    8000411e:	7b42                	ld	s6,48(sp)
    80004120:	7ba2                	ld	s7,40(sp)
    80004122:	7c02                	ld	s8,32(sp)
    80004124:	6ce2                	ld	s9,24(sp)
    80004126:	6d42                	ld	s10,16(sp)
    80004128:	6da2                	ld	s11,8(sp)
    8000412a:	6165                	addi	sp,sp,112
    8000412c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000412e:	8a5e                	mv	s4,s7
    80004130:	bfc9                	j	80004102 <writei+0xe2>
    return -1;
    80004132:	557d                	li	a0,-1
}
    80004134:	8082                	ret
    return -1;
    80004136:	557d                	li	a0,-1
    80004138:	bfe1                	j	80004110 <writei+0xf0>
    return -1;
    8000413a:	557d                	li	a0,-1
    8000413c:	bfd1                	j	80004110 <writei+0xf0>

000000008000413e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000413e:	1141                	addi	sp,sp,-16
    80004140:	e406                	sd	ra,8(sp)
    80004142:	e022                	sd	s0,0(sp)
    80004144:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004146:	4639                	li	a2,14
    80004148:	ffffd097          	auipc	ra,0xffffd
    8000414c:	c4e080e7          	jalr	-946(ra) # 80000d96 <strncmp>
}
    80004150:	60a2                	ld	ra,8(sp)
    80004152:	6402                	ld	s0,0(sp)
    80004154:	0141                	addi	sp,sp,16
    80004156:	8082                	ret

0000000080004158 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004158:	7139                	addi	sp,sp,-64
    8000415a:	fc06                	sd	ra,56(sp)
    8000415c:	f822                	sd	s0,48(sp)
    8000415e:	f426                	sd	s1,40(sp)
    80004160:	f04a                	sd	s2,32(sp)
    80004162:	ec4e                	sd	s3,24(sp)
    80004164:	e852                	sd	s4,16(sp)
    80004166:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004168:	04451703          	lh	a4,68(a0)
    8000416c:	4785                	li	a5,1
    8000416e:	00f71a63          	bne	a4,a5,80004182 <dirlookup+0x2a>
    80004172:	892a                	mv	s2,a0
    80004174:	89ae                	mv	s3,a1
    80004176:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004178:	457c                	lw	a5,76(a0)
    8000417a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000417c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000417e:	e79d                	bnez	a5,800041ac <dirlookup+0x54>
    80004180:	a8a5                	j	800041f8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004182:	00004517          	auipc	a0,0x4
    80004186:	52650513          	addi	a0,a0,1318 # 800086a8 <syscalls+0x1a8>
    8000418a:	ffffc097          	auipc	ra,0xffffc
    8000418e:	3a0080e7          	jalr	928(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004192:	00004517          	auipc	a0,0x4
    80004196:	52e50513          	addi	a0,a0,1326 # 800086c0 <syscalls+0x1c0>
    8000419a:	ffffc097          	auipc	ra,0xffffc
    8000419e:	390080e7          	jalr	912(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041a2:	24c1                	addiw	s1,s1,16
    800041a4:	04c92783          	lw	a5,76(s2)
    800041a8:	04f4f763          	bgeu	s1,a5,800041f6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041ac:	4741                	li	a4,16
    800041ae:	86a6                	mv	a3,s1
    800041b0:	fc040613          	addi	a2,s0,-64
    800041b4:	4581                	li	a1,0
    800041b6:	854a                	mv	a0,s2
    800041b8:	00000097          	auipc	ra,0x0
    800041bc:	d70080e7          	jalr	-656(ra) # 80003f28 <readi>
    800041c0:	47c1                	li	a5,16
    800041c2:	fcf518e3          	bne	a0,a5,80004192 <dirlookup+0x3a>
    if(de.inum == 0)
    800041c6:	fc045783          	lhu	a5,-64(s0)
    800041ca:	dfe1                	beqz	a5,800041a2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800041cc:	fc240593          	addi	a1,s0,-62
    800041d0:	854e                	mv	a0,s3
    800041d2:	00000097          	auipc	ra,0x0
    800041d6:	f6c080e7          	jalr	-148(ra) # 8000413e <namecmp>
    800041da:	f561                	bnez	a0,800041a2 <dirlookup+0x4a>
      if(poff)
    800041dc:	000a0463          	beqz	s4,800041e4 <dirlookup+0x8c>
        *poff = off;
    800041e0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041e4:	fc045583          	lhu	a1,-64(s0)
    800041e8:	00092503          	lw	a0,0(s2)
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	754080e7          	jalr	1876(ra) # 80003940 <iget>
    800041f4:	a011                	j	800041f8 <dirlookup+0xa0>
  return 0;
    800041f6:	4501                	li	a0,0
}
    800041f8:	70e2                	ld	ra,56(sp)
    800041fa:	7442                	ld	s0,48(sp)
    800041fc:	74a2                	ld	s1,40(sp)
    800041fe:	7902                	ld	s2,32(sp)
    80004200:	69e2                	ld	s3,24(sp)
    80004202:	6a42                	ld	s4,16(sp)
    80004204:	6121                	addi	sp,sp,64
    80004206:	8082                	ret

0000000080004208 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004208:	711d                	addi	sp,sp,-96
    8000420a:	ec86                	sd	ra,88(sp)
    8000420c:	e8a2                	sd	s0,80(sp)
    8000420e:	e4a6                	sd	s1,72(sp)
    80004210:	e0ca                	sd	s2,64(sp)
    80004212:	fc4e                	sd	s3,56(sp)
    80004214:	f852                	sd	s4,48(sp)
    80004216:	f456                	sd	s5,40(sp)
    80004218:	f05a                	sd	s6,32(sp)
    8000421a:	ec5e                	sd	s7,24(sp)
    8000421c:	e862                	sd	s8,16(sp)
    8000421e:	e466                	sd	s9,8(sp)
    80004220:	1080                	addi	s0,sp,96
    80004222:	84aa                	mv	s1,a0
    80004224:	8aae                	mv	s5,a1
    80004226:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004228:	00054703          	lbu	a4,0(a0)
    8000422c:	02f00793          	li	a5,47
    80004230:	02f70363          	beq	a4,a5,80004256 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004234:	ffffe097          	auipc	ra,0xffffe
    80004238:	c32080e7          	jalr	-974(ra) # 80001e66 <myproc>
    8000423c:	15053503          	ld	a0,336(a0)
    80004240:	00000097          	auipc	ra,0x0
    80004244:	9f6080e7          	jalr	-1546(ra) # 80003c36 <idup>
    80004248:	89aa                	mv	s3,a0
  while(*path == '/')
    8000424a:	02f00913          	li	s2,47
  len = path - s;
    8000424e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004250:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004252:	4b85                	li	s7,1
    80004254:	a865                	j	8000430c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004256:	4585                	li	a1,1
    80004258:	4505                	li	a0,1
    8000425a:	fffff097          	auipc	ra,0xfffff
    8000425e:	6e6080e7          	jalr	1766(ra) # 80003940 <iget>
    80004262:	89aa                	mv	s3,a0
    80004264:	b7dd                	j	8000424a <namex+0x42>
      iunlockput(ip);
    80004266:	854e                	mv	a0,s3
    80004268:	00000097          	auipc	ra,0x0
    8000426c:	c6e080e7          	jalr	-914(ra) # 80003ed6 <iunlockput>
      return 0;
    80004270:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004272:	854e                	mv	a0,s3
    80004274:	60e6                	ld	ra,88(sp)
    80004276:	6446                	ld	s0,80(sp)
    80004278:	64a6                	ld	s1,72(sp)
    8000427a:	6906                	ld	s2,64(sp)
    8000427c:	79e2                	ld	s3,56(sp)
    8000427e:	7a42                	ld	s4,48(sp)
    80004280:	7aa2                	ld	s5,40(sp)
    80004282:	7b02                	ld	s6,32(sp)
    80004284:	6be2                	ld	s7,24(sp)
    80004286:	6c42                	ld	s8,16(sp)
    80004288:	6ca2                	ld	s9,8(sp)
    8000428a:	6125                	addi	sp,sp,96
    8000428c:	8082                	ret
      iunlock(ip);
    8000428e:	854e                	mv	a0,s3
    80004290:	00000097          	auipc	ra,0x0
    80004294:	aa6080e7          	jalr	-1370(ra) # 80003d36 <iunlock>
      return ip;
    80004298:	bfe9                	j	80004272 <namex+0x6a>
      iunlockput(ip);
    8000429a:	854e                	mv	a0,s3
    8000429c:	00000097          	auipc	ra,0x0
    800042a0:	c3a080e7          	jalr	-966(ra) # 80003ed6 <iunlockput>
      return 0;
    800042a4:	89e6                	mv	s3,s9
    800042a6:	b7f1                	j	80004272 <namex+0x6a>
  len = path - s;
    800042a8:	40b48633          	sub	a2,s1,a1
    800042ac:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042b0:	099c5463          	bge	s8,s9,80004338 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800042b4:	4639                	li	a2,14
    800042b6:	8552                	mv	a0,s4
    800042b8:	ffffd097          	auipc	ra,0xffffd
    800042bc:	a62080e7          	jalr	-1438(ra) # 80000d1a <memmove>
  while(*path == '/')
    800042c0:	0004c783          	lbu	a5,0(s1)
    800042c4:	01279763          	bne	a5,s2,800042d2 <namex+0xca>
    path++;
    800042c8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042ca:	0004c783          	lbu	a5,0(s1)
    800042ce:	ff278de3          	beq	a5,s2,800042c8 <namex+0xc0>
    ilock(ip);
    800042d2:	854e                	mv	a0,s3
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	9a0080e7          	jalr	-1632(ra) # 80003c74 <ilock>
    if(ip->type != T_DIR){
    800042dc:	04499783          	lh	a5,68(s3)
    800042e0:	f97793e3          	bne	a5,s7,80004266 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042e4:	000a8563          	beqz	s5,800042ee <namex+0xe6>
    800042e8:	0004c783          	lbu	a5,0(s1)
    800042ec:	d3cd                	beqz	a5,8000428e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042ee:	865a                	mv	a2,s6
    800042f0:	85d2                	mv	a1,s4
    800042f2:	854e                	mv	a0,s3
    800042f4:	00000097          	auipc	ra,0x0
    800042f8:	e64080e7          	jalr	-412(ra) # 80004158 <dirlookup>
    800042fc:	8caa                	mv	s9,a0
    800042fe:	dd51                	beqz	a0,8000429a <namex+0x92>
    iunlockput(ip);
    80004300:	854e                	mv	a0,s3
    80004302:	00000097          	auipc	ra,0x0
    80004306:	bd4080e7          	jalr	-1068(ra) # 80003ed6 <iunlockput>
    ip = next;
    8000430a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000430c:	0004c783          	lbu	a5,0(s1)
    80004310:	05279763          	bne	a5,s2,8000435e <namex+0x156>
    path++;
    80004314:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004316:	0004c783          	lbu	a5,0(s1)
    8000431a:	ff278de3          	beq	a5,s2,80004314 <namex+0x10c>
  if(*path == 0)
    8000431e:	c79d                	beqz	a5,8000434c <namex+0x144>
    path++;
    80004320:	85a6                	mv	a1,s1
  len = path - s;
    80004322:	8cda                	mv	s9,s6
    80004324:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004326:	01278963          	beq	a5,s2,80004338 <namex+0x130>
    8000432a:	dfbd                	beqz	a5,800042a8 <namex+0xa0>
    path++;
    8000432c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000432e:	0004c783          	lbu	a5,0(s1)
    80004332:	ff279ce3          	bne	a5,s2,8000432a <namex+0x122>
    80004336:	bf8d                	j	800042a8 <namex+0xa0>
    memmove(name, s, len);
    80004338:	2601                	sext.w	a2,a2
    8000433a:	8552                	mv	a0,s4
    8000433c:	ffffd097          	auipc	ra,0xffffd
    80004340:	9de080e7          	jalr	-1570(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004344:	9cd2                	add	s9,s9,s4
    80004346:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000434a:	bf9d                	j	800042c0 <namex+0xb8>
  if(nameiparent){
    8000434c:	f20a83e3          	beqz	s5,80004272 <namex+0x6a>
    iput(ip);
    80004350:	854e                	mv	a0,s3
    80004352:	00000097          	auipc	ra,0x0
    80004356:	adc080e7          	jalr	-1316(ra) # 80003e2e <iput>
    return 0;
    8000435a:	4981                	li	s3,0
    8000435c:	bf19                	j	80004272 <namex+0x6a>
  if(*path == 0)
    8000435e:	d7fd                	beqz	a5,8000434c <namex+0x144>
  while(*path != '/' && *path != 0)
    80004360:	0004c783          	lbu	a5,0(s1)
    80004364:	85a6                	mv	a1,s1
    80004366:	b7d1                	j	8000432a <namex+0x122>

0000000080004368 <dirlink>:
{
    80004368:	7139                	addi	sp,sp,-64
    8000436a:	fc06                	sd	ra,56(sp)
    8000436c:	f822                	sd	s0,48(sp)
    8000436e:	f426                	sd	s1,40(sp)
    80004370:	f04a                	sd	s2,32(sp)
    80004372:	ec4e                	sd	s3,24(sp)
    80004374:	e852                	sd	s4,16(sp)
    80004376:	0080                	addi	s0,sp,64
    80004378:	892a                	mv	s2,a0
    8000437a:	8a2e                	mv	s4,a1
    8000437c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000437e:	4601                	li	a2,0
    80004380:	00000097          	auipc	ra,0x0
    80004384:	dd8080e7          	jalr	-552(ra) # 80004158 <dirlookup>
    80004388:	e93d                	bnez	a0,800043fe <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000438a:	04c92483          	lw	s1,76(s2)
    8000438e:	c49d                	beqz	s1,800043bc <dirlink+0x54>
    80004390:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004392:	4741                	li	a4,16
    80004394:	86a6                	mv	a3,s1
    80004396:	fc040613          	addi	a2,s0,-64
    8000439a:	4581                	li	a1,0
    8000439c:	854a                	mv	a0,s2
    8000439e:	00000097          	auipc	ra,0x0
    800043a2:	b8a080e7          	jalr	-1142(ra) # 80003f28 <readi>
    800043a6:	47c1                	li	a5,16
    800043a8:	06f51163          	bne	a0,a5,8000440a <dirlink+0xa2>
    if(de.inum == 0)
    800043ac:	fc045783          	lhu	a5,-64(s0)
    800043b0:	c791                	beqz	a5,800043bc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043b2:	24c1                	addiw	s1,s1,16
    800043b4:	04c92783          	lw	a5,76(s2)
    800043b8:	fcf4ede3          	bltu	s1,a5,80004392 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043bc:	4639                	li	a2,14
    800043be:	85d2                	mv	a1,s4
    800043c0:	fc240513          	addi	a0,s0,-62
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	a0e080e7          	jalr	-1522(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800043cc:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043d0:	4741                	li	a4,16
    800043d2:	86a6                	mv	a3,s1
    800043d4:	fc040613          	addi	a2,s0,-64
    800043d8:	4581                	li	a1,0
    800043da:	854a                	mv	a0,s2
    800043dc:	00000097          	auipc	ra,0x0
    800043e0:	c44080e7          	jalr	-956(ra) # 80004020 <writei>
    800043e4:	872a                	mv	a4,a0
    800043e6:	47c1                	li	a5,16
  return 0;
    800043e8:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043ea:	02f71863          	bne	a4,a5,8000441a <dirlink+0xb2>
}
    800043ee:	70e2                	ld	ra,56(sp)
    800043f0:	7442                	ld	s0,48(sp)
    800043f2:	74a2                	ld	s1,40(sp)
    800043f4:	7902                	ld	s2,32(sp)
    800043f6:	69e2                	ld	s3,24(sp)
    800043f8:	6a42                	ld	s4,16(sp)
    800043fa:	6121                	addi	sp,sp,64
    800043fc:	8082                	ret
    iput(ip);
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	a30080e7          	jalr	-1488(ra) # 80003e2e <iput>
    return -1;
    80004406:	557d                	li	a0,-1
    80004408:	b7dd                	j	800043ee <dirlink+0x86>
      panic("dirlink read");
    8000440a:	00004517          	auipc	a0,0x4
    8000440e:	2c650513          	addi	a0,a0,710 # 800086d0 <syscalls+0x1d0>
    80004412:	ffffc097          	auipc	ra,0xffffc
    80004416:	118080e7          	jalr	280(ra) # 8000052a <panic>
    panic("dirlink");
    8000441a:	00004517          	auipc	a0,0x4
    8000441e:	47650513          	addi	a0,a0,1142 # 80008890 <syscalls+0x390>
    80004422:	ffffc097          	auipc	ra,0xffffc
    80004426:	108080e7          	jalr	264(ra) # 8000052a <panic>

000000008000442a <namei>:

struct inode*
namei(char *path)
{
    8000442a:	1101                	addi	sp,sp,-32
    8000442c:	ec06                	sd	ra,24(sp)
    8000442e:	e822                	sd	s0,16(sp)
    80004430:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004432:	fe040613          	addi	a2,s0,-32
    80004436:	4581                	li	a1,0
    80004438:	00000097          	auipc	ra,0x0
    8000443c:	dd0080e7          	jalr	-560(ra) # 80004208 <namex>
}
    80004440:	60e2                	ld	ra,24(sp)
    80004442:	6442                	ld	s0,16(sp)
    80004444:	6105                	addi	sp,sp,32
    80004446:	8082                	ret

0000000080004448 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004448:	1141                	addi	sp,sp,-16
    8000444a:	e406                	sd	ra,8(sp)
    8000444c:	e022                	sd	s0,0(sp)
    8000444e:	0800                	addi	s0,sp,16
    80004450:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004452:	4585                	li	a1,1
    80004454:	00000097          	auipc	ra,0x0
    80004458:	db4080e7          	jalr	-588(ra) # 80004208 <namex>
}
    8000445c:	60a2                	ld	ra,8(sp)
    8000445e:	6402                	ld	s0,0(sp)
    80004460:	0141                	addi	sp,sp,16
    80004462:	8082                	ret

0000000080004464 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    80004464:	1101                	addi	sp,sp,-32
    80004466:	ec22                	sd	s0,24(sp)
    80004468:	1000                	addi	s0,sp,32
    8000446a:	872a                	mv	a4,a0
    8000446c:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    8000446e:	00004797          	auipc	a5,0x4
    80004472:	27278793          	addi	a5,a5,626 # 800086e0 <syscalls+0x1e0>
    80004476:	6394                	ld	a3,0(a5)
    80004478:	fed43023          	sd	a3,-32(s0)
    8000447c:	0087d683          	lhu	a3,8(a5)
    80004480:	fed41423          	sh	a3,-24(s0)
    80004484:	00a7c783          	lbu	a5,10(a5)
    80004488:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    8000448c:	87ae                	mv	a5,a1
    if(i<0){
    8000448e:	02074b63          	bltz	a4,800044c4 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    80004492:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    80004494:	4629                	li	a2,10
        ++p;
    80004496:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    80004498:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    8000449c:	feed                	bnez	a3,80004496 <itoa+0x32>
    *p = '\0';
    8000449e:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    800044a2:	4629                	li	a2,10
    800044a4:	17fd                	addi	a5,a5,-1
    800044a6:	02c766bb          	remw	a3,a4,a2
    800044aa:	ff040593          	addi	a1,s0,-16
    800044ae:	96ae                	add	a3,a3,a1
    800044b0:	ff06c683          	lbu	a3,-16(a3)
    800044b4:	00d78023          	sb	a3,0(a5)
        i = i/10;
    800044b8:	02c7473b          	divw	a4,a4,a2
    }while(i);
    800044bc:	f765                	bnez	a4,800044a4 <itoa+0x40>
    return b;
}
    800044be:	6462                	ld	s0,24(sp)
    800044c0:	6105                	addi	sp,sp,32
    800044c2:	8082                	ret
        *p++ = '-';
    800044c4:	00158793          	addi	a5,a1,1
    800044c8:	02d00693          	li	a3,45
    800044cc:	00d58023          	sb	a3,0(a1)
        i *= -1;
    800044d0:	40e0073b          	negw	a4,a4
    800044d4:	bf7d                	j	80004492 <itoa+0x2e>

00000000800044d6 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    800044d6:	711d                	addi	sp,sp,-96
    800044d8:	ec86                	sd	ra,88(sp)
    800044da:	e8a2                	sd	s0,80(sp)
    800044dc:	e4a6                	sd	s1,72(sp)
    800044de:	e0ca                	sd	s2,64(sp)
    800044e0:	1080                	addi	s0,sp,96
    800044e2:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    800044e4:	4619                	li	a2,6
    800044e6:	00004597          	auipc	a1,0x4
    800044ea:	20a58593          	addi	a1,a1,522 # 800086f0 <syscalls+0x1f0>
    800044ee:	fd040513          	addi	a0,s0,-48
    800044f2:	ffffd097          	auipc	ra,0xffffd
    800044f6:	828080e7          	jalr	-2008(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    800044fa:	fd640593          	addi	a1,s0,-42
    800044fe:	5888                	lw	a0,48(s1)
    80004500:	00000097          	auipc	ra,0x0
    80004504:	f64080e7          	jalr	-156(ra) # 80004464 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    80004508:	1684b503          	ld	a0,360(s1)
    8000450c:	16050763          	beqz	a0,8000467a <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004510:	00001097          	auipc	ra,0x1
    80004514:	94e080e7          	jalr	-1714(ra) # 80004e5e <fileclose>

  begin_op();
    80004518:	00000097          	auipc	ra,0x0
    8000451c:	47a080e7          	jalr	1146(ra) # 80004992 <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004520:	fb040593          	addi	a1,s0,-80
    80004524:	fd040513          	addi	a0,s0,-48
    80004528:	00000097          	auipc	ra,0x0
    8000452c:	f20080e7          	jalr	-224(ra) # 80004448 <nameiparent>
    80004530:	892a                	mv	s2,a0
    80004532:	cd69                	beqz	a0,8000460c <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004534:	fffff097          	auipc	ra,0xfffff
    80004538:	740080e7          	jalr	1856(ra) # 80003c74 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000453c:	00004597          	auipc	a1,0x4
    80004540:	1bc58593          	addi	a1,a1,444 # 800086f8 <syscalls+0x1f8>
    80004544:	fb040513          	addi	a0,s0,-80
    80004548:	00000097          	auipc	ra,0x0
    8000454c:	bf6080e7          	jalr	-1034(ra) # 8000413e <namecmp>
    80004550:	c57d                	beqz	a0,8000463e <removeSwapFile+0x168>
    80004552:	00004597          	auipc	a1,0x4
    80004556:	1ae58593          	addi	a1,a1,430 # 80008700 <syscalls+0x200>
    8000455a:	fb040513          	addi	a0,s0,-80
    8000455e:	00000097          	auipc	ra,0x0
    80004562:	be0080e7          	jalr	-1056(ra) # 8000413e <namecmp>
    80004566:	cd61                	beqz	a0,8000463e <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80004568:	fac40613          	addi	a2,s0,-84
    8000456c:	fb040593          	addi	a1,s0,-80
    80004570:	854a                	mv	a0,s2
    80004572:	00000097          	auipc	ra,0x0
    80004576:	be6080e7          	jalr	-1050(ra) # 80004158 <dirlookup>
    8000457a:	84aa                	mv	s1,a0
    8000457c:	c169                	beqz	a0,8000463e <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	6f6080e7          	jalr	1782(ra) # 80003c74 <ilock>

  if(ip->nlink < 1)
    80004586:	04a49783          	lh	a5,74(s1)
    8000458a:	08f05763          	blez	a5,80004618 <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000458e:	04449703          	lh	a4,68(s1)
    80004592:	4785                	li	a5,1
    80004594:	08f70a63          	beq	a4,a5,80004628 <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80004598:	4641                	li	a2,16
    8000459a:	4581                	li	a1,0
    8000459c:	fc040513          	addi	a0,s0,-64
    800045a0:	ffffc097          	auipc	ra,0xffffc
    800045a4:	71e080e7          	jalr	1822(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045a8:	4741                	li	a4,16
    800045aa:	fac42683          	lw	a3,-84(s0)
    800045ae:	fc040613          	addi	a2,s0,-64
    800045b2:	4581                	li	a1,0
    800045b4:	854a                	mv	a0,s2
    800045b6:	00000097          	auipc	ra,0x0
    800045ba:	a6a080e7          	jalr	-1430(ra) # 80004020 <writei>
    800045be:	47c1                	li	a5,16
    800045c0:	08f51a63          	bne	a0,a5,80004654 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800045c4:	04449703          	lh	a4,68(s1)
    800045c8:	4785                	li	a5,1
    800045ca:	08f70d63          	beq	a4,a5,80004664 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800045ce:	854a                	mv	a0,s2
    800045d0:	00000097          	auipc	ra,0x0
    800045d4:	906080e7          	jalr	-1786(ra) # 80003ed6 <iunlockput>

  ip->nlink--;
    800045d8:	04a4d783          	lhu	a5,74(s1)
    800045dc:	37fd                	addiw	a5,a5,-1
    800045de:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800045e2:	8526                	mv	a0,s1
    800045e4:	fffff097          	auipc	ra,0xfffff
    800045e8:	5c6080e7          	jalr	1478(ra) # 80003baa <iupdate>
  iunlockput(ip);
    800045ec:	8526                	mv	a0,s1
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	8e8080e7          	jalr	-1816(ra) # 80003ed6 <iunlockput>

  end_op();
    800045f6:	00000097          	auipc	ra,0x0
    800045fa:	41c080e7          	jalr	1052(ra) # 80004a12 <end_op>

  return 0;
    800045fe:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    80004600:	60e6                	ld	ra,88(sp)
    80004602:	6446                	ld	s0,80(sp)
    80004604:	64a6                	ld	s1,72(sp)
    80004606:	6906                	ld	s2,64(sp)
    80004608:	6125                	addi	sp,sp,96
    8000460a:	8082                	ret
    end_op();
    8000460c:	00000097          	auipc	ra,0x0
    80004610:	406080e7          	jalr	1030(ra) # 80004a12 <end_op>
    return -1;
    80004614:	557d                	li	a0,-1
    80004616:	b7ed                	j	80004600 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    80004618:	00004517          	auipc	a0,0x4
    8000461c:	0f050513          	addi	a0,a0,240 # 80008708 <syscalls+0x208>
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	f0a080e7          	jalr	-246(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004628:	8526                	mv	a0,s1
    8000462a:	00001097          	auipc	ra,0x1
    8000462e:	7de080e7          	jalr	2014(ra) # 80005e08 <isdirempty>
    80004632:	f13d                	bnez	a0,80004598 <removeSwapFile+0xc2>
    iunlockput(ip);
    80004634:	8526                	mv	a0,s1
    80004636:	00000097          	auipc	ra,0x0
    8000463a:	8a0080e7          	jalr	-1888(ra) # 80003ed6 <iunlockput>
    iunlockput(dp);
    8000463e:	854a                	mv	a0,s2
    80004640:	00000097          	auipc	ra,0x0
    80004644:	896080e7          	jalr	-1898(ra) # 80003ed6 <iunlockput>
    end_op();
    80004648:	00000097          	auipc	ra,0x0
    8000464c:	3ca080e7          	jalr	970(ra) # 80004a12 <end_op>
    return -1;
    80004650:	557d                	li	a0,-1
    80004652:	b77d                	j	80004600 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004654:	00004517          	auipc	a0,0x4
    80004658:	0cc50513          	addi	a0,a0,204 # 80008720 <syscalls+0x220>
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	ece080e7          	jalr	-306(ra) # 8000052a <panic>
    dp->nlink--;
    80004664:	04a95783          	lhu	a5,74(s2)
    80004668:	37fd                	addiw	a5,a5,-1
    8000466a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000466e:	854a                	mv	a0,s2
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	53a080e7          	jalr	1338(ra) # 80003baa <iupdate>
    80004678:	bf99                	j	800045ce <removeSwapFile+0xf8>
    return -1;
    8000467a:	557d                	li	a0,-1
    8000467c:	b751                	j	80004600 <removeSwapFile+0x12a>

000000008000467e <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    8000467e:	7179                	addi	sp,sp,-48
    80004680:	f406                	sd	ra,40(sp)
    80004682:	f022                	sd	s0,32(sp)
    80004684:	ec26                	sd	s1,24(sp)
    80004686:	e84a                	sd	s2,16(sp)
    80004688:	1800                	addi	s0,sp,48
    8000468a:	84aa                	mv	s1,a0
  printf("createSwapFile\n");
    8000468c:	00004517          	auipc	a0,0x4
    80004690:	0a450513          	addi	a0,a0,164 # 80008730 <syscalls+0x230>
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	ee0080e7          	jalr	-288(ra) # 80000574 <printf>
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    8000469c:	4619                	li	a2,6
    8000469e:	00004597          	auipc	a1,0x4
    800046a2:	05258593          	addi	a1,a1,82 # 800086f0 <syscalls+0x1f0>
    800046a6:	fd040513          	addi	a0,s0,-48
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	670080e7          	jalr	1648(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    800046b2:	fd640593          	addi	a1,s0,-42
    800046b6:	5888                	lw	a0,48(s1)
    800046b8:	00000097          	auipc	ra,0x0
    800046bc:	dac080e7          	jalr	-596(ra) # 80004464 <itoa>

  begin_op();
    800046c0:	00000097          	auipc	ra,0x0
    800046c4:	2d2080e7          	jalr	722(ra) # 80004992 <begin_op>
  
  struct inode * in = create(path, T_FILE, 0, 0);
    800046c8:	4681                	li	a3,0
    800046ca:	4601                	li	a2,0
    800046cc:	4589                	li	a1,2
    800046ce:	fd040513          	addi	a0,s0,-48
    800046d2:	00002097          	auipc	ra,0x2
    800046d6:	92a080e7          	jalr	-1750(ra) # 80005ffc <create>
    800046da:	892a                	mv	s2,a0
  printf("created file\n");
    800046dc:	00004517          	auipc	a0,0x4
    800046e0:	06450513          	addi	a0,a0,100 # 80008740 <syscalls+0x240>
    800046e4:	ffffc097          	auipc	ra,0xffffc
    800046e8:	e90080e7          	jalr	-368(ra) # 80000574 <printf>
  iunlock(in);
    800046ec:	854a                	mv	a0,s2
    800046ee:	fffff097          	auipc	ra,0xfffff
    800046f2:	648080e7          	jalr	1608(ra) # 80003d36 <iunlock>
  p->swapFile = filealloc();
    800046f6:	00000097          	auipc	ra,0x0
    800046fa:	6ac080e7          	jalr	1708(ra) # 80004da2 <filealloc>
    800046fe:	16a4b423          	sd	a0,360(s1)
  printf("allocated file\n");
    80004702:	00004517          	auipc	a0,0x4
    80004706:	04e50513          	addi	a0,a0,78 # 80008750 <syscalls+0x250>
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	e6a080e7          	jalr	-406(ra) # 80000574 <printf>
  if (p->swapFile == 0)
    80004712:	1684b783          	ld	a5,360(s1)
    80004716:	cf9d                	beqz	a5,80004754 <createSwapFile+0xd6>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004718:	0127bc23          	sd	s2,24(a5)
  p->swapFile->type = FD_INODE;
    8000471c:	1684b703          	ld	a4,360(s1)
    80004720:	4789                	li	a5,2
    80004722:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004724:	1684b703          	ld	a4,360(s1)
    80004728:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    8000472c:	1684b703          	ld	a4,360(s1)
    80004730:	4685                	li	a3,1
    80004732:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004736:	1684b703          	ld	a4,360(s1)
    8000473a:	00f704a3          	sb	a5,9(a4)
    end_op();
    8000473e:	00000097          	auipc	ra,0x0
    80004742:	2d4080e7          	jalr	724(ra) # 80004a12 <end_op>

    return 0;
}
    80004746:	4501                	li	a0,0
    80004748:	70a2                	ld	ra,40(sp)
    8000474a:	7402                	ld	s0,32(sp)
    8000474c:	64e2                	ld	s1,24(sp)
    8000474e:	6942                	ld	s2,16(sp)
    80004750:	6145                	addi	sp,sp,48
    80004752:	8082                	ret
    panic("no slot for files on /store");
    80004754:	00004517          	auipc	a0,0x4
    80004758:	00c50513          	addi	a0,a0,12 # 80008760 <syscalls+0x260>
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	dce080e7          	jalr	-562(ra) # 8000052a <panic>

0000000080004764 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004764:	1141                	addi	sp,sp,-16
    80004766:	e406                	sd	ra,8(sp)
    80004768:	e022                	sd	s0,0(sp)
    8000476a:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    8000476c:	16853783          	ld	a5,360(a0)
    80004770:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004772:	8636                	mv	a2,a3
    80004774:	16853503          	ld	a0,360(a0)
    80004778:	00001097          	auipc	ra,0x1
    8000477c:	ad8080e7          	jalr	-1320(ra) # 80005250 <kfilewrite>
}
    80004780:	60a2                	ld	ra,8(sp)
    80004782:	6402                	ld	s0,0(sp)
    80004784:	0141                	addi	sp,sp,16
    80004786:	8082                	ret

0000000080004788 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004788:	1141                	addi	sp,sp,-16
    8000478a:	e406                	sd	ra,8(sp)
    8000478c:	e022                	sd	s0,0(sp)
    8000478e:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004790:	16853783          	ld	a5,360(a0)
    80004794:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004796:	8636                	mv	a2,a3
    80004798:	16853503          	ld	a0,360(a0)
    8000479c:	00001097          	auipc	ra,0x1
    800047a0:	9f2080e7          	jalr	-1550(ra) # 8000518e <kfileread>
    800047a4:	60a2                	ld	ra,8(sp)
    800047a6:	6402                	ld	s0,0(sp)
    800047a8:	0141                	addi	sp,sp,16
    800047aa:	8082                	ret

00000000800047ac <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800047ac:	1101                	addi	sp,sp,-32
    800047ae:	ec06                	sd	ra,24(sp)
    800047b0:	e822                	sd	s0,16(sp)
    800047b2:	e426                	sd	s1,8(sp)
    800047b4:	e04a                	sd	s2,0(sp)
    800047b6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800047b8:	0002d917          	auipc	s2,0x2d
    800047bc:	cb890913          	addi	s2,s2,-840 # 80031470 <log>
    800047c0:	01892583          	lw	a1,24(s2)
    800047c4:	02892503          	lw	a0,40(s2)
    800047c8:	fffff097          	auipc	ra,0xfffff
    800047cc:	ca8080e7          	jalr	-856(ra) # 80003470 <bread>
    800047d0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800047d2:	02c92683          	lw	a3,44(s2)
    800047d6:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800047d8:	02d05863          	blez	a3,80004808 <write_head+0x5c>
    800047dc:	0002d797          	auipc	a5,0x2d
    800047e0:	cc478793          	addi	a5,a5,-828 # 800314a0 <log+0x30>
    800047e4:	05c50713          	addi	a4,a0,92
    800047e8:	36fd                	addiw	a3,a3,-1
    800047ea:	02069613          	slli	a2,a3,0x20
    800047ee:	01e65693          	srli	a3,a2,0x1e
    800047f2:	0002d617          	auipc	a2,0x2d
    800047f6:	cb260613          	addi	a2,a2,-846 # 800314a4 <log+0x34>
    800047fa:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800047fc:	4390                	lw	a2,0(a5)
    800047fe:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004800:	0791                	addi	a5,a5,4
    80004802:	0711                	addi	a4,a4,4
    80004804:	fed79ce3          	bne	a5,a3,800047fc <write_head+0x50>
  }
  bwrite(buf);
    80004808:	8526                	mv	a0,s1
    8000480a:	fffff097          	auipc	ra,0xfffff
    8000480e:	d58080e7          	jalr	-680(ra) # 80003562 <bwrite>
  brelse(buf);
    80004812:	8526                	mv	a0,s1
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	d8c080e7          	jalr	-628(ra) # 800035a0 <brelse>
}
    8000481c:	60e2                	ld	ra,24(sp)
    8000481e:	6442                	ld	s0,16(sp)
    80004820:	64a2                	ld	s1,8(sp)
    80004822:	6902                	ld	s2,0(sp)
    80004824:	6105                	addi	sp,sp,32
    80004826:	8082                	ret

0000000080004828 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004828:	0002d797          	auipc	a5,0x2d
    8000482c:	c747a783          	lw	a5,-908(a5) # 8003149c <log+0x2c>
    80004830:	0af05d63          	blez	a5,800048ea <install_trans+0xc2>
{
    80004834:	7139                	addi	sp,sp,-64
    80004836:	fc06                	sd	ra,56(sp)
    80004838:	f822                	sd	s0,48(sp)
    8000483a:	f426                	sd	s1,40(sp)
    8000483c:	f04a                	sd	s2,32(sp)
    8000483e:	ec4e                	sd	s3,24(sp)
    80004840:	e852                	sd	s4,16(sp)
    80004842:	e456                	sd	s5,8(sp)
    80004844:	e05a                	sd	s6,0(sp)
    80004846:	0080                	addi	s0,sp,64
    80004848:	8b2a                	mv	s6,a0
    8000484a:	0002da97          	auipc	s5,0x2d
    8000484e:	c56a8a93          	addi	s5,s5,-938 # 800314a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004852:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004854:	0002d997          	auipc	s3,0x2d
    80004858:	c1c98993          	addi	s3,s3,-996 # 80031470 <log>
    8000485c:	a00d                	j	8000487e <install_trans+0x56>
    brelse(lbuf);
    8000485e:	854a                	mv	a0,s2
    80004860:	fffff097          	auipc	ra,0xfffff
    80004864:	d40080e7          	jalr	-704(ra) # 800035a0 <brelse>
    brelse(dbuf);
    80004868:	8526                	mv	a0,s1
    8000486a:	fffff097          	auipc	ra,0xfffff
    8000486e:	d36080e7          	jalr	-714(ra) # 800035a0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004872:	2a05                	addiw	s4,s4,1
    80004874:	0a91                	addi	s5,s5,4
    80004876:	02c9a783          	lw	a5,44(s3)
    8000487a:	04fa5e63          	bge	s4,a5,800048d6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000487e:	0189a583          	lw	a1,24(s3)
    80004882:	014585bb          	addw	a1,a1,s4
    80004886:	2585                	addiw	a1,a1,1
    80004888:	0289a503          	lw	a0,40(s3)
    8000488c:	fffff097          	auipc	ra,0xfffff
    80004890:	be4080e7          	jalr	-1052(ra) # 80003470 <bread>
    80004894:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004896:	000aa583          	lw	a1,0(s5)
    8000489a:	0289a503          	lw	a0,40(s3)
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	bd2080e7          	jalr	-1070(ra) # 80003470 <bread>
    800048a6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800048a8:	40000613          	li	a2,1024
    800048ac:	05890593          	addi	a1,s2,88
    800048b0:	05850513          	addi	a0,a0,88
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	466080e7          	jalr	1126(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800048bc:	8526                	mv	a0,s1
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	ca4080e7          	jalr	-860(ra) # 80003562 <bwrite>
    if(recovering == 0)
    800048c6:	f80b1ce3          	bnez	s6,8000485e <install_trans+0x36>
      bunpin(dbuf);
    800048ca:	8526                	mv	a0,s1
    800048cc:	fffff097          	auipc	ra,0xfffff
    800048d0:	dae080e7          	jalr	-594(ra) # 8000367a <bunpin>
    800048d4:	b769                	j	8000485e <install_trans+0x36>
}
    800048d6:	70e2                	ld	ra,56(sp)
    800048d8:	7442                	ld	s0,48(sp)
    800048da:	74a2                	ld	s1,40(sp)
    800048dc:	7902                	ld	s2,32(sp)
    800048de:	69e2                	ld	s3,24(sp)
    800048e0:	6a42                	ld	s4,16(sp)
    800048e2:	6aa2                	ld	s5,8(sp)
    800048e4:	6b02                	ld	s6,0(sp)
    800048e6:	6121                	addi	sp,sp,64
    800048e8:	8082                	ret
    800048ea:	8082                	ret

00000000800048ec <initlog>:
{
    800048ec:	7179                	addi	sp,sp,-48
    800048ee:	f406                	sd	ra,40(sp)
    800048f0:	f022                	sd	s0,32(sp)
    800048f2:	ec26                	sd	s1,24(sp)
    800048f4:	e84a                	sd	s2,16(sp)
    800048f6:	e44e                	sd	s3,8(sp)
    800048f8:	1800                	addi	s0,sp,48
    800048fa:	892a                	mv	s2,a0
    800048fc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800048fe:	0002d497          	auipc	s1,0x2d
    80004902:	b7248493          	addi	s1,s1,-1166 # 80031470 <log>
    80004906:	00004597          	auipc	a1,0x4
    8000490a:	e7a58593          	addi	a1,a1,-390 # 80008780 <syscalls+0x280>
    8000490e:	8526                	mv	a0,s1
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	222080e7          	jalr	546(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004918:	0149a583          	lw	a1,20(s3)
    8000491c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000491e:	0109a783          	lw	a5,16(s3)
    80004922:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004924:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004928:	854a                	mv	a0,s2
    8000492a:	fffff097          	auipc	ra,0xfffff
    8000492e:	b46080e7          	jalr	-1210(ra) # 80003470 <bread>
  log.lh.n = lh->n;
    80004932:	4d34                	lw	a3,88(a0)
    80004934:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004936:	02d05663          	blez	a3,80004962 <initlog+0x76>
    8000493a:	05c50793          	addi	a5,a0,92
    8000493e:	0002d717          	auipc	a4,0x2d
    80004942:	b6270713          	addi	a4,a4,-1182 # 800314a0 <log+0x30>
    80004946:	36fd                	addiw	a3,a3,-1
    80004948:	02069613          	slli	a2,a3,0x20
    8000494c:	01e65693          	srli	a3,a2,0x1e
    80004950:	06050613          	addi	a2,a0,96
    80004954:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004956:	4390                	lw	a2,0(a5)
    80004958:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000495a:	0791                	addi	a5,a5,4
    8000495c:	0711                	addi	a4,a4,4
    8000495e:	fed79ce3          	bne	a5,a3,80004956 <initlog+0x6a>
  brelse(buf);
    80004962:	fffff097          	auipc	ra,0xfffff
    80004966:	c3e080e7          	jalr	-962(ra) # 800035a0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000496a:	4505                	li	a0,1
    8000496c:	00000097          	auipc	ra,0x0
    80004970:	ebc080e7          	jalr	-324(ra) # 80004828 <install_trans>
  log.lh.n = 0;
    80004974:	0002d797          	auipc	a5,0x2d
    80004978:	b207a423          	sw	zero,-1240(a5) # 8003149c <log+0x2c>
  write_head(); // clear the log
    8000497c:	00000097          	auipc	ra,0x0
    80004980:	e30080e7          	jalr	-464(ra) # 800047ac <write_head>
}
    80004984:	70a2                	ld	ra,40(sp)
    80004986:	7402                	ld	s0,32(sp)
    80004988:	64e2                	ld	s1,24(sp)
    8000498a:	6942                	ld	s2,16(sp)
    8000498c:	69a2                	ld	s3,8(sp)
    8000498e:	6145                	addi	sp,sp,48
    80004990:	8082                	ret

0000000080004992 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004992:	1101                	addi	sp,sp,-32
    80004994:	ec06                	sd	ra,24(sp)
    80004996:	e822                	sd	s0,16(sp)
    80004998:	e426                	sd	s1,8(sp)
    8000499a:	e04a                	sd	s2,0(sp)
    8000499c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000499e:	0002d517          	auipc	a0,0x2d
    800049a2:	ad250513          	addi	a0,a0,-1326 # 80031470 <log>
    800049a6:	ffffc097          	auipc	ra,0xffffc
    800049aa:	21c080e7          	jalr	540(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    800049ae:	0002d497          	auipc	s1,0x2d
    800049b2:	ac248493          	addi	s1,s1,-1342 # 80031470 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800049b6:	4979                	li	s2,30
    800049b8:	a039                	j	800049c6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800049ba:	85a6                	mv	a1,s1
    800049bc:	8526                	mv	a0,s1
    800049be:	ffffe097          	auipc	ra,0xffffe
    800049c2:	c5e080e7          	jalr	-930(ra) # 8000261c <sleep>
    if(log.committing){
    800049c6:	50dc                	lw	a5,36(s1)
    800049c8:	fbed                	bnez	a5,800049ba <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800049ca:	509c                	lw	a5,32(s1)
    800049cc:	0017871b          	addiw	a4,a5,1
    800049d0:	0007069b          	sext.w	a3,a4
    800049d4:	0027179b          	slliw	a5,a4,0x2
    800049d8:	9fb9                	addw	a5,a5,a4
    800049da:	0017979b          	slliw	a5,a5,0x1
    800049de:	54d8                	lw	a4,44(s1)
    800049e0:	9fb9                	addw	a5,a5,a4
    800049e2:	00f95963          	bge	s2,a5,800049f4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800049e6:	85a6                	mv	a1,s1
    800049e8:	8526                	mv	a0,s1
    800049ea:	ffffe097          	auipc	ra,0xffffe
    800049ee:	c32080e7          	jalr	-974(ra) # 8000261c <sleep>
    800049f2:	bfd1                	j	800049c6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800049f4:	0002d517          	auipc	a0,0x2d
    800049f8:	a7c50513          	addi	a0,a0,-1412 # 80031470 <log>
    800049fc:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	278080e7          	jalr	632(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004a06:	60e2                	ld	ra,24(sp)
    80004a08:	6442                	ld	s0,16(sp)
    80004a0a:	64a2                	ld	s1,8(sp)
    80004a0c:	6902                	ld	s2,0(sp)
    80004a0e:	6105                	addi	sp,sp,32
    80004a10:	8082                	ret

0000000080004a12 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004a12:	7139                	addi	sp,sp,-64
    80004a14:	fc06                	sd	ra,56(sp)
    80004a16:	f822                	sd	s0,48(sp)
    80004a18:	f426                	sd	s1,40(sp)
    80004a1a:	f04a                	sd	s2,32(sp)
    80004a1c:	ec4e                	sd	s3,24(sp)
    80004a1e:	e852                	sd	s4,16(sp)
    80004a20:	e456                	sd	s5,8(sp)
    80004a22:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004a24:	0002d497          	auipc	s1,0x2d
    80004a28:	a4c48493          	addi	s1,s1,-1460 # 80031470 <log>
    80004a2c:	8526                	mv	a0,s1
    80004a2e:	ffffc097          	auipc	ra,0xffffc
    80004a32:	194080e7          	jalr	404(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004a36:	509c                	lw	a5,32(s1)
    80004a38:	37fd                	addiw	a5,a5,-1
    80004a3a:	0007891b          	sext.w	s2,a5
    80004a3e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004a40:	50dc                	lw	a5,36(s1)
    80004a42:	e7b9                	bnez	a5,80004a90 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004a44:	04091e63          	bnez	s2,80004aa0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004a48:	0002d497          	auipc	s1,0x2d
    80004a4c:	a2848493          	addi	s1,s1,-1496 # 80031470 <log>
    80004a50:	4785                	li	a5,1
    80004a52:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004a54:	8526                	mv	a0,s1
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	220080e7          	jalr	544(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004a5e:	54dc                	lw	a5,44(s1)
    80004a60:	06f04763          	bgtz	a5,80004ace <end_op+0xbc>
    acquire(&log.lock);
    80004a64:	0002d497          	auipc	s1,0x2d
    80004a68:	a0c48493          	addi	s1,s1,-1524 # 80031470 <log>
    80004a6c:	8526                	mv	a0,s1
    80004a6e:	ffffc097          	auipc	ra,0xffffc
    80004a72:	154080e7          	jalr	340(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004a76:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004a7a:	8526                	mv	a0,s1
    80004a7c:	ffffe097          	auipc	ra,0xffffe
    80004a80:	d2c080e7          	jalr	-724(ra) # 800027a8 <wakeup>
    release(&log.lock);
    80004a84:	8526                	mv	a0,s1
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	1f0080e7          	jalr	496(ra) # 80000c76 <release>
}
    80004a8e:	a03d                	j	80004abc <end_op+0xaa>
    panic("log.committing");
    80004a90:	00004517          	auipc	a0,0x4
    80004a94:	cf850513          	addi	a0,a0,-776 # 80008788 <syscalls+0x288>
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	a92080e7          	jalr	-1390(ra) # 8000052a <panic>
    wakeup(&log);
    80004aa0:	0002d497          	auipc	s1,0x2d
    80004aa4:	9d048493          	addi	s1,s1,-1584 # 80031470 <log>
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	ffffe097          	auipc	ra,0xffffe
    80004aae:	cfe080e7          	jalr	-770(ra) # 800027a8 <wakeup>
  release(&log.lock);
    80004ab2:	8526                	mv	a0,s1
    80004ab4:	ffffc097          	auipc	ra,0xffffc
    80004ab8:	1c2080e7          	jalr	450(ra) # 80000c76 <release>
}
    80004abc:	70e2                	ld	ra,56(sp)
    80004abe:	7442                	ld	s0,48(sp)
    80004ac0:	74a2                	ld	s1,40(sp)
    80004ac2:	7902                	ld	s2,32(sp)
    80004ac4:	69e2                	ld	s3,24(sp)
    80004ac6:	6a42                	ld	s4,16(sp)
    80004ac8:	6aa2                	ld	s5,8(sp)
    80004aca:	6121                	addi	sp,sp,64
    80004acc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ace:	0002da97          	auipc	s5,0x2d
    80004ad2:	9d2a8a93          	addi	s5,s5,-1582 # 800314a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004ad6:	0002da17          	auipc	s4,0x2d
    80004ada:	99aa0a13          	addi	s4,s4,-1638 # 80031470 <log>
    80004ade:	018a2583          	lw	a1,24(s4)
    80004ae2:	012585bb          	addw	a1,a1,s2
    80004ae6:	2585                	addiw	a1,a1,1
    80004ae8:	028a2503          	lw	a0,40(s4)
    80004aec:	fffff097          	auipc	ra,0xfffff
    80004af0:	984080e7          	jalr	-1660(ra) # 80003470 <bread>
    80004af4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004af6:	000aa583          	lw	a1,0(s5)
    80004afa:	028a2503          	lw	a0,40(s4)
    80004afe:	fffff097          	auipc	ra,0xfffff
    80004b02:	972080e7          	jalr	-1678(ra) # 80003470 <bread>
    80004b06:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004b08:	40000613          	li	a2,1024
    80004b0c:	05850593          	addi	a1,a0,88
    80004b10:	05848513          	addi	a0,s1,88
    80004b14:	ffffc097          	auipc	ra,0xffffc
    80004b18:	206080e7          	jalr	518(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	fffff097          	auipc	ra,0xfffff
    80004b22:	a44080e7          	jalr	-1468(ra) # 80003562 <bwrite>
    brelse(from);
    80004b26:	854e                	mv	a0,s3
    80004b28:	fffff097          	auipc	ra,0xfffff
    80004b2c:	a78080e7          	jalr	-1416(ra) # 800035a0 <brelse>
    brelse(to);
    80004b30:	8526                	mv	a0,s1
    80004b32:	fffff097          	auipc	ra,0xfffff
    80004b36:	a6e080e7          	jalr	-1426(ra) # 800035a0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b3a:	2905                	addiw	s2,s2,1
    80004b3c:	0a91                	addi	s5,s5,4
    80004b3e:	02ca2783          	lw	a5,44(s4)
    80004b42:	f8f94ee3          	blt	s2,a5,80004ade <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004b46:	00000097          	auipc	ra,0x0
    80004b4a:	c66080e7          	jalr	-922(ra) # 800047ac <write_head>
    install_trans(0); // Now install writes to home locations
    80004b4e:	4501                	li	a0,0
    80004b50:	00000097          	auipc	ra,0x0
    80004b54:	cd8080e7          	jalr	-808(ra) # 80004828 <install_trans>
    log.lh.n = 0;
    80004b58:	0002d797          	auipc	a5,0x2d
    80004b5c:	9407a223          	sw	zero,-1724(a5) # 8003149c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004b60:	00000097          	auipc	ra,0x0
    80004b64:	c4c080e7          	jalr	-948(ra) # 800047ac <write_head>
    80004b68:	bdf5                	j	80004a64 <end_op+0x52>

0000000080004b6a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004b6a:	1101                	addi	sp,sp,-32
    80004b6c:	ec06                	sd	ra,24(sp)
    80004b6e:	e822                	sd	s0,16(sp)
    80004b70:	e426                	sd	s1,8(sp)
    80004b72:	e04a                	sd	s2,0(sp)
    80004b74:	1000                	addi	s0,sp,32
    80004b76:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004b78:	0002d917          	auipc	s2,0x2d
    80004b7c:	8f890913          	addi	s2,s2,-1800 # 80031470 <log>
    80004b80:	854a                	mv	a0,s2
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	040080e7          	jalr	64(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b8a:	02c92603          	lw	a2,44(s2)
    80004b8e:	47f5                	li	a5,29
    80004b90:	06c7c563          	blt	a5,a2,80004bfa <log_write+0x90>
    80004b94:	0002d797          	auipc	a5,0x2d
    80004b98:	8f87a783          	lw	a5,-1800(a5) # 8003148c <log+0x1c>
    80004b9c:	37fd                	addiw	a5,a5,-1
    80004b9e:	04f65e63          	bge	a2,a5,80004bfa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004ba2:	0002d797          	auipc	a5,0x2d
    80004ba6:	8ee7a783          	lw	a5,-1810(a5) # 80031490 <log+0x20>
    80004baa:	06f05063          	blez	a5,80004c0a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004bae:	4781                	li	a5,0
    80004bb0:	06c05563          	blez	a2,80004c1a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004bb4:	44cc                	lw	a1,12(s1)
    80004bb6:	0002d717          	auipc	a4,0x2d
    80004bba:	8ea70713          	addi	a4,a4,-1814 # 800314a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004bbe:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004bc0:	4314                	lw	a3,0(a4)
    80004bc2:	04b68c63          	beq	a3,a1,80004c1a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004bc6:	2785                	addiw	a5,a5,1
    80004bc8:	0711                	addi	a4,a4,4
    80004bca:	fef61be3          	bne	a2,a5,80004bc0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004bce:	0621                	addi	a2,a2,8
    80004bd0:	060a                	slli	a2,a2,0x2
    80004bd2:	0002d797          	auipc	a5,0x2d
    80004bd6:	89e78793          	addi	a5,a5,-1890 # 80031470 <log>
    80004bda:	963e                	add	a2,a2,a5
    80004bdc:	44dc                	lw	a5,12(s1)
    80004bde:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004be0:	8526                	mv	a0,s1
    80004be2:	fffff097          	auipc	ra,0xfffff
    80004be6:	a5c080e7          	jalr	-1444(ra) # 8000363e <bpin>
    log.lh.n++;
    80004bea:	0002d717          	auipc	a4,0x2d
    80004bee:	88670713          	addi	a4,a4,-1914 # 80031470 <log>
    80004bf2:	575c                	lw	a5,44(a4)
    80004bf4:	2785                	addiw	a5,a5,1
    80004bf6:	d75c                	sw	a5,44(a4)
    80004bf8:	a835                	j	80004c34 <log_write+0xca>
    panic("too big a transaction");
    80004bfa:	00004517          	auipc	a0,0x4
    80004bfe:	b9e50513          	addi	a0,a0,-1122 # 80008798 <syscalls+0x298>
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	928080e7          	jalr	-1752(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004c0a:	00004517          	auipc	a0,0x4
    80004c0e:	ba650513          	addi	a0,a0,-1114 # 800087b0 <syscalls+0x2b0>
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	918080e7          	jalr	-1768(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004c1a:	00878713          	addi	a4,a5,8
    80004c1e:	00271693          	slli	a3,a4,0x2
    80004c22:	0002d717          	auipc	a4,0x2d
    80004c26:	84e70713          	addi	a4,a4,-1970 # 80031470 <log>
    80004c2a:	9736                	add	a4,a4,a3
    80004c2c:	44d4                	lw	a3,12(s1)
    80004c2e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004c30:	faf608e3          	beq	a2,a5,80004be0 <log_write+0x76>
  }
  release(&log.lock);
    80004c34:	0002d517          	auipc	a0,0x2d
    80004c38:	83c50513          	addi	a0,a0,-1988 # 80031470 <log>
    80004c3c:	ffffc097          	auipc	ra,0xffffc
    80004c40:	03a080e7          	jalr	58(ra) # 80000c76 <release>
}
    80004c44:	60e2                	ld	ra,24(sp)
    80004c46:	6442                	ld	s0,16(sp)
    80004c48:	64a2                	ld	s1,8(sp)
    80004c4a:	6902                	ld	s2,0(sp)
    80004c4c:	6105                	addi	sp,sp,32
    80004c4e:	8082                	ret

0000000080004c50 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004c50:	1101                	addi	sp,sp,-32
    80004c52:	ec06                	sd	ra,24(sp)
    80004c54:	e822                	sd	s0,16(sp)
    80004c56:	e426                	sd	s1,8(sp)
    80004c58:	e04a                	sd	s2,0(sp)
    80004c5a:	1000                	addi	s0,sp,32
    80004c5c:	84aa                	mv	s1,a0
    80004c5e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c60:	00004597          	auipc	a1,0x4
    80004c64:	b7058593          	addi	a1,a1,-1168 # 800087d0 <syscalls+0x2d0>
    80004c68:	0521                	addi	a0,a0,8
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	ec8080e7          	jalr	-312(ra) # 80000b32 <initlock>
  lk->name = name;
    80004c72:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c76:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c7a:	0204a423          	sw	zero,40(s1)
}
    80004c7e:	60e2                	ld	ra,24(sp)
    80004c80:	6442                	ld	s0,16(sp)
    80004c82:	64a2                	ld	s1,8(sp)
    80004c84:	6902                	ld	s2,0(sp)
    80004c86:	6105                	addi	sp,sp,32
    80004c88:	8082                	ret

0000000080004c8a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c8a:	1101                	addi	sp,sp,-32
    80004c8c:	ec06                	sd	ra,24(sp)
    80004c8e:	e822                	sd	s0,16(sp)
    80004c90:	e426                	sd	s1,8(sp)
    80004c92:	e04a                	sd	s2,0(sp)
    80004c94:	1000                	addi	s0,sp,32
    80004c96:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c98:	00850913          	addi	s2,a0,8
    80004c9c:	854a                	mv	a0,s2
    80004c9e:	ffffc097          	auipc	ra,0xffffc
    80004ca2:	f24080e7          	jalr	-220(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004ca6:	409c                	lw	a5,0(s1)
    80004ca8:	cb89                	beqz	a5,80004cba <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004caa:	85ca                	mv	a1,s2
    80004cac:	8526                	mv	a0,s1
    80004cae:	ffffe097          	auipc	ra,0xffffe
    80004cb2:	96e080e7          	jalr	-1682(ra) # 8000261c <sleep>
  while (lk->locked) {
    80004cb6:	409c                	lw	a5,0(s1)
    80004cb8:	fbed                	bnez	a5,80004caa <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004cba:	4785                	li	a5,1
    80004cbc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004cbe:	ffffd097          	auipc	ra,0xffffd
    80004cc2:	1a8080e7          	jalr	424(ra) # 80001e66 <myproc>
    80004cc6:	591c                	lw	a5,48(a0)
    80004cc8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004cca:	854a                	mv	a0,s2
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	faa080e7          	jalr	-86(ra) # 80000c76 <release>
}
    80004cd4:	60e2                	ld	ra,24(sp)
    80004cd6:	6442                	ld	s0,16(sp)
    80004cd8:	64a2                	ld	s1,8(sp)
    80004cda:	6902                	ld	s2,0(sp)
    80004cdc:	6105                	addi	sp,sp,32
    80004cde:	8082                	ret

0000000080004ce0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ce0:	1101                	addi	sp,sp,-32
    80004ce2:	ec06                	sd	ra,24(sp)
    80004ce4:	e822                	sd	s0,16(sp)
    80004ce6:	e426                	sd	s1,8(sp)
    80004ce8:	e04a                	sd	s2,0(sp)
    80004cea:	1000                	addi	s0,sp,32
    80004cec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004cee:	00850913          	addi	s2,a0,8
    80004cf2:	854a                	mv	a0,s2
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	ece080e7          	jalr	-306(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004cfc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d00:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004d04:	8526                	mv	a0,s1
    80004d06:	ffffe097          	auipc	ra,0xffffe
    80004d0a:	aa2080e7          	jalr	-1374(ra) # 800027a8 <wakeup>
  release(&lk->lk);
    80004d0e:	854a                	mv	a0,s2
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	f66080e7          	jalr	-154(ra) # 80000c76 <release>
}
    80004d18:	60e2                	ld	ra,24(sp)
    80004d1a:	6442                	ld	s0,16(sp)
    80004d1c:	64a2                	ld	s1,8(sp)
    80004d1e:	6902                	ld	s2,0(sp)
    80004d20:	6105                	addi	sp,sp,32
    80004d22:	8082                	ret

0000000080004d24 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004d24:	7179                	addi	sp,sp,-48
    80004d26:	f406                	sd	ra,40(sp)
    80004d28:	f022                	sd	s0,32(sp)
    80004d2a:	ec26                	sd	s1,24(sp)
    80004d2c:	e84a                	sd	s2,16(sp)
    80004d2e:	e44e                	sd	s3,8(sp)
    80004d30:	1800                	addi	s0,sp,48
    80004d32:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004d34:	00850913          	addi	s2,a0,8
    80004d38:	854a                	mv	a0,s2
    80004d3a:	ffffc097          	auipc	ra,0xffffc
    80004d3e:	e88080e7          	jalr	-376(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d42:	409c                	lw	a5,0(s1)
    80004d44:	ef99                	bnez	a5,80004d62 <holdingsleep+0x3e>
    80004d46:	4481                	li	s1,0
  release(&lk->lk);
    80004d48:	854a                	mv	a0,s2
    80004d4a:	ffffc097          	auipc	ra,0xffffc
    80004d4e:	f2c080e7          	jalr	-212(ra) # 80000c76 <release>
  return r;
}
    80004d52:	8526                	mv	a0,s1
    80004d54:	70a2                	ld	ra,40(sp)
    80004d56:	7402                	ld	s0,32(sp)
    80004d58:	64e2                	ld	s1,24(sp)
    80004d5a:	6942                	ld	s2,16(sp)
    80004d5c:	69a2                	ld	s3,8(sp)
    80004d5e:	6145                	addi	sp,sp,48
    80004d60:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d62:	0284a983          	lw	s3,40(s1)
    80004d66:	ffffd097          	auipc	ra,0xffffd
    80004d6a:	100080e7          	jalr	256(ra) # 80001e66 <myproc>
    80004d6e:	5904                	lw	s1,48(a0)
    80004d70:	413484b3          	sub	s1,s1,s3
    80004d74:	0014b493          	seqz	s1,s1
    80004d78:	bfc1                	j	80004d48 <holdingsleep+0x24>

0000000080004d7a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004d7a:	1141                	addi	sp,sp,-16
    80004d7c:	e406                	sd	ra,8(sp)
    80004d7e:	e022                	sd	s0,0(sp)
    80004d80:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004d82:	00004597          	auipc	a1,0x4
    80004d86:	a5e58593          	addi	a1,a1,-1442 # 800087e0 <syscalls+0x2e0>
    80004d8a:	0002d517          	auipc	a0,0x2d
    80004d8e:	82e50513          	addi	a0,a0,-2002 # 800315b8 <ftable>
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	da0080e7          	jalr	-608(ra) # 80000b32 <initlock>
}
    80004d9a:	60a2                	ld	ra,8(sp)
    80004d9c:	6402                	ld	s0,0(sp)
    80004d9e:	0141                	addi	sp,sp,16
    80004da0:	8082                	ret

0000000080004da2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004da2:	1101                	addi	sp,sp,-32
    80004da4:	ec06                	sd	ra,24(sp)
    80004da6:	e822                	sd	s0,16(sp)
    80004da8:	e426                	sd	s1,8(sp)
    80004daa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004dac:	0002d517          	auipc	a0,0x2d
    80004db0:	80c50513          	addi	a0,a0,-2036 # 800315b8 <ftable>
    80004db4:	ffffc097          	auipc	ra,0xffffc
    80004db8:	e0e080e7          	jalr	-498(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004dbc:	0002d497          	auipc	s1,0x2d
    80004dc0:	81448493          	addi	s1,s1,-2028 # 800315d0 <ftable+0x18>
    80004dc4:	0002d717          	auipc	a4,0x2d
    80004dc8:	7ac70713          	addi	a4,a4,1964 # 80032570 <ftable+0xfb8>
    if(f->ref == 0){
    80004dcc:	40dc                	lw	a5,4(s1)
    80004dce:	cf99                	beqz	a5,80004dec <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004dd0:	02848493          	addi	s1,s1,40
    80004dd4:	fee49ce3          	bne	s1,a4,80004dcc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004dd8:	0002c517          	auipc	a0,0x2c
    80004ddc:	7e050513          	addi	a0,a0,2016 # 800315b8 <ftable>
    80004de0:	ffffc097          	auipc	ra,0xffffc
    80004de4:	e96080e7          	jalr	-362(ra) # 80000c76 <release>
  return 0;
    80004de8:	4481                	li	s1,0
    80004dea:	a819                	j	80004e00 <filealloc+0x5e>
      f->ref = 1;
    80004dec:	4785                	li	a5,1
    80004dee:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004df0:	0002c517          	auipc	a0,0x2c
    80004df4:	7c850513          	addi	a0,a0,1992 # 800315b8 <ftable>
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	e7e080e7          	jalr	-386(ra) # 80000c76 <release>
}
    80004e00:	8526                	mv	a0,s1
    80004e02:	60e2                	ld	ra,24(sp)
    80004e04:	6442                	ld	s0,16(sp)
    80004e06:	64a2                	ld	s1,8(sp)
    80004e08:	6105                	addi	sp,sp,32
    80004e0a:	8082                	ret

0000000080004e0c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004e0c:	1101                	addi	sp,sp,-32
    80004e0e:	ec06                	sd	ra,24(sp)
    80004e10:	e822                	sd	s0,16(sp)
    80004e12:	e426                	sd	s1,8(sp)
    80004e14:	1000                	addi	s0,sp,32
    80004e16:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004e18:	0002c517          	auipc	a0,0x2c
    80004e1c:	7a050513          	addi	a0,a0,1952 # 800315b8 <ftable>
    80004e20:	ffffc097          	auipc	ra,0xffffc
    80004e24:	da2080e7          	jalr	-606(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004e28:	40dc                	lw	a5,4(s1)
    80004e2a:	02f05263          	blez	a5,80004e4e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004e2e:	2785                	addiw	a5,a5,1
    80004e30:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004e32:	0002c517          	auipc	a0,0x2c
    80004e36:	78650513          	addi	a0,a0,1926 # 800315b8 <ftable>
    80004e3a:	ffffc097          	auipc	ra,0xffffc
    80004e3e:	e3c080e7          	jalr	-452(ra) # 80000c76 <release>
  return f;
}
    80004e42:	8526                	mv	a0,s1
    80004e44:	60e2                	ld	ra,24(sp)
    80004e46:	6442                	ld	s0,16(sp)
    80004e48:	64a2                	ld	s1,8(sp)
    80004e4a:	6105                	addi	sp,sp,32
    80004e4c:	8082                	ret
    panic("filedup");
    80004e4e:	00004517          	auipc	a0,0x4
    80004e52:	99a50513          	addi	a0,a0,-1638 # 800087e8 <syscalls+0x2e8>
    80004e56:	ffffb097          	auipc	ra,0xffffb
    80004e5a:	6d4080e7          	jalr	1748(ra) # 8000052a <panic>

0000000080004e5e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004e5e:	7139                	addi	sp,sp,-64
    80004e60:	fc06                	sd	ra,56(sp)
    80004e62:	f822                	sd	s0,48(sp)
    80004e64:	f426                	sd	s1,40(sp)
    80004e66:	f04a                	sd	s2,32(sp)
    80004e68:	ec4e                	sd	s3,24(sp)
    80004e6a:	e852                	sd	s4,16(sp)
    80004e6c:	e456                	sd	s5,8(sp)
    80004e6e:	0080                	addi	s0,sp,64
    80004e70:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004e72:	0002c517          	auipc	a0,0x2c
    80004e76:	74650513          	addi	a0,a0,1862 # 800315b8 <ftable>
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	d48080e7          	jalr	-696(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004e82:	40dc                	lw	a5,4(s1)
    80004e84:	06f05163          	blez	a5,80004ee6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004e88:	37fd                	addiw	a5,a5,-1
    80004e8a:	0007871b          	sext.w	a4,a5
    80004e8e:	c0dc                	sw	a5,4(s1)
    80004e90:	06e04363          	bgtz	a4,80004ef6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e94:	0004a903          	lw	s2,0(s1)
    80004e98:	0094ca83          	lbu	s5,9(s1)
    80004e9c:	0104ba03          	ld	s4,16(s1)
    80004ea0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ea4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ea8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004eac:	0002c517          	auipc	a0,0x2c
    80004eb0:	70c50513          	addi	a0,a0,1804 # 800315b8 <ftable>
    80004eb4:	ffffc097          	auipc	ra,0xffffc
    80004eb8:	dc2080e7          	jalr	-574(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004ebc:	4785                	li	a5,1
    80004ebe:	04f90d63          	beq	s2,a5,80004f18 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004ec2:	3979                	addiw	s2,s2,-2
    80004ec4:	4785                	li	a5,1
    80004ec6:	0527e063          	bltu	a5,s2,80004f06 <fileclose+0xa8>
    begin_op();
    80004eca:	00000097          	auipc	ra,0x0
    80004ece:	ac8080e7          	jalr	-1336(ra) # 80004992 <begin_op>
    iput(ff.ip);
    80004ed2:	854e                	mv	a0,s3
    80004ed4:	fffff097          	auipc	ra,0xfffff
    80004ed8:	f5a080e7          	jalr	-166(ra) # 80003e2e <iput>
    end_op();
    80004edc:	00000097          	auipc	ra,0x0
    80004ee0:	b36080e7          	jalr	-1226(ra) # 80004a12 <end_op>
    80004ee4:	a00d                	j	80004f06 <fileclose+0xa8>
    panic("fileclose");
    80004ee6:	00004517          	auipc	a0,0x4
    80004eea:	90a50513          	addi	a0,a0,-1782 # 800087f0 <syscalls+0x2f0>
    80004eee:	ffffb097          	auipc	ra,0xffffb
    80004ef2:	63c080e7          	jalr	1596(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004ef6:	0002c517          	auipc	a0,0x2c
    80004efa:	6c250513          	addi	a0,a0,1730 # 800315b8 <ftable>
    80004efe:	ffffc097          	auipc	ra,0xffffc
    80004f02:	d78080e7          	jalr	-648(ra) # 80000c76 <release>
  }
}
    80004f06:	70e2                	ld	ra,56(sp)
    80004f08:	7442                	ld	s0,48(sp)
    80004f0a:	74a2                	ld	s1,40(sp)
    80004f0c:	7902                	ld	s2,32(sp)
    80004f0e:	69e2                	ld	s3,24(sp)
    80004f10:	6a42                	ld	s4,16(sp)
    80004f12:	6aa2                	ld	s5,8(sp)
    80004f14:	6121                	addi	sp,sp,64
    80004f16:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004f18:	85d6                	mv	a1,s5
    80004f1a:	8552                	mv	a0,s4
    80004f1c:	00000097          	auipc	ra,0x0
    80004f20:	542080e7          	jalr	1346(ra) # 8000545e <pipeclose>
    80004f24:	b7cd                	j	80004f06 <fileclose+0xa8>

0000000080004f26 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004f26:	715d                	addi	sp,sp,-80
    80004f28:	e486                	sd	ra,72(sp)
    80004f2a:	e0a2                	sd	s0,64(sp)
    80004f2c:	fc26                	sd	s1,56(sp)
    80004f2e:	f84a                	sd	s2,48(sp)
    80004f30:	f44e                	sd	s3,40(sp)
    80004f32:	0880                	addi	s0,sp,80
    80004f34:	84aa                	mv	s1,a0
    80004f36:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004f38:	ffffd097          	auipc	ra,0xffffd
    80004f3c:	f2e080e7          	jalr	-210(ra) # 80001e66 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004f40:	409c                	lw	a5,0(s1)
    80004f42:	37f9                	addiw	a5,a5,-2
    80004f44:	4705                	li	a4,1
    80004f46:	04f76763          	bltu	a4,a5,80004f94 <filestat+0x6e>
    80004f4a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004f4c:	6c88                	ld	a0,24(s1)
    80004f4e:	fffff097          	auipc	ra,0xfffff
    80004f52:	d26080e7          	jalr	-730(ra) # 80003c74 <ilock>
    stati(f->ip, &st);
    80004f56:	fb840593          	addi	a1,s0,-72
    80004f5a:	6c88                	ld	a0,24(s1)
    80004f5c:	fffff097          	auipc	ra,0xfffff
    80004f60:	fa2080e7          	jalr	-94(ra) # 80003efe <stati>
    iunlock(f->ip);
    80004f64:	6c88                	ld	a0,24(s1)
    80004f66:	fffff097          	auipc	ra,0xfffff
    80004f6a:	dd0080e7          	jalr	-560(ra) # 80003d36 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f6e:	46e1                	li	a3,24
    80004f70:	fb840613          	addi	a2,s0,-72
    80004f74:	85ce                	mv	a1,s3
    80004f76:	05093503          	ld	a0,80(s2)
    80004f7a:	ffffc097          	auipc	ra,0xffffc
    80004f7e:	404080e7          	jalr	1028(ra) # 8000137e <copyout>
    80004f82:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004f86:	60a6                	ld	ra,72(sp)
    80004f88:	6406                	ld	s0,64(sp)
    80004f8a:	74e2                	ld	s1,56(sp)
    80004f8c:	7942                	ld	s2,48(sp)
    80004f8e:	79a2                	ld	s3,40(sp)
    80004f90:	6161                	addi	sp,sp,80
    80004f92:	8082                	ret
  return -1;
    80004f94:	557d                	li	a0,-1
    80004f96:	bfc5                	j	80004f86 <filestat+0x60>

0000000080004f98 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f98:	7179                	addi	sp,sp,-48
    80004f9a:	f406                	sd	ra,40(sp)
    80004f9c:	f022                	sd	s0,32(sp)
    80004f9e:	ec26                	sd	s1,24(sp)
    80004fa0:	e84a                	sd	s2,16(sp)
    80004fa2:	e44e                	sd	s3,8(sp)
    80004fa4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004fa6:	00854783          	lbu	a5,8(a0)
    80004faa:	c3d5                	beqz	a5,8000504e <fileread+0xb6>
    80004fac:	84aa                	mv	s1,a0
    80004fae:	89ae                	mv	s3,a1
    80004fb0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004fb2:	411c                	lw	a5,0(a0)
    80004fb4:	4705                	li	a4,1
    80004fb6:	04e78963          	beq	a5,a4,80005008 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004fba:	470d                	li	a4,3
    80004fbc:	04e78d63          	beq	a5,a4,80005016 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004fc0:	4709                	li	a4,2
    80004fc2:	06e79e63          	bne	a5,a4,8000503e <fileread+0xa6>
    ilock(f->ip);
    80004fc6:	6d08                	ld	a0,24(a0)
    80004fc8:	fffff097          	auipc	ra,0xfffff
    80004fcc:	cac080e7          	jalr	-852(ra) # 80003c74 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004fd0:	874a                	mv	a4,s2
    80004fd2:	5094                	lw	a3,32(s1)
    80004fd4:	864e                	mv	a2,s3
    80004fd6:	4585                	li	a1,1
    80004fd8:	6c88                	ld	a0,24(s1)
    80004fda:	fffff097          	auipc	ra,0xfffff
    80004fde:	f4e080e7          	jalr	-178(ra) # 80003f28 <readi>
    80004fe2:	892a                	mv	s2,a0
    80004fe4:	00a05563          	blez	a0,80004fee <fileread+0x56>
      f->off += r;
    80004fe8:	509c                	lw	a5,32(s1)
    80004fea:	9fa9                	addw	a5,a5,a0
    80004fec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004fee:	6c88                	ld	a0,24(s1)
    80004ff0:	fffff097          	auipc	ra,0xfffff
    80004ff4:	d46080e7          	jalr	-698(ra) # 80003d36 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ff8:	854a                	mv	a0,s2
    80004ffa:	70a2                	ld	ra,40(sp)
    80004ffc:	7402                	ld	s0,32(sp)
    80004ffe:	64e2                	ld	s1,24(sp)
    80005000:	6942                	ld	s2,16(sp)
    80005002:	69a2                	ld	s3,8(sp)
    80005004:	6145                	addi	sp,sp,48
    80005006:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005008:	6908                	ld	a0,16(a0)
    8000500a:	00000097          	auipc	ra,0x0
    8000500e:	5b6080e7          	jalr	1462(ra) # 800055c0 <piperead>
    80005012:	892a                	mv	s2,a0
    80005014:	b7d5                	j	80004ff8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005016:	02451783          	lh	a5,36(a0)
    8000501a:	03079693          	slli	a3,a5,0x30
    8000501e:	92c1                	srli	a3,a3,0x30
    80005020:	4725                	li	a4,9
    80005022:	02d76863          	bltu	a4,a3,80005052 <fileread+0xba>
    80005026:	0792                	slli	a5,a5,0x4
    80005028:	0002c717          	auipc	a4,0x2c
    8000502c:	4f070713          	addi	a4,a4,1264 # 80031518 <devsw>
    80005030:	97ba                	add	a5,a5,a4
    80005032:	639c                	ld	a5,0(a5)
    80005034:	c38d                	beqz	a5,80005056 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005036:	4505                	li	a0,1
    80005038:	9782                	jalr	a5
    8000503a:	892a                	mv	s2,a0
    8000503c:	bf75                	j	80004ff8 <fileread+0x60>
    panic("fileread");
    8000503e:	00003517          	auipc	a0,0x3
    80005042:	7c250513          	addi	a0,a0,1986 # 80008800 <syscalls+0x300>
    80005046:	ffffb097          	auipc	ra,0xffffb
    8000504a:	4e4080e7          	jalr	1252(ra) # 8000052a <panic>
    return -1;
    8000504e:	597d                	li	s2,-1
    80005050:	b765                	j	80004ff8 <fileread+0x60>
      return -1;
    80005052:	597d                	li	s2,-1
    80005054:	b755                	j	80004ff8 <fileread+0x60>
    80005056:	597d                	li	s2,-1
    80005058:	b745                	j	80004ff8 <fileread+0x60>

000000008000505a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000505a:	715d                	addi	sp,sp,-80
    8000505c:	e486                	sd	ra,72(sp)
    8000505e:	e0a2                	sd	s0,64(sp)
    80005060:	fc26                	sd	s1,56(sp)
    80005062:	f84a                	sd	s2,48(sp)
    80005064:	f44e                	sd	s3,40(sp)
    80005066:	f052                	sd	s4,32(sp)
    80005068:	ec56                	sd	s5,24(sp)
    8000506a:	e85a                	sd	s6,16(sp)
    8000506c:	e45e                	sd	s7,8(sp)
    8000506e:	e062                	sd	s8,0(sp)
    80005070:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005072:	00954783          	lbu	a5,9(a0)
    80005076:	10078663          	beqz	a5,80005182 <filewrite+0x128>
    8000507a:	892a                	mv	s2,a0
    8000507c:	8aae                	mv	s5,a1
    8000507e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005080:	411c                	lw	a5,0(a0)
    80005082:	4705                	li	a4,1
    80005084:	02e78263          	beq	a5,a4,800050a8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005088:	470d                	li	a4,3
    8000508a:	02e78663          	beq	a5,a4,800050b6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000508e:	4709                	li	a4,2
    80005090:	0ee79163          	bne	a5,a4,80005172 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005094:	0ac05d63          	blez	a2,8000514e <filewrite+0xf4>
    int i = 0;
    80005098:	4981                	li	s3,0
    8000509a:	6b05                	lui	s6,0x1
    8000509c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800050a0:	6b85                	lui	s7,0x1
    800050a2:	c00b8b9b          	addiw	s7,s7,-1024
    800050a6:	a861                	j	8000513e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800050a8:	6908                	ld	a0,16(a0)
    800050aa:	00000097          	auipc	ra,0x0
    800050ae:	424080e7          	jalr	1060(ra) # 800054ce <pipewrite>
    800050b2:	8a2a                	mv	s4,a0
    800050b4:	a045                	j	80005154 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800050b6:	02451783          	lh	a5,36(a0)
    800050ba:	03079693          	slli	a3,a5,0x30
    800050be:	92c1                	srli	a3,a3,0x30
    800050c0:	4725                	li	a4,9
    800050c2:	0cd76263          	bltu	a4,a3,80005186 <filewrite+0x12c>
    800050c6:	0792                	slli	a5,a5,0x4
    800050c8:	0002c717          	auipc	a4,0x2c
    800050cc:	45070713          	addi	a4,a4,1104 # 80031518 <devsw>
    800050d0:	97ba                	add	a5,a5,a4
    800050d2:	679c                	ld	a5,8(a5)
    800050d4:	cbdd                	beqz	a5,8000518a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800050d6:	4505                	li	a0,1
    800050d8:	9782                	jalr	a5
    800050da:	8a2a                	mv	s4,a0
    800050dc:	a8a5                	j	80005154 <filewrite+0xfa>
    800050de:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800050e2:	00000097          	auipc	ra,0x0
    800050e6:	8b0080e7          	jalr	-1872(ra) # 80004992 <begin_op>
      ilock(f->ip);
    800050ea:	01893503          	ld	a0,24(s2)
    800050ee:	fffff097          	auipc	ra,0xfffff
    800050f2:	b86080e7          	jalr	-1146(ra) # 80003c74 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800050f6:	8762                	mv	a4,s8
    800050f8:	02092683          	lw	a3,32(s2)
    800050fc:	01598633          	add	a2,s3,s5
    80005100:	4585                	li	a1,1
    80005102:	01893503          	ld	a0,24(s2)
    80005106:	fffff097          	auipc	ra,0xfffff
    8000510a:	f1a080e7          	jalr	-230(ra) # 80004020 <writei>
    8000510e:	84aa                	mv	s1,a0
    80005110:	00a05763          	blez	a0,8000511e <filewrite+0xc4>
        f->off += r;
    80005114:	02092783          	lw	a5,32(s2)
    80005118:	9fa9                	addw	a5,a5,a0
    8000511a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000511e:	01893503          	ld	a0,24(s2)
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	c14080e7          	jalr	-1004(ra) # 80003d36 <iunlock>
      end_op();
    8000512a:	00000097          	auipc	ra,0x0
    8000512e:	8e8080e7          	jalr	-1816(ra) # 80004a12 <end_op>

      if(r != n1){
    80005132:	009c1f63          	bne	s8,s1,80005150 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005136:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000513a:	0149db63          	bge	s3,s4,80005150 <filewrite+0xf6>
      int n1 = n - i;
    8000513e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005142:	84be                	mv	s1,a5
    80005144:	2781                	sext.w	a5,a5
    80005146:	f8fb5ce3          	bge	s6,a5,800050de <filewrite+0x84>
    8000514a:	84de                	mv	s1,s7
    8000514c:	bf49                	j	800050de <filewrite+0x84>
    int i = 0;
    8000514e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005150:	013a1f63          	bne	s4,s3,8000516e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005154:	8552                	mv	a0,s4
    80005156:	60a6                	ld	ra,72(sp)
    80005158:	6406                	ld	s0,64(sp)
    8000515a:	74e2                	ld	s1,56(sp)
    8000515c:	7942                	ld	s2,48(sp)
    8000515e:	79a2                	ld	s3,40(sp)
    80005160:	7a02                	ld	s4,32(sp)
    80005162:	6ae2                	ld	s5,24(sp)
    80005164:	6b42                	ld	s6,16(sp)
    80005166:	6ba2                	ld	s7,8(sp)
    80005168:	6c02                	ld	s8,0(sp)
    8000516a:	6161                	addi	sp,sp,80
    8000516c:	8082                	ret
    ret = (i == n ? n : -1);
    8000516e:	5a7d                	li	s4,-1
    80005170:	b7d5                	j	80005154 <filewrite+0xfa>
    panic("filewrite");
    80005172:	00003517          	auipc	a0,0x3
    80005176:	69e50513          	addi	a0,a0,1694 # 80008810 <syscalls+0x310>
    8000517a:	ffffb097          	auipc	ra,0xffffb
    8000517e:	3b0080e7          	jalr	944(ra) # 8000052a <panic>
    return -1;
    80005182:	5a7d                	li	s4,-1
    80005184:	bfc1                	j	80005154 <filewrite+0xfa>
      return -1;
    80005186:	5a7d                	li	s4,-1
    80005188:	b7f1                	j	80005154 <filewrite+0xfa>
    8000518a:	5a7d                	li	s4,-1
    8000518c:	b7e1                	j	80005154 <filewrite+0xfa>

000000008000518e <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    8000518e:	7179                	addi	sp,sp,-48
    80005190:	f406                	sd	ra,40(sp)
    80005192:	f022                	sd	s0,32(sp)
    80005194:	ec26                	sd	s1,24(sp)
    80005196:	e84a                	sd	s2,16(sp)
    80005198:	e44e                	sd	s3,8(sp)
    8000519a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000519c:	00854783          	lbu	a5,8(a0)
    800051a0:	c3d5                	beqz	a5,80005244 <kfileread+0xb6>
    800051a2:	84aa                	mv	s1,a0
    800051a4:	89ae                	mv	s3,a1
    800051a6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800051a8:	411c                	lw	a5,0(a0)
    800051aa:	4705                	li	a4,1
    800051ac:	04e78963          	beq	a5,a4,800051fe <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800051b0:	470d                	li	a4,3
    800051b2:	04e78d63          	beq	a5,a4,8000520c <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800051b6:	4709                	li	a4,2
    800051b8:	06e79e63          	bne	a5,a4,80005234 <kfileread+0xa6>
    ilock(f->ip);
    800051bc:	6d08                	ld	a0,24(a0)
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	ab6080e7          	jalr	-1354(ra) # 80003c74 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    800051c6:	874a                	mv	a4,s2
    800051c8:	5094                	lw	a3,32(s1)
    800051ca:	864e                	mv	a2,s3
    800051cc:	4581                	li	a1,0
    800051ce:	6c88                	ld	a0,24(s1)
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	d58080e7          	jalr	-680(ra) # 80003f28 <readi>
    800051d8:	892a                	mv	s2,a0
    800051da:	00a05563          	blez	a0,800051e4 <kfileread+0x56>
      f->off += r;
    800051de:	509c                	lw	a5,32(s1)
    800051e0:	9fa9                	addw	a5,a5,a0
    800051e2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800051e4:	6c88                	ld	a0,24(s1)
    800051e6:	fffff097          	auipc	ra,0xfffff
    800051ea:	b50080e7          	jalr	-1200(ra) # 80003d36 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800051ee:	854a                	mv	a0,s2
    800051f0:	70a2                	ld	ra,40(sp)
    800051f2:	7402                	ld	s0,32(sp)
    800051f4:	64e2                	ld	s1,24(sp)
    800051f6:	6942                	ld	s2,16(sp)
    800051f8:	69a2                	ld	s3,8(sp)
    800051fa:	6145                	addi	sp,sp,48
    800051fc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800051fe:	6908                	ld	a0,16(a0)
    80005200:	00000097          	auipc	ra,0x0
    80005204:	3c0080e7          	jalr	960(ra) # 800055c0 <piperead>
    80005208:	892a                	mv	s2,a0
    8000520a:	b7d5                	j	800051ee <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000520c:	02451783          	lh	a5,36(a0)
    80005210:	03079693          	slli	a3,a5,0x30
    80005214:	92c1                	srli	a3,a3,0x30
    80005216:	4725                	li	a4,9
    80005218:	02d76863          	bltu	a4,a3,80005248 <kfileread+0xba>
    8000521c:	0792                	slli	a5,a5,0x4
    8000521e:	0002c717          	auipc	a4,0x2c
    80005222:	2fa70713          	addi	a4,a4,762 # 80031518 <devsw>
    80005226:	97ba                	add	a5,a5,a4
    80005228:	639c                	ld	a5,0(a5)
    8000522a:	c38d                	beqz	a5,8000524c <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000522c:	4505                	li	a0,1
    8000522e:	9782                	jalr	a5
    80005230:	892a                	mv	s2,a0
    80005232:	bf75                	j	800051ee <kfileread+0x60>
    panic("fileread");
    80005234:	00003517          	auipc	a0,0x3
    80005238:	5cc50513          	addi	a0,a0,1484 # 80008800 <syscalls+0x300>
    8000523c:	ffffb097          	auipc	ra,0xffffb
    80005240:	2ee080e7          	jalr	750(ra) # 8000052a <panic>
    return -1;
    80005244:	597d                	li	s2,-1
    80005246:	b765                	j	800051ee <kfileread+0x60>
      return -1;
    80005248:	597d                	li	s2,-1
    8000524a:	b755                	j	800051ee <kfileread+0x60>
    8000524c:	597d                	li	s2,-1
    8000524e:	b745                	j	800051ee <kfileread+0x60>

0000000080005250 <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    80005250:	715d                	addi	sp,sp,-80
    80005252:	e486                	sd	ra,72(sp)
    80005254:	e0a2                	sd	s0,64(sp)
    80005256:	fc26                	sd	s1,56(sp)
    80005258:	f84a                	sd	s2,48(sp)
    8000525a:	f44e                	sd	s3,40(sp)
    8000525c:	f052                	sd	s4,32(sp)
    8000525e:	ec56                	sd	s5,24(sp)
    80005260:	e85a                	sd	s6,16(sp)
    80005262:	e45e                	sd	s7,8(sp)
    80005264:	e062                	sd	s8,0(sp)
    80005266:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005268:	00954783          	lbu	a5,9(a0)
    8000526c:	10078663          	beqz	a5,80005378 <kfilewrite+0x128>
    80005270:	892a                	mv	s2,a0
    80005272:	8aae                	mv	s5,a1
    80005274:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005276:	411c                	lw	a5,0(a0)
    80005278:	4705                	li	a4,1
    8000527a:	02e78263          	beq	a5,a4,8000529e <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000527e:	470d                	li	a4,3
    80005280:	02e78663          	beq	a5,a4,800052ac <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005284:	4709                	li	a4,2
    80005286:	0ee79163          	bne	a5,a4,80005368 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000528a:	0ac05d63          	blez	a2,80005344 <kfilewrite+0xf4>
    int i = 0;
    8000528e:	4981                	li	s3,0
    80005290:	6b05                	lui	s6,0x1
    80005292:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005296:	6b85                	lui	s7,0x1
    80005298:	c00b8b9b          	addiw	s7,s7,-1024
    8000529c:	a861                	j	80005334 <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000529e:	6908                	ld	a0,16(a0)
    800052a0:	00000097          	auipc	ra,0x0
    800052a4:	22e080e7          	jalr	558(ra) # 800054ce <pipewrite>
    800052a8:	8a2a                	mv	s4,a0
    800052aa:	a045                	j	8000534a <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800052ac:	02451783          	lh	a5,36(a0)
    800052b0:	03079693          	slli	a3,a5,0x30
    800052b4:	92c1                	srli	a3,a3,0x30
    800052b6:	4725                	li	a4,9
    800052b8:	0cd76263          	bltu	a4,a3,8000537c <kfilewrite+0x12c>
    800052bc:	0792                	slli	a5,a5,0x4
    800052be:	0002c717          	auipc	a4,0x2c
    800052c2:	25a70713          	addi	a4,a4,602 # 80031518 <devsw>
    800052c6:	97ba                	add	a5,a5,a4
    800052c8:	679c                	ld	a5,8(a5)
    800052ca:	cbdd                	beqz	a5,80005380 <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800052cc:	4505                	li	a0,1
    800052ce:	9782                	jalr	a5
    800052d0:	8a2a                	mv	s4,a0
    800052d2:	a8a5                	j	8000534a <kfilewrite+0xfa>
    800052d4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	6ba080e7          	jalr	1722(ra) # 80004992 <begin_op>
      ilock(f->ip);
    800052e0:	01893503          	ld	a0,24(s2)
    800052e4:	fffff097          	auipc	ra,0xfffff
    800052e8:	990080e7          	jalr	-1648(ra) # 80003c74 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    800052ec:	8762                	mv	a4,s8
    800052ee:	02092683          	lw	a3,32(s2)
    800052f2:	01598633          	add	a2,s3,s5
    800052f6:	4581                	li	a1,0
    800052f8:	01893503          	ld	a0,24(s2)
    800052fc:	fffff097          	auipc	ra,0xfffff
    80005300:	d24080e7          	jalr	-732(ra) # 80004020 <writei>
    80005304:	84aa                	mv	s1,a0
    80005306:	00a05763          	blez	a0,80005314 <kfilewrite+0xc4>
        f->off += r;
    8000530a:	02092783          	lw	a5,32(s2)
    8000530e:	9fa9                	addw	a5,a5,a0
    80005310:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005314:	01893503          	ld	a0,24(s2)
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	a1e080e7          	jalr	-1506(ra) # 80003d36 <iunlock>
      end_op();
    80005320:	fffff097          	auipc	ra,0xfffff
    80005324:	6f2080e7          	jalr	1778(ra) # 80004a12 <end_op>

      if(r != n1){
    80005328:	009c1f63          	bne	s8,s1,80005346 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000532c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005330:	0149db63          	bge	s3,s4,80005346 <kfilewrite+0xf6>
      int n1 = n - i;
    80005334:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005338:	84be                	mv	s1,a5
    8000533a:	2781                	sext.w	a5,a5
    8000533c:	f8fb5ce3          	bge	s6,a5,800052d4 <kfilewrite+0x84>
    80005340:	84de                	mv	s1,s7
    80005342:	bf49                	j	800052d4 <kfilewrite+0x84>
    int i = 0;
    80005344:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005346:	013a1f63          	bne	s4,s3,80005364 <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    8000534a:	8552                	mv	a0,s4
    8000534c:	60a6                	ld	ra,72(sp)
    8000534e:	6406                	ld	s0,64(sp)
    80005350:	74e2                	ld	s1,56(sp)
    80005352:	7942                	ld	s2,48(sp)
    80005354:	79a2                	ld	s3,40(sp)
    80005356:	7a02                	ld	s4,32(sp)
    80005358:	6ae2                	ld	s5,24(sp)
    8000535a:	6b42                	ld	s6,16(sp)
    8000535c:	6ba2                	ld	s7,8(sp)
    8000535e:	6c02                	ld	s8,0(sp)
    80005360:	6161                	addi	sp,sp,80
    80005362:	8082                	ret
    ret = (i == n ? n : -1);
    80005364:	5a7d                	li	s4,-1
    80005366:	b7d5                	j	8000534a <kfilewrite+0xfa>
    panic("filewrite");
    80005368:	00003517          	auipc	a0,0x3
    8000536c:	4a850513          	addi	a0,a0,1192 # 80008810 <syscalls+0x310>
    80005370:	ffffb097          	auipc	ra,0xffffb
    80005374:	1ba080e7          	jalr	442(ra) # 8000052a <panic>
    return -1;
    80005378:	5a7d                	li	s4,-1
    8000537a:	bfc1                	j	8000534a <kfilewrite+0xfa>
      return -1;
    8000537c:	5a7d                	li	s4,-1
    8000537e:	b7f1                	j	8000534a <kfilewrite+0xfa>
    80005380:	5a7d                	li	s4,-1
    80005382:	b7e1                	j	8000534a <kfilewrite+0xfa>

0000000080005384 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005384:	7179                	addi	sp,sp,-48
    80005386:	f406                	sd	ra,40(sp)
    80005388:	f022                	sd	s0,32(sp)
    8000538a:	ec26                	sd	s1,24(sp)
    8000538c:	e84a                	sd	s2,16(sp)
    8000538e:	e44e                	sd	s3,8(sp)
    80005390:	e052                	sd	s4,0(sp)
    80005392:	1800                	addi	s0,sp,48
    80005394:	84aa                	mv	s1,a0
    80005396:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005398:	0005b023          	sd	zero,0(a1)
    8000539c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800053a0:	00000097          	auipc	ra,0x0
    800053a4:	a02080e7          	jalr	-1534(ra) # 80004da2 <filealloc>
    800053a8:	e088                	sd	a0,0(s1)
    800053aa:	c551                	beqz	a0,80005436 <pipealloc+0xb2>
    800053ac:	00000097          	auipc	ra,0x0
    800053b0:	9f6080e7          	jalr	-1546(ra) # 80004da2 <filealloc>
    800053b4:	00aa3023          	sd	a0,0(s4)
    800053b8:	c92d                	beqz	a0,8000542a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800053ba:	ffffb097          	auipc	ra,0xffffb
    800053be:	718080e7          	jalr	1816(ra) # 80000ad2 <kalloc>
    800053c2:	892a                	mv	s2,a0
    800053c4:	c125                	beqz	a0,80005424 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800053c6:	4985                	li	s3,1
    800053c8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800053cc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800053d0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800053d4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800053d8:	00003597          	auipc	a1,0x3
    800053dc:	44858593          	addi	a1,a1,1096 # 80008820 <syscalls+0x320>
    800053e0:	ffffb097          	auipc	ra,0xffffb
    800053e4:	752080e7          	jalr	1874(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    800053e8:	609c                	ld	a5,0(s1)
    800053ea:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800053ee:	609c                	ld	a5,0(s1)
    800053f0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800053f4:	609c                	ld	a5,0(s1)
    800053f6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800053fa:	609c                	ld	a5,0(s1)
    800053fc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005400:	000a3783          	ld	a5,0(s4)
    80005404:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005408:	000a3783          	ld	a5,0(s4)
    8000540c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005410:	000a3783          	ld	a5,0(s4)
    80005414:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005418:	000a3783          	ld	a5,0(s4)
    8000541c:	0127b823          	sd	s2,16(a5)
  return 0;
    80005420:	4501                	li	a0,0
    80005422:	a025                	j	8000544a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005424:	6088                	ld	a0,0(s1)
    80005426:	e501                	bnez	a0,8000542e <pipealloc+0xaa>
    80005428:	a039                	j	80005436 <pipealloc+0xb2>
    8000542a:	6088                	ld	a0,0(s1)
    8000542c:	c51d                	beqz	a0,8000545a <pipealloc+0xd6>
    fileclose(*f0);
    8000542e:	00000097          	auipc	ra,0x0
    80005432:	a30080e7          	jalr	-1488(ra) # 80004e5e <fileclose>
  if(*f1)
    80005436:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000543a:	557d                	li	a0,-1
  if(*f1)
    8000543c:	c799                	beqz	a5,8000544a <pipealloc+0xc6>
    fileclose(*f1);
    8000543e:	853e                	mv	a0,a5
    80005440:	00000097          	auipc	ra,0x0
    80005444:	a1e080e7          	jalr	-1506(ra) # 80004e5e <fileclose>
  return -1;
    80005448:	557d                	li	a0,-1
}
    8000544a:	70a2                	ld	ra,40(sp)
    8000544c:	7402                	ld	s0,32(sp)
    8000544e:	64e2                	ld	s1,24(sp)
    80005450:	6942                	ld	s2,16(sp)
    80005452:	69a2                	ld	s3,8(sp)
    80005454:	6a02                	ld	s4,0(sp)
    80005456:	6145                	addi	sp,sp,48
    80005458:	8082                	ret
  return -1;
    8000545a:	557d                	li	a0,-1
    8000545c:	b7fd                	j	8000544a <pipealloc+0xc6>

000000008000545e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000545e:	1101                	addi	sp,sp,-32
    80005460:	ec06                	sd	ra,24(sp)
    80005462:	e822                	sd	s0,16(sp)
    80005464:	e426                	sd	s1,8(sp)
    80005466:	e04a                	sd	s2,0(sp)
    80005468:	1000                	addi	s0,sp,32
    8000546a:	84aa                	mv	s1,a0
    8000546c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000546e:	ffffb097          	auipc	ra,0xffffb
    80005472:	754080e7          	jalr	1876(ra) # 80000bc2 <acquire>
  if(writable){
    80005476:	02090d63          	beqz	s2,800054b0 <pipeclose+0x52>
    pi->writeopen = 0;
    8000547a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000547e:	21848513          	addi	a0,s1,536
    80005482:	ffffd097          	auipc	ra,0xffffd
    80005486:	326080e7          	jalr	806(ra) # 800027a8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000548a:	2204b783          	ld	a5,544(s1)
    8000548e:	eb95                	bnez	a5,800054c2 <pipeclose+0x64>
    release(&pi->lock);
    80005490:	8526                	mv	a0,s1
    80005492:	ffffb097          	auipc	ra,0xffffb
    80005496:	7e4080e7          	jalr	2020(ra) # 80000c76 <release>
    kfree((char*)pi);
    8000549a:	8526                	mv	a0,s1
    8000549c:	ffffb097          	auipc	ra,0xffffb
    800054a0:	53a080e7          	jalr	1338(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    800054a4:	60e2                	ld	ra,24(sp)
    800054a6:	6442                	ld	s0,16(sp)
    800054a8:	64a2                	ld	s1,8(sp)
    800054aa:	6902                	ld	s2,0(sp)
    800054ac:	6105                	addi	sp,sp,32
    800054ae:	8082                	ret
    pi->readopen = 0;
    800054b0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800054b4:	21c48513          	addi	a0,s1,540
    800054b8:	ffffd097          	auipc	ra,0xffffd
    800054bc:	2f0080e7          	jalr	752(ra) # 800027a8 <wakeup>
    800054c0:	b7e9                	j	8000548a <pipeclose+0x2c>
    release(&pi->lock);
    800054c2:	8526                	mv	a0,s1
    800054c4:	ffffb097          	auipc	ra,0xffffb
    800054c8:	7b2080e7          	jalr	1970(ra) # 80000c76 <release>
}
    800054cc:	bfe1                	j	800054a4 <pipeclose+0x46>

00000000800054ce <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800054ce:	711d                	addi	sp,sp,-96
    800054d0:	ec86                	sd	ra,88(sp)
    800054d2:	e8a2                	sd	s0,80(sp)
    800054d4:	e4a6                	sd	s1,72(sp)
    800054d6:	e0ca                	sd	s2,64(sp)
    800054d8:	fc4e                	sd	s3,56(sp)
    800054da:	f852                	sd	s4,48(sp)
    800054dc:	f456                	sd	s5,40(sp)
    800054de:	f05a                	sd	s6,32(sp)
    800054e0:	ec5e                	sd	s7,24(sp)
    800054e2:	e862                	sd	s8,16(sp)
    800054e4:	1080                	addi	s0,sp,96
    800054e6:	84aa                	mv	s1,a0
    800054e8:	8aae                	mv	s5,a1
    800054ea:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800054ec:	ffffd097          	auipc	ra,0xffffd
    800054f0:	97a080e7          	jalr	-1670(ra) # 80001e66 <myproc>
    800054f4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800054f6:	8526                	mv	a0,s1
    800054f8:	ffffb097          	auipc	ra,0xffffb
    800054fc:	6ca080e7          	jalr	1738(ra) # 80000bc2 <acquire>
  while(i < n){
    80005500:	0b405363          	blez	s4,800055a6 <pipewrite+0xd8>
  int i = 0;
    80005504:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005506:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005508:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000550c:	21c48b93          	addi	s7,s1,540
    80005510:	a089                	j	80005552 <pipewrite+0x84>
      release(&pi->lock);
    80005512:	8526                	mv	a0,s1
    80005514:	ffffb097          	auipc	ra,0xffffb
    80005518:	762080e7          	jalr	1890(ra) # 80000c76 <release>
      return -1;
    8000551c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000551e:	854a                	mv	a0,s2
    80005520:	60e6                	ld	ra,88(sp)
    80005522:	6446                	ld	s0,80(sp)
    80005524:	64a6                	ld	s1,72(sp)
    80005526:	6906                	ld	s2,64(sp)
    80005528:	79e2                	ld	s3,56(sp)
    8000552a:	7a42                	ld	s4,48(sp)
    8000552c:	7aa2                	ld	s5,40(sp)
    8000552e:	7b02                	ld	s6,32(sp)
    80005530:	6be2                	ld	s7,24(sp)
    80005532:	6c42                	ld	s8,16(sp)
    80005534:	6125                	addi	sp,sp,96
    80005536:	8082                	ret
      wakeup(&pi->nread);
    80005538:	8562                	mv	a0,s8
    8000553a:	ffffd097          	auipc	ra,0xffffd
    8000553e:	26e080e7          	jalr	622(ra) # 800027a8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005542:	85a6                	mv	a1,s1
    80005544:	855e                	mv	a0,s7
    80005546:	ffffd097          	auipc	ra,0xffffd
    8000554a:	0d6080e7          	jalr	214(ra) # 8000261c <sleep>
  while(i < n){
    8000554e:	05495d63          	bge	s2,s4,800055a8 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005552:	2204a783          	lw	a5,544(s1)
    80005556:	dfd5                	beqz	a5,80005512 <pipewrite+0x44>
    80005558:	0289a783          	lw	a5,40(s3)
    8000555c:	fbdd                	bnez	a5,80005512 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000555e:	2184a783          	lw	a5,536(s1)
    80005562:	21c4a703          	lw	a4,540(s1)
    80005566:	2007879b          	addiw	a5,a5,512
    8000556a:	fcf707e3          	beq	a4,a5,80005538 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000556e:	4685                	li	a3,1
    80005570:	01590633          	add	a2,s2,s5
    80005574:	faf40593          	addi	a1,s0,-81
    80005578:	0509b503          	ld	a0,80(s3)
    8000557c:	ffffc097          	auipc	ra,0xffffc
    80005580:	e8e080e7          	jalr	-370(ra) # 8000140a <copyin>
    80005584:	03650263          	beq	a0,s6,800055a8 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005588:	21c4a783          	lw	a5,540(s1)
    8000558c:	0017871b          	addiw	a4,a5,1
    80005590:	20e4ae23          	sw	a4,540(s1)
    80005594:	1ff7f793          	andi	a5,a5,511
    80005598:	97a6                	add	a5,a5,s1
    8000559a:	faf44703          	lbu	a4,-81(s0)
    8000559e:	00e78c23          	sb	a4,24(a5)
      i++;
    800055a2:	2905                	addiw	s2,s2,1
    800055a4:	b76d                	j	8000554e <pipewrite+0x80>
  int i = 0;
    800055a6:	4901                	li	s2,0
  wakeup(&pi->nread);
    800055a8:	21848513          	addi	a0,s1,536
    800055ac:	ffffd097          	auipc	ra,0xffffd
    800055b0:	1fc080e7          	jalr	508(ra) # 800027a8 <wakeup>
  release(&pi->lock);
    800055b4:	8526                	mv	a0,s1
    800055b6:	ffffb097          	auipc	ra,0xffffb
    800055ba:	6c0080e7          	jalr	1728(ra) # 80000c76 <release>
  return i;
    800055be:	b785                	j	8000551e <pipewrite+0x50>

00000000800055c0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800055c0:	715d                	addi	sp,sp,-80
    800055c2:	e486                	sd	ra,72(sp)
    800055c4:	e0a2                	sd	s0,64(sp)
    800055c6:	fc26                	sd	s1,56(sp)
    800055c8:	f84a                	sd	s2,48(sp)
    800055ca:	f44e                	sd	s3,40(sp)
    800055cc:	f052                	sd	s4,32(sp)
    800055ce:	ec56                	sd	s5,24(sp)
    800055d0:	e85a                	sd	s6,16(sp)
    800055d2:	0880                	addi	s0,sp,80
    800055d4:	84aa                	mv	s1,a0
    800055d6:	892e                	mv	s2,a1
    800055d8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800055da:	ffffd097          	auipc	ra,0xffffd
    800055de:	88c080e7          	jalr	-1908(ra) # 80001e66 <myproc>
    800055e2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffb097          	auipc	ra,0xffffb
    800055ea:	5dc080e7          	jalr	1500(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055ee:	2184a703          	lw	a4,536(s1)
    800055f2:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055f6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055fa:	02f71463          	bne	a4,a5,80005622 <piperead+0x62>
    800055fe:	2244a783          	lw	a5,548(s1)
    80005602:	c385                	beqz	a5,80005622 <piperead+0x62>
    if(pr->killed){
    80005604:	028a2783          	lw	a5,40(s4)
    80005608:	ebc1                	bnez	a5,80005698 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000560a:	85a6                	mv	a1,s1
    8000560c:	854e                	mv	a0,s3
    8000560e:	ffffd097          	auipc	ra,0xffffd
    80005612:	00e080e7          	jalr	14(ra) # 8000261c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005616:	2184a703          	lw	a4,536(s1)
    8000561a:	21c4a783          	lw	a5,540(s1)
    8000561e:	fef700e3          	beq	a4,a5,800055fe <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005622:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005624:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005626:	05505363          	blez	s5,8000566c <piperead+0xac>
    if(pi->nread == pi->nwrite)
    8000562a:	2184a783          	lw	a5,536(s1)
    8000562e:	21c4a703          	lw	a4,540(s1)
    80005632:	02f70d63          	beq	a4,a5,8000566c <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005636:	0017871b          	addiw	a4,a5,1
    8000563a:	20e4ac23          	sw	a4,536(s1)
    8000563e:	1ff7f793          	andi	a5,a5,511
    80005642:	97a6                	add	a5,a5,s1
    80005644:	0187c783          	lbu	a5,24(a5)
    80005648:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000564c:	4685                	li	a3,1
    8000564e:	fbf40613          	addi	a2,s0,-65
    80005652:	85ca                	mv	a1,s2
    80005654:	050a3503          	ld	a0,80(s4)
    80005658:	ffffc097          	auipc	ra,0xffffc
    8000565c:	d26080e7          	jalr	-730(ra) # 8000137e <copyout>
    80005660:	01650663          	beq	a0,s6,8000566c <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005664:	2985                	addiw	s3,s3,1
    80005666:	0905                	addi	s2,s2,1
    80005668:	fd3a91e3          	bne	s5,s3,8000562a <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000566c:	21c48513          	addi	a0,s1,540
    80005670:	ffffd097          	auipc	ra,0xffffd
    80005674:	138080e7          	jalr	312(ra) # 800027a8 <wakeup>
  release(&pi->lock);
    80005678:	8526                	mv	a0,s1
    8000567a:	ffffb097          	auipc	ra,0xffffb
    8000567e:	5fc080e7          	jalr	1532(ra) # 80000c76 <release>
  return i;
}
    80005682:	854e                	mv	a0,s3
    80005684:	60a6                	ld	ra,72(sp)
    80005686:	6406                	ld	s0,64(sp)
    80005688:	74e2                	ld	s1,56(sp)
    8000568a:	7942                	ld	s2,48(sp)
    8000568c:	79a2                	ld	s3,40(sp)
    8000568e:	7a02                	ld	s4,32(sp)
    80005690:	6ae2                	ld	s5,24(sp)
    80005692:	6b42                	ld	s6,16(sp)
    80005694:	6161                	addi	sp,sp,80
    80005696:	8082                	ret
      release(&pi->lock);
    80005698:	8526                	mv	a0,s1
    8000569a:	ffffb097          	auipc	ra,0xffffb
    8000569e:	5dc080e7          	jalr	1500(ra) # 80000c76 <release>
      return -1;
    800056a2:	59fd                	li	s3,-1
    800056a4:	bff9                	j	80005682 <piperead+0xc2>

00000000800056a6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800056a6:	de010113          	addi	sp,sp,-544
    800056aa:	20113c23          	sd	ra,536(sp)
    800056ae:	20813823          	sd	s0,528(sp)
    800056b2:	20913423          	sd	s1,520(sp)
    800056b6:	21213023          	sd	s2,512(sp)
    800056ba:	ffce                	sd	s3,504(sp)
    800056bc:	fbd2                	sd	s4,496(sp)
    800056be:	f7d6                	sd	s5,488(sp)
    800056c0:	f3da                	sd	s6,480(sp)
    800056c2:	efde                	sd	s7,472(sp)
    800056c4:	ebe2                	sd	s8,464(sp)
    800056c6:	e7e6                	sd	s9,456(sp)
    800056c8:	e3ea                	sd	s10,448(sp)
    800056ca:	ff6e                	sd	s11,440(sp)
    800056cc:	1400                	addi	s0,sp,544
    800056ce:	892a                	mv	s2,a0
    800056d0:	dea43423          	sd	a0,-536(s0)
    800056d4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800056d8:	ffffc097          	auipc	ra,0xffffc
    800056dc:	78e080e7          	jalr	1934(ra) # 80001e66 <myproc>
    800056e0:	84aa                	mv	s1,a0
  printf("exec\n");
    800056e2:	00003517          	auipc	a0,0x3
    800056e6:	14650513          	addi	a0,a0,326 # 80008828 <syscalls+0x328>
    800056ea:	ffffb097          	auipc	ra,0xffffb
    800056ee:	e8a080e7          	jalr	-374(ra) # 80000574 <printf>
  begin_op();
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	2a0080e7          	jalr	672(ra) # 80004992 <begin_op>

  if((ip = namei(path)) == 0){
    800056fa:	854a                	mv	a0,s2
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	d2e080e7          	jalr	-722(ra) # 8000442a <namei>
    80005704:	c93d                	beqz	a0,8000577a <exec+0xd4>
    80005706:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	56c080e7          	jalr	1388(ra) # 80003c74 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005710:	04000713          	li	a4,64
    80005714:	4681                	li	a3,0
    80005716:	e4840613          	addi	a2,s0,-440
    8000571a:	4581                	li	a1,0
    8000571c:	8556                	mv	a0,s5
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	80a080e7          	jalr	-2038(ra) # 80003f28 <readi>
    80005726:	04000793          	li	a5,64
    8000572a:	00f51a63          	bne	a0,a5,8000573e <exec+0x98>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000572e:	e4842703          	lw	a4,-440(s0)
    80005732:	464c47b7          	lui	a5,0x464c4
    80005736:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000573a:	04f70663          	beq	a4,a5,80005786 <exec+0xe0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000573e:	8556                	mv	a0,s5
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	796080e7          	jalr	1942(ra) # 80003ed6 <iunlockput>
    end_op();
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	2ca080e7          	jalr	714(ra) # 80004a12 <end_op>
  }
  return -1;
    80005750:	557d                	li	a0,-1
}
    80005752:	21813083          	ld	ra,536(sp)
    80005756:	21013403          	ld	s0,528(sp)
    8000575a:	20813483          	ld	s1,520(sp)
    8000575e:	20013903          	ld	s2,512(sp)
    80005762:	79fe                	ld	s3,504(sp)
    80005764:	7a5e                	ld	s4,496(sp)
    80005766:	7abe                	ld	s5,488(sp)
    80005768:	7b1e                	ld	s6,480(sp)
    8000576a:	6bfe                	ld	s7,472(sp)
    8000576c:	6c5e                	ld	s8,464(sp)
    8000576e:	6cbe                	ld	s9,456(sp)
    80005770:	6d1e                	ld	s10,448(sp)
    80005772:	7dfa                	ld	s11,440(sp)
    80005774:	22010113          	addi	sp,sp,544
    80005778:	8082                	ret
    end_op();
    8000577a:	fffff097          	auipc	ra,0xfffff
    8000577e:	298080e7          	jalr	664(ra) # 80004a12 <end_op>
    return -1;
    80005782:	557d                	li	a0,-1
    80005784:	b7f9                	j	80005752 <exec+0xac>
  if((pagetable = proc_pagetable(p)) == 0)
    80005786:	8526                	mv	a0,s1
    80005788:	ffffc097          	auipc	ra,0xffffc
    8000578c:	7a2080e7          	jalr	1954(ra) # 80001f2a <proc_pagetable>
    80005790:	8b2a                	mv	s6,a0
    80005792:	d555                	beqz	a0,8000573e <exec+0x98>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005794:	e6842783          	lw	a5,-408(s0)
    80005798:	e8045703          	lhu	a4,-384(s0)
    8000579c:	c735                	beqz	a4,80005808 <exec+0x162>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000579e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057a0:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800057a4:	6a05                	lui	s4,0x1
    800057a6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800057aa:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800057ae:	6d85                	lui	s11,0x1
    800057b0:	7d7d                	lui	s10,0xfffff
    800057b2:	ac1d                	j	800059e8 <exec+0x342>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800057b4:	00003517          	auipc	a0,0x3
    800057b8:	07c50513          	addi	a0,a0,124 # 80008830 <syscalls+0x330>
    800057bc:	ffffb097          	auipc	ra,0xffffb
    800057c0:	d6e080e7          	jalr	-658(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800057c4:	874a                	mv	a4,s2
    800057c6:	009c86bb          	addw	a3,s9,s1
    800057ca:	4581                	li	a1,0
    800057cc:	8556                	mv	a0,s5
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	75a080e7          	jalr	1882(ra) # 80003f28 <readi>
    800057d6:	2501                	sext.w	a0,a0
    800057d8:	1aa91863          	bne	s2,a0,80005988 <exec+0x2e2>
  for(i = 0; i < sz; i += PGSIZE){
    800057dc:	009d84bb          	addw	s1,s11,s1
    800057e0:	013d09bb          	addw	s3,s10,s3
    800057e4:	1f74f263          	bgeu	s1,s7,800059c8 <exec+0x322>
    pa = walkaddr(pagetable, va + i);
    800057e8:	02049593          	slli	a1,s1,0x20
    800057ec:	9181                	srli	a1,a1,0x20
    800057ee:	95e2                	add	a1,a1,s8
    800057f0:	855a                	mv	a0,s6
    800057f2:	ffffc097          	auipc	ra,0xffffc
    800057f6:	85a080e7          	jalr	-1958(ra) # 8000104c <walkaddr>
    800057fa:	862a                	mv	a2,a0
    if(pa == 0)
    800057fc:	dd45                	beqz	a0,800057b4 <exec+0x10e>
      n = PGSIZE;
    800057fe:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005800:	fd49f2e3          	bgeu	s3,s4,800057c4 <exec+0x11e>
      n = sz - i;
    80005804:	894e                	mv	s2,s3
    80005806:	bf7d                	j	800057c4 <exec+0x11e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005808:	4481                	li	s1,0
  iunlockput(ip);
    8000580a:	8556                	mv	a0,s5
    8000580c:	ffffe097          	auipc	ra,0xffffe
    80005810:	6ca080e7          	jalr	1738(ra) # 80003ed6 <iunlockput>
  end_op();
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	1fe080e7          	jalr	510(ra) # 80004a12 <end_op>
  p = myproc();
    8000581c:	ffffc097          	auipc	ra,0xffffc
    80005820:	64a080e7          	jalr	1610(ra) # 80001e66 <myproc>
    80005824:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005826:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000582a:	6785                	lui	a5,0x1
    8000582c:	17fd                	addi	a5,a5,-1
    8000582e:	94be                	add	s1,s1,a5
    80005830:	77fd                	lui	a5,0xfffff
    80005832:	8fe5                	and	a5,a5,s1
    80005834:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005838:	6609                	lui	a2,0x2
    8000583a:	963e                	add	a2,a2,a5
    8000583c:	85be                	mv	a1,a5
    8000583e:	855a                	mv	a0,s6
    80005840:	ffffc097          	auipc	ra,0xffffc
    80005844:	27e080e7          	jalr	638(ra) # 80001abe <uvmalloc>
    80005848:	8c2a                	mv	s8,a0
  ip = 0;
    8000584a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000584c:	12050e63          	beqz	a0,80005988 <exec+0x2e2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005850:	75f9                	lui	a1,0xffffe
    80005852:	95aa                	add	a1,a1,a0
    80005854:	855a                	mv	a0,s6
    80005856:	ffffc097          	auipc	ra,0xffffc
    8000585a:	af6080e7          	jalr	-1290(ra) # 8000134c <uvmclear>
  stackbase = sp - PGSIZE;
    8000585e:	7afd                	lui	s5,0xfffff
    80005860:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005862:	df043783          	ld	a5,-528(s0)
    80005866:	6388                	ld	a0,0(a5)
    80005868:	c925                	beqz	a0,800058d8 <exec+0x232>
    8000586a:	e8840993          	addi	s3,s0,-376
    8000586e:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005872:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005874:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005876:	ffffb097          	auipc	ra,0xffffb
    8000587a:	5cc080e7          	jalr	1484(ra) # 80000e42 <strlen>
    8000587e:	0015079b          	addiw	a5,a0,1
    80005882:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005886:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000588a:	13596363          	bltu	s2,s5,800059b0 <exec+0x30a>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000588e:	df043d83          	ld	s11,-528(s0)
    80005892:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005896:	8552                	mv	a0,s4
    80005898:	ffffb097          	auipc	ra,0xffffb
    8000589c:	5aa080e7          	jalr	1450(ra) # 80000e42 <strlen>
    800058a0:	0015069b          	addiw	a3,a0,1
    800058a4:	8652                	mv	a2,s4
    800058a6:	85ca                	mv	a1,s2
    800058a8:	855a                	mv	a0,s6
    800058aa:	ffffc097          	auipc	ra,0xffffc
    800058ae:	ad4080e7          	jalr	-1324(ra) # 8000137e <copyout>
    800058b2:	10054363          	bltz	a0,800059b8 <exec+0x312>
    ustack[argc] = sp;
    800058b6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800058ba:	0485                	addi	s1,s1,1
    800058bc:	008d8793          	addi	a5,s11,8
    800058c0:	def43823          	sd	a5,-528(s0)
    800058c4:	008db503          	ld	a0,8(s11)
    800058c8:	c911                	beqz	a0,800058dc <exec+0x236>
    if(argc >= MAXARG)
    800058ca:	09a1                	addi	s3,s3,8
    800058cc:	fb3c95e3          	bne	s9,s3,80005876 <exec+0x1d0>
  sz = sz1;
    800058d0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800058d4:	4a81                	li	s5,0
    800058d6:	a84d                	j	80005988 <exec+0x2e2>
  sp = sz;
    800058d8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800058da:	4481                	li	s1,0
  ustack[argc] = 0;
    800058dc:	00349793          	slli	a5,s1,0x3
    800058e0:	f9040713          	addi	a4,s0,-112
    800058e4:	97ba                	add	a5,a5,a4
    800058e6:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffc8ef8>
  sp -= (argc+1) * sizeof(uint64);
    800058ea:	00148693          	addi	a3,s1,1
    800058ee:	068e                	slli	a3,a3,0x3
    800058f0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800058f4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800058f8:	01597663          	bgeu	s2,s5,80005904 <exec+0x25e>
  sz = sz1;
    800058fc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005900:	4a81                	li	s5,0
    80005902:	a059                	j	80005988 <exec+0x2e2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005904:	e8840613          	addi	a2,s0,-376
    80005908:	85ca                	mv	a1,s2
    8000590a:	855a                	mv	a0,s6
    8000590c:	ffffc097          	auipc	ra,0xffffc
    80005910:	a72080e7          	jalr	-1422(ra) # 8000137e <copyout>
    80005914:	0a054663          	bltz	a0,800059c0 <exec+0x31a>
  p->trapframe->a1 = sp;
    80005918:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    8000591c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005920:	de843783          	ld	a5,-536(s0)
    80005924:	0007c703          	lbu	a4,0(a5)
    80005928:	cf11                	beqz	a4,80005944 <exec+0x29e>
    8000592a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000592c:	02f00693          	li	a3,47
    80005930:	a039                	j	8000593e <exec+0x298>
      last = s+1;
    80005932:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005936:	0785                	addi	a5,a5,1
    80005938:	fff7c703          	lbu	a4,-1(a5)
    8000593c:	c701                	beqz	a4,80005944 <exec+0x29e>
    if(*s == '/')
    8000593e:	fed71ce3          	bne	a4,a3,80005936 <exec+0x290>
    80005942:	bfc5                	j	80005932 <exec+0x28c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005944:	4641                	li	a2,16
    80005946:	de843583          	ld	a1,-536(s0)
    8000594a:	158b8513          	addi	a0,s7,344
    8000594e:	ffffb097          	auipc	ra,0xffffb
    80005952:	4c2080e7          	jalr	1218(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005956:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000595a:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000595e:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005962:	058bb783          	ld	a5,88(s7)
    80005966:	e6043703          	ld	a4,-416(s0)
    8000596a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000596c:	058bb783          	ld	a5,88(s7)
    80005970:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005974:	85ea                	mv	a1,s10
    80005976:	ffffc097          	auipc	ra,0xffffc
    8000597a:	68c080e7          	jalr	1676(ra) # 80002002 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000597e:	0004851b          	sext.w	a0,s1
    80005982:	bbc1                	j	80005752 <exec+0xac>
    80005984:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005988:	df843583          	ld	a1,-520(s0)
    8000598c:	855a                	mv	a0,s6
    8000598e:	ffffc097          	auipc	ra,0xffffc
    80005992:	674080e7          	jalr	1652(ra) # 80002002 <proc_freepagetable>
  if(ip){
    80005996:	da0a94e3          	bnez	s5,8000573e <exec+0x98>
  return -1;
    8000599a:	557d                	li	a0,-1
    8000599c:	bb5d                	j	80005752 <exec+0xac>
    8000599e:	de943c23          	sd	s1,-520(s0)
    800059a2:	b7dd                	j	80005988 <exec+0x2e2>
    800059a4:	de943c23          	sd	s1,-520(s0)
    800059a8:	b7c5                	j	80005988 <exec+0x2e2>
    800059aa:	de943c23          	sd	s1,-520(s0)
    800059ae:	bfe9                	j	80005988 <exec+0x2e2>
  sz = sz1;
    800059b0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800059b4:	4a81                	li	s5,0
    800059b6:	bfc9                	j	80005988 <exec+0x2e2>
  sz = sz1;
    800059b8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800059bc:	4a81                	li	s5,0
    800059be:	b7e9                	j	80005988 <exec+0x2e2>
  sz = sz1;
    800059c0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800059c4:	4a81                	li	s5,0
    800059c6:	b7c9                	j	80005988 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800059c8:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800059cc:	e0843783          	ld	a5,-504(s0)
    800059d0:	0017869b          	addiw	a3,a5,1
    800059d4:	e0d43423          	sd	a3,-504(s0)
    800059d8:	e0043783          	ld	a5,-512(s0)
    800059dc:	0387879b          	addiw	a5,a5,56
    800059e0:	e8045703          	lhu	a4,-384(s0)
    800059e4:	e2e6d3e3          	bge	a3,a4,8000580a <exec+0x164>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800059e8:	2781                	sext.w	a5,a5
    800059ea:	e0f43023          	sd	a5,-512(s0)
    800059ee:	03800713          	li	a4,56
    800059f2:	86be                	mv	a3,a5
    800059f4:	e1040613          	addi	a2,s0,-496
    800059f8:	4581                	li	a1,0
    800059fa:	8556                	mv	a0,s5
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	52c080e7          	jalr	1324(ra) # 80003f28 <readi>
    80005a04:	03800793          	li	a5,56
    80005a08:	f6f51ee3          	bne	a0,a5,80005984 <exec+0x2de>
    if(ph.type != ELF_PROG_LOAD)
    80005a0c:	e1042783          	lw	a5,-496(s0)
    80005a10:	4705                	li	a4,1
    80005a12:	fae79de3          	bne	a5,a4,800059cc <exec+0x326>
    if(ph.memsz < ph.filesz)
    80005a16:	e3843603          	ld	a2,-456(s0)
    80005a1a:	e3043783          	ld	a5,-464(s0)
    80005a1e:	f8f660e3          	bltu	a2,a5,8000599e <exec+0x2f8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005a22:	e2043783          	ld	a5,-480(s0)
    80005a26:	963e                	add	a2,a2,a5
    80005a28:	f6f66ee3          	bltu	a2,a5,800059a4 <exec+0x2fe>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005a2c:	85a6                	mv	a1,s1
    80005a2e:	855a                	mv	a0,s6
    80005a30:	ffffc097          	auipc	ra,0xffffc
    80005a34:	08e080e7          	jalr	142(ra) # 80001abe <uvmalloc>
    80005a38:	dea43c23          	sd	a0,-520(s0)
    80005a3c:	d53d                	beqz	a0,800059aa <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    80005a3e:	e2043c03          	ld	s8,-480(s0)
    80005a42:	de043783          	ld	a5,-544(s0)
    80005a46:	00fc77b3          	and	a5,s8,a5
    80005a4a:	ff9d                	bnez	a5,80005988 <exec+0x2e2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005a4c:	e1842c83          	lw	s9,-488(s0)
    80005a50:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005a54:	f60b8ae3          	beqz	s7,800059c8 <exec+0x322>
    80005a58:	89de                	mv	s3,s7
    80005a5a:	4481                	li	s1,0
    80005a5c:	b371                	j	800057e8 <exec+0x142>

0000000080005a5e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005a5e:	7179                	addi	sp,sp,-48
    80005a60:	f406                	sd	ra,40(sp)
    80005a62:	f022                	sd	s0,32(sp)
    80005a64:	ec26                	sd	s1,24(sp)
    80005a66:	e84a                	sd	s2,16(sp)
    80005a68:	1800                	addi	s0,sp,48
    80005a6a:	892e                	mv	s2,a1
    80005a6c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005a6e:	fdc40593          	addi	a1,s0,-36
    80005a72:	ffffd097          	auipc	ra,0xffffd
    80005a76:	676080e7          	jalr	1654(ra) # 800030e8 <argint>
    80005a7a:	04054063          	bltz	a0,80005aba <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005a7e:	fdc42703          	lw	a4,-36(s0)
    80005a82:	47bd                	li	a5,15
    80005a84:	02e7ed63          	bltu	a5,a4,80005abe <argfd+0x60>
    80005a88:	ffffc097          	auipc	ra,0xffffc
    80005a8c:	3de080e7          	jalr	990(ra) # 80001e66 <myproc>
    80005a90:	fdc42703          	lw	a4,-36(s0)
    80005a94:	01a70793          	addi	a5,a4,26
    80005a98:	078e                	slli	a5,a5,0x3
    80005a9a:	953e                	add	a0,a0,a5
    80005a9c:	611c                	ld	a5,0(a0)
    80005a9e:	c395                	beqz	a5,80005ac2 <argfd+0x64>
    return -1;
  if(pfd)
    80005aa0:	00090463          	beqz	s2,80005aa8 <argfd+0x4a>
    *pfd = fd;
    80005aa4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005aa8:	4501                	li	a0,0
  if(pf)
    80005aaa:	c091                	beqz	s1,80005aae <argfd+0x50>
    *pf = f;
    80005aac:	e09c                	sd	a5,0(s1)
}
    80005aae:	70a2                	ld	ra,40(sp)
    80005ab0:	7402                	ld	s0,32(sp)
    80005ab2:	64e2                	ld	s1,24(sp)
    80005ab4:	6942                	ld	s2,16(sp)
    80005ab6:	6145                	addi	sp,sp,48
    80005ab8:	8082                	ret
    return -1;
    80005aba:	557d                	li	a0,-1
    80005abc:	bfcd                	j	80005aae <argfd+0x50>
    return -1;
    80005abe:	557d                	li	a0,-1
    80005ac0:	b7fd                	j	80005aae <argfd+0x50>
    80005ac2:	557d                	li	a0,-1
    80005ac4:	b7ed                	j	80005aae <argfd+0x50>

0000000080005ac6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005ac6:	1101                	addi	sp,sp,-32
    80005ac8:	ec06                	sd	ra,24(sp)
    80005aca:	e822                	sd	s0,16(sp)
    80005acc:	e426                	sd	s1,8(sp)
    80005ace:	1000                	addi	s0,sp,32
    80005ad0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005ad2:	ffffc097          	auipc	ra,0xffffc
    80005ad6:	394080e7          	jalr	916(ra) # 80001e66 <myproc>
    80005ada:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005adc:	0d050793          	addi	a5,a0,208
    80005ae0:	4501                	li	a0,0
    80005ae2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005ae4:	6398                	ld	a4,0(a5)
    80005ae6:	cb19                	beqz	a4,80005afc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005ae8:	2505                	addiw	a0,a0,1
    80005aea:	07a1                	addi	a5,a5,8
    80005aec:	fed51ce3          	bne	a0,a3,80005ae4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005af0:	557d                	li	a0,-1
}
    80005af2:	60e2                	ld	ra,24(sp)
    80005af4:	6442                	ld	s0,16(sp)
    80005af6:	64a2                	ld	s1,8(sp)
    80005af8:	6105                	addi	sp,sp,32
    80005afa:	8082                	ret
      p->ofile[fd] = f;
    80005afc:	01a50793          	addi	a5,a0,26
    80005b00:	078e                	slli	a5,a5,0x3
    80005b02:	963e                	add	a2,a2,a5
    80005b04:	e204                	sd	s1,0(a2)
      return fd;
    80005b06:	b7f5                	j	80005af2 <fdalloc+0x2c>

0000000080005b08 <sys_dup>:

uint64
sys_dup(void)
{
    80005b08:	7179                	addi	sp,sp,-48
    80005b0a:	f406                	sd	ra,40(sp)
    80005b0c:	f022                	sd	s0,32(sp)
    80005b0e:	ec26                	sd	s1,24(sp)
    80005b10:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005b12:	fd840613          	addi	a2,s0,-40
    80005b16:	4581                	li	a1,0
    80005b18:	4501                	li	a0,0
    80005b1a:	00000097          	auipc	ra,0x0
    80005b1e:	f44080e7          	jalr	-188(ra) # 80005a5e <argfd>
    return -1;
    80005b22:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005b24:	02054363          	bltz	a0,80005b4a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005b28:	fd843503          	ld	a0,-40(s0)
    80005b2c:	00000097          	auipc	ra,0x0
    80005b30:	f9a080e7          	jalr	-102(ra) # 80005ac6 <fdalloc>
    80005b34:	84aa                	mv	s1,a0
    return -1;
    80005b36:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005b38:	00054963          	bltz	a0,80005b4a <sys_dup+0x42>
  filedup(f);
    80005b3c:	fd843503          	ld	a0,-40(s0)
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	2cc080e7          	jalr	716(ra) # 80004e0c <filedup>
  return fd;
    80005b48:	87a6                	mv	a5,s1
}
    80005b4a:	853e                	mv	a0,a5
    80005b4c:	70a2                	ld	ra,40(sp)
    80005b4e:	7402                	ld	s0,32(sp)
    80005b50:	64e2                	ld	s1,24(sp)
    80005b52:	6145                	addi	sp,sp,48
    80005b54:	8082                	ret

0000000080005b56 <sys_read>:

uint64
sys_read(void)
{
    80005b56:	7179                	addi	sp,sp,-48
    80005b58:	f406                	sd	ra,40(sp)
    80005b5a:	f022                	sd	s0,32(sp)
    80005b5c:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b5e:	fe840613          	addi	a2,s0,-24
    80005b62:	4581                	li	a1,0
    80005b64:	4501                	li	a0,0
    80005b66:	00000097          	auipc	ra,0x0
    80005b6a:	ef8080e7          	jalr	-264(ra) # 80005a5e <argfd>
    return -1;
    80005b6e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b70:	04054163          	bltz	a0,80005bb2 <sys_read+0x5c>
    80005b74:	fe440593          	addi	a1,s0,-28
    80005b78:	4509                	li	a0,2
    80005b7a:	ffffd097          	auipc	ra,0xffffd
    80005b7e:	56e080e7          	jalr	1390(ra) # 800030e8 <argint>
    return -1;
    80005b82:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b84:	02054763          	bltz	a0,80005bb2 <sys_read+0x5c>
    80005b88:	fd840593          	addi	a1,s0,-40
    80005b8c:	4505                	li	a0,1
    80005b8e:	ffffd097          	auipc	ra,0xffffd
    80005b92:	57c080e7          	jalr	1404(ra) # 8000310a <argaddr>
    return -1;
    80005b96:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b98:	00054d63          	bltz	a0,80005bb2 <sys_read+0x5c>
  return fileread(f, p, n);
    80005b9c:	fe442603          	lw	a2,-28(s0)
    80005ba0:	fd843583          	ld	a1,-40(s0)
    80005ba4:	fe843503          	ld	a0,-24(s0)
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	3f0080e7          	jalr	1008(ra) # 80004f98 <fileread>
    80005bb0:	87aa                	mv	a5,a0
}
    80005bb2:	853e                	mv	a0,a5
    80005bb4:	70a2                	ld	ra,40(sp)
    80005bb6:	7402                	ld	s0,32(sp)
    80005bb8:	6145                	addi	sp,sp,48
    80005bba:	8082                	ret

0000000080005bbc <sys_write>:

uint64
sys_write(void)
{
    80005bbc:	7179                	addi	sp,sp,-48
    80005bbe:	f406                	sd	ra,40(sp)
    80005bc0:	f022                	sd	s0,32(sp)
    80005bc2:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005bc4:	fe840613          	addi	a2,s0,-24
    80005bc8:	4581                	li	a1,0
    80005bca:	4501                	li	a0,0
    80005bcc:	00000097          	auipc	ra,0x0
    80005bd0:	e92080e7          	jalr	-366(ra) # 80005a5e <argfd>
    return -1;
    80005bd4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005bd6:	04054163          	bltz	a0,80005c18 <sys_write+0x5c>
    80005bda:	fe440593          	addi	a1,s0,-28
    80005bde:	4509                	li	a0,2
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	508080e7          	jalr	1288(ra) # 800030e8 <argint>
    return -1;
    80005be8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005bea:	02054763          	bltz	a0,80005c18 <sys_write+0x5c>
    80005bee:	fd840593          	addi	a1,s0,-40
    80005bf2:	4505                	li	a0,1
    80005bf4:	ffffd097          	auipc	ra,0xffffd
    80005bf8:	516080e7          	jalr	1302(ra) # 8000310a <argaddr>
    return -1;
    80005bfc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005bfe:	00054d63          	bltz	a0,80005c18 <sys_write+0x5c>

  return filewrite(f, p, n);
    80005c02:	fe442603          	lw	a2,-28(s0)
    80005c06:	fd843583          	ld	a1,-40(s0)
    80005c0a:	fe843503          	ld	a0,-24(s0)
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	44c080e7          	jalr	1100(ra) # 8000505a <filewrite>
    80005c16:	87aa                	mv	a5,a0
}
    80005c18:	853e                	mv	a0,a5
    80005c1a:	70a2                	ld	ra,40(sp)
    80005c1c:	7402                	ld	s0,32(sp)
    80005c1e:	6145                	addi	sp,sp,48
    80005c20:	8082                	ret

0000000080005c22 <sys_close>:

uint64
sys_close(void)
{
    80005c22:	1101                	addi	sp,sp,-32
    80005c24:	ec06                	sd	ra,24(sp)
    80005c26:	e822                	sd	s0,16(sp)
    80005c28:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005c2a:	fe040613          	addi	a2,s0,-32
    80005c2e:	fec40593          	addi	a1,s0,-20
    80005c32:	4501                	li	a0,0
    80005c34:	00000097          	auipc	ra,0x0
    80005c38:	e2a080e7          	jalr	-470(ra) # 80005a5e <argfd>
    return -1;
    80005c3c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005c3e:	02054463          	bltz	a0,80005c66 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005c42:	ffffc097          	auipc	ra,0xffffc
    80005c46:	224080e7          	jalr	548(ra) # 80001e66 <myproc>
    80005c4a:	fec42783          	lw	a5,-20(s0)
    80005c4e:	07e9                	addi	a5,a5,26
    80005c50:	078e                	slli	a5,a5,0x3
    80005c52:	97aa                	add	a5,a5,a0
    80005c54:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005c58:	fe043503          	ld	a0,-32(s0)
    80005c5c:	fffff097          	auipc	ra,0xfffff
    80005c60:	202080e7          	jalr	514(ra) # 80004e5e <fileclose>
  return 0;
    80005c64:	4781                	li	a5,0
}
    80005c66:	853e                	mv	a0,a5
    80005c68:	60e2                	ld	ra,24(sp)
    80005c6a:	6442                	ld	s0,16(sp)
    80005c6c:	6105                	addi	sp,sp,32
    80005c6e:	8082                	ret

0000000080005c70 <sys_fstat>:

uint64
sys_fstat(void)
{
    80005c70:	1101                	addi	sp,sp,-32
    80005c72:	ec06                	sd	ra,24(sp)
    80005c74:	e822                	sd	s0,16(sp)
    80005c76:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005c78:	fe840613          	addi	a2,s0,-24
    80005c7c:	4581                	li	a1,0
    80005c7e:	4501                	li	a0,0
    80005c80:	00000097          	auipc	ra,0x0
    80005c84:	dde080e7          	jalr	-546(ra) # 80005a5e <argfd>
    return -1;
    80005c88:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005c8a:	02054563          	bltz	a0,80005cb4 <sys_fstat+0x44>
    80005c8e:	fe040593          	addi	a1,s0,-32
    80005c92:	4505                	li	a0,1
    80005c94:	ffffd097          	auipc	ra,0xffffd
    80005c98:	476080e7          	jalr	1142(ra) # 8000310a <argaddr>
    return -1;
    80005c9c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005c9e:	00054b63          	bltz	a0,80005cb4 <sys_fstat+0x44>
  return filestat(f, st);
    80005ca2:	fe043583          	ld	a1,-32(s0)
    80005ca6:	fe843503          	ld	a0,-24(s0)
    80005caa:	fffff097          	auipc	ra,0xfffff
    80005cae:	27c080e7          	jalr	636(ra) # 80004f26 <filestat>
    80005cb2:	87aa                	mv	a5,a0
}
    80005cb4:	853e                	mv	a0,a5
    80005cb6:	60e2                	ld	ra,24(sp)
    80005cb8:	6442                	ld	s0,16(sp)
    80005cba:	6105                	addi	sp,sp,32
    80005cbc:	8082                	ret

0000000080005cbe <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80005cbe:	7169                	addi	sp,sp,-304
    80005cc0:	f606                	sd	ra,296(sp)
    80005cc2:	f222                	sd	s0,288(sp)
    80005cc4:	ee26                	sd	s1,280(sp)
    80005cc6:	ea4a                	sd	s2,272(sp)
    80005cc8:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cca:	08000613          	li	a2,128
    80005cce:	ed040593          	addi	a1,s0,-304
    80005cd2:	4501                	li	a0,0
    80005cd4:	ffffd097          	auipc	ra,0xffffd
    80005cd8:	458080e7          	jalr	1112(ra) # 8000312c <argstr>
    return -1;
    80005cdc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cde:	10054e63          	bltz	a0,80005dfa <sys_link+0x13c>
    80005ce2:	08000613          	li	a2,128
    80005ce6:	f5040593          	addi	a1,s0,-176
    80005cea:	4505                	li	a0,1
    80005cec:	ffffd097          	auipc	ra,0xffffd
    80005cf0:	440080e7          	jalr	1088(ra) # 8000312c <argstr>
    return -1;
    80005cf4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cf6:	10054263          	bltz	a0,80005dfa <sys_link+0x13c>

  begin_op();
    80005cfa:	fffff097          	auipc	ra,0xfffff
    80005cfe:	c98080e7          	jalr	-872(ra) # 80004992 <begin_op>
  if((ip = namei(old)) == 0){
    80005d02:	ed040513          	addi	a0,s0,-304
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	724080e7          	jalr	1828(ra) # 8000442a <namei>
    80005d0e:	84aa                	mv	s1,a0
    80005d10:	c551                	beqz	a0,80005d9c <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    80005d12:	ffffe097          	auipc	ra,0xffffe
    80005d16:	f62080e7          	jalr	-158(ra) # 80003c74 <ilock>
  if(ip->type == T_DIR){
    80005d1a:	04449703          	lh	a4,68(s1)
    80005d1e:	4785                	li	a5,1
    80005d20:	08f70463          	beq	a4,a5,80005da8 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80005d24:	04a4d783          	lhu	a5,74(s1)
    80005d28:	2785                	addiw	a5,a5,1
    80005d2a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d2e:	8526                	mv	a0,s1
    80005d30:	ffffe097          	auipc	ra,0xffffe
    80005d34:	e7a080e7          	jalr	-390(ra) # 80003baa <iupdate>
  iunlock(ip);
    80005d38:	8526                	mv	a0,s1
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	ffc080e7          	jalr	-4(ra) # 80003d36 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    80005d42:	fd040593          	addi	a1,s0,-48
    80005d46:	f5040513          	addi	a0,s0,-176
    80005d4a:	ffffe097          	auipc	ra,0xffffe
    80005d4e:	6fe080e7          	jalr	1790(ra) # 80004448 <nameiparent>
    80005d52:	892a                	mv	s2,a0
    80005d54:	c935                	beqz	a0,80005dc8 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80005d56:	ffffe097          	auipc	ra,0xffffe
    80005d5a:	f1e080e7          	jalr	-226(ra) # 80003c74 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005d5e:	00092703          	lw	a4,0(s2)
    80005d62:	409c                	lw	a5,0(s1)
    80005d64:	04f71d63          	bne	a4,a5,80005dbe <sys_link+0x100>
    80005d68:	40d0                	lw	a2,4(s1)
    80005d6a:	fd040593          	addi	a1,s0,-48
    80005d6e:	854a                	mv	a0,s2
    80005d70:	ffffe097          	auipc	ra,0xffffe
    80005d74:	5f8080e7          	jalr	1528(ra) # 80004368 <dirlink>
    80005d78:	04054363          	bltz	a0,80005dbe <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    80005d7c:	854a                	mv	a0,s2
    80005d7e:	ffffe097          	auipc	ra,0xffffe
    80005d82:	158080e7          	jalr	344(ra) # 80003ed6 <iunlockput>
  iput(ip);
    80005d86:	8526                	mv	a0,s1
    80005d88:	ffffe097          	auipc	ra,0xffffe
    80005d8c:	0a6080e7          	jalr	166(ra) # 80003e2e <iput>

  end_op();
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	c82080e7          	jalr	-894(ra) # 80004a12 <end_op>

  return 0;
    80005d98:	4781                	li	a5,0
    80005d9a:	a085                	j	80005dfa <sys_link+0x13c>
    end_op();
    80005d9c:	fffff097          	auipc	ra,0xfffff
    80005da0:	c76080e7          	jalr	-906(ra) # 80004a12 <end_op>
    return -1;
    80005da4:	57fd                	li	a5,-1
    80005da6:	a891                	j	80005dfa <sys_link+0x13c>
    iunlockput(ip);
    80005da8:	8526                	mv	a0,s1
    80005daa:	ffffe097          	auipc	ra,0xffffe
    80005dae:	12c080e7          	jalr	300(ra) # 80003ed6 <iunlockput>
    end_op();
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	c60080e7          	jalr	-928(ra) # 80004a12 <end_op>
    return -1;
    80005dba:	57fd                	li	a5,-1
    80005dbc:	a83d                	j	80005dfa <sys_link+0x13c>
    iunlockput(dp);
    80005dbe:	854a                	mv	a0,s2
    80005dc0:	ffffe097          	auipc	ra,0xffffe
    80005dc4:	116080e7          	jalr	278(ra) # 80003ed6 <iunlockput>

bad:
  ilock(ip);
    80005dc8:	8526                	mv	a0,s1
    80005dca:	ffffe097          	auipc	ra,0xffffe
    80005dce:	eaa080e7          	jalr	-342(ra) # 80003c74 <ilock>
  ip->nlink--;
    80005dd2:	04a4d783          	lhu	a5,74(s1)
    80005dd6:	37fd                	addiw	a5,a5,-1
    80005dd8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ddc:	8526                	mv	a0,s1
    80005dde:	ffffe097          	auipc	ra,0xffffe
    80005de2:	dcc080e7          	jalr	-564(ra) # 80003baa <iupdate>
  iunlockput(ip);
    80005de6:	8526                	mv	a0,s1
    80005de8:	ffffe097          	auipc	ra,0xffffe
    80005dec:	0ee080e7          	jalr	238(ra) # 80003ed6 <iunlockput>
  end_op();
    80005df0:	fffff097          	auipc	ra,0xfffff
    80005df4:	c22080e7          	jalr	-990(ra) # 80004a12 <end_op>
  return -1;
    80005df8:	57fd                	li	a5,-1
}
    80005dfa:	853e                	mv	a0,a5
    80005dfc:	70b2                	ld	ra,296(sp)
    80005dfe:	7412                	ld	s0,288(sp)
    80005e00:	64f2                	ld	s1,280(sp)
    80005e02:	6952                	ld	s2,272(sp)
    80005e04:	6155                	addi	sp,sp,304
    80005e06:	8082                	ret

0000000080005e08 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e08:	4578                	lw	a4,76(a0)
    80005e0a:	02000793          	li	a5,32
    80005e0e:	04e7fa63          	bgeu	a5,a4,80005e62 <isdirempty+0x5a>
{
    80005e12:	7179                	addi	sp,sp,-48
    80005e14:	f406                	sd	ra,40(sp)
    80005e16:	f022                	sd	s0,32(sp)
    80005e18:	ec26                	sd	s1,24(sp)
    80005e1a:	e84a                	sd	s2,16(sp)
    80005e1c:	1800                	addi	s0,sp,48
    80005e1e:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e20:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e24:	4741                	li	a4,16
    80005e26:	86a6                	mv	a3,s1
    80005e28:	fd040613          	addi	a2,s0,-48
    80005e2c:	4581                	li	a1,0
    80005e2e:	854a                	mv	a0,s2
    80005e30:	ffffe097          	auipc	ra,0xffffe
    80005e34:	0f8080e7          	jalr	248(ra) # 80003f28 <readi>
    80005e38:	47c1                	li	a5,16
    80005e3a:	00f51c63          	bne	a0,a5,80005e52 <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    80005e3e:	fd045783          	lhu	a5,-48(s0)
    80005e42:	e395                	bnez	a5,80005e66 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e44:	24c1                	addiw	s1,s1,16
    80005e46:	04c92783          	lw	a5,76(s2)
    80005e4a:	fcf4ede3          	bltu	s1,a5,80005e24 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    80005e4e:	4505                	li	a0,1
    80005e50:	a821                	j	80005e68 <isdirempty+0x60>
      panic("isdirempty: readi");
    80005e52:	00003517          	auipc	a0,0x3
    80005e56:	9fe50513          	addi	a0,a0,-1538 # 80008850 <syscalls+0x350>
    80005e5a:	ffffa097          	auipc	ra,0xffffa
    80005e5e:	6d0080e7          	jalr	1744(ra) # 8000052a <panic>
  return 1;
    80005e62:	4505                	li	a0,1
}
    80005e64:	8082                	ret
      return 0;
    80005e66:	4501                	li	a0,0
}
    80005e68:	70a2                	ld	ra,40(sp)
    80005e6a:	7402                	ld	s0,32(sp)
    80005e6c:	64e2                	ld	s1,24(sp)
    80005e6e:	6942                	ld	s2,16(sp)
    80005e70:	6145                	addi	sp,sp,48
    80005e72:	8082                	ret

0000000080005e74 <sys_unlink>:

uint64
sys_unlink(void)
{
    80005e74:	7155                	addi	sp,sp,-208
    80005e76:	e586                	sd	ra,200(sp)
    80005e78:	e1a2                	sd	s0,192(sp)
    80005e7a:	fd26                	sd	s1,184(sp)
    80005e7c:	f94a                	sd	s2,176(sp)
    80005e7e:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    80005e80:	08000613          	li	a2,128
    80005e84:	f4040593          	addi	a1,s0,-192
    80005e88:	4501                	li	a0,0
    80005e8a:	ffffd097          	auipc	ra,0xffffd
    80005e8e:	2a2080e7          	jalr	674(ra) # 8000312c <argstr>
    80005e92:	16054363          	bltz	a0,80005ff8 <sys_unlink+0x184>
    return -1;

  begin_op();
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	afc080e7          	jalr	-1284(ra) # 80004992 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005e9e:	fc040593          	addi	a1,s0,-64
    80005ea2:	f4040513          	addi	a0,s0,-192
    80005ea6:	ffffe097          	auipc	ra,0xffffe
    80005eaa:	5a2080e7          	jalr	1442(ra) # 80004448 <nameiparent>
    80005eae:	84aa                	mv	s1,a0
    80005eb0:	c961                	beqz	a0,80005f80 <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    80005eb2:	ffffe097          	auipc	ra,0xffffe
    80005eb6:	dc2080e7          	jalr	-574(ra) # 80003c74 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005eba:	00003597          	auipc	a1,0x3
    80005ebe:	83e58593          	addi	a1,a1,-1986 # 800086f8 <syscalls+0x1f8>
    80005ec2:	fc040513          	addi	a0,s0,-64
    80005ec6:	ffffe097          	auipc	ra,0xffffe
    80005eca:	278080e7          	jalr	632(ra) # 8000413e <namecmp>
    80005ece:	c175                	beqz	a0,80005fb2 <sys_unlink+0x13e>
    80005ed0:	00003597          	auipc	a1,0x3
    80005ed4:	83058593          	addi	a1,a1,-2000 # 80008700 <syscalls+0x200>
    80005ed8:	fc040513          	addi	a0,s0,-64
    80005edc:	ffffe097          	auipc	ra,0xffffe
    80005ee0:	262080e7          	jalr	610(ra) # 8000413e <namecmp>
    80005ee4:	c579                	beqz	a0,80005fb2 <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80005ee6:	f3c40613          	addi	a2,s0,-196
    80005eea:	fc040593          	addi	a1,s0,-64
    80005eee:	8526                	mv	a0,s1
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	268080e7          	jalr	616(ra) # 80004158 <dirlookup>
    80005ef8:	892a                	mv	s2,a0
    80005efa:	cd45                	beqz	a0,80005fb2 <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    80005efc:	ffffe097          	auipc	ra,0xffffe
    80005f00:	d78080e7          	jalr	-648(ra) # 80003c74 <ilock>

  if(ip->nlink < 1)
    80005f04:	04a91783          	lh	a5,74(s2)
    80005f08:	08f05263          	blez	a5,80005f8c <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005f0c:	04491703          	lh	a4,68(s2)
    80005f10:	4785                	li	a5,1
    80005f12:	08f70563          	beq	a4,a5,80005f9c <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80005f16:	4641                	li	a2,16
    80005f18:	4581                	li	a1,0
    80005f1a:	fd040513          	addi	a0,s0,-48
    80005f1e:	ffffb097          	auipc	ra,0xffffb
    80005f22:	da0080e7          	jalr	-608(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f26:	4741                	li	a4,16
    80005f28:	f3c42683          	lw	a3,-196(s0)
    80005f2c:	fd040613          	addi	a2,s0,-48
    80005f30:	4581                	li	a1,0
    80005f32:	8526                	mv	a0,s1
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	0ec080e7          	jalr	236(ra) # 80004020 <writei>
    80005f3c:	47c1                	li	a5,16
    80005f3e:	08f51a63          	bne	a0,a5,80005fd2 <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80005f42:	04491703          	lh	a4,68(s2)
    80005f46:	4785                	li	a5,1
    80005f48:	08f70d63          	beq	a4,a5,80005fe2 <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80005f4c:	8526                	mv	a0,s1
    80005f4e:	ffffe097          	auipc	ra,0xffffe
    80005f52:	f88080e7          	jalr	-120(ra) # 80003ed6 <iunlockput>

  ip->nlink--;
    80005f56:	04a95783          	lhu	a5,74(s2)
    80005f5a:	37fd                	addiw	a5,a5,-1
    80005f5c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005f60:	854a                	mv	a0,s2
    80005f62:	ffffe097          	auipc	ra,0xffffe
    80005f66:	c48080e7          	jalr	-952(ra) # 80003baa <iupdate>
  iunlockput(ip);
    80005f6a:	854a                	mv	a0,s2
    80005f6c:	ffffe097          	auipc	ra,0xffffe
    80005f70:	f6a080e7          	jalr	-150(ra) # 80003ed6 <iunlockput>

  end_op();
    80005f74:	fffff097          	auipc	ra,0xfffff
    80005f78:	a9e080e7          	jalr	-1378(ra) # 80004a12 <end_op>

  return 0;
    80005f7c:	4501                	li	a0,0
    80005f7e:	a0a1                	j	80005fc6 <sys_unlink+0x152>
    end_op();
    80005f80:	fffff097          	auipc	ra,0xfffff
    80005f84:	a92080e7          	jalr	-1390(ra) # 80004a12 <end_op>
    return -1;
    80005f88:	557d                	li	a0,-1
    80005f8a:	a835                	j	80005fc6 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    80005f8c:	00002517          	auipc	a0,0x2
    80005f90:	77c50513          	addi	a0,a0,1916 # 80008708 <syscalls+0x208>
    80005f94:	ffffa097          	auipc	ra,0xffffa
    80005f98:	596080e7          	jalr	1430(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005f9c:	854a                	mv	a0,s2
    80005f9e:	00000097          	auipc	ra,0x0
    80005fa2:	e6a080e7          	jalr	-406(ra) # 80005e08 <isdirempty>
    80005fa6:	f925                	bnez	a0,80005f16 <sys_unlink+0xa2>
    iunlockput(ip);
    80005fa8:	854a                	mv	a0,s2
    80005faa:	ffffe097          	auipc	ra,0xffffe
    80005fae:	f2c080e7          	jalr	-212(ra) # 80003ed6 <iunlockput>

bad:
  iunlockput(dp);
    80005fb2:	8526                	mv	a0,s1
    80005fb4:	ffffe097          	auipc	ra,0xffffe
    80005fb8:	f22080e7          	jalr	-222(ra) # 80003ed6 <iunlockput>
  end_op();
    80005fbc:	fffff097          	auipc	ra,0xfffff
    80005fc0:	a56080e7          	jalr	-1450(ra) # 80004a12 <end_op>
  return -1;
    80005fc4:	557d                	li	a0,-1
}
    80005fc6:	60ae                	ld	ra,200(sp)
    80005fc8:	640e                	ld	s0,192(sp)
    80005fca:	74ea                	ld	s1,184(sp)
    80005fcc:	794a                	ld	s2,176(sp)
    80005fce:	6169                	addi	sp,sp,208
    80005fd0:	8082                	ret
    panic("unlink: writei");
    80005fd2:	00002517          	auipc	a0,0x2
    80005fd6:	74e50513          	addi	a0,a0,1870 # 80008720 <syscalls+0x220>
    80005fda:	ffffa097          	auipc	ra,0xffffa
    80005fde:	550080e7          	jalr	1360(ra) # 8000052a <panic>
    dp->nlink--;
    80005fe2:	04a4d783          	lhu	a5,74(s1)
    80005fe6:	37fd                	addiw	a5,a5,-1
    80005fe8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005fec:	8526                	mv	a0,s1
    80005fee:	ffffe097          	auipc	ra,0xffffe
    80005ff2:	bbc080e7          	jalr	-1092(ra) # 80003baa <iupdate>
    80005ff6:	bf99                	j	80005f4c <sys_unlink+0xd8>
    return -1;
    80005ff8:	557d                	li	a0,-1
    80005ffa:	b7f1                	j	80005fc6 <sys_unlink+0x152>

0000000080005ffc <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    80005ffc:	715d                	addi	sp,sp,-80
    80005ffe:	e486                	sd	ra,72(sp)
    80006000:	e0a2                	sd	s0,64(sp)
    80006002:	fc26                	sd	s1,56(sp)
    80006004:	f84a                	sd	s2,48(sp)
    80006006:	f44e                	sd	s3,40(sp)
    80006008:	f052                	sd	s4,32(sp)
    8000600a:	ec56                	sd	s5,24(sp)
    8000600c:	0880                	addi	s0,sp,80
    8000600e:	89ae                	mv	s3,a1
    80006010:	8ab2                	mv	s5,a2
    80006012:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006014:	fb040593          	addi	a1,s0,-80
    80006018:	ffffe097          	auipc	ra,0xffffe
    8000601c:	430080e7          	jalr	1072(ra) # 80004448 <nameiparent>
    80006020:	892a                	mv	s2,a0
    80006022:	12050e63          	beqz	a0,8000615e <create+0x162>
    return 0;

  ilock(dp);
    80006026:	ffffe097          	auipc	ra,0xffffe
    8000602a:	c4e080e7          	jalr	-946(ra) # 80003c74 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000602e:	4601                	li	a2,0
    80006030:	fb040593          	addi	a1,s0,-80
    80006034:	854a                	mv	a0,s2
    80006036:	ffffe097          	auipc	ra,0xffffe
    8000603a:	122080e7          	jalr	290(ra) # 80004158 <dirlookup>
    8000603e:	84aa                	mv	s1,a0
    80006040:	c921                	beqz	a0,80006090 <create+0x94>
    iunlockput(dp);
    80006042:	854a                	mv	a0,s2
    80006044:	ffffe097          	auipc	ra,0xffffe
    80006048:	e92080e7          	jalr	-366(ra) # 80003ed6 <iunlockput>
    ilock(ip);
    8000604c:	8526                	mv	a0,s1
    8000604e:	ffffe097          	auipc	ra,0xffffe
    80006052:	c26080e7          	jalr	-986(ra) # 80003c74 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006056:	2981                	sext.w	s3,s3
    80006058:	4789                	li	a5,2
    8000605a:	02f99463          	bne	s3,a5,80006082 <create+0x86>
    8000605e:	0444d783          	lhu	a5,68(s1)
    80006062:	37f9                	addiw	a5,a5,-2
    80006064:	17c2                	slli	a5,a5,0x30
    80006066:	93c1                	srli	a5,a5,0x30
    80006068:	4705                	li	a4,1
    8000606a:	00f76c63          	bltu	a4,a5,80006082 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000606e:	8526                	mv	a0,s1
    80006070:	60a6                	ld	ra,72(sp)
    80006072:	6406                	ld	s0,64(sp)
    80006074:	74e2                	ld	s1,56(sp)
    80006076:	7942                	ld	s2,48(sp)
    80006078:	79a2                	ld	s3,40(sp)
    8000607a:	7a02                	ld	s4,32(sp)
    8000607c:	6ae2                	ld	s5,24(sp)
    8000607e:	6161                	addi	sp,sp,80
    80006080:	8082                	ret
    iunlockput(ip);
    80006082:	8526                	mv	a0,s1
    80006084:	ffffe097          	auipc	ra,0xffffe
    80006088:	e52080e7          	jalr	-430(ra) # 80003ed6 <iunlockput>
    return 0;
    8000608c:	4481                	li	s1,0
    8000608e:	b7c5                	j	8000606e <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006090:	85ce                	mv	a1,s3
    80006092:	00092503          	lw	a0,0(s2)
    80006096:	ffffe097          	auipc	ra,0xffffe
    8000609a:	a46080e7          	jalr	-1466(ra) # 80003adc <ialloc>
    8000609e:	84aa                	mv	s1,a0
    800060a0:	c521                	beqz	a0,800060e8 <create+0xec>
  ilock(ip);
    800060a2:	ffffe097          	auipc	ra,0xffffe
    800060a6:	bd2080e7          	jalr	-1070(ra) # 80003c74 <ilock>
  ip->major = major;
    800060aa:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800060ae:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800060b2:	4a05                	li	s4,1
    800060b4:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800060b8:	8526                	mv	a0,s1
    800060ba:	ffffe097          	auipc	ra,0xffffe
    800060be:	af0080e7          	jalr	-1296(ra) # 80003baa <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800060c2:	2981                	sext.w	s3,s3
    800060c4:	03498a63          	beq	s3,s4,800060f8 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800060c8:	40d0                	lw	a2,4(s1)
    800060ca:	fb040593          	addi	a1,s0,-80
    800060ce:	854a                	mv	a0,s2
    800060d0:	ffffe097          	auipc	ra,0xffffe
    800060d4:	298080e7          	jalr	664(ra) # 80004368 <dirlink>
    800060d8:	06054b63          	bltz	a0,8000614e <create+0x152>
  iunlockput(dp);
    800060dc:	854a                	mv	a0,s2
    800060de:	ffffe097          	auipc	ra,0xffffe
    800060e2:	df8080e7          	jalr	-520(ra) # 80003ed6 <iunlockput>
  return ip;
    800060e6:	b761                	j	8000606e <create+0x72>
    panic("create: ialloc");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	78050513          	addi	a0,a0,1920 # 80008868 <syscalls+0x368>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	43a080e7          	jalr	1082(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800060f8:	04a95783          	lhu	a5,74(s2)
    800060fc:	2785                	addiw	a5,a5,1
    800060fe:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006102:	854a                	mv	a0,s2
    80006104:	ffffe097          	auipc	ra,0xffffe
    80006108:	aa6080e7          	jalr	-1370(ra) # 80003baa <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000610c:	40d0                	lw	a2,4(s1)
    8000610e:	00002597          	auipc	a1,0x2
    80006112:	5ea58593          	addi	a1,a1,1514 # 800086f8 <syscalls+0x1f8>
    80006116:	8526                	mv	a0,s1
    80006118:	ffffe097          	auipc	ra,0xffffe
    8000611c:	250080e7          	jalr	592(ra) # 80004368 <dirlink>
    80006120:	00054f63          	bltz	a0,8000613e <create+0x142>
    80006124:	00492603          	lw	a2,4(s2)
    80006128:	00002597          	auipc	a1,0x2
    8000612c:	5d858593          	addi	a1,a1,1496 # 80008700 <syscalls+0x200>
    80006130:	8526                	mv	a0,s1
    80006132:	ffffe097          	auipc	ra,0xffffe
    80006136:	236080e7          	jalr	566(ra) # 80004368 <dirlink>
    8000613a:	f80557e3          	bgez	a0,800060c8 <create+0xcc>
      panic("create dots");
    8000613e:	00002517          	auipc	a0,0x2
    80006142:	73a50513          	addi	a0,a0,1850 # 80008878 <syscalls+0x378>
    80006146:	ffffa097          	auipc	ra,0xffffa
    8000614a:	3e4080e7          	jalr	996(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000614e:	00002517          	auipc	a0,0x2
    80006152:	73a50513          	addi	a0,a0,1850 # 80008888 <syscalls+0x388>
    80006156:	ffffa097          	auipc	ra,0xffffa
    8000615a:	3d4080e7          	jalr	980(ra) # 8000052a <panic>
    return 0;
    8000615e:	84aa                	mv	s1,a0
    80006160:	b739                	j	8000606e <create+0x72>

0000000080006162 <sys_open>:

uint64
sys_open(void)
{
    80006162:	7131                	addi	sp,sp,-192
    80006164:	fd06                	sd	ra,184(sp)
    80006166:	f922                	sd	s0,176(sp)
    80006168:	f526                	sd	s1,168(sp)
    8000616a:	f14a                	sd	s2,160(sp)
    8000616c:	ed4e                	sd	s3,152(sp)
    8000616e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006170:	08000613          	li	a2,128
    80006174:	f5040593          	addi	a1,s0,-176
    80006178:	4501                	li	a0,0
    8000617a:	ffffd097          	auipc	ra,0xffffd
    8000617e:	fb2080e7          	jalr	-78(ra) # 8000312c <argstr>
    return -1;
    80006182:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006184:	0c054163          	bltz	a0,80006246 <sys_open+0xe4>
    80006188:	f4c40593          	addi	a1,s0,-180
    8000618c:	4505                	li	a0,1
    8000618e:	ffffd097          	auipc	ra,0xffffd
    80006192:	f5a080e7          	jalr	-166(ra) # 800030e8 <argint>
    80006196:	0a054863          	bltz	a0,80006246 <sys_open+0xe4>

  begin_op();
    8000619a:	ffffe097          	auipc	ra,0xffffe
    8000619e:	7f8080e7          	jalr	2040(ra) # 80004992 <begin_op>

  if(omode & O_CREATE){
    800061a2:	f4c42783          	lw	a5,-180(s0)
    800061a6:	2007f793          	andi	a5,a5,512
    800061aa:	cbdd                	beqz	a5,80006260 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800061ac:	4681                	li	a3,0
    800061ae:	4601                	li	a2,0
    800061b0:	4589                	li	a1,2
    800061b2:	f5040513          	addi	a0,s0,-176
    800061b6:	00000097          	auipc	ra,0x0
    800061ba:	e46080e7          	jalr	-442(ra) # 80005ffc <create>
    800061be:	892a                	mv	s2,a0
    if(ip == 0){
    800061c0:	c959                	beqz	a0,80006256 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800061c2:	04491703          	lh	a4,68(s2)
    800061c6:	478d                	li	a5,3
    800061c8:	00f71763          	bne	a4,a5,800061d6 <sys_open+0x74>
    800061cc:	04695703          	lhu	a4,70(s2)
    800061d0:	47a5                	li	a5,9
    800061d2:	0ce7ec63          	bltu	a5,a4,800062aa <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800061d6:	fffff097          	auipc	ra,0xfffff
    800061da:	bcc080e7          	jalr	-1076(ra) # 80004da2 <filealloc>
    800061de:	89aa                	mv	s3,a0
    800061e0:	10050263          	beqz	a0,800062e4 <sys_open+0x182>
    800061e4:	00000097          	auipc	ra,0x0
    800061e8:	8e2080e7          	jalr	-1822(ra) # 80005ac6 <fdalloc>
    800061ec:	84aa                	mv	s1,a0
    800061ee:	0e054663          	bltz	a0,800062da <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800061f2:	04491703          	lh	a4,68(s2)
    800061f6:	478d                	li	a5,3
    800061f8:	0cf70463          	beq	a4,a5,800062c0 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800061fc:	4789                	li	a5,2
    800061fe:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006202:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006206:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000620a:	f4c42783          	lw	a5,-180(s0)
    8000620e:	0017c713          	xori	a4,a5,1
    80006212:	8b05                	andi	a4,a4,1
    80006214:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006218:	0037f713          	andi	a4,a5,3
    8000621c:	00e03733          	snez	a4,a4
    80006220:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006224:	4007f793          	andi	a5,a5,1024
    80006228:	c791                	beqz	a5,80006234 <sys_open+0xd2>
    8000622a:	04491703          	lh	a4,68(s2)
    8000622e:	4789                	li	a5,2
    80006230:	08f70f63          	beq	a4,a5,800062ce <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006234:	854a                	mv	a0,s2
    80006236:	ffffe097          	auipc	ra,0xffffe
    8000623a:	b00080e7          	jalr	-1280(ra) # 80003d36 <iunlock>
  end_op();
    8000623e:	ffffe097          	auipc	ra,0xffffe
    80006242:	7d4080e7          	jalr	2004(ra) # 80004a12 <end_op>

  return fd;
}
    80006246:	8526                	mv	a0,s1
    80006248:	70ea                	ld	ra,184(sp)
    8000624a:	744a                	ld	s0,176(sp)
    8000624c:	74aa                	ld	s1,168(sp)
    8000624e:	790a                	ld	s2,160(sp)
    80006250:	69ea                	ld	s3,152(sp)
    80006252:	6129                	addi	sp,sp,192
    80006254:	8082                	ret
      end_op();
    80006256:	ffffe097          	auipc	ra,0xffffe
    8000625a:	7bc080e7          	jalr	1980(ra) # 80004a12 <end_op>
      return -1;
    8000625e:	b7e5                	j	80006246 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006260:	f5040513          	addi	a0,s0,-176
    80006264:	ffffe097          	auipc	ra,0xffffe
    80006268:	1c6080e7          	jalr	454(ra) # 8000442a <namei>
    8000626c:	892a                	mv	s2,a0
    8000626e:	c905                	beqz	a0,8000629e <sys_open+0x13c>
    ilock(ip);
    80006270:	ffffe097          	auipc	ra,0xffffe
    80006274:	a04080e7          	jalr	-1532(ra) # 80003c74 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006278:	04491703          	lh	a4,68(s2)
    8000627c:	4785                	li	a5,1
    8000627e:	f4f712e3          	bne	a4,a5,800061c2 <sys_open+0x60>
    80006282:	f4c42783          	lw	a5,-180(s0)
    80006286:	dba1                	beqz	a5,800061d6 <sys_open+0x74>
      iunlockput(ip);
    80006288:	854a                	mv	a0,s2
    8000628a:	ffffe097          	auipc	ra,0xffffe
    8000628e:	c4c080e7          	jalr	-948(ra) # 80003ed6 <iunlockput>
      end_op();
    80006292:	ffffe097          	auipc	ra,0xffffe
    80006296:	780080e7          	jalr	1920(ra) # 80004a12 <end_op>
      return -1;
    8000629a:	54fd                	li	s1,-1
    8000629c:	b76d                	j	80006246 <sys_open+0xe4>
      end_op();
    8000629e:	ffffe097          	auipc	ra,0xffffe
    800062a2:	774080e7          	jalr	1908(ra) # 80004a12 <end_op>
      return -1;
    800062a6:	54fd                	li	s1,-1
    800062a8:	bf79                	j	80006246 <sys_open+0xe4>
    iunlockput(ip);
    800062aa:	854a                	mv	a0,s2
    800062ac:	ffffe097          	auipc	ra,0xffffe
    800062b0:	c2a080e7          	jalr	-982(ra) # 80003ed6 <iunlockput>
    end_op();
    800062b4:	ffffe097          	auipc	ra,0xffffe
    800062b8:	75e080e7          	jalr	1886(ra) # 80004a12 <end_op>
    return -1;
    800062bc:	54fd                	li	s1,-1
    800062be:	b761                	j	80006246 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800062c0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800062c4:	04691783          	lh	a5,70(s2)
    800062c8:	02f99223          	sh	a5,36(s3)
    800062cc:	bf2d                	j	80006206 <sys_open+0xa4>
    itrunc(ip);
    800062ce:	854a                	mv	a0,s2
    800062d0:	ffffe097          	auipc	ra,0xffffe
    800062d4:	ab2080e7          	jalr	-1358(ra) # 80003d82 <itrunc>
    800062d8:	bfb1                	j	80006234 <sys_open+0xd2>
      fileclose(f);
    800062da:	854e                	mv	a0,s3
    800062dc:	fffff097          	auipc	ra,0xfffff
    800062e0:	b82080e7          	jalr	-1150(ra) # 80004e5e <fileclose>
    iunlockput(ip);
    800062e4:	854a                	mv	a0,s2
    800062e6:	ffffe097          	auipc	ra,0xffffe
    800062ea:	bf0080e7          	jalr	-1040(ra) # 80003ed6 <iunlockput>
    end_op();
    800062ee:	ffffe097          	auipc	ra,0xffffe
    800062f2:	724080e7          	jalr	1828(ra) # 80004a12 <end_op>
    return -1;
    800062f6:	54fd                	li	s1,-1
    800062f8:	b7b9                	j	80006246 <sys_open+0xe4>

00000000800062fa <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800062fa:	7175                	addi	sp,sp,-144
    800062fc:	e506                	sd	ra,136(sp)
    800062fe:	e122                	sd	s0,128(sp)
    80006300:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006302:	ffffe097          	auipc	ra,0xffffe
    80006306:	690080e7          	jalr	1680(ra) # 80004992 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000630a:	08000613          	li	a2,128
    8000630e:	f7040593          	addi	a1,s0,-144
    80006312:	4501                	li	a0,0
    80006314:	ffffd097          	auipc	ra,0xffffd
    80006318:	e18080e7          	jalr	-488(ra) # 8000312c <argstr>
    8000631c:	02054963          	bltz	a0,8000634e <sys_mkdir+0x54>
    80006320:	4681                	li	a3,0
    80006322:	4601                	li	a2,0
    80006324:	4585                	li	a1,1
    80006326:	f7040513          	addi	a0,s0,-144
    8000632a:	00000097          	auipc	ra,0x0
    8000632e:	cd2080e7          	jalr	-814(ra) # 80005ffc <create>
    80006332:	cd11                	beqz	a0,8000634e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006334:	ffffe097          	auipc	ra,0xffffe
    80006338:	ba2080e7          	jalr	-1118(ra) # 80003ed6 <iunlockput>
  end_op();
    8000633c:	ffffe097          	auipc	ra,0xffffe
    80006340:	6d6080e7          	jalr	1750(ra) # 80004a12 <end_op>
  return 0;
    80006344:	4501                	li	a0,0
}
    80006346:	60aa                	ld	ra,136(sp)
    80006348:	640a                	ld	s0,128(sp)
    8000634a:	6149                	addi	sp,sp,144
    8000634c:	8082                	ret
    end_op();
    8000634e:	ffffe097          	auipc	ra,0xffffe
    80006352:	6c4080e7          	jalr	1732(ra) # 80004a12 <end_op>
    return -1;
    80006356:	557d                	li	a0,-1
    80006358:	b7fd                	j	80006346 <sys_mkdir+0x4c>

000000008000635a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000635a:	7135                	addi	sp,sp,-160
    8000635c:	ed06                	sd	ra,152(sp)
    8000635e:	e922                	sd	s0,144(sp)
    80006360:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006362:	ffffe097          	auipc	ra,0xffffe
    80006366:	630080e7          	jalr	1584(ra) # 80004992 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000636a:	08000613          	li	a2,128
    8000636e:	f7040593          	addi	a1,s0,-144
    80006372:	4501                	li	a0,0
    80006374:	ffffd097          	auipc	ra,0xffffd
    80006378:	db8080e7          	jalr	-584(ra) # 8000312c <argstr>
    8000637c:	04054a63          	bltz	a0,800063d0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006380:	f6c40593          	addi	a1,s0,-148
    80006384:	4505                	li	a0,1
    80006386:	ffffd097          	auipc	ra,0xffffd
    8000638a:	d62080e7          	jalr	-670(ra) # 800030e8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000638e:	04054163          	bltz	a0,800063d0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006392:	f6840593          	addi	a1,s0,-152
    80006396:	4509                	li	a0,2
    80006398:	ffffd097          	auipc	ra,0xffffd
    8000639c:	d50080e7          	jalr	-688(ra) # 800030e8 <argint>
     argint(1, &major) < 0 ||
    800063a0:	02054863          	bltz	a0,800063d0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800063a4:	f6841683          	lh	a3,-152(s0)
    800063a8:	f6c41603          	lh	a2,-148(s0)
    800063ac:	458d                	li	a1,3
    800063ae:	f7040513          	addi	a0,s0,-144
    800063b2:	00000097          	auipc	ra,0x0
    800063b6:	c4a080e7          	jalr	-950(ra) # 80005ffc <create>
     argint(2, &minor) < 0 ||
    800063ba:	c919                	beqz	a0,800063d0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800063bc:	ffffe097          	auipc	ra,0xffffe
    800063c0:	b1a080e7          	jalr	-1254(ra) # 80003ed6 <iunlockput>
  end_op();
    800063c4:	ffffe097          	auipc	ra,0xffffe
    800063c8:	64e080e7          	jalr	1614(ra) # 80004a12 <end_op>
  return 0;
    800063cc:	4501                	li	a0,0
    800063ce:	a031                	j	800063da <sys_mknod+0x80>
    end_op();
    800063d0:	ffffe097          	auipc	ra,0xffffe
    800063d4:	642080e7          	jalr	1602(ra) # 80004a12 <end_op>
    return -1;
    800063d8:	557d                	li	a0,-1
}
    800063da:	60ea                	ld	ra,152(sp)
    800063dc:	644a                	ld	s0,144(sp)
    800063de:	610d                	addi	sp,sp,160
    800063e0:	8082                	ret

00000000800063e2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800063e2:	7135                	addi	sp,sp,-160
    800063e4:	ed06                	sd	ra,152(sp)
    800063e6:	e922                	sd	s0,144(sp)
    800063e8:	e526                	sd	s1,136(sp)
    800063ea:	e14a                	sd	s2,128(sp)
    800063ec:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800063ee:	ffffc097          	auipc	ra,0xffffc
    800063f2:	a78080e7          	jalr	-1416(ra) # 80001e66 <myproc>
    800063f6:	892a                	mv	s2,a0
  
  begin_op();
    800063f8:	ffffe097          	auipc	ra,0xffffe
    800063fc:	59a080e7          	jalr	1434(ra) # 80004992 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006400:	08000613          	li	a2,128
    80006404:	f6040593          	addi	a1,s0,-160
    80006408:	4501                	li	a0,0
    8000640a:	ffffd097          	auipc	ra,0xffffd
    8000640e:	d22080e7          	jalr	-734(ra) # 8000312c <argstr>
    80006412:	04054b63          	bltz	a0,80006468 <sys_chdir+0x86>
    80006416:	f6040513          	addi	a0,s0,-160
    8000641a:	ffffe097          	auipc	ra,0xffffe
    8000641e:	010080e7          	jalr	16(ra) # 8000442a <namei>
    80006422:	84aa                	mv	s1,a0
    80006424:	c131                	beqz	a0,80006468 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006426:	ffffe097          	auipc	ra,0xffffe
    8000642a:	84e080e7          	jalr	-1970(ra) # 80003c74 <ilock>
  if(ip->type != T_DIR){
    8000642e:	04449703          	lh	a4,68(s1)
    80006432:	4785                	li	a5,1
    80006434:	04f71063          	bne	a4,a5,80006474 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006438:	8526                	mv	a0,s1
    8000643a:	ffffe097          	auipc	ra,0xffffe
    8000643e:	8fc080e7          	jalr	-1796(ra) # 80003d36 <iunlock>
  iput(p->cwd);
    80006442:	15093503          	ld	a0,336(s2)
    80006446:	ffffe097          	auipc	ra,0xffffe
    8000644a:	9e8080e7          	jalr	-1560(ra) # 80003e2e <iput>
  end_op();
    8000644e:	ffffe097          	auipc	ra,0xffffe
    80006452:	5c4080e7          	jalr	1476(ra) # 80004a12 <end_op>
  p->cwd = ip;
    80006456:	14993823          	sd	s1,336(s2)
  return 0;
    8000645a:	4501                	li	a0,0
}
    8000645c:	60ea                	ld	ra,152(sp)
    8000645e:	644a                	ld	s0,144(sp)
    80006460:	64aa                	ld	s1,136(sp)
    80006462:	690a                	ld	s2,128(sp)
    80006464:	610d                	addi	sp,sp,160
    80006466:	8082                	ret
    end_op();
    80006468:	ffffe097          	auipc	ra,0xffffe
    8000646c:	5aa080e7          	jalr	1450(ra) # 80004a12 <end_op>
    return -1;
    80006470:	557d                	li	a0,-1
    80006472:	b7ed                	j	8000645c <sys_chdir+0x7a>
    iunlockput(ip);
    80006474:	8526                	mv	a0,s1
    80006476:	ffffe097          	auipc	ra,0xffffe
    8000647a:	a60080e7          	jalr	-1440(ra) # 80003ed6 <iunlockput>
    end_op();
    8000647e:	ffffe097          	auipc	ra,0xffffe
    80006482:	594080e7          	jalr	1428(ra) # 80004a12 <end_op>
    return -1;
    80006486:	557d                	li	a0,-1
    80006488:	bfd1                	j	8000645c <sys_chdir+0x7a>

000000008000648a <sys_exec>:

uint64
sys_exec(void)
{
    8000648a:	7145                	addi	sp,sp,-464
    8000648c:	e786                	sd	ra,456(sp)
    8000648e:	e3a2                	sd	s0,448(sp)
    80006490:	ff26                	sd	s1,440(sp)
    80006492:	fb4a                	sd	s2,432(sp)
    80006494:	f74e                	sd	s3,424(sp)
    80006496:	f352                	sd	s4,416(sp)
    80006498:	ef56                	sd	s5,408(sp)
    8000649a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000649c:	08000613          	li	a2,128
    800064a0:	f4040593          	addi	a1,s0,-192
    800064a4:	4501                	li	a0,0
    800064a6:	ffffd097          	auipc	ra,0xffffd
    800064aa:	c86080e7          	jalr	-890(ra) # 8000312c <argstr>
    return -1;
    800064ae:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800064b0:	0c054a63          	bltz	a0,80006584 <sys_exec+0xfa>
    800064b4:	e3840593          	addi	a1,s0,-456
    800064b8:	4505                	li	a0,1
    800064ba:	ffffd097          	auipc	ra,0xffffd
    800064be:	c50080e7          	jalr	-944(ra) # 8000310a <argaddr>
    800064c2:	0c054163          	bltz	a0,80006584 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800064c6:	10000613          	li	a2,256
    800064ca:	4581                	li	a1,0
    800064cc:	e4040513          	addi	a0,s0,-448
    800064d0:	ffffa097          	auipc	ra,0xffffa
    800064d4:	7ee080e7          	jalr	2030(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800064d8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800064dc:	89a6                	mv	s3,s1
    800064de:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800064e0:	02000a13          	li	s4,32
    800064e4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800064e8:	00391793          	slli	a5,s2,0x3
    800064ec:	e3040593          	addi	a1,s0,-464
    800064f0:	e3843503          	ld	a0,-456(s0)
    800064f4:	953e                	add	a0,a0,a5
    800064f6:	ffffd097          	auipc	ra,0xffffd
    800064fa:	b58080e7          	jalr	-1192(ra) # 8000304e <fetchaddr>
    800064fe:	02054a63          	bltz	a0,80006532 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006502:	e3043783          	ld	a5,-464(s0)
    80006506:	c3b9                	beqz	a5,8000654c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006508:	ffffa097          	auipc	ra,0xffffa
    8000650c:	5ca080e7          	jalr	1482(ra) # 80000ad2 <kalloc>
    80006510:	85aa                	mv	a1,a0
    80006512:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006516:	cd11                	beqz	a0,80006532 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006518:	6605                	lui	a2,0x1
    8000651a:	e3043503          	ld	a0,-464(s0)
    8000651e:	ffffd097          	auipc	ra,0xffffd
    80006522:	b82080e7          	jalr	-1150(ra) # 800030a0 <fetchstr>
    80006526:	00054663          	bltz	a0,80006532 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000652a:	0905                	addi	s2,s2,1
    8000652c:	09a1                	addi	s3,s3,8
    8000652e:	fb491be3          	bne	s2,s4,800064e4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006532:	10048913          	addi	s2,s1,256
    80006536:	6088                	ld	a0,0(s1)
    80006538:	c529                	beqz	a0,80006582 <sys_exec+0xf8>
    kfree(argv[i]);
    8000653a:	ffffa097          	auipc	ra,0xffffa
    8000653e:	49c080e7          	jalr	1180(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006542:	04a1                	addi	s1,s1,8
    80006544:	ff2499e3          	bne	s1,s2,80006536 <sys_exec+0xac>
  return -1;
    80006548:	597d                	li	s2,-1
    8000654a:	a82d                	j	80006584 <sys_exec+0xfa>
      argv[i] = 0;
    8000654c:	0a8e                	slli	s5,s5,0x3
    8000654e:	fc040793          	addi	a5,s0,-64
    80006552:	9abe                	add	s5,s5,a5
    80006554:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffc8e80>
  int ret = exec(path, argv);
    80006558:	e4040593          	addi	a1,s0,-448
    8000655c:	f4040513          	addi	a0,s0,-192
    80006560:	fffff097          	auipc	ra,0xfffff
    80006564:	146080e7          	jalr	326(ra) # 800056a6 <exec>
    80006568:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000656a:	10048993          	addi	s3,s1,256
    8000656e:	6088                	ld	a0,0(s1)
    80006570:	c911                	beqz	a0,80006584 <sys_exec+0xfa>
    kfree(argv[i]);
    80006572:	ffffa097          	auipc	ra,0xffffa
    80006576:	464080e7          	jalr	1124(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000657a:	04a1                	addi	s1,s1,8
    8000657c:	ff3499e3          	bne	s1,s3,8000656e <sys_exec+0xe4>
    80006580:	a011                	j	80006584 <sys_exec+0xfa>
  return -1;
    80006582:	597d                	li	s2,-1
}
    80006584:	854a                	mv	a0,s2
    80006586:	60be                	ld	ra,456(sp)
    80006588:	641e                	ld	s0,448(sp)
    8000658a:	74fa                	ld	s1,440(sp)
    8000658c:	795a                	ld	s2,432(sp)
    8000658e:	79ba                	ld	s3,424(sp)
    80006590:	7a1a                	ld	s4,416(sp)
    80006592:	6afa                	ld	s5,408(sp)
    80006594:	6179                	addi	sp,sp,464
    80006596:	8082                	ret

0000000080006598 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006598:	7139                	addi	sp,sp,-64
    8000659a:	fc06                	sd	ra,56(sp)
    8000659c:	f822                	sd	s0,48(sp)
    8000659e:	f426                	sd	s1,40(sp)
    800065a0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800065a2:	ffffc097          	auipc	ra,0xffffc
    800065a6:	8c4080e7          	jalr	-1852(ra) # 80001e66 <myproc>
    800065aa:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800065ac:	fd840593          	addi	a1,s0,-40
    800065b0:	4501                	li	a0,0
    800065b2:	ffffd097          	auipc	ra,0xffffd
    800065b6:	b58080e7          	jalr	-1192(ra) # 8000310a <argaddr>
    return -1;
    800065ba:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800065bc:	0e054063          	bltz	a0,8000669c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800065c0:	fc840593          	addi	a1,s0,-56
    800065c4:	fd040513          	addi	a0,s0,-48
    800065c8:	fffff097          	auipc	ra,0xfffff
    800065cc:	dbc080e7          	jalr	-580(ra) # 80005384 <pipealloc>
    return -1;
    800065d0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800065d2:	0c054563          	bltz	a0,8000669c <sys_pipe+0x104>
  fd0 = -1;
    800065d6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800065da:	fd043503          	ld	a0,-48(s0)
    800065de:	fffff097          	auipc	ra,0xfffff
    800065e2:	4e8080e7          	jalr	1256(ra) # 80005ac6 <fdalloc>
    800065e6:	fca42223          	sw	a0,-60(s0)
    800065ea:	08054c63          	bltz	a0,80006682 <sys_pipe+0xea>
    800065ee:	fc843503          	ld	a0,-56(s0)
    800065f2:	fffff097          	auipc	ra,0xfffff
    800065f6:	4d4080e7          	jalr	1236(ra) # 80005ac6 <fdalloc>
    800065fa:	fca42023          	sw	a0,-64(s0)
    800065fe:	06054863          	bltz	a0,8000666e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006602:	4691                	li	a3,4
    80006604:	fc440613          	addi	a2,s0,-60
    80006608:	fd843583          	ld	a1,-40(s0)
    8000660c:	68a8                	ld	a0,80(s1)
    8000660e:	ffffb097          	auipc	ra,0xffffb
    80006612:	d70080e7          	jalr	-656(ra) # 8000137e <copyout>
    80006616:	02054063          	bltz	a0,80006636 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000661a:	4691                	li	a3,4
    8000661c:	fc040613          	addi	a2,s0,-64
    80006620:	fd843583          	ld	a1,-40(s0)
    80006624:	0591                	addi	a1,a1,4
    80006626:	68a8                	ld	a0,80(s1)
    80006628:	ffffb097          	auipc	ra,0xffffb
    8000662c:	d56080e7          	jalr	-682(ra) # 8000137e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006630:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006632:	06055563          	bgez	a0,8000669c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006636:	fc442783          	lw	a5,-60(s0)
    8000663a:	07e9                	addi	a5,a5,26
    8000663c:	078e                	slli	a5,a5,0x3
    8000663e:	97a6                	add	a5,a5,s1
    80006640:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006644:	fc042503          	lw	a0,-64(s0)
    80006648:	0569                	addi	a0,a0,26
    8000664a:	050e                	slli	a0,a0,0x3
    8000664c:	9526                	add	a0,a0,s1
    8000664e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006652:	fd043503          	ld	a0,-48(s0)
    80006656:	fffff097          	auipc	ra,0xfffff
    8000665a:	808080e7          	jalr	-2040(ra) # 80004e5e <fileclose>
    fileclose(wf);
    8000665e:	fc843503          	ld	a0,-56(s0)
    80006662:	ffffe097          	auipc	ra,0xffffe
    80006666:	7fc080e7          	jalr	2044(ra) # 80004e5e <fileclose>
    return -1;
    8000666a:	57fd                	li	a5,-1
    8000666c:	a805                	j	8000669c <sys_pipe+0x104>
    if(fd0 >= 0)
    8000666e:	fc442783          	lw	a5,-60(s0)
    80006672:	0007c863          	bltz	a5,80006682 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006676:	01a78513          	addi	a0,a5,26
    8000667a:	050e                	slli	a0,a0,0x3
    8000667c:	9526                	add	a0,a0,s1
    8000667e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006682:	fd043503          	ld	a0,-48(s0)
    80006686:	ffffe097          	auipc	ra,0xffffe
    8000668a:	7d8080e7          	jalr	2008(ra) # 80004e5e <fileclose>
    fileclose(wf);
    8000668e:	fc843503          	ld	a0,-56(s0)
    80006692:	ffffe097          	auipc	ra,0xffffe
    80006696:	7cc080e7          	jalr	1996(ra) # 80004e5e <fileclose>
    return -1;
    8000669a:	57fd                	li	a5,-1
}
    8000669c:	853e                	mv	a0,a5
    8000669e:	70e2                	ld	ra,56(sp)
    800066a0:	7442                	ld	s0,48(sp)
    800066a2:	74a2                	ld	s1,40(sp)
    800066a4:	6121                	addi	sp,sp,64
    800066a6:	8082                	ret
	...

00000000800066b0 <kernelvec>:
    800066b0:	7111                	addi	sp,sp,-256
    800066b2:	e006                	sd	ra,0(sp)
    800066b4:	e40a                	sd	sp,8(sp)
    800066b6:	e80e                	sd	gp,16(sp)
    800066b8:	ec12                	sd	tp,24(sp)
    800066ba:	f016                	sd	t0,32(sp)
    800066bc:	f41a                	sd	t1,40(sp)
    800066be:	f81e                	sd	t2,48(sp)
    800066c0:	fc22                	sd	s0,56(sp)
    800066c2:	e0a6                	sd	s1,64(sp)
    800066c4:	e4aa                	sd	a0,72(sp)
    800066c6:	e8ae                	sd	a1,80(sp)
    800066c8:	ecb2                	sd	a2,88(sp)
    800066ca:	f0b6                	sd	a3,96(sp)
    800066cc:	f4ba                	sd	a4,104(sp)
    800066ce:	f8be                	sd	a5,112(sp)
    800066d0:	fcc2                	sd	a6,120(sp)
    800066d2:	e146                	sd	a7,128(sp)
    800066d4:	e54a                	sd	s2,136(sp)
    800066d6:	e94e                	sd	s3,144(sp)
    800066d8:	ed52                	sd	s4,152(sp)
    800066da:	f156                	sd	s5,160(sp)
    800066dc:	f55a                	sd	s6,168(sp)
    800066de:	f95e                	sd	s7,176(sp)
    800066e0:	fd62                	sd	s8,184(sp)
    800066e2:	e1e6                	sd	s9,192(sp)
    800066e4:	e5ea                	sd	s10,200(sp)
    800066e6:	e9ee                	sd	s11,208(sp)
    800066e8:	edf2                	sd	t3,216(sp)
    800066ea:	f1f6                	sd	t4,224(sp)
    800066ec:	f5fa                	sd	t5,232(sp)
    800066ee:	f9fe                	sd	t6,240(sp)
    800066f0:	82bfc0ef          	jal	ra,80002f1a <kerneltrap>
    800066f4:	6082                	ld	ra,0(sp)
    800066f6:	6122                	ld	sp,8(sp)
    800066f8:	61c2                	ld	gp,16(sp)
    800066fa:	7282                	ld	t0,32(sp)
    800066fc:	7322                	ld	t1,40(sp)
    800066fe:	73c2                	ld	t2,48(sp)
    80006700:	7462                	ld	s0,56(sp)
    80006702:	6486                	ld	s1,64(sp)
    80006704:	6526                	ld	a0,72(sp)
    80006706:	65c6                	ld	a1,80(sp)
    80006708:	6666                	ld	a2,88(sp)
    8000670a:	7686                	ld	a3,96(sp)
    8000670c:	7726                	ld	a4,104(sp)
    8000670e:	77c6                	ld	a5,112(sp)
    80006710:	7866                	ld	a6,120(sp)
    80006712:	688a                	ld	a7,128(sp)
    80006714:	692a                	ld	s2,136(sp)
    80006716:	69ca                	ld	s3,144(sp)
    80006718:	6a6a                	ld	s4,152(sp)
    8000671a:	7a8a                	ld	s5,160(sp)
    8000671c:	7b2a                	ld	s6,168(sp)
    8000671e:	7bca                	ld	s7,176(sp)
    80006720:	7c6a                	ld	s8,184(sp)
    80006722:	6c8e                	ld	s9,192(sp)
    80006724:	6d2e                	ld	s10,200(sp)
    80006726:	6dce                	ld	s11,208(sp)
    80006728:	6e6e                	ld	t3,216(sp)
    8000672a:	7e8e                	ld	t4,224(sp)
    8000672c:	7f2e                	ld	t5,232(sp)
    8000672e:	7fce                	ld	t6,240(sp)
    80006730:	6111                	addi	sp,sp,256
    80006732:	10200073          	sret
    80006736:	00000013          	nop
    8000673a:	00000013          	nop
    8000673e:	0001                	nop

0000000080006740 <timervec>:
    80006740:	34051573          	csrrw	a0,mscratch,a0
    80006744:	e10c                	sd	a1,0(a0)
    80006746:	e510                	sd	a2,8(a0)
    80006748:	e914                	sd	a3,16(a0)
    8000674a:	6d0c                	ld	a1,24(a0)
    8000674c:	7110                	ld	a2,32(a0)
    8000674e:	6194                	ld	a3,0(a1)
    80006750:	96b2                	add	a3,a3,a2
    80006752:	e194                	sd	a3,0(a1)
    80006754:	4589                	li	a1,2
    80006756:	14459073          	csrw	sip,a1
    8000675a:	6914                	ld	a3,16(a0)
    8000675c:	6510                	ld	a2,8(a0)
    8000675e:	610c                	ld	a1,0(a0)
    80006760:	34051573          	csrrw	a0,mscratch,a0
    80006764:	30200073          	mret
	...

000000008000676a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000676a:	1141                	addi	sp,sp,-16
    8000676c:	e422                	sd	s0,8(sp)
    8000676e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006770:	0c0007b7          	lui	a5,0xc000
    80006774:	4705                	li	a4,1
    80006776:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006778:	c3d8                	sw	a4,4(a5)
}
    8000677a:	6422                	ld	s0,8(sp)
    8000677c:	0141                	addi	sp,sp,16
    8000677e:	8082                	ret

0000000080006780 <plicinithart>:

void
plicinithart(void)
{
    80006780:	1141                	addi	sp,sp,-16
    80006782:	e406                	sd	ra,8(sp)
    80006784:	e022                	sd	s0,0(sp)
    80006786:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006788:	ffffb097          	auipc	ra,0xffffb
    8000678c:	6b2080e7          	jalr	1714(ra) # 80001e3a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006790:	0085171b          	slliw	a4,a0,0x8
    80006794:	0c0027b7          	lui	a5,0xc002
    80006798:	97ba                	add	a5,a5,a4
    8000679a:	40200713          	li	a4,1026
    8000679e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800067a2:	00d5151b          	slliw	a0,a0,0xd
    800067a6:	0c2017b7          	lui	a5,0xc201
    800067aa:	953e                	add	a0,a0,a5
    800067ac:	00052023          	sw	zero,0(a0)
}
    800067b0:	60a2                	ld	ra,8(sp)
    800067b2:	6402                	ld	s0,0(sp)
    800067b4:	0141                	addi	sp,sp,16
    800067b6:	8082                	ret

00000000800067b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800067b8:	1141                	addi	sp,sp,-16
    800067ba:	e406                	sd	ra,8(sp)
    800067bc:	e022                	sd	s0,0(sp)
    800067be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800067c0:	ffffb097          	auipc	ra,0xffffb
    800067c4:	67a080e7          	jalr	1658(ra) # 80001e3a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800067c8:	00d5179b          	slliw	a5,a0,0xd
    800067cc:	0c201537          	lui	a0,0xc201
    800067d0:	953e                	add	a0,a0,a5
  return irq;
}
    800067d2:	4148                	lw	a0,4(a0)
    800067d4:	60a2                	ld	ra,8(sp)
    800067d6:	6402                	ld	s0,0(sp)
    800067d8:	0141                	addi	sp,sp,16
    800067da:	8082                	ret

00000000800067dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800067dc:	1101                	addi	sp,sp,-32
    800067de:	ec06                	sd	ra,24(sp)
    800067e0:	e822                	sd	s0,16(sp)
    800067e2:	e426                	sd	s1,8(sp)
    800067e4:	1000                	addi	s0,sp,32
    800067e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800067e8:	ffffb097          	auipc	ra,0xffffb
    800067ec:	652080e7          	jalr	1618(ra) # 80001e3a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800067f0:	00d5151b          	slliw	a0,a0,0xd
    800067f4:	0c2017b7          	lui	a5,0xc201
    800067f8:	97aa                	add	a5,a5,a0
    800067fa:	c3c4                	sw	s1,4(a5)
}
    800067fc:	60e2                	ld	ra,24(sp)
    800067fe:	6442                	ld	s0,16(sp)
    80006800:	64a2                	ld	s1,8(sp)
    80006802:	6105                	addi	sp,sp,32
    80006804:	8082                	ret

0000000080006806 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006806:	1141                	addi	sp,sp,-16
    80006808:	e406                	sd	ra,8(sp)
    8000680a:	e022                	sd	s0,0(sp)
    8000680c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000680e:	479d                	li	a5,7
    80006810:	06a7c963          	blt	a5,a0,80006882 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006814:	0002c797          	auipc	a5,0x2c
    80006818:	7ec78793          	addi	a5,a5,2028 # 80033000 <disk>
    8000681c:	00a78733          	add	a4,a5,a0
    80006820:	6789                	lui	a5,0x2
    80006822:	97ba                	add	a5,a5,a4
    80006824:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006828:	e7ad                	bnez	a5,80006892 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000682a:	00451793          	slli	a5,a0,0x4
    8000682e:	0002e717          	auipc	a4,0x2e
    80006832:	7d270713          	addi	a4,a4,2002 # 80035000 <disk+0x2000>
    80006836:	6314                	ld	a3,0(a4)
    80006838:	96be                	add	a3,a3,a5
    8000683a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000683e:	6314                	ld	a3,0(a4)
    80006840:	96be                	add	a3,a3,a5
    80006842:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006846:	6314                	ld	a3,0(a4)
    80006848:	96be                	add	a3,a3,a5
    8000684a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000684e:	6318                	ld	a4,0(a4)
    80006850:	97ba                	add	a5,a5,a4
    80006852:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006856:	0002c797          	auipc	a5,0x2c
    8000685a:	7aa78793          	addi	a5,a5,1962 # 80033000 <disk>
    8000685e:	97aa                	add	a5,a5,a0
    80006860:	6509                	lui	a0,0x2
    80006862:	953e                	add	a0,a0,a5
    80006864:	4785                	li	a5,1
    80006866:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000686a:	0002e517          	auipc	a0,0x2e
    8000686e:	7ae50513          	addi	a0,a0,1966 # 80035018 <disk+0x2018>
    80006872:	ffffc097          	auipc	ra,0xffffc
    80006876:	f36080e7          	jalr	-202(ra) # 800027a8 <wakeup>
}
    8000687a:	60a2                	ld	ra,8(sp)
    8000687c:	6402                	ld	s0,0(sp)
    8000687e:	0141                	addi	sp,sp,16
    80006880:	8082                	ret
    panic("free_desc 1");
    80006882:	00002517          	auipc	a0,0x2
    80006886:	01650513          	addi	a0,a0,22 # 80008898 <syscalls+0x398>
    8000688a:	ffffa097          	auipc	ra,0xffffa
    8000688e:	ca0080e7          	jalr	-864(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006892:	00002517          	auipc	a0,0x2
    80006896:	01650513          	addi	a0,a0,22 # 800088a8 <syscalls+0x3a8>
    8000689a:	ffffa097          	auipc	ra,0xffffa
    8000689e:	c90080e7          	jalr	-880(ra) # 8000052a <panic>

00000000800068a2 <virtio_disk_init>:
{
    800068a2:	1101                	addi	sp,sp,-32
    800068a4:	ec06                	sd	ra,24(sp)
    800068a6:	e822                	sd	s0,16(sp)
    800068a8:	e426                	sd	s1,8(sp)
    800068aa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800068ac:	00002597          	auipc	a1,0x2
    800068b0:	00c58593          	addi	a1,a1,12 # 800088b8 <syscalls+0x3b8>
    800068b4:	0002f517          	auipc	a0,0x2f
    800068b8:	87450513          	addi	a0,a0,-1932 # 80035128 <disk+0x2128>
    800068bc:	ffffa097          	auipc	ra,0xffffa
    800068c0:	276080e7          	jalr	630(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068c4:	100017b7          	lui	a5,0x10001
    800068c8:	4398                	lw	a4,0(a5)
    800068ca:	2701                	sext.w	a4,a4
    800068cc:	747277b7          	lui	a5,0x74727
    800068d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800068d4:	0ef71163          	bne	a4,a5,800069b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800068d8:	100017b7          	lui	a5,0x10001
    800068dc:	43dc                	lw	a5,4(a5)
    800068de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068e0:	4705                	li	a4,1
    800068e2:	0ce79a63          	bne	a5,a4,800069b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800068e6:	100017b7          	lui	a5,0x10001
    800068ea:	479c                	lw	a5,8(a5)
    800068ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800068ee:	4709                	li	a4,2
    800068f0:	0ce79363          	bne	a5,a4,800069b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800068f4:	100017b7          	lui	a5,0x10001
    800068f8:	47d8                	lw	a4,12(a5)
    800068fa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800068fc:	554d47b7          	lui	a5,0x554d4
    80006900:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006904:	0af71963          	bne	a4,a5,800069b6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006908:	100017b7          	lui	a5,0x10001
    8000690c:	4705                	li	a4,1
    8000690e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006910:	470d                	li	a4,3
    80006912:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006914:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006916:	c7ffe737          	lui	a4,0xc7ffe
    8000691a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc875f>
    8000691e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006920:	2701                	sext.w	a4,a4
    80006922:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006924:	472d                	li	a4,11
    80006926:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006928:	473d                	li	a4,15
    8000692a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000692c:	6705                	lui	a4,0x1
    8000692e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006930:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006934:	5bdc                	lw	a5,52(a5)
    80006936:	2781                	sext.w	a5,a5
  if(max == 0)
    80006938:	c7d9                	beqz	a5,800069c6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000693a:	471d                	li	a4,7
    8000693c:	08f77d63          	bgeu	a4,a5,800069d6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006940:	100014b7          	lui	s1,0x10001
    80006944:	47a1                	li	a5,8
    80006946:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006948:	6609                	lui	a2,0x2
    8000694a:	4581                	li	a1,0
    8000694c:	0002c517          	auipc	a0,0x2c
    80006950:	6b450513          	addi	a0,a0,1716 # 80033000 <disk>
    80006954:	ffffa097          	auipc	ra,0xffffa
    80006958:	36a080e7          	jalr	874(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000695c:	0002c717          	auipc	a4,0x2c
    80006960:	6a470713          	addi	a4,a4,1700 # 80033000 <disk>
    80006964:	00c75793          	srli	a5,a4,0xc
    80006968:	2781                	sext.w	a5,a5
    8000696a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000696c:	0002e797          	auipc	a5,0x2e
    80006970:	69478793          	addi	a5,a5,1684 # 80035000 <disk+0x2000>
    80006974:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006976:	0002c717          	auipc	a4,0x2c
    8000697a:	70a70713          	addi	a4,a4,1802 # 80033080 <disk+0x80>
    8000697e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006980:	0002d717          	auipc	a4,0x2d
    80006984:	68070713          	addi	a4,a4,1664 # 80034000 <disk+0x1000>
    80006988:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000698a:	4705                	li	a4,1
    8000698c:	00e78c23          	sb	a4,24(a5)
    80006990:	00e78ca3          	sb	a4,25(a5)
    80006994:	00e78d23          	sb	a4,26(a5)
    80006998:	00e78da3          	sb	a4,27(a5)
    8000699c:	00e78e23          	sb	a4,28(a5)
    800069a0:	00e78ea3          	sb	a4,29(a5)
    800069a4:	00e78f23          	sb	a4,30(a5)
    800069a8:	00e78fa3          	sb	a4,31(a5)
}
    800069ac:	60e2                	ld	ra,24(sp)
    800069ae:	6442                	ld	s0,16(sp)
    800069b0:	64a2                	ld	s1,8(sp)
    800069b2:	6105                	addi	sp,sp,32
    800069b4:	8082                	ret
    panic("could not find virtio disk");
    800069b6:	00002517          	auipc	a0,0x2
    800069ba:	f1250513          	addi	a0,a0,-238 # 800088c8 <syscalls+0x3c8>
    800069be:	ffffa097          	auipc	ra,0xffffa
    800069c2:	b6c080e7          	jalr	-1172(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    800069c6:	00002517          	auipc	a0,0x2
    800069ca:	f2250513          	addi	a0,a0,-222 # 800088e8 <syscalls+0x3e8>
    800069ce:	ffffa097          	auipc	ra,0xffffa
    800069d2:	b5c080e7          	jalr	-1188(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    800069d6:	00002517          	auipc	a0,0x2
    800069da:	f3250513          	addi	a0,a0,-206 # 80008908 <syscalls+0x408>
    800069de:	ffffa097          	auipc	ra,0xffffa
    800069e2:	b4c080e7          	jalr	-1204(ra) # 8000052a <panic>

00000000800069e6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800069e6:	7119                	addi	sp,sp,-128
    800069e8:	fc86                	sd	ra,120(sp)
    800069ea:	f8a2                	sd	s0,112(sp)
    800069ec:	f4a6                	sd	s1,104(sp)
    800069ee:	f0ca                	sd	s2,96(sp)
    800069f0:	ecce                	sd	s3,88(sp)
    800069f2:	e8d2                	sd	s4,80(sp)
    800069f4:	e4d6                	sd	s5,72(sp)
    800069f6:	e0da                	sd	s6,64(sp)
    800069f8:	fc5e                	sd	s7,56(sp)
    800069fa:	f862                	sd	s8,48(sp)
    800069fc:	f466                	sd	s9,40(sp)
    800069fe:	f06a                	sd	s10,32(sp)
    80006a00:	ec6e                	sd	s11,24(sp)
    80006a02:	0100                	addi	s0,sp,128
    80006a04:	8aaa                	mv	s5,a0
    80006a06:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006a08:	00c52c83          	lw	s9,12(a0)
    80006a0c:	001c9c9b          	slliw	s9,s9,0x1
    80006a10:	1c82                	slli	s9,s9,0x20
    80006a12:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006a16:	0002e517          	auipc	a0,0x2e
    80006a1a:	71250513          	addi	a0,a0,1810 # 80035128 <disk+0x2128>
    80006a1e:	ffffa097          	auipc	ra,0xffffa
    80006a22:	1a4080e7          	jalr	420(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006a26:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006a28:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006a2a:	0002cc17          	auipc	s8,0x2c
    80006a2e:	5d6c0c13          	addi	s8,s8,1494 # 80033000 <disk>
    80006a32:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006a34:	4b0d                	li	s6,3
    80006a36:	a0ad                	j	80006aa0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006a38:	00fc0733          	add	a4,s8,a5
    80006a3c:	975e                	add	a4,a4,s7
    80006a3e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006a42:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006a44:	0207c563          	bltz	a5,80006a6e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006a48:	2905                	addiw	s2,s2,1
    80006a4a:	0611                	addi	a2,a2,4
    80006a4c:	19690d63          	beq	s2,s6,80006be6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006a50:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006a52:	0002e717          	auipc	a4,0x2e
    80006a56:	5c670713          	addi	a4,a4,1478 # 80035018 <disk+0x2018>
    80006a5a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006a5c:	00074683          	lbu	a3,0(a4)
    80006a60:	fee1                	bnez	a3,80006a38 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006a62:	2785                	addiw	a5,a5,1
    80006a64:	0705                	addi	a4,a4,1
    80006a66:	fe979be3          	bne	a5,s1,80006a5c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006a6a:	57fd                	li	a5,-1
    80006a6c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006a6e:	01205d63          	blez	s2,80006a88 <virtio_disk_rw+0xa2>
    80006a72:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006a74:	000a2503          	lw	a0,0(s4)
    80006a78:	00000097          	auipc	ra,0x0
    80006a7c:	d8e080e7          	jalr	-626(ra) # 80006806 <free_desc>
      for(int j = 0; j < i; j++)
    80006a80:	2d85                	addiw	s11,s11,1
    80006a82:	0a11                	addi	s4,s4,4
    80006a84:	ffb918e3          	bne	s2,s11,80006a74 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006a88:	0002e597          	auipc	a1,0x2e
    80006a8c:	6a058593          	addi	a1,a1,1696 # 80035128 <disk+0x2128>
    80006a90:	0002e517          	auipc	a0,0x2e
    80006a94:	58850513          	addi	a0,a0,1416 # 80035018 <disk+0x2018>
    80006a98:	ffffc097          	auipc	ra,0xffffc
    80006a9c:	b84080e7          	jalr	-1148(ra) # 8000261c <sleep>
  for(int i = 0; i < 3; i++){
    80006aa0:	f8040a13          	addi	s4,s0,-128
{
    80006aa4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006aa6:	894e                	mv	s2,s3
    80006aa8:	b765                	j	80006a50 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006aaa:	0002e697          	auipc	a3,0x2e
    80006aae:	5566b683          	ld	a3,1366(a3) # 80035000 <disk+0x2000>
    80006ab2:	96ba                	add	a3,a3,a4
    80006ab4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006ab8:	0002c817          	auipc	a6,0x2c
    80006abc:	54880813          	addi	a6,a6,1352 # 80033000 <disk>
    80006ac0:	0002e697          	auipc	a3,0x2e
    80006ac4:	54068693          	addi	a3,a3,1344 # 80035000 <disk+0x2000>
    80006ac8:	6290                	ld	a2,0(a3)
    80006aca:	963a                	add	a2,a2,a4
    80006acc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006ad0:	0015e593          	ori	a1,a1,1
    80006ad4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006ad8:	f8842603          	lw	a2,-120(s0)
    80006adc:	628c                	ld	a1,0(a3)
    80006ade:	972e                	add	a4,a4,a1
    80006ae0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006ae4:	20050593          	addi	a1,a0,512
    80006ae8:	0592                	slli	a1,a1,0x4
    80006aea:	95c2                	add	a1,a1,a6
    80006aec:	577d                	li	a4,-1
    80006aee:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006af2:	00461713          	slli	a4,a2,0x4
    80006af6:	6290                	ld	a2,0(a3)
    80006af8:	963a                	add	a2,a2,a4
    80006afa:	03078793          	addi	a5,a5,48
    80006afe:	97c2                	add	a5,a5,a6
    80006b00:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006b02:	629c                	ld	a5,0(a3)
    80006b04:	97ba                	add	a5,a5,a4
    80006b06:	4605                	li	a2,1
    80006b08:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006b0a:	629c                	ld	a5,0(a3)
    80006b0c:	97ba                	add	a5,a5,a4
    80006b0e:	4809                	li	a6,2
    80006b10:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006b14:	629c                	ld	a5,0(a3)
    80006b16:	973e                	add	a4,a4,a5
    80006b18:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006b1c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006b20:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006b24:	6698                	ld	a4,8(a3)
    80006b26:	00275783          	lhu	a5,2(a4)
    80006b2a:	8b9d                	andi	a5,a5,7
    80006b2c:	0786                	slli	a5,a5,0x1
    80006b2e:	97ba                	add	a5,a5,a4
    80006b30:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006b34:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006b38:	6698                	ld	a4,8(a3)
    80006b3a:	00275783          	lhu	a5,2(a4)
    80006b3e:	2785                	addiw	a5,a5,1
    80006b40:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006b44:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006b48:	100017b7          	lui	a5,0x10001
    80006b4c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006b50:	004aa783          	lw	a5,4(s5)
    80006b54:	02c79163          	bne	a5,a2,80006b76 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006b58:	0002e917          	auipc	s2,0x2e
    80006b5c:	5d090913          	addi	s2,s2,1488 # 80035128 <disk+0x2128>
  while(b->disk == 1) {
    80006b60:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006b62:	85ca                	mv	a1,s2
    80006b64:	8556                	mv	a0,s5
    80006b66:	ffffc097          	auipc	ra,0xffffc
    80006b6a:	ab6080e7          	jalr	-1354(ra) # 8000261c <sleep>
  while(b->disk == 1) {
    80006b6e:	004aa783          	lw	a5,4(s5)
    80006b72:	fe9788e3          	beq	a5,s1,80006b62 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006b76:	f8042903          	lw	s2,-128(s0)
    80006b7a:	20090793          	addi	a5,s2,512
    80006b7e:	00479713          	slli	a4,a5,0x4
    80006b82:	0002c797          	auipc	a5,0x2c
    80006b86:	47e78793          	addi	a5,a5,1150 # 80033000 <disk>
    80006b8a:	97ba                	add	a5,a5,a4
    80006b8c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006b90:	0002e997          	auipc	s3,0x2e
    80006b94:	47098993          	addi	s3,s3,1136 # 80035000 <disk+0x2000>
    80006b98:	00491713          	slli	a4,s2,0x4
    80006b9c:	0009b783          	ld	a5,0(s3)
    80006ba0:	97ba                	add	a5,a5,a4
    80006ba2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006ba6:	854a                	mv	a0,s2
    80006ba8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006bac:	00000097          	auipc	ra,0x0
    80006bb0:	c5a080e7          	jalr	-934(ra) # 80006806 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006bb4:	8885                	andi	s1,s1,1
    80006bb6:	f0ed                	bnez	s1,80006b98 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006bb8:	0002e517          	auipc	a0,0x2e
    80006bbc:	57050513          	addi	a0,a0,1392 # 80035128 <disk+0x2128>
    80006bc0:	ffffa097          	auipc	ra,0xffffa
    80006bc4:	0b6080e7          	jalr	182(ra) # 80000c76 <release>
}
    80006bc8:	70e6                	ld	ra,120(sp)
    80006bca:	7446                	ld	s0,112(sp)
    80006bcc:	74a6                	ld	s1,104(sp)
    80006bce:	7906                	ld	s2,96(sp)
    80006bd0:	69e6                	ld	s3,88(sp)
    80006bd2:	6a46                	ld	s4,80(sp)
    80006bd4:	6aa6                	ld	s5,72(sp)
    80006bd6:	6b06                	ld	s6,64(sp)
    80006bd8:	7be2                	ld	s7,56(sp)
    80006bda:	7c42                	ld	s8,48(sp)
    80006bdc:	7ca2                	ld	s9,40(sp)
    80006bde:	7d02                	ld	s10,32(sp)
    80006be0:	6de2                	ld	s11,24(sp)
    80006be2:	6109                	addi	sp,sp,128
    80006be4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006be6:	f8042503          	lw	a0,-128(s0)
    80006bea:	20050793          	addi	a5,a0,512
    80006bee:	0792                	slli	a5,a5,0x4
  if(write)
    80006bf0:	0002c817          	auipc	a6,0x2c
    80006bf4:	41080813          	addi	a6,a6,1040 # 80033000 <disk>
    80006bf8:	00f80733          	add	a4,a6,a5
    80006bfc:	01a036b3          	snez	a3,s10
    80006c00:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006c04:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006c08:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006c0c:	7679                	lui	a2,0xffffe
    80006c0e:	963e                	add	a2,a2,a5
    80006c10:	0002e697          	auipc	a3,0x2e
    80006c14:	3f068693          	addi	a3,a3,1008 # 80035000 <disk+0x2000>
    80006c18:	6298                	ld	a4,0(a3)
    80006c1a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006c1c:	0a878593          	addi	a1,a5,168
    80006c20:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006c22:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006c24:	6298                	ld	a4,0(a3)
    80006c26:	9732                	add	a4,a4,a2
    80006c28:	45c1                	li	a1,16
    80006c2a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006c2c:	6298                	ld	a4,0(a3)
    80006c2e:	9732                	add	a4,a4,a2
    80006c30:	4585                	li	a1,1
    80006c32:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006c36:	f8442703          	lw	a4,-124(s0)
    80006c3a:	628c                	ld	a1,0(a3)
    80006c3c:	962e                	add	a2,a2,a1
    80006c3e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffc800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006c42:	0712                	slli	a4,a4,0x4
    80006c44:	6290                	ld	a2,0(a3)
    80006c46:	963a                	add	a2,a2,a4
    80006c48:	058a8593          	addi	a1,s5,88
    80006c4c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006c4e:	6294                	ld	a3,0(a3)
    80006c50:	96ba                	add	a3,a3,a4
    80006c52:	40000613          	li	a2,1024
    80006c56:	c690                	sw	a2,8(a3)
  if(write)
    80006c58:	e40d19e3          	bnez	s10,80006aaa <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006c5c:	0002e697          	auipc	a3,0x2e
    80006c60:	3a46b683          	ld	a3,932(a3) # 80035000 <disk+0x2000>
    80006c64:	96ba                	add	a3,a3,a4
    80006c66:	4609                	li	a2,2
    80006c68:	00c69623          	sh	a2,12(a3)
    80006c6c:	b5b1                	j	80006ab8 <virtio_disk_rw+0xd2>

0000000080006c6e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006c6e:	1101                	addi	sp,sp,-32
    80006c70:	ec06                	sd	ra,24(sp)
    80006c72:	e822                	sd	s0,16(sp)
    80006c74:	e426                	sd	s1,8(sp)
    80006c76:	e04a                	sd	s2,0(sp)
    80006c78:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006c7a:	0002e517          	auipc	a0,0x2e
    80006c7e:	4ae50513          	addi	a0,a0,1198 # 80035128 <disk+0x2128>
    80006c82:	ffffa097          	auipc	ra,0xffffa
    80006c86:	f40080e7          	jalr	-192(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006c8a:	10001737          	lui	a4,0x10001
    80006c8e:	533c                	lw	a5,96(a4)
    80006c90:	8b8d                	andi	a5,a5,3
    80006c92:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006c94:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006c98:	0002e797          	auipc	a5,0x2e
    80006c9c:	36878793          	addi	a5,a5,872 # 80035000 <disk+0x2000>
    80006ca0:	6b94                	ld	a3,16(a5)
    80006ca2:	0207d703          	lhu	a4,32(a5)
    80006ca6:	0026d783          	lhu	a5,2(a3)
    80006caa:	06f70163          	beq	a4,a5,80006d0c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006cae:	0002c917          	auipc	s2,0x2c
    80006cb2:	35290913          	addi	s2,s2,850 # 80033000 <disk>
    80006cb6:	0002e497          	auipc	s1,0x2e
    80006cba:	34a48493          	addi	s1,s1,842 # 80035000 <disk+0x2000>
    __sync_synchronize();
    80006cbe:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006cc2:	6898                	ld	a4,16(s1)
    80006cc4:	0204d783          	lhu	a5,32(s1)
    80006cc8:	8b9d                	andi	a5,a5,7
    80006cca:	078e                	slli	a5,a5,0x3
    80006ccc:	97ba                	add	a5,a5,a4
    80006cce:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006cd0:	20078713          	addi	a4,a5,512
    80006cd4:	0712                	slli	a4,a4,0x4
    80006cd6:	974a                	add	a4,a4,s2
    80006cd8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006cdc:	e731                	bnez	a4,80006d28 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006cde:	20078793          	addi	a5,a5,512
    80006ce2:	0792                	slli	a5,a5,0x4
    80006ce4:	97ca                	add	a5,a5,s2
    80006ce6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006ce8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006cec:	ffffc097          	auipc	ra,0xffffc
    80006cf0:	abc080e7          	jalr	-1348(ra) # 800027a8 <wakeup>

    disk.used_idx += 1;
    80006cf4:	0204d783          	lhu	a5,32(s1)
    80006cf8:	2785                	addiw	a5,a5,1
    80006cfa:	17c2                	slli	a5,a5,0x30
    80006cfc:	93c1                	srli	a5,a5,0x30
    80006cfe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006d02:	6898                	ld	a4,16(s1)
    80006d04:	00275703          	lhu	a4,2(a4)
    80006d08:	faf71be3          	bne	a4,a5,80006cbe <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006d0c:	0002e517          	auipc	a0,0x2e
    80006d10:	41c50513          	addi	a0,a0,1052 # 80035128 <disk+0x2128>
    80006d14:	ffffa097          	auipc	ra,0xffffa
    80006d18:	f62080e7          	jalr	-158(ra) # 80000c76 <release>
}
    80006d1c:	60e2                	ld	ra,24(sp)
    80006d1e:	6442                	ld	s0,16(sp)
    80006d20:	64a2                	ld	s1,8(sp)
    80006d22:	6902                	ld	s2,0(sp)
    80006d24:	6105                	addi	sp,sp,32
    80006d26:	8082                	ret
      panic("virtio_disk_intr status");
    80006d28:	00002517          	auipc	a0,0x2
    80006d2c:	c0050513          	addi	a0,a0,-1024 # 80008928 <syscalls+0x428>
    80006d30:	ffff9097          	auipc	ra,0xffff9
    80006d34:	7fa080e7          	jalr	2042(ra) # 8000052a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
