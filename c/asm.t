@example  @c

/* To do: */
/* Implement tail recursion properly. */
/* buggo: Need to hack asm to set ROOT bit on cfns when appropriate.  */
/* buggo: Can compiler deposit a PUSH_CATCHFRAME or other such opcode */      
/*        directly, bypassing the special assembler instructions and  */
/*        mebbe crashing us?                                          */


/*--   asm.c -- ASseMbler for muq compilers.				*/
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
/* Created:      93May15						*/
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
/* Talent is obsessively determined to be what others expect.		*/
/* Genius is obsessively determined to know the truth.			*/
/************************************************************************/



/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/************************************************************************/
/*

To improve performance, the Muq interpreter trusts that cfn
(compiledFunction) objects are correct in various senses, and doesn't
bother checking for all conceivable problems such as jumps to spots
not within the current code segment etc: This is basically the
familiar performance tweak of moving work from execution time to
compile time.

It is the responsibility of the asm.c module to ensure that only valid
cfn objects are generated, even in the face of malicious users trying
to crash the system or bypass security.

Asm sits as an opaque interface between whatever compiler is
constructing the new cfn, and the cfn itself: Asm is the 'security
kernel' of the compilation process, enforcing correctness constraints
while attempting to impose no policy constraints -- this way, Muq
users can be allowed to write new compilers for new languages, if they
wish, without compromising the security or reliability of Muq.

In essence, an asm object contains the state information needed about
a partly-compiled cfn, hides that state information from the user to
prevent naughtiness, and exports enough high-level operations on that
state to allow construction of any valid cfn object, while
implementing enough checking to prevent the construction of any
invalid cfn object.



Datastructures
--------------

A compiled function consists primarily of a vector of Vm_Obj (4-byte)
constants, followed by a vector of one-byte bytecodes, packed in the
same physical object.  Thus, during the assembly process, we are
primarily accumulating these two vectors.

We use a regular Stack instance to accumulate the constants.
As a small optimization, we usually search this stack for
a constant before adding it to the stack, and use the
existing copy of it if already present.

Our 'local_vars' stack holds the names of all loopstack local-variable
slots which we have so far allocated for this function.

We accumulate the bytecodes proper in the 'bytecodes' stack, stored
simply as one Vm_Obj format (4-byte) int for each byte of code.

We accumulate debug information about the source-code line number
corresponding to each bytecode in the 'linecodes' stack, which has
one entry for each 'bytecodes' entry, made simply by pushing our
'line_number' on 'linecodes' whenever we push any value on
'bytecodes'.  (It is entirely up to the compiler to keep our
'line_number' property updated to a reasonable value, via the
#/line-number property.)

We accumulate information about branch locations and
targets in the "labels" stack.  All entries on this
stack are Vm_Obj format integers;  We use a few bits
at the bottom to distinguish different types of
entries, and the remainder as an integer offset.

Each label (jump target) on the "labels" stack is represented
as a two-entry block:

   LOC:     Offset in 'bytecodes' at which label resides.
   ID:      Integer name distinguishing this from other labels.

Each branch is recorded
as a block of stack entries so:
  
   OP:      Actual 'branch' opcode.
   LEN:     Current length of offset: 2 bytes or 1.
   LOC:     Offset in 'bytecodes' at which branch resides.
   LINK:    Integer name of label to which we are branching.





Compiling Branches
------------------

Compiling branches is slightly amusing, since we have both one- and
two-byte offsets available, and want to use the smallest allowable
size... which depends in turn on the sizes of other jumps.  There is
actually an academic literature on this problem, the optimal solution
involves assuming initially that all branches use two-byte offsets,
and then iteratively shrinking all possible branches to one-byte
offsets until a fixpoint is reached.  Doing this in optimal complexity
requires an unreasonably sophisticated data structure... most
real-world compilerfolk just iterate, yielding O(N^2) worst-case
complexity for an N-jump fn.

We deposit all our branches with two-byte offsets, initially, in
'bytecodes'.  We also record the 'bytecodes' offsets of all jumps and
labels in 'labels', along with a couple of bits distinguishing jump
from label offsets.  Each jump gets an additional 'labels' word
recording the label it is linked to.

'branch_fixups()' handles branches in four steps:

  link_branches_to_labels() changes the LINK field in each branch
  from an integer label to the integer offset in 'labels' of the
  matching label.  This is done by linearly searching 'labels'
  once for each branch, so CPU cost is O(N^2).  (If compilation
  speed of large functions becomes an issue, this may need fixing.
  A simple sort would allow finding each label in O(logN) time,
  for overall O(NlogN) time, which should be good enough.)

  minimize_branch_offsets() iteratively tests each branch to see
  if its offset can be shortened from two to one bytes, until no
  further progress can be made.  Typically, almost all branches
  will in fact collapse, and each collapse will require updating
  the address of all branches after us, so CPU cost here is O(N^2)
  also.  If this becomes an issue, an option to simply skip this
  step might be one solution.

  compact_bytecodes_stack() collapses the 'bytecodes' stack to
  eliminate all holes left by shrinking branch offsets.  This
  is O(N) with a low constant, and shouldn't ever pose a problem.

  patch_in_branch_opcodes_and_offsets_etc(), finally, selects the
  correct binary representation for each branch based on the selected
  offset size, and patches it into the 'bytecodes' array.  This is
  likewise a basically O(N) process, hence unlikely to be much of a
  problem.



 ************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"
#include "jobprims.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Maximum number of global variables permitted: */
#ifndef ASM_MAX_PROGVARS
#define ASM_MAX_PROGVARS (50)
#endif

/* Maximum number of local variables permitted: */
#ifndef ASM_MAX_VARS
#define ASM_MAX_VARS (256)
#endif

/* #defines used in 'labels' array, which */
/* uses a 3-bit low-end typefield:        */

/* Each branch effectively gets a 4-word structure: */
#define VAL(i)        ((i)>>3)

#define OP_OFFSET   (0)
#define LEN_OFFSET  (1)
#define LOC_OFFSET  (2)
#define LINK_OFFSET (3)
#define BRANCH_LEN  (4)

#define IS_OP(i)     (((i)&0x7)==3)
#define IS_LEN(i)    (((i)&0x7)==4)
#define IS_LOC(i)    (((i)&0x7)==5)
#define IS_LINK(i)   (((i)&0x7)==6)

#define OP(i)        (((i)<<3)|3)
#define LEN(i)       (((i)<<3)|4)
#define LOC(i)       (((i)<<3)|5)
#define LINK(i)      (((i)<<3)|6)

/* Labels are 2-word structures: */
#define IS_LABEL_LOC(i)  (((i)&0x7)==1)
#define IS_LABEL_ID(i)   (((i)&0x7)==2)
#define LABEL_LOC(i)     (((i)<<3)|1)
#define LABEL_ID(i)      (((i)<<3)|2)
#define LABEL_LEN        (2)




/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

#if MUQ_DEBUG
static int      invariants(FILE*,char*,Vm_Obj);
#endif

static Vm_Unt   sizeof_asm( Vm_Unt );
static void     for_new(    Vm_Obj, Vm_Unt );

static Vm_Unt   constant_note( Vm_Obj, Vm_Obj );
static void     compute_arity( Vm_Obj, Vm_Obj, Vm_Obj, Vm_Int );

static void     deposit_offset( Vm_Obj, Vm_Int, Vm_Int );

static void     branch_fixups(  Vm_Obj );

static Vm_Int  lookup_ascii_opcode(Vm_Uch*);
static Vm_Int  lookup_fast_opcode(Vm_Int);
static Vm_Int  lookup_slow_opcode(Vm_Int,Vm_Int);
#ifdef SOMETIMES_USEFUL_WHEN_DEBUGGING
static void    printstate(Vm_Uch*,Vm_Obj);
#endif

static void    deposit_offset( Vm_Obj,Vm_Int,Vm_Int );

static Vm_Int  offset_needed( Vm_Int, Vm_Int, Vm_Int );
static void    push_byte( Vm_Obj, Vm_Int );
static void    asm_unary(Vm_Obj,Vm_Unt,Vm_Unt);

static void    warn( Vm_Obj, Vm_Uch*, ...  );

