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
/*-    Lyrics								*/
/************************************************************************/

/************************************************************************/
/* (With apologies to "The Gambler")                                    */
/*                                                                      */
/*                                                                      */
/* Working late on campus                                               */
/*   I was sitting by a hacker                                          */
/* trying to fix the last bug                                           */
/*   before he had to sleep                                             */
/* I was lost in the debugger                                           */
/*   thoroughly bewildered                                              */
/* when the hacker started linking                                      */
/*   and showed that he could speak!                                    */
/*                                                                      */
/* "Man, I've made a living                                             */
/*    out of fixing people's errors                                     */
/* And getting software working                                         */
/*    by hacking through the night                                      */
/* And frankly as a hacker                                              */
/*    you're a middlin' fair linebacker                                 */
/* For a taste of that there Twinkie                                    */
/*    I'll give you some advice"                                        */
/*                                                                      */
/* So I handed him my Twinkie                                           */
/*   and it vanished in a Twinkling                                     */
/* Then he grabbed my can of Jolt                                       */
/*   which he downed like Pepsi Lite                                    */
/* Then the night grew deathly quiet                                    */
/*   and his fingers started twitching                                  */
/* and he said: "If you're gonna play at hacking,                       */
/*   for chrissake do it right!"                                        */
/*                                                                      */
/* CHORUS:                                                              */
/*     You gotta:                                                       */
/*       know when to code 'em                                          */
/*       know when to modem                                             */
/*       know when to load 'em                                          */
/*       know when to run                                               */
/*     You don't think about the world                                  */
/*       when you're pounding on the keyboard                           */
/*     Reality can wait                                                 */
/*       'til the program's done.                                       */
/*                                                                      */
/*"Every hacker knows                                                   */
/*   the basic trick to coding                                          */
/* is knowing how to tune the code                                      */
/*   to run on given mips                                               */
/* 'cause every feature's buggy                                         */
/*   and every bug's a feature                                          */
/* and the most that you can hope for                                   */
/*   is to vest before it ships"                                        */
/*                                                                      */
/* (CHORUS)                                                             */
/*                                                                      */
/*                                                                      */
/*"Every hacker knows                                                   */
/*   the secret of debugging                                            */
/* is knowing when to single-step                                       */
/*   to pin down where it trips                                         */
/* 'cause every bug's a tough one                                       */
/*   and every bug's the last one                                       */
/* and the most that you can hope for                                   */
/*   is to vest before it ships"                                        */
/*                                                                      */
/* (CHORUS)                                                             */
/*                                                                      */
/*                                                                      */
/* Then he gave up speaking                                             */
/*   'cause his job had finished linking                                */
/* he verified the output                                               */
/*   and settled down to snooze                                         */
/* and sometime in the wee hours                                        */
/*   the hacker Fully Vested                                            */
/* but in his final output                                              */
/*   were some tricks that I could use:                                 */
/*                                                                      */
/* (CHORUS)                                                             */
/*                                                                      */
/*                                                                      */
/************************************************************************/

/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"
#include "jobprims.h"

/************************************************************************/
/*-    Statics								*/
/************************************************************************/


/************************************************************************/
/*-    Public fns, true prims for jobprims.c	 			*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_P_Pop_Block -- "]pop" operator.				*/
 /***********************************************************************/

void
job_P_Pop_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );

	/* Pop block: */
	jS.s -= i+2;
    }
}

 /***********************************************************************/
 /*-    job_P_Depth -- 							*/
 /***********************************************************************/

void
job_P_Depth(
    void
) {
    jS.s[1] = OBJ_FROM_INT(jS.s-jS.s_bot);
    ++jS.s;
}

 /***********************************************************************/
 /*-    job_P_Dup_Arg_Block -- |dup					*/
 /***********************************************************************/

void
job_P_Dup_Arg_Block(
    void
) {
    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    if (size < 1) MUQ_WARN ("Can't |dup empty block!");
    job_Guarantee_N_Args( size+2 );
    jS.s[1] = jS.s[-1];
    ++jS.s;
}

 /***********************************************************************/
 /*-    job_P_Dup_Args_Into_Block -- dup[				*/
 /***********************************************************************/

void
job_P_Dup_Args_Into_Block(
    void
) {
    Vm_Int n = OBJ_TO_INT( jS.s[0] );
    job_Guarantee_Int_Arg( 0 );
    if (n < 0) MUQ_WARN ("Can't dup[ negative argcount");
    job_Guarantee_N_Args(   n+1 );
    job_Guarantee_Headroom( n+1 );
    {   Vm_Obj* src = jS.s - n;
	*jS.s++ = OBJ_BLOCK_START;
	jS.s[n] = OBJ_FROM_BLK( n );
        while (n --> 0)   *jS.s++ = *src++;
    }
}

 /***********************************************************************/
 /*-    job_P_Dup_Bth -- dupBth					*/
 /***********************************************************************/

void
job_P_Dup_Bth(
    void
) {
    /* Read offset:   */
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    if (n <  0) MUQ_WARN ("Can't dupBth negative n.");
    job_Guarantee_N_Args( n+2 );

    /* Do it: */
    jS.s[0] = jS.s_bot[n+1];
}

 /***********************************************************************/
 /*-    job_P_Dup_First_Arg_Block -- |first				*/
 /***********************************************************************/

void
job_P_Dup_First_Arg_Block(
    void
) {
    /* Read blocksize and offset:   */
    Vm_Int b = OBJ_TO_BLK( jS.s[0] );

    /* Sanity checks: */
    job_Guarantee_Blk_Arg( 0 );
    if (b == 0) MUQ_WARN ("No |first value in empty block");
    job_Guarantee_N_Args( b+2 );

    /* Do it: */
    {   Vm_Obj result = jS.s[-b];
        *++jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Dup_Nth -- dupNth					*/
 /***********************************************************************/

void
job_P_Dup_Nth(
    void
) {
    /* Read offset:   */
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    if (n <  0) MUQ_WARN ("Can't dupNth negative n.");
    job_Guarantee_N_Args( n );

    /* Do it: */
    jS.s[0] = jS.s[-n];
}

 /***********************************************************************/
 /*-    job_P_Dup_Nth_Arg_Block -- |dupNth				*/
 /***********************************************************************/

void
job_P_Dup_Nth_Arg_Block(
    void
) {
    /* Read blocksize and offset:   */
    Vm_Int b = OBJ_TO_BLK( jS.s[-1] );
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Blk_Arg( -1 );
    if (n <  0) MUQ_WARN ("Can't |dupNth negative n!");
    if (n >= b) MUQ_WARN ("Can't |dupNth slot %d in size-%d block!",(int)n,(int)b);
    job_Guarantee_N_Args( b+3 );

    /* Do it: */
    jS.s[0] = jS.s[n-(b+1)];
}

 /***********************************************************************/
 /*-    job_P_Pop_Nth_From_Block -- |popNth				*/
 /***********************************************************************/

void
job_P_Pop_Nth_From_Block(
    void
) {
    /* Read blocksize and offset:   */
    Vm_Int b = OBJ_TO_BLK( jS.s[-1] );
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Blk_Arg( -1 );
    if (n <  0) MUQ_WARN ("Can't |popNth negative n!");
    if (n >= b) MUQ_WARN ("Can't |popNth slot %d in size-%d block!",(int)n,(int)b);
    job_Guarantee_N_Args( b+3 );

    /* Save value being popped: */
    {   Vm_Obj v = jS.s[n-(b+1)];

	/* Slide rest of block down one: */
	Vm_Int i;
	for (i = n;   i < b-1;   ++i) {
	    jS.s[i-(b+1)] = jS.s[i-b];
	}

	/* Save new block delimiter: */
	jS.s[ -2 ] = OBJ_FROM_BLK( b-1 );

	/* Save popped value: */
	jS.s[ -1 ] = v;

	/* Adjust stack depth: */
	--jS.s;
    }
}

 /***********************************************************************/
 /*-    job_P_Pop_Nth_And_Block -- ]popNth				*/
 /***********************************************************************/

void
job_P_Pop_Nth_And_Block(
    void
) {
    /* Read blocksize and offset:   */
    Vm_Int b = OBJ_TO_BLK( jS.s[-1] );
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Blk_Arg( -1 );
    if (n <  0) MUQ_WARN ("Can't ]popNth negative n!");
    if (n >= b) MUQ_WARN ("Can't ]popNth slot %d in size-%d block!",(int)n,(int)b);
    job_Guarantee_N_Args( b+3 );

    /* Save value being popped: */
    {   Vm_Obj v = jS.s[n-(b+1)];

	/* Pop block: */
	jS.s -= b+2;

	/* Save popped value: */
       *jS.s  = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Push_Nth_Into_Block -- |pushNth				*/
 /***********************************************************************/

void
job_P_Push_Nth_Into_Block(
    void
) {
    /* Read blocksize and offset:   */
    Vm_Int b = OBJ_TO_BLK( jS.s[-2] );
    Vm_Int v =             jS.s[-1]  ;
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Blk_Arg( -2 );
    if (n < 0) MUQ_WARN ("Can't |pushNth negative n!");
    if (n > b) MUQ_WARN ("Can't |pushNth slot %d in size-%d block!",(int)n,(int)b);
    job_Guarantee_N_Args( b+4 );

    /* Adjust stack depth: */
    --jS.s;

    {	/* Slide block up to open up slot n: */
	Vm_Int i;
	for (i = b-1;   i >= n;   --i) {
	    jS.s[i-b] = jS.s[i-(b+1)];
	}

	/* Compute new block size: */
	++b;

	/* Save new block delimiter: */
	jS.s[ 0 ] = OBJ_FROM_BLK( b );

	/* Store pushed value: */
	jS.s[ n-b ] = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Bracket_Position_In_Block -- |bracket-position		*/
 /***********************************************************************/

void
job_P_Bracket_Position_In_Block(
    void
) {
    /* Read blocksize and offset:   */
    Vm_Int size = OBJ_TO_BLK(  jS.s[-2] );
    Vm_Int left = OBJ_TO_CHAR( jS.s[-1] );
    Vm_Int roit = OBJ_TO_CHAR( jS.s[ 0] );
    Vm_Int deep = 0;

    /* Sanity checks: */
    job_Guarantee_Char_Arg(    0 );
    job_Guarantee_Char_Arg(   -1 );
    job_Guarantee_Blk_Arg(    -2 );
    job_Guarantee_N_Args( size+4 );

    {   Vm_Int i;
        for (i = 0;   i < size;   ++i) {

	    Vm_Obj val = jS.s[ i-size ];

	    /* Ignore non-integer values: */
	    if (!OBJ_IS_INT(val))   continue;

	    /* Convert to pure int: */
	    val = OBJ_TO_INT(val);

	    /* Ignore stuff inside double-quotes: */
	    if (val == '"') {
		for (++i;  i < size;   ++i) {
		    val = jS.s[ i-size ];
		    if (val == OBJ_FROM_INT('"')) break;
	    	}
		continue;
	    }

	    /* Count bracket nesting: */
	    if (val == left) {
		++deep;
		continue;
	    }
	    if (val == roit  &&  !deep--) {
		*--jS.s = OBJ_FROM_INT(i);
		return;
    }	}   }

    *--jS.s = OBJ_NIL;
}

 /***********************************************************************/
 /*-    job_P_Char_Position_In_Block -- |charPosition			*/
 /***********************************************************************/

void
job_P_Char_Position_In_Block(
    void
) {
    Vm_Uch buf[ 256 ];
    /* Read blocksize and offset:   */
    Vm_Int size = OBJ_TO_BLK( jS.s[-1] );
    Vm_Obj stg  =             jS.s[ 0]  ;
    Vm_Int len;

    /* Sanity checks: */
    job_Guarantee_Blk_Arg(    -1 );
    job_Guarantee_N_Args( size+3 );
    job_Guarantee_Stg_Arg(     0 );
    len = stg_Get_Bytes( buf, 256, stg, 0 );
    if (len == 256) MUQ_WARN("|charPosition string too long");
    {   Vm_Int i;
	for (i = 0;   i < size;   ++i) {
	    Vm_Obj val = jS.s[ i-(1+size) ];

	    /* Ignore non-integer values: */
	    if (OBJ_IS_INT(val)) {

		/* Convert to pure int: */
		val = OBJ_TO_INT(val);
	    } else if (OBJ_IS_CHAR(val)) {
		val = OBJ_TO_CHAR(val);
	    } else {
		continue;
	    }

	    /* Ignore stuff inside double-quotes: */
	    if (val == '"') {
		for (++i;  i < size;   ++i) {
		    val = jS.s[ i-size ];
		    if (val == OBJ_FROM_INT('"')) break;
	    	}
		continue;
	    }

	    /* Search to see if we've found one of our chars: */
	    {   Vm_Int j;
	    	for (j = 0;   j < len;   ++j) {
		    if (val == buf[j]) {
			*jS.s = OBJ_FROM_INT(i);
			return;
    }	}   }   }   }

    *jS.s = OBJ_NIL;
}

 /***********************************************************************/
 /*-    job_P_Position_In_Block -- |position				*/
 /***********************************************************************/

void
job_P_Position_In_Block(
    void
) {
    /* Read blocksize and offset:   */
    Vm_Int size = OBJ_TO_BLK( jS.s[-1] );
    Vm_Obj val  =             jS.s[ 0]  ;
    Vm_Int i;

    /* Sanity checks: */
    job_Guarantee_Blk_Arg(    -1 );
    job_Guarantee_N_Args( size+3 );
    job_ThunkN(                0 );

    --jS.s;
    if (obj_Eq_Via_Pointer_Is_Ok( val )) {

	for (i = 0;   i < size;   ++i) {
	    if (val == jS.s[ i-size ]) {
		*++jS.s = OBJ_FROM_INT(i);
		return;
	}   }

    } else {

	for (i = 0;   i < size;   ++i) {
	    if (!obj_Neql( val, jS.s[ i-size ])){
		*++jS.s = OBJ_FROM_INT(i);
		return;
    }	}   }

    *++jS.s = OBJ_NIL;
}

 /***********************************************************************/
 /*-    job_P_Set_Bth -- setBth					*/
 /***********************************************************************/

void
job_P_Set_Bth(
    void
) {
    /* Read val and offset:   */
    Vm_Int v =             jS.s[-1]  ;
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    if (n <  0) MUQ_WARN ("Can't setBth negative n!");
    job_Guarantee_N_Args( n+3 );

    /* Adjust stack depth: */
    jS.s -= 2;

    /* Store specified value: */
    jS.s_bot[ n+1 ] = v;
}

 /***********************************************************************/
 /*-    job_P_Set_Nth -- setNth					*/
 /***********************************************************************/

void
job_P_Set_Nth(
    void
) {
    /* Read val and offset:   */
    Vm_Int v =             jS.s[-1]  ;
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    if (n <  0) MUQ_WARN ("Can't setNth negative n!");
    job_Guarantee_N_Args( n+2 );

    /* Adjust stack depth: */
    jS.s -= 2;

    /* Store specified value: */
    jS.s[ -n ] = v;
}

 /***********************************************************************/
 /*-    job_P_Set_Nth_In_Block -- |setNth				*/
 /***********************************************************************/

void
job_P_Set_Nth_In_Block(
    void
) {
    /* Read blocksize and offset:   */
    Vm_Int b = OBJ_TO_BLK( jS.s[-2] );
    Vm_Int v =             jS.s[-1]  ;
    Vm_Int n = OBJ_TO_INT( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Blk_Arg( -2 );
    if (n <  0) MUQ_WARN ("Can't |setNth negative n!");
    if (n >= b) MUQ_WARN ("Can't |setNth slot %d in size-%d block!",(int)n,(int)b);
    job_Guarantee_N_Args( b+4 );

    /* Adjust stack depth: */
    jS.s -= 2;

    /* Store specified value: */
    jS.s[ n-b ] = v;
}
 /***********************************************************************/
 /*-    job_P_Stack_To_Block -- 					*/
 /***********************************************************************/

void
job_P_Stack_To_Block(
    void
) {
    /* Need room to add both [ and | */
    job_Guarantee_Headroom( 2 );

    /* Slide stack contents up to make */
    /* space at bottom for the [       */
    {   Vm_Obj* p = jS.s;
        for (p = jS.s;   p > jS.s_bot;   --p)   p[1] = p[0];
    }

    /* Insert [ and | */
    jS.s_bot[1] = OBJ_BLOCK_START;
    jS.s[    2] = OBJ_FROM_BLK( jS.s-jS.s_bot );
    jS.s  += 2;
}

 /***********************************************************************/
 /*-    job_P_Double_Block -- "|dup" operator.				*/
 /***********************************************************************/

void
job_P_Double_Block(
    void
) {

    /* Get size of block: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );
    {   Vm_Unt old_size = OBJ_TO_BLK(*jS.s);
	Vm_Int new_size = old_size << 1;
        job_Guarantee_N_Args( old_size+2 );

	/* Grow block: */
	job_Guarantee_Headroom( old_size );
	{   register Vm_Obj* rat = &jS.s[       -1 ];
	    register Vm_Obj* cat = &jS.s[ old_size ];
	    register Vm_Int  i   = old_size;
	    jS.s   = cat;
	    *cat-- = OBJ_FROM_BLK( new_size );
	    while (i --> 0) {
		register Vm_Obj v = *rat--;
		*cat-- = v;
		*cat-- = v;
    }   }   }
}

 /***********************************************************************/
 /*-    job_P_Delete_Arg_Block -- "|delete" operator.			*/
 /***********************************************************************/

void
job_P_Delete_Arg_Block(
    void
) {
    /* Get size of block: */
    job_Guarantee_N_Args(   2 );	/* Arg plus blocksize */
    job_Guarantee_Blk_Arg( -1 );
    {   Vm_Unt old_size = OBJ_TO_BLK(jS.s[-1]);
	Vm_Obj cheese   =            jS.s[ 0] ;
        job_Guarantee_N_Args( old_size+3 );

	/* Shrink block: */
	{   Vm_Obj* mat = &jS.s[ -1-old_size ]; /* 1st slot in block.	*/
	    Vm_Obj* cat = mat;			/* Copy-to   ptr.	*/
	    Vm_Obj* rat = cat;			/* Copy-from ptr.	*/
	    Vm_Obj* vat = &jS.s[ -1          ]; /* 1st slot past block.	*/

	    /* Cat chases rat from mat to vat: */
	    while (rat < vat) {

		/* Cat stops if it smells cheese: */
		if (obj_Neql( *rat, cheese ))   *cat++ = *rat;

		/* Rat is too scared to ever stop: */
		++rat;
	    }

	    /* Write down how far cat got from mat: */
	    *cat = OBJ_FROM_BLK( cat-mat );
	    jS.s = cat;
    }   }
}

 /***********************************************************************/
 /*-    job_P_Delete_Nonchars_Block -- "|deleteNonchars" function.	*/
 /***********************************************************************/

void
job_P_Delete_Nonchars_Block(
    void
) {
    /* Get size of block: */
    Vm_Unt old_size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args( old_size+2 );

    /* Shrink block: */
    {   Vm_Obj* mat = &jS.s[ -old_size ]; /* 1st slot in block.	*/
	Vm_Obj* cat = mat;		  /* Copy-to   ptr.	*/
	Vm_Obj* rat = cat;		  /* Copy-from ptr.	*/
	Vm_Obj* vat = &jS.s[  0        ]; /* 1st slot past block*/

	/* Cat chases rat from mat to vat: */
	while (rat < vat) {

	    /* Rat is too scared to ever stop:  */
	    Vm_Obj val = *rat++;

	    /* Cat stops if it smells nonchars: */
	    if (OBJ_IS_CHAR(val))   *cat++ = val;
	}

	/* Write down how far cat got from mat: */
	*cat = OBJ_FROM_BLK( cat-mat );
	jS.s = cat;
    }
}

 /***********************************************************************/
 /*-    job_P_Drop_Keys_Block -- "|vals" operator.			*/
 /***********************************************************************/

void
job_P_Drop_Keys_Block(
    void
) {

    /* Get size of block: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );
    {   Vm_Unt old_size = OBJ_TO_BLK(*jS.s);
	Vm_Unt new_size = old_size >> 1;
        job_Guarantee_N_Args( old_size+1 );
	if (old_size & 1)  MUQ_WARN ("|keys needs even-sized block");

	/* Shrink block: */
	{   register Vm_Obj* cat = &jS.s[ -old_size ];
	    register Vm_Obj* rat = cat;
	    register Vm_Int  i   = new_size;
	    while (i --> 0) {
		*cat++ = *++rat;
		++rat;
	    }
	    *cat = OBJ_FROM_BLK( new_size );
	    jS.s = cat;
    }   }
}

 /***********************************************************************/
 /*-    job_P_Drop_Vals_Block -- "|keys" operator.			*/
 /***********************************************************************/

void
job_P_Drop_Vals_Block(
    void
) {

    /* Get size of block: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );
    {   Vm_Unt old_size = OBJ_TO_BLK(*jS.s);
	Vm_Unt new_size = old_size >> 1;
        job_Guarantee_N_Args( old_size+2 );
	if (old_size & 1)  MUQ_WARN ("|keys needs even-sized block");

	/* Shrink block: */
	{   register Vm_Obj* cat = &jS.s[ -old_size ];
	    register Vm_Obj* rat = cat;
	    register Vm_Int  i   = new_size;
	    while (i --> 0) {
		*cat++ = *rat;
		rat   += 2;
	    }
	    *cat = OBJ_FROM_BLK( new_size );
	    jS.s = cat;
    }   }
}

 /***********************************************************************/
 /*-    job_P_End_Block -- "|" operator.				*/
 /***********************************************************************/

void
job_P_End_Block(
    void
) {

    /* Search stack for [ marker: */
    register Vm_Obj*  s   = jS.s    ;
    register Vm_Obj*  bot = jS.s_bot;
    for ( ;   s >= bot;   --s) {
	if (*s == OBJ_BLOCK_START) {

	    /* Found [ marker. Add a count of    */
	    /* block elements and return:        */
	    Vm_Int size = jS.s - s;
	    *++jS.s = OBJ_FROM_BLK( size  );
	    return;
    }   }

    MUQ_WARN ("'|' has no matching '['!");
}

 /***********************************************************************/
 /*-    job_P_Get_Val_Block -- "|get" operator.				*/
 /***********************************************************************/



Vm_Obj
job_Get_Val_Block(
    Vm_Obj deflt,
    Vm_Int size
) {
    Vm_Int i;
    Vm_Obj key0 = *jS.s--;

    /* Allow odd sizes: */
    Vm_Int lim = size & ~1;
	
    if (obj_Eq_Via_Pointer_Is_Ok( key0 )) {

	for (i = 0;   i < lim;   i += 2) {
	    if (key0 ==          jS.s[ (i-size)    ]) {
		return           jS.s[ (i-size) +1 ];
	}   }

    } else {

	for (i = 0;   i < lim;   i += 2) {
	    if (!obj_Neql( key0, jS.s[ (i-size)    ])){
		return           jS.s[ (i-size) +1 ];
    }	}   }

    return deflt;
}

static int
job_get_val_block(
    Vm_Obj deflt,
    Vm_Int size
) {
    Vm_Int i;
    Vm_Obj key0 = *jS.s--;

    /* Allow odd sizes: */
    Vm_Int lim = size & ~1;
	
    if (obj_Eq_Via_Pointer_Is_Ok( key0 )) {

	for (i = 0;   i < lim;   i += 2) {
	    if (key0 ==          jS.s[ (i-size)    ]) {
		jS.s[1]        = jS.s[ (i-size) +1 ];
		++jS.s;
		return &jS.s[(i-size)-1] - jS.s_bot;
	}   }

    } else {

	for (i = 0;   i < lim;   i += 2) {
	    if (!obj_Neql( key0, jS.s[ (i-size)    ])){
		jS.s[1] =        jS.s[ (i-size) +1 ];
		++jS.s;
		return &jS.s[(i-size)-1] - jS.s_bot;
    }	}   }

    *++jS.s = deflt;
    return 0;
}

void
job_P_Get_Val_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int size = OBJ_TO_BLK( jS.s[-1] );
    job_Guarantee_N_Args(           2  );
    job_ThunkN(                     0  );
    job_Guarantee_Blk_Arg(         -1  );
    /* We deliberately allow odd-size blocks */
    /* here, in support of datagrams (&tc)   */
    /* with keyval headers and char bodies.  */
    job_Guarantee_N_Args( size+3 );

    job_get_val_block( OBJ_NIL, size );
}

 /***********************************************************************/
 /*-    job_P_Ged_Val_Block -- "|ged" operator.				*/
 /***********************************************************************/

void
job_P_Ged_Val_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Obj deflt  =             jS.s[ 0]  ;
    Vm_Int size   = OBJ_TO_BLK( jS.s[-2] );
    job_Guarantee_N_Args(             3  );
    job_ThunkN(                       0  );
    job_ThunkN(                      -1  );
    job_Guarantee_Blk_Arg(           -2  );
    /* We deliberately allow odd-size blocks */
    /* here, in support of datagrams (&tc)   */
    /* with keyval headers and char bodies.  */
    job_Guarantee_N_Args( size+4 );
    --jS.s;
    job_get_val_block( deflt, size );
}

 /***********************************************************************/
 /*-    job_P_Ped_Val_Block -- "|gep" operator.				*/
 /***********************************************************************/

void
job_P_Gep_Val_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Obj deflt  =             jS.s[ 0]  ;
    Vm_Int size   = OBJ_TO_BLK( jS.s[-2] );
    job_Guarantee_N_Args(             3  );
    job_ThunkN(                       0  );
    job_ThunkN(                      -1  );
    job_Guarantee_Blk_Arg(           -2  );
    /* We deliberately allow odd-size blocks */
    /* here, in support of datagrams (&tc)   */
    /* with keyval headers and char bodies.  */
    job_Guarantee_N_Args( size+4 );
    --jS.s;
    {   int i = job_get_val_block( deflt, size );
        if (i) {
	    Vm_Obj* d = jS.s_bot+i;
	    Vm_Obj* s = d+2;
	    do{ *d++ = *s++; } while (s <= jS.s);
	    jS.s -= 2;
	    jS.s[-1] = OBJ_FROM_BLK( size-2 );
    }	}
}

 /***********************************************************************/
 /*-    job_P_Set_Val_Block -- "|set" operator.				*/
 /***********************************************************************/

void
job_P_Set_Val_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int i;
    Vm_Obj val0 =             jS.s[ 0]  ;
    Vm_Obj key0 =             jS.s[-1]  ;
    Vm_Int size = OBJ_TO_BLK( jS.s[-2] );
    Vm_Int lim  = size & ~1;
    job_Guarantee_N_Args(           3  );
    job_ThunkN(                     0  );
    job_ThunkN(                    -1  );
    job_Guarantee_Blk_Arg(         -2  );
    /* We deliberately allow odd-size blocks */
    /* here, in support of datagrams (&tc)   */
    /* with keyval headers and char bodies.  */
    job_Guarantee_N_Args( size+4 );

    jS.s -= 2;
    if (obj_Eq_Via_Pointer_Is_Ok( key0 )) {

	for (i = 0;   i < lim;   i += 2) {
	    if (jS.s[ (i-size)    ] == key0) {
		jS.s[ (i-size) +1 ] =  val0;
		return;
	}   }

    } else {

	for (i = 0;   i < lim;   i += 2) {
	    if (!obj_Neql(
		jS.s[ (i-size)    ],  key0
	    ) ) {
		jS.s[ (i-size) +1 ] = val0;
		return;
    }	}   }

    /* Push new keyval pair onto block: */
    jS.s       += 2;
    jS.s[ -2 ]  = key0;
    jS.s[ -1 ]  = val0;
    jS.s[  0 ]  = OBJ_FROM_BLK( size + 2 );
}


 /***********************************************************************/
 /*-    job_P_Pop_From_Block -- "|pop" operator.			*/
 /***********************************************************************/

