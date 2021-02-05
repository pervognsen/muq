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
@c Everything! :)
@c =============================================

@node Muq FAQ, Muq FAQ Overview, Top, Top
@chapter Muq FAQ

@menu
* Muq FAQ Overview::
* Muq FAQ Proper::
* Muq FAQ Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Muq FAQ Overview
@c
@node Muq FAQ Overview, Muq FAQ Proper, Muq FAQ, Muq FAQ
@section Muq FAQ

At the time of writing, Muq is five months short of its first beta
release, so this FAQ is necessarily a bit sketchy: It is hard for me
as author of the system to anticipate what other people will ask about
it.

@c {{{endfold}}}
@c {{{ Muq FAQ Proper
@c
@node Muq FAQ Proper, Muq FAQ Wrapup, Muq FAQ Overview, Muq FAQ
@section Muq FAQ

@itemize @bullet
@item @strong{Wouldn't Muq @sc{muf} run ten times faster if it compiled
to native code instead of bytecode?}

It would for a few things, such as simple integer loops or floating point
operations on arrays.

But typical real-world @sc{muf} code is dominated by string operations, network
delays and such:  Compiling to native code would make little if any noticable
difference.  (What it @code{would do} would be to make compiling slower and compiled
code a portability problem.)

Reducing latency by such things as interleaving bignum arithmetic with other
operations and doing disk I/O in a background process would do much more
to make the system feel fast and responsive.


@item
@strong{Why does Muq use a custom @code{.db} format and @code{vm.t} code module
instead of something standard and well-tested like gdbm?}

That's a lot like asking why Formula One racers use tuned custom engines
instead of standard, well-tested Mac truck diesel engines!  I'm sure any
Formula One racing team is good enough to get a racer working using a
Mac truck engine.  But the result would be an engineering monstrosity
equally useless for racing and trucking.

Muq is a persistent programming system, and the virtual store used permeates
every aspect of the internal server code.  Standard packages like gdbm were
were simply not designed with Muq's intricate requirements in mind.

For example, when the @code{vm.t} code moves the currently executing
@code{compiledFunction} during ram cache compaction, it must update
the Muq bytecode program counter to prevent an interpreter crash.
Multiply that by dozens of such interactions, and you begin to get the
idea.

Basing Muq on something like gdbm would make it half as fast when
doing disk I/O, would perhaps double the size of the db files, and
would make much of the internal server code trickier, uglier and less
reliable.

Since gdbm and kin aren't designed with Muq in mind, there would be a
good chance that each new release would break Muq in unforseen ways.

I could make Muq work with the heap stored in gdbm.  But I prefer
having the critical core parts of the Muq server tightly optimized to
work together cleanly, reliably and efficiently.

This doesn't mean that a Muq interface to gdbm wouldn't be a cool idea!

Keeping the Muq heap in gdbm would be awful, but there is nothing
wrong with keeping in gdbm the sort of databases for which it was
designed, nor with accessing them from Muq and sharing them with other
applications designed to use them.



@item
@strong{I've heard Muq has everything but the kitchen sink.}

A base canard! Muq has had a fully functional, @sc{posix}-compliant
kitchenSinks primitive since version -2.4, 1994Mar26.

@end itemize

@c {{{endfold}}}
@c {{{ Muq FAQ Wrapup
@c
@node Muq FAQ Wrapup, Function Index, Muq FAQ Proper, Muq FAQ
@section Muq FAQ Wrapup

Comments?  Correnctions?  Suggestions?  Additional questions?  I'd be happy to hear
from you: @code{cynbe@@muq.org}.


@c {{{endfold}}}
@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
