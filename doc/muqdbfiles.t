@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muq Dbfiles, Muq Dbfiles Overview, 00-muf.muf Shell Overview, Top
@chapter Muq Dbfiles

@menu
* Muq Dbfiles Overview::
* Muq Dbfile Names::
* Muq Dbfiles Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Muq Dbfiles Overview

@node Muq Dbfiles Overview, Muq Dbfile Names, Muq Dbfiles, Muq Dbfiles
@section Muq Dbfiles Overview

The state for a Muq server is physically stored in a set of files.
For administrative purposes, you do not need to understand the
internal structure of these files, but you do need to understand
their functions and naming conventions.


@c {{{endfold}}}
@c {{{ Muq Dbfile Names

@node Muq Dbfile Names, Muq Dbfiles Wrapup, Muq Dbfiles Overview, Muq Dbfiles
@section Muq Dbfiles Names

A complete Muq server database consists of a set of files with names like

@example
-rw-------   1 cynbe    cynbe        4347 Jul 28 19:58 muq-0000001-DIFI.db.lzo
-rw-------   1 cynbe    cynbe        2435 Jul 28 19:58 muq-0000001-GEST.db.lzo
-rw-------   1 cynbe    cynbe       37864 Jul 28 19:58 muq-0000001-KEYW.db.lzo
-rw-------   1 cynbe    cynbe       29826 Jul 28 19:58 muq-0000001-LISP.db.lzo
-rw-------   1 cynbe    cynbe      290273 Jul 28 19:58 muq-0000001-MUF.db.lzo
-rw-------   1 cynbe    cynbe        2836 Jul 28 19:58 muq-0000001-MUFV.db.lzo
-rw-------   1 cynbe    cynbe        2880 Jul 28 19:58 muq-0000001-QNET.db.lzo
-rw-------   1 cynbe    cynbe        2590 Jul 28 19:58 muq-0000001-QNETA.db.lzo
-rw-------   1 cynbe    cynbe      194207 Jul 28 19:58 muq-0000001-ROOTDB.db.lzo
-rw-------   1 cynbe    cynbe       29113 Jul 28 19:58 muq-0000001-TLNT.db.lzo
-rw-------   1 cynbe    cynbe        3364 Jul 28 19:58 muq-0000001-muqn.db.lzo
-rw-------   1 cynbe    cynbe        4032 Jul 28 19:58 muq-0000002-DIFI.db.lzo
-rw-------   1 cynbe    cynbe        2432 Jul 28 19:58 muq-0000002-GEST.db.lzo
-rw-------   1 cynbe    cynbe       38305 Jul 28 19:58 muq-0000002-KEYW.db.lzo
-rw-------   1 cynbe    cynbe       29881 Jul 28 19:58 muq-0000002-LISP.db.lzo
-rw-------   1 cynbe    cynbe      336268 Jul 28 19:58 muq-0000002-MUF.db.lzo
-rw-------   1 cynbe    cynbe        2837 Jul 28 19:58 muq-0000002-MUFV.db.lzo
-rw-------   1 cynbe    cynbe        2881 Jul 28 19:58 muq-0000002-QNET.db.lzo
-rw-------   1 cynbe    cynbe        2587 Jul 28 19:58 muq-0000002-QNETA.db.lzo
-rw-------   1 cynbe    cynbe      198572 Jul 28 19:58 muq-0000002-ROOTDB.db.lzo
-rw-------   1 cynbe    cynbe       29117 Jul 28 19:58 muq-0000002-TLNT.db.lzo
-rw-------   1 cynbe    cynbe        3365 Jul 28 19:58 muq-0000002-muqn.db.lzo
-rw-------   1 cynbe    cynbe        8517 Jul 28 19:59 muq-CURRENT-ANSI.db.lzo
-rw-------   1 cynbe    cynbe       13165 Jul 28 19:59 muq-CURRENT-DBUG.db.lzo
-rw-------   1 cynbe    cynbe       74900 Jul 28 19:59 muq-CURRENT-DICT.db.lzo
-rw-------   1 cynbe    cynbe        4038 Jul 28 19:59 muq-CURRENT-DIFI.db.lzo
-rw-------   1 cynbe    cynbe        2438 Jul 28 19:59 muq-CURRENT-GEST.db.lzo
-rw-------   1 cynbe    cynbe       50948 Jul 28 19:59 muq-CURRENT-KEYW.db.lzo
-rw-------   1 cynbe    cynbe       29901 Jul 28 19:59 muq-CURRENT-LISP.db.lzo
-rw-------   1 cynbe    cynbe        6002 Jul 28 19:59 muq-CURRENT-LNED.db.lzo
-rw-------   1 cynbe    cynbe      370285 Jul 28 19:59 muq-CURRENT-MUF.db.lzo
-rw-------   1 cynbe    cynbe        2842 Jul 28 19:59 muq-CURRENT-MUFV.db.lzo
-rw-------   1 cynbe    cynbe      112503 Jul 28 19:59 muq-CURRENT-OMSH.db.lzo
-rw-------   1 cynbe    cynbe      250804 Jul 28 19:59 muq-CURRENT-OMUD.db.lzo
-rw-------   1 cynbe    cynbe       13053 Jul 28 19:59 muq-CURRENT-PUB.db.lzo
-rw-------   1 cynbe    cynbe       47174 Jul 28 19:59 muq-CURRENT-QNET.db.lzo
-rw-------   1 cynbe    cynbe        3438 Jul 28 19:59 muq-CURRENT-QNETA.db.lzo
-rw-------   1 cynbe    cynbe       15486 Jul 28 19:59 muq-CURRENT-RMUD.db.lzo
-rw-------   1 cynbe    cynbe      201785 Jul 28 19:59 muq-CURRENT-ROOTDB.db.lzo
-rw-------   1 cynbe    cynbe       29612 Jul 28 19:59 muq-CURRENT-TASK.db.lzo
-rw-------   1 cynbe    cynbe       29119 Jul 28 19:59 muq-CURRENT-TLNT.db.lzo
-rw-------   1 cynbe    cynbe        3367 Jul 28 19:59 muq-CURRENT-muqn.db.lzo
@end example

The naming conventions used are as follows:

@itemize @bullet
@item
The prefix (@code{muq-} in this case) allows multiple Muq servers to run from
the same directory if desired.  The prefix can be specified as a commandline
parameter: @code{muq mydb} if the prefix is @code{mydb-}.

@item
The second component of each filename is the generation.  The
first generation is @code{0000001} and numbers climb consecutively
thereafter, except that dbfiles for the most recent quiescient dbfiles
have a generation "number" of @code{CURRENT} and dbfiles actively in
use by a running Muq server process have a generation "number" of
@code{RUNNING}.  Each backup done (and each server shutdown) generate
one new generation of dbfiles.

@item
The third component of each filename distinguishes the various files
within one generation of one db.  Uppercase names like MUF and DBUG
are system libraries such as the multi-user forth runtimes and
the debugger.  The special name ROOTDB is always the root dbfile
which is loaded first, much like the root partition on Unix.
Lowercase names such as muqn and kim represent individual
user accounts.

Renaming file 'kim' to 'pat' or such will not work in general:
The third field is a human-readable representation of a 21-bit
db identifier which is embedded in all pointers from other
dbfiles into this dbfile, and such a renaming will at best
confuse things.

@item
The fourth component of dbfile names is always @code{.db};  It has
no particular significance other than helping sort out dbfiles
from other random files in the same directory.  The Muq server
only looks for dbfiles with these extensions, however, so you
cannot switch to another and still run Muq on the files.

@item
The last optional component of dbfile names is simply the
extension (@code{.gz} @code{.lzo} or @code{.bz2}) added	
by the compression program in use, if any.
@end itemize

@c {{{endfold}}}
@c {{{ Muq Dbfiles Wrapup

@node Muq Dbfiles Wrapup, Crash Recovery, Muq Dbfile Names, Muq Dbfiles
@section Muq Dbfiles Wrapup
@cindex Muq Dbfiles Wrapup

Other adminstratively useful tidbits of information about Muq dbfile files:

@itemize @bullet

@item
Muq dbfiles are 64-bit throughout on all supported machines, including
Intel/x86.

@item
Muq dbfiles are big-endian or little-endian according to the convention
used by the host machine.  (This is necessary for rational
memory-mapped file sharing.)  Future versions of Muq will automatically
convert between byte orders as needed, but this is not yet implemented.
At present, Muq dbfiles cannot be transported between machines with
different byte sexes.

@item
You will eventually be able to mount and dismouht Muq dbfiles in a
server about as freely as you can mount and dismount disk partitions
in unix.  This is not yet implemented, however.

@item
When the Muq server does backups, all dbfiles are saved at the same
time, and all receive the same generation number.

@item
Beyond the above, the Muq server also keeps "logarithmic" backups:
It attempts to as good an approximation as possible to keep the
most recent second, fourth, eighth, sixteenth and so forth backups.
This provides a scattering of older fallback dbs as insurance
against something being clobbered and not missed for weeks, without
filling up the disk with inordinate numbers of backups.  If you
don't want logarithmic backups to be kept, set the internal Muq
variable @code{.muq.logarithmicBackups} to @sc{nil}.

@item
Once a dbfile receives a numeric
generation number, the Muq server will not touch it again in the course of
normal operations.
(The sole exception being to
delete it when it gets too old, to save disk space.)
You can delete any or all of the numbered backup files at any time
if you like.  Just don't clobber the @code{RUNNING} files if you
care about the current server run, or the @code{CURRENT} files if
you have any ambition to restart from the current point should
the running server crash.

@item
The number of consecutive recent backups kept is controlled by the
internal @code{.muq.consecutiveBackupsToKeep} variable.  Six is
a good number;  Two or three is risky.  If you have effectively
unlimited disk space, feel free to set this value to some
large number like a billion.

@item
Muq can work with uncompressed @code{.db} files, or files compressed
by any of @code{gzip}, @code{lzop} or @code{bzip2}.  Muq dbfiles, like
almost all binary database formats, compress very well, typically by a
factor of ten or so -- so keeping inactive dbfiles compressed can save
lots of diskspace.

@code{gzip} is the typical compressio program these days, @code{lzop}
is several times faster at the cost of compressing perhaps 30% less,
and @code{bzip2} provides the best compression, but may not work well
with binary files such as Muq uses.

Muq will look for these programs in @code{/bin}, @code{/usr/bin}, and
@code{/usr/local/bin}.  If they are elsewhere on your system, you may
@code{setenv} one of the Unix environment variables @code{MUQ_GZIP},
@code{MUQ_LZOP} or @code{MUQ_BZIP2} to the appropriate path, perhaps
@code{/home/me/bin/gzip}.

To disable use of one (or all) of these programs, @code{setenv} the
corresponding environment variable to the empty string.

@item
The interval between backups is controlled by the internal Muq
variable @code{.muq.millisecsBetweenBackups}.  It can be anything from
minutes to years, at your discretion.  Once a day (@code{86400000}) is
probably a reasonable choice on a stable production server; Perhaps
once an hour (@code{3600000}) if critical work is being done or
crashes are a problem.

@end itemize


@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