void
job_P_Pop_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (!i) MUQ_WARN ("Can't '|pop' empty block");
	/* Pop one element from block: */
	jS.s[ 0] = jS.s[-1];
	jS.s[-1] = OBJ_FROM_BLK( i-1 );
    }
}

 /***********************************************************************/
 /*-    job_P_Popp_From_Block -- "|popp" operator.			*/
 /***********************************************************************/

void
job_P_Popp_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (!i) MUQ_WARN ("Can't '|popp' empty block");
	/* Pop and discard one element from block: */
	*--jS.s = OBJ_FROM_BLK( i-1 );
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_And_Pop -- "]shift" operator.			*/
 /***********************************************************************/

void
job_P_Shift_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (!i) MUQ_WARN ("Can't ']shift' empty block");
	jS.s -= i+1;
	jS.s[0] = jS.s[1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_2_And_Pop -- "]shift2" operator.			*/
 /***********************************************************************/

void
job_P_Shift_2_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (i<2) MUQ_WARN ("']shift2' block too small");
	jS.s -= i;
	jS.s[-1] = jS.s[0];
	jS.s[ 0] = jS.s[1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_3_And_Pop -- "]shift3" operator.			*/
 /***********************************************************************/

void
job_P_Shift_3_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (i<3) MUQ_WARN ("']shift3' block too small");
	jS.s -= i-1;
	jS.s[-2] = jS.s[-1];
	jS.s[-1] = jS.s[ 0];
	jS.s[ 0] = jS.s[ 1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_4_And_Pop -- "]shift4" operator.			*/
 /***********************************************************************/

void
job_P_Shift_4_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (i<4) MUQ_WARN ("']shift4' block too small");
	jS.s -= i-2;
	jS.s[-3] = jS.s[-2];
	jS.s[-2] = jS.s[-1];
	jS.s[-1] = jS.s[ 0];
	jS.s[ 0] = jS.s[ 1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_5_And_Pop -- "]shift5" operator.			*/
 /***********************************************************************/

void
job_P_Shift_5_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (i<5) MUQ_WARN ("']shift5' block too small");
	jS.s -= i-3;
	jS.s[-4] = jS.s[-3];
	jS.s[-3] = jS.s[-2];
	jS.s[-2] = jS.s[-1];
	jS.s[-1] = jS.s[ 0];
	jS.s[ 0] = jS.s[ 1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_6_And_Pop -- "]shift6" operator.			*/
 /***********************************************************************/

void
job_P_Shift_6_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (i<6) MUQ_WARN ("']shift6' block too small");
	jS.s -= i-4;
	jS.s[-5] = jS.s[-4];
	jS.s[-4] = jS.s[-3];
	jS.s[-3] = jS.s[-2];
	jS.s[-2] = jS.s[-1];
	jS.s[-1] = jS.s[ 0];
	jS.s[ 0] = jS.s[ 1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_7_And_Pop -- "]shift7" operator.			*/
 /***********************************************************************/

void
job_P_Shift_7_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (i<7) MUQ_WARN ("']shift7' block too small");
	jS.s -= i-5;
	jS.s[-6] = jS.s[-5];
	jS.s[-5] = jS.s[-4];
	jS.s[-4] = jS.s[-3];
	jS.s[-3] = jS.s[-2];
	jS.s[-2] = jS.s[-1];
	jS.s[-1] = jS.s[ 0];
	jS.s[ 0] = jS.s[ 1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_8_And_Pop -- "]shift8" operator.			*/
 /***********************************************************************/

void
job_P_Shift_8_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (i<8) MUQ_WARN ("']shift8' block too small");
	jS.s -= i-6;
	jS.s[-7] = jS.s[-6];
	jS.s[-6] = jS.s[-5];
	jS.s[-5] = jS.s[-4];
	jS.s[-4] = jS.s[-3];
	jS.s[-3] = jS.s[-2];
	jS.s[-2] = jS.s[-1];
	jS.s[-1] = jS.s[ 0];
	jS.s[ 0] = jS.s[ 1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_9_And_Pop -- "]shift9" operator.			*/
 /***********************************************************************/

void
job_P_Shift_9_And_Pop(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+2 );
	if (i<9) MUQ_WARN ("']shift9' block too small");
	jS.s -= i-7;
	jS.s[-8] = jS.s[-7];
	jS.s[-7] = jS.s[-6];
	jS.s[-6] = jS.s[-5];
	jS.s[-5] = jS.s[-4];
	jS.s[-4] = jS.s[-3];
	jS.s[-3] = jS.s[-2];
	jS.s[-2] = jS.s[-1];
	jS.s[-1] = jS.s[ 0];
	jS.s[ 0] = jS.s[ 1];
    }
}

 /***********************************************************************/
 /*-    job_P_Shift_From_Block -- "|shift" operator.			*/
 /***********************************************************************/

void
job_P_Shift_From_Block(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_BLK(*jS.s);
        register Vm_Obj*s;
	Vm_Unt len = i;
        job_Guarantee_N_Args( i+2 );
	if (!i) MUQ_WARN ("Can't '|shift' empty block");
	/* Shift one element from block: */
	jS.s[ 0] = jS.s[-i];
	for (s = &jS.s[-i];   --i > 0;   ++s) {
	    s[0] = s[1];
	}
	jS.s[-1] = OBJ_FROM_BLK( len-1 );
    }
}

 /***********************************************************************/
 /*-    job_P_Shiftp_From_Block -- "|shiftp" operator.			*/
 /***********************************************************************/

void
job_P_Shiftp_From_Block(
    void
) {
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_BLK(*jS.s);
        register Vm_Obj*s;
	Vm_Unt len = i;
        job_Guarantee_N_Args( i+2 );
	if (!i) MUQ_WARN ("Can't '|shiftp' empty block");
	/* Shift and discard one element from block: */
	for (s = &jS.s[-i];   --i > 0;   ++s) {
	    s[0] = s[1];
	}
	*--jS.s = OBJ_FROM_BLK( len-1 );
    }
}

 /***********************************************************************/
 /*-    job_P_Shiftp_N_From_Block -- "|shiftpN" operator.		*/
 /***********************************************************************/

void
job_P_Shiftp_N_From_Block(
    void
) {
    Vm_Unt n = OBJ_TO_INT(jS.s[ 0]);
    Vm_Unt b = OBJ_TO_BLK(jS.s[-1]);

    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Blk_Arg( -1 );

    job_Guarantee_N_Args( n+2 );
    if (b < n) MUQ_WARN("Can't |shiftpN more args than block contains");

    {   /* Shift and discard N elements from block: */
	register Vm_Unt i   = b-n;
        register Vm_Obj*s;
	for (s = &jS.s[-1-b];   i --> 0;   ++s) {
	    s[0] = s[n];
	}
	jS.s -= n;
	*--jS.s = OBJ_FROM_BLK( b-n );
    }
}

 /***********************************************************************/
 /*-    job_P_Unshift_Into_Block -- "|unshift" operator.		*/
 /***********************************************************************/

void
job_P_Unshift_Into_Block(
    void
) {
    job_Guarantee_Blk_Arg( -1 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_BLK(jS.s[-1]);
        register Vm_Obj*s;
	Vm_Obj o = *jS.s;
        job_Guarantee_N_Args( i+3 );
	/* Pop one element from block: */
	jS.s[0] = OBJ_FROM_BLK( i+1 );
	for (s = jS.s-1;   i --> 0;   --s) {
	    s[0] = s[-1];
	}
	*s = o;
    }
}

 /***********************************************************************/
 /*-    job_P_Push_Into_Block -- "|push" operator.			*/
 /***********************************************************************/

void
job_P_Push_Into_Block(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Blk_Arg( -1 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_BLK( jS.s[ -1 ] );
        job_Guarantee_N_Args( i+3 );
	/* Push top-of-stack into block: */
	jS.s[-1] = jS.s[0];
	jS.s[ 0] = OBJ_FROM_BLK( i+1 );
    }
}

 /***********************************************************************/
 /*-    job_P_Extract -- "|extract[" function.				*/
 /***********************************************************************/

void
job_P_Extract(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int len = OBJ_TO_BLK( jS.s[ -2 ]  );
    Vm_Int lo  = OBJ_TO_INT( jS.s[ -1 ]  );
    Vm_Int hi  = OBJ_TO_INT( jS.s[  0 ]  );
    job_Guarantee_N_Args(           3 );
    job_Guarantee_Blk_Arg(         -2 );
    job_Guarantee_Int_Arg(         -1 );
    job_Guarantee_Int_Arg(          0 );
    job_Guarantee_N_Args(       len+4 );

    if (lo < 0  ) MUQ_WARN ("|extract[ lower limit too small: %d",(int)lo);
    if (lo > len) MUQ_WARN ("|extract[ lower limit too big: %d",(int)lo);
    if (hi > len) MUQ_WARN ("|extract[ upper limit too big: %d",(int)hi);
    if (hi < lo ) MUQ_WARN ("|extract[ limits misordered: %d,%d",(int)lo,(int)hi);

    {   /* Ensure we have room to push new block: */
        Vm_Int sublen = hi-lo;
	job_Guarantee_Headroom( sublen );

	/* Build new block: */
	jS.s[-1] = OBJ_BLOCK_START;
	{   register Vm_Obj* dst   = &jS.s[ 0          ];
	    register Vm_Obj* src   = &jS.s[ lo-(2+len) ];
	    register Vm_Int  i;
	    for (i = 0;   i < sublen;   ++i) {
		dst[ i ] = src[ i ];
	    }
	    jS.s[ sublen ] = OBJ_FROM_BLK(sublen);

            /* Delete new block from old block: */
	    jS.s[ -2 ] = OBJ_FROM_BLK( len - sublen );
	    dst = src;
	    src = dst + sublen;		
	    for (i = jS.s+sublen+2-src;  --i > 0; ) {
		*dst++ = *src++;
	    }
        }
    }
}

 /***********************************************************************/
 /*-    job_P_Subblock -- "|subblock[" function.			*/
 /***********************************************************************/

void
job_P_Subblock(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int len = OBJ_TO_BLK( jS.s[ -2 ]  );
    Vm_Int lo  = OBJ_TO_INT( jS.s[ -1 ]  );
    Vm_Int hi  = OBJ_TO_INT( jS.s[  0 ]  );
    job_Guarantee_N_Args(           3 );
    job_Guarantee_Blk_Arg(         -2 );
    job_Guarantee_Int_Arg(         -1 );
    job_Guarantee_Int_Arg(          0 );
    job_Guarantee_N_Args(       len+4 );

    if (lo < 0  ) MUQ_WARN ("|subblock[ lower limit too small: %d",(int)lo);
    if (lo > len) MUQ_WARN ("|subblock[ lower limit too big: %d",(int)lo);
    if (hi > len) MUQ_WARN ("|subblock[ upper limit too big: %d",(int)hi);
    if (hi < lo ) MUQ_WARN ("|subblock[ limits misordered: %d,%d",(int)lo,(int)hi);

    /* Ensure we have room to push new block: */
    {   Vm_Int sublen = hi-lo;
	job_Guarantee_Headroom( sublen );

	/* Build new block: */
	jS.s[-1] = OBJ_BLOCK_START;
	{   register Vm_Obj* src   = &jS.s[ lo-(2+len) ];
	    register Vm_Int  i;
	    for (i = 0;   i < sublen;   ++i) {
		jS.s[ i ] = src[ i ];
	    }
	    jS.s += sublen;
	    *jS.s = OBJ_FROM_BLK(sublen);
    }   }
}

 /***********************************************************************/
 /*-    job_P_Tr_Block -- "|tr" operator.				*/
 /***********************************************************************/

void
job_P_Tr_Block(
    void
) {
    Vm_Uch src_buf[ 256 ];
    Vm_Uch dst_buf[ 256 ];
    Vm_Int buf_len;

    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( jS.s[-2] );
    Vm_Obj src_stg    =             jS.s[-1]  ;
    Vm_Obj dst_stg    =             jS.s[ 0]  ;

    job_Guarantee_Blk_Arg(               -2  );
    job_Guarantee_Stg_Arg(               -1  );
    job_Guarantee_Stg_Arg(                0  );

    job_Guarantee_N_Args(    block_size+4 );

    buf_len = stg_Get_Bytes( src_buf, 256, src_stg, 0 );
    if (buf_len == 256) MUQ_WARN("|tr src string too long");
    if (buf_len != stg_Get_Bytes( dst_buf, 256, dst_stg, 0 )) {
	MUQ_WARN("|tr arg strings not same length");
    }

    /* Find block, reverse it: */
    {   register Vm_Obj* p     = &jS.s[ -2-block_size ];
	register Vm_Int  i     = block_size;
	register Vm_Int  j;
	register Vm_Obj  o;
	register Vm_Int  c;
	for (; i --> 0; ++p) {
	    o = *p;
	    if (OBJ_IS_CHAR(o)) {
		c = OBJ_TO_CHAR(o);
		for (j = 0;   j < buf_len;   ++j) {
		    if (src_buf[j] == c) {
			*p = OBJ_FROM_CHAR( dst_buf[j] );
			break;
		    }
		}
	    } else if (OBJ_IS_INT(o)) {
		c = OBJ_TO_INT(o);
		if (c >= 256)   continue;
		for (j = 0;   j < buf_len;   ++j) {
		    if (src_buf[j] == c) {
			*p = OBJ_FROM_INT( dst_buf[j] );
			break;
		    }
		}
	    }
	}
    }
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Dup_Block -- "|dup[" operator.				*/
 /***********************************************************************/

void
job_P_Dup_Block(
    void
) {

    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_Blk_Arg(              0 );
    job_Guarantee_N_Args(    block_size+2 );
    job_Guarantee_Headroom(  block_size+2 );

    /* Find block, reverse it: */
    {   register Vm_Obj* src   = &jS.s[ -2-block_size ]; /* [ symbol */
	register Vm_Obj* dst   = &jS.s[  0            ];
	register Vm_Int  i     = block_size+2;
	while (i --> 0)   *++dst = *++src;
    }
    jS.s += block_size+2;
}

 /***********************************************************************/
 /*-    job_P_Reverse_Block -- "|reverse" operator.			*/
 /***********************************************************************/

void
job_P_Reverse_Block(
    void
) {

    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size <= 1)   return;
    job_Guarantee_N_Args(    block_size+2 );

    /* Find block, reverse it: */
    {   register Vm_Obj* bot   = &jS.s[ -block_size ]; /* Base of our block. */
	register Vm_Obj* top   = &jS.s[ -         1 ];
	register Vm_Int  i     = block_size >> 1;
	register Vm_Obj  tmp;
	while (i --> 0) { tmp = *bot; *bot++ = *top; *top-- = tmp; }
    }
}

 /***********************************************************************/
 /*-    job_P_Downcase -- "downcase" operator.				*/
 /***********************************************************************/

void
job_P_Downcase(
    void
) {
    Vm_Obj o = *jS.s ;
    job_Guarantee_N_Args( 1 );

    if (OBJ_IS_CHAR(o)) {
	*jS.s=OBJ_FROM_CHAR(tolower(OBJ_TO_CHAR(o)));
    } else if (OBJ_IS_INT( o)) {
	int c = OBJ_TO_INT(o);
	if (c < 256) {
	    *jS.s=OBJ_FROM_INT( tolower(c) );
	}
    }	
}

 /***********************************************************************/
 /*-    job_P_Upcase -- "upcase" operator.				*/
 /***********************************************************************/

void
job_P_Upcase(
    void
) {
    Vm_Obj o = *jS.s ;
    job_Guarantee_N_Args( 1 );

    if (OBJ_IS_CHAR(o)) {
	*jS.s=OBJ_FROM_CHAR(toupper(OBJ_TO_CHAR(o)));
    } else if (OBJ_IS_INT( o)) {
	int c = OBJ_TO_INT(o);
	if (c < 256) {
	    *jS.s=OBJ_FROM_INT( toupper(c) );
	}
    }	
}

 /***********************************************************************/
 /*-    job_P_Upcase_Block -- "|upcase" operator.			*/
 /***********************************************************************/

void
job_P_Upcase_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (!block_size)         return;
    job_Guarantee_N_Args(    block_size+2 );

    /* Find block, reverse it: */
    {   register Vm_Obj* p   = &jS.s[ -block_size ]; /* Base of our block. */
	register Vm_Int  i   = block_size;
	register Vm_Obj  o;
	register Vm_Int  c;
	for (i = block_size;  i --> 0;   ++p) {
	    o = *p;
	    if (OBJ_IS_CHAR(o)) {
		*p=OBJ_FROM_CHAR(toupper(OBJ_TO_CHAR(o)));
	    } else if (OBJ_IS_INT( o)) {
		c = OBJ_TO_INT(o);
		if (c < 256) {
		    *p=OBJ_FROM_INT( toupper(c) );
		}
	    }	
	}		
    }
}

 /***********************************************************************/
 /*-    job_P_Downcase_Block -- "|downcase" operator.			*/
 /***********************************************************************/

void
job_P_Downcase_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (!block_size)         return;
    job_Guarantee_N_Args(    block_size+2 );

    /* Find block, reverse it: */
    {   register Vm_Obj* p   = &jS.s[ -block_size ]; /* Base of our block. */
	register Vm_Int  i   = block_size;
	register Vm_Obj  o;
	register Vm_Int  c;
	for (i = block_size;  i --> 0;   ++p) {
	    o = *p;
	    if (OBJ_IS_CHAR(o)) {
		*p=OBJ_FROM_CHAR(tolower(OBJ_TO_CHAR(o)));
	    } else if (OBJ_IS_INT( o)) {
		c = OBJ_TO_INT(o);
		if (c < 256) {
		    *p=OBJ_FROM_INT( tolower(c) );
		}
	    }	
	}		
    }
}

 /***********************************************************************/
 /*-    job_P_Reverse_Keysvals_Block -- "|keysvals-reverse" operator.	*/
 /***********************************************************************/

void
job_P_Reverse_Keysvals_Block(
    void
) {

    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size <= 2)   return;
    if (block_size  & 1)   MUQ_WARN ("|reverse-pairs needs even-sized block!");
    job_Guarantee_N_Args(    block_size+2 );

    /* Find block, reverse it: */
    {   register Vm_Obj* bot   = &jS.s[ -block_size ]; /* Base of our block. */
	register Vm_Obj* top   = &jS.s[ -         2 ];
	register Vm_Int  i     = block_size >> 2;
	register Vm_Obj  tmp;
	while (i --> 0) {
            tmp  = bot[0];  bot[0] = top[0]; top[0] = tmp;
            tmp  = bot[1];  bot[1] = top[1]; top[1] = tmp;
	    bot += 2;
	    top -= 2;
    }   }
}

 /***********************************************************************/
 /*-    job_P_Rotate_Block -- "|rotate" operator.			*/
 /***********************************************************************/

void
job_P_Rotate_Block(
    void
) {
    /* Get size of block: */
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Blk_Arg( -1 );
    {	Vm_Int dist = OBJ_TO_INT( jS.s[ 0] );
        Vm_Int size = OBJ_TO_BLK( jS.s[-1] );
	if (size <  0)   MUQ_WARN ("Negative block size?!");
	--jS.s;
	if (size == 0)   return;
        job_Guarantee_N_Args( size+2 );
	while (dist < 0   )  dist += size;
	while (dist > size)  dist -= size;

	/* If dist and size are relatively  */
	/* prime, we can do the rotation in */
	/* one pass.  In general it takes   */
	/* gcd(dist,size) passes:           */
	{   Vm_Int pass = job_Gcd( dist, size );
	    Vm_Int len  = size / pass;

	    register Vm_Obj* s = &jS.s[ -size ];
	    while (pass --> 0) {

		/* Rotate block: */
		register Vm_Int  i = pass;	/* Starting slot.	*/
	        register Vm_Obj  c = s[i];	/* Make an empty slot.	*/
		register Vm_Int  p = len-1;	/* # steps in pass.	*/
		while (p --> 0) {
		    register Vm_Int j  = i+dist;/* Next slot from i.	*/
		    if (j > size)   j -= size;	/* Wrap around correctly*/
		    s[i] = s[j];		/* Move one value.	*/
		    i    = j;			/* Next slot to fill.	*/
		}
		s[i] = c;			/* Fill empty slot.	*/
    }   }   }
}

 /***********************************************************************/
 /*-    job_P_Seq_Block -- "seq[" operator.				*/
 /***********************************************************************/

void
job_P_Seq_Block(
    void
) {
    /* Get size for block: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    {   Vm_Int size = OBJ_TO_INT(*jS.s);
	job_Guarantee_Headroom( size+1 );

	/* Create block: */
	*jS.s++ = OBJ_BLOCK_START;
	{   Vm_Int i;
	    for (i = 0;   i < size;   ++i) {
		jS.s[i] = OBJ_FROM_INT(i);
	}   }
	jS.s   += size;
       *jS.s = OBJ_FROM_BLK(size);
    }
}

 /***********************************************************************/
 /*-    job_P_Unsort_Block -- "|unsort" operator.			*/
 /***********************************************************************/

