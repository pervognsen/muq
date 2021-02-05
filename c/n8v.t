@example  @c
/*- This file is formatted for outline-minor-mode in emacs19.		*/
/*-^C^O^A shows All of file.						*/
/* ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	*/
/* ^C^O^T hides all Text. (Leaves all headings.)			*/
/* ^C^O^I shows Immediate children of node.				*/
/* ^C^O^S Shows all of a node.						*/
/* ^C^O^D hiDes all of a node.						*/
/* ^HFoutline-mode gives more details.					*/
/* (Or do ^HI and read emacs:outline mode.)				*/

93Aug14: Thoughts on supporting application functions:

Specializing the interpreter to a particular server appears to be
possible purely by adding appropriate C-coded functions.

It is desirable that such functions work in a network environment,
and support dynamic loading of the relevant C code on demand.

A workable scheme seems to me to be the creation of a special
class of function 'n8v', (native)
which contains the following:

    Name of function.
    Doc String (like regular fn).
    Name of C module exporting function.
    Index of function in interpreter n8v table.
    Date at which index slot was last updated.

Calling a n8v then involves:

 If n8v index date precedes start of interpreter run, null index.
 If index is null, load C module, assign fn index in n8vtab, note index in n8v.
 Jump to indicated C fn.

In a network environment, an attempt to execute a foriegn n8v will
need to result in either an error, or a process migration to the
appropriate server.  (?-- or should we presume a match on module
and function name is sufficient to allow execution to proceed?)


Primary and secondary opcodes should really be represented within the
system in similar objects ('opc'?), giving the primitive name,
docString, opcode byte(s) etc.  This would allow functions like
apropos to document prims and mufcoded stuff interchangably.  These
objects should likely all be stored in /lib.  Making these objects
actually executable would satisfy the occasional need to quote a prim
... and keep the distinction between prim and fn more
user-transparent.

@end example
