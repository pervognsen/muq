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

@c Little hints:
@c Never stop at a "natural stopping place"
@c Don't check for bugs unless you have time to fix them
@c End each hacking session while you're still enjoying it.

@c Something I'm just maybe learning:  Decompose each unit
@c into units of similar complexity level:  A function shouldn't
@c both call fantastically deep functions and do trivial bookkeeping.

@c Should we document tell-me-twice method of phasing in a new
@c version of a facility by running it in parallel to an old one?

@c Keep a line of retreat open:  RCS, CVS, emacs 'undo', tarballs, whatever.
@c Sometimes it is wiser and faster to back up and try again by smaller
@c steps, than to resolve a hopeless mess.

@c More stuff:
@c
@c The hard ones. Most code is stunningly boring, and dragging out
@c these weapons for that is like using a 155mm howitzer on a
@c mosquito.  But sometimes you do hit a tough one, and it
@c it helps to have some heavy artillery in your programming toolkit:
@c
@c Use pseudocode (only) on the tough ones. Write it as comments,
@c indented by normal programming conventions.
@c
@c Explicitly work out the loop invariants. (Example: binary search.)

@node Muf Mastery, Muf Mastery Overview, Top, Top
@chapter Muf Mastery

@menu
* Muf Mastery Overview::
* Beauty::
* Truth::
* Good Factoring::
* Modularity::
* Commenting::
* Divide And Conquer::
* Normal Form::
* Power Tools::
* Sit On Your Hands::
* Keep Learning::
* Enjoy::
* Muf Mastery Wrapup::
@end menu

@c
@node Muf Mastery Overview, Beauty, Muf Mastery, Muf Mastery
@section Muf Mastery Overview

In any discipline, there is a clear but hard-to-define gulf
between the merely proficient, and the true master.
Proficiency can be acquired in a year or two; Mastery is the
work of a lifetime.

There is certainly no way to capture mastery of any
discipline in any single chapter; It comes from within, from
years of practice and contemplation and caring intensely
about the quality of the result.

Yet, it would be remiss to pass over the subject in complete
silence.

So, in lieu of a magical mastery-in-30-minutes recipe, I
here provide some personal thoughts and a grabbag of tricks.

None of them are really specific to Muf.

@c
@node Beauty, Truth, Muf Mastery Overview, Muf Mastery
@section Beauty
@cindex Beauty
@cindex Euclid
@cindex Shakespeare

In any discipline, proficiency begins as a very
goal-oriented skills-aquisition process: This tactic lets me
win a pawn, that color selection gives a visual impression
of distance, and so forth.

With time, the skills become second-nature, the low-level
goals develop into an esthetic of economy, and the simple
search for sufficiency grows into a quest for beauty.

Perhaps the clearest and most consistent distinction to be
found between the proficient and the master lies in the
motivations they cite when asked to explain their work: The
proficient will cite simple utilitarian goals, the master
will almost invariably cite intangibles like beauty and
elegance.  The master is not content to build the box or win
the game: It must be beautifully wrought, beautifully won.

To the master programmer, badly written code is more than
just time-consuming to work with: It is actively and
intensely unpleasant to encounter, as much so as fingernails
on a chalkboard.

Programming is a young discipline, brash and curious: As
yet, we are frequently satisfied with code that merely --
often -- functions.  I have yet to see a truly beautiful
program; I think that today's programming languages militate
against their construction.  Muf, with its syntactic economy
and flexibility, is perhaps one of the languages least
unsuited to the construction of beauty.

Mathematics has Euclid, English has Shakespeare; Programming
awaits the person who will lift it from a craft to an art.

@c
@node Truth, Good Factoring, Beauty, Muf Mastery
@section Truth
@cindex Truth
@cindex Invariants
@cindex Rope, throwing the reader
@cindex Strunk, Will.
@quotation
Truth is not democratic.
@end quotation

Through Truths we apprehend our universe: Some found, some made.

Programming is to a great degree an art of creating new
truths: We decide that one should not be be able to walk
through virtual walls, and make it so.  Our virtual world
works to the extent that we succeed in maintaining our
chosen truths.

(Monosyllables being forbidden to doctors of philosophy, such
truths are called "invariants" in the trade.)

When constructing a complex system, it helps immensely to
have clearly in mind from the outset the major truths which
you wish to maintain, and to so structure your code that it
is clear how these truths are maintained.

A frequently-overlooked development tool is the creation of
code to verify your selected truths: Writing such code early
in the project can save untold debugging time.

Finally: If, like Will Strunk, you believe that the reader
is forever half sunk in the swamp, and that it is the duty
of the writer to throw his man a rope whenever possible, you
can hardly find a better way to do so than by clearly
documenting the Truths your code is intended to maintain.

