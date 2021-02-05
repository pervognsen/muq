@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muf Data Types, Data Types Overview, Top, Top
@chapter Muf Data Types

@menu
* Data Types Overview::
* Booleans::
* Characters::
* Strings::
* Strings::
* Integers::
* Floats::
* Lists::
* Vectors::
* Structures::
* Symbols::
* Data Type Ownership::
* Data Type Comparisons::
* Data Type Efficiency Considerations::
@end menu
@c -*-texinfo-*-

@c {{{ Data Types Overview					

@c
@node Data Types Overview, Booleans, Muf Data Types, Muf Data Types
@section Data Types Overview
@cindex Value typing vs typing of variables
@cindex Typing, of values vs of variables
@cindex Muf datatypes, first-classness
@cindex First-classness of Muf datatypes

This manual draws an intuitive but ultimately artificial distinction
between "data types" like integer, which the programmer tends to think
of as atomic entities, and objects, which the programmer tends to think
of as named collections of atomic entities.  This chapter briefly
introduces the former.

Muq is intended to ultimately support a good implementation of
CommonLisp, hence the data types are closely related to those
implemented by CommonLisp.  Any serious differences between Muq and
CommonLisp data types are likely to eventually be resolved in Common
Lisp's favor.

Note that in muf, like Lisp but unlike C, it is @emph{values} which have
types, not variables.  It is perfectly legal, and frequently useful, for
a muf variable to hold an integer one moment and a string or object the
next.  Since all values "know" what type they are, no confusion results.

(In languages like C, on the other hand, values do @emph{not} "know"
what type they are, so allowing the same variable to hold an integer at
one moment and a float at the next is normally an excellent recipe for
disaster.)

With only obscure server-internal exceptions, all Muq data types are
@dfn{first class:} any of them may be stored in any variable, pushed on
any stack, used as a key or value on any object, and so forth
@footnote{Yes, really, any value: you may use a compiled function for a
property name and a job instance for a property value, for example.}.
This makes for a more flexible and predictable system than in
traditional mudservers, in which each class of variable or property has
arbitrary (and different) restrictions on which values may be stored,
few if any of them designed to make the muf programmer's life easier.
(Many individual Muq operators accept only arguments of certain kinds,
of course: arithmetic operators expect numbers, string formatting
operators expect strings, and so on.  This is a separate issue.)

@c {{{endfold}}}
@c {{{ Booleans							

@c
@node Booleans, Characters, Data Types Overview, Muf Data Types
@section Booleans
@cindex Muf boolean values
@cindex Boolean values in Muf
@cindex nil value in Muf
@cindex t value in Muf
@cindex Muf 't' value
@cindex Muf value for true ('t')
@cindex Muf value for false ('nil')
@cindex Muf value for empty list ('nil')

Boolean values are those which are logically either @sc{true} or
@sc{false}.  They are returned as result values by operators like
@code{and} and @code{or,} and accepted as arguments by operators like
@code{if.}

Following CommonLisp, muf does not have a separate Boolean type;
instead, it has a special value @code{nil} which represents @sc{false,}
all other values being taken as representing @sc{true} in a boolean
context.  The standard true value is the constant @code{t,} but any
other value, such as @code{12} or @code{.lib.muf,} will do as well.

The constant @code{nil} also represents the empty list.  @xref{Lists}.

Note: In Muq v -1.0.0, @code{nil} and @code{t} are actually a separate
type boolean, as required by the Scheme standard.  Programs should not
be coded to depend on this: The CommonLisp standard requires @code{nil}
and @code{t} to be symbols, and future Muq releases will switch to this
setup.

@c {{{endfold}}}
@c {{{ Characters						

@c
@node Characters, Strings, Booleans, Muf Data Types
@section Characters
@cindex Character constant syntax in Muf
@cindex Muf syntax for character constants

Character constants represent single @sc{ascii} characters,
and are entered and printed according to C syntax:

@example
'a' 'b' 'c' '\n' '\0'
@end example

@noindent
Unlike C, muf character constants are _not_ integers:
they are a separate type, distinct from both integers
and strings.

Characters compare by @sc{ascii} collating order.

Note: This syntax for character constants is inconsistent
with the CommonLisp standard, but I find the CommonLisp
character-constant syntax too painfully ugly to inflict on
muf programmers.

@c {{{endfold}}}
@c {{{ Strings							

@c
@node Strings, Integers, Characters, Muf Data Types
@section Strings
@cindex String constant syntax in Muf
@cindex Muf string constants
@cindex Muf strings, length limit
@cindex Length limit, strings.

Muq string constants represent string strings, 
and are entered and printed according to C syntax:

@example
"abc" "\r\n" "\0\013\044"
@end example

@noindent
Unlike C, muf string constants are _not_ null-terminated; muf
string constants "know" their own length, and may contain
arbitrary eight-bit data.  Thus, they may also be used for
containing things like binary images and sounds.

Muf strings compare by @sc{ascii} collating order.

Muf strings currently (v -1.0.0) are limited to about 64K in
length; This limitation will be removed in future releases.

(You can probably currently crash the server by pushing this
limit.)

@c {{{endfold}}}
@c {{{ Integers							

@c
@node Integers, Floats, Strings, Muf Data Types
@section Integers
@cindex Muq integers, 31-bit.
@cindex Integers, 31-bit.
@cindex 31-bit integers.

On 32-bit machines, Muq muf supports 31-bit signed integers,
with the usual decimal syntax:

@example
123
-412
@end example

@noindent
(The "missing" bit is used internally to distinguish integer
values from, for example, float and character values.)

Overflow is currently ignored, but code should not be
written to depend on this: It is possible that future
versions of Muq will implement arbitrary-precision integer
arithmetic.

@c {{{endfold}}}
@c {{{ Floats							

@node Floats, Lists, Integers, Muf Data Types
@section Floats
@cindex Muq floating point numbers, 27-bit.
@cindex Floating point numbers, 27-bit.
@cindex 27-bit floating point numbers.

On 32-bit machines, Muq muf supports 27-bit floats:
the host 32-bit floating-point format minus five bits off
the bottom.  (The "missing" five bits are used internally to
distinguish float values from, for example, int and
character values.)  The syntax follows the C standard:

@example
123.0
-412.12e-12
@end example

@noindent
Neither full single precision nor double precision floats
are currently supported; it is possible that a future
release of Muq will do so.

Note: It is likely that a future release will switch from
using C float syntax to using Lisp float syntax, which is
similar but not identical.  (And, as usual, more
complicated.)

@c {{{endfold}}}
@c {{{ Lists							

@node Lists, Vectors, Floats, Muf Data Types
@section Lists
@cindex Muq Lists (lisp sense).
@cindex Lists (lisp sense).
@cindex Cons cells.

Muq muf provides operators to construct and traverse
Lisp-style lists constructed of pointer-pairs, but does not
provide the syntactic convenience Lisp does for entering
them, nor are they as central to normal muf coding style as
they are to Lisp.

As in Lisp, @code{nil} represents the empty list, while
non-empty lists are constructed of cons cells, each
containing two pointers.

Muq cons cells are subject to side-effects, hence are
compared by address, not by contents.

@c {{{endfold}}}
@c {{{ Vectors							

@node Vectors, Structures, Lists, Muf Data Types
@section Vectors
@cindex Vectors.
@cindex Arrays, one-dimensional.

Vectors are simple fixed-length, one-dimensional arrays.
They are intended to provide a simple, flexible,
space-efficient component from which muf programmers may
build custom datastructures of various sorts.  To this end,
a vector contains an absolute minimum of overhead (a pointer
identifying its owner), and hence provides a minimum of
functionality: Just the ability to return its length, and to
get and set the value of any slot.

As in C and Lisp, vector slots are numbered starting at
zero.

Since vectors are subject to side-effects, they are compared
by address rather than by contents.

As an efficiency hack, it is possible to allocate vectors on
the stack rather than on the heap.  Doing so avoids the need
to garbage-collect them, and fits naturally into the paradigm
of some languages like C;  It also of course introduces the
danger of the vector being recycles while references to it
remain, and in the Muq implementation restricts access to
the vector to the job creating the vector.

@c {{{endfold}}}
@c {{{ Structures

@node Structures, Symbols, Vectors, Muf Data Types
@section Structures
@cindex Structures.
@cindex Records.

Structures are simple fixed-length sets of named
values, corresponding to "records" in Pascal or
"structs" in C.

Like vectors, they are intended to provide a simple, flexible,
space-efficient component from which muf programmers may
build custom datastructures of various sorts, and
contain an absolute minimum of overhead (a pointer
identifying its owner, plus a pointer to the structure
definition), and hence provide a minimum of
functionality.

Since structures are subject to side-effects, they are compared by
address rather than by contents.

As an efficiency hack, it is possible to allocate structures on
the stack rather than on the heap.  Doing so avoids the need
to garbage-collect them, and fits naturally into the paradigm
of some languages like C;  It again introduces the
danger of the structure being recycled while references to it
remain, and in the Muq implementation restricts access to
the structure to the job creating the vector.

@c {{{endfold}}}
@c {{{ Symbols							

@node Symbols, Data Type Ownership, Structures, Muf Data Types
@section Symbols
@cindex Symbols (lisp sense).
@cindex Symbols as global variables.
@cindex Symbols as names for functions.
@cindex Symbols, singlequoting.
@cindex Property lists on symbols (lisp sense).

Muq @dfn{symbols} are modelled directly on those of Common
Lisp, and serve essentially as global variables.

Internally, a symbol is much like a vector with one slot
each for the name of the symbol, the value of the symbol
when used as a variable, the value of the symbol when used
as a function, a list of properties associated with the
symbol, and the package to which the symbol belongs.
@xref{Class Package}.

Only the function and value slots are normally of interest to
the muf programmer:

@itemize @bullet
@item
Muf tends to use properties on objects in preference to to
property lists on symbols.

@item
As in Lisp, the package pointer tends to be more for
internal bookkeeping than for explicit reference.
@end itemize

The "global variables" the muf programmer deals with,
including names of functions, are in fact symbols.

In muf, mentioning the name of a symbol generates a call to
the 'function' value of the symbol if it has one, else
pushes the contents of its value slot on the stack.
Preceding the symbol's name with a singleQuote pushes the
symbol itself on the stack.

Thus, it is important to define a function before attempting
to use it: doing otherwise will result in a load of the
symbol's value rather than a call to it.

Symbols export the following properties:

@example
$S.name     String naming object.
$S.function If symbol names a function, this holds the compiledFunction.
$S.package  If symbol is owned by a package, this points to that package.
$S.value    If symbol names a global variable, this holds the value.
$S.type     If symbol names a type, this holds the type.
$S.proplist A linklist of properties, as usual in Lisp.
@end example

@c {{{endfold}}}
@c {{{ Data Type Ownership					

@node Data Type Ownership, Data Type Comparisons, Symbols, Muf Data Types
@section Data Type Ownership

Muq is intended as a fairly heavy-duty multiuser system.

Two consequences of that are that everything which takes
space in the db has an owner, Muq tracking the total number
of bytes of db space consumed by each user, and that only
the owner of an object can modify it.

(Note: This isn't working yet in version -1.0.0.)

Characters, integers, floats and strings may not be modified
at all.  Cons cells, symbols and vectors may only be
modified by their owner.

(As a practical matter, the owner of such data may make
publicly available setuid code which empowers others to
modify them; when that code does so, however, it does so by
running as the legitimate owner, so as far as the server is
concerned, it remains true that only the owner can modify
them.)

@c {{{endfold}}}
@c {{{ Data Type Comparisons					

@node Data Type Comparisons, Data Type Efficiency Considerations, Data Type Ownership, Muf Data Types
@section Data Type Comparisons
@cindex Comparison of Muq datatypes, collating order(s).
@cindex Collating order(s) of Muq datatypes.
@cindex Datatypes, collating order(s).

Muq provides native operators such as @code{<} and @code{=}
to compare values, hence must decide what the results of
such comparisons should be for any possible pair of values.

In addition, Muq objects allow the use of any values
whatever as both keys and values, and maintains (for
example) all public keyValue pairs on an object in a sorted
tree.

For this to work nicely, it is essential that values compare
equal only if they can sensibly be regarded as
interchangable, that any pair of values not equal sort into
one of the two possible orderings, and that any given
unequal pair of values should always sort into the same
order.

In light of this, the Muq muf comparison operators are
defined over all possible pairs of values.  Values not
subject to side-effects (characters, integers, floats and
strings) are sorted by contents; the remaining values are
sorted by their arbitrary internal binary addresses.

Integers and floats intercompare according to normal numeric
rules: 2.0 is equal to 2.  Except for this values of
different types are always unequal.

Properties of the comparison functions not defined above are
subject to change in future releases; coding should not
depend (for example) on whether strings sort less than or
greater than integers.

@c {{{endfold}}}
@c {{{ Data Type Efficiency Considerations			

@node Data Type Efficiency Considerations, Muq Classes, Data Type Comparisons, Muf Data Types
@section Data Type Efficiency Considerations
@cindex Datatypes, efficiency (space and time).
@cindex Efficiency (space and time) of Muq datatypes.

Novice programmers tend to worry too much about efficiency
early on, and too little about it later on.  Unless your
code is going to run thousands of times, or manipulate
thousands of items of some sort, efficiency is not normally
likely to be a very important consideration.

Still, one does write programs from time to time which take
significant amounts of time or space, and it is worth
understanding the approximate space and time costs of the
various programming primitives one is using.

Muq muf characters, integers and floats take up no space at
all, in the sense that they fit entirely within their
variable, property, or stack slot.

Operations on integers and floats take about fifty host
clock cycles, as a rough rule of thumb, meaning that integer
muf code is likely to be about two orders of magnitude
slower than equivalent C code would be.  If you need to do
serious number-crunching, you probably want to code up a new
muf primitive for it to put in inner loop down in C, or
perhaps just write a separate server.

Strings of three bytes or less also take "no space": Muq
stores them, like ints and chars, entirely within the
pointer.

All objects allocated separate memory blocks have about
twelve bytes of internal overhead when in memory, with
usually another four bytes of ownership information on top
of that.  Strings also get rounded up to a multiple of four
bytes in length, internally, so as to keep everything
word-aligned.  (All 32-bit machines run faster if operands
are 32-bit aligned; many require this.)

If you're going to store thousands of some string, therefor,
"yes" is a @emph{much} better choice than "true": four bytes
each vs twenty-four bytes each, approximately, on a 32-bit
machine.

Vectors take normal overhead plus four bytes per slot on a
32-bit machine; Symbols are essentially four-slot vectors;
Cons cells are essentially two-slot vectors.

Thus, for example, a list of 100 cons cells is going to take
about 2K when in ram (sixteen bytes of overhead plus eight
bytes of slot, per cell) while a 100-slot vector will take
about 416 bytes when in ram.

All operations fetching or storing a value from vectors,
symbols, cons cells, stack slots, and local variables can be
thought of as taking 50-100 host clock cycles -- about as
fast as Muq can do anything.  (Any read or write or a
property on an object, by contrast, should be thought of as
taking thousands of host clock cycles.)  Operations on the
top two stack locations are fastest; Everything else is
operated on by first loading it onto the stack.

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
