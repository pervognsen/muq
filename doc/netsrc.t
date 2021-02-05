@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Net Re-sources, Net Re-sources Overview, Reference Shelf Wrapup, Top
@appendix Net Re-sources

@menu
* Net Re-sources Overview::
* 3-D Graphics::
* Computer Algebra::
* GNU stuff::
* Image Processing Tools::
* Object Oriented Stuff::
* TeX::
* Net Re-sources Wrapup::
@end menu

@c
@node Net Re-sources Overview, 3-D Graphics, Net Re-sources, Net Re-sources
@section Net Re-sources Overview

This appendix contains pointers to various public domain or
copyleft bits of code on the net which might contain wheels
worth adding to (or using in conjuction with) Muq at some
point.

Note: "Public Domain" is a term widely abused in the
computer field.  Legally, something is public domain only if
it carries no copyright whatever.  Most so-called "public
domain" software does in fact carry a copyright.

However, language means what people use it to mean, myriad
frustrated gradeschool teachers to the contrary.  In this
section I use "PD" in the contemporary sense of code which
is freely usable for most reasonable purposes, and also
"copyleft" for code which has a GNUish sort of licence.

Once again, I must point to the netnews @sc{faq} (Frequently
Asked Questions) archive on rtfm.mit.edu (mnemonic: Read The
Fine Manual) as a treasure trove of further pointers.

@c
@node 3-D Graphics, Computer Algebra, Net Re-sources Overview, Net Re-sources
@section Image Processing Tools

GeomView is a very well written, NSF-funded copyleft 3-D
visualization package oriented towards math and geometry
researchers.  (It is not often the Los Federales fund good
copyleft code: If you use this code and send them email
telling them so, it will help them maintain the funding to
maintain the software.  Do it!)  Anon-ftp to geom.umn.edu.

Full @sc{pd} source for all the code in the Graphics Gems
series of books is available for anon-ftp at princeton.edu
in pub/Graphics/GraphicsGems.

Ygl is a copyleft implementation of (some subset of?) SGI's
Graphics Language.
@display
http://www.thp.Uni-Duisburg.DE/Ygl/ReadMe.html.
ftp.thp.Uni-Duisburg.DE (134.91.141.1):
pub/source/X11/Ygl-2.5.tar.@{Z|gz@}.
EMail: fred@@hal6000.Uni-Duisburg.DE.
@end display

@c
@node Computer Algebra, GNU stuff, 3-D Graphics, Net Re-sources
@section Computer Algebra

Jacal is a nice little package written in Scheme, available
from prep.ai.mit.edu in the @sc{gnu} stuff.  Comes with a
small Scheme-in-C.

The calc*.el package for emacs lisp is another resource to
consider.

@c
@node GNU stuff, Image Processing Tools, Computer Algebra, Net Re-sources
@section GNU stuff

