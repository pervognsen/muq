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
/* From: glenn@nimbus.som.cwru.edu (Glenn Crocker)			*/
/* Date: Thu, 24 Mar 94 14:36:41 EDT					*/
/* Cc: mushhacks@caisr2.caisr.cwru.edu, mjr@tis.com			*/
/* ...									*/
/* For those who don't know him, Marcus is the God of MU* servers. 	*/
/* ...									*/
/*      [ i.e., Marcus J Ranum ]					*/
/************************************************************************/

/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"
#include "jobprims.h"

/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void     job_string_downcase( Vm_Chr*t,Vm_Chr*,Vm_Int);

static void     job_makesym_fetchseg( Vm_Uch*, Vm_Obj*, Vm_Int );



/************************************************************************/
/*-    Public fns, true prims for jobprims.c	 			*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_P_Acting_User -- Return effective user.			*/
 /***********************************************************************/

void
job_P_Acting_User(
    void
) {
    /* Seize one stack location, and push result in it: */
    *++jS.s = jS.j.acting_user;
}


 /***********************************************************************/
 /*-    job_P_Actual_User -- Return true user.				*/
 /***********************************************************************/
void
job_P_Actual_User(
    void
) {
    /* Seize one stack location, and push result in it: */
    *++jS.s = jS.j.actual_user;
}


 /***********************************************************************/
 /*-    job_P_Caseless_Ge --						*/
 /***********************************************************************/
void
job_P_Caseless_Ge(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );
    {   Vm_Int val = obj_Caseless_Neql( arg1, arg0 );
	*--jS.s    = OBJ_FROM_BOOL(val >= 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Caseless_Le --						*/
 /***********************************************************************/

void
job_P_Caseless_Le(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );
    {   Vm_Int val = obj_Caseless_Neql( arg1, arg0 );
	*--jS.s    = OBJ_FROM_BOOL(val <= 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Caseless_Lt --						*/
 /***********************************************************************/

void
job_P_Caseless_Lt(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );
    {   Vm_Int val = obj_Caseless_Neql( arg1, arg0 );
	*--jS.s    = OBJ_FROM_BOOL(val < 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Caseless_Gt --						*/
 /***********************************************************************/

void
job_P_Caseless_Gt(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );
    {   Vm_Int val = obj_Caseless_Neql( arg1, arg0 );
	*--jS.s    = OBJ_FROM_BOOL(val > 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Caseless_Eq --						*/
 /***********************************************************************/

void
job_P_Caseless_Eq(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );
    {   Vm_Int val = obj_Caseless_Neql( arg1, arg0 );
	*--jS.s    = OBJ_FROM_BOOL(val == 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Caseless_Ne --						*/
 /***********************************************************************/

void
job_P_Caseless_Ne(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );
    {   Vm_Int val = obj_Caseless_Neql( arg1, arg0 );
	*--jS.s    = OBJ_FROM_BOOL(val != 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Alpha_Char_P --						*/
 /***********************************************************************/

void
job_P_Alpha_Char_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    *jS.s = OBJ_FROM_BOOL( isalpha( OBJ_TO_CHAR( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Alphanumeric_P --						*/
 /***********************************************************************/

void
job_P_Alphanumeric_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    *jS.s = OBJ_FROM_BOOL( isalnum( OBJ_TO_CHAR( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Control_Char_P --						*/
 /***********************************************************************/

void
job_P_Control_Char_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    *jS.s = OBJ_FROM_BOOL( iscntrl( OBJ_TO_CHAR( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Controlp --						*/
 /***********************************************************************/

void
job_P_Controlp(
    void
) {
    *jS.s = OBJ_FROM_BOOL( job_Controls( *jS.s ) );
}

 /***********************************************************************/
 /*-    job_P_Digit_Char_P --						*/
 /***********************************************************************/

void
job_P_Digit_Char_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    {   Vm_Int c = OBJ_TO_CHAR( *jS.s );

        if (isdigit(c))   *jS.s = OBJ_FROM_INT( c-'0' );
        else              *jS.s = OBJ_NIL;
    }
}

 /***********************************************************************/
 /*-    job_P_Graphic_Char_P --						*/
 /***********************************************************************/

void
job_P_Graphic_Char_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    *jS.s = OBJ_FROM_BOOL( isprint( OBJ_TO_CHAR( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Hex_Digit_Char_P --					*/
 /***********************************************************************/

void
job_P_Hex_Digit_Char_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    {   Vm_Int c = OBJ_TO_CHAR( *jS.s );

        /* Yes, this assumes an ascii implementation: */
        if      (!isxdigit(c))   *jS.s = OBJ_NIL;
        else if (c <= '9')       *jS.s = OBJ_FROM_INT(      c-'0' );
        else if (c <= 'F')       *jS.s = OBJ_FROM_INT( 10 + c-'A' );
        else if (c <= 'f')       *jS.s = OBJ_FROM_INT( 10 + c-'a' );
	else MUQ_WARN ("job_P_Hex_Digit_Char_P: internal err");
    }
}

 /***********************************************************************/
 /*-    job_P_Hash --							*/
 /***********************************************************************/

void
job_P_Hash(
    void
) {
    job_Guarantee_N_Args(   1 );
    *jS.s = dil_Hash( *jS.s );
}

 /***********************************************************************/
 /*-    job_P_Punctuation_P --						*/
 /***********************************************************************/

void
job_P_Punctuation_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    *jS.s = OBJ_FROM_BOOL( ispunct( OBJ_TO_CHAR( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Whitespace_P --						*/
 /***********************************************************************/

void
job_P_Whitespace_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    *jS.s = OBJ_FROM_BOOL( isspace( OBJ_TO_CHAR( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Upper_Case_P --						*/
 /***********************************************************************/

void
job_P_Upper_Case_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    *jS.s = OBJ_FROM_BOOL( isupper( OBJ_TO_CHAR( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Lower_Case_P --						*/
 /***********************************************************************/

void
job_P_Lower_Case_P(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );

    *jS.s = OBJ_FROM_BOOL( islower( OBJ_TO_CHAR( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Substring_P --						*/
 /***********************************************************************/

void
job_P_Substring_P(
    void
) {
    job_P_Find_Substring_P();
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Caseless_Substring_P --					*/
 /***********************************************************************/

void
job_P_Caseless_Substring_P(
    void
) {
    job_P_Caseless_Find_Substring_P();
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Find_Substring_P --					*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

static void
find_substring_p(
    Vm_Int caseless,
    Vm_Int have_offset
) {
    Vm_Obj substr;
    Vm_Obj    str;
    Vm_Int offset = 0;
    if (have_offset) {
        job_Guarantee_N_Args(   3 );
        job_Guarantee_Stg_Arg(  0 );
        job_Guarantee_Int_Arg( -1 );
        job_Guarantee_Stg_Arg( -2 );
        substr =             jS.s[   0 ]  ;
        offset = OBJ_TO_INT( jS.s[  -1 ] ) +1;
        str    =             jS.s[  -2 ]  ;
    } else {
        job_Guarantee_N_Args(   2 );
        job_Guarantee_Stg_Arg(  0 );
        job_Guarantee_Stg_Arg( -1 );
        substr = jS.s[   0 ];
        str    = jS.s[  -1 ];
    }
    {   Vm_Chr    str_buf[ MAX_STRING ];
        Vm_Chr substr_buf[ MAX_STRING ];
        Vm_Int    str_len = stg_Len(    str );
        Vm_Int substr_len = stg_Len( substr );
	if (str_len >= MAX_STRING-1) {
	    MUQ_WARN ("find-substring: arg too big");
	}
	if (str_len != stg_Get_Bytes( str_buf, str_len, str, 0 )) {
	    MUQ_WARN ("find-substring: internal error");
	}
	str_buf[ str_len ] = '\0';
	if (substr_len >= MAX_STRING-1) {
	    MUQ_WARN ("find-substring: arg too big");
	}
	if (substr_len != stg_Get_Bytes( substr_buf, substr_len, substr, 0 )) {
	    MUQ_WARN ("find-substring: internal error");
	}
	substr_buf[ substr_len ] = '\0';
	if (!have_offset)  ++jS.s;
	jS.s[ -2 ] = OBJ_NIL;
	jS.s[ -1 ] = OBJ_FROM_INT( offset );
	jS.s[  0 ] = OBJ_FROM_INT( offset );
	if (offset >= str_len)   return;
	if (offset <  0)         offset = 0;
	if (substr_len == 0) {  jS.s[ -2 ] = OBJ_TRUE;   return; }
	if (caseless) {
	    job_string_downcase(    str_buf,    str_buf,    str_len );
	    job_string_downcase( substr_buf, substr_buf, substr_len );
	}
	if (substr_len == 1) {
	    Vm_Chr* loc = strchr( str_buf+offset, substr_buf[ 0 ] );	    
	    if (loc) {
		jS.s[ -2 ] = OBJ_TRUE;
		jS.s[ -1 ] = OBJ_FROM_INT( loc-str_buf+1 );
		jS.s[  0 ] = OBJ_FROM_INT( loc-str_buf   );
	    }
	    return;
	} else {
	    Vm_Chr* loc = strstr( str_buf+offset, substr_buf );	    
	    if (loc) {
		jS.s[ -2 ] = OBJ_TRUE;
		jS.s[ -1 ] = OBJ_FROM_INT( loc-str_buf + substr_len );
		jS.s[  0 ] = OBJ_FROM_INT( loc-str_buf              );
	    }
	    return;
	}
    }
}
void
job_P_Find_Substring_P(
    void
) {
    find_substring_p( /* caseless: */ FALSE, /* have_offset: */ FALSE );
}

 /***********************************************************************/
 /*-    job_P_Find_Next_Substring_P --					*/
 /***********************************************************************/

void
job_P_Find_Next_Substring_P(
    void
) {
    find_substring_p( /* caseless: */ FALSE, /* have_offset: */ TRUE );
}


 /***********************************************************************/
 /*-    job_P_Find_Last_Substring_P --					*/
 /***********************************************************************/

static void
find_last_substring_p(
    Vm_Int caseless,
    Vm_Int have_offset
) {
    Vm_Obj substr = jS.s[   0 ];
    Vm_Obj    str = jS.s[  -1 ];
    Vm_Int offset = 0;
    if (have_offset) {
        job_Guarantee_N_Args(   3 );
        job_Guarantee_Stg_Arg(  0 );
        job_Guarantee_Int_Arg( -1 );
        job_Guarantee_Stg_Arg( -2 );
        substr =             jS.s[   0 ]     ;
        offset = OBJ_TO_INT( jS.s[  -1 ] ) -1;
        str    =             jS.s[  -2 ]     ;
    } else {
        job_Guarantee_N_Args(   2 );
        job_Guarantee_Stg_Arg(  0 );
        job_Guarantee_Stg_Arg( -1 );
        substr = jS.s[   0 ];
        str    = jS.s[  -1 ];
    }
    {   Vm_Chr    str_buf[ MAX_STRING ];
        Vm_Chr substr_buf[ MAX_STRING ];
        Vm_Int    str_len = stg_Len(    str );
        Vm_Int substr_len = stg_Len( substr );
	if (str_len >= MAX_STRING-1) {
	    MUQ_WARN ("find-last-substring: arg too big");
	}
	if (str_len != stg_Get_Bytes( str_buf, str_len, str, 0 )) {
	    MUQ_WARN ("find-last-substring: internal error");
	}
	str_buf[ str_len ] = '\0';
	if (substr_len >= MAX_STRING-1) {
	    MUQ_WARN ("find-last-substring: arg too big");
	}
	if (substr_len != stg_Get_Bytes( substr_buf, substr_len, substr, 0 )) {
	    MUQ_WARN ("find-last-substring: internal error");
	}
	substr_buf[ substr_len ] = '\0';
	if (!have_offset)   ++jS.s;
	jS.s[ -2 ] = OBJ_NIL;
	jS.s[ -1 ] = OBJ_FROM_INT( 0 );
	jS.s[  0 ] = OBJ_FROM_INT( 0 );
	if (offset < 0)   return;
	if (substr_len == 0) {
	    jS.s[ -2 ] = OBJ_TRUE;
	    jS.s[ -1 ] = OBJ_FROM_INT( str_len );
	    jS.s[  0 ] = OBJ_FROM_INT( str_len );
	    return;
	}
	if (caseless) {
	    job_string_downcase(    str_buf,    str_buf,    str_len );
	    job_string_downcase( substr_buf, substr_buf, substr_len );
	}
	if (have_offset) {
	    /* Plop a nul in buffer, positioned so as    */
	    /* to forbid all unwanted substring matches: */
	    Vm_Unt x = (Vm_Unt)(-1 + offset + substr_len);
	    if (x < (Vm_Unt) str_len) {
		str_buf[ x ] = '\0';
	    }
	}
	if (substr_len == 1) {
	    Vm_Chr* loc = strrchr( str_buf, substr_buf[ 0 ] );	    
	    if (loc) {
		jS.s[ -2 ] = OBJ_TRUE;
		jS.s[ -1 ] = OBJ_FROM_INT( loc-str_buf+1 );
		jS.s[  0 ] = OBJ_FROM_INT( loc-str_buf   );
	    }
	    return;
	} else {
	    Vm_Chr* last_loc = NULL;
	    Vm_Chr* loc      = str_buf-1;
	    while  (loc = strstr( loc+1, substr_buf ))   last_loc = loc;
	    if (last_loc) {
		jS.s[ -2 ] = OBJ_TRUE;
		jS.s[ -1 ] = OBJ_FROM_INT( last_loc-str_buf + substr_len );
		jS.s[  0 ] = OBJ_FROM_INT( last_loc-str_buf              );
	    }
	    return;
	}
    }
}

void
job_P_Find_Last_Substring_P(
    void
) {
    find_last_substring_p( /* caseless: */ FALSE, /* have_offset: */ FALSE );
}

 /***********************************************************************/
 /*-    job_P_Find_Previous_Substring_P --				*/
 /***********************************************************************/

void
job_P_Find_Previous_Substring_P(
    void
) {
    find_last_substring_p( /* caseless: */ FALSE, /* have_offset: */ TRUE );
}

 /***********************************************************************/
 /*-    job_P_Caseless_Find_Last_Substring_P --				*/
 /***********************************************************************/

void
job_P_Caseless_Find_Last_Substring_P(
    void
) {
    find_last_substring_p( /* caseless: */ TRUE, /* have_offset: */ FALSE );
}

 /***********************************************************************/
 /*-    job_P_Caseless_Find_Previous_Substring_P --			*/
 /***********************************************************************/

void
job_P_Caseless_Find_Previous_Substring_P(
    void
) {
    find_last_substring_p( /* caseless: */ TRUE, /* have_offset: */ TRUE );
}

 /***********************************************************************/
 /*-    job_P_Caseless_Find_Substring_P --				*/
 /***********************************************************************/

void
job_P_Caseless_Find_Substring_P(
    void
) {
    find_substring_p( /* caseless: */ TRUE, /* have_offset: */ FALSE );
}

 /***********************************************************************/
 /*-    job_P_Caseless_Find_Next_Substring_P --				*/
 /***********************************************************************/

void
job_P_Caseless_Find_Next_Substring_P(
    void
) {
    find_substring_p( /* caseless: */ TRUE, /* have_offset: */ TRUE );
}

 /***********************************************************************/
 /*-    job_P_Ale -- Compare per '<='					*/
 /***********************************************************************/

void
job_P_Ale(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );

    {   Vm_Int val = obj_Neql( arg1, arg0 );
	jS.s[-1]   = OBJ_FROM_BOOL(val <= 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Age -- Compare per '>='					*/
 /***********************************************************************/

void
job_P_Age(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );

    {   Vm_Int val = obj_Neql( arg1, arg0 );
	jS.s[ -1 ] = OBJ_FROM_BOOL(val >= 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Alt -- Compare per '<'					*/
 /***********************************************************************/

void
job_P_Alt(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );

    {   Vm_Int val = obj_Neql( arg1, arg0 );
	jS.s[ -1 ] = OBJ_FROM_BOOL(val < 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Agt -- Compare per '>'					*/
 /***********************************************************************/

void
job_P_Agt(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );

    {   Vm_Int val = obj_Neql( arg1, arg0 );
	jS.s[ -1 ] = OBJ_FROM_BOOL(val > 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Aeq -- Compare per '='					*/
 /***********************************************************************/

void
job_P_Aeq(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );

    {   Vm_Int val = obj_Neql( arg1, arg0 );
	jS.s[ -1 ] = OBJ_FROM_BOOL(val == 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Ane -- Compare per '!='					*/
 /***********************************************************************/

void
job_P_Ane(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );

    {   Vm_Int val = obj_Neql( arg1, arg0 );
	jS.s[ -1 ] = OBJ_FROM_BOOL(val != 0);
    }
}

 /***********************************************************************/
 /*-    job_P_Add_Muf_Source -- "( src muf -- ) add_muf_source" op.	*/
 /***********************************************************************/

void
job_P_Add_Muf_Source(
    void
) {
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Muf_Arg(   0 );
    job_Guarantee_Stg_Arg(  -1 );
    job_Must_Control_Object( 0 );
    {   register Vm_Obj* t = jS.s;
	jS.s -= 2;  /* <- so muf_Reset sees correct initial top of stack. */
	muf_Source_Add( t[0], t[-1] );
    }
}

 /***********************************************************************/
 /*-    job_P_Assemble_After --						*/
 /***********************************************************************/

void
job_P_Assemble_After(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Branch( asm, JOB_OP_PUSH_PROTECT, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_After_Child --					*/
 /***********************************************************************/

void
job_P_Assemble_After_Child(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Branch( asm, JOB_OP_PUSH_PROTECT_CHILD, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Always_Do --					*/
 /***********************************************************************/

void
job_P_Assemble_Always_Do(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Branch( asm, JOB_OP_BLANCH_PROTECT, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Catch --						*/
 /***********************************************************************/

void
job_P_Assemble_Catch(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Branch( asm, JOB_OP_PUSH_CATCH, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Tag --						*/
 /***********************************************************************/

void
job_P_Assemble_Tag(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Branch( asm, JOB_OP_PUSH_TAG, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Beq --						*/
 /***********************************************************************/

void
job_P_Assemble_Beq(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Branch( asm, JOB_OP_BEQ, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Bne --						*/
 /***********************************************************************/

void
job_P_Assemble_Bne(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Branch( asm, JOB_OP_BNE, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Bra --						*/
 /***********************************************************************/

void
job_P_Assemble_Bra(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Branch( asm, JOB_OP_BRA, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Call --						*/
 /***********************************************************************/

void
job_P_Assemble_Call(
    void
) {
    Vm_Obj asm = jS.s[  0 ];
    Vm_Obj cfn = jS.s[ -1 ];
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    if (!OBJ_IS_SYMBOL(cfn)) {
        job_Guarantee_Cfn_Arg(   -1 );
    }
    job_Must_Control_Object( 0 );

    asm_Call( asm, cfn );

    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Calla --						*/
 /***********************************************************************/

void
job_P_Assemble_Calla(
    void
) {
    Vm_Obj asm   = jS.s[  0 ];
    Vm_Obj arity = jS.s[ -1 ];

    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Calla( asm, arity );

    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Constant --					*/
 /***********************************************************************/

void
job_P_Assemble_Constant(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Must_Control_Object( 0 );

    asm_Const( asm, jS.s[-1] );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Constant_Slot --					*/
 /***********************************************************************/

void
job_P_Assemble_Constant_Slot(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    1 );
    job_Guarantee_Asm_Arg(   0 );
    job_Must_Control_Object( 0 );

    *jS.s = OBJ_FROM_UNT( asm_ConstSlot( asm ) );
}

 /***********************************************************************/
 /*-    job_P_Assemble_Label --						*/
 /***********************************************************************/

void
job_P_Assemble_Label(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Label( asm, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Label_Get --					*/
 /***********************************************************************/

void
job_P_Assemble_Label_Get(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    1 );
    job_Guarantee_Asm_Arg(   0 );
    job_Must_Control_Object( 0 );

    *jS.s = OBJ_FROM_UNT( asm_Label_Get( asm ) );
}

 /***********************************************************************/
 /*-    job_P_Assemble_Line_In_Fn --					*/
 /***********************************************************************/

void
job_P_Assemble_Line_In_Fn(
    void
) {
    Vm_Obj asm         = jS.s[  0 ];
    Vm_Obj line_in_fn  = jS.s[ -1 ];
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Line_In_Fn( asm, line_in_fn );
}

 /***********************************************************************/
 /*-    job_P_Assemble_Nth_Constant_Get --				*/
 /***********************************************************************/

void
job_P_Assemble_Nth_Constant_Get(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_ConstNth( asm, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Variable_Get --					*/
 /***********************************************************************/

void
job_P_Assemble_Variable_Get(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Var( asm, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Variable_Set --					*/
 /***********************************************************************/

void
job_P_Assemble_Variable_Set(
    void
) {
    Vm_Obj asm = *jS.s;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );

    asm_Var_Set( asm, OBJ_TO_UNT( jS.s[-1] ) );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Assemble_Variable_Slot --					*/
 /***********************************************************************/

void
job_P_Assemble_Variable_Slot(
    void
) {
    Vm_Obj asm  = jS.s[ 0];
    Vm_Obj name = jS.s[-1];
    Vm_Obj result;
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Asm_Arg(   0 );
    job_Must_Control_Object( 0 );
    result  = OBJ_FROM_INT( asm_Var_Next(asm, name) );
    *--jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Block_Length -- '|length' function.			*/
 /***********************************************************************/

void
job_P_Block_Length(
    void
) {
    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    *++jS.s = OBJ_FROM_INT(size);
}

 /***********************************************************************/
 /*-    job_P_Block_Break -- ']break' operator.				*/
 /***********************************************************************/

void
job_P_Block_Break(
    void
) {
    Vm_Obj do_break = JOB_P(jS.job)->do_break;

    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    if (size & 1) MUQ_WARN ("]break argblock length must be even.");
    job_Guarantee_N_Args( size+2 );

    /* Scan argument block for :job and :event */
    {   Vm_Int events_found = 0;
	Vm_Int i;
	for (i = 0;   i < size;   i += 2) {

	    Vm_Int key_index  = i-size;
	    Vm_Int val_index  = key_index +1;
	    Vm_Obj key        = jS.s[ key_index ];
	    Vm_Obj val        = jS.s[ val_index ];

	    if        (key == job_Kw_Event  ) {
		if (!OBJ_IS_OBJ(val)
/*		||  !OBJ_IS_CLASS_EVT(val) */
		){
		    MUQ_WARN ("]break :event must be an Event.");
		}
		++events_found;
	    } else if (!OBJ_IS_SYMBOL(key)) {
		MUQ_WARN ("]break keywords must be symbols.");
    	}   }

	if (events_found != 1) {
	    MUQ_WARN ("]break needs exactly one :event.");
	}
    }

    /* Find our doBreak function: */

    /* Buggo, should be an arity check somewhere... */

    if (OBJ_IS_SYMBOL(do_break)) {
	do_break = job_Symbol_Function(do_break);
    }

    /* Do call only if do_break */
    /* is a compiled function:  */    
    if (!OBJ_IS_CFN(do_break)) {
	jS.s -= size+2;
	return;
    }

    /* Do call only if breakDisable is NIL: */
    if (JOB_P(jS.job)->break_disable != OBJ_NIL) {
	jS.s -= size+2;
	return;
    }

#ifdef NOT_COOL_YET /* buggo */
/* problem with this is that nobody is going to pop it yet: */
    /* Switch actingUser to actualUser  */
    /* so that ]doSignal function runs   */
    /* in a more predictable environment: */
    push_user_frame( jS.j.actual_user );
#endif

    /* Execute call to doBreak fn: */
    job_Call( do_break );
}

 /***********************************************************************/
 /*-    job_P_Break -- 'break' operator.				*/
 /***********************************************************************/

void
job_P_Break(
    void
) {
    Vm_Obj do_break = JOB_P(jS.job)->do_break;

    job_Guarantee_Stg_Arg(  0 );

    /* Find our doBreak function: */

    /* Buggo, should be an arity check somewhere... */

    job_Guarantee_Headroom( 5 );

    if (OBJ_IS_SYMBOL(do_break)) {
	do_break = job_Symbol_Function(do_break);
    }

    /* Do call only if do_break */
    /* is a compiled function:  */    
    if (!OBJ_IS_CFN(do_break)) {
	--jS.s;
	return;
    }

    /* Do call only if breakDisable is NIL: */
    if (JOB_P(jS.job)->break_disable != OBJ_NIL) {
	--jS.s;
	return;
    }

#ifdef NOT_COOL_YET /* buggo */
/* problem with this is that nobody is going to pop it yet: */
    /* Switch actingUser to actualUser  */
    /* so that ]doSignal function runs   */
    /* in a more predictable environment: */
    push_user_frame( jS.j.actual_user );
#endif

    /* Convert single given string */
    /* to a proper event block:    */
    {   Vm_Obj string = *jS.s;
	*jS.s++ = OBJ_BLOCK_START;
	*jS.s++ = job_Kw_Event;
	*jS.s++ = obj_Err_Simple_Event;
	*jS.s++ = job_Kw_Format_String;
	*jS.s++ = string;
	*jS.s   = OBJ_FROM_BLK( 4 );

	/* Execute call to doBreak fn: */
	job_Call( do_break );
    }
}

 /***********************************************************************/
 /*-    job_P_Char_To_Int -- 'charInt'					*/
 /***********************************************************************/

void
job_P_Char_To_Int(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );
    *jS.s = OBJ_FROM_INT( OBJ_TO_CHAR( *jS.s ) );
}

 /***********************************************************************/
 /*-    job_P_Chars2_To_Int -- 'chars2Int'				*/
 /***********************************************************************/

void
job_P_Chars2_To_Int(
    void
) {
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Char_Arg(  0 );
    job_Guarantee_Char_Arg( -1 );
    {   Vm_Obj result = OBJ_FROM_INT(
	    OBJ_TO_CHAR(jS.s[-1]) << 8   |   OBJ_TO_CHAR(jS.s[0])
	);
        *--jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Chars4_To_Int -- 'chars4Int'				*/
 /***********************************************************************/

void
job_P_Chars4_To_Int(
    void
) {
    Vm_Int i;
    job_Guarantee_N_Args(    4 );
    job_Guarantee_Char_Arg(  0 );
    job_Guarantee_Char_Arg( -1 );
    job_Guarantee_Char_Arg( -2 );
    job_Guarantee_Char_Arg( -3 );
    i = (
	OBJ_TO_CHAR( jS.s[-3] ) << 24    |
	OBJ_TO_CHAR( jS.s[-2] ) << 16    |
	OBJ_TO_CHAR( jS.s[-1] ) <<  8    |
	OBJ_TO_CHAR( jS.s[-0] )
    );
     jS.s -= 3;
    *jS.s  = OBJ_FROM_INT( i );
}

 /***********************************************************************/
 /*-    job_P_Ints3_To_Dbref -- 'ints3ToDbref'			*/
 /***********************************************************************/

void
job_P_Ints3_To_Dbref(
    void
) {
    job_Guarantee_N_Args(    3 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg( -2 );
    {   Vm_Unt i0 = OBJ_TO_UNT( jS.s[-2] );
	Vm_Unt i1 = OBJ_TO_UNT( jS.s[-1] );
	Vm_Unt i2 = OBJ_TO_UNT( jS.s[ 0] );
	Vm_Unt ok;
	Vm_Obj o  = obj_Ints3_To_Dbref( &ok, i0, i1, i2 );
	--jS.s;
        jS.s[-1]  = OBJ_FROM_BOOL(ok);
        jS.s[ 0]  = o;
    }
}

 /***********************************************************************/
 /*-    job_P_Int_To_Dbname -- 'intToDbname'				*/
 /***********************************************************************/

void
job_P_Int_To_Dbname(
    void
) {
    Vm_Unt i  = OBJ_TO_INT( *jS.s );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    *jS.s     = stg_From_Asciz( vm_DbId_To_Asciz( i ) );
}

 /***********************************************************************/
 /*-    job_P_Dbname_To_Int -- 'dbnameToInt'				*/
 /***********************************************************************/

void
job_P_Dbname_To_Int(
    void
) {
    Vm_Chr str_buf[ 8 ];
    Vm_Int str_len;
    Vm_Obj str = *jS.s;
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Stg_Arg( 0 );
    str_len = stg_Len( str );
    if (str_len > 7)   str_len = 7;
    if (str_len != stg_Get_Bytes( str_buf, str_len, str, 0 )) {
	MUQ_WARN ("dbnameToInt: internal error");
    }
    str_buf[str_len] = '\0';
    *jS.s = OBJ_FROM_INT( vm_Asciz_To_DbId( str_buf )  );
}

 /***********************************************************************/
 /*-    job_P_Dbref_To_Ints3 -- 'dbrefToInts3'			*/
 /***********************************************************************/

void
job_P_Dbref_To_Ints3(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Headroom( 2 );
    {   Vm_Unt i0 = 0;
	Vm_Unt i1 = 0;
	Vm_Unt i2 = 0;
	obj_Dbref_To_Ints3( &i0, &i1, &i2, *jS.s );
	jS.s += 2;
	jS.s[-2] = OBJ_FROM_UNT(i0);
	jS.s[-1] = OBJ_FROM_UNT(i1);
	jS.s[ 0] = OBJ_FROM_UNT(i2);
    }
}

 /***********************************************************************/
 /*-    job_P_Char_To_Int_Block -- "|charInt" function.		*/
 /***********************************************************************/

void
job_P_Char_To_Int_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int len = OBJ_TO_BLK( *jS.s );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args( len+2 );

    /* Find block, do conversion: */
    {   register Vm_Obj*p = &jS.s[ -len ]; /* Base of our block. */
	register Vm_Int i;
	for (i = len;   i --> 0;  ++p) {
	    register Vm_Obj v = *p;
	    if (OBJ_IS_CHAR(v))  *p = OBJ_FROM_INT( OBJ_TO_CHAR(v) );
        }
    }
}


 /***********************************************************************/
 /*-    job_P_Char_To_String -- 'char->string'				*/
 /***********************************************************************/

void
job_P_Char_To_String(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Char_Arg( 0 );
    *jS.s = OBJ_FROM_BYT1( OBJ_TO_CHAR( *jS.s ) );
}

 /***********************************************************************/
 /*-    job_P_String_To_Keyword -- 'string->keyword'			*/
 /***********************************************************************/

void
job_P_String_To_Keyword(
    void
) {
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Stg_Arg( 0 );
    *jS.s = sym_Alloc_Keyword( *jS.s );
}

 /***********************************************************************/
 /*-    job_P_Class -- Return current class object.			*/
 /***********************************************************************/

void
job_P_Class(
    void
) {
    /* Seize one stack location, and push result in it: */
    *++jS.s = JOB_P(jS.job)->class;
}

 /***********************************************************************/
 /*-    job_P_Compiled_Function_Bytecodes				*/
 /***********************************************************************/

void
job_P_Compiled_Function_Bytecodes(
    void
) {
    Vm_Obj x = *jS.s;
    job_Guarantee_Cfn_Arg(  0 );
    job_must_control( x );

    { /*Vm_Unt len = vm_Len(x); */
	Vm_Int n   = cfn_Bytes_Of_Code(x);
	Cfn_P  p;
	Vm_Uch*t;
	Vm_Int u;

	job_Guarantee_Headroom( n+1 );

	p        = CFN_P(x);
	t        = (Vm_Uch*) &p->vec[ CFN_CONSTS(p->bitbag) ];

	*jS.s    = OBJ_BLOCK_START;
	for   (u = 0;   u < n;   ++u) *++jS.s = OBJ_FROM_INT( t[u] );
	*++jS.s  = OBJ_FROM_BLK( n );
    }
}

 /***********************************************************************/
 /*-    job_P_Compiled_Function_Constants				*/
 /***********************************************************************/

void
job_P_Compiled_Function_Constants(
    void
) {
    Vm_Obj x = *jS.s;
    job_Guarantee_Cfn_Arg(  0 );
    job_must_control( x );

    {   Cfn_P  p   = CFN_P(x);
        Vm_Int n   = CFN_CONSTS( p->bitbag );
	Vm_Int i;

	job_Guarantee_Headroom( n+1 );

	*jS.s    = OBJ_BLOCK_START;
	for (i = 0;   i < n;   ++i)   *++jS.s = p->vec[i];
	*++jS.s  = OBJ_FROM_BLK( n );
    }
}

 /***********************************************************************/
 /*-    job_P_Compiled_Function_Disassembly				*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Compiled_Function_Disassembly(
    void
) {
    Vm_Obj x = *jS.s;
    job_Guarantee_Cfn_Arg(  0 );
    job_must_control( x );

    {   Vm_Obj stg;	/* String holding disassembled code. */
        Vm_Chr buf[ MAX_STRING ];
        Vm_Chr*end;
    /*	Vm_Unt len = vm_Len(x); */
	Vm_Int n   = cfn_Bytes_Of_Code(x);
	Cfn_P  p   = CFN_P(x);
	Vm_Uch*t   = (Vm_Uch*) &p->vec[ CFN_CONSTS(p->bitbag) ];

	#ifdef OLD
	Vm_Int u;
	for   (u = 0;   u < n;   ++u) {
	    if (!(u & 0xF))   buf = lib_Sprint(buf,lim, "\n%02x:", (int)u  );
	    buf                   = lib_Sprint(buf,lim, " %02x", (int)(t[u]) );
	}
	buf = lib_Sprint( buf,lim, "\n" );
	#endif

	end   = asm_Sprint_Code_Disassembly( buf,buf+MAX_STRING, t, t+n );
	stg   = stg_From_Buffer( buf, end-buf );
	*jS.s = stg;
    }
}

 /***********************************************************************/
 /*-    job_P_Cons -- "cons" function.					*/
 /***********************************************************************/

void
job_P_Cons(
    void
) {
    Vm_Obj cdr = jS.s[ 0];
    Vm_Obj car = jS.s[-1];
    job_Guarantee_N_Args(  2 );
    *--jS.s = lst_Alloc( car, cdr );
}

 /***********************************************************************/
 /*-    job_P_Root_All_Active_Sockets -- "rootAllActiveSockets["	*/
 /***********************************************************************/

void
job_P_Root_All_Active_Sockets(
    void
) {
    /* Count number of active sockets: */
    Vm_Int len;
    for (
	len = 0;
	skt_Nth_Active_Socket( len ) != OBJ_NOT_FOUND;
	++len
    );

    /* Reserve sufficient stack space: */
    job_Guarantee_Headroom( len+2 );

    /* Stuff them all on: */
    {   Vm_Int i;
	*++jS.s = OBJ_BLOCK_START;
	for (i = 0;   i < len;   ++i) {
	    Vm_Obj skt = skt_Nth_Active_Socket( i );
	    *++jS.s    = skt;
	}
	*++jS.s = OBJ_FROM_BLK( len );
    }
}

 /***********************************************************************/
 /*-    job_P_Close_Socket -- "close-socket"				*/
 /***********************************************************************/

void
job_P_Close_Socket(
    void
) {
    Vm_Int i;
    Vm_Obj socket         = OBJ_NOT_FOUND;

    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    if (size & 1) {
	MUQ_WARN ("]closeSocket argblock length must be even.");
    }
    job_Guarantee_N_Args( size+2 );

    /* Parse the arguments: */
    for (i = 0;   i < size;   i += 2) {

	Vm_Int key_index  = i-size;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Socket        ) {
	    if (OBJ_IS_OBJ(val)
	    &&  OBJ_IS_CLASS_SKT(val)
	    ){
		socket = val;
	    } else {
		MUQ_WARN ("]closeSocket :socket arg must be a socket.");
	    }
	} else {
	    MUQ_WARN ("Unrecognized ]closeSocket keyword.");
    }	}	

    if (socket == OBJ_NOT_FOUND) {
	MUQ_WARN ("Missing ]closeSocket :socket parameter.");
    }
    job_must_control( socket );

    skt_Close( socket );
    
    jS.s -= size+2;
}

 /***********************************************************************/
 /*-    job_P_Popen_Socket -- "]popen-socket"				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_skip_whitespace -- 						*/
  /**********************************************************************/

static Vm_Uch*
job_skip_whitespace(
    Vm_Uch* t
) {
    while (*t && isspace(*t))  ++t;
    return t;
}

  /**********************************************************************/
  /*-   job_strip_whitespace --						*/
  /**********************************************************************/

static Vm_Int
job_strip_whitespace(
    Vm_Uch* t,
    Vm_Int  len
) {
    while (len && isspace(t[len-1]))  t[--len] = '\0';
    return len;
}

  /**********************************************************************/
  /*-   job_P_Root_Popen_Socket -- "]rootPopenSocket"			*/
  /**********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Root_Popen_Socket(
    void
) {
    Vm_Chr  buf[ MAX_STRING ];
    Vm_Chr* cmd;
    Vm_Int  len;
    Vm_Int  i;
    Vm_Obj  popen  = OBJ_NOT_FOUND;
    Vm_Obj  socket = OBJ_NOT_FOUND;
    Vm_Int  pipe_into_child = FALSE;
    Vm_Int  pipe_from_child = FALSE;

    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    if (size & 1) MUQ_WARN("]rootPopenSocket argblock length must be even.");
    job_Guarantee_N_Args( size+2 );

    /* Parse the arguments: */
    for (i = 0;   i < size;   i += 2) {

	Vm_Int key_index  = i-size;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Socket) {
	    if (OBJ_IS_OBJ(val)
	    &&  OBJ_IS_CLASS_SKT(val)
	    ){
		socket = val;
	    } else {
		MUQ_WARN ("]rootPopenSocket :socket arg must be a socket.");
	    }
        } else if (key == job_Kw_Commandline ) {
	    if (stg_Is_Stg(val)) {
		popen = val;
	    } else {
		MUQ_WARN ("]rootPopenSocket :commandline arg must be a string.");
	    }
	} else {
	    MUQ_WARN ("Unrecognized ]rootPopenSocket keyword.");
    }	}	

    if (socket == OBJ_NOT_FOUND) {
	MUQ_WARN ("Missing ]rootPopenSocket :socket parameter.");
    }
    job_must_control( socket );

    if (popen == OBJ_NOT_FOUND) {
	MUQ_WARN ("Missing ]rootPopenSocket :popen parameter.");
    }

    if (!OBJ_IS_CLASS_ROT(jS.j.acting_user)) {
	MUQ_WARN( "]rootPopenSocket: @$s.actingUser must be root");
    }
    if (!obj_Srv_Dir) {
	MUQ_WARN ("]rootPopenSocket disabled: See --srvdir commandline option");
    }

    len = stg_Get_Bytes(
	buf, MAX_STRING,
	popen, 0
    );
    if (len >= MAX_STRING)   MUQ_WARN (":popen string too long");
    buf[ len ] = '\0';

    /* Check for and eat trailing "... |": */
    len = job_strip_whitespace( buf, len );
    if (len && buf[len-1] == '|') {
	pipe_from_child = TRUE;
	buf[ --len ]    = '\0';
        len = job_strip_whitespace( buf, len );
    }

    /* Check for and eat leading "| ...": */
    cmd = job_skip_whitespace( buf );
    if (*cmd == '|') {
	pipe_into_child = TRUE;
	cmd = job_skip_whitespace( cmd+1 );
    }

    /* Do some security checks on commandline: */
    if (*cmd == '.')  MUQ_WARN("Program name may not start with '.'");
    {   Vm_Uch* t;
	Vm_Uch  c;
	for (t=cmd; (c=*t) && !isspace(c); ++t) {
	    if (!isalnum(c)
	    &&  c != '.'
	    &&  c != '-'
	    ){
		MUQ_WARN("Program name may not contain '%c'",c);
    }	}   }

    if (!(pipe_into_child|pipe_from_child)) {
	MUQ_WARN("Must pipe either into or out of popen'd child");
    }

    /* Maybe fail if socket%s/standardInput */
    /* is not a messageStream:              */
    if (pipe_into_child) {
	Vm_Obj mss = SKT_P(socket)->standard_input;
        if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	    MUQ_WARN (
		"Bad ]rootPopenSocket socket$s.standardInput value."
	    );
    }   }

    /* Maybe fail if socket%s/standardOutput */
    /* is not a messageStream:               */
    if (pipe_from_child) {
	Vm_Obj mss = SKT_P(socket)->standard_output;
        if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	    MUQ_WARN (
		"Bad ]rootPopenSocket socket$s.standardOutput value."
	    );
    }   }

    skt_Popen(
        socket,
        cmd,
	pipe_into_child,
	pipe_from_child
    );

    jS.s -= size+2;
}

 /***********************************************************************/
 /*-    job_P_Open_Socket -- "]openSocket"				*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Open_Socket(
    void
) {
    Vm_Chr hostname[ MAX_STRING ];
    Vm_Int i;
    Vm_Unt iport          = 0;
    Vm_Obj ip0            = OBJ_NOT_FOUND;
    Vm_Obj ip1            = OBJ_NOT_FOUND;
    Vm_Obj ip2            = OBJ_NOT_FOUND;
    Vm_Obj ip3            = OBJ_NOT_FOUND;
    Vm_Obj port           = OBJ_NOT_FOUND;
    Vm_Obj host           = OBJ_NOT_FOUND;
    Vm_Obj socket         = OBJ_NOT_FOUND;
    Vm_Int protocol       = SOCK_STREAM;
    Vm_Int address_family = AF_INET;

    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    if (size & 1) MUQ_WARN ("]openSocket argblock length must be even.");
    job_Guarantee_N_Args( size+2 );

    /* Parse the arguments: */
    for (i = 0;   i < size;   i += 2) {

	Vm_Int key_index  = i-size;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Socket        ) {
	    if (OBJ_IS_OBJ(val)
	    &&  OBJ_IS_CLASS_SKT(val)
	    ){
		socket = val;
	    } else {
		MUQ_WARN ("]openSocket :socket arg must be a socket.");
	    }
        } else if (key == job_Kw_Port          ) {
	    if (OBJ_IS_INT(val)) {
		iport = OBJ_TO_UNT(val);
		if (iport > 0xFFFF) {
		    MUQ_WARN("Bad port number: %d",(int)i);
		}
		port = val;
	    } else {
		MUQ_WARN ("]openSocket :port arg must be an integer.");
	    }
        } else if (key == job_Kw_Host          ) {
	    if (stg_Is_Stg(val)) {
		Vm_Int len = stg_Get_Bytes(
		    hostname, MAX_STRING,
		    val, 0
		);
		if (len >= MAX_STRING)   MUQ_WARN (":host name too long");
		hostname[ len ] = '\0';
		host = val;
	    } else {
		MUQ_WARN ("]openSocket :host arg must be a string.");
	    }
        } else if (key == job_Kw_Ip0           ) {
	    if (OBJ_IS_INT(val)) {
		ip0 = val;
	    } else {
		MUQ_WARN ("]openSocket :ip0 arg must be an integer.");
	    }
        } else if (key == job_Kw_Ip1           ) {
	    if (OBJ_IS_INT(val)) {
		ip1 = val;
	    } else {
		MUQ_WARN ("]openSocket :ip1 arg must be an integer.");
	    }
        } else if (key == job_Kw_Ip2           ) {
	    if (OBJ_IS_INT(val)) {
		ip2 = val;
	    } else {
		MUQ_WARN ("]openSocket :ip2 arg must be an integer.");
	    }
        } else if (key == job_Kw_Ip3           ) {
	    if (OBJ_IS_INT(val)) {
		ip3 = val;
	    } else {
		MUQ_WARN ("]openSocket :ip3 arg must be an integer.");
	    }
        } else if (key == job_Kw_Protocol      ) {
	    if (val == job_Kw_Stream) {
		protocol = SOCK_STREAM;
	    } else if (val == job_Kw_Datagram) {
		protocol = SOCK_DGRAM;
	    } else {
		MUQ_WARN (
		    "]openSocket :protocol arg must be :stream or :datagram."
		);
	    }
        } else if (key == job_Kw_Address_Family) {
	    if (val == job_Kw_Internet) {
		address_family = AF_INET;
	    } else {
		MUQ_WARN (
		    "]openSocket :address-family arg must be :internet."
		);
	    }
	} else {
	    MUQ_WARN ("Unrecognized ]openSocket keyword.");
    }	}	

    if (socket == OBJ_NOT_FOUND) {
	MUQ_WARN ("Missing ]openSocket :socket parameter.");
    }
    job_must_control( socket );

    /* Fail if socket%s/standardOutput */
    /* is not a messageStream:         */
    {   Vm_Obj mss = SKT_P(socket)->standard_output;
        if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	    MUQ_WARN (
		"Bad ]openSocket socket$s.standardOutput value."
	    );
    }   }

    /* Fail if socket%s/standardInput */
    /* is not a messageStream:        */
    if (protocol != SOCK_STREAM) {	/* stream listener needs no input */
	Vm_Obj mss = SKT_P(socket)->standard_input;
        if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	    MUQ_WARN (
		"Bad ]openSocket socket$s.standardInput value."
	    );
    }   }

    if (ip0 != OBJ_NOT_FOUND
    ||  ip1 != OBJ_NOT_FOUND
    ||  ip2 != OBJ_NOT_FOUND
    ||  ip3 != OBJ_NOT_FOUND
    ){
	if (ip0 == OBJ_NOT_FOUND) MUQ_WARN ("]openSocket: missing :ip0");
	if (ip1 == OBJ_NOT_FOUND) MUQ_WARN ("]openSocket: missing :ip1");
	if (ip2 == OBJ_NOT_FOUND) MUQ_WARN ("]openSocket: missing :ip3");
	if (ip3 == OBJ_NOT_FOUND) MUQ_WARN ("]openSocket: missing :ip3");
        if (host!= OBJ_NOT_FOUND) {
	    MUQ_WARN  ("May not have both :host and :ip0/:ip1/:ip2:/ip3");
	}
	sprintf(
	    hostname,
	    "%d.%d.%d.%d", 
	    (int)OBJ_TO_INT( ip0 ),
	    (int)OBJ_TO_INT( ip1 ),
	    (int)OBJ_TO_INT( ip2 ),
	    (int)OBJ_TO_INT( ip3 )
	);
    } else {
	if (host == OBJ_NOT_FOUND) {
	    strcpy( hostname, "127.0.0.1" );
	}
    }
 
    if (port   == OBJ_NOT_FOUND) {
	iport = 23;
    }
    /* Check that user is allowed to connect to that port: */
    if (!obj_Outbound_Port_Is_Allowed(
	    obj_Allowed_Outbound_Net_Ports,
	    iport
	) && (
	    !(jS.j.privs & JOB_PRIVS_OMNIPOTENT)   ||
	    !OBJ_IS_CLASS_ROT(jS.j.acting_user)    ||
	    !obj_Outbound_Port_Is_Allowed(
		obj_Root_Allowed_Outbound_Net_Ports,
		iport
	)   )
    ) {
	MUQ_WARN (
	    "Forbidden port: Use 'muq --[root]destports=+%d' to allow it",
	    (int)iport
	);
    }

    skt_Open(
	socket,
	hostname,
	address_family,
	protocol,
	INADDR_ANY,
	iport
    );
    
    jS.s -= size+2;
}

 /***********************************************************************/
 /*-    job_P_Listen_On_Socket -- "]listenOnSocket"			*/
 /***********************************************************************/

void
job_P_Listen_On_Socket(
    void
) {
    Vm_Int i;
    Vm_Obj socket         = OBJ_NOT_FOUND;
    Vm_Obj port           = OBJ_NOT_FOUND;
    Vm_Int protocol       = SOCK_STREAM;
    Vm_Int address_family = AF_INET;
    Vm_Int interfaces     = INADDR_ANY;

    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    if (size & 1) {
	MUQ_WARN ("]listenOnSocket argblock length must be even.");
    }
    job_Guarantee_N_Args( size+2 );

    /* Parse the arguments: */
    for (i = 0;   i < size;   i += 2) {

	Vm_Int key_index  = i-size;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Message_Stream) {
	    MUQ_WARN (
		"]listenOnSocket :messageStream parameter "
		"has been replaced by the :socket parameter."
	    );
	} else if (key == job_Kw_Socket) {
	    if (OBJ_IS_OBJ(val)
	    &&  OBJ_IS_CLASS_SKT(val)
	    ){
		socket = val;
	    } else {
		MUQ_WARN (
		    "]listenOnSocket :socket arg "
		    "must be a socket."
		);
	    }
        } else if (key == job_Kw_Port          ) {
	    if (OBJ_IS_INT(val)) {
		port = val;
	    } else {
		MUQ_WARN (
		    "]listenOnSocket :port arg must be an integer."
		);
	    }
        } else if (key == job_Kw_Interfaces    ) {
	    if (val == job_Kw_Any) {
		interfaces = INADDR_ANY;
	    } else {
		MUQ_WARN (
		    "]listenOnSocket :interfaces arg must be :any."
		);
	    }
        } else if (key == job_Kw_Protocol      ) {
	    if (val == job_Kw_Stream) {
		protocol = SOCK_STREAM;
	    } else if (val == job_Kw_Datagram) {
		protocol = SOCK_DGRAM;
	    } else {
		MUQ_WARN (
		    "]listenOnSocket :protocol arg "
		    "must be :stream or :datagram."
		);
	    }
        } else if (key == job_Kw_Address_Family) {
	    if (val == job_Kw_Internet) {
		address_family = AF_INET;
	    } else {
		MUQ_WARN (
		    "]listenOnSocket :address-family "
		    "arg must be :internet."
		);
	    }
	} else {
	    MUQ_WARN ("Unrecognized ]listenOnSocket keyword.");
    }	}	

    if (port   == OBJ_NOT_FOUND) {
	MUQ_WARN ("Missing ]listenOnSocket :port parameter.");
    }
    if (socket == OBJ_NOT_FOUND) {
	MUQ_WARN (
	    "Missing ]listenOnSocket :socket parameter."
	);
    }
    job_must_control( socket );

    /* Fail if socket%s/standardOutput */
    /* is not a messageStream:         */
    {   Vm_Obj mss = SKT_P(socket)->standard_output;
        if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	    MUQ_WARN (
		"Bad ]listenOnSocket socket$s.standardOutput value."
	    );
    }   }

    skt_Listen(
	socket,
	address_family,
	protocol,
	interfaces,
	OBJ_TO_INT(port)
    );

    jS.s -= size+2;
}

 /***********************************************************************/
 /*-    job_P_Count_Lines_In_String -- 					*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Count_Lines_In_String(
    void
) {
    Vm_Int str_len;
    Vm_Chr str_buf[ MAX_STRING ];
    Vm_Obj str = *jS.s;
    job_Guarantee_Stg_Arg(   0 );
    str_len = stg_Len( str );
    if (str_len >= MAX_STRING-1) {
	MUQ_WARN ("countLinesInString: arg too big");
    }
    if (str_len != stg_Get_Bytes( str_buf, str_len, str, 0 )) {
	MUQ_WARN ("countLinesInString: internal error");
    }
    {   register Vm_Chr* p = str_buf;
	register Vm_Int  i = str_len;	/* Chars to check. */
	register Vm_Int  l = 0;		/* Lines found.    */
	while (i --> 0) if (*p++ == '\n') ++l;
	if (str_buf[ str_len-1 ] != '\n') ++l;
	*jS.s = OBJ_FROM_INT(l);
    }
}

 /***********************************************************************/
 /*-    job_P_Get_Line_From_String -- 					*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Get_Line_From_String(
    void
) {
    Vm_Int str_len;
    Vm_Chr str_buf[ MAX_STRING ];
    Vm_Obj str =             jS.s[ -1 ]  ;
    Vm_Int n   = OBJ_TO_INT( jS.s[  0 ] );
    job_Guarantee_Stg_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    str_len = stg_Len( str );
    if (str_len >= MAX_STRING-1) {
	MUQ_WARN ("getLineFromString: arg too big");
    }
    if (str_len != stg_Get_Bytes( str_buf, str_len, str, 0 )) {
	MUQ_WARN ("getLineFromString: internal error");
    }
    {	Vm_Chr* start;
	register Vm_Chr* p = str_buf;
	register Vm_Int  i = str_len;	/* Chars to check. */
	register Vm_Int  l = 0;		/* Lines found.    */
	if (n) while (i --> 0) if (*p++ == '\n' && ++l == n)  break;
	if (l != n) MUQ_WARN ("getLineFromString: No line %d.",(int)n);
	start = p;
	while (i --> 0) if (*p++ == '\n') { --p; break; }
	if (str_buf[ str_len-1 ] != '\n') ++l;
	{   Vm_Obj result = stg_From_Buffer( start, p-start );
	    *--jS.s = result;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Expand_C_String_Escapes -- Conver \n \0 etc, return len.	*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

  /**********************************************************************/
  /*-   job_expand_c_string_escapes--Convert \n \0 etc, return final len*/
  /**********************************************************************/

static Vm_Unt
job_expand_c_string_escapes(
    Vm_Chr* buf,
    Vm_Unt  len
) {
    /* Expand \n etc correctly: */
    Vm_Chr* cat = buf;
    Vm_Chr* rat = buf;
    while (len --> 0) {	
	Vm_Chr c = *rat++;
	if (c != '\\') {
	    *cat++ = c;
	} else {
	    --len;
	    switch (c = *rat++) {
	    case '0':   *cat++ = '\0';	break;
	    case 'a':   *cat++ = '\a';	break;
	    case 'b':   *cat++ = '\b';	break;
	    case 'f':   *cat++ = '\f';	break;
	    case 'n':   *cat++ = '\n';	break;
	    case 'r':   *cat++ = '\r';	break;
	    case 't':   *cat++ = '\t';	break;
	    case 'v':   *cat++ = '\v';	break;
	    default:    *cat++ =   c ;	break;
	    }
	}	
    }

    return   cat - buf;
}

  /**********************************************************************/
  /*-   job_P_Expand_C_String_Escapes -- Convert \n \0 etc.		*/
  /**********************************************************************/

void
job_P_Expand_C_String_Escapes(
    void
) {

    job_Guarantee_N_Args(  1 );
    job_Guarantee_Stg_Arg( 0 );
    
    {   Vm_Obj stg = jS.s[ 0 ];
	Vm_Chr buf[ MAX_STRING ];
        Vm_Int len = stg_Len( stg );
	if (len >= MAX_STRING) MUQ_WARN ("expandCStringEscapes: arg too big");
	if (len != stg_Get_Bytes( buf, len, stg, 0 )) {
	    MUQ_WARN ("expandCStringEscapes: internal error");
	}

	{   Vm_Int newlen = job_expand_c_string_escapes( buf, len );
	    if (newlen != len) {
		stg = stg_From_Buffer( buf, newlen );
		*jS.s = stg;
    }   }   }
}

 /***********************************************************************/
 /*-    job_P_Do_C_Backslashes -- Convert \n \0 etc.			*/
 /***********************************************************************/

void
job_P_Do_C_Backslashes(
    void
) {
    /* Guarantee valid argblock: */
    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args( size+2 );
    
    {   register Vm_Obj* cat = jS.s - size;
        register Vm_Obj* rat = cat;
        register Vm_Obj* mat = jS.s;
        register Vm_Obj  old = OBJ_FROM_INT(0);
	while (rat < mat) {
	    if (old == OBJ_FROM_CHAR('\\')) {
		old = *rat++;
		/* Note that the programmer never has to know what */
		/* (say) \v is -- one compiler tells the next :)   */
		switch (old) {
		case OBJ_FROM_CHAR('0'):  *cat++ = OBJ_FROM_CHAR('\0');	break;
		case OBJ_FROM_CHAR('a'):  *cat++ = OBJ_FROM_CHAR('\a');	break;
		case OBJ_FROM_CHAR('b'):  *cat++ = OBJ_FROM_CHAR('\b');	break;
		case OBJ_FROM_CHAR('f'):  *cat++ = OBJ_FROM_CHAR('\f');	break;
		case OBJ_FROM_CHAR('n'):  *cat++ = OBJ_FROM_CHAR('\n');	break;
		case OBJ_FROM_CHAR('r'):  *cat++ = OBJ_FROM_CHAR('\r');	break;
		case OBJ_FROM_CHAR('t'):  *cat++ = OBJ_FROM_CHAR('\t');	break;
		case OBJ_FROM_CHAR('v'):  *cat++ = OBJ_FROM_CHAR('\v');	break;
		default:                  *cat++ = old;			break;
		}
		old = OBJ_FROM_INT(0);
	    } else {
		old = *rat++;
		if (old != OBJ_FROM_CHAR('\\'))  *cat++ = old;
	    }
	}
	{   Vm_Int shrink = rat - cat;
	    jS.s -= shrink;
	   *jS.s  = OBJ_FROM_BLK( size-shrink );
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Backslashes_To_Highbit -- Set high bit on quoted chars.	*/
 /***********************************************************************/

#undef  QUOTED
#define QUOTED	0x1000

void
job_P_Backslashes_To_Highbit(
    void
) {
    /* Guarantee valid argblock: */
    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args( size+2 );
    
    {   register Vm_Obj* cat = jS.s - size;
        register Vm_Obj* rat = cat;
        register Vm_Obj* mat = jS.s;
        register Vm_Obj  old = OBJ_FROM_INT(0);
	while (rat < mat) {
	    if (old != OBJ_FROM_CHAR('\\')) {
		old = *rat++;
		if (old != OBJ_FROM_CHAR('\\')) {
		    if (OBJ_IS_CHAR(old)) {
			*cat++ = OBJ_FROM_INT( OBJ_TO_CHAR(old) & 0xFF );
		    } else {
			*cat++ = old;
		    }
		}
	    } else {
		old = *rat++;
		if (OBJ_IS_CHAR(old)) {
		    *cat++ = OBJ_FROM_INT( (OBJ_TO_CHAR(old)&0xFF)|QUOTED );
		} else {
		    *cat++ =                            old                ;
		}
		old = OBJ_FROM_INT(0);
	    }
	}
	{   Vm_Int shrink = rat - cat;
	    jS.s -= shrink;
	   *jS.s  = OBJ_FROM_BLK( size-shrink );
	}
    }
}

  /**********************************************************************/
  /*-   job_P_Make_Symbol --						*/
  /**********************************************************************/


#ifndef JOB_MAX_SYMBOL_NAME
#define JOB_MAX_SYMBOL_NAME 1024
#endif

   /*********************************************************************/
   /*-  job_makesym_first_colon --					*/
   /*********************************************************************/

static
Vm_Int /* Loc of first unquoted colon in token, else -1 */
job_makesym_first_colon(
    Vm_Obj* loc,
    Vm_Int  len
){
    Vm_Int first_colon = -1;
    Vm_Int colons = 0;
    Vm_Int i;
    Vm_Int c;
    Vm_Int b = '\0';

    /* Special hacks so : and :: are vanilla */
    /* symbols, to keep MUF happy:           */
    if (len==1)   return -1;	/*"No colons"*/
    if (len==2
    && loc[0]==OBJ_FROM_INT(':')
    && loc[1]==OBJ_FROM_INT(':')
    ){
	return -1;	/* No colons, honest!*/
    }

    /* Only legal colon usage patterns are */
    /* :keyword pkg:sym pkg::sym sym       */
    for (i = 0;   i < len;   b=c, ++i) {
	/* Note that we deliberately do -not- do  */
	/* & 0xFF stripping of the QUOTED bit,    */
	/* because we want xxx|:|yyy to parse as  */
	/* a single symbol not as pkg:key syntax: */
        c = OBJ_TO_INT( loc[i] );
	if      (c == ':') {

	    if (!colons)   first_colon = i;

	    if ((colons && b != ':')	/* x:y:z is no good */
	    ||  (colons && i==1)	/* ::x   is no good */
	/*  ||  (i == len-1)		/* x:    is no good */
	    ||  (colons > 1)		/* x:::y is no good */
	    ){
		MUQ_WARN("Only unquoted colon uses are :key pkg:sym pkg::sym");
	    }
	    ++colons;
        }
    }

    /* Special hack allowing 'on:' and 'else:'.     */
    /* CommonLisp doesn't define any colon-terminal */
    /* symbols, so this hack is compatible with it  */
    /* even though not part of it:                  */
    if (first_colon == len-1)   first_colon = -1;

    return first_colon;
}

   /*********************************************************************/
   /*-  job_makesym_fetchseg -- copy chars from stack to asciz buffer	*/
   /*********************************************************************/

static
void
job_makesym_fetchseg(
    Vm_Uch* buf,
    Vm_Obj* loc,
    Vm_Int  len
){
    while (len --> 0) {
	Vm_Obj o = *loc++;
	if (OBJ_IS_INT(o)) {
	    *buf++ = OBJ_TO_INT(o) & 0xFF;
	} else if (OBJ_IS_CHAR(o)) {
	    *buf++ = OBJ_TO_CHAR(o) & 0xFF;
	} else {
	    *buf++ = 0;
	}
    }
    *buf = '\0';
}

 /***********************************************************************/
 /*-    job_P_Read_Lisp_Chars --					*/
 /***********************************************************************/

#undef  STATE_INITAL     
#undef  STATE_EVEN       
#undef  STATE_ODD        
#undef  STATE_EVEN_ESCAPE
#undef  STATE_ODD_ESCAPE 
#undef  STATE_MACRO      
#undef  STATE_SYMBOL
#undef  STATE_POTNUM     
#undef  STATE_EOF
#undef  STATE_DOT

#define STATE_INITIAL       OBJ_FROM_INT(1)
#define STATE_EVEN          OBJ_FROM_INT(2)
#define STATE_ODD           OBJ_FROM_INT(3)
#define STATE_EVEN_ESCAPE   OBJ_FROM_INT(4)
#define STATE_ODD_ESCAPE    OBJ_FROM_INT(5)
#define STATE_MACRO         OBJ_FROM_INT(6)
#define STATE_SYMBOL        OBJ_FROM_INT(7)
#define STATE_POTNUM        OBJ_FROM_INT(8)
#define STATE_EOF           OBJ_FROM_INT(9)
#define STATE_DOT           OBJ_FROM_INT(10)
/* STATE_RIGHT_PAREN == 11 is used at the muf level only. */
#define STATE_WHITESPACE    OBJ_FROM_INT(12)

  /**********************************************************************/
  /*-   job_potnum -- TRUE iff buffer is a CommoNlisp "potential number"*/
  /**********************************************************************/

static
Vm_Int
job_potnum(
    Vm_Obj* loc,
    Vm_Int  len
){
    Vm_Int i;

    /* Buffer contains Vm_Obj-coded integers holding    */
    /* ascii chars in the lower 8 bits and attributes   */
    /* in the higher bits.				*/

    /* Definition following CLtL2p517 */

    /* Not a number unless it begins */
    /* with digit or + - . ^ _       */
    if (!len) return FALSE;
    i = (OBJ_TO_INT(*loc) & 0xFF);
    if (isalpha(i)) return FALSE;
    if (!isdigit(i)
    &&  i != '+'
    &&  i != '-'
    &&  i != '.'
    &&  i != '^'
    &&  i != '_'
    ){
	return FALSE;
    }

    /* Not a number if it contains two consecutive letters: */
    for (i = 1;   i < len;   ++i) {
        if (isalpha(OBJ_TO_INT(loc[i  ]) & 0xFF)
	&&  isalpha(OBJ_TO_INT(loc[i-1]) & 0xFF)
	){
	    return FALSE;
    }	}
    
    /* Not a number if it ends with a sign: */
    i = (OBJ_TO_INT(loc[len-1]) & 0xFF);
    if (i == '+' || i == '-') {
        return FALSE;
    }


    /* Not a number if any constituent was quoted: */
    for (i = 0;   i < len;   ++i) {
        if (loc[i] & OBJ_FROM_INT(QUOTED)) {
            return FALSE;

	}
    }

    /* Check for illegal constituents */
    for (i = 0;   i < len;   ++i) {
        Vm_Int c = (OBJ_TO_INT(loc[i]) & 0xFF);
        if (!isdigit(c)
        &&  !isalpha(c)
        &&  c != '+'
        &&  c != '-'
        &&  c != '/'
        &&  c != '.'
        &&  c != '^'
        &&  c != '_'
        &&  c != '_'
	){
	    return FALSE;
	}
    }

    /* Not a number unless it contains a digit: */
    for (i = 0;   i < len;   ++i) {
        if (isdigit(OBJ_TO_INT(loc[i]) & 0xFF))   return TRUE;
    }
    /* buggo, this fn ignores *read-base* stuff. */
    return FALSE;
}

  /**********************************************************************/
  /*-   job_potnum_buf -- TRUE iff buffer is a "potential number"	*/
  /**********************************************************************/

static
Vm_Int
job_potnum_buf(
    Vm_Uch* loc
){
    Vm_Int i;
    Vm_Int len = strlen(loc);

    /* Buffer contains Vm_Obj-coded integers holding    */
    /* ascii chars in the lower 8 bits and attributes   */
    /* in the higher bits.				*/

    /* Definition following CLtL2p517 */

    /* Not a number unless it begins */
    /* with digit or + - . ^ _       */
    if (!len) return FALSE;
    i = *loc;
    if (isalpha(i)) return FALSE;
    if (!isdigit(i)
    &&  i != '+'
    &&  i != '-'
    &&  i != '.'
    &&  i != '^'
    &&  i != '_'
    ){
	return FALSE;
    }

    /* Not a number if it contains two consecutive letters: */
    for (i = 1;   i < len;   ++i) {
        if (isalpha(loc[i  ])
	&&  isalpha(loc[i-1])
	){
	    return FALSE;
    }	}
    
    /* Not a number if it ends with a sign: */
    i = loc[len-1];
    if (i == '+' || i == '-') {
        return FALSE;
    }


    /* Check for illegal constituents */
    for (i = 0;   i < len;   ++i) {
        Vm_Int c = loc[i];
        if (!isdigit(c)
        &&  !isalpha(c)
        &&  c != '+'
        &&  c != '-'
        &&  c != '/'
        &&  c != '.'
        &&  c != '^'
        &&  c != '_'
        &&  c != '_'
	){
	    return FALSE;
	}
    }

    /* Not a number unless it contains a digit: */
    for (i = 0;   i < len;   ++i) {
        if (isdigit(loc[i]))   return TRUE;
    }

    /* buggo, this fn ignores *read-base* stuff. */
    return FALSE;
}

  /**********************************************************************/
  /*-   job_isdot -- TRUE iff buffer contains '.'. Err on '...' &tc	*/
  /**********************************************************************/

static
Vm_Int
job_isdot(
    Vm_Obj* loc,
    Vm_Int  len
){
    Vm_Int i;
    Vm_Int c;

    /* Not a dot if any constituent was quoted: */
    for (i = 0;   i < len;   ++i) {
	c = OBJ_TO_INT( loc[i] );
	/* By not doing & 0xFF stripping, we */
	/* check for QUOTED and non-'.' at   */
	/* the same time:                    */
	if (c != '.')   return FALSE;
    }

    if (len > 1) MUQ_WARN ("Multi-dot symbols illegal (unless |quoted|)");

    return TRUE;
}

  /**********************************************************************/
  /*-   job_convert_case -- Implement readtable_case stuff		*/
  /**********************************************************************/

static
void
job_convert_case(
    Vm_Obj* loc,
    Vm_Int  len,
    Vm_Obj  readtable_case
){
    Vm_Int i;
    switch (readtable_case) {

    case RDT_PRESERVE:
	for (i = 0;  i < len;   ++i) {
	    Vm_Int c = OBJ_TO_INT( loc[i] );
	    loc[i] = OBJ_FROM_INT(c & 0xFF);
	}
	return;

    case RDT_UPCASE:
	for (i = 0;  i < len;   ++i) {
	    Vm_Int c = OBJ_TO_INT( loc[i] );
	    if (c & QUOTED) {
		loc[i] = OBJ_FROM_INT(          c & 0xFF   );
	    } else {
		loc[i] = OBJ_FROM_INT( toupper( c & 0xFF ) );
	    }
	}
	return;

    case RDT_DOWNCASE:
	for (i = 0;  i < len;   ++i) {
	    Vm_Int c = OBJ_TO_INT( loc[i] );
	    if (c & QUOTED) {
		loc[i] = OBJ_FROM_INT(          c & 0xFF   );
	    } else {
		loc[i] = OBJ_FROM_INT( tolower( c & 0xFF ) );
	    }
	}
	return;


    case RDT_INVERT:
	for (i = 0;  i < len;   ++i) {
	    Vm_Int c = OBJ_TO_INT( loc[i] );
	    if (isupper( c & 0xFF )) {
	    	if (c & QUOTED) {
		    loc[i] = OBJ_FROM_INT(          c & 0xFF   );
		} else {
		    loc[i] = OBJ_FROM_INT( tolower( c & 0xFF ) );
		}
	    } else if (islower( c & 0xFF )) {
	    	if (c & QUOTED) {
		    loc[i] = OBJ_FROM_INT(          c & 0xFF   );
		} else {
		    loc[i] = OBJ_FROM_INT( toupper( c & 0xFF ) );
		}
	    } else {
		loc[    i] = OBJ_FROM_INT(          c & 0xFF   );
	}   }
	return;


    default:
	MUQ_FATAL("");
    }

}

  /**********************************************************************/
  /*-   job_strip_quoted -- Strip off QUOTED bit.			*/
  /**********************************************************************/

#ifdef UNUSED
static
void
job_strip_quoted(
    Vm_Obj* loc,
    Vm_Int  len
){
    Vm_Int i;

    for (i = 0;  i < len;   ++i) {
	Vm_Int c = OBJ_TO_INT( loc[i] );
	loc[i] = OBJ_FROM_INT(c & ~QUOTED);
    }
}
#endif

 /***********************************************************************/
 /*-    job_P_Potential_Number_P --					*/
 /***********************************************************************/

void
job_P_Potential_Number_P(
    void
) {
    Vm_Int blk = OBJ_TO_BLK( jS.s[ 0 ] );

    job_Guarantee_Blk_Arg(   0 );
    job_Guarantee_N_Args( blk+2 );

    if (blk < 1) MUQ_WARN ("potentialNumber needs nonempty block");

    {   Vm_Int potnum = job_potnum( jS.s-blk, blk );
	*++jS.s = OBJ_FROM_BOOL( potnum );
    }
}

 /***********************************************************************/
 /*-    job_P_Scan_Lisp_Token --					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   scan_token_for_lisp_termination_test --				*/
  /**********************************************************************/

static Vm_Obj scan_token_for_lisp_readtable;
static Vm_Int
scan_token_for_lisp_termination_test(
    Vm_Int c
) {
    /* Look up syntax info on character c: */
    Rdt_A_Slot char_info;
    char_info = RDT_P( scan_token_for_lisp_readtable )->slot[ c & 0xFF ];

    /* Different handling depending on state: */
    switch (jS.s[-1]) {

    case STATE_INITIAL:

	/* Dispatch following CLtL2p511: */
	switch (char_info.kind) {

	case RDT_ILLEGAL:
	    MUQ_WARN ("lisp reader: Illegal char x=%x", (int)c );

	case RDT_WHITESPACE:
	    jS.s[ -1 ] = STATE_WHITESPACE;
	    return FALSE;

	case RDT_TERMINATING_MACRO:
	case RDT_NONTERMINATING_MACRO:
	    /* Tell caller to call macro for us: */
	    jS.s[ -1 ] = STATE_MACRO;
	    return MSS_END_TOKEN_WITH_THIS_CHAR;


	case RDT_CONSTITUENT:
	    /* Char is part of token: */
	    jS.s[ -1 ] = STATE_EVEN;
	    return FALSE;

	case RDT_SINGLE_ESCAPE:
	    jS.s[ -1 ] = STATE_EVEN_ESCAPE;
	    return FALSE;


	case RDT_MULTIPLE_ESCAPE:
	    jS.s[ -1 ] = STATE_ODD;
	    return FALSE;


	case RDT_DISPATCHING_MACRO:
	    MUQ_WARN("I have no clue what a dispatching macro is");
	    return FALSE;

	default:
	    MUQ_FATAL("");
	}
	break;

    case STATE_WHITESPACE:
	if (char_info.kind == RDT_WHITESPACE)   return FALSE;
	return MSS_END_TOKEN_WITH_PREV_CHAR;

    case STATE_EVEN_ESCAPE:
	jS.s[ -1 ] = STATE_EVEN;
	return FALSE;

    case STATE_ODD_ESCAPE:
	jS.s[ -1 ] = STATE_ODD;
	return FALSE;

    case STATE_EVEN:
	/* Dispatch, following CLtL2p511: */
	switch (char_info.kind) {

	case RDT_NONTERMINATING_MACRO:
	case RDT_CONSTITUENT:
	    jS.s[ -1 ] = STATE_EVEN;
	    return FALSE;

	case RDT_SINGLE_ESCAPE:
	    jS.s[ -1 ] = STATE_EVEN_ESCAPE;
	    return FALSE;

	case RDT_ILLEGAL:
	    MUQ_WARN ("lisp reader: Illegal char x=%x", (int)c );
	    return FALSE;

	case RDT_WHITESPACE:
	case RDT_TERMINATING_MACRO:
	    jS.s[ -1 ] = STATE_SYMBOL;
	    return MSS_END_TOKEN_WITH_PREV_CHAR;

	case RDT_MULTIPLE_ESCAPE:
	    jS.s[ -1 ] = STATE_ODD;
	    return FALSE;

	case RDT_DISPATCHING_MACRO:
	    MUQ_WARN("I have no clue what a dispatching macro is");
	    return FALSE;

	default:
	    MUQ_FATAL("");
	}
	break;

    case STATE_ODD:
	/* Dispatch, following CLtL2p511: */
	switch (char_info.kind) {

	case RDT_NONTERMINATING_MACRO:
	case RDT_TERMINATING_MACRO:
	case RDT_CONSTITUENT:
	case RDT_WHITESPACE:
	    jS.s[ -1 ] = STATE_ODD;
	    return FALSE;

	case RDT_SINGLE_ESCAPE:
	    jS.s[ -1 ] = STATE_ODD_ESCAPE;
	    return FALSE;

	case RDT_ILLEGAL:
	    MUQ_WARN ("lisp reader: Illegal char x=%x", (int)c );
	    return FALSE;

	case RDT_MULTIPLE_ESCAPE:
	    jS.s[ -1 ] = STATE_EVEN;
	    return FALSE;

	case RDT_DISPATCHING_MACRO:
	    MUQ_WARN("I have no clue what a dispatching macro is");
	    return FALSE;

	default:
	    MUQ_FATAL("");
	}
	break;

    default:
	MUQ_WARN("|scan-token-for-lisp state corrupted");
    }
    return FALSE; /* Only to quiet compilers. */
}


  /**********************************************************************/
  /*-   job_P_Scan_Lisp_Token --					*/
  /**********************************************************************/

void
job_P_Scan_Lisp_Token(
    void
) {
    Vm_Obj mss = OBJ_FROM_INT(0);	/* Only to quiet compilers. */
    Vm_Int blk = OBJ_TO_BLK( jS.s[  0 ] );

    job_Guarantee_Blk_Arg( 0 );
    /* If called directly by the user,    */
    /* we have just a block containing    */
    /* the mss.  If we're being restarted */
    /* we have the stack in return format.*/
    if (blk == 1) {

        mss =            jS.s[ -1 ]  ;
        job_Guarantee_Mss_Arg( -1 );
	job_Guarantee_Headroom( 4 );
	jS.s += 4;
	jS.s[ -4 ] = OBJ_FROM_INT(0);
	jS.s[ -3 ] = OBJ_FROM_INT(0);
	jS.s[ -2 ] = OBJ_FROM_INT(0);
	jS.s[ -1 ] = STATE_INITIAL;
	jS.s[  0 ] = OBJ_FROM_BLK(5);

    } else if (blk == 5) {
        mss =             jS.s[ -5 ]  ;
        job_Guarantee_Mss_Arg( -5 );
        job_Guarantee_Int_Arg( -4 );
        job_Guarantee_Int_Arg( -3 );
        job_Guarantee_Int_Arg( -2 );
        job_Guarantee_Int_Arg( -1 );
    } else {
	MUQ_WARN("scan-token-for-lisp takes one arg");
    }

    scan_token_for_lisp_readtable = JOB_P( jS.job )->readtable;

    mss = job_Will_Read_Message_Stream( mss );


    {   Vm_Uch buf[MSS_MAX_TOKEN_STRING];
	Vm_Int byteloc = 0;
	Vm_Int lineloc = 0;

	Vm_Int chars_read;
	chars_read = mss_Scan_Token(
	    &byteloc,	/* Byte offset of first returned char in stream.*/
	    &lineloc,	/* Line offset of first returned char in stream.*/
	    buf,	/* Buffer in which we return chars.		*/
	    MSS_MAX_TOKEN_STRING,/* Maximum number of chars to return.	*/
	    mss,	/* Message stream to read.			*/
	    scan_token_for_lisp_termination_test  /* Termination cond.  */
	);

	jS.s[ -4 ] = OBJ_FROM_INT(  byteloc            );
	jS.s[ -3 ] = OBJ_FROM_INT(  byteloc+chars_read );
	jS.s[ -2 ] = OBJ_FROM_INT(  lineloc            );
    }
}

  /**********************************************************************/
 /*-    job_P_Classify_Lisp_Token --					*/
  /**********************************************************************/

void
job_P_Classify_Lisp_Token(
    void
) {
    Vm_Obj rdt = JOB_P( jS.job )->readtable;
    Rdt_A_Slot char_info;
    Vm_Obj state;
    Vm_Int cat;
    Vm_Int rat;
    Vm_Int c;
    Vm_Int i;
    Vm_Int blk = OBJ_TO_BLK( jS.s[ 0 ] );
    Rdt_P r = RDT_P(rdt);
    job_Guarantee_Blk_Arg( 0 );

    for (i = 1;   i <= blk;   ++i) {
	if (!OBJ_IS_CHAR( jS.s[ -i ] )) {
	    MUQ_WARN ("classifyLispToken takes only chars as args");
	}
    }

    /* It is a bit of a shame to basically   */
    /* have to run this algorithm twice on   */
    /* each token, once to scan it and once  */
    /* to classify it, but this arrangment   */
    /* fits the general scan-token-* pattern */
    state = STATE_INITIAL;
    for (cat = rat = -blk;   rat < 0;  ) {

	/* Different handling depending on state: */
	switch (state) {

	case STATE_INITIAL:
	    /* Read one char: */
	    c = OBJ_TO_CHAR( jS.s[ rat++ ] );
	    char_info = r->slot[ c & 0xFF ];

	    /* Dispatch, following CLtL2p511: */
	    switch (char_info.kind) {

	    case RDT_ILLEGAL:
		MUQ_WARN ("classifyLispToken: Illegal char x=%x", (int)c );

	    case RDT_WHITESPACE:
		continue;

	    case RDT_TERMINATING_MACRO:
	    case RDT_NONTERMINATING_MACRO:
		/* We shouldn't be called on macro chars: */
		MUQ_WARN ("classifyLispToken: macro char x=%x", (int)c );

	    case RDT_CONSTITUENT:
		/* Add val to token: */
   	        jS.s[ cat++ ] = OBJ_FROM_INT( c );
		state = STATE_EVEN;
		continue;


	    case RDT_SINGLE_ESCAPE:
		state = STATE_EVEN_ESCAPE;
		continue;


	    case RDT_MULTIPLE_ESCAPE:
		state = STATE_ODD;
		continue;

	    case RDT_DISPATCHING_MACRO:
		MUQ_WARN("classifyLispToken: dispatching macro char x=%x",(int)c);

	    default:
		MUQ_FATAL("");
	    }
	    break;

	case STATE_EVEN_ESCAPE:
	    /* Read one char: */
	    c = OBJ_TO_CHAR( jS.s[ rat++ ] );
   	    jS.s[ cat++ ] = OBJ_FROM_INT( c | QUOTED );
	    state = STATE_EVEN;
	    continue;

	case STATE_ODD_ESCAPE:
	    /* Read one char: */
	    c = OBJ_TO_CHAR( jS.s[ rat++ ] );
   	    jS.s[ cat++ ] = OBJ_FROM_INT( c | QUOTED );
	    state = STATE_ODD;
	    continue;

	case STATE_EVEN:
	    /* Read one char: */
	    c = OBJ_TO_CHAR( jS.s[ rat++ ] );
	    char_info = r->slot[ c & 0xFF ];

	    /* Dispatch, following CLtL2p511: */
	    switch (char_info.kind) {

	    case RDT_NONTERMINATING_MACRO:
	    case RDT_CONSTITUENT:
   	        jS.s[ cat++ ] = OBJ_FROM_INT( c );
		state = STATE_EVEN;
		continue;

	    case RDT_SINGLE_ESCAPE:
		state = STATE_EVEN_ESCAPE;
		continue;


	    case RDT_ILLEGAL:
		MUQ_WARN ("classifyLispToken: Illegal char x=%x", (int)c );
		continue;

	    case RDT_WHITESPACE:
		MUQ_WARN ("classifyLispToken: whitespace char x=%x", (int)c );
	    case RDT_TERMINATING_MACRO:
		MUQ_WARN ("classifyLispToken: macro char x=%x", (int)c );


	    case RDT_MULTIPLE_ESCAPE:
		state = STATE_ODD;
		continue;


	    case RDT_DISPATCHING_MACRO:
		MUQ_WARN("I have no clue what a dispatching macro is");
		continue;

	    default:
		MUQ_FATAL("");
	    }
	    break;

	case STATE_ODD:
	    /* Read one char: */
	    c = OBJ_TO_CHAR( jS.s[ rat++ ] );
	    char_info = r->slot[ c & 0xFF ];

	    /* Dispatch, following CLtL2p511: */
	    switch (char_info.kind) {

	    case RDT_NONTERMINATING_MACRO:
	    case RDT_TERMINATING_MACRO:
	    case RDT_CONSTITUENT:
	    case RDT_WHITESPACE:
   	        jS.s[ cat++ ] = OBJ_FROM_INT( c | QUOTED );
		state = STATE_ODD;
		continue;

	    case RDT_SINGLE_ESCAPE:
		state = STATE_ODD_ESCAPE;
		continue;


	    case RDT_ILLEGAL:
		MUQ_WARN ("classifyLispToken: Illegal char x=%x", (int)c );


	    case RDT_MULTIPLE_ESCAPE:
		state = STATE_EVEN;
		continue;


	    case RDT_DISPATCHING_MACRO:
		MUQ_WARN("I have no clue what a dispatching macro is");

	    default:
		MUQ_FATAL("");
	    }
	    break;
	default:
	    MUQ_WARN("|classifyLispToken state corrupted");
	}
    }

    /* Re-adjust stack, since we may have */
    /* removed various quotes from token: */
    i = rat-cat;
    jS.s -= i;
    blk  -= i;
    *jS.s = OBJ_FROM_BLK( blk );

    /* Push on stack a value classifying token: */

    /* Is it all dots? */
    if (job_isdot( jS.s-blk, blk )) {
	*++jS.s = STATE_DOT;
	return;
    }

    /* Is it a potential number? */
    if (job_potnum( jS.s-blk, blk )) {
	*++jS.s = STATE_POTNUM;
	return;
    }

    /* Must be a symbol, then.*/
    /* Do any case conversion */
    /* requested and return:  */
    job_convert_case(
	jS.s-blk,
	blk,
	r->readtable_case
    );
/*  job_strip_replaceable( jS.s-blk, r.blk ); */
    *++jS.s = STATE_SYMBOL;
}

#undef  QUOTED
#undef  STATE_INITIAL     
#undef  STATE_EVEN       
#undef  STATE_ODD        
#undef  STATE_EVEN_ESCAPE
#undef  STATE_ODD_ESCAPE 
#undef  STATE_MACRO      
#undef  STATE_SYMBOL
#undef  STATE_POTNUM     
#undef  STATE_EOF


  /**********************************************************************/
  /*-    job_P_Get_Macro_Character --					*/
  /**********************************************************************/

void
job_P_Get_Macro_Character(
    void
) {
    Vm_Int blk    = OBJ_TO_BLK( jS.s[ 0 ] );
    Vm_Obj rdt    = 0; /* Initialized just to quiet compilers. */
    Vm_Obj chr    = 0; /* Initialized just to quiet compilers. */

    job_Guarantee_Blk_Arg(  0 );

    job_Guarantee_N_Args( blk+2 );
    
    switch (blk) {
    case 2:
	rdt = jS.s[ -1 ];
	chr = jS.s[ -2 ];
	if (rdt == OBJ_NIL)   rdt = JOB_P( jS.job )->readtable;
	break;
    case 1:
	rdt = JOB_P( jS.job )->readtable;
	chr = jS.s[ -1 ];
	break;	
    default:
	MUQ_WARN ("get-macro-char takes 1-2 args");
    }
    if (!OBJ_IS_CHAR(chr)) MUQ_WARN ("get-macro-char 1st arg not char");
    if (!OBJ_IS_OBJ(rdt) || !OBJ_IS_CLASS_RDT(rdt)) {
	MUQ_WARN ("get-macro-char 2nd arg not readtable");
    }
    {   Rdt_A_Slot s = RDT_P(rdt)->slot[ OBJ_TO_CHAR(chr) & 0xFF ];
	jS.s   -= blk+1;
	*++jS.s = s.val;
	*++jS.s = (s.kind == RDT_NONTERMINATING_MACRO) ? OBJ_T : OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 2 );
    }	
}
    

  /**********************************************************************/
 /*-    job_P_Set_Macro_Character --					*/
  /**********************************************************************/

void
job_P_Set_Macro_Character(
    void
) {
    Vm_Int blk    = OBJ_TO_BLK( jS.s[ 0 ] );

    Vm_Obj rdt = OBJ_NIL;
    Vm_Obj chr = 0; /* Initialized just to quiet compilers. */
    Vm_Obj cfn = 0; /* Initialized just to quiet compilers. */
    Vm_Obj tag = OBJ_NIL;

    job_Guarantee_Blk_Arg(  0 );

    job_Guarantee_N_Args( blk+2 );
    
    switch (blk) {
    case 4:
	chr = jS.s[ -4 ];
	cfn = jS.s[ -3 ];
	tag = jS.s[ -2 ];
	rdt = jS.s[ -1 ];
	break;
    case 3:
	chr = jS.s[ -3 ];
	cfn = jS.s[ -2 ];
	tag = jS.s[ -1 ];
	break;
    case 2:
	chr = jS.s[ -2 ];
	cfn = jS.s[ -1 ];
	break;
    default:
	MUQ_WARN ("set-macro-char takes 2-4 args");
    }
    if (!OBJ_IS_CHAR(chr)) MUQ_WARN ("set-macro-char 1st arg not char");
    if (!OBJ_IS_CFN(cfn) && !OBJ_IS_INT(cfn)) {
	MUQ_WARN ("get-macro-char bad chr arg");
    }
    if (rdt == OBJ_NIL) rdt = JOB_P( jS.job )->readtable;
    if (!OBJ_IS_OBJ(rdt) || !OBJ_IS_CLASS_RDT(rdt)) {
	MUQ_WARN ("get-macro-char 4th arg not readtable");
    }
    if (tag == OBJ_NIL)  tag = RDT_TERMINATING_MACRO;
    else                 tag = RDT_NONTERMINATING_MACRO;
    {   Rdt_Slot s = &RDT_P(rdt)->slot[ OBJ_TO_CHAR( chr ) & 0xFF ];
	s->kind = tag;
	s->val  = cfn;
	vm_Dirty(rdt);
    }
    jS.s    -= blk+1;
    *++jS.s  = OBJ_T;
    *++jS.s  = OBJ_FROM_BLK( 1 );
}
    

 /***********************************************************************/
 /*-    job_P_Next_Muc_Token_In_String --				*/
 /***********************************************************************/

#undef AUTO
#undef BREAK
#undef CASE
#undef CHAR
#undef CONST
#undef CONTINUE
#undef DEFAULT
#undef DO
#undef DOUBLE
#undef ELSE
#undef ENUM
#undef EXTERN
#undef FLOAT
#undef FOR
#undef GOTO
#undef IF
#undef INT
#undef LONG
#undef REGISTER
#undef RETURN
#undef SHORT
#undef SIGNED
#undef SIZEOF
#undef STATIC
#undef STRUCT
#undef SWITCH
#undef TYPEDEF
#undef UNION
#undef UNSIGNED
#undef VOID
#undef VOLATILE
#undef WHILE
#undef ID
#undef STR_CNST
#undef FLT_CNST
#undef INT_CNST
#undef CHR_CNST
#undef OCT_CNST
#undef HEX_CNST
#undef ADD_SET
#undef AMPAMP
#undef AMP_SET
#undef BARBAR
#undef BAR_SET
#undef DASHMORE
#undef DOTDOTDOT
#undef EQUAL
#undef HAT_SET
#undef LESSLESS
#undef LESSLESS_SET
#undef LESS_OR_EQ
#undef MOREMORE
#undef MOREMORE_SET
#undef MORE_OR_EQ
#undef NOT_EQ
#undef PCNT_SET
#undef PLUSPLUS
#undef SLASH_SET
#undef STARSTAR
#undef STAR_SET
#undef SUBSUB
#undef SUB_SET
#undef OBJ

#define AUTO         257
#define BREAK        258
#define CASE         259
#define CHAR         260
#define CONST        261
#define CONTINUE     262
#define DEFAULT      263
#define DO           264
#define DOUBLE       265
#define ELSE         266
#define ENUM         267
#define EXTERN       268
#define FLOAT        269
#define FOR          270
#define GOTO         271
#define IF           272
#define INT          273
#define LONG         274
#define REGISTER     275
#define RETURN       275
#define SHORT        276
#define SIGNED       277
#define SIZEOF       278
#define STATIC       279
#define STRUCT       280
#define SWITCH       281
#define TYPEDEF      282
#define UNION        283
#define UNSIGNED     284
#define VOID         285
#define VOLATILE     286
#define WHILE        287
#define ID           289
#define STR_CNST     290
#define FLT_CNST     291
#define INT_CNST     292
#define CHR_CNST     293
#define OCT_CNST     294
#define HEX_CNST     295
#define ADD_SET      296
#define AMPAMP       297
#define AMP_SET      298
#define BARBAR       299
#define BAR_SET      300
#define DASHMORE     301
#define DOTDOTDOT    302
#define EQUAL        303
#define TILDA_SET    304
#define HAT_SET	     305
#define LESSLESS     306
#define LESSLESS_SET 307
#define LESS_OR_EQ   308
#define MOREMORE     309

#define MOREMORE_SET 310
#define MORE_OR_EQ   311
#define MORE_OR_LESS 312
#define NOT_EQ       313

#define PCNT_SET     314
#define PLUSPLUS     315
#define PLUSSLASH    316
#define SLASH_SET    317
#define STARSLASH    318
#define STARSTAR     319

#define STAR_SET     320
#define SUBSUB       321
#define SUB_SET      322

#define DOLLAR_ID    340
#define REGEX        341	/* Context-sensitive lexer hack. */

#define AFTER        350
#define BIT          351
#define BYTE         352
#define CILK         353
#define CLASS        354
#define DELETE       355
#define EQ           356
#define GE           357
#define GENERIC      358
#define GT           359
#define INLET        360
#define LE           361
#define LT           362
#define MACRO        363
#define METHOD       364
#define NE           365
#define NORETURN     366
#define OBJ          367
#define PRIVATE      368
#define PUBLIC       369
#define SPAWN        370
#define SYNC         371
#define TRY          372
#define WITH         373
#define ENDIF        374
#define WHEN         375


/* NB: CILK, SPAWN, SYNC and INLET are from Cilk, which I currently */
/* think is a very pretty parallel extension to C.  For docs see    */
/* supertech.lcs.mit.edu/cilk/home/intro.html			    */

/* REGEX is returned by the lexer when it sees a '/' immediately    */
/* after a '~=' assignment: This signals a regular expression. The  */
/* lexer independently scans, compiles and returns the regex.       */

static Vm_Uch* jgetc_beg;
static Vm_Uch* jgetc_ptr;
static Vm_Uch* jgetc_lim;

static int
jgetc(
    void
) {
    if (++jgetc_ptr > jgetc_lim)   return 0;
    return jgetc_ptr[-1];
}
static void
jungetc(
    void
) {
    --jgetc_ptr;
}

static int
lex_number(
   int c
) {
    /* Check for "0" or "0x" prefix: */
    if (c == '0') {

        c = jgetc(); 

	if (c == 'x') {
            c = jgetc(); 

	    /* Eat and return hex number: */
            for (;;) {
	        if (!isxdigit(c)) {
		    jungetc();
		    return HEX_CNST;
		}
                c = jgetc(); 
	    }
	}

	/* Eat and return octal number: */
	if (c != '.') {
	    for (;;) {
		if (!isdigit(c) || c=='8' || c=='9') {
		    jungetc();
		    return OCT_CNST;
		}
		c = jgetc(); 
	    }
	}
    }

    /* Eat digits: */
    for (;;) {
	if (!isdigit(c)) break;
        c = jgetc(); 
    }

    /* Check for end of string: */
    if (!c) {
        jungetc();
        return INT_CNST;
    }

    if (c != 'e'
    &&  c != 'E'
    ){
	/* Check for decimal point: */
	if (c != '.') {
	    jungetc();
	    return INT_CNST;
	}

	/* Eat fractional part: */
	for (;;) {
	    c = jgetc(); 
	    if (!isdigit(c)) break;
	}

	/* Done unless we have 'e' or 'E' signalling exponent: */
	if (c != 'e'
	&&  c != 'E'
	){
	    jungetc();
	    return FLT_CNST;
	}
    }

    /* Eat 'e'/'E': */
    c = jgetc(); 

    /* Eat any sign on exponent: */
    if (c == '+'
    ||  c == '-'
    ){
	c = jgetc(); 
    }

    /* Eat exponent proper: */
    for (;;) {
	if (!isdigit(c)) break;
	c = jgetc(); 
    }

    jungetc();
    return FLT_CNST;

    /* Possible improvement: Might want to allow underscores */
    /* for readability.  But we'd have to remember to strip  */
    /* them out before using standard C atoi() &tc on them.  */
}
static int
lex_identifier(
   int c
) {
    int  result = ID;
    char buf[4096];
    char*t = buf;
    *t++ = c;
    /* Do we want to consider ':' and/or '$' to be alphabetic? */
    do {
        *t++ = c = jgetc(); 
	if ((t-buf) > 4000)  break;
    } while (isalnum(c) || c=='_' || c=='?');
    jungetc();
    *--t = '\0';

    /* Check for special keyword values: */
    switch (buf[0]) {

    case 'a':
        if (STRCMP(buf, == ,"auto"    ))     return AUTO;
        if (STRCMP(buf, == ,"after"   ))     return AFTER;
	break;

    case 'b':
	if (STRCMP(buf, == ,"bit"     ))     return BIT;
	if (STRCMP(buf, == ,"break"   ))     return BREAK;
	if (STRCMP(buf, == ,"byte"    ))     return BYTE;
	break;

    case 'c':
	if (STRCMP(buf, == ,"case"    ))     return CASE;
	if (STRCMP(buf, == ,"char"    ))     return CHAR;
	if (STRCMP(buf, == ,"cilk"    ))     return CILK;
	if (STRCMP(buf, == ,"class"   ))     return CLASS;
	if (STRCMP(buf, == ,"const"   ))     return CONST;
	if (STRCMP(buf, == ,"continue"))     return CONTINUE;
	break;

    case 'd':
	if (STRCMP(buf, == ,"default" ))     return DEFAULT;
	if (STRCMP(buf, == ,"delete"  ))     return DELETE;
	if (STRCMP(buf, == ,"do"      ))     return DO;
	if (STRCMP(buf, == ,"double"  ))     return DOUBLE;
	break;

    case 'e':
	if (STRCMP(buf, == ,"else"    ))     return ELSE;
	if (STRCMP(buf, == ,"endif"   ))     return ENDIF;
	if (STRCMP(buf, == ,"enum"    ))     return ENUM;
	if (STRCMP(buf, == ,"eq"      ))     return EQ;
	if (STRCMP(buf, == ,"extern"  ))     return EXTERN;
	break;

    case 'f':
	if (STRCMP(buf, == ,"float"   ))     return FLOAT;
	if (STRCMP(buf, == ,"for"     ))     return FOR;
	break;

    case 'g':
	if (STRCMP(buf, == ,"goto"    ))     return GOTO;
	if (STRCMP(buf, == ,"ge"      ))     return GE;
	if (STRCMP(buf, == ,"generic" ))     return GE;
	if (STRCMP(buf, == ,"gt"      ))     return GT;
	break;

    case 'i':
	if (STRCMP(buf, == ,"if"      ))     return IF;
	if (STRCMP(buf, == ,"inlet"   ))     return INLET;
	if (STRCMP(buf, == ,"int"     ))     return INT;
	break;

    case 'l':
	if (STRCMP(buf, == ,"long"    ))     return LONG;
	if (STRCMP(buf, == ,"le"      ))     return LE;
	if (STRCMP(buf, == ,"lt"      ))     return LT;
	break;

    case 'm':
	if (STRCMP(buf, == ,"macro"   ))     return MACRO;
	if (STRCMP(buf, == ,"method"  ))     return METHOD;
	break;

    case 'n':
	if (STRCMP(buf, == ,"ne"      ))     return NE;
	if (STRCMP(buf, == ,"noreturn"))     return NORETURN;
	break;

    case 'o':
	if (STRCMP(buf, == ,"obj"     ))     return OBJ;
	break;

    case 'p':
	if (STRCMP(buf, == ,"private" ))     return PRIVATE;
	if (STRCMP(buf, == ,"public"  ))     return PUBLIC;
	break;

    case 'r':
	if (STRCMP(buf, == ,"register"))     return REGISTER;
	if (STRCMP(buf, == ,"return"  ))     return RETURN;
	break;

    case 's':
	if (STRCMP(buf, == ,"short"   ))     return SHORT;
	if (STRCMP(buf, == ,"signed"  ))     return SIGNED;
	if (STRCMP(buf, == ,"sizeof"  ))     return SIZEOF;
	if (STRCMP(buf, == ,"spawn"   ))     return SPAWN;
	if (STRCMP(buf, == ,"static"  ))     return STATIC;
	if (STRCMP(buf, == ,"struct"  ))     return STRUCT;
	if (STRCMP(buf, == ,"switch"  ))     return SWITCH;
	if (STRCMP(buf, == ,"sync"    ))     return SYNC;
	break;

    case 't':
	if (STRCMP(buf, == ,"try"     ))     return TRY;
	if (STRCMP(buf, == ,"typedef" ))     return TYPEDEF;
	break;

    case 'u':
	if (STRCMP(buf, == ,"union"   ))     return UNION;
	if (STRCMP(buf, == ,"unsigned"))     return UNSIGNED;
	break;

    case 'v':
	if (STRCMP(buf, == ,"void"    ))     return VOID;
	if (STRCMP(buf, == ,"volatile"))     return VOLATILE;
	break;

    case 'w':
	if (STRCMP(buf, == ,"when"    ))     return WHEN;
	if (STRCMP(buf, == ,"while"   ))     return WHILE;
	if (STRCMP(buf, == ,"with"    ))     return WITH;
	break;
    }

    return result;
}
static int
lex_string_constant(
   int c
) {
    int last;
    for (;;) {
        last = c;
        c = jgetc(); 
	if (c == '"' && last != '\\')   return STR_CNST;
	if (!c) MUQ_WARN("Unclosed MUC string constant");
    }
}

static int
lex_char_constant(
   int c
) {
    /* Handle 'a': */
    if (jgetc_ptr[0] != '\\'
    &&  jgetc_ptr[1] == '\''
    ){
	jgetc_ptr += 2;
	return CHR_CNST;
    }

    /* Handle '\a': */
    if (jgetc_ptr[0] == '\\'
    &&  jgetc_ptr[2] == '\''
    ){
	jgetc_ptr += 3;
	return CHR_CNST;
    }

    /* Unlike C, we allow standalone single quotes: */
    return '\'';
}

/* Foward declaration for recursive calls: */
static int job_next_muc_token_in_string_yylex(int lastyp);

static int
lex_c_comment(
   int c,
   int lastyp
) {
    /* Eat rest of C-style comment and return next token: */
    int last;
    for (;;) {
        last = c;
        c = jgetc(); 
/*printf("lex_c_comment: last c=%c c d=%c x=%x\n",last,c,c);*/
	if (last == '*' && c == '/')   return job_next_muc_token_in_string_yylex(lastyp);
	if (!c) MUQ_WARN("Unclosed MUC C-style comment");
    }
}

static int
lex_cpp_comment(
   int c,
   int lastyp
) {
    /* Eat rest of C++ style // comment and return next token: */
    for (;;) {
        c = jgetc(); 
	if (!c || c == '\n')   return job_next_muc_token_in_string_yylex(lastyp);
    }
}

static int
job_next_muc_token_in_string_yylex(
    int lastyp
) {
    int c = jgetc();

/*printf("job_next_muc_token_in_string_yylex: c c='%c' x=%x\n",c,c);*/
    /* Skip leading whitespace: */
    while (c && isspace(c)) c = jgetc();
/*printf("job_next_muc_token_in_string_yylex: postwhitespace c c='%c' x=%x\n",c,c);*/

    /* Remember actual start of token: */
    jgetc_beg = jgetc_ptr-1;

    if (isalpha(c))  return lex_identifier(c);
    if (isdigit(c))  return lex_number(c);

    switch (c) {

    case '_':
	return lex_identifier(c);

    case '$':
	return lex_identifier(c);

    case '-':
        switch (c = jgetc()) {
	case '>':   return DASHMORE;
	case '-':   return SUBSUB;
	case '=':   return SUB_SET;
	default:
	    jungetc();
	    return '-';
	}

    case '+':
        switch (c = jgetc()) {
	case '+':   return PLUSPLUS;
	case '=':   return ADD_SET;
	case '/':   return PLUSSLASH;
	default:
	    jungetc();
	    return '+';
	}

    case '<':
        switch (c = jgetc()) {
	case '=':  return LESS_OR_EQ;
	case '<':
            switch (c = jgetc()) {
	    case '=':   return LESSLESS_SET;
	    default:
	        jungetc();
	        return LESSLESS;
	    }
	default:
	    jungetc();
	    return '<';
	}

    case '>':
        switch (c = jgetc()) {
	case '=':  return MORE_OR_EQ;
	case '<':  return MORE_OR_LESS;
	case '>':
            switch (c = jgetc()) {
	    case '=':   return MOREMORE_SET;
	    default:
	        jungetc();
	        return MOREMORE;
	    }
	default:
	    jungetc();
	    return '>';
	}

    case '=':
        switch (c = jgetc()) {
	case '=':   return EQUAL;
	default:
	    jungetc();
	    return '=';
	}

    case '~':
        switch (c = jgetc()) {
	case '=':   return TILDA_SET;
	default:
	    jungetc();
	    return '~';
	}

    case '!':
        switch (c = jgetc()) {
	case '=':   return NOT_EQ;
	default:
	    jungetc();
	    return '!';
	}

    case '&':
        switch (c = jgetc()) {
	case '=':   return AMP_SET;
	case '&':   return AMPAMP;
	default:
	    jungetc();
	    return '&';
	}

    case '|':
        switch (c = jgetc()) {
	case '=':   return BAR_SET;
	case '|':   return BARBAR;
	default:
	    jungetc();
	    return '|';
	}

    case '*':
        switch (c = jgetc()) {
	case '=':   return STAR_SET;
	case '*':   return STARSTAR;
	case '/':   return STARSLASH;
	default:
	    jungetc();
	    return '*';
	}

    case '/':
        switch (c = jgetc()) {
	case '=':   return SLASH_SET;
	case '/':   return lex_cpp_comment('/',lastyp);
	case '*':   return lex_c_comment('*',lastyp);
	default:
	    if (lastyp == TILDA_SET) {
	        jungetc();
	        jungetc();
		return REGEX;
	    }
	    jungetc();
	    return '/';
	}

#ifdef OLD
    case '#':
        /* Maybe someday we support preprocessing */
        /* or token pasting in MUC, but for now   */
        /* a hash is a comment to end of line:    */
	return lex_cpp_comment('#');
	/* Later: Decided I'd rather have '#vec'  */
	/* as syntax for length of a vector, than */
	/* have a third style of comment in MUC.  */
#endif

    case '^':
        switch (c = jgetc()) {
	case '=':   return HAT_SET;
	default:
	    jungetc();
	    return '^';
	}

    case '%':
        switch (c = jgetc()) {
	case '=':   return PCNT_SET;
	default:
	    jungetc();
	    return '%';
	}

    case '.':
        if (isdigit(jgetc())) {
            jungetc();
	    return lex_number('.');
	}
        jungetc();
        return '.';

    case '"':
	return lex_string_constant('"');

    case '\'':
	return lex_char_constant('\'');

    default:
	return c;
    }
}

void
job_P_Next_Muc_Token_In_String(
    void
){
    Vm_Uch*t;
    Vm_Uch buf[10];
    Vm_Obj stg    =             jS.s[ -2 ];
    Vm_Unt offset = OBJ_TO_UNT( jS.s[ -1 ] );
    int    lastyp = OBJ_TO_UNT( jS.s[  0 ] );
    Vm_Int len;

    /* Input: string and offset, type of last token           */
    /* Output: token starting offset, ending offset and type. */
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Stg_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    len  = stg_Len( stg );
    if (OBJ_TYPE(stg) == OBJ_TYPE_BYTN) {
	t = &STG_P(stg)->byte[0];
    } else {
	if (len != stg_Get_Bytes( buf, len, stg, 0 )) {
	    MUQ_WARN ("nextMucTokenInString: internal error");
	}
	t = buf;
    }
#ifdef NOISY
{int i;
printf("job_P_Next_Muc_Token_In_String: offset d=%lld len d=%lld\n",offset,len);
printf("'");
for (i=0;i<offset;++i)printf("%c",t[i]);
printf("'\n");
printf("'");
for (;i<len;++i)printf("%c",t[i]);
printf("'\n");
}
#endif
    /* Special end-of-string token: */
    if (offset == len) {
	jS.s[-2] = OBJ_FROM_INT(0);
	jS.s[-1] = OBJ_FROM_INT(len);
	jS.s[ 0] = OBJ_FROM_INT(len);
	return;
    }
    if (offset >= len) {
	MUQ_WARN("nextMucTokenInString: start offset must be within string");
    }

    jgetc_ptr = t+offset;
    jgetc_lim = t+len;

    {   Vm_Int token_type;
	Vm_Int token_start;
	Vm_Int token_end;

        token_type  = job_next_muc_token_in_string_yylex(lastyp);

	if (jgetc_ptr > jgetc_lim) {
	    jgetc_ptr = jgetc_lim;
	}

	token_start = jgetc_beg - t;
	token_end   = jgetc_ptr - t;

	jS.s[-2] = OBJ_FROM_INT(token_type);
	jS.s[-1] = OBJ_FROM_INT(token_start);
	jS.s[ 0] = OBJ_FROM_INT(token_end);
    }
}

 /***********************************************************************/
 /*-    job_P_Muc_Token_Value_In_String --				*/
 /***********************************************************************/

void
job_P_Muc_Token_Value_In_String(
    void
) {
    Vm_Uch buf[MAX_STRING];

    /* Input: string and offset                               */
    /* Output: token starting offset, ending offset and type. */
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Stg_Arg( -3 );	/* string	*/
    job_Guarantee_Int_Arg( -2 );	/* beg offset	*/
    job_Guarantee_Int_Arg( -1 );	/* end offset	*/
    job_Guarantee_Int_Arg(  0 );	/* token type	*/
    {   Vm_Obj stg =              jS.s[ -3 ]  ;
	Vm_Unt beg = OBJ_TO_UNT(  jS.s[ -2 ] );
	Vm_Unt end = OBJ_TO_UNT(  jS.s[ -1 ] );
	Vm_Unt tok = OBJ_TO_UNT(  jS.s[  0 ] );
    	Vm_Unt len = stg_Len( stg );
	if (beg > len
        ||  end > len
        ||  beg > end
	){
	    MUQ_WARN("mucTokenValueInString: bad begin/end offsets %d %d %d",(int)beg,(int)end,(int)len);
        }
	if (end-beg >= MAX_STRING-1) MUQ_WARN("mucTokenValueInString: max token length exceeded");
	if (end-beg != stg_Get_Bytes( buf, end-beg, stg, beg )) {
	    MUQ_WARN ("mucTokenValueInString: internal error");
	}
	buf[end-beg] = '\0';
        jS.s -= 3;
	switch ((int)tok) {
	case ID:
	    *jS.s = stg_From_Asciz(buf);
	    return;
	case STR_CNST:
	    /* Drop initial and final doublequotes: */
	    buf[(end-beg)-1] = '\0';
	    *jS.s = stg_From_Asciz(buf+1);
	    return;
	case FLT_CNST:
	    *jS.s = OBJ_FROM_FLOAT(strtod(buf,NULL));
	    return;
	case INT_CNST:
	    /* buggo, this won't handle bignums or even longlong: */
	    *jS.s = OBJ_FROM_INT(atoi(buf));
	    return;
	case CHR_CNST:
	    /* buggo, this won't handle \escapes: */
	    *jS.s = OBJ_FROM_CHAR(buf[1]);
	    return;
	case OCT_CNST:
	    /* buggo, this won't handle bignums or even longlong: */
	    {   int i;
		sscanf(buf,"%o",&i);
		*jS.s = OBJ_FROM_INT(i);
	    }
	    return;
	case HEX_CNST:
	    /* buggo, this won't handle bignums or even longlong: */
	    {   int i;
		sscanf(buf,"%x",&i);
		*jS.s = OBJ_FROM_INT(i);
	    }
	    return;
	default:
	    *jS.s = OBJ_FROM_INT(tok);
	    return;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Root_Collect_Garbage -- garbage collection operator.	*/
 /***********************************************************************/

void
job_P_Root_Collect_Garbage(
    void
){
    Vm_Chr buf[ 2048 ];

    job_Must_Be_Root();
    obj_Collect_Garbage();
    vm_Set_Bytes_Allocated_Since_Last_Garbage_Collection(0,0);

    sprintf(buf,
	"Recovered: %d objs (%d bytes)   Remaining: %d objs (%d bytes)\n",
	(int)obj_Objs_Recovered, (int)obj_Byts_Recovered,
	(int)obj_Objs_Remaining, (int)obj_Byts_Remaining
    );
    *++jS.s = stg_From_Asciz(buf);
}

 /***********************************************************************/
 /*-    job_P_Root_Do_Backup -- DB backup operator.			*/
 /***********************************************************************/

void
job_P_Root_Do_Backup(
    void
){
    job_Must_Be_Root();

    /* Mark instruction as complete before */
    /* saving db, otherwise we'll loop on  */
    /* it forever:			   */
    jS.pc += jS.instruction_len;
    jS.instruction_len = 0;

    obj_Do_Backup();
}

 /***********************************************************************/
 /*-    job_P_Gcd -- Greatest Common Divisor.				*/
 /***********************************************************************/
  /**********************************************************************/
  /*-    job_Gcd -- Greatest Common Divisor.				*/
  /**********************************************************************/

Vm_Int
job_Gcd(
    Vm_Int arg0,	/* Must be nonnegative.	*/
    Vm_Int arg1		/* Must be nonnegative.	*/
){
    for (;;) {
	if (arg1 == 0) return arg0;	arg0 %= arg1;
	if (arg0 == 0) return arg1;	arg1 %= arg0;
    }
}

  /**********************************************************************/
  /*-   job_P_Gcd -- Greatest Common Divisor.				*/
  /**********************************************************************/

void
job_P_Gcd(
    void
){
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    Vm_Obj result;

    job_Guarantee_N_Args(   2 );

    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { result=bnm_Bgcd(  a,b); *--jS.s=result; return; }
	else if  (OBJ_IS_INT(   b)) { result=bnm_BgcdBI(a,b); *--jS.s=result; return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { result=bnm_BgcdBI(b,a); *--jS.s=result; return; }
    }

    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );
    
    {   Vm_Int arg0 = OBJ_TO_INT( jS.s[  0 ] );
	Vm_Int arg1 = OBJ_TO_INT( jS.s[ -1 ] );

	if (arg0 < 0)   arg0 = -arg0;
	if (arg1 < 0)   arg1 = -arg1;

	result  = OBJ_FROM_INT( job_Gcd( arg0, arg1 ) );
	*--jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Lcm -- Least Common Multiple.				*/
 /***********************************************************************/
  /**********************************************************************/
  /*-    job_Lcm -- Least Common Multiple.				*/
  /**********************************************************************/

Vm_Int
job_Lcm(
    Vm_Int arg0,	/* Must be nonnegative.	*/
    Vm_Int arg1		/* Must be nonnegative.	*/
){
    /* Don't combine the following two lines, */
    /* ANSI C allows the compiler to avoid    */
    /* parens and give the wrong answer, I    */
    /* think:                                 */
    Vm_Int p = arg0 / job_Gcd( arg0, arg1 );
    return p * arg1;
}

void
job_P_Lcm(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );
    
    {   Vm_Int arg0 = OBJ_TO_INT( jS.s[  0 ] );
	Vm_Int arg1 = OBJ_TO_INT( jS.s[ -1 ] );

	if (arg0 < 0)   arg0 = -arg0;
	if (arg1 < 0)   arg1 = -arg1;

	*--jS.s = OBJ_FROM_INT( job_Lcm( arg0, arg1 ) );
    }
}

 /***********************************************************************/
 /*-    job_P_Get_Substring -- ( stg lo hi -- stg ).			*/
 /***********************************************************************/

#ifndef MAX_SUBSTRING
#define MAX_SUBSTRING 8192
#endif

void
job_P_Get_Substring(
    void
) {

    job_Guarantee_N_Args(   3 );
    job_Guarantee_Stg_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );

    {   Vm_Obj stg =             jS.s[ -2 ]  ;
        Vm_Int lo  = OBJ_TO_INT( jS.s[ -1 ] );
        Vm_Int hi  = OBJ_TO_INT( jS.s[  0 ] );
	Vm_Chr buf[ MAX_SUBSTRING ];
        Vm_Int len = stg_Len( stg );
        Vm_Int sublen = hi-lo;

	if (lo < 0  ) MUQ_WARN ("SUBSTRING lower limit too small: %d",(int)lo);
	if (lo > len) MUQ_WARN ("SUBSTRING lower limit too big: %d",(int)lo);
	if (hi > len) MUQ_WARN ("SUBSTRING upper limit too big: %d",(int)hi);
	if (hi < lo ) MUQ_WARN ("SUBSTRING limits misordered: %d,%d",(int)lo,(int)hi);
	if (sublen >= MAX_SUBSTRING) MUQ_WARN ("SUBSTRING string too big");

	if (sublen != stg_Get_Bytes( buf, sublen, stg, lo )) {
	    MUQ_WARN ("SUBSTRING: internal error");
	}

	{   Vm_Obj substring = stg_From_Buffer( buf, sublen );
	    jS.s -= 2;
	   *jS.s  = substring;
    }	}
}

 /***********************************************************************/
 /*-    job_P_Get_Substring_Block -- ( stg lo hi -- [ chars | ).	*/
 /***********************************************************************/

#ifndef MAX_SUBSTRING
#define MAX_SUBSTRING 8192
#endif

void
job_P_Get_Substring_Block(
    void
) {

    job_Guarantee_N_Args(   3 );
    job_Guarantee_Stg_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );

    {   Vm_Obj stg =             jS.s[ -2 ]  ;
        Vm_Int lo  = OBJ_TO_INT( jS.s[ -1 ] );
        Vm_Int hi  = OBJ_TO_INT( jS.s[  0 ] );
	Vm_Chr buf[ MAX_SUBSTRING ];
        Vm_Int len = stg_Len( stg );
        Vm_Int sublen = hi-lo;

	if (lo < 0  ) MUQ_WARN ("SUBSTRING[ lower limit too small: %d",(int)lo);
	if (lo > len) MUQ_WARN ("SUBSTRING[ lower limit too big: %d",(int)lo);
	if (hi > len) MUQ_WARN ("SUBSTRING[ upper limit too big: %d",(int)hi);
	if (hi < lo ) MUQ_WARN ("SUBSTRING[ limits misordered: %d,%d",(int)lo,(int)hi);
	if (sublen >= MAX_SUBSTRING) MUQ_WARN ("SUBSTRING[ string too big");
	job_Guarantee_Headroom( sublen );	
	if (sublen != stg_Get_Bytes( buf, sublen, stg, lo )) {
	    MUQ_WARN ("SUBSTRING[: internal error");
	}

	{   Vm_Int i;
	    jS.s   -= 3;
	    *++jS.s = OBJ_BLOCK_START;
	    for (i = 0;   i < sublen;   ++i) {
		*++jS.s = OBJ_FROM_CHAR( buf[ i ] );
	    }
	    *++jS.s   = OBJ_FROM_BLK(sublen);
}   }	}

 /***********************************************************************/
 /*-    job_P_Int_To_Char -- 'intChar'					*/
 /***********************************************************************/

void
job_P_Int_To_Char(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    *jS.s = OBJ_FROM_CHAR( OBJ_TO_INT( *jS.s ) );
}

 /***********************************************************************/
 /*-    job_P_Int_To_Chars2 -- 'intChars2'				*/
 /***********************************************************************/

void
job_P_Int_To_Chars2(
    void
) {
    Vm_Int  i;
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    i = OBJ_TO_INT( *jS.s );
    *  jS.s = OBJ_FROM_CHAR( (i >> 8) & 0xFF );
    *++jS.s = OBJ_FROM_CHAR(  i       & 0xFF );
}

 /***********************************************************************/
 /*-    job_P_Int_To_Chars4 -- 'intChars4'				*/
 /***********************************************************************/

void
job_P_Int_To_Chars4(
    void
) {
    Vm_Unt  i;
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    job_Guarantee_Headroom( 4 );
    i = OBJ_TO_UNT( *jS.s );
    *  jS.s = OBJ_FROM_CHAR( (i >> 24) & 0xFF );
    *++jS.s = OBJ_FROM_CHAR( (i >> 16) & 0xFF );
    *++jS.s = OBJ_FROM_CHAR( (i >>  8) & 0xFF );
    *++jS.s = OBJ_FROM_CHAR(  i        & 0xFF );
}

 /***********************************************************************/
 /*-    job_P_Int_To_Char_Block -- "|intChar" function.		*/
 /***********************************************************************/

void
job_P_Int_To_Char_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Int len = OBJ_TO_BLK( *jS.s );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args( len+2 );

    /* Find block, do conversion: */
    {   register Vm_Obj*p = &jS.s[ -len ]; /* Base of our block. */
	register Vm_Int i;
	for (i = len;   i --> 0;  ++p) {
	    register Vm_Obj v = *p;
	    if (OBJ_IS_INT(v))  *p = OBJ_FROM_CHAR( OBJ_TO_INT(v) & 0xFF );
        }
    }
}

 /***********************************************************************/
 /*-    job_P_Join -- "join" operator.					*/
 /***********************************************************************/

void
job_P_Join(
    void
) {
    Vm_Obj arg0 = jS.s[   0 ];
    Vm_Obj arg1 = jS.s[  -1 ];
    job_Guarantee_N_Args( 2 );
    if (stg_Is_Stg( arg0 )
    &&  stg_Is_Stg( arg1 )
    ){
	Vm_Obj       val = stg_Concatenate( arg1, arg0 );
	*--jS.s    = val;
    } else {
	MUQ_WARN ("join: unsupported types");
    }
}

 /***********************************************************************/
 /*-    job_P_Glue_Strings_Block -- "]glueStrings" operator.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Glue_Strings_Block(
    void
) {
    Vm_Chr buf[ MAX_STRING ];
    Vm_Chr dlm[ MAX_STRING ];
    Vm_Int dln;
    Vm_Obj arg =             jS.s[  0 ]  ;
    Vm_Int len = OBJ_TO_BLK( jS.s[ -1 ] );
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Blk_Arg( -1 );
    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_N_Args( len+2 );

    dln = stg_Get_Bytes( dlm, MAX_STRING, arg, 0 );
    if (dln == MAX_STRING) {
	MUQ_WARN ("]glueStrings: delimiter too long");
    }

    {   /* Sum lengths of all block entries, checking type on each: */
	Vm_Chr* dst = &buf[          0 ];
	Vm_Chr* lim = &buf[ MAX_STRING ];
	Vm_Int  i;
	for (i = 0;   i < len;   ++i) {
	    Vm_Obj stg = jS.s[ -1-len +i ];
	    Vm_Int siz;
	    if (!stg_Is_Stg(stg)) {
		MUQ_WARN ("]glueStrings: non-string in string block");
	    }
	    siz = stg_Len(stg);	
	    if (dst+siz+dln >= lim) MUQ_WARN("]glueStrings: result too long");
	    if (dst != buf) {
		memcpy( dst, dlm, dln );
		dst += dln;
	    }
	    if (siz != stg_Get_Bytes( dst, siz, stg, 0 )) {
		MUQ_WARN ("]glueStrings: internal err");
	    }
	    dst += siz;
	}
	jS.s -= len+2;
	*jS.s = stg_From_Buffer( buf, dst-buf );
    }
}

 /***********************************************************************/
 /*-    job_P_Join_Block -- "]join" operator.				*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Join_Block(
    void
) {

    Vm_Chr buf[ MAX_STRING ];
    Vm_Int len = OBJ_TO_BLK( jS.s[  0 ] );
    Vm_Obj arg =             jS.s[ -1 ]  ;
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(  len+1 );

    /* Treat empty block as a  */
    /* special case and return */
    /* an empty string:        */
    if (!len) {
	*--jS.s = OBJ_FROM_BYT0;
	return;
    }

    if (OBJ_IS_CHAR( arg )) {
	/* Collapse block of chars to a string: */
	if (len >= MAX_STRING) MUQ_WARN ("]join: result too long");
	{   Vm_Int i;
	    for (i = 0;   i < len;   ++i) {
		Vm_Obj n = jS.s[ -len + i ];
		if (!OBJ_IS_CHAR(n))MUQ_WARN ("]join: non-char in char block");
		buf[ i ] = OBJ_TO_CHAR( n );
	    }
	}
	jS.s -= len+1;
       *jS.s  = stg_From_Buffer( buf, len );
	return;
    }

    if (OBJ_IS_INT( arg )) {
	/* Collapse block of ints to a string: */
	if (len >= MAX_STRING) MUQ_WARN ("]join: result too long");
	{   Vm_Int i;
	    for (i = 0;   i < len;   ++i) {
		Vm_Obj n = jS.s[ -len + i ];
		if (!OBJ_IS_INT(n)) MUQ_WARN ("]join: non-int in int block");
		buf[ i ] = OBJ_TO_UNT( n );
	    }
	}
	jS.s -= len+1;
       *jS.s  = stg_From_Buffer( buf, len );
	return;
    }

    if (stg_Is_Stg( arg )) {
	/* Sum lengths of all block entries, checking type on each: */
	Vm_Chr* dst = &buf[        0 ];
	Vm_Chr* lim = &buf[ MAX_STRING ];
	Vm_Int  i;
	for (i = 0;   i < len;   ++i) {
	    Vm_Obj stg = jS.s[ -len +i ];
	    Vm_Int siz;
	    if (!stg_Is_Stg(stg)) MUQ_WARN ("]join: non-string in string block");
	    siz = stg_Len(stg);	
	    if (dst+siz >= lim) MUQ_WARN ("]join: result too long");
	    if (siz != stg_Get_Bytes( dst, siz, stg, 0 )) MUQ_WARN ("]join: internal err");
	    dst += siz;
	}
	jS.s -= len+1;
	*jS.s = stg_From_Buffer( buf, dst-buf );
	return;
    }

    MUQ_WARN ("]join: unsupported types");
}

 /***********************************************************************/
 /*-    job_P_Join_Blocks -- "]|join" operator.				*/
 /***********************************************************************/

void
job_P_Join_Blocks(
    void
) {
    /* Get size of top block: */
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Blk_Arg( 0 );
    {   Vm_Unt top_size = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( top_size + 3 );

	/* Get size of bottom block: */
	job_Guarantee_Blk_Arg( -2 - top_size );
        {   Vm_Unt bot_size = OBJ_TO_BLK( jS.s[ -2 - top_size ] );
	    job_Guarantee_N_Args( bot_size + top_size + 4 );

	    /* Merge two blocks into one: */
	    {   register Vm_Obj* s = &jS.s[ -2 - top_size ];
		register Vm_Int  i = top_size;
		while (i --> 0) { s[0]=s[2]; ++s; }
		jS.s -= 2;
		*jS.s = OBJ_FROM_BLK( bot_size + top_size );
    }   }   }
}

 /***********************************************************************/
 /*-    job_P_Swap_Blocks -- "||swap" operator.				*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Swap_Blocks(
    void
) {
    Vm_Obj buf[ MAX_STRING ];

    /* Get size of top block: */
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Blk_Arg( 0 );
    {   Vm_Unt top_size = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( top_size + 3 );

	/* Get size of bottom block: */
	job_Guarantee_Blk_Arg( -2 - top_size );
        {   Vm_Unt bot_size = OBJ_TO_BLK( jS.s[ -2 - top_size ] );
	    job_Guarantee_N_Args( bot_size + top_size + 4 );

	    if (top_size > MAX_STRING-2) {
		MUQ_WARN("||swap: Top block too large for current implementation.");
	    }
	    
	    {   /* Stash top block in buf: */
		register Vm_Obj* d;
		register Vm_Obj* s = &jS.s[ -1-top_size ];
		register Vm_Int  i;
		for (i = top_size+2;  i --> 0;  )  buf[i] = s[i];

		/* Slide bottom block up: */
		d = &jS.s[            0 ];
		s = &jS.s[ -2 -top_size ];
		for (i = bot_size+2;  i --> 0;  )  *d-- = *s--;

		/* Copy stashed top block into bottom position: */
		d = &jS.s[ -3 -top_size -bot_size ];
		for (i = top_size+2;  i --> 0;  )  d[i] = buf[i];
    }   }   }
}

 /***********************************************************************/
 /*-    job_P_Kitchen_Sinks -- Count # of kitchen sinks server supports.*/
 /***********************************************************************/

#ifndef MUQ_KITCHEN_SINKS
#define MUQ_KITCHEN_SINKS 0
#endif

void
job_P_Kitchen_Sinks(
    void
) {
    *++jS.s = OBJ_FROM_INT( MUQ_KITCHEN_SINKS );
}

 /***********************************************************************/
 /*-    job_P_Words_To_String -- "]words operator.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Words_To_String(
    void
) {

    Vm_Chr buf[ MAX_STRING ];
    Vm_Int len = OBJ_TO_BLK( jS.s[  0 ] );
/*  Vm_Obj arg =             jS.s[ -1 ]  ; */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(  len+2 );

    {   /* Sum lengths of all block entries, checking type on each: */
	Vm_Chr* dst = &buf[        0 ];
	Vm_Chr* lim = &buf[ MAX_STRING ];
	Vm_Int  i;
	for (i = 0;   i < len;   ++i) {
	    Vm_Obj stg = jS.s[ -len +i ];
	    Vm_Int siz;
	    if (!stg_Is_Stg(stg)) MUQ_WARN ("]words: non-string arg");
	    siz = stg_Len(stg);	
	    if (dst+siz+1 >= lim) MUQ_WARN ("]words: result too long");
	    if (i) *dst++ = ' ';
	    if (siz != stg_Get_Bytes( dst, siz, stg, 0 )) MUQ_WARN ("]words: internal err");
	    dst += siz;
	}
	jS.s -= len+1;
	*jS.s = stg_From_Buffer( buf, dst-buf );
	return;
    }
}

 /***********************************************************************/
 /*-    job_P_Length2 --						*/
 /***********************************************************************/

void
job_P_Length2(
    void
) {
    Vm_Obj o = jS.s[  0 ]   ;
    job_Guarantee_N_Args(   1 );

    if (OBJ_IS_VEC(o)) {Vm_Obj val=OBJ_FROM_UNT(vec_Len(o)); *jS.s=val; return; }
    if (stg_Is_Stg(o)) {Vm_Obj val=OBJ_FROM_UNT(stg_Len(o)); *jS.s=val;	return; }
/*  if (OBJ_IS_I08(o)) {Vm_Obj val=OBJ_FROM_UNT(stg_Len(o)); *jS.s=val; return; } */
    if (OBJ_IS_I16(o)) {Vm_Obj val=OBJ_FROM_UNT(i16_Len(o)); *jS.s=val;	return; }
    if (OBJ_IS_I32(o)) {Vm_Obj val=OBJ_FROM_UNT(i32_Len(o)); *jS.s=val;	return; }
    if (OBJ_IS_F32(o)) {Vm_Obj val=OBJ_FROM_UNT(f32_Len(o)); *jS.s=val;	return; }
    if (OBJ_IS_F64(o)) {Vm_Obj val=OBJ_FROM_UNT(f64_Len(o)); *jS.s=val;	return; }

    if (OBJ_IS_EPHEMERAL_VECTOR(o)) {
	Vm_Int  len;
	(void) EVC_P( &len, o );
	*jS.s = OBJ_FROM_INT( len );
	return;
    }

    if (OBJ_IS_STRUCT(o)) {
	job_Guarantee_Stc_Arg( 0 );
	{   Vm_Obj  val = OBJ_FROM_UNT( stc_Len( o ) );
	    *jS.s = val;
	}
	return;
    }

    if (OBJ_IS_EPHEMERAL_STRUCT(o)) {
	Vm_Int  len;
	(void) EST_P( &len, o );
	*jS.s = OBJ_FROM_INT( len );
	return;
    }


    if (OBJ_IS_OBJ(o)) {
	if (OBJ_IS_CLASS_STK(o)
	||  OBJ_IS_CLASS_LST(o)
	||  OBJ_IS_CLASS_DST(o)
	){
	    *jS.s = stk_Length(o);
	    return;
	}
	if (OBJ_IS_CLASS_STM(o)) {
	    *jS.s = stm_Length(o);
	    return;
	}
    }
    
    MUQ_WARN ("length: unsupported arg type");
}

 /***********************************************************************/
 /*-    job_P_Copy_Mos_Key_Slot -- 					*/
 /***********************************************************************/

void
job_P_Copy_Mos_Key_Slot(
    void
) {
    Vm_Obj dst_key  =             jS.s[ -3 ]  ;
    Vm_Unt dst_slot = OBJ_TO_UNT( jS.s[ -2 ] );
    Vm_Obj src_key  =             jS.s[ -1 ]  ;
    Vm_Unt src_slot = OBJ_TO_UNT( jS.s[  0 ] );

    job_Guarantee_N_Args(4);

    job_Guarantee_Key_Arg(    -3 );
    job_Guarantee_Int_Arg(    -2 );
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    job_Must_Control_Object(  -3 );

    {   Key_P d;
        Key_P s;
	vm_Loc2( (void**)&d, (void**)&s, dst_key, src_key );
	if (dst_slot >= OBJ_TO_UNT( d->total_slots )) {
	    MUQ_WARN("copyMosKeySlot: dst slot index out of range");
	}
	if (src_slot >= OBJ_TO_UNT( s->total_slots )) {
	    MUQ_WARN("copyMosKeySlot: src slot index out of range");
	}
/* buggo? Probably we should be more restrictive */
/* about read permissions on src here. */
	d->slot[ dst_slot ] = s->slot[ src_slot ];

	/* Slot name must be copied separately: */
	{   Key_Sym dst_sym_a = (Key_Sym)((Vm_Obj*)d) + OBJ_TO_INT(d->sym_loc);
	    Key_Sym src_sym_a = (Key_Sym)((Vm_Obj*)s) + OBJ_TO_INT(s->sym_loc);

	    dst_sym_a[ dst_slot ].symbol = src_sym_a[ src_slot ].symbol;
	}
	vm_Dirty( dst_key );
    }
    jS.s -= 4;
}

 /***********************************************************************/
 /*-    job_P_Unlink_Mos_Key_From_Ancestor -- 				*/
 /***********************************************************************/

static void
unlink_mos_key_from_ancestor(
    Vm_Obj key,
    Vm_Int slot
) {
    Vm_Obj next;	Vm_Int next_slot;
    Vm_Obj prev;	Vm_Int prev_slot;

    {	Key_P k = KEY_P(key);
	Key_Link a = (Key_Link)(
	    ((Vm_Obj*)k) + OBJ_TO_INT(k->link_loc)
	);
	Key_Link s = a + slot;

	if (slot < -1 || slot >= OBJ_TO_INT(k->precedence_len)) {
	    MUQ_WARN("unlinkMosKeyFromAncestor: bad slot number");
	}

	/* Check for already unlinked: */
	next = s->next;   next_slot = OBJ_TO_INT( s->next_slot );
	prev = s->prev;   prev_slot = OBJ_TO_INT( s->prev_slot );

	if (next == key
	&&  prev == key
	&&  prev_slot == slot
	&&  next_slot == slot
	){
	    /* Silently treat redundant unlink as a no-op: */
	    return;
	}

	s->next = key;
	s->prev = key;
	s->next_slot = OBJ_FROM_INT( slot );
	s->prev_slot = OBJ_FROM_INT( slot );

	vm_Dirty(key);
    }

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(next) || !OBJ_IS_CLASS_KEY(next)) MUQ_WARN("intern err0");
    if (!OBJ_IS_OBJ(prev) || !OBJ_IS_CLASS_KEY(prev)) MUQ_WARN("intern err1");
    #endif

    {	Key_P k = KEY_P(next);
	Key_Link a = (Key_Link)(
	    ((Vm_Obj*)k) + OBJ_TO_INT(k->link_loc)
	);
	Key_Link s = a + next_slot;

	if (next_slot < -1 || next_slot >= OBJ_TO_INT(k->precedence_len)) {
	    MUQ_WARN("internal err2");
	}

	s->prev      =               prev       ;
	s->prev_slot = OBJ_FROM_INT( prev_slot );

	vm_Dirty(next);
    }

    {	Key_P k = KEY_P(prev);
	Key_Link a = (Key_Link)(
	    ((Vm_Obj*)k) + OBJ_TO_INT(k->link_loc)
	);
	Key_Link s = a + prev_slot;

	if (prev_slot < -1 || prev_slot >= OBJ_TO_INT(k->precedence_len)) {
	    MUQ_WARN("internal err3");
	}

	s->next      =               next       ;
	s->next_slot = OBJ_FROM_INT( next_slot );

	vm_Dirty(prev);
    }
}

void
job_P_Unlink_Mos_Key_From_Ancestor(
    void
) {
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Int slot = OBJ_TO_INT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    job_Must_Control_Object(  -1 );
    unlink_mos_key_from_ancestor( key, slot );

    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Link_Mos_Key_To_Ancestor -- 				*/
 /***********************************************************************/

void
job_Link_Mos_Key_To_Ancestor(
    Vm_Obj key,
    Vm_Int slot
) {
    Vm_Obj prev;	Vm_Int prev_slot;
    Vm_Obj next;	Vm_Int next_slot;

    {	Vm_Obj ancestor;
	Vm_Obj akey;
	Key_P k = KEY_P(key);

	Key_Ancestor a0 = (Key_Ancestor)(
	    ((Vm_Obj*)k) + OBJ_TO_INT(k->precedence_loc)
	);
	Key_Ancestor a = a0 + slot;

	if (slot < -1 || slot >= OBJ_TO_INT(k->precedence_len)) {
	    MUQ_WARN("linkMosKeyToAncestor: bad slot number");
	}

	/* Check for no ancestor to link to: */
	ancestor = a->ancestor;
	if (!OBJ_IS_OBJ(ancestor) || !OBJ_IS_CLASS_CDF(ancestor)
	|| !(akey = CDF_P(ancestor)->key)
	||  !OBJ_IS_OBJ(akey)     || !OBJ_IS_CLASS_KEY(akey)
        ){
	    /* Silently treat impossible link as a no-op: */
	    return;
	}

	/* We will be 'next' on ancestor's */
	/*  -1 (root) ancestor slot:       */
	prev      = akey;
	prev_slot = -1;
    }

    {	Key_P k = KEY_P(prev);
	/* I've heard it suggested that folks who use */
	/* 'l' as a local var name should be shot.    */
	/* I've never heard a fate proposed for those */
	/* who use 'l0' as a local var name...        */
	Key_Link l0 = (Key_Link)(
	    ((Vm_Obj*)k) + OBJ_TO_INT(k->link_loc)
	);
	Key_Link l = l0 + prev_slot;

	/* Check for ancestor not owned or fertile: */
	if (k->fertile == OBJ_NIL)   job_must_control( prev );

	next           =             l->next       ;
	next_slot      = OBJ_TO_INT( l->next_slot );

	l->next        =               key   ;
	l->next_slot   = OBJ_FROM_INT( slot );

	vm_Dirty(prev);
    }

    {	Key_P k = KEY_P(next);
	Key_Link l0 = (Key_Link)(
	    ((Vm_Obj*)k) + OBJ_TO_INT(k->link_loc)
	);
	Key_Link l = l0 + next_slot;

	#if MUQ_IS_PARANOID
	if (l->prev != prev || l->prev_slot != OBJ_FROM_INT(prev_slot)) {
	    MUQ_WARN("internal err4");
	}
	#endif

	l->prev        =               key  ;
	l->prev_slot   = OBJ_FROM_INT( slot );

	vm_Dirty(next);
    }

    {	Key_P k = KEY_P(key);
	Key_Link l0 = (Key_Link)(
	    ((Vm_Obj*)k) + OBJ_TO_INT(k->link_loc)
	);
	Key_Link l = l0 + slot;

	/* Make ourself 'next' on ancestor's chain: */
	l->prev      =               prev       ;
	l->prev_slot = OBJ_FROM_INT( prev_slot );
	l->next      =               next       ;
	l->next_slot = OBJ_FROM_INT( next_slot );

	vm_Dirty(key);
    }
}

void
job_P_Link_Mos_Key_To_Ancestor(
    void
) {
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Int slot = OBJ_TO_INT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    job_Must_Control_Object(  -1 );

    /* Make sure key is unlinked: */
    unlink_mos_key_from_ancestor( key, slot );

    job_Link_Mos_Key_To_Ancestor( key, slot );

    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Next_Mos_Key_Link -- 					*/
 /***********************************************************************/

void
job_P_Next_Mos_Key_Link(
    void
) {
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Int slot = OBJ_TO_INT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );

    {   Key_P k  = KEY_P( key );
        Key_Link l;
	Vm_Int len = OBJ_TO_INT( k->precedence_len );
	Vm_Unt loc = OBJ_TO_UNT(       k->link_loc );
	if (slot >= len || slot < -1) {
	    MUQ_WARN ("No such ancestor slot in this mosKey");
	}
	l = (Key_Link)(((Vm_Obj*)k)+loc);
	jS.s[ -1 ] = l[ slot ].next;
	jS.s[  0 ] = l[ slot ].next_slot;
    }
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Ancestor -- 					*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Ancestor(
    void
) {
    Vm_Obj result = OBJ_NIL;
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    {   Key_P s  = KEY_P( key );
        Key_Ancestor a;
	Vm_Unt len = OBJ_TO_UNT( s->precedence_len );
	Vm_Unt loc = OBJ_TO_UNT( s->precedence_loc );
	if (slot >= len) MUQ_WARN ("No such ancestor slot in this mosKey");
	a = (Key_Ancestor)(((Vm_Obj*)s)+loc);
	result = a[ slot ].ancestor;
    }

    *--jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Ancestor_P -- 				*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Ancestor_P(
    void
) {
    Vm_Obj result = OBJ_NIL;
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    {   Key_P s  = KEY_P( key );
        Key_Ancestor a;
	Vm_Unt len = OBJ_TO_UNT( s->precedence_len );
	Vm_Unt loc = OBJ_TO_UNT( s->precedence_loc );
	if (slot >= len) {
	    jS.s[-1] = OBJ_NIL;
	    return;
	}
	a = (Key_Ancestor)(((Vm_Obj*)s)+loc);
	result = a[ slot ].ancestor;
    }
    jS.s[-1] = OBJ_T;
    jS.s[ 0] = result;
}

 /***********************************************************************/
 /*-    job_Set_Mos_Key_Ancestor --	 				*/
 /***********************************************************************/

void
job_Set_Mos_Key_Ancestor(
    Vm_Obj key,
    Vm_Unt slot,
    Vm_Obj val
) {
    Key_P s   = KEY_P( key );
    Key_Ancestor a;
    Vm_Unt len = OBJ_TO_UNT( s->precedence_len );
    Vm_Unt loc = OBJ_TO_UNT( s->precedence_loc );
    if (slot >= len) MUQ_WARN ("No such ancestor slot in this mosKey");
    a = (Key_Ancestor)(((Vm_Obj*)s)+loc);
    a[ slot ].ancestor = val;
    vm_Dirty(key);
}

 /***********************************************************************/
 /*-    job_P_Set_Mos_Key_Ancestor --	 				*/
 /***********************************************************************/

void
job_P_Set_Mos_Key_Ancestor(
    void
) {
    Vm_Obj key  =             jS.s[ -2 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -1 ] );
    Vm_Obj val  =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(3);
    job_Guarantee_Key_Arg(    -2 );
    job_Guarantee_Int_Arg(    -1 );
    job_Guarantee_Cdf_Arg(     0 );
    job_Must_Control_Object(  -2 );

    /* Check for ancestor not owned or fertile: */
    {   Vm_Obj akey = CDF_P(val)->key;
	if (!OBJ_IS_OBJ(akey) || !OBJ_IS_CLASS_KEY(akey)) {
	    MUQ_WARN("Must define superclasses before their descendants");
	}
	{   Key_P k   = KEY_P( akey );
	    if (k->fertile == OBJ_NIL)   job_must_control( akey );
    }	}

    job_Set_Mos_Key_Ancestor( key, slot, val );

    jS.s -= 3;
}

 /***********************************************************************/
 /*-    job_P_Delete_Mos_Key_Class_Method -- 				*/
 /***********************************************************************/

#undef  M
#define M sizeof(Key_A_Class_Method)/sizeof(Vm_Obj)
void
job_P_Delete_Mos_Key_Class_Method(
    void
) {
    Vm_Obj key = jS.s[ -1 ];
    Vm_Unt mtd = jS.s[  0 ];
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg( -1 );
    job_Guarantee_Mtd_Arg(  0 );
    job_Must_Control_Object( -1 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->classmethods_len );
	Vm_Unt loc = OBJ_TO_UNT( s->classmethods_loc );
	Key_Class_Method p = (Key_Class_Method) (a + loc);
	Vm_Int i;
	for (i = 0;   i < len;   ++i) {
	    if (p[i].method == mtd) {
		Vm_Unt oldlen = vm_Len( key );
		Vm_Unt newlen = oldlen - sizeof(Key_A_Class_Method);
		Vm_Obj result = vm_Malloc(newlen,VM_DBFILE(key),OBJ_K_OBJ);
		Vm_Int lohalf = ((Vm_Obj*)(&p[i].argument_number))-a;
		Vm_Int lim    = newlen / sizeof(Vm_Obj);
		Vm_Int j;
		Vm_Obj*b;
		vm_Loc2( (void**)&a, (void**)&b, key, result );
		for (j = 0;   j < lohalf;   ++j)   b[j] = a[j];
		for (     ;   j < lim   ;   ++j)   b[j] = a[j+M];
		*--jS.s = result;
	        s = (Key_P) b;
	        s->classmethods_len = OBJ_FROM_UNT( len - 1 );

		/* Clear all ancestor links: */
		{   Vm_Unt  loc = OBJ_TO_UNT( ((Key_P)b)->      link_loc );
		    Vm_Int  len = OBJ_TO_INT( ((Key_P)b)->precedence_len );
		    Key_Link l = (Key_Link)(((Vm_Obj*)b)+loc);
		    Vm_Int i;
		    for (i = -1;   i < len;   ++i) {
			l[i].next      = result;
			l[i].prev      = result;
			l[i].next_slot = OBJ_FROM_INT(i);
			l[i].prev_slot = OBJ_FROM_INT(i);
		}   }

		vm_Dirty(result);
		return;
	    }
	}
	MUQ_WARN ("getMosKeyClassMethod: Method not found");
    }
}
#undef  M

 /***********************************************************************/
 /*-    job_P_Delete_Mos_Key_Object_Method -- 				*/
 /***********************************************************************/

#undef  M
#define M sizeof(Key_A_Object_Method)/sizeof(Vm_Obj)
void
job_P_Delete_Mos_Key_Object_Method(
    void
) {
    Vm_Obj key = jS.s[ -1 ];
    Vm_Unt mtd = jS.s[  0 ];
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg( -1 );
    job_Guarantee_Mtd_Arg(  0 );
    job_Must_Control_Object( -1 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt  len = OBJ_TO_UNT( s->objectmethods_len );
	Vm_Unt  loc = OBJ_TO_UNT( s->objectmethods_loc );
	Vm_Unt cloc = OBJ_TO_UNT( s->classmethods_loc );
	Key_Object_Method p = (Key_Object_Method) (a + loc);
	Vm_Int i;
	for (i = 0;   i < len;   ++i) {
	    if (p[i].method == mtd) {
		Vm_Unt oldlen = vm_Len( key );
		Vm_Unt newlen = oldlen - sizeof(Key_A_Object_Method);
		Vm_Obj result = vm_Malloc(newlen,VM_DBFILE(key),OBJ_K_OBJ);
		Vm_Int lohalf = ((Vm_Obj*)(&p[i].argument_number))-a;
		Vm_Int lim    = newlen / sizeof(Vm_Obj);
		Vm_Int j;
		Vm_Obj*b;
		vm_Loc2( (void**)&a, (void**)&b, key, result );
		for (j = 0;   j < lohalf;   ++j)   b[j] = a[j];
		for (     ;   j < lim   ;   ++j)   b[j] = a[j+M];
	        s = (Key_P) b;
		s->classmethods_loc  = OBJ_FROM_UNT( cloc - M );
		s->objectmethods_len = OBJ_FROM_UNT(  len - 1 );

		/* Clear all ancestor links: */
		{   Vm_Unt  loc = OBJ_TO_UNT( ((Key_P)b)->      link_loc );
		    Vm_Int  len = OBJ_TO_INT( ((Key_P)b)->precedence_len );
		    Key_Link l = (Key_Link)(((Vm_Obj*)b)+loc);
		    Vm_Int i;
		    for (i = -1;   i < len;   ++i) {
			l[i].next      = result;
			l[i].prev      = result;
			l[i].next_slot = OBJ_FROM_INT(i);
			l[i].prev_slot = OBJ_FROM_INT(i);
		}   }

		vm_Dirty(result);
		*--jS.s = result;
		return;
	    }
	}
	MUQ_WARN ("getMosKeyObjectMethod: Method not found");
    }
}
#undef  M

 /***********************************************************************/
 /*-    job_P_Insert_Mos_Key_Class_Method -- 				*/
 /***********************************************************************/

#undef  M
#define M sizeof(Key_A_Class_Method)/sizeof(Vm_Obj)
void
job_P_Insert_Mos_Key_Class_Method(
    void
) {
    Vm_Obj key =             jS.s[ -4 ]  ;
    Vm_Unt slot= OBJ_TO_UNT( jS.s[ -3 ] );
    Vm_Unt ano =             jS.s[ -2 ]  ;
    Vm_Unt cfn =             jS.s[ -1 ]  ;
    Vm_Unt mtd =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(5);
    job_Guarantee_Key_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Cfn_Arg( -1 );
    job_Guarantee_Mtd_Arg(  0 );
    job_Must_Control_Object( -4 );
    {   Key_P  s   = KEY_P( key );
        Vm_Obj*a   = (Vm_Obj*) s;
        Vm_Unt loc = OBJ_TO_UNT( s->classmethods_loc );
        Vm_Unt len = OBJ_TO_UNT( s->classmethods_len );

	/* Find slot at which to insert new method: */
        Vm_Int mloc = ((Vm_Obj*)(((Key_Class_Method)(a+loc))+slot)) - a;

	Vm_Unt oldlen = vm_Len( key );
	Vm_Unt newlen = oldlen + sizeof(Key_A_Class_Method);
	Vm_Obj result = vm_Malloc( newlen, VM_DBFILE(key), OBJ_K_OBJ );
	Vm_Int lim    = newlen / sizeof(Vm_Obj);
	Vm_Int j;
	Vm_Obj*b;
	if (slot > len) {
	    MUQ_WARN("insertMosKeyClassMethod: bad slot number");
	}
	vm_Loc2( (void**)&a, (void**)&b, key, result );
	for (j = 0;   j < mloc;   ++j) {
	    b[j] = a[j];
	}
	((Key_Class_Method)(b+j))->argument_number  = ano;
	((Key_Class_Method)(b+j))->generic_function = cfn;
	((Key_Class_Method)(b+j))->method           = mtd;
	for (j += M;   j < lim;   ++j) {
            b[j] = a[j-M];
	}
        ((Key_P)b)->classmethods_len = OBJ_FROM_UNT(len+1);

	/* Clear all ancestor links: */
	{   Vm_Unt  loc = OBJ_TO_UNT( ((Key_P)b)->      link_loc );
	    Vm_Int  len = OBJ_TO_INT( ((Key_P)b)->precedence_len );
	    Key_Link l = (Key_Link)(((Vm_Obj*)b)+loc);
	    Vm_Int i;
	    for (i = -1;   i < len;   ++i) {
		l[i].next      = result;
		l[i].prev      = result;
		l[i].next_slot = OBJ_FROM_INT(i);
		l[i].prev_slot = OBJ_FROM_INT(i);
	}   }

	vm_Dirty(result);
	jS.s -= 4;
	*jS.s = result;
    }
}
#undef  M

 /***********************************************************************/
 /*-    job_P_Insert_Mos_Key_Object_Method -- 				*/
 /***********************************************************************/

#undef  M
#define M sizeof(Key_A_Object_Method)/sizeof(Vm_Obj)
void
job_P_Insert_Mos_Key_Object_Method(
    void
) {
    Vm_Obj key =             jS.s[ -5 ]  ;
    Vm_Unt slot= OBJ_TO_UNT( jS.s[ -4 ] );
    Vm_Unt ano =             jS.s[ -3 ]  ;
    Vm_Unt cfn =             jS.s[ -2 ]  ;
    Vm_Unt mtd =             jS.s[ -1 ]  ;
    Vm_Unt obj =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(6);
    job_Guarantee_Key_Arg( -5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Cfn_Arg( -2 );
    job_Guarantee_Mtd_Arg( -1 );
/*  job_Guarantee_Mos_Arg(  0 ); */
    job_Must_Control_Object( -5 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt  loc = OBJ_TO_UNT( s->objectmethods_loc );
	Vm_Unt  len = OBJ_TO_UNT( s->objectmethods_len );
	Vm_Unt cloc = OBJ_TO_UNT( s->classmethods_loc  );
	/* Find slot at which to insert new method: */
        Vm_Int mloc = ((Vm_Obj*)(((Key_Object_Method)(a+loc))+slot)) - a;

	Vm_Unt oldlen = vm_Len( key );
	Vm_Unt newlen = oldlen + sizeof(Key_A_Object_Method);
	Vm_Obj result = vm_Malloc( newlen, VM_DBFILE(key), OBJ_K_OBJ );
	Vm_Int lim    = newlen / sizeof(Vm_Obj);
	Vm_Int j;
	Vm_Obj*b;
	if (slot > len) {
	    MUQ_WARN("insertMosKeyObjectMethod: bad slot number");
	}
	vm_Loc2( (void**)&a, (void**)&b, key, result );
	for (j = 0;   j < mloc;   ++j)   b[j] = a[j];
	((Key_Object_Method)(b+j))->argument_number  = ano;
	((Key_Object_Method)(b+j))->generic_function = cfn;
	((Key_Object_Method)(b+j))->method           = mtd;
	((Key_Object_Method)(b+j))->object           = obj;
	for (j += M;   j < lim;   ++j)   b[j] = a[j-M];
        ((Key_P)b)->objectmethods_len = OBJ_FROM_UNT(len+1);
        ((Key_P)b)->classmethods_loc  = OBJ_FROM_UNT(cloc+M);

	/* Clear all ancestor links: */
	{   Vm_Unt  loc = OBJ_TO_UNT( ((Key_P)b)->      link_loc );
	    Vm_Int  len = OBJ_TO_INT( ((Key_P)b)->precedence_len );
	    Key_Link l = (Key_Link)(((Vm_Obj*)b)+loc);
	    Vm_Int i;
	    for (i = -1;   i < len;   ++i) {
		l[i].next      = result;
		l[i].prev      = result;
		l[i].next_slot = OBJ_FROM_INT(i);
		l[i].prev_slot = OBJ_FROM_INT(i);
	}   }


	jS.s -= 5;
	*jS.s = result;
    }
}
#undef  M

 /***********************************************************************/
 /*-    job_P_Find_Mos_Class_Method -- 					*/
 /***********************************************************************/

void
job_P_Find_Mos_Key_Class_Method(
    void
) {
    Vm_Obj key  =             jS.s[ -3 ]  ;
    Vm_Obj ano  =             jS.s[ -2 ]  ;
    Vm_Obj cfn  =             jS.s[ -1 ]  ;
    Vm_Int slot = OBJ_TO_INT( jS.s[  0 ] );
    job_Guarantee_N_Args(4);
    job_Guarantee_Key_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Cfn_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    if (slot < 0) {
	MUQ_WARN("find-mos-key-class-method: Slot must be non-negative");
    }
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->classmethods_len );
	Vm_Unt loc = OBJ_TO_UNT( s->classmethods_loc );


	Key_Class_Method p = (Key_Class_Method) (a + loc);
	Vm_Int i;
	for (i = slot;   i < len;   ++i) {
	    if (p[i].generic_function == cfn
	    &&  p[i].argument_number  == ano
            ){
		--jS.s;
		jS.s[ -2 ] = OBJ_T;
		jS.s[ -1 ] = p[i].method;
		jS.s[  0 ] = OBJ_FROM_UNT(i+1);
		return;
	    }
	}
	--jS.s;
	jS.s[-2] = OBJ_NIL;
	return;
    }
}

 /***********************************************************************/
 /*-    job_P_Find_Mos_Object_Method --					*/
 /***********************************************************************/

void
job_P_Find_Mos_Key_Object_Method(
    void
) {
    Vm_Obj key  =             jS.s[ -4 ]  ;
    Vm_Obj ano  =             jS.s[ -3 ]  ;
    Vm_Obj cfn  =             jS.s[ -2 ]  ;
    Vm_Obj obj  =             jS.s[ -1 ]  ;
    Vm_Int slot = OBJ_TO_INT( jS.s[  0 ] );
    job_Guarantee_N_Args(4);
    job_Guarantee_Key_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Cfn_Arg( -2 );
/*  job_Guarantee_Mos_Arg( -1 ); */
    job_Guarantee_Int_Arg(  0 );
    if (slot < 0) {
	MUQ_WARN("find-mos-key-object-method: Slot must be non-negative");
    }
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->objectmethods_len );
	Vm_Unt loc = OBJ_TO_UNT( s->objectmethods_loc );


	Key_Object_Method p = (Key_Object_Method) (a + loc);
	Vm_Int i;
	for (i = slot;   i < len;   ++i) {
	    if (p[i].generic_function == cfn
	    &&  p[i].object           == obj
	    &&  p[i].argument_number  == ano
	    ){
		jS.s -= 2;
		jS.s[ -2 ] = OBJ_T;
		jS.s[ -1 ] = p[i].method;
		jS.s[  0 ] = OBJ_FROM_INT(i+1);
		return;
	    }
	}
	jS.s -= 2;
	jS.s[-2] = OBJ_NIL;
	return;
    }
}

 /***********************************************************************/
 /*-    job_P_Applicable_Method_P --					*/
 /***********************************************************************/

void
job_P_Applicable_Method_P(
    void
) {
    Vm_Int len = OBJ_TO_BLK( jS.s[ -1 ] );
    Vm_Obj mtd =             jS.s[  0 ]  ;
    Mtd_P  m;
    Vm_Int i;

    job_Guarantee_Blk_Arg( -1 );
    job_Guarantee_Mtd_Arg(  0 );
    job_Guarantee_N_Args(len+3);

    m = MTD_P(mtd);
    if (OBJ_TO_INT(m->required_args) != len) {
        *jS.s = OBJ_NIL;
        return;
    }

    /* Over all required arguments, excepting first, */
    /* which we presume to have been already checked */
    /* findMosKeyClassMethod? or else via       */
    /* findMosKeyObjectMethod?                  */
    for (i = 1;   i < len;   ++i) {
        Vm_Obj o = m->slot[i].op;
	Vm_Obj a;
	Vm_Obj c;

	/* Op two (t) means no constraint on arg: */
	if (o == OBJ_FROM_INT(2)) {
	    /* No constraints on this arg: */
	    continue;
	}

	/* Op zero (:eql) means arg must */
        /* be equal to given constant:  */
	a = jS.s[ i - (len + 1) ];
	if (o == OBJ_FROM_INT(0)) {
	    /* Given arg must == given value: */
	    if (a != m->slot[i].op) {
		*jS.s = OBJ_NIL;
		return;
	    }
	    continue;
	}

	/* Op one (:instance) means given arg must be  */
        /* instance of given class or of a subclass of */
        /* that class:				       */
	c = m->slot[i].arg;
/* Buggo, will need a hack here to support ephemeral objects. */
        if (!OBJ_IS_STRUCT(a)) {
	    *jS.s = OBJ_NIL;
	    return;
	}
        a = STC_P(a)->is_a;
        if (!OBJ_IS_OBJ(a)
	||  !OBJ_IS_CLASS_KEY(a)
	){
	    *jS.s = OBJ_NIL;
	    return;
	}

	/* Search class precedence list for arg's class. */
	/* One of them must match target class c:        */
	{   Key_P  g   = KEY_P(a);
	    Vm_Int lim = OBJ_TO_INT( g->precedence_len );
/* buggo, if class has been updated,  */
/* may need to take care of that here */
	    Key_Ancestor a = (Key_Ancestor)(
		((Vm_Obj*)g) + OBJ_TO_INT( g->precedence_loc )
	    );
	    Vm_Int j = lim;
	    for (;  ;   --j, ++a) {
		if (!j) {
		    /* Whoops, failed this test: */
		    *jS.s = OBJ_NIL;
		    return;
		}
		if (a->ancestor == c) break;
	    }

	    /* Need to restore 'm': */
	    m = MTD_P(mtd);
	    continue;
	}
    }
    *jS.s = OBJ_T;
}

 /***********************************************************************/
 /*-    job_P_Methods_Match_P -- "methodsMatch?"			*/
 /***********************************************************************/

void
job_P_Methods_Match_P(
    void
) {
    Vm_Obj mtd0 = jS.s[ -1 ];
    Vm_Obj mtd1 = jS.s[  0 ];
    Mtd_P  m0;
    Mtd_P  m1;
    job_Guarantee_Mtd_Arg( -1 );
    job_Guarantee_Mtd_Arg(  0 );
    vm_Loc2( (void**)&m0, (void**)&m1, mtd0, mtd1 );
    if (m0->required_args
    !=  m1->required_args
    ){
	jS.s[ 0] = OBJ_NIL;
	jS.s[-1] = OBJ_NIL;
	return;
    }
    if (m0->generic_fn
    !=  m1->generic_fn
    ){
	jS.s[ 0] = OBJ_NIL;
	jS.s[-1] = OBJ_NIL;
	return;
    }
    jS.s[-1] = OBJ_T;
    {   Vm_Int lim = OBJ_TO_INT( m0->required_args );
	Vm_Int i;
	for (i = 0;   i < lim;   ++i) {
	    Vm_Obj arg1 = m0->slot[i].arg;
	    Vm_Obj arg2 = m1->slot[i].arg;
	    if (m0->slot[i].op
	    !=  m1->slot[i].op
	    ){
		if (OBJ_TO_INT(m0->slot[i].op)
		<   OBJ_TO_INT(m1->slot[i].op)
		){
		    jS.s[ 0] = OBJ_FROM_INT(-1);
		} else {
		    jS.s[ 0] = OBJ_FROM_INT( 1);
		}
		return;
	    }

	    /* If op is ignore arg, ignore args: */
	    if (m0->slot[i].op == OBJ_FROM_INT(0))   continue;

	    /* Punt unless arg1 and arg1 are both valid classes: */
	    if ((arg1 = m0->slot[i].arg)
	    !=  (arg2 = m1->slot[i].arg)
	    ){
		if (m0->slot[i].op == OBJ_FROM_INT(1)) {
		    if (!OBJ_IS_OBJ(arg1) || !OBJ_IS_CLASS_CDF(arg1)
		    ||  !OBJ_IS_OBJ(arg2) || !OBJ_IS_CLASS_CDF(arg2)
                    ){
		        jS.s[ 0] = OBJ_NIL;
		        return;
		    }
		}

		/* Punt unless arg1 and arg1 both have valid key: */
		{   Vm_Obj key1 = CDF_P(arg1)->key;
		    Vm_Obj key2 = CDF_P(arg2)->key;
		    if(!OBJ_IS_OBJ(key1) || !OBJ_IS_CLASS_KEY(key1)
		    || !OBJ_IS_OBJ(key2) || !OBJ_IS_CLASS_KEY(key2)
		    ){
			jS.s[ 0] = OBJ_NIL;
			return;
		    }

		    /* Is arg1 a subclass of arg2? */
		    {   Key_P   g   = KEY_P(key2);
			Vm_Int  loc = OBJ_TO_INT(g->precedence_loc);
			Vm_Int  len = OBJ_TO_INT(g->precedence_len);
		        Key_Ancestor a = (Key_Ancestor)(((Vm_Obj*) g)+loc);
			Vm_Int  i;
			for (i = 0;   i < len;   ++i) {
			    if (a[i].ancestor == arg1) {
				jS.s[ 0] = OBJ_FROM_INT(1);
				return;
		    }   }   }

		    /* Is arg2 a subclass of arg1? */
		    {   Key_P   g   = KEY_P(key1);
			Vm_Int  loc = OBJ_TO_INT(g->precedence_loc);
			Vm_Int  len = OBJ_TO_INT(g->precedence_len);
		        Key_Ancestor a = (Key_Ancestor)(((Vm_Obj*) g)+loc);
			Vm_Int  i;
			for (i = 0;   i < len;   ++i) {
			    if (a[i].ancestor == arg2) {
				jS.s[ 0] = OBJ_FROM_INT(-1);
				return;
		}   }   }   }
		jS.s[ 0] = OBJ_NIL;
		return;
    }	}   }
    jS.s[0] = OBJ_FROM_INT(0);
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Parent -- 					*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Parent(
    void
) {
    Vm_Obj result = OBJ_NIL;
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->superclass_len );
	Vm_Unt loc = OBJ_TO_UNT( s->superclass_loc );
	if (slot >= len) MUQ_WARN ("No such parent slot in this mosKey");
	result = a[ loc + slot ];
    }

    *--jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Initarg -- 					*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Initarg(
    void
) {
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->initarg_len );
	Vm_Unt loc = OBJ_TO_UNT( s->initarg_loc );
	if (slot >= len) MUQ_WARN ("No such initarg slot in this mosKey");
	jS.s[ -1 ] = a[ loc +     slot*(sizeof(Key_A_Initarg)/sizeof(Vm_Obj))];
	jS.s[  0 ] = a[ loc + 1 + slot*(sizeof(Key_A_Initarg)/sizeof(Vm_Obj))];
    }
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Metharg -- 					*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Metharg(
    void
) {
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->metharg_len );
	Vm_Unt loc = OBJ_TO_UNT( s->metharg_loc );
	if (slot >= len) MUQ_WARN ("No such metharg slot in this mosKey");
	--jS.s;
	jS.s[  0 ] = a[ loc + slot ];
    }
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Slotarg -- 					*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Slotarg(
    void
) {
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->slotarg_len );
	Vm_Unt loc = OBJ_TO_UNT( s->slotarg_loc );
	if (slot >= len) MUQ_WARN ("No such slotarg slot in this mosKey");
	--jS.s;
	jS.s[  0 ] = a[ loc + slot ];
    }
}

 /***********************************************************************/
 /*-    job_P_Set_Mos_Key_Metharg --	 				*/
 /***********************************************************************/

void
job_P_Set_Mos_Key_Metharg(
    void
) {
    Vm_Obj Key  =             jS.s[ -2 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -1 ] );
    Vm_Obj val  =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(4);
    job_Guarantee_Key_Arg(    -2 );
    job_Guarantee_Int_Arg(    -1 );
    job_Must_Control_Object(  -2 );
    {   Key_P s   = KEY_P( Key );
        Vm_Obj* a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->metharg_len );
	Vm_Unt loc = OBJ_TO_UNT( s->metharg_loc );
	if (slot >= len) MUQ_WARN ("No such metharg slot in this mosKey");
	a[ loc +  slot ] = val;
	vm_Dirty(Key);
    }

    jS.s -= 4;
}

 /***********************************************************************/
 /*-    job_P_Set_Mos_Key_Slotarg --	 				*/
 /***********************************************************************/

void
job_P_Set_Mos_Key_Slotarg(
    void
) {
    Vm_Obj Key  =             jS.s[ -2 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -1 ] );
    Vm_Obj val  =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(4);
    job_Guarantee_Key_Arg(    -2 );
    job_Guarantee_Int_Arg(    -1 );
    job_Must_Control_Object(  -2 );
    {   Key_P s   = KEY_P( Key );
        Vm_Obj* a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->slotarg_len );
	Vm_Unt loc = OBJ_TO_UNT( s->slotarg_loc );
	if (slot >= len) MUQ_WARN ("No such slotarg slot in this mosKey");
	a[ loc +  slot ] = val;
	vm_Dirty(Key);
    }

    jS.s -= 4;
}

 /***********************************************************************/
 /*-    job_P_Set_Mos_Key_Initarg --	 				*/
 /***********************************************************************/

void
job_P_Set_Mos_Key_Initarg(
    void
) {
    Vm_Obj Key  =             jS.s[ -3 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -2 ] );
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Obj val  =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(4);
    job_Guarantee_Key_Arg(    -3 );
    job_Guarantee_Int_Arg(    -2 );
    job_Must_Control_Object(  -3 );
    {   Key_P s   = KEY_P( Key );
        Vm_Obj* a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->initarg_len );
	Vm_Unt loc = OBJ_TO_UNT( s->initarg_loc );
	if (slot >= len) MUQ_WARN ("No such initarg slot in this mosKey");
	a[ loc +     slot*(sizeof(Key_A_Initarg)/sizeof(Vm_Obj)) ] = key;
	a[ loc + 1 + slot*(sizeof(Key_A_Initarg)/sizeof(Vm_Obj)) ] = val;
	vm_Dirty(Key);
    }

    jS.s -= 4;
}

 /***********************************************************************/
 /*-    job_P_Set_Mos_Key_Class_Method --				*/
 /***********************************************************************/

void
job_P_Set_Mos_Key_Class_Method(
    void
) {
    Vm_Obj key  =             jS.s[ -4 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -3 ] );
    Vm_Obj ano  =             jS.s[ -2 ]  ;
    Vm_Obj cfn  =             jS.s[ -1 ]  ;
    Vm_Obj mtd  =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(4);
    job_Guarantee_Key_Arg(    -4 );
    job_Guarantee_Int_Arg(    -3 );
    job_Guarantee_Int_Arg(    -2 );
    job_Guarantee_Cfn_Arg(    -1 );
    job_Guarantee_Mtd_Arg(     0 );
    job_Must_Control_Object(  -4 );
    {   Key_P s   = KEY_P( key );
        Vm_Obj* a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->classmethods_len );
	Vm_Unt loc = OBJ_TO_UNT( s->classmethods_loc );
        Key_Class_Method p;
	if (slot >= len) MUQ_WARN ("No such classmethod in this mosKey");
        p = (Key_Class_Method)(
            a + loc + slot*(sizeof(Key_A_Class_Method)/sizeof(Vm_Obj))
        );
	p->argument_number  = ano;
	p->generic_function = cfn;
	p->method           = mtd;
	vm_Dirty(key);
    }

    jS.s -= 5;
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Class_Method -- 				*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Class_Method(
    void
) {
    Vm_Obj ano  = OBJ_0;
    Vm_Obj cfn  = OBJ_NIL;
    Vm_Obj mtd  = OBJ_NIL;
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->classmethods_len );
	Vm_Unt loc = OBJ_TO_UNT( s->classmethods_loc );
        Key_Class_Method p;
	if (slot >= len) {
	    MUQ_WARN ("No such classmethods slot in this mosKey");
	}
        p = (Key_Class_Method)(
            a + loc + slot*(sizeof(Key_A_Class_Method)/sizeof(Vm_Obj))
        );
	ano = p->argument_number;
	cfn = p->generic_function;
	mtd = p->method;
    }
    ++jS.s;
    jS.s[ -2 ] = ano;
    jS.s[ -1 ] = cfn;
    jS.s[  0 ] = mtd;
}

 /***********************************************************************/
 /*-    job_P_Set_Mos_Key_Object_Method --				*/
 /***********************************************************************/

void
job_P_Set_Mos_Key_Object_Method(
    void
) {
    Vm_Obj key  =             jS.s[ -5 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -4 ] );
    Vm_Obj ano  =             jS.s[ -3 ]  ;
    Vm_Obj cfn  =             jS.s[ -2 ]  ;
    Vm_Obj mtd  =             jS.s[ -1 ]  ;
    Vm_Obj obj  =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(5);
    job_Guarantee_Key_Arg(    -5 );
    job_Guarantee_Int_Arg(    -4 );
    job_Guarantee_Int_Arg(    -3 );
    job_Guarantee_Cfn_Arg(    -2 );
    job_Guarantee_Mtd_Arg(    -1 );
/*  job_Guarantee_Mos_Arg(     0 ); */
    job_Must_Control_Object(  -5 );
    {   Key_P s   = KEY_P( key );
        Vm_Obj* a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->objectmethods_len );
	Vm_Unt loc = OBJ_TO_UNT( s->objectmethods_loc );
        Key_Object_Method p;
	if (slot >= len) MUQ_WARN ("No such classmethod in this mosKey");
        p = (Key_Object_Method)(
            a + loc + slot*(sizeof(Key_A_Class_Method)/sizeof(Vm_Obj))
        );
	p->argument_number  = ano;
	p->generic_function = cfn;
	p->method           = mtd;
	p->object           = obj;
	vm_Dirty(key);
    }

    jS.s -= 6;
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Object_Method -- 				*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Object_Method(
    void
) {
    Vm_Obj ano  = OBJ_0;
    Vm_Obj cfn  = OBJ_NIL;
    Vm_Obj mtd  = OBJ_NIL;
    Vm_Obj obj  = OBJ_NIL;
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Int_Arg(     0 );
    {   Key_P s  = KEY_P( key );
        Vm_Obj*a = (Vm_Obj*) s;
	Vm_Unt len = OBJ_TO_UNT( s->objectmethods_len );
	Vm_Unt loc = OBJ_TO_UNT( s->objectmethods_loc );
        Key_Object_Method p;
	if (slot >= len) {
	    MUQ_WARN ("No such objectmethods slot in this mosKey");
	}
        p = (Key_Object_Method)(
            a + loc + slot*(sizeof(Key_A_Object_Method)/sizeof(Vm_Obj))
        );
	ano = p->argument_number;
	cfn = p->generic_function;
	mtd = p->method;
	obj = p->object;
    }

    jS.s += 2;
    jS.s[ -3 ] = ano;
    jS.s[ -2 ] = cfn;
    jS.s[ -1 ] = mtd;
    jS.s[  0 ] = obj;
}

 /***********************************************************************/
 /*-    job_P_Get_Lambda_Slot_Property -- 				*/
 /***********************************************************************/

void
job_P_Get_Lambda_Slot_Property(
    void
) {
    Vm_Obj result = OBJ_NIL;
    Vm_Obj lbd  =             jS.s[ -2 ]  ;
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );

    job_Guarantee_N_Args(3);
    job_Guarantee_Lbd_Arg(    -2 );
    job_Guarantee_Symbol_Arg( -1 );
    job_Guarantee_Int_Arg(     0 );

    {   Lbd_P s = LBD_P( lbd );
	Vm_Unt slots = OBJ_TO_UNT( s->total_args );
	if (slot >= slots) MUQ_WARN ("No such slot in this lambdaList");
	{   Lbd_Slot p = &s->slot[slot];
	    if        (key == job_Kw_Name) {
		result = p->name;
	    } else if (key == job_Kw_Initval) {
		result = p->initval;
	    } else if (key == job_Kw_Initform) {
		result = p->initform;
		if (result == OBJ_FROM_INT(0))   result = OBJ_NIL;
	    } else {
		MUQ_WARN ("No such property on lambdaList slots");
    }	}   }

    jS.s -= 2;
    *jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Get_Method_Slot -- 					*/
 /***********************************************************************/

void
job_P_Get_Method_Slot(
    void
) {
    Vm_Obj mtd  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );

    job_Guarantee_Mtd_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );

    {   Mtd_P s = MTD_P( mtd );
	Vm_Unt slots = OBJ_TO_UNT( s->required_args );
	if (slot >= slots) MUQ_WARN ("No such slot in this method");
	{   Mtd_Slot p = &s->slot[slot];
	    jS.s[  0 ] = p->arg;
	    /* Note that job_P_Methods_Match_P depends */
	    /* on the numbering scheme here:           */
	    switch (p->op) {
	    case OBJ_FROM_INT(0):   jS.s[ -1 ] = job_Kw_Eql;		break;
	    case OBJ_FROM_INT(1):   jS.s[ -1 ] = job_Kw_Is_A;		break;
	    case OBJ_FROM_INT(2):   jS.s[ -1 ] = OBJ_T;			break;
	    default:
		MUQ_FATAL("getMethodSlot");
	    }
    }	}
}

 /***********************************************************************/
 /*-    job_P_Set_Method_Slot -- 					*/
 /***********************************************************************/

void
job_P_Set_Method_Slot(
    void
) {
    Vm_Obj mtd  =             jS.s[ -3 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -2 ] );
    Vm_Obj op   =             jS.s[ -1 ]  ;
    Vm_Obj arg  =             jS.s[  0 ]  ;

    job_Guarantee_N_Args(4);
    job_Guarantee_Mtd_Arg(    -3 );
    job_Guarantee_Int_Arg(    -2 );
    job_Guarantee_Symbol_Arg( -1 );
    job_Must_Control_Object(  -3 );

    {   Mtd_P s = MTD_P( mtd );
	Vm_Unt slots = OBJ_TO_UNT( s->required_args );

	if (slot >= slots) MUQ_WARN ("No such slot in this method");
	{   Mtd_Slot p = &s->slot[slot];
	    if (op == OBJ_T) {
		p->op  = OBJ_FROM_INT(2);
	    	p->arg = arg;
	    } else if (op == job_Kw_Eql) {
		p->op  = OBJ_FROM_INT(0);
	    	p->arg = arg;
	    } else if (op == job_Kw_Is_A) {
		if (OBJ_IS_SYMBOL(arg)) arg = sym_Type(arg);
		if (!OBJ_IS_OBJ(arg) || !OBJ_IS_CLASS_CDF(arg)) {
		    MUQ_WARN(":instance arg must be a class");
		}
		/* Optimize class t to a no-op: */
		if (arg == obj_Lib_Muf_Class_T) {
		    p->op  = OBJ_FROM_INT(2);
		    p->arg = arg;
		} else {
		    p->op  = OBJ_FROM_INT(1);
		    p->arg = arg;
		}
	    } else {
		MUQ_WARN("setMethodSlot: op must be t :isA or :eql");
	    }
	    vm_Dirty(mtd);
    }	}

    jS.s -= 4;
}

 /***********************************************************************/
 /*-    job_Set_Mos_Key_Parent --	 				*/
 /***********************************************************************/

void
job_Set_Mos_Key_Parent(
    Vm_Obj key,
    Vm_Unt slot,
    Vm_Obj val
) {
    Key_P s   = KEY_P( key );
    Vm_Obj* a = (Vm_Obj*) s;
    Vm_Unt len = OBJ_TO_UNT( s->superclass_len );
    Vm_Unt loc = OBJ_TO_UNT( s->superclass_loc );
    if (slot >= len) MUQ_WARN ("No such parent slot in this mosKey");
    a[ loc + slot ] = val;
    vm_Dirty(key);
}

 /***********************************************************************/
 /*-    job_P_Set_Mos_Key_Parent --	 				*/
 /***********************************************************************/

void
job_P_Set_Mos_Key_Parent(
    void
) {
    Vm_Obj key  =             jS.s[ -2 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -1 ] );
    Vm_Obj val  =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(3);
    job_Guarantee_Key_Arg(    -2 );
    job_Guarantee_Int_Arg(    -1 );
    job_Guarantee_Cdf_Arg(     0 );
    job_Must_Control_Object(  -2 );

    /* Check for ancestor not owned or fertile: */
    {   Vm_Obj akey = CDF_P(val)->key;
	if (!OBJ_IS_OBJ(akey) || !OBJ_IS_CLASS_KEY(akey)) {
	    MUQ_WARN("Must define superclasses before their descendants");
	}
	{   Key_P k   = KEY_P( akey );
	    if (k->fertile == OBJ_NIL)   job_must_control( akey );
    }	}

    job_Set_Mos_Key_Parent( key, slot, val );

    jS.s -= 3;
}

 /***********************************************************************/
 /*-    job_P_Set_Mos_Key_Slot_Property -- 				*/
 /***********************************************************************/

void
job_P_Set_Mos_Key_Slot_Property(
    void
) {
    Vm_Obj key  =             jS.s[ -3 ]  ;
    Vm_Obj sym  =             jS.s[ -2 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -1 ] );
    Vm_Obj val  =             jS.s[  0 ]  ;

    job_Guarantee_N_Args(4);
    job_Guarantee_Key_Arg(    -3 );
    job_Guarantee_Symbol_Arg( -2 );
    job_Guarantee_Int_Arg(    -1 );
    job_Must_Control_Object(  -3 );

    {   Key_P k = KEY_P( key );
	Vm_Unt slots = OBJ_TO_UNT( k->total_slots );

	if (k->created_an_instance != OBJ_NIL) {
	    MUQ_WARN ("May not change slot prop after creating key instance");
	}

	if (slot >= slots) MUQ_WARN ("No such slot in this mosKey");
	{   Key_Slot p = &k->slot[slot];
	    if        (sym == job_Kw_Symbol) {
		if (OBJ_IS_SYMBOL(val)){
		    Key_Sym sa=(Key_Sym)(((Vm_Obj*)k)+OBJ_TO_INT(k->sym_loc));
		    sa[slot].symbol = val; vm_Dirty(key);
		}
	    } else if (sym == job_Kw_Initform) {
		if (val!=OBJ_NIL && !OBJ_IS_CFN(val)
		&& !(p->flags & KEY_FLAG_SHARED)
                ){
		    MUQ_WARN (
			":initform not NIL or compiledFn."
			"Did you want :initval?"
		    );
		}
		p->initform = val; vm_Dirty(key);
	    } else if (sym == job_Kw_Initval) {
		p->initval  = val; vm_Dirty(key);
	    } else if (sym == job_Kw_Type) {
		p->type = val; vm_Dirty(key);
	    } else if (sym == job_Kw_Documentation) {
		p->documentation = val; vm_Dirty(key);
	    } else if (sym == job_Kw_Get_Function) {
		if (OBJ_IS_CFN(val) || OBJ_IS_SYMBOL(val)) {
		    p->get_function = val; vm_Dirty(key);
		}
	    } else if (sym == job_Kw_Set_Function) {
		if (OBJ_IS_CFN(val) || OBJ_IS_SYMBOL(val)) {
		    p->set_function = val; vm_Dirty(key);
		}
	    } else if (sym == job_Kw_Root_May_Read) {
		if ((jS.j.privs & JOB_PRIVS_OMNIPOTENT)
		&&   OBJ_IS_CLASS_ROT(jS.j.acting_user)
		){
		    if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_ROOT_MAY_READ;
		    else		  p->flags |=  KEY_FLAG_ROOT_MAY_READ;
		    vm_Dirty(key);
		}
	    } else if (sym == job_Kw_Root_May_Write) {
		if ((jS.j.privs & JOB_PRIVS_OMNIPOTENT)
		&&   OBJ_IS_CLASS_ROT(jS.j.acting_user)
		){
		    if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_ROOT_MAY_WRITE;
		    else		  p->flags |=  KEY_FLAG_ROOT_MAY_WRITE;
		    vm_Dirty(key);
		}

	    } else if (sym == job_Kw_Inherited) {
		if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_INHERITED;
		else		      p->flags |=  KEY_FLAG_INHERITED;
		vm_Dirty(key);
	    } else if (sym == job_Kw_User_May_Read) {
		if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_USER_MAY_READ;
		else		      p->flags |=  KEY_FLAG_USER_MAY_READ;
		vm_Dirty(key);
	    } else if (sym == job_Kw_User_May_Write) {
		if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_USER_MAY_WRITE;
		else		      p->flags |=  KEY_FLAG_USER_MAY_WRITE;
		vm_Dirty(key);

	    } else if (sym == job_Kw_Class_May_Read) {
		if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_CLASS_MAY_READ;
		else		      p->flags |=  KEY_FLAG_CLASS_MAY_READ;
		vm_Dirty(key);
	    } else if (sym == job_Kw_Class_May_Write) {
		if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_CLASS_MAY_WRITE;
		else		      p->flags |=  KEY_FLAG_CLASS_MAY_WRITE;
		vm_Dirty(key);

	    } else if (sym == job_Kw_World_May_Read) {
		if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_WORLD_MAY_READ;
		else		      p->flags |=  KEY_FLAG_WORLD_MAY_READ;
		vm_Dirty(key);
	    } else if (sym == job_Kw_World_May_Write) {
		if (val == OBJ_NIL)   p->flags &= ~KEY_FLAG_WORLD_MAY_WRITE;
		else		      p->flags |=  KEY_FLAG_WORLD_MAY_WRITE;
		vm_Dirty(key);

	    } else if (sym == job_Kw_Allocation) {
#ifdef DUBIOUS
		if (val == job_Kw_Instance) {
		    p->flags &= ~KEY_FLAG_SHARED;
		} else	if (val == job_Kw_Class) {
		    p->flags |=  KEY_FLAG_SHARED;
		} else {
		    MUQ_WARN (":allocation must be :instance or :class");
		}
		vm_Dirty(key);
#else
		MUQ_WARN ("May not change :allocation of slot after creation");
#endif
	    } else {
		MUQ_WARN ("No such property on mosKey slots");
    }	}   }

    jS.s -= 4;
}

 /***********************************************************************/
 /*-    job_P_Set_Lambda_Slot_Property -- 				*/
 /***********************************************************************/

void
job_P_Set_Lambda_Slot_Property(
    void
) {
    Vm_Obj ldb  =             jS.s[ -3 ]  ;
    Vm_Obj key  =             jS.s[ -2 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[ -1 ] );
    Vm_Obj val  =             jS.s[  0 ]  ;

    job_Guarantee_N_Args(4);
    job_Guarantee_Lbd_Arg(    -3 );
    job_Guarantee_Symbol_Arg( -2 );
    job_Guarantee_Int_Arg(    -1 );
    job_Must_Control_Object(  -3 );

    {   Lbd_P s = LBD_P( ldb );
	Vm_Unt slots = OBJ_TO_UNT( s->total_args );


	if (slot >= slots) MUQ_WARN ("No such slot in this lambdaList");
	{   Lbd_Slot p = &s->slot[slot];
	    if        (key == job_Kw_Name) {
		p->name = val; vm_Dirty(ldb);
	    } else if (key == job_Kw_Initform) {
		if (val == OBJ_NIL) {
		    val = OBJ_FROM_INT(0);
		} else if (!OBJ_IS_CFN(val)) {
		    MUQ_WARN (":initform must be compiledFn or nil");
		}
		p->initform = val;
		vm_Dirty(ldb);
	    } else if (key == job_Kw_Initval) {
		p->initval  = val; vm_Dirty(ldb);
	    } else {
		MUQ_WARN ("No such property on lambdaList slots");
    }	}   }

    jS.s -= 4;
}

 /***********************************************************************/
 /*-    job_P_Apply_Lambda_List -- 					*/
 /***********************************************************************/

void
job_P_Apply_Lambda_List(
    void
) {
    Vm_Obj result[ LBD_MAX_SLOTS ];

    Vm_Obj lbd  =             jS.s[  0 ]  ;
    Vm_Obj blk  = OBJ_TO_BLK( jS.s[ -1 ] );

    /* Muf-coded version to handle initvals: */
    Vm_Obj sym  = obj_Lib_Muf_Apply_Lambda_List_Slowly;
    Vm_Obj cfn  = SYM_P(sym)->function;
	
    job_Guarantee_Blk_Arg(   -1 );
    job_Guarantee_Lbd_Arg(    0 );
    job_Guarantee_N_Args( blk+3 );

    /* Locate lambdaList: */
    {   Lbd_P l = LBD_P( lbd );
	Vm_Int req_args = OBJ_TO_INT( l->required_args );
	Vm_Int opt_args = OBJ_TO_INT( l->optional_args );
	Vm_Int kwd_args = OBJ_TO_INT( l->keyword_args  );
	Vm_Int kw_loc   = req_args + opt_args;
	Vm_Int kw_lim   = kw_loc + kwd_args;
        Vm_Int i;
        Vm_Int src = -1-blk;
        Vm_Int dst = 0;
	if (blk < req_args) MUQ_WARN("Missing required argument(s)");

	job_Guarantee_Headroom( kw_lim-blk );

	/* Accept all supplied required arguments: */
	for (i = 0;   i < req_args;   ++i) {
	    result[ dst++ ] = jS.s[ src++ ];
	}

	/* Accept all supplied optional arguments: */
	for (i = 0;   i < opt_args && src < -1;   ++i) {
	    result[ dst++ ] = jS.s[ src++ ];
	}

	/* Supply defaults for all missing optional arguments: */
	for (     ;   i < opt_args;   ++i) {

            Lbd_Slot s = &l->slot[ req_args + i ];

	    /* If initform provided, punt and */
	    /* let MUF version do everything: */
	    if (s->initform != OBJ_FROM_INT(0)
	    &&  OBJ_IS_CFN(cfn)
	    ){
		job_Call2(cfn);
		return;
	    }

	    result[ dst++ ] = s->initval;
	}

	/* Remember we've found no kw args yet: */
	{   Vm_Int j;
	    for (j = kw_loc;   j < kw_lim;   ++j) {
		result[j] = OBJ_NOT_FOUND;
	}   }

	/* Accept all supplied keyword arguments: */
	for (i = 0;   i < kwd_args && src < -2;   ++i) {

	    /* Read keyval pair: */
	    Vm_Obj key = jS.s[ src++ ];
	    Vm_Obj val = jS.s[ src++ ];

	    /* Find key in lambdaList: */
	    Vm_Int j;
	    for (j = kw_loc;   j < kw_lim;   ++j) {
		if (l->slot[j].name == key) {
		    if (result[j] == OBJ_NOT_FOUND)   result[j] = val;
		    break;
	}   }	}

	/* Provide defaults for all missing keyword arguments: */
	{   Vm_Int j;
	    for (j = kw_loc;   j < kw_lim;   ++j) {
		if (result[j] == OBJ_NOT_FOUND) {
                    Lbd_Slot s = &l->slot[j];

		    /* If initform provided, punt and */
		    /* let MUF version do everything: */
	            if (s->initform != OBJ_FROM_INT(0)
		    &&  OBJ_IS_CFN(cfn)
		    ){
			job_Call2(cfn);
			return;
		    }

		    result[j]  = s->initval;
    	}   }	}

	/* Pop all input except bottom '[': */
	jS.s -= blk+2;

	/* Push all results: */
	for (i = 0;   i < kw_lim;   ++i) {
	    *++jS.s = result[i];
    	}

	/* Complete block: */	
	*++jS.s = OBJ_FROM_BLK(kw_lim);
    }
}

 /***********************************************************************/
 /*-    job_P_Apply_Read_Lambda_List -- 				*/
 /***********************************************************************/

#undef  OPT_ARGS
#define OPT_ARGS 4
void
job_P_Apply_Read_Lambda_List(
    void
) {
    Vm_Obj result[ 4 ];

    Vm_Obj blk  = OBJ_TO_BLK( jS.s[ 0 ] );

    job_Guarantee_Blk_Arg(   0  );

    job_Guarantee_N_Args( blk+2 );
    if (blk > OPT_ARGS) MUQ_WARN("Extra read-lambda args");

    {   Vm_Int i;
        Vm_Int src = -blk;
        Vm_Int dst = 0;

	job_Guarantee_Headroom( 4 );

	/* Accept all supplied optional arguments: */
	for (i = 0;   i < OPT_ARGS && src < 0;   ++i) {
	    result[ dst++ ] = jS.s[ src++ ];
	}

	/* Supply defaults for all missing optional arguments: */
	if (i == 0) { result[0] = JOB_P(jS.job)->standard_input; ++i; }
	if (i == 1) { result[1] = OBJ_NIL;                       ++i; }
	if (i == 2) { result[2] = OBJ_NIL;                       ++i; }
	if (i == 3) { result[3] = OBJ_NIL;                       ++i; }

	/* Pop all input except bottom '[': */
	jS.s -= blk+1;

	/* Push all results: */
	*++jS.s = result[0];
	*++jS.s = result[1];
	*++jS.s = result[2];
	*++jS.s = result[3];

	/* Complete block: */	
	*++jS.s = OBJ_FROM_BLK(4);
    }
}
#undef  OPT_ARGS

 /***********************************************************************/
 /*-    job_P_Apply_Print_Lambda_List -- 				*/
 /***********************************************************************/

#undef  OPT_ARGS
#define OPT_ARGS 2
void
job_P_Apply_Print_Lambda_List(
    void
) {
    Vm_Obj result[ 2 ];

    Vm_Obj blk  = OBJ_TO_BLK( jS.s[ 0 ] );

    job_Guarantee_Blk_Arg(   0  );

    job_Guarantee_N_Args( blk+2 );
    if (blk < 1       ) MUQ_WARN("Missing print-lambda arg");
    if (blk > OPT_ARGS) MUQ_WARN("Extra print-lambda args");

    {   Vm_Int i;
        Vm_Int src = -blk;
        Vm_Int dst = 0;

	job_Guarantee_Headroom( 2 );

	/* Accept all supplied optional arguments: */
	for (i = 0;   i < OPT_ARGS && src < 0;   ++i) {
	    result[ dst++ ] = jS.s[ src++ ];
	}

	/* Supply defaults for all missing optional arguments: */
	if (i == 1) { result[1] = JOB_P(jS.job)->standard_output; ++i; }

	/* Pop all input except bottom '[': */
	jS.s -= blk+1;

	/* Push all results: */
	*++jS.s = result[0];
	*++jS.s = result[1];

	/* Complete block: */	
	*++jS.s = OBJ_FROM_BLK(2);
    }
}
#undef  OPT_ARGS

 /***********************************************************************/
 /*-    job_P_Mos_Key_Parents_Block --					*/
 /***********************************************************************/

void
job_P_Mos_Key_Parents_Block(
    void
) {
    Vm_Obj key = *jS.s;
    job_Guarantee_Key_Arg(0);
    job_Guarantee_Headroom( 1 + OBJ_TO_INT( KEY_P(key)->superclass_len ) );
    {   Vm_Obj* p;
	Vm_Int n = key_Parents_List( &p, key );
	Vm_Int i;

	*jS.s++ = OBJ_BLOCK_START;
	for  (i = 0;   i < n;   ++i)   *jS.s++ = p[i];
	*jS.s   = OBJ_FROM_BLK( n );
    }
}

 /***********************************************************************/
 /*-    job_P_Mos_Key_Unshared_Slots_Match_P --				*/
 /***********************************************************************/

static Vm_Int
mos_key_unshared_slots_match(
    Vm_Obj key0,
    Vm_Obj key1
) {
    Key_P k0;
    Key_P k1;
    Key_Slot s0;
    Key_Slot s1;
    Key_Sym  y0;
    Key_Sym  y1;
    Vm_Int i;
    vm_Loc2( (void**)&k0, (void**)&k1, key0, key1 );
    if (k0->unshared_slots != k1->unshared_slots) return FALSE;
    s0 = (Key_Slot)(&k0->slot[0]);
    s1 = (Key_Slot)(&k1->slot[0]);
    y0 = (Key_Sym) (((Vm_Obj*)k0) + OBJ_TO_INT(k0->sym_loc));
    y1 = (Key_Sym) (((Vm_Obj*)k1) + OBJ_TO_INT(k1->sym_loc));
    for (i = OBJ_TO_INT(k0->unshared_slots);   i --> 0;   ++s0, ++s1) {
	if (y0->symbol        != y1->symbol
	||  s0->initform      != s1->initform
	||  s0->initval       != s1->initval
	||  s0->type          != s1->type
    /*  ||  s0->documentation != s1->documentation	*/
	||  s0->flags         != s1->flags
    /*  ||  s0->get_function  != s1->get_function	*/
    /*  ||  s0->set_function  != s1->set_function	*/
	){
	    return FALSE;
	}
    }
    return TRUE;
}
void
job_P_Mos_Key_Unshared_Slots_Match_P(
    void
) {
    Vm_Obj key0 = jS.s[ -1 ];
    Vm_Obj key1 = jS.s[  0 ];
    if (OBJ_IS_OBJ(key0) && OBJ_IS_CLASS_CDF(key0)) key0 = CDF_P(key0)->key;
    if (OBJ_IS_OBJ(key1) && OBJ_IS_CLASS_CDF(key1)) key1 = CDF_P(key1)->key;
    if (!OBJ_IS_OBJ(key0)|| !OBJ_IS_CLASS_KEY(key0)) job_Guarantee_Cdf_Arg(-1);
    if (!OBJ_IS_OBJ(key1)|| !OBJ_IS_CLASS_KEY(key1)) job_Guarantee_Cdf_Arg( 0);
    *--jS.s = OBJ_FROM_BOOL( mos_key_unshared_slots_match(key0,key1) );
}

 /***********************************************************************/
 /*-    job_P_Mos_Key_Precedence_List_Block --				*/
 /***********************************************************************/

void
job_P_Mos_Key_Precedence_List_Block(
    void
) {
    Vm_Obj key = *jS.s;
    job_Guarantee_Key_Arg(0);
    job_Guarantee_Headroom( 1 + OBJ_TO_INT( KEY_P(key)->precedence_len ) );
    {   Key_Ancestor p;
	Vm_Int n = key_Ancestor_List( &p, key );
	Vm_Int i;

	*jS.s++ = OBJ_BLOCK_START;
	for  (i = 0;   i < n;   ++i)   *jS.s++ = p[i].ancestor;
	*jS.s   = OBJ_FROM_BLK( n );
    }
}

 /***********************************************************************/
 /*-    job_P_This_Mos_Class_P --					*/
 /***********************************************************************/

void
job_P_This_Mos_Class_P(
    void
) {
    Vm_Unt lim = KEY_MAX_INCLUDE_DEPTH;
    Vm_Obj is_a;
    Vm_Obj stc = jS.s[ -1 ];
    Vm_Obj key = jS.s[  0 ];
MUQ_WARN("unimplemented");
    job_Guarantee_Key_Arg(  0 );
/* buggo: Thunks aren't given a chance to cut in here. */
/* This is a general problem with the predicate fns.   */
    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
	is_a = EST_P(&len,stc)->is_a;
    } else if (OBJ_IS_STRUCT(stc)) {
        is_a = STC_P(stc)->is_a;
    } else {
	*--jS.s = OBJ_NIL;
	return;
    }
    while (is_a != key) {
	Key_P k    = KEY_P(is_a);
	Vm_Int loc = OBJ_TO_INT( k->superclass_loc );
	Vm_Int len = OBJ_TO_INT( k->superclass_len );
	if (len < 1) MUQ_WARN("No superclass");
	is_a = ((Vm_Obj*)(k))[loc];

	if (is_a == OBJ_NIL) {
	    *--jS.s = OBJ_NIL;
	    return;
        }
        /* Guard against malicious attempts    */
        /* to hang the server for a long time: */
	if (!--lim) MUQ_WARN ("Structure nesting too deep");
    }
    *--jS.s = OBJ_T;
}

 /***********************************************************************/
 /*-    job_P_Is_This_Mos_Class --					*/
 /***********************************************************************/

void
job_P_Is_This_Mos_Class(
    void
) {
    Vm_Unt lim = KEY_MAX_INCLUDE_DEPTH;
    Vm_Obj is_a;
    Vm_Obj stc = jS.s[ -1 ];
    Vm_Obj key = jS.s[  0 ];
MUQ_WARN("unimplemented");
    job_Guarantee_Key_Arg(  0 );
    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
	is_a = EST_P(&len,stc)->is_a;
    } else {
	job_Guarantee_Stc_Arg( -1 );
	is_a = STC_P(stc)->is_a;
    }
    while (is_a != key) {
	Key_P k    = KEY_P(is_a);
	Vm_Int loc = OBJ_TO_INT( k->superclass_loc );
	Vm_Int len = OBJ_TO_INT( k->superclass_len );
	if (len < 1) MUQ_WARN("No superclass");
	is_a = ((Vm_Obj*)(k))[loc];
	if (is_a == OBJ_NIL)   MUQ_WARN ("Wrong kind of object.E");
        /* Guard against malicious attempts    */
        /* to hang the server for a long time: */
	if (!--lim) MUQ_WARN ("Structure nesting too deep");
    }
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    CommonLisp support/library functions --				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_P_L_Read --		 					*/
  /**********************************************************************/

void
job_P_L_Read(
    void
) {
    Vm_Obj readtable    = JOB_P(jS.job)->readtable;
    Vm_Obj input_stream = JOB_P(jS.job)->standard_input;
    Vm_Obj eof_error_p  = OBJ_NIL;
    Vm_Obj eof_value_p  = OBJ_NIL;
    Vm_Obj recursive_p  = OBJ_NIL;
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_Blk_Arg(              0 );
    job_Guarantee_N_Args(    block_size+2 );
    switch (block_size) {
    case 4:    recursive_p  = jS.s[ 3-block_size ];
    case 3:    eof_value_p  = jS.s[ 2-block_size ];
    case 2:    eof_error_p  = jS.s[ 1-block_size ];
    case 1:    input_stream = jS.s[ 0-block_size ];
    }
    if (input_stream == OBJ_NIL)  input_stream = JOB_P(jS.job)->standard_input;
    if (input_stream == OBJ_T)    input_stream = JOB_P(jS.job)->terminal_io;
    if (!OBJ_IS_OBJ(input_stream) || !OBJ_IS_CLASS_MSS(input_stream)) {
	MUQ_WARN("read: bad inputStream");
    }
    input_stream = job_Will_Read_Message_Stream( input_stream );
    readtable = readtable; /* Just to quiet compilers. */
MUQ_WARN("Unimplemented");
}

 /***********************************************************************/
 /*-    job_P_Copy_Structure -- 					*/
 /***********************************************************************/

void
job_P_Copy_Structure(
    void
) {
/* buggo, need to do field-by-field privilege */
/* checking here, I think, to prevent people  */
/* from accessing forbidden fields just by    */
/* copying a structure.                       */
    Vm_Obj result;
    Vm_Obj stc = jS.s[ -1 ];
    Vm_Obj cdf = jS.s[  0 ];
    if (OBJ_IS_EPHEMERAL_STRUCT(jS.s[-1])) {
	if (cdf != OBJ_NIL) {
	    Vm_Int len;
	    job_Guarantee_Cdf_Arg( 0 );
	    if (EST_P(&len,stc)->is_a != CDF_P(cdf)->key) {
		MUQ_WARN ("Wrong kind of object for this fn");
	    }
	}
	result  = stc_Dup_Est( stc );
    } else {
        job_Guarantee_Stc_Arg( -1 );
	if (cdf != OBJ_NIL) {
	    job_Guarantee_Cdf_Arg( 0 );
	    if (STC_P(stc)->is_a != CDF_P(cdf)->key) {
		MUQ_WARN ("Wrong kind of object for this fn");
	    }
	}
	result  = stc_Dup( stc );
    }
    *--jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Copy_Structure_Contents --				*/
 /***********************************************************************/

void
job_P_Copy_Structure_Contents(
    void
) {
/* buggo, need to do field-by-field privilege */
/* checking here, I think, to prevent people  */
/* from accessing forbidden fields just by    */
/* copying a structure.                       */
    static Vm_Chr* err = "copyStructureContents: Incompatible src & dst";
    Vm_Obj dst = jS.s[ -1 ];
    Vm_Obj src = jS.s[  0 ];
    Vm_Int srclen;
    Vm_Int dstlen;
    Vm_Int i;
    if     (OBJ_IS_EPHEMERAL_STRUCT(dst)) {
        if (OBJ_IS_EPHEMERAL_STRUCT(src)) {
    	    Est_P s = EST_P(&srclen,src);	    
    	    Est_P d = EST_P(&dstlen,dst);	    
	    if (s->is_a != d->is_a
	    ||  srclen  != dstlen
	    ){
		MUQ_WARN (err);
	    }
	    for (i = 0;   i < srclen;   ++i)   d->slot[i] = s->slot[i];
	    /* No need to dirty an emphemeral structure. */

	} else {
	    job_Guarantee_Stc_Arg( 0 );
	    srclen = stc_Len( src );
    	    {   Stc_P s = STC_P(        src);	/* Must do STC_P b4 EST_P */
    	        Est_P d = EST_P(&dstlen,dst);	    
	        if (s->is_a != d->is_a
	        ||  srclen  != dstlen
	        ){
		    MUQ_WARN (err);
	        }
		for (i = 0;   i < srclen;   ++i)   d->slot[i] = s->slot[i];
		/* No need to dirty an emphemeral structure. */
	    }
	}
    } else {
	job_Guarantee_Stc_Arg( -1 );
        if (OBJ_IS_EPHEMERAL_STRUCT(src)) {
	    dstlen = stc_Len( dst );
    	    {   Stc_P d = STC_P(        dst);	/* Must do STC_P b4 EST_P */
    	        Est_P s = EST_P(&srclen,src);	    
		if (s->is_a != d->is_a
		||  srclen  != dstlen
		){
		    MUQ_WARN (err);
		}
		for (i = 0;   i < srclen;   ++i)   d->slot[i] = s->slot[i];
		vm_Dirty(dst);
	    }
	} else {
	    job_Guarantee_Stc_Arg( 0 );
	    srclen = stc_Len( src );
	    dstlen = stc_Len( dst );
	    {   Stc_P s;
		Stc_P d;
		vm_Loc2( (void**)&s, (void**)&d, src, dst );
		if (s->is_a != d->is_a
		||  srclen  != dstlen
		){
		    MUQ_WARN (err);
		}
		for (i = 0;   i < srclen;   ++i)   d->slot[i] = s->slot[i];
		vm_Dirty(dst);
	    }
	}
    }
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Error_If_Ephemeral -- 					*/
 /***********************************************************************/

void
job_P_Error_If_Ephemeral(
    void
) {
    Vm_Int len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args( len+2 );
    if (len >= 2
    &&  jS.s[  -len ] == job_Kw_Ephemeral
    &&  jS.s[ 1-len ] != OBJ_NIL
    ){
	MUQ_WARN (
	    ":ephemeral t won't work here; "
            "Call ]makeStructure/list/&tc directly."
        );
    }
}

 /***********************************************************************/
 /*-    job_find_mos_key_slot -- 					*/
 /***********************************************************************/

static Vm_Int
job_find_mos_key_slot(
    Vm_Obj key,
    Vm_Obj sym
) {
    Key_P s = KEY_P( key );
    Vm_Int slots = OBJ_TO_INT( s->total_slots );
    Key_Sym sa = (Key_Sym)(((Vm_Obj*)s) + OBJ_TO_INT(s->sym_loc));
    Vm_Int i;
    for (i = 0;   i < slots;  ++i) {
	if (sa[i].symbol == sym)   return i;
    }
    return -1;
}

 /***********************************************************************/
 /*-    job_P_Find_Mos_Key_Slot -- 					*/
 /***********************************************************************/

void
job_P_Find_Mos_Key_Slot(
    void
) {
    Vm_Obj key  =             jS.s[ -1 ]  ;
    Vm_Obj sym  =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(2);
    job_Guarantee_Key_Arg(    -1 );
    job_Guarantee_Symbol_Arg(  0 );
    {   Vm_Int i = job_find_mos_key_slot( key, sym );
	if (i == -1)  *--jS.s = OBJ_NIL;
	else          *--jS.s = OBJ_FROM_INT(i);
    }
}

 /***********************************************************************/
 /*-    job_P_Get_Nth_Structure_Slot --					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_Read_Structure_Slot -- 					*/
  /**********************************************************************/

Vm_Int
job_Read_Structure_Slot(
    Vm_Obj* val,
    Vm_Obj  stc,
    Vm_Unt  slot
){
    Vm_Obj key;
    Vm_Unt flags;
    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;

	Vm_Unt slots;
	Vm_Unt author;
	key = EST_P(&len,stc)->is_a;
	{   Key_P  k   = KEY_P(key);
	    slots  = OBJ_TO_UNT( k->total_slots      );
	    flags  =             k->slot[slot].flags  ;
	    author =             obj_Owner(key)       ;
	}

	if (slot >= slots) {
	    MUQ_WARN ("No slot %d in object", (int)slot );
	}

	/* Is acting user allowed to read this slot? */
	if (  (flags & KEY_FLAG_WORLD_MAY_READ)

	|| (  (flags & KEY_FLAG_CLASS_MAY_READ)
	   && jS.j.acting_user == author)

	|| (  (flags & KEY_FLAG_ROOT_MAY_READ)
	   && (jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	   && OBJ_IS_CLASS_ROT(jS.j.acting_user))

	|| (  (flags & KEY_FLAG_USER_MAY_READ)
	   && (  (  !(flags & KEY_FLAG_SHARED)
	         && (EST_P(&len,stc)->owner == jS.j.acting_user))
	      || (   (flags & KEY_FLAG_SHARED)
	         && (obj_Owner(key)         == jS.j.acting_user))
	   )  )
        ){
	    /* Acting user may read slot; */
	    /* Where -is- the slot?       */
	    if (!(flags & KEY_FLAG_SHARED)) {

		/* Slot is in structure: */
	        *val = EST_P(&len,stc)->slot[slot];
	        return TRUE;
	    }
	    /* Fall through to shared-slot code. */

	} else {

	    return FALSE;
	}

    } else {

	Vm_Unt slots;
	Vm_Unt author;
	key = STC_P(stc)->is_a;
	{   Key_P  k   = KEY_P(key);
	    slots  = OBJ_TO_UNT( k->total_slots      );
	    flags  =             k->slot[slot].flags  ;
	    author =             obj_Owner(key)       ;
	}

	if (slot >= slots) {
	    MUQ_WARN ("No slot %d in object", (int)slot );
	}

	if (  (flags & KEY_FLAG_WORLD_MAY_READ)

	|| (  (flags & KEY_FLAG_CLASS_MAY_READ)
	   && (jS.j.acting_user == author))


	|| (  (flags & KEY_FLAG_ROOT_MAY_READ)
	   && (jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	   && OBJ_IS_CLASS_ROT(jS.j.acting_user))

	|| (  (flags & KEY_FLAG_USER_MAY_READ)
	   && (  (  !(flags & KEY_FLAG_SHARED)
	         && (obj_Owner(stc)      == jS.j.acting_user))
	      || (   (flags & KEY_FLAG_SHARED)

	         && (obj_Owner(key)      == jS.j.acting_user))
	   )  )
        ){
	    /* Acting user may read slot; */
	    /* Where -is- the slot?       */
	    if (!(flags & KEY_FLAG_SHARED)) {

		*val = STC_P(stc)->slot[slot];
		return TRUE;
	    }
	    /* Fall through to shared-slot code. */

	} else {
	    return FALSE;
	}
    }

    /* Shared slot.  If it is not inherited, */
    /* value is in the initval field:        */
    if (!(flags & KEY_FLAG_INHERITED)) {
        *val = KEY_P(key)->slot[slot].initval;
	return TRUE;
    }

    /* Inherited, shared slot: */
    {   Key_P  k     = KEY_P(key);
	Vm_Obj key2  = k->slot[slot].initval;
	Vm_Obj slot2 = k->slot[slot].initform;
	Vm_Unt s2    = OBJ_TO_UNT(slot2);
	if (!OBJ_IS_OBJ(key2) || !OBJ_IS_CLASS_KEY(key2)) {
	    MUQ_WARN("Inherited shared slot not on a mosKey?!");
	}
	k = KEY_P(key2);
	if (!OBJ_IS_INT(slot2)) {
	    MUQ_WARN("Inherited shared slot number not a fixnum");
	}
	if (s2 >= OBJ_TO_UNT(k->total_slots)) {
	    MUQ_WARN("Inherited shared slot number out of range");
	}
	flags  = k->slot[s2].flags;
	if (!(flags & KEY_FLAG_SHARED)) {
	    MUQ_WARN("Inherited shared slot not actually shared");
	}

	/* Same privilege checking on new slot: */
	if (  (flags & KEY_FLAG_WORLD_MAY_READ)

	|| (  (flags & KEY_FLAG_CLASS_MAY_READ)
	   && (jS.j.acting_user == obj_Owner(key)))


	|| (  (flags & KEY_FLAG_ROOT_MAY_READ)
	   && (jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	   && OBJ_IS_CLASS_ROT(jS.j.acting_user))

	|| (  (flags & KEY_FLAG_USER_MAY_READ)
	   && (jS.j.acting_user == obj_Owner(key)))

        ){
	    *val = k->slot[s2].initval;
	    return TRUE;
	}
	return FALSE;
    }
}

  /**********************************************************************/
  /*-   job_Write_Structure_Slot -- 					*/
  /**********************************************************************/

Vm_Int
job_Write_Structure_Slot(
    Vm_Obj stc,
    Vm_Unt slot,
    Vm_Obj val
){
    Vm_Unt flags;
    Vm_Obj key;
    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
	Vm_Unt slots;
	Vm_Unt author;
	key = EST_P(&len,stc)->is_a;
	{   Key_P  k   = KEY_P(key);
	    slots  = OBJ_TO_UNT( k->total_slots      );
	    flags  =             k->slot[slot].flags  ;
	    author =             obj_Owner(key)       ;
	}

	if (slot >= slots) {
	    MUQ_WARN ("Can't write slot %d in %d-slot object", (int)slot, (int)slots );
	}

	if (   (flags & KEY_FLAG_WORLD_MAY_WRITE)

	|| (   (flags & KEY_FLAG_CLASS_MAY_WRITE)
	   &&  (jS.j.acting_user == author))

	|| (   (flags & KEY_FLAG_ROOT_MAY_WRITE)
	   &&  (jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	   &&  OBJ_IS_CLASS_ROT(jS.j.acting_user))

	|| (   (flags & KEY_FLAG_USER_MAY_WRITE)
	   && (  (  !(flags & KEY_FLAG_SHARED)
	         && (EST_P(&len,stc)->owner == jS.j.acting_user))
	      || (   (flags & KEY_FLAG_SHARED)
	         && (obj_Owner(key)         == jS.j.acting_user))))
	){
	    /* Acting user may read slot; */
	    /* Where -is- the slot?       */
	    if (!(flags & KEY_FLAG_SHARED)) {

		EST_P(&len,stc)->slot[ slot ] = val;
		return TRUE;
	    }
	    /* Fall through to shared-slot code. */
	} else {

	    return FALSE;
	}

    } else {

	Vm_Unt slots;
	Vm_Unt author;
	key = STC_P(stc)->is_a;
	{   Key_P  k   = KEY_P(key);
	    slots  = OBJ_TO_UNT( k->total_slots      );
	    flags  =             k->slot[slot].flags  ;
	    author =             obj_Owner(key)       ;
	}

	if (slot >= slots) {
	    MUQ_WARN ("Can't write slot %d in %d-slot object", (int)slot, (int)slots );
	}

	if (  (flags & KEY_FLAG_WORLD_MAY_WRITE)

	|| (  (flags & KEY_FLAG_CLASS_MAY_WRITE)
	   && jS.j.acting_user == author)

	|| (  (flags & KEY_FLAG_ROOT_MAY_WRITE)
	   && (jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	   && OBJ_IS_CLASS_ROT(jS.j.acting_user))

	|| (  (flags & KEY_FLAG_USER_MAY_WRITE)
	   && (  (  !(flags & KEY_FLAG_SHARED)
	         && (obj_Owner(stc)      == jS.j.acting_user))
	      || (   (flags & KEY_FLAG_SHARED)
	         && (obj_Owner(key)      == jS.j.acting_user))
	   )  )
	){
	    /* Acting user may read slot; */
	    /* Where -is- the slot?       */
	    if (!(flags & KEY_FLAG_SHARED)) {

		STC_P(stc)->slot[ slot ] = val;   vm_Dirty(stc);
		return TRUE;
	    }
	    /* Fall through to shared-slot code. */

	} else {
	    return FALSE;
	}
    }

    /* Shared slot.  If it is not inherited, */
    /* value goes in the initval field:      */
    if (!(flags & KEY_FLAG_INHERITED)) {
        KEY_P(key)->slot[slot].initval = val;
	vm_Dirty(key);
	return TRUE;
    }

    /* Inherited, shared slot: */
    {   Key_P  k     = KEY_P(key);
	Vm_Obj key2  = k->slot[slot].initval;
	Vm_Obj slot2 = k->slot[slot].initform;
	Vm_Unt s2    = OBJ_TO_UNT(slot2);
	if (!OBJ_IS_OBJ(key2) || !OBJ_IS_CLASS_KEY(key2)) {
	    MUQ_WARN("Inherited shared slot not on a mosKey?!");
	}
	k = KEY_P(key2);
	if (!OBJ_IS_INT(slot2)) {
	    MUQ_WARN("Inherited shared slot number not a fixnum");
	}
	if (s2 >= OBJ_TO_UNT(k->total_slots)) {
	    MUQ_WARN("Inherited shared slot number out of range");
	}
	flags  = k->slot[s2].flags;
	if (!(flags & KEY_FLAG_SHARED)) {
	    MUQ_WARN("Inherited shared slot not actually shared");
	}

	/* Same privilege checking on new slot: */
	if (  (flags & KEY_FLAG_WORLD_MAY_WRITE)

	|| (  (flags & KEY_FLAG_CLASS_MAY_WRITE)
	   && (jS.j.acting_user == obj_Owner(key)))


	|| (  (flags & KEY_FLAG_ROOT_MAY_WRITE)
	   && (jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	   && OBJ_IS_CLASS_ROT(jS.j.acting_user))

	|| (  (flags & KEY_FLAG_USER_MAY_WRITE)
	   && (jS.j.acting_user == obj_Owner(key)))

        ){
	    k->slot[s2].initval = val;
	    vm_Dirty(key2);
	    return TRUE;
	}

	return FALSE;
    }
}

  /**********************************************************************/
  /*-   validate_struct		 					*/
  /**********************************************************************/

static void
validate_struct(
    Vm_Obj needed_cdf,
    Vm_Obj object_key
) {
    /* Verify that needed_cdf is somewhere on   */
    /* the class precedence list of struct_key: */

    Key_P k    = KEY_P(object_key);
    Vm_Int loc = OBJ_TO_INT( k->precedence_loc );
    Vm_Int len = OBJ_TO_INT( k->precedence_len );
    Vm_Int i;
    Key_Ancestor a = (Key_Ancestor)(((Vm_Obj*)k)+loc);
    /* It's fun to unwind a loop now and then, */
    /* and this fn is called pretty often, so: */
    for (i = len;   i > 8;   i -= 8, a += 8) {
	/* It used to be fastest to increment 'a'  */
	/* at each step in this sort of stuff, but */
	/* I expect today's CPUs prefer explicit   */
	/* constant indices like this, to decrease */
	/* dependencies and facilitate parallelism:*/
	if (a[0].ancestor == needed_cdf)   return;
	if (a[1].ancestor == needed_cdf)   return;
	if (a[2].ancestor == needed_cdf)   return;
	if (a[3].ancestor == needed_cdf)   return;
	if (a[4].ancestor == needed_cdf)   return;
	if (a[5].ancestor == needed_cdf)   return;
	if (a[6].ancestor == needed_cdf)   return;
	if (a[7].ancestor == needed_cdf)   return;
    }
    for (       ;   i > 0;   --i, ++a) {
	if (a->ancestor == needed_cdf)   return;
    }
    MUQ_WARN ("Wrong kind of object.");
}

 /***********************************************************************/
 /*-    job_P_Is_This_Structure --					*/
 /***********************************************************************/

void
job_P_Is_This_Structure(
    void
) {
    Vm_Obj is_a;
    Vm_Obj stc = jS.s[ -1 ];
    Vm_Obj cdf = jS.s[  0 ];
    job_Guarantee_Cdf_Arg(  0 );
    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
	is_a = EST_P(&len,stc)->is_a;
    } else {
	job_Guarantee_Stc_Arg( -1 );
	is_a = STC_P(stc)->is_a;
    }
    validate_struct( cdf, is_a );
    jS.s -= 2;
}

  /**********************************************************************/
  /*-   job_Maybe_Update_Struct	 					*/
  /**********************************************************************/

#ifndef JOB_MAX_OBJ_INDIRECTS
#define JOB_MAX_OBJ_INDIRECTS 128
#endif

Vm_Obj
job_Maybe_Update_Struct(
    Vm_Obj stc
) {
    /* This loop is mainly to prevent the server */
    /* from hanging indefinitely when presented  */
    /* with an arbitrarily long (or circular!)   */
    /* chain of key%s/newerKey links:           */
    Vm_Int max_indirects;
    for (max_indirects = JOB_MAX_OBJ_INDIRECTS;   max_indirects --> 0; ) {

	/**************************************************/
	/* Our job here is to handle any updates required */
	/* by a change in the class for this object.      */
	/*						      */
	/* If there has been such a change, then          */
	/*     stc->is_a				      */
	/* will give the old mosKey for the class, and   */
	/*     stc->is_a->newer_key			      */
	/* will point to the updated mosKey -- instead   */
	/* of being NIL, as it normally is.               */
	/**************************************************/

	Vm_Obj old_key = STC_P( stc )->is_a;
	Vm_Obj new_key;

	/* Sanity check: */
	if (!OBJ_IS_OBJ(old_key) || !OBJ_IS_CLASS_KEY(old_key)) {
	    /* This should not be possible: */
	    MUQ_WARN("job_Maybe_Update_Struct internal err0");
	}

	/* If no newer key, we're done: */
	new_key = KEY_P(old_key)->newer_key;
	if (new_key == OBJ_NIL)   return stc;

	/* Same sanity check: */
	if (!OBJ_IS_OBJ(new_key) || !OBJ_IS_CLASS_KEY(new_key)) {
	    MUQ_WARN("job_Maybe_Update_Struct internal err1");
	}

	/* If the slot info hasn't changed (usually means that a */
	/* method has been added or removed) then we can just    */
	/* update the isA pointer in the struct without needing */
	/* to change slot contents around:                       */
	{   Key_P old;
	    Key_P new;
	    vm_Loc2( (void**)&old, (void**)&new, old_key, new_key );
	    if (old->unshared_slots == new->unshared_slots) {
		Vm_Int i = OBJ_TO_INT( old->unshared_slots);
		Key_Sym os=(Key_Sym)(((Vm_Obj*)old)+OBJ_TO_INT(old->sym_loc));
		Key_Sym ns=(Key_Sym)(((Vm_Obj*)new)+OBJ_TO_INT(new->sym_loc));
		for (;;) {
		    if (--i == -1) {

			/* Slot names all match, so */
			/* update isA and loop:    */
			STC_P(stc)->is_a = new_key;
			vm_Dirty(stc);
			break;
		    }
		    if (ns[i].symbol != os[i].symbol) break;
		}
		if (i == -1)   continue; /* C lacks two-level 'continue'...*/
	    }

	    /* Heh... need to actually re-arrange the slots some. *pout* */
MUQ_WARN("sorry, dunno how to do real struct updates yet.");
	}
    }

    MUQ_WARN ("Maximum object indirects exceeded!");

    return stc; /* Just to quiet compilers. */
}

  /**********************************************************************/
  /*-   this_struct_p		 					*/
  /**********************************************************************/

static Vm_Int
this_struct_p(
    Vm_Obj needed_cdf,
    Vm_Obj object_key
) {
    /* Verify that needed_cdf is somewhere on   */
    /* the class precedence list of object_key: */

    Key_P k    = KEY_P(object_key);
    Vm_Int loc = OBJ_TO_INT( k->precedence_loc );
    Vm_Int len = OBJ_TO_INT( k->precedence_len );
    Vm_Int i;
    Key_Ancestor a = (Key_Ancestor)(((Vm_Obj*)k)+loc);
    for (i = 0;   /* i < len */;   ++i) {
	if (i == len) return FALSE;
	if (a[i].ancestor == needed_cdf)   return TRUE;
    }
}

 /***********************************************************************/
 /*-    job_P_This_Structure_P --					*/
 /***********************************************************************/

void
job_P_This_Structure_P(
    void
) {
    Vm_Obj is_a;
    Vm_Obj stc = jS.s[ -1 ];
    Vm_Obj cdf = jS.s[  0 ];
    job_Guarantee_Cdf_Arg(  0 );
/* buggo: Thunks aren't given a chance to cut in here. */
/* This is a general problem with the predicate fns.   */
    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
	is_a = EST_P(&len,stc)->is_a;
    } else if (OBJ_IS_STRUCT(stc)) {
        is_a = STC_P(stc)->is_a;
    } else {
	*--jS.s = OBJ_NIL;
	return;
    }
    *--jS.s = OBJ_FROM_BOOL( this_struct_p( cdf, is_a ) );
}

 /***********************************************************************/
 /*-    job_P_Subclass_Of_P --						*/
 /***********************************************************************/

void
job_P_Subclass_Of_P(
    void
) {
    Vm_Obj sub = jS.s[ -1 ];
    Vm_Obj sup = jS.s[  0 ];

    job_Guarantee_Cdf_Arg(  0 );
    job_Guarantee_Cdf_Arg( -1 );
/* buggo: Thunks aren't given a chance to cut in here. */
/* This is a general problem with the predicate fns.   */
    {   Vm_Obj subkey = CDF_P(sub)->key;
	if (!OBJ_IS_OBJ(subkey) || !OBJ_IS_CLASS_KEY(subkey)) {
	    MUQ_WARN("subclassOf? subclass->key is not a Key instance");
	}
        *--jS.s = OBJ_FROM_BOOL( this_struct_p( sup, subkey ) );
    }
}

  /**********************************************************************/
  /*-   job_P_Get_Nth_Structure_Slot -- 				*/
  /**********************************************************************/

void
job_P_Get_Nth_Structure_Slot(
    void
) {
    Vm_Obj stc  =             jS.s[ -2 ]  ;
    Vm_Obj cdf  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );

    job_Guarantee_N_Args(3);
/*  job_Guarantee_Cdf_Arg( -1 );	<- Redundant. */
    job_Guarantee_Int_Arg(  0 );

    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
        Vm_Obj is_a = EST_P( &len, stc )->is_a;
	Vm_Obj val;
	/* Note: We deliberately don't worry about updating   */
	/* ephmeral structs.  This would be a significant     */
	/* amount of extra coding effort, and we presume that */
	/* their lifetime is so short that they can keep on   */
	/* using the old mosKey without undue problem.	      */
	if (cdf != OBJ_NIL)   validate_struct( cdf, is_a );
	if (!job_Read_Structure_Slot( &val, stc, slot )) {
	    MUQ_WARN ("You may not read that slot");
	}
	jS.s -= 2;
       *jS.s  = val;
    } else {
        job_Guarantee_Stc_Arg( -2 );
	stc = job_Maybe_Update_Struct( stc );
        {   Vm_Obj is_a = STC_P( stc )->is_a;
	    Vm_Obj val;
	    if (cdf != OBJ_NIL)   validate_struct( cdf, is_a );
	    if (!job_Read_Structure_Slot( &val, stc, slot )) {
		MUQ_WARN ("You may not read that slot");
	    }
	    jS.s -= 2;
	   *jS.s  = val;
	}
    }
}

  /**********************************************************************/
  /*-   job_P_Get_Named_Structure_Slot -- 				*/
  /**********************************************************************/

void
job_P_Get_Named_Structure_Slot(
    void
) {
    Vm_Obj stc  = jS.s[ -2 ];
    Vm_Obj cdf  = jS.s[ -1 ];
    Vm_Obj sym  = jS.s[  0 ];

    job_Guarantee_N_Args(3);
/*  job_Guarantee_Cdf_Arg( -1 );	<- Redundant. */
    job_Guarantee_Symbol_Arg(  0 );

    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
        Vm_Obj is_a = EST_P( &len, stc )->is_a;
	Vm_Obj val;
	/* Note: We deliberately don't worry about updating   */
	/* ephmeral structs.  This would be a significant     */
	/* amount of extra coding effort, and we presume that */
	/* their lifetime is so short that they can keep on   */
	/* using the old mosKey without undue problem.	      */
	if (cdf != OBJ_NIL)   validate_struct( cdf, is_a );


#ifdef CRIB
	{   Key_P s = KEY_P( is_a );
	    Vm_Int slots = OBJ_TO_INT( s->total_slots );
	    Key_Sym sa = (Key_Sym)(((Vm_Obj*)s) + OBJ_TO_INT(s->sym_loc));
	    Vm_Int i;
	    for (i = 0;   /* i < slots*/;  ++i) {
		if (i == slots) {
		    MUQ_WARN("getNamedStructureSlot: no such slot");
		}
		if (sa[i].symbol == sym)   break;
	    }
	    if (i < OBJ_TO_INT(s->unshared_slots)) {
	    }

#endif
	{   Vm_Int slot = job_find_mos_key_slot( is_a, sym );
	    if (slot == -1) {
		MUQ_WARN("getNamedStructureSlot: no such slot");
	    }
	    if (!job_Read_Structure_Slot( &val, stc, slot )) {
		MUQ_WARN ("You may not read that slot");
	    }
	    jS.s -= 2;
	   *jS.s  = val;
	}
    } else {
        job_Guarantee_Stc_Arg( -2 );
	stc = job_Maybe_Update_Struct( stc );
        {   Vm_Obj is_a = STC_P( stc )->is_a;
	    Vm_Obj val;
	    if (cdf != OBJ_NIL)   validate_struct( cdf, is_a );
	    {   Vm_Int slot = job_find_mos_key_slot( is_a, sym );
		if (slot == -1) {
		    MUQ_WARN("getNamedStructureSlot: no such slot");
		}
		if (!job_Read_Structure_Slot( &val, stc, slot )) {
		    MUQ_WARN ("You may not read that slot");
		}
		jS.s -= 2;
	       *jS.s  = val;
	    }
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Set_Named_Structure_Slot -- 				*/
 /***********************************************************************/

void
job_P_Set_Named_Structure_Slot(
    void
) {
    Vm_Obj stc  = jS.s[ -3 ]  ;
    Vm_Obj val  = jS.s[ -2 ]  ;
    Vm_Obj cdf  = jS.s[ -1 ]  ;
    Vm_Obj sym  = jS.s[  0 ];

    job_Guarantee_N_Args(4);
/*  job_Guarantee_Cdf_Arg(    -1 );	<- Redundant. */
    job_Guarantee_Symbol_Arg(  0 );

    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
        Vm_Obj is_a = EST_P( &len, stc )->is_a;
	if (cdf != OBJ_NIL)   validate_struct( cdf, is_a );
	{   Vm_Int slot = job_find_mos_key_slot( is_a, sym );
	    if (slot == -1) {
		MUQ_WARN("setNamedStructureSlot: no such slot");
	    }
	    if (!job_Write_Structure_Slot( stc, slot, val )) {
		MUQ_WARN ("You may not write that slot");
	    }
	    jS.s -= 4;
	}
    } else {
        job_Guarantee_Stc_Arg( -3 );
	stc = job_Maybe_Update_Struct( stc );
        {   Vm_Obj is_a = STC_P( stc )->is_a;
	    if (cdf != OBJ_NIL)   validate_struct( cdf, is_a );
	    {   Vm_Int slot = job_find_mos_key_slot( is_a, sym );
		if (slot == -1) {
		    MUQ_WARN("setNamedStructureSlot: no such slot");
		}
		if (!job_Write_Structure_Slot( stc, slot, val )) {
		    MUQ_WARN ("You may not write that slot");
		}
		jS.s -= 4;
	    }
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Set_Nth_Structure_Slot -- 				*/
 /***********************************************************************/

void
job_P_Set_Nth_Structure_Slot(
    void
) {
    Vm_Obj stc  =             jS.s[ -3 ]  ;
    Vm_Obj val  =             jS.s[ -2 ]  ;
    Vm_Obj cdf  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );

    job_Guarantee_N_Args(4);
/*  job_Guarantee_Cdf_Arg( -1 );	<- Redundant. */
    job_Guarantee_Int_Arg(  0 );

    if (OBJ_IS_EPHEMERAL_STRUCT(stc)) {
	Vm_Int len;
        Vm_Obj is_a = EST_P( &len, stc )->is_a;
	if (cdf != OBJ_NIL)   validate_struct( cdf, is_a );
	if (!job_Write_Structure_Slot( stc, slot, val )) {
	    MUQ_WARN ("You may not write that slot");
	}
	jS.s -= 4;
    } else {
        job_Guarantee_Stc_Arg( -3 );
	stc = job_Maybe_Update_Struct( stc );
        {   Vm_Obj is_a = STC_P( stc )->is_a;
	    if (cdf != OBJ_NIL)   validate_struct( cdf, is_a );
	    if (!job_Write_Structure_Slot( stc, slot, val )) {
		MUQ_WARN ("You may not write that slot");
	    }
	    jS.s -= 4;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key_Slot_Property -- 				*/
 /***********************************************************************/

void
job_P_Get_Mos_Key_Slot_Property(
    void
) {
    Vm_Obj result = OBJ_NIL;
    Vm_Obj key  =             jS.s[ -2 ]  ;
    Vm_Obj sym  =             jS.s[ -1 ]  ;
    Vm_Unt slot = OBJ_TO_UNT( jS.s[  0 ] );

    job_Guarantee_N_Args(3);
    job_Guarantee_Key_Arg(    -2 );
    job_Guarantee_Symbol_Arg( -1 );
    job_Guarantee_Int_Arg(     0 );

    {   Key_P s = KEY_P( key );
	Vm_Unt slots = OBJ_TO_UNT( s->total_slots );
	if (slot >= slots) MUQ_WARN ("No such slot in this mosKey");
	{   Key_Slot p = &s->slot[slot];
	    if        (sym == job_Kw_Symbol) {
		Key_Sym sa = (Key_Sym)(((Vm_Obj*)s) + OBJ_TO_INT(s->sym_loc));
		result = sa[slot].symbol;
	    } else if (sym == job_Kw_Initform) {
		result = p->initform;
	    } else if (sym == job_Kw_Initval) {
		result = p->initval;
	    } else if (sym == job_Kw_Type) {
		result = p->type;
	    } else if (sym == job_Kw_Documentation) {
		result = p->documentation;
	    } else if (sym == job_Kw_Get_Function) {
		result = p->get_function;
	    } else if (sym == job_Kw_Set_Function) {
		result = p->set_function;

    } else if (sym == job_Kw_Root_May_Read) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_ROOT_MAY_READ)    != 0 );
	    } else if (sym == job_Kw_Root_May_Write) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_ROOT_MAY_WRITE)   != 0 );

	    } else if (sym == job_Kw_Inherited) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_INHERITED) != 0 );
	    } else if (sym == job_Kw_User_May_Read) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_USER_MAY_READ)    != 0 );
	    } else if (sym == job_Kw_User_May_Write) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_USER_MAY_WRITE)   != 0 );

	    } else if (sym == job_Kw_Class_May_Read) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_CLASS_MAY_READ)  != 0 );
	    } else if (sym == job_Kw_Class_May_Write) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_CLASS_MAY_WRITE) != 0 );

	    } else if (sym == job_Kw_World_May_Read) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_WORLD_MAY_READ)   != 0 );
	    } else if (sym == job_Kw_World_May_Write) {
		result = OBJ_FROM_BOOL( (p->flags & KEY_FLAG_WORLD_MAY_WRITE)  != 0 );

	    } else if (sym == job_Kw_Allocation) {
		result = (
		    (p->flags & KEY_FLAG_SHARED)  ?
		    job_Kw_Class		  :
		    job_Kw_Instance
		);
	    } else {
		MUQ_WARN ("No such property on mosKey slots");
    }	}   }

    jS.s -= 2;
    *jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Get_Muqnet_Io -- 						*/
 /***********************************************************************/

void
job_P_Get_Muqnet_Io(
    void
) {
    Vm_Obj mss = JOB_P(jS.job)->muqnet_io;
    if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	mss = obj_Alloc_In_Dbfile( OBJ_CLASS_A_MSS, 0, VM_DBFILE(mss) );
	JOB_P(jS.job)->muqnet_io = mss;
	vm_Dirty(jS.job);	/* Or is this unneeded? */
    }
    mss_Reset( mss );
    *++jS.s = mss;
}

 /***********************************************************************/
 /*-    job_P_Mult -- '*' for non-fixnum, nonfloat cases.		*/
 /***********************************************************************/

void
job_P_Mult(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_Mult(   a, b, NULL ); return; }
	else if  (OBJ_IS_INT(   b)) { jS.s[-1] = bnm_MultBI( a, b       ); return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_MultBI( b, a       ); return; }
    }

    /* Handle vector multiplication: */
    if ((OBJ_IS_VEC(a) || OBJ_IS_F64(a) || OBJ_IS_F32(a) || OBJ_IS_FLOAT(a))
    &&  (OBJ_IS_VEC(b) || OBJ_IS_F64(b) || OBJ_IS_F32(b) || OBJ_IS_FLOAT(b))
    ){
	jS.s[-1] = job_mul_vectors(a,b);
	return;
    }

    MUQ_WARN("job_P_Mult: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Neg -- unary minus for non-float, non-fixnum cases.	*/
 /***********************************************************************/

void
job_P_Neg(
    void
) {
    Vm_Obj a = jS.s[0];

    /* Handle vector negation: */
    if ((OBJ_IS_VEC(a) || OBJ_IS_F64(a) || OBJ_IS_F32(a) || OBJ_IS_FLOAT(a))
    ){
	jS.s[0] = job_neg_vector(a);
	return;
    }

    /* Handle arbitrary bignum and fixnum combinations: */
    job_Guarantee_Bnm_Arg(   0 );
    {   Vm_Obj result = bnm_Neg( jS.s[0] );
        *jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Plus -- '+' for non-numeric cases.			*/
 /***********************************************************************/

void
job_P_Plus(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_Add(   a, b ); return; }
	else if  (OBJ_IS_INT(   b)) { jS.s[-1] = bnm_AddBI( a, b ); return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_AddBI( b, a ); return; }
    }

    /* Handle vector addition: */
    if ((OBJ_IS_VEC(a) || OBJ_IS_F64(a) || OBJ_IS_F32(a) || OBJ_IS_FLOAT(a))
    &&  (OBJ_IS_VEC(b) || OBJ_IS_F64(b) || OBJ_IS_F32(b) || OBJ_IS_FLOAT(b))
    ){
	jS.s[-1] = job_add_vectors(a,b);
	return;
    }
    MUQ_WARN("Addition unsupported on these operands");
#ifdef OLD
    /* Check that we have two strings on stack: */
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_Stg_Arg( -1 );
    jS.s[-1] = stg_Concatenate( jS.s[-1], jS.s[0] );
#endif
}

 /***********************************************************************/
 /*-    job_P_And_Bits -- 'logand' for non-fixnum cases.		*/
 /***********************************************************************/

void
job_P_And_Bits(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_Logand(   a, b, NULL ); return; }
	else if  (OBJ_IS_INT(   b)) { jS.s[-1] = bnm_LogandBI( a, b       ); return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_LogandBI( b, a       ); return; }
    }
    MUQ_WARN("logand: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Not_Bits -- 'lognot' for non-fixnum cases.		*/
 /***********************************************************************/

void
job_P_Not_Bits(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        jS.s[0] = bnm_Lognot(   a );
        return;
    }
    MUQ_WARN("lognot: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Or_Bits -- 'logior' for non-fixnum cases.			*/
 /***********************************************************************/

void
job_P_Or_Bits(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_Logior(   a, b, NULL ); return; }
	else if  (OBJ_IS_INT(   b)) { jS.s[-1] = bnm_LogiorBI( a, b       ); return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_LogiorBI( b, a       ); return; }
    }
    MUQ_WARN("logior: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Xor_Bits -- 'logxor' for non-fixnum cases.		*/
 /***********************************************************************/

void
job_P_Xor_Bits(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_Logxor(   a, b, NULL ); return; }
	else if  (OBJ_IS_INT(   b)) { jS.s[-1] = bnm_LogxorBI( a, b       ); return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_LogxorBI( b, a       ); return; }
    }
    MUQ_WARN("logxor: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Shift_Bits -- 'ash' for non-fixnum cases.			*/
 /***********************************************************************/

void
job_P_Shift_Bits(
    void
) {
    /* Handle bignum shifted by fixnum: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    job_Guarantee_Bnm_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    jS.s[-1] = bnm_Leftshift( a, b );
}

 /***********************************************************************/
 /*-    job_P_Sub -- '-' for non-numeric cases.				*/
 /***********************************************************************/

void
job_P_Sub(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_Sub(   a, b ); return; }
	else if  (OBJ_IS_INT(   b)) { jS.s[-1] = bnm_SubBI( a, b ); return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_SubIB( a, b ); return; }
    }

    /* Handle vector subtraction: */
    if ((OBJ_IS_VEC(a) || OBJ_IS_F64(a) || OBJ_IS_F32(a) || OBJ_IS_FLOAT(a))
    &&  (OBJ_IS_VEC(b) || OBJ_IS_F64(b) || OBJ_IS_F32(b) || OBJ_IS_FLOAT(b))
    ){
	jS.s[-1] = job_sub_vectors(a,b);
	return;
    }

    MUQ_WARN("job_P_Sub: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Div -- 'div' for non-numeric cases.			*/
 /***********************************************************************/

void
job_P_Div(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_Div(   a, b ); return; }
	else if  (OBJ_IS_INT(   b)) { jS.s[-1] = bnm_DivBI( a, b ); return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_DivIB( a, b ); return; }
    }

    /* Handle vector multiplication: */
    if ((OBJ_IS_VEC(a) || OBJ_IS_F64(a) || OBJ_IS_F32(a) || OBJ_IS_FLOAT(a))
    &&  (OBJ_IS_VEC(b) || OBJ_IS_F64(b) || OBJ_IS_F32(b) || OBJ_IS_FLOAT(b))
    ){
	jS.s[-1] = job_div_vectors(a,b);
	return;
    }

    MUQ_WARN("job_P_Div: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Mod -- 'mod' for non-numeric cases.			*/
 /***********************************************************************/

void
job_P_Mod(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];
    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_Mod(   a, b ); return; }
	else if  (OBJ_IS_INT(   b)) { jS.s[-1] = bnm_ModBI( a, b ); return; }
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) { jS.s[-1] = bnm_ModIB( a, b ); return; }
    }

    /* Handle vector multiplication: */
    if ((OBJ_IS_VEC(a) || OBJ_IS_F64(a) || OBJ_IS_F32(a) || OBJ_IS_FLOAT(a))
    &&  (OBJ_IS_VEC(b) || OBJ_IS_F64(b) || OBJ_IS_F32(b) || OBJ_IS_FLOAT(b))
    ){
	jS.s[-1] = job_mod_vectors(a,b);
	return;
    }

    MUQ_WARN("job_P_Mod: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Nearly_Equal -- approximate comparisons of floats.	*/
 /***********************************************************************/

int
job_nearly_equal(
    double a,
    double b
){
    double n;
    double d;

    a = fabs( a );
    b = fabs( b );

    if (a < b) {  n = b-a;  d = b+a; }
    else       {  n = a-b;  d = a+b; }

    if (d == 0.0) {
	return a==b;
    }
    return   (n/d) < 0.000001;
}

void
job_P_Nearly_Equal(
    void
) {
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];

    job_Guarantee_N_Args(   2 );

    if (OBJ_IS_FLOAT(a)
    &&  OBJ_IS_FLOAT(b)
    ){
	*--jS.s = OBJ_FROM_BOOL(  job_nearly_equal( OBJ_TO_FLOAT( a ), OBJ_TO_FLOAT2( b ) ) );
	return;
    }

    /* Handle vector comparison: */
    if ((OBJ_IS_VEC(a) || OBJ_IS_F64(a) || OBJ_IS_F32(a) || OBJ_IS_FLOAT(a))
    &&  (OBJ_IS_VEC(b) || OBJ_IS_F64(b) || OBJ_IS_F32(b) || OBJ_IS_FLOAT(b))
    ){
	*--jS.s = OBJ_FROM_BOOL( job_neq_vectors(a,b) );
	return;
    }

    MUQ_WARN("nearlyEqual: unsupported argument type(s)");
}

 /***********************************************************************/
 /*-    job_P_Debug_Print -- sprintf special objects.			*/
 /***********************************************************************/

#ifndef SOMETIMES_USEFUL

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Debug_Print(
    void
) {
    Vm_Obj o = *jS.s;
    Vm_Chr buf[ MAX_STRING ];
    Vm_Chr* end;
    job_Guarantee_N_Args( 1 );

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_FN(o)) {
	end = fun_Sprint( &buf[0], &buf[MAX_STRING-1], o );
    } else if (OBJ_IS_CFN(o)) {
	end = cfn_Sprint( &buf[0], &buf[MAX_STRING-1], o );
    } else {
        end = buf + job_Sprint_Vm_Obj(&buf[0],&buf[MAX_STRING-1],o,0);
    }
    *end = '\0';
    fputs(buf,stdout);
    --jS.s;
}
#endif

 /***********************************************************************/
 /*-    job_P_Dil_Test -- 						*/
 /***********************************************************************/

#ifndef SOMETIMES_USEFUL

void
job_P_Dil_Test(
    void
) {
  /**    dil_Test();*/
}
#endif

 /***********************************************************************/
 /*-    job_P_Print -- sprintf special objects.				*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Print(
    void
) {
    Vm_Obj o = *jS.s;
    Vm_Chr buf[ MAX_STRING ];
    job_Guarantee_N_Args( 1 );

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_FN(o)) {
	Vm_Chr* end = fun_Sprint( &buf[0], &buf[MAX_STRING], o );
	Vm_Obj  val = stg_From_Buffer( buf, end-buf );
	*jS.s = val;
	return;
    }
    if (OBJ_IS_CFN(o)) {
	Vm_Chr* end = cfn_Sprint( &buf[0], &buf[MAX_STRING], o );
	Vm_Obj  val = stg_From_Buffer( buf, end-buf );
	*jS.s = val;
	return;
    }

    {   Vm_Int arg_len = job_Sprint_Vm_Obj(&buf[0],&buf[MAX_STRING],o,1);
	Vm_Obj     val = stg_From_Buffer( buf, arg_len );
	*jS.s    = val;
	return;
    }
}

 /***********************************************************************/
 /*-    job_P_Print1 -- sprintf special objects.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Print1(
    void
) {

    Vm_Obj o = *jS.s;
    Vm_Chr buf[ MAX_STRING ];
    job_Guarantee_N_Args( 1 );

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_JOB(o)) {

	Vm_Chr* end = fun_Sprint( &buf[0], &buf[MAX_STRING], o );
	Vm_Obj  val = stg_From_Buffer( buf, end-buf );
	*jS.s = val;
	return;
    }

    MUQ_WARN ("print1: unsupported arg type");
}

 /***********************************************************************/
 /*-    job_P_Print_String -- sprintf.					*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif
 

 /***********************************************************************/
 /*-    find_next_format_field -- Break out '%s', const string etc.	*/
 /***********************************************************************/

static Vm_Int
find_next_format_field(
				/* We return field type else FALSE if done.*/
    Vm_Chr** format,		/* Where to start scan, updated when done. */
    Vm_Chr*  field_buf		/* We return full field scanned into here. */
) {
    register Vm_Chr* src = *format;
    register Vm_Chr* dst =  field_buf;
    register Vm_Int  c   = *src;
    *dst = '\0';

    switch (c) {

    case '\0':
	return FALSE;

    case '%':	
	/* %s or %3.6g or such: */
	*dst++ = c;
	if (src[1] != '%') {
	    Vm_Int digits_seen = 0;
	    for (;;) {
		c = *++src;
		if (!c || isspace(c))  MUQ_WARN ("Bad formatString string.");
		*dst++ = c;

		/* This check is because I'm worried about */
		/* malicious users trying to crash the     */
		/* server by doing '%40000s' or such:      */
		if (isdigit(c)) {
		    if (digits_seen++ == 3) {
			MUQ_WARN ("Too many digits in formatString spec");
		}   }

		if (isalpha(c)) {
		    *dst++ = '\0';
		    *format = src+1;
		    return c;
		}
	    }	    
	}
	/* Let '%%' fall into regular const-string code: */
	--dst;	/* Erase the '%' we already copied.	*/
	++src;	/* Skip the first '%' in the '%%'.	*/
	/* Fall through: */
	    
    default:
	/* Constant string: */	
	*dst++ = c;
	for (;;) {
	    *dst++ = c = *++src;
	    if (!c || c=='%') {
		dst[-1] = '\0';
		*format = src;
		return 1;
	    }
	}	    

    }
    /* Never reached. */
}

 /***********************************************************************/
 /*-    next_format_arg -- Return next formatString arg.		*/
 /***********************************************************************/

static Vm_Obj
next_format_arg(
    Vm_Int*  args_left
) {
    Vm_Int a = *args_left;
    if (!a) MUQ_WARN ("formatString: not enough args");
    *args_left =  a-1;
    return jS.s[ -a ];
}


  /**********************************************************************/
  /*-   print_string							*/
  /**********************************************************************/

static Vm_Int
print_string(
    Vm_Chr* result
) {
    Vm_Int block_len;

    job_Guarantee_N_Args(  2 );
    job_Guarantee_Blk_Arg( 0 );

    block_len = OBJ_TO_BLK( jS.s[ 0 ] );

    /* Make sure entire promised block is present: */
    job_Guarantee_N_Args(   block_len+2 );
    job_Guarantee_Stg_Arg( -block_len   );

    {   Vm_Obj  stg      = jS.s[ -block_len ]  ;
        Vm_Int  string_len = stg_Len( stg );
	Vm_Chr* fmt;

	Vm_Chr  temp[   MAX_STRING   ];
	Vm_Chr  format[ MAX_STRING+1 ];
	Vm_Chr  field[  MAX_STRING   ];

        Vm_Int  args_left 	 = block_len -1;
        Vm_Chr* remaining_format = format;
	Vm_Int  result_len 	 = 0;
	Vm_Int  field_type;

	if (block_len < 0)MUQ_WARN ("formatString: bad blocklen: %d",block_len);
	if (string_len >= MAX_STRING)MUQ_WARN ("formatString formatstring too big");
	if (string_len != stg_Get_Bytes( format, string_len, stg, 0 )) {
	    MUQ_WARN ("formatString: internal error");
	}
	/* Should maybe rewrite someday to allow nuls in format: */
	format[ string_len ] = '\0';
	result[        0 ] = '\0';


	while (field_type = find_next_format_field(&remaining_format,field)) {

	    switch (field_type) {

	    case 1:
		{   Vm_Int field_len = strlen(field);
		    if (field_len + result_len +1 >= MAX_STRING) {
		        MUQ_WARN ("formatString: result too long");
		    }
		    strcpy( result+result_len, field );
		    result_len += field_len;
		}
		break;

	    case 's':
		{   /* Grab arg, see if it is a stg: */
		    Vm_Obj arg = next_format_arg( &args_left );
		    Vm_Int arg_len;
		    if (stg_Is_Stg(arg)) {

			/* Make sure arg will fit in result[]: */
			arg_len = stg_Len( arg );
			/* '+1000' for possible '%999s' format: */
			if (arg_len + result_len + 1000 >= MAX_STRING) {
			    MUQ_WARN ("formatString: result too long");
			}

			/* Format arg into result[]: */
			if (arg_len != stg_Get_Bytes(temp, arg_len, arg, 0 )) {
			    MUQ_WARN ("formatString: internal error");
			}
			temp[ arg_len ] = '\0';
			sprintf( result+result_len, field, temp );
			result_len += strlen( result+result_len );

		    } else {

			/* Format arg into temp[]: */
			arg_len = job_Sprint_Vm_Obj(temp,temp+MAX_STRING,arg,0);

			if (arg_len + result_len >= MAX_STRING) {
			    MUQ_WARN ("formatString: result too long");
			}
			strcpy( result+result_len, temp );
			result_len += arg_len;
		    }
		}
		break;

	    case 'd':   fmt = VM_D;	goto ijoin;
	    case 'i':   fmt = VM_I;	goto ijoin;
	    case 'o':   fmt = VM_O;	goto ijoin;
	    case 'u':   fmt = VM_U;	goto ijoin;
	    case 'x':   fmt = VM_X;	goto ijoin;
	    ijoin:
	        /* Convert, say, "%03x" to "%03llx" or whatever: */
		strcpy( &field[ strlen(field) -1 ], fmt );
		{   /* Grab arg, make sure it's an int: */
		    Vm_Obj arg = next_format_arg( &args_left );
		    if (OBJ_IS_CHAR(arg)) arg = OBJ_FROM_INT(OBJ_TO_CHAR(arg));
		    if (!OBJ_IS_INT(arg)) {
			MUQ_WARN ("%c format needs int arg",field_type);
		    }

		    /* Make sure arg will fit in result[]: */
		    /* '+1000' for possible '%999d' format: */
		    if (result_len + 1000 >= MAX_STRING) {
			MUQ_WARN ("formatString: result too long");
		    }

		    /* Format arg into result[]: */
		    sprintf( result+result_len, field, OBJ_TO_INT(arg) );
		    result_len += strlen( result+result_len );
		}
		break;

	    case 'c':
		{   /* Grab arg, make sure it's an int: */
		    Vm_Obj arg = next_format_arg( &args_left );
		    if (OBJ_IS_CHAR(arg)) arg = OBJ_FROM_INT(OBJ_TO_CHAR(arg));
		    if (!OBJ_IS_INT(arg)) {
			MUQ_WARN ("%c format needs int arg",field_type);
		    }

		    /* Make sure arg will fit in result[]: */
		    /* '+1000' for possible '%999d' format: */
		    if (result_len + 1000 >= MAX_STRING) {
			MUQ_WARN ("formatString: result too long");
		    }

		    /* Format arg into result[]: */
		    sprintf( result+result_len, field, (int)OBJ_TO_INT(arg) );
		    result_len += strlen( result+result_len );
		}
		break;

	    case 'e':   fmt = VM_E;	goto fjoin;
	    case 'f':   fmt = VM_F;	goto fjoin;
	    case 'g':   fmt = VM_G;	goto fjoin;
	    fjoin:
	        /* Convert, say, "%5.3g" to "%5.3lg" or whatever: */
		strcpy( &field[ strlen(field) -1 ], fmt );
		{   /* Grab arg, make sure it's a float: */
		    Vm_Obj arg = next_format_arg( &args_left );
		    if (!OBJ_IS_FLOAT(arg)) {
			MUQ_WARN ("%c format needs float arg",field_type);
		    }

		    /* Make sure arg will fit in result[]: */
		    /* '+1000' for possible '%999f' format: */
		    if (result_len + 1000 >= MAX_STRING) {
			MUQ_WARN ("formatString: result too long");
		    }

		    /* Format arg into result[]: */
		    sprintf( result+result_len, field, OBJ_TO_FLOAT(arg) );
		    result_len += strlen( result+result_len );
		}
		break;

	    default:
		MUQ_WARN ("formatString: unsupported spec '%s'",field);
	    }
	}

	/* Check that all args were used: */
	if (args_left)   MUQ_WARN ("formatString: too many args");

	/* Pop args: */
	jS.s -= block_len+2;
        return result_len;
    }
}

  /**********************************************************************/
  /*-   job_P_Print_String -- sprintf.					*/
  /**********************************************************************/

void
job_P_Print_String(
    void
) {
    Vm_Chr  result[ MAX_STRING ];
    Vm_Int  result_len = print_string( result     );
    *++jS.s = stg_From_Buffer( result, result_len );	
}

  /**********************************************************************/
  /*-   job_P_Root_Log_Print -- sprintf to logfile.			*/
  /**********************************************************************/

void
job_P_Root_Log_Print(
    void
) {
    Vm_Chr  result[ MAX_STRING ];
    Vm_Int  result_len = print_string( result );
    result[ result_len ] = '\0';
    /* Buggo: Bypassed during testing: */
/*  job_Must_Be_Root(); */
    lib_Log_String( result );
}

 /***********************************************************************/
 /*-    job_P_Print_Time -- strftime					*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

 /***********************************************************************/
 /*-    Job_time: A state struct while we're running			*/
 /***********************************************************************/

typedef struct Job_time_rec {
    Vm_Chr*    dst;	/* First free byte in output buffer.	*/
    Vm_Chr*    lim;	/* Last       byte in output buffer.	*/
    Vm_Int     sec;	/* Time as seconds since 1970.		*/
    struct tm* tim;	/* Time exploded into fields.		*/
} Job_time;

 /***********************************************************************/
 /*-    job_print_time							*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    job_print_time_append_string -- Add a string to output buffer.	*/
 /***********************************************************************/

static void
job_print_time_append_string(
    Job_time*     s,
    const Vm_Chr* src
) {
    while (s->dst < s->lim   &&   (*s->dst = *src++))   ++s->dst;
}

 /***********************************************************************/
 /*-    job_print_time_append_number -- Add decimal val to output buf.	*/
 /***********************************************************************/

static void
job_print_time_append_number(
    Job_time* s,
    Vm_Unt    val,	/* Value to convert to decimal.	*/
    Vm_Int    width,	/* Minimum width for result.	*/
    Vm_Chr    fill	/* Fill-to-minimum character.	*/
) {
    /* Write the string backwards into buf: */
    Vm_Chr       buf[ sizeof(Vm_Int)*4 ];
    Vm_Chr *t = &buf[ sizeof(Vm_Int)*4 ];

    /* Write terminal null: */
    *--t = '\0';

    /* Mod-10 digits one by one off val, */
    /* and prepend them to accumulating  */
    /* result string in buf[]:           */
    do {
	/* Divides and mods tend to be horribly */
	/* slow, so we avoid doing a % in favor */
	/* of doing a * and - :                 */
	Vm_Int next_val = val / 10;
	*--t = (val - next_val*10) + '0';
	val  = next_val;
        --width;
    } while (val);

    /* Make sure we make minimum width: */
    while (width --> 0)   *--t = fill;

    /* Add to output buffer: */
    job_print_time_append_string( s, t );
}

 /***********************************************************************/
 /*-    job_print_time -- Add decimal val to output buf.		*/
 /***********************************************************************/

static void
job_print_time(
    Job_time* s,
    Vm_Chr*   f
) {

  /**********************************************************************/
  /*-   day and month name tables					*/
  /**********************************************************************/

    static Vm_Chr*
    sun_sat[ 7 ] = {
	"Sun",
	"Mon",
	"Tue",
	"Wed",
	"Thu",
	"Fri",
	"Sat"
    };

    static Vm_Chr*
    sunday_saturday[ 7 ] = {
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday"
    };

    static Vm_Chr*
    jan_dec[ 12 ] = {
	"Jan",
	"Feb",
	"Mar",
	"Apr",
	"May",
	"Jun",
	"Jul",
	"Aug",
	"Sep",
	"Oct",
	"Nov",
	"Dec"
    };

    static Vm_Chr*
    january_december[ 12 ] = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
    };

/***********************************************************/
/* I don't see how autoconfig can deduce the timezone when */
/* missing, so this is left as one by-hand patch.  Define  */
/* this only if your system's time.h:struct tm does not    */
/* have a tm_zone field:                                   */
/* #define NEED_TIME_ZONE "PST", "PDT"                     */
/***********************************************************/

    #undef OUR_TIME_ZONE
    #ifdef HAVE_TM_ZONE
	#define OUR_TIME_ZONE t->tm_zone
    #else
        #ifndef HAVE_TZNAME
	    #ifndef LOCAL_TIME_ZONE
	        #define LOCAL_TIME_ZONE "PST", "PDT"
	    #endif
	    static Vm_Chr*
	    tzname[2] = {
	       LOCAL_TIME_ZONE
	    };
	#endif
	#define OUR_TIME_ZONE tzname[ t->tm_isdst ? 1 : 0 ]
    #endif

    

    Vm_Int     h;
    Vm_Int     d;
    struct tm* t = s->tim;

    /* Over all characters in user's format string */
    /* (at least until result buffer overflows):   */
    while (*f  &&  s->dst < s->lim) {



	/* Copy chars not preceded by '%', delegate rest: */
	if (*f != '%') {
	    *s->dst++ = *f++;
	    continue;
	}



	/* Define some abbreviations to make */
	/* following switch() more concise:  */

	#undef  str
	#define str(x)     job_print_time_append_string(s,x)

	#undef  dec
	#define dec(x,y,z) job_print_time_append_number(s,x,y,z)

	#undef  prt
	#define prt(x)     job_print_time(s,x)



	/* Branch on char following the '%': */
	switch(++f, *f++) {

	case 'A':  str( sunday_saturday[  t->tm_wday ]	    );	break;
	case 'a':  str( sun_sat[          t->tm_wday ]	    );	break;
	case 'B':  str( january_december[ t->tm_mon  ]	    );	break;

	case 'b':
	case 'h':  str( jan_dec[          t->tm_mon  ]	    );	break;

	case 'p':  str( t->tm_hour >= 12 ? "PM" : "AM"	    );	break;
	case 'Z':  str( OUR_TIME_ZONE			    );	break;

	case 'W':  d = t->tm_wday ? (t->tm_wday-1) : 6;
		   dec( (t->tm_yday+7-d) / 7	   , 2, '0' );	break;

	case 'd':  dec( t->tm_mday		   , 2, '0' );	break;
	case 'e':  dec( t->tm_mday		   , 2, ' ' );	break;
	case 'H':  dec( t->tm_hour		   , 2, '0' );	break;

	case 'I':  dec( (h=t->tm_hour%12) ? h : 12 , 2, '0' );	break;
	case 'l':  dec( (h=t->tm_hour%12) ? h : 12 , 2, ' ' );	break;

	case 'j':  dec( t->tm_yday + 1		   , 3, '0' );	break;
	case 'k':  dec( t->tm_hour		   , 2, ' ' );	break;
	case 'M':  dec( t->tm_min		   , 2, '0' );	break;
	case 'm':  dec( t->tm_mon + 1		   , 2, '0' );	break;

	case 'S':  dec( t->tm_sec		   , 2, '0' );	break;
	case 'U':  dec((t->tm_yday+7-t->tm_wday)/7 , 2, '0' );	break;
	case 'w':  dec( t->tm_wday		   , 1, '0' );	break;

	case 'y':  dec( (t->tm_year+1900) % 100    , 2, '0' );	break;
	case 'Y':  dec(  t->tm_year+1900	   , 4, '0' );	break;

	case 's':  dec( s->sec			   , 0, ' ' );	break;

	case 'C':  prt( "%a %b %e %H:%M:%S %Y"		    );	break;
	case 'c':  prt( "%y%b%d:%H:%M:%S"		    );	break;

	case 'x':
	case 'D':  prt( "%m/%d/%y"			    );	break;

	case 'R':  prt( "%H:%M"				    );	break;
	case 'r':  prt( "%I:%M:%S %p"			    );	break;

	case 'T':
	case 'X':  prt( "%H:%M:%S"			    );	break;

	default:
	    /* Print all other chars: */
	    if (s->dst < s->lim)  *s->dst++ = f[-1];
	    break;
	}
    }
}

  /**********************************************************************/
  /*-   job_Strftime							*/
  /**********************************************************************/

void
job_Strftime(
    Vm_Uch* buf,
    Vm_Int  buflen,
    Vm_Uch* format,
    Vm_Int  time
) {
    #if VM_INTBYTES > 4
    Vm_Int secs_since_1970 = time / 1000;
    #else
    Vm_Int secs_since_1970 = time       ;
    #endif

    /* Crack given time into components: */
    time_t     secs          = secs_since_1970;
    struct tm* exploded_time = localtime( &secs );

    /* Set up pointers to start and end of result buffer: */
    Job_time   s;
    s.dst = &buf[      0 ];
    s.lim = &buf[ buflen ];
    s.sec = secs_since_1970;
    s.tim = exploded_time;

    job_print_time( &s, format );

    /* Add terminal null: */
    *s.dst = '\0';
}

  /**********************************************************************/
  /*-   job_P_Print_Time -- strftime					*/
  /**********************************************************************/

void
job_P_Print_Time(
    void
) {
    Vm_Int msecs_since_1970 = OBJ_TO_INT( jS.s[ -1 ] );

    job_Guarantee_N_Args(   2 );
    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );

    {   Vm_Obj  stg      = jS.s[ 0 ]  ;
        Vm_Int  string_len = stg_Len( stg );

	Vm_Chr  format[ MAX_STRING+1 ];
	Vm_Chr  result[ MAX_STRING+1 ];

	if (string_len >= MAX_STRING)MUQ_WARN ("printTime formatstring too big");
	if (string_len != stg_Get_Bytes( format, string_len, stg, 0 )) {
	    MUQ_WARN ("printTime: internal error");
	}
	/* Should maybe rewrite someday to allow nuls in format: */
	format[ string_len ] = '\0';
	result[          0 ] = '\0';

	job_Strftime( result, MAX_STRING, format, msecs_since_1970 );

	jS.s--;
       *jS.s  = stg_From_Buffer( result, strlen(result) );	
    }
}

 /***********************************************************************/
 /*-    job_P_Delete -- "delete" operator.				*/
 /***********************************************************************/

void
job_P_Delete(
    void
) {
    Vm_Obj o = jS.s[ 0];
    Vm_Obj v = jS.s[-1];
    job_Guarantee_N_Args( 2 );
    if (OBJ_IS_CONS( o )
    ||  o == OBJ_NIL
    ){
	Vm_Obj cfn = SYM_P(obj_Lib_Muf_List_Delete)->function;
	if (OBJ_IS_CFN(cfn)) {
	    job_Call2(cfn);
	    return;
    }   }
    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STK( o )) {
	    stk_Delete( o, v );
	    jS.s -= 2;
	    return;
	}
    }
    MUQ_WARN ("'delete' doesn't know how to operate on that.");
}

 /***********************************************************************/
 /*-    job_P_Delete_Bth -- "deleteBth" operator.			*/
 /***********************************************************************/

void
job_P_Delete_Bth(
    void
) {
    Vm_Obj o =             jS.s[-1]  ;
    Vm_Unt u = OBJ_TO_UNT( jS.s[ 0] );
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Int_Arg( 0 );
    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STK( o )) {
	    stk_Delete_Bth( o, u );
	    jS.s -= 2;
	    return;
	}
    }
    MUQ_WARN ("'deleteBth' doesn't know how to operate on that.");
}

 /***********************************************************************/
 /*-    job_P_Delete_Nth -- "deleteNth" operator.			*/
 /***********************************************************************/

void
job_P_Delete_Nth(
    void
) {
    Vm_Obj o =             jS.s[-1]  ;
    Vm_Unt u = OBJ_TO_UNT( jS.s[ 0] );
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Int_Arg( 0 );
    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STK( o )) {
	    stk_Delete_Nth( o, u );
	    jS.s -= 2;
	    return;
	}
    }
    MUQ_WARN ("'deleteNth' doesn't know how to operate on that.");
}

 /***********************************************************************/
 /*-    job_P_Empty_P -- "empty?" operator.				*/
 /***********************************************************************/

void
job_P_Empty_P(
    void
) {
    Vm_Obj o = jS.s[0];
    job_Guarantee_N_Args( 1 );
    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STK( o )) {
	    *jS.s = (stk_Empty_P( o ) ? OBJ_TRUE : OBJ_NIL);
	    return;
	}
	if (OBJ_IS_CLASS_STM( o )) {
	    *jS.s = (stm_Empty_P( o ) ? OBJ_TRUE : OBJ_NIL);
	    return;
    }	}
    MUQ_WARN ("'empty?' doesn't know how to query that.");
}

 /***********************************************************************/
 /*-    job_P_End_P -- "end?" operator.					*/
 /***********************************************************************/

void
job_P_End_P(
    void
) {
    Vm_Obj o = *jS.s;
    if (o==OBJ_NIL) {
	*jS.s = OBJ_TRUE;
	return;
    }
    job_Guarantee_Cons_Arg(0);
    *jS.s = OBJ_NIL;
}

 /***********************************************************************/
 /*-    job_P_Pull -- "pull" operator.					*/
 /***********************************************************************/

void
job_P_Pull(
    void
) {
    Vm_Obj o = jS.s[0];
    job_Guarantee_N_Args(  1 );
    job_Must_Control(      0 );

    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STK( o )) {
	    *jS.s = stk_Pull( o );
	    return;
	}
	if (OBJ_IS_CLASS_STM( o )) {
	    *jS.s = stm_Pull( o );
	    return;
    }	}
    MUQ_WARN ("pull: can't pull out of that.");
}

 /***********************************************************************/
 /*-    job_P_Unpush -- "unpush" operator.				*/
 /***********************************************************************/

void
job_P_Unpush(
    void
) {
    Vm_Obj o = jS.s[0];
    job_Guarantee_N_Args( 1 );
    job_Must_Control(     0 );
    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STM( o )) {
	    *jS.s = stm_Unpush( o );
	    return;
    }	}
    MUQ_WARN ("unpush: can't unpush that.");
}

 /***********************************************************************/
 /*-    job_P_Push -- "push" operator.					*/
 /***********************************************************************/

void
job_P_Push(
    void
) {
    Vm_Obj o = jS.s[ 0];
    Vm_Obj v = jS.s[-1];
    job_Guarantee_N_Args( 2 );
    job_Must_Control(     0 );
    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STK( o )) {
if (job_Reserved) {
printf("job_P_Push calling stk_Push...\n");
}
	    stk_Push( o, v );
	    jS.s -= 2;
	    return;
	}
	if (OBJ_IS_CLASS_STM( o )) {
if (job_Reserved) {
printf("job_P_Push calling stm_Push...\n");
}
	    stm_Push( o, v );
	    jS.s -= 2;
	    return;
    }	}
    MUQ_WARN ("push: can't push onto that.");
}

 /***********************************************************************/
 /*-    job_P_Push_Block -- "]push" operator.				*/
 /***********************************************************************/

void
job_P_Push_Block(
    void
) {
    Vm_Unt b = OBJ_TO_BLK( jS.s[-1] );
    Vm_Obj o =             jS.s[ 0] ;
    job_Guarantee_N_Args( b+3 );
    job_Must_Control(     0 );
    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STK( o )) {
	    stk_Push_Block( o, b );
	    jS.s -= b+3;
	    return;
    }	}
    MUQ_WARN ("]push: can't ]push onto that.");
}

 /***********************************************************************/
 /*-    job_P_Unpull -- "unpull" operator.				*/
 /***********************************************************************/

void
job_P_Unpull(
    void
) {
    Vm_Obj o = jS.s[ 0];
    Vm_Obj v = jS.s[-1];
    job_Guarantee_N_Args( 2 );
    job_Must_Control(     0 );
    if (OBJ_IS_OBJ( o )) {
	if (OBJ_IS_CLASS_STM( o )) {
	    stm_Unpull( o, v );
	    jS.s -= 2;
	    return;
    }	}
    MUQ_WARN ("unpull: can't unpull onto that.");
}

 /***********************************************************************/
 /*-    job_P_Random -- Return random float in [0.0, 1.0)		*/
 /***********************************************************************/

void
job_P_Random(
    void
) {
    #if   defined( HAVE_DRAND48 )
    double d = drand48();
    float  f = d;
    #elif defined( HAVE_RANDOM )
    Vm_Int i = 0x7FFFFFFF & random();
    float  f = ((float)i) / (float)0x7FFFFFFF;
    #else
    Vm_Int i = 0x7FFF & rand();
    float  f = ((float)i) / (float)0x7FFF;
    #endif
    Vm_Obj o = OBJ_FROM_FLOAT(f);
    *++jS.s  = o;
}

 /***********************************************************************/
 /*-    job_P_Truly_Random_Fixnum -- Return random 61-bit fixnum	*/
 /***********************************************************************/

void
job_P_Truly_Random_Fixnum(
    void
) {
    Vm_Unt bits = VM_INTBITS-(OBJ_INT_SHIFT+1);
    Vm_Obj result = bnm_TrulyRandomInteger( bits );
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Truly_Random_Integer -- Return random n-bit integer	*/
 /***********************************************************************/

void
job_P_Truly_Random_Integer(
    void
) {
    job_Guarantee_Int_Arg( 0 );
    {   Vm_Unt bits = OBJ_TO_INT( *jS.s );
        *jS.s       = bnm_TrulyRandomInteger( bits );
    }
}

 /***********************************************************************/
 /*-    job_P_Bits -- Return length-in-bits of an integer		*/
 /***********************************************************************/

void
job_P_Bits(
    void
) {
    Vm_Obj o = *jS.s;
    if (OBJ_IS_BIGNUM(o) && !BNM_P(o)->private) {
	*jS.s = OBJ_FROM_UNT( (Vm_Unt)bnm_Bits(       o ) );
	return;
    }	
    job_Guarantee_Int_Arg( 0 );
    {   Vm_Int i = OBJ_TO_INT( o );
	if (i < 0)   i = -i;
        *jS.s = OBJ_FROM_INT( (Vm_Int)bnm_VmuntBits(  i ) );
    }
}

 /***********************************************************************/
 /*-    job_P_Flush --							*/
 /***********************************************************************/

void
job_P_Flush(
    void
) {
    Vm_Obj mss  = JOB_P(jS.job)->standard_output;
    job_Will_Write_Message_Stream( mss );
    mss_Flush( mss );
}

 /***********************************************************************/
 /*-    job_P_Flush_Stream --						*/
 /***********************************************************************/

void
job_P_Flush_Stream(
    void
) {
    Vm_Obj mss  = *jS.s;
    job_Guarantee_Mss_Arg( 0 );
    job_Will_Write_Message_Stream( mss );
    mss_Flush( mss );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Read_Byte --						*/
 /***********************************************************************/

void
job_P_Read_Byte(
    void
) {
    job_P_Read_Char();
    if (*jS.s != OBJ_NIL) {
        *jS.s = OBJ_FROM_INT( OBJ_TO_CHAR( *jS.s ) );
    }
}

 /***********************************************************************/
 /*-    job_P_Read_Char --						*/
 /***********************************************************************/

void
job_P_Read_Char(
    void
) {
    Vm_Obj who;
    Vm_Obj tag;
    Vm_Obj val;
    Vm_Obj mss = job_Will_Read_Message_Stream( JOB_P(jS.job)->standard_input );

    while (mss_Read_Value( &who, &tag, &val, mss )) {
	if (tag != OBJ_FROM_BYT3('t','x','t'))   continue;
	if (!OBJ_IS_CHAR(val))   continue;
	*++jS.s = val;
	return;
    }
    if (MSS_P(mss)->dead != OBJ_NIL
    &&  JOB_P(jS.job)->read_nil_from_dead_streams != OBJ_0
    ){
	*++jS.s = OBJ_NIL;
	return;
    }
    mss_Readsleep( mss );
}

 /***********************************************************************/
 /*-    job_P_Read_Value --						*/
 /***********************************************************************/

void
job_P_Read_Value(
    void
) {
    Vm_Obj who;
    Vm_Obj tag;
    Vm_Obj val;
    Vm_Obj mss = job_Will_Read_Message_Stream( JOB_P(jS.job)->standard_input );

    if (mss_Read_Value( &who, &tag, &val, mss )) {
	*++jS.s = val;
	return;
    }
    if (MSS_P(mss)->dead != OBJ_NIL
    &&  JOB_P(jS.job)->read_nil_from_dead_streams != OBJ_0
    ){
	*++jS.s = OBJ_NIL;
	return;
    }
    mss_Readsleep( mss );
}

 /***********************************************************************/
 /*-    job_P_Unread_Char --						*/
 /***********************************************************************/

void
job_P_Unread_Char(
    void
) {
    Vm_Obj mss = job_Will_Read_Message_Stream( JOB_P(jS.job)->standard_input );
    mss_Unread_Value( mss );
}

 /***********************************************************************/
 /*-    job_P_Unread_Stream_Char --					*/
 /***********************************************************************/

void
job_P_Unread_Stream_Char(
    void
) {
    Vm_Obj mss  = *jS.s;
    job_Guarantee_Mss_Arg( 0 );

    mss = job_Will_Read_Message_Stream( mss );

    mss_Unread_Value( mss );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Read_Stream_Byte --					*/
 /***********************************************************************/

void
job_P_Read_Stream_Byte(
    void
) {
    job_P_Read_Stream_Char();
    if (jS.s[-1] != OBJ_NIL) {
        jS.s[-1] = OBJ_FROM_INT( OBJ_TO_CHAR( jS.s[-1] ) );
    }
}

 /***********************************************************************/
 /*-    job_P_Read_Stream_Char --					*/
 /***********************************************************************/

void
job_P_Read_Stream_Char(
    void
) {
    Vm_Obj who;
    Vm_Obj tag;
    Vm_Obj val;

    Vm_Obj mss  = *jS.s;
    job_Guarantee_Mss_Arg( 0 );
    mss = job_Will_Read_Message_Stream( mss );

    while (mss_Read_Value( &who, &tag, &val, mss )) {
	if (tag != OBJ_FROM_BYT3('t','x','t'))   continue;
	if (!OBJ_IS_CHAR(val))   continue;
	*  jS.s = val;
	*++jS.s = who;
	return;
    }
    if (MSS_P(mss)->dead != OBJ_NIL
    &&  JOB_P(jS.job)->read_nil_from_dead_streams != OBJ_0
    ){
	*  jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	return;
    }
    mss_Readsleep( mss );
}

 /***********************************************************************/
 /*-    job_P_Read_Stream_Value --					*/
 /***********************************************************************/

void
job_P_Read_Stream_Value(
    void
) {
    Vm_Obj who;
    Vm_Obj tag;
    Vm_Obj val;

    Vm_Obj mss  = *jS.s;
    job_Guarantee_Mss_Arg( 0 );
    mss = job_Will_Read_Message_Stream( mss );

    job_Guarantee_Headroom( 2 );
    if (mss_Read_Value( &who, &tag, &val, mss )) {
	*  jS.s = val;
	*++jS.s = tag;
	*++jS.s = who;
	return;
    }
    if (MSS_P(mss)->dead != OBJ_NIL
    &&  JOB_P(jS.job)->read_nil_from_dead_streams != OBJ_0
    ){
	*  jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	return;
    }
    mss_Readsleep( mss );
}

 /***********************************************************************/
 /*-    job_P_Unread_Token_Char --					*/
 /***********************************************************************/

void
job_P_Unread_Token_Char(
    void
) {
    Vm_Obj mss = jS.s[ -1 ];
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Mss_Arg( -1 );
    if (OBJ_TO_BLK( jS.s[ 0 ] ) != 1) {
        MUQ_WARN ("unreadTokenChar takes argblock exactly one long");
    }
    mss = job_Will_Read_Message_Stream( mss );
    {   Vm_Int c = mss_Unread_Token_Char( mss );
	jS.s[ -1 ] = OBJ_FROM_CHAR( c );
    }
}

 /***********************************************************************/
 /*-    job_P_Read_Token_Char --					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_p_read_token_char_termination_test --			*/
  /**********************************************************************/

static Vm_Int
job_p_read_token_char_termination_test(
    Vm_Int c
) {
    return FALSE;
}

  /**********************************************************************/
  /*-   job_P_Read_Token_Char --					*/
  /**********************************************************************/

void
job_P_Read_Token_Char(
    void
) {
    Vm_Obj mss = jS.s[ -1 ];
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Mss_Arg( -1 );
    if (OBJ_TO_BLK( jS.s[ 0 ] ) != 1) {
        MUQ_WARN ("readTokenChar takes argblock exactly one long");
    }
    mss = job_Will_Read_Message_Stream( mss );
    job_Guarantee_Headroom( 2 );

    {   Vm_Uch buf[4];
	Vm_Int byteloc = 0;
	Vm_Int lineloc = 0;

	Vm_Int chars_read;
	chars_read = mss_Scan_Token(
	    &byteloc,	/* Byte offset of first returned char in stream.*/
	    &lineloc,	/* Line offset of first returned char in stream.*/
	    buf,	/* Buffer in which we return chars.		*/
	    1,		/* Maximum number of chars to return.		*/
	    mss,	/* Message stream to read.			*/
	    job_p_read_token_char_termination_test /* Termination condition.*/
	);

	if (chars_read != 1) MUQ_WARN("readTokenChar: Internal err");

	jS.s += 2;

	jS.s[  0 ] = OBJ_FROM_BLK(3);
	jS.s[ -3 ] = OBJ_FROM_CHAR( buf[0]  );
	jS.s[ -2 ] = OBJ_FROM_INT(  byteloc );
	jS.s[ -1 ] = OBJ_FROM_INT(  lineloc );
    }
}

 /***********************************************************************/
 /*-    job_P_Read_Token_Chars --					*/
 /***********************************************************************/

void
job_P_Read_Token_Chars(
    void
) {
    Vm_Uch buf[ MSS_MAX_TOKEN_STRING ];
    Vm_Obj mss =               jS.s[ -3 ];
    Vm_Int start = OBJ_TO_INT( jS.s[ -2 ] );
    Vm_Int stop  = OBJ_TO_INT( jS.s[ -1 ] );
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Mss_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    if (OBJ_TO_BLK( jS.s[ 0 ] ) != 3) {
        MUQ_WARN ("readTokenChars takes argblock exactly three long");
    }
    mss = job_Will_Read_Message_Stream( mss );
    if (start < 0) MUQ_WARN("readTokenChars 'start' value must be >=0");
    if (stop  < 0) MUQ_WARN("readTokenChars 'stop' value must be >=0");
    if (stop  < start) MUQ_WARN("readTokenChars 'stop' < 'start'");

    {   Vm_Int i;
        Vm_Int chars_read = mss_Read_Token(
	    buf,		  /* Buffer in which we return chars.	*/
	    MSS_MAX_TOKEN_STRING, /* Maximum number of chars to return.	*/
	    mss,		  /* Message stream to read.		*/
	    start,		  /* Offset to start at.		*/
	    stop		  /* Offset to stop at.			*/
	);
	job_Guarantee_Headroom( chars_read );
	jS.s -= 3;
	for (i = 0;   i < chars_read;   ++i) {
	    *jS.s++ = OBJ_FROM_CHAR( buf[i] );
	}
	*jS.s = OBJ_FROM_BLK( chars_read );
    }	
}

 /***********************************************************************/
 /*-    job_P_Scan_Token_As_Lisp_String --				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   scan_token_as_lstr_termination_test --				*/
  /**********************************************************************/

static Vm_Obj scan_token_as_lstr_rdt;
static Vm_Int scan_token_as_lstr_endchr;
static Vm_Int scan_token_as_lstr_quoted;
static Vm_Int
scan_token_as_lstr_termination_test(
    Vm_Int c
) {
    if (scan_token_as_lstr_quoted) {
	scan_token_as_lstr_quoted = FALSE;
	return FALSE;
    }

    {   Vm_Obj kind = RDT_P( scan_token_as_lstr_rdt )->slot[ c & 0xFF ].kind;
        if (kind == RDT_SINGLE_ESCAPE) {
	    scan_token_as_lstr_quoted = TRUE;
	    return FALSE;
	}
    }

    if (c == scan_token_as_lstr_endchr) {
	return MSS_END_TOKEN_WITH_THIS_CHAR;
    }

    return FALSE;
}

  /**********************************************************************/
  /*-   job_P_Scan_Lisp_String_Token --					*/
  /**********************************************************************/

void
job_P_Scan_Lisp_String_Token(
    void
) {
    Vm_Int blk = OBJ_TO_BLK( *jS.s );
    Vm_Obj mss0= OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Obj mss;
    Vm_Int chr = OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Headroom( 5 );
    if (blk == 2) {
        job_Guarantee_Mss_Arg(  -2 );
        job_Guarantee_Char_Arg( -1 );
	mss0=              jS.s[ -2 ];
	chr = OBJ_TO_CHAR( jS.s[ -1 ] );
    } else {
	MUQ_WARN("scan-token-as-lisp-string takes 2 args");
    }

    mss = job_Will_Read_Message_Stream( mss0 );
    scan_token_as_lstr_endchr = chr;
    scan_token_as_lstr_quoted = FALSE;
    scan_token_as_lstr_rdt    = JOB_P( jS.job )->readtable;

    {   Vm_Uch buf[MSS_MAX_TOKEN_STRING];
	Vm_Int byteloc = 0;
	Vm_Int lineloc = 0;

	Vm_Int chars_read;
	chars_read = mss_Scan_Token(
	    &byteloc,	/* Byte offset of first returned char in stream.*/
	    &lineloc,	/* Line offset of first returned char in stream.*/
	    buf,	/* Buffer in which we return chars.		*/
	    MSS_MAX_TOKEN_STRING,/* Maximum number of chars to return.	*/
	    mss,	/* Message stream to read.			*/
	    scan_token_as_lstr_termination_test/* Termination condition.*/
	);

	jS.s += 4-blk;

	jS.s[ -4 ] =                mss0                ;
	jS.s[ -3 ] = OBJ_FROM_INT(  byteloc            );
	jS.s[ -2 ] = OBJ_FROM_INT(  byteloc+chars_read );
	jS.s[ -1 ] = OBJ_FROM_INT(  lineloc            );
	jS.s[  0 ] = OBJ_FROM_BLK(  4                  );
    }
}

 /***********************************************************************/
 /*-    job_P_Scan_Token_To_Char --					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   scan_token_to_char_termination_test --				*/
  /**********************************************************************/

static Vm_Int scan_token_to_char_endchar;
static Vm_Int scan_token_to_char_qotchar;
static Vm_Int scan_token_to_char_prvchar;
static Vm_Int
scan_token_to_char_termination_test(
    Vm_Int c
) {
    if (scan_token_to_char_prvchar == scan_token_to_char_qotchar) {
	scan_token_to_char_prvchar = -2;
	return FALSE;
    }

    if (c == scan_token_to_char_endchar) {
	return MSS_END_TOKEN_WITH_THIS_CHAR;
    }

    scan_token_to_char_prvchar = c;
    return FALSE;
}

  /**********************************************************************/
  /*-   job_P_Scan_Token_To_Char --					*/
  /**********************************************************************/

void
job_P_Scan_Token_To_Char(
    void
) {
    Vm_Int blk = OBJ_TO_BLK( *jS.s );
    Vm_Obj mss0= OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Obj mss;
    Vm_Int chr = OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Int qot = -1;
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Headroom( 4 );
    if (blk == 2) {
        job_Guarantee_Mss_Arg(  -2 );
        job_Guarantee_Char_Arg( -1 );
	mss0=              jS.s[ -2 ];
	chr = OBJ_TO_CHAR( jS.s[ -1 ] );
    } else if (blk == 3) {
        job_Guarantee_Mss_Arg(  -3 );
        job_Guarantee_Char_Arg( -2 );
	mss0=              jS.s[ -3 ];
	chr = OBJ_TO_CHAR( jS.s[ -2 ] );
	if (jS.s[-1] != OBJ_NIL) {
            job_Guarantee_Char_Arg( -1 );
	    qot = OBJ_TO_CHAR( jS.s[ -1 ] );
	}
    } else {
	MUQ_WARN("scanTokenToChar takes 2 or 3 args");
    }

    mss = job_Will_Read_Message_Stream( mss0 );
    scan_token_to_char_endchar = chr;
    scan_token_to_char_qotchar = qot;
    scan_token_to_char_prvchar =  -2;

    {   Vm_Uch buf[MSS_MAX_TOKEN_STRING];
	Vm_Int byteloc = 0;
	Vm_Int lineloc = 0;

	Vm_Int chars_read;
	chars_read = mss_Scan_Token(
	    &byteloc,	/* Byte offset of first returned char in stream.*/
	    &lineloc,	/* Line offset of first returned char in stream.*/
	    buf,	/* Buffer in which we return chars.		*/
	    MSS_MAX_TOKEN_STRING,/* Maximum number of chars to return.	*/
	    mss,	/* Message stream to read.			*/
	    scan_token_to_char_termination_test/* Termination condition.*/
	);

	jS.s += 4-blk;

	jS.s[ -4 ] =                mss0                ;
	jS.s[ -3 ] = OBJ_FROM_INT(  byteloc            );
	jS.s[ -2 ] = OBJ_FROM_INT(  byteloc+chars_read );
	jS.s[ -1 ] = OBJ_FROM_INT(  lineloc            );
	jS.s[  0 ] = OBJ_FROM_BLK(  4                  );
    }
}

 /***********************************************************************/
 /*-    job_P_Scan_Token_To_Chars --					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   scan_token_to_chars_termination_test --				*/
  /**********************************************************************/

static Vm_Uch* scan_token_to_chars_endchars;
static Vm_Int  scan_token_to_chars_count;
static Vm_Int  scan_token_to_chars_qotchar;
static Vm_Int  scan_token_to_chars_prvchar;
static Vm_Int
scan_token_to_chars_termination_test(
    Vm_Int c
) {
    if (scan_token_to_chars_prvchar == scan_token_to_chars_qotchar) {
	scan_token_to_chars_prvchar = -2;
	return FALSE;
    }

    {   register Vm_Int i;
	for (i = scan_token_to_chars_count;   i --> 0; ) {
	    if (c == scan_token_to_chars_endchars[i]) {
		return MSS_END_TOKEN_WITH_THIS_CHAR;
    }	}   }

    scan_token_to_chars_prvchar = c;
    return FALSE;
}

  /**********************************************************************/
  /*-   job_P_Scan_Token_To_Chars --					*/
  /**********************************************************************/

void
job_P_Scan_Token_To_Chars(
    void
) {
    Vm_Uch buf[ 256 ];
    Vm_Int blk = OBJ_TO_BLK( *jS.s );
    Vm_Obj mss0= OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Obj mss;
    Vm_Int len = OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Obj stg = OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Int qot = -1;
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Headroom( 4 );


    if (blk == 2) {
        job_Guarantee_Mss_Arg(   -2 );
        job_Guarantee_Stg_Arg(   -1 );
	mss0=              jS.s[ -2 ];
	stg =              jS.s[ -1 ];
    } else if (blk == 3) {
        job_Guarantee_Mss_Arg(   -3 );
        job_Guarantee_Stg_Arg(   -2 );
	mss0=              jS.s[ -3 ];
	stg =              jS.s[ -2 ];
	if (jS.s[-1] != OBJ_NIL) {
            job_Guarantee_Char_Arg(  -1 );
	    qot = OBJ_TO_CHAR( jS.s[ -1 ] );
	}
    } else {
	MUQ_WARN("scanTokenToChars takes 2 or 3 args");
    }

    len = stg_Get_Bytes( buf, 256, stg, 0 );
    if (len == 256) MUQ_WARN("|scanTokenToChars string too long");

    mss = job_Will_Read_Message_Stream( mss0 );
    scan_token_to_chars_endchars = buf;
    scan_token_to_chars_count    = len;
    scan_token_to_chars_qotchar  = qot;
    scan_token_to_chars_prvchar  =  -2;

    {   Vm_Uch buf[MSS_MAX_TOKEN_STRING];
	Vm_Int byteloc = 0;
	Vm_Int lineloc = 0;

	Vm_Int chars_read;
	chars_read = mss_Scan_Token(
	    &byteloc,	/* Byte offset of first returned char in stream.*/
	    &lineloc,	/* Line offset of first returned char in stream.*/
	    buf,	/* Buffer in which we return chars.		*/
	    MSS_MAX_TOKEN_STRING,/* Maximum number of chars to return.	*/
	    mss,	/* Message stream to read.			*/
	    scan_token_to_chars_termination_test/*Termination condition.*/
	);

	jS.s += 4-blk;

	jS.s[ -4 ] =                mss0                ;
	jS.s[ -3 ] = OBJ_FROM_INT(  byteloc            );
	jS.s[ -2 ] = OBJ_FROM_INT(  byteloc+chars_read );
	jS.s[ -1 ] = OBJ_FROM_INT(  lineloc            );
	jS.s[  0 ] = OBJ_FROM_BLK(  4                  );
    }
}

 /***********************************************************************/
 /*-    job_P_Scan_Token_To_Char_Pair --				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   scan_token_to_pair_termination_test --				*/
  /**********************************************************************/

static Vm_Int scan_token_to_pair_end0char;
static Vm_Int scan_token_to_pair_end1char;
static Vm_Int scan_token_to_pair_qotchar;
static Vm_Int scan_token_to_pair_prvchar;
static Vm_Int
scan_token_to_pair_termination_test(
    Vm_Int c
) {
    if (scan_token_to_pair_prvchar == scan_token_to_pair_qotchar) {
	scan_token_to_pair_prvchar = -2;
	return FALSE;
    }

    if (c == scan_token_to_pair_end1char
    &&  scan_token_to_pair_prvchar == scan_token_to_pair_end0char
    ){
	return MSS_END_TOKEN_WITH_THIS_CHAR;
    }

    scan_token_to_pair_prvchar = c;
    return FALSE;
}

  /**********************************************************************/
  /*-   job_P_Scan_Token_To_Char_Pair --				*/
  /**********************************************************************/

void
job_P_Scan_Token_To_Char_Pair(
    void
) {
    Vm_Int blk = OBJ_TO_BLK( *jS.s );
    Vm_Obj mss0= OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Obj mss;
    Vm_Int chr0= OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Int chr1= OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Int qot = -1;
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Headroom( 4 );
    if (blk == 3) {
        job_Guarantee_Mss_Arg(   -3 );
        job_Guarantee_Char_Arg(  -2 );
        job_Guarantee_Char_Arg(  -1 );
	mss0=              jS.s[ -3 ];
	chr0= OBJ_TO_CHAR( jS.s[ -2 ] );
	chr1= OBJ_TO_CHAR( jS.s[ -1 ] );
    } else if (blk == 4) {
        job_Guarantee_Mss_Arg(  -4 );
        job_Guarantee_Char_Arg( -3 );
        job_Guarantee_Char_Arg( -2 );
	mss0=              jS.s[ -4 ];
	chr0= OBJ_TO_CHAR( jS.s[ -3 ] );
	chr1= OBJ_TO_CHAR( jS.s[ -2 ] );
	if (jS.s[-1] != OBJ_NIL) {
            job_Guarantee_Char_Arg(  -1 );
	    qot = OBJ_TO_CHAR( jS.s[ -1 ] );
	}
    } else {
	MUQ_WARN("scan-token-to-char-pair takes 3 or 4 args");
    }

    mss = job_Will_Read_Message_Stream( mss0 );
    scan_token_to_pair_end0char = chr0;
    scan_token_to_pair_end1char = chr1;
    scan_token_to_pair_qotchar  = qot;
    scan_token_to_pair_prvchar  =  -2;

    {   Vm_Uch buf[MSS_MAX_TOKEN_STRING];
	Vm_Int byteloc = 0;
	Vm_Int lineloc = 0;

	Vm_Int chars_read;
	chars_read = mss_Scan_Token(
	    &byteloc,	/* Byte offset of first returned char in stream.*/
	    &lineloc,	/* Line offset of first returned char in stream.*/
	    buf,	/* Buffer in which we return chars.		*/
	    MSS_MAX_TOKEN_STRING,/* Maximum number of chars to return.	*/
	    mss,	/* Message stream to read.			*/
	    scan_token_to_pair_termination_test/* Termination condition.*/
	);

	jS.s += 4-blk;

	jS.s[ -4 ] =                mss0                ;
	jS.s[ -3 ] = OBJ_FROM_INT(  byteloc            );
	jS.s[ -2 ] = OBJ_FROM_INT(  byteloc+chars_read );
	jS.s[ -1 ] = OBJ_FROM_INT(  lineloc            );
	jS.s[  0 ] = OBJ_FROM_BLK(  4                  );
    }
}

 /***********************************************************************/
 /*-    job_P_Scan_Token_To_Whitespace --				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   scan_token_to_ws_termination_test --				*/
  /**********************************************************************/

static Vm_Int scan_token_to_ws_qotchar;
static Vm_Int scan_token_to_ws_prvchar;
static Vm_Int
scan_token_to_ws_termination_test(
    Vm_Int c
) {
    if (scan_token_to_ws_prvchar == scan_token_to_ws_qotchar) {
	scan_token_to_ws_prvchar = -2;
	return FALSE;
    }

    if (isspace(c)) {
	return MSS_END_TOKEN_WITH_PREV_CHAR;
    }

    scan_token_to_ws_prvchar = c;
    return FALSE;
}

  /**********************************************************************/
  /*-   job_P_Scan_Token_To_Whitespace --				*/
  /**********************************************************************/

void
job_P_Scan_Token_To_Whitespace(
    void
) {
    Vm_Int blk = OBJ_TO_BLK( *jS.s );
    Vm_Obj mss0= OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Obj mss;
    Vm_Int qot = -1;
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Headroom( 4 );
    if (blk == 1) {
        job_Guarantee_Mss_Arg(   -1 );
	mss0=              jS.s[ -1 ];
    } else if (blk == 2) {
        job_Guarantee_Mss_Arg(  -2 );
	mss0=             jS.s[ -2 ];
	if (jS.s[-1] != OBJ_NIL) {
            job_Guarantee_Char_Arg(  -1 );
	    qot = OBJ_TO_CHAR( jS.s[ -1 ] );
	}
    } else {
	MUQ_WARN("scanTokenToWhitespace takes 1 or 2 args");
    }

    mss = job_Will_Read_Message_Stream( mss0 );
    scan_token_to_ws_qotchar  = qot;
    scan_token_to_ws_prvchar  =  -2;

    {   Vm_Uch buf[MSS_MAX_TOKEN_STRING];
	Vm_Int byteloc = 0;
	Vm_Int lineloc = 0;

	Vm_Int chars_read;
	chars_read = mss_Scan_Token(
	    &byteloc,	/* Byte offset of first returned char in stream.*/
	    &lineloc,	/* Line offset of first returned char in stream.*/
	    buf,	/* Buffer in which we return chars.		*/
	    MSS_MAX_TOKEN_STRING,/* Maximum number of chars to return.	*/
	    mss,	/* Message stream to read.			*/
	    scan_token_to_ws_termination_test  /* Termination condition.*/
	);

	jS.s += 4-blk;

	jS.s[ -4 ] =                mss0                ;
	jS.s[ -3 ] = OBJ_FROM_INT(  byteloc            );
	jS.s[ -2 ] = OBJ_FROM_INT(  byteloc+chars_read );
	jS.s[ -1 ] = OBJ_FROM_INT(  lineloc            );
	jS.s[  0 ] = OBJ_FROM_BLK(  4                  );
    }
}


 /***********************************************************************/
 /*-    job_P_Scan_Token_To_Nonwhitespace --				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   scan_token_to_nonws_termination_test --				*/
  /**********************************************************************/

static Vm_Int scan_token_to_nonws_seen_nl;
static Vm_Int
scan_token_to_nonws_termination_test(
    Vm_Int c
) {
    if (c == '\n') scan_token_to_nonws_seen_nl = TRUE;
    if (!isspace(c)) {
	return MSS_END_TOKEN_WITH_PREV_CHAR;
    }

    return FALSE;
}

  /**********************************************************************/
  /*-   job_P_Scan_Token_To_Nonwhitespace --				*/
  /**********************************************************************/

void
job_P_Scan_Token_To_Nonwhitespace(
    void
) {
    Vm_Int blk = OBJ_TO_BLK( *jS.s );
    Vm_Obj mss0= OBJ_FROM_INT(0);	/* Initialized to quiet compilers.*/
    Vm_Obj mss;
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Headroom( 5 );
    if (blk == 1) {
        job_Guarantee_Mss_Arg(   -1 );
	mss0=              jS.s[ -1 ];
    } else {
	MUQ_WARN("scanTokenToNonwhitespace takes 1 arg");
    }

    scan_token_to_nonws_seen_nl = FALSE;
    mss = job_Will_Read_Message_Stream( mss0 );

    {   Vm_Uch buf[MSS_MAX_TOKEN_STRING];
	Vm_Int byteloc = 0;
	Vm_Int lineloc = 0;

	Vm_Int chars_read;
	chars_read = mss_Scan_Token(
	    &byteloc,	/* Byte offset of first returned char in stream.*/
	    &lineloc,	/* Line offset of first returned char in stream.*/
	    buf,	/* Buffer in which we return chars.		*/
	    MSS_MAX_TOKEN_STRING,/* Maximum number of chars to return.	*/
	    mss,	/* Message stream to read.			*/
	    scan_token_to_nonws_termination_test  /* Termination cond.  */
	);

	jS.s += 5-blk;

	jS.s[ -5 ] =                mss0                ;
	jS.s[ -4 ] = OBJ_FROM_INT(  byteloc            );
	jS.s[ -3 ] = OBJ_FROM_INT(  byteloc+chars_read );
	jS.s[ -2 ] = OBJ_FROM_INT(  lineloc            );
	jS.s[ -1 ] = OBJ_FROM_BOOL( scan_token_to_nonws_seen_nl );
	jS.s[  0 ] = OBJ_FROM_BLK(  5                  );
    }
}


 /***********************************************************************/
 /*-    job_P_Make_Number --						*/
 /***********************************************************************/

#define LISP_BADNUM         OBJ_FROM_INT(0)
#define LISP_SHORT_FLOAT    OBJ_FROM_INT(1)
#define LISP_SINGLE_FLOAT   OBJ_FROM_INT(2)
#define LISP_DOUBLE_FLOAT   OBJ_FROM_INT(3)
#define LISP_EXTENDED_FLOAT OBJ_FROM_INT(4)
#define LISP_FIXNUM         OBJ_FROM_INT(5)
#define LISP_BIGNUM         OBJ_FROM_INT(6)
#define LISP_RATIO          OBJ_FROM_INT(7)

  /**********************************************************************/
  /*-   job_makenum_typ -- Deduce type of lisp number.			*/
  /**********************************************************************/


static
Vm_Obj	/* One of LISP_FIXNUM, LISP_RATIO, LISP_SHORT_FLOAT. */
job_makenum_typ(
    Vm_Obj* loc,
    Vm_Int  len
){
    /* We don't try to establish that the  */
    /* input constitutes a valid number,   */
    /* only to narrow it down to one valid */
    /* possibility:                        */

    Vm_Int seen_slash  = FALSE;
    Vm_Int seen_alpha  = FALSE;
    Vm_Int seen_period = FALSE;
    Vm_Int i;
    Vm_Int c;

    for (i = 0;   i < len;   ++i) {
        c = (OBJ_TO_INT( loc[i]) & 0xFF);
	if      (c == '/')     seen_slash  = TRUE;
        else if (c == '.')     seen_period = TRUE;
        else if (isalpha(c))   seen_alpha  = TRUE;
    }

    /* Only ratios can contain '/': */
    if (seen_slash)  return LISP_RATIO;

    /* Integer unless it has either decimal point or exponent: */
    if (!seen_period && !seen_alpha)      return LISP_FIXNUM;

    /* Integr if decimal point is at end: */
    if (OBJ_TO_INT( loc[len-1] ) == '.')  return LISP_FIXNUM;

    /* Must be a float: */
    return LISP_SHORT_FLOAT;
}

  /**********************************************************************/
  /*-   job_makenum_flo -- Convert float number.			*/
  /**********************************************************************/

static
Vm_Obj
job_makenum_flo(
    Vm_Obj* typ,
    Vm_Obj* loc,
    Vm_Int  len
){
    /************************************************************/
    /* Parse commonlisp float syntax:				*/
    /* flo  -> [sign] digit*   '.' digit+   [exp]		*/
    /*      |  [sign] digit+ [ '.' digit* ]  exp		*/
    /* exp  -> [mark] [sign] digit+				*/
    /* mark -> 'e' | 's' | 'f' | 'd' | 'l'     -- Or uppercase	*/
    /************************************************************/

    Vm_Int  seen_digit = FALSE;
    Vm_Int  exp_sign =  1;
    Vm_Int  exp_val  =  0;
    double  sign  = 1.0;
    double  val   = 0.0;
    double  scale = 0.1;
    Vm_Int  i     = 0;
    Vm_Int  c;

    *typ = LISP_SHORT_FLOAT;

    /* Handle any leading sign: */
    c = (OBJ_TO_INT(loc[i]) & 0xFF);
    if (c == '+') {
        ++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    } else if (c == '-') {
	sign = -1.0;
        ++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    }

    /* Eat any mantissa digits before decimal point: */
    while (i < len) {
	if (!isdigit(c))  break;
	seen_digit = TRUE;
	val = 10.0 * val + ((double)(c - '0'));
        ++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    }

    if (i == len) {
	if (!seen_digit)   *typ = LISP_BADNUM;
	return OBJ_FROM_FLOAT( (float)(sign * val) );
    }

    /* Eat any decimal point and following digits: */
    if (c == '.') {
        ++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
	while (i < len) {
	    if (!isdigit(c))  break;
	    val += scale * ((double)(c - '0'));
	    scale *= 0.1;
	    ++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
	}
    }

    val *= sign;

    if (i == len) {
	return OBJ_FROM_FLOAT( (float)val );
    }

    /* Must have an exponent marker: */
    c = tolower(c);
    if (c == 'e'
    ||  c == 's'
    ||  c == 'f'
    ||  c == 'd'
    ||  c == 'l'
    ){
	++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    }else{
	*typ = LISP_BADNUM;
	return OBJ_FROM_FLOAT( (float)val );
    }

    /* May have sign on exponent: */
    if (c == '+') {
	++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    }else if (c == '-') {
	exp_sign = -1;
	++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    }

    /* Must have an exponent digit: */
    if (i == len
    || !isdigit(c)
    ){
	*typ = LISP_BADNUM;
	return OBJ_FROM_FLOAT( (float)val );
    }

    /* Accumulate exponent digits: */
    while (i < len) {
	if (!isdigit(c)) {
	    /* Can't have anything but digits here: */
	    *typ = LISP_BADNUM;
	    return OBJ_FROM_FLOAT( (float)val );
	}
	exp_val  = 10 * exp_val + (c - '0');
	++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    }

    /* Apply exponent: */
    if (exp_sign == 1) {
	while (exp_val > 100) { val *= 1e100 ; exp_val -= 100; }
	while (exp_val >  10) { val *= 1e10  ; exp_val -=  10; }
	while (exp_val >   0) { val *= 1e1   ; exp_val -=   1; }
    } else {		    
	while (exp_val > 100) { val *= 1e-100; exp_val -= 100; }
	while (exp_val >  10) { val *= 1e-10 ; exp_val -=  10; }
	while (exp_val >   0) { val *= 1e-1  ; exp_val -=   1; }
    }

    return OBJ_FROM_FLOAT( (float)val );
}

  /**********************************************************************/
  /*-   job_makenum_rat -- Convert rational number.			*/
  /**********************************************************************/

static
Vm_Obj
job_makenum_rat(
    Vm_Obj* typ,
    Vm_Obj* loc,
    Vm_Int  len
){
    MUQ_WARN ("rational numbers not supported yet");

    return OBJ_FROM_INT( 0 );	/* Just to quiet compilers. */
}

  /**********************************************************************/
  /*-   job_makenum_fix -- Convert rational number.			*/
  /**********************************************************************/

static
Vm_Obj
job_makenum_fix(
    Vm_Obj* typ,
    Vm_Obj* loc,
    Vm_Int  len
){
    Vm_Int  sign = 1;
    Vm_Int  val  = 0;
    Vm_Int  i    = 0;
    Vm_Int  c;

    *typ = LISP_FIXNUM;

    /* Handle any leading sign: */
    c = (OBJ_TO_INT(loc[i]) & 0xFF);
    if (c == '+') {
        ++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    } else if (c == '-') {
	sign = -1;
        ++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    }

    /* Eat digits: */
    while (i < len) {
	if (!isdigit(c)) {
	    *typ = LISP_BADNUM;
	    return OBJ_FROM_INT( val );
	}
	val = 10 * val + (c - '0');
	if (val < 0) MUQ_WARN ("Integer out of range");
        ++i;        c = (OBJ_TO_INT(loc[i]) & 0xFF);
    }

    if (OBJ_TO_INT( OBJ_FROM_INT(val)) < 0) MUQ_WARN ("Integer out of range");

    if (sign == -1) val = -val;

    return OBJ_FROM_INT( val );
}

 /***********************************************************************/
 /*-    job_P_Position_In_Stack -- |positionInStack?			*/
 /***********************************************************************/

#ifndef JOB_MAX_SYMBOL_NAME
#define JOB_MAX_SYMBOL_NAME 1024
#endif

void
job_P_Position_In_Stack_P(
    void
) {
    Vm_Uch buf[ JOB_MAX_SYMBOL_NAME ];
    Vm_Obj stk =             jS.s[  0 ]  ;
    Vm_Int blk = OBJ_TO_BLK( jS.s[ -1 ] );

    job_Guarantee_Stk_Arg(  0 );  
    job_Guarantee_Blk_Arg( -1 );
    job_Guarantee_N_Args( blk+3 );

    if (blk >= JOB_MAX_SYMBOL_NAME) MUQ_WARN ("block too long");
    job_makesym_fetchseg( buf, &jS.s[-1-blk], blk );

    {   Vm_Int loc = 0;
        Vm_Int found = stk_Get_Key_P_Asciz( &loc, stk, buf );
	*  jS.s = OBJ_FROM_BOOL( found );
	*++jS.s = OBJ_FROM_INT(  loc   );
    }
}

   /*********************************************************************/
   /*-  job_P_Streq_Block --						*/
   /*********************************************************************/

void
job_P_Streq_Block(
    void
) {
    Vm_Uch bufs[ JOB_MAX_SYMBOL_NAME ];
    Vm_Uch bufp[ JOB_MAX_SYMBOL_NAME ];
    Vm_Int blk      = OBJ_TO_BLK( jS.s[ -1 ] );
    Vm_Obj stg      =             jS.s[  0 ]  ;

    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_Blk_Arg( -1 );
    job_Guarantee_N_Args( blk+3 );

    {   Vm_Int len = stg_Len(stg);
	if (len != blk) {
	    *jS.s = OBJ_NIL;	
	    return;
	}
        len = stg_Get_Bytes( bufs, JOB_MAX_SYMBOL_NAME, stg, 0 );
        if (len == JOB_MAX_SYMBOL_NAME) MUQ_WARN("|= string too long");
        job_makesym_fetchseg( bufp, jS.s-1-blk, blk ); 
	
	{   Vm_Int i;
	    for (i= 0;   i < blk;   ++i) {
	        if (bufp[i] != bufs[i]) {
		    *jS.s = OBJ_NIL;
		    return;
    }	}   }	}

   *jS.s = OBJ_T;
}

 /***********************************************************************/
 /*-    job_P_To_Delimited_String -- "toDelimitedString" fn.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_To_Delimited_String(
    void
) {
    job_Guarantee_N_Args(   1 );

    *jS.s = job_Tprint_Vm_Obj( *jS.s, /*Quote strings:*/TRUE );
}

 /***********************************************************************/
 /*-    job_P_To_String -- "toString" fn.				*/
 /***********************************************************************/

void
job_P_To_String(
    void
) {
    job_Guarantee_N_Args(   1 );

    if (!stg_Is_Stg(*jS.s)) {
	*jS.s = job_Tprint_Vm_Obj( *jS.s,/*Quote strings:*/FALSE);
    }
}

 /***********************************************************************/
 /*-    job_P_Explode_Bounded_String_Line -- "explodeBoundedStringLine["*/
 /***********************************************************************/

void
job_P_Explode_Bounded_String_Line(
    void
) {
    Vm_Uch buf[ MAX_STRING ];
    Vm_Obj stg =             jS.s[ -2 ]  ;
    Vm_Unt off = OBJ_TO_INT( jS.s[ -1 ] );	/* Starting offset. */
    Vm_Unt lim = OBJ_TO_INT( jS.s[  0 ] );	/* Max length.      */
    Vm_Unt len;

    job_Guarantee_N_Args(   3 );
    job_Guarantee_Stg_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );

    if (off > (Vm_Unt)MAX_STRING)   off = MAX_STRING-1;
    if (lim > (Vm_Unt)MAX_STRING)   lim = MAX_STRING-1;

    len = stg_Len(stg);
    if (off > len) MUQ_WARN ("Invalid start offset");
    len = stg_Get_Bytes( buf, lim, stg, off );
    buf[len] = '\0';

    /* Find ending newline, if any, counting quotables: */
    {   Vm_Unt quotables = 0;
	Vm_Unt i;
	for (i = 0;   i < len;   ++i) {
	    Vm_Unt c = buf[i];
	    if (c == '\n') {
		len = i+1;
		break;
	    }
	    if (c == '"'
            ||  c == '\\'
	    ){
		++quotables;
	    }
	}

	/* Make sure we have room to push a block  */
	/* containing line, remembering we need to */
	/* add backslashes before the quotables:   */
	job_Guarantee_Headroom( len + quotables );
	
	/* Pop input and push return block: */
	jS.s -= 3;
	*++jS.s = OBJ_BLOCK_START;
	for (i = 0;   i < len;   ++i) {
	    Vm_Unt c = buf[i];
	    if (c == '"'
	    ||  c == '\\'
	    ){
		*++jS.s = OBJ_FROM_CHAR('\\');
	    }
	    *++jS.s = OBJ_FROM_CHAR(c);
	}
	*++jS.s = OBJ_FROM_BLK( len + quotables );

	/* Push also number of chars consumed: */
	*++jS.s = OBJ_FROM_INT( len );
    }
}


 /***********************************************************************/
 /*-    job_P_Explode_Number -- "explodeNumber["			*/
 /***********************************************************************/

void
job_P_Explode_Number(
    void
) {
    Vm_Uch buf[ MAX_STRING ];
    Vm_Obj num = *jS.s;

    job_Guarantee_N_Args(    1);

    /* Sprintf argument into buf[]: */
    if (OBJ_IS_FLOAT( num )) {
	Vm_Flt f = OBJ_TO_FLOAT( num );
	sprintf( buf, "%g", f );
    } else if (OBJ_IS_INT( num )) {
	Vm_Int i = OBJ_TO_INT(   num );
	sprintf( buf, "%" VM_D, i );
    } else {
	MUQ_WARN ("Needed numeric argument");
    }

    /* Convert buf[] contents to a char stackblock: */
    {   Vm_Int len = strlen( buf );
	Vm_Int i;
	job_Guarantee_Headroom( len + 1 );
	*jS.s = OBJ_BLOCK_START;
	for (i = 0;   i < len;   ++i) {
	    *++jS.s = OBJ_FROM_CHAR( buf[i] );
	}
	*++jS.s = OBJ_FROM_BLK( len );
    }
}


 /***********************************************************************/
 /*-    job_P_Explode_Symbol -- "explodeSymbol[" fn.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

  /**********************************************************************/
  /*-   job_needs_quoting -- TRUE iff string contains | \ ( ...		*/
  /**********************************************************************/

static
Vm_Int
job_needs_quoting(
    Vm_Uch* buf
){
    /* This is probably all wrong, but it is a start: */
    Vm_Int c;
    for ( ;   c = *buf;   ++buf) {
	switch (c) {
	case '\\':
	case '|':
	case '#':
	case '(':
	case ')':
	case '"':
	case '\'':
	case '`':
	case ':':
	case ',':
	    return TRUE;
	default:
	    if (c <= ' ' || c >= 127) return TRUE;
	}
    }
    return FALSE;
}

  /**********************************************************************/
  /*-   job_quote_buffer -- wrap |...| around buffer, quote \ and |	*/
  /**********************************************************************/

static
void
job_quote_buffer(
    Vm_Uch* buf
){
    
    /* This is probably all wrong, but it is a start: */
    Vm_Int len = strlen( buf );
    Vm_Int qot = 0;
    Vm_Uch* src = buf+len;
    Vm_Uch* dst = buf+len;
    Vm_Int c;

    /* Count number of internal quotes needed in string: */
    for (src = buf;   c = *src;   ++src) {
        if (c == '|' || c == '\\')   ++qot;
    }

    src = buf+len-1;
    dst = src+qot+3;
    *dst-- = '\0';
    *dst-- = '|';
    for ( ;   src >= buf;   --src) {
	c = *src;
	*dst-- = c;
	if (c == '|' || c == '\\')  *dst-- = '\\';
    }
    *dst = '|';
    if (dst != buf)  MUQ_FATAL ("internal err");
}

  /**********************************************************************/
  /*-   job_symbol_name_part -- Package or symbol name. properly quoted	*/
  /**********************************************************************/

static
Vm_Uch*
job_symbol_name_part(
   Vm_Uch* buf,
   Vm_Uch* lim,
   Vm_Obj  nam
){
    Vm_Int len;
    if (!stg_Is_Stg(nam)) MUQ_WARN ("Symbol or package name not a string");

    len = stg_Len(nam);
    if (len > ((lim-buf)>>1)-3) MUQ_WARN ("Symbol or package name too long");
    if (len != stg_Get_Bytes( buf, len, nam, 0 )) MUQ_FATAL ("Internal err");
    buf[len] = '\0';
    if (job_potnum_buf(    buf )
    ||  job_needs_quoting( buf )
    ){
	job_quote_buffer(  buf );
    }
    return buf+strlen(buf);

}

  /**********************************************************************/
  /*-   job_P_Explode_Symbol -- "explodeSymbol[" fn.			*/
  /**********************************************************************/

void
job_P_Explode_Symbol(
    void
) {
    Vm_Uch buffer[ MAX_STRING ];
    Vm_Uch*buf = buffer;
    Vm_Uch*lim = &buffer[ MAX_STRING ];
    Vm_Obj obj = *jS.s;
    Vm_Obj pkg;
    Vm_Obj nam;
    Vm_Obj fun;

    job_Guarantee_N_Args(    1);
    job_Guarantee_Symbol_Arg(0);


    {   Sym_P s = SYM_P(obj);
	pkg     = s->package;
	nam     = s->name;
	fun     = s->function;
    }
    if (!OBJ_IS_OBJ(pkg)
    ||  !OBJ_IS_CLASS_PKG(pkg)
    ){
	/* Special format to print uninterned symbols: */
	buf = lib_Sprint( buf, lim, "#:" );
    } else if (pkg == obj_Lib_Keyword) {
	/* Special format to print keywords: */
	buf = lib_Sprint( buf, lim, ":" );
    } else {
	Vm_Obj current_pkg = JOB_P(job_RunState.job)->package;

	/* If symbol is not accessable in current   */
	/* package,  prefix name with package name: */
	if (!pkg_Knows_Symbol( current_pkg, obj )) {
	    buf = job_symbol_name_part( buf, lim, OBJ_P(pkg)->objname );

	    /* Need '::' iff symbol isn't exported from package: */
	    if (sym_Find_Exported( pkg, nam )) {
		buf = lib_Sprint( buf, lim, ":"   );
	    } else {
		buf = lib_Sprint( buf, lim, "::"  );
    }   }   }

    buf = job_symbol_name_part( buf, lim, SYM_P(obj)->name );

    job_Guarantee_Headroom( (buf-buffer)+1 );
    *jS.s++ = OBJ_BLOCK_START;
    lim = buf;
    buf = buffer;
    while (buf < lim)   *jS.s++ = OBJ_FROM_CHAR(*buf++);
    *jS.s = OBJ_FROM_BLK(lim-buffer);
}

 /***********************************************************************/
 /*-    job_P_Trim_String -- "trimString" operator.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Trim_String(
    void
) {

    job_Guarantee_N_Args(  1 );
    job_Guarantee_Stg_Arg( 0 );

    {   Vm_Obj stg = jS.s[0];
        Vm_Int len = stg_Len( stg );
	Vm_Uch src[ MAX_STRING ];
	Vm_Uch dst[ MAX_STRING ];

	if (len >= MAX_STRING) MUQ_WARN ("string too long (%d) for trimString",(int)len);
	if (len != stg_Get_Bytes( src, MAX_STRING-1, stg, 0 )) {
	    MUQ_WARN ("trimString: internal error");
	}
	src[ len ] = '\0';
	{/* register Vm_Int  i = len; */
	    register Vm_Uch* s = src;
	    register Vm_Uch* d = dst;

	    /* Skip leading whitespace: */
	    while (isspace( *s ))   ++s;

	    /* Copy rest of string: */
	    while (*d++ = *s++ );
	    --d;

	    /* Suppress trailing whitespace: */
	    while (isspace( d[-1] )   &&   d > dst)   --d;
	    *d = '\0';
	}
	if (STRCMP( src, != ,dst ))   *jS.s = stg_From_Asciz( dst );
    }
}

   /*********************************************************************/
   /*-  job_P_Make_Symbol --						*/
   /*********************************************************************/

void
job_P_Make_Symbol(
    void
) {
    Vm_Obj sym = sym_Make();
    *++jS.s = sym;
}

   /*********************************************************************/
   /*-  job_P_Make_Symbol_Block --					*/
   /*********************************************************************/

void
job_P_Make_Symbol_Block(
    void
) {
    Vm_Uch bufp[ JOB_MAX_SYMBOL_NAME ];
    Vm_Uch bufs[ JOB_MAX_SYMBOL_NAME ];
    Vm_Int blk      = OBJ_TO_BLK( jS.s[ -1 ] );
    Vm_Int dflt_pkg =             jS.s[  0 ]  ;
    Vm_Int cln;
    Vm_Obj pkg;
    Vm_Obj sym;
    if (!OBJ_IS_OBJ(dflt_pkg) || !OBJ_IS_CLASS_PKG(dflt_pkg)) {
	dflt_pkg = OBJ_FROM_INT(0);
    }

    job_Guarantee_Blk_Arg( -1 );
    job_Guarantee_N_Args( blk+3 );
    if (!blk) MUQ_WARN ("]makeSymbol needs non-empty block");

    cln = job_makesym_first_colon( jS.s-1-blk, blk );

    if (cln == 0) {

	/* Keyword with a single leading colon */

	/* Make asciz string: */
	job_makesym_fetchseg( bufs, (jS.s-blk), blk-1 ); 

	/* Make/find keyword: */
	sym = sym_Alloc_Asciz_Keyword( bufs );

    } else if (cln == -1) {

	/* No colon: symbol in current pkg */

	/* Make asciz string: */
	job_makesym_fetchseg( bufs, jS.s-1-blk, blk ); 

	sym = sym_Alloc_Asciz( JOB_P(jS.job)->package, bufs, dflt_pkg );

    } else {

	/* Distinguish x:y from x::y by */
	/* checking for a second ':':   */
	if (':' == OBJ_TO_INT( *((jS.s-blk)+cln) )) {

	    /* x::y */

	    /* Get package name: */
	    job_makesym_fetchseg( bufp, jS.s-1-blk, cln ); 

	    /* Find package proper: */
	    pkg = muf_Find_Package_Asciz( bufp );
	    if (!pkg) MUQ_WARN ("No package '%s' in @$s.lib",bufp);

	    /* Get symbol name: */
	    job_makesym_fetchseg( bufs, (jS.s-blk)+cln+1, blk-(cln+2) ); 

	    /* Find symbol proper: */
	    sym = sym_Find_Asciz( pkg, bufs );
	    if (!sym) MUQ_WARN ("No such private symbol as %s::%s",bufp,bufs);

	} else {

	    /* x:y */

	    /* Get package name: */
	    job_makesym_fetchseg( bufp, jS.s-1-blk, cln ); 

	    /* Find package proper: */
	    pkg = muf_Find_Package_Asciz( bufp );
	    if (!pkg) MUQ_WARN ("No package '%s' in @$s.lib",bufp);

	    /* Get symbol name: */
	    job_makesym_fetchseg( bufs, (jS.s-blk)+cln, blk-(cln+1) ); 

	    /* Get symbol proper: */
	    sym = sym_Find_Exported_Asciz( pkg, bufs );
	    if (!sym) MUQ_WARN ("No such exported symbol as %s:%s",bufp,bufs);
	}
    }

    jS.s    -= blk+2;
    jS.s[ 0] = sym;
}


 /***********************************************************************/
 /*-    job_P_Read_Lisp_Comment --					*/
 /***********************************************************************/

void
job_P_Read_Lisp_Comment(
    void
) {
    /* Note: This fn isn't terribly fast, but */
    /* the interface is designed to allow a   */
    /* fast reimplementation.                 */
    Vm_Obj mss =             jS.s[-1 ]  ;
    Vm_Int blk = OBJ_TO_BLK( jS.s[ 0 ] );

    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_Mss_Arg( -1 );

    job_Guarantee_N_Args( blk+2 );
    if (blk != 1) MUQ_WARN ("readLispComment takes one argument");
    
    mss = job_Will_Read_Message_Stream( mss );

    for (;;) {
	Vm_Obj who;
	Vm_Obj tag;
	Vm_Obj val;
        if (!mss_Read_Value( &who, &tag, &val, mss )) {
	    mss_Readsleep( mss );
	}
	if (tag != OBJ_FROM_BYT3('t','x','t'))   continue;
	if (!OBJ_IS_CHAR(val))   continue;

	if (val != OBJ_FROM_CHAR('\n'))   continue;

	jS.s[ -1 ] = OBJ_NIL;

	return;
    }
}


 /***********************************************************************/
 /*-    job_P_Read_Lisp_String --					*/
 /***********************************************************************/

void
job_P_Read_Lisp_String(
    void
) {
    /* Note: This fn isn't terribly fast, but */
    /* the interface is designed to allow a   */
    /* fast reimplementation.                 */
    Vm_Obj ins;
    Vm_Obj mss =             jS.s[-3 ]  ;
    Vm_Obj dlm =             jS.s[-2 ]  ;
    Vm_Int qot =             jS.s[-1 ]  ;
    Vm_Int blk = OBJ_TO_BLK( jS.s[ 0 ] );

    job_Guarantee_Blk_Arg(   0 );
    job_Guarantee_Mss_Arg(  -3 );
    job_Guarantee_Char_Arg( -2 );

    job_Guarantee_N_Args( blk+2 );
    if (blk < 3) MUQ_WARN ("readLispString takes three args");
    
    ins = job_Will_Read_Message_Stream( mss );

    for (;;) {
	Vm_Obj who;
	Vm_Obj tag;
	Vm_Obj val;
        if (!mss_Read_Value( &who, &tag, &val, ins )) {
	    mss_Readsleep( ins );
	}
	if (tag != OBJ_FROM_BYT3('t','x','t'))   continue;
	if (!OBJ_IS_CHAR(val))   continue;

        job_Guarantee_Headroom( 1 );

	/* \-ed chars always get added to string: */
	if (qot != OBJ_NIL) {
	    /* Character is quoted: */
	    jS.s++;
	    jS.s[ -4 ] = val;
	    jS.s[ -3 ] = mss;
	    jS.s[ -2 ] = dlm;
	    jS.s[ -1 ] = qot = OBJ_NIL;
	    jS.s[  0 ] = OBJ_FROM_BLK( ++blk );
	    continue;
	}

	/* Non-\-ed \s change our state but otherwise get ignored: */
/* Buggo -- should be checking readtable for single-escape */
/* attribute, not doing a hardwired check for '\' here:    */
	if (val == OBJ_FROM_CHAR('\\')) {
	    qot = jS.s[-1 ] = OBJ_T;
	    continue;
	}

	/* Non-\-ed delimiters end the string: */
	if (val == dlm) {
	    /* Pop our three state variables: */
	    jS.s -= 3;
	    *jS.s = OBJ_FROM_BLK( blk-3 );
	    return;
	}

	/* Vanilla char -- add it to string block: */
	jS.s++;
	jS.s[ -4 ] = val;
	jS.s[ -3 ] = mss;
	jS.s[ -2 ] = dlm;
	jS.s[ -1 ] = qot;
	jS.s[  0 ] = OBJ_FROM_BLK( ++blk );
    }
}


  /**********************************************************************/
  /*-   job_P_Make_Number --						*/
  /**********************************************************************/

void
job_P_Make_Number(
    void
) {
    Vm_Int blk    = OBJ_TO_BLK( jS.s[ 0 ] );
    Vm_Obj typ;
    Vm_Obj val    = 0; /* Initialized just to quiet compilers. */

    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args( blk+2 );

    typ = job_makenum_typ( jS.s-blk, blk );

    switch (typ) {

    case LISP_FIXNUM:
	val = job_makenum_fix( &typ, jS.s-blk, blk );
	break;

    case LISP_RATIO:
	val = job_makenum_rat( &typ, jS.s-blk, blk );
	break;

    case LISP_SHORT_FLOAT:
	val = job_makenum_flo( &typ, jS.s-blk, blk );
	break;

    default:
        MUQ_FATAL ("");
    }

    jS.s    -= blk;
    jS.s[-1] = typ;
    jS.s[ 0] = val;
}
    


   /*********************************************************************/
   /*-  job_P_Find_Symbol_P --						*/
   /*********************************************************************/

void
job_P_Find_Symbol_P(
    void
) {
    Vm_Uch bufp[ JOB_MAX_SYMBOL_NAME ];
    Vm_Uch bufs[ JOB_MAX_SYMBOL_NAME ];
    Vm_Int blk      = OBJ_TO_BLK( jS.s[ -1 ] );
    Vm_Obj dflt_pkg =             jS.s[  0 ]  ;
    Vm_Int cln;
    Vm_Obj pkg;
    Vm_Obj sym;
    if (!OBJ_IS_OBJ(dflt_pkg) || !OBJ_IS_CLASS_PKG(dflt_pkg)) {
	dflt_pkg = OBJ_FROM_INT(0);
    }

    job_Guarantee_Blk_Arg( -1 );
    job_Guarantee_N_Args( blk+2 );

    if (!blk) MUQ_WARN ("|findSymbol?? needs non-empty block");
    if (blk >= JOB_MAX_SYMBOL_NAME) MUQ_WARN ("Symbol name too long");

    cln = job_makesym_first_colon( jS.s-1-blk, blk );

    if (cln == 0) {

	/* Keyword with a single leading colon */

	/* Make asciz string: */
	job_makesym_fetchseg( bufs, (jS.s-blk), blk-1 ); 

	/* Make/find keyword: */
	sym = sym_Alloc_Asciz_Keyword( bufs );

    } else if (cln == -1) {

	/* No colon: symbol in current pkg */

	/* Make asciz string: */
	job_makesym_fetchseg( bufs, jS.s-1-blk, blk ); 

	sym = sym_Find_Asciz( JOB_P(jS.job)->package, bufs );

	/* If no go, search default package: */
	if (!sym) {
	    sym = sym_Find_Exported_Asciz( dflt_pkg, bufs );
	}
/*	if (!sym) MUQ_WARN ("No such symbol as %s",bufs); */

    } else {

	/* Distinguish x:y from x::y by */
	/* checking for a second ':':   */
	if (':' == OBJ_TO_INT( *((jS.s-blk)+cln) )) {

	    /* x::y */

	    /* Get package name: */
	    job_makesym_fetchseg( bufp, jS.s-1-blk, cln ); 

	    /* Find package proper: */
	    pkg = muf_Find_Package_Asciz( bufp );
	    if (!pkg) MUQ_WARN ("No package '%s' in @$s.lib",bufp);

	    /* Get symbol name: */
	    job_makesym_fetchseg( bufs, (jS.s-blk)+cln+1, blk-(cln+2) ); 

	    /* Find symbol proper: */
	    sym = sym_Find_Asciz( pkg, bufs );
/*	    if (!sym)MUQ_WARN ("No such private symbol as %s::%s",bufp,bufs);*/

	} else {

	    /* x:y */

	    /* Get package name: */
	    job_makesym_fetchseg( bufp, jS.s-1-blk, cln ); 

	    /* Find package proper: */
	    pkg = muf_Find_Package_Asciz( bufp );
	    if (!pkg) MUQ_WARN ("No package '%s' in @$s.lib",bufp);

	    /* Get symbol name: */
	    job_makesym_fetchseg( bufs, (jS.s-blk)+cln, blk-(cln+1) ); 

	    /* Get symbol proper: */
	    sym = sym_Find_Exported_Asciz( pkg, bufs );
/*	    if (!sym)MUQ_WARN ("No such exported symbol as %s:%s",bufp,bufs);*/
	}
    }

   *  jS.s = OBJ_FROM_BOOL( sym != 0 );
   *++jS.s = sym ? sym : OBJ_NIL;
}


 /***********************************************************************/
 /*-    job_P_String_Downcase -- "stringDowncase" operator.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

static void
job_string_downcase(
    Vm_Chr* dst,
    Vm_Chr* src,
    Vm_Int  len
) {
    register Vm_Int  i = len;
    register Vm_Chr* s = src;
    register Vm_Chr* d = dst;
    while (i --> 0)  *d++ = tolower( *s++ );
    dst[ len ] = '\0';
}

void
job_P_String_Downcase(
    void
) {

    job_Guarantee_N_Args(               1 );

    /* Do fastest case first, as usual, although if */
    /* we ever really care, this should be moved    */
    /* from slow to fast prim table:                */
    if (job_Type0[jS.s[0]&0xFF] == JOB_TYPE_i) {
	*jS.s = OBJ_FROM_INT( tolower( OBJ_TO_INT( *jS.s ) &0xFF ) );
	return;
    }

    job_Guarantee_Stg_Arg(              0 );

    {   Vm_Obj stg = jS.s[0];
        Vm_Int len = stg_Len( stg );
	Vm_Chr src[ MAX_STRING ];
	Vm_Chr dst[ MAX_STRING ];

	if (len >= MAX_STRING) MUQ_WARN ("string too long (%d) for stringDowncase",(int)len);
	if (len != stg_Get_Bytes( src, MAX_STRING, stg, 0 )) {
	    MUQ_WARN ("stringDowncase: internal error");
	    src[ len ] = '\0';
	}
	job_string_downcase( dst, src, len );
	if (STRCMP( src, != ,dst ))   *jS.s = stg_From_Buffer( dst, len );
    }
}

 /***********************************************************************/
 /*-    job_P_String_Mixedcase -- "stringMixedcase" function.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

#undef POST_PUNCTUATION
#undef POST_WHITESPACE
#undef POST_OTHER

#define POST_PUNCTUATION	(1) /* Just saw '?' '!' or '.'	         */
#define POST_WHITESPACE		(2) /* Just saw '\n' '\t' ' '...	  */
#define POST_SENTENCE		(3) /* Just saw '?'/'!'/'.' + whitespace. */
#define POST_OTHER		(4) /* All other cases.		          */

void
job_P_String_Mixedcase(
    void
) {

    job_Guarantee_N_Args(               1 );

    /* Do fastest case first, as usual, although if */
    /* we ever really care, this should be moved    */
    /* from slow to fast prim table:                */
    if (job_Type0[jS.s[0]&0xFF] == JOB_TYPE_i) {
	*jS.s = OBJ_FROM_INT( toupper( OBJ_TO_INT( *jS.s )  &0xFF ) );
	return;
    }

    job_Guarantee_Stg_Arg(              0 );

    {   Vm_Obj stg = jS.s[0];
        Vm_Int len = stg_Len( stg );
	Vm_Chr src[ MAX_STRING ];
	Vm_Chr dst[ MAX_STRING ];

	if (len >= MAX_STRING) MUQ_WARN ("string too long (%d) for stringMixedcase",(int)len);
	if (len != stg_Get_Bytes( src, MAX_STRING, stg, 0 )) {
	    MUQ_WARN ("stringMixedcase: internal error");
	    src[ len ] = '\0';
	}
	{   register Vm_Int  i = len;
	    register Vm_Uch* s = src;
	    register Vm_Uch* d = dst;
	    register Vm_Int  p = POST_SENTENCE;
	    while (i --> 0) {
		register Vm_Int c = *s++;
		switch (p) {
		case POST_SENTENCE:
		    if      (isalpha(c))       { *d++ = toupper(c);  p = POST_OTHER      ; }
		    else 	               { *d++ =         c ;                      ; }
		    break;
		case POST_PUNCTUATION:
		    if      (isspace(c))       { *d++ =         c ;  p = POST_SENTENCE   ; }
		    else if (isalpha(c))       { *d++ =         c ;  p = POST_OTHER      ; }
		    else                       { *d++ =         c ;                      ; }
		    break;
		case POST_WHITESPACE:
		    if (c=='i' &&!isalpha(*s)) { *d++ =        'I';  p = POST_OTHER      ; }
		    else if (isspace(c))       { *d++ =         c ;                      ; }
		    else                       { *d++ =         c ;  p = POST_OTHER      ; }
		    break;
		case POST_OTHER:
		    switch (c) {
		    case '?':case '!':case '.':{ *d++ =         c ;  p = POST_PUNCTUATION; }
			break;        case ' ':
		    case'\n':case'\r':case'\t':{ *d++ =         c ;  p = POST_WHITESPACE ; }
			break;
		    default:                   { *d++ =         c ;                      ; }
		    }
		}
	    }
	    dst[ len ] = '\0';
	}
	if (STRCMP( src, != ,dst ))   *jS.s = stg_From_Buffer( dst, len );
    }
}

 /***********************************************************************/
 /*-    job_P_String_Upcase -- "stringUpcase" operator.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

static void
job_string_upcase(
    Vm_Chr* dst,
    Vm_Chr* src,
    Vm_Int  len
) {
    register Vm_Int  i = len;
    register Vm_Chr* s = src;
    register Vm_Chr* d = dst;
    while (i --> 0)  *d++ = toupper( *s++ );
    dst[ len ] = '\0';
}

void
job_P_String_Upcase(
    void
) {

    job_Guarantee_N_Args(               1 );

    /* Do fastest case first, as usual, although if */
    /* we ever really care, this should be moved    */
    /* from slow to fast prim table:                */
    if (job_Type0[jS.s[0]&0xFF] == JOB_TYPE_i) {
	*jS.s = OBJ_FROM_INT( toupper( OBJ_TO_INT( *jS.s )  &0xFF ) );
	return;
    }

    job_Guarantee_Stg_Arg(              0 );

    {   Vm_Obj stg = jS.s[0];
        Vm_Int len = stg_Len( stg );
	Vm_Chr src[ MAX_STRING ];
	Vm_Chr dst[ MAX_STRING ];

	if (len >= MAX_STRING) MUQ_WARN ("string too long (%d) for to-lower",(int)len);
	if (len != stg_Get_Bytes( src, MAX_STRING, stg, 0 )) {
	    MUQ_WARN ("to-lower: internal error");
	    src[ len ] = '\0';
	}
	job_string_upcase( dst, src, len );
	if (STRCMP( src, != ,dst ))   *jS.s = stg_From_Buffer( dst, len );
    }
}

 /***********************************************************************/
 /*-    job_P_Secure_Hash -- "secureHash" operator.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Secure_Hash(
    void
) {
    /* Get size of block, verify stack holds that much: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Stg_Arg( 0 );

    {   Vm_Obj stg = jS.s[0];
        Vm_Int len = stg_Len( stg );
	Vm_Chr src[ MAX_STRING ];

	if (len >= MAX_STRING) MUQ_WARN ("string too long (%d) for secureHash",(int)len);
	if (len != stg_Get_Bytes( src, MAX_STRING, stg, 0 )) {
	    MUQ_WARN ("secureHash: internal error");
	    src[ len ] = '\0';
	}
	{   Vm_Uch digest[ 20 ];
	    Vm_Uch ascii_digest[ 48 ];
	    sha_Digest( digest, src, len );
	    {   int  i;
		for (i = 0;   i < 20;   ++i) {
		    sprintf(&ascii_digest[i*2],"%02x",digest[i]);
	    }   }
	    *jS.s = stg_From_Buffer( ascii_digest, 40 );
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Secure_Hash_Binary -- "secureHashBinary" operator.	*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Secure_Hash_Binary(
    void
) {
    /* Get size of block, verify stack holds that much: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Stg_Arg( 0 );

    {   Vm_Obj stg = jS.s[0];
        Vm_Int len = stg_Len( stg );
	Vm_Chr src[ MAX_STRING ];

	if (len >= MAX_STRING) MUQ_WARN ("string too long (%d) for secureHash",(int)len);
	if (len != stg_Get_Bytes( src, MAX_STRING, stg, 0 )) {
	    MUQ_WARN ("secureHash: internal error");
	    src[ len ] = '\0';
	}
	{   Vm_Uch digest[ 20 ];
	    sha_Digest( digest, src, len );
	    *jS.s = stg_From_Buffer( digest, 20 );
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Secure_Hash_Fixnum -- "secureHashFixnum" operator.	*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Secure_Hash_Fixnum(
    void
) {
    /* Get size of block, verify stack holds that much: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Stg_Arg( 0 );

    {   Vm_Obj stg = jS.s[0];
        Vm_Int len = stg_Len( stg );
	Vm_Chr src[ MAX_STRING ];

	if (len >= MAX_STRING) MUQ_WARN ("string too long (%d) for secureHash",(int)len);
	if (len != stg_Get_Bytes( src, MAX_STRING, stg, 0 )) {
	    MUQ_WARN ("secureHash: internal error");
	    src[ len ] = '\0';
	}
	{   Vm_Uch digest[ 20 ];
	    Vm_Unt result = 0;
	    sha_Digest( digest, src, len );
            #if VM_INTBYTES > 4
	    result |= ((Vm_Unt)digest[7]) << 56;
	    result |= ((Vm_Unt)digest[6]) << 48;
	    result |= ((Vm_Unt)digest[5]) << 40;
	    result |= ((Vm_Unt)digest[4]) << 32;
	    #endif
	    result |= ((Vm_Unt)digest[3]) << 24;
	    result |= ((Vm_Unt)digest[2]) << 16;
	    result |= ((Vm_Unt)digest[1]) <<  8;
	    result |= ((Vm_Unt)digest[0])      ;
	    result &= ((~((Vm_Unt)0))>>2);	/* Zero high two bits.	*/
	    *jS.s = OBJ_FROM_UNT(result);	/* Always nonnegative.	*/
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
