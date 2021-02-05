@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node The Muq Vision, Why Muq?, Top, Top
@unnumbered The Muq Vision
@cindex The Muq Vision
@cindex Vision, The Muq

In this section, I want to explain why I care enough about Muq to put
a decade of my spare time into writing it and then giving it away
free. Skip directly to the next section if you just want the
technogeek stuff.

I am fascinated by the moving frontier where computing technology
meets mainstream society:  Where it stops being toys for geeks and
becomes tools for tinkers and tailors -- and tots.

I've been involved with online communities since the late seventies,
and I'm always amazed by the resonance they strike in their users.

I love the synergy when online communities bring together communities
as diverse as anti-technology punk bassists and career books and
motherhood libraries.

I enjoy seeing a Volkswagen mechanic teach himself to
program just so he can help maintain an online community.

I'm delighted by the creativity random non-geek people display when
they are given a chance to build cooperatively in a software-mediated
environment:  Things get attempted and often accomplished that were
utterly unanticipated by the creators of the software substrate.

But I'm pained when I see such attempts failing primarily because
the software substrate is grossly inadequate to the builder's vision.
I'm embarassed on behalf of the programmer who provided the inadequate
tools, and I'm frustrated on behalf of the community thus robbed of what
might have been.

Eventually, I cannot stand it any more, and I take a stab at providing
a better software substrate.

In the early '70s, one cutting edge was computer BBS systems.  (I was
on the Internet too, but it was purely geekly back then:  Local
modem driven computer BBS systems were what real people could use.)
I wound up writing the public-domain Citadel BBS program, which twenty
years later is still going strong, having been ported to just about
every operating system and machine on the planet, modified creatively
by hundreds of geeks (many of whom seem to have learned programming
primarily to do so), linked into continental-size networks and used
by millions of people, many of whom seem fondly loyal to Citadel
long after it has objectively become technologically obsolescent.
There are Citadel implementations out there without a single line
of my code remaining, but the authors are still proud to call them
Citadels:  Some sort of larger sense of community has emerged.
Wonderful!

In the early '90s, one cutting edge was muds, "Multi-User
Dungeons".  (When academe and industry moved in, respectability
transformed them into "Multi-User Dimensions.")  Where BBSes
were limited by phone charges to city scale, Internet-linked
muds allowed communities to form on the continental scale.
Beyond that, muds allowed much more scope for creativity:
Users could create virtual rooms, mazes and puzzles: Unicorns
which shied away when approached, mini-applications to speed
travel and communication, gifts, quests -- endless profusion!

Muq is fundamentally my reaction to that experience:  A follow-on
to the tinyMUDs and tinyMUSHes and MOOs intended to explore the
visions and vistas which they have opened up, while enabling these
communities to explore beyond the limits set by these previous
tools.

Muq supports bigger databases, so users can create more works of
wonder before hitting the system capacity limit.

Muq supports distributed operation, so community size is no longer
limited by the capacity of any single machine or cluster (or budget!),
but only by the aggregate computing power available to the community
members as a whole.  And so that the continued existence of the
community need no longer be hostage to any single provider, or any
handful of members.

Muq supports better security, so community members will less often
have expectations of privacy rudely exploded.

Muq supports improved reliability, so community activities are
less often disrupted by outages.  (Distributed operation also
means that a failure normally takes out a small part of the
community space, rather than the whole kit and kaboodle.)

Muq supports a variety of more sophisticated programming facilities,
so both the dedicated geeks and the self-taught mechanics can
create more freely.

I envision Muq-based communities where nobody has creative projects
frustrated by trivial limits on hardware resource consumptions,
because any member can add another machine to the resource base
at will.

I envision Muq-based communities where nobody has creative projects
frustrated for lack of creation rights, because the substrate is
secure and distributed enough that everyone can have creation rights
sufficient unto their vision.

I envision Muq-based communities where new wonders are built because
the tools are markedly less inadequate to the vision.  (I hope our
tools never cease to be inadequate to our visions, for that could only
mean that we had forgotten how to dream.)

I envision Muq-based communities so broad-based that they are
hostage to no individual or corporation:  Communities that are
immortal as long as any pair of members continue to value them.

I've spent years building Muq:  Now go out and amaze me! :)



@node Why Muq?, Muq Status, The Muq Vision, Top
@unnumbered Why Muq?
@cindex Features of Muq
@cindex Muq, Features
@cindex Why Muq?


@quotation
"Longer, lower, wider, faster than anything else in its price class!"