As just about everyone must know, the Free Software Foundation's
@sc{gnu} (Gnu's Not Unix) project to write a free unix clone
is a fountain of copyleft code, much of it very high quality.

The definitive archive is prep.ai.mit.edu, but it is
mirrored at most of the big net archives, such as
gatekeeper.dec.com and wuarchive.wustl.edu.

@c
@node Image Processing Tools, Object Oriented Stuff, GNU stuff, Net Re-sources
@section Image Processing Tools

I haven't actually checked code quality or PD-ness of this
one:

@example
| Date: Tue, 1 Nov 94 17:49:50 GMT
| From: "S. A. J. Winder" <sajw@@maths.bath.ac.uk>
| Organization: Bath University Computing Group
| Subject: SHAREWARE: New Image Processing Toolset
| 
|               IMG* Image Processing Toolset and C Library
| 
|                         Version 1.0 (Oct 1994)
@end example
@example
| Announcing the availability of a new public domain image processing
| environment developed at Bath University: The ImgStar toolset.
| 
| *** Features:
|  * Seventy tools, including edge operators, space and Fourier domain
|    filtering, differential operators, sequence handling etc.
|  * Allows multiple images or sequences to be processed using one
| 
|    command-line.
|  * Developed to complement the well known PBMPLUS tools.
|  * Full 80 page postscript documentation.
|  * Only 3.5Mbytes - small enough to accompany any existing image
|    processing environment.
|  * Compatible with popular image file formats.
|  * Easily expandable using the accompanying C library.
|  * Developed and tested over two years on SGI and Sun UNIX platforms.
| 
@end example
@example
| *** Description:
| 
| The ImgStar Image Processing Tools are intended as a complete
| environment for image processing to compliment Jef Poskanzer's PBMPLUS
| toolkit which mostly provides conversion between different standard
| file formats. All 70 ImgStar tools use a similar UNIX command line
| invocation style and images are piped between operators, each of which
| provides some filtering transformation. A floating point image format
| is introduced in order to allow image processing operations to be
| cascaded usefully. Conversion tools are included to convert between
| this and the PBM-type formats.
| 
| In addition to the processing of single images, all the ImgStar tools
| include support for sequential processing of multiple images from a
| single command line. This is useful when similar operations need to be
| applied to many images such as the analysis of motion sequences. A
| comprehensive set of sequence handling tools allows many useful
| processing schemes to be created with a minimum number of commands.
| 
@end example
@example
| *** How to obtain it:
| 
| Version 1.0 of the package is now available by anonymous ftp from
| axiom.maths.bath.ac.uk (138.38.96.32) as file "imgstar.tar.Z" in
| directory "/pub/imgstar".
| 
| Further information is available by World Wide Web from:
| 
|    http://www.bath.ac.uk/~mapsajw/imgstar.html
| 
| This also provides a convenient way of downloading the package.
| 
|  Simon A.J. Winder        ***********  Vision Research ***********
|  sajw@@maths.bath.ac.uk    ** University of Bath Computing Group **
|  Tel: +44 (0)225 826183   http://www.bath.ac.uk/~mapsajw/home.html
@end example


SGI computers ship with a 4Dgifts set of PD image hacking tools,
mostly by Paul Haeberli.

@c
@node Object Oriented Stuff, TeX, Image Processing Tools, Net Re-sources
@section Object Oriented Stuff

I peeked at a promising sounding delegation based
lisp package mentioned in the comp.lang.lisp @sc{faq}:

@example
ftp.cs.cmu.edu:
/user/ai/lang/lisp/oop/non-clos/corbit
@end example

@noindent
but unfortunately it doesn't seem a good fit to Muq.

For an infix notation, ftp.cwi.nl:pub/python is an infix
language competing with Perl and Tcl, offering good
object-oriented support with multiple inheritance and
such, used and recommended by Randy Pausch in his
impresive "Alice" immersive-VR system.

@c
@node TeX, Net Re-sources Wrapup, Object Oriented Stuff, Net Re-sources
@section TeX

Knuth's typesetting package TeX (and matching font generation
package MetaFont) should need no introduction or review, and
are needed for generating new versions of the Muq documentation
if nothing else.

@example
Date: Thu, 28 Jul 94 07:36:47 -0700
From: Unix TeX Distribution <unixtex@@u.washington.edu>
To: jsp@@betz.biostr.washington.edu
Subject: Re: TeX: ftp info

[unixtex.ftp: 15 July 1994]

The master version of this file is on ftp.cs.umb.edu (158.121.104.33)
in pub/tex/unixtex.ftp.

=========================================================================
             Consider joining the TeX Users Group (TUG):
support the maintenance and development of the programs you retrieve.
              Send membership request to: tug@@tug.org.
=========================================================================
@end example
@example

			FTP INSTRUCTIONS

for Unix sites wanting to retrieve source files for installing 
(plain) TeX, LaTeX, BibTeX, plain Metafont, a previewer that will 
work under the X windowing system, and a PostScript device driver.

