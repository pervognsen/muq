@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Crash Recovery, Crash Recovery Overview, Muq Dbfiles Wrapup, Top
@chapter Crash Recovery

@menu
* Crash Recovery Overview::
* Crash Diagnosis::
* Crash Recovery Mechanics::
* Crash Recovery Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Crash Recovery Overview

@node Crash Recovery Overview, Crash Diagnosis, Crash Recovery, Crash Recovery
@section Crash Recovery Overview

The Muq server was designed and implemented with reliability in mind.  Its test suite
includes thousands of tests, and gets run roughly hourly during development.

Still, server crashes are a fact of life, if not due to bugs which have survived to
reach beta testing, then due to bad memory, power failures, disk failures, disk
overflow or whatever.

Your best insurance against crashes is always to keep lots of backups, both in
the active server directory itself, and also somewhere completely different,
at minimum on another machine, ideally offline in a firesafe in a separate
building.  Think about how much it would cost you to replace the db if (say)
the host machine got stolen or destroyed by fire, and plan accordingly.

@c {{{endfold}}}
@c {{{ Crash Diagnosis

@node Crash Diagnosis, Crash Recovery Mechanics, Crash Recovery Overview, Crash Recovery
@section Crash Diagnosis
@cindex Crash Diagnosis

Your first action after a crash will usually be to run your adrenalin
level up and say a few choice words.  If you act quickly while still
in this phase, you can usually manage to make things much, much worse!
It is often a good idea to start by taking a deep breath, getting a cup
of coffee, and perhaps grabbing a friend for moral support.

After that, your next action should be to make a reasonable diagnosis of
the reason for the crash.  Restarting the server without doing this is
very likely to just make a bad situation worse, by further corrupting
the database and perhaps erasing some of your few remaining good backups
(if you keep a shallow sequence of backups).

Two good checks to start with:
@itemize @bullet
@item
Are you low on diskspace?  Do "df -k" (say).  If the partition you run
Muq from is full, that's a prime suspect.
@item
Are you low on free memory?  Do "free" and check the amount of free ram
and swap.  If you got a corefile and it bigger than free ram and swap,
there's a good chance you simply ran out of space.
@end itemize

If you have the diskspace to spare, a good next step is to make a complete tar
archive of the entire db directory.  This will preserve almost all the relevant
information, which may help with diagnosis later, and may also save your bacon
if you screw up and wreck the db directory while attempting recovery.

If Muq crashed and you did @strong{not} get a corefile, you may have them
turned off:  Do "limit".  If it says "coredumpsize 0", you're cheating yourself
of good diagnostic information.  You may want to do "limit coredumpsize unlimited"
before future runs.

If you got a corefile, do

@example
script stackdump
gdb ../bin/muq ./core
bt
(You may need to hit <return> a few times here.)
quit
exit
@end example

and save the resulting 'stackdump' listing: Even if it doesn't mean
anything to you, you can email it to me (via @code{bugs@@muq.org}) if
the problem eludes diagnosis, and perhaps I will be able to make
something of it.  (At the least, I may be able to tell you whether
other people are reporting similar problems.)  If you can afford the
space, saving the 'core' file in a directory where it won't be overwritten
by new coredumps can be a good idea.


@c {{{endfold}}}
@c {{{ Crash Recovery Mechanics

@node Crash Recovery Mechanics, Crash Recovery Wrapup, Crash Diagnosis, Crash Recovery
@section Crash Recovery
@cindex Crash Recovery

Once you have attempted diagnosis and convinced yourself that you've either resolved
the problem or else have no clue what else to do, it is time to try getting your
Muq server back on the air.

The server crash probably left a bunch of '*-RUNNING-*.db' files.
These are useless: they are undoubtedly in a corrupt state.  Delete
them. (If you're feeling cautious, you might move them to an archive
subdirectory somewhere, if you haven't already archived the entire
directory.  They might possibly will come in useful in later detective
work.)

Nine times out of ten, you will now be able to restart the server
without further incident.  (Until the same problem repeats, whatever
it was.)

Occasionally, the '*CURRENT*.db.*' files will also be corrupt (meaning
dying server managed to complete a backup before dying completely). In
that case, you'll want to delete (or archive) those files as well, and
rename the most recent numeric backup set to be the '*CURRENT*.db.*'
fileset.

If you're @strong{really} unlucky, you may have to go back more than
one generation before finding a good backup set, but that is unusual.
You should quickly start suspecting that your hardware has gone bad,
or that your Muq executable image has somehow gotten corrupted: You
may wish to recompile or redownload (or checksum) it, and verify
that other large programs are working correctly on your machine.

A good check is to compile Muq from source and then run "make check".
If you suspect you have an erratic ram failure that shows up only
every hour or two, you may wish in tcsh to do something like

@example
while (1)
muq-distclean
make
make check
date
end
@end example

and leave it running overnight:  If that crashes on clean Muq
source, you almost certainly have a hardware problem of some
sort.  If it runs a full day without problems, your hardware
is probably pretty healthy.


@c {{{endfold}}}
@c {{{ Crash Recovery Wrapup

@node Crash Recovery Wrapup, Muq Db Layout, Crash Recovery Mechanics, Crash Recovery
@section Crash Recovery Wrapup

It is a good idea to send a summary to @code{bugs@@muq.org} any time you get
a new sort of crash:  It may help us make future releases more robust in some
way.

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