-- Excerpt from early 1970s car advertisement.
@end quotation

In a world with literally thousands of software platforms, what makes Muq
special?  When is Muq an appropriate design choice?

Muq goes several design generations beyond (say) MOO or Java in providing support
for applications characterized by these five requirements:

@itemize @bullet

@item
Multi-user: The application involves close interaction between many users.

@item
Persistent state:  The application runs for years rather than hours.

@item
Complex data:  The application dataset doesn't neatly reduce to tables.

@item
Complex code:  The application requires full-strength programming
languages and per-user customizibility.

@item
Distributed:  The application requires coordination of state, code and
users distributed over many network-linked machines.
@end itemize

If your application fits this profile, picking Muq as your platform
may reduce your development time by an order of magnitude or more
while also improving the reliability and robustness of your
delivered application.

Traditional software platforms such as C or Java provide very little
support for any of the above requirements, but the combination is
becoming increasingly common in the Internet age.

To support these five requirements well, especially in conjunction,
a software platform must really have been designed with them in
mind from the very beginning:  The requirements affect thousands
of design decisions throughout the implementation.

Muq was so designed, building on many years of experience using,
maintaining, administering and writing online communities and
their software.

Here are some of the specific facilities Muq provides which support
the target application space:

@itemize @bullet

@item
Binary disk-based persistent state:  All state information is
automatically persistent, automatically backed up regularly,
and data which haven't been used recently are automatically
swapped to disk to conserve physical ram.  Up to forty percent
of the code for many applications is devoted to implementing
this functionality:  In the Muq platform, that part is done
and debugged before you start.

@item
Well-factored state:  The state information is divided up
logically among different host files.  For example, each standard Muq
system library has its own file, as does each user.  This makes it
easy to install updated system libraries, easy to roll back a user's
state without rolling back the entire database, and easy to move
a user from one server to another.  Competing platforms usually
roll all the state into one unmanageable blob:  In a production
environment, this becomes a nightmare the first time a user
complains, "I accidentally deleted all my stuff, can you
restore it from backup for me?".

@item
Multiple application languages:  Experience has shown that there
is no such thing as a one-size-fits-all programming language:
Different users need different languages, and a large multi-user
application has to recognize this.  Most competing platforms
force all users and programmers to use a single syntax:  Muq
is specifically designed to support multiple programming syntaxes,
and in fact allows unprivileged users to implement new programming
syntaxes without compromising system reliability or security,
thanks to a core backend generator which guarantees to
produce only valid compiledFunction objects.

@item
Full-featured application languages:  Competing platforms often have
application languages added as an afterthought, grown without design
from some primitive macro language.  You are often stuck trying to
build real applications in a toy language.  Muq's application
languages were designed to be fully modern and full featured from
the very beginning, and include a full complement of modern
data and control structures and facilities, up to and including
object oriented programming with multiple inheritance.

@item
Automated storage management ("garbage collection"):  Discarded
datastructures are automatically detected and recycled.  Typical
C/C++ problems of memory leaks, hanging pointers and clobbered
memory are inherently impossible.  This alone can cut your
debugging time in half on many projects.

@item
Multi-user design: Every datum is owned by some specific user,
can by default only be modified by that user, and can be hidden
from other users.  Every operation is designed to respect these
(and many additional) security concerns.  Competing platforms
typically lack such designed-in security walls, and retrofitting
them at the application code level can be problematic at best.

@item
Transparent distributed operation support: Muq's muqnet support
merges selected Muq server processes into a single logical computer.
The processes can be on the same machine or on opposite sides of the
Internet.  All threads can communicate with each other in exactly the
same way regardless of whether they are local or remote.  All threads
can access all data in exactly the same way regardless of whether they are
local or remote.  (Naturally, security safeguards apply:  Private data
is protected from access by other users, whether it is local or remote.)

@item
Painstaking attention to security and privacy concerns throughout
the design and implementation.  For example:
@itemize @bullet
@item
Users are automatically and transparently assigned public/private keypairs.
@item
Private keys are stored in a special datatype unreadable even to the user
owning it.
@item
Muqnet traffic is automatically and transparently 256-bit blowfish encrypted.
@item
Muq tells the recipient of each inter-user call who the sender was.  This
information is validated by internal server logic for intra-server calls
and by public key techniques for inter-server calls, reducing spoofing
problems by a large factor.
@end itemize
This support can by itself cut the implementation time for a distributed
application in half or more.

