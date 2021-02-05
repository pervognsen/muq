@c  -*-texinfo-*-

@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muq Internals, Muq Internals Overview, Hacker Hints Wrapup, Top
@chapter Muq Internals

@menu
* Muq Internals Overview::
* Vm_Obj Tagbits::
* Job State::
* Instruction Dispatch::
* Job Queues::
* Signals::
* Job Control::
* Loop Stacks::
* Virtual Memory::
* Garbage Collection::
* Transparent Distributed Operation::
* Flatfile Save/Restore::
* Muq Internals Wrapup::
@end menu

@c
@node Muq Internals Overview, Vm_Obj Tagbits, Muq Internals, Muq Internals
@section Muq Internals Overview

This chapter documents the C implementation of Muq.  You do
not need to read or understand this chapter in order to
write application code, much less just use the system as a
user: You only need to read this section if you intend to
read or write Muq server C code, although others may find
that a deeper understanding of the server internals
clarifies various aspects of system design and performance.

@c CRIB
@c Unix implements data privacy via protection bits associated
@c with each file.  Unix files, however, average hundreds of
@c bytes in length, while Muq keys and values may easily
@c average less than a dozen bytes in many plausible
@c applications: Adding protection information to each
@c propertyValue pair could be a real space-efficiency hit.
@c Furthermore, unix-style protection has been tried in other
@c Muq-like servers, and left some people convinced that
@c unix-style protection bits are both overkill and often
@c confusing in this context.

@c
@node Vm_Obj Tagbits, Job State, Muq Internals Overview, Muq Internals
@section Vm_Obj Tagbits

Muq Vm_Obj variables are basically 32-bit unsigneds,
which can be used to refer to any user-visible object in the
system: They are the basic type manipulated by a @sc{muf}
programmer.

Muq Vm_Obj values store the types of certain (small)
datatypes within the pointer itself.  In fact, they store
the @emph{values} of certain (smaller!) datatypes within the
pointer itself, also.

We interpret the meaning of a @code{Vm_Obj} by examining
the least significant eleven bits.  Those with five-bit
tags are pointers into the virtual memory pool;  The
remainder are immediate values stored in the pointer
itself, except for the ephemeral values, which are
offsets into some loop stack:

@example
Bit:
A9876543210   Meaning
-----------   ---------------------------------------------
*********00   62-bit int   in upper 62 bits.
*********10   Reserved for immediate complex values.
******11111   59-bit float in upper 59 bits.
******11101   Bignum
******11011   Struct (also CLOS objects and bignums).
******11001   Thunk/promise.
******10111   Procedure.
******10101   Standard obj stored in vm_obj.
******10011   CONS cell.
******10001   Symbol.
******01111   Vector.
******01101   Doublevector
******01011   Floatvector
******01001   Intvector
******00111   Shortvector.
******00101   Bytevector. (String.)
******00011   Bitvector.
#ifdef OLD
***11100001   A 0-byte byte string.
***11000001   A 1-byte byte string (o >> 24)
***10100001   A 2-byte byte string (o >> 24), (o >> 16)
***10000001   A 3-byte byte string (o >> 24), (o >> 16), (o >> 8)
#else
00011100001   A 0-byte byte string.
00111100001   A 1-byte byte string.
01011100001   A 2-byte byte string.
***11000001   A 3-byte byte string
10011100001   A 4-byte byte string.
10111100001   A 5-byte byte string.
11011100001   A 6-byte byte string.
***10100001   A 7-byte byte string.
***10000001   Unused (RBGA values?)
#endif
xxx01100001   Reserved for nonzero xxx.
00001100001   Bottom-of-stack value.
1**01000001   Reserved for future ephemeral types.
01101000001   Ephemeral (stack-allocated)  vectors.
01001000001   Ephemeral (stack-allocated)  structs.
00101000001   Ephemeral (stack-allocated)  objects.
00001000001   Special values such as OBJ_NOT_FOUND.
xxx00100001   Reserved for nonzero xxx.
00000100001   Top-of-block value.
***00000001   Char.
@end example

@c
@node Job State, Instruction Dispatch, Vm_Obj Tagbits, Muq Internals
@section Job State

We store the state of inactive jobs (== 'threads' ~=
'processes') in standard muq objects of class Job.  For
speed, we cache the state of the currently running process
in a global static C struct 'state'.

@c
@node Instruction Dispatch, Job Queues, Job State, Muq Internals
@section Instruction Dispatch

We would like to keep within a worst-case factor of 10 of C
in speed, keeping a careful watch to make sure that every
cycle taken on the common bytecodes really is necessary.
For example, just because we call a prim function, does not
mean it needs to waste a cycle returning.

On at least some machines, jumps are particularly expensive,
since they screw up the prefetch queue and make a mess of
pipelining, so we are particularly careful to minimize
jumps.  Short of compiling native code, we need a logical
minimum of one jump per opcode executed.  We can achieve
this minimum by branching through a dispatch table indexed
by opcode, and replicating the dispatch logic at the bottom
of each fast primitive, to save a return jump.

It is easy for an interpreter to wind up wasting a
ridiculous amount of time checking for stack over/underflow
and argument types: This can easily add several conditional
jumps to a simple ADD primitive if not watched carefully.

We can tackle this by saving argument types explicitly on
the stack, and having our dispatch code fold the types of
the top two stack arguments into the table-index value.
This implements both argument type-checking for the fast
arithmetic prims --- if we jump to them, they know they have
the right argument types --- and also stack underflow
checking, since we keep two dummy arguments with bad types
on the bottom of the stack.

We can keep sufficient spare space above the stack pointer
at all times to prevent the fast prims from having to worry
about stack overflow.

This line of thought leads us to putting something like

@example
  table[  *++pc  |  typ0(stack_top[0])  |  typ1(stack_top[-1])  ]();
@end example

at the bottom of every fast primitive, where @code{typ0} and
@code{typ1} are macros producing type info pre-shifted to
mesh appropriately with our bytecode.  This appears to be a
very nearly optimal bytecode dispatch design:  Every fast
binary op clearly needs an opcode fetch, pc increment, and
checks on both arguments.  Unary and nullary ops are paying
for one or two typechecks they don't need, but attempting to
avoid this appears likely to add as much work as we are
saving.

The main problem with the above is that it does not implement
instruction limits.  One could try to do this via interrupts
or such, to keep it from slowing down the instruction
dispatch code, but for now at least we fold this into our
dispatch macro.  @emph{sigh}.

See the @sc{JOB_NEXT} @code{#define} in @file{jobprims.h} or
@file{jobbuild.c} for the actual dispatch code.

@c
@node Job Queues, Signals, Instruction Dispatch, Muq Internals
@section Job Queues

Every live job is in exactly one job queue at any given moment.
In addition, all live jobs are in the @file{.ps} propdir.

@example
  Jobs ready to run: .etc.run queue.
  'sleep'ing jobs:   .etc.doz queue.
  'pause'd   jobs:   .etc.poz queue.
  Stopped    jobs:   .etc.stp queue.
@end example

Dead jobs are not actually in any queue (being in a queue
would keep them from ever being garbage-collected), but
their @code{q_this} entry points to @file{.etc.ded}, to make their
@code{status} well-defined.

All other jobs are in a queue associated with the resource for which
they are waiting:

@display
  Jobs waiting to read from an empty message stream are in its q_in.
  Jobs waiting to write to  a  full  message stream are in its q_out.
@end display

The @file{.etc.doz} queue for sleeping jobs is sorted by
time waited-for; all other queues rotate chronologically,
with jobs inserted at the @code{prev} end and removed from the
@code{next} end.

A job queue (joq) is a 4-vector with the logical structure:

@example
struct joq @{
   Vm_Obj next;  // Next job in queue.
   Vm_Obj prev;  // Prev job in queue.
   Vm_Obj owner; // Owner of    queue.
   Vm_Obj name;  // Queue name: "in" "out" "run" "doz" "poz" "stp" @dots{}
@};
@end example

Jobs are doubly linked into their queue via their
@code{q_next} and @code{q_prev} fields.  In an empty queue,
@code{next} and @code{prev} point to the queue itself.

The currently running job is always @code{next} in the run
queue.  The run queue can be empty, in which case nothing
much will happen until some external event wakes a job from
some queue --- network I/O unblocking a job waiting on a
message stream, say, or clock timing waking an
@file{.etc.doz} job.


@c
@node Signals, Job Control, Job Queues, Muq Internals
@section Signals

Signals are an asynchronous communication mechanism between jobs: by
sending a signal to another job J, a job can kill or suspend J, or
cause it to execute some J-selected bit of code.  Typical uses are to
stop runaway processes, to notify a job of some event in which it is
interested or for which it it waiting, or to notify the job of some
internal error event such as divide-by-zero or resource
exhaustion.

Muq signals closely follow the unix model (specifically the
@sc{POSIX.1} model with job control).  Asynchronous
communication is a treacherous programming area, it seemed
best to stick close to known ground, both to smooth
implementation and to reduce surprises for programmers
moving between muq and unix.

Muq supports a fixed finite (currently 21) number of
signals.  Each job has, for each signal, a slot for a
user-supplied signal handler function, and an integer mask
specifying signals which should be blocked while that
handler is running.  These slots and masks are object
properties accessable via normal keyval get and set
operators in muf.

Signals are 'reliable': a bitmap is kept of pending interrupts, which
will eventually be delivered if the process unblocks them (and does
not terminate or such first).

Signals are not 'queued': if the same interrupt is given several times
before the job has a chance to respond, the corresponding handler will
be called only once, since muq's pending-interrupt bitmap is
sufficient only to record that the interrupt has arrived at least
once.

The names and meanings of Muq signals follow unix/posix as closely
as practical.

@c
@node Job Control, Loop Stacks, Signals, Muq Internals
@section Job Control

Practical experience with sophisticated unix users led Berkeley Unix
to introduce job control, the facility that lets one suspend a running
unix task by typing (typically) ^Z, or kill it by typing (typically)
^C.

Implementing this sort of seemingly simple facility requires a
moderately sophisticated data structure:

@itemize @bullet
@item
A unix task may consist of a cluster of related processes connected by
pipes, all of which must be suspended or re-activated as a group;

@item
Questions of what to do when background tasks attempt to read or write
the controlling terminal must be dealt with;

@item
The active shell must be notified of suspend/kill events somehow,
and needs appropriate tools for manipulating groups of related
processes.
@end itemize

The unix solution is to group into a 'session' all processes belonging
to a single login, and within the session to group all processes
implementing a single user command into a 'process group', which may
then as a unit be killed, suspended, activated or moved between
foreground and background, via appropriate signals to the process
group (which are then merely sent to all the processes in the group).

Muq follows the unix model quite closely, with session ('ssn') objects
which may be created via make-session, job sets ('jbs') objects which
may be created via make-jobset, and job control signals closely
patterned on unix.

@c
@node Loop Stacks, Loop Stacks Overview, Job Control, Muq Internals
@section Loop Stacks

Muq supports the following kinds of loop stack stackframes (so far):

@example
JOB_STACKFRAME_THUNK  , pushed when starting evaluation of a thunk.
JOB_STACKFRAME_NORMAL , pushed by a normal CALL or EXECUTE;
JOB_STACKFRAME_CATCH  , pushed by a CATCH@{ @} command.
JOB_STACKFRAME_TAG    , pushed by a TAG@{ @} command.
JOB_STACKFRAME_TAGTOP , pushed by a TAG@{ @} command.
JOB_STACKFRAME_LOCK   , pushed while running with-lock-do@{ ... code.
JOB_STACKFRAME_LOCK_CHILD, pushed while running with-child-lock-do@{ ... code.
JOB_STACKFRAME_NULL   , unwanted LOCK frames get changed to this.
JOB_STACKFRAME_USER   , pushed while running as-me@{...@}/as-user@{...@} code.
JOB_STACKFRAME_PRIVS  , pushed while running omnipotently-do@{...@} code.
JOB_STACKFRAME_PROTECT, pushed while running after@{ ... clause code.
JOB_STACKFRAME_PROTECT_CHILD, pushed while running after-child-does@{ ...
JOB_STACKFRAME_THROW  , pushed while running @}always_do@{ ... code in throw.
JOB_STACKFRAME_ENDJOB , pushed while running @}always_do@{ ... code in endjob.
JOB_STACKFRAME_EXEC   , pushed while running @}always_do@{ ... code in exec.
JOB_STACKFRAME_GOTO   , pushed while running @}always_do@{ ... code in goto.
JOB_STACKFRAME_RETURN , pushed while running @}always_do@{ ... code in return.
JOB_STACKFRAME_JUMP   , pushed while running @}always_do@{ ... code in jump.
JOB_STACKFRAME_VANILLA, pushed while running @}always_do@{ ... code normally.
JOB_STACKFRAME_RESTART, pushed by a ]with-restart-do@{...@} command.
JOB_STACKFRAME_TMP_USER,pushed while running handlers.
JOB_STACKFRAME_FUN_BIND,pushed when binding a function to a symbol.
JOB_STACKFRAME_VAR_BIND,pushed when binding a value    to a symbol.
JOB_STACKFRAME_EPHEMERAL_LIST,   pushed when storing one on stack.
JOB_STACKFRAME_EPHEMERAL_STRUCT, pushed when storing one on stack.
JOB_STACKFRAME_EPHEMERAL_VECTOR, pushed when storing one on stack.
@end example

Be warned that the stackframe types and layouts are far
from finalized in Muq v -1.13.0: Count on significant
changes in future releases.

@menu
* Loop Stacks Overview::
* JOB_STACKFRAME_NORMAL::
* JOB_STACKFRAME_THUNK::
* JOB_STACKFRAME_CATCH::
* JOB_STACKFRAME_TAG::
* JOB_STACKFRAME_TAGTOP::
* JOB_STACKFRAME_LOCK::
* JOB_STACKFRAME_LOCK_CHILD::
* JOB_STACKFRAME_NULL::
* JOB_STACKFRAME_USER::
* JOB_STACKFRAME_TMP_USER::
* JOB_STACKFRAME_PRIVS::
* JOB_STACKFRAME_PROTECT::
* JOB_STACKFRAME_PROTECT_CHILD::
* JOB_STACKFRAME_THROW::
* JOB_STACKFRAME_ENDJOB::
* JOB_STACKFRAME_EXEC::
* JOB_STACKFRAME_GOTO::
* JOB_STACKFRAME_RETURN::
* JOB_STACKFRAME_JUMP::
* JOB_STACKFRAME_VANILLA::
* JOB_STACKFRAME_RESTART::
* JOB_STACKFRAME_HANDLERS::
* JOB_STACKFRAME_HANDLING::
* JOB_STACKFRAME_FUN_BIND::
* JOB_STACKFRAME_VAR_BIND::
* JOB_STACKFRAME_EPHEMERAL_LIST::
* JOB_STACKFRAME_EPHEMERAL_STRUCT::
* JOB_STACKFRAME_EPHEMERAL_VECTOR::
* Loop Stacks Wrapup::
@end menu

@c
@node  Loop Stacks Overview, JOB_STACKFRAME_NORMAL, Loop Stacks, Loop Stacks
@subsection Loop Stacks Overview

Each time a @sc{muf} function F calls another function G,
Muq must somehow remember remember where it was in F, so as
to be able to pick up where it left off after G returns.

In the distant early days of computing, this was done simply
by saving a pointer to the appropriate instruction inside of
function F itself.  This turned out to be a fairly uncool
idea, since it meant that F could not call itself repeatedly
without completely losing track of where it was supposed to
return to.  In a multi-user system like Muq, in which many
different users may wish to use F at the "same" time, things
would be even worse!

Thus, nowadays almost every language uses a stack to hold
these return addresses (and most computers now have special
instructions for maintaining such stacks.)  A code sequence
like

@example
: H 1 + ;
: G -> x   x H  x H  * ;
: F -> y   y G  2 * ;
13 F ,
@end example

@noindent
is implemented by a series of loop stack operations which
look like this:

@example
Loop stack top ->  +------+     ( Loop stack is empty. )

                   +------+
Loop stack top ->  |   ,  |     ( Address of ',' saved while calling F )
                   +------+

                   +------+
Loop stack top ->  | F: 2 |     ( Address of '2' in F while calling G  )
                   +------+
                   |   ,  |
                   +------+

                   +------+
Loop stack top ->  | G: x |     ( Address of 'x' in G while calling H  )
                   +------+
                   | F: 2 |     ( Address of '2' in F while calling G  )
                   +------+
                   |   ,  |
                   +------+

                   +------+
Loop stack top ->  | F: 2 |     ( Back in G after 1st call to H )
                   +------+
                   |   ,  |
                   +------+

                   +------+
Loop stack top ->  | G: * |     ( Address of '*' in G while calling H  )
                   +------+
                   | F: 2 |     ( Address of '2' in F while calling G  )
                   +------+
                   |   ,  |
                   +------+

                   +------+
Loop stack top ->  | F: 2 |     ( Back in G after 2nd call to H )
                   +------+
                   |   ,  |
                   +------+

                   +------+
Loop stack top ->  |   ,  |     ( Back in F after call to G )
                   +------+

Loop stack top ->  +------+     ( Done, loop stack is again empty. )
@end example

We also need some place to keep the values of local
variables within a function.  It is natural and efficient to
keep them on the loop stack as well.  Adding them, plus a
count of them plus a frame label results in a normal
stackframe looking as follows.

@c
@node  JOB_STACKFRAME_NORMAL, JOB_STACKFRAME_THUNK, Loop Stacks Overview, Loop Stacks
@subsection JOB_STACKFRAME_NORMAL

@example
  job_RunState.l   ->   size in bytes of stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of stackframe
@end example

@noindent
where job_RunState.l is an internal interpreter variable
pointing to the current top of loop stack, and
job_RunState.v is an internal interpreter variable pointing
to the currently active set of local variables.

Rationale:
@itemize @bullet
@item
We need an explicit stackframe type so THROW, ERROR etc can walk
down the loop stack looking for what they want;

@item
We need to save 'x_obj' and 'pc' so we can continue execution at the
correct bytecode upon return to function;

@item
We need size of stack frame at both top and bottom so as to be able to
traverse the stack either direction.  The given size includes both top
and bottom sizewords, and the size is stored as a straight C integer,
not a Muq-encoded one.  (This is slightly unclean, but is safe because
the stackframe sizes will all be a multiple of sizeof(Vm_Obj) --- four
bytes on 32-bit machines --- and hence will have the least significant
bit zero and thus will look like a Muq integer to any Muq code
inspecting the size slots.  This slight uncleanliness buys us the
ability to walk down the stack at maximum plausible speed.)
@end itemize   

Note: The very bottom stackframe on a stack has a zero
word below it.  This stops any attempt to traverse
down past the bottom of the stack:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
                        ZERO WORD
@end example

A full @code{getStackframe[} @sc{normal} frame result looks like:

@example
:owner             object
:kind              :normal
:programCounter   fixnum
:compiledFunction object
:variables         count of local variables
0                  value of local_variable_0
1                  value of local_variable_1
...                ...
@end example

@c
@node  JOB_STACKFRAME_THUNK, JOB_STACKFRAME_CATCH, JOB_STACKFRAME_NORMAL, Loop Stacks
@subsection JOB_STACKFRAME_THUNK

JOB_STACKFRAME_THUNK stackframes in context look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_THUNK
			stack slot in which to place thunk return value
                        saved logical-bottom-of-data-stack.
			saved actual_user
			saved acting_user
			saved privs
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

Rationale:
@itemize @bullet
@item
A function may take any number of arguments, and any of them may
prove to be a thunk requiring evaluation.  We need to remember
where in the stack to put the return value from the thunk when
it completes execution.

@item
We need to create a logically empty data stack in order to prevent
the thunk from messing with existing stack contents, which could
be a security and/or privacy breach.  Hence the need to save the
old logical-bottom-of-data-stack for later restoration.

@item
We need to clear the privilege-conferring entries in the job state
to innocuous values for similar security/privacy reasons,
and must save them for later restoration before doing so.
POSSIBLE BUG:  It doesn't seem safe to clear current 'job' entry;
If any special privileges are accessable via it, thunks may be
a privacy/security hole.
@end itemize

A full @code{getStackframe[} @sc{thunk} frame result looks like:

@example
:owner             object
:kind              :thunk
:privileges	   fixnum
:actingUser       object
:actualUser       object
:stackBottom      fixnum
:return-slot       fixnum
@end example

@c
@node  JOB_STACKFRAME_CATCH, JOB_STACKFRAME_TAG, JOB_STACKFRAME_THUNK, Loop Stacks
@subsection JOB_STACKFRAME_CATCH

JOB_STACKFRAME_CATCH stackframes in context look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_CATCH
                        saved catch tag
                        saved job_RunState.s (after catch args popped)
                        pc to resume execution at (after catching error)
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_CATCH
                        saved catch tag
                        saved job_RunState.s (after catch args popped)
                        pc to resume execution at (after catching error)
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

(An errset just uses a CATCH with a tag of the loopstack itself -- a
value user code should never be able to directly access.)

We show two CATCH frames here only to emphasize that they
can be nested without needing one NORMAL frame each.  This
is also true of all following stackframe types.

Rationale:

@itemize @bullet
@item
We need to restore a reasonable datastack depth so that code can
continue reasonably after the error.

@item
We need to save the catch tag so 'throw' can select an appropriate
catch frame.

@item
We want to be able to lexically nest ECATCH commands within
a function -- partly because lisp does this, partly because we'd like
access to local variables within the guarded expression(s).
@end itemize

A full @code{getStackframe[} @sc{catch} frame result looks like:

@example
:owner             object
:kind              :catch
:programCounter   fixnum
:stack-depth       fixnum
:tag               symbol
@end example


@c
@node  JOB_STACKFRAME_TAG, JOB_STACKFRAME_TAGTOP, JOB_STACKFRAME_CATCH, Loop Stacks
@subsection JOB_STACKFRAME_TAG

@sc{job_stackframe_tag} stackframes in context look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        @sc{job_stackframe_tagtop}
                        saved job_RunState.s (after catch args popped)
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        @sc{job_stackframe_tag}
                        saved tag
                        pc to resume execution at (after catching goto)
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        @sc{job_stackframe_normal}   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

These frames record a location to which nonlocal gotos are
allowed.  This is like a simplified form of @sc{catch} in
which neither an argument block nor a flag is returned.

A full @code{getStackframe[} @sc{tag} frame result looks like:

@example
:owner             object
:kind              :tag
:programCounter   fixnum
:tag               symbol
@end example

@c
@node  JOB_STACKFRAME_TAGTOP, JOB_STACKFRAME_LOCK, JOB_STACKFRAME_TAG, Loop Stacks
@subsection JOB_STACKFRAME_TAGTOP

@sc{job_stackframe_tagtop} stackframes in context look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        @sc{job_stackframe_tagtop}
                        saved job_RunState.s
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        @sc{job_stackframe_tag}
                        saved tag
                        pc to resume execution at (after catching goto)
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        @sc{job_stackframe_normal}   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

These frames record a location to which nonlocal gotos are
allowed.  This is just a simplified form of @sc{catch} in
which neither an argument block nor a flag is returned.

A full @code{getStackframe[} @sc{tagtop} frame result looks like:

@example
:owner             object
:kind              :tagtop
:stack-depth       fixnum
@end example


@c
@node  JOB_STACKFRAME_LOCK, JOB_STACKFRAME_LOCK_CHILD, JOB_STACKFRAME_TAGTOP, Loop Stacks
@subsection JOB_STACKFRAME_LOCK

JOB_STACKFRAME_LOCK stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_LOCK
                        lock object held by job
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

These stackframes are pushed to mark the scope of an
@code{with-lock-do@{...@}} clause, and include a pointer to the
lock held by the job during this interval: The point is to
ensure that the server can reliably find and release all
locks held by a job when killing it.  To ensure this, the
@code{pushLockframe} instruction is the @emph{only}
supported way of acquiring a lock.

A full @code{getStackframe[} @sc{lock} frame result looks like:

@example
:owner             object
:kind              :lock
:lock              object
@end example

@c
@node  JOB_STACKFRAME_LOCK_CHILD, JOB_STACKFRAME_NULL, JOB_STACKFRAME_LOCK, Loop Stacks
@subsection JOB_STACKFRAME_LOCK_CHILD

JOB_STACKFRAME_LOCK_CHILD stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_LOCK_CHILD
                        lock object held by job
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

These stackframes are pushed to mark the scope of an
@code{with-child-lock-do@{...@}} clause, and include a pointer to the
lock held by the job during this interval: The point is to
ensure that the server can reliably find and release all
locks held by a job when killing it.  To ensure this, the
@code{pushLockframe*} instructions are the @emph{only}
supported way of acquiring a lock.

A full @code{getStackframe[} @sc{lock} frame result looks like:

@example
:owner             object
:kind              :lock-child
:lock              object
@end example

@c
@node  JOB_STACKFRAME_NULL, JOB_STACKFRAME_USER, JOB_STACKFRAME_LOCK_CHILD, Loop Stacks
@subsection JOB_STACKFRAME_NULL

JOB_STACKFRAME_NULL stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_NULL
                        junk
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

When we fork, we want only the parent to hold the lock.
(This is the unix tradition.)  So we convert all @sc{lock}
frames held by the child into @sc{null} frames.  These
frames are ignored except that when trying to pop a
@sc{lock} frame, a @sc{null} frame will be accepted
as a substitute.

A full @code{getStackframe[} @sc{null} frame result looks like:

@example
:owner             object
:kind              nil
@end example

@c
@node  JOB_STACKFRAME_USER, JOB_STACKFRAME_TMP_USER, JOB_STACKFRAME_NULL, Loop Stacks
@subsection JOB_STACKFRAME_USER

JOB_STACKFRAME_USER stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_USER
                        previous actingUser value
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

These stackframes are pushed to mark the scope of an
@code{as-me@{...@}} or @code{as-user@{...@}} clause, during
which the @code{@@$s.actingUser} value is changed, and and
save the old @code{@@$s.actingUser} value for later
restoration.

A full @code{getStackframe[} @sc{user} frame result looks like:

@example
:owner             object
:kind              :user
:actingUser       object
@end example

@c
@node  JOB_STACKFRAME_TMP_USER, JOB_STACKFRAME_PRIVS, JOB_STACKFRAME_USER, Loop Stacks
@subsection JOB_STACKFRAME_TMP_USER

@sc{job_stackframe_tmp_user} stackframes in context will look as
follows:

@example

  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_TMP_USER
                        previous actingUser value
                        size in bytes of above stackframe
@end example

These stackframes are pushed to mark the scope of a
handler being executed:  We wish handlers to execute
under the effective user who established them, to
avoid odd problems, but wish the original user
automatically restored upon exit.

The @sc{job_stackframe_tmp_user} stackframe differs
from the @sc{job_stackframe_user} stackframe primarily
in that it is pushed below rather than above the associated
@sc{job_stackframe_user} stackframe, and consequently is
popped when encountered by the @code{return} operator.

A full @code{getStackframe[} @sc{user} frame result looks like:

@example
:owner             object
:kind              :tmp-user
:actingUser       object
@end example

@c
@node  JOB_STACKFRAME_PRIVS, JOB_STACKFRAME_PROTECT, JOB_STACKFRAME_TMP_USER, Loop Stacks
@subsection JOB_STACKFRAME_PRIVS

JOB_STACKFRAME_PRIVS stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_PRIVS
                        old jS.j.privs status for job
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

These stackframes are pushed to mark the scope of an
@code{omnisciently-do@{...@}} clause, or similar clause
changing the @code{jS.j.privs} bitmask, and include a
copy of the original @code{jS.j.privs} bitmask for
later restoration.

A full @code{getStackframe[} @sc{privs} frame result looks like:

@example
:owner             object
:kind              :privileges
:privileges        fixnum
@end example

@c
@node  JOB_STACKFRAME_PROTECT, JOB_STACKFRAME_PROTECT_CHILD, JOB_STACKFRAME_PRIVS, Loop Stacks
@subsection JOB_STACKFRAME_PROTECT

JOB_STACKFRAME_PROTECT stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_PROTECT
                        pc to resume execution at (to run second clause)
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

These stackframes are pushed to mark subsequently executed
code as being under the aegis of an @code{after@{ @dots{}}
type statement, with some trailing @code{@}always_do@{
@dots{} @}} code that the system must execute come hell or
high water.

A full @code{getStackframe[} @sc{protect} frame result looks like:

@example
:owner             object
:kind              :protect
:programCounter   fixnum
@end example

@c
@node  JOB_STACKFRAME_PROTECT_CHILD, JOB_STACKFRAME_THROW, JOB_STACKFRAME_PROTECT, Loop Stacks
@subsection JOB_STACKFRAME_PROTECT_CHILD

JOB_STACKFRAME_PROTECT_CHILD stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_PROTECT_CHILD
                        pc to resume execution at (to run second clause)
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

These stackframes are pushed to mark subsequently executed
code as being under the aegis of an @code{after-child-does@{ @dots{}}
type statement, with some trailing @code{@}always_do@{
@dots{} @}} code that the system must execute come hell or
high water.

A full @code{getStackframe[} @sc{protect} frame result looks like:

@example
:owner             object
:kind              :protect-child
:programCounter   fixnum
@end example

@c
@node  JOB_STACKFRAME_THROW, JOB_STACKFRAME_ENDJOB, JOB_STACKFRAME_PROTECT_CHILD, Loop Stacks
@subsection JOB_STACKFRAME_THROW

@sc{JOB_STACKFRAME_THROW} stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_THROW
                        tag being 'thrown'.
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

This stackframe is pushed when we are actually executing
@sc{@}always_do@{ @dots{} @}} code -- we've halted some sort
of @code{throw} operation midway in order to execute our
@sc{@}always_do@{} clause, and must resume the throw as soon
as the @sc{@}always_do@{} clause completes.

@c
@node  JOB_STACKFRAME_ENDJOB, JOB_STACKFRAME_EXEC, JOB_STACKFRAME_THROW, Loop Stacks
@subsection JOB_STACKFRAME_ENDJOB

@sc{JOB_STACKFRAME_ENDJOB} stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_ENDJOB
                        junk entry.
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

This stackframe is pushed when we are actually executing
@sc{@}always_do@{ @dots{} @}} code -- we've halted an @code{endJob}
operation midway in order to execute our
@sc{@}always_do@{} clause, and must resume the @code{endJob} as soon
as the @sc{@}always_do@{} clause completes.

A full @code{getStackframe[} @sc{endJob} frame result looks like:

@example
:owner             object
:kind              :endJob
:junk              junk
@end example


@c
@node  JOB_STACKFRAME_EXEC, JOB_STACKFRAME_GOTO, JOB_STACKFRAME_ENDJOB, Loop Stacks
@subsection JOB_STACKFRAME_EXEC

@sc{JOB_STACKFRAME_EXEC} stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_EXEC
                        junk entry.
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

This stackframe is pushed when we are actually executing
@sc{@}always_do@{ @dots{} @}} code -- we've halted an @code{exec}
operation midway in order to execute our
@sc{@}always_do@{} clause, and must resume the @code{exec} as soon
as the @sc{@}always_do@{} clause completes.

A full @code{getStackframe[} @sc{exec} frame result looks like:

@example
:owner             object
:kind              :exec
:junk              junk
@end example


@c
@node  JOB_STACKFRAME_GOTO, JOB_STACKFRAME_RETURN, JOB_STACKFRAME_EXEC, Loop Stacks
@subsection JOB_STACKFRAME_GOTO

@sc{JOB_STACKFRAME_GOTO} stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_GOTO
                        tag being 'goto'ed.
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

This stackframe is pushed when we are actually executing
@sc{@}always_do@{ @dots{} @}} code -- we've halted some sort
of @code{goto} operation midway in order to execute our
@sc{@}always_do@{} clause, and must resume the @code{goto} as soon
as the @sc{@}always_do@{} clause completes.

A full @code{getStackframe[} @sc{goto} frame result looks like:

@example
:owner             object
:kind              :goto
:tag               symbol
@end example


@c
@node  JOB_STACKFRAME_RETURN, JOB_STACKFRAME_JUMP, JOB_STACKFRAME_GOTO, Loop Stacks
@subsection JOB_STACKFRAME_RETURN

@sc{JOB_STACKFRAME_RETURN} stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_RETURN
                        junk entry.
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

Just like @sc{JOB_STACKFRAME_THROW} stackframe, except that
it was a @code{return} rather than a @code{throw} that was
interrupted.

A full @code{getStackframe[} @sc{return} frame result looks like:

@example
:owner             object
:kind              :return
:junk              junk
@end example

@c
@node  JOB_STACKFRAME_JUMP, JOB_STACKFRAME_VANILLA, JOB_STACKFRAME_RETURN, Loop Stacks
@subsection JOB_STACKFRAME_JUMP

@sc{JOB_STACKFRAME_JUMP} stackframes in context will look as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_JUMP
                        pc to resume execution at.
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

Just like @sc{JOB_STACKFRAME_THROW} stackframe, except it
was a jump rather than a 'throw' that was interrupted.  This
is needed for cases like

@example
  do@{
    after@{
      ...
      loopFinish;
      ...
    @}always_do@{
      stuff
    @}
  @}
@end example

@noindent
where the @code{loopFinish} must execute @code{stuff}
before actually jumping past loop termination.

A full @code{getStackframe[} @sc{jump} frame result looks like:

@example
:owner             object
:kind              :jump
:programCounter   fixnum
@end example



@c
@node  JOB_STACKFRAME_VANILLA, JOB_STACKFRAME_RESTART, JOB_STACKFRAME_JUMP, Loop Stacks
@subsection JOB_STACKFRAME_VANILLA

@sc{JOB_STACKFRAME_VANILLA} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_VANILLA
                        junk entry.
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

When an @code{after@{} clause completes normally, it changes
its @sc{protect} stackframe to a @sc{vanilla} stackframe and
then starts up the @code{@}always_do@{} clause.  When the
@code{@}always_do@{} clause completes, it pops the
@sc{vanilla} stackframe.

(If the @code{after@{} clause does not complete normally,
something tastier than a @sc{vanilla} frame is pushed, and
when done the @sc{@}always_do@{} clause will continue
whatever activity the @sc{@}always_do@{} interrupted,
getting the needed information from the tasty stackframe,
which it eats before finishing.)

A full @code{getStackframe[} @sc{vanilla} frame result looks like:

@example
:owner             object
:kind              :vanilla
:junk		   junk
@end example

@c
@node  JOB_STACKFRAME_RESTART, JOB_STACKFRAME_HANDLERS, JOB_STACKFRAME_VANILLA, Loop Stacks
@subsection JOB_STACKFRAME_RESTART

@sc{JOB_STACKFRAME_RESTART} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_RESTART
                        name (a symbol, maybe nil)
                        function (the restart proper)
			test-function (or nil)
			interactive-function (or nil)
			reportFunction (or nil)
			data (or nil)
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

A full @code{getStackframe[} @sc{restart} frame result looks like:

@example
:owner                 object
:kind                  :restart
:data                  anything
:reportFunction       compiledFunction, string or nil
:interactive-function  compiledFunction or nil
:test-function         compiledFunction or nil
:function              compiledFunction
:name                  symbol, nil means "no name"
@end example


@c
@node  JOB_STACKFRAME_HANDLERS, JOB_STACKFRAME_HANDLING, JOB_STACKFRAME_RESTART, Loop Stacks
@subsection JOB_STACKFRAME_HANDLERS

@sc{JOB_STACKFRAME_HANDLERS} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_HANDLERS
			...
                        function1
                        event1
                        function0
                        event0
                        size in bytes of above stackframe

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
			...
			local_variable_1
  job_RunState.v   ->	local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

While a @code{]with-handlers@{} clause is executing, a
@sc{handlers} stackframe holds the active handlers and
their corresponding events.

A full @code{getStackframe[} @sc{handlers} frame result looks like:

@example
:owner                 object
:kind                  :handlers
:handlers              N+1
0		       event0
1		       function0
2		       event1
3		       function1
...		       ...
2*N		       eventN
2*N+1		       functionN
@end example


@c
@node  JOB_STACKFRAME_HANDLING, JOB_STACKFRAME_FUN_BIND, JOB_STACKFRAME_HANDLERS, Loop Stacks
@subsection JOB_STACKFRAME_HANDLING

@sc{JOB_STACKFRAME_HANDLING} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_HANDLING
                        raw integer stack offset of HANDLERS frame
                        size in bytes of above stackframe

                        ...

                        size in bytes of below stackframe
                        JOB_STACKFRAME_HANDLERS
                        event0
                        function0
                        event1
                        function1
                        ...
                        size in bytes of above stackframe

                        ...

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
                        ...
                        local_variable_1
  job_RunState.v   ->   local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

While a handler is being invoked, CommonLisp specifies that all
handlers in that set must be de-activated in order to prevent
recursive errors and such.  Muq implements this by pushing
a @sc{handling} stackframe which points to the inactivated
@sc{handlers} stackframe.

A full @code{getStackframe[} @sc{handling} frame result looks like:

@example
:owner             object
:kind              :handling
:stack-depth	   fixnum
@end example

@c
@node  JOB_STACKFRAME_FUN_BIND, JOB_STACKFRAME_VAR_BIND, JOB_STACKFRAME_HANDLING, Loop Stacks
@subsection JOB_STACKFRAME_FUN_BIND

@sc{job_stackframe_fun_bind} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_FUN_BIND
                        raw int stack loc of next FUN_BIND frame, or 0
                        function
                        symbol
                        size in bytes of above stackframe

                        ...

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
                        ...
                        local_variable_1
  job_RunState.v   ->   local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

The @code{@@$s.functionBindings} value of a job points to
a linklist of function bindings in the loop stack;  The final
link is zero.

A full @code{getStackframe[} @sc{fun_bind} frame result looks like:

@example
:owner             object
:kind              :function-binding
:symbol		   symbol
:function	   function
:next		   integer offset
@end example

@c
@node  JOB_STACKFRAME_VAR_BIND, JOB_STACKFRAME_EPHEMERAL_LIST, JOB_STACKFRAME_FUN_BIND, Loop Stacks
@subsection JOB_STACKFRAME_VAR_BIND

@sc{job_stackframe_fun_bind} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_VAR_BIND
                        raw int stack loc of next VAR_BIND frame, or 0
                        value
                        symbol
                        size in bytes of above stackframe

                        ...

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
                        ...
                        local_variable_1
  job_RunState.v   ->   local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

The @code{@@$s.variableBindings} value of a job points to
a linklist of variable bindings in the loop stack;  The final
link is zero.

A full @code{getStackframe[} @sc{var_bind} frame result looks like:

@example
:owner             object
:kind              :variable-binding
:symbol		   symbol
:value		   value
:stack-depth	   integer offset
@end example

@c
@node  JOB_STACKFRAME_EPHEMERAL_LIST, JOB_STACKFRAME_EPHEMERAL_STRUCT, JOB_STACKFRAME_VAR_BIND, Loop Stacks
@subsection JOB_STACKFRAME_EPHEMERAL_LIST

@sc{job_stackframe_ephemeral_list} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_EPHEMERAL_LIST
                        raw int stack loc of next EPHEMERAL_LIST frame, or 0
                        (one or more slot-pairs -- cons cells)
                        owner of list
                        size in bytes of above stackframe

                        ...

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
                        ...
                        local_variable_1
  job_RunState.v   ->   local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

The @code{@@$s.ephemeral-lists} value of a job points to
a linklist of ephemeral lists on the loop stack;  The final
link is zero.

A full @code{getStackframe[} @sc{ephemeralList} frame result looks like:

@example
:owner             object
:kind              :ephemeralList
@end example

@c
@node  JOB_STACKFRAME_EPHEMERAL_STRUCT, JOB_STACKFRAME_EPHEMERAL_VECTOR, JOB_STACKFRAME_EPHEMERAL_LIST, Loop Stacks
@subsection JOB_STACKFRAME_EPHEMERAL_STRUCT

@sc{job_stackframe_ephemeral_struct} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_EPHEMERAL_STRUCT
                        raw int stack loc of next EPHEMERAL_STRUCT frame, or 0
                        (multiple slots holding ephemeral object)
                        size in bytes of above stackframe

                        ...

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
                        ...
                        local_variable_1
  job_RunState.v   ->   local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

The @code{@@$s.ephemeralStructs} value of a job points to
a linklist of ephemeral structs on the loop stack;  The final
link is zero.

A full @code{getStackframe[} @sc{ephemeral-struct} frame result looks like:

@example
:owner             object
:kind              :ephemeral-struct
@end example

@c
@node  JOB_STACKFRAME_EPHEMERAL_VECTOR, Loop Stacks Wrapup, JOB_STACKFRAME_EPHEMERAL_STRUCT, Loop Stacks
@subsection JOB_STACKFRAME_EPHEMERAL_VECTOR

@sc{job_stackframe_ephemeral_vector} stackframes in context will look
as follows:

@example
  job_RunState.l   ->   size in bytes of below stackframe
                        JOB_STACKFRAME_EPHEMERAL_VECTOR
                        raw int stack loc of next EPHEMERAL_VECTOR frame, or 0
                        (multiple slots holding ephemeral vector)
                        size in bytes of above stackframe

                        ...

                        size in bytes of below stackframe
                        JOB_STACKFRAME_NORMAL   
                        local_variable_N
                        ...
                        local_variable_1
  job_RunState.v   ->   local_variable_0
                        compiledFunction for this frame.
                        programCounter for this frame.
                        size in bytes of above stackframe
@end example

The @code{@@$s.ephemeralVectors} value of a job points to
a linklist of ephemeral vectors on the loop stack;  The final
link is zero.

A full @code{getStackframe[} @sc{ephemeral-vector} frame result looks like:

@example
:owner             object
:kind              :ephemeral-vector
@end example

@c
@node  Loop Stacks Wrapup, Virtual Memory, JOB_STACKFRAME_EPHEMERAL_VECTOR, Loop Stacks
@subsection Loop Stacks Wrapup


@c
@node Virtual Memory, Garbage Collection, Loop Stacks Wrapup, Muq Internals
@section Virtual Memory

The @file{vm.c} module implements a simple virtual memory manager.
Blocks of storage are named by integers, and swapped to and
from disk transparently to the rest of the program.
Pragmatically, the module is tuned to the assumption that
the set of objects being managed consists of many (tens of
thousands to millions) small (tens of bytes) objects, with a
working set which is small (a few percent) relative to the
size of virtual memory, and reasonably static.

Design decisions driven by the above pragmatics include:

@itemize @bullet
@item
Objects on disk are stored in a series of .db files, each file
containing the state for one user.  Internally, each file
consists of arrays of fixed-size slots, each array having
slots twice the size of the preceding one, together bit
allocation bitmaps and other overhead.

@item
A length-in-bytes field is stored on disk for each object,
a single byte added to blocks of 64 bytes or less, four
bytes on larger objects.  

@item
Objects are identified by 64-bit unsigneds (Vm_Objs) which
specify the file the object is in (hence its approximate length)
and its offset within that file.

The low 5 bits of Vm_Obj pointers are a typetag, used for
various purposes, both internally by us and externally by our
caller.  (More on this in a moment.)  The remaining 59 bits
encode the octave array holding the object, and the offset of the
object within that octave array, plus other overhead information.

@item
Objects which are in ram are located using a hashtable mapping
object identifiers to ram locations.  Rationale:  A hashtable
is slower than a direct-mapped array indexed by object number
(the most obvious alternative), but the direct-mapped array
would lock into ram an pointer for every object in
virtual memory, which is more ram than we wish to spend.  In
particular, if average object size dropped to 4-8 bytes, we'd
have more in-ram overhead than db on disk. (!)

@item
Objects in ram are stored in one large rambuffer, "bigbuf",
packed at the zeronear end of the buffer:  Ram is allocated
by advancing a bugbufFree zerofarward through bigbuf, much
like a stack which is pushed but never popped.  When
bigbuffree reaches the end of bigbuf, we swap some objects to
disk if needed, close up holes left by deleted objects in bigbuf
by sliding all remaining objects to the zeronear end of bigbuf,
set bigbuffree to the start of the freespace thus created,
and continue.

@item
Each object in memory is stored in bigbuf, preceded by an
two-slot bigbufBlock header containing the hashtable key (an 'o'
field which contains the object's Vm_Obj 'name') and a
'next' field pointing to the next object on the hashtable
chain.  Here's a sketch of the hashtable and one
three-object hashtable chain threaded through bigbuf,
terminated by a a pointer to nullBlock.  All hashtable
chains end with a pointer to this same nullBlock, which is
always in the second and third words of bigbuf:

@example
     hashtable             bigbuf
   ------------         -------------
   |          |         | unused    |
   |          |         |-----------|
   |          |         | 0         | <------	(nullBlock)
   |          |         | 0         |	    |
   |          |         |-----------|	    |
   |          |         |           |	    |
   |   ...    |         |    ...    |	    |
   |          |         |           |	    |
   |----------|         |-----------|       |
   |    o----------->   | o         |	    |
   |----------|         | next  o---------  |
   |          |         | user data |    |  |
   |   ...    |         |-----------|    |  |
   |          |         |           |    |  |
   |          |         |    ...    |    |  |
   |          |         |           |    |  |
   |          |         |-----------|    |  |
   |          |         | o         | <---  |
                        | next  o---------  |
                        | user data |    |  |
                        |-----------|    |  |
                        |           |    |  |
                        |    ...    |    |  |
                        |           |    |  |
                        |-----------|    |  |
                        | o         | <---  |
                        | next  o------------
                        | user data |
                        |-----------|
                        |           |
                        |    ...    |
                        |           |
@end example

This gives us a fixed overhead of sixteen bytes per in-memory
object.  (The hashtable vector itself requires four bytes
per hashtable chain, of course, which must be amortized over
the objects on the chain.  To keep performance up, we want
to keep the chains short, so this should likely be counted
as an additional 2-4 or so bytes of overhead per
ram-object.)

Recall that the bottom five bits of Vm_Obj pointers are
free for use.  This means in particular that the bottom
five bits of the 'o' field in our bigbufBlocks are free for
use.  We always set the low bit to '1', for reasons which
will become clear in a paragraph.  We use the next bit as a
@sc{dirty} flag recording which objects need to be written to
disk.  (The remaining three bits are available to users via
vm_Get_Userbits(o) and vm_Set_Userbits(o,bits)... at the moment
actually only two are made available, this needs fixing.)

Since we don't really expect to use a 4Gbyte bigbuf any time
soon, we can likewise steal a few bits from the bottom of
our bigbufBlock->next field.  We steal six bits (thus
limiting ourself to a bigbuf of no more than 64Mbytes ---
remember that bigbufBlocks are int-aligned) and use them to
hold size-in-bytes information for data blocks up through
the 33-64 byte octave.  Beyond this octave, we prepend a
64-bit length field to our bigbufBlock, containing
fieldlength << 8.  (Since this length field always has the
low bit set to 0, and our 'o' fields always have the low bit
set to 1, we can still unambiguously step through bigbuf
when compacting.)

This headerblock scheme seems nearly optimal: Clearly any
hashtable design will require a key field and a 'next' field
for each object, plus a root array to anchor and index the
chains, so we can hardly reduce our overhead much.  Mallocs
tend to have a similar amount of overhead, which also
suggests we're near the practical minimum.
@end itemize

This design is, I hope, fairly immune to pathologically bad
behavior, which immunity is more important to me than
incrementally better average- or best-case behavior.  The
design adopted also appears to have near-minimal impact on
the design and implementation of the rest of the system.

By the way: @file{vm.c} should work as a pretty decent compacting memory
manager even if you never need to page anything to disk@dots{}


@c
@node Garbage Collection, Transparent Distributed Operation, Virtual Memory, Muq Internals
@section Garbage Collection

Almost all modern programming languages of any consequence
provide some variant of the nodes-and-pointers family of
data structures, either implicitly or explicitly.

Efficiency-oriented languages such as C tend to be satisfied
with providing something like @code{malloc()/free()}, but
since the mid-60s at the latest, it has been normal for
programmer-friendly languages to provide additional help in
managing these data structures: Once such data structures
reach a moderate level of complexity, manually keeping track
of which nodes are no longer in use and can safely be
@code{free()}d becomes a formidable and error-prone task, as
witness the recurring problems with memory leaks in
netservers and netclients alike.

The solution is to provide a "garbage collector": A program
which automatically detects nodes which are no longer
accessable to the program and can therefore safely be
@code{free()}d.

The study of garbage collection algorithms is an interesting
and active subfield of computer science, full of surprising
ideas.  For example, for some sorts of programs, an
appropriate garbage collector can be faster than
conventional stack-based allocation, because conventional
stackbased allocation requires a minimum of one machine
instruction in order to free each allocated block, while an
efficient copying garbage collector can avoid touching free
blocks altogether @dots{} !

I am aware of three basic garbage collector designs:

@itemize @bullet
@item
Classic mark-and-sweep garbage collectors which
@enumerate
@item
Set a @sc{free} flag on every existing object;
@item
Recursively this flag on all reachable objects;
@item
@code{free()} all objects with the @sc{free} flag still set.
@end enumerate

@item
Copying garbage collectors, which copy all accessable
objects out of a memory block, then simply @code{free()} the
entire memory block;

@item
Reference counting, which keeps in each object a count
of the number of pointers pointing to the object.  When
this drops to zero, the object can be free()d.
@end itemize

Each design approach has significant disadvantages:

@itemize @bullet
@item
Mark-and-sweep garbage collectors tend to unexpectedly stop
the program dead for a long time while they run -- bad for
interactive applications and *extremely* bad for realtime
applications such as flight control --  and they don't compact
live objects into a single area, so the free space may be
left in tiny fragments too small to be useful, even when
'successfully' @code{free()}d.

@item
Copying garbage collectors likewise tend to stop the system
dead for awhile, and require enough spare space to construct
a complete second copy of the program's datastructures.

@item
Reference counting is done incrementally every time a pointer
is assigned, which inherently avoids big garbage collection
pauses, but this scatters the overhead and code all through
the interpreter, and they can't free() two nodes pointing to
each other, even if there is no way for the program to ever
access the node-pair.
@end itemize

After sleeping on the problem a few weeks, I think the
copying garbage collector designs are the most natural to
use in the Muq context: Muq needs to routinely make complete backups
of the database anyhow and copying garbage collection
can be piggybacked on this process at negligible performance
cost and quite moderate coding cost.

The resulting code should be very nicely localized, making
it simple and reliable.  The standard copying garbage
collector "disadvantage" of requiring space for two copies
of the database is actually an asset in this situation,
since we *want* to make backups.

We could argue that the remaining disadvantage of copying
garbage collectors --- stopping the system dead for
significant periods --- is in a sense not a disadvantage
here, since we are @emph{already} stopping the system dead
for backup anyhow.  I would prefer, however, to avoid having
backup @emph{or} garbage collection wreck interactive response,
by having both done incrementally in the background, while
the server continues to run.

For me, at least, the basic design decision required to
implement this is quite simple since (other than reference
counting, and the generation-based schemes if one wishes to
consider them incremental?!) the only incremental garbage
collection technique I'm aware of offhand is Djikstra's
three-color algorithm.  In this algorithm, at any given
time, every object is either Black, Grey or White.

Black designates objects which may or may not be reachable,
until we finish enumerating all reachable objects, at which
point it designates garbage objects.

White designates objects which are known to be reachable,
and which don't point to any Black objects.

All other objects are Grey.

Conceptually, the algorithm is very simple.  All objects
start out Black.  We radiate a Grey wave out from the 'root'
pointers defining objects immediately accessable to the
program, following all pointers in the objects, by
successively arbitrarily picking any Grey object O, coloring
Grey all Black objects reachable from O, and then coloring O
White.  We stop when no more Grey objects remain, at which
point all Black objects can be free()d.  In effect, the Grey
objects constitute a queue of work remaining to be done by
the garbage collector on this pass.

The nice thing about this algorithm --- Djikstra's main
design goal for it, I believe --- is that it adapts very
nicely to being executed incrementally while the interpreter
continues to run: All we need do is keep the interpreter
operating only on White objects (Footnote 1).  This may be
achieved simply by stopping the interpreter whenever it
reaches a Grey object O (it can't reach a Black object),
processing O as our next incremental garbage collection step
(since the algorithm doesn't care what order Grey objects
are processed in, this is simple) and then continuing, O now
being a standard White object.

Adapting this idea to vm.c, our idea is to have the mud keep
running while in the background we copy our complete
database from the existing 'old' fileset to a duplicate
'new' fileset.  We start this process by flushing all dirty
objects to disk, giving us a self-consistent 'old' db on
disk; This is the last time we shall ever write to the old
db.  Thereafter, all dirty objects will be written to the
'new' fileset, and in addition we will incrementally copy
all reachable objects from 'old' to 'new' fileset.  When
this copying process is complete, vm closes all files in the
'old' db and forgets all about it thereafter.

In a 'bit' more detail, while the incremental copying/garbage
collection phase is under way, we have two complete filesets
open, each with its own allocation bitmap per file.  When
objects are copied, their Vm_Obj pointer isn't changed:
An object that was octave 5 offset 1366 in the 'old' fileset
will be copied to  octave 5 offset 1366 in the 'new' fileset.

Thus, during copying we have available two bits per object
instead of one, one bit in the bitmap for the object in each
fileset.  (Note that we do not need to keep intact the
memory bitmap for the 'old' fileset --- this bitmap was
written to disk when we did the initial flush of all dirty
objects to create a self-consistent image in 'old'.)

By a splendid coincidence, these two bits give us exactly
enough states to label each object as Black, Grey, White or
Free.  Immediately after flushing dirty objects to 'old' and
creating a 'new' fileset with (it being initially empty)
all-zero bitmaps, all objects will be either Black or Free,
indicated by a 0 in the 'new' bitmap and either '0' or '1'
in the 'old' bitmap.

At this point, we color Grey all objects immediately
accessable by the interpreter, by setting '1' on them in the
'new' bitmap.  We then run the garbage collector until there
are no Grey objects left in ram.  (Assuming a moderate size
ram buffer, this should run quickly enough to not create an
objectionable pause, no disk I/O being involved.)

The point of this is that the interpreter cannot now access
any Grey (or, of course, Black) object without reading from
disk, which means in turn that we don't need to insert any
extra garbage collection code in the fast
handle-an-object-in-ram code, only in the
read-an-object-from-disk code, which is so slow as to make
any slowdown from our additional code completely negligible.

Note that there may well be Black objects in ram, especially
initially.  This poses no problem.  These are simply objects
which the interpreter either cannot reach at all, or can
reach only via pointers which are currently on disk.

We implement White with a '0' in the 'old' bitmap and a '1'
in the new, indicating that the object is now stored in the
'new' fileset when written.

Having performed the initial flush to disk followed by
Whiting (Footnote 2) of all Grey objects in ram, we simply
let the interpreter proceed on its merry way.  Periodically
--- when the interpreter is idle, every Nth instruction or
object create, or whatever --- we White a few more Grey
nodes, a small enough number so as not to pause the
interpreter objectionably, and of course we White every Grey
object which the interpreter tries to read from disk.

Since Grey objects by (our) definition live in the 'old'
fileset, and since White objects (when not in ram) are saved
in the 'new' fileset, this process of coloring will also
automatically copy objects steadily from the 'old' fileset
to the 'new' fileset.

When we run out of Grey objects, the interpreter is running
completely out of the 'new' fileset, the 'old' fileset is a
stable self-consistent backup which may be safely backed up
by the system backup utility etc (unlike the active fileset,
which at any given instant is unlikely to be self-consistent
on disk, much less self-consistent on disk over the time
taken to back up its component files), all objects which
were garbage at the start of the garbage collect are Free in
the 'new' fileset, and the system should have exhibited no
objectionable pauses.

---------------------------------------------------------

Footnote 1:

Note that if we do @emph{not} keep the interpreter operating
only on White objects, we may easily wind up
@code{free()}ing an object we should not: the interpreter
can copy a pointer to a Black object B from a Grey object G
to a White object W and then erase the original pointer in
G, which can keep the garbage collector from ever coloring B
White or Grey, even though B remains accessable to the
program via the pointer in W.  The garbage collector will
thus wind up free()ing a node (B) in use by the program, a
very definite no-no.

Footnote 2:

If it is not obvious, I define 'to White' as the process of
coloring Grey all Black objects pointed to by a given Grey
object O, followed by coloring O White.

@sc{note}:  The above is not yet implemented.  Muq currently
uses a simple interim mark-and-sweep garbage collector.
Furthermore, my ideas have evolved somewhat over the last
two years.  See comments at top of @file{vm.c} if interested.

@c
@node Transparent Distributed Operation, Flatfile Save/Restore, Garbage Collection, Muq Internals
@section Transparent Distributed Operation

This section contains preliminary design notes on a facility
not yet implemented.

One of my prime ambitions for Muq is eventual close-coupled
operation of Muq servers and clients over wide area
networks, with near-complete network transparency to code
running on the server and client: Ideally, you should have
to use a special "remote?" predicate to tell if a given
object is local or remote.

That objective remains particularly ambitious because we
must in practice assume that any Muq clients involved have
been maliciously modified to corrupt or cripple the system
in any possible way.

In this section we make a start by considering the easier
problem of transparent operation spread over multiple
servers, where we assume that the servers are relatively
small in number (say, 3-12 rather than hundreds or
thousands), stable, and trusted: We won't attempt to defend
against maliciously modified servers, and we will assume
other servers are as entitled to private data &tc as our
own.

As a general model, I assume that each server maintains an
open reliable-stream socket connection directly to each
other server, and that the elementary unit of interaction
via these connections is a packet of the general form

  LENGTH-IN-BYTES (4 bytes)
  OPCODE (4 bytes)
  data

where I'll assume the packets are short enough to be
reasonably read and written indivisibly -- maximum size
something like 4K to 64K -- and that the server won't have
to worry about checksumming, partial packets and such.

I envision each server checking for and processing I/O
from other servers about as often as it does so with the
client connections.

The first problem to solve is the representation of a
reference on one server to an object on another server.

The most elegant solution would be something like
adding a 'server' bitfield to our Vm_Obj format,
so that any pointer could indifferently point to
any value on any machine.

Alas, with a 32-bit Vm_Obj value, we are already hard up
against the wall for bits, and adding even another 2-bit
field seems quite out of the question, whereas hardwiring
even a 6-bit field seems a quite dubious proposition...  one
would hate to hit a hard design wall when a server network
reached 64 servers, and the option of letting client
programs all over Internet dynamically join the
transparent-networking pool would be completely forclosed if
we took this approach.

The only other category of design solution which comes to
mind is that of @dfn{proxy objects}: We can create objects in
the db which, like symbolic links in the unix file system,
contain the address of the real value rather than the value
itself.  Since Muq is a value-typed virtual machine, it can
relatively easily intercept all operations on such proxies
and handle them specially via the interserver sockets.

I would envision these proxy objects as containing:

@itemize @bullet
@item
A designation of the remote server, perhaps as a
:sl.tcp.com/9876 style keyword giving the domain name and
port for the remote server (numbering servers and
indirecting through a table might simplify handling server
relocations, but might be unwieldy in the extention to
clients)

@item
The remote server's Vm_Obj designation for the object.

@item
A 32-bit object ID allowing detection of stale references --
hanging pointers. I envision the
object ID as being an integer maintained in each server,
incremented each time vm_Malloc() is called, and stored in
each addressable object.  This adds 32 bits of overhead to
every addressable object to support networking, which I
believe is reasonable.

@item
Possibly some invariant information about the object, such
as the class of object, merely to reduce traffic to the
server owning the object.
@end itemize

I'm assuming garbage collection is done locally on each
server, ignoring possible remote pointers in other servers.
Doing otherwise seems likely to introduce unacceptable
performance hits.  This does of course diminish network
transparency, since a new class of "object vanished!" errors
becomes possible for remote objects.  I expect this to prove
a practical compromise, possibly with a little help from
Muq programmers learning to avoid references to transitory
foriegn objects and/or server tweaks to remember pointers
which have been recently exported.



With the proxy concept established, we can specify the
lowlevel interserver packet transmission/translation process
in a little more detail.

We will regard the lowlevel interserver packet transmission/
translation problem as solved if we have a satisfactory way
of communicating any addressable db component, where in
general readOnly values (ints, chars, readOnly strings...)
are sent by value, and others by constructing proxy
references.

We note that the Muq server has sufficient information to
classify any given Vm_Obj value as one of the following:

@itemize @bullet
@item
An immediate value: char, int, short-float...
@item
A pointer to a sequence of 1-byte binary values
@item
A pointer to a sequence of 2-byte binary values
@item
A pointer to a sequence of 4-byte binary values
@item
A pointer to a sequence of 8-byte binary values
@item
A pointer to a sequence of (4-byte) Vm_Obj values
@end itemize

(We oversimplify only slightly;  All but the
first actually have an associated Vm_Obj value
giving the owner, and in this proposal will
also have a 32-bit object ID.  These pose
no new problems, so we ignore them here.)

The first case may be handled by simply
byteswapping to network order and transmitting.

When readOnly, the binary cases may be handled by
byteswapping the internal fields to network order and
transmitting, creating a new object with the matching
contents at the far end.  When not readOnly, a
proxy pointer should be constructed at the far end.

The final case will normally not be readOnly, so it will
need to be handled by constructing a proxy pointer at the
far end.  Read-only values of this sort could in principle
be handled by constructing a corresponding value at the far
end, and handling the contents recursively.

A problem can occur in the readOnly cases in that values
can be duplicated: A single readOnly string on one host
might wind up being instantiated several times on a remote
host, once for each reference to it.  This might break some
code using lispStyle 'eq' compares.  The most conservative
solution is to always use proxies except for immediate
values; This avoids the problem completely, but may result
in an unacceptable amount of network traffic.  It might be
the best first-cut implementation, however.



Given such a picture, we need to convince ourselves that all
prims implemented in the server can be extended to work
correctly when handed proxy arguments.

We tackle the prims by classes:

Prims which internally gaily traverse obj/prop chains on the
assumption that this is reasonably fast may need to be
recoded: Any time we hit a reference to a remote object, we
may need to stop for a good long while waiting for a
response, and we cannot freeze the entire Muq server that
long.  Restarting a complex instruction midway means either
rerunning it from the beginning, or icky hacks to save and
restore the half-completed state.  Any prims requiring the
latter probably should be just recoded in-db.

Prims which get/set/etc properties on an object can be
delegated to the server holding that object. The key
comparison logic obj_Neql() needs to be extended to handle
proxy objects, but that is fairly straightforward for values
compared by pointer.  Strings are currently the only types
compared by value; It might help to pass them by value and
let the 'eq' people suffer.

Prims which only admit of one potential proxy value can
always delegate the operation to the home server.  The
trickiest operation in this class is probably a function
call on a remote function;  a stub 'job' will need to
be created on the far end, and 'throw()' will need to
be able to handle a job in which the bottom of the
loop stack is remote in this fashion.  A fair amount
of busywork, but not obviously a major problem

Type-indifferent prims which merely shuffle pointers without
carrying about their meaning, such as those that rotate
stack blocks and copy values into and out of variables,
clearly don't need any recoding to work with proxies.

Conceptually, the most difficult cases are prims which
seriously need to deal with the contents of two objects; If
one is remote, and one local, at least a temporary copy of
the remote contents may be needed.  I do not believe there
are any prims which modify the contents of two objects at
once, so it should be possible to always delegate these
prims to the home server of the object being modified, and
treat this as a problem of making a temporary copy of the
remaining object(s) for readOnly purposes.

The central, canonical implementation difficulty seems to
be: We're in the middle of prim X, we do vm_Loc() (directly
or indirectly via something like VEC_P()), and the value in
question is a proxy.  What should we do?  We need to
@enumerate
@item
Issue some request to the home server of the object;
@item
Block the job
@item
Arrange somehow for processing to pick up where it left off.
@end enumerate
If prims always argchecked all the objects they intended to
vm_Loc() in the prologue before beginning work, we could
perhaps block at that point, replace the proxy reference by
a local copy, and continue.  This would require being sure
that the pointer to the local copy wasn't going to get
stored into the db, and that the local copy wasn't going to
be modified.  Would it be realistic to require all prims to
obey this protocol?

If speed is the main objection to the above, it might be
possible to code speed-critical fns in C, but have a
muf-coded version available, and have the C version
retreat to calling the MUF one if proxies are encountered.

The icky alternative is to have prims which can block on
access to a remote object be explicitly coded at each such
spot to save their state in the db, and then have provisions
for restoring it.  Prims coded using recursive C calls and
saving lots of state on the C stack would obviously be poor
candidates for this treatment.

It sounds as though a careful survey and perhaps rewrite of
the prim instruction set is called for before proceeding
further with the design.

@c
@node Flatfile Save/Restore, Muq Internals Wrapup, Transparent Distributed Operation, Muq Internals
@section Flatfile Save/Restore

In a production setting, it is occasionally very
useful to be able to convert the binary database
into a simple textfile.  This can be useful for
debugging, for transporting a db between machines
with incompatible architectures (different byte-sex
or floating-point representations, say), or for
converting a database to a new revision of the
server, should an incompatible change of database
format prove necessary.

Such a facility has been implemented and tested,
based on the @code{xxx_import()} and @code{xxx_export()}
functions in each module xxx, but has not been actively
maintained during recent changes and is likely
thoroughly crippled by bitrot.

The general scheme used is to represent immediate
values such as integers and floats by lines like

@example
i:1534
f:45.5
@end example

@noindent
while representing, for example, a three-slot
vector containing the above two numbers plus
a pointer to itself, as

@example
V:15a9f:3
i:1535
f:45.5
r:15a9f
@end example

The general format, then, is to delimit records
by newlines and fields within a record by colons,
and to represent a value by a record containing
a type field, followed by any immediate value,
followed in the case of composite objects by
records representing the contained values.

Addressable objects are assigned unique hex
identifiers, which are stored in the second field in
their record, and are referred to using records
consiting of the @strong{r} type field followed by a
field containing the desired hex identifier.

As a general convention, hardwired classes have
three-character type fields matching their source
filename, and other hardwired types have one- or
two-character type fields.  As a further convention,
the latter are lower-case for immediate values and
upper-case for composite values.

The defined type fields are:

@table @strong
@item asm
Assembler class.
@item a
Top-of-stack-block delimiters.
@item u
Bottom-of-stack value.  (Not normally user-visible.)
@item cdf
Class definitions.
@item cdt
Events.
@item cfg
Configuration objects.  (/config.)
@item PT
Compiled-functions.
@item c
Characters.
@item f
Floats.
@item fun
Functions.
@item i
Integers.
@item jbs
Job-sets.
@item job
Jobs.
@item joq
Job-queues.
@item lok
Locks.  (Binary semaphores.)
@item L
Cons cells.  (Lists.)
@item mrk
Markers in text buffers.  (Unimplemented.)
@item mss
Message streams.
@item mss
Message streams.
@item muq
Muq server interface objects.  (/muq.)
@item obj
Muq index objects.  (As created by @code{makeIndex}.)
@item pkg
Package objects.  (As created by @code{makePackage}.)
@item prx
Proxy objects.  (Unimplemented.)
@item sdf
Structure definition objects.
@item skt
Socket objects.
@item s
Special values.  (OBJ_NOT_FOUND and such.  Not normally user-visible.)
@item ssn
Session objects.
@item C
Structure instances.
@item EC
Ephemeral structure instances.
@item EN
Ephemeral cons cell instances.
@item t
Strings.  ("Text".)
@item stk
Vanilla stacks.
@item lst
Loop stacks.  (Specialized to hold call/return &tc info for jobs.)
@item dst
Data stacks.  (Specialized to hold expression values for jobs.)
@item stm
Vanilla streams.
@item S
Symbols.
@item sys
System.  (Interface to host OS.)
@item tbf
Text buffers.  (Modelled on those of emacs.  Unimplemented.)
@item usq
User queues.  (Used internally by inserver job-scheduler.)
@item rot
Users with root privileges.
@item usr
Vanilla users.
@item V
Vectors.
@item EV
Ephemeral vectors.
@item EO
Ephemeral objects.  (Unimplemented.)
@item wrm
Wormholes.  (Unimplemented, likely to be removed.)
@item x??
Various X Window System classes. (Unimplemented, likely to be removed.)
@end table


@c
@node Muq Internals Wrapup, Muf Compiler, Flatfile Save/Restore, Muq Internals
@section Muq Internals Wrapup

This concludes the Muq Internals chapter.  Let me know if
there are other things you would like to see here
--cynbe@@sl.tcp.com

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
