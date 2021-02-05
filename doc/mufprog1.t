@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@c To do:
@c Move the 'substring' explanation of why indexing from '0' makes
@c sense from introductory to intermediate chapter, replace with
@c forshadowing reference.  Maybe substitute one of the 'explode'
@c type functions.
@c Kuranes thinks thats what seperates a tutorial from a manual: drama.
@c
@c Should we change the titles to "How do I X" for various X?
@c This might grab people more where the live, especially when
@c referring back to the tutorial for something half-remembered.
@c If that's too verbose, maybe just "Doing X" or "Doing X in MUF"?
@c
@c I think -all- of this would be much more fun in the context
@c of a working mud... :)

@node Elementary Muf Programming, Elementary Muf Programming Overview, Top, Top
@chapter Elementary Muf Programming

@menu
* Elementary Muf Programming Overview::
* The Spirit of MUF::
* MUF Words Are Whitespace-Delimited::
* MUF Evaluates Words Right-to-Left::
* The MUF Stack::
* Fun With The Stack::
* Fun With String::
* Defining New Muf Words::
* Fun With Loops::
* Fun With Variables::
* Fun With if::
* Fun With Arithmetic::
* Fun With Blocks::
* Fun With ]print::
* Fun With Indices::
* Fun With Packages::
* Fun With Messages::
* Elementary Muf Cheatsheet::
* Elementary Muf Programming Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Elementary Muf Programming Overview

@c
@node Elementary Muf Programming Overview, The Spirit of MUF, Elementary Muf Programming, Elementary Muf Programming
@section Elementary Muf Programming
@cindex Muf, acronym
@cindex Muf tutorial
@cindex Tutorial, Muf (elementary)

This chapter is intended to provide a gentle introduction to
Muq @sc{muf}.  (@sc{muf} is a name retained from tinyMuck's
@sc{muf} programming language: I believe it originally stood
for Multi-User Forth.)  You should not need any previous
familiarity with programming or @sc{muf} to follow this
chapter; If you find it lapsing into computer geek jargon
without explanation or otherwise becoming needlessly hard to
follow, please email cynbe@@sl.tcp.com and explain the
problem and perhaps suggested improvements. (Thanks!)

If you are an experienced programmer, you may wish to
read the @strong{MUF For Hackers} tutorial instead of
this one.

A hammer and handsaw suffice to build anything from a chair
to a chateau, but professional carpenters speed and simplify
their work by using a bewildering array of more specialized
power- and hand-tools.  In this chapter, we introduce you to
the @sc{muf} equivalent of hammer and handsaw: When done,
you should have the tools to program just about anything you
want, but to learn about the many @sc{muf} power tools that
can speed and simplify your programming, you'll need to go
on to the Intermediate @sc{muf} chapter (and beyond).

This chapter is @emph{not} intended to explain all @sc{muf}
functions and primitives mentioned in full detail @xref{Core
Muf,,,mufref.t,Muf Reference}.

You are encouraged to try out examples given interactively
as you read this tutorial, and to otherwise experiment.
Play is the natural human way of learning, is much more fun
than just reading, and increases recall later.  You can't
break Muq by playing around trying to learn.  Or if you do,
we'd be delighted to hear about how you did it!

