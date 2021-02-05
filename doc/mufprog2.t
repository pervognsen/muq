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

@c Should make a serious effort to go through and
@c try to present everything in terms of How To
@c Solve Task X.  Or, if that's not practical,
@c have a separate section of such task-oriented
@c tutorials.  Memorizing features is deadly dull
@c and does little to advance programming skill:
@c What one needs is programming production rules
@c of the form Problem X can be solved by doing Y,
@c which are what real programming skill consists
@c of.  (Maybe that should be the mufprog2/mufprog3
@c distinction?)

@node Intermediate Muf Programming, Intermediate Muf Programming Overview, Top, Top
@chapter Intermediate Muf Programming

@menu
* Intermediate Muf Programming Overview::
* Understanding Structures::
* Understanding Regular Expressions::
* Understanding Arities::
* Understanding Indices::
* Understanding Packages::
* Understanding Jobs::
* Understanding Lists::
* Understanding Muf Macros::
* Understanding Coding Style::
* Intermediate Muf Programming Wrapup::
@end menu

@c {{{ Intermediate Muf Programming Overview

@c
@node Intermediate Muf Programming Overview, Understanding Structures, Intermediate Muf Programming, Intermediate Muf Programming
@section Intermediate Muf Programming Overview

(This chapter is unfinished; Critiques and topic suggestions
welcome.)

This chapter is intended to provide in-depth @sc{muf}'s-eye
explanations of all the core Muq @sc{muf} programming
facilities.  If you study this chapter diligently and find
that significant aspects of the core Muq @sc{muf}
programming facilities remain mysterious, that is a
documentation bug and should be reported as such.

This chapter is unabashedly more difficult than the
Elementary @sc{muf} Programming chapter: We're going to be
covering more ground in more detail, and will presume you
are motivated enough to keep up and self-sufficient enough
to do follow-up reading in the reference manual where
appropriate.

The sections in this chapter are arranged in a reasonably
logical order, but are sufficiently self-contained that you
should be able to read them selectively as you get
interested in a particular topic, if you prefer.

There are relatively few examples in this chapter, since the
Advanced @sc{muf} Programming chapter consists of almost
nothing @emph{but} examples.

I suggest reading the current chapter by stages, examining
examples that you find interesting from the Advanced
@sc{muf} Programming chapter in the interstices, and
meanwhile working on a programming project that interests
you, perhaps starting with one of the Advanced @sc{muf}
Programming examples, as you go along.

(If you do not have a programming project in mind that
interests you, you will most likely find all this very
dreary indeed, and in fact I would have to wonder why you
are bothering to read this.)

@c {{{endfold}}}
@c {{{ Understanding Structures

@c
@node Understanding Structures, Structures Overview, Intermediate Muf Programming Overview, Intermediate Muf Programming
@section Understanding Structures

@menu
* Structures Overview::
* Simple Structure Example::
* Default Slot Values::
* Read/Write Slot Protection::
* Extending A Structure::
* Ephemeral Structures::
* Structures Wrapup::
@end menu

@c {{{ Structures Overview

@c
@node  Structures Overview, Simple Structure Example, Understanding Structures, Understanding Structures
@subsection Structures Overview

Muq @emph{structures} are modelled closely on those of CommonLisp,
and are similar to Pascal's @emph{records} and C's @emph{structs}.

One thinks of a structure as being a chunk of storage
divided into named slots, each capable of holding one
value.  A structure representing a person might, for
example, have slots for @emph{name}, @emph{age} and
@emph{sex}:

@example
    __________________________
    | Name     "Pat"         |
    __________________________
    | Age      21            |
    __________________________
    | Sex      Yes           |
    __________________________
@end example

Structures are simple, no-frills datastructures
intended to supply this sort of functionality
with a minimum of extra baggage.

Structures are the appropriate datastructure to
use when either your needs are so simple that
the extra machinery supplied by objects would
be wasted, or else when you needs are so
specialized that you prefer to construct the
facilities you need yourself out of simple
building blocks, in order to have maximum
control over the time and space tradeoffs.

Structures are very similar to vectors, differing
mainly in that vector slots are selected by small
integers, whereas structure slots are selected by
mnemonic names.  Thus, vectors are a better choice if
you often compute which slot to use on the fly, and
structures are a better choice if you usually have a
fixed number of slots each with a fixed and distinct
meaning.

@c {{{endfold}}}
@c {{{ Simple Structure Example

@c
@node  Simple Structure Example, Default Slot Values, Structures Overview, Understanding Structures
@subsection Simple Structure Example

Let's define a structure type @code{person}:

@example
Stack:
[ 'person   'name 'age 'sex | ]defstruct
Stack:
@end example

We may now create structures of this type:

@example
Stack:
[ :name "Pat"  :age 21   :sex t | ]make-person --> pat
Stack:
pat
Stack: #<a person>
ls
:name	"Pat"
:age	21
:sex	t
@end example

Structure slots may be accessed using the usual
path notation:

@example
Stack:
pat.name
Stack: "Pat"
pop   "Kim" --> pat.name
Stack:
pat.name
Stack: "Kim"
@end example

Structure slots may also be accessed using
functions which @code{]defstruct} defined
for the purpose:

@example
Stack:
pat person-name
Stack: "Kim"
pop   pat "Pat" set-person-name
Stack:
pat person-name
Stack: "Pat"
@end example

Finally, @code{]defstruct} has defined a
a predicate @code{person?} and assertion
@code{is-a-person} which may be
used to test whether a value is a person:

@example
Stack:
2.3 person?
Stack: nil
pop   pat person?
Stack: t
pop pat is-a-person
Stack:
@end example

That's all you need to know about structs for most
routine applications!

However, @code{]defstruct} has many more tricks up
its sleeve, which can be very handy on occasion.
We'll cover some of them in the following sections;
For full details, @xref{]defstruct,,,mufcore.t,Muf Reference}.

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Ephemeral Structures

@c
@node  Default Slot Values, Read/Write Slot Protection, Simple Structure Example, Understanding Structures
@subsection Default Slot Values

Particularly if a structure has many slots,
and the value of some are usually the same
for each instance, we may prefer to have
the value of a slot default to the appropriate
value on creation, saving us from having to
repetitively explicitly specify these values.

For example, sailboats are occasionally
dismasted or lose a rudder, but most
sailboats most of the time have both
mast and rudder, and we might wish Muq
to assume this except when told otherwise.

@example
Stack:
[ 'sailboat
  'name       :initval "Windward Passage"
  'has-mast   :initval t
  'has-rudder :initval t
| ]defstruct
@end example

Now any sailboat created will start out
with the given values in its three slots
unless we explicitly say otherwise:

@example
Stack:
[ | ]make-sailboat --> myboat
Stack: 
myboat
Stack: #<a sailboat>
ls
:name	"Windward Passage"
:has-mast	t
:has-rudder	t
Stack:
[ :name "Leaky Sieve"
  :has-mast nil
  :has-rudder nil
| ]make-sailboat --> yourboat
Stack:
yourboat ls
:name	"Leaky Sieve"
:has-mast	nil
:has-rudder	nil
@end example

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Ephemeral Structures

@c
@node  Read/Write Slot Protection, Extending A Structure, Default Slot Values, Understanding Structures
@subsection Read/Write Slot Protection

You may specify, for each slot in a structure,
just which categories of users are allowed to
read or write that slot, using a fixed system
of four user categories:

@table @emph
@item root
Users with root privileges on the server.  Only
root users may restrict root access.
@item user
The user who created the structure instance holding
the slot.
@item class
The user who created the @emph{definition} for the
structure instance holding the slot -- that is,
the user who executed the original @code{]defstruct}.
@item world
Any user at all.
@end table

The point of the @emph{class} category is to allow the
creation of structures which are owned (and counted
against the space quota) of a user, but which are
maintained by code written by another user.

For example, in a game context it may be desirable for
each player to own a per-player state structure
containing score and location, but not for each player
to be able to randomly update score and location.

As examples, we show first the extreme case of
defining a structure type @code{blackhole} whose
single @code{hadron} slot is completely
inaccessable (you'll need to be root to have this
work properly)

@example
root:
[ 'blackhole
    'hadron
      :rootMayRead    nil
      :rootMayWrite   nil
      :userMayRead    nil
      :userMayWrite   nil
      :classMayRead   nil
      :classMayWrite  nil
      :worldMayRead   nil
      :worldMayWrite  nil
| ]defstruct
@end example

@noindent
and then a structure type @code{blackboard} whose
single @code{slate} slot is both readable and writable
by everyone

@example
root:
[ 'blackboard
    'slate
      :worldMayRead   t
      :worldMayWrite  t
| ]defstruct
@end example

@noindent
and finally a structure type @code{spacewar} with
slots readable by the user but only modifiable by
the class:

@example
root:
[ 'spacewar
    'score
      :initval          0
      :userMayRead    t
      :userMayWrite   nil
      :classMayRead   t
      :classMayWrite  t
      :worldMayRead   nil
      :worldMayWrite  nil
    'x-loc
      :initval          0.0
      :userMayRead    t
      :userMayWrite   nil
      :classMayRead   t
      :classMayWrite  t
      :worldMayRead   nil
      :worldMayWrite  nil
    'y-loc
      :initval          0.0
      :userMayRead    t
      :userMayWrite   nil
      :classMayRead   t
      :classMayWrite  t
      :worldMayRead   nil
      :worldMayWrite  nil
| ]defstruct
@end example

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Extending A Structure

@c
@node  Extending A Structure, Ephemeral Structures, Read/Write Slot Protection, Understanding Structures
@subsection Extending A Structure

It is sometimes handy to define a new
structure which is just like an existing
structure except for having an additional
slot or two.  

For example, recall our example structure
type

@example
[ 'person   'name 'age 'sex | ]defstruct
@end example

@noindent
and suppose that we wish to define a new
structure type @code{saint} which is just
like @code{person} except for having an
extra field in which to count miracles,
which we will initialize to two, that
being the qualifying number for a saint:

@example
[ 'saint :include 'person   'miracles :initval 2 | ]defstruct
@end example

Now we can do

@example
Stack:
[ :name "Nick" :age 3042 :sex nil :miracles 10 | ]make-saint --> nick
Stack:
nick
Stack: #<a saint>
ls
:name	"Nick"
:age	3042
:sex	nil
:miracles	10
Stack:
nick person?
Stack: t
pop nick saint?
Stack: t
pop nick person-name
Stack: "Nick"
pop nick saint-miracles
Stack: 10
pop nick.name
Stack: "Nick"
pop nick.miracles
Stack: 10
@end example

Note that all the old access and predicate functions
for type @code{person} still work on type @code{saint}:
In general, you can use a saint anywhere you can use
a person, you just have the extra field of miracles
available.

You may @code{:include} only one structure in a
given structure definition -- remember, structures
are intended to be simple, cheap datastructures!
For fancy stuff, you need objects and generic
functions.

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Ephemeral Structures

@c
@node  Ephemeral Structures, Structures Wrapup, Extending A Structure, Understanding Structures
@subsection Ephemeral Structures

It is sometimes convenient to create structures at a
high rate for very temporary, local use.  For example,
a structure is a convenient way of packaging up state
in one function to be passed to functions it is calling:
If the state contains two or three dozen slots, passing
a single structure through a forest of mutually
recursive functions can be much more appetizing than
passing the state as two or three dozen parameters to
each function, or -- worse -- in two or three dozen
global symbols.

In cases like these, one may be creating structures
very frequently which are known to be unwanted on
return from the creating function, and it may be
much more efficient to allocate them on the stack
than to have the general-purpose garbage collector
find and recycle them all.

I intend that at some point one should be able to
allocate any structure on the stack simply by doing

@example
[ :ephemeral t   ... | ]make-whatever
@end example

@noindent
in place of the vanilla

@example
[ ... | ]make-whatever
@end example

@noindent
call.  Unfortunately, @code{]make-whatever} is itself
an in-db function, and while the structure gets
stack-allocated properly, it also gets de-allocated
upon return from that function, which makes the whole
exercise fairly useless!

This will be resolved eventually by implementing
inline functions, and making @code{]make-whatever}
inline.  In the meantime, one must use the 
slightly less elegant code sequence

@example
[ :ephemeral t   ... | 'whatever ]makeStructure
@end example

@noindent
to allocate an ephemeral structure.  For example,
to create an ephemeral saint which will vanish
when the expression completes execution, we may do:

@example
Stack:
[ :ephemeral t  :name "Patrick" | 'saint ]makeStructure -> s  s saint?
Stack: t
@end example

@emph{Ephemeral structures should be used with caution.}

In particular, they should never be passed to another
job, because that job will search its own stack for the
structure and either not find anything, or -- worse! --
find the wrong thing.  For the same reason, ephemeral
structures should seldom be stored into the database.
In general, you should only pass them as function
parameters and store them in local variables.

@xref{]defstruct,,,mufcore.t,Muf Reference}.

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Structures Wrapup

@c
@node  Structures Wrapup, Understanding Regular Expressions, Ephemeral Structures, Understanding Structures
@subsection Structures Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Understanding Arities

@c
@node Understanding Regular Expressions, Regex Overview, Structures Wrapup, Intermediate Muf Programming
@section Understanding Regular Expressions

@menu
* Regex Overview::
* Regex Wrapup::
@end menu

@c {{{ Regex Overview

@c
@node  Regex Overview, Regex Wrapup, Understanding Regular Expressions, Understanding Regular Expressions
@subsection Regex Overview

No, this isn't written yet.  It's not implemented
yet either :).

@c {{{endfold}}}
@c {{{ Regex Wrapup

@c
@node  Regex Wrapup, Understanding Arities, Regex Overview, Understanding Regular Expressions
@subsection Regex Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Understanding Arities

@c
@node Understanding Arities, Understanding Indices, Regex Wrapup, Intermediate Muf Programming
@section Understanding Arities

One particularly insidious class of bugs are those in which
a function trashes some stack slot that doesn't "belong" to
it, or returns one more value than expected, or such.

These bugs can be quite difficult to track down, since it
may be hundreds of nested subroutine calls later until the
problem triggers an error, by which time tracking down the
long-vanished culprit may be an arduous task indeed.

To help prevent such problems before they happen, Muq
@sc{muf} implements function@dfn{arities}.  ("Arity" is a
generalization of "unary", "binary", "trinary"...)  The
arity of a function is a synopsis of how many values it
accepts and returns on the stack.

Muq expects each function to have a fixed arity (to always
consume and return the same number of arguments), and it
normally computes this arity for each function as it
compiles it, and saves the result for future reference.  If
it finds an inconsistency, such as a function which
sometimes returns three values, and sometimes four, it will
issue an error message.

You can tell @sc{muf} what arity you think your function
has, and it will also issue an error message if it disagrees
with your opinion.  You can also tell it to accept some
arity for the function, and not bother checking itself.
This is sometimes useful in cases which @sc{muf} is not
smart enough to analyse itself.

The simplest arity-declaration syntax looks like:

@example
: x @{ $ $ -> $ @} * ;
@end example

This declares a function which accepts two values on the
stack, and returns one.  You may also declare functions
which operate on blocks:

@example
: |r @{ [] -> [] @} |reverse ;
@end example

A functions may have both block and scalar arguments:

@example
: |pr @{ [] $ -> [] @} |push |reverse ;
@end example

(In this case, the blocks must always precede the scalar
arguments, on both sides of the arrow.)

Some functions never return.  (They may loop forever, or
they may do a @code{throw} past the caller.)  The syntax
for declaring this looks like:

@example
: err @{ -> @@ @} [ "Woops! | ]throw-error ;
@end example

(Think of the '@@' as a black hole that the program falls
into.)

This is to be avoided where reasonably possible, but very
occasionally you may have a function which genuinely needs
to accept or return a variable number of arguments.  (The
@code{compile-@}} function in 00-Core-muf.muf is a
moderately good example.)  The syntax for declaring this is:

@example
: yikes @{ -> ? @} if pop fi ;
@end example

Even more rarely, you may have a function which deposits
or eats a '[':

@example
: my-[ @{ -> [ @} [ ;
: my-| @{ -> | @} | ;
: my-] @{ -> ] @} ] ;
@end example

Finally, if you want @sc{muf} to simply accept your declared
arity without checking, either because the function is
beyond @sc{muf}'s current ability to understand or because
you've found a good reason to lie to it, end your arity
declaration with a '!':

@example
: lie  @{ $ -> $ ! @} + ; ( It is really @{ $ $ -> $ @} )
: soon @{   -> @ ! @} ;   ( It's not finished, but won't return when done.)
@end example

@sc{future directions:}  I expect to eventually revamp
the compiler so that

@example
: x @{ a b -> c @}  a b + -> c ;
@end example

will work: The compiler will automatically pop @code{a} and
@code{b} into local variables with those names at the top of
the function, and push local variable @code{c} onto the
stack before returning.  I'm currently only allowing '$' for
scalar arguments in arity declarations, in order to leave
room for upgrading to this approach without breaking
existing @sc{muf} code at that point.

@c {{{endfold}}}
@c {{{ Understanding Indices

@c
@node Understanding Indices, Indices Overview, Understanding Arities, Intermediate Muf Programming
@section Packages

@menu
* Indices Overview::
* Keyval Pairs::
* Index Paths::
* Hidden Keyvals::
* Admins Keyvals::
* System Keyvals::
* Ownership and Groups::
* Keyval Iterators::
* Method Keyvals::
* Messages and Inheritance::
* Generic Functions::
* Indices Wrapup::
@end menu

@c {{{ Indices Overview

@c
@node  Indices Overview, Keyval Pairs, Understanding Indices, Understanding Indices
@subsection Indices Overview

"Object-oriented" has become such a fashional marketing
buzzword as to have virtually lost meaning altogether: By
now, one can probably purchase object-oriented toilet paper.

"Object-oriented" programming was originally intended as an
antidote to the "top-down Structured Programming" paradigm
in which attention was focused perhaps excessively upon the
decomposition of the code into nested subroutines, with
datastructures being treated as something of a neglected
stepchild.

"Object-oriented" programming represented an attempt to
reverse the mistake by instead focussing excessively on the
datastructures and treating code as an afterthought, clearly
a much healthier state of affairs @emph{grin}@dots{}

In particular, some goals of the object-oriented programming
paradigm were:

@itemize @bullet
@item
Structure the program state as various kinds of chunks:
@emph{objects} belonging to @emph{classes}.

@item
Implement important datastructures just once, and then
re-use that implementation over and over.

@item
Make programs more modular by strictly segratating code
according to the datastructure it works on and hiding
the details of that datastructure's implementation from
all other code in the system: @emph{implementation-hiding}.

@item
Group similar datastructures into hierarchies, and share
code used to implement common facilities, rather than
replicating it: @emph{inheritance}.

@item
Support abstract operations upon objects which
automatically do "the appropriate thing" for a
given object depending on its class: @emph{message-passing}.
@end itemize

Muq is not a strongly "object-oriented" system in the
classical sense outlined above, although the above sorts of
things can indeed be done, as we shall see later.

In this section, however, we are interested in "object" in
the very simplest sense, as a little package of information
which may be modified and referred to as a whole.

@c {{{endfold}}}
@c {{{ Keyval Pairs

@c
@node  Keyval Pairs, Index Paths, Indices Overview, Understanding Indices
@subsection Keyval Pairs

Muq thinks of objects primarily as a set of @dfn{keyValue pairs}:
as tables of named properties.  Thus, we might have an
object named 'Kim':

@example
Name:    Kim
Age:     12
Weight:  64
Hobby:   Drawing
Grade:   7
Marbles: 12
Bedroom: Messy
@end example

As you can see, a Muq object can be visualized very nicely
as a two-column table.  Given any @dfn{key}, such as "Name",
Muq can easily give you the corresponding value ("Kim").
(The reverse is not true: Given a value, Muq cannot quickly
find the matching key, and in fact there may not be a unique
matching key, as with @code{12} in this case.)

@quotation
@cartouche
Muq tries very hard to make every bit of information in the
system appear to be the value of some key on some object.
@end cartouche
@end quotation

By presenting all information in the metaphor of keyval
pairs on objects, we hope to be able to build powerful,
general object inspection and editing tools and then get
lots of mileage from them by being able to apply them to all
of the information in the Muq database.

In pursuit of this level of generality, Muq allows both keys
and values to be (almost) any value whatever which Muq knows
how to represent.  (The exceptions are a few obscure values
used internally which users are never supposed to see, such
as the internal "I can't find that key!" value.)

@c {{{endfold}}}
@c {{{ Index Paths

@c
@node  Index Paths, Hidden Keyvals, Keyval Pairs, Understanding Indices
@subsection Index Paths

Since object keyvals may contain any keys and values
whatever, we may in particular use objects as the values:

@example
Stack:
makeIndex --> a      ( Put a new object in variable 'a ' )
Stack:
makeIndex --> a.b    ( Next object goes under key 'b' on first object )
Stack:
makeIndex --> a.b.c  ( Next goes under key 'c' on second object. )
Stack:
12 --> a.b.c.d         ( Store 12 under key 'd' on third object. )
Stack:
a.b.c.d                ( Verify that we can retrieve above value. )
Stack: 12
@end example

Expressions such as @code{a.b.c.d} are merely convenient
shorthand which the Muq @sc{muf} compiler expands into
longer expressions: They don't let you do anything which you
could not do otherwise.  In particular, instead of writing
@code{a.b.c.d} we could have written:

@example
a :b get :c get :d get
@end example

(The latter is really much more in the spirit of @sc{muf},
really, but the former is so convenient that I couldn't
resist including it as an alternative.)

This syntactic convention, together with the ability to use
objects as key values, lets us build trees of objects within
the Muq database which provide an indexing system similar to
the hierarchical directory trees used in Unix and MS-Dos and
MacOs.

@c {{{endfold}}}
@c {{{ Hidden Keyvals

@c
@node  Hidden Keyvals, Admins Keyvals, Index Paths, Understanding Indices
@subsection Hidden Keyvals

Data privacy is an important issue in most multi-user systems.

Muq meets this need by equipping objects with an area for
hidden keyvals visible only to the owner of the object.
This area is otherwise identical to the area in which public
keyvals are stored, and is accessed by using @code{$h.} of
instead of @code{.} as the object/key separator. 

@example
Stack:
makeIndex --> a      
Stack:
makeIndex --> a$h.b     ( Hidden key :b on obj a. )
Stack:
makeIndex --> a$h.b$h.c  ( Hidden key :c on obj a$h.b. )
Stack:
13 --> a$h.b$h.c$h.d        ( Hidden key :d on obj a$h.b$h.c. )
Stack:
a$h.b$h.c$h.d
Stack: 13                ( Sure enough! )
@end example

Again, the final expression could be coded "by hand" if
we wanted:

@example
Stack:
a :b hiddenGet :c hiddenGet :d hiddenGet
@end example

@c {{{endfold}}}
@c {{{ Admins Keyvals

@c
@node  Admins Keyvals, System Keyvals, Hidden Keyvals, Understanding Indices
@subsection Admins Keyvals

As every chocolate lover knows, it is impossible to have too
much of a good thing!  Having once introduced the notion of
having separate keyval areas on an object, more applications
of the idea quickly suggest themselves.

For example, it is not only users who need to have private
data.  The administrators of the server may wish to place
data on an object and have it visible only to them.  For
example, storing things like encrypted user passphrases on the
user object makes sense, because it means that they
automatically get recycled when the user object is recycled,
saving the bother of running round finding and deleting that
information from various system tables.  But it may be best
to let not even the user have access to the encrypted
passphrase, since it may make it too simple for naughtyfolk
taking advantage of an unattended terminal.

Why not a private space on each object for admins?

Why not, indeed!  Muq provides access to such an area
via the @code{$a.} object.key separator.  You will
need to be connected as Root to do this example:

@example
Stack:
makeIndex --> a      
Stack:
makeIndex --> a$a.b      ( Admins key :b on obj a. )
Stack:
makeIndex --> a$a.b$a.c  ( Admins key :c on obj a$a.b. )
Stack:
14 --> a$a.b$a.c$a.d       ( Admins key :d on obj a$a.b$a.c. )
Stack:
a$a.b$a.c$a.d
Stack: 14                  ( Well, well@dots{} )
@end example

The hand-coding for the final expression is:

@example
Stack:
a :b adminsGet :c adminsGet :d adminsGet
@end example

@c {{{endfold}}}
@c {{{ System Keyvals

@node  System Keyvals, Ownership and Groups, Admins Keyvals, Understanding Indices
@subsection System Keyvals

Muq objects have various special hardwired properties on
them, such as their owner, class, creation date and time,
and so forth.  Keeping these in a separate @dfn{system area}
on the object keeps them out of the way when they are not of
interest, and makes them easy to find when they are.

Muq provides access to this area via the @code{$s.} object/key
separator.  (Do @code{.muq lss} or @code{.sys lss} for examples of
interesting system values.)

Thus, you will also need to be connected as Root to do this
example:

@example
Stack:
makeIndex --> a      
Stack:
makeIndex --> a$s.b     ( System key 'b' on obj a. )
Stack:
makeIndex --> a$s.b$s.c ( System key 'c' on obj a$s.b. )
Stack:
15 --> a$s.b$s.c$s.d      ( System key 'd' on obj a$s.b$s.c. )
Stack:
a$s.b$s.c$s.d
Stack: 15                 ( Surprise? )
@end example

The hand-coding for the final expression is:

@example
a :b systemGet :c systemGet :d systemGet
@end example

@c {{{endfold}}}
@c {{{ Ownership and Groups

@c
@node  Ownership and Groups, Keyval Iterators, System Keyvals, Understanding Indices
@subsection Ownership and Groups

This isn't really implemented yet, so I won't
venture to discuss it :)

@c {{{endfold}}}
@c {{{ Keyval Iterators

@c
@node  Keyval Iterators, Method Keyvals, Ownership and Groups, Understanding Indices
@subsection Keyval Iterators

Where there is a collection of values, there is a programmer
trying to iteratively process them all: When implementing a
new type of collection, it is usually a good idea to
implement nice facilities for iterating over them as well.

The Muq primitive functions for iterating over the public
properties on an object are

@example
getFirstKey??   @{ obj          -> found? firstKey @}
getNextKey??    @{ obj last-key -> found? nextKey  @}
@end example

@noindent
where @code{obj} is the object over which we are iterating,
@code{found?} is @code{nil} unless a first/next key existed,
@code{last-key} is the key to which a successor is desired,
and @code{firstKey} and @code{nextKey} are the next key to
use in the iteration.

Using the above, we may write a loop to list out all the
public properties on an object:

@example
: list @{ $ -> @}
    -> obj                    ( Save given object.          )
    obj getFirstKey?? do@{    ( Get first found?/key pair.  )
        -> key                ( Save key, if we have one.   )
       while                  ( Exit loop if found? is nil. )
       key , "\n" ,           ( List the key.               )
       obj key getNextKey??  ( Try to get the next key.    )
    @}
;
@end example

The above is workable, but hardly a model of beauty, clarity
or conciseness, so Muq @sc{muf} provides a control structure
to encapsulate the above in sweeter syntax:

@example
: list @{ $ -> @}
    -> obj                    ( Save given object.          )
    obj foreach key do@{       ( Get first found?/key pair.  )
       key , "\n" ,           ( List the key.               )
    @}
;
@end example

The latter compiles into almost exactly the same code as
the former, but suppresses a lot of the detail work.  So
much so that if you're in to mood, you can now fit the
function on one line:

@example
: list foreach key do@{ key , "\n" , @} ;
@end example

As a further convenience, @code{foreach} will iterate
through the values of the keys as well, if you wish:

@example
: list foreach key val do@{ key , "\t" , val , "\n" , @} ;
@end example

(The above function is available in the standard library as @code{ls}.)

Analogs of the above are available for each area in an
object.  For example, @code{hiddenGetFirstKey??} and
@code{hiddenGetNextKey??} are the prims iterating over the
hidden keyvals in an object, and @code{foreachHidden} is
the high-level loop which encapsulates them more prettily.
@xref{keyval functions,,,mufcore.t,Muf Reference}.

Prims also exist to push all the keys and/or vals in an object on the
stack as a block: @xref{keys[,,,mufcore.t,Muf Reference},
@xref{vals[,,,mufcore.t,Muf Reference}, @xref{keysvals[,,,mufcore.t,Muf Reference}.

@c {{{endfold}}}
@c {{{ Method Keyvals

@c
@node  Method Keyvals, Messages and Inheritance, Keyval Iterators, Understanding Indices
@subsection Method Keyvals

Muq uses prototype-oriented facilities in which
messages may be individually implemented on each object
simply by placing anonymous functions in the method keyval
area, accessed by @code{/:/} object/key separator syntax.

This approach is simpler and more flexible than the
classical class-based approach, which admittedly can be
compiled into more compact and efficient code, and hence is
more appropriate for a systems implementation langauge such
as C++.

@c {{{endfold}}}
@c {{{ Messages and Inheritance

@c
@node  Messages and Inheritance, Generic Functions, Method Keyvals, Understanding Indices
@subsection Messages and Inheritance

To be written.

@c {{{endfold}}}
@c {{{ Generic Functions

@c
@node  Generic Functions, Indices Wrapup, Messages and Inheritance, Understanding Indices
@subsection Generic Functions

CommonLisp introduced the very nice concept of generic
functions, which look (and in fact really are) just like
normal functions to the caller, but which internally
dispatch to the appropriate method based on the parameter
values.

This allows message-passing to be used anywhere a function
is permitted, and to take advantage of all system facilities
constructed to support use of functions, which is much more
elegant than having a special distinguished syntax used for
sending messages.

Muq implements message-passing functionality by having folks do

@example
:: + ; --> obj/:/plus
@end example

in order to establish a method, and having the system automatically
create a corresponding generic function @code{plus} if one does not
already exist: The generic function has the same arity as the method,
and future @code{plus} methods that can ``see'' this generic (due to
being in a package in which the generic is accessable) are required to
have the same arity.

Internally, these generic functions would look like something like

@example
: generic @{ ... $ -> ... ! @} -> recipient
    recipient findMethod -> method
    method call
;
@end example

@noindent
where @code{findMethod} is a function which implements
inheritance of methods by searching up the parent chain (or
tree) of the first argument to the function.

@c {{{endfold}}}
@c {{{ Indices Wrapup

@c
@node  Indices Wrapup, Understanding Packages, Generic Functions, Understanding Indices
@subsection Indices Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Understanding Packages

@c
@node Understanding Packages, Packages Overview, Indices Wrapup, Intermediate Muf Programming
@section Understanding Packages

@menu
* Packages Overview::
* Understanding Symbols::
* Understanding Interned Symbols::
* Understanding Exported Symbols::
* Understanding Used Packages::
* Understanding Nicknames::
* Understanding Package Selection::
* Understanding Constants::
* Understanding Keywords::
* Packages Wrapup::
@end menu

@c {{{ Packages Overview

@c
@node  Packages Overview, Understanding Package Selection, Understanding Packages, Understanding Packages
@subsection Packages Overview

"Programming in the large" involves quite different issues
from "programming in the small" (which concerns itself with
such things as syntax, control structure and data
structures): The over-riding concern of programming in the
large is the division of the program as a whole into modules
which are simple enough, and isolated enough, to be
comprehended and maintained.

One of the key Muq tools provided to support programming in
the large is the @dfn{package}, a construct which the Lisp
community has developed and refined through decades of
experimentation and experience.  Muq packages allow you to
group together a related set of functions and data
structures, to provide a name (in fact, several names) for
the complete assemblage, to specify which components are
intended for direct external use (versus which are intended
to be hidden internal support), and to identify in a
convenient and structured way the other packages needed by a
given package.

Muq packages can be used to implement code libraries,
encapsulate application programs, delimit personal
workspaces, and meet a myriad other needs to group functions
and/or data conveniently.

@c {{{endfold}}}
@c {{{ Understanding Package Selection

@c
@node  Understanding Package Selection, Understanding Symbols, Packages Overview, Understanding Packages
@subsection Understanding Package Selection

At any given time, you are "in" one particular package, that
indicated by @code{@@$s.package}: All variables which you
create -- and all functions which you define -- are placed
in this package, and all functions and variables "in" that
package are available to you for unqualified access.

In addition, you have at any given time some set of packages
which are considered to be "available" to you.  (CommonLisp
specifies that there should be a single such set, but it is
a single-user system, and this does not seem terribly
practical in a multi-user system, so Muq instead provides
one such set per user, optionally per job.)  This set is
indicated by @code{@@$s.lib}, and may be listed by doing:

@example
@@$s.lib ls
@end example

You may create a new set of "available" packages by creating
a new object and setting @code{@@$s.lib} to point to it (if
you want the effect to be permanent you should also set
@code{~$s.lib} to it) and then entering the desired packages
into it.  You should not normally have occasion to do this,
however.

As you switch from project to project (at the least) you
will usually switch from package to package, which is
normally done using the @code{inPackage} command, which
finds the package with the given name (creating it if no
such package exists in @code{@@$s.lib} points
@code{@@$s.package} to it.

The interactive @sc{muf} prompt, which we give as "Stack:"
in our examples, is actually the name of the current
package.

@c {{{endfold}}}
@c {{{ Understanding Symbols

@c
@node  Understanding Symbols, Understanding Interned Symbols, Understanding Package Selection, Understanding Packages
@subsection Understanding Symbols

The Muq @dfn{symbol} is borrowed directly from Lisp, which
has been refining the concept for half a century now. Lisp
symbols are vaguely equivalent to the "external identifiers"
of languages like C in that they provide global (to the
current package, at least) names for important functions and
datastructures.

The only datastructure components in very early Lisps were
symbols and cons cells:  Cons cells provided a way to
build up complex structures and associations, while symbols
provided stopping points in this graph, points of reference
which could be given names and values.  These early symbols
were datastructures in memory containing a single slot,
which pointed to a @dfn{property list} of keyValue pairs:

@example
    Symbol            Property List of Cons Cells
   +-------+          +---------------+
   |   o --------->   |   o   |  o--------->  key0
   +-------+          +---|-----------+
                          v
                      +---------------+
                      |   o   |  o--------->  val0
                      +---|-----------+
                          v
                      +---------------+
                      |   o   |  o--------->  val1
                      +---|-----------+
                          v
                      +---------------+
                      |       |  o--------->  val1
                      +---------------+
@end example              

Typical keyvals found in the property list were the
print-name of the symbol, the value of the symbol considered
as a variable (if any), and the value of the symbol
considered as a function (if any).

Lisp very early acquired a reputation as a very slow
language which consumed inordinate amounts of memory, and
implementation techniques such as the above were part of the
reason.

It didn't take too long to conclude that the Lisp
interpreter would both run faster and take less memory if
the most frequently used property list values were stored
directly in reserved slots in the symbol instead of on the
property list, leading to a datastructure looking like:

@example
    Symbol            
   +-------+          
   |   o --------->   Print name of symbol
   +-------+          
   |   o --------->   Value as a variable
   +-------+          
   |   o --------->   Value as a function
   +-------+          
   |   o --------->   Package owning symbol
   +-------+          +---------------+
   |   o --------->   |   o   |  o--------->  key0
   +-------+          +---|-----------+
                          v
                      +---------------+
                      |   o   |  o--------->  val0
                      +---|-----------+
                          v
                      +---------------+
                      |   o   |  o--------->  val1
                      +---|-----------+
                          v
                      +---------------+
                      |       |  o--------->  val1
                      +---------------+
@end example              

(With the most frequently used values moved into the symbol
itself, the property list is no longer as heavily used as it
once was, but it is still available.  @xref{symbolPlist,,,mufcore.t,Muf Reference},
@xref{setSymbolPlist,,,mufcore.t,Muf Reference}.)

So, a Muq symbol is essentially a vector with slots reserved
to hold its name, value as a variable, value as a function,
home package, and property list.  (Modern compiled Lisps may
actually implement symbols in a variety of different ways,
including techniques essentially indistinguishable from
those used by conventional C compilers, but Muq sticks with
the traditional implementation technique.)  Functions are
available to read and write most of these slots individually
when you need to: @xref{symbol functions,,,mufcore.t,Muf Reference}.

A Muq package is really little more than a Muq object all of
whose public and hidden keyval pairs "happen" to have
symbols for their value half.  In particular, you may
iterate over all the symbols in a package using the
normal object iterators:

@example
( List all variables in the current package: )
: lv @{ -> @}
    @@$s.package foreachHidden key val do@{
        val symbolValue -> val
        val if key , "\t" , val , "\n" , fi
    @}
;
@end example

@c {{{endfold}}}
@c {{{ Understanding Interned Symbols

@c
@node  Understanding Interned Symbols, Understanding Exported Symbols, Understanding Symbols, Understanding Packages
@subsection Understanding Interned Symbols

Symbols do not need to belong to a package.  For example,
@code{#:plugh} will create an "uninterned" symbol named
"plugh" which is a member of no package.

Symbols may also be "in" more than one package (although
they may never have more than one official "home package",
that indicated in their internal @code{package} slot): This
just means that more than one package has an entry for them.

Entering a symbol into a package is called "interning" it in
Lisp jargon, presumably because this makes the symbol
"internal" to that package.

The function @code{intern} may be used to create an interned
symbol with the given name in the current package: It
returns the existing symbol of that name if such exists,
otherwise creates one and returns it.  @xref{intern,,,mufcore.t,Muf Reference}.

The function @code{unintern} removes a symbol from the
current package; It can be handy for removing unwanted
variables and functions, perhaps created by mistake.

@c {{{endfold}}}
@c {{{ Understanding Exported Symbols

@c
@node  Understanding Exported Symbols, Understanding Used Packages, Understanding Interned Symbols, Understanding Packages
@subsection Understanding Exported Symbols

When you do

@example
13 --> *count*
@end example

@noindent
you create a symbol named @code{*count*} in the current
package (assuming no such symbol previously existed) and put
@code{13} in its value slot.  (It is good Muq programming
style to put asterisks around the name of a global
variable.)

When you do

@example
: thirteen 13 ;
@end example

@noindent
you create a symbol named @code{thirteen} in the current package
and put @code{:: 13;} in its function slot.

When you do

@example
'abc
@end example

@noindent
you create a symbol named @code{abc} in the current package.

In all of these cases (and more), the symbols created are
entered in the hidden area of the current package, and are
considered private to that package.  (They can be accessed
from other packages by using the package-name::symbolName
syntax, but this is intended as a hack for debugging and
such, not as something which should be done as a part of
normal use of the package.)

Use the @code{export} function to make a symbol (and hence
any value, function, or property list associated with it)
publicly available in the package:

@example
'*count*  export
'thirteen export
'abc      export
@end example

This enters the given symbol into the public area of the
current package, making it accessable (for example) via
@code{package-name:symbolName} notation.

You may use @code{lxf} (List eXported Functions) to list
exported symbols in the current package which have their
function slot set; You may use @code{lxv} (List eXported
Variables) to list exported symbols in the the current
package which have their value slot set.

If you @code{export} a symbol by mistake, you may undo the
effect using @code{unexport}.  @xref{unexport,,,mufcore.t,Muf Reference}.

It is good programming practice to group all the
@code{export} statements in a source file together, often
right after the @code{inPackage} line, and accompanied by
comments explaining the intended use of the exported symbol.
These comments may often be all the user of a package needs
to know about it.

@c {{{endfold}}}
@c {{{ Understanding Used Packages

@c
@node  Understanding Used Packages, Understanding Nicknames, Understanding Exported Symbols, Understanding Packages
@subsection Understanding Used Packages

It has been said that software is truly successful when it
begins to be used for things that the implementors never
expected.

One kind of Muq package is the @dfn{library}: A package of
canned functionality intended to be used by other Muq
packages.

It is possible to take advantage of libraries simply by
accessing their exported functions via colon syntax as
@code{lib-x:fn-a}, @code{lib-y:fn-b} and so forth, but such
use of package-name prefixes can be wearisome if the library
functions are frequently used.

An alternative is to do

@example
"lib-y" usePackage
@end example

@noindent
This permanently enters package @code{lib-y} into
@@$s.package$s.usedPackages, making all exported symbols in
@code{lib-y} available inside the current package just as
though they were internal.

This does mean, of course, that the current package must not
have any symbols with the same name as an exported symbol in
@code{lib-y}, nor may @code{lib-y} have any exported symbol
with the same name as any other exported symbol in any other
package already used by the current package.

The @code{unusePackage} function may be used to undo the
effect of an @code{usePackage}: @xref{unusePackage,,,mufcore.t,Muf Reference}.

@c {{{endfold}}}
@c {{{ Understanding Nicknames

@node  Understanding Nicknames, Understanding Constants, Understanding Used Packages, Understanding Packages
@subsection Understanding Nicknames

It is desirable for packages to have self-explainatory names
such as "mudShell", but lazy programmers may ofter prefer
typing "ms:fn" to typing "mudShell:fn": To reduce needless
bloodshed, Muq supports package @dfn{nicknames}, additional
names for a given package.

The simplest way to assign nicknames to a package is to
replace the usual

@example
"mudShell" inPackage
@end example

@noindent
line creating and selecting the package in the source file
with a line like

@example
[ "mudShell" "ms" "new-shell" | ]inPackage
@end example

@noindent
The first name given becomes the official name of the
package if it is created; the remaining names become
nicknames, stored in @@$s.package$s.nicknames.

Also, @xref{]renamePackage,,,mufcore.t,Muf Reference}.

@c {{{endfold}}}
@c {{{ Understanding Constants

@node  Understanding Constants, Understanding Keywords, Understanding Nicknames, Understanding Packages
@subsection Understanding Constants

You are likely to find your programs using some values which
are never intended to change.  For example, pi has been
@code{3.14159265...} for a very long time, despite the best
efforts of biblical writers and American legislators to
change it to a more convenient value.

You may aid both human and mechanical readers of you code by
explicitly declaring such values to be constants: This saves
human readers the work of deducing that they never change,
and allows compilers to produce more efficient code by
omitting checks to see if the value has changed.

The Muq @sc{muf} syntax for establishing a constant is

@example
3.1416 -->constant pi
@end example

@noindent
This does everything that

@example
3.1416 --> pi
@end example

@noindent
does, and then in addition sets a flag making it
an error to modify this value.  (This flag is
currently implemented by setting the function
value of the symbol to zero, but you should not
write code to depend on this fact, nor is it
immediately visible.)

You may actually change the value of such a constant using
another @code{-->constant} instruction, but this exception
is intended only to simplify reloading a source file after
editing it: Using this to modify a constant inside a program
is likely to have unexpected effects unless you are very
careful to subsequently recompile all code which "knows" the
value of the constant.

@c {{{endfold}}}
@c {{{ Understanding Keywords

@node  Understanding Keywords, Packages Wrapup, Understanding Constants, Understanding Packages
@subsection Understanding Keywords

Smalltalk has a class UniqueString of strings, which
guarantees that no two "distinct" (that is, having different
memory addresses) UniqueStrings contain the same characters
in the same order (that is, are equal in a visual, textual
sense).  UniqueStrings take longer to create than vanilla
strings, but can be a useful efficiency hack in that they
may be sorted, compared and looked up using fast integer
operations on their addresses, rather than slow
character-by-character comparisons of their contents.

The Lisp @dfn{keyword} serves a similar purpose: While there
may be many symbols with a given name (albeit at most one
per package), there can be at most one keyword with a given
name.  Keywords thus provide a Muq-global vocabulary of
symbols which may be distinguished at a glance by humans and
in a machine cycle by computers, useful as property names,
object keys, as readable special values for variables, and
in general anywhere that efficiently distinguishable names
are handy.

@quotation
@cartouche
Since keywords form a global resource and cannot easily be
recycled once created, it is best to avoid creating large
numbers of keywords: Use strings or uninterned symbols
instead if you need temporary values.
@end cartouche
@end quotation

Keywords are kept in the special package
@code{.lib.keyword}.  All keywords are constants, all are
exported from the keyword package, and all keywords have
themselves as their value (meaning that is is never
necessary to explicitly quote them).

@c If you change the following @samp{}s to @code{}s,
@c TeX complains about an overful hbox.  Why?
To make keywords syntactically more convenient, they are
written @samp{:xyzzy} rather than @samp{keyword:xyzzy}.
This is a special hardwired exception to the general symbol
naming and printing rules.

The entire keyword package is a very special hardwired hack:
You should never enter non-keyword symbols into it,
@code{unexport} keyword symbols, or indeed directly do much
of anything with it.

Keywords are normally created simply by mentioning them by
name in code: @code{:my-name} or such.

Use keywords when you need an efficient vocabulary global to
the database, efficiently usable without confusion from any
package, independent of @code{usePackage} settings.

@c {{{endfold}}}
@c {{{ Packages Wrapup

@c
@node  Packages Wrapup, Understanding Jobs, Understanding Keywords, Understanding Packages
@subsection Packages Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Understanding Jobs

@c
@node Understanding Jobs, Jobs Overview, Packages Wrapup, Intermediate Muf Programming
@section Understanding Jobs

@menu
* Jobs Overview::
* von Neuman Machines::
* Turing Machines and Lambda Calculus::
* Understanding Job State::
* Understanding Exception Handling::
* Understanding Streams::
* Understanding Job Queues::
* Understanding Job Creation::
* Understanding Signals::
* Understanding Sockets::
* Understanding Transactions::
* Jobs Wrapup::
@end menu

@c {{{ Jobs Overview

@c
@node  Jobs Overview, von Neuman Machines, Understanding Jobs, Understanding Jobs
@subsection Jobs Overview

Facilitating human communication is a central design goal of
Muq: Muq is intended to support the creation of systems in
which many people interact in complex, unpredictable way
facilitated by power tools -- software, both system
libraries and personal customizations that adapt the system
to particular needs and interests.

A single Muq must thus be able to appear to be providing
uninterrupted computation resources to dozens or even
hundreds of users "at the same time": It must appear to
support some computational paradigm in which different
computational activities are going on in parallel.

There are many conceptual models for parallel computation,
but as yet the only one to achieve widespread practical
success is the time-sharing approach in which each user is
in essence given an individual "virtual machine", and the
many virtual machines thus created are animated by having
the single underlying physical machine run each virtual
machine in sequence for a brief time (perhaps a hundredth of
a second) and then switch to the next, producing the
illusion to slow-witted humans that all of them are running
smoothly in parallel much as movies produce the illusion of
continuously moving images by rapidly flashing still images
on a screen for a few hundredths of a second each.  In
computerese, this is called "timesharing by pre-emptive
multitasking".

A Muq @dfn{job} represents such a virtual machine.  Each Muq
job constitutes a software simulation of a simple little
computer, complete with input and output channels leading to
a user (usually), stacks holding data values and return
addresses, compiled functions containing program
instructions in a virtual instruction set, and a virtual
"program counter" recording where just where in the program
this virtual machine is at the moment.

The Muq server may contain hundreds or thousands of these
"jobs" at any given instant, some waiting for their user to
type a command for them, some waiting for their user's
terminal to accept output text, some sleeping, some paused
waiting to be told to resume computation, and some number
ready to proceed with computation.  The Muq server keeps all
existing jobs neatly pigeonholed in different queues
according to such state information, and busily cycles
between all jobs marked as ready to run, running them one
after another for a short period of time, trying hard to
maintain the illusion that they are all running
continuously.

In essence, Muq is a tiny operating system all by itself:
because of this, network servers of this sort of design are
often called "virtual operating systems".

In this section we will examine the functions which Muq
provides to create and destroy jobs, to allow communication
and synchronization between them, and for monitoring and
modifying their execution.

As of Muq version -1.5.0, these facilities are still under
active development:  Neither they nor this discussion are
particularly complete.

@c {{{endfold}}}
@c {{{ von Neuman Machines

@c
@node  von Neuman Machines, Turing Machines and Lambda Calculus, Jobs Overview, Understanding Jobs
@subsection von Neuman Machines

(This and the next node contain historical and conceptual
background which the terminally impatient may wish to skip.)

Johnny von Neuman introduced what has come to be called the
"von Neuman architecture" for computers on one of the first
vacuum-tube computers, and despite much grumbling and many
attempts to dethrone it, it has remained the mainstay of
computing ever since.

The essential components of the von Neuman architecture
are:

@itemize @bullet
@item
A single data store of addressable elements containing
both the information to be operated upon and the
instructions specifying the operations to be performed.

@item
A pointer called the @dfn{program counter} designating
the instruction currently being executed.

@item
Some sort of machinery which repeatedly changes the data store
as specified by the current instruction, and then modifies
the program counter to point to a new instruction.
@end itemize

@c {{{endfold}}}
@c {{{ Turing Machines and Lambda Calculus

@c
@node  Turing Machines and Lambda Calculus, Understanding Job State, von Neuman Machines, Understanding Jobs
@subsection Turing Machines and Lambda Calculus

One of the surprising results from mathematical analysis of
computation (generally credited independently to Alan Turing
and Alonzo Church) is that a very simple machine of the von
Neuman variety (or of any one of many similar designs,
including for example Conway's ingenious Game of Life, a
cellular automaton popular nowadays as a computer screen
saver) is capable of computing anything which we know any
way at all of computing.

For example, it is quite possible to build a machine of this
sort with only one or two instructions (which perhaps
respectively read two bits and store back the negated OR of
them, and conditionally select one of two possible next
instructions depending on the value of a given bit) which is
quite capable of performing any computation we might want.
Almost all the instructions contained in modern computers
are logically unneccessary: They are included only to speed
up specific common operations, such as addition.

Turing's proof that a given machine is a @dfn{Universal
Turing Machine}, capable of computing anything which can be
computed at all, is quite simple in concept, reducing to
showing that such a machine can be programmed to emulate
perfectly any other machine which you can describe
precisely, and hence can compute whatever the described
machine could compute.

Alonzo Church worked in a more mathematical setting,
developing a simple abstract @dfn{lambda calculus}, and then
similarly showing that any other computational scheme could
be described in terms of it.

Turing's proof has an intuitively pleasing nuts-and-bolts
quality to it that made it more immediately appealing and
popular: To this day we speak of "Universal Turing Machines"
rather than (say) "Lambda Calculus Isomorphism".  (Turing's
name also produces better puns about Universal Touring
Machines@dots{})

Church's lambda calculus has however perhaps had a deeper
and more significant impact:

@itemize @bullet
@item
It provided the
conceptual substrate for @dfn{denotational semantics}
(perhaps the most promising, comprehensive and rigorous
technique for describing what programming languages
"mean").

@item
It inspired the field of pure-functional
programming, probably the currently the promising line
of research in programming language design.  ("Haskell"
appears likely to be to functional programming what
Smalltalk was to object-oriented programming: The
proof-of-concept implementation that moves the idea
from the lab into mainstream consciousness.)

@item
It influenced the creation of Lisp, as witness the "lambda"
syntax used to this day in Lisp  -- although John McCarthy,
inventor of Lisp, strenuously denies that Lisp was ever
intended to be an implementation of the lambda calculus.
@end itemize

Since Muq @sc{muf} is in turn based heavily on Lisp, it can
be reasonably argued that anyone programming in Muq @sc{muf}
owes a considerable intellectual debt to both Alan Turing's
proof, with his abstract "Turing Machines" which led to the
underlying computer architecture, and to Church's proof,
which led to the underlying software architecture.

Both proofs were of course at the time considered to be
exercises in "pure mathematics", devoid of any practical
application @emph{grin}.

@c {{{endfold}}}
@c {{{ Understanding Job State

@c
@node  Understanding Job State, Understanding Exception Handling, Turing Machines and Lambda Calculus, Understanding Jobs
@subsection Understanding Job State

Muq jobs, as the central representation of a computation in
progress, are decorated with a remarkable profusion of
variables@footnote{Sixty-five in Muq -1.5.0!} intended to
allow you to customize and control the computation as it
proceeds, but there are only a handful of conceptually
critical job components:

@itemize @bullet
@item
The @dfn{executable} slot points to the function which is
currently being executed by the job.

@item
The @dfn{programCounter} slot points to the particular
instruction being executed within the current function.

@item
The @dfn{dataStack} slot pointing to the programmer
visible stack on which function parameters are passed
and expressions evaluated.

@item
The @dfn{loopStack} slot pointing to the stack
containing return addresses to the function which
called the current function, the function which
called that function, and so forth.  (Local
variables also live on this stack.)
@end itemize

(The @code{programCounter} and @code{executable} slots
could in principle be a single value, except that for purely
technical reasons Muq does not allow pointers into the
interior of an object, only to the top of the object.)

These four job slots are critical to the operation of Muq
jobs, and we will be returning repeatedly to them.

The remaining job object slots are frills by comparison,
implementing various bookkeeping, protection and
customization needs: One could eliminate any of them and
have a recognizable and useful Muq implementation.

You may do @code{@@ lss} to list these various properties.
@xref{Class Job,,,muqclass.t, Muf Reference}.

You should not try to memorize the above properties at this
point.  The important understanding to take with you from
this section is that Muq can contain many Jobs and that each
Job is conceptually a separate little computer running in
parallel with all the rest, reading user input and producing
output.

Later, we will see that you can create new Jobs by the dozen
if you wish, and that you can hook them together into
cooperative networks to compute results more conveniently
than can be done using a single Job.

@c {{{endfold}}}
@c {{{ Understanding Exception Handling

@c
@node  Understanding Exception Handling, Understanding Streams, Understanding Job State, Understanding Jobs
@subsection Understanding Exception Handling

@c {{{endfold}}}
@c {{{ Understanding Streams

@c
@node  Understanding Streams, Understanding Job Queues, Understanding Exception Handling, Understanding Jobs
@subsection Understanding Streams

@c {{{endfold}}}
@c {{{ Understanding Job Queues

@c
@node  Understanding Job Queues, Understanding Job Creation, Understanding Streams, Understanding Jobs
@subsection Understanding Job Queues

@c {{{endfold}}}
@c {{{ Understanding Job Creation

@c
@node  Understanding Job Creation, Understanding Signals, Understanding Job Queues, Understanding Jobs
@subsection Understanding Job Creation

@c {{{endfold}}}
@c {{{ Understanding Signals

@c

@c 
@node  Understanding Signals, Understanding Sockets, Understanding Job Creation, Understanding Jobs
@subsection Understanding Signals

@c {{{endfold}}}
@c {{{ Understanding Sockets

@c

@node  Understanding Sockets, Understanding Transactions, Understanding Signals, Understanding Jobs
@subsection Understanding Sockets

@c {{{endfold}}}
@c {{{ Understanding Transactions

@c

@node  Understanding Transactions, Jobs Wrapup, Understanding Sockets, Understanding Jobs
@subsection Understanding Transactions

@c {{{endfold}}}
@c {{{ Jobs Wrapup

@c
@node  Jobs Wrapup, Understanding Lists, Understanding Transactions, Understanding Jobs
@subsection Jobs Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Understanding Lists

@c
@node Understanding Lists, Lists Overview, Jobs Wrapup, Intermediate Muf Programming
@section Understanding Lists

@menu
* Lists Overview::
* The Cons Cell::
* Lists As Binary Trees::
* Lists As N-ary Trees::
* Lists As Digraphs::
* Creating Lists::
* List Sharing::
* Operations On Lists::
* Destructive Operations On Lists::
* Property Lists::
* Association Lists::
* Lists Wrapup::
@end menu

@c {{{ Lists Overview

@c
@node  Lists Overview, The Cons Cell, Understanding Lists, Understanding Lists
@subsection Lists Overview

@c {{{endfold}}}
@c {{{ The Cons Cell

@c
@node  The Cons Cell, Lists As Binary Trees, Lists Overview, Understanding Lists
@subsection The Cons Cell

@c {{{endfold}}}
@c {{{ Lists As Binary Trees

@c
@node  Lists As Binary Trees, Lists As N-ary Trees, The Cons Cell, Understanding Lists
@subsection Lists As Binary Trees

@c {{{endfold}}}
@c {{{ Lists As N-ary Trees

@c
@node  Lists As N-ary Trees, Lists As Digraphs, Lists As Binary Trees, Understanding Lists
@subsection Lists As N-ary Trees

@c {{{endfold}}}
@c {{{ Lists As Digraphs

@c
@node  Lists As Digraphs, Creating Lists, Lists As N-ary Trees, Understanding Lists
@subsection Lists As Digraphs

@c {{{endfold}}}
@c {{{ Creating Lists

@c
@node  Creating Lists, List Sharing, Lists As Digraphs, Understanding Lists
@subsection Creating Lists

@c {{{endfold}}}
@c {{{ List Sharing

@c
@node  List Sharing, Operations On Lists, Creating Lists, Understanding Lists
@subsection List Sharing

@c {{{endfold}}}
@c {{{ Operations On Lists

@c
@node  Operations On Lists, Destructive Operations On Lists, List Sharing, Understanding Lists
@subsection Operations On Lists

@c {{{endfold}}}
@c {{{ Destructive Operations On Lists

@c
@node  Destructive Operations On Lists, Property Lists, Operations On Lists, Understanding Lists
@subsection Destructive Operations On Lists

@c {{{endfold}}}
@c {{{ Property Lists

@c
@node  Property Lists, Association Lists, Destructive Operations On Lists, Understanding Lists
@subsection Property Lists

@c {{{endfold}}}
@c {{{ Association Lists

@c
@node  Association Lists, Lists Wrapup, Property Lists, Understanding Lists
@subsection Association Lists

@c {{{endfold}}}
@c {{{ Lists Wrapup

@c
@node  Lists Wrapup, Understanding Muf Macros, Association Lists, Understanding Lists
@section Lists Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Understanding Muf Macros

@c
@node Understanding Muf Macros, Muf Macros Overview, Lists Wrapup, Intermediate Muf Programming
@section Understanding Muf Macros

@menu
* Muf Macros Overview::
* Muf Macros Wrapup::
@end menu

@c {{{ Muf Macros Overview

@c
@node  Muf Macros Overview, Muf Macros Wrapup, Understanding Muf Macros, Understanding Muf Macros
@subsection Muf Macros Overview

@c {{{endfold}}}
@c {{{ Muf Macros Wrapup

@c
@node  Muf Macros Wrapup, Understanding Coding Style, Muf Macros Overview, Understanding Muf Macros
@section Muf Macros Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Understanding Coding Style

@c
@node Understanding Coding Style, Coding Style Overview, Muf Macros Wrapup, Intermediate Muf Programming
@section Understanding Coding Style

@menu
* Coding Style Overview::
* Comment Style::
* Identifier Style::
* Coding Style Wrapup::
@end menu

@c {{{ Coding Style Overview

@c
@node  Coding Style Overview, Comment Style, Understanding Coding Style, Understanding Coding Style
@subsection Coding Style Overview

@c {{{endfold}}}
@c {{{ Comment Style

@c
@node  Comment Style, Identifier Style, Coding Style Overview, Understanding Coding Style
@section Comment Style

A point very difficult to convey to novice programmers is
that programs don't just get compiled and run: They get read
and modified by humans.  The ultimate efficiency and
reliability of a program depend heavily on how easily the
program can be read and understood: People making changes
have limited time and energy, and after some amount of
effort spent trying to understand the operation of the
program, will make the most plausible change and hope for
the best.

@c {{{endfold}}}
@c {{{ Identifier Style

@c
@node  Identifier Style, Coding Style Wrapup, Comment Style, Understanding Coding Style
@section Identifier Style

Picking good identifier names is an art not quickly
mastered, but here are some helpful hints@footnote{Some
of these are adapted from Peter Norvig's excellent
@emph{Paradigms of Artificial Intelligence Programming}}:

@itemize @bullet
@item
Most of the time, construct identifiers from
full words joined by dashes.

@item
Use abbreviations sparingly, for words you use frequently
within a package.  As always, be consistent if you do so.

@item
Identifier names should grow longer as their scope
grows longer:  Identifiers local to a function can
have much shorter names than those used throughout
a package.

@item
Identifier names should grow longer as their use
grows less frequent:  Constantly-used identifiers
can have much shorter names than those used only
once in a blue moon.

@item
Global variables in a package should have names
beginning and ending with asterisks.  This is a
CommonLisp tradition which is even more important
in @sc{muf}, which uses identical syntax for
global functions and variables.  (Avoid global
variables where practical, but don't be fanatic
about it.)

@item
Global constants in a package do @emph{not}
get asterisks around their names.

@item
It is often a good idea to pick names of the
form @code{verb-noun}: @code{printList}
@code{find-user} @code{sort-mail} and so forth.
@end itemize

@c {{{endfold}}}
@c {{{ Coding Style Wrapup

@c
@node  Coding Style Wrapup, Intermediate Muf Programming Wrapup, Identifier Style, Understanding Coding Style
@section Coding Style Wrapup

@c {{{endfold}}}

@c {{{endfold}}}
@c {{{ Intermediate Muf Programming Wrapup

@node Intermediate Muf Programming Wrapup, Advanced Muf Programming, Coding Style Wrapup, Intermediate Muf Programming
@section Intermediate Muf Programming Wrapup

This concludes the Intermediate Muf Programming chapter.

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
