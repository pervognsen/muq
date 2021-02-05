@example  @c
/*--   x-bnm.c -- eXerciser for bnm.c.					*/
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
/* Created:      98Jan11						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1999, by Jeff Prothero.				*/
/*									*/
/* This program is free software; you may use, distribute and/or modify	*/
/* it under the terms of the GNU Library General Public License as      */
/* published by	the Free Software Foundation; either version 2, or (at  */
/* your option)	any later version FOR NONCOMMERCIAL PURPOSES.		*/
/*									*/
/*  COMMERCIAL operation allowable at $100/CPU/YEAR.			*/
/*  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		*/
/*  Other commercial arrangements NEGOTIABLE.				*/
/*  Contact cynbe@eskimo.com for a COMMERCIAL LICENSE.			*/
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
/* Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
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
/*-    #defines								*/
/************************************************************************/

/* What to do on fatal error:						*/
#ifndef JOB_FATAL
#define JOB_FATAL(x) {fprintf(stderr, (x));abort();}
#endif


/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Globals								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

void usage( void );




/************************************************************************/
/*-    try -- Debug function to process one test vector.		*/
/************************************************************************/

static void try(
    Vm_Uch* str
) {
    printf("+++++  Bignum: I'm bored\n");
}

/************************************************************************/
/*-    main -- Apply all test vectors.					*/
/************************************************************************/

Vm_Int   main_ArgC;
Vm_Uch** main_ArgV;

int
main(
    int    argc,
    char** argv
) {
    main_ArgV = (Vm_Uch**)argv;
    main_ArgC =           argc;

    if (argc != 1)   usage();

    try(
	"abc"
    );

    exit(0);
}

/************************************************************************/
/*-    usage								*/
/************************************************************************/

void usage(void) {

    fprintf( stderr, "usage: x_bnm\n" );
    exit(1);
}




/************************************************************************/
/*-    File variables							*/
/************************************************************************/
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

@end example
