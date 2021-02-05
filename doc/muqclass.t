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
@node Muq Classes, Muq Classes Overview, Data Type Efficiency Considerations, Top
@chapter Muq Classes

@menu
* Muq Classes Overview::
* Class Plain::
* Class Assembler::
* Class MosClass::
* Class MosKey::
* Class CompiledFunction::
* Class Data Stack::
* Class Function::
* Class Hash::
* Class Index::
* Class Job::
* Class JobQueue::
* Class JobSet::
* Class LambdaList::
* Class Lock::
* Class Loop Stack::
* Class MessageStream::
* Class Method::
* Class Muq::
* Class MuqConfiguration::
* Class Package::
* Class Proxy::
* Class Stream::
* Class Session::
* Class Set::
* Class Socket::
* Class Stack::
* Class StructureDefinition::
* Class System::
* Class User::
* Muq Object Efficiency Considerations::
@end menu
@c -*-texinfo-*-

@c
@node Muq Classes Overview, Class Plain, Muq Classes, Muq Classes
@section Muf Classes Overview
@cindex Classes in Muq
@cindex Muq classes

Muq is a vaguely micro-kernel design in that the intention is to provide
just efficiency- and security-critical functionality in the server, in
as policy-neutral a fashion as practical, while confining most of the
"interesting" code to in-db code written in the application language(s).

However, Muq is also intended to be a reasonably secure, stable and
reliable server: even root should not be able to coredump the server
by fiddling with the db, ideally, and certainly no normal user should be
able to do so.

My approach to ensuring this has been to code up the basic multi-user,
multi-tasking functionality inserver, and really not let in-db hackers
get their fingers very far into it.  Most of the following classes are
essential, in one fashion or another, to implementing this basic
security kernel.  My hope is that most application-specific
functionality can be coded up in-db without much further addition to the
kernel, although some applications -- such as 3-D graphics -- would
clearly require additional C-coded functionality in order to achieve
acceptable performance.

@c
@node Class Plain, Class Assembler, Muq Classes Overview, Muq Classes
@section Class Plain
@cindex Class Plain
@cindex Plain Class

Class Plain defines the basic functionality and properties required of
all Muq built-in classes.  Class Plain also serves as a vanilla object which may
be used to construct directory hierarchies, and which may be specialized
in-db to provide specialized functionality unrelated to any of the
specialized built-in classes.

Class Plain predefines the following properties:

@example
$S.owner   User object with write privileges.
$S.myclass Which inserver class is this object?
$S.name    User-settable name for object.
$S.isA     User-defined class for object.
$S.dbname  Name of dbfile in which object is stored.
@end example

@c
@node Class Assembler, Class MosClass, Class Plain, Muq Classes
@section Class Assembler
@cindex Assembler Class
@cindex Class Assembler

Two Muq design goals are to provide secure, stable service to multiple
users, and to allow unprivileges users to implement compilers for new
languages.  Together, these imply that the writer of a compiler must not
be able to generate code that would crash the server or bypass security
mechanisms.

To some extent, this is intractable: If the compiler generates
unexpected code, and other people use it and run that code with their
own privileges, their security will be compromised.  To put it mildly.
(See Ken Thompson's Turing Award acceptance speech, reprinted in
Communications of the Association for Computing Machinery.)

However, we can at least guarantee that compilers can only generate
valid executables that will not crash the server or, say, do fetches
from non-existent offsets in the constant vector.

Class Assembler exists to provide this layer of security: It provides
the only mechanism by which executable objects can be constructed in
Muq, and ensures the basic validity of all such objects.  It also
provides a central pathway through which all code generation flows, in
which a certain amount of language-independent optimization may be done.

Compilers create executables by creating an instance of Class Assembler,
feeding it all the code for the proposed executable, then asking it to
create the executable.  The Assembler instance sanity-checks all input,
preserves the state of the assembler internally out of reach of errant
or malicious fingers, and on completion of assembly returns an
executable guaranteed to be basically safe, if not necessarily sane.

Class Assembler adds the following properties to those of Class Plain:

@example
$S.bytecodes:       Nonzero if code has been assembled since last reset.
$S.compileTime:    True iff fn should run at compiletime not runtime.
$S.fnLine:         Line# fn began on in src file (1st is 0). (Set by compiler.)
$S.fileName:       File containing source for function. (Set by compiler.)
$S.lineInFn:      Current line# in fn in source (1st is 0). (Set by compiler.)
$S.fnName:         Name of function currently being compiled. (Set by compiler.)
$S.neverInline?:   True iff user forbids compiling fn inline.
$S.nextLabel:      Label to be returned by next assembleLabelGet.
$S.pleaseInline?:  True iff user prefers compiling fn inline.
$S.saveDebugInfo: Non-nil to save debug support info on compiled functions.
$S.flavor:          NIL :thunk :promise or :mosGeneric.
$S.vars             Number of local variables in fn being compiled.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

The @code{fnLine} and @code{lineInFn} properties are both
zero-based: The first line in a file is line zero, the first line in a
function is line zero.  However, users expect line numbers to begin at
one, and text editors conventionally number them this way, so you
should add one to either when displaying it.

@c
@node Class MosClass, Class MosKey, Class Assembler, Muq Classes
@section Class MosClass
@cindex Class MosClass
@cindex MosClass Class

Class MosClass instances hold the information defining
a particular MOS (Muq Object System) class.

Class MosClass adds the following properties to those of Class Plain:

@example
$S.key                  Object containing slot definitions &tc.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

Note: Proper support for the CommonLisp meta-class protocol,
when it is finalized, may require changes to this class.

@c
@node Class MosKey, Class CompiledFunction, Class MosClass, Muq Classes
@section Class MosKey
@cindex Class MosKey
@cindex MosKey Class

Class MosKey provides part of the Muq support
for the Muq Object System model of object-oriented
computation.  It is an internal support class normally
only directly visible to -- or of interest to -- programmers
venturing deep into the internals of Muq compilers and runtimes.

The @sc{mos} model requires that
@itemize @bullet
@item
Generic functions be real compiled-functions, which can
be called, applied &tc just like any normal compiledFunction.
@item
Generic functions be modifiable on the fly, adding and
removing new methods and the like.
@item
Such modification may not actually change the idenity of the
generic compiledFunction:
The modified compiledFunction must be @code{eq} to the original.
@end itemize

Muq meets these requirements by implementing @sc{mos} generic
functions as normal compiledFunction instances which happen
to have (among other things) a special bit set identifying
them as a @sc{mos} compiledFunction, and to have in their
first constant slot a pointer to a MosKey
instance, which then contains the time-varying information
such as the currently-defined set of methods for the
generic function.

A MosKey instance is itself neither a function
nor a compiledFunction:  It is merely a passive datastructure
containing information about the generic function encoded for
quick access during method invocation ("message-sending").

Class MosKey adds the following properties to those of Class Plain:

@example
( Buggo, should merge type and layout, I think: )
$S.abstract              Normally NIL; non-NIL to forbid creation of instances.
$S.type                  'vector 'list or nil
$S.layout                Ram layout: :structure :vector :built-in :fixnum ...
$S.compiler              Parallel to function$s.compiler
$S.documentation         Value supplied to ]defclass :documentation option.
$S.source                Parallel to function$s.source
$S.fileName             Parallel to function$s.fileName
$S.fnLine               Parallel to function$s.fnLine
$S.assertion             Type verification compiledFunction.
$S.predicate             Type check compiled-funciton.
$S.printFunction        Print function.
$S.createdAnInstance   NIL unless an instances has been created.
$S.mosClass             Backpointer to MOS class we implement.
$S.newerKey             NIL, else pointer to key superceding us.
$S.concName             Prefix for accessor functions.
$S.constructor           Constructor compiledFunction.
$S.copier                Copier compiledFunction.
$S.named                 t or nil
$S.initialOffset        whole number
$S.export                NIL unless defstruct included :export t option.
$S.fertile               NIL unless subclassing by other users is ok.
$S.unsharedSlots        # of unshared slots (those stored in key).
$S.sharedSlots          # of shared slots (those stored in instances).
$S.mosParents           # of direct superclasses.
$S.mosAncestors         # of direct and indirect superclasses.
$S.initargs              # of initarg -> slotname map pairs.
$S.objectMmethods        # of methods keying on obj of our class in 1st arg.
$S.classMethods         # of methods keying on our class in 1st arg.
$S.metaclass             Currently always standardClass.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

MosKey instances also contain internal
arrays with the above dimensions, in particular, the
class precedence list:
@xref{getMosKeyInitarg}.
@xref{setMosKeyInitarg}.
@xref{getMosKeyParent}.
@xref{setMosKeyParent}.
@xref{getMosKeyAncestor}.
@xref{setMosKeyAncestor}.
@xref{getMosKeySlotProperty}.
@xref{setMosKeySlotProperty}.

@xref{makeMosKey}.

@c
@node Class CompiledFunction, Class Data Stack, Class MosKey, Muq Classes
@section Class CompiledFunction
@cindex Class CompiledFunction
@cindex CompiledFunction Class

Class CompiledFunction instances contain the actual executable
bytecodes that drive the Muq interpreter, along with
constants needed by the code.  (Making the constant vector a
separate object would be slightly cleaner design, but would
slow down procedure call/return by requiring two objects to
be found instead of just one.)

Thunks and promises are simply compiled-functions with
special flags set on them.  (Internally, they are also
referenced via pointers with special flags set, so as to be
able to implement promise and thunk functionality extremely
efficiently in the interpreter, without actually having to
waste any instructions on each bytecode checking to see if
the arguments are thunks and need to be evaluated.  In a
sense, thunks add zero overhead to the basic Muq instruction
dispatch code.)

CompiledFunction instances do not actually possess the full
overhead of a standard muq object, with creation time,
change time and so forth: since compiled-functions may be created by
the thousand when using anonymous functions as data
constructors (via capture of lexical environment in lisp
@code{lambda}s, say) or when using promises to program in
pure-functional style, I have attempted to reduce space
overhead of compiled-functions to the absolute minimum.

The physical layout of a compiledFunction instance is
currently approximately:

@itemize @bullet
@item
A three-word header giving ownership, source function,
number of constants, and a few bits of information as
to whether, for example, the compiledFunction is a thunk.

@item
The constants needed by the bytecodes.

@item
The bytecodes themselves, 0xFF-padded to a word boundary.
@end itemize

Thus, if one minimizes the amount of code actually stored in
a compiledFunction by having most of its work done by
another compiledFunction, it may reasonably be used as a
lightweight object, capable of containing information with
only about five words more overhead than a vector, but
unlike a vector, able to provide encapsulation and arbitrary
computation in response to a call.

Since compiledFunction objects are not really true objects,
storing arbitrary properties on them via the normal
object-oriented property get/set calls is not currently
supported.

Compiled-functions export the following public properties:

@example
$S.asRoot?           True iff "as-root@{...@}" is used in source.
$S.compileTime?      True iff "compileTime" flagged in source.
$S.constCount        Number of constants in constant vector.
$S.generic?           True iff is a old-style generic (CommonLisp sense) fn.
$S.mosGeneric?       True iff is a Muq Object System generic fn.
$S.keptPromise?      True iff promise has been evaluated.
$S.neverInline?      True iff "neverInline" flagged in source.
$S.owner              User owning compiledFunction.
$S.pleaseInline?     True iff "pleaseInline" flagged in source.
$S.prim?              True iff fn is a C-coded in-server primitive.
$S.promiseOrThunk?  True iff either of the promise? or thunk? values is true.
$S.promise?           True iff function is a promise.
$S.source             Source function for this compiled function.
$S.thunk?             True iff function is a thunk.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class Data Stack, Class Function, Class CompiledFunction, Muq Classes
@section Class Data Stack
@cindex Class Data Stack
@cindex Data Stack Class

One Class Data Stack instance is associated with each job, and
implements the programmer-visible evaluation stack.

There is no way to create instances of this class other than
by creating new jobs: The class exists specifically to let
the server efficiently distinguish job evalation stacks from
other sorts of stacks, in support of debugging and security.

Class Data Stack adds the following properties to those of Class Plain:

@example
$S.vector:   The vector used to actually hold the stack contents.
$S.length:   The current number of occupied slots in the stack.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class Function, Class Hash, Class Data Stack, Muq Classes
@section Class Function
@cindex Class Function
@cindex Function Class

Class Function serves to keep track of the source code for a given
executable, and other information needed to recompile it, such as the
compiler used to translate from source to executable form.

This information could be kept in the executable itself, of course,
but keeping it in a separate object has a number of advantages:

@itemize @bullet
@item
The function instance exists before the first compile and between
compiles and remains the same object between compiles, hence provides
a stable place to keep the source code:  A new executable will be
created by each compile.  The function provides a stable place to
hang help information, for example.

@item
Potentially thousands of executables may be created from a single
set of source code, if it describes a thunk or promise being used
as a data constructor.  Factoring all the source information out
into a single shared function object provides space efficiency
and reduced redundancy.

@item
Much code is more frequently executed than edited or compiled: by
factoring the information needed for recompilation into a separate
object from that needed for execution, the former can stay on disk when
the latter is swapped into ram.
@end itemize

Class Function adds the following properties to those of Class Plain:

@example
$S.arity:	Number of arguments accepted and returned.
$S.executable:   Most recently compiled executable. There may be others.
$S.compiler:     Program translating source to executable.
$S.fileName:    Debug information: Name of source file.
$S.fnLine:      Debug information: Starting line number in source file.
$S.lineNumbers: Debug information: vector of line numbers, one per bytecode.
$S.source:       String source code.
$S.localVariableNames: Vector of string names for local variables.
$S.specializedParameters:  NIL or count of required args for generic.
$S.defaultMethods:  NIL or mosKey of methods with t as 1st arg specializer.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

The @code{fnLine} value, and the integers in the @code{lineNumbers}
vector, are all
zero-based: The first line in a file is line zero, the first line in a
function is line zero.  However, users expect line numbers to begin at one,
and text editors conventionally number them this way, so you
should add one to either when displaying it.

As of version -1.0.0, compiler and debug information is not used.
@xref{explodeArity}.

@c
@node Class Hash, Class Index, Class Function, Muq Classes
@section Class Hash
@cindex Class Hash
@cindex Hash Class

Like Index objects, Hash objects serve to map arbitrary keys to
values:

@example
root:
makeHash --> _h
root:
12 --> _h["12"]
root:
_h["12"]
root: 12
@end example

Values are stored in four hashed b-trees (one each for
hidden, public, system and admins properties) stored on
the hash object.

As a result, hash objects need three slots per key-val
pair (key, hashed-key, val) rather than just two as in
Index objects.

In compensation, lookup may be significant faster in hash objects if
key comparisons are expensive -- for example, if the keys are long
strings which differ only in the last few characters.

Note that values will be read out of a Hash in an arbitrary appearing
order (that dictated by the hash function):  If sorted readout order
is a requirement, you should use an Index instead.

