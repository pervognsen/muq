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
@c =============================================

@node MUC For Hackers, MUC For Hackers Overview, Top, Top
@chapter MUC For Hackers

@menu
* MUC For Hackers Overview::
* Basics::
* Running the MUC shell::
* OpenGL Graphics in MUC::
* MUC For Hackers Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ MUC For Hackers Overview

@c
@node MUC For Hackers Overview, Basics, MUC For Hackers, MUC For Hackers
@section MUC For Hackers Overview

This tutorial is intended to provide a concise introduction
to Muq @sc{muc} for experienced programmers.

If you are not an experienced programmer, you may might prefer
read the @strong{Elementary Muc Programming} tutorial instead of
this one -- unfortunately, it hasn't been written yet.

@sc{muc} (Multi-User C) is one of the three core programming
notations supported by Muq, the other two being @sc{muf} (Multi-User
Forth -- a name traditional in the @sc{TinyMUCK} community) and
@sc{mul} (Multi-User Lisp).

@sc{muc} attempts to look and feel as superficially familiar to
the experienced C programmer as practical, while also working
effectively on the Muq virtual machine and interoperating well
with the other core Muq programming notations.

Since C is essentially an abstracted portable assembly language
designed for down and dirty systems hacking, while @sc{muc} is a
high-level sandbox interpreted scripting languages, some differences
between the two are not only inevitable but desirable.

NB: If it matters, I pronounce @sc{muc} as "moose", partly because
I'm Canadian, mostly to avoid phonetic confusion with "Muq" and
"MUCK" and such.


@c {{{endfold}}}
@c {{{ Basics

@c
@node Basics, Running the MUC shell, MUC For Hackers Overview, MUC For Hackers
@section Basics

You're assumed to know C backwards and forwards, so we won't waste time
on orientation, just cut to the chase:

There is (as yet?) no C-style preprocessor for @sc{muc}: In general
@code{#define} and kith are not supported.  As a special exception,
@example
#if (expression)
...
#else	/* optional */
...
#endif
@end example
is emulated by the compiler.  Since Muq compiles files incrementally
and the @code{#if} is emulated by the compiler, @code{expression} is
not limited to constant expressions: Arbitrary expressions may be
used, including function calls.  If @code{expression} is a bare
variable, the parentheses may be dropped.  For internal technical
reasons, this construct will only work at the top level, not
nested inside functions or other expressions.

Two styles of comments are supported:
@example
/* Traditional C style comments. Must currently be contained on one line. */
// C++ style comments running to end of line.
@end example

There is no address arithmetic whatever in @sc{muc}: You cannot modify
a pointer, and there is no way to point to part of an object, only to
the entire object.  Use code like @code{for (i=len; i --> 0;)a[i]=0;} instead
of C-style code like @code{for (i=len,p=&a[0]; i --> 0;)*p++=0;}.  There is
no C-style unary '&' operator, so C expressions like
@code{int*p=&a[5];} simply do no translate.  Similarly, there is no
C-style unary @code{*} operator.  This is also no C-style @code{->}
operator: @sc{muc} uses @code{a.b} where C would use @code{a->b}.

There is in general no direct access to host files, directories or
other resources from @code{muc}: Muq is primarily a sandbox
environment for building virtual worlds and hosting guests without
risking damage to the host filesystem or computer.  (The Muq virtual
machine does have commands for inbound and outbound TCP and UDP communication
and for spawning subprocesses, but for now they are best accessed from
@sc{muf}.)

Declarations and statements can be freely mixed in @sc{muc}, unlike
C: @code{@{int a=10;printf("a=%d\n",a);int b=1<<a;@}} is perfectly
good @sc{muc} syntax.

Since @sc{muc} is a high-level scripting language, not a systems
implementation langauge, expressions are evaluated
one by one in the order presented.  This means it is perfectly
legal, for example, to put @code{printf("Got this far!\n");} in
the middle of a @sc{muc} source file, outside of any function
definition.

The Muq virtual machine is a tagged archicture: the type
of any value can be determined by the interpreter by inspection, without
needing to know anything about the type of the variable holding it.

This means that in general any @sc{muc} variable can hold any type of
value without causing problems or misinterpretations, which in turn
means that @sc{muc} can and does ignore most variable type
declarations: @sc{muc} currently treats all the following as exactly
equivalent:

@example
int i=0;
byte i=0;
char i=0;
short i=0;
long i=0;
obj i=0;
@end example

I suggest that when in doubt you use @code{obj i;} -- all Muq
values including ints, chars and floats are objects (unlike,
say, C++ or Java, where they are special exceptions to the
object orientation), so everything is of type @code{obj}.

The Muq virtual machine provides garbage collection: In essence, this
means you cannot create a memory leak, so you can sling dynamically
created strings and objects around freely.  There is no
@code{malloc()} -- one typically uses various @code{make*()} functions
to allocate new store.  There is also no @code{free()}.

Most C arithmetic types and expressions should work in @sc{muc} just
as you expect.  There are three new binary operators: You may use
@code{a ! b} to compute the dot-product of two length-three vectors,
you may use @code{a >< b} to compute the cross-product of two such
vectors, and you may use @code{x ~ y} to compare floats or such
vectors for approximate equality (to about one part in 100,000) -- it
is usually a bad idea to compare floats for exact equality due to
accumulation of rounding errors.  You may also add, subtract,
multiply, divide, and negate floats and such vectors, and
also do floating point modular reduction.

The @code{distance(P,Q)} function will compute the distance between
points (three-vectors) P and Q, and @code{magnitude(V)} will compute
the length of vector V using the usual Euclidean square root of sum of
squares formula.

If you're feeling concise you can abbreviate @code{magnitude(V)} to
just @code{=V} -- the unary @code{=} is a synonym.  Similarly,
@code{|f} (unary vertical bar) is a synonym for @code{abs(f)} --
this is an approximation to the traditional @code{|f|} notation
for absolute value.

Floats are a bit less than @code{double} in precision. (59 bits.)

Ints are indefinite precision: Muq internally uses 62-bit arithmetic
until it gets an overflow, then switches automatically and
transparently to indefinite precision bignum arithmetic.  This means
@code{1<<1000} will produce a correct result in @sc{muc}, unlike in C
or Java.

The @code{+= and ++} type operators currently work only on
simple variables, not expressions.

There is an extra "**" operator for raising numbers to an exponent.

There is also an integer @code{exptmod(base,exponent,modulus)}
function which raises @code{base} to @code{exponent} mod
@code{modulus} efficiently enough for basic public-key style digital
signature computations, or of course just playing with number theory.

You also have available
@code{acos()} @code{asin()} @code{atan()} @code{atan2()} @code{cos()} @code{sin()}
@code{tan()} @code{cosh()} @code{sinh()} @code{tanh()} @code{exp()} @code{log()}
@code{log10()} @code{sqrt()} @code{abs()} @code{ffloor()} @code{fceiling()}
@code{floor()} @code{ceiling()} @code{truncate()} @code{round()}
all more or less direct from the C math library.

Character constants are distinct from int constants in the Muq virtual
machine: Use @code{'a'} as in C to specify a character constant.  Use
@code{int i=charInt('a');} and @code{char c=intChar(60);} to convert
back and forth.

Strings are not null-terminated.  You can concatenate them using '+'
if you wish; Many other string operations are provided.  (For now,
you'll have to check the @sc{muf} reference manual.  Most can be
called directly from @sc{muf}.)  As with vectors (strings are in fact
a special kind of vector) use @code{length(string)} to get the length
of a string.

String constants are specified using double-quotes as usual --
modifying the contents of strings created this way is currently
possible but discouraged and likely to be forbidden in future Muq
releases.

Regular expressions using a close approximation to Perl4 syntax
and semantics are available using the @code{vars ~= /regex/ (string);}
idiom:  Think of the regex as naming a function.  The first return
value is a flag indicating whether the match was successful,
subsequent return values correspond to parenthesized matches:
@example
muc>
int i;char* s;
muc>
muc>
i,s ~= /^a(b*)c$/ ("abbc");
muc>
i;s;
muc>  t
muc>  "bb"
i,s ~= /^a(b*)c$/ "abbc";
muc>
i;s;
muc>  t
muc>  "bb"
i,s ~= /^a(b*)c$/ sprintf("a%sc","bb");
muc>
i;s;
muc>  t
muc>  "bb"
i,s ~= /^a(b*)c$/ sprintf("a%sc","cc");
muc>
i;s;
muc>  nil
muc>  ""
@end example
Currently the regular expression delimiter @strong{must} be @code{'/'},
must follow a @code{'~='} and the regular expression must all be on
one line.  (Future releases will allow other delimiters and also
support @code{var ~= s/regex/replacement/ (string);} and
@code{var ~= tr/A-Z/a-z/ (string);} syntax.)

Most C control structures should work just as you expect in @sc{muc}.

There is however no C-style statement-level comma operator as
in C @code{for (a=0, b=len;   a<b;   ++a, --b);} -- comma is instead
used for multiple assignments such as @code{a,b = b,a;} and
(more importantly) @code{a,b,c = threevalued();}.
@example
muc> 
int a=1;
muc> 
int b=2;
muc> 
a,b=b,a;
muc> 
a;
muc>  2
b;
muc>  1
@end example
This means you must rewrite the above @code{for} loop as
@code{for (a,b = 0,len;  a<b;  a,b = a+1,b+1);}.  Life is tough.

Also, 'switch' is not yet implemented, nor is 'goto'.

Cascaded assignments (@code{a=b=0;}) are not yet supported.

@code{printf("...\n",a,b...);} and @code{sprintf(...);}
should work just as you expect.  Also @code{gets();} to
read a line from standard input.

Also available is @code{sscanf}, but due to the lack of
C-style unary '&' in @sc{muc} is uses multiple return
values in place of pointer arguments:
@example
muc> 
sscanf("12 128.45 hike!", "%d %f %s");
muc>  12 128.45 "hike!"
float f;char*s;int i;
muc> 
muc> 
muc> 
i,f,s = sscanf("12 128.45 hike!", "%d %f %s");
muc> 
i; f; s;
muc>  12
muc>  128.45
muc>  "hike!"
@end example
Some might find this syntax actually prettier than what C does.

There is a small potential @strong{gotcha} with boolean values: C
treats zero and NULL as being 'false' and everything else as being
'true': @sc{muc} treats only @code{nil} as being 'false'.  (There
are however @sc{null} and @sc{false} synonyms for @code{nil}, to
make C programmers feel a bit more at home.) This means
you cannot do @code{for (i=10; i; i--);} and expect it to terminate.
Use explicit tests instead and you'll be fine: @code{for (i=10; i>0; i--);}

Another small potential @strong{gotcha} is that @sc{muc} allows characters
in identifiers which C does not: In particular '?' is allowed because
other Muq languages have so many predicates such as @code{vector?} --
so be careful to write @code{int a = b ? c : d;} not @code{int a=b?c:d;}
in which both the '?' and the ':' are likely to cause problems.

You may use @code{< > <= >= = !=} to compare any two Muq values whatever:
comparing an integer to a float is kosher (and will do the right thing)
as is comparing an integer to an object.  The latter sort of comparison
will return consistent results but is not otherwise specified: The
intention is to only allow rational sorting and lookup of arbitrary
sets of values.  Strings compare using case-sensitive @sc{ascii}
collating order.  (Use @code{lt gt le ge eq ne} to do case-insensitive
string compares.)

The cheapest small chunks of storage you can allocate are vectors,
which behave like one-dimensional arrays which can hold any type
of value in any slot.

As in C, slots are numbered starting at zero, not at one.

Use @code{obj myvec=makeVector(0,10);} to generate a ten-slot vector
initialized to zeroes.

Use @code{myvec[i]=myvec[i+1];} style syntax to read and write slots.

You may use @code{int len=length(myvec);} to get the length of a
vector in slots.  If you are in a concise mood, you may use @code{int
len=#myvec;} instead.  Similarly, you may if you wish use
@code{+/vector;} as a shorthand for @code{sum(vector);} to compute the
sum of the elements in a vector, and @code{*/vector;} as a shorthand
for @code{product(vector);}.

You may use negative indices to access slots starting from the
far end: @code{myvec[-1]} gives the value of the last slot.

There is a special syntax @code{@{a,1,i+3@}} which may be used
to create (in this case) a three-slot vector containing the
given values:  This syntax may be used anywhere any constant
can appear in an expression.  In particular, it may be used
to construct arguments to functions compactly.  By nesting
this construct you may conveniently create small tree structures
on the fly: This can be useful for example in functions which
recursively rewrite a parsetree.

There are specialized types of vectors which hold only bytes, shorts,
32-bit ints, 32-bit floats, or 64-bit floats.  These vectors are
intended primarily for doing OpenGL graphics from @sc{muc}, since the
OpenGL API calls expect simple numeric vectors, not Muq's native
internal datastructures.

There are separate calls for creating these types of vectors --
the following examples create length-ten specialized
vectors initialized to zero:

@example
byte*   p=makeVectorI08(0,10);	/* 'byte' and 'char' are synonyms. */
short*  p=makeVectorI16(0,10);
int*    p=makeVectorI32(0,10,0);
float*  p=makeVectorF32(0.0,10);
double* p=makeVectorF64(0.0,10);
@end example

(Again, remember that the above type declarations are currently
completely ignored: Each variable could have been as well declared
@code{obj p=...;}.)

As with plain Muq vectors, there is special @sc{muc} syntax for
creating short vectors on the fly in the middle of an expression
by explicit enumeration of contents:

@example
(char*) @{0,a+3,f(x)@}
(short*) @{0,a+3,f(x)@}
(int*) @{0,a+3,f(x)@}
(float*) @{0.0,a+3.0,f(x)@}
(double*) @{0.0,a+3.0,f(x)@}
@end example

In the above example, the types @code{do} matter, they determine
the type of vector created.  Other than this special construct,
there is @strong{no} cast operator in @sc{muc}.

There are no multidimensional arrays yet, although you can construct
vectors of vectors.

Muq has Index objects which are used similarly to hashes in Perl
or Dictionary objects in some other systems:  they map an
arbitary set of keys to matching values.  They may be created by
@code{obj myindex=makeIndex();} values may be added by
@code{myindex["key"]=someval;} and retrieved by @code{obj val=myindex["key"];}
You will shortly be able to remove keys by doing @code{delete myindex["key"];}
but this isn't supported quite yet.

Muq Index objects use sorted B-trees internally, so they can potentially
scale to very large numbers of key-val pairs.  Muq also has Hash objects
which use hashed instead of sorted B-trees, which may sometimes buy
some lookup speed at the cost of the additional space used internally
to store the hashcodes:  You may use @code{obj myhash=makeHash();} to
create one, after which usage is the same as with Index objects.

You may use unary @code{^} as a synonym for @code{return}:  This can
look better in very compact expressions.

Use @code{inPackage("mypackage");} to select a new package:  This
is somewhat similar to doing @code{cd directory} in Unix, except
that packages may not be nested.  If the named package does not
exist, it will be created.

Use @code{ls(obj);} to list the fields, values or properties
associated with object, vector or value @code{objdx}.  For example,
@code{ls(.u);} will list known users, @code{ls(.db);} will list
mounted databases, @code{ls(.cfg);} will list the server compiletime
configuration parameters, @code{ls(.muq);} will list the server
runtime configuration parameters, and @code{ls(.lib["muf"];)} will
list all exported (public) symbols in the @code{muf} package.  (Be
warned that the latter listing is fairly long -- currently over 2500
symbols.)

Muq objects actually have four sets of properties: public,
hidden, system and admins.  (The latter two are in general
only of interest to system administrators.)  Use
@code{lsh(obj);} to list the hidden properties on @code{obj}.
Use @code{lsa(obj);} and @code{lss(obj);} to list the
admins and system properties.

Unix uses a leading separator @code{/} to indicate an
absolute path (@code{/usr/home/cynbe/tmp} vs @code{cynbe/tmp}).
Muq uses a similar convention, but with a leading dot
instead of slash, since dot is the matching C separator.
Thus for example @code{.lib} is the absolute pathname for the global
list of standard packages, @code{.u} is the absolute pathname
for the global list of known users, and @code{.db} is the
absolute pathname for the global list of mounted databases.
(A "database" in Muq is comparable to a filesystem in Unix.)

Use @code{root();} to get the root object itself.

In similar fashion, @code{job();} will give you the currently
running job:  Do @code{ls(job());} to list all the properties
on it.  To compactly access individual properties of the job
you may use the @code{@.lib} syntax. For example, @code{@.pid}
is the PID for the current job, and @code{@.package} returns
the currently selected package.  (If you need a mnemonic,
think of the '@' as a little whirling turbine slaving away
doing your job's computation.)

There is as yet no support for defining structs or classes
in @sc{muc}.

There is currently no @code{sizeof} in @sc{muc}.

All C reserved words are also reserved words in @sc{muc} and in
addition @sc{muc} has the following reserved words:

@example
after
bit
byte
cilk
class
delete
endif
eq
ge
generic
gt
inlet
le
lt
macro
method
ne
noreturn
obj
public
spawn
sync
try
with
@end example

(Many of these are currently unused.)

The Muq virtual machine provides literally hundreds of functions,
notably including the OpenGL API.  For now, you'll have to peek
at the Muf Reference Manual for a listing of them.  Almost all
of them should be usable directly from @sc{muc}.

In addition to these hardcoded functions, the Muq softcode libraries
have various other useful functions, in particular
@code{muq/pkg/100-C-utils.t} and @code{muq/pkg/100-C-list.t}.

At the time of writing, @sc{muc} is about two weeks old, and undoubtedly
contains many deficiences not mentioned here.  Caveat programmer.


@c {{{endfold}}}
@c {{{ Running the MUC shell

@c
@node Running the MUC shell, OpenGL Graphics in MUC, Basics, MUC For Hackers
@section Running the MUC shell

To run the @sc{muc} shell, just type @code{muc:shell} at the @sc{muf} shell
prompt:

@example
root: 
muc:shell
MUC (Multi-User C) shell starting up
root> 
printf("Hello, world!\n");
Hello, world!
root> 
1 << 130;
root>  1361129467683753853853498429727072845824
@end example

Remember to end each command with a ';' or '@}' as required by C
syntax!

@c {{{endfold}}}

@c {{{ OpenGL Graphics in MUC

@c
@node OpenGL Graphics in MUC, MUC For Hackers Wrapup, Running the MUC shell, MUC For Hackers
@section OpenGL Graphics in MUC

Muq supports OpenGL graphics as of release @code{-1.45.0}, provided that
you compile the server on a machine with appropriate libraries.

On Debian, this means you typically need the following packages
installed:

@example
mesag3
mesag-dev
glutg3
glutg3-dev
@end example

(If anyone will tell me what the required libraries are for other
distributions, say RedHat, I'll be happy to list that information
here also.)

If these packages are missing, Muq will still compile fine, but
the OpenGL calls will be stubbed out to error traps.

The main missing OpenGL functionality as of Muq -1.45.0 relates
to input (from mouse and such).  Nearly all the drawing commands
should work.  Almost none of them have been tested, however.

Here is a transcript of using MUC to draw the OpenGL teapot:

@example
cynbe@@chee muq/c> ./muq
Opening db ROOTDB...
Opening db KEYW...
Opening db MUF...
Opening db LISP...
Opening db QNET...
Opening db ANSI...
Opening db DBUG...
Opening db DICT...
Opening db DIFI...
Opening db GEST...
Opening db LNED...
Opening db MUC...
Opening db MUFV...
Opening db OMSH...
Opening db OMUD...
Opening db PUB...
Opening db QNETA...
Opening db RMUD...
Opening db TASK...
Opening db TLNT...
Opening db muqn...
MUF (Multi-User Forth) shell starting up
Hints from me$s.loginHints$h[1,2...]:
  For configuration menu do:       config
  To exit server from console do:  <CTRL>-C or rootShutdown
root: 
muc:shell
MUC (Multi-User C) shell starting up
root> 
glutInitDisplayMode( GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH );
root> 
glutCreateWindow("Teapot");
root>  1
float* light_diffuse  = (float*) @{ 1.0, 1.0, 1.0, 1.0 @};
root> 
float* light_position = (float*) @{ 1.0, 1.0, 1.0, 0.0 @}; 
root> 
glLightfv( GL_LIGHT0, GL_DIFFUSE, light_diffuse );
root> 
glLightfv( GL_LIGHT0, GL_POSITION, light_position );
root> 
glEnable( GL_LIGHTING );
root> 
glEnable( GL_LIGHT0 );
root> 
glEnable( GL_DEPTH_TEST );
root> 
glMatrixMode( GL_PROJECTION );
root> 
gluPerspective( 40.0, 1.0, 1.0, 10.0 );
root> 
glMatrixMode( GL_MODELVIEW );
root> 
glutSwapBuffers();
root> 
gluLookAt( /*eye:*/ 0.0,0.0,3.0, /*centre:*/ 0.0,0.0,0.0, /*up:*/ 0.0,1.0,0.0);
root> 
glTranslatef( 0.0,0.0, -1.0 );
root> 
glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
root> 
glutSolidTeapot( 1.0 );
root> 
glutSwapBuffers();
root> 
glFlush();
root> 
sleepJob( 1000 );
root> 
glutDestroyWindow( glutGetWindow() );
root> 
@end example


@c {{{endfold}}}
@c {{{ MUC For Hackers Wrapup
@node MUC For Hackers Wrapup, Function Index, OpenGL Graphics in MUC, MUC For Hackers
@section MUC For Hackers Wrapup

What's the most important thing I forgot? :)

@c {{{endfold}}}
@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