@c
@node Good Factoring, Modularity, Truth, Muf Mastery
@section Good Factoring
@cindex Factoring, of software.
@cindex Code factoring.

Good code factoring is a concept well-understood in the
Forth world, but perhaps not as widely appreciated
elsewhere.

It is common to find, in code that merely works, function
after function that differ only slightly, fragments of code
that repeat over and over with minor variations.

Such code is easy to write, even for a novice: Simply copy
an existing bit of code that does something similar to what
is wanted, modify a couple of lines -- presto!

Such code is also wearisome to read -- the same code must be
read over and over, flipping back and forth to figure out
just what the differences are, and guessing what might be
the point of those differences -- and even more wearisome to
maintain and improve, as each fundamental transformation on
the code must be repeated in endless little variations
through forests of not-quite-identical code trees.

@quotation
@cartouche
The ideal well-factored program
says each thing exactly once.
@end cartouche
@end quotation

There is no simple recipe for achieving this.  Some
languages make achieving it very difficult.  Muf, with its
economical function-call syntax and support for (for
example) custom control structures, offers much better
factoring support than most contemporary programming
languages.

Will Strunk was not a programmer, but his prime dicti apply
forcefully to programs and prose alike:

@example
Eschew obfustication.
Omit needless words!
Omit needless words!
Omit needless words!
@end example

Learn to habitually watch your code as you write, wondering
"Have I seen code like this before"?  Look for ways to
factor out the common element and write it but once, keeping
separate only the quintessential differences.

@c
@node Modularity, Commenting, Good Factoring, Muf Mastery
@section Modularity
@cindex Modularity

Writing large programs is incomparably more difficult than
writing small programs.  The novice who has learned enough
to write a 1,000 line program is inclined to believe that
writing a 10,000 or 100,000 line program requires only the
same techniques, done ten or a hundred times longer.

The fundamental problems are that

@itemize @bullet
@item
Left to themselves, all parts of a program tend to interact,
and it is keeping track of, controlling, and changing these
interactions which constitutes the bulk of the work in a
large program.  Given free interaction between all parts, a
10,000 line program will be 100 times more work than a 1,000
line program, and a 100,000 line program will be 10,000
times more work than a 1,000 line program.

@item
Humans have a very limited ability to keep lots of different
things in mind at one time, especially when dealing with
difficult problems, especially over long periods of time.
@end itemize


Modularity is the programmer's first line of defense against
both of the above problems: One breaks the program up into
small modules, and works very hard indeed to drastically
limit the interaction of each module with the others to a
very narrow interface.  Ideally, this results in it being
possible to completely understand a given module without
needing to understand the rest of the program, and also
makes it possible to safely, reliably modify one module
without needing to understand or modify any other parts of
the program.

Programs are not naturally modular, nor is there any simple
recipe for imposing modularity on a program: Finding a good
way to modularize a given program is a fundamentally
creative process, and discovering a pleasing way of
untangling a recalcitrant knot of code into cleanly
separated modules is one of the more satisfying moments in
the programming process.

Modularity does not come for free, either: Imposing
modularity on a program can result in slower code, code
redundancy or obscurity.  Real world engineering involves
real-world trade-offs like that: There are no magic wands
that let one achieve all one's design goals for free.  That
is what makes great engineering a creative art, and that is
what makes it so satisfying to find unexpected solution that
achieves almost everything one had hoped.

("Object-oriented programming," to the extent that the
phrase still means anything at all, is a particular bag of
tricks for imposing modularity on a program, centering on
the idea of factoring the program state into classes of
similar objects, and then segrating into one module all code
directly accessing the contents of a particular class.  It
frequently works very well, but certainly isn't the only way
to modularize, nor always the best, nor even always
applicable.  For example, if your program has very little
data, or only one class of data, it is of little if any help.)

@c
@node Commenting, Divide And Conquer, Modularity, Muf Mastery
@section Commenting
@cindex Commenting

The ideal program, in the ideal programming language, would
have no comments at all: Comments exist to convey important
information about a program which cannot be expressed in the
programming language itself, and the ideal programming
language would be powerful enough to express all important
information about the program.  If the information is
important, the compiler has just as much right to be told as
does the human reader.  As compilers evolve into true
software environments, those environments will exhibit a
steadily increasing appetite for all available information
about the programs they are massaging.

We are today amazingly far from that ideal!

It is kind of neat watching the very first iron nails being
painfully hand-forged by first-generation blacksmiths, even
if at times one grows a little impatient for the era of
mass-produced, reliable nails @dots{}

In the present, while we await a brighter future, we are
left hiding much of the content of our programs from our
compilers in the form of comment statements for human
consumption only.

Effective written communication with humans is not an
altogether new art: Study of effective string composition and
layout long precedes Gutenberg, extending in unbroken
tradition back to Homer and beyond.  Modern books,
magazines, and printed matter generally are heir to millenia
of hard-won expertise.

Even in our primitive @sc{ascii} era, much of this expertise
can be applied to making programs easier and more pleasant
to read; As programming emerges from the dark ages, we as
programmers shall have access to steadily more of the
resources that other writers take for granted, from font
selection to illustrations.

I am utterly mystified why so many programmers seem to take
obscure pride in writing program comments in utterly
illiterate style, markedly below even their own habitual
prose standards.  For example, a capital letter at the start
of a sentence, and appropriate punctuation at the end, make
a sentence easier for the reader to pick out.  This has been
known for centuries, and hardly ceases to be true if the
sentence happens to reside in a program instead of an essay.
Why, then, do we see so many program comments lacking even
such basic amenities?

Anyhow.  For those who take pride in their programs, English
style guides are there for the reading.

@c
@node Divide And Conquer, Normal Form, Commenting, Muf Mastery
@section Divide And Conquer
@cindex Divide And Conquer

One central task of a C compiler is to assign variables and
temporaries to registers.

Possibly the prettiest way to solve this problem is to
re-express it as a graph-coloring problem, in which every
node in the graph is to be assigned a color, no two nodes
connected by an edge may have the same color, and we wish to
use the minimum number of colors to color the entire graph.
@footnote{This being a good idea, naturally our society has
specified that anyone using it should be fined.  (IBM has
patents on it.)}.

This problem is known to be NP-Complete in general, which
means that for realistic-sized problems we cannot usually
expect to find the best possible solution, only a good
solution.

One quite pretty way of finding a good solution is to
iteratively remove all the easy-to-color parts of the graph,
color any 'hard' core remaining (often there will be none)
and then color the remaining parts one-by-one as we add them
back.  This will often color with ease graphs that at first
blush look intimidatingly difficult.

One may take this heuristic as a metaphor for
divide-and-conquer problem-solving in general: We are
frequently faced with a problem which is too complex to
solve all at once.  A ubiquituous technique for such
problems is to divide them into subproblems, solve the
subproblems individually, and then merge the subsolutions
into a solution to the entire problem.  (Many, many
algorithms from sorting to integer factoring may be
understood as simply divide-and-conquer applied with
particular ways of doing the subdivision and merging steps.)

As usual with the techniques discussed in this chapter,
there is no simple recipe for dividing an arbitrary problem
or merging the subsolutions: Creativity and insight are
required and rewarded.

But we may draw a very general lesson from the
graph-coloring heuristic:

@quotation
@cartouche
Solve the most important subproblem first.
@end cartouche
@end quotation

Depending on the particular problem, the "most important"
subproblem may be the most highly constrained one, the most
novel one, the most difficult one, or the one most critical
to quality of the resulting solution.

In any event, each subproblem solved usually reduces the
degrees of freedom left for solving the succeeding
subproblems, so it pays to select the order of solution
carefully, making the most of the extra degrees of freedom
available in the first subproblem.

Thus, for example, if the most critical design goal in a
given application is minimizing disk @sc{I/O}, start by
designing the data structures and algorithms involved in
disk @sc{I/O}, then design the other parts of the
application to work well with them without degrading their
performance.  (Muq was designed in somewhat this fashion.)

@c
@node Normal Form, Power Tools, Divide And Conquer, Muf Mastery
@section Normal Form
@cindex Normal Form

The more information you have available, the simpler it is
likely to be to solve the problem.  Make sense?  Extra
information can't hurt, and may help.

You will often find that your first datastructure design
contains unneeded degrees of freedom.  If the problem to be
solved is nontrivial, you may often make life much simpler
by systematically eliminating those extra degrees of freedom
before attempting a solution.  This process is often called
"reduction to a normal form".  The result when done is that
you know more about the datastructure, and so you have fewer
cases to consider when coding, or more information available
which you may take advantage of when coding the main case.

As a simple example, comparing two arrays of numbers to see
if they contain the same set of numbers is fairly expensive.
But if we sort each array first, it becomes fast and
completely trivial to code.  

Along the same lines, comparing two binary trees to see if
they have the same leaves in the same order is a tricky
problem in recursion, but becomes completely trivial if we
first reduce each tree to a linear linklist.

As a more sophisticated example, when a symbolic algebra
package attempts to check two expressions for equivalence,
the task is considerably eased if each expression is first
reduced to a standard form: Systematically applying this
insight has led to significant advances in symbolic algebra
systems.

Much of the front-end processing in a compiler can be
understood as stripping out irrelevant degrees of freedom
and massaging the input code into a normal form; significant
parts of some dataflow analysis, code optimization, and code
generation components of compilers can be similarly
understood.

Taken to the extreme, as in Church's lambda calculus and the
denotational semantics systems based on it, all computation
can be understood as reduction to a normal form.  But that
overinflates the concept to uselessness for most practical
purposes.

Learn to keep a critical eye cocked on your input, and to
habitually look for ways to reduce it to a simpler form
before beginning serious processing on it.

@c
@node Power Tools, Sit On Your Hands, Normal Form, Muf Mastery
@section Power Tools
@cindex Power Tools

We ignore here the issue of thosefolk who feel that the
ideal programmer should write code that runs correctly when
first submitted to a computer.  There may well be
self-consistent ethical systems in which handwork earns more
karma than mechanical processing, but as a practical
engineering matter, it is (for example) incontestably more
efficient to use the compiler's syntax checker to locate
certain classes of errors than to simulate the compiler's
syntax checker by hand.

@quotation
@cartouche
Don't waste time doing by hand what the computer can do
faster and more accurately for you.
@end cartouche
@end quotation

This sounds simple, even trivial, but is far from being so.

Finding better and more general ways to apply the power of
computing machinery to the task of software production is
one of the most important and difficult tasks facing the
computing community, and one on which we have made amazingly
little progress.

Computing hardware has improved a millionfold over the last
decades, and the tools and techniques used by the engineers
building it has changed beyond recognition in that time; In
the last twenty years, changes in mainstream software
construction techniques have been so slight as to virtually
defy detection: We still edit lines of imperative code in
string editors, compile, and crash.

@quotation
@cartouche
Know what tools @emph{are} available, and use them when
appropriate.

Try to reduce your coding to normal forms: Solve the same
problem in the same way when no good reason exists to do
otherwise.
@end cartouche
@end quotation

At the least, the increased uniformity will often aid you in
mechanically implementing mass transformations on your code
via string editor macros or the like.

At best, you may come to understand some facet of what you
are doing so well that you can write a code generator to
automate the process, freeing you to concentrate on more
interesting coding issues.

@c
@node Sit On Your Hands, Keep Learning, Power Tools, Muf Mastery
@section Sit On Your Hands

@quotation
@cartouche
Clear your mind and proofread your code when finished.
@end cartouche
@end quotation

Chess mastery is a discipline which places a premium on
consistency: One moment of hallucination can throw away
hours of good work.

Someone once asked a grandmaster how to avoid such mistakes,
and was told, "Sit on your hands!"

The advice was only partly in jest.  There is a distinct
tendency when analysing extended variations to get immersed
in a particular set of crucial issues, and to lose track of
more "obvious" concerns: Almost anyone who has played chess
at all seriously has repeatedly had the experience of making
a move after deep thought and realizing that it was an
elementary blunder@dots{} immediately @emph{after} releasing
the piece.  (The only remaining strategy at that point is to
keep a poker face and hope the opponent trusts you too much
to notice.  It has been known to work!)

The solution is to deliberately cultivate the habit of
completely clearing one's mind and re-examining the position
and proposed move with fresh eyes right before actually
making the move.

Programming produces a very similar phenomenon: It is very
easy to get lost in a particular set of intricate
considerations while coding up a function, and to lose sight
of more elementary considerations, resulting in elementary
coding blunders.  Coding blunders will not usually cost you
a tournament and a title, but it remains true that it is
much more efficient to avoid them than to track them down
later in testing.

As with the chess master, the master programmer eventually
--- usually through painful experience --- acquires the
habit of stepping back from each involved coding task once
done, clearing the mind, and re-reading thoroughly with
fresh eyes, looking for elementary mistakes.

It is not a natural habit, but once acquired it can make
programming much more pleasant.  You may even eventually
find your code working first try on a regular basis, an
experience akin to nirvana.
@node Keep Learning, Enjoy, Sit On Your Hands, Muf Mastery
@section Keep Learning

@quotation
@cartouche
Try to make each new project distinctly superior in some
significant respect to any previous project you've done.
@end cartouche
@end quotation

You won't always succeed, but you will assuredly always
learn something.

A programming project from which you learn nothing is a
failed project.

@c
@node Enjoy, Muf Mastery Wrapup, Keep Learning, Muf Mastery
@section Enjoy Hacking

@quotation
@cartouche
Make enjoyment a deliberate policy.
@end cartouche
@end quotation

You cannot produce consistently first-rate results if you do
not enjoy what you are doing.  (Nor is life long enough to
be spending undue time on something you do not enjoy.)

Do not passively accept enjoyment as something which appears
or not, outside of your control.  Enjoyment is a matter of
attitude, approach, and technique.  Some people can be happy
working on almost anything, others are habitually miserable.
You can be either.

Watch to see what factors make something enjoyable for you,
and work systematically to institutionalize them.

@c
@node Muf Mastery Wrapup, Biographical Sketches, Enjoy, Muf Mastery
@section Muf Mastery Wrapup

This exhausts the chapter, while admittedly barely
scratching the surface of the topic.

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
