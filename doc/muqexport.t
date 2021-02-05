@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Exporting Muq, Muq Export Overview, .who, Top
@chapter Exporting Muq

@menu
* Muq Export Overview::
* Muq Export Mechanics::
* Muq Export Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Muq Export Overview

@node Muq Export Overview, Muq Export Mechanics, Exporting Muq, Exporting Muq
@section Muq Export Overview

It may possibly be illegal to export unmodified Muq source code or
binaries from the United States.  I say "possibly" because the laws in
question are secret and changed frequently by anonymous officials in
an agency (NSA) whose existence has been repeatedly denied by the
government, and because these laws have recently been ruled flatly
unConstitutional by a US Court of Appeals.
(See @code{http://www.epic.org/crypto/export_controls/bernstein_decision_9_cir.html}).

It appears to me that the spy agencies in question are taking 
laws intended to limit the export of weapons from the United States,
and attempting to use them to eliminate privacy within the
United States.

This should not normally be a problem for you:  Even if you need
to move a system across the border, the most you should ever have
to do to remain squeaky-clean legal is to delete the server source
code and executable before crossing the border and then download
them again from @code{ftp.cistron.nl} afterwards.

There has been as yet not the slightest hint that simply possessing
and using privacy-enhancing software within the United States is
illegal.  (States like Iran are a different matter -- you may draw the
death penalty there. Watch where you step!)

The only problem case should be if you need to move your server
across the border and it contains modifications or bugfixes not
present in the standard release.

In the unlikely case this becomes an issue, the next section
details the mechanics of doing so while remaining squeaky-clean
legal.

@c {{{endfold}}}
@c {{{ Muq Export Mechanics

@node Muq Export Mechanics, Muq Export Wrapup, Muq Export Overview, Exporting Muq
@section Muq Export Mechanics
@cindex Muq Export Mechanics

The theory of operation is very simple:  To export Muq source in problematic
cases, we do the following:

@itemize @bullet
@item
Remove every trace of cryptographic code, or even hooks for cryptographic code,
from the source.  Obviously, this is legal.  The result is a fully functional
Muq server which simply happens to be totally insecure.
@item
Export the resulting code.  Since it contains nothing whatever problematic, this
is legal.
@item
At the far end, download the missing crypto code from a crypto Free World site.
This is done outside the US, and in any event the US laws in question say nothing
about importing code, only exporting it, so this is unquestionably legal.
@item
Recombine the vanilla and crypto code to produce a secure server.  This is
happening on a single machine without any transport of code whatever being
involved, so again there is no question whatever of violating export laws.
@end itemize

The practical procedure is equally simple:
@itemize @bullet

@item
Run the 'muq/bin/muq-exportable' script.  This will remove every trace of
problematic code from the server, and put it in a file
@code{muq-crypto-src.tar.gz}, which you may simply delete.  (If you've
made modifications to this part of the code, you'll have to do what I
did:  Print it out on hard copy, transport it to a crypto Free World
country such as Finland or Switzerland, and type it in again there.)

@item
If you are moving your machine physically, you can now just up and move
it.  If you are moving the source code electronically, use the
@code{muq/bin/muq-src-tar} script to produce a compressed tar archive.
(You'll likely want to run @code{muq/bin/muq-distclean} first.)  This
file is exportable as sea salt, unless the secret laws have been tweaked yet
again in some unpredictable way.

@item
Unpack the above tarfile in your home directory on the destination machine.

@item
Download a copy of @code{muq-crypto-src.tar.gz} from some Free World site
such as @code{ftp://ftp.cistron.nl/pub/people/cynbe/}.

@item
Unpack @code{muq-crypto-src.tar.gz} in your home directory.

@item
That's it!  The @code{muq-crypto-src.tar.gz} unpack will overwrite the
insecure parts of the Muq source code with secure versions, and you are
ready to compile and run.
@end itemize

Caveat:  Be careful not to accidentally try compiling and running the insecure
Muq server version in a network of secure Muq servers.  The result will probably
be obscure failures with unhelpful diagnostics.  This is unfortunately legally
required, as far as I can see:  Any code specifically designed to detect this
would count as 'hooks for encryption' and by the spooks' interpretations of
their powers would land me in jail.  Think of it as your tax dollars at work.


@c {{{endfold}}}
@c {{{ Muq Export Wrapup

@node Muq Export Wrapup, Function Index, Muq Export Mechanics, Exporting Muq
@section Muq Export Wrapup

If you're worried about your legal exposure, you may wish
to consult sites such as the International PGP page
(@code{http://www.pgpi.com/}).
If you're seriously paranoid, you should of course
consult a lawyer before doing any of this.
And before taking each breath, for that matter -- You Never Know!

As a practical matter, it seems clear that only high-profile targets like
the principal authors and archive sites of widely used packages get
targetted for legal harassment, and even they usually win the cases
in the end, barring blatent violations.

If you're worried about these Big Brother tendencies toward a
government mandated spy in every virtual room and want to maybe
add your voice to those raised in protest, see the Electronic
Frontier Foundation (@code{http://www.eff.org/}) or the
Internet Privacy Coalition (@code{http://www.privacy.org/ipc/}).
Adding your voice can be as easy as adding their logo to your
web page.

(And if you're not worried ... well, gods help us all!)


@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
