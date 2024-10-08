#ifndef LIBCULT_H
#define LIBCULT_H

#if defined (__linux__)
#   if defined (__amd64__)
#       include <libcult/arch/linux/amd64/api.h>
#   else /* #if defined (__amd64__) */
#       error "unsupported OS and CPU combination"
#   endif /* #if defined (__amd64__) */
#elif defined (_WIN32)
#   if defined (__amd64__)
#       include <libcult/arch/winnt/amd64/api.h>
#   else /* #if defined (__amd64__) */
#       error "unsupported OS and CPU combination"
#   endif /* #if defined (__amd64__) */
#endif /* #if defined (__linux__) */

#if defined (__GNUC__)
#define libcult_aligned(align) __attribute__ ((aligned (align)))
#endif /* #if defined (__GNUC__) */

struct libcult_state; /* NOTE(jesse): CPU context */
struct libcult_stack; /* NOTE(jesse): stack range */
struct libcult; /* NOTE(jesse): public API struct */

struct libcult {
    struct libcult_state state; /* NOTE(jesse): put state and successor in */
    struct libcult *successor;  /*      contiguous cache lines; stack is cold */
    struct libcult_stack stack; /* NOTE(jesse): deliberately in next cache line */
};

#define LIBCULT_VGPR_DECL(vgprs, bytes, align) \
    libcult_aligned (align) uint8_t vgprs[bytes]

#define LIBCULT_FUNC(fn, fiber, thread, arg0, arg1) \
    void fn (struct libcult *fiber, void *thread, void *arg0, void *arg1)

typedef void (*libcult_func) (struct libcult *fib, void *thr, void *arg0, void *arg1);

/*
 * @libcult_convert (): bootstrap first fiber on a thread
 */
extern void libcult_convert (struct libcult *libcult, void *vgpr);

/*
 * @libcult_restore (): deinitialize fiber, and restore thread status
 */
extern void libcult_restore (struct libcult *libcult);

/*
 * @libcult_create (): create a child fiber
 */
extern void libcult_create (struct libcult *succ,
        void *stack_base, size_t stack_size, libcult_func entry,
        struct libcult *curr, void *thread_info, void *arg0, void *arg1);

/*
 * @libcult_switch (): switch between fiber contexts
 */

extern void libcult_switch (struct libcult *curr, struct libcult *succ);

#endif /* EOF */