@item
Migration support:  In a distributed application with perhaps thousands
of servers spread across the internet and state persisting for years,
what happens when a server must move from one IP address to another?
Muqnet logic handles this completely transparently and automatically.

@item
Scalability: Muq and Muqnet are designed to be as scalable and
reliable as realistically possible.  In particular, muqnet needs no
central node, which might constitute a potential single point of
failure capable of bringing the entire system down.  Communication is
peer-to-peer with no inherently distinguished server nodes.  (There
are of course be some muqnet nodes pragmatically known to be stable
and secure, and others which are online from dynamic IP addresses on
laptops or public workstations, and they are in consequence actually
used differently.)

@item
Robustness:  For example, the underlying Muq C-coded server is designed by
the "mechanism not policy" rule:  Customization can typically be done
without touching the C code, which vastly reduces the probability of
introducing nasty crashing bugs during development.  Competing platforms
typically put most policy decisions in the C server code, making constant
tweaking of it a requirement and constant crashes a fact of life.

@item
Careful attention to space efficiency issues throughout.  For example, Java
requires over 100 heap bytes to store the string "bloated";  Muq takes
no heap bytes at all -- it is stored as an immediate value within a Muq
64-bit variable.  The state of  multi-user applications is dominated
by short strings, so this alone can reduce your application space
consumption by a factor of ten.  Since Muq swaps
unused objects to disk while Java keeps them in memory, the practical
ram consumption ratio may run as high as one hundred.

@item
Similar attention to time efficiency issues.  For example, Muq has
less than 1/3 the instruction dispatch overhead of most tinyMU*
servers.

@item
Portable:  Muq produces exactly the same results on all machines.
(Java, for example, produces different results on 32-bit vs 64-bit
machines.)  Muq db files are designed to be portable between all
supported machines without any explicit conversion needed.  (For
speed, the db is internally big-endian on big-endian machines and
little-endian on little-endian machines: This allows the dbfiles
to be memory-mapped and accessed at high speed.  But no explicit
user-invoked conversion is used.)

@item 
Muq runs 64-bit throughout, on all machines: This in an
investment in the future, since 32-bit era is clearly coming to an
end.  Running 64-bit on all platforms (including x86) costs about a
15% slowdown on compute-intensive tasks, but means that your
applications are guaranteed to port to next-generation 64-bit machines
completely painlessly when the time comes.  (Dbs developed on 32-bit
platforms such as x86 Java may be nightmares to port to 64-bit
platforms.)  You can also run Muq dbs indifferently on today's Intel,
Sparc and MIPS platforms without porting issues.

@item
Muq addresses such issues as what happens to instances of a
class when it is redefined.  This is a crucial issue in a
production multi-user application with state intended to
persist for years, but is completely ignored by platforms
such as Java or C++, which expect all objects to vanish
at the end of a program run of a few hours.  Coding around
this problem on a platform not designed to deal with it may
easily add months to your application development.
@end itemize

Muq is a new platform designed for the needs of a new millenium, with
sufficient design hooks in place to keep it at the leading edge for
years to come.  Muq represents the leading edge of the future:
Competing platforms represent the receding edge of the past.

@c
@node Muq Status, Installing Muq, Why Muq?, Top
@unnumbered Muq Status
@cindex Implementation status of Muq
@cindex Muq, implementation status
@cindex Stability of Muq
@cindex Muq stability
@cindex Reliability of Muq
@cindex Muq reliability
@cindex Completeness of Muq
@cindex Muq completeness

Muq is at version -1.44.0 as of this (1999Jul30) writing.
Muq version -1.44.0 is a barely-pre-beta release.
The first beta release (version 0.0.0) will be on
2000Dec29, marking exactly seven years of alpha
development.  The latest public release of source
code is always available at
@code{ftp.cistron.nl/pub/people/cynbe/}, the latest
docs are always on the web at
@code{http://muq.org/~cynbe/muq/muq.html},
and
preformatted tarball versions of
these manuals are available in @sc{scii}, @sc{html}, @sc{nfo},
@sc{dvi} and @sc{ps} from @code{ftp://muq.org/pub/muq/}.

There are currently no publicly accessible Internet sites
running Muq servers.

Muq has
been in development for seven years.  Many
needed tutorial documents have yet to be written, but the
specification is still nearly frozen, and I don't remember
the last crashing bug reported by a user.  Many security
checks and several major planned Muq capabilities are
still unimplemented, but beta-testing is currently really
only waiting for a complete freeze of the db binary format,
so that upgrades won't break running dbs.

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
