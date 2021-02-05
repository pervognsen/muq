#!/bin/make -f
# Makefile for the Muq manual.
# Created: 93Mar28
# Updated: 94Dec16
#
# This Makefile assumes you have the GNU 'makeinfo' program handy.
# I got it from their elisp manual distribution, v1.03.

# "One shell programming construction that you should not use
#  [...]  is `VAR=${VAR:-VALUE}'.  Old BSD shells, including
#  the Ultrix `sh', don't understand the colon, and complain
#  and die.  If you omit the colon, it works fine."
#   -- GNU autoconf.info: General Feature Tests

##########################################################################
#- header stuff

MAKE= make
SHELL= /bin/sh

##########################################################################
#- all muq check check2 clean

help:
	@echo "Do 'make ascii'  to build all manuals in ascii format."
	@echo "Do 'make html'   to build all manuals in html  format."
	@echo "Do 'make info'   to build all manuals in info  format."
	@echo "Do 'make dvi'    to build all manuals in .dvi  format."
	@echo "Do 'make ps'     to build all manuals in .ps   format."
	@echo "Do 'make all'    to build all manuals in all   formats."
	@echo "Do 'make mufref' to build all versions of mufref manual. (&tc)"
	@echo "Do 'make src.ps' to build just .ps version of src manual. (&tc)"
	@echo "Do 'make tars'   to build     *tar.gz in all   formats."
	@echo "Do 'make clean'  to discard all regeneratable files."
	@echo "Do 'muq-install-html' to install all html docs in ~/www/muq."
	@echo "Read 'Makefile' for other make commands."

##########################################################################
#-- mufhack

mufhack.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufhack.html)

mufhack.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufhack.info)

mufhack.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufhack.ascii)

mufhack.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufhack.dvi)

mufhack.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufhack.ps)

mufhack:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufhack)




##########################################################################
#-- muchack

muchack.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muchack.html)

muchack.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muchack.info)

muchack.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muchack.ascii)

muchack.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muchack.dvi)

muchack.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muchack.ps)

muchack:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muchack)




##########################################################################
#-- muqfaq

muqfaq.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqfaq.html)

muqfaq.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqfaq.info)

muqfaq.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqfaq.ascii)

muqfaq.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqfaq.dvi)

muqfaq.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqfaq.ps)

muqfaq:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqfaq)




##########################################################################
#-- muf1

muf1.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf1.html)

muf1.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf1.info)

muf1.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf1.ascii)

muf1.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf1.dvi)

muf1.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf1.ps)

muf1:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf1)




##########################################################################
#-- muf2

muf2.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf2.html)

muf2.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf2.info)

muf2.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf2.ascii)

muf2.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf2.dvi)

muf2.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf2.ps)

muf2:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf2)

##########################################################################
#-- muf3

muf3.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf3.html)

muf3.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf3.info)

muf3.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf3.ascii)

muf3.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf3.dvi)

muf3.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf3.ps)

muf3:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir`; \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muf3)

##########################################################################
#-- mufref

mufref.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufref.html)

mufref.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufref.info)

mufref.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufref.ascii)

mufref.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufref.dvi)

mufref.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufref.ps)

mufref:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 mufref)

##########################################################################
#-- lspref

lspref.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 lspref.html)

lspref.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 lspref.info)

lspref.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 lspref.ascii)

lspref.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 lspref.dvi)

lspref.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 lspref.ps)

lspref:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 lspref)

##########################################################################
#-- src

src.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 src.html)

src.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 src.info)

src.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 src.ascii)

src.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 src.dvi)

src.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 src.ps)

src:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 src)

##########################################################################
#-- admin

admin.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 admin.html)

admin.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 admin.info)

admin.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 admin.ascii)

admin.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 admin.dvi)

admin.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 admin.ps)

admin:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 admin)

##########################################################################
#-- muqsoon

muqsoon.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqsoon.html)

muqsoon.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqsoon.info)

muqsoon.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqsoon.ascii)

muqsoon.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqsoon.dvi)

muqsoon.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqsoon.ps)

muqsoon:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqsoon)




##########################################################################
#-- muqnet

muqnet.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqnet.html)

muqnet.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqnet.info)

muqnet.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqnet.ascii)

muqnet.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqnet.dvi)

muqnet.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqnet.ps)

muqnet:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 muqnet)




##########################################################################
#-- micronesia

micronesia.html:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 micronesia.html)

micronesia.info:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 micronesia.info)

micronesia.ascii:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 micronesia.ascii)

micronesia.dvi:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir`	\
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 micronesia.dvi)

micronesia.ps:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 micronesia.ps)

micronesia:	
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 $(MAKE) -f Makefile2 micronesia)




##########################################################################
#-- ascii

ascii:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 ascii)

##########################################################################
#-- html

html:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 html)

##########################################################################
#-- info

info:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 info)

##########################################################################
#-- dvi

dvi:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 dvi)

##########################################################################
#-- ps

ps:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 ps)

##########################################################################
#-- all

all:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 all)

##########################################################################
#-- tars

tars:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 tars)

##########################################################################
#-- obsolete junk

tar:	muq.ps
	tar -cvf muqdocs.`$${MUQDIR-$${HOME}/bin/muq}/muq-config version`.tar muq.dvi muq.ps
	gzip muqdocs.`$${MUQDIR-$${HOME}/bin/muq}/muq-config version`.tar

manual: $(srcs) # index.texi
	makeinfo muq.texi

muq.dvi: $(srcs) # index.texi
	tex muq.texi
	texindex muq.??
	tex muq.texi

muq.ps:	muq.dvi
	dvips muq.dvi -o muq.ps

##########################################################################
#-- clean

clean:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 clean)

##########################################################################
#-- versionc.t, versiont.t

versionc.t:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 versionc.t)

versiont.t:
	@(HDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config hdir` \
	 MODDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config moddir` \
	 BINDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config bindir` \
	 DOCDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config docdir` \
	 PKGDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config pkgdir` \
	 CDIR=`$${MUQDIR-$${HOME}/bin/muq}/muq-config cdir` \
	 VERSION=`$${MUQDIR-$${HOME}/bin/muq}/muq-config version` \
	 $(MAKE) -f Makefile2 versiont.t)

versions: versionc.t versiont.t

##########################################################################
#- Local variables
# Local Variables:
# shellscript-mode: t
# mode: outline-minor
# outline-regexp: "#-+"
# End:
