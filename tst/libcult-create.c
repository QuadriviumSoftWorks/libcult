#include <libcult/libcult.h>

#include <stdlib.h>
#include <stdio.h>

LIBCULT_FUNC (test_one, fiber, thread, arg0, arg1);
LIBCULT_FUNC (test_two, fiber, thread, arg0, arg1);
LIBCULT_FUNC (test_all, fiber, thread, arg0, arg1);

LIBCULT_FUNC (test_all, fiber, thread, arg0, arg1)
{
    (void) thread;
    (void) arg0;
    (void) arg1;

    struct libcult ctx_one;
    struct libcult ctx_two;

    printf ("%s:%d libcult_create (&test_one = %p, &ctx_one = %p)\n",
            __func__, __LINE__, &test_one, &ctx_one);

    libcult_create (fiber, malloc (8192), 8192, &test_one, &ctx_one, NULL, NULL, NULL);
    libcult_switch (fiber, &ctx_one);

    printf ("%s:%d libcult_create (&test_two = %p, &ctx_two = %p)\n",
            __func__, __LINE__, &test_two, &ctx_two);
    libcult_create (fiber, malloc (8192), 8192, &test_two, &ctx_two, NULL, NULL, NULL);
    libcult_switch (fiber, &ctx_two);

    free (ctx_one.stack.base);
    free (ctx_two.stack.base);

    libcult_switch (fiber, fiber->successor);
}

LIBCULT_FUNC (test_one, fiber, thread, arg0, arg1)
{
    (void) thread;
    (void) arg0;
    (void) arg1;

    libcult_switch (fiber, fiber->successor);
}

LIBCULT_FUNC (test_two, fiber, thread, arg0, arg1)
{
    (void) thread;
    (void) arg0;
    (void) arg1;

    libcult_switch (fiber, fiber->successor);
}

int main (int argc, char **argv)
{
    (void) argc;
    (void) argv;

    LIBCULT_VGPR_DECL (vgpr, 2048, 64);
    struct libcult self;

    libcult_convert (&self, vgpr);

    struct libcult succ;
    libcult_create (&self, malloc (8192), 8192, &test_all, &succ, NULL, NULL, NULL);
    libcult_switch (&self, &succ);

    libcult_restore (&self);

    return 0;
}

