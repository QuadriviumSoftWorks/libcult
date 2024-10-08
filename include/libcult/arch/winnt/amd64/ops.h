#ifndef LIBCULT_WINNT_AMD64_OPS_H
#define LIBCULT_WINNT_AMD64_OPS_H

struct libcult_stack;
struct libcult_state;
struct libcult;

extern void __libcult_load_sse128 (void *vgpr);
extern void __libcult_save_sse128 (void *vgpr);

extern void __libcult_load_avx256 (void *vgpr);
extern void __libcult_save_avx256 (void *vgpr);

extern void __libcult_load_avx512 (void *vgpr);
extern void __libcult_save_avx512 (void *vgpr);

extern void __libcult_convert (struct libcult_state *libcult, void *vgpr);
extern void __libcult_restore (struct libcult_state *libcult);
extern void __libcult_create (struct libcult_state *libcult_state,
        void *stack_top, void *vgpr, void *code,
        struct libcult *libcult, void *info, void *arg0, void *arg1);

extern void __libcult_switch (struct libcult_state *curr,
        struct libcult_state *succ, struct libcult_stack *succ_stack);

#endif /* EOF */
