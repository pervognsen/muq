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

@node Future Plans, Future Plans Overview, Top, Top
@chapter Future Plans

@menu
* Future Plans Overview::
* More Transparent Networking::
* Interfacing To The World::
* Arrays and Vectors::
* GUI::
* Multimedia Support::
* More Islekits::
* Integrated Development Environment::
* Mail Client::
* Linux VFS::
* Lisp Compiler::
* C-like Compiler::
* J Compiler::
* Smalltalk Compiler - And Class Hierarchy::
* Perl Compiler::
* Elisp Compiler::
* SQL Compiler::
* Java Compilers::
* Functional Programming Compilers::
* Logic Programming Compiler::
* Constraint Compilers::
* Experimental Compilers::
* Experimental Datatypes::
* CVS Support::
* Procedural Data Compression::
* Automatic Updates::
* Large Site Load Balancing::
* Parallel Computing::
* Tainting::
* Ports to Windows Mac Etc::
* Flashcrowd-Proofing::
* Big Community Support::
* More Numbers::
* Native Code::
* Blackboard Computing::
* Smart Languages::
* Resource Market::
* Clarity and Robustness::
* Future Plans Wrapup::
@end menu

@c {{{ Future Plans Overview

@c
@node Future Plans Overview, More Transparent Networking, Future Plans, Future Plans
@section Future Plans Overview

Now that the Muq infrastructure is more or less in place, the fun
of actually doing various things with it can start!

This section outlines some of the directions I'd like to see Muq
go.  Some of them are projects I intend to do, some are projects
I'd like to do but likely won't have time, and some are projects
I'd love to see done but cannot possibly do myself.

You'll note a lot of compilers listed.

Why?

Because compilers are a major part of programmer's toolkit, and a good
programmer, like a good carpenter, uses the right tool for the job.

Programmers will no more voluntarily use @sc{apl} for an assembly job or
assembly for a Perl job, than would a carpenter voluntarily use an
electric drill for a mallet or a screwdriver for a chisel.

One of the great potential strengths of Muq is that it can free
programmers to use the right syntax for the job, in contrast to
one-tool-for-all-jobs software environments.

@c {{{endfold}}}
@c {{{ More Transparent Networking
@c
@node More Transparent Networking, Interfacing To The World, Future Plans Overview, Future Plans
@section More Transparent Networking

Muq already supports a considerable degree of network transparency:
Micronesia programmers for the most part do not have to worry about
whether a given object or user is local or remote.

But there is much more that could be done on this front, and I see this
as a core Muq capability and selling point, something that Muq should be
doing better than any other system in existence.

Ideally, every Muq virtual machine operation should work identically on
any mixture of local and remote operands.  This involves just lots and
lots of detailed hacking and special cases, deep in the Muq C server
code.

I don't expect that anyone but me will be doing this work!

@c {{{endfold}}}
@c {{{ Interfacing To The World
@c
@node Interfacing To The World, Arrays and Vectors, More Transparent Networking, Future Plans
@section Interfacing To The World

Eric S Raymond says that one nice thing about Python is that
"it comes with batteries included":  It has good support
out of the box for interfacing to a variety of net protocols.

Muq has a nice core engine, but it does not yet have this kind
of connectivity support.  An engine which cannot be hooked up
to the load is pretty useless in practice, however beautiful
its internals may be in principle, so I think providing such
interfaces is a very high practical priority for Muq.

Particularly important:

@itemize @bullet
@item
More @sc{telnet} support:  Muq has a reasonable core engine
for the @sc{telnet} protocol, but few of the standard
options are supported yet.

@item
@sc{ssh} support: It would be wonderful if people could log
in and use the server in a secure fashion.  This part probably
needs to be done in the crypto Free World, however.

@item
@sc{html} support.  If you can't fetch and serve web content,
you hardly exist at all in today's Internet.  Secure web
browser support would be a plus.  Lots of fun Muq projects
have to wait on this, such as smart and filtering web proxies,
or using transformed web content as part of a virtual world.

@item
@sc{ftp} support:  @sc{ftp} is the standard protocol for
distribution of large filesets.  We could use it to grab
Project Gutenberg books on the fly as content for virutal
worlds, or to distribute updates of Muq server and library
code.  I could use emacs' ange-ftp support to edit @sc{muf}
program source directly in-db without having to save it to
a hostfile.

@item
@sc{smtp} support: It would be nice to link in-world
paging, mudmail and standard internet mail.  I'd love
to write a really good mail client in Muq.  But we
need the basic protocol implementation first.
@end itemize

Beyond that, the sky is the limit: @sc{ldap},
@sc{icq}, @sc{snmp}, whatever -- the more, the
merrier!  @sc{corba} support would be expecially
nice.  Or how about implementing support for the
server end of the AlphaWorlds, Onlive! Worlds,
Quake or Ultima Online protocols, say, so we can
use the free clients available for them?

None of this requires knowledge or hacking of the Muq
server internals:  If someone else could do some of
this stuff, it would free me up to spend more time
improving the core server functionality.

For a first cut implementation, at least, I'd leverage
(say) existing Perl implementations of these protocols,
rather than re-inventing the wheel:  Simple Perl scripts
can be run from Muq via @code{]rootPopenSocket}, with
suitable @sc{muf} wrapper code making it all transparent
to the Muq application programmer.  When (and if!) the
separate Perl processes become efficiency issues, we
can consider doing native @sc{muf} implementations.
Or @xref{Perl Compiler}.

Similar comments apply to such things as interfacing
Muq to standard engines such as @code{gdbm}:  An
external program linked to the relevant libraries,
started up via @code{]rootPopenSocket} and presented
to the Muq application programmer via suitable
wrappers can make another facet of the external
world available to the Muq application programmer
(and end-user).

How about a bridge allowing Muq to be used as a
@sc{gimp} script language?  This could allow
(say) smart websites written in Muq to use the
full power of @sc{gimp} to generate on-the-fly
graphics.  The existing Perl bridge to @code{gimp}
could be re-used, at least for the first try.


@c {{{endfold}}}
@c {{{ Arrays and Vectors
@c
@node Arrays and Vectors, GUI, Interfacing To The World, Future Plans
@section Arrays and Vectors

Muq currently only has general purpose one-dimensional vectors.

Muq needs vectors specialized to hold (for example) bytes, shorts,
32-bit ints, 64-bit ints, and floats.  These are useful for a
variety of things such as holding RGB images and MRI datasets,
and allowing efficient operations upon them.  (Since all the
values in such a specialized array are known to be binary values
of the same type, a great deal of type-checking overhead needed
in typical Muq virtual memory functions can be dispensed with.)

Once these are in place, support can be implemented for putting their
contents in shared memory, which will allow efficient communication
between Muq softcode and external programs doing slow, complex
operations on them -- (maximum-entropy image cleanup, say).

I'd like to build something like a poor man's AVS on top of
those facilities once they are in place.  (If you haven't
seen AVS, it is a pretty cool but quite expensive scientific
visualization program for working with image, volume and
polygon datasets.  Yes, I do 3D graphics for a living!)

This project would also involve relaxing the current roughly 64K
maximum-ength constraints on vectors, strings and such.

This is deep-down Muq server hacking, so it is most unlikely
anyone other than me will do this.

@c {{{endfold}}}
@c {{{ GUI
@c
@node GUI, Multimedia Support, Arrays and Vectors, Future Plans
@section GUI

Telnet connections to glass-TTY interfaces are traditional
in the mud world, but very archaic and very limiting in
what one can do.

For example, writing a really good Muq db administration
and configuration tool using only glass-TTY style interface
tools strikes me as more work than it is worth.

I would @strong{really} like to see decent GUI facilities
hooked up to Muq, and sooner rather than later.

There are several plausible design approaches:

@itemize @bullet
@item
Use Tcl/Tk.  Tcl/Tk is
free, tested, reasonably secure, available on all the major platforms,
easy to drive as a subprocess, and already installed on
many Linux boxes.

We can write a @code{wish} script to handle the interaction,
and run it in a subprocess via Muq's existing @code{]rootPopenSocket}
primitive.  Wrappers written in @sc{muf} can hide all this from the
Muq application programmer, just as @code{xlib} &tc hide X protocol
communications from C programmers.  The Muq Event System should
be used to supply "callback" handlers for widget events.

If we want, we can run @code{wish} processes on other machines via
network links, so the display doesn't have to be on the same machine
as the Muq server process.

Tcl/Tk already has a Toogl widget for doing OpenGL graphics, and
will likely shortly have a Gecko widget for doing @sc{html} display.

@item
Use wxWindows.  This was my favorite option at one point:
wxWindows has a vigorous open source team developing it, and runs
on Windows, Mac, Unix/Motif and Unix/Gtk:  It would let us be as
cross-platform as Tcl/Tk would, at a higher level of functionality
-- and also at a higher level of Muq support effort.  It sounds
likely that wxWindows will soon also support Unix/Qt, allowing
nice Muq GUIs on both @sc{gnome} and @sc{kde}.

@item
Use Gtk.  Gtk has a fancier set of widgets that will integrate better
with the Linux hosts used by most Muq fans.  A Tcl wrapper could be
added around the basic widget set and everything then done just as
in the above design.  Or a Tcl-free subserver could be used.
This is currently my favored option, because there is now a
Windows port of Gtk (@code{http://user.sgic.fi/~tml/gimp/win32/}) and
I anticipate with the huge amount of momentum behind Gtk that this
port will thrive and a Mac port will follow in due course -- meaning
that Gtk will wind up as portable as wxWindows, without the overhead
of the extra software layer.  Which in turn means that wxWindows probably
will get very little support.  All in all Gtk looks like the safest horse
to which to hitch the Muq wagon.

@item
Use the Java Swing widgetset.  This would open the way to eventually running really
decent GUIs from Muq on random users who simply connect to the server
via HTTP while web-browsing, without downloading any sort of special
client.  Dropping the Muq/Micronesia barrier to entry that low would
be fantastic.  But the technology seems very bleeding-edge at present.

@item
Use X, say by implementing CLX (CommonLisp bindings to X) in Muq
softcode, or simply linking an appropriate library (Lesstif?) into
the Muq server.  I'm not very keen on this because X has severe
security issues (once someone can connect to your X server they
can do nasties like steal all your keystrokes) that make it
unsuited for running GUI components provided by random untrusted
sites on the Internet: This would vastly reduce the scope for
doing interesting collaborative applications in Muq.
@end itemize

This GUI stuff doesn't involve any deep understanding of the Muq
internals, so someone else could do it as easily as I could, but
it needs to be done pretty soon, so I'll probably wind up being
the one doing it.


@c {{{endfold}}}
@c {{{ Multimedia Support
@c
@node Multimedia Support, More Islekits, GUI, Future Plans
@section Multimedia Support

My wife and I are just wrapping up ripping our CD collection to disk,
and I can now play any track in our collection with a single
emacs@footnote{Yeah, but GUIs aren't as convenient when one lives in
emacs!} keystroke.  Whee -- sound and video can add amazing punch to a
system!

A lot of multimedia support can consist of just small wrapper
programs to be executed from within Muq via @code{]rootPopenSocket}.
Fun to do, worth doing, but not a major design or server issue.

What I'm primarily thinking of at the moment, however, is
3D graphics.

3D interactive graphics is cool, is tremendous fun, is finally
getting decent hardware support on Linux, and offers tremendous
scope for teaching and applying various sorts of programming
techniques.  It is also what I do for a living, most of the time!

So I'm very interested in adding 3D graphic capabilities to
Muq.

I'd like to do this by building on top of the previously
mentioned Arrays and Vectors, and GUI projects, and then
running an OpenGL-based rendering engine in a separate
host process, forked off from the Muq server using
@code{]rootPopenSocket}.  Synchronization would be done
via the pipe, and communication of large polygon, volume
and image/texture datasets would be done via shared
memory.

I'm currently thinking of using the Skandha4 scientific
visualization application as the rendering engine, since
it happens that I wrote it and just recently ported it to Linux.

There are a whole slew of spatial datastructures and algorithms
which it would be nice to implement in Muq in this context --
R-trees for indexing spatial datasets, for example, or
polygon reduction.


@c {{{endfold}}}
@c {{{ More Islekits
@c
@node More Islekits, Integrated Development Environment, Multimedia Support, Future Plans
@section More Islekits

The current Micronesia islekit is a demonstration of providing
a conventional mud-like environment on top of Muq, but is
deliberately rather unexciting.  

I hope and expect that other people will extend Micronesia in various
ways, and probably write completely new islekits from scratch for it.
(If someone wants to take over maintainance of Micronesia and to start
adding tailfins and flashing lights, that would be great!)

Even within the existing Micronesia framework, completely
different mudshells can be written, plugged in and used.

It might be entertaining, educational, and even useful to
write fairly straight-forward emulations of older mudservers
on top of the Muq server.  Or alternatively, to write
translators from old db formats to Micronesia, allowing
old content to be run within new communities.  @sc{moo}
emulators or db converters, anyone?

Lots of great possibilities here, but I'm very unlikely
to have time to get to them:  For the most part, they
will have to wait until someone else comes along to
make them happen.

Extending Micronesia to handle 3D virtual worlds would
be great fun, and is the thing I'm most likely to find
time to do on this front.

I'd also love to see people build completely different
kinds of collaborative applications on top of Muq.
How about collaborative Internet-mediated soundfile
hacking or symbolic algebra or animation planning
or management of large-scale raytraced animation
efforts as they run or...?  Muq provides a whole
suite of capabilities which can make these sorts
of applications easier to build and more robust
and capable when complete.

@c {{{endfold}}}
@c {{{ Integrated Development Environment
@c
@node Integrated Development Environment, Mail Client, More Islekits, Future Plans
@section Integrated Development Environment

I don't want to re-invent the wheel needlessly here,
but Muq is a sophisticated software environment in
its own right, and really needs good, modern programming
tools.

A full-bore Integrated Development Environment would be wonderful, and
Muq would be an enjoyable platform on which to write one.

Short of that, there is still a lot we could do.

Anyone want to write appropriate emacs modes for Muq?

The current Muq "debugger" is very lame placeholder.  I haven't looked
at the Linux ddd debugger front end: Any chance of writing an adapter
that would let it be used with Muq?

Even doing that would require significant tweaks to the server, which
right now does not even support breakpointing or single-stepping.
(Tweaking the server to allow jobs to be single-stepped
@strong{backwards} would be great fun!)

Bringing the Muq internal documentation system up to at least the level
of emacs internal documentation tools (@code{apropos} and such) would be
another great practical aid to programming.  The CommonLisp standard on
which Muq is built provides a specification which could be used, and the
emacs internal elisp documentation system provides another quite
successful model.

I'll probably need to do most of the serious server support, but it would
be great if someone else would pick up the rest of this project.

@c {{{endfold}}}
@c {{{ Mail Client
@c
@node Mail Client, Linux VFS, Integrated Development Environment, Future Plans
@section Mail Client

My wife and I have been through at least a dozen Linux mail
client programs so far without finding one that comes close
to meeting our needs, and we both virtually live in email,
so I have a rather strong and personal motivation for
writing a Linux mail client.

Muq, having grown out of a line of virtual world servers, might
seem at first blush an odd choice of platform for writing a
mail client, but in fact its ability to handle persistent
data in a highly flexible and programmable fashion, and its
strong and growing suite of text manipulation facilities,
make it a very strong platform for such a project.

But what I have in mind is actually something new that doesn't
seem to have a name yet, which goes well beyond a traditional
mail client:  I want a personal document storage, manipulation
and presentation application which integrates handling of
web pages, email, netnews and personal calendar in an effective
way, letting me index and find documents I've read recently
regardless of format or transmission protocol, letting me
apply gag filters to content independent of the format or
protocol by which the content is delivered, and giving me
strong support for automatically sorting, prioritizing and
reformatting such documents.

Nobody but me is likely to write something that satifies
me on this front. :)

@c {{{endfold}}}
@c {{{ Linux VFS
@c
@node Linux VFS, Lisp Compiler, Mail Client, Future Plans
@section Linux VFS

It would be technically cool and potentially very useful to write a
little bridge program allowing a running Muq server to appear on Linux
as a virtual file system: This would allow the huge suite of existing
Linux tools from 'find' to emacs to grep to what have you to be easily
applied to the contents of Muq dbs.

For example, this would provide another way of using standard
emacs to browse and edit the Muq db.

The existing tools would only understand text presentations
of the various Muq datatypes, of course, but this could still
be quite useful.

Careful attention to security issues would be important!

Alternate ways of broadening the Muq/Unix interface while maintaining
decent sandbox security include a @code{muq/pub} directory containing
files visible to both Muq and Unix code and a hack allowing @sc{Muq}
code to be executed from the Unix commandline and within Unix scripts
and pipelines -- this would just require a named pipe, a Muq daemon, and
a small C wrapper.  Or one could use Unix signals and a filesystem
convention in place of the named pipe.

@c {{{endfold}}}
@c {{{ Lisp Compiler
@c
@node Lisp Compiler, C-like Compiler, Linux VFS, Future Plans
@section Lisp Compiler

The semantics of the Muq virtual machine are based on the CommonLisp
specification, and Lisp is a truly distinctive language that can do
some things far better than any other language.

For example, Lisp macros let you tune code generation and extend the
language accepted by the compiler in ways more clean and powerful than
anything from the Algolic world.

In particular, Lisp is a great language for writing the sorts of
expression rewriting done inside compilers!

So I'd love to complete Muq's half-written Lisp compiler and shell,
so I can use it to write other compilers.

This is a near-term project which I'm likely to get to long before
anyone else does -- but I'd be happy to be surprised!

@c {{{endfold}}}
@c {{{ C-like Compiler
@c
@node C-like Compiler, J Compiler, Lisp Compiler, Future Plans
@section C-like Compiler

I've written something coming up on a million lines of C code now, and
I find the syntax great for writing straight-forward basic archival
support code.

Furthermore, about 70% of today's programmers were imprinted like geese
on C notation and will never be comfortable using anything radically
different.

So a C-ish compiler and shell for Muq are strategically very important.

My current notion would be to write add some C syntax lexical scanner
primitives to the Muq virtual machine, plus an LALR(1) parser inner
loop primitive, and then write some Perl (say) scripts to massage
the output from (probably) @code{byacc} into form suitable for loading
into the Muq db.  @footnote{For an even quicker path to first release, the parser could be
written as an external C program invoked via @code{]rootPopenSocket},
with suitable @sc{muf} wrappers to hide it from the softcoder.  This
observation applies to all the other compilers discussed, of course.}

The output from the parser might well be Lisp S-expressions, which could be
fed into the Lisp compiler after a little massaging by suitable Lisp
macros.  Naturally, we'd never tell lisp-phobic C devotees what was
going on under the hood. :)

C-style pointer arithmetic doesn't make much sense on the context of
the Muq virtual machine, so the actual language is likely to wind
up chopped down much like Java on that front.  Java might actually
be a good model, in some ways.  (Python might be another model
worth looking at.)

I'll do this if need be, but it may take me awhile to get to it.
This would be a helpful project for someone else to take on.

@c {{{endfold}}}
@c {{{ J Compiler
@c
@node J Compiler, Smalltalk Compiler - And Class Hierarchy, C-like Compiler, Future Plans
@section J Compiler

J is Ken Iverson's successor to his famous @sc{apl} language.

For many sorts of hacking on arrays, @sc{apl} is enormously productive
because all the explicit looping over arrays is suppressed.

J retains all the power of @sc{apl}, but uses standard @sc{ascii}
in place of @sc{apl}'s oddball semi-hieroglyphic character set.

J also introduces a number of neat new programming ideas.

It is quite literally possible to do in half a line of J code things
which would require half a page or more of code in most other languages.
This can be handy when the dawn deadline for code delivery is rushing
toward you.

Having a J compiler for Muq would also give C-fixated users of Muq
at least a glimpse of life beyond the Algolic fold!

J is quite a simple language, so the scanning, parsing and compiling
would be relatively straightforward: Most of the work would probably be
in implementing the needed operations on arrays -- which would be good
tools to have, useful from the other Muq languages as well.

This one is fun but not critical, so (alas) I'm not likely
to get to it in the forseeable future.  I'd be delighted to
help out with server tweaks and such if someone else took
the initiative here!

@c {{{endfold}}}
@c {{{ Smalltalk Compiler - And Class Hierarchy
@c
@node Smalltalk Compiler - And Class Hierarchy, Perl Compiler, J Compiler, Future Plans
@section Smalltalk Compiler - And Class Hierarchy

I'd kind of like to see a Smalltalk syntax compiler for Muq if only as a
bit of a trip down memory lane: It was it was Smalltalk 72 that first
got me excited about object-oriented programming (I'd studied Simula67
but it hadn't clicked for me) and my very first bytecode compiler and
interpreter implementation project was a Smalltalk compiler and
interpreter done back about 1979, done right after writing my first Lisp
system.

Although Smalltalk78 as a syntax doesn't have a whole lot to recommend
it, except in comparison to Smalltalk72's wild excesses: It offers much
what any similar Algolic syntax offers these days, in rather quirky
clothing.

The Smalltalk class hierarchy, on the other hand, represents a big set
of reasonably well thought out and tested software tools:  It would be
nice to see how much of that is missing from Muq and worth importing.
It used to be that the Smalltalk folks were itching to sue anyone who
did anything along these lines (which is one reason I veered away
from Smalltalk in 1980), but I have the vague sense that the legal
issues have since receded.

This is not a project I am likely to find time to do myself in the
forseeable future, but I'd be happy to offer time-limited help
and encouragement.

@c {{{endfold}}}
@c {{{ Perl Compiler
@c
@node Perl Compiler, Elisp Compiler, Smalltalk Compiler - And Class Hierarchy, Future Plans
@section Perl Compiler

Much Muq application programming is going to be heavily text
oriented, whether it be text virtual worlds, web page synthesis, 
serving and processing or my mail client.  Perl makes hacking
text a pleasure and is known and liked by a large proportion
of Muq's potential audience:  A Muq compiler for a good
approximation to Perl syntax would be welcomed and used by
lots of people.  If it were a really close approximation, we
might even be able to run existing Perl library code within
Muq.

This is another project I'd love to see done, but which doesn't
require my knowledge of Muq internals, and which isn't critical
enough that I'm likely to get to it any time soon.

@c {{{endfold}}}
@c {{{ Elisp Compiler
@c
@node Elisp Compiler, SQL Compiler, Perl Compiler, Future Plans
@section Elisp Compiler

I live in emacs day in and day out;  It is a bit frustrating that it
is single-threaded and locks up completely whenever something grabs
the attention of that single thread.

It would be really cool if we could implement the core emacs
functionality in Muq and then run all the existing elisp code base
inside of Muq!

This would also open the door to collaborative text hacking via Muq's
networking infrastructure, and would be useful (albeit not essential)
in writing a really world-class IDE in and for Muq.

There is essentially no chance that I will find time to do this
myself, however:  It is only going to happen if someone else picks
up the ball and runs with it.

@c {{{endfold}}}
@c {{{ SQL Compiler
@c
@node SQL Compiler, Java Compilers, Elisp Compiler, Future Plans
@section SQL Compiler

There is probably no point in trying to make Muq a serious competitor to
Oracle, DB2, or even MySql: bridge programs interfacing to them make
more sense than re-inventing them, when such functionality is seriously
needed.

But Codd's relational db algebra is very pretty and useful, and a basic
implementation could be done in an evening or two: Muq already provides
persistent storage, automatic storage allocation, management and
reclamation, and B-tree indices (via the Index class) so all you really
need to do is to write a few short functions implementing the various
canonical operations, and then a simple compiler for the syntax.

The result could be a good code example for novice programmers to
play with, and could also be downright useful for quick-and-dirty
hacking around with small datasets when cranking up a major league
external database program just isn't worth the effort.

I have a feeling this particular one will never rise to the top
of my personal programming project queue, so it will probably
have to wait for someone else to get interested.

@c {{{endfold}}}
@c {{{ Java Compilers
@c
@node Java Compilers, Functional Programming Compilers, SQL Compiler, Future Plans
@section Java Compilers

There are two distinct approaches and motivations here:

@itemize @bullet
@item
Java is a well-known, decently designed language in the classic strongly
typed tradition, and would on that basis be a plausible addition to the
Muq stable of syntaxes supported, although fitting it into Muq's more
high-level and free-wheeling programming model might take a little
work.  Following this line of thought would suggest developing a
conventional compiler which accepts @sc{ascii} source code.
@item
Java is a well-defined virtual machine for which billions of dollars
worth of software development have been done:  It would be nice
to take advantage of this body of code in the Muq context.
Following this line of thought
might suggest developing a Muq compiler which accepts as input compiled
Java class files.
@end itemize

I'm not likely to get excited enough about these projects to do them
any time in the forseeable future:  For now, I'd rather concentrate
building up Muq's distinctive strengths with respect to Java, than
on improving Muq as a clone of the Java virtual machine, which is
the direction this project will inevitably drag its implementor.

@c {{{endfold}}}
@c {{{ Functional Programming Compilers
@c
@node Functional Programming Compilers, Logic Programming Compiler, Java Compilers, Future Plans
@section Functional Programming Compilers

Mainstream programming has been stuck in a rut for a quarter of a
century:  The last major addition to the repertoire was object-oriented
programming, which dates back to Simula67 in 1967.

We could use some new ideas!

The only really innovative work I know of in programming language design
and implementation right now is coming from the Functional Programming
community, whose flagship project is Haskell -- although variants of ML
still seem to get the most practical use.

What I find particularly intriguing is that much of the practical power
of programming comes from the ability to recombine a small base set
of elements in combinatorial fashion to achieve an exponentially large
space of results.

Functional programming languages combine smaller elements more freely
and compactly than any other languages I know of, and consequently are
potentially far more concise and productive than mainstream
alternatives.

Muq would be a great environment in which to experiment with fp
programming ideas: Much of the infrastructure is already
done, adding new compilers is relatively easy, and the result
could be compared in practice in free, fair, head-to-head
competition with alternative programming syntaxes.

I'd be particularly interested in trying to apply fp ideas to
procedurally defined 3D graphics worlds, where free recombination of
different procedural ideas is the name of the game -- and where the
low-level rendering is so resource intensive (whether done OpenGL- or
raytracing-style) as to make efficiency issues in the high-level code
just about irrelevant.  (Personally, I think the Haskell people are
making a strategic mistake in attempting to go head-to-head with C where
it is strongest -- efficiency -- rather that concentrating on staking
out a claim where C is weakest -- combinatorial power.)

I've included some tentative support for functional style programming in
the Muq virtual machine, such as thunks, and I'd be happy to provide
additional server support as reasonable needed if someone else wanted to
take on the softcode end of the project.  (There is virtually zero
chance that I will have time to do the whole project myself within the
forseeable future.)


@c {{{endfold}}}
@c {{{ Logic Programming Compiler
@c
@node Logic Programming Compiler, Constraint Compilers, Functional Programming Compilers, Future Plans
@section Logic Programming Compiler

I'd love to see a Prolog-style compiler for Muq, if only because my
sortaparents (David and Paula Matuszek,
@code{http://www.netaxs.com/people/nerp/}) love the language!

Logic programming notations are clearly the cats' pyjamas for compactly
defining and searching combinatorial spaces.

I've never had a good excuse to to a major project in Prolog, so
I've never developed a good intuition for when and how to apply
it.  :(

Logic programming has really distinctive strengths and weaknesses
relative to other programming languages, so it would be great to have it
at our fingertips as part of the Muq suite of programming tools.

As with many of these other compiler projects, implementing logic
programming in Muq should go very quickly, since the virtual machine
already exists and the assembler API handles all the code
generation issues.

We'd need to pick a representation and indexing mechanism for tuples
(Vectors indexed by Index objects?) and logic variables (symbols@dots{}?),
and presumably a C-coded primitive for the unify operation -- any
major issues beyond that?

I'd be happy to write or integrate some server tweaks in support of
this, but am not likely to do the rest of the project any time soon.

@c {{{endfold}}}
@c {{{ Constraint Compilers
@c
@node Constraint Compilers, Experimental Compilers, Logic Programming Compiler, Future Plans
@section Constraint Compilers

Constraint languages are a complete subfamily of very useful
programming languages:  Instead of specifying what to do,
step by step, you specify the relationships you wish to
have maintained, and the code gets cranked out for you.

The @code{make} program might be the most familiar example
to Linux programmers:  Just specify the dependencies between
programs in a Makefile and it takes care of the messy
details of updating files in correct order for you.

Dynamic persistent systems like Muq are great platforms for implementing
and applying such languages, since they are both full of complex
datastructures with important relationships we would like maintained,
and also make it easy to dynamically compile and execute appropriate
code on the fly.  (I'm thinking in particular of Alan Borning's
Smalltalk-based ThingLab.)

For example, as soon as we have dynamic 3D worlds in Muq, we'll have
lots of demand for a system which automatically generates code to update
their positions properly, starting from an abstract description of the
forces and constraints acting upon them.

Another fun little project which very likely will never rise to the
top of my programming project list!

A compiler for the usual knobs-and-tubes grapical programming notation
used by systems like the previously-mentioned @sc{avs} would be fun
and not too difficult.  The paradigm is a graphical instantiation of
dataflow computing where one has data sources (microphones, cameras,
user-controlled widgets@dots{}), data sinks (3D rendering windows, bargraph
widgets &tc &tc) and a variety of transformation operators on
datastreams (think of all the GIMP operators, say):  The user programs
"Without programming!!" by dragging and dropping appropriate icons
on a canvas and then wiring them together with the mouse.  Changes
at any source are them automatically reflected at the appropriate
sinks: Unidirectional contraint programming.  Given
completion of some of the other projects listed in this section as
support, this could be a quite enjoyable and easy project.  I never
wind up being the one to do the fun projects, so I presume someone
else will get to do this one@dots{}

A more pressing, project is implementing @code{rpm}-style package
management for Muq dbfiles: To maintain db sanity, we sooner rather than
later need to have dbfiles specify what other dbfiles they need for
correct operation, what dbfiles they conflict with, and so forth.  This
isn't very complex stuff, and both RedHat's @code{rpm} and Debian's
@code{dpkg} are available as tested examples, so implementing something
workable shouldn't be hard.  This is a critical need, so unless someone
else beats me to it pretty quickly, I'll probably wind up doing this.

@c {{{endfold}}}
@c {{{ Experimental Compilers
@c
@node Experimental Compilers, Experimental Datatypes, Constraint Compilers, Future Plans
@section Experimental Compilers

Programming languages have been largely Lost In Time for twenty or
thirty years:  What we're using today is not much better than what
Simula 67 was providing a third of a century ago.

How about some fresh ideas?

Muq potentially provides a great platform for prototyping new
programming language ideas:  The existing virtual machine and
the existing support libraries can be re-used rather than
re-invented, chopping years off the development time, and the
existing base of Muq users and applications provide a testbed
in which experimental ideas can be tried out on useful
real-life tasks.

How about allowing source code to be in modern @sc{html}
instead of archaic @sc{ascii}?  Then we could write true
subscripts and superscripts instead of using ugly
circumlutions.  We could even include explanatory diagrams
in program comments!

How about experimenting in Muq with aspect-based programming?
(See
@code{http://www.umcs.maine.edu/~ftp/wisr/wisr8/papers/kiczales/kiczales.html}.)

I've been arguing for decades now that program source code
should not be thought of -- or manipulated -- as ascii
text, but rather as sophisticated datastructures something like
the program dependency and dataflow graphs used internally by
optimizing compilers.  Source display should be more like
database queries and views than static text, and editing
operations should be more at the semantic level of
"rename this global variable" than "change this word".

Muq, is among other things a highly programmable database
optimized toward large, complex, irregular datastructures
with considerable compiler support, so it should make a
great platform for experimenting with such ideas!



@c {{{endfold}}}
@c {{{ Experimental Datatypes
@c
@node Experimental Datatypes, CVS Support, Experimental Compilers, Future Plans
@section Experimental Datatypes

Data types have been as Lost In Time as programming syntax for the last
few decades.

Pick any contemporary programming language at random, and
what are you going to find?

Structs, arrays, objects, hashtables.

Yawn.

I think we've mastered those now, and can think about moving on!

I'm particularly interested in exploring "softer" datatypes and
algorithms.

For example, the Bloom Filter is interesting: Take (say) a one-megabit
bitvector, and a hundred hash functions.  Enter words into it by hashing
each one by all 100 hash functions, and setting the corresponding bits
to 0 for even-numbered hash functions and 1 for the odd-numbered hash
functions.  Now, given a query word, hash it all 100 times and check the
corresponding bits: If you get 100 hits you 100% know the word, if you
get 50 hits (random expectation) you don't know the word, and in between
you have different levels of "familiarity" for the word. Neat! We're now
getting soft "that seems a @strong{bit} familiar" responses back instead
of just conventional hard Boolean "Definitely yes!"  or "Definitely no!"
answers.  Notice old values don't get suddenly overwritten, instead they
gradually become less familiar over time.  Very humanlike!  Very unusual
effect using conventional programming techniques!  And extremely space
efficient.  Is it coincidence that as our effects get more human-like,
they also get more efficient@dots{}?

In mathematical essence, we're generating sparse megabit queries and
projecting them onto our (nonsparse) state vector.  (And thus an
appropriate programming syntax, should be able to write the whole
thing in a few lines.  What would the appropriate programming
syntax look like?)

The idea can be extended to other kinds (scalar or complex instead of
bit) of sparse query vectors, and we can search for closest matches
among the set of known vectors instead of just projecting onto the state
vector.  The result can be a very vague, soft notion of finding
"similar" situations seen in the past, something at which conventional
programming is very bad, which is one reason why conventional programs
either run perfectly or stop completely.  @footnote{We need to get
beyond that sort of primitive programming style to produce programs
which keep at least limping along even in the face of unexpected
situations that keep them from running smoothly.  By progressively
eliminating all the Boolean black-and-white cartoon-mentality aspects of
our programming in favor of gray-scale -- or technicolor! -- approaches.
Bloom Filters are one very simple example of moving from black-and-white
to gray-scale programming.}

One can extend this idea further by doing hill-climbing learning on
the hash functions, evaluating statistically which ones are contributing
most and least, and replacing the flops by random mutations of the
successful ones.)

For another example, implement a general notion of graph, together with
a set of dataflow and network operators for conveniently computing
interesting things.  Almost any complex dataset can be cast as a graph,
and there is a rich body of research literature on graph algorithms
which could be applied to them.  (Engineers have their own set of sparse
matrix algorithms, which are really graph algorithms seen from a
different direction.  Linear programming is a reasonably close relative
also.)

Or take off in some completely different direction!  What other life
is there beyond the beaten paths of structs, arrays, objects, hashtables
and lookup trees?  Let's use some imagination!

@c {{{endfold}}}
@c {{{ CVS Support
@c
@node CVS Support, Procedural Data Compression, Experimental Datatypes, Future Plans
@section CVS Support

When using Muq for serious projects with datasets of reasonable size, it
would be very nice if there were support for checking out the Muq dbfiles
from a CVS repository at the start of the run and checking them back in
at the end of the run.

When doing long runs, checking db checkpoints into the CVS repository
might also be handy.

This project could be done purely using wrapper scripts, or purely in
the Muq server C code, or some combination of the two.  It would likely
take an evening or two to get a first prototype working, and a few
months of actually using it to find out what tweaks and feeps are
required to make it comfortable.

I expect one would want to check in uncompressed dbfiles, so as to give
CVS file differencing a reasonable shot at finding commonalities between
successive file generations.


@c {{{endfold}}}
@c {{{ Procedural Data Compression
@c
@node Procedural Data Compression, Automatic Updates, CVS Support, Future Plans
@section Procedural Data Compression

Ok, I admit this is blue-sky research, but it happens to be close to my
heart:

The ultimate form of data compression is when you compile the dataset
into a program which, when executed, produces the original dataset.

It is important not because it is an immediately practical way of
compressing datasets for storage or transmission, but because there is a
deep connection between understanding a dataset and being able to
compress it: Anything you genuinely know about a dataset allows you to
compress it better, and conversely anything that allows you to compress
a dataset better represents real knowledge of some sort about that
dataset.  (And contrawise, if it doesn't help you compress the
dataset, it isn't knowledge, just fanciful projection of your own
thoughts onto the screen of the dataset.)

This in turn is important because it puts the notion of "understanding"
on a firm quantitative footing: Shannon's information theory gives us a
solid theoretical basis for measuring and comparing information content.
In conventional qualitative artificial intelligence hacking, whether and
how much a system learns is very much a matter of subjective handwaving
rather than precise calculation: "Looks smart to me!"  By looking at it
as a matter of data compression, one can say precisely and confidently
things like "This bit of knowledge explains 3.716% of the given dataset".

This in turn means that given a precise, reliable notion of
"understanding", automated searches for additional understanding become
much more feasible than when all evaluation must be done by grad
students waving their hands at each other.

Physics didn't get properly started until the qualitative medieval
methods ("Objects fall faster as they approach the earth because
they are glad to return home!") were replaced by Galileo's and then
Newton's quantitative methods (d==vt + 0.5*at**2).  The field of
AI won't get properly started until @strong{it} adopts appropriate
quantitative methods -- and Shannon's information theory will be to
AI what Cartesian coordinates and algebra were to physics.

I'd love to explore this further, and Muq, as a highly programmable
persistent db of complex datasets, will I think be a productive
environment to do so, once it hits its stride.

There are also a whole slew of technically fascinating programming
issues involved in all this!  For example, how does one best work with
information measured in fractions of a bit?  Conventional programming
just shrugs and sloppily rounds off to some integral number of bits, but
that won't cut it here.  Arithmetic encoding provides one way of
efficiently storing fractional-bit information, but it is far from
constituting a complete fractional-bit programming methodology.  One
quickly winds up rediscovering the virtues of pattern-directed
subroutine invocation (shades of the 50s!!) since explicit invocation
is often prohibitively expensive in the context of procedural data
compression and fractional-bit programming.  @footnote{This all turns out to
tie nicely into procedurally defined graphics worlds, since they
require fierce combinatorial code productivity, and implicit invocation
is even better than the compact explicit invocation of J or Haskell. Alas,
this footnote is too small to contain to contain the full proof! @strong{grin}}

@c {{{endfold}}}
@c {{{ Automatic Updates
@c
@node Automatic Updates, Large Site Load Balancing, Procedural Data Compression, Future Plans
@section Automatic Updates

There are a variety of situations in which it would be nice if Muq
servers could update automatically.

Since Muq is designed to heavily networked with other Muq servers in an
Internet-connected environment and has support for digital signatures
and such, implementing automatic updating should be rather
straightforward.

Some sites run by hackers with infinite time on their hands for
doing manual upgrades and configuration would no doubt disdain
(and disable) any such facility, but for the vast majority of
server sites, the realistic choice is likely to be between
automatic updates and no updates.

Muq server C-code updates are one obvious opportunity for providing such
service: When a new server release is available and sufficiently tested,
there is no reason not to have most sites automatically download,
compile (if needed) and install it.  With a smidgen of design and
implementation intelligence, one should be able to have the existing
server @code{exec()} the new one, so that operation looks continuous to
any user not watching the logs.

Muq library updates are another, equally obvious opportunity.  Small
patches might be simply downloaded as @sc{muf} source and locally
executed.  Larger updates might be downloaded as complete library
dbfiles, to be mounted in place of the current one.

Another nice service to support would be hot-spare mirroring:
If the administrators at a pair of Muq sites agreed, each might
maintain a full mirror of the dbfiles for the other, and be
ready to take over service for the site almost instantly should
the primary site be knocked out by hardware problems or such.

None of these require any great amount of effort, but they are
boring infrastructure sorts of things which I expect will sit
on the project queue until I get around to them.

@c {{{endfold}}}
@c {{{ Large Site Load Balancing
@c
@node Large Site Load Balancing, Parallel Computing, Automatic Updates, Future Plans
@section Large Site Load Balancing

Imagine a Muq site based on dozens to hundreds of interchangable server
boxes.  They might be clustered Beowulf style or @sc{wan}-distributed
over the Internet, it doesn't matter too much from a design perspective.

At login, the least-loaded machine close to the point of login is
selected, the user's dbfiles copied to that machine and mounted
(or perhaps accessed via NFS or such) and the login redirected to
that machine.

Voila, Muq sites scalable almost indefinitely!

All it really requires is good implementation of dbfile dis/mounting,
plus a teensy bit of logic to organize and migrate dbfiles, and of
course some simple mechanism for redirecting logins to a selected
machine.

(A related idea might be implementing support for distributing datasets
over many machines.  Suppose the set of Muq packages gets too large to
store on a single site, or that one wants to operate on sets or numbers
too large to store on one machine.  All it should take to make it work
are a hashing algorithms to distribute data across the available boxes
plus appropriate datastructures and operations to access such
distributed data.)

This one will stay on my personal back burner unless/until I run into
a personal need for such a facility@dots{}

@c {{{endfold}}}
@c {{{ Parallel Computing
@c
@node Parallel Computing, Tainting, Large Site Load Balancing, Future Plans
@section Parallel Computing

A central design goal of Muq is to break down the walls
separating processes and servers, so as to truly make the
Internet a World Without Walls.

The current focus has been on applying this network transparency
to facilitate human interaction, with one to many users per server,
but another way of applying it would be to facilitate use of many
servers by one user.

The many servers could be either a local Beowulf-style cluster,
or could be a WAN-separated set of machines, perhaps donating
spare cycles to some large computation.

Doing this would require writing some infrastructure to implement
a central job queue from which individual servers pull individual
tasks and to which they return their results, along with control
software to display and modify the state of the computation.

Rendering ray-traced animations on the cheap would be one obvious
application of such a Muq-based parallel computing engine.

One can envision a Grassroot Compute Server project in which
Muq servers volunteer idle cycles, and in return get a vote
in which projects get approved for execution, in proportion
to the compute cycles donated.

@c {{{endfold}}}
@c {{{ Tainting
@c
@node Tainting, Ports to Windows Mac Etc, Parallel Computing, Future Plans
@section Tainting

One really nice tweak Larry Wall added to Perl is @strong{tainting}:
A bit associated with each datum recording whether it derives fairly
directly from untrusted sources.

Given this taint bit, the interpreter can then automatically flag many
dangerous operations as errors, such as invoking the host shell
with a tainted string as the command.

In essence, the taint bit takes us a tiny step towards applying modern
compiler type-checking and optimization logic -- usually locked up out
of reach within those blackbox Algolic compilers -- toward general
computational tasks.

Given that Muq is intended to be a heavily interactive environment, it
would be cool to add tainting to the set of tools available to improve
Muq security.

It would be even more cool to experiment with supplying general support
for this sort of computation, so that users can experiment to find other
applications for it without having to get into brutal server hacking.

This would mean providing support for
@itemize @bullet
@item
Allocating and maintaining new per-object bitflags.
@item
Specifying cleanly how primitive Muq operations should propagate
these bits.
@end itemize
Plus of course the gruntwork of writing the infrastructure to make
the bit propagation happen!

Only practical experimentation is likely to reveal whether tainting
is in practice useful only for strings (in which case modifying only
the string types and operations would be the optimal engineering
solution) or is useful for most datatypes (in which case low-level
pervasive support in the Muq virtual machine is the optimal
engineering solution).

This sort of facility has the potential to slow down almost all
Muq computations, so naturally there is a strong burden of proof which needs
to be satisfied before mainstreaming the technology@dots{}


@c {{{endfold}}}
@c {{{ Ports to Windows Mac Etc
@c
@node Ports to Windows Mac Etc, Flashcrowd-Proofing, Tainting, Future Plans
@section Ports to Windows Mac Etc

I've tried to keep the Muq source reasonably portable.  I do not
anticipate personally having the time and motivation to port Muq
to other platforms such as Windows, Mac or BeOS, but I will be
happy to work with other people interested in doing such ports.

@c {{{endfold}}}
@c {{{ Flashcrowd-Proofing
@c
@node Flashcrowd-Proofing, Big Community Support, Ports to Windows Mac Etc, Future Plans
@section Flashcrowd-Proofing

A recurring problem with today's Internet is that if a site
suddenly becomes of widespread interest, the sheer client
load may force it down, or at least prevent most people from
accessing it in a timely fashion.

The result is often that only corporations and rich individuals
can make their voice heard effectively, which is unpleasant.

The solution is, judo-style, to convert the problem into the
solution:  Form the mass of clients into a tree which passes
the required information outward, automatically expanding
service capacity in direct proportion to load, and in the
limit allowing a single 14.4 modem to serve the entire Internet
in real time.

There are some details which need to be done right, to deal
with the probability of a maliciously uncooperative minority
of clients, but the idea looks workable given public-key
signatures to prevent addition of forged packets, and
numbered heartbeat packets to prevent deletion of valid packets.

If this is done well, and incorporated into the Muqnet substrate,
everything built on top of it should automatically be largely
flashcrowd-proof, and anyone with something to say should be
able to address as large an audience as is interested in listening.

@c {{{endfold}}}
@c {{{ Big Community Support
@c
@node Big Community Support, More Numbers, Flashcrowd-Proofing, Future Plans
@section Big Community Support

We could easily wind up with thousands of Muq servers supporting
millions of users, and might possibly wind up with millions of
Muq servers supporting billions of users.

Some basic low-level fixes will need to be made to scale that
high (to start with, @@who shouldn't list all online users, and
@code{.folkBy.nickName[]} shouldn't try to cache all known
users) but I'm thinking here primarily of higher-level software
infrastructure needed to support useful, pleasant, largescale
online communities.

In particular, we need mechanisms to define and operate social groups on
size scales between "me and my friends" and "the entire online
community".

We need to have the non-geographic equivalennt of "The North American
Gardening Club Association" with under it a hierarchy of equivalents to
state and city associations and neighborhood groups, some of which also
belong to other associations -- which is to say, we will really have a
lattice, not a hierarchy.

We need a uniform convention for determining whether person P is
a member of group G, and for making a request of group G ("Hey,
stop your subgroup S from trashing our servers, or we'll block
your access entirely!").

We need a uniform protocol for limiting use of a resource to
defined groups.

We need to let groups internally implement decision-making any way they
wish, from classical mud Maximum Leader dictatorships to radical-left
concensus-based "talk 'til you drop" communes to radical biker "last one
breathing wins" anarchies, and to provide basic pre-built software
support frameworks for the most common models.  Anyone want to code
up Roberts Rules of Order? @strong{grin}

Some of this is just straight-up software design (for example, defining
the membership determination API) some of it is straightforward
coding (implementing that API), some of it is fairly basic
research (is is possible to implement secure, verifiable, decentralized
secret ballots, or are open ballots the only practical alternative?) and
a lot of it is novel social experimentation -- nobody has ever built a
real large-scale community not based ultimately on physical coercion!


@c {{{endfold}}}
@c {{{ More Numbers
@c
@node More Numbers, Native Code, Big Community Support, Future Plans
@section More Numbers

C provides access to the basic arithmetic abilities of the host
computer, which is all one wants from a low-level language, but
real life involves many other kinds of numbers and things used
like numbers, and one would like a high-level system such as
Muq to provide good support for them.

For starters, Muq does not yet have complex numbers, although I
have sketched in the code.  (Anyone know where to find PD code
for trig and exponential functions on complex numbers?)

Quaternions are the unique generalization of complex numbers
and quite useful for such things as representing 3D rotations:
They deserve to be better known and appreciated, and might
be so if more systems like Muq supported them.

Much real computation involves dimensioned numbers:  Meters
per second, dollars, or whatever.  If the dimensions are
explicitly tracked, Muq can automatically
handle addition of yen to dollars or meters to yards,
and can flag as nonsensical addition of yen to yards.  This
isn't hard, but it needs to be done to be useful.

It is only a small step from handling dimensioned numbers to
handling simple symbolic algebra also.  Polynomials, for
example, are combined using the same operators (addition,
multiplcation &tc) as scalar numbers, and there's no reason
Muq users shouldn't be given at least basic algebraic
operations.

Handling arrays as numeric types is a quite similar issue,
and languages like @sc{apl} (and even ForTran) have demonstrated
that supporting this takes much of the drudgery out of working
with arrays by reducing or eliminating the need to be forever
writing explicit looping constructs.  Good virtual machine
support for such operations would simplify implementation on
Muq of languages such a J and would benefit all Muq languages.

The Muq arithmetic primitives should (but as yet do not)
be extensible to work with arbitrary user-defined bytes
via the Muq generic function mechanisms.  This isn't
hard, just needs to be done.

All this is stuff which I somehow doubt anyone but me is going
to be willing and able to implement.

@c {{{endfold}}}
@c {{{ Native Code
@c
@node Native Code, Blackboard Computing, More Numbers, Future Plans
@section Native Code

The benefits of compiling to native code in a system like Muq
are typically grossly overestimated, but there are times when
it can make all the difference in the world.  For example, if
you are writing a realtime sound-processing app and need to
do 256-sample Fast Fourier Transforms lightning-fast.

I'd like to handle this by introducing a NativeFunction
object class into Muq, with the C source code as one
property.  The Muq server can easily invoke @code{gcc}
to compile the function into a @code{.so} file and
then dynamically link it in.

This requires total trust of the person providing the
code, of course, but that is normal when downloading
and executing any binary app anyhow.  The main use
I see for this facility is in standard libraries
maintained by a few trusted people, so public-key
signatures on the distributed code (and a per-server
list of trusted signatures) should be sufficient
to keep the security problems within bounds.

The main point of this mechanism is to allow access
to C-level performance in Muq library code which needs
it without requiring the Muq server as a whole to be
re-linked, stopped, and restarted, as is typically done
on today's servers in such a situation.

A facility allowing one to compile to native code -without-
requiring complete trust would be great, but experience to
date with Java (and Lisp) suggest strongly that in the
end one usually winds up giving up either security (e.g.,
Lisp's compiler safety settings) or else performance
(e.g., Java just insists on doing array bounds checking on each
array access, killing performance in almost every situation
where it matters).

This project is probable a weekend or two, and I doubt anyone
but me is going to do it.

On the code efficiency front, there's a lot to like about what
the Self folks did:  Some good papers on their optimizations
(which they claim brought them to 2-4x the speed of commercial
Smalltalk, and about half the speed of C) are at
@code{http://www.sunlabs.com/research/self}.  The project died
in 1995, alas -- overdosed on elegance?

@c {{{endfold}}}
@c {{{ Blackboard Computing
@c
@node Blackboard Computing, Smart Languages, Native Code, Future Plans
@section Blackboard Computing

Since the function call is the fundamental abstraction mechanism of
modern computing, many computing advances are expressed as changes
to the way we do function calls.

One idea that keeps drifting in and out of fashion is that of
implicit invocation of functions:  Execution of a given function
is triggered not by an explicit call to it in the flow of
computation, but rather by the appearance of some pattern in
the data.

A simple example of pattern-directed invocation is tinyfugue's
triggers, which are executed when a given regular expression
is matched in the current input line.

Modern blackboard systems represent a more sophisticated example,
in which some or all of the state of the program is kept in a
shared datastructure known as a blackboard, which in effect is
inspected by many automated experts, each of which performs the
tasks it is specialized for as the occasion arises, taking the
information it needs from the blackboard and putting the results
back in the blackboard, where they may in turn trigger yet more
computation.  The blackboard becomes a wide, sophisticated
communication channel for a very decentralized (and potentially
distributed) computation.

It would be interesting to consider using some or all of a Muq
db as a blackboard, and to see what we could learn from blackboard
system research:  What server support would be appropriate, and
what would the resulting coding style look like?

This is potentially a very powerful model of computation, and one
very well suited to the Internet in general and Muq in particular.

I am interested in providing generic Muq support for all the
computational styles identified in Design Patterns (a superb book) and
as part of that am contemplating generic Watcher support: This is likely
to be of great help in implementing blackboard-style computations in
Muq.  Is that necessary and sufficient?  Are there other server
mechanisms critically needed?

This is a research level project.

@c {{{endfold}}}
@c {{{ Smart Languages
@c
@node Smart Languages, Resource Market, Blackboard Computing, Future Plans
@section Smart Languages

Typical modern compilers and interpreters aim chiefly for
micro-efficiency: They try to execute each subroutine call as quickly as
possible at runtime.

This means that the code they produce acts very "dumb", since it does
as little reflection as possible about what it is doing.

This is certainly a valid and useful language design approach, but there
are times when one would like alternatives.

Suppose, for example, that you are working (as I often do) with MRI
datasets averages tens of megabytes in size, where each primitive
operation can take seconds or even minutes.

Micro-optimizations shaving a microsecond or two off the call invoking
the primitive will help us in this sort of problem domain.

What @strong{will} help us are macro-optimizations such as noticing that
the same expression has been computed recently and the result is still
available, or restructuring the expression as a whole to execute fewer
primitive calls, or perhaps even compiling custom versions of the
primitives that will run faster in the particular case at hand.

A language optimized to this sort of problem domain can afford to sweat
blood over each expression as it is interpreted, perhaps searching
through the space of algebraically equivalent expressions and applying
a cost function to find the cheapest, or even doing trial runs on
smaller datasets to find out experimentally which approach is fastest.

Language implementations of this sort are rare today because datasets
of this size have been rare:  The most prominent examples to date are
SQL implementations, which sometimes do these sorts of optimizations.

But with personal computer disk capacities climbing into the tens of
gigabytes, gigabit networking becoming common, and multi-CPU chips
starting to ship, the need for such languages is going to become
widespread and routine.

Muq is a good substrate on which to build such languages both because it
can handle gigascale databases, and also because it provides a rich,
flexible environment in which to symbolically manipulate code.

(Obviously, this sort of language support has strong affinities to
symbolic algebra systems.  This is one reason I am interested in
seeing symbolic algebra supported in the Muq environment.)


@c {{{endfold}}}
@c {{{ Resource Market
@c
@node Resource Market, Clarity and Robustness, Smart Languages, Future Plans
@section Resource Market

As we head towards personal computers with thousands of ongoing tasks of
various sorts and millions of data stored in hundreds of gigabytes of
storage, explicitly programming all the resource trade-offs between them
will gradually become impossible: Ultimately only a resource currency
intelligible to them all will be able to mediate all the needed
interactions smoothly and sensibly.

For example, in an Internet-mediated distributed computing context,
it is inevitable that a great deal of local caching will be done,
both of values available elsewhere on the net, and of values which
can be recomputed at some expense.  When we run short of storage,
how do we decide which cached values to discard?

Primitive FIFO schemes (say) can be used, but only at the expense
of wasting a fair amount of compute time and storage space, neither
of which will ever be as plentiful as we would like.

A much more flexible approach is to establish an internal resource
currency -- say, compute cycles -- and then let current and proposed
uses of resources bid against each other for resources in units of this
currency.

This provides a systematic, decentralized way of deciding whether
to uninstall seldom-used libraries in order to free up more cache
space, or perhaps whether to divert compute cycles from sound
playback into archive compression or network bandwidth from
security checks into library download.

Once implemented, it means a computer which never has idle cycles
or storage:  There will always be some available task with a nonzero
value attached to it which can soak up the surplus storage, be it
only prefetching the web pages most likely to be of interest to the
system owner in the near future, and precomputing the results of
queries likely to be made shortly.

Link a number of such systems together by establishing exchange rates,
and you have an online compute economy of machines autonomously buying
and selling resources to each other according to fluctuating local
surpluses: A virtual bazaar of machines muttering "I've got a midnight
deadline and need render cycles BAD here -- who's selling?" vs "I'm just
sitting chugging on RC-160 tonight -- what's a cycle worth to you?" to
each other.  Perhaps eventually the compute currencies become
interconvertable with dollars and Euros?  All values are tradable in
the end, given sufficient volume and interest.

Someone needs to devote some serious time to prototyping such a system
and accumulating practical experience with it before we can think of
mainstreaming it, and we don't have all that long before we'll need a
maintreamable implementation of it.  Anyone want to take this one on?

@c {{{endfold}}}
@c {{{ Clarity and Robustness
@c
@node Clarity and Robustness, Future Plans Wrapup, Resource Market, Future Plans
@section Clarity and Robustness

With a scattering of honorable exceptions, the overwhelming mass of
contemporary software is mysterious and fragile:  Almost any unexpected
event or circumstance results in complete failure, and in general there
is no systematic way of discovering what a program is doing or why it
has failed to perform as sexpected.

Dealing with the unexpected and helping the user understand the state
and problems of the computation are at best dealt with as minor
afterthoughs, and typically simply not dealt with at all:  The
standard explanation for failure is basically "Segment violation".

This is no longer necessary, and is rapidly ceasing to become tolerable.

We are rapidly entering an era where everyday users perform
network-driven computations involving dozens of machines and millions of
lines of code.  Completey failure must become dramatically less
frequent, and when automated success is not possible, the software must
be able to involve the user constructively in resolving the problem.

Muq is an excellent platform on which to explore these requirements and work
out programming methologies for meeting them:

@itemize @bullet
@item
Its design is focussed on precisely the sort of multi-user multi-machine
networked applications which require improved failure handlines.
@item
The Muq event system is based on the CommonLisp exception handling
system, arguably the most advanced such mechanism yet standardized:
It allows multiple strategies for reaching a goal -- some of which
may involve interaction with the user -- to be registered
in modular fashion, and also registration of second-order strategies
for for picking the next first-order strategy to try.
@item
The Muq event system publishes a high-level view of the computation
and options for redirecting it in a form suitable for browsing by
the end-user.
@end itemize

With a little thought and work, we can have a software environment in
which short-lived computations are robust and unmysterious, and in
which long-lived computations can be actively steered by the user as
easily and naturally as a boat or car.

@c {{{endfold}}}
@c {{{ Future Plans Wrapup
@c
@node Future Plans Wrapup, Function Index, Clarity and Robustness, Future Plans
@section Future Plans Wrapup

NB: I also have, at any given time, a list of lower-level projects in
@code{muq/c/TODO}, but those are probably too mundane to interest
anyone else, even should they prove able to decipherable it.

The critical Muq projects (say, for 2000, roughly) are to my mind:
@itemize @bullet
@item
GUI
@item
More Transparent Networking
@item
Lisp Compiler
@item
C-like Compiler
@item
Arrays and Vectors
@item
Multimedia, meaning mostly 3D Graphics
@end itemize

That is a pretty full plate -- each of those can easily eat a month
of sparetime hacking -- so everything else on the list is likely to
have to wait either for 2001 or later@dots{} or for someone else to
pick up the slack.  See on the list any Muq coding itches you'd like to
scratch?  Dive in!

Do you have other projects you'd like to do with Muq?  Let me know!
@code{cynbe@@muq.org}.  There are many directions I'd be delighted to
see explored, and if yours is one of them, I may be able to work with
you on it.  I'm particularly interested in education and online
collaboration.  Even if I can't actively help immediately, it is
useful to know what people are actually doing with Muq when I
plan future developments.

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:

