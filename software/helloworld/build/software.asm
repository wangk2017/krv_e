
build/software.elf:     file format elf32-littleriscv


Disassembly of section .init:

00000000 <_start>:
   0:	00041197          	auipc	gp,0x41
   4:	81818193          	addi	gp,gp,-2024 # 40818 <__global_pointer$>
   8:	00044117          	auipc	sp,0x44
   c:	ff810113          	addi	sp,sp,-8 # 44000 <_sp>
  10:	00000517          	auipc	a0,0x0
  14:	6b450513          	addi	a0,a0,1716 # 6c4 <__fini_array_end>
  18:	00040597          	auipc	a1,0x40
  1c:	fe858593          	addi	a1,a1,-24 # 40000 <_data>
  20:	00040617          	auipc	a2,0x40
  24:	00060613          	mv	a2,a2
  28:	00c5fc63          	bleu	a2,a1,40 <_start+0x40>
  2c:	00052283          	lw	t0,0(a0)
  30:	0055a023          	sw	t0,0(a1)
  34:	00450513          	addi	a0,a0,4
  38:	00458593          	addi	a1,a1,4
  3c:	fec5e8e3          	bltu	a1,a2,2c <_start+0x2c>
  40:	00040517          	auipc	a0,0x40
  44:	fe050513          	addi	a0,a0,-32 # 40020 <_global_atexit>
  48:	00040597          	auipc	a1,0x40
  4c:	17058593          	addi	a1,a1,368 # 401b8 <_end>
  50:	00b57863          	bleu	a1,a0,60 <_start+0x60>
  54:	00052023          	sw	zero,0(a0)
  58:	00450513          	addi	a0,a0,4
  5c:	feb56ce3          	bltu	a0,a1,54 <_start+0x54>
  60:	00000517          	auipc	a0,0x0
  64:	2d450513          	addi	a0,a0,724 # 334 <__libc_fini_array>
  68:	2b8000ef          	jal	320 <atexit>
  6c:	320000ef          	jal	38c <__libc_init_array>
  70:	014000ef          	jal	84 <main>
  74:	02000513          	li	a0,32
  78:	288000ef          	jal	300 <putchar>

0000007c <mainDone>:
  7c:	0000006f          	j	7c <mainDone>

00000080 <_fini>:
  80:	00008067          	ret

Disassembly of section .text:

00000084 <main>:
  84:	00040537          	lui	a0,0x40
  88:	ff010113          	addi	sp,sp,-16
  8c:	00050513          	mv	a0,a0
  90:	00112623          	sw	ra,12(sp)
  94:	228000ef          	jal	2bc <puts>
  98:	00c12083          	lw	ra,12(sp)
  9c:	00000513          	li	a0,0
  a0:	01010113          	addi	sp,sp,16
  a4:	00008067          	ret

000000a8 <printf_s>:
  a8:	ff010113          	addi	sp,sp,-16
  ac:	00812423          	sw	s0,8(sp)
  b0:	00112623          	sw	ra,12(sp)
  b4:	00050413          	mv	s0,a0
  b8:	00054503          	lbu	a0,0(a0) # 40000 <_data>
  bc:	00050a63          	beqz	a0,d0 <printf_s+0x28>
  c0:	00140413          	addi	s0,s0,1
  c4:	23c000ef          	jal	300 <putchar>
  c8:	00044503          	lbu	a0,0(s0)
  cc:	fe051ae3          	bnez	a0,c0 <printf_s+0x18>
  d0:	00c12083          	lw	ra,12(sp)
  d4:	00812403          	lw	s0,8(sp)
  d8:	01010113          	addi	sp,sp,16
  dc:	00008067          	ret

000000e0 <printf_c>:
  e0:	2200006f          	j	300 <putchar>

000000e4 <printf_d>:
  e4:	fd010113          	addi	sp,sp,-48
  e8:	02912223          	sw	s1,36(sp)
  ec:	02112623          	sw	ra,44(sp)
  f0:	02812423          	sw	s0,40(sp)
  f4:	03212023          	sw	s2,32(sp)
  f8:	00050493          	mv	s1,a0
  fc:	04054c63          	bltz	a0,154 <printf_d+0x70>
 100:	00010913          	mv	s2,sp
 104:	00010413          	mv	s0,sp
 108:	00a00713          	li	a4,10
 10c:	00049463          	bnez	s1,114 <printf_d+0x30>
 110:	01241e63          	bne	s0,s2,12c <printf_d+0x48>
 114:	02e4e7b3          	rem	a5,s1,a4
 118:	00140413          	addi	s0,s0,1
 11c:	03078793          	addi	a5,a5,48
 120:	02e4c4b3          	div	s1,s1,a4
 124:	fef40fa3          	sb	a5,-1(s0)
 128:	fe5ff06f          	j	10c <printf_d+0x28>
 12c:	fff40413          	addi	s0,s0,-1
 130:	00044503          	lbu	a0,0(s0)
 134:	fadff0ef          	jal	e0 <printf_c>
 138:	ff241ae3          	bne	s0,s2,12c <printf_d+0x48>
 13c:	02c12083          	lw	ra,44(sp)
 140:	02812403          	lw	s0,40(sp)
 144:	02412483          	lw	s1,36(sp)
 148:	02012903          	lw	s2,32(sp)
 14c:	03010113          	addi	sp,sp,48
 150:	00008067          	ret
 154:	02d00513          	li	a0,45
 158:	f89ff0ef          	jal	e0 <printf_c>
 15c:	409004b3          	neg	s1,s1
 160:	fa1ff06f          	j	100 <printf_d+0x1c>

00000164 <setStats>:
 164:	00008067          	ret

00000168 <printf>:
 168:	fb010113          	addi	sp,sp,-80
 16c:	01412c23          	sw	s4,24(sp)
 170:	02112623          	sw	ra,44(sp)
 174:	02812423          	sw	s0,40(sp)
 178:	02912223          	sw	s1,36(sp)
 17c:	03212023          	sw	s2,32(sp)
 180:	01312e23          	sw	s3,28(sp)
 184:	01512a23          	sw	s5,20(sp)
 188:	00050a13          	mv	s4,a0
 18c:	00054503          	lbu	a0,0(a0)
 190:	04f12223          	sw	a5,68(sp)
 194:	03410793          	addi	a5,sp,52
 198:	02b12a23          	sw	a1,52(sp)
 19c:	02c12c23          	sw	a2,56(sp)
 1a0:	02d12e23          	sw	a3,60(sp)
 1a4:	04e12023          	sw	a4,64(sp)
 1a8:	05012423          	sw	a6,72(sp)
 1ac:	05112623          	sw	a7,76(sp)
 1b0:	00f12623          	sw	a5,12(sp)
 1b4:	04050863          	beqz	a0,204 <printf+0x9c>
 1b8:	00000413          	li	s0,0
 1bc:	02500a93          	li	s5,37
 1c0:	06300493          	li	s1,99
 1c4:	07300913          	li	s2,115
 1c8:	06400993          	li	s3,100
 1cc:	07551063          	bne	a0,s5,22c <printf+0xc4>
 1d0:	008a0733          	add	a4,s4,s0
 1d4:	0100006f          	j	1e4 <printf+0x7c>
 1d8:	06978663          	beq	a5,s1,244 <printf+0xdc>
 1dc:	09278863          	beq	a5,s2,26c <printf+0x104>
 1e0:	0b378a63          	beq	a5,s3,294 <printf+0x12c>
 1e4:	00174783          	lbu	a5,1(a4)
 1e8:	00140413          	addi	s0,s0,1
 1ec:	00170713          	addi	a4,a4,1
 1f0:	fe0794e3          	bnez	a5,1d8 <printf+0x70>
 1f4:	00140413          	addi	s0,s0,1
 1f8:	008a07b3          	add	a5,s4,s0
 1fc:	0007c503          	lbu	a0,0(a5)
 200:	fc0516e3          	bnez	a0,1cc <printf+0x64>
 204:	02c12083          	lw	ra,44(sp)
 208:	00000513          	li	a0,0
 20c:	02812403          	lw	s0,40(sp)
 210:	02412483          	lw	s1,36(sp)
 214:	02012903          	lw	s2,32(sp)
 218:	01c12983          	lw	s3,28(sp)
 21c:	01812a03          	lw	s4,24(sp)
 220:	01412a83          	lw	s5,20(sp)
 224:	05010113          	addi	sp,sp,80
 228:	00008067          	ret
 22c:	eb5ff0ef          	jal	e0 <printf_c>
 230:	00140413          	addi	s0,s0,1
 234:	008a07b3          	add	a5,s4,s0
 238:	0007c503          	lbu	a0,0(a5)
 23c:	f80518e3          	bnez	a0,1cc <printf+0x64>
 240:	fc5ff06f          	j	204 <printf+0x9c>
 244:	00c12783          	lw	a5,12(sp)
 248:	00140413          	addi	s0,s0,1
 24c:	0007a503          	lw	a0,0(a5)
 250:	00478793          	addi	a5,a5,4
 254:	00f12623          	sw	a5,12(sp)
 258:	e89ff0ef          	jal	e0 <printf_c>
 25c:	008a07b3          	add	a5,s4,s0
 260:	0007c503          	lbu	a0,0(a5)
 264:	f60514e3          	bnez	a0,1cc <printf+0x64>
 268:	f9dff06f          	j	204 <printf+0x9c>
 26c:	00c12783          	lw	a5,12(sp)
 270:	00140413          	addi	s0,s0,1
 274:	0007a503          	lw	a0,0(a5)
 278:	00478793          	addi	a5,a5,4
 27c:	00f12623          	sw	a5,12(sp)
 280:	e29ff0ef          	jal	a8 <printf_s>
 284:	008a07b3          	add	a5,s4,s0
 288:	0007c503          	lbu	a0,0(a5)
 28c:	f40510e3          	bnez	a0,1cc <printf+0x64>
 290:	f75ff06f          	j	204 <printf+0x9c>
 294:	00c12783          	lw	a5,12(sp)
 298:	00140413          	addi	s0,s0,1
 29c:	0007a503          	lw	a0,0(a5)
 2a0:	00478793          	addi	a5,a5,4
 2a4:	00f12623          	sw	a5,12(sp)
 2a8:	e3dff0ef          	jal	e4 <printf_d>
 2ac:	008a07b3          	add	a5,s4,s0
 2b0:	0007c503          	lbu	a0,0(a5)
 2b4:	f0051ce3          	bnez	a0,1cc <printf+0x64>
 2b8:	f4dff06f          	j	204 <printf+0x9c>

000002bc <puts>:
 2bc:	ff010113          	addi	sp,sp,-16
 2c0:	00812423          	sw	s0,8(sp)
 2c4:	00112623          	sw	ra,12(sp)
 2c8:	00050413          	mv	s0,a0
 2cc:	00054503          	lbu	a0,0(a0)
 2d0:	00050a63          	beqz	a0,2e4 <puts+0x28>
 2d4:	00140413          	addi	s0,s0,1
 2d8:	028000ef          	jal	300 <putchar>
 2dc:	00044503          	lbu	a0,0(s0)
 2e0:	fe051ae3          	bnez	a0,2d4 <puts+0x18>
 2e4:	00a00513          	li	a0,10
 2e8:	018000ef          	jal	300 <putchar>
 2ec:	00c12083          	lw	ra,12(sp)
 2f0:	00000513          	li	a0,0
 2f4:	00812403          	lw	s0,8(sp)
 2f8:	01010113          	addi	sp,sp,16
 2fc:	00008067          	ret

00000300 <putchar>:
 300:	70001737          	lui	a4,0x70001
 304:	00072783          	lw	a5,0(a4) # 70001000 <_sp+0x6ffbd000>
 308:	fe079ee3          	bnez	a5,304 <putchar+0x4>
 30c:	00a72023          	sw	a0,0(a4)
 310:	00008067          	ret

00000314 <time>:
 314:	4400c7b7          	lui	a5,0x4400c
 318:	ff87a503          	lw	a0,-8(a5) # 4400bff8 <_sp+0x43fc7ff8>
 31c:	00008067          	ret

00000320 <atexit>:
 320:	00050593          	mv	a1,a0
 324:	00000693          	li	a3,0
 328:	00000613          	li	a2,0
 32c:	00000513          	li	a0,0
 330:	0ec0006f          	j	41c <__register_exitproc>

00000334 <__libc_fini_array>:
 334:	ff010113          	addi	sp,sp,-16
 338:	00812423          	sw	s0,8(sp)
 33c:	00912223          	sw	s1,4(sp)
 340:	6c400793          	li	a5,1732
 344:	6c400413          	li	s0,1732
 348:	40f40433          	sub	s0,s0,a5
 34c:	40245413          	srai	s0,s0,0x2
 350:	00241493          	slli	s1,s0,0x2
 354:	ffc48493          	addi	s1,s1,-4
 358:	00112623          	sw	ra,12(sp)
 35c:	00f484b3          	add	s1,s1,a5
 360:	00040c63          	beqz	s0,378 <__libc_fini_array+0x44>
 364:	0004a783          	lw	a5,0(s1)
 368:	fff40413          	addi	s0,s0,-1
 36c:	ffc48493          	addi	s1,s1,-4
 370:	000780e7          	jalr	a5
 374:	fe0418e3          	bnez	s0,364 <__libc_fini_array+0x30>
 378:	00c12083          	lw	ra,12(sp)
 37c:	00812403          	lw	s0,8(sp)
 380:	00412483          	lw	s1,4(sp)
 384:	01010113          	addi	sp,sp,16
 388:	08000067          	jr	zero,128 # 80 <_fini>

