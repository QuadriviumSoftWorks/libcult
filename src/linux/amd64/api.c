#include <libcult/libcult.h>
#include <libcult/arch/linux/amd64/ops.h>

void libcult_convert (struct libcult *libcult, void *vgpr)
{
    libcult->successor = NULL;
    //__libcult_save_avx256 (vgpr);
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
    uint8_t *sp = (uint8_t *) stack_base + (stack_size - 2048);
    uint8_t *vec = sp;
    curr->stack.base = stack_base;
    curr->stack.size = stack_size;
    curr->successor = succ;

    __libcult_create (&curr->state, sp, vec, entry, curr, thread_info, arg0, arg1);
    //__libcult_save_avx256 (curr->state.vec);
}

void libcult_switch (struct libcult *curr, struct libcult *succ)
{
    //__libcult_save_avx256 (curr->state.vec);
    //__libcult_load_avx256 (succ->state.vec);
    __libcult_switch (&curr->state, &succ->state);
}
