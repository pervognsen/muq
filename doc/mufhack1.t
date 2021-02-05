@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@c =============================================
@c TO DO:
@c Add coverage of do{}/while/until and case{}
@c Add mentions of getting and printing time.
@c Add mentions of asMeDo{}
@c Add a section on Job stuff: fork/signal/ps/sleep
@c =============================================

@node MUF For Hackers, MUF For Hackers Overview, Top, Top
@chapter MUF For Hackers

@menu
* MUF For Hackers Overview::
* Basics::
* Blocks::
* Indices::
* Vectors::
* Structs::
* Objects::
* Debugging::
* Regular Expressions::
* Jobs::
* Lists::
* Projects::
* Pragmatics::
* Appendix I - Muq MUF for tinyMUCK MUF hackers::
* MUF For Hackers Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ MUF For Hackers Overview

@c
@node MUF For Hackers Overview, Basics, MUF For Hackers, MUF For Hackers
@section MUF For Hackers Overview

This tutorial is intended to provide a concise introduction
to Muq @sc{muf} for experienced programmers.

If you are not an experienced programmer, you may wish to
read the @strong{Elementary Muf Programming} tutorial instead of
this one.  (If you are a tinyMuck @sc{muf} programmer, you may
wish to start by reading Appendix I, which compares Muq @sc{muf}
to tinyMuck @sc{muf}.)

@sc{muf} (Multi-User Forth) is the traditional name for the
reverse-polish programming notation used to application programming
on the tinyMuck family of servers.

Muq's cultural roots lie in the tinyMuck community, but Muq @sc{muf}
has only the haziest relationship to tinyMuck @sc{muf}.  Muq @sc{muf}
is arguably more closely related to CommonLisp than to tinyMuck @sc{muf}.

In the Muq manual set, '@sc{muf}' when not otherwise qualified should
always be understood as referring to Muq @sc{muf}, not tinyMuck @sc{muf}.

@sc{muf} attempts to maximize the traditional strengths of Forth family
languages, such a simple, transparent, highly customizable compilers,
while fixing many of its traditional weaknesses, such as lack of local
variables and frequent use of the @sc{reset} button during debugging.

@sc{muf} has somewhat C-style control structures,
C-style printf formatting, 
modern
datastructures including Lisp-style lists and 
objects with multiple inheritance, internal pre-emptive multitasking,
a limited infix path notation that overcomes some of the worst
verbosity problems of traditional Forths, and a sophisticated
exception handling facility.  Among many other things!

@sc{muf} is particularly appropriate for interactive throwaway
hacking, since it is concise, evaluates expressions right-to-left
exactly in the order you type them, and publishes intermediate states
visibly on the stack as you go.

@sc{muf} is less appropriate (but usable) for programming of large
projects.  It is less readable than C-style infix notation for
such archival code, and the lack of strong type checking means
you wind up having to hunt down at runtime bugs which a language
like Java would have reported at compiletime.

@c {{{endfold}}}
@c {{{ Basics

@c
@node Basics, Blocks, MUF For Hackers Overview, MUF For Hackers
@section Basics

The best way to learn is by experimenting yourself.

You can reach a @sc{muf}
shell by running Muq from the commandline under unix in a
scratch db:

@example
muq/c> make
muq/c> rm muq-*
muq/c> muq-db-c
muq/c> ./muq
root:
2 2 +
root: 4
@end example

You can also reach a @sc{muf} shell by logging into a Micronesia
server as a normal user and doing @code{@@muf}.

The primitive @sc{muf} datatypes include strings ("abc"), floats
(12.34) and integers (123).

Integer precision is normally 62 bits internally, but is transparently
extended to the kilobit range upon arithmetic overflow, with no need
to explicitly invoke a bignum package:

@example
root:
2 3 +
root: 6
pop 10 3 -
root: 7
3 *
root: 21
2 %
root: 1
pop 2 10 expt
root: 1024
40 expt
root: 2582249878086908589655919172003011874329705792829223512830659356540647622016841194629645353280137831435903171972747493376
pop
root:
123 456 789 exptmod  ( Modular exponentiation -- 123 to the 456th mod 789 )
root: 699
@end example

The @code{exptmod} function is sufficiently optimized to be usable for
digital signatures.

Float precision is about 62 bits:

@example
root:
3.4 4.5 expt
root: 246.408
sin
root: 0.978691
asin
root: 1.36399
2.4e30 *
root: 3.27357e+30
@end example

Strings are currently limited to about
64K in length (this will be fixed in future releases):

@example
root:
"abc" "def" join
root: "abcdef"
pop
root:
[ "Print strings %-5s ints %04x and floats %-8.3f just like printf." "abc" 5 3.4 | ]print
root: "Print strings abc   ints 0005 and floats 3.400    just like printf."
pop
root:
"12 128.45 hike!" "%d %f %s" unprint[     ( Works much like C sscanf )
root: [ 12 128.45 "hike!" |
]pop
root:
@end example

(@sc{muf} comments are enclosed in parentheses.  There must be whitespace on
each side of each paren.)

Muq's character type uses syntax much like that of C, but is not as often
used:

@example
root:
'a' '\n'
root: 'a' '\n'
@end example


Functions are defined using the traditional Forth syntax of a colon followed
by the function name followed by the function body ended with a semicolon.
Here we define @code{x} to be a function working just like the built-in
@code{*} multiplication operator:

@example
root:
: x * ;
root:
2.3 4.5 x
root: 10.35
@end example

Anonymous functions are defined identically, except that the
colon is replaced by a double colon and the name dropped.
They are usually invoked using the @code{call} primitive:

@example
root:
:: "Hello, World!\n" , ;
root: #<c-fn _>
call
Hello, World!
root: 
@end example

Anonymous functions are handy any time you just need to
hand a short fragment of code to some function -- we'll
see them again shortly as object slot initializers.

Assignment to local variables within a function is done using
@code{value -> variable} syntax.  Here's a more long-winded
version of the above function:

@example
root:
:  x2
   -> arg2             ( Save second parameter to a local var. )
   -> arg1             ( Save first  parameter to a local var. )
   arg1 arg2 * -> arg3 ( Do the multiplication, save in a var. )
   arg3                ( Return the result.                    )
;
root:
2.3 4.5 x2
root: 10.35
@end example

These local variables are created by assignment and live until
the end of the function.  (They are not block structured.)

Using local variables eliminates many of the readability problems
that dog traditional Forths, including tinyMuck @sc{muf}.  Local
variables are very fast:  Use them freely.

Unlike traditional Forths, @sc{muf} allows you to declare the number
of arguments accepted and returned by a function.  Here's an even more
verbose version of the above function which does that:

@example
root:
:  x3 @{ $ $ -> $ @}     ( Accepts two args, returns one result. )
   -> arg2             ( Save second parameter to a local var. )
   -> arg1             ( Save second parameter to a local var. )
   arg1 arg2 * -> arg3 ( Do the multiplication, save in a var. )
   arg3                ( Return the result.                    )
;
root:
2.3 4.5 x3
root: 10.35
@end example

The @sc{muf} compiler will verify that the declaration is correct:

@example
root:
:  x4 @{ $ -> $ $ @}     ( Accepts two args, returns one result. )
   -> arg2             ( Save second parameter to a local var. )
   -> arg1             ( Save second parameter to a local var. )
   arg1 arg2 * -> arg3 ( Do the multiplication, save in a var. )
   arg3                ( Return the result.                    )
;
Sorry: Line 79: Fn x4: Fn arity conflict:   2 -> 1   vs   1 -> 2
root:
@end example

This error-checking forstalls many of the obscure bugs common
in traditional Forths.

The @sc{muf} compiler is not very bright, so sometimes it will be unable
to deduce the arity correctly, for example in recursive functions.
You can disable the arity checking in such cases by including a
final @code{!} in the arity declaration:

@example
root:
: x5 @{ $ $ -> $ ! @} ;
root:
@end example

This is also useful when you need to introduce a forward
declaration of a function ahead of its actual definition:
Simply define it with an empty body and suppress the arity
check, as in the above example.


The basic @sc{muf} conditional expression is the much-reviled
Forth @code{someExpression if firstChoice else secondChoice fi}
construct.  Here is a function to flip a coin and return "heads"
or "tails":

@example
root:
:  flip @{ -> $ @}
   1 trulyRandomInteger -> oneOrZero
   oneOrZero 1 = if "heads" else "tails" fi -> result
   result
;
root: 
flip
root: "tails"
pop flip
root: "tails"
pop flip
root: "heads"
pop flip
root: "tails"
pop flip
root: "tails"
pop flip
root: "heads"
@end example

Unlike traditional Forths, @sc{muf} allows you to do at
the commandline anything you can do inside a function
definition, in particular loops and conditional expressions.
@footnote{Commandlines are actually executed by compiling them into
a temporary function and then executing it.}

In @sc{muf} the value @code{nil} is "false" and all other
values are "true" for purposes of conditional expressions.
The conventional "true" value when an arbitrary one is
needed is @code{t}.  (Avoid using @code{t} as the name for
a variable!)

The @sc{muf} comparison operators are
@code{!= < <= = > >=}.  They work on strings (and other
things) as well as numbers.  To do case-insensitive
comparison of strings, use
@code{!=-ci <-ci <=-ci =-ci >-ci >=-ci}.

@sc{muf} has a basic count-up or count-down loop control
structure.  The @sc{muf} operator for printing is the
comma.  Remember that blanks are significant in @sc{muf},
as in all Forths -- the comma must have whitespace on both
sides!

@example
root: 
for i from 0 upto 3 do@{ i , "\n" , @}
0
1
2
3
root: 
for i from 0 below 3 do@{ i , "\n" , @}
0
1
2
root: 
for i from 3 above 0 do@{ i , "\n" , @}
3
2
1
root: 
for i from 3 downto 0 do@{ i , "\n" , @}
3
2
1
0
root: 
for i from 100 downto 0 by 10 do@{ i , "\n" , @}
100
90
80
70
60
50
40
30
20
10
0
root: 
@end example

Global variables are created and assigned to using the
@code{expression --> variable} syntax.

Note that this
assignment operator has one more dash than the one
used to assign to local variables.  You will be miserable
in @sc{muf} until you master the distinction!

Assigning to global variables is more dangerous and expensive, so
we give it a longer syntax, counting on human laziness to then
encourage people to use local variables rather than global ones
whenever reasonably possible:

@example
root:
12 --> twelve   ( Creates a permanent global variable. )
root:
twelve
root: 12
pop
root:
13 -> thirteen  ( Creates a local function variable -- vanishes instantly! )
root:
thirteen
Sorry: Undefined identifier: thirteen
root:
"twelve" --> twelve  ( Variables have no types, only values have types. )
root:
twelve
root: "twelve"
@end example	

Use @code{pf} (or @code{printFunctions}) to list the functions you have
defined.

Use @code{pv} (or @code{printVariables}) to list the global variables
you have defined.

To maintain sanity in a large multi-user sytem,
@sc{muf} supports multiple namespaces, which are called "packages".
All the above examples have been done in the default package for the
root user, which is named "root", which is why the prompt printed
after each command twas "root:".

Use "inPackage" to switch to another package.  If the package doesn't
exist, it will be created:

@example
root:
"test" inPackage
test:
pv
test:
12 --> test12
test:
13 --> test13
test:
pv
test12	12
test13	13
test: 
"junk" inPackage
junk:
12 --> junk12
junk: 
13 --> junk13
junk: 
pv
junk12	12
junk13	13
junk: 
"test" inPackage
test: 
pv
test12	12
test13	13
test: 
"root" inPackage
root: 
@end example

By default, variables and functions you define in a package are private to that
package.  To make them visible from other packages, use @code{export}:

@example
root:
test:test13
Sorry: Undefined identifier: test:test13
root: 
"test" inPackage
test:
'test13 export
test:
"root" inPackage
root:
test:test13
root: 13
@end example

You can actually examine unexported symbols in other packages using the
double-colon qualifier, but that is considered cheating -- it is
intended as a debugging facility, not something to use in routine
coding:

@example
root:
test:test12
Sorry: Undefined identifier: test:test12
root:
test::test12
root: 12
@end example

Functions are exported and referenced in exactly the same way.  Here
we define a function @code{gibberish} in package @code{test} which
when called prints out @code{n} random verbs, then export it and
call it from the @code{root} package:

@example
root:
"test" inPackage
test: 
: gibberish  -> n  for i from 0 below n do@{ 10 trulyRandomInteger -> x dict:intToVerb[x] , "\n" , @} ;
test:
'gibberish export
test:
"root" inPackage
root:
3 test:gibberish
blitz
pelt
dress
root: 
@end example

@c {{{endfold}}}
@c {{{ Blocks
@node Blocks, Indices, Basics, MUF For Hackers
@section Blocks

Let me introduce you to one final, fairly general and widely used @sc{muf}
facility before letting you go.

Evaluation stacks are very efficient ways of allocating and freeing
small amounts of temporary storage, but most languages use them
very clumsily, a problem which often becomes evident when dealing
with functions which accept or return a variable number of arguments.

Traditional Forth implementations (and tinyMuck @sc{muf}) are little
better, using a clumsy and error-prone convention of an integer count
pushed on top of the argument vector.

Muq @sc{muf} systematizes this by introducing the concept of stack
blocks and a variety of operations upon them.

A stack block may be created by enclosing some number of arguments
between @code{[} and @code{|}.  The @code{|} is syntactic sugar for a count
which tracks the size of the stackblock and allows operations to
be performed upon the block quite efficiently:

@example
root:
[ "this" "is" "a" "block" "of" "words" |
root: [ "this" "is" "a" "block" "of" "words" |
|sort
root: [ "a" "block" "is" "of" "this" "words" |
|mix
root: [ "block" "this" "is" "of" "words" "a" |
|pop
root: [ "block" "this" "is" "of" "words" | "a"
--> _tmp
root: [ "block" "this" "is" "of" "words" |
_tmp
root: [ "block" "this" "is" "of" "words" | "a"
|push
root: [ "block" "this" "is" "of" "words" "a" |
|shift
root: [ "this" "is" "of" "words" "a" | "block"
|unshift
root: [ "block" "this" "is" "of" "words" "a" |
]vec
root: #<vec>
vals[
root: [ "block" "this" "is" "of" "words" "a" |
|dup[
root: [ "block" "this" "is" "of" "words" "a" | [ "block" "this" "is" "of" "words" "a" |
]|join
root: [ "block" "this" "is" "of" "words" "a" "block" "this" "is" "of" "words" "a" |
|sort
root: [ "a" "a" "block" "block" "is" "is" "of" "of" "this" "this" "words" "words" |
|uniq
root: [ "a" "block" "is" "of" "this" "words" |
|length
root: [ "a" "block" "is" "of" "this" "words" | 6
pop
root: [ "a" "block" "is" "of" "this" "words" |
|dup[
root: [ "a" "block" "is" "of" "this" "words" | [ "a" "block" "is" "of" "this" "words" |
]pop
root: [ "a" "block" "is" "of" "this" "words" |
1 |rotate
root: [ "block" "is" "of" "this" "words" "a" |
-1 |rotate
root: [ "a" "block" "is" "of" "this" "words" |
3 |rotate
root: [ "of" "this" "words" "a" "block" "is" |
]words
root: "of this words a block is"
words[
root: [ "of" "this" "words" "a" "block" "is" |
]join
root: "ofthiswordsablockis"
"i" chopString[
root: [ "ofth" "swordsablock" "s" |
]words
root: "ofth swordsablock s"
vals[
root: [ 'o' 'f' 't' 'h' ' ' 's' 'w' 'o' 'r' 'd' 's' 'a' 'b' 'l' 'o' 'c' 'k' ' ' 's' |
|upcase
root: [ 'O' 'F' 'T' 'H' ' ' 'S' 'W' 'O' 'R' 'D' 'S' 'A' 'B' 'L' 'O' 'C' 'K' ' ' 'S' |
|downcase
root: [ 'o' 'f' 't' 'h' ' ' 's' 'w' 'o' 'r' 'd' 's' 'a' 'b' 'l' 'o' 'c' 'k' ' ' 's' |
|sort
root: [ ' ' ' ' 'a' 'b' 'c' 'd' 'f' 'h' 'k' 'l' 'o' 'o' 'o' 'r' 's' 's' 's' 't' 'w' |
|uniq
root: [ ' ' 'a' 'b' 'c' 'd' 'f' 'h' 'k' 'l' 'o' 'r' 's' 't' 'w' |
|charInt
root: [ 32 97 98 99 100 102 104 107 108 111 114 115 116 119 |
|sum
root: [ 32 97 98 99 100 102 104 107 108 111 114 115 116 119 | 1422
pop
root: [ 32 97 98 99 100 102 104 107 108 111 114 115 116 119 |
|intChar
root: [ ' ' 'a' 'b' 'c' 'd' 'f' 'h' 'k' 'l' 'o' 'r' 's' 't' 'w' |
|for v do@{ v , @} "\n" ,
 abcdfhklorstw
root: [ ' ' 'a' 'b' 'c' 'd' 'f' 'h' 'k' 'l' 'o' 'r' 's' 't' 'w' |
@end example

The general convention is that a function with a name ending with
@code{[} creates a stackblock (think of Unix shell syntax '<' for
opening a pipeline), a function beginning with @code{|} operates on a
pre-existing stackblock (again, think of Unix shell pipe notation) and
a function beginning with @code{]} consumes a stackblock (like Unix
shell @code{>} for terminating a pipeline).

Obviously, every @code{[} in an expression should have a balancing
@code{]} somewhere.

See the block section of the @sc{muf} reference manual for a fuller
listing of the block functions.

@sc{muf} functions may actually accept and return multiple
stackblocks, as well as multiple individual arguments.  The syntax for declaring
this to the compiler uses @code{[]} in place of the @code{$} used for
declaring a scalar argument or result:

@example
root:
: ]]pop @{ [] [] -> @}  ]pop ]pop ;
root:
[ "abc" | [ "def" |
root: [ "abc" | [ "def" |
]]pop
root: 
@end example

Block arguments must always precede (be below) scalar arguments, both
call and return.

Using stack blocks is a great way to avoid grinding the garbage collector
heavily by creating scads of small objects as intermediate values in an
expression.  For example, manipulating a stackblock of characters generates
no garbage, while doing the equivalent operation with string operators
might generate a number of garbage strings.  (Note, however, that strings
shorter than eight characters also count as zero garbage, since they are
stored as immediate stack values rather than being allocated on the heap.)

@c {{{endfold}}}
@c {{{ Indices
@node Indices, Vectors, Blocks, MUF For Hackers
@section Indices

Hashes are one of the most common and useful @sc{muf} datastructures:  They are comparable
to Perl's hashes.  A @sc{muf} hash maps arbitrary keys to values.  Internally it is
organized as a hashed b-tree, so it can efficiently handle half a dozen keys or half a
million keys.

Use @code{makeHash} to create a hash:

@example
root:
makeHash --> phone
root:
phone
root: #<Hash _ 4e9c915>
@end example

We normally use bracket notation to add and retrieve values from a hash:

@example
root:
"234-5555" --> phone["pat"]
root:
"324-6666" --> phone["kim"]
root:
phone["pat"]
root: "234-5555"
pop phone["kim"]
root: "324-6666"
@end example

If you want to check for the presence or absence of a key without
risking an error condition, use the @code{get?} primitive.  The
top return value is the stored value, if any, and the bottom return
value is a t/nil flag indicating whether the key was found:

@example
root:
phone["sam"]
Sorry: No such property: "sam"
root: 
phone "sam" get?
root: nil nil
pop pop
root:
phone "kim" get?
root: t "324-6666"
@end example

Use @code{ls} to list the contents of an hash:

@example
root:
phone ls
"kim"	"324-6666"
"pat"	"234-5555"
root:
@end example

Use @code{foreach} to iterate over the contents of
a hash:

@example
root:
phone foreach key do@{ key , "\n" , @}
kim
pat
root: 
phone foreach key val do@{ key , " " , val , "\n" , @}
kim 324-6666
pat 234-5555
root: 
@end example

By default, values in a hash are visible to anyone who can
access the hash.  You may also store hidden values on a
hash, in a space separate from the public one:

@example
root:
"666-6666" --> phone$hidden["nsa"]
root:
"777-7777" --> phone$hidden["cia"]
root:
phone$hidden["nsa"]
root: "666-6666"
pop phone$hidden["cia"]
root: "777-7777"
@end example

Use @code{lsh} to list hidden properties:

@example
root:
phone lsh
"cia"	"777-7777"
"nsa"	"666-6666"
root: 
@end example

Use @code{foreachHidden} to iterate over the hidden contents of
an hash:

@example
phone foreachHidden key val do@{ key , " " , val , "\n" , @}
cia 777-7777
nsa 666-6666
root: 
@end example

Use @code{delete:} to remove values from an hash:

@example
root:
phone lsh
"cia"	"777-7777"
"nsa"	"666-6666"
root: 
delete: phone$hidden["cia"]
root: 
phone lsh
"nsa"	"666-6666"
root: 
phone ls
"kim"	"324-6666"
"pat"	"234-5555"
root: 
delete: phone["kim"]
root: 
phone ls
"pat"	"234-5555"
root:
@end example

In addition to the public and private values on a hash, each
hash has system values which are visible to the owner but are
(often) settable only by root.  Use @code{lss} to list these system
values:

@example
root:
phone lss
:dbname	"ROOTDB"
:isA	#<MosClass Object 209fa15>
:myclass	"obj"
:owner	#<Root root 2c015>
:name	"_"
root: 
me lss
:dbname	"ROOTDB"
:isA	#<MosClass Root 3a9d015>
:myclass	"rot"
:owner	#<Root root 2c015>
:hashName	1263705246727446217
:lib	#<Object .u.roo%s.lib 91e915>
:name	"root"
:ip3	82
:ip2	182
:ip1	179
:ip0	205
:breakOnSignal	0
:breakEnable	0
:breakDisable	0
:doSignal	0
:debugger	'debug:mufDebugger
:doBreak	0
:group	0
:runQueue1	#<JobQueue 1 1020215>
:runQueue0	#<JobQueue 0 20115>
:psQueue	#<JobQueue ps f20415>
:pgpKeyprint	0
:pauseQueue	#<JobQueue poz ea0515>
:objectsOwned	9660
:objectQuota	268435456
:configFns	#<Object _ 211fb0000b81de15>
:loginHints	#<Object _ 211fb0000359cc15>
:homepage	0
:haltQueue	#<JobQueue hlt e20615>
:email	0
:doing	0
:doNotDisturb	0
:defaultPackage	#<Package root 422a15>
:dbrefConvertErrors	0
:bytes-owned	20714832
:byte-quota	268435456
:packetPreprocessor	0
:dateAtWhichWeLastQueriedUserServers	0
:userServer4NeedsUpdating	0
:userServer3NeedsUpdating	0
:userServer2NeedsUpdating	0
:userServer1NeedsUpdating	0
:userServer4	0
:userServer3	0
:userServer2	0
:userServer1	0
:userServer0	1511201586247629963
:userVersion	8
:hasUnknownUserServer	0
:port	30000
:ioStream	0
:dateOfLastNameChange	0
:originalNickName	"root"
:lastSharedSecrets	nil
:lastHashName	0
:lastTrueName	nil
:lastLongName	0
:sharedSecrets	nil
:trueName	nil
:longName	21785844818505190280484762160577916926604332233153169514740797048102153525671947608990996953242732183859349004057149371159606487467804054198140106344292159054364973335175134573886793277186528940143238208826532169922986204369431519881943212123282907303118638555788690891574541957756718153188906349437557021918
:nickName	"root"
:gagged	0
:rank	100
:timeSlice	125983
:textEditor	'edit:editString
:telnetDaemon	#<c-fn start>
:shell	0
:runQueue2	#<JobQueue 2 fa0315>
:timesUsedByMuqnet	0
:lastUsedByMuqnet	0
:firstUsedByMuqnet	0
:packetPostprocessor	0
root: 
@end example

A package is implemented by a specialized hash object.

Hashes also have an administrative namespace visible and settable only by root,
useful for systems programming.  It uses such syntax as @code{obj$admins.val},
@code{obj$admins["key"]} @code{lsa} and @code{foreachAdmins}.



Use @code{makeIndex} to create Index objects.  They have an
interface identical to Hash objects, but internally the keys
are stored in a sorted btree instead of a hashed btree: This saves a
little space (no separate hash value to store) but slows down access
and retrieval a bit (comparing keys is slower than comparing
integer hash values).  Indices are especially useful when you
want to list keys in order for display to the user.

Almost everything in Muq is also an index.  This makes it easy
to hang random values off of objects without having to redefine
their class every time.  The User object @code{me} which represents your
account on the Muq server is an object which is also an index,
for example:

@example
root:
me
root: #<Root root 2c015>
ls
:doBreak	'muf:]doBreak
:www	0
root: 
12 --> me["twelve"]
root: 
me["twelve"]
root: 12
pop delete: me["twelve"]
root:
me["twelve"]
Sorry: No such property: "twelve"
root:
@end example

The backbone of
the internal Muq "file system hierarchy" (actually an object graph)
consists of indices of various kinds.  Use a leading "." to explore
it, just as you use a leading "/" to explore the Unix filesystem.  Points
of interest include @code{.u} (indexes local users by name),
@code{.etc} (much like unix @code{/etc}), and @code{.folkBy.nickName}
(lists known muqnet users by name, both local and remote).

Use @code{makeSet} to create a Set, which is like a SortedIndex whose
value field is alway @code{t} -- this cuts the space needs in half:

@example
root:
makeSet --> _x
root:
t --> _x["b"]
root:
t --> _x["c"]
root:
_x ls
"b"	t
"c"	t
root:
@end example

Here is a more compact way of creating Sets, along with an illustration
of set union and intersection operations and the @code{vals[} operator
for extracting an object's set of keys as a stackblock (stackblocks
will be discussed shortly):

@example
root:
[ 'a' 'b' 'c' | ]set   [ 'b' 'c' 'd' | ]set   union   keys[
root: [ 'a' 'b' 'c' 'd' |
]pop
root:
[ 'a' 'b' 'c' | ]set   [ 'b' 'c' 'd' | ]set   intersection   keys[
root: [ 'b' 'c' |
@end example

Much the same shortcut and operations are available for Index objects:

@example
root:
[ "a" 'a' "b" 'b' "c" 'c' | ]index   [ "b" 'b' "c" 'c' "d" 'd' | ]index   union   ls
"a"	'a'
"b"	'b'
"c"	'c'
"d"	'd'
root:
[ "a" 'a' "b" 'b' "c" 'c' | ]index   [ "b" 'b' "c" 'c' "d" 'd' | ]index   intersection   ls
"b"	'b'
"c"	'c'
root:
@end example

@c {{{endfold}}}
@c {{{ Vectors
@node Vectors, Structs, Indices, MUF For Hackers
@section Vectors

Vectors are the closest approximation Muq offers to cheap, pure,
minimal-overhead chunks of storage with which you can do what
you please with minimum hindrance (or assistance).  They consist
of @code{n} slots numbered @code{0} to @code{n-1}.

@example
root:
"abc" 4 makeVector --> v
v length
root: 4
pop
root:
v ls
0	"abc"
1	"abc"
2	"abc"
3	"abc"
root:
"def" --> v[0]
root:
v ls
0	"def"
1	"abc"
2	"abc"
3	"abc"
root:
for i from 0 below 4 do@{ v[i] , "\n" , @}
def
abc
abc
abc
root: 
@end example

All the Index facilities work with vectors, except that they are
restricted to always having keys restricted to the consecutive
sequence @code{0 -> n-1}.  Vectors may point to other vectors
(or anything else) in arbitrary trees and graphs.

As with all other Muq objects, vectors are automatically
recycled when they are no longer accessible:  You need
not (and cannot) explicitly free them.  (You also cannot
have C-style memory leaks or pointer bugs!)

Vectors are currently limited to about 64K in length; Each slot
is eight bytes (64 bits) so that gives you about eight thousand
slots.

Here's a shortcut for creating a vector with given contents:

@example
root:
[ "abc" "def" "ghi" | ]vec
root: #<vec>
ls
0	"abc"
1	"def"
2	"ghi"
root: 
@end example


@c {{{endfold}}}
@c {{{ Structs
@node Structs, Objects, Vectors, MUF For Hackers
@section Structs

Muq @sc{muf} offers the ability to define and use structs,
but in the Muq context they make less sense than they do
in the C context:  Usually it makes more sense to use
@sc{muf} classes than @sc{muf} structs: Muq structs essentially
just offet a subset of the class functionality.

Here is a very sketchy overview.  As always, see the
@sc{muf} reference manual for more details.  The
ultimate reference is the @code{140-C-defstruct.t}
source implementing all this.  It is less than 8K
long and a good example of extending the @sc{muf}
compiler without touching the core code.

@example
root:
defstruct: Grunt 'name 'rank 'serialNumber ;
root:
[ :name "tom" :rank "private" :serialNumber 1 | ]makeGrunt
root: #<a Grunt 4d499a1b>
--> _tom
root:
_tom ls
:name	"tom"
:rank	"private"
:serialNumber	1
root: 
"dick" --> _tom.name
root:
_tom ls
:name	"dick"
:rank	"private"
:serialNumber	1
root:
_tom.name 
root: "dick"
@end example


@c {{{endfold}}}
@c {{{ Objects
@node Objects, Debugging, Structs, MUF For Hackers
@section Object

Muq is more object-oriented than (say) Java:  In Muq everything,
including for example integers, really is treated consistently
as an object.  @footnote{Java special-cases ints, and consequently
requires ugly work-arounds when they must interoperate with
the object-oriented parts of the language.  Muq saves you
from having to deal with such special cases and work-arounds,
at the cost of having the implementation work a bit harder.
Java's approach makes sense for its design domain of
programming embedded processors with very little spare
ram or compute power; Muq's approach makes sense for its design
domain of application programming where simplicity, reliability
and ease of code creation and maintainance are more important
than small efficiency wins.}

But in this section we are concerned specifically with
user-defined classes, inheritance relationships between those
classes, and the creation and use of instances of those classes.

In the Muq Object System, fields are called "slots".
@footnote{The Muq Object System is modelled on the Common Lisp Object System.}

Here are the bare essentials of creating and using an object.

@example
root:
defclass: Geek   :slot :name   :slot :language   ;
root:
'Geek makeInstance
root: #<a Geek 4e41861b>
--> _geek1
root:
"Linus" --> _geek1.name
root:
"C" --> _geek1.language
root:
_geek1 ls
:name	"Linus"
:language	"C"
root:
_geek1.name
root: "Linus"
@end example

Slots may have default initial values defined:

@example
root:
defclass: Geek
   :slot :name       :initval "Kim"
   :slot :language   :initval "C"
;
root:
'Geek makeInstance --> _geek1
root: 
_geek1 ls
:name	"Kim"
:language	"C"
root: 
@end example

Sometimes you want the initial value of a slot to be computed
at object creation time, rather than be a fixed constant.  A
typical situation is when you wish each object to possess one
or more index subobjects, and you don't want them shared
between all instances of the class.

Use the @code{:initform} keyword with an anonymous function in
such situations:

@example
root:
defclass: geek
   :slot :name       :initval "Kim"
   :slot :likes      :initform   :: makeIndex ;
   :slot :dislikes   :initform   :: makeIndex ;
;
root:
'Geek makeInstance --> _geek1
root: 
_geek1 ls
:name	"Kim"
:dislikes	#<Index _ 2f41db15>
:likes	#<Index _ 2f49da15>
root:
t --> _geek1.dislikes["Smurfs"]
root:
t --> _geek1.dislikes["Jocks"]
root:
_geek1.dislikes ls
"Jocks"	t
"Smurfs"	t
root: 
t --> _geek1.likes["Filk"]
root:
t --> _geek1.likes["Babylon5"]
root:
_geek1.likes ls
"Babylon5"	t
"Filk"	t
root: 
@end example

By default, object slots are readable and writable by the
owner, and readable by others who obtain a pointer to the
object.  You may change this using the @code{:prot} keyword.

For example, suppose you want to create a class to contain
PGP keypairs, with the public key to be readable by anyone
but the private key readable only by the owner:

@example
root:
defclass: PgpKey
   :slot :publicKey    :prot  "rwr-r-"
   :slot :privateKey   :prot  "rw----"
;
root:
@end example

(The Muq server actually provides special types for Muqnet
private keys which are unreadable even by the owner --
a production implementation might use them.)

Use the @code{:isA} keyword to define subclasses of a
previously defined class:

@example
root:
defclass: Flier
    :slot :wings        :initval 2
;
root:
defclass: Animal
    :slot :warmBlooded  :initval t
;
root:
defclass: Bird
    :isA 'Flier
    :isA 'Animal
;
root:
'Bird makeInstance --> _myBird
root:
_myBird ls
:warmBlooded	t
:wings	2
root: 
@end example

Here @code{Flier} and @code{Animal} are base classes, and
@code{Bird} is a subclass of both @code{Flier} and
@code{Animal}, and hence has both a slot giving how
many wings it has, and a slot recording whether it is
warmblooded.

Sometimes you want a slot to be shared between all instances
of a class.  Perhaps you have lots of Vassals in your
simulation, but they must always all have the same Queen.
Use the @code{:allocation :class} slot modifier
in such cases:

@example
root:
defclass: Vassal
    :slot :queen   :allocation :class   :initval "Victoria"
;
root:
'Vassal makeInstance --> _toby
root:
'Vassal makeInstance --> _rupert
root:
_toby ls
:queen	"Victoria"
root: 
_rupert ls
:queen	"Victoria"
root:
"Elizabeth" --> _toby.queen
root:
_toby ls
:queen	"Elizabeth"
root: 
_rupert ls
:queen	"Elizabeth"
root: 
@end example

Message-passing is central to any object-oriented programming
system:  It lets a single abstract operation have different
detailed implementations depending on the class of the object(s)
at hand, and allows those implementations to be cleanly
separated from each other rather than tangled together in
some central maintainance headache of a function.

"Generic functions" provide Muq with message-passing.

Unlike languages like Java and C++ in which message-passing is done in
a fashion inconsistent with the vanilla function facilities of the
language, Muq generic functions are fully consistent with the vanilla
function facilities of the language: Generic functions are invoked
exactly as are normal functions (the caller need not even know whether
they are generic or vanilla), may be passed around and stored in slots
like vanilla functions, and in general may be used anywhere a vanilla
function may be used, in exactly the same way a vanilla function would
be used.  In fact, in terms of superficial implementation, generic
functions @strong{are} vanilla functions -- they just happen to have
some extra magic beneath the surface.

Let us create a flock of different animals answering to a single
"speak" generic function which will do appropriately varied
things depending on the class of the argument:

@example
root: 
defclass: Dog ;
root: 
defclass: Poodle    :isA 'Dog ;    'Poodle makeInstance  --> _poodle
root: 
defclass: Sheltie   :isA 'Dog ;    'Sheltie makeInstance --> _sheltie
root: 
defclass: Bulldog   :isA 'Dog ;    'Bulldog makeInstance --> _bulldog
root: 
defclass: Bird ;
root: 
defclass: Wren      :isA 'Bird ;   'Wren    makeInstance --> _wren
root: 
defclass: Sparrow   :isA 'Bird ;   'Sparrow makeInstance --> _sparrow
root: 
defclass: Crow      :isA 'Bird ;   'Crow    makeInstance --> _crow
root: 
defgeneric: speak  @{ $ -> @} ;    ( One input, no return values. )
root: 
defmethod:  speak  @{ 'Bird   @} pop "Chirp!\n" , ;
root: 
defmethod:  speak  @{ 'Crow   @} pop "Caw!\n" , ;
root: 
defmethod:  speak  @{ 'Dog    @} pop "Woof!\n" , ;
root: 
defmethod:  speak  @{ 'Poodle @} pop "Yip!\n" , ;
root: 
_poodle speak
Yip!
root: 
_sheltie speak
Woof!
root: 
_bulldog speak
Woof!
root: 
_wren speak
Chirp!
root: 
_sparrow speak
Chirp!
root: 
_crow speak
Caw!
root: 
@end example

Things to note:

@itemize @bullet
@item
The right thing happens when we ask @code{_wren} and @code{_sheltie}
to @code{speak}, even though we didn't explicitly specify a @code{speak}
method for them:  They inherit the appropriate behavior from
(respectively) @code{Bird} and @code{Dog}.

@item
The @code{_crow} and @code{_poodle} behave differently from their
ancestral @code{Bird} and @code{Dog} classes because the default
behavior has been explicitly over-ridden.

@item
@code{Dog} and @code{Bird} have no common ancestor, but @code{speak}
still works fine on both of them.  You cannot do that in C++ or Java,
but it is very useful in real systems where existing inheritance trees
sometimes do not fit what you need to do today.

@item
The generic function and method definitions do not need to be textually
nested within the relevant class definitions.  They do not even have to
be in the same source file.  This avoids pathological giganticism problems
and lets you factor your code in whatever way you find cleanest and
most readable:  You can group the methods with the relevant classes,
or factor them off into separate files.  You will often find that a
given generic function has very little to do with the core functionality
of the classes in question, and that putting the generic function and
its methods in a separate file makes lots of sense.
@end itemize

@c {{{endfold}}}
@c {{{ Debugging
@node Debugging, Regular Expressions, Objects, MUF For Hackers
@section Debugging

I'd love to see GUI-driven multiprocess debugging for Muq.

What we actually have at the moment is@dots{} primitive.
As in stone age.  Here are some hints for coping.

@itemize @bullet
@item
Writing code in small increments and testing it frequently
helps.  @sc{muf} is designed for interactive code execution,
which makes this easier.
@item
You can print out stuff using the comma operator.  I use
this a lot.
@item
Normally, when the interpreter discovers an error, it
prints out a diagnostic and returns you to the prompt.
If you can do @code{debugOn}, then errors instead
throw you into the debugger, from which you can examine
the evaluationa and call stacks.  Use @code{debugOff}
to disable the debugger again.  (You can instead tweak the
@@$s.breakEnable flag directly if you prefer.)
@item
Printout generated via the comma operator has to go through
the message streams and @code{skt.t} socket logic and internal
timeslicing logic, which may prevent timely printout.  One
way around this is to enable logging by invoking Muq
@code{./muq --logfile=xyzzy.log} and then use @code{log,}
instead of the regular comma operator -- this will do an
immediate C write directly to the logfile, bypassing all
the message stream, timeslice and socket interface logic.
You can either examine the logfile later, or else watch
it in realtime using @code{tail -f xyzzy.log} from the
Unix commandline.
@item
As a last resort, you can invoke Muq by something like @code{./muq  --logfile=xyzzy.log --log-bytecodes}
after which it will log every bytecode executed to @code{xyzzy.log}.  Keep in mind that Muq can
easily execute a million bytecodes per second normally, so this can fill disk fast -- not to
mention slow down the interpreter a lot!
You can switch bytecode logging on and off in softcode by doing (respectively)
@code{t --> .muq.logBytecodes}
and
@code{nil --> .muq.logBytecodes}.
@end itemize

Want to write a better debugger?  Go for it!

@c {{{endfold}}}
@c {{{ Regular Expressions
@node Regular Expressions, Jobs, Debugging, MUF For Hackers
@section Regular Expressions

Muq @sc{muf} provides a simple regular expression syntax roughly
comparable to that of Perl 4.  @footnote{Its implementation is in
@code{muq/pkg/175-C-rex.t} and provides a nice example of
extending the core @sc{muf} compiler without touching any of
the core compiler code.}

Regular expressions are treated as a sublanguage used to compile
named functions which may then be called just like any other
@sc{muf} function.  The definition of a regular expression
function begins with the @code{rex:} keyword, which is
followed by the function name and then the regular expression
proper, delimited by the printable character of your choice,
typically slashes:

@example
root:
rex: re1 /^abc[def]/
root:
"abcd" re1
root: t
pop "abcg" re1
root: nil
pop
root:

rex: re2 /^abc[d-f]/
root:
"abcd" re2
root: t
pop "abcg" re2
root: nil
pop
root:

rex: re3 /^abc|def|ghi/
root:
"abc" re3   "jkl" re3
root: t nil
pop pop
root:

rex: re4 /^a[bc]*d/
root:
"acbd" re4   "acb" re4
root: t nil
pop pop
root:
@end example

The basic Perl4 set of special escape characters are supported:

@example
^      match start of string
$      match end of string
[a-z]  any char from a through z
[^a-z] any char BUT a through z
\s     whitespace
\S     non-whitespace
\d     digit: [0-9]
\D     non-digit
\w     word character: [0-9a-zA-Z]
\W     non-word character
x*     zero or more 'x's.
x+     one  or more 'x's.
x?     zero or one 'x'x.
x@{2,4@} two to four 'x's.
@end example

Parens in a regular expression serve to group it, and also indicate
a part which should be returned as an additional result of the
function:

@example
root:
rex: re6 /^a(b*)c/
root:
"ac" re6
root: t ""
pop pop
root:
"abbbbbbbc" re6
root: t "bbbbbbb"
pop pop
root:
"adc" re6
root: nil ""
@end example

As usual, numeric escapes such as @code{\2} will match whatever
the corresponding (second, in this case) pair of parens in the
regular expression matched:

@example
root:
rex: re5 /^(abc)\1$/
root:
"abcabc" re5
root: t "abc"
pop pop
root:
"abcacb" re5
root: nil ""
@end example

Regular expressions can be a great aid in digesting formatted text:

@example
root:
rex: matchDate /^\s*(\w+)\s*(\d+)(\w*),\s*(\d+)\s*$/
root:
" July 4th, 1999  " matchDate
root: t "July" "4" "th" "1999"
pop pop pop pop pop
root:
"Aug8,1999" matchDate
root: t "Aug" "8" "" "1999"
@end example

@c {{{endfold}}}
@c {{{ Jobs
@node Jobs, Lists, Regular Expressions, MUF For Hackers
@section Jobs

Muq @sc{muf} provides pre-emptive multitasking facilities which are in
some respects comparable to threads provided by Unix: Each user may
have multiple jobs scheduled to run (or waiting on I/O) at any given
time, each with its own call and evaluation stack.  Execution of
ready-to-run jobs is interleaved in an attempt to give each user an
equal share of available processing power.  Jobs are organized into
jobsets similar to Unix process groups, which in turn are organized
into sessions corresponding roughly to a single user login: Usually
each session is associated with a single Socket object and vice versa.
Jobs, jobsets and sessions may be created via fork primitives and
killed by signals.  Jobs may be moved in and out of jobqueues under
softcode control, allowing high-level scheduling algorithms to be
coded in-db.

@sc{muf} functions use @code{@@} to get a pointer to the job executing
them.  As usual, @code{lss} is your friend:

@example
root:
@@ lss
:dbname	"ROOTDB"
:isA	#<MosClass Job 3f9fd15>
:myclass	"job"
:owner	#<Root root 2c015>
:lib	#<Index .u.roo%s.lib 91e915>
:package	#<Package root 422a15>
:name	3
:compiler	#<an ephemeral context>
:muqnetIo	0
:pid	3
:standardOutput	#<MessageStream _ caee15>
:standardInput	#<MessageStream _ caee15>
:killStandardOutputOnExit	nil
:errorOutput	#<MessageStream _ caee15>
:promiscuousNoFragments	0
:doingPromiscuousRead	nil
:debugIo	#<MessageStream _ caee15>
:dataStack	#<DataStack _ 2b51e815>
:breakOnSignal	nil
:breakEnable	nil
:breakDisable	nil
:actualUser	#<Root root 2c015>
:actingUser	#<Root root 2c015>
:endJob	0
:doSignal	'muf:]doSignal
:doError	#:doError
:debuggerHook	nil
:debugger	'debug:mufDebugger
:doBreak	'muf:]doBreak
:variableBindings	0
:traceOutput	#<MessageStream _ caee15>
:terminalIo	#<MessageStream _ caee15>
:state	"1"
:stackBottom	1
:spareCompileMessageStream	0
:spareAssembler	0
:sleepUntilMillisec	0
:root	#<DatabaseFile ROOTDB 24815>
:task	0
:reportEvent	#:reportEvent
:readtable	#<ReadTable _ 37b15>
:readNilFromDeadStreams	nil
:queryIo	#<MessageStream _ caee15>
:priority	1
:parentJob	#<Job jb0 33115>
:opCount	2971
:loopStack	#<LoopStack _ 2b49ea15>
:jobSet	#<JobSet _ 17d22615>
:here	#<Root root 2c015>
:group	0
:functionBindings	0
:ephemeralVectors	0
:ephemeralStructs	74
:ephemeralObjects	0
:ephemeralList	0
root: 
@end example


@c {{{endfold}}}
@c {{{ Lists
@node Lists, Projects, Jobs, MUF For Hackers
@section Lists

@sc{muf} does not attempt to be Lisp, but it does provide basic
support for Lisp-style Lists -- binary trees built from @code{cons}
cells.  Lisp lists are not terribly efficient in time and space,
but they are unmatched in flexibility:  If you are doing something
like recursively rewriting expressions in place (perhaps in a
compiler or while doing a little symbolic algebra), they can
turn dismal drudgery to delight.

This isn't the place to explain programming with Lists, so I'll
just give some samples of what is available.  Much of it is
implemented in @code{muq/pkg/100-C-lists.t} and as usual you
should see the @sc{muf} reference manual for further documentation.

@example
root:
"a" "b" cons
root: #<cons>
car
root: "a"
pop
root:
[ "a" "b" "c" "d" ]
root: #<cons>
dup car , "\n" , cdr
a
root: #<cons>
dup car , "\n" , cdr
b
root: #<cons>
dup car , "\n" , cdr
c
root: #<cons>
dup car , "\n" , cdr
d
root: nil
pop
root:
[ [ "a" "b" "c" ] |   :: car ;   maplist   --> _l
root:
_l first   _l second   _l third
root: "a" "b" "c"
pop pop pop
root:
'd' [ 'a' 'b' 'c' ] member?
root: nil
pop
root:
'b' [ 'a' 'b' 'c' ] member? car
root: 'b'
pop
root:
[ 'a' 'b' ] [ 'c' 'd' ] nconc --> _l
root:
_l first  _l second  _l third  _l fourth
root: 'a' 'b' 'c' 'd'
pop pop pop pop
root:
[ [ 'your 'house ] [ 'your 'spouse ] ] --> _l
root:
'my 'your _l nsubst printList

root: "[ [ 'my 'house ] [ 'my 'spouse ] ]"
@end example

@c {{{endfold}}}
@c {{{ Projects
@node Projects, Pragmatics, Lists, MUF For Hackers
@section Projects

All the examples so far have presumed you are executing code interactively.

This is great for learning and experimentation, but for serious coding you
need to be able to edit up archival code in a text editor, save it in a
host file, and compile it into the db.

The purpose of this section is to take you quickly through the
detailed mechanics of one way of establishing a serious Muq @sc{muf}
project of your own: Where to put the source files, how to compile
them and so forth.  It presumes you are running your own Muq
developmental server, with full Unix level access to the development
account.

The purpose of this section is @strong{not} to cover all the
possibilities, just to present one simple, workable approach.

We will do the development using a development version of the
Muq executable in @file{muq/c/muq}, and a test version of the
database, in @file{muq/c/muq-*}.  This frees us up to do whatever
debugging hacks we want on either, since the production server
normally uses the executable @file{muq/bin/muq} and keeps the
database in @file{muq/db/*}.

Start by installing the full source distribution, if you have
not already, and doing
@example
cynbe@@chee muq/c> make
cynbe@@chee muq/c> make check
@end example
to verify that you can compile the server from scratch.  I
usually do
@example
cynbe@@chee muq/c> rm -rf muq-*
cynbe@@chee muq/c> rm -rf #check.tmp#
@end example
next to clean out the debris from @code{make check}.

Now do
@example
% muq-db-c
[@dots{}]
@end example
to create a test db in @file{muq/c/muq-*}.  Test that it
works as expected interactively:

@example
cynbe@@chee muq/c> ./muq
[@dots{}]
Hints from me$s.loginHints$h[1,2...]:
  For configuration menu do:       config
  To exit server from console do:  <CTRL>-C or rootShutdown
root: 
2 2 +
root: 4
rootShutdown
[@dots{}]
cynbe@@chee muq/c>
@end example

(For what it is worth, I usually do all this sort of stuff
from inside an emacs shell buffer:  @code{M-x shell} in
emacs.  This makes editing and re-trying expressions trivial,
and also allows pasting in full function definitions direct
from files in other emacs buffers.)

Now, let's create our own @sc{muf} source file establishing our own
package, and compile it into the db.

@sc{muf} source code lives in @sc{muq/pkg/}.  When @sc{muq/bin/muq-db-c}
builds a database from scratch, it compiles the files in ascending order
of numerical prefix, which ensures that critical system files are loaded
before other files that depend on them.

Prefix numbers @code{000-499} are reserved for the standard Muq
libraries, while prefix numbers @code{500-999} are reserved for local
source libraries.  By obeying this convention, you ensure that your
files won't be clobbered by files in future source distributions, and
that your files will be loaded after the standard Muq facilities they
depend on are in place.

Use your favorite text editor to create a file @code{muq/pkg/500-mystuff.t} containing
@example
@@example  @@c
"mystuff" inPackage
2001 -->constant myconst
2002 --> _myvar
: myfn "Hello, world!\n" , ;
myfn
@@end example
@end example
Explanation:
@itemize @bullet
@item
The first and last lines are texinfo support for creating printed
documentation from your souce code -- they are not actually part
of the @sc{muf} code.  You can take them as boilerplate for now.
(Be sure to get them exactly as illustrated, including a double
blank before the @code{@@c}!)
@item
@code{"mystuff" inPackage} creates a "package" (namespace) named
"mystuff", into which the following code compiles.  If the named
package already exists, it is merely selected as the current
package.  @code{inPackage} is a bit like Unix @code{cd}.
@item
@code{2001 -->constant myconst} is an example of creating a constant.
@item
@code{2002 --> _myvar} is an example of creating a global variable.
@item
@code{: myfn "Hello, world!\n" , ;} is an example of defining a
function.
@item
@code{myfn} is an example of invoking the above function during
compilation -- I've included this as a reminder that you can
execute arbitrary code during these "compiles", since the input
code is in fact being evaluated line by line just as it is during
interactive sessions.  You'll see the result print out during the
nest step.
@end itemize
(I usually test code like this interactively before saving it in a file, but we'll
skip that step here for brevity.  One reason I do this is because the interactive
error diagnostics are not as bad as the batchmode compile diagnostics, which
currently often consist of the server hanging...)

Now load that file into the db:
@example
cynbe@@chee muq/c> muq-c-lib 500-mystuff
[@dots{}]
cynbe@@chee muq/c> 
@end example

For a simple example like this, of course, it would be easier -- and
equivalent -- to simply skip the source file editing and enter the
code interactively, but for a realistic project consisting of a dozen
or two source files each containing hundreds or thousands of lines of
@sc{muf} source, batchmode compilation is a virtual necessity.

Now we check that the db has been updated as we expect:
@example
cynbe@@chee muq/c> ./muq
[@dots{}]
Hints from me$s.loginHints$h[1,2...]:
  For configuration menu do:       config
  To exit server from console do:  <CTRL>-C or rootShutdown
root: 
"mystuff" inPackage
mystuff:
myconst
mystuff: 2001
pop
mystuff: 
_myvar
mystuff: 2002
pop
mystuff: 
myfn
Hello, world!
mystuff: 
rootShutdown
[@dots{}]
cynbe@@chee muq/c>
@end example

Now let's create the world's simplest shell.  Edit @code{muq/pkg/500-mystuff.t} to contain
@example
@@example  @@c
"mystuff" inPackage
: ]shell @{ [] -> @@ @}
    do@{
        t @@.standardInput readStreamPacket[ ]pop
        "Huh?\n" ,
    @}
;
@@end example
@end example
Explanation: This declares @code{]shell} to be a function accepting one stackblock
and never returning.  The @code{do@{@dots{}@}} construct is an infinite loop, and
inside it we eternally read one line from standard input, ignore the result, and
print "Huh?" to standard output.

Again, this example is so simple that we could as easily have defined the function
interactively, but we're warming up for cases where the shell might have hundreds
or thousands of lines of code.

We could load the file in just as before, using @code{muq-c-lib}, but let us suppose
instead that we've spent a few days thrashing around and prefer now to build a
pristine new database from scratch:
@example
cynbe@@chee muq/c> rm -rf muq-*
cynbe@@chee muq/c> muq-db-c
[@dots{}]
cynbe@@chee muq/c>
@end example
As you do this, you'll notice that your @code{muq/pkg/500-mystuff.t} file now gets
loaded in last automatically.

@c {{{endfold}}}
@c {{{ Pragmatics
@node Pragmatics, Appendix I - Muq MUF for tinyMUCK MUF hackers, Projects, MUF For Hackers
@section Pragmatics

Every software system has, beyond its formal sematics, a set of pragmatics:  Assumptions
on how the system will be used that affect how it is implemented.

Use the system as intended and it will be reasonably effective and
efficient.

Use it in unanticipated ways, and you are likely to find the implementation inefficient
and ineffective.

The purpose of this section is to give you some notion of what sort of coding
practices and problems the Muq implementation was designed to handle.  You
don't have to limit yourself to these, of course, but at least you'll know
when you are venturing into deep water.

@c buggo, need to fill this in!
@c e.g.:
@c large numbers of small objects are a design focus
@c small strings are efficient.
@c integer loops over float/int vectors are inefficient.
@c intent is to support dbs 10x bigger than physical ram.
@c   but gc is an issue and avoid iterating over the world.
@c discuss detailed overhead stuff, including btrees


@c {{{endfold}}}
@c {{{ Appendix I - Muq MUF for tinyMUCK MUF hackers
@node Appendix I - Muq MUF for tinyMUCK MUF hackers, MUF For Hackers Wrapup, Pragmatics, MUF For Hackers
@section Appendix I - Muq MUF for tinyMUCK MUF hackers

Some reasons I stuck with @sc{rpn} notation for Muq's first programming syntax:
@itemize @bullet
@item
A surprising number of my tinyMuck hacker friends reported that they actually @strong{liked}
tinyMuck @sc{muf}.  To my surprise!  (Before I surveyed them, I'd figured they all used it under
protest.)
@item
Forth was developed for interactive at-the-keyboard hacking -- I can't think offhand
of any other major language that was so designed.  (Excepting tcsh & kith!)  There is room
for a syntax which works well in realtime mode.
@item
I've never seen anyone seriously try to drag a Forthlike language into the
modern programming era:  I found it fascinating to explore how much it could
be improved with modern facilities without losing its essential character.
@item
I've always been distressed by how very bad tinyMuck @sc{muf} was -- in many
ways it combines the @strong{worst} aspects of the Algolic tradition (for example,
explicit compile-edit-debug cycles, black-box compilers) with the worst aspects of the
Forth tradition (for example, unreadable code, obscure bugs).  That the original
author of tinyMuck @sc{muf} was completely ignorant of Forth, compilers and interpreters
is an explanation but not a justification@dots{}

Why not a @sc{muf} that combined the @strong{best} of those traditions?
@end itemize

Here is a quick guide to differences between Muq @sc{muf} and tinyMuck @sc{muf} for
the experienced tinyMuck hacker:

@itemize @bullet
@item
Muq lets you execute code directly from the internal commandline:  No edit-compile-run
cycle.  You can also interact with Muq directly from the unix commandline (instead of
telnetting in) if you prefer -- I usually do my interactive @sc{muf} hacking in an
emacs shell window, which makes it trivial to paste code in, save printout, and edit
and re-run recent expressions.
@item
Muq gives you local variables in functions -- no more of those awful @code{swap drop rot dup}
sequences uglifying your code.  Local variable assignment syntax is @code{expr -> var} and
global variable assignment syntax is @code{expr --> var}.
@item
Muq gives you nice infix notations like @code{a.b[i]} for the common cases, to reduce
code ugliness.  The @code{a[i]} notation is used both for vectors and for the
btree-based indices, which get used like Perl hashes.
@item
Muq gives you a variety of new and improved datatypes: Floats, ints
good to over a thousand bits precision (with a modular expenentiation
function fast enough to use for public-key signature sorts of stuff),
structs, objects with multiple inheritance, hashed-btree based Index
objects (used in place of propdirs), vectors, Lisp-style Lists,
Perl4-style regular expressions, anonymous functions, thunks and
promises with implicit forcing, pretty much you name it.  And complex
numbers are on the way! @strong{grin}
@item
Muq gives you a variety of nice, vaguely C-like control constructs, including a
@code{case} statement and lots of loops.
@item
Muq gives you full-strength C-style printf()s (@code{]print}) -- man, I miss those in languages
like Java!  Also C-style sscanf()s (@code{unprint[}), C-style strftime (@code{printTime})
and lots more goodies.
@item
Muq systematizes the notation for stackblocks and introduces dozens of operators on them
like @code{|sort} and @code{|uniq}.
@item
Muq lets you declare the count of arguments accepted and returned by a function, and
verifies that the declaration is correct.  This is good documentation, and can prevent
lots of obscure stack usage bugs.
@item
Muq gives you pre-emptive multi-tasking, so you can write @sc{muf} code that runs awhile
(or even a daemon that runs indefinitely) without locking up the server completely.  With
this goes job forking, message streams with reader/writer synchronization, signals,
jobsets, sessions, tcp/ip and udp via socket objects, millisecond-accurate times and
sleeps@dots{}
@item
Muq gives you automatic storage management ("garbage collection") to allow serious
programming without serious C-style memory leaks or pointer bugs.
@item
Muq gives you a @code{]rootPopenSocket} primitive for running host subprocesses.  This lets
you easily interface the Muq server to external resources.
@item
Muq gives you packages to manage global namespace rationally, and dbfiles to divide the
db between hostfiles rationally.
@item
Muq hides server process boundaries, so you can interact with data and jobs on other Muq
servers across the Internet without even needing to know the data are remote.  (Underneath,
Muqnet uses both public-key and conventional crypto are used to secure remote operation.)
@item
Muq authenticates all message stream packets (including those from remote servers) -- spoofing
is much less of a problem on Muq.
@item
Muq was written with lots of attention to space and time efficiency --
for example, instruction dispatch overhead was less than 1/3 that of
fuzzball last I checked, and short strings are stored entirely within
the pointer, incurring zero heap space and deallocation overhead.
@end itemize


@c {{{endfold}}}
@c {{{ MUF For Hackers Wrapup
@node MUF For Hackers Wrapup, Function Index, Appendix I - Muq MUF for tinyMUCK MUF hackers, MUF For Hackers
@section MUF For Hackers Wrapup

If you've read this far, you now have a working understanding of the
core everyday programming facilities of Muq @sc{muf}.

There are lots more goodies available, but they are mostly useful
shortcuts and specialized support for particular problems, which you
can easily enough pick up as you go along by referring to the @sc{muf}
reference manual as needed.

Many useful examples of real-life @sc{muf} programming may be found in the
@code{muq/pkg} and @code{muq/pkg/Check} directories in the Muq source distribution.

@c {{{endfold}}}
@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
