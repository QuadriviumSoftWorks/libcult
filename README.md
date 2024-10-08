libCULT overview

Q: What is a User Level Thread?
A:

    A user-level thread is a co-operatively scheduled flow of control.
    Also called coroutines, fibers or sometimes, continuations.

    The difference between user-level threads and normal execution is
    that normal execution deallocates local variables upon returning.
    User-level threads do not. State is persistent, but owned by a context.
    Interestingly, user-level threads subsume normal return semanics.
    Local variables within a child function are automatically allocated
    and deallocated.

    The owner of the context can choose to free the stack (and context, if needed)
    at a time of their choosing.

    Like a thread, it contains an execution enviorment. On modern CPUs,
    registers are used to store inputs and outputs produced by ALU and
    memory controller. This includes a record of local variables, whose
    addresses are determined by the value of the stack pointer register.
    Unlike a thread, there is no such interrupting a fiber without the fiber
    knowing. Threads context switch on a timer and fibers context switch when
    the programmer asks it to.

Q: Why User-Level Threads?
A:

    There are a few different use-cases. Some are impossible to solve without them.
    The "Same Fringe" problem is a simple demonstration of co-operative scheduling.
    We walk two binary trees in parallel, and check if the values of the two nodes
    are the same. Fibers avoid frequent access of nodes near the root.

    In a more practical context, generators, state machines and job systems are
    enhanced by fibers.

    Generators and state machines get to use local variables
    instead of a special-case C struct to store local state.
    More importantly, recursion works as expected.

    Job systems can use fibers to suspend a job waiting on child work, while
    not blocking the calling thread. The job system can return to the thread's
    top-level entry point, and dequeue more jobs.

Q: Why libCULT? Why not use existing solutions?
A:

    There are a number of deficiencies in most existing solutions. Windows has its
    Fiber API. POSIX has makecontext(3), Simon Tatham has a solution in C89 and switch
    statements, finally, Yossi Kreinin has a solution with inline assembly and setjmp / longjmp.

    Windows' Fiber API doesn't allow reusing the same stack at different times. The interface
    requires a syscall during creation, to allocate a stack. SwitchToFiber takes a single
    argument, which isn't enough to be honest about inputs and outputs.
    CreateFiber takes a single user argument, so the input data and fiber context need to be
    in the same C struct.

    POSIX's makecontext(3) is deprecated, citing portablility and complexity, which are why this
    library exists. In the API, there is an issue: arguments are passed in via a
    variable argument list of 32-bit integers. glibc corrects this for some platforms (x64),
    but the spec doesn't require this.

Q: What happens if we mix threads and libCULT? And why?
A:

    Mixing threads and fibers is tricky. You can no longer use system primitives. These
    are tied to threads, and fibers can migrate between threads. So WaitForSingleObject is not
    allowed to be called by jobs.

    At a minimum, you need to prevent multiple threads from accessing
    the same stack simultaneously, leading to stack corruption. Wrapping 'struct libcult'
    with a spinlock is the right implementation. The lock must be held while switching, and unlocked by the
    resumed fiber.

    Job systems can suspend a job on a condition, wake up when that condition is true,
    and take on other jobs in-between. This prevents deadlock. If a thread busy-waits
    without dequeuing jobs, forward progress halts when all workers take a job that
    spawns child work.

    It isn't automagic like transactional memory, but it does allow you to express
    starting child work and waiting on it.