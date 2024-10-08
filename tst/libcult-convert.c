#include <libcult/libcult.h>

int main (int argc, char **argv)
{
    (void) argc;
    (void) argv;

    LIBCULT_VGPR_DECL (vgpr, 2048, 64);
    struct libcult self;

    libcult_convert (&self, vgpr); /* NOTE(jesse): convert thread to fiber */
    libcult_restore (&self); /* NOTE(jesse): invalidate fiber context */

    return 0;
}