@xref{Class Index}.
@xref{Class Set}.

@c
@node Class Index, Class Job, Class Hash, Muq Classes
@section Class Index
@cindex Class Index
@cindex Index Class

Index objects serve to map arbitrary keys to
values:

@example
root:
makeIndex --> _h
root:
12 --> _h["12"]
root:
_h["12"]
root: 12
@end example

Values are stored in four b-trees (one each for
hidden, public, system and admins properties) stored on
the index object.

Thus, index objects need a minimum of two slots per key-val
pair stored.

For convenience, many other Muq classes appear to store key-val pairs just
as do Index objects.  However, in instances of other classes do not have
dedicated slots for the key-val btrees:  Instead the btrees are stored in
an internal Index mapping objects to btrees.

The practical result is that storing and retrieving values from Index
objects will be faster, but empty Index objects will have the space
overhead of the four slots used to hold the btrees.

Also note that storing just one key-val pair in an Index still
requires allocating a full 512-byte btree node:  Allocating
large numbers of Index objects which each hold just one or
two key-val pairs is not space-efficient.  If space efficiency
matters, you should use MOS objects, structs, vectors, or even
Lists in such cases.

@xref{Class Hash}.
@xref{Class Set}.

@c
@node Class Job, Class JobQueue, Class Index, Muq Classes
@section Class Job
@cindex Class Job
@cindex Job Class

Each Class Job instance contains information about one Muq
thread of control: It tracks a program counter pointing into
some executable, with an associated stack of return
information.

Jobs are Muq's closest approximation to the unix concept of
a process, but are more like threads because all Muq jobs
(in a given server) share a single address space and
database, hence may freely exchange not just strings and
numbers, but data values of any sort whatever, including
objects, stacks and jobs.

Muq jobs run round-robin under pre-emptive multi-tasking,
normally blocking when they read from an empty message stream
or write to a full message stream.

Muq jobs support a fairly complete unix-like set of signals
which may be blocked, ignored, provided with handlers, and
so forth.

Class Job adds the following properties to those of Class Plain:

@example
$S.debugIo:        Bidirectional messageStream for debugging I/O.
$S.doBreak:        Function to call when 'break' is executed.
$S.debugger_hook:   Runs before $s.debugger'.
$S.debugger:        Interactive event handler.
$S.compiler:        Compiler instance currently in use by the running shell.
$S.spareAssembler: Used internally by compilers.
$S.spareCompileMessageStream: Reserved for compiling code from strings.
$S.breakDisable:   non-NIL turns 'break' and ']break' into no-ops.
$S.breakEnable:    non-NIL lets ]error and ]cerror enter debugger.
$S.breakOnSignal: T runs ]invokeDebugger on every signal.
$S.doingPromiscuousRead: NIL except during |readAnyStreamPacket.
$S.promiscuousNoFragments: Internal state during |readAnyStreamPacket.
$S.doError:        Fn invoked when server detects an error.
$S.doSignal:       Fn invoked by 'signal' to do most of the work.
$S.errorOutput:    Message-stream for standard error output.
$S.queryIo:        Bidirectional Message stream for query I/O.
$S.ephemeral-lists:   Loop stack offset of most recent ephemeral list.
$S.ephemeralObjects: Loop stack offset of most recent ephemeral object.
$S.ephemeralStructs: Loop stack offset of most recent ephemeral struct.
$S.ephemeralVectors: Loop stack offset of most recent ephemeral vector.
$S.functionBindings: Loop stack offset of most recent function binding.
$S.variableBindings: Loop stack offset of most recent variable binding.
$S.muqnetIo:       Dedicated stream for transparent networking support.
$S.standardInput$s.twin:  Job reads vals written to this message stream.
$S.standardOutput: Job output is written to this messageStream.
$S.terminalIo:     Bidirectional message stream for human I.O.
$S.traceOutput:    Message-stream for 'trace' function.
$S.dataStack:	    Muf-visible data stack.
$S.loopStack:	    Loop stack holding local vars, return addresses &tc.
$S.package:	    Current package.
$S.lib:		    Known packages.
$S.readtable:	    Lisp readtable instance for compiling lisp.
$S.reportEvent:	    Fn invoked to report an event.
$S.actingUser:	    Effective user at the moment.
$S.actualUser:	    Actual user.
$S.group            Currently undefined, intended for shared access.
$S.here:            Current directory in "cd" sense.
$S.jobSet:         Jobset to which this job belongs.
$S.opCount:	    Virtual-instructions-executed count.
$S.parentJob:      Job that forked us off.
$S.priority:	    0 is max execution priority, 2 is min, 1 is normal.
$S.root:            Current logical root, for chroot support.
$S.sleepUntilMillisec:  Earliest time to wake job, when sleeping.
$S.stackBottom:    Logical bottom of stack.  (May differ from real bottom.)
$S.state:           Whether job is running or whatever.
$S.endJob:         In dead jobs, holds value given to 'endJob' prim.
$S.killStandardOutputOnExit: Set $S.standardOutput$S.dead at shutdown?
$S.readNilFromDeadStreams:  Non-NIL => readLine returns NIL.
$S.asynch           Support for ASYNCH package.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class JobQueue, Class JobSet, Class Job, Muq Classes
@section Class JobQueue
@cindex JobQueue Class
@cindex Class JobQueue

A Muq jobQueue is just what you probably think, an
anchor-point for a linklist of Job objects, typically
used to hold a set of jobs waiting on some event before
they continue.  Jobs currently ready to run are kept
in a jobQueue, as are paused jobs.  Each stream object
has two job-queues associated with it, one for jobs
which are waiting for something to read, one for
jobs waiting for room for a write.

Class JobQueue adds the following properties to those of Class Plain:

@example
$S.next:     Next job in queue, or else the jobQueue itself.
$S.previous: Previous job in queue, or else the jobQueue itself.
$S.partOf:  In job-queues on a stream, this points to the stream.
$S.kind:     "i/o" usually, "run" for run queues, else "ps"/"doz"/"poz"/"hlt".
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class JobSet, Class LambdaList, Class JobQueue, Muq Classes
@section Class JobSet
@cindex Jobset Class
@cindex Class Jobset

Since Muq, like unix, allows jobs to cooperate easily to
accomplish a task, and since it is likely that Muq shells,
like unix shells, will take advantage of this to implement
complex tasks as a set of jobs, there arises the problem of
coordinating and controlling these complexes: what if the
user fires up a pipeline of half a dozen jobs and then wants
to abort them halfway through?  Doing so shouldn't be a
mysterious task requiring sorting through listings and
killing them off one at a time by number.

Since this problem is rife with tricky complications, since
unix solves it reasonably well, since I see no reason to
believe that I can match, much less improve upon, the unix
solution, and since following the unix lead allows users to
transfer hard-won expertise back and forth between Muq and
unix, Muq attempts to follow the unix model fairly closely
in this area.

JobSets correspond directly to unix process groups, and
exist to group a set of jobs implementing one conceptual
task together into a cluster which may be conveniently
stopped, restarted, and killed as a unit.

A jobSet is essentially nothing more than an object with a
propdir full of jobs, but is made a separate class to help
let the server keep a handle on the sanity of the system: we
don't want users doing bogus things to jobsets and confusing
the server multitasking machinery.

Class JobSet adds the following properties to those of Class Plain:

@example
$S.jobsetLeader:   Job serving as equivalent of unix "process group leader".
$S.jobQueue:       Jobqueue holding all jobs in jobset.
$S.nextJobset:     Linklist holding all jobsets in session.
$S.previousJobset: Linklist holding all jobsets in session.
$S.session:         Session to which this jobset belongs.
@end example

@noindent
Other jobs in the jobset are filed under pid. (?)

Note: For convenience, the $S properties are also available in the public (default)
propdir.

Note: JobSet functionality is incomplete in release -1.0.0.

@c
@node Class LambdaList, Class Lock, Class JobSet, Muq Classes
@section Class LambdaList
@cindex Class LambdaList
@cindex LambdaList Class

Class LambdaList is used internally by Muq to record
the argument declarations for a function (required,
optional and keyword parameters with their default
values &tc) in a compact for suitable for efficiently
processing an argument block at runtime.  LambdaList
instances are not normally directly visible to, or of
interest to, programmers who are not poking around
deep in the key of the Muq compilers or runtimes.

Class LambdaList adds the following properties to those of Class Plain:

@example
$S.requiredArgs:  Integer count of required arguments.
$S.optionalArgs:  Integer count of optional arguments.
$S.keywordArgs:   Integer count of keyword arguments.
$S.totalArgs:     Sum of above three.
$S.allowOtherKeywords:  T or NIL.  Currently ignored.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

Class LambdaList instances also contain an internal variable-length
array describing the various arguments:
@xref{getLambdaSlotProperty}, @xref{setLambdaSlotProperty}.

@xref{makeLambdaList}.

@c
@node Class Lock, Class Loop Stack, Class LambdaList, Muq Classes
@section Class Lock
@cindex Class Lock
@cindex Lock Class

Class Lock implements what are traditionally termed
"semaphores", used to keep multiple jobs from stepping
on each other when they update the db.  The canonical
usage pattern is

@example
( new object )  --> obj
makeLock       --> obj.lock
@end example

when creating an object, and then

@example
obj.lock with-lock-do@{
    ( Update object )
@}
@end example

The server does not explicitly associate a lock with any
particular object or property: It is up to you to decide
what values the lock protects, and to ensure that all code
accessing those values respects the lock.

The @code{with-lock-do@{@dots{}@}} syntax blocks the job until
it can obtail sole control of the lock, then executes the
given code with that control, meaning that any other jobs
attempting to obtain the lock will block until we exit the
construct.

Class Lock adds the following properties to those of Class Plain:

@example
$S.heldBy:  NIL or else the job holding the lock.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class Loop Stack, Class MessageStream, Class Lock, Muq Classes
@section Class Loop Stack
@cindex Class Loop Stack
@cindex Loop Stack Class

One Class Loop Stack instance is associated with each job,
and contains the procedure call/return stack, local
variables, and various state information not directly
visible to the programmer.

The name comes from the fact that local variables implicitly
created by control constructs, such as the various loops,
live on this stack.  Forth implementations traditionally
refer to this as the "return stack".

There is no way to create instances of this class other than
by creating new jobs: The class exists specifically to let
the server efficiently distinguish job loop stacks from
other sorts of stacks, in support of debugging and security.

Class Loop Stack adds the following properties to those of Class Plain:

@example
$S.vector:   The vector used to actually hold the stack contents.
$S.length:   The current number of occupied slots in the stack.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class MessageStream, Class Method, Class Loop Stack, Muq Classes
@section Class MessageStream
@cindex MessageStream Class
@cindex Class MessageStream

Unix allows processes to communicate between unidirectional
@dfn{pipes;} In close analogy, Muq allows jobs to
communicate between unidirectional @dfn{message streams}.

In both cases, a principal motivation is to provide a clean
and simple prepackaged solution to the producer-consumer
synchronization problem, in which one job produces output
which is then consumed by another job: the consumer job
needs to stop and wait when no more input is available, and
it is usually a good idea for the producer job to stop and
wait when the consumer falls behind, rather than filling the
database with perhaps megabytes of unconsumed output.

Pipes and message streams both serve as bounded buffers
written to by one or more producers and read by one or more
consumers; A producer which attempts to write to a full
buffer will automatically block until free space becomes
available; a consumer which attempts to read from an empty
buffer will automaticaly block until input becomes
available.

The principal difference between unix pipes and Muq message
streams is that pipes are fundamentally structured to
pass a flow of bytes, while message
streams are fundamentally structured to pass a flow of
stackblocks containing arbitrary Muq values, including
characters, floats, objects, and even jobs, sessions and
message streams, if desired.

There is a limit on the maximum size stackblock which a
given message stream can hold, available as
@code{stream$s.maxPacket}.  This is currently a fixed
constant (4095); It may be made variable on a
per-stream basis in a future release.

There is also a limit on the maximum number of stackblocks
resident in a given message stream at a given instant; This
is currently fixed at 31.

The conventional way to pass text through message
streams (that is, to use them as unix-style text
streams) is to pass blocks of characters, one line per
block.
@footnote{By not routinely passing large numbers of
strings through message streams, we avoid both the
inefficiency of allocating and then garbage-collecting
massive numbers of strings, and also the thorny issue
of who should own -- and be quota-charged for -- these
strings.}
Functions are available to simplify doing
unix-style character- or line-oriented @sc{i/o} through
message streams.  @xref{message stream functions}.

The standard input and output (and error) of a job will
always be message streams.

A pair of vanilla unidirectional message streams may be
combined to produce a bidirectional message stream
simply by pointing their @code{stream$s.twin}
properties to each other:
@xref{makeBidirectionalMessageStream}.  This works
because all server primitives which read from a stream,
actually read from @code{stream$s.twin}.  By default
this is the stream itself, and has no effect, but in a
bidirectional stream it results in the desired
behavior.

Internally, message streams contain job queues on which to
place blocked produce and consumer jobs; this functionality
is not normally of concern to the Muq programmer, or even
directly visible.

Class MessageStream adds the following properties to those of Class
Index:

@example
$S.allowReads:     T, job or user to allow non-owners to read from stream.
$S.allowWrites:    T, job or user to allow non-owners to write to stream.
$S.column:          Number of chars read from current packet so far.
$S.byte:            Number of bytes of tokens read from stream so far.
$S.line:            Number of packets or lines read from stream so far.
$S.dead:            NIL to allow normal I/O;  non-NIL to stop it.
$S.maxPacket:      Maximum size packet which may be written.
$S.twin:            Self, or twin if stream is bidirectional.
$S.inputString:       Reserved for supporting compilation from strings.
$S.inputStringCursor: Reserved for supporting compilation from strings.
$S.inputSubstitute:   Reserved for supporting compilation from strings.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

The @code{allowReads} and @code{allowWrites} properties allow
the owner of a stream to expand the default read or write
permissions for it.  Setting them to @code{t} results in
unrestricted read or write access;  Setting them to a job
or user adds access only for that job, or jobs with
@code{@@$s.actingUser} set to the given user.  This
simplifies implementation of communication mechanisms
between users.

@c
@node Class Method, Class Muq, Class MessageStream, Muq Classes
@section Class Method
@cindex Method Class
@cindex Class Method

Class Method constitutes part of Muq's support for
the Muq Object System model of object-oriented
computation.  @sc{mos} methods are @emph{not}
compiled functions (as they are in many other models
of object-oriented computation):  They are data objects
which @emph{contain} a compiled function, along with
information used by the genericFunction ("message-passing")
machinery to decide when and how to invoke that compiled
function.

Class Method adds the following properties to those of Class
Index:

@example
$S.qualifier:         NIL, :before :after :around (for std method combination).
$S.methodFunction:   Compiled function implementing method.
$S.genericFunction:  Compiled-function for generic to which method belongs.
$S.lambdaList:       Description of args for compiledFn.
$S.requiredArgs:     Count of required arguments for compiledFn.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

Class Method instances also contain an array of
slots, one for each required argument:
@xref{getMethodSlot}, @xref{setMethodSlot}.

@xref{makeMethod}.


@c
@node Class Muq, Class MuqConfiguration, Class Method, Muq Classes
@section Class Muq
@cindex Muq Class
@cindex Class Muq

In the interests of trying to provide a simple, flexible,
programmer-friendly environment, Muq attempts to provide as
simple and regular an interface as practical.  In
particular, it attempts to provide as much functionality as
possible via the central metaphor of properties on objects.

Thus, rather than provide a host of obscure primitives for
reading and modifying server configuration parameters, Muq
provides Class Muq, the properties of which display these
parameters.  Configuration parameters may thus be configured
via the normal property-setting primitives.

There is normally only one instance of Class Muq in the db,
available as @code{.muq}.

Reading and modifying host system configuration is done
via a separate class.  @xref{Class System}.

Class Muq adds the following properties to those of Class Plain:

@example
$S.allowUserLogging: Boolean policy flag.
$S.backupsDone: Total backups done over life of db, as published by vm.t.
$S.banned: Object indexing banned Guests.Users, else NIL.
$S.blocksRecoveredInLastGarbageCollect: As published by obj.t.
$S.bytesRecoveredInLastGarbageCollect: As published by obj.t.
$S.bytesBetweenGarbageCollects:   Controls frequency of interim gc.
$S.bytesInFreeBlocks:  Space in unused disk slots in db.
$S.bytesInUsefulData: Useful data stored in disk db.
$S.bytesLostInUsedBlocks: Disk bytes lost by internal fragmentation in db.
$S.bytesSinceLastGarbageCollect: Total bytes allocated.
$S.dbBufSize:  Size in bytes of vm.c's bigbuf[].
$S.dbLoads:     Number of disk reads done by vm.c since server boot.
$S.dbMakes:     Number of store blocks created by vm.c since server boot.
$S.dbSaves:     Number of disk writes done by vm.c since server boot.
$S.dateOfLastBackup: Time in milliseconds since the epoch (1970).
$S.dateOfLastGarbageCollect: Time in milliseconds since the epoch (1970).
$S.dateOfNextBackup: Zero to disable, else time in millisec since epoch (1970).
$S.debug:            Reserved for nonce server debugging.
$S.defaultUserServer1: Copied into user$s.userServer1 at creation.
$S.defaultUserServer2: Copied into user$s.userServer2 at creation.
$S.defaultUserServer3: Copied into user$s.userServer3 at creation.
$S.defaultUserServer4: Copied into user$s.userServer4 at creation.
$S.freeBlocks: Number of unused disk slots in db.
$S.glutIo:   Should be stream leading to job handling GLUT mouse/etc events.
$S.glutJob:  Should be set to job handling GLUT mouse/etc events, if any.
$S.logarithmicBackups: NIL for sequential backups, non-NIL for logarithmic.
$S.logBytecodes: Dis/able bytecode execution trace to logfile, if compiled in.
$S.logDaemonStuff: Dis/able logging of daemon packet I/O &tc.
$S.logWarnings: Dis/able writing server warnings to logfile.
$S.consecutiveBackupsToKeep: Usually at least 3.
$S.maxBytecodesPerTimeslice:           Multitasking timeslice length
$S.maxMicrosecondsToSleepInIdleSelect:  In select() when no runnable jobs
$S.maxMicrosecondsToSleepInBusySelect:  In select() when    runnable jobs
$S.microsecondsToSleepPerTimeslice:   Always sleep this long each slice
$S.muqnetIo: Should be stream leading to job handling iter-Muq networking.
$S.muqnetJob:    Should be set to job handling iter-Muq networking, if any.
$S.muqnetSocket: Should be socket for job handling iter-Muq networking.
$S.nextGuestRank:   Integer rank to assign to next Guest created.
$S.nextUserRank:   Integer rank to assign to next User created.
$S.nextPid:   Next integer to assign as a job name.
$S.millisecsBetweenBackups: Used to generate new dateOfNextBackup values.
$S.millisecsForLastBackup: Duration time in milliseconds of last backup.
$S.millisecsForLastGarbageCollect: Duration time of last garbage collect.
$S.runningAsDaemon:    Whether server is running daemon or from console.
$S.selectCallsMade:    Count of select()s done by skt.t module.
$S.blockingSelectCallsMade:    Similar skt.t-maintained count.
$S.nonblockingSelectCallsMade:    Similar skt.t-maintained count.
$S.reserved: Reserved for nonce server debugging hacks.
$S.selectCallsInterrupted:    Similar skt.t-maintained count.
$S.selectCallsWithNoIo:    Similar skt.t-maintained count.
$S.serverName:    Name of server for muqnet purposes.
$S.srvdir:  Host directory searched for subserver programs, else NIL.
$S.stackframesPoppedAfterLoopStackOverflow: >= 2. MUF settable.
$S.stackslotsPoppedAfterDataStackOverflow: >= 16. MUF settable.
$S.usedBlocks: Number of used disk slots in db.
$S.version: Version number of server, as a string.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class MuqConfiguration, Class Package, Class Muq, Muq Classes
@section Class MuqConfiguration
@cindex MuqConfiguration Class
@cindex Class MuqConfiguration

Another class providing a window into the server.  This
one publishes the compile options under which the
server was installed.  These may be useful in
determining whether the server provides a given
needed functionality.

(Class MuqConfiguration adds too many and obvious
a set of properties to that of
Class Plain to justify listing here.)

@c
@node Class Package, Class Proxy, Class MuqConfiguration, Muq Classes
@section Class Package
@cindex Class Package
@cindex Package Class

"Program" is a concept imposed by lazy operating-system
designers on reluctant programmers, as a way of locking
useful functions away from each other and the programmer at
runtime:  Programming environments designed by and for
programmers almost invariably lack the concept of a program:
Lisp, Smalltalk, Forth, APL...

Muq being intended to be a pleasant programming environment,
it likewise lacks the concept of a "program": subject to
privacy mechanisms, any function is free to refer to any
other function, and the programmer may invoke any function
at any time without needing to pry the lid off any black
box.

Eliminating the concept of "program" does not, however,
eliminate the need for modularity, namespace control, and
the ability to group code and data into units larger than
that of an individual datum or executable.

Lisp, being older than Fortran, has had some half a century
now to grapple with this problem, and has produced
@emph{packages} as an answer.  Not seeing any reason to
believe that I can improve sufficiently on the collective
wisdom of the Lisp community to justify imposing a more
idiosyncratic solution on the Muq user community, I have
configured Muq to follow CommonLisp here as closely as seems
practical.

A Muq @dfn{package} is nothing more or less than an object
whose public and hidden properties are all @emph{symbols.}
Since symbols have names, know to which package they belong,
and have value and function slots, this means that symbols
provide convenient little wrappers in which values may be
passed to functions and users, who will then be able to
simply use the provided value, if desired, or else be able
to print its name and package affiliation, if the user
should become curious as to where the value came from and
what it means.

Muq symbols serve as generic global variables; Muq packages
serve as sets of related symbols (representing both code and
data) which may then be included as a single unit in the
programming environment of a given Muq programmer: Muq
packages play something of the role of library as well as
the vestigal roles of programs.

Packages may contain both public symbols exported to anyone
using the package, and also private symbols intended only
for internal use, hence they also possess something in the
nature of an interface specification, and provide a simple,
generic form of encapsulization.

All symbols "present" in a package are listed in it as
hidden keys.

All symbols "exported' from a package are in addition listed
in it as public keys, making them available for general
external access.

A package P may "use" another package Q: this means that all
symbols exported from Q are known in P, and may be freely
used in P more or less as though they were present in P.

At a given time in a given job @@, @@.package is the currently
open package, and @@.lib is an object, public keys of which
represent the universe of packages treated as known to the
job.

Class Package adds the following properties to those of Class Plain:

@example
$S.nicknames:   An object, public keys of which are interpreted as
               nicknames for the package.

$S.shadowingSymbols:
               An object, public keys of which are interpreted as
               symbols which are to silently win name conflicts
               in the current package.

$S.usedPackages:
               An object, public keys of which are interpreted
               as packages "used" by the package.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class Proxy, Class Stream, Class Package, Muq Classes
@section Class Proxy
@cindex Class Proxy
@cindex Proxy Class

Proxy objects are not normally directly visible to
the application programmer:  They are used internally
by Muq to represent objects on other servers.

@c
@node Class Stream, Class Session, Class Proxy, Muq Classes
@section Class Stream
@cindex Class Stream
@cindex Stream Class

Class Stream is a bit of an exception to the general rule
that built-in Muq classes exist only to implement secure
multitasking: Class Stream is nowhere used in the fundamental
Muq server functionality; It exists only to provide a simple
and common service for muf programmers.  (It seemed odd to
me to provide the muf programmer with generic vectors and
various specialized stacks and streams, but not to provide
generic stacks and streams useful for arbitrary computation.)

Class Stream actually implements deques: Objects may be added
or removed from either end, hence if may actually be used as
a simple stack if desired.  It seemed to me to promote
clarity of programming to provide both stacks and the more
general streams, however.

Class Stream adds the following properties to those of Class Plain:

@example
$S.vector:   The vector used to actually hold the stream contents.
$S.length:   The current number of occupied slots in the stream.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

Since Class Stream is not part of the Muq security kernel, it
does not attempt to protect Stream internals from malicious
or nonsensical modification;  The alert reader will have
noticed that message-streams, by contrast, provide no direct
access to the contents of the stream.

@xref{makeStream}.
@xref{push}.  @xref{pull}.
@xref{unpush}.  @xref{unpull}.
@xref{length}. @xref{reset}.


@c
@node Class Session, Class Set, Class Stream, Muq Classes
@section Class Session
@cindex Session Class
@cindex Class Session

Class Session is the topmost part of the unix-modelled Muq
job-control hierarchy.

Jobs are the elementary constituents of this hierarchy.

Jobs are grouped into jobsets, sets of jobs implementing
logical tasks, such that all jobs in a jobset should
normally be stopped or killed together.

Jobsets are in turn grouped into sessions, a session
representing all tasks being run by a single user from a
single net connection.  Just as all the jobs in a jobset
should be killed or suspended if the logical task is
aborted, all the jobsets in a session should normally be
suspended or killed if the network connection is broken.

A session is thus structurally almost identical to a jobset,
except that it is hardwired to contain only jobsets, instead
of only jobs.  Sessions, like jobset, could be trivially
replaced by generic objects if we were not trying to heavily
protect the system against crashes due to programming errors
or malicious tampering.  Implementing a separate Session
class allows the kernel to efficiently and simply do more
sanity checking than would be the case with generic objects,
and may also make the system more self-documenting.

Class Session adds the following properties to those of Class Plain:

@example
$S.nextJobset:       Linklist holding all jobsets in session.
$S.previousJobset:   Linklist holding all jobsets in session.
$S.socket:            Network socket (or tty) for session, if any.
$S.sessionLeader:    Job recieving session-related signals.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class Set, Class Socket, Class Session, Muq Classes
@section Class Set
@cindex Set Class
@cindex Class Set

Class Set is much like Class Plain, except for
storing no values with the keys:  Values always come
back as 't'.  This can cut the space needs in half.

Sets are appropriate any time all that matters is
the presence or absence of the key, not the value
associated with it.

To facilitate this use, a Set returns @code{nil} for
missing keys, rather than throwing an error (as do
Index and kin):

@example
root:
makeIndex --> _x
root:
t --> _x["a"]
root:
_x["a"]
root: t
pop _x["b"]
Sorry: No such property: "b"
root:
makeSet --> _x
root:
t --> _x["a"]
root:
_x["a"]
root: t
pop _x["b"]
root: nil
@end example

Often the main reason to use a Set rather than an Index
will be simple space efficiency:  Set needs a minimum of
one slot on disk per stored value, while Index needs a
minimum of two (one each for key and value).

Class Set adds no properties to those of Class Plain.
@xref{Class Hash}.
@xref{Class Index}.

@c
@node Class Socket, Class Stack, Class Set, Muq Classes
@section Class Socket
@cindex Socket Class
@cindex Class Socket

Internally, Class Socket implements Muq's network interface logic:
all the good select(), bind(), listen() and so forth code lives there,
with attendant portability headaches.

To the muf programmer, Muq attempts to make an Socket look like just
one more job that communicates via message streams, but with the
mysterious restriction that only Strings may be passed to/from it (since
the network is bytestream-oriented, and the program on the far end
normally is also).

Class Socket adds the following properties to those of Class Plain:

@example
$S.closedBy:       NIL, else one of :close :exit :signal.
$S.exitStatus:     NIL, else integer which subprocess gave [_]exit();
$S.lastSignal:     NIL, else integer signal which killed subprocess.
$S.fdToRead:      Integer file descriptor used for read()s  (else NIL).
$S.fdToWrite:     Integer file descriptor used for write()s (else NIL).
$S.nlToNetCrnl:  T to convert \n -> \r\n on output, else NIL.
$S.netCrnlToNl:  T to convert \r\n -> \n on input,  else NIL.
$S.killStandardOutputOnExit: Set $S.standardOutput$S.dead at shutdown?
$S.passNonprintingFromNet NIL to change nonprinting chars to blanks else T.
$S.passNonprintingToNet NIL to strip all but isprint() and \n chars else T.
$S.inputByLines   T return only complete lines where practical else NIL.
$S.standardInput:  MessageStream whose contents should be fed to network.
$S.standardOutput: MessageStream to which network bytes should be sent.
$S.outOfBandInput:  MessageStream to send as network TELNET commands &tc.
$S.outOfBandOutput: MessageStream to get network TELNET commands &tc.
$S.thisTelnetState: 256 byte-string with 256 telnet option states.
$S.thatTelnetState: 256 byte-string with 256 telnet option states.
$S.telnetProtocol: T to support TELNET protocol on net, else NIL.
$S.telnetOptionHandler: NIL else vector of 256 compiled-functions.
$S.telnetOptionLock: NIL else a lock instance protecting *-telnet-state.
$S.outOfBandJob: Job doing telnet &tc processing for socket, else NIL.
$S.discardNetboundData: Set T to suppress output. Reset by any data read from net.
$S.session:         Session to recieve hangup signals and such for this socket.
$S.thisPort:       Integer port number of near end of connection, else zero.
$S.thatPort:       Integer port number of far  end of connection, else zero.
$S.thatPid:        Integer process ID for $S.type == :popen sockets, else NIL.
$S.thatAddress:    "128.95.44.22" adr for far  end of connection, else "".
$S.ip0:             1st (128) byte of above, as an integer.
$S.ip1:             2nd ( 95) byte of above, as an integer.
$S.ip2:             3rd ( 44) byte of above, as an integer.
$S.ip3:             4th ( 22) byte of above, as an integer.
$S.type:            Type of associated socket: stream (:tcp) vs
		    console (:tty) vs batch-file (:bat) vs dead (:eof)...
