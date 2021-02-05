@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Invoking Muq, Invoking Muq Overview, Muq Installation Wrapup, Top
@chapter Invoking Muq

@menu
* Invoking Muq Overview::
* Muq Commandline Options::
* Bootstrap Shell Overview::
* 00-muf.muf Shell Overview::
@end menu
@c -*-texinfo-*-

@c {{{ Invoking Muq Overview					

@node Invoking Muq Overview, Muq Commandline Options, Invoking Muq, Invoking Muq
@section Invoking Muq Overview
@cindex Invoking Muq
@cindex Muq, invoking
@cindex Running Muq
@cindex Muq, running
@cindex Bug reports
@cindex Reporting bugs
@cindex Muq bugs, reporting

My usual routine is to do
@example
cd ~/muq/c
make muq
muq-db-c
./muq
@end example
@noindent
Where of course all but the last may be skipped if you
have done them already.

If Muq crashes somehow on you, it will leave a trashed db
behind, and will refuse to run with it on next invocation.
I merely do "rm -rf vm0" in this case, and then "./muq".

Needless to say, I'd like to hear about such crashes:
Please email to cynbe@@muq.org or muq@@muq.com.

Muq version -1.40.0 defaults to running the db out of a 2Meg
ram buffer.  This should be a reasonable choice for learning
and playing with small dbs.  If you want to use a different
buffer size, you may do "muq -b 4K" or "muq -b 10M" or such.
You may also permanently change the default buffer size by
redefining @sc{VM_INITIAL_BIGBUF_SIZE} (preferably in
h/Site-config.h) and recompiling.

@c {{{endfold}}}
@c {{{ Muq Commandline Options					

@node Muq Commandline Options, Bootstrap Shell Overview, Invoking Muq Overview, Invoking Muq
@section Muq Commandline Options
@cindex Muq commandline options
@cindex Options, Muq commandline
@cindex Commandline options of Muq
@cindex Ram buffer resizing
@cindex Muq ram buffer, resizing
@cindex Resizing the Muq ram buffer
@cindex Batchmode invocation of Muq
@cindex Invoking Muq in batch mode
@cindex Muq libraries, listing standard
@cindex Listing standard Muq libraries
@cindex Muq selfcheck libraries, listing standard
@cindex Listing standard Muq selfcheck libraries
@cindex Muq version, listing
@cindex Listing Muq version
@cindex Specifying Muq db
@cindex Muq db, specifying
@cindex Muq execution path, specifying
@cindex Specifying Muq execution path

Muq is accumulating the usual forest of commandline options.

For casual use, none of these are likely to be of general
interest at present, but all are used in the various scripts
that come with Muq:

@example
-b 12K   Run with bigbuf size of twelve kilobytes.
-b 4M    Run with bigbuf size of four megabytes. 
-f file  Run the given file in batchmode.
-d       Run as a unix daemon, via muf:initShell and .etc.rc2
-i       Run interactive session.  (Default if no -f switches supplied.)
-m       List all expected optional muf libraries and exit.
-M       List all expected optional muf selfcheck libraries and exit.
-V       List Muq version (e.g., -2.10.0) and exit.
-x pkg:sym Use @emph{pkg:sym} to evaluate any -f files or interactive input.
db       Use @emph{db} (default 'muq') as the muq db prefix for this run.
--destports=80,4096-32000  Which outbound net connects are allowed.
--rootdestports=80,4096-32000  Which outbound net connects are allowed.
  (ALLOWING ALL OUTBOUND PORTS POSES SERIOUS SECURITY PROBLEMS!)
--full-db-check     Do full sanity check even if db looks ok.
--ignore-signature  Run even on db not matching server.
--logfile=xyzzy.log Log to given file.  (Otherwise, no logging.)
--no-environment    Do not load environment into .env.
--no-pid-file       Don't create a muq-vm.pid file.
--log-bytecodes     Start up with .muq$s.logBytecodes == t.
--srvdir=$HOME/muq/srv Override muq/bin/Muq-config.sh srvdir setting.
--dump              Write .muq file to stdout in ascii and exit.
@end example

@noindent
If you want the Muq server to exit at the end of processing a batchfile,
you need to put "rootShutdown" at the end of the file.

Note that setting @sc{VM_INITIAL_BIGBUF_SIZE} in Site-config.h
and is recompiling is preferable to using option -b: recompiling
results in an appropriately resized hashtable and more efficient
operation.

@strong{Allowing arbitrary outbound network connections can pose
serious security problems!}  For example, it may allow connections to
NFS filesystems on your subnet and modification of them or capture of
passphrase files, or connection to X servers on your subnet and perhaps
capture of keyboard type-in (including passphrases) or insertion of
commands like "rm *" in open shell windows, or forging of email on
your machine.  For these and other reasons, Muq by default allows only
certain fairly safe destination ports.
(@xref{]openSocket,,,mufcore.t,Muf Reference}.)  Think carefully
before relaxing these limitations, and don't relax them further than
you really need to!  @strong{In particular, note that the X Window
System ports are in the range 6000-6063, so doing something like
"--destports=1000-64000" opens up every X server that trusts your
host.}  If you @emph{must} allow access to dangerous ports, consider
doing so only for users running with in-db root privileges, using the
@code{--rootdestports} switch.

Doing @code{--destports=+4000} or @code{--destports=+4000-5000}
will add the given port(s) to the previously allowed set of
ports;  doing @code{--destports=4000} or @code{--destports=4000-5000}
allows only the specified port(s).  There is deliberately no way
to change these settings from in-db, as insurance against the
in-db root accounts being cracked.  The default set of ports
is controlled by @sc{obj_root_allowed_outbound_net_ports} and
@sc{obj_allowed_outbound_net_ports} in @code{c/obj.t} and may
be permanently changed by providing alternate definitions
of them in @code{h/Site-config.h}, touching @code{c/obj.t},
and recompiling.

The @code{security} switch controls the general level of
access to host Unix system from within the Muq server.

@table @var
@item max
No access to host Unix filesystem, other than db file I/O,
creation of the pid file and reading of any @code{-f} files
specified on commandline: No logfile writes, no external
program invocation of any sort, no internally initiated
extern file reading of any sort.

@item high
Very limited access to host Unix filesystem, primarily
the ability to write to the logfile.

@item medium
Somewhat limited access to host Unix filesystem.  Can
read and sometimes write files in designated directories.

@item low
Essentially unlimited access to host Unix filesystem.
Not suitable for public-access servers, but useful
for private Muq hacking.
@end table

Most servers default to @code{high} security, but this
is compileTime configurable, for example by placing

@example
#define OBJ_SECURITY_DEFAULT OBJ_SECURITY_TOP
@end example

in your @file{muq/h/Site-config.h} file and recompiling.

At all security levels, any modification of host filesystem
(beyond routine db I/O) requires root privilege within the
Muq.  However, you should assume that Muq in-db system
programming errors will periodically result in compromise of
internal Muq root privileges on a public server: If security
is an issue, presume that Muq root is controlled by your
most hostile user.

The @code{--quick-start} (or equivalently @code{-q}) switch
bypasses normal sanity checking on the db.  At startup, Muq
by default does the equivalent of Unix @code{fsck},
examining and if need be repairing all essential
datastructures.  This can take awhile:  If you are pretty
confident your db is uncorrupted, you can save time by
bypassing it.

The @code{--no-pid-file} switch prevents the Muq server
from creating (and later removing) a diskfile containing
its process identifier number.  Usually it creates a
file named @file{muq-DB.pid} where @code{DB} is the name
of the database in use, ``vm'' by default.

The @code{--srvdir=directory} switch selects the directory
in which Muq will look for programs to run as subservers,
invokable from in-db.  This is normally muq/srv and normally
specified in muq/bin/Muq-config.sh via the $srvdir variable.
Specifying @code{--srv-dir=} will disable invocation of
subservers, which might be a good security precaution in
some environments.  You should definitely be -very-
cautious about doing something like @code{--srv-dir=/bin},
which would let in-db processes run arbitrary shell commands
with your unix-level privileges.

The @code{-x pkg:sym} switch allows execution of an arbitrary
function as the command or file interpreter at startup.
The @code{pkg} should be in @code{.lib}, the @code{sym}
should be an exported symbol in @code{pkg}, and the
functional value of @code{sym} should be the desired
compiledFunction.


@c {{{endfold}}}
@c {{{ Bootstrap Shell Overview					

@node Bootstrap Shell Overview, 00-muf.muf Shell Overview, Muq Commandline Options, Invoking Muq
@section Bootstrap Shell Overview
@cindex Bootstrap shell
@cindex Shell, bootstrap
@cindex Inserver shell
@cindex Shell, inserver
@cindex zil

When you fire up muq by (say) "./muq", you will by default be left in
the inserver bootstrap muf shell, which identifies itself by printing a
"Root:" prompt and then waiting for input.

The outermost loop of this shell is written in muf (.lib.muf.zil --- see
z-muq.c:assemble_zil()) but the rest is hardcoded in C.

The bootstrap shell repetitively reads input lines until it has a
syntactically complete muf expression, then compiles it into bytecodes
and evaluates it.  Values on the stack are printed after the "Root:"
prompt, with the top of stack to the right.

@c {{{endfold}}}
@c {{{ 00-muf.muf Shell Overview				

@node 00-muf.muf Shell Overview, Muq Dbfiles, Bootstrap Shell Overview, Invoking Muq
@section 00-muf.mf Shell Overview
@cindex In-db shell
@cindex Shell, in-db
@cindex Muf shell
@cindex Shell, muf

@sc{Ignore the following --- in Muq v -1.0.0, the in-db
compiler has been left behind by the cascade of recent
changes and is currently quite broken.}

After firing up muq and landing in the bootstrap shell, you
may invoke the ~/muq/pkg/00-muf.muf shell (assuming you
loaded it) by typing ".lib.muf.muf".  This is an almost
complete re-implementation in muf of the muf compiler, just
coming up to steam in version -2.0, which should look almost
identical except that it uses a "Stack:" prompt instead of a
"boot:" prompt.

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
