@example  @c
/*--   job.c -- Multithreaded-processes / bytecode-intepreter.		*/
/*- This file is formatted for outline-minor-mode in emacs19.		*/
/*-^C^O^A shows All of file.						*/
/* ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	*/
/* ^C^O^T hides all Text. (Leaves all headings.)			*/
/* ^C^O^I shows Immediate children of node.				*/
/* ^C^O^S Shows all of a node.						*/
/* ^C^O^D hiDes all of a node.						*/
/* ^HFoutline-mode gives more details.					*/
/* (Or do ^HI and read emacs:outline mode.)				*/

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
/* Created:      96Oct15 from job.t code.				*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-1997, by Jeff Prothero.				*/
/*									*/
/* This program is free software; you may use, distribute and/or modify	*/
/* it under the terms of the GNU Library General Public License as      */
/* published by	the Free Software Foundation; either version 2, or (at  */
/* your option)	any later version FOR NONCOMMERCIAL PURPOSES.		*/
/*									*/
/*  COMMERCIAL operation allowable at $100/CPU/YEAR.			*/
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

#include "Muq.h"
#include "jobprims.h"

/************************************************************************/
/*-    Public fns, true prims for jobprims.c	 			*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_signeddigest operator.					*/
 /***********************************************************************/

void
job_signeddigest(
    Vm_Uch  digest[20],
    Vm_Uch  signature[64],
    Vm_Uch* buffer,
    Vm_Unt  buflen
) {
    /********************************************************************/
    /* I've heard that it is supposedly now illegal to export code	*/
    /* using SHA for digest authentication from the US, so we use a     */
    /* deliberately weak hash function here:                            */
    /********************************************************************/

    /* Guarantee that all digest bytes have well-defined values: */
    int  i;
    for (i = 20;   i --> 0;)   digest[20] = 0;

    for (i = 0;   i < buflen;   ++i) {
	digest[ i & 0xF ] ^= signature[ i & 0x3F ] ^ buffer[i];
    }
}

 /***********************************************************************/
 /*-    job_P_Signed_Digest_Block -- "|signedDigest" operator.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Signed_Digest_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Uch buffer[ MAX_STRING ];
    Vm_Int block_size = OBJ_TO_BLK( jS.s[-1] );
    Vm_Obj sharedSecret = jS.s[0];

    job_Guarantee_N_Args(               2 );
    job_Guarantee_Blk_Arg(             -1 );
    job_Guarantee_N_Args(    block_size+3 );
    if (!OBJ_IS_BIGNUM(sharedSecret)
    || BNM_P(sharedSecret)->private != BNM_DIFFIE_HELLMAN_SHARED_SECRET
    ){
	MUQ_WARN("signature argument must be a #<DiffieHellmanSharedSecret>");
    }
 
    if (block_size > MAX_STRING) {
	MUQ_WARN("|signedDigest: Block too long");
    }
    job_Guarantee_Headroom( 20 );

    {   Vm_Obj*b = &jS.s[ (-block_size)-1 ]; /* Base of our block. */
	Vm_Int chars = 0;
	Vm_Int ints  = 0;
        Vm_Int i;
	for   (i = 0;   i < block_size;   ++i) {
	    Vm_Obj c = b[i];
	    if        (OBJ_IS_CHAR(c)) {
		buffer[ i ] = OBJ_TO_CHAR(c);
		++chars;
	    } else if (OBJ_IS_INT( c)) {
		buffer[ i ] = OBJ_TO_INT(c);
		++ints;
	    } else {
		MUQ_WARN("|signedDigest accepts only chars and fixnums");
	    }
        }
	{   Vm_Uch digest[     20 ];
	    Vm_Uch signature[  64 ];	/* 512 bits, SHA block size.	*/
	    int k   = 0;
	    {   Bnm_P s = BNM_P(sharedSecret);
		for (i = 0;  i < 64;   ++i)   signature[i] = 0;
		for (i = 0;  i < 64/VM_INTBYTES && i < s->length;    ++i) {
		    Vm_Unt u = s->slot[i];
		    int  j;
		    for	(j = 0;   j < VM_INTBYTES;  ++j) {
			signature[k++] = (u >> (j*8)) & 0xFF;
		    }
		}
	    }
            job_signeddigest( digest, signature, buffer, block_size );
	    if (chars > ints) {
		for (i = 0;   i < 20;   ++i) {
		    b[ block_size + i ] = OBJ_FROM_CHAR( digest[i] );
		}
	    } else {
		for (i = 0;   i < 20;   ++i) {
		    b[ block_size + i ] = OBJ_FROM_INT(  digest[i] );
		}
	    }
	    jS.s += 19;
           *jS.s  = OBJ_FROM_BLK( block_size + 20 );
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Signed_Digest_Check_Block -- "|signedDigestCheck" fn	*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Signed_Digest_Check_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Uch buffer[ MAX_STRING ];
    Vm_Int block_size = OBJ_TO_BLK( jS.s[-1] );
    Vm_Obj sharedSecret = jS.s[0];
    job_Guarantee_N_Args(               2 );
    job_Guarantee_Blk_Arg(             -1 );
    job_Guarantee_N_Args(    block_size+3 );
    if (block_size > MAX_STRING) {
	MUQ_WARN("|signedDigestCheck: Block too long");
    }
    if (block_size < 20) {
	MUQ_WARN("|signedDigestCheck: Block too short");
    }
    if (!OBJ_IS_BIGNUM(sharedSecret)
    || BNM_P(sharedSecret)->private != BNM_DIFFIE_HELLMAN_SHARED_SECRET
    ){
	MUQ_WARN("signature argument must be a #<DiffieHellmanSharedSecret>");
    }

    {   Vm_Obj* b = &jS.s[ (-block_size)-1 ]; /* Base of our block. */
	Vm_Uch old_digest[ 20 ];
        Vm_Int i;
	Vm_Uch signature[  64 ];	/* 512 bits, SHA block size.	*/
	int k   = 0;
	{   Bnm_P s = BNM_P(sharedSecret);
	    for (i = 0;  i < 64;   ++i)   signature[i] = 0;
	    for (i = 0;  i < 64/VM_INTBYTES && i < s->length;    ++i) {
		Vm_Unt u = s->slot[i];
		int  j;
		for	(j = 0;   j < VM_INTBYTES;  ++j) {
		    signature[k++] = (u >> (j*8)) & 0xFF;
		}
	    }
	}
	for   (i = 0;   i < 20;   ++i) {
	    Vm_Int j = (block_size-20)+i;
	    Vm_Obj c = b[j];
	    if        (OBJ_IS_CHAR(c)) {
		old_digest[ i ] = OBJ_TO_CHAR(c);
	    } else if (OBJ_IS_INT( c)) {
		old_digest[ i ] = OBJ_TO_INT(c);
	    } else {
		MUQ_WARN("|signedDigestCheck accepts only chars and ints");
	    }
	}
	for   (i = 0;   i < block_size-20;   ++i) {
	    Vm_Obj c = b[i];
	    if        (OBJ_IS_CHAR(c)) {
		buffer[ i ] = OBJ_TO_CHAR(c);
	    } else if (OBJ_IS_INT( c)) {
		buffer[ i ] = OBJ_TO_INT(c);
	    } else {
		MUQ_WARN("|signedDigestCheck accepts only chars and ints");
	    }
        }
	{   Vm_Uch digest[ 20 ];
	    Vm_Int differ = FALSE;
            job_signeddigest( digest, signature, buffer, block_size-20 );
	    for (i = 0;   i < 20;   ++i) {
		differ |= (old_digest[i] != digest[i]);
	    }
	    jS.s    -= 20;
            jS.s[ 0] = OBJ_FROM_BLK( block_size - 19 );
            jS.s[-1] = OBJ_FROM_BOOL( differ );
	}
    }
}

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
