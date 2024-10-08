.file "ops.S"
.text
#define CULT_STATE_RDI 0
#define CULT_STATE_RSI 8
#define CULT_STATE_RDX 16
#define CULT_STATE_RCX 24
#define CULT_STATE_R8 32
#define CULT_STATE_R9 40
#define CULT_STATE_R12 48
#define CULT_STATE_R13 56
#define CULT_STATE_R14 64
#define CULT_STATE_R15 72
#define CULT_STATE_RBX 80
#define CULT_STATE_RSP 88
#define CULT_STATE_RBP 96
#define CULT_STATE_RIP 104
#define CULT_STATE_VEC 112

# __libcult_convert: initialize first context from enclosing thread
# ARGUMENTS:
#   %rdi: struct libcult_state *self
#   %rsi: void *vgpr - aligned to 16 bytes

    .align 16
    .globl __libcult_convert
    .type __libcult_convert, @function
__libcult_convert:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    xorl %eax, %eax
    movq %rdi, CULT_STATE_RDI(%rdi)
    movq %rsi, CULT_STATE_RSI(%rdi)
    movq %rdx, CULT_STATE_RDX(%rdi)
    movq %rcx, CULT_STATE_RCX(%rdi)
    movq %r8, CULT_STATE_R8(%rdi)
    movq %r9, CULT_STATE_R9(%rdi)
    movq %r12, CULT_STATE_R12(%rdi)
    movq %r13, CULT_STATE_R13(%rdi)
    movq %r14, CULT_STATE_R14(%rdi)
    movq %r15, CULT_STATE_R15(%rdi)
    movq %rbx, CULT_STATE_RBX(%rdi)

	leaq 8(%rsp), %r11		/* Exclude the return address.  */
	movq %r11, CULT_STATE_RSP(%rdi)

	movq (%rsp), %r10
	movq %r10, CULT_STATE_RIP(%rdi)

	movq %rsi, CULT_STATE_VEC(%rdi)

    retq
    .cfi_endproc
    .size __libcult_convert, .-__libcult_convert
# __libcult_restore: decommision libcult state
# NOTE: cannot free vgpr buffer after __libcult_restore is called
# ARGUMENTS
#   %rdi: struct libcult_state *self

    .align 16
    .globl __libcult_restore
    .type __libcult_restore, @function
__libcult_restore:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    xorl %eax, %eax
    movq %rax, 0(%rdi)
    movq %rax, 8(%rdi)
    movq %rax, 16(%rdi)
    movq %rax, 24(%rdi)
    movq %rax, 32(%rdi)
    movq %rax, 40(%rdi)
    movq %rax, 48(%rdi)
    movq %rax, 64(%rdi)
    movq %rax, 72(%rdi)
    movq %rax, 80(%rdi)
    movq %rax, 88(%rdi)
    movq %rax, 96(%rdi)
    movq %rax, 104(%rdi)
    movq %rax, 112(%rdi)
    retq
    .cfi_endproc
    .size __libcult_restore, .-__libcult_restore
# __libcult_create: initialize libcult context, ready to __libcult_switch()
# ARGUMENTS
#   %rdi: struct libcult_state *child_state
#   %rsi: void *stack_top - NOTE: aligned to 16
#   %rdx: void *vgpr_buff - NOTE: aligned to 64
#   %rcx: void (*code) (struct libcult *callee, void *info, void *arg0, void *arg1)
#   %r8: struct libcult *child_struct
#   %r9: void *thread_info -
#   8(%rsp): void *arg0 -  NOTE: first user argument
#   16(%rsp): void *arg1 - NOTE: second user argument

    .align 16
    .globl __libcult_create
    .type __libcult_create, @function
__libcult_create:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    movq %rdx, CULT_STATE_VEC(%rdi)
    movq %r8, CULT_STATE_RDI(%rdi)
    movq %r9, CULT_STATE_RSI(%rdi)

    movq 8(%rsp), %r10
    movq %r10, CULT_STATE_RDX(%rdi)

    movq 16(%rsp), %r10
    movq %r10, CULT_STATE_RCX(%rdi)

    leaq -8(%rsi), %r10

    movq %r10, CULT_STATE_RSP(%rdi)
    movq %r10, CULT_STATE_RBP(%rdi)
    movq %rcx, CULT_STATE_RIP(%rdi)

    retq
    .cfi_endproc
    .size __libcult_create, .-__libcult_create

    .align 16
    .globl __libcult_switch
    .type __libcult_switch, @function
