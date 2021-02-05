@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Installing Muq, Muq Installation Overview, Muq Status, Top
@chapter Invoking Muq

@menu
* Muq Installation Overview::
* Downloading Muq Source::
* Compiling Muq Source::
* Muq Installation Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Installing Muq Overview					

@node Muq Installation Overview, Downloading Muq Source, Installing Muq, Installing Muq
@section Muq Installation Overview
@cindex Installing Muq
@cindex Muq, installing

To compile and test Muq, you will need about fifty megabytes of free disk space.  (You
could do it in ten at a pinch, with some fiddling.)  To run a serious server, you will
probably want one or two hundred megabytes, to allow space for the db and backups of
the db.

Compilation should be a no-brainer on almost any Unix platform.

You'll need a good @sc{ansi} C compiler.  The compiler of choice is @code{gcc}, because
that is what Muq is developed on, and because it is available on almost every machine
these days, but Muq has been successfully tested with many proprietary Unix compilers,
including those supplied with AIX and IRIX.

Muq is developed on Linux (specifically ELF Debian), so if you have a choice of platform,
Linux is most likely to give you troublefree installation and operation.

@c {{{endfold}}}
@c {{{ Downloading Muq Source					

@node Downloading Muq Source, Compiling Muq Source, Muq Installation Overview, Installing Muq
@section Downloading Muq Source

The canonical download location is ftp://ftp.cistron.nl/pub/people/cynbe.  The latest source
distribution will have a name like "muq.0.22.0-src.tar.gz".

From the Unix commandline, you can download it by doing something like:

@example
ftp ftp.cistron.nl
ftp
cynbe@@muq.org
cd pub/people/cynbe
ls
binary
hash
get muq.0.22.0-src.tar.gz
quit
@end example

From a browser like Netscape Navigator, you can download it by visiting @sc{url}
@code{ftp://ftp.cistron.nl/pub/people/cynbe/} and then @emph{right}-clicking the
appropriate filename and selecting "Save Link As" from the pop-up menu.

Other GUI-driven FTP utilities will work similarly.


@c {{{endfold}}}
@c {{{ Compiling Muq Source					

@node Compiling Muq Source, Muq Installation Wrapup, Downloading Muq Source, Installing Muq
@section Compiling Muq Source

Move the downloaded file (@code{muq.0.22.0-src.tar.gz} or whatever) to your home
directory, if it is not already there.  (Compiling elsewhere is slightly more work.)

Unpack the downloaded file.  On Linux, the easiest command to do this is

@example
tar xzf muq.0.22.0-src.tar.gz
@end example

On other Unices, you may need to instead do

@example
gunzip muq.0.22.0-src.tar.gz
tar xf muq.0.22.0-src.tar
@end example

If "gunzip" comes up "gunzip: Command not found", see if one of the following commands works:

@example
gzip -d muq.0.22.0-src.tar.gz
/usr/local/bin/gzip -d muq.0.22.0-src.tar.gz
zcat muq.0.22.0-src.tar.gz >muq.0.22.0-src.tar
/usr/local/bin/zcat muq.0.22.0-src.tar.gz >muq.0.22.0-src.tar
@end example

If none of those work, you should either ask your administrator to install "GNU gzip",
else else compile and install it yourself.  The canonical distribution site is
@code{ftp://prep.ai.mit.edu/gnu/gzip/} but every self-respecting archive on the
Internet has the same files.

The Muq source code will unpack into a subdirectory named @code{muq}.

For detailed instructions on compiling Muq (which may well
be more up-to-date than this documentation) see the plain text file
@code{muq/INSTALL}, which may be read using @code{less}, @code{more},
your favorite text editor, or Netscape Navigator, using File ->
Open Page -> /usr/home/cynbe/muq/INSTALL or similar.  However, you
should normally be able to compile and check Muq simply by doing

@example
cd muq/c
make
make check
@end example

If for some reason the fileset gets corrupted (due to running out of
disk space, say), you may wish to do @code{../bin/muq-distclean} before
attempting @code{make} again.

(If your system has less than a hundred meg of ram, it is normal to get
a few errors in the final section of "make check", where it runs three
separate Muq servers at the same time to check out networking.)

@c {{{endfold}}}
@c {{{ Muq Installation Wrapup				

@node Muq Installation Wrapup, Invoking Muq, Compiling Muq Source, Installing Muq
@section Muq Installation Wrapup

Please report installation problems to @code{bugs@@muq.org}.  We also like to hear about
successful installations on unusual systems!  See @code{muq/INSTALL} for a list of
systems Muq has been tested on, and any systems currently known to have problems.
And if you have suggestions for making installation easier or the instructions
clearer, let us know!


@c {{{endfold}}}

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
