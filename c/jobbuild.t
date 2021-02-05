@example  @c
/* To do: reserve one of the slow opcode tables for */
/* fns which don't want their pc incremented --     */
/* SLEEP, PAUSE, END_JOB...  Then we can remove the */
/* gross decrement hacks from their job.c fns.      */
/* ROOT-KILL-JOB is currently a special case: This  */
/* could be fixed by having it refuse to let a      */
/* job kill itself that way, which would be reasonable.*/

/*--   jobbuild.c -- Build 'jobprims.c' for job.c			*/
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
/* Created:      93Feb04						*/
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
/* Talent finds the right answer;					*/
/* Genius finds the right qestion.					*/
/************************************************************************/

/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/************************************************************************/
/*
Code and tables for job.c are sufficiently large that it
makes more sense to write code to generate them than to
create and maintain them manually.
 ************************************************************************/

/************************************************************************/
/*-    Loop stack overview						*/
/* This overview has moved to the "Loop Stacks" node in the manual.	*/
/************************************************************************/

/************************************************************************/
/*-    #includes							*/
/************************************************************************/


/*********************************************/
/* We don't #include All.h because we don't  */
/* want to include job.h because it includes */
/* jobprims.h, and including our own output  */
/* can lead to odd problems.		     */
/*********************************************/

#include "Config.h"
#include "Hax.h"	/* Portability stuff working with above.	*/
#include "Need.h"	/* Portability stuff working with above.	*/

#include "Site-config.h"
#include "Defaults.h"

#include "jobpass.h"
#include "obj2.h"
#include "fun2.h"

/************************************************************************/
/*-    Prim specifications						*/
/************************************************************************/

/* This section contains the major input specs	*/
/* which jobbuild.c works from.			*/

 /***********************************************************************/
 /*-   #defines								*/
 /***********************************************************************/

 /***********************************************************************/
 /*-   Define JOB_ATP_MAX (Arithmetic TyPe MAX) as:			*/
 /*   1 to compile support for integer arithemtic only,			*/
 /*   2 to compile support for float   arithemtic also,			*/
 /*   3 to compile support for double as well as above two.		*/
 /* Selecting option 3 generates nearly three times as many		*/
 /* binary arithmetic operator primitive functions:			*/
 /***********************************************************************/
 #define JOB_ATP_MAX (3)

 /***********************************************************************/
 /*-   Define JOB_DST_MAX as:						*/
 /*   1 if you prefer a smaller interpreter,				*/
 /*   3 if you want the fastest possible interpreter.			*/
 /* If it is 3, binary operations can store directly to			*/
 /* local and global variables, if it is 1, binary operations		*/
 /* always leave result on stack, and storing to a variable		*/
 /* always requires a second instruction.				*/
 /* Selecting option 3 generates three times as many			*/
 /* binary arithmetic operator primitive functions:			*/
 /***********************************************************************/
 #define JOB_DST_MAX (1)

 /***********************************************************************/
 /*-   Define JOB_OPCODE_BITS as:					*/
 /*   6 for a  32Kbyte job_Fast_Table[],				*/
 /*   7 for a  64Kbyte job_Fast_Table[],				*/
 /*   8 for a 128Kbyte job_Fast_Table[].				*/
 /* A value of 6 gives you  64 primary opcodes.				*/
 /* A value of 7 gives you 128 primary opcodes.				*/
 /* A value of 8 gives you 256 primary opcodes.				*/
 /* Assigning a primitive directly to a primary opcode			*/
 /* saves you a few clock cycles each time it executes,			*/
 /* of course, but I'm not sure all the world is ready			*/
 /* 128Kbyte dispatch tables, hence the choices:			*/
 /***********************************************************************/
 #define JOB_OPCODE_BITS (7)

 /***********************************************************************/
 /*-   Mask used to detect when current timeslice is done,		*/
 /* meaning it's time to think about stack    				*/
 /* overflow checking, multitasking etc:				*/
 /***********************************************************************/
 #define JOB_OPS_COUNT_MASK (1 << JOB_OPCODE_BITS)
 #define JOB_PRIMARY_PRIMS_AVAILABLE JOB_OPS_COUNT_MASK

 /***********************************************************************/
 /*-   Size of dispatch table.  This is determined by			*/
 /* our 6-8 opcode bits + 3 bits of type for each   			*/
 /* of two arguments plus 1 bit of timeslice check. 			*/
 /* That works out to 8->32K 4-byte pointers, or			*/
 /* 32->128K of dispatch table:						*/
 /***********************************************************************/
 #define JOB_FAST_TABLE_MAX (1 << (JOB_OPCODE_BITS+JOB_TYPE_BITS+JOB_TYPE_BITS+1))

/* Prim table size is completely arbitrary.	*/
/* Prolly should expand it as needed, really:	*/
#define JOB_PRIM_TABLE_MAX (2048)

/* Slow table size is just set by size of byte	*/
/* of expansion code that we use to index it:	*/
#define JOB_SLOW_TABLE_MAX (0x100)

/* Number of slow prefix bytes supported.	*/
/* Changing this won't work without hand-	*/
/* hacking various things, at present:		*/
#define JOB_SLOW_PREFIX_BYTES (16)

/* We support sixteen plain slow prefix bytes:	*/
#define JOB_SECONDARY_PRIMS_AVAILABLE (JOB_SLOW_PREFIX_BYTES*JOB_SLOW_TABLE_MAX)

/* Bitsize of our loc  fields.  Always 3 for now:  */
#define JOB_LOC_BITS	(3)

/* Bitsize of index    fields.  Always 3 for now:  */
#define JOB_INDEX_BITS	(3)

/* Bitsize of our type fields.  Always 3 for now:  */
#define JOB_TYPE_BITS	(3)

#define JOB_CODE_MAX      JOB_FAST_TABLE_MAX /* A decently large # */

/* Define a flag signalling that op2 field is valid: */
#define JOB_2_BYTES	(0x1000)


 /***********************************************************************/
 /*-   cell_types -- Definition of our basic Vm_Obj -> type0/1 types.	*/
 /* Couldn't manage to fit it into 2 bits:				*/
 /* t == thunk								*/
 /* u == underflow							*/
 /* i == int								*/
 /* r == real (float)							*/
 /* s == symbol								*/
 /* c == cons cell							*/
 /* o == other/object							*/
 /* NB: fast_prims_write() depends on 'u' being				*/
 /* the first char in cell_types:					*/
 /***********************************************************************/
 static char* cell_types = "utirsco";

 /***********************************************************************/
 /*-   loc_types -- Operand locations supported by interpreter.		*/
 /* Type 's' is hardwired into jobbuild.c, which			*/
 /* generates correct code to pop up to two stack			*/
 /* arguments and push up to one stack result.	 			*/
 /* The other types are assumed to be pointers	 			*/
 /* in job_RunState:				 			*/
 /*   '_': Missing operand...			 			*/
 /*   's': Stack operand...			 			*/
 /*   'p': pc operand (jump)...			 			*/
 /*   'v': Local variable operand...		 			*/
 /*   'V': Global variable operand...		 			*/
 /*   'k': Local constant operand...		 			*/
 /* job_Deposit_Instruction depends on prefix being _sp:		*/
 /***********************************************************************/
 static char* loc_types = "_spvVk";

 /***********************************************************************/
 /*-   job_Code[]/Code -- Table summarizing the prims we've built.	*/
 /***********************************************************************/

  /**********************************************************************/
  /*-  job_Code[] Overview						*/
  /**********************************************************************/

/*

The primary purpose of job_Code[] is to record the information needed
by job_Deposit_Instruction to generate valid bytecoded instructions.

The essential mapping is from 'key' (JOB_OP_SOMETHING) to 'op', the
bytecode to deposit for that operation.  If this is a slow code, 'op2'
will be deposited as a second bytecode.  If an offset is needed
(jumps, constant/variable load/store), 'x' tells us how many bytes of
offset to deposit following the primary bytecode.  The 'name' field
can be used for disassembling compiled bytecodes; The other values are
mostly useful internally in jobbuild.c but are included on the
offchance they will be at some point interesting to an optimizing
bytecode assembler or compiler.

We accumulate job_Code[] entries linearly while we are generating
prims, then sort by keyfield and write out a sorted table
job_Fast_Code[] for runtime lookup.


*/


#undef A
#define A(a,b,c,d,e) FUN_ARITY(a,b,c,d,e)

static struct Code_Rec {
    Vm_Int   key;	/* opcode.					*/
    Vm_Int   op;	/* First bytecode.				*/
    Vm_Int   op2;	/* If nonzero, 2nd opcode|JOB_2_BYTES		*/
    Vm_Int   x;		/* Bytes per immediate offset.			*/
    Vm_Int   x_signed;	/* Whether   immediate offsets are signed.	*/
    Vm_Int   commutes;	/* True for + * etc, false for - / etc.		*/
    Vm_Int   sp_adjust;	/* Stack offset, beyond usual.			*/
    Vm_Chr*  name;
    Vm_Obj   arity;
} job_Code[ JOB_CODE_MAX ];
typedef struct Code_Rec A_Code;
typedef struct Code_Rec*  Code;
static unsigned code_next = 0;  /* Next slot to allocate. */
static unsigned fast_next = 0;  /* Next fast bytecode to allocate. */
static unsigned slow_next = 0;  /* Next slow bytecode to allocate. */
static unsigned prim_next = 0;  /* Next prim opcode   to allocate. */

 /***********************************************************************/
 /*-   fast[]/Fast -- Specs for speed-critical primitives		*/

  /**********************************************************************/
  /*-  fast[] Overview							*/
  /**********************************************************************/

/* 

Fast[] specifies primitive functions to construct.
Type-checking on first two stack arguments is 'free', since
it is done in JOB_NEXT.  The prim must do type checking by
hand on any other input arguments.

Specifying typechecking on nonstack arguments doesn't
accomplish much.

'a_name' is used to generate a unique name for prim, has no
intrinsic meaning.

'c_name' is the C name for a binary operator: "*" for
multiply etc.  This is special support for generating the
arithmetic prims, for other prims you'll want to just set
this to "" and use 'macro'.

'commutes' is TRUE for multiplication and addition, not for
subtraction or division.

'sp_adjust' can be used to specify a stack adjustment beyond
that normally generated, it is added to the normal stack
adjustment computed by counting 's' arguments.

'x_min'/'x_max' specify the size-in-bytes range allowed for
index fields following opcode.  Setting both to 1 limits
access to first 256 vars/consts/etc. Setting both to 2
allows access to first 64K vars/consts etc, but of course
takes more space in generated code.  Setting min/max to 1/2
generates codes for both 1- and 2-byte variants, making for
more compact code generated, at price of more primitive
functions and opcode space.  Set both to zero if all
location arguments are "s", meaning no index fields will be
generated anyhow.

'l[012]' are chars specifying where our up-to-three input
and output arguments may be found, "_" if that argument
doesn't exist.  Letters in these strings are from the set
defined in loc[].  For unary arithmetic ops, l1 should be
"_", l0 and l2 should be "s".

't[12]' are strings specifying the set of input argument
types to be accepted.  Letters in these strings are from the
set defined in cell_types.  Typechecking costs nothing
beyond normal bytecode lookup if the arguments are on the
stack ("s"), otherwise it must be done by code you provide.

(Note that specifying a "_" (don't-care) typestring
isn't the same as listing all types, the first will generate
just one prim fn, the second will generate a prim function
for each type specified.  Either can be useful, depending on
the situation.)

't0' is a string specifying how to set the destination type:
 "_" means don't do anything
 "i" means make type integer.  Used for >= etc.
 "1" means copy type from first  argument
 "2" means copy type from second argument
 "a" means compute type according to arithmetic rules:
       i+i -> i
       r+i -> r
       r+r -> r
       R+* -> R
     Note that this will only work if both args are on stack,
     since jobbuild.c uses only the type information generated
     by JOB_NEXT, which checks only the top two stack locs.    

'macro' is a string which, if strlen('macro'), will be macro-expanded
within the primitive, with L0, L1, L2 available as the dst/src1/src2
arguments, T1, T2 as types for args L1,L2 (useful only if L1/L2 are on
stack), FN_NAME as name of the primitive fn being generated, X as the
correct expression for reading an un/signed index from the instruction
stream (if nonzero, X must be used exactly once in the instruction,
else instruction length computations will be thrown off, and hence
instruction restart code), ILEN as the instruction length in bytes, N2
as the numeric value of L2 if it is on stack and int or float, and N2Z
'0' '0.0' or 'OBJ_FROM_BYT0' according to the type of L2: i/r/other.
(N1/N1Z do for L1 what N2/N2Z do for L2.  N1U and N2U -- unity -- are
1 or 1.0 as appropriate.  TYP2 is OBJ_FROM_INT or OBJ_FROM_FLOAT,
according to type of N2.) This is a general mechanism for plugging
arbitary code into the generated prims.  (Obviously, if you have a lot
of code to plug in, it makes most sense to put it in another fn and
just macro-expand in a call.)

It is permissable to have two entries with the same 'a_name': this is
useful for specifying different operations for the same bytecode,
depending on the types of the stack arguments.  Such entry pairs
should match in all slots except 'c_name', 't0', 't1', 't2' and
'macro'.  Such pairs _only_ make sense if 'l2' (and 'l1' if present)
are 's'.  Entries are processed in order, and later ones more or less
blindly overwrite previous ones in such cases: It may make sense to
have the first entry specify 't1'=='t2'=="_" to establish default case
handling, then have subsequent entries override the default for
specific combinations of arguments.

*/


  /**********************************************************************/
  /*-  Fast_Rec								*/
  /**********************************************************************/

