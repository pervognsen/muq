@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c ---^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Biographical Sketches, Biographical Sketches Overview, Muf Mastery Wrapup, Top
@appendix Biographical Sketches

@menu
* Biographical Sketches Overview::
* Edsger W. Dijkstra::
* Richard P Feynman::
* Alan Kay::
* Donald Knuth::
* Doug Lenat::
* Marvin Minsky::
* Isaac Newton::
* Johnny von Neumann::
* Alan Turing::
* Leor Zolman::
* Biographical Sketches Wrapup::
@end menu

@c
@node Biographical Sketches Overview, Edsger W. Dijkstra, Biographical Sketches, Biographical Sketches
@section Biographical Sketches Overview

I personally find that it makes a field much more
interesting and approachable if one knows something about
the people who have made major contributions to it: It makes
the field seem more of a dynamic human enterprise and less a
dry collection of results.

In this appendix, I attempt to provide brief biographical
sketches of some major figures in computing, along with
pointers to more extended (and reliable!) biographies.

@c
@node Edsger W. Dijkstra, Richard P Feynman, Biographical Sketches Overview, Biographical Sketches
@section Edsger W. Dijkstra

I know of no biographical information whatever on Dijkstra, but
he deserves mention for at least three reasons:

@itemize @bullet
@item
Dijkstra is one of the grand old men of the post-WW II generation
that built modern computing, contributing for example to the first
implementation of Algol-60, ancestor to most of today's infix
programming languages.

@item
Dijkstra is among the brightest lights in theoretical computer
science;  I think it is generally conceded that he has often
found the answer before otherfolk were aware of the problem.

@item
In his later career, he seems to personify almost perfectly the class of
computer scientist who is inclined to never touch a computer, to do his
best to keep his students from touching computers, and to present
computer science as a branch of pure mathematics.  (Yes, this is a
caricature.)
@end itemize

Dijkstra's theoretical contributions include the semaphores
implemented internally or externally by virtually every
modern operating system, and the three-color incremental
garbage collection algorithm I (intend to) use in Muq.

Dijkstra is one of a number of brilliant early contributors
to practical hardware and software engineering who
subsequently became very dissatisfied with the perpetually
bug-ridden state of the art, and turned to the study of ways
of producing demonstrably correct computing systems.

(C.A.R Hoare, inventor of Quicksort, and David Gries, a
compiler construction pioneer, are other examples.  I would
include Donald Knuth, except that he is a polymath who does
@emph{everything} from massive practical hacking (TeX) to
pure mathematics to humor, making him harder to pigeonhole.)

To date, formal programming verification techniques have not
had a great impact on mainstream programming practice, but
few people can work for long in the field without becoming
dissatisfied with the state of the art, and one cannot help
but feel that at some point the current split between theory
and practice of programming will close dramatically.

For a sip of vintage Dijkstra, I'd suggest: @emph{a
discipline of programming}, edsger w. dijkstra,
Prentice-Hall 1976, @sc{isbn} 0-13-215871-X.

As an illustration of the current gap between the
theoretical and practical wings of the computing community,
I'd contrast Kernigan and Ritchie's assurance that all
examples in their book have been tested directly from the
text, with Dijstra's laconic comment in the above book that,
"None of the programs in this monograph, needless to say,
has been tested on a machine."

Dijkstra seems to me to have something of the shrillness of
a brilliant pioneer feeling ignored and bypassed by the
mainstream, but he is a profound analyst and synthesist who
cares deeply about correctness, elegance and beauty in
computing, and careful attention to him can hardly fail to
deepen one's own understanding.

(Folks intrigued by the above book might look to
@emph{Formal Development of Programs and Proofs}, edited by
Edsger W. Dijkstra, Addison-Wesley 1990, ISBN 0-201-17237-2
for a more recent survey.)

Why have formal programming techniques had such little
little success as yet?

I'm confident that somefolk would reply more or less to the
effect that most programmers are just too dumb and/or
ignorant to apply them, but I think this cheap shot falls
far short of the complete story.

First of all, few if any people would have the temerity to
accuse Donald Knuth of being too dumb or ignorant to apply
program proof techniques, but not even he chose to apply
them formally to TeX when he wrote it.

To be sure, David Gries cites TeX as an example of a program
written throughout with careful informal attention to
correctness considerations, but Knuth offers a reward of
$10.24 for bugs located in TeX, hardly suggesting absolute
faith in the absolute correctness of the program.

Despite periodic media campaigns suggesting that
formal program verification techniques are about to charge
over the hill and rescue computing from the reliability
crisis, actual application of the best techniques available
have repeatedly had unsatisfying results.  A Canadian
project to use computer rather than mechanical controls in a
nuclear reactor, led by Dave Parnas, one of the leading
practitioners of the field, ended with the conclusion that
if the project were redone, it would be better to stick with
mechanical controls.

Further, even "provably correct" toy programs published in
refereed journals regularly turn out to contain errors.

The fundamental problems appear to be:

@enumerate
@item
Program proofs are just as succeptable to errors as
mathematical proofs, not to mention programs.

@item
Classical algorithms are short and tricky, but real
programs are long and boring.

@item
It is frequently impractical to express the problem
formally.
@end enumerate

The first is a problem because whereas increasing our
confidence in short mathematical proofs can reasonably be
accomplished by publishing them and having the top
specialists in the field debate them at length, this is
scarcely an economic way to produce billions of lines of
computer code annually.

The second is a problem because while the innovative
algorithms that computer scientists devote their attention
to tend to be short and tricky, both allowing and justifying
application of proof techniques, most practical computer
programs seem to consist of vast amounts of very
straight-forward code which just don't reward proof
techniques.  The vast majority of coding errors are
completely trivial when noticed. The real program
reliability issues seem to relate more to dealing
consistently with thousands of trivial constraints than a
handful of difficult ones:  One seems to need fiendishly
precise bookkeeping more than brilliant insight.

The third is a problem because if you can't specify formally
the requirements on the program, or if the specification is
bigger and buggier than the program itself, formal
verification is quite useless.  David Parnas relates asking
an engineer whether "the temperature exceeds 350 degrees"
means exceeding it for a microsecond, or for some percentage
of the time over some interval, or some weighted combination
of time in excess times degrees in excess or just what... I
think he got chased out of the office.  But if even such an
apparently straight-forward issue is problematical, imagine
the difficulty of verifying that a program is "ergonomic" or
whatever.

The real wins in reliability seem so far to have come from
automating programming tasks, rather than analysing them: If
the code produced is larger than the code producing it, then
it can be analysed and debugged more thoroughly, and the
resulting code quality may be much higher.  An outstanding
example is register allocation, which used to be done by
hand by assembly programmers, clobbered registers being a
perpetual source of bugs, and which is now done almost
universally by compilers, clobbered registers being today an
almost unknown problem.

That said, there does seem also to be an almost unnoticed,
slow but steady spread of automatic program verification
techniques: The typechecker in a compiler is in fact a
specialized but useful theorem-prover establishing certain
sorts of correctness properties on the program.  There is
steady progress in both the underlying dataflow analysis
algorithms used to deduce program properties -- mostly with
the immediate goal of optimizing the code -- and in the
richness of the type language provided to the user: The type
language of C is a huge advance over that of early Fortran,
and the type languages of recent offerings such as Haskell
are dramatically more sophisticated yet.

Will the next increments in program reliability come from
just exhorting programmers to be more perfect?  From more
abstract languages which automate more of the code
generation?  From more effective typecheckers and type
languages that understand more properties of the program?
From programmers gradually learning to apply a deeper
understanding of algorithmic structure to existing
languages?  From semantically more sophisticated code
editors which produce programs known to be correct by
construction?  From switching to a different programming
paradigm which makes programming simpler?  From capitalizing
on cheaper hardware by writing code which is less efficient
but simpler and more reliable?

@c
@node Richard P Feynman, Alan Kay, Edsger W. Dijkstra, Biographical Sketches
@section Richard P Feynman 1918-1986

I can't honestly say that Feynman deserves a place in the
history of computing.  But he has been dead less than a
decade and may yet earn such a place: He suggested in 1982
that quantum computers might have fundamentally more
powerful computational abilities than conventional ones
(basing his conjecture on the extreme difficulty encountered
in computing the result of quantum mechanical processes on
conventional computers, in marked contrast to the ease with
which Nature computes the same results), a suggestion which
has feen followed up by fits and starts, and has recently
led to the conclusion that either quantum mechanics is wrong
in some respect, or else a quantum mechanical computer can
make factoring integers "easy", destroying the entire
existing edifice of publicKey cryptography, the current
proposed basis for the electronic community of the future.

