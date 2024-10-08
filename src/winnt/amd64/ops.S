.file "ops.S"
.text
#define CULT_STATE_RCX 0
#define CULT_STATE_RDX 8
#define CULT_STATE_R8 16
#define CULT_STATE_R9 24
#define CULT_STATE_RDI 32
#define CULT_STATE_RSI 40
#define CULT_STATE_R12 48
#define CULT_STATE_R13 56
#define CULT_STATE_R14 64
#define CULT_STATE_R15 72
#define CULT_STATE_RBX 80
#define CULT_STATE_RSP 88
#define CULT_STATE_RBP 96
#define CULT_STATE_RIP 104
#define CULT_STATE_VEC 112

#define CULT_STACK_BASE 0
#define CULT_STACK_SIZE 8

#define NT_TIB_STACK_LO 8
#define NT_TIB_STACK_HI 16

# __libcult_convert: initialize first context from enclosing thread
# ARGUMENTS:
#   %rcx: struct libcult_state *self
#   %rdx: void *vgpr - aligned to 16 bytes

    .align 16
    .globl __libcult_convert
__libcult_convert:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    movq %rcx, CULT_STATE_RCX(%rcx)
    movq %rdx, CULT_STATE_RDX(%rcx)
    movq %r8, CULT_STATE_R8(%rcx)
    movq %r9, CULT_STATE_R9(%rcx)
    movq %rdi, CULT_STATE_RDI(%rcx)
    movq %rsi, CULT_STATE_RSI(%rcx)
    movq %r12, CULT_STATE_R12(%rcx)
    movq %r13, CULT_STATE_R13(%rcx)
    movq %r14, CULT_STATE_R14(%rcx)
    movq %r15, CULT_STATE_R15(%rcx)
    movq %rbx, CULT_STATE_RBX(%rcx)

    leaq 8(%rsp), %r11
    movq %r11, CULT_STATE_RSP(%rcx)

    movq (%rsp), %r10
    movq %r10, CULT_STATE_RIP(%rcx)
    movq %rdx, CULT_STATE_VEC(%rcx)
    retq
    .cfi_endproc

# __libcult_restore: decommision libcult state
# NOTE: cannot free vgpr buffer after __libcult_restore is called
# ARGUMENTS
#   %rcx: struct libcult_state *self

    .align 16
    .globl __libcult_restore
__libcult_restore:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    xorl %eax, %eax
    movq %rax, 0(%rcx)
    movq %rax, 8(%rcx)
    movq %rax, 16(%rcx)
    movq %rax, 24(%rcx)
    movq %rax, 32(%rcx)
    movq %rax, 40(%rcx)
    movq %rax, 48(%rcx)
    movq %rax, 64(%rcx)
    movq %rax, 72(%rcx)
    movq %rax, 80(%rcx)
    movq %rax, 88(%rcx)
    movq %rax, 96(%rcx)
    movq %rax, 104(%rcx)
    movq %rax, 112(%rcx)
    retq
    .cfi_endproc

# __libcult_create: initialize libcult context, ready to __libcult_switch()
# ARGUMENTS
#   %rcx: struct libcult_state *child_state
#   %rdx: void *stack_top - NOTE: aligned to 16
#   %r8: void *vgpr_buff - NOTE: aligned to 64
#   %r9: void (*code) (struct libcult *callee, void *info, void *arg0, void *arg1)
#   40(%rsp): struct libcult *child_struct
#   48(%rsp): void *thread_info -
#   56(%rsp): void *arg0 -  NOTE: first user argument
#   64(%rsp): void *arg1 - NOTE: second user argument

    .align 16
    .globl __libcult_create
__libcult_create:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    movq %rdx, CULT_STATE_RSP(%rcx)
    movq %rdx, CULT_STATE_RBP(%rcx)
    movq %r9, CULT_STATE_RIP(%rcx)
    movq %r8, CULT_STATE_VEC(%rcx)

    movq 64(%rsp), %r8
    movq 56(%rsp), %r9
    movq 48(%rsp), %r10
    movq 40(%rsp), %r11

    movq %r11, CULT_STATE_RCX(%rcx)
    movq %r10, CULT_STATE_RDX(%rcx)
    movq %r9, CULT_STATE_R8(%rcx)
    movq %r8, CULT_STATE_R9(%rcx)

    retq
    .cfi_endproc

    .align 16
    .globl __libcult_switch
__libcult_switch:
    .cfi_startproc
    .cfi_def_cfa_offset 0
	movq	%rbx, CULT_STATE_RBX(%rcx)
	movq	%rbp, CULT_STATE_RBP(%rcx)
	movq	%r12, CULT_STATE_R12(%rcx)
	movq	%r13, CULT_STATE_R13(%rcx)
	movq	%r14, CULT_STATE_R14(%rcx)
	movq	%r15, CULT_STATE_R15(%rcx)
	movq	%rdi, CULT_STATE_RDI(%rcx)
	movq	%rsi, CULT_STATE_RSI(%rcx)

	movq	%r9, CULT_STATE_R9(%rcx)
	movq	%r8, CULT_STATE_R8(%rcx)
	movq	%rdx, CULT_STATE_RDX(%rcx)
	movq	%rcx, CULT_STATE_RCX(%rcx)

	movq CULT_STACK_BASE(%r8), %r10
	movq CULT_STACK_SIZE(%r8), %r11
	addq %r10, %r11

	movq %r10, %gs:NT_TIB_STACK_LO
	movq %r11, %gs:NT_TIB_STACK_HI

	movq	(%rsp), %r11
	movq	%r11, CULT_STATE_RIP(%rcx)
	leaq	8(%rsp), %r11		/* Exclude the return address.  */
	movq	%r11, CULT_STATE_RSP(%rcx)

	movq	CULT_STATE_RIP(%rdx), %r10
	movq	CULT_STATE_RSP(%rdx), %rsp
	movq	CULT_STATE_RBP(%rdx), %rbp
    .cfi_def_cfa_offset 0


	movq	CULT_STATE_RBX(%rdx), %rbx
	movq	CULT_STATE_R12(%rdx), %r12
	movq	CULT_STATE_R13(%rdx), %r13
	movq	CULT_STATE_R14(%rdx), %r14
	movq	CULT_STATE_R15(%rdx), %r15
	movq    CULT_STATE_RSI(%rdx), %rsi
	movq	CULT_STATE_RDI(%rdx), %rdi

	movq	CULT_STATE_R8(%rdx), %r8
	movq	CULT_STATE_R9(%rdx), %r9
	movq	CULT_STATE_RCX(%rdx), %rcx
	movq	CULT_STATE_RDX(%rdx), %rdx

    jmp *%r10
	retq
    .cfi_endproc

    .align 16
    .globl __libcult_save_sse128
__libcult_save_sse128:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    movups %xmm0, 0 * 16(%rcx)
    movups %xmm1, 1 * 16(%rcx)
    movups %xmm2, 2 * 16(%rcx)
    movups %xmm3, 3 * 16(%rcx)
    movups %xmm4, 4 * 16(%rcx)
    movups %xmm5, 5 * 16(%rcx)
    movups %xmm6, 6 * 16(%rcx)
    movups %xmm7, 7 * 16(%rcx)
    movups %xmm8, 8 * 16(%rcx)
    movups %xmm9, 9 * 16(%rcx)
    movups %xmm10, 10 * 16(%rcx)
    movups %xmm11, 11 * 16(%rcx)
    movups %xmm12, 12 * 16(%rcx)
    movups %xmm13, 13 * 16(%rcx)
    movups %xmm14, 14 * 16(%rcx)
    movups %xmm15, 15 * 16(%rcx)
    retq
    .cfi_endproc

    .align 16
    .globl __libcult_load_sse128
__libcult_load_sse128:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    movups 0 * 16(%rcx), %xmm0
    movups 1 * 16(%rcx), %xmm1
    movups 2 * 16(%rcx), %xmm2
    movups 3 * 16(%rcx), %xmm3
    movups 4 * 16(%rcx), %xmm4
    movups 5 * 16(%rcx), %xmm5
    movups 6 * 16(%rcx), %xmm6
    movups 7 * 16(%rcx), %xmm7
    movups 8 * 16(%rcx), %xmm8
    movups 9 * 16(%rcx), %xmm9
    movups 10 * 16(%rcx), %xmm10
    movups 11 * 16(%rcx), %xmm11
    movups 12 * 16(%rcx), %xmm12
    movups 13 * 16(%rcx), %xmm13
    movups 14 * 16(%rcx), %xmm14
    movups 15 * 16(%rcx), %xmm15
    retq
    .cfi_endproc

    .align 16
    .globl __libcult_save_avx256
__libcult_save_avx256:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    vmovups %ymm0, 0 * 32(%rcx)
    vmovups %ymm1, 1 * 32(%rcx)
    vmovups %ymm2, 2 * 32(%rcx)
    vmovups %ymm3, 3 * 32(%rcx)
    vmovups %ymm4, 4 * 32(%rcx)
    vmovups %ymm5, 5 * 32(%rcx)
    vmovups %ymm6, 6 * 32(%rcx)
    vmovups %ymm7, 7 * 32(%rcx)
    vmovups %ymm8, 8 * 32(%rcx)
    vmovups %ymm9, 9 * 32(%rcx)
    vmovups %ymm10, 10 * 32(%rcx)
    vmovups %ymm11, 11 * 32(%rcx)
    vmovups %ymm12, 12 * 32(%rcx)
    vmovups %ymm13, 13 * 32(%rcx)
    vmovups %ymm14, 14 * 32(%rcx)
    vmovups %ymm15, 15 * 32(%rcx)
    retq
    .cfi_endproc

    .align 16
    .globl __libcult_load_avx256
__libcult_load_avx256:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    vmovups 0 * 32(%rcx), %ymm0
    vmovups 1 * 32(%rcx), %ymm1
    vmovups 2 * 32(%rcx), %ymm2
    vmovups 3 * 32(%rcx), %ymm3
    vmovups 4 * 32(%rcx), %ymm4
    vmovups 5 * 32(%rcx), %ymm5
    vmovups 6 * 32(%rcx), %ymm6
    vmovups 7 * 32(%rcx), %ymm7
    vmovups 8 * 32(%rcx), %ymm8
    vmovups 9 * 32(%rcx), %ymm9
    vmovups 10 * 32(%rcx), %ymm10
    vmovups 11 * 32(%rcx), %ymm11
    vmovups 12 * 32(%rcx), %ymm12
    vmovups 13 * 32(%rcx), %ymm13
    vmovups 14 * 32(%rcx), %ymm14
    vmovups 15 * 32(%rcx), %ymm15
    retq
    .cfi_endproc

    .align 16
    .globl __libcult_save_avx512
__libcult_save_avx512:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    vmovups %zmm0, 0 * 64(%rcx)
    vmovups %zmm1, 1 * 64(%rcx)
    vmovups %zmm2, 2 * 64(%rcx)
    vmovups %zmm3, 3 * 64(%rcx)
    vmovups %zmm4, 4 * 64(%rcx)
    vmovups %zmm5, 5 * 64(%rcx)
    vmovups %zmm6, 6 * 64(%rcx)
    vmovups %zmm7, 7 * 64(%rcx)
    vmovups %zmm8, 8 * 64(%rcx)
    vmovups %zmm9, 9 * 64(%rcx)
    vmovups %zmm10, 10 * 64(%rcx)
    vmovups %zmm11, 11 * 64(%rcx)
    vmovups %zmm12, 12 * 64(%rcx)
    vmovups %zmm13, 13 * 64(%rcx)
    vmovups %zmm14, 14 * 64(%rcx)
    vmovups %zmm15, 15 * 64(%rcx)
    vmovups %zmm16, 16 * 64(%rcx)
    vmovups %zmm17, 17 * 64(%rcx)
    vmovups %zmm18, 18 * 64(%rcx)
    vmovups %zmm19, 19 * 64(%rcx)
    vmovups %zmm20, 20 * 64(%rcx)
    vmovups %zmm21, 21 * 64(%rcx)
    vmovups %zmm22, 22 * 64(%rcx)
    vmovups %zmm23, 23 * 64(%rcx)
    vmovups %zmm24, 24 * 64(%rcx)
    vmovups %zmm25, 25 * 64(%rcx)
    vmovups %zmm26, 26 * 64(%rcx)
    vmovups %zmm27, 27 * 64(%rcx)
    vmovups %zmm28, 28 * 64(%rcx)
    vmovups %zmm29, 29 * 64(%rcx)
    vmovups %zmm30, 30 * 64(%rcx)
    vmovups %zmm31, 31 * 64(%rcx)
    retq
    .cfi_endproc

    .align 16
    .globl __libcult_load_avx512
__libcult_load_avx512:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    vmovups 0 * 64(%rcx), %zmm0
    vmovups 1 * 64(%rcx), %zmm1
    vmovups 2 * 64(%rcx), %zmm2
    vmovups 3 * 64(%rcx), %zmm3
    vmovups 4 * 64(%rcx), %zmm4
    vmovups 5 * 64(%rcx), %zmm5
    vmovups 6 * 64(%rcx), %zmm6
    vmovups 7 * 64(%rcx), %zmm7
    vmovups 8 * 64(%rcx), %zmm8
    vmovups 9 * 64(%rcx), %zmm9
    vmovups 10 * 64(%rcx), %zmm10
    vmovups 11 * 64(%rcx), %zmm11
    vmovups 12 * 64(%rcx), %zmm12
    vmovups 13 * 64(%rcx), %zmm13
    vmovups 14 * 64(%rcx), %zmm14
    vmovups 15 * 64(%rcx), %zmm15
    vmovups 16 * 64(%rcx), %zmm16
    vmovups 17 * 64(%rcx), %zmm17
    vmovups 18 * 64(%rcx), %zmm18
    vmovups 19 * 64(%rcx), %zmm19
    vmovups 20 * 64(%rcx), %zmm20
    vmovups 21 * 64(%rcx), %zmm21
    vmovups 22 * 64(%rcx), %zmm22
    vmovups 23 * 64(%rcx), %zmm23
    vmovups 24 * 64(%rcx), %zmm24
    vmovups 25 * 64(%rcx), %zmm25
    vmovups 26 * 64(%rcx), %zmm26
    vmovups 27 * 64(%rcx), %zmm27
    vmovups 28 * 64(%rcx), %zmm28
    vmovups 29 * 64(%rcx), %zmm29
    vmovups 30 * 64(%rcx), %zmm30
    vmovups 31 * 64(%rcx), %zmm31
    retq
    .cfi_endproc
