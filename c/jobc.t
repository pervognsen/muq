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
/* Copyright (c) 1993-2000, by Jeff Prothero.				*/
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

#include "All.h"
#include "jobprims.h"

/************************************************************************/
/*-    Statics								*/
/************************************************************************/


/************************************************************************/
/*-    Public fns, true prims for jobprims.c	 			*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_P_Read_Next_Muf_Token --					*/
 /***********************************************************************/

/* ( stg beg -- end beg typ ) */

/****************************************************************/
/* This prim returns the next muf token in			*/
/* the given stg.						*/
/* INPUT:							*/
/*   'stg' must be a stg instance.				*/
/*   'beg' is the integer offset to begin scanning.		*/
/* OUTPUT:							*/
/*   'beg' is integer offset of first char in token.		*/
/*   'end' is integer offset of last char in token.		*/
/*   'typ' is the type of token found:				*/
/*         "afn": quote-colon token (':).			*/
/*         "qfn": quoted function name ('abc).			*/
/*         "flt": floating-point numbr (1.2).			*/
/*         "dbl": double-precision floating-point numbr (1.2d).	*/
/*         "int": integer (12).					*/
/*         "stg": double-quoted string ("abc").			*/
/*         "chr": single-quoted string ('a').			*/
/*         "id" : generic identifier (abc).			*/
/*         0    : nothing but whitespace found.			*/
/****************************************************************/

void
job_P_Read_Next_Muf_Token(
    void
) {

    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Stg_Arg( -1 );
    
    job_Guarantee_Headroom( 1 );

    {   Vm_Obj stg    = jS.s[-1];
	Vm_Unt beg_in = OBJ_TO_UNT( jS.s[0] );

	Vm_Int beg_out;
	Vm_Int end_out;
	Vm_Obj typ_out;

	muf_Read_Next_Muf_Token( &beg_out, &end_out, &typ_out, beg_in, stg );

	++jS.s;
	jS.s[  0 ] =               typ_out  ;
	jS.s[ -1 ] = OBJ_FROM_INT( beg_out );
	jS.s[ -2 ] = OBJ_FROM_INT( end_out );
    }
}

 /***********************************************************************/
 /*-    job_P_Read_Stream --						*/
 /***********************************************************************/

void
job_P_Read_Stream(
    void
) {
    /* Read from appropriate mss: */
    Vm_Obj mss    = *jS.s;

    job_Guarantee_Mss_Arg(   0 );

    mss = job_Will_Read_Message_Stream( mss );

    {   Mss_A_Msg  msg;
	{   Vm_Uch buf[ MSS_MAX_MSG_VECTOR ];
	    Vm_Obj obj[ MSS_MAX_MSG_VECTOR ];
	    Vm_Int bytes_read;
	    bytes_read = mss_Read(
		obj,
		MSS_MAX_MSG_VECTOR,
		OBJ_T,
		&msg,
		mss,
		TRUE	/* ok_to_block */
	    );

	    /* Copy values from obj[] to     */
	    /* buf[], converting from        */
	    /* Vm_Obj to Vm_Uch as we go and */
	    /* dropping non-char values:     */
{	    Vm_Int cat = 0;
	    Vm_Int rat = 0;
	    Vm_Uch*dst = (Vm_Uch*)buf;
	    Vm_Obj val;
	    while (rat < bytes_read) {
		val = obj[ rat++ ];
		if (OBJ_IS_CHAR(val)) dst[ cat++ ] = OBJ_TO_CHAR(val);
	    }
	    bytes_read = cat;

	    *  jS.s = stg_From_Buffer( buf, bytes_read );
            *++jS.s = msg.who;
}
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Reset -- ( asm|stack -- )					*/
 /***********************************************************************/

void
job_P_Reset(
    void
) {
    Vm_Obj o = *jS.s;
    job_Guarantee_N_Args(  1 );
    job_Must_Control(      0 );

    if (OBJ_IS_OBJ(o)) {
	if (OBJ_IS_CLASS_ASM(o)) {
	    asm_Reset(       o);
	    --jS.s;
	    return;
	}
	if (OBJ_IS_CLASS_STK(o)) {
	    stk_Reset(       o);
	    --jS.s;
	    return;
	}
	if (OBJ_IS_CLASS_STM(o)) {
	    stm_Reset(       o);
	    --jS.s;
	    return;
	}
	if (OBJ_IS_CLASS_LOK(o)) {
	    lok_Release(     o);
	    --jS.s;
	    return;
	}
	if (OBJ_IS_CLASS_MSS(o)) {
	    mss_Reset(	     o);
	}
    }
    MUQ_WARN ("reset: don't know how to reset that.");
}

 /***********************************************************************/
 /*-    job_P_Drop_Single_Quotes -- "|dropSingleQuotes" operator.	*/
 /***********************************************************************/

void
job_P_Drop_Single_Quotes(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Obj rdt = JOB_P( jS.job )->readtable;
    Rdt_P  r   = RDT_P(rdt);
    Vm_Int block_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_N_Args(               1 );
    job_Guarantee_Blk_Arg(              0 );
    if (block_size <= 1)   return;
    job_Guarantee_N_Args(    block_size+2 );

    /* Find block, drop singleQuote chars: */
    {   register Vm_Obj* cat   = &jS.s[ -block_size ]; /* Base of our block. */
	register Vm_Obj* mat   = &jS.s[           0 ];
        register Vm_Obj* rat   = cat;
	register Vm_Int  quoted= FALSE;
	register Vm_Obj  tmp;
	while (rat < mat) {
	    tmp = *rat++;
            if (quoted) {
		quoted = FALSE;
		*cat++ = tmp;
	    } else if (r->slot[OBJ_TO_CHAR(tmp)&0xFF].kind==RDT_SINGLE_ESCAPE){
		quoted = TRUE;
	    } else {
		*cat++ = tmp;
	    }
        }
	*cat = OBJ_FROM_BLK( block_size - (rat-cat) );
	jS.s = cat;
    }
}

 /***********************************************************************/
 /*-    job_P_Over -- 'over'						*/
 /***********************************************************************/

void
job_P_Over(
    void
) {
    Vm_Obj to_dup = jS.s[-1];
    job_Guarantee_N_Args(2);
    *++jS.s = to_dup;
}

 /***********************************************************************/
 /*-    job_P_Rot -- Rotate three stack elements.			*/
 /***********************************************************************/

void
job_P_Rot(
    void
) {
    job_Guarantee_N_Args( 3 );
    {   Vm_Obj c = jS.s[-2];    
	jS.s[-2] = jS.s[-1];
	jS.s[-1] = jS.s[ 0];
	jS.s[ 0] = c       ;
    }
}

 /***********************************************************************/
 /*-    job_P_Rotate --							*/
 /***********************************************************************/

/* Dropped this because it conflicts     */
/* with typechecking of argument counts, */
/* and |rotate is usually more to the    */
/* point anyhow, I suspect:              */
#ifdef DROPPED
void
job_P_Rotate(
    void
) {

    Vm_Obj c;
    register Vm_Obj* s = jS.s;
    register Vm_Int  i = OBJ_TO_INT(*s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    --s;
    if        (i>0) {
        job_Guarantee_N_Args( i+1 );
        c=s[1-i];
        while(--i>0) s[-i]=s[1-i];
        s[0]=c;
    } else if (i<0) {
	Vm_Int j = -i;
	i = -i;
        job_Guarantee_N_Args( i+1 );
        c=s[0];
        for (i=0; i<j; ++i) s[-i]=s[-i-1];
        s[1-j]=c;
    }
    jS.s = s;
}
#endif

 /***********************************************************************/
 /*-    job_P_Rplaca -- Overwrite CAR of cons cell.			*/
 /***********************************************************************/

void
job_P_Rplaca(
    void
) {
    job_Guarantee_N_Args( 2 );
    if (OBJ_IS_EPHEMERAL_LIST(jS.s[-1])) {
	Vm_Obj owner;
	(void) ECN_P(&owner,jS.s[-1]);
	if (owner != jS.j.acting_user
	&& (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
	){
	    MUQ_WARN ("May not modify this ephemeral cons cell");
	}
	ECN_P(&owner,jS.s[-1])->car = *jS.s;
	jS.s -= 2;
	return;
    }
    job_Guarantee_Cons_Arg( -1);
    job_Must_Control_Object(-1);

    {   Vm_Obj    cons        = jS.s[ -1 ];
        LST_P(    cons )->car = jS.s[  0 ];
        vm_Dirty( cons );
    }
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Rplacd -- Overwrite CDR of cons cell.			*/
 /***********************************************************************/

void
job_P_Rplacd(
    void
) {
    job_Guarantee_N_Args( 2 );
    if (OBJ_IS_EPHEMERAL_LIST(jS.s[-1])) {
	Vm_Obj owner;
	(void) ECN_P(&owner,jS.s[-1]);
	if (owner != jS.j.acting_user
	&& (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
	){
	    MUQ_WARN ("May not modify this ephemeral cons cell");
	}
	ECN_P(&owner,jS.s[-1])->cdr = *jS.s;
	jS.s -= 2;
	return;
    }
    job_Guarantee_Cons_Arg( -1);
    job_Must_Control_Object(-1);

    {   Vm_Obj    cons        = jS.s[ -1 ];
        LST_P(    cons )->cdr = jS.s[  0 ];
        vm_Dirty( cons );
    }
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Find_Method -- Locate method for message.			*/
 /***********************************************************************/

#ifdef OLD
/* We don't want people accidentally or */
/* maliciously hanging the interpreter  */
/* with a very large and/or circular    */
/* inheritance tree, so we arbitrarily  */
/* impose a small finite limit on the   */
/* number of parents which we will      */
/* check without reporting an error:    */
#ifndef JOB_MAX_SUPERCLASSES
#define JOB_MAX_SUPERCLASSES (1024)
#endif

void
job_P_Find_Method(
    void
) {
    /* { recipient key -> method class } */
    Vm_Int class_quota = JOB_MAX_SUPERCLASSES;
    Vm_Obj recipient   = jS.s[-1];
    Vm_Obj key         = jS.s[ 0];
    Vm_Obj val_obj     = OBJ_NIL;	/* Obj on which key was found. */

    job_Guarantee_N_Args(      2 );
    job_Guarantee_Object_Arg( -1 );

    {   Vm_Obj method  = obj_X_Get_With_Inheritance(
	    &val_obj,
	    &class_quota,
	    recipient,
	    key,
	    OBJ_PROP_METHOD
	);
	if (method == OBJ_NOT_FOUND) {
	    MUQ_WARN ("No such method.");
	}
	jS.s[-1] = method ;
	jS.s[ 0] = val_obj;
    }
}

 /***********************************************************************/
 /*-    job_P_Find_Method_P -- Maybe locate method for message.		*/
 /***********************************************************************/

void
job_P_Find_Method_P(
    void
) {
    /* { recipient key -> success method class } */
    Vm_Int class_quota = JOB_MAX_SUPERCLASSES;
    Vm_Obj recipient   = jS.s[-1];
    Vm_Obj key         = jS.s[ 0];
    Vm_Obj val_obj     = OBJ_NIL;	/* Obj on which key was found. */
    Vm_Obj success     = OBJ_TRUE;

    job_Guarantee_N_Args(      2 );
    job_Guarantee_Object_Arg( -1 );

    {   Vm_Obj method  = obj_X_Get_With_Inheritance(
	    &val_obj,
	    &class_quota,
	    recipient,
	    key,
	    OBJ_PROP_METHOD
	);
	if (method == OBJ_NOT_FOUND) {
	    method  = OBJ_NIL;
	    success = OBJ_NIL;
	}
	++jS.s;
	jS.s[-2] = success;
	jS.s[-1] = method;
	jS.s[ 0] = val_obj;
    }
}
#endif

 /***********************************************************************/
 /*-    job_P_Finish_Assembly -- { force arity fn asm -> cfn }		*/
 /***********************************************************************/

void
job_P_Finish_Assembly(
    void
) {
    Vm_Obj asm   = jS.s[  0 ];
    Vm_Obj fn    = jS.s[ -1 ];
    Vm_Obj arity = jS.s[ -2 ];
    Vm_Obj force = jS.s[ -3 ];

    job_Guarantee_N_Args(    4 );
    job_Guarantee_Asm_Arg(   0 );
    job_Guarantee_Fn_Arg(   -1 );
    job_Guarantee_Int_Arg(  -2 );
    job_Must_Control_Object( 0 );

    {   Vm_Obj result = asm_Cfn_Build( asm, fn, arity, force!=OBJ_NIL );
        jS.s -= 3;	/* Must be done only after above returns. */
	*jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Get_Here -- Return current working directory.		*/
 /***********************************************************************/

void
job_P_Get_Here(
    void
) {
    /* Seize one stack location, and push result in it: */
    *++jS.s = JOB_P(jS.job)->here_obj;
}

 /***********************************************************************/
 /*-    job_P_Get_Mos_Key -- Return mosKey for given object.		*/
 /***********************************************************************/

void
job_P_Get_Mos_Key(
    void
) {
    /* 'obj' can be absolutely anything: */
    job_Guarantee_N_Args( 1 );

    {   Vm_Obj obj = jS.s[ 0];
	Vm_Obj key = (*mod_Type_Summary[ OBJ_TYPE(obj) ]->get_mos_key)( obj );

	#if MUQ_IS_PARANOID
	if (!OBJ_IS_OBJ(key) || !OBJ_IS_CLASS_KEY(key)) {
	    MUQ_WARN("getMosKey: Result not a key?!");
	}
	#endif

	jS.s[  0 ] = key;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Assembler -- { -> asm }				*/
 /***********************************************************************/

void
job_P_Make_Assembler(
    void
) {
    /* Done in two lines to make sure ++ gets */
    /* done only if obj_Alloc succeeds:       */
    Vm_Obj asm = obj_Alloc( OBJ_CLASS_A_ASM, 0 );
    *++jS.s = asm;
}

 /***********************************************************************/
 /*-    job_P_Egcd -- { bnm bnm -> bnm bnm bnm }			*/
 /***********************************************************************/

void
job_P_Egcd(
    void
) {
    /* Handle arbitrary bignum and fixnum combinations: */
    Vm_Obj a = jS.s[-1];
    Vm_Obj b = jS.s[ 0];

    job_Guarantee_N_Args(   2 );

    if           (OBJ_IS_BIGNUM(a) && !BNM_P(a)->private) {
        if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) {
	    Vm_Obj u;
	    Vm_Obj v;
	    Vm_Obj gcd    = bnm_Egcd( &u, &v, jS.s[-1], jS.s[0] );
	    ++jS.s;
	    jS.s[-2] = gcd;
	    jS.s[-1] = u;
	    jS.s[ 0] = v;
	    return;
	} else if  (OBJ_IS_INT(   b)) {
	    Vm_Obj u;
	    Vm_Obj v;
	    Vm_Obj gcd    = bnm_EgcdBI( &u, &v, jS.s[-1], jS.s[0] );
	    ++jS.s;
	    jS.s[-2] = gcd;
	    jS.s[-1] = u;
	    jS.s[ 0] = v;
	    return;
	}
    } else if    (OBJ_IS_INT(   a)) {
	if       (OBJ_IS_BIGNUM(b) && !BNM_P(b)->private) {
	    Vm_Obj u;
	    Vm_Obj v;
	    Vm_Obj gcd    = bnm_EgcdIB( &u, &v, jS.s[-1], jS.s[0] );
	    ++jS.s;
	    jS.s[-2] = gcd;
	    jS.s[-1] = u;
	    jS.s[ 0] = v;
	    return;
	} else if  (OBJ_IS_INT(   b)) {
	    Vm_Obj u;
	    Vm_Obj v;
	    Vm_Obj gcd    = bnm_EgcdII( &u, &v, jS.s[-1], jS.s[0] );
	    ++jS.s;
	    jS.s[-2] = gcd;
	    jS.s[-1] = u;
	    jS.s[ 0] = v;
	    return;
	}
    }

    job_Guarantee_Bnm_Arg(  -1 );
    job_Guarantee_Bnm_Arg(   0 );
}

 /***********************************************************************/
 /*-    job_P_Exptmod -- { i i i -> i }					*/
 /***********************************************************************/

void
job_P_Exptmod(
    void
) {
    if (!OBJ_IS_INT(jS.s[-2]))  job_Guarantee_Bnm_Arg(  -2 );
    if (!OBJ_IS_INT(jS.s[-1]))  job_Guarantee_Bnm_Arg(  -1 );
    if (!OBJ_IS_INT(jS.s[ 0]))  job_Guarantee_Bnm_Arg(   0 );
    {   Vm_Obj result = bnm_Exptmod( jS.s[-2], jS.s[-1], jS.s[0] );
        jS.s -= 2;
        *jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Multmod_Bignum -- { bnm bnm -> bnm }			*/
 /***********************************************************************/

#ifdef UNUSED
void
job_P_Multmod_Bignum(
    void
) {
    job_Guarantee_Bnm_Arg(  -2 );
    job_Guarantee_Bnm_Arg(  -1 );
    job_Guarantee_Bnm_Arg(   0 );
    {   Vm_Obj result = bnm_Multmod( jS.s[-2], jS.s[-1], jS.s[0] );
        jS.s -= 2;
        *jS.s = result;
    }
}
#endif

 /***********************************************************************/
 /*-    job_P_Generate_Diffie_Hellman_Key_Pair -- { bnm bnm -> bnm bnm }*/
 /***********************************************************************/

void
job_P_Generate_Diffie_Hellman_Key_Pair(
    void
) {
    Vm_Obj publicKey;
    Vm_Obj privateKey;

    Vm_Obj g = jS.s[ -1 ];
    Vm_Obj p = jS.s[  0 ];

    job_Guarantee_Bnm_Arg(  -1 );
    job_Guarantee_Bnm_Arg(   0 );

    privateKey = bnm_Generate_Diffie_Hellman_Key_Pair( &publicKey, g, p );

    jS.s[-1] = privateKey;
    jS.s[ 0] = publicKey;
}

 /***********************************************************************/
 /*-    job_P_Generate_Diffie_Hellman_Shared_Secret bnm bnm bnm -> bnm	*/
 /***********************************************************************/

void
job_P_Generate_Diffie_Hellman_Shared_Secret(
    void
) {
    Vm_Obj sharedSecret;

    Vm_Obj g = jS.s[ -2 ];
    Vm_Obj e = jS.s[ -1 ];
    Vm_Obj p = jS.s[  0 ];

    if (!OBJ_IS_BIGNUM(e)
    || BNM_P(e)->private != BNM_DIFFIE_HELLMAN_PRIVATE_KEY
    ){
	MUQ_WARN("generateDiffieHellmanSharedSecret: 2nd arg must be a #<DiffieHellmanPrivateKey>");
    } 
    job_Guarantee_Bnm_Arg(  -2 );
    job_Guarantee_Bnm_Arg(   0 );

    sharedSecret = bnm_Generate_Diffie_Hellman_Shared_Secret( g, e, p );

    jS.s -= 2;

    jS.s[ 0] = sharedSecret;
}

 /***********************************************************************/
 /*-    job_P_Make_Bignum -- { -> bnm }					*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Make_Bignum(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len >= MAX_STRING) MUQ_WARN ("makeBignum arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("makeBignum: internal error");
	}
	buf[len] = '\0';	
	*jS.s = bnm_Alloc_Asciz( buf );
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Hashed_Btree -- { -> btree }				*/
 /***********************************************************************/

void
job_P_Make_Hashed_Btree(
    void
) {
    /* Done in two lines to make sure ++ gets */
    /* done only if obj_Alloc succeeds:       */
    Vm_Obj asm = dil_Alloc();
    *++jS.s = asm;
}

 /***********************************************************************/
 /*-    job_P_Make_Sorted_Btree -- { -> btree }				*/
 /***********************************************************************/

void
job_P_Make_Sorted_Btree(
    void
) {
    /* Done in two lines to make sure ++ gets */
    /* done only if obj_Alloc succeeds:       */
    Vm_Obj asm = sil_Alloc();
    *++jS.s = asm;
}

 /***********************************************************************/
 /*-    job_Btree_Get_Asciz						*/
 /***********************************************************************/

Vm_Obj
job_Btree_Get_Asciz(
    Vm_Obj btree,
    Vm_Uch*key
) {
    if (btree == OBJ_NULL_DIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_DIL(btree) || OBJ_IS_CLASS_DIN(btree)))){
	return  dil_Get_Asciz( btree, key );
    }
    if (btree == OBJ_NULL_SIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SIL(btree) || OBJ_IS_CLASS_SIN(btree)))){
	return  sil_Get_Asciz( btree, key );
    }
    if (btree == OBJ_NULL_SEL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SEL(btree) || OBJ_IS_CLASS_SEN(btree)))){
	return  sel_Get_Asciz( btree, key );
    }
    MUQ_WARN("job_Btree_Get_Asciz: unsupported treetype");
    return OBJ_NIL; /* Just to quiet compilers */
}

 /***********************************************************************/
 /*-    job_Btree_Get							*/
 /***********************************************************************/

Vm_Obj
job_Btree_Get(
    Vm_Obj btree,
    Vm_Obj key
) {
    if (btree == OBJ_NULL_DIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_DIL(btree) || OBJ_IS_CLASS_DIN(btree)))){
	return dil_Get( btree, key );
    }
    if (btree == OBJ_NULL_MIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_MIL(btree) || OBJ_IS_CLASS_MIN(btree)))){
	return mil_Get( btree, key );
    }
    if (btree == OBJ_NULL_PIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_PIL(btree) || OBJ_IS_CLASS_PIN(btree)))){
	return pil_Get( btree, key );
    }
    if (btree == OBJ_NULL_SIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SIL(btree) || OBJ_IS_CLASS_SIN(btree)))){
	return sil_Get( btree, key );
    }
    if (btree == OBJ_NULL_SEL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SEL(btree) || OBJ_IS_CLASS_SEN(btree)))){
	return sel_Get( btree, key );
    }
    MUQ_WARN("job_Btree_Get: unsupported treetype");
    return OBJ_NIL; /* Just to quiet compilers */
}

 /***********************************************************************/
 /*-    job_P_Btree_Get -- { -> }					*/
 /***********************************************************************/