/* This is just sort-block with random sort. */

#undef  RANDOM
#if   defined( HAVE_RANDOM )
#define RANDOM random
#else
#define RANDOM rand
#endif

void
job_P_Unsort_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size <= 1)   return;
    job_Guarantee_N_Args(    block_size+2 );

    {
	#undef  SIFT_UP
	#define SIFT_UP							    \
	{   Vm_Int hole = left;						    \
	    for (;;) {							    \
		Vm_Int R    = (hole+1)<<1;	/* Right kid of hole. */    \
		Vm_Int L    = R-1;		/* Left  kid of hole. */    \
		Vm_Int maxkid;			/* Max   kid of hole. */    \
									    \
		/* If kids L,R don't exist, can just put 'key' in hole: */  \
		if (L >= roit)            {  b[hole] = key;  break; }	    \
									    \
		/* Set maxkid to largest of hole's two kids, L and R:   */  \
		maxkid = (R < roit && (RANDOM()&16)) ? R : L;	    	    \
									    \
		/* If 'key' > maxkid, put 'key' in hole and stop: */	    \
		if (RANDOM()&16) { b[hole] = key; break; }	    	    \
									    \
		/* Biggest kid fills hole, loop to fill new hole: */	    \
		b[hole] = b[maxkid];					    \
		hole    = maxkid;					    \
        }   }\

	/* Find block, initialize 'left' and 'roit': */
	Vm_Obj* b    = &jS.s[ -block_size ]; /* Base of our block. */
	Vm_Int  left = block_size/2 +1;	     /* Heap is slots k:   */
	Vm_Int  roit = block_size     ;	     /* left <= k < roit.  */
	Vm_Obj  key;

	/* Heap-build followed by heap-unbuild phases: */
	while (left-->0) { key = b[left];                 SIFT_UP; }  ++left;
	while (roit-->1) { key = b[roit]; b[roit] = b[0]; SIFT_UP; }
    }
}
#undef RANDOM

 /***********************************************************************/
 /*-    job_P_Sort_Block -- "|sort" operator.				*/
 /***********************************************************************/

void
job_P_Sort_Block(
    void
) {

    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size <= 1)   return;
    job_Guarantee_N_Args(    block_size+2 );

    /* Heapsort following Knuth.  Heapsort's best case is */
    /* about half as fast as Quicksort's best case, but	  */
    /* Heapsort's worst case is much the same as its best */
    /* case, while Quicksort's worst case is disastrous.  */
    /* Following the Numerical Recipes authors, I prefer  */
    /* consistently good performance to erratically    	  */
    /* excellent performance for general use.	       	  */
    {   /********************************************************/
	/* Definition:  We say part of the block is a 'heap' if */
	/* b[i] >= b[i/2] for all i,i/2 in the part.            */
        /*						        */
        /* Heapsort starts with two pointers 'left', 'roit'     */
	/* set so the block looks like:                         */
        /*						        */
	/*   untouched-half 'left' untouched-half 'roit'        */
        /*						        */
	/* It then advances 'left' to the left, one step at a   */
        /* time, re-establishing the heap property on all block */
        /* entries between 'left' and 'roit' after each move.   */
        /* While this is running, the block looks like:	        */
        /*						        */
	/*   untouched-part 'left' heap-part 'roit'             */
        /*						        */
        /* When this phase is complete, the block looks like:   */
        /*						        */
	/*   'left' heap-part 'roit'                            */
        /*						        */
        /* Heapsort then advances 'roit' one step at a time,    */
        /* replacing block[roit] by the greatest element in the */
        /* heap part (heap[0]), then inserting block[roit] in   */
        /* the heap.						*/
        /* While this is running, the block looks like:	        */
        /*						        */
	/*   'left' heap-part 'roit' sorted-part                */
        /*						        */
        /* When this phase is complete, the block looks like:   */
        /*						        */
	/*   'left' 'roit' sorted-part                          */
        /*						        */
        /* and we return, mission completed.                    */
        /********************************************************/


	/* 'SIFT-UP':  Insert 'key' into the heap area 'twixt */
	/* 'left' and 'roit'.   There is currently a hole at  */
	/* 'left'.  If 'key' is greater than either child of  */
	/* the hole, we can simple put 'key' in the hole;     */
	/* otherwise, we fill the hole with the greatest of   */
	/* hole's two kids and then start over, trying to put */
	/* 'key' in the new hole just created:                */
	#undef  SIFT_UP
	#define SIFT_UP							    \
	{   Vm_Int hole = left;						    \
	    for (;;) {							    \
		Vm_Int R    = (hole+1)<<1;	/* Right kid of hole. */    \
		Vm_Int L    = R-1;		/* Left  kid of hole. */    \
		Vm_Int maxkid;			/* Max   kid of hole. */    \
									    \
		/* If kids L,R don't exist, can just put 'key' in hole: */  \
		if (L >= roit)            {  b[hole] = key;  break; }	    \
									    \
		/* Set maxkid to largest of hole's two kids, L and R:   */  \
		maxkid = (R < roit && OBJ_LESS( b[L], b[R])) ? R : L;	    \
									    \
		/* If 'key' > maxkid, put 'key' in hole and stop: */	    \
		if (OBJ_LESS(b[maxkid],key)) { b[hole] = key; break; }	    \
									    \
		/* Biggest kid fills hole, loop to fill new hole: */	    \
		b[hole] = b[maxkid];					    \
		hole    = maxkid;					    \
        }   }\

	/* Find block, initialize 'left' and 'roit': */
	Vm_Obj* b    = &jS.s[ -block_size ]; /* Base of our block. */
	Vm_Int  left = block_size/2 +1;	     /* Heap is slots k:   */
	Vm_Int  roit = block_size     ;	     /* left <= k < roit.  */
	Vm_Obj  key;

	/* Heap-build followed by heap-unbuild phases: */
	while (left-->0) { key = b[left];                 SIFT_UP; }  ++left;
	while (roit-->1) { key = b[roit]; b[roit] = b[0]; SIFT_UP; }
    }
}

 /***********************************************************************/
 /*-    job_P_Sort_Keysvals_Block -- "|keysvalsSort" operator.		*/
 /***********************************************************************/

void
job_P_Sort_Keysvals_Block(
    void
) {

    /**********************************************************/
    /* This fn is just like job_P_Sort_Block() except we sort */
    /* a block of keyVal pairs instead of a block of keys.   */
    /* See job_P_Sort_Block() for algorithm comments.         */
    /**********************************************************/

    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size <= 2)   return;
    if (block_size  & 1)   MUQ_WARN ("|sort-pairs needs even-sized block!");
    job_Guarantee_N_Args(  block_size+2 );

    {   /* Convenience macro: */
	#undef  SIFT_UP
        #define SIFT_UP							    \
	{   Vm_Int hole = left;						    \
	    for (;;) {							    \
		Vm_Int R    = (hole+2)<<1;	/* Right kid of hole. */    \
		Vm_Int L    = R-2;		/* Left  kid of hole. */    \
		Vm_Int maxkid;			/* Max   kid of hole. */    \
		if (L >= roit) {  b[hole] = key; b[hole+1] = val; break; }  \
		maxkid = (R < roit && OBJ_LESS( b[L], b[R])) ? R : L;	    \
		if (OBJ_LESS(b[maxkid],key)) {				    \
		    b[ hole   ] = key;					    \
		    b[ hole+1 ] = val;					    \
                    break;						    \
                }							    \
		b[ hole   ] = b[ maxkid   ];				    \
		b[ hole+1 ] = b[ maxkid+1 ];				    \
		hole        = maxkid;					    \
        }   }

        /* Init: */
	Vm_Obj* b    = &jS.s[ -block_size ];
	Vm_Int  left =(block_size/4 +1)*2;
	Vm_Int  roit = block_size        ;
	Vm_Obj  key;
	Vm_Obj  val;

	/* Build heap: */
	while ((left -= 2) >= 0) {
	    key = b[ left   ];
	    val = b[ left+1 ];
            SIFT_UP;
        }
        left += 2;

	/* Unbuild heap: */
	while ((roit -= 2) >= 2) {

	    key        = b[ roit   ];
	    val        = b[ roit+1 ];

	    b[ roit  ] = b[      0 ];
	    b[ roit+1] = b[      1 ];

            SIFT_UP;
        }
    }
}

 /***********************************************************************/
 /*-    job_P_Sort_Pairs_Block -- "|pairsSort" operator.		*/
 /***********************************************************************/

void
job_P_Sort_Pairs_Block(
    void
) {

    /**********************************************************/
    /* This fn is just like job_P_Sort_Block() except we sort */
    /* a block of keyVal pairs instead of a block of keys.   */
    /* See job_P_Sort_Block() for algorithm comments.         */
    /**********************************************************/

    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size <= 2)   return;
    if (block_size  & 1)   MUQ_WARN ("|sort-pairs needs even-sized block!");
    job_Guarantee_N_Args(  block_size+2 );

    {   /* Convenience macro: */
	#undef  SIFT_UP
        #define SIFT_UP							    \
	{   Vm_Int hole = left;						    \
	    for (;;) {							    \
		Vm_Int R    = (hole+2)<<1;	/* Right kid of hole. */    \
		Vm_Int L    = R-2;		/* Left  kid of hole. */    \
		Vm_Int maxkid;			/* Max   kid of hole. */    \
		Vm_Int cmp;						    \
		if (L >= roit) {  b[hole] = key; b[hole+1] = val; break; }  \
		if (R < roit) {						    \
		    cmp           = obj_Neql( b[L  ], b[R  ] );		    \
		    if (!cmp) cmp = obj_Neql( b[L+1], b[R+1] );		    \
		    maxkid = (0>cmp) ? R : L;				    \
		} else {						    \
		    maxkid = L;						    \
		}							    \
		cmp           = obj_Neql( b[maxkid  ], key );		    \
		if (!cmp) cmp = obj_Neql( b[maxkid+1], val );		    \
		if (0>cmp) {						    \
		    b[ hole   ] = key;					    \
		    b[ hole+1 ] = val;					    \
                    break;						    \
                }							    \
		b[ hole   ] = b[ maxkid   ];				    \
		b[ hole+1 ] = b[ maxkid+1 ];				    \
		hole        = maxkid;					    \
        }   }

        /* Init: */
	Vm_Obj* b    = &jS.s[ -block_size ];
	Vm_Int  left =(block_size/4 +1)*2;
	Vm_Int  roit = block_size        ;
	Vm_Obj  key;
	Vm_Obj  val;

	/* Build heap: */
	while ((left -= 2) >= 0) {
	    key = b[ left   ];
	    val = b[ left+1 ];
            SIFT_UP;
        }
        left += 2;

	/* Unbuild heap: */
	while ((roit -= 2) >= 2) {

	    key        = b[ roit   ];
	    val        = b[ roit+1 ];

	    b[ roit  ] = b[      0 ];
	    b[ roit+1] = b[      1 ];

            SIFT_UP;
        }
    }
}

 /***********************************************************************/
 /*-    job_P_Tsort_Block -- "|tsort" operator.				*/
 /***********************************************************************/

struct job_tsort_edge_rec {
    Vm_Obj src;
    Vm_Obj dst;
};
struct job_tsort_node_rec {
    Vm_Obj nod;
    Vm_Obj cnt;
    Vm_Obj edg;
    Vm_Obj nxt;
};

static Vm_Obj
job_tsort_lookup(
    struct job_tsort_node_rec * Node,	/* Array of nodes  */
    Vm_Int                      nodes,  /* Count of nodes  */
    Vm_Obj                      node    /* Node to look up */
) {
    /* Your standard plain-Jane binary search: */
    Vm_Int lo = 0;
    Vm_Int hi = nodes;
    for (;;) {
	Vm_Int i  = (hi+lo) >> 1;
	Vm_Obj e  = Node[i].nod;
	Vm_Int ne = obj_Neql( node, e );
	if (!ne)   return OBJ_FROM_INT(i);
	if ((Vm_Int)0>ne) {    
	    if (hi==i) MUQ_WARN("job_tsort_lookup internal err");
	    hi = i;
	} else {
	    if (lo==i) MUQ_WARN("job_tsort_lookup internal err");
	    lo = i;
	}
    }
}

static void
job_tsort(
    Vm_Int cltl2_p784	/* TRUE to trigger MOS tiebreaking per   */
) {                     /* Common Lisp: The Language 2nd Ed p784 */
    struct job_tsort_edge_rec *Edge;
    struct job_tsort_node_rec *Node;
    Vm_Int block_size;
    Vm_Int Candidate;
    Vm_Int Candidate_len;
    Vm_Int Result;
    Vm_Int Result_len;

    /* 'Edges' block on stack contains pairs expressing		*/
    /* partial ordering constraints.            		*/

    /* Sortuniq Edges by pairs, to eliminate redundancies.	*/
    /* This will leave all pairs starting with a given element	*/
    /* stored contiguously.					*/
    job_P_Sort_Pairs_Block();	/* Should do this using immediate compares. */
    job_P_Uniq_Pairs_Block();

    /* Get size of block, verify stack holds that much: */
    block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(    block_size+2 );
    if (block_size & 1)   MUQ_WARN("|tsort argblock can't be odd-length");
    if (block_size== 0) {
	*++jS.s = OBJ_T;
	return;
    }

    /* Dupsortuniq Edges producing a second, 'Nodes' block with	*/
    /* all elements to be tsorted, without duplicates.		*/
    /* The 'Nodes' argblock contains, for each element:		*/
    /*    The element E itself.					*/
    /*    Integer offset of first edge starting with E.		*/
    /*    Field to count incoming edges, initially zero.	*/
    /*    "Next" link for Candidates and Results linklists.	*/
    job_P_Dup_Block();
    job_P_Sort_Block();	/* Should do this using immediate compares. */
    job_P_Uniq_Block();
    {   Vm_Int edges = block_size >> 1;
        Vm_Int nodes = OBJ_TO_BLK( *jS.s );
	Vm_Int last;
	Vm_Int i;
	job_Guarantee_Headroom( nodes * 3 );	
	Edge    = (struct job_tsort_edge_rec*)( jS.s - (nodes+2+block_size));
	Node    = (struct job_tsort_node_rec*)( jS.s - (nodes             ));
	jS.s   += nodes * 3;
	jS.s[0] = OBJ_FROM_BLK( nodes * 4 );

	/* Expand Nodes from 1 to 4 slots per node: */
	for (i = nodes;   i --> 0;   ) {
	    Node[i].nod = ((Vm_Obj*)Node)[i];
	}

	/* Initialize the three new Nodes slots: */
	for (i = nodes;   i --> 0;   ) {
	    Node[i].cnt = OBJ_FROM_INT( 0);
	    Node[i].nxt = OBJ_FROM_INT(-1);
	    Node[i].edg = OBJ_FROM_INT(-1);
	}

	/* Replace each value in Edges argblock by			*/
	/* appropriate integer index into Nodes argblock.   	*/
	for (i = 0;   i < edges;   ++i) {
	    Edge[i].src = job_tsort_lookup( Node, nodes, Edge[i].src );
	    Edge[i].dst = job_tsort_lookup( Node, nodes, Edge[i].dst );
	}

	/* Initialize Node[*].edg: */
	last = -1;
	for (i = 0;   i < edges;   ++i) {
	    if (Edge[i].src != last) {
		last = Edge[i].src;
		Node[ OBJ_TO_INT(last) ].edg = OBJ_FROM_INT(i);
	    }
	}

	/* Scan Edges argblock, incrementing incoming	*/
	/* edge counts in Nodes argblock.		*/
	for (i = 0;   i < edges;   ++i) {
	    Vm_Int n = OBJ_TO_INT( Edge[i].dst );
	    Vm_Int c = OBJ_TO_INT( Node[n].cnt );
	    Node[n].cnt = OBJ_FROM_INT( c+1 );
	}

	/* Initialize a Result linklist to empty:		*/
	Result        = -1;
	Result_len    =  0;

	/* Initialize a Candidate linklist to empty:		*/
	Candidate     = -1;
	Candidate_len =  0;

	/* Scan Nodes argblock, building Candidates linklist of	*/
	/* nodes with zero counts of incoming edges.  These are	*/
	/* candidates to be added next to Result ordering.	*/
	for (i = 0;   i < nodes;   ++i) {
	    if (Node[i].cnt == OBJ_FROM_INT(0)) {
		Node[i].nxt = OBJ_FROM_INT(Candidate);
		Candidate   = i;
		++ Candidate_len;
	    }
	}

	/* While Candidates list is not empty:			*/
	while (Candidate_len) {

            /* Select next Candidate C to process,		*/ 
	    /* and remove it from candidates list:		*/
	    Vm_Int c;
	    if (!cltl2_p784
	    ||  Candidate_len == 1
            ){
		/* Just take first candidate:			*/ 
		c = Candidate;
		--Candidate_len;
		Candidate = OBJ_TO_INT( Node[c].nxt );
	    } else {
		/* CLtL2 p784 wants us to break the tie		*/
		/* by marching down the Results list and	*/
		/* picking the first candidate to be a		*/
		/* superclass of one of the results.		*/

		/* Over all classes on result */
		/* list, most recent first:   */
		Vm_Int r;
		Vm_Obj cdf;
		Vm_Obj key =OBJ_0; /* Initialized only to quiet compilers. */
		Vm_Int done=FALSE;
		for (r = Result;   !done;   r = OBJ_TO_INT(Node[r].nxt)) {
		    Vm_Int last = -1;
		    if (r == -1) {
			MUQ_WARN("|tsortMos: Bad input, can't break tie");
		    }

		    /* Verify that we -do- have a mos class: */
		    cdf = Node[r].nod;
		    if(!OBJ_IS_OBJ(cdf)
		    || !OBJ_IS_CLASS_CDF(cdf)
		    || !(key = CDF_P(cdf)->key)
		    || !OBJ_IS_OBJ(key)
		    || !OBJ_IS_CLASS_KEY(key)
                    ){
			MUQ_WARN("|tsortMos: Inputs must be mos classes");
		    }

		    /* Over all classes in candidates list: */
		    for(c    = Candidate;
                        c   != -1;
			Node = (struct job_tsort_node_rec*)(jS.s-(nodes<<2)),
			last = c,
                        c    = OBJ_TO_INT( Node[last].nxt )
		    ){
			Vm_Obj dad = Node[c].nod;

			/* If candidate class is a direct      */
			/* superclass of current result class: */
			if (key_Direct_Subclass_Of( key, dad )) {
			    
			    /* C is next class to add to result list. */

			    /* Restore Node and Edge pointers, which  */
			    /* may have been trashed by the call to   */
			    /* key_Direct_Subclass_Of():              */
			    Node=(struct job_tsort_node_rec*)(jS.s-(nodes<<2));
			    Edge=(struct job_tsort_edge_rec*)(
                                ((Vm_Obj*)Node) - (2+block_size)
                            );

			    /* Remove c from Candidates list: */
			    if (last == -1) {
				/* C is first entry on Candidates list: */
				Candidate = OBJ_TO_INT( Node[c].nxt );
			    } else {
				/* C is nonfirst entry on Candidates list: */
				Node[last].nxt = Node[c].nxt;
			    }
			    --Candidate_len;

			    done = TRUE;
			    break;
			}
		    }
		}
	    }

	    /* For all edges C,N decrement incoming edge	*/
	    /* count for N:  If the count goes to zero,		*/
	    /* add N to Candidates.				*/
	    last = OBJ_TO_INT( Node[c].edg );
	    if (last != -1) {
		for (i = last;   Edge[i].src == Edge[last].src;   ++i) {
		    Vm_Int n = OBJ_TO_INT( Edge[i].dst );
		    Vm_Int e = OBJ_TO_INT( Node[n].cnt ) -1;
		    Node[n].cnt = OBJ_FROM_INT( e );
		    if (!e) {
			Node[n].nxt = OBJ_FROM_INT(Candidate);
			Candidate   = n;
			++ Candidate_len;
		    }
		}
	    }

	    /* Append C to Result linklist:				*/
	    Node[c].cnt = OBJ_FROM_INT(-1); /* So cnt==0 only on candidates */
	    Node[c].nxt = OBJ_FROM_INT(Result);
	    Result      = c;
	    ++ Result_len;
	}

	/* If there are nodes not on the Result linklist,	*/
	/* the given graph contained cycles: return NIL flag.	*/
	jS.s -= nodes*4 + edges*2 + 4;
	if (Result_len != nodes) {
	    /* Might be nice to return a cycle at some point.   */
	    /* For now, we return an empty block:               */
	    *++jS.s = OBJ_BLOCK_START;
	    *++jS.s = OBJ_FROM_BLK(0);
	    *++jS.s = OBJ_NIL;
	    return;
	}

        /* Return contents of Results as a block, below T flag.	*/
	*++jS.s = OBJ_BLOCK_START;
	jS.s   += nodes;
	for (i = 0;   i < nodes;   ++i) {
	    if (Result == -1) MUQ_WARN("|tsort internal err");
	    jS.s[-i] = Node[Result].nod;
	    Result   = OBJ_TO_INT( Node[Result].nxt );
	}
	*++jS.s = OBJ_FROM_BLK(nodes);
	if (Result != -1) MUQ_WARN("|tsort internal err");
	*++jS.s = OBJ_T;
    }
}

void
job_P_Tsort_Block(
    void
) {
    job_tsort( FALSE );
}

 /***********************************************************************/
 /*-    job_P_Tsort_Mos_Block -- "|tsortMos" operator.			*/
 /***********************************************************************/

void
job_P_Tsort_Mos_Block(
    void
) {
    job_tsort( TRUE );
}

 /***********************************************************************/
 /*-    job_P_Start_Block -- "[" operator.				*/
 /***********************************************************************/

void
job_P_Start_Block(
    void
) {
    *++jS.s = OBJ_BLOCK_START;
}

 /***********************************************************************/
 /*-    job_P_Abc_Abbc_Block -- "|abc-to-abbc" operator.		*/
 /***********************************************************************/

void
job_P_Abc_Abbc_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    job_Guarantee_N_Args(    block_size+2 );
    if (block_size == 0
    ||  block_size == 2
    ){
	return;
    }
    if (block_size == 1) {
	*--jS.s = OBJ_FROM_BLK(0);
	return;
    }

    /* Compute final size for block: */
    {   Vm_Int added_entries = block_size -2;

	/* Make sure we have room: */
        job_Guarantee_Headroom( added_entries );

	/* Convert abcd into abbccd &tc: */
	{   Vm_Obj* dst = jS.s + added_entries -1;
	    Vm_Obj* src = jS.s                 -1;
	    Vm_Int  i;
	    for (i = block_size-1;   i --> 0;  ) {
		*dst-- = *src--;
		*dst-- = *src  ;
    	}   }
	jS.s += added_entries;
       *jS.s = OBJ_FROM_BLK( block_size + added_entries );
    }
}

 /***********************************************************************/
 /*-    job_P_Uniq_Block -- "|uniq" operator.				*/
 /***********************************************************************/

void
job_P_Uniq_Block(
    void
) {

    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size <= 1)   return;
    job_Guarantee_N_Args(    block_size+2 );

    /* Find block, uniq it: */
    {   Vm_Obj* b     = &jS.s[ -block_size ]; /* Base of our block. */
        Vm_Obj* cat   = b;
        Vm_Obj* rat   = cat+1;
	Vm_Obj* top   = jS.s;
	/* Invariant is that *cat is the last   */
	/* element definitely marked to be kept */
	/* and rat points to next candidate to  */
	/* kept.  Space between is junk:        */
	for ( ;   rat < top;   ++rat) {
	    if (obj_Neql( *cat, *rat ))  *++cat = *rat;
        }
	jS.s = ++cat;
       *jS.s = OBJ_FROM_BLK( cat-b );
    }
}

 /***********************************************************************/
 /*-    job_P_Uniq_Keysvals_Block -- "|keysvalsUniq" operator.		*/
 /***********************************************************************/

void
job_P_Uniq_Keysvals_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size & 1) MUQ_WARN("|pairsUniq needs even-sized block");
    if (block_size <= 2)   return;
    job_Guarantee_N_Args(    block_size+2 );

    /* Find block, uniq it: */
    {   Vm_Obj* b     = &jS.s[ -block_size ]; /* Base of our block. */
        Vm_Obj* cat   = b;
        Vm_Obj* rat   = cat+2;
	Vm_Obj* top   = jS.s;
	for ( ;   rat < top;   rat += 2) {
	    if (obj_Neql( cat[0], rat[0] )) {
		cat   += 2;
		cat[0] = rat[0];
		cat[1] = rat[1];
	    }
        }
        cat += 2;
	jS.s = cat;
       *jS.s = OBJ_FROM_BLK( cat-b );
    }
}

 /***********************************************************************/
 /*-    job_P_Uniq_Pairs_Block -- "|pairsUniq" operator.		*/
 /***********************************************************************/

void
job_P_Uniq_Pairs_Block(
    void
) {

    /* Get size of block, verify stack holds that much: */
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size & 1) MUQ_WARN("|pairsUniq needs even-sized block");
    if (block_size <= 2)   return;
    job_Guarantee_N_Args(    block_size+2 );

    /* Find block, uniq it: */
    {   Vm_Obj* b     = &jS.s[ -block_size ]; /* Base of our block. */
        Vm_Obj* cat   = b;
        Vm_Obj* rat   = cat+2;
	Vm_Obj* top   = jS.s;
	for ( ;   rat < top;   rat += 2) {
	    if (obj_Neql( cat[0], rat[0] )
	    ||  obj_Neql( cat[1], rat[1] )
            ){
		cat   += 2;
		cat[0] = rat[0];
		cat[1] = rat[1];
	    }
        }
        cat += 2;
	jS.s = cat;
       *jS.s = OBJ_FROM_BLK( cat-b );
    }
}

 /***********************************************************************/
 /*-    job_P_Secure_Hash_Block -- "|secureHash" operator.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Secure_Hash_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Uch buffer[ MAX_STRING ];
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    job_Guarantee_N_Args(    block_size+2 );
    if (block_size > MAX_STRING) {
	MUQ_WARN("|secureHash: Block too long");
    }
    job_Guarantee_Headroom( 20 );

    /* Find block, uniq it: */
    {   Vm_Obj*b = &jS.s[ -block_size ]; /* Base of our block. */
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
		MUQ_WARN("|secureHash accepts only chars and ints");
	    }
        }
	{   Vm_Uch digest[ 20 ];
            sha_Digest( digest, buffer, block_size );
	    jS.s -= block_size;
	    if (chars > ints) {
		for (i = 0;   i < 20;   ++i) {
		    b[ i ] = OBJ_FROM_CHAR( digest[i] );
		}
	    } else {
		for (i = 0;   i < 20;   ++i) {
		    b[ i ] = OBJ_FROM_INT(  digest[i] );
		}
	    }
	    jS.s += 20;
           *jS.s  = OBJ_FROM_BLK( 20 );
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Secure_Digest_Block -- "|secureDigest" operator.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Secure_Digest_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Uch buffer[ MAX_STRING ];
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    job_Guarantee_N_Args(    block_size+2 );
    if (block_size > MAX_STRING) {
	MUQ_WARN("|secureHash: Block too long");
    }
    job_Guarantee_Headroom( 20 );

    /* Find block, uniq it: */
    {   Vm_Obj*b = &jS.s[ -block_size ]; /* Base of our block. */
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
		MUQ_WARN("|secureHash accepts only chars and ints");
	    }
        }
	{   Vm_Uch digest[ 20 ];
            sha_Digest( digest, buffer, block_size );
	    if (chars > ints) {
		for (i = 0;   i < 20;   ++i) {
		    b[ block_size + i ] = OBJ_FROM_CHAR( digest[i] );
		}
	    } else {
		for (i = 0;   i < 20;   ++i) {
		    b[ block_size + i ] = OBJ_FROM_INT(  digest[i] );
		}
	    }
	    jS.s += 20;
           *jS.s  = OBJ_FROM_BLK( block_size + 20 );
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Secure_Digest_Check_Block -- "|secureDigestCheck" operator*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Secure_Digest_Check_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Uch buffer[ MAX_STRING ];
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    job_Guarantee_N_Args(    block_size+2 );
    if (block_size > MAX_STRING) {
	MUQ_WARN("|secureDigestCheck: Block too long");
    }
    if (block_size < 20) {
	MUQ_WARN("|secureDigestCheck: Block too short");
    }

    /* Find block, uniq it: */
    {   Vm_Obj* b = &jS.s[ -block_size ]; /* Base of our block. */
	Vm_Uch old_digest[ 20 ];
        Vm_Int i;
	for   (i = 0;   i < 20;   ++i) {
	    Vm_Int j = (block_size-20)+i;
	    Vm_Obj c = b[j];
	    if        (OBJ_IS_CHAR(c)) {
		old_digest[ i ] = OBJ_TO_CHAR(c);
	    } else if (OBJ_IS_INT( c)) {
		old_digest[ i ] = OBJ_TO_INT(c);
	    } else {
		MUQ_WARN("|secureDigestCheck accepts only chars and ints");
	    }
	}
	for   (i = 0;   i < block_size-20;   ++i) {
	    Vm_Obj c = b[i];
	    if        (OBJ_IS_CHAR(c)) {
		buffer[ i ] = OBJ_TO_CHAR(c);
	    } else if (OBJ_IS_INT( c)) {
		buffer[ i ] = OBJ_TO_INT(c);
	    } else {
		MUQ_WARN("|secureDigestCheck accepts only chars and ints");
	    }
        }
	{   Vm_Uch digest[ 20 ];
	    Vm_Int differ = FALSE;
            sha_Digest( digest, buffer, block_size );
	    for (i = 0;   i < 20;   ++i) {
		differ |= (old_digest[i] != digest[i]);
	    }
	    jS.s    -= 19;
            jS.s[ 0] = OBJ_FROM_BLK( block_size - 19 );
            jS.s[-1] = OBJ_FROM_BOOL( !differ );
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Rex_Begin -- { string -> }				*/
 /***********************************************************************/

void
job_P_Rex_Begin(
    void
) {
    /* Set up start of string match. */
    job_Guarantee_Stg_Arg( 0 );
    rex_Begin( *jS.s );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Rex_End -- { -> }						*/
 /***********************************************************************/

void
job_P_Rex_End(
    void
) {
    rex_End();
}

 /***********************************************************************/
 /*-    job_P_Rex_Open_Paren -- { fixnum -> }				*/
 /***********************************************************************/

void
job_P_Rex_Open_Paren(
    void
) {
    Vm_Unt which = OBJ_TO_INT(*jS.s);
    job_Guarantee_Int_Arg( 0 );
    if (which >= REX_MAX_MATCHES)  MUQ_WARN("rexOpenParen: only 0-31 currently supported.");
    rex_Open_Paren( which );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Rex_Close_Paren -- { fixnum -> }				*/
 /***********************************************************************/

void
job_P_Rex_Close_Paren(
    void
) {
    Vm_Unt which = OBJ_TO_INT(*jS.s);
    job_Guarantee_Int_Arg( 0 );
    if (which >= REX_MAX_MATCHES)  MUQ_WARN("rexCloseParen: only 0-31 currently supported.");
    rex_Close_Paren( which );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Rex_Cancel_Paren -- { fixnum -> }				*/
 /***********************************************************************/

void
job_P_Rex_Cancel_Paren(
    void
) {
    Vm_Unt which = OBJ_TO_INT(*jS.s);
    job_Guarantee_Int_Arg( 0 );
    if (which >= REX_MAX_MATCHES)  MUQ_WARN("rexCancelParen: only 0-31 currently supported.");
    rex_Cancel_Paren( which );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Rex_Get_Paren -- { fixnum -> }				*/
 /***********************************************************************/

void
job_P_Rex_Get_Paren(
    void
) {
    Vm_Unt which = OBJ_TO_INT(*jS.s);
    job_Guarantee_Int_Arg( 0 );
    if (which >= REX_MAX_MATCHES)  MUQ_WARN("rexGetParen: only 0-31 currently supported.");
    {   Vm_Obj stop;
        Vm_Obj start = rex_Get_Paren( &stop, which );
        *  jS.s = start;
        *++jS.s = stop;
    }
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Previous_Match -- { fixnum -> bool }		*/
 /***********************************************************************/

void
job_P_Rex_Match_Previous_Match(
    void
) {
    Vm_Unt which = OBJ_TO_INT(*jS.s);
    job_Guarantee_Int_Arg( 0 );
    if (which >= REX_MAX_MATCHES)  MUQ_WARN("rexMatchPreviousMatch: only 0-31 currently supported.");
    *jS.s = rex_Match_Previous_Match( which );
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Char_Class -- { str -> bool }			*/
 /***********************************************************************/

void
job_P_Rex_Match_Char_Class(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    *jS.s = rex_Match_Char_Class( *jS.s );
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Dot -- { -> bool }				*/
 /***********************************************************************/

void
job_P_Rex_Match_Dot(
    void
) {
    Vm_Obj result = rex_Match_Dot();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Digit -- { -> bool }				*/
 /***********************************************************************/

void
job_P_Rex_Match_Digit(
    void
) {
    Vm_Obj result = rex_Match_Digit();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Wordboundary -- { -> bool }			*/
 /***********************************************************************/

void
job_P_Rex_Match_Wordboundary(
    void
) {
    Vm_Obj result = rex_Match_Wordboundary();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Wordchar -- { -> bool }				*/
 /***********************************************************************/

void
job_P_Rex_Match_Wordchar(
    void
) {
    Vm_Obj result = rex_Match_Wordchar();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Whitespace -- { -> bool }			*/
 /***********************************************************************/

void
job_P_Rex_Match_Whitespace(
    void
) {
    Vm_Obj result = rex_Match_Whitespace();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Nondigit -- { -> bool }				*/
 /***********************************************************************/

void
job_P_Rex_Match_Nondigit(
    void
) {
    Vm_Obj result = rex_Match_Nondigit();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Nonwordboundary -- { -> bool }			*/
 /***********************************************************************/

void
job_P_Rex_Match_Nonwordboundary(
    void
) {
    Vm_Obj result = rex_Match_Nonwordboundary();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Nonwordchar -- { -> bool }			*/
 /***********************************************************************/

void
job_P_Rex_Match_Nonwordchar(
    void
) {
    Vm_Obj result = rex_Match_Nonwordchar();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_Nonwhitespace -- { -> bool }			*/
 /***********************************************************************/

void
job_P_Rex_Match_Nonwhitespace(
    void
) {
    Vm_Obj result = rex_Match_Nonwhitespace();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Match_String -- { str -> bool }			*/
 /***********************************************************************/

void
job_P_Rex_Match_String(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    *jS.s = rex_Match_String( *jS.s );
}

extern void       job_P_Rex_Match_Wordboundary(	void );
extern void       job_P_Rex_Match_Wordchar(	void );
extern void       job_P_Rex_Match_Whitespace(	void );
extern void       job_P_Rex_Match_Digit(	void );
extern void       job_P_Rex_Match_Nonwordboundary(void );
extern void       job_P_Rex_Match_Nonwordchar(	void );
extern void       job_P_Rex_Match_Nonwhitespace(void );
extern void       job_P_Rex_Match_Nondigit(	void );

 /***********************************************************************/
 /*-    job_P_Rex_Get_Cursor -- { -> fixnum }				*/
 /***********************************************************************/

void
job_P_Rex_Get_Cursor(
    void
) {
    Vm_Obj result = rex_Get_Cursor();
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Rex_Set_Cursor -- { fixnum -> }				*/
 /***********************************************************************/

void
job_P_Rex_Set_Cursor(
    void
) {
    job_Guarantee_Int_Arg( 0 );
    rex_Set_Cursor( *jS.s );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Rex_Done_P -- { -> bool }					*/
 /***********************************************************************/

void
job_P_Rex_Done_P(
    void
) {
    Vm_Obj result = OBJ_FROM_BOOL( rex_Done_P() );
    *++jS.s = result;
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
