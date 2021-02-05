@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Reference Shelf, Reference Shelf Overview, Biographical Sketches Wrapup, Top
@appendix Reference Shelf

@menu
* Reference Shelf Overview::
* Artificial Intelligence::
* Common Lisp::
* Compilers::
* Computer Graphics::
* Data Compression::
* Forth::
* Fundamental Algorithms::
* Numerical Programming::
* Operating Systems::
* Software Manual for the Elementary Functions::
* Unix System Administration::
* Unix Tutorials::
* Unix Programming::
* User Interface Design::
* X Windows Programming::
* Reference Shelf Wrapup::
@end menu

@c {{{ Reference Shelf Overview

@c
@node Reference Shelf Overview, Artificial Intelligence, Reference Shelf, Reference Shelf
@section Reference Shelf Overview

Computing has become sufficiently trendy that it is no
longer particularly hard to find books devoted to it.
(Nowadays, friends no longer ask me "Why would anyone want
to own a computer?" with an expression suggesting grave
concern for my sanity @emph{grin}.)

Finding @emph{good} books on a given topic can still involve
some work, however.

Following are various books which I find myself using or
recommending frequently, together with some of which I am
simply personally quite fond.

@c {{{endfold}}}
@c {{{ Artificial Intelligence

@c
@node Artificial Intelligence, Common Lisp, Reference Shelf Overview, Reference Shelf
@section Artificial Intelligence

It has been asserted, only partly in jest, that artificial
intelligence is whatever we don't know how to program yet:
Numerous techniques pioneered by artificial intelligence
programmers have been accepted into mainstream programming
practice, but none of them are today considered to have much
to do with intelligence.

Sherlock Holmes used to complain on occasion that his
deductions were respected only until explained; Magicians
and holyfolk have known for centuries that the magic goes
away as soon as the trick is revealed.



The closest thing I am aware of to an attempted encyclopedia
of artificial intelligence programming techniques is the
multivolume @emph{Handbook of Artificial Intelligence} by
Barr and Feigenbaum: HeurisTech Press 1981, ISBN
0-86576-004-7.

At the least, it provides a good overview of the scope and
accomplishments of classical (lisp-based) artificial
intelligence programming.



To my mind, probably the farthest advance yet along in the
direction of classical artificial intelligence programming
is marked by the @sc{soar} project, which is written up in
@emph{Universal Subgoaling and Chunking: The Automatic
Generation and Learning of Goal Hierarchies}, by Laird,
Rosenbloom and Newell: Kluwer Academic Publishers 1986, ISBN
0-89838-213-0.  @sc{soar}'s strengths and weaknesses serve
as a good summary of the strengths and weaknesses of the
classical artificial intelligence approach as a whole, at
least based on experience to date.

A persistent problem of classical artificial intelligence
appears to me to be that it works predominantly with complex
structures which are boolean in the sense that they occupy a
discrete space of possibilities, rather than a continuum,
making it very difficult to apply simple learning algorithms
based on hill-climbing: varying tunable parameters bit by
bit and converging slowly towards the goal.  Neural nets,
by contrast, consist of almost nothing but continuously
tunable parameters, making learning much simpler:  This
may explain what I percieve to be a certain tiredness with
the classical artificial intelligence paradigm, and a
resurgence of interest in neural nets.

The flip side of that is that it is much less clear how one
expresses complex and abstract ideas in neural net form: I
expect we'll see a return to more classical approaches in
due course, probably armed with new insights gained from the
neural net paradigm.  Playing two paradigms off against
each other rarely fails to enrich both.



The accepted classic introduction to classical
artificial intelligence programming techniques is:

Paradigms of Artificial Intelligence Programming:
Case Studies in Common Lisp, by Peter Norvig.
Morgan Kaufman 1992, ISBN 1-55860-191-0

A thousand pages of practical introduction to Lisp
programming techniques and algorithms.  These days, they
look more like just sensible, useful programming than
anything to do with intelligence, but that's the way it
goes@dots{}

I borrowed this book some time ago, and it has been sitting
by my elbow ever since, getting alternately skimmed, read
and consulted.  Best of breed.

Code in the book is available via ftp from
unix.sri.com:/pub/norvig.


One more book simply @emph{must} be mentioned:

Vision: A Computational Investigation into the Human
Representation and Processing of Visual Information, by
David Marr: W H Freeman and Company 1982, ISBN
0-7167-1284-9.

Artificial intelligence has never suffered from an excess of
promising ideas and people, so it is especially tragic that
David died at the age of thirty-five, just as he began to
hit his stride: This book was published posthumously.  (The
preface comments that "In December 1977, certain events
occurred that forced me to write this book a few years
earlier than I had planned..."; The preface is dated "Summer
1979"; He died in 1980.)  This is an original and enjoyable
book on the very difficult problem of artificial vision,
which has had a lasting effect on the field.

(Recent progress has hinged on the re-integration of visual
processing steps which David isolates: The process of
analysis followed by resynthesis is old and fruitful.)

@c {{{endfold}}}
@c {{{ Common Lisp

@c
@node Common Lisp, Compilers, Artificial Intelligence, Reference Shelf
@section Common Lisp

The standard reference is:

Common Lisp, The Language, Second Edition, by Guy L Steele,
Jr.  Digital Press 1990, ISBN 1-55558-041-6.

This book is choppy because it was re-edited to reflect
on-going standardization, and a bit dated because the
@sc{ansi} Common Lisp standard has since been adopted, but
as far as I know it is still the standard reference in
practice.

Guy L Steele Jr. is himself an interesting and influential
member of the computing community, who did his thesis on
constraint-oriented programming languages, has made major
contributions to standardization efforts for Common Lisp,
Scheme (a smaller, faster lisp), Fortran (still the
unchallenged ruler of numeric computing) and C, as well
as having been chief scientist of Thinking Machines
corporation and hence a major contributor to the
development of massively parallel computers.

His varied interests include Loglan/Lojban, an artificial
human language based on symbolic logic.  His is always a
thoughtful and interesting voice of reason.

@c {{{endfold}}}
@c {{{ Compilers

@c
@node Compilers, Computer Graphics, Common Lisp, Reference Shelf
@section Compilers

For years the standard text for compiler classes was
@emph{Principles of Compiler Design} by Aho and Ullman,
universally known as "the Dragon book" because of it's
colorful cover cartoon of St Hacker slaying the jolly green
giant dragon of Compiler Complexity.  (I presently have
@emph{two} copies of this on my shelf.)

@quotation
There is a wonderful underground cartoon showing some
armor picked clean, with the caption "Sometimes the
dragon wins" which really belongs somewhere in the book.
I gave up my own compiler project after three years...
@end quotation

In 1986, the Dragon book burst its cocoon and emerged twice
as big, as @emph{Compilers: Principles, Techniques and
Tools}, by Aho, Sethi and Ullman: Addison-Wesley ISBN
0-201-10088-6.  I have a whole shelf of other compiler
tomes, but none I like nearly as well.  So far as I know,
it remains the standard text in the field.



I can't resist mentioning one favorite related book:

Realistic Compiler Generation, by Peter Lee.  @sc{mit} Press
1989, ISBN 0-262-12141-7, part of the Foundations of
Computing Series.

The compiling field is clearly mired in the dark ages at
present: This book provides a glimpse of the future,
generating a compiler from high-level descriptions of both
the syntax and the semantics of the language, not to mention
of the target machine.

@c {{{endfold}}}
@c {{{ Computer Graphics

@c
@node Computer Graphics, Data Compression, Compilers, Reference Shelf
@section Computer Graphics

(By "computer graphics", I mean the Real Stuff: Color and
three-dimensional.)



There are a bazillion mediocre books on this that all look
about the same.  The standard text on the field is still:

Fundamentals of Interactive Computer Graphics, Second
Edition, by Foley, Van Dam, Feiner and Hughes.
Addison-Wesley 1987,  ISBN 201-12110-7.

(When I took the course, the text was Newman and Sproull;
My copy of the above is actually the first edition.  There
may be a third edition of it out by now.)



Photo-realistic computer graphics is a separate subfield
these days: The datastructures and techniques are almost
completely different from those used in interactive computer
graphics.

This doesn't mean that photo-realistic computer graphics is
harder than interactive computer graphics:  A basic
ray-tracer that produces spectacular looking images is
actually amazingly easy to write.  It is more work to
support a wide range of geometry types, and @code{much} more
work to try and produce images as quickly as practical.

I recommend:

An Introduction To Ray Tracing, edited by Andrew S Glassner.
Academic Press 1989, ISBN 0-12-286160-4.

Andy just happens to be one of the folks who coordinate the
annual American computer graphics shindig (SIGGRAPH): He
knows and loves the topic, and has put together a good
practical introduction to the subject.



I have a long shelf full of more specialized books on
splines, image processing and such, but there doesn't seem
much point in reviewing them here: By the time you need
them, you'll know what you want and where to find it.
But this demands mention:

Graphics Gems, edited by Andrew S Glassner.
Academic Press 1990, ISBN 0-12-286165-5

This book was intended to make available lots of little
tricks of the trade in one handy volume.  The first
intention worked pretty well, the latter ambition has been a
miserable flop: The series is now up to four volumes and
going strong:

Graphics Gems II, edited by James Arvo.
Academic Press 1991, ISBN 0-12-064480-0.

Graphics Gems III, edited by David Kirk.
Academic Press 1992, ISBN 0-12-409670-0.

Graphics Gems IV, edited by Paul Heckbert.
Academic Press 1994, ISBN 0-12-336155-9.

The bad news is that, as a collection of contributions from
dozens of authors, the quality is rather uneven, ranging
from great to perhaps somewhat dubious.

The good news is that all the code has been placed in the
public domain and made available via the internet, complete
with improvements and bugfixes: Ftp (or whatever) to
princeton.edu and look in pub/Graphics/GraphicsGems.

(Incidentally, I learned the above by consulting the
comp.graphics Frequently Asked Questions posting on
rtfm.mit.edu, a resource you should not neglect.)



Here's one more reference just to avoid being thought
non-trendy @emph{grin}:

The Science of Fractal Images, edited by Peitgen and Saupe:
Springer-Verlag 1988, ISBN 3-540-96608-0.

A nice practical manual to making those cool fractal images,
complete with Pascal code snippets for the central
algorithms.  Fractals are still treated as a niche sort of
thing in computer graphics, but I expect to see them
becoming steadily more mainstream over time.

@c {{{endfold}}}
@c {{{ Data Compression

@c
@node Data Compression, Forth, Computer Graphics, Reference Shelf
@section Data Compression

This looks like the definitive book on the subject for now:

Data Compression: Methods and Theory, by James A Storer.
Computer Science Press 1988, ISBN 0-99175-161-8.

@c {{{endfold}}}
@c {{{ Forth

@c
@node Forth, Fundamental Algorithms, Data Compression, Reference Shelf
@section Forth

In the end, I didn't wind up finding much in Forth that
seemed to apply to Muq: The general programming model is
realy too low-level, and the latest innovations that
interested me had been adapted from Lisp, in which cases it
seemed to make more sense to go directly to the source.

However, just for the record, the current best reference
on Forth appears to be:

Forth: The Now Model;  A Programmer's Handbook, by Jack Woehr.
M&T Publishing 1992, ISBN 1-55851-277-2

As the cover blurb proudly notes: "Covers the proposed
American National Standard for Forth".  The standard
includes many optional extentions, however, most of which
are not covered.

Forth's great strength is it's ability to provide a nice
programming environments on tiny hardware configurations; In
an era of gigabyte SIMMs (yes, they're available now), this
attracts mostly a niche market of hardware hackers building
sonobuoys and such, with a Z-80 (or whatever) chip tucked
in.  On larger systems, Lisp really offers everything Forth
does, and a lot more.

@c {{{endfold}}}
@c {{{ Fundamental Algorithms

@c
@node Fundamental Algorithms, Numerical Programming, Forth, Reference Shelf
@section Fundamental Algorithms

Reading Knuth's @emph{Art Of Computer Programming} series is
still not a bad substitute for an undergraduate computer
science degree.  The most essential volume remains the
first:

Fundamental Algorithms, by Donald Knuth, Addison-Wesley
1973.

(Real Hackers(@sc{tm}) can be recognized by the well-thumbed
copies of all three volumes of this series above their
desk.)

The above is without question getting somewhat dated,
although I can't help feeling that it gains in historical
value at least as much as it loses in currency@dots{}

A more contemporary treatment may be found in:

Algorithms, by Robert Sedgewick, Addison-Wesley 1983,
ISBN 0-201-06672-6.  

Naturally, it was typeset using @TeX{}!

@c {{{endfold}}}
@c {{{ Numerical Programming

@c
@node Numerical Programming, Operating Systems, Fundamental Algorithms, Reference Shelf
@section Fundamental Algorithms

Serious computation using floating-point numbers is a
completely separate field from garden variety C-style
programming.  It has its own language (ForTran, still far
ahead of the competition, and probably pulling away),
culture and skills.  Few people are proficient at both.

If you find yourself having to produce nontrivial numerical
results in C, the definitive cookbook to reach for is:

Numerical Recipes in C: The Art of Scientific Computing, by
Press, Flannery, Teukolsky and Vettering.  Cambridge
University Press 1988, ISBN 0-521-35465-X

(Versions for Fortran and Pascal are also available, along
with complete software on floppy.)

@quotation
An illustration of the cultural gap: In their programming
style section, they suggest avoiding the C switch()
statement, as a newfangled syntactic experiment which has
yet to prove its worth@dots{}!
@end quotation

These guys know and love their craft, and are determined to
give practical, useful help to folks hacking in the
trenches, unlike many academic tomes.

This book features full source code for practical solutions
to all the problems they discuss, along with sufficient
explanation to give you a fighting chance of distinguishing
use from abuse of the code.  (The downside is that the code
is copyrighted: You'll have to look elsewhere if you want to
distribute your program.)

Most amazingly, they've managed to make a highly technical,
moderately mathematical book which is actually fun to read!
The first example in the book shows you how to compute the
phase of the moon, and contains the classic marginal
comment, "You aren't really intended to understand
this@dots{}"

@quotation
Mark Twain maintained that every man needs three books: A
leather one to strop his razor, a thin one to shim the
table, and a thick one to throw at the cat.  My household
has two cats, and two copies (ForTran and C) of this
book@dots{}
@end quotation

@c {{{endfold}}}
@c {{{ Operating Systems

@c
@node Operating Systems, Software Manual for the Elementary Functions, Numerical Programming, Reference Shelf
@section Operating Systems

Many people consider this to be the classic of the field:

Operating Systems: Design and Implementation, by
Andrew S Tanenbaum. Prentice-Hall 1987, ISBN 0-13-637406-9

(Tanenbaum was also the guiding light behind Minix, which was
sort of the Linux of the 1980s.)



A shorter book which also comes highly recommended (which I think I
prefer) is:

The Design of the Unix Operating System, by Maurice J Bach.
Prentice-Hall 1986, ISBN 0-13-201799-7 025

(This is another book of which I've wound up with two copies, which is
some sort of testimonial.)

@c {{{endfold}}}
@c {{{ Software Manual for the Elementary Functions

@c
@node Software Manual for the Elementary Functions, Unix System Administration, Operating Systems, Reference Shelf
@section Software Manual for the Elementary Functions

If you ever need to implement functions like @code{sin()},
this is @emph{the} book on the subject.  Cody and Waite,
Prentice-Hall 1980, ISBN 0-13-822064-6.

@c {{{endfold}}}
@c {{{ Unix System Administration

@c
@node Unix System Administration, Unix Tutorials, Software Manual for the Elementary Functions, Reference Shelf
@section Unix System Administration

There seem to be zillions of mediocre to downright bad
books on this subject.  There is also one glittering
jewel:

Unix System Administration Handbook: Unix System
Administration Made Difficult, by Nemeth, Snyder and
Seebass.  Prentice-Hall 1989, ISBN 0-13-933441-6.

These folks have been there, seen it, fixed it, and
survived to tell the tale.  With gusto!  The cartoons
are as priceless as the advice.

If you're on the way to becoming a unix sysadmin, from
choice or necessity, full or parttime, you shouldn't
pass up this book.



No single volume can begin to cover everything a unix
sysadmin might want or need to know, however.  The de facto
standard reference shelf for unix is O'Reilly series.
Examples:



sendmail, by Bryan Costales with Eric Allman & Reil Rickert.
O'Reilly & Associates 1993, ISBN 1-56592-056-2

If you know who Eric Allman is, you won't need to hear more.
If you don't know who Eric Allman is, and are doing anything
involving sendmail, you need this book!



Programming perl, by Larry Wall and Randal L Schwartz.
O'Reilly & Associates 1991, ISBN 0-937175-64-1.

Larry is one of the alltime top unix programmers and
sysadmins, and perl is his personal tool for getting
sysadminish tasks done with a minimum of time and fuss.
perl has all the grace and charm of a Mac truck, and gets
the job done with comparable dispatch.  perl is a net
freebie (jpl-devvax.jpl.nasa.gov) with a self-install script
so incredibly thorough it leaves many people in fits of
giggles.



As you might or might not expect, the nutshell books
can be ordered directly via internet email: nuts@@ora.com

@c {{{endfold}}}
@c {{{ Unix Tutorials

@c
@node Unix Tutorials, Unix Programming, Unix System Administration, Reference Shelf
@section Unix Tutorials

People keep asking me for a good introductory book on
practical unix.  I've never discovered a book on the
subject that really excites me, but this book seems
pretty good, which is more than one can say for most
such:

Unix Made Easy, McGraw-Hill 1990, ISBN 0-07-881576-2.



Here's a book a like a @emph{lot}:

Life With Unix:  A Guide For Everyone, by Libes and Ressler.
Prentice-Hall 1989, ISBN 0-13-536657-7

Unix has been (and largely continues to be) an oral
tradition more than a written one:  This book is
essentially a distillation of net unix culture,
lovingly reduced to written form.

@emph{Life With Unix} gives you a huge step up on "going
native" as a unixoid, should you desire to do so: A history
of unix, a survey of unix today, a peer into the unix
future, an annotated bibliography of unix resources (from
books to netnews to conferences), an overview of Unix from
the user's, programmer's and system administrator's
perspectives, dresscodes for unixfolk, a survey of unix
applications...

This book isn't best of breed in any of the technical
areas it covers, but it is an outstanding overall
introduction to unixthink and the unixworld, an
enjoyable read, and a rich source of pointers to
further material.  Highly recommended.

@c {{{endfold}}}
@c {{{ Unix Programming

@c
@node Unix Programming, User Interface Design, Unix Tutorials, Reference Shelf
@section Unix Programming

Many books are enjoyable, not a few are educational,
only a handful can be honestly termed indispensable.
If you are doing serious C programming on unix, these
two books are indispensable.  Having them borrowed for
just a day or two is enough to make me restless and
frustrated, as I keep reaching for them and finding
an empty space:

Unix Network Programming, by W. Richard Stevens.
Prentice Hall 1990, ISBN 0-13-949876-1.

(Peering inside the cover, I notice Brian W Kernighan
is listed as "Advisor" for this book series.)

Advanced Programming in the @sc{unix} Environment, W. Richard Stevens.
Addison-Wesley 1992, ISBN 0-201-56317-7.

I've virtually stopped using unix manuals for nontrivial
reference purposes: I just reach for this book and flip to
the index.  My only complaint is that the index lists every
mention of a given topic, without bold-facing the primary
reference, forcing me to try several times before finding
the substantive part.  I pinged Stevens via email about
this, and he agreed, but said the software he used doesn't
allow such boldfacing.  "Maybe in the next book."

These two books have it all: Clear conceptual overviews,
working code examples, crisp tables summarizing which unix
flavors support which calls, advice on the best practical
solutions to common problems, corrections to the standard
unix manuals.

1500 pages of priceless information:  Buy 'em and use 'em.

@c {{{endfold}}}
@c {{{ User Interface Design

@c
@node User Interface Design, X Windows Programming, Unix Programming, Reference Shelf
@section User Interface Design

Designing & Writing Online Documentation:
Helpfiles to Hypertext, by William K Horton.
John Wiley & Sons 1990, ISBN 0-471-50772-5.

Any book which constantly quotes people like Alan Kay and
Ted Nelson (the original Hypertext Prophet, whose Project
Xanadu has been two decades of trying to make WorldWideWeb
happen) can't be all bad!

I like this book: It has lots of good advice, quotes lots of
useful numbers with research references to back them up, and
is obviously written by someone who knows and cares about
the field.  The book is more general than the title
suggests: It contains useful advice about designing just
about everything visible to the user, on everything from
glass TTYs to bitmapped multi-window graphics displays.

This book won't tell you anything about the nuts and bolts
of coding in any particular user interface toolkit, however:
You'll want another reference for that.

@c {{{endfold}}}
@c {{{ X Windows Programming

@c
@node X Windows Programming, Reference Shelf Wrapup, User Interface Design, Reference Shelf
@section X Windows Programming

I've yet to see a book on X Windows that didn't look as if
it were written at gunpoint to make a deadline and a dollar.



The O'Reilly series seems to be the accepted reference:

"The Definitive Guides to the X Window System", Volume One:
Xlib Programming Manual for Version 11 by Adrian Nye.
O'Reilly & Associates 1992, ISBN 1-56592-002-3

And so on for half a dozen volumes.



X Window System Programming, by Nabajyoti Barkakati (SAMS
Macmillan 1991, ISBN 0-672-22750-9) is perhaps a bit better
as a tutorial.

@c {{{endfold}}}
@c {{{ Reference Shelf Wrapup

@c
@node Reference Shelf Wrapup, Net Re-sources, X Windows Programming, Reference Shelf
@section Reference Shelf Wrapup

This concludes my personal-favorites computing bookshelf.
Suggestions for other books which deserve inclusion will
be gravely considered.

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
