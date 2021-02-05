@c  -*-texinfo-*-

@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c ---^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Core Muf, Core Muf Overview, Muq Event System Wrapup, Top
@chapter Core Muf
@menu
* Core Muf Overview::
* Function Documentation Conventions::
* arithmetic and bitwise functions::
* assembler functions::
* assignment functions::
* block functions::
* boolean functions::
* browsing functions::
* comparison functions::
* compiler support functions::
* event system functions::
* control structure syntax::
* conversion functions::
* db functions::
* debug support functions::
* function definition syntax::
* job control functions::
* keyval functions::
* lisp library::
* list functions::
* loop stack functions::
* math functions::
* message stream functions::
* misc functions::
* object creation functions::
* package functions::
* path functions::
* posix functions::
* predicates::
* assertions::
* predicates on chars::
* regular expressions::
* set and index functions::
* stack stream and vector functions::
* string functions::
* structure functions::
* low-level structure functions::
* MOS functions::
* low-level MOS functions::
* low-level btree functions::
* symbol functions::
* sysadmin functions::
* telnet functions::
* user i/o functions::
* graphics functions::
* x functions::
* Core Muf Wrapup::
@end menu


@c
@node Core Muf Overview, Function Documentation Conventions, Core Muf, Core Muf
@section Core Muf Overview
@cindex Core Muf
@cindex Flowers, let a thousand bloom
@cindex Wine, dilution of
@cindex Sophistication
@cindex Prim

Muq is designed to be a highly extendable framework from
which more specialized servers and applications can be
built: Muq systems can and should extend both Muq and
@sc{muf} in a wild variety of ways.  "Let a thousand flowers
bloom."

Amid this sea of chaos, one wishes to preserve a central
isle of stability from which the visitor may survey the
scene: This chapter defines a core layer of functionality
which every Muq @sc{muf} implementation should support,
which I hope is large enough to facilitate the construction
of portable packages, yet small enough that supporting the
full Core is not an undue burden on smaller implementations
(tempting them to implement only a subset).

This chapter documents both muf prims and in-db muf
functions.

"Prim" is short for "primitive".  Prims are so called not
because they are unsophisticated, but because they are the
atomic, irreducible components from which other code in the
system is built up@footnote{"To sophisticate" originally
meant to dilute wine (say) with other fluids, so in the
original sense, "unsophisticated" meant "undiluted".  Muq
primitives are straight C code, undiluted by any hint of
interpretation, and in this sense may be fairly thought of
as unsophisticated.}.

The muf prims are those hardcoded in C in the server itself,
as opposed to library functions coded in muf (or another
in-db language) and compiled into muq bytecodes.

From a system implementation perspective, prims and library
functions are quite different:

Prims may execute up to about one hundred times faster than
library functions, but are trickier to code, require
restarting the server to update, and may crash the entire
server if defective, or failing that may corrupt the db or
punch unintended holes in the security kernel.  Prims also
are locked into the executable image, meaning that they have
to be loaded into ram every time the server starts up, and
tend to stay in ram as long as it is running: a Muq server
could fairly easily support half a gigabyte of library
functions (since they would just sit on disk in the db until
actually needed), but most contemporary workstations would
be overwhelmed by half a gigabyte of primitives.

From the typical Muq programmer's point of view, however,
there is rarely any need to distinguish between prims and
library functions: The syntax is identical in either case.

So much so that we explicitly reserve to the implementor the
decision as to what Core functionality to implement
inserver, and what to implement in-db: We deem unportable
and nonstandard any @sc{muf} code written to depend on the
mode of implementation of any Core function.

This manual does document which functions are prims, and
which in-db @sc{muf}-coded, but such knowledge should be
used only to satisfy curiosity and for performance tuning.

By convention, @sc{muf}-coded Core functionality is kept in
the muq/[0-9][0-9]-C-*.muf files.

@c
@node Function Documentation Conventions, arithmetic and bitwise functions, Core Muf Overview, Core Muf, Core Muf
@section Function Documentation Conventions
@cindex Function documentation conventions

For purposes of this manual, a @dfn{function} is something
whose semantics are satisfactorily understood in terms of
consuming some (possibly zero) number of input values from
the data stack and returning some (possibly zero) number of
values on the data stack.  Thus, things which are not
mathematical functions, such as @code{frandom}, still
qualify, but things like @code{if} and @code{->} do not, and
are instead termed @dfn{operators}.

A typical function definition looks like

@quotation
@example
join @{ string string -> string @}
File: job.t
Status: alpha
@end example

The @code{join} function concatenates two strings and
returns the resulting string.
@end quotation

The first line gives the name of the function followed by
the the number of values it accepts and returns, separated
by @code{->}.  There may be more than one line like this if
the function does several distinct tasks depending on the
types of its parameters.  Groups of related functions may
also be listed one per line here.  Operators other than
functions (such as function definition, variable assignment,
and control structure operators) give a synoptic usage
example rather than a simple argsIn/argsOut declaration.

Argument abbreviations used include
@table @samp
@item int
An integer.

@item flt
A floating point number.

@item #
An number, integer or floating point.

@item stg
A string.

@item obj
Any variety of object supporting generic keyval operations.

@item []
A stack block
@end table

The second line gives the source file implementing the
function.

The third line will be one of:

@table @samp
@item Status: temporary
This function is needed at the moment but is scheduled to be
replaced by something better.  releases.

@item Status: tentative
The function is offered for discussion and perhaps
experimentation, but is very likely to change in future
releases.

@item Status: alpha
The function is in useful form, but is subject to change if
any possible improvement becomes evident.

@item Status: beta
The function is thought to be final form, but is subject to
change if significant problems are identified in actual use.

@item Status: production
The function is baselined for general use, and incompatible
changes will be made only as a last resort.  (Compatible
extensions, such as allowing additional argument types, may
still be considered.)
@end table

@c
@node arithmetic and bitwise functions, assembler functions, Function Documentation Conventions, Core Muf
@section arithmetic and bitwise functions


@cindex arithmetic functions
@findex *
@findex %
@findex +
@c putting @c comment on same line as @findex crashes 'makeinfo' horribly.
@c using "@minus{}" instead of '-' on next line crashes TeX horribly.
@findex -
@findex /
@findex 1+
@findex 1-
@findex logior
@findex logxor
@findex logand
@findex lognot
@findex ash
@findex egcd
@findex gcd
@findex lcm
@findex neg
@findex frandom
@findex multiplicative inverse (modular)
@findex trulyRandomFixnum
@findex trulyRandomInteger
@findex generateDiffieHellmanKeyPair
@findex generateDiffieHellmanSharedSecret
@findex bits

@example
+          @{ #   #   -> #   @}
-          @{ #   #   -> #   @}
*          @{ #   #   -> #   @}
%          @{ int int -> int @}
/          @{ int int -> int @}
neg        @{ #       -> #   @}
gcd        @{ int int -> int @}
egcd       @{ int int -> int int int @}
lcm        @{ int int -> int @}
ash        @{ int int -> int @}
logand     @{ int int -> int @}
logior     @{ int int -> int @}
lognot     @{ int     -> int @}
logxor     @{ int int -> int @}
1+         @{ int     -> int @}
1-         @{ int     -> int @}
frandom    @{         -> flt @}
bits       @{ int     -> int @}
trulyRandomFixnum  @{         -> int @}
trulyRandomInteger @{ int     -> int @}
File: job.t
Status: alpha
@end example

Here is a quick table of @sc{muf} to C equivalences:

@example
i j %           Return i % j.  Integer only.
m n *           Return m * n.  Any combination of floats and ints.
m n +           Return m + n.  Any combination of floats and ints.
s t +           Append strings s and t.
m n -           Return m - n.  Any combination of floats and ints.
m n /           Return m / n.  Any combination of floats and ints, n != 0.
n   1+          Return n + 1.  Float or int.
n   1-          Return n - 1.  Float or int.
i j logand      Return i & j.  Int only.
i j logior      Return i | j.  Int only.
i j logxor      Return i ^ j.  Int only.
i j ash         Return i << j. Int only.
i   neg         Return     -i. Float or int.
    frandom     Return a pseudorandom() float:  0.0 <= random < 1.0
    trulyRandomFixnum  Return a truly random nonnegative fixnum. (61 bits.)
i   trulyRandomInteger Return a truly random nonnegative i-bit integer.
i   bits        Return number of bits in integer (offset of first 1 bit).
@end example

Signed integer values of 62 bits or less are handled as immediate
fixnums, and hence are considerably more efficient in space and time.
Other integer values are handled as heap-allocated bignums; Currently
integer precisions of up to a few thousand bits are supported.  Except
for efficiency issues, the distinction between fixnums and bignums
should not normally be user-visible.

The @code{gcd} function returns the Greatest Common
Divisor of two integers, using Euclid's algorithm.

Given @code{X,Y} the @code{egcd} (extended greatest common denominator)
function returns @code{GCD,C,D} where @code{GCD} is the usual greatest
common denominator, and where @code{C} and @code{D} are such that
@code{X*C + Y*D == GCD}.  The extra return values are sometimes useful.
In particular, @code{egcd} may be used to find modular multiplicative
inverses: If @code{X} and @code{Y} are positive and relatively prime
(@code{gcd(X,Y)==1}) with @code{X < Y}, then the multiplicative inverse
of @code{X}, mod @code{Y}, is @code{A}.  Here's a sample routine
returning the multiplicative inverse else @code{nil}:

@example
:  inv @{ $ $ -> $ @}
   -> p  ( The modulus.      )
   -> a  ( Number to invert. )
   a p egcd -> b -> a -> g
   g 1 != if nil return fi ( A and P not relatively prime. )
   a 0 >  if a   return fi
   p a +                   ( Return positive value always. )
;
@end example



The @code{lcm} function returns the Least Common Multiple of
two integers, defined following CommonLisp as @code{abs(a*b)
/ gcd(a,b)}.

The @code{log-*} functions perform bitwise operations on
integers.

The @code{1+} and @code{1-} functions are no faster than
doing @code{1 +} and @code{1 -}, and in fact compile into
the same code: Use or non-use of them is a stylistic choice.

Notes:

@itemize @bullet
@item
I dislike the @code{log*} names (e.g., @code{and-bits} seems
more readable and more consistent with our general verb-noun
naming convention) and particularly dislike @code{ash} for
arithmetic shift, but it seems best to stick with the
CommonLisp standard here.

@item
The current @code{trulyRandomInteger} implementation is a best-effort
approach which operates by maintaining an internal bitbuffer
into which information from asynchronous events is accumulated:
When random bits are requested, a Secure Hash of the bitbuffer
is used as a whitening function and the result returned.  There
is no attempt to guarantee that entropy entered into the bitbuffer
exceeds "truly random" bits extracted from the buffer.  I expect
this implementation to suffice for most intended purposes, in
particular passphrase generation and digital signature applications.
If not, we can improve the algorithm later without changing the
API, and hence without breaking existing dbs in the upgrade.

@item
The @code{generateDiffieHellmanKeyPair} function accepts a generator and prime
@code{g} and @code{p} (typically @code{dh:g} and @code{dh:p}) and
returns a public and private Diffie-Hellman key.  This is equivalent
to doing simply

@example
159 trulyRandomInteger -> privateKey
g privateKey p exptmod -> publicKey
@end example

except that for
security the private key is returned as a special
@code{#<DiffieHellmanPrivateKey>} instead of as an integer.
(@code{#<DiffieHellmanPrivateKey>} values may not be exported,
inspected, or used in ordinary arithmetic operations.)

@item
The @code{generateDiffieHellmanSharedSecret} function is equivalent to

@example
@end example
publicKey privateKey p exptmod
@end itemize

except that (as security precautions) privateKey is required to be a
@code{#<DiffieHellmanPrivateKey>} instead of as an integer, and the
resulting value is a @code{#<DiffieHellmanSharedSecret>} instead of
an integer.

@c
@node assembler functions, assembler overview, arithmetic and bitwise functions, Core Muf
@section assembler functions
@cindex assembler functions

This section covers the interface to the Muq
assembler class: A set of primitive functions
which together may be used to produce executable
@code{compiledFunction} objects.

You probably don't need to read this section unless
you are writing or maintaining Muq compilers.

@menu
* assembler overview::
* assembleAfter::
* assembleAfterChild::
* assembleAlwaysDo::
* assembleBeq::
* assembleBne::
* assembleBra::
* assembleTag::
* assembleCall::
* assembleCalla::
* assembleCatch::
* assembleConstant::
* assembleConstantSlot::
* assembleConstantGet::
* assembleLabel::
* assembleLabelGet::
* assembleLineInFn::
* assembleVariableGet::
* assembleVariableSet::
* assembleVariableSlot::
* finishAssembly::
* assembler wrapup::
@end menu

@c
@node  assembler overview, assembleAfter, assembler functions, assembler functions
@subsection assembler overview

The Muq assembler uses a procedural rather than text
interface:  To produce a Muq @code{compiledFunction}
you:

@itemize @bullet
@item
Create an Assembler instance using @code{makeAssembler}
(or @code{reset} an existing assembler.

@item
Specify a sequence of instructions using primitive functions
such as @code{assembleBra}, @code{assembleLabel} and @code{assembleCall}.

@item
Call @code{assembleFinishAssembly} to generate and return the
actual compiledFunction.
@end itemize

Here's an example compiling a simple 'hello' function
equivalent to @code{: hello "Hello, world!\n" , ;}

@example
stack:
makeAssembler --> *asm*
stack:
"Hello, world!\n" *asm* assembleConstant
stack:
#', *asm* assembleCall
stack:
nil -1 makeFunction asm finishAssembly
stack: #<c-fn _>
--> #'hello
stack:
hello
Hello, world!
stack:
@end example

Code is deposited monotonically from start to end of
function: there is no way to back up and insert more
instructions between those already laid down.

Jumps are connected to labels by giving them matching ids:
Calling @code{assembleLabel} with an @sc{id} of 13, and
(later or earlier) calling @code{assembleBra} also with an
@sc{id} of 13, results in assembly of an unconditional jump
from the @code{assembleBra} location to the
@code{assembleLabel} location.  It is an error if there is
not exactly one matching label for each branch.  @sc{id}s
should be small integers obtained from
@code{assembleLabelGet}.

Most bytecodes are deposited by doing an
@code{assembleCall} on the appropriate function: The
assembler checks to see if the function is a primitive, and
if so deposits the appropriate bytecodes rather than an
actual call.  This greatly simplifies compiler construction
and maintainance, since the compilers need contain very
little information about the bytecoded instruction set.

The exceptions are the bytecodes which need special
parameters.  These fall into two general classes:

@enumerate
@item
Those which need a label parameter specifying the scope of
some construct (the jumps and error-trapping primitives).

@item
Those which need a parameter specifying an offset into
the constant vector or stackframe (the local-variable
get- and set- primitives, mostly).
@end enumerate

Note that there are special assembler functions to push
@sc{catchframes} and @sc{unwindframes,} but no special
functions to pop them.  This is because they can be popped
merely by invoking @code{assembleCall} on
@code{popCatchframe} and @code{popUnwindframe}. The
corresponding pushes cannot be handled this way because they
need to reference a code label.

Note that @sc{lockframes} (implementing
@code{withLockDo@{@dots{}@}}) are both pushed and popped in
this fashion, using @code{pushLockframe} and
@code{popLockframe}.




@c
@node  assembleAfter, assembleAfterChild, assembler overview, assembler functions
@subsection assembler after

@defun assembleAfter @{ label asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleAfter} prim is a specialized hack
supporting the @sc{muf} @code{after@{ @dots{} @}alwaysDo@{ @dots{} @}}
construct -- and matching constructs in other languages.

We implement @code{after@{ @dots{} @}alwaysDo@{ @dots{} @} }
as follows:
@example
assembleLabelGet  -> label1
assembleLabelGet  -> label2
label1 asm assembleAfter                    ( Push a @sc{protectframe} )
@dots{}                                      ( Protected code clause )
label2 asm assembleAlwaysDo                ( Convert frame to @sc{vanilla} )
label1 asm assembleLabel                    ( Label matching @sc{after} )
@dots{}                                      ( Mandatory code clause )
label2 a assembleLabel                      ( Label end of clause )
.lib.muf.popUnwindframe a assembleCall     ( Pop @sc{vanilla} frame. )
@end example

This is internally the most complex of the control
structures to implement, and what can actually happen gets
somewhat involved.

For example, if a @code{throw} is executed in the
protected first clause, it must be interrupted
long enough for the second clause to be executed,
and then resumed at the end of the second clause.

This is implemented by pushing an appropriate
frame on the loop stack as a flag before beginning
execution of the second clause; popUnwindframe
then checks the frame on top of the loopstack when
it executes: if it finds a VANILLA frame, it
merely pops it and lets execution continue; if it
finds a special flag frame, it pops it and
continues the interrupted operation, whatever it
was.

Additional complexities arise if the protected
clause contains fork operations, since the second
clause must still be executed exactly once
(@emph{not} exactly once per job).

However, the above boilerplate sequence is all one needs
to know as an in-db compiler writer in order to implement
the construct.

@end defun

@c
@node  assembleAfterChild, assembleAlwaysDo, assembleAfter, assembler functions
@subsection assembleAfterChild

@defun assembleAfterChild @{ label asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleAfterChild} prim is identical
to the @code{assembleAfter} prim except that if a
@code{forkJob} is executed in the first clause in
the @sc{muf} @code{after@{ @dots{} @}alwaysDo@{
@dots{} @}} statement, the second clause is
executed only in the child job, whereas with the
@code{assembleAfter} prim the second clause is
executed only in the original job.

@end defun

@c
@node  assembleAlwaysDo, assembleBeq, assembleAfterChild, assembler functions
@subsection assembleAlwaysDo

@defun assembleAlwaysDo @{ label asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleAlwaysDo} prim provides
specialized support for the @sc{muf} @code{after@{ @dots{} @}alwaysDo@{
@dots{} @}} statement. @xref{assembleAfter}.

@end defun

@c
@node  assembleBeq, assembleBne, assembleAlwaysDo, assembler functions
@subsection assembleBeq

@defun assembleBeq @{ label asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleBeq} prim is one of four
functions provided in support of basic
control structures such as @code{if-then-else}
and @code{loop@{@dots{}@}}.

The @code{assembleBeq} deposits a conditional
branch to the given @code{label}.

At runtime, the deposited branch will pop one
value from the data stack:  If that value is
@code{nil}, the next instruction executed with
be that located at @code{label}, otherwise
execution continues normally with the next
instruction.

For example, @code{: ab if "a" else "b" fi ;} can be
compiled so:

@example
stack:
makeAssembler --> *asm*
stack:
*asm* reset
stack:
*asm* assembleLabelGet --> *elseLabel* ( Allocate first label )
stack:
*asm* assembleLabelGet --> *endLabel*  ( Allocate second label )
stack:
*elseLabel* *asm* assembleBeq ( Deposit conditional jump )
stack:
"a" *asm* assembleConstant ( Deposit 'then' clause body )
stack:
*endLabel* *asm* assembleBra ( Deposit unconditional jump to end )
stack:
*elseLabel* *asm* assembleLabel ( Deposit 'else' label )
stack:
"b" *asm* assembleConstant ( Deposit 'else' clause body )
stack:
*endLabel* *asm* assembleLabel ( Deposit 'end' label )
stack:
nil -1 makeFunction *asm* finishAssembly --> #'ab ( Compile fn 'ab' )
stack:
t ab ( Test fn 'ab' on true value )
stack: "a"
pop nil ab ( Test fn 'ab' on false value )
stack: "b"
@end example

@xref{assembleBne}.
@xref{assembleLabel}.
@xref{assembleLabelGet}.

@end defun

@c
@node  assembleBne, assembleBra, assembleBeq, assembler functions
@subsection assembleBne

@defun assembleBne @{ label asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleBne} prim is exactly identical
to the @code{assembleBeq} prim except that the
sense of the conditional test is reversed: the
conditional branch is taken only if the value
popped at runtime is @emph{not} @code{nil}.

@xref{assembleBeq}.


@end defun

@c
@node  assembleBra, assembleTag, assembleBne, assembler functions
@subsection assembleBra

@defun assembleBra @{ label asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleBra} prim is similar to the
@code{assembleBeq} and @code{assembleBne}
prims, except that the jump deposited is
unconditional and does not pop a value off
the stack.

@xref{assembleBne}.
@xref{assembleLabel}.
@xref{assembleLabelGet}.

@end defun

@c
@node  assembleTag, assembleCall, assembleBra, assembler functions
@subsection assembleTag

@defun assembleTag @{ label asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleTag} prim supports
implementation of non-local @code{goto} operations
-- those which jump from one function to an
enclosing function, much like the C
@code{longjmp()} library function.

The @code{assembleTag} prim deposits an
instruction which at runtime will pop a tag from
the job's data stack and push a
@sc{job_stackframe_tag} stackframe onto the job's
loop stack, containing the popped tag together
with the given @code{label}: As long as that
stackframe exists, any @code{goto} of that tag
will result in a transfer of control to the given
@code{label}.

You may mark the end of the tag's scope by
popping the @sc{job_stackframe_tag} stackframe
using the @code{popTagframe} primitive.

For technical reasons relating to support for
the CommonLisp standard, any sequence of one
or more @sc{job_stackframe_tag} stackframes
pushed on the loopstack should be topped off
with a @sc{job_stackframe_tagtop} frame: These
can be pushed and popped using
@code{pushTagtopframe}
and @code{popTagtopframe}.

Here is an example which hand-compiles

@example
:   xx 
    withTag qqq do@{  ( Establish nonlocal goto target  )
       'qqq goto      ( Do nonlocal goto to 'tag' label )
       "Hi mom!"      ( This will get jumped over.      )
    qqq               ( Specify tag label location.     )
       "Hi dad!"      ( This will get executed.         )
    @}                 ( End of tag scope.               )
;
@end example

@example
stack:
makeAssembler --> *asm*
stack:
*asm* reset
stack:
*asm* assembleLabelGet --> *label* ( Allocate label )
stack:
'qqq *asm* assembleConstant ( Code to push tag on stack )
stack:
*label* *asm* assembleTag ( Code to push tagframe on stack )
stack:
#'pushTagtopframe *asm* assembleCall ( Code to push tagtopframe on stack )
stack:
'qqq *asm* assembleConstant ( Code to again push tag on stack )
stack:
#'goto *asm* assembleCall ( Code to do nonlocal goto )
stack:
"Hi mom!" *asm* assembleConstant ( Code to get jumped over )
stack:
*label* *asm* assembleLabel ( Label location )
stack:
"Hi dad!" *asm* assembleConstant ( Code to get executed )
stack:
#'popTagtopframe *asm* assembleCall ( Code to pop tagtopframe from stack )
stack:
#'popTagframe *asm* assembleCall ( Code to end tag scope )
stack:
nil -1 makeFunction *asm* finishAssembly --> #'xx ( Compile fn 'xx' )
stack:
xx ( Invoke function )
stack: "Hi dad!"
@end example

@end defun

@c
@node  assembleCall, assembleCalla, assembleTag, assembler functions
@subsection assembleCall

@defun assembleCall @{ function asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleCall} prim is the workhorse
assembler call used to assemble all vanilla instructions
-- those which don't have an associated label or
other similar peculiarity.

Note in particular that the @code{assembleCall}
prim is used to deposit calls to both functions
coded in-db, and also primitive functions coded
in-server in C: The Muq compiler writer has in
general no need to distinguish between these two
cases, and Muq compilers have in general no need
to contain a list of all primitives supported by
the Muq virtual machine.  (This both simplifies
the Muq compilers, and means that they do not need
to be recoded if a given function changes from
being a C-coded prim to being coded in-db.)

The @code{function} argument may be either a
compiledFunction, or else a symbol containing
a compiledFunction in its @code{symbolFunction}
slot (@code{symbol$s.function}).

For example, here's a hand-assembly of the
function @code{: x * ;}

@example
makeAssembler --> *asm*
stack:
*asm* reset
stack:
#'* *asm* assembleCall
stack:
nil -1 makeFunction *asm* finishAssembly --> #'x ( Compile fn 'x' )
stack:
2.3 3.4 x ( Invoke function )
stack: 7.81982
@end example

@end defun

@c
@node  assembleCalla, assembleCatch, assembleCall, assembler functions
@subsection assembleCalla

@defun assembleCalla @{ arity asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleCalla} prim is used to compile
a call to a function which will be passed at
runtime, and which is expected to have a given
arity:  The runtime call will pop a compiledFunction
off the stack, check that the arity is as
expected, and then issue the call.

Here's a hand-assembly of

@example
:   f2 @{ $ $ $ -> $ @} -> fn 
    fn call@{ $ $ -> $ @}
;
@end example

@noindent
as an example:


@example
makeAssembler --> *asm*
stack:
*asm* reset
stack:
0 2 0 1 arityNormal implodeArity *asm* assembleCalla
stack:
nil -1 makeFunction *asm* finishAssembly --> #'f2 ( Compile fn 'f2' )
stack:
3.4 4.5 #'* f2 ( Invoke function )
stack: 15.2998
@end example

@end defun

@c
@node  assembleCatch, assembleConstant, assembleCalla, assembler functions
@subsection assembleCatch

@defun assembleCatch @{ label asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleCatch} prim supports
implementation of @code{catch/throw}
functionality:  @code{catch/throw} is
similar to the non-local @code{goto},
but additionally supports passing a
block of values from the @code{throw}
to the @code{catch}.


Here's a hand-assembly of

@example
: test  'aaa catch@{ [ "Whee!" | 'aaa ]throw @} ;
@end example

@noindent
as an example:


@example
makeAssembler --> *asm*
stack:
*asm* reset
stack:
'aaa *asm* assembleConstant
stack:
*asm* assembleLabelGet --> *label*
stack:
*label* *asm* assembleCatch
stack:
#'startBlock *asm* assembleCall
stack:
"Whee!" *asm* assembleConstant
stack:
#'endBlock *asm* assembleCall
stack:
'aaa *asm* assembleConstant
stack:
#']throw *asm* assembleCall
stack:
*label* *asm* assembleLabel
stack:
nil -1 makeFunction *asm* finishAssembly --> #'test ( Compile fn 'test' )
stack:
test ( Invoke function )
stack: [ "Whee!" | t
@end example
@end defun

@c
@node  assembleConstant, assembleConstantSlot, assembleCatch, assembler functions
@subsection assembleConstant

@defun assembleConstant @{ any asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleConstant} prim stores the
given constant in the new compiledFunction's
constant vector and deposits an instruction
to load it on the stack at runtime.  If the
given constant is already in the constant
vector, the pre-existing copy will be used
rather than entering it a second time.

@end defun

@c
@node  assembleConstantSlot, assembleConstantGet, assembleConstant, assembler functions
@subsection assembleConstantSlot

@defun assembleConstantSlot @{ asm -> offset @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleConstantSlot} prim allocates a
constant slot and returns it's offset.  There is
currently little use for this.

@end defun

@c
@node  assembleConstantGet, assembleLabel, assembleConstantSlot, assembler functions
@subsection assembleConstantGet

@defun assembleConstantGet @{ offset asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleConstantGet} prim deposits
code to fetch from the given offset within the
compiledFunction's constant vector.  There is
currently little use for this.

@end defun


@c
@node  assembleLabel, assembleLabelGet, assembleConstantGet, assembler functions
@subsection assembleLabel

@defun assembleLabel @{ offset asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleLabel} function marks the spot
corresponding to a label within the code for a
function.  The @code{offset} value should have
been obtained earlier by calling
@code{assembleLabelGet}, and will typically be
the target for a (possibly conditional) branch
instruction.

@end defun

@c
@node  assembleLabelGet, assembleLineInFn, assembleLabel, assembler functions
@subsection assembleLabelGet

@defun assembleLabel @{ asm -> label @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleLabelGet} prim allocates and
returns a new label for the compiledFunction
being assembled.  It will later be given to the
@code{assembleLabel} prim to mark the proper
spot, and typically also to a (possibly
conditional) branch jumping to the spot.

@end defun

@c
@node  assembleLineInFn, assembleVariableGet, assembleLabelGet, assembler functions
@subsection assembleLineInFn

@defun assembleLineInFn @{ line asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleLineInFn} function specifies
the current line number in the source
corresponding to the next instruction assembled,
relative to the start of the current function.
The assembler records this internally in the
generated code for use by debuggers.

Calling this function is exactly equivalent to setting the
@code{asm$s.lineInFn} property, but a bit faster.

@end defun


@c
@node  assembleVariableGet, assembleVariableSet, assembleLineInFn, assembler functions
@subsection assembleVariableGet

@defun assembleVariableGet @{ offset asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleVariableGet} prim deposits
code to load the value of the given local
variable onto the data stack.  The @code{offset}
value should have been obtained from the
@code{assembleVariableSlot} prim.

@end defun

@c
@node  assembleVariableSet, assembleVariableSlot, assembleVariableGet, assembler functions
@subsection assembleVariableSet

@defun assembleVariableSet @{ offset asm -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{assembleVariableSet} prim deposits
code to pop the top value on the data stack
into the given local variable.  The @code{offset}
value should have been obtained from the
@code{assembleVariableSlot} prim.

@end defun

@c
@node  assembleVariableSlot, finishAssembly, assembleVariableSet, assembler functions
@subsection assembleVariableSlot

@defun assembleVariableSlot @{ name asm -> offset @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display


The @code{assembleVariableSlot} prim allocates a
fresh local variable and returns its offset, which
value can later be used with the
@code{assembleVariableGet}
and @code{assembleVariableSet} prims.

@end defun

@c
@node  finishAssembly, assembler wrapup, assembleVariableSlot, assembler functions
@subsection finishAssembly

@defun finishAssembly @{ force arity function asm -> compiledFunction @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{finishAssembly} prim complete assembly
of a function and returns the resulting
@code{compiledFunction} object.

If the @code{force} argument is non-@code{nil}, the
compiledFunction is assigned the specified
@code{arity} without attempting to verify that
it is correct.

If the @code{force} argument is @code{nil}, the
assembler does a simple symbolic execution of
the function to deduce its arity (number of
blocks and scalars accepted and returned).
The simple symbolic execution algorithm is
sufficient to automatically deduce the arity
of many functions, but will currently fail
on recursive functions.

The @code{arity} value may be constructed
using @code{implodeArity}, or may be set
to @code{-1} meaning "dunno".

The @code{function} argument is a Class Function
instance in which to store info about the
generated @code{compiledFunction}, including
for example the arity and the source code.

@end defun

@c
@node  assembler wrapup, assignment functions, finishAssembly, assembler functions
@subsection assembler wrapup

Here's a quick-reference summary of the assembler functions:

@example

assembleConstant      @{ k a ->   @}
assembleConstantSlot @{   a -> i @}
assembleConstantGet  @{ i a ->   @}
assembleLabel         @{ i a ->   @}
assembleLabelGet     @{   a -> i @}
assembleLineInFn    @{ i a ->   @}
assembleVariableGet  @{ i a ->   @}
assembleVariableSet  @{ i a ->   @}
assembleVariableSlot @{ n a -> i @}

assembleAfter         @{ i a -> @}
assembleAfterChild   @{ i a -> @}
assembleAlwaysDo     @{ i a -> @}
assembleBeq           @{ i a -> @}
assembleBne           @{ i a -> @}
assembleBra           @{ i a -> @}
assembleTag           @{ i a -> @}
assembleCall          @{ f a -> @}
assembleCalla         @{ # a -> @}

assembleCatch         @{ i a -> @}

@end example

Decoding hints:

@example

The 'a' operands are in each case an assembler instance.
The 'i' operands are integer labels and offsets.
The 'k' operands are arbitrary constants of any type whatever.
The 'f' operands are function instances.
The 'x' operands are executable (compiledFunction) instances.
The '#' operands are integer arity declarations.
The 'n' operands are names, normally strings.

@end example

Summary of assembler call semantics:

@example
assembleAfter            Assemble PUSH_PROTECT       opcode linked to label i.
assembleAfterChild      Assemble PUSH_PROTECT_CHILD opcode linked to label i.
assembleAlwaysDo        Assemble BLANCH_PROTECT opcode linked to label i.
assembleBeq              Runtime: Pop stacktop, jump if @code{nil}.
assembleBne              Runtime: Pop stacktop, jump if not @code{nil}.
assembleBra              Runtime: Jump unconditionally to label i.
assembleCall             Assemble call to fn f, inline bytecodes if a prim.
assembleCalla            Runtime: Check arity of top-of-stack fn & call it.
assembleCatch            Runtime: Push CATCHFRAME which will send any
                          throws to label i.
assembleConstant         Runtime: Load constant K on the stack.
assembleConstantSlot    Compiletime: Return offset i of new constant slot.
assembleLabel            Compiletime: Internally note location of label i.
assembleLabelGet        Compiletime: Returns 0 1 2 ... on successive calls.
assembleLineInFn       Compiletime: Sets asm$s.lineInFn.
assembleConstantGet     Runtime: Load contents of const slot i onto stack.
assembleTag              Runtime: Push a TAG stackframe .
assembleVariableGet     Runtime: Load contents of local var  i onto stack.
assembleVariableSet     Runtime: Set  contents of local var  i from stack.
assembleVariableSlot    Compiletime: Return offset i of new localvar slot.
? # f a finishAssembly   Compiletime: Return executable for fn.
@end example

Note: 'f' argument to @code{finishAssembly} is the function
being compiled.  '#' argument is the arity of the function,
if known from declaration, else -1. This is an integer interpreted
as a set of bitfields.  @xref{explodeArity}.  @xref{implodeArity}.
'?' is @code{nil} normally, non-@code{nil} to force
the assembler to accept the given arity without arguing.

For examples of using the Muq assembler, see the
Muq compilers, for example the mufInMuf compiler
in the library files:

@example
12-C-muf.t
13-C-muf-syntax.t
@end example


@c
@node assignment functions, block functions, assembler wrapup, Core Muf
@section assignment functions
@cindex Assignment functions
@cindex @code{delete:}
@cindex @code{-->constant}
@cindex @code{-->}
@cindex @code{->}
@cindex @code{]-->}
@cindex @code{]->}
@cindex @code{=>}
@cindex Global variables
@cindex Local variables
@findex @code{-->}
@findex @code{->}

@example
expr -->constant symbol
expr --> path
expr -> localvar
expr => symbol
[ values | ]--> path
[ values | ]-> localvar
delete: path
File: muf.c, jobbuild.c, job.t
Status: alpha
@end example

Muq @sc{muf} uses a different and variable reference syntax
from traditional muf or forth, one which I believe to be
more readable.

One important difference between Muq @sc{muf} and
traditional @sc{muf} or Forth is that Muq @sc{muf} has true
local variables with scope limited to the function within
which they are declared -- what C calls "automatic"
variables.

I believe lack of true local variables and consequent abuse
of the data stack via obscure sequences of operators like
@code{rot, swap, dup, over} contributed mightily to making
traditional @sc{muf} and Forth code less readable than it
should be.  I have worked hard to make Muq @sc{muf} local
variables efficient enough that programmers will not
hesitate to use them, and to give them a syntax that
promotes readability of the resulting code.

Local variables within a function are referenced simply by
mentioning their name, and are assigned values by using a
short right-arrow followed by their name:

@example
salary savings + -> new-salary
@end example

@noindent
I believe this exhibits better visual flow and less noise
than the traditional

@example
salary @@ savings @@ + new-salary !
@end example

@noindent
quite aside from the complete lack of local variables in
traditional @sc{muf} and Forth.

The Muq @sc{muf} @code{->} operator will automatically
create a local variable of the given name if none currently
exists within the function.  This again reduces the amount
of syntactic noise and busywork involved in using local
variables.  Such automatic declaration of variables at need
is accepted practice in value-typed application languages,
where no type need be specified for a variable, and where
the emphasis is on convenience of interactive hacking rather
than strong type-checking of large programs.



In Muq @sc{muf,} global variables (that is, symbols in the
currently open package) and properties on objects are set
using a similar syntax:

@example
value --> global            ( Store into a symbol. )
value --> .u["cynbe"].tmp.x ( Store into a property. )
value --> me.tmp.x           ( Same as above when done by cynbe. )
@end example

@noindent
Note that this arrow is longer than that used for local
variables.  This is a reflection of the fact that access to
symbols and properties is a slower and more dangerous
operation: Programmers, like most people, tend to follow the
path of least resistance, and we wish to encourage them to
use local variables in preference to symbols or object
properties, when given a choice.

@example
Stack:
makeIndex --> o
Stack:
1 --> o.a   2 --> o.b   3 --> o.c
Stack: 
o.a o.b o.c
Stack: 1 2 3
@end example

A convenient syntax for deleting properties is

@example
delete: .u["cynbe"].tmp.x
@end example

@noindent
which removes property @code{x} from object @code{.u["cynbe"].tmp}.

The @code{--} and @code{++} are short notations for
incrementing or decrementing a symbol or local variable.

@example
-- my-local-var      ( Subtract one from given local variable. )
++ *my-symbol*       ( Add one to value of given symbol. )
@end example

@noindent
These produce exactly the same code as

@example
my-local-var 1 -  -> my-local-var
*my-symbol*  1 + --> *my-symbol*
@end example

@noindent
The point is only to improve readability by providing a more
concise notation for a common operation.

The @code{-->constant} operator works exactly like the
@code{-->} except that it should only be applied to symbols,
and it marks the symbol as being a constant.  Declaring a
symbol to be a constant is a promise to the compiler that
you will never change its value.  More specifically:

@itemize @bullet
@item
The compiler will freely substitute the value of the
symbol for references to it.  This makes for faster
code.

@item
Any subsequent attempt to set any slot on the symbol will be
an error, and usually signaled as such.
@end itemize

As a deliberate exception, you may change a constant's value
using @code{-->constant}, but in such a case it is strictly
up to you to ensure that all affected code gets recompiled.
(This exception is motivated primarily by a wish to let
files be reloaded without producing error messages.)

The @code{=>} operator is a borrowing from Lisp: It binds a
value to the given symbol.  In CommonLisp nomenclature, this
binding has @emph{indefinite scope} and @emph{dynamic
extent}: This means roughly that the binding is visible in
all other functions, not just the current one, but ends when
the current function exits.  (More precisely, when the
current function, @code{@{@}}-scope or @code{if/else/fi}
clause is exited.)  Binding is handy when you want to change
a global value temporarily, but want it automatically
restored to the previous value when you are done.

Binding has some special quirks in the Muq context:

@itemize @bullet
@item
Bindings are visible only within the current job.
This can be an advantage or a disadvantage, depending on
the situation.
@item
You may bind a Muq symbol even if you don't
own it, and hence cannot set it.
@item
The Muq binding mechanism is not terribly efficient:
All existing bindings are searched in sequence each
time a symbol value is retrieved.  You should avoid
binding large numbers of symbols if efficiency is at
all an issue.
@end itemize

The @code{]->} operator is simply a shorthand for
@code{]shift ->}.  @xref{]shift}.

The @code{]-->} operator is simply a shorthand for
@code{]shift -->}.



@c
@node block functions, block functions overview, assignment functions, Core Muf
@section block functions
@cindex Block functions

@menu
* block functions overview::
* [ |::
* jobQueueContents[::
* jobQueues[::
* seq[::
* stack[::
* stringChars[::
* stringInts[::
* stringWords[::
* chopString[::
* |=::
* |charInt::
* |delete::
* |deleteNonchars::
* |doCBackslashes::
* |backslashesToHighbit::
* |downcase::
* |dup::
* |dupNth::
* dup[::
* |dup[::
* |extract[::
* |first::
* |for::
* |forPairs::
* |ged::
* |gep::
* |get::
* |intChar::
* |keys::
* |unsort::
* |keysKeysvals::
* |abcAbbc::
* |length::
* |pop::
* |popp::
* |popNth::
* ]popNth::
* |push::
* |pushNth::
* |reverse::
* |keysvalsReverse::
* |bracketPosition::
* |charPosition::
* |position::
* |rotate::
* |secureHash::
* |secureDigest::
* |secureDigestCheck::
* |signedDigest::
* |signedDigestCheck::
* |set::
* |setNth::
* |shift::
* |shiftp::
* |shiftpN::
* ]shift::
* |sort::
* |subblock[::
* ||swap::
* |keysvalsSort::
* |pairsSort::
* |tsort::
* |tsortMos::
* |uniq::
* |keysvalsUniq::
* |pairsUniq::
* |unshift::
* |upcase::
* |vals::
* ]glueStrings::
* ]join::
* ]makeNumber::
* |findSymbol?::
* |positionInStack?::
* ]makeSymbol::
* ]makeVector::
* ]makeEphemeralVector::
* ]keysvalsMake::
* ]pop::
* ]print::
* ]rootLogPrint::
* ]setLocalVars::
* |sum::
* ]words::
* ]|join::
* |enbyte::
* |debyte::
* |debyteMuqnetHeader::
@end menu

@c
@node  block functions overview, [ |, block functions, block functions
@subsection block functions overview
@cindex Block functions overview

A major syntactic difference between Lisp and Forth is that
Lisp explicitly indicates the lexical scope of every
operator via a pair of parentheses.  This results in a lot
of syntactic noise, but does make it easy to cope with
operators which take a variable number of arguments.

Forth, by contrast, almost never explicitly indicates the
lexical scope of an operator, and in consequence almost all
operators are forced to take a fixed number of arguments.
This reduces syntactic clutter enormously, but the inability
to deal with variable numbers of arguments can be almost
crippling at times.

The tinymuck @sc{muf} coding community has evolved a
workaround for this problem, which consists of passing a
block of values on the stack, with a count of the number of
values in the block sitting atop it.

Muq @sc{muf} systematizes this ad hoc practice by providing
a consistent syntax for such operators, and by providing a
general set of tools for manipulating such stack blocks.
The result is that the @sc{muf} programmer can frequently
operate very concisely on complete blocks of data without
writing explicit loops, with a gain in notational
conciseness vaguely similar to that achieved by APL, and
much more closely related to that achieved by unix shell
commands using pipes.  In honor of the latter, the Muq
@sc{muf} syntax is chosen to be somewhat suggestive of that
used by unix shells for constructing pipes, although the
underlying implementation mechanisms are very different.

The general syntactic @sc{muf} conventions for dealing with
stack blocks are:

@example
Names of functions depositing a block on the stack end with '['.
Names of functions which transform a block on the stack start with '|'.
Names of functions which pop a block off the stack start with ']'.
@end example

These conventions provide immediate, obvious warning to
anyone reading the @sc{muf} code that block operations are
taking place.  In addition, given these conventions, a few
simple syntactic code-writing rules make it easy to write
reasonable block code, and to spot questionable block code
at a glance:

@display
@cartouche
Every '[' should be folloed  by a matching ']'.
Every ']' should be preceded by a matching '['.
Every '|' should be between a '[' @dots{} ']' pair.
@end cartouche
@end display

Given appropriate functions, a variety of useful computations
become quite simple to do interactively in a coding style
reminiscient of unix filters.  For example

@example
.who vals[ "z*" |grep |length -> i ]pop i
@end example

@noindent
is a plausible command to count the number of people
currently logged in whose name starts with 'z'.  We
assume here that:

@display
@code{vals[} pushes all keys on a given object on the stack in a block.
@code{|grep} removes all keys not matching a regular expression from block.
@code{|length} counts the number of items in a block.
@code{]pop} removes a block from the stack.
@end display

(At present, all the above operators are implemented exept
@code{|grep}; implementation of regular expressions is still
at an early stage.)

@noindent
@sc{warning:} Stack blocks are currently implemented as
simply N args on the stack with an integer count atop, but
code should not be written to depend on this.  A future
version of Muq is likely to use a special top-of-block
indicator rather than just an integer.  Use the provided
functions to construct and manipulate blocks.

@c
@node  [ |, jobQueueContents[, block functions overview, block functions
@subsection [ @dots{} |
@findex [ @dots{} |

@example
[ @dots{} |
File: muf.c job.t
Status: alpha
@end example

This operator pair provides a convenient way of pushing a
block on the stack:

@example
Stack:
[ 1 '3' "a" 'hiMom! |
Stack: [ 1 '3' "a" 'hiMom! |
@end example

This operator pair is particularly handy in constructing a stack block
to pass to a function.  For example, "]print" is muf's equivalent to C
sprintf, and takes as arguments a block containing a format string
followed by any arguments to be formatted:

@example
Stack:
14 --> count   "rabbits" --> what
Stack:
[ "I have %d %s." count what | ]print
Stack: "I have 14 rabbits."
@end example

@c
@node  jobQueueContents[, jobQueues[, [ |, block functions
@subsection jobQueueContents[
@defun seq[ @{ jobQueue -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{jobQueueContents[} function pushes a
block containing the jobs currently in the given
job queue.

@end defun

@c
@node  jobQueues[, seq[, jobQueueContents[, block functions
@subsection jobQueues[
@defun seq[ @{ job -> [] sleep-millisecs @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{jobQueue[} function pushes a
block containing the jobqueues in which
the given job currently resides.  (Certain
uninteresting jobqueues are excluded.)

If the job is currently in the sleep queue,
@code{sleep-millisecs} will be the number of
milliseconds left to sleep;  otherwise it will
be @code{nil}.

@end defun

@c
@node  seq[, stack[, jobQueues[, block functions
@subsection seq[
@defun seq[ @{ -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{seq[} function pushes an ascending sequence of
integers on the stack:

@example
Stack:
5 seq[
Stack: [ 0 1 2 3 4 |
@end example

(The block contains values 0-4, and is of length 5.)
@end defun

@c
@node  stack[, stringChars[, seq[, block functions
@subsection stack[
@defun stack[ @{ n-args -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{stack[} operator converts the entire current
contents of the data stack into a block:

@example
Stack: 'a' 'b' 'c'
stack[
Stack: [ 'a' 'b' 'c' |
@end example
@end defun

@c
@node  stringChars[, stringInts[, stack[, block functions
@subsection stringChars[
@defun stringChars[ @{ stg -> [chars] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Converts a string into a block of chars:
 
@example
Stack:
"abc" stringInts[
Stack: [ 'a' 'b' 'c' |
@end example

@xref{stringInts[}.
@xref{vals[}.
@xref{|charInt}.
@xref{|intChar}.
@end defun

@c
@node  stringInts[, stringWords[, stringChars[, block functions
@subsection stringInts[
@defun stringInts[ @{ stg -> [ints] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Converts a string into a block of one int per char,
according to their @sc{ascii} encodings:

@example
Stack:
"abc" stringInts[
Stack: [ 97 98 99 |
@end example

@xref{stringChars[}.
@xref{vals[}.
@xref{|charInt}.
@xref{|intChar}.
@end defun

@c
@node  stringWords[, chopString[, stringInts[, block functions
@subsection stringWords[
@findex words[
@defun stringWords[ @{ stg -> [stgs] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Pushes a block containing the alphanumeric words in a given string:

@example
Stack:
"The goddess is alive, and magic is afoot" stringWords[
Stack: [ "The" "goddess" "is" "alive" "and" "magic" "is" "afoot" |
@end example
@xref{chopString[}.
@end defun

For conciseness, this operator is also available as @code{words[}.
@xref{chopString[}. @xref{substring}.

@c
@node  chopString[, |=, stringWords[, block functions
@subsection chopString[
@defun chopString[ @{ stg delim -> [stgs] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Both arguments are usually strings (although the
@code{delim} argument may instead be a character): All
instances of @code{delim} are removed from @code{stg},
and the resulting fragments returned in a block:

@example
Stack:
"ag::995:30:Alexander the Geek:/q/ag:msh" ":" chopString[
Stack: [ "ag" "" "995" "30" "Alexander the Geek" "/q/ag" "msh" |
"" |delete
Stack: [ "ag" "995" "30" "Alexander the Geek" "/q/ag" "msh" |
@end example
@end defun

A more frequent case is splitting on blanks:

@example
Stack:
"now is the time " " " chopString[ "" |delete
Stack: [ "now" "is" "the" "time" |
@end example

As a special case, a null delimiter string breaks the string
into one-character substrings:

@example
Stack:
"Alexandria" "" chopString[
Stack: [ "A" "l" "e" "x" "a" "n" "d" "r" "i" "a" |
|unsort
Stack: [ "a" "n" "x" "r" "i" "d" "e" "a" "A" "l" |
]join
Stack: "anxrideaAl"
stringDowncase stringMixedcase
Stack: "Anxrideaal"
@end example

@c
@node  |=, |charInt, chopString[, block functions
@subsection |=
@defun |= @{ [chars] string -> [chars] tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

A quick way of comparing a block of chars vs a
string for textual equality.

The block should contain chars or ints.  The
@code{|=} prim returns @code{nil} unless the
block is the same length as @code{string}, and
unless the low 8 bits of each char or int match the value
of the corresponding byte in the @code{string}.

@example
Stack:
[ 'a' 'b' 'c' 'd' 'e' | "abcde" |=
Stack: [ 'a' 'b' 'c' 'd' 'e' | t
@end example

@end defun

@c
@node  |charInt, |delete, |=, block functions
@subsection |charInt
@defun |charInt @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

All characters in the given block are converted to
integers.  Other values are left unchanged.

@example
Stack:
[ 'a' 'b' 'c' "d" :e |
Stack: [ 'a' 'b' 'c' "d" :e |
|charInt
Stack: [ 97 98 99 "d" :e |
@end example

@xref{|intChar}.
@end defun

@c
@node  |delete, |deleteNonchars, |charInt, block functions
@subsection |delete
@defun |delete @{ [] arg -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given @code{arg} and a block, @code{|delete} removes all
instances of @code{arg} from the block:

@example
Stack:
"ag::995:30:Alexander the Geek:/q/ag:msh" ":" chopString[
Stack: [ "ag" "" "995" "30" "Alexander the Geek" "/q/ag" "msh" |
"" |delete
Stack: [ "ag" "995" "30" "Alexander the Geek" "/q/ag" "msh" |
":" ]glueStrings
Stack: "ag:995:30:Alexander the Geek:/q/ag:msh"
@end example

@xref{|popNth}.
@end defun

@c
@node  |deleteNonchars, |doCBackslashes, |delete, block functions
@subsection |deleteNonchars
@defun |deleteNonchars @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|deleteNonchars} removes all
non-character values (those for which
@code{char?} is not true) from the
given block.

This is useful for stripping address information from
datagrams, and similar cases where a keyval header
is present in a block of characters.

@example
Stack:
[ :ip0 127 :ip1 0 :ip2 0 :ip3 1 'a' 'b' 'c' |S
Stack: [ :ip0 127 :ip1 0 :ip2 0 :ip3 1 'a' 'b' 'c' |
|deleteNonchars
Stack: [ 'a' 'b' 'c' 'd' |
@end example

@end defun

@c
@node  |doCBackslashes, |backslashesToHighbit, |deleteNonchars, block functions
@subsection |doCBackslashes
@defun |doCBackslashes @{ [chars] -> [chars] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|doCBackslashes} function is a simple
compiler convenience function which
implements the C backslash convention on a block
of characters -- sequences consisting of a backslash
character followed by another character are contracted
to the single corresponding character.

The current list of escapes recognized:

@example
'\0'
'\a'
'\b'
'\f'
'\n'
'\r'
'\t'
'\v'
@end example

(Other characters preceded by backslash simply
reduce to themselves.)

While this function is intended to be used on blocks of
characters, it is not an error to have non-character
values in the block.
@end defun


@c
@node  |backslashesToHighbit, |downcase, |doCBackslashes, block functions
@subsection |backslashesToHighbit
@defun |backslashesToHighbit @{ [chars] -> [ints] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|backslashesToHighbit}
function is a simple
compiler convenience function which converts
a block of chars to a block of ints with the
corresponding @sc{ascii} values, except that
(non-backslashed) backslashes have been
dropped, and a high (0x1000) bit set on the following
characters.

The result is a convenient representation
used by the Muq compilers to represent a
token while remembering which characters
were quoted.

If unwanted, the quote bits may be stripped out using
the @code{|intChar} function.

@end defun


@c
@node  |downcase, |dup, |backslashesToHighbit, block functions
@subsection |downcase
@defun |downcase do@{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|downcase} prim converts to lowercase any
character or integer values in the block.  (Integer
values > 255 are ignored.)

@example
Stack: [ 'A' 'b' 'C' |
|downcase
Stack: [ 'a' 'b' 'c' |
@end example

@xref{downcase}.
@xref{stringDowncase}.

@end defun

@c
@node  |dup, |dupNth, |downcase, block functions
@subsection |dup
@defun |dup do@{ [] -> [] arg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|dup} prim pushes on the
stack a copy of the top (last) element of the block,
which is left unchanged.

@example
Stack: [ 'a' 'b' 'c' |
|dup
Stack: [ 'a' 'b' 'c' | 'c'
@end example

@xref{|dupNth}.

@end defun

@c
@node  |dupNth, dup[, |dup, block functions
@subsection |dupNth
@defun |dupNth do@{ [] n -> [] arg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given @code{n} and a block, @code{|dupNth} pushes on the
stack a copy of the nth element in the block, which is left
unchanged.  The bottom (leftmost) element in the block is
element zero:

@example
Stack:
[ 'a' 'b' 'c' | 0 |dupNth
Stack: [ 'a' 'b' 'c' | 'a'
pop 2 |dupNth
Stack: [ 'a' 'b' 'c' | 'c'
@end example

@xref{|first}.
@xref{|setNth}.
@xref{|popNth}.
@xref{]popNth}.
@end defun

@c
@node  dup[, |dup[, |dupNth, block functions
@subsection dup[
@defun |dup[ do@{ ... num -> ... [] @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Create a block and put @emph{copies} of the top
@code{num} entries on the stack inside the block.

@example
Stack:
'a' 'b' 'c' 3 dup[
Stack: 'a' 'b' 'c' [ 'a' 'b' 'c' |
@end example

@end defun

@c
@node  |dup[, |extract[, dup[, block functions
@subsection |dup[
@defun |dup[ do@{ [] -> [] [] @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Push a duplicate of the given block on the stack.

@example
Stack:
[ 'a' 'b' 'c' |
Stack: [ 'a' 'b' 'c' |
|dup[
Stack: [ 'a' 'b' 'c' | [ 'a' 'b' 'c' | 
@end example

@end defun

@c
@node  |extract[, |first, |dup[, block functions
@subsection |extract[
@defun |extract[ @{ [] start stop -> [] [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|extract[} function extracts a subblock from a given
block:

@example
Stack:
[ 'a' 'b' 'c' 'd' 'e' | 1 2 |extract[
Stack: [ 'a' 'c' 'd' 'e' | [ 'b' |
@end example

@xref{|subblock[}.

@end defun



@c
@node  |first, |for, |extract[, block functions
@subsection |first
@defun |first do@{ [] -> [] arg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Returns first (leftmost/bottommost) element of stackblock.
Exactly equivalent to @code{0 |dupNth}.

@example
Stack: [ 'a' 'b' 'c' | 
|first
Stack: [ 'a' 'b' 'c' | 'a'
@end example

@xref{|dupNth}.
@end defun

@c
@node  |for, |forPairs, |first, block functions
@subsection |for v i do@{ @dots{} @}
@defun |for var i do@{ ... @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given a block of @sc{n} items, loops @sc{n} times,
with the designated variable set successively to
each item in the block.  Changing the variable will
change the corresponding element of the block:

@example
Stack:
5 seq[
Stack: [ 0 1 2 3 4 |
|for v do@{ v 2 * -> v @}
Stack: [ 0 2 4 6 8 |
@end example

The optional second argument will iterate through the block indices:

@example
Stack: [ 0 2 4 6 8 |
|for v i do@{ [ "blk[%d] is %d\n" i v | ]print , @}
blk[0] is 0
blk[1] is 2
blk[2] is 4
blk[3] is 6
blk[4] is 8
Stack: [ 0 2 4 6 8 |
@end example
@end defun

Note: The body of a @code{|for} should not change the size
of the block.

Note: The body of a @code{|for} may accumulate results on
top of the iterated block.  This is not generally
recommended, but occasionally very useful.  See the
implementations of @code{map*} in @file{10-C-lists.muf}.
Such accumulation is liable to confuse the arity-deduction
code: You will likely need to include a '!' in your arity
declaration for the function.



@c
@node  |forPairs, |ged, |for, block functions
@subsection |forPairs k v i do@{ @dots{} @}
@defun |forPairs k v i do@{ ... @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given a block of @sc{2n} items, loops @sc{n} times,
with the designated variables @code{k} and @code{v}
set successively to
each sequential pair of values in the block.  Changing the
@code{k} and @code{v} variables will
change the corresponding elements of the block:

@example
Stack:
6 seq[
Stack: [ 0 1 2 3 4 |
|forPairs k v do@{ v 2 * -> v @}
Stack: [ 0 2 2 6 4 10 |
@end example

The optional third argument will iterate through the block indices
used:

@example
Stack: [ 0 2 4 6 8 |
|forPairs k v i do@{ [ "blk[%d] is %d\n" i k | ]print , @}
blk[0] is 0
blk[2] is 4
blk[4] is 8
Stack: [ 0 2 4 6 8 |
@end example
@end defun

Note: The body of a @code{|forPairs} should not change the size
of the block.

Note: The body of a @code{|forPairs} may accumulate results on
top of the iterated block.  This is not generally
recommended, but occasionally very useful.  See the
implementations of @code{map*} in @file{10-C-lists.muf}.
Such accumulation is liable to confuse the arity-deduction
code: You will likely need to include a '!' in your arity
declaration for the function.



@c
@node  |ged, |gep, |forPairs, block functions
@subsection |ged
@defun |ged do@{ [] key deflt -> [] val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given @code{key} default value @code{deflt}, and a block
interpreted as keyval pairs, @code{|ged} (GEt with Default)
returns the value corresponding to @code{key} in the block,
if present, else @code{dflt}.

@example
[   :a 1   :b 2   :c 3   |
Stack: [ :a 1 :b 2 :c 3 |
:a 13 |ged
Stack: [ :a 1 :b 2 :c 3 | 1
pop :d 13 |ged
Stack: [ :a 1 :b 2 :c 3 | 13
@end example

This function is intended for functions which take a block
of keyword-labelled arguments, some of which may be optionally
omitted and which default to non-@code{nil} values:

@example
: fn @{ [] -> @}
   :key0 deflt0 |ged -> val0
   :key1 deflt1 |ged -> val1
   :key2 deflt2 |ged -> val2
   ...
   :keyN defltN |ged -> valN
   ]pop
   ( Stuff depending on val0..valN. )
;
@end example

Keywords are the recommended type of key, but any datatype
may be used.

This type of parameter passing is not suitable for simple,
efficiency-critical, commonly used functions, but is very
suitable for obscure functions which take many parameters,
some of little interest to many users, and especially if
you'd like to maintain the option to add more parameters in
future without breaking existing code.

@xref{|gep}.
@xref{|get}.
@xref{|set}.
@xref{|dupNth}.

@end defun

@c
@node  |gep, |get, |ged, block functions
@subsection |gep
@defun |gep do@{ [] key deflt -> [] val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@code{|gep} is exactly the same as @code{|ged} except that
the key/val pair matched, if any, is also popped from the
block, instead of being left there.

@example
[   :a 1   :b 2   :c 3   |
Stack: [ :a 1 :b 2 :c 3 |
:a 13 |get
Stack: [ :b 2 :c 3 | 1
pop :d 13 |ged
Stack: [ :a 1 :b 2 :c 3 | 13
@end example

@code{|gep} makes it easier to check for unused arguments: If the block
is not empty after extracting all expected arguments, an unsupported
argument is present.

@xref{|ged}.
@xref{|get}.
@xref{|set}.
@xref{|dupNth}.

@end defun

@c
@node  |get, |intChar, |gep, block functions
@subsection |get
@defun |get do@{ [] key -> [] val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given @code{key} and a block interpreted as keyval pairs,
@code{|get} returns the value corresponding to @code{key}
in the block, if present, else @code{nil}.

@example
[   :a 1   :b 2   :c 3   |
Stack: [ :a 1 :b 2 :c 3 |
:a |get
Stack: [ :a 1 :b 2 :c 3 | 1
@end example

Keywords are the recommended type of key, but any datatype
may be used.

@xref{|ged}.
@xref{|gep}.
@xref{|set}.
@xref{|position}.
@end defun

@c
@node  |intChar, |keys, |get, block functions
@subsection |intChar
@defun |intChar @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

All integers in the given block are converted to
characters.  Other values are left unchanged.

@example
Stack:
[ 97 98 99 "d" :e |
Stack: [ 97 98 99 "d" :e |
|intChar
Stack: [ 'a' 'b' 'c' "d" :e |
@end example

@xref{|charInt}.
@end defun

@c
@node  |keys, |unsort, |intChar, block functions
@subsection |keys
@defun |keys @{ [keysvals] -> [keys] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given a block of alternating key and value entries,
drop the values, leaving only the keys:

@example
Stack: [ "joe" 12 "ava" 13 "tom" 34 |
|keys
Stack: [ joe" "ava" "tom" |
@end example
@end defun

@c
@node  |unsort, |keysKeysvals, |keys, block functions
@subsection |unsort
@defun |unsort @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Shuffle a block randomly.  This is the opposite of @code{|sort}

@example
Stack: [ "H9" "H10" "HJ" "HQ" "HK" "HA" |
|unsort
Stack: [ "H10" "HA" "HQ" "H9" "HJ" "HK" |
@end example

This is implemented using the heapsort algorithm, but using
the random number generator to decide the result of each
comparison.
@end defun

@c
@node  |keysKeysvals, |abcAbbc, |unsort, block functions
@subsection |keysKeysvals
@defun |keysKeysvals @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Duplicate every entry in a block:

@example
Stack: [ 4 2 12 |
|keysKeysvals
Stack: [ 4 4 2 2 12 12 |
@end example

This function is part of a @sc{muf} idiom used to sort a
block of objects on an arbitrarily computed set of keys: One
doubles the block using @code{|keysKeysvals,} uses
@code{|for} to replace alternating block entries by the
desired sort keys, uses @code{|sort-keysvals} to do the
actual sort, then uses @code{|vals} to discard the keys,
leaving only the sorted values.
@end defun

@c
@node  |abcAbbc, |length, |keysKeysvals, block functions
@subsection |abcAbbc
@defun |abcAbbc @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Convert a block containing a sequence
of values into a block of pairs
expressing the original adjacency
information:

@example
Stack: [ 'a' 'b' 'c' 'd' 'e' 'f' |
|abcAbbc
Stack: [ 'a' 'b' 'b' 'c' 'c' 'd' 'd' 'e' 'e' 'f' |
@end example

This function is useful in topological sorting
contexts.

@end defun

@c
@node  |length, |pop, |abcAbbc, block functions
@subsection |length
@defun |length @{ [] -> [] int @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Count the number of entries in a block:

@example
Stack: [ 4 2 12 |
|length
Stack: [ 4 2 12 | 3
@end example

@end defun

@c
@node  |pop, |popp, |length, block functions
@subsection |pop
@defun |pop @{ [] -> [] any @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Remove one entry from a block, leaving it on the stack:

@example
Stack: [ 101 102 103 |
|pop
Stack: [ 101 102 | 103
@end example
@end defun

@c
@node  |popp, |popNth, |pop, block functions
@subsection |popp
@defun |popp @{ [a ... ] -> [ ... ] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Remove one entry from a block, discarding it.
This is equivalent to the @code{|pop pop} code
sequence:

@example
[ 'a' 'b' 'c' |
Stack: [ 'a' 'b' 'c' |
|popp
Stack: [ 'a' 'b' |
@end example

@xref{|pop}.
@xref{|shiftp}.
@end defun

@c
@node  |popNth, ]popNth, |popp, block functions
@subsection |popNth
@defun |popNth @{ [] n -> [] any @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Remove one entry from a block, leaving it on the stack.  The
bottom (leftmost) element in the block is element zero:

@example
[ 'a' 'b' 'c' |
Stack: [ 'a' 'b' 'c' |
0 |popNth
Stack: [ 'b' 'c' | 'a'
@end example

@xref{|pushNth}.
@xref{|dupNth}.
@xref{]popNth}.
@end defun

@c
@node  ]popNth, |push, |popNth, block functions
@subsection ]popNth
@defun ]popNth @{ [] n -> any @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Same as @code{|popNth} except the block is
dropped.

@example
[ 'a' 'b' 'c' |
Stack: [ 'a' 'b' 'c' |
0 ]popNth
Stack: 'a'
@end example
@end defun

@c
@node  |push, |pushNth, ]popNth, block functions
@subsection |push
@defun |push @{ [] any -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Add one entry to a block:

@example
Stack: [ 101 102 | 103
|push
Stack: [ 101 102 103 |
@end example
@end defun

@c
@node  |pushNth, |reverse, |push, block functions
@subsection |pushNth
@defun |pushNth @{ [] any i -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Insert one entry into a block.  The bottom (leftmost)
element in the block is element zero:

@example
[ 'b' 'c' 'd' |
Stack: [ 'b' 'c' 'd' |
'a' 0 |pushNth
Stack: [ 'a' 'b' 'c' 'd' |

@xref{|popNth}.
@end example
@end defun


@c
@node  |reverse, |keysvalsReverse, |pushNth, block functions
@subsection |reverse
@defun |reverse @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Reverse the contents of a block:

@example
Stack: [ 101 102 103 |
|reverse
Stack: [ 103 102 101 |
@end example
@end defun


@c
@node  |keysvalsReverse, |bracketPosition, |reverse, block functions
@subsection |keysvalsReverse
@defun |keysvalsReverse @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Reverse the contents of a block consisting of keyVal pairs:

@example
Stack: 
10 seq[ |keysKeysvals
Stack: [ 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 |
|keysvalsReverse
Stack: [ 9 9 8 8 7 7 6 6 5 5 4 4 3 3 2 2 1 1 0 0 |
@end example
@end defun


@c
@node  |bracketPosition, |charPosition, |keysvalsReverse, block functions
@subsection |bracketPosition
@defun |bracketPosition @{ [] left right -> [] i-or-nil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a specialized compiler-support function.)

The @code{left} and @code{right} values must be
characters;  They are interpreted as a matching
pair of brackets, just as () [] or @{@}.

Search the contents of the block for an integer
value corresponding to the first @code{right}
bracket not matched by a @code{left} bracket.  If
such a value is found, return the integer offset
of the block location in which it is found;
Otherwise, return @code{nil}.

Integer values in the block above 255 are ignored.
So are values between double quotes.

@end defun


@c
@node  |charPosition, |position, |bracketPosition, block functions
@subsection |charPosition
@defun |charPosition @{ [] string -> [] i-or-nil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a specialized compiler-support function.)

Search the contents of the block for an integer
value corresponding to one of the characters
in @code{string}.  If such a value is found, return the
integer offset of the first block location in which
it is found;  Otherwise, return @code{nil}.

Integer values in the block above 255 are ignored.
So are values between double quotes.

The block will normally be ascii integer codes such
as produced by @code{|backslashesToHighbit}, but
may also be a simple block of characters.

@end defun


@c
@node  |position, |rotate, |charPosition, block functions
@subsection |position
@defun |position @{ [] v -> [] i-or-nil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Search the contents of the block for the given value,
left to right.  If the value is found, return the
integer offset of the first block location in which
it is found;  Otherwise, return @code{nil}.

@example
Stack: 
[ 'z' 'q' 'z' 'd' |
Stack: [ 'z' 'q' 'z' 'd' |
'z' |position
Stack: [ 'z' 'q' 'z' 'd' | 0
pop 'd' |position
Stack: [ 'z' 'q' 'z' 'd' | 3
pop 'm' |position
Stack: [ 'z' 'q' 'z' 'd' | nil
@end example

@xref{|get}.
@end defun


@c
@node  |rotate, |secureHash, |position, block functions
@subsection |rotate
@defun |rotate @{ [] n -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Circulate the contents of a block by @code{n} slots:

@example
Stack: 
10 seq[
Stack: [ 0 1 2 3 4 5 6 7 8 9 |
1 |rotate
Stack: [ 1 2 3 4 5 6 7 8 9 0 |
@end example

@end defun


@c
@node  |secureHash, |secureDigest, |rotate, block functions
@subsection |secureHash
@defun |secureHash @{ [chars-or-ints] -> [checkbytes] arg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is based on the Secure Hash Function (@sc{sha}-1),
as specified by international standard @sc{fips pub 180-1}:  It
mixes the information in the given block together to produce a
twenty-byte signature, which then replaces the block:

@example
[ 'a' 'b' 'c' |
Stack: [ 'a' 'b' 'c' |
|secureHash
Stack: [ '\251' '\231' '>' '6' 'G' '\006' '\201' 'j' '\272' '>' '%' 'q' 'x' 'P' '\302' 'l' '\234' '\320' '\330' '\235' |
@end example

@xref{hash}.
@xref{|secureDigest}.
@xref{|secureDigestCheck}.
@xref{secureHash}.
@xref{secureHashBinary}.
@xref{secureHashFixnum}.

@end defun

@c
@node  |secureDigest, |secureDigestCheck, |secureHash, block functions
@subsection |secureDigest
@defun |secureDigest @{ [chars-or-ints] -> [same-plus-checkbytes] arg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is based on the Secure Hash Function (@sc{sha}-1),
as specified by international standard @sc{fips pub 180-1}:  It
mixes the information in the given block together to produce a
twenty-byte signature, which is then appended to the block:

@example
[ 'a' 'b' 'c' |
Stack: [ 'a' 'b' 'c' |
|secureHash
Stack: [ 'a' 'b' 'c' '\251' '\231' '>' '6' 'G' '\006' '\201' 'j' '\272' '>' '%' 'q' 'x' 'P' '\302' 'l' '\234' '\320' '\330' '\235' |
@end example

One use is to append the signature to the block before
transmitting it over an unreliable medium, and then to
verify it at the other end:  If any bytes have become
accidentally garbled, it is extremely unlikely the
signature will still match.

Another use is in authentication:  If Alice and Bob share
a secret string, and Alice sends Bob @code{ message +
secureHash( message + secret )}, Bob can verify (with
very high probability) that whoever sent the message
must have known the secret, hence is probably Alice.

@xref{hash}.
@xref{|signedDigest}.
@xref{|signedDigestCheck}.
@xref{|secureHash}.
@xref{|secureDigestCheck}.
@xref{secureHash}.
@xref{secureHashBinary}.
@xref{secureHashFixnum}.

@end defun

@c
@node  |secureDigestCheck, |signedDigest, |secureDigest, block functions
@subsection |secureHashCheck
@defun |secureDigest @{ [msg-plus-signature] -> [message-plus-badsig] arg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is complementary to @code{|secureDigest}:  It checks
whether the signature on the message is correct, then replaces
the signature with a flag value which is @code{nil} if the signature
was correct, else non-@code{nil}.

@example
[ 'a' 'b' 'c' |
Stack: [ 'a' 'b' 'c' |
|secureDigest
Stack: [ 'a' 'b' 'c' '\251' '\231' '>' '6' 'G' '\006' '\201' 'j' '\272' '>' '%' 'q' 'x' 'P' '\302' 'l' '\234' '\320' '\330' '\235' |
|secureDigestCheck
root: [ 'a' 'b' 'c' nil |
@end example

@xref{hash}.
@xref{|secureHash}.
@xref{|secureDigest}.
@xref{|signedDigest}.
@xref{|signedDigestCheck}.
@xref{secureHash}.
@xref{secureHashBinary}.
@xref{secureHashFixnum}.

@end defun

@c
@node  |signedDigest, |signedDigestCheck, |secureDigestCheck, block functions
@subsection |signedDigest
@defun |signedDigest @{ [chars-or-ints] secret -> [same-plus-checkbytes] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is based on the Secure Hash Function (@sc{sha}-1), as
specified by international standard @sc{fips pub 180-1}: It mixes the
secret plus the information in the given block together to produce a
twenty-byte signature, which is then appended to the block:

@example
[ 'a' 'b' 'c' |
Stack: [ 'a' 'b' 'c' |
sharedSecret |signedHash
Stack: [ 'a' 'b' 'c' '\251' '\231' '>' '6' 'G' '\006' '\201' 'j' '\272' '>' '%' 'q' 'x' 'P' '\302' 'l' '\234' '\320' '\330' '\235' |
@end example

Use @code{generateDiffieHellmanSharedSecret} to generate the
shared secret.

@xref{hash}.
@xref{|secureHash}.
@xref{|secureDigest}.
@xref{|secureDigestCheck}.
@xref{|signedDigestCheck}.
@xref{secureHash}.
@xref{secureHashBinary}.
@xref{secureHashFixnum}.

@end defun

@c
@node  |signedDigestCheck, |set, |signedDigest, block functions
@subsection |signedDigestCheck
@defun |signedDigestCheck @{ [msg-plus-signature] secret -> [message-plus-badsig] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is complementary to @code{|signedDigest}:  It checks
whether the signature on the message is correct, then replaces
the signature with a flag value which is @code{nil} if the signature
was correct, else non-@code{nil}.  The @code{secret} argument must
be a @code{#<DiffieHellmanSharedSecret>}.

@example
Stack:
dh:g dh:p generateDiffieHellmanKeyPair --> publicKey1 --> privateKey1
Stack:
dh:g dh:p generateDiffieHellmanKeyPair --> publicKey2 --> privateKey2
Stack:
publicKey1 privateKey2 dh:p generateDiffieHellmanSharedSecret --> sharedSecret1
Stack:
publicKey2 privateKey1 dh:p generateDiffieHellmanSharedSecret --> sharedSecret2
Stack:
[ 'a' 'b' 'c' | sharedSecret1
Stack: [ 'a' 'b' 'c' | #<DiffieHellmanSharedSecret>
|signedDigest ( Exact signature bytes will of course vary randomly: )
Stack: [ 'a' 'b' 'c' '\251' '\231' '>' '6' 'G' '\006' '\201' 'j' '\272' '>' '%' 'q' 'x' 'P' '\302' 'l' '\234' '\320' '\330' '\235' |
sharedSecret2 |signedDigestCheck
Stack: [ 'a' 'b' 'c' nil |
@end example

@xref{hash}.
@xref{|secureHash}.
@xref{|secureDigest}.
@xref{secureHash}.
@xref{secureHashBinary}.
@xref{secureHashFixnum}.

@end defun

@c
@node  |set, |setNth, |signedDigestCheck, block functions
@subsection |dup
@defun |dup do@{ [] -> [] arg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given @code{key}, @code{val}, and a block interpreted as keyval pairs,
@code{|set} sets the value corresponding to @code{key}
in the block, if present, otherwise pushes @code{key} and
@code{val} on the block as a new keyval pair.

@example
[   :a 1   :b 2   :c 3   |
Stack: [ :a 1 :b 2 :c 3 |
:b 0 |set
Stack: [ :a 1 :b 0 :c 3 |
:d 4 |set
Stack: [ :a 1 :b 0 :c 3 :d 4 |
@end example

Keywords are the recommended type of key, but any datatype
may be used.

@xref{|ged}.
@xref{|get}.

Given @code{arg} and a block, @code{|dup} pushes on the
stack a copy of the top (last) element of the block,
which is left unchanged.

@example
Stack: [ 'a' 'b' 'c' |
|dup
Stack: [ 'a' 'b' 'c' | 'c'
@end example

@end defun

@c
@node  |setNth, |shift, |set, block functions
@subsection |setNth
@defun |setNth @{ [] val i -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Overwrite one entry in a block.  The bottom (leftmost)
element in the block is element zero:

@example
Stack: 
[ 'a' 'B' 'c' 'd' |
Stack: [ 'a' 'B' 'c' 'd' |
'b' 1 |setNth
Stack: [ 'a' 'b' 'c' 'd' |
@end example
@end defun


@c
@node  |shift, |shiftp, |setNth, block functions
@subsection |shift
@defun |shift @{ [a ...] -> [...] a @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Remove first element from a block, leaving it on stack.

@example
Stack: 
[ 'a' 'b' 'c' 'd' |
Stack: [ 'a' 'b' 'c' 'd' |
|shift
Stack: [ 'b' 'c' 'd' | 'a' 
@end example

@xref{|shiftp}.
@xref{|unshift}.
@xref{]shift}.
@xref{|pop}.
@end defun


@c
@node  |shiftp, |shiftpN, |shift, block functions
@subsection |shiftp
@defun |shiftp @{ [a ...] -> [...] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Remove first element from a block, discarding it.
This is equivalent to the @code{|shift pop}
code sequence:

@example
Stack: 
[ 'a' 'b' 'c' 'd' |
Stack: [ 'a' 'b' 'c' 'd' |
|shiftp
Stack: [ 'b' 'c' 'd' |
@end example

@xref{|shift}.
@xref{|shiftpN}.
@end defun


@c
@node  |shiftpN, ]shift, |shiftp, block functions
@subsection |shiftp
@defun |shiftpN @{ [a b ... n o ... ] n -> [ o ... ] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Remove first @code{n} elements from a block, discarding them.
This is equivalent to @code{n} @code{|shiftp} operations.

@example
Stack: 
[ 'a' 'b' 'c' 'd' |
Stack: [ 'a' 'b' 'c' 'd' |
2 |shiftpN
Stack: [ 'c' 'd' |
@end example

@xref{|shift}.
@xref{|shiftp}.
@end defun


@c
@node  ]shift, |sort, |shiftpN, block functions
@subsection ]shift
@defun ]shift @{ [a ...] -> a @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Same as @code{0 ]popNth}:

@example
Stack: 
[ 'a' 'b' 'c' 'd' |
Stack: [ 'a' 'b' 'c' 'd' |
]shift
Stack: 'a' 
@end example

Similar functions
@code{]shift2}
@code{]shift3}
@code{]shift4}
@code{]shift5}
@code{]shift6}
@code{]shift7}
@code{]shift8}
@code{]shift9} return the indicated
number of scalars from the block.

(Note that a general @code{]shiftN} operator would
defeat the static arity analysis on which the
MUF compiler depends.)


@end defun


@c
@node  |sort, |subblock[, ]shift, block functions
@subsection |sort
@defun |sort @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Sort the entries in a block:

@example
Stack: 
20 seq[
Stack: [ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 |
|unsort
Stack: [ 4 3 15 13 11 12 18 19 10 17 9 7 2 6 1 16 8 5 14 0 |
|sort
Stack: [ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 |
@end example

This uses a HeapSort driven by the standard Muq comparison
function.  HeapSort is a simple, fast, stable O(n*log(n))
sort.  Its best-case performance isn't quite as good as
QuickSort's best-case performance, but HeapSort's worst-case
performance is the same as its best-case performance, while
QuickSort's worst-case performance is catastrophic.
@end defun


@c
@node  |subblock[, ||swap, |sort, block functions
@subsection |subblock[
@defun |subblock[ @{ [] start stop -> [] [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|subblock[} function extracts a subblock from a given
block:

@example
Stack:
[ 'a' 'b' 'c' 'd' 'e' | 1 2 |subblock[
Stack: [ 'a' 'b' 'c' 'd' 'e' | [ 'b' |
@end example

@xref{|extract[}.

@end defun



@c
@node  ||swap, |keysvalsSort, |subblock[, block functions
@subsection ||swap
@defun ||swap @{ [a] [b] -> [b] [a] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{||swap} function swaps two stackblocks on the stack:

@example
Stack:
[ 'a' 'b' 'c' | [ 0 1 2 | ||swap
Stack: [ 0 1 2 | [ 'a' 'b' 'c' |
@end example

@xref{swap}.
@end defun



@c
@node  |keysvalsSort, |pairsSort, ||swap, block functions
@subsection |keysvalsSort
@defun |keysvalsSort @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Sort the entries in a block of keyVal pairs on their keys:

@example
Stack: [ "joe" 12 "ava" 13 "tom" 34 |
|keysvalsSort
Stack: [ "ava" 13 "joe" 12 "tom" 34 |
@end example

@xref{|sort}.
@xref{|pairsSort}.

@end defun


@c
@node  |pairsSort, |tsort, |keysvalsSort, block functions
@subsection |pairsSort
@defun |pairsSort @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Sort the entries in a block of keyVal pairs, treating
each keyVal pair as a single two-element key.

@xref{|sort}.
@xref{|keysvalsSort}.
@xref{|pairsUniq}.
@end defun


@c
@node  |tsort, |tsortMos, |pairsSort, block functions
@subsection |tsort
@defun |tsort @{ [] -> [] tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Topological sort:  Resolve a partial ordering
into a total ordering.

The input is a block of pairs @code{s t} interpreted
as meaning that @code{s} must
precede @code{t} in the result.

The result block contains a total ordering of the
given value, consistent with the given partial
ordering constraints, if possible, below
a @code{t} result flag.

If the input block contains a constraint cycle,
then a consistent total ordering is not possible,
and a @code{nil} result flag is returned;  The
contents of the block are undefined.

The following example specifies that 'i' must
precede 'x', 'n' must precede 'i', and 'u' must
precede 'n'.  The computed solution is unique:

@example
Stack: [ 'i' 'x'   'n' 'i'   'u' 'n' |
|tsort
Stack: [ 'u' 'n' 'i' 'x' | t
@end example

@end defun


@c
@node  |tsortMos, |uniq, |tsort, block functions
@subsection |tsortMos
@defun |tsortMos @{ [] -> [] tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|tsortMos} prim is a specialization of the @code{|tsort}
prim: It sorts only instances of class @code{mosClass}, and it
uses an algorithm which breaks ties according to the requirements
of @emph{Common Lisp the Language 2nd Ed} section @strong{28.1.5.1}
(page 784), resulting in a uniquely determined ordering.

(The @code{|tsortMos} prim is provided as support for
implementation of @code{]defclass} and is unlikely to
be of any other use.)

@xref{|tsort}.

@end defun


@c
@node  |uniq, |keysvalsUniq, |tsortMos, block functions
@subsection |uniq
@cindex That that is is that that is not is not is that it it is
@cindex Punctuate this sentence
@defun |uniq @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Drop all adjacent repeated entries in a block:

@example
Stack: [ 0 0 14 2 14 2 |
|uniq
Stack: [ 0 14 2 14 2 |
@end example

This may not look terribly useful by itself, but it is
part of a standard idiom for counting the number of
distinct items in a block.  For example, from an old
"punctuate this sentence" puzzle:

@example
Stack: "that that is is that that is not is not is that it it is"
words[ |sort |uniq
Stack: [ "is" "it" "not" "that" |
|length -> count ]pop [ "It had %d distinct words" count | ]print
Stack: "It had 4 distinct words"
@end example

@xref{|keysvalsUniq}.
@xref{|pairsUniq}.
@xref{|sort}.
@end defun


@c
@node  |keysvalsUniq, |pairsUniq, |uniq, block functions
@subsection |keysvalsUniq
@defun |keysvalsUniq @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Drop all adjacent keyval pairs with the
same key in a block:

@example
Stack: [ 0 'a' 1 'b' 0 'c' 1 'd' |
|keysvalsSort
Stack: [ 0 'c' 0 'a' 1 'b' 1 'd' |
|pairsSort
Stack: [ 0 'a' 0 'c' 1 'b' 1 'd' |
|pairsUniq
Stack: [ 0 'a' 0 'c' 1 'b' 1 'd' |
|keysvalsUniq
Stack: [ 0 'a' 1 'b' |
@end example

@xref{|keysvalsSort}.
@xref{|pairsSort}.
@xref{|pairsUniq}.

@end defun


@c
@node  |pairsUniq, |unshift, |keysvalsUniq, block functions
@subsection |pairsUniq
@defun |pairsUniq @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Drop all adjacent repeated pairs in a block:

@example
Stack: [ 0 0 1 1 0 0 1 1 |
|pairsSort
Stack: [ 0 0 0 0 1 1 1 1 |
|pairsUniq
Stack: [ 0 0 1 1 |
@end example

@xref{|pairsSort}.

@end defun


@c
@node  |unshift, |upcase, |pairsUniq, block functions
@subsection |unshift
@defun |unshift @{ [...] a -> [a ...] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Insert a value as first element of a block:

@example
Stack: [ 1 2 3 | 0
|unshift
Stack: [ 0 1 2 3 |
@end example

@end defun


@c
@node  |upcase, |vals, |unshift, block functions
@subsection |upcase
@defun |upcase do@{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|upcase} prim converts to uppercase any
character or integer values in the block.  (Integer
values > 255 are ignored.)

@example
Stack: [ 'a' 'B' 'c' |
|dup
Stack: [ 'A' 'B' 'C' |
@end example

@xref{upcase}.
@xref{stringUpcase}.
@end defun

@c
@node  |vals, ]glueStrings, |upcase, block functions
@subsection |vals
@defun |vals @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Given a block of alternating key and value entries,
drop the keys, leaving only the values:

@example
Stack: [ "joe" 12 "ava" 13 "tom" 34 |
|vals
Stack: [ 12 13 34 |
@end example
@end defun


@c
@node  ]glueStrings, ]join, |vals, block functions
@subsection ]glueStrings
@defun ]glueStrings @{ [stgs] delim -> stg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]glueStrings} operator merges a block of strings
into a single string, separating the substrings by the
given delimiter:

@example
Stack:
"ag::995:30:Alexander the Geek:/q/ag:msh" ":" chopString[
Stack: [ "ag" "" "995" "30" "Alexander the Geek" "/q/ag" "msh" |
"" |delete
Stack: [ "ag" "995" "30" "Alexander the Geek" "/q/ag" "msh" |
":" ]glueStrings
Stack: "ag:995:30:Alexander the Geek:/q/ag:msh" 
@end example

@xref{]join}.
@xref{stringChars[}.
@xref{vals[}.
@xref{stringWords[}. @xref{chopString[}.

@end defun


@c
@node  ]join, ]makeNumber, ]glueStrings, block functions
@subsection ]join
@defun ]join @{ [stgs] -> stg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]join} operator merges a block of strings into a
single string, or alternately a block of integers, or
a block of characters, into a string:

@example
Stack: 
[ "The" " eye" " of" " the" " tiger." | ]join
Stack: "The eye of the tiger."
pop [ 101 102 103 | ]join
Stack: "efg"
@end example

@xref{]glueStrings}.
@xref{stringWords[}. @xref{chopString[}.
@xref{stringChars[}.
@xref{vals[}.
@end defun

@c
@node  ]makeNumber, |findSymbol?, ]join, block functions
@subsection ]makeNumber
@defun ]makeNumber @{ [token] -> typ val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]makeNumber} prim is a hardcoded
speed hack intended to be used by the Muq
compilers (for example, the Lisp
@code{read} function) to translate a number
token (see @code{|potentialNumber?})
into the corresponding number.  The @code{typ}
return value indicates the type of number,
being one of the integer constants
@example
lisp:lispBadnum
lisp:lispShortFloat
lisp:lispSingleFloat
lisp:lispDoubleFloat
lisp:lispExtendedFloat
lisp:lispFixnum
lisp:lispBignum
lisp:lispRatio
@end example

@end defun


@c
@node  |findSymbol?, |positionInStack?, ]makeNumber, block functions
@subsection |findSymbol?
@defun |findSymbol? @{ [token] default-pkg -> [token] found sym @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|findSymbol?} prim is a
compiler-support function which accepts a block
of integer-coded characters
such as returned by @code{lisp:|classifyLispToken} or
@code{|backslashesToHighbit} and returns the
corresponding symbol as @code{sym} if found, else
@code{nil}.  The @code{found} return value will be
@code{nil} unless the symbol was found.

The @code{|findSymbol?} prim distinguishes four
token types:

@table @code
@item :sss
A keyword symbol.  Looked up in the keyword
package, created if not found.

@item sss
A vanilla symbol.  Looked up first as a private
symbol in the current
package (@code{@@$s.package}), then as a public
(exported) symbol in all packages used by the
current package, finally in the default compiler
package @code{default-pkg} if it is a package.

@item ppp:sss
Looked up as a public symbol in package
@code{ppp}.

@item ppp::sss
Looked up as a private symbol in package
@code{ppp}, then as a public symbol in any
package used by @code{ppp}.

@end table


@xref{intern}.
@xref{makeSymbol}.
@xref{]makeSymbol}.
@end defun

@c
@node  |positionInStack?, ]makeSymbol, |findSymbol?, block functions
@subsection |positionInStack?
@defun |positionInStack? @{ [token] stack -> [token] found position @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|positionInStack?} prim is a
compiler-support function which accepts a block of
integer-coded characters such as returned by
@code{lisp:|classifyLispToken} or
@code{|backslashesToHighbit} and searches the
given @code{stack} for a matching string.

The usual use is to maintain a block-structured
local symbol table in the @code{stack}, with
alternating string keys and function/integer
values.

As usual, one motivation for expressing the
@code{[token]} argument as a block of ints
instead of as a string, is to minimize
generation of garbage strings by the Muq
compilers:  It is usually possible to
tokenize the compiler input and look up
the results in the symbol tables entirely
without garbage generation.

@xref{getKey?}.

@end defun

@c
@node  ]makeSymbol, ]makeVector, |positionInStack?, block functions
@subsection ]makeSymbol
@defun ]makeSymbol @{ [token] default-pkg -> symbol @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

The @code{]makeSymbol} prim is a hardcoded speed
hack intended to be used by the Muq compilers (for
example, the Lisp @code{read} function) to
translate a symbol token returned by
@code{|readLispChars} into the corresponding
symbol.

The @code{[token]} input should be a block of integers
such as returned by @code{lisp:|classifyLispToken} or
@code{|backslashesToHighbit}.

@xref{intern}.
@xref{makeSymbol}.
@xref{|findSymbol?}.
@end defun


@c
@node  ]makeVector, ]makeEphemeralVector, ]makeSymbol, block functions
@subsection ]makeVector
@findex ]vec
@defun ]makeVector @{ [any] -> vec @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]makeVector} function stores the contents of the
given block (which is then discarded) in a newly created
vector, which is returned on the stack:

@example
Stack: 
[ "The" " eye" " of" " the" " tiger." | ]makeVector --> v
Stack: 
v[0] v[1] v[2] v[3] v[4]
Stack: "The" " eye" " of" " the" " tiger."
@end example

For those of us addicted to conciseness, this function
is also available under the synonym @code{]vec}.

Similar functions
@code{]makeVectorI01}
@code{]makeVectorI08}
@code{]makeVectorI16}
@code{]makeVectorI32}
@code{]makeVectorF32}
@code{]makeVectorF64} are also available.

Note that a key distinction between @code{]makeVectorI08}
and the string primitives is that the latter return
values marked read-only, while @code{]makeVectorI08}
returns a value marked read-write.

@xref{makeVector}.
@xref{]makeEphemeralVector}.
@end defun


@c
@node  ]makeEphemeralVector, ]keysvalsMake, ]makeVector, block functions
@subsection ]makeEphemeralVector
@findex ]evec
@defun ]makeEphemeralVector @{ [any] -> evec @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]makeEphemeralVector} function is much like
the @code{]makeVector} function, except that it returns
an ephemeral (stack-allocated) vector instead of a
vanilla (heap-allocated) vector.

The only advantage of using an ephemeral vector is that
stack allocation is generally more efficient than
heap allocation, since the storage is automatically
released upon return from the function creating the
vector, without need to run the garbage collector.
This can be a significant advantage if you are
creating lots of vectors with very short lifetimes.

In all other cases, you should avoid using
ephemeral vectors, due to the potential problems
they introduce:

Ephemeral vectors are only useful within the job
that created them (that is, the job on whose
loop stack they reside).  Thus, storing an
ephemeral vector in the db, or passing it to
another job via a message stream, is almost
always a bad idea.  The other job will wind up
looking in its own loop stack for the ephemeral
vector, and either not find it or (worse) find
the wrong one.

Ephemeral vectors should normally be created at
the start of a function.  If you must create
one within a "with@dots{}do@{" type nested scope,
you should pop the vector off the stack at the
end of the construct using @code{popEphemeralVector}:
Otherwise, you'll get an error when the function
attempts to exit the scope and finds an unexpected
vector pushed on the loop stack.

For those of us addicted to conciseness, this function
is also available under the synonym @code{]evec}.

@xref{]makeVector}.
@xref{makeEphemeralVector}.
@xref{popEphemeralVector}.
@end defun


@c
@node  ]keysvalsMake, ]pop, ]makeEphemeralVector, block functions
@subsection ]keysvalsMake
@defun ]keysvalsMake @{ [keysvals] -> obj @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{]keysvalsMake} operator consumes a block of keyVal pairs,
creates an object, and enters the given properties onto
that object, which is then returned:

@example
Stack: 
[   "a" 1   "b" 2   "c" 3 | ]keysvalsMake --> o
Stack: 
o.a o.b o.c
Stack: 1 2 3
@end example

Note: This operator is not implemented in Muq version -1.0.0.
@end defun


@c
@node  ]pop, ]print, ]keysvalsMake, block functions
@subsection ]pop
@defun ]pop @{ [] -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]pop} operator discards the block on the stack:

@example
Stack: 
14 seq[ |unsort
Stack: [ 11 9 8 4 13 6 7 3 10 1 12 5 2 0 |
]pop
Stack: 
@end example
@end defun


@c
@node  ]print, ]rootLogPrint, ]pop, block functions
@subsection ]print
@defun ]print @{ [] -> stg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]print} operator is just C's @code{printf}
function in muf clothing:

@example
Stack: 
[ "%s: %x %d %8.4f %g" "Testing" 24 13 123.456 54.3e21 | ]print
Stack: "Testing: 18 13 123.4559 5.42999e+22"
@end example

All the usual C @code{printf} options are supported, since
Muq uses @code{printf} internally to implement this.

Yes, I should type all those pages of printf() documentation
here.  In the meantime, do "man printf" if you need the gory
formatting details @dots{}
@end defun


@c
@node  ]rootLogPrint, ]setLocalVars, ]print, block functions
@subsection ]rootLogPrint
@defun ]rootLogPrint @{ [] -> stg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]rootLogPrint} operator is just like @code{]print} except that
the caller must be root and the result is written to the logfile if any
(@code{--logfile} on commandline) instead of being returned as a string.

There is also a @code{muf:]logPrint} function intended to be called by
non-root users:  If @code{.muq%s.allowUserLogging} is non-@code{nil}, this
will also write to the logfile.  Otherwise, it silently does nothing.

@xref{rootLogString}.
@end defun


@c
@node  ]setLocalVars, |sum, ]rootLogPrint, block functions
@subsection ]setLocalVars
@defun ]setLocalVars @{ [] -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]setLocalVars} copies the @code{N} values in the
given argblock to the first @code{N} local variables of
the current function.  An error is signalled if there are
not enough local variables.

This prim is typically used in conjunction with
@code{|applyLambdaList} to process a function's
parameter block and then copy the results to
local variables.

@xref{|applyLambdaList}.

@end defun

@c
@node  |sum, ]words, ]setLocalVars, block functions
@subsection |]sum
@defun |sum @{ [numbers] -> [numbers] sum @}
@display
@exdent file: 100-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{|sum} operator takes a block of numbers and adds
them all together, returning the result.

@example
Stack: 
[ 1.1 1.2 1.3 | |sum
Stack: [ 1.1 1.2 1.3 | 3.6
@end example
@end defun


@c
@node  ]words, ]|join, |sum, block functions
@subsection ]words
@defun ]words @{ [stgs] -> stg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]words} operator takes a block of words and joins
them into a string.  The difference between this and what
@code{]join} does is that @code{]words} inserts blanks
between the words:

@example
Stack: 
[ "My" "little" "chickadee" | ]words
Stack: "My little chickadee"
pop [ "My" "little" "chickadee" | ]join
Stack: "Mylittlechickadee"
@end example

@xref{stringWords[}. @xref{chopString[}.
@xref{]join}.
@end defun


@c
@node  ]|join, |enbyte, ]words, block functions
@subsection ]|join
@defun ]|join @{ [] [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]|join} function merely merges two
stack blocks into one:

@example
Stack: 
4 seq[ 4 seq[
Stack: [ 0 1 2 3 | [ 0 1 2 3 4 |
]|join
Stack: [ 0 1 2 3 0 1 2 3 |
|sort
Stack: [ 0 0 1 1 2 2 3 3 |
|uniq
Stack: [ 0 1 2 3 |
@end example
@end defun


@c
@node  |enbyte, |debyte, ]|join, block functions
@subsection |enbyte
@defun |enbyte @{ [block] -> [bytes] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|enbyte} function converts a block from native
in-db format to a pure-byte format suitable for network
transmission to another server.

Currently, this means that immediate values (meaning mainly
floats, ints and chars) and strings
of length 111 or less are passed by value, and other
values are passed as proxies.

@xref{|debyte}.
@xref{ints3ToDbref}.

@end defun


@c
@node  |debyte, |debyteMuqnetHeader, |enbyte, block functions
@subsection |debyte
@defun |debyte @{ [enbytten] -> [debytten] failed @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|debyte} function is a rough inverse to the @code{|enbyte}
function, converting a portable pure-bytes block produced by
@code{|enbyte} into native form.

If @code{failed} is @code{nil}, the conversion succeeded.

If @code{failed} is a fixnum (@code{fixnum?}, the conversion failed and
@code{failed} is a hashName not listed in @code{.usersBy.hashName}:
Caller should discard the stackblock and request full information
corresponding to that hashName from the source of the stackblock,
probably via @code{muq/pkg/190-C-muqnet:sendGetUserInfo}.

If @code{failed} is a string (@code{string?}, the conversion failed for
some other reason and @code{failed} is an error message explaining why.

@xref{|enbyte}.
@xref{dbrefToInts3}.
@xref{|debyteMuqnetHeader}.

@end defun


@c
@node  |debyteMuqnetHeader, boolean functions, |debyte, block functions
@subsection |debyteMuqnetHeader
@defun |debyteMuqnetHeader @{ [enbytten] -> [unchanged] failed from to fromLongname op @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|debyteMuqnetHeader} function is a little bit of dedicated
support for the @code{muqnet:run} daemon: It extracts and converts the
standard muqnet packet header fields without disturbing the packet.

@xref{|debyte}.

@end defun


@c
@node boolean functions, and, |debyteMuqnetHeader, Core Muf
@section boolean functions

Boolean functions accept arguments interpreted as true/false
values, and return true/false results.  Muq muf supports the
usual three, @code{and,} @code{or,} and @code{not.}

@menu
* and::
* or::
* not::
* null?::
@end menu

@c
@node  and, or, boolean functions, boolean functions
@subsection and

@defun and @{ bool bool -> bool @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Returns @code{nil} if either input was @code{nil}, otherwise returns @code{t}.
@end defun

@c
@node  or, not, and, boolean functions
@subsection or

@defun or @{ bool bool -> bool @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Returns @code{nil} if both inputs were @code{nil}, otherwise returns @code{t}.
@end defun

@c
@node  not, null?, or, boolean functions
@subsection not

@defun not @{ bool -> bool @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Returns @code{t} if input was @code{nil}, otherwise returns @code{nil}.
@end defun

@c
@node  null?, browsing functions, not, boolean functions
@subsection null?

@defun null? @{ bool -> bool @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Returns @code{t} if input was @code{nil}, otherwise returns @code{nil}.

This is computationally identical to @code{not}, but used in
list rather than logic contexts.

@xref{end?}.
@end defun


@c
@node browsing functions, ls lsh lss lsm lsw, null?, Core Muf
@section browsing functions
@cindex Browsing functions

These functions facilitate interactive inspection and
modification of the database.

@menu
* ls lsh lss lsm lsw::
* pf ps pv pxf pxs pxv::
* ph::
* pr::
* pj rootPj::
@end menu

@c
@node  ls lsh lss lsm lsw, pf ps pv pxf pxs pxv, browsing functions, browsing functions
@subsection ls lsh lss lsm lsw
@findex lsh
@findex lss
@findex lsm
@findex lsw

@defun ls  @{ obj -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This summarizes all the public keyval pairs on the given
object to the current job's standard output.

The @code{lsh, lss, lsm} and @code{lsw} are exactly the same
except for listing (respectively) the hidden, system
and admins keyval pairs on the object.
@end defun


@c
@node  pf ps pv pxf pxs pxv, ph, ls lsh lss lsm lsw, browsing functions
@subsection pf ps pv pxf pxs plv

@defun pf  @{ -> @}
@findex printFunctions
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{pf} (printFunctions) function lists the names of all functions
in the current package.
@end defun

@defun ps  @{ -> @}
@findex printSymbols
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{ps} (printSymbols) function lists the names of all symbols
in the current package.
@end defun

@defun pv  @{ -> @}
@findex printVariables
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{pv} (printVariables) function lists the names and values of
all variables (symbols with non-@code{nil} values) in the current package.
@end defun

@defun pxf  @{ -> @}
@findex printExportedFunctions
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{pxf} (printExportedFunctions) function lists the names of all
functions exported from the current package.
@end defun

@defun pxs  @{ -> @}
@findex printExportedSymbols
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{pxs} (printExportedSymbols) function lists the names of all
symbols exported from the current package.
@end defun

@defun pxv  @{ -> @}
@findex printExportedVariables
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{pxv} (printExportedVariables) function lists the names and
values of all variables (symbols with non-@code{nil} values) exported
from the current package.
@end defun

@c
@node  ph, pr, pf ps pv pxf pxs pxv, browsing functions
@subsection ph

@defun ph  @{ -> @}
@findex printHandlers
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{ph} (printHandlers) function lists all live handlers for the
current job.

This function is currently implemented as

@example
: printHandlers

    ( Over all available handlers: )
    [ |
        |getAllActiveHandlers[
            -> k
            -> hi
            -> lo
            for i from lo below hi do@{
                i     dupBth -> eventN
                i k + dupBth -> handlerN

                eventN , "\t" , handlerN , "\n" ,
            @}
        ]pop
    ]pop
;
@end example

@end defun

@defun rootPj  @{ -> @}
@findex rootPrintJobs
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{rootPj} (rootPrintJobs) function is much like @code{pj}, but
lists all live jobs in the system instead of just those belonging
to a given user, and lists the owner of each job.

@end defun




@c
@node  pr, pj rootPj, ph, browsing functions
@subsection pr

@defun pr  @{ -> @}
@findex printRestarts
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{pr} (printRestarts) function lists all live restarts for the
current job.

This function is currently implemented as

@example
: printRestarts

    ( Over all available restarts: )
    0 -> i
    do@{
        ( Fetch next restart: )
        i getNthRestart
        -> name
        -> fn
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id

        ( Done if no restart found: )
        id not if return fi

        ( Summarize restart: )
        name , "\t" , rFn , "\n" ,

        ( Next restart to try: )
        i 1 + -> i
    @}
;
@end example

@end defun

@defun rootPj  @{ -> @}
@findex rootPrintJobs
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{rootPj} (rootPrintJobs) function is much like @code{pj}, but
lists all live jobs in the system instead of just those belonging
to a given user, and lists the owner of each job.

@end defun




@c
@node  pj rootPj, comparison functions, pr, browsing functions
@subsection pj rootPj

@defun pj  @{ -> @}
@findex printJobs
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{pj} (printJobs) function lists all live jobs for the
current user -- those in user$s.psQueue.  (Jobs are entered into
this queue when created, and removed when killed by an operator
such as @code{endJob}.)

@end defun

@defun rootPj  @{ -> @}
@findex rootPrintJobs
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: tentative
@end display

The @code{rootPj} (rootPrintJobs) function is much like @code{pj}, but
lists all live jobs in the system instead of just those belonging
to a given user, and lists the owner of each job.

@end defun




@c
@node comparison functions, !=, pj rootPj, Core Muf
@section comparison functions

The @code{!=} @code{<} @code{<=} @code{=} and
@code{>=} functions are the vanilla Muq comparison
functions, which compare numbers and strings by
value and other things by address.

The @code{!=-ci} @code{<-ci} @code{<=-ci}
@code{=-ci} and @code{>=-ci} functions differ only
in that they ignore case differences when
comparing strings: "abc" and "ABC" are equal to
@code{=-ci}.

The @code{eq} @code{eql} and @code{equal}
functions are for CommonLisp compatability.

@menu
* !=::
* <::
* <=::
* =::
* >::
* >=::
* !=-ci::
* <-ci::
* <=-ci::
* =-ci::
* >-ci::
* >=-ci::
* eq::
* eql::
* equal::
@end menu

@c
@node  !=, <, comparison functions, comparison functions
@subsection !=
@defun != @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function compares two arguments in the
Muq-natural way: Constants are compared by value,
objects which can change over time are compared by
address.  (This ensures that comparing a given
pair of objects always returns the same result.)
@end defun

@c
@node  <, <=, !=, comparison functions
@subsection <
@defun < @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function compares two arguments in the
Muq-natural way: Constants are compared by value,
objects which can change over time are compared by
address.  (This ensures that comparing a given
pair of objects always returns the same result.)
@end defun

@c
@node  <=, =, <, comparison functions
@subsection <=
@defun <= @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function compares two arguments in the
Muq-natural way: Constants are compared by value,
objects which can change over time are compared by
address.  (This ensures that comparing a given
pair of objects always returns the same result.)
@end defun

@c
@node  =, >, <=, comparison functions
@subsection =
@defun = @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function compares two arguments in the
Muq-natural way: Constants are compared by value,
objects which can change over time are compared by
address.  (This ensures that comparing a given
pair of objects always returns the same result.)
@end defun

@c
@node  >, >=, =, comparison functions
@subsection >
@defun > @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function compares two arguments in the
Muq-natural way: Constants are compared by value,
objects which can change over time are compared by
address.  (This ensures that comparing a given
pair of objects always returns the same result.)
@end defun

@c
@node  >=, !=-ci, >, comparison functions
@subsection >=
@defun >= @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function compares two arguments in the
Muq-natural way: Constants are compared by value,
objects which can change over time are compared by
address.  (This ensures that comparing a given
pair of objects always returns the same result.)
@end defun

@c
@node  !=-ci, <-ci, >=, comparison functions
@subsection !=-ci
@defun !=-ci @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function ignores case when comparing
strings, and is otherwise identical to @code{!=}.
@xref{!=}.
@end defun

@c
@node  <-ci, <=-ci, !=-ci, comparison functions
@subsection <-ci
@defun <-ci @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function ignores case when comparing
strings, and is otherwise identical to @code{<}.
@xref{<}.
@end defun

@c
@node  <=-ci, =-ci, <-ci, comparison functions
@subsection <=-ci
@defun <=-ci @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function ignores case when comparing
strings, and is otherwise identical to @code{<=}.
@xref{<=}.
@end defun

@c
@node  =-ci, >-ci, <=-ci, comparison functions
@subsection =-ci
@defun =-ci @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function ignores case when comparing
strings, and is otherwise identical to @code{=}.
@xref{=}.
@end defun

@c
@node  >-ci, >=-ci, =-ci, comparison functions
@subsection >-ci
@defun >-ci @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function ignores case when comparing
strings, and is otherwise identical to @code{>}.
@xref{>}.
@end defun

@c
@node  >=-ci, eq, >-ci, comparison functions
@subsection >=-ci
@defun >=-ci @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

This function ignores case when comparing
strings, and is otherwise identical to @code{>=}.
@xref{>=}.
@end defun


@c
@node  eq, eql, >=-ci, comparison functions
@subsection eq
@defun eq @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

The @code{eq} operator is a weird speed hack which
is best avoided unless you are very sure you know
what you are doing.  It simply compares the two
given arguments as machine words, and hence its
results depend on implementation details of the
various datatypes.  In the current (-1.5.0) Muq
implemention, @code{eq} will distinguish floats,
ints and characters correctly, and strings of
three characters or less, and beyond this will
distinguish objects which have different
addresses.
@end defun

@c
@node  eql, equal, eq, comparison functions
@subsection eql
@defun eql @{ any any -> tOrNil @}
@display
@exdent file: jobbuild.c
@exdent package: muf
@exdent status: alpha
@end display

The @code{eql} operator is defined by CommonLisp
to be essentially an @code{eq} which also works
correctly for all numbers.  At present, this is
implemented identically to @code{=}. @xref{=}.
@end defun

@c
@node  equal, compiler support functions, eql, comparison functions
@subsection equal
@defun equal @{ any any -> tOrNil @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{equal} operator is defined by CommonLisp
to be essentially an @code{eql} which also compares
lists by value.

@example
Stack:
[ 'a' 'b' ]l [ 'a' 'b' ]l =
Stack: nil
pop [ 'a' 'b' ]l [ 'a' 'b' ]l equal
Stack: t
@end example
@end defun

@c
@node compiler support functions, popCatchframe, equal, Core Muf
@section compiler support functions
@cindex Compiler support functions

The following functions are usually of interest only to people
writing new in-db compilers for Muq.

@menu
* popCatchframe::
* popEphemeralVector::
* popLockframe::
* popTagframe::
* popTagtopframe::
* pushLockframe::
* pushLockframeChild::
* pushTagtopframe::
* pushTagframe::
* pushUserMeFrame::
* rootPushUserFrame::
* rootPushPrivsOmnipotentFrame::
* popUserFrame::
* popPrivsFrame::
* popUnwindframe::
* readNextMufToken::
* addMufSource::
* continueMufCompile::
* startMufCompile::
* setMufLineNumber::
* mufShell::
* compileMufFile::
* parameter::
* |potentialNumber?::
* |unreadTokenChar::
* |readTokenChar::
* |readTokenChars::
* |scanTokenToChar::
* |scanTokenToChars::
* |scanTokenToCharPair::
* |scanTokenToWhitespace::
* |scanTokenToNonwhitespace::
@end menu

@c
@node  popCatchframe, popEphemeralVector, compiler support functions, compiler support functions
@subsection popCatchframe

@defun popCatchframe @{ -> [] flag @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator pops a @sc{catch} frame off the loop stack;
It is used to mark the end of a @code{catch@{ @dots{} @} }
clause.

In a strict sense, the return value is always @code{nil}
atop an empty block.  But if an error is encountered,
it will push a block of diagnostic information and then
a @code{t} value and then resume execution after the
@code{popCatchframe} instruction, so as a practical
matter the instruction may be thought of as returning
either @code{nil} or @sc{t} depending whether an error
was detected, atop a block which contains diagnostic
information if one was.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.
@end defun


@c
@node  popEphemeralVector, popLockframe, popCatchframe, compiler support functions
@subsection popEphemeralVector

@defun popEphemeralVector @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator pops a @sc{ephemeral_vector} frame off the loop stack;
It is used when an ephemeral vector must be allocated
within a "with@dots{}do@{" style nested scope, to clear
the ephemeral vector off the loop stack and thus
avoid confusing the endOfScope function.

@xref{makeEphemeralVector}.
@xref{]makeEphemeralVector}.
@end defun


@c
@node  popLockframe, popTagframe, popEphemeralVector, compiler support functions
@subsection popLockframe

@defun popLockframe @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator pops a @sc{lock} frame off the loop stack;
It is used to mark the end of a @code{withLockDo@{ @dots{} @} }
clause.

@xref{pushLockframe,,,muqimp.t,Muq Source Code}.

@xref{JOB_STACKFRAME_LOCK,,,muqimp.t,Muq Source Code}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

@xref{reset}.
@end defun


@c
@node  popTagframe, popTagtopframe, popLockframe, compiler support functions
@subsection popTagframe

@defun popTagframe @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator pops a @sc{tag} frame off the loop stack;
It is used to mark the end of a @code{withTags @dots{} do@{ @dots{} @} }
clause.

See @code{assembleTag} in @ref{assembler functions}.

@end defun


@c
@node  popTagtopframe, pushLockframe, popTagframe, compiler support functions
@subsection popTagtopframe

@defun popTagtopframe @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator pops a @sc{tagtop} frame off the loop stack;
It is used to mark the end of a @code{withTags @dots{} do@{ @dots{} @} }
clause.

@xref{pushTagtopframe}.

@end defun


@c
@node  pushLockframe, pushLockframeChild, popTagtopframe, compiler support functions
@subsection pushLockframe

@defun pushLockframe @{ lock -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator blocks the job until the specified lock can be
acquired, then pops it off the data stack and pushes a
@sc{lock} frame containing it onto the the loop stack; It is
used to mark the start of a @code{withLockDo@{ @dots{} @} }
clause.

Bug: Deadlock is not yet detected.  Complain if this is a
problem @dots{}

@xref{pushLockframeChild}.

@xref{popLockframe,,,muqimp.t,Muq Source Code}.

@xref{JOB_STACKFRAME_LOCK,,,muqimp.t,Muq Source Code}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

@xref{reset}.
@end defun


@c
@node  pushLockframeChild, pushTagtopframe, pushLockframe, compiler support functions
@subsection pushLockframeChild

@defun pushLockframeChild @{ lock -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator blocks the job until the specified lock can be
acquired, then pops it off the data stack and pushes a
@sc{lock-child} frame containing it onto the the loop stack; It is
used to mark the start of a @code{withChildLockDo@{ @dots{} @} }
clause.

Bug: Deadlock is not yet detected.  Complain if this is a
problem @dots{}

@xref{pushLockframe}.

@xref{popLockframe,,,muqimp.t,Muq Source Code}.

@xref{JOB_STACKFRAME_LOCK_CHILD,,,muqimp.t,Muq Source Code}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

@xref{reset}.
@end defun


@c
@node  pushTagtopframe, pushTagframe, pushLockframeChild, compiler support functions
@subsection pushTagtopframe

@defun pushTagtopframe @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator pushes a @sc{tagtop} stackframe.

@xref{popTagtopframe}.
@xref{pushTagframe}.

@end defun


@c
@node  pushTagframe, pushUserMeFrame, pushTagtopframe, compiler support functions
@subsection pushTagframe

@defun pushTagframe @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator pushes a @sc{tag} stackframe.

You should always push a @sc{tagtop} stackframe
immediately after pushing one or more @sc{tag}
stackframes.

@xref{pushTagtopframe}.

@end defun


@c
@node  pushUserMeFrame, rootPushUserFrame, pushTagframe, compiler support functions
@subsection pushUserMeFrame

@defun pushUserMeFrame @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator saves @code{@@$s.actingUser} on the loop stack in a
@code{USER} frame, then sets @code{@@$s.actingUser} to the owner
of the currently executing function.  This is analogous to doing
@code{set-uid} on unix, and is intended to be the usual way for
one user to grant privileges to another.

Use @code{popUserFrame} to undo the effect: @xref{popUserFrame}.

@xref{JOB_STACKFRAME_USER,,,muqimp.t,Muq Source Code}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

@end defun


@c
@node  rootPushUserFrame, rootPushPrivsOmnipotentFrame, pushUserMeFrame, compiler support functions
@subsection rootPushUserFrame

@defun rootPushUserFrame @{ user -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if @code{@@$s.actingUser} is not of Class
Root. (In the usual Muq configuration, the only instance of Class Root
is @code{.u["root"]}.)

This operator saves @code{@@$s.actingUser} on the loop stack in a
@code{USER} frame, then sets @code{@@$s.actingUser} to the
specified user.  This is intended to be the primary mechanism
by which administrators may override protection of user objects.

Use @code{popUserFrame} to undo the effect: @xref{popUserFrame}.

@xref{JOB_STACKFRAME_USER,,,muqimp.t,Muq Source Code}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

@end defun


@c
@node  rootPushPrivsOmnipotentFrame, popUserFrame, rootPushUserFrame, compiler support functions
@subsection rootPushPrivsOmnipotentFrame

@defun rootPushPrivsOmnipotentFrame @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if @code{@@$s.actingUser} is not of Class
Root. (In the usual Muq configuration, the only instance of Class Root
is @code{.u["root"]}.)

This operator saves @code{jS.j.privs}, the internal job-privilege
bitmask, on the loop stack in a @code{PRIVS} frame, then sets the
@sc{omnipotent} bit in @code{jS.j.privs}, which effectively disables
almost all security checking for the job.  Obviously, this should be
used with extreme caution.  Where-ever practical, it is best to use
@code{rootPushUserFrame} instead: @xref{rootPushUserFrame}.

Use @code{popPrivsFrame} to undo the effect: @xref{popPrivsFrame}.

@xref{JOB_STACKFRAME_PRIVS,,,muqimp.t,Muq Source Code}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

@end defun


@c
@node  popUserFrame, popPrivsFrame, rootPushPrivsOmnipotentFrame, compiler support functions
@subsection pushLockframe

@defun pushLockframe @{ lock -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator blocks the job until the specified lock can be
acquired, then pops it off the data stack and pushes a
@sc{lock} frame containing it onto the the loop stack; It is
used to mark the start of a @code{withLockDo@{ @dots{} @} }
clause.

Bug: Deadlock is not yet detected.  Complain if this is a
problem @dots{}

@xref{popLockframe,,,muqimp.t,Muq Source Code}.

@xref{JOB_STACKFRAME_LOCK,,,muqimp.t,Muq Source Code}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

@xref{reset}.
@end defun


@c
@node  popPrivsFrame, popUnwindframe, popUserFrame, compiler support functions
@subsection pushLockframe

@defun pushLockframe @{ lock -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator blocks the job until the specified lock can be
acquired, then pops it off the data stack and pushes a
@sc{lock} frame containing it onto the the loop stack; It is
used to mark the start of a @code{withLockDo@{ @dots{} @} }
clause.

Bug: Deadlock is not yet detected.  Complain if this is a
problem @dots{}

@xref{popLockframe,,,muqimp.t,Muq Source Code}.

@xref{JOB_STACKFRAME_LOCK,,,muqimp.t,Muq Source Code}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

@xref{reset}.
@end defun


@c
@node  popUnwindframe, readNextMufToken, popPrivsFrame, compiler support functions
@subsection popUnwindframe

@defun popUnwindframe @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This operator pops a @sc{vanilla} or other frame off the loop stack;
It is used to mark the end of the second
clause of an @code{after@{ @dots{} @}alwaysDo@{ @dots{} @} }
construct.  The full description of everything this operator
can do is quite involved;  all the Muq in-db compiler writer
normally needs to know is that is ends such a clause.

@xref{assembler functions}.

@xref{Loop Stacks,,,muqimp.t,Muq Source Code}.

For full gory details, read the source: c/job.t:job_Pop_Unwindframe().
@end defun


@c
@node  readNextMufToken, addMufSource, popUnwindframe, compiler support functions
@subsection readNextMufToken
@defun readNextMufToken @{ stg beg -> end beg typ @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is C-coded support for the 00-muf.muf muf
compiler: Token scanning is sufficiently fine-grained that
it seems a worthwhile efficiency win to put this inserver.

@display
@sc{input:}
'stg' must be a stg instance.
'beg' is the integer offset to begin scanning.
@sc{output:}
'beg' is integer offset of first char in token.
'end' is integer offset of last char in token.
'typ' is the type of token found:
@display
"afn": quote-colon token (':).
"qfn": quoted function name ('abc).
"flt": floating-point numbr (1.2).
"dbl": double-precision floating-point numbr (1.2d).
"int": integer (12).
"stg": double-quoted string ("abc").
"chr": single-quoted string ('a').
"id" : generic identifier (abc).
0    : nothing but whitespace found.
@end display
@end display
@end defun


@c
@node  addMufSource, continueMufCompile, readNextMufToken, compiler support functions
@subsection addMufSource
@defun addMufSource @{ stg muf -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is part of the inserver bootstrap muf
compiler, not intended for other use.  Likely to be
removed from the server in due course.
@end defun


@c
@node  continueMufCompile, startMufCompile, addMufSource, compiler support functions
@subsection continueMufCompile
@defun continueMufCompile @{ muf -> various @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is part of the inserver bootstrap muf
compiler, not intended for other use.  Likely to be
removed from the server in due course.

This is one of the functions which returns a variable
number of arguments.   Naughty!
@end defun


@c
@node  startMufCompile, setMufLineNumber, continueMufCompile, compiler support functions
@subsection startMufCompile
@defun startMufCompile @{ stg muf -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is part of the inserver bootstrap muf
compiler, not intended for other use.  Likely to be
removed from the server in due course.
@end defun


@c
@node  setMufLineNumber, mufShell, startMufCompile, compiler support functions
@subsection setMufLineNumber
@defun setMufLineNumber @{ int muf -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Sets the inserver muf compiler's concept of the current
line number.  The first line of a file or function should
be number zero;  Output functions should add one before
displaying it, to produce the one-based numbering
expected by users.

The standard @code{mufShell} stores the current top-level
muf compiler instance in @code{@@$s.compiler}.

This function is part of the inserver bootstrap muf
compiler, not intended for other use.  Likely to be
removed from the server in due course.
@end defun


@c
@node  mufShell, compileMufFile, setMufLineNumber, compiler support functions
@subsection mufShell
@defun mufShell @{ -> @@ @}
@display
@exdent file: muf.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{muf:mufShell} function is the default loop
run by the Muq server when it is invoked interactively:
The symbol name is hardwired into the interpreter and
looked up at startup time and the corresponding functional
value invoked.

The default functional value for this symbol is a loop
hand-assembled into the db when a db is first created, by
@file{muq/c/muf.t:validate_muf_shell()}.
@end defun


@c
@node  compileMufFile, parameter, mufShell, compiler support functions
@subsection compileMufFile
@defun compileMufFile @{ -> @@ @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{muf:compileMufFile} function is the default loop run by the
Muq server when it is invoked to do batch-mode compiles: The symbol name
is hardwired into the interpreter and looked up at startup time and the
corresponding functional value invoked.

The default functional value for this symbol is a loop
hand-assembled into the db when a db is first created, by
@file{muq/c/muf.t:validate_compile_muf_file()}.
@end defun


@c
@node  parameter, |potentialNumber?, compileMufFile, compiler support functions
@subsection parameter:
@defun parameter varname
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{parameter:} pseudo-op simply allocates a named
local variable: It doesn't normally produce any runtime
executable code at all, merely increases the constant
argument for the @code{vars} prim.

The intended use is to allocate space for a
named parameter when coding a lispStyle
function in muf:

@example
:   read @{ [] -> [] @}

    ( Declare four local vars for parameters: )
    parameter: inputStream
    parameter: eofErrorP
    parameter: eofValue
    parameter: recursiveP

    ( Process parameter block into above: )
    lisp:applyReadLambdaList
    ]setLocalVars

    ( Body of fn )
;
@end example

@end defun

@c
@node  |potentialNumber?, |unreadTokenChar, parameter, compiler support functions
@subsection |potentialNumber?
@defun |potentialNumber? @{ [token] -> [token] tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|potentialNumber?} compiler support
function accepts a block of integers coding
characters, such as returned by
@code{|backslashesToHighbit}, and returns a
Boolean value indicating whether the token is a
potential number (as defined by the CommonLisp
syntax standard).

@xref{|backslashesToHighbit}.
@xref{]makeNumber}.

@end defun

@c
@node  |unreadTokenChar, |readTokenChar, |potentialNumber?, compiler support functions
@subsection |unreadTokenChar
@defun |unreadTokenChar @{ [messageStream] -> [char] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|unreadTokenChar} function reverses the effect
of a preceding @code{|readTokenChar}.  You should not
count on being able to do this more than one char deep.

The intended use is to allow a loop to read chars
until a char not part of the current token is
encountered, then to return the final unwanted char.

Return value is the character unread.

@end defun

@c
@node  |readTokenChar, |readTokenChars, |unreadTokenChar, compiler support functions
@subsection |readTokenChar
@defun |readTokenChar @{ [messageStream] -> [char byteloc lineloc] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|readTokenChar} function reads one token
char.  In common with all the @code{|readToken*}
functions, it ignores all packets with tags other
than @code{txt} and all non-char values.

The @code{byteloc} return value is a zero-based integer
offset suitable for @code{|readTokenChars};
The @code{lineloc} return value is a zero-based integer
offset suitable for diagnostic messages.

@end defun

@c
@node  |readTokenChars, |scanTokenToChar, |readTokenChar, compiler support functions
@subsection |readTokenChars
@defun |readTokenChars @{ [messageStream start stop] -> [chars] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|readTokenChars} function reads a sequence
of characters from the given @code{messageStream}'s
token log.  The @code{start} parameter specifies the
byte offset of the first char to read, and the @code{stop}
parameter specifies the byte offset of the first char
not to read.

The intended uses are to read the chars in a token
immediately after locating it via a function like
@code{|scanTokenToWhitespace}, or to read the
source for an entire function.

Token logs are currently circular queues a fixed
16K chars in length, so tokens or functions longer
than this cannot be read this way.

@end defun

@c
@node  |scanTokenToChar, |scanTokenToChars, |readTokenChars, compiler support functions
@subsection |scanTokenToChar
@defun |scanTokenToChar @{ [mss char quote] -> [mss bytestart bytestop lineloc] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|scanTokenToChar} function reads token
chars from message stream @code{mss} until it
finds a char @code{char} (which is included
in the token).  If @code{quote} is not @code{nil},
it is a quote char (typically backslash), and
@code{char} terminates the token only if not
preceded by an unquoted quote.

The @code{|scanTokenToChar} function returns
@code{lineloc}, the line on which the token
began (for diagnostic purposes).  The remaining
arguments may be passed to @code{|readTokenChars}
to obtain the actual chars in the token.  (These
are sometimes unwanted, for example in comment
tokens.)

The terminating character is included in the token.

@end defun

@c
@node  |scanTokenToChars, |scanTokenToCharPair, |scanTokenToChar, compiler support functions
@subsection |scanTokenToChars
@defun |scanTokenToChars @{ [mss string quote] -> [mss bytestart bytestop lineloc] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|scanTokenToChars} function is
exactly like the @code{|scanTokenToChar}
function, except scanning is terminated by
any character in @code{string}.

@end defun

@c
@node  |scanTokenToCharPair, |scanTokenToWhitespace, |scanTokenToChars, compiler support functions
@subsection |scanTokenToCharPair
@defun |scanTokenToCharPair @{ [mss c1 c2 quote] -> [mss bytestart bytestop lineloc] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|scanTokenToCharPair} function is
exactly like the @code{|scanTokenToChar}
function, except that the token read is terminated
by the consecutive pair of characters @code{c1
c2}, instead of by a single character.  The
terminating characters are included in the token.

@end defun

@c
@node  |scanTokenToWhitespace, |scanTokenToNonwhitespace, |scanTokenToCharPair, compiler support functions
@subsection |scanTokenToWhitespace
@defun |scanTokenToWhitespace @{ [mss quote] -> [mss bytestart bytestop lineloc] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|scanTokenToWhitespace} function is
exactly like the @code{|scanTokenToChar}
function, except that the token read is terminated
by any whitespace character.  The terminating
whitespace is not included in the token.

@end defun

@c
@node  |scanTokenToNonwhitespace, event system functions, |scanTokenToWhitespace, compiler support functions
@subsection |scanTokenToNonwhitespace
@defun |scanTokenToNonwhitespace @{ [mss] -> [mss bytestart bytestop lineloc eol] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|scanTokenToNonwhitespace} function is
exactly like the @code{|scanTokenToChar}
function, except that the token read is terminated
by any nonwhitespace character, and an @code{eoln}
return value is provided which is @code{nil} unless the
token contained a newline.  The terminating
nonwhitespace is not included in the token.

@end defun

@c
@node event system functions, getNthRestart, |scanTokenToNonwhitespace, Core Muf
@section event system functions
@cindex Event system functions

@menu
* getNthRestart::
* getRestart::
* invokeRestart::
* invokeRestartInteractively::
* restartName::
* findRestart::
* computeRestarts::
* getAllActiveHandlers::
* invokeHandler::
* ]invokeDebugger::
* mufDebugger::
* signal::
* doSignal::
* doError::
* abort::
* continue::
* muffleWarning::
* storeValue::
* useValue::
* break::
* ]break::
* ]doBreak::
* ]reportEvent::
* ]cerror::
* ]error::
* ]warn::
* why unreliable signals?::
@end menu

@xref{withRestartDo}.
@xref{withHandlersDo}.

@xref{Muq Events}.

@c
@node  getNthRestart, getRestart, event system functions, event system functions
@subsection getNthRestart
@defun getNthRestart @{ n -> id data rFn iFn tFn fn name @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function returns the contents of the nth restart
from the @emph{top} of the loop stack, along with a
value which may be used to refer to it in future (the
integer offset of the restart within the stack, as it
happens -- but code should not be written to depend on
this).  The top restart is number zero.

The return values are:

@table @strong
@item name
@code{:name} symbol specified when creating restart.
@item fn
@code{:function} function specified when creating restart.
@item tFn
@code{:testFunction} function specified when creating restart.
@item iFn
@code{:interactiveFunction} function specified when creating restart.
@item rFn
@code{:reportFunction} function specified when creating restart.
@item data
@code{:data} value specified when creating restart, else @code{nil}.
@item id
@code{nil} if no nth restart was found, else a
restart label usable with @code{getRestart}.
@item ok
@end table

Example:

@example
Stack:
[ :function :: ; :name 'x | ]withRestartDo@{ 0 getNthRestart @}
Stack: 16 nil nil nil nil #<c-fn _> 'x
@end example

@end defun

@c
@node  getRestart, invokeRestart, getNthRestart, event system functions
@subsection getRestart
@defun getRestart @{ id -> id data rFn iFn tFn fn name @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function returns the contents of the
given restart.  The argument should have
been obtained from @code{getNthRestart},
either directly or indirectly.

The return values are the same as with
@code{getNthRestart}.

@xref{getNthRestart}.

Example:

@example
Stack:
       [ :function :: ; :name 'x | ]withRestartDo@{
-----> 0 getNthRestart pop pop pop pop pop getRestart @}
Stack: 16 nil nil nil nil #<c-fn _> 'x
@end example

@end defun

@c
@node  invokeRestart, invokeRestartInteractively, getRestart, event system functions
@findex ]invokeRestart
@subsection invokeRestart
@defun invokeRetart @{ id -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a symbol naming a restart, or else a
restart identifier, which must have been obtained from
@code{getNthRestart}, either directly or indirectly (as
via @code{findRestart}) and invokes it.  In the current
implementation, the restart function must neither accept nor
return arguments.

The @code{invokeRestart} function returns only if the
restart function itself returns -- many will do a
@code{goto} to some suitable tag.

This function is currently implemented as

@example
: invokeRestart @{ $ -> ! @} -> restart

    restart symbol? if
        restart nil findRestart -> restart
    fi

    restart getRestart
    -> name
    -> fn
    -> tFn
    -> iFn
    -> rFn
    -> data
    -> id

    fn call@{ -> @}
;
'invokeRestart export
@end example

A matching function @code{]invokeRestart} is provided for
restarts which take as argument a single block.

This function is currently implemented as

@example
: ]invokeRestart @{ [] $ -> ! @} -> restart

    restart symbol? if
        restart nil findRestart -> restart
    fi

    restart getRestart
    -> name
    -> fn
    -> tFn
    -> iFn
    -> rFn
    -> data
    -> id

    fn call@{ [] -> @}
;
']invokeRestart export
@end example

If you use restarts with other arities, you
may wish to write yourself an appropriate
variant of the above functions.

@end defun

@c
@node  invokeRestartInteractively, restartName, invokeRestart, event system functions
@subsection invokeRestartInteractively
@defun invokeRetart @{ id -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a symbol naming a restart, or else a
restart identifier, which must have been obtained from
@code{getNthRestart}, either directly or indirectly (as
via @code{findRestart}) and invokes it.

If the @code{:interactiveFunction} value for the
restart is @code{nil}, it is assumed that the
@code{:function} takes no arguments, and it is invoked
directly; If the @code{:interactiveFunction} value for
the restart is not @code{nil}, it should be a function
which constructs an appropriate argument block for the
@code{:function}, typically using the
@code{queryFor*} functions --- @xref{user i/o
functions}.

The @code{invokeRestartInteractively} function
returns only if the restart @code{:function} itself
returns --- many will do a @code{goto} to some suitable
tag.

Example:

@example
[   :name 'print
    :function  :: @{ [] -> @}   |pop -> text   ]pop   text ,  ;
    :interactiveFunction :: [ "text to print" "" queryForString | ;
    :reportFunction "Print something on standardOutput"
| ]withRestartDo@{
    'print invokeRestartInteractively
@}
@end example

@noindent
will prompt the user for text to print, print it, and return.

The @code{invokeRestartInteractively} function is
currently implemented as

@example
: invokeRestartInteractively @{ $ -> ! @} -> restart

    restart symbol? if
        restart nil findRestart -> restart
    fi

    restart getRestart
    -> name
    -> fn
    -> tFn
    -> iFn
    -> rFn
    -> data
    -> id

    iFn if
        iFn call@{ -> [] @}
        fn call@{ [] -> @}
    else
        fn call@{ -> @}
    fi
;
'invokeRestartInteractively export
@end example

@end defun

@c
@node  restartName, findRestart, invokeRestartInteractively, event system functions
@subsection restartName
@defun restartName @{ id -> name @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is specified by CommonLisp and
returns the name fields of the given restart.  The
argument should have been obtained from
@code{getNthRestart}, either directly or
indirectly.

This function is currently implemented as

@example
: restartName @{ $ -> $ @} -> restart

    ( A quick approximation to the CommonLisp function: )
    restart getRestart
    -> name
    -> fn
    -> tFn
    -> iFn
    -> rFn
    -> data
    -> id

    name
;
'restartName export
@end example

@end defun

@c
@node  findRestart, computeRestarts, restartName, event system functions
@subsection findRestart
@defun findRestart @{ restart event -> id @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is specified by CommonLisp and
returns the most recent active restart matching
the request, else @code{nil}.

The @code{restart} argument may be a symbol
naming the restart, or a restart identifier
such as returned by @code{getNthRestart}.

If @code{event} is @code{nil} it is ignored,
otherwise only restarts matching it will be
returned.  (A restart ``matches'' a event
if it has no test-function, or if that
test-function returns non-@code{nil} on that
event.)

This function is currently implemented as:

@example
: findRestart @{ $ $ -> $ @} -> event -> restart

    ( Over all available restarts: )
    0 -> i
    do@{
        ( Fetch next restart: )
        i getNthRestart
        -> name
        -> fn
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id

        ( Done if no restart found: )
        id not if nil return fi

        ( If name matches id, return it: )
        id restart = if id return fi

        ( If names and maybe events match, return it: )
        name restart = if
            event not                 if id return fi
            tFn      not                 if id return fi
            event tFn call@{ $ -> $ @} if id return fi
        fi

        ( Next restart to try: )
        i 1 + -> i
    @}
;
'findRestart export
@end example

@end defun

@c
@node  computeRestarts, getAllActiveHandlers, findRestart, event system functions
@subsection computeRestarts[
@defun computeRestarts[ @{ event -> [restarts] @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is specified by CommonLisp and returns all
active restarts matching the @code{event}.  If
@code{event} is @code{nil}, all active restarts are
returned.

(A restart ``matches'' a event if it has no
test-function, or if that test-function returns
non-@code{nil} on that event.)

This function is currently implemented as:

@example
: computeRestarts[ @{ $ -> [] @} -> event

    ( Create block of restarts to return: )
    [ |

    ( Over all available restarts: )
    0 -> i
    do@{
        ( Fetch next restart: )
        i getNthRestart
        -> name
        -> fn
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id

        ( Done if no restart found: )
        id not if return fi

        ( Maybe add restart to our collection: )
        event if
            tFn        if
                event tFn call@{ $ -> $ @} if
                    id |push
                fi
            else
                id |push
            fi
        else
            id |push
        fi

        ( Next restart to try: )
        i 1 + -> i
    @}
;
'computeRestarts[ export
@end example

@end defun

@c
@node  getAllActiveHandlers, invokeHandler, computeRestarts, event system functions
@subsection |getAllActiveHandlers[
@defun |getAllActiveHandlers[ @{ [args] -> [handlers] [args] lo hi k @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

This function is used internally by @code{]signal}
and kin to find handlers.  @emph{It is not
normally called directly by the application
programmer, and may well change in future
releases.}  It is a specialCase hack tuned
specifically for the convenience of @code{]signal}
and kin.

The @code{[args]} block is presumably the argument
block to be given to the selected handler(s).  The
@code{|getAllActiveHandlers[} does not modify
or inspect this block in any way, merely copies it
to be above the constructed @code{[handlers]} block.

The @code{[handlers]} block returned contains
@code{k} Events followed by @code{k} handlers,
pairs given originally to
@code{]withHandlersDo@{}.  Busy handler sets are
ignored: All handlers in the returned
@code{[handlers]} block are eligible to handle a
signal.

The @code{lo} and @code{hi} return values are
indices into the data stack delimiting the
Events portion of the
@code{[handlers]} block, such that

@example
for i from lo below hi do@{
    i     dupBth -> event
    i k + dupBth -> handler
    ...
@}
@end example

@noindent
will correctly iterate over all event handler
pairs, most recent bindings first.

Example:

@example
Stack:
[ .err.warning :: ; | ]withHandlerDo@{ [ | |getAllActiveHandlers[ @}
Stack: [ #<event warning> #<c-fn _> | [ | 2 3 1
@end example

(Note: This example assumes an unrealistically
simple runtime environment. Most actual Muq
runtime environments will produce additional
handlers if the example is run.)

Rationale: We fetch all active handlers in a
block, rather than looping with a get-nth type
function, because this reduces the work done from
O(N^2) in the stack size to O(N) in the stack
size.  Probably not a major issue most of the
time, but it is little if any extra work to avoid
the possible O(N^2) blowup, and making the
event system as efficient as practical may
encourage its use.

@end defun

@c
@node  invokeHandler, ]invokeDebugger, getAllActiveHandlers, event system functions
@subsection ]invokeHandler
@defun ]invokeHandler @{ [args] handler -> [args] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is used internally by @code{]signal}
and kin to invoke a handler.  @emph{It is not
normally called directly by the application
programmer.}  The @code{handler} argument
specifies the handler to invoke.  This argument is
@emph{not} a pointer to the handler proper, but
rather a handler @sc{id} as returned by
@code{|getAllActiveHandlers[}.

The reason we use @code{]invokeHandler} to invoke
a handler function, rather than just calling it
directly, is that @code{]invokeHandler} pushes a
@sc{handling} stackframe and then calls the
handler, all in one atomic operation, guaranteeing
that the handler set cannot possibly be handling
more than one signal at a time.  This guarantee is
required by the CommonLisp standard because it
prevents nasty bugs and coding headaches which
could otherwise occur.

Before calling the indicated handler, @code{]invokeHandler}
switches to the @code{actingUser} which was in effect at
the time the handler binding was established.  (This is
intended to avoid odd and difficult-to-trace problems due to
a signal arriving when some unexpected @code{actingUser} is
in effect.)  A @sc{job_stackframe_tmp_user} stackframe is
pushed before making the call, which will result in the
pre-@code{]invokeHandler} @code{actingUser} being restored
upon (any kind of) exit from the handler.
@xref{JOB_STACKFRAME_TMP_USER,,,muqimp.t,Muq Source Code}.

@end defun

@c
@node  ]invokeDebugger, mufDebugger, invokeHandler, event system functions
@subsection ]invokeDebugger
@defun ]invokeDebugger @{ [event] -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]invokeDebugger} function is a standard
way for a Muq program to enter the debugger.

If @code{@@$s.debuggerHook} is a compiled function,
it will be called with the event block and the
value of @code{@@$s.debuggerHook} itself.  We pass
the latter because @code{@@$s.debuggerHook} is set to
@code{nil} while the hook function is executing.

If @code{@@$s.debuggerHook} returns, then if
@code{@@$s.debugger} is a compiled function, it is
invoked with the event as argument.  (The event
is first converted from a stackblock to a vector
via @code{]makeVector}.) This function
should never return.  (If it does,
@code{]invokeDebugger} will in desperation kill the
job.)

Note that @code{@@$s.debugger} is set at login to the
value of @code{me$s.debugger}: thus the way to
``permanently'' change to another debugger is to set
@code{me$s.debugger} to the desired function.

By default, the standard Muq db binds @code{me$s.debugger}
to @code{mufDebugger}.  @xref{mufDebugger}.

For a very simple example, try:

@example
withTag my-tag do@{
    [   :function :: @{ -> ! @} 'my-tag goto ;
        :name     'my-restart
        :reportFunction "Continue from 'my-tag"
    | ]withRestartDo@{
        [ | ]invokeDebugger
    @}
my-tag
@}
@end example

This will invoke the debugger after establishing a
restart which lets you continue from where you left
off.

The @code{]invokeDebugger} function is currently implemented as:

@example
: ]invokeDebugger @{ [] -> @@ ! @}

    ( Invoke debugger_hook, if present: )
    @@$s.debuggerHook -> dh
    dh compiledFunction? if
        ( We're supposed to bind rather than )
        ( set, but we'll cheat, since we do  )
        ( not have binding implemented yet:  )
        after@{
            nil --> @@$s.debuggerHook
            |dup[ dh dh
            call@{ [] $ -> @}
        @}alwaysDo@{
            dh --> @@$s.debugger_hook
        @}
    fi

    ( Since debuggerHook returned, )
    ( invoke standard debugger:     )
    ]makeVector -> event
    @@$s.debugger -> debugger
    debugger compiledFunction? if
        event debugger call@{ $ -> @@ @}
    fi

    ( If no debugger, kill job: )
    "]invokeDebugger: Invalid @@$s.debugger, killing job." ,
    nil endJob
;
']invokeDebugger export
@end example

@xref{break}.
@xref{]error}.
@xref{]cerror}.
@end defun

@c
@node  mufDebugger, signal, ]invokeDebugger, event system functions
@subsection mufDebugger
@defun mufDebugger @{ event-vector -> @@ @}
@display
@exdent file: 15-C-debugger.muf
@exdent package: debug
@exdent status: alpha
@end display

The @code{mufDebugger} function is the
default Muq debugger.  It accepts a event
block which has been converted to a vector
via @code{]makeVector}, interacts with the
user, and eventually exits by invoking a
restart -- it never does a simple return.

See its internal online help for a
description of its command language.

@xref{]invokeDebugger}.
@xref{]break}.
@xref{break}.
@end defun

@c
@node  signal, doSignal, mufDebugger, event system functions
@subsection ]signal
@defun ]signal @{ [event] -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is the most vanilla way to invoke the
event system.

The argument block to this function consists of
keyVal pairs, and will be handed unchanged to
the signal handlers.  (The block may currently
not contain more than 64 keyval pairs:  See
the rationale at end of this subsection.)

One keyval pair must always be present:

@example
:event C
@end example

@noindent
where @code{C} is a Event object.  This
specifies the particular type of event
being signaled.

An important optional keyval pair is

@example
:job J
@end example

where @code{J} is a Job object.  If this keyval is
provided, the signal is sent to the specified job,
and is handled (or not) by whatever handlers that
job has established.  If no @code{:job J} keyval
is provided, the signal is sent to the currently
executing job.

In order to send a signal to another job, the
actingUser must be the same as the actualUser of
the other job, or else must be root running with
the @sc{omnipotent} bit set: Otherwise the signal
will be silently ignored.

Any other keyval pairs present will be ignored by
@code{]signal} but may be meaningful to any signal
handlers invoked.

Signals sent to other jobs via @code{]signal}
always return.

Signals sent to the currently running job
return if and only if all ``relevant'' handlers
return.

A handler is ``relevant'' if the event
associated with the handler is the same as the
event @code{C} being signaled (or is a parent
of @code{C}), and if that handler is not part of a
handler set already handling a signal.

Note that these signals are @emph{unreliable}:
There is no guarantee that any handler will be
invoked, even if present, since it might be busy
handling another signal.

@strong{Rationale:} The definition of this
function was selected with the intention that it
be a primary means of communication between Muq
jobs, yet anticipating that in general these jobs
may not be on the same Muq server.  It is intended
that one reasonable implementation of signals in
such a case be via @sc{udp} packet.

Unreliable signals are appropriate for a variety
of state-update tasks in multi-user interactive
settings, such as tracking cursor position: If a
particular update gets lost, the next update will
rectify matters anyhow, so there is no need for
expensive reliable-delivery mechanisms, and in
particular no need to block the sender for a full
roundTrip time over the network.

It is anticipated that when reliable delivery of
information is needed, that streams rather than
signals will be used, and that the underlying
implementation will in this case use a reliable
stream protocol such as @code{tcp}.

When appropriate, you may of course implement your
own acknowledgement protocol on top of the basic
Muq signal facility: Waiting for a return signal
after each signal, or checking for a heartbeat
every N milliseconds or whatever.

Signal blocks are limited to 128 entries (configurable
by changing @sc{job_signal_block_max} and recompiling)
partly because signals are intended for brief notifications,
not (say) file transfer, and need to fit in a datagram
without excessive fragmentation or spamming the net
interface.

@strong{Future directions:} Due to limitations such as
UDP packet size, it is likely that future Muq releases
will place a limit on the total size in bytes of the
keyword names.  It is reasonably safe to assume that
such limit will support an aggregate half a K or so of
keyval names.  (The default Maximum Transmission Unit
size on the Internet is 576 bytes; Ideally
@code{]signal} blocks should be about this size, or
smaller.)

@xref{doSignal}.

@end defun

@c
@node  doSignal, doError, signal, event system functions
@subsection ]doSignal
@defun ]doSignal @{ [event] -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is invoked by the @code{]signal}
primitive to do the work of actually generating a list
of all active handlers, then sequentially invokes each
handler appropriate to the given event, most recent
binding first, until one doesn't return.  If all
return, @code{]doSignal} returns nothing.

The in-server @code{signal[} operator itself
merely handles the necessary magic to pass the
event block between jobs, if needed, then
invokes the in-db @code{]doSignal} function to do
the rest of the work.

Customization of @code{]doSignal} is possible:
@code{]signal} actually runs whatever function it
finds in the @@$s.doSignal property of the
recipient job.  You may set this property to
anything you like.  If it is not set to a valid
@code{compiledFunction} object, @code{]signal}
will silently ignore all events raised.

The @code{]doSignal} function is currently implemented as:

@example
:   ]doSignal

    ( This function is the default value of   )
    ( @@$s.doSignal, and hence gets called by )
    ( the server when delivering a signal to  )
    ( the job.                                )

    :event |get -> event
    |getAllActiveHandlers[
        -> k
        -> hi
        -> lo
        for i from lo below hi do@{
            i     dupBth -> eventN
            i k + dupBth -> handlerN
            .err.event event = if
                handlerN ]invokeHandler
            else
                event eventN childOf? if
                    handlerN ]invokeHandler
            fi  fi
        @}
    ]pop
    ]pop
;
@end example

@noindent
(The special @code{.err.event event = if} hack
is partial enforcement of the CommonLisp requirement that
all events inherit from @code{.err.event}:  This
hack at least guarantees that a handler set on
@code{.err.event} will catch all signals.)

@xref{signal}.
@xref{childOf?}.
@end defun

@c
@node  doError, abort, doSignal, event system functions
@subsection doError
@defun doError @{ event formatString -> @@ @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is the default value of
@code{@@$s.doError} and hence gets called by the
server when an error is detected, as the first
part of the server error-signaling process.

The @code{doError} function is currently implemented as:

@example
: doError @{ $ $ -> @@ @} -> formatString -> event

    ( This function is the default value of   )
    ( @@$s.doError, and hence gets called by  )
    ( the server when an error is detected,   )
    ( as the first part of the errorHandling )
    ( process.                                )

    ( Construct an appropriate event: )
    [   :event     event
	:formatString formatString
    | ]error
;
@end example

@xref{]error}.
@end defun

@c
@node  abort, continue, doError, event system functions
@subsection abort
@defun abort @{ event -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{abort} function invokes the most recent
@code{abort} restart, which normally results in
return to the outer @code{readEvalPrint} loop
of the current interpreter or shell.

The @code{event} argument will usually be
@code{nil}, but may be used to restrict selection
to a subset of the active @code{abort} restarts.

The @code{abort} function is currently implemented as:

@example
: abort @{ $ -> @} -> event

    'abort event findRestart -> restart
    restart if
        restart invokeRestart
    fi
    [ :event .err.controlError | ]signal
;
@end example

@xref{withRestartDo}.

@end defun

@c
@node  continue, muffleWarning, abort, event system functions
@subsection continue
@defun continue @{ event -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

(If you are looking for the @sc{muf} equivalent to the
C @code{continue} operator, you want
@code{loopNext}. @xref{do}.)

The @code{continue} function invokes the most recent
@code{continue} restart, which normally results in
continuation of the computation that was just
interrupted:  Most functions which suspend
computation with the intention of allowing
immediate resumption will establish a
@code{continue} restart for the purpose.
For example, @ref{]cerror}.

The @code{event} argument will usually be
@code{nil}, but may be used to restrict selection
to a subset of the active @code{continue} restarts.

The @code{continue} function is currently implemented as:

@example
: continue @{ $ -> @} -> event

    'continue event findRestart -> restart
    restart if restart invokeRestart fi
;
@end example

@end defun

@c
@node  muffleWarning, storeValue, continue, event system functions
@subsection muffleWarning
@defun muffleWarning @{ event -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{muffleWarning} function invokes the most
recent @code{muffleWarning} restart, which normally
results in continuation of the computation that was
just interrupted without printing of a warning message:
It is normally invoked by a handler for a event
signaled via @code{]warn}, which establishes a
@code{muffleWarning} to let handlers suppress its
default message.  @xref{]warn}.

The @code{event} argument will usually be @code{nil},
but might potentially be used to restrict selection to
a subset of the active @code{muffleWarning} restarts.

The @code{muffleWarning} function is currently implemented as:

@example
: muffleWarning @{ $ -> @} -> event

    'muffleWarning event findRestart -> restart
    restart if restart invokeRestart fi
    [ :event .err.controlError | ]signal
;
@end example

@end defun

@c
@node  storeValue, useValue, muffleWarning, event system functions
@subsection storeValue
@defun storeValue @{ event value -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{storeValue} function invokes the most
recent @code{storeValue} restart, which normally
results in continuation of the computation that was
just interrupted with the offending variable set
to the given value.

@sc{note}:  This function is included because it
is specified by the CommonLisp standard.  Muq does
not currently ever establish an @code{storeValue}
restart, hence this function is of little if any
use at the moment.

The @code{storeValue} function is currently implemented as:

@example
: storeValue @{ $ $ -> @} -> value -> event

    'storeValue event findRestart -> restart
    restart if [ value | restart ]invokeRestart fi
;
@end example

@end defun

@c
@node  useValue, break, storeValue, event system functions
@subsection useValue
@defun useValue @{ event value -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{useValue} function invokes the most
recent @code{useValue} restart, which normally
results in continuation of the computation that was
just interrupted with given value substituted
for that originally obtained (but without
modifying the corresponding variable, if any).

@sc{note}:  This function is included because it
is specified by the CommonLisp standard.  Muq does
not currently ever establish an @code{useValue}
restart, hence this function is of little if any
use at the moment.

The @code{useValue} function is currently implemented as:

@example
: useValue @{ $ $ -> @} -> value -> event

    'useValue event findRestart -> restart
    restart if [ value | restart ]invokeRestart fi
;
@end example

@end defun

@c
@node  break, ]break, useValue, event system functions
@subsection break
@defun break @{ string -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is a quick and simple way of invoking
the debugger.  It is intended to be inserted as a
temporary debugging technique, not as a routine
production coding method.  It packages up the given
string as the @code{:formatString} in a @code{simpleEvent}
event block, and then invokes @code{]doBreak}.

The @code{break} function is a convenience:

@example
"some-string" break
@end example

@noindent
is equivalent to

@example
[   :event .err.simpleEvent
    :formatString "some-string"
| ]break
@end example

If @code{@@$s.breakDisable} is set non-@code{nil},
@code{break} become a no-op which does nothing
but check and pop its argument.

@xref{]break}.
@xref{]doBreak}.

@end defun

@c
@node  ]break, ]doBreak, break, event system functions
@subsection ]break
@defun ]break @{ [event] -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is a flexible way of invoking
the debugger.  It is intended to be inserted as a
temporary debugging technique, not as a routine
production coding method.  It invokes @code{]doBreak}.

A minimal argument block is

@example
[ :event .err.simpleEvent |
@end example

In any event, the argument block must consist of
symbol- (usually keyword-) value pairs, exactly
one such symbol must be @code{:event}, and
the corresponding value must be a @code{Event}.

If @code{@@$s.breakDisable} is set non-@code{nil},
@code{]break} become a no-op which does nothing
but check and pop its argument block.

@xref{break}.
@xref{]doBreak}.

@end defun

@c
@node  ]doBreak, ]reportEvent, ]break, event system functions
@subsection ]doBreak
@defun ]doBreak @{ [] -> @}
@display
@exdent file: 15-C-debugger.t
@exdent package: muf
@exdent status: alpha
@end display

This function is invoked by @code{break} to do
the work of actually invoking the debugger.

Customization of @code{]doBreak} is possible: @code{break}
actually runs whatever function it finds in the
@@$s.doBreak property of the job.  You may set this
property to anything you like.  If it is not set to a valid
@code{compiledFunction} object, @code{break} becomes a
no-op.

Note that @code{@@$s.doBreak} is set at login to the
value of @code{me$s.doBreak}, thus the way to
``permanently'' change to another break function is to set
@code{me$s.doBreak} to the desired function.

The default @code{]doBreak} function is currently
implemented as

@example
: ]doBreak @{ [] -> @@ @}

    ( Save the event in a vector. )
    ( We do this before setting the   )
    ( 'cont tag since we don't want   )
    ( the 'cont tag trying to restore )
    ( the event to the stack when )
    ( invoked:                        )
    ]makeVector -> event

    ( Establish a 'cont tag that returns to caller: )
    withTag cont do@{

        ( Establish a 'continue restart jumping to 'cont: )
        [   :function :: @{ -> ! @} 'cont goto ;
            :name     'continue
            :reportFunction "Continue from 'break'."
        | ]withRestartDo@{

            ( Invoke debugger.  We don't use     )
            ( "]invokeDebugger" here because it )
            ( checks @@$s.debugger_hook, and     )
            ( CommonLisp specifies that 'break'  )
            ( shouldn't use @@$s.debugger_hook.  )
            @@$s.debugger -> ]debugger
            ]debugger compiledFunction? if
                event debugger call@{ $ -> @@ @}
            fi

            ( If no debugger, kill job: )
            "break: Invalid @@$s.debugger, killing job." ,
            nil endJob
        @}
        cont
        ]pop
    @}
;
']doBreak export
#']doBreak --> .u["root"]$s.doBreak
@end example

@xref{break}.
@xref{]break}.
@end defun

@c
@node  ]reportEvent, ]cerror, ]doBreak, event system functions
@subsection ]reportEvent
@defun ]reportEvent @{ [event] stream -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is invoked by @code{]error},
@code{]cerror} and @code{]warn} to actually
announce a event, hence may be customized
to modify the way such announcements are done.

The @code{]reportEvent} function is currently implemented as:

@example
: ]reportEvent @{ [] $ -> @} -> ostream
    :formatString |get -> formatString
    formatString if
        [ "Sorry: %s\n" formatString | ]print ostream writeStream
    else
        :event |get -> event
        [ "Sorry: %s\n" event$s.name | ]print ostream writeStream
    fi
    ]pop
;
@end example

@xref{]error}.
@xref{]cerror}.
@xref{]warn}.
@end defun

@c
@node  ]cerror, ]error, ]reportEvent, event system functions
@subsection ]cerror
@findex cerror
@defun ]cerror @{ [event] -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is the standard way for the @sc{muf}
application programmer to signal detection of a
continuable error.

The argument should be a valid event block,
containing at minimum a event, and normally
also a @code{:formatString} describing the
problem:

@example
[   :event    .err.simpleError
    :formatString "The snarkle got frobulated."
|
@end example

The @code{]cerror} function first establishes
a @code{continue} restart, then @code{]signal}s
the event, then if @code{]signal} returns
(indicating no handler resolved the problem)
either invokes the debugger or else prints
an error message and aborts, depending whether
@code{@@$s.breakEnable} is @code{nil}.

The @code{]cerror} function is currently implemented as:

@example
: ]cerror @{ [] -> ! @}

    ( Establish a 'cont tag that returns to caller: )
    withTag cont do@{

        ( Establish a 'continue restart jumping to 'cont: )
        [   :function :: @{ -> ! @} 'cont goto ;
            :name     'continue
            :reportFunction "Continue from ]cerror call."
        | ]withRestartDo@{

            ( Issue the requested signal: )
            |dup[ ]signal

            ( Handlers didn't resolve event: )
            @@$s.breakEnable if
                ]invokeDebugger
            else
                @@$s.errorOutput ]reportEvent
                nil abort
            fi
        @}
        cont
        ]pop
    @}
;
@end example

A convenience function @code{cerror} is also provided
for cases when specifying a string is sufficient:  It
is currently implemented as

@example
: cerror @{ $ -> @} -> formatString

    [   :event .err.simpleError
	:formatString formatString
    | ]cerror
;
@end example

@xref{]error}.
@xref{]warn}.
@end defun

@c
@node  ]error, ]warn, ]cerror, event system functions
@subsection ]error
@defun ]error @{ [event] -> @@ @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is the standard way for the @sc{muf}
application programmer to signal detection of an
uncontinuable error.

The argument should be a valid event block,
containing at minimum a event, and normally
also a @code{:formatString} describing the
problem:

@example
[   :event    .err.simpleError
    :formatString "The snarkle got frobulated."
| ]error
@end example

The @code{]error} function @code{]signal}s
the event, then if @code{]signal} returns
(indicating no handler resolved the problem)
either invokes the debugger or else prints
an error message and aborts, depending whether
@code{@@$s.breakEnable} is @code{nil}.

The @code{]error} function is currently implemented as:

@example
: ]error @{ [] -> @@ ! @} 

    ( Signal the given event: )
    |dup[ ]signal

    ( Handlers didn't resolve event: )
    @@$s.breakEnable if
        ]invokeDebugger
    else
        @@$s.errorOutput ]reportEvent
        nil abort
    fi
;
@end example

A convenience function @code{error} is also provided
for cases when specifying a string is sufficient:  It
is currently implemented as

@example
: error @{ $ -> @@ @} -> formatString

    [   :event .err.simpleError
	:formatString formatString
    | ]error
;
@end example

@xref{]cerror}.
@xref{]warn}.
@end defun


@c
@node  ]warn, why unreliable signals?, ]error, event system functions
@subsection ]warn
@defun ]warn @{ [event] -> @}
@display
@exdent file: 01-C-event.t
@exdent package: muf
@exdent status: alpha
@end display

This function is the standard way for the @sc{muf}
application programmer to signal detection of an
dangerous or dubious event which does not
actually prevent computation from proceeding.

The argument should be a valid event block,
containing at minimum a event, and normally
also a @code{:formatString} describing the
problem:

@example
[   :event    .err.simpleError
    :formatString "The snarkle got frobulated."
|
@end example

The @code{]warn} function first establishes
a @code{muffleWarning} restart, then @code{]signal}s
the event, then if @code{]signal} returns
(indicating no handler decided to suppress the
warning by invoking the @code{muffleWarning}
restart) issues a warning message and returns
normally.

The @code{]warn} function is currently implemented as:

@example
: ]warn @{ [] -> @}

    ( Establish a 'muffle tag that returns to caller: )
    withTag muffle do@{

        ( Establish a 'muffleWarning restart jumping to 'muffle: )
        [   :function :: @{ -> ! @} 'muffle goto ;
            :name     'muffleWarning
            :reportFunction "Continue from ]warn call."
        | ]withRestartDo@{

            ( Issue the requested signal: )
            |dup[ ]signal

            ( Write warning to errorOutput: )
            @@$s.errorOutput ]reportEvent
        @}
        muffle
    @}
;
@end example

As a convenience, an @code{warn} function is also
available, accepting a single string.  It is
currently implemented as

@example
: warn @{ $ -> @} -> formatString

    [   :event .err.simpleError
        :formatString formatString
    | ]warn
;
@end example

@xref{]cerror}.
@xref{]error}.
@end defun

@c
@node  why unreliable signals?, control structure syntax, ]warn, event system functions
@subsection why unreliable signals?

Why should the basic Muq signal system be unreliable?
Shouldn't it promise reliable signal delivery at least
within a given server, when no network packet loss problems
are involved?  Shouldn't the server at the very least
guarantee that a division-by-zero signal within a job always
gets reliably delivered?

Perhaps it should!  But there are reasonable arguments
against this:

@itemize @bullet
@item
Our principal standard, CommonLisp, specifies unreliable signals.
Having reliable signals too would mean more or less two
separate signal systems within the same server, which
is clearly to be avoided if possible.

@item
Having more than one copy of the same signal handler
running at the same time in the same task presents
problems which the server can't hide from the app
programmer:  It means any datastructures manipulated
by the handler can easily get munged due to interleaved
execution.  The normal solution would be to use a lock,
but this doesn't work here because it would be the same
job already holding the lock, so you'd get either no
change or deadlock, depending on whether your lock
allowed the same job in again or not.  Some more
ingenious solution would be required in such handlers,
and most application programmers would just ignore the
problem, leading to obscure and unrepeatable timing-
dependent errors.  All in all, re-invoking a handler
which is already running sounds like a mess to be
avoided if at all possible.

@item
If handlers which are already running are not to be
interrupted, the only remaining strategy for implementing
reliable signals is to queue up signals as they are sent.
But now we have the problem that the signal producer can
easily outrun the signal consumer:  Our queue may get
arbitrarily large, perhaps limited only by available
disk space.  Now either we have to depend on the signal
producer to check the queue size (which again most app
programmers probably won't bother to do) or we need to
block the signal producer when the queue reaches some
limit.  But now we've basically re-implemented message
streams, which we already have, at the cost of sacrificing
nice properties of signals that some people might want,
such as being able to count on them always returning
"immediately":  We seem to me to have made the signal
implementation more expensive while reducing its utility.
@end itemize

It may be worth clarifying what we mean by signals being
"unreliable" within a given server: We mean that there is no
guarantee that a given signal sent to a given job will have
any effect on that job, @emph{because} if the only appropriate
signal handler is already running, the new signal will
simply be silently discarded.

To take the division-by-zero example, this means that a
division-by-zero notification will be lost only if the
division-by-zero happens in the division-by-zero handler.
But isn't this what one wants, really?  If the
division-by-zero handler is generating division-by-zero
events, re-invoking it will probably simply lead to an
infinite recursion followed by a stack overflow, which
doesn't seem an improvement.  Under the Muq unreliable
signal system, any division-by-zero exceptions raised within
the division-by-zero handler will be handled by any prior
division-by-handler if present, else by any more general
error handler if present, else simply ignored.  I think this
is just about right.

For special cases where the signal absolutely -must- go
through, but regular message streams are for some reason
insufficient, one can build a more sophisticated mechanism
on top of the basic Muq server facility, perhaps using some
combination of both message streams and signals, or perhaps
waiting for an acknowledging signal and resending after some
timeout, or such.  It will probably be a fairly complex
system by the time it is complete -- likely too complex to
make in-server implementation of it sensible or effective.
The particular algorithm chosen may well prove to be
application-dependent, which provides yet another reason to
keep it out of the Muq server proper, which is intended to
provide "mechanism, not policy" (to quote an X window system
catchphrase).

@c
@node control structure syntax, control structure overview, why unreliable signals?, Core Muf
@subsection control structure syntax

@menu
* control structure overview::
* after::
* call::
* catch::
* compileTime::
* for::
* foreach::
* if::
* goto::
* listfor::
* neverInline::
* pleaseInline::
* until::
* do::
* while::
* withLockDo::
* withRestartDo::
* withHandlersDo::
* withTags::
* return::
* case::
* asMeDo::
* rootAsUserDo::
* rootOmnipotentlyDo::
@end menu

@c
@node  control structure overview, after, control structure syntax, control structure syntax
@section control structure overview
@cindex Control structure overview

Most of the words documented in this section do not actually
correspond directly to Muq bytecode primitives; Instead,
they are essentially directives to the muf compiler to alter
the normal sequential flow of control in various ways, which
it does by synthesizing patterns of simpler bytecode
primitives.

It is traditional in Forth to allow the programmer great
flexibility, up to and including defining new control
structures and crashing the interpreter.  As a multi-user
system, Muq cannot allow users to crash the interpreter, but
it does allow users to define new control structures.  This
isn't currently (version -1.0.0) documented or fully
finalized; someone remind Cynbe to do so, sometime.

Muq muf uses curly braces to delimit the scope of control
structures, somewhat as C does:
@example
do@{ @dots{} @}
@end example
Since muf, unlike C, breaks source code up into tokens
simply based on whitespace, the presence or absence of
a blank is very significant in muf:  The above example
is @emph{not} equivalent to
@example
do @{ @dots{} @}
@end example


@c
@node  after, call, control structure overview, control structure syntax
@subsection after
@deffn Control-struct after@{ ... @}alwaysDo@{ ... @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

It is often important that certain cleanup operations be
done at the end of a given section of code, even if that
section should fail in some way.

For example, if one is doing a network file transfer, the
socket should be closed at the end, even if the tranfer
fails to complete normally for some reason.

Or if one has a session open to an X server, one should be
very careful to release resources allocated in the server at
the end of the session, to avoid having it gradually fill up
with unused garbage.

Almost every nontrivial application has invariants like
these which it is intended to maintain, but which must be
temporarily broken from time to time during processing: One
of the hallmarks of high-quality muf code is the careful
attention given to preserving all invariants in the face of
unexpected error conditions.

The Muq control construct designed for these cases is

@example
after@{ clause-1 @}alwaysDo@{ clause-2 @}
@end example

Muq goes to great lengths internally to guarantee that
clause-2 will always execute, even if the code in clause one
should do a divide-by-zero or attempt to do a @code{throw}
or @code{return} past us: It will silently interrupt the
error-recovery, throw, or return processing long enough for
clause-2 to execute, and then transparently resume the
interrupted processing.

Almost the sole exception to this rule is that if
@code{killJobMessily} is used to terminate the job
during execution of clause-1 or clause-2, no attempt is
made to execute (or complete execution of) clause-2:
the job is killed dead, instantly.  This ensures that
users and root always have @emph{some} way to kill a
runaway process: if Muq insisted on always running
clause-2 to completion, an accidental or malicious
recursion or infinite loop in clause-2 could result in
an immortal, cancerous process endlessly chewing up
system resources until the server crashed.

(This is, of course, a good reason to use
@code{killJobMessily} only as a last resort: one
should always first attempt to kill an unwanted job
with a friendly @code{killJob} signal, giving it a
fair chance to clean up after itself before exiting.)

What should happen if clause-1 does a fork?  This
leaves two jobs capable of executing clause-2, but
in general one wishes clause-2 to be executed
exactly once.

There are two obvious policies:  Have only the child
job execute clause-2, or have only the parent job
execute clause-2.  Since convincing examples exist
supporting each possibility, Muq provides both, via
the syntax

@example
afterChildDoes@{  clause-1 @}alwaysDo@{ clause-2 @}
afterParentDoes@{ clause-1 @}alwaysDo@{ clause-2 @}
@end example

The vanilla syntax

@example
after@{ clause-1 @}alwaysDo@{ clause-2 @}
@end example

is currently a synonym for the
@code{afterParentDoes@{}
syntax.
@end deffn

@c
@node  call, catch, after, control structure syntax
@subsection call
@deffn Control-struct call @{ ... fn -> ... @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{call@{ inargs -> outargs @}} syntax generates code
which accepts one compiledFunction (or a symbol with
appropriate functional value) and invokes it, after checking
that the compiledFunction's arity is as declared.  (But a
@code{call@{ -> ? @}} matches any function.) Thus,
if anyone complains that in Muq @sc{muf} you must do @code{2
2 +} to add two and two, you may easily demonstrate that
there are actually many more ways:

@example
Stack:
2 2 +
Stack: 4
pop 2 2 '+ call@{ $ $ -> $ @}
Stack: 4
pop 2 2 :: + ; call@{ $ $ -> $ @}
Stack: 4
pop 2 2 :: + ; : c call@{ $ $ -> $ @} ; c
@end example

The @code{call@{@dots{}@}} syntaxis is the intended
mechanism for invoking functions which are passed as
arguments or plucked at runtime from the database.

Note: An older syntax of simply @code{call} still
exists.  It can be useful in exceptional cases where
you need and want to call a function of no
particular arity, as for example in a user shell.

@end deffn


@c
@node  catch, compileTime, call, control structure syntax
@subsection catch
@findex ]throw
@findex throw
@deffn Control-struct catch@{  @dots{} [ | @dots{} ]throw @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

When writing nontrivial code, one sometimes needs to abort a
fairly deeply nested set of function calls.

One way of handling this problem is by having each function
return a flag saying "yes, I'm aborting," or "no, I'm not
aborting," and then having every function-call check this
flag an conditionally propagate the abort.  However, code
written this way is tedious to code, ugly to read, and prone
to errors.  Code with the single purpose of implementing a
non-local exit winds up scattered all through the program,
which is poor separation of concerns and just plain poor
software design.

C solves this problem via @code{setjmp()} and
@code{longjmp().}  Lisp implements a similar but more
sophisticated utility via @code{catch} and @code{throw,}
recently adopted by @sc{ansi} Forth.  Muq implements a
similar @code{catch/throw} pair:

@example
anyconst catch@{ ... [ anyargs | anyconst ]throw ... @}
@end example

Catch accepts one @code{anyconst} argument: It only responds
to @code{]throw}s given a matching @code{anyconst} value.

(This makes selective @code{]throw}ing possible, in which a
@code{]throw} bypasses several @code{catch} clauses to reach
a preferred one deeper down on the execution stack.)

@code{Catch} then executes the brace-enclosed clause;  If the
clause complete normally, @code{catch} returns a @code{nil} value
on top of an empty block.

If a matching @code{]throw} is executed in the clause,
@code{catch} pushes a true value on top of the block
returned by @code{]throw.}
@end deffn


@c
@node  compileTime, for, catch, control structure syntax
@subsection compileTime
@deffn Control-struct compileTime
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Algolic compilers (Algol, C, Pascal, Modula, Ada @dots{})
are traditionally big black boxes of functionality locked
away from the programmer.  Lisp and Forth compilers are
traditionally open frameworks which programmers are
encouraged to use and extend.  Muq @sc{muf} is implemented
in the latter spirit.

Specifically, Forth traditionally implements the compiler
using a standard architecture which is documented and
open to the programmer, and provides a keyword by which
the programmer may mark a particular function as being
intended to run at compiletime rather than at runtime.

When the compiler encounters an invocation of such a
function, it evaluates the function immediately in the
context of the partly-compiled program, rather than
assembling a call to invoke it at runtime.  In essence, the
programmer is allowed to dynamically extend the compiler.

Muq @sc{muf} defines a very different compileTime
architecture (since, again, it must prevent erroneous or
malicious code from crashing the interpreter), but provides
essentially the same facility: Any function which contains
the operator @code{compileTime} anywhere in its definition
compiles into an executable procedure with a special flag
set; When the @sc{muf} compiler encounters an invocation of
such a procedure, it evaluates the procedure immediately at
compiletime, rather than assembling a runtime call to it.
@end deffn

Since the compileTime architecture is not yet (version
-1.0.0) stably defined, no examples of this are given here.

Note: The @sc{compileTime} flag is ignored by the inserver
@sc{muf} compiler, which is the only compiler functional in
the -1.0.0 Muq release.

Note: This operator will probably be replaced by a
@code{define-macro:} operator in a future release.


@c
@node  for, foreach, compileTime, control structure syntax
@subsection for
@findex for
@findex from
@findex upto
@findex downto
@findex below
@findex above
@findex by
@example
@exdent for i from 1 upto   9 by 1 do@{ @dots{} @}
@exdent for i from 9 downto 1 by 1 do@{ @dots{} @}
@exdent for i from 1 below  9 by 1 do@{ @dots{} @}
@exdent for i from 9 above  1 by 1 do@{ @dots{} @}
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end example

The @code{for} construct is Muq @sc{muf}'s tool for interating a
specified number of times.

The "by" value should always be positive, and defaults to
one if not specified.

The "from" value defaults to zero if not specified.

The "upto" value specifies a limit which is to be reached:
The index variable may have this value on the final iteration.

The "below" value specifies a limit which is not to be reached:
The index variable must be below this value on the final iteration.

The "downto" value specifies a limit which is to be reached:
The index variable may have this value on the final iteration.

The "above" value specifies a limit which is not to be reached:
The index variable must be above this value on the final iteration.

If "downto" or "above" are supplied, the loop runs towards
smaller values, else it runs toward larger values.

@example
Stack:
[ for i below 10 do@{ i @} |
Stack: [ 0 1 2 3 4 5 6 7 8 9 |
]pop for b from 9 downto 0 do@{ [ "%d beers on the shelf!\n" b | ]print , @}
9 beers on the shelf!
8 beers on the shelf!
7 beers on the shelf!
6 beers on the shelf!
5 beers on the shelf!
4 beers on the shelf!
3 beers on the shelf!
2 beers on the shelf!
1 beers on the shelf!
0 beers on the shelf!
Stack: 
@end example


@c
@node  foreach, goto, for, control structure syntax
@subsection foreach
@deffn Control-struct foreach  key [val] do@{ ... @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{foreach} construct is Muq @sc{muf}'s tool for
conveniently iterating over all public keys (and optionally
values) on an object:

@example
Stack:
makeIndex --> o
Stack:
101 --> o.a   102 --> o.b   103 --> o.c
Stack:
o foreach key val do@{ [ "%s:%d\n" key val | ]print , @}
a:101
b:102
c:103
Stack:
@end example

The @code{foreach} operator accepts one object argument, then
executes the given code clause once for each public key on the
object, setting the given @code{key} local variable succesively
to each key.

If the optional @code{val} local variable is also supplied,
it will be filled in with the corresponding value. If this
variable is not supplied, the values of the various keys are
not fetched, which may speed the loop somewhat.

The current implementation does not automatically store
changes to the @code{val} variable back to the given object.
@end deffn

Matching constructs are available to loop over the other
four areas of an object: foreachHidden, foreachSystem and
foreachAdmins.


@c
@node  goto, if, foreach, control structure syntax
@subsection goto
@deffn Control-struct 'tag goto
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Jump to the given tag, which may be in the same
function or a calling function.  If the tag is
in the same function, it should @emph{not} be
more deeply nested than the @code{goto}.

That is, do @emph{not} do something like

@example
: f
    'x goto
    withTag x do@{ x @}
;    
@end example

@noindent
or

@example
: f -> lock
    withTag x do@{
        'x goto
        lock withLockDo@{ x @}
    @}
;    
@end example



@xref{withTags}.
@end deffn

@c
@node  if, listfor, goto, control structure syntax
@subsection if
@deffn Control-struct if @dots{} else @dots{} fi
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Muq @sc{muf}'s @code{if @dots{} else @dots{} fi} construct
follows the Forth tradition:

@example
Stack:
1 2 = if "1st\n" , else "2nd\n" , fi
2nd
Stack:
2 2 = if "1st\n" , else "2nd\n" , fi
1st
Stack:
2 2 = if "only\n" , fi
only
@end example

The @code{if} operator pops one value off the stack; if it
is non-@code{nil}, the first clause is evaluated, otherwise
the second clause (if present) is evaluated.
@end deffn

(I find curly braces inesthetic in the muf
@code{if-then-else} construct, and believe that using
@code{fi} as a terminator is both prettier and less
confusing to novices than the traditional use of @code{else}
as the terminator.)


@c
@node  listfor, neverInline, if, control structure syntax
@subsection listfor
@deffn Control-struct list LISTFOR val [cons] do@{ ... @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{listfor} loop sets @code{val} to a successive
element of @code{list} on each iteration.  The @code{val}
value is stored back into the list at the end of each
iteration, so you may use assignments to it to update the
list.  If @code{cons} is specified, it will be set to the
appropriate @code{cons} before each iteraction.

@example
Stack:
[ 'a' 'b' 'c' ]l listfor i do@{ i , "\n" , @}
'a'
'b'
'c'
Stack:
@end example

(Note that a special @code{vecfor} (say) is not needed,
because @code{foreach} works on all native Muq objects.)

@end deffn

@c
@node  neverInline, pleaseInline, listfor, control structure syntax
@subsection neverInline
@deffn Control-struct neverInline
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

CommonLisp functions may have any of three @code{inline}
attributes: The compiler may be forbidden to inline,
encouraged to inline, or left to its own devices.

A Muq @sc{muf} function containing the @code{neverInline}
operator results in a @emph{compiledFunction} with the
$s.neverInline property set @code{t}.
@end deffn

Function inlining is not yet (version -1.5.0) implemented in
the Muq @sc{muf} compilers, however.

@c
@node  pleaseInline, until, neverInline, control structure syntax
@subsection pleaseInline
@deffn Control-struct pleaseInline
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

I am reluctant to introduce text macros into Muq: The
problem is that text macros tend to be very
language-specific, and Muq is intended to be a multi-lingual
programming environment.

Any significant accumulation of header files containing
important information recorded as text macros could quickly
lead to a maintainance nightmare of trying to translate
these header files into formats suitable for other languages
on the system, and the prospect of loss of access to such
header files would pose a significant disincentive to
experimentation with new languages on Muq.

Inline functions seem a more attractive alternative.  Inline
functions can do much of what macros are usually used for
with equal efficiency, while remaining much more language-
independent: There is no obvious reason inline functions
coded in Muq @sc{muf} cannot be called from Muq Lisp, and vice
versa.

It is intended that @sc{muf} functions be flagged as
inline-expandable simply by including the keyword
@code{pleaseInline} somewhere in their body -- presumably
normally at or near the beginning.

The @sc{muf} compiler is not required to inline such
functions, but it is permitted and encouraged to do so.
@end deffn

Function inlining is not yet (version -1.5.0) implemented in
the Muq @sc{muf} compilers, however.


@c
@node  until, do, pleaseInline, control structure syntax
@subsection until
@deffn Control-struct until
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This construct provides a loop with a termination test at
any point:

@example
Stack: 1 2 3 4 5 6 7 8
do@{ 5 = until @}
Stack: 1 2 3 4
@end example

On each iteration, the @code{until} operator pops one value
off the stack: if that value is non-@code{nil}, control is
transferred to the first statement following the loop,
otherwise execution continues normally past the
@code{until}.

@xref{while}.
@end deffn


@c
@node  do, while, until, control structure syntax
@subsection do
@findex loopNext
@findex C continue
@findex loopFinish
@findex C break
@deffn Control-struct  do@{ @dots{} loopFinish @dots{} loopNext @dots{} @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Sometimes one wants the loop-termination test in the middle
of the loop.  @code{do@{ @dots{} @} } constitutes an
infinite loop.

The @code{loopFinish} operator is just like the C @code{break}
operator: It terminates the loop tranferring control to the code
following the loop.

The @code{loopNext} operator is just like the C @code{continue}
operator: It transfers control to the top of the loop, beginning the
next iteration: It is useful for quickly dismissing uninteresting cases
in favor of proceeding immediately to the next iteration of the loop.

@example
Stack:
0 10 for i do@{ i 1 logand 1 = if [ "%d is odd\n" i | ]print , fi @}
1 is odd
3 is odd
5 is odd
7 is odd
9 is odd
Stack:
@end example

Please note that @sc{muf} (following CommonLisp) @emph{does} have
functions named @code{break} and @code{continue}, but that they
are very different from their C namesakes. @xref{break}.
@xref{continue}.

@end deffn

@c
@node  while, withLockDo, do, control structure syntax
@subsection while
@deffn Control-struct while
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{while} operator is traditional in Forth, and is
equivalent to @code{not if loopFinish fi.}  It may be used
anywhere in a loop:

@example
Stack:
10 seq[
Stack: [ 0 1 2 3 4 5 6 7 8 9 |
do@{   |pop -> x   x |push   x 5 != while   |rotate   @}
Stack: [ 6 7 8 9 0 1 2 3 4 5 |
@end example

@xref{until}.
For more on @code{loopFinish}, see @ref{do}.
@end deffn


@c
@node  withLockDo, withRestartDo, while, control structure syntax
@subsection withLockDo
@findex withChildLockDo@{
@findex withParentLockDo@{
@deffn Control-struct withLockDo@{ @dots{} @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{withLockDo@{@dots{}@}} operator is the main Muq @sc{muf}
explicit synchronization mechanism:  The canonical code for
sequencing access to a small db by multiple jobs is

@example
makeIndex --> obj      ( Create db object proper.              )
makeLock --> obj.lock  ( Create a lock (semaphore) for db.     )
...                     (                                       )
obj.lock withLockDo@{   ( Block until we aquire the lock.       )
    ...                 ( Fiddle with the db.                   )
@}                       ( Release the lock.                     )
@end example

@xref{Class Lock}.
@xref{popLockframe}.
@xref{pushLockframe}.

Note that Muq streams provide implicit synchronization.
@xref{Class MessageStream}.

Fine point:
Attempting to acquire a lock which the job already
holds is essentially a no-op:  Execution continues
without pause.  The only effect is that a null
stackframe is pushed, to keep the subsequent
@code{popLockframe} instruction happy.

Fine point:
Since the point of a lock is that it can be held
by only one job at a time, when a job holding a
lock does a @code{copyJob}, only one of the resulting
two jobs should hold the lock.  By default, this
will be the parent.  If you wish to specify which
job should inherit the lock, you may use the syntax

@example
withChildLockDo@{ ... @}
@end example

to specify that the child should inherit the lock,
or

@example
withParentLockDo@{ ... @}
@end example

to specify that the parent should inherit the lock.
Currently, @code{withLockDo@{} is a synonym for
@code{withParentLockDo@{}.
@end deffn


@c
@node  withRestartDo, withHandlersDo, withLockDo, control structure syntax
@subsection withRestartDo
@deffn Control-struct ]withRestartDo@{ @dots{} @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]withRestartDo@{@dots{}@}} operator is
the current Muq @sc{muf} surface syntax for
executing code under the control of a specified
restart.  (@xref{Restarts}.)

The @sc{muf} syntax for establishing a restart is

@example
[ :name 'halt-and-catch-fire
  :function  :: halt-and-catch-fire ;
  :testFunction nil
  :interactiveFunction nil
  :reportFunction "Halt and catch fire"
  :data "<any user data value whatever>"
| ]withRestartDo@{
  @dots{}
@}
@end example

@noindent
where @code{nil} properties may be omitted.

The @code{:reportFunction} may be either a string, or
else a function accepting a stream and printing a
string to that stream.

Restarts intended for interactive use should have a
@code{:reportFunction} (which may be merely a string).
If @code{:function} takes no arguments, then @code{:interactiveFunction}
may be @code{nil}, otherwise @code{:function} should accept a single block
of arguments, and @code{:interactiveFunction} should be a function
which generates an appropriate argument block, typically by use of
the @code{queryFor*} functions (@pxref{user i/o functions}).

Note: The @code{:function} value needs to be of arity
@code{@{ -> @}} if the restart is to be invoked via
@code{invokeRestart}, and of arity @code{@{ [] -> @}}
if the restart is to be invoked via
@code{]invokeRestart}.  In particular, this means that
restart @code{:function}s exiting via a nonlocal
@code{goto} will usually need to be forced to the
appropriate arity.  Example:

@example
withTag my-tag do@{
    [   :function :: @{ -> ! @} 'my-tag goto ;
        :name 'my-restart
    | ]withRestartDo@{
        ...
    @}
@}
@end example

See @ref{Muq Events} for a general discussion of the
event system.

The @code{:data} value is a hook intended to be used
by user code to attach any desired information to a
restart: It may later be used by user-defined handlers
when selecting a restart to invoke.  It is ignored by
all software in the current standard Muq distribution.

@end deffn


@c
@node  withHandlersDo, withTags, withRestartDo, control structure syntax
@subsection withHandlersDo
@findex withHandlerDo
@deffn Control-struct ]withHandlersDo@{ @dots{} @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]withHandlersDo@{@dots{}@}} operator is
the current Muq @sc{muf} surface syntax for
executing code under the control of specified
event handlers.  (@xref{Handlers}.)

(The @code{]withHandlerDo@{@dots{}@}} operator is
a synonym for @code{]withHandlersDo@{@dots{}@}}.)

The syntax is

@example
[  event0  handler0
   event1  handler1
   ...
| ]withHandlersDo@{ ... @}
@end example

where:

@itemize @bullet
@item
Each @emph{event} must be an instance of Class
Event (@pxref{makeEvent}).

@item
Each @emph{handler} must be a @{ [] -> [] @} function
accepting a block describing the event,
and returning that block unchanged if it
returns at all.  (A handler which resolves the
event will normally not return.)
@end itemize

To prevent recursive handler disasters, when any
of the specified handlers is invoked, it is run in
a context in which the given handler bindings are
all effectively dis-established.  (Handler
bindings established by other
@code{]withHandlersDo@{} statements are of
course completely unaffected by this, even if they
specify the same handler functions.)

Example:  This calls a function @code{fn} with
a handler established that counts warnings.
Since the handler then returns normally, normal
warning handling is not otherwise affected:

@example
0 --> *warnings-seen*
[ .err.warning
  :: @{ [] -> [] ! @} ++ *warnings-seen* ;
| ]withHandlersDo@{
  fn
@}
@end example

Example: This prints a custom message on divide by zero,
then (by simply returning) lets the usual handler(s) take
over:

@example
[ .err.divisionByZero
  :: @{ [] -> [] ! @}
    "-Real- hackers don't divide by zero!\n" ,
  ;
| ]withHandlersDo@{
  1 0 /
@}
@end example

For a fuller discussion of events, see @ref{Muq
Events}.

@end deffn


@c
@node  withTags, return, withHandlersDo, control structure syntax
@subsection withTags
@cindex goto, in withTags
@deffn Control-struct withTags a b c do@{ 'a goto @dots{} a @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{withTags} syntax supports the @code{goto}
operator, which is primarily intended for
non-local tranfers of control from one function
to a calling function, used heavily by the
event handling system's @code{restart}s
(@pxref{Muq Events}).

The syntax is

@example
withTags @emph{tags} do@{ @emph{body} @}
@end example

@noindent
where @emph{tags} is a list of zero or more @code{goto}
target labels, and @emph{body} is the code scope in which
they are to be defined and usable.

If only one tag is used, the @code{withTag} synonym to
@code{withTags} may be used.

Examples:

Defining a single tag @code{x} and jumping to it:

@example
Stack:
withTag x do@{ "a\n" ,   'x goto   "b\n" ,   x   "c\n" ,   @}
a
c
Stack:
@end example

@noindent
Defining three tags @code{x, y, z} and jumping between them:

@example
Stack:
       withTags x y z do@{
----->   "a\n" , 
----->   'y goto 
-----> x 
----->   "b\n" ,
----->   'z goto
-----> y
----->   "c\n" ,
----->   'x goto
-----> z
----->   "d\n" ,
-----> @}
a
c
b
d
Stack:
@end example


@noindent
Finally, an example along the lines of how
@code{withTags} and @code{goto} are actually
intended to be used.  Jumping to a tag in an
enclosing function:

@example
Stack:
       : f -> arg
;---->   withTags x y do@{
----->     : g -> arg
;---->       arg if   'x goto   else   'y goto   fi
;---->     ;
----->     arg g
----->   x
----->     "x\n" ,
----->   y
----->     "y\n" ,
----->   @}
;----> ;
Stack:
nil f
y
Stack:
t f
x
y
Stack:
@end example

@end deffn


@c
@node  return, case, withTags, control structure syntax
@subsection return
@deffn Control-struct return
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{return} operator uneventally returns from the
current function.  Any return values should be in placed on
the stack before executing it.
@end deffn


@c
@node  case, asMeDo, return, control structure syntax
@subsection case
@deffn Control-struct case@{ on: k1 @dots{} on: k2 @dots{} else: @dots{} @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This construct is a multiway branch corresponding to the
Pascal @code{case} and C @code{switch} statements, except
that the constants may be any values, including strings.
(I've frequently wished that C allowed string keys in
@code{switch}!) The @sc{muf} version also has the advantage
of being able to return a value, unlike either the C or
Pascal versions.  (Ansi Forth has a multiway branch also,
but its semantics seem twisted enough to cause continual
problems for novice programmers; After some thought, I
decided to break new ground.)

@example
Stack:
: xlt @{ $ -> $ @} case@{ on: 1 "one" on: 2 "two" else: "many" @} ;
Stack:
1 xlt
Stack: "one"
pop 2 xlt
Stack: "two"
pop 3 xlt
Stack: "many"
@end example

The @code{case@{} operator pops one value off the stack
and compares it with all provided @code{on:} constants until
it finds a match.  If it finds a match, it executes the
associated code clause; otherwise, it executes the
@code{else:} code clause, if present.
@end deffn

The current @sc{muf} compilers produce code which simply
scans all @code{on:} clauses in order until a match is
found: It may be wise to put the most frequently used cases
first if speed is an issue.

Note that, unlike C, the @sc{muf} @code{case@{} statement
does not require that clauses be separated by @code{break}
operators.  This feature of C tends to cause obscure bugs,
to puzzle newcomers (particularly those trained on Pascal),
and to add unneeded verbosity: Try translating the above
one-liner into C.


@c
@node  asMeDo, rootAsUserDo, case, control structure syntax
@subsection asMeDo
@deffn Control-struct asMeDo@{ @dots{} @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This construct allows you to write a function which can be
called by other people, but which will execute with your
privileges when they call it.  This is the standard way of
extending the access other people have to your objects.

This construct saves the current value of
@code{@@$s.actingUser} on the loop stack, then sets
@code{@@$s.actingUser} to the owner of the currently
executing function.  Upon exit from the construct, the
original value of @code{@@$s.actingUser} is restored.

Functions using this construct should be very carefully
written and do a very clearly defined task: If you make a
mistake, you may wind up granting everyone full access to
all your objects, the ability to send mail under your name,
and so forth.

Functions using this construct and owned by root should be
@emph{extremely} carefully written and do an
@emph{extremely} clearly defined, simple task: Every such
function is part of the "security kernel" of your system,
which is only as secure as the least secure function of this
kind.  It only takes @emph{one} carelessly written one-line
@code{asMeDo@{@dots{}@}} function owned by root to
eliminate all security and privacy on a complete Muq system.

On any well-administered Muq system, there should be at
least one administrator who knows exactly where all the
root-owned @code{asMeDo} functions are, exactly what each
one does, and who either makes or is informed of all
modifications to these functions.  I considered having the
server force all such functions to be stored on some
particular object, but decided this was inconsistent with
the design goal of a policy-free server.  I do think you
would be wise to pick some spot like @code{.u["root"].asMeDo}
and in it keep a pointer to all such functions.

@xref{pushUserMeFrame}.  @xref{popUserFrame}.

@end deffn


@c
@node  rootAsUserDo, rootOmnipotentlyDo, asMeDo, control structure syntax
@subsection rootAsUserDo
@deffn Control-struct user rootAsUserDo@{ @dots{} @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error will be signaled if @code{@@$s.actingUser} is not
of Class Root.  (In the usual Muq configuration, the only
instance of Class Root is @code{.u["root"]}.)

This construct allows you to write a function which executes
with the privileges of an arbitrary other user.  This is the
preferred way for a system administrator to fiddle with the
property of a particular user.

This construct saves the current value of
@code{@@$s.actingUser} on the loop stack, then sets
@code{@@$s.actingUser} to the value supplied at top of
stack.  Upon exit from the construct, the original value of
@code{@@$s.actingUser} is restored.

@xref{rootPushUserFrame}.
@xref{rootOmnipotentlyDo}.
@xref{popUserFrame}.
@xref{asMeDo}.

@end deffn


@c
@node  rootOmnipotentlyDo, conversion functions, rootAsUserDo, control structure syntax
@subsection rootOmnipotentlyDo
@deffn Control-struct rootOmnipotentlyDo@{ @dots{} @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error will be signaled if @code{@@$s.actingUser} is not
of Class Root.  (In the usual Muq configuration, the only
instance of Class Root is @code{.u["root"]}.)

This construct allows you to write a function which executes
with essentially no security restrictions at all.
Obviously, this is very dangerous and should be done very
carefully indeed and only when truly needed: The surface
syntax is intentionally clumsy to discourage frivolous use.
When practical, use the somewhat less dangerous
@code{rootAsUserDo}: @xref{rootAsUserDo}.

This construct saves the current value of @code{jS.j.privs},
an internal C-level privilege word, on the loop stack, then
sets the @code{omnipotent} bit in @code{jS.j.privs}.  Upon
exit from the construct, the original value of
@code{jS.j.privs} is restored.

@xref{rootPushPrivsOmnipotentFrame}.
@xref{popPrivsFrame}.
@xref{asMeDo}.

@end deffn


@c
@node conversion functions, charInt, rootOmnipotentlyDo, Core Muf
@section conversion functions

@menu
* charInt::
* chars2Int::
* chars4Int::
* intChar::
* intChars2::
* intChars4::
* charString::
* stringInt::
* stringKeyword::
* dbrefToInts3::
* ints3ToDbref::
* dbnameToInt::
* intToDbname::
* upcase::
* downcase::
@end menu

@c
@node  charInt, chars2Int, conversion functions, conversion functions
@subsection charInt
@defun charInt @{ char -> int @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{charInt} function converts a character to an
integer with the corresponding (@sc{ascii}) display code.
@end defun

@c
@node  chars2Int, chars4Int, charInt, conversion functions
@subsection chars2Int
@defun chars2Int @{ char0 char1 -> int @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{chars2Int} function converts a pair of characters
to an integer @code{char0<<8 + char1}.  This is intended
primarily for converting short integers recieved through
a @sc{tcp} or @sc{udp} network connection into usable
form.
@end defun

@c
@node  chars4Int, intChar, chars2Int, conversion functions
@subsection chars4Int
@defun chars4Int @{ char0 char1 char2 char3 -> int @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{chars4Int} function converts a quad of
characters to an integer @code{char0<<24 + char1<<16 +
char2<<8 +char3}.  This is intended primarily for
converting integers recieved through a @sc{tcp} or
@sc{udp} network connection into usable form.

Note that since Muq integers are only 31 bits, it
is possible to lose one bit of precision at the
high end by doing this.
@end defun

@c
@node  intChar, intChars2, chars4Int, conversion functions
@subsection intChar
@defun intChar
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{intChar} function converts an integer to a
character with the corresponding (@sc{ascii}) display code.
The result is undefined if no such equivalent character
exists.
@end defun

@example
Stack: "Joshua Christ"@footnote{"Jesus" is Greek translation, "Joshua" the original.}
stringInts[
Stack: [ 74 111 115 104 117 97 32 67 104 114 105 115 116 |
|for c do@{ c intChar -> c @}
Stack: [ 'J' 'o' 's' 'h' 'u' 'a' ' ' 'C' 'h' 'r' 'i' 's' 't' |
|for c do@{ c charInt -> c @}
Stack: [ 74 111 115 104 117 97 32 67 104 114 105 115 116 |
]join
Stack: "Joshua Christ"
@end example

@c
@node  intChars2, intChars4, intChar, conversion functions
@subsection intChars2
@defun intChars2 @{ int -> char0 char1 @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{intChars2} function converts an integer
characters to a pair of chars, @code{int>>8 & 0xFF, int & 0xFF}.
This is intended primarily for converting integers into
a form suitable to send through a @sc{tcp} or
@sc{udp} network connection.

@end defun

@c
@node  intChars4, charString, intChars2, conversion functions
@subsection intChars4
@defun intChars4 @{ int -> char0 char1 char2 char3 @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{intChars4} function converts an integer
to four characters, @code{int>>24 & 0xFF,
int>>16 & 0xFF, int>>8 & 0xFF, int & 0xFF}.
This is intended primarily for converting integers into
a form suitable to send through a @sc{tcp} or
@sc{udp} network connection.

@end defun

@c
@node  charString, stringInt, intChars4, conversion functions
@subsection charString
@defun charString @{ char -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{charString} function converts a character
into a length-one string containing just that character:

@example
Stack:
'a'
Stack: 'a'
charString
Stack: "a"
@end example
@end defun

@c
@node  stringInt, stringKeyword, charString, conversion functions
@subsection stringInt
@defun stringInt @{ string -> int @}
@findex atoi
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{stringInt} function converts a string
into an integer, much like the C @code{atoi()}
function (which is currently used in the
implementation):

@example
Stack:
"123"
Stack: "123"
stringInt
Stack: 123
@end example

@end defun

@c
@node  stringKeyword, dbrefToInts3, stringInt, conversion functions
@subsection stringKeyword
@defun stringKeyword @{ string -> keyword @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{stringKeyword} function converts a string
into a keyword with the same name:

@example
Stack:
"abc"
Stack: "abc"
stringKeyword
Stack: :abc
@end example

Be aware that it is almost impossible to get rid of a
keyword once created, so creating zillions of them is likely
to permanently bloat the database.
@end defun


@c
@node  dbrefToInts3, ints3ToDbref, stringKeyword, conversion functions
@subsection dbrefToInts3
@defun dbrefToInts3 @{ dbref -> i0 i1 i2 @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Let a @emph{dbref} be any of the 32-bit values
which Muq actually stores in variables and stack
slots.  (Dbrefs may be short integers or
floats and pointers to objects, among other things.)

The @code{dbrefToInts3} function converts an arbitrary
Muq dbref.   The only intended use of this primitive
is to allow the transmission and storage of the resulting integers,
with eventual reconstitution of the dbref via
@emph{ints3ToDbref}.

@xref{ints3ToDbref}.
@xref{|debyte}.

@end defun


@c
@node  ints3ToDbref, dbnameToInt, dbrefToInts3, conversion functions
@subsection ints3ToDbref
@defun ints3ToDbref @{ i0 i1 i2 -> tOrNil dbref @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{ints3ToDbref} function is the inverse
of @code{dbrefToInts3}, converting the three
integers back to a dbref if possible, and
returning @code{tOrNil} as @code{t} if
successful, @code{nil} otherwise.  (Possible
reasons for failure include garbled input, input
from another db, or the indicated object having
been garbage-collected since the integers were
created.)

@xref{dbrefToInts3}.
@xref{|enbyte}.

@end defun


@c
@node  dbnameToInt, intToDbname, ints3ToDbref, conversion functions
@subsection dnameToInt
@defun dbnameToInt @{ string -> int @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This is a fairly esoteric internal function.  Muq internally uses 21-bit
fields to identify database files, but externally uses an @sc{ascii}
representation of this number in the filename, a six-character string
consisting approximately of a string of four all lower-case (user db
file) or all upper-case (system db file) alphabetic characters, usually
padded with a couple of dashes.

This function converts from the string representation to the integer
representation.  Invalid strings are silently coerced to something
reasonable.

For readability (and to avoid "------" being ambiguous) database id zero
(the root db) is special-cased as "ROOTDB".

@example
Stack:
"lisa" dbnameToInt
Stack: 1291847
intToDbname
Stack: "lisa--"
pop 0 intToDbname
Stack: "ROOTDB"
pop "LISP" dbnameToInt intToDbname
Stack: "LISP--"
dbnameToInt 1 + intToDbname
Stack: "LISQ--"
@end example

@xref{intToDbname}.

@end defun


@c
@node  intToDbname, downcase, dbnameToInt, conversion functions
@subsection intToDbname
@defun intToDbname @{ int -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is the inverse of @code{dbnameToInt}.

@xref{dbnameToInt}.

@end defun


@c
@node  downcase, upcase, intToDbname, conversion functions
@subsection downcase
@defun downcase @{ any -> any @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

If the input is a character it is converted to the
corresponding lowercase value.  If it is a small
positive integer interpretable as an ASCII character,
the corresponding integer conversion is done.
In all
other cases, nothing is done.

@xref{|downcase}.
@xref{stringDowncase}.

@end defun


@c
@node  upcase, db functions, downcase, conversion functions
@subsection upcase
@defun upcase @{ any -> any @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

If the input is a character it is converted to the
corresponding uppercase value.  If it is a small
positive integer interpretable as an ASCII character,
the corresponding integer conversion is done.
In all
other cases, nothing is done.

@xref{|upcase}.
@xref{stringUpcase}.

@end defun


@c
@node db functions, db functions overview, upcase, Core Muf
@section db functions
@cindex Db functions

@menu
* db functions overview::
* db pragmatics::
* rootMakeDb::
* rootExportDb::
* rootImportDb::
* rootRemoveDb::
* rootReplaceDb::
* db functions wrapup::
* db functions future directions::
@end menu

@c
@node  db functions overview, db pragmatics, db functions, db functions
@subsection db functions overview

The state of an individual Muq server is stored in a single @code{.muq}
which is logically separated into a number of "databases", typically
one per user plus one for each major system library or
dataset.  (These may be thought of as being roughly parallel
to the separate disk partitions of a unix file system, with
their ability to be independently mounted and unmounted.)

These logical databases may be "exported" as independent host files,
which are given the extension @code{.db} to distinguish them from
the master @code{.muq} server state file.

The resulting @code{.db} files may then in turn be "imported" back
into the master Muq @code{.muq} file at a later date, or may be
transported to other systems and imported into servers there.

This means that @code{.db} files may serve as a universal
interchange format within the Muq world: Any combination of
code and data, no matter how large or complex, may be this
means be passed from one system to another and there
accessed without the usual inconveniences of going through
an obscuring layer of API access functions: The installed
code and data is directly accessable without further ado.

This is a distinct improvement on the typical contemporary
arrangement of hundreds of different datafile formats, each
of which addresses only a narrow range of datastructures
(and typically no code at all), and each of which requires
use of a different, clumsy API in order to gain access to
the file contents:  With luck, this reduced cost of
code and data interchange within the Muq world will lead
directly to a higher level of cooperative interchange.



@c
@node  db pragmatics, rootMakeDb, db functions overview, db functions
@subsection db pragmatics

Each db is named internally by a 21-bit number:  Internally
within server, every 64-bit logical pointer references an
object includes this number.

For human consumption, these numbers are usually encoded as
four-letter names, such as "joe" or "LISP".  By a convention
supported by the Muq server, uppercase names are used for
standard system libraries, and lowercase names are used for
local users and libraries:  By respecting this convention
on your system, you minimize chances of incompatibilities
between your local server state and future standard
libraries which may become available.

The set of databases installed in a given server may be listed out
from the @sc{muf} commandline:

@example
root: 
.db ls
"ANSI"	#<Db ANSI 3b6580000001c15>
"DBUG"	#<Db DBUG 9dbe00000001c15>
"DICT"	#<Db DICT a6c900000001c15>
"DIFI"	#<Db DIFI a6ec00000001c15>
"GEST"	#<Db GEST 1154380000001c15>
"KEYW"	#<Db KEYW 1af5c00000001c15>
"LISP"	#<Db LISP 1db2b00000001c15>
"LNED"	#<Db LNED 1e18680000001c15>
"MUC"	#<Db MUC 211d280000001c15>
"MUF"	#<Db MUF 211fb00000001c15>
"MUFV"	#<Db MUFV 2120600000001c15>
"OMSH"	#<Db OMSH 2542d80000001c15>
"OMUD"	#<Db OMUD 2544680000001c15>
"PUB"	#<Db PUB 2851980000001c15>
"QNET"	#<Db QNET 2a1c600000001c15>
"QNETA"	#<Db QNETA 6afbe80000001c15>
"RMUD"	#<Db RMUD 2c79b00000001c15>
"ROOTDB"	#<Db ROOTDB 3d15>
"TASK"	#<Db TASK 3035080000001c15>
"TLNT"	#<Db TLNT 312bb00000001c15>
"muqn"	#<Db muqn a129680000001c15>
root: 
@end example

The above system has no user accounts, consisting almost
entirely of system libraries:

@enumerate
@item ANSI
A small experimental library of ansi-terminal cursor
positioning (&tc) functions.

@item DBUG
The Muq debugger.

@item DICT
Lists of words 1024 long, used by Muq password routines.

@item DIFI
Constants and functions for the Diffie-Hellman public key
support code.

@item GEST
Db used to hold known users on other systems -- "guests".

@item KEYW
Db used to hold system keywords -- @code{:xyzzy} in @sc{muf}
notation.

@item LISP
Db used to hold the lisp compiler and runtimes.

@item LNED
Db used to hold a small experimental line editor.

@item MUC
Db used to hold the Multi-User C compiler, shell and runtimes.

@item MUF
Db used to hold the Multi-User Forth compilers, shells and
runtimes -- this holds the bulk of the core Muq support
softcode.

@item MUFV
Db intended to hold all the variables needed by the @sc{muf}
db, so that the @sc{muf} can be read-only.  There are
probably still variables in the @sc{muf} db.

@item OMSH
Db holding the Micronesia "oldmud" user shell code.

@item OMUD
Db holding the Micronesia "oldmud" worldkit code.

@item PUB
I forget!

@item QNET
Db holding the Muqnet transparent networking support code.

@item QNETA
Db intended to hold the mutable data for the Muqnet db, so
as to allow @sc{qnet} to eventually be read-only.

@item RMUD
Db parts of the "oldmud" worldkit which need to be root
privileged.  In principle, the other oldmud libraries should
be installable owned by an unprivileged account, although
this is not yet done and probably not yet possible in
practice.

@item ROOTDB
This is the root db for the server, corresponding to the
root partition @code{/} on a unix filesystem:  It is
deliberately given a six-letter name (otherwise impossible)
to emphasize its specialness.  (The actual decimal db number
is zero.)  Since it is risky to modify this db, and
impossible to dismount it, it should be kept simple,
stable and small.

@item TASK
This db contains the "task" support logic used by the
Micronesia worldkit to handle Muqnet callback archiving
and invocation.

@item TLNT
This db contains the @sc{telnet} protocol support code and
data, used to support user telnet logins.
@end enumerate

Here is an occasionally useful facility:  The 'private'
propdir on db objects lists all existing objects in that db.
This means that you may do

@example
root:
.db["MUF"] lsh
@end example

to list absolutely everything in the @sc{muf} db -- every
string, every object, every vector, every bignum, every
b-tree block, everything.

This is usually not a good idea!

But writing loops similar to that used by @code{lsh} can
be a useful way of gathering statistics on space
consumption:
  
@example
root: 
0 -> symbols   .db["MUF"] foreachHidden key do@{ key symbol? if ++ symbols fi @}   "symbols=" , symbols , "\n" ,
symbols=1638
root: 
@end example


Here is a simple example of creating a new db, creating a
package inside it, creating a value in that package,
exporting the db as a Muq @code{.db} file, removing the db from the server, and
then importing the @code{.db} file back into the server to
recreate the db and its contents:

@example
root: 
[ "mydb" | rootMakeDb ]pop            ( Create a db 'mydb' )
root: 
[ "mypkg" .db["mydb"] | ]inPackage    ( Create a package inside mydb )
mypkg: 
13 1300 makeVector --> myvec          ( Create a 1300-slot vector in mypkg )
mypkg: 
"root" inPackage                      ( Return to home package )
root: 
[ .db["mydb"] | rootExportDb ]pop     ( Write 'mydb' contents to a host .db file )
root: 
[ .db["mydb"] | rootRemoveDb ]pop     ( Remove 'mydb' db from main server .muq file )
root: 
[ "mydb"      | rootImportDb ]pop     ( Read .db hostfile in, recreating 'mydb'. )
root: 
mypkg::myvec[0]                       ( Verify 'myvec' exists in 'mypkg' in 'mydb'. )
root: 13
@end example




@c
@node  rootMakeDb, rootExportDb, db pragmatics, db functions
@subsection rootMakeDb
@defun rootMakeDb @{ [dbId] -> [dbId] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Create a new db.  The input @code{dbId} may be a string,
an integer, or nil.  If it is nil, the server picks an
unused name for the db.  If it is a string or integer,
the server accepts them as name hints and tries to
assign the new db a name as close as possible to the
hint.

The return value is the dbId actually selected, as
a string:  It may be used to index the global
@code{.db[]} index to locate the actual created
db object.

Note that @code{rootMakeUser} creates a new db, owned
by the new user, as part of its operation:
@xref{rootMakeUser}.

@end defun

@c
@node  rootExportDb, rootImportDb, rootMakeDb, db functions
@subsection rootExportDb
@defun rootExportDb @{ [ db ] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a db and writes its contents out as
a host @code{.db} file.

The usual way to obtain the required db object is to
index into the internal @code{.db[]} index:

@example
root:
[ .db["MUF"] | rootExportDb ]pop
@end example

@end defun

@c
@node  rootImportDb, rootRemoveDb, rootExportDb, db functions
@subsection rootImportDb
@defun rootImportDb @{ [dbId] -> [dbId] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a db designation, either as a
(typically four-letter) string or as an integer, and
attempts to import the corresponding host @code{.db}
file:

@example
root:
[ "xyz" | rootImportDb ]pop
root: 
@end example

The above command will search for host files under the names
@example
muq-CURRENT-xyz.db
muq-CURRENT-xyz.db.gz
muq-CURRENT-xyz.db.lzo
muq-CURRENT-xyz.db.bz2
@end example
and load the first one found, uncompressing as needed (presuming the appropriate
decompression program can be located).

If the imported db contains pointers to objects in other dbs
which existed on the exporting system but are missing from
the current server, such pointers will be replaced by
@code{nil}s.  If these pointers occurred in critical spots,
these substitutions may cripple index or other
datastructures in the db, or even crash the server later
on.

Also, it is relatively easy for the imported db to forge
pointers to objects it would not normally be able to
access.

In general, Muq is not currently intended to be secure
or stable in the face of importation of maliciously
constructed .db files:  You should import .db files
only from reasonably trusted sources.

A future version of this function should probably optionally
accept a full host filename as input argument.

If the db in question already exists within the server,
you must use @code{rootReplaceDb} instead of
@code{rootImportDb}.  (It would be easy enough to combine
these into one function, but keeping them separate may
reduce the incidence of unfortunate accidents.)

@xref{rootReplaceDb}.
@end defun

@c
@node  rootRemoveDb, rootReplaceDb, rootImportDb, db functions
@subsection rootRemoveDb
@defun rootRemoveDb @{ [db] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function removes the given db from the server state,
which essentially means removing all the information
nassociated with that db from the currently open
@code{.muq} file:

@example
root:
[ .db["mydb"] | rootRemoveDb ]pop
root:
@end example

All references from other dbs to objects in the deleted
db will be replaced by @code{nil}s:  If there are such
references in critical spots, these new @code{nil}s
may (say) cripple an index object or even crash the server.

The implementation attempts to catch and prevent common
cases of this, and will likely be upgraded to catch
additional cases in the future, but caution and good sense
are advised.

If you are primarily trying to upgrade a db, it is usually a
bad idea to do @code{rootRemoveDb} followed immediately by
@code{rootImportDb} because this sequence is guaranteed to
break (replace by @code{nil}) all pointers from outside the
db into it: It is better to do @code{rootReplaceDb}, which
will leave these pointers intact if reasonably possible.

@xref{rootReplaceDb}.

@end defun

@c
@node  rootReplaceDb, db functions wrapup, rootRemoveDb, db functions
@subsection rootReplaceDb
@defun rootReplaceDb @{ [db] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function replaces the contents of the given db with
those taken from the corresponding host @code{.db} file.

The result is similar to that obtainable by doing a
@code{rootRemoveDb} followed immediately by a matching
@code{rootImportDb}, except that doing a
@code{rootReplaceDb} instead will usually leave intact
pointers from outside the db into it, whereas the former
sequence is guaranteed to set all such pointers to
@code{nil}.

@example
root:
[ .db["mydb"] | rootReplaceDb ]pop
root:
@end example

The @code{rootReplaceDb} may be used to either upgrade
or roll back ("downgrade"?) a db:  It doesn't care which.

The replacement @code{.db} file must currently have (in the
case of the above example) one of the names

@example
muq-CURRENT-xyz.db
muq-CURRENT-xyz.db.gz
muq-CURRENT-xyz.db.lzo
muq-CURRENT-xyz.db.bz2
@end example

A future version of this function will probably allow
specification of an arbitrary host filename (if not
pathname) for the @code{.db} file.

@xref{rootRemoveDb}.
@xref{rootImportDb}.

@end defun

@c
@node  db functions wrapup, db functions future directions, rootReplaceDb, db functions
@subsection db functions wrapup

The db functions should be used with caution.

Removing a db from the server can disrupt datastructures and running
processes due to the suddenly missing objects.  The server tries to
catch simple, common cases of this, but there remain many ways of
crashing or crippling the server this way.

Installing a db is a bit like injecting fluid into the body with
a hypodermic needle:  The normal system defenses are bypassed, and
various security or reliability problems may result.  For instance,
it is fairly easy to craft a malicious .db file which will forge
pointers to data which would not normally be available to a user.
A .db file may also overwrite a system package pointer with an
inappropriate new package, subverting existing in-db software.


@c
@node  db functions future directions, debug support functions, db functions wrapup, db functions
@subsection db functions future directions

Good handling of persistent data and related issues is Muq's
greatest single strength, and future releases will continue
to focus upon this.

Improvements which I expect to introduce roughly in the year
2000-2001 timeframe include:

@itemize @bullet
@item
Supporting objects up through about 64Mbytes in size -- current
limit is 64K.

@item
Supporting variable size objects -- currently size of an
object is fixed at creation, at least in terms of the
fundamental vm.t diskbase layer facilities.

@item
Mapping @code{.muq} files into memory.  This will speed
db open and close (particularly of uncompressed dbs) and
somewhat speed up disk I/O on large objects, but primarily
it will enable the following.

@item
Communicating with other processes via shared-memory access
to @code{.muq} files.  This will allow high-bandwidth
communication with a variety of helper applications, such
as lapack operations and sound, still and video
I/O and transformations via large shared arrays.

@item
Mounting (as opposed to importing) @code{.db} files, in
particular large, static read-only @code{.db} files.  This
would be an appropriate way of making large datasets such
as MRI voxel datasets, gene sequence data, image libraries
and such available to softcode without having to actually
copy them into the master @code{.muq} file and duplicate
their contents at each backup of the @code{.muq} file.

@item
More sophisticated garbage collection -- this is critical
to working effectively with datasets larger than physical
memory workingset.  Options include going to a multi-generation
garbage collection scheme, going to an incremental scheme
-- likely based on Dijkstra's three-color algorithm -- or
a combination of the two.  Ideally, garbage collection
pauses should become too short to be noticable to
interactive users doing 3D graphics &tc.

@item
True incremental backup, so that (ideally, at least) the
server continues to run without noticable pauses during
backup operations.

@end itemize

In a slightly longer timeframe, it would be good to
investigate input journalling, so as to be able to
back up and reproduce a run exactly -- very handy
for debugging, among other things.


@c
@node debug support functions, disassembleCompiledFunction, db functions future directions, Core Muf
@section debug support functions
@cindex Debug support functions

The following functions are of interest mainly to people
writing new in-db debuggers for Muq.

@menu
* disassembleCompiledFunction::
* compiledFunctionBytecodes[::
* compiledFunctionConstants[::
* compiledFunctionDisassembly::
* programCounterToLineNumber::
@end menu

@c
@node  disassembleCompiledFunction, compiledFunctionBytecodes[, debug support functions, debug support functions
@subsection disassembleCompiledFunction
@defun disassembleCompiledFunction @{ cfn stream -> @}
@display
@exdent file: 15-C-debugger.t
@exdent package: debug
@exdent status: tentative
@end display

This function accepts a @code{compiledFunction}
and lists a human-readable disassembly of it
to the given stream.  It is intended
to be invoked by (for example) a debugger.

Note that the Muq bytecode instruction set is
@emph{not} frozen, and should @emph{not} be
depended on to be the same in future releases.
@strong{You have been warned!}

@example
stack:
: x234 2 3.4 * ;
stack:
#'x234 @@$s.standardOutput debug:disassembleCompiledFunction
name: x234
source: 2 3.4 *
constants:
 0: 3.39999
code bytes:
00: 33 02 34 00 0e 2e 
code disassembly:
000:      33 02       GETi   2
002:      34 00       GETk   0
004:      0e          MUL    
005:      2e          RETURN 
@end example

It is currently implemented as:

@example
: disassembleCompiledFunction @{ $ $ -> @} -> s -> cfn
    cfn isACompiledFunction

    ( Do a nice disassembly of a compiled function for human consumption: )

    cfn$s.source -> fn
    fn function? if

        fn$s.name -> name
        name string? if
            "name: "   s writeStream
            name       s writeStream
            "\n"       s writeStream
        fi

        fn$s.source -> src
        src  string? if
            "source: " s writeStream
            src        s writeStream
            "\n"       s writeStream
        fi
    fi

    "constants:\n" s writeStream
    cfn compiledFunctionConstants[
        |for v i do@{
            [ "%2d: " i | ]print  s writeStream
            v toDelimitedString s writeStream
            "\n"                  s writeStream
        @}
    ]pop
    
    "code bytes:" s writeStream
    cfn compiledFunctionBytecodes[    
        |for v i do@{
            i 15 logand 0 = if [ "\n%02x: " i | ]print s writeStream fi
            [ "%02x " v | ]print                       s writeStream
        @}
    ]pop
    "\n" s writeStream

    "code disassembly:\n"             s writeStream
    cfn compiledFunctionDisassembly s writeStream
;
@end example

@end defun

@c
@node  compiledFunctionBytecodes[, compiledFunctionConstants[, disassembleCompiledFunction, debug support functions
@subsection compiledFunctionBytecodes[
@defun compiledFunctionBytecodes[ @{ cfn -> [bytecodes| @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

This function accepts a @code{compiledFunction}
and returns a block containing all bytecodes in
the compiled code, as one integer per eight-bit
bytecode.

Note that the Muq bytecode instruction set is
@emph{not} frozen, and should @emph{not} be
depended on to be the same in future releases.
@strong{You have been warned!}

This is a low-level function intended for use by
debuggers rather than for direct human use.

@example
stack:
: x234 2 3.4 * ;
stack:
#'x234 compiledFunctionBytecodes[
stack: [ 51 2 52 0 14 46 |
@end example
@end defun

@c
@node  compiledFunctionConstants[, compiledFunctionDisassembly, compiledFunctionBytecodes[, debug support functions
@subsection compiledFunctionDisassembly
@defun compiledFunctionConstants[ @{ cfn -> [constants| @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

This function accepts a @code{compiledFunction}
and returns a block containing all constants
stored in the @code{compiledFunction}.

This is a low-level function intended for use by
debuggers rather than for direct human use.

@example
stack:
: ad "abc" "def" join ;
stack:
#'ad compiledFunctionConstants[
stack: [ "abc" "def" |
@end example
@end defun

@c
@node  compiledFunctionDisassembly, programCounterToLineNumber, compiledFunctionConstants[, debug support functions
@subsection compiledFunctionDisassembly
@defun compiledFunctionDisassembly @{ cfn -> text @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

This function accepts a @code{compiledFunction}
and returns a symbolic disassembly of the bytecodes
in that function.

Note that the Muq bytecode instruction set is
@emph{not} frozen, and should @emph{not} be
depended on to be the same in future releases.
@strong{You have been warned!}

This is a low-level function intended for use by
debuggers rather than for direct human use.

@example
stack:
: x234 2 3.4 * ;
stack:
#'x234 compiledFunctionDisassembly ,
000:      33 02       GETi   2
002:      34 00       GETk   0
004:      0e          MUL    
005:      2e          RETURN 
stack:
@end example
@end defun

@c
@node  programCounterToLineNumber, function definition syntax, compiledFunctionDisassembly, debug support functions
@subsection programCounterToLineNumber
@defun programCounterToLineNumber @{ pc fn -> line-number @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function converts an integer program counter value
(typically obtained via @code{getStackframe[} as the
@code{:programCounter} value in a @code{:normal}
stackframe) to the corresponding source code line
number for the function.

Note that by convention, these line numbers start at
zero for the first line in the function: Users normally
expect line numbers to start at one, so it is normal to
add one before displaying this value.

If line number relative to the source file as a whole
is desired, @code{fun$s.fileLine} should be added
also.

@xref{getStackframe[}.
@xref{assembler functions}.
@end defun

@c
@node function definition syntax, Named functions, programCounterToLineNumber, Core Muf
@section function definition syntax
@cindex Function definition syntax

@menu
* Named functions::
* Arity declarations::
* Nested functions::
* Recursive functions::
* Anonymous functions::
* Thunks::
* Promises::
@end menu

@c
@node  Named functions, Arity declarations, function definition syntax, function definition syntax
@subsection function definition syntax
@findex :
@findex defineWord:

A good notation makes things look simple by making common
operations concise.  It is good programming practice to make
heavy use of function definitions @footnote{The inventor of
Forth insists that no function should be longer than two
lines!}.

In any event, Forth does an admirable job of making function
definitions simple, cheap and concise, and Muq @sc{muf} attempts
to preserve that heritage:

@example
Stack:
: hi "Hello!\n , ;
Stack:
hi hi hi
Hello!
Hello!
Hello!
Stack:
: thrice 3 * ;
Stack:
13 thrice
Stack: 39
thrice
Stack: 117
thrice
Stack: 351
@end example

The first word after the colon is the name of the new
function; The remaining words up until the @code{;} form the
definition of the function: Once the function is defined,
entering its name is about the same as entering all the code
in its body.

Muq @sc{muf} allows @code{defineWord:} as a synonym for
@code{:}, regarding the latter as an abbreviation of the
former.  Ada programmers and lawyers may prefer the former
name @emph{grin} @dots{}


@c
@node  Arity declarations, Nested functions, Named functions, function definition syntax
@subsection Arity declarations
@cindex Arity declaration
@findex @{

It is traditional Forth programming practice to include at
the start of each function a comment giving the number of
arguments it accepts and returns.  (This sort of
documentation is a good habit in any language.)

Muq @sc{muf} continues this tradition, but extends it by
making the declarations in a syntax understandable to the
muf compiler, as do most modern languages other than Forth:

@example
Stack:
: x @{ $ $ -> $ @} * ;
Stack:
2 3 x
Stack: 6
@end example

The arity declaration is enclosed in curly braces and
contains one '$' for each input parameter, followed by an
arrow, followed by one dot for each value returned.

Muq distinguishes single arguments from blocks of arguments:

@example
Stack:
: |double   @{ [] -> [] @}   |for i do@{ i 2 * -> i @}   ;
Stack:
5 seq[
Stack: [ 0 1 2 3 4 |
|double
Stack: [ 0 2 4 6 8 |
@end example

The arity declaration contains one @code{[]} for each block
read, and one for each block returned.  Block arguments must
in each case precede nonblock arguments.


@c
@node  Nested functions, Recursive functions, Arity declarations, function definition syntax
@subsection Nested functions
@cindex Nested functions

Many Algolic languages, such as Pascal, allow functions to
be declared inside other functions, so as to be visible only
inside that function.  The Muq @sc{muf} compiler also allows
this:

@example
Stack:
: print2 -> n   : p -> i [ "%d\n" i | ]print , ;   n p n p ;
Stack:
13 print2
13
13
Stack:
13 p

**** Sorry: No such variable: 'p'

Stack:
@end example


@c
@node  Recursive functions, Anonymous functions, Nested functions, function definition syntax
@subsection Recursive functions
@cindex Recursive functions

Forth has traditionally not handled recursion nicely,
functions being disallowed from calling themselves
naturally.

Muq @sc{muf} allows this sort of recursion quite naturally.
Here is the venerable factorial function:

@example
Stack:
: fact @{ $ -> $ @} -> i   i 1 = if  i  else  i 1- fact i *  fi ;
Stack:
3 fact
Stack: 6
@end example

Note: This example also doesn't compile on version -1.0.0.  Ick.


@c
@node  Anonymous functions, Thunks, Recursive functions, function definition syntax
@subsection Anonymous functions
@cindex Anonymous functions

The practical power of a software system is largely a
function of the freedom with which a basis set of
pre-existing functions can be combined to span a
combinatorial space of possible computations: The search for
increased programming power has driven a relentless trend
toward ever more flexible ways of combining ever shorter
functions, currently reaching some sort of apogee in the
functional programming community.

A natural result of this trend to shorter functions used as
building blocks in large computations is that many functions
are created simply to be immediately passed to other
functions.  Requiring that such functions be given names
only contributes to syntantic clutter.

The Muq @sc{muf} syntax for declaring an anonymous function
is identical to that for a named function, except that a
double colon replaces the single colon, the name is dropped,
and the compiled function is left on the stack:

@example
Stack:
:: "Hi mom!\n" , ;
Stack: <c-fn _>
call
Hi mom!
Stack:
@end example

Note: This example also doesn't work quite right on Muq
version -1.0.0.  Thpt!


@c
@node  Thunks, Promises, Anonymous functions, function definition syntax
@subsection Thunks
@cindex Thunks

When the result of a computation depends on a changing
context, it is often sensible to delay computation of a
result until the last possible instant, so as to produce a
result as up-to-date as possible.

If the code using the value is not aware that it is runtime
computed, however, this can often be difficult to arrange,
and can result in a maze of twisty little functions once it
@emph{has} been arranged.

Muq @sc{muf}'s answer to this design problem is the
@dfn{thunk:} A chunk of code which may be freely copied
around and stored in variables, properties and so forth, but
which will be transparently evaluated and replaced by its
result as soon as any computation depending on its value is
attempted@footnote{The name 'thunk' comes from the
implementation of call-by-name semantics in Algol68, where
the name purportedly derived from the notion that the
function didn't have to think about the value because the
compiler had already thunk about it@dots{}}.

Thunks have the same syntax as anonymous functions, except
that the double colon is replaced by @code{star-colon}:
@example

Stack:
*: 2 3 + ;
Stack: <thunk>
1+
Stack: 6
@end example
Implementation of thunks presents some interesting security
problems @dots{} @emph{grin}.


@c
@node  Promises, job control functions, Thunks, function definition syntax
@subsection Promises
@cindex Promises

Promises are quite similar to thunks, but are intended to
implement context-free computations@footnote{The 'promise'
nomenclature derives from Scheme.}.  Since the result of the
computation doesn't depend on when it is performed, there is
no reason to waste @sc{cpu} time computing it more than
twice, so promises are guaranteed to evaluate at most once,
subsequent invocations merely returning a saved copy of the
original result:

@example
Stack:
1: 2 3 + ;
Stack: <thunk>
1+
Stack: 6
@end example

Promises are completely unimplemented as of Muq version -1.0.0.


@c
@node job control functions, job control overview, Promises, Core Muf
@section job control functions
@cindex Job control functions

@menu
* job control overview::
* copyJob::
* copyJobset::
* copySession::
* debugOff::
* debugOn::
* endJob::
* switchJob::
* exec::
* forkJob::
* forkJobset::
* forkSession::
* pauseJob::
* pidToJob::
* queueJob::
* runJob::
* sleepJob::
* abortJob::
* killJob::
* killJobMessily::
* exitShell::
@end menu

@c
@node  job control overview, copyJob, job control functions, job control functions
@subsection job control overview

The Muq multitasking model deliberately sticks fairly close
to that of unix, both to avoid borrowing trouble in a tricky
area by adopting a well-tested design, and to facilitate
transfer of user expertise between Muq and unix.

A single flow of control within Muq -- a program counter
plus a stack, if you will -- is termed a @dfn{job}.  A job
corresponds loosely to a unix @emph{process}, except that it
lacks a separate address space; A unix @emph{thread} is in
that respect a closer analogy.

Several jobs performing a single conceptual task (much like
a unix pipeline) are grouped together into a @dfn{jobset},
corresponding to a unix @emph{process group}.  Jobsets
provide us with a convenient way of (for example) stopping
or killing all of the jobs in a pipeline, something which
might otherwise be tedious and error-prone.

The group of jobsets executing for a single user connected
via a single login are grouped toegether into a
@dfn{session}, corresponding to a unix @emph{session}.
Sessions provide us with a convenient way of killing all the
jobs associated with a login if the network connection is
lost, and a place to record which jobset is currently titled
to read and write interactively to the user -- the
@dfn{foreground jobset}.

Muq jobs communicate and are controlled by a signal
mechanism closely modelled on the unix signal mechanism, as
well as via message streams which are loosely modelled on
unix pipes, and via the db, which even more loosely
corresponds to the unix filesystem.

Note: Muq signals are likely to change substantially as Muq
is brought more into line with the CommonLisp
exception-handling standard.


@c
@node  copyJob, copyJobset, job control overview, job control functions
@subsection copyJob
@deffn Control-struct copyJob @{ name -> job @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{copyJob} operator is somewhat like the
unix @code{fork} operator: The return value is @code{nil} in
the child job and is the child job itself in the parent.

Unlike unix @code{fork}, the @code{copyJob} does not
immediately schedule the child to run:  Instead, it
is placed in the owner's @code{pauseQueue}. @xref{forkJob}.

Note: @code{copyJob} currently does not copy
over properties in the propdirs.  This is
probably a bug, but I don't want single
bytecodes doing unlimited amounts of work,
locking up the server for an indefinite
period.

@end deffn


@c
@node  copyJobset, copySession, copyJob, job control functions
@subsection copyJobset
@deffn Control-struct copyJobset @{ name -> job @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{copyJobset} operator is just like the
@code{copyJob} operator, except that in addition to
copying the current job, it also copies the current jobset,
and places the child job alone in the new jobset.  (This
avoids the race events in the equivalent unix
operation.)  The child job sees a @code{nil} return value;
The parent job gets back the child job.  @xref{forkJobset}.

Note: @code{copyJobset} currently does not copy
over properties in the propdirs.  This is
probably a bug, but I don't want single
bytecodes doing unlimited amounts of work,
locking up the server for an indefinite
period.

@end deffn


@c
@node  copySession, debugOff, copyJobset, job control functions
@subsection copySession
@deffn Control-struct copySession @{ name -> job @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{copySession} operator is just like the
@code{copyJobset} operator, except that in addition to
copying the current jobset, it also copies the current
session, and places the child jobset alone in the new
session.  The child job sees a @code{nil} return value; The
parent job gets back the new job. @xref{forkSession}.

Note: @code{copySession} currently does not copy
over properties in the propdirs.  This is
probably a bug, but I don't want single
bytecodes doing unlimited amounts of work,
locking up the server for an indefinite
period.

@end deffn


@c
@node  debugOff, debugOn, copySession, job control functions
@subsection debugOff
@defun debugOff @{ -> @}
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{debugOff} convenience function sets the current job to
@strong{not} enter the debugger if an exception is raised and not
handled automatically.

This is the recommended state for daemon processes, but not
for user shells.

This function is currently defined as
@example
:   debugOff @{ -> @}   nil --> @@$s.breakEnable  ;
@end example

@xref{debugOn}.
@end defun


@c
@node  debugOn, endJob, debugOff, job control functions
@subsection debugOn
@defun debugOn @{ -> @}
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{debugOn} convenience function sets the current job to enter
the debugger if an exception is raised and not handled automatically.

This is the recommended state for user shells, but not (obviously) for
daemons.

This function is currently defined as
@example
:   debugOn @{ -> @}   t --> @@$s.breakEnable  ;
@end example

@xref{debugOff}.
@end defun


@c
@node  endJob, switchJob, debugOn, job control functions
@subsection endJob
@deffn Control-struct endJob @{ nil -> @@ @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{endJob} operator corresponds to the unix
@code{exit()} function.  It takes one argument which is
intended to be used like the corresponding @code{exit()}
argument, which currently must be @code{nil}, and it kills the
job which executed it.
@end deffn


@c
@node  switchJob, exec, endJob, job control functions
@subsection switchJob
@deffn Control-struct switchJob @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{switchJob} operator ends the current
Muq timeslice, reliquishing control of the Muq
virtual machine to any other job waiting to run.

Since the Muq virtual machine implements
pre-emptive multitasking, there is rarely any
reason to use @code{switchJob}.

One possible use is when busy-waiting on
some other job:  Doing a @code{switchJob}
after each check can minimize wasted CPU
time and maximize the other job's chance
of completing the task.

In general, of course, use of busy-waiting is
strongly discouraged.  It is, however,
occasionally useful in test or system code.

@end deffn


@c
@node  exec, forkJob, switchJob, job control functions
@subsection exec
@deffn Control-struct exec @{ fn -> @@ @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{exec} operator corresponds to the unix
@code{exec*()} functions.  It takes one argument which must
be a @code{compiledFunction} or a symbol with a
@code{compiledFunction} functional value.  The current loop
and data stack contents are cleared, and the function is
then called.  Thus, the function should take no arguments,
and since when it returns the job will terminate, it cannot
really return any arguments either.

In order to do an @code{exec}, @code{@@$s.actingUser}
must equal @code{@@$s.actualUser}, or else must be
root running with the @sc{omnipotent} bit set.

The function will normally be some sort of interactive
readEvalPrint loop with an @code{abort} restart so the
user can return to the loop.
@end deffn


@c
@node  forkJob, forkJobset, exec, job control functions
@subsection forkJob
@deffn Control-struct forkJob @{ name -> job @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{forkJob} operator is a simple convenience
which does a @code{copyJob} and then runs the child,
yielding something closer to the unix semantics.

It is currently implemented as:

@example

: forkJob   @{ $ -> $ @} -> name
    name copyJob -> j
    j if j runJob fi
    j
;
@end example

@xref{copyJob}.
@end deffn


@c
@node  forkJobset, forkSession, forkJob, job control functions
@subsection forkJobset
@deffn Control-struct forkJobset @{ name -> job @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{forkJobset} operator is a simple convenience
which does a @code{copyJobset} and then runs the child,
yielding something closer to the unix semantics.

It is currently implemented as:

@example
: forkJobset   @{ $ -> $ @} -> name
    name copyJobset -> j
    j if j runJob fi
    j
;
@end example

@xref{copyJobset}.
@end deffn


@c
@node  forkSession, pauseJob, forkJobset, job control functions
@subsection forkSession
@deffn Control-struct forkSession @{ name -> job @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{forkSession} operator is a simple convenience
which does a @code{copySession} and then runs the child,
yielding something closer to the unix semantics.

It is currently implemented as:

@example
: forkSession   @{ $ -> $ @} -> name
    name copySession -> j
    j if j runJob fi
    j
;
@end example

@xref{copySession}.
@end deffn


@c
@node  pauseJob, pidToJob, forkSession, job control functions
@subsection pauseJob
@deffn Control-struct pauseJob @{ job -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{pauseJob} operator is a simple convenience
which looks up the pause queue for the given
job, and then calls @code{queueJob} on it.

It is currently implemented as:

@example
: pauseJob @{ $ -> @}     -> job
    job$s.owner          -> owner
    owner$s.pauseQueue  -> q
    job q queueJob
;
@end example

@end deffn


@c
@node  pidToJob, queueJob, pauseJob, job control functions
@subsection pidToJob

@defun pidToJob @{ pid -> job @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{pidToJob} function accepts an integer pid
such as displayed by @code{pj}, and returns a corresponding
job.  (Pids are assigned sequentially from the global
counter @code{.muq$s.nextPid}, which means it is
possible but normally unlikely for a two running jobs to
have the same pid.  Pids are stored as @code{job$s.name}.)

It is currently implemented as:
@example
: pidToJob @{ $ -> $ @} -> pid

    ( Generate block of all non-killed )
    ( jobs owned by current user:      )
   me$s.psQueue jobQueueContents[

        ( Over all entries in block: )
        |for j do@{

            j$s.name pid = if ]pop j return fi
        @}
    ]pop 

    [ "No job with pid %d." pid | ]print simpleError
;
@end example

@xref{pj rootPj}.

@end defun

@defun maybePidToJob @{ pid -> job @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This convenience function calls @code{pidToJob} on
integer arguments while leaving other arguments
unchanged;  It is useful in implementing functions
which indifferently accept either a job or a pid
as input.

It is currently implemented as:
@example
: maybePidToJob @{ $ -> $ @} -> pid

    pid integer? if   pid pidToJob -> pid   fi

    pid
;
@end example
@end defun


@c
@node  queueJob, runJob, pidToJob, job control functions
@subsection queueJob
@deffn Control-struct queueJob @{ job jobQueue -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{queueJob} operator removes @code{job} from
whatever job-queues it is currently in, and then
inserts it into @code{jobQueue}.  Moving a job into
some arbitrary jobQueue is one way to stop it from
running.  (It may get woken by signals, however.)
Moving it into a ``run'' jobQueue (for example,
@code{me$s.runQueue1}) is a way to start it running
again.

(Note: Since there are actually multiple run-queues
for each user, and a job should always go in the queue
matching its priority, the @code{queueJob} operator
silently puts the job in the right jobQueue, even if
it is not the one specified.)

@example
Stack:
makeJobQueue --> q
Stack:
copyJob dup if --> j j q queueJob else pop 2000 sleepJob nil endJob fi
Stack:
j me$s.runQueue0 queueJob
Stack:
@end example

Here, the @code{copyJob} line leaves job @code{j} in
suspended animation in jobQueue @code{q}, and the
next line releases it and lets it run to completion.
You can use the @code{printJobs} (@code{pj}) command
to observe jobstate.
@end deffn

@c
@node  runJob, sleepJob, queueJob, job control functions
@subsection runJob
@deffn Control-struct runJob @{ job -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{runJob} operator is a simple convenience
which looks up a run queue for the given
job, and then calls @code{queueJob} to run it.

It is currently implemented as:

@example
: runJob @{ $ -> @}   -> j
    j$s.owner        -> o
    o$s.runQueue1  -> q ( Doesn't matter which runQueue we pick. )
    j q queueJob
;
@end example

@end deffn

@c
@node  sleepJob, abortJob, runJob, job control functions
@subsection sleepJob
@deffn Control-struct sleepJob
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{sleepJob} operator puts the currently executing
job to sleep for @code{n} milliseconds, by setting
@@$s.sleepUntilMillisec to the current date plus @code{n} and then
moving it to the .etc.doz job queue:

@example
Stack:
10000 sleepJob "*yawn* Morning already?\n" ,
*yawn* Morning already?
Stack:
@end example

Unlike unix, sleeping jobs sent signals will process them
and then return to sleep until the designated time; I expect
this will make coding simpler for novice programmers.
@end deffn


@c
@node  abortJob, killJob, sleepJob, job control functions
@subsection abortJob
@defun abortJob @{ job -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{abortJob} function provides a way of
resetting well-behaved jobs to their main
interpreter loop:  It simply signals
a @code{.err.abort} event to
the job.

It is currently implemented as:

@example
: abortJob @{ $ -> @}   -> j
    [ :event .err.abort :job j | ]signal
;
@end example

@end defun


@c
@node  killJob, killJobMessily, abortJob, job control functions
@subsection killJob
@defun killJob @{ job -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{killJob} is intended to be the normal,
civilized way of shutting down an unwanted job.
It simply signals a @code{.err.kill} event to
the job:  Well-behaved jobs will respond by cleaning
up and exiting.  @xref{killJobMessily}.

It is currently implemented as:

@example
: killJob @{ $ -> @}   -> j
    [ :event .err.kill :job j | ]signal
;
@end example

@end defun


@c
@node  killJobMessily, exitShell, killJob, job control functions
@subsection killJobMessily
@defun killJobMessily @{ job -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{killJobMessily} operator is intended to allow
killing any Muq job, even one run wild, refusing signals,
or looping in @code{after@{@}alwaysDo@{}@} clauses.  Since
it shuts down jobs without allowing @code{after@{@}alwaysDo@{}@}
clauses to execute, and hence can leave damaged datastructures
behind, it should be used only as a last resort.
@xref{killJob}.
@xref{endJob}.
@end defun

@c
@node  exitShell, keyval functions, killJobMessily, job control functions
@subsection exitShell
@defun exitShell @{ -> @}
@display
@exdent file: 14-C-muf-shell.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{exitShell} function provides a way of
exiting from well-behaved shells.  This can be
useful if the shell was invoked interactively
from another shell;  Otherwise, it will probably
leave you with a dead line connection.

It is currently implemented as:

@example
: exitShell @{ -> @@ ! @}
   'muf:exitShell goto
;
@end example

@end defun



@c
@node keyval functions, keyval functions overview, exitShell, Core Muf
@section keyval functions
@cindex Keyval functions

@menu
* keyval functions overview::
* ]keysvalsSet::
* ]keysSet::
* delKey::
* delKey?::
* get::
* getFirstKey?::
* getKey?::
* getKeysByPrefix[::
* getNextKey?::
* get?::
* keys[::
* keysvals[::
* set::
* vals[::
* functions for nonpublic keyvals::
@end menu

@c
@node  keyval functions overview, ]keysvalsSet, keyval functions, keyval functions
@subsection keyval functions overview

A primary Muq metaphor is that of objects viewed as sets of
keyValue pairs.  In essence, objects are two-column
relations, the relation being one of the most fundamental
and flexible mathematical structures.  The restriction to
two columns is mildly inelegant, but not serious given that
the value column may be a vector; From a relational
perspective, the Muq implementation restriction to only
indexing on the key column is considerably more serious.

This section documents the fundamental Muq primitives for
manipulating the contents of objects.  Higher-level
facilities such as the @code{for} operator are built on top
of these, and will frequently be found to be more convenient
that using the prims directly.

Five parallel sets of primitives are provided, one set each
for the five sets of keyVal pairs on Muq objects: public,
hidden, system, admins.  We document the public
set in detail, then briefly list the other sets.


@c
@node  ]keysvalsSet, ]keysSet, keyval functions overview, keyval functions
@subsection ]keysvalsSet
@defun ]keysvalsSet
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]keysvalsSet} function takes a block of keyval
pairs, and stores them in the public area on the given object:

@example
Stack:
makeIndex --> o
Stack:
[ "a" 1   "b" 2   "c" 3 | o ]keysvalsSet
Stack:
o.a o.b o.c
Stack: 1 2 3
@end example

Note: This function is not implemented in Muq version -1.0.0.
@end defun


@c
@node  ]keysSet, delKey, ]keysvalsSet, keyval functions
@subsection ]keysSet
@defun ]keysSet
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]keysSet} function takes a block of values and stores
them in the public area on the given object, each as a key
having itself as a value::

@example
Stack:
makeIndex --> o
Stack:
[ "a" "b" "c" | o ]keysSet
Stack:
o.a o.b o.c
Stack: "a" "b" "c"
@end example

Note: This function is not implemented in Muq version -1.0.0.
@end defun


@c
@node  delKey, delKey?, ]keysSet, keyval functions
@subsection delKey
@defun delKey
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{delKey} function takes a an object and a
key, and removes that key from that object:

@example
Stack:
makeIndex --> o
Stack:
1 --> o.a
Stack:
o.a
Stack: 1
o "a" delKey
Stack: 1
o.a

**** Sorry: Unrecognized identifier: 'o.a'

@end example
@xref{delKey?}.
@end defun


@c
@node  delKey?, get, delKey, keyval functions
@subsection delKey?
@defun delKey?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{delKey?} function takes a an object and a
key, and removes that key from that object.  It
returns the previous value of that key on top of
a success/failure flag:

@example
Stack:
makeIndex --> o
Stack:
1 --> o.a
Stack:
o.a
Stack: 1
pop o "a" delKey?
Stack: t 1
o.a

**** Sorry: Unrecognized identifier: 'o.a'

@end example
@xref{delKey}.
@end defun


@c
@node  get, getFirstKey?, delKey?, keyval functions
@subsection get
@defun get
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{get} function takes a an object and a
key, and returns the corresponding public value:

@example
Stack:
makeIndex --> o
Stack:
1 --> o.a
Stack:
o "a" get
Stack: 1
@end example
Note: @code{get} throws an error if the key is not present.
@xref{get?}.

Note: Path notation is frequently more convenient, but
@code{get} is more general, since the key can be any value
whatever.  Path notation actually compiles into applications
of this and related function.
@end defun


@c
@node  getFirstKey?, getKey?, get, keyval functions
@subsection getFirstKey?
@defun getFirstKey?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getFirstKey?} function takes a an object and
key, and returns the corresponding public value (or
else @code{nil}), on top of a boolean flag recording whether
any keys were present:

@example
makeIndex --> o
Stack:
o getFirstKey?
Stack: nil nil
pop pop   1 --> o.a   o getFirstKey?
Stack: t "a"
@end example
@end defun


@c
@node  getKey?, getKeysByPrefix[, getFirstKey?, keyval functions
@subsection getKey?
@defun getKey? @{ obj val -> tOrNil key @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getKey?} function takes an object and a
value, and returns the corresponding public key (or
else @code{nil}), on top of a boolean flag recording whether
such a value was present:

@example
makeIndex --> o
Stack:
1 --> o["a"]   o 1 getKey?
Stack: t "a"
@end example
Note: Muq version -2.9.0 @code{getKey?} does not support
searching of objects.

The @code{getKey?} function may also be used to search
vectors and stacks for a given value, returning the
corresponding key (offset).  Vectors are searched starting
at offset zero, stacks are searched starting at the top.

This function does nothing that could not be done equally
easily in muf, but it puts the inner loop down in C, hence
may run a couple of orders of magnitude faster.
@end defun


@c
@node  getKeysByPrefix[, getNextKey?, getKey?, keyval functions
@subsection getKeysByPrefix[
@defun getKeysByPrefix[
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getKeysByPrefix[} function takes an object and
a string, and returns all public keys on the object which
start with the given string.  If any key matches the string
exactly, only that key is returned, even if other keys have
the string as a prefix.

This is intended to be useful for command
interpreters which allow abbreviation of commands to any
unique prefix:  The presumption is that an exact match
will be executed, but a multiple matches will result in
querying the user to select one of the alternatives.

This search could easily be coded in @sc{muf},
but can run much faster in C:

@example
makeIndex --> o
Stack:
1 --> o.a   1 --> o.ba   1 --> o.bb   1 --> o.c
Stack: 
o "b" getKeysByPrefix[
Stack: [ "ba" "bb" |
@end example

@end defun


@c
@node  getNextKey?, get?, getKeysByPrefix[, keyval functions
@subsection getNextKey?
@defun getNextKey?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getNextKey?} function takes an object and
a key, and returns the next public key on the object (else
@code{nil}) on top of a flag recording whether a nest key was
found:

@example
makeIndex --> o
Stack:
1 --> o.a   1 --> o.ba   1 --> o.bb   1 --> o.c
Stack: 
o "ba" getNextKey?
Stack: t "bb"
pop pop   o "c" getNextKey?
Stack: nil nil
@end example

Note: it is usually more convenient to use higher-level
operators built on top of this one.  @xref{for}.
@end defun


@c
@node  get?, keys[, getNextKey?, keyval functions
@subsection get?
@defun get? @{ obj key -> found val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{get?} function takes an object and a key, and
returns the corresponding public value on the object (else
@code{nil}) on top of a flag recording whether the key was found:

@example
makeIndex --> o
Stack:
1 --> o.a
Stack: 
o "a" get?
Stack: t 1
pop pop   o "z" get?
Stack: nil nil
@end example

Note: This function is mostly useful when you care about the
difference between a key which is missing, and one which has
@code{nil} as a value.

@xref{get}.
@xref{functions for nonpublic keyvals}.
@end defun


@c
@node  keys[, keysvals[, get?, keyval functions
@subsection keys[
@defun keys[
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{keys[} function takes an object and pushes a
block consisting of all public keys on the object:

@example
makeIndex --> o
Stack:
1 --> o.a   2 --> o.b   3 --> o.c
Stack: 
o keys[
Stack: [ :a :b :c |
@end example

Note: The keys currently arrive sorted, but Muq does not promise
to retain this in future versions.  Do a @code{|sort} if you need
them sorted.
@end defun


@c
@node  keysvals[, set, keys[, keyval functions
@subsection keys[
@defun keysvals[
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{keysvals[} function takes an object and pushes a
block consisting of all public keyVal pairs on the object:

@example
makeIndex --> o
Stack:
1 --> o.a   2 --> o.b   3 --> o.c
Stack: 
o keysvals[
Stack: [   :a 1   :b 2   :c 3   |
@end example

Note: The pairs currently arrive sorted, but Muq does not
promise to retain this in future versions.  Do a
@code{|keysvalsSort} if you need them sorted.
@end defun


@c
@node  set, vals[, keysvals[, keyval functions
@subsection set
@defun set
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{set} function takes an object and a keyVal
pair and stores the keyVal pair in the public area
of the object:

@example
makeIndex --> o
Stack:
1 o "a" set
Stack: 
o keysvals[
Stack: [ "a" 1 |
@end example

Note: Path notation is usually more convenient, but the
@code{set} function is more general in that any value may be
used as the key.  Path notation compiles into code which
includes this or a related function.
@end defun


@c
@node  vals[, functions for nonpublic keyvals, set, keyval functions
@subsection vals[
@defun vals[
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{vals[} function takes an object and pushes a
block consisting of all public values on the object:

@example
makeIndex --> o
Stack:
1 --> o.a   2 --> o.b   3 --> o.c
Stack: 
o vals[
Stack: [ 1 2 3 |
@end example
@end defun


@c
@node  functions for nonpublic keyvals, lisp library, vals[, keyval functions
@subsection functions for nonpublic keyvals
@findex ]hiddenKeysvalsSet      
@findex ]hiddenSet               
@findex hiddenDelKey                
@findex hiddenDelKey?           
@findex hiddenGet                
@findex hiddenGetFirstKey?     
@findex hiddenGetKey?           
@findex hiddenGetKeysByPrefix[
@findex hiddenGetNextKey?      
@findex hiddenGet?               
@findex hiddenKeys[              
@findex hiddenKeysvals[          
@findex hiddenSet                
@findex hiddenVals[              
@findex ]systemKeysvalsSet          
@findex ]systemSet                   
@findex systemDelKey                    
@findex systemDelKey?
@findex systemGet                    
@findex systemGetFirstKey?         
@findex systemGetKey?               
@findex systemGetKeysByPrefix[    
@findex systemGetNextKey?          
@findex systemGet?                   
@findex systemKeys[                  
@findex systemKeysvals[              
@findex systemSet                    
@findex systemVals[                  
@findex ]adminsKeysvalsSet         
@findex ]adminsSet                  
@findex adminsDelKey                    
@findex adminsDelKey?
@findex adminsGet                   
@findex adminsGetFirstKey?        
@findex adminsGetKey?              
@findex adminsGetKeysByPrefix[   
@findex adminsGetNextKey?         
@findex adminsGet?                  
@findex adminsKeys[                 
@findex adminsKeysvals[             
@findex adminsSet                   
@findex adminsVals[                 

@findex muqnetDelKey                    
@findex muqnetDelKey?
@findex muqnetGet                   
@findex muqnetGetFirstKey?        
@findex muqnetGetKey?              
@findex muqnetGetKeysByPrefix[   
@findex muqnetGetNextKey?         
@findex muqnetGet?                  
@findex muqnetKeys[                 
@findex muqnetKeysvals[             
@findex muqnetSet                   
@findex muqnetVals[                 

The above functions all manipulate keyval pairs in the
public area of a given object.  Exactly analogous
functions are available to manipulate keyval pairs
in the other three areas of an object:

@example
]hiddenKeysvalsSet        ]systemKeysvalsSet          
]hiddenSet                 ]systemSet                   
hiddenDelKey              systemDelKey                    
hiddenDelKey?             systemDelKey?
hiddenGet                  systemGet                    
hiddenGetFirstKey?       systemGetFirstKey?         
hiddenGetKey?             systemGetKey?               
hiddenGetKeysByPrefix[  systemGetKeysByPrefix[    
hiddenGetNextKey?        systemGetNextKey?          
hiddenGet?                 systemGet?                   
hiddenKeys[                systemKeys[                  
hiddenKeysvals[            systemKeysvals[              
hiddenSet                  systemSet                    
hiddenVals[                systemVals[                  

]adminsKeysvalsSet         
]adminsSet                  
adminsDelKey                    
adminsDelKey?
adminsGet                   
adminsGetFirstKey?        
adminsGetKey?              
adminsGetKeysByPrefix[   
adminsGetNextKey?         
adminsGet?                  
adminsKeys[                 
adminsKeysvals[             
adminsSet                   
adminsVals[                 
@end example

In addition, a special series is present for muqnet support, which
differ in that an extra final integer argument explicitly specifies
which propdir is intended, and in that they are executed with the
permissions of @code{.u["nul"]} rather than of the current user:

@example
]muqnetKeysvalsSet        
]muqnetSet                 
muqnetDelKey              
muqnetDelKey?             
muqnetGet                  
muqnetGetFirstKey?       
muqnetGetKey?             
muqnetGetKeysByPrefix[  
muqnetGetNextKey?        
muqnetGet?                 
muqnetKeys[                
muqnetKeysvals[            
muqnetSet                  
muqnetVals[                
@end example

@c
@node lisp library, lisp library overview, functions for nonpublic keyvals, Core Muf
@section lisp library
@cindex lisp library

@menu
* lisp library overview::
* read::
* lisp library wrapup::
@end menu

@c
@node  lisp library overview, read, lisp library, lisp library
@subsection lisp library overview
@cindex lisp library overview

Functions in this section are intended to be called
directly from Lisp, hence they all obey the Lisp
convention of always accepting and returning a
block.  In this section, we use Lisp syntax for
describing parameters and return values, rather
than the usual @sc{muf} syntax.

There is nothing wrong with calling these functions
from @sc{muf}.

@c
@node  read, lisp library wrapup, lisp library overview, lisp library
@subsection read
@defun read @{ &optional stream eof-err-p eof-val recursiveP -> val @}
@display
@exdent file: 00-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{read} function reads characters from input stream
@code{stream}, which it interprets according to lisp syntax,
constructing and returning a lisp value @code{val}.

@end defun

@c
@node  lisp library wrapup, list functions, read, lisp library
@subsection lisp library wrapup



@c
@node list functions, list functions overview, lisp library wrapup, Core Muf
@section list functions
@cindex list functions

@menu
* list functions overview::
* ]::
* car::
* cdr::
* cons::
* caar &tc::
* append::
* assoc::
* copyAlist::
* copyList::
* copyTree::
* delete::
* deleteIf::
* deleteIfNot::
* eighth::
* end?::
* fifth::
* first::
* fourth::
* getprop::
* last::
* length::
* length2::
* list::
* dottedList::
* listLength::
* mapc::
* mapcan::
* mapcar::
* mapcon::
* mapl::
* maplist::
* member?::
* nconc::
* ninth::
* nreverse::
* nsublis::
* nsubst::
* nsubstIf::
* nsubstIfNot::
* nth::
* nthcdr::
* printList::
* putprop::
* rassoc::
* remove::
* removeIf::
* removeIfNot::
* remprop::
* rest::
* reverse::
* rplaca::
* rplacd::
* second::
* seventh::
* sixth::
* sublis::
* subseq::
* subst::
* substIf::
* substIfNot::
* tenth::
* third::
@end menu

@c
@node  list functions overview, ], list functions, list functions
@subsection list functions overview
@cindex list functions overview
@cindex Lisp lists
@cindex Lists, lisp

A @dfn{List}, in the computer science sense of the term,
consists of a sequence of cells, each of which has two
pointers, one to a value, one to the next cell in the list:

@example
           +--------------+
List  -->  |   car     -------------> first value
           |--------------|
           |   cdr   |    |
           +-------- | ---+
                     |
                     V
           +--------------+
           |   car     -------------> second value
           |--------------|
           |   cdr   |    |
           +-------- | ---+
                     |
                     V
           +--------------+
           |   car     -------------> third value
           |--------------|
           |   cdr        |
           +--------------+
@end example

The List data structure is logically a binary tree (or graph
-- the pointers are permitted to form loops) but is usually
interpreted as a sequence.  Since the values may themselves
be Lists, arbitrary logical tree structures may easily be
constructed.

Lists are used very heavily in classical artificial
intelligence programming and such offshoots as expert
systems and functional programming languages.

Muq will eventually have a full complement of List
functions, but for now has just the following (partly
because many others are more appropriately coded in-db).

List cells are logically vectors of length two, but it is
worth making them a different data type, if only to
facilitate more appropriate prettyprinting of List
structures.  In additiona, CommonLisp requires that they be
separate data types.

@c
@node  ], car, list functions overview, list functions
@subsection ]
@defun ]
@display
@exdent file: 00-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{]} function constructs a List from a given
set of arguments:

@example
Stack:
[ 1 2 3 ]l --> lst
Stack: 
lst first
Stack: 1
lst second
Stack: 1 2
lst third
Stack: 1 2 3
@end example

This is the closest @sc{muf} comes to Lisp's @code{'(1 2 3)}
notation for quoted lists.

Note that no '|' is used, that such lists may be nested,
and that (unlike quoted lists in Lisp) all the arguments
are evaluated, and may in fact be arbitrary expressions.

Thus, to construct a list of symbols, you must do

@example
Stack:
[ 'a 'b 'c ]
@end example

instead of merely

@example
Stack:
[ a b c ]
@end example

@xref{list}.

The similar @code{]v} function builds a vector rather
than a list.

The related @code{]i16} @code{]i32} @code{]f32} and @code{]f64} functions
build vectors specialized to containing (respectively) shorts, ints,
floats and doubles.

@end defun

@c
@node  car, cdr, ], list functions
@subsection car
@defun car
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{car} function takes a List cell as argument, and
returns the contents of the car field:

@example
Stack:
"a" "d" cons
Stack: <cons>
car
Stack: "a"
@end example

@end defun

Modern languages often use more logical names like
@code{head} or @code{first} for this function.

Historical note: @code{car} stands for "Contents of Address
Register", referring to the machine instruction used to
implement this in the first Lisp, on an IBM 704 at MIT in
the late 1950s.)


@c
@node  cdr, cons, car, list functions
@subsection cdr
@defun cdr
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{cdr} function takes a List cell as argument, and
returns the contents of the cdr field:

@example
Stack:
"a" "d" cons
Stack: <cons>
cdr
Stack: "d"
@end example

This function is usually pronounced "could'er".

Modern languages often use more logical names like
@code{tail} or @code{rest} for this function.

Historical note: @code{cdr} stands for "Contents of
Decrement Register", referring to the machine instruction
used to implement this in the first Lisp, on an IBM 704 at
MIT in the late 1950s.)
@end defun


@c
@node  cons, caar &tc, cdr, list functions
@subsection cons
@findex econs
@findex ephemeralCons
@defun cons
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{cons} function takes two values and constructs a
List cell containing them as it's @code{car} and @code{cdr}:
@example
Stack:
"a" "d" cons -> cell
Stack: 
cell car   cell cdr
Stack: "a" "d"
@end example

The name is short for "construct", since it constructs a
@code{cons} cell, the basic unit of storage in classical
lisp systems.

List cells are often called "cons cells", since they are
constructed by @code{cons}, or simply "conses", and the
process of constructing them is often called "consing".
@end defun

@quotation
It is possible to implement arbitrary programs using only
@code{cons} to modify memory; This train of thought leads to
the pure-functional programming community.  If this
intrigues you, you might grab a Haskell implementation from
cs.yale.edu or join the mailing list via
haskell-request@@cs.yale.edu.
@end quotation

You may sometimes wish to allocate a cons cell
on the stack instead of on the heap:  The function
@code{ephemeralCons} will do this.  For brevity,
it is also available under the synonym @code{econs}.
The usual cautions pertaining to ephemerals
apply: @xref{]makeEphemeralVector}.

@c
@node  caar &tc, append, cons, list functions
@subsection caar &tc
@defun caar @{ cons -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

CommonLisp defines a number of abbreviation functions:

@example
caar       Same as car car
cadr       Same as car cdr
cdar       Same as cdr car
...        ...
cdaddr     Same as cdr car cdr cdr
...        ...
@end example

All combinations of up to four @code{car} or @code{cdr}
operators are defined in this way.
@end defun

@c
@node  append, assoc, caar &tc, list functions
@subsection append
@defun append @{ listA listB -> newlist @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{append} function returns a list which is the
concatenation of listA and listB.  All the cells in listA
are copied; listB is shared.  (Thus, @code{a nil append} is
an antique way of copying list @code{a}.)

@example
Stack:
[ 'a' 'b' ]l [ 'c' 'd' ]l append --> list
Stack:
list first  list second  list third  list fourth
Stack: 'a' 'b' 'c' 'd'
@end example

@xref{nconc}.
@end defun

@c
@node  assoc, copyAlist, append, list functions
@subsection assoc
@defun assoc @{ key list -> keyval @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

An @dfn{association list} is a list of cells containing
key/val pairs in their car/cdr slots:

@example
Stack:
[ key0 val0 cons   key1 val1 cons   key2 val2 cons ]l   --> list
@end example

Association lists are frequently used in traditional Lisp
programming to remember keyval associations, and typically
modified nondestructively by pushing and popping new keyval
cells at the start of the list.

The @code{assoc} function takes an association list and a
key, a returns the first keyval cell containing that key, if
any, else @code{nil}.  Thus, you must take the @code{cdr} of
the returned value to find the actual value associated with
the key.

If no matching key is found, @code{nil} is returned.

The choice of return value may see a bit odd.  One
advantage of this arrangement is that it makes it
easy to distinguish between failure to find the
key, and finding that the key has a value of @code{nil}.

@example
Stack:
[ 'k' 'v' cons   'K' 'V' cons ]l   --> list
Stack:
'k' list assoc cdr
Stack: 'v'
pop 'K' list assoc cdr
Stack: 'V'
@end example

@xref{rassoc}.

@end defun

@c
@node  copyAlist, copyList, assoc, list functions
@subsection copyAlist
@defun copyAlist @{ list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

Constructs a copy of an association list.

@xref{assoc}.

@xref{copyList}.  @xref{copyTree}.
@end defun

@c
@node  copyList, copyTree, copyAlist, list functions
@subsection copyList
@defun copyList @{ list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

Copies the top level of a List, which must not be circular.

@xref{copyAlist}.  @xref{copyTree}.
@end defun

@c
@node  copyTree, delete, copyList, list functions
@subsection copyTree
@defun copyTree @{ list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

Copies all cons cells reachable from the given
cons cell, passing only through cons cells.  The
tree must not contain circular links.

@xref{copyAlist}.  @xref{copyList}.
@end defun

@c
@node  delete, deleteIf, copyTree, list functions
@subsection delete
@defun delete @{ val arg -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

If @code{arg} is a stack, all instances of @code{val} in
it are removed.  Otherwise, @code{arg} must be a list.

The @code{delete} function searches @code{list} and
@emph{destructively} removes all references to @code{val}:
The return value is a splice of the given value.

It is usually safer to construct a new list than to
modify the existing one: @xref{remove}.

@example
Stack:
[ 'a' 'b' 'c' ]l   --> list
Stack:
'b' list delete
Stack:
list first   list second
Stack: 'a' 'c'
@end example

@xref{deleteNth}.

@end defun

@c
@node  deleteIf, deleteIfNot, delete, list functions
@subsection deleteif
@defun delete @{ fn list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{deleteIf} function searches @code{list} and
@emph{destructively} removes all elements satisfying @code{fn}:
The return value is a splice of the given value.

It is usually safer to construct a new list than to
modify the existing one: @xref{removeIf}.

@example
Stack:
:: 'b' = ;   [ 'a' 'b' 'c' ]l   deleteIf   --> list
Stack:
list first   list second
Stack: 'a' 'c'
@end example

@xref{delete}. @xref{deleteIfNot}.

@end defun

@c
@node  deleteIfNot, eighth, deleteIf, list functions
@subsection delete
@defun delete @{ val list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{delete} function searches @code{list} and
@emph{destructively} removes all references to @code{val}:
The return value is a splice of the given value.

It is usually safer to construct a new list than to
modify the existing one: @xref{remove}.

@example
Stack:
[ 'a' 'b' 'c' ]l   --> list
Stack:
'b' list delete
Stack:
list first   list second
Stack: 'a' 'c'
@end example

@end defun

@c
@node  eighth, end?, deleteIfNot, list functions
@subsection eighth
@defun eighth @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{eighth} function returns the eighth
element in a list.
@xref{first}, @xref{second}, 
@xref{third}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  end?, fifth, eighth, list functions
@subsection end?
@defun end? @{ list -> notlist @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{end?} function is a clone of @code{not}
and @code{null?}, except that it is an error to
give it as input anything but @code{nil} or a cons cell.

@xref{not}, @xref{null?}.

@end defun

@c
@node  fifth, first, end?, list functions
@subsection fifth
@defun fifth @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{fifth} function returns the fifth
element in a list.
@xref{first}, @xref{second}, 
@xref{third}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  first, fourth, fifth, list functions
@subsection first
@defun first @{ list -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{first}, function returns the first
element in a list;  it is identical to @code{car}.
@xref{second}, @xref{third}, 
@xref{fourth}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  fourth, getprop, first, list functions
@subsection fourth
@defun fourth @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{fourth} function returns the fourth
element in a list:  It is identical to
@code{cdddar}.
@xref{first}, @xref{second}, 
@xref{third}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  getprop, last, fourth, list functions
@subsection getprop
@defun getprop @{ symbol key -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

This function gets the value of @code{key} on
@code{symbol}'s property list.  CommonLisp actually calls
this function @code{get}, but @sc{muf} has another function
by that name.

@xref{putprop}.

@end defun

@c
@node  last, length, getprop, list functions
@subsection last
@defun last @{ list n -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{last} function returns the last @code{n}
cons cells in the given list.

If @code{n} is
greater than the list length, the list is
returned.

If @code{n} is zero, the @code{cdr} of the
final cell is returned.

It is an error to supply a negative @code{n}.
@end defun

@example
Stack:
'a' 'b' cons 0 last
Stack: 'b'
pop [ 'a' 'b' ]l 1 last car
Stack: 'b'
pop [ 'a' 'b' ]l 2 last car
Stack: 'a'
@end example


@c
@node  length, length2, last, list functions
@subsection length
@defun length
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ arg -> length @}
@end example

The @code{length} function accepts a List, vector (or
ephemeral vector), string, Stack, Stream, Structure
(or ephemeral structure)
and returns its length (number of valid items contained).

Behavior of this function is undefined on a circular list:
Use listLength for possibly circular lists.
@xref{listLength}.
@end defun


@c
@node  length2, list, length, list functions
@subsection length2
@defun length2
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{length2} function is a primitive 
used internally by the current implementation
of @code{length}, which should not be called
directly by users, and may change or disappear
in future releases.  @xref{length}.

@end defun


@c
@node  list, dottedList, length2, list functions
@subsection list
@defun list @{ [items] -> [list-of-items] @}
@display
@exdent file: 00-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{list} function constructs a List from a given
set of arguments, using Lisp calling conventions:

@example
Stack:
[ 1 2 3 | list |pop --> lst ]pop
Stack: 
lst first
Stack: 1
lst second
Stack: 1 2
lst third
Stack: 1 2 3
@end example

@xref{]}.

It is currently implemented as:

@example
: list @{ [] -> [] @}

    nil    -> result
    do@{
	|length 0 = until
        |pop result cons -> result
    @}

    result |push
;
@end example



@end defun

@c
@node  dottedList, listLength, list, list functions
@subsection dottedList
@defun list @{ [items] tail -> [list-of-items] @}
@display
@exdent file: 00-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{dottedList} function constructs a List from a given
set of arguments, with the given tail.

@xref{list}.

It is currently implemented as:

@example
:   dottedList @{ [] $ -> [] @}

    -> result
    do@{
	|length 0 = until
        |pop result cons -> result
    @}

    result |push
;
@end example



@end defun

@c
@node  listLength, mapc, dottedList, list functions
@subsection listLength
@defun listLength
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ list -> length @}
@end example

The @code{listLength} function accepts a list and returns
the length of the list, or @code{nil} if the list is circular.
@end defun


@c
@node  mapc, mapcan, listLength, list functions
@subsection mapc
@defun mapc @{ [] fn -> @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @sc{muf} @code{mapc} function is named and patterned
after that of CommonLisp, although it is not quite the same.
It provides a simple way of applying a function to many sets
of arguments, when the function has no return values.

The @code{mapc} function accepts a block of lists and a
function, which must accept as many arguments as there are
lists in the block.  On the first call to the given
function, it is passed the first element in each of
the given lists.  On the second call, it recieves the
second element from each list.  This continues until
one or more of the lists run out of elements:

@example
Stack: 
[ [ "a" "b" "c" ]l [ 0 1 2 ]l |   :: , , "\n" , ;   mapc
0a
1b
2c
Stack: 
@end example

@end defun

@c
@node  mapcan, mapcar, mapc, list functions
@subsection mapcan
@defun mapcan @{ [] fn -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{mapcan} function accepts a block of lists and a
function, which must accept as many arguments as there are
lists in the block, and return a list.  On the first call to
the given function, it is passed the first element in each
of the given lists.  On the second call, it recieves the
second element from each list.  This continues until one or
more of the lists run out of elements.

The lists returned from the successive calls are combined
with @code{nconc} and returned as the final result.

@example
Stack: 
[ [ "a" "b" "c" ]l |   :: nil cons ;   mapcan   --> list
Stack: 
list first   list second   list third
Stack: "a" "b" "c"
@end example

The name @code{mapcar} is derived from @code{mapcar}, using
as usual an 'n' to signal a destructive list operation.

Think of @code{mapcan} as providing a way for the @code{fn}
to return a variable number of results on each call,
including zero (by returning @code{nil}).

@xref{mapcar}.

@end defun

@c
@node  mapcar, mapcon, mapcan, list functions
@subsection mapcar
@defun mapcan @{ [] fn -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{mapcar} function accepts a block of lists and a
function, which must accept as many arguments as there are
lists in the block, and return a value.  On the first call to
the given function, it is passed the first element in each
of the given lists.  On the second call, it recieves the
second element from each list.  This continues until one or
more of the lists run out of elements.

The return values are collected in a list, which is returned
as the final result:

@example
Stack: 
[ [ "a" "b" "c" ]l |   :: ;   mapcar   --> list
Stack: 
list first   list second   list third
Stack: "a" "b" "c"
@end example

@end defun

@c
@node  mapcon, mapl, mapcar, list functions
@subsection mapcon
@defun mapcon @{ [] fn -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{mapcon} function accepts a block of lists and a
function, which must accept as many arguments as there are
lists in the block, and return a list.  On the first call to
the given function, it is passed the first cons cell (not
element!) in each of the given lists.  On the second call,
it recieves the second cons cell from each list.  This
continues until one or more of the lists run out of
elements.

The lists returned from the successive calls are combined
with @code{nconc} and returned as the final result.

@example
Stack: 
[ [ "a" "b" "c" ]l |   :: car nil cons ;   mapcon   --> list
Stack: 
list first   list second   list third
Stack: "a" "b" "c"
@end example

@xref{maplist}.

@end defun

@c
@node  mapl, maplist, mapcon, list functions
@subsection mapl
@defun mapl @{ [] fn -> @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{mapl} function accepts a block of lists and a
function, which must accept as many arguments as there are
lists in the block.  On the first call to
the given function, it is passed the first cons cell (not
element!) in each of the given lists.  On the second call,
it recieves the second cons cell from each list.  This
continues until one or more of the lists run out of
elements.  The @code{fn} should return no value, and
@code{mapl} does not either:  It is used purely for
side-effects:

@example
Stack: 
[ [ "a" "b" "c" ]l |   :: car , "\n" , ;   mapl
a
b
c
Stack: 
@end example

@xref{maplist}.

@end defun

@c
@node  maplist, member?, mapl, list functions
@subsection maplist
@defun maplist @{ [] fn -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{maplist} function accepts a block of lists and a
function, which must accept as many arguments as there are
lists in the block, and return a value.  On the first call to
the given function, it is passed the first cons cell (not
element!) in each of the given lists.  On the second call,
it recieves the second cons cell from each list.  This
continues until one or more of the lists run out of
elements.  The values returned from the successive calls are
collected into a list, which is returned as the final result:

@example
Stack: 
[ [ "a" "b" "c" ]l |   :: car ;   maplist   --> list
Stack: 
list first   list second   list third
Stack: "a" "b" "c"
@end example

@xref{mapl}. @xref{mapcon}. @xref{mapcar}.
@end defun

@c
@node  member?, nconc, maplist, list functions
@subsection member?
@defun member? @{ val list -> nil-or-cons @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @sc{muf} @code{member?} function searches a list for a
given value.  It returns @code{nil} if the value is found,
else the first cons cell containing the given value:

@example
Stack: 
'd' [ 'a' 'b' 'c' ]l member?
Stack: nil
pop 'b' [ 'a' 'b' 'c' ]l member? car
Stack: 'b'
@end example

It is currently defined as:

@example
: member?  @{ $ $ -> $ @}   -> list   -> val
    list listfor v c do@{ v val = if c return fi @}
    nil
;
@end example

@end defun


@c
@node  nconc, ninth, member?, list functions
@subsection nconc
@defun nconc @{ list list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @sc{muf} @code{nconc} function @emph{destructively}
joins two lists:  The last cons cell in the first list
is changed to point to the first cons cell in the
second list:

@example
Stack:
[ 'a' 'b' ]l [ 'c' 'd' ]l nconc --> list
Stack:
list first  list second  list third  list fourth
Stack: 'a' 'b' 'c' 'd'
@end example

This looks much like the @code{append} function
(@pxref{append}) but is much more dangerous, since it
modifies an existing list instead of constructing a new one:
@code{nconc} is an efficiency hack to avoid allocating new
list cells.  Use it only if you really need to.

The name comes from CommonLisp: 'conc' for 'concatenate',
prefixed by the 'n' which signals a dangerous function
modifying existing lists.  (Think of as as n-for-nuke.)
@end defun


@c
@node  ninth, nreverse, nconc, list functions
@subsection ninth
@defun ninth @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{ninth} function returns the ninth
element in a list.
@xref{first}, @xref{second}, 
@xref{third}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  nreverse, nsublis, ninth, list functions
@subsection nreverse
@defun nreverse @{ list -> list @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{nreverse} function reverses a list by
modifying the cons cell pointers.

@xref{reverse}.

@end defun

@c
@node  nsublis, nsubst, nreverse, list functions
@subsection nsublis
@defun nsublis @{ alist list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{nsublis} function destructively modifies
the given list by replacing all leafs which are
keys in the association list @code{alist} by their
corresponding values in @code{alist}.
@xref{assoc}.

(As usual the n-for-nuke prefix signals a
destructive list operation.)

@example
Stack:
[ [ 'your 'car ]l [ 'your 'spouse ]l ]l --> list
Stack:
[  'your 'my cons   'car 'bicycle cons   ]l --> alist
Stack:
alist list nsublis printList
Stack: "[ [ 'my 'bicycle ]l [ 'my 'spouse ]l ]l"
@end example

@xref{sublis}.
@end defun

@c
@node  nsubst, nsubstIf, nsublis, list functions
@subsection nsubst
@defun nsubst @{ new old list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{nsubst} function destructively modifies
the given list by everywhere replacing @code{old}
by @code{new}.  (As usual the n-for-nuke in the
name signals a destructive list operation.)

@example
Stack:
[ [ 'your 'car ]l [ 'your 'spouse ]l ]l --> list
Stack:
'my 'your list nsubst printList
Stack: "[ [ 'my 'car ]l [ 'my 'spouse ]l ]l"
@end example

@xref{subst}.
@end defun

@c
@node  nsubstIf, nsubstIfNot, nsubst, list functions
@subsection nsubstIf
@defun nsubstIf @{ new fn list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{nsubstIf} function destructively
modifies the given list by replacing all elements
satisfying @code{fn} by @code{new}.  (As usual the
n-for-nuke in the name signals a destructive list
operation.)

@example
Stack:
[ [ 'a' 'B' 'c' ]l [ 'D' 'e' 'f' ]l ]l --> list
Stack:
'_' :: upperCase? ; list nsubstIf printList
Stack: "[ [ 'a' '_' 'c' ]l [ '_' 'e' 'f' ]l ]l"
@end example

@xref{substIf}.
@end defun

@c
@node  nsubstIfNot, nth, nsubstIf, list functions
@subsection nsubstIfNot
@defun nsubstIfNot @{ new fn list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{nsubstIfNot} function destructively
modifies the given list by replacing all elements
not satisfying @code{fn} by @code{new}.  (As usual
the n-for-nuke in the name signals a destructive
list operation.)

@example
Stack:
[ [ 'a' 'B' 'c' ]l [ 'D' 'e' 'f' ]l ]l --> list
Stack:
'_' :: upperCase? ; list nsubstIfNot printList
Stack: "[ [ '_' 'B' '_' ]l [ 'D' '_' '_' ]l ]l"
@end example

@end defun

@c
@node  nth, nthcdr, nsubstIfNot, list functions
@subsection nth
@defun nth @{ n list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{nth} function returns the nth
element in a list, counting from
zero:  @code{0 list nth} is equivalent to
@code{car}.
@xref{first}, @xref{second}, 
@xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  nthcdr, printList, nth, list functions
@subsection fourth
@defun fourth @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{nth} function returns the nth
cons cell in a list, counting from
zero:  @code{0 list nthcdr} simply
returns @code{list}.
@xref{first}, @xref{second}, 
@xref{nth}, @xref{rest}.

The @code{fourth} function returns the fourth
element in a list:  It is identical to
@code{cdddar}.
@xref{first}, @xref{third}, 
@xref{fourth}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  printList, putprop, nthcdr, list functions
@subsection printList
@defun printList @{ list -> string @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

This function produces a string representation of a
list resembling the syntax one might use to type it
in:

@example
Stack:
[ [ 'a' 'b' 'c' ]l [ "def" 12 ]l ]l printList
Stack: "[ [ 'a' 'b' 'c' ]l [ "def" 12 ]l ]l"
@end example

It is currently implemented as:

@example
: printList @{ $ -> $ @} -> list
    [   "[ "
        list listfor e do@{
            e   e cons? if printList else toDelimitedString fi
            " "
        @}
        "]l"
    | ]join
;
@end example

@end defun

@c
@node  putprop, rassoc, printList, list functions
@subsection putprop
@defun putprop @{ symbol val key -> @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

This function sets the value of @code{key} on
@code{symbol}'s property list to @code{val}.  Any previous
value is overwritten.

@example
Stack:
'sym "val" "key" putprop
Stack:
'sym "key" getprop
Stack: "val"
pop   'sym "VAL" "key" putprop
Stack: 
'sym "key" getprop
Stack: "VAL"
pop 'sym symbolPlist length
Stack: 2
@end example

(CommonLisp has actually phased out this function name, but
the CommonLisp replacement won't work in @sc{muf}.)

@xref{getprop}.  @xref{remprop}.
@xref{symbolPlist}.  @xref{setSymbolPlist}.

@end defun

@c
@node  rassoc, remove, putprop, list functions
@subsection rassoc
@defun rassoc @{ val list -> keyval @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

This function is exactly like @code{assoc} except that
it searches for a cons cell with a matching @code{cdr}
slot, instead of a matching @code{car} slot:

@example
Stack:
[ 'k' 'v' cons   'K' 'V' cons ]l   --> list
Stack:
'v' list rassoc car
Stack: 'k'
pop 'V' list rassoc car
Stack: 'K'
@end example

Note that @code{rassoc} does @emph{not} search the list in
reverse!

@xref{assoc}.

@end defun

@c
@node  remove, removeIf, rassoc, list functions
@subsection remove
@defun remove @{ val list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{remove} function scans @code{list} and
constructs a new list identical to the original
except for containing no references to @code{val}.

The original @code{list} is never modified.

The return value may share cells with the original list, and
may be identical to the original list if no deletions were
needed.  (The current implementation does not do this,
but future implementations might.)

@xref{delete}.

@example
Stack:
[ 'a' 'b' 'c' ]l   --> list
Stack:
'b' list remove
Stack:
list first   list second
Stack: 'a' 'c'
@end example

@end defun

@c
@node  removeIf, removeIfNot, remove, list functions
@subsection removeIf
@defun removeIf @{ fn list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{removeIf} function scans @code{list} and
constructs a new list identical to the original
except for containing no elements satisfying @code{fn}.

The original @code{list} is never modified.

@example
Stack:
:: 'b' = ;   [ 'a' 'b' 'c' ]l   removeIf   --> list
Stack:
list first   list second
Stack: 'a' 'c'
@end example

@end defun

@c
@node  removeIfNot, remprop, removeIf, list functions
@subsection remove
@defun removeIfNot @{ fn list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{removeIfNot} function scans @code{list} and
constructs a new list identical to the original
except for containing only elements satisfying @code{fn}.

The original @code{list} is never modified.

@example
Stack:
:: 'b' != ;   [ 'a' 'b' 'c' ]l   removeIfNot   --> list
Stack:
list first   list second
Stack: 'a' 'c'
@end example

@end defun

@c
@node  remprop, rest, removeIfNot, list functions
@subsection remprop
@defun remprop @{ symbol key @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

This function removes any property @code{key} which
might be present on @code{symbol}.

@example
Stack:
'sym "val" "key" putprop
Stack:
'sym "key" getprop
Stack: "val"
pop   'sym "key" remprop
Stack:
'sym "key" getprop
Stack: nil
@end example

@xref{putprop}.  @xref{getprop}.

@end defun

@c
@node  rest, reverse, remprop, list functions
@subsection rest
@defun rest @{ list -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rest}, function returns the nonfirst part of a
list; it is identical to @code{cdr}, but reads better with
@code{first}.  @xref{first}, @xref{second}, @xref{third},
@xref{fourth}, @xref{nth}, @xref{nthcdr}.

@end defun

@c
@node  reverse, rplaca, rest, list functions
@subsection reverse
@defun reverse @{ list -> list @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{reverse}, function returns copy of the given
list with the elements in reverse order.  The original
list is unchanged.

@example
Stack:
[ 'a' 'b' ]l reverse --> list
Stack:
list first list second
Stack: 'b' 'a'
@end example

@xref{nreverse}.

@end defun

@c
@node  rplaca, rplacd, reverse, list functions
@subsection rplaca
@defun rplaca @{ cons val -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rplaca} function RePLACes the cAr of the given
cons cell with the given value.  (The name is
awful@footnote{Many traditional Lisp function names "just
happen" to fit in six characters, possibly because the
@sc{pdp}-10, for years the standard Lisp machine, could fit
six letters in each 36-bit word using @sc{sixbit} format.},
but traditional in Lisp.)
@end defun

@c
@node  rplacd, second, rplaca, list functions
@subsection rplacd
@defun rplacd @{ cons val -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rplacd} function RePLACes the cDr of the given
cons cell with the given value.  This is @code{rplaca}'s
twin:  Together, the two let you do arbitrarily awful
things to pre-existing List structures.

Pragmatics: Creating new Lists almost always produces
simpler, more reliable code than modifying existing Lists
using @code{rplaca} and @code{rplacd}: They are usually used
as an efficiency hack.

@end defun

@c
@node  second, seventh, rplacd, list functions
@subsection second
@defun second @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{second} function returns the second
element in a list:  It is identical to
@code{cdar}.
@xref{first}, @xref{third}, 
@xref{fourth}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  seventh, sixth, second, list functions
@subsection seventh
@defun seventh @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{seventh} function returns the seventh
element in a list
@xref{first}, @xref{second}, 
@xref{third}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  sixth, sublis, seventh, list functions
@subsection sixth
@defun sixth @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{sixth} function returns the sixth
element in a list.
@xref{first}, @xref{second}, 
@xref{third}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  sublis, subseq, sixth, list functions
@subsection sublis
@defun sublis @{ alist list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{sublis} function returns a copy of the
given list in which keys present in the
association list @code{alist} are everywhere
replaced by their corresponding values
in @code{alist}.  @xref{assoc}.

@example
Stack:
[ [ 'your 'car ]l [ 'your 'spouse ]l ]l --> list
Stack:
[  'your 'my cons   'car 'bicycle cons   ]l --> alist
Stack:
alist list sublis printList
Stack: "[ [ 'my 'bicycle ]l [ 'my 'spouse ]l ]l"
@end example

@xref{nsublis}.
@end defun

@c
@node  subseq, subst, sublis, list functions
@subsection subseq
@defun subseq @{ list start end -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{subseq} function returns a copy of the
indicated part of @code{list}.  The first element
of the list is position zero, as usual.  Both
@code{start} and @code{end} should be whole
numbers.  The result will contain those values
from positions numbered @code{start} or greater,
but less than @code{end}:

@example
Stack:
[ 'a 'b 'c 'd 'e ]l 2 4 subseq printList
Stack: "[ 'c 'd ]l"
@end example
@end defun

@c
@node  subst, substIf, subseq, list functions
@subsection subst
@defun subst @{ new old list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{subst} function returns a copy of the
given list in which @code{old} is everywhere
replaced by @code{new}:

@example
Stack:
[ [ 'your 'car ]l [ 'your 'spouse ]l ]l --> list
Stack:
'my 'your list subst printList
Stack: "[ [ 'my 'car ]l [ 'my 'spouse ]l ]l"
@end example

@xref{nsubst}.
@end defun

@c
@node  substIf, substIfNot, subst, list functions
@subsection substIf
@defun substIf @{ new fn list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{substIf} function returns a copy
of the given list in which all elements
satisfying @code{fn} are replaced by @code{new}:

@example
Stack:
[ [ 'a' 'B' 'c' ]l [ 'D' 'e' 'f' ]l ]l --> list
Stack:
'_' :: upperCase? ; list substIf printList
Stack: "[ [ 'a' '_' 'c' ]l [ '_' 'e' 'f' ]l ]l"
@end example

@xref{nsubstIf}.
@end defun

@c
@node  substIfNot, tenth, substIf, list functions
@subsection substIfNot
@defun substIfNot @{ new fn list -> list @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{substIfNot} function returns a copy of the given
list in which all elements not satisfying @code{fn} are
replaced by @code{new}:

@example
Stack:
[ [ 'a' 'B' 'c' ]l [ 'D' 'e' 'f' ]l ]l --> list
Stack:
'_' :: upperCase? ; list substIfNot printList
Stack: "[ [ '_' 'B' '_' ]l [ 'D' '_' '_' ]l ]l"
@end example

@xref{nsubstIfNot}.
@end defun

@c
@node  tenth, third, substIfNot, list functions
@subsection tenth
@defun tenth @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{tenth} function returns the tenth
element in a list.
@xref{first}, @xref{second}, 
@xref{third}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node  third, loop stack functions, tenth, list functions
@subsection third
@defun third @{ list -> val @}
@display
@exdent file: 10-C-lists.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{third} function returns the third
element in a list:  It is identical to
@code{cddar}.
@xref{first}, @xref{second}, 
@xref{fourth}, @xref{nth}, @xref{nthcdr}, @xref{rest}.

@end defun

@c
@node loop stack functions, loop stack overview, third, Core Muf
@section loop stack functions
@cindex loop stack functions

@menu
* loop stack overview::
* countStackframes::
* getStackframe[::
@end menu

@c
@node  loop stack overview, countStackframes, loop stack functions, loop stack functions
@subsection loop stack overview
@cindex loop stack overview

Each Muq job ("thread") has two stacks:

@itemize @bullet
@item
Data stack, used for expression evaluation.
@item
Loop stack, used for local variables, return addresses and so forth.
@end itemize

The data stack is directly visible to the @sc{muf} programmer,
and holds a simple unstructured sequences of values.

The loop stack has a more intricate structure consisting essentially
of typed records of various lengths.  For a full discussion of
loop stacks, see @ref{Loop Stacks,,,muqimp.t,Loop Stacks}.

The functions in this section provide ways to inspect and
modify the other-wise inaccessable loop stack contents.
They are intended primarily for use in debuggers.

@c
@node  countStackframes, getStackframe[, loop stack overview, loop stack functions
@subsection countStackframes
@defun countStackframes @{ job -> count @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{countStackframes} function returns an integer count of
the number of stackframes in the loop stack of the given job.
It is intended primarily to be used to obtain the maximum
usable argument for @code{getStackframe[}.  @xref{getStackframe[}.

@end defun

@c
@node  getStackframe[, math functions, countStackframes, loop stack functions
@subsection getStackframe[
@defun getStackframe[ @{ n job -> [block] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getStackframe[} function is the primary
(low-level) window into the loop stack.  It returns a keyval
block describing the given stackframe (@code{n} must be a
non-negative integer less than @code{job
countStackframes}).

If @code{@@$s.actingUser} doesn't ``control'' the stackframe
in question, the @code{getStackframe[} return block
contains only

@example
[ :owner o |
@end example

@noindent
where @code{o} is the ``owner'' of the stackframe;
otherwise it returns a full dump of the contents of the
stackframe.  For a precise description of this dump,
see @ref{Loop Stacks,,,muqimp.t,Loop Stacks}.

The ``owner'' of a stackframe is the value of
@code{@@$s.actingUser} at the time the stackframe
was created.  A job ``controls'' a stackframe iff
@code{@@$s.actingUser} for the job is the owner
of the stackframe, or else is root running with
the @sc{omnipotent} bit set.

@end defun

@c
@node math functions, math functions overview, getStackframe[, Core Muf
@section math functions
@cindex Math functions

@menu
* math functions overview::
* float to int functions::
* exponential and logarithmic functions::
* trigonometric functions::
@end menu

@c
@node  math functions overview, float to int functions, math functions, math functions
@subsection math functions overview

Muq takes @sc{ansi} Common Lisp as the ultimate standard for
the semantics of all functions in this section; The current
implementation does not claim to be fully compliant, but
programs should not be written to depend on any differences
between the standard and the current implementation.

For simplicity and portability, the current implementation
merely uses the math functions provided by the host C
libraries.


@c
@node  float to int functions, exponential and logarithmic functions, math functions overview, math functions
@subsection float to int functions
@findex floor
@findex ceiling
@findex truncate
@findex round

@example
 floor    @{ flt -> int @}
 ceiling  @{ flt -> int @}
 truncate @{ flt -> int @}
 round    @{ flt -> int @}
@end example


@code{floor} truncates towards negative infinity;

@code{ceiling} truncates toward positive infinity;

@code{truncate} truncates toward zero;

@code{round} truncates toward nearest integer.



@c
@node  exponential and logarithmic functions, trigonometric functions, float to int functions, math functions
@subsection exponential and logarithmic functions
@findex exp
@findex expt
@findex exptmod
@findex log
@findex log10
@findex sqrt
@findex abs
@findex ffloor
@findex fceiling

@example
 exp      @{ # -> flt @}
 expt     @{ # # -> flt @} (C pow())
 exptmod  @{ i i i -> i @}
 log      @{ # -> flt @}
 log10    @{ # -> flt @} (Nonlisp)
 sqrt     @{ # -> flt @}
 abs      @{ # -> # @}
 ffloor   @{ # -> # @}
 fceiling @{ # -> # @}
@end example

The @code{exptmod} function takes three integer operands @code{b},
@code{p}, @code{m} and computes @code{b} to the @code{p} power mod
@code{m} -- an operation frequently used by various digital signature
schemes and related public-key based authentication techniques.

The @code{exptmod} function is implemented using Montgomery exponentiation, meaning
that results up to about 512 bits can be computed in seconds.  (I've
computed results up to about 9,000 bit this way, but that takes half
an hour or more, and requires recompiling bnm.t with some constants
set larger.)



@c
@node  trigonometric functions, message stream functions, exponential and logarithmic functions, math functions
@subsection trigonometric functions
@findex acos
@findex asin
@findex atan
@findex atan2
@findex cos
@findex sin
@findex tan
@findex cosh
@findex sinh
@findex tanh

@example
 acos  @{ # -> flt @}
 asin  @{ # -> flt @}
 atan  @{ # -> flt @}
 atan2 @{ # -> flt @}
 cos   @{ # -> flt @}
 sin   @{ # -> flt @}
 tan   @{ # -> flt @}
 cosh  @{ # -> flt @}
 sinh  @{ # -> flt @}
 tanh  @{ # -> flt @}
@end example


@c
@node message stream functions, message stream functions overview, trigonometric functions, Core Muf
@section message stream functions
@cindex Message stream functions

@menu
* message stream functions overview::
* delimitedWriteToOutputStream::
* flush::
* flushStream::
* readByte::
* readChar::
* readValue::
* readStreamByte::
* readStreamChar::
* readStreamValue::
* unreadChar::
* unreadStreamChar::
* readStreamPacket[::
* |readAnyStreamPacket::
* readLine::
* readStreamLine::
* |writeStreamPacket::
* |rootWriteStreamPacket::
* |maybeWriteStreamPacket::
* |rootMaybeWriteStreamPacket::
* writeOutputStream::
* writeStream::
* writeSubstringToStream::
* ]writeStreamByLines::
* rootWriteStream::
@end menu

@c
@node  message stream functions overview, delimitedWriteToOutputStream, message stream functions, message stream functions
@subsection message stream functions

Message streams are Muq's answer to unix pipes: They are
bounded buffers serving as communication channels and
synchronization mechanisms between jobs.

Unlike unix streams, Muq message streams may contain values of
any sort whatever, including jobs and message streams,
although string is still the usual fare.


@c
@node  delimitedWriteToOutputStream, flush, message stream functions overview, message stream functions
@subsection delimitedWriteToOutputStream
@defun delimitedWriteToOutputStream @{ string -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This command accepts one parameter and writes it to the
standard output stream for the current job,
@code{@@$s.dstMsq}.  If necessary, the job will block until
space becomes available.

For conciseness, this function is also available as
@code{,,} (comma comma).

This function is similar to @code{val @@$s.standardOuput
writeStream}, but differs in that
@code{writeOutputStream} also converts any non-string
arguments to string before placing them in the stream,
effectively using the @code{toDelimitedString} function.

@xref{writeOutputStream}.
@xref{toDelimitedString}.  @xref{writeStream}.  @xref{rootWriteStream}.
@end defun


@c
@node  flush, flushStream, delimitedWriteToOutputStream, message stream functions
@subsection flush
@defun flush @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Any incomplete packet on @code{@@$s.standardOutput} is marked as
complete.  Use this function to send partial lines:

@example
"prompt: " , flush
@end example

Without the @code{flush}, the string would not be
made available to the reading process until a "\n"
was written, (unless the reading job is accepting
incomplete packets).

@xref{flushStream}.
@end defun


@c
@node  flushStream, readByte, flush, message stream functions
@subsection flushStream
@defun flushStream @{ stream -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Any incomplete packet on @code{@@$s.standardOutput} is marked as
complete.  Use this function to send partial lines:

@example
"prompt: " stream writeStream   stream flushStream
@end example

Without the @code{flushStream}, the string would not
be made available to the reading process until a "\n"
was written, (unless the reading job is accepting
incomplete packets).

@xref{flush}.
@end defun


@c
@node  readByte, readChar, flushStream, message stream functions
@subsection readByte
@defun readByte @{ -> std-in-byte @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts no parameters, and returns as an
integer the next character from the standard input for the
current job, @code{@@$s.standardInput}.

@strong{Details}:  Packets with tags other than @code{"txt"}
are ignored, as are non-character values.

If no input is available, the job blocks until something
arrives, unless both @code{@@$s.standardInput$s.dead}
and @code{@@$s.readNilFromDeadStreams} are non-@code{nil},
in which case @code{nil} is returned.

@xref{readStreamByte}.
@xref{readChar}.
@end defun


@c
@node  readChar, readValue, readByte, message stream functions
@subsection readChar
@defun readChar @{ -> std-in-char @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts no parameters, and returns the
next character from the standard input for the
current job, @code{@@$s.standardInput}.

@strong{Details}:  Packets with tags other than @code{"txt"}
are ignored, as are non-character values.

If no input is available, the job blocks until something
arrives, unless both @code{@@$s.standardInput$s.dead}
and @code{@@$s.readNilFromDeadStreams} are non-@code{nil},
in which case @code{nil} is returned.

@xref{readStreamChar}.
@xref{readByte}.
@xref{unreadChar}.
@end defun


@c
@node  readValue, readStreamByte, readChar, message stream functions
@subsection readValue
@defun readValue @{ -> std-in-value @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts no parameters, and returns the
next value from the standard input for the
current job, @code{@@$s.standardInput}.

@strong{Details}:  Any kind of value in any packet
with any tag is fair game for this function.

If no input is available, the job blocks until something
arrives, unless both @code{@@$s.standardInput$s.dead}
and @code{@@$s.readNilFromDeadStreams} are non-@code{nil},
in which case @code{nil} is returned.

@xref{readStreamValue}.
@xref{readChar}.
@end defun


@c
@node  readStreamByte, readStreamChar, readValue, message stream functions
@subsection readStreamByte
@defun readStreamByte @{ stream -> byte who @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a stream, and returns as an
integer the next byte from the stream, plus the
@code{actingUser} who wrote the byte into the stream.

If no input is available, the job blocks until something
arrives, unless both @code{stream$s.dead}
and @code{@@$s.readNilFromDeadStreams} are non-@code{nil},
in which case @code{nil} is returned.

@xref{readStreamChar}.
@xref{readByte}.
@end defun


@c
@node  readStreamChar, readStreamValue, readStreamByte, message stream functions
@subsection readStreamChar
@defun readStreamChar @{ stream -> char who @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a stream, and returns as a
character the next byte from the stream, plus the
@code{actingUser} who wrote the byte into the stream.

If no input is available, the job blocks until something
arrives, unless both @code{stream$s.dead}
and @code{@@$s.readNilFromDeadStreams} are non-@code{nil},
in which case @code{nil} is returned.

@xref{readStreamByte}.
@xref{readChar}.
@xref{unreadStreamChar}.
@end defun

@c
@node  readStreamValue, unreadChar, readStreamChar, message stream functions
@subsection readStreamValue
@defun readStreamValue @{ stream -> value tag who @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a stream, and returns the next
value from the stream, plus the tag from the packet
containing that value, and the
@code{actingUser} who wrote that packet into the stream.

If no input is available, the job blocks until something
arrives, unless both @code{stream$s.dead}
and @code{@@$s.readNilFromDeadStreams} are non-@code{nil},
in which case @code{nil nil nil} is returned.

@xref{readStreamChar}.
@xref{readValue}.
@end defun

@c
@node  unreadChar, unreadStreamChar, readStreamValue, message stream functions
@subsection unreadChar
@findex unreadByte
@findex unreadValue
@defun unreadChar @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

If the job has just read a value via
@code{readChar} or @code{readByte}, then
@code{unreadChar} may be used to effectively
undo the read.  (This is often convenient when
scanning input a character at a time, to return
an unwanted value belonging to the next token.)

There is no guarantee of being able to unread
more than one value deep, and the effect of
calling @code{unreadChar} in other contexts
is undefined.  (In general, however, @code{unreadChar}
will do either the obvious thing, or nothing.)

This function is also available under the names
@code{unreadByte} and @code{unreadValue}, to
improve code readability.

@xref{unreadStreamChar}.
@end defun


@c
@node  unreadStreamChar, readStreamPacket[, unreadChar, message stream functions
@subsection unreadStreamChar
@findex unreadStreamByte
@findex unreadStreamValue
@defun unreadStreamChar @{ stream -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

If the job has just read a value via
@code{readStreamChar} or @code{readStreamByte}, then
@code{unreadStreamChar} may be used to effectively
undo the read.

There is no guarantee of being able to unread more than
one value deep, and the effect of calling
@code{unreadStreamChar} in other contexts is
undefined.  (In general, however,
@code{unreadStreamChar} will do either the obvious
thing, or nothing.)

This function is also available under the names
@code{unreadStreamByte} and @code{unreadStreamValue}, to
improve code readability.

Example:

@example
stack:
makeMessageStream --> *s*
stack:
"abc\n" *s* writeStream
stack:
*s* readStreamByte
stack: 97 #<root root>
pop pop
stack:
*s* readStreamChar
stack: 'b' #<root root>
pop pop
stack:
*s* readStreamValue
stack: 'c' "txt" #<root root>
pop pop pop
stack:
*s* unreadStreamValue
stack:
*s* readStreamValue
stack: 'c' "txt" #<root root>
@end example

@xref{unreadChar}.
@end defun


@c
@node  readStreamPacket[, |readAnyStreamPacket, unreadStreamChar, message stream functions
@subsection readStreamPacket[
@defun readStreamPacket[ @{ noFragments stream -> [values] tag who @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This is the fundamental non-root function for reading a
message stream: It returns all information stored in
the message stream for a particular packet, plus the
value of @code{@@$s.actingUser} in the job that sent
the packet at the time the packet was sent, as an
anti-spoofing measure.
(@pxref{|writeStreamPacket}.)

One normally supplies @code{t} for @code{noFragments}, meaning
that only completed packets should be read:  Supplying
@code{nil} for this parameter will result in even
incomplete packets being returned, which is
occasionally useful.

If no input is available, the job blocks until something
arrives, unless both @code{stream$s.dead}
and @code{@@$s.readNilFromDeadStreams} are non-@code{nil},
in which case an empty block plus two @code{nil}s are returned.

@xref{|readAnyStreamPacket}.
@end defun


@c
@node  |readAnyStreamPacket, readLine, readStreamPacket[, message stream functions
@subsection |readAnyStreamPacket
@findex select()
@defun |readAnyStreamPacket @{ [streams] nf millisecs -> [values] tag who s @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This is Muq's closest analogue to the C/Unix select() call:
It waits until input is available on one of the given
streams and returns a block from that stream.

The @code{[streams]} argument must be a block of
streams.  There may currently be at most thirteen
streams in the block.

The @code{nf} argument is same as the @code{noFragments}
@code{readStreamPacket[} argument.

The @code{millisecs} argument must be either @code{nil} or a
positive (not zero!) integer limit on the number of
milliseconds which the job should wait for input to arrive.
If this limit is exceeded, the job will return
@code{[ | nil nil nil}.  (Zero @code{millisecs} values are
disallowed in order to discourage waste of CPU
resources in busy-wait loops.)

The @code{[values]} @code{tag} and @code{who} return
values are as in @code{readStreamPacket[}.

The @code{s} return value is the particular stream
from which the packet was read, or @code{nil} if the call
timed out before input arrived.  (The logically
separate operations of finding a nonempty stream and
reading from it are combined into a single operation in
order to avoid race events -- if they were
separate, some other job might empty the stream between
the two operations.)

Example.  Here is a simple implementation of
@code{sleepJob} based on
@code{|readAnyStreamPacket}:

@example
:   my-sleep-job @{ $ -> @} -> millisecs
    [ | t millisecs
    |readAnyStreamPacket
    pop pop pop ]pop
;
@end example

Example.  Here is a loop that merges two input streams
into one output stream:

@example
:   merge-streams @{ $ $ $ -> @@ @} -> outstream -> instream2 -> instream1
    do@{
        ( Read a block from either input stream: )
        [ instream1 instream2 | t nil
            |readAnyStreamPacket
            -> stream
            -> who
            -> tag

            ( Write the block to output stream: )
	    tag t outstream
	    |writeStreamPacket

	    ( Pop the block and continue: )
            pop pop
        ]pop
    @}
;
@end example

@xref{readStreamPacket[}.

@end defun


@c
@node  readLine, readStreamLine, |readAnyStreamPacket, message stream functions
@subsection readLine
@defun readLine @{ -> std-in-line @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts no parameters, and returns the next
value from the standard input for the current job,
@code{@@$s.standardInput}.  If no input is available, the job
blocks until something arrives.

This function is completely equivalent to @code{@@$s.standardInput readStreamLine pop}.
@end defun


@c
@node  readStreamLine, |writeStreamPacket, readLine, message stream functions
@subsection readStreamLine
@defun readStreamLine @{ stream -> value who @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts one parameter, which must be a message
stream, and returns the next value from that message stream,
beneath the author of the message.

If no input is available, the job blocks until something
arrives.

The 'who' value should normally be the value of
@code{@@$s.actingUser} in the job sending the
value at the time the value was sent.  In the
case of message streams fed from the net, there
is no such @code{@@$s.actingUser} value in
general (since any process anywhere on the
Internet might have sent the value) so the
originating socket is supplied instead.  (It is
possible to send other values using @code{rootWriteStream},
but it is not clear this has any legitimate purpose
other than preserving the above information when
redirecting a message.)
@end defun


@c
@node  |writeStreamPacket, |rootWriteStreamPacket, readStreamLine, message stream functions
@subsection |writeStreamPacket
@defun |writeStreamPacket @{ [block] tag done stream -> [block] tag done @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This is a fundamental function for writing to a stream.
A block of arbitrary values with an arbitrary
tag is written into the @code{stream}.

The @code{done} argument should normally be @code{t},
but may be used to build up a packet using a sequence
of @code{|writeStreamPacket} calls, by setting
@code{done} to @code{nil} on all but the final call
in a sequence.

(Any write to the same stream by another job in the
middle of this sequence will result in premature
completion of the packet, which will emerge from the
stream as two or more packets, with the interrupting
foriegn packets interspersed.)

To facilitate writing the same packet to many streams, the
arguments (other than the stream) are not popped.

If necessary, the job will block until space becomes available.
@xref{|maybeWriteStreamPacket}.
@xref{|rootWriteStreamPacket}.
@end defun


@c
@node  |rootWriteStreamPacket, |maybeWriteStreamPacket, |writeStreamPacket, message stream functions
@subsection |rootWriteStreamPacket
@defun |rootWriteStreamPacket @{ [block] tag done who stream -> [block] tag done @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is identical to @code{|writeStreamPacket}
except that the effective user must be root and an
extra argument, @code{who} is accepted, which becomes
@code{who} value read by @code{readStreamPacket[}.
This allows properly propagating @code{who}
information in system code, where needed.

@xref{|writeStreamPacket}.
@end defun


@c
@node  |maybeWriteStreamPacket, |rootMaybeWriteStreamPacket, |rootWriteStreamPacket, message stream functions
@subsection |maybeWriteStreamPacket
@defun |maybeWriteStreamPacket @{ [block] tag done stream -> [block] tag done @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is exactly the same as
@code{|writeStreamPacket} except that if the packet
cannot be written to @code{stream} due to @code{stream}
being too full, the code returns immediately without
blocking or doing anything else other than popping the
stream argument.  (To discourage busy-waiting loops, no
return value indicating success/failure is provided.)

This function is provided as one way of allowing
messages to be sent to a group of listeners without
risking having the sending job block indefinitely due
to one blocked listener.

If @code{stream} is a proxy and @code{muqnet:maybeWriteStreamPacket}
names a function, that function will be invoked:  This is part of the
inserver support for transparent networking.

In addition, if @code{stream} is a @sc{mos} object
and @code{muf:maybeWriteStreamPacket} names a function, that
function will be invoked: This is additional inserver support for
transparent networking.  The standard
@code{muf:maybeWriteStreamPacket} function redirects the write to
@code{stream.io} if it exists and is a message stream, else issues an
error: This little hack allows requests to be written directly to a
@sc{mos} object rather than to its @code{io} messageStream, saving the caller
the choice between using an extra network roundTrip to fetch the
recipient's @code{io} property, or passing it around in company with the
recipient, at best a nuisance.

@xref{|writeStreamPacket}.
@end defun


@c
@node  |rootMaybeWriteStreamPacket, writeOutputStream, |maybeWriteStreamPacket, message stream functions
@subsection |rootMaybeWriteStreamPacket
@defun |rootMaybeWriteStreamPacket @{ [block] tag done who stream -> [block] tag done @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is identical to @code{|maybeWriteStreamPacket}
except that the effective user must be root and an
extra argument, @code{who} is accepted, which becomes
@code{who} value read by @code{readStreamPacket[}.
This allows properly propagating @code{who}
information in system code, where needed.


@xref{|maybeWriteStreamPacket}.
@end defun


@c
@node  writeOutputStream, writeStream, |rootMaybeWriteStreamPacket, message stream functions
@subsection writeOutputStream
@defun writeOutputStream
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This command accepts one parameter and writes it to the
standard output stream for the current job,
@code{@@$s.dstMsq}.  If necessary, the job will block until
space becomes available.

For conciseness, this function is also available as
@code{,} (comma).

This function is similar to @code{val @@$s.standardOutput
writeStream}, but differs in that
@code{writeOutputStream} also converts any non-string
arguments to string before placing them in the stream,
effectively using the @code{toString} function.

@xref{delimitedWriteToOutputStream}.
@xref{toString}.  @xref{writeStream}.  @xref{rootWriteStream}.
@end defun


@c
@node  writeStream, writeSubstringToStream, writeOutputStream, message stream functions
@subsection writeStream
@defun writeStream @{ string stream -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This command accepts a message under a message stream, and
writes the message to the message stream.  If necessary, the
job will block until space becomes available.
@end defun


@c
@node  writeSubstringToStream, ]writeStreamByLines, writeStream, message stream functions
@subsection writeSubstringToStream
@defun writeSubstringToStream @{ string start stop stream -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This command writes the indicated substring of
@code{string} to @code{stream}.  (Since it is
implemented as a server primitive, it can do
this without actually generating a garbage
substring in the process.)

@example
stack:
"abc\ndef" 1 4 @@$s.standardOutput writeSubstringToStream
bc
stack:
@end example
@end defun


@c
@node  ]writeStreamByLines, rootWriteStream, writeSubstringToStream, message stream functions
@subsection ]writeStreamByLines
@defun ]writeStreamByLines @{ [block] stream -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function writes @code{[block]}, which will usually
be a block of characters, to @code{stream} in
chunks representing a single line whenever possible,
but always in chunks small enough to fit in the stream's buffer.

This function is not normally invoked directly by user code: Instead,
the server generates a call to it if @code{writeStream} encounters a
string too long to fit in the stream.  This is more efficient than
having user code directly call @code{]writeStreamByLines}.
@end defun


@c
@node  rootWriteStream, misc functions, ]writeStreamByLines, message stream functions
@subsection rootWriteStream
@defun rootWriteStream @{ who msg msq -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This command sends @code{msg} to @code{msq} while recording
the originating user as being @code{who}.  For obvious
reasons, this is intended to be a privileged primitive
executable only by tasks which are running root-privileged.
@end defun


@c
@node misc functions, class, rootWriteStream, Core Muf
@section misc functions

@menu
* class::
* copy::
* copyCfn::
* explodeArity::
* implodeArity::
* getMuqnetIo::
* getUniversalTime::
* hash::
* getSocketCharEvent::
* setSocketCharEvent::
* kitchenSinks::
* proxyInfo::
* reset::
* rootLogString::
* rootShutdown::
@end menu

@c
@node  class, copy, misc functions, misc functions
@subsection class
@defun class
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

This function returns the object on which the currently
running method was found, as opposed to the object to which
the message was sent.

As of Muq version -1.0.0, this isn't really implemented, and
may change or vanish in future releases.
@end defun


@c
@node  copy, copyCfn, class, misc functions
@subsection copy
@defun copy
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

This function accepts an arbitrary value and
attempts to return a copy of it.  It is a no-op
on integers and such.  You may not make new
jobs or such this way.  @xref{copyJob}.

Note: @code{copy} currently does not copy
over properties in the propdirs.  This is
probably a bug, but I don't want single
bytecodes doing unlimited amounts of work,
locking up the server for an indefinite
period.
@end defun


@c
@node  copyCfn, explodeArity, copy, misc functions
@subsection copyCfn
@defun copyCfn
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

This function is intended to be used internally by
compiler-generated code, rather than directly by users.  It
accepts a block of value-offset pairs beneath a
compiledFunction instance, and returns a copy of the
compile-function with the indicated offsets in its constant
vector overwritten with the indicated values.

This is the mechanism used to implement true lambdas in lisp
compilers, allowing lambda to be a data constructor as well
as a function constructor.
@end defun


@c
@node  explodeArity, implodeArity, copyCfn, misc functions
@subsection explodeArity
@defun explodeArity @{ arity -> blksIn argsIn blksOut argsOut typ @}
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

This function breaks @code{function$s.arity} values into their
logical fields.  @xref{implodeArity}.
@end defun


@c
@node  implodeArity, getMuqnetIo, explodeArity, misc functions
@subsection implodeArity
@defun implodeArity @{ blksIn argsIn blksOut argsOut typ -> arity @}
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

This function builds @code{function$s.arity} values up out of their
logical fields:

@itemize @bullet
@item
@code{arity}: Integer obtained by doing fn$s.arity on some function.

@item
@code{blksIn}: Integer giving number of stackblocks read by function.

@item
@code{argsIn}: Integer giving number of nonblock arguments read by function.

@item
@code{blksOut}: Integer giving number of stackblocks returned by function.

@item
@code{argsOut}: Integer giving number of nonblocks arguments returned
by function.

@item
@code{typ}: Integer marking special function types:
@display
0: Normal function.
1: Function that never returns.
2: Operator that modifies program counter.
3: Other.
4: CALLI.
5: Q            Function returns unpredictable number of args.
6: START_BLOCK  Special hack for '[' operator.
7: END_BLOCK    Special hack for '|' operator.
8: EAT_BLOCK    Special hack for ']' operator.
9: CALLA        Special hack for JOB_OP_CALLA bytecode.
@end display
@end itemize

The above integer @code{typ} values are subject to 
change in future releases:  To avoid having your
code break in future releases, it is best to use
the corresponding constants:

@example
0  arityNormal
1  arityExit
2  arityBranch
3  arityOther
4  arityCalli
5  arityQ
6  arityStartBlock
7  arityEndBlock
8  arityEatBlock
9  arityCalla
@end example

@end defun


@c
@node  getMuqnetIo, getUniversalTime, implodeArity, misc functions
@subsection getMuqnetIo
@defun getMuqnetIo @{ -> stream @}
@display
@exdent file: joba.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMuqnetIo} function is a special-purpose
convenience in support of transparent networking.

It doesn't do anything not otherwise possible,
just encapsulates a commonly needed bit of
functionality in fast C code.  It checks that
@code{@@$S.muqnetIo} is a message stream,
creating it if it is not (this slot is set to
zero in the child process during a fork to
avoid having it shared), resets the stream
to empty, and then returns it.

@end defun

@c
@node  getUniversalTime, hash, getMuqnetIo, misc functions
@subsection getUniversalTime
@defun getUniversalTime @{ -> milliseconds @}
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{getUniversalTime} function is specified by the
CommonLisp standard as the name for .sys$s.millisecsSince1970:

@example
: getUniversalTime .sys$s.millisecsSince1970 ;
@end example

Making the date-and-time available as a property makes it
easier to find by browsing, and reduces the number of
hardcoded primitives in the server; Making it available as
@code{getUniversalTime} meets the expectations of
experience lisp programmers and will eventually support a
Muq Lisp compiler.

@xref{date}.  @xref{time}.  @xref{printTime}.

@end defun

@c
@node  hash, getSocketCharEvent, getUniversalTime, misc functions
@subsection hash
@defun hash @{ any -> int @}
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{hash} function produces from an arbitrary Muq value a
nonnegative fixnum (integer) value appropriate for use as a hash table
key.  The hash value is based on the contents of constant values and the
addresses of variable values.

@example
123' hash
Stack: 123
'a' hash
Stack: 12416
pop "a" hash
Stack: 3494793310839505136
pop "abc" hash
Stack: 3508640010523902048
pop "abcdefg" hash
Stack: 3508640226122871760
pop "abcdefghijk" hash
Stack: 1255154817073630319
@end example

@xref{|secureHash}.
@xref{|secureDigest}.
@xref{|secureDigestCheck}.
@xref{secureHash}.
@xref{secureHashBinary}.
@xref{secureHashFixnum}.

@end defun

@c
@node  getSocketCharEvent, setSocketCharEvent, hash, misc functions
@subsection getSocketCharEvent
@defun getSocketCharEvent @{ socket int -> event @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{int} value must be in the range 0-255.

The @code{getSocketCharEvent} function allows
you to check the event which will be signalled to
the socket's @code{sessionLeader} when that character
is recieved from the net.  (The character is then
discarded.)  If there is no such event, @code{nil}
will be returned.

(This mechanism is a hack to simplify implementing
special functionality for ^C ^T ^\ and so forth.)

@emph{Bugs:}  This interface should be implemented
via normal properties on the socket rather than
this special hack, but implementing that is not
quite straight-forward.

@xref{setSocketCharEvent}.

@end defun

@c
@node  setSocketCharEvent, kitchenSinks, getSocketCharEvent, misc functions
@subsection setSocketCharEvent
@defun setSocketCharEvent @{ socket int event -> milliseconds @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{int} value must be in the range 0-255.

The @code{setSocketCharEvent} function allows
you to specify the event which will be signalled to
the socket's @code{sessionLeader} when that character
is recieved from the net.
To clear the event, specify @code{nil}.

@xref{getSocketCharEvent}.

@end defun

@c
@node  kitchenSinks, proxyInfo, setSocketCharEvent, misc functions
@subsection kitchenSinks
@defun kitchenSinks @{ -> count @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

It has been suggested that the Muq server supports
everything but the kitchen sink.  This is untrue: Muq has
had a fully functional, @sc{posix}-compliant kitchenSinks
function since version -2.4, 94Mar26.

This function accepts no arguments, and returns the number
of kitchen sinks physically installed on the host system.

If this number is nonzero for your system, add (say)

@example
#define MUQ_KITCHEN_SINKS 2
@end example

to your h/Site-config.h before compiling Muq.

Note: If the number of kitchen sinks on your
system tends to fluctuate erratically, you may
wish to put

@example
setenv KITCHEN_SINKS `ls -lR /dev                 \
                    | egrep -i "kitchen.*sink.*"  \
                    | wc -l`
@end example

@noindent
in your .login script, and then add

@example
-DMUQ_KITCHEN_SINKS=$@{KITCHEN_SINKS@}
@end example

@noindent
to CDEBUGFLAGS and COPTFLAGS in c/Makefile2.in and
c/Makefile2.  On most systems, this will automatically
give you the correct value each time you recompile.

If your unix has non-standard kitchen-sink
drivers, you may need to edit the above regular
expression to match your local conventions.
@end defun


@c
@node  proxyInfo, reset, kitchenSinks, misc functions
@subsection proxyInfo
@defun proxyInfo @{ proxy -> guest i0 i1 i2 xx yy @}
@display
@exdent file: jobc.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{proxyInfo} returns the remote-reference information
hidden inside a proxy object, information normally of interest
only to a few pieces of networking-support software.

The @code{proxy} argument must be a proxy -- @code{remote?}
must return non-@code{nil} on it.

The @code{guest} return value is the local Guest object
representing the owner of the remote object.

The @code{i0 i2 i1} return values are integers encoding the
dbref for the remote object on its home server, in the
format generated by @code{dbrefToInts3}.

The @code{xx} and @code{yy} values are currently undefined,
but reserved for future expansion.

@xref{remote?}.
@xref{dbrefToInts3}.
@xref{]makeProxy}.

@end defun


@c
@node  reset, rootLogString, proxyInfo, misc functions
@subsection reset
@defun reset
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{reset} function is a generic way of resetting
various things to a default configuration:
 
This is used to clear an instance of Class Assembler before
beginning compilation of a new function.

This is used to clear an instance of Class Stack to empty.

This is used to clear an instance of Class Stream to empty.

This is used to clear an instance of Class Lock to empty.

Other effects will probably be defined in future.
@end defun


@c
@node  rootLogString, rootShutdown, reset, misc functions
@subsection rootLogString
@defun rootLog @{ "sometext\n" -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rootLogString} function appends the given text to
the server log, which is specified via the @code{--logfile=myfile.log}
commandline switch.

An error will be signaled if @code{@@$s.actingUser} is not
root-privileged.

There is also a @code{muf:l,} function intended to be called by
non-root users:  If @code{.muq$s.allowUserLogging} is non-@code{nil}, this
will also write to the logfile.  Otherwise, it silently does nothing.

Note that no quotas are applied to the logfile, hence (for
example) if you log some user-triggerable activity, you open
yourself to a disk-flood attack: a hostile user can attempt
to trigger enough logging to fill the host disk partition,
preventing expansion of the db files and thus crashing or
halting the server.

@xref{]rootLogPrint}.
@end defun


@c
@node  rootShutdown, object creation functions, rootLogString, misc functions
@subsection rootShutdown
@defun rootShutdown
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{rootShutdown} function flushes virtual memory to
disk and shuts down the server.  Typing control-C (or your
selected equivalent) at the console has the same effect.
@end defun


@c
@node object creation functions, makeAssembler, rootShutdown, Core Muf
@section object creation functions
@cindex Object creation functions

@xref{rootMakeUser}.

@menu
* makeAssembler::
* makeBignum::
* makeEvent::
* makeFunction::
* makeJobQueue::
* makeMuf::
* makeHash::
* makeIndex::
* makePlain::
* makePackage::
* makeLock::
* makeMessageStream::
* makeBidirectionalMessageStream::
* makeStream::
* makeStack::
* makeString::
* makeSymbol::
* makeVector::
* makeEphemeralVector::
* makeSocket::
* ]makeProxy::
@end menu

@c
@node  makeAssembler, makeBignum, object creation functions, object creation functions
@subsection makeAssembler
@defun makeAssembler @{ -> asm @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeAssembler} function creates and returns an
instance of Class Assembler.
@end defun


@c
@node  makeBignum, makeEvent, makeAssembler, object creation functions
@subsection makeBignum
@defun makeBignum
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeBignum} function accepts a string and returns an
instance of Class Bignum.  This function is included primarily
for the benefit of the Muq selftest suite:  Normal users should
seldom if ever have any cause to use it.

@end defun


@c
@node  makeEvent, makeFunction, makeBignum, object creation functions
@subsection makeEvent
@defun makeEvent
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeEvent} function creates and returns an
instance of Class Event.
@end defun


@c
@node  makeFunction, makeJobQueue, makeEvent, object creation functions
@subsection makeFunction
@defun makeFunction @{ -> function @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeFunction} function creates and returns an
instance of Class Function.

(It is important not to confuse @code{function}s, which
contain source code and documentation, with
@code{compiledFunction}s, which contain compiled constants
and bytecodes, and may be created only via instances of
Class Assembler. @xref{makeAssembler}.)
@end defun


@c
@node  makeJobQueue, makeMuf, makeFunction, object creation functions
@subsection makeJobQueue
@defun makeJobQueue @{ -> jobQueue @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeJobQueue} function creates and returns an
instance of Class JobQueue.  You may do coarse-grain
job scheduling by moving jobs between such queues.
@xref{queueJob}.
@end defun


@c
@node  makeMuf, makeHash, makeJobQueue, object creation functions
@subsection makeMuf
@defun makeMuf
@display
@exdent file: job.t
@exdent package: muf
@exdent status: temporary
@end display

The @code{makeMuf} function accepts a function argument and
creates and returns a vector suitable for use as a
compilation context record for the inserver muf compiler.

@sc{note}: This call, like the inserver muf compiler, is likely to
vanish in a future release.
@end defun


@c
@node  makeHash, makeIndex, makeMuf, object creation functions
@subsection makeHash
@cindex Hashtable
@defun makeHash
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeHash} function creates and returns an
instance of Class Hash, a hashed btree.

Since these objects store their properties in a hashed btree, they
are often used as hashtables:

@example
Stack:
makeHash --> datebook
Stack:
"555-1212 -- cute" --> datebook["kim"]
Stack:
"555-2121 -- never again" --> datebook["pat"]
Stack:
datebook["kim"]
Stack: "555-1212 -- cute"
@end example

@xref{makeIndex}.
@xref{low-level btree functions}.

@end defun


@c
@node  makeIndex, makePlain, makeHash, object creation functions
@subsection makeIndex
@cindex Index
@defun makeIndex
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeIndex} function creates and returns an
instance of Class Index which will keep key-val pairs in
sorted btrees (as opposed to objects made by @code{makeHash},
which stores key-val pairs in a hashed btree.  The two types
of objects are in all other respects identical.

Indices objects are useful when you wish to iterate over all
keys in natural order, rather than the random-looking order produced by
hashed btrees.  (For a more extended discussion of the tradeoffs:
@xref{low-level btree functions}.)

@example
Stack:
makeIndex --> datebook
Stack:
"555-1212 -- cute" --> datebook["kim"]
Stack:
"555-2121 -- never again" --> datebook["pat"]
Stack:
datebook foreach key val do@{ [ "%s: %s\n" key val | ]print , @}

@end example

@xref{makeHash}.

@end defun


@c
@node  makePlain, makePackage, makeIndex, object creation functions
@subsection makePlain
@cindex Plain
@defun makePlain
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makePlain} function creates and returns an
instance of Class Plain, which represents the simplest
kind of built-in class, unspecialized to any particular
purpose.

Since Class Plain has no specialized functionality, there
is little reason to create an instance of it:  Class Plain
and the primitive @code{makePlain} are included mostly
for completeness.

Class Plain, like the other built-in classes, can be used
to store key-val pairs much as can Index:  The trade-off
is that Plain objects do not have four slots pre-allocated
to hold the btrees, but finding the associated btrees (if
any) requires an additional btree lookup to find the btree
itself.  Thus, if you need to create many objects which can
be used to store key-val pairs, but very few of which actually
do so, you might conceivably wish to use Plain rather than
Index objects to save a little space.

@xref{makeIndex}.

@end defun


@c
@node  makePackage, makeLock, makePlain, object creation functions
@subsection makePackage
@defun makePackage
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ name -> package @}
@end example

The @code{makePackage} function creates and returns an
instance of Class Package.  There must be no package of
the given name or nickname in @@$s.lib.  The new package
is automatically entered in @@$s.lib under given name.

@sc{note}: Most of the time, the @code{inPackage} function
is what you really want.  @xref{inPackage}.
@end defun


@c
@node  makeLock, makeMessageStream, makePackage, object creation functions
@subsection makeLock
@defun makeLock @{ -> lock @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeLock} function creates and returns an
instance of Class Lock.

@xref{reset}.
@end defun


@c
@node  makeMessageStream, makeBidirectionalMessageStream, makeLock, object creation functions
@subsection makeMessageStream
@defun makeMessageStream @{ -> messageStream @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{makeMessageStream} function creates and returns an
instance of Class MessageStream.

@end defun


@c
@node  makeBidirectionalMessageStream, makeStream, makeMessageStream, object creation functions
@subsection makeBidirectionalMessageStream
@defun makeBidirectionalMessageStream @{ -> end0 end1 @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeBidirectionalMessageStream} function
creates a bidirectional message stream and returns
both ends.  Data written to one end is read from the
other.

It is currently implemented as:

@example
: makeBidirectionalMessageStream @{ -> $ $ @}

    makeMessageStream -> a
    makeMessageStream -> b

    a --> b$s.twin
    b --> a$s.twin

    a b   
;
@end example

@end defun


@c
@node  makeStream, makeStack, makeBidirectionalMessageStream, object creation functions
@subsection makeStream
@defun makeStream
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeStream} function creates and returns an
instance of Class Stream.
@end defun


@c
@node  makeStack, makeString, makeStream, object creation functions
@subsection makeStack
@defun makeStack @{ -> stack @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeStack} function creates and returns an
instance of Class Stack.
@end defun


@c
@node  makeString, makeSymbol, makeStack, object creation functions
@subsection makeString
@defun makeString @{ val len -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeString} function accepts a length atop a character or
integer value, and creates and returns a string of that length, with all
slots initialized to that value.

@example
Stack:
'a' 3 makeString
Stack: "aaa"
pop 90 3 makeString
Stack: "ZZZ"
@end example

@xref{]print}.
@xref{]join}.
@end defun


@c
@node  makeSymbol, makeVector, makeString, object creation functions
@subsection makeSymbol
@defun makeSymbol @{ -> symbol @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeSymbol} function creates an uninterned symbol, with
no name or package.

@xref{intern}.
@xref{]makeSymbol}.
@xref{|findSymbol?}.
@end defun


@c
@node  makeVector, makeEphemeralVector, makeSymbol, object creation functions
@subsection makeVector
@findex vec
@defun makeVector @{ val len -> vec @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeVector} function accepts a length atop a
value, and creates and returns a vector of that length,
with all slots initialized to that value.

For those of us addicted to conciseness, this function
is also available under the synonym @code{vec}.

Similar functions
@code{makeVectorI01}
@code{makeVectorI08}
@code{makeVectorI16}
@code{makeVectorI32}
@code{makeVectorF32}
@code{makeVectorF64} are also available.

Note that a key distinction between @code{makeVectorI08}
and the string primitives is that the latter return
values marked read-only, while @code{]makeVectorI08}
returns a value marked read-write.

@xref{]makeVector}.
@xref{makeEphemeralVector}.
@end defun


@c
@node  makeEphemeralVector, makeSocket, makeVector, object creation functions
@subsection makeEphemeralVector
@findex evec
@defun makeEphemeralVector @{ val len -> vec @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeEphemeralVector} function is much like
the @code{makeVector} function, except that it returns
an ephemeral (stack-allocated) vector instead of a
vanilla (heap-allocated) vector.

For those of us addicted to conciseness, this function
is also available under the synonym @code{evec}.

@xref{]makeEphemeralVector}, for a discussion of the
advantage and dangers of using ephemeral vectors.
@end defun


@c
@node  makeSocket, ]makeProxy, makeEphemeralVector, object creation functions
@subsection makeSocket
@defun makeSocket
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeSocket} function creates and returns a
new instance of Class Socket.  This is merely an
object in the Muq db:  No unix-level socket is
created at this point.

@xref{]listenOnSocket}.
@xref{]openSocket}.
@xref{]rootPopenSocket}.

@end defun


@c
@node  ]makeProxy, package functions, makeSocket, object creation functions
@subsection makeProxy
@defun ]makeProxy @{ [args] -> proxy @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]makeProxy} function creates and returns a
new instance of Class Proxy.  There is normally no
reason to do this except in the Muq selftest code:
Proxies are normally created implicitly by the
transparent networking support code, in particular
by @code{|debyte}.

@table @code
@item :guest
One Guest object representing the remote owner of the
proxied object.

@item :i0 :i1 :i2
Three fixnums (integers) giving the dbref of the proxied object
on its home server, in @code{dbrefToInts3} format.
@end table

@example
[   :guest rootMakeGuest
    :i0 2104643567 :i1 1522621456 :i2 2621455621
|   ]makeProxy
@end example

@xref{|debyte}.
@xref{proxyInfo}.
@xref{dbrefToInts3}.

@end defun


@c
@node package functions, ]inPackage, ]makeProxy, Core Muf
@section package functions
@cindex Package functions

@menu
* ]inPackage::
* ]makePackage::
* ]renamePackage::
* deletePackage::
* export::
* findPackage::
* import::
* inPackage::
* intern::
* unexport::
* unintern::
* unusePackage::
* usePackage::
@end menu

@c
@node  ]inPackage, ]makePackage, package functions, package functions
@subsection ]inPackage
@defun ]inPackage
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ [names] -> @}
@end example

Switch to the package with the first name given.  If it does
not already exist in @code{@@$s.lib}, create it and assign any
remaining names given as nicknames.

This function is usually used in a source file before
beginning a series of function and data definitions intended
for the named package; Usually any "export" declarations
follow shortly thereafter.
@end defun


@c
@node  ]makePackage, ]renamePackage, ]inPackage, package functions
@subsection ]makePackage
@defun ]makePackage
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ [names] -> pkg @}
@end example

This function creates a package with the first name given,
and enters it into @code{@@$s.lib} under that name.  Any remaining
names are assigned as nicknames of the package.

If the last value in the block is a DatabaseFile instance,
and the acting user controls that instance, then the new
package will be created in the given database file.  (Otherwise,
as usual, it will be created in the same database file as
the currently active package.)
@end defun


@c
@node  ]renamePackage, deletePackage, ]makePackage, package functions
@subsection ]renamePackage
@defun ]renamePackage
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ [names] package -> @}
@end example

@code{Package} must be in @code{@@$s.lib}; It may be the
package itself or a name for it.

The package is deleted from @code{@@$s.lib} and re-entered under the
first name given; Any other names are entered as nicknames.
In any event, all old nicknames are lost.

This function is useful, for example, when renaming a
production version of a package before loading in a test
version.
@end defun


@c
@node  deletePackage, export, ]renamePackage, package functions
@subsection deletePackage
@defun deletePackage
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ package -> @}
@end example

@code{Package} must be in @code{@@$s.lib};  It may be the package
itself or a name for it.

The package is deleted from @code{@@$s.lib}.
@end defun


@c
@node  export, findPackage, deletePackage, package functions
@subsection export
@defun export
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ symbol -> @}
@end example

The given symbol is entered into the public area of the
current package (@code{@@$s.package}), making it available
to other packages which 'use' this package.

If the given symbol is not already internal to the current
package, it is made so.
@end defun


@c
@node  findPackage, import, export, package functions
@subsection findPackage
@defun findPackage
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ package -> pkg @}
@end example

If @code{package} is a package, it is returned.

If @code{package} is a string, the corresponding
package in @code{@@$s.lib} is found and returned.  It
is an error for there to be no such package.
@end defun


@c
@node  import, inPackage, findPackage, package functions
@subsection import
@defun import
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ symbol -> @}
@end example

The given symbol is made internal to the current
package (@code{@@$s.package}) if is not already.
@end defun


@c
@node  inPackage, intern, import, package functions
@subsection inPackage
@defun inPackage
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ names -> @}
@end example

This function is exactly equivalent to @code{]inPackage}
when the latter is given only one name.  @xref{]inPackage}.
@end defun


@c
@node  intern, unexport, inPackage, package functions
@subsection intern
@findex stringSymbol
@defun intern @{ name -> symbol old @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

If a symbol with the given name is visible in the
current package (@code{@@$s.package}), it is returned.
Otherwise a fresh internal symbol with that name
is created and returned.

The return value @code{old} will be @code{nil} iff a fresh
symbol was created.  Do @sc{not} make assumptions about the
particular value returned in the non-@code{nil} case.

(A more logical name for @code{intern} might be
@code{stringSymbol}, but CommonLisp follows tradition
rather than logic in this case, and @sc{muf} follows
CommonLisp.)

@xref{makeSymbol}.
@xref{|findSymbol?}.
@xref{unintern}.
@xref{]makeSymbol}.
@end defun



@c
@node  unexport, unintern, intern, package functions
@subsection unexport
@defun unexport
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ symbol -> @}
@end example

If the given symbol is currently exported from the
current package (@code{@@$s.package}), it is removed from
the public area of that package.
@end defun


@c
@node  unintern, unusePackage, unexport, package functions
@subsection unintern
@defun unintern
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ symbol -> @}
@end example

If the given symbol is in the current package
(@code{@@$s.package}), it is removed from the private area
of that package.  If it is exported from the current
package, it is likewise removed from the public area of that
package.
@end defun


@c
@node  unusePackage, usePackage, unintern, package functions
@subsection unusePackage
@defun unusePackage
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ package -> @}
@end example

@code{Package} may be a name or package; If it is currently
"used" by the current package -- that is, if it is in
@code{@@$s.package$s.usedPackages} -- it is removed.
@end defun


@c
@node  usePackage, path functions, unusePackage, package functions
@subsection usePackage
@defun usePackage @{ package -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@code{Package} may be a name or package; If it is not
already "used" by the current package -- that is, if it is
not in @code{@@$s.package$s.usedPackages} -- it is added.

This has the effect of making all symbols exported by
@code{package} visible inside the current package.
@end defun


@c
@node path functions, actingUser, usePackage, Core Muf
@section path functions
@cindex Path functions

@menu
* actingUser::
* actualUser::
* getHere::
* job::
* currentCompiledFunction::
* root::
* self::
* setHere::
@end menu

@c
@node  actingUser, actualUser, path functions, path functions
@subsection actingUser
@defun actingUser
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{actingUser} function returns the "current user" as set
by login and as modified by any set-uid type commands.

This is equivalent to @code{@@$s.actingUser}.

For consistency with user-relative @code{me.x.y} style paths,
this function is also available as @code{me}.
@end defun


@c
@node  actualUser, getHere, actingUser, path functions
@subsection actualUser
@defun actualUser
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{actualUser} function returns the "current user" as set by
login, ignoring the effect of any set-uid type commands.  This is
equivalent to @code{@@$s.actualUser}.
@end defun


@c
@node  getHere, job, actualUser, path functions
@subsection getHere
@defun getHere
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getHere} function returns the "current object" as set
by the @code{cd} command.

This is equivalent to @code{@@$s.here}.

@end defun


@c
@node  job, currentCompiledFunction, getHere, path functions
@subsection job
@defun job @{ -> job @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{job} function returns the currently executing job.

For consistency with job-relative @code{@@.x.y} style paths, this
function is also available as @code{@@} (at-sign).
@end defun


@c
@node  currentCompiledFunction, root, job, path functions
@subsection currentCompiledFunction
@defun currentCompiledFunction @{ -> cfn @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{currentCompiledFunction} function returns
the currently compiled function.  (It isn't really a
path function, but it seems to below with @code{job}
and kin anyhow.)

This @code{currentCompiledFunction} function is
useful when code within a function needs to refer
to that function, which would otherwise be
difficult since the compiledFunction does not yet
exist when the code for it is being specified.

(Generic functions are one common example kind of
compiled-functions which need to refer to
themselves.)
@end defun


@c
@node  root, self, currentCompiledFunction, path functions
@subsection root
@defun root
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{root} function returns the current logical root of
the Muq "filesystem".  This is equivalent to @code{@@$s.root}.
Note that this may sometimes to deliberately set to a value
other than the default root, much as a unix process may use
"chroot" to make a subset of the unix filesystem appear to
be the full filesystem.

For consistency with user-relative @code{.x.y} style paths,
this function is also available as @code{.}.
@end defun


@c
@node  self, setHere, root, path functions
@subsection self
@defun self
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{self} function returns the object which most
recently recieved a message.  This is for methods which wish
to send another message to it, and such.  @xref{class}.

This is not fully implemented in Muq version -1.0.0, and
may change somewhat in future releases.
@end defun


@c
@node  setHere, posix functions, self, path functions
@subsection setHere
@findex cd
@defun setHere
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{setHere} function accepts an object and makes it
the "current object," @code{@@$s.here}.

This is equivalent to @code{arg --> @@$s.here}.

For unixoids and concision, this function is also available
as @code{cd}.
@end defun


@c
@node posix functions, choosing a port number, setHere, Core Muf
@section posix functions

These functions provide access to host and network
resources.  They will usually be of interest only to
Root-privileged programmers.

@menu
* choosing a port number::
* rootAllActiveSockets[::
* ]closeSocket::
* ]listenOnSocket::
* ]openSocket::
* ]rootPopenSocket::
@end menu

@c
@node  choosing a port number, rootAllActiveSockets[, posix functions, posix functions
@subsection Choosing a port number
@cindex Choosing a port number
@cindex Port number, choosing a

Port numbers are integers in the range
1-65535 used to distinguish between different
services offered by a given machine on the
internet.  Each internet machine has one space
of 65535 port numbers for @sc{tcp} connections
and a second, separate space of 65535 port
numbers for @sc{udp} connections.

These port numbers form the only way of distinguishing
between different processes or users on the same
machine using the @sc{udp} and @sc{tcp} Internet
protocols:  An internet IP address (128.95.44.22, say)
plus a port number form the most specific Internet
address these protocols understand.

Every process communicating over the Internet via these
protocols must have at least one port number assigned
to it.  A process which is communicating simultaneously
with many other processes may have dozens or even
hundreds of port numbers assigned to it.

Some port numbers have only temporary significance,
being assigned for the duration of a program run.  Port
numbers assigned to a telnet or rlogin session are in
this category.  These numbers are called "ephemeral"
and are usually picked arbitrarily by the operating
system from the set of currently free port numbers.

Other port numbers have specific, widely understood
meanings, which processes on other machines use to
locate specific services.  For example, 'sendmail'
always runs on @sc{tcp} port 25, and other systems
count on this when sending mail.  These numbers
are called 'well-known' numbers, and the best
established ones are published periodically:
see 
@strong{http://ds.internic.net/rfc/rfc1700.txt}
(mirrored at
@strong{http://sunsite.unc.edu/pub/docs/rfc/rfc1700.txt}).

Certain ranges of port numbers have special
significance.

In particular, ports 1-1023 (in both the @sc{tcp} and
@sc{udp} address spaces) are reserved for processes
running with unix root privilege.  This provides a
certain (weak) amount of authentication: If you connect
to a port in this range, you can have some confidence
that the process you contact was set up by the
authority controlling that machine, rather that by some
arbitrary user.

Unix typically (but not always @footnote{W R
Stevens in @emph{Unix Network Programming p304}
notes that "The system doesn't automatically
assign a port greater than 5000.  It leaves these
ports for user-developed, nonpriveleged servers."
Solaris appears to automatically assign all ports,
alas.}) allocates ephemeral @sc{tcp} ports from
the range 1024-5000, and ephemeral @sc{udp} ports
from the range 1024-32767.  If your are picking a
well-known port for a new service, you might want
to avoid these ranges, in order to avoid finding
yourself unable to restart your server due to
(say) some telnet session having been assigned
your port number.

In addition, it is best to avoid ports used by other
well-known services, both to avoid confusion, and to
avoid conflict should you wish to run one of those
services on your machine at some point.  For example,
the X Window System uses @sc{tcp} ports 6000-6063,
which makes this an excellent port range to avoid.

Note that @sc{tcp} ports in the range 10,000 -> 65,535
are almost entirely unused at present -- you don't
@emph{have} to try and squeeze into the crowded
5000-9999 range.

A reasonable choice for a new @sc{tcp} port number for
an in-db Muq daemon supporting local, experimental, or
game functionality would be '2' followed by the last
four digits of your phone number.  This scatters them
randomly, minimizing the chance of port-choice
collisions, without depending on a central registration
authority.

For production in-db Muq daemons which parallel the
function of an existing unix daemon at port xyz, I
suggest using port 30xyz: Port 30007 for echo, 30011
for systat listing of users, 30079 for finger, 30023
for telnet, 30025 for mail, 30080 for HTTP, &tc.

For production in-db Muq daemons not corresponding to
an existing unix daemon, I suggest using ports
31000-31999, ideally registering them with some central
coordinator.

For random test scripts connecting only to the local
machine but needing a specific port, I suggest using
ports 32000-32767.

When multiple Muq servers must export a full complement
of daemons from the same @sc{ip} address, I suggest the
second use the range 32000-33999 in place of
30000-31999, the third use the range 34000-35999, and
so forth.


@c
@node  rootAllActiveSockets[, ]closeSocket, choosing a port number, posix functions
@subsection rootAllActiveSockets[
@defun rootAllActiveSockets[ @{ -> [sockets] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{rootAllActiveSockets[} function returns
a block containing all socket objects currently
associated with a file descriptor or unix socket.

It provides the basic hook for taking an inventory
of all online users, all running daemons, and such.

You may examine @code{socket$S.type} to distinguish
different types of sockets, or @code{socket$S.session}
to find associated jobs.

@quotation
It would be more consistent with the Muq design
philosophy to provide a class Socket-Set (say),
with active sockets appearing as properties, but
in this case I felt the extra overhead of
introducing another hardwired class to be
unjustified.
@end quotation
@end defun


@c
@node  ]closeSocket, ]listenOnSocket, rootAllActiveSockets[, posix functions
@subsection ]closeSocket
@deffn Control-struct ]closeSocket
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

@example
@{ [ :socket socket
   | ]closeSocket
@}
@end example

The @code{]closeSocket} closes a @sc{tcp/ip}
connection from the Muqserver to another process.  The
@code{socket} value must be a socket.

@end deffn


@c
@node  ]listenOnSocket, ]openSocket, ]closeSocket, posix functions
@subsection ]listenOnSocket
@deffn Control-struct ]listenOnSocket
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

@example
@{  [ :socket socket
     :port 4201
     :protocol :stream            ( optional )
     :addressFamily :internet    ( optional )
     :interfaces :any             ( optional )
   | ]listenOnSocket
@}
@end example

The @code{]listenOnSocket} function sets the Muq server to
listen for network connections on the given unix port
number.

The @code{:socket} parameter must be a socket with a
@code{socket$S.standardOutput} set to a messageStream.
A typical choice of messageStream
is @code{@@$s.standardInput} (the input message stream
for the job issuing the @code{]listenOnSocket}
request).

If @code{:protocol} is @code{:stream} (or omitted),
each connection accepted will result in
the creation of a Socket bound to the connection, which
will be placed in the messageStream @code{socket$S.standardOutput}.  The
presumption is that some job is reading this
message stream and forking off a job for each
connection accepted.

If @code{:protocol} is @code{:datagram},
@code{socket$S.type} will be set to @code{:udp}
and the socket will return datagrams read from
that port.

The @code{:addressFamily} parameter must currently always
be @code{:internet} if provided.

The @code{:interfaces} parameter must currently always
be @code{:any} if provided.

The @code{:port} parameter must be an integer
specifying the unix port on which to listen.
@xref{choosing a port number}.

Here is a complete short example of listening on
a socket.  Normally the work done in the example
would involve three jobs, one for the listening
socket, one for the server (forked by the listening
job) and one for the client, probably on another
machine.  Here we do everything inline in one job
to keep things simple;  See the nanomud for a
more realistic example.

@example
( Create a socket listening      )
( for connections on port 32123: )
makeSocket --> *listen*
makeMessageStream --> *listen-output*
*listen-output* --> *listen*$S.standardOutput
[ :socket *listen*
  :port 32123
  :protocol :stream
| ]listenOnSocket

( Open a client connection: )
makeSocket --> *client*
makeMessageStream --> *client-input*
makeMessageStream --> *client-output*
*client-input* --> *client*$S.standardInput
*client-output* --> *client*$S.standardOutput
[ :socket *client*
  :port 32123
  :protocol :stream
| ]openSocket

( Accept the connection, creating server: )
*listen-output* readStreamLine --> *server* --> *opcode*
( *server* is the new socket; *opcode* is "new" )
makeMessageStream --> *server-input*
makeMessageStream --> *server-output*
*server-input* --> *server*$S.standardInput
*server-output* --> *server*$S.standardOutput

( Send a line from client to server: )
"This is a test\n" *client-input* writeStream

( Read line at server end: )
*server-output* readStreamLine --> *who* --> *line*
( *who* == *server*  and *line* is our line of text )

( Send a line from server to client: )
"This is not a test\n" *server-input* writeStream

( Read line at client end: )
*client-output* readStreamLine --> *who* --> *line*
( *who* == *client* and *line* is our line of text )

( Close all ports: )
[ :socket *client* | ]closeSocket
[ :socket *server* | ]closeSocket
[ :socket *listen* | ]closeSocket
@end example

@end deffn


@c
@node  ]openSocket, ]rootPopenSocket, ]listenOnSocket, posix functions
@subsection ]openSocket
@deffn Control-struct ]openSocket
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

@c addressFamily and protocol are needed for socket()
@c host is for 'connect()'.

@example
@{  [ :socket socket
     :port 4201                   ( optional )
     :host "sl.tcp.com"           ( optional )
     :protocol :stream            ( optional )
     :addressFamily :internet    ( optional )
   | ]openSocket
@}
@end example

@example
@{  [ :socket socket
     :port 4201                   ( optional )
     :host "128.95.44.22"         ( optional )
     :protocol :stream            ( optional )
     :addressFamily :internet    ( optional )
   | ]openSocket
@}
@end example

@example
@{  [ :socket socket
     :port 4201                       ( optional )
     :ip0 128 :ip1 95 :ip2 44 :ip3 22 ( optional )
     :protocol :stream                ( optional )
     :addressFamily :internet        ( optional )
   | ]openSocket
@}
@end example

@example
@{  [ :socket socket
     :protocol :datagram              ( optional )
     :addressFamily :internet        ( optional )
   | ]openSocket
@}
@end example

The @code{]openSocket} can open a @sc{tcp/ip} connection
from the Muq server to another process, or a @sc{udp/ip}
datagram socket.

@quotation
@cartouche
@strong{Allowing arbitrary outbound network connections can pose serious
security problems!}  For example, it may be used to connect
to NFS filesystems on your subnet and modify them or
capture passphrase files, or it may be used to connect to X servers
on your subnet and capture keyboard type-in (including passphrases)
or issue commands like "rm *" to open shell windows.  For
these and other reasons, Muq provides bitmaps controlling
which ports may be specified by user and root jobs:
See the @code{--destports} and @code{--rootdestports}
commandline arguments for Muq.
@end cartouche
@end quotation

By default, user jobs may open @sc{tcp} or @sc{udp} connections to
the following ports:

@table @strong
@item 7
echo
@item 9
discard
@item 13
daytime
@item 19
chargen (character generator)
@item 20
ftp-data
@item 21
ftp
@item 23
telnet
@item 37
time
@item 53
domain (Domain Namserver system)
@item 70
gopher
@item 79
finger
@item 80
wwweb
@item 113
auth
@item 119
nntp
@item 123
ntp
@item 194
irc
@item 517
talk
@item 518
ntalk
@item 532
netnews
@item 750
kerberos
@item mud-ports
 1234, 1701, 1812, 1863, 1908, 1919, 1941, 1963, 1969,
 1973, 1984, 2000, 2001, 2002, 2010, 2069, 2093, 2095,
 2113, 2150, 2222, 2283, 2345, 2444, 2477, 2508, 2525,
 2700, 2777, 2779, 2800, 2994, 2999, 3000, 3011, 3019,
 3026, 3056, 3287, 3456, 3500, 3742, 3754, 3779, 4000,
 4001, 4004, 4040, 4080, 4201, 4242, 4321, 4402, 4441,
 4444, 4445, 4567, 4711, 5000, 5150, 5195, 5440, 5454,
 5555, 5757, 6123, 6239, 6250, 6666, 6669, 6715, 6789,
 6886, 6889, 6969, 6970, 6971, 6972, 6996, 6999,
 7000-17006, 17008-65535
@item 8080
wwweb
@end table

The @code{:socket} parameter must be a socket ; It
should be either freshly created
@xref{makeSocket}, or else one which has been
closed by @xref{]closeSocket}.  Before making this
call, you should set the socket's
@code{$s.standardInput} and @code{$s.standardOutput}
keys to the message streams which you wish the socket
connection to use.

The @code{:addressFamily} parameter may be omitted, and
must currently always be @code{:internet} if present; It is
provided for future expansion of functionality.

The @code{:protocol} parameter may be omitted, in which
case it defaults to @code{:stream}, indicating a @sc{tcp}
connection.  If @code{:datagram} is specified, an @sc{udp}
socket is opened.

When writing to @sc{udp} sockets, you can (and usually
should) specify the destination address and port
on a datagram-by-datagram basis using
@code{|writeStreamPacket} and the keywords
@code{:ip0}, @code{:ip1}, @code{:ip2}, @code{:ip3}
and @code{:port}.  For example, to send "This is a test"
to port 9 at 128.95.44.22 you might do:

@example
[ :ip0 128 :ip1 95 :ip2 44 :ip3 22 :port 9
  'T' 'h' 'i' 's' ' ' 'i' 's' ' ' 'a' ' ' 't' 'e' 's' 't'
| "txt" t my-udp-stream |writeStreamPacket pop pop ]pop
@end example

The keyval pairs may be anywhere in the block, although
grouping them at the beginning or end is recommended.
If the address or port is not specified this way, the
values from the previous datagram are used, or failing
that, those specified in the @code{]openSocket}.

In the current Muq implementation, you cannot count on
being able to send datagrams of more than 2000 bytes
if @code{"\n" -> "\r\n"} conversion is enabled, or of more
than 4000 bytes if this conversion is disabled
(@code{socket$S.nlToCrnlOnOutput} property);
similar size contraints apply to datagram reception.
Oversize datagrams are likely to be silently dropped.
Let me know if these limitations become a problem.

Note that sending datagrams larger than the path
MTU (Maximum Transmission Unit) is inefficient and
normally avoided by good networking code.  Typical
wide-area network MTU values range from 500 to 1500
bytes.

@quotation
"As an experiment, this ... was run numerous times to
various hosts around the world.  Fifteen countries
(including Antarctica) were reached and various
transatlantic and transpacific links were used. ...
Out of 18 runs, only 2 had a path MTU of less than
1500." -- W R Stevens, @emph{@sc{TCP/IP} Illustrated
Vol I 1994}.
@end quotation

You should usually set @code{socket$s.inputByLines}
to @code{nil} on a @sc{udp} socket, since you will want
to read complete datagrams one at a time, rather than
single lines from them.

@quotation
@cartouche
Remember that the Internet @sc{udp} datagram service
is @strong{unreliable}!  Datagrams can and frequently
do get lost without any notification to client or
server.  Any code which uses @sc{udp} datagrams must
be prepared to deal with this.
@end cartouche
@end quotation

The @code{:host} parameter gives the destination host
to contact, and should be a string containing
either a dotted-decimal Internet address such as
"128.95.44.22" or else a symbolic Internet address such as
"sl.tcp.com".  Alternatively, the @code{:ip0}, @code{:ip1},
@code{:ip2} and @code{:ip3} parameters may be used to
specify the destination host address using four integers.
Providing both forms of address is an error;  If neither
is provided, the default localhost address of 127.0.0.1
will be used.

The @code{:port} parameter must be an integer specifying the
unix port to which to connect.  If no port is specified,
the default telnet port 23 will be used.

@strong{Example.}  Here's a function which prints one line from
the given port on the host machine:

@example
:   print-port @{ $ -> @} -> port

    ( Create a socket for network I/O: )
    makeSocket -> socket

    ( Hook up input and output streams to it: )
    makeMessageStream -> in
    makeMessageStream -> out
    in  --> socket$s.standardInput
    out --> socket$s.standardOutput

    ( Open a connection to given port: )
    [ :socket socket :port port | ]openSocket

    ( Read and print one line from socket: )
    out readStreamLine pop ,

    ( Close the socket: )
    [ :socket socket | ]closeSocket
;
@end example

Here is an example of @code{print-port} in action.
Port 13 ("daytime") supplies the current date and time.
Port 19 ("chargen") generates an endless stream
of text.

@example
stack:
13 print-port
Thu Oct 19 00:28:06 1995 
stack:
19 print-port
 !"#$%&'()*+,-./0123456789:;<=>?@@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefg 
stack:
@end example

@strong{Example.}  Here's code to communicate via
a pair of @sc{udp} ports.  Remember that @sc{udp}
is an unreliable protocol, so any packet transmitted
may be silently lost.  Normally the client and
server code would be run on different machines,
of course!

@example
( Create socket to listen for  )
( UDP datagrams on port 62121: )
makeSocket --> *server*
makeMessageStream --> *server-input*
makeMessageStream --> *server-output*
*server-input*  --> *server*$S.standardInput
*server-output* --> *server*$S.standardOutput
[ :socket *server*
  :port 62121 ( Local socket on which we read. )
  :protocol :datagram
| ]listenOnSocket

( Create socket to send      )
( udp packets to port 62121: )
makeSocket --> *client*
makeMessageStream --> *client-input*
makeMessageStream --> *client-output*
*client-input*  --> *client*$S.standardInput
*client-output* --> *client*$S.standardOutput
[ :socket *client*
  :port 62121 ( Far socket to which we send. )
  :protocol :datagram
| ]openSocket

( We almost always want UDP    )
( sockets to preserve datagram )
( boundaries intact, not slice )
( them up into lines:          )
nil --> *server*$S.inputByLines
nil --> *client*$S.inputByLines

( Fork off separate server     )
( and client processes, and    )
( do a request/acknowledge     )
( with retries and exponential )
( backoff:                     )
nil --> *time-for-server-to-exit*
makeLock --> *lock*
*lock* withChildLockDo@{
    1 -> millisecsToWait
    forkJob -> amParent
    amParent if

        ( We'll have parent job play client: )
        do@{
            ( Send a query to server.     )
            ( We use |writeStreamPacket )
            ( to ensure that our text     )
            ( goes out in exactly one     )
            ( datagram even though it     )
            ( contains a newline and does )
            ( not end with one:           )
            "Party!\nRSVP" stringChars[
            "txt" t *client-input*
            |writeStreamPacket
            pop pop ]pop

            ( Read an acknowledgement: )
            [ *client-output* | t millisecsToWait
            |readAnyStreamPacket dup not if

                ( Timeout: Discard dummy )
                ( values and try again:  )
                pop pop pop ]pop
                millisecsToWait 2 * -> millisecsToWait

            else

                ( Got acknowledgement:   )
                ( save it and quit loop: )
                --> *client-stream*
                --> *client-socket*
                --> *client-tag*

                ( Delete address info    )
                ( from datagram packet:  )
                |deleteNonchars

                ( Save server response:  )
                ]join --> *server-line*

                ( Reset wait time before next request: )
                1000 -> millisecsToWait

                ( Do only one request,  )
                ( for this toy example: )
                loopFinish
            fi
        @}

        ( Tell server to exit: )
        t --> *time-for-server-to-exit* 

        ( Wait until it does: )
        *lock* withLockDo@{ @}

    else

        ( We'll have child job play server: )
        do@{
            ( Read datagram from client: )
            [ *server-output* | t millisecsToWait
            |readAnyStreamPacket dup not if

                ( Timeout: Discard )
                ( dummy values:    )
                pop pop pop ]pop

            else

                ( Got request -- save it: )
                --> *server-stream*
                --> *server-socket*
                --> *server-tag*

                ( Remember where request came from: )
                :ip0  |get -> ip0
                :ip1  |get -> ip1
                :ip2  |get -> ip2
                :ip3  |get -> ip3
                :port |get -> port

                ( Remove address info )
                |deleteNonchars

                ( Record request line: )
                ]join --> *client-line*

                ( Acknowledge request: )
                [ :ip0 ip0 :ip1 ip1 :ip2 ip2 :ip3 ip3 :port port |
                "No thanks!" stringChars[ ]|join
                "txt" t *server-input*
                |writeStreamPacket
                pop pop ]pop
            fi

            ( Exit if client says to: )
            *time-for-server-to-exit* if

                ( Exiting releases lock: )
                nil endJob
            fi
        @}
   fi
@}
"Client line: '" , *client-line* , "'\n" ,
"Server line: '" , *server-line* , "'\n" ,

( Close both ports: )
[ :socket *server* | ]closeSocket
[ :socket *client* | ]closeSocket
@end example

@xref{]rootPopenSocket}.
@end deffn


@c
@node  ]rootPopenSocket, write-only-1|, ]openSocket, posix functions
@subsection ]rootPopenSocket
@findex popen
@deffn Control-struct ]rootPopenSocket
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

@example
@{  [ :socket socket
     :commandline "| pgp -feast pat |"
   | ]rootPopenSocket
@}
@end example

The @code{]rootPopenSocket} spawns a host process
connected to the Muq server via pipes.  The
@code{@@$S.actingUser} must be @code{root} to do
this.)

The @code{:socket} parameter must be a socket; It
should be either freshly created
@xref{makeSocket}, or else one which has been
closed by @xref{]closeSocket}.  Before making this
call, you should set the socket's
@code{$s.standardInput} and @code{$s.standardOutput}
keys to the message streams which you wish the socket
connection to use.

The @code{:commandline} parameter may take one
of three forms:

@table @strong
@item :commandline "| srv args"
Subprocess reads from socket, output to @code{/dev/null}.
@item :commandline   "srv args |"
Subprocess reads from @code{/dev/null}, output to socket.
@item :commandline "| srv args |"
Subprocess both reads and writes from socket.
@end table

Note that in the third case, it is often necessary that
the subprocess disable output buffering in order to
avoid a deadlock in which it blocks waiting for input
while its output sits unsent in its stdio output
buffer.  Subprocesses written in Perl may disable
output buffering by doing

@example
select( (select(STDOUT), $| = 1)[0]);
@end example

@noindent
while subprocesses written in C may disable output
buffering by doing

@example
setvbuf( stdout, NULL, _IONBF, 0 );
@end example

@noindent
or simply by using raw @code{write()} calls in
place of the stdio @code{printf}, @code{fprintf}
@dots{} family of buffered output calls.

In all events, Muq will look for the server in the host
directory given by db property @code{.muq$S.srvdir},
which is usually @code{muq/srv} but may be set to other
values by editing the value of @code{srvdir} in
@code{muq/bin/Muq-config.sh} or by using the
@code{--srvdir=/var/people/pat/muq/srv} commandline
switch when invoking Muq.

Security precautions include:
@itemize @bullet

@item
There is no way to modify the @code{.muq$S.srvdir} property
from within a running server.

@item
Server names specified may not begin with a period,
and must consist only of letters, digits, periods
and dashes. (In particular, slashes are not allowed.)

@item
This facility may be disabled completely by
specifying @code{--srvdir} (no server directory)
on the commandline.

@item
Servers are started up by a direct @code{fork()} and
@code{exec()}, without the security problems of an
intervening shell.  (Hence also without most of the
conveniences of an intervening shell, such as wildcard
or environment variable expansion.)
@end itemize

@strong{Gory Details}
@itemize @bullet

@item
Subprocess streams which you do not specify are
set to @code{/dev/null}.  In particular, @code{stdout}
is currently always @code{/dev/null}.

@item
Doing @code{[ :socket s | ]closeSocket} on a socket
opened with @code{]rootPopenSocket} will return immediately,
but the socket will not be ready for re-use until the
subprocess actually exits (as determined by recieving
a @sc{sigchld} signal and querying @code{waitpid()}).
When you call @code{]closeSocket} Muq sends a @sc{hup},
and if that doesn't do the trick within
@code{skt_milliseconds_of_grace} (normally 30000) milliseconds,
sends a @sc{sigkill}.  If @emph{that} has no effect
within another @code{skt_milliseconds_of_grace} milliseconds,
is closes the pipes and frees the socket anyhow.

@item
You may examine @code{socket$S.closedBy} to determine
what terminated a subprocess:  It will be @code{:exit}
if the subprocess called @code{exit()} (in which case
@code{socket$S.exitStatus} will have the integer
exit status), @code{:close} if the subprocess was killed
by a Muq @code{]closeSocket}, and @code{:signal} if
it was killed by any other signal (in which case
@code{socket$S.lastSignal} will have the integer
signal number).
@end itemize

@xref{]openSocket}.
@end deffn

@strong{Examples}

@menu
* write-only-1|::
* write-only-2|::
* |read-only-1::
* |unix-string-upcase-1|::
* |unix-string-upcase-2|::
@end menu

@c
@node   write-only-1|, write-only-2|, ]rootPopenSocket,  ]rootPopenSocket
@subsubsection "write-only-1|"

Here is a simple example of running a
Muq subserver which writes a stream
of text output to the current standard
output.  It assumes you have Perl
installed on your system.

In @code{muq/srv/} create a file @code{write-only-1} with
contents

@example
#!/usr/local/bin/perl
select( (select(STDOUT), $| = 1)[0]);
for (;;) @{
    printf "Loop %d\n", $loop++;
    sleep 10;
@}
@end example

At the unix level, do @code{chmod +x write-only-1}
to make the script executable.

Now, at the Muq prompt do:

@example
root:
makeSocket --> s    @@$s.standardOutput --> s$s.standardOutput
root:
[ :socket s :commandline "write-only-1|" | ]rootPopenSocket
root:
@end example

You will see a sequence of lines

@example
Loop 0
Loop 1
...
@end example

printing out, one every ten seconds.  These
are being copied directly from the socket
into the output stream for the current job,
so they will not interfere with anything
else you might wish to do.

You may close down the subprocess by doing

@example
root:
[ :socket s | ]closeSocket
root:
@end example

@c
@node   write-only-2|, |read-only-1, write-only-1|,  ]rootPopenSocket
@subsubsection "write-only-2|"

This is a simple variant on
@code{write-only-1|}: Instead of routing
coprocess output directly to the output
stream of the current job, we route it
to the input stream, so that it gets
processed by the current interpreter.

In @code{muq/srv/} create a file @code{write-only-2} with
contents

@example
#!/usr/local/bin/perl
select( (select(STDOUT), $| = 1)[0]);
for (;;) @{
    printf "\"Loop %d\\n\" ,\n", $loop++;
    sleep 10;
@}
@end example

As before, at the unix level, do
@code{chmod +x write-only-2} to make
the script executable.

Now, at the Muq prompt do:

@example
root:
makeSocket --> s    @@$s.standardInput$s.twin --> s$s.standardOutput
root:
[ :socket s :commandline "write-only-2|" | ]rootPopenSocket
root:
@end example

You will see a sequence of lines

@example
Loop 0
root:
Loop 1
root:
...
@end example

printing out, one every ten seconds, but
this time they result from the execution
by the @sc{muf} interpreter of a series
of lines

@example
"Loop 0\n" ,
"Loop 1\n" ,
...
@end example

read from the coprocess.  (Since the @sc{muf}
interpreter prints a new prompt after each
command executed, this time you see a prompt
printed after each "Loop" line.)

As before, you may close down the subprocess by doing

@example
root:
[ :socket s | ]closeSocket
root:
@end example

@strong{Gory Detail:}

In the example, we use
@code{@@$s.standardInput$s.twin} rather that just
@code{@@$s.standardInput} because in general
@code{@@$s.standardInput} and
@code{@@$s.standardOutput} may be equal, both pointing
to the same bidirectional stream.  (This is virtually
required by the CommonLisp standard in the simple case,
since @code{@@$S.terminalIo} must be bidirectional,
and must be used by @code{@@$s.standardInput} and
@code{@@$s.standardOutput}.)

Because Muq implements bidirectional streams using two
unidirectional streams, and always indirecting all
reads through @code{stream$s.twin} (which points to the
stream itself in unidirectional streams),
@code{@@$s.standardInput$s.twin} gives us the stream
which, when written, is guaranteed to deliver input
to the current job.

If this is confusing, just remember that writing to
@code{@@$s.standardInput$s.twin} will always send
input to the current job, whether it is using
bidirection or unidirectional message streams.

@c
@node   |read-only-1, |unix-string-upcase-1|, write-only-2|,  ]rootPopenSocket
@cindex syslogd
@cindex MIDI
@cindex email generation
@subsubsection "read-only-1|"

The last two examples were readOnly servers: Muq
was reading from them but not writing to them.
Here we provide simple example of a write-only
server.  Write-only servers might be useful in
practice for controlling an output device (such as
driving an output MIDI music port, say) or perhaps
for generating email, say as part of a
registration system.

To keep this example simple, our example server
will merely accept text, convert it to upper case,
and print it on the console.  (A simple variant
might be used to provide access to the syslogd
daemon from within the Muq.)

In @code{muq/srv/} create a file @code{read-only-1} with
contents

@example
#!/usr/local/bin/perl
open(STDOUT,">/dev/tty");
select( (select(STDOUT), $| = 1)[0]);
print "read-only-1 STARTING\n";
while (<STDIN>) @{
    tr/a-z/A-Z/;
    print;
@}
print "read-only-1 DONE\n";
exit(0);
@end example

Again, at the unix level, do
@code{chmod +x read-only-1} to make
the script executable.

(Remember that in this example we are sending the
output to the unix @code{/dev/tty} device, hence
it will work as shown only when running Muq from
the unix commandline, not when telnetted into
Muq.)

Now, at the Muq prompt do:

@example
root:
makeSocket --> s
root:
makeMessageStream --> m
root:
m --> s$S.standardInput
root:
[ :socket s :commandline "|read-only-1" | ]rootPopenSocket
root:
read-only-1 STARTING
@end example

We now have the message stream @code{m}
leading to our readOnly job @code{read-only-1}
via the socket @code{s}, and thus may
feed test line-by-line to @code{read-only-1}
by stuffing it into @code{m}:

@example
"testing 1...\n" m writeStream
root: 
TESTING 1...
"testing 2...\n" m writeStream
root:
TESTING 2...
@end example

As usual, you may close down the subprocess by doing

@example
[ :socket s | ]closeSocket
read-only-1 DONE
root:
@end example


@c
@node   |unix-string-upcase-1|, |unix-string-upcase-2|, |read-only-1,  ]rootPopenSocket
@subsubsection "|unix-string-upcase-1|"

The last three examples involved communication
only one direction with the subprocess: Either
readOnly or write-only.  This arrangement
is simple and reliable, and is good when it
suffices, but we often need to send information
both to and from the subprocess.

Arranging such two-way communication with a
Muq subprocess is simple, but when doing so
you must always be wary of falling into a
@emph{deadlock} configuration in which both
ends of the socket are waiting for the other
to send something.

One good way to avoid deadlock is to use
separate Muq jobs to read and write the
socket.  If you are sending long blocks of
information each direction, this approach
is recommended.

Another way to avoid deadlock is to simply
send short one-line queries and responses,
and to always wait for the response to one
query before sending the next.  We will
use this approach in this example.

In this example, we show how to use a unix
coprocess as a subroutine: We will define a
process which reads one line, converts it to upper
case, returns the result, and then exits.  We will
then write a @sc{muf} function which hides the
process of invoking the server, so that we wind up
with a function which to the caller looks much
like @code{stringUpcase} -- but much slower,
since a unix process must be started and stopped
for each call.  This is not a practical way to
convert strings to uppercase, of course!  But this
might be a practical way to invoke a special
@sc{ftp} subserver, say, which fetched files on
command from another site and then perhaps loaded
them into the Muq db.

For simplicity, our example function will also
assume that the given string contains exactly
one newline, at the end of the string, and hence
can be trivially read and written as a single line.

In @code{muq/srv/} create a file @code{unix-string-upcase-1} with
contents

@example
#!/usr/local/bin/perl
$_ = <STDIN>;
tr/a-z/A-Z/;
print;
exit(0);
@end example

As usual, at the unix level, do
@code{chmod +x unix-string-upcase-1} to make
the script executable.

Now, at the Muq prompt do:

@example
root:
: my-string-upcase-1 @{ $ -> $ @} -> input
;----> makeSocket -> s
;----> makeMessageStream -> i
;----> makeMessageStream -> o
;----> i --> s$S.standardInput
;----> o --> s$S.standardOutput
;----> [ :socket s :commandline "|unix-string-upcase-1|" | ]rootPopenSocket
;----> input i writeStream
;----> o readStreamLine pop
;----> ;
root:
"abc\n" my-string-upcase-1
root: "ABC
"
@end example

@strong{Fine point:} Our @code{my-string-upcase-1}
function doesn't bother explicitly closing the
socket.  Doing an explicit close would do no
harm, but since our @code{unix-string-upcase-1} program exits
by itself, and since Muq will close the socket
automatically when the associated process exits,
there is no actual need to explicitly close the
socket.




@c
@node   |unix-string-upcase-2|, predicates, |unix-string-upcase-1|,  ]rootPopenSocket
@subsubsection "|unix-string-upcase-2|"

The previous example showed bidirectional
communication, but starts up a new unix process
for each request.  This can be a reasonable
approach, but often we wish to have a subserver
handle multiple requests before exiting.  This
might be because we wish to avoid the overhead of
starting up a unix process for each request (at
the price of maintaining an open socket), or it
might be because we wish to have the server
preserve state between calls (we might be using
GeomView as a subserver to do 3D graphics display,
for example) or it might be because we want to
make sure only one copy of the subserver in
question is running, either to limit system
resources used by the Muq server or to prevent
attempts to share an unsharable resource such as a
single-user database.

In this example, we show how to set up and access
such a server.  To keep the example simple, we
again have our subserver do nothing more than
convert given text to uppercase, but it is
still significantly more complex than
previous examples.

In @code{muq/srv/} create a file @code{unix-string-upcase-2} with
contents

@example
#!/usr/local/bin/perl
select( (select(STDOUT), $| = 1)[0]);
while (<STDIN>) @{
    tr/a-z/A-Z/;
    print;
@}
exit(0);
@end example

At the unix level, do the usual
@code{chmod +x unix-string-upcase-2} to make
the script executable.

Now, define the following function in Muq:

@example
nil --> *my-socket*
:   my-string-upcase-2 @{ $ -> $ @} -> input

    ( Run as root so normal users )
    ( can invoke the subserver:   )
    asMeDo@{

        ( Start up subserver if not already running: )
        *my-socket* socket? not if makeSocket --> *my-socket* fi
        *my-socket*$S.type :popen = not if
            makeLock --> *my-lock*
            makeMessageStream --> *my-input*
            makeMessageStream --> *my-output*
            *my-input*  --> *my-socket*$s.standardInput
            *my-output* --> *my-socket*$s.standardOutput
            [ :socket *my-socket*
              :commandline "|unix-string-upcase-2|"
            | ]rootPopenSocket
        fi

        ( Wait until any other copies of us )
        ( are finished using the server:    )
        *my-lock* withLockDo@{

            ( Send the query to the server: )
            input *my-input* writeStream

	    ( Read and return server response: )
            *my-output* readStreamLine pop
        @}
   @}
;
@end example

You can now do:

@example
root:
"abc\n" my-string-upcase-2
root: "ABC
"
pop "def\n" my-string-upcase-2
root: "DEF
"
@end example

A subserver like this might well be left running
indefinitely, but if you want to shut it down, 
the usual

@example
[ :socket *my-socket* | ]closeSocket
@end example

@noindent
will suffice.

@c
@node predicates, [?, |unix-string-upcase-2|, Core Muf
@section predicates
@cindex Predicates

Predicates accept some argument(s), and return a
true-or-false value.  Muq muf follows the Scheme (and Muck
@sc{muf}) tradition of ending predicates with a question
mark, rather than the CommonLisp tradition of ending them
with a "-p".  This is much more readable, and such
superficial syntax differences should pose few compatibility
problems with Muq CommonLisp code@footnote{CommonLisp avoids
this notation for the excellent reason that it wishes to
reserve the '?' character to users for Lisp reader macros.
Muq @sc{muf} not having reader macros, the reason does not
apply, and in any event, the Muq @sc{muf} design emphasizes
convenience for novices more highly than maximum power for
professionals.}.

@menu
* [?::
* assembler?::
* bignum?::
* bound?::
* callable?::
* char?::
* childOf?::
* mosClass?::
* mosKey?::
* mosObject?::
* compiledFunction?::
* event?::
* cons?::
* constant?::
* control?::
* dataStack?::
* empty?::
* ephemeral?::
* fixnum?::
* float?::
* function?::
* guest?::
* folk?::
* root?::
* omnipotent?::
* integer?::
* job?::
* jobIsAlive?::
* jobQueue?::
* jobSet?::
* keyword?::
* lambdaList?::
* list?::
* lock?::
* loopStack?::
* method?::
* number?::
* package?::
* messageStream?::
* remote?::
* session?::
* socket?::
* stream?::
* stack?::
* string?::
* structure?::
* thisMosClass?::
* thisStructure?::
* symbol?::
* user?::
* vanilla?::
* vector?::
@end menu

@c
@node  [?, assembler?, predicates, predicates
@subsection [?
@defun [?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the given argument is @code{[}, the special value
pushed to mark the bottom of a stack block.  This function
was written to allow implementation of the @code{]}
operator, and may possibly have no other sensible use.

@xref{[ |}.
@xref{]}.
@end defun

@c
@node  assembler?, bignum?, [?, predicates
@subsection assembler?
@defun assembler?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the given argument is an assembler.
@end defun

@c
@node  bignum?, bound?, assembler?, predicates
@subsection bignum?
@defun bignum?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a bignum, a heap-allocated
integer too large to be represented as an immediate value.

You should rarely if ever use this predicate, normally you should
use @code{integer?}, the vanilla integer predicate.

@xref{fixnum?}.
@xref{integer?}.
@end defun


@c
@node  bound?, callable?, bignum?, predicates
@subsection bound?
@defun bound? @{ symbol -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the given symbol has a value as a variable.
An error is signaled if the argument is not a symbol.
@end defun

@c
@node  callable?, char?, bound?, predicates
@subsection callable?
@defun callable? @{ any -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is @code{nil} unless the argument
can be successfully called.  Currently, it
will return non-@code{nil} if the argument is
either a compiledFunction or else a symbol
with a compiledFunction in the function
slot.

@end defun


@c
@node  char?, childOf?, callable?, predicates
@subsection char?
@defun char?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the given argument is a character.  (As opposed to
an integer or string, say.)
@end defun


@c
@node  childOf?, mosClass?, char?, predicates
@subsection childOf?
@findex childOf2?
@defun childOf? @{ kid mom -> tOrNil @}
@display
@exdent file: cdt.t
@exdent package: muf
@exdent status: alpha
@end display

True if @code{mom} can be reached from @code{kid}
by following zero or more @code{kid$s.parents}
pointers.  If @code{kid$s.parents} is a vector,
then all pointers in the vector are checked
recursively.

This function is hand-assembled into the db by cdt.t
because @code{.lib.muf.]doSignal} needs it,
and we want @code{.lib.muf.]doSignal}
functioning as soon as the server starts
executing code.

The source is effectively

@example
: childOf2? -> n -> mom -> kid
    do@{
        mom kid = if t n return fi
        n 0 = if nil n return fi
        n 1 - -> n
        kid$s.parents -> parents
        parents vector? if
            parents foreach i kid do@{
                kid mom n childOf2? -> n if t n return fi
                n 0 = if nil n return fi
                n 1 - -> n
            @}
            nil n return
        else
            parents -> kid
        fi
    @}
;
: childOf? 512 childOf2? pop ;
@end example

@noindent
where the limit of checking 512 parents is to keep
accidental or deliberate parenting loops from
hanging @code{childOf?} and hence
@code{.lib.muf.]doSignal} in an infinite loop.

@xref{doSignal}.

@end defun


@c
@node  mosClass?, mosKey?, childOf?, predicates
@subsection mosClass?
@findex mosClass?
@defun mosClass? @{ any -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True if @code{any} is an instance of ClassMosClass --
if it is a Muq Object System class.

@end defun


@c
@node  mosKey?, mosObject?, mosClass?, predicates
@subsection mosKey?
@findex mosKey?
@defun mosKey? @{ any -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True if @code{any} is an instance of
ClassMosKey -- if it implements the internals
of a Muq Object System class.

@end defun


@c
@node  mosObject?, compiledFunction?, mosKey?, predicates
@subsection mosObject?
@defun mosObject? @{ any -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True if @code{obj} is a Muq Object System
object.

@end defun


@c
@node  compiledFunction?, event?, mosObject?, predicates
@subsection compiledFunction?
@defun compiledFunction? @{ any -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is @code{nil} unless the argument
is a @code{compiledFunction}.

If you just want to know whether something
can be called, use @code{callable?} instead.
@xref{callable?}.

(In particular, a symbol with a compiled-function as its function value
is also callable -- and using such symbols in place of compiled
functions improves code maintainability.)

@end defun


@c
@node  event?, cons?, compiledFunction?, predicates
@subsection event?
@defun event?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a Event.
@end defun


@c
@node  cons?, constant?, event?, predicates
@subsection cons?
@defun cons?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a List cell.
@end defun


@c
@node  constant?, control?, cons?, predicates
@subsection constant?
@defun constant?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True of arguments trivially known to evaluate to themselves:
numbers, characters, strings and keywords, as well as all
constant symbols declared by @code{-->constant} such as
@code{nil} and @code{t}.

@code{nil} otherwise.  Note such a value might still
evaluate to itself, such as a function which returns itself.
@end defun


@c
@node  control?, dataStack?, constant?, predicates
@subsection control?
@defun control? @{ any -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Nil unless effective user either owns the object, or
else is root and running with @sc{omnipotent} set.

@end defun


@c
@node  dataStack?, empty?, control?, predicates
@subsection dataStack?
@defun dataStack?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class Data Stack.
@end defun


@c
@node  empty?, ephemeral?, dataStack?, predicates
@subsection empty?
@defun empty?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error if the object is not a Stream or Stack;
True iff the object is empty.
@end defun


@c
@node  ephemeral?, fixnum?, empty?, predicates
@subsection ephemeral?
@defun ephemeral? @{ any -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the object is allocated on the
stack (as opposed to the heap).

Ephemeral objects are a crude efficiency hack, usable
only within the job that created them, and only until
the function that created them returns.  Currently
only structures and vectors can be ephemeral.
@end defun


@c
@node  fixnum?, float?, ephemeral?, predicates
@subsection fixnum?
@defun fixnum?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a fixnum, a integer small
enough to be reprented as an immediate value instead
of as a heap-allocated value.

You should rarely if ever use this predicate, normally you should
use @code{integer?}, the vanilla integer predicate.

@xref{fixnum?}.
@xref{integer?}.
@end defun


@c
@node  float?, function?, fixnum?, predicates
@subsection float?
@defun float?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a floating point number.
@end defun


@c
@node  function?, integer?, float?, predicates
@subsection function?
@defun function?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of class Function (as
opposed to CompiledFunction or any other class or data
value).
@end defun


@c
@node  integer?, job?, function?, predicates
@subsection integer?
@defun integer?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an integer.

@xref{bignum?}.
@xref{fixnum?}.
@end defun


@c
@node  job?, jobIsAlive?, integer?, predicates
@subsection job?
@defun job?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class Job.
(It may be a dead job, note.)
@end defun


@c
@node  jobIsAlive?, jobQueue?, job?, predicates
@subsection jobIsAlive?
@defun job? @{ job -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class Job,
which has not yet executed @code{endJob} nor been
killed by @code{killJob}, otherwise @code{nil}.
@end defun


@c
@node  jobQueue?, jobSet?, jobIsAlive?, predicates
@subsection jobQueue?
@defun jobQueue?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class JobQueue.
@end defun


@c
@node  jobSet?, keyword?, jobQueue?, predicates
@subsection jobSet?
@defun jobSet?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class JobSet.
@end defun


@c
@node  keyword?, lambdaList?, jobSet?, predicates
@subsection keyword?
@defun keyword? @{ any -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a keyword.  (All keywords
are symbols, but only symbols in the keyword
package are keywords.)
@end defun


@c
@node  lambdaList?, list?, keyword?, predicates
@subsection lambdaList?
@defun lambdaList?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a lambdaList.
@end defun


@c
@node  list?, lock?, lambdaList?, predicates
@subsection list?
@defun list?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a List cell or the constant @code{nil}.
@end defun


@c
@node  lock?, loopStack?, list?, predicates
@subsection lock?
@defun lock?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class Lock.
@end defun


@c
@node  loopStack?, method?, lock?, predicates
@subsection loopStack?
@defun loopStack?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class Loop Stack.
@end defun


@c
@node  method?, number?, loopStack?, predicates
@subsection method?
@defun method?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class Method.
@end defun


@c
@node  number?, package?, method?, predicates
@subsection number?
@defun number?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a number of some sort -- currently
this means either a floating point number or an integer.
@end defun


@c
@node  package?, messageStream?, number?, predicates
@subsection package?
@defun package?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class Package.
@end defun


@c
@node  messageStream?, remote?, package?, predicates
@subsection messageStream?
@defun messageStream?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is a message stream.
@end defun


@c
@node  remote?, guest?, messageStream?, predicates
@subsection remote?
@defun remote? @{ arg -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Returns @code{nil} if the primary copy of @code{arg} is
located on the current server, else a currently unspecified
non-@code{nil} value.

(Application code should not normally care whether an object
is remote, but there may be times when, for example, there
is a choice of objects to be accessed, and access to local
objects preferred for performance reasons.)
@end defun


@c
@node  guest?, folk?, remote?, predicates
@subsection guest?
@defun guest?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is an instance of class Guest.
Class Guest has the same structure as class User,
but represents users on other servers instead of
users on the local server.

This function may change or be removed in future Muq
versions.

@xref{user?}.
@xref{folk?}.
@xref{root?}.
@end defun


@c
@node  folk?, root?, guest?, predicates
@subsection folk?
@defun folk?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is an instance of class Guest
or else an instance of class User.  Since class
Guest instances represent users on other machines,
this is the appropriate predicate to use if you
don't care where a user is located.

This function may change or be removed in future Muq
versions.

@xref{user?}.
@xref{guest?}.
@xref{root?}.
@end defun


@c
@node  root?, omnipotent?, folk?, predicates
@subsection root?
@defun root?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is that instance of class User
designated as having maximum special system privileges.

This function may change or be removed in future Muq
versions.
@end defun


@c
@node  omnipotent?, session?, root?, predicates
@subsection omnipotent? @{ -> tOrNil @}
@defun root?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

Not strictly a predicate, since it takes no
explicit argument.  Return @code{nil} unless
job is running with the @sc{omnipotent} bit
set (via rootOmnipotentlyDo@{@dots{}@}).

@end defun


@c
@node  session?, socket?, omnipotent?, predicates
@subsection session?
@defun session?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is an instance of Class Session.
@end defun


@c
@node  socket?, stream?, session?, predicates
@subsection socket?
@defun socket?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is an instance of Class Socket.
@end defun


@c
@node  stream?, stack?, socket?, predicates
@subsection stream?
@defun stream?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is an instance of Class Stream.
@end defun


@c
@node  stack?, structure?, stream?, predicates
@subsection stack?
@defun stack?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is an instance of Class Stack.
(Specifically not true if it is an instance of one of the
more specialized types of stacks.)

@sc{note}: Stacks may get merged in with arrays, since
CommonLisp arrays have stackpointers.
@end defun


@c
@node  structure?, thisMosClass?, stack?, predicates
@subsection structure?
@defun structure?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True iff the argument is some (any) kind of structure.
(That is, something ultimately created via @code{]makeStructure}
or @code{copyStructure}.)

@end defun


@c
@node  thisMosClass?, thisStructure?, structure?, predicates
@subsection thisMosClass?
@defun thisMosClass? @{ obj mosClass -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True if @code{obj} is an instance of @code{mosClass},
or of some direct or indirect sublass of @code{mosClass}.
@end defun


@c
@node  thisStructure?, symbol?, thisMosClass?, predicates
@subsection thisStructure?
@defun thisStructure? @{ struct structDef -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

True if @code{struct} is an instance of @code{structDef},
or of a @code{structureDefinition} which directly or
indirectly @code{:include}s @code{structDef}.
@end defun


@c
@node  symbol?, string?, thisStructure?, predicates
@subsection symbol?
@defun symbol?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a symbol.
@end defun


@c
@node  string?, user?, symbol?, predicates
@subsection string?
@defun string?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

(True iff the argument is a string.  As opposed
to a character, an integer, or anything else.)
@end defun


@c
@node  user?, vanilla?, string?, predicates
@subsection user?
@defun user?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is an instance of Class User,
or a more privileged but otherwise equivalent class
-- currently, the only such is Class Root.

@xref{root?}.
@xref{folk?}.
@xref{guest?}.
@end defun

@c
@node  vanilla?, vector?, user?, predicates
@subsection vanilla?
@defun vanilla?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: temporary
@end display

True iff the given argument is a generic object.  (As
opposed to a specialized object class such as User.)

@sc{note}: I hate this name, but am not sure what else
to pick.  I think @code{object?} should be reserved for
a predicate true of any general object.
@end defun

@c
@node  vector?, assertions, vanilla?, predicates
@subsection vector?
@defun vector?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

True iff the argument is a vector.  As opposed to a symbol,
List cell, or any other class or data type.  True of both
vanilla and ephemeral vectors:  Use @code{ephemeral?} to
distinguish the two cases.

Similar functions
@code{vectorI01?}
@code{vectorI08?}
@code{vectorI16?}
@code{vectorI32?}
@code{vectorF32?}
@code{vectorF64?}
exist for the other vector flavors.
@end defun


@c
@node assertions, isAnAssembler, vector?, Core Muf
@section assertions
@cindex assertions

Assertions are closely related to predicates, but instead
of returning a value, they signal an error if the argument
does not satisfy them:  They are intended for use in
type-checking arguments to a function.

@menu
* isAnAssembler::
* isCallable::
* isAChar::
* isAMosClass::
* isAMosKey::
* isAMosObject::
* isACompiledFunction::
* isAnEvent::
* isACons::
* isAConstant::
* isADataStack::
* isAFloat::
* isAFunction::
* isAnInteger::
* isAJob::
* isAJobQueue::
* isAJobSet::
* isAKeyword::
* isALambdaList::
* isAList::
* isALock::
* isALoopStack::
* isAMethod::
* isANumber::
* isAPackage::
* isAMessageStream::
* isASession::
* isASocket::
* isAStream::
* isAStack::
* isAStructure::
* isThisStructure::
* isASymbol::
* isAString::
* isAUser::
* isEphemeral::
* isVanilla::
* isAVector::
* isThisMosClass::
* isThisStructure::
@end menu

@c
@node  isAnAssembler, isCallable, assertions, assertions
@subsection isAnAssembler
@defun isAnAssembler @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the given argument is not an assembler.
@end defun

@c
@node  isCallable, isAChar, isAnAssembler, assertions
@subsection isCallable
@defun isCallable @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error unless the argument
can be successfully called.

@end defun


@c
@node  isAChar, isAMosClass, isCallable, assertions
@subsection isAChar
@defun isAChar @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the given argument is not a character.
@end defun


@c
@node  isAMosClass, isAMosKey, isAChar, assertions
@subsection isAMosClass
@defun isAMosClass @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error unless the argument
is a Muq Object System class.

@end defun


@c
@node  isAMosKey, isAMosObject, isAMosClass, assertions
@subsection isAMosKey
@defun isAMosKey @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error unless the argument
is a Muq Object System key
(implements internals of a @sc{mos}
class).

@end defun


@c
@node  isAMosObject, isACompiledFunction, isAMosKey, assertions
@subsection isAMosObject
@defun isAMosObject @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error unless the argument
is a Muq Object System object.

@end defun


@c
@node  isACompiledFunction, isAnEvent, isAMosObject, assertions
@subsection isACompiledFunction
@defun isACompiledFunction @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error unless the argument
is a @code{compiledFunction}.

If you just want to check whether something
can be called, use @code{isCallable} instead.
@xref{isCallable}.

@end defun


@c
@node  isAnEvent, isACons, isACompiledFunction, assertions
@subsection isAnEvent
@defun isAnEvent @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a Event.
@end defun


@c
@node  isACons, isAConstant, isAnEvent, assertions
@subsection isACons
@defun isACons @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a List cell.
@end defun


@c
@node  isAConstant, isADataStack, isACons, assertions
@subsection isAConstant
@defun isAConstant @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if argument does not trivially evaluate to itself,
as for example
numbers, characters, strings and keywords, as well as all
constant symbols declared by @code{-->constant} such as
@code{nil} and @code{t}.

@end defun


@c
@node  isADataStack, isAFloat, isAConstant, assertions
@subsection isADataStack
@defun isADataStack @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class Data Stack.
@end defun


@c
@node  isAFloat, isAFunction, isADataStack, assertions
@subsection isAFloat
@defun isAFloat @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a floating point number.
@end defun


@c
@node  isAFunction, isAnInteger, isAFloat, assertions
@subsection isAFunction
@defun isAFunction @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of class Function.
@end defun


@c
@node  isAnInteger, isAJob, isAFunction, assertions
@subsection isAnInteger
@defun isAnInteger @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an integer.
@end defun


@c
@node  isAJob, isAJobQueue, isAnInteger, assertions
@subsection isAJob
@defun isAJob @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class Job.
@end defun


@c
@node  isAJobQueue, isAJobSet, isAJob, assertions
@subsection isAJobQueue
@defun isAJobQueue @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class JobQueue.
@end defun


@c
@node  isAJobSet, isAKeyword, isAJobQueue, assertions
@subsection isAJobSet
@defun isAJobSet @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class JobSet.
@end defun


@c
@node  isAKeyword, isALambdaList, isAJobSet, assertions
@subsection isAKeyword
@defun isAKeyword @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a keyword.
All keywords are symbols, but only symbols in the
keyword package are keywords.
@end defun


@c
@node  isALambdaList, isAList, isAKeyword, assertions
@subsection isALambdaList
@defun isALambdaList @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a lambdaList.
@end defun


@c
@node  isAList, isALock, isALambdaList, assertions
@subsection isAList
@defun isAList @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is neither a List cell nor the constant @code{nil}.
@end defun


@c
@node  isALock, isALoopStack, isAList, assertions
@subsection isALock
@defun isALock @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class Lock.
@end defun


@c
@node  isALoopStack, isAMethod, isALock, assertions
@subsection isALoopStack
@defun isALoopStack @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class Loop Stack.
@end defun


@c
@node  isAMethod, isANumber, isALoopStack, assertions
@subsection isAMethod
@defun isAMethod @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of
Class Method.
@end defun


@c
@node  isANumber, isAPackage, isAMethod, assertions
@subsection isANumber
@defun isANumber @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a number of some sort -- currently
this means either a floating point number or an integer.
@end defun


@c
@node  isAPackage, isAMessageStream, isANumber, assertions
@subsection isAPackage
@defun isAPackage @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class Package.
@end defun


@c
@node  isAMessageStream, isASession, isAPackage, assertions
@subsection isAMessageStream
@defun isAMessageStream @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a message stream.
@end defun


@c
@node  isASession, isASocket, isAMessageStream, assertions
@subsection isASession
@defun isASession @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class Session.
@end defun


@c
@node  isASocket, isAStream, isASession, assertions
@subsection isASocket
@defun isASocket @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

Signals an error if the argument is not an instance of Class Socket.
@end defun


@c
@node  isAStream, isAStack, isASocket, assertions
@subsection isAStream
@defun isAStream @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signal an error if the argument is not an instance of Class Stream.
@end defun


@c
@node  isAStack, isAStructure, isAStream, assertions
@subsection isAStack
@defun isAStack @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class Stack.
(Specifically if it is an instance of one of the
more specialized types of stacks.)

@end defun


@c
@node  isAStructure, isThisStructure, isAStack, assertions
@subsection isAStructure
@defun isAStructure @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not some (any) kind of
structure.
(That is, something ultimately created via @code{]makeStructure}
or @code{copyStructure}.)

@end defun


@c
@node  isThisStructure, isThisMosClass, isAStructure, assertions
@subsection isThisStructure
@defun isThisStructure @{ struct class -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if @code{struct} is not an instance of
@code{class} nor of a class
which (directly or indirectly) subclasses @code{class}.
@end defun


@c
@node  isThisMosClass, isASymbol, isThisStructure, assertions
@subsection isThisMosClass
@defun isThisMosClass @{ obj mosClass -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if @code{obj} is not an instance of
@code{mosClass} nor of any @sc{mos} (direct or indirect) subclass of
@code{mosClass}.
@end defun


@c
@node  isASymbol, isAString, isThisMosClass, assertions
@subsection isASymbol
@defun isASymbol @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a symbol.
@end defun


@c
@node  isAString, isAUser, isASymbol, assertions
@subsection isAString
@defun isAString @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a string.
@end defun


@c
@node  isAUser, isEphemeral, isAString, assertions
@subsection isAUser
@defun isAUser @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an instance of Class User,
or a more privileged but otherwise equivalent class,
such as Class Root.
@end defun

@c
@node  isEphemeral, isVanilla, isAUser, assertions
@subsection isEphemeral
@defun isEphemeral @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not an ephemeral
object.

Ephemeral objects are a crude efficiency hack, usable
only within the job that created them, and only until
the function that created them returns.  Currently
only structures and vectors can be ephemeral.
@end defun


@c
@node  isVanilla, isAVector, isEphemeral, assertions
@subsection isVanilla
@defun isVanilla @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a vanilla object.
@end defun

@c
@node  isAVector, predicates on chars, isVanilla, assertions
@subsection isAVector
@defun isAVector @{ any -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Signals an error if the argument is not a (possibly ephemeral) vector.
@end defun


@c
@node predicates on chars, alphaChar?, isAVector, Core Muf
@section predicates on chars
@cindex Predicates on chars
@cindex Chars, predicates on

@menu
* alphaChar?::
* controlChar?::
* digitChar?::
* graphicChar?::
* hexDigitChar?::
* lowerCase?::
* punctuation?::
* upperCase?::
* whitespace?::
@end menu

@c
@node  alphaChar?, controlChar?, predicates on chars, predicates on chars
@subsection alphaChar?
@defun alphaChar?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if the argument is not a character.

True iff the given argument is an alphabetic (C
@code{isalpha}).
@end defun


@c
@node  controlChar?, digitChar?, alphaChar?, predicates on chars
@subsection controlChar?
@defun controlChar?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if the argument is not a character.

True iff the given argument is a control character (C
@code{iscntrl}).
@end defun


@c
@node  digitChar?, graphicChar?, controlChar?, predicates on chars
@subsection digitChar?
@defun digitChar?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if the argument is not a character.

Returns @code{nil} if the argument is not in '0'->'9' (C
@code{isdigit}), else returns the decimal value of the
argument (an integer in 0->9).
@end defun


@c
@node  graphicChar?, hexDigitChar?, digitChar?, predicates on chars
@subsection graphicChar?
@defun graphicChar?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if the argument is not a character.
True iff the argument is printable (including blank, but
excluding control chars and such): C @code{isprint}).

Note that this is @emph{not} the C @code{isgraph} function!
The clash between C and CommonLisp naming conventions here
is unfortunate.
@end defun


@c
@node  hexDigitChar?, lowerCase?, graphicChar?, predicates on chars
@subsection hexDigitChar?
@defun hexDigitChar?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if the argument is not a character.

Returns @code{nil} if the argument is not in '0'->'9',
'a'->'f', 'A'->'F', (C @code{isxdigit}), else returns the
decimal value of the argument (an integer in 0->15).
@end defun


@c
@node  lowerCase?, punctuation?, hexDigitChar?, predicates on chars
@subsection lowerCase?
@defun lowerCase?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if the argument is not a character.
True iff the argument is a lowercase alphabetic (C @code{islower}).
@end defun


@c
@node  punctuation?, upperCase?, lowerCase?, predicates on chars
@subsection punctuation?
@defun punctuation?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error is signaled if the argument is not a character.

True iff the argument is neither but an alphanumeric,
control nor whitespace char (C @code{ispunct}).
@end defun


@c
@node  upperCase?, whitespace?, punctuation?, predicates on chars
@subsection upperCase?
@defun upperCase?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error if the argument is not a character.
True iff the character is an uppercase
alphabetic (C @code{isupper}).
@end defun


@c
@node  whitespace?, regular expressions, upperCase?, predicates on chars
@subsection whitespace?
@defun whitespace?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

An error if the argument is not a character.
True iff the character is a space, newline or
such (C @code{isspace}).
@end defun


@c
@node regular expressions, regular expression syntax, whitespace?, Core Muf
@section regular expressions

Regular expressions are a powerful notation for specifying
string patterns and for extracting components of strings.

@menu
* regular expression syntax::
* rex::
* rexBegin::
* rexCancelParen::
* rexCloseParen::
* rexDone?::
* rexEnd::
* rexGetCursor::
* rexGetParen::
* rexMatchCharClass::
* rexMatchDot::
* rexMatchString::
* rexMatchDigit::
* rexMatchWhitespace::
* rexMatchWordboundary::
* rexMatchWordchar::
* rexMatchNondigit::
* rexMatchNonwhitespace::
* rexMatchNonwordboundary::
* rexMatchNonwordchar::
* rexMatchPreviousMatch::
* rexOpenParen::
* rexSetCursor::
@end menu

@c
@node  regular expression syntax, rex, regular expressions, regular expressions
@subsection regular expression syntax
@cindex Regular expression syntax

This node is not a tutorial, just a quick synopsis of
syntax.

Current Muq @sc{muf} regular expression syntax is implemented primarily
in @code{muq/pkg/175-C-rex.t} -- which is incidentally a good example of
a compiler for an embedded language in @sc{muf} -- with some C-coded
support in @code{muq/c/rex.t}.

Muq @sc{muf} follows the lead of Larry Wall's @sc{Perl} language in
regular expression syntax: His syntax has a simple quoting rule and
minimizes the number of backslashes needed in typical uses of regular
expressions.  (I wince every time I read a regular expression written in
emacs lisp.)  The current implementation follows Perl v4: One of these
days we'll probably add support for the v5 extensions.

Here are the regular expression operators Muq @sc{muf}
currently recognizes:
@example
a       Match given char.  Ditto other chars not listed below.
.       Match any single character except a newline.
[a-z]   Match any single character in the given ascii range. 
[^a-z]  Match any single character @emph{not} in the given ascii range. 

\d      Match any single decimal digit: Same as [0-9].
\D      Inverse of above:  Same as [^0-9].

\s      Match any single whitespace char.
\S      Inverse of above.

\w      Match any single word-component char:  Same as [a-zA-Z0-9_].
\W      Inverse of above:  Same as [^a-zA-Z0-9_].

^ $     Match beginning or end of given string, respectively.

\n \r \t \f \0 Match newline/carraige-return/tab/formfeed/nul (respectively)

(<rex>) Parens group interior <rex> into a unit for exterior operators;
        Parens also remember the substring they matched.

<rex>*  Matches <rex> zero or more times.

<rex>+  Matches <rex> one or more times.

<rex>?  Matches <rex> zero or one times.

<rex>@{n@} Matches <rex> exactly n times.

<rex>@{n,@} Matches <rex> at least n times.

<rex>@{n,m@} Matches <rex> at least n and at most m times.

<rex0>|<rex1>   Match exactly one of <rex0> or <rex1>.
@end example

Hints:

@example
To include ^ in a character set, make it non-first: [a-z^].
To include - in a character set, make it first: [-az]
To subdue all operators, precede all nonalphanumeric chars with "\".
In particular, to include a literal backslash, insert "\\".
@end example

@c
@node  rex, rexBegin, regular expression syntax, regular expressions
@subsection rex

The @code{rex:} operator defines a function expressed in the
previously described regular expression syntax.  The regular
expression proper is preceded and followed by an arbitrary
delimiter character, which may be any printing character
desired.

The resulting function accepts a single string as input and returns at
minimum a boolean flag indicating whether or not the string was
successfully matched.

@example
Stack:
rex: myfn /^ab*c$/
Stack:
"abc" myfn
Stack: t
pop "ad" myfn
Stack: nil
@end example

If there are any parentheses in the regular expression, the function in
addition returns one string value for each parenthesis pair, giving the
substring matched by that parenpair.

@example
Stack:
rex: myfn /^a(b*)c$/
Stack:
"abbbc" myfn
Stack: t "bbb"
pop pop "ad" myfn
Stack: nil ""
@end example

@c
@node  rexBegin, rexCancelParen, rex, regular expressions
@subsection rexBegin
@defun rexBegin @{ -> @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Clear internal regular expression state record in job in preparation
for a new regular expression match.  (See muq/h/rex.h for the state
record declaration.)

@end defun

@c
@node  rexCancelParen, rexCloseParen, rexBegin, regular expressions
@subsection rexCancelParen
@defun rexCancelParen @{ i -> @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Cancel matched substring for i-th parenpair.  Legal values for i
currently range from 0 to 31.

@end defun

@c
@node  rexCloseParen, rexDone?, rexCancelParen, regular expressions
@subsection rexCloseParen
@defun rexCloseParen @{ i -> @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Set end of matched substring for i-th parenpair to current rex cursor
position.  Legal values for i currently range from 0 to 31.

@end defun

@c
@node  rexDone?, rexEnd, rexCloseParen, regular expressions
@subsection rexDone?
@defun rexDone? @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Return @code{nil} unless rex cursor is currently at end of string -- this
is used to implement the $ syntax.

@end defun

@c
@node  rexEnd, rexGetCursor, rexDone?, regular expressions
@subsection rexEnd
@defun rexEnd @{ -> @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Clear regular expression state record at end of regular expression match.

@end defun

@c
@node  rexGetCursor, rexGetParen, rexEnd, regular expressions
@subsection rexGetCursor
@defun rexGetCursor @{ -> i @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Get regular expression cursor as non-negative integer offset into
matched string.

@end defun

@c
@node  rexGetParen, rexMatchCharClass, rexGetCursor, regular expressions
@subsection rexGetParen
@defun rexGetParen @{ i -> start stop @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Get string range matched by i-th parenpair.
Legal values for i currently range from 0 to 31.
Return value @code{start} will be offset of first character in matched string.
Return value @code{stop} will be offset of first character past
substring in matched string.

If no match is current registered, both return values will be zero.

@end defun

@c
@node  rexMatchCharClass, rexMatchDot, rexGetParen, regular expressions
@subsection rexMatchCharClass
@defun rexMatchCharClass @{ str -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Try to match a char class.  Input string looks like "^a-zA-Z" if surface
syntax was "[^a-zA-z]".  Return value is @code{nil} if match failed,
otherwise cursor is advanced one char.

@end defun

@c
@node  rexMatchDot, rexMatchString, rexMatchCharClass, regular expressions
@subsection rexMatchDot
@defun rexMatchDot @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Match any character but newline.  Return value is @code{nil} if match failed,
otherwise cursor is advanced one char.

@end defun

@c
@node  rexMatchString, rexMatchDigit, rexMatchDot, regular expressions
@subsection rexMatchString
@defun rexMatchString @{ str -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Match given string, which should be less than 64 chars in length.
Return value is @code{nil} if match failed, otherwise cursor is advanced
by length of given string.

@end defun

@c
@node  rexMatchDigit, rexMatchWhitespace, rexMatchString, regular expressions
@subsection rexMatchDigit
@defun rexMatchDigit @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Match any of "0123456789".
Return value is @code{nil} if match failed, otherwise cursor is advanced
by one.

@end defun

@c
@node  rexMatchWhitespace, rexMatchWordboundary, rexMatchDigit, regular expressions
@subsection rexMatchWhitespace
@defun rexMatchWhitespace @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Match any of the usual C @code{isspace()} characters: space, tab,
linefeed, return.
Return value is @code{nil} if match failed, else cursor advances one.

@end defun

@c
@node  rexMatchWordboundary, rexMatchWordchar, rexMatchWhitespace, regular expressions
@subsection rexMatchWordboundary
@defun rexMatchWordboundary @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

NOT IMPLEMENTED IN THIS RELEASE.

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Match boundary between word char [a-zA-Z0-9_] and non word char.
Return value is @code{nil} if match failed.  Cursor does not advance.

@end defun

@c
@node  rexMatchWordchar, rexMatchNondigit, rexMatchWordboundary, regular expressions
@subsection rexMatchWordchar
@defun rexMatchWordchar @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Match any ofr [a-zA-Z0-9_].
Return value is @code{nil} if match failed, else cursor advances one.

@end defun

@c
@node  rexMatchNondigit, rexMatchNonwhitespace, rexMatchWordchar, regular expressions
@subsection rexMatchNondigit
@defun rexMatchNondigit @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Same as @code{rexMatchDigit} except sense of test is reversed.

@xref{rexMatchDigit}.

@end defun

@c
@node  rexMatchNonwhitespace, rexMatchNonwordboundary, rexMatchNondigit, regular expressions
@subsection rexMatchNonwhitespace
@defun rexMatchNonwhitespace @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Same as @code{rexMatchWhitespace} except sense of test is reversed.

@xref{rexMatchWhitespace}.

@end defun

@c
@node  rexMatchNonwordboundary, rexMatchNonwordchar, rexMatchNonwhitespace, regular expressions
@subsection rexMatchNonwordboundary
@defun rexMatchNonwordboundary @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

NOT IMPLEMENTED IN THIS RELEASE.

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Same as @code{rexMatchWordboundary} except sense of test is reversed.

@xref{rexMatchWordboundary}.

@end defun

@c
@node  rexMatchNonwordchar, rexMatchPreviousMatch, rexMatchNonwordboundary, regular expressions
@subsection rexMatchNonwordchar
@defun rexMatchNonwordchar @{ -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Same as @code{rexMatchWordchar} except sense of test is reversed.

@xref{rexMatchWordchar}.

@end defun

@c
@node  rexMatchPreviousMatch, rexOpenParen, rexMatchNonwordchar, regular expressions
@subsection rexMatchPreviousMatch
@defun rexMatchPreviousMatch @{ i -> bool @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Match substring matched by i-th paren pair -- implements @code{\1}
notation.  Legal values for i currently range from 0 to 31.  Current
implementation only supports substrings of length 8192 chars or less.

@end defun

@c
@node  rexOpenParen, rexSetCursor, rexMatchPreviousMatch, regular expressions
@subsection rexOpenParen
@defun rexOpenParen @{ i -> @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Mark start of i-th paren pair -- copies cursor into start field of that
paren pair in internal state.
Legal values for i currently range from 0 to 31.

@end defun

@c
@node  rexSetCursor, set and index functions, rexOpenParen, regular expressions
@subsection rexSetCursor
@defun rexSetCursor @{ i -> @}
@display
@exdent file: jobb.t
@exdent package: muf
@exdent status: alpha
@end display

(This is a low-level primitive used internally by the @sc{Muq muf}
regular expression implementation: It will not normally be of interest
to users unless they are writing another regular expression implemention
for @code{Muq}.)

Set regular expression cursor in internal regular expression state
record in job to given non-negative offset within string.

@end defun


@c
@node set and index functions, ]set, rexSetCursor, Core Muf
@section set and index functions

Eventually I'd like to see many of the list functions such as
@code{mapcar} apply also to set and index objects, but for
now we settle for the basic set operations.

@menu
* ]set::
* ]index::
* union::
* intersection::
* setDifference::
@end menu

@c
@node  ]set, ]index, set and index functions, set and index functions
@subsection ]set
@defun ]set @{ [keys] -> set @}
@display
@exdent file: 100-C-lists.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]set} function provides a more concise way of creating a
small set than using @code{makeSet} followed by some assignments:

@example
root:
[ 'a' 'b' 'c' | ]set
[ 'a' 'b' 'c' | ]set
root: #<Set _ 369ef15>
ls
'a'	t
'b'	t
'c'	t
root:
@end example
@end defun

@c
@node  ]index, union, ]set, set and index functions
@subsection ]index
@defun ]index @{ [keyvals] -> index @}
@display
@exdent file: 100-C-lists.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]index} function provides a more concise way of creating a
small index than using @code{makeHash} followed by some assignments:

@example
root:
[ "a" 'a' "b" 'b' "c" 'c' | ]index
root:
ls
'a'	t
'b'	t
'c'	t
root: #<Index _ 381e615>
ls
"a"	'a'
"b"	'b'
"c"	'c'
root:
@end example
@end defun

@c
@node  union, intersection, ]index, set and index functions
@subsection union
@defun union @{ a b -> c @}
@display
@exdent file: 100-C-lists.t
@exdent package: muf
@exdent status: alpha
@end display

Does just what you expect:
@example
root:
[ 'a' 'b' 'c' | ]set   [ 'b' 'c' 'd' | ]set   union   keys[
root: [ 'a' 'b' 'c' 'd' |
]pop
root:
[ "a" 'a' "b" 'b' "c" 'c' | ]index   [ "b" 'b' "c" 'c' "d" 'd' | ]index   union   ls
"a"	'a'
"b"	'b'
"c"	'c'
"d"	'd'
root: 
@end example
@end defun

@c
@node  intersection, setDifference, union, set and index functions
@subsection intersection
@defun intersection @{ a b -> c @}
@display
@exdent file: 100-C-lists.t
@exdent package: muf
@exdent status: alpha
@end display

Does just what you expect:
@example
root:
[ 'a' 'b' 'c' | ]set   [ 'b' 'c' 'd' | ]set   intersection   keys[
root: [ 'b' 'c' |
]pop
root: 
[ "a" 'a' "b" 'b' "c" 'c' | ]index   [ "b" 'b' "c" 'c' "d" 'd' | ]index   intersection   ls
"b"	'b'
"c"	'c'
root: 
@end example
@end defun


@c
@node  setDifference, stack stream and vector functions, intersection, set and index functions
@subsection setDifference
@defun union @{ a b -> c @}
@display
@exdent file: 100-C-lists.t
@exdent package: muf
@exdent status: alpha
@end display

Does just what you expect:
@example
root:
[ 'a' 'b' 'c' | ]set   [ 'b' 'c' 'd' | ]set   setDifference   keys[
root: [ 'a' |
]pop
root: 
[ "a" 'a' "b" 'b' "c" 'c' | ]index   [ "b" 'b' "c" 'c' "d" 'd' | ]index   setDifference   ls
"a"	'a'
root: 
@end example
@end defun

@c
@node stack stream and vector functions, deleteBth, setDifference, Core Muf
@section stack stream and vector functions
@cindex Stack functions
@cindex Stream functions
@cindex Vector functions

The dataStack functions tend to get over-used in muck muf and
traditional forth due to the lack of dynamic variables, with
consequent losses to code readability.

When using these, please be sure your code could not
be better expressed using local variables (which are
just as fast, and usually more readable).

When using stack and stream objects, note that generic object
functions are also applicable:  For example, @code{vals[} may
be used to extract the contents of a stack object in a block.

@menu
* deleteBth::
* deleteNth::
* depth::
* dup::
* dup2nd::
* dupBth::
* dupNth::
* pop::
* pull::
* push::
* ]push::
* rot::
* setBth::
* setNth::
* swap::
* sum::
* product::
* unpull::
* unpush::
@end menu

@c
@node  deleteBth, deleteNth, stack stream and vector functions, stack stream and vector functions
@subsection deleteBth
@defun deleteBth @{ stack n -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Remove @code{n-th} element from bottom of stack, sliding remaining
entries down to fill the hole.  Bottom entry is entry zero.

@xref{pull}.
@xref{unpush}.
@xref{delete}.
@xref{deleteNth}.
@end defun

@c
@node  deleteNth, depth, deleteBth, stack stream and vector functions
@subsection deleteNth
@defun deleteNth @{ stack n -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Remove @code{n-th} element from top of stack, sliding remaining
entries down to fill the hole.  Top entry is entry zero.

@xref{pull}.
@xref{unpush}.
@xref{delete}.
@xref{deleteBth}.
@end defun


@c
@node  depth, dup, deleteNth, stack stream and vector functions
@subsection depth
@defun depth?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{depth} function returns a count of the number of
items currently logically on the data stack.  (This may be
less than the number physically on the data stack, for
example if a thunk is executing, since it lacks rights to
examine stack elements it doesn't own.)
@end defun


@c
@node  dup, dup2nd, depth, stack stream and vector functions
@subsection dup
@defun dup
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{dup} function duplicates the top argument on the
data stack.  This is purely a pointer operation: This will
@emph{not} create a copy of an object or vector or such,
just a second reference to it.  @xref{copy}.
@end defun


@c
@node  dup2nd, dupBth, dup, stack stream and vector functions
@subsection dup2nd
@defun dup2nd
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{dup2nd} function duplicates the 2nd-from-top
argument on the data stack.  This is purely a pointer operation:
This will @emph{not} create a copy of an object or vector or
such, just a second reference to it.  @xref{copy}.

This function is called @code{over} in Muck @sc{muf} and
traditional Forth: Muq @sc{muf} attempts to adopt systematic
naming conventions ala emacs lisp, in order to increase the
utility of apropos-style help commands.
@end defun


@c
@node  dupBth, dupNth, dup2nd, stack stream and vector functions
@subsection dupBth
@defun dupBth
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{dupBth} function duplicates the bth-from-bottom
argument on the data stack: @code{depth 1- dupBth} is
equivalent to @code{dup}.  This is purely a pointer
operation: This will @emph{not} create a copy of an object
or vector or such, just an additional pointer to it.
@xref{copy}.

@end defun


@c
@node  dupNth, pop, dupBth, stack stream and vector functions
@subsection dupNth
@defun dupNth
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{dupNth} function duplicates the nth-from-top
argument on the data stack: @code{1 dupNth} is equivalent
to @code{dup}.  This is purely a pointer operation: This
will @emph{not} create a copy of an object or vector or
such, just a second reference to it.  @xref{copy}.

This function is called @code{pick} in muck muf and
traditional Forth: Muq muf attempts to adopt systematic
naming conventions ala emacs lisp, in order to increase the
utility of apropos-style help commands.
@end defun


@c
@node  pop, pull, dupNth, stack stream and vector functions
@subsection pop
@defun pop
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{pop} function drops the top element on the
data stack.

This function is called @code{drop} in traditional Forth:
Muq muf bows to Muck @sc{muf}, computer science tradition,
and brevity.

@xref{delete}.
@xref{deleteBth}.
@xref{deleteNth}.
@end defun


@c
@node  pull, push, pop, stack stream and vector functions
@subsection pull
@defun pull @{ stream-or-stack -> value @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{pull} function accepts a Stream or Stack as argument,
removes one element from it, and returns that element.

This function does @emph{not} operate upon the job's data
stack.  (Other than using it for parameter and result.)

@xref{delete}.
@xref{deleteBth}.
@xref{deleteNth}.
@xref{push}.
@xref{unpull}.
@xref{Class Stream}.
@xref{Class Stack}.
@end defun


@c
@node  push, ]push, pull, stack stream and vector functions
@subsection push
@defun push @{ value stream-or-stack -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{push} function inserts @code{value} into the Stack or Stream.

This function does @emph{not} operate upon the job's data
stack.  (Other than using it for parameter and result.)

Stacks and streams currently have a maximum size of 4K
slots; An error is signaled if @code{push} is invoked on a
full stack or stream.

@sc{note}: This and the previous function may clash
with CommonLisp naming conventions, in which case
they may change.

@xref{pull}.
@xref{]push}.
@xref{unpush}.
@xref{Class Stream}.
@xref{Class Stack}.
@end defun


@c
@node  ]push, rot, push, stack stream and vector functions
@subsection push
@defun push @{ [values] stack -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{]push} function inserts the given block
of @code{[values]} into the given Stack.

This function does @emph{not} operate upon the job's data
stack.  (Other popping @code{[values]} off it whend done.)

@xref{push}.
@xref{pull}.
@xref{unpush}.
@xref{Class Stream}.
@xref{Class Stack}.
@end defun


@c
@node  rot, setBth, ]push, stack stream and vector functions
@subsection rot
@defun rot
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rot} function rotates the top three elements on
the data stack.  Use of this function is a nearly infallible
indication that you should be using local variables instead
of the stack.
@end defun


@c
@node  setBth, setNth, rot, stack stream and vector functions
@subsection setBth
@defun setBth
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setBth} function accepts a stack offset atop a
value, and overwrites the indicated data stack offset with
the given value, taking the logical bottom element of the
stack as zero.  This is an obscure way of hacking the
contents of the data stack, and not generally recommended,
but occasionally useful.

Note that the logical bottom of stack may not be the
physical bottom of stack: Some operations such as thunk
evaluation restrict the accessable stack locations to a
subset of those physically present.
@end defun


@c
@node  setNth, swap, setBth, stack stream and vector functions
@subsection setNth
@defun setNth
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setNth} function accepts a stack offset atop a
value, and overwrites the indicated data stack offset with
the given value.  This is an obscure way of hacking the
contents of the data stack, and not generally recommended,
but occasionally useful.
@end defun


@c
@node  swap, sum, setNth, stack stream and vector functions
@subsection swap
@defun swap
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{swap} function interchanges the top two elements
on the data stack.  It is usually clearer to use local
variables instead.

@xref{||swap}.
@end defun


@c
@node  sum, product, swap, stack stream and vector functions
@subsection sum
@defun sum
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{sum} function sums the elements in a vector.

@xref{product}.
@end defun


@c
@node  product, unpull, sum, stack stream and vector functions
@subsection product
@defun product
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{product} function multiplies the elements in a vector.

@xref{sum}.
@end defun


@c
@node  unpull, unpush, product, stack stream and vector functions
@subsection unpull
@defun unpull @{ value stream -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{unpull} function reverses the effect of a
@code{pull} operation, adding @code{value} to @code{stream}.
This is like @code{push}, but operating on the opposite end
of the stream.

@xref{pull}.
@xref{unpush}.
@xref{Class Stream}.
@end defun

@c
@node  unpush, string functions, unpull, stack stream and vector functions
@subsection unpush
@defun unpush @{ stream -> value @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{unpush} function removes @code{value} from
the @code{stream} and returns it.  This is like @code{pull},
but operating on the opposite end of the stream.

@xref{delete}.
@xref{deleteBth}.
@xref{deleteNth}.
@xref{push}.
@xref{unpull}.
@xref{Class Stream}.
@end defun


@c
@node string functions, editString, unpush, Core Muf
@section string functions
@cindex String functions

Recall that Muq muf follows Scheme in using "-ci" as a
suffix for Case-Insensitive functions -- those which ignore
the distinction between upper and lower case@footnote{
Scheme actually uses a "ci-" prefix.}.

@menu
* editString::
* findLastSubstringCi?::
* findSubstringCi?::
* findNextSubstringCi?::
* findPreviousSubstringCi?::
* substringCi?::
* countLinesInString::
* date::
* expandCStringEscapes::
* findLastSubstring?::
* findSubstring?::
* findNextSubstring?::
* findPreviousSubstring?::
* getLineFromString::
* join::
* print::
* print1::
* print1DataStack::
* printTime::
* ]replaceSubstrings::
* secureHash::
* secureHashBinary::
* secureHashFixnum::
* substring::
* substring?::
* substring[::
* time::
* toDelimitedString::
* stringDowncase::
* stringMixedcase::
* stringUpcase::
* toString::
* trimString::
* unprintFormatString[::
* unprint[::
* wrapString::
@end menu

Also @xref{length}.

@c
@node  editString, findLastSubstringCi?, string functions, string functions
@subsection editString
@defun editString @{ string -> string @}
@display
@exdent file: 14-C-edit.t
@exdent package: edit
@exdent status: alpha
@end display

The @code{editString} function accepts a strings, prompts
the user to edit it interactively, and then returns the
result.

Because it is intended as a minimal editor supporting
the lowest common denominator user connection, a simple
"glass tty" communicating in line mode,
@code{editString} implements only a very simple
line-editing interface.  Implementation of more
sophisticated editors taking advantage of cursor
addressing is encouraged.

There is no point in duplicating the online help
for @code{editString} here:  Invoke it online,
or read the source file.
@end defun


@c
@node  findLastSubstringCi?, findSubstringCi?, editString, string functions
@subsection findLastSubstringCi?
@defun findLastSubstringCi? @{ string substring -> found? end start @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findLastSubstringCi?} function accepts a substring
atop a string and returns the location of the substring atop a
success flag.  Search is from end of string, ignoring case.

On a @code{nil} success value, @code{start} and @code{end} are undefined.
@end defun


@c
@node  findSubstringCi?, findNextSubstringCi?, findLastSubstringCi?, string functions
@subsection findSubstringCi?
@defun findSubstringCi? @{ string substring -> found? end start @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findSubstringCi?} function accepts a substring
atop a string and returns the location of the substring atop a
success flag.  Search is from start of string, ignoring case.

On a @code{nil} success value, @code{start} and @code{end} are undefined.
@end defun


@c
@node  findNextSubstringCi?, findPreviousSubstringCi?, findSubstringCi?, string functions
@subsection findNextSubstringCi?
@defun findNextSubstringCi? @{ string n substring -> found? end start @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findNextSubstringCi?} function accepts a substring
atop a string and returns the location of the substring atop a
success flag.  Search is from offset @code{n+1} in string, and
ignores case.

Searching from a too-large @code{n} results in a @code{nil} success
value (not an error).

Searching from a negative @code{n} is the same as searching from
zero.

On a @code{nil} success value, @code{start} and @code{end} are undefined.
@end defun


@c
@node  findPreviousSubstringCi?, substringCi?, findNextSubstringCi?, string functions
@subsection findPreviousSubstringCi?
@defun findPreviousSubstringCi? @{ string n substring -> found? end start @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findPreviousSubstringCi?} function accepts a substring
atop a string and returns the location of the substring atop a
success flag.  Search is backwards from offset @code{n-1} in string, and
ignores case.

Searching from a too-small @code{n} results in a @code{nil} success value
(not an error).

Searching from a too-large @code{n} is the same as searching from
end of string.

On a @code{nil} success value, @code{start} and @code{end} are undefined.
@end defun


@c
@node  substringCi?, countLinesInString, findPreviousSubstringCi?, string functions
@subsection substringCi?
@defun substringCi?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ string pat -> flag @}
@end example

The @code{substringCi?} function returns non-@code{nil} iff it locates a
substring in a string, ignoring case differences.

This is entirely equivalent to @code{string pat findSubstringCi? pop pop}.
@end defun


@c
@node  countLinesInString, date, substringCi?, string functions
@subsection countLinesInString
@defun countLinesInString @{ string -> integer @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{countLinesInString} function is a trivial
convenience function returning the number of newlines
in the string, plus one if the last character is not a
newline.  It is coded in-db mostly because doing so is
easy, and the function is likely to be frequently used.

Examples:

@example
stack:
"abc\ndef" countLinesInString
stack: 2
pop "abc\ndef\n" countLinesInString
stack: 2
@end example

@xref{getLineFromString}.
@end defun


@c
@node  date, expandCStringEscapes, countLinesInString, string functions
@subsection date
@defun date @{ -> "Thu Mar 15, 1956 @}
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{date} function is a trivial convenience function
returning the current date.  It is currently defined as

@example
: date @{ -> $ @}
    .sys$s.millisecsSince1970 "%a %b %e, %Y" printTime
;
@end example

@xref{time}.  @xref{printTime}.
@end defun


@c
@node  expandCStringEscapes, findLastSubstring?, date, string functions
@subsection expandCStringEscapes
@defun expandCStringEscapes
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ string -> string @}
@end example

The @code{expandCStringEscapes} function accepts a string and
returns a string in which any C-style escape sequences found
have been appropriately expanded -- "\n" expanded to a
newline, and so forth.

The current list of escapes recognized:

@example
'\0'
'\a'
'\b'
'\f'
'\n'
'\r'
'\t'
'\v'
@end example

(This could certainly be coded in muf easily enough, but
C-coding it seems likely to speed up the muf compiler.)
@end defun


@c
@node  findLastSubstring?, findSubstring?, expandCStringEscapes, string functions
@subsection findLastSubstring?
@defun findLastSubstring?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ string substring -> found? end start @}
@end example

The @code{findLastSubstring?} function accepts a substring
atop a string and returns the location of the substring atop a
success flag.  Search is from end of string.

On a @code{nil} success value, @code{start} and @code{end} are undefined.
@end defun


@c
@node  findSubstring?, findNextSubstring?, findLastSubstring?, string functions
@subsection findSubstring?
@defun findSubstring?  @{ string substring -> found? end start @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findSubstring?} function accepts a substring atop a string
and returns the location of the substring atop a success flag.  Search
is from start of string.

On a @code{nil} success value, @code{start} and @code{end} are undefined.
@end defun


@c
@node  findNextSubstring?, findPreviousSubstring?, findSubstring?, string functions
@subsection findNextSubstring?
@defun findNextSubstring? @{ string n substring -> found? end start @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findNextSubstring?} function accepts a substring atop a
string and returns the location of the substring atop a success flag.
Search is from @code{n+1} in the string.

Searching from a negative @code{n} is the same as searching from
zero.

Searching from a too-large @code{n} results in a @code{nil} success
value (not an error).

On a @code{nil} success value, @code{start} and @code{end} are undefined.
@end defun


@c
@node  findPreviousSubstring?, getLineFromString, findNextSubstring?, string functions
@subsection findPreviousSubstring?
@defun findPreviousSubstring?  @{ string n substring -> found? end start @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findPreviousSubstring?} function accepts a substring atop a
string and returns the location of the substring atop a success flag.
Search is from @code{n-1} in the string, and proceeds backwards.

Searching from a too-large @code{n} is the same as searching from
end of string.

Searching from a too-small @code{n} results in a @code{nil} success
value (not an error).

On a @code{nil} success value, @code{start} and @code{end} are undefined.
@end defun


@c
@node  getLineFromString, join, findPreviousSubstring?, string functions
@subsection getLineFromString
@defun getLineFromString @{ string n -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getLineFromString} function is a trivial
convenience function returning the @emph{nth} line
from a string, defined as the text after the @emph{nth}
newline but preceding the @emph{n+1th} newline (if any)
but including neither:

@example
stack:
"abc\ndef" 0 getLineFromString
stack: "abc"
pop "abc\ndef\n" 1 getLineFromString
stack: "def"
@end example

@xref{countLinesInString}.
@end defun


@c
@node  join, print, getLineFromString, string functions
@subsection join
@defun join
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ string test -> string @}
@end example

The @code{join} function concatenates two given strings.

@end defun


@c
@node  print, print1, join, string functions
@subsection print
@defun print
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ arg -> string @}
@end example

The @code{print} function accepts any sort of argument and
attempts to produce a human-readable string display of it.
For example, this produces a disassembly of a Procedure
argument.

@xref{toString}.  @xref{]print}.
@end defun


@c
@node  print1, print1DataStack, print, string functions
@subsection print1
@defun print1
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ arg -> string @}
@end example

The @code{print1} function accepts a job and attempts to
produce a one-line summary of its state, suitable for debug
traces and such.

Other types of arguments may eventually be supported.
@end defun


@c
@node  print1DataStack, printTime, print1, string functions
@subsection print1DataStack
@defun print1DataStack
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

@example
@{ -> string @}
@end example

The @code{print1DataStack} function attempts to produce a
one-line summary of the data stack of the current job.

This function may be modified or absent in future Muq versions.
@end defun


@c
@node  printTime, ]replaceSubstrings, print1DataStack, string functions
@subsection printTime
@defun printTime
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ millisecsSince1970 formatString -> formatted-string @}
@end example

The @code{printTime} provides functionality corresponding
to C's strftime(): it takes a date expressed as an integer
giving the time in milliseconds since 1970 (such as may be
obtained from .sys$s.millisecsSince1970), and a format string
similar to that used by @code{]print}, and returns a string
expressing the given time:

@example
Stack:
.sys$s.millisecsSince1970  "%c" printTime
Stack: "94Aug13:00:08:33"
@end example
The full set of format characters supported is:
@example
%A  Long day of week:  "Sunday" -> "Saturday".
%a  Short day of week: "Sun" -> "Sat"
%B  Long month:        "January" -> "December"
%b  Short month:       "Jan" -> "Dec"
%h  Same as above.
%p  "AM" or "PM".
%Z  Time zone:         "PST" vs "PDT" (etc).
%W  Week of year:      00 -> 53  (Counting from first Monday)
%d  Day of month:      01 -> 31
%e  Day of month:     " 1" -> "31"
%H  Hour of day:       00 -> 23
%I  Hour of halfday:   00 -> 12
%l  Hour of halfday:  " 0" -> "12"
%j  Day of year:      000 -> 366
%k  Hour of day:      " 0" -> "23"
%M  Minute of hour:    00  -> 59
%m  Month of year:     01  -> 12
%S  Second of minute:  00  -> 59
%U  Week of year:      00 -> 53  (Counting from first Sunday)
%w  Day of week:        0 -> 6   (0=Sunday)
%y  Year of century:   00 -> 99
%Y  Year common era: 1970 -> 1995
%s  Seconds since 1970.
%C  Convenience format: "Sat Aug 13 00:18:36 1994"
%c  convenience format: "94Aug13:00:18:36"
%D  (Date) same as %m/%d/%y
%x  Same as above
%R  Same as %H:%M
%r  Same as %I:%M:%S %p
%X  Same as %H:%M:%S
%T  Same as above
@end example

@xref{date}.  @xref{time}.
@end defun


@c
@node  ]replaceSubstrings, secureHash, printTime, string functions
@subsection ]replaceSubstrings
@defun ]replaceSubstrings @{ [ "x" "y" | "xz" ]replaceSubstrings -> "yz" @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]replaceSubstrings} function makes a series of
substitutions in a given string.  It accepts a string to
operate on and a block of old-new stringpairs, and
returns a string on which the indicated substitutions
have been performed:

@example
Stack:
[ "0" "a"   "1" "b" | "0110" ]replaceSubstrings
Stack: "abba"
pop [ "x" "xx" | "xx"  ]replaceSubstrings
Stack: "xxxx"
pop [ "x" "" | "xyzzy" ]replaceSubstrings
Stack: "yzzy"
pop [ "" "x" | "xyzzy" ]replaceSubstrings

**** Sorry: ]replaceSubstrings: Empty template string!

@end example
@end defun

@c
@node  secureHash, secureHashBinary, ]replaceSubstrings, string functions
@subsection secureHash
@defun secureHash @{ string -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is based on the Secure Hash Function (@sc{sha}-1),
as specified by international standard @sc{fips pub 180-1}:  It
mixes the information in the given block together to produce a
twenty-byte signature, which is then returned as a hex string:

@example
"abc" secureHash
Stack: "a9993e364706816aba3e25717850c26c9cd0d89d"
@end example

@xref{hash}.
@xref{|secureHash}.
@xref{|secureDigest}.
@xref{|secureDigestCheck}.
@xref{secureHashBinary}.
@xref{secureHashFixnum}.

@end defun

@c
@node  secureHashBinary, secureHashFixnum, secureHash, string functions
@subsection secureHashBinary
@defun secureHashBinary @{ string -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is identical to @code{secureHash} except the return value
is a machine-oriented string containing twenty binary bytes, instead of
a of human-oriented readable string:

@example
"abc" secureHashBinary
Stack: "©™>6Gjº>%qxPÂlœÐØ"
@end example

@xref{hash}.
@xref{|secureHash}.
@xref{|secureDigest}.
@xref{|secureDigestCheck}.
@xref{secureHash}.
@xref{secureHashFixnum}.

@end defun

@c
@node  secureHashFixnum, substring, secureHashBinary, string functions
@subsection secureHashFixnum
@defun secureHashFixnum @{ string -> fixnum @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is identical to @code{secureHash} except that the
result is returned as a single nonnegative fixnum (small integer), instead
of a string.

@sc{caveat programmer}: Since the normal @code{secureHash} return value
contains 160 bits, and a nonnegative Muq fixnum contains only
62 bits, this is much less secure: Use in authentication is not
recommended.

However, if you just want a quick and easy way of reducing a string to
an efficient integer form, @code{secureHashFixnum} may be just the
ticket.

The specific application I had in mind when introducing this was
procedurally defined worlds in which a room is defined by a canonical
path string for it looking something like (say)
@code{"north;west;north;up@dots{}"} -- a fixnum hash of this canonical
name may then be an excellent basis from which to generate name and
contents for the room:

@example
[ "Alice's Acres" "Barb's BAR-B-Q" "Carol's Chalet" | ]vec --> names
Stack:
"n;s;e;w" secureHashFixnum
Stack: 3030486389481771550
3 % --> h
Stack:
names[h]
Stack: "Barb's BAR-B-Q"
@end example

@xref{hash}.
@xref{|secureHash}.
@xref{|secureDigest}.
@xref{|secureDigestCheck}.
@xref{secureHash}.
@xref{secureHashBinary}.

@end defun

@c
@node  substring, substring?, secureHashFixnum, string functions
@subsection substring
@example
@{ string start stop -> string @}
@end example

The @code{substring} function extracts a substring from a given
string:

@example
Stack:
"abcde" 1 2 substring
Stack: "b"
@end example

@xref{stringWords[}. @xref{chopString[}.
@xref{substring[}.


@c
@node  substring?, substring[, substring, string functions
@subsection substring?
@defun substring?
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ string pat -> flag @}
@end example

The @code{substring?} function returns TRUE iff it locates a
substring in a string.

This is entirely equivalent to @code{string pat findSubstring? pop pop}.
@end defun


@c
@node  substring[, time, substring?, string functions
@subsection substring[
@example
@{ string start stop -> [ chars | @}
@end example

The @code{substring[} function extracts a substring from a given
string, returning it as a block of chars:

@example
Stack:
"abcde" 1 3 substring
Stack: [ 'b' 'c' |
@end example

@xref{substring}.


@c
@node  time, toDelimitedString, substring[, string functions
@subsection time
@defun time @{ -> " 9:45PM" @}
@display
@exdent file: 10-C-utils.muf
@exdent package: muf
@exdent status: alpha
@end display

The @code{time} function is a trivial convenience function
returning the current time.  It is currently defined as

@example
: time @{ -> $ @}
    .sys$s.millisecsSince1970 "%l:%M%p" printTime
;
@end example

@xref{date}.  @xref{printTime}.
@end defun

@c


@c
@node  toDelimitedString, stringDowncase, time, string functions
@subsection toDelimitedString
@defun toDelimitedString @{ any -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{toDelimitedString} function accepts any sort of argument
and attempts to produce a short human-readable string
display of it.  Strings will be surrounded by double-quotes,
and characters will be surrounded by single-quotes.

@xref{print}.  @xref{]print}.   @xref{toString}.
@end defun

@c
@node  stringDowncase, stringMixedcase, toDelimitedString, string functions
@subsection stringDowncase
@defun stringDowncase
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ string -> string @}
@end example

The @code{stringDowncase} function maps all characters in the
given string to lower case:

@example
Stack:
"You know, I love Lucy." stringDowncase
Stack: "you know, i love lucy."
@end example

@xref{stringMixedcase}.
@xref{stringUpcase}.
@xref{downcase}.
@xref{|downcase}.
@end defun


@c
@node  stringMixedcase, stringUpcase, stringDowncase, string functions
@subsection stringMixedcase
@defun stringMixedcase
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ string -> string @}
@end example

The @code{stringMixedcase} function makes a weak attempt to map
all characters in the given string to pleasing values:
@example
Stack: "you know, i love lucy."
stringMixedcase
Stack: "You know, I love lucy."
@end example

@xref{stringUpcase}.
@xref{stringDowncase}.
@end defun


@c
@node  stringUpcase, toString, stringMixedcase, string functions
@subsection stringUpcase
@defun stringUpcase
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

@example
@{ string -> string @}
@end example

The @code{stringUpcase} function maps all characters in the
given string to upper case:

@example
Stack: "You know, I love lucy."
stringUpcase
Stack: "YOU KNOW, I LOVE LUCY."
@end example

@xref{stringMixedcase}.
@xref{stringDowncase}.
@xref{upcase}.
@xref{|upcase}.
@end defun


@c
@node  toString, trimString, stringUpcase, string functions
@subsection toString
@defun toString @{ any -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{toString} function accepts any sort of argument
and attempts to produce a short human-readable string
display of it.  This is the conversion used by the comma
(@code{writeOutputStream}) operator.  Strings are not
surrounded by double-quotes; Characters are not surrounded
by single-quotes nor newlines (and so forth) converted to
'\n' form.

@xref{print}.  @xref{]print}.   @xref{toDelimitedString}.
@end defun


@c
@node  trimString, unprintFormatString[, toString, string functions
@subsection trimString
@defun trimString @{ string -> string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

The @code{trimString} function removes all leading and trailing
whitespace from the given string, and returns the result.

@sc{note}: It should perhaps take an argument string
consisting of the characters to strip.
@end defun


@c
@node  unprintFormatString[, unprint[, trimString, string functions
@subsection unprintFormatString[
@defun unprintFormatString[
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

@example
@{ string -> [] @}
@end example

The @code{unprintFormatString[} function breaks up a
@code{]print} style format string into its components and
returns them as a block.  It is intended to be used by
programmers who intend to implement a superset of
@code{]print} or else a similar function, such as the muck
one that does pronoun substituion:

@example
Stack:
"This %s a %3.5d %8.2string" unprintFormatString[
Stack: [ "This " "%s" " a " "%3.5d" " " "%8.2s" "tring" |
@end example
@end defun


@c
@node  unprint[, wrapString, unprintFormatString[, string functions
@subsection unprint[
@defun unprint[
@display
@exdent file: job.t
@exdent package: muf
@exdent status: tentative
@end display

@example
@{ string format -> [] @}
@end example

The @code{unprint[} function is a muf wrapper around
C's @code{sscanf}:

@example
Stack:
"12 128.45 hike!" "%d %f %s" unprint[
Stack: [ 12 128.45 "hike!" |
@end example
@end defun


@c
@node  wrapString, structure functions, unprint[, string functions
@subsection wrapString
@defun wrapString @{ delim width in-string -> wrapped-string @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function is intended to allow very simple reformatting
of a paragraph for viewing on a terminal of specified width
in characters.

The @code{delim} parameter is an end-of-line delimiter.
It will usually be "\n", but may (for instance) be set
to "\n  " to produce indented text, or perhaps might
include padding nuls.  The @code{wrapString} function
treats @code{delim} as being of zero length for line-length
computation, so you should reduce @code{width}
accordingly if you are using @code{delim} to implement
indentation.

The @code{width} parameter is a terminal width.  Setting it
to 80 will use the full width of the terminal.  However,
many people suggest using line widths of no more than 72
in order to enhance readability.

The @code{in-string} parameter is the string to be wrapped,
which is presumed to consist of running printable text --
words delimited by whitespace.

The @code{wrapString} function converts all existing
newlines to blanks, then replaces whitespace sequences by
@code{delim} where-ever needed in order to ensure that no
line is more than @code{width} characters long.  If any
word is more than @code{width} characters long, it is
chopped into fragments @code{width} characters long, with
no attempt at hyphenation or finding intelligent points
at which to break the word.

@example
Stack:
"Now is the time for all good furries to come ..."
Stack: "Now is the time for all good furries to come ..."
15 "\n        " wrapString
Stack: "Now is the time
        for all good
        furries to come
        ..."
@end example
@end defun


@c
@node structure functions, structure overview, wrapString, Core Muf
@section structure functions
@cindex Structure functions

User level functions used to manipulate structures.

@menu
* structure overview::
* ]defstruct::
* structure wrapup::
@end menu

@c
@node  structure overview, ]defstruct, structure functions, structure functions
@subsection structure overview

Muq structures are taken from CommonLisp, and are
similar to "structs" in C or "records" in Pascal:
They provide a perspicuous and efficient way of
allocating a chunk of storage organized as a set
of named slots.


@c
@node  ]defstruct, structure wrapup, structure overview, structure functions
@subsection ]defstruct
@defun ]defstruct @{ [args] -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

As the name suggests, @code{]defstruct} defines a
structure.  A typical sample use is:

@example
Stack:
[ 'ship   'x 'y 'mass | ]defstruct
@end example

@noindent
which accomplishes the following:

@itemize @bullet
@item
Declares a @code{ship} structure type with three components,
@code{x}, @code{y} and @code{mass}.
@item
The symbol @code{ship} becomes the name of this structure type.
@item
Constructs a function @code{ship?} which is true of (only)
instances of this structure type.
@item
Constructs a function @code{]make-ship} which constructs
instances of this type: @code{[ :x 0.5 :y 2.0 :mass 15.0 | ]make-ship --> s}
@end itemize

The full syntax follows the CommonLisp standard fairly
closely, and (hence?) is fairly intimidating.  Using
the notation @strong{(* x | y *)} to indicate a
sequence of zero or more @strong{x} and/or @strong{y}
instances:

@example
'somestructname (*
  :concName      string |
  :constructor    symbol |
  :copier         symbol |
  :assertion      symbol |
  :predicate      symbol |
  :include        symbol |
  :printFunction cfn    |
  :type           symbol |
  :named          symbol |
  :initialOffset symbol |
  :export         t      *)
(* 'someslotname (*
    :init any                  |
    :type type                 |
    :readOnly tOrNil        |
    :rootMayRead    tOrNil |
    :rootMayWrite   tOrNil |
    :userMayRead    tOrNil |
    :userMayWrite   tOrNil |
    :classMayRead   tOrNil |
    :classMayWrite  tOrNil |
    :worldMayRead   tOrNil |
    :worldMayWrite  tOrNil |
*) *)
@end example

The first group of options apply to the structure
proper; The last group of options apply to a particular
slot.

Structure options:

@table @code
@item :concName      string
By default, if a structure named @code{ship}
has slots named @code{mast} and @code{sail},
@code{]defstruct} will generate slot-reading
functions called @code{ship-mast} and
@code{ship-sail}, and slot-writing functions
called @code{set-ship-mast} and @code{set-ship-sail}.
Specifying @code{:concName "boat-"} will result
in slot-reading functions called @code{boat-mast}
and @code{boat-sail} and slot-writing functions
called @code{set-boat-mast} and @code{set-boat-sail}.

@item :constructor    symbol
By default, a structure named @code{ship} will
have a constructor function named @code{]make-ship}.
Specifying @code{:constructor 'xx} will result in
a constructor function named @code{xx}.

@item :copier         symbol
By default, a structure named @code{ship} will
have a copier function named @code{copy-ship}.
Specifying @code{:constructor 'cc} will result in
a copier function named @code{cc}.

@item :assertion      symbol
By default, a structure named @code{ship} will
have an assertion function named @code{is-a-ship}.
Specifying @code{:assertion 'aa} will result in
an assertion function named @code{aa}.

@item :predicate      symbol
By default, a structure named @code{ship} will
have an assertion function named @code{ship?}.
Specifying @code{:predicate 'pp} will result in
a predicate function named @code{dd}.

@item :include        symbol
By default, a structure contains only the slots
explicitly named.  Specifying @code{:include
'somestruct} where @code{somestruct} is a symbol naming
some previously defined structure type will result in
all the slots of @code{somestruct} being included in
the new structure, plus the predicate and slot
functions for the old structure working on the
corresponding slots of the new structure.  This is a
simple but useful form of single inheritence.

@item :printFunction cfn
This is specified by the CommonLisp standard
but currently ignored.

@item :type           symbol
This is specified by the CommonLisp standard
but currently ignored.

@item :named          symbol
This is specified by the CommonLisp standard
but currently ignored.

@item :initialOffset symbol
This is specified by the CommonLisp standard
but currently ignored.

@item :export t
This is not specified by the CommonLisp standard,
but I got sick of exporting all the functions
generated by a defstruct one at a time by hand:
If you set this flag, defstruct will export all
symbols it creates.
@end table

Slot options:

@table @code
@item :initval any
Specifies the default value for the slot if
none is specified in the @code{]make-foo}
command.

@item :initform nil-or-compiled-fn
If non-nil, specifies a compiled function
of no arguments and one return value which
provides the default initial value for the
slot.  If @code{:initform} is non-nil,
@code{:initval} is ignored.  The @code{:initform}
option provides a way to compute initial
values at structure creation time: In particular,
it is useful when you want to create a fresh
object to fill the slot each time a new
structure is created.
command.

@item :type type
This is specified by the CommonLisp standard
but currently ignored.

@item :readOnly        tOrNil
This is specified by the CommonLisp standard
and interpreted as being the negation of
@code{:userMayWrite}.

@item :rootMayRead    tOrNil
This may be set only by root running
@sc{omnipotent}, and prevents root
from reading the field.  Included
mainly for completeness.

@item :rootMayWrite   tOrNil
This may be set only by root running
@sc{omnipotent}, and prevents root
from writing the field.  May be
useful for protecting important
data, or indicating that it may
be safely cached on remote servers.

@item :userMayRead    tOrNil
Controls whether this slot may
be read by the user who did the
@code{]make-foo} creating the
structure containing the slot.

@item :userMayWrite   tOrNil
Controls whether this slot may
be written by the user who did the
@code{]make-foo} creating the
structure containing the slot.

@item :classMayRead  tOrNil
Controls whether this slot may
be read by the owner of the class
defining the object.

@item :classMayWrite tOrNil
Controls whether this slot may
be written by the owner of the
class defining the object.

@item :worldMayRead   tOrNil
Controls whether this slot may
be read by random unprivileged
users.

@item :worldMayWrite  tOrNil
Controls whether this slot may
be written by random unprivileged
users.
@end table
@end defun


@c
@node  structure wrapup, low-level structure functions, ]defstruct, structure functions
@subsection structure wrapup


@c
@node low-level structure functions, low-level structure overview, structure wrapup, Core Muf
@section low-level structure functions
@cindex Structure functions

Low level functions used in implementing structures.

@menu
* low-level structure overview::
* copyStructure::
* copyStructureContents::
* ]makeStructure::
* getStructureSlotProperty::
* setStructureSlotProperty::
* findMosKeySlot::
* getNthStructureSlot::
* setNthStructureSlot::
* getNamedStructureSlot::
* setNamedStructureSlot::
* |errorIfEphemeral::
* low-level structure wrapup::
@end menu

@c
@node  low-level structure overview, copyStructure, low-level structure functions, low-level structure functions
@subsection low-level structure overview

The functions in this section constitute the
C-coded Muq server support for structures.  They
are not normally used directly by application
programmers, but may be of interest to people
writing Muq compilers.

@c
@node  copyStructure, copyStructureContents, low-level structure overview, low-level structure functions
@subsection copyStructureContents
@defun copy @{ old-struct structure-definition -> new-struct @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{copyStructure} function accepts a structure
and returns a copy of it.  Structure slots are copied
by reference, not value:  Only the structure itself
is copied, not any of the values referenced by it.

If @code{structure-definition} is not @code{nil}, an
error is signaled unless @code{old-struct} is an
instance of it.

@end defun


@c
@node  copyStructureContents, ]makeStructure, copyStructure, low-level structure functions
@subsection copyStructureContents
@defun copyStructureContents @{ dst src -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{copyStructureContents} function accepts two
structures, which must be of the same type, and copies
the contents of @code{src} into @code{dst}.

@end defun


@c
@node  ]makeStructure, getStructureSlotProperty, copyStructureContents, low-level structure functions
@subsection ]makeStructure
@defun ]makeStructure @{ [args] structureClass -> structure @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]makeStructure} function accepts a
block of keywordValue pairs and a
@code{mosClass} instance defining a structure
class, and creates an appropriately initialized
instance of the structure.

@end defun


@c
@node  getStructureSlotProperty, setStructureSlotProperty, ]makeStructure, low-level structure functions
@subsection getStructureSlotProperty
@defun getStructureSlotProperty @{ sdf key slot -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getStructureSlotProperty} returns the value of property @code{key}
(a keyword) on slot number @code{slot} (an integer) in
structure-definition @code{sdf}.

The slot properties supported are:

@table @code
@item :keyword
A keyword giving the name of the slot.
@item :initform
CompiledFunction generating initial value for slot, else nil.
@item :initval
Default initial value for slot, else nil.  Ignored if :initform non-nil.
@item :type
Type of slot.  (Currently ignored.)
@item :documentation
Documentation for slot.
@item :getFunction
Function which fetches a value from this slot.
@item :setFunction
Function which stores a value into this slot.
@item :rootMayRead
@code{nil} unless omnipotent root may read this slot.
@item :rootMayWrite
@code{nil} unless omnipotent root may write this slot.
@item :userMayRead
@code{nil} unless structure owner may read this slot.
@item :userMayWrite
@code{nil} unless structure owner may write this slot.
@item :classMayRead
@code{nil} unless structure-definition owner may read this slot.
@item :classMayWrite
@code{nil} unless structure-definition owner may write this slot.
@item :worldMayRead
@code{nil} unless arbitrary users may read this slot.
@item :worldMayWrite
@code{nil} unless arbitrary users may write this slot.
@end table

@xref{setStructureSlotProperty}.
@end defun


@c
@node  setStructureSlotProperty, findMosKeySlot, getStructureSlotProperty, low-level structure functions
@subsection setStructureSlotProperty
@defun setStructureSlotProperty @{ sdf key slot val -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setStructureSlotProperty} sets the value of property @code{key}
(a keyword) on slot number @code{slot} (an integer) in
structure-definition @code{sdf} to @code{val}.

You must be @code{root} running with
@sc{omnipotent} to modify the @code{:root-*} slot properties.

You may not change a slot property after the first instance
of that structure has been created.  This restriction
prevents security problems relating to the owner of a
structure changing slot access privileges after some
other user of the structure definition has created
instances depending on the declared slot security settings.

@xref{getStructureSlotProperty}.
@end defun


@c
@node  findMosKeySlot, getNthStructureSlot, setStructureSlotProperty, low-level structure functions
@subsection findMosKeySlot
@defun findMosKeySlot @{ mosKey symbol -> slot @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findMosKeySlot} function accepts a
@code{mosKey} and a symbol, and
returns the number of the slot named by that
symbol, else @code{nil}.

@end defun


@c
@node  getNthStructureSlot, setNthStructureSlot, findMosKeySlot, low-level structure functions
@subsection getNthStructureSlot
@defun getNthStructureSlot @{ struct mosClass slot -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getNthStructureSlot} function accepts
a structure @code{struct}, a mosClass
@code{mosClass} and an integer slot number
@code{slot}, and returns the value of the given
slot in the given structure.  An error is signaled
if @code{mosClass} is not @code{nil} and
@code{struct} not an instance of it.

@end defun


@c
@node  setNthStructureSlot, getNamedStructureSlot, getNthStructureSlot, low-level structure functions
@subsection setNthStructureSlot
@defun setNthStructureSlot @{ struct val mosClass slot -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setNthStructureSlot} function accepts a
structure @code{struct}, a structure-definition
@code{mosClass} and an integer slot number
@code{slot}, and sets the value of this slot to
@code{val}.  An error is signaled if @code{mosClass} is
not @code{nil} and @code{struct} not an instance of it.

@end defun


@c
@node  getNamedStructureSlot, setNamedStructureSlot, setNthStructureSlot, low-level structure functions
@subsection getNamedStructureSlot
@defun getNamedStructureSlot @{ struct mosClass key -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getNamedStructureSlot} function accepts a
structure @code{struct}, a mosClass
@code{mosClass} and a symbol
@code{key}, and returns the value of the given slot in
the given structure.  An error is signaled if
@code{mosClass} is not @code{nil} and @code{struct}
is not an instace of it.

@end defun


@c
@node  setNamedStructureSlot, |errorIfEphemeral, getNamedStructureSlot, low-level structure functions
@subsection setNamedStructureSlot
@defun setNamedStructureSlot @{ struct val mosClass key -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setNamedStructureSlot} function accepts a
structure @code{struct}, a @code{mosClass}
and a symbol @code{key} and sets the value of the @code{struct}
slot named by @code{key} to
@code{val}.  An error is signaled if @code{mosKey} is
not @code{nil} and @code{struct} is not an instance of @code{mosClass}.

@end defun


@c
@node  |errorIfEphemeral, low-level structure wrapup, setNamedStructureSlot, low-level structure functions
@subsection |errorIfEphemeral
@defun |errorIfEphemeral @{ [] -> [] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|errorIfEphemeral} function accepts a
block and issues an error message if the first
two values in the block are @code{:ephemeral}
followed by a non-@code{nil} value.

This is a little hack used by the constructor
functions for structures and such: Allocating an
ephemeral function in an in-db constructor
function is useless because it gets popped when
the constructor function returns.

The solution is to call the C-coded
@code{]makeStructure} primitive directly.
the @code{|errorIfEphemeral} function
is used by automatically generated constructor
functions to diagnose this problem and remind
the user of the solution.

@end defun


@c
@node  low-level structure wrapup, MOS functions, |errorIfEphemeral, low-level structure functions
@subsection low-level structure wrapup


@c
@node MOS functions, MOS overview, low-level structure wrapup, Core Muf
@section MOS functions
@cindex MOS functions

User level functions used to manipulate Muq
Object System objects and classes.

@menu
* MOS overview::
* ]defclass::
* subclassOf?::
* MOS wrapup::
@end menu

@c
@node  MOS overview, ]defclass, MOS functions, MOS functions
@subsection structure overview

Common Lisp defines possibly the most sophisticated
and flexible object-oriented programming system to
date.  This flexibility comes at the price of myriad
functions defined to control various aspects of MOS.

@c
@node  ]defclass, subclassOf?, MOS overview, MOS functions
@subsection ]defclass
@defun ]defclass @{ [args] -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

As the name suggests, @code{]defclass} defines a
class.  A typical sample use is:

@example
Stack:
[ 'ship   'x 'y 'mass | ]defclass
@end example

@noindent
which accomplishes the following:

@itemize @bullet
@item
Declares a @code{ship} structure type with three components,
@code{x}, @code{y} and @code{mass}.
@item
The symbol @code{ship} becomes the name of this structure type.
@item
Constructs a function @code{ship?} which is true of (only)
instances of this structure type.
@item
Constructs a function @code{]make-ship} which constructs
instances of this type: @code{[ :x 0.5 :y 2.0 :mass 15.0 | ]make-ship --> s}
@end itemize

The full syntax follows the CommonLisp standard fairly
closely, and (hence?) is fairly intimidating.  Using
the notation @strong{(* x | y *)} to indicate a
sequence of zero or more @strong{x} and/or @strong{y}
instances:

@example
'aClassName
(* :isA          'anotherClassName 
|  :is            'anotherClassName 
|  :has           'anotherClassName 
|  :hasA         'anotherClassName 
|  :metaclass     'metaclassName
|  :documentation "some text"
|  :fertile       tOrNil
|  :abstract      tOrNil
|  :export        tOrNil
*)
(* :slot :my-slot
  (*
  |   :initval  any
  |   :initform cfn
  |   :initarg  'aName
  |   :type type
  |   :reader   'readerFnName
  |   :writer   'writerFnName
  |   :accessor 'accessorFnName
  |   :allocation :class
  |   :allocation :instance
  |   :documentation "some text"
  |   :rootMayRead    tOrNil
  |   :rootMayWrite   tOrNil
  |   :userMayRead    tOrNil
  |   :userMayWrite   tOrNil
  |   :classMayRead   tOrNil
  |   :classMayWrite  tOrNil
  |   :worldMayRead   tOrNil
  |   :worldMayWrite  tOrNil
  |   :prot "rw----"
  *)
*)
@end example

The first group of options apply to the class
proper; The last group of options apply to a particular
slot.

Structure options:

@table @code
@item :metaclass symbol
MOS allows you to extend it by defining and
using new metaclasses.  Muq does not currently
support this.

@item :isA symbol
You need one entry like this for each superclass
of the new class.  Muq current requires that the
superclass have already been defined, although CLOS
only requires that it be defined before an
instance of the new class is created.  (The
synonyms @code{:is}, @code{:has} and @code{:hasA} are also
supported, simply because they sometimes let code
read more naturally.)

@item :documentation string
Human-readable documentation describing the class.

@item :initarg symbol value
A symbol name, and the corresponding initial value
for it.  This allows you to specify an initial
value for a slot which you are not declaring.
(Presumably you are either inheriting it, or
expect a subclass of this class to declare it.)

@end table


The next section declares those slots which are
not inherited, together with optional slot options
declaring individual properties for each slot.

Slot options:

@table @code

@item :initform any
Specifies a default initial value for the slot
in a newly created instance of the class.

@item :initarg 'symbol
Specifies a name by which the slot may be
idenfified in @code{initializeInstance}.
MOS allows multiple @code{:initarg} values
per slot, Muq currently allows only one.

@item :type type
This is specified by the CommonLisp standard
but currently ignored.

@item :documentation "some text"
This allows a human-readable description
string to be associated with the slot.

@item :allocation @{ :class | :instance @}
Normally, a slot is allocated space in each
instance of the class.  Specifying an @code{:allocation}
of @code{:class} results in the slot instead
being allocated in the class itself, containing
a single value shared between all instances.


@item :reader 'symbol
Specifies the name for a generic function which
will read the value of this slot from an instance
of this class.  MOS allows multiple
@code{:reader} options per slot, Muq currently
allows only one.

@item :writer 'symbol
Specifies the name for a generic function which
will set the value of this slot in an instance
of this class.  MOS allows multiple
@code{:writer} options per slot, Muq currently
allows only one.

@item :accessor 'xxx
Same as reader, except that a writer named
@code{setf-xxx} will also be defined.  MOS allows
multiple @code{:accessor} options per slot, Muq
currently allows only one.

@item :rootMayRead    tOrNil
This may be set only by root running
@sc{omnipotent}, and prevents root
from reading the field.  Included
mainly for completeness.

@item :rootMayWrite   tOrNil
This may be set only by root running
@sc{omnipotent}, and prevents root
from writing the field.  May be
useful for protecting important
data, or indicating that it may
be safely cached on remote servers.

@item :userMayRead    tOrNil
Controls whether this slot may
be read by the user who did the
@code{]make-foo} creating the
structure containing the slot.

@item :userMayWrite   tOrNil
Controls whether this slot may
be written by the user who did the
@code{]make-foo} creating the
structure containing the slot.

@item :classMayRead  tOrNil
Controls whether this slot may
be read by the owner of the
class defining the object.

@item :classMayWrite tOrNil
Controls whether this slot may
be written by the owner of the
class defining the object.

@item :worldMayRead   tOrNil
Controls whether this slot may
be read by random unprivileged
users.

@item :worldMayWrite  tOrNil
Controls whether this slot may
be written by random unprivileged
users.

@item :prot "rw----"
An abbreviation for the preceding
six properties:  The six characters
in the value string
control user, class and world
read/write privileges in the
obvious fashion.  

@end table
@end defun

@c
@node  subclassOf?, MOS wrapup, ]defclass, MOS functions
@subsection subclassOf?
@defun ]defclass @{ classA classB -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

A simple test to determine whether classA has classB as an ancestor.

@example
stack:
defclass: ClassA ;
stack:
defclass: ClassB   :isA 'ClassA ;
stack:
defclass: ClassC   :isA 'ClassB ;
stack:
'ClassC$s.type 'ClassA$s.type subclassOf?
stack: t
pop 'ClassA$s.type 'ClassC$s.type subclassOf?
stack: nil
@end example

@end defun

@c
@node  MOS wrapup, low-level MOS functions, subclassOf?, MOS functions
@subsection MOS wrapup


@c
@node low-level MOS functions, low-level MOS overview, MOS wrapup, Core Muf
@section low-level MOS functions
@cindex Low-level MOS functions

Low level functions used in implementing the
Muq Object System (MOS) support.

@menu
* low-level MOS overview::
* makeMosClass::
* makeMosKey::
* makeLambdaList::
* makeMethod::
* getMosKey::
* linkMosKeyToAncestor::
* unlinkMosKeyFromAncestor::
* nextMosKeyLink::
* getMosKeyAncestor::
* getMosKeyAncestor?::
* setMosKeyAncestor::
* getMosKeyParent::
* setMosKeyParent::
* getMosKeySlotProperty::
* setMosKeySlotProperty::
* getMosKeyInitarg::
* setMosKeyInitarg::
* getMosKeyMetharg::
* setMosKeyMetharg::
* getMosKeySlotarg::
* setMosKeySlotarg::
* getMosKeyObjectMethod::
* setMosKeyObjectMethod::
* getMosKeyClassMethod::
* setMosKeyClassMethod::
* insertMosKeyClassMethod::
* deleteMosKeyClassMethod::
* insertMosKeyObjectMethod::
* deleteMosKeyObjectMethod::
* findMosKeyClassMethod?::
* findMosKeyObjectMethod?::
* getLambdaSlotProperty::
* setLambdaSlotProperty::
* getMethodSlot::
* setMethodSlot::
* |applicableMethod?::
* methodsMatch?::
* mosKeyUnsharedSlotsMatch?::
* findMosKeySlot::
* copyMosKeySlot::
* mosPredenceList[::
* |applyLambdaList::
* low-level MOS wrapup::
@end menu

@c
@node  low-level MOS overview, makeMosClass, low-level MOS functions, low-level MOS functions
@subsection low-level MOS overview

The functions in this section constitute the
C-coded Muq server support for the Muq
Object System.  They are not normally used
directly by application programmers, but may be of
interest to people writing Muq compilers.  They
are quite similar to, but more elaborate than,
the low-level support functions for structures.

@xref{low-level structure functions}.


@c
@node  makeMosClass, makeMosKey, low-level MOS overview, low-level MOS functions
@subsection makeMosClass
@defun makeMosClass @{ -> newClass @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeMosClass} function constructs and
returns a new @code{mosClass} instance.  This is
a very low-level call, and the returned value is
rather useless as it stands:  One needs to set the
@code{key} property of the class to an appropriate
@code{mosKey} object (typically freshly
created) before the new class may be used to
create new objects via @code{]makeStructure}.

@xref{makeMosKey}. @xref{]makeStructure}.

@end defun


@c
@node  makeMosKey, makeLambdaList, makeMosClass, low-level MOS functions
@subsection makeMosKey
@defun makeMosKey @{ class us ss ip pl sa ma ia om cm -> key @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeMosKey} function creates a @code{mosKey}
instance.

The @code{class} parameter must be a @sc{mos}
class.

The @code{us} (unshared slots) parameter must be an nonnegative
integer specifying the number of unshared slots --
those stored in the instances (as opposed to the key).
These will be first in the internal slots array.

The @code{ss} (shared slots) parameter must be a nonnegative
integer specifying the number of shared slots --
those stored in the key (as opposed to the instances).
These will follow the unshared slots in the
internal slots array.

The @code{ip} (immediate parents) parameter must be a nonnegative
integer specifying the number of direct superclasses.

The @code{pl} (precedence list) parameter must be a nonnegative
integer specifying the number of entries in the
class precedence list.  (The class precedence
list contains all direct and indirect superclasses
of the class, in topologically sorted order.)

The @code{sa} (slot-args) parameter must be a nonnegative
integer specifying the number of symbols
in the vector of valid slot initializer argnames
for the @code{makeInstance} call.

The @code{ma} (method-args) parameter must be a nonnegative
integer specifying the number of symbols
in the vector of valid method initializer argnames
for the @code{makeInstance} call.

The @code{ia} (initargs) parameter must be a nonnegative
integer specifying the number of initarg->slotname
pairs in the initargs vector.  (This vector maps
initialization names in the objectCreation call
to matching slotnames to be initialized.)

The @code{om} (object methods) parameter must be a nonnegative
integer specifying the number of slots to reserve for
methods specializing on an object of this type in the first parameter.

The @code{cm} (class methods) parameter must be a nonnegative
integer specifying the number of slots to reserve
for methods specializing
on this class in the first parameter.

@end defun


@c
@node  makeLambdaList, makeMethod, makeMosKey, low-level MOS functions
@subsection makeLambdaList
@defun makeLambdaList @{ REQ_ARGS optArgs key-args slots -> lambda @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeLambdaList} function creates a @code{lambdaList}
instance.

The @code{REQ_ARGS} parameter is an integer giving the
number of required arguments.

The @code{optArgs} parameter is an integer giving the
number of optional arguments.

The @code{key-args} parameter is an integer giving the
number of keyword arguments.

The @code{slots} parameter is an integer giving the
number of stackframe variable slots used.

@xref{getLambdaSlotProperty}.
@xref{setLambdaSlotProperty}.
@xref{|applyLambdaList}.

@end defun


@c
@node  makeMethod, getMosKey, makeLambdaList, low-level MOS functions
@subsection makeMethod
@defun makeMethod @{ requiredArgs -> method @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeMethod} function creates a @code{method}
instance.

The @code{requiredArgs} parameter is an integer giving the
number of required arguments.

@end defun


@c
@node  getMosKey, linkMosKeyToAncestor, makeMethod, low-level MOS functions
@subsection getMosKey
@defun getMosKey @{ any -> key @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKey} function returns the key
for @code{any} -- an object describing the
layout and implemention of @code{any}.

The @code{getMosKey} function will return a
valid and appropriate @code{key} for any
Muq value, including (for example) integers,
floats and strings, as well as stacks, jobs,
structs, vectors, objects and so forth.

The @code{getMosKey} function is intende
primarily as an efficient, dedicated hack
supporting implementation of generic functions
by rapidly locating the key indexing the
generic functions defined for a given value.

@end defun

@c
@node  linkMosKeyToAncestor, unlinkMosKeyFromAncestor, getMosKey, low-level MOS functions
@subsection linkMosKeyToAncestor
@defun linkMosKeyToAncestor @{ mosKey slot-num -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{linkMosKeyToAncestor} function links
@code{mosKey} to its @code{slot-num}-th ancestor
(using hidden links in its internal ancestor vector).

The effective user must either control the ancestor
in question or else it's @code{fertile} flag must
be non-@code{nil}.

This provides a way to find all descendants of a
given superclass when it is time to update them to
reflect changes in the superclass.

@xref{nextMosKeyLink}.
@xref{unlinkMosKeyFromAncestor}.

@end defun

@c
@node  unlinkMosKeyFromAncestor, nextMosKeyLink, linkMosKeyToAncestor, low-level MOS functions
@subsection unlinkMosKeyFromAncestor
@defun unlinkMosKeyFromAncestor @{ mosKey slot-num -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{unlinkMosKeyFromAncestor} function unlinks
@code{mosKey} from its @code{slot-num}-th ancestor
(as recorded in hidden links in its internal ancestor vector).

This is normally done when the @code{mosKey} in function
is obsolete, to allow it to be garbage-collected normally
in due course (something which the hidden links would
otherwise prevent).

@xref{nextMosKeyLink}.
@xref{linkMosKeyToAncestor}.

@end defun

@c
@node  nextMosKeyLink, getMosKeyAncestor, unlinkMosKeyFromAncestor, low-level MOS functions
@subsection nextMosKeyLink
@defun nextMosKeyLink @{ mosKey slot-num -> mosKey slot-num @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{nextMosKeyLink} function permits
traversal of the linklist joining a superclass
to its subclasses -- useful when trying to update
all descendants of a given superclass to reflect
changes in that superclass.

The @code{slot-num} value will be -1 for the
superclass proper, and a non-negative integer
for its descendants.

@xref{unlinkMosKeyFromAncestor}.
@xref{linkMosKeyToAncestor}.

@end defun


@c
@node  getMosKeyAncestor, getMosKeyAncestor?, nextMosKeyLink, low-level MOS functions
@subsection getMosKeyAncestor
@defun getMosKeyAncestor @{ key slot -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeyAncestor} prim returns the
contents of ancestor slot @code{slot} in
mosKey instance @code{key} -- the return
value is the @code{slot}-th class in
the precedence list for @code{key}.

@xref{getMosKeyAncestor?}.
@xref{setMosKeyAncestor}.
@end defun


@c
@node  getMosKeyAncestor?, setMosKeyAncestor, getMosKeyAncestor, low-level MOS functions
@subsection getMosKeyAncestor?
@defun getMosKeyAncestor? @{ key slot -> nil-or-t val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeyAncestor?} prim returns the
contents of ancestor slot @code{slot} in
mosKey instance @code{key} -- the return
value is the @code{slot}-th class in
the precedence list for @code{key} -- together
with a @code{t} success flag, if such an ancestor
exists, else a @code{nil} success flag and
undefined value.

@xref{getMosKeyAncestor}.
@xref{setMosKeyAncestor}.
@end defun


@c
@node  setMosKeyAncestor, getMosKeyParent, getMosKeyAncestor?, low-level MOS functions
@subsection setMosKeyAncestor
@defun setMosKeyAncestor @{ key slot mosClass -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMosKeyAncestor} prim sets the
@code{slot}-th precedence list entry for mosKey
instance @code{key} to be @code{mosClass}.  This is a
low-level call which only fills in a slot!

An error will be signalled unless either
@code{mosClass$s.key$s.fertile} is non-@code{nil},
or else controlled (owned) by @@$s.actingUser).
(This allows users some control over subclassing
of their classes by others.)

@xref{getMosKeyAncestor}.
@end defun


@c
@node  getMosKeyParent, setMosKeyParent, setMosKeyAncestor, low-level MOS functions
@subsection getMosKeyParent
@defun getMosKeyParent @{ key slot -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeyParent} prim returns the
contents of parent slot @code{slot} in
mosKey instance @code{key} -- the return
value is the @code{slot}-th direct superclass
of @code{key}.

@xref{setMosKeyParent}.
@end defun


@c
@node  setMosKeyParent, getMosKeySlotProperty, getMosKeyParent, low-level MOS functions
@subsection setMosKeyParent
@defun setMosKeyParent @{ key slot mosClass -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMosKeyParent} prim sets the
@code{slot}-th direct superclass of mosKey
instance @code{key} to be @code{mosClass}.  This
is a low-level call which only fills in a slot --
it won't take care of (for example) inheritance of
slots from @code{val}!

An error will be signalled unless either
@code{mosClass$s.key$s.fertile} is non-@code{nil},
or else controlled (owned) by @@$s.actingUser).
(This allows users some control over subclassing
of their classes by others.)

@xref{getMosKeyParent}.
@end defun


@c
@node  getMosKeySlotProperty, setMosKeySlotProperty, setMosKeyParent, low-level MOS functions
@subsection getMosKeySlotProperty
@defun getMosKeySlotProperty @{ mosKey key slot -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeySlotProperty} returns the value of property @code{key}
(a keyword) on slot number @code{slot} (an integer) in
mosKey @code{mosKey}.

The slot properties supported are:

@table @code
@item :symbol
A symbol naming the slot.
@item :initform
Fn returning initial value for slot, else nil.
@item :initval
Default initial value for slot.
@item :allocation
Either :class (meaning slot is shared among all instances) or :instance.
@item :documentation
Text description of slot.
@item :type
Type of slot.  (Currently ignored; Reserved.)
@item :getFunction
Function which fetches a value from this slot.
@item :setFunction
Function which stores a value into this slot.
@item :rootMayRead
@code{nil} unless omnipotent root may read this slot.
@item :rootMayWrite
@code{nil} unless omnipotent root may write this slot.
@item :userMayRead
@code{nil} unless structure owner may read this slot.
@item :userMayWrite
@code{nil} unless structure owner may write this slot.
@item :classMayRead
@code{nil} unless structure-definition owner may read this slot.
@item :classMayWrite
@code{nil} unless structure-definition owner may write this slot.
@item :worldMayRead
@code{nil} unless arbitrary users may read this slot.
@item :worldMayWrite
@code{nil} unless arbitrary users may write this slot.
@item :inherited
@code{nil} unless slot is shared and located in
another mosKey instance.
@end table

@xref{setMosKeySlotProperty}.
@end defun


@c
@node  setMosKeySlotProperty, getMosKeyInitarg, getMosKeySlotProperty, low-level MOS functions
@subsection setMosKeySlotProperty
@defun setMosKeySlotProperty @{ key sym slot val -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMosKeySlotProperty} sets the value of property @code{sym}
(a symbol) on slot number @code{slot} (an integer) in
mosKey instance @code{key} to @code{val}.

You must be @code{root} running with
@sc{omnipotent} to modify the @code{:root-*} slot properties.

You may not change a slot property after the first
object instance of that mosKey has been
created.  This restriction prevents security
problems relating to the owner of a class
changing slot access privileges after some other
user of the class definition has created
instances depending on the declared slot security
settings.

@xref{getMosKeySlotProperty}.
@end defun


@c
@node  getMosKeyInitarg, setMosKeyInitarg, setMosKeySlotProperty, low-level MOS functions
@subsection getMosKeyInitarg
@defun getMosKeyInitarg @{ key slot -> key val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeyInitarg} returns the @code{key}/@code{val} pair
stored in the given @code{slot} of the given @code{mosKey}'s internal
initarg array.

@xref{setMosKeyInitarg}.
@end defun


@c
@node  setMosKeyInitarg, getMosKeyMetharg, getMosKeyInitarg, low-level MOS functions
@subsection getMosKeyInitarg
@defun setMosKeyInitarg @{ key slot key val -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMosKeyInitarg} sets the @code{key}/@code{val}
pair stored in the @code{slot}-th slot of the @code{key}'s
internal initarg array.

@xref{getMosKeyInitarg}.
@end defun


@c
@node  getMosKeyMetharg, setMosKeyMetharg, setMosKeyInitarg, low-level MOS functions
@subsection getMosKeyMetharg
@defun getMosKeyMetharg @{ key slot -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeyMetharg} returns the @code{val}
stored in the given @code{slot} of the given @code{mosKey}'s internal
metharg array, which lists keywords admissable as method initialization
arguments in @code{makeInstance}.

@xref{setMosKeyMetharg}.
@end defun


@c
@node  setMosKeyMetharg, getMosKeySlotarg, getMosKeyMetharg, low-level MOS functions
@subsection getMosKeyMetharg
@defun setMosKeyMetharg @{ key slot val -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMosKeyMetharg} sets the @code{val}
stored in the @code{slot}-th slot of the @code{key}'s
internal metharg array.

@xref{getMosKeyMetharg}.
@end defun


@c
@node  getMosKeySlotarg, setMosKeySlotarg, setMosKeyMetharg, low-level MOS functions
@subsection getMosKeySlotarg
@defun getMosKeySlotarg @{ key slot -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeySlotarg} returns the @code{val}
stored in the given @code{slot} of the given @code{mosKey}'s internal
slotarg array, which lists keywords admissable as slot initialization
arguments in @code{makeInstance}.

@xref{setMosKeySlotarg}.
@end defun


@c
@node  setMosKeySlotarg, getMosKeyObjectMethod, getMosKeySlotarg, low-level MOS functions
@subsection getMosKeySlotarg
@defun setMosKeySlotarg @{ key slot val -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMosKeySlotarg} sets the @code{val}
stored in the @code{slot}-th slot of the @code{key}'s
internal metharg array.

@xref{getMosKeySlotarg}.
@end defun


@c
@node  getMosKeyObjectMethod, setMosKeyObjectMethod, setMosKeySlotarg, low-level MOS functions
@subsection getMosKeyObjectMethod
@defun getMosKeyObjectMethod @{ key slot -> argno g-fn method object @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeyObjectMethod} function returns the
@code{argument-number} @code{genericFunction}, @code{method}
@code{object}
quadruple
stored in the given @code{slot} of the given @code{mosKey}'s internal
object-method array.

@xref{setMosKeyObjectMethod}.
@end defun


@c
@node  setMosKeyObjectMethod, getMosKeyClassMethod, getMosKeyObjectMethod, low-level MOS functions
@subsection setMosKeyObjectMethod
@defun setMosKeyObjectMethod @{ key slot argno g-fn method obj -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMosKeyObjectMethod} function sets the
@code{argument-number} @code{genericFunction} @code{method} @code{object}
quadruple stored in the @code{slot}-th slot of the @code{key}'s
internal object-method array.

@xref{getMosKeyObjectMethod}.
@end defun


@c
@node  getMosKeyClassMethod, setMosKeyClassMethod, setMosKeyObjectMethod, low-level MOS functions
@subsection getMosKeyClassMethod
@defun getMosKeyClassMethod @{ key slot -> argno g-fn method @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMosKeyClassMethod} function returns the
@code{argument-number} @code{genericFunction} @code{method} triplet
stored in the given @code{slot} of the given @code{mosKey}'s internal
classMethod array.

@xref{setMosKeyClassMethod}.
@end defun


@c
@node  setMosKeyClassMethod, insertMosKeyClassMethod, getMosKeyClassMethod, low-level MOS functions
@subsection setMosKeyClassMethod
@defun setMosKeyClassMethod @{ key slot argno g-fn method -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMosKeyClassMethod} function sets the
@code{argument-number} @code{genericFunction} @code{method} triplet
stored in the @code{slot}-th slot of the @code{key}'s
internal classMethod array.

@xref{getMosKeyClassMethod}.
@end defun

@c
@node  insertMosKeyClassMethod, deleteMosKeyClassMethod, setMosKeyClassMethod, low-level MOS functions
@subsection insertMosKeyClassMethod
@defun insertMosKeyClassMethod @{ key slot argno g-fn method -> newkey @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{insertMosKeyClassMethod} function creates
and returns a new key instance identical to the supplied
one except for the additional of the given
@code{argument-number} @code{generic-fn} @code{method} triplet to the
classMethod vector at the given @code{slot}.

@xref{insertMosKeyObjectMethod}.
@xref{deleteMosKeyClassMethod}.
@end defun

@c
@node  deleteMosKeyClassMethod, insertMosKeyObjectMethod, insertMosKeyClassMethod, low-level MOS functions
@subsection deleteMosKeyClassMethod
@defun deleteMosKeyClassMethod @{ key method -> newkey @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{deleteMosKeyClassMethod} function creates
and returns a new key instance identical to the supplied
one except for the deletion of the 
@code{generic-fn}/@code{method} pair containing
the given @code{method} from the
classMethod vector.

@xref{insertMosKeyClassMethod}.
@xref{deleteMosKeyObjectMethod}.
@end defun

@c
@node  insertMosKeyObjectMethod, deleteMosKeyObjectMethod, deleteMosKeyClassMethod, low-level MOS functions
@subsection insertMosKeyObjectMethod
@defun insertMosKeyObjectMethod @{ key slot argno g-fn method obj -> newkey @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{insertMosKeyObjectMethod} function creates
and returns a new key instance identical to the supplied
one except for the additional of the given
@code{argument-number} @code{generic-fn} @code{method} @code{object}
quadruple to the
object-method vector at the given @code{slot}.

@xref{insertMosKeyClassMethod}.
@xref{deleteMosKeyObjectMethod}.
@end defun

@c
@node  deleteMosKeyObjectMethod, findMosKeyClassMethod?, insertMosKeyObjectMethod, low-level MOS functions
@subsection deleteMosKeyObjectMethod
@defun deleteMosKeyObjectMethod @{ key method -> newkey @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{deleteMosKeyObjectMethod} function creates
and returns a new key instance identical to the supplied
one except for the deletion of the 
@code{generic-fn}/@code{method}/@code{object} triple containing
the given @code{method} from the
object-method vector.

@xref{insertMosKeyObjectMethod}.
@xref{deleteMosKeyClassMethod}.
@end defun


@c
@node  findMosKeyClassMethod?, findMosKeyObjectMethod?, deleteMosKeyObjectMethod, low-level MOS functions
@subsection findMosKeyClassMethod?
@defun findMosKeyClassMethod? @{ key argno g-fn slot -> tOrNil mtd slot @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findMosKeyClassMethod?} function searches the given
@code{key} instance's classMethod vector for a method for the given
@code{argument-number} and @code{generic-fn}, starting at the given
slot.  Return value @code{tOrNil} is @code{nil} if no such method is
found, otherwise the @code{mtd} return value is the method found, and
the @code{slot} return value is the slot at which to resume searching,
should that be desired.

@xref{findMosKeyObjectMethod?}.
@end defun

@c
@node  findMosKeyObjectMethod?, getLambdaSlotProperty, findMosKeyClassMethod?, low-level MOS functions
@subsection findMosKeyObjectMethod?
@defun findMosKeyObjectMethod? @{ key argno g-fn obj slot -> tOrNil mtd slot @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{findMosKeyObjectMethod?} function searches the given
@code{key} instance's object-method vector for a method for the given
@code{argument-number} @code{generic-fn} and @code{obj}, starting at the
given slot.  Return value @code{tOrNil} is @code{nil} if no such method
is found, otherwise the @code{mtd} return value is the method found, and
the @code{slot} return value is the slot at which to resume searching,
should that be desired.

@xref{findMosKeyClassMethod?}.
@end defun


@c
@node  getLambdaSlotProperty, setLambdaSlotProperty, findMosKeyObjectMethod?, low-level MOS functions
@subsection getLambdaSlotProperty
@defun getLambdaSlotProperty @{ lambda key slot -> val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getLambdaSlotProperty} returns the value of property @code{key}
(a keyword) on slot number @code{slot} (an integer) in
lambda-lists @code{lambda}.

The slot properties supported are:

@table @code
@item :name
A string (for required or optional args) or keyword
giving the name of the slot.
@item :initval
Default value for this parameter.
@item :initform
If non-NIL, a compiledFunction which should be
evaluated to yield the default value for this parameter.
@end table

@xref{setLambdaSlotProperty}.
@end defun


@c
@node  setLambdaSlotProperty, getMethodSlot, getLambdaSlotProperty, low-level MOS functions
@subsection setLambdaSlotProperty
@defun setLambdaSlotProperty @{ lambda key slot val -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setLambdaSlotProperty} sets the value of property @code{key}
(a keyword) on slot number @code{slot} (an integer) in
lambdaList instance @code{lambda} to @code{val}.

@xref{getLambdaSlotProperty}.
@end defun


@c
@node  getMethodSlot, setMethodSlot, setLambdaSlotProperty, low-level MOS functions
@subsection getMethodSlot
@defun getMethodSlot @{ method slot -> op arg @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{getMethodSlot} prim returns the @code{op} and @code{arg}
stored in that slot of the method.  It is expected that @code{op}
will be @code{t} if no check is needed, @code{:isA} if the
corresponding generic function argument must be an instance
of class @code{arg}, or @code{:eql} if the corresponding
generic function argument must be @code{eql} to @code{arg}.

@xref{setMethodSlot}.
@end defun


@c
@node  setMethodSlot, |applicableMethod?, getMethodSlot, low-level MOS functions
@subsection setMethodSlot
@defun setMethodSlot @{ method slot op arg -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setMethodSlot} sets contents of the
given @code{slot} to @code{op} and @code{arg}.

If @code{op} is @code{t}, the interpretation is
that the matching actual argument given to the
generic function is under no constraint. (Wild card
match.)

If @code{op} is @code{:isA}, the interpretation
is that the matching actual argument given to the
generic function must be an instance of class @code{arg}
(or a subclass of @code{arg}) in order for the method
to be applicable.

If @code{op} is @code{:eql}, the interpretation is that
the matching actual argument given to the generic
function must be @code{eql} to @code{arg} in order for
the method to be applicable -- they must be the same
object, or numerically equal.

@xref{getMethodSlot}.
@end defun

@c
@node  |applicableMethod?, methodsMatch?, setMethodSlot, low-level MOS functions
@subsection |applicableMethod?
@defun applicableMethod? @{ [args] method -> [args] tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|applicableMethod?} function checks to see if
the given argument block satisfies the given
@code{method}.  It skips checking the first argument,
on the assumption that the @code{method} was
obtained by
using one of the @code{findMosKeyObjectMethod?}
or @code{findMosKeyClassMethod?}
on the first argument.

@end defun

@c
@node  methodsMatch?, mosKeyUnsharedSlotsMatch?, |applicableMethod?, low-level MOS functions
@subsection methodsMatch?
@defun methodsMatch? @{ method1 method2 -> tOrNil order @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{methodsMatch?} function returns
a @code{nil} @code{tOrNil} value if
the two methods differ in number of required
arguments, or if they have generic functions.

Otherwise, it returns @code{t} for @code{tOrNil}
and returns @code{-1} for @code{order} if
@code{method1} is more specific, @code{0} if they have
identical signatures, @code{1} if @code{method1} is
less specific, and @code{nil} if they are unordered
(for example, @code{:eql 1} vs @code{:eql 'a'}).

@end defun

@c
@node  mosKeyUnsharedSlotsMatch?, copyMosKeySlot, methodsMatch?, low-level MOS functions
@subsection mosKeyUnsharedSlotsMatch?
@defun mosKeyUnsharedSlotsMatch? @{ key1 key2 -> tOrNil @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{mosKeyUnsharedSlotsMatch?} function returns
a @code{nil} @code{tOrNil} value unless
the two mosKey instances are semantically equivalent
with regard to shared slots.

At present, this means that they must have the same
number of shared slots, and must have the same
slot property values for those slots excepting
for the @code{:documentation}, @code{:getFunction}
and @code{:setFunction} properties.

@end defun

@c
@node  copyMosKeySlot, mosPredenceList[, mosKeyUnsharedSlotsMatch?, low-level MOS functions
@subsection copyMosKeySlot
@defun copyMosKeySlot @{ dst-key dst-slot src-key src-slot -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{copyMosKeySlot} function copies
the contents of one slot description between
two instances of class mosKey.  This saves
having to individually copy all the slot
properties such as @code{:classMayWrite}.

@end defun


@c
@node  mosPredenceList[, |applyLambdaList, copyMosKeySlot, low-level MOS functions
@subsection mosPredenceList[
@defun mosPredenceList[ @{ mosKey -> [classes] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{mosPredenceList[} function is a
specialized @code{]defclass} support function that accepts an
instance of class MosKey and returns a block
containing the precedence list for that MosKey -- the
contents of the @code{ancestor} slots, which are
normally read and written using
@code{getMosKeyAncestor} and
@code{setMosKeyAncestor}.

@xref{getMosKeyAncestor}.
@xref{setMosKeyAncestor}.
@xref{]defclass}.



@end defun


@c
@node  |applyLambdaList, low-level MOS wrapup, mosPredenceList[, low-level MOS functions
@subsection |applyLambdaList
@defun |applyLambdaList @{ [raw-args] lambda -> [cooked-args] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|applyLambdaList} function is the
central mechanism for processing a lispStyle
argument block at runtime.  The @code{[raw-args]}
block should contain a lisp parameter block as
supplied by the calling function: Required
arguments followed by any optional arguments
followed by any key/val pairs.  The resulting
@code{[cooked-args]} block is a fixed-length
block with one entry for each possible argument,
where default values have been supplied for
missing optional or keyword arguments.

After calling @code{|applyLambdaList} one will
typically call @code{]setLocalVars} to copy the
results into local variables.  @xref{]setLocalVars}.

@end defun


@c
@node  low-level MOS wrapup, low-level btree functions, |applyLambdaList, low-level MOS functions
@subsection low-level MOS wrapup


@c
@node low-level btree functions, low-level btree overview, low-level MOS wrapup, Core Muf
@section low-level MOS functions
@cindex Low-level MOS functions

Low level btree functions used to store key-value
pairs on native Muq objects.

Note:  These functions have currently been dropped from the server due
to technical problems:  It is difficult to ensure that the btree and
the parent object stay in the same dbfile.  There doesn't seem a strong
reason to work on this since you can always use Hash or Index
objects to achieve much the same thing with slightly more overhead.
If you come across a good reason to revive these functions, let me
know and I'll look into it.

@menu
* low-level btree overview::
* makeHashedBtree::
* makeSortedBtree::
* btreeGet::
* btreeSet::
* btreeDelete::
* btreeFirst::
* btreeNext::
* copyBtree::
* low-level btree wrapup::
@end menu

@c
@node  low-level btree overview, makeHashedBtree, low-level btree functions, low-level btree functions
@subsection low-level btree overview

When you do something like
@example
Stack:
makeHash --> myHash
Stack:
12.3 --> myHash["mass"]
Stack:
44.3 --> myHash["weight"]
@end example 
@noindent
Muq stores the properties on @code{myIndex} in a @strong{btree}, a
standard computer data structure capable of handling anything
from a handful of values to millions of values with reasonable
efficiency.

The following functions provide low-level access to the in-server
functions which build and access these btrees.

Most users will never have any reason to use them directly: The standard
high-level interface via objects is sufficient.  Such users have no
reason to read this section: Just use @code{makeHash} to create an
object with key-val pairs stored in a hashed btree (accessible via
@code{obj[key]}) or @code{makeIndex} to create an object with
key-val pairs stored in a sorted btree (again accessible via
@code{obj[key]}).

@xref{makeHash}.
@xref{makeIndex}.

Occasionally, however, it may prove useful to use disembodied btrees
without associated parent objects, or to build similar btree
functionality into other classes of objects:  The following functions
provide the low-level access to the in-server btree functionality
needed in such cases.

@c
@node  makeHashedBtree, makeSortedBtree, low-level btree overview, low-level btree functions
@subsection makeHashedBtree
@defun makeHashedBtree @{ -> nullHashedBtree @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeHashedBtree} function constructs and
returns a new @code{nullHashedBtree} instance.  This is
an immediate value (it takes no space beyond the
return slot itself).

All the other btree functions operate equally well on
hashed or sorted btrees.

Hashed btrees can often be faster than sorted btrees, because they do
all interior comparisons on hashes of keys, rather than the keys
themselves: If the keys are long strings, say, comparing integer hash
values can be much faster than comparing the string keys themselves.

On the other hand, hashed btrees require three values per key-val pair
in the leaf, meaning that big trees may take 50% more space, and when
you iterate over them, the keys will appear in an arbitrary order
dictated by the hash function.  If your keys are small immediate values
anyhow anyhow (integers of 62 bits or less, or strings of seven bytes or
less), a hashed tree won't buy you anything, and you might as well use a
sorted tree.

@xref{makeSortedBtree}.

@end defun


@c
@node  makeSortedBtree, btreeGet, makeHashedBtree, low-level btree functions
@subsection makeSortedBtree
@defun makeSortedBtree @{ -> nullSortedBtree @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{makeSortedBtree} function constructs and
returns a new @code{nullSortedBtree} instance.  This is
an immediate value (it takes no space beyond the
return slot itself).

All the other btree functions operate equally well on
hashed or sorted btrees.

Sorted trees are preferred if you need to be able to iterate over the
keys in a sensible order, or if your keys are small immediate values
such as integers of 62 bits or less.

Hashed trees are preferred if you want efficient lookup on keys
which are expensive to compare, such as long strings.

@xref{makeHashedBtree}.

@end defun


@c
@node  btreeGet, btreeSet, makeSortedBtree, low-level btree functions
@subsection btreeGet
@defun btreeGet @{ btree key -> tOrNil val @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{btreeGet} function searches the given @code{btree} for a value
corresponding to @code{key}.  If found, it is returned as @code{val} and
@code{tOrNil} will be non-@code{nil}, else both will be @code{nil}.

@end defun

@c
@node  btreeSet, btreeDelete, btreeGet, low-level btree functions
@subsection btreeSet
@defun btreeSet @{ btree key val -> newbtree @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function adds the given @code{key val} pair to the given
@code{btree}, and returns the resulting @code{newbtree}, which may or
may not be the same as the given @code{btree}, depending on whether the
root node had to split (or the btree was initially empty).

(Keeping track of changing values of btree is the price one pays for
working with the low level routines instead of having an object
keep track of it for you.)

@end defun

@c
@node  btreeDelete, btreeFirst, btreeSet, low-level btree functions
@subsection btreeDelete
@defun btreeDelete @{ btree key -> newBtree @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function removes the given @code{key} (and any associated
value) from the given @code{btree} and returns the resulting
new @code{newBtree}, which might or might not be the same object
as the given @code{btree}.

@end defun

@c
@node  btreeFirst, btreeNext, btreeDelete, low-level btree functions
@subsection btreeFirst
@defun btreeFirst @{ btree -> tOrNil key @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function returns 'first' key in btree if possible, else both
return values will be @code{nil}.

Note that 'first' is relative to an arbitrary hashing order, not
to any generally interesting sort order!  If you want sorted
results, you'll have to do that yourself.

@xref{|sort}.

@end defun

@c
@node  btreeNext, copyBtree, btreeFirst, low-level btree functions
@subsection btreeNext
@defun btreeNext @{ btree key -> tOrNil nextKey @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

This function returns the 'next' key in the given tree tree if possible,
else both return values will be @code{nil}.

Again, note that the 'next' ordering is relative to an arbitrary hash,
not relative to any interesting ordering.

@end defun

@c
@node  copyBtree, low-level btree wrapup, btreeNext, low-level btree functions
@subsection copyBtree
@defun copyBtree @{ btree -> newBtree @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

Copies all the internal and leaf nodes of the given @code{btree} and
returns the resulting @code{newBtree}:  The result is a tree which
contains the same key-val pairs as the original, but which can be
modified without affecting the original.  No keys or values are
copied.

This operation is currently done inserver, hence can lock up the server
for an arbitrary length of time until the operation completes: This is a
bug, the fn should be recoded in-db at some point.

@end defun

@c
@node  low-level btree wrapup, symbol functions, copyBtree, low-level btree functions
@subsection low-level btree wrapup

Muq btrees are a fairly stock implementation, except that nonleafl key
comparisons are done on hashes of the key values rather than the key
values directly, which may speed access in some cases, such as perhaps
when the keys are long strings with a common prefix.

Currently, internal nodes contain about 10-20 children, with leaf nodes
containing about 7-15 key-val pairs: Searching is linear within both
kinds of nodes.  (Linear unsorted lists are usually the fastest
algorithm for list lengths less than about 8-16.)

This means that for very small btrees, insertion and deletion
performance is close to that of unsorted lists, typically requiring no
storage allocation or garbage collection, while for very large btrees,
efficiency is close to that usually achieved in databases: A btree with
a million entries will be only three levels deep.



@c
@node symbol functions, symbolFunction, low-level btree wrapup, Core Muf
@section symbol functions
@cindex Symbol functions

@menu
* symbolFunction::
* setSymbolFunction::
* symbolName::
* symbolPlist::
* setSymbolPlist::
* symbolType::
* setSymbolType::
* symbolValue::
* setSymbolValue::
* unbindSymbol::
@end menu

@c
@node  symbolFunction, setSymbolFunction, symbol functions, symbol functions
@subsection symbolFunction
@defun symbolFunction
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{symbolFunction} function accepts a symbol, and returns
the function slot of that symbol.  Compilers normally invoke
this implicitly as needed:  It is not normally explicitly
invoked by the programmer.

On occasions when you do need it, the shorthand syntax

@example
#'function
@end example

@noindent
may be used instead of

@example
'function symbolFunction
@end example
@end defun


@c
@node  setSymbolFunction, symbolName, symbolFunction, symbol functions
@subsection setSymbolFunction
@defun setSymbolFunction @{ fn sym -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setSymbolFunction} function accepts a symbol
atop a value, and sets the given symbol's function slot to
the given value.  Compilers normally invoke this implicitly
as needed: It is not normally explicitly invoked by the
programmer.

On occasions when you do need it, the shorthand syntax

@example
fn --> #'function
@end example

@noindent
may be used instead of

@example
fn 'symbol setSymbolFunction
@end example
@end defun


@c
@node  symbolName, symbolPlist, setSymbolFunction, symbol functions
@subsection symbolName
@defun symbolName
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{symbolName} function accepts a symbol, and returns
the name slot of that symbol.

@example
Stack:
"abc" intern
Stack: 'abc
symbolName
Stack: "abc"
@end example
@end defun


@c
@node  symbolPlist, setSymbolPlist, symbolName, symbol functions
@subsection symbolPlist
@defun symbolPlist
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{symbolPlist} function accepts a symbol, and returns
the "proplist" slot of that symbol.

Property lists are lists of the form

@example
key0 val0 key1 val1 @dots{}
@end example

The primeval @sc{mit} Lisp had only cons cells and symbols
with properties, so essentially all information had to be
stored as properties on symbols.  Both Muq and modern Lisps
have much richer sets of data types, and use property lists
much less.

In Muq, it is generally better to use keyval pairs on
objects than property lists on symbols.

@xref{putprop}. @xref{setSymbolPlist}.
@end defun


@c
@node  setSymbolPlist, symbolType, symbolPlist, symbol functions
@subsection setSymbolPlist
@defun setSymbolPlist @{ plist sym -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setSymbolPlist} function accepts a symbol atop a
value, and sets the given symbol's "proplist" field to the
given value.

@xref{setSymbolPlist}.  @xref{putprop}. 
@end defun


@c
@node  symbolType, setSymbolType, setSymbolPlist, symbol functions
@subsection symbolType
@defun symbolType @{ symbol -> type @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{symbolType} function accepts a symbol, and returns
the "type" slot of that symbol.

@xref{setSymbolType}.
@end defun


@c
@node  setSymbolType, symbolValue, symbolType, symbol functions
@subsection setSymbolType
@defun setSymbolPlist @{ type sym -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setSymbolType} function accepts a symbol atop a
type expression, and sets the given symbol's "type" field to the
given type.

@xref{symbolType}.
@end defun


@c
@node  symbolValue, setSymbolValue, setSymbolType, symbol functions
@subsection symbolValue
@defun symbolValue
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{symbolValue} function accepts a symbol, and returns
the value slot of that symbol.  Compilers normally invoke
this implicitly as needed:  It is not normally explicitly
invoked by the programmer.
@end defun


@c
@node  setSymbolValue, unbindSymbol, symbolValue, symbol functions
@subsection setSymbolValue
@defun setSymbolValue
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{setSymbolValue} function accepts a symbol atop a
value, and sets the given symbol's value field to the given
value.  Compilers normally invoke this implicitly as needed:
It is not normally explicitly invoked by the programmer.
@end defun


@c
@node  unbindSymbol, sysadmin functions, setSymbolValue, symbol functions
@subsection unbindSymbol
@findex makunbound
@defun unbindSymbol @{ symbol -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{unbindSymbol} function accepts a symbol,
and sets it to have no value.  Freshly created
symbols have no value until they are assigned one:
This function is the only way of restoring a symbol
to the original value-less event.

This is equivalent to the CommonLisp @code{makunbound}
function.
@end defun


@c
@node sysadmin functions, sysadmin overview, unbindSymbol, Core Muf
@section sysadmin functions
@cindex Sysadmin functions

@menu
* sysadmin overview::
* rootCollectGarbage::
* rootDoBckup::
* rootMakeDbfile::
* rootMakeGuest::
* rootMakeUser::
* rootMakeAUser::
* rootAddUser::
* rootAcceptLogins::
* rootAcceptLoginsOn::
* rootBecomeUser::
* sysadmin wrapup::
@end menu

@c
@node  sysadmin overview, rootCollectGarbage, sysadmin functions, sysadmin functions
@subsection sysadmin overview

This section gathers together reference material on
functions of interest primarily to Muq system
administrators: Those responsible for adding new users,
maintaining core shared facilities and so forth.


@c
@node  rootCollectGarbage, rootDoBckup, sysadmin overview, sysadmin functions
@subsection rootCollectGarbage
@defun rootCollectGarbage @{ -> string-summary @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: temporary
@end display

This function does a monolithic mark-and-sweep garbage
collection.  The server stops until garbage collection is
complete.  I'd like to think that this function is a
temporary kludge which will be removed in a future release.

Garbage collection is performed automatically as needed, so
the usual reason to invoke this function is just to get the
return value.  It may occasionally make sense to invoke it
if you know you just freed up a lot of storage.

The return value is a human-readable string summarizing
garbage collection results.
@end defun


@c
@node  rootDoBckup, rootMakeDbfile, rootCollectGarbage, sysadmin functions
@subsection rootDoBckup
@defun rootDoBckup @{ -> @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: temporary
@end display

This function does a monolithic backup of the entire db.
The server stops until backup is
complete.  I'd like to think that this function is a
temporary kludge which will be removed in a future release.

You may find it easier and more reliable to use the
inserver support for periodic backups rather than
the @code{rootDoBckup} function: Just set the

@example
.muq$s.dateOfNextBackup
.muq$s.millisecsBetweenBackups
@end example

@noindent
to nonzero values (the default) and the server will do
the rest.

Conversely, if you wish precise control of backup timing,
you may wish to zero the above two properties and call
@code{rootDoBckup} exactly when you want backups done.

Also relevant is the

@example
.muq$s.maxDbCopiesToKeep
@end example

@noindent
property.

@end defun


@c
@node  rootMakeDbfile, rootMakeGuest, rootDoBckup, sysadmin functions
@subsection rootMakeDbfile
@defun rootMakeDbfile  @{ proposedName -> finalName @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rootMakeDbfile} function creates and returns a new
instance of Class DatabaseFile.  Since each such instance
is associated with a section of the database stored in
a host file, as a side-effect a host file will be created.

The @code{proposedName} argument may be an integer;  only
the lowest twenty-one bits will be used.  The high bit
distinguishes system library from personal dbfiles.

The @code{proposedName} argument may also be a text
string of four letters.  Lower-case letters are used
for personal dbfiles, uppercase letters are used
for system files.

In either of the above cases, if the @code{proposedName}
is inappropriate (too long, say), it will be modified
appropriately, and if it conflicts with the name of
an existing dbfile, it will be incremented until there
is no conflict.

Finally, the @code{proposedName} argument may be @code{nil},
in which case an unused dbname is assigned randomly.

The name actually used is returned as @code{finalName}.

An entry 
@code{.db[finalName]} is made containing the actual
dbfile instance created.

You will normally next create one or more packages
in the new dbfile by including the dbfile object
as the final argument to @code{]makePackage}.
@xref{]makePackage}.

If you want the new dbfile to be the home for a
new user, you should create them together
using @code{rootMakeUser}.
@xref{rootMakeUser}.

@end defun


@c
@node  rootMakeGuest, rootMakeUser, rootMakeDbfile, sysadmin functions
@subsection rootMakeGuest   @{ [ | -> [ guest | @}
@defun rootMakeGuest
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rootMakeGuest} function creates and returns a new
instance of Class Guest.  (Guest is structurally identical
to User, but represents users on remote Muq servers.)

@end defun


@c
@node  rootMakeUser, rootMakeAUser, rootMakeGuest, sysadmin functions
@subsection rootMakeUser  @{ [ proposedDbfileName | -> [ user | @}
@defun rootMakeUser
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rootMakeUser} function creates and returns a new
instance of Class User.  This instance owns (only) itself.
A new dbfile is created for the new user:
the name of the new dbfile is as close to  @code{proposedDbfileName}
as practical.

In the interests of keeping the C-coded kernel as
policy-free as possible, @code{rootMakeUser} does nothing
beyond the above.  However, in the interest of sanity, it is
recommended that:

@enumerate
@item
A User instance be created only after
prompting for a name and passphrase and verifying that the
name is not present in @code{.u}.

@item
The new User's name and passphrase should be set immediately.

@item
The new User instance be immediately entered into .u under
its name.
@end enumerate

If several jobs may be entering new users, a lock should
of course be used to protect @code{.u}.  @xref{withLockDo}.

Newly created User objects default to having @code{.lib} as
their library of packages (@code{user$s.lib}), and
@code{.lib.muf} as their default package
(@code{usr$s.package}).  Since they won't own either, they
won't be able to create symbols in their accessable packages
nor create new packages: You will normally want to create a
new object as their @code{usr$s.lib}, copy into it the
system packages you feel to be appropriate, and most likely
also create them a personal package which they own (probably
giving it their login name as a name) and point their
@code{user$s.package} to it.

A higher level wrapper function exists to do much of
this work:  @xref{rootMakeAUser}.

@end defun


@c
@node  rootMakeAUser, rootAddUser, rootMakeUser, sysadmin functions
@subsection rootMakeAUser
@defun rootMakeAUser @{ name -> @}
@display
@exdent file: muf/10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rootMakeAUser} function (a wrapper around the
lower level @code{rootMakeUser} function) creates a new
user of the specified name and enters it into to the
@code{.u} directory.  (For an interactive wrapper around
@code{rootMakeAUser} itself, @xref{rootAddUser}.)

If there is a pre-existing user in @code{.u} with the given
name, an error message is issued and no new user is created.

A @code{user$s.lib} is created for the new user, and all
packages in @code{.lib} copied into it.  In addition, a new
package owned by (and named after) the user is created,
entered into @code{user$s.lib}, and @code{user$s.defaultPackage}
set to it: This is the package the user will be "in"
immediately after logging on.

Finally, @code{user$s.name} is set to the given name, and
@code{user$s.shell} set to @code{muf:oldMufShell}, the default
@sc{muf} shell.

After calling @code{rootMakeAUser}, you will frequently
wish to set @code{user$s.shell} to something more
appropriate, and also set @code{user$a.encryptedPassphrase}
via something like

@example
[ 'f' 'f' 'm' 'y' 'p' 'w' | |secureHash ]join --> .u["pat"]$a.encryptedPassphrase
@end example

@xref{rootAddUser}.
@xref{rootBecomeUser}.
@xref{rootMakeUser}.
@xref{|secureHash}.
@end defun


@c
@node  rootAddUser, rootAcceptLogins, rootMakeAUser, sysadmin functions
@subsection rootAddUser
@defun rootAddUser @{ -> @}
@display
@exdent file: muf/10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rootAddUser} function is an interactive
convenience function which prompts for the name and
passphrase of a new user, checks that no user by that
name already exists in @code{.u}, and then creates
the requested user.

The new user's shell is the muf shell: If this is
not what you want, you may afterwards set
@code{.u["username"]$s.shell} to some other
suitable function.

@xref{rootAddUser}.
@xref{rootBecomeUser}.
@xref{rootMakeUser}.
@xref{rootMakeAUser}.
@xref{|secureHash}.
@end defun


@c
@node  rootAcceptLogins, rootAcceptLoginsOn, rootAddUser, sysadmin functions
@subsection rootAcceptLogins
@defun rootAcceptLogins @{ -> @}
@display
@exdent file: muf/10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{rootAcceptLogins} function is the
usual way to start up "multi-user" mode on a
Muq server.  It is currently implemented as:

@example
:   rootAcceptLogins @{ -> @}
    30023 rootAcceptLoginsOn
;
@end example

@xref{rootAcceptLoginsOn}.
@end defun

@c
@node  rootAcceptLoginsOn, rootBecomeUser, rootAcceptLogins, sysadmin functions
@subsection rootAcceptLoginsOn
@defun rootAcceptLoginsOn @{ port -> @}
@display
@exdent file: muf/10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This is the normal way of starting up "mult-user"
mode on a Muq server.

The @code{rootAcceptLoginsOn} function starts
up a process listening on the specified port,
which prompts all connections for a name and
passphrase.  If @code{.u["name"]} exists for
the given name, and if @code{.u["name"]$s.encryptedPassphrase}
matches the encryption of the entered passphrase,
a fresh session is forked for the connection and
the function @code{.u["name"]$s.shell} is
invoked via @code{]exec}.

The usual port is @code{30023};  A convenience
function is provided to save you typing this
port number if you wish: 
@xref{rootAcceptLogins}.
@end defun


@c
@node  rootBecomeUser, sysadmin wrapup, rootAcceptLoginsOn, sysadmin functions
@subsection rootBecomeUser
@defun rootBecomeUser @{ user -> @@ @}
@display
@exdent file: muf/10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

A utility function for logging in a new user
after passphrase validation, which switches the
job from running as a root thread to running
as a user session -- it forks off a new session,
sets up new input/output streams, and execs the
user's shell.
@end defun


@c
@node  sysadmin wrapup, telnet functions, rootBecomeUser, sysadmin functions
@subsection symbolFunction
@defun symbolFunction
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{symbolFunction} function accepts a symbol, and returns
the function slot of that symbol.  Compilers normally invoke
this implicitly as needed:  It is not normally explicitly
invoked by the programmer.

On occasions when you do need it, the shorthand syntax

@example
#'function
@end example

@noindent
may be used instead of

@example
'function symbolFunction
@end example
@end defun


@c
@node telnet functions, telnet overview, sysadmin wrapup, Core Muf
@section sysadmin functions
@cindex Sysadmin functions

@menu
* telnet overview::
* telnet start::
* telnet stop::
* maybeStartTelnetDaemon::
* dontEcho::
* doEcho::
* willEcho::
* wontEcho::
* wantWontTelnetSocketOption::
* wantWillTelnetSocketOption::
* wantDontTelnetSocketOption::
* wantDoTelnetSocketOption::
* ]unsupportedOptionHandler::
* ]supportedOptionHandler::
* telnet wrapup::
@end menu

@c
@node  telnet overview, telnet start, telnet functions, telnet functions
@subsection sysadmin overview

The @sc{telnet} protocol is designed to allow client
and server programs to whisper back and forth without
distrupting user I/O on the connection, by using
special escape sequences flagged by an initial
@code{0xFF} byte.

Muq provides in-server support for @code{telnet}
protocol processing primarily in the form of code in
the socket object implementation which can split the
bytestream from the net into two in-db bytestreams, one
carrying vanilla user I/O to the shell, and one
carrying @sc{telnet} protocol commands to a separate
@sc{telnet} daemon implemented in-db in the
@code{telnet} package in @code{07-C-telnet.t}.

The current Muq telnet protocol support is a very rough
first draft: Among other deficiencies, @sc{tcp} urgent
data is not properly supported (meaning telnet commands
may not be communicated in as timely a fashion as they
should) and no options are supported, with the partial
exception of the @sc{echo} option.  All in good time.

@c
@node  telnet start, telnet stop, telnet overview, telnet functions
@subsection telnet start
@defun telnet:start @{ -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This function starts up a job which will handle
telnet protocol processing for the socket of the
current session.  This function is usually stored
in @code{user$S.telnetDaemon} and started up by
a shell via @code{maybeStartTelnetDaemon}.

It is currently implemented as:

@example
: start @{ -> ! @}
    forkJobset not if
        #'run exec
    fi
;
@end example

(See @code{07-C-telnet.t} for the gory details
of @code{run} if you're curious.)

@xref{telnet stop}.

@end defun


@c
@node  telnet stop, maybeStartTelnetDaemon, telnet start, telnet functions
@subsection telnet stop
@defun telnet:stop @{ -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This function shuts down the @code{telnet} daemon
for the current session.

It is currently implemented as:

@example
: stop @{ -> @}

    @@$S.jobSet$S.session$S.socket -> socket

    socket$S.outOfBandJob -> j
    j job? if j abortJob fi

    nil --> socket$S.outOfBandJob
    nil --> socket$S.outOfBandInput
    nil --> socket$S.outOfBandOutput

    nil --> socket$S.telnetProtocol
    nil --> socket$S.thisTelnetState
    nil --> socket$S.thatTelnetState
    nil --> socket$S.telnetOptionHandlers
    nil --> socket$S.telnetOptionLock
;
@end example

@end defun


@c
@node  maybeStartTelnetDaemon, dontEcho, telnet stop, telnet functions
@subsection maybeStartTelnetDaemon
@defun maybeStartTelnetDaemon @{ -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This function is designed to be invoked by a
shell during startup, to start a telnet
daemon running for the current session if
appropriate.

It is currently implemented as:

@example
:   maybeStartTelnetDaemon @{ -> @}

    ( Find our socket: )
    @@$s.jobSet$s.session$s.socket -> socket

    ( We attempt to only run the telnetDaemon )
    ( when there's likely to be telnet support )
    ( on the other end.  In particular, if     )
    ( socket$S.type is :tty we are on a direct )
    ( console connection:                      )
    socket$S.type :tcp = not if return fi
    
    ( Let's not clobber a telnetDaemon which  )
    ( is already running:                      )
    socket$S.telnetOptionLock if return fi

    ( Go for it: )
    me$s.telnetDaemon  -> daemon
    daemon compiledFunction? not if
        #'telnet:start -> daemon
    fi
    daemon compiledFunction? if
	daemon call@{ -> @}
    fi
;
@end example

@end defun


@c
@node  dontEcho, doEcho, maybeStartTelnetDaemon, telnet functions
@subsection dontEcho
@defun dontEcho @{ -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is a convenience function to try negotiating
@sc{DONT ECHO} via our telnet daemon.  It is a
simple wrapper around
@code{]supportedOptionHandler}.

@end defun


@c
@node  doEcho, willEcho, dontEcho, telnet functions
@subsection doEcho
@defun doEcho @{ -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is a convenience function to try negotiating
@sc{DO ECHO} via our telnet daemon.  It is a
simple wrapper around
@code{]supportedOptionHandler}.

@end defun


@c
@node  willEcho, wontEcho, doEcho, telnet functions
@subsection willEcho
@defun willEcho @{ -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is a convenience function to try negotiating
@sc{WILL ECHO} via our telnet daemon.  It is a
simple wrapper around
@code{]supportedOptionHandler}.

This doesn't actually do any echoing, even if
successful, but @emph{does} convince the
telnet client not to echo:  This is currently
how the Muq nanomud login function suppresses
passphrase echoing.

@end defun


@c
@node  wontEcho, wantWontTelnetSocketOption, willEcho, telnet functions
@subsection wontEcho
@defun wontEcho @{ -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is a convenience function to try negotiating
@sc{WONT ECHO} via our telnet daemon.  It is a
simple wrapper around
@code{]supportedOptionHandler}.

@end defun


@c
@node  wantWontTelnetSocketOption, wantWillTelnetSocketOption, wontEcho, telnet functions
@subsection wantWontTelnetSocketOption
@defun wantWontTelnetSocketOption @{ socket code -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is a generic function which tries negotiating @sc{wont}
for a given integer @code{code} on a given
@code{socket}:  It is a wrapper for @code{]supportedOptionHandler}.

@end defun


@c
@node  wantWillTelnetSocketOption, wantDontTelnetSocketOption, wantWontTelnetSocketOption, telnet functions
@subsection wantWillTelnetSocketOption
@defun wantWillTelnetSocketOption @{ socket code -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is a generic function which tries negotiating @sc{will}
for a given integer @code{code} on a given
@code{socket}:  It is a wrapper for @code{]supportedOptionHandler}.

@end defun


@c
@node  wantDontTelnetSocketOption, wantDoTelnetSocketOption, wantWillTelnetSocketOption, telnet functions
@subsection wantDontTelnetSocketOption
@defun wantDontTelnetSocketOption @{ socket code -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is a generic function which tries negotiating @sc{dont}
for a given integer @code{code} on a given
@code{socket}:  It is a wrapper for @code{]supportedOptionHandler}.

@end defun


@c
@node  wantDoTelnetSocketOption, ]unsupportedOptionHandler, wantDontTelnetSocketOption, telnet functions
@subsection wantDoTelnetSocketOption
@defun wantDoTelnetSocketOption @{ socket code -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is a generic function which tries negotiating @sc{do}
for a given integer @code{code} on a given
@code{socket}:  It is a wrapper for @code{]supportedOptionHandler}.

@end defun


@c
@node  ]unsupportedOptionHandler, ]supportedOptionHandler, wantDoTelnetSocketOption, telnet functions
@subsection ]unsupportedOptionHandler
@defun ]unsupportedOptionHandler @{ [] stream this that code op -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is the generic function used to handle negotiations
for options not supported at the Muq end:  You can
disable support for option N by doing

@example
@@$s.jobSet$S.session$s.socket$s.telnetOptionHandler --> handler
#']unsupportedOptionHandler --> handler[n]
@end example

It is currently implemented as:

@example
:   ]unsupportedOptionHandler @{ [] $ $ $ $ $ -> @}

    -> op        ( One of will wont do dont suboptionBegin )
    -> code      ( Integer, 0-255                           )
    -> that      ( 256-byte state-* string                  )
    -> this      ( 256-byte state-* string                  )
    -> oobInput ( Message stream for replies               )
    ]pop

    ( This is the handler called for unsupported options. )
    ( We always refuse DO and WILL, and always ignore     )
    ( everything else:                                    )
    op case@{
    on: will              oobInput code sendDont
    on: do	          oobInput code sendWont
    on: wont              ( Ignored. )
    on: dont              ( Ignored. )
    on: wantWont         ( Ignored. )
    on: wantDont         ( Ignored. )
    on: wantDo           ( Ignored. )
    on: wantDont         ( Ignored. )
    on: suboptionBegin	  ( Ignored. )
    @}
;
@end example

@end defun


@c
@node  ]supportedOptionHandler, telnet wrapup, ]unsupportedOptionHandler, telnet functions
@subsection ]supportedOptionHandler
@defun ]supportedOptionHandler @{ [] stream this that code op -> @}
@display
@exdent file: 07-C-telnet.t
@exdent package: telnet
@exdent status: alpha
@end display

This is the generic function used to handle negotiations
for options supported at the Muq end:  You can
enable negotiation for option N by doing

@example
@@$s.jobSet$S.session$s.socket$s.telnetOptionHandler --> handler
#']supportedOptionHandler --> handler[n]
@end example

This won't actually implement the option, of course,
just enable negotiations as though it were -- it merely
implements the Q state machine described in @sc{rfc1143}.

You may wish to implement telnet protocol options by
installing in @code{telnetOptionHandler[n]} a
function which implements the option-specific
semantics while delegating the negotiation details
to @code{]supportedOptionHandler}.

@end defun


@c
@node  telnet wrapup, user i/o functions, ]supportedOptionHandler, telnet functions
@subsection telnet wrapup

It will be awhile before I manage to fit implementation
of the complete @sc{telnet} protocol option suite into
my Muq development schedule: Let me know if there is
any specific facility you need.


@c
@node user i/o functions, user i/o overview, telnet wrapup, Core Muf
@section user i/o functions
@cindex User I/O functions

@menu
* user i/o overview::
* queryForFloat::
* queryForInt::
* queryForString::
* ]queryForChoice::
* user i/o wrapup::
@end menu

@c
@node  user i/o overview, queryForFloat, user i/o functions, user i/o functions
@subsection user i/o overview

These functions facilitate interaction with the user.
We will eventually need a fairly sophisticated mechanism
divorcing what is presented from how to present it;  For
now, we provide only a few essential low-level functions.

My past experience has indicated that the ability to compose
a display out of the following four basic classes of widgets
is sufficient to build simple but effective interfaces:

@enumerate
@item
Widget to allow text string entry.

@item
Widget to allow control of bounded integer variable.

@item
Widget to allow control of bounded float variable.

@item
Widget to allow selection of one of N strings.
@end enumerate

Additional specialized widgets, such as to allow selection
of a color from a color from a saturation hue intensity
colorspace, can certainly be welcome on occasion, but the
above four seem to suffice in general.

Thus first four functions in this section implement
these abilities in a form appropriate for use in
an @code{:interactiveFunction} for a @code{restart}.
(@xref{withRestartDo}.)

@c
@node  queryForFloat, queryForInt, user i/o overview, user i/o functions
@subsection queryForFloat
@defun queryForFloat @{ what min was max -> result @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function prompts the user for a float value via
@code{@@$s.queryOutput} and then reads it via
@code{@@$s.queryInput}.  It loops until
it obtains a value greater than or equal to
@code{min} and less than or equal to @code{max}
and then returns that value.

It is currently implemented as:

@example
: queryForFloat @{ $ $ $ $ -> $ @}   -> max -> was -> min -> what
    was min >= if
        [ "The '%s' was %g.\n" what was
        | ]print @@$s.queryOutput writeStream
    fi
    do@{
        [ "Please enter new float value for '%s':\n" what
        | ]print @@$s.queryOutput writeStream

        @@$s.queryInput readStreamLine pop trimString -> string
        string "%f" unprint[ |pop -> result ]pop

        result min < if
            [ "Sorry, the '%s' must be at least %g.\n" what min
            | ]print @@$s.queryOutput writeStream
            continue    
        fi

        result max > if
            [ "Sorry, the '%s' must be at most %g.\n" what max
            | ]print @@$s.queryOutput writeStream
            continue    
        fi

        result return
    @}
;
'queryForFloat export
@end example
@end defun


@c
@node  queryForInt, queryForString, queryForFloat, user i/o functions
@subsection queryForInt
@defun queryForInt @{ what min was max -> result @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function prompts the user for an integer value via
@code{@@$s.queryOutput} and then reads it via
@code{@@$s.queryInput}.  It loops until
it obtains a value greater than or equal to
@code{min} and strictly less than @code{max}
and then returns that value.

It is currently implemented as:

@example
: queryForInt @{ $ $ $ $ -> $ @}   -> max -> was -> min -> what
    was min >= if
        [ "The '%s' was %d\n" what was
    | ]print @@$s.queryOutput writeStream
    fi
    do@{
        [ "Please enter new integer value for '%s':\n" what
        | ]print @@$s.queryOutput writeStream

        @@$s.queryInput readStreamLine pop trimString -> string
        string stringInt -> result

        result min < if
            [ "Sorry, the '%s' must be at least %d\n" what min
            | ]print @@$s.queryOutput writeStream
            continue    
        fi

        result max >= if
            [ "Sorry, the '%s' must be less than %d\n" what max
            | ]print @@$s.queryOutput writeStream
            continue    
        fi

        result return
    @}
;
'queryForInt export
@end example
@end defun


@c
@node  queryForString, ]queryForChoice, queryForInt, user i/o functions
@subsection queryForString
@defun queryForInt @{ what was -> result @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function prompts the user for a string value via
@code{@@$s.queryOutput} and then reads it via
@code{@@$s.queryInput}.  It loops until
it obtains a nonempty string (after stripping
leading and trailing whitespace)
and then returns that value.

It is currently implemented as:

@example
: queryForString @{ $ $ -> $ @}   -> was -> what 
    was length 0 > if
        [ "The '%s' was '%s'.\n" what was
        | ]print @@$s.queryOutput writeStream
    fi
    do@{
        [ "Please enter new string value for '%s'.\n" what
        | ]print @@$s.queryOutput writeStream

        @@$s.queryInput readStreamLine pop trimString -> result
        result length 0 > if result return fi

        [ "Sorry, the '%s' value must not be blank.\n" what
        | ]print @@$s.queryOutput writeStream
    @}
;
'queryForString export
@end example
@end defun


@c
@node  ]queryForChoice, user i/o wrapup, queryForString, user i/o functions
@subsection ]queryForChoice
@defun ]queryForChoice @{ what was -> result @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function prompts the user to select one of a given
set (block) of strings. It loops until the user enters
the number of a valid string, then returns both the
selected string and its offset within the block (zero
to n-1).

Note that it may easily be adapted to select from
a set of nonstring values:

@example
[ "Pat" "Kim" | "Pick mate" ]queryForChoice pop -> choice
[ .u.pat .u.kim | choice dupNth -> choice ]pop
choice
@end example

@noindent
will return one of @code{.u.pat} or @code{.u.kim}.

It is currently implemented as:

@example
: ]queryForChoice @{ [] $ -> $ $ @} -> prompt
    |length -> len
    do@{
        prompt length 0 = if
          "\nPick one:\n" @@$s.queryOutput writeStream
            "---------\n" @@$s.queryOutput writeStream
        else
            [ "\n%s:\n" prompt | ]print @@$s.queryOutput writeStream
        fi

        0 -> i
       |for choice do@{
            i 1 + -> i      

            [ "%d) %s\n" i choice
            | ]print @@$s.queryOutput writeStream
        @}

        @@$s.queryInput readStreamLine pop trimString -> string
        string stringInt 1 - -> result

        result 0 <= if
            "Sorry, choice must be at least 1\n"
            @@$s.queryOutput writeStream
            continue
        fi

        result len >= if
            [ "Sorry, choice must be at most %d\n" len
            | ]print  @@$s.queryOutput writeStream
            continue
        fi

        result |dupNth -> resultString
        ]pop
        result resultString return
    @}
;
']queryForChoice export
@end example
@end defun


@c
@node  user i/o wrapup, graphics functions, ]queryForChoice, user i/o functions
@subsection user i/o wrapup

Eventually, I would like to see a toolkit which allows an
application package to export an abstract interface
specifying things like "a parameter named 'speed' is
available which may be varied from 0.0 to 1600.0, with help
available as 'http://here/speed.html'", and then separate
interface packages while provide various commandline,
text-menu and graphical presentations of these interfaces.

(I feel strongly that Muq applications should not be
hardwired to present one particular end-user interface.
Content and presentation should be firmly separated.)

Anyone want to work up a proposal, or know of good
existing prior art in this area?

@c
@node graphics functions, graphics functions overview, user i/o wrapup, Core Muf
@section graphics functions
@cindex Graphics functions

@menu
* graphics functions overview::
* bias::
* clamp::
* crossProduct::
* distance::
* dotProduct::
* fBm::
* gain::
* gammacorrect::
* gnoise::
* magnitude::
* mix::
* normalize::
* rayHitsSphereAt::
* smoothstep::
* spline::
* step::
* turbulence::
* vcnoise::
* vnoise::
* graphics functions wrapup::
@end menu

@c
@node  graphics functions overview, bias, graphics functions, graphics functions
@subsection graphics functions overview

Virtually all of the standard OpenGL and GLUT calls are available:
There are several hundred of them which are well documented elsewhere,
so I won't document them here.  (If anyone wants to volunteer to write
up Muq docs for them, that would be great!)  See the "Blue Book"
(OpenGL Reference Manual) and "Green Book" (OpenGL Programming for
the X Window System, Mark J Kilgard).

Documented here are some additional functions not in the OpenGL API.
They don't actually do graphics in the sense of drawing anything,
but they were invented by graphics programmers and are mostly used
in graphics contexts.

@c
@node  bias, clamp, graphics functions overview, graphics functions
@subsection bias
@defun bias @{ b x -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

An alternative to @code{gammacorrect}.

@code{Result = pow( x, log(b)/log(0.5) );}

@end defun

@c
@node  clamp, crossProduct, bias, graphics functions
@subsection clamp
@defun clamp @{ a b x -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Clamps @code{x} to be between @code{a} and @code{b}.

@code{ Result = (x < a ? a : (x > b ? b : x ))}


@end defun

@c
@node  crossProduct, distance, clamp, graphics functions
@subsection crossProduct
@defun clamp @{ a b -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{crossProduct} function accepts two length-3
32-bit float vectors, and returns their cross product.

The cross product is a vector with direction perpendicular to both of
the input vectors, and with magnitude equal to the area of the
parallelogram defined by the two input vectors.

@end defun

@c
@node  distance, dotProduct, crossProduct, graphics functions
@subsection distance
@defun distance @{ a b -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{distance} function accepts two length-3
32-bit float vectors representing points, and returns the
Euclidian distance separating them.

@end defun

@c
@node  dotProduct, fBm, distance, graphics functions
@subsection dotProduct
@defun dotProduct @{ a b -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{dotProduct} function accepts two length-3
32-bit float vectors representing points, and returns their
"dot product": @code{a.x*b.x + a.y*b.y + a.z*b.z}.

@end defun

@c
@node  fBm, gain, dotProduct, graphics functions
@subsection fBm
@defun fBm @{ x y z H lacunarity octaves -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Noise functions map a point in space to a value between -1 and 1.
They are frequently used to create clouds and other irregular
shapes in computer graphics.

The fBM function has more knobs than most and is the granddady
of all noise functions, with analysis and use going back to
Benoit Mandelbrot's introduction of fractals to computer graphics.

The name originally came from "fractal Brownian motion" (I think)
but nowadays everyone just calls it @code{fBm}.

This version is from F. Kenton Musgrave's chapter in Texturing and
Modelling, A Procedural Approach.

See the book or the Muq source for full implementation details.



@end defun

@c
@node  gain, gammacorrect, fBm, graphics functions
@subsection gain
@defun gain @{ g x -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Yet another handy little function for remapping the
unit interval.

@example
if (x < 0.5)    r =       bias( 1.0-g,       2.0*x ) * 0.5;
else            r = 1.0 - bias( 1.0-g, 2.0 - 2.0*x ) * 0.5;
@end example

@end defun

@c
@node  gammacorrect, gnoise, gain, graphics functions
@subsection gammacorrect
@defun gammacorrect @{ gamma x -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

A basic exponential remapping function, often used to
correct image brightness for the nonlinear response
of CRT tubes.

@code{ Result = pow( x, 1.0/gamma ); }

@end defun

@c
@node  gnoise, magnitude, gammacorrect, graphics functions
@subsection gnoise
@defun gnoise @{ x y z -> f @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Noise functions map a point in space to a value between -1 and 1.
They are frequently used to create clouds and other irregular
shapes in computer graphics.

This one is Darwyn Peachey's gradient lattice noise function with
smoothed trilinear interpolation, from his chapter in Texturing and
Modelling, A Procedural Approach.

See the book or the Muq source for full implementation details.


@end defun

@c
@node  magnitude, mix, gnoise, graphics functions
@subsection magnitude
@defun magnitude @{ v -> f @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{magnitude} function accepts a length-3 32-bit float
vector and returns its magnitude, given mathematically
by the formula @code{sqrt( x*x + y*y + z*z )}.  The actual
formula used is a bit more involved to reduce precision problems.

@end defun

@c
@node  mix, normalize, magnitude, graphics functions
@subsection mix
@defun mix @{ a b f -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Mixes @code{a} and @code{b} with @code{f} as a 0-1 knob.

@code{ Result = (1-f)*a + f*b }

@end defun

@c
@node  normalize, rayHitsSphereAt, mix, graphics functions
@subsection normalize
@defun normalize @{ v1 -> v2 @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{normalize} function accepts a length-3 32-bit float
vector and returns a new vector with the same direction but
unit magnitude.

@end defun

@c
@node  rayHitsSphereAt, smoothstep, normalize, graphics functions
@subsection rayHitsSphereAt
@defun rayHitsSphereAt @{ O D S r -> P s @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Basic raytracing primitive:  Given a ray at origin @code{O}
with direction vector @code{D} and a sphere given by center
@code{S} (all length-three vectors) and radius @code{r},
this function returns @code{nil,largevalue} if there was no intersection,
else the point of intersection @code{P} and the parametric ray
coordinate of the intersection, a scalar @code{s}.  (One often
uses @code{s} to check which of several candidate hits is in
fact first on the ray.)


@end defun

@c
@node  smoothstep, spline, rayHitsSphereAt, graphics functions
@subsection smoothstep
@defun smoothstep @{ a b x -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Constructs a function zero below @code{a}, one above @code{b}
and smoothly varying between them.

In the smoothly varying part the computation is:

@code{ x = (x - a) / (b - a); return x*x*(3-2*x); }

@end defun

@c
@node  spline, step, smoothstep, graphics functions
@subsection spline
@defun spline @{ float*knots, float x -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

A basic cubic spline interpolation routine suitable for
constructing smooth curves.  @code{knots} should be
a float vector of length at least four;  @code{x} is
the point at which to  evaluate the spline.

@end defun

@c
@node  step, turbulence, spline, graphics functions
@subsection step
@defun step @{ a x -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Maps @code{x} to a step function according to whether it
is less than @code{a}.

@code{ Result = (float)(x >= a)}

@end defun

@c
@node  turbulence, vcnoise, step, graphics functions
@subsection turbulence
@defun turbulence @{ x y z lo hi -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Turbulence is a noise function which has been creased
by introducing an absolute-value computation: This
turns zero-crossings into discontinuities somewhat
reminiscent of the boundaries between eddys in turbulent
flow.  Turbulence functions are often used for modelling
explosions and such.

@code{lo} is the lowest frequency you want represented,
and @code{hi} is the highest -- there is no point in
exceeding pixel resolution in general.

@end defun

@c
@node  vcnoise, vnoise, turbulence, graphics functions
@subsection vcnoise
@defun vnoise @{ x y z -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Noise functions map a point in space to a value between -1 and 1.
They are frequently used to create clouds and other irregular
shapes in computer graphics.

This one is Darwyn Peachey's lattice convolution noise function with
Catmull-Rom interpolation, from his chapter in Texturing and
Modelling, A Procedural Approach.

See the book or the Muq source for full implementation details.


@end defun

@c
@node  vnoise, graphics functions wrapup, vcnoise, graphics functions
@subsection vnoise
@defun vnoise @{ x y z -> r @}
@display
@exdent file: jobg.t
@exdent package: muf
@exdent status: alpha
@end display

Noise functions map a point in space to a value between -1 and 1.
They are frequently used to create clouds and other irregular
shapes in computer graphics.

This one is Darwyn Peachey's lattice noise function with cubic Catmull-Rom
interpolation, from his chapter in Texturing and Modelling, A
Procedural Approach.

See the book or the Muq source for full implementation details.

@end defun

@c
@node  graphics functions wrapup, x functions, vnoise, graphics functions
@subsection graphics functions wrapup

Anything else we should support inserver?

@c
@node x functions, x overview, graphics functions wrapup, Core Muf
@section x functions
@cindex X Window System functions

@menu
* x overview::
* ]create-gcontext::
* ]create-window::
* ]draw-glyphs::
* ]draw-image-glyphs::
* ]draw-image-glyphs::
* ]make-event-mask::
* ]text-extents::
* close-display::
* destroy-subwindows::
* destroy-window::
* display-roots[::
* drawable-border-width::
* drawable-depth::
* drawable-display::
* drawable-height::
* drawable-width::
* drawable-x::
* drawable-y::
* flush-display::
* font-ascent::
* font-descent::
* gcontext-background::
* gcontext-font::
* gcontext-foreground::
* map-subwindows::
* map-window::
* open-font::
* query-pointer::
* root-open-display::
* screen-black-pixel::
* screen-root::
* screen-white-pixel::
* unmap-subwindows::
* unmap-window::
* x amples::
* x wrapup::
@end menu

@c
@node  x overview, ]create-gcontext, x functions, x functions
@subsection x overview

[The volunteer who was going to complete the code in
this section never had time to do so, so it is not
included in the current version of the server.  I'll
be happy to cooperate with anyone else who wants to
volunteer to work on it.]

The functions described in this section constitutes a Muq
interface to the X Window System, following the CLX
(Common Lisp interface to X) standard as closely as
reasonable.

Examples are gathered into a separate section ("x
amples") rather than scattered through the individual
entries, because the X functions usually cannot be
briefly demonstrated in isolation.

@emph{These functions form an optional module and may
not be present in all versions of Muq.}

Note: These functions currently compile into package
@code{muf}, but will eventually move to package @code{xlib}.

@c
@node  ]create-gcontext, ]create-window, x overview, x functions
@subsection ]create-gcontext
@defun ]create-gcontext @{ [keyvals] -> gcontext @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a block of keyValue pairs,
then creates and returns an X graphics context.

Only the following keys are allowed:

@table @code
@item :arc-mode
Currently ignored.
@item :background
If value satisfies @code{integer?}, specifies background color;
Otherwise ignored.
@item :cap-style
Currently ignored.
@item :clip-mask
Currently ignored.
@item :clip-ordering
Currently ignored.
@item :clip-x
Currently ignored.
@item :clip-y
Currently ignored.
@item :dash-offset
Currently ignored.
@item :dashes
Currently ignored.
@item :drawable
Required;  Value must satisfy @code{window?}, and sets the @code{drawable}.
@item :exposures
Currently ignored.
@item :fill-rule
Currently ignored.
@item :fill-style
Currently ignored.
@item :font
If value satisfies @code{font?}, sets @code{font};  Otherwise ignored.
@item :foreground
If value satisfies @code{integer?}, specifies foreground color;
Otherwise ignored.
@item :function
Currently ignored.
@item :join-style
Currently ignored.
@item :line-style
Currently ignored.
@item :line-width
Currently ignored.
@item :plane-mask
Currently ignored.
@item :stipple
Currently ignored.
@item :subwindow-mode
Currently ignored.
@item :tile
Currently ignored.
@item :ts-x
Currently ignored.
@item :ts-y
Currently ignored.
@end table

@end defun


@c
@node  ]create-window, ]draw-glyphs, ]create-gcontext, x functions
@subsection ]create-window
@defun ]create-window @{ [keyvals] -> window @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a block of keyValue pairs,
then creates and returns an X window.

Only the following keys are allowed:

@table @code
@item :background
If value satisfies @code{integer?}, specifies background color;
Otherwise ignored.
@item :backing_pixel
Currently ignored.
@item :backing_planes
Currently ignored.
@item :backing_store
Currently ignored.
@item :bit_gravity
Currently ignored.
@item :border
Currently ignored.
@item :border_width
Currently ignored.
@item :class
Must be one of: @code{:copy} @code{:input-output} @code{:input-only}
@item :colormap
Currently ignored.
@item :cursor
Currently ignored.
@item :depth
Currently ignored.
@item :do_not_propagate_mask
Currently ignored.
@item :event_mask
If value satisfies @code{integer?}, specifies event mask;
Otherwise ignored.
The mask should ultimately have been created via
@code{]make-event-mask}.
@item :gravity
Currently ignored.
@item :height
If value satisfies @code{integer?}, specifies window height;
Otherwise ignored.
@item :override_redirect
Currently ignored.
@item :parent
If value satisfies @code{window?}, specifies window parent;
Otherwise ignored.
@item :save_under
Currently ignored.
@item :visual
Currently ignored.
@item :width
If value satisfies @code{integer?}, specifies window width;
Otherwise ignored.
@item :x
If value satisfies @code{integer?}, specifies window x coordinate;
Otherwise ignored.
@item :y
If value satisfies @code{integer?}, specifies window y coordinate;
Otherwise ignored.
@end table

@end defun


@c
@node  ]draw-glyphs, ]draw-image-glyphs, ]create-window, x functions
@subsection ]draw-glyphs
@defun ]draw-glyphs @{ [drawable gcontext x y string] -> nil nil @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a block of five positional arguments,
and returns two values, which are currently always @code{nil}.

Background pixels around the text are unchanged.

The input arguments are:
@table @code
@item drawable
Window to draw in -- must satisfy @code{window?}
@item drawable
Context to draw with -- must satisfy @code{gcontext?}
@item x
X coordinate at which to draw in window -- must satisfy @code{integer?}
@item y
Y coordinate at which to draw in window -- must satisfy @code{integer?}
@item string
Text to display in window -- must satisfy @code{string?}
@end table
@end defun


@c
@node  ]draw-image-glyphs, ]make-event-mask, ]draw-glyphs, x functions
@subsection ]draw-image-glyphs
@defun ]draw-image-glyphs @{ [[drawable gcontext x y string] -> nil nil @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a block of five positional arguments,
and returns two values, which are currently always @code{nil}.

Background pixels around the text are cleared to the
background pixel value specified by the @code{gcontext}.

The input arguments are:
@table @code
@item drawable
Window to draw in -- must satisfy @code{window?}
@item drawable
Context to draw with -- must satisfy @code{gcontext?}
@item x
X coordinate at which to draw in window -- must satisfy @code{integer?}
@item y
Y coordinate at which to draw in window -- must satisfy @code{integer?}
@item string
Text to display in window -- must satisfy @code{string?}
@end table
@end defun


@c
@node  ]make-event-mask, ]text-extents, ]draw-image-glyphs, x functions
@subsection ]make-event-mask
@defun ]make-event-mask @{ [args] -> mask @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function accepts a block of keywords and returns a
bitmask representing them.

Only the following keywords are allowed:

@table @code
@item :button-1-motion
@item :button-2-motion
@item :button-3-motion
@item :button-4-motion
@item :button-5-motion
@item :button-motion  
@item :button-press   
@item :button-release 
@item :colormap-change
@item :enter-window   
@item :exposure       
@item :focus-change   
@item :key-press      
@item :key-release    
@item :keymap-state   
@item :leave-window   
@item :owner-grab-button
@item :pointer-motion 
@item :pointer-motion-hint
@item :property-change
@item :resize-redirect
@item :structure-notify
@item :substructure-notify
@item :substructure-redirect
@item :visibility-change
@end table

@end defun


@c
@node  ]text-extents, close-display, ]make-event-mask, x functions
@subsection ]text-extents
@defun ]text-extents @{ [font text] -> W a d L R A dir nil @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{]texit-extents} function computes and returns
size information on the given @code{text} when rendered
in the given @code{font} by querying the X server.

The @code{font} argument must satisfy @code{font?}.
The @code{text} argument must satisfy @code{string?}.

The return values are:
@table @code
@item W
Width -- total width in pixels.
@item a
Ascent -- vertical ascent of given string.
@item d
Descent -- vertical descent of given string.
@item L
Left bearing of leftmost character.
@item R
Right bearing of rightmost character.
@item A
Vertical ascent of given font.
@item dir
Font direction -- @code{:left-to-right} or @code{:right-to-left}.
@item nil
Currently always @code{nil}.
@end table
@end defun


@c
@node  close-display, destroy-subwindows, ]text-extents, x functions
@subsection close-display
@defun close-display @{ display -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Closes given @code{display}.

The @code{display} argument must satisfy @code{display?}.
@end defun


@c
@node  destroy-subwindows, destroy-window, close-display, x functions
@subsection destroy-subwindows
@defun destroy-subwindows @{ window -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Destroy all offspring windows of the given @code{window}
on the relevant X server.

The @code{window} argument must satisfy @code{window?}.
@end defun


@c
@node  destroy-window, display-roots[, destroy-subwindows, x functions
@subsection destroy-window
@defun destroy-window @{ window -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Destroy the specified @code{window} on the relevant X server,
plus all offspring.

The @code{window} argument must satisfy @code{window?}.
@end defun


@c
@node  display-roots[, drawable-border-width, destroy-window, x functions
@subsection display-roots[
@defun display-roots[ @{ display -> [roots] @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns all screens on the given @code{display}.
(There will typically be just one.)

The @code{display} argument must satisfy @code{display?}.

The returned values will satisfy @code{screen?}.
@end defun


@c
@node  drawable-border-width, drawable-depth, display-roots[, x functions
@subsection drawable-border-width
@defun drawable-border-width @{ window -> width @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the @code{width} in pixels of the border
on the given @code{window}.

The @code{window} argument must satisfy @code{window?}.

The @code{width} value will satisfy @code{integer?}.

@end defun


@c
@node  drawable-depth, drawable-display, drawable-border-width, x functions
@subsection drawable-depth
@defun drawable-depth @{ window -> depth @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the @code{depth} in bits of pixels on the given @code{window}.

The @code{window} argument must satisfy @code{window?}.

The @code{depth} value will satisfy @code{integer?}.

@end defun


@c
@node  drawable-display, drawable-height, drawable-depth, x functions
@subsection drawable-display
@defun drawable-display @{ window -> display @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the @code{display} on which @code{window} will appear.

The @code{window} argument must satisfy @code{window?}

The @code{display} value will satisfy @code{display?}
@end defun


@c
@node  drawable-height, drawable-width, drawable-display, x functions
@subsection drawable-height
@defun drawable-height @{ window -> height @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the @code{height} in pixels of the given @code{window}.

The @code{window} argument must satisfy @code{window?}.

The @code{height} value will satisfy @code{integer?}.

@end defun


@c
@node  drawable-width, drawable-x, drawable-height, x functions
@subsection drawable-width
@defun drawable-width @{ window -> width @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the @code{width} in pixels of the given @code{window}.

The @code{window} argument must satisfy @code{window?}.

The @code{width} value will satisfy @code{integer?}.

@end defun


@c
@node  drawable-x, drawable-y, drawable-width, x functions
@subsection drawable-x
@defun drawable-x @{ window -> x @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the X-coordinate in pixels of the given @code{window}.

The @code{window} argument must satisfy @code{window?}

The @code{x} value will satisfy @code{integer?}

@end defun


@c
@node  drawable-y, flush-display, drawable-x, x functions
@subsection drawable-y
@defun drawable-y @{ window -> y @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns in Y-coordinate in pixels of the given @code{window}.

The @code{window} argument must satisfy @code{window?}

The @code{y} value will satisfy @code{integer?}
@end defun


@c
@node  flush-display, font-ascent, drawable-y, x functions
@subsection flush-display
@defun flush-display @{ display -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Flush all buffered output to the given display,
to ensure pending draw commands are sent and
the display left as intended.

This is not normally needed, as @code{xlib}
automatically does flushes at appropriate
points such as before reading input, but
may occasionally be useful, for example in
animation.
@end defun


@c
@node  font-ascent, font-descent, flush-display, x functions
@subsection font-ascent
@defun font-ascent @{ font -> ascent @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the vertical @code{ascent} in pixels used for
interline spacing of the given font.

The @code{font} argument must satisfy @code{font?}

The @code{ascent} value will satisfy @code{integer?}
@end defun


@c
@node  font-descent, gcontext-background, font-ascent, x functions
@subsection font-descent
@defun font-descent @{ font -> descent @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the vertical @code{descent} in pixels used for
interline spacing of the given font.  (Some characters
may in the font may actually descent deeper than this.)

The @code{font} argument must satisfy @code{font?}

The @code{descent} value will satisfy @code{integer?}
@end defun


@c
@node  gcontext-background, gcontext-font, font-descent, x functions
@subsection gcontext-background
@defun gcontext-background @{ gcontext -> background @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the background color in the given @code{gcontext}.

The @code{gcontext} argument must satisfy @code{gcontext?}

The @code{background} value will satisfy @code{integer?}
@end defun


@c
@node  gcontext-font, gcontext-foreground, gcontext-background, x functions
@subsection gcontext-font
@defun gcontext-font @{ gcontext -> font @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the @code{font} associated with the given @code{gcontext}.

The @code{gcontext} argument must satisfy @code{gcontext?}

The return @code{font} value will either be @code{nil} or
satisfy @code{font?}
@end defun


@c
@node  gcontext-foreground, map-subwindows, gcontext-font, x functions
@subsection gcontext-foreground
@defun gcontext-foreground @{ gcontext -> foreground @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the foreground color in the given @code{gcontext}.

The @code{gcontext} argument must satisfy @code{gcontext?}

The @code{foreground} value will satisfy @code{integer?}
@end defun


@c
@node  map-subwindows, map-window, gcontext-foreground, x functions
@subsection map-subwindows
@defun map-subwindows @{ window -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Maps all subwindows of @code{window} on the relevant
server.  (This makes them visible, provided that
@code{window} itself is visible.)

The @code{window} argument must satisfy @code{window?}
@end defun


@c
@node  map-window, open-font, map-subwindows, x functions
@subsection map-window
@defun map-window @{ window -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Maps @code{window} on the relevant server.  (This
makes it visible, provided that its ancestors are
all visible.)

The @code{window} argument must satisfy @code{window?}
@end defun


@c
@node  open-font, query-pointer, map-window, x functions
@subsection open-font
@defun open-font @{ display fontname -> font @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Finds and returns the @code{font} named @code{fontname}
on @code{display}.

The @code{display} argument must satisfy @code{display?}

The @code{fontname} argument must satisfy @code{string?}

The @code{font} value will satisfy @code{font?}
@end defun


@c
@node  query-pointer, root-open-display, open-font, x functions
@subsection query-pointer
@defun query-pointer @{ window -> x y same? kid state rx ry root@}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

This function returns information about the location of
the pointer (cursor) relative to the given
@code{window}.

The @code{window} argument must satisfy @code{window?}

The return values are:
@table @code
@item x
(satisfies @code{integer?} pixel pointer location
relative to window.
@item y
(satisfies @code{integer?} pixel pointer location
relative to window.
@item same?
(@code{t} or @code{nil}) t if pointer is on same screen
as window.
@item kid
(@code{nil} or satisfies @code{window?}) child of
@code{window} containing the pointer, if any.
@item state
(satisfies @code{integer?}) state of mouse buttons and
modifier keys.
@item rx
(satisfies @code{integer}) pixel pointer location
relative to root window.
@item ry
(satisfies @code{integer}) pixel pointer location
relative to root window.
@item root
(satisfies @code{window?}) root window containing pointer
@end table

If @code{same?} is @code{nil}, @code{child} will also
be @code{nil} and @code{x} and @code{y} will be zero.
@end defun


@c
@node  root-open-display, screen-black-pixel, query-pointer, x functions
@subsection root-open-display
@defun root-open-display @{ hostname -> display @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Opens the indicated X display.

The @code{hostname} argument must satisfy
@code{string?} and will usually look something
like "rocky.uw.edu:0".

The @code{display} value will satisfy @code{display?}

This function is restricted to @code{root} in part
because X is a nontrivial security threat:  For
example, it is possible to open an invisible window
and collect all keystrokes typed including passphrases,
or to stuff commands like "rm -rf ~/*" into shell
windows.  You may not want arbitrary people having
X access on your Muq server.
@end defun


@c
@node  screen-black-pixel, screen-root, root-open-display, x functions
@subsection screen-black-pixel
@defun screen-black-pixel @{ screen -> color @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the "black" pixel value on the indicated
@code{screen}.

The @code{screen} argument must satisfy @code{screen?}

The @code{color} value will satisfy @code{integer?}
@end defun


@c
@node  screen-root, screen-white-pixel, screen-black-pixel, x functions
@subsection screen-root
@defun screen-root @{ screen -> window @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the root @code{window} for the given
@code{screen}.

The @code{screen} argument must satisfy @code{screen?}

The @code{window} argument will be @code{nil} or
satisfy @code{window?}

@end defun


@c
@node  screen-white-pixel, unmap-subwindows, screen-root, x functions
@subsection screen-white-pixel
@defun screen-white-pixel @{ screen -> color @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Returns the "white" pixel value on the indicated
@code{screen}.

The @code{screen} argument must satisfy @code{screen?}

The @code{color} value will satisfy @code{integer?}
@end defun


@c
@node  unmap-subwindows, unmap-window, screen-white-pixel, x functions
@subsection unmap-subwindows
@defun unmap-subwindows @{ window -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Unmaps all children of @code{window}, making them
invisible (if they weren't already).

The @code{window} argument must satisfy @code{window?}
@end defun


@c
@node  unmap-window, x amples, unmap-subwindows, x functions
@subsection unmap-window
@defun unmap-window @{ window -> @}
@display
@exdent file: 10-C-utils.t
@exdent package: muf
@exdent status: alpha
@end display

Unmaps @code{window}, making it
invisible (if it wasn't already), along with any
descendent windows.

The @code{window} argument must satisfy @code{window?}
@end defun


@c
@node  x amples, x wrapup, unmap-window, x functions
@subsection x amples

The Muq X support library isn't complete enough to do a
lot as yet; The code so far was written primarily in
the hope of teasing someone else into contributing to
this project.  If that doesn't happen, I'll get back to
it once the rest of the server is in solid shape...

Here's a brief code sequence which exercises most of
what works so far.  It is intended to be executed
interactively line-by-line:

@example

( ConvenienceFor popping query-pointer stuff. )
: p8 pop pop pop pop pop pop pop pop ; 

( Open display: )
"localhost:0" root-open-display --> display

( Find a screen on display: )
display display-roots[ |pop --> screen ]pop

( Find a color for foreground: )
screen screen-black-pixel --> fg-color

( Find a color for background: )
screen screen-white-pixel --> bg-color

( Find a font for text: )
display "8x13bold" open-font --> nice-font

( Find the root window for screen: )
screen screen-root --> window

( Query location of pointer on root window: )
window query-pointer

( Discard pointer information: )
p8

( Create a pen (gcontext) to draw with: )
[ :drawable window :foreground fg-color :background bg-color :font nice-font |
]create-gcontext --> gcontext 

( Create a white window of our very own: )
[ :enter-window :leave-window :button-press :button-release |
]make-event-mask --> event-mask
[ :parent window :x 10 :y 10 :width 200 :height 100 :background bg-color :event-mask event-mask |
]create-window --> our-window

( Make our window visible: )
our-window map-window   display flush-display

( Create a black window within our white window: )
[ :parent our-window :x 8 :y 8 :width 16 :height 16 :background fg-color :event-mask event-mask |
]create-window --> sub-window

( Make our subwindow visible: )
sub-window map-window   display flush-display

( Destroy our subwindow: )
sub-window destroy-window   display flush-display

( Draw some text in the window: )
[ our-window gcontext 10 20 "Hello world!" | ]draw-glyphs display flush-display
@end example

@c
@node  x wrapup, Core Muf Wrapup, x amples, x functions
@subsection x wrapup

I expect Muq support for X to ramp up steadily over
time:  Once the basic @sc{clx} interface is in place,
we'll need support for one or more widget sets, for
example.  This is a nice, separable project for
anyone with the time and interest.

@c
@node Core Muf Wrapup, Muq Plans, x wrapup, Core Muf
@section Core Muf Wrapup

This concludes the Core Muf chapter.

@c --    File variables                                                 */

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:

