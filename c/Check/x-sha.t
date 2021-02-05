@example  @c
/*--   x-sha.c -- eXerciser for sha.c.					*/
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
    Vm_Uch* str,
    Vm_Uch* expected_digest
) {
    Vm_Uch digest[20];
    Vm_Uch ascii_digest[48];

    sha_Digest( digest, str, strlen(str) );

    {   Vm_Int32  i;
        for (i = 0;   i < 20;   ++i) {
	    sprintf(&ascii_digest[i*2],"%02x",digest[i]);
    }   }
    if (strcmp(ascii_digest,expected_digest)) {
	printf("***** expected hash %s != actual hash %s!\n",expected_digest,ascii_digest);
    } else {
        printf("+++++  Secure hash:  %s\n",ascii_digest);
    }
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
	"abc",
	"a9993e364706816aba3e25717850c26c9cd0d89d"
    );
    try(
	"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
	"84983e441c3bd26ebaae4aa1f95129e5e54670f1"
    );

    {   /* Construct test vector of one million 'a's: */
	Vm_Uch* mega_a = (Vm_Uch*) malloc( 1000001 );
	int  i;
	for (i = 0;   i < 1000000;   ++i) {
	    mega_a[i] = 'a';
	}
	mega_a[1000000] = '\0';
	try(
	    mega_a,
	    "34aa973cd4c4daa4f61eeb2bdbad27316534016f"
	);
    }

    exit(0);
}

/************************************************************************/
/*-    usage								*/
/************************************************************************/

void usage(void) {

    fprintf( stderr, "usage: x_sha\n" );
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
