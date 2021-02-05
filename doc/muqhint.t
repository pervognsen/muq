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

@node Hacker Hints, Hacker Hints Overview, Top, Top
@chapter Hacker Hints

@menu
* Hacker Hints Overview::
* Keeping C files around::
* Getting Execution Traces::
* Hacker Hints Wrapup::
@end menu

@c
@node Hacker Hints Overview, Keeping C files around, Hacker Hints, Hacker Hints
@section Hacker Hints Overview

This chapter contains the answers to various questions
I've been asked in email.  The techniques described are
@emph{not} guaranteed to work in future releases of Muq.
Many of them are frank kludges.  But they usually
accomplish something useful which cannot yet be done
more conveniently.

@c
@node Keeping C files around, Getting Execution Traces, Hacker Hints Overview, Hacker Hints
@section Keeping C files around

The c/Makefile* complex normally creates @code{.c} files
on the fly as needed from the corresponding @code{.t} files:

This avoids needless clutter, but it can also frustrate
source-level debuggers configured to (for example) display
the contents of @code{.c} files during debugging.

To defeat automatic deletion of @code{.c} files, do

@example
setenv MUQ_KEEP_C_FILES true
@end example

either by hand or in your @file{.login} file.

@c
@node Getting Execution Traces, Hacker Hints Wrapup, Keeping C files around, Hacker Hints
@section Getting Execution Traces

When all else fails, you may wish to generate a
bytecode by bytecode log of every virtual instruction
the Muq bytecode engine executes.  (Save a forest:
don't run the output to hard copy!)

To do this, look in @file{c/jobbuild.c} for

@example
#if JOB_PASS_IN_PARAMETERS
    fputs("#define JOB_NEXT                             \\\n", fd );
    /* Uncomment next for a debug trace (see also job_run()): */
    /* fputs("job_Print1(stdout,jSpc,jSs);\\\n", fd );*/
    fputs("@{++jSops;                                    \\\n", fd );
    fputs(" ((Job_Fast_Prim*)jStabl)[                   \\\n", fd );
    fputs("  *jSpc                          |           \\\n", fd );
    fputs("  (job_Type1[jSs[-1]&0xFF])      |           \\\n", fd );
    fputs("   job_Type0[jSs[ 0]&0xFF]       |           \\\n", fd );
    fputs("  (jSops & JOB_OPS_COUNT_MASK)               \\\n", fd );
    fputs(" ](JOB_PRIM_ARGS);@}\n",                             fd );
#else
    fputs("#define JOB_NEXT                             \\\n", fd );
    /* Uncomment next for a debug trace (see also job_run()): */
    /* fputs("job_Print1(stdout,jSpc,jSs);\\\n", fd ); */
    fputs(" ((Job_Fast_Prim*)jStabl)[                   \\\n", fd );
    fputs("  *jSpc                          |           \\\n", fd );
    fputs("  (job_Type1[jSs[-1]&0xFF])      |           \\\n", fd );
    fputs("   job_Type0[jSs[ 0]&0xFF]       |           \\\n", fd );
    fputs("  (++jSops & JOB_OPS_COUNT_MASK)             \\\n", fd );
    fputs(" ](JOB_PRIM_ARGS)\n",                               fd );
#endif
@end example

@noindent
and uncomment both of the indicated lines.  Then go into @file{job.t}
and find in function @code{job_run()} the section reading

@example
        /* Uncomment next line for a handy trace when debugging: */
        /* job_Print1(stdout,jS.pc,jS.s); */
        /* See also JOB_NEXT in jobbuild.c */
@end example

@noindent
and uncomment.  Recompile @dots{} and stand back.

@c
@node Hacker Hints Wrapup, Muq Internals, Getting Execution Traces, Hacker Hints
@section hacker Hints Wrapup

This concludes the Hacker Hints chapter.  Let me know if
your favorite kludge is missing!
--cynbe@@sl.tcp.com

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