static Vm_Obj  bytecodes_len(      Vm_Obj );
static Vm_Obj  compile_time(       Vm_Obj );
static Vm_Obj  compile_time_set(   Vm_Obj, Vm_Obj );
static Vm_Obj  never_in_line(      Vm_Obj );
static Vm_Obj  never_in_line_set(  Vm_Obj, Vm_Obj );
static Vm_Obj  next_label(         Vm_Obj );
static Vm_Obj  next_label_set(     Vm_Obj, Vm_Obj );
static Vm_Obj  please_in_line(     Vm_Obj );
static Vm_Obj  please_in_line_set( Vm_Obj, Vm_Obj );
static Vm_Obj  save_debug_info(    Vm_Obj );
static Vm_Obj  save_debug_info_set(Vm_Obj, Vm_Obj );
static Vm_Obj  flavor(             Vm_Obj );
static Vm_Obj  flavor_set(         Vm_Obj, Vm_Obj );
static Vm_Obj  vars(               Vm_Obj );
static Vm_Obj  vars_set(           Vm_Obj, Vm_Obj );
static Vm_Obj  fn_name(            Vm_Obj );
static Vm_Obj  fn_name_set(        Vm_Obj, Vm_Obj );
static Vm_Obj  file_name(          Vm_Obj );
static Vm_Obj  file_name_set(      Vm_Obj, Vm_Obj );
static Vm_Obj  fn_line(          Vm_Obj );
static Vm_Obj  fn_line_set(      Vm_Obj, Vm_Obj );
static Vm_Obj  line_in_fn(         Vm_Obj );
static Vm_Obj  line_in_fn_set(     Vm_Obj, Vm_Obj );
static Vm_Obj  asm_set_never(	   Vm_Obj, Vm_Obj );



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property asm_system_properties[] = {

    /* Include properties require on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"bytecodes"	, bytecodes_len	     , asm_set_never		},
    {0,"compileTime?"	, compile_time	     , compile_time_set		},
    {0,"fileName"	, file_name	     , file_name_set		},
    {0,"fnLine"	, fn_line	     , fn_line_set		},
    {0,"fnName"	, fn_name	     , fn_name_set		},
    {0,"lineInFn"	, line_in_fn	     , line_in_fn_set		},
    {0,"neverInline?"	, never_in_line	     , never_in_line_set	},
    {0,"nextLabel"	, next_label	     , next_label_set		},
    {0,"pleaseInline?"	, please_in_line     , please_in_line_set	},
    {0,"saveDebugInfo", save_debug_info    , save_debug_info_set	},
    {0,"flavor"		, flavor	     , flavor_set		},
    {0,"vars"		, vars	     	     , vars_set			},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class asm_Hardcoded_Class = {
    OBJ_FROM_BYT3('a','s','m'),
    "Assembler",
    sizeof_asm,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { asm_system_properties, asm_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void asm_doTypes(void){}
Obj_A_Module_Summary asm_Module_Summary = {
    "asm",
    asm_doTypes,
    asm_Startup,
    asm_Linkup,
    asm_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    asm_Branch -- Assemble an un/conditional branch.			*/
/************************************************************************/

void
asm_Branch(
    Vm_Obj asm,
    Vm_Unt op,
    Vm_Unt label_id
) {
    /* Remember branch opcode, loc, len, reserve space for label link: */
    {   Vm_Obj bytecodes = ASM_P(asm)->bytecodes;
        Vm_Unt byte_off  = OBJ_TO_UNT( stk_Length(bytecodes) );
        Vm_Obj labels    = ASM_P(asm)->labels;
        stk_Push(labels, OBJ_FROM_INT(OP(  op      )));
        stk_Push(labels, OBJ_FROM_INT(LEN( 2       )));
        stk_Push(labels, OBJ_FROM_INT(LOC( byte_off)));
        stk_Push(labels, OBJ_FROM_INT(LINK(label_id)));
    }

    /* Deposit dummy opcode byte and offset byte(s): */
    push_byte(asm, 0 );
    deposit_offset(asm, /*bytes_needed:*/ 2, 0 );
}



/************************************************************************/
/*-    asm_Build_Generic -- Build a simple MUF-style generic function.	*/
/************************************************************************/

#ifdef OLD
Vm_Obj
asm_Build_Generic(
    Vm_Obj name,
    Vm_Obj keyword,
    Vm_Obj arity
) {
    /*************************************/
    /* Our standard MUF generic function */
    /* is very simpleminded:             */
    /*				         */
    /*   CALLM (two bytes);		 */
    /*   RET   (one byte ); 	         */
    /*				         */
    /* It needs two constants, the key-  */
    /* word and the arity;  Making a new */
    /* generic just requires a bit-copy  */
    /* and changing the two constants.   */
    /*				         */
    /* At four bytes/cell, 2 constants + */
    /* 3 bytes of code => 3 cells:	 */
    /*************************************/

    Vm_Obj src    = obj_Alloc( OBJ_CLASS_A_FN, 0 );
    Vm_Obj gen = cfn_Alloc( 3, OBJ_K_CFN );
    {   Cfn_P   x  = vm_Loc( gen );
	Vm_Uch* p  = (Vm_Uch*) (&x->vec[2]);
	Vm_Uch* q  = (Vm_Uch*) (&x->vec[3]);

        /* Deposit "CALL_METHOD" instruction: */
	Vm_Int code = asm_Look_Up_Primcode( JOB_OP_CALL_METHOD );
	*p++ = job_Code[code].op;
	if (job_Code[code].op2) {
	    *p++ = (job_Code[code].op2 & 0xFF);
	}

        /* Deposit "RETURN" instruction: */
	code = asm_Look_Up_Primcode( JOB_OP_RETURN );
	*p++ = job_Code[code].op;
	if (job_Code[code].op2) {
	    *p++ = (job_Code[code].op2 & 0xFF);
	}

	/* Pad rest of cell with FFs so it disassembles neatly: */
	#if MUQ_IS_PARANOID
	if (p > q)   MUQ_FATAL ("internal err");
	#endif
	while (p < q)   *p++ = 0xFF;

	/* Don't forget the constants: */
	x->vec[0] = keyword;
	x->vec[1] = arity;

	/* Nor source and type: */
	x->src    = src;
	x->bitbag = CFN_SET_GENERIC( CFN_SET_CONSTS( OBJ_0,2 ) );

	vm_Dirty(gen);
    }

    /* Now we need a matching source object: */
    {   Fun_P  f      = FUN_P( src );
	f->arity      = arity;
	f->o.objname  = name;
	f->executable = gen;
	vm_Dirty(src);
    }

    return gen;
}
#endif


/************************************************************************/
/*-    asm_Call -- Assemble fn call.					*/
/************************************************************************/

void
asm_Call(
    Vm_Obj asm,    /* Asm to receive bytes.	*/
    Vm_Obj fn      /* Function to call.		*/
) {
    Vm_Obj cfn = OBJ_0;	/* Initialized only to quiet compilers. */

    if (OBJ_IS_SYMBOL(fn)) {
	cfn = job_Symbol_Function(fn);
        if (!OBJ_IS_CFN(cfn)) {
	    /* Assume compiledFunction will */
	    /* be slotted in later.  This is */
	    /* required when compiling auto- */
	    /* recursive functions:          */
	    asm_unary(
		asm,
		JOB_OP_CALLI,
		constant_note( asm, fn )
	    );
	    return;
	}
#ifdef OLD
    } else if (OBJ_IS_OBJ(fn)
    &&         OBJ_IS_CLASS_FN(fn)
    ){
/* buggo, should phase out this hack sometime soon */
	cfn = FUN_P(fn)->executable;
#endif
    } else if (OBJ_IS_CFN(fn)) {
	cfn = fn;
        fn  = FALSE;
    } else {
	warn( asm, "asm_Call: 'fn' isn't fn or symbol!" );
    }
    if (!OBJ_IS_CFN(cfn)) warn(asm,"asm_Call: fn/sym val isn't a procedure?!");

    /* Expand calls to primitive procedures   */
    /* into inline bytecodes.  This is likely */
    /* to surprise a few people who discover  */
    /* that resetting some symbol at runtime  */
    /* doesn't have the expected effect, but  */
    /* I can't think of a better way offhand: */
    {   Vm_Obj bitbag = CFN_P(cfn)->bitbag;
	if (CFN_IS_PRIM(bitbag)) {
	    /* Assemble generic primitive: */
	    Vm_Obj op = CFN_P(cfn)->vec[0];
	    asm_Nullary( asm, OBJ_TO_UNT( op ) );
	    return;
    }	}

    /* It would be slightly faster to call the cfn	*/
    /* directly, but calling via the symbol		*/
    /* instead means that anyone calling the function	*/
    /* automatically gets the new code if the function	*/
    /* gets recompiled, where if we assembled a call	*/
    /* call to the cfn, all code calling the function	*/
    /* would have to be located and recompiled after	*/
    /* each change to it, which is both a nuisance and	*/
    /* likely to confuse our target audience of naive	*/
    /* programmers.  Calling via the symbol also meshes	*/
    /* with lisp traditions and lisp hacking practices:	*/
    asm_unary(
	asm,
	JOB_OP_CALLI,
	constant_note( asm, fn ? fn : cfn )
    );
}

/************************************************************************/
/*-    asm_Calla -- Assemble fn call with runtime arity check.		*/
/************************************************************************/

void
asm_Calla(
    Vm_Obj asm,    /* Asm to receive bytes.	*/
    Vm_Obj arity   /* Arity to check.		*/
) {
    /* Sanity checks, partly to make sure arity will */
    /* not later crash compute_basic_block_arity():  */
    Vm_Unt tp = FUN_ARITY_TYP_GET(arity);
    if (!OBJ_IS_INT(arity)) warn(asm,"assembleCalla: arity must be integer");
    switch (tp) {
    case FUN_ARITY_TYP_NORMAL:		/* Normal operator.		*/
    case FUN_ARITY_TYP_EXIT:		/* Operator that doen't return.	*/
    case FUN_ARITY_TYP_Q:		/* For { -> ? } ops.		*/
    case FUN_ARITY_TYP_START_BLOCK:	/* For JOB_OP_START_BLOCK.	*/
    case FUN_ARITY_TYP_END_BLOCK:	/* For JOB_OP_END_BLOCK.	*/
    case FUN_ARITY_TYP_EAT_BLOCK:	/* For ']' operator.		*/
	/* These should be ok: */
	break;

    case FUN_ARITY_TYP_CALLI:	/* For JOB_OP_CALLI.		*/
    case FUN_ARITY_TYP_BRANCH:	/* Operator that hacks pc.	*/
    case FUN_ARITY_TYP_OTHER:	/* Remaining special cases.	*/
    case FUN_ARITY_TYP_CALLA:	/* For JOB_OP_CALLA.		*/
    case FUN_ARITY_TYP_CALL_METHOD:	/* For JOB_OP_CALL_METHOD.	*/
    default:
	/* I don't see any reason for these in a call{...}: */
	warn(asm,"assembleCalla: unsupported arity type");
    }

    asm_unary( asm, JOB_OP_CALLA, constant_note( asm, arity ) );
}



/************************************************************************/
/*-    asm_Const -- Assemble const-load.				*/
/************************************************************************/

void
asm_Const(
    Vm_Obj asm,    /* Asm to receive bytes.	*/
    Vm_Obj k	   /* Const to load.		*/
) {
    /* Special case for small integers: */
    if (OBJ_IS_INT(k)) {
        Vm_Int i = OBJ_TO_INT(k);
	if (-128 < i   &&   i < 128) {
	    asm_unary( asm, JOB_OP_GETi, i );
	    return;
    }	}

    /* General case: */
    asm_unary( asm, JOB_OP_GETk, constant_note( asm, k ) );
}



/************************************************************************/
/*-    asm_ConstNth -- Assemble const-load of 'n'th constant.		*/
/************************************************************************/

void
asm_ConstNth(
    Vm_Obj asm,    /* Asm to receive bytes.	*/
    Vm_Unt n       /* Const slot to load from.	*/
) {
    /* Check that we _have_ n constants: */
    Vm_Obj  constants =  ASM_P(asm)->constants;
    Vm_Unt  len       = OBJ_TO_UNT( stk_Length( constants ) );
    if (n >= len)   warn(asm,"Tried to load const #%" VM_D ", only %" VM_D " exist!",n,len);

    asm_unary( asm, JOB_OP_GETk, n );
}



/************************************************************************/
/*-    asm_ConstSlot -- Allocate constant slot.				*/
/************************************************************************/

Vm_Unt
asm_ConstSlot(
    Vm_Obj asm
) {
    Vm_Obj  constants = ASM_P(asm)->constants;
    Vm_Unt  loc_const = OBJ_TO_UNT( stk_Length( constants ) );
    stk_Push(   constants, OBJ_FROM_INT(0) );
    return  loc_const;
}



/************************************************************************/
/*-    asm_Const_Asciz -- Assemble const-load of ascii string.		*/
/************************************************************************/

void
asm_Const_Asciz(
    Vm_Obj  asm,    /* Asm to receive bytes.	*/
    Vm_Uch* str
) {
    asm_Const( asm, stg_From_Asciz( str ) );
}



/************************************************************************/
/*-    asm_Sprint_Code_Disassembly -- Disassemble to buffer.		*/
/************************************************************************/


 /***********************************************************************/
 /*-   asm_scd_disassemble_offset -- disassemble offset of continuation.*/
 /***********************************************************************/


  /**********************************************************************/
  /*-  asm_scd_get_offset -- read offset from instruction stream.	*/
  /**********************************************************************/

static Vm_Int
asm_scd_get_offset(
    Vm_Uch** ppc,
    Job_Code c
) {
    Vm_Uch* pc = *ppc;
    Vm_Int  offset = 0;	/* Initialized only to quiet compilers. */
    if (!c->x_signed) {
	switch (c->x) {
	case 1:
	    offset = *pc++;
	    break;
	case 2:
	    offset = (pc += 2,   (pc[-1] << VM_BYTEBITS) + pc[-2]);
	    break;
	case 3:
	    offset = (pc += 3,   (pc[-1] << 2*VM_BYTEBITS) + (pc[-2] << VM_BYTEBITS) + pc[-3]);
	    break;
	case 0:
	default:
	    MUQ_FATAL ("ux");
	}
    } else {
        switch (c->x) {
	case 1:
	    offset = ((Vm_Sch)*pc++);
	    break;
	case 2:
	    offset = ((Vm_Sht)(pc += 2,   (pc[-1] << VM_BYTEBITS) + pc[-2]));
	    break;
	case 3:
	    /* Hmm, this depends on ints being 32 bits: */
	    offset = (pc += 3,
                ((Vm_Int)
                    (   ((Vm_Int)(pc[-1]) << (VM_INTBITS-1*VM_BYTEBITS))
                    +   ((Vm_Int)(pc[-2]) << (VM_INTBITS-2*VM_BYTEBITS))
                    +   ((Vm_Int)(pc[-3]) << (VM_INTBITS-3*VM_BYTEBITS))
                    )
                ) >> VM_INTBITS-3*VM_BYTEBITS
            );
	    break;
	case 0:
	default:
	    MUQ_FATAL ("sx");
	}
    }
    *ppc = pc;
    return offset;
}

  /**********************************************************************/
  /*-  asm_scd_disassemble_offset -- disassemble offset of continuation.*/
  /**********************************************************************/

static Vm_Uch*
asm_scd_disassemble_offset(

    Vm_Uch*     buf,
    Vm_Uch*     lim,

    Vm_Uch**	pc,

    Job_Code	c,
    Vm_Uch*	buf0
) {
    /* We print branch offsets as the hex destination within the */
    /* fn, other offsets we print as absolute decimal numbers:   */
    Vm_Uch*  op_pc     = (*pc)-1;
    Vm_Int   key       = job_Code[ lookup_fast_opcode(*op_pc) ].key;
    Vm_Int   is_branch = JOB_IS_BRANCH( key );
    Vm_Int   offset    = asm_scd_get_offset(pc,c);
    if (!is_branch)   buf = lib_Sprint(buf,lim, "%" VM_D,    offset );
    else	      buf = lib_Sprint(buf,lim, "%03x:", ((*pc)+offset)-buf0 );
    return buf;
}

 /***********************************************************************/
 /*-   asm_Sprint_Code_Disassembly -- Disassemble to buffer.		*/
 /***********************************************************************/

Vm_Uch*
asm_Sprint_Code_Disassembly(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Uch* buf0,	/* First byte     to disassemble.	*/
    Vm_Uch* bufN	/* First byte not to disassemble.	*/
) {
    /****************************************************/
    /* WARNING: asm_Assemble_Instruction() makes rather */
    /* detailed assumptions about the format of the     */
    /* listing we produce here, used in lib_import.	*/
    /****************************************************/

    Vm_Uch* pc;
    for    (pc = buf0;   pc < bufN;   ) {

	/* Print the opcode: */
	Vm_Unt op   = *pc++;
	if (op  < JOB_SLOW_PREFIX_BYTES) {

	    /* Slow opcode: */
	    Vm_Unt code = lookup_slow_opcode( op, *pc++ );
	    Job_Code c  = &job_Code[code];
	    buf = lib_Sprint(buf,lim,
		"%03x:   00 %02x          %s\n",
		(pc-buf0)-2, pc[-1], c->name
	    );

	} else {

	    /* Fast opcode: */
	    Vm_Unt code = lookup_fast_opcode( op );
	    Job_Code c  = &job_Code[code];

	    /* Hex-print address and opcode: */
	    buf = lib_Sprint(buf,lim,"%03x:      %02x", (pc-buf0)-1, pc[-1] );

	    /* Hex-print argument offset if present: */
	    if (c->x) {
		int offset = asm_scd_get_offset(&pc,c) & 0xFFFF;
		int hibyte = offset >> 8;
		if ((hibyte & 0xFF)
		&&  (hibyte ^ 0xFF)
		){
		    buf = lib_Sprint(buf,lim," %04x",   offset & 0xFFFF );
		} else {
                    buf = lib_Sprint(buf,lim," %02x  ", offset & 0x00FF );
		}
	    } else {
		buf = lib_Sprint(buf,lim,"     "           );
	    }
	    pc -= c->x;	/* Set pc back to pre-'get_offset' setting. */

	    /* Ascii-print opcode: */
	    buf = lib_Sprint(buf,lim, "     %-6s ", c->name );

	    /* Ascii-print argument offset if present: */
	    if (c->x)  buf = asm_scd_disassemble_offset(buf,lim, &pc, c, buf0);

	    buf = lib_Sprint(buf,lim, "\n");
	}
    }
    if (pc != bufN)   MUQ_FATAL ("bad codebuf");
    return buf;
}



/************************************************************************/
/*-    asm_Assemble_Instruction -- Return bytecodes given ascii.	*/
/************************************************************************/

#ifndef ASM_MAX_INSTR
#define ASM_MAX_INSTR 132
#endif

Vm_Int
asm_Assemble_Instruction(
    Vm_Uch* buf,
    Vm_Int  buflen,
    Vm_Uch* instr
) {
    Vm_Uch* o = buf;
    Vm_Uch* t;
    Vm_Uch  op[ ASM_MAX_INSTR ];
    if (strlen( instr ) > ASM_MAX_INSTR) {
	MUQ_WARN ("asm_Assemble_Instruction: input too long.");
    }

    /* Skip hex for instruction: */
    if (strlen( instr ) < 23) {
	MUQ_FATAL ("asm_Assemble_Instruction: bad assembly code!");
    }
    t = instr + 22;

    /* Scan in the opcode proper: */
    if (1 != sscanf( t, "%s", op )) {
	MUQ_FATAL ("asm_Assemble_Instruction: missing opcode!");
    }

    /* Find instruction with that opcode: */
    {   Vm_Int code = lookup_ascii_opcode( op );

	/* If instruction has no extension bytes, write */
	/* instruction bytecodes into result buffer and */
	/* we're done:                                  */
	if (!job_Code[code].x) {
            *o++ = job_Code[code].op;
	    if (job_Code[code].op2)   *o++ = job_Code[code].op2 & 0xFF;
	    return o-buf;
	}

	/* Instruction has argument, read arg also: */
	{   /* Separate cases for jumps and others: */
	    int arg;
	    if (!JOB_IS_BRANCH(job_Code[code].key)) {
		if (2 != sscanf(t, "%s %d", op, &arg )) {
		    MUQ_FATAL ("asm_Assemble_Instruction: missing argument!");
		}
	    } else {
		/* Arg is hex instruction address, */
		/* resolve it by comparison with   */
		/* address of current instruction: */
		int inst_adr;
		int inst_arg;
		int inst_len = (job_Code[code].op2 ? 2 : 1);
		/* Cheat, count number of extension bytes in hex listing: */
		Vm_Int  arg_len = (instr[16]==' ') ? 1 : 2;
		if (1 != sscanf(instr, "%x", &inst_adr )) {
		    MUQ_FATAL ("asm_Assemble_Instruction: missing address!");
		}
		if (2 != sscanf(t, "%s %x", op, &inst_arg )) {
		    MUQ_FATAL ("asm_Assemble_Instruction: missing argument!");
		}
		arg = inst_arg - (inst_adr + inst_len + arg_len);
	    }

	    /* Select 'code' with 1 or 2 bytes of index, as needed: */
	    {   Vm_Int x_signed     = job_Code[code].x_signed;
		Vm_Int bytes_needed = offset_needed( 0, x_signed, arg );
		Vm_Int key          = job_Code[code].key;
		Vm_Int i;
		for   (i = 0;   ;   ++i) {
		    if (job_Code[code+i].key != key) {
			MUQ_WARN ("asm_Assemble_Instruction: no opcode");
		    }
		    if (job_Code[code+i].x   == bytes_needed)   break;
		}
		code += i;

		/* Deposit opcode(s) proper: */
            	*o++ = job_Code[code].op;
	        if (job_Code[code].op2)   *o++ = job_Code[code].op2 & 0xFF;

		/* Deposit appropriate number of extension bytes: */
		if (bytes_needed == 1) {
		    *o++ = arg;
		}
		if (bytes_needed == 2) {
		    *o++ = arg      & 0xFF;
		    *o++ = (arg>>8) & 0xFF;
		}
		return o-buf;
    }   }   }   
}



/************************************************************************/
/*-    asm_Disassemble_Opcode -- Return ascii for opcode.		*/
/************************************************************************/

Vm_Uch*
asm_Disassemble_Opcode(
    Vm_Uch* pc
) {
    /* Print the opcode: */
    Vm_Unt op   = *pc++;

    Vm_Unt  code;
    if (op < JOB_SLOW_PREFIX_BYTES) code  = lookup_slow_opcode( op, *pc++ );
    else    			    code  = lookup_fast_opcode( op        );

    return job_Code[code].name;
}



/************************************************************************/
/*-    asm_Cfn_Build -- Finish assembly, return new cfn object.		*/
/************************************************************************/

Vm_Obj
asm_Cfn_Build(
    Vm_Obj   asm,
    Vm_Obj   fn,
    Vm_Obj   arity,	/* Signature for arguments.	*/
    Vm_Int   force	/* TRUE to force arity.		*/
) {
    /* Make sure we have a RETURN at end of fn: */
    asm_Nullary( asm, JOB_OP_RETURN );

    /* Do final hacks on branches: */

    branch_fixups( asm );

    {   /* Find stack containing bytecodes: */
	Vm_Obj bytecodes  = ASM_P(asm)->bytecodes;
	Vm_Obj linecodes  = ASM_P(asm)->linecodes;
	Vm_Obj file_name  = ASM_P(asm)->file_name;
	Vm_Obj fn_line    = ASM_P(asm)->fn_line;

	/* Count number of bytes of executable code: */
	Vm_Int byte_len   = OBJ_TO_INT( stk_Length( bytecodes ) );

	/* Find stack containing constants: */
	Vm_Obj constants  = ASM_P(asm)->constants;

	/* Count number of cells of constants: */
	Vm_Int cell_len   = OBJ_TO_INT( stk_Length( constants ) );

	Vm_Obj flavor 	      = ASM_P(asm)->flavor;

	/* Build executable consisting of a stack */
	/* just big enough to contain above:      */
	Vm_Obj executable = cfn_Alloc(
	    cell_len  +  (byte_len + sizeof(Vm_Obj)-1) / sizeof(Vm_Obj),
            ((flavor == job_Kw_Thunk || flavor == job_Kw_Promise) ? OBJ_K_THUNK : OBJ_K_CFN)
	);

	Vm_Obj compile_time   = ASM_P(asm)->compile_time;
	Vm_Obj never_in_line  = ASM_P(asm)->never_in_line;
	Vm_Obj please_in_line = ASM_P(asm)->please_in_line;

	/* Construct a vector to hold the line number info: */
	Vm_Obj linecodes_vec  = vec_Alloc( byte_len, OBJ_FROM_INT(0) );

	/* Construct a vector to hold the local variable names: */
	Vm_Obj local_vars     = ASM_P(asm)->local_vars;
	Vm_Int var_count      = OBJ_TO_INT( stk_Length( local_vars )  );
	Vm_Obj locals_vec     = vec_Alloc( var_count, OBJ_FROM_INT(0) );

	#if MUQ_IS_PARANOID
	if (!byte_len)  warn(asm,"Len-0 compiled code");
	#endif

	/* Copy linecodes from stack into vec:	  */
	{   Vm_Obj vec = STK_P(linecodes)->vector;
	    Vec_P  src;
	    Vec_P  dst;
	    Vm_Int i;
	    vm_Loc2( (void**)&dst, (void**)&src, linecodes_vec, vec );
	    for (i = 0;   i < byte_len;   ++i) {
		dst->slot[i]  = src->slot[i];
	    }
	    vm_Dirty(linecodes);
	}

	/* Copy var names from stack into vec:	  */
	if (var_count) {
	    Vm_Obj vec = STK_P(local_vars)->vector;
	    Vec_P  src;
	    Vec_P  dst;
	    Vm_Int i;
	    vm_Loc2( (void**)&dst, (void**)&src, locals_vec, vec );
	    for (i = 0;   i < var_count;   ++i) {
		dst->slot[i]  = src->slot[i];
	    }
	    vm_Dirty(locals_vec);
	}

	/* Plug executable, arity, linecodes */
	/* and filename into fn:             */
	{   Fun_P  p          = FUN_P(fn);
	    p->arity          = arity;
	    p->executable     = executable;
	    p->line_numbers   = linecodes_vec;
	    p->fn_line        = fn_line;
	    p->file_name      = file_name;
	    p->local_variable_names = locals_vec;
	    vm_Dirty(fn);
	}

	/* Copy constants into executable: */
	{   Vm_Obj vec = STK_P(constants)->vector;
	    Vec_P  src;
	    Cfn_P  dst;
	    Vm_Int i;
	    vm_Loc2( (void**)&dst, (void**)&src, executable, vec );
	    for (i = 0;   i < cell_len;   ++i) {
		dst->vec[i] = src->slot[i];
	    }

	    dst    ->bitbag = CFN_SET_CONSTS(    OBJ_0,cell_len );
	    if (flavor == job_Kw_Promise) {
		dst->bitbag = CFN_SET_PROMISE(      dst->bitbag );
	    } else if (flavor == job_Kw_Thunk) {
		dst->bitbag = CFN_SET_THUNK(        dst->bitbag );
	    } else if (flavor == job_Kw_Mos_Generic && cell_len) {
		dst->bitbag = CFN_SET_MOS_GENERIC( dst->bitbag );
	    } else {
		dst->bitbag = CFN_SET_FN(           dst->bitbag );
	    }
	    if (never_in_line != OBJ_NIL) {
		dst->bitbag = CFN_SET_NEVER_INLINE( dst->bitbag );
	    }
	    if (please_in_line != OBJ_NIL) {
		dst->bitbag = CFN_SET_PLEASE_INLINE( dst->bitbag );
	    }
/* buggo, should really make this a type field with flavor */
	    if (compile_time != OBJ_NIL) {
		dst->bitbag = CFN_SET_COMPILETIME(  dst->bitbag );
	    }
	    /* Install executable -> fn pointer while we're at it: */
	    dst->src = fn;
	    vm_Dirty(executable);
	}

	/* Copy bytecodes into executable: */
	{   Vm_Obj vec = STK_P(bytecodes)->vector;
	    Vec_P  src;
	    Cfn_P  dst;
	    vm_Loc2( (void**)&dst, (void**)&src, executable, vec );

	    {   Vm_Uch* p = (Vm_Uch*) &dst->vec[ CFN_CONSTS(dst->bitbag) ];
		Vm_Int  u;
		for    (u = 0;   u < byte_len;   ++u) {
		    *p++ = OBJ_TO_INT( src->slot[ u ] );
		}

		/* Set remaining unused bytes to FF: */
		{   Vm_Int cell_part = byte_len % sizeof(Vm_Obj);
		    if    (cell_part) {
			byte_len += sizeof(Vm_Obj) - cell_part;
			for (;   u < byte_len;   ++u) {
			    *p++ = 0xFF;
	    }   }   }   }
	    vm_Dirty(executable);
	}

	compute_arity( asm, fn, arity, force );

        return executable;
    }
}



/************************************************************************/
/*-    asm_Label -- Assemble a branch label.				*/
/************************************************************************/

void
asm_Label(
    Vm_Obj asm,
    Vm_Unt label_id
) {
    /* Remember label offset: */
    Vm_Obj bytecodes = ASM_P(asm)->bytecodes;
    Vm_Unt byte_off  = OBJ_TO_INT( stk_Length(bytecodes) );
    Vm_Obj labels    = ASM_P(asm)->labels;
    if (label_id >= OBJ_TO_UNT( ASM_P(asm)->next_label )) {
	MUQ_WARN ("Invalid assembler label: %" VM_D "(%" VM_X ")", label_id, label_id);
    }
    stk_Push(labels, OBJ_FROM_INT(LABEL_LOC( byte_off )) );
    stk_Push(labels, OBJ_FROM_INT(LABEL_ID(  label_id )) );
}

/************************************************************************/
/*-    asm_Label_Get -- Issue next label number to use.			*/
/************************************************************************/

Vm_Unt
asm_Label_Get(
    Vm_Obj   asm
) {
    Vm_Unt result;
    {   Asm_P a = ASM_P(asm);
	result = OBJ_TO_UNT( a->next_label );
	a->next_label = OBJ_FROM_UNT( result+1 );
        vm_Dirty(asm);
    }
    return result;
}

/************************************************************************/
/*-    asm_Line_In_Fn -- Set line number.				*/
/************************************************************************/

void
asm_Line_In_Fn(
    Vm_Obj   asm,
    Vm_Obj   line_in_fn
) {
    ASM_P(asm)->line_in_fn = line_in_fn; vm_Dirty(asm);
}

/************************************************************************/
/*-    asm_Look_Up_Primcode -- Look up given instruction in job_Code (asm) */
/************************************************************************/

Vm_Int
asm_Look_Up_Primcode(
    Vm_Int op	/* JOB_OP_POP or whatever. */
) { 
    Vm_Int key = op;
    Vm_Int lo  = 0;
    Vm_Int hi  = JOB_CODE_MAX;
    while (lo < hi-1) {
        Vm_Int mid = (lo + hi) >> 1;
	Vm_Int k   = job_Code[mid].key;
	if      (key < k)   hi = mid;
        else if (key > k)   lo = mid;
        else              { lo = mid;  break; }
    }
    while (lo && job_Code[lo-1].key==key)   --lo;
    if (         job_Code[lo  ].key!=key)   MUQ_FATAL ("Bad opcode");
    return lo;
}  



/************************************************************************/
/*-    asm_Nullary -- Assemble zero-address instruction into binary.	*/
/************************************************************************/

void
asm_Nullary(
    Vm_Obj asm,		/* Asm to receive bytes: */
    Vm_Unt op		/* Specs for instruction to assemble: */
) {
    Vm_Uch buf[4];
    switch (asm_Nullary_To_Buf(buf,op)) {

    case 1:
        push_byte( asm, buf[0] );
	break;

    case 2:
        push_byte( asm, buf[0] );
        push_byte( asm, buf[1] );
	break;

    default:
	MUQ_FATAL ("asm_Nullary: internal err");
    }
}



/************************************************************************/
/*-    asm_Nullary_To_Buf -- Assemble zero-address instr into bytebuf.	*/
/************************************************************************/

Vm_Int
asm_Nullary_To_Buf(
    Vm_Uch* buf,
    Vm_Unt  op
) {
    /* Find our primary opcode: */
    Vm_Int code = asm_Look_Up_Primcode( op );

    /* Find opcode with zero offset size: */
    Vm_Int key = job_Code[code].key;
    Vm_Int i;
    for (i = 0;   ;   ++i) {
	if (job_Code[code+i].key != key) {
	    MUQ_WARN ("asm_Nullary_To_Buf:no opcode");
	}
	if (job_Code[code+i].x   == 0)   break;
    }
    code += i;

    /* Deposit opcode byte[s]: */
    buf[0] = (job_Code[code].op        );
    if (!job_Code[code].op2)    return 1;
    buf[1] = (job_Code[code].op2 & 0xFF);
    return 2;
}



/************************************************************************/
/*-    asm_Reset -- Reset asm context for new compile.			*/
/************************************************************************/

void
asm_Reset(
    Vm_Obj asm
) {
    stk_Reset( ASM_P(asm)->constants  );
    stk_Reset( ASM_P(asm)->bytecodes  );
    stk_Reset( ASM_P(asm)->labels     );
    stk_Reset( ASM_P(asm)->linecodes  );
    stk_Reset( ASM_P(asm)->local_vars );

    /* Deposit a VARS instruction to allocate local variables: */
    asm_unary( asm, JOB_OP_VARS, 0 );

    {   Asm_P a = ASM_P(asm);
	a->line_in_fn     = OBJ_FROM_INT( 0 );
	a->fn_line        = OBJ_FROM_INT( 0 );
	a->next_label     = OBJ_FROM_UNT( 0 );
	a->fn_name        = OBJ_FROM_BYT0;
	a->compile_time   = OBJ_NIL;
	a->never_in_line  = OBJ_NIL;
	a->please_in_line = OBJ_NIL;
	a->flavor         = OBJ_NIL;
        vm_Dirty(asm);
    }
}



/************************************************************************/
/*-    asm_unary -- Assemble one-address instruction into binary.	*/
/************************************************************************/

/* Note: this function isn't exported because it would */
/* be too much of a security hole, likely, allowing    */
/* folks to assemble illegal offsets for jumps and     */
/* variables and such.				       */

static void
asm_unary(

    /* Asm to receive bytes: */
    Vm_Obj asm,

    /* Specs for instruction to assemble: */
    Vm_Unt op,
    Vm_Unt offset
) {
    Vm_Unt code = asm_Look_Up_Primcode( op );

    /* Select 'code' with 0, 1 or 2 bytes of index, as needed: */
    Vm_Int x_signed     = job_Code[code].x_signed;
    Vm_Int bytes_needed = offset_needed( 0, x_signed, offset );
    Vm_Int key          = job_Code[code].key;
    Vm_Int i;
    for   (i = 0;   ;   ++i) {
	if (job_Code[code+i].key != key) {
	    warn(asm,"asm_unary: no opcode");
	}
	if (job_Code[code+i].x   == bytes_needed)   break;
    }
    code += i;

    /* Deposit opcode byte[s] and offset: */
    push_byte(                           asm, job_Code[code].op         );
    if (job_Code[code].op2)   push_byte( asm, job_Code[code].op2 & 0xFF );
    deposit_offset(asm, bytes_needed, offset );
}



/************************************************************************/
/*-    asm_Var    -- Assemble local-variable read.			*/
/************************************************************************/

void
asm_Var(
    Vm_Obj asm,    /* Asm to receive bytes.		*/
    Vm_Unt offset  /* Offset of variable to read.	*/
) {
    if (offset >= OBJ_TO_UNT( stk_Length(ASM_P(asm)->local_vars))) {
        warn(asm,"Bad var offset %" VM_D ".",offset);
    }

    asm_unary( asm, JOB_OP_GETv, offset );
}



/************************************************************************/
/*-    asm_Var_Set -- Assemble local-variable write.			*/
/************************************************************************/

void
asm_Var_Set(
    Vm_Obj asm,    /* Asm to receive bytes.		*/
    Vm_Unt offset  /* Offset of variable to write.	*/
) {
    if (offset >= OBJ_TO_UNT( stk_Length(ASM_P(asm)->local_vars))) {
        warn(asm,"Bad var offset %" VM_D ".",offset);
    }

    asm_unary( asm, JOB_OP_SETv, offset );
}



/************************************************************************/
/*-    asm_Var_Next -- Allocate next local var, return offset.		*/
/************************************************************************/

Vm_Unt
asm_Var_Next(
    Vm_Obj asm,
    Vm_Obj name
) {
    Vm_Obj local_vars = ASM_P(asm)->local_vars;
    Vm_Unt result     = OBJ_TO_UNT( stk_Length( local_vars ) );
    if (result >= ASM_MAX_VARS) {
	warn(asm,"Too many (%d) local variables",ASM_MAX_VARS);
    }
    stk_Push( local_vars, name );
    return result;
}




/************************************************************************/
/*-    --- Standard public fns ---					*/
/************************************************************************/



/************************************************************************/
/*-    asm_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
asm_Startup(
    void
) {

    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;

    vm_Startup();
    obj_Startup();	/* Ensures /etc exists.	*/
    stk_Startup();
    cfn_Startup();

    /* Make sure /etc/bad exists and is a cfn. */
    /* /etc/bad is used as the initial value   */
    /* for fun->executable on new 'fun's, and  */
    /* also as a placeholder cfn in muf.t in   */
    /* sym->function, until the real cfn is    */
    /* done compiling:                         */
    {   Vm_Obj etc = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("etc"), OBJ_PROP_PUBLIC );
	Vm_Obj bad = OBJ_GET( etc,        sym_Alloc_Asciz_Keyword("bad"), OBJ_PROP_PUBLIC );
	if (bad != OBJ_NOT_FOUND && !OBJ_IS_CFN(bad)) {
	    obj_Etc_Bad = bad;
	} else {
/* buggo: For some reason obj_Etc_Bad is coming out a */
/* thunk rather than just a cfn.  I don't see any good */
/* reason for this...? Prolly should fix it. */
	    Vm_Obj bad = cfn_Alloc( 1, OBJ_K_CFN );
	    Cfn_P   x  = vm_Loc( bad );
	    Vm_Uch* p  = (Vm_Uch*) x->vec;
	    Vm_Unt  i  = sizeof( Vm_Obj )-1;
	    Vm_Int code=asm_Look_Up_Primcode( JOB_OP_BAD );
	    p[0] = job_Code[code].op;
            if (job_Code[code].op2) {
		p[1] = (job_Code[code].op2 & 0xFF);
		--i;
	    }
	    /* Pad rest of cell with FFs so it disassembles neatly: */
	    while (i --> 0)   *++p = 0xFF;
	    vm_Dirty(bad);
	    OBJ_SET( etc, sym_Alloc_Asciz_Keyword("bad"), bad, OBJ_PROP_PUBLIC );
	    obj_Etc_Bad = bad;

	    /* Add source function for bad: */
	    {	Vm_Uch buf[ 256 ];
		Vm_Obj fun = obj_Alloc( OBJ_CLASS_A_FN, 0 );
		sprintf(buf,
		    "#<Server prim 0x%04x: '%s'>",
		    JOB_OP_BAD, "bad"
		);
		{   Vm_Obj source = stg_From_Asciz(buf);
		    Vm_Obj name   = stg_From_Asciz("BAD");
		    Vm_Int op     = JOB_OP_BAD;
		    Vm_Int arity  = job_Code[ asm_Look_Up_Primcode(op) ].arity;
		    Fun_P  f      = FUN_P(fun);
		    f->o.objname  = name;
		    f->source     = source;
		    f->executable = bad;
		    f->arity      = arity;
		    vm_Dirty(fun);
		}
		CFN_P(bad)->src   = fun;
		vm_Dirty(bad);
    }	}   }
}



/************************************************************************/
/*-    asm_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
asm_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    vm_Linkup();
    obj_Linkup();
}



/************************************************************************/
/*-    asm_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
asm_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    vm_Shutdown();
    obj_Shutdown();
}


#ifdef OLD

/************************************************************************/
/*-    asm_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
asm_Import(
    FILE* fd
) {
    MUQ_FATAL ("asm_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    asm_Export -- Write object into textfile.			*/
/************************************************************************/

void
asm_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("asm_Export unimplemented");
}


#endif

/************************************************************************/
/*-    asm_Invariants -- Sanity check on asm.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
asm_Invariants (
    FILE* errlog,
    char* title,
    Vm_Obj fn
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, fn );
#endif
    return errs;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    branch_fixups -- Figure branch offset sizes and patch correctly. */
/************************************************************************/


 /***********************************************************************/
 /*-   link_branches_to_labels						*/
 /***********************************************************************/


  /**********************************************************************/
  /*-  find_label							*/
  /**********************************************************************/

#undef  NOT_FOUND
#define NOT_FOUND ((Vm_Unt)~0)
static Vm_Unt
find_label(
    Vm_Obj labels,
    Vm_Unt label_id
) {
    /* Over all branches and labels in 'labels': */
    Vm_Unt label_off = OBJ_TO_UNT( stk_Length(labels) );
    Vm_Unt u         = 0;
    while (u < label_off) {

	/* Fetch first entry in "record": */
	Vm_Int i = stk_Get_Int( labels, u );

	/* Ignore branch records: */
	if (IS_OP(i)) {  u += BRANCH_LEN;   continue;  }

	/* Check label id, return record location  */
	/* if this is the label we're looking for: */      
	{   Vm_Unt id = VAL( stk_Get_Int( labels, u+1 ) );
	    if (id == label_id)   return u;
    	}
	u += LABEL_LEN;
    }
    return NOT_FOUND;
}


  /**********************************************************************/
  /*-  link_branches_to_labels						*/
  /**********************************************************************/

/* Yes, this has icky O(N^2) performance.  Likely, */
/* we won't get fns big enough for it to matter... */

static void
link_branches_to_labels(
    Vm_Obj asm
) {
    /* Over all branches and labels in 'labels': */
    Vm_Obj labels    = ASM_P(asm)->labels;
    Vm_Unt label_off = OBJ_TO_UNT( stk_Length(labels) );
    Vm_Unt u         = 0;
    while (u < label_off) {

	/* Fetch first entry in "record": */
	Vm_Int i = stk_Get_Int( labels, u );

	/* Ignore label records: */
	if (IS_LABEL_LOC(i)) {  u += LABEL_LEN;   continue;  }

	/* Check for trashed 'labels' (server bugs): */
	if (!IS_OP(i)) MUQ_FATAL ("check_for_unlinked_branches: bad 'labels'");

	/* Translate 'link' field in branch record from */
        /* a label id to a label offset in 'labels':    */
	{   Vm_Unt link = VAL( stk_Get_Int( labels, u + LINK_OFFSET ) );
	    link = find_label( labels, link );
	    if (link == NOT_FOUND) {
		warn(asm,"asm: Missing label");
	    }
	    stk_Set_Int( labels, u + LINK_OFFSET, LINK(link) );
	}
	u += BRANCH_LEN;
    }
}
#undef  NOT_FOUND



 /***********************************************************************/
 /*-   minimize_branch_offsets -- Shrink two- to one-byte offsets.	*/
 /***********************************************************************/


  /**********************************************************************/
  /*-  shrink_branch -- Change branch from two-byte offset to one.	*/
  /**********************************************************************/

static void
shrink_branch(
    Vm_Obj labels,
    Vm_Unt branch
) {
    /************************************************************/
    /* Shrink the branch at offset 'branch' in 'labels'.	*/
    /* This is mainly amusing because it changes the location   */
    /* of all jumps and labels beyond us in 'labels': 	        */
    /************************************************************/
    Vm_Unt label_off = OBJ_TO_UNT( stk_Length(labels) );
    Vm_Unt u         = branch;

    /* Change our 'len' field from 2 to 1: */
    stk_Set_Int(
        labels,
        u + LEN_OFFSET, 
	LEN( 1 )
    );

    /* Step to next branch/label in 'labels': */
    u += BRANCH_LEN;

    /* Decrement location of all succeeding labels and branches: */
    while (u < label_off) {

	Vm_Int i = stk_Get_Int( labels, u );
	if (IS_LABEL_LOC(i)) {

	    /* Decrement label location: */
	    Vm_Int loc = VAL( stk_Get_Int( labels, u ) );
	    stk_Set_Int(
		labels,
		u, 
		LABEL_LOC( loc-1 )
	    );
	    u += LABEL_LEN;
	    continue;
	}

#if MUQ_IS_PARANOID
	if (!IS_OP(i))  MUQ_FATAL ("Bad labels op");
#endif

	/* Decrement branch location: */
	{   Vm_Int loc = VAL( stk_Get_Int( labels, u+LOC_OFFSET ) );
	    stk_Set_Int(
		labels,
		u+LOC_OFFSET, 
		LOC( loc-1 )
	    );
	    u += BRANCH_LEN;
	    continue;
	}
    }
}

  /**********************************************************************/
  /*-  minimize_branch_offsets -- Shrink two- to one-byte offsets.	*/
  /**********************************************************************/

static void
minimize_branch_offsets(
    Vm_Obj asm
) {
    Vm_Int bigjumps_left = FALSE;
    Vm_Int progress_made = TRUE;

    /* Repeat while there's hope of shrinking more branches: */
    do {
	/* Over all instructions in procedure: */

	#if MUQ_IS_PARANOID
	Vm_Obj bytecodes = ASM_P(asm)->bytecodes;
	Vm_Int byte_off  = OBJ_TO_INT( stk_Length(bytecodes) );
	#endif
	Vm_Obj labels    = ASM_P(asm)->labels;
	Vm_Int label_off = OBJ_TO_INT( stk_Length(labels) );
	Vm_Int u         = 0;

	bigjumps_left = FALSE;
	progress_made = FALSE;

	while (u < label_off) {

	    /* Fetch first entry in "record", ignore labels: */
	    Vm_Int i = stk_Get_Int( labels, u );
	    if (IS_LABEL_LOC(i)) {  u += LABEL_LEN;   continue;  }

	    /* Attempt to shrink branch: */	
	    {   /* Fetch components of record: */
	    /*	Vm_Int op   = VAL( stk_Get_Int( labels, u+  OP_OFFSET ) ); */
		Vm_Int len  = VAL( stk_Get_Int( labels, u+ LEN_OFFSET ) );
		Vm_Int loc  = VAL( stk_Get_Int( labels, u+ LOC_OFFSET ) );
		Vm_Int link = VAL( stk_Get_Int( labels, u+LINK_OFFSET ) );
		#if MUQ_IS_PARANOID
		if (link < 0 || link >= label_off) MUQ_FATAL ("Bad link addr");
		#endif
		if (len == 2) {
		    Vm_Int label     = stk_Get_Int( labels, link );
		    Vm_Int label_loc = VAL(label);

		    #if MUQ_IS_PARANOID
		    if (!IS_LABEL_LOC(label))  MUQ_FATAL ("Bad link op");
		    if (label_loc < 0 || label_loc >= byte_off) {
			MUQ_FATAL ("Bad link val");
		    }
		    #endif

		    /* If span would fit in one signed byte, shrink jump: */
		    if (loc < label_loc) {
			int span  = label_loc - (loc+2);
			if (span <= 127) {
			    shrink_branch( labels, u );
			    progress_made = TRUE;
			} else {
			    bigjumps_left = TRUE;
			}
		    } else {
			int span  = (loc+2) - label_loc;
			if (span <= 128) {
			    shrink_branch( labels, u );
			    progress_made = TRUE;
			} else {
			    bigjumps_left = TRUE;
			}
		    }
		}
	    }

	    /* Step to next record: */
	    u += BRANCH_LEN;
	}
    } while (bigjumps_left && progress_made);
}



 /***********************************************************************/
 /*-   compact_bytecodes_stack						*/
 /***********************************************************************/

static void
compact_bytecodes_stack(
    Vm_Obj asm
) {
    /******************************************/
    /* Collapse 'bytecodes', closing up holes */
    /* opened by shrinking branches.	      */
    /******************************************/

    /* Over all branches: */
    Vm_Obj bytecodes = ASM_P(asm)->bytecodes;
    Vm_Obj linecodes = ASM_P(asm)->linecodes;
    Vm_Obj byte_off  = OBJ_TO_UNT( stk_Length(bytecodes) );
    Vm_Obj labels    = ASM_P(asm)->labels;
    Vm_Unt label_off = OBJ_TO_UNT( stk_Length(labels) );
    Vm_Unt next      = 0;	/* Next slot to copy to.		*/
    Vm_Unt lost      = 0;	/* Bytes deleted by branch-shrinking.	*/
    Vm_Unt u         = 0;
    Vm_Int noVARS    = OBJ_TO_INT(stk_Length(ASM_P(asm)->local_vars)) ? 0 : 2;

    /* We also delete the initial VARS instruction if */
    /* we in fact wound up with no local variables:   */
    if (noVARS)   lost += 2;

    while (u < label_off) {

	/* Branch of fetch first entry in "record": */
	Vm_Int i = stk_Get_Int( labels, u );
	if (IS_LABEL_LOC(i)) {

	    if (noVARS) {
		/* Remember new location of label: */
		Vm_Int loc    = VAL( stk_Get_Int( labels, u ) );
		stk_Set_Int( labels, u, LABEL_LOC( loc - 2 ) );
	    }

	    u += LABEL_LEN;
            continue;
        }

	{   /* Fetch components of record: */
	/*  Vm_Int op     = VAL( stk_Get_Int( labels, u+  OP_OFFSET ) ); */
	    Vm_Int len    = VAL( stk_Get_Int( labels, u+ LEN_OFFSET ) );
	    Vm_Int loc    = VAL( stk_Get_Int( labels, u+ LOC_OFFSET ) );
	/*  Vm_Int link   = VAL( stk_Get_Int( labels, u+LINK_OFFSET ) ); */

	    /* Slide back bytecodes from end of */
            /* last jump to end of this jump:   */
	    Vm_Int t;
	    for   (t = next;   t+noVARS < loc+len+1;   ++t) {
		stk_Set_Int( bytecodes, t, stk_Get_Int( bytecodes, t+lost ) );
		stk_Set_Int( linecodes, t, stk_Get_Int( linecodes, t+lost ) );
            }
	    next = t;

	    if (noVARS) {
		/* Remember new location of branch: */
	    	stk_Set_Int( labels, u+ LOC_OFFSET, LOC( loc - 2 ) );
	    }

	    if (len == 1)   ++lost;
	}
	u += BRANCH_LEN;
    }

    /* Copy remaining bytes after last jump: */
    {   Vm_Unt t;
	for (t = next;   t+lost < byte_off;   ++t) {
	    stk_Set_Int( bytecodes, t, stk_Get_Int( bytecodes, t+lost ) );
	    stk_Set_Int( linecodes, t, stk_Get_Int( linecodes, t+lost ) );
    }	}

    /* Reset 'bytecodes' stackpointer */
    /* to reflect diminished length:  */
    while (lost --> 0) {
	stk_Pull( bytecodes );
	stk_Pull( linecodes );
    }
}



 /***********************************************************************/
 /*-   patch_in_branch_opcodes_and_offsets				*/
 /***********************************************************************/


  /**********************************************************************/
  /*-  branch_opcode -- look up appropriate bytecode			*/
  /**********************************************************************/

static Vm_Unt
branch_opcode(
    Vm_Obj asm,
    Vm_Unt op,
    Vm_Unt bytes_needed    /* Currently, always 1- or 2-byte jump offsets. */
) {
    Vm_Int x    = (Vm_Int) bytes_needed;
    Vm_Int code = asm_Look_Up_Primcode( op );

    /* Find opcode with that offset size: */
    Vm_Int key = job_Code[code].key;
    Vm_Int i;
    if (!JOB_IS_BRANCH(op))   warn(asm,"bad branch opcode");
    for (i = 0;   ;   ++i) {
	if (job_Code[code+i].key != key) warn(asm,"no opcode");
	if (job_Code[code+i].x   == x  )   break;
    }
    code += i;
    return code;
}

  /**********************************************************************/
  /*-  patch_in_branch_opcodes_and_offsets				*/
  /**********************************************************************/

static void 
patch_in_branch_opcodes_and_offsets_etc(
    Vm_Obj asm
) {
    /* Over all branches: */
    Vm_Obj bytecodes = ASM_P(asm)->bytecodes;
    Vm_Obj labels    = ASM_P(asm)->labels;
    Vm_Unt label_off = OBJ_TO_UNT( stk_Length(labels) );
    Vm_Unt u         = 0;
    while (u < label_off) {

	/* Fetch first entry in "record", ignore labels: */
	Vm_Int i = stk_Get_Int( labels, u );
	if (IS_LABEL_LOC(i)) {  u += LABEL_LEN;   continue;  }

	/* Deposit correct opcode and offset for branch: */	
	{   /* Fetch components of record: */
	    Vm_Int op     = VAL( stk_Get_Int( labels, u+  OP_OFFSET ) );
	    Vm_Int len    = VAL( stk_Get_Int( labels, u+ LEN_OFFSET ) );
	    Vm_Int loc    = VAL( stk_Get_Int( labels, u+ LOC_OFFSET ) );
	    Vm_Int link   = VAL( stk_Get_Int( labels, u+LINK_OFFSET ) );
	    Vm_Unt code   = branch_opcode( asm, op, len );
	    Vm_Int dest   = VAL( stk_Get_Int( labels, link          ) );
	    Vm_Int offset = dest - (loc+len+1);
	    stk_Set_Int( bytecodes, loc, code );
	    switch (len) {
	    case 2: stk_Set_Int(bytecodes, loc+2, (offset>>8) & 0xFF); /*fall*/
	    case 1: stk_Set_Int(bytecodes, loc+1,  offset     & 0xFF);   break;
	    default:
		MUQ_FATAL ("bad offset len");
        }   }

	u += BRANCH_LEN;
    }

    /* Also patch in the number of local variables: */
    {   Vm_Unt local_vars = OBJ_TO_UNT( stk_Length(ASM_P(asm)->local_vars) );
	if (   local_vars) {
	    stk_Set_Int(bytecodes, 1, local_vars );
    }   }
}

 /***********************************************************************/
 /*-   branch_fixups -- Figure branch offset sizes and patch correctly. */
 /***********************************************************************/

static void
branch_fixups(
    Vm_Obj asm
) {
    /* NB:  Be nice to put an optimizer pass in here someday.	*/
    /* Candidate optimizations:					*/
    /* * Redirect jumps to unconditional jumps;			*/
    /* * Optimize "> if" (etc) sequences to single ops.		*/
    /* * Possibly also "dup if"? Need frequency data.		*/

    link_branches_to_labels(                 asm );
    minimize_branch_offsets(                 asm );
    compact_bytecodes_stack(                 asm );
    patch_in_branch_opcodes_and_offsets_etc( asm );
}



/************************************************************************/
/*-    compute_arity -- Figure number of arguments accepted & returned.	*/
/************************************************************************/

 /***********************************************************************/
 /*-   Quote								*/
 /***********************************************************************/

  /*
       "The problem with engineers is that they
	cheat in order to get results.

	The problem with mathematicians is that they
	work on toy problems in order to get results.

	The problem with program verifiers is that they
	cheat on toy problems in order to get results."

				-- Anonymous

	(Quoted in the excellent "Expert C Programming / Deep C Secrets")

   */

 /***********************************************************************/
 /*-   struct compute_arity_state_rec -- State during symbolic execution*/
 /***********************************************************************/

#ifndef ASM_MAX_FN
#define ASM_MAX_FN (10000)
#endif

/* 'sp' is our symbolic evaluation stack. */
/* Values on it are one of:               */
/* '|':  bottom of stack.                 */
/* '.':  generic scalar argument.         */
/* '#':  generic block  argument.         */
/* '[':  [ startOfBlock marker.        */

struct compute_arity_state_rec {
    Vm_Obj  asm;	/* Assembler.       Needed only for error reports.*/
    Vm_Obj  fn;		/* Function proper. Needed only for error reports.*/
    Vm_Obj  cfn;	/* Compiled function.				  */
    Vm_Uch* sp_0;	/* Logical bottom-of-stack.			  */
    Vm_Uch* sp;		/* *sp is top thing on stack.			  */
    Vm_Uch* sp_lim;	/* First location past top of stack.		  */
    Vm_Unt  pc_0;	/* First codebyte in fn,   byte offset from start.*/
    Vm_Unt  pc;		/* Current codebyte in fn, byte offset from start.*/
    Vm_Obj* arity;	/* Indexed by pc-pc_0, marks code already visited.*/
    Vm_Int  blk_get;	/* # blocks  accepted as input  parameters.	  */
    Vm_Int  blk_ret;	/* # blocks  returned as output parameters.	  */
    Vm_Int  arg_get;	/* # scalars accepted as input  parameters.	  */
    Vm_Int  arg_ret;	/* # scalars returned as output parameters.	  */
    Vm_Int  seen_q;	/* TRUE iff seen { -> ? } op.			  */
    struct compute_arity_state_rec * root;
    struct compute_arity_state_rec * prev;
};



 /***********************************************************************/
 /*-   merge_arities -- Return most specific of two arities.		*/
 /***********************************************************************/

static Vm_Obj
merge_arities(
    Vm_Obj arity0,
    Vm_Obj arity1,
    struct compute_arity_state_rec * r
) {
    /* If arities match, return it: */
    if (arity0 == arity1)   return arity0;

    /* If either arity is "unknown", return other: */
    if (arity0 == OBJ_FROM_INT(-1))   return arity1;
    if (arity1 == OBJ_FROM_INT(-1))   return arity0;

/* Buggo: This stuff needs to be carefully  */
/* thought through and tidied, it's been    */
/* quickly rehacked far too many times.     */
    /* If either arity is "{ -> @ }", return other: */
    if (FUN_ARITY_TYP_GET( arity0 ) == FUN_ARITY_TYP_EXIT) {
	return arity1;
    }
    if (FUN_ARITY_TYP_GET( arity1 ) == FUN_ARITY_TYP_EXIT) {
	return arity0;
    }

    /* If either arity is "{ -> ? }", return it: */
    if (FUN_ARITY_TYP_GET( arity0 ) == FUN_ARITY_TYP_Q) {
	return arity0;
    }
    if (FUN_ARITY_TYP_GET( arity1 ) == FUN_ARITY_TYP_Q) {
	return arity1;
    }

    /* If an operator with undefined arity has been   */
    /* seen, it is pretty pointless to complain about */
    /* (probably meaningless) arity mismatches:  At   */
    /* this point we are really just checking to see  */
    /* whether the function ever returns:             */
    if (r->root->seen_q)   return arity0; /* Picked arbitrarily. */

    /* Complain about mismatched arities: */
    if (FUN_ARITY_BLK_GET( arity0 )
    ||  FUN_ARITY_BLK_RET( arity0 )
    ||  FUN_ARITY_BLK_GET( arity1 )
    ||  FUN_ARITY_BLK_RET( arity1 )
    ){
	warn( r->asm,
	    "Fn arity conflict:   "
	    "[]%d %d -> []%d %d%s   vs   "
	    "[]%d %d -> []%d %d%s",

	    (int)FUN_ARITY_BLK_GET( arity0 ),
	    (int)FUN_ARITY_ARG_GET( arity0 ),
	    (int)FUN_ARITY_BLK_RET( arity0 ),
	    (int)FUN_ARITY_ARG_RET( arity0 ),
	    fun_TypeName( FUN_ARITY_TYP_GET( arity0 ) ),

	    (int)FUN_ARITY_BLK_GET( arity1 ),
	    (int)FUN_ARITY_ARG_GET( arity1 ),
	    (int)FUN_ARITY_BLK_RET( arity1 ),
	    (int)FUN_ARITY_ARG_RET( arity1 ),
	    fun_TypeName( FUN_ARITY_TYP_GET( arity1 ) )
	);

    } else {

	warn( r->asm,
	    "Fn arity conflict:   "
	    "%d -> %d%s   vs   "
	    "%d -> %d%s",

	    (int)FUN_ARITY_ARG_GET( arity0 ),
	    (int)FUN_ARITY_ARG_RET( arity0 ),
	    fun_TypeName( FUN_ARITY_TYP_GET( arity0 ) ),

	    (int)FUN_ARITY_ARG_GET( arity1 ),
	    (int)FUN_ARITY_ARG_RET( arity1 ),
	    fun_TypeName( FUN_ARITY_TYP_GET( arity1 ) )
	);
    }

    return arity0;
}



 /***********************************************************************/
 /*-   compute_arity_effects -- Update state given arity of operator.	*/
 /***********************************************************************/

static void
compute_arity_effects(
    struct compute_arity_state_rec * r,
    Vm_Obj                           arity
) {
    Vm_Unt tp    = FUN_ARITY_TYP_GET(arity);
    Vm_Unt bg    = FUN_ARITY_BLK_GET(arity);
    Vm_Unt br    = FUN_ARITY_BLK_RET(arity);
    Vm_Unt ag    = FUN_ARITY_ARG_GET(arity);
    Vm_Unt ar    = FUN_ARITY_ARG_RET(arity);

    /* Do symbolic evalution of this	   */
    /* instruction's effect on data stack: */
    while (ag --> 0) {
	if (*r->sp=='|') { ++r->arg_get; continue; }
	if (*r->sp=='.') { --r->sp     ; continue; }
	if (*r->sp=='#') {
	    warn(r->asm,"asm: can't do scalar operation on block arg!");
	}
	if (*r->sp=='[') {
	    warn(r->asm,"asm: can't do scalar operations on [ arg!");
	}
	warn(r->asm,"asm: compute_arity: internal err.");
    }
    while (bg --> 0) {
	switch (*r->sp) {
	case '|':  ++r->blk_get; continue;
	case '#':  --r->sp;      continue;
	case '.':
/* {Vm_Uch buf[4096];
Vm_Obj src = FUN_P(r->fn)->source;
*stg_Sprint(buf,buf+4096,src)='\0';
printf("src '%s'\n",buf);} */
	    printf ("asm: can't do block operation on scalar arg!\n");
	    break;
	case '[':
	    printf ("asm: can't do block operation on [ arg!");
	    break;
	default:
	    printf ("asm: compute_arity: internal err.");
	}
    }
    while (br --> 0) {
	if (r->sp == r->sp_lim) {
	    printf ("asm: compute_arity: stack overflow");
	}
	*++r->sp = '#';
    }
    while (ar --> 0) {
	if (r->sp == r->sp_lim) {
	    printf ("asm: compute_arity: stack overflow");
	}
	*++r->sp = '.';
    }

    /* Above computes the generic symbolic */
    /* evaluation of operator, check for   */
    /* specialCase extra stuff for [ &tc: */
    switch (tp) {

    case FUN_ARITY_TYP_START_BLOCK :
	if (r->sp == r->sp_lim) {
	    printf ("asm.c: compute_arity: stack overflow");
	}
	*++r->sp = '[';
	break;

    case FUN_ARITY_TYP_Q:
	/* Set flag so we know we've seen an op of	*/
	/* unknown arity, but continue analysis to	*/
	/* see if fn never returns, making it moot:	*/
	r->root->seen_q = TRUE;
	break;

    case FUN_ARITY_TYP_EAT_BLOCK:
    case FUN_ARITY_TYP_END_BLOCK:
	while (*r->sp != '[') {
	    switch (*r->sp) {
	    case '|':
		warn(r->asm,
		    "asm.c: '%c' matches no '['",
		    (tp==FUN_ARITY_TYP_END_BLOCK) ? '|' : ']'
		);
		break;
	    case '#':
		warn(r->asm,"asm.c: blocks may not be nested.");
		break;
	    case '.':
		--r->sp;
		break;
	    default:
		warn(r->asm,"asm.c:compute_bb_arity: internal err");
	    }
	}
	*r->sp = ((tp==FUN_ARITY_TYP_END_BLOCK) ? '#' : '.');
	break;
    }
}



 /***********************************************************************/
 /*-   compute_basic_block_arity -- Handling jumps recursively.		*/
 /***********************************************************************/

static Vm_Obj
compute_basic_block_arity(
    struct compute_arity_state_rec * rold
) {
    /* Duplicate current state+stack: */
    struct compute_arity_state_rec  r = *rold;
    r.prev = rold;
    {   Vm_Int n = (rold->sp+1) - rold->sp_0;
	Vm_Int i;
	r.sp_0 = rold->sp +1;
	r.sp   = rold->sp +n;
	if (r.sp+n >= r.sp_lim) {
	    warn(r.asm,"asm.c: procedure too large to compute arity!");
	}
	for (i = 0;   i < n;   ++i) {
	    r.sp_0[i] = rold->sp_0[i];
    }	}

    /* Search for path to RETURN statement: */
    for (;;) {

	Vm_Unt  op;
	Vm_Unt  code;
	Vm_Int  xtn = 0;
	Vm_Unt  pc  = r.pc;

	/* If we have already computed arity of current location, */
	/* return it.  This include returning -1 (unknown) if we  */
	/* have got back to a place on our current path:          */
	{   Vm_Int i = r.pc - r.pc_0;
	    if (r.arity[i] != OBJ_FROM_INT(-2)) {
		return r.arity[i];
	}   }

	/* Decode current instruction: */
	op = ((Vm_Uch*)(vm_Loc(r.cfn)))[ r.pc++ ];
	if (op < JOB_SLOW_PREFIX_BYTES) {

	    /* Slow opcode: */
	    Vm_Unt op2 = ((Vm_Uch*)(vm_Loc(r.cfn)))[ r.pc++ ];
	    code = lookup_slow_opcode( op, op2 );

	} else {

	    /* Fast opcode: */
	    code = lookup_fast_opcode( op );
	    {   Job_Code c = &job_Code[code];
		if (c->x) {
		    Vm_Uch* pc_before = &((Vm_Uch*)(vm_Loc(r.cfn)))[ r.pc ];
		    Vm_Uch* pc_after  = pc_before;
		    xtn = asm_scd_get_offset(&pc_after,c);
		    r.pc += (pc_after-pc_before);
	    }   }
	}

	{   /* Look up arity information on decoded instruction: */
	    Job_Code c     = &job_Code[code];
	    Vm_Obj   arity = c->arity;
	    Vm_Unt   tp    = FUN_ARITY_TYP_GET(arity);

	    #ifdef HANDY_WHEN_DEBUGGING
	    printf(
		"compute_basic_block_arity on '%s' arity %x (%s)\n",
		job_Code[code].name, (int)arity, fun_Type(tp)
	    );
	    #endif

	    /* An arity type of FUN_ARITY_TYP_CALLA means */
	    /* that the actual arity is stored in the     */
	    /* constant vector for the function:          */
	    if (tp == FUN_ARITY_TYP_CALL_METHOD) {
		warn(r.asm,
		    "CALL_METHOD not yet supported in arity computations."
		);
	    }
	    if (tp == FUN_ARITY_TYP_CALLA) {
		arity = CFN_P(r.cfn)->vec[ xtn ];
		tp    = FUN_ARITY_TYP_GET(arity);

		/* Need to account for called function */
		/* getting popped off stack:           */
		compute_arity_effects(
		    &r,
		    FUN_ARITY(0,0,1,0,FUN_ARITY_TYP_NORMAL)
		);
	    }

	    compute_arity_effects( &r, arity );

	    /* Above computes the generic symbolic */
	    /* evaluation of operator, check for   */
	    /* specialCase extra stuff for [ &tc: */
	    switch (tp) {

	    case FUN_ARITY_TYP_NORMAL:
		break;

	    case FUN_ARITY_TYP_EXIT  :
		/* Count values left on stack: */
		while (*r.sp=='.') { --r.sp; ++r.arg_ret; }
		while (*r.sp=='#') { --r.sp; ++r.blk_ret; }
		if (*r.sp=='[') warn(r.asm,"Unmatched [ in function.");
		if (*r.sp=='.') warn(r.asm,"May not return scalar arg under block.");
		if (*r.sp!='|') warn(r.asm,"asm: compute_arity: internal err.");

		/* Make sure we don't overflow any bitfields: */
		if (r.blk_get > FUN_ARITY_BLK_GET_MAX) {
		    warn(r.asm,"Function accepts too many blocks.");
		}
		if (r.blk_ret > FUN_ARITY_BLK_GET_MAX) {
		    warn(r.asm,"Function returns too many blocks.");
		}
		if (r.arg_get > FUN_ARITY_ARG_GET_MAX) {
		    warn(r.asm,"Function accepts too many values.");
		}
		if (r.arg_ret > FUN_ARITY_ARG_GET_MAX) {
		    warn(r.asm,"Function returns too many values.");
		}
		if (job_Code[code].key == JOB_OP_RETURN) {
		    return (
			FUN_ARITY(
			    r.blk_get,r.blk_ret,r.arg_get,r.arg_ret,
			    FUN_ARITY_TYP_NORMAL
			)
		    );
		}
		return FUN_ARITY(
		    r.blk_get,r.blk_ret,r.arg_get,r.arg_ret,
		    FUN_ARITY_TYP_EXIT
		);

	    case FUN_ARITY_TYP_BRANCH:
		if (job_Code[code].key == JOB_OP_BRA) {
		    /* It is an unconditional jump, */
		    /* we just follow it blindly:   */

		    /* Mark current instruction to  */
		    /* prevent infinite recursion:  */
		    Vm_Int i   = pc - r.pc_0;
		    r.arity[i] = OBJ_FROM_INT(-1);

		    /* Jump: */
		    r.pc += xtn;
		} else {
		    /* It is a conditional jump, must */
		    /* compute arities of both paths: */
		    Vm_Obj arity0;
		    Vm_Obj arity1;

		    /* Do first path, marking current  */
		    /* instruction to prevent infinite */
		    /* recursion:                      */
		    Vm_Int i   = pc - r.pc_0;
		    r.arity[i] = OBJ_FROM_INT(-1);
		    arity0     = compute_basic_block_arity( &r );
		    r.arity[i] = arity0;

		    /* Compute arity down second path: */
		    r.pc      += xtn;
		    arity1     = compute_basic_block_arity( &r );

		    return merge_arities( arity0, arity1, &r );
		}
		break;

	    case FUN_ARITY_TYP_CALLI :
		{   Vm_Obj tocall = CFN_P(r.cfn)->vec[ xtn ];
		    if (OBJ_IS_SYMBOL(tocall)) {
			tocall = job_Symbol_Function(tocall);
		    }
		    if (OBJ_IS_OBJ(tocall)
		    &&  OBJ_IS_CLASS_FN(tocall)
		    ){
			tocall = FUN_P(tocall)->executable;
		    }
		    if (!OBJ_IS_CFN(tocall)) {
			Vm_Uch buf[512];
			job_Sprint_Vm_Obj(buf,buf+512,tocall,1);
			warn(
			    r.asm,
			    "CALLI arg #%d == %s isn't a compiledFunction",
			    (int)xtn,
			    buf
			);
		    }
{Vm_Obj toc = tocall;
		    tocall = CFN_P(tocall)->src;
		    if (!OBJ_IS_OBJ(tocall)
		    ||  !OBJ_IS_CLASS_FN(tocall)
		    ){
Vm_Uch buf[1024];
Vm_Int i=0;
printf("toc    x=%" VM_X "\n",toc);
printf("tocall x=%" VM_X "\n",tocall);
i=job_Sprint_Vm_Obj(buf,buf+1024,toc,1);
job_Sprint_Vm_Obj(buf+i,buf+1024,tocall,1);
printf("sprintfs: %s\n",buf);
			warn(r.asm,"CALLI src isn't a function?!");
		    }
}
		    {   Vm_Obj  arity = FUN_P(tocall)->arity;
			Vm_Unt  tp    = FUN_ARITY_TYP_GET(arity);

			if (tp == FUN_ARITY_TYP_EXIT) {
			    return arity;
			}
			if (tp == FUN_ARITY_TYP_Q) {
			    r.root->seen_q = TRUE;
			    break;
		        }
			if (tp != FUN_ARITY_TYP_NORMAL
			&&  tp != FUN_ARITY_TYP_START_BLOCK
			&&  tp != FUN_ARITY_TYP_END_BLOCK
			&&  tp != FUN_ARITY_TYP_EAT_BLOCK
			){
/*{ Vm_Unt tp    = FUN_ARITY_TYP_GET(arity);
    Vm_Unt bg    = FUN_ARITY_BLK_GET(arity);
    Vm_Unt br    = FUN_ARITY_BLK_RET(arity);
    Vm_Unt ag    = FUN_ARITY_ARG_GET(arity);
    Vm_Unt ar    = FUN_ARITY_ARG_RET(arity);
printf("CALLI %" VM_X " arity: %d,%d,%d,%d,%d\n",tocall,(int)bg,(int)br,(int)ag,(int)ar,(int)tp);}*/
			    warn(r.asm,"internal err: weird CALLI arity");
			}
			compute_arity_effects( &r, arity );
		}   }
		break;

	    case FUN_ARITY_TYP_END_BLOCK:
	    case FUN_ARITY_TYP_EAT_BLOCK:
	    case FUN_ARITY_TYP_Q:
	    case FUN_ARITY_TYP_START_BLOCK :
		break;

	    case FUN_ARITY_TYP_OTHER :

		switch (job_Code[code].key) {
		default:
		    warn(r.asm,"asm.c:compute_basic_block_arity: internal err");
		}
		break;
	    default:
		warn(r.asm,"asm.c:compute_arity: internal err.");
	    }	    
	}
    }
}


 /***********************************************************************/
 /*-   compute_arity -- Figure number of arguments accepted & returned.	*/
 /***********************************************************************/

static void
compute_arity(
    Vm_Obj asm,	/* Used only for error message info.	*/
    Vm_Obj fn,
    Vm_Obj declared_arity,
    Vm_Int force
) {
    /* Here we need to do a (simple!) symbolic	*/
    /* execution of the function to deduce the	*/
    /* number of arguments it accepts and	*/
    /* returns.					*/
    Vm_Uch stk[ ASM_MAX_FN ];
    Vm_Obj aty[ ASM_MAX_FN ];
    Vm_Obj cfn = FUN_P(fn)->executable;
    Vm_Int n = cfn_Bytes_Of_Code(cfn);
    Vm_Obj arity;

    struct compute_arity_state_rec r;

    #ifdef VERBOSE_DEBUGGING
    printf( "asm.c: starting analysis of Fn %" VM_X " (arity %" VM_X" decl %" VM_X "), with %d bytes of code\n",fn,FUN_P(fn)->arity,declared_arity,n);
    {   Vm_Uch buf[32000];
        Vm_Obj src = FUN_P(fn)->source;
        *stg_Sprint(buf,buf+32000,src)='\0';
        printf("src: '%s'\n",buf);
    }
    #endif

    /* If arity was declared as { -> ? }  */
    /* then just skip arity checking:     */
    if (FUN_ARITY_TYP_GET( declared_arity ) == FUN_ARITY_TYP_Q) {
	FUN_P(fn)->arity = declared_arity;
	vm_Dirty(fn);
	return;
    }

    /* If arity was declared as { -> @ }  */
    /* then just skip arity checking.     */
/* (It seems sensible to check this, but */
/* : s { -> @ }   14 -> a  [ "err" | ]throw-error ; */
/* : r { -> @ } s 13 -> a ; */
/* is producing: */
/* **** Sorry: Fn type conflict:   NORMAL vs EXIT */
/* if we do, and I can't be bothered to fix it just now.) */
    if (FUN_ARITY_TYP_GET( declared_arity ) == FUN_ARITY_TYP_EXIT) {
	FUN_P(fn)->arity = declared_arity;
	vm_Dirty(fn);
	return;
    }


    /* If arity was declared as { ... -> ... ! }  */
    /* then just skip arity checking, but record  */
    /* it as having given (NORMAL) arity:         */
    if (force) {
	FUN_P(fn)->arity = declared_arity;
	vm_Dirty(fn);
	return;
    }

    if (n > ASM_MAX_FN) {
	warn(asm,"asm.c: Function has too many bytes of code for me!");
    }
    {   Vm_Int i;
	for (i = n;   i --> 0; )   aty[i] = OBJ_FROM_INT(-2);
    }

    stk[0]    = '|';

    r.fn	= fn;
    r.cfn	= cfn;
    r.sp_0	= &stk[            0 ];
    r.sp	= &stk[            0 ];
    r.sp_lim	= &stk[ ASM_MAX_FN-1 ];
    r.arity	= aty;
    r.blk_get	= 0;
    r.blk_ret	= 0;
    r.arg_get	= 0;
    r.arg_ret	= 0;
    r.seen_q	= FALSE;
    r.root	= &r;
    r.prev	= NULL;
    r.asm	= asm;
    {   Cfn_P p = CFN_P(cfn);
        r.pc_0	= (
	    (Vm_Uch*) &p->vec[ CFN_CONSTS(p->bitbag) ] -
	    (Vm_Uch*)  p
        );
    }
    r.pc	= r.pc_0;

    arity = compute_basic_block_arity( &r );

    #ifdef VERBOSE_DEBUGGING
    {   int tp    = (int)FUN_ARITY_TYP_GET(arity);
	int bg    = (int)FUN_ARITY_BLK_GET(arity);
	int br    = (int)FUN_ARITY_BLK_RET(arity);
	int ag    = (int)FUN_ARITY_ARG_GET(arity);
	int ar    = (int)FUN_ARITY_ARG_RET(arity);
        printf("computed fn %" VM_X " arity: %d,%d,%d,%d,%d\n",fn,bg,br,ag,ar,tp);
    }
    #endif

    /* I think we can have arity=-1 here  */
    /* only if the fn never returns:      */
    if (arity == OBJ_FROM_INT(-1)) {
        if (FUN_ARITY_TYP_GET( declared_arity ) != FUN_ARITY_TYP_EXIT) {
	    warn(asm,"Fn is { -> @ } but not so declared.");
	}
	FUN_P(fn)->arity = FUN_ARITY(0,0,0,0,FUN_ARITY_TYP_EXIT);
	vm_Dirty(fn);
	return;
    }

    /* For now, we'll permit fns to be { -> ? } */
    /* (usually due to using a 'call') only if  */
    /* explicitly declared { -> ? }:		*/
    if (r.seen_q
    && FUN_ARITY_TYP_GET( declared_arity ) != FUN_ARITY_TYP_Q) {
	warn(asm,"Fn is { -> ? } but not so declared. (Use call{...} ?)");
    }

    /* Complain about mismatches in      */
    /* declared vs actual function type: */
    if (declared_arity != OBJ_FROM_INT(-1)
    &&  FUN_ARITY_TYP_GET( arity ) != FUN_ARITY_TYP_GET( declared_arity )
    ){
	warn(asm,
	    "Fn type conflict:   %s vs %s",
	    fun_Type( FUN_ARITY_TYP_GET(          arity ) ),
	    fun_Type( FUN_ARITY_TYP_GET( declared_arity ) )
	);
    }

    /* Reconcile actual arity with declared arity: */
    arity = merge_arities( arity, declared_arity, &r );

    #ifdef VERBOSE_DEBUGGING
    {   int tp    = (int)FUN_ARITY_TYP_GET(arity);
	int bg    = (int)FUN_ARITY_BLK_GET(arity);
	int br    = (int)FUN_ARITY_BLK_RET(arity);
	int ag    = (int)FUN_ARITY_ARG_GET(arity);
	int ar    = (int)FUN_ARITY_ARG_RET(arity);
        printf("merged fn %" VM_X " arity: %d,%d,%d,%d,%d\n",fn,bg,br,ag,ar,tp);
    }
    #endif

    /* Complain if arity was neither declared nor deducible: */
    if (arity == OBJ_FROM_INT(-1)) {
	#ifndef VERBOSE_DEBUGGING
        {   Vm_Uch buf[4096];
	    Vm_Obj src = FUN_P(fn)->source;
	    *stg_Sprint(buf,buf+4096,src)='\0';
	    printf("src '%s'\n",buf);
	}
	#endif
	printf( "asm.c: Fn %" VM_X " arity neither declared nor deducible!\n",fn);
    }

    /* Save function arity for further use: */
    FUN_P(fn)->arity = arity;
    vm_Dirty(fn);
}



/************************************************************************/
/*-    constant_note -- Enter const in consts vector, return offset	*/
/************************************************************************/

static Vm_Unt
constant_note(
    Vm_Obj asm,
    Vm_Obj  c
) {
    /* We have a constant:  Enter it in const stack	*/
    /* unless it is already there, either way noting	*/
    /* location in const stack:				*/
    Vm_Obj  constants = ASM_P(asm)->constants;
    Vm_Int  loc_const;
    if (!stk_Get_Key_P( &loc_const, constants, c )) {
	loc_const = OBJ_TO_UNT( stk_Length( constants ) );
	stk_Push( constants, c );
    }
    return loc_const;
}



/************************************************************************/
/*-    deposit_offset                                                 	*/
/************************************************************************/

static void
deposit_offset(
    /* Assembler to receive bytes: */
    Vm_Obj asm,

    Vm_Int bytes_needed,
    Vm_Int offset
) {
    if (bytes_needed == 0)   MUQ_FATAL ("deposit_offset");
    if (bytes_needed == 1) {
        push_byte( asm, offset );
    }
    if (bytes_needed == 2) {
        push_byte( asm, (offset   ) & 0xFF );
        push_byte( asm, (offset>>8) & 0xFF );
    }
}



/************************************************************************/
/*-    offset_needed -- Update estimate of needed offset field size.	*/
/************************************************************************/

static Vm_Int
offset_needed(
    Vm_Int bytes_needed,
    Vm_Int x_signed,
    Vm_Int offset
) {
    if (bytes_needed == 0)                       bytes_needed = 1;
    if (bytes_needed == 1) {
	if (x_signed) {
	    if (offset < -128 || offset > 127)   bytes_needed = 2;
	} else {
	    if (offset > 255)                    bytes_needed = 2;
	}
    }
    return bytes_needed;
}



/************************************************************************/
/*-    lookup_ascii_opcode -- Find given bytecode in job_Code (asm)	*/
/************************************************************************/

static Vm_Int
lookup_ascii_opcode(
    Vm_Uch* op
) { 
    Vm_Int  i;
    for    (i = 0;   i < JOB_CODE_MAX;   ++i) { /*Needs to be ascending order*/
	if (STRCMP( op, == ,job_Code[i].name ))   return i;
    }
    MUQ_FATAL ("Can't find opcode '%s'!", op );
    return 0; /* Pacify gcc. */
}  



/************************************************************************/
/*-    lookup_fast_opcode -- Find given bytecode in job_Code (disassem)	*/
/************************************************************************/

static Vm_Int
lookup_fast_opcode(
    Vm_Int op
) { 
    Vm_Int  i;
    for    (i = JOB_CODE_MAX;   i --> 0;  ) {
	if (op == job_Code[ i ].op)   return i;
    }
    MUQ_FATAL ("No op x=%" VM_X " in job_Code[]",op);
    return 0; /* Pacify gcc. */
}  



/************************************************************************/
/*-    lookup_slow_opcode -- Find given bytecode in job_Code (disassem)	*/
/************************************************************************/

static Vm_Int
lookup_slow_opcode(
    Vm_Int po,	/* Prefix opcode. */
    Vm_Int op	/* Main   opcode. */
) { 
    Vm_Int  i;
    op |= JOB_2_BYTES;
    for    (i = JOB_CODE_MAX;   i --> 0;  ) {
	if (op == job_Code[ i ].op2
	&&  po == job_Code[ i ].op
	){
	    return i;
    }   }
    MUQ_FATAL ("Bad opcode!?");
    return 0; /* Pacify gcc. */
}  



/************************************************************************/
/*-    printstate -- debug hack to show state of labels/bytecodes	*/
/************************************************************************/

#ifdef SOMETIMES_USEFUL_WHEN_DEBUGGING


/************************************************************************/
/*-    printlabels -- print contents of 'labels' stack			*/
/************************************************************************/

static void
printlabels(
    Vm_Obj asm
) {
    /* Over all branches: */
    Vm_Obj labels    = ASM_P(asm)->labels;
    Vm_Unt label_off = OBJ_TO_UNT( stk_Length(labels) );
    int    u         = 0;
    while (u < label_off) {

	/* Switch on type of first entry in "record": */
	Vm_Int i = stk_Get_Int( labels, u );
	if (IS_LABEL_LOC(i)) {
	    int loc = (int)VAL( stk_Get_Int( labels, u   ) );
	    int id  = (int)VAL( stk_Get_Int( labels, u+1 ) );
	    printf("%2d LABEL: loc %2d id %2d\n",u,loc,id);
	    u += LABEL_LEN;
            continue;
        }


	{   /* Print out a branch: */
	    int op   = (int)VAL( stk_Get_Int( labels, u+  OP_OFFSET ) );
	    int len  = (int)VAL( stk_Get_Int( labels, u+ LEN_OFFSET ) );
	    int loc  = (int)VAL( stk_Get_Int( labels, u+ LOC_OFFSET ) );
	    int link = (int)VAL( stk_Get_Int( labels, u+LINK_OFFSET ) );
	    printf("%2d BRANCH: op %2d len %2d loc %2d link %2d\n",u,op,len,loc,link);
        }

	/* Step to next record: */
	u += BRANCH_LEN;
    }
}

	

static void
printstate(
    Vm_Uch*title,
    Vm_Obj asm
) {
    Vm_Obj labels    = ASM_P(asm)->labels;
    Vm_Obj bytecodes = ASM_P(asm)->bytecodes;
    printf("\n\n\n>>> %s <<<\n",title);
    printlabels(asm);
#ifdef SOON
    stk_Print(stdout,"bytecodes",bytecodes);
#endif
}

#endif




/************************************************************************/
/*-    push_byte -- Push byte on 'bytecodes'.				*/
/************************************************************************/

static void
push_byte(
    Vm_Obj asm,
    Vm_Int byt
) {
    /* Push given byte on given stack: */
    stk_Push( ASM_P(asm)->bytecodes, OBJ_FROM_INT(byt) );

    /* Push corresponding source line number: */
    stk_Push( ASM_P(asm)->linecodes, ASM_P(asm)->line_in_fn );
}



/************************************************************************/
/*-    warn -- Issue error message.					*/
/************************************************************************/

#ifndef ASM_MAX_WARN
#define ASM_MAX_WARN 2048
#endif

static void
warn(
    Vm_Obj  asm,
    Vm_Uch *format,
    ...
) {
    va_list args;
    Vm_Uch buf1[ASM_MAX_WARN];
    Vm_Uch buf2[ASM_MAX_WARN];
    buf1[0] = '\0';

    /* We first deposit whatever identifying information */
    /* we have about the source code location of the     */
    /* error, then we append the error message proper:   */

    {   Asm_P a = ASM_P(asm);

	if (a->file_name != OBJ_FROM_BYT0
	&&  stg_Is_Stg( a->file_name )
	){
	    Vm_Int len = stg_Get_Bytes(buf2,ASM_MAX_WARN,a->file_name,0);
	    buf2[  len ] = '\0';
	    strcat( buf1, "File " );
	    strcat( buf1, buf2   );
	    strcat( buf1, ": "   );
	    a = ASM_P(asm);
	}

	if (OBJ_IS_INT(a->line_in_fn)
	&&  OBJ_TO_INT(a->line_in_fn) > 0
	){
	    int line = (int)OBJ_TO_INT(a->line_in_fn);
	    if (OBJ_IS_INT(a->fn_line)
	    &&  OBJ_TO_INT(a->fn_line) > 0
	    ){
		line += (int)OBJ_TO_INT(a->fn_line);
	    }
	    sprintf( buf2, "Line %d: ", line+1 );
	    strcat( buf1, buf2   );
	}

	if (a->fn_name != OBJ_FROM_BYT0
	&&  stg_Is_Stg( a->fn_name )
	){
	    Vm_Int len = stg_Get_Bytes(buf2,ASM_MAX_WARN,a->fn_name,0);
	    buf2[  len ] = '\0';
	    strcat( buf1, "Fn " );
	    strcat( buf1, buf2   );
	    strcat( buf1, ": "   );
	    a = ASM_P(asm);
	}

    }

    va_start(args, format);
    vsprintf(buf2, format, args);
    va_end(args);

    strcat( buf1, buf2 );

    job_Error( buf1 );
}


/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    invariants -- Sanity check on asm.				*/
/************************************************************************/

#if MUQ_DEBUG

static int
invariants(
    FILE* f,
    char* t,
    Vm_Obj fn
) {
/*buggo*/
    return 0;
}

#endif



/************************************************************************/
/*-    for_new -- Initialize new asm.					*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
/* buggo -- turning garbage collection on would break   */
/* this badly. Prolly need to look a lot of places for  */
/* suchstuff.  Best idea is probably to push them on    */
/* the datastack temporarily, but we need to make sure  */
/* that we always have a valid data stack when called.  */
/* There's also the issue of garbage collection hitting */
/* a vector we haven't fully initialized yet.		*/
    Vm_Obj constants   = obj_Alloc( OBJ_CLASS_A_STK, 0 );
    Vm_Obj bytecodes   = obj_Alloc( OBJ_CLASS_A_STK, 0 );
    Vm_Obj labels      = obj_Alloc( OBJ_CLASS_A_STK, 0 );
    Vm_Obj linecodes   = obj_Alloc( OBJ_CLASS_A_STK, 0 );
    Vm_Obj local_vars  = obj_Alloc( OBJ_CLASS_A_STK, 0 );

    {   Asm_P a = ASM_P( o );

	a->constants       = constants;
	a->bytecodes       = bytecodes;
	a->labels          = labels   ;
	a->linecodes       = linecodes;
        a->local_vars      = local_vars;

	a->file_name       = OBJ_FROM_BYT0;
	a->fn_name         = OBJ_FROM_BYT0;
	a->fn_line         = OBJ_FROM_INT(0);
	a->line_in_fn      = OBJ_FROM_INT(0);
        a->next_label      = OBJ_FROM_INT(0);
        a->save_debug_info = OBJ_TRUE;

	{   int i;
	    for (i = ASM_RESERVED_SLOTS;  i --> 0; ) a->reserved_slot[i] = OBJ_FROM_INT(0);
	}

	vm_Dirty( o );
    }

    asm_Reset( o );
}



/************************************************************************/
/*-    sizeof_asm -- Return size of generic asm.			*/
/************************************************************************/

static Vm_Unt
sizeof_asm(
    Vm_Unt size
) {
    return sizeof( Asm_A_Header );
}



/************************************************************************/
/*-    --- Static propfns --						*/
/************************************************************************/


/************************************************************************/
/*-    never_in_line -- Return neverInline? flag.			*/
/************************************************************************/

static Vm_Obj
never_in_line(
    Vm_Obj o
) {
    return ASM_P(o)->never_in_line;
}

/************************************************************************/
/*-    please_in_line -- Return pleaseInline? flag.			*/
/************************************************************************/

static Vm_Obj
please_in_line(
    Vm_Obj o
) {
    return ASM_P(o)->please_in_line;
}



/************************************************************************/
/*-    never_in_line_set -- Set 'neverInline?' flag.			*/
/************************************************************************/

static Vm_Obj
never_in_line_set(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL	/* Can't currently use a switch() */
    ||  v == OBJ_TRUE	/* due to these not being consts. */
    ){
        ASM_P(o)->never_in_line = v;
        vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    please_in_line_set -- Set 'pleaseInline?' flag.			*/
/************************************************************************/

static Vm_Obj
please_in_line_set(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL	/* Can't currently use a switch() */
    ||  v == OBJ_TRUE	/* due to these not being consts. */
    ){
        ASM_P(o)->please_in_line = v;
        vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    bytescodes_len -- Return length of bytecodes stack		*/
/************************************************************************/

static Vm_Obj
bytecodes_len(
    Vm_Obj o
) {
    /* We subtract two off because asm_Reset always   */
    /* deposits a two-byte VARS instruction, and the  */
    /* main use of asm%s/bytecodes is to check it for */
    /* nonzero to determine whether any user code     */
    /* has been deposited:                            */
    return OBJ_FROM_INT( OBJ_TO_INT(stk_Length(ASM_P(o)->bytecodes)) -2 );
}



/************************************************************************/
/*-    compile_time -- Return compileTime flag.			*/
/************************************************************************/

static Vm_Obj
compile_time(
    Vm_Obj o
) {
    return ASM_P(o)->compile_time;
}



/************************************************************************/
/*-    compile_time_set -- Set 'compileTime' flag.			*/
/************************************************************************/

static Vm_Obj
compile_time_set(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v != OBJ_NIL)   v = OBJ_TRUE;
    ASM_P(o)->compile_time = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    file_name -- Return current source line number.			*/
/************************************************************************/

static Vm_Obj
file_name(
    Vm_Obj o
) {
    return ASM_P(o)->file_name;
}



/************************************************************************/
/*-    fn_line -- Return line number on which function began.		*/
/************************************************************************/

static Vm_Obj
fn_line(
    Vm_Obj o
) {
    return ASM_P(o)->fn_line;
}



/************************************************************************/
/*-    fn_name -- Return current function name.				*/
/************************************************************************/

static Vm_Obj
fn_name(
    Vm_Obj o
) {
    return ASM_P(o)->fn_name;
}



/************************************************************************/
/*-    line_in_fn -- Return current source line number.		*/
/************************************************************************/

static Vm_Obj
line_in_fn(
    Vm_Obj o
) {
    return ASM_P(o)->line_in_fn;
}



/************************************************************************/
/*-    flavor -- Return flavor flag.					*/
/************************************************************************/

static Vm_Obj
flavor(
    Vm_Obj o
) {
    return ASM_P(o)->flavor;
}



/************************************************************************/
/*-    flavor_set -- Set 'flavor' flag.					*/
/************************************************************************/

static Vm_Obj
flavor_set(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL
    ||  v == job_Kw_Thunk
    ||  v == job_Kw_Promise
    ||  v == job_Kw_Mos_Generic
    ){
        ASM_P(o)->flavor = v;
        vm_Dirty(o);
    }
    vm_Dirty(o);
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    next_label -- Return number of labels allocated so far.		*/
/************************************************************************/

static Vm_Obj
next_label(
    Vm_Obj o
) {
    return ASM_P(o)->next_label;
}



/************************************************************************/
/*-    next_label_set -- Ignore attempt to set # global vars allocated.	*/
/************************************************************************/

static Vm_Obj
next_label_set(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    save_debug_info -- Non-nil to save debug info on compiled fns.	*/
/************************************************************************/

static Vm_Obj
save_debug_info(
    Vm_Obj o
) {
    return ASM_P(o)->save_debug_info;
}



/************************************************************************/
/*-    save_debug_info_set -- 						*/
/************************************************************************/

static Vm_Obj
save_debug_info_set(
    Vm_Obj o,
    Vm_Obj v
) {
    ASM_P(o)->save_debug_info = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    vars -- Return number of local vars allocated so far.		*/
/************************************************************************/

static Vm_Obj
vars(
    Vm_Obj o
) {
    return stk_Length(ASM_P(o)->local_vars);
}



/************************************************************************/
/*-    file_name_set	-- Set current source file name.		*/
/************************************************************************/

static Vm_Obj
file_name_set(
    Vm_Obj o,
    Vm_Obj v
) {
    ASM_P(o)->file_name = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    fn_line_set	-- Set source line number on which fn began.	*/
/************************************************************************/

static Vm_Obj
fn_line_set(
    Vm_Obj o,
    Vm_Obj v
) {
    if (!OBJ_IS_INT(v)) MUQ_WARN("asm$s.fnLine must be an integer");
    ASM_P(o)->fn_line = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    fn_name_set	-- Set current source function name.		*/
/************************************************************************/

static Vm_Obj
fn_name_set(
    Vm_Obj o,
    Vm_Obj v
) {
    ASM_P(o)->fn_name = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    line_in_fn -- Set current source line number wrt start of fn.	*/
/************************************************************************/

static Vm_Obj
line_in_fn_set(
    Vm_Obj o,
    Vm_Obj v
) {
    if (!OBJ_IS_INT(v)) MUQ_WARN("asm$s.lineInFn must be an integer");

    ASM_P(o)->line_in_fn = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    vars_set	-- Ignore attempt to set # local vars allocated.	*/
/************************************************************************/

static Vm_Obj
vars_set(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}


/************************************************************************/
/*-     asm_set_never							*/
/************************************************************************/

static Vm_Obj
asm_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
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