static struct Fast_Rec {
    char* a_name;	/* Arbitary string name for internal use.	*/
    char* c_name;	/* Native 'c' name.				*/
    Vm_Int   commutes;	/* TRUE iff operation is commutative.		*/
    Vm_Int   sp_adjust;	/* Bump stack by this, beyond normal push/pop.  */
    Vm_Int   x_min;	/* Min size-in-bytes for indices.		*/
    Vm_Int   x_max;	/* Max size-in-bytes for indices.		*/
    Vm_Int   x_signed;	/* 0/1 as index is un/signed.			*/
    Vm_Int   ilen_valid;/* True iff jS.instruction_len good at fn end.  */
    char  l0;		/* Loc for    output, "_"  if none.		*/
    char  l1;		/* Loc for 1st input, "_"  if no 1st.		*/
    char  l2;		/* Loc for 2nd input, "_"  if no 2nd.		*/
    char* t0;		/* "_"("a"==arithmetic rule, "1"/"2"==arg 1/2)  */
    char* t1;		/* Types allowed for 1st input, "_" ==don't care*/
    char* t2;		/* Types allowed for 2nd input, "_" ==don't care*/
    Vm_Obj   arity;
    char* macro;	/* "" else Code to macro-expand at end of fn.	*/
} fast[] = {


  /**********************************************************************/
  /*-   Slow ops dispatch fns -- Must be first.		 		*/
  /**********************************************************************/

/* The SLO[34] indirections through job_OpenGL_Table[34] allow us to */
/* switch OpenGL support on or off just by changing those pointers,  */
/* at the reasonable cost of one extra memory fetch per OpenGL       */
/* primitive executed:                                               */

/* A   	C  C S M M S I   L   L   L    T   T     T     A M     */
/* n	n  o p i a i l   0   1   2    0   1     2     r c     */
/* a	a  m   n x g e	                              t r     */
/* m	m  m	   n n	                              y o     */
{"SLO0","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Table0  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO1","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Table1  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO2","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Table2  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO3","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_OpenGL_Table3)[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO4","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_OpenGL_Table4)[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO5","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Table5  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO6","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Table6  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO7","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Table7  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO8","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Table8  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLO9","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Table9  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLOA","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Tablea  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLOB","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Tableb  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLOC","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Tablec  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLOD","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Tabled  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLOE","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Tablee  )[i]();JOB_UNCACHE_ARGS;}"
},
{"SLOF","",0,0,1,1,0,1, '_','_','_', "_","_"  ,"_"  , A(0,0,0,0,0),
 "{register Vm_Int i=X;JOB_CACHE_ARGS;((Job_Slow_Prim*)job_Slow_Tablef  )[i]();JOB_UNCACHE_ARGS;}"
},

  /**********************************************************************/
  /*-  Logic ops -- not and or bitand bitor bitxor bitshift int?	*/
  /**********************************************************************/

/* A   	C  C S M M S I   L   L   L    T   T    T     A M     */
/* n	n  o p i a i l   0   1   2    0   1    2     r c     */
/* a	a  m   n x g e	                             t r     */
/* m	m  m	   n n	                             y o     */
{"NOT","" ,0,0,0,0,0,0, 's','_','s', "_","_", "_" ,  A(0,0,1,1,0),
 "L0 = OBJ_FROM_BOOL( L2==OBJ_NIL );"
},
{"AND","" ,1,0,0,0,0,0, 's','s','s', "_","_", "_" , A(0,0,2,1,0),
 /* A good compiler can do the following w/o jumps: */
 "L0 = OBJ_FROM_BOOL( ((L1!=OBJ_NIL) + (L2!=OBJ_NIL)) >>1 );"
},
{"OR",""  ,1,0,0,0,0,0, 's','s','s', "_","_","_" , A(0,0,2,1,0),
 /* A good compiler can do the following w/o jumps: */
 "L0 = OBJ_FROM_BOOL(   L1!=OBJ_NIL  |  L2!=OBJ_NIL       );"
},

{"AND_BITS","",1,0,0,0,0,0, 's','s','s', "_","_","_",A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_And_Bits();JOB_UNCACHE_ARGS;" },
{"AND_BITS","",1,0,0,0,0,0, 's','s','s', "_","i","i",A(0,0,2,1,0),
 "L0=OBJ_FROM_INT(N1&N2);"},
{"NOT_BITS","",1,0,0,0,0,0, 's','_','s', "_","_","_",A(0,0,1,1,0),
 "JOB_CACHE_ARGS;job_P_Not_Bits();JOB_UNCACHE_ARGS;" },
{"NOT_BITS","",1,0,0,0,0,0, 's','_','s', "_","_","i",A(0,0,1,1,0),
 "L0=OBJ_FROM_INT(~N2);"},
{"OR_BITS" ,"",1,0,0,0,0,0, 's','s','s', "_","_","_",A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Or_Bits();JOB_UNCACHE_ARGS;" },
{"OR_BITS" ,"",1,0,0,0,0,0, 's','s','s', "_","i","i",A(0,0,2,1,0),
 "L0=OBJ_FROM_INT(N1|N2);"},
{"XOR_BITS","",1,0,0,0,0,0, 's','s','s', "_","_","_",A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Xor_Bits();JOB_UNCACHE_ARGS;" },
{"XOR_BITS","",1,0,0,0,0,0, 's','s','s', "_","i","i",A(0,0,2,1,0),
 "L0=OBJ_FROM_INT(N1^N2);"},
{"SHIFT_BITS","",1,0,0,0,0,0,'s','s','s',"_","_","_",A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Shift_Bits();JOB_UNCACHE_ARGS;" },
{"SHIFT_BITS","",1,0,0,0,0,0,'s','s','s',"_","i","i",A(0,0,2,1,0),
  "{register Vm_Int n1=N1;"
   "register Vm_Int n2=N2;"

   "if (n2<0) {"
        "L0=OBJ_FROM_INT((n1>>-(n2)));"
   "}else{"
       /* Try to do the simple common cases fast:			   */
       /* Note: trying to do fixnum shifts whenever ((n1<<n2) >>>n2) == n1 */
       /* seems to fail on intel due to the shift hardware simply ignoring */
       /* high-order bits in n2, resulting in false positives. :(          */
       "if (!(n1&~(((Vm_Int)1<<(VM_INTBITS>>1))-(Vm_Int)1))"
       "&& (n2<((VM_INTBITS>>1)-(Vm_Int)2*OBJ_INT_SHIFT))"
       "){"
         "L0=OBJ_FROM_INT(n1<<n2);"
       "}else{"
         "L0=bnm_LeftshiftII(n1,n2);"
       "}"
   "}"
  "}"
},
#ifdef OLDX
{"INTEGER_P","",0,0,0,0,0,0, 's','_','s', "_","_","_",A(0,0,1,1,0),
    "L0=OBJ_FROM_BOOL(OBJ_IS_INT(N2));"
},
#endif

  /**********************************************************************/
  /*-  Arithmetic ops -- + - * / ...					*/
  /**********************************************************************/

/* A   	C  C S M M S I   L   L   L    T   T     T     A M     */
/* n	n  o p i a i l   0   1   2    0   1     2     r c     */
/* a	a  m   n x g e	                              t r     */
/* m	m  m	   n n	                              y o     */
{"NEG","" ,0,0,0,0,0,0, 's','_','s', "_","_" ,"_" , A(0,0,1,1,0), "JOB_CACHE_ARGS;job_P_Neg();JOB_UNCACHE_ARGS;" },
{"NEG","" ,0,0,0,0,0,0, 's','_','s', "_","r", "r" , A(0,0,1,1,0),"L0 = OBJ_FROM_FLOAT(-N2);"},
/* buggo -- We can't always negate a fixnum and get a fixnum: */
{"NEG","" ,0,0,0,0,0,0, 's','_','s', "_","i", "i" , A(0,0,1,1,0),
"{ Vm_Int n2=N2;"
  /* Only time in my life I've wished we were using one's complement! */
  "if (n2==BNM_THE_NEGATIVE_FIXNUM_WITH_NO_MATCHING_POSITIVE_FIXNUM) L0 = bnm_Smallest_Positive_Bignum();"
  "else L0 = OBJ_FROM_INT(-n2);"
"}"
},
{"ADD","" ,1,0,0,0,0,1, 's','s','s', "_","_" ,"_" , A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Plus();JOB_UNCACHE_ARGS;" },
{"ADD","+",1,0,0,0,0,0, 's','s','s', "a","r" , "r", A(0,0,2,1,0),"" },
{"ADD","+",1,0,0,0,0,0, 's','s','s', "a","i" , "r", A(0,0,2,1,0),"" },
{"ADD","+",1,0,0,0,0,0, 's','s','s', "a","r" , "i", A(0,0,2,1,0),"" },
{"ADD","" ,1,0,0,0,0,0, 's','s','s', "a","i",  "i", A(0,0,2,1,0),
  "Vm_Int a = N1;"	/* First input argument.		*/
  "Vm_Int b = N2;"	/* Second input argument.		*/
  "Vm_Int c = a+b;"	/* Sum of two inputs.			*/	
  "Vm_Int d = a^~b;"	/* Were the two sign bits identical?	*/
  /* Check for and handle arithmetic overflow without using assembly support:*/
  /* If the two input signbits were identical and the result signbit differs */
  /* then we have an overflow and need to switch to bignum arithmetic.       */
  /* Obviously, assembly language support here would be a cool speed hack... */
  "if ((d&(c^b)) & (~((~((Vm_Unt)0))>>1)>>OBJ_INT_SHIFT) )"
  "{L0=bnm_AddII(N1,N2);}" /*printf(\"a x=%llx b x=%llx c x=%llx d=%llx\\n\",a,b,c,d);*/
  "else L0=OBJ_FROM_INT(c);"
},
{"SUB","" ,0,0,0,0,0,1, 's','s','s', "_","_" ,"_" , A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Sub();JOB_UNCACHE_ARGS;" },
{"SUB","-",0,0,0,0,0,0, 's','s','s', "a", "r", "r", A(0,0,2,1,0),"" },
{"SUB","-",0,0,0,0,0,0, 's','s','s', "a", "i", "r", A(0,0,2,1,0),"" },
{"SUB","-",0,0,0,0,0,0, 's','s','s', "a", "r", "i", A(0,0,2,1,0),"" },
{"SUB","" ,0,0,0,0,0,0, 's','s','s', "a", "i", "i", A(0,0,2,1,0),
  /* Note that we cannot just negate N2 and then use the addition  */
  /* code: Since there is one more negative than positive value in */
  /* two's complement, we cannot count on being able to negate N2. */
  "Vm_Int a =  N1;"	/* First input argument.		*/
  "Vm_Int b =  N2;"	/* Second input argument.		*/
  "Vm_Int c = a-b;"	/* Difference of two inputs.		*/	
  "Vm_Int d = a^b;"	/* Were the two sign bits opposite?	*/
  /* Check for and handle arithmetic overflow without using assembly support:*/
  /* If the two input signbits were opposite and the result signbit differs  */
  /* from that of 'a' then we have an overflow and need to switch to bignums.*/
  /* Obviously, assembly language support here would be a cool speed hack... */
/*"printf(\"a x=%llx b x=%llx c x=%llx d=%llx\\n\",a,b,c,d);"*/
  "if ((d&(c^a)) & (~((~((Vm_Unt)0))>>1)>>OBJ_INT_SHIFT) )"
  "{L0=bnm_SubII(a,b);}" /*printf(\"a x=%llx b x=%llx c x=%llx d=%llx\\n\",a,b,c,d);*/
  "else L0=OBJ_FROM_INT(c);"
},

{"MUL","" ,1,0,0,0,0,0, 's','s','s', "_","_","_", A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Mult();JOB_UNCACHE_ARGS;" },
{"MUL","*",1,0,0,0,0,0, 's','s','s', "a","r","r", A(0,0,2,1,0),"" },
{"MUL","*",1,0,0,0,0,0, 's','s','s', "a","i","r", A(0,0,2,1,0),"" },
{"MUL","*",1,0,0,0,0,0, 's','s','s', "a","r","i", A(0,0,2,1,0),"" },
{"MUL","" ,1,0,0,0,0,0, 's','s','s', "a","i","i", A(0,0,2,1,0),
 "{"
  "Vm_Int n1 =  N1;"	/* First input argument.		*/
  "Vm_Int n2 =  N2;"	/* Second input argument.		*/
  /* Check for and handle arithmetic overflow without using assembly support:*/
  /* Obviously, assembly language support here would be a cool speed hack... */
  "if (!((n1|n2)&~(((Vm_Int)1<<((VM_INTBITS>>1)-OBJ_INT_SHIFT))-(Vm_Int)1)))"
  "L0=OBJ_FROM_INT(n1*n2);"
  "else{L0=bnm_MultII(n1,n2);}"
 "}"
},
{"DIV","" ,0,0,0,0,0,0, 's','s','s', "_","_" ,"_" , A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Div();JOB_UNCACHE_ARGS;" },
{"DIV","/",0,0,0,0,0,0, 's','s','s', "a","ri","ri", A(0,0,2,1,0),""
 "if (N2 == N2Z) {JOB_CACHE_ARGS;job_Divide_By_Zero();}"
},
/* C barfs on d % d so we just do ints for now: */
{"MOD","" ,0,0,0,0,0,0, 's','s','s', "_","_" ,"_" , A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Mod();JOB_UNCACHE_ARGS;" },
{"MOD","%",0,0,0,0,0,0, 's','s','s', "a", "i", "i", A(0,0,2,1,0), ""
 "if (N2 == N2Z) {JOB_CACHE_ARGS;job_Divide_By_Zero();}"
},
/* buggo, bignums not supported yet... */
{"INC","",0,0,0,0,0,0,'s','_','s',"a","_","ri",A(0,0,1,1,0),"L0=TYP2(N2+N2U);" },
{"DEC","",0,0,0,0,0,0,'s','_','s',"a","_","ri",A(0,0,1,1,0),"L0=TYP2(N2-N2U);" },


  /**********************************************************************/
  /*-  Comparison ops -- <= > ...					*/
  /**********************************************************************/

/* A   	C  C S M M S I   L   L   L    T   T     T     A M     */
/* n	n  o p i a i l   0   1   2    0   1     2     r c     */
/* a	a  m   n x g e	                              t r     */
/* m	m  m	   n n	                              y o     */
{"ALE","" ,0,0,0,0,0,1, 's','s','s', "_","_" ,"_" ,   A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Ale();JOB_UNCACHE_ARGS;" },
{"ALE","<=",0,0,0,0,0,0,'s','s','s', "i","ri","ri",   A(0,0,2,1,0),"" },
{"AGE","" ,0,0,0,0,0,1, 's','s','s', "_","_" ,"_" ,   A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Age();JOB_UNCACHE_ARGS;" }, 
{"AGE",">=",0,0,0,0,0,0,'s','s','s', "i","ri","ri",   A(0,0,2,1,0),"" },
{"ALT","" ,0,0,0,0,0,1, 's','s','s', "_","_" ,"_" ,   A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Alt();JOB_UNCACHE_ARGS;" },
{"ALT","<" ,0,0,0,0,0,0,'s','s','s', "i","ri","ri",   A(0,0,2,1,0),"" },
{"AGT","" ,0,0,0,0,0,1, 's','s','s', "_","_" ,"_" ,   A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Agt();JOB_UNCACHE_ARGS;" },
{"AGT",">" ,0,0,0,0,0,0,'s','s','s', "i","ri","ri",   A(0,0,2,1,0),"" },
{"AEQ","" ,0,0,0,0,0,1, 's','s','s', "_","_" ,"_" ,   A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Aeq();JOB_UNCACHE_ARGS;" },
{"AEQ","==",0,0,0,0,0,0,'s','s','s', "i","ri","ri",   A(0,0,2,1,0),"" },
{"ANE","" ,0,0,0,0,0,1, 's','s','s', "_","_" ,"_" ,   A(0,0,2,1,0),
 "JOB_CACHE_ARGS;job_P_Ane();JOB_UNCACHE_ARGS;" },
{"ANE","!=",0,0,0,0,0,0,'s','s','s', "i","ri","ri",   A(0,0,2,1,0),"" },
{"EQ" ,"" ,0,1,0,0,0,0, '_','s','s', "_","_",  "_",   A(0,0,2,1,0),
  "jSs[-1]=OBJ_FROM_BOOL(L1==L2);"
},

  /**********************************************************************/
  /*-  Stack ops -- pop swap ...					*/
  /**********************************************************************/

/* A   	 C  C S M M S I   L   L   L    T   T     T     A M     */
/* n	 n  o p i a i l   0   1   2    0   1     2     r c     */
/* a	 a  m   n x g e                                t r     */
/* m	 m  m	    n n                                y o     */
{"POP" ,"", 0,0,0,0,0,0, '_','_','s', "_","_",  "_",   A(0,0,1,0,0),"" },
{"DUP" ,"", 0,1,0,0,0,0, 's','_','s', "_","_",  "_",   A(0,0,1,2,0),
 "jSs[1] = L2;"
},
{"SWAP","", 0,1,0,0,0,0, 's','s','s', "_","_",  "_",   A(0,0,2,2,0),
 "{Vm_Obj tmp; tmp=L1; L1=L2; L2=tmp;}"
},

  /**********************************************************************/
  /*-  Control ops							*/
  /**********************************************************************/

/* A   	 C  C S M M S I   L   L   L    T   T     T     M     */
/* n	 n  o p i a i l   0   1   2    0   1     2     c     */
/* a	 a  m   n x g e                                r     */
/* m	 m  m	    n n                                o     */
{"BEQ", "", 0,0,1,2,1,0, 'p','_','s', "_","_","_", A(0,0,1,0,2),
 "if (L2 == OBJ_NIL)   jSpc += l0off;"
},
#ifdef MAYBE_SOMEDAY
/* muf compiler isn't bright enough to generate these yet, */
/* and it's not clear they are used enough to justify the  */
/* bytecode space anyhow.  Need some statistics.           */
{"BGE", "", 0,0,1,2,1,0, 'p','_','s', "_","_","ri", A(0,0,1,0,2),
 "if (N2 >= N2Z)   jSpc += l0off;"
},
{"BGT", "", 0,0,1,2,1,0, 'p','_','s', "_","_","ri", A(0,0,1,0,2),
 "if (N2 >  N2Z)   jSpc += l0off;"
},
{"BLE", "", 0,0,1,2,1,0, 'p','_','s', "_","_","ri", A(0,0,1,0,2),
 "if (N2 <= N2Z)   jSpc += l0off;"
},
{"BLT", "", 0,0,1,2,1,0, 'p','_','s', "_","_","ri", A(0,0,1,0,2),
 "if (N2 <  N2Z)   jSpc += l0off;"
},
#endif
{"BNE", "", 0,0,1,2,1,0, 'p','_','s', "_","_","_",  A(0,0,1,0,2),/* buggo? Why "rio"? */
 "if (L2 != OBJ_NIL)   jSpc += l0off;"
},
{"PUSH_CATCH" , "", 0,-1,1,2,1,1, 'p','_','_', "_","_",  "_", A(0,0,1,0,0),
 "JOB_CACHE_ARGS;"
 "job_Push_Catchframe(l0off+(ILEN));"
 "JOB_UNCACHE_ARGS;"
},
{"PUSH_TAG"   , "", 0,-1,1,2,1,1, 'p','_','_', "_","_",  "_", A(0,0,1,0,0),
 "JOB_CACHE_ARGS;"
 "job_Push_Tagframe(l0off+(ILEN));"
 "JOB_UNCACHE_ARGS;"
},
{"PUSH_PROTECT" , "", 0,0,1,2,1,1, 'p','_','_', "_","_",  "_", A(0,0,0,0,0),
 "JOB_CACHE_ARGS;"
 "job_Push_Protectframe(l0off+(ILEN));"
 "JOB_UNCACHE_ARGS;"
},
{"PUSH_PROTECT_CHILD" , "", 0,0,1,2,1,1, 'p','_','_', "_","_",  "_", A(0,0,0,0,0),
 "JOB_CACHE_ARGS;"
 "job_Push_Protectchildframe(l0off+(ILEN));"
 "JOB_UNCACHE_ARGS;"
},
{"BLANCH_PROTECT","", 0,0,1,2,1,1, 'p','_','_', "_","_",  "_", A(0,0,0,0,0),
 "JOB_CACHE_ARGS;"
 "job_Blanch_Protectframe(l0off+(ILEN));"
 "JOB_UNCACHE_ARGS;"
},
{"BRA", "", 0,0,1,2,1,0, 'p','_','_', "_","_",  "_", A(0,0,0,0,2),
 "jSpc += l0off;"
},
/* NOTE: JOB_IS_BRANCH macro thinks it knows the order of */
/* the above branches, if you change the above, you may   */
/* need to its definition in write_jobprims_h.		  */

/* NOTE: compact_bytecodes_stack() thinks it knows that   */
/* VARS instructions are always two bytes long.           */
{"VARS","", 0,0,1,1,0,1, '_','_','_', "_","_",  "_", A(0,0,0,0,0),

 /* Read number of local variable slots to allocate: */
 "{ register Vm_Unt slots    = X;"
   "register Vm_Obj* l       = jS.l;"
   "register Vm_Int oldlen   = *l;"
   "register Vm_Int newlen   = oldlen + slots*sizeof(Vm_Obj);"
   
   /* Guarantee that instruction_length    */
   /* will be valid at end of instruction: */
   "jS.instruction_len = ILEN;"

   /* Check for loop stack overflow: */
   "if (l + slots >= jS.l_top) {"
     "JOB_CACHE_ARGS;"
     "job_Guarantee_Loop_Headroom(slots);"
     "JOB_UNCACHE_ARGS;"
     "l = jS.l;"
   "}"

   /* Check that we're on a NORMAL stackframe: */
   "if (l[-1] != JOB_STACKFRAME_NORMAL) {"
     "JOB_CACHE_ARGS;"
     "MUQ_WARN(\"VARS opcode must be first in fn.\");"
   "}"

   /* Allocate requested number of local-var slots: */
   "l += slots;"

   /* Write new top-of-frame: */
   "l[ 0] = newlen;"
   "l[-1] = JOB_STACKFRAME_NORMAL;"
   "jS.l = l;"
   /* Update bottom-of-frame length count: */
   "l = (Vm_Obj*) (((Vm_Chr*)l) - (Vm_Int)(*l));"
   "*++l = newlen;"
 "}"
},

{"RETURN", "", 0,0,0,0,0,1, '_','_','_', "_","_",  "_", A(0,0,0,0,1),
  "JOB_CACHE_ARGS;"
  "job_P_Return();"
  "JOB_UNCACHE_ARGS;"
},

{"CALLI","", 0,0,1,2,0,1, '_','_','k', "_","_",  "_",  A(0,0,0,0,4),
  /* CALL-Immediate.	*/
  "JOB_CACHE_ARGS;"
  "job_Call(L2);"
  "JOB_UNCACHE_ARGS;"
},

{"LCALL","", 0,0,1,2,0,1, '_','_','k', "_","_",  "_",  A(1,0,1,0,0),
  /* Lisp-CALL.	*/
  "JOB_CACHE_ARGS;"
  "job_LispCall(L2);"
  "JOB_UNCACHE_ARGS;"
},

/* A   	 C  C S M M S I   L   L   L    T   T     T     M     */
/* n	 n  o p i a i l   0   1   2    0   1     2     c     */
/* a	 a  m   n x g e                                r     */
/* m	 m  m	    n n                                o     */
{"CALLA","",0,0,1,2,0,1, '_','_','k', "_","_",  "_",  A(0,0,0,0,9),
  /* CALL-with-Arity.	*/
  "JOB_CACHE_ARGS;"
  "job_Calla(L2);"
  "JOB_UNCACHE_ARGS;"
},

  /**********************************************************************/
  /*-  Get/Set ops							*/
  /**********************************************************************/

/* A   	 C  C S M M S I   L   L   L   T   T   T    A M     */
/* n	 n  o p i a i l   0   1   2   0   1   2    r c     */
/* a	 a  m   n x g e                            t r     */
/* m	 m  m	    n n                            y o     */
{"GETi","", 0,0,1,1,1,0, 's','_','_',"_","_","_", A(0,0,0,1,0),"L0 = OBJ_FROM_INT(X);"},
{"GETk","", 0,0,1,2,0,0, 's','_','k',"_","_","_", A(0,0,0,1,0),"L0 = L2;"},
{"GETv","", 0,0,1,2,0,0, 's','_','v',"_","_","_", A(0,0,0,1,0),"L0 = L2;"},
{"SETv","", 0,0,1,2,0,0, 'v','_','s',"_","_","_", A(0,0,1,0,0),"L0 = L2;"},
{"SYMBOL_FUNCTION","",0,0,0,0,0,0,'s','_','s',"_","_","s",A(0,0,1,1,0),
  "{ Vm_Obj o=L2;"
    "JOB_CACHE_ARGS;"
    "o= job_Symbol_Function(o);"
    "if (o == SYM_CONSTANT_FLAG) o = OBJ_NIL;"
    "JOB_UNCACHE_ARGS;"
    "L0 = o;"
  "}"
},
{"SET_SYMBOL_FUNCTION","",0,0,0,0,0,0,'_','s','s',"_","_","s",A(0,0,2,0,0),
  "{ Vm_Obj sym=L2;"
    "Vm_Obj fn=L1;"
    "JOB_CACHE_ARGS;"
    "{ Sym_P p = SYM_P(sym);"
      "if (p->function == SYM_CONSTANT_FLAG) {"
        "MUQ_WARN (\"Can't set function slot on a constant.\");"
      "}"
      "p->function=fn;"
    "vm_Dirty(sym);"
  "} }"
  "JOB_UNCACHE_ARGS;"
},
{"SYMBOL_VALUE","",0,0,0,0,0,0,'s','_','s',"_","_","s",A(0,0,1,1,0),
  "{"
    "Vm_Obj o = L2;"
    "JOB_CACHE_ARGS;"
    "o = job_Symbol_Value(o);"
    "JOB_UNCACHE_ARGS;"
    "L0 = o;"
  "}"
},
{"SET_SYMBOL_VALUE","",0,0,0,0,0,0,'_','s','s',"_","_","s",A(0,0,2,0,0),
  "{ Vm_Obj sym=L2;"
    "Vm_Obj val=L1;"
    "JOB_CACHE_ARGS;"
    "{ Sym_P p = SYM_P(sym);"
      "if (p->function == SYM_CONSTANT_FLAG) {"
        "MUQ_WARN (\"Can't set value of a constant.\");"
      "}"
      "p->value=val;"
      "vm_Dirty(sym);"
  "} }"
  "JOB_UNCACHE_ARGS;"
},
/* A   	 C  C S M M S I   L   L   L   T   T   T    A M     */
/* n	 n  o p i a i l   0   1   2   0   1   2    r c     */
/* a	 a  m   n x g e                            t r     */
/* m	 m  m	    n n                            y o     */
{"CAR",  "",0,0,0,0,0,0,'s','_','s',"_","_","_",A(0,0,1,1,0),
 "if(OBJ_IS_EPHEMERAL_LIST(L2)){"
  "Vm_Obj owner;L0=ECN_P(&owner,L2)->car;"
 "}else if(L2!=OBJ_NIL){"
   "JOB_CACHE_ARGS;MUQ_WARN(\"car: Arg must be a List.\");"
 "}"
},
{"CAR",  "",0,0,0,0,0,0,'s','_','s',"_","_","c",A(0,0,1,1,0),"L0=LST_P(L2)->car;"},
{"CDR",  "",0,0,0,0,0,0,'s','_','s',"_","_","_",A(0,0,1,1,0),
 "if(OBJ_IS_EPHEMERAL_LIST(L2)){"
  "Vm_Obj owner;L0=ECN_P(&owner,L2)->cdr;"
 "}else if(L2!=OBJ_NIL){"
   "JOB_CACHE_ARGS;MUQ_WARN(\"cdr: Arg must be a List.\");"
 "}"
},
{"CDR",  "",0,0,0,0,0,0,'s','_','s',"_","_","c",A(0,0,1,1,0),"L0=LST_P(L2)->cdr;"},

  /**********************************************************************/
  /*-  End-of-array sentinel etc					*/
  /**********************************************************************/

{NULL,NULL,0,0,0,0,0,0, '\0','\0','\0', NULL,NULL,NULL, 0, NULL}
};
typedef struct Fast_Rec A_Fast;
typedef struct Fast_Rec*  Fast;

 /***********************************************************************/
 /*-   slow[]/Slow -- Specs for garden variety primitives		*/
 /***********************************************************************/

  /**********************************************************************/
  /*-  slow[] Overview							*/
  /**********************************************************************/

/* 

Slow[] specifies primitive functions to construct.
"Slow" primitives take an additional bytecode of encoding,
and Muq does no automatic argument checking for them.
In general, it is expected that they get and return all
values from/to the stack, and do their own typechecking
as required.

'a_name' is used to generate a unique name for prim, has no
intrinsic meaning.

*/

  /**********************************************************************/
  /*-  Slow_Rec								*/
  /**********************************************************************/

static struct Slow_Rec {
    Vm_Obj  arity;
    Vm_Chr* a_name;	/* Arbitary string name for internal use.	*/
} slow[] = {

  /**********************************************************************/
  /*-  Slow prim specs							*/
  /**********************************************************************/

/* Good things to do when adding XXXX here:	*/
/*						*/
/* -> Declare job_P_Xxxx in h/job.h		*/
/*						*/
/* -> Implement job_P_Xxxx in c/job.t		*/
/*						*/
/* -> Enter into c/muf.t: mufprim[].		*/
/*						*/
/* -> Document in info/mufcore.t		*/
/*						*/
/* -> Because many opcodes may have changed,	*/
/*    do "muq-clobber" and then "make" to	*/
/*    completely rebuild server, then nuke	*/
/*    your dbs and rebuild them.		*/

/* Arity         A_name          		*/
/* ----------    -----------------------------	*/
{A(0,0,2,0,0),	"PUBLIC_DEL_KEY"		},
{A(0,0,2,2,0),	"PUBLIC_DEL_KEY_P"		},
{A(0,0,1,2,0),	"PUBLIC_GET_FIRST_KEY"		},
{A(0,0,2,2,0),	"PUBLIC_GET_KEY_P"		},
{A(0,1,2,0,0),	"PUBLIC_GET_KEYS_BY_PREFIX"	},
{A(0,0,2,2,0),	"PUBLIC_GET_NEXT_KEY"		},
{A(0,0,2,1,0),	"PUBLIC_GET_VAL"    		},
{A(0,0,2,2,0),	"PUBLIC_GET_VAL_P"		},
{A(0,1,1,0,0),	"PUBLIC_KEYSVALS_BLOCK"		},
{A(0,1,1,0,0),	"PUBLIC_KEYS_BLOCK"		},
{A(1,0,1,0,0),	"PUBLIC_SET_FROM_BLOCK"		},
{A(1,0,1,0,0),	"PUBLIC_SET_FROM_KEYSVALS_BLOCK"},
{A(0,0,3,0,0),	"PUBLIC_SET_VAL"    		},
{A(0,1,1,0,0),	"PUBLIC_VALS_BLOCK"		},

{A(0,0,2,0,0),	"HIDDEN_DEL_KEY"		},
{A(0,0,2,2,0),	"HIDDEN_DEL_KEY_P"		},
{A(0,0,1,2,0),	"HIDDEN_GET_FIRST_KEY"		},
{A(0,0,2,2,0),	"HIDDEN_GET_KEY_P"		},
{A(0,1,2,0,0),	"HIDDEN_GET_KEYS_BY_PREFIX"	},
{A(0,0,2,2,0),	"HIDDEN_GET_NEXT_KEY"		},
{A(0,0,2,1,0),	"HIDDEN_GET_VAL"    		},
{A(0,0,2,2,0),	"HIDDEN_GET_VAL_P"		},
{A(0,1,1,0,0),	"HIDDEN_KEYSVALS_BLOCK"		},
{A(0,1,1,0,0),	"HIDDEN_KEYS_BLOCK"		},
{A(1,0,1,0,0),	"HIDDEN_SET_FROM_BLOCK"		},
{A(1,0,1,0,0),	"HIDDEN_SET_FROM_KEYSVALS_BLOCK"},
{A(0,0,3,0,0),	"HIDDEN_SET_VAL"   		},
{A(0,1,1,0,0),	"HIDDEN_VALS_BLOCK"		},

{A(0,0,2,0,0),	"SYSTEM_DEL_KEY"		},
{A(0,0,2,2,0),	"SYSTEM_DEL_KEY_P"		},
{A(0,0,1,2,0),	"SYSTEM_GET_FIRST_KEY"		},
{A(0,0,2,2,0),	"SYSTEM_GET_KEY_P"		},
{A(0,1,2,0,0),	"SYSTEM_GET_KEYS_BY_PREFIX"	},
{A(0,0,2,2,0),	"SYSTEM_GET_NEXT_KEY"		},
{A(0,0,2,1,0),	"SYSTEM_GET_VAL"    		},
{A(0,0,2,2,0),	"SYSTEM_GET_VAL_P"		},
{A(0,1,1,0,0),	"SYSTEM_KEYSVALS_BLOCK"		},
{A(0,1,1,0,0),	"SYSTEM_KEYS_BLOCK"		},
{A(1,0,1,0,0),	"SYSTEM_SET_FROM_BLOCK"		},
{A(1,0,1,0,0),	"SYSTEM_SET_FROM_KEYSVALS_BLOCK"},
{A(0,0,3,0,0),	"SYSTEM_SET_VAL"    		},
{A(0,1,1,0,0),	"SYSTEM_VALS_BLOCK"		},

{A(0,0,2,0,0),	"ADMINS_DEL_KEY"		},
{A(0,0,2,2,0),	"ADMINS_DEL_KEY_P"		},
{A(0,0,1,2,0),	"ADMINS_GET_FIRST_KEY"		},
{A(0,0,2,2,0),	"ADMINS_GET_KEY_P"		},
{A(0,1,1,0,0),	"ADMINS_GET_KEYS_BY_PREFIX"	},
{A(0,0,2,2,0),	"ADMINS_GET_NEXT_KEY"		},
{A(0,0,2,1,0),	"ADMINS_GET_VAL"		},
{A(0,0,2,2,0),	"ADMINS_GET_VAL_P"		},
{A(0,1,1,0,0),	"ADMINS_KEYSVALS_BLOCK"		},
{A(0,1,1,0,0),	"ADMINS_KEYS_BLOCK"		},
{A(1,0,1,0,0),	"ADMINS_SET_FROM_BLOCK"		},
{A(1,0,1,0,0),	"ADMINS_SET_FROM_KEYSVALS_BLOCK"},
{A(0,0,3,0,0),	"ADMINS_SET_VAL"   		},
{A(0,1,1,0,0),	"ADMINS_VALS_BLOCK"		},

#ifdef OLD
{A(0,0,2,0,0),	"METHOD_DEL_KEY"		},
{A(0,0,2,2,0),	"METHOD_DEL_KEY_P"		},
{A(0,0,1,2,0),	"METHOD_GET_FIRST_KEY"		},
{A(0,0,2,2,0),	"METHOD_GET_KEY_P"		},
{A(0,1,2,0,0),	"METHOD_GET_KEYS_BY_PREFIX"	},
{A(0,0,2,2,0),	"METHOD_GET_NEXT_KEY"		},
{A(0,0,2,1,0),	"METHOD_GET_VAL"		},
{A(0,0,2,2,0),	"METHOD_GET_VAL_P"		},
{A(0,1,1,0,0),	"METHOD_KEYSVALS_BLOCK"		},
{A(0,1,1,0,0),	"METHOD_KEYS_BLOCK"		},
{A(1,0,1,0,0),	"METHOD_SET_FROM_BLOCK"		},
{A(1,0,1,0,0),	"METHOD_SET_FROM_KEYSVALS_BLOCK"},
{A(0,0,3,0,0),	"METHOD_SET_VAL" 		},
{A(0,1,1,0,0),	"METHOD_VALS_BLOCK"		},
#endif

{A(0,0,3,0,0),	"MUQNET_DEL_KEY"		},
{A(0,0,3,2,0),	"MUQNET_DEL_KEY_P"		},
{A(0,0,2,2,0),	"MUQNET_GET_FIRST_KEY"		},
{A(0,0,3,2,0),	"MUQNET_GET_KEY_P"		},
{A(0,1,3,0,0),	"MUQNET_GET_KEYS_BY_PREFIX"	},
{A(0,0,3,2,0),	"MUQNET_GET_NEXT_KEY"		},
{A(0,0,3,1,0),	"MUQNET_GET_VAL"		},
{A(0,0,3,2,0),	"MUQNET_GET_VAL_P"		},
{A(0,1,2,0,0),	"MUQNET_KEYSVALS_BLOCK"		},
{A(0,1,2,0,0),	"MUQNET_KEYS_BLOCK"		},
{A(1,0,2,0,0),	"MUQNET_SET_FROM_BLOCK"		},
{A(1,0,2,0,0),	"MUQNET_SET_FROM_KEYSVALS_BLOCK"},
{A(0,0,4,0,0),	"MUQNET_SET_VAL" 		},
{A(0,1,2,0,0),	"MUQNET_VALS_BLOCK"		},


{A(1,1,0,0,0),  "ABC_ABBC_BLOCK"                },
{A(0,0,0,1,0),  "ACTING_USER"                   },
{A(0,0,0,1,0),  "ACTUAL_USER"                   },
{A(0,0,1,1,0),  "ALPHANUMERIC_P"                },
{A(0,0,1,1,0),  "ALPHA_CHAR_P"                  },
{A(1,0,0,1,0),  "AREF"                          },
{A(0,0,1,1,0),  "ARRAY_P"                       },
{A(1,0,0,0,0),  "ASET"                          },
{A(0,0,1,1,0),  "ASSEMBLER_P"                   },
{A(0,0,2,0,0),  "ASSEMBLE_AFTER"                },
{A(0,0,2,0,0),  "ASSEMBLE_AFTER_CHILD"          },
{A(0,0,2,0,0),  "ASSEMBLE_ALWAYS_DO"            },
{A(0,0,2,0,0),  "ASSEMBLE_BEQ"                  },
{A(0,0,2,0,0),  "ASSEMBLE_BNE"                  },
{A(0,0,2,0,0),  "ASSEMBLE_BRA"                  },
{A(0,0,2,0,0),  "ASSEMBLE_CALL"                 },
{A(0,0,2,0,0),  "ASSEMBLE_CALLA"                },
{A(0,0,2,0,0),  "ASSEMBLE_CATCH"                },
{A(0,0,2,0,0),  "ASSEMBLE_CONSTANT"             },
{A(0,0,1,1,0),  "ASSEMBLE_CONSTANT_SLOT"        },
{A(0,0,2,0,0),  "ASSEMBLE_LABEL"                },
{A(0,0,1,1,0),  "ASSEMBLE_LABEL_GET"            },
{A(0,0,2,0,0),  "ASSEMBLE_LINE_IN_FN"           },
{A(0,0,2,0,0),  "ASSEMBLE_TAG"                  },
{A(0,0,2,0,0),  "ASSEMBLE_NTH_CONSTANT_GET"     },
{A(0,0,2,0,0),  "ASSEMBLE_VARIABLE_GET"         },
{A(0,0,2,0,0),  "ASSEMBLE_VARIABLE_SET"         },
{A(0,0,2,1,0),  "ASSEMBLE_VARIABLE_SLOT"        },
{A(1,1,0,0,0),  "BACKSLASHES_TO_HIGHBIT"	},
{A(0,0,0,0,1),  "BAD"                           },
{A(0,0,2,1,0),  "BIAS"                          },
{A(0,0,1,1,0),  "BIGNUM_P"                      },
{A(0,0,1,1,0),  "BITS"                          },
{A(1,0,0,0,0),  "BLOCK_IN_PACKAGE"              },
{A(1,0,0,1,0),  "BLOCK_MAKE_PACKAGE"            },
{A(1,0,0,1,0),  "BLOCK_MAKE_PROXY"              },
{A(0,0,1,2,0),  "BLOCK_P"                       },
{A(1,0,1,0,0),  "BLOCK_RENAME_PACKAGE"          },
{A(1,0,0,0,0),  "BLOCK_BREAK"                   },
{A(1,1,0,1,0),  "BLOCK_LENGTH"                  },
{A(0,0,1,1,0),  "BOUND_P"  	                },
{A(1,1,2,1,0),  "BRACKET_POSITION_IN_BLOCK"     },
{A(0,0,1,0,0),  "BREAK"                         },
#ifdef OLD
{A(0,0,2,2,0),  "BTREE_GET"                     },
{A(0,0,3,1,0),  "BTREE_SET"                     },
{A(0,0,2,1,0),  "BTREE_DELETE"                  },
{A(0,0,1,2,0),  "BTREE_FIRST"                   },
{A(0,0,2,2,0),  "BTREE_NEXT"                    },
{A(0,0,1,1,0),  "COPY_BTREE"                    },
#endif
#ifdef OLD
{A(0,0,1,0,10), "CALL_METHOD"                   },
#endif
{A(0,0,1,0,5),  "CALL"                          },
{A(0,0,1,1,0),  "CALLABLE_P"                    },
{A(0,0,2,1,0),  "CASELESS_EQ"                   },
{A(0,0,2,3,0),  "CASELESS_FIND_LAST_SUBSTRING_P"},
{A(0,0,3,3,0),  "CASELESS_FIND_NEXT_SUBSTRING_P"},
{A(0,0,3,3,0),  "CASELESS_FIND_PREVIOUS_SUBSTRING_P"},
{A(0,0,2,3,0),  "CASELESS_FIND_SUBSTRING_P"     },
{A(0,0,2,1,0),  "CASELESS_GE"                   },
{A(0,0,2,1,0),  "CASELESS_GT"                   },
{A(0,0,2,1,0),  "CASELESS_LE"                   },
{A(0,0,2,1,0),  "CASELESS_LT"                   },
{A(0,0,2,1,0),  "CASELESS_NE"                   },
{A(0,0,2,1,0),  "CASELESS_SUBSTRING_P"          },
{A(0,0,1,1,0),  "CHAR_P"                        },
{A(1,1,1,1,0),  "CHAR_POSITION_IN_BLOCK"        },
{A(0,0,1,1,0),  "CHAR_TO_INT"                   },
{A(1,1,0,0,0),  "CHAR_TO_INT_BLOCK"             },
{A(0,0,1,1,0),  "CHAR_TO_STRING"                },
{A(0,0,2,1,0),  "CHARS2_TO_INT"                 },
{A(0,0,4,1,0),  "CHARS4_TO_INT"                 },
{A(0,1,2,0,0),  "CHOP_STRING"                   },
{A(0,0,3,1,0),  "CLAMP"                         },
{A(0,0,0,1,0),  "CLASS"                         },
{A(1,0,0,0,0),  "CLOSE_SOCKET"                  },
{A(0,1,1,0,0),  "COMPILED_FUNCTION_BYTECODES"   },
{A(0,1,1,0,0),  "COMPILED_FUNCTION_CONSTANTS"   },
{A(0,0,1,1,0),  "COMPILED_FUNCTION_DISASSEMBLY" },
{A(0,0,1,1,0),  "COMPILED_FUNCTION_P"           },
{A(0,0,2,1,0),  "CONS"                          },
{A(0,0,1,1,0),  "CONSTANTP"                     },
{A(0,0,1,1,0),  "CONS_P"                        },
{A(0,0,1,1,0),  "CONTROLP"                      },
{A(0,0,1,1,0),  "CONTROL_CHAR_P"                },
{A(0,0,1,1,0),  "COPY"                          },
{A(0,0,0,1,0),  "COPY_CFN"                      },
{A(0,0,1,1,0),  "COPY_JOB"                      },
{A(0,0,1,1,0),  "COPY_JOB_SET"                  },
{A(0,0,1,1,0),  "COPY_SESSION"                  },
{A(0,0,1,1,0),  "COUNT_LINES_IN_STRING"         },
{A(0,0,1,1,0),  "COUNT_STACKFRAMES"             },
{A(0,0,2,1,0),  "CROSS_PRODUCT"                 },
{A(0,0,0,1,0),  "CURRENT_COMPILED_FUNCTION"     },
/* {A(1,1,0,0,0),  "CRYPT"                         }, */
{A(0,0,1,1,0),  "DATA_STACK_P"                  },
{A(0,0,1,3,0),  "DBREF_TO_INTS3"                },
{A(0,0,1,1,0),  "DBNAME_TO_INT"                 },
{A(1,1,0,1,0),  "DEBYTE"                        },
#ifndef NEW_HEADER
{A(1,1,0,6,0),  "DEBYTE_MUQNET_HEADER"          },
#else
{A(1,1,0,5,0),  "DEBYTE_MUQNET_HEADER"          },
#endif
{A(0,0,2,0,0),  "DELETE"			},
{A(1,1,1,0,0),  "DELETE_ARG_BLOCK"              },
{A(1,1,0,0,0),  "DELETE_NONCHARS_BLOCK"         },
{A(0,0,2,0,0),  "DELETE_BTH"			},
{A(0,0,2,0,0),  "DELETE_NTH"			},
{A(0,0,1,0,0),  "DELETE_PACKAGE"                },
{A(0,0,0,1,0),  "DEPTH"                         },
{A(0,0,1,1,0),  "DIGIT_CHAR_P"                  },
{A(0,0,2,1,0),  "DISTANCE"                      },
{A(1,1,0,0,0),  "DO_C_BACKSLASHES"		},
{A(1,1,0,0,0),  "DOUBLE_BLOCK"                  },
{A(0,0,1,1,0),  "DOWNCASE"                      },
{A(1,1,0,0,0),  "DOWNCASE_BLOCK"                },
{A(0,0,2,1,0),  "DOT_PRODUCT"                   },
{A(1,1,0,0,0),  "DROP_SINGLE_QUOTES"            },
{A(1,1,0,0,0),  "DROP_KEYS_BLOCK"               },
{A(1,1,0,0,0),  "DROP_VALS_BLOCK"               },
{A(1,1,0,1,0),  "DUP_ARG_BLOCK"                 },
{A(0,1,1,0,0),  "DUP_ARGS_INTO_BLOCK"           }, /*buggo, arity deduction..*/
{A(1,2,0,0,0),  "DUP_BLOCK"                 	},
{A(0,0,1,1,0),  "DUP_BTH"                       },
{A(1,1,0,1,0),  "DUP_FIRST_ARG_BLOCK"           },
{A(0,0,1,1,0),  "DUP_NTH"                       },
{A(1,1,1,1,0),  "DUP_NTH_ARG_BLOCK"             },
{A(0,0,2,3,0),	"EGCD"				},
{A(0,0,1,1,0),  "EMPTY_P"                       },
{A(1,1,0,0,0),  "ENBYTE"                        },
{A(0,0,0,0,7),  "END_BLOCK"                     },
{A(0,0,1,0,1),  "END_JOB"                       },
{A(0,0,1,1,0),  "END_P"                         },
{A(0,0,2,1,0),  "EPHEMERAL_CONS"                },
{A(0,0,1,1,0),  "EPHEMERAL_P"                   },
{A(1,0,1,0,1),  "EXEC"                          },
{A(0,0,1,1,0),  "EXPAND_C_STRING_ESCAPES"       }, /* buggo: should phase out*/
{A(0,0,1,0,0),  "EXPORT"                        },
{A(1,2,2,0,0),  "EXTRACT"                       },
{A(0,0,6,1,0),  "FBM"			        },
{A(0,0,2,3,0),  "FIND_LAST_SUBSTRING_P"         },
#ifdef OLD
{A(0,0,2,2,0),  "FIND_METHOD"                   },
{A(0,0,2,3,0),  "FIND_METHOD_P"                 },
#endif
{A(0,0,3,3,0),  "FIND_NEXT_SUBSTRING_P"         },
{A(0,0,1,1,0),  "FIND_PACKAGE"                  },
{A(0,0,3,3,0),  "FIND_PREVIOUS_SUBSTRING_P"     },
{A(0,0,2,3,0),  "FIND_SUBSTRING_P"              },
{A(1,1,1,2,0),	"FIND_SYMBOL_P"			},
{A(0,0,4,1,0),  "FINISH_ASSEMBLY"               },
{A(0,0,1,1,0),  "FIXNUM_P"                      },
{A(0,0,1,1,0),  "FLOAT_P"                       },
{A(0,0,0,0,0),  "FLUSH"                         },
{A(0,0,1,0,0),  "FLUSH_STREAM"                  },
{A(0,0,1,1,0),  "FOLK_P"               		},
{A(0,0,1,1,0),  "FUNCTION_P"                    },
{A(0,0,2,1,0),  "GAIN"                          },
{A(0,0,2,1,0),  "GAMMACORRECT"                  },
{A(0,0,2,1,0),  "GCD"                           },
{A(1,1,2,1,0),  "GED_VAL_BLOCK"                 },
{A(0,0,2,2,0),  "GENERATE_DIFFIE_HELLMAN_KEY_PAIR"},
{A(0,0,3,1,0),  "GENERATE_DIFFIE_HELLMAN_SHARED_SECRET"},
{A(1,1,2,1,0),  "GEP_VAL_BLOCK"                 },
{A(1,2,0,3,0),  "GET_ALL_ACTIVE_HANDLERS"       },
{A(0,0,0,1,0),  "GET_HERE"                      },
{A(0,0,2,1,0),  "GET_LINE_FROM_STRING"          },
{A(0,0,0,1,0),  "GET_MUQNET_IO"                 },
{A(0,0,1,7,0),  "GET_NTH_RESTART"               },
{A(0,0,1,7,0),  "GET_RESTART"                   },
{A(0,0,2,1,0),  "GET_SOCKET_CHAR_EVENT"         },
{A(0,1,2,0,0),  "GET_STACKFRAME"                },
{A(0,0,3,1,0),  "GET_SUBSTRING"                 },
{A(0,1,3,0,0),  "GET_SUBSTRING_BLOCK"           },
{A(1,1,1,1,0),  "GET_VAL_BLOCK"                 },
{A(0,0,3,1,0),  "GNOISE"                        },
{A(1,0,1,1,0),  "GLUE_STRINGS_BLOCK"            },
{A(0,0,1,0,1),  "GOTO"                          },
{A(0,0,1,1,0),  "GRAPHIC_CHAR_P"                },
{A(0,0,1,1,0),  "GUEST_P"                       },
{A(0,0,1,1,0),  "HASH"			        },
{A(0,0,1,1,0),  "HASH_P"                        },
{A(0,0,1,1,0),  "HEX_DIGIT_CHAR_P"              },
{A(0,0,1,0,0),  "IMPORT"                        },
{A(0,0,1,1,0),  "INDEX_P"                       },
{A(0,0,1,1,0),  "INTERN"                        },
{A(0,0,1,1,0),  "INT_TO_DBNAME"                 },
{A(0,0,1,1,0),  "INT_TO_CHAR"                   },
{A(1,1,0,0,0),  "INT_TO_CHAR_BLOCK"             },
{A(0,0,1,2,0),  "INT_TO_CHARS2"                 },
{A(0,0,1,4,0),  "INT_TO_CHARS4"                 },
{A(0,0,3,2,0),  "INTS3_TO_DBREF"                },
{A(0,0,1,0,0),  "IN_PACKAGE"                    },
{A(0,0,1,1,0),  "INTEGER_P"                     },
{A(1,0,1,0,0),  "INVOKE_HANDLER"                },
{A(0,0,1,0,0),	"IS_AN_ASSEMBLER"		},
{A(0,0,1,0,0),	"IS_CALLABLE"			},
{A(0,0,1,0,0),	"IS_AN_ARRAY"			},
{A(0,0,1,0,0),	"IS_A_CHAR"			},
{A(0,0,1,0,0),	"IS_A_COMPILED_FUNCTION"	},
{A(0,0,1,0,0),	"IS_A_CONS"			},
{A(0,0,1,0,0),	"IS_A_CONSTANT"			},
{A(0,0,1,0,0),	"IS_A_DATA_STACK"		},
{A(0,0,1,0,0),	"IS_A_FLOAT"			},
{A(0,0,1,0,0),	"IS_A_FUNCTION"			},
{A(0,0,1,0,0),	"IS_A_HASH"			},
{A(0,0,1,0,0),	"IS_AN_INDEX"			},
{A(0,0,1,0,0),	"IS_AN_INTEGER"			},
{A(0,0,1,0,0),	"IS_A_JOB"			},
{A(0,0,1,0,0),	"IS_A_JOB_QUEUE"		},
{A(0,0,1,0,0),	"IS_A_JOB_SET"			},
{A(0,0,1,0,0),  "IS_A_KEYWORD"             	},
{A(0,0,1,0,0),	"IS_A_LIST"			},
{A(0,0,1,0,0),	"IS_A_LOCK"			},
{A(0,0,1,0,0),	"IS_A_LOOP_STACK"		},
{A(0,0,1,0,0),	"IS_A_NUMBER"			},
{A(0,0,1,0,0),	"IS_A_PACKAGE"			},
{A(0,0,1,0,0),	"IS_A_PLAIN"			},
{A(0,0,1,0,0),	"IS_A_MESSAGE_STREAM"		},
{A(0,0,1,0,0),	"IS_A_SESSION"			},
{A(0,0,1,0,0),	"IS_A_SET"			},
{A(0,0,1,0,0),	"IS_A_SOCKET"			},
{A(0,0,1,0,0),	"IS_A_STREAM"			},
{A(0,0,1,0,0),	"IS_A_STACK"			},
{A(0,0,1,0,0),	"IS_A_STRING"			},
{A(0,0,1,0,0),	"IS_A_SYMBOL"			},
{A(0,0,1,0,0),	"IS_A_TABLE"			},
{A(0,0,1,0,0),	"IS_A_USER"			},
{A(0,0,1,0,0),	"IS_A_VECTOR"			},
{A(0,0,1,0,0),	"IS_A_VECTOR_I01"		},
{A(0,0,1,0,0),	"IS_A_VECTOR_I08"		},
{A(0,0,1,0,0),	"IS_A_VECTOR_I16"		},
{A(0,0,1,0,0),	"IS_A_VECTOR_I32"		},
{A(0,0,1,0,0),	"IS_A_VECTOR_F32"		},
{A(0,0,1,0,0),	"IS_A_VECTOR_F64"		},
{A(0,0,1,0,0),	"IS_EPHEMERAL"			},
{A(0,0,0,1,0),  "JOB"                           },
{A(0,0,1,1,0),  "JOB_IS_ALIVE_P"                },
{A(0,0,1,1,0),  "JOB_P"                         },
{A(0,0,1,1,0),  "JOB_QUEUE_P"                   },
{A(0,0,1,1,0),  "JOB_SET_P"                     },
{A(0,1,1,0,0),  "JOB_QUEUE_CONTENTS"            },
{A(0,1,1,1,0),  "JOB_QUEUES"                    },
{A(0,0,2,1,0),  "JOIN"                          },
{A(1,0,0,1,0),  "JOIN_BLOCK"                    },
{A(2,1,0,0,0),  "JOIN_BLOCKS"                   },
{A(0,0,1,1,0),  "KEYWORD_P"             	},
{A(0,0,1,0,0),  "KILL_JOB_MESSILY"             	},
{A(0,0,0,1,0),  "KITCHEN_SINKS"                 },
{A(0,0,1,1,0),  "LBRK_P"                        },
{A(0,0,2,1,0),  "LCM"                           },
{A(0,0,1,1,0),  "LENGTH2"                       },
{A(0,0,1,1,0),  "LIST_P"                        },
{A(1,0,0,0,0),  "LISTEN_ON_SOCKET"              },
{A(0,0,1,1,0),  "LOCK_P"                        },
{A(0,0,1,1,0),  "LOOP_STACK_P"                  },
{A(0,0,1,1,0),  "LOWER_CASE_P"                  },
{A(0,0,2,1,0),  "MAKE_ARRAY"                    },
{A(0,0,0,1,0),  "MAKE_ASSEMBLER"                },
{A(0,0,1,1,0),	"MAKE_BIGNUM"			},
#ifdef OLD
{A(0,0,0,1,0),  "MAKE_HASHED_BTREE"             },
{A(0,0,0,1,0),  "MAKE_SORTED_BTREE"             },
#endif
{A(0,0,0,0,8),  "MAKE_EPHEMERAL_LIST"           },
{A(0,0,2,1,0),  "MAKE_EPHEMERAL_VECTOR"         },
{A(1,0,0,1,0),  "MAKE_EPHEMERAL_VECTOR_FROM_BLOCK"},
{A(0,0,0,1,0),  "MAKE_FN"                       },
{A(1,0,1,1,0),  "MAKE_FROM_KEYSVALS_BLOCK"      },
{A(0,0,0,1,0),  "MAKE_HASH"                     },
{A(0,0,0,1,0),  "MAKE_INDEX"                    },
{A(0,0,0,1,0),  "MAKE_INDEX3D"                  },
{A(0,0,0,1,0),  "MAKE_JOB_QUEUE"                },
{A(0,0,0,1,0),  "MAKE_LOCK"                     },
{A(0,0,0,1,0),  "MAKE_MESSAGE_STREAM"           },
{A(1,0,0,2,0),	"MAKE_NUMBER"			},
{A(0,0,1,1,0),  "MAKE_PACKAGE"                  },
{A(0,0,0,1,0),  "MAKE_PLAIN"                    },
{A(0,0,0,1,0),  "MAKE_SET"                      },
{A(0,0,0,1,0),  "MAKE_SOCKET"                   },
{A(0,0,0,1,0),  "MAKE_STACK"                    },
{A(0,0,0,1,0),  "MAKE_STREAM"                   },
{A(0,0,2,1,0),  "MAKE_STRING"                   },
{A(0,0,0,1,0),	"MAKE_SYMBOL"			},
{A(1,0,1,1,0),	"MAKE_SYMBOL_BLOCK"		},
{A(0,0,2,1,0),  "MAKE_TABLE"                    },
{A(0,0,2,1,0),  "MAKE_VECTOR"                   },
{A(0,0,2,1,0),  "MAKE_VECTOR_I01"               },
{A(0,0,2,1,0),  "MAKE_VECTOR_I08"               },
{A(0,0,2,1,0),  "MAKE_VECTOR_I16"               },
{A(0,0,2,1,0),  "MAKE_VECTOR_I32"               },
{A(0,0,2,1,0),  "MAKE_VECTOR_F32"               },
{A(0,0,2,1,0),  "MAKE_VECTOR_F64"               },
{A(1,0,0,1,0),  "MAKE_VECTOR_FROM_BLOCK"        },
{A(1,0,0,1,0),  "MAKE_VECTOR_I01_FROM_BLOCK"    },
{A(1,0,0,1,0),  "MAKE_VECTOR_I08_FROM_BLOCK"    },
{A(1,0,0,1,0),  "MAKE_VECTOR_I16_FROM_BLOCK"    },
{A(1,0,0,1,0),  "MAKE_VECTOR_I32_FROM_BLOCK"    },
{A(1,0,0,1,0),  "MAKE_VECTOR_F32_FROM_BLOCK"    },
{A(1,0,0,1,0),  "MAKE_VECTOR_F64_FROM_BLOCK"    },
{A(1,1,3,2,0),  "MAYBE_WRITE_STREAM_PACKET"     },
{A(0,0,1,1,0),  "MESSAGE_STREAM_P"              },
{A(0,0,1,1,0),  "MAGNITUDE"                     },
{A(0,0,3,1,0),  "MIX"                           },
{A(0,0,2,1,0),  "NEARLY_EQUAL"                  },
{A(0,0,1,1,0),  "NORMALIZE"                     },
{A(0,0,1,1,0),  "NUMBER_P"                      },
{A(0,0,0,1,0),  "OMNIPOTENT_P"                  },
{A(1,0,0,0,0),  "OPEN_SOCKET"                   },
{A(0,0,2,3,0),  "OVER"		                },
{A(0,0,1,1,0),  "PACKAGE_P"                     },
{A(0,0,1,1,0),  "PLAIN_P"                       },
{A(1,0,0,0,0),  "POP_BLOCK"                     },
{A(0,1,0,1,0),  "POP_CATCHFRAME"                },
{A(1,1,0,1,0),  "POP_FROM_BLOCK"                },
{A(0,0,0,0,0),  "POP_EPHEMERAL_LIST"            },
{A(0,0,0,0,0),  "POP_EPHEMERAL_STRUCT"          },
{A(0,0,0,0,0),  "POP_EPHEMERAL_VECTOR"          },
{A(0,0,0,0,0),  "POP_FUN_BINDING"               },
{A(0,0,0,0,0),  "POP_HANDLERSFRAME"             },
{A(0,0,0,0,0),  "POP_LOCKFRAME"                 },
{A(1,1,1,1,0),  "POP_NTH_FROM_BLOCK"            },
{A(1,1,0,1,0),  "POP_NTH_AND_BLOCK"             },
{A(0,0,0,0,0),  "POP_PRIVS_FRAME"               },
{A(0,0,0,0,0),  "POP_RESTARTFRAME"              },
{A(0,0,0,0,0),  "POP_TAGFRAME"                  },
{A(0,0,0,0,0),  "POP_TAGTOPFRAME"               },
{A(0,0,0,0,0),  "POP_UNWINDFRAME"               },
{A(0,0,0,0,0),  "POP_USER_FRAME"                },
{A(0,0,0,0,0),  "POP_VAR_BINDING"               },
{A(1,1,0,0,0),  "POPP_FROM_BLOCK"               },
{A(1,1,1,1,0),  "POSITION_IN_BLOCK"             },
{A(1,1,1,2,0),  "POSITION_IN_STACK_P"           },
{A(1,1,0,1,0),  "POTENTIAL_NUMBER_P"       	},
{A(0,0,2,1,0),  "PRINT_TIME"                    },
{A(0,0,2,1,0),  "PROGRAM_COUNTER_TO_LINE_NUMBER"},
{A(0,0,1,6,0),  "PROXY_INFO"			},
{A(0,0,1,1,0),  "PULL"                          },
{A(0,0,1,1,0),  "PUNCTUATION_P"                 },
{A(0,0,2,0,0),  "PUSH"                          },
{A(1,0,1,0,0),  "PUSH_BLOCK"	                },
{A(0,0,2,0,0),  "PUSH_FUN_BINDING"              },
{A(1,0,0,0,0),  "PUSH_HANDLERSFRAME"            },
{A(1,1,1,0,0),  "PUSH_INTO_BLOCK"               },
{A(0,0,1,0,0),  "PUSH_LOCKFRAME"                },
{A(0,0,1,0,0),  "PUSH_LOCKFRAME_CHILD"          },
{A(1,1,2,0,0),  "PUSH_NTH_INTO_BLOCK"           },
{A(1,0,0,0,0),  "PUSH_RESTARTFRAME"             },
{A(0,0,0,0,0),  "PUSH_TAGTOPFRAME"              },
{A(0,0,0,0,0),  "PUSH_USER_ME_FRAME"            },
{A(0,0,2,0,0),  "PUSH_VAR_BINDING"              },
{A(0,0,2,0,0),  "QUEUE_JOB"                     },
{A(0,0,0,1,0),  "RANDOM"                        },
{A(0,0,4,2,0),  "RAY_HITS_SPHERE_AT"            },
{A(0,0,6,2,0),  "RAY_HITS_SPHERES_AT"           },
{A(0,0,0,1,0),  "READ_BYTE"                     },
{A(0,0,0,1,0),  "READ_CHAR"                     },
{A(0,0,0,1,0),  "READ_VALUE"                    },
{A(0,0,0,1,0),  "READ_LINE"                     },
{A(0,0,2,3,0),  "READ_NEXT_MUF_TOKEN"           },
{A(0,0,1,2,0),  "READ_STREAM"                   },
{A(0,0,1,2,0),  "READ_STREAM_BYTE"              },
{A(0,0,1,2,0),  "READ_STREAM_CHAR"              },
{A(0,0,1,3,0),  "READ_STREAM_VALUE"             },
{A(0,1,2,2,0),  "READ_STREAM_PACKET"            },
{A(1,1,2,3,0),  "READ_ANY_STREAM_PACKET"        },
{A(0,0,1,1,0),  "REMOTE_P"                      },
{A(1,0,1,1,0),  "REPLACE_SUBSTRINGS"            },
{A(0,0,1,0,0),  "RESET"                         },
{A(1,1,0,0,0),  "REVERSE_BLOCK"                 },
{A(1,1,0,0,0),  "REVERSE_KEYSVALS_BLOCK"        },
{A(0,0,1,0,0),  "REX_BEGIN"                     },
{A(0,0,0,1,0),  "REX_DONE_P"                    },
{A(0,0,0,0,0),  "REX_END"                       },
{A(0,0,1,0,0),  "REX_CANCEL_PAREN"              },
{A(0,0,1,2,0),  "REX_GET_PAREN"                 },
{A(0,0,1,0,0),  "REX_OPEN_PAREN"                },
{A(0,0,1,0,0),  "REX_CLOSE_PAREN"               },
{A(0,0,0,1,0),  "REX_GET_CURSOR"                },
{A(0,0,1,1,0),  "REX_MATCH_CHAR_CLASS"          },
{A(0,0,0,1,0),  "REX_MATCH_DOT"                 },
{A(0,0,1,1,0),  "REX_MATCH_STRING"              },
{A(0,0,0,1,0),  "REX_MATCH_WORDBOUNDARY"        },
{A(0,0,0,1,0),  "REX_MATCH_NONWORDBOUNDARY"     },
{A(0,0,0,1,0),  "REX_MATCH_WORDCHAR"            },
{A(0,0,0,1,0),  "REX_MATCH_NONWORDCHAR"         },
{A(0,0,0,1,0),  "REX_MATCH_DIGIT"               },
{A(0,0,0,1,0),  "REX_MATCH_NONDIGIT"            },
{A(0,0,0,1,0),  "REX_MATCH_NONWHITESPACE"       },
{A(0,0,1,1,0),  "REX_MATCH_PREVIOUS_MATCH"      },
{A(0,0,0,1,0),  "REX_MATCH_WHITESPACE"          },
{A(0,0,1,0,0),  "REX_SET_CURSOR"                },
{A(0,0,0,1,0),  "ROOT"                          },
{A(0,1,1,0,0),  "ROOT_ALL_ACTIVE_SOCKETS"       },
{A(1,0,0,0,0),	"ROOT_LOG_PRINT"		},
{A(0,0,1,0,0),	"ROOT_LOG_STRING"		},
{A(1,1,0,0,0),  "ROOT_MAKE_DB"		        },
{A(1,1,0,0,0),  "ROOT_MAKE_GUEST"               },
{A(0,0,1,1,0),  "ROOT_MAKE_GUEST_IN_DBFILE"     },
{A(1,1,0,0,0),  "ROOT_MAKE_USER"                },
{A(1,1,4,2,0),  "ROOT_MAYBE_WRITE_STREAM_PACKET"},

{A(1,1,0,0,0),  "ROOT_MOUNT_DATABASE_FILE"      },
{A(1,1,0,0,0),  "ROOT_UNMOUNT_DATABASE_FILE"    },
{A(1,1,0,0,0),  "ROOT_IMPORT_DB"     		},
{A(1,1,0,0,0),  "ROOT_EXPORT_DB"     		},
{A(1,1,0,0,0),  "ROOT_REPLACE_DB"    		},
{A(1,1,0,0,0),  "ROOT_REMOVE_DB"     		},

{A(0,0,2,1,0),  "ROOT_MOVE_TO_DBFILE"           },
{A(0,0,1,1,0),  "ROOT_P"                        },
{A(1,0,0,0,0),  "ROOT_POPEN_SOCKET"             },
{A(0,0,0,0,0),  "ROOT_PUSH_PRIVS_OMNIPOTENT_FRAME"},
{A(0,0,1,0,0),  "ROOT_PUSH_USER_FRAME"          },
{A(0,0,0,0,1),  "ROOT_SHUTDOWN"                 },
{A(0,0,1,0,0),  "ROOT_VALIDATE_DATABASE_FILE"   },
{A(0,0,3,0,0),  "ROOT_WRITE_STREAM"             },
{A(1,1,4,2,0),  "ROOT_WRITE_STREAM_PACKET"	},
{A(0,0,3,3,0),  "ROT"                           },
{A(1,1,1,0,0),  "ROTATE_BLOCK"                  },
{A(0,0,2,0,0),  "RPLACA"                        },
{A(0,0,2,0,0),  "RPLACD"                        },
{A(2,2,1,1,0),  "SELECT_MESSAGE_STREAMS"        },
{A(0,0,0,1,0),  "SELF"                          },
{A(0,1,1,0,0),  "SEQ_BLOCK"                     },
{A(0,0,1,1,0),  "SESSION_P"                     },
{A(0,0,2,0,0),  "SET_BTH"                       },
{A(0,0,1,0,0),  "SET_HERE"                      },
{A(1,0,0,0,0),  "SET_LOCAL_VARS"                },
{A(0,0,2,0,0),  "SET_NTH"                       },
{A(1,1,2,0,0),  "SET_NTH_IN_BLOCK"              },
{A(0,0,1,1,0),  "SET_P"		                },
{A(0,0,3,0,0),  "SET_SOCKET_CHAR_EVENT"         },
{A(0,0,2,0,0),  "SET_SYMBOL_CONSTANT"           },
{A(0,0,2,0,0),  "SET_SYMBOL_PLIST"              },
{A(0,0,2,0,0),  "SET_SYMBOL_TYPE"               },
{A(1,1,2,0,0),  "SET_VAL_BLOCK"                 },
{A(1,0,0,1,0),  "SHIFT_AND_POP"                 },
{A(1,0,0,2,0),  "SHIFT_2_AND_POP"               },
{A(1,0,0,3,0),  "SHIFT_3_AND_POP"               },
{A(1,0,0,4,0),  "SHIFT_4_AND_POP"               },
{A(1,0,0,5,0),  "SHIFT_5_AND_POP"               },
{A(1,0,0,6,0),  "SHIFT_6_AND_POP"               },
{A(1,0,0,7,0),  "SHIFT_7_AND_POP"               },
{A(1,0,0,8,0),  "SHIFT_8_AND_POP"               },
{A(1,0,0,9,0),  "SHIFT_9_AND_POP"               },
{A(1,1,0,1,0),  "SHIFT_FROM_BLOCK"              },
{A(1,1,0,0,0),  "SHIFTP_FROM_BLOCK"             },
{A(1,1,1,0,0),  "SHIFTP_N_FROM_BLOCK"           },
{A(1,0,0,0,0),  "SIGNAL"                        },
{A(0,0,1,0,1),  "SIMPLE_ERROR"                  },
{A(0,0,1,0,0),  "SLEEP_JOB"                     },
{A(0,0,3,1,0),  "SMOOTHSTEP"                    },
{A(0,0,1,1,0),  "SOCKET_P"                      },
{A(1,1,0,0,0),  "SORT_BLOCK"                    },
{A(1,1,0,0,0),  "SORT_KEYSVALS_BLOCK"           },
{A(1,1,0,0,0),  "SORT_PAIRS_BLOCK"              },
{A(0,0,2,1,0),  "SPLINE"                        },
{A(0,0,1,1,0),  "STACK_P"                       },
{A(0,0,0,0,1),  "STACK_TO_BLOCK"                },
{A(0,0,0,0,6),  "START_BLOCK"                   },
{A(0,0,2,1,0),  "STEP"                          },
{A(0,0,1,1,0),  "STREAM_P"                      },
{A(1,1,1,1,0),  "STREQ_BLOCK"	                },
{A(0,0,1,1,0),  "STRING_DOWNCASE"               },
{A(0,0,1,1,0),  "STRING_MIXEDCASE"              },
{A(0,0,1,1,0),  "STRING_P"                      },
{A(0,1,1,0,0),  "STRING_TO_CHARS"               },
{A(0,0,1,1,0),  "STRING_TO_INT"                 },
{A(0,1,1,0,0),  "STRING_TO_INTS"                },
{A(0,0,1,1,0),  "STRING_TO_KEYWORD"             },
{A(0,1,1,0,0),  "STRING_TO_WORDS"               },
{A(0,0,1,1,0),  "STRING_UPCASE"                 },
{A(0,0,2,1,0),  "SUBCLASS_OF_P"                 },
{A(0,0,2,1,0),  "SUBSTRING_P"                   },
{A(1,2,2,0,0),  "SUBBLOCK"                      },
{A(2,2,0,0,0),  "SWAP_BLOCKS"                   },
{A(0,0,0,0,0),  "SWITCH_JOB"                    },
{A(0,0,1,1,0),  "SYMBOL_NAME"                   },
{A(0,0,1,1,0),  "SYMBOL_P"                      },
{A(0,0,1,1,0),  "SYMBOL_PACKAGE"                },
{A(0,0,1,1,0),  "SYMBOL_PLIST"                  },
{A(0,0,1,1,0),  "SYMBOL_TYPE"                   },
{A(0,0,1,1,0),  "TABLE_P"                       },
{A(1,0,1,0,1),  "THROW"                         },
{A(0,0,1,1,0),  "TO_DELIMITED_STRING"           },
{A(0,0,1,1,0),  "TO_STRING"                     },
{A(0,0,1,1,0),  "TRIM_STRING"                   },
{A(0,0,0,1,0),  "TRULY_RANDOM_FIXNUM"           },
{A(0,0,1,1,0),  "TRULY_RANDOM_INTEGER"          },
{A(1,1,2,0,0),  "TR_BLOCK"	                },
{A(1,1,0,1,0),  "TSORT_BLOCK"                   },
{A(0,0,5,1,0),  "TURBULENCE"		        },
{A(0,0,1,0,0),  "UNBIND_SYMBOL"                 },
{A(0,0,1,0,0),  "UNEXPORT"                      },
{A(0,0,1,0,0),  "UNINTERN"                      },
{A(1,1,0,0,0),  "UNIQ_BLOCK"                    },
{A(1,1,0,0,0),  "UNIQ_KEYSVALS_BLOCK"           },
{A(1,1,0,0,0),  "UNIQ_PAIRS_BLOCK"              },
{A(0,1,1,0,0),  "UNPRINT_FORMAT_STRING"         },
{A(0,1,2,0,0),  "UNPRINT_STRING"                },
{A(0,0,2,0,0),  "UNPULL"                        },
{A(0,0,1,1,0),  "UNPUSH"                        },
{A(0,0,1,0,0),  "UNUSE_PACKAGE"                 },
{A(0,0,0,0,0),  "UNREAD_CHAR"                   },
{A(0,0,1,0,0),  "UNREAD_STREAM_CHAR"            },
{A(1,1,1,0,0),  "UNSHIFT_INTO_BLOCK"            },
{A(1,1,0,0,0),  "UNSORT_BLOCK"                  },
{A(0,0,1,1,0),  "UPCASE"                        },
{A(1,1,0,0,0),  "UPCASE_BLOCK"                  },
{A(0,0,1,1,0),  "UPPER_CASE_P"                  },
{A(0,0,1,1,0),  "USER_P"                        },
{A(0,0,1,0,0),  "USE_PACKAGE"                   },
{A(0,0,3,1,0),  "VCNOISE"                       },
{A(0,0,1,1,0),  "VECTOR_P"                      },
{A(0,0,1,1,0),  "VECTOR_I01_P"                  },
{A(0,0,1,1,0),  "VECTOR_I08_P"                  },
{A(0,0,1,1,0),  "VECTOR_I16_P"                  },
{A(0,0,1,1,0),  "VECTOR_I32_P"                  },
{A(0,0,1,1,0),  "VECTOR_F32_P"                  },
{A(0,0,1,1,0),  "VECTOR_F64_P"                  },
{A(0,0,3,1,0),  "VNOISE"                        },
{A(0,0,1,1,0),  "WHITESPACE_P"                  },
{A(1,0,0,1,0),  "WORDS_TO_STRING"               },
{A(0,0,3,1,0),  "WRAP_STRING"                   },
{A(0,0,1,0,0),  "WRITE_OUTPUT_STREAM"           },
{A(0,0,2,0,0),  "WRITE_STREAM"                  },
{A(1,1,3,2,0),  "WRITE_STREAM_PACKET"           },
{A(0,0,4,0,0),  "WRITE_SUBSTRING_TO_STREAM"     },

/* Integer functions: */
{A(0,0,3,1,0),	"EXPTMOD"			},

/* Floating point functions: */
{A(0,0,1,1,0),	"FLOOR"				},
{A(0,0,1,1,0),	"CEILING"			},
{A(0,0,1,1,0),	"ROUND"				},
{A(0,0,1,1,0),	"TRUNCATE"			},

{A(0,0,1,1,0),	"EXP"				},
{A(0,0,1,1,0),	"LOG"				},
{A(0,0,1,1,0),	"LOG10"				},
{A(0,0,1,1,0),	"SQRT"				},
{A(0,0,2,1,0),	"POW"				},

{A(0,0,1,1,0),	"ABS"				},
{A(0,0,1,1,0),	"FFLOOR"			},
{A(0,0,1,1,0),	"FCEILING"			},
{A(0,0,1,1,0),	"ACOS"				},
{A(0,0,1,1,0),	"ASIN"				},
{A(0,0,1,1,0),	"ATAN"				},
{A(0,0,2,1,0),	"ATAN2"				},
{A(0,0,1,1,0),	"COS"				},
{A(0,0,1,1,0),	"SIN"				},
{A(0,0,1,1,0),	"TAN"				},
{A(0,0,1,1,0),	"COSH"				},
{A(0,0,1,1,0),	"SINH"				},
{A(0,0,1,1,0),	"TANH"				},

/* Structure functions: */
{A(0,0,2,1,0),	"COPY_STRUCTURE"		},
{A(0,0,2,0,0),	"COPY_STRUCTURE_CONTENTS"	},
{A(1,0,1,1,0),	"MAKE_STRUCTURE"		},
{A(0,0,3,1,0),	"GET_NTH_STRUCTURE_SLOT"	},
{A(0,0,4,0,0),	"SET_NTH_STRUCTURE_SLOT"	},
{A(0,0,3,1,0),	"GET_NAMED_STRUCTURE_SLOT"	},
{A(0,0,3,1,0),	"SET_NAMED_STRUCTURE_SLOT"	},
{A(0,0,1,1,0),	"STRUCTURE_P"			},
{A(0,0,1,0,0),	"IS_A_STRUCTURE"		},
{A(0,0,2,1,0),	"THIS_STRUCTURE_P"		},
{A(0,0,2,0,0),	"IS_THIS_STRUCTURE"		},
{A(1,1,0,0,0),	"ERROR_IF_EPHEMERAL"		},

/* MOS-KEY functions: */
{A(0,0,1,1,0),  "GET_MOS_KEY"			},
{A(0,0,2,1,0),	"FIND_MOS_KEY_SLOT"		},
{A(0,0,10,1,0),	"MAKE_MOS_KEY"			},
{A(0,0,3,1,0),	"GET_MOS_KEY_SLOT_PROPERTY"	},
{A(0,0,4,0,0),	"SET_MOS_KEY_SLOT_PROPERTY"	},
{A(0,0,2,1,0),	"GET_MOS_KEY_PARENT"		},
{A(0,0,3,0,0),	"SET_MOS_KEY_PARENT"		},
{A(0,0,2,1,0),	"GET_MOS_KEY_ANCESTOR"		},
{A(0,0,2,2,0),	"GET_MOS_KEY_ANCESTOR_P"	},
{A(0,0,3,0,0),	"SET_MOS_KEY_ANCESTOR"		},
{A(0,0,2,2,0),	"GET_MOS_KEY_INITARG"		},
{A(0,0,4,0,0),	"SET_MOS_KEY_INITARG"		},
{A(0,0,2,1,0),	"GET_MOS_KEY_METHARG"		},
{A(0,0,3,0,0),	"SET_MOS_KEY_METHARG"		},
{A(0,0,2,1,0),	"GET_MOS_KEY_SLOTARG"		},
{A(0,0,3,0,0),	"SET_MOS_KEY_SLOTARG"		},
{A(0,0,2,4,0),	"GET_MOS_KEY_OBJECT_METHOD"	},
{A(0,0,6,0,0),	"SET_MOS_KEY_OBJECT_METHOD"	},
{A(0,0,2,3,0),	"GET_MOS_KEY_CLASS_METHOD"	},
{A(0,0,5,0,0),	"SET_MOS_KEY_CLASS_METHOD"	},
{A(0,0,4,0,0),	"COPY_MOS_KEY_SLOT"		},
{A(0,0,6,1,0),	"INSERT_MOS_KEY_OBJECT_METHOD"	},
{A(0,0,2,1,0),	"DELETE_MOS_KEY_OBJECT_METHOD"	},
{A(0,0,5,1,0),	"INSERT_MOS_KEY_CLASS_METHOD"	},
{A(0,0,2,1,0),	"DELETE_MOS_KEY_CLASS_METHOD"	},
{A(0,0,4,3,0),	"FIND_MOS_KEY_CLASS_METHOD"	},
{A(0,0,5,3,0),	"FIND_MOS_KEY_OBJECT_METHOD"	},
{A(0,1,1,0,0),  "MOS_KEY_PARENTS_BLOCK"		},
{A(0,1,1,0,0),  "MOS_KEY_PRECEDENCE_LIST_BLOCK"	},
{A(0,0,2,1,0),  "MOS_KEY_UNSHARED_SLOTS_MATCH_P"},
{A(0,0,2,0,0),  "LINK_MOS_KEY_TO_ANCESTOR"	},
{A(0,0,2,0,0),  "UNLINK_MOS_KEY_FROM_ANCESTOR"	},
{A(0,0,2,2,0),  "NEXT_MOS_KEY_LINK"		},

/* Other MOS functions: */
{A(0,0,0,1,0),	"MAKE_MOS_CLASS"		},
{A(1,1,1,1,0),	"APPLICABLE_METHOD_P"		},
{A(0,0,2,2,0),	"METHODS_MATCH_P"		},

{A(1,1,0,1,0),  "TSORT_MOS_BLOCK"		},
{A(0,0,1,1,0),	"MOS_CLASS_P"			},
{A(0,0,1,0,0),	"IS_A_MOS_CLASS"		},
{A(0,0,1,1,0),	"MOS_KEY_P"			},
{A(0,0,1,0,0),	"IS_A_MOS_KEY"			},
{A(0,0,1,1,0),	"MOS_OBJECT_P"			},
{A(0,0,1,0,0),	"IS_A_MOS_OBJECT"		},
{A(0,0,2,1,0),	"THIS_MOS_CLASS_P"		},
{A(0,0,2,0,0),	"IS_THIS_MOS_CLASS"		},

{A(0,0,4,1,0),	"MAKE_LAMBDA_LIST"		},
{A(0,0,3,1,0),	"GET_LAMBDA_SLOT_PROPERTY"	},
{A(0,0,4,0,0),	"SET_LAMBDA_SLOT_PROPERTY"	},
{A(0,0,1,1,0),	"LAMBDA_LIST_P"			},
{A(0,0,1,0,0),	"IS_A_LAMBDA_LIST"		},
{A(1,1,1,0,0),	"APPLY_LAMBDA_LIST"		},
{A(1,1,0,0,0),	"APPLY_READ_LAMBDA_LIST"	},
{A(1,1,0,0,0),	"APPLY_PRINT_LAMBDA_LIST"	},

{A(0,0,1,1,0),	"MAKE_METHOD"			},
{A(0,0,2,2,0),	"GET_METHOD_SLOT"		},
{A(0,0,4,0,0),	"SET_METHOD_SLOT"		},
{A(0,0,1,1,0),	"METHOD_P"			},
{A(0,0,1,0,0),	"IS_A_METHOD"			},

/* CommonLisp library/support functions: */
/* {A(1,1,2,2,0),	"READ_LISP_CHARS"		}, */
/* {A(1,1,0,0,0),	"READ_LISP_COMMENT"		}, */
{A(1,1,0,0,0),	"READ_LISP_STRING"		},
{A(1,1,0,0,0),	"GET_MACRO_CHARACTER"		},
{A(1,1,0,0,0),	"SET_MACRO_CHARACTER"		},
{A(0,1,1,0,0),	"EXPLODE_NUMBER"		},
{A(0,1,1,0,0),	"EXPLODE_SYMBOL"		},
{A(0,1,3,1,0),	"EXPLODE_BOUNDED_STRING_LINE"	},
{A(1,1,0,0,0),	"L_READ"			},

/* Compiler library/support functions: */
{A(1,1,0,0,0),	"UNREAD_TOKEN_CHAR"		},
{A(1,1,0,0,0),	"READ_TOKEN_CHAR"		},
{A(1,1,0,0,0),	"READ_TOKEN_CHARS"		},
{A(1,1,0,0,0),	"SCAN_LISP_STRING_TOKEN"	},
{A(1,1,0,0,0),	"SCAN_TOKEN_TO_CHAR"		},
{A(1,1,0,0,0),	"SCAN_TOKEN_TO_CHARS"		},
{A(1,1,0,0,0),	"SCAN_TOKEN_TO_CHAR_PAIR"	},
{A(1,1,0,0,0),	"SCAN_TOKEN_TO_WHITESPACE"	},
{A(1,1,0,0,0),	"SCAN_TOKEN_TO_NONWHITESPACE"	},
{A(1,1,0,0,0),	"SCAN_LISP_TOKEN"		},
{A(1,1,0,1,0),	"CLASSIFY_LISP_TOKEN"		},
{A(0,0,3,3,0),	"NEXT_MUC_TOKEN_IN_STRING"	},
{A(0,0,4,1,0),	"MUC_TOKEN_VALUE_IN_STRING"	},

/* Authentication support: */
{A(1,1,0,0,0),	"SECURE_DIGEST_BLOCK"		},
{A(1,1,0,0,0),	"SECURE_DIGEST_CHECK_BLOCK"	},
{A(1,1,0,0,0),	"SECURE_HASH_BLOCK"		},
{A(0,0,1,1,0),	"SECURE_HASH"			},
{A(0,0,1,1,0),	"SECURE_HASH_BINARY"		},
{A(0,0,1,1,0),	"SECURE_HASH_FIXNUM"		},
{A(1,1,1,0,0),	"SIGNED_DIGEST_BLOCK"		},
{A(1,1,1,0,0),	"SIGNED_DIGEST_CHECK_BLOCK"	},

/* Nonce fns for server debugging &tc: */
{A(1,1,0,0,0),  "NONCE_11000A"                  },
{A(0,0,1,0,0),  "NONCE_00100A"                  },
{A(0,0,1,1,0),  "NONCE_00110A"                  },
{A(0,0,0,1,0),  "NONCE_00010A"                  },

/* Dubious things: */
{A(0,0,1,1,0),	"PRINT"				},
{A(0,0,1,1,0),	"PRINT1"			},
{A(0,0,0,1,0),	"PRINT1_DATA_STACK"		},
{A(1,0,0,1,0),	"PRINT_STRING"			},
{A(0,0,2,0,0),	"START_MUF_COMPILE"		},
{A(0,0,2,0,0),	"ADD_MUF_SOURCE"		},
{A(0,0,1,3,0),	"CONTINUE_MUF_COMPILE"		},
{A(0,0,1,1,0),	"MAKE_MUF"			},
{A(0,0,2,0,0),	"SET_MUF_LINE_NUMBER"		},
{A(0,0,0,1,0),	"ROOT_COLLECT_GARBAGE"		},
{A(0,0,0,0,0),	"ROOT_DO_BACKUP"		},

/* The purpose of these reserved slots is to    */
/* force the OpenGL prims into separate tables  */
/* of their own, so we can switch OpenGL on or  */
/* off by changing a table pointer:             */
{A(0,0,0,0,0),	"RESERVED_00"			},
{A(0,0,0,0,0),	"RESERVED_01"			},
{A(0,0,0,0,0),	"RESERVED_02"			},
{A(0,0,0,0,0),	"RESERVED_03"			},
{A(0,0,0,0,0),	"RESERVED_04"			},
{A(0,0,0,0,0),	"RESERVED_05"			},
{A(0,0,0,0,0),	"RESERVED_06"			},
{A(0,0,0,0,0),	"RESERVED_07"			},
{A(0,0,0,0,0),	"RESERVED_08"			},
{A(0,0,0,0,0),	"RESERVED_09"			},

{A(0,0,0,0,0),	"RESERVED_10"			},
{A(0,0,0,0,0),	"RESERVED_11"			},
{A(0,0,0,0,0),	"RESERVED_12"			},
{A(0,0,0,0,0),	"RESERVED_13"			},
{A(0,0,0,0,0),	"RESERVED_14"			},
{A(0,0,0,0,0),	"RESERVED_15"			},
{A(0,0,0,0,0),	"RESERVED_16"			},
{A(0,0,0,0,0),	"RESERVED_17"			},
{A(0,0,0,0,0),	"RESERVED_18"			},
{A(0,0,0,0,0),	"RESERVED_19"			},

{A(0,0,0,0,0),	"RESERVED_20"			},
{A(0,0,0,0,0),	"RESERVED_21"			},
{A(0,0,0,0,0),	"RESERVED_22"			},
{A(0,0,0,0,0),	"RESERVED_23"			},
{A(0,0,0,0,0),	"RESERVED_24"			},
{A(0,0,0,0,0),	"RESERVED_25"			},
{A(0,0,0,0,0),	"RESERVED_26"			},
{A(0,0,0,0,0),	"RESERVED_27"			},
{A(0,0,0,0,0),	"RESERVED_28"			},
{A(0,0,0,0,0),	"RESERVED_29"			},

{A(0,0,0,0,0),	"RESERVED_30"			},
{A(0,0,0,0,0),	"RESERVED_31"			},
{A(0,0,0,0,0),	"RESERVED_32"			},
{A(0,0,0,0,0),	"RESERVED_33"			},
{A(0,0,0,0,0),	"RESERVED_34"			},
{A(0,0,0,0,0),	"RESERVED_35"			},
{A(0,0,0,0,0),	"RESERVED_36"			},
{A(0,0,0,0,0),	"RESERVED_37"			},
{A(0,0,0,0,0),	"RESERVED_38"			},
{A(0,0,0,0,0),	"RESERVED_39"			},

{A(0,0,0,0,0),	"RESERVED_40"			},
{A(0,0,0,0,0),	"RESERVED_41"			},
{A(0,0,0,0,0),	"RESERVED_42"			},
{A(0,0,0,0,0),	"RESERVED_43"			},
{A(0,0,0,0,0),	"RESERVED_44"			},
{A(0,0,0,0,0),	"RESERVED_45"			},
{A(0,0,0,0,0),	"RESERVED_46"			},
{A(0,0,0,0,0),	"RESERVED_47"			},
{A(0,0,0,0,0),	"RESERVED_48"			},
{A(0,0,0,0,0),	"RESERVED_49"			},

{A(0,0,0,0,0),	"RESERVED_50"			},
{A(0,0,0,0,0),	"RESERVED_51"			},
{A(0,0,0,0,0),	"RESERVED_52"			},
{A(0,0,0,0,0),	"RESERVED_53"			},
{A(0,0,0,0,0),	"RESERVED_54"			},
{A(0,0,0,0,0),	"RESERVED_55"			},
{A(0,0,0,0,0),	"RESERVED_56"			},
{A(0,0,0,0,0),	"RESERVED_57"			},
{A(0,0,0,0,0),	"RESERVED_58"			},
{A(0,0,0,0,0),	"RESERVED_59"			},

{A(0,0,0,0,0),	"RESERVED_60"			},
{A(0,0,0,0,0),	"RESERVED_61"			},

/* OpenGL bindings: */
#ifdef OLD
{A(0,0,1,0,0),  "GL_CLEAR"                      },
{A(0,0,1,0,0),  "GL_ENABLE"                     },
{A(0,0,1,0,0),  "GL_MATRIX_MODE"                },
#endif
{A(0,0,1,0,0),  "GL_CLEAR_INDEX"		},	/* void <- ( GLfloat c )	*/
{A(0,0,4,0,0),  "GL_CLEAR_COLOR"		},	/* void <- ( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha )	*/
{A(0,0,1,0,0),  "GL_CLEAR"		},	/* void <- ( GLbitfield mask )	*/
{A(0,0,1,0,0),  "GL_INDEX_MASK"		},	/* void <- ( GLuint mask )	*/
{A(0,0,4,0,0),  "GL_COLOR_MASK"		},	/* void <- ( GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha )	*/
{A(0,0,2,0,0),  "GL_ALPHA_FUNC"		},	/* void <- ( GLenum func, GLclampf ref )	*/
{A(0,0,2,0,0),  "GL_BLEND_FUNC"		},	/* void <- ( GLenum sfactor, GLenum dfactor )	*/
{A(0,0,1,0,0),  "GL_LOGIC_OP"		},	/* void <- ( GLenum opcode )	*/
{A(0,0,1,0,0),  "GL_CULL_FACE"		},	/* void <- ( GLenum mode )	*/
{A(0,0,1,0,0),  "GL_FRONT_FACE"		},	/* void <- ( GLenum mode )	*/
{A(0,0,1,0,0),  "GL_POINT_SIZE"		},	/* void <- ( GLfloat size )	*/
{A(0,0,1,0,0),  "GL_LINE_WIDTH"		},	/* void <- ( GLfloat width )	*/
{A(0,0,2,0,0),  "GL_LINE_STIPPLE"		},	/* void <- ( GLint factor, GLushort pattern )	*/
{A(0,0,2,0,0),  "GL_POLYGON_MODE"		},	/* void <- ( GLenum face, GLenum mode )	*/
{A(0,0,2,0,0),  "GL_POLYGON_OFFSET"	},	/* void <- ( GLfloat factor, GLfloat units )	*/
{A(0,0,1,0,0),  "GL_POLYGON_STIPPLE"	},	/* void <- ( const GLubyte *mask )	*/
{A(0,0,1,0,0),  "GL_GET_POLYGON_STIPPLE"	},	/* void <- ( GLubyte *mask )	*/
{A(0,0,1,0,0),  "GL_EDGE_FLAG"		},	/* void <- ( GLboolean flag )	*/
{A(0,0,1,0,0),  "GL_EDGE_FLAGV"		},	/* void <- ( const GLboolean *flag )	*/
{A(0,0,4,0,0),  "GL_SCISSOR"		},	/* void <- ( GLint x, GLint y, GLsizei width, GLsizei height)	*/
{A(0,0,2,0,0),  "GL_CLIP_PLANE"		},	/* void <- ( GLenum plane, const GLdouble *equation )	*/
{A(0,0,2,0,0),  "GL_GET_CLIP_PLANE"	},	/* void <- ( GLenum plane, GLdouble *equation )	*/
{A(0,0,1,0,0),  "GL_DRAW_BUFFER"		},	/* void <- ( GLenum mode )	*/
{A(0,0,1,0,0),  "GL_READ_BUFFER"		},	/* void <- ( GLenum mode )	*/
{A(0,0,1,0,0),  "GL_ENABLE"		},	/* void <- ( GLenum cap )	*/
{A(0,0,1,0,0),  "GL_DISABLE"		},	/* void <- ( GLenum cap )	*/
{A(0,0,1,0,0),  "GL_IS_ENABLED"		},	/* GLboolean <- ( GLenum cap )	*/
{A(0,0,1,0,0),  "GL_ENABLE_CLIENT_STATE"	},	/* void <- ( GLenum cap )	*/
{A(0,0,1,0,0),  "GL_DISABLE_CLIENT_STATE"	},	/* void <- ( GLenum cap )	*/
{A(0,0,1,1,0),  "GL_GET_BOOLEAN"		},
{A(0,0,1,1,0),  "GL_GET_DOUBLE"			},
{A(0,0,1,1,0),  "GL_GET_FLOAT"			},
{A(0,0,1,1,0),  "GL_GET_INTEGER"		},
{A(0,1,1,0,0),  "GL_GET_BOOLEAN_BLOCK"		},
{A(0,1,1,0,0),  "GL_GET_DOUBLE_BLOCK"		},
{A(0,1,1,0,0),  "GL_GET_FLOAT_BLOCK"		},
{A(0,1,1,0,0),  "GL_GET_INTEGER_BLOCK"		},
{A(0,0,2,0,0),  "GL_GET_BOOLEANV"		},	/* void <- ( GLenum pname, GLboolean *params )	*/
{A(0,0,2,0,0),  "GL_GET_DOUBLEV"		},	/* void <- ( GLenum pname, GLdouble *params )	*/
{A(0,0,2,0,0),  "GL_GET_FLOATV"		},	/* void <- ( GLenum pname, GLfloat *params )	*/
{A(0,0,2,0,0),  "GL_GET_INTEGERV"		},	/* void <- ( GLenum pname, GLint *params )	*/
{A(0,0,1,0,0),  "GL_PUSH_ATTRIB"		},	/* void <- ( GLbitfield mask )	*/
{A(0,0,0,0,0),  "GL_POP_ATTRIB"		},	/* void <- ( void )	*/
{A(0,0,1,0,0),  "GL_PUSH_CLIENT_ATTRIB"	},	/* void <- ( GLbitfield mask )	*/
{A(0,0,0,0,0),  "GL_POP_CLIENT_ATTRIB"	},	/* void <- ( void )	*/
{A(0,0,1,1,0),  "GL_RENDER_MODE"		},	/* GLint <- ( GLenum mode )	*/
{A(0,0,0,1,0),  "GL_GET_ERROR"		},	/* GLenum <- ( void )	*/
{A(0,0,1,1,0),  "GL_GET_STRING"		},	/* const GLubyte* <- ( GLenum name )	*/
{A(0,0,0,0,0),  "GL_FINISH"		},	/* void <- ( void )	*/
{A(0,0,0,0,0),  "GL_FLUSH"		},	/* void <- ( void )	*/
{A(0,0,2,0,0),  "GL_HINT"		},	/* void <- ( GLenum target, GLenum mode )	*/
{A(0,0,1,0,0),  "GL_CLEAR_DEPTH"		},	/* void <- ( GLclampd depth )	*/
{A(0,0,1,0,0),  "GL_DEPTH_FUNC"		},	/* void <- ( GLenum func )	*/
{A(0,0,1,0,0),  "GL_DEPTH_MASK"		},	/* void <- ( GLboolean flag )	*/
{A(0,0,2,0,0),  "GL_DEPTH_RANGE"		},	/* void <- ( GLclampd near_val, GLclampd far_val )	*/
{A(0,0,4,0,0),  "GL_CLEAR_ACCUM"		},	/* void <- ( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha )	*/
{A(0,0,2,0,0),  "GL_ACCUM"		},	/* void <- ( GLenum op, GLfloat value )	*/
{A(0,0,1,0,0),  "GL_MATRIX_MODE"		},	/* void <- ( GLenum mode )	*/
{A(0,0,6,0,0),  "GL_ORTHO"		},	/* void <- ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble near_val, GLdouble far_val )	*/
{A(0,0,6,0,0),  "GL_FRUSTUM"		},	/* void <- ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble near_val, GLdouble far_val )	*/
{A(0,0,4,0,0),  "GL_VIEWPORT"		},	/* void <- ( GLint x, GLint y, GLsizei width, GLsizei height )	*/
{A(0,0,0,0,0),  "GL_PUSH_MATRIX"		},	/* void <- ( void )	*/
{A(0,0,0,0,0),  "GL_POP_MATRIX"		},	/* void <- ( void )	*/
{A(0,0,0,0,0),  "GL_LOAD_IDENTITY"	},	/* void <- ( void )	*/
{A(0,0,1,0,0),  "GL_LOAD_MATRIXD"		},	/* void <- ( const GLdouble *m )	*/
{A(0,0,1,0,0),  "GL_LOAD_MATRIXF"		},	/* void <- ( const GLfloat *m )	*/
{A(0,0,1,0,0),  "GL_MULT_MATRIXD"		},	/* void <- ( const GLdouble *m )	*/
{A(0,0,1,0,0),  "GL_MULT_MATRIXF"		},	/* void <- ( const GLfloat *m )	*/
{A(0,0,4,0,0),  "GL_ROTATED"		},	/* void <- ( GLdouble angle, GLdouble x, GLdouble y, GLdouble z )	*/
{A(0,0,4,0,0),  "GL_ROTATEF"		},	/* void <- ( GLfloat angle, GLfloat x, GLfloat y, GLfloat z )	*/
{A(0,0,3,0,0),  "GL_SCALED"		},	/* void <- ( GLdouble x, GLdouble y, GLdouble z )	*/
{A(0,0,3,0,0),  "GL_SCALEF"		},	/* void <- ( GLfloat x, GLfloat y, GLfloat z )	*/
{A(0,0,3,0,0),  "GL_TRANSLATED"		},	/* void <- ( GLdouble x, GLdouble y, GLdouble z )	*/
{A(0,0,3,0,0),  "GL_TRANSLATEF"		},	/* void <- ( GLfloat x, GLfloat y, GLfloat z )	*/
{A(0,0,1,1,0),  "GL_IS_LIST"		},	/* GLboolean <- ( GLuint list )	*/
{A(0,0,2,0,0),  "GL_DELETE_LISTS"		},	/* void <- ( GLuint list, GLsizei range )	*/
{A(0,0,1,1,0),  "GL_GEN_LISTS"		},	/* GLuint <- ( GLsizei range )	*/
{A(0,0,2,0,0),  "GL_NEW_LIST"		},	/* void <- ( GLuint list, GLenum mode )	*/
{A(0,0,0,0,0),  "GL_END_LIST"		},	/* void <- ( void )	*/
{A(0,0,1,0,0),  "GL_CALL_LIST"		},	/* void <- ( GLuint list )	*/
{A(0,0,3,0,0),  "GL_CALL_LISTS"		},	/* void <- ( GLsizei n, GLenum type, const GLvoid *lists )	*/
{A(0,0,1,0,0),  "GL_LIST_BASE"		},	/* void <- ( GLuint base )	*/
{A(0,0,1,0,0),  "GL_BEGIN"		},	/* void <- ( GLenum mode )	*/
{A(0,0,0,0,0),  "GL_END"			},	/* void <- ( void )	*/
{A(0,0,2,0,0),  "GL_VERTEX2D"		},	/* void <- ( GLdouble x, GLdouble y )	*/
{A(0,0,2,0,0),  "GL_VERTEX2F"		},	/* void <- ( GLfloat x, GLfloat y )	*/
{A(0,0,2,0,0),  "GL_VERTEX2I"		},	/* void <- ( GLint x, GLint y )	*/
{A(0,0,2,0,0),  "GL_VERTEX2S"		},	/* void <- ( GLshort x, GLshort y )	*/
{A(0,0,3,0,0),  "GL_VERTEX3D"		},	/* void <- ( GLdouble x, GLdouble y, GLdouble z )	*/
{A(0,0,3,0,0),  "GL_VERTEX3F"		},	/* void <- ( GLfloat x, GLfloat y, GLfloat z )	*/
{A(0,0,3,0,0),  "GL_VERTEX3I"		},	/* void <- ( GLint x, GLint y, GLint z )	*/
{A(0,0,3,0,0),  "GL_VERTEX3S"		},	/* void <- ( GLshort x, GLshort y, GLshort z )	*/
{A(0,0,4,0,0),  "GL_VERTEX4D"		},	/* void <- ( GLdouble x, GLdouble y, GLdouble z, GLdouble w )	*/
{A(0,0,4,0,0),  "GL_VERTEX4F"		},	/* void <- ( GLfloat x, GLfloat y, GLfloat z, GLfloat w )	*/
{A(0,0,4,0,0),  "GL_VERTEX4I"		},	/* void <- ( GLint x, GLint y, GLint z, GLint w )	*/
{A(0,0,4,0,0),  "GL_VERTEX4S"		},	/* void <- ( GLshort x, GLshort y, GLshort z, GLshort w )	*/
{A(0,0,1,0,0),  "GL_VERTEX2DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX2FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX2IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX2SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX3DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX3FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX3IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX3SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX4DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX4FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX4IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_VERTEX4SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,3,0,0),  "GL_NORMAL3B"		},	/* void <- ( GLbyte nx, GLbyte ny, GLbyte nz )	*/
{A(0,0,3,0,0),  "GL_NORMAL3D"		},	/* void <- ( GLdouble nx, GLdouble ny, GLdouble nz )	*/
{A(0,0,3,0,0),  "GL_NORMAL3F"		},	/* void <- ( GLfloat nx, GLfloat ny, GLfloat nz )	*/
{A(0,0,3,0,0),  "GL_NORMAL3I"		},	/* void <- ( GLint nx, GLint ny, GLint nz )	*/
{A(0,0,3,0,0),  "GL_NORMAL3S"		},	/* void <- ( GLshort nx, GLshort ny, GLshort nz )	*/
{A(0,0,1,0,0),  "GL_NORMAL3BV"		},	/* void <- ( const GLbyte *v )	*/
{A(0,0,1,0,0),  "GL_NORMAL3DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_NORMAL3FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_NORMAL3IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_NORMAL3SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_INDEXD"		},	/* void <- ( GLdouble c )	*/
{A(0,0,1,0,0),  "GL_INDEXF"		},	/* void <- ( GLfloat c )	*/
{A(0,0,1,0,0),  "GL_INDEXI"		},	/* void <- ( GLint c )	*/
{A(0,0,1,0,0),  "GL_INDEXS"		},	/* void <- ( GLshort c )	*/
{A(0,0,1,0,0),  "GL_INDEXUB"		},	/* void <- ( GLubyte c )	*/
{A(0,0,1,0,0),  "GL_INDEXDV"		},	/* void <- ( const GLdouble *c )	*/
{A(0,0,1,0,0),  "GL_INDEXFV"		},	/* void <- ( const GLfloat *c )	*/
{A(0,0,1,0,0),  "GL_INDEXIV"		},	/* void <- ( const GLint *c )	*/
{A(0,0,1,0,0),  "GL_INDEXSV"		},	/* void <- ( const GLshort *c )	*/
{A(0,0,1,0,0),  "GL_INDEXUBV"		},	/* void <- ( const GLubyte *c )	*/
{A(0,0,3,0,0),  "GL_COLOR3B"		},	/* void <- ( GLbyte red, GLbyte green, GLbyte blue )	*/
{A(0,0,3,0,0),  "GL_COLOR3D"		},	/* void <- ( GLdouble red, GLdouble green, GLdouble blue )	*/
{A(0,0,3,0,0),  "GL_COLOR3F"		},	/* void <- ( GLfloat red, GLfloat green, GLfloat blue )	*/
{A(0,0,3,0,0),  "GL_COLOR3I"		},	/* void <- ( GLint red, GLint green, GLint blue )	*/
{A(0,0,3,0,0),  "GL_COLOR3S"		},	/* void <- ( GLshort red, GLshort green, GLshort blue )	*/
{A(0,0,3,0,0),  "GL_COLOR3UB"		},	/* void <- ( GLubyte red, GLubyte green, GLubyte blue )	*/
{A(0,0,3,0,0),  "GL_COLOR3UI"		},	/* void <- ( GLuint red, GLuint green, GLuint blue )	*/
{A(0,0,3,0,0),  "GL_COLOR3US"		},	/* void <- ( GLushort red, GLushort green, GLushort blue )	*/
{A(0,0,4,0,0),  "GL_COLOR4B"		},	/* void <- ( GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha )	*/
{A(0,0,4,0,0),  "GL_COLOR4D"		},	/* void <- ( GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha )	*/
{A(0,0,4,0,0),  "GL_COLOR4F"		},	/* void <- ( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha )	*/
{A(0,0,4,0,0),  "GL_COLOR4I"		},	/* void <- ( GLint red, GLint green, GLint blue, GLint alpha )	*/
{A(0,0,4,0,0),  "GL_COLOR4S"		},	/* void <- ( GLshort red, GLshort green, GLshort blue, GLshort alpha )	*/
{A(0,0,4,0,0),  "GL_COLOR4UB"		},	/* void <- ( GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha )	*/
{A(0,0,4,0,0),  "GL_COLOR4UI"		},	/* void <- ( GLuint red, GLuint green, GLuint blue, GLuint alpha )	*/
{A(0,0,4,0,0),  "GL_COLOR4US"		},	/* void <- ( GLushort red, GLushort green, GLushort blue, GLushort alpha )	*/
{A(0,0,1,0,0),  "GL_COLOR3BV"		},	/* void <- ( const GLbyte *v )	*/
{A(0,0,1,0,0),  "GL_COLOR3DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_COLOR3FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_COLOR3IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_COLOR3SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_COLOR3UBV"		},	/* void <- ( const GLubyte *v )	*/
{A(0,0,1,0,0),  "GL_COLOR3UIV"		},	/* void <- ( const GLuint *v )	*/
{A(0,0,1,0,0),  "GL_COLOR3USV"		},	/* void <- ( const GLushort *v )	*/
{A(0,0,1,0,0),  "GL_COLOR4BV"		},	/* void <- ( const GLbyte *v )	*/
{A(0,0,1,0,0),  "GL_COLOR4DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_COLOR4FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_COLOR4IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_COLOR4SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_COLOR4UBV"		},	/* void <- ( const GLubyte *v )	*/
{A(0,0,1,0,0),  "GL_COLOR4UIV"		},	/* void <- ( const GLuint *v )	*/
{A(0,0,1,0,0),  "GL_COLOR4USV"		},	/* void <- ( const GLushort *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD1D"		},	/* void <- ( GLdouble s )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD1F"		},	/* void <- ( GLfloat s )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD1I"		},	/* void <- ( GLint s )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD1S"		},	/* void <- ( GLshort s )	*/
{A(0,0,2,0,0),  "GL_TEX_COORD2D"		},	/* void <- ( GLdouble s, GLdouble t )	*/
{A(0,0,2,0,0),  "GL_TEX_COORD2F"		},	/* void <- ( GLfloat s, GLfloat t )	*/
{A(0,0,2,0,0),  "GL_TEX_COORD2I"		},	/* void <- ( GLint s, GLint t )	*/
{A(0,0,2,0,0),  "GL_TEX_COORD2S"		},	/* void <- ( GLshort s, GLshort t )	*/
{A(0,0,3,0,0),  "GL_TEX_COORD3D"		},	/* void <- ( GLdouble s, GLdouble t, GLdouble r )	*/
{A(0,0,3,0,0),  "GL_TEX_COORD3F"		},	/* void <- ( GLfloat s, GLfloat t, GLfloat r )	*/
{A(0,0,3,0,0),  "GL_TEX_COORD3I"		},	/* void <- ( GLint s, GLint t, GLint r )	*/
{A(0,0,3,0,0),  "GL_TEX_COORD3S"		},	/* void <- ( GLshort s, GLshort t, GLshort r )	*/
{A(0,0,4,0,0),  "GL_TEX_COORD4D"		},	/* void <- ( GLdouble s, GLdouble t, GLdouble r, GLdouble q )	*/
{A(0,0,4,0,0),  "GL_TEX_COORD4F"		},	/* void <- ( GLfloat s, GLfloat t, GLfloat r, GLfloat q )	*/
{A(0,0,4,0,0),  "GL_TEX_COORD4I"		},	/* void <- ( GLint s, GLint t, GLint r, GLint q )	*/
{A(0,0,4,0,0),  "GL_TEX_COORD4S"		},	/* void <- ( GLshort s, GLshort t, GLshort r, GLshort q )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD1DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD1FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD1IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD1SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD2DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD2FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD2IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD2SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD3DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD3FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD3IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD3SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD4DV"		},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD4FV"		},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD4IV"		},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_TEX_COORD4SV"		},	/* void <- ( const GLshort *v )	*/
{A(0,0,2,0,0),  "GL_RASTER_POS2D"		},	/* void <- ( GLdouble x, GLdouble y )	*/
{A(0,0,2,0,0),  "GL_RASTER_POS2F"		},	/* void <- ( GLfloat x, GLfloat y )	*/
{A(0,0,2,0,0),  "GL_RASTER_POS2I"		},	/* void <- ( GLint x, GLint y )	*/
{A(0,0,2,0,0),  "GL_RASTER_POS2S"		},	/* void <- ( GLshort x, GLshort y )	*/
{A(0,0,3,0,0),  "GL_RASTER_POS3D"		},	/* void <- ( GLdouble x, GLdouble y, GLdouble z )	*/
{A(0,0,3,0,0),  "GL_RASTER_POS3F"		},	/* void <- ( GLfloat x, GLfloat y, GLfloat z )	*/
{A(0,0,3,0,0),  "GL_RASTER_POS3I"		},	/* void <- ( GLint x, GLint y, GLint z )	*/
{A(0,0,3,0,0),  "GL_RASTER_POS3S"		},	/* void <- ( GLshort x, GLshort y, GLshort z )	*/
{A(0,0,4,0,0),  "GL_RASTER_POS4D"		},	/* void <- ( GLdouble x, GLdouble y, GLdouble z, GLdouble w )	*/
{A(0,0,4,0,0),  "GL_RASTER_POS4F"		},	/* void <- ( GLfloat x, GLfloat y, GLfloat z, GLfloat w )	*/
{A(0,0,4,0,0),  "GL_RASTER_POS4I"		},	/* void <- ( GLint x, GLint y, GLint z, GLint w )	*/
{A(0,0,4,0,0),  "GL_RASTER_POS4S"		},	/* void <- ( GLshort x, GLshort y, GLshort z, GLshort w )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS2DV"	},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS2FV"	},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS2IV"	},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS2SV"	},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS3DV"	},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS3FV"	},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS3IV"	},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS3SV"	},	/* void <- ( const GLshort *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS4DV"	},	/* void <- ( const GLdouble *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS4FV"	},	/* void <- ( const GLfloat *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS4IV"	},	/* void <- ( const GLint *v )	*/
{A(0,0,1,0,0),  "GL_RASTER_POS4SV"	},	/* void <- ( const GLshort *v )	*/
{A(0,0,4,0,0),  "GL_RECTD"		},	/* void <- ( GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2 )	*/
{A(0,0,4,0,0),  "GL_RECTF"		},	/* void <- ( GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2 )	*/
{A(0,0,4,0,0),  "GL_RECTI"		},	/* void <- ( GLint x1, GLint y1, GLint x2, GLint y2 )	*/
{A(0,0,4,0,0),  "GL_RECTS"		},	/* void <- ( GLshort x1, GLshort y1, GLshort x2, GLshort y2 )	*/
{A(0,0,2,0,0),  "GL_RECTDV"		},	/* void <- ( const GLdouble *v1, const GLdouble *v2 )	*/
{A(0,0,2,0,0),  "GL_RECTFV"		},	/* void <- ( const GLfloat *v1, const GLfloat *v2 )	*/
{A(0,0,2,0,0),  "GL_RECTIV"		},	/* void <- ( const GLint *v1, const GLint *v2 )	*/
{A(0,0,2,0,0),  "GL_RECTSV"		},	/* void <- ( const GLshort *v1, const GLshort *v2 )	*/
{A(0,0,4,0,0),  "GL_VERTEX_POINTER"	},	/* void <- ( GLint size, GLenum type, GLsizei stride, const GLvoid *ptr )	*/
{A(0,0,4,0,0),  "GL_NORMAL_POINTER"	},	/* void <- ( GLenum type, GLsizei stride, const GLvoid *ptr )	*/
{A(0,0,4,0,0),  "GL_COLOR_POINTER"	},	/* void <- ( GLint size, GLenum type, GLsizei stride, const GLvoid *ptr )	*/
{A(0,0,4,0,0),  "GL_INDEX_POINTER"	},	/* void <- ( GLenum type, GLsizei stride, const GLvoid *ptr )	*/
{A(0,0,4,0,0),  "GL_TEX_COORD_POINTER"	},	/* void <- ( GLint size, GLenum type, GLsizei stride, const GLvoid *ptr )	*/
{A(0,0,2,0,0),  "GL_EDGE_FLAG_POINTER"	},	/* void <- ( GLsizei stride, const GLboolean *ptr )	*/
{A(0,0,2,0,0),  "GL_GET_POINTERV"	},	/* void <- ( GLenum pname, void **params )	*/
{A(0,0,1,0,0),  "GL_ARRAY_ELEMENT"	},	/* void <- ( GLint i )	*/
{A(0,0,3,0,0),  "GL_DRAW_ARRAYS"	},	/* void <- ( GLenum mode, GLint first, GLsizei count )	*/
{A(0,0,4,0,0),  "GL_DRAW_ELEMENTS"	},	/* void <- ( GLenum mode, GLsizei count, GLenum type, const GLvoid *indices )	*/
{A(0,0,3,0,0),  "GL_INTERLEAVED_ARRAYS"	},	/* void <- ( GLenum format, GLsizei stride, const GLvoid *pointer )	*/
{A(0,0,1,0,0),  "GL_SHADE_MODEL"	},	/* void <- ( GLenum mode )	*/
{A(0,0,3,0,0),  "GL_LIGHTF"		},	/* void <- ( GLenum light, GLenum pname, GLfloat param )	*/
{A(0,0,3,0,0),  "GL_LIGHTI"		},	/* void <- ( GLenum light, GLenum pname, GLint param )	*/
{A(0,0,3,0,0),  "GL_LIGHTFV"		},	/* void <- ( GLenum light, GLenum pname, const GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_LIGHTIV"		},	/* void <- ( GLenum light, GLenum pname, const GLint *params )	*/
{A(0,0,3,0,0),  "GL_GET_LIGHTFV"	},	/* void <- ( GLenum light, GLenum pname, GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_GET_LIGHTIV"	},	/* void <- ( GLenum light, GLenum pname, GLint *params )	*/
{A(0,0,2,0,0),  "GL_LIGHT_MODELF"	},	/* void <- ( GLenum pname, GLfloat param )	*/
{A(0,0,2,0,0),  "GL_LIGHT_MODELI"	},	/* void <- ( GLenum pname, GLint param )	*/
{A(0,0,2,0,0),  "GL_LIGHT_MODELFV"	},	/* void <- ( GLenum pname, const GLfloat *params )	*/
{A(0,0,2,0,0),  "GL_LIGHT_MODELIV"	},	/* void <- ( GLenum pname, const GLint *params )	*/
{A(0,0,3,0,0),  "GL_MATERIALF"		},	/* void <- ( GLenum face, GLenum pname, GLfloat param )	*/
{A(0,0,3,0,0),  "GL_MATERIALI"		},	/* void <- ( GLenum face, GLenum pname, GLint param )	*/
{A(0,0,3,0,0),  "GL_MATERIALFV"		},	/* void <- ( GLenum face, GLenum pname, const GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_MATERIALIV"		},	/* void <- ( GLenum face, GLenum pname, const GLint *params )	*/
{A(0,0,3,0,0),  "GL_GET_MATERIALFV"	},	/* void <- ( GLenum face, GLenum pname, GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_GET_MATERIALIV"	},	/* void <- ( GLenum face, GLenum pname, GLint *params )	*/
{A(0,0,2,0,0),  "GL_COLOR_MATERIAL"	},	/* void <- ( GLenum face, GLenum mode )	*/
{A(0,0,2,0,0),  "GL_PIXEL_ZOOM"		},	/* void <- ( GLfloat xfactor, GLfloat yfactor )	*/
{A(0,0,2,0,0),  "GL_PIXEL_STOREF"	},	/* void <- ( GLenum pname, GLfloat param )	*/
{A(0,0,2,0,0),  "GL_PIXEL_STOREI"	},	/* void <- ( GLenum pname, GLint param )	*/
{A(0,0,2,0,0),  "GL_PIXEL_TRANSFERF"	},	/* void <- ( GLenum pname, GLfloat param )	*/
{A(0,0,2,0,0),  "GL_PIXEL_TRANSFERI"	},	/* void <- ( GLenum pname, GLint param )	*/
{A(0,0,3,0,0),  "GL_PIXEL_MAPFV"	},	/* void <- ( GLenum map, GLint mapsize, const GLfloat *values )	*/
{A(0,0,3,0,0),  "GL_PIXEL_MAPUIV"	},	/* void <- ( GLenum map, GLint mapsize, const GLuint *values )	*/
{A(0,0,3,0,0),  "GL_PIXEL_MAPUSV"	},	/* void <- ( GLenum map, GLint mapsize, const GLushort *values )	*/
{A(0,0,2,0,0),  "GL_GET_PIXEL_MAPFV"	},	/* void <- ( GLenum map, GLfloat *values )	*/
{A(0,0,2,0,0),  "GL_GET_PIXEL_MAPUIV"	},	/* void <- ( GLenum map, GLuint *values )	*/
{A(0,0,2,0,0),  "GL_GET_PIXEL_MAPUSV"	},	/* void <- ( GLenum map, GLushort *values )	*/
{A(0,0,7,0,0),  "GL_BITMAP"		},	/* void <- ( GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, const GLubyte *bitmap )	*/
{A(0,0,7,0,0),  "GL_READ_PIXELS"		},	/* void <- ( GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels )	*/
{A(0,0,5,0,0),  "GL_DRAW_PIXELS"		},	/* void <- ( GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels )	*/
{A(0,0,5,0,0),  "GL_COPY_PIXELS"		},	/* void <- ( GLint x, GLint y, GLsizei width, GLsizei height, GLenum type )	*/
{A(0,0,3,0,0),  "GL_STENCIL_FUNC"		},	/* void <- ( GLenum func, GLint ref, GLuint mask )	*/
{A(0,0,1,0,0),  "GL_STENCIL_MASK"		},	/* void <- ( GLuint mask )	*/
{A(0,0,3,0,0),  "GL_STENCIL_OP"		},	/* void <- ( GLenum fail, GLenum zfail, GLenum zpass )	*/
{A(0,0,1,0,0),  "GL_CLEAR_STENCIL"	},	/* void <- ( GLint s )	*/
{A(0,0,3,0,0),  "GL_TEX_GEND"		},	/* void <- ( GLenum coord, GLenum pname, GLdouble param )	*/
{A(0,0,3,0,0),  "GL_TEX_GENF"		},	/* void <- ( GLenum coord, GLenum pname, GLfloat param )	*/
{A(0,0,3,0,0),  "GL_TEX_GENI"		},	/* void <- ( GLenum coord, GLenum pname, GLint param )	*/
{A(0,0,3,0,0),  "GL_TEX_GENDV"		},	/* void <- ( GLenum coord, GLenum pname, const GLdouble *params )	*/
{A(0,0,3,0,0),  "GL_TEX_GENFV"		},	/* void <- ( GLenum coord, GLenum pname, const GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_TEX_GENIV"		},	/* void <- ( GLenum coord, GLenum pname, const GLint *params )	*/
{A(0,0,3,0,0),  "GL_GET_TEX_GENDV"		},	/* void <- ( GLenum coord, GLenum pname, GLdouble *params )	*/
{A(0,0,3,0,0),  "GL_GET_TEX_GENFV"		},	/* void <- ( GLenum coord, GLenum pname, GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_GET_TEX_GENIV"		},	/* void <- ( GLenum coord, GLenum pname, GLint *params )	*/
{A(0,0,3,0,0),  "GL_TEX_ENVF"		},	/* void <- ( GLenum target, GLenum pname, GLfloat param )	*/
{A(0,0,3,0,0),  "GL_TEX_ENVI"		},	/* void <- ( GLenum target, GLenum pname, GLint param )	*/
{A(0,0,3,0,0),  "GL_TEX_ENVFV"		},	/* void <- ( GLenum target, GLenum pname, const GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_TEX_ENVIV"		},	/* void <- ( GLenum target, GLenum pname, const GLint *params )	*/
{A(0,0,3,0,0),  "GL_GET_TEX_ENVFV"		},	/* void <- ( GLenum target, GLenum pname, GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_GET_TEX_ENVIV"		},	/* void <- ( GLenum target, GLenum pname, GLint *params )	*/
{A(0,0,3,0,0),  "GL_TEX_PARAMETERF"	},	/* void <- ( GLenum target, GLenum pname, GLfloat param )	*/
{A(0,0,3,0,0),  "GL_TEX_PARAMETERI"	},	/* void <- ( GLenum target, GLenum pname, GLint param )	*/
{A(0,0,3,0,0),  "GL_TEX_PARAMETERFV"	},	/* void <- ( GLenum target, GLenum pname, const GLfloat *params )	*/
{A(0,0,3,0,0),  "GL_TEX_PARAMETERIV"	},	/* void <- ( GLenum target, GLenum pname, const GLint *params )	*/
{A(0,0,3,0,0),  "GL_GET_TEX_PARAMETERFV"	},	/* void <- ( GLenum target, GLenum pname, GLfloat *params)	*/
{A(0,0,3,0,0),  "GL_GET_TEX_PARAMETERIV"	},	/* void <- ( GLenum target, GLenum pname, GLint *params )	*/
{A(0,0,4,0,0),  "GL_GET_TEX_LEVEL_PARAMETERFV"	},	/* void <- ( GLenum target, GLint level, GLenum pname, GLfloat *params )	*/
{A(0,0,4,0,0),  "GL_GET_TEX_LEVEL_PARAMETERIV"	},	/* void <- ( GLenum target, GLint level, GLenum pname, GLint *params )	*/
{A(0,0,8,0,0),  "GL_TEX_IMAGE1D"		},	/* void <- ( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLint border, GLenum format, GLenum type, const GLvoid *pixels )	*/
{A(0,0,9,0,0),  "GL_TEX_IMAGE2D"		},	/* void <- ( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels )	*/
{A(0,0,5,0,0),  "GL_GET_TEX_IMAGE"		},	/* void <- ( GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels )	*/
{A(0,0,2,0,0),  "GL_GEN_TEXTURES"		},	/* void <- ( GLsizei n, GLuint *textures )	*/
{A(0,0,2,0,0),  "GL_DELETE_TEXTURES"	},	/* void <- ( GLsizei n, const GLuint *textures)	*/
{A(0,0,2,0,0),  "GL_BIND_TEXTURE"		},	/* void <- ( GLenum target, GLuint texture )	*/
{A(0,0,3,0,0),  "GL_PRIORITIZE_TEXTURES"	},	/* void <- ( GLsizei n, const GLuint *textures, const GLclampf *priorities )	*/
{A(0,0,3,1,0),  "GL_ARE_TEXTURES_RESIDENT"	},	/* GLboolean <- ( GLsizei n, const GLuint *textures, GLboolean *residences )	*/
{A(0,0,1,1,0),  "GL_IS_TEXTURE"		},	/* GLboolean <- ( GLuint texture )	*/
{A(0,0,7,0,0),  "GL_TEX_SUB_IMAGE1D"	},	/* void <- ( GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const GLvoid *pixels )	*/
{A(0,0,9,0,0),  "GL_TEX_SUB_IMAGE2D"	},	/* void <- ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels )	*/
{A(0,0,7,0,0),  "GL_COPY_TEX_IMAGE1D"	},	/* void <- ( GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border )	*/
{A(0,0,8,0,0),  "GL_COPY_TEX_IMAGE2D"	},	/* void <- ( GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border )	*/
{A(0,0,6,0,0),  "GL_COPY_TEX_SUB_IMAGE1D"	},	/* void <- ( GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width )	*/
{A(0,0,8,0,0),  "GL_COPY_TEX_SUB_IMAGE2D"	},	/* void <- ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height )	*/
{A(0,0,6,0,0),  "GL_MAP1D"		},	/* void <- ( GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, const GLdouble *points )	*/
{A(0,0,6,0,0),  "GL_MAP1F"		},	/* void <- ( GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, const GLfloat *points )	*/
{A(0,0,10,0,0),  "GL_MAP2D"		},	/* void <- ( GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, const GLdouble *points )	*/
{A(0,0,10,0,0),  "GL_MAP2F"		},	/* void <- ( GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, const GLfloat *points )	*/
{A(0,0,3,0,0),  "GL_GET_MAPDV"		},	/* void <- ( GLenum target, GLenum query, GLdouble *v )	*/
{A(0,0,3,0,0),  "GL_GET_MAPFV"		},	/* void <- ( GLenum target, GLenum query, GLfloat *v )	*/
{A(0,0,3,0,0),  "GL_GET_MAPIV"		},	/* void <- ( GLenum target, GLenum query, GLint *v )	*/
{A(0,0,1,0,0),  "GL_EVAL_COORD1D"		},	/* void <- ( GLdouble u )	*/
{A(0,0,1,0,0),  "GL_EVAL_COORD1F"		},	/* void <- ( GLfloat u )	*/
{A(0,0,1,0,0),  "GL_EVAL_COORD1DV"	},	/* void <- ( const GLdouble *u )	*/
{A(0,0,1,0,0),  "GL_EVAL_COORD1FV"	},	/* void <- ( const GLfloat *u )	*/
{A(0,0,2,0,0),  "GL_EVAL_COORD2D"		},	/* void <- ( GLdouble u, GLdouble v )	*/
{A(0,0,2,0,0),  "GL_EVAL_COORD2F"		},	/* void <- ( GLfloat u, GLfloat v )	*/
{A(0,0,1,0,0),  "GL_EVAL_COORD2DV"	},	/* void <- ( const GLdouble *u )	*/
{A(0,0,1,0,0),  "GL_EVAL_COORD2FV"	},	/* void <- ( const GLfloat *u )	*/
{A(0,0,3,0,0),  "GL_MAP_GRID1D"		},	/* void <- ( GLint un, GLdouble u1, GLdouble u2 )	*/
{A(0,0,3,0,0),  "GL_MAP_GRID1F"		},	/* void <- ( GLint un, GLfloat u1, GLfloat u2 )	*/
{A(0,0,6,0,0),  "GL_MAP_GRID2D"		},	/* void <- ( GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2 )	*/
{A(0,0,6,0,0),  "GL_MAP_GRID2F"		},	/* void <- ( GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2 );	*/
{A(0,0,1,0,0),  "GL_EVAL_POINT1"		},	/* void <- ( GLint i )	*/
{A(0,0,2,0,0),  "GL_EVAL_POINT2"		},	/* void <- ( GLint i, GLint j )	*/
{A(0,0,3,0,0),  "GL_EVAL_MESH1"		},	/* void <- ( GLenum mode, GLint i1, GLint i2 )	*/
{A(0,0,5,0,0),  "GL_EVAL_MESH2"		},	/* void <- ( GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2 )	*/
{A(0,0,2,0,0),  "GL_FOGF"		},	/* void <- ( GLenum pname, GLfloat param )	*/
{A(0,0,2,0,0),  "GL_FOGI"		},	/* void <- ( GLenum pname, GLint param )	*/
{A(0,0,2,0,0),  "GL_FOGFV"		},	/* void <- ( GLenum pname, const GLfloat *params )	*/
{A(0,0,2,0,0),  "GL_FOGIV"		},	/* void <- ( GLenum pname, const GLint *params )	*/
{A(0,0,3,0,0),  "GL_FEEDBACK_BUFFER"	},	/* void <- ( GLsizei size, GLenum type, GLfloat *buffer )	*/
{A(0,0,1,0,0),  "GL_PASS_THROUGH"		},	/* void <- ( GLfloat token )	*/
{A(0,0,2,0,0),  "GL_SELECT_BUFFER"	},	/* void <- ( GLsizei size, GLuint *buffer )	*/
{A(0,0,0,0,0),  "GL_INIT_NAMES"		},	/* void <- ( void )	*/
{A(0,0,1,0,0),  "GL_LOAD_NAME"		},	/* void <- ( GLuint name )	*/
{A(0,0,1,0,0),  "GL_PUSH_NAME"		},	/* void <- ( GLuint name )	*/
{A(0,0,0,0,0),  "GL_POP_NAME"		},	/* void <- ( void )	*/
{A(0,0,6,0,0),  "GL_DRAW_RANGE_ELEMENTS"		},	/* void<- ( GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const GLvoid *indices )	*/
{A(0,0,10,0,0),  "GL_TEX_IMAGE3D"			},	/* void<- ( GLenum target, GLint level, GLenum internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const GLvoid *pixels )	*/
{A(0,0,11,0,0),  "GL_TEX_SUB_IMAGE3D"		},	/* void<- ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const GLvoid *pixels)	*/
{A(0,0,9,0,0),  "GL_COPY_TEX_SUB_IMAGE3D"		},	/* void<- ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height)	*/
{A(0,0,4,0,0),  "GLU_PERSPECTIVE"               },
{A(0,0,9,0,0),  "GLU_LOOKAT"                    },
{A(0,0,4,0,0),  "GLU_ORTHO2D"			},
{A(0,0,5,0,0),  "GLU_PICK_MATRIX"		},
{A(0,0,6,4,0),  "GLU_PROJECT"			},
{A(0,0,9,1,0),  "GLU_UN_PROJECT"		},
{A(0,0,1,1,0),  "GLU_ERROR_STRING"		},
{A(0,0,9,1,0),  "GLU_SCALE_IMAGE"		},
{A(0,0,6,1,0),  "GLU_BUILD1D_MIPMAPS"		},
{A(0,0,7,1,0),  "GLU_BUILD2D_MIPMAPS"		},
{A(0,0,0,1,0),  "GLU_NEW_QUADRIC"		},
{A(0,0,1,0,0),  "GLU_DELETE_QUADRIC"		},
{A(0,0,2,0,0),  "GLU_QUADRIC_DRAW_STYLE"	},
{A(0,0,2,0,0),  "GLU_QUADRIC_ORIENTATION"	},
{A(0,0,2,0,0),  "GLU_QUADRIC_NORMALS"		},
{A(0,0,2,0,0),  "GLU_QUADRIC_TEXTURE"		},
{A(0,0,3,0,0),  "GLU_QUADRIC_CALLBACK"		},
{A(0,0,6,0,0),  "GLU_CYLINDER"			},
{A(0,0,4,0,0),  "GLU_SPHERE"			},
{A(0,0,5,0,0),  "GLU_DISK"			},
{A(0,0,7,0,0),  "GLU_PARTIAL_DISK"		},
{A(0,0,0,1,0),  "GLU_NEW_NURBS_RENDERER"	},
{A(0,0,1,0,0),  "GLU_DELETE_NURBS_RENDERER"	},
{A(0,0,4,0,0),  "GLU_LOAD_SAMPLING_MATRICES"	},
{A(0,0,3,0,0),  "GLU_NURBS_PROPERTY"		},
{A(0,0,2,1,0),  "GLU_GET_NURBS_PROPERTY"	},
{A(0,0,1,0,0),  "GLU_BEGIN_CURVE"		},
{A(0,0,1,0,0),  "GLU_END_CURVE"			},
{A(0,0,7,0,0),  "GLU_NURBS_CURVE"		},
{A(0,0,1,0,0),  "GLU_BEGIN_SURFACE"		},
{A(0,0,1,0,0),  "GLU_END_SURFACE"		},
{A(0,0,11,0,0), "GLU_NURBS_SURFACE"		},
{A(0,0,1,0,0),  "GLU_BEGIN_TRIM"		},
{A(0,0,1,0,0),  "GLU_END_TRIM"			},
{A(0,0,5,0,0),  "GLU_PWL_CURVE"			},
{A(0,0,3,0,0),  "GLU_NURBS_CALLBACK"		},
{A(0,0,0,1,0),  "GLU_NEW_TESS"			},
{A(0,0,3,0,0),  "GLU_TESS_CALLBACK"		},
{A(0,0,1,0,0),  "GLU_DELETE_TESS"		},
{A(0,0,1,0,0),  "GLU_BEGIN_POLYGON"		},
{A(0,0,1,0,0),  "GLU_END_POLYGON"		},
{A(0,0,2,0,0),  "GLU_NEXT_CONTOUR"		},
{A(0,0,3,0,0),  "GLU_TESS_VERTEX"		},
{A(0,0,1,1,0),  "GLU_GET_STRING"		},
{A(0,0,1,1,0),  "GLUT_CREATE_WINDOW"            },
{A(0,0,1,0,0),  "GLUT_INIT_DISPLAY_MODE"        },
{A(0,0,0,0,0),  "GLUT_SWAP_BUFFERS"             },
{A(0,0,1,0,0),  "GLUT_INIT_DISPLAY_STRING"      },
{A(0,0,2,0,0),  "GLUT_INIT_WINDOW_POSITION"     },
{A(0,0,2,0,0),  "GLUT_INIT_WINDOW_SIZE"         },
{A(0,0,5,1,0),  "GLUT_CREATE_SUB_WINDOW"        },
{A(0,0,1,0,0),  "GLUT_DESTROY_WINDOW"           },
{A(0,0,0,0,0),  "GLUT_POST_REDISPLAY"           },
{A(0,0,1,0,0),  "GLUT_POST_WINDOW_REDISPLAY"    },
{A(0,0,0,1,0),  "GLUT_GET_WINDOW"               },
{A(0,0,1,0,0),  "GLUT_SET_WINDOW"               },
{A(0,0,1,0,0),  "GLUT_SET_WINDOW_TITLE"         },
{A(0,0,1,0,0),  "GLUT_SET_ICON_TITLE"           },
{A(0,0,2,0,0),  "GLUT_POSITION_WINDOW"          },
{A(0,0,2,0,0),  "GLUT_RESHAPE_WINDOW"           },
{A(0,0,0,0,0),  "GLUT_POP_WINDOW"               },
{A(0,0,0,0,0),  "GLUT_PUSH_WINDOW"              },
{A(0,0,0,0,0),  "GLUT_ICONIFY_WINDOW"           },
{A(0,0,0,0,0),  "GLUT_SHOW_WINDOW"              },
{A(0,0,0,0,0),  "GLUT_HIDE_WINDOW"              },
{A(0,0,0,0,0),  "GLUT_FULL_SCREEN"              },
{A(0,0,1,0,0),  "GLUT_SET_CURSOR"               },
{A(0,0,2,0,0),  "GLUT_WARP_POINTER"             },
{A(0,0,0,0,0),  "GLUT_ESTABLISH_OVERLAY"        },
{A(0,0,0,0,0),  "GLUT_REMOVE_OVERLAY"           },
{A(0,0,1,0,0),  "GLUT_USE_LAYER"                },
{A(0,0,0,0,0),  "GLUT_POST_OVERLAY_REDISPLAY"   },
{A(0,0,1,0,0),  "GLUT_WINDOW_OVERLAY_REDISPLAY" },
{A(0,0,0,0,0),  "GLUT_SHOW_OVERLAY"             },
{A(0,0,0,0,0),  "GLUT_HIDE_OVERLAY"             },
{A(0,0,4,0,0),  "GLUT_SET_COLOR"                },
{A(0,0,2,1,0),  "GLUT_GET_COLOR"                },
{A(0,0,1,0,0),  "GLUT_COPY_COLORMAP"            },
{A(0,0,1,1,0),  "GLUT_GET"                      },
{A(0,0,1,1,0),  "GLUT_DEVICE_GET"               },
{A(0,0,1,1,0),  "GLUT_EXTENSION_SUPPORTED"      },
{A(0,0,0,1,0),  "GLUT_GET_MODIFIERS"            },
{A(0,0,1,1,0),  "GLUT_LAYER_GET"                },

{A(0,0,2,0,0),  "GLUT_BITMAP_CHARACTER"         },
{A(0,0,2,1,0),  "GLUT_BITMAP_WIDTH"             },
{A(0,0,2,0,0),  "GLUT_STROKE_CHARACTER"         },
{A(0,0,2,1,0),  "GLUT_STROKE_WIDTH"             },
{A(0,0,2,1,0),  "GLUT_BITMAP_LENGTH"            },
{A(0,0,2,1,0),  "GLUT_STROKE_LENGTH"            },

{A(0,0,3,0,0),  "GLUT_WIRE_SPHERE"              },
{A(0,0,3,0,0),  "GLUT_SOLID_SPHERE"             },
{A(0,0,4,0,0),  "GLUT_WIRE_CONE"                },
{A(0,0,4,0,0),  "GLUT_SOLID_CONE"               },
{A(0,0,1,0,0),  "GLUT_WIRE_CUBE"                },
{A(0,0,1,0,0),  "GLUT_SOLID_CUBE"               },
{A(0,0,4,0,0),  "GLUT_WIRE_TORUS"               },
{A(0,0,4,0,0),  "GLUT_SOLID_TORUS"              },
{A(0,0,0,0,0),  "GLUT_WIRE_DODECAHEDRON"        },
{A(0,0,0,0,0),  "GLUT_SOLID_DODECAHEDRON"       },
{A(0,0,1,0,0),  "GLUT_WIRE_TEAPOT"              },
{A(0,0,1,0,0),  "GLUT_SOLID_TEAPOT"             },
{A(0,0,0,0,0),  "GLUT_WIRE_OCTAHEDRON"          },
{A(0,0,0,0,0),  "GLUT_SOLID_OCTAHEDRON"         },
{A(0,0,0,0,0),  "GLUT_WIRE_TETRAHEDRON"         },
{A(0,0,0,0,0),  "GLUT_SOLID_TETRAHEDRON"        },
{A(0,0,0,0,0),  "GLUT_WIRE_ICOSAHEDRON"         },
{A(0,0,0,0,0),  "GLUT_SOLID_ICOSAHEDRON"        },
{A(0,0,1,1,0),  "GLUT_VIDEO_RESIZE_GET"         },
{A(0,0,0,1,0),  "GLUT_SETUP_VIDEO_RESIZING"     },
{A(0,0,0,0,0),  "GLUT_STOP_VIDEO_RESIZING"      },
{A(0,0,4,0,0),  "GLUT_VIDEO_RESIZE"             },
{A(0,0,4,0,0),  "GLUT_VIDEO_PAN"                },
{A(0,0,1,0,0),  "GLUT_IGNORE_KEY_REPEAT"        },
{A(0,0,1,0,0),  "GLUT_SET_KEY_REPEAT"           },
{A(0,0,1,0,0),  "GLUT_GAME_MODE_STRING"         },
{A(0,0,0,1,0),  "GLUT_ENTER_GAME_MODE"          },
{A(0,0,0,0,0),  "GLUT_LEAVE_GAME_MODE"          },
{A(0,0,1,1,0),  "GLUT_GAME_MODE_GET"            },

{A(0,0,0,0,0),  "GLUT_RESERVED_00"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_01"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_02"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_03"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_04"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_05"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_06"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_07"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_08"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_09"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_10"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_11"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_12"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_13"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_14"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_15"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_16"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_17"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_18"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_19"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_20"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_21"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_22"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_23"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_24"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_25"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_26"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_27"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_28"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_29"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_30"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_31"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_32"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_33"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_34"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_35"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_36"		},
{A(0,0,0,0,0),  "GLUT_RESERVED_37"		},

{A(1,0,0,0,0),  "GLUQ_DRAW_QUADRUPED"           },
{A(1,0,0,0,0),  "GLUQ_DRAW_BIPED"               },
{A(0,0,0,0,0),  "GLUQ_DRAW_FACE"                },
{A(1,0,0,0,0),  "GLUQ_DRAW_TERRAIN"             },
{A(0,0,0,1,0),  "GLUQ_EVENTS_PENDING"           },
{A(0,1,0,0,0),  "GLUQ_EVENT"			},
{A(1,0,0,0,0),  "GLUQ_QUEUE_EVENT"		},
{A(0,1,0,0,0),  "GLUQ_MOUSE_POSITION"		},

/* Temporary scaffolding: */


/* CLX functions: */
/* Commented out because nobody is working */
/* on completing the X support:            */
#ifdef MAYBE_SOMEDAY
{A(0,0,1,0,0),  "CLOSE_DISPLAY"                 },
{A(0,0,1,1,0),  "COLORMAP_P"                    },
{A(0,0,1,1,0),  "COLOR_P"                       },
{A(1,0,0,1,0),  "CREATE_GCONTEXT"               },
{A(1,0,0,1,0),  "CREATE_WINDOW"                 },
{A(0,0,1,1,0),  "CURSOR_P"                      },
{A(0,0,1,0,0),  "DESTROY_SUBWINDOWS"            },
{A(0,0,1,0,0),  "DESTROY_WINDOW"                },
{A(0,0,1,1,0),  "DISPLAY_P"                     },
{A(0,1,1,0,0),  "DISPLAY_ROOTS"                 },
{A(0,0,1,1,0),  "DRAWABLE_BORDER_WIDTH"         },
{A(0,0,1,1,0),  "DRAWABLE_DEPTH"                },
{A(0,0,1,1,0),  "DRAWABLE_DISPLAY"              },
{A(0,0,1,1,0),  "DRAWABLE_HEIGHT"               },
{A(0,0,1,1,0),  "DRAWABLE_WIDTH"                },
{A(0,0,1,1,0),  "DRAWABLE_X"                    },
{A(0,0,1,1,0),  "DRAWABLE_Y"                    },
{A(1,0,0,2,0),  "DRAW_GLYPHS"	                },
{A(1,0,0,2,0),  "DRAW_IMAGE_GLYPHS"             },
{A(0,0,1,0,0),  "FLUSH_DISPLAY"                 },
{A(0,0,1,1,0),  "FONT_ASCENT"                   },
{A(0,0,1,1,0),  "FONT_DESCENT"                  },
{A(0,0,1,1,0),  "FONT_P"                        },
{A(0,0,1,1,0),  "GCONTEXT_BACKGROUND"           },
{A(0,0,1,1,0),  "GCONTEXT_FONT"                 },
{A(0,0,1,1,0),  "GCONTEXT_FOREGROUND"           },
{A(0,0,1,1,0),  "GCONTEXT_P"                    },
{A(1,0,0,1,0),  "MAKE_EVENT_MASK"               },
{A(0,0,1,0,0),  "MAP_SUBWINDOWS"                },
{A(0,0,1,0,0),  "MAP_WINDOW"                    },
{A(0,0,1,1,0),  "OPEN_DISPLAY"                  },
{A(0,0,2,1,0),  "OPEN_FONT"                     },
{A(0,0,1,1,0),  "PIXMAP_P"                      },
{A(0,0,1,8,0),  "QUERY_POINTER"                 },
{A(0,0,1,1,0),  "SCREEN_BLACK_PIXEL"            },
{A(0,0,1,1,0),  "SCREEN_P"                      },
{A(0,0,1,1,0),  "SCREEN_ROOT"                   },
{A(0,0,1,1,0),  "SCREEN_WHITE_PIXEL"            },
{A(1,0,0,8,0),  "TEXT_EXTENTS"                  },
{A(0,0,1,0,0),  "UNMAP_SUBWINDOWS"              },
{A(0,0,1,0,0),  "UNMAP_WINDOW"                  },
{A(0,0,1,1,0),  "WINDOW_P"                      },
#endif

/* Strictly temporary things: */
#ifndef SOMETIMES_USEFUL
{A(0,0,1,0,0),	"DEBUG_PRINT"			},
{A(0,0,0,0,0),	"DIL_TEST"			},
#endif


	/* Prims specific to selected emulation(s): */
#define  MODULES_JOBBUILD_C_SLOW_PRIMS
#include "Modules.h"
#undef   MODULES_JOBBUILD_C_SLOW_PRIMS

  /**********************************************************************/
  /*-  End-of-array sentinel.						*/
  /**********************************************************************/
{0,NULL}
};
typedef struct Slow_Rec A_Slow;
typedef struct Slow_Rec*  Slow;

/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Names for our tempfiles: */
#define JOB_DECL_TMPFILE "##jb-decl##.tmp"
#define JOB_TABL_TMPFILE "##jb-tabl##.tmp"
#define JOB_CODE_TMPFILE "##jb-code##.tmp"

/* Name file final output file: */
#define JOB_OUTPUT_FILE "jobprims.c"

/* Buffer size to use when copying tempfiles:	*/
#define JOB_BUFSIZE (4096)

/* Stackframe types.  Good things to do when	*/
/* adding a new stackframe type:		*/
/*						*/
/* -> patch write_jobprims_h() to pass the	*/
/*    new definition to output.			*/
/*						*/
/* -> document new stackframe in info/muqimp.t	*/
/*						*/
/* -> patch c/job.t:job_P_Return() to understand*/
/*    the new frame type.			*/
/*						*/
/* -> patch c/job.t:throw_set_up_jSl_and_jSv()	*/
/*    to understand the new frame type.		*/
/*						*/
/* -> patch c/job.t:job_throw() to understand	*/
/*    the new frame type.			*/

#define JOB_STACKFRAME_NULL          (0x161)
#define JOB_STACKFRAME_FUN_BIND      (0x162)
#define JOB_STACKFRAME_VAR_BIND      (0x163)
#define JOB_STACKFRAME_NORMAL        (0x164)
#define JOB_STACKFRAME_PROTECT       (0x165)
#define JOB_STACKFRAME_PROTECT_CHILD (0x166)
#define JOB_STACKFRAME_CATCH         (0x167)
#define JOB_STACKFRAME_THROW         (0x168)
#define JOB_STACKFRAME_RETURN        (0x169)
#define JOB_STACKFRAME_JUMP          (0x16a)
#define JOB_STACKFRAME_VANILLA       (0x16b)
#define JOB_STACKFRAME_THUNK         (0x16c)
#define JOB_STACKFRAME_SIGNAL        (0x16d)
#define JOB_STACKFRAME_LOCK          (0x16e)
#define JOB_STACKFRAME_LOCK_CHILD    (0x16f)
#define JOB_STACKFRAME_USER          (0x170)
#define JOB_STACKFRAME_PRIVS         (0x171)
#define JOB_STACKFRAME_TAG           (0x172)
#define JOB_STACKFRAME_GOTO          (0x173)
#define JOB_STACKFRAME_TAGTOP        (0x174)
#define JOB_STACKFRAME_RESTART       (0x175)
#define JOB_STACKFRAME_HANDLERS      (0x176)
#define JOB_STACKFRAME_BUSY_HANDLERS (0x177)
#define JOB_STACKFRAME_HANDLING      (0x178)
#define JOB_STACKFRAME_TMP_USER      (0x179)
#define JOB_STACKFRAME_ENDJOB        (0x17a)
#define JOB_STACKFRAME_EXEC          (0x17b)
#define JOB_STACKFRAME_EPHEMERAL_LIST   (0x17c)
#define JOB_STACKFRAME_EPHEMERAL_STRUCT (0x17d)
#define JOB_STACKFRAME_EPHEMERAL_VECTOR (0x17e)

#ifndef JOB_FATAL
#define JOB_FATAL job_fatal
static void
job_fatal(
    Vm_Chr *format, ...
) {
    /* First, sprintf the error message */
    /* into a temporary buffer:         */
    va_list args;
    Vm_Chr buffer[4096];
    va_start(args,   format);
    vsprintf(buffer, format, args);
    va_end(args);
    strcat(buffer,"\n");
    fputs(buffer,stderr);

    abort();
}
#endif

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* During generate() we have three files open, one for	*/
/* static declarations, one for the table proper, one	*/
/* for actual code.  These can later be concatenated	*/
/* to produce compilable files:				*/
static FILE* fd_decl;
static FILE* fd_tabl;
static FILE* fd_code;

static int prims_built    =  0       ;



/* prim_table[] is used only to assign unique number to	*/
/* each prim name, which gets written out eventually    */
/* as the JOB_OP_* set of #defines.  It just contains   */
/* the name of each primitive operation defined.        */

/* fast_table[] maps a 6-bit bytecode from the code	*/
/* being executed, plus the types of the top two stack  */
/* arguments, plus a bit from the current instruction   */
/* count, into the name of the function which should be */
/* executed under those condition.                      */

/* slow_table0[] maps an 8-bit secondary opcode read    */
/* from the codestream (following a 0 prefix byte)	*/
/* into the name of the function which should be	*/
/* executed. No typechecking is done on stack args.	*/

/* slow_table1[] through slow_tableF[]			*/
/* are similar maps for the 0x01 -> 0x0F prefix bytes.	*/

static char* fast_table[  JOB_FAST_TABLE_MAX ];
static char* slow_table0[ JOB_SLOW_TABLE_MAX ];
static char* slow_table1[ JOB_SLOW_TABLE_MAX ];
static char* slow_table2[ JOB_SLOW_TABLE_MAX ];
static char* slow_table3[ JOB_SLOW_TABLE_MAX ];
static char* slow_table4[ JOB_SLOW_TABLE_MAX ];
static char* slow_table5[ JOB_SLOW_TABLE_MAX ];
static char* slow_table6[ JOB_SLOW_TABLE_MAX ];
static char* slow_table7[ JOB_SLOW_TABLE_MAX ];
static char* slow_table8[ JOB_SLOW_TABLE_MAX ];
static char* slow_table9[ JOB_SLOW_TABLE_MAX ];
static char* slow_tableA[ JOB_SLOW_TABLE_MAX ];
static char* slow_tableB[ JOB_SLOW_TABLE_MAX ];
static char* slow_tableC[ JOB_SLOW_TABLE_MAX ];
static char* slow_tableD[ JOB_SLOW_TABLE_MAX ];
static char* slow_tableE[ JOB_SLOW_TABLE_MAX ];
static char* slow_tableF[ JOB_SLOW_TABLE_MAX ];
static char* prim_table[  JOB_PRIM_TABLE_MAX ];

/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void     check_constraints( void );
static void     code_table_dump( void );
static void     type_table_dump( void );
static unsigned assign_fast_code(char*,Vm_Int,char,char,char,Vm_Int,Vm_Int,Vm_Int,Vm_Int,Vm_Obj);
static unsigned assign_slow_code(char*,Vm_Int,Vm_Obj);
static unsigned assign_prim_code(Vm_Chr*);
static void     code_table_sort( void );
static void     fast_table_initialize( void );
static void     fast_table_entry(unsigned,char,char,char*);
static void     fast_table_dump(void);
static void     slow_table_initialize( void );
static void     slow_table_dump(void);
static FILE*    open_file( char*, char* );
static void     open_temp_files( void );
static void     concatenate_temp_files( void );
static char*    str_dup( char* );
static void     summarize_run( void );
static void     write_headers_to_temp_files( void );
static void     write_contents_to_temp_files( void );
static void     write_trailers_to_temp_files( void );
static void     write_jobprims_h( void );
   

/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    main								*/
/************************************************************************/

int
main(
    int    arg_c,
    char** arg_v
) {
    open_temp_files();
    write_headers_to_temp_files();
    write_contents_to_temp_files();
    write_trailers_to_temp_files();
    write_jobprims_h();
    concatenate_temp_files();
    check_constraints();
    summarize_run();

    exit(0);
}

/************************************************************************/
/*-    --- Static fns: main phases ---					*/
/************************************************************************/

/************************************************************************/
/*-    write_headers_to_temp_files -- 					*/
/************************************************************************/

/************************************************************************/
/*-    write_decl_header						*/
/************************************************************************/

static void
write_decl_header( void ) {
    char  buf[ JOB_BUFSIZE ];

    /* Open self so we can copy copyright info: */
    FILE* fd = open_file("jobbuild.c","r");

    /* Skip first line of self (title): */
    fgets( buf, JOB_BUFSIZE, fd );

    /* Substitute more appropriate title: */

    fputs("/*-    jobprims.c -- Code generated by jobbuild.c for job.c		*/\n", fd_decl );

    /* Copy title and copyright sections: */
    {   Vm_Int sections_left = 2;
	do {
	    char* ok = fgets( buf, JOB_BUFSIZE, fd );
	    if (!ok) JOB_FATAL ("write_decl_header: internal err");
	    fputs( buf, fd_decl );
	    if (STRCMP(buf, == ,"\n"))   --sections_left;
	} while (sections_left);
    }
    fclose(fd);



    /* Open #includes section: */

    fputs("/*-    #includes                                            		*/\n", fd_decl );

    /* Write #includes section: */
    fputc('\n'		             , fd_decl );
    fputs("#include \"All.h\"\n"     , fd_decl );
    fputs("#include \"jobprims.h\"\n", fd_decl );
    fputs("#include \"job.h\"\n"     , fd_decl );

    /* Close #includes section: */
    fputs("\n\n", fd_decl );



    /* Open #defines section: */

    fputs("/*-    #defines                                            		*/\n", fd_decl );


    /* Close #defines section: */
    fputs("\n\n", fd_decl );



    /* Open statics section: */

    fputs("/*-    --- statics ---                                      		*/\n\n", fd_decl );

}

/************************************************************************/
/*-    write_tabl_header						*/
/************************************************************************/

static void
write_tabl_header( void ) {

    /* Open globals section: */

    fputs("/*-    --- globals ---                                      		*/\n", fd_tabl );

}

/************************************************************************/
/*-    write_code_header						*/
/************************************************************************/

static void
write_code_header( void ) {

    /* Open static fnss section: */
    fputs("/*-    --- Static fns ---                                   		*/\n", fd_code );

    /* Special hack for OpenGL table indirection pointers: */
    fprintf(fd_code,"\nextern Job_Slow_Prim * job_OpenGL_Table3;\n");
    fprintf(fd_code,"\nextern Job_Slow_Prim * job_OpenGL_Table4;\n");
}


/************************************************************************/
/*-    write_headers_to_temp_files					*/
/************************************************************************/

static void
write_headers_to_temp_files( void ) {

    write_decl_header();
    write_tabl_header();
    write_code_header();

}

/************************************************************************/
/*-    write_contents_to_temp_files --					*/
/************************************************************************/

/************************************************************************/
/*-    fast_prims_write							*/
/************************************************************************/

/************************************************************************/
/*-    ux_expr -- Return string to read unsigned index via pc.		*/
/************************************************************************/

/* If you change [su]x_expr, you'll want to change get_offset()		*/
/* in job.c accordingly, to keep everything synched shipshape.		*/

char*
ux_expr(
    Vm_Int x
) {
    switch (x) {
    case 0:
	JOB_FATAL ("ux_expr: attempt to build 0-byte index field.");
    case 1:
	return "((Vm_Uch*)jSpc)[1]";
    case 2:
	return "(jSpc[2] << VM_BYTEBITS) + jSpc[1]";
    case 3:
	return "(jSpc[3] << (2*VM_BYTEBITS)) + (jSpc[2] << VM_BYTEBITS) + jSpc[1]";
    default:
	JOB_FATAL ("ux_expr: internal error.");
    }
    return "";	/* Pacify gcc -Wall. */
}

/************************************************************************/
/*-    sx_expr -- Return string to read   signed index via pc.		*/
/************************************************************************/

char*
sx_expr(
    Vm_Int x
) {
    switch (x) {
    case 0:
	JOB_FATAL ("sx_expr: attempt to build 0-byte index field.");
    case 1:
	return "(((Vm_Sch*)jSpc)[1])";
    case 2:
	return "((Vm_Sht)((jSpc[2] << VM_BYTEBITS) + jSpc[1]))";
    case 3:
	/* Shifts are 24,16,8,8 bits when Vm_Int is 32 bits: */
 	return "(((Vm_Int)((jSpc[3] << VM_INTBITS-VM_BYTEBITS) + (jSpc[2] << VM_INTBITS-2*VM_BYTEBITS) + (jSpc[1] << VM_INTBITS-3*VM_BYTEBITS))) >> VM_INTBITS-3*VM_BYTEBITS)";
    default:
	JOB_FATAL ("sx_expr: internal error.");
    }
    return "";	/* Pacify gcc -Wall. */
}

/************************************************************************/
/*-    fast_prim_write							*/
/************************************************************************/

static char*
fast_prim_write(
    Fast s,
    Vm_Int  x,			/* Size-in-bytes for indices.		*/
    char l0,char l1,char l2,	/* Loc of out/in1/in2 args else '_'.	*/
            char t1,char t2	/* Typ of     in1/in2 args else '_'.	*/
) {
    static char fn_name[ 128 ];
    char* l0off = "l0off";
    char* l1off = "l1off";
    char* l2off = "l2off";
    char  t0    = 'i';
    Vm_Int   use_assnop = FALSE;
    Vm_Int   args = 0;
    Vm_Int   instruction_len = x+1;
    if (l0 != '_')  ++args;
    if (l1 != '_')  ++args;
    if (l2 != '_')  ++args;
    ++ prims_built      ;

    /* Generate name for prim fn: */
    sprintf( fn_name, "job_%s_%c%c%c_%c%c%d", s->a_name, l0,l1,l2, t1,t2, (int)x );

    /* Compute output type: */
    if (*s->t0=='a') {
        t0                              = 'i';
        if (t1 == 'r' || t2 == 'r')  t0 = 'r';
    }


    /* Write fn declaration. AIX cc gets confused */
    /* if we declare these fns Job_Fast_Prim, so: */
    fprintf(fd_decl,
	"static void %s( JOB_PRIM_ARGS_TYPED );\n",
	fn_name
    );



    /* Write fn header: */

    fprintf(fd_code, "/*-    %s\t\t\t\t\t\t\t*/\n" , fn_name );
    fprintf(fd_code,
	"\nstatic void\n%s(\n    JOB_PRIM_ARGS_TYPED\n) {\n",
	fn_name
    );

    /* Read any l1 immediate offset: */
    if     (l1 != 's') {
	if (l1 != '_') {
            fprintf(fd_code,"    register unsigned l1off = %s;\n", ux_expr(x));
	}
    } else {
	l1off =   (l2=='s' ? "-1" : "0");
    }

    /* Read any l2 immediate offset: */
    if     (l2 != 's') {
	if (l2 != '_') {
	    fprintf(fd_code,"    register unsigned l2off = %s;\n", ux_expr(x));
	}
    } else {
	l2off = "0";
    }

    /* Read any l0 immediate offset: */
    if         (l0 != 's') {
	if     (l0 != '_') {
	    if (l0 == 'p') {
	        fprintf(fd_code,
		    "    register Vm_Int l0off = %s;\n", sx_expr(x)
		);
	    } else {
	        fprintf(fd_code,
		    "    register Vm_Unt l0off = %s;\n", ux_expr(x)
		);
	    }
	}
    } else {
	if      (l1=='s' && l2=='s')   l0off = "-1";
	else if (l1=='s' || l2=='s')   l0off =  "0";
	else                           l0off =  "1";
    }



    /* Write any macro provided: */
    if (*s->macro) {
	fprintf(fd_code, "#undef  ILEN\n");
	fprintf(fd_code, "#define ILEN (%d+1)\n",(int)x);
	fprintf(fd_code, "#undef  M\n");
	fprintf(fd_code,
	    "#define M(L0,L1,L2,T1,T2,FN_NAME,X,N1,N1Z,N1U,N2,N2Z,N2U,TYP2) \\\n    %s\n",
	    s->macro
	);

	fprintf(fd_code,"    M( " 				);

	/* L0: */
	if (l0!='_') fprintf(fd_code, "jS%c[%s], ", (int)l0, l0off	);
	else         fprintf(fd_code, "_, "			);

	/* L1: */
	if (l1!='_') fprintf(fd_code, "jS%c[%s], ", (int)l1, l1off	);
	else         fprintf(fd_code, "_, "			);

	/* L2: */
	if (l2!='_') fprintf(fd_code, "jS%c[%s], ", (int)l2, l2off	);
	else         fprintf(fd_code, "_, "			);

	/* T1, T2, FN_NAME, X, XN: */
 	fprintf(fd_code, "%c, ", (int)t1			);
 	fprintf(fd_code, "%c, ", (int)t2			);
 	fprintf(fd_code, "%s, ", fn_name			);
 	fprintf(fd_code, "%s, ", x ? (s->x_signed?sx_expr(x):ux_expr(x)) :"_");

	/* N1: */
	if (l1=='_') {
	    fprintf(fd_code, "_, " );
	} else {
	    if      (t1=='i') fprintf(fd_code, "OBJ_TO_INT(jS%c[%s]), ",  (int)l1,l1off);
	    else if (t1=='r') fprintf(fd_code, "OBJ_TO_FLOAT(jS%c[%s]), ",(int)l1,l1off);
	    else	      fprintf(fd_code, "jS%c[%s], ",              (int)l1,l1off);
	}

	/* N1Z: */
 	if          (l1=='_') fprintf(fd_code, "_, "		);
	else {
	    if      (t1=='i') fprintf(fd_code, "0, "		);
	    else if (t1=='r') fprintf(fd_code, "0.0, "		);
	    else              fprintf(fd_code, "OBJ_FROM_BYT0, ");
	}

	/* N1U: */
 	if          (l1=='_') fprintf(fd_code, "_, "		);
	else {
	    if      (t1=='i') fprintf(fd_code, "1, "		);
	    else if (t1=='r') fprintf(fd_code, "1.0, "		);
	    else              fprintf(fd_code, "OBJ_FROM_BYT1, ");
	}

	/* N2: */
	if (l2=='_') {
	    fprintf(fd_code, "_, " );
	} else {
	    if      (t2 == 'i') fprintf(fd_code, "OBJ_TO_INT(jS%c[%s]), ",   (int)l2,l2off);
	    else if (t2 == 'r') fprintf(fd_code, "OBJ_TO_FLOAT2(jS%c[%s]), ",(int)l2,l2off);
	    else	        fprintf(fd_code, "jS%c[%s], ",               (int)l2,l2off);
	}

	/* N2Z: */
 	if          (l2=='_') fprintf(fd_code, "_, "		);
	else {
	    if      (t2=='i') fprintf(fd_code, "0, "		);
	    else if (t2=='r') fprintf(fd_code, "0.0, "		);
	    else              fprintf(fd_code, "OBJ_FROM_BYT0, ");
	}

	/* N2U: */
 	if          (l2=='_') fprintf(fd_code, "_, "		);
	else {
	    if      (t2=='i') fprintf(fd_code, "1, "		);
	    else if (t2=='r') fprintf(fd_code, "1.0, "		);
	    else              fprintf(fd_code, "OBJ_FROM_BYT1, ");
	}

	/* Convert to output type: */
	switch (t2) {
	case 'i':   fprintf(fd_code, " OBJ_FROM_INT "   );	break;
	case 'r':   fprintf(fd_code, " OBJ_FROM_FLOAT " );	break;
	default:    fprintf(fd_code, " OBJ_FROM_BYT1 "  );	break;
	}

 	fprintf(fd_code, ")\n"					);
    }



    if (!*s->c_name) {

        /* Not doing special support for generating arithmetic prims: */

    } else {

        /* Special support for generating arithmetic prims: */
	char type_update_buf[ 128 ]; type_update_buf[0] = '\0';

	/* Decide whether to use assnop, or update dest type: */
	if (*s->t0 == 'a') {
	    /* User wants dest type determined */
	    /* by normal arithmetic rules.     */

	    if (l0=='s' && l1=='s' && t1==t0) { /*l2=='s',!='s'both ok*/
		use_assnop = 2;
            } else if (l0=='s' && l1!='s' && l2=='s' && t2==t0) {
		if (s->commutes)   use_assnop = 1;
	    }

	} else if (*s->t0 == 'i') {

	    /* User wants dest type	*/
	    /* always integer:		*/

	    /* I can't (yet?) make sense of '1' or '2' options here, */
	    /* since we don't know the type of nonstack arguments at */
	    /* this point, but I've sketched in code for them anyhow.*/
	    /* Think hard before using:                              */
	} else if (*s->t0 == '1') {
	    /* User wants dest type same as arg 1. */

	    if (l0=='s' && l1=='s') { /*l2 can be 's'/!'s' either*/
		/* Same stack loc */
		use_assnop = 2;
	    }
	} else if (*s->t0 == '2') {
	    /* User wants dest type same as arg 2. */

	    if (l0=='s' && l2=='s' && l1!='s') {
		/* Same stack loc */
		if (s->commutes)   use_assnop = 1;
    	}   }



	/* Write destination: */
	fprintf(fd_code,
	    "    jS%c[%s]",
	    (int)l0, l0off
	);


	/* Never use assnops for unary C operators: */
	if (l1 == '_')   use_assnop = FALSE;

        /* Generate code something like                       */
        /* a = OBJ_FROM_INT( OBJ_TO_INT(b) + OBJ_TO_INT(c) ); */
	fprintf(fd_code, " = " );


	/* Special optimization for integer + and -:  */
	if (t0 == 'i'
        &&  t1 == 'i'
	&&  t2 == 'i'
	&& (   STRCMP( s->c_name, == ,"+")
            || STRCMP( s->c_name, == ,"-")
	   )
	) {
	    /* Skip converting to and from integer format: */
	    fprintf(fd_code, " jS%c[%s] %s jS%c[%s];\n", (int)l1,l1off, s->c_name, (int)l2,l2off );

	} else {

	    /* Comparison ops produce bools, not ints: */
	    if (STRCMP( s->c_name, == ,"<")
	    ||  STRCMP( s->c_name, == ,">")
	    ||  STRCMP( s->c_name, == ,"<=")
	    ||  STRCMP( s->c_name, == ,">=")
	    ||  STRCMP( s->c_name, == ,"!=")
	    ||  STRCMP( s->c_name, == ,"==")
	    ){
		fprintf(fd_code, " OBJ_FROM_BOOL( "   );
	    } else {

		/* Convert to output type: */
		switch (t0) {
		case 'i':   fprintf(fd_code, " OBJ_FROM_INT( "   );	break;
		case 'r':   fprintf(fd_code, " OBJ_FROM_FLOAT( " );	break;
		default:
		    fprintf(stderr,"fast_prim_write: t0 c='%c'?!\n",(int)t0);
		    exit(1);
		}
	    }

	    /* Convert first input to numeric form: */
	    switch (t1) {
	    case 'i':   fprintf(fd_code, " OBJ_TO_INT("   );	break;
	    case 'r':   fprintf(fd_code, " OBJ_TO_FLOAT(" );	break;
	    case '_':						break;
	    default:
		fprintf(stderr,"fast_prim_write: t1 c='%c'?!\n",(int)t1);
		exit(1);
	    }

	    /* Write first arg, if any: */
	    if (l1 != '_')   fprintf(fd_code, "jS%c[%s]) ", (int)l1, l1off );

	    /* Write op: */
	    fprintf(fd_code, "%s ", s->c_name );

	    /* Convert second input to numeric form: */
	    switch (t2) {
	    case 'i':   fprintf(fd_code, " OBJ_TO_INT("   );	break;
	    case 'r':   fprintf(fd_code, " OBJ_TO_FLOAT2(");	break;
	    default:
		fprintf(stderr,"fast_prim_write: t2 c='%c'?!\n",(int)t2);
		exit(1);
	    }

	    /* Write second arg: */
	    fprintf(fd_code, "jS%c[%s]) );", (int)l2, l2off );
	}
    }



    /* Write any stack update needed: */
    {   Vm_Int offset = s->sp_adjust;
	if (l0 == 's')   ++offset;
	if (l1 == 's')   --offset;
	if (l2 == 's')   --offset;
	switch (offset) {
	case  0:	    					break;
	case  1:  fprintf(fd_code, "    ++jSs;\n" );		break;
	case -1:  fprintf(fd_code, "    --jSs;\n" );		break;
	default:  fprintf(fd_code, "    jSs += %d;\n", (int)offset);	break;
    }	}



    /* Write fn trailer: */

    if (s->ilen_valid) {
	/* This is a slow function where jS.instruction_len */
	/* may have been hacked while we weren't looking,   */
	/* say to do a task switch, hence we need to use it */
	/* rather than trusting to dead reckoning:          */
	fprintf(fd_code, "    jSpc += jS.instruction_len;\n" );
    } else {
	/* This is a fast function with no significant logic,  */
	/* we can compute instruction length by dead reckoning */
	/* and save a memory cycle:                            */
	switch (instruction_len) {
	case 1:  fprintf(fd_code, "    ++jSpc;\n" );		break;
	default: fprintf(fd_code, "    jSpc += %d;\n", (int)instruction_len );
    }	}

    fputs( "    JOB_NEXT;\n", fd_code);
    fputs( "}\n"            , fd_code);
    fputs( "\n\n"  , fd_code);

    return fn_name;
}



static void
fast_prims_write( void ) {

 Fast         f;
 for         (f  = fast     ;   f->a_name    ;   ++f ) {
  unsigned prim  = assign_prim_code( f->a_name );
  Vm_Int      x;
  for        (x  = f->x_min ;   x <= f->x_max;   ++x ) {
   char       l0 = f->l0;
   char       l1 = f->l1;
   char       l2 = f->l2;
   unsigned opcode = assign_fast_code(
    f->a_name, prim, l0,l1,l2, x, f->x_signed,f->commutes,f->sp_adjust,f->arity
   );
   char*   t1;
   for    (t1 = f->t1    ;   *t1          ;   ++t1) {
    char*  t2;
    for   (t2 = f->t2    ;   *t2          ;   ++t2) {

     /* Create function: */
     char* fn_name = str_dup(fast_prim_write( f,x, l0,l1,l2, *t1,*t2 ));

     /* Construct dispatch table entries for fn. */
     /* This means iterating over all don't-care */
     /* types t?.  If argument exists, iteration */
     /* is over all valid types, if it doesn't,  */
     /* iteration is over underflow type as well:*/
     char  buf1[ 1  <<  JOB_TYPE_BITS + 1 ];
     char  buf2[ 1  <<  JOB_TYPE_BITS + 1 ];
     /* Start by assuming just given type: */
     buf1[0] = *t1;  buf1[1]  = '\0';
     buf2[0] = *t2;  buf2[1]  = '\0';
     /* Iterate over all nonunderflow */
     /* types on don't-care types,    */
     /* including thunks (since they  */
     /* are presumably just being     */
     /* blindly copied around):       */
     if (*buf1 == '_')   strcpy( buf1, cell_types+1 );
     if (*buf2 == '_')   strcpy( buf2, cell_types+1 );
     /* Iterate over underflow as well on nonstack args: */
     if (l1    != 's')   strcpy( buf1, cell_types   );
     if (l2    != 's')   strcpy( buf2, cell_types   );
     {char* T1;
      for  (T1 = buf1;   *T1;   ++T1) {
       char*T2;
       for (T2 = buf2;   *T2;   ++T2) {
	fast_table_entry( opcode, *T1, *T2, fn_name );
     }}}

     /* If fn has stack args, need to insert underflow checks: */
     if  (l2 == 's') {
      if (l1 == 's') {
       /* Both args exist, error if 1st is underflow (u) and 2nd any: */
       char*T2;
       for (T2 = cell_types;   *T2;   ++T2) {
	fast_table_entry( opcode, 'u', *T2, "job_UNDERFLOW" );
      }} else {{
	/* Second arg exists, err if 2nd is underflow (u),   */
	/* which can only happen if first is also underflow: */
	fast_table_entry( opcode, 'u', 'u', "job_UNDERFLOW" );
     }}}

     /* If fn has stack args whose types matter, */
     /* need to insert thunk-evaluation support: */
     if  (l1 == 's'  &&  *t1 != '_') {
      char*T2;
      /* Eval 1st if 1st is thunk (t) and 2nd any: */
      for (T2 = cell_types;   *T2;   ++T2) {
       fast_table_entry( opcode, 't', *T2, "job_THUNK1" );
     }}
     if  (l2 == 's'  &&  *t2 != '_') {
      char*T1;
      /* Eval 2nd if 2nd is thunk (t) and 1st any: */
      for (T1 = cell_types;   *T1;   ++T1) {
       fast_table_entry( opcode, *T1, 't', "job_THUNK0" );
 }}}}}}
}

/************************************************************************/
/*-    slow_prims_write							*/
/************************************************************************/

/************************************************************************/
/*-    slow_prim_write							*/
/************************************************************************/

static char*
slow_prim_write(
    Slow s
) {
    static char fn_name[ 128 ];
    ++ prims_built;

    /* Generate name for prim fn: */
    sprintf( fn_name, "job_P_%s", s->a_name );
    /* Convert "job_P_DO_IT" to "job_P_Do_It" &tc: */
    {   unsigned char* t;
	for  (t = fn_name+6;   t[0];   ++t) {
	    if (isalpha(t[ 0])
            &&  isalpha(t[-1])
	    ){
		t[0] = tolower(t[0]);
    }	}   }

    return fn_name;
}




static void
slow_prims_write( void ) {

    fputs( "#undef  Reg\n"		 			, fd_code );
    fputs( "#define Reg register\n"	 			, fd_code );

    fputs( "#undef  Int\n"		 			, fd_code );
    fputs( "#define Int Vm_Int\n"	 			, fd_code );

    fputs( "#undef  jSs\n"		 			, fd_code );
    fputs( "#define jSs job_RunState.s\n"			, fd_code );

    fputs( "#undef  jSpc\n"		 			, fd_code );
    fputs( "#define jSpc job_RunState.pc\n"			, fd_code );

    {   Slow s;
	for  (s  = slow;   s->a_name;   ++s ) {
            unsigned prim   = assign_prim_code( s->a_name );
	    unsigned opcode = assign_slow_code(
		s->a_name,
		prim,
		s->arity
	    );
	    /* Create function: */
	    char* fn_name = str_dup(slow_prim_write( s ));

	    /* Remember function: */
	    if      (opcode < 0x100) slow_table0[ opcode-0x000 ] = fn_name;
	    else if (opcode < 0x200) slow_table1[ opcode-0x100 ] = fn_name;
	    else if (opcode < 0x300) slow_table2[ opcode-0x200 ] = fn_name;
	    else if (opcode < 0x400) slow_table3[ opcode-0x300 ] = fn_name;
	    else if (opcode < 0x500) slow_table4[ opcode-0x400 ] = fn_name;
	    else if (opcode < 0x600) slow_table5[ opcode-0x500 ] = fn_name;
	    else if (opcode < 0x700) slow_table6[ opcode-0x600 ] = fn_name;
	    else if (opcode < 0x800) slow_table7[ opcode-0x700 ] = fn_name;
	    else if (opcode < 0x900) slow_table8[ opcode-0x800 ] = fn_name;
	    else if (opcode < 0xa00) slow_table9[ opcode-0x900 ] = fn_name;
	    else if (opcode < 0xb00) slow_tableA[ opcode-0xa00 ] = fn_name;
	    else if (opcode < 0xc00) slow_tableB[ opcode-0xb00 ] = fn_name;
	    else if (opcode < 0xd00) slow_tableC[ opcode-0xc00 ] = fn_name;
	    else if (opcode < 0xe00) slow_tableD[ opcode-0xd00 ] = fn_name;
	    else if (opcode < 0xf00) slow_tableE[ opcode-0xe00 ] = fn_name;
	    else                     slow_tableF[ opcode-0xf00 ] = fn_name;
    }   }

    fputs( "#undef  Reg\n"   , fd_code );
    fputs( "#undef  Int\n"   , fd_code );
    fputs( "#undef  jSs\n"   , fd_code );
    fputs( "#undef  jSpc\n"  , fd_code );
}



static void
write_contents_to_temp_files( void ) {

    fast_table_initialize();
    slow_table_initialize();
    fast_prims_write();
    slow_prims_write();
    fast_table_dump();
    slow_table_dump();
    code_table_sort();
    code_table_dump();
    type_table_dump();
}

/************************************************************************/
/*-    write_trailers_to_temp_files -- 					*/
/************************************************************************/

/************************************************************************/
/*-    write_decl_trailer						*/
/************************************************************************/

static void
write_decl_trailer( void ) {

    /* Close statics section: */
    fputs("\n\n", fd_decl );

}

/************************************************************************/
/*-    write_tabl_trailer						*/
/************************************************************************/

static void
write_tabl_trailer( void ) {

    /* Close globals section: */
    fputs("\n\n", fd_tabl );

}

/************************************************************************/
/*-    write_code_trailer						*/
/************************************************************************/

static void
write_code_trailer( void ) {

    /* Close static-fns section: */
    fputs("\n\n", fd_code );

    /* Append 'File variables' section: */

    fputs("\n/*-    File variables							*/\n", fd_code );
    fputs( "/*\n",				fd_code );
    fputs( "Local variables:\n",		fd_code );
    fputs( "mode: outline-minor\n",		fd_code );
    fputs( "case-fold-search: nil\n",		fd_code );
    fputs( "outline-regexp: \"[ \\\\t]*\\/\\\\*-\"\n",fd_code );
/*    fputs( "outline-regexp: \"/\\\\* {+\"\n",	fd_code );*/
    fputs( "End:\n",				fd_code );
    fputs( "*/\n",				fd_code );
    fputs( "\n",			fd_code );
}



static void
write_trailers_to_temp_files(
    void
) {

    write_decl_trailer();
    write_tabl_trailer();
    write_code_trailer();
}

/************************************************************************/
/*-    write_job_code_docs 						*/
/************************************************************************/

static void
write_job_code_docs(
    FILE* fd
) {
    fputc('\n',fd);
    fputs("/*************************************************************/\n", fd );
    fputs("/* key op op2 arity x x_signed commutes sp_adjust name:      */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'key' is JOB_OP_SOMETHING -- the abstract operation.      */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'op' is first bytecode of an instruction implementing it. */\n", fd );
    fputs("/* Note that there may be more than one instruction          */\n", fd );
    fputs("/* implementing a given abstract operation.                  */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'op2' is zero else the second opcode byte, if needed.     */\n", fd );
    fputs("/* To allow a zero second opcode byte, JOB_2_BYTES           */\n", fd );
    fputs("/* is ORed into all valid op2 values:  Only the low byte     */\n", fd );
    fputs("/* of op2 should actually be used.                           */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'arity' encodes the operation arity, in the usual format. */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'x' is the number of extension bytes to read out of       */\n", fd );
    fputs("/* the instruction stream after the opcode bytes:  It        */\n", fd );
    fputs("/* encodes jump distances, constant-vector offsets and       */\n", fd );
    fputs("/* so forth.  If this is non-zero, there will usually be     */\n", fd );
    fputs("/* multiple versions of the instruction, differing only in   */\n", fd );
    fputs("/* the opcode and number of extension bytes.                 */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'x_signed' is TRUE iff the extension bytes, combined      */\n", fd );
    fputs("/* to form a value, should be interpreted as a signed        */\n", fd );
    fputs("/* number.  Jumps need signed extension values, most other   */\n", fd );
    fputs("/* instructions use unsigned extensions.                     */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'commutes' is TRUE for binary instructions that implement */\n", fd );
    fputs("/* commutative operations (addition, as opposed to sub-      */\n", fd );
    fputs("/* traction, say.  This could be used by optimizers, but     */\n", fd );
    fputs("/* currently is not.                                         */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'sp_adjust' may be used to encode a jS.s adjustment needed*/\n", fd );
    fputs("/* at the end of the instruction, beyond what can be deduced */\n", fd );
    fputs("/* from the arity.   Should maybe be phased out.             */\n", fd );
    fputs("/*                                                           */\n", fd );
    fputs("/* 'name' is an ascii string naming the abstract operation,  */\n", fd );
    fputs("/* useful for symbolic disassembly of code and such.         */\n", fd );
    fputs("/*************************************************************/\n", fd );
}

/************************************************************************/
/*-    write_jobprims_h -- 						*/
/************************************************************************/

static void
write_jobprims_h(
    void
) {

    FILE* fd = fopen( "../h/jobprims.h", "w" );
    if  (!fd)   JOB_FATAL ("Couldn't open ../h/jobprims.h");


    fputs("/*-    jobprims.h -- Header for jobprims.c -- which see.                */\n\n", fd );

    fputs("#ifndef INCLUDED_JOBPRIMS_H\n", fd );
    fputs("#define INCLUDED_JOBPRIMS_H\n", fd );
    fputs("\n", fd );


    fputs("/*-    #includes                                                           */\n\n", fd );
    fputs("#include \"jobpass.h\"\n", fd );
    fputs("#include \"vm.h\"\n", fd );
    fputs("\n", fd );


    fputs("/*-    #defines                                                            */\n\n", fd );

    /* Write #define section: */
    fputs("\n#define jS job_RunState\n\n", fd );

    /* Decide whether to pass our core state (pc etc)	*/
    /* to prims in parameters or globals:		*/
/*buggo... shouldn't have just a 'j' prefix...*/
#   if JOB_PASS_IN_PARAMETERS
    fputs("#define jSs    s\n", fd );
    fputs("#define jSpc   pc\n", fd );
    fputs("#define jSops  ops\n", fd );
    fputs("#define jStabl tabl\n", fd );
#   else
    fputs("#define jSs    jS.s\n", fd );
    fputs("#define jSpc   jS.pc\n", fd );
    fputs("#define jSops  jS.ops\n", fd );
    fputs("#define jStabl job_Fast_Table\n", fd );
#   endif
    /* Rest are always passed as globals, for now: */
    fputs("#define jSv    jS.v\n", fd );
    fputs("#define jSV    jS.V\n", fd );
    fputs("#define jSk    jS.k\n", fd );

    fprintf(fd,"#define JOB_ATP_MAX (%d)\n", (int)JOB_ATP_MAX );
    fprintf(fd,"#define JOB_DST_MAX (%d)\n", (int)JOB_DST_MAX );
    fprintf(fd,"#define JOB_OPCODE_BITS (%d)\n", (int)JOB_OPCODE_BITS );
    fprintf(fd,"#define JOB_TYPE_BITS (%d)\n", (int)JOB_TYPE_BITS );
    fprintf(fd,"#define JOB_LOC_BITS (%d)\n", (int)JOB_LOC_BITS );
    fprintf(fd,"#define JOB_INDEX_BITS (%d)\n", (int)JOB_INDEX_BITS );
    fprintf(fd,"#define JOB_OPS_COUNT_MASK (0x%x)\n", (int)JOB_OPS_COUNT_MASK );
    fprintf(fd,"#define JOB_FAST_TABLE_MAX (0x%x)\n", (int)JOB_FAST_TABLE_MAX );
    fprintf(fd,"#define JOB_SLOW_TABLE_MAX (0x%x)\n", (int)JOB_SLOW_TABLE_MAX );
    fprintf(fd,"#define JOB_CODE_MAX (0x%x)\n", (int)code_next );
    fprintf(fd,"#define JOB_SLOW_PREFIX_BYTES (%d)\n", (int)JOB_SLOW_PREFIX_BYTES );
    fprintf(fd,"#define JOB_2_BYTES (%d)\n", (int)JOB_2_BYTES );

    fputs(
	"#define JOB_IS_BRANCH(op) ((op)>=JOB_OP_BEQ && (op)<=JOB_OP_BRA)\n",
	fd
    );

    fputs("#define JOB_LOC_MASK    ((1<<JOB_LOC_BITS)-1)\n", fd );

    fputc('\n',fd);
#if JOB_PASS_IN_PARAMETERS
    fputs("#define JOB_NEXT                             \\\n", fd );

    /*****************************************************************************/
    /* Note: I used to compile in the MUQ_TRACE stuff only when actively needed. */
    /* I dislike inner-loop overhead. :)  But doing some actual timing of how    */
    /* long it takes to compile all the Muq libraries				 */ 
    /* WITHOUT the MUQ_TRACE stuff compiled in:					 */
    /*										 */
    /*	74.310u 7.760s 1:39.84 82.2% 0+0k 0+0io 20978pf+0w			 */
    /*	75.020u 7.890s 1:33.82 88.3% 0+0k 0+0io 20495pf+0w			 */
    /*	75.000u 8.040s 1:34.88 87.5% 0+0k 0+0io 20495pf+0w			 */
    /*										 */
    /* and WITH the MUQ_TRACE stuff compiled in:				 */
    /* 	77.270u 7.940s 1:41.58 83.8% 0+0k 0+0io 20878pf+0w			 */	
    /*	77.880u 8.270s 1:42.54 84.0% 0+0k 0+0io 20563pf+0w			 */
    /*	77.670u 7.660s 1:35.55 89.3% 0+0k 0+0io 20501pf+0w			 */
    /*										 */
    /* suggests that the speed difference prolly won't be noticable to most	 */
    /* people, and I might as well leave the code in permanently, unless/until   */
    /* we start seriously performance-tuning.			      98Jan08CrT */
    /*****************************************************************************/

    /* Un#ifdef next 3 for a debug trace (see also job_Is_Idle()): */
    #ifndef MUQ_TRACE
    fputs("if (job_Log_Bytecodes /*= (++job_Bytecodes_Traced>JOB_TRACE_BYTECODES_FROM)*/){\\\n",fd);
    fputs("JOB_CACHE_ARGS;\\\n",fd);
    fputs("job_Print1(jSpc,jSs);\\\n", fd );
    fputs("JOB_UNCACHE_ARGS;\\\n",fd);
    fputs("}\\\n",fd);
    #endif
    fputs("{++jSops;                                    \\\n", fd );
    fputs(" ((Job_Fast_Prim*)jStabl)[                   \\\n", fd );
    fputs("  *jSpc                          |           \\\n", fd );
    fputs("  (job_Type1[jSs[-1]&0xFF])      |           \\\n", fd );
    fputs("   job_Type0[jSs[ 0]&0xFF]       |           \\\n", fd );
    fputs("  (jSops & JOB_OPS_COUNT_MASK)               \\\n", fd );
    fputs(" ](JOB_PRIM_ARGS);}\n",                             fd );
#else
    fputs("#define JOB_NEXT                             \\\n", fd );
    /* Uncomment #ifdef next for a debug trace (see also job_Is_Idle()): */
    #ifndef MUQ_TRACE
    fputs("if (job_Log_Bytecodes /*= (++job_Bytecodes_Traced>JOB_TRACE_BYTECODES_FROM)*/){\\\n",fd);
/*  fputs("if (job_Log_Bytecodes){\\\n",fd); */
    fputs("job_Print1(jSpc,jSs);\\\n", fd );
    fputs("}\\\n",fd);
    #endif
    fputs(" ((Job_Fast_Prim*)jStabl)[                   \\\n", fd );
    fputs("  *jSpc                          |           \\\n", fd );
    fputs("  (job_Type1[jSs[-1]&0xFF])      |           \\\n", fd );
    fputs("   job_Type0[jSs[ 0]&0xFF]       |           \\\n", fd );
    fputs("  (++jSops & JOB_OPS_COUNT_MASK)             \\\n", fd );
    fputs(" ](JOB_PRIM_ARGS)\n",                               fd );
#endif


    fputc('\n',fd);
#if JOB_PASS_IN_PARAMETERS
    fputs("#define JOB_CACHE_ARGS			\\\n", fd );
    fputs("{ jS.s   = s;				\\\n", fd );
    fputs("  jS.pc  = pc;				\\\n", fd );
    fputs("  jS.instruction_len = ILEN;			\\\n", fd );
    fputs("  jS.ops = ops;}				  \n", fd );
    fputs("#define JOB_UNCACHE_ARGS			\\\n", fd );
    fputs("{ s   = jS.s;				\\\n", fd );
    fputs("  pc  = jS.pc;				\\\n", fd );
    fputs("  ops = jS.ops;}				  \n", fd );
#else
    fputs("#define JOB_CACHE_ARGS			\\\n", fd );
    fputs("  jS.instruction_len = ILEN;			  \n", fd );
    fputs("#define JOB_UNCACHE_ARGS\n"                       , fd );
#endif


#if JOB_PASS_IN_PARAMETERS
    fputs("\n#define JOB_PRIM_ARGS_TYPED Vm_Obj* s, Vm_Uch* pc, Vm_Int ops, void* tabl\n",fd);
    fputs("\n#define JOB_PRIM_ARGS s, pc, ops, tabl\n",fd);
#else
    fputs("\n#define JOB_PRIM_ARGS_TYPED void\n",fd);
    fputs("\n#define JOB_PRIM_ARGS\n",fd);
#endif

    fputc('\n',fd);
    fprintf(fd,"#define JOB_STACKFRAME_NULL     OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_NULL );
    fprintf(fd,"#define JOB_STACKFRAME_FUN_BIND OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_FUN_BIND );
    fprintf(fd,"#define JOB_STACKFRAME_VAR_BIND OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_VAR_BIND );
    fprintf(fd,"#define JOB_STACKFRAME_NORMAL  OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_NORMAL );
    fprintf(fd,"#define JOB_STACKFRAME_CATCH   OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_CATCH  );
    fprintf(fd,"#define JOB_STACKFRAME_PROTECT OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_PROTECT);
    fprintf(fd,"#define JOB_STACKFRAME_PROTECT_CHILD OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_PROTECT_CHILD);
    fprintf(fd,"#define JOB_STACKFRAME_THROW   OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_THROW  );
    fprintf(fd,"#define JOB_STACKFRAME_RETURN  OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_RETURN );
    fprintf(fd,"#define JOB_STACKFRAME_JUMP    OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_JUMP   );
    fprintf(fd,"#define JOB_STACKFRAME_VANILLA OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_VANILLA);
    fprintf(fd,"#define JOB_STACKFRAME_THUNK   OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_THUNK  );
    fprintf(fd,"#define JOB_STACKFRAME_SIGNAL  OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_SIGNAL );
    fprintf(fd,"#define JOB_STACKFRAME_LOCK    OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_LOCK   );
    fprintf(fd,"#define JOB_STACKFRAME_LOCK_CHILD OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_LOCK_CHILD );
    fprintf(fd,"#define JOB_STACKFRAME_USER    OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_USER   );
    fprintf(fd,"#define JOB_STACKFRAME_PRIVS   OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_PRIVS  );
    fprintf(fd,"#define JOB_STACKFRAME_TAG     OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_TAG    );
    fprintf(fd,"#define JOB_STACKFRAME_GOTO    OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_GOTO   );
    fprintf(fd,"#define JOB_STACKFRAME_TAGTOP  OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_TAGTOP );
    fprintf(fd,"#define JOB_STACKFRAME_RESTART OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_RESTART);
    fprintf(fd,"#define JOB_STACKFRAME_HANDLERS OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_HANDLERS);
    fprintf(fd,"#define JOB_STACKFRAME_BUSY_HANDLERS OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_BUSY_HANDLERS);
    fprintf(fd,"#define JOB_STACKFRAME_HANDLING OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_HANDLING);
    fprintf(fd,"#define JOB_STACKFRAME_TMP_USER OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_TMP_USER   );
    fprintf(fd,"#define JOB_STACKFRAME_ENDJOB OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_ENDJOB   );
    fprintf(fd,"#define JOB_STACKFRAME_EXEC OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_EXEC   );
    fprintf(fd,"#define JOB_STACKFRAME_EPHEMERAL_LIST OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_EPHEMERAL_LIST);
    fprintf(fd,"#define JOB_STACKFRAME_EPHEMERAL_STRUCT OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_EPHEMERAL_STRUCT);
    fprintf(fd,"#define JOB_STACKFRAME_EPHEMERAL_VECTOR OBJ_FROM_INT(%d)\n",(int)JOB_STACKFRAME_EPHEMERAL_VECTOR);

    fputc('\n',fd);
    {   unsigned u;
	for (u = 0;   u < strlen(cell_types);   ++u) {
	    fprintf(fd,
		"#define JOB_TYPE_%c (%d)\n",
		(int)cell_types[u],
		(int)(u << JOB_OPCODE_BITS+1)
	    );
    }	}

    fputc('\n',fd);
    {   unsigned u = 0;
	for (u = 0;   u < strlen(loc_types);   ++u) {
	    fprintf(fd,"#define JOB_LOC_%c (%d)\n", (int)loc_types[u], (int)u );
    }	}

    fputc('\n',fd);
    {   unsigned u;
	for (u = 0;   u < prim_next;   u++) {
	    fprintf(fd,"#define JOB_OP_%s\t(0x%02x)\n",	prim_table[u], (int)u);
    }   }

    fputc('\n',fd);
    fputs("\n", fd );


    fputs("/*-    types                                                               */\n\n", fd );

    /* Job_Code: */
    write_job_code_docs(fd);
    fputc('\n',fd);
    fputs("struct Job_Code_Rec {\n",			fd );
    fputs("    Vm_Int   key;\n",			fd );
    fputs("    Vm_Int   op;\n" ,			fd );
    fputs("    Vm_Int   op2;\n",			fd );
    fputs("    Vm_Obj   arity;\n",			fd );
    fputs("    Vm_Int   x;\n"  ,			fd );
    fputs("    Vm_Int   x_signed;\n",			fd );
    fputs("    Vm_Int   commutes;\n",			fd );
    fputs("    Vm_Int   sp_adjust;\n" ,			fd );
    fputs("    Vm_Chr*  name;\n",			fd );
    fputs("};\n",					fd );
    fputs("typedef struct Job_Code_Rec Job_A_Code;\n",	fd );
    fputs("typedef struct Job_Code_Rec*  Job_Code;\n",	fd );


    /* Job_Any: */
    fputc('\n',fd);
    fputs("union Job_Any_Prim {\n",			fd );
    fputs("    Vm_Int i;\n",				fd );
    fputs("    Vm_Flt r;\n",				fd );
    fputs("/*  double R; */\n",				fd );
    fputs("    Vm_Obj o;\n",				fd );
    fputs("};\n",					fd );
    fputs("typedef union Job_Any_Prim Job_An_Any;\n",	fd );
    fputs("typedef union Job_Any_Prim*   Job_Any;\n",	fd );


    /* Job_Fast_Prim, Job_Slow_Prim: */
    fputc('\n',fd);
    fputs("typedef void (*Job_Fast_Prim)(JOB_PRIM_ARGS_TYPED);\n", fd );
    fputs("typedef void (*Job_Slow_Prim)(        void       );\n", fd );

    fputc('\n',fd);
    fputs("\n", fd );



    fputc('\n',fd);

    fputs("/*-    externs                                                             */\n\n", fd );

    fputc('\n',fd);
    fputs("\nextern Job_A_Code job_Code[  JOB_CODE_MAX ];\n",fd);
    fputs("\nextern Vm_Unt     job_Type1[          256 ];\n",fd);
    fputs("\nextern Vm_Unt     job_Type0[          256 ];\n",fd);
    fputs(
	"\nextern Job_Fast_Prim job_Fast_Table[ JOB_FAST_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table0[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table1[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table2[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table3[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table4[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table5[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table6[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table7[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table8[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Table9[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Tablea[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Tableb[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Tablec[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Tabled[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Tablee[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputs(
	"\nextern Job_Slow_Prim job_Slow_Tablef[ JOB_SLOW_TABLE_MAX ];\n",
	fd
    );
    fputc('\n',fd);
    fputs("\n", fd );




    fputs("/*-    File variables							*/\n", fd );
    fputs("#endif /* INCLUDED_JOBPRIMS_H */\n", fd );
    fputs("/*\n", fd );
    fprintf(fd, "%c\n", (int)12 );	/* ^L */
    fputs("Local variables:\n", fd );
    fputs( "mode: outline-minor\n", fd );
    fputs( "case-fold-search: nil\n",		fd );
    fputs( "outline-regexp: \"[ \\\\t]*\\/\\\\*-\"\n",	fd );
    fputs("*/\n", fd );
    fputs("\n", fd );

    fclose(fd);
}

/************************************************************************/
/*-    --- Static fns: support stuff ---				*/
/************************************************************************/

/************************************************************************/
/*-    check constraints -- make sure a correct interpreter is possible	*/
/************************************************************************/

static void
check_constraints(
    void
) {

    /* Check for opcode space exhaustion: */
    if (fast_next > JOB_PRIMARY_PRIMS_AVAILABLE) {
	printf(
	    "%d primary opcodes requested, only %d available.\n",
	    (int)fast_next, (int)JOB_PRIMARY_PRIMS_AVAILABLE
	);
	printf("Please re-edit jobbuild.c and recompile.\n");
	exit(1);
    }
    if (slow_next > JOB_SECONDARY_PRIMS_AVAILABLE) {
	printf(
	    "%d secondary opcodes requested, only %d available.\n",
	    (int)slow_next, (int)JOB_SECONDARY_PRIMS_AVAILABLE
	);
	printf("Please re-edit jobbuild.c and recompile.\n");
	exit(1);
    }
}

/************************************************************************/
/*-    concatenate_temp_files -- final wrapup				*/
/************************************************************************/

/************************************************************************/
/*-    copy_tmp_to_output						*/
/************************************************************************/

static void
copy_tmpfile_to_output(
    FILE* fdo,
    FILE* fdi
) {
    char   buf[ JOB_BUFSIZE ];
    Vm_Int i;
    while (i = fread( buf, sizeof(char), JOB_BUFSIZE, fdi )) {
        fwrite(       buf, sizeof(char), i          , fdo );
    }
}



static void
concatenate_temp_files(
    void
) {

    FILE* fd = open_file( "jobprims.c", "w" );

    fclose( fd_decl );
    fclose( fd_tabl );
    fclose( fd_code );

    fd_decl = open_file( JOB_DECL_TMPFILE, "r" );
    fd_tabl = open_file( JOB_TABL_TMPFILE, "r" );
    fd_code = open_file( JOB_CODE_TMPFILE, "r" );

    copy_tmpfile_to_output( fd, fd_decl );
    copy_tmpfile_to_output( fd, fd_tabl );
    copy_tmpfile_to_output( fd, fd_code );

    fclose( fd_decl );
    fclose( fd_tabl );
    fclose( fd_code );

    unlink( JOB_DECL_TMPFILE );
    unlink( JOB_TABL_TMPFILE );
    unlink( JOB_CODE_TMPFILE );

    fclose( fd );
}

/************************************************************************/
/*-    code_table_dump -- write to fd_tabl				*/
/************************************************************************/

static void
code_table_dump(
    void
) {
    write_job_code_docs( fd_tabl );
    fputs(
        "\nJob_A_Code job_Code[ JOB_CODE_MAX ] = {\n",
        fd_tabl
    );
    {   unsigned u;
	for (u = 0;   u < code_next;   u++) {
	    fprintf(fd_tabl,
		"    /* %04x: */\t{0x%03x,0x%02x,0x%03x,0x%08x, %d,%d,%d,%d, \"%s\"\t}%c\n",
		(int)u,
		(int)job_Code[u].key 		,
		(int)job_Code[u].op  		,
		(int)job_Code[u].op2  		,
		(int)job_Code[u].arity		,
		(int)job_Code[u].x   		,
		(int)job_Code[u].x_signed		,
		(int)job_Code[u].commutes		,
		(int)job_Code[u].sp_adjust		,
		     job_Code[u].name		,
		(int)(u<code_next-1) ? ',' : ' '
	    );
    }   }
    fputs( "};\n", fd_tabl );

}

/************************************************************************/
/*-    type_table_dump -- write to fd_tabl				*/
/************************************************************************/

static void
type_table_dump(
    void
) {

    fputs("/* Tables used by JOB_NEXT to classify */\n", fd_tabl );
    fputs("/* top two stack entries by low byte:  */\n", fd_tabl );

    fputs(
        "\nVm_Unt job_Type0[ 256 ] = {\n",
        fd_tabl
    );
    {   unsigned u;
	for (u = 0;   u < 256;   u++) {
	    Vm_Chr* typ;
	    if      (OBJ_IS_INT(u))    typ = "JOB_TYPE_i";
	    else if (OBJ_IS_FLOAT(u))  typ = "JOB_TYPE_r";
	    else if (OBJ_IS_BOTTOM(u)) typ = "JOB_TYPE_u";
	    else if (OBJ_IS_THUNK(u))  typ = "JOB_TYPE_t";
	    else if (OBJ_IS_SYMBOL(u)) typ = "JOB_TYPE_s";
	    else if (OBJ_IS_CONS(u))   typ = "JOB_TYPE_c";
	    else                       typ = "JOB_TYPE_o";
	    fprintf(fd_tabl,"    /* %04x: */ %s,\n", (int)u, typ );
    }   }
    fputs( "};\n", fd_tabl );


    fputs(
        "\nVm_Unt job_Type1[ 256 ] = {\n",
        fd_tabl
    );
    {   unsigned u;
	for (u = 0;   u < 256;   u++) {
	    Vm_Chr* typ;
	    if      (OBJ_IS_INT(u))    typ = "JOB_TYPE_i";
	    else if (OBJ_IS_FLOAT(u))  typ = "JOB_TYPE_r";
	    else if (OBJ_IS_BOTTOM(u)) typ = "JOB_TYPE_u";
	    else if (OBJ_IS_THUNK(u))  typ = "JOB_TYPE_t";
	    else if (OBJ_IS_SYMBOL(u)) typ = "JOB_TYPE_s";
	    else if (OBJ_IS_CONS(u))   typ = "JOB_TYPE_c";
	    else                       typ = "JOB_TYPE_o";
	    fprintf(fd_tabl,"    /* %04x: */ %s << JOB_TYPE_BITS,\n", (int)u, typ );
    }   }
    fputs( "};\n", fd_tabl );
}

/************************************************************************/
/*-    assign_fast_code -- Insert entry	in job_Code[]			*/
/************************************************************************/

#ifdef UNUSED_MAYBE_DELETE

/************************************************************************/
/*-    loc_no -- assign number to location type				*/
/************************************************************************/

static int
loc_no(
    char t
) {
    char *s;
    for  (s = loc_types;   *s;  ++s) {
        if (*s == t)   return s - loc_types;
    }
    JOB_FATAL ("loc_no: internal error");
    return 0;  /* Pacify gcc -Wall. */
}


#endif

static unsigned
assign_fast_code(
    char* name,
    Vm_Int   opcode,
    char  l0,
    char  l1,
    char  l2,
    Vm_Int   x,
    Vm_Int   x_signed,
    Vm_Int   commutes,
    Vm_Int   sp_adjust,
    Vm_Obj   arity
) {
    /* Allow multiple specs with same name etc. */
    /* These will normally differ in arg types  */
    /* supported.  This is to let us have, for  */
    /* example, '+' map to one fn set for our   */
    /* arithmetic types and another function    */
    /* for strings etc:                         */
    {   int  i;
	for (i = code_next;   i --> 0; ) {
	    if (job_Code[i].key == opcode) {

		if (job_Code[i].op2) {
		    fprintf(stderr,
			"fast op '%s': conflicting slow opcode\n",
			name
		    );
		    exit(1);
		}
		if (STRCMP( job_Code[i].name, != ,name )) {
		    fprintf(stderr,
			"fast op '%s': internal err\n",
			name
		    );
		    abort();
		}
		if (job_Code[i].x_signed != x_signed) {
		    fprintf(stderr,
			"fast op '%s': conflicting sign specs\n",
			name
		    );
		    exit(1);
		}
		if (job_Code[i].commutes != commutes) {
		    fprintf(stderr,
			"fast op '%s': conflicting commute specs\n",
			name
		    );
		    exit(1);
		}
		if (job_Code[i].sp_adjust != sp_adjust) {
		    fprintf(stderr,
			"fast op '%s': conflicting sp_adjust specs\n",
			name
		    );
		    exit(1);
		}

		if (job_Code[i].x == x)   return job_Code[i].op;
    }   }   }

    if (code_next == JOB_CODE_MAX) {
	JOB_FATAL ("assign_fast_code: job_Code[] overflow");
    }

    job_Code[code_next].key		= opcode;
    job_Code[code_next].op	 	= fast_next;
    job_Code[code_next].op2	 	= 0;
    job_Code[code_next].x		= x;
    job_Code[code_next].x_signed	= x_signed;
    job_Code[code_next].commutes	= commutes;
    job_Code[code_next].sp_adjust	= sp_adjust;
    job_Code[code_next].name		= name;
    job_Code[code_next].arity		= arity;

    code_next++;
    return fast_next++;
}

/************************************************************************/
/*-    assign_slow_code -- Insert entry	in job_Code[]			*/
/************************************************************************/

static unsigned
assign_slow_code(
    Vm_Chr*  name,
    Vm_Int   opcode,
    Vm_Obj   arity
) {

    /* Disallow multiple specs with same name: */
    {   int  i;
	for (i = code_next;   i --> 0; ) {
	    if (job_Code[i].key == opcode) {

		fprintf(stderr,
		    "slow op '%s': conflicts with previous spec!\n",
		    name
		);
		exit(1);
    }   }   }

    if (code_next == JOB_CODE_MAX) {
	JOB_FATAL ("assign_slow_code: job_Code[] overflow");
    }

    job_Code[code_next].key	    = opcode;

    job_Code[code_next].op	    =  slow_next >> 8;
    job_Code[code_next].op2	    = (slow_next & 0xFF) | JOB_2_BYTES;

    job_Code[code_next].x	    = 0;
    job_Code[code_next].x_signed    = 0;

    job_Code[code_next].commutes    = 0;
    job_Code[code_next].sp_adjust   = 0;
    job_Code[code_next].name	    = name;
    job_Code[code_next].arity	    = arity;

    code_next++;
    return slow_next++;
}

/************************************************************************/
/*-    assign_prim_code -- Allocate a new prim num, noting it's name.	*/
/************************************************************************/

static unsigned
assign_prim_code(
    Vm_Chr*  name
) {
    /* If 'name' is already in use, return existing num for it: */
    {   int i;
	for (i = prim_next;   i --> 0; ) {
	    if (STRCMP( name, == ,prim_table[i] ))   return i;
    }   }




    /* Assign 'name' a new prim num: */

    if (prim_next == JOB_PRIM_TABLE_MAX) {
	JOB_FATAL ("assign_prim_code: prim_table[] overflow");
    }

    prim_table[prim_next] = name;

    return prim_next++;
}

/************************************************************************/
/*-    code_table_sort  -- Sort job_Code[] by key field.		*/
/************************************************************************/

/************************************************************************/
/*-    code_table_compare -- Compute order of two job_Code[] records.	*/
/************************************************************************/

static int
code_table_compare(
    const void* a,
    const void* b
) {
#ifdef OLD
    return ((Code)a)->key - ((Code)b)->key;
#else
    if (((Code)a)->key != ((Code)b)->key) {
	return ((Code)a)->key - ((Code)b)->key;
    }
    if (((Code)a)->op  != ((Code)b)->op ) {
	return ((Code)a)->op  - ((Code)b)->op ;
    }
    if (((Code)a)->op2 != ((Code)b)->op2) {
	return ((Code)a)->op2 - ((Code)b)->op2;
    }
    return 0;
#endif
}

static void
code_table_sort( void ) {
    qsort( (void*)job_Code, code_next, sizeof( A_Code ), code_table_compare );
}

/************************************************************************/
/*-    fast_table_dump -- write to fd_tabl				*/
/************************************************************************/

static void
fast_table_dump( void ) {

    unsigned u;

    fputs(
        "\nJob_Fast_Prim job_Fast_Table[ JOB_FAST_TABLE_MAX ] = {\n",
        fd_tabl
    );

    for (u = 0;   u < JOB_FAST_TABLE_MAX;   u++) {
        fprintf(fd_tabl,
	    "    /* %04x: */\t%s%c\n",
	    (int)u,
	    fast_table[ u ],
	    (int)((u<JOB_FAST_TABLE_MAX-1) ? ',' : ' ')
	);
    }

    fputs( "};\n", fd_tabl );
}

/************************************************************************/
/*-    slow_table_dump -- write to fd_tabl				*/
/************************************************************************/

/************************************************************************/
/*-    slow_table_dump1							*/
/************************************************************************/

static void
slow_table_dump1(
    char** slow_table,	/* Table of slow prim names.	*/
    Vm_Int num		/* Which table we're doing.	*/
) {

    unsigned u;

    fprintf(fd_tabl,
        "\nJob_Slow_Prim job_Slow_Table%x[ JOB_SLOW_TABLE_MAX ] = {\n",
	(int)num
    );

    for (u = 0;   u < JOB_SLOW_TABLE_MAX;   u++) {
        fprintf(fd_tabl,
	    "    /* %04x: */\t%s%c\n",
	    (int)u,
	    slow_table[ u ],
	    (u<JOB_SLOW_TABLE_MAX-1) ? ',' : ' '
	);
    }

    fputs( "};\n", fd_tabl );
}



static void
slow_table_dump( void ) {

    slow_table_dump1( slow_table0, 0x00 );
    slow_table_dump1( slow_table1, 0x01 );
    slow_table_dump1( slow_table2, 0x02 );
    slow_table_dump1( slow_table3, 0x03 );
    slow_table_dump1( slow_table4, 0x04 );
    slow_table_dump1( slow_table5, 0x05 );
    slow_table_dump1( slow_table6, 0x06 );
    slow_table_dump1( slow_table7, 0x07 );
    slow_table_dump1( slow_table8, 0x08 );
    slow_table_dump1( slow_table9, 0x09 );
    slow_table_dump1( slow_tableA, 0x0A );
    slow_table_dump1( slow_tableB, 0x0B );
    slow_table_dump1( slow_tableC, 0x0C );
    slow_table_dump1( slow_tableE, 0x0D );
    slow_table_dump1( slow_tableE, 0x0E );
    slow_table_dump1( slow_tableF, 0x0F );
}

/************************************************************************/
/*-    fast_table_initialize						*/
/************************************************************************/

static void
fast_table_initialize( void ) {

    /* Start by setting up default error handler: */
    unsigned u;
    for (u = JOB_FAST_TABLE_MAX;   u --> 0;   ) {
	fast_table[ u ] = "job_UNIMPLEMENTED_OPCODE";
    }

    /* Add in timeslice-expired handler: */
    for (u = JOB_FAST_TABLE_MAX;   u --> 0;   ) {
	if (u & JOB_OPS_COUNT_MASK) {
	    fast_table[ u ] = "job_TIMESLICE_OVER";
    }   }
}

/************************************************************************/
/*-    slow_table_initialize						*/
/************************************************************************/

/************************************************************************/
/*-    slow_table_initialize1						*/
/************************************************************************/

static void
slow_table_initialize1(
    char** slow_table
) {

    /* Start by setting up default error handler: */
    unsigned u;
    for (u = JOB_SLOW_TABLE_MAX;   u --> 0;   ) {
	slow_table[ u ] = "job_Unimplemented_Slow_Opcode";
    }
}



static void
slow_table_initialize( void ) {

    slow_table_initialize1( slow_table0 );
    slow_table_initialize1( slow_table1 );
    slow_table_initialize1( slow_table2 );
    slow_table_initialize1( slow_table3 );
    slow_table_initialize1( slow_table4 );
    slow_table_initialize1( slow_table5 );
    slow_table_initialize1( slow_table6 );
    slow_table_initialize1( slow_table7 );
    slow_table_initialize1( slow_table8 );
    slow_table_initialize1( slow_table9 );
    slow_table_initialize1( slow_tableA );
    slow_table_initialize1( slow_tableB );
    slow_table_initialize1( slow_tableC );
    slow_table_initialize1( slow_tableD );
    slow_table_initialize1( slow_tableE );
    slow_table_initialize1( slow_tableF );
}

/************************************************************************/
/*-    fast_table_entry -- Insert entry					*/
/************************************************************************/

/************************************************************************/
/*-    type_no -- assign number to character type			*/
/************************************************************************/

static int
type_no(
    char t
) {
    char *s;
    for  (s = cell_types;   *s;  ++s) {
        if (*s == t)   return s - cell_types;
    }
    JOB_FATAL ("type_no: internal error");
    return 0; /* Pacify gcc -Wall. */
}



static void
fast_table_entry(
    unsigned opcode,		/* Prim under construction.		*/
    char     t1, char t2,	/* Typ of out/in1/in2 args else ' '.	*/
    char*    fn_name
) {
    /* Figure out which dispatch table slot prim fn goes in: */
    Vm_Int typ1 = type_no( t1 );
    Vm_Int typ2 = type_no( t2 );
    Vm_Int slot = opcode;
    slot    |= typ1 << (JOB_OPCODE_BITS+JOB_TYPE_BITS+1);
    slot    |= typ2 << (JOB_OPCODE_BITS              +1);
    fast_table[ slot ] = fn_name;
}

/************************************************************************/
/*-    open_file -- Open file, check for failure			*/
/************************************************************************/

static FILE*
open_file(
    char* name,
    char* typ
) {
    FILE* fd;
    fd = fopen( name, typ );
    if (!fd) {
	char    buf[132];
	sprintf(buf,"Couldn't create '%s'!\n",name);
	JOB_FATAL (buf);
    }
    return fd;
}

/************************************************************************/
/*-    open_temp_files -- fd_decl / fd_tabl / fd_code			*/
/************************************************************************/

static void
open_temp_files( void ) {

    fd_decl = open_file( JOB_DECL_TMPFILE, "w" );
    fd_tabl = open_file( JOB_TABL_TMPFILE, "w" );
    fd_code = open_file( JOB_CODE_TMPFILE, "w" );
}

/************************************************************************/
/*-    str_dup -- Create stable copy of string				*/
/************************************************************************/

static char*
str_dup(
    char* s
) {
    /* Construct stable copy of name for prim fn: */
    char*   t = (char*) malloc( strlen( s ) +1 );
    strcpy( t, s );
    return  t;
}

/************************************************************************/
/*-    summarize_run -- print stats to stdout				*/
/************************************************************************/

static void
summarize_run( void ) {

    printf(
	"%d prims built implementing %d primary opcodes (%d free)\n",
	(int)prims_built,
	(int)fast_next,
        (int)(JOB_PRIMARY_PRIMS_AVAILABLE - fast_next)
    );
    printf(
	"and %d secondary opcodes (%d free).\n",
	(int)slow_next,
        (int)(JOB_SECONDARY_PRIMS_AVAILABLE - slow_next)
    );
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
