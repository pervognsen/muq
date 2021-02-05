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

@node Advanced Muf Programming, Advanced Muf Programming Overview, Intermediate Muf Programming Wrapup, Top
@chapter Advanced Muf Programming

@menu
* Advanced Muf Programming Overview::
* Big-O Notation::
* Doubly Linked Lists::
* Splay Trees::
* B-Trees::
* Relational Algebra::
* General Graphs::
* Writing Muq Compilers::
* Writing Mud Worlds::
* Writing Mud Shells::
* A Citadel::
* Phrase-Structure Grammars::
* Weizenbaums Eliza::
* Symbolic Algebra::
* Portability Issues::
* Advanced Muf Programming Wrapup::
@end menu

@c {{{ Advanced Muf Programming Overview

@c
@node Advanced Muf Programming Overview, Big-O Notation, Advanced Muf Programming, Advanced Muf Programming
@section Advanced Muf Programming Overview

This chapter is yet to be written.  Topic suggestions? :)

Manyfolk's first real programming experiences come from
working with a programmable server such as Muq.

This chapter is intended to provide a bridge from the
"book-learning" knowledge of Muq @sc{muf} provided by the
previous chapter to real hands-on @sc{muf} proficiency, by
presenting a series of logically complete toy programs which
illustrate important programming algorithms, tasks, and
techniques.

In essence, this chapter is an attempt to condense a
programming BA degree into a one-week minicourse, which
isn't really possible.  But working through these examples
and using one or more of them as a springboard for projects
of your own should give you a good start toward acquiring
solid programming skills.

@c {{{endfold}}}
@c {{{ Big-O Notation

@c
@node Big-O Notation, Big-O Notation Overview, Advanced Muf Programming Overview, Advanced Muf Programming
@section Big-O Notation

@menu
* Big-O Notation Overview::
* Big-O Notation Explained::
* Big-O Notation Wrapup::
@end menu

@c {{{ Big-O Notation Overview

@c
@node  Big-O Notation Overview, Big-O Notation Explained, Big-O Notation, Big-O Notation
@subsection Big-O Notation Overview

@c {{{endfold}}}
@c {{{ Big-O Notation Explained

@c
@node  Big-O Notation Explained, Big-O Notation Wrapup, Big-O Notation Overview, Big-O Notation
@subsection Big-O Notation Explained

@c {{{endfold}}}
@c {{{ Big-O Notation Wrapup

@c
@node  Big-O Notation Wrapup, Doubly Linked Lists, Big-O Notation Explained, Big-O Notation
@subsection Big-O Notation Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Doubly Linked Lists

@c
@node Doubly Linked Lists, Doubly Linked List Overview, Big-O Notation Wrapup, Advanced Muf Programming
@section Doubly Linked Lists

@menu
* Doubly Linked List Overview::
* Doubly Linked List Wrapup::
@end menu

@c {{{ Doubly Linked List Overview

@c
@node  Doubly Linked List Overview, Doubly Linked List Wrapup, Doubly Linked Lists, Doubly Linked Lists
@subsection Doubly Linked List Overview

Doubly linked lists are the peanut butter sandwich of
datastructures: They're not the fanciest or most elegant
solution, often, but they're quick to build and will usually
do in a pinch, so they get used a lot.

Their biggest disadvantage is that finding an arbitrary given
value in a doubly-linked list is normally an O(n) operation,
since it requires searching all the entries in the list one
by one.  (If you rarely need to do this operation, or if
your lists are so short that the search time is not an
issue, doubly linked lists may be just what the doctor
ordered.)

Other disadvantages are that storing a given set of values
in a doubly linked list takes several times more memory than
just packing them in a vector would, and just @emph{finding}
the nth element of a doubly linked list is an O(n) operation
-- whereas it is an O(1) operation in a vector, and an
O(n*log(n)) operation in most tree datastructures.

The greatest advantage (other than sheer simplicity) of the
doubly linked list is that deleting an element, once you've
found it, is an O(1) operation... whereas the same operation
on a packed vector is an O(n) operation.  (The story is the
same for insertion of elements.)  Hence, doubly linked lists
are particularly appropriate when you expect to be inserting
and deleting elements frequently, particularly in the middle
of the list.

@c {{{endfold}}}
@c {{{ Doubly Linked List Wrapup

@c
@node  Doubly Linked List Wrapup, Splay Trees, Doubly Linked List Overview, Doubly Linked Lists
@subsection Doubly Linked List Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Splay Trees

@c
@node Splay Trees, Splay Tree Overview, Doubly Linked List Wrapup, Advanced Muf Programming
@section Splay Trees

@menu
* Splay Tree Overview::
* Splay Tree Wrapup::
@end menu

@c {{{ Splay Tree Overview

@c
@node  Splay Tree Overview, Splay Tree Wrapup, Splay Trees, Splay Trees
@subsection Splay Tree Overview

@c {{{endfold}}}
@c {{{ Splay Tree Wrapup

@c
@node  Splay Tree Wrapup, B-Trees, Splay Tree Overview, Splay Trees
@subsection Splay Tree Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ B-Trees

@c
@node B-Trees, B-Tree Overview, Splay Tree Wrapup, Advanced Muf Programming
@section B-Trees

@menu
* B-Tree Overview::
* B-Tree Wrapup::
@end menu

@c {{{ B-Tree Overview

@c
@node  B-Tree Overview, B-Tree Wrapup, B-Trees, B-Trees
@subsection B-Tree Overview

B-Trees are the bread and butter of the database world:
Virtually every database is implemented internally as some
variant of B-Trees.

@c {{{endfold}}}
@c {{{ B-Tree Wrapup

@c
@node  B-Tree Wrapup, Relational Algebra, B-Tree Overview, B-Trees
@subsection B-Tree Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Relational Algebra

@c
@node Relational Algebra, Relational Algebra Overview, B-Tree Wrapup, Advanced Muf Programming
@section Relational Algebra

@menu
* Relational Algebra Overview::
* Relational Algebra Wrapup::
@end menu

@c {{{ Relational Algebra Overview

@c
@node  Relational Algebra Overview, Relational Algebra Wrapup, Relational Algebra, Relational Algebra
@subsection Relational Algebra Overview

@c {{{endfold}}}
@c {{{ Relational Algebra Wrapup

@c
@node  Relational Algebra Wrapup, General Graphs, Relational Algebra Overview, Relational Algebra
@subsection Relational Algebra Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ General Graphs

@c
@node General Graphs, General Graphs Overview, Relational Algebra Wrapup, Advanced Muf Programming
@section General Graphs

@menu
* General Graphs Overview::
* General Graphs Wrapup::
@end menu

@c {{{ General Graphs Overview

@c
@node  General Graphs Overview, General Graphs Wrapup, General Graphs, General Graphs
@subsection General Graphs Overview

@c {{{endfold}}}
@c {{{ General Graphs Wrapup

@c
@node  General Graphs Wrapup, Writing Muq Compilers, General Graphs Overview, General Graphs
@subsection General Graphs Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Writing Muq Compilers

@c
@node Writing Muq Compilers, Compiler Overview, General Graphs Wrapup, Advanced Muf Programming
@section Writing Muq Compilers

The Muq design makes writing simple compilers relatively
easy.  In this section we develop a toy compiler step by
step.  If you follow the development carefully, you should
have no trouble developing compilers of your own.

@menu
* Compiler Overview::
* A Lexer::
* A Parser::
* An Optimizer::
* A Code Generator::
* Compiler Wrapup::
@end menu

@c {{{ Compiler Overview

@c
@node  Compiler Overview, A Lexer, Writing Muq Compilers, Writing Muq Compilers
@subsection Compiler Overview

Reference Aho, Sethi & Uhlman here.

@c {{{endfold}}}
@c {{{ A Lexer

@c
@node  A Lexer, A Parser, Compiler Overview, Writing Muq Compilers
@subsection A Lexer

@c {{{endfold}}}
@c {{{ A Parser

@c
@node  A Parser, An Optimizer, A Lexer, Writing Muq Compilers
@subsection A Parser

@c {{{endfold}}}
@c {{{ An Optimizer

@c
@node  An Optimizer, A Code Generator, A Parser, Writing Muq Compilers
@subsection An Optimizer

Abstractly considered, a program is a partly-specified
computation: If it were completely specified, the compiler
could compute the result immediately and return it, but
typically a program uses some values which won't be known
until the program is run -- values entered by the user, say.

Still, it is often the case that parts of the computation
specified by the source text are @dfn{constant expressions}
and can indeed be performed once while the is being
compiled, instead of being performed every time the program
is run.

Most compilers contain an @dfn{optimizer} subprogram
intended to find certain kinds of constant expressions and
replace them by their result.

Compiler optimization is a large, active and fascinating
subfield of computer science in its own right, which each
year produces more subtle data structures for representing
code, and algorithms for transforming them: In essence, we
are engaged in teaching the compiler to understand steadily
more of the programs it compiles.

Good journals covering the subject include the ACM
(Association for Computing Machinery)'s SIGPLAN (Special
Interest Group for Programing LANguages) annual proceedings,
and the ACM's journal TOPLAS (Transactions On Programing
Languages And Systems.)

@c {{{endfold}}}
@c {{{ A Code Generator

@c
@node  A Code Generator, Code Generation Overview, An Optimizer, Writing Muq Compilers
@subsection A Code Generator

@menu
* Code Generation Overview::
* The Muq Assembler::
* Specifying Function Arity::
* Assembling The Trivial Function::
* Assembling Constants And Calls::
* Assembling Conditionals And Loops::
* Assembling Local Variables::
* Assembling Debug Information::
* Assembling Obscure Special Cases::
* Code Generation Wrapup::
@end menu

@c {{{ Code Generation Overview

@c
@node  Code Generation Overview, The Muq Assembler, A Code Generator, A Code Generator
@subsubsection Code Generation Overview

@c {{{endfold}}}
@c {{{ The Muq Assembler

@c
@node  The Muq Assembler, Assembling The Trivial Function, Code Generation Overview, A Code Generator
@subsubsection The Muq Assembler

Muq has a special class of objects called "assemblers" which
are responsible for most of the busywork involved in
actually producing a @code{compiledFunction}.  They ensure
that only valid @code{compiledFunction}s are produced --
that is, ones that at minimum will not crash the bytecode
interpreter -- and take care of a great deal of low level
work such as selecting appropriate bytecode encodings,
choosing between one and two byte jump offsets, and similar
arcana of the bytecode instruction set.

Thanks to the assembler, most Muq compiler writers need not
even know which instructions are bytecoded on Muq and which
are implemented in-db, for the most part, much less the
details of (say) conditional branch encoding.

The next few sections concentrate on the mechanics of
generating valid Muq @code{compiledFunction} objects via
assemblers, postponing consideration of how the compiler
gets hooked up to it all: We simply demonstrate simple
programs which generate simple @code{compiledFunction}s.

@c {{{endfold}}}
@c {{{ Assembling The Trivial Function

@c
@node  Assembling The Trivial Function, Specifying Function Arity, The Muq Assembler, A Code Generator
@subsubsection Assembling The Trivial Function

The first task, as always, is simply to learn the
bare mechanics of producing a @code{compiledFunction}
by means of an assembler.

@example
stack:
makeAssembler --> *asm*
stack:
makeFunction  --> *fun*
stack:
"my-function"  --> *fun*$s.name
stack:
*asm* reset
stack:
0 *fun* *asm* finishAssembly --> *cfn*
stack:
*cfn*
stack: #<c-fn my-function>
@end example

That's it!  Our first compiled function.
If we disassembled it, we would see:

@example
constants:
code bytes:
00: 2e
code disassembly:
000:      2e          RETURN 
@end example

@noindent
which is the simplest function possible in Muq:
No constants and code limited to a single one-byte
RETURN bytecode.

Let's go over the example in detail.

@example
makeAssembler --> *asm*
@end example

The above creates our own assembler.  It records internally
everything we tell it about what we want in the final
@code{compiledFunction}, and then when we're done
describing it, actually builds the @code{compiledFunction}.

@example
makeFunction  --> *fun*
@end example

The above creates our @code{function}.  Do not confuse
@code{function} objects with @code{compiledFunction}
objects!

@itemize @bullet
@item
A @code{function} contains book-keeping information of
interest to humans, such as the source code in text
form, the compiler used to compile the source, the
date created, and the names of any local variables
used by the function.  A @code{function} has a full
compliment of propdirs, and hence may be decorated
with any extra information you like.  A @code{function}
will normally spend most of its life on disk, being
fetched into memory only if some human wishes to
inspect the source code or such.
@item
A @code{compiledFunction} is very specialized, bare-bones
object containing all and only the information needed by the
bytecode interpreter to execute function, namely the
bytecodes for the instructions, and any constants needed by
those bytecodes.  (Well... and an 'owner' field for
accounting purposes, and a pointer to the corresponding
@code{function} object.)  No creation date, no propdirs, no
name.  99% lean muscle.  You will almost never have cause
to do anything with a @code{compile-function} except to
call it or to fetch the pointer to the corresponding
@code{function}, where all the human-readable stuff is.
@end itemize

(Note that there may be more than one
@code{compiledFunction} pointing to a given
@code{function}. This is most common when implementing
lispStyle lambda closures, scheme-style promises, or
functional programming stuff.  For generic Algolic sorts of
code, however, there will normally be just one
@code{compiledFunction} for each @code{function}.)

@example
"my-function"  --> *fun*$s.name
@end example

We name the function ``my-function''.  This is optional; The
default name is ``_''.

@example
*asm* reset
@end example

A single assembler may be used to assemble many functions;
In a production compiler, it is much more efficient to
re-use assemblers than to create and discard a new one
for each function assembled.

We use @code{reset} to prepare our assembler to compile a
new function.

In this particular example, the assembler was freshly
created and hence already reset, so we could actually have
skipped this step, but we include it for didactic
completeness.

@example
nil 0 *fun* *asm* finishAssembly --> *cfn*
@end example

The @code{finishAssembly} command triggers construction
by the assembler of the desired @code{compiledFunction}.

The @code{*fun*} argument is used by the assembler to
initialize the @code{cfn$s.source} slot in the resulting
@code{compiledFunction} to the desired @code{function}
object: For security and reliability reasons, Muq doesn't
let anything much but an assembler tinker with the contents
of a @code{compiledFunction}, so you can't do this
yourself.

What were the @sc{nil} and @code{0} parameters for?  We cover this
in the next section.

@c {{{endfold}}}
@c {{{ Specifying Function Arity

@c
@node  Specifying Function Arity, Assembling Constants And Calls, Assembling The Trivial Function, A Code Generator
@subsubsection Specifying Function Arity

The Muq assembler computes the number of arguments accepted
and returned by the function being assembled -- the
@emph{arity} of the function -- and saves it in the
associated @code{function} object.

Some languages allow the user to explicitly declare the
arity, in which case it may make sense to supply this
declared information to the assembler for cross-check
purposes.

There may also be cases where the assembler is unable to
compute the arity, or where you wish to override the
computed arity with an explicitly specified one -- for
example, when the function hasn't been written yet, and only
a preliminary stub is being compiled.

Muq encodes the arity information for a function as
a single integer, for speed of runtime checking.  The
arity has five logical components:

@enumerate
@item
Blocks consumed/used as input.
@item
Blocks returned as output.
@item
Normal (nonblock) args consumed/used as input.
@item
Normal (nonblock) args returned as output.
@item
Function type.
@end enumerate

Where ``Function type'' is a catchall slot for
indicating other information of interest about
the function.  It will currently be one of:

@example
0  arityNormal		A vanilla function.
1  arityExit		This function never returns to caller.
2  arityBranch		A bytecode that alters the program counter.
3  arityOther  	I'm not sure this is used.
4  arityCalli		Special hack for JOB_OP_CALLI bytecode.
5  arityQ		Function returns unpredictable number of args.
6  arityStartBlock	Special hack for '[' operator.
7  arityEndBlock	Special hack for '|' operator.
8  arityEatBlock	Special hack for ']' operator.
9  arityCalla		Special hack for JOB_OP_CALLA bytecode.
10 arityCallMethod	Special hack for JOB_OP_CALL_METHOD bytecode.
@end example

The specific decimal values given are subject to change
in future releases:  Use the given symbolic constant names
instead.

These constants are defined in
@file{muq/muf/10-C-utils.t} and @file{muq/c/fun2.h},
which also define the layout of an arity word:

@example
/****************************************************/
/* The current layout looks like:                   */
/*						    */
/*   MSB 33222222222211111111110000000000 LSB	    */
/*       10987654321098765432109876543210	    */
/*        S-----Ss-----sB----Bb----bt--tI	    */
/*						    */
/* where:					    */
/*   I:       1-bit typetag identifying integers.   */
/*   t--t:    4-bit type (see FUN_ARITY_TYP_*).	    */
/*   b----b:  6-bit count of stackblocks accepted.  */
/*   B----B:  6-bit count of stackblocks returned.  */
/*   s-----s: 7-bit count of scalar args accepted.  */
/*   S-----S: 7-bit count of scalar args returned.  */
/****************************************************/
@end example

(Again, this layout is subject to change in future
release:  Use @code{implodeArity} to construct
arity values, rather than hardwiring assumptions
about the layout into your code.
@xref{implodeArity,,,muqref.t,implodeArity}.)

Thus, if your function accepts two blocks and
three normal arguments, and returns one block
and zero normal arguments, you may construct
an appropriate arity value for it via

@example
2 3 1 0 arityNormal implodeArity -> arity
@end example

And the final argument to @code{finishAssembly}?

It is an @emph{force} flag which may be set
non-@sc{nil} to force the assembler to accept
the arity value you supply as valid, rather
than conducting its own cross-check.

And what if you want to let the assembler compute the
function arity on its own, and ignore your value?  In
this case, provide an arity of -1 and leave the
@code{force} argument @sc{nil}.

Bottom-line take-home lesson for this section: 99% of
the time, you can supply @sc{nil} as the @code{force}
argument and -1 as the arity argument, and everything
will go fine.

Ok, enough discussion of how to assemble the trivial
function: Let's assemble some functions which actually
things!

@c {{{endfold}}}
@c {{{ Assembling Constants And Calls

@c
@node  Assembling Constants And Calls, Assembling Conditionals And Loops, Specifying Function Arity, A Code Generator
@subsubsection Assembling Constants And Calls

Much of the useful work done by a program consists
of loading needed constants onto the stack, and then
calling functions on them.  Let's see how to do that.
We'll assume the @code{*fun*} and @code{*asm*}
variables established in the previous section are still
with us.

@example
stack:
*asm* reset
stack:
"Hello, world!\n" *asm* assembleConstant
stack:
#', *asm* assembleCall
stack:
nil 0 *fun* *asm* finishAssembly --> *cfn*
stack:
*cfn* call@{ -> @}
Hello, world!
stack:
@end example

Whee -- everything should be so easy!

If we peek at the disassembly of @code{*cfn*} we
will find:

@example
constants:
0: "Hello, world!
"
code bytes:
00: 34 00 01 3f 2e
code disassembly:
000:      34 00       GETk   0
002:   00 3f          WRITE_OUTPUT_STREAM
004:      2e          RETURN 
@end example

Let's cover some fine points not obvious from
inspection of the above.

The @code{assembleConstant} function tells the
assembler to append to the @code{compiledFunction}
code which will result in the given constant being
loaded on the stack at runtime.

(We don't know or care exactly how the assembler does
this: The particular bytecode instructions used
actually vary somewhat depending on the type and value
of the constant, as it happens.  Future releases of Muq
may change change the precise set of load-constant
bytecodes available to the assembler; Since the
assembler takes care of this, your compiler is
automatically portable across such changes.)

The current Muq assembler isn't terribly smart, but it
@emph{does} do one simple but handy optimization in the
@code{assembleConstant} routine: If the constant you
ask for has already been loaded once by the function
(so that it is already available in the
@sc{compiledFunction} constant vector), then the
existing constant vector slot will be re-used rather
than a new one created.  This is worth knowing, if only
so that you don't feel obligated to implement the same
optimization in your own compilers.

(In general, future releases of Muq will attempt to add
optimizations to the assembler rather than the
compilers: Since there will be many compilers but only
one assembler, this saves effort over the long haul.)

The @code{assembleCall} function also hides some
secrets.  First, the value you give to it may be
either a @code{compiledFunction} or a symbol with
a @code{compiledFunction} functional value.  Both
are useful, but they are not equivalent:

@itemize @bullet
@item
Specifying a @code{compiledFunction} value generates
runtime code which directly calls the given
@code{compiledFunction}.  This is the fastest option.
@item
Specifying a symbol generates runtime code which looks
up the function value of the symbol and calls it. This
is somewhat slower than the direct call, but in return
you get the added flexibility of being able to change
the function called at runtime by setting the
functional value of the symbol -- and also the
advantage that your function need not be recompiled
just because the function called got recompiled.
@end itemize

I think the added flexibility is well worth the small
runtime speed cost, and strongly recommend that you
generate calls via symbols as a normal matter of
course.

To do this in the above example, we would replace the
line

@example
#', *asm* assembleCall
@end example

@noindent
by the line

@example
', *asm* assembleCall
@end example

Now, let's try something even more ambitious: A
function which adds 2+2 to get 4:

@example
stack:
*asm* reset
stack:
2 *asm* assembleConstant
stack:
2 *asm* assembleConstant
stack:
'+ *asm* assembleCall
stack:
nil -1 *fun* *asm* finishAssembly --> *cfn*
stack:
*cfn* call@{ -> $ @}
stack: 4
@end example

If we peek at the disassembly of @code{*cfn*} we
will now find:

@example
constants:
code bytes:
00: 33 02 33 02 0c 2e
code disassembly:
000:      33 02       GETi   2
002:      33 02       GETi   2
004:      0c          ADD    
005:      2e          RETURN 
@end example

As a minor point, note that this time the Muq assembler
produced a different load-constant instruction than it
did last time:  It switched to a special load-immediate
integer instruction to avoid allocating a constant
slot.  This is the sort of minor optimization mentioned
above which saves you as compiler writer from having to
worry about such issues, and frees the server
implementor to tune the bytecode instruction set in
future without breaking existing compilers.

More importantly, note that in both of the previous two
examples, the @code{assembleCall} function did not in
fact assemble a call to the indicated function, but
instead emitted a primitive bytecode to do the same
thing.  This is another optimization done by the
assembler, trivial in terms of computation required,
but very important because it again decouples the
compilers from the bytecode architecture: The Muq
compiler writer in general @code{need never know} while
functions are implemented in-db, and which are
implemented in-server, which again means that the
compiler writer has less to worry about, and that the
server maintainer can continue to tune the virtual
machine in future release by moving functionality
between the server and the db, without breaking
existing compilers.

Bottom-line take-home lesson from this section:
@quotation
@cartouche
Almost all the useful work done by the functions you
compile will be done by code deposited via
@code{assembleCall} calls.  Some of these calls will
produce server-implemented bytecode primitives, and
some will produce calls to functions in the db: As a
compiler writer, you need not know or care which.
@end cartouche
@end quotation

The next sections explore exceptions to the above rule
@emph{grin}.

@c {{{endfold}}}
@c {{{ Assembling Conditionals And Loops

@c
@node  Assembling Conditionals And Loops, Assembling Local Variables, Assembling Constants And Calls, A Code Generator
@subsubsection Assembling Conditionals And Loops

One major class of programming language functionality
which cannot easily be expressed simply as loading a
constant or calling a function is control structure:
loops, ifs and such.  From the compiler writer's
point of view, these are all built out of labels
marking places in the code, and branch instructions
jumping to these labels.

Let's assemble a simple "nil if 1 else 2 fi" function,
which demonstrates all the essentials:

@example
stack:
*asm* reset
stack:
*asm* assembleLabelGet --> *elseLabel*
stack:
*asm* assembleLabelGet --> *fiLabel*
stack:
nil *asm* assembleConstant
stack:
*elseLabel* *asm* assembleBeq
stack:
1 *asm* assembleConstant
stack:
*fiLabel* *asm* assembleBra
stack:
*elseLabel* *asm* assembleLabel
stack:
2 *asm* assembleConstant
stack:
*fiLabel* *asm* assembleLabel
stack:
nil -1 *fun* *asm* finishAssembly --> *cfn*
stack:
*cfn* call@{ -> $ @}
stack: 2
@end example

This time, a peek at the disassembly produces:

@example
constants:
0: nil
code bytes:
00: 34 00 1f 04 33 01 2b 02 33 02 2e
code disassembly:
000:      34 00       GETk   0
002:      1f 04       BEQ    008:
004:      33 01       GETi   1
006:      2b 02       BRA    00a:
008:      33 02       GETi   2
00a:      2e          RETURN 
@end example

How does this work?

@itemize @bullet
@item
@code{assembleLabelGet} allocates code labels.
(These are currently small integers, but your
code should be written to depend on this.)
@item
@code{assembleLabel} deposits a the given label
at the current spot in the code.  @emph{You must
have allocated the label via 
@code{assembleLabelGet}.}
@item
@code{assembleBne}, @code{assembleBeq},
@code{assembleBra}, each deposit a branch to the
specified label.  @emph{You must have allocated the
label via @code{assembleLabelGet}.}
@itemize @bullet
@item
@code{assembleBne} assembles a conditional
branch which pops the stack and branchs iff
it is non-@sc{nil}.
@item
@code{assembleBeq} assembles a conditional
branch which pops the stack and branchs iff
it is @sc{nil}.
@item
@code{assembleBra} assembles an unconditional
branch.
@end itemize
@end itemize

Labels may be deposited before or after the matching
branch.  Preceding labels result in loops; following
labels result in conditionals.  The Muq assembler cares
nothing about how well-structured your jump
architecture is (although future optimizing versions of
it may have difficulty optimizing nasty unstructured
code).

Just be sure that every label used was properly
allocated, and that every branch assembled is to a
properly deposited label.

As a minor note: The Muq server implements both one-
and two-byte branch offsets.  The assembler uses the
usual jump minimization algorithm to always use
one-byte branch offsets where possible.  Supporting
three-byte branch offsets would be trivial, but I don't
think I want people clogging the virtual memory buffer
with functions more than 64K long, so I haven't
implemented this.  Any function producing more than
64K of code probably needs to be rewritten :).

@c {{{endfold}}}
@c {{{ Assembling Local Variables

@c
@node  Assembling Local Variables, Assembling Debug Information, Assembling Conditionals And Loops, A Code Generator
@subsubsection Assembling Local Variables

Another major class of programming language
functionality which cannot easily be expressed simply
as loading a constant or calling a function is local
variables: What C afficionados call ``automatic''
variables.

The Muq assembler supplies the following functions
in support of local variables:

@itemize @bullet
@item
@code{assembleVariableSlot} Allocate a local variable.
@item
@code{assembleVariableGet} Load from a local variable.
@item
@code{assembleVariableSet} Store to a local variable.
@end itemize

Let's assemble code for @code{: square   -> x    x x * ;}
as an example:

@example
stack:
"square" --> *fun*$s.name
stack:
*asm* reset
stack:
"x" *asm* assembleVariableSlot --> *x*
stack:
*x* *asm* assembleVariableSet
stack:
*x* *asm* assembleVariableGet
stack:
*x* *asm* assembleVariableGet
stack:
'* *asm* assembleCall
stack:
nil -1 *fun* *asm* finishAssembly --> *cfn*
stack:
*cfn* 'square setSymbolFunction
stack:
2 square
stack: 4
@end example

This time, a peek at the disassembly shows:

@example
constants:
code bytes:
00: 2d 01 38 00 36 00 36 00 0e 2e
code disassembly:
000:      2d 01       VARS   1
002:      38 00       SETv   0
004:      36 00       GETv   0
006:      36 00       GETv   0
008:      0e          MUL    
009:      2e          RETURN 
@end example

By now, you can probably divine most of the coding rules
by inspection:

@itemize @bullet
@item
Allocate every local via @code{assembleVariableSlot}.
@item
Don't assume anything about the return value from
@code{assembleVariableSlot}, except that it will
be accepted by @code{assembleVariableGet} and
@code{assembleVariableSet}.
@item
Give @code{assembleVariableSlot} as input the name of
the local variable, as specified by the user.  If the
local is compiler-generated, pick a descriptive name
that starts with a blank: Debuggers will normally
suppress display of these.
@end itemize

Some fine points:

@itemize @bullet
@item
All local variables are always allocated at the start
of the function, via a single @sc{vars} instruction.
The assembler counts the number of locals you allocate
and emits the proper @sc{vars} instruction.  If you
allocate no locals, it generates no @sc{vars}
instruction, as another minor optimization.  There
is no need for the compiler writer to count the number
of locals allocated, or to attempt to allocate them
all before starting to generate code.
@item
Access to locals is much faster than access to symbols
(and about as fast as access to constants).  You should
feel free to use locals; You should avoid generating
needless accesses to symbols.  (Access to vector slots
will be a bit slower than access to symbol value slots,
of course, and access of object properties will be much
slower yet.)
@end itemize

@c {{{endfold}}}

@c {{{ Assembling Obscure Special Cases

@c
@node  Assembling Debug Information, Assembling Obscure Special Cases, Assembling Local Variables, A Code Generator
@subsubsection Assembling Debug Information

A production Muq compiler needs to do more than generate
code that executes successfully:  It should also document
that code well enough to support symbolic debugging,
including:

@itemize @bullet
@item
The source code used to generate the compiledFunction.
@item
The name of the function, if provided by the user.
@item
The names of local variables used.
@item
The line number in the source code of each instruction.
@item
The name of the file containing the source, if any.
@end itemize

We have already seen that the names of local variables
may be documented via @code{assembleVariableSlot},
and that the name of the function may be documented
by setting @code{fun$s.name}.  The remaining items
may be recorded as follows:

@itemize @bullet
@item
The name of the source file may be stored in
@code{asm$s.fileName}: The assembler will
copy it to @code{fun$s.fileName}.  You may
also set the latter directly.
@item
The location of the first line of the function
within the source file may be recorded in
@code{asm$s.file-line}: The assembler will
copy it to @code{fun$s.fileLine}.  You may
also set the latter directly.  @emph{Note that
the first line in the file is line zero,
for this purpose.}
@item
The source code for the function should be
stored in @code{fun$s.source}.
@item
The line number in the source corresponding to the
instructions being assembled should be recorded in
@code{asm$s.line-number}.  This may be set directly, or
via @code{assemble-line-number}, which is somewhat
faster.  This information winds up in
@code{fun$s.lineNumbers}, but you shouldn't manipulate
the latter directly, as its format is likely to change
in future releases.  These line numbers should start at
zero for the first line of code in the function: If the
line number within the source file is later desired,
@code{fun$s.fileLine} may be added in.
@end itemize

@c {{{endfold}}}

@c {{{ Assembling Obscure Special Cases

@c
@node  Assembling Obscure Special Cases, Code Generation Wrapup, Assembling Debug Information, A Code Generator
@subsubsection Assembling Obscure Special Cases

There are several other assembler commands currently
implemented.  Some of them are likely to vanish in
the near future, and none are central to normal
code generation;  I defer discussion of them to
a later version of this manual. :)

@c {{{endfold}}}

@c
@node  Code Generation Wrapup, Compiler Wrapup, Assembling Obscure Special Cases, A Code Generator
@subsubsection Code Generation Wrapup

This section is only half written, since only the
assembler interface has been described, not the actual
design and implementation of the code generator pass of
a compiler.  Patience!

@c {{{endfold}}}

@c {{{ Compiler Wrapup

@c
@node  Compiler Wrapup, Writing Mud Worlds, Code Generation Wrapup, Writing Muq Compilers
@subsection Compiler Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Writing Mud Worlds

@c
@node Writing Mud Worlds, Mud World Overview, Compiler Wrapup, Advanced Muf Programming
@section Writing Mud Worlds

@menu
* Mud World Overview::
* Mud World Wrapup::
@end menu

@c {{{ Mud World Overview

@c
@node  Mud World Overview, Mud World Wrapup, Writing Mud Worlds, Writing Mud Worlds
@subsection Mud World Overview

@c {{{endfold}}}
@c {{{ Mud World Wrapup

@c
@node  Mud World Wrapup, Writing Mud Shells, Mud World Overview, Writing Mud Worlds
@subsection Mud World Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Writing Mud Shells

@c
@node Writing Mud Shells, Mud Shell Overview, Mud World Wrapup, Advanced Muf Programming
@section Writing Mud Shells

@menu
* Mud Shell Overview::
* Mud Shell Wrapup::
@end menu

@c {{{ Mud Shell Overview

@c
@node  Mud Shell Overview, Mud Shell Wrapup, Writing Mud Shells, Writing Mud Shells
@subsection Mud Shell Overview

@c {{{endfold}}}
@c {{{ Mud Shell Wrapup

@c
@node  Mud Shell Wrapup, A Citadel, Mud Shell Overview, Writing Mud Shells
@subsection Mud Shell Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ A Citadel

@c
@node A Citadel, Citadel Overview, Mud Shell Wrapup, Advanced Muf Programming
@section A Citadel

@menu
* Citadel Overview::
* Citadel Wrapup::
@end menu

@c {{{ Citadel Overview

@c
@node  Citadel Overview, Citadel Wrapup, A Citadel, A Citadel
@subsection Citadel Overview

@c {{{endfold}}}
@c {{{ Citadel Wrapup

@c
@node  Citadel Wrapup, Phrase-Structure Grammars, Citadel Overview, A Citadel
@subsection Citadel Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Phrase-Structure Grammars

@c
@node Phrase-Structure Grammars, Grammars Overview, Citadel Wrapup, Advanced Muf Programming
@section Phrase-Structure Grammars

@menu
* Grammars Overview::
* Grammars Wrapup::
@end menu

@c {{{ Grammars Overview

@c
@node  Grammars Overview, Grammars Wrapup, Phrase-Structure Grammars, Phrase-Structure Grammars
@subsection Grammars Overview

@c {{{endfold}}}
@c {{{ Grammars Wrapup

@c
@node  Grammars Wrapup, Weizenbaums Eliza, Grammars Overview, Phrase-Structure Grammars
@subsection Grammars Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Weizenbaums Eliza

@c
@node Weizenbaums Eliza, Eliza Overview, Grammars Wrapup, Advanced Muf Programming
@section Weizenbaums Eliza

@menu
* Eliza Overview::
* Eliza Wrapup::
@end menu

@c {{{ Eliza Overview

@c
@node  Eliza Overview, Eliza Wrapup, Weizenbaums Eliza, Weizenbaums Eliza
@subsection Eliza Overview

@c {{{endfold}}}
@c {{{ Eliza Wrapup

@c
@node  Eliza Wrapup, Symbolic Algebra, Eliza Overview, Weizenbaums Eliza
@subsection Eliza Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Symbolic Algebra

@c
@node Symbolic Algebra, Symbolic Algebra Overview, Eliza Wrapup, Advanced Muf Programming
@section Symbolic Algebra

@menu
* Symbolic Algebra Overview::
* Symbolic Algebra Wrapup::
@end menu

@c {{{ Symbolic Algebra Overview

@c
@node  Symbolic Algebra Overview, Symbolic Algebra Wrapup, Symbolic Algebra, Symbolic Algebra
@subsection Symbolic Algebra Overview

@c {{{endfold}}}
@c {{{ Symbolic Algebra Wrapup

@c
@node  Symbolic Algebra Wrapup, Portability Issues, Symbolic Algebra Overview, Symbolic Algebra
@subsection Symbolic Algebra Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Portability Issues

@c
@node Portability Issues, Advanced Muf Programming Wrapup, Symbolic Algebra Wrapup, Advanced Muf Programming
@section Portability Issues

@quotation
Programming is difficult.  All programmers know the frustration
of trying to get a program to work accordig to specification.
But one thing that really defines the professional programmer
is the ability to write portable programs that will work on
a variety of systems.

--- Peter Norvig, @emph{Paradigms of Artificial Intelligence Programming}
@end quotation

@itemize @bullet
@item
Be clear about the distinction between the specification and
implementation of the facilities and packages you use.
Don't write code that depends on implementation-specific
details subject to change.  (Some novice programmers seem to
take special delight in writing code that depends on obscure
implementation details.)

@item
Don't use other packages frivolously: Users should not have
to to find and install a package just to make one of your
error messages prettier, say.  (This doesn't mean you should
replicate complete other packages inside your own just to
eliminate dependencies on other packages, of course!)

@item
Don't export symbols frivolously: This clutters the
namespaces of packages using your package, and may force
them to inport symbols one by one if there are too many name
clashes with other packages in use.  Try to find a design
with a reasonably small number of exported symbols.  If
you need to export symbols unlikely to be used very often,
give them long descriptive names less likely to clash with
symbol names from other packages.

@item
Look for ways to deduce system-dependent information at
installation time or on the fly, or else accept it as a
parameter, rather than embedding such dependencies in your
package code.

@item
If you must depend on some system-dependent property, such
as the location of a particular external resource, confine
this dependency to a single global variable or such, don't
scatter it repeatedly all through your code.
@end itemize

@c {{{endfold}}}
@c {{{ Advanced Muf Programming Wrapup

@node Advanced Muf Programming Wrapup, Function Index, Portability Issues, Advanced Muf Programming
@section Advanced Muf Programming Wrapup

This concludes the Advanced Muf Programming chapter.

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:

