@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@c
@node Muq Events, Muq Event System Motivation, Muq Object Efficiency Considerations, Top
@chapter Muq Events

@menu
* Muq Event System Motivation::
* Muq Event System Overview::
* Handlers::
* Signaling Events::
* Restarts::
* Predefined Events::
* Muq Event System Wrapup::
@end menu
@c -*-texinfo-*-

@c
@node Muq Event System Motivation, Muq Event System Overview, Muq Events, Muq Events
@section Muq Events Motivation
@cindex Events in Muq, Motivation
@cindex Motivation, Muq events

This section contains no technical details.  Impatient
readers may wish to skip ahead.

The power of a programming notation derives fundamentally
from the ability to flexibly combine many small chunks of
code to produce a number of potential computations which is
exponential in the length of the program.

The tools which allow us to do this are the @dfn{abstraction
mechanisms} provided by that notation, and the character of
a given programming notation is largely determined by its
abstraction mechanisms.

There are not many fundamentally different abstraction
mechanisms in common use:  It is worth reviewing them
before explaining why we need another one.

The simplest form of computation consists of a fixed
sequence of operations on some constant set of operands.
When we punch up "93 sin" on our hand calculator, we are
performing this sort of computation.  Useful, but terribly
limited.  We rarely bother writing down such computations
for later use.

The simplest abstraction mechanism consists of introducing
@dfn{variables} into our programming notation.  This lets us
write down a complex expression and then evaluate it
repeatedly for different values of the variables.  ``How
much money will I make if interest rates stay at five
percent?  How much at five and a half.?''

The next abstraction mechanism consists of the @dfn{conditional}
statement:  An @code{if-then-else} of some sort that allows us
to perform different computations for different values of
selected variables.  Suddenly it become possible to write
vastly more flexible programs!

The next abstraction mechanism usually introduced consists of
the @dfn{procedure}:  A subcomputation which can be defined
once, named, and then used repeatedly.  This lets us in
essence define a new language as we go along, specialized to
our particular needs.  Variables, conditionals and procedures
together provide us with a universal programming notation which
in principle allows us to describe any possible computation.
Further abstractions are conveniences rather than necessities,
which is why they took much longer to get established.

Object-oriented programming was the next major abstraction
mechanism to achieve mainstream acceptance.  The heart of
object-oriented programming consists of mechanisms to
facilitate the definition and naming of new datastructures
together with operations on them -- much as procedures let
us define and name new codestructures -- and the
construction of code which automatically invokes the
operations appropriate to the datastructure in use: To
create code that within certain limits doesn't care what kinds
of data it operates on.  Conventional procedural code is
written in terms of fixed, prespecified procedures and
datastructures, but object-oriented code lets us write code
with variables representing procedures and datastructures.
Once upon a time, this would have been called
``meta-programming'' @dots{}

(@dfn{Functional programming} provides even more powerful
abstraction mechanisms, but is not yet part of mainstream
programming practice, so we will ignore it for now.)

Why do we need yet another abstraction mechanism?

Fundamentally, to deal with the problem of very large
programs.

You will have noted that each level of abstraction we
have discussed has enabled the construction of programs
ten or a hundred times larger than before:

@itemize @bullet
@item
@emph{Tiny} computations of one to perhaps
a hundred lines may often be reasonably expressed as
constant expressions.

@item
@emph{Small} computations of ten to a thousand lines tend to
need variables, and usually conditionals, to deal with
the complexity of the problem.

@item
@emph{Medium} computations of a hundred to ten thousand
lines tend to need procedures as well, to hide the
complexity in named units.

@item
@emph{Large} computations of a thousand to a hundred thousand
lines tend to need the additional facilities of
object-oriented programming.  These are the largest
computations which we currently know how to handle
effectively: Computations which need millions or tens of
millions of lines in their description fail with monotonous
regularity.

@end itemize

But we are entering an era of @emph{very large}
computations involving millions to billions of
lines of code.  The entire Internet is becoming an
integrated computational engine: A user sitting at
a WWWeb browser may with a few mouseclicks invoke
computations on machines scattered all over the
planet.  @sc{corba} (the Common Object Request
Broker Architecture) is extending the
object-oriented programming paradigm to the
Internet scale, allowing intricate computations
spanning the net.

Each order-of-magnitude change in computation scale has in
the past introduced qualitatively new problems requiring
qualitatively new abstraction mechanisms: We may be
reasonably confident that this trend will continue as we
proceed to these even larger computations.

One particular problem introduced by netscale
computations is that of @emph{reliability}.  We
may at least entertain fantasies of proving
@emph{large} computations correct, eliminating the
possibility of surprise failures.

@emph{There is no possibility of proving @emph{very large}
computations correct}, even in principle, because the work
required in such proofs is exponential in the size of the
program, and simply isn't possible in the
@emph{very large}
regime, even if programs in this size range ever remained
unchanged long enough for such a proof to be attempted --
which they of course do not, Internet computational
facilities being constantly updated in uncoordinated and
decentralized fashion.

Thus, we must accept that the path of @emph{very large}
computations will always be uncertain and exploratory,
involving negotiations between unrelated and mismatched
chunks of code, and not infrequently consultation with the
user.

This class of problem is elegantly handled by the CommonLisp
Condition System, on which the Muq event system is
closely modelled.  The event system provides a mechanism
by which code may:

@itemize @bullet
@item
Publish the availability of different continuations for the
computation in progress, in both human and machine
intelligible terms.

@item
Publish the availability of expertise for making
particular kinds of continuation decisions.

@item
Search out the above-published kinds of information.

@item
Announce the presence of a particular kind of
continuation decision -- a @emph{event} --
requiring these mechanisms.

@item
Invoke an appropriate continuation of the computation,
having optionally consulted the user to pick it.
@end itemize


@c
@node Muq Event System Overview, Handlers, Muq Event System Motivation, Muq Events
@section Muq Event System Overview
@findex setjmp
@cindex Overview of Muq event system
@cindex Overview of Muq event system

The Muq event system is a general facility for
steering complex computations, with or without
explicit user intervention.

It provides the ability to signal and handle
hardware and software faults either entirely in
software or with the active participation of the
user, hence subsumes the role of unix signals and
signal handlers and the debugger core, but it
should not be thought of primarily as a
specialized mechanism for catching errors, but
rather as a powerful, general control mechanism
for controlling complex programs and building
sophisticated user interfaces.

The event system is based on a three-phase model
of the problem resolution process:

@enumerate
@item
Describing the problem.
@item
Selecting the best available way of continuing the
computation.
@item
Executing the selected continuation.
@end enumerate

Here is a typical sequence of events when using
the event system.  We suppose that part of an
application is attempting to access a netserver as
part of performing some task for a user:

@enumerate
@item
The application registers several @emph{restarts}
for continuation options such as
@itemize @bullet
@item
Abort the task.
@item
Retry the server.
@item
Try a mirror server.
@item
Try a different kind of server.
@end itemize

@item
The application registers several @emph{handlers}
for problems which might arise during this
server-access attempt, such as
@itemize @bullet
@item
Server not responding.
@item
Network is down.
@item
Server has started charging a dollar a byte.
@end itemize
Some of these handlers may operate entirely
invisibly, such as ones that retry or try another
server, and some might wish to query the user,
such one deciding whether to pay a dollar a byte.

@item
The application initiates the server access
attempt.

@item
A problem is detected.  A description of the
problem is constructed, and the event system
activated to resolve it.

@item
The handler registry is searched for handlers
claiming to be able to solve this sort of
problem, and an appropriate one selected.

@item
The handler searches the restart registry
to see what its current options are, consults
the problem description, possibly consults
the user, and finally invokes a particular
restart.

@item
The restart does something expected to resolve the
problem, often a @code{goto} to some appropriate
tag, aborting part of the computation and
continuing along a backup path, but perhaps merely
(for example) changing some parameters in the network interface.
@end enumerate

This problem resolution model leads in a natural
way to requirements for the following sets of
tools:

@itemize @bullet
@item
Tools to announce available ways of continuing the
computation -- @emph{restarts}.  Each Muq job
maintains a registry of restarts available at any
given point in time, the contents fluctuating as
the computation proceeds.

@item
Tools to announce available ways of picking an
appropriate restart under various
events -- @emph{handlers}.  Each
handler is a domain expert for some class
of problem.  Each Muq job maintains a registry of
handlers available at any given point in
time, the contents fluctuating as the computation
proceeds.

@item
Tools to search the above two registries and to
activate selections from them.

@item
Tools to describe an existing problem and
trigger the problem resolution process.
@end itemize

The Muq event system provides the following
tools to meet these requirements:

@table @strong
@item Describing problems
The class @code{Event} is provided.  Each instance
of this class represents a particular kind of
problem, and inheritance links between these
instances describe the relationships between
these kinds of problems.  Thus, "diskWriteError"
may inherit from "diskError" which might inherit
from "ioError" which might inherit from "error".
This inheritance lattice helps the programmer
precisely describe the set of problems which a
particular handler understands.

The functions @code{signal}, @code{warn},
@code{error} and @code{cerror} are provided for
explicitly invoking the event system on a
particular event.  (The server also implicitly
invokes these when it encounters problems.)

@item Registering restarts
The @code{withRestartDo@{ @dots{} @}} construct
allows execution of a block of code with a given
restart active.

@item Registering handlers
The @code{withHandlersDo@{ @dots{} @}} construct
allows execution of a block of code with a given
set of handlers active.

@item Searching the handler registry
This is done internally by @code{signal} and kin,
which also server to select and invoke handlers.

@item Searching the restart registry
The @code{findRestart} function may be used to
find a single restart.  The @code{computeRestarts[}
function may be used to return some or all active
restarts.  The @code{invokeRestart} operator
allows invocation of any selected restart.
@end table

One concrete example is often worth any amount of
abstract hand-waving.  Here's a simple example which
exercises all the basic event system functions.
Even without having been formally introduced to all
the functions used, the general idea may come though:

@example
makeEvent --> _myEvent

withTag my-tag do@{
    [   :function :: 'my-tag goto ;
        :name     'my-restart
    | ]withRestartDo@{
        [   _myEvent
            ::  @{ [] -> [] ! @}
                'my-restart invokeRestart
            ;
        | ]withHandlerDo@{
            [ :event _myEvent | ]signal
    @}   @}

    t if
        nil --> _looksGood
    else
    my-tag
        t   --> _looksGood
    fi
@}
@end example

The above example is a fairly complete exercise of the
fundamental three layers (tags, restarts, handlers) of the
event system:

@itemize @bullet
@item
It creates a new event @code{_myEvent} which
we may send in handler signals, invoking only handlers
watching for it.

@item
It establishes a tag named @code{my-tag} in the current function
to which other functions may jump.

@item
It establishes a restart named @code{'my-restart} which
jumps to @code{my-tag}.  Other functions may find and
invoke this restart.

@item
It establishes a handler for @code{_myEvent} signals
which invokes @code{'my-restart}.

@item
It sends a signal of type @code{_myEvent}, triggering
all the above machinery, so that execution resumes at
@code{my-tag}:  On exit, @code{_looksGood} will be @code{t}.
@end itemize

We now discuss these tools in more detail.

@c
@node Handlers, Signaling Events, Muq Event System Overview, Muq Events
@section Handlers
@cindex Handlers

A handler function accepts a block of keywordValue
pairs.  The keyword @code{:event} must be present,
and the matching value must be a event.

A handler that returns is understood to have declined
handling the event.  It should leave its argument block
untouched.  A handler that resolves the event normally
signals this by invoking an appropriate restart.

Non-serious events, such as window resizing,
don't require resolution, and handlers for them
may simply return after taking whatever action
they consider appropriate, perhaps none.

For syntax to establish handlers in @sc{muf},
see @ref{withHandlersDo}.

@c
@node Signaling Events, error fn, Handlers, Muq Events
@section Signalling Events

@menu
* error fn::
* cerror::
* signal fn::
@end menu

@c
@node error fn, cerror, Signaling Events, Signaling Events
@section error fn
@defun ]error @{ [] -> @@ @}
@display
@exdent File: job.t
@exdent Status: alpha
@end display

The @code{]error} operator accepts a designation
of a event, and invokes the appropriate
handlers.  If all of them return,
@code{]invokeDebugger} is executed: The
@code{]error} operator never returns to the
caller.

The parameter block consists of keywordValue
pairs.  The keyword @code{:event} must be
present:  The corresponding value must be a
@code{event}.  Other keywordValue pairs
may be supplied, depending on the event:
Unrecognized ones will be silently ignored.

@end defun


@c
@node cerror, signal fn, error fn, Signaling Events
@section cerror
@defun ]cerror @{ [] -> @}
@display
@exdent File: job.t
@exdent Status: alpha
@end display

The @code{]cerror} (``continuable error'')
operator is identical to the @code{]error}
operator except that a @code{continue}
restart is established by which handlers
or the debugger may effectively return
from the call.

@end defun


@c
@node signal fn, Restarts, cerror, Signaling Events
@section signal
@defun ]signal @{ [] -> @}
@display
@exdent File: job.t
@exdent Status: alpha
@end display

The @code{]signal} operator accepts a designation
of a event, and invokes the appropriate
handlers.  If all of them return, @code{]signal}
itself returns.

@xref{signal}.

@end defun


@c
@node Restarts, Predefined Events, signal fn, Muq Events
@section Restarts
@cindex Restarts

Muq restarts are implemented as dynamic entities
that live on the call stack: They cannot be
directly addressed, although values representing
them are made available.

A Muq restart has the following properties:

@table @strong
@item :name
A symbol by which code may invoke the restart.  A
@sc{nil} name designates an anonymous restart.

@item :function @{ [] -> @}
The restart function proper.  This is what does
any actual useful work.

@item :testFunction @{ [event] -> boolean @}
If not @sc{nil}, this is a function which
accepts a event and returns @sc{nil} if the
restart may not be appropriately used to resolve
this event, else non-@sc{nil}.

@item :interactive-function @{ -> [] @}
A function which prompts the user for all
arguments needed by the restart, and returns
them in a block.  This is used when invoking
the restart interactively from the ``debugger''.

@item :reportFunction @{ stream -> @}
Prints on the given stream a description of
what the restart will do if invoked.  Used
by the debugger when listing available options
for the user.
@end table

See @ref{withRestartDo} for the @sc{muf} syntax
for establishing a restart.

@c
@node Predefined Events, event, Restarts, Muq Events
@section Predefined Events
@findex setjmp
@cindex Predefined Events
@cindex Events, predefined

The following event lattice is based on that
given in Common Lisp the Language, 2nd Ed.  The
server-predefined events are kept in @file{.event}
in the Muq db.

@example
event
    simpleEvent
    printJobs
    warning
        simpleWarning (also a child of simpleEvent)
        brokenPipeWarning
        readFromDeadStreamWarning
        writeToDeadStreamWarning
    seriousEvent
        abort
        debug
        kill
        storageEvent
        error
            serverError
            simpleError (also a child of simpleEvent)
            arithmeticError
                divisionByZero
                floatingPointOverflow
                floatingPointUnderflow
            cellError
                unboundVariable
                undefinedFunction
            controlError
            fileError
            packageError
            programError
            streamError
                endOfFile
            typeError
                simpleTypeError (also a child of simpleEvent)
@end example

@menu
* event::
* warning::
* event printJobs::
* seriousEvent::
* event abort::
* event debug::
* event kill::
* event error::
* serverError::
* simpleEvent::
* simpleWarning::
* simpleError::
* storageEvent::
* typeError::
* simpleTypeError::
* programError::
* controlError::
* packageError::
* streamError::
* endOfFile::
* fileError::
* cellError::
* unboundVariable::
* undefinedFunction::
* arithmeticError::
* divisionByZero::
* floatingPointOverflow::
* floatingPointUnderflow::
* brokenPipeWarning::
* readFromDeadStreamWarning::
* writeToDeadStreamWarning::
@end menu

@c
@node event, warning, Predefined Events, Predefined Events
@subsection event
@cindex event

The root event type, from which all others inherit.

@menu
@end menu

@c
@node warning, event printJobs, event, Predefined Events
@subsection warning
@cindex warning

The root warning event type, from which all
other warnings inherit.

@c
@node event printJobs, seriousEvent, warning, Predefined Events
@subsection event printJobs
@cindex printJobs

A signal sent to sessionLeader job to indicate
a request to list active jobs.

The usual use is to bind a character (usually ^T) to it
on a socket via @code{setSocketCharEvent}.

@xref{setSocketCharEvent}.

@c
@node seriousEvent, event abort, event printJobs, Predefined Events
@subsection seriousEvent
@cindex seriousEvent

A @code{event} is @dfn{serious} if it calls
for user intervention in the absence of resolution
by some handler.  All serious events should
inherit from @code{seriousEvent}.

(All errors are serious events. Events
such as ``stack overflow'' are serious events,
although they are not errors.)

@emph{Note:} Actual user intervention is triggered
not by the event type, but rather by choice of
signaling function: @code{error} will invoke the
debugger if the signaled event is not handled,
and @code{signal} will not.  You are expected to
use @code{error} when the event is a
descendant of @code{seriousEvent}, and
@code{signal} otherwise.

@c
@node event abort, event debug, seriousEvent, Predefined Events
@subsection abort
@cindex abort

Child of @code{seriousEvent}.

This is the conventional event signaled
to abort a job -- to invoke the most recent
abort restart, which will usually be a major
interpreter readEvalPrint loop.


@c
@node event debug, event kill, event abort, Predefined Events
@subsection debug
@cindex debug

Child of @code{seriousEvent}.

This is the conventional event signaled
to throw a job into the debugger.


@c
@node event kill, event error, event debug, Predefined Events
@subsection kill
@cindex kill

Child of @code{seriousEvent}.

This is the conventional event signalled
to kill a job.  The job catching the signal
is expected to wrap up and exit promptly.

Keyword specifics available:
@table @code
@item :why
An optional diagnostic value which may be
passed to the 'endJob' prim as argument.
@end table


@c
@node event error, serverError, event kill, Predefined Events
@subsection error
@cindex error

All errors events should
inherit from @code{error}, which is a child of
@code{seriousError}.

@c
@node serverError, simpleEvent, event error, Predefined Events
@subsection serverError
@cindex serverError

@sc{Not a event defined by CommonLisp.}

Child of @code{error}.

Catchall event type for errors detected at runtime
by the server.  These errors should probably all be
assigned to more appropriate event types
eventually, and @code{serverError} either eliminated
or made a parent of them.

@c
@node simpleEvent, simpleWarning, serverError, Predefined Events
@subsection simpleEvent
@cindex simpleEvent

Child of @code{event}.

Default event type for @code{signal} when
first arg is a string.

@c
@node simpleWarning, simpleError, simpleEvent, Predefined Events
@subsection simpleWarning
@cindex simpleWarning

Child of @code{warning} and @code{simpleEvent}.

Default event type for @code{warn} when
first arg is a string.

@c
@node simpleError, storageEvent, simpleWarning, Predefined Events
@subsection simpleError
@cindex simpleError

Child of @code{error} and @code{simpleEvent}.

Default event type for @code{error} and
@code{cerror} when
first arg is a string.

@c
@node storageEvent, typeError, simpleError, Predefined Events
@subsection storageEvent
@cindex storageEvent

Child of @code{seriousEvent}.

Events relating to storage overflow inherit
from this.

@c
@node typeError, simpleTypeError, storageEvent, Predefined Events
@subsection typeError
@cindex typeError

Child of @code{error}.

Events relating to data type errors, such as
those relating to data movement, inherit from
this.

Keyword specifics available:
@table @code
@item :datum
The offending value.
@item :expected-type
Type which @code{:datum} failed to satisfy.
@end table

@c
@node simpleTypeError, programError, typeError, Predefined Events
@subsection simpleTypeError
@cindex simpleTypeError

Child of @code{typeError} and @code{simpleEvent}.

@c
@node programError, controlError, simpleTypeError, Predefined Events
@subsection programError
@cindex programError

Child of @code{error}.

Errors relating to incorrect program syntax which
are statically detectable (even if in fact
detected at runtime) inherit from this.

@c
@node controlError, packageError, programError, Predefined Events
@subsection controlError
@cindex controlError

Child of @code{error}.

Errors relating to dynamic transfer of control
inherit from this.

@c
@node packageError, streamError, controlError, Predefined Events
@subsection packageError
@cindex packageError

Child of @code{error}.

Errors relating to operations on packages
inherit from this.

Keyword specifics available:
@table @code
@item :package
The offending package.
@end table


@c
@node streamError, endOfFile, packageError, Predefined Events
@subsection streamError
@cindex streamError

Child of @code{error}.

Errors relating to reading, writing or closing a
stream
inherit from this.

Keyword specifics available:
@table @code
@item :stream
The offending stream.
@end table


@c
@node endOfFile, fileError, streamError, Predefined Events
@subsection endOfFile
@cindex endOfFile

Child of @code{streamError}.

Errors relating to reading from an empty
stream
inherit from this.

Keyword specifics available:
@table @code
@item :stream
The offending stream.
@end table


@c
@node fileError, cellError, endOfFile, Predefined Events
@subsection fileError
@cindex fileError

Child of @code{error}.

Errors relating to opening a file or other
low-level file system operation inherit from this.

Keyword specifics available:
@table @code
@item :pathname
The offending file.
@end table


@c
@node cellError, unboundVariable, fileError, Predefined Events
@subsection cellError
@cindex cellError

Child of @code{error}.

Errors relating to accessing a memory location
inherit from this.

Keyword specifics available:
@table @code
@item :name
Name of offending location.
@end table

@c
@node unboundVariable, undefinedFunction, cellError, Predefined Events
@subsection unboundVariable
@cindex unboundVariable

Child of @code{cellError}.

Errors relating to accessing an unbound variable
inherit from this.

Keyword specifics available:
@table @code
@item :name
Name of offending location.
@end table


@c
@node undefinedFunction, arithmeticError, unboundVariable, Predefined Events
@subsection undefinedFunction
@cindex undefinedFunction

Child of @code{cellError}.

Errors relating to accessing an undefined function
inherit from this.

Keyword specifics available:
@table @code
@item :name
Name of offending location.
@end table


@c
@node arithmeticError, divisionByZero, undefinedFunction, Predefined Events
@subsection arithmeticError
@cindex arithmeticError

Child of @code{error}.

Errors relating to arithmetic operations
inherit from this.

Keyword specifics available:
@table @code
@item :operation
Function being performed.
@item :operands
Function being performed.
@end table


@c
@node divisionByZero, floatingPointOverflow, arithmeticError, Predefined Events
@subsection divisionByZero
@cindex divisionByZero

Child of @code{arithmeticError}.

Errors relating to arithmetic operations
inherit from this.

Keyword specifics available:
@table @code
@item :operation
Function being performed.
@item :operands
Function being performed.
@end table


@c
@node floatingPointOverflow, floatingPointUnderflow, divisionByZero, Predefined Events
@subsection floatingPointOverflow
@cindex floatingPointOverflow

Child of @code{arithmeticError}.

Errors relating to floating point overflow
inherit from this.

Keyword specifics available:
@table @code
@item :operation
Function being performed.
@item :operands
Function being performed.
@end table

@c
@node floatingPointUnderflow, brokenPipeWarning, floatingPointOverflow, Predefined Events
@subsection floatingPointUnderflow
@cindex floatingPointUnderflow

Child of @code{arithmeticError}.

Errors relating to floating point underflow
inherit from this.

Keyword specifics available:
@table @code
@item :operation
Function being performed.
@item :operands
Function being performed.
@end table


@c
@node brokenPipeWarning, readFromDeadStreamWarning, floatingPointUnderflow, Predefined Events
@subsection brokenPipeWarning
@cindex brokenPipeWarning

Child of @code{warning}.

This warning is sent to the session leader for a socket
when a disconnect is detected.

Keyword specifics available:
@table @code
@item :socket
Socket disconnected
@end table

@c
@node readFromDeadStreamWarning, writeToDeadStreamWarning, brokenPipeWarning, Predefined Events
@subsection readFromDeadStreamWarning
@cindex readFromDeadStreamWarning

Child of @code{warning}.

This is sent to a job when it attempts to read from an
ampty stream which has @code{stream$s.dead} set
non-@sc{nil}.

Keyword specifics available:
@table @code
@item :stream
The dead stream.
@end table


@c
@node writeToDeadStreamWarning, Muq Event System Wrapup, readFromDeadStreamWarning, Predefined Events
@subsection writeToDeadStreamWarning
@cindex writeToDeadStreamWarning

Child of @code{warning}.

This is sent to a job when
it attempts to write to a stream
which has @code{stream$s.dead}
set non-@sc{nil}.

Keyword specifics available:
@table @code
@item :stream
The dead stream.
@end table


@c
@node Muq Event System Wrapup, Core Muf, writeToDeadStreamWarning, Muq Events
@section Muq Event System Wrapup

Event handling is a traditionally thorny
programming language topic, frequently handled
by ad hoc mechanisms and a frequent source of
bugs and maintainance headaches.

The Muq event system provides a clean modern
toolkit.  It is up to you to make effective use
of it.


@c --    File variables							*/

@c Local variables:
@c mode: texinfo
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