$S.outdrainMilliseconds These five properties implement timeouts used
$S.eofwaitMilliseconds  internally by the implementation when closing
$S.hupwaitMilliseconds  down a socket.  I don't know why you'd need to
$S.killwaitMilliseconds fiddle with them, but if you do, see the comments
$S.indrainMilliseconds  and transition diagram in the muq/c/skt.t file.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

You must own the socket, or be root running @sc{omnipotent},
to read @code{$S.fdToRead}, @code{$S.fdToRead},
@code{$S.thisPort}, @code{$S.thatPort}, or @code{$S.thatAddress}.

Possible values for @code{$S.type} are:

@table @strong
@item :batch
Socket reading batch-mode from a list of host files.
@item :tty
Socket representing a unix-level terminal (originating console).
@item :tcp
Socket representing a @sc{tcp/ip} byte-stream network connection.
@item :udp
Socket representing a @sc{udp} datagram network socket.
@item :ear
Socket listening for new connections.
@item :popen
Socket connected via pipe(s) to a popen()'d host process.
@item :eof
Socket which has been closed (or never opened).
@end table

The @sc{telnet} processing triggered by setting
@code{socket$S.telnetProtocol} to @sc{t}
collapses @code{0xFF 0xFF}
bytepairs from the net to single @code{0xFF}
bytes and does the reverse when sending to
the net.  In addition, @sc{telnet} protocol
commands recieved from the net (marked by
an @code{0xFF} byte followed by something
other than a second @code{0xFF} byte) are
sent to the @code{socket$S.outOfBandOutput}
stream instead of the @code{socket$S.standardOutput}
(if @code{socket$S.outOfBandOutput} is set to
a stream) and any text written to the
@code{socket$S.outOfBandInput} stream is
merged into the output bytestream.

@xref{]listenOnSocket}.  @xref{makeSocket}.
@xref{]openSocket}.  @xref{]closeSocket}.

@c
@node Class Stack, Class StructureDefinition, Class Socket, Muq Classes
@section Class Stack
@cindex Class Stack
@cindex Stack Class

Class Stack, like Class Stream, is not part of the Muq
security kernel, but rather merely a generic facility
provided to support muf programming.  It seemed odd to
provide several specialized stack classes but no generic
one; Failing to provide a generic one would invite abuse of
the specialized ones.

Class Stack adds the following properties to those of Class Plain:

@example
$S.vector:   The vector used to actually hold the stack contents.
$S.length:   The current number of occupied slots in the stack.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

Note: Class stack may eventually be merged with the array
classes, since CommonLisp one-dimensional arrays support
stack pointers.

@xref{makeStack}.
@xref{push}.  @xref{pull}.
@xref{length}. @xref{reset}.

@c
@node Class StructureDefinition, Class System, Class Stack, Muq Classes
@section Class StructureDefinition
@cindex Class StructureDefinition
@cindex StructureDefinition Class

Class StructureDefinition instances hold the information defining
a particular type of user-defined structure.

Class StructureDefinition adds the following properties to those of Class Plain:

@example
$S.compiler              Parallel to function$s.compiler
$S.source                Parallel to function$s.source
$S.fileName             Parallel to function$s.fileName
$S.fnLine               Parallel to function$s.fnLine
$S.slotCount            Count of slots in structure.
$S.include               Parent structure-definition or nil.
$S.assertion             Type verification compiledFunction.
$S.predicate             Type check compiled-funciton.
$S.printFunction        Print function.
$S.concName             Prefix for accessor functions.
$S.constructor           Constructor compiledFunction.
$S.copier                Copier compiledFunction.
$S.type                  'vector 'list or nil
$S.named                 t or nil
$S.initialOffset        whole number
$S.export                NIL unless defstruct included :export t option.
$S.createdAnInstance   NIL unless an instances has been created.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

Note: Proper support for the CommonLisp meta-class protocol,
when it is finalized, may require changes to this class.

@c
@node Class System, Class User, Class StructureDefinition, Muq Classes
@section Class System
@cindex System Class
@cindex Class System

Rather than provide a host of obscure primitives for reading
and modifying host system configuration parameters, Muq
provides Class System, the properties of which display these
parameters.  Configuration parameters may thus be configured
via the normal property-setting primitives.

There is normally only one instance of Class System in the db,
available as @code{.sys}.

Reading and modifying the muq-server configuration is done
via a separate class.  @xref{Class Muq}.

Class System adds the following properties to those of Class Plain:

@example
$S.pageSize:    Host page size in bytes.
$S.pid:          Process id of server on host unix.

$S.hostName:    Hostname as returned by unix gethostname() function.
$S.dnsName:     Fully qualified Domain Name System name for host.
$S.dnsAddress:  Dotted-decimal Domain Name System address for host.
$S.ip0:          First  byte of host IP address, as an integer.
$S.ip1:          Second byte of host IP address, as an integer.
$S.ip2:          Third  byte of host IP address, as an integer.
$S.ip3:          Fourth byte of host IP address, as an integer.
$S.muqPort:     Base port for server and port for server's muqnet daemon.

$S.millisecsSince1970:    System time.
$S.dateMicroseconds:  Additional precision for above.

$S.usermodeCpuSeconds:  As reported by unix for server.
$S.usermodeCpuNanoseconds:  As reported by unix for server.
$S.sysmodeCpuSeconds:   As reported by unix for server.
$S.sysmodeCpuNanoseconds:   As reported by unix for server.
$S.maxRss:   As reported by unix for server.
$S.pageReclaims:   As reported by unix for server.
$S.pageFaults:   As reported by unix for server.
$S.swapOuts:   As reported by unix for server.
$S.blockReads:   As reported by unix for server.
$S.blockWrites:   As reported by unix for server.
$S.voluntaryContextSwitches:   As reported by unix for server.
$S.involuntaryContextSwitches:   As reported by unix for server.
$S.endOfDataSegment:   As reported by unix for server.
@end example

Note: For convenience, the $S properties are also available in the public (default)
propdir.

@c
@node Class User, Muq Object Efficiency Considerations, Class System, Muq Classes
@section Class User
@cindex Class User
@cindex User Class

Class User instances are intended to represent one real-life
human each, in general, and to be the fundamental unit of
accounting in the system.  Muq tracks the number of bytes
used on a per-User basis, imposes quotas of various sorts on
a per-User basis, and so forth.

Class User is @emph{not} intended to be the unit of
"presence" in a virtual world, because Muq is not intended
to be that tightly specialized to mudding, because a single
user may reasonably wish to have multiple points of presence
in the virtual world, because it may be desirable to have
points of presence not directly controlled by any user ---
robots and such --- and because in general it seems good
separation of concerns.  Thus, virtual presence is handled
by separate avatar objects.

Class User adds the following properties to those of Class Plain:

@example
$S.breakDisable:   Value of @@$s.breakDisable at login.
$S.breakEnable:    Value of @@$s.breakEnable at login.
$S.breakOnSignal: Value of @@$s.breakOnSignal at login.
$S.byte-quota:      Max bytes of db the user may have.
$S.bytes-owned:     Bytes of db user currently uses.
$S.dbrefConvertErrors:	Count maintained by ints3ToDbref.
$S.debugger:        Default @@$s.debugger at login.
$S.defaultPackage: Value for "current package" at login.
$S.doing:          Text field for human @@doing display.
$S.doBreak:        Default @@$s.break at login.
$S.doNotDisturb:   t/nil field for human @@who display.
$S.doSignal:       Default @@$s.doSignal at login.
$S.email:          "me@@my.com" or such.
$S.group            Currently undefined, intended for shared ownership.
$S.haltQueue:      Job queue for halted jobs.
$S.homepage:       "http://my.com/me" or such.
$S.lib:             List of known packages for user.
$S.loginHints:     NIL, else object with string-valued hint properties.
$S.objectQuota:    Max number of objects user may possess.
$S.objectsOwned:   Current number of objects owned.
$S.pauseQueue:     Job queue for paused jobs.
$S.pgpKeyprint:    PGP Key fingerprint.
$S.psQueue:        Job queue for all active jobs owned by user.
$S.runQueue0:     Job queue for running high-priority jobs.
$S.runQueue1:     Job queue for running normal-priority jobs.
$S.runQueue2:     Job queue for running low-priority jobs.
$S.shell:	    Default shell at login.
$S.telnetDaemon:   Default telnet handler at login, usually telnet:start.
$S.textEditor:	    User's preferred text editor.
$S.timeSlice:	    Incremented monotonically by scheduler.
$A.encryptedPassphrase As in unix: One-way encrypted passphrase as a string.
.www		    Support for user homepage on the WWWeb.
$S.gagged           NIL, else object listing Guests/Users gagged by this user.
$S.rank             Integer rank used for conflict resolution.
$S.nickName         Max 16 chars of text nickname.
$S.longName         Diffie_Hellman public key.	
$S.trueName         Diffie_Hellman private key.	
$S.hashName         61-bit (i.e., positive fixnum) hash of longName.
$S.sharedSecrets    Shared Diffie_Hellman secrets indexed by hashName.
$S.lastLongName     Last value of longName.
$S.lastTrueName     Last value of trueName.
$S.lastHashName     Last value of hashName.
$S.lastSharedSecrets Last value of sharedSecrets.
$S.originalNickName nickName value on home server.
$S.dateOfLastNameChange Last time longName/trueName/hashname were rotated.
$S.packetPreprocessor    Future support for compression and/or encryption.
$S.packetPostprocessor   Future support for decompression and/or decryption.
$S.firstUsedByMuqnet     Future administration support.
$S.lastUsedByMuqnet      Future administration support.
$S.timesUsedByMuqnet     Future administration support. 
$S.ip0              These give last known IP address of this
$S.ip1              user.  Mainly useful for guest (remote) users,
$S.ip2              but for simplicity we
$S.ip3              use identical records for
$S.port             local and guest users.
$S.ioStream         Last known I/O stream on which user was communicating.
$S.userServer0  Muqserver which should known user's current location.
$S.userServer1  Muqserver which should known user's current location.
$S.userServer2  Muqserver which should known user's current location.
$S.userServer3  Muqserver which should known user's current location.
$S.userServer4  Muqserver which should known user's current location.
$S.userVersion  Incremented each time location changes.
$S.userServer1NeedsUpdating NIL or date of last update attempt.
$S.userServer2NeedsUpdating NIL or date of last update attempt.
$S.userServer3NeedsUpdating NIL or date of last update attempt.
$S.userServer4NeedsUpdating NIL or date of last update attempt.
$S.hasUnknownUserServer Non-NIL iff one of userServer[0-4] not in .folkBy.hashName.
$S.dateAtWhichWeLastQueriedLocationServers  To help avoid thrashing them.
@end example

@c
@node Muq Object Efficiency Considerations, Muq Events, Class User, Muq Classes
@section Muq Object Efficiency Considerations
@cindex Object efficiency (space and time).
@cindex Efficiency of objects (space and time).

Objects viewed a collections of named properties constitute
one of the central Muq metaphors.  In slightly mathematical
terms, a Muq object implements an enumerated function: Given
a key, it returns the corresponding value.  I have tried to
make this functionality as general as efficiently practical,
by allowing use of arbitrary Muq data items as both keys and
values.

Since objects and their properties are likely to dominate
both the space and time efficiency of many Muq computations,
I have attempted to make them reasonably efficient on both
dimensions.

Since it is my understanding that human factors studies have
shown that users prefer predictable to erratic response
times, even at the cost of somewhat higher average response
time if need be, I have tried to avoid algorithms which buy
good performance for many cases at the cost of
catastrophically bad performance for other cases.

Muq properties are implemented internally via a two-tiered
mechanism in which built-in properties for a given class are
stored in statically allocated slots within the object
record itself (this avoids storing the property name for
these properties on each object, and also allows C code to
access these values via fast C pointer/structure operations)
while user-defined properties are stored in separate propdir
trees.

In the interests of presenting a simple, consistent
programming model, these two classes of properties are, as
far as practical, merged into a single set as far as the muf
programmer is concerned.  The difference emerges now and
then, however: For example, built-in properties cannot be
deleted from an object.

Niklaus Wirth has observed that, while binary trees are
often not the top performer by a given measure, they are
usually in the top three.  In particular, they tend not to
have catastrophically bad worst cases.

After studying the problem awhile, I concluded that
array-based solutions such as hashtables are inappropriate
due to abuse of the virtual memory subsystem: fetching one
property from a hashtable holding a million or so can
require reading in an arbitrarily large array, for example,
yielding an arbitrarily bad worst case.  Similarly,
large-fanout trees suffer from needlessly slow lookup times
when the tree fits entirely in memory.  Finally, most trees
suffer from the problem of excessive space wasted in null
pointers: the typical binary tree has half its pointer field
empty at any given time, which is not good if they are
dominating our diskspace usage.

The Muq solution is a hybrid 2-3 tree with fat leaves
containing approximately 6-12 key/val pairs.  This has
the following advantages:
@itemize @bullet
In a large propdir, the space used is very little more than
the logical minimum of 8 bytes per keyVal pair.

In a large propdir of which only a small fraction of the values
are being used, most of the tree can sit on disk.

When reading sequentially through a large propdir, keyVal
pairs are read from disk in batches of 6-12, a significant
performance advantage over hitting disk for each pair.

In a small propdir, all the keyVal pairs are stored in a
single linear block, which can be searched linearly.  Linear
search tends to be faster than binary search up to table
sizes of a couple dozen entries.

In a large propdir, the number of key comparisons needed to
find a given key is never too far from the binary-tree
minimum.  (Only hashtables and radix sort variants thereof
can improve on the balanced-binary-tree minimum, and they
have severe disadvantages in this context.)

The 2-3 trees are a balanced tree type, hence cannot
degenerate to a linear-lookup worst case, as naive binary
trees (for example) can: logarithmic lookup time is
guaranteed.
@end itemize

The take-home lessons for the muf programmer are:

@itemize @bullet
@item
That lookup of a key on an object can be assumed to take
about a dozen key comparisons, give or take a factor of two,
which is slow compared to vector or local variable access,
but effectively almost constant independent of number or
kind or key stored on an object, for most practical
purposes.

@item
That each keyVal pair stored on an object can be taken as
taking about eight bytes of db space, independent of number
of keys stored on an object.

@item
That very large numbers of properties may be stored on a
single object if desired, without untoward penalties in
space or time performance: There should be no need to code
specially to avoid use of large numbers of properties.  For
example, keeping all system mail on one object will not spam
the system horribly every time one person checks mail, as is
the case on many other servers.  (I personally think that to
be an ugly way to implement a mail system, but that is a
separate issue!)
@end itemize

Note: In retrospect, I believe the 2-3 tree component was a
mistake due to an analytical hallucination; A future release
is likely to switch to more conventional B-trees.

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