__libcult_switch:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    movq %rbx, CULT_STATE_RBX(%rdi)
	movq %rbp, CULT_STATE_RBP(%rdi)
	movq %r12, CULT_STATE_R12(%rdi)
	movq %r13, CULT_STATE_R13(%rdi)
	movq %r14, CULT_STATE_R14(%rdi)
	movq %r15, CULT_STATE_R15(%rdi)

	movq %rdi, CULT_STATE_RDI(%rdi)
	movq %rsi, CULT_STATE_RSI(%rdi)
	movq %rdx, CULT_STATE_RDX(%rdi)
	movq %rcx, CULT_STATE_RCX(%rdi)
	movq %r8, CULT_STATE_R8(%rdi)
	movq %r9, CULT_STATE_R9(%rdi)

	movq (%rsp), %r10
	movq %r10, CULT_STATE_RIP(%rdi)
	leaq 8(%rsp), %r11		/* Exclude the return address.  */
	movq %r11, CULT_STATE_RSP(%rdi)
	.cfi_def_cfa_offset 0

	movq CULT_STATE_RIP(%rsi), %r10
	movq CULT_STATE_RSP(%rsi), %rsp
	movq CULT_STATE_RBP(%rsi), %rbp
	movq CULT_STATE_RBX(%rsi), %rbx
	movq CULT_STATE_R12(%rsi), %r12
	movq CULT_STATE_R13(%rsi), %r13
	movq CULT_STATE_R14(%rsi), %r14
	movq CULT_STATE_R15(%rsi), %r15

	movq CULT_STATE_RDI(%rsi), %rdi
	movq CULT_STATE_RDX(%rsi), %rdx
	movq CULT_STATE_RCX(%rsi), %rcx
	movq CULT_STATE_R8(%rsi), %r8
	movq CULT_STATE_R9(%rsi), %r9
    movq CULT_STATE_RSI(%rsi), %rsi

    jmp *%r10
    retq
    .cfi_endproc
    .size __libcult_switch, .-__libcult_switch

    .align 16
    .globl __libcult_save_sse128
    .type __libcult_save_sse128, @function
__libcult_save_sse128:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    movups %xmm0, 0 * 16(%rdi)
    movups %xmm1, 1 * 16(%rdi)
    movups %xmm2, 2 * 16(%rdi)
    movups %xmm3, 3 * 16(%rdi)
    movups %xmm4, 4 * 16(%rdi)
    movups %xmm5, 5 * 16(%rdi)
    movups %xmm6, 6 * 16(%rdi)
    movups %xmm7, 7 * 16(%rdi)
    movups %xmm8, 8 * 16(%rdi)
    movups %xmm9, 9 * 16(%rdi)
    movups %xmm10, 10 * 16(%rdi)
    movups %xmm11, 11 * 16(%rdi)
    movups %xmm12, 12 * 16(%rdi)
    movups %xmm13, 13 * 16(%rdi)
    movups %xmm14, 14 * 16(%rdi)
    movups %xmm15, 15 * 16(%rdi)
    retq
    .cfi_endproc
    .size __libcult_save_sse128, .-__libcult_save_sse128

    .align 16
    .globl __libcult_load_sse128
    .type __libcult_load_sse128, @function
__libcult_load_sse128:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    movups 0 * 16(%rdi), %xmm0
    movups 1 * 16(%rdi), %xmm1
    movups 2 * 16(%rdi), %xmm2
    movups 3 * 16(%rdi), %xmm3
    movups 4 * 16(%rdi), %xmm4
    movups 5 * 16(%rdi), %xmm5
    movups 6 * 16(%rdi), %xmm6
    movups 7 * 16(%rdi), %xmm7
    movups 8 * 16(%rdi), %xmm8
    movups 9 * 16(%rdi), %xmm9
    movups 10 * 16(%rdi), %xmm10
    movups 11 * 16(%rdi), %xmm11
    movups 12 * 16(%rdi), %xmm12
    movups 13 * 16(%rdi), %xmm13
    movups 14 * 16(%rdi), %xmm14
    movups 15 * 16(%rdi), %xmm15
    retq
    .cfi_endproc
    .size __libcult_load_sse128, .-__libcult_load_sse128

    .align 16
    .globl __libcult_save_avx256
    .type __libcult_save_avx256, @function
__libcult_save_avx256:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    vmovups %ymm0, 0 * 32(%rdi)
    vmovups %ymm1, 1 * 32(%rdi)
    vmovups %ymm2, 2 * 32(%rdi)
    vmovups %ymm3, 3 * 32(%rdi)
    vmovups %ymm4, 4 * 32(%rdi)
    vmovups %ymm5, 5 * 32(%rdi)
    vmovups %ymm6, 6 * 32(%rdi)
    vmovups %ymm7, 7 * 32(%rdi)
    vmovups %ymm8, 8 * 32(%rdi)
    vmovups %ymm9, 9 * 32(%rdi)
    vmovups %ymm10, 10 * 32(%rdi)
    vmovups %ymm11, 11 * 32(%rdi)
    vmovups %ymm12, 12 * 32(%rdi)
    vmovups %ymm13, 13 * 32(%rdi)
    vmovups %ymm14, 14 * 32(%rdi)
    vmovups %ymm15, 15 * 32(%rdi)
    retq
    .cfi_endproc
    .size __libcult_save_avx256, .-__libcult_save_avx256

    .align 16
    .globl __libcult_load_avx256
    .type __libcult_load_avx256, @function
__libcult_load_avx256:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    vmovups 0 * 32(%rdi), %ymm0
    vmovups 1 * 32(%rdi), %ymm1
    vmovups 2 * 32(%rdi), %ymm2
    vmovups 3 * 32(%rdi), %ymm3
    vmovups 4 * 32(%rdi), %ymm4
    vmovups 5 * 32(%rdi), %ymm5
    vmovups 6 * 32(%rdi), %ymm6
    vmovups 7 * 32(%rdi), %ymm7
    vmovups 8 * 32(%rdi), %ymm8
    vmovups 9 * 32(%rdi), %ymm9
    vmovups 10 * 32(%rdi), %ymm10
    vmovups 11 * 32(%rdi), %ymm11
    vmovups 12 * 32(%rdi), %ymm12
    vmovups 13 * 32(%rdi), %ymm13
    vmovups 14 * 32(%rdi), %ymm14
    vmovups 15 * 32(%rdi), %ymm15
    retq
    .cfi_endproc
    .size __libcult_load_avx256, .-__libcult_load_avx256

    .align 16
    .globl __libcult_save_avx512
    .type __libcult_save_avx512, @function
__libcult_save_avx512:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    vmovups %zmm0, 0 * 64(%rdi)
    vmovups %zmm1, 1 * 64(%rdi)
    vmovups %zmm2, 2 * 64(%rdi)
    vmovups %zmm3, 3 * 64(%rdi)
    vmovups %zmm4, 4 * 64(%rdi)
    vmovups %zmm5, 5 * 64(%rdi)
    vmovups %zmm6, 6 * 64(%rdi)
    vmovups %zmm7, 7 * 64(%rdi)
    vmovups %zmm8, 8 * 64(%rdi)
    vmovups %zmm9, 9 * 64(%rdi)
    vmovups %zmm10, 10 * 64(%rdi)
    vmovups %zmm11, 11 * 64(%rdi)
    vmovups %zmm12, 12 * 64(%rdi)
    vmovups %zmm13, 13 * 64(%rdi)
    vmovups %zmm14, 14 * 64(%rdi)
    vmovups %zmm15, 15 * 64(%rdi)
    vmovups %zmm16, 16 * 64(%rdi)
    vmovups %zmm17, 17 * 64(%rdi)
    vmovups %zmm18, 18 * 64(%rdi)
    vmovups %zmm19, 19 * 64(%rdi)
    vmovups %zmm20, 20 * 64(%rdi)
    vmovups %zmm21, 21 * 64(%rdi)
    vmovups %zmm22, 22 * 64(%rdi)
    vmovups %zmm23, 23 * 64(%rdi)
    vmovups %zmm24, 24 * 64(%rdi)
    vmovups %zmm25, 25 * 64(%rdi)
    vmovups %zmm26, 26 * 64(%rdi)
    vmovups %zmm27, 27 * 64(%rdi)
    vmovups %zmm28, 28 * 64(%rdi)
    vmovups %zmm29, 29 * 64(%rdi)
    vmovups %zmm30, 30 * 64(%rdi)
    vmovups %zmm31, 31 * 64(%rdi)
    retq
    .cfi_endproc
    .size __libcult_save_avx512, .-__libcult_save_avx512

    .align 16
    .globl __libcult_load_avx512
    .type __libcult_load_avx512, @function
__libcult_load_avx512:
    .cfi_startproc
    .cfi_def_cfa_offset 0
    vmovups 0 * 64(%rdi), %zmm0
    vmovups 1 * 64(%rdi), %zmm1
    vmovups 2 * 64(%rdi), %zmm2
    vmovups 3 * 64(%rdi), %zmm3
    vmovups 4 * 64(%rdi), %zmm4
    vmovups 5 * 64(%rdi), %zmm5
    vmovups 6 * 64(%rdi), %zmm6
    vmovups 7 * 64(%rdi), %zmm7
    vmovups 8 * 64(%rdi), %zmm8
    vmovups 9 * 64(%rdi), %zmm9
    vmovups 10 * 64(%rdi), %zmm10
    vmovups 11 * 64(%rdi), %zmm11
    vmovups 12 * 64(%rdi), %zmm12
    vmovups 13 * 64(%rdi), %zmm13
    vmovups 14 * 64(%rdi), %zmm14
    vmovups 15 * 64(%rdi), %zmm15
    vmovups 16 * 64(%rdi), %zmm16
    vmovups 17 * 64(%rdi), %zmm17
    vmovups 18 * 64(%rdi), %zmm18
    vmovups 19 * 64(%rdi), %zmm19
    vmovups 20 * 64(%rdi), %zmm20
    vmovups 21 * 64(%rdi), %zmm21
    vmovups 22 * 64(%rdi), %zmm22
    vmovups 23 * 64(%rdi), %zmm23
    vmovups 24 * 64(%rdi), %zmm24
    vmovups 25 * 64(%rdi), %zmm25
    vmovups 26 * 64(%rdi), %zmm26
    vmovups 27 * 64(%rdi), %zmm27
    vmovups 28 * 64(%rdi), %zmm28
    vmovups 29 * 64(%rdi), %zmm29
    vmovups 30 * 64(%rdi), %zmm30
    vmovups 31 * 64(%rdi), %zmm31
    retq
    .cfi_endproc
    .size __libcult_load_avx512, .-__libcult_load_avx512
