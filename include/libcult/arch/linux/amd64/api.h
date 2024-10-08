#ifndef LIBCULT_LINUX_AMD64_API_H
#define LIBCULT_LINUX_AMD64_API_H

#include <stddef.h>
#include <stdint.h>

typedef uint64_t libcult_reg;

struct libcult_state {
    libcult_reg rdi;
    libcult_reg rsi;
    libcult_reg rdx;
    libcult_reg rcx;
    libcult_reg r8;
    libcult_reg r9;
    libcult_reg r12;
    libcult_reg r13;
    libcult_reg r14;
    libcult_reg r15;
    libcult_reg rbx;
    libcult_reg rsp;
    libcult_reg rbp;
    libcult_reg rip;
    void *vec;
};

struct libcult_stack {
    uint8_t *base;
    size_t size;
};

#endif /* EOF */