void
job_P_Btree_Get(
    void
) {
    job_Guarantee_Btree_Arg( -1 );
    {   Vm_Obj btree = jS.s[ -1 ];
	Vm_Obj result= job_Btree_Get( btree, jS.s[0] );
        if (result == OBJ_NOT_FOUND) {
	    jS.s[-1] = OBJ_NIL;
	    jS.s[ 0] = OBJ_NIL;
	} else {
	    jS.s[-1] = OBJ_T;
	    jS.s[ 0] = result;
	}
    }
}

 /***********************************************************************/
 /*-    job_Btree_Set							*/
 /***********************************************************************/

Vm_Obj
job_Btree_Set(
    Vm_Obj btree,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Unt dbfile
) {
    if (btree == OBJ_NULL_DIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_DIL(btree) || OBJ_IS_CLASS_DIN(btree)))){
	return  dil_Set( btree, key, val, dbfile );
    }
    if (btree == OBJ_NULL_SIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SIL(btree) || OBJ_IS_CLASS_SIN(btree)))){
	return  sil_Set( btree, key, val, dbfile );
    }
    if (btree == OBJ_NULL_SEL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SEL(btree) || OBJ_IS_CLASS_SEN(btree)))){
	return  sel_Set( btree, key, val, dbfile );
    }
    MUQ_WARN("job_Btree_Set: unsupported treetype");
    return OBJ_NIL; /* Just to quiet compilers */
}

 /***********************************************************************/
 /*-    job_P_Btree_Set -- { -> }					*/
 /***********************************************************************/

void
job_P_Btree_Set(
    void
) {
    job_Guarantee_N_Args( 3 );
    job_Guarantee_Btree_Arg( -2 );
    {   Vm_Obj btree  = jS.s[ -2 ];
	Vm_Unt dbfile;
	Vm_Obj result;
	if (OBJ_IS_OBJ(btree)) {
	    dbfile = VM_DBFILE(btree);
	} else {
	    dbfile = VM_DBFILE(JOB_P(jS.job)->package);
	}
	result = job_Btree_Set( btree, jS.s[-1], jS.s[0], dbfile );
	jS.s -= 2;
	*jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_Btree_Del							*/
 /***********************************************************************/

Vm_Obj
job_Btree_Del(
    Vm_Obj btree,
    Vm_Obj key
) {
    if (btree == OBJ_NULL_DIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_DIL(btree) || OBJ_IS_CLASS_DIN(btree)))){
	return  dil_Del( btree, key );
    }
    if (btree == OBJ_NULL_SIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SIL(btree) || OBJ_IS_CLASS_SIN(btree)))){
	return  sil_Del( btree, key );
    }
    if (btree == OBJ_NULL_SEL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SEL(btree) || OBJ_IS_CLASS_SEN(btree)))){
	return  sel_Del( btree, key );
    }
    MUQ_WARN("job_Btree_Del: unsupported treetype");
    return OBJ_NIL; /* Just to quiet compilers */
}

 /***********************************************************************/
 /*-    job_P_Btree_Delete -- { -> }					*/
 /***********************************************************************/

void
job_P_Btree_Delete(
    void
) {
    job_Guarantee_N_Args( 2 );
    job_Guarantee_Btree_Arg( -1 );
    {   Vm_Obj btree = jS.s[ -1 ];
        Vm_Obj result= job_Btree_Del( btree, jS.s[0] );
	*--jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_Btree_First							*/
 /***********************************************************************/

Vm_Obj
job_Btree_First(
    Vm_Obj btree
) {
    if (btree == OBJ_NULL_DIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_DIL(btree) || OBJ_IS_CLASS_DIN(btree)))){
	return  dil_First( btree );
    }
    if (btree == OBJ_NULL_SIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SIL(btree) || OBJ_IS_CLASS_SIN(btree)))){
	return  sil_First( btree );
    }
    if (btree == OBJ_NULL_SEL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SEL(btree) || OBJ_IS_CLASS_SEN(btree)))){
	return  sel_First( btree );
    }
    MUQ_WARN("job_Btree_First: unsupported treetype");
    return OBJ_NIL; /* Just to quiet compilers */
}

 /***********************************************************************/
 /*-    job_P_Btree_First -- { -> }					*/
 /***********************************************************************/

void
job_P_Btree_First(
    void
) {
    job_Guarantee_Btree_Arg( 0 );
    {   Vm_Obj btree = jS.s[ 0 ];
	Vm_Obj result= job_Btree_First( btree );
	++jS.s; 
        if (result == OBJ_NOT_FOUND) {
	    jS.s[-1] = OBJ_NIL;
	    jS.s[ 0] = OBJ_NIL;
	} else {
	    jS.s[-1] = OBJ_T;
	    jS.s[ 0] = result;
    }	}
}

 /***********************************************************************/
 /*-    job_Btree_Next							*/
 /***********************************************************************/

Vm_Obj
job_Btree_Next(
    Vm_Obj btree,
    Vm_Obj lastkey
) {
    if (btree == OBJ_NULL_DIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_DIL(btree) || OBJ_IS_CLASS_DIN(btree)))){
	return  dil_Next( btree, lastkey );
    }
    if (btree == OBJ_NULL_SIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SIL(btree) || OBJ_IS_CLASS_SIN(btree)))){
	return  sil_Next( btree, lastkey );
    }
    if (btree == OBJ_NULL_SEL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SEL(btree) || OBJ_IS_CLASS_SEN(btree)))){
	return  sel_Next( btree, lastkey );
    }
    MUQ_WARN("job_Btree_Next: unsupported treetype");
    return OBJ_NIL; /* Just to quiet compilers */
}

 /***********************************************************************/
 /*-    job_P_Btree_Next -- { -> }					*/
 /***********************************************************************/

void
job_P_Btree_Next(
    void
) {
    job_Guarantee_Btree_Arg( -1 );
    {   Vm_Obj btree = jS.s[ -1 ];
	Vm_Obj result = job_Btree_Next( btree, jS.s[0] );
        if (result == OBJ_NOT_FOUND) {
	    jS.s[-1] = OBJ_NIL;
	    jS.s[ 0] = OBJ_NIL;
	} else {
	    jS.s[-1] = OBJ_T;
	    jS.s[ 0] = result;
    }	}
}

 /***********************************************************************/
 /*-    job_Copy_Btree -- 						*/
 /***********************************************************************/

Vm_Obj
job_Copy_Btree(
    Vm_Obj btree
) {
    if (btree == OBJ_NULL_DIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_DIL(btree) || OBJ_IS_CLASS_DIN(btree)))){
	return  dil_Copy( btree );
    }
    if (btree == OBJ_NULL_SIL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SIL(btree) || OBJ_IS_CLASS_SIN(btree)))){
	return  sil_Copy( btree );
    }
    if (btree == OBJ_NULL_SEL || (OBJ_IS_OBJ(btree) && (OBJ_IS_CLASS_SEL(btree) || OBJ_IS_CLASS_SEN(btree)))){
	return  sel_Copy( btree );
    }
    MUQ_WARN("job_Copy_Btree: unsupported treetype");
    return OBJ_NIL; /* Just to quiet compilers */
}

 /***********************************************************************/
 /*-    job_P_Copy_Btree -- { -> }					*/
 /***********************************************************************/