0000038c <__libc_init_array>:
 38c:	ff010113          	addi	sp,sp,-16
 390:	00812423          	sw	s0,8(sp)
 394:	01212023          	sw	s2,0(sp)
 398:	6c400793          	li	a5,1732
 39c:	6c400913          	li	s2,1732
 3a0:	40f90933          	sub	s2,s2,a5
 3a4:	00912223          	sw	s1,4(sp)
 3a8:	00112623          	sw	ra,12(sp)
 3ac:	40295913          	srai	s2,s2,0x2
 3b0:	6c400413          	li	s0,1732
 3b4:	00000493          	li	s1,0
 3b8:	00090c63          	beqz	s2,3d0 <__libc_init_array+0x44>
 3bc:	00042783          	lw	a5,0(s0)
 3c0:	00148493          	addi	s1,s1,1
 3c4:	00440413          	addi	s0,s0,4
 3c8:	000780e7          	jalr	a5
 3cc:	fe9918e3          	bne	s2,s1,3bc <__libc_init_array+0x30>
 3d0:	080000e7          	jalr	zero,128 # 80 <_fini>
 3d4:	6c400793          	li	a5,1732
 3d8:	6c400913          	li	s2,1732
 3dc:	40f90933          	sub	s2,s2,a5
 3e0:	40295913          	srai	s2,s2,0x2
 3e4:	6c400413          	li	s0,1732
 3e8:	00000493          	li	s1,0
 3ec:	00090c63          	beqz	s2,404 <__libc_init_array+0x78>
 3f0:	00042783          	lw	a5,0(s0)
 3f4:	00148493          	addi	s1,s1,1
 3f8:	00440413          	addi	s0,s0,4
 3fc:	000780e7          	jalr	a5
 400:	fe9918e3          	bne	s2,s1,3f0 <__libc_init_array+0x64>
 404:	00c12083          	lw	ra,12(sp)
 408:	00812403          	lw	s0,8(sp)
 40c:	00412483          	lw	s1,4(sp)
 410:	00012903          	lw	s2,0(sp)
 414:	01010113          	addi	sp,sp,16
 418:	00008067          	ret

