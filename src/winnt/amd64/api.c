#include <libcult/libcult.h>
#include <libcult/arch/winnt/amd64/ops.h>

void libcult_convert (struct libcult *libcult, void *vgpr)
{
    libcult->successor = NULL;
    __libcult_convert (&libcult->state, vgpr);
}

void libcult_restore (struct libcult *libcult)
{
    __libcult_restore (&libcult->state);
}

void libcult_create (struct libcult *succ,
        void *stack_base, size_t stack_size, libcult_func entry,
        struct libcult *curr, void *thread_info, void *arg0, void *arg1)
{
    /* NOTE(jlactin): AVX-512 requires 64 byte alignment; AND by 63 */
    uint8_t *top = (uint8_t *) ((size_t) (stack_base + stack_size - 64) & ~63);
    uint8_t *vec = (top - 2048);
    uint8_t *sp = vec - 8;

    curr->stack.base = stack_base;
    curr->stack.size = stack_size;
    curr->successor = succ;

    __libcult_create (&curr->state, sp, vec, entry, curr, thread_info, arg0, arg1);
}

void libcult_switch (struct libcult *curr, struct libcult *succ)
{
    __libcult_switch (&curr->state, &succ->state, &succ->stack);
}