void
job_P_Copy_Btree(
    void
) {
    job_Guarantee_Btree_Arg( 0 );
    {   Vm_Obj btree = jS.s[ 0 ];
	Vm_Obj result= job_Copy_Btree( btree );
        *jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_From_Block -- "]makeVector" operator.	*/
 /***********************************************************************/

void
job_P_Make_Vector_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt siz = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( siz+2 );

	{   /* Create a len-'siz' vector: */
	    Vm_Obj vec = vec_Alloc( siz, OBJ_FROM_INT(0) );
	    /* Locate it: */
	    register Vec_P   v = VEC_P( vec );
	    register Vm_Obj* b = &jS.s[ -siz ];
	    register Vm_Int  i = siz;
	    while (i --> 0)  v->slot[i] = b[i];
	    vm_Dirty(vec);

	    /* Pop block, leave vec on stack: */
	    jS.s -= siz+1;
	   *jS.s  = vec;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_I01_From_Block -- "]makeVectorI01" operator.	*/
 /***********************************************************************/

void
job_P_Make_Vector_I01_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

MUQ_WARN("]makeVectorI01 not implemented");
    /* Get size of block: */
    {   register Vm_Unt siz = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( siz+2 );

	{   /* Create a len-'siz' vector: */
	    Vm_Obj vec = vec_Alloc( siz, OBJ_FROM_INT(0) );
	    /* Locate it: */
	    register Vec_P   v = VEC_P( vec );
	    register Vm_Obj* b = &jS.s[ -siz ];
	    register Vm_Int  i = siz;
	    while (i --> 0)  v->slot[i] = b[i];
	    vm_Dirty(vec);

	    /* Pop block, leave vec on stack: */
	    jS.s -= siz+1;
	   *jS.s  = vec;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_I08_From_Block -- "]makeVectorI08" operator.	*/
 /***********************************************************************/

void
job_P_Make_Vector_I08_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt siz = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( siz+2 );

	{   /* Create a len-'siz' vector: */
	    Vm_Obj vec = i08_Alloc( siz, OBJ_FROM_INT(0) );
	    /* Locate it: */
	    register Stg_P   v = STG_P( vec );
	    register Vm_Obj* b = &jS.s[ -siz ];
	    register Vm_Int  i = siz;
	    while (i --> 0) {
	        register Vm_Obj  o = b[i];
		if (OBJ_IS_INT( o)) {  v->byte[i] = OBJ_TO_INT( o); continue; }
		if (OBJ_IS_CHAR(o)) {  v->byte[i] = OBJ_TO_CHAR(o); continue; }
		MUQ_WARN("]makeVectorI08 arg neither char nor fixnum");
	    }
	    vm_Dirty(vec);

	    /* Pop block, leave vec on stack: */
	    jS.s -= siz+1;
	   *jS.s  = vec;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_I16_From_Block -- "]makeVectorI16" operator.	*/
 /***********************************************************************/

void
job_P_Make_Vector_I16_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt siz = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( siz+2 );

/* buggo, all these routines will have problems if */
/* length zero is specified, due to the special    */
/* length-zero value vm.t returns.  Probably need  */
/* to change vm.t. */
	{   /* Create a len-'siz' vector: */
	    Vm_Obj vec = i16_Alloc( siz, OBJ_FROM_INT(0) );
	    /* Locate it: */
	    register I16_Header v = I16_P( vec );
	    register Vm_Obj* b = &jS.s[ -siz ];
	    register Vm_Int  i = siz;
	    while (i --> 0)  {
	        register Vm_Obj  o = b[i];
		if (!OBJ_IS_INT(o)) MUQ_WARN("]makeVectorI16 arg not a fixnum");
		v->slot[i] = OBJ_TO_INT(o);
	    }
	    vm_Dirty(vec);

	    /* Pop block, leave vec on stack: */
	    jS.s -= siz+1;
	   *jS.s  = vec;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_I32_From_Block -- "]makeVectorI32" operator.	*/
 /***********************************************************************/

void
job_P_Make_Vector_I32_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt siz = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( siz+2 );

	{   /* Create a len-'siz' vector: */
	    Vm_Obj vec = i32_Alloc( siz, OBJ_FROM_INT(0) );
	    /* Locate it: */
	    register I32_Header v = I32_P( vec );
	    register Vm_Obj* b = &jS.s[ -siz ];
	    register Vm_Int  i = siz;
	    while (i --> 0) {
	        register Vm_Obj  o = b[i];
		if (!OBJ_IS_INT(o)) MUQ_WARN("]makeVectorI32 arg not a fixnum");
		v->slot[i] = OBJ_TO_INT(o);
	    }
	    vm_Dirty(vec);

	    /* Pop block, leave vec on stack: */
	    jS.s -= siz+1;
	   *jS.s  = vec;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_F32_From_Block -- "]makeVectorF32" operator.	*/
 /***********************************************************************/

void
job_P_Make_Vector_F32_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt siz = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( siz+2 );

	{   /* Create a len-'siz' vector: */
	    Vm_Obj vec = f32_Alloc( siz, OBJ_FROM_INT(0) );
	    /* Locate it: */
	    register F32_Header v = F32_P( vec );
	    register Vm_Obj* b = &jS.s[ -siz ];
	    register Vm_Int  i = siz;
	    while (i --> 0) {
	        register Vm_Obj  o = b[i];
		if (!OBJ_IS_FLOAT(o)) MUQ_WARN("]makeVectorF32 arg not a float");
		v->slot[i] = (float)OBJ_TO_FLOAT(o);
	    }
	    vm_Dirty(vec);

	    /* Pop block, leave vec on stack: */
	    jS.s -= siz+1;
	   *jS.s  = vec;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_F64_From_Block -- "]makeVectorF64" operator.	*/
 /***********************************************************************/

void
job_P_Make_Vector_F64_From_Block(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt siz = OBJ_TO_BLK( jS.s[0] );
        job_Guarantee_N_Args( siz+2 );

	{   /* Create a len-'siz' vector: */
	    Vm_Obj vec = f64_Alloc( siz, OBJ_FROM_INT(0) );
	    /* Locate it: */
	    register F64_Header v = F64_P( vec );
	    register Vm_Obj* b = &jS.s[ -siz ];
	    register Vm_Int  i = siz;
	    while (i --> 0) {
	        register Vm_Obj  o = b[i];
		if (!OBJ_IS_FLOAT(o)) MUQ_WARN("]makeVectorF64 arg not a float");
		v->slot[i] = (double)OBJ_TO_FLOAT(o);
	    }
	    vm_Dirty(vec);

	    /* Pop block, leave vec on stack: */
	    jS.s -= siz+1;
	   *jS.s  = vec;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Make_From_Keysvals_Block -- "]keysvals-new" operator.	*/
 /***********************************************************************/

void
job_P_Make_From_Keysvals_Block(
    void
) {
MUQ_FATAL ("New_From_Pair_Block unimplemented");
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Blk_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_BLK(*jS.s);
        job_Guarantee_N_Args( i+1 );

	/* Pop block: */
	jS.s -= i+1;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Lock -- { -> lock }					*/
 /***********************************************************************/

void
job_P_Make_Lock(
    void
) {
    /* Don't combine these two lines, we don't */
    /* want jS.s incremented until the call is */
    /* known to have succeeded w/o error:      */
    Vm_Obj lock = obj_Alloc( OBJ_CLASS_A_LOK, 0 );
    *++jS.s = lock;
}

 /***********************************************************************/
 /*-    job_P_Make_Muf -- { fn -> muf }					*/
 /***********************************************************************/

void
job_P_Make_Muf(
    void
) {
    job_Guarantee_N_Args( 1 );
    job_Guarantee_Fn_Arg( 0 );
    *jS.s = muf_Alloc( *jS.s );
}

 /***********************************************************************/
 /*-    job_P_Make_Index -- { -> obj }					*/
 /***********************************************************************/

void
job_P_Make_Index(
    void
) {
    Vm_Obj    o = obj_Alloc( OBJ_CLASS_A_NDX, 0 );
    *++jS.s = o;
}

 /***********************************************************************/
 /*-    job_P_Make_Index3D -- { -> obj }				*/
 /***********************************************************************/

void
job_P_Make_Index3D(
    void
) {
#ifdef SOMEDAY
    Vm_Obj    o = obj_Alloc( OBJ_CLASS_A_N3D, 0 );
    *++jS.s = o;
#else
    MUQ_WARN("makeIndex3D unimplemented");
#endif
}

 /***********************************************************************/
 /*-    job_P_Make_Set -- { -> set }					*/
 /***********************************************************************/

void
job_P_Make_Set(
    void
) {
    Vm_Obj    o;
    o = obj_Alloc( OBJ_CLASS_A_SET, 0 );
    *++jS.s = o;
}

 /***********************************************************************/
 /*-    job_P_Make_Hash -- { -> obj }					*/
 /***********************************************************************/

void
job_P_Make_Hash(
    void
) {
    Vm_Obj    o = obj_Alloc( OBJ_CLASS_A_HSH, 0 );

    *++jS.s = o;
}

 /***********************************************************************/
 /*-    job_P_Make_Plain -- { -> obj }					*/
 /***********************************************************************/

void
job_P_Make_Plain(
    void
) {
    Vm_Obj    o = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );

    *++jS.s = o;
}

 /***********************************************************************/
 /*-    job_P_Make_Fn -- { -> fn }					*/
 /***********************************************************************/

void
job_P_Make_Fn(
    void
) {
    Vm_Obj    fn = obj_Alloc( OBJ_CLASS_A_FN, 0 );
    *++jS.s = fn;
}

 /***********************************************************************/
 /*-    job_P_Make_Package -- { name -> package }			*/
 /***********************************************************************/

void
job_P_Make_Package(
    void
){
    /* Let job_P_Block_Make_Package do all the work: */
    *++jS.s = OBJ_FROM_INT(1);
    job_P_Block_Make_Package();
}

 /***********************************************************************/
 /*-    job_P_Make_Message_Stream -- { -> stream }			*/
 /***********************************************************************/

void
job_P_Make_Message_Stream(
    void
) {
    Vm_Obj result = obj_Alloc( OBJ_CLASS_A_MSS, 0 );
    *++jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Make_Stream -- { -> stream }				*/
 /***********************************************************************/

void
job_P_Make_Stream(
    void
) {
    Vm_Obj o = obj_Alloc( OBJ_CLASS_A_STM, 0 );
    *++jS.s  = o;
}

 /***********************************************************************/
 /*-    job_P_Make_Stack -- { -> stack }				*/
 /***********************************************************************/

void
job_P_Make_Stack(
    void
) {
    Vm_Obj o = obj_Alloc( OBJ_CLASS_A_STK, 0 );
    *++jS.s  = o;
}

 /***********************************************************************/
 /*-    job_P_Make_Job_Queue -- { -> joq }				*/
 /***********************************************************************/

void
job_P_Make_Job_Queue(
    void
) {
    Vm_Obj o = obj_Alloc( OBJ_CLASS_A_JOQ, 0 );
    *++jS.s  = o;
}

 /***********************************************************************/
 /*-    job_P_Make_String -- { a # -- string }				*/
 /***********************************************************************/

void
job_P_Make_String(
    void
) {
    Vm_Unt u   = OBJ_TO_UNT( jS.s[ 0] );
    Vm_Obj val =             jS.s[-1]  ;
    Vm_Int v;
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Int_Arg( 0 );
    if (OBJ_IS_CHAR(val)) {
	v = OBJ_TO_CHAR(val);
    } else {
	job_Guarantee_Int_Arg( -1 );
	v = OBJ_TO_INT(val);
    }
    val = stg_From_Spec( v, u );
    *--jS.s   = val;
}

 /***********************************************************************/
 /*-    job_P_Make_Array -- { a # -- array }				*/
 /***********************************************************************/

void
job_P_Make_Array(
    void
) {
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Int_Arg( 0 );
    {   Vm_Unt  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = ary_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Table -- { a # -- array }				*/
 /***********************************************************************/

void
job_P_Make_Table(
    void
) {
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Int_Arg( 0 );
    {   Vm_Unt  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = tbl_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector -- { a # -- vector }				*/
 /***********************************************************************/

void
job_P_Make_Vector(
    void
) {
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Int_Arg( 0 );
    {   Vm_Unt  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = vec_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_I01 -- { a # -- vector }			*/
 /***********************************************************************/

void
job_P_Make_Vector_I01(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );
    {   Vm_Unt  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = i01_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_I08 -- { a # -- vector }			*/
 /***********************************************************************/

void
job_P_Make_Vector_I08(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );
    {   Vm_Uch  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = i08_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_I16 -- { a # -- vector }			*/
 /***********************************************************************/

void
job_P_Make_Vector_I16(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );
    {   Vm_Unt  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = i16_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_I32 -- { a # -- vector }			*/
 /***********************************************************************/

void
job_P_Make_Vector_I32(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );
    {   Vm_Unt  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = i32_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_F32 -- { a # -- vector }			*/
 /***********************************************************************/

void
job_P_Make_Vector_F32(
    void
) {
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Int_Arg(    0 );
    job_Guarantee_Float_Arg( -1 );
    {   Vm_Unt  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = f32_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Vector_F64 -- { a # -- vector }			*/
 /***********************************************************************/

void
job_P_Make_Vector_F64(
    void
) {
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Int_Arg(    0 );
    job_Guarantee_Float_Arg( -1 );
    {   Vm_Unt  u = OBJ_TO_UNT( jS.s[ 0] );
        Vm_Obj  a =             jS.s[-1]  ;
	Vm_Obj  v = f64_Alloc( u, a );
	*--jS.s   = v;
    }
}

 /***********************************************************************/
 /*-    job_P_Make_Mos_Class -- 					*/
 /***********************************************************************/

void
job_P_Make_Mos_Class(
    void
) {
    Vm_Obj result;

    result = obj_Alloc( OBJ_CLASS_A_CDF, 0 );

    *++jS.s  = result;
}

 /***********************************************************************/
 /*-    job_P_Make_Mos_Key -- 						*/
 /***********************************************************************/

void
job_P_Make_Mos_Key(
    void
) {
    Vm_Obj result;

    Vm_Obj mos_class      =             jS.s[ -9 ]  ;
    Vm_Int unshared_slots = OBJ_TO_INT( jS.s[ -8 ] );
    Vm_Int   shared_slots = OBJ_TO_INT( jS.s[ -7 ] );
    Vm_Int parents        = OBJ_TO_INT( jS.s[ -6 ] );
    Vm_Int ancestors      = OBJ_TO_INT( jS.s[ -5 ] );
    Vm_Int slotargs	  = OBJ_TO_INT( jS.s[ -4 ] );
    Vm_Int methargs	  = OBJ_TO_INT( jS.s[ -3 ] );
    Vm_Int initargs       = OBJ_TO_INT( jS.s[ -2 ] );
    Vm_Int object_methods = OBJ_TO_INT( jS.s[ -1 ] );
    Vm_Int class_methods  = OBJ_TO_INT( jS.s[  0 ] );

    job_Guarantee_N_Args( 10 );

    job_Guarantee_Cdf_Arg( -9 );
    job_Guarantee_Int_Arg( -8 );
    job_Guarantee_Int_Arg( -7 );
    job_Guarantee_Int_Arg( -6 );
    job_Guarantee_Int_Arg( -5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );

    if (unshared_slots < 0) MUQ_WARN ("unsharedSlots must be >= 0");
    if (  shared_slots < 0) MUQ_WARN   ("sharedSlots must be >= 0");
    if (       parents < 0) MUQ_WARN       ("parents must be >= 0");
    if (     ancestors < 0) MUQ_WARN     ("ancestors must be >= 0");
    if (      slotargs < 0) MUQ_WARN      ("slotargs must be >= 0");
    if (      methargs < 0) MUQ_WARN      ("methargs must be >= 0");
    if (      initargs < 0) MUQ_WARN      ("initargs must be >= 0");
    if (object_methods < 0) MUQ_WARN("objectMmethods must be >= 0");
    if (class_methods  < 0) MUQ_WARN  ("classMethods must be >= 0");

    result = key_Alloc(
	mos_class,
	unshared_slots,
	  shared_slots,
	parents,
	ancestors,
	slotargs,
	methargs,
	initargs,
	object_methods,
	class_methods
    );

    jS.s -= 9;
   *jS.s  = result;
}

 /***********************************************************************/
 /*-    job_P_Make_Lambda_List -- 					*/
 /***********************************************************************/

void
job_P_Make_Lambda_List(
    void
) {
    Vm_Obj result;
    Vm_Int required_args  = OBJ_TO_INT( jS.s[ -3 ] );
    Vm_Int optional_args  = OBJ_TO_INT( jS.s[ -2 ] );
    Vm_Int keyword_args   = OBJ_TO_INT( jS.s[ -1 ] );
    Vm_Int local_vars     = OBJ_TO_INT( jS.s[  0 ] );
    Vm_Unt extra_slots;
    job_Guarantee_N_Args( 3 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );

    if (required_args < 0) MUQ_WARN ("requiredArgs must be >= 0");
    if (optional_args < 0) MUQ_WARN ("optionalArgs must be >= 0");
    if (keyword_args  < 0) MUQ_WARN ("keyworld-args must be >= 0");
    if (local_vars    < 0) MUQ_WARN ("localVars    must be >= 0");
    if (local_vars > LBD_MAX_VARS) MUQ_WARN ("localVars too big");
    extra_slots = (
        (required_args + optional_args + keyword_args)
        *
        (sizeof(Lbd_A_Slot)/sizeof(Vm_Obj))
    );
    if (extra_slots >= LBD_MAX_SLOTS) {
	MUQ_WARN ("makeLambdaList: Too many slots");
    }

    result = obj_Alloc( OBJ_CLASS_A_LBD, extra_slots );
    /* obj_Alloc() can't initialize properly 'cause the */
    /* single size argument we pass it isn't enough to  */
    /* let lbd.t:for_new() do its job, so now we call   */
    /* lbd_For_New() to complete initialization:        */
    lbd_For_New(
	result,
	required_args,
	optional_args,
	keyword_args,
	local_vars
    );

    jS.s -= 3;
    *jS.s = result;
}

 /***********************************************************************/
 /*-    job_P_Make_Method -- 						*/
 /***********************************************************************/

void
job_P_Make_Method(
    void
) {
    Vm_Obj result;
    Vm_Int required_args  = OBJ_TO_INT( jS.s[  0 ] );
    job_Guarantee_Int_Arg(  0 );

    if (required_args <= 0) MUQ_WARN ("requiredArgs must be > 0");
    if (required_args >= MTD_MAX_SLOTS) {
	MUQ_WARN ("makeMethod: Too many required arguments");
    }

    result = obj_Alloc( OBJ_CLASS_A_MTD, required_args );
    *jS.s  = result;
}

 /***********************************************************************/
 /*-    job_P_Root -- Return current root directory.			*/
 /***********************************************************************/

void
job_P_Root(
    void
) {
    /* Seize one stack location, and push result in it: */
    *++jS.s = JOB_P(jS.job)->root_obj;
}

 /***********************************************************************/
 /*-    job_P_Self -- Return currently executing object.		*/
 /***********************************************************************/

void
job_P_Self(
    void
) {
    /* Seize one stack location, and push result in it: */
    *++jS.s = JOB_P(jS.job)->self;
}

 /***********************************************************************/
 /*-    job_P_Set_Muf_Line_Number -- { lineno muf -> }			*/
 /***********************************************************************/

void
job_P_Set_Muf_Line_Number(
    void
) {
    job_Guarantee_Muf_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );
    muf_Set_Line_Number( jS.s[0], jS.s[-1] );
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Start_Muf_Compile -- ( src muf -- )			*/
 /***********************************************************************/

void
job_P_Start_Muf_Compile(
    void
) {
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Muf_Arg(   0 );
    job_Guarantee_Stg_Arg(  -1 );
    job_Must_Control_Object( 0 );
    {   register Vm_Obj* t = jS.s;
	jS.s -= 2; /* <- so muf_Reset sees correct initial top of stack. */
	muf_Reset( t[0], t[-1] );
    }
}

 /***********************************************************************/
 /*-    job_P_Exp							*/
 /***********************************************************************/

void
job_P_Exp(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( exp( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Pow							*/
 /***********************************************************************/

void
job_P_Pow(
    void
){
    if (OBJ_IS_INT(    jS.s[ 0])) {
        if (OBJ_IS_BIGNUM( jS.s[-1]) && !BNM_P(jS.s[-1])->private) {
	    Vm_Int e = OBJ_TO_INT( *jS.s );
	    if (e < 0) MUQ_WARN("expt: negative exponents not yet supported");
	    {   Vm_Obj result = bnm_Pow( jS.s[-1], e, NULL );
		*--jS.s = result;
	    }
	    return;
	}
        if (OBJ_IS_INT( jS.s[-1])) {
	    Vm_Int e = OBJ_TO_INT( *jS.s );
	    if (e < 0) MUQ_WARN("expt: negative exponents not yet supported");
	    {   Vm_Obj result = bnm_PowI( jS.s[-1], e );
		*--jS.s = result;
	    }
	    return;
	}
    }   

    job_Guarantee_IFloat_Arg(  0 );
    job_Guarantee_IFloat_Arg( -1 );
    jS.s[-1] = OBJ_FROM_FLOAT( pow( OBJ_TO_FLOAT(jS.s[-1]), OBJ_TO_FLOAT2(jS.s[0]) ) );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Log							*/
 /***********************************************************************/

void
job_P_Log(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( log( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Log10							*/
 /***********************************************************************/

void
job_P_Log10(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( log10( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Sqrt							*/
 /***********************************************************************/

void
job_P_Sqrt(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( sqrt( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Ceiling							*/
 /***********************************************************************/

void
job_P_Ceiling(
    void 
){
    double number;
    double integer;
    double fraction;
    Vm_Int i;
    job_Guarantee_Float_Arg( 0 );
    number = (double) OBJ_TO_FLOAT( *jS.s );

    /* 'modf' appears to be the only relevant ANSI    */
    /* function we can use here, and I can't find     */
    /* a POSIX function list.  I'm avoiding functions */
    /* defined only by BSD 4.3:                       */
    fraction = modf( number, &integer );
    i        = (Vm_Int) integer;

    if (fraction == 0.0) { *jS.s = OBJ_FROM_INT( i ); return; }

    *jS.s = OBJ_FROM_INT( i + (i > (Vm_Int)0) );
}

 /***********************************************************************/
 /*-    job_P_Floor							*/
 /***********************************************************************/

void
job_P_Floor(
    void 
){
    double number;
    double integer;
    double fraction;
    Vm_Int i;
    job_Guarantee_Float_Arg( 0 );
    number = (double) OBJ_TO_FLOAT( *jS.s );

    /* 'modf' appears to be the only relevant ANSI    */
    /* function we can use here, and I can't find     */
    /* a POSIX function list.  I'm avoiding functions */
    /* defined only by BSD 4.3:                       */
    fraction = modf( number, &integer );
    i        = (Vm_Int) integer;

    if (fraction == 0.0) { *jS.s = OBJ_FROM_INT( i ); return; }

    *jS.s = OBJ_FROM_INT( i - (i < (Vm_Int)0) );
}

 /***********************************************************************/
 /*-    job_P_Round							*/
 /***********************************************************************/

void
job_P_Round(
    void 
){
    double number;
    double integer;
    double fraction;
    Vm_Int i;
    job_Guarantee_Float_Arg( 0 );
    number = (double) OBJ_TO_FLOAT( *jS.s );

    /* 'modf' appears to be the only relevant ANSI    */
    /* function we can use here, and I can't find     */
    /* a POSIX function list.  I'm avoiding functions */
    /* defined only by BSD 4.3:                       */
    fraction = modf( number, &integer );
    i        = (Vm_Int) integer;

    if (fraction < 0) {

	/* "If -number- is exactly halfway between two integers, */
	/* then it is rounded to the one that is even" --CLtL2:  */
        if (fraction == -0.5) { *jS.s = OBJ_FROM_INT( i - (i & (Vm_Int)1) ); return; }

	*jS.s = OBJ_FROM_INT( i - (Vm_Int)(fraction < -0.5) );
	return;

    } else {

	/* "If -number- is exactly halfway between two integers, */
	/* then it is rounded to the one that is even" --CLtL2:  */
        if (fraction ==  0.5) { *jS.s = OBJ_FROM_INT( i + (i & (Vm_Int)1) ); return; }

	*jS.s = OBJ_FROM_INT( i + (Vm_Int)(fraction >  0.5) );
	return;
    }
}

 /***********************************************************************/
 /*-    job_P_Truncate							*/
 /***********************************************************************/

void
job_P_Truncate(
    void 
){
    double number;
    double integer;
    double fraction;
    Vm_Int i;
    job_Guarantee_Float_Arg( 0 );
    number = (double) OBJ_TO_FLOAT( *jS.s );

    /* 'modf' appears to be the only relevant ANSI    */
    /* function we can use here, and I can't find     */
    /* a POSIX function list.  I'm avoiding functions */
    /* defined only by BSD 4.3:                       */
    fraction = modf( number, &integer );
    i        = (Vm_Int) integer;

    *jS.s = OBJ_FROM_INT( i );
}

 /***********************************************************************/
 /*-    job_P_Abs							*/
 /***********************************************************************/

void
job_P_Abs(
    void
){
    /* Make integer case fastest: */
    register Vm_Obj a = *jS.s;
    if (OBJ_IS_INT(a)) {
	register Vm_Int i = OBJ_FROM_INT(a);
	if (i >= 0) return;
	*jS.s = OBJ_FROM_INT( -i );
	return;
    }

    /* Float case: */
    job_Guarantee_Float_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( fabs( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Ffloor							*/
 /***********************************************************************/

void
job_P_Ffloor(
    void 
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( floor( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Fceiling							*/
 /***********************************************************************/

void
job_P_Fceiling(
    void 
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( ceil( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Acos							*/
 /***********************************************************************/

void
job_P_Acos(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( acos( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Asin							*/
 /***********************************************************************/

void
job_P_Asin(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( asin( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Atan							*/
 /***********************************************************************/

void
job_P_Atan(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( atan( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Atan2							*/
 /***********************************************************************/

void
job_P_Atan2(
    void
){
    job_Guarantee_IFloat_Arg(  0 );
    job_Guarantee_IFloat_Arg( -1 );
    jS.s[-1] = OBJ_FROM_FLOAT( atan2( OBJ_TO_FLOAT( jS.s[-1] ), OBJ_TO_FLOAT2( jS.s[0] ) ) );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Cos							*/
 /***********************************************************************/

void
job_P_Cos(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( cos( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Sin							*/
 /***********************************************************************/

void
job_P_Sin(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( sin( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Tan							*/
 /***********************************************************************/

void
job_P_Tan(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( tan( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Cosh							*/
 /***********************************************************************/

void
job_P_Cosh(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( cosh( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Sinh							*/
 /***********************************************************************/

void
job_P_Sinh(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( sinh( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Tanh							*/
 /***********************************************************************/

void
job_P_Tanh(
    void
){
    job_Guarantee_IFloat_Arg( 0 );
    *jS.s = OBJ_FROM_FLOAT( tanh( OBJ_TO_FLOAT( *jS.s ) ) );
}

 /***********************************************************************/
 /*-    job_P_Block_In_Package -- ]inPackage				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_make_package						*/
  /**********************************************************************/

/* This is a separate fn just	*/
/* so it can be shared by	*/
/* job_P_Block_Make_Package and	*/
/* job_P_Block_Use_Package:	*/

static void
job_make_package(
    Vm_Int names,
    Vm_Unt dbfile
) {
    Vm_Obj lib = JOB_P(job_RunState.job)->lib;
    if (!OBJ_IS_OBJ(lib)) {
	MUQ_WARN ("@$s.lib isn't an object?!");
    }

    /* Buggo: Any names which are not immediate */
    /* and not in same dbfile as new package    */
    /* should probably be duplicated within the */
    /* new package at this point.               */

    /* Create package: */
    {   Vm_Obj pkg = obj_Alloc_In_Dbfile( OBJ_CLASS_A_PKG, 0, dbfile );
	OBJ_P( pkg)->objname = jS.s[-names];	vm_Dirty(pkg);
	OBJ_SET( lib, jS.s[-names], pkg, OBJ_PROP_PUBLIC );

	/* Enter all given nicknames into package: */
	{   Vm_Obj nn = PKG_P(pkg)->nicknames;
	    Vm_Int i;
	    for (i = 1;   i < names;   i++) {
		OBJ_SET( nn, jS.s[-i], jS.s[-i], OBJ_PROP_PUBLIC );
	}   }

	/* Pop names: */
	jS.s -= names+1;

	/* Return new package: */
	*jS.s = pkg;
    }
}

  /**********************************************************************/
  /*-   job_P_Block_In_Package -- ]inPackage				*/
  /**********************************************************************/

void
job_P_Block_In_Package(
    void
){
    Vm_Unt dbfile= VM_DBFILE(JOB_P(jS.job)->package);
    Vm_Int i;

    /* If last argument in block is   */
    /* a dbf instance, create package */
    /* in that dbfile:                */ 	
    if (OBJ_IS_BLK(      jS.s[ 0])
    &&  OBJ_IS_OBJ(      jS.s[-1])
    &&  OBJ_IS_CLASS_DBF(jS.s[-1])
    ){
	Vm_Unt n = OBJ_TO_BLK(  jS.s[ 0]);
        if (job_Controls(       jS.s[-1])) {
	    dbfile = VM_DBFILE( jS.s[-1]);
	}
	*--jS.s  = OBJ_FROM_BLK(n-1);
    }

    {   Vm_Int names = job_Guarantee_Nonempty_Stgblock();
	for (i = 1;   i <= names;   i++) {
	    /* Buggo? Should probably demand that acting user */
	    /* control the package before allowing this:      */
	    Vm_Obj pkg = jS.s[-i];
	    if (OBJ_IS_OBJ(pkg)
	    &&  OBJ_IS_CLASS_PKG(pkg)
	    ){
		JOB_P(jS.job)->package = pkg; 
		jS.s -= names+2;
		return;
	    }
	    if (pkg = muf_Find_Package( pkg )) {
		JOB_P(jS.job)->package = pkg; 
		jS.s -= names+2;
		return;
	}	}

	job_make_package( names, dbfile );
	JOB_P(jS.job)->package = *jS.s--; 
    }
}

 /***********************************************************************/
 /*-    job_P_Block_Make_Package -- ]makePackage			*/
 /***********************************************************************/

void
job_P_Block_Make_Package(
    void
){
    Vm_Unt dbfile;
    dbfile = VM_DBFILE(JOB_P(jS.job)->package);

    /* If last argument in block is   */
    /* a dbf instance, create package */
    /* in that dbfile:                */ 	
    if (OBJ_IS_BLK(      jS.s[ 0])
    &&  OBJ_IS_OBJ(      jS.s[-1])
    &&  OBJ_IS_CLASS_DBF(jS.s[-1])
    ){
	Vm_Unt n = OBJ_TO_BLK(  jS.s[ 0]);
        if (job_Controls(       jS.s[-1])) {
	    dbfile = VM_DBFILE( jS.s[-1]);
	}
	*--jS.s  = OBJ_FROM_BLK(n-1);
    }

    {   Vm_Int names = job_Guarantee_Nonempty_Stgblock();
        Vm_Int i;
        for (i = 1;   i <= names;   i++) {
	    if (muf_Find_Package( jS.s[-i] )) {
	        MUQ_WARN ("Package name already in use!");
        }   }

        job_must_control( JOB_P(jS.job)->lib );

        job_make_package( names, dbfile );
    }
}


 /***********************************************************************/
 /*-    job_P_Block_Make_Proxy -- ]makeProxy				*/
 /***********************************************************************/

void
job_P_Block_Make_Proxy(
    void
){
    Vm_Int i;
    Vm_Unt j;

    Vm_Obj guest	= OBJ_NOT_FOUND;

    Vm_Obj i0		= OBJ_NOT_FOUND;
    Vm_Obj i1		= OBJ_NOT_FOUND;
    Vm_Obj i2		= OBJ_NOT_FOUND;

    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    if (size & 1) MUQ_WARN ("]makeProxy argblock length must be even.");
    job_Guarantee_N_Args( size+2 );

    /* Parse the arguments: */
    for (i = 0;   i < size;   i += 2) {

	Vm_Int key_index  = i-size;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Guest      ) {
	    /* Buggo -- should check for it being a Guest here... */
	    if (OBJ_IS_OBJ(val) && OBJ_IS_CLASS_GST(val)) {
		j = OBJ_TO_UNT(val);
		guest = val;
	    } else {
		MUQ_WARN ("]makeProxy :guest arg must be a Guest.");
	    }
        } else if (key == job_Kw_I0            ) {
	    if (OBJ_IS_INT(val)) {
		i0 = val;
	    } else {
		MUQ_WARN ("]makeProxy :i0 arg must be a fixnum.");
	    }
        } else if (key == job_Kw_I1            ) {
	    if (OBJ_IS_INT(val)) {
		i1 = val;
	    } else {
		MUQ_WARN ("]makeProxy :i1 arg must be a fixnum.");
	    }
        } else if (key == job_Kw_I2            ) {
	    if (OBJ_IS_INT(val)) {
		i2 = val;
	    } else {
		MUQ_WARN ("]makeProxy :i2 arg must be a fixnum.");
	    }

	} else {
	    MUQ_WARN ("Unrecognized ]makeProxy keyword.");
    }	}	

    if (guest== OBJ_NOT_FOUND) MUQ_WARN ("]makeProxy: missing :guest");

    if (i0   == OBJ_NOT_FOUND) MUQ_WARN ("]makeProxy: missing :i0");
    if (i1   == OBJ_NOT_FOUND) MUQ_WARN ("]makeProxy: missing :i1");
    if (i2   == OBJ_NOT_FOUND) MUQ_WARN ("]makeProxy: missing :i3");

    {   Vm_Obj prx = obj_Alloc( OBJ_CLASS_A_PRX, 0 );
	Prx_P  p   = PRX_P( prx );

	p->guest   = guest;

	p->i0	   = i0;
	p->i1	   = i1;
	p->i2	   = i2;

        jS.s      -= size+1;
       *jS.s       = prx;
    }
}


 /***********************************************************************/
 /*-    job_P_Block_Rename_Package -- ]renamePackage			*/
 /***********************************************************************/

void
job_P_Block_Rename_Package(
    void
){
    Vm_Obj pkg;
    Vm_Int names;
    job_Guarantee_N_Args(   3 );
    pkg   = jS.s[-1];
    if (stg_Is_Stg(pkg))  pkg = muf_Find_Package( pkg );
    if (!pkg
    || !OBJ_IS_OBJ(pkg)
    || !OBJ_IS_CLASS_PKG(pkg)
    ){
	MUQ_WARN ("]renamePackage: invalid pkg argument.");
    }
    job_must_control( JOB_P(jS.job)->lib );
    job_must_control( pkg                );
    --jS.s;
    names = job_Guarantee_Nonempty_Stgblock();

    /* Check that proposed new names for */
    /* package are not in use, except by */
    /* package itself:                   */
    {   Vm_Int i;
	for (i = 1;   i <= names;   i++) {
	    Vm_Obj pk = muf_Find_Package( jS.s[-i] );
	    if (pk && pk != pkg) {
		MUQ_WARN ("Package name already in use!");
    }	}   }

    /* Create a fresh nicknames object: */
    {   Vm_Obj nn = obj_Alloc_In_Dbfile( OBJ_CLASS_A_OBJ, 0, VM_DBFILE(pkg) );
	Vm_Obj name = stg_From_Asciz("nicknames");
	OBJ_P(nn)->objname  = name; vm_Dirty(nn );
	PKG_P(pkg)->nicknames = nn; vm_Dirty(pkg);

	/* Note all proposed nicknames: */
	{   Vm_Int i;
	    for (i = 1;   i < names;   i++) {
		OBJ_SET( nn, jS.s[-i], jS.s[-i], OBJ_PROP_PUBLIC );
    }	}   }

    /* Enter new name into package itself: */
    OBJ_P(pkg)->objname = jS.s[-names];   vm_Dirty(pkg);

    /* Remove all existing references */
    /* to pkg from @%s/lib:           */
    {   Vm_Obj lib = JOB_P( jS.job )->lib;
	Vm_Obj key;
	if (!OBJ_IS_OBJ(lib)) {
	    MUQ_WARN ("@$s.lib isn't an object?!");
	}
	for (key=OBJ_NEXT(lib,OBJ_FIRST,OBJ_PROP_PUBLIC);
	    key!=OBJ_NOT_FOUND;
	    key=OBJ_NEXT(lib,key,OBJ_PROP_PUBLIC)
	){

	    /* Find the key's value: */
	    Vm_Obj pk  = OBJ_GET( lib, key, OBJ_PROP_PUBLIC );

	    if (pk==pkg) OBJ_DEL( lib, key, OBJ_PROP_PUBLIC );
    	}

	/* Enter package into @%s/lib under new name: */
	OBJ_SET( lib, jS.s[-names], pkg, OBJ_PROP_PUBLIC );
    }

    /* Discard the namelist: */
    jS.s -= names+2;
}

 /***********************************************************************/
 /*-    job_P_Delete_Package -- deletePackage				*/
 /***********************************************************************/

void
job_P_Delete_Package(
    void
){
    Vm_Obj pkg;
    job_Guarantee_N_Args( 1 );
    job_must_control( JOB_P(jS.job)->lib );
    pkg   = jS.s[-1];
    if (stg_Is_Stg(pkg))  pkg = muf_Find_Package( pkg );
    if (!pkg
    || !OBJ_IS_OBJ(pkg)
    || !OBJ_IS_CLASS_PKG(pkg)
    ){
        /* Used to issue an error here, but seems more programmer-friendly  */
        /* to merely ignore it.  Full CommonLisp rules are fairly involved. */
        --jS.s;
	return;
    }
    job_must_control( pkg );

    /* Refuse to delete current package: */
    if (pkg == JOB_P(jS.job)->package) {
	MUQ_WARN ("deletePackage: may not delete current package.");
    }

    /* Buggo? CommonLisp wants us to run around   */
    /* unusing this package in all packages which */
    /* use it.  Thpt.                             */

    /* Remove all existing references */
    /* to pkg from @%s/lib:           */
    {   Vm_Obj lib = JOB_P( jS.job )->lib;
	Vm_Obj key;
	if (!OBJ_IS_OBJ(lib)) {
	    MUQ_WARN ("@$s.lib isn't an object?!");
	}
	for(key=OBJ_NEXT(lib,OBJ_FIRST,OBJ_PROP_PUBLIC);
	    key!=OBJ_NOT_FOUND;
	    key=OBJ_NEXT(lib,key,OBJ_PROP_PUBLIC)
	){

	    /* Find the key's value: */
	    Vm_Obj pk  = OBJ_GET( lib, key, OBJ_PROP_PUBLIC );

	    if (pk==pkg) OBJ_DEL( lib, key, OBJ_PROP_PUBLIC );
    	}
        --jS.s;
    }
}

 /***********************************************************************/
 /*-    job_P_Export -- export						*/
 /***********************************************************************/

void
job_P_Export(
    void
){
    Vm_Obj sym = *jS.s;
    job_Guarantee_Symbol_Arg( 0 );
    {   Vm_Obj pkg = JOB_P(jS.job)->package;
        Vm_Obj nam = SYM_P(sym)->name;

	job_must_control(pkg);

	/* If sym isn't already internal */
	/* to package, make it so:       */
	if (OBJ_GET( pkg, nam,      OBJ_PROP_HIDDEN ) == OBJ_NOT_FOUND) {
	    OBJ_SET( pkg, nam, sym, OBJ_PROP_HIDDEN );
	}

	/* If sym isn't already external */
	/* to package, make it so:       */
	if (OBJ_GET( pkg, nam,      OBJ_PROP_PUBLIC ) == OBJ_NOT_FOUND) {
	    OBJ_SET( pkg, nam, sym, OBJ_PROP_PUBLIC );
    }	}
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Find_Package -- findPackage				*/
 /***********************************************************************/

void
job_P_Find_Package(
    void
){
    /* Buggo, CommonLisp wants us to accept */
    /* symbols as well as string names:       */
    job_Guarantee_Stg_Arg(  0 );
    {   Vm_Obj pkg = muf_Find_Package( *jS.s );
	if (pkg)  *jS.s = pkg;
	else      *jS.s = OBJ_NIL;
    }
}

 /***********************************************************************/
 /*-    job_P_Import -- import						*/
 /***********************************************************************/
 

 /***********************************************************************/
 /*-    job_import							*/
 /***********************************************************************/

static void
job_import(
    Vm_Obj sym
) {
    Vm_Obj nam = SYM_P(sym)->name;
    Vm_Obj pkg = JOB_P(jS.job)->package;
    Vm_Obj val = OBJ_GET( pkg, nam, OBJ_PROP_HIDDEN );
    if (val == OBJ_NOT_FOUND) {
	/* Buggo, should prolly also check */
	/* for conflicting inherited syms. */
	OBJ_SET( pkg, nam, sym, OBJ_PROP_HIDDEN );
    } else if (val != sym) {
	MUQ_WARN ("Import failed, conflicting symbol exists.");
    }
}



void
job_P_Import(
    void
){
    Vm_Obj sym = *jS.s;
    job_Guarantee_Symbol_Arg( 0 );
    job_must_control( JOB_P(jS.job)->package );
    job_import( sym );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_In_Package -- inPackage					*/
 /***********************************************************************/

void
job_P_In_Package(
    void
){
    /* Let job_P_Block_In_Package do all the work: */
    job_Guarantee_Headroom( 2 );
    jS.s += 2;
    jS.s[  0 ] = OBJ_FROM_BLK(1);	/* |		 */    
    jS.s[ -1 ] = jS.s[ -2 ];		/* Package name. */    
    jS.s[ -2 ] = OBJ_BLOCK_START;	/* [		 */
    job_P_Block_In_Package();
}

 /***********************************************************************/
 /*-    job_P_Intern -- intern						*/
 /***********************************************************************/

void
job_P_Intern(
    void
){
    Vm_Obj name = *jS.s;
    Vm_Obj pkg  = JOB_P(jS.job)->package;
    job_Guarantee_Stg_Arg( 0 );
/* Buggo? won't muf.t intern symbols in current package w/o a control check? */
    job_must_control( pkg );
    *jS.s = sym_Alloc( name, 0 );
}

 /***********************************************************************/
 /*-    job_P_Unexport -- unexport					*/
 /***********************************************************************/

void
job_P_Unexport(
    void
){
    Vm_Obj sym = *jS.s;
    job_Guarantee_Symbol_Arg( 0 );
    {   Vm_Obj pkg = JOB_P(jS.job)->package;
        Vm_Obj nam = SYM_P(sym)->name;
        job_must_control( pkg );

	/* If sym is external to    */
	/* package, make it not so: */
	OBJ_DEL( pkg, nam, OBJ_PROP_PUBLIC );
    }

    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Unintern -- unintern					*/
 /***********************************************************************/

void
job_P_Unintern(
    void
){
    Vm_Obj sym = *jS.s;
    job_Guarantee_Symbol_Arg( 0 );
    {   Vm_Obj cur_pkg = JOB_P(jS.job)->package;
        Vm_Obj sym_nam;
        Vm_Obj sym_pkg;
	{   Sym_P s = SYM_P(sym);
	    sym_nam = s->name;
	    sym_pkg = s->package;
	}
        job_must_control( cur_pkg );

	/* If sym is in-/ex-ternal to */
	/* package, make it not so:   */
	if (OBJ_IS_OBJ(cur_pkg) && OBJ_IS_CLASS_PKG(cur_pkg)) {
	    OBJ_DEL( cur_pkg, sym_nam, OBJ_PROP_PUBLIC  );
	    OBJ_DEL( cur_pkg, sym_nam, OBJ_PROP_HIDDEN  );
	}

	/* If symbol's home package was current */
	/* package, make it homeless:           */
	if (sym_pkg == cur_pkg) {
	    SYM_P(sym)->package = OBJ_NIL;	vm_Dirty(sym);
    }   }

    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Unuse_Package -- unusePackage				*/
 /***********************************************************************/

void
job_P_Unuse_Package(
    void
){
    Vm_Obj pkg = *jS.s;
    job_Guarantee_N_Args( 1 );
    job_Guarantee_Stg_Arg(  0 );
    if (stg_Is_Stg(pkg))   pkg = muf_Find_Package( *jS.s );
    if (!OBJ_IS_OBJ(pkg) && OBJ_IS_CLASS_PKG(pkg)) {
	MUQ_WARN ("unusePackage arg must be package or package name");
    }
    {   Vm_Obj name = OBJ_P(pkg)->objname;
	Vm_Obj current_package = JOB_P(jS.job)->package;
	Vm_Obj used_packages;
	if (!OBJ_IS_OBJ(      current_package)
        ||  !OBJ_IS_CLASS_PKG(current_package)
	){	
	    MUQ_WARN ("Invalid @$s.package!");
	}
        job_must_control( current_package );
	used_packages = PKG_P(current_package)->used_packages;
	if (!OBJ_IS_OBJ(used_packages)) {
	    MUQ_WARN ("Invalid @$s.package$s.used_packages!");
	}
	OBJ_DEL( used_packages, name, OBJ_PROP_PUBLIC );
    }

    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Use_Package -- usePackage					*/
 /***********************************************************************/

void
job_P_Use_Package(
    void
){
    Vm_Obj pkg = *jS.s;
    job_Guarantee_N_Args( 1 );
    if (stg_Is_Stg(pkg))   pkg = muf_Find_Package( *jS.s );
    if (!OBJ_IS_OBJ(pkg) || !OBJ_IS_CLASS_PKG(pkg)) {
	MUQ_WARN ("usePackage arg must be package or package name");
    }
    {   Vm_Obj name = OBJ_P(pkg)->objname;
	Vm_Obj current_package = JOB_P(jS.job)->package;
	Vm_Obj used_packages;
        job_must_control( current_package );
	if (!OBJ_IS_OBJ(      current_package)
        ||  !OBJ_IS_CLASS_PKG(current_package)
	){	
	    MUQ_WARN ("Invalid @$s.package!");
	}
	used_packages = PKG_P(current_package)->used_packages;
	if (!OBJ_IS_OBJ(used_packages)) {
	    MUQ_WARN ("Invalid @$s.package$s.used_packages!");
	}
	{   Vm_Obj val = OBJ_GET( used_packages, name, OBJ_PROP_PUBLIC );
	    if (OBJ_IS_OBJ(val)
	    &&  OBJ_IS_CLASS_PKG(val)
	    &&  val != pkg
	    ){
		MUQ_WARN ("usePackage: Conflicting package in use");
	    }		
	    OBJ_SET( used_packages, name, pkg, OBJ_PROP_PUBLIC );
    }   }

    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_String_To_Int -- "stringInt" function.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_String_To_Int(
    void
) {

    job_Guarantee_N_Args(   1 );
    job_Guarantee_Stg_Arg(  0 );

    {   Vm_Obj stg = *jS.s;
	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len >= MAX_STRING) MUQ_WARN ("stringInt arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("string-to-int: internal error");
	}
	buf[len] = '\0';	
	{   Vm_Int i = atoi( (const char*)buf );
	    *jS.s    = OBJ_FROM_INT(i);
	}
    }
}

 /***********************************************************************/
 /*-    job_P_String_To_Chars -- "stringChars[" operator.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_String_To_Chars(
    void
) {

    job_Guarantee_N_Args(   1 );
    job_Guarantee_Stg_Arg(  0 );

    {   Vm_Obj stg = *jS.s;
	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len > MAX_STRING) MUQ_WARN ("string-to-chars[ arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("string-to-chars[: internal error");
	}
	*jS.s++ = OBJ_BLOCK_START;
	{   Vm_Int i;
	    for (i = 0;   i < len;   ++i)   jS.s[ i ] = OBJ_FROM_CHAR(buf[i]);
	}
	jS.s += len;
       *jS.s  = OBJ_FROM_BLK( len );
    }
}

 /***********************************************************************/
 /*-    job_P_String_To_Ints -- "stringInts[" operator.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_String_To_Ints(
    void
) {

    job_Guarantee_N_Args(   1 );
    job_Guarantee_Stg_Arg(  0 );

    {   Vm_Obj stg = *jS.s;
	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len > MAX_STRING) MUQ_WARN ("string-to-ints[ arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("string-to-ints[: internal error");
	}
	*jS.s++ = OBJ_BLOCK_START;
	{   Vm_Int i;
	    for (i = 0;   i < len;   ++i)   jS.s[ i ] = OBJ_FROM_UNT( buf[ i ] );
	}
	jS.s += len;
       *jS.s  = OBJ_FROM_BLK( len );
    }
}

 /***********************************************************************/
 /*-    job_P_Chop_String -- "chopString[" operator.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Chop_String(
    void
) {
    if (OBJ_IS_CHAR(*jS.s)) *jS.s = OBJ_FROM_BYT1( OBJ_TO_CHAR(*jS.s) );
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Stg_Arg(  0 );	/* Delimiter.	*/
    job_Guarantee_Stg_Arg( -1 );	/* Main string. */

    {   Vm_Obj dlm = jS.s[ 0];
        Vm_Obj stg = jS.s[-1];
	Vm_Int slen = stg_Len( stg );
	Vm_Int dlen = stg_Len( dlm );
	Vm_Uch sbuf[ MAX_STRING ];
	Vm_Uch dbuf[ MAX_STRING ];
	if (dlen >= (MAX_STRING-1)
	||  slen >= (MAX_STRING-1)
	){
	    MUQ_WARN ("chopString[ arg too long");
	}
	if (slen != stg_Get_Bytes( (Vm_Uch*)sbuf, slen, stg, 0 )
	||  dlen != stg_Get_Bytes( (Vm_Uch*)dbuf, dlen, dlm, 0 )
	){
	    MUQ_WARN ("chopString[: internal error");
	}

	/* Treat a delimiter of length zero  */
	/* as a cue to create one string per */
	/* character in input string:        */
	if (!dlen) {
	    Vm_Int i;

	    /* Make sure we'll have room to store */
	    /* all those one-character strings:   */
	    job_Guarantee_Headroom( slen );

	    /* Pop the input arguments: */
	    jS.s -= 2;

	    /* Place bottom-of-block marker: */
	    *++jS.s = OBJ_BLOCK_START;

	    /* Over all chars in input string: */
	    for (i = 0;   i < slen;   ++i) {

		/* Push an equivalent one-char */
		/* string on the stack:        */
		*++jS.s = OBJ_FROM_BYT1( sbuf[i] );
	    }

	    /* Push a final block count: */
	    *++jS.s = OBJ_FROM_BLK( slen );
	    return;
	}

	/* Initialize stack to empty block: */
	jS.s[-1] = OBJ_BLOCK_START;
	jS.s[ 0] = OBJ_FROM_BLK(0);

	sbuf[slen] = '\0';
	dbuf[dlen] = '\0';

	/* Over all delimiter matches in string: */
	{   Vm_Uch* lastmatch = sbuf;
	    Vm_Uch* thismatch;
	    Vm_Int  w   = 0;	/* Count of words found */
	    while (thismatch = strstr( lastmatch, dbuf )) {

		/* Push delimited substring: */
		job_Guarantee_Headroom( 1 );
		*jS.s++ = stg_From_Buffer( lastmatch, thismatch-lastmatch );
		*jS.s   = OBJ_FROM_BLK( ++w );

		/* Remember where to pick up search: */
		lastmatch = thismatch + dlen;
    	    }

	    /* Push final substring: */
	    job_Guarantee_Headroom( 1 );
	    *jS.s++ = stg_From_Buffer( lastmatch, &sbuf[slen]-lastmatch );
	    *jS.s   = OBJ_FROM_BLK( ++w );
    }   }
}

 /***********************************************************************/
 /*-    job_P_String_To_Words -- "words[" operator.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_String_To_Words(
    void
) {

    job_Guarantee_N_Args(   1 );
    job_Guarantee_Stg_Arg(  0 );

    {   Vm_Obj stg = *jS.s;
	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	Vm_Uch wrd[ MAX_STRING ];
	if (len > MAX_STRING) MUQ_WARN ("string-to-words[ arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("string-to-words[: internal error");
	}
	/* Initialize stack to empty block: */
	*jS.s++ = OBJ_BLOCK_START;
	*jS.s   = OBJ_FROM_BLK(0);
	{   Vm_Uch* dst = wrd;
	    Vm_Uch* src = buf;
	    Vm_Int  w   = 0;	/* Count of words found */
	    Vm_Int  i;
	    for (i = 0;   i < len;   ++i) {
		Vm_Int c = *src++;
		if ( isalnum(c))   *dst++ = c;
		if (!isalnum(c) || i==len-1) {
		    if (dst != wrd) {
			job_Guarantee_Headroom( 1 );
			*jS.s++ = stg_From_Buffer( wrd, dst-wrd );
			*jS.s   = OBJ_FROM_BLK( ++w );
			dst     = wrd;
    }	}   }   }   }
}

 /***********************************************************************/
 /*-    job_P_Symbol_Name -- "symbolName" operator.			*/
 /***********************************************************************/

void
job_P_Symbol_Name(
    void
) {
    Vm_Obj sym = *jS.s;
    job_Guarantee_N_Args(      1 );
    job_Guarantee_Symbol_Arg(  0 );
    *jS.s = SYM_P(sym)->name;
}

 /***********************************************************************/
 /*-    job_P_Symbol_Package -- "symbolPackage" operator.		*/
 /***********************************************************************/

void
job_P_Symbol_Package(
    void
) {
    Vm_Obj sym = *jS.s;
    job_Guarantee_N_Args(      1 );
    job_Guarantee_Symbol_Arg(  0 );
    *jS.s = SYM_P(sym)->package;
}

 /***********************************************************************/
 /*-    job_P_Set_Symbol_Constant -- "-->constant" operator.		*/
 /***********************************************************************/

void
job_P_Set_Symbol_Constant(
    void
) {
    Vm_Obj sym = *jS.s;
    job_Guarantee_N_Args(      2 );
    job_Guarantee_Symbol_Arg(  0 );
    job_Must_Control_Object(   0 );
    {   Sym_P s = SYM_P(sym);
        s->value    = jS.s[-1];
        s->function = SYM_CONSTANT_FLAG;
        vm_Dirty(sym);
    }
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Set_Symbol_Plist -- "setSymbolPlist" operator.		*/
 /***********************************************************************/

void
job_P_Set_Symbol_Plist(
    void
) {
    Vm_Obj sym = *jS.s;
    job_Guarantee_N_Args(      2 );
    job_Guarantee_Symbol_Arg(  0 );
    job_Must_Control_Object(   0 );
    {   Sym_P s = SYM_P(sym);
	if (s->function == SYM_CONSTANT_FLAG) {
	    MUQ_WARN ("Can't set properties on a constant.");
	}
        sym_Set_Proplist(sym,jS.s[-1]);
    }
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Set_Symbol_Type -- "setSymbolType" operator.		*/
 /***********************************************************************/

void
job_P_Set_Symbol_Type(
    void
) {
    Vm_Obj sym = *jS.s;
    job_Guarantee_N_Args(      2 );
    job_Guarantee_Symbol_Arg(  0 );
    job_Must_Control_Object(   0 );
    sym_Set_Type(sym,jS.s[-1]);
    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Symbol_Plist -- "symbolPlist" operator.			*/
 /***********************************************************************/

void
job_P_Symbol_Plist(
    void
) {
    Vm_Obj sym = *jS.s;
    job_Guarantee_N_Args(      1 );
    job_Guarantee_Symbol_Arg(  0 );
    {   Vm_Obj result = sym_Proplist(sym);
        *jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Symbol_Type -- "symbolType" function.			*/
 /***********************************************************************/

void
job_P_Symbol_Type(
    void
) {
    Vm_Obj sym = *jS.s;
    job_Guarantee_N_Args(      1 );
    job_Guarantee_Symbol_Arg(  0 );
    {   Vm_Obj result = sym_Type(sym);
        *jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Unbind_Symbol -- "unbindSymbol" function.			*/
 /***********************************************************************/

void
job_P_Unbind_Symbol(
    void
) {
    Vm_Obj sym = *jS.s;
    job_Guarantee_N_Args(      1 );
    job_Guarantee_Symbol_Arg(  0 );
    SYM_P(sym)->value = OBJ_FROM_BOTTOM(1);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Get_Socket_Char_Event -- "getSocketCharEvent"		*/
 /***********************************************************************/

void
job_P_Get_Socket_Char_Event(
    void
) {
    Vm_Obj skt =             jS.s[ -1 ]  ;
    Vm_Unt chr = OBJ_TO_INT( jS.s[  0 ] );
    job_Guarantee_Socket_Arg( -1 );
    job_Guarantee_Int_Arg(     0 );
    if (chr > (Vm_Unt)255) {
	MUQ_WARN ("getSocketCharEvent int must be <= 255.");
    }
    {   Vm_Obj evt = SKT_P(skt)->char_event[ chr ];
	if    (evt == OBJ_FROM_INT(0))   evt = OBJ_NIL;
        *--jS.s = evt;
    }
}

 /***********************************************************************/
 /*-    job_P_Set_Socket_Char_Event -- "setSocketCharEvent"		*/
 /***********************************************************************/

void
job_P_Set_Socket_Char_Event(
    void
) {
    Vm_Obj skt =             jS.s[ -2 ]  ;
    Vm_Unt chr = OBJ_TO_INT( jS.s[ -1 ] );
    Vm_Obj evt =             jS.s[  0 ]  ;
    job_Guarantee_N_Args(      3 );
    job_Guarantee_Socket_Arg( -2 );
    job_Guarantee_Int_Arg(    -1 );
    if (evt != OBJ_NIL) /* job_Guarantee_Evt_Arg(0) */;
    else                  evt = OBJ_FROM_INT(0);
    if (chr > (Vm_Unt)255) {
	MUQ_WARN ("setSocketCharEvent int must be <= 255.");
    }
    SKT_P(skt)->char_event[ chr ] = evt;
    vm_Dirty(skt);
    jS.s -= 3;
}

 /***********************************************************************/
 /*-    job_P_Replace_Substrings -- "]replaceSubstrings" operator.	*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

static Vm_Int
job_replace_substring(
    Vm_Uch* buf,  Vm_Int buflen,  Vm_Int bufmax,
    Vm_Uch* old,  Vm_Int oldlen,
    Vm_Uch* new,  Vm_Int newlen
) {
    Vm_Int  delta = newlen - oldlen;
    Vm_Uch* loc = buf;
    Vm_Uch* hit;
    while (hit = strstr( loc, old )) {
	if (buflen + delta >= bufmax-1) {
	    MUQ_WARN ("]replaceSubstrings result too long.");
	}
	memmove( hit+newlen, hit+oldlen, (buflen-(hit-buf))-oldlen );
	strncpy( hit, new, newlen );
	buflen += delta;
	loc     = hit+newlen;
	buf[buflen] = '\0';
    }
    return buflen;
}

void
job_P_Replace_Substrings(
    void
) {
    Vm_Int block_size = OBJ_TO_BLK( jS.s[-1] );
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_Blk_Arg( -1 );
    job_Guarantee_N_Args(  block_size+3 );

    {   Vm_Obj string = jS.s[ 0];
        Vm_Int srclen = stg_Len( string );
        Vm_Int dstlen = srclen;
	Vm_Uch dst[ MAX_STRING ];
	Vm_Uch src[ MAX_STRING ];
	Vm_Uch new[ MAX_STRING ];
	Vm_Uch old[ MAX_STRING ];
	Vm_Int i;

	if (dstlen >= MAX_STRING) {
	    MUQ_WARN ("string too long (%d) for ]replaceSubstrings",(int)dstlen);
	}
	if (dstlen != stg_Get_Bytes( src, MAX_STRING, string, 0 )) {
	    MUQ_WARN ("]replace-strings: internal error");
	    src[ dstlen ] = '\0';
	}
	strcpy( dst, src );

	/* Make sure each 'old' string has   */
	/* a matching 'new' string in block: */
	if (block_size & 1) {
	    MUQ_WARN (
		"]replace-strings blocklen (%d) must be even!",
		(int)block_size
	    );
	}

	/* Over all old-new stringpairs in block: */
	for (i = 0;  i < block_size;   i += 2) {

	    Vm_Int oldlen;
	    Vm_Int newlen;

	    /* Find offset on stack of 'old' and 'new': */
	    Vm_Int oldloc = i - (block_size+1);
	    Vm_Int newloc = oldloc +1;

	    /* Find old and new strings proper: */
	    Vm_Obj oldstr = jS.s[ oldloc ];
	    Vm_Obj newstr = jS.s[ newloc ];

	    /* Verify that they are strings: */
	    job_Guarantee_Stg_Arg( oldloc );
	    job_Guarantee_Stg_Arg( newloc );

	    /* Compute lengths of strings: */
	    oldlen = stg_Len( oldstr );
	    newlen = stg_Len( newstr );
	    if (oldlen >= MAX_STRING
	    ||  newlen >= MAX_STRING
	    ){
		MUQ_WARN ("String arg too long for ]replaceSubstrings");
	    }

	    /* Load strings into buffers: */
	    if (oldlen != stg_Get_Bytes( old, MAX_STRING, oldstr, 0 )
	    ||  newlen != stg_Get_Bytes( new, MAX_STRING, newstr, 0 )
	    ){
		MUQ_WARN ("]replaceSubstrings: internal error");
	    }
	    old[ oldlen ] = '\0';
	    new[ newlen ] = '\0';

	    if (!oldlen) {
		MUQ_WARN ("]replaceSubstrings: Empty template string!");
	    }

	    dstlen = job_replace_substring(
		dst, dstlen, MAX_STRING,
		old, oldlen,
		new, newlen
	    );	
	}

	/* Pop unneeded stuff from stack: */
	jS.s -= block_size +2;

	/* Return original string if  */
	/* unchanged, else a new one: */
        if (dstlen!=srclen
	|| strncmp(src,dst,dstlen)
	){
	    *jS.s = stg_From_Buffer( dst, dstlen );
	} else	{
	    *jS.s = string;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Wrap_String -- "wrapString" operator.			*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

static Vm_Uch*
job_newline(
    Vm_Int* col,
    Vm_Uch* d,   Vm_Uch* e,
    Vm_Uch* dlm, Vm_Int dlm_len,
    Vm_Uch* emsg
) {
    if (d + dlm_len > e)   MUQ_WARN (emsg);
    strcpy( d, dlm );
    d += dlm_len;
    *col = 0;
    return d;
}

static Vm_Int
job_wrap_string(
    Vm_Uch* dst,  Vm_Int dst_max,
    Vm_Uch* src,  Vm_Int src_len,
    Vm_Uch* dlm,  Vm_Int dlm_len,
    Vm_Int  width
) {
    static Vm_Uch* emsg = "wrapString result too long.";
    Vm_Int  col = 0;
    Vm_Uch* d = dst;
    Vm_Uch* e = dst + dst_max;
    Vm_Uch* s = src;
    Vm_Uch* z = src + src_len;
    Vm_Uch* t = s;
    Vm_Uch* u = t;

    /* Convert all newlines to blanks: */
    {   Vm_Int  i;
	for (i = src_len;   i --> 0;   ) {
	    if (src[i] == '\n')  src[i] = ' ';
    }   }

    /* While source text remains to process: */
    while (s < z) {

	/* Find end of current whitespace: */
	for (t = s;   t < z && isspace(*t);  ++t);

	/* Find end of next word: */
	for (u = t;   u < z && !isspace(*u);  ++u);

	/* If whitespace plus word would put us past   */
	/* width limit, replace whitespace with delim: */
	if (col + (u-s) > width) {
	    d = job_newline( &col, d,e,dlm,dlm_len,emsg);
	    s = t;
	}

	/* If word would still put us past width limit, break it: */
	while (col + (u-s) > width) {
	    if (d + width > e)   MUQ_WARN (emsg);
	    strncpy( d, s, width );
	    d += width;
	    s += width;
	    d = job_newline( &col, d,e,dlm,dlm_len,emsg);
	}

	/* Copy word, possibly preceded by whitespace, */
	/* to destination buffer:                      */
	{   Vm_Int len = u-s;
	    if (d + len > e)   MUQ_WARN (emsg);
	    strncpy( d, s, len );
	    d   += len;
	    col += len;
	    s  = u;
	}
    }

    /* Return length of result string; */
    return d - dst;
}

void
job_P_Wrap_String(
    void
) {

    job_Guarantee_N_Args(   3 );
    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Stg_Arg( -2 );


    {   Vm_Obj delim  =             jS.s[ 0]  ;
        Vm_Int width  = OBJ_TO_INT( jS.s[-1] );
        Vm_Obj string =             jS.s[-2]  ;
        Vm_Int slen   = stg_Len( string );
        Vm_Int dlen   = stg_Len( delim  );
	Vm_Uch src[ MAX_STRING ];
	Vm_Uch dlm[ MAX_STRING ];
	Vm_Uch dst[ MAX_STRING ];
	Vm_Int len;

	if (slen >= MAX_STRING) {
	    MUQ_WARN ("string too long (%d) for wrapString",(int)slen);
	}
	if (slen != stg_Get_Bytes( src, MAX_STRING, string, 0 )) {
	    MUQ_WARN ("wrapString: internal error");
	    src[ slen ] = '\0';
	}
	if (dlen >= MAX_STRING) {
	    MUQ_WARN ("delimiter too long (%d) for wrapString",(int)dlen);
	}
	if (dlen != stg_Get_Bytes( dlm, MAX_STRING, delim, 0 )) {
	    MUQ_WARN ("wrapString: internal error");
	    dlm[ dlen ] = '\0';
	}

	len = job_wrap_string( dst, MAX_STRING, src, slen, dlm, dlen, width );
	jS.s -= 2;
	*jS.s = stg_From_Buffer( dst, len );
    }
}

 /***********************************************************************/
 /*-    job_P_Unprint_Format_String -- Parse sscanf-type format string.	*/
 /***********************************************************************/

/****************************************************************/
/* ( format -- blk )						*/
/*								*/
/* Here we take a format string, and crack it into constant	*/
/* substrings and '%s' type specs, which we return in a block. 	*/
/****************************************************************/

  /**********************************************************************/
  /*-   find_next_unformat_field -- Break out '%s', const string etc.	*/
  /**********************************************************************/

static Vm_Int
find_next_unformat_field(
				/* We return field type else FALSE if done.*/
    Vm_Uch** format,		/* Where to start scan, updated when done. */
    Vm_Uch*  field_buf		/* We return full field scanned into here. */
) {
    register Vm_Uch* src = *format;
    register Vm_Uch* dst =  field_buf;
    register Vm_Int  c   = *src;
    *dst      = '\0';

    switch (c) {

    case '\0':
	return FALSE;

    case '%':	
	/* %s or %3.6g or such: */
	*dst++ = c;
	if (src[1] == '%') {
	    *dst++ = *src++;
	    *dst++ = '\0';
	    *format = src+1;
	    return '%';
	}
	for (;;) {
	    *dst++ = c = *++src;
	    if (!c || isspace(c))  MUQ_WARN ("Bad unformat-string string.");

	    /* Check for [] scanset: */
	    if (c=='[') {
		/* Scan to end of spec.  There's a bit   */
		/* of fiddling because ']' can be in the */
		/* scanset as first char, possibly       */
		/* preceded by '^':                      */
		*dst++ = c = *++src;
		if (c == '^') { *dst++ = c = *++src; }
		if (c == ']') { *dst++ = c = *++src; }
		do {
		    *dst++ = c = *++src;
		    if (!c) MUQ_WARN ("unformat-string: unterminated '['");
		} while (c != ']');
		*dst++ = '\0';
		*format = src+1;
		return '[';
	    }
	    if (isalpha(c)) {
		*dst++ = '\0';
		*format = src+1;
		return c;
	    }
	}	    
	/* Never reached. */
	    
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

  /**********************************************************************/
  /*-   push_unformatted_arg --						*/
  /**********************************************************************/

static void
push_unformatted_arg(
    Vm_Obj arg
) {
    Vm_Int old_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_Headroom( 1 );
    *jS.s   = arg;
    *++jS.s = OBJ_FROM_BLK( ++old_size );
}


  /**********************************************************************/
  /*-   job_P_Unprint_Format_String -- Parse sscanf-type format string.	*/
  /**********************************************************************/

void
job_P_Unprint_Format_String(
    void
) {

    job_Guarantee_N_Args(   1 );
    job_Guarantee_Stg_Arg(  0 );

    {   Vm_Int  formatstg = jS.s[  0 ];
        Vm_Int  formatlen = stg_Len( formatstg );

	Vm_Uch  format[ MAX_STRING+1 ];
	Vm_Uch  field[  MAX_STRING   ];

        Vm_Uch* remaining_format = format;

	if (formatlen >= MAX_STRING)MUQ_WARN ("unformat-string: format too big");
	if (formatlen != stg_Get_Bytes( format, formatlen, formatstg, 0 )) {
	    MUQ_WARN ("unformat-string: internal error");
	}

	/* Should maybe rewrite someday to allow nuls in format: */
	format[ formatlen ] = '\0';

	/* Initialize stack to empty block of return values: */
	*jS.s++ = OBJ_BLOCK_START;
	*jS.s   = OBJ_FROM_BLK(0);

	while (find_next_unformat_field( &remaining_format, field )) {
	    push_unformatted_arg( stg_From_Asciz(field) );
    	}
    }
}

 /***********************************************************************/
 /*-    job_P_Unprint_String -- sscanf.					*/
 /***********************************************************************/

/****************************************************************/
/* ( stg format -- blk )					*/
/*								*/
/* Here we take a string and a format string, and crack the	*/
/* string into arguments, which we then return in a block. 	*/
/****************************************************************/

  /**********************************************************************/
  /*-   find_next_unprint_field -- Break out '%s', const string etc.	*/
  /**********************************************************************/

static Vm_Int
find_next_unprint_field(
				/* We return field type else FALSE if done.*/
    Vm_Uch** format,		/* Where to start scan, updated when done. */
    Vm_Uch*  field_buf,		/* We return full field scanned into here. */
    Vm_Int*  saw_star
) {
    register Vm_Uch* src = *format;
    register Vm_Uch* dst =  field_buf;
    register Vm_Int  c   = *src;
    *dst      = '\0';
    *saw_star = FALSE;

    switch (c) {

    case '\0':
	return FALSE;

    case '%':	
	/* %s or %3.6g or such: */
	*dst++ = c;
	if (src[1] != '%') {
	    for (;;) {
		*dst++ = c = *++src;
		if (!c || isspace(c))  MUQ_WARN ("Bad unprint-string string.");
		if (c == '*')   *saw_star = TRUE;

		/* Check for [] scanset: */
		if (c=='[') {
		    /* Scan to end of spec.  There's a bit   */
		    /* of fiddling because ']' can be in the */
		    /* scanset as first char, possibly       */
		    /* preceded by '^':                      */
		    *dst++ = c = *++src;
		    if (c == '^') { *dst++ = c = *++src; }
		    if (c == ']') { *dst++ = c = *++src; }
		    do {
			*dst++ = c = *++src;
			if (!c) MUQ_WARN ("unprint-string: unterminated '['");
		    } while (c != ']');
		    *dst++ = '\0';
		    *format = src+1;
		    return '[';
		}
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

  /**********************************************************************/
  /*-   push_unprinted_arg --						*/
  /**********************************************************************/

static void
push_unprinted_arg(
    Vm_Obj arg
) {
    Vm_Int old_size = OBJ_TO_BLK( *jS.s );
    job_Guarantee_Headroom( 1 );
    *jS.s   = arg;
    *++jS.s = OBJ_FROM_BLK( ++old_size );
}


  /**********************************************************************/
  /*-   job_P_Unprint_String -- sscanf.					*/
  /**********************************************************************/


void
job_P_Unprint_String(
    void
) {

    job_Guarantee_N_Args(   2 );
    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_Stg_Arg( -1 );

    {   Vm_Obj  input_stg = jS.s[ -1 ]  ;
        Vm_Int  formatstg = jS.s[  0 ];
        Vm_Int  input_len = stg_Len( input_stg );
        Vm_Int  formatlen = stg_Len( formatstg );

	Vm_Uch  format[ MAX_STRING+1 ];
	Vm_Uch  input[  MAX_STRING+1 ];
	Vm_Uch  field[  MAX_STRING   ];
	Vm_Uch  temp[   MAX_STRING   ];

        Vm_Uch* remaining_format = format;
        Vm_Uch* remaining_input  = input;
	Vm_Int  field_type;
        Vm_Int  saw_star;
	Vm_Uch* fmt;

	if (input_len >= MAX_STRING)MUQ_WARN ("unprint-string: input too big");
	if (formatlen >= MAX_STRING)MUQ_WARN ("unprint-string: format too big");
	if (input_len != stg_Get_Bytes( input , input_len, input_stg, 0 )
	||  formatlen != stg_Get_Bytes( format, formatlen, formatstg, 0 )
	){
	    MUQ_WARN ("unprint-string: internal error");
	}

	/* Should maybe rewrite someday to allow nuls in format: */
	format[ formatlen ] = '\0';
	input[  input_len ] = '\0';


	/* Initialize stack to empty block of return values: */
	jS.s[-1] = OBJ_BLOCK_START;
	jS.s[ 0] = OBJ_FROM_BLK(0);

	for (;;) {

	    field_type = find_next_unprint_field(
		&remaining_format,
		field,
		&saw_star
	    );

	    switch (field_type) {

	    case 0:
		return;

	    case 1:
		/* We implement this by hand, rather */
		/* than bothering to call sscanf:    */
		{   Vm_Uch* remaining_field = field;
		    int  c;
		    while (c = *remaining_field++) {
			if (isspace(c)) {
			    while (isspace(*remaining_input)) {
				++          remaining_input;
			    }
			} else {
			    if (c != *remaining_input++)   return;
		}   }	}
		break;

	    case 's':
	    case '[':
		{   int chars_read;
		    strcat( field, "%n" );	/* To get char_read back. */
		    if (1 != sscanf(remaining_input, field,temp,&chars_read)) {
			return;
		    }
		    remaining_input += chars_read;
		    if (!saw_star) push_unprinted_arg(stg_From_Asciz(temp));
		}
		break;

	    case 'd':   fmt = VM_D;	goto ijoin;
	    case 'i':   fmt = VM_I;	goto ijoin;
	    case 'o':   fmt = VM_O;	goto ijoin;
	    case 'u':   fmt = VM_U;	goto ijoin;
	    case 'x':   fmt = VM_X;	goto ijoin;
	    case 'X':   fmt = VM_X;	goto ijoin;
	    ijoin:
	        /* Convert, say, "%03x" to "%03llx" or whatever: */
		strcpy( &field[ strlen(field) -1 ], fmt );
		{   int    chars_read;
		    Vm_Int val;
		    strcat( field, "%n" );	/* To get char_read back. */
		    if (1 != sscanf(remaining_input, field,&val,&chars_read)) {
			return;
		    }
		    remaining_input += chars_read;
		    if (!saw_star) push_unprinted_arg(OBJ_FROM_INT(val));
		}
		break;

	    case 'c':
		{   int    chars_read;
		    Vm_Uch val;
		    strcat( field, "%n" );	/* To get char_read back. */
		    if (1 != sscanf(remaining_input, field,&val,&chars_read)) {
			return;
		    }
		    remaining_input += chars_read;
		    if (!saw_star) push_unprinted_arg(OBJ_FROM_INT(val));
		}
		break;

	    case 'e':   fmt = VM_E;	goto fjoin;
	    case 'f':   fmt = VM_F;	goto fjoin;
	    case 'g':   fmt = VM_G;	goto fjoin;
	    fjoin:
	        /* Convert, say, "%5.3g" to "%5.3lg" or whatever: */
		strcpy( &field[ strlen(field) -1 ], fmt );
		{   int    chars_read;
		    Vm_Flt val;
		    strcat( field, "%n" );	/* To get char_read back. */
		    if (1 != sscanf(remaining_input, field,&val,&chars_read)) {
			return;
		    }
		    remaining_input += chars_read;
		    if (!saw_star) push_unprinted_arg(OBJ_FROM_FLOAT(val));
		}
		break;

	    default:
		MUQ_WARN ("unprint-string: bad spec '%s'",field);
	    }
    }	}

    /* Never reached. */
}

 /***********************************************************************/
 /*-    job_P_Root_Log_String -- Append string to logfile.		*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Root_Log_String(
    void
) {
    Vm_Obj txt = *jS.s;
    Vm_Uch buf[ MAX_STRING ];

    job_Must_Be_Root();

    job_Guarantee_Stg_Arg(0);

    {   Vm_Int len = stg_Len( txt );
	if (len >= MAX_STRING)MUQ_WARN ("rootLog: msg too big");
	if (len != stg_Get_Bytes( buf , MAX_STRING, txt, 0 )){
	    MUQ_WARN ("rootLog: internal error");
	}
        buf[len] = '\0';
        lib_Log_String( buf );
    }

    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Make_Socket -- { -> socket }				*/
 /***********************************************************************/

void
job_P_Make_Socket(
    void
) {
    {    Vm_Obj result = obj_Alloc( OBJ_CLASS_A_SKT, 0 );
        *++jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_root_make_database	 					*/
 /***********************************************************************/

static Vm_Unt
job_root_make_database(
    Vm_Unt arg_id,
    int    different_id_ok
) {
    /* Create a new db file: */
    Vm_Unt new_id;
    if (different_id_ok) {
	while (!(new_id=vm_Make_Db(arg_id))) {
	    arg_id = (arg_id+1) & VM_DBFILE_MASK;
	}
    } else {
	if (vm_Db_Is_Mounted(  arg_id))   return arg_id;
	new_id = vm_Make_Db(arg_id);
	if (!new_id) MUQ_WARN("rootValidateDbfile: Internal err");
    }

    /* Create db object within that dbfile: */
    {   Vm_Obj dbf = obj_Alloc_In_Dbfile( OBJ_CLASS_A_DBF, 0, new_id );
	Vm_Obj nam = stg_From_Asciz(vm_DbId_To_Asciz(new_id));

/*	*jS.s = nam; oops! */
	vm_Set_Root( new_id, dbf );

	/* Index db objects in .db: */
	if (OBJ_IS_OBJ(obj_Db)) {
	    OBJ_SET( obj_Db, nam, dbf, OBJ_PROP_PUBLIC );
	}

	/* Create a "lib" package index within the dbfile: */
	{   Vm_Obj lib = obj_Alloc_In_Dbfile( OBJ_CLASS_A_OBJ, 0, new_id );
	    OBJ_SET( vm_Root(new_id), OBJ_FROM_BYT3('l','i','b'), lib, OBJ_PROP_PUBLIC );
	    OBJ_P(lib)->objname = stg_From_Asciz(".lib");  vm_Dirty(lib);
	}
    }

    return new_id;
}

 /***********************************************************************/
 /*-    job_P_Root_Make_Db -- { [name] -> [dbf] }			*/
 /***********************************************************************/

void
job_P_Root_Make_Db(
    void
) {
    Vm_Unt arg_id     = 0;
    Vm_Obj arg        = jS.s[-1];
    Vm_Int block_size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_N_Args(  block_size+2 );

    job_Must_Be_Root();

    if (block_size != 1)  MUQ_WARN("rootMakeDb takes one arg");

    /* Convert given argument to 21-bit db id: */
    if (stg_Is_Stg(arg)) {

	Vm_Chr str_buf[ 8 ];
	Vm_Int str_len;
	str_len = stg_Len( arg );
	if (str_len > 7)   str_len = 7;
	if (str_len != stg_Get_Bytes( str_buf, str_len, arg, 0 )) {
	    MUQ_WARN ("rootMakeDatabaseFile: internal error");
	}
        str_buf[str_len] = '\0';
        arg_id = vm_Asciz_To_DbId( str_buf );

    } else if (OBJ_IS_INT(arg)) {

	arg_id = OBJ_TO_INT(arg) & VM_DBFILE_MASK;

    } else if (arg == OBJ_NIL) {

        arg_id = obj_TrueRandom(NULL);

    } else {

	MUQ_WARN("rootMakeDatabaseFile: arg must be NIL, fixnum, or string");
    }

    {   Vm_Unt new_id = job_root_make_database( arg_id, TRUE );
	Vm_Obj nam    = stg_From_Asciz(vm_DbId_To_Asciz(new_id));
	jS.s[-1]      = nam;
    }
}

 /***********************************************************************/
 /*-    job_P_Root_Validate_Database_File -- { name -> dbf }		*/
 /***********************************************************************/

void
job_P_Root_Validate_Database_File(
    void
) {
    Vm_Unt arg_id = 0;
    Vm_Obj arg    = *jS.s;

    job_Guarantee_N_Args(   1 );
    job_Must_Be_Root();

    /* Convert given argument to 21-bit db id: */
    if (stg_Is_Stg(arg)) {

	Vm_Chr str_buf[ 8 ];
	Vm_Int str_len;
	str_len = stg_Len( arg );
	if (str_len > 7)   str_len = 7;
	if (str_len != stg_Get_Bytes( str_buf, str_len, arg, 0 )) {
	    MUQ_WARN ("rootMakeDatabaseFile: internal error");
	}
        str_buf[str_len] = '\0';
        arg_id = vm_Asciz_To_DbId( str_buf );

    } else if (OBJ_IS_INT(arg)) {

	arg_id = OBJ_TO_INT(arg) & VM_DBFILE_MASK;

    } else if (arg == OBJ_NIL) {

        arg_id = obj_TrueRandom(NULL);

    } else {

	MUQ_WARN("rootMakeDatabaseFile: arg must be NIL, fixnum, or string");
    }

    {   Vm_Unt new_id = job_root_make_database( arg_id, FALSE );
	Vm_Obj nam    = stg_From_Asciz(vm_DbId_To_Asciz(new_id));
	*jS.s         = nam;
    }
}

 /***********************************************************************/
 /*-    job_root_make_user -- 						*/
 /***********************************************************************/

static Vm_Obj 
job_root_make_user(
    Vm_Unt dbfile
) {
    Vm_Obj usr = obj_Alloc_In_Dbfile( OBJ_CLASS_A_USR, 0, dbfile );
    Vm_Obj lib = obj_Alloc_In_Dbfile( OBJ_CLASS_A_OBJ, 0, dbfile );
    Vm_Obj pkg = obj_Alloc_In_Dbfile( OBJ_CLASS_A_PKG, 0, dbfile );

    /* Assign users sequential rankings: */
    Vm_Obj r;
    {   Muq_P  m = MUQ_P(obj_Muq);
	r = m->next_user_rank;
	m->next_user_rank = OBJ_FROM_INT( OBJ_TO_INT(r)+1 );
    }

    USR_P(usr)->rank            = r;
    USR_P(usr)->default_package = pkg;
    USR_P(usr)->lib             = lib;
    vm_Dirty(usr);

    return usr;
}

 /***********************************************************************/
 /*-    job_P_Root_Make_User -- ( name -- user )			*/
 /***********************************************************************/

void
job_P_Root_Make_User(
    void
) {
    Vm_Unt arg_id;
    Vm_Obj arg        = jS.s[-1];
    Vm_Int block_size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_N_Args(  block_size+2 );
    job_Guarantee_Stg_Arg( -1 );

    if (block_size != 1) {
	MUQ_WARN("rootMakeUser takes one arg");
    }

    job_Must_Be_Root();

    {   Vm_Chr str_buf[ 8 ];
	Vm_Int str_len = stg_Len( arg );
	if (str_len > 7)   str_len = 7;
	if (str_len != stg_Get_Bytes( str_buf, str_len, arg, 0 )) {
	    MUQ_WARN ("rootMakeUser: internal error");
	}
        str_buf[str_len] = '\0';
        arg_id = vm_Asciz_To_DbId( str_buf );
    }

    {   Vm_Unt dbfile      = job_root_make_database( arg_id, TRUE );
        Vm_Obj usr         = job_root_make_user(     dbfile       );
	Vm_Obj dbf         = vm_Root(dbfile);
	DBF_P( dbf)->owner = usr;
	jS.s[-1]           = usr;
    }
}

 /***********************************************************************/
 /*-    job_P_Root_Make_User -- ( -- user )				*/
 /***********************************************************************/

#ifdef OLD
void
job_P_Root_Make_User(
    void
) {
    job_Must_Be_Root();
    
    {   Vm_Obj pkg    = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
        Vm_Unt dbfile = VM_DBFILE(pkg);
        Vm_Obj result = job_root_make_user(dbfile);
	*++jS.s = result;
    }
}
#endif

 /***********************************************************************/
 /*-    job_P_Root_Mount_Database_File -- { name -> dbf }		*/
 /***********************************************************************/

void
job_P_Root_Mount_Database_File(
    void
) {
    Vm_Unt arg_id = 0;
    Vm_Obj arg    = *jS.s;

    job_Guarantee_N_Args(   1 );
    job_Must_Be_Root();
MUQ_WARN("rootMountDatabaseFile not yet implemented");

    /* Convert given argument to 21-bit db id: */
    if (stg_Is_Stg(arg)) {

	Vm_Chr str_buf[ 8 ];
	Vm_Int str_len;
	str_len = stg_Len( arg );
	if (str_len > 7)   str_len = 7;
	if (str_len != stg_Get_Bytes( str_buf, str_len, arg, 0 )) {
	    MUQ_WARN ("rootMountDatabaseFile: internal error");
	}
        str_buf[str_len] = '\0';
        arg_id = vm_Asciz_To_DbId( str_buf );

    } else if (OBJ_IS_INT(arg)) {

	arg_id = OBJ_TO_INT(arg);

    } else if (arg == OBJ_NIL) {

        arg_id = obj_TrueRandom(NULL);

    } else {

	MUQ_WARN("rootMountDatabaseFile: arg must be NIL, fixnum, or string");
    }

    {   /* Create a new db file: */
        Vm_Unt dbfile;
	arg_id &= VM_DBFILE_MASK;
        while (!(dbfile=vm_Make_Db(arg_id))) {
	    arg_id = (arg_id+1) & VM_DBFILE_MASK;
	}

	/* Create and return db object within that dbfile: */
        {   Vm_Obj dbf = obj_Alloc_In_Dbfile( OBJ_CLASS_A_DBF, 0, dbfile );
	    Vm_Obj nam = stg_From_Asciz(vm_DbId_To_Asciz(dbfile));
	    *jS.s = nam;
	    vm_Set_Root( dbfile, dbf );

	    /* Index db objects in .db: */
	    if (OBJ_IS_OBJ(obj_Db)) {
		OBJ_SET( obj_Db, nam, dbf, OBJ_PROP_PUBLIC );
	    }
	}
    }
}

 /***********************************************************************/
 /*-    job_note_new_db --						*/
 /***********************************************************************/

static void
job_note_new_db(
    Vm_Unt dbId
) {
    Vm_Obj nam = stg_From_Asciz( vm_DbId_To_Asciz(dbId) );

    /* Index db objects in .db: */
    if (OBJ_IS_OBJ(obj_Db)) {
	OBJ_SET( obj_Db, nam, vm_Root(dbId), OBJ_PROP_PUBLIC );
    }

    {   Vm_Db db   = vm_Db(dbId);
	Vm_Obj lib = JOB_P( jS.job )->lib;

	/* Index package objects in @.lib and .lib: */
	Vm_Obj o;
	for   (o = vm_First(db);   o;   o = vm_Next(o,db)) {
	    if (OBJ_TYPE(o) == OBJ_TYPE_OBJ
	    &&  OBJ_IS_CLASS_PKG(o)
	    ){
		if (isupper( *vm_DbId_To_Asciz(dbId) )
		)    { OBJ_SET( obj_Lib, OBJ_P(o)->objname, o, OBJ_PROP_PUBLIC ); } /* global */
		else { OBJ_SET( lib,     OBJ_P(o)->objname, o, OBJ_PROP_PUBLIC ); } /*  local */
	    }
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Root_Import_Db -- { [name] -> [dbf] }			*/
 /***********************************************************************/

void
job_P_Root_Import_Db(
    void
) {
    Vm_Unt dbId   = 0;
    Vm_Obj arg    = jS.s[-1];
    Vm_Int block_size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_N_Args(  block_size+2 );

    if (block_size != 1) {
	MUQ_WARN("rootImportDb takes one arg");
    }

    /* Convert given argument to 21-bit db id: */
    if (stg_Is_Stg(arg)) {

	Vm_Chr str_buf[ 8 ];
	Vm_Int str_len;
	str_len = stg_Len( arg );
	if (str_len > 7)   str_len = 7;
	if (str_len != stg_Get_Bytes( str_buf, str_len, arg, 0 )) {
	    MUQ_WARN ("rootImportDb: internal error");
	}
        str_buf[str_len] = '\0';
        dbId = vm_Asciz_To_DbId( str_buf );

    } else if (OBJ_IS_INT(arg)) {

	dbId = OBJ_TO_INT(arg);

    } else {

	MUQ_WARN("rootImportDb: arg must be fixnum or string");
    }

    job_Must_Be_Root();

    if (vm_Db_Is_Mounted(dbId)) MUQ_WARN("Db '%s' already exists!",vm_DbId_To_Asciz(dbId));

    dbId = vm_Import_Db( dbId );

    job_note_new_db( dbId );

    /* Null out any bad links in new db: */
    obj_Null_Out_Broken_Pointers_In_Db( vm_Db(dbId) );

    jS.s[-1] = stg_From_Asciz( vm_DbId_To_Asciz(dbId) );
}

 /***********************************************************************/
 /*-    job_P_Root_Export_Db -- { [dbf] -> [] }				*/
 /***********************************************************************/

void
job_P_Root_Export_Db(
    void
) {
    Vm_Obj dbf        = jS.s[-1];
    Vm_Int block_size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_N_Args(  block_size+2 );
    job_Guarantee_Dbf_Arg( -1 );

    if (block_size != 1) {
	MUQ_WARN("rootExportDb takes one arg");
    }

    vm_Export_Db( VM_DBFILE(dbf) );

    *--jS.s = OBJ_FROM_BLK(0);
}

 /***********************************************************************/
 /*-    job_P_Root_Remove_Db -- { [dbf] -> [] }				*/
 /***********************************************************************/

static int
job_root_remove_db_check_sockets(
    void* dbId,
    Vm_Obj skt
){
    /* Return TRUE to continue search, FALSE to terminate it: */
    return  ((*((Vm_Unt*)dbId)) != VM_DBFILE(skt));
}

static void
job_remove_db(
    Vm_Unt dbId 
) {
    /* Sanity checks:  Don't let admin */
    /* crash server by removing a db:  */
    {   if (!vm_Db_Is_Mounted(dbId)) MUQ_FATAL("internal err");

	/* Defend critical hardwired dbs: */
	if (!dbId)                             MUQ_WARN("May not remove root db");
	if (vm_Asciz_To_DbId("KEYW") == dbId)  MUQ_WARN("May not remove keyword db");
	if (vm_Asciz_To_DbId("MUF" ) == dbId)  MUQ_WARN("May not remove MUF db");
	if (vm_Asciz_To_DbId("LISP") == dbId)  MUQ_WARN("May not remove LISP db");
	if (vm_Asciz_To_DbId("QNET") == dbId)  MUQ_WARN("May not remove muqnet db");

	/* Defend the currently running job: */
	if (VM_DBFILE(jS.x_obj)         == dbId) MUQ_WARN("May not remove db holding current running function");
	if (VM_DBFILE(jS.job)           == dbId) MUQ_WARN("May not remove db holding current running job");
	if (VM_DBFILE(jS.data_vector)   == dbId) MUQ_WARN("May not remove db holding current data stack");
	if (VM_DBFILE(jS.loop_vector)   == dbId) MUQ_WARN("May not remove db holding current loop stack");
	if (VM_DBFILE(jS.j.acting_user) == dbId) MUQ_WARN("May not remove db holding current acting user");
	if (VM_DBFILE(jS.j.actual_user) == dbId) MUQ_WARN("May not remove db holding current actual user");

	/* Defend open sockets: */
	if (!skt_All_Sockets( job_root_remove_db_check_sockets, &dbId )) {
	    MUQ_WARN("May not remove db holding open socket");
	}

	/* Defend objects pinned in ram  */
        /* via vm_Register_Hard_Pointer: */
        if (vm_Db_Is_Pinned_In_Ram(dbId)) {
	    MUQ_WARN("May not remove db holding object pinned in ram");
        }

	/* I'm sure I've missed lots of cases that will crash us -- */
	/* and that I'll get email about them in due course! :)     */ /* buggo */

	/* One hack here might be iterating over all objects in the */
	/* server looking for loop stack references to this db?     */
    }

    /* Remove db from .db[] directory: */
    OBJ_DEL( obj_Db, stg_From_Asciz(vm_DbId_To_Asciz(dbId)), OBJ_PROP_PUBLIC );

    /* Buggo, should probably try to remove packages in db from */
    /* @.lib and .lib and such, using logic parallel to that    */
    /* used to install them in Import_Db().                     */

    /* Zap indicated db: */
    vm_Remove_Db( dbId );

    /* Flush from cache any references */
    /* to objects in the db:           */
    vm_Flush_Db_From_Cache( dbId );
}

void
job_P_Root_Remove_Db(
    void
) {
    Vm_Obj dbf        = jS.s[-1];
    Vm_Unt dbId       = VM_DBFILE(dbf);
    Vm_Int block_size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_N_Args(  block_size+2 );
    job_Guarantee_Dbf_Arg( -1 );

    if (block_size != 1) {
	MUQ_WARN("rootRemoveDb takes one arg");
    }

    job_Must_Be_Root();

    job_remove_db( dbId );

    obj_Null_Out_All_Broken_Pointers();

    *--jS.s = OBJ_FROM_BLK(0);
}

 /***********************************************************************/
 /*-    job_P_Root_Replace_Db -- { name -> dbf }			*/
 /***********************************************************************/

void
job_P_Root_Replace_Db(
    void
) {
    Vm_Obj dbf        = jS.s[-1];
    Vm_Unt dbId       = VM_DBFILE(dbf);
    Vm_Int block_size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_N_Args(  block_size+2 );
    job_Guarantee_Dbf_Arg( -1 );

    if (block_size != 1) {
	MUQ_WARN("rootRemoveDb takes one arg");
    }

    job_Must_Be_Root();

    job_remove_db( dbId );

    dbId = vm_Import_Db( dbId );

    job_note_new_db(     dbId );

    obj_Null_Out_All_Broken_Pointers();

    *--jS.s = OBJ_FROM_BLK(0);
}

 /***********************************************************************/
 /*-    job_P_Root_Unmount_Database_File -- { name -> dbf }		*/
 /***********************************************************************/

void
job_P_Root_Unmount_Database_File(
    void
) {
    Vm_Unt arg_id = 0;
    Vm_Obj arg    = *jS.s;

    job_Guarantee_N_Args(   1 );
    job_Must_Be_Root();
MUQ_WARN("rootUnmountDatabaseFile not yet implemented");

    /* Convert given argument to 21-bit db id: */
    if (stg_Is_Stg(arg)) {

	Vm_Chr str_buf[ 8 ];
	Vm_Int str_len;
	str_len = stg_Len( arg );
	if (str_len > 7)   str_len = 7;
	if (str_len != stg_Get_Bytes( str_buf, str_len, arg, 0 )) {
	    MUQ_WARN ("rootMountDatabaseFile: internal error");
	}
        str_buf[str_len] = '\0';
        arg_id = vm_Asciz_To_DbId( str_buf );

    } else if (OBJ_IS_INT(arg)) {

	arg_id = OBJ_TO_INT(arg) & VM_DBFILE_MASK;

    } else if (arg == OBJ_NIL) {

        arg_id = obj_TrueRandom(NULL);

    } else {

	MUQ_WARN("rootMountDatabaseFile: arg must be NIL, fixnum, or string");
    }

    {   /* Create a new db file: */
        Vm_Unt new_id;
        while (!(new_id=vm_Make_Db(arg_id))) {
	    arg_id = (arg_id+1) & VM_DBFILE_MASK;
	}

	/* Create and return db object within that dbfile: */
        {   Vm_Obj dbf = obj_Alloc_In_Dbfile( OBJ_CLASS_A_DBF, 0, new_id );
	    Vm_Obj nam = stg_From_Asciz(vm_DbId_To_Asciz(new_id));
	    *jS.s = nam;
	    vm_Set_Root( new_id, dbf );


	    /* Index db objects in .db: */
	    if (OBJ_IS_OBJ(obj_Db)) {
		OBJ_SET( obj_Db, nam, dbf, OBJ_PROP_PUBLIC );
	    }
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Root_Move_To_Dbfile -- { obj dbf -> newobj }		*/
 /***********************************************************************/

void
job_P_Root_Move_To_Dbfile(
    void
) {
    Vm_Unt dbfile = 0;
    Vm_Obj old    = jS.s[-1];
    Vm_Obj dbfarg = jS.s[ 0];

    job_Must_Be_Root();
    job_Guarantee_N_Args(   2 );
    job_Must_Be_Root();

    /* Check that copied object -is- an object: */
    job_Guarantee_Object_Arg( -1 );
    /* Currently support moving only messageStream and      */
    /* socket objects, because that's all rootBecomeUser    */
    /* needs and I haven't thought through the implications */
    /* for other objects:                                   */
    if (!OBJ_IS_CLASS_MSS(old)
    &&  !OBJ_IS_CLASS_SKT(old)
    ){
	MUQ_WARN("rootMoveToDbfile: Moved object must be MessageStream or Socket");
    }

    /* Convert given argument to 21-bit db id: */
    if (stg_Is_Stg(dbfarg)) {

	Vm_Chr str_buf[ 8 ];
	Vm_Int str_len;
	str_len = stg_Len( dbfarg );
	if (str_len > 7)   str_len = 7;
	if (str_len != stg_Get_Bytes( str_buf, str_len, dbfarg, 0 )) {
	    MUQ_WARN ("rootMoveToDbfile: internal error");
	}
        str_buf[str_len] = '\0';
        dbfile = vm_Asciz_To_DbId( str_buf );

    } else if (OBJ_IS_INT(dbfarg)) {

	dbfile = OBJ_TO_INT(dbfarg) & VM_DBFILE_MASK;

    } else {

	MUQ_WARN("rootMoveToDbfile: arg must be fixnum, or string");
    }


    {   Vm_Obj new = obj_Dup_In_Dbfile(old,dbfile);
	*--jS.s = new;

        if (OBJ_IS_CLASS_SKT(new)) {
	    skt_Replace(new,old);
	}
    }
}

 /***********************************************************************/
 /*-    job_make_guest							*/
 /***********************************************************************/

static Vm_Obj
job_make_guest(
    Vm_Unt dbfile
){
    Vm_Obj result = obj_Alloc_In_Dbfile( OBJ_CLASS_A_GST, 0, dbfile );

    /* Assign guests sequential rankings: */
    Vm_Obj r;
    {   Muq_P  m = MUQ_P(obj_Muq);
        r = m->next_guest_rank;
	m->next_guest_rank = OBJ_FROM_INT( OBJ_TO_INT(r)+1 );
    }
    USR_P(result)->rank = r;
    vm_Dirty(result);

    return result;
}

 /***********************************************************************/
 /*-    job_P_Root_Make_Guest -- ( -- guest )				*/
 /***********************************************************************/

void
job_P_Root_Make_Guest(
    void
) {
    Vm_Obj pkg    = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    Vm_Unt dbfile = VM_DBFILE(pkg);

    Vm_Int block_size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_N_Args(  block_size+2 );

    if (block_size != 0) {
	MUQ_WARN("rootMakeGuest takes zero args");
    }

    job_Must_Be_Root();
    {   Vm_Obj result = job_make_guest(dbfile);
	*jS.s   = result;
	*++jS.s = OBJ_FROM_BLK(1);
    }
}

 /***********************************************************************/
 /*-    job_P_Root_Make_Guest_In_Dbfile -- { dbfile -> guest }		*/
 /***********************************************************************/

void
job_P_Root_Make_Guest_In_Dbfile(
    void
) {
    Vm_Unt dbfile = 0;
    Vm_Obj arg    = *jS.s;

    job_Must_Be_Root();
    job_Guarantee_N_Args(   1 );
    job_Must_Be_Root();

    /* Convert given argument to 21-bit db id: */
    if (stg_Is_Stg(arg)) {

	Vm_Chr str_buf[ 8 ];
	Vm_Int str_len;
	str_len = stg_Len( arg );
	if (str_len > 7)   str_len = 7;
	if (str_len != stg_Get_Bytes( str_buf, str_len, arg, 0 )) {
	    MUQ_WARN ("rootMakeDatabaseFile: internal error");
	}
        str_buf[str_len] = '\0';
        dbfile = vm_Asciz_To_DbId( str_buf );

    } else if (OBJ_IS_INT(arg)) {

	dbfile = OBJ_TO_INT(arg) & VM_DBFILE_MASK;

    } else if (arg == OBJ_NIL) {

        dbfile = obj_TrueRandom(NULL);

    } else {

	MUQ_WARN("rootMakeDatabaseFile: arg must be NIL, fixnum, or string");
    }

    {   Vm_Obj result = job_make_guest(dbfile);
	*jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Write_Output_Stream -- "," operator.			*/
 /***********************************************************************/

void
job_P_Write_Output_Stream(
    void
) {
    job_Guarantee_N_Args(   1 );

    /* Find output message stream: */
    {	Vm_Obj sym = obj_Lib_Muf_Write_Stream_By_Lines;
	Vm_Obj cfn;
        Vm_Obj mss = JOB_P(jS.job)->standard_output;
        Vm_Obj msg = *jS.s;

        job_Will_Write_Message_Stream( mss );

        {   /* Render string into buffer: */
	    Vm_Uch buf[ JOB_MAX_LINE ];
	    Vm_Int first_nl;
	    Vm_Int len = job_Sprint_Vm_Obj(
		buf, buf+JOB_MAX_LINE,
		msg,
		/*quote_strings:*/ FALSE
	    );

	    /* Find first newline: */
	    for (first_nl = 0;  first_nl < len;  ++first_nl) {
		if (buf[ first_nl ] == '\n')   break;
	    }

	    /* Write string if it will fit in stream buffer */
	    /* and contains no newlines except possibly at  */
	    /* the end.   We also take this route if the    */
	    /* symbol ']writeStreamByLines' doesn't have */
	    /* a functional value, just for the sake of the */
	    /* error message it will issue for us:          */
	    cfn = SYM_P(sym)->function;
	    if (first_nl >= len-1
	    &&  (   len < OBJ_TO_INT( MSS_P(mss)->vector_len )
	        ||  !OBJ_IS_CFN( cfn )
		)
	    ){
		/* Copy values from buf[] to  */
		/* obj[], converting from     */
		/* Vm_Uch to Vm_Obj as we go: */
		Vm_Obj obj[ JOB_MAX_LINE ];
		Vm_Int i;
		for (i = 0;   i < len;   ++i) {
		    obj[i] = OBJ_FROM_CHAR( buf[i] );
		}

		/* Send message.   Mark packet */
		/* as complete if it ends with */
		/* a newline, else incomplete: */
		mss_Send(
		    mss,
		    jS.j.acting_user,
		    OBJ_FROM_BYT3('t','x','t'),
		    (first_nl==len) ? OBJ_NIL : OBJ_T,
		    obj, len
		);

	    } else {

		/* Make sure we have room to push */
		/* buf[] on stack:                */
		job_Guarantee_Headroom( len+2 );

		/* Copy buf[] to stack: */
		{   Vm_Int i;
		    *jS.s = OBJ_BLOCK_START;
		    for (i = 0;   i < len;   ++i) {
			*++jS.s = OBJ_FROM_CHAR( buf[i] );
		    }
		    *++jS.s   = OBJ_FROM_BLK(len);
	    	}

		/* Push stream to write to: */
		*++jS.s = mss;

		/* Call ]writeStreamByLines to feed */
		/* the value out in packets small      */
		/* enough to fit in the stream:        */
		job_Call( cfn );

		/* Don't want to pop the args here! */
		return;
	    }
	}
    }
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Write_Stream --						*/
 /***********************************************************************/

void
job_P_Write_Stream(
    void
) {
    /* Write to given mss: */
    Vm_Obj mss  = jS.s[  0 ];
    Vm_Obj msg  = jS.s[ -1 ];

    job_Guarantee_N_Args(    2 );
    job_Guarantee_Mss_Arg(   0 );
    job_Will_Write_Message_Stream( mss );

    {   /* Render string into buffer: */
	Vm_Obj sym = obj_Lib_Muf_Write_Stream_By_Lines;
	Vm_Obj cfn;
	Vm_Uch buf[ JOB_MAX_LINE ];
	Vm_Int len = job_Sprint_Vm_Obj(
	    buf, buf+JOB_MAX_LINE,
	    msg,
	    /*quote_strings:*/ FALSE
	);
	Vm_Int first_nl;

	/* Find first newline: */
	for (first_nl = 0;  first_nl < len;  ++first_nl) {
	    if (buf[ first_nl ] == '\n')   break;
	}

	/* Write string if it will fit in stream buffer */
	/* and contains no newlines except possibly at  */
	/* the end.   We also take this route if the    */
	/* symbol ']writeStreamByLines' doesn't have */
	/* a functional value, just for the sake of the */
	/* error message it will issue for us:          */
	cfn = SYM_P(sym)->function;
	if (first_nl >= len-1
	&&  (   len < OBJ_TO_INT( MSS_P(mss)->vector_len )
	    ||  !OBJ_IS_CFN( cfn )
	    )
	){
	    /* Copy values from buf[] to  */
	    /* obj[], converting from     */
	    /* Vm_Uch to Vm_Obj as we go: */
	    Vm_Obj obj[ JOB_MAX_LINE ];
	    Vm_Int i;
	    for (i = 0;   i < len;   ++i) {
		obj[i] = OBJ_FROM_CHAR( buf[i] );
	    }

	    /* Send message.   Mark packet */
	    /* as complete if it ends with */
	    /* a newline, else incomplete: */
	    mss_Send(
		mss,
		jS.j.acting_user,
		OBJ_FROM_BYT3('t','x','t'),
		(first_nl==len) ? OBJ_NIL : OBJ_T,
		obj, len
	    );

	} else {

	    /* Make sure we have room to push */
	    /* buf[] on stack:                */
	    job_Guarantee_Headroom( len+1 );

	    /* Copy buf[] to stack: */
	    {   Vm_Int i;
		*--jS.s = OBJ_BLOCK_START;
		for (i = 0;   i < len;   ++i) {
		    *++jS.s = OBJ_FROM_CHAR( buf[i] );
		}
		*++jS.s   = OBJ_FROM_BLK(len);
	    }

	    /* Push stream to write to: */
	    *++jS.s = mss;

	    /* Call ]writeStreamByLines to feed */
	    /* the value out in packets small      */
	    /* enough to fit in the stream:        */
	    job_Call( cfn );

	    /* Don't want to pop the args here! */
	    return;
	}
    }

    jS.s -= 2;
}

 /***********************************************************************/
 /*-    job_P_Write_Substring_To_Stream --				*/
 /***********************************************************************/

void
job_P_Write_Substring_To_Stream(
    void
) {
    /* Write to given mss: */
    Vm_Obj mss =             jS.s[  0 ]  ;
    Vm_Int hi  = OBJ_TO_INT( jS.s[ -1 ] );
    Vm_Int lo  = OBJ_TO_INT( jS.s[ -2 ] );
    Vm_Obj stg =             jS.s[ -3 ]  ;

    job_Guarantee_N_Args(    4 );
    job_Will_Write_Message_Stream( mss );
    job_Guarantee_Mss_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );
    job_Guarantee_Int_Arg(  -2 );
    job_Guarantee_Stg_Arg(  -3 );

    {   Vm_Int len    = stg_Len( stg );
        Vm_Int sublen = hi-lo;
	Vm_Uch buf[ JOB_MAX_LINE ];

	if (lo < 0  ) MUQ_WARN ("substring lower limit too small: %d",(int)lo);
	if (lo > len) MUQ_WARN ("substring lower limit too big: %d",(int)lo);
	if (hi > len) MUQ_WARN ("substring upper limit too big: %d",(int)hi);
	if (hi < lo ) MUQ_WARN ("substring limits misordered: %d,%d",(int)lo,(int)hi);

	if (sublen > JOB_MAX_LINE) {
	    MUQ_WARN ("substring too long for server buffer");
	}
	if (sublen >= OBJ_TO_INT( MSS_P(mss)->vector_len )) {
	    MUQ_WARN ("substring too long for stream buffer");
	}

        /* Extract substring into buffer: */
	if (sublen != stg_Get_Bytes(
		buf, 
		sublen,
		stg,
		lo
	)   ) {
	    MUQ_WARN ("internal err");
	}

	{   /* Copy values from buf[] to  */
	    /* obj[], converting from     */
	    /* Vm_Uch to Vm_Obj as we go: */
	    Vm_Obj obj[ JOB_MAX_LINE ];
	    Vm_Int i;
	    for (i = 0;   i < sublen;   ++i) {
		obj[i] = OBJ_FROM_CHAR( buf[i] );
	    }
	    mss_Send(
		mss,
		jS.j.acting_user,
		OBJ_FROM_BYT3('t','x','t'),
		OBJ_T,
		obj, sublen
	    );
	}
    }

    jS.s -= 4;
}

 /***********************************************************************/
 /*-    job_P_Root_Write_Stream --					*/
 /***********************************************************************/

void
job_P_Root_Write_Stream(
    void
) {
    /* Write to given mss: */
    Vm_Obj mss  = jS.s[  0 ];
    Vm_Obj msg  = jS.s[ -1 ];
    Vm_Obj who  = jS.s[ -2 ];

    job_Must_Be_Root();
    job_Guarantee_N_Args(  3 );
    job_Guarantee_Mss_Arg( 0 );

    {   /* Render string into buffer: */
	Vm_Uch buf[ JOB_MAX_LINE ];
	Vm_Obj obj[ JOB_MAX_LINE ];
	Vm_Int len = job_Sprint_Vm_Obj(
	    buf, buf+JOB_MAX_LINE,
	    msg,
	    /*quote_strings:*/ FALSE
	);

	/* Send message: */
        /* Copy values from buf[] to  */
	/* obj[], converting from     */
	/* Vm_Uch to Vm_Obj as we go: */
	Vm_Int i;
	for (i = 0;   i < len;   ++i) {
	    obj[i] = OBJ_FROM_CHAR( buf[i] );
	}
	mss_Send(
	    mss,
	    who,
	    OBJ_FROM_BYT3('t','x','t'),
	    OBJ_T,
	    obj, len
	);
    }

    jS.s -= 3;
}

 /***********************************************************************/
 /*-    job_P_Call_Method -- Find and call method, in generic function.	*/
 /***********************************************************************/

#ifdef OLD
void
job_P_Call_Method(
    void
) {
    /**************************************************/
    /* This prim is a totally hardwired little horror */
    /* intended for nothing but generic functions     */
    /* created by asm_Build_Generic().                */
    /*						      */
    /* We should be in a generic function with the    */
    /* message key as constant #0 and the message     */
    /* arity as constant #1.                          */
    /**************************************************/

    /* Find current executable: */
    Vm_Obj j = jS.x_obj;

    /* Gather together the materials we need: */
    Vm_Int class_quota = JOB_MAX_SUPERCLASSES;
    Vm_Obj keyword   = jS.k[0];
    Vm_Obj arity     = jS.k[1];
    Vm_Obj recipient = jS.s[0];
    Vm_Obj val_obj   = OBJ_NIL;	/* Obj on which key was found. */

    /* Check that we have two constants: */
    Vm_Obj bitbag    = CFN_P(j)->bitbag;
    if (CFN_CONSTS(bitbag) < 2)   MUQ_WARN ("CALLM fn has < 2 consts(!)");

    /* Check that recipient is an object: */
    job_Guarantee_Object_Arg( 0 );

    /* Search for an apropriate method: */
    {   Vm_Obj method  = obj_X_Get_With_Inheritance(
	    &val_obj,
	    &class_quota,
	    recipient,
	    keyword,
	    OBJ_PROP_METHOD
	);
	if (method == OBJ_NOT_FOUND) {
	    MUQ_WARN ("Object doesn't understand that message.");
	}
	/* buggo, at some point we should save val_obj */
	/* where user can find it via 'class' or such. */
	/* Getting scoping right requires pushing some */
	/* sort of stackframe, which is more work than */
	/* I feel like doing just now.		       */

	if (!OBJ_IS_CFN(method)) {
	    MUQ_WARN ("Message method wasn't a compiled function(?!)");
	}

	/* Locate source function for compiledFunction: */
	{   Vm_Obj fn = CFN_P(method)->src;
	    #ifdef MUQ_IS_PARANOID
	    if (!OBJ_IS_OBJ(fn) || !OBJ_IS_CLASS_FN(fn)) {
		MUQ_FATAL ("job_P_Call_Method");
	    }
	    #endif

	    /* Check arity: */
	    {   Vm_Obj   actual_arity = FUN_P(fn)->arity;
		if (  actual_arity != arity
		&&  arity != FUN_ARITY(0,0,0,0,FUN_ARITY_TYP_Q)
		){
		    MUQ_WARN (
			"method mismatch: needed arity %x vs actual arity %x",
			(int)arity,
			(int)actual_arity
		    );
        }   }   }

        /* All systems go for calling: */
        job_Call2(method);
    }
}
#endif


 /***********************************************************************/
 /*-    job_Divide_By_Zero -- 						*/
 /***********************************************************************/

void
job_Divide_By_Zero(
    void
) {
/*job_Trace_Bytecodes = TRUE; /* buggo! */
    MUQ_WARN ("Divide by zero");
}

 /***********************************************************************/
 /*-    job_Now -- Return current time.					*/
 /***********************************************************************/

Vm_Int
job_Now(
    void
) {
    #if VM_INTBYTES > 4

    #ifdef HAVE_GETTIMEOFDAY
    Vm_Int result;
    {   Vm_Int secs0;
	Vm_Int microsecs;
	Vm_Int secs1;
	/* Is there a prettier way?                */
	/* Is it safe to assume the gettimeofday() */
	/* and time() seconds are synchronized?	   */
	do{
	    secs0     = time(NULL);
	    microsecs = sys_Date_Usecs();
	    secs1     = time(NULL);
	} while (secs0 != secs1);
	result = (secs0 * 1000) + (microsecs / 1000);
    }
    #else
    Vm_Int result    = ((Vm_Int) time(NULL)) * 1000;	/* secs -> millisecs */
    #endif

    #else

    Vm_Int result    = (Vm_Int) time(NULL);

    #endif

    MUQ_NOTE_RANDOM_BITS( result );

    return result;
}

 /***********************************************************************/
 /*-    job_P_Proxy_Info -- 						*/
 /***********************************************************************/

void
job_P_Proxy_Info(
    void
) {
    job_Guarantee_N_Args(    1 );
    job_Guarantee_Prx_Arg(   0 );
    job_Guarantee_Headroom(  6 );
    {   Prx_P p = PRX_P( *jS.s );
	jS.s[0] = p->guest;
	jS.s[1] = p->i0;
	jS.s[2] = p->i1;
	jS.s[3] = p->i2;
	jS.s[4] = p->reserved_slot[0];
	jS.s[5] = p->reserved_slot[1];
	jS.s   += 5;
    }
}

 /***********************************************************************/
 /*-    job_P_Continue_Muf_Compile -- (muf -- f | "\nthen> " f t | fn t t) */
 /***********************************************************************/

void
job_P_Continue_Muf_Compile(
    void
) {
    job_Guarantee_N_Args(    1 );
    job_Guarantee_Muf_Arg(   0 );
    job_Must_Control_Object( 0 );
    --jS.s;	/* Pop before any do_if etc pushes start. */
    muf_Continue_Compile( jS.s[1] );
}

 /***********************************************************************/
 /*-    job_P_CommaLs -- ",ls" operator.				*/
 /***********************************************************************/

void
job_P_CommaLs(
    void
) {

/* buggo This should probably be mufcoded, not C-coded, eventually. 93Nov09CrT */
    Vm_Obj what = *jS.s;
    job_Guarantee_N_Args(  1 );
    if (stg_Is_Stg( what ))   what = job_Path_Get_Unrooted( what, 1 );

    job_State_Update();	/* Not needed now, cheap insurance. */
    job_Print_Here( stdout, what, /* All: */ FALSE );

    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_CommaLsa -- ",lsa" operator.				*/
 /***********************************************************************/

void
job_P_CommaLsa(
    void
) {

/* buggo This should probably be mufcoded, not C-coded, eventually. 93Nov09CrT */
    Vm_Obj what = *jS.s;
    job_Guarantee_N_Args(  1 );
    if (stg_Is_Stg( what ))   what = job_Path_Get_Unrooted( what, 1 );

    job_State_Update();	/* Not needed now, cheap insurance. */
    job_Print_Here( stdout, what, /* All: */ TRUE );
}

 /***********************************************************************/
 /*-    job_P_Job_Set_P -- "jobSet?"					*/
 /***********************************************************************/

void
job_P_Job_Set_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_JBS(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Job_Set -- "isAJobSet"				*/
 /***********************************************************************/

void
job_P_Is_A_Job_Set(
    void
) {
    job_Guarantee_Jbs_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Job_Queue_P -- "jobQueue?"				*/
 /***********************************************************************/

void
job_P_Job_Queue_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_JOQ(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Job_Queue -- "isAJobQueue"				*/
 /***********************************************************************/

void
job_P_Is_A_Job_Queue(
    void
) {
    job_Guarantee_Joq_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Job_Queue_Contents -- "job-queue-contents"		*/
 /***********************************************************************/

void
job_P_Job_Queue_Contents(
    void
) {
    Vm_Obj joq = *jS.s;
    Vm_Int siz = 0;
    job_Guarantee_N_Args( 1 );
    job_Guarantee_Joq_Arg(0 );
    job_Must_Control(     0 );

    /* Initialize stack to empty block: */
    *jS.s++ = OBJ_BLOCK_START  ;
    *jS.s   = OBJ_FROM_BLK(siz);

    /* Over all jobs in jobqueue: */
    {   Joq_A_Pointer this;
	for (this = JOQ_P( joq )->link.next;
	    !OBJ_IS_CLASS_JOQ(this.o);
	     this = JOB_P( this.o )->link[ OBJ_TO_UNT(this.i) ].next
	){
	    /* Add job to block: */
	    *jS.s++ = this.o;
	    *jS.s   = OBJ_FROM_BLK(++siz);

	    #if MUQ_IS_PARANOID
	    if (!OBJ_IS_OBJ(      this.o)
	    ||  !OBJ_IS_CLASS_JOB(this.o)
	    ){
		MUQ_FATAL ("Needed job");
	    }
	    #endif
    }	}
}

 /***********************************************************************/
 /*-    job_P_Job_Queues -- "jobQueues["				*/
 /***********************************************************************/

void
job_P_Job_Queues(
    void
) {
    Vm_Obj doz = OBJ_NIL;
    Vm_Obj job = *jS.s;
    Vm_Int qs  = 0;
    job_Guarantee_N_Args( 1 );
    job_Guarantee_Job_Arg(0 );
    job_Must_Control(     0 );

    /* Count number of queues job is in: */
    {   Job_P j = JOB_P( job );
	Vm_Unt i;
	for(i = JOB_QUEUE_MEMBERSHIP_MIN;
	    i < JOB_QUEUE_MEMBERSHIP_MAX;
	    i++
	){
	    Vm_Obj this = j->link[i].this;
	    if (OBJ_IS_OBJ(this) && OBJ_IS_CLASS_JOQ(this)) ++qs;
    }	}

    job_Guarantee_Headroom( qs+2 );

    /* Put bottom-of-block down: */
    *jS.s++ = OBJ_BLOCK_START  ;

    /* Copy all queues job is in to stack: */
    {   Job_P j = JOB_P( job );
	Vm_Unt i;
	for(i = JOB_QUEUE_MEMBERSHIP_MIN;
	    i < JOB_QUEUE_MEMBERSHIP_MAX;
	    i++
	){
	    Vm_Obj this = j->link[i].this;
	    if (OBJ_IS_OBJ(this) && OBJ_IS_CLASS_JOQ(this)) {
		*jS.s++ = this;
    	}   }

	/* If job is sleeping, remember number */
        /* of milliseconds left to sleep:      */
	{   Vm_Obj doz_q = j->link[JOB_QUEUE_DOZ].this;
	    if    (doz_q != OBJ_FROM_INT(0)) {
		doz = OBJ_FROM_INT( OBJ_TO_INT(j->until_msec)-OBJ_TO_INT(jS.now) );
	    }
	}
    }

    /* Add top delimiter for block: */
    *jS.s   = OBJ_FROM_BLK(qs);

    /* If job is in sleep queue, add number of   */
    /* milliseconds to sleep, otherwise add NIL: */
    *++jS.s = doz;
}

 /***********************************************************************/
 /*-    job_P_Lambda_List_P -- "lambdaList?"				*/
 /***********************************************************************/

void
job_P_Lambda_List_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_LBD(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Method_P -- "method?"					*/
 /***********************************************************************/

void
job_P_Method_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_MTD(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Lock_P -- "lock?"						*/
 /***********************************************************************/

void
job_P_Lock_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_LOK(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Lock -- "isALock"					*/
 /***********************************************************************/

void
job_P_Is_A_Lock(
    void
) {
    job_Guarantee_Lck_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Remote_P -- "remote?"					*/
 /***********************************************************************/

void
job_P_Remote_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_PRX(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Session_P -- "session?"					*/
 /***********************************************************************/

void
job_P_Session_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_SSN(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Session -- "isASession"				*/
 /***********************************************************************/

void
job_P_Is_A_Session(
    void
) {
    job_Guarantee_Ssn_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Set_P -- "set?"						*/
 /***********************************************************************/

void
job_P_Set_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_SET(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Set -- "isASet"					*/
 /***********************************************************************/

void
job_P_Is_A_Set(
    void
) {
    job_Guarantee_Set_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Socket_P -- "socket?"					*/
 /***********************************************************************/

void
job_P_Socket_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_SKT(*jS.s)
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Socket -- "isASocket"				*/
 /***********************************************************************/

void
job_P_Is_A_Socket(
    void
) {
    job_Guarantee_Socket_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Keyword_P -- "keyword?"					*/
 /***********************************************************************/

void
job_P_Keyword_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL(
        OBJ_IS_SYMBOL(*jS.s)
	&& SYM_P(*jS.s)->package==obj_Lib_Keyword
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Keyword -- "isAKeyword"				*/
 /***********************************************************************/

void
job_P_Is_A_Keyword(
    void
) {
    job_Guarantee_Symbol_Arg( 0 );
    if (SYM_P(*jS.s)->package!=obj_Lib_Keyword) MUQ_WARN ("Needed keyword");
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Symbol_P -- "symbol?"					*/
 /***********************************************************************/

void
job_P_Symbol_P(
    void
) {
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_SYMBOL(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Symbol -- "isASymbol"				*/
 /***********************************************************************/

void
job_P_Is_A_Symbol(
    void
) {
    job_Guarantee_Symbol_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Cons_P -- "block?"					*/
 /***********************************************************************/

void
job_P_Block_P(
    void
) {
    job_Guarantee_N_Args(1);
    {  Vm_Obj result = OBJ_FROM_BOOL( OBJ_IS_BLK(*jS.s) );
       *++jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Cons_P -- "cons?"						*/
 /***********************************************************************/

void
job_P_Cons_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_CONS(*jS.s)||OBJ_IS_EPHEMERAL_LIST(*jS.s) );}

 /***********************************************************************/
 /*-    job_P_Is_A_Cons -- "isACons"					*/
 /***********************************************************************/

void
job_P_Is_A_Cons(
    void
) {
    job_Guarantee_Cons_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_ConstantP -- "constant?"					*/
 /***********************************************************************/

void
job_P_Constantp(
    void
) {
    Vm_Obj obj = *jS.s;
    job_Guarantee_N_Args(1);

    switch (OBJ_TYPE(obj)) {

    case OBJ_TYPE_SYMBOL:
	if (SYM_IS_CONSTANT(obj)) *jS.s = OBJ_TRUE;
	else                      *jS.s = OBJ_NIL ;
	return;

    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_BLK:
/* buggo, BLK should likely be an error */
    case OBJ_TYPE_FLOAT:
    case OBJ_TYPE_INT:
    case OBJ_TYPE_BIGNUM:
    case OBJ_TYPE_CHAR:
    case OBJ_TYPE_BYTN:
    case OBJ_TYPE_BYT7:
    case OBJ_TYPE_BYT6:
    case OBJ_TYPE_BYT5:
    case OBJ_TYPE_BYT4:
    case OBJ_TYPE_BYT3:
    case OBJ_TYPE_BYT2:
    case OBJ_TYPE_BYT1:
    case OBJ_TYPE_BYT0:
	*jS.s = OBJ_TRUE;
	return;
    }

    *jS.s = OBJ_NIL;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Constant -- "isAConstant"				*/
 /***********************************************************************/

void
job_P_Is_A_Constant(
    void
) {
    Vm_Obj obj = *jS.s;
    job_Guarantee_N_Args(1);

    switch (OBJ_TYPE(obj)) {

    case OBJ_TYPE_SYMBOL:
	if (SYM_IS_CONSTANT(obj)) {
	    --jS.s;
	    return;
	}
	break;

    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_BLK:
/* buggo, BLK should likely be an error */
    case OBJ_TYPE_FLOAT:
    case OBJ_TYPE_INT:
    case OBJ_TYPE_CHAR:
    case OBJ_TYPE_BYTN:
    case OBJ_TYPE_BYT3:
    case OBJ_TYPE_BYT2:
    case OBJ_TYPE_BYT1:
    case OBJ_TYPE_BYT0:
	--jS.s;
	return;
    }

    MUQ_WARN("Needed constant");
}

 /***********************************************************************/
 /*-    job_P_List_P -- "list?"						*/
 /***********************************************************************/

void
job_P_List_P(
    void
) {
    Vm_Obj o = *jS.s;
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL(
        o==OBJ_NIL            ||
        OBJ_IS_CONS(o)        ||
	OBJ_IS_EPHEMERAL_LIST(o)
     );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Lambda_List -- "isALambdaList"			*/
 /***********************************************************************/

void
job_P_Is_A_Lambda_List(
    void
) {
    job_Guarantee_Lbd_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Method -- "isAMethod"				*/
 /***********************************************************************/

void
job_P_Is_A_Method(
    void
) {
    job_Guarantee_Mtd_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_List -- "isAList"					*/
 /***********************************************************************/

void
job_P_Is_A_List(
    void
) {
    Vm_Obj o = *jS.s;
    if (o==OBJ_NIL || OBJ_IS_CONS(o)) { --jS.s;  return; }
    MUQ_WARN("Needed list");
}

 /***********************************************************************/
 /*-    job_P_Float_P -- "float?"					*/
 /***********************************************************************/

void
job_P_Float_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_FLOAT(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Float -- "isAFloat"					*/
 /***********************************************************************/

void
job_P_Is_A_Float(
    void
) {
    job_Guarantee_Float_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Bignum_P -- "bignum?"					*/
 /***********************************************************************/

void
job_P_Bignum_P(
    void
) {
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_BIGNUM( *jS.s ) );
}

 /***********************************************************************/
 /*-    job_P_Fixnum_P -- "fixnum?"					*/
 /***********************************************************************/

void
job_P_Fixnum_P(
    void
) {
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_INT( *jS.s ) );
}

 /***********************************************************************/
 /*-    job_P_Integer_P -- "integer?"					*/
 /***********************************************************************/

void
job_P_Integer_P(
    void
) {
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_INT( *jS.s ) || OBJ_IS_BIGNUM( *jS.s ) );
}

 /***********************************************************************/
 /*-    job_P_Is_An_Integer -- "isAnInteger"				*/
 /***********************************************************************/

void
job_P_Is_An_Integer(
    void
) {
    job_Guarantee_Int_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Number_P -- "number?"					*/
 /***********************************************************************/

void
job_P_Number_P(
    void
) {
    Vm_Obj o = *jS.s;
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_INT(o) || OBJ_IS_FLOAT(o) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Number -- "isANumber"				*/
 /***********************************************************************/

void
job_P_Is_A_Number(
    void
) {
    Vm_Obj o = *jS.s;
    if (OBJ_IS_INT(o) || OBJ_IS_FLOAT(o)) { --jS.s;  return; }
    MUQ_WARN("Needed number");
}

 /***********************************************************************/
 /*-    job_P_String_P -- "string?"					*/
 /***********************************************************************/

void
job_P_String_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( stg_Is_Stg(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_String -- "isAString"				*/
 /***********************************************************************/

void
job_P_Is_A_String(
    void
) {
    if (stg_Is_Stg(*jS.s) ) { --jS.s; return; }
    MUQ_WARN("Needed string");
}

 /***********************************************************************/
 /*-    job_P_Vector_P -- "vector?"					*/
 /***********************************************************************/

void
job_P_Vector_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_VEC(*jS.s)||OBJ_IS_EPHEMERAL_VECTOR(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Vector_I01_P -- "vectorI01?"				*/
 /***********************************************************************/

void
job_P_Vector_I01_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_I01(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Vector_I08_P -- "vectorI08?"				*/
 /***********************************************************************/

void
job_P_Vector_I08_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_I08(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Vector_I16_P -- "vectorI16?"				*/
 /***********************************************************************/

void
job_P_Vector_I16_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_I16(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Vector_I32_P -- "vectorI32?"				*/
 /***********************************************************************/

void
job_P_Vector_I32_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_I32(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Vector_F32_P -- "vectorF32?"				*/
 /***********************************************************************/

void
job_P_Vector_F32_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_F32(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Vector_F64_P -- "vectorF64?"				*/
 /***********************************************************************/

void
job_P_Vector_F64_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_F64(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Vector -- "isAVector"				*/
 /***********************************************************************/

void
job_P_Is_A_Vector(
    void
) {
    job_Guarantee_Vec_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Vector_I01 -- "isAVectorI01"				*/
 /***********************************************************************/

void
job_P_Is_A_Vector_I01(
    void
) {
    job_Guarantee_I01_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Vector_I08 -- "isAVectorI08"				*/
 /***********************************************************************/

void
job_P_Is_A_Vector_I08(
    void
) {
    job_Guarantee_I08_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Vector_I16 -- "isAVectorI16"				*/
 /***********************************************************************/

void
job_P_Is_A_Vector_I16(
    void
) {
    job_Guarantee_I16_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Vector_I32 -- "isAVectorI32"				*/
 /***********************************************************************/

void
job_P_Is_A_Vector_I32(
    void
) {
    job_Guarantee_I32_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Vector_F32 -- "isAVectorF32"				*/
 /***********************************************************************/

void
job_P_Is_A_Vector_F32(
    void
) {
    job_Guarantee_F32_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Vector_F64 -- "isAVectorF64"				*/
 /***********************************************************************/

void
job_P_Is_A_Vector_F64(
    void
) {
    job_Guarantee_F64_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Char_P -- "char?"						*/
 /***********************************************************************/

void
job_P_Char_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_CHAR(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Char -- "isAChar"					*/
 /***********************************************************************/

void
job_P_Is_A_Char(
    void
) {
    job_Guarantee_Char_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Root_P -- "root?"						*/
 /***********************************************************************/

void
job_P_Root_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_ROT(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Omnipotent_P -- "omnipotent?"				*/
 /***********************************************************************/

void
job_P_Omnipotent_P(
    void
) {
    *++jS.s = OBJ_FROM_BOOL( (jS.j.privs & JOB_PRIVS_OMNIPOTENT) != 0 );
}

 /***********************************************************************/
 /*-    job_P_User_P -- "user?"						*/
 /***********************************************************************/

void
job_P_User_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_ISA_USR(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Folk_P -- "folk?"						*/
 /***********************************************************************/

void
job_P_Folk_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_FOLK(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Guest_P -- "guest?"					*/
 /***********************************************************************/

void
job_P_Guest_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_GST(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_User -- "isAUser"					*/
 /***********************************************************************/

void
job_P_Is_A_User(
    void
) {
    job_Guarantee_User_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Message_Stream_P -- "messageStream?"			*/
 /***********************************************************************/

void
job_P_Message_Stream_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_MSS(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Message_Stream -- "isAMessageStream"		*/
 /***********************************************************************/

void
job_P_Is_A_Message_Stream(
    void
) {
    job_Guarantee_Mss_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Package_P -- "package?"					*/
 /***********************************************************************/

void
job_P_Package_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_PKG(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Package -- "isAPackage"				*/
 /***********************************************************************/

void
job_P_Is_A_Package(
    void
) {
    job_Guarantee_Package_Arg(1);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Stream_P -- "stream?"					*/
 /***********************************************************************/

void
job_P_Stream_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_STM(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Stream -- "isAStream"				*/
 /***********************************************************************/

void
job_P_Is_A_Stream(
    void
) {
    job_Guarantee_Stm_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Data_Stack_P -- "dataStack?"				*/
 /***********************************************************************/

void
job_P_Data_Stack_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_DST(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Data_Stack -- "isADataStack?"			*/
 /***********************************************************************/

void
job_P_Is_A_Data_Stack(
    void
) {
    job_Guarantee_Dst_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Loop_Stack_P -- "loopStack?"				*/
 /***********************************************************************/

void
job_P_Loop_Stack_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_LST(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Loop_Stack -- "isALoopStack"			*/
 /***********************************************************************/

void
job_P_Is_A_Loop_Stack(
    void
) {
    if (OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_LST(*jS.s)) { --jS.s; return; }
    MUQ_WARN("Needed loopStack");
}

 /***********************************************************************/
 /*-    job_P_Stack_P -- "stack?"					*/
 /***********************************************************************/

void
job_P_Stack_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_STK(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Stack_P -- "isAStack"					*/
 /***********************************************************************/

void
job_P_Is_A_Stack(
    void
) {
    job_Guarantee_Stk_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Assembler_P -- "assembler?"				*/
 /***********************************************************************/

void
job_P_Assembler_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_ASM(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_An_Array -- "isAnArray"				*/
 /***********************************************************************/

void
job_P_Is_An_Array(
    void
) {
    job_Guarantee_Ary_Arg(   0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Table -- "isATable"					*/
 /***********************************************************************/

void
job_P_Is_A_Table(
    void
) {
    job_Guarantee_Tbl_Arg(   0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_An_Assembler -- "isAnAssembler"			*/
 /***********************************************************************/

void
job_P_Is_An_Assembler(
    void
) {
    job_Guarantee_Asm_Arg(   0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Bound_P -- "bound?"					*/
 /***********************************************************************/

void
job_P_Bound_P(
    void
) {
    job_Guarantee_Symbol_Arg(  0 );
    *jS.s = job_Symbol_Boundp( *jS.s );
}

 /***********************************************************************/
 /*-    job_P_Job_P -- "job?"						*/
 /***********************************************************************/

void
job_P_Job_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_JOB(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Job -- "isAJob"					*/
 /***********************************************************************/

void
job_P_Is_A_Job(
    void
) {
    job_Guarantee_Job_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Job_Is_Alive_P -- "jobIsAlive?"				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_Is_Alive							*/
  /**********************************************************************/

Vm_Int
job_Is_Alive(
    Vm_Obj job
) {
    return JOB_P( job )->link[ JOB_QUEUE_PS ].this != OBJ_FROM_INT(0);
}

  /**********************************************************************/
  /*-   job_P_Job_Is_Alive_P -- "jobIsAlive?"				*/
  /**********************************************************************/

void
job_P_Job_Is_Alive_P(
    void
) {
    Vm_Obj j = *jS.s;
    job_Guarantee_N_Args(1);
    if (!OBJ_IS_OBJ(j) || !OBJ_IS_CLASS_JOB(j)) {
	*jS.s = OBJ_NIL;
	return;
    }
    *jS.s = OBJ_FROM_BOOL( job_Is_Alive( j ) );
}

 /***********************************************************************/
 /*-    job_P_Array_P -- "array?"					*/
 /***********************************************************************/

void
job_P_Array_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_ARY(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Aref -- "aref"						*/
 /***********************************************************************/

void
job_P_Aref(
    void
) {
    MUQ_WARN("aref unimplemented");
}

 /***********************************************************************/
 /*-    job_P_Aset -- "aset"						*/
 /***********************************************************************/

void
job_P_Aset(
    void
) {
    MUQ_WARN("aset unimplemented");
}

 /***********************************************************************/
 /*-    job_P_Table_P -- "table?"					*/
 /***********************************************************************/

void
job_P_Table_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_TBL(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Hash_P -- "hash?"						*/
 /***********************************************************************/

void
job_P_Hash_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_HSH(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Index_P -- "index?"					*/
 /***********************************************************************/

void
job_P_Index_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_NDX(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Plain_P -- "plain?"					*/
 /***********************************************************************/

void
job_P_Plain_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_OBJ(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_An_Index -- "isAnIndex"				*/
 /***********************************************************************/

void
job_P_Is_An_Index(
    void
) {
    job_Guarantee_Index_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Hash -- "isAHash"					*/
 /***********************************************************************/

void
job_P_Is_A_Hash(
    void
) {
    job_Guarantee_Hash_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Plain -- "isAPlain"					*/
 /***********************************************************************/

void
job_P_Is_A_Plain(
    void
) {
    job_Guarantee_Plain_Arg(0);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Ephemeral_P -- "ephemeral?"				*/
 /***********************************************************************/

void
job_P_Ephemeral_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_EPHEMERAL(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_Ephemeral -- "isEphemeral"				*/
 /***********************************************************************/

void
job_P_Is_Ephemeral(
    void
) {
    job_Guarantee_Ephemeral_Arg(0);
    --jS.s;
}


 /***********************************************************************/
 /*-    job_P_Callable_P -- "callable?"					*/
 /***********************************************************************/

void
job_P_Callable_P(
    void
) {
    Vm_Obj o = *jS.s;
    job_Guarantee_N_Args( 1 );
    if (OBJ_IS_CFN(o)) {
        *jS.s = OBJ_T;
    } else if (OBJ_IS_SYMBOL(o) && OBJ_IS_CFN(SYM_P(o)->function)) {
        *jS.s = OBJ_T;
    } else {
        *jS.s = OBJ_NIL;
    }
}

 /***********************************************************************/
 /*-    job_P_Is_Callable -- "isCallable"				*/
 /***********************************************************************/

void
job_P_Is_Callable(
    void
) {
    Vm_Obj o = *jS.s;
    job_Guarantee_N_Args( 1 );
    if (OBJ_IS_CFN(o)) {
        --jS.s;	return;
    } else if (OBJ_IS_SYMBOL(o) && OBJ_IS_CFN(SYM_P(o)->function)) {
        --jS.s;	return;
    }
    MUQ_WARN("Needed callable value");
}

 /***********************************************************************/
 /*-    job_P_Compiled_Function_P -- 'compiledFunction?' operator.	*/
 /***********************************************************************/

void
job_P_Compiled_Function_P(
    void
) {
    Vm_Obj o = *jS.s;
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_CFN(o) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Compiled_Function -- 'isACompiledFunction'	*/
 /***********************************************************************/

void
job_P_Is_A_Compiled_Function(
    void
) {
    job_Guarantee_Cfn_Arg(  0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Lbrk_P -- "[?"						*/
 /***********************************************************************/

void
job_P_Lbrk_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( *jS.s == OBJ_BLOCK_START );
}

 /***********************************************************************/
 /*-    job_P_Function_P -- 'function?' operator.			*/
 /***********************************************************************/

void
job_P_Function_P(
    void
) {
    Vm_Obj o = *jS.s;
    job_Guarantee_N_Args( 1 );
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(o) && OBJ_IS_CLASS_FN(o) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Function -- 'isAFunction' operator.		*/
 /***********************************************************************/

void
job_P_Is_A_Function(
    void
) {
    job_Guarantee_Fn_Arg( 0 );
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Job -- Return current job.				*/
 /***********************************************************************/

void
job_P_Job(
    void
) {
    /* Seize one stack location, and push result in it: */
    *++jS.s = jS.job;
}

 /***********************************************************************/
 /*-    job_P_Current_Compiled_Function -- Return currently running cfn.*/
 /***********************************************************************/

void
job_P_Current_Compiled_Function(
    void
) {
    /* Seize one stack location, and push result in it: */
    *++jS.s = jS.x_obj;
}

 /***********************************************************************/
 /*-    job_P_Mos_Class_P -- 						*/
 /***********************************************************************/

void
job_P_Mos_Class_P(
    void
) {
    job_Guarantee_N_Args(1);
/* buggo: Thunks aren't given a chance to cut in here. */
/* This is a general problem with the predicate fns.   */
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_CDF(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Mos_Key_P -- 						*/
 /***********************************************************************/

void
job_P_Mos_Key_P(
    void
) {
    job_Guarantee_N_Args(1);
/* buggo: Thunks aren't given a chance to cut in here. */
/* This is a general problem with the predicate fns.   */
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_KEY(*jS.s) );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Mos_Class -- 					*/
 /***********************************************************************/

void
job_P_Is_A_Mos_Class(
    void
) {
   job_Guarantee_Cdf_Arg( 0 );
   --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Is_A_Mos_Key -- 						*/
 /***********************************************************************/

void
job_P_Is_A_Mos_Key(
    void
) {
   job_Guarantee_Key_Arg( 0 );
   --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Mos_Object_P -- 						*/
 /***********************************************************************/

void
job_P_Mos_Object_P(
    void
) {
    Vm_Int len;
    Vm_Obj is_a;
    job_Guarantee_N_Args(1);
/* buggo: Thunks aren't given a chance to cut in here. */
/* This is a general problem with the predicate fns.   */
    *jS.s = OBJ_FROM_BOOL(
	OBJ_IS_STRUCT(*jS.s)
        && (is_a = STC_P(*jS.s)->is_a)
        && OBJ_IS_OBJ(is_a)
        && OBJ_IS_CLASS_KEY(is_a)
	||
	OBJ_IS_EPHEMERAL_STRUCT(*jS.s)
        && (is_a = EST_P(&len,*jS.s)->is_a)
        && OBJ_IS_OBJ(is_a)
        && OBJ_IS_CLASS_KEY(is_a)
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Mos_Object --					*/
 /***********************************************************************/

void
job_P_Is_A_Mos_Object(
    void
) {
MUQ_WARN("unimplemented");
   if (!OBJ_IS_EPHEMERAL_STRUCT(*jS.s))   job_Guarantee_Stc_Arg( 0 );
   --jS.s;
}



 /***********************************************************************/
 /*-    job_P_Structure_P -- 						*/
 /***********************************************************************/

void
job_P_Structure_P(
    void
) {
    Vm_Int len;
    Vm_Obj is_a;
    job_Guarantee_N_Args(1);
/* buggo: Thunks aren't given a chance to cut in here. */
/* This is a general problem with the predicate fns.   */
    *jS.s = OBJ_FROM_BOOL(
	OBJ_IS_STRUCT(*jS.s)
        && (is_a = STC_P(*jS.s)->is_a)
        && OBJ_IS_OBJ(is_a)
        && OBJ_IS_CLASS_KEY(is_a)
	||
	OBJ_IS_EPHEMERAL_STRUCT(*jS.s)
        && (is_a = EST_P(&len,*jS.s)->is_a)
        && OBJ_IS_OBJ(is_a)
        && OBJ_IS_CLASS_KEY(is_a)
    );
}

 /***********************************************************************/
 /*-    job_P_Is_A_Structure --						*/
 /***********************************************************************/

void
job_P_Is_A_Structure(
    void
) {
   if (!OBJ_IS_EPHEMERAL_STRUCT(*jS.s))   job_Guarantee_Stc_Arg( 0 );
   --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Nonce_11000A --						*/
 /***********************************************************************/

void
job_P_Nonce_11000A(
    void
) {
   MUQ_WARN("nonce11000a unimplemented");
}

 /***********************************************************************/
 /*-    job_P_Nonce_00100A --						*/
 /***********************************************************************/

void
job_P_Nonce_00100A(
    void
) {
   MUQ_WARN("nonce00100a unimplemented");
}

 /***********************************************************************/
 /*-    job_P_Nonce_00110A --						*/
 /***********************************************************************/

void
job_P_Nonce_00110A(
    void
) {
  MUQ_WARN("nonce00110a unimplemented");
}

 /***********************************************************************/
 /*-    job_P_Nonce_00010A --						*/
 /***********************************************************************/

void
job_P_Nonce_00010A(
    void
) {
   MUQ_WARN("nonce00010a unimplemented");
}

 /***********************************************************************/
 /*-    job_P_Reserved_00 through job_P_Reserved_76 --			*/
 /***********************************************************************/

/* These functions are merely padding in the slow lookup tables, */
/* so as to force the OpenGL functions into separate tables of   */
/* their own, which in turn makes it easier to switch OpenGL     */
/* functionality on or off by changing a table pointer:          */

void job_P_Reserved_00(	void ) {}
void job_P_Reserved_01(	void ) {}
void job_P_Reserved_02(	void ) {}
void job_P_Reserved_03(	void ) {}
void job_P_Reserved_04(	void ) {}
void job_P_Reserved_05(	void ) {}
void job_P_Reserved_06(	void ) {}
void job_P_Reserved_07(	void ) {}
void job_P_Reserved_08(	void ) {}
void job_P_Reserved_09(	void ) {}
     			
void job_P_Reserved_10(	void ) {}
void job_P_Reserved_11(	void ) {}
void job_P_Reserved_12(	void ) {}
void job_P_Reserved_13(	void ) {}
void job_P_Reserved_14(	void ) {}
void job_P_Reserved_15(	void ) {}
void job_P_Reserved_16(	void ) {}
void job_P_Reserved_17(	void ) {}
void job_P_Reserved_18(	void ) {}
void job_P_Reserved_19(	void ) {}
     			
void job_P_Reserved_20(	void ) {}
void job_P_Reserved_21(	void ) {}
void job_P_Reserved_22(	void ) {}
void job_P_Reserved_23(	void ) {}
void job_P_Reserved_24(	void ) {}
void job_P_Reserved_25(	void ) {}
void job_P_Reserved_26(	void ) {}
void job_P_Reserved_27(	void ) {}
void job_P_Reserved_28(	void ) {}
void job_P_Reserved_29(	void ) {}
     			
void job_P_Reserved_30(	void ) {}
void job_P_Reserved_31(	void ) {}
void job_P_Reserved_32(	void ) {}
void job_P_Reserved_33(	void ) {}
void job_P_Reserved_34(	void ) {}
void job_P_Reserved_35(	void ) {}
void job_P_Reserved_36(	void ) {}
void job_P_Reserved_37(	void ) {}
void job_P_Reserved_38(	void ) {}
void job_P_Reserved_39(	void ) {}
     			
void job_P_Reserved_40(	void ) {}
void job_P_Reserved_41(	void ) {}
void job_P_Reserved_42(	void ) {}
void job_P_Reserved_43(	void ) {}
void job_P_Reserved_44(	void ) {}
void job_P_Reserved_45(	void ) {}
void job_P_Reserved_46(	void ) {}
void job_P_Reserved_47(	void ) {}
void job_P_Reserved_48(	void ) {}
void job_P_Reserved_49(	void ) {}
     			
void job_P_Reserved_50(	void ) {}
void job_P_Reserved_51(	void ) {}
void job_P_Reserved_52(	void ) {}
void job_P_Reserved_53(	void ) {}
void job_P_Reserved_54(	void ) {}
void job_P_Reserved_55(	void ) {}
void job_P_Reserved_56(	void ) {}
void job_P_Reserved_57(	void ) {}
void job_P_Reserved_58(	void ) {}
void job_P_Reserved_59(	void ) {}
     			
void job_P_Reserved_60(	void ) {}
void job_P_Reserved_61(	void ) {}

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