@c {{{endfold}}}
@c {{{ The Spirit of MUF

@node The Spirit of MUF, MUF Words Are Whitespace-Delimited, Elementary Muf Programming Overview, Elementary Muf Programming
@section The Spirit of @sc{muf}
@cindex Muf, spirit of
@cindex Spirit of Muf
@cindex Hello world in Muf
@cindex Muf, Hello world
@cindex Kay, Alan
@cindex Simple things
@cindex Complex things

It helps to understand right from the start the spirit of
the @sc{muf} design and implementation.

@sc{muf} is not intended to be a maximum-machine-efficiency
programing language like C or ForTran, nor a
maximum-sophistication language like Lisp or Haskell, nor a
maximum-reliability language like Eiffel or Ada.

Rather, @sc{muf} is intended to be a simple, predictable
language in which novices and experienced programmers alike
may interactively perform little programming tasks on Muq.

By itself this makes @sc{muf} neither better nor worse than
other programming languages.  Different tasks and different
audiences call for different designs, in the computer world
no less than in other areas of engineering.

The spirit of @sc{muf} calls for providing simple tools
which allow solving simple tasks with an absolute minimum
of syntactic clutter and busywork, while providing
facilities sufficient for solving more complex tasks
when needed.

@example
Simple things should be simple, 
complex things should be possible.
   -- Alan Kay (creator of Dynabook, Smalltalk...)
@end example

As a quick illustration of the spirit of muf, here is the
simple function hw printing out "Hello world!" in various
languages:

@example
@sc{muf}:    : hw "Hello world!\n" , ;
@sc{c}:      void hw(void) @{ puts("Hello world!\n"); @}
@sc{Pascal}: procedure hw begin writeln('Hello world!') end;
@sc{Lisp}:   (defun hw () (format t "Hello world!~%"))
@end example

As you can see, as a simple notation for doing simple tasks,
@sc{muf} compares quite nicely with the competition.

@c {{{endfold}}}
@c {{{ MUF Words Are Whitespace-Delimited

@node MUF Words Are Whitespace-Delimited, MUF Evaluates Words Right-to-Left, The Spirit of MUF, Elementary Muf Programming
@section MUF Words Are Whitespace-Delimited
@cindex Muf, word delimiting
@cindex Word delimiting in Muf
@cindex Quotation in Muf
@cindex Muf quotation syntax
@cindex Comments in Muf
@cindex Muf comment syntax

As befits a very simple language, @sc{muf} uses a very
simple rule to understand the instructions you
type in for it:

@quotation
Lines of text you type in are separated into words
surrounded by whitespace.
@end quotation

Whitespace is anything that doesn't put ink on the paper
when printed: spaces, tabs, newlines...  @sc{muf} treats
all whitespace, in any amount, alike.  Thus, all the
following mean exactly the same thing as far as @sc{muf}
is concerned:

@example
: hw "Hello world\n" , ;
     :    hw    "Hello world\n"    ,    ;

: hw
  "Hello world\n" ,
;

:
hw
"Hello world\n"
,
;
@end example

In particular, note that all printing characters are alike as
far as @sc{muf} is concerned when it comes to forming words;
each of the following lines contains @emph{one} word as far
as @sc{muf} is concerned:

@example
oneword
1word
one-word
one,1--yes>ONE<--word!
$#@@!^a,_[%$|]~'"q.+-*/n
@end example

They are all surrounded by whitespace, and that's all @sc{muf}
cares about.  A very simple, predictable mind, @sc{muf} has!

@quotation
Note: As a practical matter, it is best to make words from
letters and dashes.  In particular, leading '#' characters
are good to avoid, as they will be acquiring special
meanings in future releases.
@end quotation

@sc{exceptions}: The only exceptions to this rule are a few
situations involving quotations of various sorts.  For
example, we would like to be able to enter a string to be
printed like

@example
"Hello world!"
@end example

and have @sc{muf} treat it as a single piece that we can
print out in one operation, rather than having to quote
and print each word one at a time.  So @sc{muf} has a
special hack just for words which begin with a doubleQuote:
it takes all text up until the next doubleQuote as
constituting a single quotation, whitespace and all.

A similar quotation problem arises when trying to quote
single characters: suppose we want to quote a blank?  A nice
syntax for doing this is just:

@example
' '
@end example

But this obviously won't work if @sc{muf} does absolutely
all separation of input text based on whitespace: it would
interpret the above as two single quotes or something
equally unhelpful.  So, again, a special rule is made for
words beginning with single-quotes.

A third such quotation problem arises when we want to
include comments for humans in our @sc{muf} code without
confusing @sc{muf} itself, which is @emph{far} too stupid
to understand them.  We certainly don't want to have to
quote every single word in our comments.  So, again, we
stick a special little hack in @sc{muf} telling it that
if it sees a word consisting of just a left parenthesis,
it should completely ignore everything until the next
right parenthesis:

@example
( This is a comment -- completely invisible to @sc{muf}. )
( This is also a comment. )
( I am invisible too. Whee! )
(I am not a comment! I don't start with a whitespace-surrounded '('! )
@end example

Note: The closing parenthesis must be preceded by whitespace.  This
allows you to safely use parenthesis in your comments, since in normal
English usage a right (left) parenthesis is normally not preceded
(followed) by whitespace.

@c {{{endfold}}}
@c {{{ MUF Evaluates Words Right-to-Left

@node MUF Evaluates Words Right-to-Left, The MUF Stack, MUF Words Are Whitespace-Delimited, Elementary Muf Programming
@section @sc{muf} Evaluates Words Right-to-Left

Once @sc{muf} has broken your command into words, how does
it carry them out?

Remembering that @sc{muf} is a very simple-minded little
program, you will not be suprised that it follows a very
simple-minded little rule: It has a little dictionary of
simple tasks it knows how to do, and it just works its way
left-to-right through the words you gave it, looking each
word up in its dictionary and performing the corresponding
action.  If you type a word that isn't in its dictionary, it
doesn't guess or deduce what the word means, it just stops
and complains about you being so unkind as to use a word it
doesn't know.

In a moment, we'll give some examples of words that @sc{muf}
knows.  (Later on, we'll show you how to teach @sc{muf} new
words, which is where the real fun begins!)  But first, let
me note that, like every good rule, the left-to-right one
has a few exceptions.  There are times when we'd like
@sc{muf} to do the same sequence of words a dozen times (or
perhaps a thousand or a million) without having to type them
in a dozen times: @sc{muf} knows some special words which
allow you to do this.  We'll get to these presently.

@c {{{endfold}}}
@c {{{ The MUF Stack

@node The MUF Stack, Fun With The Stack, MUF Evaluates Words Right-to-Left, Elementary Muf Programming
@section The @sc{muf} Stack
@cindex Data stack, Muf
@cindex Stack, Muf
@cindex Muf data stack
@cindex Muf loop stack
@cindex Loop stack, Muf
@cindex Pop, stack function
@cindex Swap, stack function
@cindex Rot, stack function
@cindex Muf 'pop' function
@cindex Muf 'rot' function
@cindex Muf 'swap' function

Think of @sc{muf} as a very quick and eager assistant which
is very eager to please, but just @emph{extraordinarily}
stupid.

If you were to give a series of objects to such an assistant
one at a time, what do you suppose it would do with them?

What a human helper of this type might do is difficult to
say, but what @sc{muf} will do in this situation is
perfectly predictable:

It will make a neat little pile of them, one atop the other,
and keep adding each new item to the top until you tell it
otherwise.

This little pile behaves much like those spring-loaded
stacks of plates at cafeterias: It is much easier to put
something on the top, or to remove the top item, than it is
to get at things lower down.  So we traditionally call this
little pile "the stack".

Note: While @sc{muf} is a simple-minded little helper, it is
not entirely without subtlety: It has a second stack of its
own that you rarely get to see.  When we get to discussing
this, we'll distinguish between the "data stack", described
above, and this hidden "loop stack".  For now, however, the
data stack is the only one we're concerned with, so we'll
follow the usual custom of simply referring to it as "The
Stack".

When you are playing with @sc{muf}, it is very helpful to
see the contents of the stack, so after it finishes each
command, @sc{muf} prints out a line consisting of a word
like "stack:" followed by the contents of the stack.  If
there are too many things on the stack to show them all
(there might be thousands) it shows just the top few.

Here is an example of what you will see if you feed the
words "This is a test" to @sc{muf} one at a time.  We'll
give lots of examples like this in this tutorial: I strongly
encourage you to actually try them out!  Remember to put
each word in double quotes for this example:

@example
Stack:
"This"
Stack: "This"
"is"
Stack: "This" "is"
"a"
Stack: "This" "is" "a"
"test"
Stack: "This" "is" "a" "test"
@end example

@c {{{endfold}}}
@c {{{ Fun With The Stack

@node Fun With The Stack, Fun With String, The MUF Stack, Elementary Muf Programming
@section Fun With The Stack
@cindex Lucy, I love

Things you can do with the stack:

@noindent
Pop things off it:

@example
Stack: "This" "is" "a" "test"
pop
Stack: "This" "is" "a"
pop
Stack: "This" "is"
pop
Stack: "This"
pop
Stack: 
pop
Stack: 

**** Sorry: Stack underflow

Stack: 
@end example

Note that when I accidentally tried to pop an empty stack,
@sc{muf} complained.  (It didn't really sound very sorry.
But then, it wasn't really very accidental either
@emph{grin}.)

You'll see that complaint a lot when you play with @sc{muf},
unless you are just inhumanly precise.  It doesn't do any
harm, other than stopping your command from getting any
further.  There's no secret log recording how often you get
stack underflow that the system gurus read and snicker over.
Honest!  Mostly because the system gurus would probably lead
the list@dots{}

@noindent
Push things back on the stack, more than one at a time:

@example
Stack:
"This" "is"
Stack: "This" "is"
"yet" "another" "test" "--" "really!"
Stack: "This" "is" "yet" "another" "test" "--" "really!"
@end example

@noindent
Pop things back off the stack, more than one at a time:

@example
Stack: "This" "is" "yet" "another" "test" "--" "really!"
pop pop
Stack: "This" "is" "yet" "another" "test"
pop pop pop pop
Stack: "This"
pop
Stack: 
@end example

@noindent
Swap the top two things on the stack:

@example
Stack: 
"1" "2" "3" "4"
Stack: "1" "2" "3" "4"
swap
Stack: "1" "2" "4" "3"
pop
Stack: "1" "2" "4"
swap
Stack: "1" "4" "2"
@end example

@noindent
Circulate (rotate) the top three things on the stack:

@example
Stack: "1" "4" "2"
rot
Stack: "4" "2" "1"
rot
Stack: "2" "1" "4"
@end example

(Forth code, and old-time @sc{muf} code, used to be full of
@code{swap}s and @code{rot}s because there weren't good
variables, so the stack got over-used.  Nowadays, you very
seldom see them in good Muq @sc{muf} code.  But they can
still occasionally be handy when playing around
interactively.  We'll explain variables in a bit!)

@c {{{endfold}}}
@c {{{ Fun With String

@node Fun With String, Defining New Muf Words, Fun With The Stack, Elementary Muf Programming
@section Fun With String
@cindex Lucy, I love
@cindex Join, string function
@cindex stringUpcase, string function
@cindex stringDowncase, string function
@cindex stringMixedcase, string function
@cindex Substring, string function
@cindex String function 'join'
@cindex String function 'stringUpcase'
@cindex String function 'stringDowncase'
@cindex String function 'stringMixedcase'
@cindex String function 'substring'

Text is a Big Deal on interactive systems like muds: Text is
what people type in, text is what gets displayed on their
terminals, text is what the programs are composed of, text
is used for people's names @dots{} text is just all over!

For some reason, programmers insist on referring to text as
"string".  The logic of this escapes me, but the standards
Muq follows do this too, so we'll do likewise.

@sc{Muf} has a lot of words for doing things with strings.

Here are some examples:

@noindent
Sticking two strings together:

@example
Stack: 
"String1" "String2"
Stack: "String1" "String2"
join
Stack: "String1String2"
@end example

@noindent
Sticking three strings together:

@example
Stack: 
"String1" "String2" "String3"
Stack: "String1" "String2" "String3"
join
Stack: "String1" "String2String3"
join
Stack: "String1String2String3"
@end example

@noindent
Sticking three strings together done all on one line:

@example
Stack: 
"String1" "String2" "String3" join join
Stack: "String1String2String3"
@end example

@noindent
Counting the number of characters in a string:

@example
Stack: "String1String2String3"
length
Stack: 15
@end example

@noindent
Converting between upper, lower, and mixed cases:

@example
Stack:
"I love Lucy"
Stack: "I love Lucy"
stringUpcase
Stack: "I LOVE LUCY"
stringDowncase
Stack: "i love lucy"
stringMixedcase
Stack: "I love lucy"
@end example

(Notice that @sc{muf} is too stupid to capitalize "Lucy" when
going to mixed case.  It doesn't know anything about names.
It does know about "I" and capitalizing the first word in a
sentence, however, which isn't bad for such a simple-minded
little program.)

@noindent
Getting a substring from the middle of a string:

@example
Stack:
"abcdef"
Stack: "abcde"
1 4 substring
Stack: "bcd"
@end example

'Substring' numbers letters starting from zero,
so 'b' is letter number '1' in "abcdef".  'Substring' extracts
letters until it gets to just @emph{before} the second
letter number given, which was '4' in this case.  So in this
case, it extracts characters number one, two, three: 'b',
'c', 'd'.

(This will probably seem a peculiar way of doing business to
you, but turns out to be convenient when writing lots of
programs to work with strings.  For example, when extracting a
sequence of adjacent substrings, the ending index for one
string is the same as the starting index for the next
string, which saves adding or subtracting one.)

@c {{{endfold}}}
@c {{{ Defining New Muf Words

@node Defining New Muf Words, Fun With Loops, Fun With String, Elementary Muf Programming
@section Defining New Muf Words
@cindex Muf words, defining
@cindex Defining Muf words
@cindex Define-word operator
@cindex Muf functions, defining
@cindex Defining Muf functions
@cindex : operator
@cindex Define-word: operator
@cindex ; operator
@cindex Join3 string function
@cindex String function 'join3'
@cindex , function
@cindex Comma function
@cindex Printing string (comma function)
@cindex String, printing (comma function)

Suppose you find yourself joining three strings together frequently:

@example
Stack: "String1" "String2" "String3"
join join
Stack: "String1String2String3"
@end example

You'd like to have a single word that does this, to save
a little typing.  (Later we'll see a built-in way of joining
groups of strings.)  Well, @sc{muf} may be simple-minded, but
it @emph{does} have an excellent memory, and is good at
learning new tricks, provided we can explain them precisely.
Let's teach @sc{muf} a new word @code{join3} that joins three
strings together by doing two @code{join}s:

@example
Stack:
defineWord: join3   join join   ;
Stack:
"String1" "String2" "String3"
Stack: "String1" "String2" "String3"
join3
Stack: "String1String2String3"
@end example

What could be simpler?

Actually, programmers are much too lazy to type a word as
long as "defineWord:" all the time, so @sc{muf} allows you
to abbreviate this word to just ":" --- saving you eleven
whole characters of typing on every word you define!

The general way to teach @sc{muf} a new word is:

@example
Type a colon to tell @sc{muf} that you are defining a new word.
Type the name of the new word.
Type the words which @sc{muf} should do each time it sees the new word.
Type a semi-colon to tell @sc{muf} that you are finished defining the word.
@end example

Once you've defined a new word, it works just like the
built-in words.  In particular, you can use it to define
more words.  Let's define a @code{join4} that uses our @code{join3}:

@example
Stack:
: join4   join3 join   ;
Stack:
"String1" "String2" "String3" "String4"
Stack: "String1" "String2" "String3" "String4"
join4
Stack: "String1String2String3String4"
@end example

Now you know almost enough to follow the "Hello world!" word
we defined when discussing the spirit of @sc{muf}:

@example
: hw "Hello world!\n" , ;
@end example

Clearly, @code{hw} is the name of the word, the @code{:} and
@code{;} are just the markers for the start and end of the
word definition, and "Hello world!\n" is just the string to be
printed.  (The "\n" makes @sc{muf} start a new line.  This
is a convention borrowed from C.  The 'n' stands for "new
line" and the '\\' tells @sc{muf} that the next letter is
special.)  That leaves only the comma unexplained, so it is
not too hard to guess that comma is the @sc{muf} word for
printing a string to the user's screen.

Let's try defining a word that prints several lines, to see
if we have got the idea right:

@example
Stack:
: print-4-lines "Line1!\n" , "Line2!\n" , "Line3!\n" , "Line4!\n" , ;
Stack:
print-4-lines
Line1!
Line2!
Line3!
Line4!
Stack:
@end example

@noindent
Neat!

The alert reader may be wondering if the words we're
defining become available to everyone using @sc{muf} on the
system, and whether they will be there the next time you run
@sc{muf}.

It would be an awful mess if every word defined by one user
immediately appeared in the @sc{muf} run by every other
user: Different users might wind up redefining each other's
words and getting very confused when words suddenly appeared
or disappeared or changed.

So unless you do something special, words you define are
only visible to you.  But they @emph{will} be there for you
next time you run @sc{muf}, unless you delete them.  Later
on, we'll show you how to make words available to other
people when you want, and how to take advantage of
nonstandard packages of words that other people may have
made available for you.

Note: What we are calling 'words' (a traditional name in
Forth circles, Forth being a distant ancestor of @sc{muf})
are called various other things in other programming
languages, and even by other @sc{muf} programmers.  You'll
most frequently see them called "functions", "subroutines",
"procedures" or "operators".  These names all mean much the
same thing, and we use the terms interchangably in the Muq
@sc{muf} documentation.  I usually call them 'functions', a
term loosely derived from mathematics and popular among C
programmers.

@c {{{endfold}}}
@c {{{ Fun With Loops

@node Fun With Loops, Fun With Variables, Defining New Muf Words, Elementary Muf Programming
@section Fun With Loops
@cindex Loops in Muf
@cindex Muf loops
@cindex For loop in Muf
@cindex Muf 'for' loop
@cindex Muf 'depth' function
@cindex Depth function
@cindex Stack 'depth' function

Let's reconsider our function to print four lines:

@example
: print-4-lines "Line1!\n" , "Line2!\n" , "Line3!\n" , "Line4!\n" , ;
@end example

This is a rather repetitious way to print four lines, and
defining function to print a thousand or a million lines
that way would be ridiculous.  We'd like to have a way to
tell @sc{muf} to do something lots of times without actually
having to list it that many times.

The @code{for} loop is one way to do this.  (As we'll see,
@sc{muf} has lots of different loops, each designed to
simplify programming some particular kind of repetitive
task.  We'll also see that @sc{muf} lets us define new kinds
of loops ourself if we want to -- something most programming
languages don't allow.)  Here's a new function to print four
lines:

@example
Stack:
: print-4 for i from 0 upto 3 do@{ "Line!\n" , @} ;
Stack:
print-4
Line!
Line!
Line!
Line!
Stack:
@end example

How does this work?  @sc{muf} runs the code between the
@code{do@{} and the @code{@}} four times, with the variable
@code{i} set successively to the values 0,1,2,3.
@sc{muf} starts it at the first number given and keeps
incrementing it by one until it is equal to the second
number given.)

Unlike Forth, @sc{muf} doesn't restrict loops to living only
inside of words: It can be fun to execute them directly from
the commandline:

@example
Stack:
for i from 0 upto 3 do@{ "Line!\n" , @}
Line!
Line!
Line!
Line!
Stack:
for j from 2 upto 4 do@{ "Line!\n" , @}
Line!
Line!
Line!
Stack:
@end example

You're wondering about those @code{i} and @code{j} variables, right?
A @dfn{variable} is just a name for a quantity or object or
string or whatever.  When you mention a variable by name,
@sc{muf} silently replaces the variable by the corresponding
value.  @sc{muf} has two major types of variables, and we'll
discuss them shortly.  In the meantime, let's try an
experiment:

@example
Stack:
for i from 0 upto 19 do@{ i @}
Stack: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
@end example

What happened here?  As instructed, @sc{muf} executed the
code from @code{do@{} to @code{@}} twenty times, with the
variable @code{i} successively given the values zero to
nineteen.  The repeated code consisted only of the variable
@code{i}: Each time it encountered the variable, @sc{muf}
replaced it by its value and then, since we didn't tell it
anything else to do with the value, @sc{muf} does what it
always does in such a situation: It made a neat little pile
of the values.

Possibly you are not looking forward to doing @code{pop} twenty
times to get rid of all those values?  Use another loop:

@example
Stack: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
for i from 0 to 19 do@{ pop @}
Stack:
@end example

@noindent
Whee!

If we had a way to count how many items there are on the
stack, we could write a general function to clear the
stack.  It just happens that @sc{muf} has such a
function, called @code{depth}:

@example
Stack:
"alpha" "beta" "gamma"
Stack: "alpha" "beta" "gamma"
depth
Stack: "alpha" "beta" "gamma" 3
@end example

Here is a @code{pop-all} function that will pop all the items on the
stack.  In this example we use the keyword @code{below} instead
of the keyword @code{upto}: The difference is that @code{below}
stops just before reaching the upper limit, while @code{upto}
stops only after reaching the upper limit.
(The "depth -> limit" notation for assigning a value
@code{depth} to a local variable @code{limit} will be explained in the
next section, @emph{Fun With Variables}.)

@example
Stack:
: pop-all   depth -> limit   for i from 1 upto limit do@{ pop @} ;
Stack:
for xx from 40 below 56 do@{ xx @}
Stack: 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55
pop-all
Stack:
@end example

Let's close this section by showing a function which will
print any number of lines, and number them as well, nicely
generalizing the @code{print-4-lines} function which we
began with.  This uses the @code{]print} function, which
we've not covered yet, but the general idea should be clear:

@example
Stack:
: print-n-lines -> k for i from 0 below k do@{ [ "Line %d!\n" i | ]print , @} ;
Stack:
4 print-n-lines
Line 0!
Line 1!
Line 2!
Line 3!
Stack:
2 print-n-lines
Line 0!
Line 1!
@end example

How does this work?  @code{print-n-lines} finds a number on
the stack -- @code{4} or @code{2} in the above two examples.
It slips a zero underneath the number via "0 swap" to make a
valid iteration range for @code{for}.  It then constructs
the actual string to print via the "[ @dots{} ]print" magic
(notice the reference to @code{i} slipped in there), and
prints the string with the comma.  Simple?

You can play with ]print a bit if you want:

@example
Stack:
[ "->%d<-" 12 | ]print
Stack: "->12<-"
pop
Stack:
[ "->%d<-->%g<-" 12 3.5 | ]print
Stack: "->12<-->3.5<-"
@end example

The @code{]print} function is a neat way of building all
sorts of strings, but we need to explain @code{blocks} before
we can explain it properly!

Does anyone remember when the phone company
supplied the time for free?

@example
Stack:
for sec from 10 upto 50 by 10 do@{
    "At the tone the time will be " ,
    time , " and " , sec , " seconds...\n" ,
    10 sleepJob
    "BEEP!\n" ,
@}
At the tone the time will be  4:57AM and 10 seconds...
BEEP!
At the tone the time will be  4:57AM and 20 seconds...
BEEP!
At the tone the time will be  4:57AM and 30 seconds...
BEEP!
At the tone the time will be  4:57AM and 40 seconds...
BEEP!
At the tone the time will be  4:57AM and 50 seconds...
BEEP!
Stack:
@end example

@quotation
(Yes, I was a bad boy again and used some functions which we
haven't officially been introduced to yet.  Forget you saw
any of that, ok?  @emph{grin})
@end quotation

@c {{{endfold}}}
@c {{{ Fun With Variables

@node Fun With Variables, Fun With if, Fun With Loops, Elementary Muf Programming
@section Fun With Variables
@cindex Muf variables
@cindex Variables in Muf
@cindex Muf global variables
@cindex Global variables in Muf
@cindex Muf local variables
@cindex Local variables in Muf
@cindex @code{-->} operator (global variable assignment)
@cindex @code{->} operator (local variable assignment)
@cindex Muf @code{->} operator (local variable assignment)
@cindex Muf @code{-->} operator (global variable assignment)

Obviously, the stack is only suited for temporary storage.
Furthermore, we have already seen that using the stack too
much in our code can make it cryptic.  It would be very nice
if we had other places to keep things... pigeonholes with
little nametages, perhaps?

Our simple-minded little helper @sc{muf} is very good at
"put that there" and "get item X" sorts of tasks, so this
does not seem too much to expect.  In fact, @sc{muf}
provides two types of variables: 'global' variables and
'local' variables.  (Well, there's more to the story, as we
shall find when we get to 'packages', but that's enough to
explain just now.)

Global variables are so called because they are visible
everywhere (in the current package, at least) and in
particular are visible in every function (again, in the
current package, at least).

Local variables, by contrast, exist only while the
particular function they are confined within is actually
running -- a tiny fraction of a second, usually -- and are
visible only to that particular function.  Such fleeting
existence might seem almost pointless at first blush, but
in fact it turns out to be quite handy for functions to
have private storage which they can scribble all over
without upsetting anyone else.

Let's start with global variables.  Notice that the next few
examples have arrows with @emph{two} hyphens in their name!

@example
Stack:
"TestString" --> x
Stack:
x
Stack: "TestString"
x x x
Stack: "TestString" "TestString" "TestString" "TestString"
@end example

The @code{-->} operator takes one value off the stack, and
sticks it in the variable you specify.  If the variable
doesn't exist, it is created.  Thereafter, mentioning the
variable's name is equivalent to typing in the corresponding
value.

You may change the value of a variable at any time using
the @code{-->} function:

@example
Stack:
1 --> x
Stack:
x
Stack: 1
2 --> x
Stack: 1
x
Stack: 1 2
@end example

(Later, we'll see that @sc{muf} has many things other than
strings and numbers for us to store in variables: vectors,
lists, objects @dots{})

Local variables work much like global variables, but
they have one less hyphen in their name, and usually
make sense only inside the definition of a word,
since they live only as long as their word is running:

@example
Stack:
: double   -> string   string string join ;
Stack:
"trouble" double
Stack: "troubletrouble"
string

**** Sorry: Unrecognized identifier: 'string'

@end example

The function @code{double} takes a string and returns one
twice as long, by joining two copies of it.  It works by
first popping the given string off the stack and into a local
variable named @code{string}, then by mentioning the variable
@code{string} twice and feeding the resulting two pointers to
@code{join}.

Hint: It is a good idea to begin all your functions by
copying all the stack values you intend to use into local
variables: This lets you give them meaningful names, and
usually makes the rest of the function much easier for
humans to read.

Hint: Whenever you have a choice, it is better to use a
local variable than a global variable.  You don't know what
other functions might be depending on the value of the
global variable, but you certainly know no other functions
depend on the value of a local variable.  (Local variables
are also a bit faster.)  This is why we give local variables
a slightly shorter assignment symbol (@code{->}) than global
variables (@code{-->}): humans are lazy and tend to use the
shortest-named function by preference.

@c {{{endfold}}}
@c {{{ Fun With 'if'

@node Fun With if, Fun With Arithmetic, Fun With Variables, Elementary Muf Programming
@section Fun With @code{if}
@cindex Muf 'if' operator
@cindex If operator in Muf
@cindex Muf 'random' function
@cindex Random function in Muf
@cindex Comparison functions in Muf
@cindex Muf comparison functions
@cindex != function in Muf
@cindex Muf != function
@cindex < function in Muf
@cindex Muf < function
@cindex <= function in Muf
@cindex Muf <= function
@cindex = function in Muf
@cindex Muf = function
@cindex > function in Muf
@cindex Muf > function
@cindex >= function in Muf
@cindex Muf >= function
@cindex Muf less-than comparisons
@cindex Less-than comparisons in Muf
@cindex Muf equality comparisons
@cindex Equality comparisons in Muf
@cindex Muf greater-than comparisons
@cindex Greater-than comparisons in Muf

Most programming languages offer two basic ways of altering
the normal left-to-right, top-to-bottom code execution
sequence: a way of looping repeatedly over a section of
code, and a way of executing a section of code only if some
condition is true.

We've seen a way to execute code repeatedly, using
@code{for}; Let's look at a way to execute code
conditionally, using @code{if}:

@example
Stack:
: flip   frandom 0.5 >  if "heads!\n" else "tails!\n" fi  ,  ;
Stack: 
flip
tails!
Stack: 
flip
tails!
Stack: 
flip
heads!
Stack: 
flip
tails!
Stack: 
flip
heads!
Stack:
@end example

How does this work?  Well, it introduces several new
functions.  One is @code{frandom}, a function which returns a
randomly selected number between 0.0 and 1.0:

@example
Stack:
frandom frandom frandom frandom
Stack: 0.00176691 0.187589 0.990434 0.750497
pop pop pop pop frandom frandom frandom frandom
Stack: 0.366273 0.351209 0.573344 0.132554
pop pop pop pop frandom frandom frandom frandom
Stack: 0.0641664 0.950853 0.15356 0.584649
@end example

Another is @code{>}, a function which returns a @code{true} value
if its first argument is greater than the second, else
a @code{false} value.  What is a @code{false} value in @sc{muf}?
The special constant @code{nil}.  What is a @code{true} value in
@sc{muf}?  Any but @code{nil}!

@example
Stack:
1 2 >
Stack: nil
pop  2 1 >
Stack: t
@end example

You can compare strings as well as numbers with @code{>}:

@example
Stack:
"alpha" "beta" >
Stack: nil
pop  "beta" "alpha" >
Stack: t
@end example

And, as you might expect, @sc{muf} has the full usual
set of comparison functions:

@example
!=        Not-equal
<         Less-than
<=        Less-than-or-equal-to
=         Equal-to
>         Greater-than
>=        Greater-than-or-equal-to
@end example

Notice that it looks a little odd to write "1 2 >" instead
of "1 > 2" the way Ms Grundy did in third grade, but that
this order is required by our strict rule of evaluating
words left-to-right: @code{>} cannot execute until we have
pushed both of its operands on the stack for it.

(We could make special exceptions from left-to-right
evaluation order just for comparison functions, but then
@sc{muf} would start getting more complicated than we want,
and become a quite different sort of language.  There is
nothing wrong with building more complicated languages
designed to look more like what Ms Grundy taught in school,
and Muq will eventually have such languages as well as
@sc{muf}, but for now let's stick to our simple-minded
little language.)

With that background in mind, let's take another look
at our @code{flip} function:

@example
: flip   random 0.5 >  if "heads!\n" else "tails!\n" fi  ,  ;
@end example

The "random 0.5 >" will leave a @code{true} value on the
stack half the time, and a @code{false} value (@code{nil})
on the stack the other half of the time.  What does the
@code{if} do?

In @sc{muf}, @code{if} pops one value off the stack and
looks at it.  If that value is @code{true} (anything but
@code{nil}), all the words from @code{if} to @code{else} are
executed.  If that value is @code{false} (@code{nil}), all
the words from @code{else} to @code{fi} are executed.
(@code{fi}, as you might guess, is just @code{if} backwards,
and serves to mark the end of the statement.)

In function @code{flip}, this means that the
@code{if-else-fi} pops a true/false value off the stack, and
then pushes either "heads!\n" or "tails!\n" on the stack, to
get printed by the final comma function.

Again, it looks peculiar to put the true/false value
controlling the @code{if} @emph{before} the @code{if}, but
that order is forced by our simple-minded left-to-right
evaluation rule: @code{if} cannot make its decision until we
give it the information it needs.

You may wish to experiment interactively with @code{if} for
awhile, until it begins to feel natural:

@example
Stack:
nil     if "Yup!" else "Nope!" fi
Stack: "Nope!"
pop   t if "Yup!" else "Nope!" fi
Stack: "Yup!"
pop 2.3 if "Yup!" else "Nope!" fi
Stack: "Yup!"
@end example

Believe it or not, you've now mastered most of the
essentials of elementary @sc{muf} programming!  In
principle, you now know enough @sc{muf} to compute anything
which can be computed.

Let's finish off by covering a few very handy and
frequently used facilities.

@c {{{endfold}}}
@c {{{ Fun With Arithmetic

@node Fun With Arithmetic, Fun With Blocks, Fun With if, Elementary Muf Programming
@section Fun With Arithmetic
@cindex Addition in Muf
@cindex Multiplication in Muf
@cindex Subtraction in Muf
@cindex Division in Muf (arithmetic)
@cindex Muf multiplication (arithmetic)
@cindex Muf addition (arithmetic)
@cindex Muf division (arithmetic)
@cindex Muf subtraction (arithmetic)
@cindex + function (arithmetic)
@c putting @c comment on same line as @findex crashes 'makeinfo' horribly.
@c using "@minus{}" instead of '-' on next line crashes TeX horribly.
@cindex - function (arithmetic)
@cindex * function (arithmetic)
@cindex div function (arithmetic)
@cindex Overflow in muf (arithmetic)
@cindex Muf arithmetic overflow

You've likely already guessed that arithmetic functions in
@sc{muf} have to follow their operands, just as comparison
functions do, resulting in yet another jarring clash with
The World According To Ms Grundy:

@example
Stack:
2 2 +
Stack: 4
pop   2 3.4 *
Stack: 6.8
pop   5 3 -
Stack: 2
pop   6.5 2.3 div
Stack: 2.82609
@end example

There's really not a lot else to say about arithmetic!  As
with many computer languages, numbers can only get so big,
after which you get nonsensical results:

@example
Stack:
2.0
Stack: 2
: square  -> x  x x * ;
Stack: 2
square
Stack: 4
square
Stack: 16
square
Stack: 256
square
Stack: 65536
square
Stack: 4.29497e+09
square
Stack: 1.84467e+19
square
Stack: Infinity
@end example

Obviously, we didn't really reach infinity, we just reached
a number larger than @sc{muf} knows how to represent.

Be aware that dividing integers (numbers without decimal
points) gives the largest integer less than or equal to the
real result, while dividing floating point numbers (numbers
with decimal points) gives a floating point result:

@example
Stack:
9.0 4.0 div
Stack: 2.25
pop   9 4 div
Stack: 2
@end example

Both types of division are useful, but the results can be
puzzling if you get the wrong sort of division for what you
intended!

Ms Grundy always told you that you can't divide by zero.
What do you think @sc{muf} will do if you try?  (Hint: If
you haven't figured this out by now, the fastest way to
decide many questions like this is just to try it.  You
can't break anything.  Honest!)

@c {{{endfold}}}
@c {{{ Fun With Blocks

@node Fun With Blocks, Fun With ]print, Fun With Arithmetic, Elementary Muf Programming
@section Fun With Blocks
@cindex Blocks in Muf
@cindex Muf stack blocks
@cindex Muf blocks (stack)
@cindex Muf 'seq[' function
@cindex Muf '|mix' function
@cindex Muf '|sort' function
@cindex Muf '|rotate' function
@cindex Muf ']pop' function
@cindex |mix function in Muf
@cindex |sort function in Muf
@cindex ]pop function in Muf
@cindex ]seq function in Muf
@cindex |rotate function in Muf
@cindex | operator in Muf (stack blocks)
@cindex [ operator in Muf (stack blocks)
@cindex Muf '[' operator (stack blocks)
@cindex Muf '|' operator (stack blocks)

This topic almost really belongs in Intermediate Muf
Programming, but blocks are such fun that I can't resist
introducing them here.  Also, we need them for @code{]print},
which is essential to civilized life under @sc{muf}.

There are many times when we want to operate on a whole
group of values, or wish to write a function which does so.
@sc{muf} has a dazzling (some might say bewildering!)
assortment of functions to assist with this.  We'll show
just a few of of the essential ones here.  Well... some
of the fun ones too!

The @code{seq[} function creates a block of values, and the
@code{]pop} function discards a block of values.  Notice
the square brackets in their names:  functions which
create a block always end with a @code{[}, and functions
which destroy a block always start with a @code{]}.  If
you keep your brackets balanced, your code will
likely make sense:

@example
Stack:
12 seq[
Stack: [ 0 1 2 3 4 5 6 7 8 9 10 11 |
]pop 
Stack:
18 seq[
Stack: [ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 |
@end example

A block consists of some number of values sandwiched between
@code{[} and @code{|}.
The first block above consists of the twelve
values 0-11 The second
block above consists of the eighteen values 0-17.

You can use @code{|mix} to shuffle a block randomly, and
@code{|sort} to sort them.  (Functions which modify a
block always begin with a @code{|}.  If you've played with
unix, you'll spot the similarity to pipe notation.)

@example
Stack:
12 seq[
Stack: [ 0 1 2 3 4 5 6 7 8 9 10 11 |
|mix
Stack: [ 9 1 8 10 5 6 7 4 0 2 11 3 |
|mix
Stack: [ 2 5 10 1 6 4 8 0 3 11 9 7 |
|sort
Stack: [ 0 1 2 3 4 5 6 7 8 9 10 11 |
@end example

There are lots of ways other than @code{seq[} to create
a block.  One of the most mundane, but most useful is
simply to list them, between @code{[} and @code{|}:
@example
Stack:
[ "a" "b" "c" "d" |
Stack: [ "a" "b" "c" "d" |
|mix
Stack: [ "b" "c" "d" "a" |
|sort
Stack: [ "a" "b" "c" "d" |
1 |rotate
Stack: [ "b" "c" "d" "a" |
@end example

Another way is to explode a string into a block of words:

@example
Stack:
"The goddess is alive, and magic afoot"
Stack: "The goddess is alive, and magic afoot"
words[ 
Stack: [ "The" "goddess" "is" "alive" "and" "magic" "afoot" |
|mix
Stack: [ "goddess" "magic" "alive" "and" "afoot" "is" "The" |
]words
Stack: "goddess magic alive and afoot is The"
stringUpcase stringMixedcase
Stack: "Goddess magic alive and afoot is the"
@end example

@c {{{endfold}}}
@c {{{ Fun With ]print

@node Fun With ]print, Fun With Indices, Fun With Blocks, Elementary Muf Programming
@section Fun With ]print
@cindex Muf ']print' function
@cindex ]print function in Muf
@cindex printf() function, ancestor of Muf ']print'
@cindex String construction via ']print'
@cindex Formatting string via ']print'
@cindex Muf string formatting via ']print'
@cindex Muf formatting of string via ']print'

The @code{]print} function is the indispensable all-in-one
Swiss Army Knife of string-construction functions.  (If you've
ever played with C, you'll recognize is as just C's
@code{printf()} function in @sc{muf} clothing.)

@example
Stack:
[ "Test!" | ]print
Stack: "Test!"
pop   [ "I am %d. You are %d." 2 6 | ]print
Stack: "I am 2. You are 6."
pop   [ "Call me %s." "Ishmael" | ]print
Stack: "Call me Ishmael."
@end example

@code{]print} takes a block consisting of a format string
followed by any needed operands, and returns a new string
consisting of the format string with data values substituted
into it at appropriate spots.

How does @code{]print} know where to do the substitutions?
Simple!  It scans the format string looking for @code{%}
characters.  The @code{%} character tells it where to substitute,
and the following letter tells it what sort of substitution
is intended:

@example
%s  a string ("String")
%d  an integer ("Decimal number" -- but no decimal point!)
%f  a Floating point point number.  Print like "123.456"
%%  put a single '%' here in the result string.
@end example

(@code{]print} knows how to do other sorts of substitutions,
and can be told exotic things such as how many digits to
print after the decimal point, but we'll save those for the
intermediate @sc{muf} programming chapter.  The above three
types of substitution suffice for 90% of normal coding.)

The values to be substituted follow the format string, in
the same order as their substitution points.

That's really all the essentials on @code{]print}!  You
may want to play with it awhile to get used to using it.

@c {{{endfold}}}
@c {{{ Fun With Indices

@c androgenous names:  kim pat robin terry bo

@node Fun With Indices, Fun With Packages, Fun With ]print, Elementary Muf Programming
@section Fun With Indices
@cindex Muf objects
@cindex Indices in Muf
@cindex Index properties in Muf (getting and setting)
@cindex Properties, Muf objects (getting and setting)
@cindex Muf a.b syntax
@cindex Muf a[b] syntax

Indices will be covered in much more depth and variety in
the intermediate @sc{muf} programming chapter, but I think
we should at least glance at them here.

A Muq object is conceptually just a little table of named
values.  You can store any values you like in an object, as
many values as you like, and name them anything you like.
That's really about all there is to say about a generic
object!  Except we should show you how to actually do it:

@example
Stack:
makeIndex --> o
Stack:
o
Stack: <index _>
@end example

@code{makeIndex} returns a brand-new index.  In the above
example, we stick it in a global variable called @code{o} and
then push it on the stack to see how @sc{muf} will display it.

Let's stick some named values on an index and then try
reading them back.  @sc{muf} uses a path notation for doing
this which is much like the path notation used by unix: to
refer to the property o @code{o} which is named @code{chris}, we type
"o.chris":

@example
Stack:
makeIndex --> o
Stack:
"555-1423" --> o.kim
"555-6261" --> o.pat
Stack: 
o.kim
Stack: "555-1423"
pop  o.pat
Stack: "555-6261"
@end example

The above example suggests how we might use an index as a
phone book, holding a set of names with corresponding phone
numbers.  Entering new phone numbers doesn't look too hard,
nor looking them up.

What if we wanted to list all of the names and phone numbers
on our list, however?  We certainly don't want to have to
remember all the names!

@sc{muf} provides a special type of loop just for iterating
over the properties on an index:
@example
Stack:
o foreach name number do@{ name , " " , number , "\n" , @}
kim 555-1423
pat 555-6261
Stack:
@end example

This loop takes an index as operand (@code{o} in this case) and
executes the code between @code{do@{} and @code{@}} once for
each name.value pair on the index, with local variables
@code{name} and @code{number} set appropriately before each pass
through the code.

The variables' names are arbitrary, as usual:

@example
Stack:
o foreach key val do@{ key , " " , val , "\n" , @}
kim 555-1423
pat 555-6261
Stack:
@end example

There is one final trick we need.  Suppose we want to
write a little function to look up a phone number given
a name.  It won't do to write

@example
: phone-num  -> name   o.name ;
@end example

@noindent
because @sc{muf} would take this as a request to look for
someone named literally "name":  We need some way to look
up an arbitrary key we've been given on an index, not
just a specific key we know ahead of time.  The @sc{muf}
syntax for doing that is:

@example
: phone-num  -> name   o[name] ;
@end example

@example
Stack:
"robin" phone-num
Stack: 555-1423
pop "pat" phone-num
Stack: 555-6261
@end example

And that is really the essentials of programming with
indices!

@c {{{endfold}}}
@c {{{ Fun With Packages

@node Fun With Packages, Fun With Messages, Fun With Indices, Elementary Muf Programming
@section Fun With Packages
@cindex Muf packages
@cindex Packages in Muf
@cindex Packages, switching between
@cindex Packages, creating
@cindex Muf 'inPackage' function
@cindex Muf pkg::sym notation.

Packages will also be covered in much more depth and variety
in the intermediate @sc{muf} programming chapter, but they
are such a great organizational help that I can't resist
covering the bare basics of them here.

Everyone has a variety of different interests, and we all
learn to compartmentalize them somewhat just to keep our
sanity: We keep the cooking stuff in the kitchen, the
woodworking stuff in the workshop, the financial records in
the study, and so forth.

Anyone really using a Muq system for long will quickly
discover that sanity demands that the functions and data
created for one project be kept separate from those for
other projects.

Muq provides "packages" for this purpose.  At any given
time, you are working in one particular package, and all
functions and global variables that you create are put in
this package.  To see what package you are in, you can print
out the value of @code{@@$s.package}.  To see the functions in
the current package do @code{lf} (List Functions); to see
the variables and their values, do @code{lv} (List
Variables).

However, since it is very important to keep in mind what
package one is in at any given instant, and since some of us
(me!) are quite absent-minded, @sc{muf} reminds us
constantly which package we are in by printing out the
package name to the left of each stack listing.

You change the package you are "in" using the
@code{inPackage} function.  If you try to
change to a package which doesn't exist, it
is automatically created for you:

@example
Stack:
"kitchen" inPackage
kitchen:
2 --> story
kitchen:
"workshop" inPackage
workshop:
1 --> story
workshop:
story
workshop: 1
pop "kitchen" inPackage
kitchen:
story
kitchen: 2
@end example

Notice that we now have two different variables named
"story", one in the "kitchen" package and one in the
"workshop" package, holding different values without
conflicting.  (We could also create different functions with
the same name in the two packages, without conflicting.)

It can sometimes be useful to refer to a value or
function in one package when you are in another
package:

@example
kitchen:
story
kitchen: 2
pop workshop::story
kitchen: 1
@end example

Just prefix the symbol name you want by the package name,
and separate them by a double colon.

If cleanliness is next to godliness, packages just might be
your road to heaven @emph{grin}.

@c {{{endfold}}}
@c {{{ Elementary Muf Cheatsheet

@node Fun With Messages, Elementary Muf Cheatsheet, Fun With Packages, Elementary Muf Programming
@section Fun With Messages
@cindex Muf messages
@cindex Messages in Muf
@cindex Object-Oriented Programming in Muf

A "message", in the object oriented sense, is a
function call in which Muq determines exactly
which function to called by examining (typically)
at runtime the first argument to the function.
(This is in contrast to traditional function
calls, in which the function to be applied is
directly specified by the programmer.)

Each Muq object has an area devoted to holding
functions implementing messages: The
function for a hypothetical "sit" message
would be stored in @code{obj$m.sit}, a "greet" function
would be stored in @code{obj$m.greet} and so forth.

Let's suppose we are building a virtual world, and
are creating objects which respond in various ways
to a "sit" command.  Here is an example of
attaching a "sit" function to a "dog" object:

@example
Stack:
makeIndex --> dog
Stack:
:: pop "wagwag?\n" , ; --> dog$m.sit
Stack:
@end example

Each muq object also has an @code{obj$s.parents} pointer
indicating object(s) on which to search for functions, when
a suitable one is not found on the object itself.

Message functions are invoked by "generic functions".  To
send a message "sit" to an object "dog", we apply the generic
function "sit" to the object "dog":

@example
Stack:
dog sit
wagwag?
Stack:
@end example

The generic function "sit" checks for a @code{dog$m.sit}
function, and runs it if found.  This is a handy way of
making different objects to different things in response to
the same command, without having to have one complicated
function with all the different cases in it:

@example
Stack:
makeIndex --> teenager
Stack:
:: pop "Fat chance!\n" , ; --> teenager$m.sit
Stack:
makeIndex --> soldier
Stack:
:: pop "Yessir! Right away, sir!\n" , ; --> soldier$m.sit
Stack:
makeIndex --> cat
Stack:
:: pop ; --> cat$m.sit
Stack:
dog sit
wagwag?
Stack:
teenager sit
Fat chance!
Stack:
soldier sit
Yessir! Right away, sir!
Stack:
cat sit
Stack:
@end example

If the generic function does not find a "sit" function on
(say) "dog", it next checks the @code{dog$s.parents}
object(s) for a "sit" function, and calls it if found.  This
lets a single object control the behavior of lots of other
objects, which can be handy when one wants to easily change
the behavior of all of them at once:

@example
Stack:
makeIndex --> blind-mouse-1
Stack:
makeIndex --> blind-mouse-2
Stack:
makeIndex --> blind-mouse-3
Stack:
makeIndex --> mouse-parent
Stack:
mouse-parent --> blind-mouse-1$s.parents
Stack:
mouse-parent --> blind-mouse-2$s.parents
Stack:
mouse-parent --> blind-mouse-3$s.parents
Stack:
:: pop "Runrunrunrun!\n" , ; --> mouse-parent$m.sit
Stack:
blind-mouse-1 sit
Runrunrunrunrun!
Stack:
blind-mouse-2 sit
Runrunrunrunrun!
Stack:
:: pop "Chase farmer's wife!\n" , ; --> mouse-parent$m.sit
blind-mouse-1 sit
Chase farmer's wife!
Stack:
blind-mouse-3 sit
Chase farmer's wife!
Stack:
@end example

The advantage of this sort of arrangement is most evident
when one is dealing with hundreds of objects of dozens of
different kinds, and wishes to have objects of a given kind
mostly behave the same, but occasionally have individual
differences.  We cannot do an example that big in this
tutorial, but let's illustrate the principle by making one
of the mice respond differently without changing the other
two:

@example
Stack:
:: pop "Squeak?\n" , ; --> blind-mouse-2$m.sit
Stack:
blind-mouse-1 sit
Chase farmer's wife!
Stack:
blind-mouse-2 sit
Squeak?
Stack:
blind-mouse-3 sit
Chase farmer's wife!
Stack:
@end example

If the generic function "sit" were to search both
@code{blind-mouse-1} and @code{mouse-parent} for a "sit"
function without success, it would then search the
@code{mouse-parent$s.parents} object, if any, and so forth,
until it found a "sit" function or ran out of new objects to
check.  We won't give an example of this, but it means that
@code{mouse-parent} could inherit functions from
@code{standard-animal}, which might inherit functions from
@code{standard-movable-object}, and so forth.

Hierarchies of this sort are a powerful way of building
varied collections of objects which share behavior.  When
constructing a new kind of object, one can frequently
inherit most of the required behavior from existing objects,
and write code only for what is new and different about this
particular object: Merlin's Magic Sword may inherit most of
its behavior from a @code{canonical-sword} object, which may
in turn inherit most of its behavior from a
@code{metal-tool} object.

One may occasionally want a new object to inherit functions
from more than one other object.  (Be careful!  The other
objects might have contradictory requirements in some cases,
or might someday be changed so that they do.)  This may be
done by storing a vector of objects in the @code{parents}
slot, instead of a single object.  Let's demonstrate this by
building an auto that can drive, and a plane that can fly,
and then creating a auto-plane that inherits both abilities:

@example
Stack:
makeIndex --> auto
Stack:
:: pop "Vroom!\n" , ; --> auto$m.drive
Stack:
makeIndex --> plane
:: pop "Zoom!\n" , ; --> plane$m.fly
Stack:
makeIndex --> auto-plane
Stack:
[ auto plane | ]makeVector --> auto-plane$s.parents
Stack:
auto-plane drive
Vroom!
Stack:
auto-plane fly
Zoom!
Stack:
@end example

You may be wondering just where these generic functions are
coming from, and where they wind up.  They are so simple
(two constants and two instructions) and so similar (only
the name constant changes) that Muq simply creates them as
needed: Any time you store a message function on an object,
if there is not already a corresponding generic function,
Muq simply creates it for you:

@example
Stack:
makeIndex --> mouse
Stack:
run

**** Sorry: Undefined identifier: 'run'

Stack:
:: pop "Scurryscurryscurry!\n" , ; --> mouse$m.run
Stack:
run

**** Sorry: Needed object argument at top-of-stack[0]

Stack:
mouse run
Scurryscurryscurry!
Stack:
#'run
Stack: #<c-fn run>
@end example

The "run" symbol and function are stored in the current
package, just like everything else you create.

@node Elementary Muf Cheatsheet, Elementary Muf Programming Wrapup, Fun With Messages, Elementary Muf Programming
@section Elementary Muf Cheatsheet
@cindex Cheatsheet, Muf
@cindex Muf cheatsheet

Here is a quick-reference card of essential @sc{muf} syntax
and operators:

@example
Strings:             "Hello, world!\n"
Characters:          ' '  'H'  '\n'
Comments:            ( Very good. )
Integers, floats:    1 1.0 2.3e4 0.1e-4
Stack functions:     pop swap rot dup
Printing something:  ,
Arithmetic ops:      + - * div mod logand logior logxor ash gcd lcm frandom
Trancendental fns:   exp expt log log10 sqrt abs ffloor fceiling
Trigonometric fns:   acos asin atan atan2 cos sin tan cosh sinh tanh
String functions:    join stringUpcase stringDowncase stringMixedcase substring ]print
Defining functions:  : fnName (function-body) ;
Loops:               for i from  0 upto  19 do@{ ... @}
                     for i from 19 downto 0 do@{ ... @}
Global variables:    expression --> variable-name
Local variables:     expression  -> variable-name
Comparison tests:    = != < <= > >=
Boolean functions:   not and or
Conditionals:        (test) if (expression) else (expression) fi
Block functions:     [ (stuff) |   seq[ |mix |sort |pop |push ]pop
                     words[ ]words chopString[ ]glueStrings
                     |for key do@{ (stuff) @}   |for key val do@{ (stuff) @}
Indices:             makeIndex   1 --> obj.a   1 --> obj[i]
                     obj foreach key val do@{ (stuff) @}
Packages:            "name" inPackage   pkg:x   pkg::x   lf lv
@end example

@c {{{endfold}}}
@c {{{ Elementary Muf Programming Wrapup

@node Elementary Muf Programming Wrapup, Function Index, Elementary Muf Cheatsheet, Elementary Muf Programming
@section Elementary Muf Programming Wrapup
@cindex Zen, and the art of motorcycle maintainance.
@cindex Motorcycle maintainance, Zen and the art of.
@cindex Pirsig, Robert.
@cindex Programming, purpose of.
@cindex Purpose of programming.

This concludes the Elementary Muf Programming chapter.

You may wish to take a break and perhaps try a few little
programming projects before proceeding to the Intermediate
Muf Programming chapter.  Or you might find that what you've
learned so far is quite sufficient for what you need to do.

Either way, remember that the point of programming is to
improve your life.  If you're not enjoying playing with
@sc{muf}, stop and fix the problem!  (Reading Robert
Pirsig's @emph{Zen And The Art Of Motorcycle Maintainance}
might help?)

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
