@example  @c

/*--   Hax.c -- Portability hacks for Muq.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/



/************************************************************************/
/*-    Dedication and Copyright.					*/
/************************************************************************/

/************************************************************************/
/*									*/
/*		For Firiss:  Aefrit, a friend.				*/
/*									*/
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      94Jul18						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-1995, by Jeff Prothero.				*/
/*									*/
/* This program is free software; you may use, distribute and/or modify	*/
/* it under the terms of the GNU Library General Public License as      */
/* published by	the Free Software Foundation; either version 2, or (at  */
/* your option)	any later version FOR NONCOMMERCIAL PURPOSES.		*/
/*									*/
/*  COMMERCIAL operation allowable at $100/CPU/year.			*/
/*  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		*/
/*  Other commercial arrangements NEGOTIABLE.				*/
/*  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			*/
/*									*/
/*   This program is distributed in the hope that it will be useful,	*/
/*   but WITHOUT ANY WARRANTY; without even the implied warranty of	*/
/*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	*/
/*   GNU Library General Public License for more details.		*/
/*									*/
/*   You should have received the GNU Library General Public License	*/
/*   along with this program (COPYING.LIB); if not, write to:		*/
/*      Free Software Foundation, Inc.					*/
/*      675 Mass Ave, Cambridge, MA 02139, USA.				*/
/*									*/
/* JEFF PROTHERO DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
/* INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	*/
/* NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	*/
/* CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	*/
/* OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		*/
/* NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	*/
/* WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.			*/
/*									*/
/* Please send bug reports/fixes etc to bugs@@muq.org.			*/
/************************************************************************/



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    Hax_dummy -- int var so file is always nonempty			*/
/************************************************************************/

/* Seems to me that I've heard of C compilers */
/* that die on empty files?                   */
int Hax_dummy = 0;



/************************************************************************/
/*-    memmove -- memcpy that handles overlaps correctly		*/
/************************************************************************/

/**********************************************************/
/* Apparently this fn isn't POSIX.  There are some places */
/* in the server where source and destination overlap,    */
/* however, so we can't use memcpy.  Hence, we provide    */
/* our own memmove() on systems lacking it (SunOS 4.x)    */
/**********************************************************/

#ifndef HAVE_MEMMOVE

void*
memmove(
    void      * dst,
    const void* src,
    size_t      len
) {
    register       char*  d = dst;
    register const char*  s = src;
    register       size_t u = len;

    if (d < s) {

	/* Yes, should specialCase word-aligned */
	/* copies for real performance:          */
	while (u & ~0x7) {

	    /* Superscalars probably prefer     */
	    /* this to a series of *d++ = *s++: */
	    d[0] = s[0];
	    d[1] = s[1];
	    d[2] = s[2];
	    d[3] = s[3];
	    d[4] = s[4];
	    d[5] = s[5];
	    d[6] = s[6];
	    d[7] = s[7];

	    d   += 8;
	    s   += 8;
	    u   -= 8;
	}

	/* Mop up: */
        /* "while (--u >= 0)" often compiles into */
        /* better code -- but is incorrect for    */
        /* unsigned types:                        */
	while (u --> 0)  *d++ = *s++;

	return dst;

    } else {

	d += (u-1);
	s += (u-1);

	while (u & ~0x7) {

	    d[ 0] = s[ 0];
	    d[-1] = s[-1];
	    d[-2] = s[-2];
	    d[-3] = s[-3];
	    d[-4] = s[-4];
	    d[-5] = s[-5];
	    d[-6] = s[-6];
	    d[-7] = s[-7];

	    d    -= 8;
	    s    -= 8;
	    u    -= 8;
	}

	while (u --> 0)   *d-- = *s--;

	return dst;
    }
}

#endif




/************************************************************************/
/*-    File variables							*/
/************************************************************************/
/*

Local variables:
mode: c
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

@end example