(If you wish to retrieve executables, please see the note from 
George Greenwade at the end of this file.)

The three sites listed below are part of the Comprehensive TeX Archive 
Network (CTAN) --  the result of cooperative work among members of TUG, 
DANTE [German-speaking TeX Users Group], and UKTUG [U.K. TeX Users Group], 
under the leadership of George Greenwade, Chair for TUG's Technical 
Working Group on TeX Archive Guidelines.

Special thanks to George Greenwade for establishing the CTAN site at 
Sam Houston State University (US); to Rainer Schoepf, Barbara Burr, 
and members of DANTE for the CTAN site at Heidelberg (FRG); and to 
Sebastian Rahtz for the CTAN site at Aston University (UK).  These 
archives mirror each other.
    
Use the host nearest you: 

    Host			Internet address	TeX root dir
    ----			----------------	------------
    ftp.shsu.edu		192.92.115.10		tex-archive
    ftp.tex.ac.uk		134.151.44.19		tex-archive
    ftp.dante.de		128.69.1.12		tex-archive

Users of ftp.tex.ac.uk or ftp.dante.de will be able to retrieve the same 
tex-archive files, but site-specific files such as the two mentioned in the 
next paragraph may be named differently.

Upon logging on (to ftp.shsu.edu), retrieve and read 

    README.archive-features
    README.site-commands 

Our instructions assume you have read these documents.

If you do not have GNU's gunzip utility, first retrieve and install the
gzip package.  Set "binary" mode by typing "bi" at your ftp prompt; retrieve

    /tex-archive/tools/info-zip/gzip-<version>.tar

It does a better job of compression than standard Unix compress, and it
is (as far as is known) patent-free.  It is illegal to use Unix compress
(at least in the USA), because it infringes on a software patent.

Write to lpf@@uunet.uu.net, the League for Programming Freedom, for
information about fighting the new software monopolies in the US.

If you have difficulty retrieving the files, email tex-wizard@@cs.umb.edu.  

@end example
@example

For a basic set of input files and fonts:
----------------------------------------

ftp> cd tex-archive/systems/web2c
ftp> bi
ftp> get lib.tar.gz

     This file contains a minimal collection of fonts (TFM files only),
     (La)TeX macros, MF macros, and BibTeX files -- just enough to get
     started. The AMS fonts and macros are included.

     It unpacks into a directory named `texmf', which you will want in
     your equivalent of /usr/local/lib -- whatever you defined as your
     $(datadir) in the Makefiles.

     The organization of the archive was debated at great length. We hope
     it will be useful. If you don't like our organization, feel free to
     move the files around as you see fit, not forgetting to redefine the
     search paths and installation directories. The Makefiles,
     kpathsea/HIER, kpathsea/paths.h.in, and web2c/README (``Directory
     hierarchies'') have more information.

     You must decide on your directory structure *before* doing the
     compilations, since you must specify default search paths, and
     since the web2c Makefile tries to create the basic .fmt and .base
     files, which require the .@{tex,mf,tfm@} input files to be in place.

@end example
@example

For web2c (that is, TeX, Metafont, and friends):
------------------------------------------------

Still in tex-archive/systems/web2c:

ftp> get web.tar.gz	[Knuth's WEB sources for TeX, MF, & family:
			 unpacks into ./web2c-<version>]
ftp> get web2c.tar.gz	[WEB-to-C source: unpacks into ./web2c-<version>]

     You must retrieve and unpack both web.tar.gz and web2c.tar.gz.

     The web2c software converts Knuth's original WEB source files
     for TeX, Metafont, & family to C source.

@end example
@example

Device driver support:
----------------------


       For an X window system previewer (xdvik):

ftp> cd /tex-archive/dviware/xdvik
ftp> get xdvik.tar.gz	[unpacks into ./xdvik-<version>]


       For a DVI-to-PostScript translator (dvipsk):

ftp> cd /tex-archive/dviware/dvipsk
ftp> get dvipsk.tar.gz	[unpacks into dvipsk-<version>]


       For a DVI-to-PCL translator (dviljk):

ftp> cd /tex-archive/dviware/dviljk
ftp> get dviljk.tar.gz	[unpacks into dviljk-<version>]


        For optional prebuilt fonts:

ftp> cd /tex-archive/fonts/cm/pk
ftp> get pk300.zip

     These bitmapped fonts were generated by Metafont using the CanonCX
     mode_def for write-black 300dpi devices.

     If using the default search paths, place this set of 
     Computer Modern fonts in $(fontdir)/public/cm/pk/cx.

     These are optional because the drivers can be used with a script
     called `MakeTeXPK' (sample supplied in the dvipsk distribution) to
     generate needed bitmapped fonts.

     The zip/unzip package is in /tex-archive/tools/info-zip.
     

ftp> quit		[end ftp session]

We believe this covers the retrieval of the essential files.  

Each of these packages -- web2c, xdvik, dvipsk, dviljk -- contains its
own installation instructions.  It is possible to build all three
programs in a single make, but it is simpler to make them separately.

Compile web2c first (that is to say, the material in both web.tar.gz and 
web2c.tar.gz, unpacked).  Begin by reading 

	./web2c-<version>/README
	./web2c-<version>/web2c/README
	./web2c-<version>/web2c/INSTALL
	./web2c-<version>/kpathsea/README
	./web2c-<version>/kpathsea/INSTALL

The INSTALL files are your guides to installation.

Remember to set up your texmf directory hierarchy before embarking on 
your compilation (see "For a basic set of input files and fonts" above).

All installation processes require careful attention to detail, and
knowledge of your system.  Festa lente -- make haste slowly -- and you
improve your chances of success.

@end example
@example

Network users interested in TeX software will find much that is useful in 
the following FAQ (Frequently Asked Questions) documents on rtfm.mit.edu
(18.70.0.209) in /pub/usenet/comp.text.tex:

	T,_L,_e.:_F_A_Q_w_A_[M]	
		(i.e., TeX, LaTeX, etc.: FAQ with Answers [Monthly])

There is also a supplement to the FAQ containing FTP locations; it's in
the same place on rtfm.mit.edu.

A beautifully done index of macros for TeX and LaTeX is available on 
theory.lcs.mit.edu (18.52.0.92) in /pub/tex/TeX-index.

These files are included in ftp.cs.umb.edu:pub/tex/src.tar.gz.

@end example
@example

Distribution on tape:
--------------------

For TeX on a single tape (4mm DAT or QIC-24), ordering information is
available from unixtex@@u.washington.edu.  A distribution fee in the area
of US$210.00 covers administrative costs.  Tapes will be available at
least through summer of 1994.

@end example
@example

Retrieving TeX executables:
--------------------------

Date: Mon, 09 May 1994 09:09:20 CST
From: "George D. Greenwade" <bed_gdg@@SHSU.edu> (but slightly edited)

The files in /tex-archive/systems/unix/unixkit/ are minimal sets of
precompiled executables (thanks to Sebastian Rahtz for making these sets
available) for the various platforms using the latest web2c (version
6.1) package and techniques outlined in unixtex.ftp.  The one exception to
this is the file share.tar.gz, which includes man pages and pool files
for the distribution which may be used across all architectures.

Specifically excluded from this distribution in unixkit are the many
additional macros and styles, fonts, and utilities which are available
elsewhere in the CTAN archives -- the idea is to have the ability to get
the latest files, but still have them in workable chunks for retrieval
purposes. [Retrieve lib.tar.gz as discussed above for the minimal
font/macro files.]

@end example
@c
@node Net Re-sources Wrapup, Function Index, TeX, Net Re-sources

@section Net Re-sources

This concludes my list of known neat and relevant
pd/copyleft software sources.

Suggestions for additions welcomed!

@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c-+\\)"
@c End:
