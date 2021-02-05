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

#include "All.h"
#include "jobprims.h"

/************************************************************************/
/*-    Public fns for jobprims.c, arg typechecking 			*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_Guarantee_Ary_Arg -- Error if arg 'n' isn't an array.	*/
 /***********************************************************************/

void
job_Guarantee_Ary_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o =*c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    &&  OBJ_IS_OBJ(        o )
    &&  OBJ_IS_CLASS_ARY(  o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed array argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Tbl_Arg -- Error if arg 'n' isn't a table.	*/
 /***********************************************************************/

void
job_Guarantee_Tbl_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o =*c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    &&  OBJ_IS_OBJ(        o )
    &&  OBJ_IS_CLASS_TBL(  o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed table argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Asm_Arg -- Error if arg 'n' isn't an asm.		*/
 /***********************************************************************/

void
job_Guarantee_Asm_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o =*c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    &&  OBJ_IS_OBJ(        o )
    &&  OBJ_IS_CLASS_ASM(  o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed asm argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Bnm_Arg -- Error if arg 'n' isn't OBJ_TYPE_BNM.	*/
 /***********************************************************************/

void
job_Guarantee_Bnm_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (OBJ_IS_BIGNUM(job_RunState.s[n])) {
	if (!BNM_P(job_RunState.s[n])->private)   return;
    } else {
	job_ThunkN(n);
    }
    MUQ_WARN ("Needed bignum argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Blk_Arg -- Error if arg 'n' isn't OBJ_TYPE_BLK.	*/
 /***********************************************************************/

void
job_Guarantee_Blk_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (OBJ_IS_BLK(job_RunState.s[n]))    return;
    job_ThunkN(n);
    MUQ_WARN ("Needed block argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Cons_Arg -- Error if arg 'n' isn't a cons.	*/
 /***********************************************************************/

void
job_Guarantee_Cons_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (OBJ_IS_CONS( job_RunState.s[n] ))   return;
    job_ThunkN(n);
    MUQ_WARN ("Needed cons argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Cfn_Arg -- Error if arg 'n' isn't an cfn.		*/
 /***********************************************************************/

void
job_Guarantee_Cfn_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (OBJ_IS_CFN( job_RunState.s[n] ))   return;
    job_ThunkN(n);
    MUQ_WARN ("Needed cfn argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Btree_Arg -- Error if arg 'n' isn't a btree.	*/
 /***********************************************************************/

void
job_Guarantee_Btree_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj       o = job_RunState.s[n];
    if (o == OBJ_NULL_DIL) return;
    if (o == OBJ_NULL_SIL) return;
    if (OBJ_IS_OBJ(       o )
    && (OBJ_IS_CLASS_DIL( o ) || OBJ_IS_CLASS_DIN( o ) || OBJ_IS_CLASS_SIL( o ) || OBJ_IS_CLASS_SIN( o ))
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed btree argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Float_Arg -- Error if arg 'n' isn't a float.	*/
 /***********************************************************************/

void
job_Guarantee_Float_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (job_Type0[job_RunState.s[n]&0xFF] == JOB_TYPE_r)    return;
    job_ThunkN(n);
    MUQ_WARN ("Needed float argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_IFloat_Arg -- As above, first converting int to flt.*/
 /***********************************************************************/

void
job_Guarantee_IFloat_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (job_Type0[job_RunState.s[n]&0xFF] == JOB_TYPE_i) {
	job_RunState.s[n] = OBJ_FROM_FLOAT( (float)OBJ_TO_INT(job_RunState.s[n]) );
    }
    if (job_Type0[job_RunState.s[n]&0xFF] == JOB_TYPE_r)    return;
    job_ThunkN(n);
    MUQ_WARN ("Needed float argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Fn_Arg -- Error if arg 'n' isn't a fn.		*/
 /***********************************************************************/

void
job_Guarantee_Fn_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    &&  OBJ_IS_OBJ(      o )
    &&  OBJ_IS_CLASS_FN( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed function argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Char_Arg -- Error if arg 'n' isn't a char.	*/
 /***********************************************************************/

void
job_Guarantee_Char_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (OBJ_IS_CHAR(job_RunState.s[n]))    return;
    job_ThunkN(n);
    MUQ_WARN ("Needed char argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Int_Arg -- Error if arg 'n' isn't an int.		*/
 /***********************************************************************/

void
job_Guarantee_Int_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (OBJ_IS_INT(job_RunState.s[n]))    return;
    job_ThunkN(n);
    MUQ_WARN ("Needed int argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Job_Arg -- Error if arg 'n' isn't a job.		*/
 /***********************************************************************/

void
job_Guarantee_Job_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj       o = job_RunState.s[n];
    if (OBJ_IS_OBJ(       o )
    &&  OBJ_IS_CLASS_JOB( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed job argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Joq_Arg -- Error if arg 'n' isn't a jobQueue.	*/
 /***********************************************************************/

void
job_Guarantee_Joq_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj       o = job_RunState.s[n];
    if (OBJ_IS_OBJ(       o )
    &&  OBJ_IS_CLASS_JOQ( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed jobQueue argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Jbs_Arg -- Error if arg 'n' isn't a jobSet.	*/
 /***********************************************************************/

void
job_Guarantee_Jbs_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj       o = job_RunState.s[n];
    if (OBJ_IS_OBJ(       o )
    &&  OBJ_IS_CLASS_JBS( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed jobSet argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Dst_Arg -- Error if arg 'n' isn't a dataStack.	*/
 /***********************************************************************/

void
job_Guarantee_Dst_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj       o = job_RunState.s[n];
    if (OBJ_IS_OBJ(       o )
    &&  OBJ_IS_CLASS_DST( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed dataStack argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Lck_Arg -- Error if arg 'n' isn't a lock.		*/
 /***********************************************************************/

void
job_Guarantee_Lck_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_LOK( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed lock argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Mss_Arg -- Error if arg 'n' isn't a message stream.*/
 /***********************************************************************/

void
job_Guarantee_Mss_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_MSS( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed message stream argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Hash_Arg -- Error if arg 'n' isn't Hash.		*/
 /***********************************************************************/

void
job_Guarantee_Hash_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_HSH( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed Hash object at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Index_Arg -- Error if arg 'n' isn't Index.	*/
 /***********************************************************************/

void
job_Guarantee_Index_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_NDX( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed Index object at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Plain_Arg -- Error if arg 'n' isn't Plain.	*/
 /***********************************************************************/

void
job_Guarantee_Plain_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_OBJ( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed Plain object at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Ephemeral_Arg -- Error if arg 'n' isn't ephemeral.*/
 /***********************************************************************/

void
job_Guarantee_Ephemeral_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_EPHEMERAL( o )){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed ephemeral value at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Prx_Arg -- Error if arg 'n' isn't remote.		*/
 /***********************************************************************/

void
job_Guarantee_Prx_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj       o = job_RunState.s[n];
    if (OBJ_IS_OBJ(       o )
    &&  OBJ_IS_CLASS_PRX( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed remote argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Dbf_Arg -- Error if arg 'n' isn't database file.	*/
 /***********************************************************************/

void
job_Guarantee_Dbf_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj       o = job_RunState.s[n];
    if (OBJ_IS_OBJ(       o )
    &&  OBJ_IS_CLASS_DBF( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed dbf argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Stm_Arg -- Error if arg 'n' isn't a stream.	*/
 /***********************************************************************/

void
job_Guarantee_Stm_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_STM( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed stream argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Stk_Arg -- Error if arg 'n' isn't a stack.	*/
 /***********************************************************************/

void
job_Guarantee_Stk_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_STK( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed stack argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Set_Arg -- Error if arg 'n' isn't a set.		*/
 /***********************************************************************/

void
job_Guarantee_Set_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_SET( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed set argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Ssn_Arg -- Error if arg 'n' isn't a session.	*/
 /***********************************************************************/

void
job_Guarantee_Ssn_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_SSN( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed session argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Muf_Arg -- Error if arg 'n' isn't a muf.		*/
 /***********************************************************************/

void
job_Guarantee_Muf_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    &&  OBJ_IS_VEC( o )
    &&  vec_Len(    o ) >= MUF_OFF_MAX
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed muf object at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_N_Args -- Error if less than 'n' args on stack.	*/
 /***********************************************************************/

void
job_Guarantee_N_Args(
    Vm_Unt n
) {
    if (&job_RunState.s_bot[n] <= job_RunState.s) {
        return;
    }
    MUQ_WARN ("Stack underflow");
}

 /***********************************************************************/
 /*-    job_Guarantee_Object_Arg -- Error if arg 'n' isn't an object.	*/
 /***********************************************************************/

void
job_Guarantee_Object_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (OBJ_IS_OBJ( job_RunState.s[n] ))   return;
    job_ThunkN(n);
    MUQ_WARN ("Needed object argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Package_Arg -- Error if arg 'n' isn't a package.	*/
 /***********************************************************************/

void
job_Guarantee_Package_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_PKG( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed package argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Cdf_Arg -- Err if isn't a mos-class-definition.	*/
 /***********************************************************************/

void
job_Guarantee_Cdf_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_CDF( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed mos-class-definition argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Key_Arg -- Err if isn't a mosKey.		*/
 /***********************************************************************/

void
job_Guarantee_Key_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_KEY( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed mosKey argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Lbd_Arg -- Err if isn't a lambdaList.		*/
 /***********************************************************************/

void
job_Guarantee_Lbd_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_LBD( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed lambdaList argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Mtd_Arg -- Err if isn't a method.			*/
 /***********************************************************************/

void
job_Guarantee_Mtd_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_MTD( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed method argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Socket_Arg -- Error if arg 'n' isn't a package.	*/
 /***********************************************************************/

void
job_Guarantee_Socket_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_SKT( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed socket argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Evt_Arg -- Error if arg 'n' isn't a condition.	*/
 /***********************************************************************/

#ifdef OLD
void
job_Guarantee_Evt_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_CLASS_EVT( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed condition argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_User_Arg -- Error if arg 'n' isn't a user.	*/
 /***********************************************************************/

void
job_Guarantee_User_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_ISA_USR( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed user argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Folk_Arg -- Error if arg 'n' isn't a user/guest.	*/
 /***********************************************************************/

void
job_Guarantee_Folk_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj  o = job_RunState.s[n];
    if (OBJ_IS_OBJ(  o )
    &&  OBJ_IS_FOLK( o )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed user/guest argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Program_Arg -- Error if arg 'n' isn't a progam.	*/
 /***********************************************************************/

void
job_Guarantee_Program_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    &&  OBJ_IS_OBJ(           o )
#ifdef HARUMPH
    &&  OBJ_IS_CLASS_PRG( o )
#endif
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed program argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Symbol_Arg -- Error if arg 'n' isn't a symbol.	*/
 /***********************************************************************/

void
job_Guarantee_Symbol_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    if (job_Type0[job_RunState.s[n]&0xFF] == JOB_TYPE_s){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed symbol argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Thunk_Arg -- Error if arg 'n' isn't a thunk.	*/
 /***********************************************************************/

void
job_Guarantee_Thunk_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj* c = &job_RunState.s[n];
    if (job_Type0[*c&0xFF] == JOB_TYPE_t){
        return;
    }
    MUQ_WARN ("Needed thunk argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Stg_Arg -- Error if arg 'n' isn't a stg.		*/
 /***********************************************************************/

void
job_Guarantee_Stg_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (stg_Is_Stg(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed string argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Stc_Arg -- Error if arg 'n' isn't a struct.	*/
 /***********************************************************************/

void
job_Guarantee_Stc_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (OBJ_IS_STRUCT(o)
    && (o = STC_P(o)->is_a)
    && OBJ_IS_OBJ(o)
    && OBJ_IS_CLASS_KEY(o)
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed struct argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Mos_Arg -- Error if arg 'n' isn't a mos object.	*/
 /***********************************************************************/

void
job_Guarantee_Mos_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (OBJ_IS_STRUCT(o)
    && (o = STC_P(o)->is_a)
    && OBJ_IS_OBJ(o)
    && OBJ_IS_CLASS_CDF(o) /* buggo, won't this be KEY not CDF? */
    ){			   /* also, what's with ephemerals?     */
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed mos object argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_Vec_Arg -- Error if arg 'n' isn't a vec.		*/
 /***********************************************************************/

void
job_Guarantee_Vec_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_VEC(  o )
       ||  OBJ_IS_EPHEMERAL_VECTOR( o )
       )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed vec argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_I01_Arg -- Error if arg 'n' isn't a vec.		*/
 /***********************************************************************/

void
job_Guarantee_I01_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_I01(  o )
       )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorI01 argument at top-of-stack[%d]", (int)n );
}


 /***********************************************************************/
 /*-    job_Guarantee_I08_Arg -- Error if arg 'n' isn't a vec of uchars.*/
 /***********************************************************************/

void
job_Guarantee_I08_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_I08(  o )
       )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorI08 argument at top-of-stack[%d]", (int)n );
}


 /***********************************************************************/
 /*-    job_Guarantee_I08_Len -- Error if arg 'n' isn't a stg.		*/
 /***********************************************************************/

void
job_Guarantee_I08_Len(
    Vm_Int n,
    Vm_Int len
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_BYTN( o )
       )
    ){
        if (stg_Len(o) != len) {
            MUQ_WARN ("Needed len-%d VectorI08 argument at top-of-stack[%d]", (int)len, (int)n );
	}
        return;
    }

    job_ThunkN(n);
    MUQ_WARN ("Needed VectorI08 (string) argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_I16_Arg -- Error if arg 'n' isn't a vec of shorts.*/
 /***********************************************************************/

void
job_Guarantee_I16_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_I16(  o )
       )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorI16 argument at top-of-stack[%d]", (int)n );
}


 /***********************************************************************/
 /*-    job_Guarantee_I16_Len -- Error if arg 'n' isn't a vec of shorts.*/
 /***********************************************************************/

void
job_Guarantee_I16_Len(
    Vm_Int n,
    Vm_Int len
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_I16(  o )
       )
    ){
        if (i16_Len(o) != len) {
            MUQ_WARN ("Needed len-%d VectorI16 argument at top-of-stack[%d]", (int)len, (int)n );
	}
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorI16 argument at top-of-stack[%d]", (int)n );
}


 /***********************************************************************/
 /*-    job_Guarantee_I32_Arg -- Error if arg 'n' isn't a vec.		*/
 /***********************************************************************/

void
job_Guarantee_I32_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_I32(  o )
       )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorI32 argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_I32_Len -- Error if arg 'n' isn't a vec.		*/
 /***********************************************************************/

void
job_Guarantee_I32_Len(
    Vm_Int n,
    Vm_Int len
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_I32(  o )
       )
    ){
        if (i32_Len(o) != len) {
            MUQ_WARN ("Needed len-%d VectorI32 argument at top-of-stack[%d]", (int)len, (int)n );
	}
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorI32 argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_F32_Arg -- Error if arg 'n' isn't a vec.		*/
 /***********************************************************************/

void
job_Guarantee_F32_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_F32(  o )
       )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorF32 argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_F32_Len -- Error if arg 'n' isn't a vec.		*/
 /***********************************************************************/

void
job_Guarantee_F32_Len(
    Vm_Int n,
    Vm_Int len
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_F32(  o )
       )
    ){
        if (f32_Len(o) != len) {
            MUQ_WARN ("Needed len-%d VectorF32 argument at top-of-stack[%d]", (int)len, (int)n );
	}
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorF32 argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_F64_Arg -- Error if arg 'n' isn't a vec.		*/
 /***********************************************************************/

void
job_Guarantee_F64_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_F64(  o )
       )
    ){
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorF64 argument at top-of-stack[%d]", (int)n );
}

 /***********************************************************************/
 /*-    job_Guarantee_F64_Len -- Error if arg 'n' isn't a vec.		*/
 /***********************************************************************/

void
job_Guarantee_F64_Len(
    Vm_Int n,
    Vm_Int len
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;
    if (job_Type0[*c&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_F64(  o )
       )
    ){
        if (f64_Len(o) != len) {
            MUQ_WARN ("Needed len-%d VectorF64 argument at top-of-stack[%d]", (int)len, (int)n );
	}
        return;
    }
    job_ThunkN(n);
    MUQ_WARN ("Needed VectorF64 argument at top-of-stack[%d]", (int)n );
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