0000041c <__register_exitproc>:
 41c:	fe010113          	addi	sp,sp,-32
 420:	00812c23          	sw	s0,24(sp)
 424:	00040437          	lui	s0,0x40
 428:	02042783          	lw	a5,32(s0) # 40020 <_global_atexit>
 42c:	00912a23          	sw	s1,20(sp)
 430:	01212823          	sw	s2,16(sp)
 434:	01312623          	sw	s3,12(sp)
 438:	01412423          	sw	s4,8(sp)
 43c:	00112e23          	sw	ra,28(sp)
 440:	00050493          	mv	s1,a0
 444:	00058913          	mv	s2,a1
 448:	00060a13          	mv	s4,a2
 44c:	00068993          	mv	s3,a3
 450:	0c078263          	beqz	a5,514 <__register_exitproc+0xf8>
 454:	0047a703          	lw	a4,4(a5)
 458:	01f00513          	li	a0,31
 45c:	00170593          	addi	a1,a4,1
 460:	04e55263          	ble	a4,a0,4a4 <__register_exitproc+0x88>
 464:	000007b7          	lui	a5,0x0
 468:	00078793          	mv	a5,a5
 46c:	0a078e63          	beqz	a5,528 <__register_exitproc+0x10c>
 470:	19000513          	li	a0,400
 474:	00000317          	auipc	t1,0x0
 478:	b8c300e7          	jalr	t1,-1140 # 0 <_start>
 47c:	00050793          	mv	a5,a0
 480:	0a050463          	beqz	a0,528 <__register_exitproc+0x10c>
 484:	02042703          	lw	a4,32(s0)
 488:	00052223          	sw	zero,4(a0)
 48c:	18052423          	sw	zero,392(a0)
 490:	00e52023          	sw	a4,0(a0)
 494:	02a42023          	sw	a0,32(s0)
 498:	18052623          	sw	zero,396(a0)
 49c:	00100593          	li	a1,1
 4a0:	00000713          	li	a4,0
 4a4:	00271513          	slli	a0,a4,0x2
 4a8:	02049a63          	bnez	s1,4dc <__register_exitproc+0xc0>
 4ac:	00b7a223          	sw	a1,4(a5) # 4 <_start+0x4>
 4b0:	00a787b3          	add	a5,a5,a0
 4b4:	0127a423          	sw	s2,8(a5)
 4b8:	00000513          	li	a0,0
 4bc:	01c12083          	lw	ra,28(sp)
 4c0:	01812403          	lw	s0,24(sp)
 4c4:	01412483          	lw	s1,20(sp)
 4c8:	01012903          	lw	s2,16(sp)
 4cc:	00c12983          	lw	s3,12(sp)
 4d0:	00812a03          	lw	s4,8(sp)
 4d4:	02010113          	addi	sp,sp,32
 4d8:	00008067          	ret
 4dc:	00a786b3          	add	a3,a5,a0
 4e0:	0946a423          	sw	s4,136(a3)
 4e4:	1887a803          	lw	a6,392(a5)
 4e8:	00100613          	li	a2,1
 4ec:	00e61733          	sll	a4,a2,a4
 4f0:	00e86633          	or	a2,a6,a4
 4f4:	18c7a423          	sw	a2,392(a5)
 4f8:	1136a423          	sw	s3,264(a3)
 4fc:	00200693          	li	a3,2
 500:	fad496e3          	bne	s1,a3,4ac <__register_exitproc+0x90>
 504:	18c7a683          	lw	a3,396(a5)
 508:	00e6e733          	or	a4,a3,a4
 50c:	18e7a623          	sw	a4,396(a5)
 510:	f9dff06f          	j	4ac <__register_exitproc+0x90>
 514:	000407b7          	lui	a5,0x40
 518:	02478713          	addi	a4,a5,36 # 40024 <_global_atexit0>
 51c:	02e42023          	sw	a4,32(s0)
 520:	02478793          	addi	a5,a5,36
 524:	f31ff06f          	j	454 <__register_exitproc+0x38>
 528:	fff00513          	li	a0,-1
 52c:	f91ff06f          	j	4bc <__register_exitproc+0xa0>