Mostly, Dick Feynman is just a wonderful, irreplacable
character, and I can't resist including here a pointer to a
biography of him.

Dick Feynman was an irrepressably "curious character" who
devoted his life to playing with the universe, teasing out
its secrets in his own way on his own initiative, fascinated
by everything from quarks to ants to galaxies, absolutely
unafraid of any problem or person.

As a child, he would contract to fix other people's radios
despite having initially no understanding whatever of
electronics: He took them apart, determined experimentally
that replacing the glass tubes that didn't glow would often
restore correct operation, and shortly had a virtual
electronics laboratory in his bedroom.

From birth to death, he was never satisfied with accepting
conventional wisdom on any subject: He was never happy until
he had taken a subject apart and put it back together
himself in his own way.

He invented his own algebraic notation which he only very
reluctantly abandoned, finally concluding that communicating
with others sometimes justifies settling for a second-best
notation.

Self-taught in mathematics as in everything else, in his
senior college year he won the nation's most difficult and
prestigious mathematics competition -- the Putnam -- by a
score so far ahead of the next four finishers as to astound
the scorers.  In many years, more than half the entrants
fail to complete a single problem in the allotted time:
Feynman left early.

During the Manhattan project Feynman, unstoppably energetic
and completely unintimidated by the collected finest minds
in physics, ran the computing department and several other
divisions, served as a one-man "solutions please" phone
service for all difficulties mathematical, commuted to tend
a dying wife, and still managed to find enough time for
practical jokes and recreation that his memoirs leave one
with the modest impression that he was there merely as a
spectator.

Feynman is best known for -- characteristically -- taking
quantum mechanics apart and putting it back together his own
way, inventing his own notation in the process.  This time
he got the world to switch to his notation rather than vice
versa: Feynman diagrams are now the indespensable language
of quantum mechanical computations, to the point that most
high energy physicists would be lost without them.

I'm inclined to believe that Richard Feynman should be
counted the eighth and final fatality of the Challenger
shuttle explosion: Like many Manhattan Project veterans, he
eventually contracted a normally rare cancer, which had been
in remission for nearly decade when he was called to
Washington to participate in the media circus.  Stress has a
well-known depressing effect on the immune system: He died
almost immediately after returning.

Dick was a gifted and enthusiastic storyteller: He published
two volumes of anecdotes, @emph{Surely You're Joking, Mr
Feynman!"} (WW Norton and Company 1985, ISBN 0-393-01921-7)
and @emph{What Do You Care What Other People Think?} (1988,
ISBN 0-553-34784-5).  His friends were incensed that he left
himself looking a buffoon; He was incensed when they were
taken as autobiography: "Not An Autobiography.  Not So.
Simply A Set Of Anecdotes."

More true-to-life image of Feynman may be gleaned from
Freeman Dyson's @emph{Disturbing the Universe} (Harper
Colophon Books 1979, ISBN 0-06-090771-1): Dyson gets credit
for explaining Feynman diagrams to the rest of the world.
(Dyson is himself a fascinating person person, and like
Feynman sufficiently modest that one gets no real sense of
his accomplishments from his own writing.)

The best biography of Feynman to date, and probably for
some time to come, is James Gleick's @emph{Genius: The
Life And Science Of Richard Feynman} (Pantheon Books 1992,
ISBN 0-679-40836-3).

@c
@node Alan Kay, Donald Knuth, Richard P Feynman, Biographical Sketches
@section Alan Kay

In the late 60s, Alan Kay was a wild-eyed maniac doing his
thesis on The Reactive Engine and forecasting that in the
near future we would have cheap personal laptop computers
with crisp color graphics and more computing power than an
IBM mainframe.  Obviously a nut case.

Today we in fact have cheap personal laptop computers with
merely stunning color graphics, and so much more computing
power than an IBM mainframe of that era as to make the
comparison ludicrous: In retrospect, Alan was off mainly in
being too conservative.

We owe much of the utility of those laptops to Alan Kay:
When forecasting the arrival of what he called the Dynabook,
he also observed that they would scarcely be useful if
equipped with software no better than the IBM mainframe
operating systems of the time, and he set out to remedy
the problem:

He convinced the Xerox Palo Alto Research Center to fund a
lab to work on the problem, put together the best hardware
prototype of the Dynabook that he could manage with
available technology -- the Alto, which with bitmapped
display, mouse and network connectivity was in many ways the
prototype for the modern workstation -- and set out to
design software to make it all usable.

He chose schoolchildren as his test audience early on,
observing that children need much better hardware and
software than adults, who can successfully be paid to put up
with almost any degree of awfulness, and did a series of
cycles of design and implementation followed by analysis of
people actually using the system and back to the drawing
board.

The result was Smalltalk, which did much to mainstream
object-oriented programming, and a snazzy mice-and-menus
user interface which Xerox, in its inimitable fashion,
commercialized in the form of the Xerox Star computer, a
runaway commercial failure.  (Xerox is very good at not
making money selling computers, having a long series of such
efforts, stretching back to the Sigma V computer.  Hmm?
Never heard of it?)  All was not lost: A little company
named Apple was looking for something exciting to do for
their next computer, toured Xerox PARC, and the rest is
history.  (Well, actually, their first attempt was the Apple
Lisa, which in commercial terms was right on a par with the
Star, but the second try was the MacIntosh -- first
microcomputer computer to ship with no end-user
programmability whatever -- and things turned out ok in the
end, so much so that Apple eventually sued Microsoft for
stealing Xerox's ideas from them.)

My favorite Alan Kay quote:

@quotation
@cartouche
Simple things should be simple.  Complex things should be possible.
@end cartouche
@end quotation

@noindent
I consider this a deceptively subtle insight on user
interface design:  Too many interfaces try to make
complex things simple -- which is combinatorially
impossible -- and succeed in the end only in making
simple things complex.

I'm also fond of Alan Kay's observation (during a talk at
the UW) that "Graduate students are like geese: We imprint
on the first good idea we see, and spend the rest of our
careers chasing it."

And his observation that the great problem with Lisp is that
it is just good enough to keep us from developing something
really good.  (When everyone laughed, he added plaintively,
"It's true!  You know it's true@dots{})

@c
@node Donald Knuth, Doug Lenat, Alan Kay, Biographical Sketches
@section Donald Knuth

Donald Knuth is generally recognized as the Father of
Computer Science: He has published numerous papers in both
computer science and mathematics.  (He also comments that
switching back and forth between the two fields requires a
distinct mental changing of gears.)

He founded modern computational complexity theory, including
introducing the now-familiar "big-O" notation for asymtotic
efficiency of an algorithm.

He developed LR parsing theory which (once the additional
refinements leading to LALR parsing were developed) lead to
the parser generators such as @code{yacc} which power almost
all modern compilers.

He is perhaps best known in the programming fraternity for
his eternally unfinished Art Of Computer Programming series
summarizing and analysing the important algorithms for
sequential computers: After completing three of a projected
five volumes, he became dissatisfied with the typesetting
technology he had to use, and stopped to write a little
formatter that grew into the TeX typesetting program plus
the Metafont font generation program plus a series of five
books on them.  More recently, he has also detoured to write
a program (and book) on generation of graphs and datasets.
It has now (1994) been twenty-six years since the first part
of Volume One appeared, and twenty-one years since Volume
Three first appeared, but I see the publishers are listing
Volume Four as "forthcoming", so I'm sure we can expect
prompt completion of the work @dots{} @emph{grin}.

@c
@node Doug Lenat, Marvin Minsky, Donald Knuth, Biographical Sketches
@section Doug Lenat

Doug Lenat wrote possibly the most interesting program yet
to come out of the artificial intelligence field: @sc{am}
@footnote{Doug writes that the name means nothing, but
stands alone sufficient onto itself, as in the biblical I
@sc{am} that I @sc{am}.  Personally, I suspect that it
originally stood for something like Artificial
Mathematician, but that he later decided that to be a bit
too pretentious@dots{}}.

@sc{am} was a program to propose interesting mathematical
theorems.  Not to prove them: The artificial intelligence
field is rife with programs that try to prove theorems,
almost all of them uninteresting.  @sc{am} had no concept of
proof, it simply proposed theorems, more or less on
intuition.

@sc{am} ran on a @sc{pdp-10} (the standard lisp machine in
those days) and started with a small nucleus of concepts,
plus a set of rules for specializing and generalizing
concepts, and deciding how interesting they are.  It kept a
prioritized list of interesting things to investigate, and
cyclically tried one of the most interesting and then added
to the list any further ideas resulting.

Starting from its small nucleus of ideas from set theory,
@sc{am} could discover among other things counting,
addition, multiplication, prime numbers and Goldbach's
Conjecture, which it would suggest to be true but
uninterestng.

Perhaps most interestingly, it would invent the opposite of
prime numbers -- maximally divisible numbers -- and trot off
to propose theorems about them.  Why is this interesting?
First of all, because Doug didn't know anything about such
numbers when he wrote the program, and in fact thought the
program was barking up an empty tree when it went that
direction.  Secondly, because the theorems did indeed turn
out to be interesting, and for awhile it was thought that
this might be the first example of a computer program doing
interesting original mathematics.  Thirdly, because it did
eventually turn out that @code{am} had been anticipated
@dots{} by none other than Srinivasa Ramanujan, a
self-taught Indian genius who is arguably the greatest
natural talent mathematics has seen -- and who, like
@sc{am}, excelled at arithmetic computation while having
almost no concept of what a proof is.

Both @sc{am}'s successes and failures have been dissected in
some detail by the artificial intelligence community.  (It
never accomplished much else, and wasn't able to adapt very
well to other problem domains.)  Doug eventually concluded
that

@itemize @bullet
@item
@sc{am}'s remarkable successes were due in a sense to
it starting with a notation amazingly well suited to
making simple, interesting statements about mathematics --
in essence, due to Alonzo Church's brilliance in designing
the lambda calculus.

@item
That "intelligent" behavior depends critically on having
available a large stock of "common-sense" knowledge --
perhaps 100,000 rule's worth.
@end itemize

Whereup he trotted off to code up those 100,000 or so rules,
and has hardly been heard of since.  (Although he did pause
long enough to win a national computer wargame competition
by what might nowadays be called genetic programming: His
computer search evolved a fleet design sufficiently
convincing that most of his opponents resigned before a shot
was fired, and the competition rules got changed the next
year to close the loophole@dots{})

@c
@node Marvin Minsky, Johnny von Neumann, Doug Lenat, Biographical Sketches
@section Marvin Minsky

Marvin Minsky is one of the grand old men of artificial
intelligence.  He hangs out at MIT, probably because it's
name starts with M@dots{}

I like Minsky because in a field (artificial intelligence)
without a great deal to show for its early promises, and
given to sometimes silly claims and ideas, he strikes me as
one of the few people consistently able to see the obvious.

He's been widely blamed for setting back the field of neural
net computing twenty years, for the sin of publicly
observing that the Perceptron (the state of the art back
then) was inherently limited to linearly seperable
distinctions, and hence was hardly a beeline to artificial
intelligence.  He was right, and many people have never
forgiven him for that@dots{}

Minsky has written a number of popular books expounding his
ideas, such as @emph{The Society of Mind} @sc{simon and
shuster 1985} ISBN 0-671-60740-5, which has lots of bitesize
thoughts in a format which he thinks of as innovative, and
which I tend to think of as "Artificial Intelligence Meets
MTV" @emph{grin}.

My favorite Minsky quote, from a talk at the UW, is to the
effect that perhaps religions serve to keep us from wasting
time on unanswerable quetions by providing pat answers.

My favorite Minsky anecdote comes from Stephen Levy's
@strong{Hackers}, wherein one of Minsky's pet projects, a
ping-pong playing robot, decided that his bald pate looked a
@emph{lot} like a ping-pong ball, so it made a good college
try at decapitating him...

Artificial intelligence seems to be quite away off still.

@c
@node Johnny von Neumann, Isaac Newton, Marvin Minsky, Biographical Sketches
@section Johnny von Neumann

In the early years of this century, it was considered quite
acceptable in Hungary for first-rate mathematicians to
teach schoolchildren.  Partly in consequence, Hungary
produced a flock of first-rate mathematical talents, not
the least of whom was John von Neumann (the "von" being
an affectation of nobility that he alone in his family
maintained).

Von Neuman was a mathematician, a calculator (it is said
that during the Manhattan Project to develop the atomic
bomb, whenever an impromptu numerical result was needed,
Dick Feynman would pound out the result on mechanical
calculator, Fermi (?) would work it out on a on a slide
rule, and von Neumann would work it out in his head...  all
three usually arriving at the about the same result at about
the same time) and -- somewhat unusually for a person of
such talents -- a man somewhat adept at power politics and
engineering: He was the first and last man to run a
significant engineering project (building an early computer,
no less) at the Princeton Institute of Advanced Studies,
more usually understood as an intellectual graveyard for
burned-out scientists (e.g., Kurt Godel starved himself to
death there, convinced that the cooks were trying to poison
him).

Von Neumann had a mind so quick that he inspired something
like Isaac Newton's curious demigod impression on his
contemporaries, but -- possibly due in part to being a bon
vivant and ladies man, along with working usually in
collaboration rather than alone -- left a considerably less
distinctive body of work: He is perhaps best known for his
work establishing game theory, applied during WW II to
anti-submarine warfare and leading later to the basic
playing algorithm for perfect-information two-person games
such as chess.

A biography of von Neuman in conjunction with Norbert
Wiener, a favorite collaborator:

John von neumann and Norbert Wiener:
From Mathematics to the Technologies of Life and Death
Steve J Heims  ISBN 0-262-08105-9

@c
@node Isaac Newton, Alan Turing, Johnny von Neumann, Biographical Sketches
@section Isaac Newton

One doesn't normally think of Isaac Newton as one of the
fathers of modern computing, exactly, but it is not at all
inappropriate to include him here: He is a giant figure who
has had an effect on Western science somewhat akin to that
of Jesus of Nazareth on Judiasm, casting a shadow few can
escape, welcomed or not.

Carl Friedrich Gauss (1777-1855) reserved the accolade
"illustrissimus" for only two men: Isaac Newton and
Archimedes.

Other thinkers of the first water, from Albert Einstein (who
wrote "Newton, forgive me; you found the only way which in
your age was just about possible for a man with the highest
powers of thought and creativity"@footnote{Quoted from
probably the best biography yet of Einstein: @emph{Subtle Is
The Lord} by Abraham Pais, Oxford University Press 1982,
ISBN 0-19-853907-X}) to Subramanian Chandrasekhar (who is
making an intense study of Newton's Principia his final
career project) have felt similarly indebted.

Newton performed pioneering computations in celestial
mechanics, contributed mathematical tools from the calculus
to perturbation theory to Newton's Method for root finding
used pervasively in contemporary computing, contributed the
physical laws used today in almost all physical computations
from spacecraft trajectories to blockworld educational
programs, and contributed even the telescope design which
today acquires most data used for celestial mechanics
computations.  It was the application of his equations to
ballistic trajectories which drove the development of early
computing devices.

Not least, Newton as much as any one person can or could,
established in the modern analytical, quantitative
scientific worldview: He is the great transitional figure
between the medieval world of mysterious animistic forces
and spirits to be qualitatively teased and appeased, and the
modern world of systematic, quantitative experimentation and
explanation in the language of mathematics.

Newton's myth has grown so great as to today perhaps almost
entirely obscure the man behind it.  Like most great
mathematicians, Newton's essential contributions came in a
few creative years in his early twenties, albeit developed
and refined throughout his life.

Physics and mathematics ("natural philosophy", in the
language of his day) were in fact to him a passing fancy of
his youth: He devoted many times more effort to both his
alchemical studies and his heretical biblical studies (he
was an Arian, convinced that Trinitarians cooked the Book in
order to establish their case) than he ever did to natural
philosophy.

He lived a monklike existence devoid of marriage or known
affairs and shunned public controversy with a horror which
to my eye seems born of insecurity; His fame today rests on
works heroically extracted from him by Edmund Halley (of
Halley's Comet fame) via a process compared to which tooth
extraction sans anesthetic might have appeared bliss itself.

Newton was in many ways a less than admirable character.
Rich in creativity and accomplishment almost beyond compare,
he could nevertheless find no morsel of generosity for
anyone who could in any way be construed as his rival.  His
professed and evident distaste for public controversy did
not prevent him from stooping repeatedly to writing barbed
attacks on his percieved rivals to be published under the
names of friends.  His treatment of John Flamsteed, Royal
Astronomer, was nothing short of disgraceful, if not
criminal: He virtually destroyed Flamsteed's career, and did
his (ultimately unsuccessful) best to destroy the man's
lifework, in single-minded pursuit of the lunar data he
wanted for Principia.

Curiously, Newton was knighted not for his world-shaking
achievements in physics and mathematics, but for his quite
trivial services as a willing political flack of the Queen
in Parliament.  (His greatest recorded political speech was
a request to close the window, due to a draft.)

Newton ended his life comfortably and profitably as Warden
of the Mint, an initially minor post from which he contrived
to gain full control of the Mint (originally exercised by
the Master of the Mint).

The definitive biography of Isaac Newton is @emph{Never At
Rest} by Richard S Westfall, Cambridge University Press
1980, ISBN 0-521-23143-4.  A less intimidating condensation
has been released as @emph{The Life Of Isaac Newton},
Cambridge University Press 1993, ISBN 0-521-43252-9.

Newton's @emph{Principia} was forbidding when first
published and remains so today, but is excerpted in
@emph{The Classics of Science} by Derek Gjertsen, Lilian
Barber Press 1984, ISBN 0-936508-09-4, along with works
ranging from Euclid's @emph{The Elements} -- Muq uses
Euclid's Greatest Common Divisor algorithm -- to Charles
Darwin's @emph{Origin of Species}.

@c
@node Alan Turing, Leor Zolman, Isaac Newton, Biographical Sketches
@section Alan Turing

Alan Turing (1912-1954) was an English mathematical genius
who made giant contributions to the early theory and
practice of computing: The Association for Computing
Machinery's Turing Award, the highest award in computing, is
named in his honor.

He was into long-distance running decades before it became
cool.

He was interested in a wide range of problems, developing
for example a mathematical model to explain how the leopard
might get its spots and the zebra its stripes -- still a
major research problem in biology (morphogenesis) chemistry
(reaction-diffusion systems) and mathematics. 

He was a principal member of the team which developed the
Colossus computer that cracked the German Enigma code, thus
making a major contribution to winning WW II which remained
highly classified through the 1970s.

He contributed to to the design and implementation of the
post-WW II generation of British electronic computers.

And he was unabashadly gay, leading the American CIA to
basically hound him to death as undesirable to have involved
in Important Secret Stuff, depriving him and us of half of
one of the most brilliant careers in the history of
computing: Artificial intelligence has made lamentably
little progress since his death, and I cannot help but
wonder what he might have produced give a few more decades
in which to work.

My favorite Turing quote is something to the effect that
he didn't want to built an electronic genius, that he
would be quite satisfied to produce a mediocre brain
such as that of the president of Atlantic Telephone
and Telegraph.

The definitive biography of Alan Turing is:

Alan Turing:  The Enigma
Andrew Hodges, @sc{simon and shuster 1983}, ISBN 0-671-49207-1

@c
@node Leor Zolman, Biographical Sketches Wrapup, Alan Turing, Biographical Sketches
@section Leor Zolman

Leor Zolman isn't a major figure in computer science like
Donald Knuth, but all the same I, Muq, and myriad otherfolk
have much reason to thank Leor, which I think is reason
enough to give him mention here.

Leor Zolman wrote the BDS C ("Brain Damage Software", I'm
told, "Brain Damage" supposedly being Leor's MIT nickname)
compiler for CP/M and sold it for $110 or so, in an era when
CP/M compilers were hard to find, and in particular when the
only other C compiler of note cost double what the typical
Pascal compiler cost, and ten times what BDS C cost.

BDS C is one of the most beautiful programs in the history
of computing in terms of applying originality of design and
implementation to achieve a sweet balance between means and
ends:

Through an amazingly judicious choice of implementation
techniques and language subsetting, Leor produced a compiler
which gave a compile time of seconds on a 32Kbyte
floppy-based machine, resulting in a debug cycle as quick
and pleasant on that machine as that available on most
mainframes of the time, or indeed most workstations today.

To truly appreciate this accomplishment, you need to compare
it with Whitesmith's C, a straight-forward professionally
done implementation of C for CP/M that cost ten times as
much, was at least ten times as big, and took many times
longer to compile anything.

BDS C had a significant role in establishing C as the force
it is today in microcomputing: When it appeared, Pascal was
clearly the dominant microcomputer language in the Algolic
class, and there was no other affordable C compiler
available.

BDS C resulted in porting of code back and forth between
Unix and CP/M -- including (as I can personally testify)
such tools as Yacc, otherwise unavailable in the CP/M world
at any price.

BDS C sparked one of the first serious attempts at a free
Unix for micros: MARC, intended in part as a memorial for Ed
Ziemba, killed in a diving accident.  (I'd be curious to
hear what happened.  My own experiences trying to implement
stuff like Smalltalk on CP/M lead me to suspect that MARC
simply hit a hardware wall: There's only so much you can do
when given about 16K of code space and 16K of data space.)

BDS C spawned the BDS C User's Group, still active today,
albeit now calling itself the C User's Group, which in turn
did much to promote C on micros and the circulation of C
software and tools between the micro and workstation worlds.

Finally, BDS C induced me to learn C, and to write a series
of projects in BDS C, including Citadel (a system which
itself in turn introduced a certain number of microfolk to
learn and use C).  Several of these projects have been deep
influences on Muq, most notably Tetra, a byte-coded RPN
programming system with virtual memory (off floppy!) and
text windows, many echos of which may be seen in Muq.

I'm told Leor once walked into a conference packed with
compiler folk, and was astonished when they gave him a
standing ovation.  I hope it is true: He deserves it, and
much more.

@c ==============================================================
@c - Biographical Sketches Wrapup

@c
@node Biographical Sketches Wrapup, Reference Shelf, Leor Zolman, Biographical Sketches
@section Biographical Sketches Wrapup

I won't pretend that the above list of biographical sketches
is anything more than an idiosyncratic sampling.  Here are
some additional books by or about people who one way or
another have had a major influence on computing:



Hackers
Stephen Levy, Dell Publishing 1984, ISBN 0-440-13405-6

Looks like a Hollywood instant book, but actually very well
done.  Has the only worthwhile biographical material I've
seen on Richard Stallman, among others.  A fascinating read
which includes coverage of the first Lisp implementation,
although I found the last section (on kids developing video
games) of less interest.





Programmers at Work
Susan Lammers ISBN 0-914845-71-3

Somewhat fluffy series of interviews with nineteen
programmers from the microcomputer era, including silly
stuff like their doodles.



Steve Jobs: The Journey Is The Reward
Jeffrey S Young ISBN 0-673-18864-7

How the son of a used car salesman graduated from phone
phreaking, peddling illegal "blue boxes", sleeping in the
ceiling and attending an Indian guru to cofounding and
running one of the world's major computer corporations and
then getting fired by his handpicked top aide.



John Sculley: Odyssey
with John A Byrne ISBN 0-06-015780-1

How a guy whose great intellectual achievement was putting
Pepsi in bigger plastic bottles wound up firing Steve Jobs
from Apple and putting the Mac in bigger plastic boxes.



The Great Mental Calculators
Steven B Smith ISBN 0-231-05640-0

Okie, this is a trifle off topic, but: Up until WW II,
"computer" meant a person who computes.  Much of the
computation for the atomic bomb -- built in three years
start to finish, remember -- was done by parallel processing
machines consisting of women called "computers" armed with
mechanical calculators, computing and exchanging results
according to programs written by mathematicians.  In modern
terminology, this was a highly pipelined Multiple
Instruction-stream Multiple Data-stream (MIMD) computer with
an extraordinarily slow cycle time.

Before any sort of computing machinery, people factored
millions of numbers and tabulated the results, among many
other computing achievements stunning to contemplate today.

Particularly amazing were the folk who did prodigious
computations entirely mentally.  This is the only good book
I've found on this subject, ranging from Jedediah Buxton,
the dimwitted English rustic who never discovered that
multiplying by ten can be done simply by adding a zero (he
multiplied by 5 and 2) but nevertheless earned vast (and
meticulously accounted for) quantities of beer by performing
prodigious computations on bets, to mathematicians like Karl
Gauss and Srinivasa Ramanujan, both with a credible claim to
being the greatest human mathematician, and both
indefatigable computers.

Not mentioned in this book: One Ramanujan formula was for
many years the best known algorithm for electronically
computing pi to many places, and used in a number of
record-breaking computations, despite nobody having managed
to prove that it was correct.  Gauss's results are of course
used daily in too many ways to count, not least his favorite
least-squares technique for fitting a line to unreliable
data points and Gaussian blurring to scale digital images to
another size.

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:

