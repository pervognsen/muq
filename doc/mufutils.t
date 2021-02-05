@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muf Utils, Muf Utils Overview, unprint[, Top
@chapter Muf Utils

@menu
* Muf Utils Overview::
* ls and kin::
* Muf Utils Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Muf Utils Overview

@c
@node Muf Utils Overview, ls and kin, Muf Utils, Muf Utils
@section Muf Utils Overview

This chapter documents library functions implemented in
~/muq/pkg/10-utils.muf.  These are core muf utility
functions which it is assumed that almost all muq dbs will
want to have installed.

As of version -2.9.0, this library has just been created,
and is almost empty; It is slated to grow rapidly over the
next few releases, once attention switches from portability
and documentation issues back to actual progress on the
server.

@c {{{endfold}}}
@c {{{ ls and kin

@c
@node ls and kin, Muf Utils Wrapup, Muf Utils Overview, Muf Utils
@section ls and kin

"ls" pops the top-of-stack object and provides a listing of
public keyval pairs on it.

Example: ".lib.muf ls" will spam you nicely with a listing
of all standard muf prim and library functions.

Bugs: We need matching functionality for listing hidden,
admins, system and method namespaces.  It would be nice to
be able to have pointers to them, but the design just
doesn't have enough pointer bits to support this on a 32-bit
machine.  Or I lack the cleverness to find a way.

@c {{{endfold}}}
@c {{{ Muf Utils Wrapup

@c
@node Muf Utils Wrapup, Muq Internals, ls and kin, Muf Utils
@section Muf Utils Wrapup

This concludes the Muf Utilities chapter.

@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
