
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
    80000064:	00007797          	auipc	a5,0x7
    80000068:	83c78793          	addi	a5,a5,-1988 # 800068a0 <timervec>
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
    80000122:	a72080e7          	jalr	-1422(ra) # 80002b90 <either_copyin>
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
    800001b6:	e0e080e7          	jalr	-498(ra) # 80001fc0 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	5b4080e7          	jalr	1460(ra) # 80002776 <sleep>
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
    800001fe:	00003097          	auipc	ra,0x3
    80000202:	93c080e7          	jalr	-1732(ra) # 80002b3a <either_copyout>
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
    800002de:	00003097          	auipc	ra,0x3
    800002e2:	908080e7          	jalr	-1784(ra) # 80002be6 <procdump>
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
    80000436:	4d0080e7          	jalr	1232(ra) # 80002902 <wakeup>
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
    8000055c:	c9050513          	addi	a0,a0,-880 # 800081e8 <digits+0x1a8>
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
    80000882:	084080e7          	jalr	132(ra) # 80002902 <wakeup>
    
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
    8000090e:	e6c080e7          	jalr	-404(ra) # 80002776 <sleep>
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
    80000b60:	448080e7          	jalr	1096(ra) # 80001fa4 <mycpu>
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
    80000b92:	416080e7          	jalr	1046(ra) # 80001fa4 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	40a080e7          	jalr	1034(ra) # 80001fa4 <mycpu>
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
    80000bb6:	3f2080e7          	jalr	1010(ra) # 80001fa4 <mycpu>
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
    80000bf6:	3b2080e7          	jalr	946(ra) # 80001fa4 <mycpu>
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
    80000c22:	386080e7          	jalr	902(ra) # 80001fa4 <mycpu>
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
    80000e78:	120080e7          	jalr	288(ra) # 80001f94 <cpuid>
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
    80000e94:	104080e7          	jalr	260(ra) # 80001f94 <cpuid>
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
    80000eb6:	e76080e7          	jalr	-394(ra) # 80002d28 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	a26080e7          	jalr	-1498(ra) # 800068e0 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	702080e7          	jalr	1794(ra) # 800025c4 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	30e50513          	addi	a0,a0,782 # 800081e8 <digits+0x1a8>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	2ee50513          	addi	a0,a0,750 # 800081e8 <digits+0x1a8>
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
    80000f26:	fc2080e7          	jalr	-62(ra) # 80001ee4 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	dd6080e7          	jalr	-554(ra) # 80002d00 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	df6080e7          	jalr	-522(ra) # 80002d28 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	990080e7          	jalr	-1648(ra) # 800068ca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	99e080e7          	jalr	-1634(ra) # 800068e0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	5f2080e7          	jalr	1522(ra) # 8000353c <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	c84080e7          	jalr	-892(ra) # 80003bd6 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	f7a080e7          	jalr	-134(ra) # 80004ed4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	aa0080e7          	jalr	-1376(ra) # 80006a02 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	386080e7          	jalr	902(ra) # 800022f0 <userinit>
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
    80000f8c:	0a07b783          	ld	a5,160(a5) # 80009028 <kernel_pagetable>
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
    80001210:	c42080e7          	jalr	-958(ra) # 80001e4e <proc_mapstacks>
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
    80001236:	dea7bb23          	sd	a0,-522(a5) # 80009028 <kernel_pagetable>
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
    8000160a:	9ba080e7          	jalr	-1606(ra) # 80001fc0 <myproc>
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

0000000080001666 <pick_page_to_swap_>:
  // refresh TLB
  sfence_vma();
}

struct page* pick_page_to_swap_(pagetable_t pagetable)
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
    80001678:	00001097          	auipc	ra,0x1
    8000167c:	948080e7          	jalr	-1720(ra) # 80001fc0 <myproc>
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
    8000168c:	a029                	j	80001696 <pick_page_to_swap_+0x30>
  for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    8000168e:	02048493          	addi	s1,s1,32
    80001692:	05248063          	beq	s1,s2,800016d2 <pick_page_to_swap_+0x6c>
    if (pg->used)
    80001696:	4c9c                	lw	a5,24(s1)
    80001698:	dbfd                	beqz	a5,8000168e <pick_page_to_swap_+0x28>
      if (pg->va == 4096 || pg->va == 0)
    8000169a:	648c                	ld	a1,8(s1)
    8000169c:	0135f7b3          	and	a5,a1,s3
    800016a0:	d7fd                	beqz	a5,8000168e <pick_page_to_swap_+0x28>
        continue; //we dont want to swap text page
      pte_t* pte = walk(pagetable, pg->va, 0);
    800016a2:	4601                	li	a2,0
    800016a4:	8552                	mv	a0,s4
    800016a6:	00000097          	auipc	ra,0x0
    800016aa:	900080e7          	jalr	-1792(ra) # 80000fa6 <walk>
      if ((*pte & PTE_V)) // if valid page
    800016ae:	611c                	ld	a5,0(a0)
    800016b0:	0017f713          	andi	a4,a5,1
    800016b4:	df69                	beqz	a4,8000168e <pick_page_to_swap_+0x28>
      {
        if ((*pte & PTE_PG) == 0) // and page is not pages out
    800016b6:	2007f713          	andi	a4,a5,512
    800016ba:	fb71                	bnez	a4,8000168e <pick_page_to_swap_+0x28>
        {
          if(*pte & PTE_U)  // and its a user page
    800016bc:	8bc1                	andi	a5,a5,16
    800016be:	dbe1                	beqz	a5,8000168e <pick_page_to_swap_+0x28>
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

00000000800016e2 <find_fifo_page>:
  panic("no selection picked!");
  return 0;
}

struct page* find_fifo_page(pagetable_t pagetable)
{
    800016e2:	7129                	addi	sp,sp,-320
    800016e4:	fe06                	sd	ra,312(sp)
    800016e6:	fa22                	sd	s0,304(sp)
    800016e8:	f626                	sd	s1,296(sp)
    800016ea:	f24a                	sd	s2,288(sp)
    800016ec:	ee4e                	sd	s3,280(sp)
    800016ee:	ea52                	sd	s4,272(sp)
    800016f0:	e656                	sd	s5,264(sp)
    800016f2:	e25a                	sd	s6,256(sp)
    800016f4:	0280                	addi	s0,sp,320
    800016f6:	84aa                	mv	s1,a0
  struct proc* p = myproc();
    800016f8:	00001097          	auipc	ra,0x1
    800016fc:	8c8080e7          	jalr	-1848(ra) # 80001fc0 <myproc>
  static int index = 0;
  //initalize the array that will be sorted next.
  struct page *arr[MAX_TOTAL_PAGES];
  for(int i = 0; i < MAX_TOTAL_PAGES; i++)
    80001700:	17050713          	addi	a4,a0,368
    80001704:	ec040913          	addi	s2,s0,-320
    80001708:	fc040993          	addi	s3,s0,-64
  struct proc* p = myproc();
    8000170c:	87ca                	mv	a5,s2
  {
    arr[i] = &p->pages[i];
    8000170e:	e398                	sd	a4,0(a5)
  for(int i = 0; i < MAX_TOTAL_PAGES; i++)
    80001710:	02070713          	addi	a4,a4,32
    80001714:	07a1                	addi	a5,a5,8
    80001716:	ff379ce3          	bne	a5,s3,8000170e <find_fifo_page+0x2c>
    8000171a:	ec840813          	addi	a6,s0,-312
    8000171e:	4885                	li	a7,1
  }
  //use buble sort by the page's time field.
  for (int i = 0 ; i < MAX_TOTAL_PAGES - 1; i++)
  {
    for (int j = i + 1 ; j< MAX_TOTAL_PAGES ; j++)
    80001720:	4e7d                	li	t3,31
    80001722:	10090513          	addi	a0,s2,256 # 1100 <_entry-0x7fffef00>
  for (int i = 0 ; i < MAX_TOTAL_PAGES - 1; i++)
    80001726:	02000313          	li	t1,32
    8000172a:	a01d                	j	80001750 <find_fifo_page+0x6e>
    for (int j = i + 1 ; j< MAX_TOTAL_PAGES ; j++)
    8000172c:	07a1                	addi	a5,a5,8
    8000172e:	00a78d63          	beq	a5,a0,80001748 <find_fifo_page+0x66>
    {
        if(arr[i]->time > arr[j]->time)
    80001732:	ff883703          	ld	a4,-8(a6) # fff8 <_entry-0x7fff0008>
    80001736:	6394                	ld	a3,0(a5)
    80001738:	4f4c                	lw	a1,28(a4)
    8000173a:	4ed0                	lw	a2,28(a3)
    8000173c:	feb678e3          	bgeu	a2,a1,8000172c <find_fifo_page+0x4a>
        {
            struct page* temp = arr[i];
            arr[i] = arr[j];
    80001740:	fed83c23          	sd	a3,-8(a6)
            arr[j] = temp;
    80001744:	e398                	sd	a4,0(a5)
    80001746:	b7dd                	j	8000172c <find_fifo_page+0x4a>
  for (int i = 0 ; i < MAX_TOTAL_PAGES - 1; i++)
    80001748:	0885                	addi	a7,a7,1
    8000174a:	0821                	addi	a6,a6,8
    8000174c:	00688863          	beq	a7,t1,8000175c <find_fifo_page+0x7a>
    for (int j = i + 1 ; j< MAX_TOTAL_PAGES ; j++)
    80001750:	0008879b          	sext.w	a5,a7
    80001754:	fefe4ae3          	blt	t3,a5,80001748 <find_fifo_page+0x66>
    80001758:	87c2                	mv	a5,a6
    8000175a:	bfe1                	j	80001732 <find_fifo_page+0x50>
  }

  //TODO:DELETE! just to see if the sort worked..  
  for(int i = 0; i < MAX_TOTAL_PAGES; i++)
  {
    printf(" va:%d, time:%d used:%s, on_disk:%s,\n", arr[i]->va, arr[i]->time, arr[i]->used ? "true" : "false",arr[i]->on_disk ? "true" : "false" );
    8000175c:	00007a17          	auipc	s4,0x7
    80001760:	9fca0a13          	addi	s4,s4,-1540 # 80008158 <digits+0x118>
    80001764:	00007b17          	auipc	s6,0x7
    80001768:	9fcb0b13          	addi	s6,s6,-1540 # 80008160 <digits+0x120>
    8000176c:	00007a97          	auipc	s5,0x7
    80001770:	9fca8a93          	addi	s5,s5,-1540 # 80008168 <digits+0x128>
    80001774:	a809                	j	80001786 <find_fifo_page+0xa4>
    80001776:	8556                	mv	a0,s5
    80001778:	fffff097          	auipc	ra,0xfffff
    8000177c:	dfc080e7          	jalr	-516(ra) # 80000574 <printf>
  for(int i = 0; i < MAX_TOTAL_PAGES; i++)
    80001780:	0921                	addi	s2,s2,8
    80001782:	01390f63          	beq	s2,s3,800017a0 <find_fifo_page+0xbe>
    printf(" va:%d, time:%d used:%s, on_disk:%s,\n", arr[i]->va, arr[i]->time, arr[i]->used ? "true" : "false",arr[i]->on_disk ? "true" : "false" );
    80001786:	00093783          	ld	a5,0(s2)
    8000178a:	678c                	ld	a1,8(a5)
    8000178c:	4fd0                	lw	a2,28(a5)
    8000178e:	4f98                	lw	a4,24(a5)
    80001790:	86d2                	mv	a3,s4
    80001792:	e311                	bnez	a4,80001796 <find_fifo_page+0xb4>
    80001794:	86da                	mv	a3,s6
    80001796:	4b9c                	lw	a5,16(a5)
    80001798:	8752                	mv	a4,s4
    8000179a:	fff1                	bnez	a5,80001776 <find_fifo_page+0x94>
    8000179c:	875a                	mv	a4,s6
    8000179e:	bfe1                	j	80001776 <find_fifo_page+0x94>
  }

  for(int i = 0; i < MAX_TOTAL_PAGES; i++)
    800017a0:	4901                	li	s2,0
  {
    struct page *pg = arr[(i + index)% MAX_TOTAL_PAGES];
    800017a2:	00008a17          	auipc	s4,0x8
    800017a6:	87ea0a13          	addi	s4,s4,-1922 # 80009020 <index.0>
    pte_t* pte = walk(pagetable, pg->va, 0);
    if (pg->used && !pg->on_disk)
    {
      if ((*pte & PTE_V))
      {
        if (*pte & PTE_U)
    800017aa:	4ac5                	li	s5,17
  for(int i = 0; i < MAX_TOTAL_PAGES; i++)
    800017ac:	02000993          	li	s3,32
    800017b0:	a021                	j	800017b8 <find_fifo_page+0xd6>
    800017b2:	2905                	addiw	s2,s2,1
    800017b4:	05390d63          	beq	s2,s3,8000180e <find_fifo_page+0x12c>
    struct page *pg = arr[(i + index)% MAX_TOTAL_PAGES];
    800017b8:	000a2783          	lw	a5,0(s4)
    800017bc:	012787bb          	addw	a5,a5,s2
    800017c0:	41f7d71b          	sraiw	a4,a5,0x1f
    800017c4:	01b7571b          	srliw	a4,a4,0x1b
    800017c8:	9fb9                	addw	a5,a5,a4
    800017ca:	8bfd                	andi	a5,a5,31
    800017cc:	9f99                	subw	a5,a5,a4
    800017ce:	078e                	slli	a5,a5,0x3
    800017d0:	fc040713          	addi	a4,s0,-64
    800017d4:	97ba                	add	a5,a5,a4
    800017d6:	f007bb03          	ld	s6,-256(a5)
    pte_t* pte = walk(pagetable, pg->va, 0);
    800017da:	4601                	li	a2,0
    800017dc:	008b3583          	ld	a1,8(s6)
    800017e0:	8526                	mv	a0,s1
    800017e2:	fffff097          	auipc	ra,0xfffff
    800017e6:	7c4080e7          	jalr	1988(ra) # 80000fa6 <walk>
    if (pg->used && !pg->on_disk)
    800017ea:	018b2783          	lw	a5,24(s6)
    800017ee:	d3f1                	beqz	a5,800017b2 <find_fifo_page+0xd0>
    800017f0:	010b2783          	lw	a5,16(s6)
    800017f4:	ffdd                	bnez	a5,800017b2 <find_fifo_page+0xd0>
      if ((*pte & PTE_V))
    800017f6:	611c                	ld	a5,0(a0)
        if (*pte & PTE_U)
    800017f8:	0117f713          	andi	a4,a5,17
    800017fc:	fb571be3          	bne	a4,s5,800017b2 <find_fifo_page+0xd0>
        {
          if(*pte & PTE_A)
    80001800:	0407f713          	andi	a4,a5,64
    80001804:	cf09                	beqz	a4,8000181e <find_fifo_page+0x13c>
          {
            *pte = *pte ^ PTE_A;
    80001806:	0407c793          	xori	a5,a5,64
    8000180a:	e11c                	sd	a5,0(a0)
    8000180c:	b75d                	j	800017b2 <find_fifo_page+0xd0>
          }
        }
      }
    }
  }
  panic("find_fifo_page: no page was found!");
    8000180e:	00007517          	auipc	a0,0x7
    80001812:	98250513          	addi	a0,a0,-1662 # 80008190 <digits+0x150>
    80001816:	fffff097          	auipc	ra,0xfffff
    8000181a:	d14080e7          	jalr	-748(ra) # 8000052a <panic>
            index = i;
    8000181e:	00008797          	auipc	a5,0x8
    80001822:	8127a123          	sw	s2,-2046(a5) # 80009020 <index.0>
}
    80001826:	855a                	mv	a0,s6
    80001828:	70f2                	ld	ra,312(sp)
    8000182a:	7452                	ld	s0,304(sp)
    8000182c:	74b2                	ld	s1,296(sp)
    8000182e:	7912                	ld	s2,288(sp)
    80001830:	69f2                	ld	s3,280(sp)
    80001832:	6a52                	ld	s4,272(sp)
    80001834:	6ab2                	ld	s5,264(sp)
    80001836:	6b12                	ld	s6,256(sp)
    80001838:	6131                	addi	sp,sp,320
    8000183a:	8082                	ret

000000008000183c <pick_page_to_swap>:
{
    8000183c:	1141                	addi	sp,sp,-16
    8000183e:	e406                	sd	ra,8(sp)
    80001840:	e022                	sd	s0,0(sp)
    80001842:	0800                	addi	s0,sp,16
        return find_fifo_page(pagetable);
    80001844:	00000097          	auipc	ra,0x0
    80001848:	e9e080e7          	jalr	-354(ra) # 800016e2 <find_fifo_page>
}
    8000184c:	60a2                	ld	ra,8(sp)
    8000184e:	6402                	ld	s0,0(sp)
    80001850:	0141                	addi	sp,sp,16
    80001852:	8082                	ret

0000000080001854 <page_swap_out>:
{
    80001854:	7139                	addi	sp,sp,-64
    80001856:	fc06                	sd	ra,56(sp)
    80001858:	f822                	sd	s0,48(sp)
    8000185a:	f426                	sd	s1,40(sp)
    8000185c:	f04a                	sd	s2,32(sp)
    8000185e:	ec4e                	sd	s3,24(sp)
    80001860:	e852                	sd	s4,16(sp)
    80001862:	e456                	sd	s5,8(sp)
    80001864:	0080                	addi	s0,sp,64
    80001866:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80001868:	00000097          	auipc	ra,0x0
    8000186c:	758080e7          	jalr	1880(ra) # 80001fc0 <myproc>
    80001870:	8aaa                	mv	s5,a0
        return find_fifo_page(pagetable);
    80001872:	854a                	mv	a0,s2
    80001874:	00000097          	auipc	ra,0x0
    80001878:	e6e080e7          	jalr	-402(ra) # 800016e2 <find_fifo_page>
    8000187c:	84aa                	mv	s1,a0
  uint offset = get_offset();
    8000187e:	00000097          	auipc	ra,0x0
    80001882:	d80080e7          	jalr	-640(ra) # 800015fe <get_offset>
    80001886:	00050a1b          	sext.w	s4,a0
  uint64 pa = walkaddr(pagetable, pg_to_swap->va);
    8000188a:	648c                	ld	a1,8(s1)
    8000188c:	854a                	mv	a0,s2
    8000188e:	fffff097          	auipc	ra,0xfffff
    80001892:	7be080e7          	jalr	1982(ra) # 8000104c <walkaddr>
    80001896:	89aa                	mv	s3,a0
  writeToSwapFile(p, (char*) pa, offset, PGSIZE);
    80001898:	6685                	lui	a3,0x1
    8000189a:	8652                	mv	a2,s4
    8000189c:	85aa                	mv	a1,a0
    8000189e:	8556                	mv	a0,s5
    800018a0:	00003097          	auipc	ra,0x3
    800018a4:	01e080e7          	jalr	30(ra) # 800048be <writeToSwapFile>
  pg_to_swap->on_disk = 1;
    800018a8:	4785                	li	a5,1
    800018aa:	c89c                	sw	a5,16(s1)
  pg_to_swap->offset = offset;
    800018ac:	0144aa23          	sw	s4,20(s1)
  kfree((void*)pa);
    800018b0:	854e                	mv	a0,s3
    800018b2:	fffff097          	auipc	ra,0xfffff
    800018b6:	124080e7          	jalr	292(ra) # 800009d6 <kfree>
  pte_t* pte = walk(pagetable, pg_to_swap->va, 0);
    800018ba:	4601                	li	a2,0
    800018bc:	648c                	ld	a1,8(s1)
    800018be:	854a                	mv	a0,s2
    800018c0:	fffff097          	auipc	ra,0xfffff
    800018c4:	6e6080e7          	jalr	1766(ra) # 80000fa6 <walk>
  *pte = (*pte | PTE_PG) ^ PTE_V;
    800018c8:	611c                	ld	a5,0(a0)
    800018ca:	2007e793          	ori	a5,a5,512
    800018ce:	0017c793          	xori	a5,a5,1
    800018d2:	e11c                	sd	a5,0(a0)
    800018d4:	12000073          	sfence.vma
}
    800018d8:	70e2                	ld	ra,56(sp)
    800018da:	7442                	ld	s0,48(sp)
    800018dc:	74a2                	ld	s1,40(sp)
    800018de:	7902                	ld	s2,32(sp)
    800018e0:	69e2                	ld	s3,24(sp)
    800018e2:	6a42                	ld	s4,16(sp)
    800018e4:	6aa2                	ld	s5,8(sp)
    800018e6:	6121                	addi	sp,sp,64
    800018e8:	8082                	ret

00000000800018ea <page_swap_in>:
// returns -1 if kalloc failed 
// returns -2 if va not on disk
// returns -3 if va not aligned
// va must be aligned to the first va of the requested page
int page_swap_in(pagetable_t pagetable, uint64 va, struct proc *p)
{
    800018ea:	7179                	addi	sp,sp,-48
    800018ec:	f406                	sd	ra,40(sp)
    800018ee:	f022                	sd	s0,32(sp)
    800018f0:	ec26                	sd	s1,24(sp)
    800018f2:	e84a                	sd	s2,16(sp)
    800018f4:	e44e                	sd	s3,8(sp)
    800018f6:	e052                	sd	s4,0(sp)
    800018f8:	1800                	addi	s0,sp,48
    800018fa:	8a2a                	mv	s4,a0
    800018fc:	89b2                	mv	s3,a2
  //printf("pid:%d swapping in page starting at va:%d\n",p->pid,  va);
  struct page* pg;
  for ( pg =p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)  
    800018fe:	17060493          	addi	s1,a2,368 # 1170 <_entry-0x7fffee90>
    80001902:	57060713          	addi	a4,a2,1392
  {
    if (pg->va == va) // found relevant page
    80001906:	649c                	ld	a5,8(s1)
    80001908:	00b78863          	beq	a5,a1,80001918 <page_swap_in+0x2e>
  for ( pg =p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)  
    8000190c:	02048493          	addi	s1,s1,32
    80001910:	fee49be3          	bne	s1,a4,80001906 <page_swap_in+0x1c>
      *pte = (PA2PTE(mem) | perm);
      return 0;
  
    }
  }
  return -3;
    80001914:	5575                	li	a0,-3
    80001916:	a085                	j	80001976 <page_swap_in+0x8c>
      if (pg->on_disk == 0)
    80001918:	489c                	lw	a5,16(s1)
    8000191a:	cfa5                	beqz	a5,80001992 <page_swap_in+0xa8>
      if (countmemory(p->pagetable) >= MAX_PSYC_PAGES)
    8000191c:	0509b503          	ld	a0,80(s3) # fffffffffffff050 <end+0xffffffff7ffc9050>
    80001920:	00000097          	auipc	ra,0x0
    80001924:	c2c080e7          	jalr	-980(ra) # 8000154c <countmemory>
    80001928:	47bd                	li	a5,15
    8000192a:	04a7ce63          	blt	a5,a0,80001986 <page_swap_in+0x9c>
      char* mem = kalloc();
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	1a4080e7          	jalr	420(ra) # 80000ad2 <kalloc>
    80001936:	892a                	mv	s2,a0
      if(mem == 0)
    80001938:	cd39                	beqz	a0,80001996 <page_swap_in+0xac>
      readFromSwapFile(p, mem, pg->offset, PGSIZE);
    8000193a:	6685                	lui	a3,0x1
    8000193c:	48d0                	lw	a2,20(s1)
    8000193e:	85aa                	mv	a1,a0
    80001940:	854e                	mv	a0,s3
    80001942:	00003097          	auipc	ra,0x3
    80001946:	fa0080e7          	jalr	-96(ra) # 800048e2 <readFromSwapFile>
      pg->on_disk = 0;
    8000194a:	0004a823          	sw	zero,16(s1)
      pte_t* pte = walk(pagetable, pg->va, 0);
    8000194e:	4601                	li	a2,0
    80001950:	648c                	ld	a1,8(s1)
    80001952:	8552                	mv	a0,s4
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	652080e7          	jalr	1618(ra) # 80000fa6 <walk>
      int perm = (*pte) & 1023; //gives the lower 10bits (permissions)
    8000195c:	6118                	ld	a4,0(a0)
    8000195e:	3ff77713          	andi	a4,a4,1023
      perm = (perm ^ PTE_PG) | PTE_V; // turn off pg flag and turn on valid
    80001962:	20074713          	xori	a4,a4,512
      *pte = (PA2PTE(mem) | perm);
    80001966:	00c95793          	srli	a5,s2,0xc
    8000196a:	07aa                	slli	a5,a5,0xa
    8000196c:	00176713          	ori	a4,a4,1
    80001970:	8fd9                	or	a5,a5,a4
    80001972:	e11c                	sd	a5,0(a0)
      return 0;
    80001974:	4501                	li	a0,0
}
    80001976:	70a2                	ld	ra,40(sp)
    80001978:	7402                	ld	s0,32(sp)
    8000197a:	64e2                	ld	s1,24(sp)
    8000197c:	6942                	ld	s2,16(sp)
    8000197e:	69a2                	ld	s3,8(sp)
    80001980:	6a02                	ld	s4,0(sp)
    80001982:	6145                	addi	sp,sp,48
    80001984:	8082                	ret
          page_swap_out(pagetable);
    80001986:	8552                	mv	a0,s4
    80001988:	00000097          	auipc	ra,0x0
    8000198c:	ecc080e7          	jalr	-308(ra) # 80001854 <page_swap_out>
    80001990:	bf79                	j	8000192e <page_swap_in+0x44>
        return -2;
    80001992:	5579                	li	a0,-2
    80001994:	b7cd                	j	80001976 <page_swap_in+0x8c>
        return -1;
    80001996:	557d                	li	a0,-1
    80001998:	bff9                	j	80001976 <page_swap_in+0x8c>

000000008000199a <print_pages>:
  printf("pages in memory:%d\n", countmemory(p->pagetable));
  print_pages(p->pagetable);
}

void print_pages(pagetable_t pagetable)
{
    8000199a:	7179                	addi	sp,sp,-48
    8000199c:	f406                	sd	ra,40(sp)
    8000199e:	f022                	sd	s0,32(sp)
    800019a0:	ec26                	sd	s1,24(sp)
    800019a2:	e84a                	sd	s2,16(sp)
    800019a4:	e44e                	sd	s3,8(sp)
    800019a6:	1800                	addi	s0,sp,48
   struct proc* p = myproc();
    800019a8:	00000097          	auipc	ra,0x0
    800019ac:	618080e7          	jalr	1560(ra) # 80001fc0 <myproc>
   struct page* pg;
   for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    800019b0:	17050493          	addi	s1,a0,368
    800019b4:	57050913          	addi	s2,a0,1392
      printf("va : %d, on disk: %d ,  offset : %d , used : %d \n",pg->va , pg->on_disk , pg->offset , pg->used);
    800019b8:	00007997          	auipc	s3,0x7
    800019bc:	80098993          	addi	s3,s3,-2048 # 800081b8 <digits+0x178>
    800019c0:	4c98                	lw	a4,24(s1)
    800019c2:	48d4                	lw	a3,20(s1)
    800019c4:	4890                	lw	a2,16(s1)
    800019c6:	648c                	ld	a1,8(s1)
    800019c8:	854e                	mv	a0,s3
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	baa080e7          	jalr	-1110(ra) # 80000574 <printf>
   for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    800019d2:	02048493          	addi	s1,s1,32
    800019d6:	fe9915e3          	bne	s2,s1,800019c0 <print_pages+0x26>
  //   else if((*pte & PTE_V) || ((*pte & PTE_PG)))
  //   {
  //     printf("pte address of pid %d = %p\n",myproc()->pid, pte);
  //   }
  // }
}
    800019da:	70a2                	ld	ra,40(sp)
    800019dc:	7402                	ld	s0,32(sp)
    800019de:	64e2                	ld	s1,24(sp)
    800019e0:	6942                	ld	s2,16(sp)
    800019e2:	69a2                	ld	s3,8(sp)
    800019e4:	6145                	addi	sp,sp,48
    800019e6:	8082                	ret

00000000800019e8 <ppages>:
{
    800019e8:	1101                	addi	sp,sp,-32
    800019ea:	ec06                	sd	ra,24(sp)
    800019ec:	e822                	sd	s0,16(sp)
    800019ee:	e426                	sd	s1,8(sp)
    800019f0:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    800019f2:	00000097          	auipc	ra,0x0
    800019f6:	5ce080e7          	jalr	1486(ra) # 80001fc0 <myproc>
    800019fa:	84aa                	mv	s1,a0
  printf("total pages:%d\n", counttotal(p->pagetable));
    800019fc:	6928                	ld	a0,80(a0)
    800019fe:	00000097          	auipc	ra,0x0
    80001a02:	ba8080e7          	jalr	-1112(ra) # 800015a6 <counttotal>
    80001a06:	85aa                	mv	a1,a0
    80001a08:	00006517          	auipc	a0,0x6
    80001a0c:	7e850513          	addi	a0,a0,2024 # 800081f0 <digits+0x1b0>
    80001a10:	fffff097          	auipc	ra,0xfffff
    80001a14:	b64080e7          	jalr	-1180(ra) # 80000574 <printf>
  printf("pages in memory:%d\n", countmemory(p->pagetable));
    80001a18:	68a8                	ld	a0,80(s1)
    80001a1a:	00000097          	auipc	ra,0x0
    80001a1e:	b32080e7          	jalr	-1230(ra) # 8000154c <countmemory>
    80001a22:	85aa                	mv	a1,a0
    80001a24:	00006517          	auipc	a0,0x6
    80001a28:	7dc50513          	addi	a0,a0,2012 # 80008200 <digits+0x1c0>
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	b48080e7          	jalr	-1208(ra) # 80000574 <printf>
  print_pages(p->pagetable);
    80001a34:	68a8                	ld	a0,80(s1)
    80001a36:	00000097          	auipc	ra,0x0
    80001a3a:	f64080e7          	jalr	-156(ra) # 8000199a <print_pages>
}
    80001a3e:	60e2                	ld	ra,24(sp)
    80001a40:	6442                	ld	s0,16(sp)
    80001a42:	64a2                	ld	s1,8(sp)
    80001a44:	6105                	addi	sp,sp,32
    80001a46:	8082                	ret

0000000080001a48 <add_page>:


// find unused page struct in p->pages and set its va
void add_page(pagetable_t pagetable, uint64 va)
{
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	e04a                	sd	s2,0(sp)
    80001a52:	1000                	addi	s0,sp,32
    80001a54:	892a                	mv	s2,a0
    80001a56:	84ae                	mv	s1,a1
  struct proc* p = myproc();
    80001a58:	00000097          	auipc	ra,0x0
    80001a5c:	568080e7          	jalr	1384(ra) # 80001fc0 <myproc>
  if (p->pid > 1) // we want the shell process to add pages to sub processes so > 1 and not > 2
    80001a60:	5918                	lw	a4,48(a0)
    80001a62:	4785                	li	a5,1
    80001a64:	02e7d763          	bge	a5,a4,80001a92 <add_page+0x4a>
  {
    struct page* pg;
    for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80001a68:	17050793          	addi	a5,a0,368
    80001a6c:	57050693          	addi	a3,a0,1392
    {
      if (pg->used == 0)
    80001a70:	4f98                	lw	a4,24(a5)
    80001a72:	c711                	beqz	a4,80001a7e <add_page+0x36>
    for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80001a74:	02078793          	addi	a5,a5,32
    80001a78:	fed79ce3          	bne	a5,a3,80001a70 <add_page+0x28>
    80001a7c:	a819                	j	80001a92 <add_page+0x4a>
      {
        pg->pagetable = pagetable;
    80001a7e:	0127b023          	sd	s2,0(a5)
        pg->used = 1;
    80001a82:	4705                	li	a4,1
    80001a84:	cf98                	sw	a4,24(a5)
        pg->va = va;
    80001a86:	e784                	sd	s1,8(a5)
        pg->time = ticks;
    80001a88:	00007717          	auipc	a4,0x7
    80001a8c:	5b072703          	lw	a4,1456(a4) # 80009038 <ticks>
    80001a90:	cfd8                	sw	a4,28(a5)
        return;
      }
    } 
  }
}
    80001a92:	60e2                	ld	ra,24(sp)
    80001a94:	6442                	ld	s0,16(sp)
    80001a96:	64a2                	ld	s1,8(sp)
    80001a98:	6902                	ld	s2,0(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <remove_page>:

void remove_page(pagetable_t pagetable, uint64 va)
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	1000                	addi	s0,sp,32
    80001aa8:	84ae                	mv	s1,a1
  struct proc* p = myproc();
    80001aaa:	00000097          	auipc	ra,0x0
    80001aae:	516080e7          	jalr	1302(ra) # 80001fc0 <myproc>
  if (p->pid > 2)
    80001ab2:	5918                	lw	a4,48(a0)
    80001ab4:	4789                	li	a5,2
    80001ab6:	02e7dc63          	bge	a5,a4,80001aee <remove_page+0x50>
  {
  struct page* pg;
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80001aba:	17050793          	addi	a5,a0,368
    80001abe:	57050693          	addi	a3,a0,1392
  {
    if (pg->used == 1)
    80001ac2:	4605                	li	a2,1
    80001ac4:	a029                	j	80001ace <remove_page+0x30>
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80001ac6:	02078793          	addi	a5,a5,32
    80001aca:	02d78263          	beq	a5,a3,80001aee <remove_page+0x50>
    if (pg->used == 1)
    80001ace:	4f98                	lw	a4,24(a5)
    80001ad0:	fec71be3          	bne	a4,a2,80001ac6 <remove_page+0x28>
    {
      if (pg->va == va)
    80001ad4:	6798                	ld	a4,8(a5)
    80001ad6:	fe9718e3          	bne	a4,s1,80001ac6 <remove_page+0x28>
      {
        
          pg->used = 0;
    80001ada:	0007ac23          	sw	zero,24(a5)
          pg->va = 0;
    80001ade:	0007b423          	sd	zero,8(a5)
          pg->offset = 0;
    80001ae2:	0007aa23          	sw	zero,20(a5)
          pg->on_disk = 0;
    80001ae6:	0007a823          	sw	zero,16(a5)
          pg->pagetable = 0;
    80001aea:	0007b023          	sd	zero,0(a5)

      }
    }
  } 
  }
    80001aee:	60e2                	ld	ra,24(sp)
    80001af0:	6442                	ld	s0,16(sp)
    80001af2:	64a2                	ld	s1,8(sp)
    80001af4:	6105                	addi	sp,sp,32
    80001af6:	8082                	ret

0000000080001af8 <uvmunmap>:
{
    80001af8:	715d                	addi	sp,sp,-80
    80001afa:	e486                	sd	ra,72(sp)
    80001afc:	e0a2                	sd	s0,64(sp)
    80001afe:	fc26                	sd	s1,56(sp)
    80001b00:	f84a                	sd	s2,48(sp)
    80001b02:	f44e                	sd	s3,40(sp)
    80001b04:	f052                	sd	s4,32(sp)
    80001b06:	ec56                	sd	s5,24(sp)
    80001b08:	e85a                	sd	s6,16(sp)
    80001b0a:	e45e                	sd	s7,8(sp)
    80001b0c:	0880                	addi	s0,sp,80
  if((va % PGSIZE) != 0)
    80001b0e:	03459793          	slli	a5,a1,0x34
    80001b12:	e795                	bnez	a5,80001b3e <uvmunmap+0x46>
    80001b14:	89aa                	mv	s3,a0
    80001b16:	892e                	mv	s2,a1
    80001b18:	8ab6                	mv	s5,a3
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001b1a:	0632                	slli	a2,a2,0xc
    80001b1c:	00b60a33          	add	s4,a2,a1
    if(PTE_FLAGS(*pte) == PTE_V)
    80001b20:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001b22:	6b05                	lui	s6,0x1
    80001b24:	0745ef63          	bltu	a1,s4,80001ba2 <uvmunmap+0xaa>
}
    80001b28:	60a6                	ld	ra,72(sp)
    80001b2a:	6406                	ld	s0,64(sp)
    80001b2c:	74e2                	ld	s1,56(sp)
    80001b2e:	7942                	ld	s2,48(sp)
    80001b30:	79a2                	ld	s3,40(sp)
    80001b32:	7a02                	ld	s4,32(sp)
    80001b34:	6ae2                	ld	s5,24(sp)
    80001b36:	6b42                	ld	s6,16(sp)
    80001b38:	6ba2                	ld	s7,8(sp)
    80001b3a:	6161                	addi	sp,sp,80
    80001b3c:	8082                	ret
    panic("uvmunmap: not aligned");
    80001b3e:	00006517          	auipc	a0,0x6
    80001b42:	6da50513          	addi	a0,a0,1754 # 80008218 <digits+0x1d8>
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	9e4080e7          	jalr	-1564(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001b4e:	00006517          	auipc	a0,0x6
    80001b52:	6e250513          	addi	a0,a0,1762 # 80008230 <digits+0x1f0>
    80001b56:	fffff097          	auipc	ra,0xfffff
    80001b5a:	9d4080e7          	jalr	-1580(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    80001b5e:	00006517          	auipc	a0,0x6
    80001b62:	6e250513          	addi	a0,a0,1762 # 80008240 <digits+0x200>
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	9c4080e7          	jalr	-1596(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    80001b6e:	00006517          	auipc	a0,0x6
    80001b72:	6ea50513          	addi	a0,a0,1770 # 80008258 <digits+0x218>
    80001b76:	fffff097          	auipc	ra,0xfffff
    80001b7a:	9b4080e7          	jalr	-1612(ra) # 8000052a <panic>
        uint64 pa = PTE2PA(*pte);
    80001b7e:	83a9                	srli	a5,a5,0xa
        kfree((void*)pa);
    80001b80:	00c79513          	slli	a0,a5,0xc
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	e52080e7          	jalr	-430(ra) # 800009d6 <kfree>
    remove_page(pagetable, a);
    80001b8c:	85ca                	mv	a1,s2
    80001b8e:	854e                	mv	a0,s3
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	f0e080e7          	jalr	-242(ra) # 80001a9e <remove_page>
    *pte = 0;
    80001b98:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001b9c:	995a                	add	s2,s2,s6
    80001b9e:	f94975e3          	bgeu	s2,s4,80001b28 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001ba2:	4601                	li	a2,0
    80001ba4:	85ca                	mv	a1,s2
    80001ba6:	854e                	mv	a0,s3
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	3fe080e7          	jalr	1022(ra) # 80000fa6 <walk>
    80001bb0:	84aa                	mv	s1,a0
    80001bb2:	dd51                	beqz	a0,80001b4e <uvmunmap+0x56>
    if(((*pte & PTE_V) == 0) && ((*pte & PTE_PG) == 0))
    80001bb4:	611c                	ld	a5,0(a0)
    80001bb6:	2017f713          	andi	a4,a5,513
    80001bba:	d355                	beqz	a4,80001b5e <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001bbc:	3ff7f713          	andi	a4,a5,1023
    80001bc0:	fb7707e3          	beq	a4,s7,80001b6e <uvmunmap+0x76>
    if(do_free)
    80001bc4:	fc0a84e3          	beqz	s5,80001b8c <uvmunmap+0x94>
      if ((*pte & PTE_PG) == 0)
    80001bc8:	2007f713          	andi	a4,a5,512
    80001bcc:	f361                	bnez	a4,80001b8c <uvmunmap+0x94>
    80001bce:	bf45                	j	80001b7e <uvmunmap+0x86>

0000000080001bd0 <uvmdealloc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	1000                	addi	s0,sp,32
    return oldsz;
    80001bda:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001bdc:	00b67d63          	bgeu	a2,a1,80001bf6 <uvmdealloc+0x26>
    80001be0:	84b2                	mv	s1,a2
  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001be2:	6785                	lui	a5,0x1
    80001be4:	17fd                	addi	a5,a5,-1
    80001be6:	00f60733          	add	a4,a2,a5
    80001bea:	767d                	lui	a2,0xfffff
    80001bec:	8f71                	and	a4,a4,a2
    80001bee:	97ae                	add	a5,a5,a1
    80001bf0:	8ff1                	and	a5,a5,a2
    80001bf2:	00f76863          	bltu	a4,a5,80001c02 <uvmdealloc+0x32>
}
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6105                	addi	sp,sp,32
    80001c00:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001c02:	8f99                	sub	a5,a5,a4
    80001c04:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001c06:	4685                	li	a3,1
    80001c08:	0007861b          	sext.w	a2,a5
    80001c0c:	85ba                	mv	a1,a4
    80001c0e:	00000097          	auipc	ra,0x0
    80001c12:	eea080e7          	jalr	-278(ra) # 80001af8 <uvmunmap>
    80001c16:	b7c5                	j	80001bf6 <uvmdealloc+0x26>

0000000080001c18 <uvmalloc>:
{
    80001c18:	715d                	addi	sp,sp,-80
    80001c1a:	e486                	sd	ra,72(sp)
    80001c1c:	e0a2                	sd	s0,64(sp)
    80001c1e:	fc26                	sd	s1,56(sp)
    80001c20:	f84a                	sd	s2,48(sp)
    80001c22:	f44e                	sd	s3,40(sp)
    80001c24:	f052                	sd	s4,32(sp)
    80001c26:	ec56                	sd	s5,24(sp)
    80001c28:	e85a                	sd	s6,16(sp)
    80001c2a:	e45e                	sd	s7,8(sp)
    80001c2c:	e062                	sd	s8,0(sp)
    80001c2e:	0880                	addi	s0,sp,80
    80001c30:	89aa                	mv	s3,a0
    80001c32:	8a2e                	mv	s4,a1
    80001c34:	8ab2                	mv	s5,a2
  struct proc* p = myproc();
    80001c36:	00000097          	auipc	ra,0x0
    80001c3a:	38a080e7          	jalr	906(ra) # 80001fc0 <myproc>
  if(newsz < oldsz)
    80001c3e:	0b4ae963          	bltu	s5,s4,80001cf0 <uvmalloc+0xd8>
    80001c42:	8b2a                	mv	s6,a0
  oldsz = PGROUNDUP(oldsz);
    80001c44:	6585                	lui	a1,0x1
    80001c46:	15fd                	addi	a1,a1,-1
    80001c48:	9a2e                	add	s4,s4,a1
    80001c4a:	77fd                	lui	a5,0xfffff
    80001c4c:	00fa7a33          	and	s4,s4,a5
  for(a = oldsz; a < newsz; a += PGSIZE)
    80001c50:	0b5a7d63          	bgeu	s4,s5,80001d0a <uvmalloc+0xf2>
    80001c54:	8952                	mv	s2,s4
    if ((p->pid > 2) && (countmemory(pagetable) >= MAX_PSYC_PAGES))
    80001c56:	4b89                	li	s7,2
    80001c58:	4c3d                	li	s8,15
    80001c5a:	a089                	j	80001c9c <uvmalloc+0x84>
    mem = kalloc();
    80001c5c:	fffff097          	auipc	ra,0xfffff
    80001c60:	e76080e7          	jalr	-394(ra) # 80000ad2 <kalloc>
    80001c64:	84aa                	mv	s1,a0
    if(mem == 0)
    80001c66:	cd21                	beqz	a0,80001cbe <uvmalloc+0xa6>
    memset(mem, 0, PGSIZE);
    80001c68:	6605                	lui	a2,0x1
    80001c6a:	4581                	li	a1,0
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	052080e7          	jalr	82(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001c74:	4779                	li	a4,30
    80001c76:	86a6                	mv	a3,s1
    80001c78:	6605                	lui	a2,0x1
    80001c7a:	85ca                	mv	a1,s2
    80001c7c:	854e                	mv	a0,s3
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	410080e7          	jalr	1040(ra) # 8000108e <mappages>
    80001c86:	e529                	bnez	a0,80001cd0 <uvmalloc+0xb8>
    add_page(pagetable, a);
    80001c88:	85ca                	mv	a1,s2
    80001c8a:	854e                	mv	a0,s3
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	dbc080e7          	jalr	-580(ra) # 80001a48 <add_page>
  for(a = oldsz; a < newsz; a += PGSIZE)
    80001c94:	6785                	lui	a5,0x1
    80001c96:	993e                	add	s2,s2,a5
    80001c98:	05597a63          	bgeu	s2,s5,80001cec <uvmalloc+0xd4>
    if ((p->pid > 2) && (countmemory(pagetable) >= MAX_PSYC_PAGES))
    80001c9c:	030b2783          	lw	a5,48(s6) # 1030 <_entry-0x7fffefd0>
    80001ca0:	fafbdee3          	bge	s7,a5,80001c5c <uvmalloc+0x44>
    80001ca4:	854e                	mv	a0,s3
    80001ca6:	00000097          	auipc	ra,0x0
    80001caa:	8a6080e7          	jalr	-1882(ra) # 8000154c <countmemory>
    80001cae:	faac57e3          	bge	s8,a0,80001c5c <uvmalloc+0x44>
      page_swap_out(pagetable);
    80001cb2:	854e                	mv	a0,s3
    80001cb4:	00000097          	auipc	ra,0x0
    80001cb8:	ba0080e7          	jalr	-1120(ra) # 80001854 <page_swap_out>
    80001cbc:	b745                	j	80001c5c <uvmalloc+0x44>
      uvmdealloc(pagetable, a, oldsz);
    80001cbe:	8652                	mv	a2,s4
    80001cc0:	85ca                	mv	a1,s2
    80001cc2:	854e                	mv	a0,s3
    80001cc4:	00000097          	auipc	ra,0x0
    80001cc8:	f0c080e7          	jalr	-244(ra) # 80001bd0 <uvmdealloc>
      return 0;
    80001ccc:	4501                	li	a0,0
    80001cce:	a015                	j	80001cf2 <uvmalloc+0xda>
      kfree(mem);
    80001cd0:	8526                	mv	a0,s1
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	d04080e7          	jalr	-764(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001cda:	8652                	mv	a2,s4
    80001cdc:	85ca                	mv	a1,s2
    80001cde:	854e                	mv	a0,s3
    80001ce0:	00000097          	auipc	ra,0x0
    80001ce4:	ef0080e7          	jalr	-272(ra) # 80001bd0 <uvmdealloc>
      return 0;
    80001ce8:	4501                	li	a0,0
    80001cea:	a021                	j	80001cf2 <uvmalloc+0xda>
  return newsz;
    80001cec:	8556                	mv	a0,s5
    80001cee:	a011                	j	80001cf2 <uvmalloc+0xda>
    return oldsz;
    80001cf0:	8552                	mv	a0,s4
}
    80001cf2:	60a6                	ld	ra,72(sp)
    80001cf4:	6406                	ld	s0,64(sp)
    80001cf6:	74e2                	ld	s1,56(sp)
    80001cf8:	7942                	ld	s2,48(sp)
    80001cfa:	79a2                	ld	s3,40(sp)
    80001cfc:	7a02                	ld	s4,32(sp)
    80001cfe:	6ae2                	ld	s5,24(sp)
    80001d00:	6b42                	ld	s6,16(sp)
    80001d02:	6ba2                	ld	s7,8(sp)
    80001d04:	6c02                	ld	s8,0(sp)
    80001d06:	6161                	addi	sp,sp,80
    80001d08:	8082                	ret
  return newsz;
    80001d0a:	8556                	mv	a0,s5
    80001d0c:	b7dd                	j	80001cf2 <uvmalloc+0xda>

0000000080001d0e <uvmfree>:
{
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	e426                	sd	s1,8(sp)
    80001d16:	1000                	addi	s0,sp,32
    80001d18:	84aa                	mv	s1,a0
  if(sz > 0)
    80001d1a:	e999                	bnez	a1,80001d30 <uvmfree+0x22>
  freewalk(pagetable);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	5c4080e7          	jalr	1476(ra) # 800012e2 <freewalk>
}
    80001d26:	60e2                	ld	ra,24(sp)
    80001d28:	6442                	ld	s0,16(sp)
    80001d2a:	64a2                	ld	s1,8(sp)
    80001d2c:	6105                	addi	sp,sp,32
    80001d2e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001d30:	6605                	lui	a2,0x1
    80001d32:	167d                	addi	a2,a2,-1
    80001d34:	962e                	add	a2,a2,a1
    80001d36:	4685                	li	a3,1
    80001d38:	8231                	srli	a2,a2,0xc
    80001d3a:	4581                	li	a1,0
    80001d3c:	00000097          	auipc	ra,0x0
    80001d40:	dbc080e7          	jalr	-580(ra) # 80001af8 <uvmunmap>
    80001d44:	bfe1                	j	80001d1c <uvmfree+0xe>

0000000080001d46 <uvmcopy>:
{
    80001d46:	715d                	addi	sp,sp,-80
    80001d48:	e486                	sd	ra,72(sp)
    80001d4a:	e0a2                	sd	s0,64(sp)
    80001d4c:	fc26                	sd	s1,56(sp)
    80001d4e:	f84a                	sd	s2,48(sp)
    80001d50:	f44e                	sd	s3,40(sp)
    80001d52:	f052                	sd	s4,32(sp)
    80001d54:	ec56                	sd	s5,24(sp)
    80001d56:	e85a                	sd	s6,16(sp)
    80001d58:	e45e                	sd	s7,8(sp)
    80001d5a:	e062                	sd	s8,0(sp)
    80001d5c:	0880                	addi	s0,sp,80
  for(i = 0; i < sz; i += PGSIZE){
    80001d5e:	c675                	beqz	a2,80001e4a <uvmcopy+0x104>
    80001d60:	8c2a                	mv	s8,a0
    80001d62:	8b2e                	mv	s6,a1
    80001d64:	8bb2                	mv	s7,a2
    80001d66:	4a01                	li	s4,0
    80001d68:	a08d                	j	80001dca <uvmcopy+0x84>
      panic("uvmcopy: pte should exist");
    80001d6a:	00006517          	auipc	a0,0x6
    80001d6e:	50650513          	addi	a0,a0,1286 # 80008270 <digits+0x230>
    80001d72:	ffffe097          	auipc	ra,0xffffe
    80001d76:	7b8080e7          	jalr	1976(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    80001d7a:	00006517          	auipc	a0,0x6
    80001d7e:	51650513          	addi	a0,a0,1302 # 80008290 <digits+0x250>
    80001d82:	ffffe097          	auipc	ra,0xffffe
    80001d86:	7a8080e7          	jalr	1960(ra) # 8000052a <panic>
      kfree(mem);
    80001d8a:	8526                	mv	a0,s1
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	c4a080e7          	jalr	-950(ra) # 800009d6 <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001d94:	4685                	li	a3,1
    80001d96:	00ca5613          	srli	a2,s4,0xc
    80001d9a:	4581                	li	a1,0
    80001d9c:	855a                	mv	a0,s6
    80001d9e:	00000097          	auipc	ra,0x0
    80001da2:	d5a080e7          	jalr	-678(ra) # 80001af8 <uvmunmap>
  return -1;
    80001da6:	597d                	li	s2,-1
}
    80001da8:	854a                	mv	a0,s2
    80001daa:	60a6                	ld	ra,72(sp)
    80001dac:	6406                	ld	s0,64(sp)
    80001dae:	74e2                	ld	s1,56(sp)
    80001db0:	7942                	ld	s2,48(sp)
    80001db2:	79a2                	ld	s3,40(sp)
    80001db4:	7a02                	ld	s4,32(sp)
    80001db6:	6ae2                	ld	s5,24(sp)
    80001db8:	6b42                	ld	s6,16(sp)
    80001dba:	6ba2                	ld	s7,8(sp)
    80001dbc:	6c02                	ld	s8,0(sp)
    80001dbe:	6161                	addi	sp,sp,80
    80001dc0:	8082                	ret
  for(i = 0; i < sz; i += PGSIZE){
    80001dc2:	6785                	lui	a5,0x1
    80001dc4:	9a3e                	add	s4,s4,a5
    80001dc6:	ff7a71e3          	bgeu	s4,s7,80001da8 <uvmcopy+0x62>
    if((pte = walk(old, i, 0)) == 0)
    80001dca:	4601                	li	a2,0
    80001dcc:	85d2                	mv	a1,s4
    80001dce:	8562                	mv	a0,s8
    80001dd0:	fffff097          	auipc	ra,0xfffff
    80001dd4:	1d6080e7          	jalr	470(ra) # 80000fa6 <walk>
    80001dd8:	89aa                	mv	s3,a0
    80001dda:	d941                	beqz	a0,80001d6a <uvmcopy+0x24>
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
    80001ddc:	6118                	ld	a4,0(a0)
    80001dde:	20177793          	andi	a5,a4,513
    80001de2:	dfc1                	beqz	a5,80001d7a <uvmcopy+0x34>
    pa = PTE2PA(*pte);
    80001de4:	00a75593          	srli	a1,a4,0xa
    80001de8:	00c59a93          	slli	s5,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001dec:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	ce2080e7          	jalr	-798(ra) # 80000ad2 <kalloc>
    80001df8:	84aa                	mv	s1,a0
    80001dfa:	dd49                	beqz	a0,80001d94 <uvmcopy+0x4e>
    memmove(mem, (char*)pa, PGSIZE);
    80001dfc:	6605                	lui	a2,0x1
    80001dfe:	85d6                	mv	a1,s5
    80001e00:	fffff097          	auipc	ra,0xfffff
    80001e04:	f1a080e7          	jalr	-230(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001e08:	874a                	mv	a4,s2
    80001e0a:	86a6                	mv	a3,s1
    80001e0c:	6605                	lui	a2,0x1
    80001e0e:	85d2                	mv	a1,s4
    80001e10:	855a                	mv	a0,s6
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	27c080e7          	jalr	636(ra) # 8000108e <mappages>
    80001e1a:	892a                	mv	s2,a0
    80001e1c:	f53d                	bnez	a0,80001d8a <uvmcopy+0x44>
    if ( *pte & PTE_PG)
    80001e1e:	0009b783          	ld	a5,0(s3)
    80001e22:	2007f793          	andi	a5,a5,512
    80001e26:	dfd1                	beqz	a5,80001dc2 <uvmcopy+0x7c>
      pte_t* pte2 = walk(new , i , 0);
    80001e28:	4601                	li	a2,0
    80001e2a:	85d2                	mv	a1,s4
    80001e2c:	855a                	mv	a0,s6
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	178080e7          	jalr	376(ra) # 80000fa6 <walk>
      *pte2 = (*pte2) ^ PTE_V;
    80001e36:	611c                	ld	a5,0(a0)
    80001e38:	0017c793          	xori	a5,a5,1
    80001e3c:	e11c                	sd	a5,0(a0)
      kfree(mem);
    80001e3e:	8526                	mv	a0,s1
    80001e40:	fffff097          	auipc	ra,0xfffff
    80001e44:	b96080e7          	jalr	-1130(ra) # 800009d6 <kfree>
    80001e48:	bfad                	j	80001dc2 <uvmcopy+0x7c>
  return 0;
    80001e4a:	4901                	li	s2,0
    80001e4c:	bfb1                	j	80001da8 <uvmcopy+0x62>

0000000080001e4e <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001e4e:	7139                	addi	sp,sp,-64
    80001e50:	fc06                	sd	ra,56(sp)
    80001e52:	f822                	sd	s0,48(sp)
    80001e54:	f426                	sd	s1,40(sp)
    80001e56:	f04a                	sd	s2,32(sp)
    80001e58:	ec4e                	sd	s3,24(sp)
    80001e5a:	e852                	sd	s4,16(sp)
    80001e5c:	e456                	sd	s5,8(sp)
    80001e5e:	e05a                	sd	s6,0(sp)
    80001e60:	0080                	addi	s0,sp,64
    80001e62:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e64:	00010497          	auipc	s1,0x10
    80001e68:	86c48493          	addi	s1,s1,-1940 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001e6c:	8b26                	mv	s6,s1
    80001e6e:	00006a97          	auipc	s5,0x6
    80001e72:	192a8a93          	addi	s5,s5,402 # 80008000 <etext>
    80001e76:	04000937          	lui	s2,0x4000
    80001e7a:	197d                	addi	s2,s2,-1
    80001e7c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e7e:	00025a17          	auipc	s4,0x25
    80001e82:	452a0a13          	addi	s4,s4,1106 # 800272d0 <tickslock>
    char *pa = kalloc();
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	c4c080e7          	jalr	-948(ra) # 80000ad2 <kalloc>
    80001e8e:	862a                	mv	a2,a0
    if(pa == 0)
    80001e90:	c131                	beqz	a0,80001ed4 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001e92:	416485b3          	sub	a1,s1,s6
    80001e96:	8591                	srai	a1,a1,0x4
    80001e98:	000ab783          	ld	a5,0(s5)
    80001e9c:	02f585b3          	mul	a1,a1,a5
    80001ea0:	2585                	addiw	a1,a1,1
    80001ea2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ea6:	4719                	li	a4,6
    80001ea8:	6685                	lui	a3,0x1
    80001eaa:	40b905b3          	sub	a1,s2,a1
    80001eae:	854e                	mv	a0,s3
    80001eb0:	fffff097          	auipc	ra,0xfffff
    80001eb4:	26c080e7          	jalr	620(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001eb8:	57048493          	addi	s1,s1,1392
    80001ebc:	fd4495e3          	bne	s1,s4,80001e86 <proc_mapstacks+0x38>
  }
}
    80001ec0:	70e2                	ld	ra,56(sp)
    80001ec2:	7442                	ld	s0,48(sp)
    80001ec4:	74a2                	ld	s1,40(sp)
    80001ec6:	7902                	ld	s2,32(sp)
    80001ec8:	69e2                	ld	s3,24(sp)
    80001eca:	6a42                	ld	s4,16(sp)
    80001ecc:	6aa2                	ld	s5,8(sp)
    80001ece:	6b02                	ld	s6,0(sp)
    80001ed0:	6121                	addi	sp,sp,64
    80001ed2:	8082                	ret
      panic("kalloc");
    80001ed4:	00006517          	auipc	a0,0x6
    80001ed8:	3dc50513          	addi	a0,a0,988 # 800082b0 <digits+0x270>
    80001edc:	ffffe097          	auipc	ra,0xffffe
    80001ee0:	64e080e7          	jalr	1614(ra) # 8000052a <panic>

0000000080001ee4 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001ee4:	7139                	addi	sp,sp,-64
    80001ee6:	fc06                	sd	ra,56(sp)
    80001ee8:	f822                	sd	s0,48(sp)
    80001eea:	f426                	sd	s1,40(sp)
    80001eec:	f04a                	sd	s2,32(sp)
    80001eee:	ec4e                	sd	s3,24(sp)
    80001ef0:	e852                	sd	s4,16(sp)
    80001ef2:	e456                	sd	s5,8(sp)
    80001ef4:	e05a                	sd	s6,0(sp)
    80001ef6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001ef8:	00006597          	auipc	a1,0x6
    80001efc:	3c058593          	addi	a1,a1,960 # 800082b8 <digits+0x278>
    80001f00:	0000f517          	auipc	a0,0xf
    80001f04:	3a050513          	addi	a0,a0,928 # 800112a0 <pid_lock>
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	c2a080e7          	jalr	-982(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001f10:	00006597          	auipc	a1,0x6
    80001f14:	3b058593          	addi	a1,a1,944 # 800082c0 <digits+0x280>
    80001f18:	0000f517          	auipc	a0,0xf
    80001f1c:	3a050513          	addi	a0,a0,928 # 800112b8 <wait_lock>
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	c12080e7          	jalr	-1006(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f28:	0000f497          	auipc	s1,0xf
    80001f2c:	7a848493          	addi	s1,s1,1960 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001f30:	00006b17          	auipc	s6,0x6
    80001f34:	3a0b0b13          	addi	s6,s6,928 # 800082d0 <digits+0x290>
      p->kstack = KSTACK((int) (p - proc));
    80001f38:	8aa6                	mv	s5,s1
    80001f3a:	00006a17          	auipc	s4,0x6
    80001f3e:	0c6a0a13          	addi	s4,s4,198 # 80008000 <etext>
    80001f42:	04000937          	lui	s2,0x4000
    80001f46:	197d                	addi	s2,s2,-1
    80001f48:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f4a:	00025997          	auipc	s3,0x25
    80001f4e:	38698993          	addi	s3,s3,902 # 800272d0 <tickslock>
      initlock(&p->lock, "proc");
    80001f52:	85da                	mv	a1,s6
    80001f54:	8526                	mv	a0,s1
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	bdc080e7          	jalr	-1060(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001f5e:	415487b3          	sub	a5,s1,s5
    80001f62:	8791                	srai	a5,a5,0x4
    80001f64:	000a3703          	ld	a4,0(s4)
    80001f68:	02e787b3          	mul	a5,a5,a4
    80001f6c:	2785                	addiw	a5,a5,1
    80001f6e:	00d7979b          	slliw	a5,a5,0xd
    80001f72:	40f907b3          	sub	a5,s2,a5
    80001f76:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f78:	57048493          	addi	s1,s1,1392
    80001f7c:	fd349be3          	bne	s1,s3,80001f52 <procinit+0x6e>
  }
}
    80001f80:	70e2                	ld	ra,56(sp)
    80001f82:	7442                	ld	s0,48(sp)
    80001f84:	74a2                	ld	s1,40(sp)
    80001f86:	7902                	ld	s2,32(sp)
    80001f88:	69e2                	ld	s3,24(sp)
    80001f8a:	6a42                	ld	s4,16(sp)
    80001f8c:	6aa2                	ld	s5,8(sp)
    80001f8e:	6b02                	ld	s6,0(sp)
    80001f90:	6121                	addi	sp,sp,64
    80001f92:	8082                	ret

0000000080001f94 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001f94:	1141                	addi	sp,sp,-16
    80001f96:	e422                	sd	s0,8(sp)
    80001f98:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f9a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001f9c:	2501                	sext.w	a0,a0
    80001f9e:	6422                	ld	s0,8(sp)
    80001fa0:	0141                	addi	sp,sp,16
    80001fa2:	8082                	ret

0000000080001fa4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001fa4:	1141                	addi	sp,sp,-16
    80001fa6:	e422                	sd	s0,8(sp)
    80001fa8:	0800                	addi	s0,sp,16
    80001faa:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001fac:	2781                	sext.w	a5,a5
    80001fae:	079e                	slli	a5,a5,0x7
  return c;
}
    80001fb0:	0000f517          	auipc	a0,0xf
    80001fb4:	32050513          	addi	a0,a0,800 # 800112d0 <cpus>
    80001fb8:	953e                	add	a0,a0,a5
    80001fba:	6422                	ld	s0,8(sp)
    80001fbc:	0141                	addi	sp,sp,16
    80001fbe:	8082                	ret

0000000080001fc0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001fc0:	1101                	addi	sp,sp,-32
    80001fc2:	ec06                	sd	ra,24(sp)
    80001fc4:	e822                	sd	s0,16(sp)
    80001fc6:	e426                	sd	s1,8(sp)
    80001fc8:	1000                	addi	s0,sp,32
  push_off();
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	bac080e7          	jalr	-1108(ra) # 80000b76 <push_off>
    80001fd2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001fd4:	2781                	sext.w	a5,a5
    80001fd6:	079e                	slli	a5,a5,0x7
    80001fd8:	0000f717          	auipc	a4,0xf
    80001fdc:	2c870713          	addi	a4,a4,712 # 800112a0 <pid_lock>
    80001fe0:	97ba                	add	a5,a5,a4
    80001fe2:	7b84                	ld	s1,48(a5)
  pop_off();
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	c32080e7          	jalr	-974(ra) # 80000c16 <pop_off>
  return p;
}
    80001fec:	8526                	mv	a0,s1
    80001fee:	60e2                	ld	ra,24(sp)
    80001ff0:	6442                	ld	s0,16(sp)
    80001ff2:	64a2                	ld	s1,8(sp)
    80001ff4:	6105                	addi	sp,sp,32
    80001ff6:	8082                	ret

0000000080001ff8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001ff8:	1141                	addi	sp,sp,-16
    80001ffa:	e406                	sd	ra,8(sp)
    80001ffc:	e022                	sd	s0,0(sp)
    80001ffe:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80002000:	00000097          	auipc	ra,0x0
    80002004:	fc0080e7          	jalr	-64(ra) # 80001fc0 <myproc>
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	c6e080e7          	jalr	-914(ra) # 80000c76 <release>

  if (first) {
    80002010:	00007797          	auipc	a5,0x7
    80002014:	9807a783          	lw	a5,-1664(a5) # 80008990 <first.1>
    80002018:	eb89                	bnez	a5,8000202a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    8000201a:	00001097          	auipc	ra,0x1
    8000201e:	d26080e7          	jalr	-730(ra) # 80002d40 <usertrapret>
}
    80002022:	60a2                	ld	ra,8(sp)
    80002024:	6402                	ld	s0,0(sp)
    80002026:	0141                	addi	sp,sp,16
    80002028:	8082                	ret
    first = 0;
    8000202a:	00007797          	auipc	a5,0x7
    8000202e:	9607a323          	sw	zero,-1690(a5) # 80008990 <first.1>
    fsinit(ROOTDEV);
    80002032:	4505                	li	a0,1
    80002034:	00002097          	auipc	ra,0x2
    80002038:	b22080e7          	jalr	-1246(ra) # 80003b56 <fsinit>
    8000203c:	bff9                	j	8000201a <forkret+0x22>

000000008000203e <allocpid>:
allocpid() {
    8000203e:	1101                	addi	sp,sp,-32
    80002040:	ec06                	sd	ra,24(sp)
    80002042:	e822                	sd	s0,16(sp)
    80002044:	e426                	sd	s1,8(sp)
    80002046:	e04a                	sd	s2,0(sp)
    80002048:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000204a:	0000f917          	auipc	s2,0xf
    8000204e:	25690913          	addi	s2,s2,598 # 800112a0 <pid_lock>
    80002052:	854a                	mv	a0,s2
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	b6e080e7          	jalr	-1170(ra) # 80000bc2 <acquire>
  pid = nextpid;
    8000205c:	00007797          	auipc	a5,0x7
    80002060:	93878793          	addi	a5,a5,-1736 # 80008994 <nextpid>
    80002064:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80002066:	0014871b          	addiw	a4,s1,1
    8000206a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    8000206c:	854a                	mv	a0,s2
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	c08080e7          	jalr	-1016(ra) # 80000c76 <release>
}
    80002076:	8526                	mv	a0,s1
    80002078:	60e2                	ld	ra,24(sp)
    8000207a:	6442                	ld	s0,16(sp)
    8000207c:	64a2                	ld	s1,8(sp)
    8000207e:	6902                	ld	s2,0(sp)
    80002080:	6105                	addi	sp,sp,32
    80002082:	8082                	ret

0000000080002084 <proc_pagetable>:
{
    80002084:	1101                	addi	sp,sp,-32
    80002086:	ec06                	sd	ra,24(sp)
    80002088:	e822                	sd	s0,16(sp)
    8000208a:	e426                	sd	s1,8(sp)
    8000208c:	e04a                	sd	s2,0(sp)
    8000208e:	1000                	addi	s0,sp,32
    80002090:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	1b0080e7          	jalr	432(ra) # 80001242 <uvmcreate>
    8000209a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000209c:	c931                	beqz	a0,800020f0 <proc_pagetable+0x6c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000209e:	4729                	li	a4,10
    800020a0:	00005697          	auipc	a3,0x5
    800020a4:	f6068693          	addi	a3,a3,-160 # 80007000 <_trampoline>
    800020a8:	6605                	lui	a2,0x1
    800020aa:	040005b7          	lui	a1,0x4000
    800020ae:	15fd                	addi	a1,a1,-1
    800020b0:	05b2                	slli	a1,a1,0xc
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	fdc080e7          	jalr	-36(ra) # 8000108e <mappages>
    800020ba:	04054263          	bltz	a0,800020fe <proc_pagetable+0x7a>
  if (p->pid >2 )
    800020be:	03092703          	lw	a4,48(s2)
    800020c2:	4789                	li	a5,2
    800020c4:	04e7c563          	blt	a5,a4,8000210e <proc_pagetable+0x8a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800020c8:	4719                	li	a4,6
    800020ca:	05893683          	ld	a3,88(s2)
    800020ce:	6605                	lui	a2,0x1
    800020d0:	020005b7          	lui	a1,0x2000
    800020d4:	15fd                	addi	a1,a1,-1
    800020d6:	05b6                	slli	a1,a1,0xd
    800020d8:	8526                	mv	a0,s1
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	fb4080e7          	jalr	-76(ra) # 8000108e <mappages>
    800020e2:	04054063          	bltz	a0,80002122 <proc_pagetable+0x9e>
  if (p->pid >2 )
    800020e6:	03092703          	lw	a4,48(s2)
    800020ea:	4789                	li	a5,2
    800020ec:	04e7ce63          	blt	a5,a4,80002148 <proc_pagetable+0xc4>
}
    800020f0:	8526                	mv	a0,s1
    800020f2:	60e2                	ld	ra,24(sp)
    800020f4:	6442                	ld	s0,16(sp)
    800020f6:	64a2                	ld	s1,8(sp)
    800020f8:	6902                	ld	s2,0(sp)
    800020fa:	6105                	addi	sp,sp,32
    800020fc:	8082                	ret
    uvmfree(pagetable, 0);
    800020fe:	4581                	li	a1,0
    80002100:	8526                	mv	a0,s1
    80002102:	00000097          	auipc	ra,0x0
    80002106:	c0c080e7          	jalr	-1012(ra) # 80001d0e <uvmfree>
    return 0;
    8000210a:	4481                	li	s1,0
    8000210c:	b7d5                	j	800020f0 <proc_pagetable+0x6c>
    add_page(pagetable, TRAMPOLINE);
    8000210e:	040005b7          	lui	a1,0x4000
    80002112:	15fd                	addi	a1,a1,-1
    80002114:	05b2                	slli	a1,a1,0xc
    80002116:	8526                	mv	a0,s1
    80002118:	00000097          	auipc	ra,0x0
    8000211c:	930080e7          	jalr	-1744(ra) # 80001a48 <add_page>
    80002120:	b765                	j	800020c8 <proc_pagetable+0x44>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002122:	4681                	li	a3,0
    80002124:	4605                	li	a2,1
    80002126:	040005b7          	lui	a1,0x4000
    8000212a:	15fd                	addi	a1,a1,-1
    8000212c:	05b2                	slli	a1,a1,0xc
    8000212e:	8526                	mv	a0,s1
    80002130:	00000097          	auipc	ra,0x0
    80002134:	9c8080e7          	jalr	-1592(ra) # 80001af8 <uvmunmap>
    uvmfree(pagetable, 0);
    80002138:	4581                	li	a1,0
    8000213a:	8526                	mv	a0,s1
    8000213c:	00000097          	auipc	ra,0x0
    80002140:	bd2080e7          	jalr	-1070(ra) # 80001d0e <uvmfree>
    return 0;
    80002144:	4481                	li	s1,0
    80002146:	b76d                	j	800020f0 <proc_pagetable+0x6c>
    add_page(pagetable, TRAPFRAME);
    80002148:	020005b7          	lui	a1,0x2000
    8000214c:	15fd                	addi	a1,a1,-1
    8000214e:	05b6                	slli	a1,a1,0xd
    80002150:	8526                	mv	a0,s1
    80002152:	00000097          	auipc	ra,0x0
    80002156:	8f6080e7          	jalr	-1802(ra) # 80001a48 <add_page>
    8000215a:	bf59                	j	800020f0 <proc_pagetable+0x6c>

000000008000215c <proc_freepagetable>:
{
    8000215c:	1101                	addi	sp,sp,-32
    8000215e:	ec06                	sd	ra,24(sp)
    80002160:	e822                	sd	s0,16(sp)
    80002162:	e426                	sd	s1,8(sp)
    80002164:	e04a                	sd	s2,0(sp)
    80002166:	1000                	addi	s0,sp,32
    80002168:	84aa                	mv	s1,a0
    8000216a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000216c:	4681                	li	a3,0
    8000216e:	4605                	li	a2,1
    80002170:	040005b7          	lui	a1,0x4000
    80002174:	15fd                	addi	a1,a1,-1
    80002176:	05b2                	slli	a1,a1,0xc
    80002178:	00000097          	auipc	ra,0x0
    8000217c:	980080e7          	jalr	-1664(ra) # 80001af8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80002180:	4681                	li	a3,0
    80002182:	4605                	li	a2,1
    80002184:	020005b7          	lui	a1,0x2000
    80002188:	15fd                	addi	a1,a1,-1
    8000218a:	05b6                	slli	a1,a1,0xd
    8000218c:	8526                	mv	a0,s1
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	96a080e7          	jalr	-1686(ra) # 80001af8 <uvmunmap>
  uvmfree(pagetable, sz);
    80002196:	85ca                	mv	a1,s2
    80002198:	8526                	mv	a0,s1
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	b74080e7          	jalr	-1164(ra) # 80001d0e <uvmfree>
}
    800021a2:	60e2                	ld	ra,24(sp)
    800021a4:	6442                	ld	s0,16(sp)
    800021a6:	64a2                	ld	s1,8(sp)
    800021a8:	6902                	ld	s2,0(sp)
    800021aa:	6105                	addi	sp,sp,32
    800021ac:	8082                	ret

00000000800021ae <freeproc>:
{
    800021ae:	1101                	addi	sp,sp,-32
    800021b0:	ec06                	sd	ra,24(sp)
    800021b2:	e822                	sd	s0,16(sp)
    800021b4:	e426                	sd	s1,8(sp)
    800021b6:	1000                	addi	s0,sp,32
    800021b8:	84aa                	mv	s1,a0
  if(p->trapframe)
    800021ba:	6d28                	ld	a0,88(a0)
    800021bc:	c509                	beqz	a0,800021c6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	818080e7          	jalr	-2024(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    800021c6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800021ca:	68a8                	ld	a0,80(s1)
    800021cc:	c511                	beqz	a0,800021d8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    800021ce:	64ac                	ld	a1,72(s1)
    800021d0:	00000097          	auipc	ra,0x0
    800021d4:	f8c080e7          	jalr	-116(ra) # 8000215c <proc_freepagetable>
  p->pagetable = 0;
    800021d8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800021dc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800021e0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800021e4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800021e8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800021ec:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800021f0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800021f4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800021f8:	0004ac23          	sw	zero,24(s1)
}
    800021fc:	60e2                	ld	ra,24(sp)
    800021fe:	6442                	ld	s0,16(sp)
    80002200:	64a2                	ld	s1,8(sp)
    80002202:	6105                	addi	sp,sp,32
    80002204:	8082                	ret

0000000080002206 <allocproc>:
{
    80002206:	1101                	addi	sp,sp,-32
    80002208:	ec06                	sd	ra,24(sp)
    8000220a:	e822                	sd	s0,16(sp)
    8000220c:	e426                	sd	s1,8(sp)
    8000220e:	e04a                	sd	s2,0(sp)
    80002210:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002212:	0000f497          	auipc	s1,0xf
    80002216:	4be48493          	addi	s1,s1,1214 # 800116d0 <proc>
    8000221a:	00025917          	auipc	s2,0x25
    8000221e:	0b690913          	addi	s2,s2,182 # 800272d0 <tickslock>
    acquire(&p->lock);
    80002222:	8526                	mv	a0,s1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	99e080e7          	jalr	-1634(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    8000222c:	4c9c                	lw	a5,24(s1)
    8000222e:	cf81                	beqz	a5,80002246 <allocproc+0x40>
      release(&p->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	a44080e7          	jalr	-1468(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000223a:	57048493          	addi	s1,s1,1392
    8000223e:	ff2492e3          	bne	s1,s2,80002222 <allocproc+0x1c>
  return 0;
    80002242:	4481                	li	s1,0
    80002244:	a0bd                	j	800022b2 <allocproc+0xac>
  p->pid = allocpid();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	df8080e7          	jalr	-520(ra) # 8000203e <allocpid>
    8000224e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002250:	4785                	li	a5,1
    80002252:	cc9c                	sw	a5,24(s1)
  for (struct page* pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80002254:	17048793          	addi	a5,s1,368
    80002258:	57048713          	addi	a4,s1,1392
    pg->on_disk = 0;
    8000225c:	0007a823          	sw	zero,16(a5)
    pg->used = 0;
    80002260:	0007ac23          	sw	zero,24(a5)
    pg->va = 0;
    80002264:	0007b423          	sd	zero,8(a5)
  for (struct page* pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80002268:	02078793          	addi	a5,a5,32
    8000226c:	fee798e3          	bne	a5,a4,8000225c <allocproc+0x56>
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	862080e7          	jalr	-1950(ra) # 80000ad2 <kalloc>
    80002278:	892a                	mv	s2,a0
    8000227a:	eca8                	sd	a0,88(s1)
    8000227c:	c131                	beqz	a0,800022c0 <allocproc+0xba>
  p->pagetable = proc_pagetable(p);
    8000227e:	8526                	mv	a0,s1
    80002280:	00000097          	auipc	ra,0x0
    80002284:	e04080e7          	jalr	-508(ra) # 80002084 <proc_pagetable>
    80002288:	892a                	mv	s2,a0
    8000228a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    8000228c:	c531                	beqz	a0,800022d8 <allocproc+0xd2>
  memset(&p->context, 0, sizeof(p->context));
    8000228e:	07000613          	li	a2,112
    80002292:	4581                	li	a1,0
    80002294:	06048513          	addi	a0,s1,96
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	a26080e7          	jalr	-1498(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    800022a0:	00000797          	auipc	a5,0x0
    800022a4:	d5878793          	addi	a5,a5,-680 # 80001ff8 <forkret>
    800022a8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800022aa:	60bc                	ld	a5,64(s1)
    800022ac:	6705                	lui	a4,0x1
    800022ae:	97ba                	add	a5,a5,a4
    800022b0:	f4bc                	sd	a5,104(s1)
}
    800022b2:	8526                	mv	a0,s1
    800022b4:	60e2                	ld	ra,24(sp)
    800022b6:	6442                	ld	s0,16(sp)
    800022b8:	64a2                	ld	s1,8(sp)
    800022ba:	6902                	ld	s2,0(sp)
    800022bc:	6105                	addi	sp,sp,32
    800022be:	8082                	ret
    freeproc(p);
    800022c0:	8526                	mv	a0,s1
    800022c2:	00000097          	auipc	ra,0x0
    800022c6:	eec080e7          	jalr	-276(ra) # 800021ae <freeproc>
    release(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	9aa080e7          	jalr	-1622(ra) # 80000c76 <release>
    return 0;
    800022d4:	84ca                	mv	s1,s2
    800022d6:	bff1                	j	800022b2 <allocproc+0xac>
    freeproc(p);
    800022d8:	8526                	mv	a0,s1
    800022da:	00000097          	auipc	ra,0x0
    800022de:	ed4080e7          	jalr	-300(ra) # 800021ae <freeproc>
    release(&p->lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	992080e7          	jalr	-1646(ra) # 80000c76 <release>
    return 0;
    800022ec:	84ca                	mv	s1,s2
    800022ee:	b7d1                	j	800022b2 <allocproc+0xac>

00000000800022f0 <userinit>:
{
    800022f0:	1101                	addi	sp,sp,-32
    800022f2:	ec06                	sd	ra,24(sp)
    800022f4:	e822                	sd	s0,16(sp)
    800022f6:	e426                	sd	s1,8(sp)
    800022f8:	1000                	addi	s0,sp,32
  p = allocproc();
    800022fa:	00000097          	auipc	ra,0x0
    800022fe:	f0c080e7          	jalr	-244(ra) # 80002206 <allocproc>
    80002302:	84aa                	mv	s1,a0
  initproc = p;
    80002304:	00007797          	auipc	a5,0x7
    80002308:	d2a7b623          	sd	a0,-724(a5) # 80009030 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000230c:	03400613          	li	a2,52
    80002310:	00006597          	auipc	a1,0x6
    80002314:	69058593          	addi	a1,a1,1680 # 800089a0 <initcode>
    80002318:	6928                	ld	a0,80(a0)
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	f56080e7          	jalr	-170(ra) # 80001270 <uvminit>
  p->sz = PGSIZE;
    80002322:	6785                	lui	a5,0x1
    80002324:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80002326:	6cb8                	ld	a4,88(s1)
    80002328:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000232c:	6cb8                	ld	a4,88(s1)
    8000232e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002330:	4641                	li	a2,16
    80002332:	00006597          	auipc	a1,0x6
    80002336:	fa658593          	addi	a1,a1,-90 # 800082d8 <digits+0x298>
    8000233a:	15848513          	addi	a0,s1,344
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	ad2080e7          	jalr	-1326(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80002346:	00006517          	auipc	a0,0x6
    8000234a:	fa250513          	addi	a0,a0,-94 # 800082e8 <digits+0x2a8>
    8000234e:	00002097          	auipc	ra,0x2
    80002352:	236080e7          	jalr	566(ra) # 80004584 <namei>
    80002356:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000235a:	478d                	li	a5,3
    8000235c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000235e:	8526                	mv	a0,s1
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	916080e7          	jalr	-1770(ra) # 80000c76 <release>
}
    80002368:	60e2                	ld	ra,24(sp)
    8000236a:	6442                	ld	s0,16(sp)
    8000236c:	64a2                	ld	s1,8(sp)
    8000236e:	6105                	addi	sp,sp,32
    80002370:	8082                	ret

0000000080002372 <growproc>:
{
    80002372:	1101                	addi	sp,sp,-32
    80002374:	ec06                	sd	ra,24(sp)
    80002376:	e822                	sd	s0,16(sp)
    80002378:	e426                	sd	s1,8(sp)
    8000237a:	e04a                	sd	s2,0(sp)
    8000237c:	1000                	addi	s0,sp,32
    8000237e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002380:	00000097          	auipc	ra,0x0
    80002384:	c40080e7          	jalr	-960(ra) # 80001fc0 <myproc>
    80002388:	892a                	mv	s2,a0
  sz = p->sz;
    8000238a:	652c                	ld	a1,72(a0)
    8000238c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002390:	00904f63          	bgtz	s1,800023ae <growproc+0x3c>
  } else if(n < 0){
    80002394:	0204cc63          	bltz	s1,800023cc <growproc+0x5a>
  p->sz = sz;
    80002398:	1602                	slli	a2,a2,0x20
    8000239a:	9201                	srli	a2,a2,0x20
    8000239c:	04c93423          	sd	a2,72(s2)
  return 0;
    800023a0:	4501                	li	a0,0
}
    800023a2:	60e2                	ld	ra,24(sp)
    800023a4:	6442                	ld	s0,16(sp)
    800023a6:	64a2                	ld	s1,8(sp)
    800023a8:	6902                	ld	s2,0(sp)
    800023aa:	6105                	addi	sp,sp,32
    800023ac:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800023ae:	9e25                	addw	a2,a2,s1
    800023b0:	1602                	slli	a2,a2,0x20
    800023b2:	9201                	srli	a2,a2,0x20
    800023b4:	1582                	slli	a1,a1,0x20
    800023b6:	9181                	srli	a1,a1,0x20
    800023b8:	6928                	ld	a0,80(a0)
    800023ba:	00000097          	auipc	ra,0x0
    800023be:	85e080e7          	jalr	-1954(ra) # 80001c18 <uvmalloc>
    800023c2:	0005061b          	sext.w	a2,a0
    800023c6:	fa69                	bnez	a2,80002398 <growproc+0x26>
      return -1;
    800023c8:	557d                	li	a0,-1
    800023ca:	bfe1                	j	800023a2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800023cc:	9e25                	addw	a2,a2,s1
    800023ce:	1602                	slli	a2,a2,0x20
    800023d0:	9201                	srli	a2,a2,0x20
    800023d2:	1582                	slli	a1,a1,0x20
    800023d4:	9181                	srli	a1,a1,0x20
    800023d6:	6928                	ld	a0,80(a0)
    800023d8:	fffff097          	auipc	ra,0xfffff
    800023dc:	7f8080e7          	jalr	2040(ra) # 80001bd0 <uvmdealloc>
    800023e0:	0005061b          	sext.w	a2,a0
    800023e4:	bf55                	j	80002398 <growproc+0x26>

00000000800023e6 <fork>:
{
    800023e6:	715d                	addi	sp,sp,-80
    800023e8:	e486                	sd	ra,72(sp)
    800023ea:	e0a2                	sd	s0,64(sp)
    800023ec:	fc26                	sd	s1,56(sp)
    800023ee:	f84a                	sd	s2,48(sp)
    800023f0:	f44e                	sd	s3,40(sp)
    800023f2:	f052                	sd	s4,32(sp)
    800023f4:	ec56                	sd	s5,24(sp)
    800023f6:	e85a                	sd	s6,16(sp)
    800023f8:	e45e                	sd	s7,8(sp)
    800023fa:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    800023fc:	00000097          	auipc	ra,0x0
    80002400:	bc4080e7          	jalr	-1084(ra) # 80001fc0 <myproc>
    80002404:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002406:	00000097          	auipc	ra,0x0
    8000240a:	e00080e7          	jalr	-512(ra) # 80002206 <allocproc>
    8000240e:	1a050963          	beqz	a0,800025c0 <fork+0x1da>
    80002412:	89aa                	mv	s3,a0
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80002414:	170a8493          	addi	s1,s5,368
    80002418:	570a8a13          	addi	s4,s5,1392
    8000241c:	8726                	mv	a4,s1
    int index = (int) (pg - p->pages);
    8000241e:	409707b3          	sub	a5,a4,s1
    80002422:	8795                	srai	a5,a5,0x5
    80002424:	2781                	sext.w	a5,a5
    np->pages[index].offset = pg->offset;
    80002426:	4b54                	lw	a3,20(a4)
    80002428:	0796                	slli	a5,a5,0x5
    8000242a:	97ce                	add	a5,a5,s3
    8000242c:	18d7a223          	sw	a3,388(a5) # 1184 <_entry-0x7fffee7c>
    np->pages[index].on_disk = pg->on_disk;
    80002430:	4b14                	lw	a3,16(a4)
    80002432:	18d7a023          	sw	a3,384(a5)
    np->pages[index].used = pg->used;
    80002436:	4f14                	lw	a3,24(a4)
    80002438:	18d7a423          	sw	a3,392(a5)
    np->pages[index].va = pg->va;
    8000243c:	6714                	ld	a3,8(a4)
    8000243e:	16d7bc23          	sd	a3,376(a5)
  for (pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80002442:	02070713          	addi	a4,a4,32
    80002446:	fd471ce3          	bne	a4,s4,8000241e <fork+0x38>
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000244a:	048ab603          	ld	a2,72(s5)
    8000244e:	0509b583          	ld	a1,80(s3)
    80002452:	050ab503          	ld	a0,80(s5)
    80002456:	00000097          	auipc	ra,0x0
    8000245a:	8f0080e7          	jalr	-1808(ra) # 80001d46 <uvmcopy>
    8000245e:	04054863          	bltz	a0,800024ae <fork+0xc8>
  np->sz = p->sz;
    80002462:	048ab783          	ld	a5,72(s5)
    80002466:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000246a:	058ab683          	ld	a3,88(s5)
    8000246e:	87b6                	mv	a5,a3
    80002470:	0589b703          	ld	a4,88(s3)
    80002474:	12068693          	addi	a3,a3,288
    80002478:	0007b803          	ld	a6,0(a5)
    8000247c:	6788                	ld	a0,8(a5)
    8000247e:	6b8c                	ld	a1,16(a5)
    80002480:	6f90                	ld	a2,24(a5)
    80002482:	01073023          	sd	a6,0(a4)
    80002486:	e708                	sd	a0,8(a4)
    80002488:	eb0c                	sd	a1,16(a4)
    8000248a:	ef10                	sd	a2,24(a4)
    8000248c:	02078793          	addi	a5,a5,32
    80002490:	02070713          	addi	a4,a4,32
    80002494:	fed792e3          	bne	a5,a3,80002478 <fork+0x92>
  np->trapframe->a0 = 0;
    80002498:	0589b783          	ld	a5,88(s3)
    8000249c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800024a0:	0d0a8913          	addi	s2,s5,208
    800024a4:	0d098b13          	addi	s6,s3,208
    800024a8:	150a8b93          	addi	s7,s5,336
    800024ac:	a00d                	j	800024ce <fork+0xe8>
    freeproc(np);
    800024ae:	854e                	mv	a0,s3
    800024b0:	00000097          	auipc	ra,0x0
    800024b4:	cfe080e7          	jalr	-770(ra) # 800021ae <freeproc>
    release(&np->lock);
    800024b8:	854e                	mv	a0,s3
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	7bc080e7          	jalr	1980(ra) # 80000c76 <release>
    return -1;
    800024c2:	5b7d                	li	s6,-1
    800024c4:	a849                	j	80002556 <fork+0x170>
  for(i = 0; i < NOFILE; i++)
    800024c6:	0921                	addi	s2,s2,8
    800024c8:	0b21                	addi	s6,s6,8
    800024ca:	01790c63          	beq	s2,s7,800024e2 <fork+0xfc>
    if(p->ofile[i])
    800024ce:	00093503          	ld	a0,0(s2)
    800024d2:	d975                	beqz	a0,800024c6 <fork+0xe0>
      np->ofile[i] = filedup(p->ofile[i]);
    800024d4:	00003097          	auipc	ra,0x3
    800024d8:	a92080e7          	jalr	-1390(ra) # 80004f66 <filedup>
    800024dc:	00ab3023          	sd	a0,0(s6)
    800024e0:	b7dd                	j	800024c6 <fork+0xe0>
  np->cwd = idup(p->cwd);
    800024e2:	150ab503          	ld	a0,336(s5)
    800024e6:	00002097          	auipc	ra,0x2
    800024ea:	8aa080e7          	jalr	-1878(ra) # 80003d90 <idup>
    800024ee:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800024f2:	4641                	li	a2,16
    800024f4:	158a8593          	addi	a1,s5,344
    800024f8:	15898513          	addi	a0,s3,344
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	914080e7          	jalr	-1772(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002504:	0309ab03          	lw	s6,48(s3)
  release(&np->lock);
    80002508:	854e                	mv	a0,s3
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	76c080e7          	jalr	1900(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80002512:	0000f917          	auipc	s2,0xf
    80002516:	da690913          	addi	s2,s2,-602 # 800112b8 <wait_lock>
    8000251a:	854a                	mv	a0,s2
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	6a6080e7          	jalr	1702(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002524:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002528:	854a                	mv	a0,s2
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	74c080e7          	jalr	1868(ra) # 80000c76 <release>
  if (np->pid > 2)
    80002532:	0309a703          	lw	a4,48(s3)
    80002536:	4789                	li	a5,2
    80002538:	02e7cb63          	blt	a5,a4,8000256e <fork+0x188>
  acquire(&np->lock);
    8000253c:	854e                	mv	a0,s3
    8000253e:	ffffe097          	auipc	ra,0xffffe
    80002542:	684080e7          	jalr	1668(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002546:	478d                	li	a5,3
    80002548:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000254c:	854e                	mv	a0,s3
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	728080e7          	jalr	1832(ra) # 80000c76 <release>
}
    80002556:	855a                	mv	a0,s6
    80002558:	60a6                	ld	ra,72(sp)
    8000255a:	6406                	ld	s0,64(sp)
    8000255c:	74e2                	ld	s1,56(sp)
    8000255e:	7942                	ld	s2,48(sp)
    80002560:	79a2                	ld	s3,40(sp)
    80002562:	7a02                	ld	s4,32(sp)
    80002564:	6ae2                	ld	s5,24(sp)
    80002566:	6b42                	ld	s6,16(sp)
    80002568:	6ba2                	ld	s7,8(sp)
    8000256a:	6161                	addi	sp,sp,80
    8000256c:	8082                	ret
    createSwapFile(np);
    8000256e:	854e                	mv	a0,s3
    80002570:	00002097          	auipc	ra,0x2
    80002574:	268080e7          	jalr	616(ra) # 800047d8 <createSwapFile>
    for(pg = p->pages ; pg < &p->pages[MAX_TOTAL_PAGES] ; pg++)
    80002578:	a029                	j	80002582 <fork+0x19c>
    8000257a:	02048493          	addi	s1,s1,32
    8000257e:	fb448fe3          	beq	s1,s4,8000253c <fork+0x156>
      if (pg->used && pg->on_disk)
    80002582:	4c9c                	lw	a5,24(s1)
    80002584:	dbfd                	beqz	a5,8000257a <fork+0x194>
    80002586:	489c                	lw	a5,16(s1)
    80002588:	dbed                	beqz	a5,8000257a <fork+0x194>
        char* mem = kalloc();
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	548080e7          	jalr	1352(ra) # 80000ad2 <kalloc>
    80002592:	892a                	mv	s2,a0
        readFromSwapFile(p, mem, pg->offset, PGSIZE);
    80002594:	6685                	lui	a3,0x1
    80002596:	48d0                	lw	a2,20(s1)
    80002598:	85aa                	mv	a1,a0
    8000259a:	8556                	mv	a0,s5
    8000259c:	00002097          	auipc	ra,0x2
    800025a0:	346080e7          	jalr	838(ra) # 800048e2 <readFromSwapFile>
        writeToSwapFile(np, mem, pg->offset, PGSIZE);
    800025a4:	6685                	lui	a3,0x1
    800025a6:	48d0                	lw	a2,20(s1)
    800025a8:	85ca                	mv	a1,s2
    800025aa:	854e                	mv	a0,s3
    800025ac:	00002097          	auipc	ra,0x2
    800025b0:	312080e7          	jalr	786(ra) # 800048be <writeToSwapFile>
        kfree(mem);
    800025b4:	854a                	mv	a0,s2
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	420080e7          	jalr	1056(ra) # 800009d6 <kfree>
    800025be:	bf75                	j	8000257a <fork+0x194>
    return -1;
    800025c0:	5b7d                	li	s6,-1
    800025c2:	bf51                	j	80002556 <fork+0x170>

00000000800025c4 <scheduler>:
{
    800025c4:	7139                	addi	sp,sp,-64
    800025c6:	fc06                	sd	ra,56(sp)
    800025c8:	f822                	sd	s0,48(sp)
    800025ca:	f426                	sd	s1,40(sp)
    800025cc:	f04a                	sd	s2,32(sp)
    800025ce:	ec4e                	sd	s3,24(sp)
    800025d0:	e852                	sd	s4,16(sp)
    800025d2:	e456                	sd	s5,8(sp)
    800025d4:	e05a                	sd	s6,0(sp)
    800025d6:	0080                	addi	s0,sp,64
    800025d8:	8792                	mv	a5,tp
  int id = r_tp();
    800025da:	2781                	sext.w	a5,a5
  c->proc = 0;
    800025dc:	00779a93          	slli	s5,a5,0x7
    800025e0:	0000f717          	auipc	a4,0xf
    800025e4:	cc070713          	addi	a4,a4,-832 # 800112a0 <pid_lock>
    800025e8:	9756                	add	a4,a4,s5
    800025ea:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800025ee:	0000f717          	auipc	a4,0xf
    800025f2:	cea70713          	addi	a4,a4,-790 # 800112d8 <cpus+0x8>
    800025f6:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    800025f8:	498d                	li	s3,3
        p->state = RUNNING;
    800025fa:	4b11                	li	s6,4
        c->proc = p;
    800025fc:	079e                	slli	a5,a5,0x7
    800025fe:	0000fa17          	auipc	s4,0xf
    80002602:	ca2a0a13          	addi	s4,s4,-862 # 800112a0 <pid_lock>
    80002606:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002608:	00025917          	auipc	s2,0x25
    8000260c:	cc890913          	addi	s2,s2,-824 # 800272d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002610:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002614:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002618:	10079073          	csrw	sstatus,a5
    8000261c:	0000f497          	auipc	s1,0xf
    80002620:	0b448493          	addi	s1,s1,180 # 800116d0 <proc>
    80002624:	a811                	j	80002638 <scheduler+0x74>
      release(&p->lock);
    80002626:	8526                	mv	a0,s1
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	64e080e7          	jalr	1614(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002630:	57048493          	addi	s1,s1,1392
    80002634:	fd248ee3          	beq	s1,s2,80002610 <scheduler+0x4c>
      acquire(&p->lock);
    80002638:	8526                	mv	a0,s1
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	588080e7          	jalr	1416(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    80002642:	4c9c                	lw	a5,24(s1)
    80002644:	ff3791e3          	bne	a5,s3,80002626 <scheduler+0x62>
        p->state = RUNNING;
    80002648:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000264c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002650:	06048593          	addi	a1,s1,96
    80002654:	8556                	mv	a0,s5
    80002656:	00000097          	auipc	ra,0x0
    8000265a:	640080e7          	jalr	1600(ra) # 80002c96 <swtch>
        c->proc = 0;
    8000265e:	020a3823          	sd	zero,48(s4)
    80002662:	b7d1                	j	80002626 <scheduler+0x62>

0000000080002664 <sched>:
{
    80002664:	7179                	addi	sp,sp,-48
    80002666:	f406                	sd	ra,40(sp)
    80002668:	f022                	sd	s0,32(sp)
    8000266a:	ec26                	sd	s1,24(sp)
    8000266c:	e84a                	sd	s2,16(sp)
    8000266e:	e44e                	sd	s3,8(sp)
    80002670:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002672:	00000097          	auipc	ra,0x0
    80002676:	94e080e7          	jalr	-1714(ra) # 80001fc0 <myproc>
    8000267a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	4cc080e7          	jalr	1228(ra) # 80000b48 <holding>
    80002684:	c93d                	beqz	a0,800026fa <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002686:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002688:	2781                	sext.w	a5,a5
    8000268a:	079e                	slli	a5,a5,0x7
    8000268c:	0000f717          	auipc	a4,0xf
    80002690:	c1470713          	addi	a4,a4,-1004 # 800112a0 <pid_lock>
    80002694:	97ba                	add	a5,a5,a4
    80002696:	0a87a703          	lw	a4,168(a5)
    8000269a:	4785                	li	a5,1
    8000269c:	06f71763          	bne	a4,a5,8000270a <sched+0xa6>
  if(p->state == RUNNING)
    800026a0:	4c98                	lw	a4,24(s1)
    800026a2:	4791                	li	a5,4
    800026a4:	06f70b63          	beq	a4,a5,8000271a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026ac:	8b89                	andi	a5,a5,2
  if(intr_get())
    800026ae:	efb5                	bnez	a5,8000272a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800026b0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800026b2:	0000f917          	auipc	s2,0xf
    800026b6:	bee90913          	addi	s2,s2,-1042 # 800112a0 <pid_lock>
    800026ba:	2781                	sext.w	a5,a5
    800026bc:	079e                	slli	a5,a5,0x7
    800026be:	97ca                	add	a5,a5,s2
    800026c0:	0ac7a983          	lw	s3,172(a5)
    800026c4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800026c6:	2781                	sext.w	a5,a5
    800026c8:	079e                	slli	a5,a5,0x7
    800026ca:	0000f597          	auipc	a1,0xf
    800026ce:	c0e58593          	addi	a1,a1,-1010 # 800112d8 <cpus+0x8>
    800026d2:	95be                	add	a1,a1,a5
    800026d4:	06048513          	addi	a0,s1,96
    800026d8:	00000097          	auipc	ra,0x0
    800026dc:	5be080e7          	jalr	1470(ra) # 80002c96 <swtch>
    800026e0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800026e2:	2781                	sext.w	a5,a5
    800026e4:	079e                	slli	a5,a5,0x7
    800026e6:	97ca                	add	a5,a5,s2
    800026e8:	0b37a623          	sw	s3,172(a5)
}
    800026ec:	70a2                	ld	ra,40(sp)
    800026ee:	7402                	ld	s0,32(sp)
    800026f0:	64e2                	ld	s1,24(sp)
    800026f2:	6942                	ld	s2,16(sp)
    800026f4:	69a2                	ld	s3,8(sp)
    800026f6:	6145                	addi	sp,sp,48
    800026f8:	8082                	ret
    panic("sched p->lock");
    800026fa:	00006517          	auipc	a0,0x6
    800026fe:	bf650513          	addi	a0,a0,-1034 # 800082f0 <digits+0x2b0>
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	e28080e7          	jalr	-472(ra) # 8000052a <panic>
    panic("sched locks");
    8000270a:	00006517          	auipc	a0,0x6
    8000270e:	bf650513          	addi	a0,a0,-1034 # 80008300 <digits+0x2c0>
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	e18080e7          	jalr	-488(ra) # 8000052a <panic>
    panic("sched running");
    8000271a:	00006517          	auipc	a0,0x6
    8000271e:	bf650513          	addi	a0,a0,-1034 # 80008310 <digits+0x2d0>
    80002722:	ffffe097          	auipc	ra,0xffffe
    80002726:	e08080e7          	jalr	-504(ra) # 8000052a <panic>
    panic("sched interruptible");
    8000272a:	00006517          	auipc	a0,0x6
    8000272e:	bf650513          	addi	a0,a0,-1034 # 80008320 <digits+0x2e0>
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	df8080e7          	jalr	-520(ra) # 8000052a <panic>

000000008000273a <yield>:
{
    8000273a:	1101                	addi	sp,sp,-32
    8000273c:	ec06                	sd	ra,24(sp)
    8000273e:	e822                	sd	s0,16(sp)
    80002740:	e426                	sd	s1,8(sp)
    80002742:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002744:	00000097          	auipc	ra,0x0
    80002748:	87c080e7          	jalr	-1924(ra) # 80001fc0 <myproc>
    8000274c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000274e:	ffffe097          	auipc	ra,0xffffe
    80002752:	474080e7          	jalr	1140(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80002756:	478d                	li	a5,3
    80002758:	cc9c                	sw	a5,24(s1)
  sched();
    8000275a:	00000097          	auipc	ra,0x0
    8000275e:	f0a080e7          	jalr	-246(ra) # 80002664 <sched>
  release(&p->lock);
    80002762:	8526                	mv	a0,s1
    80002764:	ffffe097          	auipc	ra,0xffffe
    80002768:	512080e7          	jalr	1298(ra) # 80000c76 <release>
}
    8000276c:	60e2                	ld	ra,24(sp)
    8000276e:	6442                	ld	s0,16(sp)
    80002770:	64a2                	ld	s1,8(sp)
    80002772:	6105                	addi	sp,sp,32
    80002774:	8082                	ret

0000000080002776 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002776:	7179                	addi	sp,sp,-48
    80002778:	f406                	sd	ra,40(sp)
    8000277a:	f022                	sd	s0,32(sp)
    8000277c:	ec26                	sd	s1,24(sp)
    8000277e:	e84a                	sd	s2,16(sp)
    80002780:	e44e                	sd	s3,8(sp)
    80002782:	1800                	addi	s0,sp,48
    80002784:	89aa                	mv	s3,a0
    80002786:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002788:	00000097          	auipc	ra,0x0
    8000278c:	838080e7          	jalr	-1992(ra) # 80001fc0 <myproc>
    80002790:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	430080e7          	jalr	1072(ra) # 80000bc2 <acquire>
  release(lk);
    8000279a:	854a                	mv	a0,s2
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	4da080e7          	jalr	1242(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    800027a4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800027a8:	4789                	li	a5,2
    800027aa:	cc9c                	sw	a5,24(s1)

  sched();
    800027ac:	00000097          	auipc	ra,0x0
    800027b0:	eb8080e7          	jalr	-328(ra) # 80002664 <sched>

  // Tidy up.
  p->chan = 0;
    800027b4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800027b8:	8526                	mv	a0,s1
    800027ba:	ffffe097          	auipc	ra,0xffffe
    800027be:	4bc080e7          	jalr	1212(ra) # 80000c76 <release>
  acquire(lk);
    800027c2:	854a                	mv	a0,s2
    800027c4:	ffffe097          	auipc	ra,0xffffe
    800027c8:	3fe080e7          	jalr	1022(ra) # 80000bc2 <acquire>
}
    800027cc:	70a2                	ld	ra,40(sp)
    800027ce:	7402                	ld	s0,32(sp)
    800027d0:	64e2                	ld	s1,24(sp)
    800027d2:	6942                	ld	s2,16(sp)
    800027d4:	69a2                	ld	s3,8(sp)
    800027d6:	6145                	addi	sp,sp,48
    800027d8:	8082                	ret

00000000800027da <wait>:
{
    800027da:	715d                	addi	sp,sp,-80
    800027dc:	e486                	sd	ra,72(sp)
    800027de:	e0a2                	sd	s0,64(sp)
    800027e0:	fc26                	sd	s1,56(sp)
    800027e2:	f84a                	sd	s2,48(sp)
    800027e4:	f44e                	sd	s3,40(sp)
    800027e6:	f052                	sd	s4,32(sp)
    800027e8:	ec56                	sd	s5,24(sp)
    800027ea:	e85a                	sd	s6,16(sp)
    800027ec:	e45e                	sd	s7,8(sp)
    800027ee:	e062                	sd	s8,0(sp)
    800027f0:	0880                	addi	s0,sp,80
    800027f2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800027f4:	fffff097          	auipc	ra,0xfffff
    800027f8:	7cc080e7          	jalr	1996(ra) # 80001fc0 <myproc>
    800027fc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800027fe:	0000f517          	auipc	a0,0xf
    80002802:	aba50513          	addi	a0,a0,-1350 # 800112b8 <wait_lock>
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	3bc080e7          	jalr	956(ra) # 80000bc2 <acquire>
    havekids = 0;
    8000280e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002810:	4a15                	li	s4,5
        havekids = 1;
    80002812:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002814:	00025997          	auipc	s3,0x25
    80002818:	abc98993          	addi	s3,s3,-1348 # 800272d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000281c:	0000fc17          	auipc	s8,0xf
    80002820:	a9cc0c13          	addi	s8,s8,-1380 # 800112b8 <wait_lock>
    havekids = 0;
    80002824:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002826:	0000f497          	auipc	s1,0xf
    8000282a:	eaa48493          	addi	s1,s1,-342 # 800116d0 <proc>
    8000282e:	a0bd                	j	8000289c <wait+0xc2>
          pid = np->pid;
    80002830:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002834:	000b0e63          	beqz	s6,80002850 <wait+0x76>
    80002838:	4691                	li	a3,4
    8000283a:	02c48613          	addi	a2,s1,44
    8000283e:	85da                	mv	a1,s6
    80002840:	05093503          	ld	a0,80(s2)
    80002844:	fffff097          	auipc	ra,0xfffff
    80002848:	b3a080e7          	jalr	-1222(ra) # 8000137e <copyout>
    8000284c:	02054563          	bltz	a0,80002876 <wait+0x9c>
          freeproc(np);
    80002850:	8526                	mv	a0,s1
    80002852:	00000097          	auipc	ra,0x0
    80002856:	95c080e7          	jalr	-1700(ra) # 800021ae <freeproc>
          release(&np->lock);
    8000285a:	8526                	mv	a0,s1
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	41a080e7          	jalr	1050(ra) # 80000c76 <release>
          release(&wait_lock);
    80002864:	0000f517          	auipc	a0,0xf
    80002868:	a5450513          	addi	a0,a0,-1452 # 800112b8 <wait_lock>
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	40a080e7          	jalr	1034(ra) # 80000c76 <release>
          return pid;
    80002874:	a09d                	j	800028da <wait+0x100>
            release(&np->lock);
    80002876:	8526                	mv	a0,s1
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	3fe080e7          	jalr	1022(ra) # 80000c76 <release>
            release(&wait_lock);
    80002880:	0000f517          	auipc	a0,0xf
    80002884:	a3850513          	addi	a0,a0,-1480 # 800112b8 <wait_lock>
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	3ee080e7          	jalr	1006(ra) # 80000c76 <release>
            return -1;
    80002890:	59fd                	li	s3,-1
    80002892:	a0a1                	j	800028da <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002894:	57048493          	addi	s1,s1,1392
    80002898:	03348463          	beq	s1,s3,800028c0 <wait+0xe6>
      if(np->parent == p){
    8000289c:	7c9c                	ld	a5,56(s1)
    8000289e:	ff279be3          	bne	a5,s2,80002894 <wait+0xba>
        acquire(&np->lock);
    800028a2:	8526                	mv	a0,s1
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	31e080e7          	jalr	798(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800028ac:	4c9c                	lw	a5,24(s1)
    800028ae:	f94781e3          	beq	a5,s4,80002830 <wait+0x56>
        release(&np->lock);
    800028b2:	8526                	mv	a0,s1
    800028b4:	ffffe097          	auipc	ra,0xffffe
    800028b8:	3c2080e7          	jalr	962(ra) # 80000c76 <release>
        havekids = 1;
    800028bc:	8756                	mv	a4,s5
    800028be:	bfd9                	j	80002894 <wait+0xba>
    if(!havekids || p->killed){
    800028c0:	c701                	beqz	a4,800028c8 <wait+0xee>
    800028c2:	02892783          	lw	a5,40(s2)
    800028c6:	c79d                	beqz	a5,800028f4 <wait+0x11a>
      release(&wait_lock);
    800028c8:	0000f517          	auipc	a0,0xf
    800028cc:	9f050513          	addi	a0,a0,-1552 # 800112b8 <wait_lock>
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	3a6080e7          	jalr	934(ra) # 80000c76 <release>
      return -1;
    800028d8:	59fd                	li	s3,-1
}
    800028da:	854e                	mv	a0,s3
    800028dc:	60a6                	ld	ra,72(sp)
    800028de:	6406                	ld	s0,64(sp)
    800028e0:	74e2                	ld	s1,56(sp)
    800028e2:	7942                	ld	s2,48(sp)
    800028e4:	79a2                	ld	s3,40(sp)
    800028e6:	7a02                	ld	s4,32(sp)
    800028e8:	6ae2                	ld	s5,24(sp)
    800028ea:	6b42                	ld	s6,16(sp)
    800028ec:	6ba2                	ld	s7,8(sp)
    800028ee:	6c02                	ld	s8,0(sp)
    800028f0:	6161                	addi	sp,sp,80
    800028f2:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800028f4:	85e2                	mv	a1,s8
    800028f6:	854a                	mv	a0,s2
    800028f8:	00000097          	auipc	ra,0x0
    800028fc:	e7e080e7          	jalr	-386(ra) # 80002776 <sleep>
    havekids = 0;
    80002900:	b715                	j	80002824 <wait+0x4a>

0000000080002902 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002902:	7139                	addi	sp,sp,-64
    80002904:	fc06                	sd	ra,56(sp)
    80002906:	f822                	sd	s0,48(sp)
    80002908:	f426                	sd	s1,40(sp)
    8000290a:	f04a                	sd	s2,32(sp)
    8000290c:	ec4e                	sd	s3,24(sp)
    8000290e:	e852                	sd	s4,16(sp)
    80002910:	e456                	sd	s5,8(sp)
    80002912:	0080                	addi	s0,sp,64
    80002914:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002916:	0000f497          	auipc	s1,0xf
    8000291a:	dba48493          	addi	s1,s1,-582 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000291e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002920:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002922:	00025917          	auipc	s2,0x25
    80002926:	9ae90913          	addi	s2,s2,-1618 # 800272d0 <tickslock>
    8000292a:	a811                	j	8000293e <wakeup+0x3c>
      }
      release(&p->lock);
    8000292c:	8526                	mv	a0,s1
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	348080e7          	jalr	840(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002936:	57048493          	addi	s1,s1,1392
    8000293a:	03248663          	beq	s1,s2,80002966 <wakeup+0x64>
    if(p != myproc()){
    8000293e:	fffff097          	auipc	ra,0xfffff
    80002942:	682080e7          	jalr	1666(ra) # 80001fc0 <myproc>
    80002946:	fea488e3          	beq	s1,a0,80002936 <wakeup+0x34>
      acquire(&p->lock);
    8000294a:	8526                	mv	a0,s1
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	276080e7          	jalr	630(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002954:	4c9c                	lw	a5,24(s1)
    80002956:	fd379be3          	bne	a5,s3,8000292c <wakeup+0x2a>
    8000295a:	709c                	ld	a5,32(s1)
    8000295c:	fd4798e3          	bne	a5,s4,8000292c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002960:	0154ac23          	sw	s5,24(s1)
    80002964:	b7e1                	j	8000292c <wakeup+0x2a>
    }
  }
}
    80002966:	70e2                	ld	ra,56(sp)
    80002968:	7442                	ld	s0,48(sp)
    8000296a:	74a2                	ld	s1,40(sp)
    8000296c:	7902                	ld	s2,32(sp)
    8000296e:	69e2                	ld	s3,24(sp)
    80002970:	6a42                	ld	s4,16(sp)
    80002972:	6aa2                	ld	s5,8(sp)
    80002974:	6121                	addi	sp,sp,64
    80002976:	8082                	ret

0000000080002978 <reparent>:
{
    80002978:	7179                	addi	sp,sp,-48
    8000297a:	f406                	sd	ra,40(sp)
    8000297c:	f022                	sd	s0,32(sp)
    8000297e:	ec26                	sd	s1,24(sp)
    80002980:	e84a                	sd	s2,16(sp)
    80002982:	e44e                	sd	s3,8(sp)
    80002984:	e052                	sd	s4,0(sp)
    80002986:	1800                	addi	s0,sp,48
    80002988:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000298a:	0000f497          	auipc	s1,0xf
    8000298e:	d4648493          	addi	s1,s1,-698 # 800116d0 <proc>
      pp->parent = initproc;
    80002992:	00006a17          	auipc	s4,0x6
    80002996:	69ea0a13          	addi	s4,s4,1694 # 80009030 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000299a:	00025997          	auipc	s3,0x25
    8000299e:	93698993          	addi	s3,s3,-1738 # 800272d0 <tickslock>
    800029a2:	a029                	j	800029ac <reparent+0x34>
    800029a4:	57048493          	addi	s1,s1,1392
    800029a8:	01348d63          	beq	s1,s3,800029c2 <reparent+0x4a>
    if(pp->parent == p){
    800029ac:	7c9c                	ld	a5,56(s1)
    800029ae:	ff279be3          	bne	a5,s2,800029a4 <reparent+0x2c>
      pp->parent = initproc;
    800029b2:	000a3503          	ld	a0,0(s4)
    800029b6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800029b8:	00000097          	auipc	ra,0x0
    800029bc:	f4a080e7          	jalr	-182(ra) # 80002902 <wakeup>
    800029c0:	b7d5                	j	800029a4 <reparent+0x2c>
}
    800029c2:	70a2                	ld	ra,40(sp)
    800029c4:	7402                	ld	s0,32(sp)
    800029c6:	64e2                	ld	s1,24(sp)
    800029c8:	6942                	ld	s2,16(sp)
    800029ca:	69a2                	ld	s3,8(sp)
    800029cc:	6a02                	ld	s4,0(sp)
    800029ce:	6145                	addi	sp,sp,48
    800029d0:	8082                	ret

00000000800029d2 <exit>:
{
    800029d2:	7179                	addi	sp,sp,-48
    800029d4:	f406                	sd	ra,40(sp)
    800029d6:	f022                	sd	s0,32(sp)
    800029d8:	ec26                	sd	s1,24(sp)
    800029da:	e84a                	sd	s2,16(sp)
    800029dc:	e44e                	sd	s3,8(sp)
    800029de:	e052                	sd	s4,0(sp)
    800029e0:	1800                	addi	s0,sp,48
    800029e2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800029e4:	fffff097          	auipc	ra,0xfffff
    800029e8:	5dc080e7          	jalr	1500(ra) # 80001fc0 <myproc>
    800029ec:	89aa                	mv	s3,a0
  if(p == initproc)
    800029ee:	00006797          	auipc	a5,0x6
    800029f2:	6427b783          	ld	a5,1602(a5) # 80009030 <initproc>
    800029f6:	0d050493          	addi	s1,a0,208
    800029fa:	15050913          	addi	s2,a0,336
    800029fe:	00a79d63          	bne	a5,a0,80002a18 <exit+0x46>
    panic("init exiting");
    80002a02:	00006517          	auipc	a0,0x6
    80002a06:	93650513          	addi	a0,a0,-1738 # 80008338 <digits+0x2f8>
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	b20080e7          	jalr	-1248(ra) # 8000052a <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002a12:	04a1                	addi	s1,s1,8
    80002a14:	01248b63          	beq	s1,s2,80002a2a <exit+0x58>
    if(p->ofile[fd]){
    80002a18:	6088                	ld	a0,0(s1)
    80002a1a:	dd65                	beqz	a0,80002a12 <exit+0x40>
      fileclose(f);
    80002a1c:	00002097          	auipc	ra,0x2
    80002a20:	59c080e7          	jalr	1436(ra) # 80004fb8 <fileclose>
      p->ofile[fd] = 0;
    80002a24:	0004b023          	sd	zero,0(s1)
    80002a28:	b7ed                	j	80002a12 <exit+0x40>
  for (struct page* pg = p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)
    80002a2a:	17098793          	addi	a5,s3,368
    80002a2e:	57098713          	addi	a4,s3,1392
    pg->offset = 0;
    80002a32:	0007aa23          	sw	zero,20(a5)
    pg->on_disk = 0;
    80002a36:	0007a823          	sw	zero,16(a5)
    pg->used = 0;
    80002a3a:	0007ac23          	sw	zero,24(a5)
    pg->va = 0;
    80002a3e:	0007b423          	sd	zero,8(a5)
  for (struct page* pg = p->pages ; pg <&p->pages[MAX_TOTAL_PAGES] ; pg++)
    80002a42:	02078793          	addi	a5,a5,32
    80002a46:	fef716e3          	bne	a4,a5,80002a32 <exit+0x60>
  begin_op();
    80002a4a:	00002097          	auipc	ra,0x2
    80002a4e:	0a2080e7          	jalr	162(ra) # 80004aec <begin_op>
  iput(p->cwd);
    80002a52:	1509b503          	ld	a0,336(s3)
    80002a56:	00001097          	auipc	ra,0x1
    80002a5a:	532080e7          	jalr	1330(ra) # 80003f88 <iput>
  end_op();
    80002a5e:	00002097          	auipc	ra,0x2
    80002a62:	10e080e7          	jalr	270(ra) # 80004b6c <end_op>
  p->cwd = 0;
    80002a66:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002a6a:	0000f497          	auipc	s1,0xf
    80002a6e:	84e48493          	addi	s1,s1,-1970 # 800112b8 <wait_lock>
    80002a72:	8526                	mv	a0,s1
    80002a74:	ffffe097          	auipc	ra,0xffffe
    80002a78:	14e080e7          	jalr	334(ra) # 80000bc2 <acquire>
  reparent(p);
    80002a7c:	854e                	mv	a0,s3
    80002a7e:	00000097          	auipc	ra,0x0
    80002a82:	efa080e7          	jalr	-262(ra) # 80002978 <reparent>
  wakeup(p->parent);
    80002a86:	0389b503          	ld	a0,56(s3)
    80002a8a:	00000097          	auipc	ra,0x0
    80002a8e:	e78080e7          	jalr	-392(ra) # 80002902 <wakeup>
  acquire(&p->lock);
    80002a92:	854e                	mv	a0,s3
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	12e080e7          	jalr	302(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002a9c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002aa0:	4795                	li	a5,5
    80002aa2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002aa6:	8526                	mv	a0,s1
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	1ce080e7          	jalr	462(ra) # 80000c76 <release>
  sched();
    80002ab0:	00000097          	auipc	ra,0x0
    80002ab4:	bb4080e7          	jalr	-1100(ra) # 80002664 <sched>
  panic("zombie exit");
    80002ab8:	00006517          	auipc	a0,0x6
    80002abc:	89050513          	addi	a0,a0,-1904 # 80008348 <digits+0x308>
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	a6a080e7          	jalr	-1430(ra) # 8000052a <panic>

0000000080002ac8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002ac8:	7179                	addi	sp,sp,-48
    80002aca:	f406                	sd	ra,40(sp)
    80002acc:	f022                	sd	s0,32(sp)
    80002ace:	ec26                	sd	s1,24(sp)
    80002ad0:	e84a                	sd	s2,16(sp)
    80002ad2:	e44e                	sd	s3,8(sp)
    80002ad4:	1800                	addi	s0,sp,48
    80002ad6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002ad8:	0000f497          	auipc	s1,0xf
    80002adc:	bf848493          	addi	s1,s1,-1032 # 800116d0 <proc>
    80002ae0:	00024997          	auipc	s3,0x24
    80002ae4:	7f098993          	addi	s3,s3,2032 # 800272d0 <tickslock>
    acquire(&p->lock);
    80002ae8:	8526                	mv	a0,s1
    80002aea:	ffffe097          	auipc	ra,0xffffe
    80002aee:	0d8080e7          	jalr	216(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002af2:	589c                	lw	a5,48(s1)
    80002af4:	01278d63          	beq	a5,s2,80002b0e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002af8:	8526                	mv	a0,s1
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	17c080e7          	jalr	380(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b02:	57048493          	addi	s1,s1,1392
    80002b06:	ff3491e3          	bne	s1,s3,80002ae8 <kill+0x20>
  }
  return -1;
    80002b0a:	557d                	li	a0,-1
    80002b0c:	a829                	j	80002b26 <kill+0x5e>
      p->killed = 1;
    80002b0e:	4785                	li	a5,1
    80002b10:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002b12:	4c98                	lw	a4,24(s1)
    80002b14:	4789                	li	a5,2
    80002b16:	00f70f63          	beq	a4,a5,80002b34 <kill+0x6c>
      release(&p->lock);
    80002b1a:	8526                	mv	a0,s1
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	15a080e7          	jalr	346(ra) # 80000c76 <release>
      return 0;
    80002b24:	4501                	li	a0,0
}
    80002b26:	70a2                	ld	ra,40(sp)
    80002b28:	7402                	ld	s0,32(sp)
    80002b2a:	64e2                	ld	s1,24(sp)
    80002b2c:	6942                	ld	s2,16(sp)
    80002b2e:	69a2                	ld	s3,8(sp)
    80002b30:	6145                	addi	sp,sp,48
    80002b32:	8082                	ret
        p->state = RUNNABLE;
    80002b34:	478d                	li	a5,3
    80002b36:	cc9c                	sw	a5,24(s1)
    80002b38:	b7cd                	j	80002b1a <kill+0x52>

0000000080002b3a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002b3a:	7179                	addi	sp,sp,-48
    80002b3c:	f406                	sd	ra,40(sp)
    80002b3e:	f022                	sd	s0,32(sp)
    80002b40:	ec26                	sd	s1,24(sp)
    80002b42:	e84a                	sd	s2,16(sp)
    80002b44:	e44e                	sd	s3,8(sp)
    80002b46:	e052                	sd	s4,0(sp)
    80002b48:	1800                	addi	s0,sp,48
    80002b4a:	84aa                	mv	s1,a0
    80002b4c:	892e                	mv	s2,a1
    80002b4e:	89b2                	mv	s3,a2
    80002b50:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b52:	fffff097          	auipc	ra,0xfffff
    80002b56:	46e080e7          	jalr	1134(ra) # 80001fc0 <myproc>
  if(user_dst){
    80002b5a:	c08d                	beqz	s1,80002b7c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002b5c:	86d2                	mv	a3,s4
    80002b5e:	864e                	mv	a2,s3
    80002b60:	85ca                	mv	a1,s2
    80002b62:	6928                	ld	a0,80(a0)
    80002b64:	fffff097          	auipc	ra,0xfffff
    80002b68:	81a080e7          	jalr	-2022(ra) # 8000137e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002b6c:	70a2                	ld	ra,40(sp)
    80002b6e:	7402                	ld	s0,32(sp)
    80002b70:	64e2                	ld	s1,24(sp)
    80002b72:	6942                	ld	s2,16(sp)
    80002b74:	69a2                	ld	s3,8(sp)
    80002b76:	6a02                	ld	s4,0(sp)
    80002b78:	6145                	addi	sp,sp,48
    80002b7a:	8082                	ret
    memmove((char *)dst, src, len);
    80002b7c:	000a061b          	sext.w	a2,s4
    80002b80:	85ce                	mv	a1,s3
    80002b82:	854a                	mv	a0,s2
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	196080e7          	jalr	406(ra) # 80000d1a <memmove>
    return 0;
    80002b8c:	8526                	mv	a0,s1
    80002b8e:	bff9                	j	80002b6c <either_copyout+0x32>

0000000080002b90 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002b90:	7179                	addi	sp,sp,-48
    80002b92:	f406                	sd	ra,40(sp)
    80002b94:	f022                	sd	s0,32(sp)
    80002b96:	ec26                	sd	s1,24(sp)
    80002b98:	e84a                	sd	s2,16(sp)
    80002b9a:	e44e                	sd	s3,8(sp)
    80002b9c:	e052                	sd	s4,0(sp)
    80002b9e:	1800                	addi	s0,sp,48
    80002ba0:	892a                	mv	s2,a0
    80002ba2:	84ae                	mv	s1,a1
    80002ba4:	89b2                	mv	s3,a2
    80002ba6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002ba8:	fffff097          	auipc	ra,0xfffff
    80002bac:	418080e7          	jalr	1048(ra) # 80001fc0 <myproc>
  if(user_src){
    80002bb0:	c08d                	beqz	s1,80002bd2 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002bb2:	86d2                	mv	a3,s4
    80002bb4:	864e                	mv	a2,s3
    80002bb6:	85ca                	mv	a1,s2
    80002bb8:	6928                	ld	a0,80(a0)
    80002bba:	fffff097          	auipc	ra,0xfffff
    80002bbe:	850080e7          	jalr	-1968(ra) # 8000140a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002bc2:	70a2                	ld	ra,40(sp)
    80002bc4:	7402                	ld	s0,32(sp)
    80002bc6:	64e2                	ld	s1,24(sp)
    80002bc8:	6942                	ld	s2,16(sp)
    80002bca:	69a2                	ld	s3,8(sp)
    80002bcc:	6a02                	ld	s4,0(sp)
    80002bce:	6145                	addi	sp,sp,48
    80002bd0:	8082                	ret
    memmove(dst, (char*)src, len);
    80002bd2:	000a061b          	sext.w	a2,s4
    80002bd6:	85ce                	mv	a1,s3
    80002bd8:	854a                	mv	a0,s2
    80002bda:	ffffe097          	auipc	ra,0xffffe
    80002bde:	140080e7          	jalr	320(ra) # 80000d1a <memmove>
    return 0;
    80002be2:	8526                	mv	a0,s1
    80002be4:	bff9                	j	80002bc2 <either_copyin+0x32>

0000000080002be6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002be6:	715d                	addi	sp,sp,-80
    80002be8:	e486                	sd	ra,72(sp)
    80002bea:	e0a2                	sd	s0,64(sp)
    80002bec:	fc26                	sd	s1,56(sp)
    80002bee:	f84a                	sd	s2,48(sp)
    80002bf0:	f44e                	sd	s3,40(sp)
    80002bf2:	f052                	sd	s4,32(sp)
    80002bf4:	ec56                	sd	s5,24(sp)
    80002bf6:	e85a                	sd	s6,16(sp)
    80002bf8:	e45e                	sd	s7,8(sp)
    80002bfa:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002bfc:	00005517          	auipc	a0,0x5
    80002c00:	5ec50513          	addi	a0,a0,1516 # 800081e8 <digits+0x1a8>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	970080e7          	jalr	-1680(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c0c:	0000f497          	auipc	s1,0xf
    80002c10:	c1c48493          	addi	s1,s1,-996 # 80011828 <proc+0x158>
    80002c14:	00025917          	auipc	s2,0x25
    80002c18:	81490913          	addi	s2,s2,-2028 # 80027428 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c1c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002c1e:	00005997          	auipc	s3,0x5
    80002c22:	73a98993          	addi	s3,s3,1850 # 80008358 <digits+0x318>
    printf("%d %s %s", p->pid, state, p->name);
    80002c26:	00005a97          	auipc	s5,0x5
    80002c2a:	73aa8a93          	addi	s5,s5,1850 # 80008360 <digits+0x320>
    printf("\n");
    80002c2e:	00005a17          	auipc	s4,0x5
    80002c32:	5baa0a13          	addi	s4,s4,1466 # 800081e8 <digits+0x1a8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c36:	00005b97          	auipc	s7,0x5
    80002c3a:	762b8b93          	addi	s7,s7,1890 # 80008398 <states.0>
    80002c3e:	a00d                	j	80002c60 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002c40:	ed86a583          	lw	a1,-296(a3) # ed8 <_entry-0x7ffff128>
    80002c44:	8556                	mv	a0,s5
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	92e080e7          	jalr	-1746(ra) # 80000574 <printf>
    printf("\n");
    80002c4e:	8552                	mv	a0,s4
    80002c50:	ffffe097          	auipc	ra,0xffffe
    80002c54:	924080e7          	jalr	-1756(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c58:	57048493          	addi	s1,s1,1392
    80002c5c:	03248263          	beq	s1,s2,80002c80 <procdump+0x9a>
    if(p->state == UNUSED)
    80002c60:	86a6                	mv	a3,s1
    80002c62:	ec04a783          	lw	a5,-320(s1)
    80002c66:	dbed                	beqz	a5,80002c58 <procdump+0x72>
      state = "???";
    80002c68:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c6a:	fcfb6be3          	bltu	s6,a5,80002c40 <procdump+0x5a>
    80002c6e:	02079713          	slli	a4,a5,0x20
    80002c72:	01d75793          	srli	a5,a4,0x1d
    80002c76:	97de                	add	a5,a5,s7
    80002c78:	6390                	ld	a2,0(a5)
    80002c7a:	f279                	bnez	a2,80002c40 <procdump+0x5a>
      state = "???";
    80002c7c:	864e                	mv	a2,s3
    80002c7e:	b7c9                	j	80002c40 <procdump+0x5a>
  }
}
    80002c80:	60a6                	ld	ra,72(sp)
    80002c82:	6406                	ld	s0,64(sp)
    80002c84:	74e2                	ld	s1,56(sp)
    80002c86:	7942                	ld	s2,48(sp)
    80002c88:	79a2                	ld	s3,40(sp)
    80002c8a:	7a02                	ld	s4,32(sp)
    80002c8c:	6ae2                	ld	s5,24(sp)
    80002c8e:	6b42                	ld	s6,16(sp)
    80002c90:	6ba2                	ld	s7,8(sp)
    80002c92:	6161                	addi	sp,sp,80
    80002c94:	8082                	ret

0000000080002c96 <swtch>:
    80002c96:	00153023          	sd	ra,0(a0)
    80002c9a:	00253423          	sd	sp,8(a0)
    80002c9e:	e900                	sd	s0,16(a0)
    80002ca0:	ed04                	sd	s1,24(a0)
    80002ca2:	03253023          	sd	s2,32(a0)
    80002ca6:	03353423          	sd	s3,40(a0)
    80002caa:	03453823          	sd	s4,48(a0)
    80002cae:	03553c23          	sd	s5,56(a0)
    80002cb2:	05653023          	sd	s6,64(a0)
    80002cb6:	05753423          	sd	s7,72(a0)
    80002cba:	05853823          	sd	s8,80(a0)
    80002cbe:	05953c23          	sd	s9,88(a0)
    80002cc2:	07a53023          	sd	s10,96(a0)
    80002cc6:	07b53423          	sd	s11,104(a0)
    80002cca:	0005b083          	ld	ra,0(a1)
    80002cce:	0085b103          	ld	sp,8(a1)
    80002cd2:	6980                	ld	s0,16(a1)
    80002cd4:	6d84                	ld	s1,24(a1)
    80002cd6:	0205b903          	ld	s2,32(a1)
    80002cda:	0285b983          	ld	s3,40(a1)
    80002cde:	0305ba03          	ld	s4,48(a1)
    80002ce2:	0385ba83          	ld	s5,56(a1)
    80002ce6:	0405bb03          	ld	s6,64(a1)
    80002cea:	0485bb83          	ld	s7,72(a1)
    80002cee:	0505bc03          	ld	s8,80(a1)
    80002cf2:	0585bc83          	ld	s9,88(a1)
    80002cf6:	0605bd03          	ld	s10,96(a1)
    80002cfa:	0685bd83          	ld	s11,104(a1)
    80002cfe:	8082                	ret

0000000080002d00 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002d00:	1141                	addi	sp,sp,-16
    80002d02:	e406                	sd	ra,8(sp)
    80002d04:	e022                	sd	s0,0(sp)
    80002d06:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002d08:	00005597          	auipc	a1,0x5
    80002d0c:	6c058593          	addi	a1,a1,1728 # 800083c8 <states.0+0x30>
    80002d10:	00024517          	auipc	a0,0x24
    80002d14:	5c050513          	addi	a0,a0,1472 # 800272d0 <tickslock>
    80002d18:	ffffe097          	auipc	ra,0xffffe
    80002d1c:	e1a080e7          	jalr	-486(ra) # 80000b32 <initlock>
}
    80002d20:	60a2                	ld	ra,8(sp)
    80002d22:	6402                	ld	s0,0(sp)
    80002d24:	0141                	addi	sp,sp,16
    80002d26:	8082                	ret

0000000080002d28 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002d28:	1141                	addi	sp,sp,-16
    80002d2a:	e422                	sd	s0,8(sp)
    80002d2c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d2e:	00004797          	auipc	a5,0x4
    80002d32:	ae278793          	addi	a5,a5,-1310 # 80006810 <kernelvec>
    80002d36:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002d3a:	6422                	ld	s0,8(sp)
    80002d3c:	0141                	addi	sp,sp,16
    80002d3e:	8082                	ret

0000000080002d40 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002d40:	1141                	addi	sp,sp,-16
    80002d42:	e406                	sd	ra,8(sp)
    80002d44:	e022                	sd	s0,0(sp)
    80002d46:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002d48:	fffff097          	auipc	ra,0xfffff
    80002d4c:	278080e7          	jalr	632(ra) # 80001fc0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d54:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d56:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002d5a:	00004617          	auipc	a2,0x4
    80002d5e:	2a660613          	addi	a2,a2,678 # 80007000 <_trampoline>
    80002d62:	00004697          	auipc	a3,0x4
    80002d66:	29e68693          	addi	a3,a3,670 # 80007000 <_trampoline>
    80002d6a:	8e91                	sub	a3,a3,a2
    80002d6c:	040007b7          	lui	a5,0x4000
    80002d70:	17fd                	addi	a5,a5,-1
    80002d72:	07b2                	slli	a5,a5,0xc
    80002d74:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d76:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d7a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d7c:	180026f3          	csrr	a3,satp
    80002d80:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d82:	6d38                	ld	a4,88(a0)
    80002d84:	6134                	ld	a3,64(a0)
    80002d86:	6585                	lui	a1,0x1
    80002d88:	96ae                	add	a3,a3,a1
    80002d8a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d8c:	6d38                	ld	a4,88(a0)
    80002d8e:	00000697          	auipc	a3,0x0
    80002d92:	13868693          	addi	a3,a3,312 # 80002ec6 <usertrap>
    80002d96:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002d98:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d9a:	8692                	mv	a3,tp
    80002d9c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d9e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002da2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002da6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002daa:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002dae:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002db0:	6f18                	ld	a4,24(a4)
    80002db2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002db6:	692c                	ld	a1,80(a0)
    80002db8:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002dba:	00004717          	auipc	a4,0x4
    80002dbe:	2d670713          	addi	a4,a4,726 # 80007090 <userret>
    80002dc2:	8f11                	sub	a4,a4,a2
    80002dc4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002dc6:	577d                	li	a4,-1
    80002dc8:	177e                	slli	a4,a4,0x3f
    80002dca:	8dd9                	or	a1,a1,a4
    80002dcc:	02000537          	lui	a0,0x2000
    80002dd0:	157d                	addi	a0,a0,-1
    80002dd2:	0536                	slli	a0,a0,0xd
    80002dd4:	9782                	jalr	a5
}
    80002dd6:	60a2                	ld	ra,8(sp)
    80002dd8:	6402                	ld	s0,0(sp)
    80002dda:	0141                	addi	sp,sp,16
    80002ddc:	8082                	ret

0000000080002dde <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002dde:	1101                	addi	sp,sp,-32
    80002de0:	ec06                	sd	ra,24(sp)
    80002de2:	e822                	sd	s0,16(sp)
    80002de4:	e426                	sd	s1,8(sp)
    80002de6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002de8:	00024497          	auipc	s1,0x24
    80002dec:	4e848493          	addi	s1,s1,1256 # 800272d0 <tickslock>
    80002df0:	8526                	mv	a0,s1
    80002df2:	ffffe097          	auipc	ra,0xffffe
    80002df6:	dd0080e7          	jalr	-560(ra) # 80000bc2 <acquire>
  ticks++;
    80002dfa:	00006517          	auipc	a0,0x6
    80002dfe:	23e50513          	addi	a0,a0,574 # 80009038 <ticks>
    80002e02:	411c                	lw	a5,0(a0)
    80002e04:	2785                	addiw	a5,a5,1
    80002e06:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002e08:	00000097          	auipc	ra,0x0
    80002e0c:	afa080e7          	jalr	-1286(ra) # 80002902 <wakeup>
  release(&tickslock);
    80002e10:	8526                	mv	a0,s1
    80002e12:	ffffe097          	auipc	ra,0xffffe
    80002e16:	e64080e7          	jalr	-412(ra) # 80000c76 <release>
}
    80002e1a:	60e2                	ld	ra,24(sp)
    80002e1c:	6442                	ld	s0,16(sp)
    80002e1e:	64a2                	ld	s1,8(sp)
    80002e20:	6105                	addi	sp,sp,32
    80002e22:	8082                	ret

0000000080002e24 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002e24:	1101                	addi	sp,sp,-32
    80002e26:	ec06                	sd	ra,24(sp)
    80002e28:	e822                	sd	s0,16(sp)
    80002e2a:	e426                	sd	s1,8(sp)
    80002e2c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e2e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002e32:	00074d63          	bltz	a4,80002e4c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002e36:	57fd                	li	a5,-1
    80002e38:	17fe                	slli	a5,a5,0x3f
    80002e3a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002e3c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002e3e:	06f70363          	beq	a4,a5,80002ea4 <devintr+0x80>
  }
}
    80002e42:	60e2                	ld	ra,24(sp)
    80002e44:	6442                	ld	s0,16(sp)
    80002e46:	64a2                	ld	s1,8(sp)
    80002e48:	6105                	addi	sp,sp,32
    80002e4a:	8082                	ret
     (scause & 0xff) == 9){
    80002e4c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002e50:	46a5                	li	a3,9
    80002e52:	fed792e3          	bne	a5,a3,80002e36 <devintr+0x12>
    int irq = plic_claim();
    80002e56:	00004097          	auipc	ra,0x4
    80002e5a:	ac2080e7          	jalr	-1342(ra) # 80006918 <plic_claim>
    80002e5e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002e60:	47a9                	li	a5,10
    80002e62:	02f50763          	beq	a0,a5,80002e90 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002e66:	4785                	li	a5,1
    80002e68:	02f50963          	beq	a0,a5,80002e9a <devintr+0x76>
    return 1;
    80002e6c:	4505                	li	a0,1
    } else if(irq){
    80002e6e:	d8f1                	beqz	s1,80002e42 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002e70:	85a6                	mv	a1,s1
    80002e72:	00005517          	auipc	a0,0x5
    80002e76:	55e50513          	addi	a0,a0,1374 # 800083d0 <states.0+0x38>
    80002e7a:	ffffd097          	auipc	ra,0xffffd
    80002e7e:	6fa080e7          	jalr	1786(ra) # 80000574 <printf>
      plic_complete(irq);
    80002e82:	8526                	mv	a0,s1
    80002e84:	00004097          	auipc	ra,0x4
    80002e88:	ab8080e7          	jalr	-1352(ra) # 8000693c <plic_complete>
    return 1;
    80002e8c:	4505                	li	a0,1
    80002e8e:	bf55                	j	80002e42 <devintr+0x1e>
      uartintr();
    80002e90:	ffffe097          	auipc	ra,0xffffe
    80002e94:	af6080e7          	jalr	-1290(ra) # 80000986 <uartintr>
    80002e98:	b7ed                	j	80002e82 <devintr+0x5e>
      virtio_disk_intr();
    80002e9a:	00004097          	auipc	ra,0x4
    80002e9e:	f34080e7          	jalr	-204(ra) # 80006dce <virtio_disk_intr>
    80002ea2:	b7c5                	j	80002e82 <devintr+0x5e>
    if(cpuid() == 0){
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	0f0080e7          	jalr	240(ra) # 80001f94 <cpuid>
    80002eac:	c901                	beqz	a0,80002ebc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002eae:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002eb2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002eb4:	14479073          	csrw	sip,a5
    return 2;
    80002eb8:	4509                	li	a0,2
    80002eba:	b761                	j	80002e42 <devintr+0x1e>
      clockintr();
    80002ebc:	00000097          	auipc	ra,0x0
    80002ec0:	f22080e7          	jalr	-222(ra) # 80002dde <clockintr>
    80002ec4:	b7ed                	j	80002eae <devintr+0x8a>

0000000080002ec6 <usertrap>:
{
    80002ec6:	7179                	addi	sp,sp,-48
    80002ec8:	f406                	sd	ra,40(sp)
    80002eca:	f022                	sd	s0,32(sp)
    80002ecc:	ec26                	sd	s1,24(sp)
    80002ece:	e84a                	sd	s2,16(sp)
    80002ed0:	e44e                	sd	s3,8(sp)
    80002ed2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ed4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ed8:	1007f793          	andi	a5,a5,256
    80002edc:	e3bd                	bnez	a5,80002f42 <usertrap+0x7c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ede:	00004797          	auipc	a5,0x4
    80002ee2:	93278793          	addi	a5,a5,-1742 # 80006810 <kernelvec>
    80002ee6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	0d6080e7          	jalr	214(ra) # 80001fc0 <myproc>
    80002ef2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ef4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ef6:	14102773          	csrr	a4,sepc
    80002efa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002efc:	14202773          	csrr	a4,scause
  if(r_scause() == 8)
    80002f00:	47a1                	li	a5,8
    80002f02:	04f71e63          	bne	a4,a5,80002f5e <usertrap+0x98>
    if(p->killed)
    80002f06:	551c                	lw	a5,40(a0)
    80002f08:	e7a9                	bnez	a5,80002f52 <usertrap+0x8c>
    p->trapframe->epc += 4;
    80002f0a:	6cb8                	ld	a4,88(s1)
    80002f0c:	6f1c                	ld	a5,24(a4)
    80002f0e:	0791                	addi	a5,a5,4
    80002f10:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f16:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f1a:	10079073          	csrw	sstatus,a5
    syscall();
    80002f1e:	00000097          	auipc	ra,0x0
    80002f22:	398080e7          	jalr	920(ra) # 800032b6 <syscall>
  if(p->killed)
    80002f26:	549c                	lw	a5,40(s1)
    80002f28:	14079463          	bnez	a5,80003070 <usertrap+0x1aa>
  usertrapret();
    80002f2c:	00000097          	auipc	ra,0x0
    80002f30:	e14080e7          	jalr	-492(ra) # 80002d40 <usertrapret>
}
    80002f34:	70a2                	ld	ra,40(sp)
    80002f36:	7402                	ld	s0,32(sp)
    80002f38:	64e2                	ld	s1,24(sp)
    80002f3a:	6942                	ld	s2,16(sp)
    80002f3c:	69a2                	ld	s3,8(sp)
    80002f3e:	6145                	addi	sp,sp,48
    80002f40:	8082                	ret
    panic("usertrap: not from user mode");
    80002f42:	00005517          	auipc	a0,0x5
    80002f46:	4ae50513          	addi	a0,a0,1198 # 800083f0 <states.0+0x58>
    80002f4a:	ffffd097          	auipc	ra,0xffffd
    80002f4e:	5e0080e7          	jalr	1504(ra) # 8000052a <panic>
      exit(-1);
    80002f52:	557d                	li	a0,-1
    80002f54:	00000097          	auipc	ra,0x0
    80002f58:	a7e080e7          	jalr	-1410(ra) # 800029d2 <exit>
    80002f5c:	b77d                	j	80002f0a <usertrap+0x44>
  else if((which_dev = devintr()) != 0)
    80002f5e:	00000097          	auipc	ra,0x0
    80002f62:	ec6080e7          	jalr	-314(ra) # 80002e24 <devintr>
    80002f66:	892a                	mv	s2,a0
    80002f68:	10051163          	bnez	a0,8000306a <usertrap+0x1a4>
  else if ((p->pid > 2) && (r_scause() == 13 || r_scause() == 15 || r_scause() == 12))
    80002f6c:	5890                	lw	a2,48(s1)
    80002f6e:	4789                	li	a5,2
    80002f70:	02c7d163          	bge	a5,a2,80002f92 <usertrap+0xcc>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f74:	14202773          	csrr	a4,scause
    80002f78:	47b5                	li	a5,13
    80002f7a:	06f70163          	beq	a4,a5,80002fdc <usertrap+0x116>
    80002f7e:	14202773          	csrr	a4,scause
    80002f82:	47bd                	li	a5,15
    80002f84:	04f70c63          	beq	a4,a5,80002fdc <usertrap+0x116>
    80002f88:	14202773          	csrr	a4,scause
    80002f8c:	47b1                	li	a5,12
    80002f8e:	04f70763          	beq	a4,a5,80002fdc <usertrap+0x116>
    80002f92:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f96:	00005517          	auipc	a0,0x5
    80002f9a:	4a250513          	addi	a0,a0,1186 # 80008438 <states.0+0xa0>
    80002f9e:	ffffd097          	auipc	ra,0xffffd
    80002fa2:	5d6080e7          	jalr	1494(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fa6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002faa:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fae:	00005517          	auipc	a0,0x5
    80002fb2:	4ba50513          	addi	a0,a0,1210 # 80008468 <states.0+0xd0>
    80002fb6:	ffffd097          	auipc	ra,0xffffd
    80002fba:	5be080e7          	jalr	1470(ra) # 80000574 <printf>
    p->killed = 1;
    80002fbe:	4785                	li	a5,1
    80002fc0:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002fc2:	557d                	li	a0,-1
    80002fc4:	00000097          	auipc	ra,0x0
    80002fc8:	a0e080e7          	jalr	-1522(ra) # 800029d2 <exit>
  if(which_dev == 2)
    80002fcc:	4789                	li	a5,2
    80002fce:	f4f91fe3          	bne	s2,a5,80002f2c <usertrap+0x66>
    yield();
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	768080e7          	jalr	1896(ra) # 8000273a <yield>
    80002fda:	bf89                	j	80002f2c <usertrap+0x66>
    80002fdc:	143029f3          	csrr	s3,stval
    pte_t* pte = walk(p->pagetable, fault_addr, 0);
    80002fe0:	4601                	li	a2,0
    80002fe2:	85ce                	mv	a1,s3
    80002fe4:	68a8                	ld	a0,80(s1)
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	fc0080e7          	jalr	-64(ra) # 80000fa6 <walk>
    if ((*pte & PTE_PG))
    80002fee:	611c                	ld	a5,0(a0)
    80002ff0:	2007f793          	andi	a5,a5,512
    80002ff4:	c39d                	beqz	a5,8000301a <usertrap+0x154>
      res = page_swap_in(p->pagetable, va, p);
    80002ff6:	8626                	mv	a2,s1
    80002ff8:	75fd                	lui	a1,0xfffff
    80002ffa:	00b9f5b3          	and	a1,s3,a1
    80002ffe:	68a8                	ld	a0,80(s1)
    80003000:	fffff097          	auipc	ra,0xfffff
    80003004:	8ea080e7          	jalr	-1814(ra) # 800018ea <page_swap_in>
      if (res != 0)
    80003008:	dd19                	beqz	a0,80002f26 <usertrap+0x60>
        printf("swap_in failed\n");   
    8000300a:	00005517          	auipc	a0,0x5
    8000300e:	40650513          	addi	a0,a0,1030 # 80008410 <states.0+0x78>
    80003012:	ffffd097          	auipc	ra,0xffffd
    80003016:	562080e7          	jalr	1378(ra) # 80000574 <printf>
      print_pages(p->pagetable);
    8000301a:	68a8                	ld	a0,80(s1)
    8000301c:	fffff097          	auipc	ra,0xfffff
    80003020:	97e080e7          	jalr	-1666(ra) # 8000199a <print_pages>
      printf("fault address:%p\n",(void*) fault_addr);
    80003024:	85ce                	mv	a1,s3
    80003026:	00005517          	auipc	a0,0x5
    8000302a:	3fa50513          	addi	a0,a0,1018 # 80008420 <states.0+0x88>
    8000302e:	ffffd097          	auipc	ra,0xffffd
    80003032:	546080e7          	jalr	1350(ra) # 80000574 <printf>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003036:	142025f3          	csrr	a1,scause
      printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000303a:	5890                	lw	a2,48(s1)
    8000303c:	00005517          	auipc	a0,0x5
    80003040:	3fc50513          	addi	a0,a0,1020 # 80008438 <states.0+0xa0>
    80003044:	ffffd097          	auipc	ra,0xffffd
    80003048:	530080e7          	jalr	1328(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000304c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003050:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003054:	00005517          	auipc	a0,0x5
    80003058:	41450513          	addi	a0,a0,1044 # 80008468 <states.0+0xd0>
    8000305c:	ffffd097          	auipc	ra,0xffffd
    80003060:	518080e7          	jalr	1304(ra) # 80000574 <printf>
      p->killed = 1;
    80003064:	4785                	li	a5,1
    80003066:	d49c                	sw	a5,40(s1)
    80003068:	bfa9                	j	80002fc2 <usertrap+0xfc>
  if(p->killed)
    8000306a:	549c                	lw	a5,40(s1)
    8000306c:	d3a5                	beqz	a5,80002fcc <usertrap+0x106>
    8000306e:	bf91                	j	80002fc2 <usertrap+0xfc>
    80003070:	4901                	li	s2,0
    80003072:	bf81                	j	80002fc2 <usertrap+0xfc>

0000000080003074 <kerneltrap>:
{
    80003074:	7179                	addi	sp,sp,-48
    80003076:	f406                	sd	ra,40(sp)
    80003078:	f022                	sd	s0,32(sp)
    8000307a:	ec26                	sd	s1,24(sp)
    8000307c:	e84a                	sd	s2,16(sp)
    8000307e:	e44e                	sd	s3,8(sp)
    80003080:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003082:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003086:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000308a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000308e:	1004f793          	andi	a5,s1,256
    80003092:	cb85                	beqz	a5,800030c2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003094:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003098:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000309a:	ef85                	bnez	a5,800030d2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000309c:	00000097          	auipc	ra,0x0
    800030a0:	d88080e7          	jalr	-632(ra) # 80002e24 <devintr>
    800030a4:	cd1d                	beqz	a0,800030e2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030a6:	4789                	li	a5,2
    800030a8:	06f50a63          	beq	a0,a5,8000311c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030ac:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030b0:	10049073          	csrw	sstatus,s1
}
    800030b4:	70a2                	ld	ra,40(sp)
    800030b6:	7402                	ld	s0,32(sp)
    800030b8:	64e2                	ld	s1,24(sp)
    800030ba:	6942                	ld	s2,16(sp)
    800030bc:	69a2                	ld	s3,8(sp)
    800030be:	6145                	addi	sp,sp,48
    800030c0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800030c2:	00005517          	auipc	a0,0x5
    800030c6:	3c650513          	addi	a0,a0,966 # 80008488 <states.0+0xf0>
    800030ca:	ffffd097          	auipc	ra,0xffffd
    800030ce:	460080e7          	jalr	1120(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    800030d2:	00005517          	auipc	a0,0x5
    800030d6:	3de50513          	addi	a0,a0,990 # 800084b0 <states.0+0x118>
    800030da:	ffffd097          	auipc	ra,0xffffd
    800030de:	450080e7          	jalr	1104(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    800030e2:	85ce                	mv	a1,s3
    800030e4:	00005517          	auipc	a0,0x5
    800030e8:	3ec50513          	addi	a0,a0,1004 # 800084d0 <states.0+0x138>
    800030ec:	ffffd097          	auipc	ra,0xffffd
    800030f0:	488080e7          	jalr	1160(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030f4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030f8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030fc:	00005517          	auipc	a0,0x5
    80003100:	3e450513          	addi	a0,a0,996 # 800084e0 <states.0+0x148>
    80003104:	ffffd097          	auipc	ra,0xffffd
    80003108:	470080e7          	jalr	1136(ra) # 80000574 <printf>
    panic("kerneltrap");
    8000310c:	00005517          	auipc	a0,0x5
    80003110:	3ec50513          	addi	a0,a0,1004 # 800084f8 <states.0+0x160>
    80003114:	ffffd097          	auipc	ra,0xffffd
    80003118:	416080e7          	jalr	1046(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000311c:	fffff097          	auipc	ra,0xfffff
    80003120:	ea4080e7          	jalr	-348(ra) # 80001fc0 <myproc>
    80003124:	d541                	beqz	a0,800030ac <kerneltrap+0x38>
    80003126:	fffff097          	auipc	ra,0xfffff
    8000312a:	e9a080e7          	jalr	-358(ra) # 80001fc0 <myproc>
    8000312e:	4d18                	lw	a4,24(a0)
    80003130:	4791                	li	a5,4
    80003132:	f6f71de3          	bne	a4,a5,800030ac <kerneltrap+0x38>
    yield();
    80003136:	fffff097          	auipc	ra,0xfffff
    8000313a:	604080e7          	jalr	1540(ra) # 8000273a <yield>
    8000313e:	b7bd                	j	800030ac <kerneltrap+0x38>

0000000080003140 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003140:	1101                	addi	sp,sp,-32
    80003142:	ec06                	sd	ra,24(sp)
    80003144:	e822                	sd	s0,16(sp)
    80003146:	e426                	sd	s1,8(sp)
    80003148:	1000                	addi	s0,sp,32
    8000314a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000314c:	fffff097          	auipc	ra,0xfffff
    80003150:	e74080e7          	jalr	-396(ra) # 80001fc0 <myproc>
  switch (n) {
    80003154:	4795                	li	a5,5
    80003156:	0497e163          	bltu	a5,s1,80003198 <argraw+0x58>
    8000315a:	048a                	slli	s1,s1,0x2
    8000315c:	00005717          	auipc	a4,0x5
    80003160:	3d470713          	addi	a4,a4,980 # 80008530 <states.0+0x198>
    80003164:	94ba                	add	s1,s1,a4
    80003166:	409c                	lw	a5,0(s1)
    80003168:	97ba                	add	a5,a5,a4
    8000316a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000316c:	6d3c                	ld	a5,88(a0)
    8000316e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003170:	60e2                	ld	ra,24(sp)
    80003172:	6442                	ld	s0,16(sp)
    80003174:	64a2                	ld	s1,8(sp)
    80003176:	6105                	addi	sp,sp,32
    80003178:	8082                	ret
    return p->trapframe->a1;
    8000317a:	6d3c                	ld	a5,88(a0)
    8000317c:	7fa8                	ld	a0,120(a5)
    8000317e:	bfcd                	j	80003170 <argraw+0x30>
    return p->trapframe->a2;
    80003180:	6d3c                	ld	a5,88(a0)
    80003182:	63c8                	ld	a0,128(a5)
    80003184:	b7f5                	j	80003170 <argraw+0x30>
    return p->trapframe->a3;
    80003186:	6d3c                	ld	a5,88(a0)
    80003188:	67c8                	ld	a0,136(a5)
    8000318a:	b7dd                	j	80003170 <argraw+0x30>
    return p->trapframe->a4;
    8000318c:	6d3c                	ld	a5,88(a0)
    8000318e:	6bc8                	ld	a0,144(a5)
    80003190:	b7c5                	j	80003170 <argraw+0x30>
    return p->trapframe->a5;
    80003192:	6d3c                	ld	a5,88(a0)
    80003194:	6fc8                	ld	a0,152(a5)
    80003196:	bfe9                	j	80003170 <argraw+0x30>
  panic("argraw");
    80003198:	00005517          	auipc	a0,0x5
    8000319c:	37050513          	addi	a0,a0,880 # 80008508 <states.0+0x170>
    800031a0:	ffffd097          	auipc	ra,0xffffd
    800031a4:	38a080e7          	jalr	906(ra) # 8000052a <panic>

00000000800031a8 <fetchaddr>:
{
    800031a8:	1101                	addi	sp,sp,-32
    800031aa:	ec06                	sd	ra,24(sp)
    800031ac:	e822                	sd	s0,16(sp)
    800031ae:	e426                	sd	s1,8(sp)
    800031b0:	e04a                	sd	s2,0(sp)
    800031b2:	1000                	addi	s0,sp,32
    800031b4:	84aa                	mv	s1,a0
    800031b6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800031b8:	fffff097          	auipc	ra,0xfffff
    800031bc:	e08080e7          	jalr	-504(ra) # 80001fc0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800031c0:	653c                	ld	a5,72(a0)
    800031c2:	02f4f863          	bgeu	s1,a5,800031f2 <fetchaddr+0x4a>
    800031c6:	00848713          	addi	a4,s1,8
    800031ca:	02e7e663          	bltu	a5,a4,800031f6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800031ce:	46a1                	li	a3,8
    800031d0:	8626                	mv	a2,s1
    800031d2:	85ca                	mv	a1,s2
    800031d4:	6928                	ld	a0,80(a0)
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	234080e7          	jalr	564(ra) # 8000140a <copyin>
    800031de:	00a03533          	snez	a0,a0
    800031e2:	40a00533          	neg	a0,a0
}
    800031e6:	60e2                	ld	ra,24(sp)
    800031e8:	6442                	ld	s0,16(sp)
    800031ea:	64a2                	ld	s1,8(sp)
    800031ec:	6902                	ld	s2,0(sp)
    800031ee:	6105                	addi	sp,sp,32
    800031f0:	8082                	ret
    return -1;
    800031f2:	557d                	li	a0,-1
    800031f4:	bfcd                	j	800031e6 <fetchaddr+0x3e>
    800031f6:	557d                	li	a0,-1
    800031f8:	b7fd                	j	800031e6 <fetchaddr+0x3e>

00000000800031fa <fetchstr>:
{
    800031fa:	7179                	addi	sp,sp,-48
    800031fc:	f406                	sd	ra,40(sp)
    800031fe:	f022                	sd	s0,32(sp)
    80003200:	ec26                	sd	s1,24(sp)
    80003202:	e84a                	sd	s2,16(sp)
    80003204:	e44e                	sd	s3,8(sp)
    80003206:	1800                	addi	s0,sp,48
    80003208:	892a                	mv	s2,a0
    8000320a:	84ae                	mv	s1,a1
    8000320c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000320e:	fffff097          	auipc	ra,0xfffff
    80003212:	db2080e7          	jalr	-590(ra) # 80001fc0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003216:	86ce                	mv	a3,s3
    80003218:	864a                	mv	a2,s2
    8000321a:	85a6                	mv	a1,s1
    8000321c:	6928                	ld	a0,80(a0)
    8000321e:	ffffe097          	auipc	ra,0xffffe
    80003222:	27a080e7          	jalr	634(ra) # 80001498 <copyinstr>
  if(err < 0)
    80003226:	00054763          	bltz	a0,80003234 <fetchstr+0x3a>
  return strlen(buf);
    8000322a:	8526                	mv	a0,s1
    8000322c:	ffffe097          	auipc	ra,0xffffe
    80003230:	c16080e7          	jalr	-1002(ra) # 80000e42 <strlen>
}
    80003234:	70a2                	ld	ra,40(sp)
    80003236:	7402                	ld	s0,32(sp)
    80003238:	64e2                	ld	s1,24(sp)
    8000323a:	6942                	ld	s2,16(sp)
    8000323c:	69a2                	ld	s3,8(sp)
    8000323e:	6145                	addi	sp,sp,48
    80003240:	8082                	ret

0000000080003242 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003242:	1101                	addi	sp,sp,-32
    80003244:	ec06                	sd	ra,24(sp)
    80003246:	e822                	sd	s0,16(sp)
    80003248:	e426                	sd	s1,8(sp)
    8000324a:	1000                	addi	s0,sp,32
    8000324c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000324e:	00000097          	auipc	ra,0x0
    80003252:	ef2080e7          	jalr	-270(ra) # 80003140 <argraw>
    80003256:	c088                	sw	a0,0(s1)
  return 0;
}
    80003258:	4501                	li	a0,0
    8000325a:	60e2                	ld	ra,24(sp)
    8000325c:	6442                	ld	s0,16(sp)
    8000325e:	64a2                	ld	s1,8(sp)
    80003260:	6105                	addi	sp,sp,32
    80003262:	8082                	ret

0000000080003264 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003264:	1101                	addi	sp,sp,-32
    80003266:	ec06                	sd	ra,24(sp)
    80003268:	e822                	sd	s0,16(sp)
    8000326a:	e426                	sd	s1,8(sp)
    8000326c:	1000                	addi	s0,sp,32
    8000326e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003270:	00000097          	auipc	ra,0x0
    80003274:	ed0080e7          	jalr	-304(ra) # 80003140 <argraw>
    80003278:	e088                	sd	a0,0(s1)
  return 0;
}
    8000327a:	4501                	li	a0,0
    8000327c:	60e2                	ld	ra,24(sp)
    8000327e:	6442                	ld	s0,16(sp)
    80003280:	64a2                	ld	s1,8(sp)
    80003282:	6105                	addi	sp,sp,32
    80003284:	8082                	ret

0000000080003286 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003286:	1101                	addi	sp,sp,-32
    80003288:	ec06                	sd	ra,24(sp)
    8000328a:	e822                	sd	s0,16(sp)
    8000328c:	e426                	sd	s1,8(sp)
    8000328e:	e04a                	sd	s2,0(sp)
    80003290:	1000                	addi	s0,sp,32
    80003292:	84ae                	mv	s1,a1
    80003294:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003296:	00000097          	auipc	ra,0x0
    8000329a:	eaa080e7          	jalr	-342(ra) # 80003140 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000329e:	864a                	mv	a2,s2
    800032a0:	85a6                	mv	a1,s1
    800032a2:	00000097          	auipc	ra,0x0
    800032a6:	f58080e7          	jalr	-168(ra) # 800031fa <fetchstr>
}
    800032aa:	60e2                	ld	ra,24(sp)
    800032ac:	6442                	ld	s0,16(sp)
    800032ae:	64a2                	ld	s1,8(sp)
    800032b0:	6902                	ld	s2,0(sp)
    800032b2:	6105                	addi	sp,sp,32
    800032b4:	8082                	ret

00000000800032b6 <syscall>:
[SYS_ppages]  sys_ppages,
};

void
syscall(void)
{
    800032b6:	1101                	addi	sp,sp,-32
    800032b8:	ec06                	sd	ra,24(sp)
    800032ba:	e822                	sd	s0,16(sp)
    800032bc:	e426                	sd	s1,8(sp)
    800032be:	e04a                	sd	s2,0(sp)
    800032c0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800032c2:	fffff097          	auipc	ra,0xfffff
    800032c6:	cfe080e7          	jalr	-770(ra) # 80001fc0 <myproc>
    800032ca:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800032cc:	05853903          	ld	s2,88(a0)
    800032d0:	0a893783          	ld	a5,168(s2)
    800032d4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800032d8:	37fd                	addiw	a5,a5,-1
    800032da:	4755                	li	a4,21
    800032dc:	00f76f63          	bltu	a4,a5,800032fa <syscall+0x44>
    800032e0:	00369713          	slli	a4,a3,0x3
    800032e4:	00005797          	auipc	a5,0x5
    800032e8:	26478793          	addi	a5,a5,612 # 80008548 <syscalls>
    800032ec:	97ba                	add	a5,a5,a4
    800032ee:	639c                	ld	a5,0(a5)
    800032f0:	c789                	beqz	a5,800032fa <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800032f2:	9782                	jalr	a5
    800032f4:	06a93823          	sd	a0,112(s2)
    800032f8:	a839                	j	80003316 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800032fa:	15848613          	addi	a2,s1,344
    800032fe:	588c                	lw	a1,48(s1)
    80003300:	00005517          	auipc	a0,0x5
    80003304:	21050513          	addi	a0,a0,528 # 80008510 <states.0+0x178>
    80003308:	ffffd097          	auipc	ra,0xffffd
    8000330c:	26c080e7          	jalr	620(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003310:	6cbc                	ld	a5,88(s1)
    80003312:	577d                	li	a4,-1
    80003314:	fbb8                	sd	a4,112(a5)
  }
}
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6902                	ld	s2,0(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003322:	1101                	addi	sp,sp,-32
    80003324:	ec06                	sd	ra,24(sp)
    80003326:	e822                	sd	s0,16(sp)
    80003328:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8000332a:	fec40593          	addi	a1,s0,-20
    8000332e:	4501                	li	a0,0
    80003330:	00000097          	auipc	ra,0x0
    80003334:	f12080e7          	jalr	-238(ra) # 80003242 <argint>
    return -1;
    80003338:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000333a:	00054963          	bltz	a0,8000334c <sys_exit+0x2a>
  exit(n);
    8000333e:	fec42503          	lw	a0,-20(s0)
    80003342:	fffff097          	auipc	ra,0xfffff
    80003346:	690080e7          	jalr	1680(ra) # 800029d2 <exit>
  return 0;  // not reached
    8000334a:	4781                	li	a5,0
}
    8000334c:	853e                	mv	a0,a5
    8000334e:	60e2                	ld	ra,24(sp)
    80003350:	6442                	ld	s0,16(sp)
    80003352:	6105                	addi	sp,sp,32
    80003354:	8082                	ret

0000000080003356 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003356:	1141                	addi	sp,sp,-16
    80003358:	e406                	sd	ra,8(sp)
    8000335a:	e022                	sd	s0,0(sp)
    8000335c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000335e:	fffff097          	auipc	ra,0xfffff
    80003362:	c62080e7          	jalr	-926(ra) # 80001fc0 <myproc>
}
    80003366:	5908                	lw	a0,48(a0)
    80003368:	60a2                	ld	ra,8(sp)
    8000336a:	6402                	ld	s0,0(sp)
    8000336c:	0141                	addi	sp,sp,16
    8000336e:	8082                	ret

0000000080003370 <sys_fork>:

uint64
sys_fork(void)
{
    80003370:	1141                	addi	sp,sp,-16
    80003372:	e406                	sd	ra,8(sp)
    80003374:	e022                	sd	s0,0(sp)
    80003376:	0800                	addi	s0,sp,16
  return fork();
    80003378:	fffff097          	auipc	ra,0xfffff
    8000337c:	06e080e7          	jalr	110(ra) # 800023e6 <fork>
}
    80003380:	60a2                	ld	ra,8(sp)
    80003382:	6402                	ld	s0,0(sp)
    80003384:	0141                	addi	sp,sp,16
    80003386:	8082                	ret

0000000080003388 <sys_wait>:

uint64
sys_wait(void)
{
    80003388:	1101                	addi	sp,sp,-32
    8000338a:	ec06                	sd	ra,24(sp)
    8000338c:	e822                	sd	s0,16(sp)
    8000338e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003390:	fe840593          	addi	a1,s0,-24
    80003394:	4501                	li	a0,0
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	ece080e7          	jalr	-306(ra) # 80003264 <argaddr>
    8000339e:	87aa                	mv	a5,a0
    return -1;
    800033a0:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800033a2:	0007c863          	bltz	a5,800033b2 <sys_wait+0x2a>
  return wait(p);
    800033a6:	fe843503          	ld	a0,-24(s0)
    800033aa:	fffff097          	auipc	ra,0xfffff
    800033ae:	430080e7          	jalr	1072(ra) # 800027da <wait>
}
    800033b2:	60e2                	ld	ra,24(sp)
    800033b4:	6442                	ld	s0,16(sp)
    800033b6:	6105                	addi	sp,sp,32
    800033b8:	8082                	ret

00000000800033ba <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800033ba:	7179                	addi	sp,sp,-48
    800033bc:	f406                	sd	ra,40(sp)
    800033be:	f022                	sd	s0,32(sp)
    800033c0:	ec26                	sd	s1,24(sp)
    800033c2:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800033c4:	fdc40593          	addi	a1,s0,-36
    800033c8:	4501                	li	a0,0
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	e78080e7          	jalr	-392(ra) # 80003242 <argint>
    return -1;
    800033d2:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800033d4:	00054f63          	bltz	a0,800033f2 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800033d8:	fffff097          	auipc	ra,0xfffff
    800033dc:	be8080e7          	jalr	-1048(ra) # 80001fc0 <myproc>
    800033e0:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800033e2:	fdc42503          	lw	a0,-36(s0)
    800033e6:	fffff097          	auipc	ra,0xfffff
    800033ea:	f8c080e7          	jalr	-116(ra) # 80002372 <growproc>
    800033ee:	00054863          	bltz	a0,800033fe <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800033f2:	8526                	mv	a0,s1
    800033f4:	70a2                	ld	ra,40(sp)
    800033f6:	7402                	ld	s0,32(sp)
    800033f8:	64e2                	ld	s1,24(sp)
    800033fa:	6145                	addi	sp,sp,48
    800033fc:	8082                	ret
    return -1;
    800033fe:	54fd                	li	s1,-1
    80003400:	bfcd                	j	800033f2 <sys_sbrk+0x38>

0000000080003402 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003402:	7139                	addi	sp,sp,-64
    80003404:	fc06                	sd	ra,56(sp)
    80003406:	f822                	sd	s0,48(sp)
    80003408:	f426                	sd	s1,40(sp)
    8000340a:	f04a                	sd	s2,32(sp)
    8000340c:	ec4e                	sd	s3,24(sp)
    8000340e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003410:	fcc40593          	addi	a1,s0,-52
    80003414:	4501                	li	a0,0
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	e2c080e7          	jalr	-468(ra) # 80003242 <argint>
    return -1;
    8000341e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003420:	06054563          	bltz	a0,8000348a <sys_sleep+0x88>
  acquire(&tickslock);
    80003424:	00024517          	auipc	a0,0x24
    80003428:	eac50513          	addi	a0,a0,-340 # 800272d0 <tickslock>
    8000342c:	ffffd097          	auipc	ra,0xffffd
    80003430:	796080e7          	jalr	1942(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003434:	00006917          	auipc	s2,0x6
    80003438:	c0492903          	lw	s2,-1020(s2) # 80009038 <ticks>
  while(ticks - ticks0 < n){
    8000343c:	fcc42783          	lw	a5,-52(s0)
    80003440:	cf85                	beqz	a5,80003478 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003442:	00024997          	auipc	s3,0x24
    80003446:	e8e98993          	addi	s3,s3,-370 # 800272d0 <tickslock>
    8000344a:	00006497          	auipc	s1,0x6
    8000344e:	bee48493          	addi	s1,s1,-1042 # 80009038 <ticks>
    if(myproc()->killed){
    80003452:	fffff097          	auipc	ra,0xfffff
    80003456:	b6e080e7          	jalr	-1170(ra) # 80001fc0 <myproc>
    8000345a:	551c                	lw	a5,40(a0)
    8000345c:	ef9d                	bnez	a5,8000349a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000345e:	85ce                	mv	a1,s3
    80003460:	8526                	mv	a0,s1
    80003462:	fffff097          	auipc	ra,0xfffff
    80003466:	314080e7          	jalr	788(ra) # 80002776 <sleep>
  while(ticks - ticks0 < n){
    8000346a:	409c                	lw	a5,0(s1)
    8000346c:	412787bb          	subw	a5,a5,s2
    80003470:	fcc42703          	lw	a4,-52(s0)
    80003474:	fce7efe3          	bltu	a5,a4,80003452 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003478:	00024517          	auipc	a0,0x24
    8000347c:	e5850513          	addi	a0,a0,-424 # 800272d0 <tickslock>
    80003480:	ffffd097          	auipc	ra,0xffffd
    80003484:	7f6080e7          	jalr	2038(ra) # 80000c76 <release>
  return 0;
    80003488:	4781                	li	a5,0
}
    8000348a:	853e                	mv	a0,a5
    8000348c:	70e2                	ld	ra,56(sp)
    8000348e:	7442                	ld	s0,48(sp)
    80003490:	74a2                	ld	s1,40(sp)
    80003492:	7902                	ld	s2,32(sp)
    80003494:	69e2                	ld	s3,24(sp)
    80003496:	6121                	addi	sp,sp,64
    80003498:	8082                	ret
      release(&tickslock);
    8000349a:	00024517          	auipc	a0,0x24
    8000349e:	e3650513          	addi	a0,a0,-458 # 800272d0 <tickslock>
    800034a2:	ffffd097          	auipc	ra,0xffffd
    800034a6:	7d4080e7          	jalr	2004(ra) # 80000c76 <release>
      return -1;
    800034aa:	57fd                	li	a5,-1
    800034ac:	bff9                	j	8000348a <sys_sleep+0x88>

00000000800034ae <sys_kill>:

uint64
sys_kill(void)
{
    800034ae:	1101                	addi	sp,sp,-32
    800034b0:	ec06                	sd	ra,24(sp)
    800034b2:	e822                	sd	s0,16(sp)
    800034b4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800034b6:	fec40593          	addi	a1,s0,-20
    800034ba:	4501                	li	a0,0
    800034bc:	00000097          	auipc	ra,0x0
    800034c0:	d86080e7          	jalr	-634(ra) # 80003242 <argint>
    800034c4:	87aa                	mv	a5,a0
    return -1;
    800034c6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800034c8:	0007c863          	bltz	a5,800034d8 <sys_kill+0x2a>
  return kill(pid);
    800034cc:	fec42503          	lw	a0,-20(s0)
    800034d0:	fffff097          	auipc	ra,0xfffff
    800034d4:	5f8080e7          	jalr	1528(ra) # 80002ac8 <kill>
}
    800034d8:	60e2                	ld	ra,24(sp)
    800034da:	6442                	ld	s0,16(sp)
    800034dc:	6105                	addi	sp,sp,32
    800034de:	8082                	ret

00000000800034e0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034e0:	1101                	addi	sp,sp,-32
    800034e2:	ec06                	sd	ra,24(sp)
    800034e4:	e822                	sd	s0,16(sp)
    800034e6:	e426                	sd	s1,8(sp)
    800034e8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034ea:	00024517          	auipc	a0,0x24
    800034ee:	de650513          	addi	a0,a0,-538 # 800272d0 <tickslock>
    800034f2:	ffffd097          	auipc	ra,0xffffd
    800034f6:	6d0080e7          	jalr	1744(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800034fa:	00006497          	auipc	s1,0x6
    800034fe:	b3e4a483          	lw	s1,-1218(s1) # 80009038 <ticks>
  release(&tickslock);
    80003502:	00024517          	auipc	a0,0x24
    80003506:	dce50513          	addi	a0,a0,-562 # 800272d0 <tickslock>
    8000350a:	ffffd097          	auipc	ra,0xffffd
    8000350e:	76c080e7          	jalr	1900(ra) # 80000c76 <release>
  return xticks;
}
    80003512:	02049513          	slli	a0,s1,0x20
    80003516:	9101                	srli	a0,a0,0x20
    80003518:	60e2                	ld	ra,24(sp)
    8000351a:	6442                	ld	s0,16(sp)
    8000351c:	64a2                	ld	s1,8(sp)
    8000351e:	6105                	addi	sp,sp,32
    80003520:	8082                	ret

0000000080003522 <sys_ppages>:

uint64
sys_ppages(void)
{
    80003522:	1141                	addi	sp,sp,-16
    80003524:	e406                	sd	ra,8(sp)
    80003526:	e022                	sd	s0,0(sp)
    80003528:	0800                	addi	s0,sp,16
  ppages();
    8000352a:	ffffe097          	auipc	ra,0xffffe
    8000352e:	4be080e7          	jalr	1214(ra) # 800019e8 <ppages>
  return 0;
}
    80003532:	4501                	li	a0,0
    80003534:	60a2                	ld	ra,8(sp)
    80003536:	6402                	ld	s0,0(sp)
    80003538:	0141                	addi	sp,sp,16
    8000353a:	8082                	ret

000000008000353c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000353c:	7179                	addi	sp,sp,-48
    8000353e:	f406                	sd	ra,40(sp)
    80003540:	f022                	sd	s0,32(sp)
    80003542:	ec26                	sd	s1,24(sp)
    80003544:	e84a                	sd	s2,16(sp)
    80003546:	e44e                	sd	s3,8(sp)
    80003548:	e052                	sd	s4,0(sp)
    8000354a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000354c:	00005597          	auipc	a1,0x5
    80003550:	0b458593          	addi	a1,a1,180 # 80008600 <syscalls+0xb8>
    80003554:	00024517          	auipc	a0,0x24
    80003558:	d9450513          	addi	a0,a0,-620 # 800272e8 <bcache>
    8000355c:	ffffd097          	auipc	ra,0xffffd
    80003560:	5d6080e7          	jalr	1494(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003564:	0002c797          	auipc	a5,0x2c
    80003568:	d8478793          	addi	a5,a5,-636 # 8002f2e8 <bcache+0x8000>
    8000356c:	0002c717          	auipc	a4,0x2c
    80003570:	fe470713          	addi	a4,a4,-28 # 8002f550 <bcache+0x8268>
    80003574:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003578:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000357c:	00024497          	auipc	s1,0x24
    80003580:	d8448493          	addi	s1,s1,-636 # 80027300 <bcache+0x18>
    b->next = bcache.head.next;
    80003584:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003586:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003588:	00005a17          	auipc	s4,0x5
    8000358c:	080a0a13          	addi	s4,s4,128 # 80008608 <syscalls+0xc0>
    b->next = bcache.head.next;
    80003590:	2b893783          	ld	a5,696(s2)
    80003594:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003596:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000359a:	85d2                	mv	a1,s4
    8000359c:	01048513          	addi	a0,s1,16
    800035a0:	00002097          	auipc	ra,0x2
    800035a4:	80a080e7          	jalr	-2038(ra) # 80004daa <initsleeplock>
    bcache.head.next->prev = b;
    800035a8:	2b893783          	ld	a5,696(s2)
    800035ac:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800035ae:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035b2:	45848493          	addi	s1,s1,1112
    800035b6:	fd349de3          	bne	s1,s3,80003590 <binit+0x54>
  }
}
    800035ba:	70a2                	ld	ra,40(sp)
    800035bc:	7402                	ld	s0,32(sp)
    800035be:	64e2                	ld	s1,24(sp)
    800035c0:	6942                	ld	s2,16(sp)
    800035c2:	69a2                	ld	s3,8(sp)
    800035c4:	6a02                	ld	s4,0(sp)
    800035c6:	6145                	addi	sp,sp,48
    800035c8:	8082                	ret

00000000800035ca <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800035ca:	7179                	addi	sp,sp,-48
    800035cc:	f406                	sd	ra,40(sp)
    800035ce:	f022                	sd	s0,32(sp)
    800035d0:	ec26                	sd	s1,24(sp)
    800035d2:	e84a                	sd	s2,16(sp)
    800035d4:	e44e                	sd	s3,8(sp)
    800035d6:	1800                	addi	s0,sp,48
    800035d8:	892a                	mv	s2,a0
    800035da:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800035dc:	00024517          	auipc	a0,0x24
    800035e0:	d0c50513          	addi	a0,a0,-756 # 800272e8 <bcache>
    800035e4:	ffffd097          	auipc	ra,0xffffd
    800035e8:	5de080e7          	jalr	1502(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035ec:	0002c497          	auipc	s1,0x2c
    800035f0:	fb44b483          	ld	s1,-76(s1) # 8002f5a0 <bcache+0x82b8>
    800035f4:	0002c797          	auipc	a5,0x2c
    800035f8:	f5c78793          	addi	a5,a5,-164 # 8002f550 <bcache+0x8268>
    800035fc:	02f48f63          	beq	s1,a5,8000363a <bread+0x70>
    80003600:	873e                	mv	a4,a5
    80003602:	a021                	j	8000360a <bread+0x40>
    80003604:	68a4                	ld	s1,80(s1)
    80003606:	02e48a63          	beq	s1,a4,8000363a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000360a:	449c                	lw	a5,8(s1)
    8000360c:	ff279ce3          	bne	a5,s2,80003604 <bread+0x3a>
    80003610:	44dc                	lw	a5,12(s1)
    80003612:	ff3799e3          	bne	a5,s3,80003604 <bread+0x3a>
      b->refcnt++;
    80003616:	40bc                	lw	a5,64(s1)
    80003618:	2785                	addiw	a5,a5,1
    8000361a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000361c:	00024517          	auipc	a0,0x24
    80003620:	ccc50513          	addi	a0,a0,-820 # 800272e8 <bcache>
    80003624:	ffffd097          	auipc	ra,0xffffd
    80003628:	652080e7          	jalr	1618(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    8000362c:	01048513          	addi	a0,s1,16
    80003630:	00001097          	auipc	ra,0x1
    80003634:	7b4080e7          	jalr	1972(ra) # 80004de4 <acquiresleep>
      return b;
    80003638:	a8b9                	j	80003696 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000363a:	0002c497          	auipc	s1,0x2c
    8000363e:	f5e4b483          	ld	s1,-162(s1) # 8002f598 <bcache+0x82b0>
    80003642:	0002c797          	auipc	a5,0x2c
    80003646:	f0e78793          	addi	a5,a5,-242 # 8002f550 <bcache+0x8268>
    8000364a:	00f48863          	beq	s1,a5,8000365a <bread+0x90>
    8000364e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003650:	40bc                	lw	a5,64(s1)
    80003652:	cf81                	beqz	a5,8000366a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003654:	64a4                	ld	s1,72(s1)
    80003656:	fee49de3          	bne	s1,a4,80003650 <bread+0x86>
  panic("bget: no buffers");
    8000365a:	00005517          	auipc	a0,0x5
    8000365e:	fb650513          	addi	a0,a0,-74 # 80008610 <syscalls+0xc8>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	ec8080e7          	jalr	-312(ra) # 8000052a <panic>
      b->dev = dev;
    8000366a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000366e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003672:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003676:	4785                	li	a5,1
    80003678:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000367a:	00024517          	auipc	a0,0x24
    8000367e:	c6e50513          	addi	a0,a0,-914 # 800272e8 <bcache>
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	5f4080e7          	jalr	1524(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    8000368a:	01048513          	addi	a0,s1,16
    8000368e:	00001097          	auipc	ra,0x1
    80003692:	756080e7          	jalr	1878(ra) # 80004de4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003696:	409c                	lw	a5,0(s1)
    80003698:	cb89                	beqz	a5,800036aa <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000369a:	8526                	mv	a0,s1
    8000369c:	70a2                	ld	ra,40(sp)
    8000369e:	7402                	ld	s0,32(sp)
    800036a0:	64e2                	ld	s1,24(sp)
    800036a2:	6942                	ld	s2,16(sp)
    800036a4:	69a2                	ld	s3,8(sp)
    800036a6:	6145                	addi	sp,sp,48
    800036a8:	8082                	ret
    virtio_disk_rw(b, 0);
    800036aa:	4581                	li	a1,0
    800036ac:	8526                	mv	a0,s1
    800036ae:	00003097          	auipc	ra,0x3
    800036b2:	498080e7          	jalr	1176(ra) # 80006b46 <virtio_disk_rw>
    b->valid = 1;
    800036b6:	4785                	li	a5,1
    800036b8:	c09c                	sw	a5,0(s1)
  return b;
    800036ba:	b7c5                	j	8000369a <bread+0xd0>

00000000800036bc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036bc:	1101                	addi	sp,sp,-32
    800036be:	ec06                	sd	ra,24(sp)
    800036c0:	e822                	sd	s0,16(sp)
    800036c2:	e426                	sd	s1,8(sp)
    800036c4:	1000                	addi	s0,sp,32
    800036c6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036c8:	0541                	addi	a0,a0,16
    800036ca:	00001097          	auipc	ra,0x1
    800036ce:	7b4080e7          	jalr	1972(ra) # 80004e7e <holdingsleep>
    800036d2:	cd01                	beqz	a0,800036ea <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036d4:	4585                	li	a1,1
    800036d6:	8526                	mv	a0,s1
    800036d8:	00003097          	auipc	ra,0x3
    800036dc:	46e080e7          	jalr	1134(ra) # 80006b46 <virtio_disk_rw>
}
    800036e0:	60e2                	ld	ra,24(sp)
    800036e2:	6442                	ld	s0,16(sp)
    800036e4:	64a2                	ld	s1,8(sp)
    800036e6:	6105                	addi	sp,sp,32
    800036e8:	8082                	ret
    panic("bwrite");
    800036ea:	00005517          	auipc	a0,0x5
    800036ee:	f3e50513          	addi	a0,a0,-194 # 80008628 <syscalls+0xe0>
    800036f2:	ffffd097          	auipc	ra,0xffffd
    800036f6:	e38080e7          	jalr	-456(ra) # 8000052a <panic>

00000000800036fa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036fa:	1101                	addi	sp,sp,-32
    800036fc:	ec06                	sd	ra,24(sp)
    800036fe:	e822                	sd	s0,16(sp)
    80003700:	e426                	sd	s1,8(sp)
    80003702:	e04a                	sd	s2,0(sp)
    80003704:	1000                	addi	s0,sp,32
    80003706:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003708:	01050913          	addi	s2,a0,16
    8000370c:	854a                	mv	a0,s2
    8000370e:	00001097          	auipc	ra,0x1
    80003712:	770080e7          	jalr	1904(ra) # 80004e7e <holdingsleep>
    80003716:	c92d                	beqz	a0,80003788 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003718:	854a                	mv	a0,s2
    8000371a:	00001097          	auipc	ra,0x1
    8000371e:	720080e7          	jalr	1824(ra) # 80004e3a <releasesleep>

  acquire(&bcache.lock);
    80003722:	00024517          	auipc	a0,0x24
    80003726:	bc650513          	addi	a0,a0,-1082 # 800272e8 <bcache>
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	498080e7          	jalr	1176(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003732:	40bc                	lw	a5,64(s1)
    80003734:	37fd                	addiw	a5,a5,-1
    80003736:	0007871b          	sext.w	a4,a5
    8000373a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000373c:	eb05                	bnez	a4,8000376c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000373e:	68bc                	ld	a5,80(s1)
    80003740:	64b8                	ld	a4,72(s1)
    80003742:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003744:	64bc                	ld	a5,72(s1)
    80003746:	68b8                	ld	a4,80(s1)
    80003748:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000374a:	0002c797          	auipc	a5,0x2c
    8000374e:	b9e78793          	addi	a5,a5,-1122 # 8002f2e8 <bcache+0x8000>
    80003752:	2b87b703          	ld	a4,696(a5)
    80003756:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003758:	0002c717          	auipc	a4,0x2c
    8000375c:	df870713          	addi	a4,a4,-520 # 8002f550 <bcache+0x8268>
    80003760:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003762:	2b87b703          	ld	a4,696(a5)
    80003766:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003768:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000376c:	00024517          	auipc	a0,0x24
    80003770:	b7c50513          	addi	a0,a0,-1156 # 800272e8 <bcache>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	502080e7          	jalr	1282(ra) # 80000c76 <release>
}
    8000377c:	60e2                	ld	ra,24(sp)
    8000377e:	6442                	ld	s0,16(sp)
    80003780:	64a2                	ld	s1,8(sp)
    80003782:	6902                	ld	s2,0(sp)
    80003784:	6105                	addi	sp,sp,32
    80003786:	8082                	ret
    panic("brelse");
    80003788:	00005517          	auipc	a0,0x5
    8000378c:	ea850513          	addi	a0,a0,-344 # 80008630 <syscalls+0xe8>
    80003790:	ffffd097          	auipc	ra,0xffffd
    80003794:	d9a080e7          	jalr	-614(ra) # 8000052a <panic>

0000000080003798 <bpin>:

void
bpin(struct buf *b) {
    80003798:	1101                	addi	sp,sp,-32
    8000379a:	ec06                	sd	ra,24(sp)
    8000379c:	e822                	sd	s0,16(sp)
    8000379e:	e426                	sd	s1,8(sp)
    800037a0:	1000                	addi	s0,sp,32
    800037a2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037a4:	00024517          	auipc	a0,0x24
    800037a8:	b4450513          	addi	a0,a0,-1212 # 800272e8 <bcache>
    800037ac:	ffffd097          	auipc	ra,0xffffd
    800037b0:	416080e7          	jalr	1046(ra) # 80000bc2 <acquire>
  b->refcnt++;
    800037b4:	40bc                	lw	a5,64(s1)
    800037b6:	2785                	addiw	a5,a5,1
    800037b8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037ba:	00024517          	auipc	a0,0x24
    800037be:	b2e50513          	addi	a0,a0,-1234 # 800272e8 <bcache>
    800037c2:	ffffd097          	auipc	ra,0xffffd
    800037c6:	4b4080e7          	jalr	1204(ra) # 80000c76 <release>
}
    800037ca:	60e2                	ld	ra,24(sp)
    800037cc:	6442                	ld	s0,16(sp)
    800037ce:	64a2                	ld	s1,8(sp)
    800037d0:	6105                	addi	sp,sp,32
    800037d2:	8082                	ret

00000000800037d4 <bunpin>:

void
bunpin(struct buf *b) {
    800037d4:	1101                	addi	sp,sp,-32
    800037d6:	ec06                	sd	ra,24(sp)
    800037d8:	e822                	sd	s0,16(sp)
    800037da:	e426                	sd	s1,8(sp)
    800037dc:	1000                	addi	s0,sp,32
    800037de:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037e0:	00024517          	auipc	a0,0x24
    800037e4:	b0850513          	addi	a0,a0,-1272 # 800272e8 <bcache>
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	3da080e7          	jalr	986(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800037f0:	40bc                	lw	a5,64(s1)
    800037f2:	37fd                	addiw	a5,a5,-1
    800037f4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037f6:	00024517          	auipc	a0,0x24
    800037fa:	af250513          	addi	a0,a0,-1294 # 800272e8 <bcache>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	478080e7          	jalr	1144(ra) # 80000c76 <release>
}
    80003806:	60e2                	ld	ra,24(sp)
    80003808:	6442                	ld	s0,16(sp)
    8000380a:	64a2                	ld	s1,8(sp)
    8000380c:	6105                	addi	sp,sp,32
    8000380e:	8082                	ret

0000000080003810 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003810:	1101                	addi	sp,sp,-32
    80003812:	ec06                	sd	ra,24(sp)
    80003814:	e822                	sd	s0,16(sp)
    80003816:	e426                	sd	s1,8(sp)
    80003818:	e04a                	sd	s2,0(sp)
    8000381a:	1000                	addi	s0,sp,32
    8000381c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000381e:	00d5d59b          	srliw	a1,a1,0xd
    80003822:	0002c797          	auipc	a5,0x2c
    80003826:	1a27a783          	lw	a5,418(a5) # 8002f9c4 <sb+0x1c>
    8000382a:	9dbd                	addw	a1,a1,a5
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	d9e080e7          	jalr	-610(ra) # 800035ca <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003834:	0074f713          	andi	a4,s1,7
    80003838:	4785                	li	a5,1
    8000383a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000383e:	14ce                	slli	s1,s1,0x33
    80003840:	90d9                	srli	s1,s1,0x36
    80003842:	00950733          	add	a4,a0,s1
    80003846:	05874703          	lbu	a4,88(a4)
    8000384a:	00e7f6b3          	and	a3,a5,a4
    8000384e:	c69d                	beqz	a3,8000387c <bfree+0x6c>
    80003850:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003852:	94aa                	add	s1,s1,a0
    80003854:	fff7c793          	not	a5,a5
    80003858:	8ff9                	and	a5,a5,a4
    8000385a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000385e:	00001097          	auipc	ra,0x1
    80003862:	466080e7          	jalr	1126(ra) # 80004cc4 <log_write>
  brelse(bp);
    80003866:	854a                	mv	a0,s2
    80003868:	00000097          	auipc	ra,0x0
    8000386c:	e92080e7          	jalr	-366(ra) # 800036fa <brelse>
}
    80003870:	60e2                	ld	ra,24(sp)
    80003872:	6442                	ld	s0,16(sp)
    80003874:	64a2                	ld	s1,8(sp)
    80003876:	6902                	ld	s2,0(sp)
    80003878:	6105                	addi	sp,sp,32
    8000387a:	8082                	ret
    panic("freeing free block");
    8000387c:	00005517          	auipc	a0,0x5
    80003880:	dbc50513          	addi	a0,a0,-580 # 80008638 <syscalls+0xf0>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	ca6080e7          	jalr	-858(ra) # 8000052a <panic>

000000008000388c <balloc>:
{
    8000388c:	711d                	addi	sp,sp,-96
    8000388e:	ec86                	sd	ra,88(sp)
    80003890:	e8a2                	sd	s0,80(sp)
    80003892:	e4a6                	sd	s1,72(sp)
    80003894:	e0ca                	sd	s2,64(sp)
    80003896:	fc4e                	sd	s3,56(sp)
    80003898:	f852                	sd	s4,48(sp)
    8000389a:	f456                	sd	s5,40(sp)
    8000389c:	f05a                	sd	s6,32(sp)
    8000389e:	ec5e                	sd	s7,24(sp)
    800038a0:	e862                	sd	s8,16(sp)
    800038a2:	e466                	sd	s9,8(sp)
    800038a4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800038a6:	0002c797          	auipc	a5,0x2c
    800038aa:	1067a783          	lw	a5,262(a5) # 8002f9ac <sb+0x4>
    800038ae:	cbd1                	beqz	a5,80003942 <balloc+0xb6>
    800038b0:	8baa                	mv	s7,a0
    800038b2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800038b4:	0002cb17          	auipc	s6,0x2c
    800038b8:	0f4b0b13          	addi	s6,s6,244 # 8002f9a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038bc:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800038be:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038c0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038c2:	6c89                	lui	s9,0x2
    800038c4:	a831                	j	800038e0 <balloc+0x54>
    brelse(bp);
    800038c6:	854a                	mv	a0,s2
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	e32080e7          	jalr	-462(ra) # 800036fa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800038d0:	015c87bb          	addw	a5,s9,s5
    800038d4:	00078a9b          	sext.w	s5,a5
    800038d8:	004b2703          	lw	a4,4(s6)
    800038dc:	06eaf363          	bgeu	s5,a4,80003942 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800038e0:	41fad79b          	sraiw	a5,s5,0x1f
    800038e4:	0137d79b          	srliw	a5,a5,0x13
    800038e8:	015787bb          	addw	a5,a5,s5
    800038ec:	40d7d79b          	sraiw	a5,a5,0xd
    800038f0:	01cb2583          	lw	a1,28(s6)
    800038f4:	9dbd                	addw	a1,a1,a5
    800038f6:	855e                	mv	a0,s7
    800038f8:	00000097          	auipc	ra,0x0
    800038fc:	cd2080e7          	jalr	-814(ra) # 800035ca <bread>
    80003900:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003902:	004b2503          	lw	a0,4(s6)
    80003906:	000a849b          	sext.w	s1,s5
    8000390a:	8662                	mv	a2,s8
    8000390c:	faa4fde3          	bgeu	s1,a0,800038c6 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003910:	41f6579b          	sraiw	a5,a2,0x1f
    80003914:	01d7d69b          	srliw	a3,a5,0x1d
    80003918:	00c6873b          	addw	a4,a3,a2
    8000391c:	00777793          	andi	a5,a4,7
    80003920:	9f95                	subw	a5,a5,a3
    80003922:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003926:	4037571b          	sraiw	a4,a4,0x3
    8000392a:	00e906b3          	add	a3,s2,a4
    8000392e:	0586c683          	lbu	a3,88(a3)
    80003932:	00d7f5b3          	and	a1,a5,a3
    80003936:	cd91                	beqz	a1,80003952 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003938:	2605                	addiw	a2,a2,1
    8000393a:	2485                	addiw	s1,s1,1
    8000393c:	fd4618e3          	bne	a2,s4,8000390c <balloc+0x80>
    80003940:	b759                	j	800038c6 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003942:	00005517          	auipc	a0,0x5
    80003946:	d0e50513          	addi	a0,a0,-754 # 80008650 <syscalls+0x108>
    8000394a:	ffffd097          	auipc	ra,0xffffd
    8000394e:	be0080e7          	jalr	-1056(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003952:	974a                	add	a4,a4,s2
    80003954:	8fd5                	or	a5,a5,a3
    80003956:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000395a:	854a                	mv	a0,s2
    8000395c:	00001097          	auipc	ra,0x1
    80003960:	368080e7          	jalr	872(ra) # 80004cc4 <log_write>
        brelse(bp);
    80003964:	854a                	mv	a0,s2
    80003966:	00000097          	auipc	ra,0x0
    8000396a:	d94080e7          	jalr	-620(ra) # 800036fa <brelse>
  bp = bread(dev, bno);
    8000396e:	85a6                	mv	a1,s1
    80003970:	855e                	mv	a0,s7
    80003972:	00000097          	auipc	ra,0x0
    80003976:	c58080e7          	jalr	-936(ra) # 800035ca <bread>
    8000397a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000397c:	40000613          	li	a2,1024
    80003980:	4581                	li	a1,0
    80003982:	05850513          	addi	a0,a0,88
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	338080e7          	jalr	824(ra) # 80000cbe <memset>
  log_write(bp);
    8000398e:	854a                	mv	a0,s2
    80003990:	00001097          	auipc	ra,0x1
    80003994:	334080e7          	jalr	820(ra) # 80004cc4 <log_write>
  brelse(bp);
    80003998:	854a                	mv	a0,s2
    8000399a:	00000097          	auipc	ra,0x0
    8000399e:	d60080e7          	jalr	-672(ra) # 800036fa <brelse>
}
    800039a2:	8526                	mv	a0,s1
    800039a4:	60e6                	ld	ra,88(sp)
    800039a6:	6446                	ld	s0,80(sp)
    800039a8:	64a6                	ld	s1,72(sp)
    800039aa:	6906                	ld	s2,64(sp)
    800039ac:	79e2                	ld	s3,56(sp)
    800039ae:	7a42                	ld	s4,48(sp)
    800039b0:	7aa2                	ld	s5,40(sp)
    800039b2:	7b02                	ld	s6,32(sp)
    800039b4:	6be2                	ld	s7,24(sp)
    800039b6:	6c42                	ld	s8,16(sp)
    800039b8:	6ca2                	ld	s9,8(sp)
    800039ba:	6125                	addi	sp,sp,96
    800039bc:	8082                	ret

00000000800039be <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800039be:	7179                	addi	sp,sp,-48
    800039c0:	f406                	sd	ra,40(sp)
    800039c2:	f022                	sd	s0,32(sp)
    800039c4:	ec26                	sd	s1,24(sp)
    800039c6:	e84a                	sd	s2,16(sp)
    800039c8:	e44e                	sd	s3,8(sp)
    800039ca:	e052                	sd	s4,0(sp)
    800039cc:	1800                	addi	s0,sp,48
    800039ce:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800039d0:	47ad                	li	a5,11
    800039d2:	04b7fe63          	bgeu	a5,a1,80003a2e <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800039d6:	ff45849b          	addiw	s1,a1,-12
    800039da:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039de:	0ff00793          	li	a5,255
    800039e2:	0ae7e463          	bltu	a5,a4,80003a8a <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800039e6:	08052583          	lw	a1,128(a0)
    800039ea:	c5b5                	beqz	a1,80003a56 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800039ec:	00092503          	lw	a0,0(s2)
    800039f0:	00000097          	auipc	ra,0x0
    800039f4:	bda080e7          	jalr	-1062(ra) # 800035ca <bread>
    800039f8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800039fa:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800039fe:	02049713          	slli	a4,s1,0x20
    80003a02:	01e75593          	srli	a1,a4,0x1e
    80003a06:	00b784b3          	add	s1,a5,a1
    80003a0a:	0004a983          	lw	s3,0(s1)
    80003a0e:	04098e63          	beqz	s3,80003a6a <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003a12:	8552                	mv	a0,s4
    80003a14:	00000097          	auipc	ra,0x0
    80003a18:	ce6080e7          	jalr	-794(ra) # 800036fa <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003a1c:	854e                	mv	a0,s3
    80003a1e:	70a2                	ld	ra,40(sp)
    80003a20:	7402                	ld	s0,32(sp)
    80003a22:	64e2                	ld	s1,24(sp)
    80003a24:	6942                	ld	s2,16(sp)
    80003a26:	69a2                	ld	s3,8(sp)
    80003a28:	6a02                	ld	s4,0(sp)
    80003a2a:	6145                	addi	sp,sp,48
    80003a2c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003a2e:	02059793          	slli	a5,a1,0x20
    80003a32:	01e7d593          	srli	a1,a5,0x1e
    80003a36:	00b504b3          	add	s1,a0,a1
    80003a3a:	0504a983          	lw	s3,80(s1)
    80003a3e:	fc099fe3          	bnez	s3,80003a1c <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003a42:	4108                	lw	a0,0(a0)
    80003a44:	00000097          	auipc	ra,0x0
    80003a48:	e48080e7          	jalr	-440(ra) # 8000388c <balloc>
    80003a4c:	0005099b          	sext.w	s3,a0
    80003a50:	0534a823          	sw	s3,80(s1)
    80003a54:	b7e1                	j	80003a1c <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003a56:	4108                	lw	a0,0(a0)
    80003a58:	00000097          	auipc	ra,0x0
    80003a5c:	e34080e7          	jalr	-460(ra) # 8000388c <balloc>
    80003a60:	0005059b          	sext.w	a1,a0
    80003a64:	08b92023          	sw	a1,128(s2)
    80003a68:	b751                	j	800039ec <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003a6a:	00092503          	lw	a0,0(s2)
    80003a6e:	00000097          	auipc	ra,0x0
    80003a72:	e1e080e7          	jalr	-482(ra) # 8000388c <balloc>
    80003a76:	0005099b          	sext.w	s3,a0
    80003a7a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003a7e:	8552                	mv	a0,s4
    80003a80:	00001097          	auipc	ra,0x1
    80003a84:	244080e7          	jalr	580(ra) # 80004cc4 <log_write>
    80003a88:	b769                	j	80003a12 <bmap+0x54>
  panic("bmap: out of range");
    80003a8a:	00005517          	auipc	a0,0x5
    80003a8e:	bde50513          	addi	a0,a0,-1058 # 80008668 <syscalls+0x120>
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	a98080e7          	jalr	-1384(ra) # 8000052a <panic>

0000000080003a9a <iget>:
{
    80003a9a:	7179                	addi	sp,sp,-48
    80003a9c:	f406                	sd	ra,40(sp)
    80003a9e:	f022                	sd	s0,32(sp)
    80003aa0:	ec26                	sd	s1,24(sp)
    80003aa2:	e84a                	sd	s2,16(sp)
    80003aa4:	e44e                	sd	s3,8(sp)
    80003aa6:	e052                	sd	s4,0(sp)
    80003aa8:	1800                	addi	s0,sp,48
    80003aaa:	89aa                	mv	s3,a0
    80003aac:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003aae:	0002c517          	auipc	a0,0x2c
    80003ab2:	f1a50513          	addi	a0,a0,-230 # 8002f9c8 <itable>
    80003ab6:	ffffd097          	auipc	ra,0xffffd
    80003aba:	10c080e7          	jalr	268(ra) # 80000bc2 <acquire>
  empty = 0;
    80003abe:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ac0:	0002c497          	auipc	s1,0x2c
    80003ac4:	f2048493          	addi	s1,s1,-224 # 8002f9e0 <itable+0x18>
    80003ac8:	0002e697          	auipc	a3,0x2e
    80003acc:	9a868693          	addi	a3,a3,-1624 # 80031470 <log>
    80003ad0:	a039                	j	80003ade <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ad2:	02090b63          	beqz	s2,80003b08 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ad6:	08848493          	addi	s1,s1,136
    80003ada:	02d48a63          	beq	s1,a3,80003b0e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ade:	449c                	lw	a5,8(s1)
    80003ae0:	fef059e3          	blez	a5,80003ad2 <iget+0x38>
    80003ae4:	4098                	lw	a4,0(s1)
    80003ae6:	ff3716e3          	bne	a4,s3,80003ad2 <iget+0x38>
    80003aea:	40d8                	lw	a4,4(s1)
    80003aec:	ff4713e3          	bne	a4,s4,80003ad2 <iget+0x38>
      ip->ref++;
    80003af0:	2785                	addiw	a5,a5,1
    80003af2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003af4:	0002c517          	auipc	a0,0x2c
    80003af8:	ed450513          	addi	a0,a0,-300 # 8002f9c8 <itable>
    80003afc:	ffffd097          	auipc	ra,0xffffd
    80003b00:	17a080e7          	jalr	378(ra) # 80000c76 <release>
      return ip;
    80003b04:	8926                	mv	s2,s1
    80003b06:	a03d                	j	80003b34 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b08:	f7f9                	bnez	a5,80003ad6 <iget+0x3c>
    80003b0a:	8926                	mv	s2,s1
    80003b0c:	b7e9                	j	80003ad6 <iget+0x3c>
  if(empty == 0)
    80003b0e:	02090c63          	beqz	s2,80003b46 <iget+0xac>
  ip->dev = dev;
    80003b12:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b16:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b1a:	4785                	li	a5,1
    80003b1c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b20:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b24:	0002c517          	auipc	a0,0x2c
    80003b28:	ea450513          	addi	a0,a0,-348 # 8002f9c8 <itable>
    80003b2c:	ffffd097          	auipc	ra,0xffffd
    80003b30:	14a080e7          	jalr	330(ra) # 80000c76 <release>
}
    80003b34:	854a                	mv	a0,s2
    80003b36:	70a2                	ld	ra,40(sp)
    80003b38:	7402                	ld	s0,32(sp)
    80003b3a:	64e2                	ld	s1,24(sp)
    80003b3c:	6942                	ld	s2,16(sp)
    80003b3e:	69a2                	ld	s3,8(sp)
    80003b40:	6a02                	ld	s4,0(sp)
    80003b42:	6145                	addi	sp,sp,48
    80003b44:	8082                	ret
    panic("iget: no inodes");
    80003b46:	00005517          	auipc	a0,0x5
    80003b4a:	b3a50513          	addi	a0,a0,-1222 # 80008680 <syscalls+0x138>
    80003b4e:	ffffd097          	auipc	ra,0xffffd
    80003b52:	9dc080e7          	jalr	-1572(ra) # 8000052a <panic>

0000000080003b56 <fsinit>:
fsinit(int dev) {
    80003b56:	7179                	addi	sp,sp,-48
    80003b58:	f406                	sd	ra,40(sp)
    80003b5a:	f022                	sd	s0,32(sp)
    80003b5c:	ec26                	sd	s1,24(sp)
    80003b5e:	e84a                	sd	s2,16(sp)
    80003b60:	e44e                	sd	s3,8(sp)
    80003b62:	1800                	addi	s0,sp,48
    80003b64:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b66:	4585                	li	a1,1
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	a62080e7          	jalr	-1438(ra) # 800035ca <bread>
    80003b70:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b72:	0002c997          	auipc	s3,0x2c
    80003b76:	e3698993          	addi	s3,s3,-458 # 8002f9a8 <sb>
    80003b7a:	02000613          	li	a2,32
    80003b7e:	05850593          	addi	a1,a0,88
    80003b82:	854e                	mv	a0,s3
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	196080e7          	jalr	406(ra) # 80000d1a <memmove>
  brelse(bp);
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	b6c080e7          	jalr	-1172(ra) # 800036fa <brelse>
  if(sb.magic != FSMAGIC)
    80003b96:	0009a703          	lw	a4,0(s3)
    80003b9a:	102037b7          	lui	a5,0x10203
    80003b9e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ba2:	02f71263          	bne	a4,a5,80003bc6 <fsinit+0x70>
  initlog(dev, &sb);
    80003ba6:	0002c597          	auipc	a1,0x2c
    80003baa:	e0258593          	addi	a1,a1,-510 # 8002f9a8 <sb>
    80003bae:	854a                	mv	a0,s2
    80003bb0:	00001097          	auipc	ra,0x1
    80003bb4:	e96080e7          	jalr	-362(ra) # 80004a46 <initlog>
}
    80003bb8:	70a2                	ld	ra,40(sp)
    80003bba:	7402                	ld	s0,32(sp)
    80003bbc:	64e2                	ld	s1,24(sp)
    80003bbe:	6942                	ld	s2,16(sp)
    80003bc0:	69a2                	ld	s3,8(sp)
    80003bc2:	6145                	addi	sp,sp,48
    80003bc4:	8082                	ret
    panic("invalid file system");
    80003bc6:	00005517          	auipc	a0,0x5
    80003bca:	aca50513          	addi	a0,a0,-1334 # 80008690 <syscalls+0x148>
    80003bce:	ffffd097          	auipc	ra,0xffffd
    80003bd2:	95c080e7          	jalr	-1700(ra) # 8000052a <panic>

0000000080003bd6 <iinit>:
{
    80003bd6:	7179                	addi	sp,sp,-48
    80003bd8:	f406                	sd	ra,40(sp)
    80003bda:	f022                	sd	s0,32(sp)
    80003bdc:	ec26                	sd	s1,24(sp)
    80003bde:	e84a                	sd	s2,16(sp)
    80003be0:	e44e                	sd	s3,8(sp)
    80003be2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003be4:	00005597          	auipc	a1,0x5
    80003be8:	ac458593          	addi	a1,a1,-1340 # 800086a8 <syscalls+0x160>
    80003bec:	0002c517          	auipc	a0,0x2c
    80003bf0:	ddc50513          	addi	a0,a0,-548 # 8002f9c8 <itable>
    80003bf4:	ffffd097          	auipc	ra,0xffffd
    80003bf8:	f3e080e7          	jalr	-194(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003bfc:	0002c497          	auipc	s1,0x2c
    80003c00:	df448493          	addi	s1,s1,-524 # 8002f9f0 <itable+0x28>
    80003c04:	0002e997          	auipc	s3,0x2e
    80003c08:	87c98993          	addi	s3,s3,-1924 # 80031480 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c0c:	00005917          	auipc	s2,0x5
    80003c10:	aa490913          	addi	s2,s2,-1372 # 800086b0 <syscalls+0x168>
    80003c14:	85ca                	mv	a1,s2
    80003c16:	8526                	mv	a0,s1
    80003c18:	00001097          	auipc	ra,0x1
    80003c1c:	192080e7          	jalr	402(ra) # 80004daa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c20:	08848493          	addi	s1,s1,136
    80003c24:	ff3498e3          	bne	s1,s3,80003c14 <iinit+0x3e>
}
    80003c28:	70a2                	ld	ra,40(sp)
    80003c2a:	7402                	ld	s0,32(sp)
    80003c2c:	64e2                	ld	s1,24(sp)
    80003c2e:	6942                	ld	s2,16(sp)
    80003c30:	69a2                	ld	s3,8(sp)
    80003c32:	6145                	addi	sp,sp,48
    80003c34:	8082                	ret

0000000080003c36 <ialloc>:
{
    80003c36:	715d                	addi	sp,sp,-80
    80003c38:	e486                	sd	ra,72(sp)
    80003c3a:	e0a2                	sd	s0,64(sp)
    80003c3c:	fc26                	sd	s1,56(sp)
    80003c3e:	f84a                	sd	s2,48(sp)
    80003c40:	f44e                	sd	s3,40(sp)
    80003c42:	f052                	sd	s4,32(sp)
    80003c44:	ec56                	sd	s5,24(sp)
    80003c46:	e85a                	sd	s6,16(sp)
    80003c48:	e45e                	sd	s7,8(sp)
    80003c4a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c4c:	0002c717          	auipc	a4,0x2c
    80003c50:	d6872703          	lw	a4,-664(a4) # 8002f9b4 <sb+0xc>
    80003c54:	4785                	li	a5,1
    80003c56:	04e7fa63          	bgeu	a5,a4,80003caa <ialloc+0x74>
    80003c5a:	8aaa                	mv	s5,a0
    80003c5c:	8bae                	mv	s7,a1
    80003c5e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c60:	0002ca17          	auipc	s4,0x2c
    80003c64:	d48a0a13          	addi	s4,s4,-696 # 8002f9a8 <sb>
    80003c68:	00048b1b          	sext.w	s6,s1
    80003c6c:	0044d793          	srli	a5,s1,0x4
    80003c70:	018a2583          	lw	a1,24(s4)
    80003c74:	9dbd                	addw	a1,a1,a5
    80003c76:	8556                	mv	a0,s5
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	952080e7          	jalr	-1710(ra) # 800035ca <bread>
    80003c80:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c82:	05850993          	addi	s3,a0,88
    80003c86:	00f4f793          	andi	a5,s1,15
    80003c8a:	079a                	slli	a5,a5,0x6
    80003c8c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c8e:	00099783          	lh	a5,0(s3)
    80003c92:	c785                	beqz	a5,80003cba <ialloc+0x84>
    brelse(bp);
    80003c94:	00000097          	auipc	ra,0x0
    80003c98:	a66080e7          	jalr	-1434(ra) # 800036fa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c9c:	0485                	addi	s1,s1,1
    80003c9e:	00ca2703          	lw	a4,12(s4)
    80003ca2:	0004879b          	sext.w	a5,s1
    80003ca6:	fce7e1e3          	bltu	a5,a4,80003c68 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003caa:	00005517          	auipc	a0,0x5
    80003cae:	a0e50513          	addi	a0,a0,-1522 # 800086b8 <syscalls+0x170>
    80003cb2:	ffffd097          	auipc	ra,0xffffd
    80003cb6:	878080e7          	jalr	-1928(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003cba:	04000613          	li	a2,64
    80003cbe:	4581                	li	a1,0
    80003cc0:	854e                	mv	a0,s3
    80003cc2:	ffffd097          	auipc	ra,0xffffd
    80003cc6:	ffc080e7          	jalr	-4(ra) # 80000cbe <memset>
      dip->type = type;
    80003cca:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003cce:	854a                	mv	a0,s2
    80003cd0:	00001097          	auipc	ra,0x1
    80003cd4:	ff4080e7          	jalr	-12(ra) # 80004cc4 <log_write>
      brelse(bp);
    80003cd8:	854a                	mv	a0,s2
    80003cda:	00000097          	auipc	ra,0x0
    80003cde:	a20080e7          	jalr	-1504(ra) # 800036fa <brelse>
      return iget(dev, inum);
    80003ce2:	85da                	mv	a1,s6
    80003ce4:	8556                	mv	a0,s5
    80003ce6:	00000097          	auipc	ra,0x0
    80003cea:	db4080e7          	jalr	-588(ra) # 80003a9a <iget>
}
    80003cee:	60a6                	ld	ra,72(sp)
    80003cf0:	6406                	ld	s0,64(sp)
    80003cf2:	74e2                	ld	s1,56(sp)
    80003cf4:	7942                	ld	s2,48(sp)
    80003cf6:	79a2                	ld	s3,40(sp)
    80003cf8:	7a02                	ld	s4,32(sp)
    80003cfa:	6ae2                	ld	s5,24(sp)
    80003cfc:	6b42                	ld	s6,16(sp)
    80003cfe:	6ba2                	ld	s7,8(sp)
    80003d00:	6161                	addi	sp,sp,80
    80003d02:	8082                	ret

0000000080003d04 <iupdate>:
{
    80003d04:	1101                	addi	sp,sp,-32
    80003d06:	ec06                	sd	ra,24(sp)
    80003d08:	e822                	sd	s0,16(sp)
    80003d0a:	e426                	sd	s1,8(sp)
    80003d0c:	e04a                	sd	s2,0(sp)
    80003d0e:	1000                	addi	s0,sp,32
    80003d10:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d12:	415c                	lw	a5,4(a0)
    80003d14:	0047d79b          	srliw	a5,a5,0x4
    80003d18:	0002c597          	auipc	a1,0x2c
    80003d1c:	ca85a583          	lw	a1,-856(a1) # 8002f9c0 <sb+0x18>
    80003d20:	9dbd                	addw	a1,a1,a5
    80003d22:	4108                	lw	a0,0(a0)
    80003d24:	00000097          	auipc	ra,0x0
    80003d28:	8a6080e7          	jalr	-1882(ra) # 800035ca <bread>
    80003d2c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d2e:	05850793          	addi	a5,a0,88
    80003d32:	40c8                	lw	a0,4(s1)
    80003d34:	893d                	andi	a0,a0,15
    80003d36:	051a                	slli	a0,a0,0x6
    80003d38:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003d3a:	04449703          	lh	a4,68(s1)
    80003d3e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003d42:	04649703          	lh	a4,70(s1)
    80003d46:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003d4a:	04849703          	lh	a4,72(s1)
    80003d4e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003d52:	04a49703          	lh	a4,74(s1)
    80003d56:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003d5a:	44f8                	lw	a4,76(s1)
    80003d5c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d5e:	03400613          	li	a2,52
    80003d62:	05048593          	addi	a1,s1,80
    80003d66:	0531                	addi	a0,a0,12
    80003d68:	ffffd097          	auipc	ra,0xffffd
    80003d6c:	fb2080e7          	jalr	-78(ra) # 80000d1a <memmove>
  log_write(bp);
    80003d70:	854a                	mv	a0,s2
    80003d72:	00001097          	auipc	ra,0x1
    80003d76:	f52080e7          	jalr	-174(ra) # 80004cc4 <log_write>
  brelse(bp);
    80003d7a:	854a                	mv	a0,s2
    80003d7c:	00000097          	auipc	ra,0x0
    80003d80:	97e080e7          	jalr	-1666(ra) # 800036fa <brelse>
}
    80003d84:	60e2                	ld	ra,24(sp)
    80003d86:	6442                	ld	s0,16(sp)
    80003d88:	64a2                	ld	s1,8(sp)
    80003d8a:	6902                	ld	s2,0(sp)
    80003d8c:	6105                	addi	sp,sp,32
    80003d8e:	8082                	ret

0000000080003d90 <idup>:
{
    80003d90:	1101                	addi	sp,sp,-32
    80003d92:	ec06                	sd	ra,24(sp)
    80003d94:	e822                	sd	s0,16(sp)
    80003d96:	e426                	sd	s1,8(sp)
    80003d98:	1000                	addi	s0,sp,32
    80003d9a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d9c:	0002c517          	auipc	a0,0x2c
    80003da0:	c2c50513          	addi	a0,a0,-980 # 8002f9c8 <itable>
    80003da4:	ffffd097          	auipc	ra,0xffffd
    80003da8:	e1e080e7          	jalr	-482(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003dac:	449c                	lw	a5,8(s1)
    80003dae:	2785                	addiw	a5,a5,1
    80003db0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003db2:	0002c517          	auipc	a0,0x2c
    80003db6:	c1650513          	addi	a0,a0,-1002 # 8002f9c8 <itable>
    80003dba:	ffffd097          	auipc	ra,0xffffd
    80003dbe:	ebc080e7          	jalr	-324(ra) # 80000c76 <release>
}
    80003dc2:	8526                	mv	a0,s1
    80003dc4:	60e2                	ld	ra,24(sp)
    80003dc6:	6442                	ld	s0,16(sp)
    80003dc8:	64a2                	ld	s1,8(sp)
    80003dca:	6105                	addi	sp,sp,32
    80003dcc:	8082                	ret

0000000080003dce <ilock>:
{
    80003dce:	1101                	addi	sp,sp,-32
    80003dd0:	ec06                	sd	ra,24(sp)
    80003dd2:	e822                	sd	s0,16(sp)
    80003dd4:	e426                	sd	s1,8(sp)
    80003dd6:	e04a                	sd	s2,0(sp)
    80003dd8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003dda:	c115                	beqz	a0,80003dfe <ilock+0x30>
    80003ddc:	84aa                	mv	s1,a0
    80003dde:	451c                	lw	a5,8(a0)
    80003de0:	00f05f63          	blez	a5,80003dfe <ilock+0x30>
  acquiresleep(&ip->lock);
    80003de4:	0541                	addi	a0,a0,16
    80003de6:	00001097          	auipc	ra,0x1
    80003dea:	ffe080e7          	jalr	-2(ra) # 80004de4 <acquiresleep>
  if(ip->valid == 0){
    80003dee:	40bc                	lw	a5,64(s1)
    80003df0:	cf99                	beqz	a5,80003e0e <ilock+0x40>
}
    80003df2:	60e2                	ld	ra,24(sp)
    80003df4:	6442                	ld	s0,16(sp)
    80003df6:	64a2                	ld	s1,8(sp)
    80003df8:	6902                	ld	s2,0(sp)
    80003dfa:	6105                	addi	sp,sp,32
    80003dfc:	8082                	ret
    panic("ilock");
    80003dfe:	00005517          	auipc	a0,0x5
    80003e02:	8d250513          	addi	a0,a0,-1838 # 800086d0 <syscalls+0x188>
    80003e06:	ffffc097          	auipc	ra,0xffffc
    80003e0a:	724080e7          	jalr	1828(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e0e:	40dc                	lw	a5,4(s1)
    80003e10:	0047d79b          	srliw	a5,a5,0x4
    80003e14:	0002c597          	auipc	a1,0x2c
    80003e18:	bac5a583          	lw	a1,-1108(a1) # 8002f9c0 <sb+0x18>
    80003e1c:	9dbd                	addw	a1,a1,a5
    80003e1e:	4088                	lw	a0,0(s1)
    80003e20:	fffff097          	auipc	ra,0xfffff
    80003e24:	7aa080e7          	jalr	1962(ra) # 800035ca <bread>
    80003e28:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e2a:	05850593          	addi	a1,a0,88
    80003e2e:	40dc                	lw	a5,4(s1)
    80003e30:	8bbd                	andi	a5,a5,15
    80003e32:	079a                	slli	a5,a5,0x6
    80003e34:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e36:	00059783          	lh	a5,0(a1)
    80003e3a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e3e:	00259783          	lh	a5,2(a1)
    80003e42:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e46:	00459783          	lh	a5,4(a1)
    80003e4a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e4e:	00659783          	lh	a5,6(a1)
    80003e52:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e56:	459c                	lw	a5,8(a1)
    80003e58:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e5a:	03400613          	li	a2,52
    80003e5e:	05b1                	addi	a1,a1,12
    80003e60:	05048513          	addi	a0,s1,80
    80003e64:	ffffd097          	auipc	ra,0xffffd
    80003e68:	eb6080e7          	jalr	-330(ra) # 80000d1a <memmove>
    brelse(bp);
    80003e6c:	854a                	mv	a0,s2
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	88c080e7          	jalr	-1908(ra) # 800036fa <brelse>
    ip->valid = 1;
    80003e76:	4785                	li	a5,1
    80003e78:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e7a:	04449783          	lh	a5,68(s1)
    80003e7e:	fbb5                	bnez	a5,80003df2 <ilock+0x24>
      panic("ilock: no type");
    80003e80:	00005517          	auipc	a0,0x5
    80003e84:	85850513          	addi	a0,a0,-1960 # 800086d8 <syscalls+0x190>
    80003e88:	ffffc097          	auipc	ra,0xffffc
    80003e8c:	6a2080e7          	jalr	1698(ra) # 8000052a <panic>

0000000080003e90 <iunlock>:
{
    80003e90:	1101                	addi	sp,sp,-32
    80003e92:	ec06                	sd	ra,24(sp)
    80003e94:	e822                	sd	s0,16(sp)
    80003e96:	e426                	sd	s1,8(sp)
    80003e98:	e04a                	sd	s2,0(sp)
    80003e9a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e9c:	c905                	beqz	a0,80003ecc <iunlock+0x3c>
    80003e9e:	84aa                	mv	s1,a0
    80003ea0:	01050913          	addi	s2,a0,16
    80003ea4:	854a                	mv	a0,s2
    80003ea6:	00001097          	auipc	ra,0x1
    80003eaa:	fd8080e7          	jalr	-40(ra) # 80004e7e <holdingsleep>
    80003eae:	cd19                	beqz	a0,80003ecc <iunlock+0x3c>
    80003eb0:	449c                	lw	a5,8(s1)
    80003eb2:	00f05d63          	blez	a5,80003ecc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003eb6:	854a                	mv	a0,s2
    80003eb8:	00001097          	auipc	ra,0x1
    80003ebc:	f82080e7          	jalr	-126(ra) # 80004e3a <releasesleep>
}
    80003ec0:	60e2                	ld	ra,24(sp)
    80003ec2:	6442                	ld	s0,16(sp)
    80003ec4:	64a2                	ld	s1,8(sp)
    80003ec6:	6902                	ld	s2,0(sp)
    80003ec8:	6105                	addi	sp,sp,32
    80003eca:	8082                	ret
    panic("iunlock");
    80003ecc:	00005517          	auipc	a0,0x5
    80003ed0:	81c50513          	addi	a0,a0,-2020 # 800086e8 <syscalls+0x1a0>
    80003ed4:	ffffc097          	auipc	ra,0xffffc
    80003ed8:	656080e7          	jalr	1622(ra) # 8000052a <panic>

0000000080003edc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003edc:	7179                	addi	sp,sp,-48
    80003ede:	f406                	sd	ra,40(sp)
    80003ee0:	f022                	sd	s0,32(sp)
    80003ee2:	ec26                	sd	s1,24(sp)
    80003ee4:	e84a                	sd	s2,16(sp)
    80003ee6:	e44e                	sd	s3,8(sp)
    80003ee8:	e052                	sd	s4,0(sp)
    80003eea:	1800                	addi	s0,sp,48
    80003eec:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003eee:	05050493          	addi	s1,a0,80
    80003ef2:	08050913          	addi	s2,a0,128
    80003ef6:	a021                	j	80003efe <itrunc+0x22>
    80003ef8:	0491                	addi	s1,s1,4
    80003efa:	01248d63          	beq	s1,s2,80003f14 <itrunc+0x38>
    if(ip->addrs[i]){
    80003efe:	408c                	lw	a1,0(s1)
    80003f00:	dde5                	beqz	a1,80003ef8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003f02:	0009a503          	lw	a0,0(s3)
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	90a080e7          	jalr	-1782(ra) # 80003810 <bfree>
      ip->addrs[i] = 0;
    80003f0e:	0004a023          	sw	zero,0(s1)
    80003f12:	b7dd                	j	80003ef8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f14:	0809a583          	lw	a1,128(s3)
    80003f18:	e185                	bnez	a1,80003f38 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f1a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f1e:	854e                	mv	a0,s3
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	de4080e7          	jalr	-540(ra) # 80003d04 <iupdate>
}
    80003f28:	70a2                	ld	ra,40(sp)
    80003f2a:	7402                	ld	s0,32(sp)
    80003f2c:	64e2                	ld	s1,24(sp)
    80003f2e:	6942                	ld	s2,16(sp)
    80003f30:	69a2                	ld	s3,8(sp)
    80003f32:	6a02                	ld	s4,0(sp)
    80003f34:	6145                	addi	sp,sp,48
    80003f36:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f38:	0009a503          	lw	a0,0(s3)
    80003f3c:	fffff097          	auipc	ra,0xfffff
    80003f40:	68e080e7          	jalr	1678(ra) # 800035ca <bread>
    80003f44:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f46:	05850493          	addi	s1,a0,88
    80003f4a:	45850913          	addi	s2,a0,1112
    80003f4e:	a021                	j	80003f56 <itrunc+0x7a>
    80003f50:	0491                	addi	s1,s1,4
    80003f52:	01248b63          	beq	s1,s2,80003f68 <itrunc+0x8c>
      if(a[j])
    80003f56:	408c                	lw	a1,0(s1)
    80003f58:	dde5                	beqz	a1,80003f50 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003f5a:	0009a503          	lw	a0,0(s3)
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	8b2080e7          	jalr	-1870(ra) # 80003810 <bfree>
    80003f66:	b7ed                	j	80003f50 <itrunc+0x74>
    brelse(bp);
    80003f68:	8552                	mv	a0,s4
    80003f6a:	fffff097          	auipc	ra,0xfffff
    80003f6e:	790080e7          	jalr	1936(ra) # 800036fa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f72:	0809a583          	lw	a1,128(s3)
    80003f76:	0009a503          	lw	a0,0(s3)
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	896080e7          	jalr	-1898(ra) # 80003810 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f82:	0809a023          	sw	zero,128(s3)
    80003f86:	bf51                	j	80003f1a <itrunc+0x3e>

0000000080003f88 <iput>:
{
    80003f88:	1101                	addi	sp,sp,-32
    80003f8a:	ec06                	sd	ra,24(sp)
    80003f8c:	e822                	sd	s0,16(sp)
    80003f8e:	e426                	sd	s1,8(sp)
    80003f90:	e04a                	sd	s2,0(sp)
    80003f92:	1000                	addi	s0,sp,32
    80003f94:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f96:	0002c517          	auipc	a0,0x2c
    80003f9a:	a3250513          	addi	a0,a0,-1486 # 8002f9c8 <itable>
    80003f9e:	ffffd097          	auipc	ra,0xffffd
    80003fa2:	c24080e7          	jalr	-988(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fa6:	4498                	lw	a4,8(s1)
    80003fa8:	4785                	li	a5,1
    80003faa:	02f70363          	beq	a4,a5,80003fd0 <iput+0x48>
  ip->ref--;
    80003fae:	449c                	lw	a5,8(s1)
    80003fb0:	37fd                	addiw	a5,a5,-1
    80003fb2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fb4:	0002c517          	auipc	a0,0x2c
    80003fb8:	a1450513          	addi	a0,a0,-1516 # 8002f9c8 <itable>
    80003fbc:	ffffd097          	auipc	ra,0xffffd
    80003fc0:	cba080e7          	jalr	-838(ra) # 80000c76 <release>
}
    80003fc4:	60e2                	ld	ra,24(sp)
    80003fc6:	6442                	ld	s0,16(sp)
    80003fc8:	64a2                	ld	s1,8(sp)
    80003fca:	6902                	ld	s2,0(sp)
    80003fcc:	6105                	addi	sp,sp,32
    80003fce:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fd0:	40bc                	lw	a5,64(s1)
    80003fd2:	dff1                	beqz	a5,80003fae <iput+0x26>
    80003fd4:	04a49783          	lh	a5,74(s1)
    80003fd8:	fbf9                	bnez	a5,80003fae <iput+0x26>
    acquiresleep(&ip->lock);
    80003fda:	01048913          	addi	s2,s1,16
    80003fde:	854a                	mv	a0,s2
    80003fe0:	00001097          	auipc	ra,0x1
    80003fe4:	e04080e7          	jalr	-508(ra) # 80004de4 <acquiresleep>
    release(&itable.lock);
    80003fe8:	0002c517          	auipc	a0,0x2c
    80003fec:	9e050513          	addi	a0,a0,-1568 # 8002f9c8 <itable>
    80003ff0:	ffffd097          	auipc	ra,0xffffd
    80003ff4:	c86080e7          	jalr	-890(ra) # 80000c76 <release>
    itrunc(ip);
    80003ff8:	8526                	mv	a0,s1
    80003ffa:	00000097          	auipc	ra,0x0
    80003ffe:	ee2080e7          	jalr	-286(ra) # 80003edc <itrunc>
    ip->type = 0;
    80004002:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004006:	8526                	mv	a0,s1
    80004008:	00000097          	auipc	ra,0x0
    8000400c:	cfc080e7          	jalr	-772(ra) # 80003d04 <iupdate>
    ip->valid = 0;
    80004010:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004014:	854a                	mv	a0,s2
    80004016:	00001097          	auipc	ra,0x1
    8000401a:	e24080e7          	jalr	-476(ra) # 80004e3a <releasesleep>
    acquire(&itable.lock);
    8000401e:	0002c517          	auipc	a0,0x2c
    80004022:	9aa50513          	addi	a0,a0,-1622 # 8002f9c8 <itable>
    80004026:	ffffd097          	auipc	ra,0xffffd
    8000402a:	b9c080e7          	jalr	-1124(ra) # 80000bc2 <acquire>
    8000402e:	b741                	j	80003fae <iput+0x26>

0000000080004030 <iunlockput>:
{
    80004030:	1101                	addi	sp,sp,-32
    80004032:	ec06                	sd	ra,24(sp)
    80004034:	e822                	sd	s0,16(sp)
    80004036:	e426                	sd	s1,8(sp)
    80004038:	1000                	addi	s0,sp,32
    8000403a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000403c:	00000097          	auipc	ra,0x0
    80004040:	e54080e7          	jalr	-428(ra) # 80003e90 <iunlock>
  iput(ip);
    80004044:	8526                	mv	a0,s1
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	f42080e7          	jalr	-190(ra) # 80003f88 <iput>
}
    8000404e:	60e2                	ld	ra,24(sp)
    80004050:	6442                	ld	s0,16(sp)
    80004052:	64a2                	ld	s1,8(sp)
    80004054:	6105                	addi	sp,sp,32
    80004056:	8082                	ret

0000000080004058 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004058:	1141                	addi	sp,sp,-16
    8000405a:	e422                	sd	s0,8(sp)
    8000405c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000405e:	411c                	lw	a5,0(a0)
    80004060:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004062:	415c                	lw	a5,4(a0)
    80004064:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004066:	04451783          	lh	a5,68(a0)
    8000406a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000406e:	04a51783          	lh	a5,74(a0)
    80004072:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004076:	04c56783          	lwu	a5,76(a0)
    8000407a:	e99c                	sd	a5,16(a1)
}
    8000407c:	6422                	ld	s0,8(sp)
    8000407e:	0141                	addi	sp,sp,16
    80004080:	8082                	ret

0000000080004082 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004082:	457c                	lw	a5,76(a0)
    80004084:	0ed7e963          	bltu	a5,a3,80004176 <readi+0xf4>
{
    80004088:	7159                	addi	sp,sp,-112
    8000408a:	f486                	sd	ra,104(sp)
    8000408c:	f0a2                	sd	s0,96(sp)
    8000408e:	eca6                	sd	s1,88(sp)
    80004090:	e8ca                	sd	s2,80(sp)
    80004092:	e4ce                	sd	s3,72(sp)
    80004094:	e0d2                	sd	s4,64(sp)
    80004096:	fc56                	sd	s5,56(sp)
    80004098:	f85a                	sd	s6,48(sp)
    8000409a:	f45e                	sd	s7,40(sp)
    8000409c:	f062                	sd	s8,32(sp)
    8000409e:	ec66                	sd	s9,24(sp)
    800040a0:	e86a                	sd	s10,16(sp)
    800040a2:	e46e                	sd	s11,8(sp)
    800040a4:	1880                	addi	s0,sp,112
    800040a6:	8baa                	mv	s7,a0
    800040a8:	8c2e                	mv	s8,a1
    800040aa:	8ab2                	mv	s5,a2
    800040ac:	84b6                	mv	s1,a3
    800040ae:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040b0:	9f35                	addw	a4,a4,a3
    return 0;
    800040b2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800040b4:	0ad76063          	bltu	a4,a3,80004154 <readi+0xd2>
  if(off + n > ip->size)
    800040b8:	00e7f463          	bgeu	a5,a4,800040c0 <readi+0x3e>
    n = ip->size - off;
    800040bc:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040c0:	0a0b0963          	beqz	s6,80004172 <readi+0xf0>
    800040c4:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800040ca:	5cfd                	li	s9,-1
    800040cc:	a82d                	j	80004106 <readi+0x84>
    800040ce:	020a1d93          	slli	s11,s4,0x20
    800040d2:	020ddd93          	srli	s11,s11,0x20
    800040d6:	05890793          	addi	a5,s2,88
    800040da:	86ee                	mv	a3,s11
    800040dc:	963e                	add	a2,a2,a5
    800040de:	85d6                	mv	a1,s5
    800040e0:	8562                	mv	a0,s8
    800040e2:	fffff097          	auipc	ra,0xfffff
    800040e6:	a58080e7          	jalr	-1448(ra) # 80002b3a <either_copyout>
    800040ea:	05950d63          	beq	a0,s9,80004144 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800040ee:	854a                	mv	a0,s2
    800040f0:	fffff097          	auipc	ra,0xfffff
    800040f4:	60a080e7          	jalr	1546(ra) # 800036fa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040f8:	013a09bb          	addw	s3,s4,s3
    800040fc:	009a04bb          	addw	s1,s4,s1
    80004100:	9aee                	add	s5,s5,s11
    80004102:	0569f763          	bgeu	s3,s6,80004150 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004106:	000ba903          	lw	s2,0(s7)
    8000410a:	00a4d59b          	srliw	a1,s1,0xa
    8000410e:	855e                	mv	a0,s7
    80004110:	00000097          	auipc	ra,0x0
    80004114:	8ae080e7          	jalr	-1874(ra) # 800039be <bmap>
    80004118:	0005059b          	sext.w	a1,a0
    8000411c:	854a                	mv	a0,s2
    8000411e:	fffff097          	auipc	ra,0xfffff
    80004122:	4ac080e7          	jalr	1196(ra) # 800035ca <bread>
    80004126:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004128:	3ff4f613          	andi	a2,s1,1023
    8000412c:	40cd07bb          	subw	a5,s10,a2
    80004130:	413b073b          	subw	a4,s6,s3
    80004134:	8a3e                	mv	s4,a5
    80004136:	2781                	sext.w	a5,a5
    80004138:	0007069b          	sext.w	a3,a4
    8000413c:	f8f6f9e3          	bgeu	a3,a5,800040ce <readi+0x4c>
    80004140:	8a3a                	mv	s4,a4
    80004142:	b771                	j	800040ce <readi+0x4c>
      brelse(bp);
    80004144:	854a                	mv	a0,s2
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	5b4080e7          	jalr	1460(ra) # 800036fa <brelse>
      tot = -1;
    8000414e:	59fd                	li	s3,-1
  }
  return tot;
    80004150:	0009851b          	sext.w	a0,s3
}
    80004154:	70a6                	ld	ra,104(sp)
    80004156:	7406                	ld	s0,96(sp)
    80004158:	64e6                	ld	s1,88(sp)
    8000415a:	6946                	ld	s2,80(sp)
    8000415c:	69a6                	ld	s3,72(sp)
    8000415e:	6a06                	ld	s4,64(sp)
    80004160:	7ae2                	ld	s5,56(sp)
    80004162:	7b42                	ld	s6,48(sp)
    80004164:	7ba2                	ld	s7,40(sp)
    80004166:	7c02                	ld	s8,32(sp)
    80004168:	6ce2                	ld	s9,24(sp)
    8000416a:	6d42                	ld	s10,16(sp)
    8000416c:	6da2                	ld	s11,8(sp)
    8000416e:	6165                	addi	sp,sp,112
    80004170:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004172:	89da                	mv	s3,s6
    80004174:	bff1                	j	80004150 <readi+0xce>
    return 0;
    80004176:	4501                	li	a0,0
}
    80004178:	8082                	ret

000000008000417a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000417a:	457c                	lw	a5,76(a0)
    8000417c:	10d7e863          	bltu	a5,a3,8000428c <writei+0x112>
{
    80004180:	7159                	addi	sp,sp,-112
    80004182:	f486                	sd	ra,104(sp)
    80004184:	f0a2                	sd	s0,96(sp)
    80004186:	eca6                	sd	s1,88(sp)
    80004188:	e8ca                	sd	s2,80(sp)
    8000418a:	e4ce                	sd	s3,72(sp)
    8000418c:	e0d2                	sd	s4,64(sp)
    8000418e:	fc56                	sd	s5,56(sp)
    80004190:	f85a                	sd	s6,48(sp)
    80004192:	f45e                	sd	s7,40(sp)
    80004194:	f062                	sd	s8,32(sp)
    80004196:	ec66                	sd	s9,24(sp)
    80004198:	e86a                	sd	s10,16(sp)
    8000419a:	e46e                	sd	s11,8(sp)
    8000419c:	1880                	addi	s0,sp,112
    8000419e:	8b2a                	mv	s6,a0
    800041a0:	8c2e                	mv	s8,a1
    800041a2:	8ab2                	mv	s5,a2
    800041a4:	8936                	mv	s2,a3
    800041a6:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800041a8:	00e687bb          	addw	a5,a3,a4
    800041ac:	0ed7e263          	bltu	a5,a3,80004290 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800041b0:	00043737          	lui	a4,0x43
    800041b4:	0ef76063          	bltu	a4,a5,80004294 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041b8:	0c0b8863          	beqz	s7,80004288 <writei+0x10e>
    800041bc:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800041be:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800041c2:	5cfd                	li	s9,-1
    800041c4:	a091                	j	80004208 <writei+0x8e>
    800041c6:	02099d93          	slli	s11,s3,0x20
    800041ca:	020ddd93          	srli	s11,s11,0x20
    800041ce:	05848793          	addi	a5,s1,88
    800041d2:	86ee                	mv	a3,s11
    800041d4:	8656                	mv	a2,s5
    800041d6:	85e2                	mv	a1,s8
    800041d8:	953e                	add	a0,a0,a5
    800041da:	fffff097          	auipc	ra,0xfffff
    800041de:	9b6080e7          	jalr	-1610(ra) # 80002b90 <either_copyin>
    800041e2:	07950263          	beq	a0,s9,80004246 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800041e6:	8526                	mv	a0,s1
    800041e8:	00001097          	auipc	ra,0x1
    800041ec:	adc080e7          	jalr	-1316(ra) # 80004cc4 <log_write>
    brelse(bp);
    800041f0:	8526                	mv	a0,s1
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	508080e7          	jalr	1288(ra) # 800036fa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041fa:	01498a3b          	addw	s4,s3,s4
    800041fe:	0129893b          	addw	s2,s3,s2
    80004202:	9aee                	add	s5,s5,s11
    80004204:	057a7663          	bgeu	s4,s7,80004250 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004208:	000b2483          	lw	s1,0(s6)
    8000420c:	00a9559b          	srliw	a1,s2,0xa
    80004210:	855a                	mv	a0,s6
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	7ac080e7          	jalr	1964(ra) # 800039be <bmap>
    8000421a:	0005059b          	sext.w	a1,a0
    8000421e:	8526                	mv	a0,s1
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	3aa080e7          	jalr	938(ra) # 800035ca <bread>
    80004228:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000422a:	3ff97513          	andi	a0,s2,1023
    8000422e:	40ad07bb          	subw	a5,s10,a0
    80004232:	414b873b          	subw	a4,s7,s4
    80004236:	89be                	mv	s3,a5
    80004238:	2781                	sext.w	a5,a5
    8000423a:	0007069b          	sext.w	a3,a4
    8000423e:	f8f6f4e3          	bgeu	a3,a5,800041c6 <writei+0x4c>
    80004242:	89ba                	mv	s3,a4
    80004244:	b749                	j	800041c6 <writei+0x4c>
      brelse(bp);
    80004246:	8526                	mv	a0,s1
    80004248:	fffff097          	auipc	ra,0xfffff
    8000424c:	4b2080e7          	jalr	1202(ra) # 800036fa <brelse>
  }

  if(off > ip->size)
    80004250:	04cb2783          	lw	a5,76(s6)
    80004254:	0127f463          	bgeu	a5,s2,8000425c <writei+0xe2>
    ip->size = off;
    80004258:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000425c:	855a                	mv	a0,s6
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	aa6080e7          	jalr	-1370(ra) # 80003d04 <iupdate>

  return tot;
    80004266:	000a051b          	sext.w	a0,s4
}
    8000426a:	70a6                	ld	ra,104(sp)
    8000426c:	7406                	ld	s0,96(sp)
    8000426e:	64e6                	ld	s1,88(sp)
    80004270:	6946                	ld	s2,80(sp)
    80004272:	69a6                	ld	s3,72(sp)
    80004274:	6a06                	ld	s4,64(sp)
    80004276:	7ae2                	ld	s5,56(sp)
    80004278:	7b42                	ld	s6,48(sp)
    8000427a:	7ba2                	ld	s7,40(sp)
    8000427c:	7c02                	ld	s8,32(sp)
    8000427e:	6ce2                	ld	s9,24(sp)
    80004280:	6d42                	ld	s10,16(sp)
    80004282:	6da2                	ld	s11,8(sp)
    80004284:	6165                	addi	sp,sp,112
    80004286:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004288:	8a5e                	mv	s4,s7
    8000428a:	bfc9                	j	8000425c <writei+0xe2>
    return -1;
    8000428c:	557d                	li	a0,-1
}
    8000428e:	8082                	ret
    return -1;
    80004290:	557d                	li	a0,-1
    80004292:	bfe1                	j	8000426a <writei+0xf0>
    return -1;
    80004294:	557d                	li	a0,-1
    80004296:	bfd1                	j	8000426a <writei+0xf0>

0000000080004298 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004298:	1141                	addi	sp,sp,-16
    8000429a:	e406                	sd	ra,8(sp)
    8000429c:	e022                	sd	s0,0(sp)
    8000429e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800042a0:	4639                	li	a2,14
    800042a2:	ffffd097          	auipc	ra,0xffffd
    800042a6:	af4080e7          	jalr	-1292(ra) # 80000d96 <strncmp>
}
    800042aa:	60a2                	ld	ra,8(sp)
    800042ac:	6402                	ld	s0,0(sp)
    800042ae:	0141                	addi	sp,sp,16
    800042b0:	8082                	ret

00000000800042b2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800042b2:	7139                	addi	sp,sp,-64
    800042b4:	fc06                	sd	ra,56(sp)
    800042b6:	f822                	sd	s0,48(sp)
    800042b8:	f426                	sd	s1,40(sp)
    800042ba:	f04a                	sd	s2,32(sp)
    800042bc:	ec4e                	sd	s3,24(sp)
    800042be:	e852                	sd	s4,16(sp)
    800042c0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800042c2:	04451703          	lh	a4,68(a0)
    800042c6:	4785                	li	a5,1
    800042c8:	00f71a63          	bne	a4,a5,800042dc <dirlookup+0x2a>
    800042cc:	892a                	mv	s2,a0
    800042ce:	89ae                	mv	s3,a1
    800042d0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800042d2:	457c                	lw	a5,76(a0)
    800042d4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800042d6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042d8:	e79d                	bnez	a5,80004306 <dirlookup+0x54>
    800042da:	a8a5                	j	80004352 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800042dc:	00004517          	auipc	a0,0x4
    800042e0:	41450513          	addi	a0,a0,1044 # 800086f0 <syscalls+0x1a8>
    800042e4:	ffffc097          	auipc	ra,0xffffc
    800042e8:	246080e7          	jalr	582(ra) # 8000052a <panic>
      panic("dirlookup read");
    800042ec:	00004517          	auipc	a0,0x4
    800042f0:	41c50513          	addi	a0,a0,1052 # 80008708 <syscalls+0x1c0>
    800042f4:	ffffc097          	auipc	ra,0xffffc
    800042f8:	236080e7          	jalr	566(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042fc:	24c1                	addiw	s1,s1,16
    800042fe:	04c92783          	lw	a5,76(s2)
    80004302:	04f4f763          	bgeu	s1,a5,80004350 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004306:	4741                	li	a4,16
    80004308:	86a6                	mv	a3,s1
    8000430a:	fc040613          	addi	a2,s0,-64
    8000430e:	4581                	li	a1,0
    80004310:	854a                	mv	a0,s2
    80004312:	00000097          	auipc	ra,0x0
    80004316:	d70080e7          	jalr	-656(ra) # 80004082 <readi>
    8000431a:	47c1                	li	a5,16
    8000431c:	fcf518e3          	bne	a0,a5,800042ec <dirlookup+0x3a>
    if(de.inum == 0)
    80004320:	fc045783          	lhu	a5,-64(s0)
    80004324:	dfe1                	beqz	a5,800042fc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004326:	fc240593          	addi	a1,s0,-62
    8000432a:	854e                	mv	a0,s3
    8000432c:	00000097          	auipc	ra,0x0
    80004330:	f6c080e7          	jalr	-148(ra) # 80004298 <namecmp>
    80004334:	f561                	bnez	a0,800042fc <dirlookup+0x4a>
      if(poff)
    80004336:	000a0463          	beqz	s4,8000433e <dirlookup+0x8c>
        *poff = off;
    8000433a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000433e:	fc045583          	lhu	a1,-64(s0)
    80004342:	00092503          	lw	a0,0(s2)
    80004346:	fffff097          	auipc	ra,0xfffff
    8000434a:	754080e7          	jalr	1876(ra) # 80003a9a <iget>
    8000434e:	a011                	j	80004352 <dirlookup+0xa0>
  return 0;
    80004350:	4501                	li	a0,0
}
    80004352:	70e2                	ld	ra,56(sp)
    80004354:	7442                	ld	s0,48(sp)
    80004356:	74a2                	ld	s1,40(sp)
    80004358:	7902                	ld	s2,32(sp)
    8000435a:	69e2                	ld	s3,24(sp)
    8000435c:	6a42                	ld	s4,16(sp)
    8000435e:	6121                	addi	sp,sp,64
    80004360:	8082                	ret

0000000080004362 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004362:	711d                	addi	sp,sp,-96
    80004364:	ec86                	sd	ra,88(sp)
    80004366:	e8a2                	sd	s0,80(sp)
    80004368:	e4a6                	sd	s1,72(sp)
    8000436a:	e0ca                	sd	s2,64(sp)
    8000436c:	fc4e                	sd	s3,56(sp)
    8000436e:	f852                	sd	s4,48(sp)
    80004370:	f456                	sd	s5,40(sp)
    80004372:	f05a                	sd	s6,32(sp)
    80004374:	ec5e                	sd	s7,24(sp)
    80004376:	e862                	sd	s8,16(sp)
    80004378:	e466                	sd	s9,8(sp)
    8000437a:	1080                	addi	s0,sp,96
    8000437c:	84aa                	mv	s1,a0
    8000437e:	8aae                	mv	s5,a1
    80004380:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004382:	00054703          	lbu	a4,0(a0)
    80004386:	02f00793          	li	a5,47
    8000438a:	02f70363          	beq	a4,a5,800043b0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000438e:	ffffe097          	auipc	ra,0xffffe
    80004392:	c32080e7          	jalr	-974(ra) # 80001fc0 <myproc>
    80004396:	15053503          	ld	a0,336(a0)
    8000439a:	00000097          	auipc	ra,0x0
    8000439e:	9f6080e7          	jalr	-1546(ra) # 80003d90 <idup>
    800043a2:	89aa                	mv	s3,a0
  while(*path == '/')
    800043a4:	02f00913          	li	s2,47
  len = path - s;
    800043a8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800043aa:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800043ac:	4b85                	li	s7,1
    800043ae:	a865                	j	80004466 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800043b0:	4585                	li	a1,1
    800043b2:	4505                	li	a0,1
    800043b4:	fffff097          	auipc	ra,0xfffff
    800043b8:	6e6080e7          	jalr	1766(ra) # 80003a9a <iget>
    800043bc:	89aa                	mv	s3,a0
    800043be:	b7dd                	j	800043a4 <namex+0x42>
      iunlockput(ip);
    800043c0:	854e                	mv	a0,s3
    800043c2:	00000097          	auipc	ra,0x0
    800043c6:	c6e080e7          	jalr	-914(ra) # 80004030 <iunlockput>
      return 0;
    800043ca:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800043cc:	854e                	mv	a0,s3
    800043ce:	60e6                	ld	ra,88(sp)
    800043d0:	6446                	ld	s0,80(sp)
    800043d2:	64a6                	ld	s1,72(sp)
    800043d4:	6906                	ld	s2,64(sp)
    800043d6:	79e2                	ld	s3,56(sp)
    800043d8:	7a42                	ld	s4,48(sp)
    800043da:	7aa2                	ld	s5,40(sp)
    800043dc:	7b02                	ld	s6,32(sp)
    800043de:	6be2                	ld	s7,24(sp)
    800043e0:	6c42                	ld	s8,16(sp)
    800043e2:	6ca2                	ld	s9,8(sp)
    800043e4:	6125                	addi	sp,sp,96
    800043e6:	8082                	ret
      iunlock(ip);
    800043e8:	854e                	mv	a0,s3
    800043ea:	00000097          	auipc	ra,0x0
    800043ee:	aa6080e7          	jalr	-1370(ra) # 80003e90 <iunlock>
      return ip;
    800043f2:	bfe9                	j	800043cc <namex+0x6a>
      iunlockput(ip);
    800043f4:	854e                	mv	a0,s3
    800043f6:	00000097          	auipc	ra,0x0
    800043fa:	c3a080e7          	jalr	-966(ra) # 80004030 <iunlockput>
      return 0;
    800043fe:	89e6                	mv	s3,s9
    80004400:	b7f1                	j	800043cc <namex+0x6a>
  len = path - s;
    80004402:	40b48633          	sub	a2,s1,a1
    80004406:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000440a:	099c5463          	bge	s8,s9,80004492 <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000440e:	4639                	li	a2,14
    80004410:	8552                	mv	a0,s4
    80004412:	ffffd097          	auipc	ra,0xffffd
    80004416:	908080e7          	jalr	-1784(ra) # 80000d1a <memmove>
  while(*path == '/')
    8000441a:	0004c783          	lbu	a5,0(s1)
    8000441e:	01279763          	bne	a5,s2,8000442c <namex+0xca>
    path++;
    80004422:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004424:	0004c783          	lbu	a5,0(s1)
    80004428:	ff278de3          	beq	a5,s2,80004422 <namex+0xc0>
    ilock(ip);
    8000442c:	854e                	mv	a0,s3
    8000442e:	00000097          	auipc	ra,0x0
    80004432:	9a0080e7          	jalr	-1632(ra) # 80003dce <ilock>
    if(ip->type != T_DIR){
    80004436:	04499783          	lh	a5,68(s3)
    8000443a:	f97793e3          	bne	a5,s7,800043c0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000443e:	000a8563          	beqz	s5,80004448 <namex+0xe6>
    80004442:	0004c783          	lbu	a5,0(s1)
    80004446:	d3cd                	beqz	a5,800043e8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004448:	865a                	mv	a2,s6
    8000444a:	85d2                	mv	a1,s4
    8000444c:	854e                	mv	a0,s3
    8000444e:	00000097          	auipc	ra,0x0
    80004452:	e64080e7          	jalr	-412(ra) # 800042b2 <dirlookup>
    80004456:	8caa                	mv	s9,a0
    80004458:	dd51                	beqz	a0,800043f4 <namex+0x92>
    iunlockput(ip);
    8000445a:	854e                	mv	a0,s3
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	bd4080e7          	jalr	-1068(ra) # 80004030 <iunlockput>
    ip = next;
    80004464:	89e6                	mv	s3,s9
  while(*path == '/')
    80004466:	0004c783          	lbu	a5,0(s1)
    8000446a:	05279763          	bne	a5,s2,800044b8 <namex+0x156>
    path++;
    8000446e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004470:	0004c783          	lbu	a5,0(s1)
    80004474:	ff278de3          	beq	a5,s2,8000446e <namex+0x10c>
  if(*path == 0)
    80004478:	c79d                	beqz	a5,800044a6 <namex+0x144>
    path++;
    8000447a:	85a6                	mv	a1,s1
  len = path - s;
    8000447c:	8cda                	mv	s9,s6
    8000447e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004480:	01278963          	beq	a5,s2,80004492 <namex+0x130>
    80004484:	dfbd                	beqz	a5,80004402 <namex+0xa0>
    path++;
    80004486:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004488:	0004c783          	lbu	a5,0(s1)
    8000448c:	ff279ce3          	bne	a5,s2,80004484 <namex+0x122>
    80004490:	bf8d                	j	80004402 <namex+0xa0>
    memmove(name, s, len);
    80004492:	2601                	sext.w	a2,a2
    80004494:	8552                	mv	a0,s4
    80004496:	ffffd097          	auipc	ra,0xffffd
    8000449a:	884080e7          	jalr	-1916(ra) # 80000d1a <memmove>
    name[len] = 0;
    8000449e:	9cd2                	add	s9,s9,s4
    800044a0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800044a4:	bf9d                	j	8000441a <namex+0xb8>
  if(nameiparent){
    800044a6:	f20a83e3          	beqz	s5,800043cc <namex+0x6a>
    iput(ip);
    800044aa:	854e                	mv	a0,s3
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	adc080e7          	jalr	-1316(ra) # 80003f88 <iput>
    return 0;
    800044b4:	4981                	li	s3,0
    800044b6:	bf19                	j	800043cc <namex+0x6a>
  if(*path == 0)
    800044b8:	d7fd                	beqz	a5,800044a6 <namex+0x144>
  while(*path != '/' && *path != 0)
    800044ba:	0004c783          	lbu	a5,0(s1)
    800044be:	85a6                	mv	a1,s1
    800044c0:	b7d1                	j	80004484 <namex+0x122>

00000000800044c2 <dirlink>:
{
    800044c2:	7139                	addi	sp,sp,-64
    800044c4:	fc06                	sd	ra,56(sp)
    800044c6:	f822                	sd	s0,48(sp)
    800044c8:	f426                	sd	s1,40(sp)
    800044ca:	f04a                	sd	s2,32(sp)
    800044cc:	ec4e                	sd	s3,24(sp)
    800044ce:	e852                	sd	s4,16(sp)
    800044d0:	0080                	addi	s0,sp,64
    800044d2:	892a                	mv	s2,a0
    800044d4:	8a2e                	mv	s4,a1
    800044d6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800044d8:	4601                	li	a2,0
    800044da:	00000097          	auipc	ra,0x0
    800044de:	dd8080e7          	jalr	-552(ra) # 800042b2 <dirlookup>
    800044e2:	e93d                	bnez	a0,80004558 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044e4:	04c92483          	lw	s1,76(s2)
    800044e8:	c49d                	beqz	s1,80004516 <dirlink+0x54>
    800044ea:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044ec:	4741                	li	a4,16
    800044ee:	86a6                	mv	a3,s1
    800044f0:	fc040613          	addi	a2,s0,-64
    800044f4:	4581                	li	a1,0
    800044f6:	854a                	mv	a0,s2
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	b8a080e7          	jalr	-1142(ra) # 80004082 <readi>
    80004500:	47c1                	li	a5,16
    80004502:	06f51163          	bne	a0,a5,80004564 <dirlink+0xa2>
    if(de.inum == 0)
    80004506:	fc045783          	lhu	a5,-64(s0)
    8000450a:	c791                	beqz	a5,80004516 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000450c:	24c1                	addiw	s1,s1,16
    8000450e:	04c92783          	lw	a5,76(s2)
    80004512:	fcf4ede3          	bltu	s1,a5,800044ec <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004516:	4639                	li	a2,14
    80004518:	85d2                	mv	a1,s4
    8000451a:	fc240513          	addi	a0,s0,-62
    8000451e:	ffffd097          	auipc	ra,0xffffd
    80004522:	8b4080e7          	jalr	-1868(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    80004526:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000452a:	4741                	li	a4,16
    8000452c:	86a6                	mv	a3,s1
    8000452e:	fc040613          	addi	a2,s0,-64
    80004532:	4581                	li	a1,0
    80004534:	854a                	mv	a0,s2
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	c44080e7          	jalr	-956(ra) # 8000417a <writei>
    8000453e:	872a                	mv	a4,a0
    80004540:	47c1                	li	a5,16
  return 0;
    80004542:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004544:	02f71863          	bne	a4,a5,80004574 <dirlink+0xb2>
}
    80004548:	70e2                	ld	ra,56(sp)
    8000454a:	7442                	ld	s0,48(sp)
    8000454c:	74a2                	ld	s1,40(sp)
    8000454e:	7902                	ld	s2,32(sp)
    80004550:	69e2                	ld	s3,24(sp)
    80004552:	6a42                	ld	s4,16(sp)
    80004554:	6121                	addi	sp,sp,64
    80004556:	8082                	ret
    iput(ip);
    80004558:	00000097          	auipc	ra,0x0
    8000455c:	a30080e7          	jalr	-1488(ra) # 80003f88 <iput>
    return -1;
    80004560:	557d                	li	a0,-1
    80004562:	b7dd                	j	80004548 <dirlink+0x86>
      panic("dirlink read");
    80004564:	00004517          	auipc	a0,0x4
    80004568:	1b450513          	addi	a0,a0,436 # 80008718 <syscalls+0x1d0>
    8000456c:	ffffc097          	auipc	ra,0xffffc
    80004570:	fbe080e7          	jalr	-66(ra) # 8000052a <panic>
    panic("dirlink");
    80004574:	00004517          	auipc	a0,0x4
    80004578:	36450513          	addi	a0,a0,868 # 800088d8 <syscalls+0x390>
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	fae080e7          	jalr	-82(ra) # 8000052a <panic>

0000000080004584 <namei>:

struct inode*
namei(char *path)
{
    80004584:	1101                	addi	sp,sp,-32
    80004586:	ec06                	sd	ra,24(sp)
    80004588:	e822                	sd	s0,16(sp)
    8000458a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000458c:	fe040613          	addi	a2,s0,-32
    80004590:	4581                	li	a1,0
    80004592:	00000097          	auipc	ra,0x0
    80004596:	dd0080e7          	jalr	-560(ra) # 80004362 <namex>
}
    8000459a:	60e2                	ld	ra,24(sp)
    8000459c:	6442                	ld	s0,16(sp)
    8000459e:	6105                	addi	sp,sp,32
    800045a0:	8082                	ret

00000000800045a2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800045a2:	1141                	addi	sp,sp,-16
    800045a4:	e406                	sd	ra,8(sp)
    800045a6:	e022                	sd	s0,0(sp)
    800045a8:	0800                	addi	s0,sp,16
    800045aa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045ac:	4585                	li	a1,1
    800045ae:	00000097          	auipc	ra,0x0
    800045b2:	db4080e7          	jalr	-588(ra) # 80004362 <namex>
}
    800045b6:	60a2                	ld	ra,8(sp)
    800045b8:	6402                	ld	s0,0(sp)
    800045ba:	0141                	addi	sp,sp,16
    800045bc:	8082                	ret

00000000800045be <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    800045be:	1101                	addi	sp,sp,-32
    800045c0:	ec22                	sd	s0,24(sp)
    800045c2:	1000                	addi	s0,sp,32
    800045c4:	872a                	mv	a4,a0
    800045c6:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    800045c8:	00004797          	auipc	a5,0x4
    800045cc:	16078793          	addi	a5,a5,352 # 80008728 <syscalls+0x1e0>
    800045d0:	6394                	ld	a3,0(a5)
    800045d2:	fed43023          	sd	a3,-32(s0)
    800045d6:	0087d683          	lhu	a3,8(a5)
    800045da:	fed41423          	sh	a3,-24(s0)
    800045de:	00a7c783          	lbu	a5,10(a5)
    800045e2:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    800045e6:	87ae                	mv	a5,a1
    if(i<0){
    800045e8:	02074b63          	bltz	a4,8000461e <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    800045ec:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    800045ee:	4629                	li	a2,10
        ++p;
    800045f0:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    800045f2:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    800045f6:	feed                	bnez	a3,800045f0 <itoa+0x32>
    *p = '\0';
    800045f8:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    800045fc:	4629                	li	a2,10
    800045fe:	17fd                	addi	a5,a5,-1
    80004600:	02c766bb          	remw	a3,a4,a2
    80004604:	ff040593          	addi	a1,s0,-16
    80004608:	96ae                	add	a3,a3,a1
    8000460a:	ff06c683          	lbu	a3,-16(a3)
    8000460e:	00d78023          	sb	a3,0(a5)
        i = i/10;
    80004612:	02c7473b          	divw	a4,a4,a2
    }while(i);
    80004616:	f765                	bnez	a4,800045fe <itoa+0x40>
    return b;
}
    80004618:	6462                	ld	s0,24(sp)
    8000461a:	6105                	addi	sp,sp,32
    8000461c:	8082                	ret
        *p++ = '-';
    8000461e:	00158793          	addi	a5,a1,1
    80004622:	02d00693          	li	a3,45
    80004626:	00d58023          	sb	a3,0(a1)
        i *= -1;
    8000462a:	40e0073b          	negw	a4,a4
    8000462e:	bf7d                	j	800045ec <itoa+0x2e>

0000000080004630 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    80004630:	711d                	addi	sp,sp,-96
    80004632:	ec86                	sd	ra,88(sp)
    80004634:	e8a2                	sd	s0,80(sp)
    80004636:	e4a6                	sd	s1,72(sp)
    80004638:	e0ca                	sd	s2,64(sp)
    8000463a:	1080                	addi	s0,sp,96
    8000463c:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    8000463e:	4619                	li	a2,6
    80004640:	00004597          	auipc	a1,0x4
    80004644:	0f858593          	addi	a1,a1,248 # 80008738 <syscalls+0x1f0>
    80004648:	fd040513          	addi	a0,s0,-48
    8000464c:	ffffc097          	auipc	ra,0xffffc
    80004650:	6ce080e7          	jalr	1742(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004654:	fd640593          	addi	a1,s0,-42
    80004658:	5888                	lw	a0,48(s1)
    8000465a:	00000097          	auipc	ra,0x0
    8000465e:	f64080e7          	jalr	-156(ra) # 800045be <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    80004662:	1684b503          	ld	a0,360(s1)
    80004666:	16050763          	beqz	a0,800047d4 <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    8000466a:	00001097          	auipc	ra,0x1
    8000466e:	94e080e7          	jalr	-1714(ra) # 80004fb8 <fileclose>

  begin_op();
    80004672:	00000097          	auipc	ra,0x0
    80004676:	47a080e7          	jalr	1146(ra) # 80004aec <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    8000467a:	fb040593          	addi	a1,s0,-80
    8000467e:	fd040513          	addi	a0,s0,-48
    80004682:	00000097          	auipc	ra,0x0
    80004686:	f20080e7          	jalr	-224(ra) # 800045a2 <nameiparent>
    8000468a:	892a                	mv	s2,a0
    8000468c:	cd69                	beqz	a0,80004766 <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    8000468e:	fffff097          	auipc	ra,0xfffff
    80004692:	740080e7          	jalr	1856(ra) # 80003dce <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004696:	00004597          	auipc	a1,0x4
    8000469a:	0aa58593          	addi	a1,a1,170 # 80008740 <syscalls+0x1f8>
    8000469e:	fb040513          	addi	a0,s0,-80
    800046a2:	00000097          	auipc	ra,0x0
    800046a6:	bf6080e7          	jalr	-1034(ra) # 80004298 <namecmp>
    800046aa:	c57d                	beqz	a0,80004798 <removeSwapFile+0x168>
    800046ac:	00004597          	auipc	a1,0x4
    800046b0:	09c58593          	addi	a1,a1,156 # 80008748 <syscalls+0x200>
    800046b4:	fb040513          	addi	a0,s0,-80
    800046b8:	00000097          	auipc	ra,0x0
    800046bc:	be0080e7          	jalr	-1056(ra) # 80004298 <namecmp>
    800046c0:	cd61                	beqz	a0,80004798 <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    800046c2:	fac40613          	addi	a2,s0,-84
    800046c6:	fb040593          	addi	a1,s0,-80
    800046ca:	854a                	mv	a0,s2
    800046cc:	00000097          	auipc	ra,0x0
    800046d0:	be6080e7          	jalr	-1050(ra) # 800042b2 <dirlookup>
    800046d4:	84aa                	mv	s1,a0
    800046d6:	c169                	beqz	a0,80004798 <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	6f6080e7          	jalr	1782(ra) # 80003dce <ilock>

  if(ip->nlink < 1)
    800046e0:	04a49783          	lh	a5,74(s1)
    800046e4:	08f05763          	blez	a5,80004772 <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800046e8:	04449703          	lh	a4,68(s1)
    800046ec:	4785                	li	a5,1
    800046ee:	08f70a63          	beq	a4,a5,80004782 <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800046f2:	4641                	li	a2,16
    800046f4:	4581                	li	a1,0
    800046f6:	fc040513          	addi	a0,s0,-64
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	5c4080e7          	jalr	1476(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004702:	4741                	li	a4,16
    80004704:	fac42683          	lw	a3,-84(s0)
    80004708:	fc040613          	addi	a2,s0,-64
    8000470c:	4581                	li	a1,0
    8000470e:	854a                	mv	a0,s2
    80004710:	00000097          	auipc	ra,0x0
    80004714:	a6a080e7          	jalr	-1430(ra) # 8000417a <writei>
    80004718:	47c1                	li	a5,16
    8000471a:	08f51a63          	bne	a0,a5,800047ae <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    8000471e:	04449703          	lh	a4,68(s1)
    80004722:	4785                	li	a5,1
    80004724:	08f70d63          	beq	a4,a5,800047be <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80004728:	854a                	mv	a0,s2
    8000472a:	00000097          	auipc	ra,0x0
    8000472e:	906080e7          	jalr	-1786(ra) # 80004030 <iunlockput>

  ip->nlink--;
    80004732:	04a4d783          	lhu	a5,74(s1)
    80004736:	37fd                	addiw	a5,a5,-1
    80004738:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000473c:	8526                	mv	a0,s1
    8000473e:	fffff097          	auipc	ra,0xfffff
    80004742:	5c6080e7          	jalr	1478(ra) # 80003d04 <iupdate>
  iunlockput(ip);
    80004746:	8526                	mv	a0,s1
    80004748:	00000097          	auipc	ra,0x0
    8000474c:	8e8080e7          	jalr	-1816(ra) # 80004030 <iunlockput>

  end_op();
    80004750:	00000097          	auipc	ra,0x0
    80004754:	41c080e7          	jalr	1052(ra) # 80004b6c <end_op>

  return 0;
    80004758:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    8000475a:	60e6                	ld	ra,88(sp)
    8000475c:	6446                	ld	s0,80(sp)
    8000475e:	64a6                	ld	s1,72(sp)
    80004760:	6906                	ld	s2,64(sp)
    80004762:	6125                	addi	sp,sp,96
    80004764:	8082                	ret
    end_op();
    80004766:	00000097          	auipc	ra,0x0
    8000476a:	406080e7          	jalr	1030(ra) # 80004b6c <end_op>
    return -1;
    8000476e:	557d                	li	a0,-1
    80004770:	b7ed                	j	8000475a <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    80004772:	00004517          	auipc	a0,0x4
    80004776:	fde50513          	addi	a0,a0,-34 # 80008750 <syscalls+0x208>
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	db0080e7          	jalr	-592(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004782:	8526                	mv	a0,s1
    80004784:	00001097          	auipc	ra,0x1
    80004788:	7de080e7          	jalr	2014(ra) # 80005f62 <isdirempty>
    8000478c:	f13d                	bnez	a0,800046f2 <removeSwapFile+0xc2>
    iunlockput(ip);
    8000478e:	8526                	mv	a0,s1
    80004790:	00000097          	auipc	ra,0x0
    80004794:	8a0080e7          	jalr	-1888(ra) # 80004030 <iunlockput>
    iunlockput(dp);
    80004798:	854a                	mv	a0,s2
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	896080e7          	jalr	-1898(ra) # 80004030 <iunlockput>
    end_op();
    800047a2:	00000097          	auipc	ra,0x0
    800047a6:	3ca080e7          	jalr	970(ra) # 80004b6c <end_op>
    return -1;
    800047aa:	557d                	li	a0,-1
    800047ac:	b77d                	j	8000475a <removeSwapFile+0x12a>
    panic("unlink: writei");
    800047ae:	00004517          	auipc	a0,0x4
    800047b2:	fba50513          	addi	a0,a0,-70 # 80008768 <syscalls+0x220>
    800047b6:	ffffc097          	auipc	ra,0xffffc
    800047ba:	d74080e7          	jalr	-652(ra) # 8000052a <panic>
    dp->nlink--;
    800047be:	04a95783          	lhu	a5,74(s2)
    800047c2:	37fd                	addiw	a5,a5,-1
    800047c4:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800047c8:	854a                	mv	a0,s2
    800047ca:	fffff097          	auipc	ra,0xfffff
    800047ce:	53a080e7          	jalr	1338(ra) # 80003d04 <iupdate>
    800047d2:	bf99                	j	80004728 <removeSwapFile+0xf8>
    return -1;
    800047d4:	557d                	li	a0,-1
    800047d6:	b751                	j	8000475a <removeSwapFile+0x12a>

00000000800047d8 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    800047d8:	7179                	addi	sp,sp,-48
    800047da:	f406                	sd	ra,40(sp)
    800047dc:	f022                	sd	s0,32(sp)
    800047de:	ec26                	sd	s1,24(sp)
    800047e0:	e84a                	sd	s2,16(sp)
    800047e2:	1800                	addi	s0,sp,48
    800047e4:	84aa                	mv	s1,a0
  printf("createSwapFile\n");
    800047e6:	00004517          	auipc	a0,0x4
    800047ea:	f9250513          	addi	a0,a0,-110 # 80008778 <syscalls+0x230>
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	d86080e7          	jalr	-634(ra) # 80000574 <printf>
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    800047f6:	4619                	li	a2,6
    800047f8:	00004597          	auipc	a1,0x4
    800047fc:	f4058593          	addi	a1,a1,-192 # 80008738 <syscalls+0x1f0>
    80004800:	fd040513          	addi	a0,s0,-48
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	516080e7          	jalr	1302(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    8000480c:	fd640593          	addi	a1,s0,-42
    80004810:	5888                	lw	a0,48(s1)
    80004812:	00000097          	auipc	ra,0x0
    80004816:	dac080e7          	jalr	-596(ra) # 800045be <itoa>

  begin_op();
    8000481a:	00000097          	auipc	ra,0x0
    8000481e:	2d2080e7          	jalr	722(ra) # 80004aec <begin_op>
  
  struct inode * in = create(path, T_FILE, 0, 0);
    80004822:	4681                	li	a3,0
    80004824:	4601                	li	a2,0
    80004826:	4589                	li	a1,2
    80004828:	fd040513          	addi	a0,s0,-48
    8000482c:	00002097          	auipc	ra,0x2
    80004830:	92a080e7          	jalr	-1750(ra) # 80006156 <create>
    80004834:	892a                	mv	s2,a0
  printf("created file\n");
    80004836:	00004517          	auipc	a0,0x4
    8000483a:	f5250513          	addi	a0,a0,-174 # 80008788 <syscalls+0x240>
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	d36080e7          	jalr	-714(ra) # 80000574 <printf>
  iunlock(in);
    80004846:	854a                	mv	a0,s2
    80004848:	fffff097          	auipc	ra,0xfffff
    8000484c:	648080e7          	jalr	1608(ra) # 80003e90 <iunlock>
  p->swapFile = filealloc();
    80004850:	00000097          	auipc	ra,0x0
    80004854:	6ac080e7          	jalr	1708(ra) # 80004efc <filealloc>
    80004858:	16a4b423          	sd	a0,360(s1)
  printf("allocated file\n");
    8000485c:	00004517          	auipc	a0,0x4
    80004860:	f3c50513          	addi	a0,a0,-196 # 80008798 <syscalls+0x250>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	d10080e7          	jalr	-752(ra) # 80000574 <printf>
  if (p->swapFile == 0)
    8000486c:	1684b783          	ld	a5,360(s1)
    80004870:	cf9d                	beqz	a5,800048ae <createSwapFile+0xd6>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004872:	0127bc23          	sd	s2,24(a5)
  p->swapFile->type = FD_INODE;
    80004876:	1684b703          	ld	a4,360(s1)
    8000487a:	4789                	li	a5,2
    8000487c:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    8000487e:	1684b703          	ld	a4,360(s1)
    80004882:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004886:	1684b703          	ld	a4,360(s1)
    8000488a:	4685                	li	a3,1
    8000488c:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004890:	1684b703          	ld	a4,360(s1)
    80004894:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004898:	00000097          	auipc	ra,0x0
    8000489c:	2d4080e7          	jalr	724(ra) # 80004b6c <end_op>

    return 0;
}
    800048a0:	4501                	li	a0,0
    800048a2:	70a2                	ld	ra,40(sp)
    800048a4:	7402                	ld	s0,32(sp)
    800048a6:	64e2                	ld	s1,24(sp)
    800048a8:	6942                	ld	s2,16(sp)
    800048aa:	6145                	addi	sp,sp,48
    800048ac:	8082                	ret
    panic("no slot for files on /store");
    800048ae:	00004517          	auipc	a0,0x4
    800048b2:	efa50513          	addi	a0,a0,-262 # 800087a8 <syscalls+0x260>
    800048b6:	ffffc097          	auipc	ra,0xffffc
    800048ba:	c74080e7          	jalr	-908(ra) # 8000052a <panic>

00000000800048be <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    800048be:	1141                	addi	sp,sp,-16
    800048c0:	e406                	sd	ra,8(sp)
    800048c2:	e022                	sd	s0,0(sp)
    800048c4:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    800048c6:	16853783          	ld	a5,360(a0)
    800048ca:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    800048cc:	8636                	mv	a2,a3
    800048ce:	16853503          	ld	a0,360(a0)
    800048d2:	00001097          	auipc	ra,0x1
    800048d6:	ad8080e7          	jalr	-1320(ra) # 800053aa <kfilewrite>
}
    800048da:	60a2                	ld	ra,8(sp)
    800048dc:	6402                	ld	s0,0(sp)
    800048de:	0141                	addi	sp,sp,16
    800048e0:	8082                	ret

00000000800048e2 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    800048e2:	1141                	addi	sp,sp,-16
    800048e4:	e406                	sd	ra,8(sp)
    800048e6:	e022                	sd	s0,0(sp)
    800048e8:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    800048ea:	16853783          	ld	a5,360(a0)
    800048ee:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    800048f0:	8636                	mv	a2,a3
    800048f2:	16853503          	ld	a0,360(a0)
    800048f6:	00001097          	auipc	ra,0x1
    800048fa:	9f2080e7          	jalr	-1550(ra) # 800052e8 <kfileread>
    800048fe:	60a2                	ld	ra,8(sp)
    80004900:	6402                	ld	s0,0(sp)
    80004902:	0141                	addi	sp,sp,16
    80004904:	8082                	ret

0000000080004906 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004906:	1101                	addi	sp,sp,-32
    80004908:	ec06                	sd	ra,24(sp)
    8000490a:	e822                	sd	s0,16(sp)
    8000490c:	e426                	sd	s1,8(sp)
    8000490e:	e04a                	sd	s2,0(sp)
    80004910:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004912:	0002d917          	auipc	s2,0x2d
    80004916:	b5e90913          	addi	s2,s2,-1186 # 80031470 <log>
    8000491a:	01892583          	lw	a1,24(s2)
    8000491e:	02892503          	lw	a0,40(s2)
    80004922:	fffff097          	auipc	ra,0xfffff
    80004926:	ca8080e7          	jalr	-856(ra) # 800035ca <bread>
    8000492a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000492c:	02c92683          	lw	a3,44(s2)
    80004930:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004932:	02d05863          	blez	a3,80004962 <write_head+0x5c>
    80004936:	0002d797          	auipc	a5,0x2d
    8000493a:	b6a78793          	addi	a5,a5,-1174 # 800314a0 <log+0x30>
    8000493e:	05c50713          	addi	a4,a0,92
    80004942:	36fd                	addiw	a3,a3,-1
    80004944:	02069613          	slli	a2,a3,0x20
    80004948:	01e65693          	srli	a3,a2,0x1e
    8000494c:	0002d617          	auipc	a2,0x2d
    80004950:	b5860613          	addi	a2,a2,-1192 # 800314a4 <log+0x34>
    80004954:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004956:	4390                	lw	a2,0(a5)
    80004958:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000495a:	0791                	addi	a5,a5,4
    8000495c:	0711                	addi	a4,a4,4
    8000495e:	fed79ce3          	bne	a5,a3,80004956 <write_head+0x50>
  }
  bwrite(buf);
    80004962:	8526                	mv	a0,s1
    80004964:	fffff097          	auipc	ra,0xfffff
    80004968:	d58080e7          	jalr	-680(ra) # 800036bc <bwrite>
  brelse(buf);
    8000496c:	8526                	mv	a0,s1
    8000496e:	fffff097          	auipc	ra,0xfffff
    80004972:	d8c080e7          	jalr	-628(ra) # 800036fa <brelse>
}
    80004976:	60e2                	ld	ra,24(sp)
    80004978:	6442                	ld	s0,16(sp)
    8000497a:	64a2                	ld	s1,8(sp)
    8000497c:	6902                	ld	s2,0(sp)
    8000497e:	6105                	addi	sp,sp,32
    80004980:	8082                	ret

0000000080004982 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004982:	0002d797          	auipc	a5,0x2d
    80004986:	b1a7a783          	lw	a5,-1254(a5) # 8003149c <log+0x2c>
    8000498a:	0af05d63          	blez	a5,80004a44 <install_trans+0xc2>
{
    8000498e:	7139                	addi	sp,sp,-64
    80004990:	fc06                	sd	ra,56(sp)
    80004992:	f822                	sd	s0,48(sp)
    80004994:	f426                	sd	s1,40(sp)
    80004996:	f04a                	sd	s2,32(sp)
    80004998:	ec4e                	sd	s3,24(sp)
    8000499a:	e852                	sd	s4,16(sp)
    8000499c:	e456                	sd	s5,8(sp)
    8000499e:	e05a                	sd	s6,0(sp)
    800049a0:	0080                	addi	s0,sp,64
    800049a2:	8b2a                	mv	s6,a0
    800049a4:	0002da97          	auipc	s5,0x2d
    800049a8:	afca8a93          	addi	s5,s5,-1284 # 800314a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049ac:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800049ae:	0002d997          	auipc	s3,0x2d
    800049b2:	ac298993          	addi	s3,s3,-1342 # 80031470 <log>
    800049b6:	a00d                	j	800049d8 <install_trans+0x56>
    brelse(lbuf);
    800049b8:	854a                	mv	a0,s2
    800049ba:	fffff097          	auipc	ra,0xfffff
    800049be:	d40080e7          	jalr	-704(ra) # 800036fa <brelse>
    brelse(dbuf);
    800049c2:	8526                	mv	a0,s1
    800049c4:	fffff097          	auipc	ra,0xfffff
    800049c8:	d36080e7          	jalr	-714(ra) # 800036fa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049cc:	2a05                	addiw	s4,s4,1
    800049ce:	0a91                	addi	s5,s5,4
    800049d0:	02c9a783          	lw	a5,44(s3)
    800049d4:	04fa5e63          	bge	s4,a5,80004a30 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800049d8:	0189a583          	lw	a1,24(s3)
    800049dc:	014585bb          	addw	a1,a1,s4
    800049e0:	2585                	addiw	a1,a1,1
    800049e2:	0289a503          	lw	a0,40(s3)
    800049e6:	fffff097          	auipc	ra,0xfffff
    800049ea:	be4080e7          	jalr	-1052(ra) # 800035ca <bread>
    800049ee:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800049f0:	000aa583          	lw	a1,0(s5)
    800049f4:	0289a503          	lw	a0,40(s3)
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	bd2080e7          	jalr	-1070(ra) # 800035ca <bread>
    80004a00:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004a02:	40000613          	li	a2,1024
    80004a06:	05890593          	addi	a1,s2,88
    80004a0a:	05850513          	addi	a0,a0,88
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	30c080e7          	jalr	780(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004a16:	8526                	mv	a0,s1
    80004a18:	fffff097          	auipc	ra,0xfffff
    80004a1c:	ca4080e7          	jalr	-860(ra) # 800036bc <bwrite>
    if(recovering == 0)
    80004a20:	f80b1ce3          	bnez	s6,800049b8 <install_trans+0x36>
      bunpin(dbuf);
    80004a24:	8526                	mv	a0,s1
    80004a26:	fffff097          	auipc	ra,0xfffff
    80004a2a:	dae080e7          	jalr	-594(ra) # 800037d4 <bunpin>
    80004a2e:	b769                	j	800049b8 <install_trans+0x36>
}
    80004a30:	70e2                	ld	ra,56(sp)
    80004a32:	7442                	ld	s0,48(sp)
    80004a34:	74a2                	ld	s1,40(sp)
    80004a36:	7902                	ld	s2,32(sp)
    80004a38:	69e2                	ld	s3,24(sp)
    80004a3a:	6a42                	ld	s4,16(sp)
    80004a3c:	6aa2                	ld	s5,8(sp)
    80004a3e:	6b02                	ld	s6,0(sp)
    80004a40:	6121                	addi	sp,sp,64
    80004a42:	8082                	ret
    80004a44:	8082                	ret

0000000080004a46 <initlog>:
{
    80004a46:	7179                	addi	sp,sp,-48
    80004a48:	f406                	sd	ra,40(sp)
    80004a4a:	f022                	sd	s0,32(sp)
    80004a4c:	ec26                	sd	s1,24(sp)
    80004a4e:	e84a                	sd	s2,16(sp)
    80004a50:	e44e                	sd	s3,8(sp)
    80004a52:	1800                	addi	s0,sp,48
    80004a54:	892a                	mv	s2,a0
    80004a56:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004a58:	0002d497          	auipc	s1,0x2d
    80004a5c:	a1848493          	addi	s1,s1,-1512 # 80031470 <log>
    80004a60:	00004597          	auipc	a1,0x4
    80004a64:	d6858593          	addi	a1,a1,-664 # 800087c8 <syscalls+0x280>
    80004a68:	8526                	mv	a0,s1
    80004a6a:	ffffc097          	auipc	ra,0xffffc
    80004a6e:	0c8080e7          	jalr	200(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004a72:	0149a583          	lw	a1,20(s3)
    80004a76:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004a78:	0109a783          	lw	a5,16(s3)
    80004a7c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004a7e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004a82:	854a                	mv	a0,s2
    80004a84:	fffff097          	auipc	ra,0xfffff
    80004a88:	b46080e7          	jalr	-1210(ra) # 800035ca <bread>
  log.lh.n = lh->n;
    80004a8c:	4d34                	lw	a3,88(a0)
    80004a8e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004a90:	02d05663          	blez	a3,80004abc <initlog+0x76>
    80004a94:	05c50793          	addi	a5,a0,92
    80004a98:	0002d717          	auipc	a4,0x2d
    80004a9c:	a0870713          	addi	a4,a4,-1528 # 800314a0 <log+0x30>
    80004aa0:	36fd                	addiw	a3,a3,-1
    80004aa2:	02069613          	slli	a2,a3,0x20
    80004aa6:	01e65693          	srli	a3,a2,0x1e
    80004aaa:	06050613          	addi	a2,a0,96
    80004aae:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004ab0:	4390                	lw	a2,0(a5)
    80004ab2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004ab4:	0791                	addi	a5,a5,4
    80004ab6:	0711                	addi	a4,a4,4
    80004ab8:	fed79ce3          	bne	a5,a3,80004ab0 <initlog+0x6a>
  brelse(buf);
    80004abc:	fffff097          	auipc	ra,0xfffff
    80004ac0:	c3e080e7          	jalr	-962(ra) # 800036fa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004ac4:	4505                	li	a0,1
    80004ac6:	00000097          	auipc	ra,0x0
    80004aca:	ebc080e7          	jalr	-324(ra) # 80004982 <install_trans>
  log.lh.n = 0;
    80004ace:	0002d797          	auipc	a5,0x2d
    80004ad2:	9c07a723          	sw	zero,-1586(a5) # 8003149c <log+0x2c>
  write_head(); // clear the log
    80004ad6:	00000097          	auipc	ra,0x0
    80004ada:	e30080e7          	jalr	-464(ra) # 80004906 <write_head>
}
    80004ade:	70a2                	ld	ra,40(sp)
    80004ae0:	7402                	ld	s0,32(sp)
    80004ae2:	64e2                	ld	s1,24(sp)
    80004ae4:	6942                	ld	s2,16(sp)
    80004ae6:	69a2                	ld	s3,8(sp)
    80004ae8:	6145                	addi	sp,sp,48
    80004aea:	8082                	ret

0000000080004aec <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004aec:	1101                	addi	sp,sp,-32
    80004aee:	ec06                	sd	ra,24(sp)
    80004af0:	e822                	sd	s0,16(sp)
    80004af2:	e426                	sd	s1,8(sp)
    80004af4:	e04a                	sd	s2,0(sp)
    80004af6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004af8:	0002d517          	auipc	a0,0x2d
    80004afc:	97850513          	addi	a0,a0,-1672 # 80031470 <log>
    80004b00:	ffffc097          	auipc	ra,0xffffc
    80004b04:	0c2080e7          	jalr	194(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004b08:	0002d497          	auipc	s1,0x2d
    80004b0c:	96848493          	addi	s1,s1,-1688 # 80031470 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b10:	4979                	li	s2,30
    80004b12:	a039                	j	80004b20 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004b14:	85a6                	mv	a1,s1
    80004b16:	8526                	mv	a0,s1
    80004b18:	ffffe097          	auipc	ra,0xffffe
    80004b1c:	c5e080e7          	jalr	-930(ra) # 80002776 <sleep>
    if(log.committing){
    80004b20:	50dc                	lw	a5,36(s1)
    80004b22:	fbed                	bnez	a5,80004b14 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b24:	509c                	lw	a5,32(s1)
    80004b26:	0017871b          	addiw	a4,a5,1
    80004b2a:	0007069b          	sext.w	a3,a4
    80004b2e:	0027179b          	slliw	a5,a4,0x2
    80004b32:	9fb9                	addw	a5,a5,a4
    80004b34:	0017979b          	slliw	a5,a5,0x1
    80004b38:	54d8                	lw	a4,44(s1)
    80004b3a:	9fb9                	addw	a5,a5,a4
    80004b3c:	00f95963          	bge	s2,a5,80004b4e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004b40:	85a6                	mv	a1,s1
    80004b42:	8526                	mv	a0,s1
    80004b44:	ffffe097          	auipc	ra,0xffffe
    80004b48:	c32080e7          	jalr	-974(ra) # 80002776 <sleep>
    80004b4c:	bfd1                	j	80004b20 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004b4e:	0002d517          	auipc	a0,0x2d
    80004b52:	92250513          	addi	a0,a0,-1758 # 80031470 <log>
    80004b56:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004b58:	ffffc097          	auipc	ra,0xffffc
    80004b5c:	11e080e7          	jalr	286(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004b60:	60e2                	ld	ra,24(sp)
    80004b62:	6442                	ld	s0,16(sp)
    80004b64:	64a2                	ld	s1,8(sp)
    80004b66:	6902                	ld	s2,0(sp)
    80004b68:	6105                	addi	sp,sp,32
    80004b6a:	8082                	ret

0000000080004b6c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004b6c:	7139                	addi	sp,sp,-64
    80004b6e:	fc06                	sd	ra,56(sp)
    80004b70:	f822                	sd	s0,48(sp)
    80004b72:	f426                	sd	s1,40(sp)
    80004b74:	f04a                	sd	s2,32(sp)
    80004b76:	ec4e                	sd	s3,24(sp)
    80004b78:	e852                	sd	s4,16(sp)
    80004b7a:	e456                	sd	s5,8(sp)
    80004b7c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004b7e:	0002d497          	auipc	s1,0x2d
    80004b82:	8f248493          	addi	s1,s1,-1806 # 80031470 <log>
    80004b86:	8526                	mv	a0,s1
    80004b88:	ffffc097          	auipc	ra,0xffffc
    80004b8c:	03a080e7          	jalr	58(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004b90:	509c                	lw	a5,32(s1)
    80004b92:	37fd                	addiw	a5,a5,-1
    80004b94:	0007891b          	sext.w	s2,a5
    80004b98:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004b9a:	50dc                	lw	a5,36(s1)
    80004b9c:	e7b9                	bnez	a5,80004bea <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004b9e:	04091e63          	bnez	s2,80004bfa <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004ba2:	0002d497          	auipc	s1,0x2d
    80004ba6:	8ce48493          	addi	s1,s1,-1842 # 80031470 <log>
    80004baa:	4785                	li	a5,1
    80004bac:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004bae:	8526                	mv	a0,s1
    80004bb0:	ffffc097          	auipc	ra,0xffffc
    80004bb4:	0c6080e7          	jalr	198(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004bb8:	54dc                	lw	a5,44(s1)
    80004bba:	06f04763          	bgtz	a5,80004c28 <end_op+0xbc>
    acquire(&log.lock);
    80004bbe:	0002d497          	auipc	s1,0x2d
    80004bc2:	8b248493          	addi	s1,s1,-1870 # 80031470 <log>
    80004bc6:	8526                	mv	a0,s1
    80004bc8:	ffffc097          	auipc	ra,0xffffc
    80004bcc:	ffa080e7          	jalr	-6(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004bd0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	ffffe097          	auipc	ra,0xffffe
    80004bda:	d2c080e7          	jalr	-724(ra) # 80002902 <wakeup>
    release(&log.lock);
    80004bde:	8526                	mv	a0,s1
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	096080e7          	jalr	150(ra) # 80000c76 <release>
}
    80004be8:	a03d                	j	80004c16 <end_op+0xaa>
    panic("log.committing");
    80004bea:	00004517          	auipc	a0,0x4
    80004bee:	be650513          	addi	a0,a0,-1050 # 800087d0 <syscalls+0x288>
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	938080e7          	jalr	-1736(ra) # 8000052a <panic>
    wakeup(&log);
    80004bfa:	0002d497          	auipc	s1,0x2d
    80004bfe:	87648493          	addi	s1,s1,-1930 # 80031470 <log>
    80004c02:	8526                	mv	a0,s1
    80004c04:	ffffe097          	auipc	ra,0xffffe
    80004c08:	cfe080e7          	jalr	-770(ra) # 80002902 <wakeup>
  release(&log.lock);
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	ffffc097          	auipc	ra,0xffffc
    80004c12:	068080e7          	jalr	104(ra) # 80000c76 <release>
}
    80004c16:	70e2                	ld	ra,56(sp)
    80004c18:	7442                	ld	s0,48(sp)
    80004c1a:	74a2                	ld	s1,40(sp)
    80004c1c:	7902                	ld	s2,32(sp)
    80004c1e:	69e2                	ld	s3,24(sp)
    80004c20:	6a42                	ld	s4,16(sp)
    80004c22:	6aa2                	ld	s5,8(sp)
    80004c24:	6121                	addi	sp,sp,64
    80004c26:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c28:	0002da97          	auipc	s5,0x2d
    80004c2c:	878a8a93          	addi	s5,s5,-1928 # 800314a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004c30:	0002da17          	auipc	s4,0x2d
    80004c34:	840a0a13          	addi	s4,s4,-1984 # 80031470 <log>
    80004c38:	018a2583          	lw	a1,24(s4)
    80004c3c:	012585bb          	addw	a1,a1,s2
    80004c40:	2585                	addiw	a1,a1,1
    80004c42:	028a2503          	lw	a0,40(s4)
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	984080e7          	jalr	-1660(ra) # 800035ca <bread>
    80004c4e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004c50:	000aa583          	lw	a1,0(s5)
    80004c54:	028a2503          	lw	a0,40(s4)
    80004c58:	fffff097          	auipc	ra,0xfffff
    80004c5c:	972080e7          	jalr	-1678(ra) # 800035ca <bread>
    80004c60:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004c62:	40000613          	li	a2,1024
    80004c66:	05850593          	addi	a1,a0,88
    80004c6a:	05848513          	addi	a0,s1,88
    80004c6e:	ffffc097          	auipc	ra,0xffffc
    80004c72:	0ac080e7          	jalr	172(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004c76:	8526                	mv	a0,s1
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	a44080e7          	jalr	-1468(ra) # 800036bc <bwrite>
    brelse(from);
    80004c80:	854e                	mv	a0,s3
    80004c82:	fffff097          	auipc	ra,0xfffff
    80004c86:	a78080e7          	jalr	-1416(ra) # 800036fa <brelse>
    brelse(to);
    80004c8a:	8526                	mv	a0,s1
    80004c8c:	fffff097          	auipc	ra,0xfffff
    80004c90:	a6e080e7          	jalr	-1426(ra) # 800036fa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c94:	2905                	addiw	s2,s2,1
    80004c96:	0a91                	addi	s5,s5,4
    80004c98:	02ca2783          	lw	a5,44(s4)
    80004c9c:	f8f94ee3          	blt	s2,a5,80004c38 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004ca0:	00000097          	auipc	ra,0x0
    80004ca4:	c66080e7          	jalr	-922(ra) # 80004906 <write_head>
    install_trans(0); // Now install writes to home locations
    80004ca8:	4501                	li	a0,0
    80004caa:	00000097          	auipc	ra,0x0
    80004cae:	cd8080e7          	jalr	-808(ra) # 80004982 <install_trans>
    log.lh.n = 0;
    80004cb2:	0002c797          	auipc	a5,0x2c
    80004cb6:	7e07a523          	sw	zero,2026(a5) # 8003149c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004cba:	00000097          	auipc	ra,0x0
    80004cbe:	c4c080e7          	jalr	-948(ra) # 80004906 <write_head>
    80004cc2:	bdf5                	j	80004bbe <end_op+0x52>

0000000080004cc4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004cc4:	1101                	addi	sp,sp,-32
    80004cc6:	ec06                	sd	ra,24(sp)
    80004cc8:	e822                	sd	s0,16(sp)
    80004cca:	e426                	sd	s1,8(sp)
    80004ccc:	e04a                	sd	s2,0(sp)
    80004cce:	1000                	addi	s0,sp,32
    80004cd0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004cd2:	0002c917          	auipc	s2,0x2c
    80004cd6:	79e90913          	addi	s2,s2,1950 # 80031470 <log>
    80004cda:	854a                	mv	a0,s2
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	ee6080e7          	jalr	-282(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004ce4:	02c92603          	lw	a2,44(s2)
    80004ce8:	47f5                	li	a5,29
    80004cea:	06c7c563          	blt	a5,a2,80004d54 <log_write+0x90>
    80004cee:	0002c797          	auipc	a5,0x2c
    80004cf2:	79e7a783          	lw	a5,1950(a5) # 8003148c <log+0x1c>
    80004cf6:	37fd                	addiw	a5,a5,-1
    80004cf8:	04f65e63          	bge	a2,a5,80004d54 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004cfc:	0002c797          	auipc	a5,0x2c
    80004d00:	7947a783          	lw	a5,1940(a5) # 80031490 <log+0x20>
    80004d04:	06f05063          	blez	a5,80004d64 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004d08:	4781                	li	a5,0
    80004d0a:	06c05563          	blez	a2,80004d74 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004d0e:	44cc                	lw	a1,12(s1)
    80004d10:	0002c717          	auipc	a4,0x2c
    80004d14:	79070713          	addi	a4,a4,1936 # 800314a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004d18:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004d1a:	4314                	lw	a3,0(a4)
    80004d1c:	04b68c63          	beq	a3,a1,80004d74 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004d20:	2785                	addiw	a5,a5,1
    80004d22:	0711                	addi	a4,a4,4
    80004d24:	fef61be3          	bne	a2,a5,80004d1a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004d28:	0621                	addi	a2,a2,8
    80004d2a:	060a                	slli	a2,a2,0x2
    80004d2c:	0002c797          	auipc	a5,0x2c
    80004d30:	74478793          	addi	a5,a5,1860 # 80031470 <log>
    80004d34:	963e                	add	a2,a2,a5
    80004d36:	44dc                	lw	a5,12(s1)
    80004d38:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	a5c080e7          	jalr	-1444(ra) # 80003798 <bpin>
    log.lh.n++;
    80004d44:	0002c717          	auipc	a4,0x2c
    80004d48:	72c70713          	addi	a4,a4,1836 # 80031470 <log>
    80004d4c:	575c                	lw	a5,44(a4)
    80004d4e:	2785                	addiw	a5,a5,1
    80004d50:	d75c                	sw	a5,44(a4)
    80004d52:	a835                	j	80004d8e <log_write+0xca>
    panic("too big a transaction");
    80004d54:	00004517          	auipc	a0,0x4
    80004d58:	a8c50513          	addi	a0,a0,-1396 # 800087e0 <syscalls+0x298>
    80004d5c:	ffffb097          	auipc	ra,0xffffb
    80004d60:	7ce080e7          	jalr	1998(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004d64:	00004517          	auipc	a0,0x4
    80004d68:	a9450513          	addi	a0,a0,-1388 # 800087f8 <syscalls+0x2b0>
    80004d6c:	ffffb097          	auipc	ra,0xffffb
    80004d70:	7be080e7          	jalr	1982(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004d74:	00878713          	addi	a4,a5,8
    80004d78:	00271693          	slli	a3,a4,0x2
    80004d7c:	0002c717          	auipc	a4,0x2c
    80004d80:	6f470713          	addi	a4,a4,1780 # 80031470 <log>
    80004d84:	9736                	add	a4,a4,a3
    80004d86:	44d4                	lw	a3,12(s1)
    80004d88:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004d8a:	faf608e3          	beq	a2,a5,80004d3a <log_write+0x76>
  }
  release(&log.lock);
    80004d8e:	0002c517          	auipc	a0,0x2c
    80004d92:	6e250513          	addi	a0,a0,1762 # 80031470 <log>
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	ee0080e7          	jalr	-288(ra) # 80000c76 <release>
}
    80004d9e:	60e2                	ld	ra,24(sp)
    80004da0:	6442                	ld	s0,16(sp)
    80004da2:	64a2                	ld	s1,8(sp)
    80004da4:	6902                	ld	s2,0(sp)
    80004da6:	6105                	addi	sp,sp,32
    80004da8:	8082                	ret

0000000080004daa <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004daa:	1101                	addi	sp,sp,-32
    80004dac:	ec06                	sd	ra,24(sp)
    80004dae:	e822                	sd	s0,16(sp)
    80004db0:	e426                	sd	s1,8(sp)
    80004db2:	e04a                	sd	s2,0(sp)
    80004db4:	1000                	addi	s0,sp,32
    80004db6:	84aa                	mv	s1,a0
    80004db8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004dba:	00004597          	auipc	a1,0x4
    80004dbe:	a5e58593          	addi	a1,a1,-1442 # 80008818 <syscalls+0x2d0>
    80004dc2:	0521                	addi	a0,a0,8
    80004dc4:	ffffc097          	auipc	ra,0xffffc
    80004dc8:	d6e080e7          	jalr	-658(ra) # 80000b32 <initlock>
  lk->name = name;
    80004dcc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004dd0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004dd4:	0204a423          	sw	zero,40(s1)
}
    80004dd8:	60e2                	ld	ra,24(sp)
    80004dda:	6442                	ld	s0,16(sp)
    80004ddc:	64a2                	ld	s1,8(sp)
    80004dde:	6902                	ld	s2,0(sp)
    80004de0:	6105                	addi	sp,sp,32
    80004de2:	8082                	ret

0000000080004de4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004de4:	1101                	addi	sp,sp,-32
    80004de6:	ec06                	sd	ra,24(sp)
    80004de8:	e822                	sd	s0,16(sp)
    80004dea:	e426                	sd	s1,8(sp)
    80004dec:	e04a                	sd	s2,0(sp)
    80004dee:	1000                	addi	s0,sp,32
    80004df0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004df2:	00850913          	addi	s2,a0,8
    80004df6:	854a                	mv	a0,s2
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	dca080e7          	jalr	-566(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004e00:	409c                	lw	a5,0(s1)
    80004e02:	cb89                	beqz	a5,80004e14 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004e04:	85ca                	mv	a1,s2
    80004e06:	8526                	mv	a0,s1
    80004e08:	ffffe097          	auipc	ra,0xffffe
    80004e0c:	96e080e7          	jalr	-1682(ra) # 80002776 <sleep>
  while (lk->locked) {
    80004e10:	409c                	lw	a5,0(s1)
    80004e12:	fbed                	bnez	a5,80004e04 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004e14:	4785                	li	a5,1
    80004e16:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004e18:	ffffd097          	auipc	ra,0xffffd
    80004e1c:	1a8080e7          	jalr	424(ra) # 80001fc0 <myproc>
    80004e20:	591c                	lw	a5,48(a0)
    80004e22:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004e24:	854a                	mv	a0,s2
    80004e26:	ffffc097          	auipc	ra,0xffffc
    80004e2a:	e50080e7          	jalr	-432(ra) # 80000c76 <release>
}
    80004e2e:	60e2                	ld	ra,24(sp)
    80004e30:	6442                	ld	s0,16(sp)
    80004e32:	64a2                	ld	s1,8(sp)
    80004e34:	6902                	ld	s2,0(sp)
    80004e36:	6105                	addi	sp,sp,32
    80004e38:	8082                	ret

0000000080004e3a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004e3a:	1101                	addi	sp,sp,-32
    80004e3c:	ec06                	sd	ra,24(sp)
    80004e3e:	e822                	sd	s0,16(sp)
    80004e40:	e426                	sd	s1,8(sp)
    80004e42:	e04a                	sd	s2,0(sp)
    80004e44:	1000                	addi	s0,sp,32
    80004e46:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e48:	00850913          	addi	s2,a0,8
    80004e4c:	854a                	mv	a0,s2
    80004e4e:	ffffc097          	auipc	ra,0xffffc
    80004e52:	d74080e7          	jalr	-652(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004e56:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e5a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	ffffe097          	auipc	ra,0xffffe
    80004e64:	aa2080e7          	jalr	-1374(ra) # 80002902 <wakeup>
  release(&lk->lk);
    80004e68:	854a                	mv	a0,s2
    80004e6a:	ffffc097          	auipc	ra,0xffffc
    80004e6e:	e0c080e7          	jalr	-500(ra) # 80000c76 <release>
}
    80004e72:	60e2                	ld	ra,24(sp)
    80004e74:	6442                	ld	s0,16(sp)
    80004e76:	64a2                	ld	s1,8(sp)
    80004e78:	6902                	ld	s2,0(sp)
    80004e7a:	6105                	addi	sp,sp,32
    80004e7c:	8082                	ret

0000000080004e7e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004e7e:	7179                	addi	sp,sp,-48
    80004e80:	f406                	sd	ra,40(sp)
    80004e82:	f022                	sd	s0,32(sp)
    80004e84:	ec26                	sd	s1,24(sp)
    80004e86:	e84a                	sd	s2,16(sp)
    80004e88:	e44e                	sd	s3,8(sp)
    80004e8a:	1800                	addi	s0,sp,48
    80004e8c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004e8e:	00850913          	addi	s2,a0,8
    80004e92:	854a                	mv	a0,s2
    80004e94:	ffffc097          	auipc	ra,0xffffc
    80004e98:	d2e080e7          	jalr	-722(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e9c:	409c                	lw	a5,0(s1)
    80004e9e:	ef99                	bnez	a5,80004ebc <holdingsleep+0x3e>
    80004ea0:	4481                	li	s1,0
  release(&lk->lk);
    80004ea2:	854a                	mv	a0,s2
    80004ea4:	ffffc097          	auipc	ra,0xffffc
    80004ea8:	dd2080e7          	jalr	-558(ra) # 80000c76 <release>
  return r;
}
    80004eac:	8526                	mv	a0,s1
    80004eae:	70a2                	ld	ra,40(sp)
    80004eb0:	7402                	ld	s0,32(sp)
    80004eb2:	64e2                	ld	s1,24(sp)
    80004eb4:	6942                	ld	s2,16(sp)
    80004eb6:	69a2                	ld	s3,8(sp)
    80004eb8:	6145                	addi	sp,sp,48
    80004eba:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ebc:	0284a983          	lw	s3,40(s1)
    80004ec0:	ffffd097          	auipc	ra,0xffffd
    80004ec4:	100080e7          	jalr	256(ra) # 80001fc0 <myproc>
    80004ec8:	5904                	lw	s1,48(a0)
    80004eca:	413484b3          	sub	s1,s1,s3
    80004ece:	0014b493          	seqz	s1,s1
    80004ed2:	bfc1                	j	80004ea2 <holdingsleep+0x24>

0000000080004ed4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ed4:	1141                	addi	sp,sp,-16
    80004ed6:	e406                	sd	ra,8(sp)
    80004ed8:	e022                	sd	s0,0(sp)
    80004eda:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004edc:	00004597          	auipc	a1,0x4
    80004ee0:	94c58593          	addi	a1,a1,-1716 # 80008828 <syscalls+0x2e0>
    80004ee4:	0002c517          	auipc	a0,0x2c
    80004ee8:	6d450513          	addi	a0,a0,1748 # 800315b8 <ftable>
    80004eec:	ffffc097          	auipc	ra,0xffffc
    80004ef0:	c46080e7          	jalr	-954(ra) # 80000b32 <initlock>
}
    80004ef4:	60a2                	ld	ra,8(sp)
    80004ef6:	6402                	ld	s0,0(sp)
    80004ef8:	0141                	addi	sp,sp,16
    80004efa:	8082                	ret

0000000080004efc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004efc:	1101                	addi	sp,sp,-32
    80004efe:	ec06                	sd	ra,24(sp)
    80004f00:	e822                	sd	s0,16(sp)
    80004f02:	e426                	sd	s1,8(sp)
    80004f04:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004f06:	0002c517          	auipc	a0,0x2c
    80004f0a:	6b250513          	addi	a0,a0,1714 # 800315b8 <ftable>
    80004f0e:	ffffc097          	auipc	ra,0xffffc
    80004f12:	cb4080e7          	jalr	-844(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f16:	0002c497          	auipc	s1,0x2c
    80004f1a:	6ba48493          	addi	s1,s1,1722 # 800315d0 <ftable+0x18>
    80004f1e:	0002d717          	auipc	a4,0x2d
    80004f22:	65270713          	addi	a4,a4,1618 # 80032570 <ftable+0xfb8>
    if(f->ref == 0){
    80004f26:	40dc                	lw	a5,4(s1)
    80004f28:	cf99                	beqz	a5,80004f46 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f2a:	02848493          	addi	s1,s1,40
    80004f2e:	fee49ce3          	bne	s1,a4,80004f26 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004f32:	0002c517          	auipc	a0,0x2c
    80004f36:	68650513          	addi	a0,a0,1670 # 800315b8 <ftable>
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	d3c080e7          	jalr	-708(ra) # 80000c76 <release>
  return 0;
    80004f42:	4481                	li	s1,0
    80004f44:	a819                	j	80004f5a <filealloc+0x5e>
      f->ref = 1;
    80004f46:	4785                	li	a5,1
    80004f48:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004f4a:	0002c517          	auipc	a0,0x2c
    80004f4e:	66e50513          	addi	a0,a0,1646 # 800315b8 <ftable>
    80004f52:	ffffc097          	auipc	ra,0xffffc
    80004f56:	d24080e7          	jalr	-732(ra) # 80000c76 <release>
}
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	60e2                	ld	ra,24(sp)
    80004f5e:	6442                	ld	s0,16(sp)
    80004f60:	64a2                	ld	s1,8(sp)
    80004f62:	6105                	addi	sp,sp,32
    80004f64:	8082                	ret

0000000080004f66 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004f66:	1101                	addi	sp,sp,-32
    80004f68:	ec06                	sd	ra,24(sp)
    80004f6a:	e822                	sd	s0,16(sp)
    80004f6c:	e426                	sd	s1,8(sp)
    80004f6e:	1000                	addi	s0,sp,32
    80004f70:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004f72:	0002c517          	auipc	a0,0x2c
    80004f76:	64650513          	addi	a0,a0,1606 # 800315b8 <ftable>
    80004f7a:	ffffc097          	auipc	ra,0xffffc
    80004f7e:	c48080e7          	jalr	-952(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004f82:	40dc                	lw	a5,4(s1)
    80004f84:	02f05263          	blez	a5,80004fa8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004f88:	2785                	addiw	a5,a5,1
    80004f8a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004f8c:	0002c517          	auipc	a0,0x2c
    80004f90:	62c50513          	addi	a0,a0,1580 # 800315b8 <ftable>
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	ce2080e7          	jalr	-798(ra) # 80000c76 <release>
  return f;
}
    80004f9c:	8526                	mv	a0,s1
    80004f9e:	60e2                	ld	ra,24(sp)
    80004fa0:	6442                	ld	s0,16(sp)
    80004fa2:	64a2                	ld	s1,8(sp)
    80004fa4:	6105                	addi	sp,sp,32
    80004fa6:	8082                	ret
    panic("filedup");
    80004fa8:	00004517          	auipc	a0,0x4
    80004fac:	88850513          	addi	a0,a0,-1912 # 80008830 <syscalls+0x2e8>
    80004fb0:	ffffb097          	auipc	ra,0xffffb
    80004fb4:	57a080e7          	jalr	1402(ra) # 8000052a <panic>

0000000080004fb8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004fb8:	7139                	addi	sp,sp,-64
    80004fba:	fc06                	sd	ra,56(sp)
    80004fbc:	f822                	sd	s0,48(sp)
    80004fbe:	f426                	sd	s1,40(sp)
    80004fc0:	f04a                	sd	s2,32(sp)
    80004fc2:	ec4e                	sd	s3,24(sp)
    80004fc4:	e852                	sd	s4,16(sp)
    80004fc6:	e456                	sd	s5,8(sp)
    80004fc8:	0080                	addi	s0,sp,64
    80004fca:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004fcc:	0002c517          	auipc	a0,0x2c
    80004fd0:	5ec50513          	addi	a0,a0,1516 # 800315b8 <ftable>
    80004fd4:	ffffc097          	auipc	ra,0xffffc
    80004fd8:	bee080e7          	jalr	-1042(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004fdc:	40dc                	lw	a5,4(s1)
    80004fde:	06f05163          	blez	a5,80005040 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004fe2:	37fd                	addiw	a5,a5,-1
    80004fe4:	0007871b          	sext.w	a4,a5
    80004fe8:	c0dc                	sw	a5,4(s1)
    80004fea:	06e04363          	bgtz	a4,80005050 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004fee:	0004a903          	lw	s2,0(s1)
    80004ff2:	0094ca83          	lbu	s5,9(s1)
    80004ff6:	0104ba03          	ld	s4,16(s1)
    80004ffa:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ffe:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005002:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005006:	0002c517          	auipc	a0,0x2c
    8000500a:	5b250513          	addi	a0,a0,1458 # 800315b8 <ftable>
    8000500e:	ffffc097          	auipc	ra,0xffffc
    80005012:	c68080e7          	jalr	-920(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80005016:	4785                	li	a5,1
    80005018:	04f90d63          	beq	s2,a5,80005072 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000501c:	3979                	addiw	s2,s2,-2
    8000501e:	4785                	li	a5,1
    80005020:	0527e063          	bltu	a5,s2,80005060 <fileclose+0xa8>
    begin_op();
    80005024:	00000097          	auipc	ra,0x0
    80005028:	ac8080e7          	jalr	-1336(ra) # 80004aec <begin_op>
    iput(ff.ip);
    8000502c:	854e                	mv	a0,s3
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	f5a080e7          	jalr	-166(ra) # 80003f88 <iput>
    end_op();
    80005036:	00000097          	auipc	ra,0x0
    8000503a:	b36080e7          	jalr	-1226(ra) # 80004b6c <end_op>
    8000503e:	a00d                	j	80005060 <fileclose+0xa8>
    panic("fileclose");
    80005040:	00003517          	auipc	a0,0x3
    80005044:	7f850513          	addi	a0,a0,2040 # 80008838 <syscalls+0x2f0>
    80005048:	ffffb097          	auipc	ra,0xffffb
    8000504c:	4e2080e7          	jalr	1250(ra) # 8000052a <panic>
    release(&ftable.lock);
    80005050:	0002c517          	auipc	a0,0x2c
    80005054:	56850513          	addi	a0,a0,1384 # 800315b8 <ftable>
    80005058:	ffffc097          	auipc	ra,0xffffc
    8000505c:	c1e080e7          	jalr	-994(ra) # 80000c76 <release>
  }
}
    80005060:	70e2                	ld	ra,56(sp)
    80005062:	7442                	ld	s0,48(sp)
    80005064:	74a2                	ld	s1,40(sp)
    80005066:	7902                	ld	s2,32(sp)
    80005068:	69e2                	ld	s3,24(sp)
    8000506a:	6a42                	ld	s4,16(sp)
    8000506c:	6aa2                	ld	s5,8(sp)
    8000506e:	6121                	addi	sp,sp,64
    80005070:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005072:	85d6                	mv	a1,s5
    80005074:	8552                	mv	a0,s4
    80005076:	00000097          	auipc	ra,0x0
    8000507a:	542080e7          	jalr	1346(ra) # 800055b8 <pipeclose>
    8000507e:	b7cd                	j	80005060 <fileclose+0xa8>

0000000080005080 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005080:	715d                	addi	sp,sp,-80
    80005082:	e486                	sd	ra,72(sp)
    80005084:	e0a2                	sd	s0,64(sp)
    80005086:	fc26                	sd	s1,56(sp)
    80005088:	f84a                	sd	s2,48(sp)
    8000508a:	f44e                	sd	s3,40(sp)
    8000508c:	0880                	addi	s0,sp,80
    8000508e:	84aa                	mv	s1,a0
    80005090:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	f2e080e7          	jalr	-210(ra) # 80001fc0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000509a:	409c                	lw	a5,0(s1)
    8000509c:	37f9                	addiw	a5,a5,-2
    8000509e:	4705                	li	a4,1
    800050a0:	04f76763          	bltu	a4,a5,800050ee <filestat+0x6e>
    800050a4:	892a                	mv	s2,a0
    ilock(f->ip);
    800050a6:	6c88                	ld	a0,24(s1)
    800050a8:	fffff097          	auipc	ra,0xfffff
    800050ac:	d26080e7          	jalr	-730(ra) # 80003dce <ilock>
    stati(f->ip, &st);
    800050b0:	fb840593          	addi	a1,s0,-72
    800050b4:	6c88                	ld	a0,24(s1)
    800050b6:	fffff097          	auipc	ra,0xfffff
    800050ba:	fa2080e7          	jalr	-94(ra) # 80004058 <stati>
    iunlock(f->ip);
    800050be:	6c88                	ld	a0,24(s1)
    800050c0:	fffff097          	auipc	ra,0xfffff
    800050c4:	dd0080e7          	jalr	-560(ra) # 80003e90 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800050c8:	46e1                	li	a3,24
    800050ca:	fb840613          	addi	a2,s0,-72
    800050ce:	85ce                	mv	a1,s3
    800050d0:	05093503          	ld	a0,80(s2)
    800050d4:	ffffc097          	auipc	ra,0xffffc
    800050d8:	2aa080e7          	jalr	682(ra) # 8000137e <copyout>
    800050dc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800050e0:	60a6                	ld	ra,72(sp)
    800050e2:	6406                	ld	s0,64(sp)
    800050e4:	74e2                	ld	s1,56(sp)
    800050e6:	7942                	ld	s2,48(sp)
    800050e8:	79a2                	ld	s3,40(sp)
    800050ea:	6161                	addi	sp,sp,80
    800050ec:	8082                	ret
  return -1;
    800050ee:	557d                	li	a0,-1
    800050f0:	bfc5                	j	800050e0 <filestat+0x60>

00000000800050f2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800050f2:	7179                	addi	sp,sp,-48
    800050f4:	f406                	sd	ra,40(sp)
    800050f6:	f022                	sd	s0,32(sp)
    800050f8:	ec26                	sd	s1,24(sp)
    800050fa:	e84a                	sd	s2,16(sp)
    800050fc:	e44e                	sd	s3,8(sp)
    800050fe:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005100:	00854783          	lbu	a5,8(a0)
    80005104:	c3d5                	beqz	a5,800051a8 <fileread+0xb6>
    80005106:	84aa                	mv	s1,a0
    80005108:	89ae                	mv	s3,a1
    8000510a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000510c:	411c                	lw	a5,0(a0)
    8000510e:	4705                	li	a4,1
    80005110:	04e78963          	beq	a5,a4,80005162 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005114:	470d                	li	a4,3
    80005116:	04e78d63          	beq	a5,a4,80005170 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000511a:	4709                	li	a4,2
    8000511c:	06e79e63          	bne	a5,a4,80005198 <fileread+0xa6>
    ilock(f->ip);
    80005120:	6d08                	ld	a0,24(a0)
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	cac080e7          	jalr	-852(ra) # 80003dce <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000512a:	874a                	mv	a4,s2
    8000512c:	5094                	lw	a3,32(s1)
    8000512e:	864e                	mv	a2,s3
    80005130:	4585                	li	a1,1
    80005132:	6c88                	ld	a0,24(s1)
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	f4e080e7          	jalr	-178(ra) # 80004082 <readi>
    8000513c:	892a                	mv	s2,a0
    8000513e:	00a05563          	blez	a0,80005148 <fileread+0x56>
      f->off += r;
    80005142:	509c                	lw	a5,32(s1)
    80005144:	9fa9                	addw	a5,a5,a0
    80005146:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005148:	6c88                	ld	a0,24(s1)
    8000514a:	fffff097          	auipc	ra,0xfffff
    8000514e:	d46080e7          	jalr	-698(ra) # 80003e90 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005152:	854a                	mv	a0,s2
    80005154:	70a2                	ld	ra,40(sp)
    80005156:	7402                	ld	s0,32(sp)
    80005158:	64e2                	ld	s1,24(sp)
    8000515a:	6942                	ld	s2,16(sp)
    8000515c:	69a2                	ld	s3,8(sp)
    8000515e:	6145                	addi	sp,sp,48
    80005160:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005162:	6908                	ld	a0,16(a0)
    80005164:	00000097          	auipc	ra,0x0
    80005168:	5b6080e7          	jalr	1462(ra) # 8000571a <piperead>
    8000516c:	892a                	mv	s2,a0
    8000516e:	b7d5                	j	80005152 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005170:	02451783          	lh	a5,36(a0)
    80005174:	03079693          	slli	a3,a5,0x30
    80005178:	92c1                	srli	a3,a3,0x30
    8000517a:	4725                	li	a4,9
    8000517c:	02d76863          	bltu	a4,a3,800051ac <fileread+0xba>
    80005180:	0792                	slli	a5,a5,0x4
    80005182:	0002c717          	auipc	a4,0x2c
    80005186:	39670713          	addi	a4,a4,918 # 80031518 <devsw>
    8000518a:	97ba                	add	a5,a5,a4
    8000518c:	639c                	ld	a5,0(a5)
    8000518e:	c38d                	beqz	a5,800051b0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005190:	4505                	li	a0,1
    80005192:	9782                	jalr	a5
    80005194:	892a                	mv	s2,a0
    80005196:	bf75                	j	80005152 <fileread+0x60>
    panic("fileread");
    80005198:	00003517          	auipc	a0,0x3
    8000519c:	6b050513          	addi	a0,a0,1712 # 80008848 <syscalls+0x300>
    800051a0:	ffffb097          	auipc	ra,0xffffb
    800051a4:	38a080e7          	jalr	906(ra) # 8000052a <panic>
    return -1;
    800051a8:	597d                	li	s2,-1
    800051aa:	b765                	j	80005152 <fileread+0x60>
      return -1;
    800051ac:	597d                	li	s2,-1
    800051ae:	b755                	j	80005152 <fileread+0x60>
    800051b0:	597d                	li	s2,-1
    800051b2:	b745                	j	80005152 <fileread+0x60>

00000000800051b4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800051b4:	715d                	addi	sp,sp,-80
    800051b6:	e486                	sd	ra,72(sp)
    800051b8:	e0a2                	sd	s0,64(sp)
    800051ba:	fc26                	sd	s1,56(sp)
    800051bc:	f84a                	sd	s2,48(sp)
    800051be:	f44e                	sd	s3,40(sp)
    800051c0:	f052                	sd	s4,32(sp)
    800051c2:	ec56                	sd	s5,24(sp)
    800051c4:	e85a                	sd	s6,16(sp)
    800051c6:	e45e                	sd	s7,8(sp)
    800051c8:	e062                	sd	s8,0(sp)
    800051ca:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800051cc:	00954783          	lbu	a5,9(a0)
    800051d0:	10078663          	beqz	a5,800052dc <filewrite+0x128>
    800051d4:	892a                	mv	s2,a0
    800051d6:	8aae                	mv	s5,a1
    800051d8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800051da:	411c                	lw	a5,0(a0)
    800051dc:	4705                	li	a4,1
    800051de:	02e78263          	beq	a5,a4,80005202 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800051e2:	470d                	li	a4,3
    800051e4:	02e78663          	beq	a5,a4,80005210 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800051e8:	4709                	li	a4,2
    800051ea:	0ee79163          	bne	a5,a4,800052cc <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800051ee:	0ac05d63          	blez	a2,800052a8 <filewrite+0xf4>
    int i = 0;
    800051f2:	4981                	li	s3,0
    800051f4:	6b05                	lui	s6,0x1
    800051f6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800051fa:	6b85                	lui	s7,0x1
    800051fc:	c00b8b9b          	addiw	s7,s7,-1024
    80005200:	a861                	j	80005298 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005202:	6908                	ld	a0,16(a0)
    80005204:	00000097          	auipc	ra,0x0
    80005208:	424080e7          	jalr	1060(ra) # 80005628 <pipewrite>
    8000520c:	8a2a                	mv	s4,a0
    8000520e:	a045                	j	800052ae <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005210:	02451783          	lh	a5,36(a0)
    80005214:	03079693          	slli	a3,a5,0x30
    80005218:	92c1                	srli	a3,a3,0x30
    8000521a:	4725                	li	a4,9
    8000521c:	0cd76263          	bltu	a4,a3,800052e0 <filewrite+0x12c>
    80005220:	0792                	slli	a5,a5,0x4
    80005222:	0002c717          	auipc	a4,0x2c
    80005226:	2f670713          	addi	a4,a4,758 # 80031518 <devsw>
    8000522a:	97ba                	add	a5,a5,a4
    8000522c:	679c                	ld	a5,8(a5)
    8000522e:	cbdd                	beqz	a5,800052e4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005230:	4505                	li	a0,1
    80005232:	9782                	jalr	a5
    80005234:	8a2a                	mv	s4,a0
    80005236:	a8a5                	j	800052ae <filewrite+0xfa>
    80005238:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000523c:	00000097          	auipc	ra,0x0
    80005240:	8b0080e7          	jalr	-1872(ra) # 80004aec <begin_op>
      ilock(f->ip);
    80005244:	01893503          	ld	a0,24(s2)
    80005248:	fffff097          	auipc	ra,0xfffff
    8000524c:	b86080e7          	jalr	-1146(ra) # 80003dce <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005250:	8762                	mv	a4,s8
    80005252:	02092683          	lw	a3,32(s2)
    80005256:	01598633          	add	a2,s3,s5
    8000525a:	4585                	li	a1,1
    8000525c:	01893503          	ld	a0,24(s2)
    80005260:	fffff097          	auipc	ra,0xfffff
    80005264:	f1a080e7          	jalr	-230(ra) # 8000417a <writei>
    80005268:	84aa                	mv	s1,a0
    8000526a:	00a05763          	blez	a0,80005278 <filewrite+0xc4>
        f->off += r;
    8000526e:	02092783          	lw	a5,32(s2)
    80005272:	9fa9                	addw	a5,a5,a0
    80005274:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005278:	01893503          	ld	a0,24(s2)
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	c14080e7          	jalr	-1004(ra) # 80003e90 <iunlock>
      end_op();
    80005284:	00000097          	auipc	ra,0x0
    80005288:	8e8080e7          	jalr	-1816(ra) # 80004b6c <end_op>

      if(r != n1){
    8000528c:	009c1f63          	bne	s8,s1,800052aa <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005290:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005294:	0149db63          	bge	s3,s4,800052aa <filewrite+0xf6>
      int n1 = n - i;
    80005298:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000529c:	84be                	mv	s1,a5
    8000529e:	2781                	sext.w	a5,a5
    800052a0:	f8fb5ce3          	bge	s6,a5,80005238 <filewrite+0x84>
    800052a4:	84de                	mv	s1,s7
    800052a6:	bf49                	j	80005238 <filewrite+0x84>
    int i = 0;
    800052a8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800052aa:	013a1f63          	bne	s4,s3,800052c8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800052ae:	8552                	mv	a0,s4
    800052b0:	60a6                	ld	ra,72(sp)
    800052b2:	6406                	ld	s0,64(sp)
    800052b4:	74e2                	ld	s1,56(sp)
    800052b6:	7942                	ld	s2,48(sp)
    800052b8:	79a2                	ld	s3,40(sp)
    800052ba:	7a02                	ld	s4,32(sp)
    800052bc:	6ae2                	ld	s5,24(sp)
    800052be:	6b42                	ld	s6,16(sp)
    800052c0:	6ba2                	ld	s7,8(sp)
    800052c2:	6c02                	ld	s8,0(sp)
    800052c4:	6161                	addi	sp,sp,80
    800052c6:	8082                	ret
    ret = (i == n ? n : -1);
    800052c8:	5a7d                	li	s4,-1
    800052ca:	b7d5                	j	800052ae <filewrite+0xfa>
    panic("filewrite");
    800052cc:	00003517          	auipc	a0,0x3
    800052d0:	58c50513          	addi	a0,a0,1420 # 80008858 <syscalls+0x310>
    800052d4:	ffffb097          	auipc	ra,0xffffb
    800052d8:	256080e7          	jalr	598(ra) # 8000052a <panic>
    return -1;
    800052dc:	5a7d                	li	s4,-1
    800052de:	bfc1                	j	800052ae <filewrite+0xfa>
      return -1;
    800052e0:	5a7d                	li	s4,-1
    800052e2:	b7f1                	j	800052ae <filewrite+0xfa>
    800052e4:	5a7d                	li	s4,-1
    800052e6:	b7e1                	j	800052ae <filewrite+0xfa>

00000000800052e8 <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    800052e8:	7179                	addi	sp,sp,-48
    800052ea:	f406                	sd	ra,40(sp)
    800052ec:	f022                	sd	s0,32(sp)
    800052ee:	ec26                	sd	s1,24(sp)
    800052f0:	e84a                	sd	s2,16(sp)
    800052f2:	e44e                	sd	s3,8(sp)
    800052f4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800052f6:	00854783          	lbu	a5,8(a0)
    800052fa:	c3d5                	beqz	a5,8000539e <kfileread+0xb6>
    800052fc:	84aa                	mv	s1,a0
    800052fe:	89ae                	mv	s3,a1
    80005300:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005302:	411c                	lw	a5,0(a0)
    80005304:	4705                	li	a4,1
    80005306:	04e78963          	beq	a5,a4,80005358 <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000530a:	470d                	li	a4,3
    8000530c:	04e78d63          	beq	a5,a4,80005366 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005310:	4709                	li	a4,2
    80005312:	06e79e63          	bne	a5,a4,8000538e <kfileread+0xa6>
    ilock(f->ip);
    80005316:	6d08                	ld	a0,24(a0)
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	ab6080e7          	jalr	-1354(ra) # 80003dce <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    80005320:	874a                	mv	a4,s2
    80005322:	5094                	lw	a3,32(s1)
    80005324:	864e                	mv	a2,s3
    80005326:	4581                	li	a1,0
    80005328:	6c88                	ld	a0,24(s1)
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	d58080e7          	jalr	-680(ra) # 80004082 <readi>
    80005332:	892a                	mv	s2,a0
    80005334:	00a05563          	blez	a0,8000533e <kfileread+0x56>
      f->off += r;
    80005338:	509c                	lw	a5,32(s1)
    8000533a:	9fa9                	addw	a5,a5,a0
    8000533c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000533e:	6c88                	ld	a0,24(s1)
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	b50080e7          	jalr	-1200(ra) # 80003e90 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005348:	854a                	mv	a0,s2
    8000534a:	70a2                	ld	ra,40(sp)
    8000534c:	7402                	ld	s0,32(sp)
    8000534e:	64e2                	ld	s1,24(sp)
    80005350:	6942                	ld	s2,16(sp)
    80005352:	69a2                	ld	s3,8(sp)
    80005354:	6145                	addi	sp,sp,48
    80005356:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005358:	6908                	ld	a0,16(a0)
    8000535a:	00000097          	auipc	ra,0x0
    8000535e:	3c0080e7          	jalr	960(ra) # 8000571a <piperead>
    80005362:	892a                	mv	s2,a0
    80005364:	b7d5                	j	80005348 <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005366:	02451783          	lh	a5,36(a0)
    8000536a:	03079693          	slli	a3,a5,0x30
    8000536e:	92c1                	srli	a3,a3,0x30
    80005370:	4725                	li	a4,9
    80005372:	02d76863          	bltu	a4,a3,800053a2 <kfileread+0xba>
    80005376:	0792                	slli	a5,a5,0x4
    80005378:	0002c717          	auipc	a4,0x2c
    8000537c:	1a070713          	addi	a4,a4,416 # 80031518 <devsw>
    80005380:	97ba                	add	a5,a5,a4
    80005382:	639c                	ld	a5,0(a5)
    80005384:	c38d                	beqz	a5,800053a6 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005386:	4505                	li	a0,1
    80005388:	9782                	jalr	a5
    8000538a:	892a                	mv	s2,a0
    8000538c:	bf75                	j	80005348 <kfileread+0x60>
    panic("fileread");
    8000538e:	00003517          	auipc	a0,0x3
    80005392:	4ba50513          	addi	a0,a0,1210 # 80008848 <syscalls+0x300>
    80005396:	ffffb097          	auipc	ra,0xffffb
    8000539a:	194080e7          	jalr	404(ra) # 8000052a <panic>
    return -1;
    8000539e:	597d                	li	s2,-1
    800053a0:	b765                	j	80005348 <kfileread+0x60>
      return -1;
    800053a2:	597d                	li	s2,-1
    800053a4:	b755                	j	80005348 <kfileread+0x60>
    800053a6:	597d                	li	s2,-1
    800053a8:	b745                	j	80005348 <kfileread+0x60>

00000000800053aa <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    800053aa:	715d                	addi	sp,sp,-80
    800053ac:	e486                	sd	ra,72(sp)
    800053ae:	e0a2                	sd	s0,64(sp)
    800053b0:	fc26                	sd	s1,56(sp)
    800053b2:	f84a                	sd	s2,48(sp)
    800053b4:	f44e                	sd	s3,40(sp)
    800053b6:	f052                	sd	s4,32(sp)
    800053b8:	ec56                	sd	s5,24(sp)
    800053ba:	e85a                	sd	s6,16(sp)
    800053bc:	e45e                	sd	s7,8(sp)
    800053be:	e062                	sd	s8,0(sp)
    800053c0:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800053c2:	00954783          	lbu	a5,9(a0)
    800053c6:	10078663          	beqz	a5,800054d2 <kfilewrite+0x128>
    800053ca:	892a                	mv	s2,a0
    800053cc:	8aae                	mv	s5,a1
    800053ce:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800053d0:	411c                	lw	a5,0(a0)
    800053d2:	4705                	li	a4,1
    800053d4:	02e78263          	beq	a5,a4,800053f8 <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800053d8:	470d                	li	a4,3
    800053da:	02e78663          	beq	a5,a4,80005406 <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800053de:	4709                	li	a4,2
    800053e0:	0ee79163          	bne	a5,a4,800054c2 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800053e4:	0ac05d63          	blez	a2,8000549e <kfilewrite+0xf4>
    int i = 0;
    800053e8:	4981                	li	s3,0
    800053ea:	6b05                	lui	s6,0x1
    800053ec:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800053f0:	6b85                	lui	s7,0x1
    800053f2:	c00b8b9b          	addiw	s7,s7,-1024
    800053f6:	a861                	j	8000548e <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800053f8:	6908                	ld	a0,16(a0)
    800053fa:	00000097          	auipc	ra,0x0
    800053fe:	22e080e7          	jalr	558(ra) # 80005628 <pipewrite>
    80005402:	8a2a                	mv	s4,a0
    80005404:	a045                	j	800054a4 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005406:	02451783          	lh	a5,36(a0)
    8000540a:	03079693          	slli	a3,a5,0x30
    8000540e:	92c1                	srli	a3,a3,0x30
    80005410:	4725                	li	a4,9
    80005412:	0cd76263          	bltu	a4,a3,800054d6 <kfilewrite+0x12c>
    80005416:	0792                	slli	a5,a5,0x4
    80005418:	0002c717          	auipc	a4,0x2c
    8000541c:	10070713          	addi	a4,a4,256 # 80031518 <devsw>
    80005420:	97ba                	add	a5,a5,a4
    80005422:	679c                	ld	a5,8(a5)
    80005424:	cbdd                	beqz	a5,800054da <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005426:	4505                	li	a0,1
    80005428:	9782                	jalr	a5
    8000542a:	8a2a                	mv	s4,a0
    8000542c:	a8a5                	j	800054a4 <kfilewrite+0xfa>
    8000542e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	6ba080e7          	jalr	1722(ra) # 80004aec <begin_op>
      ilock(f->ip);
    8000543a:	01893503          	ld	a0,24(s2)
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	990080e7          	jalr	-1648(ra) # 80003dce <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    80005446:	8762                	mv	a4,s8
    80005448:	02092683          	lw	a3,32(s2)
    8000544c:	01598633          	add	a2,s3,s5
    80005450:	4581                	li	a1,0
    80005452:	01893503          	ld	a0,24(s2)
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	d24080e7          	jalr	-732(ra) # 8000417a <writei>
    8000545e:	84aa                	mv	s1,a0
    80005460:	00a05763          	blez	a0,8000546e <kfilewrite+0xc4>
        f->off += r;
    80005464:	02092783          	lw	a5,32(s2)
    80005468:	9fa9                	addw	a5,a5,a0
    8000546a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000546e:	01893503          	ld	a0,24(s2)
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	a1e080e7          	jalr	-1506(ra) # 80003e90 <iunlock>
      end_op();
    8000547a:	fffff097          	auipc	ra,0xfffff
    8000547e:	6f2080e7          	jalr	1778(ra) # 80004b6c <end_op>

      if(r != n1){
    80005482:	009c1f63          	bne	s8,s1,800054a0 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005486:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000548a:	0149db63          	bge	s3,s4,800054a0 <kfilewrite+0xf6>
      int n1 = n - i;
    8000548e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005492:	84be                	mv	s1,a5
    80005494:	2781                	sext.w	a5,a5
    80005496:	f8fb5ce3          	bge	s6,a5,8000542e <kfilewrite+0x84>
    8000549a:	84de                	mv	s1,s7
    8000549c:	bf49                	j	8000542e <kfilewrite+0x84>
    int i = 0;
    8000549e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800054a0:	013a1f63          	bne	s4,s3,800054be <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    800054a4:	8552                	mv	a0,s4
    800054a6:	60a6                	ld	ra,72(sp)
    800054a8:	6406                	ld	s0,64(sp)
    800054aa:	74e2                	ld	s1,56(sp)
    800054ac:	7942                	ld	s2,48(sp)
    800054ae:	79a2                	ld	s3,40(sp)
    800054b0:	7a02                	ld	s4,32(sp)
    800054b2:	6ae2                	ld	s5,24(sp)
    800054b4:	6b42                	ld	s6,16(sp)
    800054b6:	6ba2                	ld	s7,8(sp)
    800054b8:	6c02                	ld	s8,0(sp)
    800054ba:	6161                	addi	sp,sp,80
    800054bc:	8082                	ret
    ret = (i == n ? n : -1);
    800054be:	5a7d                	li	s4,-1
    800054c0:	b7d5                	j	800054a4 <kfilewrite+0xfa>
    panic("filewrite");
    800054c2:	00003517          	auipc	a0,0x3
    800054c6:	39650513          	addi	a0,a0,918 # 80008858 <syscalls+0x310>
    800054ca:	ffffb097          	auipc	ra,0xffffb
    800054ce:	060080e7          	jalr	96(ra) # 8000052a <panic>
    return -1;
    800054d2:	5a7d                	li	s4,-1
    800054d4:	bfc1                	j	800054a4 <kfilewrite+0xfa>
      return -1;
    800054d6:	5a7d                	li	s4,-1
    800054d8:	b7f1                	j	800054a4 <kfilewrite+0xfa>
    800054da:	5a7d                	li	s4,-1
    800054dc:	b7e1                	j	800054a4 <kfilewrite+0xfa>

00000000800054de <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800054de:	7179                	addi	sp,sp,-48
    800054e0:	f406                	sd	ra,40(sp)
    800054e2:	f022                	sd	s0,32(sp)
    800054e4:	ec26                	sd	s1,24(sp)
    800054e6:	e84a                	sd	s2,16(sp)
    800054e8:	e44e                	sd	s3,8(sp)
    800054ea:	e052                	sd	s4,0(sp)
    800054ec:	1800                	addi	s0,sp,48
    800054ee:	84aa                	mv	s1,a0
    800054f0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800054f2:	0005b023          	sd	zero,0(a1)
    800054f6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800054fa:	00000097          	auipc	ra,0x0
    800054fe:	a02080e7          	jalr	-1534(ra) # 80004efc <filealloc>
    80005502:	e088                	sd	a0,0(s1)
    80005504:	c551                	beqz	a0,80005590 <pipealloc+0xb2>
    80005506:	00000097          	auipc	ra,0x0
    8000550a:	9f6080e7          	jalr	-1546(ra) # 80004efc <filealloc>
    8000550e:	00aa3023          	sd	a0,0(s4)
    80005512:	c92d                	beqz	a0,80005584 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005514:	ffffb097          	auipc	ra,0xffffb
    80005518:	5be080e7          	jalr	1470(ra) # 80000ad2 <kalloc>
    8000551c:	892a                	mv	s2,a0
    8000551e:	c125                	beqz	a0,8000557e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005520:	4985                	li	s3,1
    80005522:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005526:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000552a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000552e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005532:	00003597          	auipc	a1,0x3
    80005536:	33658593          	addi	a1,a1,822 # 80008868 <syscalls+0x320>
    8000553a:	ffffb097          	auipc	ra,0xffffb
    8000553e:	5f8080e7          	jalr	1528(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80005542:	609c                	ld	a5,0(s1)
    80005544:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005548:	609c                	ld	a5,0(s1)
    8000554a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000554e:	609c                	ld	a5,0(s1)
    80005550:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005554:	609c                	ld	a5,0(s1)
    80005556:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000555a:	000a3783          	ld	a5,0(s4)
    8000555e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005562:	000a3783          	ld	a5,0(s4)
    80005566:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000556a:	000a3783          	ld	a5,0(s4)
    8000556e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005572:	000a3783          	ld	a5,0(s4)
    80005576:	0127b823          	sd	s2,16(a5)
  return 0;
    8000557a:	4501                	li	a0,0
    8000557c:	a025                	j	800055a4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000557e:	6088                	ld	a0,0(s1)
    80005580:	e501                	bnez	a0,80005588 <pipealloc+0xaa>
    80005582:	a039                	j	80005590 <pipealloc+0xb2>
    80005584:	6088                	ld	a0,0(s1)
    80005586:	c51d                	beqz	a0,800055b4 <pipealloc+0xd6>
    fileclose(*f0);
    80005588:	00000097          	auipc	ra,0x0
    8000558c:	a30080e7          	jalr	-1488(ra) # 80004fb8 <fileclose>
  if(*f1)
    80005590:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005594:	557d                	li	a0,-1
  if(*f1)
    80005596:	c799                	beqz	a5,800055a4 <pipealloc+0xc6>
    fileclose(*f1);
    80005598:	853e                	mv	a0,a5
    8000559a:	00000097          	auipc	ra,0x0
    8000559e:	a1e080e7          	jalr	-1506(ra) # 80004fb8 <fileclose>
  return -1;
    800055a2:	557d                	li	a0,-1
}
    800055a4:	70a2                	ld	ra,40(sp)
    800055a6:	7402                	ld	s0,32(sp)
    800055a8:	64e2                	ld	s1,24(sp)
    800055aa:	6942                	ld	s2,16(sp)
    800055ac:	69a2                	ld	s3,8(sp)
    800055ae:	6a02                	ld	s4,0(sp)
    800055b0:	6145                	addi	sp,sp,48
    800055b2:	8082                	ret
  return -1;
    800055b4:	557d                	li	a0,-1
    800055b6:	b7fd                	j	800055a4 <pipealloc+0xc6>

00000000800055b8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800055b8:	1101                	addi	sp,sp,-32
    800055ba:	ec06                	sd	ra,24(sp)
    800055bc:	e822                	sd	s0,16(sp)
    800055be:	e426                	sd	s1,8(sp)
    800055c0:	e04a                	sd	s2,0(sp)
    800055c2:	1000                	addi	s0,sp,32
    800055c4:	84aa                	mv	s1,a0
    800055c6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800055c8:	ffffb097          	auipc	ra,0xffffb
    800055cc:	5fa080e7          	jalr	1530(ra) # 80000bc2 <acquire>
  if(writable){
    800055d0:	02090d63          	beqz	s2,8000560a <pipeclose+0x52>
    pi->writeopen = 0;
    800055d4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800055d8:	21848513          	addi	a0,s1,536
    800055dc:	ffffd097          	auipc	ra,0xffffd
    800055e0:	326080e7          	jalr	806(ra) # 80002902 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800055e4:	2204b783          	ld	a5,544(s1)
    800055e8:	eb95                	bnez	a5,8000561c <pipeclose+0x64>
    release(&pi->lock);
    800055ea:	8526                	mv	a0,s1
    800055ec:	ffffb097          	auipc	ra,0xffffb
    800055f0:	68a080e7          	jalr	1674(ra) # 80000c76 <release>
    kfree((char*)pi);
    800055f4:	8526                	mv	a0,s1
    800055f6:	ffffb097          	auipc	ra,0xffffb
    800055fa:	3e0080e7          	jalr	992(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    800055fe:	60e2                	ld	ra,24(sp)
    80005600:	6442                	ld	s0,16(sp)
    80005602:	64a2                	ld	s1,8(sp)
    80005604:	6902                	ld	s2,0(sp)
    80005606:	6105                	addi	sp,sp,32
    80005608:	8082                	ret
    pi->readopen = 0;
    8000560a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000560e:	21c48513          	addi	a0,s1,540
    80005612:	ffffd097          	auipc	ra,0xffffd
    80005616:	2f0080e7          	jalr	752(ra) # 80002902 <wakeup>
    8000561a:	b7e9                	j	800055e4 <pipeclose+0x2c>
    release(&pi->lock);
    8000561c:	8526                	mv	a0,s1
    8000561e:	ffffb097          	auipc	ra,0xffffb
    80005622:	658080e7          	jalr	1624(ra) # 80000c76 <release>
}
    80005626:	bfe1                	j	800055fe <pipeclose+0x46>

0000000080005628 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005628:	711d                	addi	sp,sp,-96
    8000562a:	ec86                	sd	ra,88(sp)
    8000562c:	e8a2                	sd	s0,80(sp)
    8000562e:	e4a6                	sd	s1,72(sp)
    80005630:	e0ca                	sd	s2,64(sp)
    80005632:	fc4e                	sd	s3,56(sp)
    80005634:	f852                	sd	s4,48(sp)
    80005636:	f456                	sd	s5,40(sp)
    80005638:	f05a                	sd	s6,32(sp)
    8000563a:	ec5e                	sd	s7,24(sp)
    8000563c:	e862                	sd	s8,16(sp)
    8000563e:	1080                	addi	s0,sp,96
    80005640:	84aa                	mv	s1,a0
    80005642:	8aae                	mv	s5,a1
    80005644:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005646:	ffffd097          	auipc	ra,0xffffd
    8000564a:	97a080e7          	jalr	-1670(ra) # 80001fc0 <myproc>
    8000564e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005650:	8526                	mv	a0,s1
    80005652:	ffffb097          	auipc	ra,0xffffb
    80005656:	570080e7          	jalr	1392(ra) # 80000bc2 <acquire>
  while(i < n){
    8000565a:	0b405363          	blez	s4,80005700 <pipewrite+0xd8>
  int i = 0;
    8000565e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005660:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005662:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005666:	21c48b93          	addi	s7,s1,540
    8000566a:	a089                	j	800056ac <pipewrite+0x84>
      release(&pi->lock);
    8000566c:	8526                	mv	a0,s1
    8000566e:	ffffb097          	auipc	ra,0xffffb
    80005672:	608080e7          	jalr	1544(ra) # 80000c76 <release>
      return -1;
    80005676:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005678:	854a                	mv	a0,s2
    8000567a:	60e6                	ld	ra,88(sp)
    8000567c:	6446                	ld	s0,80(sp)
    8000567e:	64a6                	ld	s1,72(sp)
    80005680:	6906                	ld	s2,64(sp)
    80005682:	79e2                	ld	s3,56(sp)
    80005684:	7a42                	ld	s4,48(sp)
    80005686:	7aa2                	ld	s5,40(sp)
    80005688:	7b02                	ld	s6,32(sp)
    8000568a:	6be2                	ld	s7,24(sp)
    8000568c:	6c42                	ld	s8,16(sp)
    8000568e:	6125                	addi	sp,sp,96
    80005690:	8082                	ret
      wakeup(&pi->nread);
    80005692:	8562                	mv	a0,s8
    80005694:	ffffd097          	auipc	ra,0xffffd
    80005698:	26e080e7          	jalr	622(ra) # 80002902 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000569c:	85a6                	mv	a1,s1
    8000569e:	855e                	mv	a0,s7
    800056a0:	ffffd097          	auipc	ra,0xffffd
    800056a4:	0d6080e7          	jalr	214(ra) # 80002776 <sleep>
  while(i < n){
    800056a8:	05495d63          	bge	s2,s4,80005702 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    800056ac:	2204a783          	lw	a5,544(s1)
    800056b0:	dfd5                	beqz	a5,8000566c <pipewrite+0x44>
    800056b2:	0289a783          	lw	a5,40(s3)
    800056b6:	fbdd                	bnez	a5,8000566c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800056b8:	2184a783          	lw	a5,536(s1)
    800056bc:	21c4a703          	lw	a4,540(s1)
    800056c0:	2007879b          	addiw	a5,a5,512
    800056c4:	fcf707e3          	beq	a4,a5,80005692 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800056c8:	4685                	li	a3,1
    800056ca:	01590633          	add	a2,s2,s5
    800056ce:	faf40593          	addi	a1,s0,-81
    800056d2:	0509b503          	ld	a0,80(s3)
    800056d6:	ffffc097          	auipc	ra,0xffffc
    800056da:	d34080e7          	jalr	-716(ra) # 8000140a <copyin>
    800056de:	03650263          	beq	a0,s6,80005702 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800056e2:	21c4a783          	lw	a5,540(s1)
    800056e6:	0017871b          	addiw	a4,a5,1
    800056ea:	20e4ae23          	sw	a4,540(s1)
    800056ee:	1ff7f793          	andi	a5,a5,511
    800056f2:	97a6                	add	a5,a5,s1
    800056f4:	faf44703          	lbu	a4,-81(s0)
    800056f8:	00e78c23          	sb	a4,24(a5)
      i++;
    800056fc:	2905                	addiw	s2,s2,1
    800056fe:	b76d                	j	800056a8 <pipewrite+0x80>
  int i = 0;
    80005700:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005702:	21848513          	addi	a0,s1,536
    80005706:	ffffd097          	auipc	ra,0xffffd
    8000570a:	1fc080e7          	jalr	508(ra) # 80002902 <wakeup>
  release(&pi->lock);
    8000570e:	8526                	mv	a0,s1
    80005710:	ffffb097          	auipc	ra,0xffffb
    80005714:	566080e7          	jalr	1382(ra) # 80000c76 <release>
  return i;
    80005718:	b785                	j	80005678 <pipewrite+0x50>

000000008000571a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000571a:	715d                	addi	sp,sp,-80
    8000571c:	e486                	sd	ra,72(sp)
    8000571e:	e0a2                	sd	s0,64(sp)
    80005720:	fc26                	sd	s1,56(sp)
    80005722:	f84a                	sd	s2,48(sp)
    80005724:	f44e                	sd	s3,40(sp)
    80005726:	f052                	sd	s4,32(sp)
    80005728:	ec56                	sd	s5,24(sp)
    8000572a:	e85a                	sd	s6,16(sp)
    8000572c:	0880                	addi	s0,sp,80
    8000572e:	84aa                	mv	s1,a0
    80005730:	892e                	mv	s2,a1
    80005732:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005734:	ffffd097          	auipc	ra,0xffffd
    80005738:	88c080e7          	jalr	-1908(ra) # 80001fc0 <myproc>
    8000573c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000573e:	8526                	mv	a0,s1
    80005740:	ffffb097          	auipc	ra,0xffffb
    80005744:	482080e7          	jalr	1154(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005748:	2184a703          	lw	a4,536(s1)
    8000574c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005750:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005754:	02f71463          	bne	a4,a5,8000577c <piperead+0x62>
    80005758:	2244a783          	lw	a5,548(s1)
    8000575c:	c385                	beqz	a5,8000577c <piperead+0x62>
    if(pr->killed){
    8000575e:	028a2783          	lw	a5,40(s4)
    80005762:	ebc1                	bnez	a5,800057f2 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005764:	85a6                	mv	a1,s1
    80005766:	854e                	mv	a0,s3
    80005768:	ffffd097          	auipc	ra,0xffffd
    8000576c:	00e080e7          	jalr	14(ra) # 80002776 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005770:	2184a703          	lw	a4,536(s1)
    80005774:	21c4a783          	lw	a5,540(s1)
    80005778:	fef700e3          	beq	a4,a5,80005758 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000577c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000577e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005780:	05505363          	blez	s5,800057c6 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005784:	2184a783          	lw	a5,536(s1)
    80005788:	21c4a703          	lw	a4,540(s1)
    8000578c:	02f70d63          	beq	a4,a5,800057c6 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005790:	0017871b          	addiw	a4,a5,1
    80005794:	20e4ac23          	sw	a4,536(s1)
    80005798:	1ff7f793          	andi	a5,a5,511
    8000579c:	97a6                	add	a5,a5,s1
    8000579e:	0187c783          	lbu	a5,24(a5)
    800057a2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800057a6:	4685                	li	a3,1
    800057a8:	fbf40613          	addi	a2,s0,-65
    800057ac:	85ca                	mv	a1,s2
    800057ae:	050a3503          	ld	a0,80(s4)
    800057b2:	ffffc097          	auipc	ra,0xffffc
    800057b6:	bcc080e7          	jalr	-1076(ra) # 8000137e <copyout>
    800057ba:	01650663          	beq	a0,s6,800057c6 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800057be:	2985                	addiw	s3,s3,1
    800057c0:	0905                	addi	s2,s2,1
    800057c2:	fd3a91e3          	bne	s5,s3,80005784 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800057c6:	21c48513          	addi	a0,s1,540
    800057ca:	ffffd097          	auipc	ra,0xffffd
    800057ce:	138080e7          	jalr	312(ra) # 80002902 <wakeup>
  release(&pi->lock);
    800057d2:	8526                	mv	a0,s1
    800057d4:	ffffb097          	auipc	ra,0xffffb
    800057d8:	4a2080e7          	jalr	1186(ra) # 80000c76 <release>
  return i;
}
    800057dc:	854e                	mv	a0,s3
    800057de:	60a6                	ld	ra,72(sp)
    800057e0:	6406                	ld	s0,64(sp)
    800057e2:	74e2                	ld	s1,56(sp)
    800057e4:	7942                	ld	s2,48(sp)
    800057e6:	79a2                	ld	s3,40(sp)
    800057e8:	7a02                	ld	s4,32(sp)
    800057ea:	6ae2                	ld	s5,24(sp)
    800057ec:	6b42                	ld	s6,16(sp)
    800057ee:	6161                	addi	sp,sp,80
    800057f0:	8082                	ret
      release(&pi->lock);
    800057f2:	8526                	mv	a0,s1
    800057f4:	ffffb097          	auipc	ra,0xffffb
    800057f8:	482080e7          	jalr	1154(ra) # 80000c76 <release>
      return -1;
    800057fc:	59fd                	li	s3,-1
    800057fe:	bff9                	j	800057dc <piperead+0xc2>

0000000080005800 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005800:	de010113          	addi	sp,sp,-544
    80005804:	20113c23          	sd	ra,536(sp)
    80005808:	20813823          	sd	s0,528(sp)
    8000580c:	20913423          	sd	s1,520(sp)
    80005810:	21213023          	sd	s2,512(sp)
    80005814:	ffce                	sd	s3,504(sp)
    80005816:	fbd2                	sd	s4,496(sp)
    80005818:	f7d6                	sd	s5,488(sp)
    8000581a:	f3da                	sd	s6,480(sp)
    8000581c:	efde                	sd	s7,472(sp)
    8000581e:	ebe2                	sd	s8,464(sp)
    80005820:	e7e6                	sd	s9,456(sp)
    80005822:	e3ea                	sd	s10,448(sp)
    80005824:	ff6e                	sd	s11,440(sp)
    80005826:	1400                	addi	s0,sp,544
    80005828:	892a                	mv	s2,a0
    8000582a:	dea43423          	sd	a0,-536(s0)
    8000582e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005832:	ffffc097          	auipc	ra,0xffffc
    80005836:	78e080e7          	jalr	1934(ra) # 80001fc0 <myproc>
    8000583a:	84aa                	mv	s1,a0
  printf("exec\n");
    8000583c:	00003517          	auipc	a0,0x3
    80005840:	03450513          	addi	a0,a0,52 # 80008870 <syscalls+0x328>
    80005844:	ffffb097          	auipc	ra,0xffffb
    80005848:	d30080e7          	jalr	-720(ra) # 80000574 <printf>
  begin_op();
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	2a0080e7          	jalr	672(ra) # 80004aec <begin_op>

  if((ip = namei(path)) == 0){
    80005854:	854a                	mv	a0,s2
    80005856:	fffff097          	auipc	ra,0xfffff
    8000585a:	d2e080e7          	jalr	-722(ra) # 80004584 <namei>
    8000585e:	c93d                	beqz	a0,800058d4 <exec+0xd4>
    80005860:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	56c080e7          	jalr	1388(ra) # 80003dce <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000586a:	04000713          	li	a4,64
    8000586e:	4681                	li	a3,0
    80005870:	e4840613          	addi	a2,s0,-440
    80005874:	4581                	li	a1,0
    80005876:	8556                	mv	a0,s5
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	80a080e7          	jalr	-2038(ra) # 80004082 <readi>
    80005880:	04000793          	li	a5,64
    80005884:	00f51a63          	bne	a0,a5,80005898 <exec+0x98>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005888:	e4842703          	lw	a4,-440(s0)
    8000588c:	464c47b7          	lui	a5,0x464c4
    80005890:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005894:	04f70663          	beq	a4,a5,800058e0 <exec+0xe0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005898:	8556                	mv	a0,s5
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	796080e7          	jalr	1942(ra) # 80004030 <iunlockput>
    end_op();
    800058a2:	fffff097          	auipc	ra,0xfffff
    800058a6:	2ca080e7          	jalr	714(ra) # 80004b6c <end_op>
  }
  return -1;
    800058aa:	557d                	li	a0,-1
}
    800058ac:	21813083          	ld	ra,536(sp)
    800058b0:	21013403          	ld	s0,528(sp)
    800058b4:	20813483          	ld	s1,520(sp)
    800058b8:	20013903          	ld	s2,512(sp)
    800058bc:	79fe                	ld	s3,504(sp)
    800058be:	7a5e                	ld	s4,496(sp)
    800058c0:	7abe                	ld	s5,488(sp)
    800058c2:	7b1e                	ld	s6,480(sp)
    800058c4:	6bfe                	ld	s7,472(sp)
    800058c6:	6c5e                	ld	s8,464(sp)
    800058c8:	6cbe                	ld	s9,456(sp)
    800058ca:	6d1e                	ld	s10,448(sp)
    800058cc:	7dfa                	ld	s11,440(sp)
    800058ce:	22010113          	addi	sp,sp,544
    800058d2:	8082                	ret
    end_op();
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	298080e7          	jalr	664(ra) # 80004b6c <end_op>
    return -1;
    800058dc:	557d                	li	a0,-1
    800058de:	b7f9                	j	800058ac <exec+0xac>
  if((pagetable = proc_pagetable(p)) == 0)
    800058e0:	8526                	mv	a0,s1
    800058e2:	ffffc097          	auipc	ra,0xffffc
    800058e6:	7a2080e7          	jalr	1954(ra) # 80002084 <proc_pagetable>
    800058ea:	8b2a                	mv	s6,a0
    800058ec:	d555                	beqz	a0,80005898 <exec+0x98>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800058ee:	e6842783          	lw	a5,-408(s0)
    800058f2:	e8045703          	lhu	a4,-384(s0)
    800058f6:	c735                	beqz	a4,80005962 <exec+0x162>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800058f8:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800058fa:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800058fe:	6a05                	lui	s4,0x1
    80005900:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005904:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005908:	6d85                	lui	s11,0x1
    8000590a:	7d7d                	lui	s10,0xfffff
    8000590c:	ac1d                	j	80005b42 <exec+0x342>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000590e:	00003517          	auipc	a0,0x3
    80005912:	f6a50513          	addi	a0,a0,-150 # 80008878 <syscalls+0x330>
    80005916:	ffffb097          	auipc	ra,0xffffb
    8000591a:	c14080e7          	jalr	-1004(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000591e:	874a                	mv	a4,s2
    80005920:	009c86bb          	addw	a3,s9,s1
    80005924:	4581                	li	a1,0
    80005926:	8556                	mv	a0,s5
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	75a080e7          	jalr	1882(ra) # 80004082 <readi>
    80005930:	2501                	sext.w	a0,a0
    80005932:	1aa91863          	bne	s2,a0,80005ae2 <exec+0x2e2>
  for(i = 0; i < sz; i += PGSIZE){
    80005936:	009d84bb          	addw	s1,s11,s1
    8000593a:	013d09bb          	addw	s3,s10,s3
    8000593e:	1f74f263          	bgeu	s1,s7,80005b22 <exec+0x322>
    pa = walkaddr(pagetable, va + i);
    80005942:	02049593          	slli	a1,s1,0x20
    80005946:	9181                	srli	a1,a1,0x20
    80005948:	95e2                	add	a1,a1,s8
    8000594a:	855a                	mv	a0,s6
    8000594c:	ffffb097          	auipc	ra,0xffffb
    80005950:	700080e7          	jalr	1792(ra) # 8000104c <walkaddr>
    80005954:	862a                	mv	a2,a0
    if(pa == 0)
    80005956:	dd45                	beqz	a0,8000590e <exec+0x10e>
      n = PGSIZE;
    80005958:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000595a:	fd49f2e3          	bgeu	s3,s4,8000591e <exec+0x11e>
      n = sz - i;
    8000595e:	894e                	mv	s2,s3
    80005960:	bf7d                	j	8000591e <exec+0x11e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005962:	4481                	li	s1,0
  iunlockput(ip);
    80005964:	8556                	mv	a0,s5
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	6ca080e7          	jalr	1738(ra) # 80004030 <iunlockput>
  end_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	1fe080e7          	jalr	510(ra) # 80004b6c <end_op>
  p = myproc();
    80005976:	ffffc097          	auipc	ra,0xffffc
    8000597a:	64a080e7          	jalr	1610(ra) # 80001fc0 <myproc>
    8000597e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005980:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005984:	6785                	lui	a5,0x1
    80005986:	17fd                	addi	a5,a5,-1
    80005988:	94be                	add	s1,s1,a5
    8000598a:	77fd                	lui	a5,0xfffff
    8000598c:	8fe5                	and	a5,a5,s1
    8000598e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005992:	6609                	lui	a2,0x2
    80005994:	963e                	add	a2,a2,a5
    80005996:	85be                	mv	a1,a5
    80005998:	855a                	mv	a0,s6
    8000599a:	ffffc097          	auipc	ra,0xffffc
    8000599e:	27e080e7          	jalr	638(ra) # 80001c18 <uvmalloc>
    800059a2:	8c2a                	mv	s8,a0
  ip = 0;
    800059a4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800059a6:	12050e63          	beqz	a0,80005ae2 <exec+0x2e2>
  uvmclear(pagetable, sz-2*PGSIZE);
    800059aa:	75f9                	lui	a1,0xffffe
    800059ac:	95aa                	add	a1,a1,a0
    800059ae:	855a                	mv	a0,s6
    800059b0:	ffffc097          	auipc	ra,0xffffc
    800059b4:	99c080e7          	jalr	-1636(ra) # 8000134c <uvmclear>
  stackbase = sp - PGSIZE;
    800059b8:	7afd                	lui	s5,0xfffff
    800059ba:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800059bc:	df043783          	ld	a5,-528(s0)
    800059c0:	6388                	ld	a0,0(a5)
    800059c2:	c925                	beqz	a0,80005a32 <exec+0x232>
    800059c4:	e8840993          	addi	s3,s0,-376
    800059c8:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    800059cc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800059ce:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800059d0:	ffffb097          	auipc	ra,0xffffb
    800059d4:	472080e7          	jalr	1138(ra) # 80000e42 <strlen>
    800059d8:	0015079b          	addiw	a5,a0,1
    800059dc:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800059e0:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800059e4:	13596363          	bltu	s2,s5,80005b0a <exec+0x30a>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800059e8:	df043d83          	ld	s11,-528(s0)
    800059ec:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800059f0:	8552                	mv	a0,s4
    800059f2:	ffffb097          	auipc	ra,0xffffb
    800059f6:	450080e7          	jalr	1104(ra) # 80000e42 <strlen>
    800059fa:	0015069b          	addiw	a3,a0,1
    800059fe:	8652                	mv	a2,s4
    80005a00:	85ca                	mv	a1,s2
    80005a02:	855a                	mv	a0,s6
    80005a04:	ffffc097          	auipc	ra,0xffffc
    80005a08:	97a080e7          	jalr	-1670(ra) # 8000137e <copyout>
    80005a0c:	10054363          	bltz	a0,80005b12 <exec+0x312>
    ustack[argc] = sp;
    80005a10:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005a14:	0485                	addi	s1,s1,1
    80005a16:	008d8793          	addi	a5,s11,8
    80005a1a:	def43823          	sd	a5,-528(s0)
    80005a1e:	008db503          	ld	a0,8(s11)
    80005a22:	c911                	beqz	a0,80005a36 <exec+0x236>
    if(argc >= MAXARG)
    80005a24:	09a1                	addi	s3,s3,8
    80005a26:	fb3c95e3          	bne	s9,s3,800059d0 <exec+0x1d0>
  sz = sz1;
    80005a2a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005a2e:	4a81                	li	s5,0
    80005a30:	a84d                	j	80005ae2 <exec+0x2e2>
  sp = sz;
    80005a32:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005a34:	4481                	li	s1,0
  ustack[argc] = 0;
    80005a36:	00349793          	slli	a5,s1,0x3
    80005a3a:	f9040713          	addi	a4,s0,-112
    80005a3e:	97ba                	add	a5,a5,a4
    80005a40:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffc8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005a44:	00148693          	addi	a3,s1,1
    80005a48:	068e                	slli	a3,a3,0x3
    80005a4a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005a4e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005a52:	01597663          	bgeu	s2,s5,80005a5e <exec+0x25e>
  sz = sz1;
    80005a56:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005a5a:	4a81                	li	s5,0
    80005a5c:	a059                	j	80005ae2 <exec+0x2e2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005a5e:	e8840613          	addi	a2,s0,-376
    80005a62:	85ca                	mv	a1,s2
    80005a64:	855a                	mv	a0,s6
    80005a66:	ffffc097          	auipc	ra,0xffffc
    80005a6a:	918080e7          	jalr	-1768(ra) # 8000137e <copyout>
    80005a6e:	0a054663          	bltz	a0,80005b1a <exec+0x31a>
  p->trapframe->a1 = sp;
    80005a72:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005a76:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005a7a:	de843783          	ld	a5,-536(s0)
    80005a7e:	0007c703          	lbu	a4,0(a5)
    80005a82:	cf11                	beqz	a4,80005a9e <exec+0x29e>
    80005a84:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005a86:	02f00693          	li	a3,47
    80005a8a:	a039                	j	80005a98 <exec+0x298>
      last = s+1;
    80005a8c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005a90:	0785                	addi	a5,a5,1
    80005a92:	fff7c703          	lbu	a4,-1(a5)
    80005a96:	c701                	beqz	a4,80005a9e <exec+0x29e>
    if(*s == '/')
    80005a98:	fed71ce3          	bne	a4,a3,80005a90 <exec+0x290>
    80005a9c:	bfc5                	j	80005a8c <exec+0x28c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005a9e:	4641                	li	a2,16
    80005aa0:	de843583          	ld	a1,-536(s0)
    80005aa4:	158b8513          	addi	a0,s7,344
    80005aa8:	ffffb097          	auipc	ra,0xffffb
    80005aac:	368080e7          	jalr	872(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005ab0:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005ab4:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005ab8:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005abc:	058bb783          	ld	a5,88(s7)
    80005ac0:	e6043703          	ld	a4,-416(s0)
    80005ac4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005ac6:	058bb783          	ld	a5,88(s7)
    80005aca:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005ace:	85ea                	mv	a1,s10
    80005ad0:	ffffc097          	auipc	ra,0xffffc
    80005ad4:	68c080e7          	jalr	1676(ra) # 8000215c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005ad8:	0004851b          	sext.w	a0,s1
    80005adc:	bbc1                	j	800058ac <exec+0xac>
    80005ade:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005ae2:	df843583          	ld	a1,-520(s0)
    80005ae6:	855a                	mv	a0,s6
    80005ae8:	ffffc097          	auipc	ra,0xffffc
    80005aec:	674080e7          	jalr	1652(ra) # 8000215c <proc_freepagetable>
  if(ip){
    80005af0:	da0a94e3          	bnez	s5,80005898 <exec+0x98>
  return -1;
    80005af4:	557d                	li	a0,-1
    80005af6:	bb5d                	j	800058ac <exec+0xac>
    80005af8:	de943c23          	sd	s1,-520(s0)
    80005afc:	b7dd                	j	80005ae2 <exec+0x2e2>
    80005afe:	de943c23          	sd	s1,-520(s0)
    80005b02:	b7c5                	j	80005ae2 <exec+0x2e2>
    80005b04:	de943c23          	sd	s1,-520(s0)
    80005b08:	bfe9                	j	80005ae2 <exec+0x2e2>
  sz = sz1;
    80005b0a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005b0e:	4a81                	li	s5,0
    80005b10:	bfc9                	j	80005ae2 <exec+0x2e2>
  sz = sz1;
    80005b12:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005b16:	4a81                	li	s5,0
    80005b18:	b7e9                	j	80005ae2 <exec+0x2e2>
  sz = sz1;
    80005b1a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005b1e:	4a81                	li	s5,0
    80005b20:	b7c9                	j	80005ae2 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005b22:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b26:	e0843783          	ld	a5,-504(s0)
    80005b2a:	0017869b          	addiw	a3,a5,1
    80005b2e:	e0d43423          	sd	a3,-504(s0)
    80005b32:	e0043783          	ld	a5,-512(s0)
    80005b36:	0387879b          	addiw	a5,a5,56
    80005b3a:	e8045703          	lhu	a4,-384(s0)
    80005b3e:	e2e6d3e3          	bge	a3,a4,80005964 <exec+0x164>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005b42:	2781                	sext.w	a5,a5
    80005b44:	e0f43023          	sd	a5,-512(s0)
    80005b48:	03800713          	li	a4,56
    80005b4c:	86be                	mv	a3,a5
    80005b4e:	e1040613          	addi	a2,s0,-496
    80005b52:	4581                	li	a1,0
    80005b54:	8556                	mv	a0,s5
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	52c080e7          	jalr	1324(ra) # 80004082 <readi>
    80005b5e:	03800793          	li	a5,56
    80005b62:	f6f51ee3          	bne	a0,a5,80005ade <exec+0x2de>
    if(ph.type != ELF_PROG_LOAD)
    80005b66:	e1042783          	lw	a5,-496(s0)
    80005b6a:	4705                	li	a4,1
    80005b6c:	fae79de3          	bne	a5,a4,80005b26 <exec+0x326>
    if(ph.memsz < ph.filesz)
    80005b70:	e3843603          	ld	a2,-456(s0)
    80005b74:	e3043783          	ld	a5,-464(s0)
    80005b78:	f8f660e3          	bltu	a2,a5,80005af8 <exec+0x2f8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005b7c:	e2043783          	ld	a5,-480(s0)
    80005b80:	963e                	add	a2,a2,a5
    80005b82:	f6f66ee3          	bltu	a2,a5,80005afe <exec+0x2fe>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005b86:	85a6                	mv	a1,s1
    80005b88:	855a                	mv	a0,s6
    80005b8a:	ffffc097          	auipc	ra,0xffffc
    80005b8e:	08e080e7          	jalr	142(ra) # 80001c18 <uvmalloc>
    80005b92:	dea43c23          	sd	a0,-520(s0)
    80005b96:	d53d                	beqz	a0,80005b04 <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    80005b98:	e2043c03          	ld	s8,-480(s0)
    80005b9c:	de043783          	ld	a5,-544(s0)
    80005ba0:	00fc77b3          	and	a5,s8,a5
    80005ba4:	ff9d                	bnez	a5,80005ae2 <exec+0x2e2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005ba6:	e1842c83          	lw	s9,-488(s0)
    80005baa:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005bae:	f60b8ae3          	beqz	s7,80005b22 <exec+0x322>
    80005bb2:	89de                	mv	s3,s7
    80005bb4:	4481                	li	s1,0
    80005bb6:	b371                	j	80005942 <exec+0x142>

0000000080005bb8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005bb8:	7179                	addi	sp,sp,-48
    80005bba:	f406                	sd	ra,40(sp)
    80005bbc:	f022                	sd	s0,32(sp)
    80005bbe:	ec26                	sd	s1,24(sp)
    80005bc0:	e84a                	sd	s2,16(sp)
    80005bc2:	1800                	addi	s0,sp,48
    80005bc4:	892e                	mv	s2,a1
    80005bc6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005bc8:	fdc40593          	addi	a1,s0,-36
    80005bcc:	ffffd097          	auipc	ra,0xffffd
    80005bd0:	676080e7          	jalr	1654(ra) # 80003242 <argint>
    80005bd4:	04054063          	bltz	a0,80005c14 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005bd8:	fdc42703          	lw	a4,-36(s0)
    80005bdc:	47bd                	li	a5,15
    80005bde:	02e7ed63          	bltu	a5,a4,80005c18 <argfd+0x60>
    80005be2:	ffffc097          	auipc	ra,0xffffc
    80005be6:	3de080e7          	jalr	990(ra) # 80001fc0 <myproc>
    80005bea:	fdc42703          	lw	a4,-36(s0)
    80005bee:	01a70793          	addi	a5,a4,26
    80005bf2:	078e                	slli	a5,a5,0x3
    80005bf4:	953e                	add	a0,a0,a5
    80005bf6:	611c                	ld	a5,0(a0)
    80005bf8:	c395                	beqz	a5,80005c1c <argfd+0x64>
    return -1;
  if(pfd)
    80005bfa:	00090463          	beqz	s2,80005c02 <argfd+0x4a>
    *pfd = fd;
    80005bfe:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005c02:	4501                	li	a0,0
  if(pf)
    80005c04:	c091                	beqz	s1,80005c08 <argfd+0x50>
    *pf = f;
    80005c06:	e09c                	sd	a5,0(s1)
}
    80005c08:	70a2                	ld	ra,40(sp)
    80005c0a:	7402                	ld	s0,32(sp)
    80005c0c:	64e2                	ld	s1,24(sp)
    80005c0e:	6942                	ld	s2,16(sp)
    80005c10:	6145                	addi	sp,sp,48
    80005c12:	8082                	ret
    return -1;
    80005c14:	557d                	li	a0,-1
    80005c16:	bfcd                	j	80005c08 <argfd+0x50>
    return -1;
    80005c18:	557d                	li	a0,-1
    80005c1a:	b7fd                	j	80005c08 <argfd+0x50>
    80005c1c:	557d                	li	a0,-1
    80005c1e:	b7ed                	j	80005c08 <argfd+0x50>

0000000080005c20 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005c20:	1101                	addi	sp,sp,-32
    80005c22:	ec06                	sd	ra,24(sp)
    80005c24:	e822                	sd	s0,16(sp)
    80005c26:	e426                	sd	s1,8(sp)
    80005c28:	1000                	addi	s0,sp,32
    80005c2a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005c2c:	ffffc097          	auipc	ra,0xffffc
    80005c30:	394080e7          	jalr	916(ra) # 80001fc0 <myproc>
    80005c34:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005c36:	0d050793          	addi	a5,a0,208
    80005c3a:	4501                	li	a0,0
    80005c3c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005c3e:	6398                	ld	a4,0(a5)
    80005c40:	cb19                	beqz	a4,80005c56 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005c42:	2505                	addiw	a0,a0,1
    80005c44:	07a1                	addi	a5,a5,8
    80005c46:	fed51ce3          	bne	a0,a3,80005c3e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005c4a:	557d                	li	a0,-1
}
    80005c4c:	60e2                	ld	ra,24(sp)
    80005c4e:	6442                	ld	s0,16(sp)
    80005c50:	64a2                	ld	s1,8(sp)
    80005c52:	6105                	addi	sp,sp,32
    80005c54:	8082                	ret
      p->ofile[fd] = f;
    80005c56:	01a50793          	addi	a5,a0,26
    80005c5a:	078e                	slli	a5,a5,0x3
    80005c5c:	963e                	add	a2,a2,a5
    80005c5e:	e204                	sd	s1,0(a2)
      return fd;
    80005c60:	b7f5                	j	80005c4c <fdalloc+0x2c>

0000000080005c62 <sys_dup>:

uint64
sys_dup(void)
{
    80005c62:	7179                	addi	sp,sp,-48
    80005c64:	f406                	sd	ra,40(sp)
    80005c66:	f022                	sd	s0,32(sp)
    80005c68:	ec26                	sd	s1,24(sp)
    80005c6a:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005c6c:	fd840613          	addi	a2,s0,-40
    80005c70:	4581                	li	a1,0
    80005c72:	4501                	li	a0,0
    80005c74:	00000097          	auipc	ra,0x0
    80005c78:	f44080e7          	jalr	-188(ra) # 80005bb8 <argfd>
    return -1;
    80005c7c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005c7e:	02054363          	bltz	a0,80005ca4 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005c82:	fd843503          	ld	a0,-40(s0)
    80005c86:	00000097          	auipc	ra,0x0
    80005c8a:	f9a080e7          	jalr	-102(ra) # 80005c20 <fdalloc>
    80005c8e:	84aa                	mv	s1,a0
    return -1;
    80005c90:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005c92:	00054963          	bltz	a0,80005ca4 <sys_dup+0x42>
  filedup(f);
    80005c96:	fd843503          	ld	a0,-40(s0)
    80005c9a:	fffff097          	auipc	ra,0xfffff
    80005c9e:	2cc080e7          	jalr	716(ra) # 80004f66 <filedup>
  return fd;
    80005ca2:	87a6                	mv	a5,s1
}
    80005ca4:	853e                	mv	a0,a5
    80005ca6:	70a2                	ld	ra,40(sp)
    80005ca8:	7402                	ld	s0,32(sp)
    80005caa:	64e2                	ld	s1,24(sp)
    80005cac:	6145                	addi	sp,sp,48
    80005cae:	8082                	ret

0000000080005cb0 <sys_read>:

uint64
sys_read(void)
{
    80005cb0:	7179                	addi	sp,sp,-48
    80005cb2:	f406                	sd	ra,40(sp)
    80005cb4:	f022                	sd	s0,32(sp)
    80005cb6:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005cb8:	fe840613          	addi	a2,s0,-24
    80005cbc:	4581                	li	a1,0
    80005cbe:	4501                	li	a0,0
    80005cc0:	00000097          	auipc	ra,0x0
    80005cc4:	ef8080e7          	jalr	-264(ra) # 80005bb8 <argfd>
    return -1;
    80005cc8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005cca:	04054163          	bltz	a0,80005d0c <sys_read+0x5c>
    80005cce:	fe440593          	addi	a1,s0,-28
    80005cd2:	4509                	li	a0,2
    80005cd4:	ffffd097          	auipc	ra,0xffffd
    80005cd8:	56e080e7          	jalr	1390(ra) # 80003242 <argint>
    return -1;
    80005cdc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005cde:	02054763          	bltz	a0,80005d0c <sys_read+0x5c>
    80005ce2:	fd840593          	addi	a1,s0,-40
    80005ce6:	4505                	li	a0,1
    80005ce8:	ffffd097          	auipc	ra,0xffffd
    80005cec:	57c080e7          	jalr	1404(ra) # 80003264 <argaddr>
    return -1;
    80005cf0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005cf2:	00054d63          	bltz	a0,80005d0c <sys_read+0x5c>
  return fileread(f, p, n);
    80005cf6:	fe442603          	lw	a2,-28(s0)
    80005cfa:	fd843583          	ld	a1,-40(s0)
    80005cfe:	fe843503          	ld	a0,-24(s0)
    80005d02:	fffff097          	auipc	ra,0xfffff
    80005d06:	3f0080e7          	jalr	1008(ra) # 800050f2 <fileread>
    80005d0a:	87aa                	mv	a5,a0
}
    80005d0c:	853e                	mv	a0,a5
    80005d0e:	70a2                	ld	ra,40(sp)
    80005d10:	7402                	ld	s0,32(sp)
    80005d12:	6145                	addi	sp,sp,48
    80005d14:	8082                	ret

0000000080005d16 <sys_write>:

uint64
sys_write(void)
{
    80005d16:	7179                	addi	sp,sp,-48
    80005d18:	f406                	sd	ra,40(sp)
    80005d1a:	f022                	sd	s0,32(sp)
    80005d1c:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005d1e:	fe840613          	addi	a2,s0,-24
    80005d22:	4581                	li	a1,0
    80005d24:	4501                	li	a0,0
    80005d26:	00000097          	auipc	ra,0x0
    80005d2a:	e92080e7          	jalr	-366(ra) # 80005bb8 <argfd>
    return -1;
    80005d2e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005d30:	04054163          	bltz	a0,80005d72 <sys_write+0x5c>
    80005d34:	fe440593          	addi	a1,s0,-28
    80005d38:	4509                	li	a0,2
    80005d3a:	ffffd097          	auipc	ra,0xffffd
    80005d3e:	508080e7          	jalr	1288(ra) # 80003242 <argint>
    return -1;
    80005d42:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005d44:	02054763          	bltz	a0,80005d72 <sys_write+0x5c>
    80005d48:	fd840593          	addi	a1,s0,-40
    80005d4c:	4505                	li	a0,1
    80005d4e:	ffffd097          	auipc	ra,0xffffd
    80005d52:	516080e7          	jalr	1302(ra) # 80003264 <argaddr>
    return -1;
    80005d56:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005d58:	00054d63          	bltz	a0,80005d72 <sys_write+0x5c>

  return filewrite(f, p, n);
    80005d5c:	fe442603          	lw	a2,-28(s0)
    80005d60:	fd843583          	ld	a1,-40(s0)
    80005d64:	fe843503          	ld	a0,-24(s0)
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	44c080e7          	jalr	1100(ra) # 800051b4 <filewrite>
    80005d70:	87aa                	mv	a5,a0
}
    80005d72:	853e                	mv	a0,a5
    80005d74:	70a2                	ld	ra,40(sp)
    80005d76:	7402                	ld	s0,32(sp)
    80005d78:	6145                	addi	sp,sp,48
    80005d7a:	8082                	ret

0000000080005d7c <sys_close>:

uint64
sys_close(void)
{
    80005d7c:	1101                	addi	sp,sp,-32
    80005d7e:	ec06                	sd	ra,24(sp)
    80005d80:	e822                	sd	s0,16(sp)
    80005d82:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005d84:	fe040613          	addi	a2,s0,-32
    80005d88:	fec40593          	addi	a1,s0,-20
    80005d8c:	4501                	li	a0,0
    80005d8e:	00000097          	auipc	ra,0x0
    80005d92:	e2a080e7          	jalr	-470(ra) # 80005bb8 <argfd>
    return -1;
    80005d96:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005d98:	02054463          	bltz	a0,80005dc0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005d9c:	ffffc097          	auipc	ra,0xffffc
    80005da0:	224080e7          	jalr	548(ra) # 80001fc0 <myproc>
    80005da4:	fec42783          	lw	a5,-20(s0)
    80005da8:	07e9                	addi	a5,a5,26
    80005daa:	078e                	slli	a5,a5,0x3
    80005dac:	97aa                	add	a5,a5,a0
    80005dae:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005db2:	fe043503          	ld	a0,-32(s0)
    80005db6:	fffff097          	auipc	ra,0xfffff
    80005dba:	202080e7          	jalr	514(ra) # 80004fb8 <fileclose>
  return 0;
    80005dbe:	4781                	li	a5,0
}
    80005dc0:	853e                	mv	a0,a5
    80005dc2:	60e2                	ld	ra,24(sp)
    80005dc4:	6442                	ld	s0,16(sp)
    80005dc6:	6105                	addi	sp,sp,32
    80005dc8:	8082                	ret

0000000080005dca <sys_fstat>:

uint64
sys_fstat(void)
{
    80005dca:	1101                	addi	sp,sp,-32
    80005dcc:	ec06                	sd	ra,24(sp)
    80005dce:	e822                	sd	s0,16(sp)
    80005dd0:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005dd2:	fe840613          	addi	a2,s0,-24
    80005dd6:	4581                	li	a1,0
    80005dd8:	4501                	li	a0,0
    80005dda:	00000097          	auipc	ra,0x0
    80005dde:	dde080e7          	jalr	-546(ra) # 80005bb8 <argfd>
    return -1;
    80005de2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005de4:	02054563          	bltz	a0,80005e0e <sys_fstat+0x44>
    80005de8:	fe040593          	addi	a1,s0,-32
    80005dec:	4505                	li	a0,1
    80005dee:	ffffd097          	auipc	ra,0xffffd
    80005df2:	476080e7          	jalr	1142(ra) # 80003264 <argaddr>
    return -1;
    80005df6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005df8:	00054b63          	bltz	a0,80005e0e <sys_fstat+0x44>
  return filestat(f, st);
    80005dfc:	fe043583          	ld	a1,-32(s0)
    80005e00:	fe843503          	ld	a0,-24(s0)
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	27c080e7          	jalr	636(ra) # 80005080 <filestat>
    80005e0c:	87aa                	mv	a5,a0
}
    80005e0e:	853e                	mv	a0,a5
    80005e10:	60e2                	ld	ra,24(sp)
    80005e12:	6442                	ld	s0,16(sp)
    80005e14:	6105                	addi	sp,sp,32
    80005e16:	8082                	ret

0000000080005e18 <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80005e18:	7169                	addi	sp,sp,-304
    80005e1a:	f606                	sd	ra,296(sp)
    80005e1c:	f222                	sd	s0,288(sp)
    80005e1e:	ee26                	sd	s1,280(sp)
    80005e20:	ea4a                	sd	s2,272(sp)
    80005e22:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e24:	08000613          	li	a2,128
    80005e28:	ed040593          	addi	a1,s0,-304
    80005e2c:	4501                	li	a0,0
    80005e2e:	ffffd097          	auipc	ra,0xffffd
    80005e32:	458080e7          	jalr	1112(ra) # 80003286 <argstr>
    return -1;
    80005e36:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e38:	10054e63          	bltz	a0,80005f54 <sys_link+0x13c>
    80005e3c:	08000613          	li	a2,128
    80005e40:	f5040593          	addi	a1,s0,-176
    80005e44:	4505                	li	a0,1
    80005e46:	ffffd097          	auipc	ra,0xffffd
    80005e4a:	440080e7          	jalr	1088(ra) # 80003286 <argstr>
    return -1;
    80005e4e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e50:	10054263          	bltz	a0,80005f54 <sys_link+0x13c>

  begin_op();
    80005e54:	fffff097          	auipc	ra,0xfffff
    80005e58:	c98080e7          	jalr	-872(ra) # 80004aec <begin_op>
  if((ip = namei(old)) == 0){
    80005e5c:	ed040513          	addi	a0,s0,-304
    80005e60:	ffffe097          	auipc	ra,0xffffe
    80005e64:	724080e7          	jalr	1828(ra) # 80004584 <namei>
    80005e68:	84aa                	mv	s1,a0
    80005e6a:	c551                	beqz	a0,80005ef6 <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    80005e6c:	ffffe097          	auipc	ra,0xffffe
    80005e70:	f62080e7          	jalr	-158(ra) # 80003dce <ilock>
  if(ip->type == T_DIR){
    80005e74:	04449703          	lh	a4,68(s1)
    80005e78:	4785                	li	a5,1
    80005e7a:	08f70463          	beq	a4,a5,80005f02 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80005e7e:	04a4d783          	lhu	a5,74(s1)
    80005e82:	2785                	addiw	a5,a5,1
    80005e84:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005e88:	8526                	mv	a0,s1
    80005e8a:	ffffe097          	auipc	ra,0xffffe
    80005e8e:	e7a080e7          	jalr	-390(ra) # 80003d04 <iupdate>
  iunlock(ip);
    80005e92:	8526                	mv	a0,s1
    80005e94:	ffffe097          	auipc	ra,0xffffe
    80005e98:	ffc080e7          	jalr	-4(ra) # 80003e90 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    80005e9c:	fd040593          	addi	a1,s0,-48
    80005ea0:	f5040513          	addi	a0,s0,-176
    80005ea4:	ffffe097          	auipc	ra,0xffffe
    80005ea8:	6fe080e7          	jalr	1790(ra) # 800045a2 <nameiparent>
    80005eac:	892a                	mv	s2,a0
    80005eae:	c935                	beqz	a0,80005f22 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80005eb0:	ffffe097          	auipc	ra,0xffffe
    80005eb4:	f1e080e7          	jalr	-226(ra) # 80003dce <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005eb8:	00092703          	lw	a4,0(s2)
    80005ebc:	409c                	lw	a5,0(s1)
    80005ebe:	04f71d63          	bne	a4,a5,80005f18 <sys_link+0x100>
    80005ec2:	40d0                	lw	a2,4(s1)
    80005ec4:	fd040593          	addi	a1,s0,-48
    80005ec8:	854a                	mv	a0,s2
    80005eca:	ffffe097          	auipc	ra,0xffffe
    80005ece:	5f8080e7          	jalr	1528(ra) # 800044c2 <dirlink>
    80005ed2:	04054363          	bltz	a0,80005f18 <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    80005ed6:	854a                	mv	a0,s2
    80005ed8:	ffffe097          	auipc	ra,0xffffe
    80005edc:	158080e7          	jalr	344(ra) # 80004030 <iunlockput>
  iput(ip);
    80005ee0:	8526                	mv	a0,s1
    80005ee2:	ffffe097          	auipc	ra,0xffffe
    80005ee6:	0a6080e7          	jalr	166(ra) # 80003f88 <iput>

  end_op();
    80005eea:	fffff097          	auipc	ra,0xfffff
    80005eee:	c82080e7          	jalr	-894(ra) # 80004b6c <end_op>

  return 0;
    80005ef2:	4781                	li	a5,0
    80005ef4:	a085                	j	80005f54 <sys_link+0x13c>
    end_op();
    80005ef6:	fffff097          	auipc	ra,0xfffff
    80005efa:	c76080e7          	jalr	-906(ra) # 80004b6c <end_op>
    return -1;
    80005efe:	57fd                	li	a5,-1
    80005f00:	a891                	j	80005f54 <sys_link+0x13c>
    iunlockput(ip);
    80005f02:	8526                	mv	a0,s1
    80005f04:	ffffe097          	auipc	ra,0xffffe
    80005f08:	12c080e7          	jalr	300(ra) # 80004030 <iunlockput>
    end_op();
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	c60080e7          	jalr	-928(ra) # 80004b6c <end_op>
    return -1;
    80005f14:	57fd                	li	a5,-1
    80005f16:	a83d                	j	80005f54 <sys_link+0x13c>
    iunlockput(dp);
    80005f18:	854a                	mv	a0,s2
    80005f1a:	ffffe097          	auipc	ra,0xffffe
    80005f1e:	116080e7          	jalr	278(ra) # 80004030 <iunlockput>

bad:
  ilock(ip);
    80005f22:	8526                	mv	a0,s1
    80005f24:	ffffe097          	auipc	ra,0xffffe
    80005f28:	eaa080e7          	jalr	-342(ra) # 80003dce <ilock>
  ip->nlink--;
    80005f2c:	04a4d783          	lhu	a5,74(s1)
    80005f30:	37fd                	addiw	a5,a5,-1
    80005f32:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005f36:	8526                	mv	a0,s1
    80005f38:	ffffe097          	auipc	ra,0xffffe
    80005f3c:	dcc080e7          	jalr	-564(ra) # 80003d04 <iupdate>
  iunlockput(ip);
    80005f40:	8526                	mv	a0,s1
    80005f42:	ffffe097          	auipc	ra,0xffffe
    80005f46:	0ee080e7          	jalr	238(ra) # 80004030 <iunlockput>
  end_op();
    80005f4a:	fffff097          	auipc	ra,0xfffff
    80005f4e:	c22080e7          	jalr	-990(ra) # 80004b6c <end_op>
  return -1;
    80005f52:	57fd                	li	a5,-1
}
    80005f54:	853e                	mv	a0,a5
    80005f56:	70b2                	ld	ra,296(sp)
    80005f58:	7412                	ld	s0,288(sp)
    80005f5a:	64f2                	ld	s1,280(sp)
    80005f5c:	6952                	ld	s2,272(sp)
    80005f5e:	6155                	addi	sp,sp,304
    80005f60:	8082                	ret

0000000080005f62 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f62:	4578                	lw	a4,76(a0)
    80005f64:	02000793          	li	a5,32
    80005f68:	04e7fa63          	bgeu	a5,a4,80005fbc <isdirempty+0x5a>
{
    80005f6c:	7179                	addi	sp,sp,-48
    80005f6e:	f406                	sd	ra,40(sp)
    80005f70:	f022                	sd	s0,32(sp)
    80005f72:	ec26                	sd	s1,24(sp)
    80005f74:	e84a                	sd	s2,16(sp)
    80005f76:	1800                	addi	s0,sp,48
    80005f78:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f7a:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f7e:	4741                	li	a4,16
    80005f80:	86a6                	mv	a3,s1
    80005f82:	fd040613          	addi	a2,s0,-48
    80005f86:	4581                	li	a1,0
    80005f88:	854a                	mv	a0,s2
    80005f8a:	ffffe097          	auipc	ra,0xffffe
    80005f8e:	0f8080e7          	jalr	248(ra) # 80004082 <readi>
    80005f92:	47c1                	li	a5,16
    80005f94:	00f51c63          	bne	a0,a5,80005fac <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    80005f98:	fd045783          	lhu	a5,-48(s0)
    80005f9c:	e395                	bnez	a5,80005fc0 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f9e:	24c1                	addiw	s1,s1,16
    80005fa0:	04c92783          	lw	a5,76(s2)
    80005fa4:	fcf4ede3          	bltu	s1,a5,80005f7e <isdirempty+0x1c>
      return 0;
  }
  return 1;
    80005fa8:	4505                	li	a0,1
    80005faa:	a821                	j	80005fc2 <isdirempty+0x60>
      panic("isdirempty: readi");
    80005fac:	00003517          	auipc	a0,0x3
    80005fb0:	8ec50513          	addi	a0,a0,-1812 # 80008898 <syscalls+0x350>
    80005fb4:	ffffa097          	auipc	ra,0xffffa
    80005fb8:	576080e7          	jalr	1398(ra) # 8000052a <panic>
  return 1;
    80005fbc:	4505                	li	a0,1
}
    80005fbe:	8082                	ret
      return 0;
    80005fc0:	4501                	li	a0,0
}
    80005fc2:	70a2                	ld	ra,40(sp)
    80005fc4:	7402                	ld	s0,32(sp)
    80005fc6:	64e2                	ld	s1,24(sp)
    80005fc8:	6942                	ld	s2,16(sp)
    80005fca:	6145                	addi	sp,sp,48
    80005fcc:	8082                	ret

0000000080005fce <sys_unlink>:

uint64
sys_unlink(void)
{
    80005fce:	7155                	addi	sp,sp,-208
    80005fd0:	e586                	sd	ra,200(sp)
    80005fd2:	e1a2                	sd	s0,192(sp)
    80005fd4:	fd26                	sd	s1,184(sp)
    80005fd6:	f94a                	sd	s2,176(sp)
    80005fd8:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    80005fda:	08000613          	li	a2,128
    80005fde:	f4040593          	addi	a1,s0,-192
    80005fe2:	4501                	li	a0,0
    80005fe4:	ffffd097          	auipc	ra,0xffffd
    80005fe8:	2a2080e7          	jalr	674(ra) # 80003286 <argstr>
    80005fec:	16054363          	bltz	a0,80006152 <sys_unlink+0x184>
    return -1;

  begin_op();
    80005ff0:	fffff097          	auipc	ra,0xfffff
    80005ff4:	afc080e7          	jalr	-1284(ra) # 80004aec <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ff8:	fc040593          	addi	a1,s0,-64
    80005ffc:	f4040513          	addi	a0,s0,-192
    80006000:	ffffe097          	auipc	ra,0xffffe
    80006004:	5a2080e7          	jalr	1442(ra) # 800045a2 <nameiparent>
    80006008:	84aa                	mv	s1,a0
    8000600a:	c961                	beqz	a0,800060da <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    8000600c:	ffffe097          	auipc	ra,0xffffe
    80006010:	dc2080e7          	jalr	-574(ra) # 80003dce <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006014:	00002597          	auipc	a1,0x2
    80006018:	72c58593          	addi	a1,a1,1836 # 80008740 <syscalls+0x1f8>
    8000601c:	fc040513          	addi	a0,s0,-64
    80006020:	ffffe097          	auipc	ra,0xffffe
    80006024:	278080e7          	jalr	632(ra) # 80004298 <namecmp>
    80006028:	c175                	beqz	a0,8000610c <sys_unlink+0x13e>
    8000602a:	00002597          	auipc	a1,0x2
    8000602e:	71e58593          	addi	a1,a1,1822 # 80008748 <syscalls+0x200>
    80006032:	fc040513          	addi	a0,s0,-64
    80006036:	ffffe097          	auipc	ra,0xffffe
    8000603a:	262080e7          	jalr	610(ra) # 80004298 <namecmp>
    8000603e:	c579                	beqz	a0,8000610c <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80006040:	f3c40613          	addi	a2,s0,-196
    80006044:	fc040593          	addi	a1,s0,-64
    80006048:	8526                	mv	a0,s1
    8000604a:	ffffe097          	auipc	ra,0xffffe
    8000604e:	268080e7          	jalr	616(ra) # 800042b2 <dirlookup>
    80006052:	892a                	mv	s2,a0
    80006054:	cd45                	beqz	a0,8000610c <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    80006056:	ffffe097          	auipc	ra,0xffffe
    8000605a:	d78080e7          	jalr	-648(ra) # 80003dce <ilock>

  if(ip->nlink < 1)
    8000605e:	04a91783          	lh	a5,74(s2)
    80006062:	08f05263          	blez	a5,800060e6 <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006066:	04491703          	lh	a4,68(s2)
    8000606a:	4785                	li	a5,1
    8000606c:	08f70563          	beq	a4,a5,800060f6 <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80006070:	4641                	li	a2,16
    80006072:	4581                	li	a1,0
    80006074:	fd040513          	addi	a0,s0,-48
    80006078:	ffffb097          	auipc	ra,0xffffb
    8000607c:	c46080e7          	jalr	-954(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006080:	4741                	li	a4,16
    80006082:	f3c42683          	lw	a3,-196(s0)
    80006086:	fd040613          	addi	a2,s0,-48
    8000608a:	4581                	li	a1,0
    8000608c:	8526                	mv	a0,s1
    8000608e:	ffffe097          	auipc	ra,0xffffe
    80006092:	0ec080e7          	jalr	236(ra) # 8000417a <writei>
    80006096:	47c1                	li	a5,16
    80006098:	08f51a63          	bne	a0,a5,8000612c <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    8000609c:	04491703          	lh	a4,68(s2)
    800060a0:	4785                	li	a5,1
    800060a2:	08f70d63          	beq	a4,a5,8000613c <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800060a6:	8526                	mv	a0,s1
    800060a8:	ffffe097          	auipc	ra,0xffffe
    800060ac:	f88080e7          	jalr	-120(ra) # 80004030 <iunlockput>

  ip->nlink--;
    800060b0:	04a95783          	lhu	a5,74(s2)
    800060b4:	37fd                	addiw	a5,a5,-1
    800060b6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800060ba:	854a                	mv	a0,s2
    800060bc:	ffffe097          	auipc	ra,0xffffe
    800060c0:	c48080e7          	jalr	-952(ra) # 80003d04 <iupdate>
  iunlockput(ip);
    800060c4:	854a                	mv	a0,s2
    800060c6:	ffffe097          	auipc	ra,0xffffe
    800060ca:	f6a080e7          	jalr	-150(ra) # 80004030 <iunlockput>

  end_op();
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	a9e080e7          	jalr	-1378(ra) # 80004b6c <end_op>

  return 0;
    800060d6:	4501                	li	a0,0
    800060d8:	a0a1                	j	80006120 <sys_unlink+0x152>
    end_op();
    800060da:	fffff097          	auipc	ra,0xfffff
    800060de:	a92080e7          	jalr	-1390(ra) # 80004b6c <end_op>
    return -1;
    800060e2:	557d                	li	a0,-1
    800060e4:	a835                	j	80006120 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    800060e6:	00002517          	auipc	a0,0x2
    800060ea:	66a50513          	addi	a0,a0,1642 # 80008750 <syscalls+0x208>
    800060ee:	ffffa097          	auipc	ra,0xffffa
    800060f2:	43c080e7          	jalr	1084(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800060f6:	854a                	mv	a0,s2
    800060f8:	00000097          	auipc	ra,0x0
    800060fc:	e6a080e7          	jalr	-406(ra) # 80005f62 <isdirempty>
    80006100:	f925                	bnez	a0,80006070 <sys_unlink+0xa2>
    iunlockput(ip);
    80006102:	854a                	mv	a0,s2
    80006104:	ffffe097          	auipc	ra,0xffffe
    80006108:	f2c080e7          	jalr	-212(ra) # 80004030 <iunlockput>

bad:
  iunlockput(dp);
    8000610c:	8526                	mv	a0,s1
    8000610e:	ffffe097          	auipc	ra,0xffffe
    80006112:	f22080e7          	jalr	-222(ra) # 80004030 <iunlockput>
  end_op();
    80006116:	fffff097          	auipc	ra,0xfffff
    8000611a:	a56080e7          	jalr	-1450(ra) # 80004b6c <end_op>
  return -1;
    8000611e:	557d                	li	a0,-1
}
    80006120:	60ae                	ld	ra,200(sp)
    80006122:	640e                	ld	s0,192(sp)
    80006124:	74ea                	ld	s1,184(sp)
    80006126:	794a                	ld	s2,176(sp)
    80006128:	6169                	addi	sp,sp,208
    8000612a:	8082                	ret
    panic("unlink: writei");
    8000612c:	00002517          	auipc	a0,0x2
    80006130:	63c50513          	addi	a0,a0,1596 # 80008768 <syscalls+0x220>
    80006134:	ffffa097          	auipc	ra,0xffffa
    80006138:	3f6080e7          	jalr	1014(ra) # 8000052a <panic>
    dp->nlink--;
    8000613c:	04a4d783          	lhu	a5,74(s1)
    80006140:	37fd                	addiw	a5,a5,-1
    80006142:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006146:	8526                	mv	a0,s1
    80006148:	ffffe097          	auipc	ra,0xffffe
    8000614c:	bbc080e7          	jalr	-1092(ra) # 80003d04 <iupdate>
    80006150:	bf99                	j	800060a6 <sys_unlink+0xd8>
    return -1;
    80006152:	557d                	li	a0,-1
    80006154:	b7f1                	j	80006120 <sys_unlink+0x152>

0000000080006156 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    80006156:	715d                	addi	sp,sp,-80
    80006158:	e486                	sd	ra,72(sp)
    8000615a:	e0a2                	sd	s0,64(sp)
    8000615c:	fc26                	sd	s1,56(sp)
    8000615e:	f84a                	sd	s2,48(sp)
    80006160:	f44e                	sd	s3,40(sp)
    80006162:	f052                	sd	s4,32(sp)
    80006164:	ec56                	sd	s5,24(sp)
    80006166:	0880                	addi	s0,sp,80
    80006168:	89ae                	mv	s3,a1
    8000616a:	8ab2                	mv	s5,a2
    8000616c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000616e:	fb040593          	addi	a1,s0,-80
    80006172:	ffffe097          	auipc	ra,0xffffe
    80006176:	430080e7          	jalr	1072(ra) # 800045a2 <nameiparent>
    8000617a:	892a                	mv	s2,a0
    8000617c:	12050e63          	beqz	a0,800062b8 <create+0x162>
    return 0;

  ilock(dp);
    80006180:	ffffe097          	auipc	ra,0xffffe
    80006184:	c4e080e7          	jalr	-946(ra) # 80003dce <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    80006188:	4601                	li	a2,0
    8000618a:	fb040593          	addi	a1,s0,-80
    8000618e:	854a                	mv	a0,s2
    80006190:	ffffe097          	auipc	ra,0xffffe
    80006194:	122080e7          	jalr	290(ra) # 800042b2 <dirlookup>
    80006198:	84aa                	mv	s1,a0
    8000619a:	c921                	beqz	a0,800061ea <create+0x94>
    iunlockput(dp);
    8000619c:	854a                	mv	a0,s2
    8000619e:	ffffe097          	auipc	ra,0xffffe
    800061a2:	e92080e7          	jalr	-366(ra) # 80004030 <iunlockput>
    ilock(ip);
    800061a6:	8526                	mv	a0,s1
    800061a8:	ffffe097          	auipc	ra,0xffffe
    800061ac:	c26080e7          	jalr	-986(ra) # 80003dce <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800061b0:	2981                	sext.w	s3,s3
    800061b2:	4789                	li	a5,2
    800061b4:	02f99463          	bne	s3,a5,800061dc <create+0x86>
    800061b8:	0444d783          	lhu	a5,68(s1)
    800061bc:	37f9                	addiw	a5,a5,-2
    800061be:	17c2                	slli	a5,a5,0x30
    800061c0:	93c1                	srli	a5,a5,0x30
    800061c2:	4705                	li	a4,1
    800061c4:	00f76c63          	bltu	a4,a5,800061dc <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800061c8:	8526                	mv	a0,s1
    800061ca:	60a6                	ld	ra,72(sp)
    800061cc:	6406                	ld	s0,64(sp)
    800061ce:	74e2                	ld	s1,56(sp)
    800061d0:	7942                	ld	s2,48(sp)
    800061d2:	79a2                	ld	s3,40(sp)
    800061d4:	7a02                	ld	s4,32(sp)
    800061d6:	6ae2                	ld	s5,24(sp)
    800061d8:	6161                	addi	sp,sp,80
    800061da:	8082                	ret
    iunlockput(ip);
    800061dc:	8526                	mv	a0,s1
    800061de:	ffffe097          	auipc	ra,0xffffe
    800061e2:	e52080e7          	jalr	-430(ra) # 80004030 <iunlockput>
    return 0;
    800061e6:	4481                	li	s1,0
    800061e8:	b7c5                	j	800061c8 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800061ea:	85ce                	mv	a1,s3
    800061ec:	00092503          	lw	a0,0(s2)
    800061f0:	ffffe097          	auipc	ra,0xffffe
    800061f4:	a46080e7          	jalr	-1466(ra) # 80003c36 <ialloc>
    800061f8:	84aa                	mv	s1,a0
    800061fa:	c521                	beqz	a0,80006242 <create+0xec>
  ilock(ip);
    800061fc:	ffffe097          	auipc	ra,0xffffe
    80006200:	bd2080e7          	jalr	-1070(ra) # 80003dce <ilock>
  ip->major = major;
    80006204:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006208:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000620c:	4a05                	li	s4,1
    8000620e:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006212:	8526                	mv	a0,s1
    80006214:	ffffe097          	auipc	ra,0xffffe
    80006218:	af0080e7          	jalr	-1296(ra) # 80003d04 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000621c:	2981                	sext.w	s3,s3
    8000621e:	03498a63          	beq	s3,s4,80006252 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006222:	40d0                	lw	a2,4(s1)
    80006224:	fb040593          	addi	a1,s0,-80
    80006228:	854a                	mv	a0,s2
    8000622a:	ffffe097          	auipc	ra,0xffffe
    8000622e:	298080e7          	jalr	664(ra) # 800044c2 <dirlink>
    80006232:	06054b63          	bltz	a0,800062a8 <create+0x152>
  iunlockput(dp);
    80006236:	854a                	mv	a0,s2
    80006238:	ffffe097          	auipc	ra,0xffffe
    8000623c:	df8080e7          	jalr	-520(ra) # 80004030 <iunlockput>
  return ip;
    80006240:	b761                	j	800061c8 <create+0x72>
    panic("create: ialloc");
    80006242:	00002517          	auipc	a0,0x2
    80006246:	66e50513          	addi	a0,a0,1646 # 800088b0 <syscalls+0x368>
    8000624a:	ffffa097          	auipc	ra,0xffffa
    8000624e:	2e0080e7          	jalr	736(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80006252:	04a95783          	lhu	a5,74(s2)
    80006256:	2785                	addiw	a5,a5,1
    80006258:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000625c:	854a                	mv	a0,s2
    8000625e:	ffffe097          	auipc	ra,0xffffe
    80006262:	aa6080e7          	jalr	-1370(ra) # 80003d04 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006266:	40d0                	lw	a2,4(s1)
    80006268:	00002597          	auipc	a1,0x2
    8000626c:	4d858593          	addi	a1,a1,1240 # 80008740 <syscalls+0x1f8>
    80006270:	8526                	mv	a0,s1
    80006272:	ffffe097          	auipc	ra,0xffffe
    80006276:	250080e7          	jalr	592(ra) # 800044c2 <dirlink>
    8000627a:	00054f63          	bltz	a0,80006298 <create+0x142>
    8000627e:	00492603          	lw	a2,4(s2)
    80006282:	00002597          	auipc	a1,0x2
    80006286:	4c658593          	addi	a1,a1,1222 # 80008748 <syscalls+0x200>
    8000628a:	8526                	mv	a0,s1
    8000628c:	ffffe097          	auipc	ra,0xffffe
    80006290:	236080e7          	jalr	566(ra) # 800044c2 <dirlink>
    80006294:	f80557e3          	bgez	a0,80006222 <create+0xcc>
      panic("create dots");
    80006298:	00002517          	auipc	a0,0x2
    8000629c:	62850513          	addi	a0,a0,1576 # 800088c0 <syscalls+0x378>
    800062a0:	ffffa097          	auipc	ra,0xffffa
    800062a4:	28a080e7          	jalr	650(ra) # 8000052a <panic>
    panic("create: dirlink");
    800062a8:	00002517          	auipc	a0,0x2
    800062ac:	62850513          	addi	a0,a0,1576 # 800088d0 <syscalls+0x388>
    800062b0:	ffffa097          	auipc	ra,0xffffa
    800062b4:	27a080e7          	jalr	634(ra) # 8000052a <panic>
    return 0;
    800062b8:	84aa                	mv	s1,a0
    800062ba:	b739                	j	800061c8 <create+0x72>

00000000800062bc <sys_open>:

uint64
sys_open(void)
{
    800062bc:	7131                	addi	sp,sp,-192
    800062be:	fd06                	sd	ra,184(sp)
    800062c0:	f922                	sd	s0,176(sp)
    800062c2:	f526                	sd	s1,168(sp)
    800062c4:	f14a                	sd	s2,160(sp)
    800062c6:	ed4e                	sd	s3,152(sp)
    800062c8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800062ca:	08000613          	li	a2,128
    800062ce:	f5040593          	addi	a1,s0,-176
    800062d2:	4501                	li	a0,0
    800062d4:	ffffd097          	auipc	ra,0xffffd
    800062d8:	fb2080e7          	jalr	-78(ra) # 80003286 <argstr>
    return -1;
    800062dc:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800062de:	0c054163          	bltz	a0,800063a0 <sys_open+0xe4>
    800062e2:	f4c40593          	addi	a1,s0,-180
    800062e6:	4505                	li	a0,1
    800062e8:	ffffd097          	auipc	ra,0xffffd
    800062ec:	f5a080e7          	jalr	-166(ra) # 80003242 <argint>
    800062f0:	0a054863          	bltz	a0,800063a0 <sys_open+0xe4>

  begin_op();
    800062f4:	ffffe097          	auipc	ra,0xffffe
    800062f8:	7f8080e7          	jalr	2040(ra) # 80004aec <begin_op>

  if(omode & O_CREATE){
    800062fc:	f4c42783          	lw	a5,-180(s0)
    80006300:	2007f793          	andi	a5,a5,512
    80006304:	cbdd                	beqz	a5,800063ba <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006306:	4681                	li	a3,0
    80006308:	4601                	li	a2,0
    8000630a:	4589                	li	a1,2
    8000630c:	f5040513          	addi	a0,s0,-176
    80006310:	00000097          	auipc	ra,0x0
    80006314:	e46080e7          	jalr	-442(ra) # 80006156 <create>
    80006318:	892a                	mv	s2,a0
    if(ip == 0){
    8000631a:	c959                	beqz	a0,800063b0 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000631c:	04491703          	lh	a4,68(s2)
    80006320:	478d                	li	a5,3
    80006322:	00f71763          	bne	a4,a5,80006330 <sys_open+0x74>
    80006326:	04695703          	lhu	a4,70(s2)
    8000632a:	47a5                	li	a5,9
    8000632c:	0ce7ec63          	bltu	a5,a4,80006404 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006330:	fffff097          	auipc	ra,0xfffff
    80006334:	bcc080e7          	jalr	-1076(ra) # 80004efc <filealloc>
    80006338:	89aa                	mv	s3,a0
    8000633a:	10050263          	beqz	a0,8000643e <sys_open+0x182>
    8000633e:	00000097          	auipc	ra,0x0
    80006342:	8e2080e7          	jalr	-1822(ra) # 80005c20 <fdalloc>
    80006346:	84aa                	mv	s1,a0
    80006348:	0e054663          	bltz	a0,80006434 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000634c:	04491703          	lh	a4,68(s2)
    80006350:	478d                	li	a5,3
    80006352:	0cf70463          	beq	a4,a5,8000641a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006356:	4789                	li	a5,2
    80006358:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000635c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006360:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006364:	f4c42783          	lw	a5,-180(s0)
    80006368:	0017c713          	xori	a4,a5,1
    8000636c:	8b05                	andi	a4,a4,1
    8000636e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006372:	0037f713          	andi	a4,a5,3
    80006376:	00e03733          	snez	a4,a4
    8000637a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000637e:	4007f793          	andi	a5,a5,1024
    80006382:	c791                	beqz	a5,8000638e <sys_open+0xd2>
    80006384:	04491703          	lh	a4,68(s2)
    80006388:	4789                	li	a5,2
    8000638a:	08f70f63          	beq	a4,a5,80006428 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000638e:	854a                	mv	a0,s2
    80006390:	ffffe097          	auipc	ra,0xffffe
    80006394:	b00080e7          	jalr	-1280(ra) # 80003e90 <iunlock>
  end_op();
    80006398:	ffffe097          	auipc	ra,0xffffe
    8000639c:	7d4080e7          	jalr	2004(ra) # 80004b6c <end_op>

  return fd;
}
    800063a0:	8526                	mv	a0,s1
    800063a2:	70ea                	ld	ra,184(sp)
    800063a4:	744a                	ld	s0,176(sp)
    800063a6:	74aa                	ld	s1,168(sp)
    800063a8:	790a                	ld	s2,160(sp)
    800063aa:	69ea                	ld	s3,152(sp)
    800063ac:	6129                	addi	sp,sp,192
    800063ae:	8082                	ret
      end_op();
    800063b0:	ffffe097          	auipc	ra,0xffffe
    800063b4:	7bc080e7          	jalr	1980(ra) # 80004b6c <end_op>
      return -1;
    800063b8:	b7e5                	j	800063a0 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800063ba:	f5040513          	addi	a0,s0,-176
    800063be:	ffffe097          	auipc	ra,0xffffe
    800063c2:	1c6080e7          	jalr	454(ra) # 80004584 <namei>
    800063c6:	892a                	mv	s2,a0
    800063c8:	c905                	beqz	a0,800063f8 <sys_open+0x13c>
    ilock(ip);
    800063ca:	ffffe097          	auipc	ra,0xffffe
    800063ce:	a04080e7          	jalr	-1532(ra) # 80003dce <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800063d2:	04491703          	lh	a4,68(s2)
    800063d6:	4785                	li	a5,1
    800063d8:	f4f712e3          	bne	a4,a5,8000631c <sys_open+0x60>
    800063dc:	f4c42783          	lw	a5,-180(s0)
    800063e0:	dba1                	beqz	a5,80006330 <sys_open+0x74>
      iunlockput(ip);
    800063e2:	854a                	mv	a0,s2
    800063e4:	ffffe097          	auipc	ra,0xffffe
    800063e8:	c4c080e7          	jalr	-948(ra) # 80004030 <iunlockput>
      end_op();
    800063ec:	ffffe097          	auipc	ra,0xffffe
    800063f0:	780080e7          	jalr	1920(ra) # 80004b6c <end_op>
      return -1;
    800063f4:	54fd                	li	s1,-1
    800063f6:	b76d                	j	800063a0 <sys_open+0xe4>
      end_op();
    800063f8:	ffffe097          	auipc	ra,0xffffe
    800063fc:	774080e7          	jalr	1908(ra) # 80004b6c <end_op>
      return -1;
    80006400:	54fd                	li	s1,-1
    80006402:	bf79                	j	800063a0 <sys_open+0xe4>
    iunlockput(ip);
    80006404:	854a                	mv	a0,s2
    80006406:	ffffe097          	auipc	ra,0xffffe
    8000640a:	c2a080e7          	jalr	-982(ra) # 80004030 <iunlockput>
    end_op();
    8000640e:	ffffe097          	auipc	ra,0xffffe
    80006412:	75e080e7          	jalr	1886(ra) # 80004b6c <end_op>
    return -1;
    80006416:	54fd                	li	s1,-1
    80006418:	b761                	j	800063a0 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000641a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000641e:	04691783          	lh	a5,70(s2)
    80006422:	02f99223          	sh	a5,36(s3)
    80006426:	bf2d                	j	80006360 <sys_open+0xa4>
    itrunc(ip);
    80006428:	854a                	mv	a0,s2
    8000642a:	ffffe097          	auipc	ra,0xffffe
    8000642e:	ab2080e7          	jalr	-1358(ra) # 80003edc <itrunc>
    80006432:	bfb1                	j	8000638e <sys_open+0xd2>
      fileclose(f);
    80006434:	854e                	mv	a0,s3
    80006436:	fffff097          	auipc	ra,0xfffff
    8000643a:	b82080e7          	jalr	-1150(ra) # 80004fb8 <fileclose>
    iunlockput(ip);
    8000643e:	854a                	mv	a0,s2
    80006440:	ffffe097          	auipc	ra,0xffffe
    80006444:	bf0080e7          	jalr	-1040(ra) # 80004030 <iunlockput>
    end_op();
    80006448:	ffffe097          	auipc	ra,0xffffe
    8000644c:	724080e7          	jalr	1828(ra) # 80004b6c <end_op>
    return -1;
    80006450:	54fd                	li	s1,-1
    80006452:	b7b9                	j	800063a0 <sys_open+0xe4>

0000000080006454 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006454:	7175                	addi	sp,sp,-144
    80006456:	e506                	sd	ra,136(sp)
    80006458:	e122                	sd	s0,128(sp)
    8000645a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000645c:	ffffe097          	auipc	ra,0xffffe
    80006460:	690080e7          	jalr	1680(ra) # 80004aec <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006464:	08000613          	li	a2,128
    80006468:	f7040593          	addi	a1,s0,-144
    8000646c:	4501                	li	a0,0
    8000646e:	ffffd097          	auipc	ra,0xffffd
    80006472:	e18080e7          	jalr	-488(ra) # 80003286 <argstr>
    80006476:	02054963          	bltz	a0,800064a8 <sys_mkdir+0x54>
    8000647a:	4681                	li	a3,0
    8000647c:	4601                	li	a2,0
    8000647e:	4585                	li	a1,1
    80006480:	f7040513          	addi	a0,s0,-144
    80006484:	00000097          	auipc	ra,0x0
    80006488:	cd2080e7          	jalr	-814(ra) # 80006156 <create>
    8000648c:	cd11                	beqz	a0,800064a8 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000648e:	ffffe097          	auipc	ra,0xffffe
    80006492:	ba2080e7          	jalr	-1118(ra) # 80004030 <iunlockput>
  end_op();
    80006496:	ffffe097          	auipc	ra,0xffffe
    8000649a:	6d6080e7          	jalr	1750(ra) # 80004b6c <end_op>
  return 0;
    8000649e:	4501                	li	a0,0
}
    800064a0:	60aa                	ld	ra,136(sp)
    800064a2:	640a                	ld	s0,128(sp)
    800064a4:	6149                	addi	sp,sp,144
    800064a6:	8082                	ret
    end_op();
    800064a8:	ffffe097          	auipc	ra,0xffffe
    800064ac:	6c4080e7          	jalr	1732(ra) # 80004b6c <end_op>
    return -1;
    800064b0:	557d                	li	a0,-1
    800064b2:	b7fd                	j	800064a0 <sys_mkdir+0x4c>

00000000800064b4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800064b4:	7135                	addi	sp,sp,-160
    800064b6:	ed06                	sd	ra,152(sp)
    800064b8:	e922                	sd	s0,144(sp)
    800064ba:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800064bc:	ffffe097          	auipc	ra,0xffffe
    800064c0:	630080e7          	jalr	1584(ra) # 80004aec <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800064c4:	08000613          	li	a2,128
    800064c8:	f7040593          	addi	a1,s0,-144
    800064cc:	4501                	li	a0,0
    800064ce:	ffffd097          	auipc	ra,0xffffd
    800064d2:	db8080e7          	jalr	-584(ra) # 80003286 <argstr>
    800064d6:	04054a63          	bltz	a0,8000652a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800064da:	f6c40593          	addi	a1,s0,-148
    800064de:	4505                	li	a0,1
    800064e0:	ffffd097          	auipc	ra,0xffffd
    800064e4:	d62080e7          	jalr	-670(ra) # 80003242 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800064e8:	04054163          	bltz	a0,8000652a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800064ec:	f6840593          	addi	a1,s0,-152
    800064f0:	4509                	li	a0,2
    800064f2:	ffffd097          	auipc	ra,0xffffd
    800064f6:	d50080e7          	jalr	-688(ra) # 80003242 <argint>
     argint(1, &major) < 0 ||
    800064fa:	02054863          	bltz	a0,8000652a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800064fe:	f6841683          	lh	a3,-152(s0)
    80006502:	f6c41603          	lh	a2,-148(s0)
    80006506:	458d                	li	a1,3
    80006508:	f7040513          	addi	a0,s0,-144
    8000650c:	00000097          	auipc	ra,0x0
    80006510:	c4a080e7          	jalr	-950(ra) # 80006156 <create>
     argint(2, &minor) < 0 ||
    80006514:	c919                	beqz	a0,8000652a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006516:	ffffe097          	auipc	ra,0xffffe
    8000651a:	b1a080e7          	jalr	-1254(ra) # 80004030 <iunlockput>
  end_op();
    8000651e:	ffffe097          	auipc	ra,0xffffe
    80006522:	64e080e7          	jalr	1614(ra) # 80004b6c <end_op>
  return 0;
    80006526:	4501                	li	a0,0
    80006528:	a031                	j	80006534 <sys_mknod+0x80>
    end_op();
    8000652a:	ffffe097          	auipc	ra,0xffffe
    8000652e:	642080e7          	jalr	1602(ra) # 80004b6c <end_op>
    return -1;
    80006532:	557d                	li	a0,-1
}
    80006534:	60ea                	ld	ra,152(sp)
    80006536:	644a                	ld	s0,144(sp)
    80006538:	610d                	addi	sp,sp,160
    8000653a:	8082                	ret

000000008000653c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000653c:	7135                	addi	sp,sp,-160
    8000653e:	ed06                	sd	ra,152(sp)
    80006540:	e922                	sd	s0,144(sp)
    80006542:	e526                	sd	s1,136(sp)
    80006544:	e14a                	sd	s2,128(sp)
    80006546:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006548:	ffffc097          	auipc	ra,0xffffc
    8000654c:	a78080e7          	jalr	-1416(ra) # 80001fc0 <myproc>
    80006550:	892a                	mv	s2,a0
  
  begin_op();
    80006552:	ffffe097          	auipc	ra,0xffffe
    80006556:	59a080e7          	jalr	1434(ra) # 80004aec <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000655a:	08000613          	li	a2,128
    8000655e:	f6040593          	addi	a1,s0,-160
    80006562:	4501                	li	a0,0
    80006564:	ffffd097          	auipc	ra,0xffffd
    80006568:	d22080e7          	jalr	-734(ra) # 80003286 <argstr>
    8000656c:	04054b63          	bltz	a0,800065c2 <sys_chdir+0x86>
    80006570:	f6040513          	addi	a0,s0,-160
    80006574:	ffffe097          	auipc	ra,0xffffe
    80006578:	010080e7          	jalr	16(ra) # 80004584 <namei>
    8000657c:	84aa                	mv	s1,a0
    8000657e:	c131                	beqz	a0,800065c2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006580:	ffffe097          	auipc	ra,0xffffe
    80006584:	84e080e7          	jalr	-1970(ra) # 80003dce <ilock>
  if(ip->type != T_DIR){
    80006588:	04449703          	lh	a4,68(s1)
    8000658c:	4785                	li	a5,1
    8000658e:	04f71063          	bne	a4,a5,800065ce <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006592:	8526                	mv	a0,s1
    80006594:	ffffe097          	auipc	ra,0xffffe
    80006598:	8fc080e7          	jalr	-1796(ra) # 80003e90 <iunlock>
  iput(p->cwd);
    8000659c:	15093503          	ld	a0,336(s2)
    800065a0:	ffffe097          	auipc	ra,0xffffe
    800065a4:	9e8080e7          	jalr	-1560(ra) # 80003f88 <iput>
  end_op();
    800065a8:	ffffe097          	auipc	ra,0xffffe
    800065ac:	5c4080e7          	jalr	1476(ra) # 80004b6c <end_op>
  p->cwd = ip;
    800065b0:	14993823          	sd	s1,336(s2)
  return 0;
    800065b4:	4501                	li	a0,0
}
    800065b6:	60ea                	ld	ra,152(sp)
    800065b8:	644a                	ld	s0,144(sp)
    800065ba:	64aa                	ld	s1,136(sp)
    800065bc:	690a                	ld	s2,128(sp)
    800065be:	610d                	addi	sp,sp,160
    800065c0:	8082                	ret
    end_op();
    800065c2:	ffffe097          	auipc	ra,0xffffe
    800065c6:	5aa080e7          	jalr	1450(ra) # 80004b6c <end_op>
    return -1;
    800065ca:	557d                	li	a0,-1
    800065cc:	b7ed                	j	800065b6 <sys_chdir+0x7a>
    iunlockput(ip);
    800065ce:	8526                	mv	a0,s1
    800065d0:	ffffe097          	auipc	ra,0xffffe
    800065d4:	a60080e7          	jalr	-1440(ra) # 80004030 <iunlockput>
    end_op();
    800065d8:	ffffe097          	auipc	ra,0xffffe
    800065dc:	594080e7          	jalr	1428(ra) # 80004b6c <end_op>
    return -1;
    800065e0:	557d                	li	a0,-1
    800065e2:	bfd1                	j	800065b6 <sys_chdir+0x7a>

00000000800065e4 <sys_exec>:

uint64
sys_exec(void)
{
    800065e4:	7145                	addi	sp,sp,-464
    800065e6:	e786                	sd	ra,456(sp)
    800065e8:	e3a2                	sd	s0,448(sp)
    800065ea:	ff26                	sd	s1,440(sp)
    800065ec:	fb4a                	sd	s2,432(sp)
    800065ee:	f74e                	sd	s3,424(sp)
    800065f0:	f352                	sd	s4,416(sp)
    800065f2:	ef56                	sd	s5,408(sp)
    800065f4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800065f6:	08000613          	li	a2,128
    800065fa:	f4040593          	addi	a1,s0,-192
    800065fe:	4501                	li	a0,0
    80006600:	ffffd097          	auipc	ra,0xffffd
    80006604:	c86080e7          	jalr	-890(ra) # 80003286 <argstr>
    return -1;
    80006608:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000660a:	0c054a63          	bltz	a0,800066de <sys_exec+0xfa>
    8000660e:	e3840593          	addi	a1,s0,-456
    80006612:	4505                	li	a0,1
    80006614:	ffffd097          	auipc	ra,0xffffd
    80006618:	c50080e7          	jalr	-944(ra) # 80003264 <argaddr>
    8000661c:	0c054163          	bltz	a0,800066de <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006620:	10000613          	li	a2,256
    80006624:	4581                	li	a1,0
    80006626:	e4040513          	addi	a0,s0,-448
    8000662a:	ffffa097          	auipc	ra,0xffffa
    8000662e:	694080e7          	jalr	1684(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006632:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006636:	89a6                	mv	s3,s1
    80006638:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000663a:	02000a13          	li	s4,32
    8000663e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006642:	00391793          	slli	a5,s2,0x3
    80006646:	e3040593          	addi	a1,s0,-464
    8000664a:	e3843503          	ld	a0,-456(s0)
    8000664e:	953e                	add	a0,a0,a5
    80006650:	ffffd097          	auipc	ra,0xffffd
    80006654:	b58080e7          	jalr	-1192(ra) # 800031a8 <fetchaddr>
    80006658:	02054a63          	bltz	a0,8000668c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000665c:	e3043783          	ld	a5,-464(s0)
    80006660:	c3b9                	beqz	a5,800066a6 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006662:	ffffa097          	auipc	ra,0xffffa
    80006666:	470080e7          	jalr	1136(ra) # 80000ad2 <kalloc>
    8000666a:	85aa                	mv	a1,a0
    8000666c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006670:	cd11                	beqz	a0,8000668c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006672:	6605                	lui	a2,0x1
    80006674:	e3043503          	ld	a0,-464(s0)
    80006678:	ffffd097          	auipc	ra,0xffffd
    8000667c:	b82080e7          	jalr	-1150(ra) # 800031fa <fetchstr>
    80006680:	00054663          	bltz	a0,8000668c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006684:	0905                	addi	s2,s2,1
    80006686:	09a1                	addi	s3,s3,8
    80006688:	fb491be3          	bne	s2,s4,8000663e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000668c:	10048913          	addi	s2,s1,256
    80006690:	6088                	ld	a0,0(s1)
    80006692:	c529                	beqz	a0,800066dc <sys_exec+0xf8>
    kfree(argv[i]);
    80006694:	ffffa097          	auipc	ra,0xffffa
    80006698:	342080e7          	jalr	834(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000669c:	04a1                	addi	s1,s1,8
    8000669e:	ff2499e3          	bne	s1,s2,80006690 <sys_exec+0xac>
  return -1;
    800066a2:	597d                	li	s2,-1
    800066a4:	a82d                	j	800066de <sys_exec+0xfa>
      argv[i] = 0;
    800066a6:	0a8e                	slli	s5,s5,0x3
    800066a8:	fc040793          	addi	a5,s0,-64
    800066ac:	9abe                	add	s5,s5,a5
    800066ae:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffc8e80>
  int ret = exec(path, argv);
    800066b2:	e4040593          	addi	a1,s0,-448
    800066b6:	f4040513          	addi	a0,s0,-192
    800066ba:	fffff097          	auipc	ra,0xfffff
    800066be:	146080e7          	jalr	326(ra) # 80005800 <exec>
    800066c2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800066c4:	10048993          	addi	s3,s1,256
    800066c8:	6088                	ld	a0,0(s1)
    800066ca:	c911                	beqz	a0,800066de <sys_exec+0xfa>
    kfree(argv[i]);
    800066cc:	ffffa097          	auipc	ra,0xffffa
    800066d0:	30a080e7          	jalr	778(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800066d4:	04a1                	addi	s1,s1,8
    800066d6:	ff3499e3          	bne	s1,s3,800066c8 <sys_exec+0xe4>
    800066da:	a011                	j	800066de <sys_exec+0xfa>
  return -1;
    800066dc:	597d                	li	s2,-1
}
    800066de:	854a                	mv	a0,s2
    800066e0:	60be                	ld	ra,456(sp)
    800066e2:	641e                	ld	s0,448(sp)
    800066e4:	74fa                	ld	s1,440(sp)
    800066e6:	795a                	ld	s2,432(sp)
    800066e8:	79ba                	ld	s3,424(sp)
    800066ea:	7a1a                	ld	s4,416(sp)
    800066ec:	6afa                	ld	s5,408(sp)
    800066ee:	6179                	addi	sp,sp,464
    800066f0:	8082                	ret

00000000800066f2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800066f2:	7139                	addi	sp,sp,-64
    800066f4:	fc06                	sd	ra,56(sp)
    800066f6:	f822                	sd	s0,48(sp)
    800066f8:	f426                	sd	s1,40(sp)
    800066fa:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800066fc:	ffffc097          	auipc	ra,0xffffc
    80006700:	8c4080e7          	jalr	-1852(ra) # 80001fc0 <myproc>
    80006704:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006706:	fd840593          	addi	a1,s0,-40
    8000670a:	4501                	li	a0,0
    8000670c:	ffffd097          	auipc	ra,0xffffd
    80006710:	b58080e7          	jalr	-1192(ra) # 80003264 <argaddr>
    return -1;
    80006714:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006716:	0e054063          	bltz	a0,800067f6 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000671a:	fc840593          	addi	a1,s0,-56
    8000671e:	fd040513          	addi	a0,s0,-48
    80006722:	fffff097          	auipc	ra,0xfffff
    80006726:	dbc080e7          	jalr	-580(ra) # 800054de <pipealloc>
    return -1;
    8000672a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000672c:	0c054563          	bltz	a0,800067f6 <sys_pipe+0x104>
  fd0 = -1;
    80006730:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006734:	fd043503          	ld	a0,-48(s0)
    80006738:	fffff097          	auipc	ra,0xfffff
    8000673c:	4e8080e7          	jalr	1256(ra) # 80005c20 <fdalloc>
    80006740:	fca42223          	sw	a0,-60(s0)
    80006744:	08054c63          	bltz	a0,800067dc <sys_pipe+0xea>
    80006748:	fc843503          	ld	a0,-56(s0)
    8000674c:	fffff097          	auipc	ra,0xfffff
    80006750:	4d4080e7          	jalr	1236(ra) # 80005c20 <fdalloc>
    80006754:	fca42023          	sw	a0,-64(s0)
    80006758:	06054863          	bltz	a0,800067c8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000675c:	4691                	li	a3,4
    8000675e:	fc440613          	addi	a2,s0,-60
    80006762:	fd843583          	ld	a1,-40(s0)
    80006766:	68a8                	ld	a0,80(s1)
    80006768:	ffffb097          	auipc	ra,0xffffb
    8000676c:	c16080e7          	jalr	-1002(ra) # 8000137e <copyout>
    80006770:	02054063          	bltz	a0,80006790 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006774:	4691                	li	a3,4
    80006776:	fc040613          	addi	a2,s0,-64
    8000677a:	fd843583          	ld	a1,-40(s0)
    8000677e:	0591                	addi	a1,a1,4
    80006780:	68a8                	ld	a0,80(s1)
    80006782:	ffffb097          	auipc	ra,0xffffb
    80006786:	bfc080e7          	jalr	-1028(ra) # 8000137e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000678a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000678c:	06055563          	bgez	a0,800067f6 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006790:	fc442783          	lw	a5,-60(s0)
    80006794:	07e9                	addi	a5,a5,26
    80006796:	078e                	slli	a5,a5,0x3
    80006798:	97a6                	add	a5,a5,s1
    8000679a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000679e:	fc042503          	lw	a0,-64(s0)
    800067a2:	0569                	addi	a0,a0,26
    800067a4:	050e                	slli	a0,a0,0x3
    800067a6:	9526                	add	a0,a0,s1
    800067a8:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800067ac:	fd043503          	ld	a0,-48(s0)
    800067b0:	fffff097          	auipc	ra,0xfffff
    800067b4:	808080e7          	jalr	-2040(ra) # 80004fb8 <fileclose>
    fileclose(wf);
    800067b8:	fc843503          	ld	a0,-56(s0)
    800067bc:	ffffe097          	auipc	ra,0xffffe
    800067c0:	7fc080e7          	jalr	2044(ra) # 80004fb8 <fileclose>
    return -1;
    800067c4:	57fd                	li	a5,-1
    800067c6:	a805                	j	800067f6 <sys_pipe+0x104>
    if(fd0 >= 0)
    800067c8:	fc442783          	lw	a5,-60(s0)
    800067cc:	0007c863          	bltz	a5,800067dc <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800067d0:	01a78513          	addi	a0,a5,26
    800067d4:	050e                	slli	a0,a0,0x3
    800067d6:	9526                	add	a0,a0,s1
    800067d8:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800067dc:	fd043503          	ld	a0,-48(s0)
    800067e0:	ffffe097          	auipc	ra,0xffffe
    800067e4:	7d8080e7          	jalr	2008(ra) # 80004fb8 <fileclose>
    fileclose(wf);
    800067e8:	fc843503          	ld	a0,-56(s0)
    800067ec:	ffffe097          	auipc	ra,0xffffe
    800067f0:	7cc080e7          	jalr	1996(ra) # 80004fb8 <fileclose>
    return -1;
    800067f4:	57fd                	li	a5,-1
}
    800067f6:	853e                	mv	a0,a5
    800067f8:	70e2                	ld	ra,56(sp)
    800067fa:	7442                	ld	s0,48(sp)
    800067fc:	74a2                	ld	s1,40(sp)
    800067fe:	6121                	addi	sp,sp,64
    80006800:	8082                	ret
	...

0000000080006810 <kernelvec>:
    80006810:	7111                	addi	sp,sp,-256
    80006812:	e006                	sd	ra,0(sp)
    80006814:	e40a                	sd	sp,8(sp)
    80006816:	e80e                	sd	gp,16(sp)
    80006818:	ec12                	sd	tp,24(sp)
    8000681a:	f016                	sd	t0,32(sp)
    8000681c:	f41a                	sd	t1,40(sp)
    8000681e:	f81e                	sd	t2,48(sp)
    80006820:	fc22                	sd	s0,56(sp)
    80006822:	e0a6                	sd	s1,64(sp)
    80006824:	e4aa                	sd	a0,72(sp)
    80006826:	e8ae                	sd	a1,80(sp)
    80006828:	ecb2                	sd	a2,88(sp)
    8000682a:	f0b6                	sd	a3,96(sp)
    8000682c:	f4ba                	sd	a4,104(sp)
    8000682e:	f8be                	sd	a5,112(sp)
    80006830:	fcc2                	sd	a6,120(sp)
    80006832:	e146                	sd	a7,128(sp)
    80006834:	e54a                	sd	s2,136(sp)
    80006836:	e94e                	sd	s3,144(sp)
    80006838:	ed52                	sd	s4,152(sp)
    8000683a:	f156                	sd	s5,160(sp)
    8000683c:	f55a                	sd	s6,168(sp)
    8000683e:	f95e                	sd	s7,176(sp)
    80006840:	fd62                	sd	s8,184(sp)
    80006842:	e1e6                	sd	s9,192(sp)
    80006844:	e5ea                	sd	s10,200(sp)
    80006846:	e9ee                	sd	s11,208(sp)
    80006848:	edf2                	sd	t3,216(sp)
    8000684a:	f1f6                	sd	t4,224(sp)
    8000684c:	f5fa                	sd	t5,232(sp)
    8000684e:	f9fe                	sd	t6,240(sp)
    80006850:	825fc0ef          	jal	ra,80003074 <kerneltrap>
    80006854:	6082                	ld	ra,0(sp)
    80006856:	6122                	ld	sp,8(sp)
    80006858:	61c2                	ld	gp,16(sp)
    8000685a:	7282                	ld	t0,32(sp)
    8000685c:	7322                	ld	t1,40(sp)
    8000685e:	73c2                	ld	t2,48(sp)
    80006860:	7462                	ld	s0,56(sp)
    80006862:	6486                	ld	s1,64(sp)
    80006864:	6526                	ld	a0,72(sp)
    80006866:	65c6                	ld	a1,80(sp)
    80006868:	6666                	ld	a2,88(sp)
    8000686a:	7686                	ld	a3,96(sp)
    8000686c:	7726                	ld	a4,104(sp)
    8000686e:	77c6                	ld	a5,112(sp)
    80006870:	7866                	ld	a6,120(sp)
    80006872:	688a                	ld	a7,128(sp)
    80006874:	692a                	ld	s2,136(sp)
    80006876:	69ca                	ld	s3,144(sp)
    80006878:	6a6a                	ld	s4,152(sp)
    8000687a:	7a8a                	ld	s5,160(sp)
    8000687c:	7b2a                	ld	s6,168(sp)
    8000687e:	7bca                	ld	s7,176(sp)
    80006880:	7c6a                	ld	s8,184(sp)
    80006882:	6c8e                	ld	s9,192(sp)
    80006884:	6d2e                	ld	s10,200(sp)
    80006886:	6dce                	ld	s11,208(sp)
    80006888:	6e6e                	ld	t3,216(sp)
    8000688a:	7e8e                	ld	t4,224(sp)
    8000688c:	7f2e                	ld	t5,232(sp)
    8000688e:	7fce                	ld	t6,240(sp)
    80006890:	6111                	addi	sp,sp,256
    80006892:	10200073          	sret
    80006896:	00000013          	nop
    8000689a:	00000013          	nop
    8000689e:	0001                	nop

00000000800068a0 <timervec>:
    800068a0:	34051573          	csrrw	a0,mscratch,a0
    800068a4:	e10c                	sd	a1,0(a0)
    800068a6:	e510                	sd	a2,8(a0)
    800068a8:	e914                	sd	a3,16(a0)
    800068aa:	6d0c                	ld	a1,24(a0)
    800068ac:	7110                	ld	a2,32(a0)
    800068ae:	6194                	ld	a3,0(a1)
    800068b0:	96b2                	add	a3,a3,a2
    800068b2:	e194                	sd	a3,0(a1)
    800068b4:	4589                	li	a1,2
    800068b6:	14459073          	csrw	sip,a1
    800068ba:	6914                	ld	a3,16(a0)
    800068bc:	6510                	ld	a2,8(a0)
    800068be:	610c                	ld	a1,0(a0)
    800068c0:	34051573          	csrrw	a0,mscratch,a0
    800068c4:	30200073          	mret
	...

00000000800068ca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800068ca:	1141                	addi	sp,sp,-16
    800068cc:	e422                	sd	s0,8(sp)
    800068ce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800068d0:	0c0007b7          	lui	a5,0xc000
    800068d4:	4705                	li	a4,1
    800068d6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800068d8:	c3d8                	sw	a4,4(a5)
}
    800068da:	6422                	ld	s0,8(sp)
    800068dc:	0141                	addi	sp,sp,16
    800068de:	8082                	ret

00000000800068e0 <plicinithart>:

void
plicinithart(void)
{
    800068e0:	1141                	addi	sp,sp,-16
    800068e2:	e406                	sd	ra,8(sp)
    800068e4:	e022                	sd	s0,0(sp)
    800068e6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800068e8:	ffffb097          	auipc	ra,0xffffb
    800068ec:	6ac080e7          	jalr	1708(ra) # 80001f94 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800068f0:	0085171b          	slliw	a4,a0,0x8
    800068f4:	0c0027b7          	lui	a5,0xc002
    800068f8:	97ba                	add	a5,a5,a4
    800068fa:	40200713          	li	a4,1026
    800068fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006902:	00d5151b          	slliw	a0,a0,0xd
    80006906:	0c2017b7          	lui	a5,0xc201
    8000690a:	953e                	add	a0,a0,a5
    8000690c:	00052023          	sw	zero,0(a0)
}
    80006910:	60a2                	ld	ra,8(sp)
    80006912:	6402                	ld	s0,0(sp)
    80006914:	0141                	addi	sp,sp,16
    80006916:	8082                	ret

0000000080006918 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006918:	1141                	addi	sp,sp,-16
    8000691a:	e406                	sd	ra,8(sp)
    8000691c:	e022                	sd	s0,0(sp)
    8000691e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006920:	ffffb097          	auipc	ra,0xffffb
    80006924:	674080e7          	jalr	1652(ra) # 80001f94 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006928:	00d5179b          	slliw	a5,a0,0xd
    8000692c:	0c201537          	lui	a0,0xc201
    80006930:	953e                	add	a0,a0,a5
  return irq;
}
    80006932:	4148                	lw	a0,4(a0)
    80006934:	60a2                	ld	ra,8(sp)
    80006936:	6402                	ld	s0,0(sp)
    80006938:	0141                	addi	sp,sp,16
    8000693a:	8082                	ret

000000008000693c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000693c:	1101                	addi	sp,sp,-32
    8000693e:	ec06                	sd	ra,24(sp)
    80006940:	e822                	sd	s0,16(sp)
    80006942:	e426                	sd	s1,8(sp)
    80006944:	1000                	addi	s0,sp,32
    80006946:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006948:	ffffb097          	auipc	ra,0xffffb
    8000694c:	64c080e7          	jalr	1612(ra) # 80001f94 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006950:	00d5151b          	slliw	a0,a0,0xd
    80006954:	0c2017b7          	lui	a5,0xc201
    80006958:	97aa                	add	a5,a5,a0
    8000695a:	c3c4                	sw	s1,4(a5)
}
    8000695c:	60e2                	ld	ra,24(sp)
    8000695e:	6442                	ld	s0,16(sp)
    80006960:	64a2                	ld	s1,8(sp)
    80006962:	6105                	addi	sp,sp,32
    80006964:	8082                	ret

0000000080006966 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006966:	1141                	addi	sp,sp,-16
    80006968:	e406                	sd	ra,8(sp)
    8000696a:	e022                	sd	s0,0(sp)
    8000696c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000696e:	479d                	li	a5,7
    80006970:	06a7c963          	blt	a5,a0,800069e2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006974:	0002c797          	auipc	a5,0x2c
    80006978:	68c78793          	addi	a5,a5,1676 # 80033000 <disk>
    8000697c:	00a78733          	add	a4,a5,a0
    80006980:	6789                	lui	a5,0x2
    80006982:	97ba                	add	a5,a5,a4
    80006984:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006988:	e7ad                	bnez	a5,800069f2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000698a:	00451793          	slli	a5,a0,0x4
    8000698e:	0002e717          	auipc	a4,0x2e
    80006992:	67270713          	addi	a4,a4,1650 # 80035000 <disk+0x2000>
    80006996:	6314                	ld	a3,0(a4)
    80006998:	96be                	add	a3,a3,a5
    8000699a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000699e:	6314                	ld	a3,0(a4)
    800069a0:	96be                	add	a3,a3,a5
    800069a2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800069a6:	6314                	ld	a3,0(a4)
    800069a8:	96be                	add	a3,a3,a5
    800069aa:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800069ae:	6318                	ld	a4,0(a4)
    800069b0:	97ba                	add	a5,a5,a4
    800069b2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800069b6:	0002c797          	auipc	a5,0x2c
    800069ba:	64a78793          	addi	a5,a5,1610 # 80033000 <disk>
    800069be:	97aa                	add	a5,a5,a0
    800069c0:	6509                	lui	a0,0x2
    800069c2:	953e                	add	a0,a0,a5
    800069c4:	4785                	li	a5,1
    800069c6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800069ca:	0002e517          	auipc	a0,0x2e
    800069ce:	64e50513          	addi	a0,a0,1614 # 80035018 <disk+0x2018>
    800069d2:	ffffc097          	auipc	ra,0xffffc
    800069d6:	f30080e7          	jalr	-208(ra) # 80002902 <wakeup>
}
    800069da:	60a2                	ld	ra,8(sp)
    800069dc:	6402                	ld	s0,0(sp)
    800069de:	0141                	addi	sp,sp,16
    800069e0:	8082                	ret
    panic("free_desc 1");
    800069e2:	00002517          	auipc	a0,0x2
    800069e6:	efe50513          	addi	a0,a0,-258 # 800088e0 <syscalls+0x398>
    800069ea:	ffffa097          	auipc	ra,0xffffa
    800069ee:	b40080e7          	jalr	-1216(ra) # 8000052a <panic>
    panic("free_desc 2");
    800069f2:	00002517          	auipc	a0,0x2
    800069f6:	efe50513          	addi	a0,a0,-258 # 800088f0 <syscalls+0x3a8>
    800069fa:	ffffa097          	auipc	ra,0xffffa
    800069fe:	b30080e7          	jalr	-1232(ra) # 8000052a <panic>

0000000080006a02 <virtio_disk_init>:
{
    80006a02:	1101                	addi	sp,sp,-32
    80006a04:	ec06                	sd	ra,24(sp)
    80006a06:	e822                	sd	s0,16(sp)
    80006a08:	e426                	sd	s1,8(sp)
    80006a0a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006a0c:	00002597          	auipc	a1,0x2
    80006a10:	ef458593          	addi	a1,a1,-268 # 80008900 <syscalls+0x3b8>
    80006a14:	0002e517          	auipc	a0,0x2e
    80006a18:	71450513          	addi	a0,a0,1812 # 80035128 <disk+0x2128>
    80006a1c:	ffffa097          	auipc	ra,0xffffa
    80006a20:	116080e7          	jalr	278(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006a24:	100017b7          	lui	a5,0x10001
    80006a28:	4398                	lw	a4,0(a5)
    80006a2a:	2701                	sext.w	a4,a4
    80006a2c:	747277b7          	lui	a5,0x74727
    80006a30:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006a34:	0ef71163          	bne	a4,a5,80006b16 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006a38:	100017b7          	lui	a5,0x10001
    80006a3c:	43dc                	lw	a5,4(a5)
    80006a3e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006a40:	4705                	li	a4,1
    80006a42:	0ce79a63          	bne	a5,a4,80006b16 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006a46:	100017b7          	lui	a5,0x10001
    80006a4a:	479c                	lw	a5,8(a5)
    80006a4c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006a4e:	4709                	li	a4,2
    80006a50:	0ce79363          	bne	a5,a4,80006b16 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006a54:	100017b7          	lui	a5,0x10001
    80006a58:	47d8                	lw	a4,12(a5)
    80006a5a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006a5c:	554d47b7          	lui	a5,0x554d4
    80006a60:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006a64:	0af71963          	bne	a4,a5,80006b16 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a68:	100017b7          	lui	a5,0x10001
    80006a6c:	4705                	li	a4,1
    80006a6e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a70:	470d                	li	a4,3
    80006a72:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006a74:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006a76:	c7ffe737          	lui	a4,0xc7ffe
    80006a7a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc875f>
    80006a7e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006a80:	2701                	sext.w	a4,a4
    80006a82:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a84:	472d                	li	a4,11
    80006a86:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a88:	473d                	li	a4,15
    80006a8a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006a8c:	6705                	lui	a4,0x1
    80006a8e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006a90:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006a94:	5bdc                	lw	a5,52(a5)
    80006a96:	2781                	sext.w	a5,a5
  if(max == 0)
    80006a98:	c7d9                	beqz	a5,80006b26 <virtio_disk_init+0x124>
  if(max < NUM)
    80006a9a:	471d                	li	a4,7
    80006a9c:	08f77d63          	bgeu	a4,a5,80006b36 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006aa0:	100014b7          	lui	s1,0x10001
    80006aa4:	47a1                	li	a5,8
    80006aa6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006aa8:	6609                	lui	a2,0x2
    80006aaa:	4581                	li	a1,0
    80006aac:	0002c517          	auipc	a0,0x2c
    80006ab0:	55450513          	addi	a0,a0,1364 # 80033000 <disk>
    80006ab4:	ffffa097          	auipc	ra,0xffffa
    80006ab8:	20a080e7          	jalr	522(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006abc:	0002c717          	auipc	a4,0x2c
    80006ac0:	54470713          	addi	a4,a4,1348 # 80033000 <disk>
    80006ac4:	00c75793          	srli	a5,a4,0xc
    80006ac8:	2781                	sext.w	a5,a5
    80006aca:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006acc:	0002e797          	auipc	a5,0x2e
    80006ad0:	53478793          	addi	a5,a5,1332 # 80035000 <disk+0x2000>
    80006ad4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006ad6:	0002c717          	auipc	a4,0x2c
    80006ada:	5aa70713          	addi	a4,a4,1450 # 80033080 <disk+0x80>
    80006ade:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006ae0:	0002d717          	auipc	a4,0x2d
    80006ae4:	52070713          	addi	a4,a4,1312 # 80034000 <disk+0x1000>
    80006ae8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006aea:	4705                	li	a4,1
    80006aec:	00e78c23          	sb	a4,24(a5)
    80006af0:	00e78ca3          	sb	a4,25(a5)
    80006af4:	00e78d23          	sb	a4,26(a5)
    80006af8:	00e78da3          	sb	a4,27(a5)
    80006afc:	00e78e23          	sb	a4,28(a5)
    80006b00:	00e78ea3          	sb	a4,29(a5)
    80006b04:	00e78f23          	sb	a4,30(a5)
    80006b08:	00e78fa3          	sb	a4,31(a5)
}
    80006b0c:	60e2                	ld	ra,24(sp)
    80006b0e:	6442                	ld	s0,16(sp)
    80006b10:	64a2                	ld	s1,8(sp)
    80006b12:	6105                	addi	sp,sp,32
    80006b14:	8082                	ret
    panic("could not find virtio disk");
    80006b16:	00002517          	auipc	a0,0x2
    80006b1a:	dfa50513          	addi	a0,a0,-518 # 80008910 <syscalls+0x3c8>
    80006b1e:	ffffa097          	auipc	ra,0xffffa
    80006b22:	a0c080e7          	jalr	-1524(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006b26:	00002517          	auipc	a0,0x2
    80006b2a:	e0a50513          	addi	a0,a0,-502 # 80008930 <syscalls+0x3e8>
    80006b2e:	ffffa097          	auipc	ra,0xffffa
    80006b32:	9fc080e7          	jalr	-1540(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006b36:	00002517          	auipc	a0,0x2
    80006b3a:	e1a50513          	addi	a0,a0,-486 # 80008950 <syscalls+0x408>
    80006b3e:	ffffa097          	auipc	ra,0xffffa
    80006b42:	9ec080e7          	jalr	-1556(ra) # 8000052a <panic>

0000000080006b46 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006b46:	7119                	addi	sp,sp,-128
    80006b48:	fc86                	sd	ra,120(sp)
    80006b4a:	f8a2                	sd	s0,112(sp)
    80006b4c:	f4a6                	sd	s1,104(sp)
    80006b4e:	f0ca                	sd	s2,96(sp)
    80006b50:	ecce                	sd	s3,88(sp)
    80006b52:	e8d2                	sd	s4,80(sp)
    80006b54:	e4d6                	sd	s5,72(sp)
    80006b56:	e0da                	sd	s6,64(sp)
    80006b58:	fc5e                	sd	s7,56(sp)
    80006b5a:	f862                	sd	s8,48(sp)
    80006b5c:	f466                	sd	s9,40(sp)
    80006b5e:	f06a                	sd	s10,32(sp)
    80006b60:	ec6e                	sd	s11,24(sp)
    80006b62:	0100                	addi	s0,sp,128
    80006b64:	8aaa                	mv	s5,a0
    80006b66:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006b68:	00c52c83          	lw	s9,12(a0)
    80006b6c:	001c9c9b          	slliw	s9,s9,0x1
    80006b70:	1c82                	slli	s9,s9,0x20
    80006b72:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006b76:	0002e517          	auipc	a0,0x2e
    80006b7a:	5b250513          	addi	a0,a0,1458 # 80035128 <disk+0x2128>
    80006b7e:	ffffa097          	auipc	ra,0xffffa
    80006b82:	044080e7          	jalr	68(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006b86:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006b88:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006b8a:	0002cc17          	auipc	s8,0x2c
    80006b8e:	476c0c13          	addi	s8,s8,1142 # 80033000 <disk>
    80006b92:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006b94:	4b0d                	li	s6,3
    80006b96:	a0ad                	j	80006c00 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006b98:	00fc0733          	add	a4,s8,a5
    80006b9c:	975e                	add	a4,a4,s7
    80006b9e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006ba2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006ba4:	0207c563          	bltz	a5,80006bce <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006ba8:	2905                	addiw	s2,s2,1
    80006baa:	0611                	addi	a2,a2,4
    80006bac:	19690d63          	beq	s2,s6,80006d46 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006bb0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006bb2:	0002e717          	auipc	a4,0x2e
    80006bb6:	46670713          	addi	a4,a4,1126 # 80035018 <disk+0x2018>
    80006bba:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006bbc:	00074683          	lbu	a3,0(a4)
    80006bc0:	fee1                	bnez	a3,80006b98 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006bc2:	2785                	addiw	a5,a5,1
    80006bc4:	0705                	addi	a4,a4,1
    80006bc6:	fe979be3          	bne	a5,s1,80006bbc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006bca:	57fd                	li	a5,-1
    80006bcc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006bce:	01205d63          	blez	s2,80006be8 <virtio_disk_rw+0xa2>
    80006bd2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006bd4:	000a2503          	lw	a0,0(s4)
    80006bd8:	00000097          	auipc	ra,0x0
    80006bdc:	d8e080e7          	jalr	-626(ra) # 80006966 <free_desc>
      for(int j = 0; j < i; j++)
    80006be0:	2d85                	addiw	s11,s11,1
    80006be2:	0a11                	addi	s4,s4,4
    80006be4:	ffb918e3          	bne	s2,s11,80006bd4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006be8:	0002e597          	auipc	a1,0x2e
    80006bec:	54058593          	addi	a1,a1,1344 # 80035128 <disk+0x2128>
    80006bf0:	0002e517          	auipc	a0,0x2e
    80006bf4:	42850513          	addi	a0,a0,1064 # 80035018 <disk+0x2018>
    80006bf8:	ffffc097          	auipc	ra,0xffffc
    80006bfc:	b7e080e7          	jalr	-1154(ra) # 80002776 <sleep>
  for(int i = 0; i < 3; i++){
    80006c00:	f8040a13          	addi	s4,s0,-128
{
    80006c04:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006c06:	894e                	mv	s2,s3
    80006c08:	b765                	j	80006bb0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006c0a:	0002e697          	auipc	a3,0x2e
    80006c0e:	3f66b683          	ld	a3,1014(a3) # 80035000 <disk+0x2000>
    80006c12:	96ba                	add	a3,a3,a4
    80006c14:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006c18:	0002c817          	auipc	a6,0x2c
    80006c1c:	3e880813          	addi	a6,a6,1000 # 80033000 <disk>
    80006c20:	0002e697          	auipc	a3,0x2e
    80006c24:	3e068693          	addi	a3,a3,992 # 80035000 <disk+0x2000>
    80006c28:	6290                	ld	a2,0(a3)
    80006c2a:	963a                	add	a2,a2,a4
    80006c2c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006c30:	0015e593          	ori	a1,a1,1
    80006c34:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006c38:	f8842603          	lw	a2,-120(s0)
    80006c3c:	628c                	ld	a1,0(a3)
    80006c3e:	972e                	add	a4,a4,a1
    80006c40:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006c44:	20050593          	addi	a1,a0,512
    80006c48:	0592                	slli	a1,a1,0x4
    80006c4a:	95c2                	add	a1,a1,a6
    80006c4c:	577d                	li	a4,-1
    80006c4e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006c52:	00461713          	slli	a4,a2,0x4
    80006c56:	6290                	ld	a2,0(a3)
    80006c58:	963a                	add	a2,a2,a4
    80006c5a:	03078793          	addi	a5,a5,48
    80006c5e:	97c2                	add	a5,a5,a6
    80006c60:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006c62:	629c                	ld	a5,0(a3)
    80006c64:	97ba                	add	a5,a5,a4
    80006c66:	4605                	li	a2,1
    80006c68:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006c6a:	629c                	ld	a5,0(a3)
    80006c6c:	97ba                	add	a5,a5,a4
    80006c6e:	4809                	li	a6,2
    80006c70:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006c74:	629c                	ld	a5,0(a3)
    80006c76:	973e                	add	a4,a4,a5
    80006c78:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006c7c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006c80:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006c84:	6698                	ld	a4,8(a3)
    80006c86:	00275783          	lhu	a5,2(a4)
    80006c8a:	8b9d                	andi	a5,a5,7
    80006c8c:	0786                	slli	a5,a5,0x1
    80006c8e:	97ba                	add	a5,a5,a4
    80006c90:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006c94:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006c98:	6698                	ld	a4,8(a3)
    80006c9a:	00275783          	lhu	a5,2(a4)
    80006c9e:	2785                	addiw	a5,a5,1
    80006ca0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006ca4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006ca8:	100017b7          	lui	a5,0x10001
    80006cac:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006cb0:	004aa783          	lw	a5,4(s5)
    80006cb4:	02c79163          	bne	a5,a2,80006cd6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006cb8:	0002e917          	auipc	s2,0x2e
    80006cbc:	47090913          	addi	s2,s2,1136 # 80035128 <disk+0x2128>
  while(b->disk == 1) {
    80006cc0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006cc2:	85ca                	mv	a1,s2
    80006cc4:	8556                	mv	a0,s5
    80006cc6:	ffffc097          	auipc	ra,0xffffc
    80006cca:	ab0080e7          	jalr	-1360(ra) # 80002776 <sleep>
  while(b->disk == 1) {
    80006cce:	004aa783          	lw	a5,4(s5)
    80006cd2:	fe9788e3          	beq	a5,s1,80006cc2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006cd6:	f8042903          	lw	s2,-128(s0)
    80006cda:	20090793          	addi	a5,s2,512
    80006cde:	00479713          	slli	a4,a5,0x4
    80006ce2:	0002c797          	auipc	a5,0x2c
    80006ce6:	31e78793          	addi	a5,a5,798 # 80033000 <disk>
    80006cea:	97ba                	add	a5,a5,a4
    80006cec:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006cf0:	0002e997          	auipc	s3,0x2e
    80006cf4:	31098993          	addi	s3,s3,784 # 80035000 <disk+0x2000>
    80006cf8:	00491713          	slli	a4,s2,0x4
    80006cfc:	0009b783          	ld	a5,0(s3)
    80006d00:	97ba                	add	a5,a5,a4
    80006d02:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006d06:	854a                	mv	a0,s2
    80006d08:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006d0c:	00000097          	auipc	ra,0x0
    80006d10:	c5a080e7          	jalr	-934(ra) # 80006966 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006d14:	8885                	andi	s1,s1,1
    80006d16:	f0ed                	bnez	s1,80006cf8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006d18:	0002e517          	auipc	a0,0x2e
    80006d1c:	41050513          	addi	a0,a0,1040 # 80035128 <disk+0x2128>
    80006d20:	ffffa097          	auipc	ra,0xffffa
    80006d24:	f56080e7          	jalr	-170(ra) # 80000c76 <release>
}
    80006d28:	70e6                	ld	ra,120(sp)
    80006d2a:	7446                	ld	s0,112(sp)
    80006d2c:	74a6                	ld	s1,104(sp)
    80006d2e:	7906                	ld	s2,96(sp)
    80006d30:	69e6                	ld	s3,88(sp)
    80006d32:	6a46                	ld	s4,80(sp)
    80006d34:	6aa6                	ld	s5,72(sp)
    80006d36:	6b06                	ld	s6,64(sp)
    80006d38:	7be2                	ld	s7,56(sp)
    80006d3a:	7c42                	ld	s8,48(sp)
    80006d3c:	7ca2                	ld	s9,40(sp)
    80006d3e:	7d02                	ld	s10,32(sp)
    80006d40:	6de2                	ld	s11,24(sp)
    80006d42:	6109                	addi	sp,sp,128
    80006d44:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006d46:	f8042503          	lw	a0,-128(s0)
    80006d4a:	20050793          	addi	a5,a0,512
    80006d4e:	0792                	slli	a5,a5,0x4
  if(write)
    80006d50:	0002c817          	auipc	a6,0x2c
    80006d54:	2b080813          	addi	a6,a6,688 # 80033000 <disk>
    80006d58:	00f80733          	add	a4,a6,a5
    80006d5c:	01a036b3          	snez	a3,s10
    80006d60:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006d64:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006d68:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006d6c:	7679                	lui	a2,0xffffe
    80006d6e:	963e                	add	a2,a2,a5
    80006d70:	0002e697          	auipc	a3,0x2e
    80006d74:	29068693          	addi	a3,a3,656 # 80035000 <disk+0x2000>
    80006d78:	6298                	ld	a4,0(a3)
    80006d7a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006d7c:	0a878593          	addi	a1,a5,168
    80006d80:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006d82:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006d84:	6298                	ld	a4,0(a3)
    80006d86:	9732                	add	a4,a4,a2
    80006d88:	45c1                	li	a1,16
    80006d8a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006d8c:	6298                	ld	a4,0(a3)
    80006d8e:	9732                	add	a4,a4,a2
    80006d90:	4585                	li	a1,1
    80006d92:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006d96:	f8442703          	lw	a4,-124(s0)
    80006d9a:	628c                	ld	a1,0(a3)
    80006d9c:	962e                	add	a2,a2,a1
    80006d9e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffc800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006da2:	0712                	slli	a4,a4,0x4
    80006da4:	6290                	ld	a2,0(a3)
    80006da6:	963a                	add	a2,a2,a4
    80006da8:	058a8593          	addi	a1,s5,88
    80006dac:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006dae:	6294                	ld	a3,0(a3)
    80006db0:	96ba                	add	a3,a3,a4
    80006db2:	40000613          	li	a2,1024
    80006db6:	c690                	sw	a2,8(a3)
  if(write)
    80006db8:	e40d19e3          	bnez	s10,80006c0a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006dbc:	0002e697          	auipc	a3,0x2e
    80006dc0:	2446b683          	ld	a3,580(a3) # 80035000 <disk+0x2000>
    80006dc4:	96ba                	add	a3,a3,a4
    80006dc6:	4609                	li	a2,2
    80006dc8:	00c69623          	sh	a2,12(a3)
    80006dcc:	b5b1                	j	80006c18 <virtio_disk_rw+0xd2>

0000000080006dce <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006dce:	1101                	addi	sp,sp,-32
    80006dd0:	ec06                	sd	ra,24(sp)
    80006dd2:	e822                	sd	s0,16(sp)
    80006dd4:	e426                	sd	s1,8(sp)
    80006dd6:	e04a                	sd	s2,0(sp)
    80006dd8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006dda:	0002e517          	auipc	a0,0x2e
    80006dde:	34e50513          	addi	a0,a0,846 # 80035128 <disk+0x2128>
    80006de2:	ffffa097          	auipc	ra,0xffffa
    80006de6:	de0080e7          	jalr	-544(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006dea:	10001737          	lui	a4,0x10001
    80006dee:	533c                	lw	a5,96(a4)
    80006df0:	8b8d                	andi	a5,a5,3
    80006df2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006df4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006df8:	0002e797          	auipc	a5,0x2e
    80006dfc:	20878793          	addi	a5,a5,520 # 80035000 <disk+0x2000>
    80006e00:	6b94                	ld	a3,16(a5)
    80006e02:	0207d703          	lhu	a4,32(a5)
    80006e06:	0026d783          	lhu	a5,2(a3)
    80006e0a:	06f70163          	beq	a4,a5,80006e6c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006e0e:	0002c917          	auipc	s2,0x2c
    80006e12:	1f290913          	addi	s2,s2,498 # 80033000 <disk>
    80006e16:	0002e497          	auipc	s1,0x2e
    80006e1a:	1ea48493          	addi	s1,s1,490 # 80035000 <disk+0x2000>
    __sync_synchronize();
    80006e1e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006e22:	6898                	ld	a4,16(s1)
    80006e24:	0204d783          	lhu	a5,32(s1)
    80006e28:	8b9d                	andi	a5,a5,7
    80006e2a:	078e                	slli	a5,a5,0x3
    80006e2c:	97ba                	add	a5,a5,a4
    80006e2e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006e30:	20078713          	addi	a4,a5,512
    80006e34:	0712                	slli	a4,a4,0x4
    80006e36:	974a                	add	a4,a4,s2
    80006e38:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006e3c:	e731                	bnez	a4,80006e88 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006e3e:	20078793          	addi	a5,a5,512
    80006e42:	0792                	slli	a5,a5,0x4
    80006e44:	97ca                	add	a5,a5,s2
    80006e46:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006e48:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006e4c:	ffffc097          	auipc	ra,0xffffc
    80006e50:	ab6080e7          	jalr	-1354(ra) # 80002902 <wakeup>

    disk.used_idx += 1;
    80006e54:	0204d783          	lhu	a5,32(s1)
    80006e58:	2785                	addiw	a5,a5,1
    80006e5a:	17c2                	slli	a5,a5,0x30
    80006e5c:	93c1                	srli	a5,a5,0x30
    80006e5e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006e62:	6898                	ld	a4,16(s1)
    80006e64:	00275703          	lhu	a4,2(a4)
    80006e68:	faf71be3          	bne	a4,a5,80006e1e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006e6c:	0002e517          	auipc	a0,0x2e
    80006e70:	2bc50513          	addi	a0,a0,700 # 80035128 <disk+0x2128>
    80006e74:	ffffa097          	auipc	ra,0xffffa
    80006e78:	e02080e7          	jalr	-510(ra) # 80000c76 <release>
}
    80006e7c:	60e2                	ld	ra,24(sp)
    80006e7e:	6442                	ld	s0,16(sp)
    80006e80:	64a2                	ld	s1,8(sp)
    80006e82:	6902                	ld	s2,0(sp)
    80006e84:	6105                	addi	sp,sp,32
    80006e86:	8082                	ret
      panic("virtio_disk_intr status");
    80006e88:	00002517          	auipc	a0,0x2
    80006e8c:	ae850513          	addi	a0,a0,-1304 # 80008970 <syscalls+0x428>
    80006e90:	ffff9097          	auipc	ra,0xffff9
    80006e94:	69a080e7          	jalr	1690(ra) # 8000052a <panic>
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