00000530 <__call_exitprocs>:
 530:	fd010113          	addi	sp,sp,-48
 534:	01612823          	sw	s6,16(sp)
 538:	00000b37          	lui	s6,0x0
 53c:	03212023          	sw	s2,32(sp)
 540:	01412c23          	sw	s4,24(sp)
 544:	01512a23          	sw	s5,20(sp)
 548:	01712623          	sw	s7,12(sp)
 54c:	01812423          	sw	s8,8(sp)
 550:	02112623          	sw	ra,44(sp)
 554:	02812423          	sw	s0,40(sp)
 558:	02912223          	sw	s1,36(sp)
 55c:	01312e23          	sw	s3,28(sp)
 560:	01912223          	sw	s9,4(sp)
 564:	01a12023          	sw	s10,0(sp)
 568:	00050a93          	mv	s5,a0
 56c:	00058913          	mv	s2,a1
 570:	00040bb7          	lui	s7,0x40
 574:	00100a13          	li	s4,1
 578:	fff00c13          	li	s8,-1
 57c:	000b0b13          	mv	s6,s6
 580:	020ba983          	lw	s3,32(s7) # 40020 <_global_atexit>
 584:	06098063          	beqz	s3,5e4 <__call_exitprocs+0xb4>
 588:	020b8d13          	addi	s10,s7,32
 58c:	0049a403          	lw	s0,4(s3)
 590:	00241493          	slli	s1,s0,0x2
 594:	fff40413          	addi	s0,s0,-1
 598:	009984b3          	add	s1,s3,s1
 59c:	00044e63          	bltz	s0,5b8 <__call_exitprocs+0x88>
 5a0:	06090e63          	beqz	s2,61c <__call_exitprocs+0xec>
 5a4:	1044a783          	lw	a5,260(s1)
 5a8:	06f90a63          	beq	s2,a5,61c <__call_exitprocs+0xec>
 5ac:	fff40413          	addi	s0,s0,-1
 5b0:	ffc48493          	addi	s1,s1,-4
 5b4:	ff8416e3          	bne	s0,s8,5a0 <__call_exitprocs+0x70>
 5b8:	020b0663          	beqz	s6,5e4 <__call_exitprocs+0xb4>
 5bc:	0049a783          	lw	a5,4(s3)
 5c0:	0c079863          	bnez	a5,690 <__call_exitprocs+0x160>
 5c4:	0009a783          	lw	a5,0(s3)
 5c8:	00078e63          	beqz	a5,5e4 <__call_exitprocs+0xb4>
 5cc:	00098513          	mv	a0,s3
 5d0:	00fd2023          	sw	a5,0(s10)
 5d4:	00000317          	auipc	t1,0x0
 5d8:	a2c300e7          	jalr	t1,-1492 # 0 <_start>
 5dc:	000d2983          	lw	s3,0(s10)
 5e0:	fa0996e3          	bnez	s3,58c <__call_exitprocs+0x5c>
 5e4:	02c12083          	lw	ra,44(sp)
 5e8:	02812403          	lw	s0,40(sp)
 5ec:	02412483          	lw	s1,36(sp)
 5f0:	02012903          	lw	s2,32(sp)
 5f4:	01c12983          	lw	s3,28(sp)
 5f8:	01812a03          	lw	s4,24(sp)
 5fc:	01412a83          	lw	s5,20(sp)
 600:	01012b03          	lw	s6,16(sp)
 604:	00c12b83          	lw	s7,12(sp)
 608:	00812c03          	lw	s8,8(sp)
 60c:	00412c83          	lw	s9,4(sp)
 610:	00012d03          	lw	s10,0(sp)
 614:	03010113          	addi	sp,sp,48
 618:	00008067          	ret
 61c:	0049a783          	lw	a5,4(s3)
 620:	0044a703          	lw	a4,4(s1)
 624:	fff78793          	addi	a5,a5,-1
 628:	04878a63          	beq	a5,s0,67c <__call_exitprocs+0x14c>
 62c:	0004a223          	sw	zero,4(s1)
 630:	f6070ee3          	beqz	a4,5ac <__call_exitprocs+0x7c>
 634:	1889a783          	lw	a5,392(s3)
 638:	008a16b3          	sll	a3,s4,s0
 63c:	0049ac83          	lw	s9,4(s3)
 640:	00f6f7b3          	and	a5,a3,a5
 644:	02078863          	beqz	a5,674 <__call_exitprocs+0x144>
 648:	18c9a783          	lw	a5,396(s3)
 64c:	00f6f6b3          	and	a3,a3,a5
 650:	02069a63          	bnez	a3,684 <__call_exitprocs+0x154>
 654:	0844a583          	lw	a1,132(s1)
 658:	000a8513          	mv	a0,s5
 65c:	000700e7          	jalr	a4
 660:	0049a783          	lw	a5,4(s3)
 664:	f1979ee3          	bne	a5,s9,580 <__call_exitprocs+0x50>
 668:	000d2783          	lw	a5,0(s10)
 66c:	f53780e3          	beq	a5,s3,5ac <__call_exitprocs+0x7c>
 670:	f11ff06f          	j	580 <__call_exitprocs+0x50>
 674:	000700e7          	jalr	a4
 678:	fe9ff06f          	j	660 <__call_exitprocs+0x130>
 67c:	0089a223          	sw	s0,4(s3)
 680:	fb1ff06f          	j	630 <__call_exitprocs+0x100>
 684:	0844a503          	lw	a0,132(s1)
 688:	000700e7          	jalr	a4
 68c:	fd5ff06f          	j	660 <__call_exitprocs+0x130>
 690:	00098d13          	mv	s10,s3
 694:	0009a983          	lw	s3,0(s3)
 698:	ee099ae3          	bnez	s3,58c <__call_exitprocs+0x5c>
 69c:	f49ff06f          	j	5e4 <__call_exitprocs+0xb4>
 6a0:	0004                	addi	s1,sp,0
 6a2:	0000                	unimp
 6a4:	0014                	addi	a3,sp,0
 6a6:	0000                	unimp
 6a8:	00000003          	lb	zero,0(zero) # 0 <_start>
 6ac:	00554e47          	fmsub.s	ft8,fa0,ft5,ft0,rmm
 6b0:	9d31                	0x9d31
 6b2:	2e1f08f7          	0x2e1f08f7
 6b6:	dba6                	sw	s1,244(sp)
 6b8:	7d44                	flw	fs1,60(a0)
 6ba:	c98dae63          	0xc98dae63
 6be:	7d80                	flw	fs0,56(a1)
 6c0:	f26c                	fsw	fa1,100(a2)
 6c2:	0000ff17          	auipc	t5,0xf
