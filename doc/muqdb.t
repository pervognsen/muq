@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muq Db Layout, Muq Db Layout Overview, Crash Recovery Wrapup, Top
@chapter Muq Db Layout

@menu
* Muq Db Layout Overview::
* Muq Path Notation::
* Muq Path Commands::
* .err::
* .env::
* .etc::
* .lib::
* .sys::
* .u::
* .who::
@end menu
@c -*-texinfo-*-

@c {{{ Muq Db Layout Overview                                   

@node Muq Db Layout Overview, Muq Path Notation, Muq Db Layout, Muq Db Layout
@section Muf Db Layout Overview

Muq objects are usually viewed as sets of key-value pairs.

For example, at the MUF shell prompt you may list all the
public key-val pairs in the root User by doing:

@example
root:
.u["root"] ls
root:
@end example

There is an obvious analogy to Unix directories, which are
also sets of key-val pairs, albeit restricted to string
keys and file/directory values.

The unix filesystem has also proved a quite flexible and
effective tool for first-order organizing of user files in a
multiuser system with dozens to thousands users managing
thousands to millions of files.

Therefor, in the spirit of not requiring users to learn
idiosyncratic new mechanisms when familiar ones will do the
job nicely, Muq uses the unix path/directory metaphor as the
primary high-level organizing principle of the db.

Most of the directories described below are recreated
automatically by the server at startup if they are not
found, since they are essential to its operation.

@c {{{endfold}}}
@c {{{ Muq Path Notation                                        

@node Muq Path Notation, Muq Path Commands, Muq Db Layout Overview, Muq Db Layout
@section Muq Path Notation
@cindex Muq path notation.
@cindex Public properties on an object.
@cindex Hidden properties on an object.
@cindex System properties on an object.
@cindex Admins properties on an object.
@cindex Namespaces on objects.
@cindex Objects, namespaces on.
@cindex . function.
@cindex ./k syntax.
@cindex me function.
@cindex me.k syntax.
@cindex @@ function.
@cindex @@.k syntax. (Public namespace.)
@cindex . function.
@cindex .k syntax.
@cindex @@$s.k path syntax. (System namespace.)
@cindex @@$h.k path syntax. (Hidden namespace.)
@cindex @@$a.k path syntax. (Admins namespace.)
@cindex @@$m.k path syntax. (Method namespace.)
@cindex O.k syntax.
@cindex O[k] syntax.
@cindex O:k syntax.
@cindex O::k syntax.
@cindex Object-oriented programming in Muf.
@cindex Prototype-oriented programming in Muf.
@cindex Muf object-oriented programming.
@cindex Muf prototype-oriented programming.

Muq path notation is deliberately modelled on the very
successful unix filesystem path notation, which also appears
to be well on its way to becoming a major Internet notation
courtesy of WorldWideWeb/Mosaic's Uniform Resource Locators
(URLs).

However, Muq path notation uses '.' as the path separator
(following the lead of C, Java, Perl and Tcl) rather than '/'
as in Uhix. 

A valid muq path may begin with any of the following
character sequences, with the indicated meaning:

@example
.    The "root object", that serving as global origin.
@@.   The currently running job.
me.   The "acting user" for the currently running job.
abc. The value of the symbol "abc" in the current package.
@end example

Given any valid path designating an object 'o' with a public
key 'k' having value 'v', 'o.k' is a name for 'v'.  For example:

@example
.x          Public property 'x' on the root object.
@@.x         Public property 'x' on the currently running job.
me.x         Public property 'x' on the "acting user" for current job.
abc.x       Public property 'x' on the value of symbol "abc" in current pkg.
@end example

The above path-building process may be continued indefinitely:

@example
.q.Cynbe        The object stored as 'Cynbe' in the root directory 'q'.
.q.Cynbe.tmp    The object stored as 'tmp' on the above object.
.q.Cynbe.tmp.x  The object stored as 'x' on the above object.
@end example

Muq's key-access security mechanism is more closely related
to traditional tinymuck than to that of unix, partly because
the full unix system seemed too expensive in space.  Muq
actually provides four separate keyVal namepaces on each
object:

@example
A @dfn{public namespace} which is owner-writeable and world-readable.
A @dfn{hidden namespace} which is only owner-readable and writeable.
A @dfn{system namespace} which is root-writable and owner-readable.
A @dfn{admins namespace} which is only admins-readable and writable.
@end example

Muq provides special path notation syntax for accessing key-value pairs in
each of these namespaces:

@example
me.x   Access public property "x" on the acting user.
me$hidden.x  Access hidden property "x" on the acting user.
me$system.x Access system property "x" on the acting user.
me$admins.x Access admins property "x" on the acting user.
me$method.x Access method property "x" on the acting user.
@end example

The @code{$hidden}, @code{$system}, @code{$admins}, 
and @code{$method} suffixes may be applied to any valid
nonleaf object designator in a path:

@example
myObj$hidden.key
.$admins.key
@@$hidden.key
.etc$hidden.key
myObj$hidden.someKey$method.myMethod
@end example

Each suffix may be abbreviated to its three-letter or
one-letter any prefix, and is case sensitive.
Thus, the following are all equivalent:

@example
obj$system.key
obj$sys.key
obj$s.key
@end example

You may not use such a suffix on a leaf object designator,
because Muq has no way of actually returning a pointer
to part of an object as the result of an expression.
Thus, the following are all @emph{incorrect}:

@example
myObj$hidden
.$admins
@@$hidden
.etc$hidden
myObj$hidden.someKey$method
@end example

Public properties are intended to be the most commonplace,
hence are given the shortest path notation.

Hidden properties are intended to provide private storage
for information an individual user does not wish to make
publicly available, such as perhaps loveletter collections
or email addresses.

System properties are intended to provide storage for
properties controlled by the system but of interest to
the owner of the object:  Db space quotas, for example.

Admins properties are intended to provide storage for
properties associated with the user or object but private to
the system administrators, such as perhaps confidential
gripes registered against the user.  (It is desirable to
store such on the user in order to ensure that they get
recycled when the user does.)

Muq has also supports the syntax

@example
x[y]
@end example

@noindent
which returns the value on object 'x' of the property found
in variable 'y': Think of the syntax as doing array
indexing.  (Both local variables and symbols may be used in
this way.)  Contrast the above example with

@example
x.y
@end example

@noindent
in which 'y' is the literal property name, rather than the
name of a variable holding the property:

@example
tmp:
makeIndex --> o
tmp:
"x" --> key
tmp:
12 --> o[key]
tmp:
13 --> o.y
tmp:
o[key]
tmp: 12
pop o.y
tmp: 13
@end example

The bracket notation is also useful with various
kinds of constants:

@example
x[1]            NOT the same as x.1 !
x[1.0]          NOT the same as x.1.0 !
x["a"]          NOT the same as x."a" !
@end example

The differences above lie in the fact that the @code{x.yyy} syntax
always treats @code{yyy} as the name of a keyword, even if it looks like
an integer or float or whatever, whereas @code{x[1]} will use as key the
integer @code{1}, @code{x[1.0]} will use as key the floating pointer
value @code{1.0}, and @code{x["a"]} will use as key the string (not
keyword) @code{"a"}.

You may actually use any valid path inside the brokets:

@example
x[y[z]]
x[pkg:sym]      
x[pkg:sym.k]
@end example

As a final wrinkle, CommonLisp package notation is
supported: @code{pkg:sym} may be used to refer to the value
of exported symbol @code{sym} in package @code{pkg}, and
@code{pkg::sym} may be used to refer to the value of
internal symbol @code{sym} in package @code{pkg}.

The above syntactic operators may be fairly freely mixed,
nested and cascaded to produce monstrosities such as

@example
mud:world$s.creator[tmp::name[i]] --> tickle:list[tmp::name[i]]
@end example

@noindent
Experiment.

Note: Constant components of pathnames are keywords.
Thus, @code{obj.key} is equivalent to @code{obj :key get},
@emph{not} to (say) @code{obj "key" get}.

@

@c {{{endfold}}}
@c {{{ Muq Path Commands

@node Muq Path Commands, .err, Muq Path Notation, Muq Db Layout
@section Muq Path Commands

Here we list together a few of the commands most commonly useful
when manipulating the Muq path hierarchy.  They correspond
loosely to Unix shell commands such as @code{ls} @code{mkdir}
@code{rm} and so forth.

@
@itemize @bullet
@item
Creating a new object in the hierarchy, in the spirit of unix
'mkdir', in this case a '.myApp' under '.etc':

@example
root:
makeIndex --> .etc.myApp
root: 
@end example

@item
Storing arbitrary new public values on an object in the hierarchy,
in the spirit of creating files in the unix hierarchy:

@example
root:
t --> .etc.myApp.allowFoozling
root: 
nil --> .etc.myApp.allowMarfling
root: 
@end example

@item
Listing the public values on such an object:

@example
root: 
.etc.myApp ls
:allowMarfling  nil
:allowFoozling  t
root: 
@end example

@item
Storing hidden (private to root) new public values on an object in the hierarchy,
in the spirit of creating files "rw-------" files in the unix hierarchy:

@example
root:
t --> .etc.myApp$hidden.dominateWorld
root: 
nil --> .etc.myApp$hidden.useDos
root:
@end example

@item
Listing the hidden values on such an object:

@example
root: 
.etc.myApp lsh
:useDos nil
:dominateWorld  t
root:
@end example

@item
Listing the system values on such an object:

@example
root: 
.etc.myApp lss
:dbname "ROOTDB"
:isA    #<MosClass Object 209fa15>
:myclass        "obj"
:owner  #<Root root 2c015>
:name   "_"
root: 
@end example

@item
Set a system value on such an object:

@example
root: 
".etc.myApp" --> .etc.myApp$system.name
root: 
.etc.myApp lss
:dbname "ROOTDB"
:isA    #<MosClass Object 209fa15>
:myclass        "obj"
:owner  #<Root root 2c015>
:name   ".etc.myApp"
root: 
@end example

@item
Add and list some admins values on such an object:

@example
root: 
t --> .etc.myApp$admins.thisIsJunk
root: 
nil --> .etc.myApp$admins.saveThis
root: 
.etc.myApp lsa
:saveThis       nil
:thisIsJunk     t
root: 
@end example

@item
Remove admins properties, similar to unix "rm":

@example
root: 
.etc.myApp lsa
:saveThis       nil
:thisIsJunk     t
root: 
delete: .etc.myApp$admins.thisIsJunk
root: 
.etc.myApp lsa
:saveThis       nil
root: 
@end example

@item
Remove a public property:

@example
root: 
.etc.myApp ls
:allowMarfling  nil
:allowFoozling  t
root: 
delete: .etc.myApp.allowMarfling
root: 
.etc.myApp ls
:allowFoozling  t
root: 
@end example

@item
Remove a hidden property:

@example
root: 
.etc.myApp lsh
:useDos nil
:dominateWorld  t
root: 
delete: .etc.myApp$hidden.useDos
root: 
.etc.myApp lsh
:dominateWorld  t
root: 
@end example

@item
Removing an object.
In unix, removing a directory is different from removing
a file, but in MUF they are just the same:

@example
root: 
.etc ls
:rc2D   #<Object .etc.rc2D b9e015>
:server-signature       2984392281243
:bad    #<thunk BAD>
:jb0    #<Job jb0 33115>
:doz    #<JobQueue doz 17ea1e15>
:usr    #<UserQueue usr 2929ed15>
:rc2    'muf:rc2
:myApp  #<Object .etc.myApp 4d1dd15>
root: 
delete: .etc.myApp
root: 
.etc ls
:rc2D   #<Object .etc.rc2D b9e015>
:server-signature       2984392281243
:bad    #<thunk BAD>
:jb0    #<Job jb0 33115>
:doz    #<JobQueue doz 17ea1e15>
:usr    #<UserQueue usr 2929ed15>
:rc2    'muf:rc2
root: 
@end example

@end itemize

@c {{{endfold}}}
@c {{{ .env                                                     

@node .err, .env, Muq Path Commands, Muq Db Layout
@section .err

The .err directory contains all server-predefined events.

The name is a bit misleading in that the events in it
are not all errors, but I got sick of typing
@code{.event} all the time and switched to the shorter
@code{.err}.

@example
root: 
.err ls
:typeError      #<MosClass typeError 211fb00026c1ef15>
:streamError    #<MosClass streamError 211fb0002411cc15>
:simpleError    #<MosClass simpleError 211fb0002581e815>
:programError   #<MosClass programError 211fb00025d9c615>
:packageError   #<MosClass packageError 211fb0002261e315>
:fileError      #<MosClass fileError 211fb0002319c015>
:controlError   #<MosClass controlError 211fb00023b9dc15>
:cellError      #<MosClass cellError 211fb00020d9f915>
:arithmeticError        #<MosClass arithmeticError 211fb0002169d615>
:printJobs      #<MosClass printJobs 211fb0002189db15>
:warning        #<MosClass warning 211fb00021e9f915>
:simpleEvent        #<MosClass simpleEvent 211fb0002249d615>
:seriousEvent       #<MosClass seriousEvent 211fb0002099f315>
:undefinedFunction      #<MosClass undefinedFunction 211fb0002741fb15>
:unboundVariable        #<MosClass unboundVariable 211fb00027a1d815>
:floatingPointUnderflow #<MosClass floatingPointUnderflow 211fb0002821e415>
:floatingPointOverflow  #<MosClass floatingPointOverflow 211fb0002881c115>
:divisionByZero #<MosClass divisionByZero 211fb00028e1de15>
:event      #<MosClass event 211fb00020f9ce15>
:urgentCharacterWarning #<MosClass urgentCharacterWarning 211fb0002469f315>
:writeToDeadStreamWarning       #<MosClass writeToDeadStreamWarning 211fb0000be1d015>
:readFromDeadStreamWarning      #<MosClass readFromDeadStreamWarning 211fb0001f91ed15>
:brokenPipeWarning      #<MosClass brokenPipeWarning 211fb0002501ca15>
:simpleWarning  #<MosClass simpleWarning 211fb0002361e615>
:simpleTypeError        #<Eventx simpleTypeError 4c9cf15>
:endOfFile      #<MosClass endOfFile 211fb0002601f515>
:storageEvent       #<MosClass storageEvent 211fb00023c1ff15>
:kill   #<MosClass kill 211fb0002421de15>
:error  #<MosClass error 211fb0002281fd15>
:debug  #<MosClass debug 211fb00022d9dd15>
:abort  #<MosClass abort 211fb0002339fc15>
:serverError    #<MosClass serverError 211fb0002661d215>
root: 
@end example

@c {{{endfold}}}
@c {{{ .env                                             

@node .env, .etc, .err, Muq Db Layout
@section .env

The .env directory contains the complete environment
inherited by the server at startup: .env["HOME"] will return
the unix home directory of the server, for example.

This information is initialized at server startup,
and may be inhibited by the @code{--no-environment}
commandline switch.

@example
root:
.env ls
"AVS_PATH"      "/usr/avs"
"HUSHLOGIN"     "FALSE"
"GNUTERM_TITLE" "Skandha4"
"INFOPATH"      ":/usr/info"
"SSH_AUTH_SOCK" "/tmp/ssh-cynbe/agent-socket-272"
"HOSTTYPE"      "i386-linux"
"COLUMNS"       "80"
"CVSROOT"       "/src/master"
"DISPLAY"       ":0.0"
"EDITOR"        "emacs"
"EMACS" "t"
"GNUTERM"       "opengl"
"GROUP" "cynbe"
"HOME"  "/usr/home/cynbe"
"HOST"  "chee"
"HZ"    "100"
"WINDOWID"      "46137363"
"LANG"  "C"
"LOGNAME"       "cynbe"
"MAIL"  "/var/spool/mail/cynbe"
"MUQDIR"        "/usr/home/cynbe/muq/bin"
"OSTYPE"        "linux"
"GNUTERM_POSITION"      "350,350"
"PATH"  "/usr/home/cynbe/bin:/usr/bin/X11:/usr/bin/X11:/usr/home/cynbe/muq/bin:/bin:/usr/bin"
"PRINTER"       "vastus"
"PWD"   "/usr/home/cynbe/muq/c"
"MUQ_GZIP"      ""
"SHELL" "/bin/tcsh"
"SHLVL" "5"
"TERM"  "dumb"
"TMPDIR"        "/usr/home/cynbe"
"GNUTERM_SIZE"  "200,200"
"USER"  "cynbe"
"VENDOR"        "intel"
"SSH_AGENT_PID" "291"
"_"     "/usr/bin/X11/xterm"
"MACHTYPE"      "i386"
"HOSTNAME"      "chee"
"MESA_DEBUG"    ""
root: 
@end example

@c {{{endfold}}}
@c {{{ .etc                                                     

@node .etc, .lib, .env, Muq Db Layout
@section .etc

The .etc directory is intended to contain random
system-related stuff, much like the unix .etc directory.

@example
root: 
.etc ls
:rc2D   #<Object .etc.rc2D b9e015>
:serverSignature        2984392281243
:bad    #<thunk BAD>
:jb0    #<Job jb0 33115>
:doz    #<JobQueue doz 17ea1e15>
:usr    #<UserQueue usr 2929ed15>
:rc2    'muf:rc2
root: 
@end example

Comments:

@example
.etc.rc2  Program used to start up internal daemons in daemon mode.
.etc.rc2D Daemons to start up in daemon mode. (Compare unix /etc/rc2.d)
.etc.usr  Queue of all users with running jobs.
.etc.doz  Job queue for sleeping jobs.
@end example

@code{.etc.jb0} is an internal hack to avoid lots of special-case code
by ensuring that there is alway a valid "current job" while the server
is running, and hence an "acting user," "current object" and so forth.
Lots of server code expects this for bookkeeping purposes and such.

@c {{{endfold}}}
@c {{{ .lib                                                     

@node .lib, .sys, .etc, Muq Db Layout
@section .lib

The @code{.lib} directory contains all packages published for
use by all users.  When a @sc{muf} user types a qualified symbol name
such as @code{dict:nouns} the compiler looks for the named package
("dict") first in the user's private list of known packages
(@code{me$system.lib}) and then in @code{.lib} which serves as
the public system-wide list of known packages.

@example
root: 
.lib ls
"dict"	#<Package dict a6c900000020315>
"keyword"	#<Package keyword 1af5c00000020115>
"lisp"	#<Package lisp 1db2b00000020115>
"muf"	#<Package muf 211fb00000020115>
"muqnet"	#<Package muqnet 2a1c600000020115>
"oldmsh"	#<Package oldmsh 2542d80000020315>
"oldmud"	#<Package oldmud 2544680000020315>
"task"	#<Package task 3035080000020315>
"telnet"	#<Package telnet 312bb00000020315>
root: 
@end example

@c {{{endfold}}}
@c {{{ .sys                                                     

@node .sys, .u, .lib, Muq Db Layout
@section .sys

The .sys directory is conventionally an instance of Class
System, and provides an interface to tuning parameters and
performance statistics from the unix kernel and the Muq
server.  This directory is not needed for correct
functioning of the system.

@example
root: 
.sys ls
:dbname	"ROOTDB"
:isA	#<MosClass SystemInterface 2a9d615>
:myclass	"sys"
:owner	#<Root root 2c015>
:name	"/sys"
:dnsAddress	"205.179.182.82"
:dnsName	"chee.muq.org"
:hostName	"chee"
:endOfDataSegment	136269824
:involuntaryContextSwitches	0
:voluntaryContextSwitches	0
:blockWrites	0
:blockReads	0
:swapOuts	0
:pageFaults	579
:pageReclaims	825
:maxRss	0
:sysmodeCpuSeconds	0
:sysmodeCpuNanoseconds	170000000
:usermodeCpuSeconds	0
:usermodeCpuNanoseconds	210000000
:dateMicroseconds	35738
:millisecsSince1970	933275637036
:pid	18794
:pageSize	4096
:ip3	82
:ip2	182
:ip1	179
:ip0	205
:muqPort	30000
root: 
@end example

@c {{{endfold}}}
@c {{{ .u                                                       

@node .u, .who, .sys, Muq Db Layout
@section .u

The .u directory is intended to hold all User instances in
the db.  It serves as an index of all valid user accounts
on the server.  It should always contain .u["root"] (the special user
owning the core). 


@c {{{endfold}}}
@c {{{ .who                                                     

@node .who, Exporting Muq, .u, Muq Db Layout
@section .who

The .who directory is intended to hold all User instances
currently logged onto the server.  It is expected that
analogues to the unix "who" command will eventually function
simply by scanning this directory, hence the name.

(Again, this arrangement is tentative and subject to
revision in future releases.  Also nonfunctional as of
release -1.0.0.)

@c {{{endfold}}}

@c --    File variables                                                 */

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
