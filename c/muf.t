@example  @c
/*- muf.c -- Compile Multi-User Forth.					*/
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
/* Created:      93Feb01						*/
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
/*-    Epigram								*/
/************************************************************************/

/*
 * "Never put off until run time what you can do at compile time."
 * --  David Gries
 *     in "Compiler Construction for Digital Computers", circa 1969.
 */    

/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/************************************************************************/
/*

Hmm.  Basic algorithm should be:
 find next token
 figure out token type
 branch on token type:
  deposit instruction etc


 ************************************************************************/

/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"

/************************************************************************/
/*-    #defines								*/
/************************************************************************/



/********************************************************/
/* Macros to de/construct the control-structure ints	*/
/* we push on the main user data stack.  We try to      */
/* follow the ANSI Forth standard where priof MUF       */
/* practice allows.                                     */
/*                                                      */
/* In the Forth tradition, we store our labels on the	*/
/* user data stack, to enable and encourage user-       */
/* defined control structures.  They are stored as int  */
/* values, with the lower six bits used as a typetag.   */
/*                                                      */
/* At any given time, there is only one interesting	*/
/* label associated with an if-else-fi being		*/
/* compiled:  the next label to deposit.  ANSI Forth	*/
/* calls these values 'Orig's, so we allocate an ORIG	*/
/* typetag for these values.				*/
/*                                                      */
/* Basically, there are three interesting labels	*/
/* associated with a loop which we may need:            */
/* o The top of the loop, for UNTIL and such;		*/
/* o The bottom loop condition, for CONTINUE and such;  */
/* o The loop exit, for BREAK and such.			*/
/* We need to allocate numbers for these labels at the  */
/* top of the loop.  Together, the above three compose  */
/* what ANSI Forth calls a Dest, so we give them        */
/* typetags DEST_TOP, DEST_BOT and DEST_XIT.		*/
/*                                                      */
/* DO loops are a bit special in that there is an	*/
/* implicit local variable associated with them, which  */
/* needs to be incremented and tested by LOOP and also	*/
/* returned by I and J.  ANSI Forth calls the datastack */
/* block deposited by these a 'DoDest':  We distinguish */
/* them by pushing a DEST_VAR value on top of the usual */
/* three.						*/
/*                                                      */
/* A 'catch{' or 'errset{' is much like an 'if' in      */
/* that the only interesting value which needs to be    */
/* stacked is the next label to deposit, but when       */
/* doing the deposit, we also need to pop the CATCH     */
/* stackframe, so we push a CATCH instead of ORIG.      */
/* AFTER and ALWAYS are similar.                        */
/*                                                      */
/********************************************************/

/* Longest string constant allowed in source text. */
/* Yes, this is ugly and should die someday:       */
#ifndef MUF_MAX_STR
#define MUF_MAX_STR (4096)
#endif

/* Macro to construct a value from tag and label: */
#define TAGBITS  (6)
#define TAGMASK  (0x3F)
#define MAXOP    (0x3f)
#define RESTART  (0x3f)
#define GOBOT    (0x3e)
#define GOTOP    (0x3d)
#define GOTO     (0x3c)
#define LBRK     (0x3b)
#define PRIVS    (0x3a)
#define USER     (0x39)
#define LOCK     (0x38)
#define CASE     (0x37)
#define ALWAYS   (0x36)
#define AFTER    (0x35)
#define CATCH    (0x34)
#define DEST_XIT (0x33)
#define DEST_BOT (0x32)
#define DEST_TOP (0x31)
#define DEST_VAR (0x30)
#define ORIG     (0x2F)
#define COLN     (0x2E)
#define HANDLERS (0x2D)
#define VAR_BIND (0x2C)
#define FUN_BIND (0x2B)
#define MINOP    (0x2B)

/* I tend to be forgetful, so: */
#if (MAXOP > TAGMASK)
#error "MAXOP must be <= than TAGMASK"
#endif

#define TAGGED_LABEL(tag,label) (((label)<<TAGBITS)|(tag))
#undef LABEL
#undef TAG
#define LABEL(taggedlabel) ((taggedlabel) >> TAGBITS)
#define TAG(taggedlabel) ((taggedlabel) & TAGMASK)
#define TAG_IS_VALID(tag) ((tag)>=MINOP && (tag) <= MAXOP)

/* Macros to de/construct variable vals for  */
/* 'symbols' stack from a tag and an offset: */
#undef  TYPE
#undef  OFFSET
#define TYPED_OFFSET(typ,offset)  (((offset)<<TAGBITS)|(typ))
#define TYPE(type_doffset) ((typed_offset) & TAGMASK)
#define OFFSET(typed_offset) ((typed_offset) >> TAGBITS)
#define TYPE(type_doffset) ((typed_offset) & TAGMASK)
/* Types: */
#define LOCAL_VAR (1)	/* Created via "exp -> a"          */
#define LOCAL_TAG (2)	/* Created via "withTags a do{ }" */


/* Macros to get/set fields in our muf:	*/

#define BEG        vec_Get(muf,MUF_OFF_BEG)
#define END        vec_Get(muf,MUF_OFF_END)
#define TYP        vec_Get(muf,MUF_OFF_TYP)
#define STR        vec_Get(muf,MUF_OFF_STR)

#define ASM        vec_Get(muf,MUF_OFF_ASM)
#define CONTAINER  vec_Get(muf,MUF_OFF_CONTAINER)
#define SYMBOLS    vec_Get(muf,MUF_OFF_SYMBOLS)

#define FN_LINE    vec_Get(muf,MUF_OFF_FN_LINE)
#define FN_NAME    vec_Get(muf,MUF_OFF_FN_NAME)
#define FN_BEG     vec_Get(muf,MUF_OFF_FN_BEG)
#define FN         vec_Get(muf,MUF_OFF_FN)
#define QVARS      vec_Get(muf,MUF_OFF_QVARS)

#define SP         vec_Get(muf,MUF_OFF_SP)
#define SYMBOLS_SP vec_Get(muf,MUF_OFF_SYMBOLS_SP)

#define ARITY      vec_Get(muf,MUF_OFF_ARITY)
#define FORCE      vec_Get(muf,MUF_OFF_FORCE)

#define LINE       vec_Get(muf,MUF_OFF_LINE)



/* Values for the compile_path 'mode' arg: */
#define MODE_SET    (0x01)	/* For "--> sym" instead of "sym".	*/
#define MODE_GET    (0x02)	/* For "sym" instead of "--> sym".	*/
#define MODE_DEL    (0x04)	/* For "delete: path" instead of "path".*/
#define MODE_FN     (0x08)	/* For "#'sym" instead of "sym".	*/
#define MODE_QUOTE  (0x10)	/* For  "'sym" instead of "sym".	*/
#define MODE_CONST  (0x20)	/* If we're doing -->constant.		*/
#define MODE_SUBEX  (0x40)	/* Sub-expression: Ignore fn vals on	*/
				/* symbols and always do GET not SET.	*/

/* A value for process_string(): */
#define MUF_NO_DELIM	(0x100)


/************************************************************************/
/*-    Types								*/
/************************************************************************/

struct next_token_state {
    Vm_Obj stg;
    Vm_Obj beg;
    Vm_Obj end;
    Vm_Obj typ;
    Vm_Obj lin;	/* Line # in src file on which token starts. */
    Vm_Obj lot;	/* Line # in src file on which token ended.  */
    Vm_Obj muf;	/* Line number in source file. */
};

/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static Vm_Int process_string( Vm_Uch*, Vm_Uch**, Vm_Uch*, Vm_Unt, Vm_Int );
static void stg_compile( Vm_Obj );

#if MUQ_DEBUG
static int     invariants( FILE*, char*, Vm_Obj );
#endif

static Vm_Int  atoc( Vm_Obj, Vm_Uch* );
static void    assemble_token(    Vm_Obj );
static void    compile_path( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Unt  copy_token_to_buffer(Vm_Uch*,Vm_Unt,Vm_Obj);
static Vm_Unt  copy_token_to_lc_buffer(Vm_Uch*,Vm_Unt,Vm_Obj);
static Vm_Int  find_tag(   Vm_Int*, Vm_Unt );
static void    fn_fill(    Vm_Obj );
static Vm_Int  lvar_offset_old(Vm_Obj,Vm_Uch*);
static Vm_Int  lvar_offset(Vm_Obj,Vm_Uch*);
static Vm_Int  nesting(    Vm_Obj );
static void    symbol_push( Vm_Obj, Vm_Obj, Vm_Obj);
static Vm_Obj  make_source(Vm_Obj );
static Vm_Int  next_token( Vm_Obj );
static Vm_Int  next_token2( struct next_token_state * );
static Vm_Unt  pop(Vm_Obj, Vm_Unt );
static Vm_Unt  pop_after(  Vm_Obj );
static Vm_Unt  pop_always( Vm_Obj );
static void    pop_coln(   Vm_Obj );
static void    pop_catch(  Vm_Obj );
static void    pop_fun_bind(Vm_Obj);
static void    pop_goto(   Vm_Obj );
static Vm_Unt  pop_gotop(  Vm_Obj );
static void    pop_gobot(  Vm_Obj );
static void    pop_lbrk(   Vm_Obj );
static void    pop_lock(   Vm_Obj );
static void    pop_privs(  Vm_Obj );
static void    pop_handlers(Vm_Obj);
static void    pop_restart(Vm_Obj );
static void    pop_user(   Vm_Obj );
static void    pop_var_bind(Vm_Obj);
static Vm_Unt  pop_orig(   Vm_Obj );
static Vm_Unt  pop_case(   Vm_Obj );
static void    push(       Vm_Unt, Vm_Unt );
static void    push_after( Vm_Unt );
static void    push_always(Vm_Unt );
static void    push_catch( void   );
static void    push_dest(  Vm_Unt, Vm_Unt, Vm_Unt );
static void    push_coln(  void   );
static void    push_fun_bind(void );
static void    push_lbrk(  void   );
static void    push_lock(  void   );
static void    push_handlers(void );
static void    push_restart(void  );
static void    push_var_bind(void );
static void    push_user(  void   );
static void    push_privs( void   );
static void    push_orig(  Vm_Unt );
static void    push_case(  Vm_Unt );
static void    push_goto(  void   );
static void    push_gotop( Vm_Unt );
static void    push_gobot( void   );
static Vm_Obj  symbol_value_local( Vm_Obj, Vm_Uch* );
static Vm_Unt  toptag( Vm_Obj );
static void    warn( Vm_Obj, Vm_Uch*, ... );

static void    do_after(	Vm_Obj,Vm_Unt);
static void    do_always(	Vm_Obj,Vm_Unt);
static void    do_aarrow(	Vm_Obj,Vm_Unt);
static void    do_arrow(	Vm_Obj,Vm_Unt);
static void    do_bar(		Vm_Obj,Vm_Unt);
static void    do_barfor(	Vm_Obj,Vm_Unt);
static void    do_barfor_pairs( Vm_Obj,Vm_Unt);
static void    do_brace(	Vm_Obj,Vm_Unt);
static void    do_brke(		Vm_Obj,Vm_Unt);
static void    do_loop_finish(	Vm_Obj,Vm_Unt);
static void    do_calla(	Vm_Obj,Vm_Unt);
static void    do_case_else(	Vm_Obj,Vm_Unt);
static void    do_catch(	Vm_Obj,Vm_Unt);
static void    do_colon(	Vm_Obj,Vm_Unt);
static void    do_compile_time(	Vm_Obj,Vm_Unt);
static void    do_loop_next(	Vm_Obj,Vm_Unt);
static void    do_const(        Vm_Obj,Vm_Obj);
static void    do_delete(	Vm_Obj,Vm_Unt);
static void    do_else(		Vm_Obj,Vm_Unt);
static void    do_for(		Vm_Obj,Vm_Unt);
static void    do_foreach(	Vm_Obj,Vm_Unt);
static void    do_funbind(	Vm_Obj,Vm_Unt);
static void    do_if(		Vm_Obj,Vm_Unt);
static void    do_incdec(	Vm_Obj,Vm_Unt);
static void    do_lbrk(		Vm_Obj,Vm_Unt);
static void    do_listfor(	Vm_Obj,Vm_Unt);
static void    do_loop(		Vm_Obj,Vm_Unt);
static void    do_loop_end(	Vm_Obj,Vm_Unt);
static void    do_never_inline(	Vm_Obj,Vm_Unt);
static void    do_withhandlers(	Vm_Obj,Vm_Unt);
static void    do_withrestart(	Vm_Obj,Vm_Unt);
static void    do_as_me(	Vm_Obj,Vm_Unt);
static void    do_as_user(	Vm_Obj,Vm_Unt);
static void    do_omnipotently(	Vm_Obj,Vm_Unt);
static void    do_on(		Vm_Obj,Vm_Unt);
static void    do_op(		Vm_Obj,Vm_Unt);
static void    do_parameter(	Vm_Obj,Vm_Unt);
static void    do_please_inline(Vm_Obj,Vm_Unt);
static void    do_rightbrace(	Vm_Obj,Vm_Unt);
static void    do_semi(		Vm_Obj,Vm_Unt);
static void    do_case(		Vm_Obj,Vm_Unt);
static void    do_tag(		Vm_Obj,Vm_Unt);
static void    do_then(		Vm_Obj,Vm_Unt);
static void    do_until(	Vm_Obj,Vm_Unt);
static void    do_varbind(	Vm_Obj,Vm_Unt);
static void    do_while(	Vm_Obj,Vm_Unt);
static void    do_withlock(	Vm_Obj,Vm_Unt);

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void muf_doTypes(void){}
Obj_A_Module_Summary muf_Module_Summary = {
   "muf",
    muf_doTypes,
    muf_Startup,
    muf_Linkup,
    muf_Shutdown
};

 /***********************************************************************/
 /*-   mufhid[] -- array listing hidden muf symbols.			*/
 /***********************************************************************/

/**********************************************/
/* In many cases, our server primitives will  */
/* handle the fast and/or simple cases, but   */
/* invoke an in-db function to handle stuff   */
/* which is too complex, or which runs too    */
/* long, to implement as a monolithic C-coded */
/* server prim.  To provide quick and easy    */
/* access to these in-db fallback symbols,    */
/* we establish them inserver.  The actual    */
/* corresponding functions are of course      */
/* created by muq/muf/* libraries.            */
/**********************************************/

struct hidden_rec {
    Vm_Obj* slot;
    Vm_Uch* name;
} mufhid[] = {	/* "hid" for "hidden": These are internal support fns. */
    { &obj_Lib_Muf_Write_Stream_By_Lines,    "]writeStreamByLines"    },
    { &obj_Lib_Muf_Apply_Lambda_List_Slowly, "|applyLambdaListSlowly" },
    { &obj_Lib_Muf_Do_Structure_Initforms,   "]doStructureInitforms"   },

    /* End-of-array sentinel: */
    {NULL,NULL},
};

 /***********************************************************************/
 /*-   mufpub[] -- array listing public muf symbols.			*/
 /***********************************************************************/

/**********************************************/
/* In many cases, our server primitives will  */
/* handle the fast and/or simple cases, but   */
/* invoke an in-db function to handle stuff   */
/* which is too complex, or which runs too    */
/* long, to implement as a monolithic C-coded */
/* server prim.  To provide quick and easy    */
/* access to these in-db fallback symbols,    */
/* we establish them inserver.  The actual    */
/* corresponding functions are of course      */
/* created by muq/muf/* libraries.            */
/**********************************************/

struct hidden_rec
mufpub[] = {	/* "pub" for "public": */
    { &obj_Lib_Muf_List_Delete,    "listDelete"    },
    { &obj_Lib_Muf_Maybe_Write_Stream_Packet, "maybeWriteStreamPacket"},

    /* End-of-array sentinel: */
    {NULL,NULL},
};

 /***********************************************************************/
 /*-   lisphid[] -- array listing hidden lisp symbols.			*/
 /***********************************************************************/

struct hidden_rec 
lisphid[] = {

    /* End-of-array sentinel: */
    {NULL,NULL},
};

 /***********************************************************************/
 /*-   muqnetpub[] -- array listing public muqnet symbols.		*/
 /***********************************************************************/

struct hidden_rec 
muqnetpub[] = {
  { &obj_Lib_Muqnet_Maybe_Write_Stream_Packet, "maybeWriteStreamPacket"},
  { &obj_Lib_Muqnet_Del_Key,                   "delKey" 		  },
  { &obj_Lib_Muqnet_Del_Key_P,		       "delKeyP" 		  },
  { &obj_Lib_Muqnet_Get_Key_P,		       "getKeyP"		  },
  { &obj_Lib_Muqnet_Get_First_Key,	       "getFirstKey?"		  },
  { &obj_Lib_Muqnet_Get_Keys_By_Prefix,	       "getKeysByPrefix"	  },
  { &obj_Lib_Muqnet_Get_Next_Key,	       "getNextKey?"		  },
  { &obj_Lib_Muqnet_Get_Val,		       "getVal"		  	  },
  { &obj_Lib_Muqnet_Get_Val_P,		       "getValP"		  },
  { &obj_Lib_Muqnet_Keys_Block,		       "keysBlock"		  },
  { &obj_Lib_Muqnet_Keysvals_Block,	       "keysvalsBlock"		  },
  { &obj_Lib_Muqnet_Set_From_Block,	       "setFromBlock"		  },
  { &obj_Lib_Muqnet_Set_From_Keysvals_Block,   "setFromKeysvalsBlock"     },
  { &obj_Lib_Muqnet_Set_Val,		       "setVal"		          },
  { &obj_Lib_Muqnet_Vals_Block,		       "valsBlock"		  },

    /* End-of-array sentinel: */
    {NULL,NULL},
};

 /***********************************************************************/
 /*-   mufprim[] -- array describing hardwired muf primitives.		*/
 /***********************************************************************/

struct prim_rec {
    char*    name;
    void   (*fn)(Vm_Obj,Vm_Unt);
    Vm_Unt   op;
};

#undef A
#define A(a,b,c,d) FUN_ARITY(a,b,c,d)
static struct prim_rec mufprim[] = {

/* This table gets runtime-sorted */
/* by sort_prim_table():       */

{"]keysvalsSet", do_op	, JOB_OP_PUBLIC_SET_FROM_KEYSVALS_BLOCK},
{"]keysSet"	, do_op	, JOB_OP_PUBLIC_SET_FROM_BLOCK		},
{"delKey"	, do_op	, JOB_OP_PUBLIC_DEL_KEY			},
{"delKey?"	, do_op	, JOB_OP_PUBLIC_DEL_KEY_P		},
{"get"		, do_op	, JOB_OP_PUBLIC_GET_VAL			},
{"getFirstKey?" , do_op, JOB_OP_PUBLIC_GET_FIRST_KEY		},
{"getKey?"	, do_op	, JOB_OP_PUBLIC_GET_KEY_P		},
{"getKeysByPrefix[",do_op, JOB_OP_PUBLIC_GET_KEYS_BY_PREFIX	},
{"getNextKey?", do_op	, JOB_OP_PUBLIC_GET_NEXT_KEY		},
{"get?"		, do_op	, JOB_OP_PUBLIC_GET_VAL_P		},
{"keys["	, do_op	, JOB_OP_PUBLIC_KEYS_BLOCK		},
{"keysvals["	, do_op	, JOB_OP_PUBLIC_KEYSVALS_BLOCK		},
{"set"	  	, do_op	, JOB_OP_PUBLIC_SET_VAL			},
{"vals["	, do_op	, JOB_OP_PUBLIC_VALS_BLOCK		},

{"]hiddenKeysvalsSet",do_op,JOB_OP_HIDDEN_SET_FROM_KEYSVALS_BLOCK},
{"]hiddenSet"	, do_op	, JOB_OP_HIDDEN_SET_FROM_BLOCK		},
{"hiddenDelKey"	, do_op	, JOB_OP_HIDDEN_DEL_KEY		},
{"hiddenDelKey?"	, do_op	, JOB_OP_HIDDEN_DEL_KEY_P	},
{"hiddenGet"	, do_op	, JOB_OP_HIDDEN_GET_VAL			},
{"hiddenGetFirstKey?", do_op	, JOB_OP_HIDDEN_GET_FIRST_KEY	},
{"hiddenGetKey?"	, do_op	, JOB_OP_HIDDEN_GET_KEY_P	},
{"hiddenGetKeysByPrefix[",do_op,JOB_OP_HIDDEN_GET_KEYS_BY_PREFIX},
{"hiddenGetNextKey?"	, do_op	, JOB_OP_HIDDEN_GET_NEXT_KEY	},
{"hiddenGet?"		, do_op	, JOB_OP_HIDDEN_GET_VAL_P	},
{"hiddenKeys["		, do_op	, JOB_OP_HIDDEN_KEYS_BLOCK	},
{"hiddenKeysvals["	, do_op	, JOB_OP_HIDDEN_KEYSVALS_BLOCK	},
{"hiddenSet"	  	, do_op	, JOB_OP_HIDDEN_SET_VAL		},
{"hiddenVals["	    	, do_op	, JOB_OP_HIDDEN_VALS_BLOCK	},

{"]systemKeysvalsSet", do_op, JOB_OP_SYSTEM_SET_FROM_KEYSVALS_BLOCK},
{"]systemSet"		, do_op	, JOB_OP_SYSTEM_SET_FROM_BLOCK	},
{"systemDelKey"	, do_op	, JOB_OP_SYSTEM_DEL_KEY		},
{"systemDelKey?"	, do_op	, JOB_OP_SYSTEM_DEL_KEY_P	},
{"systemGet"		, do_op	, JOB_OP_SYSTEM_GET_VAL		},
{"systemGetFirstKey?", do_op	, JOB_OP_SYSTEM_GET_FIRST_KEY	},
{"systemGetKey?"	, do_op	, JOB_OP_SYSTEM_GET_KEY_P	},
{"systemGetKeysByPrefix[", do_op, JOB_OP_SYSTEM_GET_KEYS_BY_PREFIX},
{"systemGetNextKey?"	, do_op	, JOB_OP_SYSTEM_GET_NEXT_KEY	},
{"systemGet?"		, do_op	, JOB_OP_SYSTEM_GET_VAL_P	},
{"systemKeys["		, do_op	, JOB_OP_SYSTEM_KEYS_BLOCK	},
{"systemKeysvals["	, do_op	, JOB_OP_SYSTEM_KEYSVALS_BLOCK	},
{"systemSet"	  	, do_op	, JOB_OP_SYSTEM_SET_VAL		},
{"systemVals["	    	, do_op	, JOB_OP_SYSTEM_VALS_BLOCK	},

{"]adminsKeysvalsSet" , do_op , JOB_OP_ADMINS_SET_FROM_KEYSVALS_BLOCK},
{"]adminsSet"		, do_op	, JOB_OP_ADMINS_SET_FROM_BLOCK	},
{"adminsDelKey"	, do_op	, JOB_OP_ADMINS_DEL_KEY		},
{"adminsDelKey?"	, do_op	, JOB_OP_ADMINS_DEL_KEY_P	},
{"adminsGet"		, do_op	, JOB_OP_ADMINS_GET_VAL		},
{"adminsGetFirstKey?", do_op	, JOB_OP_ADMINS_GET_FIRST_KEY	},
{"adminsGetKey?"	, do_op	, JOB_OP_ADMINS_GET_KEY_P    	},
{"adminsGetKeysByPrefix[", do_op, JOB_OP_ADMINS_GET_KEYS_BY_PREFIX},
{"adminsGetNextKey?"	, do_op	, JOB_OP_ADMINS_GET_NEXT_KEY	},
{"adminsGet?"		, do_op	, JOB_OP_ADMINS_GET_VAL_P	},
{"adminsKeys["		, do_op	, JOB_OP_ADMINS_KEYS_BLOCK	},
{"adminsKeysvals["	, do_op	, JOB_OP_ADMINS_KEYSVALS_BLOCK	},
{"adminsSet"	  	, do_op	, JOB_OP_ADMINS_SET_VAL		},
{"adminsVals["	    	, do_op	, JOB_OP_ADMINS_VALS_BLOCK	},

#ifdef OLD
{"]methodKeysvalsSet" , do_op , JOB_OP_METHOD_SET_FROM_KEYSVALS_BLOCK},
{"]methodSet"		, do_op	, JOB_OP_METHOD_SET_FROM_BLOCK	},
{"methodDelKey"	, do_op	, JOB_OP_METHOD_DEL_KEY		},
{"methodDelKey?"	, do_op	, JOB_OP_METHOD_DEL_KEY_P	},
{"methodGet"		, do_op	, JOB_OP_METHOD_GET_VAL		},
{"methodGetFirstKey?", do_op	, JOB_OP_METHOD_GET_FIRST_KEY	},
{"methodGetKey?"	, do_op	, JOB_OP_METHOD_GET_KEY_P 	},
{"methodGetKeysByPrefix[", do_op, JOB_OP_METHOD_GET_KEYS_BY_PREFIX},
{"methodGetNextKey?"	, do_op	, JOB_OP_METHOD_GET_NEXT_KEY	},
{"methodGet?"		, do_op	, JOB_OP_METHOD_GET_VAL_P	},
{"methodKeys["		, do_op	, JOB_OP_METHOD_KEYS_BLOCK	},
{"methodKeysvals["	, do_op	, JOB_OP_METHOD_KEYSVALS_BLOCK	},
{"methodSet"	  	, do_op	, JOB_OP_METHOD_SET_VAL		},
{"methodVals["	    	, do_op	, JOB_OP_METHOD_VALS_BLOCK	},
#endif

{"]muqnetKeysvalsSet" , do_op , JOB_OP_MUQNET_SET_FROM_KEYSVALS_BLOCK},
{"]muqnetSet"		, do_op	, JOB_OP_MUQNET_SET_FROM_BLOCK	},
{"muqnetDelKey"	, do_op	, JOB_OP_MUQNET_DEL_KEY		},
{"muqnetDelKey?"	, do_op	, JOB_OP_MUQNET_DEL_KEY_P	},
{"muqnetGet"		, do_op	, JOB_OP_MUQNET_GET_VAL		},
{"muqnetGetFirstKey?", do_op	, JOB_OP_MUQNET_GET_FIRST_KEY	},
{"muqnetGetKey?"	, do_op	, JOB_OP_MUQNET_GET_KEY_P 	},
{"muqnetGetKeysByPrefix[", do_op, JOB_OP_MUQNET_GET_KEYS_BY_PREFIX},
{"muqnetGetNextKey?"	, do_op	, JOB_OP_MUQNET_GET_NEXT_KEY	},
{"muqnetGet?"		, do_op	, JOB_OP_MUQNET_GET_VAL_P	},
{"muqnetKeys["		, do_op	, JOB_OP_MUQNET_KEYS_BLOCK	},
{"muqnetKeysvals["	, do_op	, JOB_OP_MUQNET_KEYSVALS_BLOCK	},
{"muqnetSet"	  	, do_op	, JOB_OP_MUQNET_SET_VAL		},
{"muqnetVals["	    	, do_op	, JOB_OP_MUQNET_VALS_BLOCK	},

{"!="		    , do_op	, JOB_OP_ANE			},
{"!=-ci"	    , do_op	, JOB_OP_CASELESS_NE		},
{"ne"		    , do_op	, JOB_OP_ANE			},
{"ne_ci"	    , do_op	, JOB_OP_CASELESS_NE		},
{"%"		    , do_op	, JOB_OP_MOD			},
{"*"		    , do_op	, JOB_OP_MUL			},
{"*:"		    , do_colon	, 't'				},
{"+"		    , do_op	, JOB_OP_ADD			},
{"++"		    , do_incdec	, 1				},
{","		    , do_op	, JOB_OP_WRITE_OUTPUT_STREAM	},
{"-"		    , do_op	, JOB_OP_SUB			},
{"--"		    , do_incdec	, 0				},
{"-->"		    , do_aarrow	, 0				},
{"-->constant"	    , do_aarrow	, MODE_CONST			},
{"->"		    , do_arrow	, 0				},
{"."		    , do_op	, JOB_OP_ROOT			},
{"/"		    , do_op	, JOB_OP_DIV			},
{"1+"		    , do_op	, JOB_OP_INC			},
{"1-"		    , do_op	, JOB_OP_DEC			},
{":"		    , do_colon	, 0				},
{"::"		    , do_colon	, 'a'				},
{";"		    , do_semi	, 0				},
{"<"		    , do_op	, JOB_OP_ALT			},
{"<-ci"	            , do_op	, JOB_OP_CASELESS_LT		},
{"<="		    , do_op	, JOB_OP_ALE			},
{"<=-ci"	    , do_op	, JOB_OP_CASELESS_LE		},
{"="		    , do_op	, JOB_OP_AEQ			},
{"=-ci"	            , do_op	, JOB_OP_CASELESS_EQ		},
{"=>"		    , do_varbind, 0				},
{"=>fn"		    , do_funbind, 0				},
{">"		    , do_op	, JOB_OP_AGT			},
{">-ci"	            , do_op	, JOB_OP_CASELESS_GT		},
{">="		    , do_op	, JOB_OP_AGE			},
{">=-ci"	    , do_op	, JOB_OP_CASELESS_GE		},
{"lt"		    , do_op	, JOB_OP_ALT			},
{"lt_ci"	    , do_op	, JOB_OP_CASELESS_LT		},
{"le"		    , do_op	, JOB_OP_ALE			},
{"le_ci"	    , do_op	, JOB_OP_CASELESS_LE		},
{"eq"		    , do_op	, JOB_OP_AEQ			},
{"eq_ci"            , do_op	, JOB_OP_CASELESS_EQ		},
{"gt"		    , do_op	, JOB_OP_AGT			},
{"gt_ci"            , do_op	, JOB_OP_CASELESS_GT		},
{"ge"		    , do_op	, JOB_OP_AGE			},
{"ge_ci"	    , do_op	, JOB_OP_CASELESS_GE		},
{"=>"		    , do_varbind, 0				},
{"=>fn"		    , do_funbind, 0				},
{">"		    , do_op	, JOB_OP_AGT			},
{">-ci"	            , do_op	, JOB_OP_CASELESS_GT		},
{">="		    , do_op	, JOB_OP_AGE			},
{">=-ci"	    , do_op	, JOB_OP_CASELESS_GE		},
{"@"		    , do_op	, JOB_OP_JOB			},
{"["		    , do_lbrk	, 0				},
{"[?"		    , do_op	, JOB_OP_LBRK_P			},
{"]break"	    , do_op     , JOB_OP_BLOCK_BREAK		},
{"]closeSocket"     , do_op	, JOB_OP_CLOSE_SOCKET		},
{"]e"		    , do_brke	, 0				},
{"]evec"	    , do_op	, JOB_OP_MAKE_EPHEMERAL_VECTOR_FROM_BLOCK },
{"]exec"	    , do_op	, JOB_OP_EXEC			},
{"]glueStrings"    , do_op	, JOB_OP_GLUE_STRINGS_BLOCK	},
{"]inPackage"	    , do_op	, JOB_OP_BLOCK_IN_PACKAGE	},
{"]invokeHandler"  , do_op	, JOB_OP_INVOKE_HANDLER		},
{"]join"	    , do_op	, JOB_OP_JOIN_BLOCK		},
{"]joinStrings"    , do_op	, JOB_OP_JOIN_BLOCK		},
{"]keysvalsMake"   , do_op	, JOB_OP_MAKE_FROM_KEYSVALS_BLOCK},
{"]listenOnSocket", do_op	, JOB_OP_LISTEN_ON_SOCKET	},
{"]makeEphemeralList", do_op  , JOB_OP_MAKE_EPHEMERAL_LIST	},
{"]makeEphemeralVector", do_op, JOB_OP_MAKE_EPHEMERAL_VECTOR_FROM_BLOCK },
{"]makeNumber"     , do_op     , JOB_OP_MAKE_NUMBER		},
{"]makePackage"    , do_op	, JOB_OP_BLOCK_MAKE_PACKAGE	},
{"]makeProxy"	    , do_op	, JOB_OP_BLOCK_MAKE_PROXY	},
{"]makeStructure"  , do_op	, JOB_OP_MAKE_STRUCTURE		},
{"]makeSymbol"     , do_op     , JOB_OP_MAKE_SYMBOL_BLOCK	},
{"]makeVector"	    , do_op	, JOB_OP_MAKE_VECTOR_FROM_BLOCK	},
{"]makeVectorI01"    , do_op	, JOB_OP_MAKE_VECTOR_I01_FROM_BLOCK	},
{"]makeVectorI08"    , do_op	, JOB_OP_MAKE_VECTOR_I08_FROM_BLOCK	},
{"]makeVectorI16"    , do_op	, JOB_OP_MAKE_VECTOR_I16_FROM_BLOCK	},
{"]makeVectorI32"    , do_op	, JOB_OP_MAKE_VECTOR_I32_FROM_BLOCK	},
{"]makeVectorF32"    , do_op	, JOB_OP_MAKE_VECTOR_F32_FROM_BLOCK	},
{"]makeVectorF64"    , do_op	, JOB_OP_MAKE_VECTOR_F64_FROM_BLOCK	},
{"]openSocket"     , do_op	, JOB_OP_OPEN_SOCKET		},
{"]pop"		    , do_op	, JOB_OP_POP_BLOCK		},
{"]popNth"	    , do_op	, JOB_OP_POP_NTH_AND_BLOCK	},
{"]print"	    , do_op	, JOB_OP_PRINT_STRING		},
{"]printString"    , do_op	, JOB_OP_PRINT_STRING		},
{"]push"	    , do_op	, JOB_OP_PUSH_BLOCK		},
{"]pushHandlersframe", do_op	, JOB_OP_PUSH_HANDLERSFRAME	},
{"]pushRestartframe", do_op	, JOB_OP_PUSH_RESTARTFRAME	},
{"]renamePackage"  , do_op	, JOB_OP_BLOCK_RENAME_PACKAGE	},
{"]replaceSubstrings",do_op	, JOB_OP_REPLACE_SUBSTRINGS	},
{"]rootLogPrint"    , do_op	, JOB_OP_ROOT_LOG_PRINT		},
{"]rootPopenSocket",do_op	, JOB_OP_ROOT_POPEN_SOCKET	},
{"]setLocalVars"  , do_op     , JOB_OP_SET_LOCAL_VARS		},
{"]shift"	    , do_op	, JOB_OP_SHIFT_AND_POP		},
{"]shift2"	    , do_op	, JOB_OP_SHIFT_2_AND_POP	},
{"]shift3"	    , do_op	, JOB_OP_SHIFT_3_AND_POP	},
{"]shift4"	    , do_op	, JOB_OP_SHIFT_4_AND_POP	},
{"]shift5"	    , do_op	, JOB_OP_SHIFT_5_AND_POP	},
{"]shift6"	    , do_op	, JOB_OP_SHIFT_6_AND_POP	},
{"]shift7"	    , do_op	, JOB_OP_SHIFT_7_AND_POP	},
{"]shift8"	    , do_op	, JOB_OP_SHIFT_8_AND_POP	},
{"]shift9"	    , do_op	, JOB_OP_SHIFT_9_AND_POP	},
{"]signal"	    , do_op	, JOB_OP_SIGNAL			},
{"]throw"	    , do_op	, JOB_OP_THROW			},
{"]vec"		    , do_op	, JOB_OP_MAKE_VECTOR_FROM_BLOCK	},
{"]withHandlerDo{" ,do_withhandlers, 0				},
{"]withHandlersDo{",do_withhandlers, 0				},
{"]withRestartDo{", do_withrestart, 0				},
{"]words"	    , do_op	, JOB_OP_WORDS_TO_STRING	},
{"]|join"	    , do_op	, JOB_OP_JOIN_BLOCKS		},
{"abs"		    , do_op	, JOB_OP_ABS			},
{"acos"		    , do_op	, JOB_OP_ACOS			},
{"actingUser"	    , do_op	, JOB_OP_ACTING_USER		},
{"actualUser"	    , do_op	, JOB_OP_ACTUAL_USER		},
{"addMufSource"   , do_op	, JOB_OP_ADD_MUF_SOURCE		},
{"after{"	    , do_after	, 0				},
{"afterChildDoes{", do_after	, 1				},
{"afterParentDoes{", do_after	, 0				},
{"alphaChar?"	    , do_op	, JOB_OP_ALPHA_CHAR_P		},
{"alphanumeric?"    , do_op	, JOB_OP_ALPHANUMERIC_P		},
{"and"		    , do_op	, JOB_OP_AND			},
{"aref"		    , do_op	, JOB_OP_AREF			},
{"array?"	    , do_op	, JOB_OP_ARRAY_P		},
{"asMeDo{"	    , do_as_me	, 0				},
{"aset"		    , do_op	, JOB_OP_ASET			},
{"ash"		    , do_op	, JOB_OP_SHIFT_BITS		},
{"asin"		    , do_op	, JOB_OP_ASIN			},
{"assembleAfter"   , do_op	, JOB_OP_ASSEMBLE_AFTER		},
{"assembleAfterChild", do_op	, JOB_OP_ASSEMBLE_AFTER_CHILD	},
{"assembleAlwaysDo",do_op	, JOB_OP_ASSEMBLE_ALWAYS_DO	},
{"assembleBeq"	    , do_op	, JOB_OP_ASSEMBLE_BEQ		},
{"assembleBne"	    , do_op	, JOB_OP_ASSEMBLE_BNE		},
{"assembleBra"	    , do_op	, JOB_OP_ASSEMBLE_BRA		},
{"assembleCall"    , do_op	, JOB_OP_ASSEMBLE_CALL		},
{"assembleCalla"   , do_op	, JOB_OP_ASSEMBLE_CALLA		},
{"assembleCatch"   , do_op	, JOB_OP_ASSEMBLE_CATCH		},
{"assembleConstant"    , do_op	, JOB_OP_ASSEMBLE_CONSTANT	},
{"assembleConstantGet", do_op	, JOB_OP_ASSEMBLE_NTH_CONSTANT_GET},
{"assembleConstantSlot", do_op, JOB_OP_ASSEMBLE_CONSTANT_SLOT	},
{"assembleLabel"   , do_op	, JOB_OP_ASSEMBLE_LABEL		},
{"assembleLabelGet",do_op	, JOB_OP_ASSEMBLE_LABEL_GET	},
{"assembleLineInFn",do_op	, JOB_OP_ASSEMBLE_LINE_IN_FN	},/* Should drop? */
{"assembleTag"	    , do_op	, JOB_OP_ASSEMBLE_TAG		},
{"assembleVariableGet", do_op	, JOB_OP_ASSEMBLE_VARIABLE_GET	},
{"assembleVariableSet", do_op	, JOB_OP_ASSEMBLE_VARIABLE_SET	},
{"assembleVariableSlot",do_op	, JOB_OP_ASSEMBLE_VARIABLE_SLOT	},
{"assembler?"	    , do_op	, JOB_OP_ASSEMBLER_P		},
{"atan"		    , do_op	, JOB_OP_ATAN			},
{"atan2"	    , do_op	, JOB_OP_ATAN2			},
{"bias"		    , do_op	, JOB_OP_BIAS			},
{"bignum?"	    , do_op	, JOB_OP_BIGNUM_P		},
{"bits"		    , do_op	, JOB_OP_BITS			},
{"block?"	    , do_op	, JOB_OP_BLOCK_P		},
{"bound?"	    , do_op	, JOB_OP_BOUND_P		},
{"break"	    , do_op     , JOB_OP_BREAK			},
#ifdef OLD
{"btreeGet"	    , do_op     , JOB_OP_BTREE_GET		},
{"btreeSet"	    , do_op     , JOB_OP_BTREE_SET		},
{"btreeDelete"	    , do_op     , JOB_OP_BTREE_DELETE		},
{"btreeFirst"	    , do_op     , JOB_OP_BTREE_FIRST		},
{"btreeNext"	    , do_op     , JOB_OP_BTREE_NEXT		},
{"copyBtree"	    , do_op     , JOB_OP_COPY_BTREE		},
#endif
{"call"		    , do_op	, JOB_OP_CALL			},
{"callable?"	    , do_op	, JOB_OP_CALLABLE_P		},
{"call{"	    , do_calla	, 0				},
{"car"		    , do_op	, JOB_OP_CAR			},
{"case{"	    , do_case	, 0				},
{"catch"	    , do_catch	, 0				},
{"catch{"	    , do_catch	, 0				},
{"cd"	    	    , do_op	, JOB_OP_SET_HERE		},
{"cdr"		    , do_op	, JOB_OP_CDR			},
{"ceiling"	    , do_op	, JOB_OP_CEILING		},
{"charInt"	    , do_op	, JOB_OP_CHAR_TO_INT		},
{"charString"	    , do_op	, JOB_OP_CHAR_TO_STRING		},
{"char?"	    , do_op	, JOB_OP_CHAR_P			},
{"chars2Int"	    , do_op	, JOB_OP_CHARS2_TO_INT		},
{"chars4Int"	    , do_op	, JOB_OP_CHARS4_TO_INT		},
{"chopString["	    , do_op	, JOB_OP_CHOP_STRING		},
{"clamp"	    , do_op	, JOB_OP_CLAMP			},
{"class"	    , do_op	, JOB_OP_CLASS			},
{"compileTime"	    , do_compile_time, 0			},
{"compiledFunctionBytecodes[",do_op, JOB_OP_COMPILED_FUNCTION_BYTECODES},
{"compiledFunctionConstants[",do_op, JOB_OP_COMPILED_FUNCTION_CONSTANTS},
{"compiledFunctionDisassembly",do_op, JOB_OP_COMPILED_FUNCTION_DISASSEMBLY},
{"compiledFunction?",do_op	, JOB_OP_COMPILED_FUNCTION_P	},
{"cons"		    , do_op	, JOB_OP_CONS			},
{"cons?"	    , do_op	, JOB_OP_CONS_P			},
{"constant?"	    , do_op	, JOB_OP_CONSTANTP		},
{"continueMufCompile" , do_op	, JOB_OP_CONTINUE_MUF_COMPILE	},
{"controlChar?"    , do_op	, JOB_OP_CONTROL_CHAR_P		},
{"control?"	    , do_op	, JOB_OP_CONTROLP		},
{"copy"		    , do_op	, JOB_OP_COPY			},
{"copyCfn"	    , do_op	, JOB_OP_COPY_CFN		},
{"copyJob"	    , do_op	, JOB_OP_COPY_JOB		},
{"copyJobset"      , do_op	, JOB_OP_COPY_JOB_SET		},
{"copyMosKeySlot", do_op	, JOB_OP_COPY_MOS_KEY_SLOT	},
{"copySession"     , do_op	, JOB_OP_COPY_SESSION		},
{"copyStructure"   , do_op	, JOB_OP_COPY_STRUCTURE		},
{"copyStructureContents",do_op, JOB_OP_COPY_STRUCTURE_CONTENTS},
{"cos"		    , do_op	, JOB_OP_COS			},
{"cosh"		    , do_op	, JOB_OP_COSH			},
{"countLinesInString", do_op	, JOB_OP_COUNT_LINES_IN_STRING	},
{"countStackframes", do_op	, JOB_OP_COUNT_STACKFRAMES	},
{"crossProduct"    , do_op	, JOB_OP_CROSS_PRODUCT		},
{"currentCompiledFunction",do_op,JOB_OP_CURRENT_COMPILED_FUNCTION},
{"dataStack?"	    , do_op	, JOB_OP_DATA_STACK_P		},
{"dbnameToInt"   , do_op	, JOB_OP_DBNAME_TO_INT		},
{"dbrefToInts3"   , do_op	, JOB_OP_DBREF_TO_INTS3		},
{"defineWord:"	    , do_colon	, 0				},
{"delete"	    , do_op	, JOB_OP_DELETE			},
{"delete:"	    , do_delete	, 0				},
{"deleteBth"	    , do_op	, JOB_OP_DELETE_BTH		},
{"deleteMosKeyClassMethod" , do_op, JOB_OP_DELETE_MOS_KEY_CLASS_METHOD},
{"deleteMosKeyObjectMethod", do_op, JOB_OP_DELETE_MOS_KEY_OBJECT_METHOD},
{"deleteNth"	    , do_op	, JOB_OP_DELETE_NTH		},
{"deletePackage"   , do_op	, JOB_OP_DELETE_PACKAGE		},
{"depth"	    , do_op	, JOB_OP_DEPTH			},
{"digitChar?"	    , do_op	, JOB_OP_DIGIT_CHAR_P		},
{"distance"         , do_op	, JOB_OP_DISTANCE		},
{"do{"	 	    , do_loop	, 0				},
{"dotProduct"       , do_op	, JOB_OP_DOT_PRODUCT		},
{"downcase"	    , do_op	, JOB_OP_DOWNCASE 		},
{"dup"		    , do_op	, JOB_OP_DUP			},
{"dup["		    , do_op	, JOB_OP_DUP_ARGS_INTO_BLOCK	},
{"dup2nd"	    , do_op	, JOB_OP_OVER			},
{"dupBth"	    , do_op	, JOB_OP_DUP_BTH		},
{"dupNth"	    , do_op	, JOB_OP_DUP_NTH		},
{"econs"	    , do_op	, JOB_OP_EPHEMERAL_CONS		},
{"egcd" 	    , do_op	, JOB_OP_EGCD			},
{"else"		    , do_else	, 0				},
{"else:"	    , do_case_else, 0				},
{"empty?"	    , do_op	, JOB_OP_EMPTY_P		},
{"endBlock"	    , do_op	, JOB_OP_END_BLOCK		},
{"endJob"	    , do_op	, JOB_OP_END_JOB		},
{"end?"		    , do_op	, JOB_OP_END_P			},
{"ephemeral?"       , do_op	, JOB_OP_EPHEMERAL_P		},
{"ephemeralCons"   , do_op	, JOB_OP_EPHEMERAL_CONS		},
{"eq"		    , do_op	, JOB_OP_EQ			},
{"eql"		    , do_op	, JOB_OP_AEQ			},
{"evec"		    , do_op	, JOB_OP_MAKE_EPHEMERAL_VECTOR  },
{"exp"		    , do_op	, JOB_OP_EXP			},
{"expandCStringEscapes",do_op, JOB_OP_EXPAND_C_STRING_ESCAPES},
{"export"	    , do_op	, JOB_OP_EXPORT			},
{"expt"		    , do_op	, JOB_OP_POW			},
{"exptmod"	    , do_op	, JOB_OP_EXPTMOD		},
{"fBm"		    , do_op	, JOB_OP_FBM			},
{"fceiling"	    , do_op	, JOB_OP_FCEILING		},
{"ffloor"	    , do_op	, JOB_OP_FFLOOR			},
{"fi"		    , do_rightbrace	, 0			},
{"findLastSubstringCi?",do_op,JOB_OP_CASELESS_FIND_LAST_SUBSTRING_P},
{"findLastSubstring?", do_op	, JOB_OP_FIND_LAST_SUBSTRING_P	},
#ifdef OLD
{"findMethod"	    , do_op	, JOB_OP_FIND_METHOD		},
{"findMethod?"	    , do_op	, JOB_OP_FIND_METHOD_P		},
#endif
{"findNextSubstringCi?", do_op, JOB_OP_CASELESS_FIND_NEXT_SUBSTRING_P},
{"findNextSubstring?", do_op	, JOB_OP_FIND_NEXT_SUBSTRING_P	},
{"findPackage"	    , do_op	, JOB_OP_FIND_PACKAGE		},
{"findPreviousSubstringCi?", do_op, JOB_OP_CASELESS_FIND_PREVIOUS_SUBSTRING_P	},
{"findPreviousSubstring?", do_op, JOB_OP_FIND_PREVIOUS_SUBSTRING_P	},
{"findMosKeyClassMethod?",do_op,JOB_OP_FIND_MOS_KEY_CLASS_METHOD},
{"findMosKeyObjectMethod?",do_op,JOB_OP_FIND_MOS_KEY_OBJECT_METHOD},
{"findMosKeySlot", do_op	, JOB_OP_FIND_MOS_KEY_SLOT 	},
{"findSubstringCi?" , do_op	, JOB_OP_CASELESS_FIND_SUBSTRING_P },
{"findSubstring?"    , do_op	, JOB_OP_FIND_SUBSTRING_P	},
{"finishAssembly"  , do_op	, JOB_OP_FINISH_ASSEMBLY	},
{"first"	    , do_op	, JOB_OP_CAR			},
{"fixnum?"	    , do_op	, JOB_OP_FIXNUM_P		},
{"float?"	    , do_op	, JOB_OP_FLOAT_P		},
{"floor"	    , do_op	, JOB_OP_FLOOR			},
{"flush"	    , do_op	, JOB_OP_FLUSH			},
{"flushStream"	    , do_op	, JOB_OP_FLUSH_STREAM		},
{"for"		    , do_for	, 0				},
{"foreach"	    , do_foreach, (Vm_Unt)OBJ_PROP_PUBLIC	},
{"foreachAdmins"  , do_foreach, (Vm_Unt)OBJ_PROP_ADMINS	},
{"foreachHidden"  , do_foreach, (Vm_Unt)OBJ_PROP_HIDDEN	},
#ifdef OLD
{"foreachMethod"  , do_foreach, (Vm_Unt)OBJ_PROP_METHOD	},
#endif
{"folk?"	    , do_op	, JOB_OP_FOLK_P			},
{"foreachSystem"  , do_foreach, (Vm_Unt)OBJ_PROP_SYSTEM	},
{"frandom"	    , do_op	, JOB_OP_RANDOM			},
{"function?"	    , do_op	, JOB_OP_FUNCTION_P		},
{"gain"   	    , do_op	, JOB_OP_GAIN			},
{"gammacorrect"	    , do_op	, JOB_OP_GAMMACORRECT		},
{"gcd"   	    , do_op	, JOB_OP_GCD			},
{"generateDiffieHellmanKeyPair" , do_op	, JOB_OP_GENERATE_DIFFIE_HELLMAN_KEY_PAIR},
{"generateDiffieHellmanSharedSecret" , do_op	, JOB_OP_GENERATE_DIFFIE_HELLMAN_SHARED_SECRET},
{"getHere"    	    , do_op	, JOB_OP_GET_HERE		},
{"getMosKeyAncestor", do_op, JOB_OP_GET_MOS_KEY_ANCESTOR	},
{"getMosKeyAncestor?",do_op, JOB_OP_GET_MOS_KEY_ANCESTOR_P	},
{"getMosKeyClassMethod", do_op  , JOB_OP_GET_MOS_KEY_CLASS_METHOD},
{"getMosKeyInitarg", do_op , JOB_OP_GET_MOS_KEY_INITARG  },
{"getMosKeyMetharg", do_op , JOB_OP_GET_MOS_KEY_METHARG  },
{"getMosKeySlotarg", do_op , JOB_OP_GET_MOS_KEY_SLOTARG  },
{"getMosKeyObjectMethod", do_op  , JOB_OP_GET_MOS_KEY_OBJECT_METHOD},
{"getMosKeyParent", do_op  , JOB_OP_GET_MOS_KEY_PARENT	},
{"getMosKeySlotProperty", do_op, JOB_OP_GET_MOS_KEY_SLOT_PROPERTY},
{"getLambdaSlotProperty", do_op, JOB_OP_GET_LAMBDA_SLOT_PROPERTY},
{"getLineFromString", do_op	, JOB_OP_GET_LINE_FROM_STRING	},
{"getMethodSlot"  , do_op	, JOB_OP_GET_METHOD_SLOT	},
{"getMosKey" 	    , do_op	, JOB_OP_GET_MOS_KEY		},
{"getMuqnetIo"    , do_op	, JOB_OP_GET_MUQNET_IO		},
{"getNthRestart"  , do_op	, JOB_OP_GET_NTH_RESTART	},
{"getNthStructureSlot", do_op, JOB_OP_GET_NTH_STRUCTURE_SLOT	},
{"getRestart"	    , do_op	, JOB_OP_GET_RESTART		},
{"getSocketCharEvent",do_op     , JOB_OP_GET_SOCKET_CHAR_EVENT  },
{"getStackframe["  , do_op	, JOB_OP_GET_STACKFRAME 	},
{"getNamedStructureSlot", do_op, JOB_OP_GET_NAMED_STRUCTURE_SLOT},

{"glClearIndex"		, do_op, JOB_OP_GL_CLEAR_INDEX },
{"glClearColor"		, do_op, JOB_OP_GL_CLEAR_COLOR },
{"glClear"		, do_op, JOB_OP_GL_CLEAR },
{"glIndexMask"		, do_op, JOB_OP_GL_INDEX_MASK },
{"glColorMask"		, do_op, JOB_OP_GL_COLOR_MASK },
{"glAlphaFunc"		, do_op, JOB_OP_GL_ALPHA_FUNC },
{"glBlendFunc"		, do_op, JOB_OP_GL_BLEND_FUNC },
{"glLogicOp"		, do_op, JOB_OP_GL_LOGIC_OP },
{"glCullFace"		, do_op, JOB_OP_GL_CULL_FACE },
{"glFrontFace"		, do_op, JOB_OP_GL_FRONT_FACE },
{"glPointSize"		, do_op, JOB_OP_GL_POINT_SIZE },
{"glLineWidth"		, do_op, JOB_OP_GL_LINE_WIDTH },
{"glLineStipple"		, do_op, JOB_OP_GL_LINE_STIPPLE },
{"glPolygonMode"		, do_op, JOB_OP_GL_POLYGON_MODE },
{"glPolygonOffset"		, do_op, JOB_OP_GL_POLYGON_OFFSET },
{"glPolygonStipple"		, do_op, JOB_OP_GL_POLYGON_STIPPLE },
{"glGetPolygonStipple"		, do_op, JOB_OP_GL_GET_POLYGON_STIPPLE },
{"glEdgeFlag"		, do_op, JOB_OP_GL_EDGE_FLAG },
{"glEdgeFlagv"		, do_op, JOB_OP_GL_EDGE_FLAGV },
{"glScissor"		, do_op, JOB_OP_GL_SCISSOR },
{"glClipPlane"		, do_op, JOB_OP_GL_CLIP_PLANE },
{"glGetClipPlane"		, do_op, JOB_OP_GL_GET_CLIP_PLANE },
{"glDrawBuffer"		, do_op, JOB_OP_GL_DRAW_BUFFER },
{"glReadBuffer"		, do_op, JOB_OP_GL_READ_BUFFER },
{"glEnable"		, do_op, JOB_OP_GL_ENABLE },
{"glDisable"		, do_op, JOB_OP_GL_DISABLE },
{"glIsEnabled"		, do_op, JOB_OP_GL_IS_ENABLED },
{"glEnableClientState"	, do_op, JOB_OP_GL_ENABLE_CLIENT_STATE },
{"glDisableClientState"	, do_op, JOB_OP_GL_DISABLE_CLIENT_STATE },
{"glGetBoolean"		, do_op, JOB_OP_GL_GET_BOOLEAN },
{"glGetDouble"		, do_op, JOB_OP_GL_GET_DOUBLE },
{"glGetFloat"		, do_op, JOB_OP_GL_GET_FLOAT },
{"glGetInteger"		, do_op, JOB_OP_GL_GET_INTEGER },
{"glGetBoolean["	, do_op, JOB_OP_GL_GET_BOOLEAN_BLOCK },
{"glGetDouble["		, do_op, JOB_OP_GL_GET_DOUBLE_BLOCK },
{"glGetFloat["		, do_op, JOB_OP_GL_GET_FLOAT_BLOCK },
{"glGetInteger["	, do_op, JOB_OP_GL_GET_INTEGER_BLOCK },
{"glGetBooleanv"	, do_op, JOB_OP_GL_GET_BOOLEANV },
{"glGetDoublev"		, do_op, JOB_OP_GL_GET_DOUBLEV },
{"glGetFloatv"		, do_op, JOB_OP_GL_GET_FLOATV },
{"glGetIntegerv"	, do_op, JOB_OP_GL_GET_INTEGERV },
{"glPushAttrib"		, do_op, JOB_OP_GL_PUSH_ATTRIB },
{"glPopAttrib"		, do_op, JOB_OP_GL_POP_ATTRIB },
{"glPushClientAttrib"	, do_op, JOB_OP_GL_PUSH_CLIENT_ATTRIB },
{"glPopClientAttrib"	, do_op, JOB_OP_GL_POP_CLIENT_ATTRIB },
{"glRenderMode"		, do_op, JOB_OP_GL_RENDER_MODE },
{"glGetError"		, do_op, JOB_OP_GL_GET_ERROR },
{"glGetString"		, do_op, JOB_OP_GL_GET_STRING },
{"glFinish"		, do_op, JOB_OP_GL_FINISH },
{"glFlush"		, do_op, JOB_OP_GL_FLUSH },
{"glHint"		, do_op, JOB_OP_GL_HINT },
{"glClearDepth"		, do_op, JOB_OP_GL_CLEAR_DEPTH },
{"glDepthFunc"		, do_op, JOB_OP_GL_DEPTH_FUNC },
{"glDepthMask"		, do_op, JOB_OP_GL_DEPTH_MASK },
{"glDepthRange"		, do_op, JOB_OP_GL_DEPTH_RANGE },
{"glClearAccum"		, do_op, JOB_OP_GL_CLEAR_ACCUM },
{"glAccum"		, do_op, JOB_OP_GL_ACCUM },
{"glMatrixMode"		, do_op, JOB_OP_GL_MATRIX_MODE },
{"glOrtho"		, do_op, JOB_OP_GL_ORTHO },
{"glFrustum"		, do_op, JOB_OP_GL_FRUSTUM },
{"glViewport"		, do_op, JOB_OP_GL_VIEWPORT },
{"glPushMatrix"		, do_op, JOB_OP_GL_PUSH_MATRIX },
{"glPopMatrix"		, do_op, JOB_OP_GL_POP_MATRIX },
{"glLoadIdentity"		, do_op, JOB_OP_GL_LOAD_IDENTITY },
{"glLoadMatrixd"		, do_op, JOB_OP_GL_LOAD_MATRIXD },
{"glLoadMatrixf"		, do_op, JOB_OP_GL_LOAD_MATRIXF },
{"glMultMatrixd"		, do_op, JOB_OP_GL_MULT_MATRIXD },
{"glMultMatrixf"		, do_op, JOB_OP_GL_MULT_MATRIXF },
{"glRotated"		, do_op, JOB_OP_GL_ROTATED },
{"glRotatef"		, do_op, JOB_OP_GL_ROTATEF },
{"glScaled"		, do_op, JOB_OP_GL_SCALED },
{"glScalef"		, do_op, JOB_OP_GL_SCALEF },
{"glTranslated"		, do_op, JOB_OP_GL_TRANSLATED },
{"glTranslatef"		, do_op, JOB_OP_GL_TRANSLATEF },
{"glIsList"		, do_op, JOB_OP_GL_IS_LIST },
{"glDeleteLists"		, do_op, JOB_OP_GL_DELETE_LISTS },
{"glGenLists"		, do_op, JOB_OP_GL_GEN_LISTS },
{"glNewList"		, do_op, JOB_OP_GL_NEW_LIST },
{"glEndList"		, do_op, JOB_OP_GL_END_LIST },
{"glCallList"		, do_op, JOB_OP_GL_CALL_LIST },
{"glCallLists"		, do_op, JOB_OP_GL_CALL_LISTS },
{"glListBase"		, do_op, JOB_OP_GL_LIST_BASE },
{"glBegin"		, do_op, JOB_OP_GL_BEGIN },
{"glEnd"		, do_op, JOB_OP_GL_END },
{"glVertex2d"		, do_op, JOB_OP_GL_VERTEX2D },
{"glVertex2f"		, do_op, JOB_OP_GL_VERTEX2F },
{"glVertex2i"		, do_op, JOB_OP_GL_VERTEX2I },
{"glVertex2s"		, do_op, JOB_OP_GL_VERTEX2S },
{"glVertex3d"		, do_op, JOB_OP_GL_VERTEX3D },
{"glVertex3f"		, do_op, JOB_OP_GL_VERTEX3F },
{"glVertex3i"		, do_op, JOB_OP_GL_VERTEX3I },
{"glVertex3s"		, do_op, JOB_OP_GL_VERTEX3S },
{"glVertex4d"		, do_op, JOB_OP_GL_VERTEX4D },
{"glVertex4f"		, do_op, JOB_OP_GL_VERTEX4F },
{"glVertex4i"		, do_op, JOB_OP_GL_VERTEX4I },
{"glVertex4s"		, do_op, JOB_OP_GL_VERTEX4S },
{"glVertex2dv"		, do_op, JOB_OP_GL_VERTEX2DV },
{"glVertex2fv"		, do_op, JOB_OP_GL_VERTEX2FV },
{"glVertex2iv"		, do_op, JOB_OP_GL_VERTEX2IV },
{"glVertex2sv"		, do_op, JOB_OP_GL_VERTEX2SV },
{"glVertex3dv"		, do_op, JOB_OP_GL_VERTEX3DV },
{"glVertex3fv"		, do_op, JOB_OP_GL_VERTEX3FV },
{"glVertex3iv"		, do_op, JOB_OP_GL_VERTEX3IV },
{"glVertex3sv"		, do_op, JOB_OP_GL_VERTEX3SV },
{"glVertex4dv"		, do_op, JOB_OP_GL_VERTEX4DV },
{"glVertex4fv"		, do_op, JOB_OP_GL_VERTEX4FV },
{"glVertex4iv"		, do_op, JOB_OP_GL_VERTEX4IV },
{"glVertex4sv"		, do_op, JOB_OP_GL_VERTEX4SV },
{"glNormal3b"		, do_op, JOB_OP_GL_NORMAL3B },
{"glNormal3d"		, do_op, JOB_OP_GL_NORMAL3D },
{"glNormal3f"		, do_op, JOB_OP_GL_NORMAL3F },
{"glNormal3i"		, do_op, JOB_OP_GL_NORMAL3I },
{"glNormal3s"		, do_op, JOB_OP_GL_NORMAL3S },
{"glNormal3bv"		, do_op, JOB_OP_GL_NORMAL3BV },
{"glNormal3dv"		, do_op, JOB_OP_GL_NORMAL3DV },
{"glNormal3fv"		, do_op, JOB_OP_GL_NORMAL3FV },
{"glNormal3iv"		, do_op, JOB_OP_GL_NORMAL3IV },
{"glNormal3sv"		, do_op, JOB_OP_GL_NORMAL3SV },
{"glIndexd"		, do_op, JOB_OP_GL_INDEXD },
{"glIndexf"		, do_op, JOB_OP_GL_INDEXF },
{"glIndexi"		, do_op, JOB_OP_GL_INDEXI },
{"glIndexs"		, do_op, JOB_OP_GL_INDEXS },
{"glIndexub"		, do_op, JOB_OP_GL_INDEXUB },
{"glIndexdv"		, do_op, JOB_OP_GL_INDEXDV },
{"glIndexfv"		, do_op, JOB_OP_GL_INDEXFV },
{"glIndexiv"		, do_op, JOB_OP_GL_INDEXIV },
{"glIndexsv"		, do_op, JOB_OP_GL_INDEXSV },
{"glIndexubv"		, do_op, JOB_OP_GL_INDEXUBV },
{"glColor3b"		, do_op, JOB_OP_GL_COLOR3B },
{"glColor3d"		, do_op, JOB_OP_GL_COLOR3D },
{"glColor3f"		, do_op, JOB_OP_GL_COLOR3F },
{"glColor3i"		, do_op, JOB_OP_GL_COLOR3I },
{"glColor3s"		, do_op, JOB_OP_GL_COLOR3S },
{"glColor3ub"		, do_op, JOB_OP_GL_COLOR3UB },
{"glColor3ui"		, do_op, JOB_OP_GL_COLOR3UI },
{"glColor3us"		, do_op, JOB_OP_GL_COLOR3US },
{"glColor4b"		, do_op, JOB_OP_GL_COLOR4B },
{"glColor4d"		, do_op, JOB_OP_GL_COLOR4D },
{"glColor4f"		, do_op, JOB_OP_GL_COLOR4F },
{"glColor4i"		, do_op, JOB_OP_GL_COLOR4I },
{"glColor4s"		, do_op, JOB_OP_GL_COLOR4S },
{"glColor4ub"		, do_op, JOB_OP_GL_COLOR4UB },
{"glColor4ui"		, do_op, JOB_OP_GL_COLOR4UI },
{"glColor4us"		, do_op, JOB_OP_GL_COLOR4US },
{"glColor3bv"		, do_op, JOB_OP_GL_COLOR3BV },
{"glColor3dv"		, do_op, JOB_OP_GL_COLOR3DV },
{"glColor3fv"		, do_op, JOB_OP_GL_COLOR3FV },
{"glColor3iv"		, do_op, JOB_OP_GL_COLOR3IV },
{"glColor3sv"		, do_op, JOB_OP_GL_COLOR3SV },
{"glColor3ubv"		, do_op, JOB_OP_GL_COLOR3UBV },
{"glColor3uiv"		, do_op, JOB_OP_GL_COLOR3UIV },
{"glColor3usv"		, do_op, JOB_OP_GL_COLOR3USV },
{"glColor4bv"		, do_op, JOB_OP_GL_COLOR4BV },
{"glColor4dv"		, do_op, JOB_OP_GL_COLOR4DV },
{"glColor4fv"		, do_op, JOB_OP_GL_COLOR4FV },
{"glColor4iv"		, do_op, JOB_OP_GL_COLOR4IV },
{"glColor4sv"		, do_op, JOB_OP_GL_COLOR4SV },
{"glColor4ubv"		, do_op, JOB_OP_GL_COLOR4UBV },
{"glColor4uiv"		, do_op, JOB_OP_GL_COLOR4UIV },
{"glColor4usv"		, do_op, JOB_OP_GL_COLOR4USV },
{"glTexCoord1d"		, do_op, JOB_OP_GL_TEX_COORD1D },
{"glTexCoord1f"		, do_op, JOB_OP_GL_TEX_COORD1F },
{"glTexCoord1i"		, do_op, JOB_OP_GL_TEX_COORD1I },
{"glTexCoord1s"		, do_op, JOB_OP_GL_TEX_COORD1S },
{"glTexCoord2d"		, do_op, JOB_OP_GL_TEX_COORD2D },
{"glTexCoord2f"		, do_op, JOB_OP_GL_TEX_COORD2F },
{"glTexCoord2i"		, do_op, JOB_OP_GL_TEX_COORD2I },
{"glTexCoord2s"		, do_op, JOB_OP_GL_TEX_COORD2S },
{"glTexCoord3d"		, do_op, JOB_OP_GL_TEX_COORD3D },
{"glTexCoord3f"		, do_op, JOB_OP_GL_TEX_COORD3F },
{"glTexCoord3i"		, do_op, JOB_OP_GL_TEX_COORD3I },
{"glTexCoord3s"		, do_op, JOB_OP_GL_TEX_COORD3S },
{"glTexCoord4d"		, do_op, JOB_OP_GL_TEX_COORD4D },
{"glTexCoord4f"		, do_op, JOB_OP_GL_TEX_COORD4F },
{"glTexCoord4i"		, do_op, JOB_OP_GL_TEX_COORD4I },
{"glTexCoord4s"		, do_op, JOB_OP_GL_TEX_COORD4S },
{"glTexCoord1dv"		, do_op, JOB_OP_GL_TEX_COORD1DV },
{"glTexCoord1fv"		, do_op, JOB_OP_GL_TEX_COORD1FV },
{"glTexCoord1iv"		, do_op, JOB_OP_GL_TEX_COORD1IV },
{"glTexCoord1sv"		, do_op, JOB_OP_GL_TEX_COORD1SV },
{"glTexCoord2dv"		, do_op, JOB_OP_GL_TEX_COORD2DV },
{"glTexCoord2fv"		, do_op, JOB_OP_GL_TEX_COORD2FV },
{"glTexCoord2iv"		, do_op, JOB_OP_GL_TEX_COORD2IV },
{"glTexCoord2sv"		, do_op, JOB_OP_GL_TEX_COORD2SV },
{"glTexCoord3dv"		, do_op, JOB_OP_GL_TEX_COORD3DV },
{"glTexCoord3fv"		, do_op, JOB_OP_GL_TEX_COORD3FV },
{"glTexCoord3iv"		, do_op, JOB_OP_GL_TEX_COORD3IV },
{"glTexCoord3sv"		, do_op, JOB_OP_GL_TEX_COORD3SV },
{"glTexCoord4dv"		, do_op, JOB_OP_GL_TEX_COORD4DV },
{"glTexCoord4fv"		, do_op, JOB_OP_GL_TEX_COORD4FV },
{"glTexCoord4iv"		, do_op, JOB_OP_GL_TEX_COORD4IV },
{"glTexCoord4sv"		, do_op, JOB_OP_GL_TEX_COORD4SV },
{"glRasterPos2d"		, do_op, JOB_OP_GL_RASTER_POS2D },
{"glRasterPos2f"		, do_op, JOB_OP_GL_RASTER_POS2F },
{"glRasterPos2i"		, do_op, JOB_OP_GL_RASTER_POS2I },
{"glRasterPos2s"		, do_op, JOB_OP_GL_RASTER_POS2S },
{"glRasterPos3d"		, do_op, JOB_OP_GL_RASTER_POS3D },
{"glRasterPos3f"		, do_op, JOB_OP_GL_RASTER_POS3F },
{"glRasterPos3i"		, do_op, JOB_OP_GL_RASTER_POS3I },
{"glRasterPos3s"		, do_op, JOB_OP_GL_RASTER_POS3S },
{"glRasterPos4d"		, do_op, JOB_OP_GL_RASTER_POS4D },
{"glRasterPos4f"		, do_op, JOB_OP_GL_RASTER_POS4F },
{"glRasterPos4i"		, do_op, JOB_OP_GL_RASTER_POS4I },
{"glRasterPos4s"		, do_op, JOB_OP_GL_RASTER_POS4S },
{"glRasterPos2dv"		, do_op, JOB_OP_GL_RASTER_POS2DV },
{"glRasterPos2fv"		, do_op, JOB_OP_GL_RASTER_POS2FV },
{"glRasterPos2iv"		, do_op, JOB_OP_GL_RASTER_POS2IV },
{"glRasterPos2sv"		, do_op, JOB_OP_GL_RASTER_POS2SV },
{"glRasterPos3dv"		, do_op, JOB_OP_GL_RASTER_POS3DV },
{"glRasterPos3fv"		, do_op, JOB_OP_GL_RASTER_POS3FV },
{"glRasterPos3iv"		, do_op, JOB_OP_GL_RASTER_POS3IV },
{"glRasterPos3sv"		, do_op, JOB_OP_GL_RASTER_POS3SV },
{"glRasterPos4dv"		, do_op, JOB_OP_GL_RASTER_POS4DV },
{"glRasterPos4fv"		, do_op, JOB_OP_GL_RASTER_POS4FV },
{"glRasterPos4iv"		, do_op, JOB_OP_GL_RASTER_POS4IV },
{"glRasterPos4sv"		, do_op, JOB_OP_GL_RASTER_POS4SV },
{"glRectd"		, do_op, JOB_OP_GL_RECTD },
{"glRectf"		, do_op, JOB_OP_GL_RECTF },
{"glRecti"		, do_op, JOB_OP_GL_RECTI },
{"glRects"		, do_op, JOB_OP_GL_RECTS },
{"glRectdv"		, do_op, JOB_OP_GL_RECTDV },
{"glRectfv"		, do_op, JOB_OP_GL_RECTFV },
{"glRectiv"		, do_op, JOB_OP_GL_RECTIV },
{"glRectsv"		, do_op, JOB_OP_GL_RECTSV },
{"glVertexPointer"		, do_op, JOB_OP_GL_VERTEX_POINTER },
{"glNormalPointer"		, do_op, JOB_OP_GL_NORMAL_POINTER },
{"glColorPointer"		, do_op, JOB_OP_GL_COLOR_POINTER },
{"glIndexPointer"		, do_op, JOB_OP_GL_INDEX_POINTER },
{"glTexCoordPointer"		, do_op, JOB_OP_GL_TEX_COORD_POINTER },
{"glEdgeFlagPointer"		, do_op, JOB_OP_GL_EDGE_FLAG_POINTER },
{"glGetPointerv"		, do_op, JOB_OP_GL_GET_POINTERV },
{"glArrayElement"		, do_op, JOB_OP_GL_ARRAY_ELEMENT },
{"glDrawArrays"		, do_op, JOB_OP_GL_DRAW_ARRAYS },
{"glDrawElements"		, do_op, JOB_OP_GL_DRAW_ELEMENTS },
{"glInterleavedArrays"		, do_op, JOB_OP_GL_INTERLEAVED_ARRAYS },
{"glShadeModel"		, do_op, JOB_OP_GL_SHADE_MODEL },
{"glLightf"		, do_op, JOB_OP_GL_LIGHTF },
{"glLighti"		, do_op, JOB_OP_GL_LIGHTI },
{"glLightfv"		, do_op, JOB_OP_GL_LIGHTFV },
{"glLightiv"		, do_op, JOB_OP_GL_LIGHTIV },
{"glGetLightfv"		, do_op, JOB_OP_GL_GET_LIGHTFV },
{"glGetLightiv"		, do_op, JOB_OP_GL_GET_LIGHTIV },
{"glLightModelf"		, do_op, JOB_OP_GL_LIGHT_MODELF },
{"glLightModeli"		, do_op, JOB_OP_GL_LIGHT_MODELI },
{"glLightModelfv"		, do_op, JOB_OP_GL_LIGHT_MODELFV },
{"glLightModeliv"		, do_op, JOB_OP_GL_LIGHT_MODELIV },
{"glMaterialf"		, do_op, JOB_OP_GL_MATERIALF },
{"glMateriali"		, do_op, JOB_OP_GL_MATERIALI },
{"glMaterialfv"		, do_op, JOB_OP_GL_MATERIALFV },
{"glMaterialiv"		, do_op, JOB_OP_GL_MATERIALIV },
{"glGetMaterialfv"		, do_op, JOB_OP_GL_GET_MATERIALFV },
{"glGetMaterialiv"		, do_op, JOB_OP_GL_GET_MATERIALIV },
{"glColorMaterial"		, do_op, JOB_OP_GL_COLOR_MATERIAL },
{"glPixelZoom"		, do_op, JOB_OP_GL_PIXEL_ZOOM },
{"glPixelStoref"		, do_op, JOB_OP_GL_PIXEL_STOREF },
{"glPixelStorei"		, do_op, JOB_OP_GL_PIXEL_STOREI },
{"glPixelTransferf"		, do_op, JOB_OP_GL_PIXEL_TRANSFERF },
{"glPixelTransferi"		, do_op, JOB_OP_GL_PIXEL_TRANSFERI },
{"glPixelMapfv"		, do_op, JOB_OP_GL_PIXEL_MAPFV },
{"glPixelMapuiv"		, do_op, JOB_OP_GL_PIXEL_MAPUIV },
{"glPixelMapusv"		, do_op, JOB_OP_GL_PIXEL_MAPUSV },
{"glGetPixelMapfv"		, do_op, JOB_OP_GL_GET_PIXEL_MAPFV },
{"glGetPixelMapuiv"		, do_op, JOB_OP_GL_GET_PIXEL_MAPUIV },
{"glGetPixelMapusv"		, do_op, JOB_OP_GL_GET_PIXEL_MAPUSV },
{"glBitmap"		, do_op, JOB_OP_GL_BITMAP },
{"glReadPixels"		, do_op, JOB_OP_GL_READ_PIXELS },
{"glDrawPixels"		, do_op, JOB_OP_GL_DRAW_PIXELS },
{"glCopyPixels"		, do_op, JOB_OP_GL_COPY_PIXELS },
{"glStencilFunc"		, do_op, JOB_OP_GL_STENCIL_FUNC },
{"glStencilMask"		, do_op, JOB_OP_GL_STENCIL_MASK },
{"glStencilOp"		, do_op, JOB_OP_GL_STENCIL_OP },
{"glClearStencil"		, do_op, JOB_OP_GL_CLEAR_STENCIL },
{"glTexGend"		, do_op, JOB_OP_GL_TEX_GEND },
{"glTexGenf"		, do_op, JOB_OP_GL_TEX_GENF },
{"glTexGeni"		, do_op, JOB_OP_GL_TEX_GENI },
{"glTexGendv"		, do_op, JOB_OP_GL_TEX_GENDV },
{"glTexGenfv"		, do_op, JOB_OP_GL_TEX_GENFV },
{"glTexGeniv"		, do_op, JOB_OP_GL_TEX_GENIV },
{"glGetTexGendv"		, do_op, JOB_OP_GL_GET_TEX_GENDV },
{"glGetTexGenfv"		, do_op, JOB_OP_GL_GET_TEX_GENFV },
{"glGetTexGeniv"		, do_op, JOB_OP_GL_GET_TEX_GENIV },
{"glTexEnvf"		, do_op, JOB_OP_GL_TEX_ENVF },
{"glTexEnvi"		, do_op, JOB_OP_GL_TEX_ENVI },
{"glTexEnvfv"		, do_op, JOB_OP_GL_TEX_ENVFV },
{"glTexEnviv"		, do_op, JOB_OP_GL_TEX_ENVIV },
{"glGetTexEnvfv"		, do_op, JOB_OP_GL_GET_TEX_ENVFV },
{"glGetTexEnviv"		, do_op, JOB_OP_GL_GET_TEX_ENVIV },
{"glTexParameterf"		, do_op, JOB_OP_GL_TEX_PARAMETERF },
{"glTexParameteri"		, do_op, JOB_OP_GL_TEX_PARAMETERI },
{"glTexParameterfv"		, do_op, JOB_OP_GL_TEX_PARAMETERFV },
{"glTexParameteriv"		, do_op, JOB_OP_GL_TEX_PARAMETERIV },
{"glGetTexParameterfv"		, do_op, JOB_OP_GL_GET_TEX_PARAMETERFV },
{"glGetTexParameteriv"		, do_op, JOB_OP_GL_GET_TEX_PARAMETERIV },
{"glGetTexLevelParameterfv"		, do_op, JOB_OP_GL_GET_TEX_LEVEL_PARAMETERFV },
{"glGetTexLevelParameteriv"		, do_op, JOB_OP_GL_GET_TEX_LEVEL_PARAMETERIV },
{"glTexImage1D"		, do_op, JOB_OP_GL_TEX_IMAGE1D },
{"glTexImage2D"		, do_op, JOB_OP_GL_TEX_IMAGE2D },
{"glGetTexImage"		, do_op, JOB_OP_GL_GET_TEX_IMAGE },
{"glGenTextures"		, do_op, JOB_OP_GL_GEN_TEXTURES },
{"glDeleteTextures"		, do_op, JOB_OP_GL_DELETE_TEXTURES },
{"glBindTexture"		, do_op, JOB_OP_GL_BIND_TEXTURE },
{"glPrioritizeTextures"		, do_op, JOB_OP_GL_PRIORITIZE_TEXTURES },
{"glAreTexturesResident"		, do_op, JOB_OP_GL_ARE_TEXTURES_RESIDENT },
{"glIsTexture"		, do_op, JOB_OP_GL_IS_TEXTURE },
{"glTexSubImage1D"		, do_op, JOB_OP_GL_TEX_SUB_IMAGE1D },
{"glTexSubImage2D"		, do_op, JOB_OP_GL_TEX_SUB_IMAGE2D },
{"glCopyTexImage1D"		, do_op, JOB_OP_GL_COPY_TEX_IMAGE1D },
{"glCopyTexImage2D"		, do_op, JOB_OP_GL_COPY_TEX_IMAGE2D },
{"glCopyTexSubImage1D"		, do_op, JOB_OP_GL_COPY_TEX_SUB_IMAGE1D },
{"glCopyTexSubImage2D"		, do_op, JOB_OP_GL_COPY_TEX_SUB_IMAGE2D },
{"glMap1d"		, do_op, JOB_OP_GL_MAP1D },
{"glMap1f"		, do_op, JOB_OP_GL_MAP1F },
{"glMap2d"		, do_op, JOB_OP_GL_MAP2D },
{"glMap2f"		, do_op, JOB_OP_GL_MAP2F },
{"glGetMapdv"		, do_op, JOB_OP_GL_GET_MAPDV },
{"glGetMapfv"		, do_op, JOB_OP_GL_GET_MAPFV },
{"glGetMapiv"		, do_op, JOB_OP_GL_GET_MAPIV },
{"glEvalCoord1d"		, do_op, JOB_OP_GL_EVAL_COORD1D },
{"glEvalCoord1f"		, do_op, JOB_OP_GL_EVAL_COORD1F },
{"glEvalCoord1dv"		, do_op, JOB_OP_GL_EVAL_COORD1DV },
{"glEvalCoord1fv"		, do_op, JOB_OP_GL_EVAL_COORD1FV },
{"glEvalCoord2d"		, do_op, JOB_OP_GL_EVAL_COORD2D },
{"glEvalCoord2f"		, do_op, JOB_OP_GL_EVAL_COORD2F },
{"glEvalCoord2dv"		, do_op, JOB_OP_GL_EVAL_COORD2DV },
{"glEvalCoord2fv"		, do_op, JOB_OP_GL_EVAL_COORD2FV },
{"glMapGrid1d"		, do_op, JOB_OP_GL_MAP_GRID1D },
{"glMapGrid1f"		, do_op, JOB_OP_GL_MAP_GRID1F },
{"glMapGrid2d"		, do_op, JOB_OP_GL_MAP_GRID2D },
{"glMapGrid2f"		, do_op, JOB_OP_GL_MAP_GRID2F },
{"glEvalPoint1"		, do_op, JOB_OP_GL_EVAL_POINT1 },
{"glEvalPoint2"		, do_op, JOB_OP_GL_EVAL_POINT2 },
{"glEvalMesh1"		, do_op, JOB_OP_GL_EVAL_MESH1 },
{"glEvalMesh2"		, do_op, JOB_OP_GL_EVAL_MESH2 },
{"glFogf"		, do_op, JOB_OP_GL_FOGF },
{"glFogi"		, do_op, JOB_OP_GL_FOGI },
{"glFogfv"		, do_op, JOB_OP_GL_FOGFV },
{"glFogiv"		, do_op, JOB_OP_GL_FOGIV },
{"glFeedbackBuffer"		, do_op, JOB_OP_GL_FEEDBACK_BUFFER },
{"glPassThrough"		, do_op, JOB_OP_GL_PASS_THROUGH },
{"glSelectBuffer"		, do_op, JOB_OP_GL_SELECT_BUFFER },
{"glInitNames"		, do_op, JOB_OP_GL_INIT_NAMES },
{"glLoadName"		, do_op, JOB_OP_GL_LOAD_NAME },
{"glPushName"		, do_op, JOB_OP_GL_PUSH_NAME },
{"glPopName"		, do_op, JOB_OP_GL_POP_NAME },
{"glDrawRangeElements"		, do_op, JOB_OP_GL_DRAW_RANGE_ELEMENTS },
{"glTexImage3D"		, do_op, JOB_OP_GL_TEX_IMAGE3D },
{"glTexSubImage3D"		, do_op, JOB_OP_GL_TEX_SUB_IMAGE3D },
{"glCopyTexSubImage3D"		, do_op, JOB_OP_GL_COPY_TEX_SUB_IMAGE3D },


{"gluLookAt"          , do_op, JOB_OP_GLU_LOOKAT		},
{"gluPerspective"     , do_op, JOB_OP_GLU_PERSPECTIVE		},

{"gluOrtho2D"                 , do_op, JOB_OP_GLU_ORTHO2D },
{"gluPickMatrix"              , do_op, JOB_OP_GLU_PICK_MATRIX },
{"gluProject"                 , do_op, JOB_OP_GLU_PROJECT },
{"gluUnProject"               , do_op, JOB_OP_GLU_UN_PROJECT },
{"gluErrorString"             , do_op, JOB_OP_GLU_ERROR_STRING },
{"gluScaleImage"              , do_op, JOB_OP_GLU_SCALE_IMAGE },
{"gluBuild1DMipmaps"          , do_op, JOB_OP_GLU_BUILD1D_MIPMAPS },
{"gluBuild2DMipmaps"          , do_op, JOB_OP_GLU_BUILD2D_MIPMAPS },
{"gluNewQuadric"              , do_op, JOB_OP_GLU_NEW_QUADRIC },
{"gluDeleteQuadric"           , do_op, JOB_OP_GLU_DELETE_QUADRIC },
{"gluQuadricDrawStyle"        , do_op, JOB_OP_GLU_QUADRIC_DRAW_STYLE },
{"gluQuadricOrientation"      , do_op, JOB_OP_GLU_QUADRIC_ORIENTATION },
{"gluQuadricNormals"          , do_op, JOB_OP_GLU_QUADRIC_NORMALS },
{"gluQuadricTexture"          , do_op, JOB_OP_GLU_QUADRIC_TEXTURE },
{"gluQuadricCallback"         , do_op, JOB_OP_GLU_QUADRIC_CALLBACK },
{"gluCylinder"                , do_op, JOB_OP_GLU_CYLINDER },
{"gluSphere"                  , do_op, JOB_OP_GLU_SPHERE },
{"gluDisk"                    , do_op, JOB_OP_GLU_DISK },
{"gluPartialDisk"             , do_op, JOB_OP_GLU_PARTIAL_DISK },
{"gluNewNurbsRenderer"        , do_op, JOB_OP_GLU_NEW_NURBS_RENDERER },
{"gluDeleteNurbsRenderer"     , do_op, JOB_OP_GLU_DELETE_NURBS_RENDERER },
{"gluLoadSamplingMatrices"    , do_op, JOB_OP_GLU_LOAD_SAMPLING_MATRICES },
{"gluNurbsProperty"           , do_op, JOB_OP_GLU_NURBS_PROPERTY },
{"gluGetNurbsProperty"        , do_op, JOB_OP_GLU_GET_NURBS_PROPERTY },
{"gluBeginCurve"              , do_op, JOB_OP_GLU_BEGIN_CURVE },
{"gluEndCurve"                , do_op, JOB_OP_GLU_END_CURVE },
{"gluNurbsCurve"              , do_op, JOB_OP_GLU_NURBS_CURVE },
{"gluBeginSurface"            , do_op, JOB_OP_GLU_BEGIN_SURFACE },
{"gluEndSurface"              , do_op, JOB_OP_GLU_END_SURFACE },
{"gluNurbsSurface"            , do_op, JOB_OP_GLU_NURBS_SURFACE },
{"gluBeginTrim"               , do_op, JOB_OP_GLU_BEGIN_TRIM },
{"gluEndTrim"                 , do_op, JOB_OP_GLU_END_TRIM },
{"gluPwlCurve"                , do_op, JOB_OP_GLU_PWL_CURVE },
{"gluNurbsCallback"           , do_op, JOB_OP_GLU_NURBS_CALLBACK },
{"gluNewTess"                 , do_op, JOB_OP_GLU_NEW_TESS },
{"gluTessCallback"            , do_op, JOB_OP_GLU_TESS_CALLBACK },
{"gluDeleteTess"              , do_op, JOB_OP_GLU_DELETE_TESS },
{"gluBeginPolygon"            , do_op, JOB_OP_GLU_BEGIN_POLYGON },
{"gluEndPolygon"              , do_op, JOB_OP_GLU_END_POLYGON },
{"gluNextContour"             , do_op, JOB_OP_GLU_NEXT_CONTOUR },
{"gluTessVertex"              , do_op, JOB_OP_GLU_TESS_VERTEX },
{"gluGetString"               , do_op, JOB_OP_GLU_GET_STRING },


{"glutCreateWindow"   , do_op, JOB_OP_GLUT_CREATE_WINDOW	},
{"glutSwapBuffers"    , do_op, JOB_OP_GLUT_SWAP_BUFFERS		},
{"glutInitDisplayMode",  do_op,                  JOB_OP_GLUT_INIT_DISPLAY_MODE        },
{"glutInitDisplayString",        do_op,          JOB_OP_GLUT_INIT_DISPLAY_STRING      },
{"glutInitWindowPosition",       do_op,          JOB_OP_GLUT_INIT_WINDOW_POSITION     },
{"glutInitWindowSize",   do_op,                  JOB_OP_GLUT_INIT_WINDOW_SIZE         },
{"glutCreateSubWindow",  do_op,                  JOB_OP_GLUT_CREATE_SUB_WINDOW        },
{"glutDestroyWindow",    do_op,                  JOB_OP_GLUT_DESTROY_WINDOW           },
{"glutPostRedisplay",    do_op,                  JOB_OP_GLUT_POST_REDISPLAY           },
{"glutPostWindowRedisplay",      do_op,          JOB_OP_GLUT_POST_WINDOW_REDISPLAY    },
{"glutGetWindow",        do_op,                  JOB_OP_GLUT_GET_WINDOW               },
{"glutSetWindow",        do_op,                  JOB_OP_GLUT_SET_WINDOW               },
{"glutSetWindowTitle",   do_op,                  JOB_OP_GLUT_SET_WINDOW_TITLE         },
{"glutSetIconTitle",     do_op,                  JOB_OP_GLUT_SET_ICON_TITLE           },
{"glutPositionWindow",   do_op,                  JOB_OP_GLUT_POSITION_WINDOW          },
{"glutReshapeWindow",    do_op,                  JOB_OP_GLUT_RESHAPE_WINDOW           },
{"glutPopWindow",        do_op,                  JOB_OP_GLUT_POP_WINDOW               },
{"glutPushWindow",       do_op,                  JOB_OP_GLUT_PUSH_WINDOW              },
{"glutIconifyWindow",    do_op,                  JOB_OP_GLUT_ICONIFY_WINDOW           },
{"glutShowWindow",       do_op,                  JOB_OP_GLUT_SHOW_WINDOW              },
{"glutHideWindow",       do_op,                  JOB_OP_GLUT_HIDE_WINDOW              },
{"glutFullScreen",       do_op,                  JOB_OP_GLUT_FULL_SCREEN              },
{"glutSetCursor",        do_op,                  JOB_OP_GLUT_SET_CURSOR               },
{"glutWarpPointer",      do_op,                  JOB_OP_GLUT_WARP_POINTER             },
{"glutEstablishOverlay", do_op,                  JOB_OP_GLUT_ESTABLISH_OVERLAY        },
{"glutRemoveOverlay",    do_op,                  JOB_OP_GLUT_REMOVE_OVERLAY           },
{"glutUseLayer", do_op,                          JOB_OP_GLUT_USE_LAYER                },
{"glutPostOverlayRedisplay",     do_op,          JOB_OP_GLUT_POST_OVERLAY_REDISPLAY   },
{"glutPostWindowOverlayRedisplay",       do_op,  JOB_OP_GLUT_WINDOW_OVERLAY_REDISPLAY },
{"glutShowOverlay",      do_op,                  JOB_OP_GLUT_SHOW_OVERLAY             },
{"glutHideOverlay",      do_op,                  JOB_OP_GLUT_HIDE_OVERLAY             },
{"glutSetColor", do_op,                          JOB_OP_GLUT_SET_COLOR                },
{"glutGetColor", do_op,                          JOB_OP_GLUT_GET_COLOR                },
{"glutCopyColormap",     do_op,                  JOB_OP_GLUT_COPY_COLORMAP            },
{"glutGet",      do_op,                          JOB_OP_GLUT_GET                      },
{"glutDeviceGet",        do_op,                  JOB_OP_GLUT_DEVICE_GET               },
{"glutExtensionSupported",       do_op,          JOB_OP_GLUT_EXTENSION_SUPPORTED      },
{"glutGetModifiers",     do_op,                  JOB_OP_GLUT_GET_MODIFIERS            },
{"glutLayerGet", do_op,                          JOB_OP_GLUT_LAYER_GET                },

{"glutBitmapCharacter",  do_op,                  JOB_OP_GLUT_BITMAP_CHARACTER         },
{"glutBitmapWidth"    ,  do_op,                  JOB_OP_GLUT_BITMAP_WIDTH             },
{"glutStrokeCharacter",  do_op,                  JOB_OP_GLUT_STROKE_CHARACTER         },
{"glutStrokeWidth"    ,  do_op,                  JOB_OP_GLUT_STROKE_WIDTH             },
{"glutBitmapLength"   ,  do_op,                  JOB_OP_GLUT_BITMAP_LENGTH            },
{"glutStrokeLength"   ,  do_op,                  JOB_OP_GLUT_STROKE_LENGTH            },

{"glutWireSphere",       do_op,                  JOB_OP_GLUT_WIRE_SPHERE              },
{"glutSolidSphere",      do_op,                  JOB_OP_GLUT_SOLID_SPHERE             },
{"glutWireCone", do_op,                          JOB_OP_GLUT_WIRE_CONE                },
{"glutSolidCone",        do_op,                  JOB_OP_GLUT_SOLID_CONE               },
{"glutWireCube", do_op,                          JOB_OP_GLUT_WIRE_CUBE                },
{"glutSolidCube",        do_op,                  JOB_OP_GLUT_SOLID_CUBE               },
{"glutWireTorus",        do_op,                  JOB_OP_GLUT_WIRE_TORUS               },
{"glutSolidTorus",       do_op,                  JOB_OP_GLUT_SOLID_TORUS              },
{"glutWireDodecahedron", do_op,                  JOB_OP_GLUT_WIRE_DODECAHEDRON        },
{"glutSolidDodecahedron",        do_op,          JOB_OP_GLUT_SOLID_DODECAHEDRON       },
{"glutWireTeapot",       do_op,                  JOB_OP_GLUT_WIRE_TEAPOT              },
{"glutSolidTeapot",      do_op,                  JOB_OP_GLUT_SOLID_TEAPOT             },
{"glutWireOctahedron",   do_op,                  JOB_OP_GLUT_WIRE_OCTAHEDRON          },
{"glutSolidOctahedron",  do_op,                  JOB_OP_GLUT_SOLID_OCTAHEDRON         },
{"glutWireTetrahedron",  do_op,                  JOB_OP_GLUT_WIRE_TETRAHEDRON         },
{"glutSolidTetrahedron", do_op,                  JOB_OP_GLUT_SOLID_TETRAHEDRON        },
{"glutWireIcosahedron",  do_op,                  JOB_OP_GLUT_WIRE_ICOSAHEDRON         },
{"glutSolidIcosahedron", do_op,                  JOB_OP_GLUT_SOLID_ICOSAHEDRON        },
{"glutVideoResizeGet",   do_op,                  JOB_OP_GLUT_VIDEO_RESIZE_GET         },
{"glutSetupVideoResizing",       do_op,          JOB_OP_GLUT_SETUP_VIDEO_RESIZING     },
{"glutStopVideoResizing",        do_op,          JOB_OP_GLUT_STOP_VIDEO_RESIZING      },
{"glutVideoResize",      do_op,                  JOB_OP_GLUT_VIDEO_RESIZE             },
{"glutVideoPan", do_op,                          JOB_OP_GLUT_VIDEO_PAN                },
{"glutIgnoreKeyRepeat",  do_op,                  JOB_OP_GLUT_IGNORE_KEY_REPEAT        },
{"glutSetKeyRepeat",     do_op,                  JOB_OP_GLUT_SET_KEY_REPEAT           },
{"glutGameModeString",    do_op,                 JOB_OP_GLUT_GAME_MODE_STRING         },
{"glutEnterGameMode",    do_op,                  JOB_OP_GLUT_ENTER_GAME_MODE          },
{"glutLeaveGameMode",    do_op,                  JOB_OP_GLUT_LEAVE_GAME_MODE          },
{"glutGameModeGet",      do_op,                  JOB_OP_GLUT_GAME_MODE_GET            },

{"gluqEventsPending", do_op	, JOB_OP_GLUQ_EVENTS_PENDING	},
{"gluqEvent"	    , do_op	, JOB_OP_GLUQ_EVENT		},
{"gluqQueueEvent"    , do_op	, JOB_OP_GLUQ_QUEUE_EVENT	},
{"gluqMousePosition" , do_op	, JOB_OP_GLUQ_MOUSE_POSITION	},
{"gluqDrawTerrain"   , do_op	, JOB_OP_GLUQ_DRAW_TERRAIN	},
{"gluqDrawFace"      , do_op	, JOB_OP_GLUQ_DRAW_FACE		},
{"gluqDrawBiped"     , do_op	, JOB_OP_GLUQ_DRAW_BIPED	},
{"gluqDrawQuadruped" , do_op	, JOB_OP_GLUQ_DRAW_QUADRUPED	},

{"gnoise"	    , do_op	, JOB_OP_GNOISE			},
{"goto"		    , do_op	, JOB_OP_GOTO			},
{"graphicChar?"    , do_op	, JOB_OP_GRAPHIC_CHAR_P		},
{"guest?"	    , do_op	, JOB_OP_GUEST_P		},
{"hash"             , do_op	, JOB_OP_HASH			},
{"hexDigitChar?"  , do_op	, JOB_OP_HEX_DIGIT_CHAR_P	},
{"if"		    , do_if	, 0				},
{"import"	    , do_op	, JOB_OP_IMPORT			},
{"inPackage"	    , do_op	, JOB_OP_IN_PACKAGE		},
{"hash?"	    , do_op	, JOB_OP_HASH_P			},
{"index?"	    , do_op	, JOB_OP_INDEX_P		},
{"insertMosKeyClassMethod" , do_op, JOB_OP_INSERT_MOS_KEY_CLASS_METHOD},
{"insertMosKeyObjectMethod", do_op, JOB_OP_INSERT_MOS_KEY_OBJECT_METHOD},
{"intChar"	    , do_op	, JOB_OP_INT_TO_CHAR		},
{"intChars2"	    , do_op	, JOB_OP_INT_TO_CHARS2		},
{"intChars4"	    , do_op	, JOB_OP_INT_TO_CHARS4		},
{"intToDbname"      , do_op	, JOB_OP_INT_TO_DBNAME		},
{"integer?"	    , do_op	, JOB_OP_INTEGER_P		},
{"intern"	    , do_op	, JOB_OP_INTERN			},
{"ints3ToDbref"   , do_op	, JOB_OP_INTS3_TO_DBREF		},
{"isAnArray"	    , do_op	, JOB_OP_IS_AN_ARRAY		},
{"isAnAssembler"  , do_op	, JOB_OP_IS_AN_ASSEMBLER	},
{"isCallable"	    , do_op	, JOB_OP_IS_CALLABLE		},
{"isAChar"	    , do_op	, JOB_OP_IS_A_CHAR		},
{"isAMosClass"   , do_op     , JOB_OP_IS_A_MOS_CLASS	},
{"isAMosKey"    , do_op     , JOB_OP_IS_A_MOS_KEY		},
{"isAMosObject"  , do_op     , JOB_OP_IS_A_MOS_OBJECT	},
{"isACompiledFunction",do_op	, JOB_OP_IS_A_COMPILED_FUNCTION	},
{"isACons"	    , do_op	, JOB_OP_IS_A_CONS		},
{"isAConstant"    , do_op	, JOB_OP_IS_A_CONSTANT		},
{"isADataStack"  , do_op	, JOB_OP_IS_A_DATA_STACK	},
{"isAFloat"	    , do_op	, JOB_OP_IS_A_FLOAT		},
{"isAFunction"    , do_op	, JOB_OP_IS_A_FUNCTION		},
{"isAHash"	    , do_op	, JOB_OP_IS_A_HASH		},
{"isAnIndex"	    , do_op	, JOB_OP_IS_AN_INDEX		},
{"isAnInteger"    , do_op	, JOB_OP_IS_AN_INTEGER		},
{"isAJob"	    , do_op	, JOB_OP_IS_A_JOB		},
{"isAJobQueue"   , do_op	, JOB_OP_IS_A_JOB_QUEUE		},
{"isAJobSet"	    , do_op	, JOB_OP_IS_A_JOB_SET		},
{"isAKeyword"	    , do_op	, JOB_OP_IS_A_KEYWORD		},
{"isALambdaList" , do_op	, JOB_OP_IS_A_LAMBDA_LIST	},
{"isAList"	    , do_op	, JOB_OP_IS_A_LIST		},
{"isALock"	    , do_op	, JOB_OP_IS_A_LOCK		},
{"isALoopStack"  , do_op	, JOB_OP_IS_A_LOOP_STACK	},
{"isAMethod"	    , do_op	, JOB_OP_IS_A_METHOD		},
{"isANumber"	    , do_op	, JOB_OP_IS_A_NUMBER		},
{"isAPackage"	    , do_op	, JOB_OP_IS_A_PACKAGE		},
{"isAPlain"	    , do_op	, JOB_OP_IS_A_PLAIN		},
{"isAMessageStream",do_op	, JOB_OP_IS_A_MESSAGE_STREAM	},
{"isASession"	    , do_op	, JOB_OP_IS_A_SESSION		},
{"isASet"	    , do_op	, JOB_OP_IS_A_SET		},
{"isASocket"	    , do_op	, JOB_OP_IS_A_SOCKET		},
{"isAStream"	    , do_op	, JOB_OP_IS_A_STREAM		},
{"isAStack"	    , do_op	, JOB_OP_IS_A_STACK		},
{"isAString"	    , do_op	, JOB_OP_IS_A_STRING		},
{"isAStructure"   , do_op	, JOB_OP_IS_A_STRUCTURE		},
{"isASymbol"	    , do_op	, JOB_OP_IS_A_SYMBOL		},
{"isATable"	    , do_op	, JOB_OP_IS_A_TABLE		},
{"isAUser"	    , do_op	, JOB_OP_IS_A_USER		},
{"isThisMosClass", do_op	, JOB_OP_IS_THIS_MOS_CLASS	},
{"isThisStructure", do_op	, JOB_OP_IS_THIS_STRUCTURE	},
{"isAVector"	    , do_op	, JOB_OP_IS_A_VECTOR		},
{"isAVectorI01"	    , do_op	, JOB_OP_IS_A_VECTOR_I01	},
{"isAVectorI08"	    , do_op	, JOB_OP_IS_A_VECTOR_I08	},
{"isAVectorI16"	    , do_op	, JOB_OP_IS_A_VECTOR_I16	},
{"isAVectorI32"	    , do_op	, JOB_OP_IS_A_VECTOR_I32	},
{"isAVectorF32"	    , do_op	, JOB_OP_IS_A_VECTOR_F32	},
{"isAVectorF64"	    , do_op	, JOB_OP_IS_A_VECTOR_F64	},
{"isEphemeral"     , do_op	, JOB_OP_IS_EPHEMERAL		},
{"job"	    	    , do_op	, JOB_OP_JOB			},
{"jobQueueContents[",do_op	, JOB_OP_JOB_QUEUE_CONTENTS	},
{"jobQueue?"	    , do_op	, JOB_OP_JOB_QUEUE_P		},
{"jobQueues["	    , do_op	, JOB_OP_JOB_QUEUES		},
{"jobSet?"	    , do_op	, JOB_OP_JOB_SET_P		},
{"job?"		    , do_op	, JOB_OP_JOB_P			},
{"jobIsAlive?"    , do_op	, JOB_OP_JOB_IS_ALIVE_P		},
{"join"		    , do_op	, JOB_OP_JOIN			},
{"joinStrings"	    , do_op	, JOB_OP_JOIN			},
{"keyword?" 	    , do_op	, JOB_OP_KEYWORD_P		},
{"killJobMessily" , do_op	, JOB_OP_KILL_JOB_MESSILY	},
{"kitchenSinks"    , do_op	, JOB_OP_KITCHEN_SINKS		},
{"lambdaList?"	    , do_op	, JOB_OP_LAMBDA_LIST_P		},
{"lcm"   	    , do_op	, JOB_OP_LCM			},
{"length2"	    , do_op	, JOB_OP_LENGTH2		},
{"linkMosKeyToAncestor",do_op,JOB_OP_LINK_MOS_KEY_TO_ANCESTOR},
{"list?"	    , do_op	, JOB_OP_LIST_P			},
{"listfor"	    , do_listfor, 0				},
{"lock?"	    , do_op	, JOB_OP_LOCK_P			},
{"log"		    , do_op	, JOB_OP_LOG			},
{"log10"	    , do_op	, JOB_OP_LOG10			},
{"logand"	    , do_op	, JOB_OP_AND_BITS		},
{"logior"	    , do_op	, JOB_OP_OR_BITS		},
{"lognot"	    , do_op	, JOB_OP_NOT_BITS		},
{"logxor" 	    , do_op	, JOB_OP_XOR_BITS		},
{"loopFinish" 	    , do_loop_finish, 0				},
{"loopNext"	    , do_loop_next,0				},
{"loopStack?"	    , do_op	, JOB_OP_LOOP_STACK_P		},
{"lowerCase?"	    , do_op	, JOB_OP_LOWER_CASE_P		},
{"magnitude"        , do_op	, JOB_OP_MAGNITUDE		},
{"makeArray"	    , do_op	, JOB_OP_MAKE_ARRAY		},
{"makeAssembler"   , do_op	, JOB_OP_MAKE_ASSEMBLER		},
{"makeBignum" 	   , do_op	, JOB_OP_MAKE_BIGNUM		},
#ifdef OLD
{"makeHashedBtree" , do_op	, JOB_OP_MAKE_HASHED_BTREE	},
{"makeSortedBtree" , do_op	, JOB_OP_MAKE_SORTED_BTREE	},
#endif
{"makeMosClass"   , do_op	, JOB_OP_MAKE_MOS_CLASS	},
{"makeMosKey"     , do_op	, JOB_OP_MAKE_MOS_KEY		},
{"makeEphemeralVector", do_op , JOB_OP_MAKE_EPHEMERAL_VECTOR  },
{"makeFunction"    , do_op	, JOB_OP_MAKE_FN		},
{"makeHash"        , do_op	, JOB_OP_MAKE_HASH		},
{"makeIndex"	    , do_op	, JOB_OP_MAKE_INDEX		},
{"makeIndex3D"	    , do_op	, JOB_OP_MAKE_INDEX3D		},
{"makeJobQueue"   , do_op	, JOB_OP_MAKE_JOB_QUEUE		},
{"makeLambdaList" , do_op	, JOB_OP_MAKE_LAMBDA_LIST	},
{"makeLock"	    , do_op	, JOB_OP_MAKE_LOCK		},
{"makeMessageStream", do_op	, JOB_OP_MAKE_MESSAGE_STREAM	},
{"makeMethod"	    , do_op	, JOB_OP_MAKE_METHOD		},
{"makeMuf"	    , do_op	, JOB_OP_MAKE_MUF		},
{"makePackage"	    , do_op	, JOB_OP_MAKE_PACKAGE		},
{"makePlain"        , do_op	, JOB_OP_MAKE_PLAIN		},
{"makeSet"	    , do_op	, JOB_OP_MAKE_SET		},
{"makeSocket"	    , do_op	, JOB_OP_MAKE_SOCKET		},
{"makeStack"	    , do_op	, JOB_OP_MAKE_STACK		},
{"makeStream"	    , do_op	, JOB_OP_MAKE_STREAM		},
{"makeString"	    , do_op	, JOB_OP_MAKE_STRING		},
{"makeSymbol"      , do_op     , JOB_OP_MAKE_SYMBOL		},
{"makeTable"	    , do_op	, JOB_OP_MAKE_TABLE		},
{"makeVector"	    , do_op	, JOB_OP_MAKE_VECTOR		},
{"makeVectorI01"    , do_op	, JOB_OP_MAKE_VECTOR_I01	},
{"makeVectorI08"    , do_op	, JOB_OP_MAKE_VECTOR_I08	},
{"makeVectorI16"    , do_op	, JOB_OP_MAKE_VECTOR_I16	},
{"makeVectorI32"    , do_op	, JOB_OP_MAKE_VECTOR_I32	},
{"makeVectorF32"    , do_op	, JOB_OP_MAKE_VECTOR_F32	},
{"makeVectorF64"    , do_op	, JOB_OP_MAKE_VECTOR_F64	},
{"me"		    , do_op	, JOB_OP_ACTING_USER		},
{"messageStream?"  , do_op	, JOB_OP_MESSAGE_STREAM_P	},
{"method?"	    , do_op	, JOB_OP_METHOD_P		},
{"methodsMatch?"   , do_op	, JOB_OP_METHODS_MATCH_P	},
{"mix"		   , do_op	, JOB_OP_MIX			},
{"mosClass?"	    , do_op	, JOB_OP_MOS_CLASS_P		},
{"mosKey?"         , do_op	, JOB_OP_MOS_KEY_P		},
{"mosKeyParents[" , do_op	, JOB_OP_MOS_KEY_PARENTS_BLOCK	},
{"mosKeyPrecedenceList[", do_op, JOB_OP_MOS_KEY_PRECEDENCE_LIST_BLOCK},
{"mosKeyUnsharedSlotsMatch?",do_op, JOB_OP_MOS_KEY_UNSHARED_SLOTS_MATCH_P},
{"mosObject?"	    , do_op	, JOB_OP_MOS_OBJECT_P		},
{"mucTokenValueInString", do_op	, JOB_OP_MUC_TOKEN_VALUE_IN_STRING},
{"nearlyEqual"	    , do_op	, JOB_OP_NEARLY_EQUAL		},
{"neg"		    , do_op	, JOB_OP_NEG			},
{"neverInline"	    , do_never_inline	, 0			},
{"nextMosKeyLink", do_op	, JOB_OP_NEXT_MOS_KEY_LINK	},
{"nextMucTokenInString", do_op	, JOB_OP_NEXT_MUC_TOKEN_IN_STRING},
{"nonce11000a"      , do_op	, JOB_OP_NONCE_11000A		},
{"nonce00100a"      , do_op	, JOB_OP_NONCE_00100A		},
{"nonce00110a"      , do_op	, JOB_OP_NONCE_00110A		},
{"nonce00010a"      , do_op	, JOB_OP_NONCE_00010A		},
{"normalize"        , do_op	, JOB_OP_NORMALIZE		},
{"not"		    , do_op	, JOB_OP_NOT			},
{"null?"	    , do_op	, JOB_OP_NOT			},
{"number?"	    , do_op	, JOB_OP_NUMBER_P		},
{"omnipotent?"	    , do_on	, JOB_OP_OMNIPOTENT_P		},
{"on:"		    , do_on	, 0				},
{"or"		    , do_op	, JOB_OP_OR			},
{"package?"	    , do_op	, JOB_OP_PACKAGE_P		},
{"parameter:"       , do_parameter, 0				},
{"plain?"	    , do_op	, JOB_OP_PLAIN_P		},
{"pleaseInline"    , do_please_inline	, 0			},
{"pop"		    , do_op	, JOB_OP_POP			},
{"popCatchframe"   , do_op	, JOB_OP_POP_CATCHFRAME		},
{"popEphemeralStruct", do_op	, JOB_OP_POP_EPHEMERAL_STRUCT	},
{"popEphemeralVector", do_op	, JOB_OP_POP_EPHEMERAL_VECTOR	},
{"popFunctionBinding", do_op	, JOB_OP_POP_FUN_BINDING	},
{"popHandlersframe", do_op	, JOB_OP_POP_HANDLERSFRAME	},
{"popLockframe"    , do_op	, JOB_OP_POP_LOCKFRAME		},
{"popPrivsFrame"  , do_op     , JOB_OP_POP_PRIVS_FRAME	},
{"popRestartframe" , do_op	, JOB_OP_POP_RESTARTFRAME	},
{"popTagframe"     , do_op	, JOB_OP_POP_TAGFRAME		},
{"popTagtopframe"  , do_op	, JOB_OP_POP_TAGTOPFRAME	},
{"popUserFrame"   , do_op     , JOB_OP_POP_USER_FRAME		},
{"popVariableBinding", do_op	, JOB_OP_POP_VAR_BINDING	},
{"popUnwindframe"  , do_op	, JOB_OP_POP_UNWINDFRAME	},
{"print"	    , do_op	, JOB_OP_PRINT			},
{"printFunction"   , do_op	, JOB_OP_PRINT			},
{"printTime"	    , do_op	, JOB_OP_PRINT_TIME		},
{"print1"	    , do_op	, JOB_OP_PRINT1			},
{"print1DataStack", do_op	, JOB_OP_PRINT1_DATA_STACK	},
{"programCounterToLineNumber",do_op,JOB_OP_PROGRAM_COUNTER_TO_LINE_NUMBER},
{"proxyInfo"	    , do_op	, JOB_OP_PROXY_INFO		},
{"pull"		    , do_op	, JOB_OP_PULL			},
{"punctuation?"     , do_op	, JOB_OP_PUNCTUATION_P		},
{"push"		    , do_op	, JOB_OP_PUSH			},
{"pushFunctionBinding", do_op	, JOB_OP_PUSH_FUN_BINDING	},
{"pushLockframe"   , do_op	, JOB_OP_PUSH_LOCKFRAME		},
{"pushLockframeChild", do_op	, JOB_OP_PUSH_LOCKFRAME_CHILD	},
{"pushUserMeFrame",do_op     , JOB_OP_PUSH_USER_ME_FRAME     },
{"pushTagtopframe" , do_op	, JOB_OP_PUSH_TAGTOPFRAME	},
{"pushVariableBinding", do_op	, JOB_OP_PUSH_VAR_BINDING	},
{"queueJob"        , do_op	, JOB_OP_QUEUE_JOB		},
{"rayHitsSphereAt" , do_op	, JOB_OP_RAY_HITS_SPHERE_AT	},
{"rayHitsSpheresAt", do_op	, JOB_OP_RAY_HITS_SPHERES_AT	},
{"readByte"	    , do_op	, JOB_OP_READ_BYTE		},
{"readChar"	    , do_op	, JOB_OP_READ_CHAR		},
{"readValue"	    , do_op	, JOB_OP_READ_VALUE		},
{"readLine"	    , do_op	, JOB_OP_READ_LINE		},
{"readNextMufToken", do_op	, JOB_OP_READ_NEXT_MUF_TOKEN	},
{"readStreamByte" , do_op	, JOB_OP_READ_STREAM_BYTE	},
{"readStreamChar" , do_op	, JOB_OP_READ_STREAM_CHAR	},
{"readStreamValue", do_op	, JOB_OP_READ_STREAM_VALUE	},
{"readStreamLine" , do_op	, JOB_OP_READ_STREAM		},
{"readStreamPacket[",do_op	, JOB_OP_READ_STREAM_PACKET	},
{"remote?"	    , do_op	, JOB_OP_REMOTE_P		},
{"reset"	    , do_op	, JOB_OP_RESET			},
{"resetAssembler"  , do_op	, JOB_OP_RESET			},
{"rest"		    , do_op	, JOB_OP_CDR			},
{"return"	    , do_op	, JOB_OP_RETURN			},
{"rexBegin"	    , do_op	, JOB_OP_REX_BEGIN		},
{"rexCancelParen"   , do_op	, JOB_OP_REX_CANCEL_PAREN	},
{"rexCloseParen"    , do_op	, JOB_OP_REX_CLOSE_PAREN	},
{"rexDone?"	    , do_op	, JOB_OP_REX_DONE_P		},
{"rexEnd"	    , do_op	, JOB_OP_REX_END		},
{"rexGetCursor"     , do_op	, JOB_OP_REX_GET_CURSOR		},
{"rexGetParen"      , do_op	, JOB_OP_REX_GET_PAREN		},
{"rexMatchCharClass", do_op	, JOB_OP_REX_MATCH_CHAR_CLASS	},
{"rexMatchDot"      , do_op	, JOB_OP_REX_MATCH_DOT		},
{"rexMatchString"   , do_op	, JOB_OP_REX_MATCH_STRING	},
{"rexMatchDigit"    , do_op	, JOB_OP_REX_MATCH_DIGIT	},
{"rexMatchWhitespace",do_op	, JOB_OP_REX_MATCH_WHITESPACE	},
{"rexMatchWordboundary",do_op	, JOB_OP_REX_MATCH_WORDBOUNDARY	},
{"rexMatchWordchar",do_op	, JOB_OP_REX_MATCH_WORDCHAR	},
{"rexMatchNondigit"    , do_op	, JOB_OP_REX_MATCH_NONDIGIT	},
{"rexMatchNonwhitespace",do_op	, JOB_OP_REX_MATCH_NONWHITESPACE	},
{"rexMatchNonwordboundary",do_op, JOB_OP_REX_MATCH_NONWORDBOUNDARY	},
{"rexMatchNonwordchar",do_op	, JOB_OP_REX_MATCH_NONWORDCHAR	},
{"rexMatchPreviousMatch",do_op	, JOB_OP_REX_MATCH_PREVIOUS_MATCH	},
{"rexOpenParen"	    , do_op	, JOB_OP_REX_OPEN_PAREN		},
{"rexSetCursor"     , do_op	, JOB_OP_REX_SET_CURSOR		},
{"root"	    	    , do_op	, JOB_OP_ROOT			},
{"rootAllActiveSockets[",do_op,JOB_OP_ROOT_ALL_ACTIVE_SOCKETS},
{"rootAsUserDo{" , do_as_user, 0				},
{"rootCollectGarbage", do_op	, JOB_OP_ROOT_COLLECT_GARBAGE	},
{"rootDoBackup"   , do_op	, JOB_OP_ROOT_DO_BACKUP		},
{"rootExportDb", do_op	, JOB_OP_ROOT_EXPORT_DB},
{"rootImportDb", do_op	, JOB_OP_ROOT_IMPORT_DB},
{"rootRemoveDb", do_op	, JOB_OP_ROOT_REMOVE_DB},
{"rootLogString"    , do_op	, JOB_OP_ROOT_LOG_STRING	},
{"rootMakeDb"   	, do_op	, JOB_OP_ROOT_MAKE_DB		},
{"rootMakeGuest"   , do_op	, JOB_OP_ROOT_MAKE_GUEST	},
{"rootMakeGuestInDbfile",do_op	, JOB_OP_ROOT_MAKE_GUEST_IN_DBFILE	},
{"rootMakeUser"   , do_op	, JOB_OP_ROOT_MAKE_USER		},
{"rootMountDbfile", do_op	, JOB_OP_ROOT_MOUNT_DATABASE_FILE},
{"rootMoveToDbfile", do_op	, JOB_OP_ROOT_MOVE_TO_DBFILE    },
{"rootOmnipotentlyDo{" , do_omnipotently, 0			},
{"rootPushPrivsOmnipotentFrame",do_op,JOB_OP_ROOT_PUSH_PRIVS_OMNIPOTENT_FRAME },
{"rootPushUserFrame",do_op   , JOB_OP_ROOT_PUSH_USER_FRAME   },
{"rootShutdown"    , do_op	, JOB_OP_ROOT_SHUTDOWN		},
{"rootReplaceDb"	, do_op	, JOB_OP_ROOT_REPLACE_DB},
{"rootUnmountDbfile", do_op,JOB_OP_ROOT_UNMOUNT_DATABASE_FILE},
{"rootValidateDbfile", do_op	, JOB_OP_ROOT_VALIDATE_DATABASE_FILE},
{"rootWriteStream", do_op	, JOB_OP_ROOT_WRITE_STREAM	},
{"root?"	    , do_op	, JOB_OP_ROOT_P			},
{"rot"		    , do_op	, JOB_OP_ROT			},
{"round"	    , do_op	, JOB_OP_ROUND			},
{"rplaca"	    , do_op	, JOB_OP_RPLACA			},
{"rplacd"	    , do_op	, JOB_OP_RPLACD			},
{"secureHash"	    , do_op	, JOB_OP_SECURE_HASH		},
{"secureHashBinary", do_op	, JOB_OP_SECURE_HASH_BINARY	},
{"secureHashFixnum", do_op	, JOB_OP_SECURE_HASH_FIXNUM	},
{"self"		    , do_op	, JOB_OP_SELF			},
{"seq["		    , do_op	, JOB_OP_SEQ_BLOCK		},
{"session?"	    , do_op	, JOB_OP_SESSION_P		},
{"set?"		    , do_op	, JOB_OP_SET_P			},
{"setHere"    	    , do_op	, JOB_OP_SET_HERE		},
{"setBth"	    , do_op	, JOB_OP_SET_BTH		},
{"setMosKeyAncestor",do_op , JOB_OP_SET_MOS_KEY_ANCESTOR	},
{"setMosKeyClassMethod", do_op  , JOB_OP_SET_MOS_KEY_CLASS_METHOD},
{"setMosKeyInitarg", do_op , JOB_OP_SET_MOS_KEY_INITARG  },
{"setMosKeyMetharg", do_op , JOB_OP_SET_MOS_KEY_METHARG  },
{"setMosKeySlotarg", do_op , JOB_OP_SET_MOS_KEY_SLOTARG  },
{"setMosKeyObjectMethod", do_op  , JOB_OP_SET_MOS_KEY_OBJECT_METHOD},
{"setMosKeyParent", do_op  , JOB_OP_SET_MOS_KEY_PARENT	},
{"setMosKeySlotProperty", do_op, JOB_OP_SET_MOS_KEY_SLOT_PROPERTY},
{"setLambdaSlotProperty", do_op, JOB_OP_SET_LAMBDA_SLOT_PROPERTY},
{"setMethodSlot"  , do_op	, JOB_OP_SET_METHOD_SLOT	},
{"setMufLineNumber", do_op	, JOB_OP_SET_MUF_LINE_NUMBER	},
{"setNth"	    , do_op	, JOB_OP_SET_NTH		},
{"setNthStructureSlot", do_op, JOB_OP_SET_NTH_STRUCTURE_SLOT	},
{"setSocketCharEvent",do_op     , JOB_OP_SET_SOCKET_CHAR_EVENT	},
{"setNamedStructureSlot", do_op, JOB_OP_SET_NAMED_STRUCTURE_SLOT},
{"setSymbolConstant", do_op	, JOB_OP_SET_SYMBOL_CONSTANT	},
{"setSymbolFunction", do_op	, JOB_OP_SET_SYMBOL_FUNCTION	},
{"setSymbolPlist" , do_op	, JOB_OP_SET_SYMBOL_PLIST	},
{"setSymbolType"  , do_op	, JOB_OP_SET_SYMBOL_TYPE	},
{"setSymbolValue" , do_op	, JOB_OP_SET_SYMBOL_VALUE	},
{"simpleError"	    , do_op	, JOB_OP_SIMPLE_ERROR		},
{"sin"		    , do_op	, JOB_OP_SIN			},
{"sinh"		    , do_op	, JOB_OP_SINH			},
{"sleepJob"	    , do_op	, JOB_OP_SLEEP_JOB		},
{"smoothstep"	    , do_op	, JOB_OP_SMOOTHSTEP		},
{"socket?"	    , do_op	, JOB_OP_SOCKET_P		},
{"spline"	    , do_op	, JOB_OP_SPLINE			},
{"sqrt"		    , do_op	, JOB_OP_SQRT			},
{"stack?"	    , do_op	, JOB_OP_STACK_P		},
{"stack["	    , do_op	, JOB_OP_STACK_TO_BLOCK		},
{"startBlock"	    , do_op	, JOB_OP_START_BLOCK		},
{"startMufCompile", do_op	, JOB_OP_START_MUF_COMPILE	},
{"step"		    , do_op	, JOB_OP_STEP			},
{"stream?"	    , do_op	, JOB_OP_STREAM_P		},
{"stringChars["    , do_op	, JOB_OP_STRING_TO_CHARS	},
{"stringInt"	    , do_op	, JOB_OP_STRING_TO_INT		},
{"stringInts["    , do_op	, JOB_OP_STRING_TO_INTS		},
{"stringKeyword"  , do_op	, JOB_OP_STRING_TO_KEYWORD	},
{"stringWords["   , do_op	, JOB_OP_STRING_TO_WORDS	},
{"stringDowncase"  , do_op	, JOB_OP_STRING_DOWNCASE	},
{"stringMixedcase" , do_op	, JOB_OP_STRING_MIXEDCASE	},
{"stringUpcase"    , do_op	, JOB_OP_STRING_UPCASE		},
{"string?"	    , do_op	, JOB_OP_STRING_P		},
{"structure?"	    , do_op	, JOB_OP_STRUCTURE_P		},
{"subclassOf?"	    , do_op	, JOB_OP_SUBCLASS_OF_P		},
{"substring"	    , do_op	, JOB_OP_GET_SUBSTRING		},
{"substringCi?"    , do_op	, JOB_OP_CASELESS_SUBSTRING_P	},
{"substring?"	    , do_op	, JOB_OP_SUBSTRING_P		},
{"substring["	    , do_op	, JOB_OP_GET_SUBSTRING_BLOCK	},
{"swap"		    , do_op	, JOB_OP_SWAP			},
{"switchJob"	    , do_op	, JOB_OP_SWITCH_JOB		},
{"symbolFunction"  , do_op	, JOB_OP_SYMBOL_FUNCTION	},
{"symbolName"	    , do_op	, JOB_OP_SYMBOL_NAME		},
{"symbolPackage"   , do_op	, JOB_OP_SYMBOL_PACKAGE		},
{"symbolPlist"     , do_op	, JOB_OP_SYMBOL_PLIST		},
{"symbolType"	    , do_op	, JOB_OP_SYMBOL_TYPE		},
{"symbolValue"	    , do_op	, JOB_OP_SYMBOL_VALUE		},
{"symbol?"	    , do_op	, JOB_OP_SYMBOL_P		},
{"thisMosClass?" , do_op	, JOB_OP_THIS_MOS_CLASS_P	},
{"thisStructure?"  , do_op	, JOB_OP_THIS_STRUCTURE_P	},
{"trulyRandomFixnum", do_op	, JOB_OP_TRULY_RANDOM_FIXNUM	},
{"trulyRandomInteger", do_op	, JOB_OP_TRULY_RANDOM_INTEGER	},
{"turbulence"	    , do_op	, JOB_OP_TURBULENCE		},
{"withTag"	    , do_tag	, 0				},
{"withTags"	    , do_tag	, 0				},
{"table?"	    , do_op	, JOB_OP_TABLE_P		},
{"tan"		    , do_op	, JOB_OP_TAN			},
{"tanh"		    , do_op	, JOB_OP_TANH			},
{"then"		    , do_then	, 0				},
{"toDelimitedString", do_op	, JOB_OP_TO_DELIMITED_STRING	},
{"toString"	    , do_op	, JOB_OP_TO_STRING		},
{"trimString"	    , do_op	, JOB_OP_TRIM_STRING		},
{"truncate"	    , do_op	, JOB_OP_TRUNCATE		},
{"unbindSymbol"    , do_op	, JOB_OP_UNBIND_SYMBOL		},
{"unexport"	    , do_op	, JOB_OP_UNEXPORT		},
{"unintern"	    , do_op	, JOB_OP_UNINTERN		},
{"unlinkMosKeyFromAncestor",do_op,JOB_OP_UNLINK_MOS_KEY_FROM_ANCESTOR},
{"unprintFormatString[", do_op, JOB_OP_UNPRINT_FORMAT_STRING	},
{"unprintString["  , do_op	, JOB_OP_UNPRINT_STRING		},
{"unprint["	    , do_op	, JOB_OP_UNPRINT_STRING		},
{"unpull"	    , do_op	, JOB_OP_UNPULL			},
{"unpush"	    , do_op	, JOB_OP_UNPUSH			},
{"unreadByte"	    , do_op	, JOB_OP_UNREAD_CHAR		},
{"unreadChar"	    , do_op	, JOB_OP_UNREAD_CHAR		},
{"unreadValue"	    , do_op	, JOB_OP_UNREAD_CHAR		},
{"unreadStreamByte",do_op	, JOB_OP_UNREAD_STREAM_CHAR	},
{"unreadStreamChar",do_op	, JOB_OP_UNREAD_STREAM_CHAR	},
{"unreadStreamValue",do_op	, JOB_OP_UNREAD_STREAM_CHAR	},
{"until"	    , do_until	, 0				},
{"unusePackage"    , do_op	, JOB_OP_UNUSE_PACKAGE		},
{"upcase"	    , do_op	, JOB_OP_UPCASE			},
{"upperCase?"	    , do_op	, JOB_OP_UPPER_CASE_P		},
{"usePackage"	    , do_op	, JOB_OP_USE_PACKAGE		},
{"user?"	    , do_op	, JOB_OP_USER_P			},
{"vcnoise"    	    , do_op	, JOB_OP_VCNOISE		},
{"vec"	    	    , do_op	, JOB_OP_MAKE_VECTOR		},
{"vector?"	    , do_op	, JOB_OP_VECTOR_P		},
{"vectorI01?"	    , do_op	, JOB_OP_VECTOR_I01_P		},
{"vectorI08?"	    , do_op	, JOB_OP_VECTOR_I08_P		},
{"vectorI16?"	    , do_op	, JOB_OP_VECTOR_I16_P		},
{"vectorI32?"	    , do_op	, JOB_OP_VECTOR_I32_P		},
{"vectorF32?"	    , do_op	, JOB_OP_VECTOR_F32_P		},
{"vectorF64?"	    , do_op	, JOB_OP_VECTOR_F64_P		},
{"vnoise"    	    , do_op	, JOB_OP_VNOISE			},
{"while"	    , do_while	, 0				},
{"whitespace?"	    , do_op	, JOB_OP_WHITESPACE_P		},
{"withLockDo{"    , do_withlock, 0				},
{"withChildLockDo{", do_withlock, 1				},
{"withParentLockDo{", do_withlock, 0				},
{"words["	    , do_op	, JOB_OP_STRING_TO_WORDS	},
{"wrapString"	    , do_op	, JOB_OP_WRAP_STRING		},
{"writeOutputStream", do_op	, JOB_OP_WRITE_OUTPUT_STREAM	},
{"writeStream"	    , do_op	, JOB_OP_WRITE_STREAM		},
{"writeSubstringToStream", do_op, JOB_OP_WRITE_SUBSTRING_TO_STREAM	},
{"{"		    , do_brace	, 0				},
{"|"		    , do_bar	, 0				},
{"|="		    , do_op	, JOB_OP_STREQ_BLOCK		},
{"|abcAbbc"	    , do_op	, JOB_OP_ABC_ABBC_BLOCK		},
{"|applicableMethod?",do_op	, JOB_OP_APPLICABLE_METHOD_P	},
{"|applyLambdaList" , do_op	, JOB_OP_APPLY_LAMBDA_LIST	},
{"|backslashesToHighbit",do_op, JOB_OP_BACKSLASHES_TO_HIGHBIT	},
{"|bracketPosition", do_op	, JOB_OP_BRACKET_POSITION_IN_BLOCK	},
{"|charInt"	    , do_op	, JOB_OP_CHAR_TO_INT_BLOCK	},
{"|charPosition"   , do_op	, JOB_OP_CHAR_POSITION_IN_BLOCK	},
/*{"|crypt"	    , do_op	, JOB_OP_CRYPT			},*/
{"|debyte"	    , do_op	, JOB_OP_DEBYTE			},
{"|debyteMuqnetHeader", do_op	, JOB_OP_DEBYTE_MUQNET_HEADER	},
{"|delete"	    , do_op	, JOB_OP_DELETE_ARG_BLOCK	},
{"|deleteNonchars" , do_op	, JOB_OP_DELETE_NONCHARS_BLOCK	},
{"|dup"		    , do_op	, JOB_OP_DUP_ARG_BLOCK		},
{"|dupNth"	    , do_op	, JOB_OP_DUP_NTH_ARG_BLOCK	},
{"|dup["	    , do_op	, JOB_OP_DUP_BLOCK		},
{"|enbyte"	    , do_op	, JOB_OP_ENBYTE			},
{"|errorIfEphemeral",do_op	, JOB_OP_ERROR_IF_EPHEMERAL	},
{"|doCBackslashes", do_op	, JOB_OP_DO_C_BACKSLASHES	},
{"|downcase"	    , do_op	, JOB_OP_DOWNCASE_BLOCK		},
{"|extract["	    , do_op	, JOB_OP_EXTRACT		},
{"|findSymbol?"    , do_op	, JOB_OP_FIND_SYMBOL_P		},
{"|first"	    , do_op	, JOB_OP_DUP_FIRST_ARG_BLOCK	},
{"|for"		    , do_barfor	, 0				},
{"|forPairs"	    , do_barfor_pairs, 0			},
{"|ged"		    , do_op	, JOB_OP_GED_VAL_BLOCK		},
{"|gep"		    , do_op	, JOB_OP_GEP_VAL_BLOCK		},
{"|get"		    , do_op	, JOB_OP_GET_VAL_BLOCK		},
{"|getAllActiveHandlers[",do_op,JOB_OP_GET_ALL_ACTIVE_HANDLERS},
{"|intChar"	    , do_op	, JOB_OP_INT_TO_CHAR_BLOCK	},
{"|keys"	    , do_op	, JOB_OP_DROP_VALS_BLOCK	},
{"|keysKeysvals"   , do_op	, JOB_OP_DOUBLE_BLOCK		},
{"|keysvalsReverse", do_op	, JOB_OP_REVERSE_KEYSVALS_BLOCK	},
{"|keysvalsSort"   , do_op	, JOB_OP_SORT_KEYSVALS_BLOCK	},
{"|keysvalsUniq"   , do_op	, JOB_OP_UNIQ_KEYSVALS_BLOCK	},
{"|length"	    , do_op	, JOB_OP_BLOCK_LENGTH		},
{"|maybeWriteStreamPacket",do_op, JOB_OP_MAYBE_WRITE_STREAM_PACKET	},
{"|unsort"	    , do_op	, JOB_OP_UNSORT_BLOCK		},
{"|pairsUniq"	    , do_op	, JOB_OP_UNIQ_PAIRS_BLOCK	},
{"|pairsSort"      , do_op	, JOB_OP_SORT_PAIRS_BLOCK	},
{"|pop"		    , do_op	, JOB_OP_POP_FROM_BLOCK		},
{"|popNth"	    , do_op	, JOB_OP_POP_NTH_FROM_BLOCK	},
{"|popp"	    , do_op	, JOB_OP_POPP_FROM_BLOCK	},
{"|position"        , do_op	, JOB_OP_POSITION_IN_BLOCK	},
{"|positionInStack?",do_op	, JOB_OP_POSITION_IN_STACK_P	},
{"|potentialNumber?",do_op	, JOB_OP_POTENTIAL_NUMBER_P	},
{"|push"	    , do_op	, JOB_OP_PUSH_INTO_BLOCK	},
{"|pushNth"	    , do_op	, JOB_OP_PUSH_NTH_INTO_BLOCK	},
{"|readAnyStreamPacket",do_op	, JOB_OP_READ_ANY_STREAM_PACKET	},
{"|readTokenChar" , do_op	, JOB_OP_READ_TOKEN_CHAR	},
{"|readTokenChars", do_op	, JOB_OP_READ_TOKEN_CHARS	},
{"|reverse"	    , do_op	, JOB_OP_REVERSE_BLOCK		},
{"|rootMaybeWriteStreamPacket",do_op,JOB_OP_ROOT_MAYBE_WRITE_STREAM_PACKET},
{"|rootWriteStreamPacket",do_op, JOB_OP_ROOT_WRITE_STREAM_PACKET	},
{"|rotate"	    , do_op	, JOB_OP_ROTATE_BLOCK		},
{"|scanTokenToChar",  do_op	, JOB_OP_SCAN_TOKEN_TO_CHAR	},
{"|scanTokenToChars", do_op	, JOB_OP_SCAN_TOKEN_TO_CHARS	},
{"|scanTokenToCharPair",do_op, JOB_OP_SCAN_TOKEN_TO_CHAR_PAIR},
{"|scanTokenToWhitespace",do_op,JOB_OP_SCAN_TOKEN_TO_WHITESPACE},
{"|scanTokenToNonwhitespace",do_op,JOB_OP_SCAN_TOKEN_TO_NONWHITESPACE},
{"|secureDigest"    , do_op	, JOB_OP_SECURE_DIGEST_BLOCK	},
{"|secureDigestCheck", do_op	, JOB_OP_SECURE_DIGEST_CHECK_BLOCK},
{"|secureHash"	    , do_op	, JOB_OP_SECURE_HASH_BLOCK	},
{"|selectMessageStreams",do_op	, JOB_OP_READ_ANY_STREAM_PACKET	},
{"|set"		    , do_op	, JOB_OP_SET_VAL_BLOCK		},
{"|setNth"	    , do_op	, JOB_OP_SET_NTH_IN_BLOCK	},
{"|shift"	    , do_op	, JOB_OP_SHIFT_FROM_BLOCK	},
{"|shiftp"	    , do_op	, JOB_OP_SHIFTP_FROM_BLOCK	},
{"|shiftpN"	    , do_op	, JOB_OP_SHIFTP_N_FROM_BLOCK	},
{"|signedDigest"    , do_op	, JOB_OP_SIGNED_DIGEST_BLOCK	},
{"|signedDigestCheck",do_op	, JOB_OP_SIGNED_DIGEST_CHECK_BLOCK	},
{"|sort"	    , do_op	, JOB_OP_SORT_BLOCK		},
{"|subblock["	    , do_op	, JOB_OP_SUBBLOCK		},
{"|tr"		    , do_op	, JOB_OP_TR_BLOCK		},
{"|tsort"	    , do_op	, JOB_OP_TSORT_BLOCK		},
{"|tsortMos"	    , do_op	, JOB_OP_TSORT_MOS_BLOCK	},
{"|uniq"	    , do_op	, JOB_OP_UNIQ_BLOCK		},
{"|unreadTokenChar",do_op	, JOB_OP_UNREAD_TOKEN_CHAR	},
{"|unshift"	    , do_op	, JOB_OP_UNSHIFT_INTO_BLOCK	},
{"|upcase"	    , do_op	, JOB_OP_UPCASE_BLOCK		},
{"|vals"	    , do_op	, JOB_OP_DROP_KEYS_BLOCK	},
{"|writeStreamPacket",do_op	, JOB_OP_WRITE_STREAM_PACKET	},
{"||swap"	    , do_op	, JOB_OP_SWAP_BLOCKS		},

/* CommonLisp support/library fns: */
{"|read"	    , do_op	, JOB_OP_L_READ			},

{"}"		    , do_rightbrace, 0				},
{"}alwaysDo{"	    , do_always	, 0				},
{"~"		    , do_op	, JOB_OP_NEARLY_EQUAL		},

#ifndef SOMETIMES_USEFUL
{"debugPrint"	    , do_op	, JOB_OP_DEBUG_PRINT		},
{"d,"	    	    , do_op	, JOB_OP_DEBUG_PRINT		},
{"dil-test"	    , do_op	, JOB_OP_DIL_TEST		},
#endif

/* CLX functions: */

/* Commented out because nobody is working */
/* on completing the X support:            */
#ifdef MAYBE_SOMEDAY
{"]create-gcontext" , do_op	, JOB_OP_CREATE_GCONTEXT	},
{"]create-window"   , do_op	, JOB_OP_CREATE_WINDOW		},
{"]draw-glyphs"	    ,do_op	, JOB_OP_DRAW_GLYPHS		},
{"]draw-image-glyphs",do_op	, JOB_OP_DRAW_IMAGE_GLYPHS	},
{"]make-event-mask" , do_op	, JOB_OP_MAKE_EVENT_MASK	},
{"]text-extents"    , do_op	, JOB_OP_TEXT_EXTENTS		},
{"close-display"    , do_op	, JOB_OP_CLOSE_DISPLAY		},
{"color?"           , do_op	, JOB_OP_COLOR_P		},
{"colormap?"        , do_op	, JOB_OP_COLORMAP_P		},
{"cursor?"          , do_op	, JOB_OP_CURSOR_P		},
{"destroy-subwindows",do_op	, JOB_OP_DESTROY_SUBWINDOWS	},
{"destroy-window"   , do_op	, JOB_OP_DESTROY_WINDOW		},
{"display-roots["   , do_op	, JOB_OP_DISPLAY_ROOTS		},
{"display?"         , do_op	, JOB_OP_DISPLAY_P		},
{"drawable-border-width", do_op	, JOB_OP_DRAWABLE_BORDER_WIDTH	},
{"drawable-depth"   , do_op	, JOB_OP_DRAWABLE_DEPTH		},
{"drawable-display" , do_op	, JOB_OP_DRAWABLE_DISPLAY	},
{"drawable-height"  , do_op	, JOB_OP_DRAWABLE_HEIGHT	},
{"drawable-width"   , do_op	, JOB_OP_DRAWABLE_WIDTH		},
{"drawable-x"	    , do_op	, JOB_OP_DRAWABLE_X		},
{"drawable-y"	    , do_op	, JOB_OP_DRAWABLE_Y		},
{"flush-display"    , do_op	, JOB_OP_FLUSH_DISPLAY		},
{"font-ascent"      , do_op	, JOB_OP_FONT_ASCENT		},
{"font-descent"     , do_op	, JOB_OP_FONT_DESCENT		},
{"font?"            , do_op	, JOB_OP_FONT_P			},
{"gcontext-background",do_op	, JOB_OP_GCONTEXT_BACKGROUND	},
{"gcontext-font"    , do_op	, JOB_OP_GCONTEXT_FONT		},
{"gcontext-foreground",do_op	, JOB_OP_GCONTEXT_FOREGROUND	},
{"gcontext?"        , do_op	, JOB_OP_GCONTEXT_P		},
{"map-subwindows"   , do_op	, JOB_OP_MAP_SUBWINDOWS		},
{"map-window"       , do_op	, JOB_OP_MAP_WINDOW		},
{"open-font"        , do_op	, JOB_OP_OPEN_FONT		},
{"pixmap?"          , do_op	, JOB_OP_PIXMAP_P		},
{"query-pointer"    , do_op	, JOB_OP_QUERY_POINTER		},
{"root-open-display", do_op	, JOB_OP_OPEN_DISPLAY		},
{"screen-black-pixel",do_op	, JOB_OP_SCREEN_BLACK_PIXEL	},
{"screen-root"      , do_op	, JOB_OP_SCREEN_ROOT		},
{"screen-white-pixel",do_op	, JOB_OP_SCREEN_WHITE_PIXEL	},
{"screen?"          , do_op	, JOB_OP_SCREEN_P		},
{"unmap-subwindows" , do_op	, JOB_OP_UNMAP_SUBWINDOWS	},
{"unmap-window"	    , do_op	, JOB_OP_UNMAP_WINDOW		},
{"window?"          , do_op	, JOB_OP_WINDOW_P		},
#endif

/* Prims specific to selected emulation(s): */
#define  MODULES_MUF_C_MUFPRIM
#include "Modules.h"
#undef   MODULES_MUF_C_MUFPRIM



/* End-of-array sentinel: */
{ NULL,	NULL,		0		}
};
#undef A

 /***********************************************************************/
 /*-   lispprim[] -- array describing hardwired lisp primitives.	*/
 /***********************************************************************/

#undef A
#define A(a,b,c,d) FUN_ARITY(a,b,c,d)
static struct prim_rec
lispprim[] = {

/* This table gets runtime-sorted */
/* by sort_prim_table():       */
{"applyReadLambdaList" ,do_op, JOB_OP_APPLY_READ_LAMBDA_LIST	},
{"applyPrintLambdaList",do_op, JOB_OP_APPLY_PRINT_LAMBDA_LIST},
{"explodeNumber["	  ,do_op, JOB_OP_EXPLODE_NUMBER		},
{"explodeSymbol["	  ,do_op, JOB_OP_EXPLODE_SYMBOL		},
{"explodeBoundedStringLine[",do_op, JOB_OP_EXPLODE_BOUNDED_STRING_LINE },
{"getMacroCharacter", do_op   , JOB_OP_GET_MACRO_CHARACTER	},
{"setMacroCharacter", do_op   , JOB_OP_SET_MACRO_CHARACTER	},
{"|classifyLispToken", do_op	, JOB_OP_CLASSIFY_LISP_TOKEN	},
{"|dropSingleQuotes", do_op	, JOB_OP_DROP_SINGLE_QUOTES	},
{"|scanLispStringToken",do_op,JOB_OP_SCAN_LISP_STRING_TOKEN	},
{"|scanLispToken",  do_op	,  JOB_OP_SCAN_LISP_TOKEN	},
/*{"|readLispChars" , do_op     , JOB_OP_READ_LISP_CHARS	},*/
/*{"|readLispComment",do_op     , JOB_OP_READ_LISP_COMMENT	},*/
{"|readLispString", do_op     , JOB_OP_READ_LISP_STRING	},

/* End-of-array sentinel: */
{ NULL,	NULL,		0		}
};
#undef A

/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    muf_Startup -- start-of-world stuff.				*/
/************************************************************************/

 /***********************************************************************/
 /*-    sort_prim_table -- sort mufprim[] or lispprim[]			*/
 /***********************************************************************/

/* We can't keep mufprim[] statically sorted by */
/* hand because the mod/ * optional modules can */
/* append stuff out of order, so we runtime     */
/* sort it.  May not actually need to be sorted */
/* at present, but I like sorted tables :).     */

static void
sort_prim_table(
    struct prim_rec * table
) {
    /* Count number of entries in table: */
    Vm_Int block_size = 0;
    while (table[ block_size ].name)  ++block_size;
    if (block_size <= 1)   return;

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


	/* Define comparison between two records: */
	#undef  LESS
	#define LESS(x,y) (0>strcmp((x).name,(y).name))

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
		/* If kids L,R don't exist, can just put 'tmp' in hole: */  \
		if (L >= roit)            {  b[hole] = tmp;  break; }	    \
									    \
		/* Set maxkid to largest of hole's two kids, L and R:   */  \
		maxkid = (R < roit && LESS( b[L], b[R] )) ? R : L;	    \
									    \
		/* If 'tmp' > maxkid, put 'tmp' in hole and stop: */	    \
		if (LESS( b[maxkid], tmp )) { b[hole] = tmp; break; }	    \
									    \
		/* Biggest kid fills hole, loop to fill new hole: */	    \
		b[hole] = b[maxkid];					    \
		hole    = maxkid;					    \
        }   }\

	/* Find block, initialize 'left' and 'roit': */
        struct    prim_rec * b = table;      /* Base of our block. */
	Vm_Int  left = block_size/2 +1;	     /* Heap is slots k:   */
	Vm_Int  roit = block_size     ;	     /* left <= k < roit.  */
        struct    prim_rec     tmp    ;      /* Record in motion!  */

	/* Heap-build followed by heap-unbuild phases: */
	while (left-->0) { tmp = b[left];                 SIFT_UP; }  ++left;
	while (roit-->1) { tmp = b[roit]; b[roit] = b[0]; SIFT_UP; }
    }
}

 /***********************************************************************/
 /*-    update_lib -- Validate /lib/muf/ or /lib/lisp			*/
 /***********************************************************************/

  /**********************************************************************/
  /*-    update_lib_constant -- Validate /lib/muf/#first# &tc.		*/
  /**********************************************************************/

static void
update_lib_constant(
    Vm_Obj  pkg,
    Vm_Uch* key,
    Vm_Obj  val
) {
    Vm_Obj sym = sym_Find_Exported_Asciz( pkg, key );
    if (!sym || !OBJ_IS_SYMBOL(sym)) {
	Vm_Obj k = stg_From_Asciz( key );
	sym = sym_Make();
	OBJ_SET( pkg, k, sym, OBJ_PROP_HIDDEN );
	OBJ_SET( pkg, k, sym, OBJ_PROP_PUBLIC );
	{   Sym_P s = SYM_P(sym);
	    s->name    = k;
	    s->package = pkg;
	    vm_Dirty(sym);
	}
    }
    if (SYM_P(sym)->value != val) {
	SYM_P(sym)->value = val;
	vm_Dirty(sym);
    }
}

  /**********************************************************************/
  /*-   validate_hidden_lib_symbol -- Make sure it exists.		*/
  /**********************************************************************/

static Vm_Obj
validate_hidden_lib_symbol(
    Vm_Obj  pkg,
    Vm_Uch* name
) {
    Vm_Obj sym;
/*if (!strcmp(name,"abrt"))printf("muf:validate_hidden_lib_symbol(%" VM_X ",\"abrt\")...\n",pkg);*/
    sym = sym_Find_Asciz( pkg, name );
    if (!sym || !OBJ_IS_SYMBOL(sym)) {
	Vm_Obj key = stg_From_Asciz( name );
	sym = sym_Make();
	OBJ_SET( pkg, key, sym, OBJ_PROP_PUBLIC );
	/* All symbols in a package must be  in hidden area; */
	OBJ_SET( pkg, key, sym, OBJ_PROP_HIDDEN );
	{   Sym_P s = SYM_P(sym);
	    s->name    = key;
	    s->package = pkg;
	    vm_Dirty(sym);
    }   }
    return sym;
}

  /**********************************************************************/
  /*-   validate_pubic_lib_symbol -- Make sure it exists and is exported*/
  /**********************************************************************/

static Vm_Obj
validate_public_lib_symbol(
    Vm_Obj  pkg,  /* obj_Lib_Muf or obj_Lib_Lisp or */
    Vm_Uch* name
) {
    Vm_Obj sym = sym_Find_Exported_Asciz( pkg, name );
    if (!sym || !OBJ_IS_SYMBOL(sym)) {
	Vm_Obj key = stg_From_Asciz( name );
	sym = sym_Make();
	OBJ_SET( pkg, key, sym, OBJ_PROP_PUBLIC );
	/* All symbols in a package must be  in hidden area; */
	/* In addition, we export by putting in public area: */
	OBJ_SET( pkg, key, sym, OBJ_PROP_HIDDEN );
	OBJ_SET( pkg, key, sym, OBJ_PROP_PUBLIC );
	{   Sym_P s = SYM_P(sym);
	    s->name    = key;
	    s->package = pkg;
	    vm_Dirty(sym);
    }   }
    return sym;
}

  /**********************************************************************/
  /*-  validate_public_symbols -- Install mufpub table.			*/
  /**********************************************************************/

static void
validate_public_symbols(
    Vm_Obj             lib, /* obj_Lib_Muf  */
    struct hidden_rec* tab  /* mufpub table */
){
    for (;   tab->name;   ++tab) {
	*tab->slot = validate_public_lib_symbol( lib, tab->name );
    }
}

  /**********************************************************************/
  /*-  validate_hidden_symbols -- Install mufhid or lisphid table.	*/
  /**********************************************************************/

static void
validate_hidden_symbols(
    Vm_Obj             lib, /* obj_Lib_Muf or obj_Lib_Lisp */
    struct hidden_rec* tab  /* mufhid or lisphid table   */
){
    for (;   tab->name;   ++tab) {
	*tab->slot = validate_hidden_lib_symbol( lib, tab->name );
    }
}

  /**********************************************************************/
  /*-   update_lib -- Validate /lib/muf/ or /lib/lisp			*/
  /**********************************************************************/

static void
update_lib(
    struct prim_rec * primtab,
    Vm_Obj            lib
) {

    Vm_Uch ret[4];
    Vm_Int i;
    if (1 != (asm_Nullary_To_Buf( ret, JOB_OP_RETURN ))) {
	MUQ_FATAL ("muf.c:update_lib: internal err.");
    }

    /* Over all entries in primtab[]: */
    for   (i = 0;   primtab[i].name;   ++i) {
	Vm_Obj fun;
	Vm_Obj cfn;
	Vm_Obj sym;
	Vm_Obj bitbag;
	if (primtab[i].fn != do_op)   continue;

	/* Guarantee that a symbol is exported for the prim: */
	sym = lib_Validate_Symbol( primtab[i].name, lib );

	/* Guarantee symbol has a compiledFunction as 'function' value: */
	cfn = SYM_P(sym)->function;
	if (!OBJ_IS_CFN(cfn) || cfn_Len(cfn) != 2) {
	    cfn = cfn_Alloc( 2, OBJ_K_CFN );
	    SYM_P(sym)->function = cfn;
	    vm_Dirty(sym);
	}

	/* Guarantee compiledFunction is compileTime, */
	/* inline prim with one constant:		*/
	bitbag = CFN_P(cfn)->bitbag;
	{   Vm_Int changed = FALSE;
	    if (!OBJ_IS_INT(bitbag)) {
		bitbag  = OBJ_0;			changed = TRUE;
	    }
	    if (CFN_CONSTS(bitbag) != 1) {
		bitbag = CFN_SET_CONSTS( bitbag, 1 );	changed = TRUE;
	    }
	    if (!CFN_IS_PRIM(bitbag)) {
		bitbag = CFN_SET_PRIM( bitbag );	changed = TRUE;
	    }
	    if (!CFN_IS_PLEASE_INLINE(bitbag)) {
		bitbag = CFN_SET_PLEASE_INLINE( bitbag);changed = TRUE;
	    }
#ifdef OLD
	    if (!CFN_IS_COMPILETIME(bitbag)) {
		bitbag = CFN_CLR_COMPILETIME( bitbag );	changed = TRUE;
	    }
#endif
	    if (changed) {
		CFN_P(cfn)->bitbag = bitbag;
		vm_Dirty(cfn);
	    }
	}

	/* Guarantee that compiledFunction gives correct opcode: */
	if (CFN_P(cfn)->vec[0] != OBJ_FROM_INT( primtab[i].op )) {
	    Vm_Uch* p;
	    Vm_Uch  buf[4];
	    CFN_P(cfn)->vec[0]  = OBJ_FROM_INT( primtab[i].op );
	    vm_Dirty(cfn);

	    switch (asm_Nullary_To_Buf( buf, primtab[i].op )) {

	    case 1:
		p   = (Vm_Uch*) (&CFN_P(cfn)->vec[1]);
	       *p++ = buf[0];
	       *p++ = ret[0];
	       *p++ =   0xFF;
	       *p++ =   0xFF;
		vm_Dirty(cfn);
		break;

	    case 2:
		p   = (Vm_Uch*) (&CFN_P(cfn)->vec[1]);
	       *p++ = buf[0];
	       *p++ = buf[1];
	       *p++ = ret[0];
	       *p++ =   0xFF;
		vm_Dirty(cfn);
		break;

	    default:
		MUQ_FATAL ("muf.c:update_lib: internal err.");
	    }
	}
	fun = CFN_P(cfn)->src;
	if (!OBJ_IS_OBJ(     fun)
	||  !OBJ_IS_CLASS_FN(fun)
	||  FUN_P(fun)->executable != cfn
	){
	    Vm_Uch buf[ 256 ];
	    fun = obj_Alloc( OBJ_CLASS_A_FN, 0 );
	    sprintf(buf,
		"#<Server prim 0x%04x: '%s'>",
		(int)primtab[i].op, primtab[i].name
	    );
	    {   Vm_Obj source = stg_From_Asciz(buf);
		Vm_Obj name   = stg_From_Asciz(primtab[i].name);
		Vm_Int op     = primtab[i].op;
		Vm_Int arity  = job_Code[ asm_Look_Up_Primcode(op) ].arity;
		Fun_P  f      = FUN_P(fun);
		f->o.objname  = name;
		f->source     = source;
		f->executable = cfn;
		f->arity      = arity;
		vm_Dirty(fun);
            }
	    CFN_P(cfn)->src   = fun;
	    vm_Dirty(cfn);
}   }   }

 /***********************************************************************/
 /*-   muf_Startup -- start-of-world stuff.				*/
 /***********************************************************************/

void
muf_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    sort_prim_table(  mufprim );
    sort_prim_table( lispprim );

    vm_Startup();
    obj_Startup();

    if (!obj_Quick_Start) {

        /* Enter muf prims into muf package, */
        /* if they aren't already there:     */
        update_lib( mufprim, obj_Lib_Muf );

	/* Enter a constant as well: */
	update_lib_constant( obj_Lib_Muf, "#first#", OBJ_FIRST );

        /* Enter lisp prims into lisp package, */
        /* if they aren't already there:       */
        update_lib( lispprim, obj_Lib_Lisp );
    }
}

/************************************************************************/
/*-    muf_Linkup -- start-of-world stuff.				*/
/************************************************************************/

 /***********************************************************************/
 /*-   validate_compile_muf_file -- Maybe hand-assemble loop.           */
 /***********************************************************************/

static void
validate_compile_muf_file(
    void
) {
    /* Find "compileMufFile" symbol in muf package: */
    Vm_Obj compile_muf_file = lib_Validate_Symbol(
	"compileMufFile",
	obj_Lib_Muf
    );

    /* Find functional value of symbol: */
    Vm_Obj cfn       = SYM_P(compile_muf_file)->function;

    /* If it is a compiled function, assume no need to rebuild it: */
    if (OBJ_IS_CFN(cfn)) {
	obj_Lib_Muf_Compile_Muf_File = cfn;
        return;
    }


    /* Create a readEvalPrint loop fn: */

    {   Vm_Obj asm        = obj_Alloc( OBJ_CLASS_A_ASM, 0 );
	Vm_Unt muf_offset = asm_Var_Next( asm, OBJ_FROM_BYT1(' ') );

	/* Allocate needed labels: */
	Vm_Unt abrt    = asm_Label_Get( asm );
	Vm_Unt do1_top = asm_Label_Get( asm );
	Vm_Unt do2_top = asm_Label_Get( asm );
	Vm_Unt ls1     = asm_Label_Get( asm );
	Vm_Unt fi1     = asm_Label_Get( asm );

        /* Assemble an appropriate infinite loop: */

        /********************************************************************/
        /* Source looks like:                                               */
        /* : compileMufFile                                               */
        /*   make_fn make_muf -> muf      (Create a muf compiler   )        */
        /*   muf --> @$s.compiler         (Make compiler user-accessable )  */
        /*    [ :function :: { -> ! } 'abrt goto ;			    */
        /*      :name 'abort						    */
        /*      :reportFunction "Return to main mufShell prompt."    	    */
        /*    | ]withRestartDo{					    */
        /*     withTag abrt do{              (Trap compile errs etc   )    */
	/*       abrt                         (Continuation from errors)    */
        /*       readLine                    (Read a line             )    */
        /*       muf startMufCompile        (Set up to compile it    )    */
        /*       do{                          (Infinite loop over input)    */
        /*         do{                                                      */
        /*           muf continueMufCompile (Compile it              )    */
        /*         until }                                                  */
        /*         if                         (fn completed            )    */
        /*           call                     (Call fn.                )    */
        /*           readLine                (Read a line             )    */
        /*           muf startMufCompile    (Set up to compile it    )    */
        /*         else                       (fn not completed yet    )    */
        /*           pop                      (Discard suggested prompt)    */
        /*           readLine                (Another src line)            */
        /*           muf addMufSource       (Append to source string )    */
        /*         fi                         (fn completed            )    */
        /*       }                            (Infinite loop over input)    */
        /*     }                              (With-tag                )    */
        /*   }                               (With-restart            )    */
        /* ;                                                                */
        /********************************************************************/


	/*   make_fn make_muf -> muf      (Create a muf compiler   )    */
	asm_Nullary(     asm, JOB_OP_MAKE_FN				);
	asm_Nullary(     asm, JOB_OP_MAKE_MUF			        );
	asm_Var_Set(     asm, muf_offset				);

        /*   muf --> @$s.compiler         (Make compiler user-accessable )  */
	asm_Var(         asm, muf_offset				);
	asm_Nullary(	 asm, JOB_OP_JOB				);
	asm_Const(       asm, sym_Alloc_Asciz_Keyword("compiler")	);
	asm_Nullary(	 asm, JOB_OP_SYSTEM_SET_VAL			);

        /*   [ :function :: 'abrt goto ;				*/
        /*     :name 'abort						*/
        /*     :reportFunction "Return to main mufShell prompt."	*/
        /*   | ]withRestartDo{					*/
	asm_Nullary(     asm, JOB_OP_START_BLOCK		        );
	asm_Const(       asm, sym_Alloc_Asciz_Keyword("function")	);
	asm_Const(       asm, SYM_P(obj_Lib_Muf_Abrt)->function		);
	asm_Const(       asm, sym_Alloc_Asciz_Keyword("name")		);
	asm_Const(       asm, sym_Alloc_Asciz( obj_Lib_Muf, "abort", 0 ));
	asm_Const(       asm, sym_Alloc_Asciz_Keyword("reportFunction"));
	asm_Const_Asciz( asm, "Return to main mufShell prompt."	);
	asm_Nullary(     asm, JOB_OP_END_BLOCK				);
	asm_Nullary(     asm, JOB_OP_PUSH_RESTARTFRAME		        );

        /*   withTag abrt do{              (Trap compile errs etc   ) */
	asm_Const(       asm, obj_Lib_Muf_Abrt 				);
	asm_Branch(	 asm, JOB_OP_PUSH_TAG, abrt 			);
	asm_Nullary(     asm, JOB_OP_PUSH_TAGTOPFRAME			);

	/*       abrt                       (Continuation from errors)  */
	asm_Label(       asm, abrt        				);

	/*       readLine	  (Read a line		   )	*/
	/*       muf startMufCompile	  (Set up to compile it	   )	*/
	asm_Nullary(     asm, JOB_OP_READ_LINE			);
	asm_Var(	 asm, muf_offset				);
	asm_Nullary(     asm, JOB_OP_START_MUF_COMPILE			);

	/*       do{			  (Infinite loop over input)	*/
	asm_Label(       asm, do1_top         				);


	/*         do{      		  				*/
	/*           muf continueMufCompile (Compile it	   )	*/
	/*         until }     		  				*/
	asm_Label(       asm, do2_top         				);
	asm_Var(	 asm, muf_offset				);
	asm_Nullary(     asm, JOB_OP_CONTINUE_MUF_COMPILE		);
	asm_Branch(	 asm, JOB_OP_BEQ, do2_top			);

	/*         if       		  (fn completed		   )	*/
	/*           calle		  (Call fn.		   )	*/
	/*           readLine	          (Read a line		   )	*/
	/*           muf startMufCompile  (Set up to compile it  )	*/
	asm_Branch(	 asm, JOB_OP_BEQ, ls1				);
	asm_Nullary(     asm, JOB_OP_CALL				);
	asm_Nullary(     asm, JOB_OP_READ_LINE				);
	asm_Var(	 asm, muf_offset				);
	asm_Nullary(     asm, JOB_OP_START_MUF_COMPILE			);
	asm_Branch(	 asm, JOB_OP_BRA, fi1				);

	/*         else     		  (fn not completed yet    )	*/
	/*           pop	          (Discard suggested prompt)	*/
	/*           readLine      	  (Another src line        )    */
	/*           muf addMufSource   (Append to source string )    */
	/*         fi     		  (fn completed            )	*/
	asm_Label(       asm, ls1         				);
	asm_Nullary(     asm, JOB_OP_POP				);
	asm_Nullary(     asm, JOB_OP_READ_LINE				);
	asm_Var(	 asm, muf_offset				);
	asm_Nullary(     asm, JOB_OP_ADD_MUF_SOURCE			);
	asm_Label(       asm, fi1         				);

        /*       }			  (Infinite loop over input)	*/
	asm_Branch(	 asm, JOB_OP_BRA, do1_top			);


        {   Vm_Obj fn  = obj_Alloc( OBJ_CLASS_A_FN, 0 );
	    Vm_Obj src = stg_From_Asciz(
		"make_fn make_muf -> muf          (Create a muf compiler   )\n"
		"[ :function :: { -> ! } 'abrt goto ;\n"
		"  :name 'abort\n"
		"  :reportFunction \"Return to main mufShell prompt.\"\n"
		"| ]withRestartDo{\n"
		"  withTag abrt do{              (Trap compile errs etc   )\n"
		"    abrt                         (Continuation from errors)\n"
		"    readLine                    (Read a line             )\n"
		"    muf startMufCompile        (Set up to compile it    )\n"
		"    do{                          (Infinite loop over input)\n"
		"      do{\n"
		"        muf continueMufCompile (Compile it              )\n"
		"      until }\n"
		"      if                         (fn completed            )\n"
		"        call                     (Call fn.                )\n"
		"        readLine                (Read a line             )\n"
		"        muf startMufCompile    (Set up to compile it    )\n"
		"      else                       (fn not completed yet    )\n"
		"        pop                      (Discard suggested prompt)\n"
		"        readLine                (Another src line        )\n"
		"        muf addMufSource       (Append to source string )\n"
		"      fi                         (fn completed            )\n"
		"    }                            (Infinite loop over input)\n"
		"  }                              (With-tag                )\n"
		"}                                (With-restart            )\n"
	    );
	    Vm_Obj cfn = asm_Cfn_Build(
		asm,
		fn,
		FUN_ARITY( 0, 0, 0, 0, FUN_ARITY_TYP_EXIT ),
		TRUE
	    );

	    /* Plug source and executable into fn: */
	    {   Vm_Obj name      = SYM_P(compile_muf_file)->name;
	        Fun_P  p         = FUN_P(fn);
		p->source        = src;
		p->executable    = cfn;
		p->o.objname     = name;
		vm_Dirty(fn);
	    }

	    obj_Lib_Muf_Compile_Muf_File      = cfn;
	    SYM_P(compile_muf_file)->function = cfn;
	    vm_Dirty(compile_muf_file);
	}
    }
}

 /***********************************************************************/
 /*-   validate_lib_muf_first_key -- Ensure muf:min-key symbol+val exists.  */
 /***********************************************************************/

static void
validate_lib_muf_first_key(
    void
) {

    /* Find "muf:firstKey" symbol: */
    Vm_Obj sym = lib_Validate_Symbol( "firstKey", obj_Lib_Muf );

    Vm_Obj val = SYM_P(sym)->value;
    if (val != OBJ_FIRST) {
	SYM_P(sym)->value = OBJ_FIRST;
	vm_Dirty(sym);
    }
}

 /***********************************************************************/
 /*-   validate_lib_muf_abrt -- Make sure muf::abrt symbol+cfn exists.  */
 /***********************************************************************/

static void
validate_lib_muf_abrt(
    void
) {

    /* Find "muf::abrt" symbol: */
    Vm_Obj abrt = validate_hidden_lib_symbol( obj_Lib_Muf, "abrt" );

    /* Find functional value of symbol: */
    Vm_Obj cfn  = SYM_P(abrt)->function;
/*printf("muf:validate_lib_muf_abrt: abrt x=%" VM_X " obj_Lib_Muf x=%" VM_X "\n",abrt,obj_Lib_Muf);*/

    /* If it is a compiled function, assume no need to rebuild it: */
    if (OBJ_IS_CFN(cfn)) {
	obj_Lib_Muf_Abrt = abrt;
        return;
    }

    /* Hand-assemble an : abrt 'abrt goto ; function: */

    {   /* Allocate an assembler: */
	Vm_Obj asm        = obj_Alloc( OBJ_CLASS_A_ASM, 0 );

	asm_Const(       asm, abrt					);
	asm_Nullary(     asm, JOB_OP_GOTO				);

	{   Vm_Obj fn  = obj_Alloc( OBJ_CLASS_A_FN, 0 );
	    Vm_Obj src = stg_From_Asciz(
		"'muf::abrt goto"
	    );
	    Vm_Obj cfn = asm_Cfn_Build(
		asm,
		fn,
		FUN_ARITY( 0, 0, 0, 0, FUN_ARITY_TYP_NORMAL ),
		TRUE
	    );

	    /* Plug source and executable into fn: */
	    {   Vm_Obj name       = SYM_P(abrt)->name;
	        Fun_P  p          = FUN_P(fn);
		p->source         = src;
		p->executable     = cfn;
		p->o.objname      = name;
		vm_Dirty(fn);
	    }

	    obj_Lib_Muf_Abrt      = abrt;
	    SYM_P(abrt)->function = cfn;
	    vm_Dirty(abrt);
	}
    }
}

 /***********************************************************************/
 /*-   validate_lib_lsp_classes -- Get pointers to some builtins.	*/
 /***********************************************************************/

static void
validate_lib_lsp_classes(
    void
){
    /* Should make a table of classes, by and by? */
    Vm_Obj sym = OBJ_T;
    obj_Lib_Muf_Class_T = sym_Type(sym);
}

 /***********************************************************************/
 /*-   muf_Linkup -- start-of-world stuff.				*/
 /***********************************************************************/

void
muf_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    vm_Linkup();
    obj_Linkup();

    validate_lib_muf_abrt();
    validate_compile_muf_file();
    validate_public_symbols( obj_Lib_Muqnet, muqnetpub );
    validate_public_symbols( obj_Lib_Muf,    mufpub    );
    validate_hidden_symbols( obj_Lib_Muf,    mufhid    );
    validate_hidden_symbols( obj_Lib_Lisp,   lisphid   );
    validate_lib_muf_first_key();
    validate_lib_lsp_classes();
}

/************************************************************************/
/*-    muf_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
muf_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    vm_Shutdown();
    obj_Shutdown();
}

/************************************************************************/
/*-    muf_Invariants -- Sanity check on muf.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

Vm_Int muf_Invariants (
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
/*-    muf_Alloc -- Create new muf vector.				*/
/************************************************************************/

Vm_Obj
muf_Alloc(
    Vm_Obj fn
) {
    Vm_Obj muf	    = vec_Alloc( MUF_OFF_MAX, OBJ_FROM_INT(0) );
    Vm_Obj symbols  = obj_Alloc( OBJ_CLASS_A_STK, 0 );
    Vm_Obj asm      = obj_Alloc( OBJ_CLASS_A_ASM, 0 );

    vec_Set(muf, MUF_OFF_ASM,     asm		  );
    vec_Set(muf, MUF_OFF_SYMBOLS, symbols	  );
    vec_Set(muf, MUF_OFF_FN,      fn      	  );
    vec_Set(muf, MUF_OFF_FN_LINE, OBJ_FROM_UNT(0) ); 
    vec_Set(muf, MUF_OFF_LINE,    OBJ_FROM_UNT(0) ); 

    muf_Reset( muf, OBJ_FROM_UNT(0) );

    return muf;
}

/************************************************************************/
/*-    muf_Reset -- Reset muf for new compile.				*/
/************************************************************************/

void
muf_Reset(
    Vm_Obj muf,
    Vm_Obj stg
) {
    /* The point of the next is to have */
    /* commandline anonymous functions  */
    /* be implicitly { -> ? ! } so that */
    /* we can interactively type stuff  */
    /* like                             */
    /*   : x { -> ? } if pop fi ;       */
    /*   t t 'x call                    */
    /* without getting complaints from  */
    /* the arity checker.  Functions    */
    /* actually declared with : or such */
    /* don't get this default: do_colon */
    /* defaults them to arity -1.       */
    Vm_Obj arity = FUN_ARITY(
	/* blk_get: */ 0,
	/* blk_ret: */ 0,
	/* arg_get: */ 0,
	/* arg_ret: */ 0,
	/* typ      */ FUN_ARITY_TYP_Q
    );

    Vm_Obj line = LINE;

    vec_Set(muf, MUF_OFF_STR,		stg             ); 

    vec_Set(muf, MUF_OFF_BEG,		OBJ_FROM_UNT(0) ); 
    vec_Set(muf, MUF_OFF_END,		OBJ_FROM_UNT(0) ); 
    vec_Set(muf, MUF_OFF_TYP,		OBJ_FROM_UNT(0) ); 
    vec_Set(muf, MUF_OFF_CONTAINER,	OBJ_FROM_UNT(0) ); 
    vec_Set(muf, MUF_OFF_FN_LINE,	line		); 
    vec_Set(muf, MUF_OFF_FN_NAME,	OBJ_FROM_UNT(0) ); 
    vec_Set(muf, MUF_OFF_FN_BEG,	OBJ_FROM_UNT(0) ); 
    vec_Set(muf, MUF_OFF_QVARS,		OBJ_FROM_UNT(0) ); 
    vec_Set(muf, MUF_OFF_SP, OBJ_FROM_UNT(job_RunState.s-job_RunState.s_bot) );
    vec_Set(muf, MUF_OFF_SYMBOLS_SP,	OBJ_FROM_UNT(0)	);
    vec_Set(muf, MUF_OFF_ARITY,		arity           );
    vec_Set(muf, MUF_OFF_FORCE,		OBJ_T           );

    stk_Reset( SYMBOLS );
    asm_Reset( ASM );
}

/************************************************************************/
/*-    muf_Reset_Line_Number -- Set line number to zero.		*/
/************************************************************************/

void
muf_Set_Line_Number(
    Vm_Obj muf,
    Vm_Obj num
) {
    vec_Set(muf, MUF_OFF_LINE, num );
}

/************************************************************************/
/*-    muf_Continue_Compile -- Do one increment of muf fn compilation.	*/
/************************************************************************/

/*  This little puppy does one incremental step of a muf compile.	*/
/*  It exists mostly to keep long compiles from lagging			*/
/*  the muck horribly: by writing the compile outer loop in muf,	*/
/*  we allow Muq to timeslice other tasks in the middle of		*/
/*  the compile.							*/
/*									*/
/*  The return value is #f if the compile hasn't finished		*/
/*  processing the current the current string yet.			*/
/*									*/
/*  The return value is "\nthen> " #f #t if the compile has		*/
/*  completed the given string but can't complete the compile		*/
/*  due to an open "if ... then" construct: other unterminated		*/
/*  constructs result in other secondary prompts being returned.	*/
/*									*/
/*  The return value is fn #t #t if the compile has completed the	*/
/*  given line and also compiled a complete fn, in which case		*/
/*  'fn' is the compiled fn.						*/

void
muf_Continue_Compile(
    Vm_Obj muf
) {
    if (!next_token( muf )) {

        /* Decide whether we are in any nested       */
        /* structures that prevent us from compiling */
        /* supplied code at this point:    	     */
        Vm_Obj* old_s =  job_RunState.s_bot + OBJ_TO_UNT( SP );
	if (old_s >  job_RunState.s) warn(muf,"Stack trashed during compile");
	if (old_s == job_RunState.s) {

	    /* No tokens left.  Do final processing on fn: */
	    fn_fill( muf );

	    /* Done compiling this line: */
	    job_Guarantee_Headroom( 3 );
	    {   Vm_Obj  fn = FN;
		Vm_Obj cfn = FUN_P(fn)->executable;
		Vm_Obj* s = job_RunState.s;
		s[3] = OBJ_TRUE;
		s[2] = OBJ_TRUE;
		s[1] = cfn;
		job_RunState.s += 3;
	    }
	    return;
	}

	/* Figure out what sort of lexical */
	/* structure we are nested in, and */
	/* return an appropriate secondary */
	/* prompt based on that.           */

	/* Figure type of innermost nested block: */
	{   Vm_Uch prompt[80];
	    strcpy(                 prompt, "-----> " );
	    switch (toptag( muf )) {
	    case LBRK: 	    strcpy( prompt, "|----> " );	break;
	    case COLN: 	    strcpy( prompt, ";----> " );	break;
	    case ORIG: 	    strcpy( prompt, "fi---> " );	break;
	    case DEST_TOP:  strcpy( prompt, "}----> " );	break;
	    case DEST_VAR:  strcpy( prompt, "}----> " );	break;
	    default:
		;
	    }

	    /* Figure number of nested blocks: */
	    {   Vm_Int n = nesting( muf ) & 0xF;
		while (n --> 0) strcat( prompt, "  " );
	    }

	    /* Return prompt and request for another input line: */
	    job_Guarantee_Headroom( 3 );
	    {   Vm_Obj  stg = stg_From_Asciz(prompt);
		register Vm_Obj* s = job_RunState.s;
		s[3] = OBJ_TRUE;
		s[2] = OBJ_NIL;
		s[1] = stg;
		job_RunState.s += 3;
	    }
	}
	return;
    }

    assemble_token( muf );

    /* Still chugging along, just return NIL: */
/* buggo, need to have constant type signatures on all functions. */
    {   Vm_Obj*  s = ++job_RunState.s;
	s[0]       = OBJ_NIL;
    }
}

/************************************************************************/
/*-    muf_Read_Next_Muf_Token -- Scan string for muf token.		*/
/************************************************************************/

void
muf_Read_Next_Muf_Token(
    Vm_Int* beg_out,
    Vm_Int* end_out,
    Vm_Obj* typ_out,

    Vm_Unt  beg_in,
    Vm_Obj  stg
) {
    struct next_token_state p;

    p.stg = stg;
    p.beg = OBJ_FROM_INT( beg_in );
    p.end = OBJ_FROM_INT( beg_in );

    {   Vm_Int result = next_token2( &p );
	if (!result) {
	    *typ_out = OBJ_FROM_INT(      0 );
	    *beg_out =               beg_in  ;
	    *end_out =               beg_in  ;
	} else {
	    *typ_out =             p.typ  ;
	    *beg_out = OBJ_TO_INT( p.beg );
	    *end_out = OBJ_TO_INT( p.end );
    }   }
}

/************************************************************************/
/*-    muf_Source_Add -- Append some source stg to current source stg.	*/
/************************************************************************/

void
muf_Source_Add(
    Vm_Obj muf,
    Vm_Obj stg
) {
    Vm_Obj  old_stg = STR;
    Vm_Obj  new_stg = stg_Concatenate( old_stg, stg );

    vec_Set(muf, MUF_OFF_STR, new_stg );
}

/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    assemble_token -- Assemble one token.				*/
/************************************************************************/

 /***********************************************************************/
 /*-   atoc -- Convert a string to a char, interpreting \t etc.		*/
 /***********************************************************************/

static Vm_Int
atoc(
    Vm_Obj  muf,
    Vm_Uch* buf
) {
    Vm_Int c;
    if (buf[1] != '\\') {
	c = buf[1];
	if (buf[2] != '\'') warn(muf,"Bad char const: %s",buf);
    } else {
	/* This is most of the easy stuff ANSI C wants.  */
	/* Doesn't include the \ooo \??? and \xff stuff: */
	switch (buf[2]) {
	/* I find it intriguing how knowledge of the esc */
	/* sequences propagates from one compiler to     */
	/* another below, without me needing to know what*/
	/* they actually expand into *grin*:             */
	case '0':   c = '\0';	break;
	case 'a':   c = '\a';	break;
	case 'b':   c = '\b';	break;
	case 'e':   c = '\033';	break;
	case 'f':   c = '\f';	break;
	case 'n':   c = '\n';	break;
	case 'r':   c = '\r';	break;
	case 't':   c = '\t';	break;
	case 'v':   c = '\v';	break;
	default:    c = buf[2]; break;
	}
	if (buf[3] != '\'') warn(muf,"Bad char const: %s",buf);
    }
    return c;
}

 /***********************************************************************/
 /*-   copy_token_to_buffer -- Extract token string from source string.	*/
 /***********************************************************************/

/* We return FALSE if it didn't fit, else token len: */

static Vm_Unt
copy_token_to_buffer(
    Vm_Uch* buf,
    Vm_Unt  bufsiz,
    Vm_Obj  muf
) {
    Vm_Unt beg = OBJ_TO_UNT( BEG );
    Vm_Unt end = OBJ_TO_UNT( END );
    Vm_Obj stg =             STR  ;

    if ((Vm_Unt)(end - beg) > bufsiz-1) {
        return FALSE;
    }

    {   Vm_Int u;
	for (u = beg;   u < end;   ++u) {
	    if (!stg_Get_Byte( &buf[u-beg], stg, u )) MUQ_FATAL ("copy_token");
        }
        buf[u-beg] = '\0';
    }

    return end-beg;
}

 /***********************************************************************/
 /*-   downcase_buffer -- Downcase null-terminated buffer.		*/
 /***********************************************************************/

/* We return FALSE if it didn't fit, else token len: */

static void
downcase_buffer(
    Vm_Uch* buf
) {
    register Vm_Uch*b = buf;
    register Vm_Uch last = ' ';
    register Vm_Uch c;
    while (c = *b) {
	if (c == '\'' && b[2]=='\'' && last != '\\') {
	    /* Don't downcase 'a': */
	    b += 3;
	} else if (c == '"' && last != '\\') {
	    /* Don't downcase "a": */
	    while ((c = *++b)   &&   (c != '"' || last == '\\')) {
		last = c;
	    }
	} else {
	    last = c;
#ifdef CASE_INSENSITIVE
	    *b++ = tolower( c );
#else
	    *b++ =          c  ;
#endif
	}
    }
}

 /***********************************************************************/
 /*-   copy_token_to_lc_buffer -- Downcase token while extracting it.	*/
 /***********************************************************************/

/* We return FALSE if it didn't fit, else token len: */

static Vm_Unt
copy_token_to_lc_buffer(
    Vm_Uch* buf,
    Vm_Unt  bufsiz,
    Vm_Obj  muf
) {
    Vm_Unt len = copy_token_to_buffer( buf, bufsiz, muf );
    if (len)   downcase_buffer( buf );
    return len;
}

 /***********************************************************************/
 /*-   do_after      -- Compile an 'after{'				*/
 /***********************************************************************/

static void
do_after(
    Vm_Obj   muf,
    Vm_Unt   as_child
) {
    Vm_Unt label = asm_Label_Get( ASM );
    if (as_child)   asm_Branch( ASM, JOB_OP_PUSH_PROTECT_CHILD, label );
    else            asm_Branch( ASM, JOB_OP_PUSH_PROTECT      , label );
    push_after( label );
}

 /***********************************************************************/
 /*-   do_parameter   -- Compile a 'parameter:'				*/
 /***********************************************************************/

static void
do_parameter(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Read next token, which is our variable name: */
    Vm_Uch buf[ 256 ];
    if (!next_token( muf )) {
	warn(muf,"parameter: without varname on same line");
    }
    if (!copy_token_to_lc_buffer(buf,256,muf)) {
	warn(muf,"parameter: var name too long");
    }

    /* Find/create local var: */
    lvar_offset( muf, buf );
}

 /***********************************************************************/
 /*-   do_always     -- Compile an '}alwaysDo{'			*/
 /***********************************************************************/

static void
do_always(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
#ifdef OLD
    Vm_Unt label = pop_after( muf );
    push_always( 0 );
    asm_Nullary( ASM, JOB_OP_BLANCH_PROTECTFRAME );
    asm_Label(   ASM, label );
#else
    Vm_Unt last_label = pop_after( muf );
    Vm_Unt next_label = asm_Label_Get( ASM );
    push_always( next_label );
    asm_Branch( ASM, JOB_OP_BLANCH_PROTECT, next_label );
    asm_Label(   ASM, last_label );
#endif
}

 /***********************************************************************/
 /*-   do_aarrow     -- Compile a  '-->' or '-->constant'		*/
 /***********************************************************************/

static void
do_aarrow(
    Vm_Obj   muf,
    Vm_Unt   mode	/* 0 or MODE_CONST.	*/
) {
    /* Read next token, which is our variable name: */
    Vm_Uch buf[ 1024 ];
    if (!next_token( muf )) warn(muf,"--> without varname on same line");
    if (!copy_token_to_lc_buffer(buf,1024,muf)) {
	warn(muf,"Var name too long");
    }
    if        (buf[0] == '#' &&  buf[1] == '\'') {
	if (mode) warn(muf,"-->constant #'fn not supported.");
	compile_path( muf, buf+2, (mode&~MODE_GET)|MODE_SET|MODE_FN     );
    } else if (buf[0] == '\''){
	compile_path( muf, buf+1, (mode&~MODE_GET)|MODE_SET|MODE_QUOTE  );
    } else {
	compile_path( muf, buf  , (mode&~MODE_GET)|MODE_SET	            );
    }
}

 /***********************************************************************/
 /*-   do_arrow      -- Compile a  '->'					*/
 /***********************************************************************/

static void
do_arrow(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Read next token, which is our variable name: */
    Vm_Uch buf[ 256 ];
    if (!next_token( muf )) warn(muf,"-> without varname on same line");
    if (!copy_token_to_lc_buffer(buf,256,muf)) {
	warn(muf,"Var name too long");
    }

#ifdef BAD_IDEA
    /* Killed this check because I want to do stuff like */
    /* 4 seq[ |for s do{ s 2 * -> s }:                   */
    /* Complain if outside all fn definitions: */
    if (CONTAINER == OBJ_FROM_UNT(0)) {
	warn(muf,"Only use '->' inside fns -- Use '-->' outside them.");
    }
#endif
    /* Check that user isn't confusing -> with --> */
    /* and trying to assign into a path:           */
    {   Vm_Uch* t = buf;
	int  c;
        for (t = buf;  c = *t;  ++t) {
	    switch (c) {
	    case '$':    
		warn(muf,
		    "No '$'s allowed in local names. (Did you want '-->'?)",
		    c
		);
		break;

	    case '[':   case ']':
	    case ':':	case '.':
		warn(muf,
		    "No '%c's allowed in local names. (Did you want '-->'?)",
		    c
		);
    }	}   }

    /* Find/create local var, then */
    /* deposit a store to it:      */
    asm_Var_Set( ASM, lvar_offset( muf, buf ) );
}

 /***********************************************************************/
 /*-   do_barfor     -- Compile a  '|for'				*/
 /***********************************************************************/

static void
do_barfor(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Basic syntax is "|for v [i] do{ ... }" (i optional): */

    /* Read next token, which is our variable name: */
    Vm_Uch varname[ 256 ];
    Vm_Uch idxname[ 256 ];
    if (!next_token( muf )) warn(muf,"|for without varname on same line");
    if (!copy_token_to_lc_buffer(varname,256,muf)) {
	warn(muf,"Var name too long");
    }

    /* Next token may be optional varname or 'do{': */
    {   Vm_Uch dobrace[ 256 ];
	if (!next_token( muf )
	||  !copy_token_to_lc_buffer(dobrace,256,muf)
	){
	    warn(muf,"|for without do{ on same line");
    	}
	if (STRCMP( "do{", == ,dobrace )) {
	    idxname[0]='\0';
	} else {
	    /* Optional index var name has been supplied: */

	    /* Remember index var name: */
	    strcpy(idxname,dobrace);

	    /* Eat following 'do{': */
	    if (!next_token( muf )
	    ||  !copy_token_to_lc_buffer(dobrace,256,muf)
	    ||   STRCMP( "do{", != ,dobrace )
	    ){
		warn(muf,"|for without do{ on same line");
    }   }   }

    {   /* Create/find our local variable,    */
	/* remember its offset in stackframe: */
	Vm_Int var_offset = lvar_offset( muf, varname );

	/* Create an anonymous local variable to */
	/* hold current offset into stack block: */
	Vm_Int idx_offset = (
	    idxname[0]    		?
	    lvar_offset( muf, idxname ) :
	    asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','|','0') )
	);

	/* Create an anonymous local variable */
	/* to hold stack block size:          */
	Vm_Int lim_offset = asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','|','1') );

	/* Create an anonymous local variable */
	/* to hold stack base offset:         */
	Vm_Int bas_offset = asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','|','2') );

	/* Allocate labels for our loop: */
	Vm_Unt top = asm_Label_Get( ASM );
	Vm_Unt bot = asm_Label_Get( ASM );
	Vm_Unt xit = asm_Label_Get( ASM );

	Vm_Unt mid = asm_Label_Get( ASM );

	/* Deposit code to initialize  */
	/* limit var to blocksize:     */
	do_op( 	       muf, JOB_OP_BLOCK_LENGTH );
	asm_Var_Set(   ASM, lim_offset );

	/* Deposit code to initialize  */
	/* base var to block base:     */
	do_op( 	       muf, JOB_OP_DEPTH );
	asm_Var(       ASM, lim_offset   );
	do_op( 	       muf, JOB_OP_SUB   );
	asm_Const(     ASM, OBJ_FROM_INT(1) );
        do_op(	       muf, JOB_OP_SUB   );
	asm_Var_Set(   ASM, bas_offset   );

	/* Deposit code to initialize  */
	/* index var to -1:            */
        do_const(      muf, OBJ_FROM_INT(-1)    );
	asm_Var_Set(   ASM, idx_offset );


	/* Generate top of loop: */
	push_dest( top, bot, xit );
	asm_Label( ASM, top      );

	/* Deposit code to save result */
	/* of previous loop back in    */
        /* appropriate stack slot.     */
	/* Don't do this first time:   */
	asm_Var(       ASM, idx_offset );
	asm_Const(     ASM, OBJ_FROM_INT(-1) );
	do_op( 	       muf, JOB_OP_AEQ );
	asm_Branch(    ASM, JOB_OP_BNE, mid );

	asm_Var(       ASM, var_offset );
	asm_Var(       ASM, bas_offset );
	asm_Var(       ASM, idx_offset );
	do_op( 	       muf, JOB_OP_ADD );
	do_op(	       muf, JOB_OP_SET_BTH );

        asm_Label(     ASM, mid );

	/* Deposit code to increment   */
	/* index variable by one:      */
	asm_Var(       ASM, idx_offset );
	asm_Const(     ASM, OBJ_FROM_INT(1) );
	do_op(         muf, JOB_OP_ADD );
	asm_Var_Set(   ASM, idx_offset );

	/* Deposit code to exit if     */
	/* index variable >= limit:    */
	asm_Var(       ASM, idx_offset );
	asm_Var(       ASM, lim_offset );
	do_op( 	       muf, JOB_OP_AGE );
	asm_Branch(    ASM, JOB_OP_BNE, xit );

	/* Deposit code to load appropriate  */
	/* block element into our local var: */
	asm_Var(       ASM, bas_offset   );
	asm_Var(       ASM, idx_offset   );
        do_op(	       muf, JOB_OP_ADD   );
	do_op(	       muf, JOB_OP_DUP_BTH  );
	asm_Var_Set(   ASM, var_offset   );
    }
}

 /***********************************************************************/
 /*-   do_barfor_pairs   -- Compile a  '|forPairs'			*/
 /***********************************************************************/

static void
do_barfor_pairs(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Basic syntax is "|forPairs k v [i] do{ ... }" (i optional): */

    /* Read next token, which is our key variable name: */
    Vm_Uch keyname[ 256 ];
    Vm_Uch valname[ 256 ];
    Vm_Uch idxname[ 256 ];
    if (!next_token( muf )) warn(muf,"|forPairs without key on same line");
    if (!copy_token_to_lc_buffer(keyname,256,muf)) {
	warn(muf,"Key name too long");
    }
    if (!next_token( muf )) warn(muf,"|forPairs without val on same line");
    if (!copy_token_to_lc_buffer(valname,256,muf)) {
	warn(muf,"Var name too long");
    }

    /* Next token may be optional idxname or 'do{': */
    {   Vm_Uch dobrace[ 256 ];
	if (!next_token( muf )
	||  !copy_token_to_lc_buffer(dobrace,256,muf)
	){
	    warn(muf,"|forPairs without do{ on same line");
    	}
	if (STRCMP( "do{", == ,dobrace )) {
	    idxname[0]='\0';
	} else {
	    /* Optional index var name has been supplied: */

	    /* Remember index var name: */
	    strcpy(idxname,dobrace);

	    /* Eat following 'do{': */
	    if (!next_token( muf )
	    ||  !copy_token_to_lc_buffer(dobrace,256,muf)
	    ||   STRCMP( "do{", != ,dobrace )
	    ){
		warn(muf,"|forPairs without do{ on same line");
    }   }   }

    {   /* Create/find our local variables,    */
	/* remember its offsets in stackframe: */
	Vm_Int key_offset = lvar_offset( muf, keyname );
	Vm_Int val_offset = lvar_offset( muf, valname );

	/* Create an anonymous local variable to */
	/* hold current offset into stack block: */
	Vm_Int idx_offset = (
	    idxname[0]    		?
	    lvar_offset( muf, idxname ) :
	    asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','|','0') )
	);

	/* Create an anonymous local variable */
	/* to hold stack block size:          */
	Vm_Int lim_offset = asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','|','1') );

	/* Create an anonymous local variable */
	/* to hold stack base offset:         */
	Vm_Int bas_offset = asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','|','2') );

	/* Allocate labels for our loop: */
	Vm_Unt top = asm_Label_Get( ASM );
	Vm_Unt bot = asm_Label_Get( ASM );
	Vm_Unt xit = asm_Label_Get( ASM );

	Vm_Unt mid = asm_Label_Get( ASM );

	/* Deposit code to initialize  */
	/* limit var to blocksize:     */
	do_op( 	       muf, JOB_OP_BLOCK_LENGTH );
	asm_Var_Set(   ASM, lim_offset );

	/* Deposit code to initialize  */
	/* base var to block base:     */
	do_op( 	       muf, JOB_OP_DEPTH );
	asm_Var(       ASM, lim_offset   );
	do_op( 	       muf, JOB_OP_SUB   );
	asm_Const(     ASM, OBJ_FROM_INT(1) );
        do_op(	       muf, JOB_OP_SUB   );
	asm_Var_Set(   ASM, bas_offset   );

	/* Deposit code to initialize  */
	/* index var to -2:            */
        do_const(      muf, OBJ_FROM_INT(-2)    );
	asm_Var_Set(   ASM, idx_offset );


	/* Generate top of loop: */
	push_dest( top, bot, xit );
	asm_Label( ASM, top      );

	/* Deposit code to save result */
	/* of previous loop back in    */
        /* appropriate stack slot.     */
	/* Don't do this first time:   */
	asm_Var(       ASM, idx_offset );
	asm_Const(     ASM, OBJ_FROM_INT(-2) );
	do_op( 	       muf, JOB_OP_AEQ );
	asm_Branch(    ASM, JOB_OP_BNE, mid );

	asm_Var(       ASM, key_offset );
	asm_Var(       ASM, bas_offset );
	asm_Var(       ASM, idx_offset );
	do_op( 	       muf, JOB_OP_ADD );
	do_op(	       muf, JOB_OP_SET_BTH );

	asm_Var(       ASM, val_offset );
	asm_Var(       ASM, bas_offset );
	asm_Var(       ASM, idx_offset );
	do_op( 	       muf, JOB_OP_ADD );
	asm_Const(     ASM, OBJ_FROM_INT(1) );
	do_op( 	       muf, JOB_OP_ADD );
	do_op(	       muf, JOB_OP_SET_BTH );

        asm_Label(     ASM, mid );

	/* Deposit code to increment   */
	/* index variable by two:      */
	asm_Var(       ASM, idx_offset );
	asm_Const(     ASM, OBJ_FROM_INT(2) );
	do_op(         muf, JOB_OP_ADD );
	asm_Var_Set(   ASM, idx_offset );

	/* Deposit code to exit if     */
	/* index variable >= limit:    */
	asm_Var(       ASM, idx_offset );
	asm_Var(       ASM, lim_offset );
	do_op( 	       muf, JOB_OP_AGE );
	asm_Branch(    ASM, JOB_OP_BNE, xit );

	/* Deposit code to load appropriate    */
	/* block elements into our local vars: */
	asm_Var(       ASM, bas_offset   );
	asm_Var(       ASM, idx_offset   );
        do_op(	       muf, JOB_OP_ADD   );
	do_op(	       muf, JOB_OP_DUP_BTH  );
	asm_Var_Set(   ASM, key_offset   );

	asm_Var(       ASM, bas_offset   );
	asm_Var(       ASM, idx_offset   );
        do_op(	       muf, JOB_OP_ADD   );
	asm_Const(     ASM, OBJ_FROM_INT(1) );
	do_op( 	       muf, JOB_OP_ADD );
	do_op(	       muf, JOB_OP_DUP_BTH  );
	asm_Var_Set(   ASM, val_offset   );
    }
}

 /***********************************************************************/
 /*-   do_listfor    -- Compile a  'listfor'				*/
 /***********************************************************************/

static void
do_listfor(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Basic syntax is "<list> listfor val cons do{ ... }" (i optional): */

    /* Read next token, which is our variable name: */
    Vm_Uch varname[ 256 ];
    Vm_Uch cnsname[ 256 ];
    if (!next_token( muf )) warn(muf,"listfor without varname on same line");
    if (!copy_token_to_lc_buffer(varname,256,muf)) {
	warn(muf,"Var name too long");
    }

    /* Next token may be optional cnsname or 'do{': */
    {   Vm_Uch dobrace[ 256 ];
	if (!next_token( muf )
	||  !copy_token_to_lc_buffer(dobrace,256,muf)
	){
	    warn(muf,"|for without do{ on same line");
    	}
	if (STRCMP( "do{", == ,dobrace )) {
	    cnsname[0]='\0';
	} else {
	    /* Optional cnsname var name has been supplied: */

	    /* Remember cnsname: */
	    strcpy(cnsname,dobrace);

	    /* Eat following 'do{': */
	    if (!next_token( muf )
	    ||  !copy_token_to_lc_buffer(dobrace,256,muf)
	    ||   STRCMP( "do{", != ,dobrace )
	    ){
		warn(muf,"listfor without do{ on same line");
    }   }   }

    {   /* Create/find our local variable,    */
	/* remember its offset in stackframe: */
	Vm_Int var_offset = lvar_offset( muf, varname );

	/* Create an anonymous local variable */
	/* to hold current cons cell in list: */
	Vm_Int cns_offset = (
	    cnsname[0]			?
	    lvar_offset( muf, cnsname ) :
	    asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','L','0') )
	);

	Vm_Int lst_offset = asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','L','1') );

	/* Allocate labels for our loop: */
	Vm_Unt top = asm_Label_Get( ASM );
	Vm_Unt bot = asm_Label_Get( ASM );
	Vm_Unt xit = asm_Label_Get( ASM );

	Vm_Unt mid = asm_Label_Get( ASM );

	/* Deposit code to initialize */
	/* cns var to list:           */
	asm_Var_Set(   ASM, cns_offset );

	/* Deposit code to initialize */
	/* lst slot to NIL.           */
	asm_Const(     ASM, OBJ_NIL );
	asm_Var_Set(   ASM, lst_offset );



	/* Generate top of loop: */
	push_dest( top, bot, xit );
	asm_Label( ASM, top      );

	/* Deposit code to save result */
	/* of previous loop back in    */
        /* appropriate cons cell.      */
	/* Don't do this first time:   */
	asm_Var(       ASM, lst_offset );
	asm_Branch(    ASM, JOB_OP_BEQ, mid );

	asm_Var(       ASM, cns_offset );
	asm_Var(       ASM, var_offset );
	do_op( 	       muf, JOB_OP_RPLACA );

	/* Deposit code to step to     */
	/* next cons cell:             */
	asm_Var(       ASM, cns_offset );
	do_op(         muf, JOB_OP_CDR );
	asm_Var_Set(   ASM, cns_offset );

        asm_Label(     ASM, mid );

	/* Remember we've done first time: */
	asm_Var(       ASM, cns_offset );
	asm_Var_Set(   ASM, lst_offset );

	/* Deposit code to exit if     */
	/* cons cell is nil:           */
	asm_Var(       ASM, cns_offset );
	asm_Branch(    ASM, JOB_OP_BEQ, xit );

	/* Deposit code to load appropriate */
	/* list element into our local var: */
	asm_Var(       ASM, cns_offset   );
        do_op(	       muf, JOB_OP_CAR   );
	asm_Var_Set(   ASM, var_offset   );
    }
}

 /***********************************************************************/
 /*-   do_brace	     -- Compile a  '{'					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-  parse_arity   -- Reduce " $ $ -> }" to an arity.			*/
  /**********************************************************************/

static Vm_Obj
parse_arity(
    Vm_Obj*  force,
    Vm_Obj   muf
) {
    Vm_Uch   tok[ MUF_MAX_STR ];
    Vm_Int   blk_get = 0;
    Vm_Int   blk_ret = 0;
    Vm_Int   arg_get = 0;
    Vm_Int   arg_ret = 0;
    Vm_Int   typ     = FUN_ARITY_TYP_NORMAL;

    *force = OBJ_NIL;

    /* Scan part preceding the -> */
    for (;;) {
	/* Read next token: */
	if (!next_token( muf )
	||  !copy_token_to_lc_buffer(tok,MUF_MAX_STR,muf)
        ){
	    warn(muf,"{ without } on same line");
	}

	if        (STRCMP( tok, == ,"->" )) {   break;
	} else if (STRCMP( tok, == ,"}"  )) {   break;
	} else if (STRCMP( tok, == ,"[]" )) {   ++blk_get;
	    if (arg_get)  warn(muf,"'[]'s must precede '$'s!'");
	} else if (STRCMP( tok, == ,"$"  )) {   ++arg_get;
	} else {
	    warn(muf,"Unrecognized prototype syntax '%s'",tok);
	}
    }

    if (STRCMP( tok, != ,"}" )) {

	/* Scan part succeeding the -> */
	for (;;) {
	    /* Read next token: */
	    if (!next_token( muf )
	    ||  !copy_token_to_lc_buffer(tok,MUF_MAX_STR,muf)
	    ){
		warn(muf,"{ without } on same line");
	    }

	    if        (STRCMP( tok, == ,"}"  )) {   break;
	    } else if (STRCMP( tok, == ,"[]" )) {   ++blk_ret;
		if (arg_ret)  warn(muf,"'[]'s must precede '$'s!'");
	    } else if (STRCMP( tok, == ,"$"    )) {   ++arg_ret;
	    } else if (STRCMP( tok, == ,"!"    )) {*force = OBJ_TRUE;
	    } else if (STRCMP( tok, == ,"?"    )) {   typ = FUN_ARITY_TYP_Q;
	    } else if (STRCMP( tok, == ,"["    )) {   typ = FUN_ARITY_TYP_START_BLOCK;
	    } else if (STRCMP( tok, == ,"|"    )) {   typ = FUN_ARITY_TYP_END_BLOCK;
	    } else if (STRCMP( tok, == ,"]"    )) {   typ = FUN_ARITY_TYP_EAT_BLOCK;
	    } else if (STRCMP( tok, == ,"]v"   )) {   typ = FUN_ARITY_TYP_EAT_BLOCK;
	    } else if (STRCMP( tok, == ,"]l"   )) {   typ = FUN_ARITY_TYP_EAT_BLOCK;
	    } else if (STRCMP( tok, == ,"]i08" )) {   typ = FUN_ARITY_TYP_EAT_BLOCK;
	    } else if (STRCMP( tok, == ,"]i16" )) {   typ = FUN_ARITY_TYP_EAT_BLOCK;
	    } else if (STRCMP( tok, == ,"]i32" )) {   typ = FUN_ARITY_TYP_EAT_BLOCK;
	    } else if (STRCMP( tok, == ,"]f32" )) {   typ = FUN_ARITY_TYP_EAT_BLOCK;
	    } else if (STRCMP( tok, == ,"]f64" )) {   typ = FUN_ARITY_TYP_EAT_BLOCK;
	    } else if (STRCMP( tok, == ,"@"    )) {   typ = FUN_ARITY_TYP_EXIT;
		if (blk_ret) warn(muf,"'@' precludes returning '[]'!");
		if (arg_ret) warn(muf,"'@' precludes returning '$'!");
	    } else {
		warn(muf,"Unrecognized prototype syntax '%s'",tok);
	    }
	}
    }

    return   FUN_ARITY( blk_get, blk_ret, arg_get, arg_ret, typ );
}

 /***********************************************************************/
 /*-   do_brace	     -- Compile a  '{'					*/
 /***********************************************************************/

static void
do_brace(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Obj force;
    Vm_Obj arity = parse_arity( &force, muf );
    vec_Set( muf, MUF_OFF_ARITY, arity );
    vec_Set( muf, MUF_OFF_FORCE, force );
}

 /***********************************************************************/
 /*-   do_calla	     -- Compile a  'call{'				*/
 /***********************************************************************/

static void
do_calla(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Obj force;
    Vm_Obj arity = parse_arity( &force, muf );
    asm_Calla( ASM, arity );
}

 /***********************************************************************/
 /*-   do_loop	     -- Compile a  'do{'				*/
 /***********************************************************************/

static void
do_loop(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Unt top = asm_Label_Get( ASM );
    Vm_Unt bot = asm_Label_Get( ASM );
    Vm_Unt xit = asm_Label_Get( ASM );

    push_dest( top, bot, xit );

    asm_Label( ASM, top );
}

 /***********************************************************************/
 /*-   do_as_me -- Compile an  'asMeDo{'				*/
 /***********************************************************************/

static void
do_as_me(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    push_user();
    do_op( muf, JOB_OP_PUSH_USER_ME_FRAME );
}

 /***********************************************************************/
 /*-   do_as_user -- Compile a  'rootAsUserDo{'			*/
 /***********************************************************************/

static void
do_as_user(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    push_user();
    do_op( muf, JOB_OP_ROOT_PUSH_USER_FRAME );
}

 /***********************************************************************/
 /*-   do_omnipotently -- Compile a  'rootOmnipotentlyDo{'		*/
 /***********************************************************************/

static void
do_omnipotently(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    push_privs();
    do_op( muf, JOB_OP_ROOT_PUSH_PRIVS_OMNIPOTENT_FRAME );
}

 /***********************************************************************/
 /*-   do_withhandlers -- Compile a  ']withHandlersDo{'		*/
 /***********************************************************************/

static void
do_withhandlers(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    push_handlers();
    do_op( muf, JOB_OP_PUSH_HANDLERSFRAME );
}

 /***********************************************************************/
 /*-   do_withlock   -- Compile a  'withLockDo{'			*/
 /***********************************************************************/

static void
do_withlock(
    Vm_Obj   muf,
    Vm_Unt   child
) {
    push_lock();
    do_op(
        muf,
	child ? JOB_OP_PUSH_LOCKFRAME_CHILD : JOB_OP_PUSH_LOCKFRAME
    );
}

 /***********************************************************************/
 /*-   do_withrestart -- Compile a  'withRestartDo{'			*/
 /***********************************************************************/

static void
do_withrestart(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    push_restart();
    do_op( muf, JOB_OP_PUSH_RESTARTFRAME );
}

 /***********************************************************************/
 /*-   do_loop_finish -- Compile a  'loopFinish'			*/
 /***********************************************************************/

static void
do_loop_finish(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Check that 'loopFinish' is in a loop: */
    Vm_Int exit_loc;
    Vm_Int after_loc;
    if (!find_tag( &exit_loc, DEST_XIT )) {
	warn(muf,"'loopFinish' must be within a loop.");
    }

    /* Check that 'loopFinish' isn't jumping out of   */
    /* an after{ }alwaysDo{ }. (We should allow */
    /* doing so some day, but need to do some    */
    /* work to preserve after{}alwaysDo{} first:*/
    if (find_tag( &after_loc, AFTER )
    &&  after_loc > exit_loc
    ){
	warn(muf,"May not 'loopFinish' out of after{ }alwaysDo{ }.");
    }

    /* Deposit branch to loop exit: */
    asm_Branch( ASM, JOB_OP_BRA, LABEL( OBJ_TO_INT( jS.s[ exit_loc ] ) ) );
}

 /***********************************************************************/
 /*-   do_catch      -- Compile a  'catch{'				*/
 /***********************************************************************/

static void
do_catch(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Unt orig = asm_Label_Get( ASM );
    asm_Branch( ASM, JOB_OP_PUSH_CATCH, orig );
    push_orig( orig );
    push_catch();
}

 /***********************************************************************/
 /*-   do_tag      -- Compile a  'withTags ... do{'			*/
 /***********************************************************************/

static void
do_tag(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Unt tag_count = 0;

    /* This isn't logically needed, but I feel */
    /* better having the extra checking, first */
    /* time around:                            */
    push_gobot();

    /* Read tags until we reach a 'do{': */
    for (;;) {   Vm_Uch buf[ 256 ];

	if (!next_token( muf )
	||  !copy_token_to_lc_buffer(buf,256,muf)
	){
	    warn(muf,"withTags without do{ on same line");
    	}

	if (STRCMP( "do{", == ,buf ))   break;

	{   /* Found tag name. */

	    /* Convert it to a symbol: */
	    Vm_Obj sym   = sym_Alloc_Full_Asciz( JOB_P(jS.job)->package, buf );
	    Vm_Obj nam   = SYM_P(sym)->name;

	    /* Allocate an assembly label for it: */
	    Vm_Unt label = asm_Label_Get( ASM );

	    /* Generate code to push an appropriate tagframe: */
	    do_const( muf, sym );
	    asm_Branch( ASM, JOB_OP_PUSH_TAG, label );

	    /* Remember that we need to generate a matching pop: */
	    push_goto();
	    ++tag_count;

	    /* Remember tag is defined: */
	    symbol_push(
		muf,
		nam,
		OBJ_FROM_INT(   TYPED_OFFSET( LOCAL_TAG, label )   )
	    );
    }   }

    do_op( muf, JOB_OP_PUSH_TAGTOPFRAME );
    push_gotop( tag_count );
}

 /***********************************************************************/
 /*-   do_colon      -- Compile : :: 1: *: ...				*/
 /***********************************************************************/

static void
do_colon(
    Vm_Obj   muf,
    Vm_Unt   is_anonymous	/* FALSE, 'a'(-nonymous) or 't'(-hunk)	*/
) {
    /**********************************************/
    /* Make a new_muf copy of muf, then          */
    /* hang it beneath muf via 'container'.       */
    /* (This logically pushes 'muf' while         */
    /* physically keeping 'muf' as top of         */
    /* the chain, to save our callers from having */
    /* to update their 'muf' pointers.)	          */
    /* We want to keep new bytecodes & constants  */
    /* stacks, however:				  */
    /**********************************************/

    /* Allocate new function being compiled: */
    Vm_Obj fn            = obj_Alloc( OBJ_CLASS_A_FN, 0 );

    /* Allocate muf to save state of current function in: */
    Vm_Obj sub_muf   = muf_Alloc( fn );

    /* Find where our private symbols end,	*/
    /* so we can discard symbols private to	*/
    /* new fn when done compiling it:		*/
    Vm_Obj symbols  = SYMBOLS;
    Vm_Obj symbolsSp= stk_Length(symbols);
    Vm_Obj new_asm;
    Vm_Obj line;
    Vm_Int was_global;

    /* Get hard pointers to top and new mufs, */
    /* so we can copy stuff between them:     */
    {	Vec_P  sub;
	Vec_P  sup;
	vm_Loc2( (void**)&sub, (void**)&sup, sub_muf, muf );

	was_global = (sup->slot[ MUF_OFF_CONTAINER ] == OBJ_FROM_UNT(0));

	/* Preserve needed values from new record: */
	new_asm	= sub->slot[ MUF_OFF_ASM  ];

	/* Copy old values down to new record: */
        {   Vm_Int i;
            for (i = MUF_OFF_MAX;   i --> 0; ) sub->slot[i] = sup->slot[i];
	}

	/* Set values in top record which should be new: */
	sup->slot[ MUF_OFF_CONTAINER ]	= sub_muf;
	sup->slot[ MUF_OFF_ASM	     ]	= new_asm;
	sup->slot[ MUF_OFF_FN	     ]  = fn;
	sup->slot[ MUF_OFF_FN_LINE   ]  = sup->slot[ MUF_OFF_LINE ];
	sup->slot[ MUF_OFF_QVARS     ]  = OBJ_FROM_INT( 0);
	sup->slot[ MUF_OFF_ARITY     ]  = OBJ_FROM_INT(-1);
	sup->slot[ MUF_OFF_FORCE     ]  = OBJ_NIL         ;

	/* Remember current top of data stack, so we  */
	/* can detect unbalanced control structures   */
        /* and such (nested control structures are    */
        /* noted on the data stack during compiles):  */
	sup->slot[ MUF_OFF_SP        ] 	= (
	    OBJ_FROM_UNT( job_RunState.s - job_RunState.s_bot )
	);

	/* Remember how many symbols are currently    */
	/* defined, so we can discard symbols private */
	/* to new fn when done compiling it:          */
	sup->slot[ MUF_OFF_SYMBOLS_SP ] = symbolsSp;

	/* Cache current line number for use in a sec:*/
	line    = sup->slot[ MUF_OFF_LINE ];

	vm_Dirty( sub_muf );
	vm_Dirty(     muf );
    }

    /* Set assembler to appropriate line number in fn: */
    ASM_P(new_asm)->line_in_fn = OBJ_FROM_INT(0);
    ASM_P(new_asm)->fn_line    = line; /* Line # in file */
    vm_Dirty(new_asm);

    /* Set FN_NAME and remember start of fn source code: */
    if (is_anonymous) {

	Vm_Unt     end = OBJ_TO_UNT(END);
	vec_Set( muf, MUF_OFF_FN_NAME, OBJ_FROM_CHAR(is_anonymous) );
	vec_Set( muf, MUF_OFF_FN_BEG , OBJ_FROM_UNT(end) );
	vm_Dirty(muf);

    } else {

	/* Read next token (fn name), and handle it: */
	if (!next_token( muf ))  warn(muf,": without fn name on same line");
	{   Vm_Uch buf[ 256 ];
	    if (!copy_token_to_lc_buffer(buf,256,muf)) {
		warn(muf,"Identifier too long");
	    }
	    {   Vm_Obj fn_name = stg_From_Asciz( buf );
		Vm_Unt     end = OBJ_TO_UNT(END)	;
		Vm_Obj sym = (
		    was_global              ?
                    sym_Alloc( fn_name, 0 ) :
                    sym_Make()
                );

		/* Make sure that symbol will look */
		/* like a function to asm_Call():  */
		SYM_P(sym)->function = obj_Etc_Bad; vm_Dirty(sym);

		vec_Set( muf, MUF_OFF_FN_NAME, fn_name );
		vec_Set( muf, MUF_OFF_FN_BEG , OBJ_FROM_UNT(end) );
		vm_Dirty(muf);

		/* Push fn symbol and FN_NAME on symbols stack: */
		symbol_push(muf, fn_name, sym );
    }   }   }

    /* Remember that a ';' is now legal: */
    push_coln();
}

 /***********************************************************************/
 /*-   do_compile_time -- Handle 'compileTime'				*/
 /***********************************************************************/

static void
do_compile_time(
    Vm_Obj   muf,
    Vm_Obj   dummy
) {
    Vm_Obj asm = ASM;
    ASM_P(asm)->compile_time = OBJ_TRUE;
    vm_Dirty(asm);
}

 /***********************************************************************/
 /*-   do_const      -- Compile any sort of constant			*/
 /***********************************************************************/

static void
do_const(
    Vm_Obj   muf,
    Vm_Obj  constant
) {
    /* Deposit a load-constant instruction: */
    asm_Const( ASM, constant );
}

 /***********************************************************************/
 /*-   do_loop_next   -- Compile a  'loop_next'				*/
 /***********************************************************************/

static void
do_loop_next(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Check that 'loopNext' is in a loop: */
    Vm_Int top_loc;
    Vm_Int after_loc;
    if (!find_tag( &top_loc, DEST_TOP )) {
	warn(muf,"'loopNext' must be within a loop.");
    }

    /* Check that 'loopNext' isn't jumping out of*/
    /* an after{ }alwaysDo{ }. (We should allow */
    /* doing so some day, but need to do some    */
    /* work to preserve after{}alwaysDo{} first:*/
    if (find_tag( &after_loc, AFTER )
    &&  after_loc > top_loc
    ){
	warn(muf,"May not 'loopNext' out of after{ }alwaysDo{ }.");
    }

    /* Deposit branch to loop top: */
    asm_Branch( ASM, JOB_OP_BRA, LABEL( OBJ_TO_INT( jS.s[ top_loc ] ) ) );
}

 /***********************************************************************/
 /*-   do_delete     -- Compile a  'delete: <path>'			*/
 /***********************************************************************/

static void
do_delete(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Read next token, which is our variable name: */
    Vm_Uch buf[ 1024 ];
    if (!next_token( muf )) warn(muf,"'delete:' without path on same line");
    if (!copy_token_to_lc_buffer(buf,1024,muf)) {
	warn(muf,"Var name too long");
    }
    if (buf[0] == '\'') {
	compile_path(
	    muf, buf+1, MODE_DEL|MODE_QUOTE
        );
    } else {
	compile_path(
	    muf, buf  , MODE_DEL
	);
    }
}

 /***********************************************************************/
 /*-   do_else       -- Compile an 'else'				*/
 /***********************************************************************/

static void
do_else(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Unt if_id  = pop_orig(   muf );
    Vm_Unt our_id = asm_Label_Get( ASM );
    asm_Branch( ASM, JOB_OP_BRA, our_id );
    asm_Label(  ASM,             if_id  );
    push_orig( our_id );
}

 /***********************************************************************/
 /*-   do_for        -- Compile a  'for'				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-  do_for_token  -- Read next token.				*/
  /**********************************************************************/

static void
do_for_token(
    Vm_Uch*  buf,
    Vm_Int   buflen,
    Vm_Obj   muf
) {
    if (!next_token(muf)
    ||  !copy_token_to_lc_buffer( buf, buflen, muf )
    ){
	warn(muf,"|for without do{ on same line");
    }
}

  /**********************************************************************/
  /*-  do_for_arg -- Decode constant/localvar arg.			*/
  /**********************************************************************/

static Vm_Obj
do_for_arg(		/* Return constant value here.			*/
    Vm_Int*  slot,	/* Return local variable reference here.	*/
    Vm_Obj   muf
) {
    /* Read matching arg: */
    Vm_Obj typ;
    Vm_Uch buf[256];
    do_for_token(buf,256,muf);
    typ = TYP;

    /* Following code is rather redundant */
    /* with assemble_token() code :-/ ... */
    if (!copy_token_to_lc_buffer(buf,256,muf)) {
	warn(muf,"constant too long");
    }

    switch (typ) {

    case MUF_TYPE_ID:
/* buggo, prolly need to add support */
/* for -->constant consts here?      */
	downcase_buffer( buf );
	*slot = lvar_offset_old( muf, buf );
	return OBJ_NOT_FOUND;

    case MUF_TYPE_STR:
	{   Vm_Uch c;
	    Vm_Uch*pc;
	    return stg_From_Buffer(
		buf,
		process_string( &c, &pc, buf, strlen(buf), '"' )
	    );
	}

    case MUF_TYPE_INT:
/* Kuranes reports that Linux atol produces nonsense on overflow here. */
	return OBJ_FROM_INT((Vm_Int) atol(buf));

    case MUF_TYPE_FLT:
/* Kuranes reports that Linux atof produces floating point exception */
/* on overflow here, specifically 1.84e+55 . */
	return OBJ_FROM_FLOAT((Vm_Flt) atof(buf));

    case MUF_TYPE_CHR:
	return OBJ_FROM_CHAR( atoc(muf,buf) );
	break;

    default:
	warn(muf,"unsupported constant type");
    }
    return OBJ_NOT_FOUND; /* Pacify gcc. */
}

 /***********************************************************************/
 /*-   do_for        -- Compile a  'for'				*/
 /***********************************************************************/

static void
do_for(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Full syntax is "for i from 0 upto 1 by 0.1 do{ ... }": */

    /* Read next token, which is our variable name: */
    Vm_Uch varname[ 256 ];
    Vm_Int v_above = -1;
    Vm_Int v_below = -1;
    Vm_Int v_from  = -1;
    Vm_Int v_upto  = -1;
    Vm_Int v_dnto  = -1;
    Vm_Int v_by    = -1;
    Vm_Obj   above = OBJ_NOT_FOUND;
    Vm_Obj   below = OBJ_NOT_FOUND;
    Vm_Obj   from  = OBJ_FROM_INT(0);
    Vm_Obj   upto  = OBJ_NOT_FOUND;
    Vm_Obj   dnto  = OBJ_NOT_FOUND;
    Vm_Obj   by    = OBJ_FROM_INT(1);
    Vm_Int down;
    Vm_Int up;
    Vm_Int skip_limit;
    do_for_token(varname,256,muf);

    /* Parse "from" "upto" "by" sequence, */
    /* which are all optional:            */
    for (;;) {
        Vm_Uch buf[ 256 ];
	do_for_token(buf,256,muf);
	if (STRCMP( "do{"   , == ,buf ))  break;
	if (STRCMP( "from"  , == ,buf )){ from  = do_for_arg( &v_from , muf ); continue; }
	if (STRCMP( "upto"  , == ,buf )){ upto  = do_for_arg( &v_upto , muf ); continue; }
	if (STRCMP( "downto", == ,buf )){ dnto  = do_for_arg( &v_dnto , muf ); continue; }
	if (STRCMP( "by"    , == ,buf )){ by    = do_for_arg( &v_by   , muf ); continue; }
	if (STRCMP( "above" , == ,buf )){ above = do_for_arg( &v_above, muf ); continue; }
	if (STRCMP( "below" , == ,buf )){ below = do_for_arg( &v_below, muf ); continue; }
	warn(muf,"Unrecognized 'for' loop keyword: %s",buf);
    }

    /* Decide whether to stop at or  */
    /* just short of limiting value: */
    skip_limit = (
	above != OBJ_NOT_FOUND   ||   v_above != -1   ||
	below != OBJ_NOT_FOUND   ||   v_below != -1
    );

    /* Increment or decrement? */
    down = (
	v_above != -1  ||  above != OBJ_NOT_FOUND  ||
	v_dnto  != -1  ||  dnto  != OBJ_NOT_FOUND
    );
    up   = (
	v_below != -1  ||  below != OBJ_NOT_FOUND  ||
	v_upto  != -1  ||  upto  != OBJ_NOT_FOUND
    );

    {   /* Create/find our local variable,    */
	/* remember its offset in stackframe: */
	Vm_Int v_var = lvar_offset( muf, varname );

	/* Allocate labels for our loop: */
	Vm_Unt top = asm_Label_Get( ASM );
	Vm_Unt bot = asm_Label_Get( ASM );
	Vm_Unt xit = asm_Label_Get( ASM );



	/* Set initial value in */
	/* our local var slot:  */

	if (v_from != -1)   asm_Var(   ASM, v_from );
	else                asm_Const( ASM,   from );

	if (v_by   != -1)   asm_Var(   ASM, v_by   );
	else                asm_Const( ASM,   by   );

	do_op(         muf, down ? JOB_OP_ADD : JOB_OP_SUB );
	asm_Var_Set(   ASM, v_var );



	/* Generate top of loop: */
	push_dest( top, bot, xit );
	asm_Label( ASM, top      );


	/* Deposit code to de/increment */
	/* loop variable appropriately: */

	asm_Var(       ASM, v_var );

	if (v_by != -1)   asm_Var(   ASM, v_by );
	else              asm_Const( ASM,   by );

	do_op(         muf, down ? JOB_OP_SUB : JOB_OP_ADD );

	asm_Var_Set(   ASM, v_var );

	/* Deposit code to exit when   */
	/* loop var reaches limit var: */
	if (down || up) {
	    asm_Var(       ASM, v_var );
	    if (skip_limit) {
		if      (v_above != -1           )  asm_Var(   ASM, v_above );
		else if (  above != OBJ_NOT_FOUND)  asm_Const( ASM,   above );
		else if (v_below != -1           )  asm_Var(   ASM, v_below );
		else /* (  below != OBJ_NOT_FOUND)*/asm_Const( ASM,   below );
		if (up) do_op( muf, JOB_OP_ALT );
		else    do_op( muf, JOB_OP_AGT );
	    } else {
		if      (v_dnto != -1           )  asm_Var(   ASM, v_dnto );
		else if (  dnto != OBJ_NOT_FOUND)  asm_Const( ASM,   dnto );
		else if (v_upto != -1           )  asm_Var(   ASM, v_upto );
		else /* (  upto != OBJ_NOT_FOUND)*/asm_Const( ASM,   upto );
		if (up) do_op( muf, JOB_OP_ALE );
		else    do_op( muf, JOB_OP_AGE );
	    }
	    asm_Branch(    ASM, JOB_OP_BEQ, xit );
	}
    }
}

 /***********************************************************************/
 /*-   do_foreach   -- Compile a  'foreach'				*/
 /***********************************************************************/

static void
do_foreach(
    Vm_Obj   muf,
    Vm_Unt   propdir
) {
    /* or alternatively "foreach key     do{ ... }"  */
    /* or alternatively "foreach key val do{ ... }", */

    /* Read next token, which is our keyvar name: */
    Vm_Uch keyname[ 256 ];
    Vm_Uch valname[ 256 ];
    Vm_Int nextkey = JOB_OP_PUBLIC_GET_NEXT_KEY; /* Only to quiet compilers. */
    Vm_Int get_val = JOB_OP_PUBLIC_GET_VAL;	 /* Only to quiet compilers. */

    switch (propdir) {

    case OBJ_PROP_SYSTEM:
	nextkey = JOB_OP_SYSTEM_GET_NEXT_KEY;
	get_val = JOB_OP_SYSTEM_GET_VAL;
	break;

    case OBJ_PROP_PUBLIC:
	nextkey = JOB_OP_PUBLIC_GET_NEXT_KEY;
	get_val = JOB_OP_PUBLIC_GET_VAL;
	break;

    case OBJ_PROP_HIDDEN:
	nextkey = JOB_OP_HIDDEN_GET_NEXT_KEY;
	get_val = JOB_OP_HIDDEN_GET_VAL;
	break;

    case OBJ_PROP_ADMINS:
	nextkey = JOB_OP_ADMINS_GET_NEXT_KEY;
	get_val = JOB_OP_ADMINS_GET_VAL;
	break;

#ifdef OLD
    case OBJ_PROP_METHOD:
	nextkey = JOB_OP_METHOD_GET_NEXT_KEY;
	get_val = JOB_OP_METHOD_GET_VAL;
	break;
#endif

    default:
	warn(muf,"muf.c:do_foreach: internal err");
    }

    if (!next_token( muf )) warn(muf,"foreach without varname on same line");
    if (!copy_token_to_lc_buffer(keyname,256,muf)) {
	warn(muf,"Var name too long");
    }

    /* Next token may be optional varname or 'do{': */
    {   Vm_Uch dobrace[ 256 ];
	if (!next_token( muf )
	||  !copy_token_to_lc_buffer(dobrace,256,muf)
	){
	    warn(muf,"foreach without do{ on same line");
    	}
	if (STRCMP( "do{", == ,dobrace )) {
	    valname[0]='\0';
	} else {
	    /* Optional val name has been supplied: */

	    /* Remember val var name: */
	    strcpy(valname,dobrace);

	    /* Eat following 'do{': */
	    if (!next_token( muf )
	    ||  !copy_token_to_lc_buffer(dobrace,256,muf)
	    ||   STRCMP( "do{", != ,dobrace )
	    ){
		warn(muf,"foreach without do{ on same line");
    }   }   }

    {   /* Create/find our key/val variable(s),  */
	/* remember their offsets in stackframe: */
	Vm_Int key_offset =            lvar_offset( muf, keyname )    ;
	Vm_Int val_offset = *valname ? lvar_offset( muf, valname ) : 0;

	/* Create an anonymous local    */
	/* variable to hold target obj: */
	Vm_Int obj_offset = asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','f','0') );

	/* Allocate labels for our loop: */
	Vm_Unt top = asm_Label_Get( ASM );
	Vm_Unt bot = asm_Label_Get( ASM );
	Vm_Unt xit = asm_Label_Get( ASM );

	/* Pop object into its var: */
	asm_Var_Set(   ASM, obj_offset );

	/* Initialize key to minkey: */
	asm_Const(   ASM, OBJ_FIRST  );
	asm_Var_Set( ASM, key_offset );

	/* Generate top of loop: */
	push_dest( top, bot, xit );
	asm_Label( ASM, top      );

	/* Deposit code to find next  */
	/* key in object:             */
	asm_Var(       ASM, obj_offset );
	asm_Var(       ASM, key_offset );
	do_op(         muf, nextkey    );
	asm_Var_Set(   ASM, key_offset );

	/* Deposit code to exit  */
	/* if no keys left:      */
	asm_Branch(    ASM, JOB_OP_BEQ, xit );

	/* Optionally deposit code to set 'val' var: */
	if (*valname) {
	    asm_Var(       ASM, obj_offset            );
	    asm_Var(       ASM, key_offset            );
	    do_op(         muf, get_val               );
	    asm_Var_Set(   ASM, val_offset            );
	}
    }
}

 /***********************************************************************/
 /*-   do_if         -- Compile an 'if'					*/
 /***********************************************************************/

static void
do_if(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Unt orig = asm_Label_Get( ASM );
    asm_Branch( ASM, JOB_OP_BEQ, orig );
    push_orig( orig );
}

 /***********************************************************************/
 /*-   do_lbrk       -- Compile a '['					*/
 /***********************************************************************/

static void
do_lbrk(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    do_op( muf, JOB_OP_START_BLOCK );
    push_lbrk();
}

 /***********************************************************************/
 /*-   do_bar       -- Compile a '|'					*/
 /***********************************************************************/

static void
do_bar(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    pop_lbrk( muf );
    do_op( muf, JOB_OP_END_BLOCK );
}

 /***********************************************************************/
 /*-   do_brke       -- Compile a ']e'					*/
 /***********************************************************************/

static void
do_brke(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    pop_lbrk( muf );
    do_op( muf, JOB_OP_MAKE_EPHEMERAL_LIST );
}

 /***********************************************************************/
 /*-   do_never_inline  -- Compile a 'neverInline'			*/
 /***********************************************************************/

static void
do_never_inline(
    Vm_Obj   muf,
    Vm_Obj   dummy
) {
    Vm_Obj asm = ASM;
    ASM_P(asm)->never_in_line = OBJ_TRUE;
    vm_Dirty(asm);
}
 /***********************************************************************/
 /*-   do_please_inline  -- Compile a 'pleaseInline'			*/
 /***********************************************************************/

static void
do_please_inline(
    Vm_Obj   muf,
    Vm_Obj   dummy
) {
    Vm_Obj asm = ASM;
    ASM_P(asm)->please_in_line = OBJ_TRUE;
    vm_Dirty(asm);
}

 /***********************************************************************/
 /*-   do_case     -- Compile a 'case{'					*/
 /***********************************************************************/

static void
do_case(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Syntax is  "case{ on: val ... on: val ... else: ... }":  */

    {	/* Create an anonymous local */
	/* variable to hold key val: */
	Vm_Int key_offset = asm_Var_Next( ASM, OBJ_FROM_BYT3(' ','c','0') );

	/* Deposit end-of-'with' label on data stack: */
	Vm_Int end_label  = asm_Label_Get( ASM );
	push_orig( end_label );

	/* Deposit dummy end-of-'on:' label on data stack. */
	/* This mildly 'clever' hack depends on the fact   */
        /* that 'asm_Label_Get()' would never issue a 0   */
	/* at this point, since it starts at 0 and we have */
	/* already called it once above:                   */
	push_orig( 0 );

	/* Deposit key_offset on data stack for do_on():   */
	push_case( key_offset );

	/* Pop object into its var: */
	asm_Var_Set(   ASM, key_offset );
    }
}

 /***********************************************************************/
 /*-   do_case_else -- Compile an 'else:'				*/
 /***********************************************************************/

static void
do_case_else(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* We'd (better be!) in a "with k do{ on: tag ... }" statement: */
    Vm_Unt key_offset = pop_case( muf );
    Vm_Unt   this_id  = pop_orig( muf );
    Vm_Unt   case_id  = pop_orig( muf );

    /* If we've seen an 'on:',    */
    /* we need a jump from end of */
    /* previous 'on:' to end of   */
    /* enclosing 'with', followed */
    /* by label used to jump over */
    /* body of the previous 'on:' */
    /* clause:                    */
    if (this_id) {
	asm_Branch( ASM, JOB_OP_BRA, case_id );
	asm_Label(  ASM,             this_id );
    }

    /* Save 'with' state back on data stack: */
    push_orig( case_id    );
    push_orig(   -1       );
    push_case( key_offset );
}

 /***********************************************************************/
 /*-   do_on         -- Compile an 'on:'				*/
 /***********************************************************************/

#undef  MAX_ID
#define MAX_ID 256
static void
do_on(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* We'd (better be!) in a "case{ on: tag ... }" statement: */
    Vm_Unt key_offset = pop_case( muf );
    Vm_Unt   this_id  = pop_orig( muf );
    Vm_Unt   case_id  = pop_orig( muf );
    Vm_Unt   next_id  = asm_Label_Get( ASM );

    /* Error if we've already */
    /* seen an 'else:':       */
    if (this_id == (Vm_Unt)-1) {
	warn(muf,"'default:' must follow all 'on:'s!");
    }

    /* If this isn't first 'on:', */
    /* we need a jump from end of */
    /* previous 'on:' to end of   */
    /* enclosing 'case' followed  */
    /* by label used to jump over */
    /* body of the previous 'on:' */
    /* clause:                    */
    if (this_id) {
	asm_Branch( ASM, JOB_OP_BRA, case_id );
	asm_Label(  ASM,             this_id );
    }

    /* Next token must be a constant.    */
    /* Deposit code to load it on stack: */
    if (!next_token( muf )) warn(muf,"'on:' without constant on same line");
    {   Vm_Obj typ = TYP;
	if (typ == MUF_TYPE_STR) {
	    stg_compile( muf );
	} else {
	    /* Following code is rather redundant with  */
	    /* assemble_token() code :-/ ...		*/
	    Vm_Uch buf[ MAX_ID ];
	    if (!copy_token_to_lc_buffer(buf,MAX_ID,muf)) {
		warn(muf,"'on:' constant too long");
	    }
	    switch (typ) {

	    case MUF_TYPE_INT:
/* Kuranes reports that Linux atol produces nonsense on overflow here. */
	        do_const(muf,OBJ_FROM_INT((Vm_Int) atol(buf)));
		break;
	
	    case MUF_TYPE_FLT:
/* Kuranes reports that Linux atof produces floating point exception */
/* on overflow here, specifically 1.84e+55 . */
		do_const(muf,OBJ_FROM_FLOAT((Vm_Flt) atof(buf)));
		break;

	    case MUF_TYPE_CHR:
		do_const(muf,OBJ_FROM_CHAR( atoc(muf,buf) ));
		break;

	    case MUF_TYPE_QFN:
		if (*buf == '\'') {
		    do_const(muf,
			sym_Alloc_Asciz( JOB_P(jS.job)->package, buf+1, 0 )
		    );
		    break;
		}
		goto unsupported;

	    case MUF_TYPE_ID:
		/* Allow ':keyword': */
		if (*buf == ':') {
		    do_const(muf, sym_Alloc_Asciz_Keyword(buf+1) );
		    break;
		}
		/* Allow constants defined via */
		/* '8 -->constant eight' &tc:  */
		{   Vm_Obj sym = sym_Find_Asciz( JOB_P(jS.job)->package, buf );
		    if (sym && SYM_IS_CONSTANT(sym)) {
			Vm_Obj val = job_Symbol_Value(sym);
			do_const(muf, val );
			break;
		}   }
		goto unsupported;

	    default:
	    unsupported:
		warn(muf,"'on:' unsupported constant type %s",buf);
	    }
        }
    }

    /* Deposit testAndJump comparison of */
    /* on: constant with our which jumps   */
    /* to next on: clause on mismatch:     */
    asm_Var(    ASM, key_offset          );
    do_op(      muf, JOB_OP_AEQ          );
    asm_Branch( ASM, JOB_OP_BEQ, next_id );

    /* Save 'with' state back on data stack: */
    push_orig(   case_id  );
    push_orig(   next_id  );
    push_case( key_offset );
}

 /***********************************************************************/
 /*-   do_incdec     -- Compile a '++' or '--'				*/
 /***********************************************************************/

static void
do_incdec(
    Vm_Obj   muf,
    Vm_Unt   is_plusplus	/* TRUE for ++, FALSE for -- */
) {
    /* Read next token, which is our variable name: */
    Vm_Uch symbol[ 256 ];
    if (!next_token( muf )) {
        if (is_plusplus)  warn(muf,"++ without varname on same line.");
        else              warn(muf,"-- without varname on same line.");
    }
    if (!copy_token_to_lc_buffer(symbol,256,muf)) {
	warn(muf,"Var name too long");
    }

    /****************************************/
    /* Search symbols stack for variable.   */
    /* If found and within local scope,     */
    /* use existing variable, else          */
    /* if found at global scope, use that:  */
    /****************************************/
    {	Vm_Obj val          = symbol_value_local( muf, symbol );
	Vm_Obj typed_offset = OBJ_TO_INT( val );
    /*	Vm_Obj constant     = OBJ_FROM_INT(is_plusplus?1:-1); */
	if (val != OBJ_NOT_FOUND) {
	    if (!OBJ_IS_INT(val) || TYPE( typed_offset ) != LOCAL_VAR) {
		warn(muf,"Can't %s '%s'.", is_plusplus?"++":"--", symbol);
	    }

	    /* Increment a local variable: */
	    {   /* Find offset of local var in our stackframe: */
		Vm_Int offset   = OFFSET( typed_offset );

		asm_Var(    ASM, offset     );	/* Load from local var. */
		/* Deposit code to inc/de-crement: */
		if (is_plusplus)   do_op( muf, JOB_OP_INC );
		else               do_op( muf, JOB_OP_DEC );
		asm_Var_Set(ASM, offset     );	/* Store to local var. */
            }

        } else {

	    /* If symbol is defined in current package, */
	    /* generate a load from it:                 */
	    Vm_Obj sym = sym_Find_Asciz( JOB_P(jS.job)->package, symbol );
	    if (!sym) {
		warn(muf,"%s: no such var '%s'",is_plusplus?"++":"--",symbol);
	    }

	    /* Deposit code to load symbol on stack: */	
	    asm_Const( ASM, sym );
	    /* Deposit code to load from symbol: */
	    do_op( muf, JOB_OP_SYMBOL_VALUE );
	    /* Deposit code to inc/de-crement: */
	    if (is_plusplus)   do_op( muf, JOB_OP_INC );
	    else               do_op( muf, JOB_OP_DEC );
	    /* Deposit code to reload symbol on stack: */	
	    asm_Const( ASM, sym );
	    /* Deposit code to store to symbol: */
	    do_op( muf, JOB_OP_SET_SYMBOL_VALUE );
	}
    }
}

 /***********************************************************************/
 /*-   do_op         -- Compile a generic primitive			*/
 /***********************************************************************/

static void
do_op(
    Vm_Obj   muf,
    Vm_Unt   op
) {
    asm_Nullary( ASM, op );
}

 /***********************************************************************/
 /*-   do_loop_end  -- Compile a '}' ending a loop.			*/
 /***********************************************************************/

static void
do_loop_end(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Unt top = pop( muf, DEST_TOP );
    Vm_Unt bot = pop( muf, DEST_BOT );
    Vm_Unt xit = pop( muf, DEST_XIT );

    asm_Label(  ASM,             bot );
    asm_Branch( ASM, JOB_OP_BRA, top );
    asm_Label(  ASM,             xit );
}

 /***********************************************************************/
 /*-   do_rightbrace -- Compile a  '}'					*/
 /***********************************************************************/

static void
do_rightbrace(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Unt tag;
    for (;;) {
	tag = toptag(muf);

        /* 'expr => sym' construct is implicitly scoped: */
	if (tag == VAR_BIND) {
            pop_var_bind( muf );
	    do_op( muf, JOB_OP_POP_VAR_BINDING );
	    continue;
	}

        /* 'expr =>fn sym' construct is implicitly scoped: */
	if (tag == FUN_BIND) {
            pop_fun_bind( muf );
	    do_op( muf, JOB_OP_POP_FUN_BINDING );
	    continue;
	}

	break;
    }

    switch (tag) {
    case GOTOP:
        {   Vm_Int tag_count = pop_gotop(muf);
	    do_op( muf, JOB_OP_POP_TAGTOPFRAME );
	    while (tag_count --> 0) {
		pop_goto(muf);
		asm_Nullary( ASM, JOB_OP_POP_TAGFRAME );	
		/* buggo:  We don't erase the definitions */
		/* of the tags yet, so they can actually  */
		/* wind up placed outside the do{ ... }   */
		/* scope.  No great harm, but ugly.       */
	    }
	    pop_gobot(muf);
	}
	break;
    case CATCH:    asm_Nullary( ASM, JOB_OP_POP_CATCHFRAME );pop_catch(muf);
                   asm_Label(   ASM, pop_orig( muf )       );	break;
    case ORIG:     asm_Label(   ASM, pop_orig( muf )       );	break;
    case LBRK:	   warn(muf, "Unclosed [ ... |"		   );	break;
    case COLN:	   warn(muf, "Unclosed control structure"  );	break;
    case DEST_TOP: do_loop_end(   muf, 0		   );	break;
    case DEST_VAR: warn(muf, "Loops not implemented yet."  );   break;
    case AFTER :   warn(muf, "Missing }alwaysDo{ ."	   );   break;
    case CASE:
	/* End of "case{ on: 1 ... on: 2 ... default: ... }": */
        {/* Vm_Int key_offset; */
	    Vm_Int next_id;
            Vm_Int case_id;
        /*  key_offset = */ pop_case( muf );
	    next_id    =    pop_orig( muf );
            case_id    =    pop_orig( muf );
	    /*  next_id should be -1 unless we had no 'else:': */
	    if (next_id != -1)  asm_Label(  ASM, next_id   );
	    asm_Label(  ASM, case_id );
	}
	break;

    case ALWAYS:
        asm_Label(   ASM, pop_always( muf )      );
        asm_Nullary( ASM, JOB_OP_POP_UNWINDFRAME );
	break;

    case HANDLERS:
        pop_handlers( muf );
	do_op( muf, JOB_OP_POP_HANDLERSFRAME );
	break;

    case LOCK:
        pop_lock( muf );
	do_op( muf, JOB_OP_POP_LOCKFRAME );
	break;

    case RESTART:
        pop_restart( muf );
	do_op( muf, JOB_OP_POP_RESTARTFRAME );
	break;

    case PRIVS:
        pop_privs( muf );
	do_op( muf, JOB_OP_POP_PRIVS_FRAME );
	break;

    case USER:
        pop_user( muf );
	do_op( muf, JOB_OP_POP_USER_FRAME );
	break;

    default:
        warn(muf,"do_rightbrace: internal error.");
    }
}

 /***********************************************************************/
 /*-   do_semi       -- Compile a ';'					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-  make_source -- Make src string for fn.				*/
  /**********************************************************************/

static Vm_Obj
make_source(
    Vm_Obj muf
) {
    /* Strip any leading/trailing whitespace: */
    Vm_Unt beg       = OBJ_TO_UNT( FN_BEG );
    Vm_Unt end       = OBJ_TO_UNT(    BEG );
    Vm_Unt stg       = STR;
    Vm_Uch c;

    while (             stg_Get_Byte( &c, stg, beg   ) && isspace(c))  ++beg;
    while (end > beg && stg_Get_Byte( &c, stg, end-1 ) && isspace(c))  --end;

    /* Copy desired chunk of source. */
    /* Yes, this is remarkably ugly: */
    {   Vm_Uch buf[ 0x10000 ];
	Vm_Obj beg_save = BEG;
	Vm_Obj end_save = END;
	vec_Set(muf, MUF_OFF_BEG, OBJ_FROM_UNT(beg) );
	vec_Set(muf, MUF_OFF_END, OBJ_FROM_UNT(end) );
	copy_token_to_buffer(buf,0x10000,muf);
	vec_Set(muf, MUF_OFF_BEG, beg_save );
	vec_Set(muf, MUF_OFF_END, end_save );
	return stg_From_Asciz( buf );
    }
}    	

 /***********************************************************************/
 /*-   do_semi       -- Compile a ';'					*/
 /***********************************************************************/

static void
do_semi(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    Vm_Obj str = STR;
    Vm_Obj sym = OBJ_FROM_INT(0);

    /* Error if we're not compiling a function: */
    if (CONTAINER == OBJ_FROM_UNT(0))  warn(muf,"';' doesn't match any ':'.");

    /* Error if we don't match opening ':', due  */
    /* to unterminated 'if' or such:             */
    pop_coln(muf);

    /* Error if data stack sp isn't same as when */
    /* we started.  I think this can only happen */
    /* if user compileTime stuff has been doing */
    /* bad things to the data stack:		 */
    if (job_RunState.s_bot + OBJ_TO_UNT( SP )
    !=  job_RunState.s
    ){
	warn(muf,"Data stack trashed during compile");
    }

    /* Snip out source string for FN: */
    vec_Set(muf, MUF_OFF_STR, make_source( muf ) );

    /* Make executable, slot it and STR into FN: */
    fn_fill( muf );

    {   /* Pop muf stack.  Again, we keep */
	/* the same physical object at top of */
	/* stack, to save our callers from    */
	/* having to update 'muf'.	      */
	Vm_Obj qvars       = OBJ_TO_INT(QVARS);
        Vm_Obj sub_muf     = CONTAINER;
        Vm_Obj fn          = FN;
        Vm_Obj fn_name     = FN_NAME;
	Vm_Obj symbolsSp;
	Vm_Obj container;
	Vm_Obj symbols;
	Vm_Obj line;
	Vm_Obj fn_line;
	Vm_Obj asm;

        {   Vec_P  sub;
            Vec_P  sup;
	    vm_Loc2( (void**)&sup, (void**)&sub, muf, sub_muf );
	    symbols     = sup->slot[ MUF_OFF_SYMBOLS    ];
	    symbolsSp	= sup->slot[ MUF_OFF_SYMBOLS_SP ];
	    line        = sup->slot[ MUF_OFF_LINE       ];
	    container	= sub->slot[ MUF_OFF_CONTAINER  ];
	    fn_line     = sub->slot[ MUF_OFF_FN_LINE    ];
	    asm         = sub->slot[ MUF_OFF_ASM        ];
	    sup->slot[ MUF_OFF_SYMBOLS_SP ] = sub->slot[ MUF_OFF_SYMBOLS_SP ];
	    sup->slot[ MUF_OFF_CONTAINER  ] = sub->slot[ MUF_OFF_CONTAINER  ];
	    sup->slot[ MUF_OFF_ASM        ] = sub->slot[ MUF_OFF_ASM        ];
	    sup->slot[ MUF_OFF_SYMBOLS    ] = sub->slot[ MUF_OFF_SYMBOLS    ];
	    sup->slot[ MUF_OFF_FN_LINE    ] = sub->slot[ MUF_OFF_FN_LINE    ];
	    sup->slot[ MUF_OFF_FN_NAME    ] = sub->slot[ MUF_OFF_FN_NAME    ];
	    sup->slot[ MUF_OFF_FN         ] = sub->slot[ MUF_OFF_FN         ];
	    sup->slot[ MUF_OFF_FN_BEG     ] = sub->slot[ MUF_OFF_FN_BEG     ];
	    sup->slot[ MUF_OFF_QVARS      ] = sub->slot[ MUF_OFF_QVARS      ];
	    sup->slot[ MUF_OFF_SP         ] = sub->slot[ MUF_OFF_SP         ];
	    sup->slot[ MUF_OFF_ARITY      ] = sub->slot[ MUF_OFF_ARITY      ];
	    sup->slot[ MUF_OFF_FORCE      ] = sub->slot[ MUF_OFF_FORCE      ];
	    /*p->slot[ MUF_OFF_LINE       ] = should NOT be copied. :)      */
	    sup->slot[ MUF_OFF_STR        ] = str;
	    vm_Dirty(muf);
	}

	/* Pop any nested symbols off symbol stack.   */
	/* If function is not anonymous, we also want */
	/* to recover its symbol at this point:       */
	if (OBJ_IS_CHAR(fn_name)) {
	    /* Anonymous function: */
	    while (OBJ_TO_INT(stk_Length(symbols)) > OBJ_TO_INT(symbolsSp)) {
		stk_Pull( symbols );
	    }
	} else {
	    Vm_Obj n;
	    /* Named function: */
	    while (OBJ_TO_INT(stk_Length(symbols)) > OBJ_TO_INT(symbolsSp)+2) {
		stk_Pull( symbols );
	    }
	    #if MUQ_IS_PARANOID
	    if (OBJ_TO_INT(stk_Length(symbols)) != OBJ_TO_INT(symbolsSp)+2) {
		MUQ_FATAL("muf.t: do_semi() internal err");
	    }
	    #endif
	    n = stk_Pull( symbols );
	    #if MUQ_IS_PARANOID
	    if (n != fn_name)   MUQ_FATAL("muf.t: do_semi() internal err2");
	    #endif
	    sym = stk_Pull( symbols );
	}

	/* Set assembler to appropriate line number: */
	ASM_P(asm)->line_in_fn = OBJ_FROM_INT(
	    (OBJ_TO_INT(line) - OBJ_TO_INT(fn_line))
	);	
	vm_Dirty(asm);

	/* Save definition of fn if it is */
	/* if named, else generate a load */
	/* instruction for it:            */
	if (!OBJ_IS_CHAR(fn_name)) {
	    if (container != OBJ_FROM_UNT(0)) {
		/* Nested scope, save fn def on locals stack: */
		Vm_Obj cfn = FUN_P(fn)->executable;
		symbol_push(muf, fn_name, cfn );
		/* Update symbol for function.  Even though */
		/* we don't have a global interned symbol,  */
		/* we still need a symbol, for people who   */
		/* generated calls to us via it, before we  */
		/* even -had- a cfn to call directly:       */
		SYM_P(sym)->function = cfn; vm_Dirty(sym);
	    } else {
		/* Outermost scope, save fn def in global symbol: */
		Vm_Obj cfn = FUN_P(fn)->executable;
		{   Sym_P  s   = SYM_P(sym);
		    if (s->function == SYM_CONSTANT_FLAG) {
			warn(muf,"Can't set function slot on constant.");
		    }
		    s->function = cfn;
		    vm_Dirty(sym);
	    }   }
	} else {
	    /* Anonymous fns and thunks need to remember    */
	    /* number of quoted variables for COPY_CFN:     */
	    if (qvars) {
		do_const( muf, OBJ_FROM_INT(2*qvars) );
	    }

	    /* For anonymous fns and thunks, I'm currently  */
	    /* pushing the cfn/thunk rather than the fn,    */
	    /* figuring that stale references to anonymous  */
	    /* fns aren't like to be a significant problem: */
	    do_const( muf, FUN_P(fn)->executable );

	    /* If the anonymous fn or thunk is being used   */
	    /* as a data constructor (via quoted vars) we   */
	    /* need to deposit a runtime instruction to     */
	    /* copy the cfn/thunk and plug the runtime      */
	    /* constant values in:                          */
	    if (qvars) {
		asm_Nullary( ASM, JOB_OP_COPY_CFN );
	    }
	}
    }
}

 /***********************************************************************/
 /*-   do_then       -- Compile a  'then'				*/
 /***********************************************************************/

static void
do_then(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    asm_Label( ASM, pop_orig( muf ) );
}

 /***********************************************************************/
 /*-   do_until      -- Compile an 'until'				*/
 /***********************************************************************/

static void
do_until(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Pop the Dest off: */
    Vm_Unt top = pop( muf, DEST_TOP );
    Vm_Unt bot = pop( muf, DEST_BOT );
    Vm_Unt xit = pop( muf, DEST_XIT );

    /* Deposit conditional exit: */
    asm_Branch( ASM, JOB_OP_BNE, xit );
    
    /* Push the Dest back on: */
    push_dest( top, bot, xit );
}

 /***********************************************************************/
 /*-   do_while      -- Compile a  'while'				*/
 /***********************************************************************/

static void
do_while(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Pop the Dest off: */
    Vm_Unt top = pop( muf, DEST_TOP );
    Vm_Unt bot = pop( muf, DEST_BOT );
    Vm_Unt xit = pop( muf, DEST_XIT );

    /* Deposit conditional exit: */
    asm_Branch( ASM, JOB_OP_BEQ, xit );
    
    /* Push the Dest back on: */
    push_dest( top, bot, xit );
}

 /***********************************************************************/
 /*-   do_funbind    -- Compile a  '=>fn'				*/
 /**********************************************************************/

static void
do_funbind(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Read next token, which is our variable name: */
    Vm_Uch buf[ 256 ];
    if (!next_token( muf )) warn(muf,"=>fn without symbol same line");
    if (!copy_token_to_lc_buffer(buf,256,muf)) {
	warn(muf,"Symbol name too long");
    }

    /* Complain if outside all fn definitions: */
    if (CONTAINER == OBJ_FROM_UNT(0)) {
	warn(muf,"A '=>fn' here makes little sense: Use '-->' instead?");
    }

    /* Check that user isn't doing "exp =>fn 'abc": */
    if (buf[0] == '\'') {
	warn(muf,
	    "Please do   ... =>fn %s   not   ... =>fn '%s",
	    buf, buf
	);
    }

    /* Check that user isn't confusing => with --> */
    /* and trying to assign into a path:           */
    {   Vm_Uch* t = buf;
	int  c;
        for (t = buf;  c = *t;  ++t) {
	    switch (c) {

	    case '$':
	    case '[':   case ']':
	    case ':':	case '.':
		warn(muf,
		    "No '%c's allowed in symbol names. (Did you want '-->'?)",
		    c
		);
    }	}   }

    /* Load the symbol onto the stack: */
    compile_path(
	muf, buf, MODE_GET|MODE_QUOTE
    );

    /* Push a FUN_BIND frame: */
    do_op( muf, JOB_OP_PUSH_FUN_BINDING );

    /* Remember we need to do a POP_FUN_BINDING: */
    push_fun_bind();
}

 /***********************************************************************/
 /*-   do_varbind    -- Compile a  '=>'					*/
 /***********************************************************************/

static void
do_varbind(
    Vm_Obj   muf,
    Vm_Unt   dummy
) {
    /* Read next token, which is our variable name: */
    Vm_Uch buf[ 256 ];
    if (!next_token( muf )) warn(muf,"=> without varname on same line");
    if (!copy_token_to_lc_buffer(buf,256,muf)) {
	warn(muf,"Var name too long");
    }

    /* Complain if outside all fn definitions: */
    if (CONTAINER == OBJ_FROM_UNT(0)) {
	warn(muf,"A '=>' here makes little sense: Use '-->' instead?");
    }

    /* Check that user isn't doing "exp => 'abc": */
    if (buf[0] == '\'') {
	warn(muf,
	    "Please do   ... => %s   not   ... => '%s",
	    buf, buf
	);
    }

    /* Check that user isn't confusing => with --> */
    /* and trying to assign into a path:           */
    {   Vm_Uch* t = buf;
	int  c;
        for (t = buf;  c = *t;  ++t) {
	    switch (c) {

	    case '$':
	    case '[':   case ']':
	    case ':':	case '.':
	
		warn(muf,
		    "No '%c's allowed in symbol names. (Did you want '-->'?)",
		    c
		);
    }	}   }

    /* Load the symbol onto the stack: */
    compile_path(
	muf, buf, MODE_GET|MODE_QUOTE
    );

    /* Push a VAR_BIND frame: */
    do_op( muf, JOB_OP_PUSH_VAR_BINDING );

    /* Remember we need to do a POP_VAR_BINDING: */
    push_var_bind();
}

 /***********************************************************************/
 /*-   is_prim -- Compiles 'symbol' iff it is a hardwired muf primitive.*/
 /***********************************************************************/

static Vm_Int
is_prim(
    Vm_Obj  muf,
    Vm_Uch* symbol,
    Vm_Int  mode	/* MODE_* bitbag.	*/
) {
    /* We currently don't allow 'if and such: */
    if (mode & MODE_QUOTE)  return FALSE;

    /* Check for function in mufprim[]. */
    /* We do this first because it is a */
    /* pain having 13-C-muf-syntax.muf's*/
    /* '-> fn result in '->' compiling  */
    /* as a variable reference:         */
    if (!(mode & MODE_SUBEX) && (mode & MODE_GET)) {
        struct prim_rec * p;
	for (p = &mufprim[0];   p->name;   ++p) {
	    if (STRCMP( symbol, == ,p->name)) {
		if (p->fn != do_op) {
		    (*p->fn)( muf, p->op );
		    return TRUE;
    }	}   }   }


    /* Check for function in /lib/muf: */
    {   Vm_Obj sym = OBJ_GET_ASCIZ( obj_Lib_Muf, symbol, OBJ_PROP_PUBLIC );
	if (sym != OBJ_NOT_FOUND) {
	    Vm_Obj fn;
	    if (!OBJ_IS_SYMBOL(sym)) {
		MUQ_FATAL( "/lib/muf contains nonsymbol!");
	    }
	    fn  = job_Symbol_Function(sym);

	    /* If symbol has a function value set, compile call: */
	    if (!(mode & MODE_SUBEX)
	    &&  !(mode & MODE_FN   )
            && OBJ_IS_CFN(fn)
            ){

		if (CFN_IS_PRIM( CFN_P(fn)->bitbag )) {
		    Vm_Obj op = CFN_P(fn)->vec[0];
		    if (!OBJ_IS_INT(op)) {
			MUQ_FATAL ("muf.c:is_prim: internal err0");
		    }
		    do_op( muf, OBJ_TO_INT( op ) );
		    return TRUE;
		} else {
		    /* For now we ignore the compileTime stuff  */
		    /* that 00-muf.muf sticks in this directory. */
	        }

	    } else {

		if (!(mode & MODE_SUBEX) && (mode & MODE_SET)) {
		    /* Compile a store into symbol: */

		    /* Deposit code to load symbol on stack: */	
		    asm_Const( ASM, sym );

		    /* Deposit code to store into symbol: */
		    if (mode & MODE_FN) {
			do_op(muf, JOB_OP_SET_SYMBOL_FUNCTION);
		    } else if (mode & MODE_CONST) {
			do_op(muf, JOB_OP_SET_SYMBOL_CONSTANT);
		    } else {
			do_op(muf, JOB_OP_SET_SYMBOL_VALUE);
		    }
		    return TRUE;

		} else if (mode & MODE_GET) {

		    if (mode & MODE_FN) {
			asm_Const( ASM, sym );
			do_op(muf, JOB_OP_SYMBOL_FUNCTION);
		    } else if (SYM_IS_CONSTANT(sym)) {
			/* Compile a load of symbol value. */
			/* This is faster than compiling   */
			/* a runtime load from symbol:     */
			do_const( muf, job_Symbol_Value(sym) );
		    } else {
			asm_Const( ASM, sym );
			do_op(muf, JOB_OP_SYMBOL_VALUE);
		    }
		    return TRUE;
		} else if (mode & MODE_DEL) {
		    warn(muf,"\"delete: <prim>\" not supported.");
		} else {
		    warn(muf,"muf.c:is_prim(): internal err1");
    }   }   }   }

    return FALSE;
}

 /***********************************************************************/
 /*-   is_user -- Compiles 'symbol' iff it is user-defined var/word.	*/
 /***********************************************************************/
  /**********************************************************************/
  /*-  is_user_local   -- Compiles 'symbol' iff is local-to-fn.		*/
  /**********************************************************************/

static Vm_Int
is_user_local(
    Vm_Obj  muf,
    Vm_Uch* symbol,
    Vm_Int  mode	/* MODE_* bitbag.	*/
) {
    /* Search symbols stack for symbol: */
    Vm_Int loc;

    /* We currently don't allow 'var of a local: */
    if (mode & MODE_QUOTE)   return FALSE;

    if (stk_Get_Key_P_Asciz( &loc, SYMBOLS, symbol )) {

	/* Found symbol, fetch its value: */
	Vm_Obj value = stk_Get( SYMBOLS, loc-1 );

	/* If symbol value is a fn, */
	/* deposit a call to it:    */
	if (!(mode & MODE_SUBEX)) {

	    /* Two cases here.  If the fn was */
	    /* local and has already been     */
	    /* compiled, we'll have the cfn   */
	    /* here, and can compile a call   */
	    /* directly to it.  Otherwise, we */
	    /* will have a symbol, and will   */
	    /* do an indirect call through it.*/
	    /* Code assembled is exactly the  */
	    /* same in either case, since the */
	    /* call instruction handles both  */
	    /* symbols and cfns anyhow:       */
	    if (OBJ_IS_CFN(    value )
	    ||  OBJ_IS_SYMBOL( value )
	    ){
		asm_Call( ASM, value );
		return TRUE;
	}   }

	/* If 'value' is an integer, it is a variable */
	/* reference:  Compile a load from given var: */
	if (!OBJ_IS_INT( value )) {

	    warn(muf,"is_user_local: internal err");

	} else if ((mode & MODE_SUBEX) || (mode & MODE_GET)) {
	    /* Above check makes sure that we don't */
	    /* let "x --> y" store into local var y */

	    /* Strip object wrapper off int: */
	    Vm_Int typed_offset = OBJ_TO_INT( value );

	    /* 'typed_offset' has both a type field */
	    /* distinguishing types of variables,   */
	    /* and also an offset distinguishing    */
	    /* variables of the same type.  Unpack: */
	    Vm_Int  var_type   = TYPE(   typed_offset );
	    Vm_Int  var_offset = OFFSET( typed_offset );

	    /* Compile appropriate type of variable load: */

	    /* Check that we can 'see' the var, */
	    /* that it's not in an enclosing    */
	    /* scope:                           */
	    Vm_Int base = OBJ_TO_INT( SYMBOLS_SP );
	    if (loc > base) {
		switch (var_type) {

		case LOCAL_VAR:
		    asm_Var(ASM, var_offset );
		    return TRUE;

		case LOCAL_TAG:
		    asm_Label(ASM, var_offset );
		    return TRUE;

		default:
		    warn(muf,"is_user_local.2: internal err");
    }   }   }   }

    return FALSE;
}

  /**********************************************************************/
  /*-  is_user_global  -- Compiles 'symbol' iff is global-to-program.	*/
  /**********************************************************************/

   /*********************************************************************/
   /*- is_user_global_check -- Compile ref to 'val' else return FALSE.	*/
   /*********************************************************************/

static Vm_Int
is_user_global_check(
    Vm_Obj  muf,
    Vm_Obj  sym,
    Vm_Int  mode	/* MODE_* bitbag.	*/
) {
    /* If symbol value is a fn, */
    /* deposit a call to it:	*/
    Vm_Obj fn   = job_Symbol_Function(sym);
    if (!(mode & MODE_SUBEX)
    &&  !(mode & MODE_QUOTE)
    &&  !(mode & MODE_FN)
    &&   (mode & MODE_GET)
    ){
	if (OBJ_IS_OBJ(      fn )
	&&  OBJ_IS_CLASS_FN( fn )
	){
	    fn = FUN_P(fn)->executable;
	}
	if (OBJ_IS_CFN(fn)) {
	    /* The compileTime functions 00-muf.muf defines screw us  */
	    /* up badly -- "-->" breaks us and such.  As a quick hack, */
	    /* ignore compiletime functions: */
	    if (!CFN_IS_COMPILETIME( CFN_P(fn)->bitbag )) {
		asm_Call( ASM, sym );
		return TRUE;
    }   }   }

    if ((mode & MODE_SUBEX) || (mode & MODE_GET)) {

/* buggo, this will likely be so frequent that we */
/* should assign a single SYMGETi bytecode to it: */

	if (SYM_IS_CONSTANT(sym) && !(mode & MODE_QUOTE)) {

	    /* Save an instruction by loading constant */
	    /* value directly at runtime, rather than  */
	    /* indirecting through symbol:		   */
	    asm_Const( ASM, SYM_P(sym)->value );

	} else {

	    /* Deposit code to load symbol on stack: */	
	    asm_Const( ASM, sym );

	    if (!(mode & MODE_SUBEX)
	    &&   (mode & MODE_FN)
	    ){
		/* Deposit code to load function from symbol: */
		do_op( muf, JOB_OP_SYMBOL_FUNCTION );
	    } else if (!(mode & MODE_QUOTE)) {
		/* Deposit code to load value from symbol: */
		do_op( muf, JOB_OP_SYMBOL_VALUE );
	}   }

    } else if (mode & MODE_SET) {

	if (mode & MODE_QUOTE) warn(muf,"Can't do \"exp --> 'sym\"!");

	/* Deposit code to load symbol on stack: */	
	asm_Const( ASM, sym );

	/* Deposit code to store into symbol: */
	if      (mode & MODE_FN   )   do_op(muf, JOB_OP_SET_SYMBOL_FUNCTION );
	else if (mode & MODE_CONST)   do_op(muf, JOB_OP_SET_SYMBOL_CONSTANT );
	else                          do_op(muf, JOB_OP_SET_SYMBOL_VALUE    );

    } else if (mode & MODE_DEL) {
	warn(muf,"\"delete: <symbol>\" not supported.");
    } else {

	warn(muf,"muf.c:is_user_global_check() internal err");
    }

    return TRUE;
}

   /*********************************************************************/
   /*- is_user_global  -- Compiles 'symbol' iff is global-to-program.	*/
   /*********************************************************************/

static Vm_Int
is_user_global(
    Vm_Obj  muf,
    Vm_Uch* symbol,
    Vm_Int  mode	/* MODE_* bitbag.	*/
) {
    /* NOTE:  If you change the sequence of packages */
    /* searched by this fn, please also update       */
    /* sym_Alloc() and sym_Alloc_Asciz().            */

    /* If symbol is defined in our    */
    /* current package, use that def: */
    Vm_Obj pkg = JOB_P(jS.job)->package;
    if (!OBJ_IS_OBJ(pkg) || !OBJ_IS_CLASS_PKG(pkg))  return FALSE;

    /* Here's an ugly specialCase hack for ']' */
    /* which is a normal user fn except for     */
    /* having to match '['.                     */
    if (symbol[0]==']' && !symbol[1]
    && !(mode & MODE_QUOTE)	/* Don't fire on   '] export   */
    ){
	pop_lbrk( muf );
    }

    {   Vm_Obj sym = sym_Find_Asciz( pkg, symbol );
	if (sym)   return is_user_global_check( muf, sym, mode );
    }

    /* Do a final hardwired search of /lib/muf.   */
    /* This isn't logically necessary, but avoids */
    /* users getting hung up with no packages     */
    /* selected and no way to select one (say):   */
    if (OBJ_IS_OBJ(      obj_Lib_Muf)
    &&  OBJ_IS_CLASS_PKG(obj_Lib_Muf)
    ){
	Vm_Obj sym = sym_Find_Exported_Asciz( obj_Lib_Muf, symbol );
	if (sym	&& is_user_global_check( muf, sym, mode)) {
	    return TRUE;
    }	}

    return FALSE;
}



#ifdef OLD
static Vm_Int
is_user(
    Vm_Obj  muf,
    Vm_Uch* symbol,
    Vm_Int  mode	/* MODE_* bitbag.	*/
) {
    if (is_user_local(  muf, symbol, mode ))  return TRUE;
    if (is_user_global( muf, symbol, mode ))  return TRUE;
    return FALSE;
}
#endif

 /***********************************************************************/
 /*-   compile_path -- Compile load/store from symbol or path.		*/
 /***********************************************************************/

  /**********************************************************************/
  /*-  is_number -- Maybe compile a number				*/
  /**********************************************************************/

static Vm_Int
is_number(
    Vm_Obj  muf,
    Vm_Uch* buf
) {
    /* This is a weakie substitute for */
    /* doing serious recognition of    */
    /* full syntax for numbers:        */
    Vm_Int seen_decimal   = FALSE;
    Vm_Int seen_digit     = FALSE;
    Vm_Uch*p    = buf;
    Vm_Uch c    = '\0';
    Vm_Uch last = '\0';
    for (;;) {
	last = (last=='\\' ? '\0' : c);

	if (!(c=*p++))   break;

	if (c == '.'   && last != '\\')   seen_decimal = TRUE;
	if (isdigit(c) && last != '\\')   seen_digit   = TRUE;

	if (!isxdigit(c)
	&&  c != '-'
	&&  c != '+'
	&&  c != '.'
	||  last=='\\'
	){
	    return FALSE;
	}
    }
    if (last == '+'  /* Silly hack to keep '1+' op from being a number. */
    ||  last == '-'  /* Silly hack to keep '1-' op from being a number. */
    || !seen_digit   /* Silly hack to keep '.'  op from being a number. */
    ){	
	return FALSE;
    }

    /* Okie, call it a number: */
    if (!seen_decimal) {
	do_const(muf,OBJ_FROM_INT((Vm_Int)   atol(buf)));
    } else if (last == 'D' || last == 'd') {
	warn(muf,"Double-precision floats not supported yet.");
    } else {
	do_const(muf,OBJ_FROM_FLOAT((Vm_Flt) atof(buf)));
    }
    return TRUE;
}

  /**********************************************************************/
  /*-  is_string -- Maybe compile a string				*/
  /**********************************************************************/

static Vm_Int
is_string(
    Vm_Obj  muf,
    Vm_Uch* buf
) {
    Vm_Uch*p     = buf;
    Vm_Uch c     = '\0';
    Vm_Uch last;
    for (;;) {
	last = c;

	if (!(c=*p++))   break;
    }
    if (last != '"') {
	return FALSE;
    }

    /* Okie, call it a string: */
    {   Vm_Uch c;
        Vm_Uch*pc;
        Vm_Int len    = process_string(&c,&pc,buf,strlen(buf),'"');
        Vm_Obj string = stg_From_Buffer( buf, len );
        do_const(muf, string);
    }
    return TRUE;
}

  /**********************************************************************/
  /*-  end_of_prefix -- Search for next !\ed '$' '[' '.' or '\0'	*/
  /**********************************************************************/

static Vm_Uch*
end_of_prefix(
    Vm_Uch* buf,
    Vm_Uch  last_char
) {
    Vm_Uch c    = '\0';
    Vm_Uch last = last_char;  /* Don't trust parameters to be efficient. */
    for (;;) {
	c    = *buf++;
	if (c == '\0'
	|| (c == '$'   &&   last != '\\')
	|| (c == '['   &&   last != '\\'   &&   *buf != '\0')
	|| (c == '.'   &&   last != '\\')
	){
	    return buf-1;
	}
	last = (last=='\\' ? '\0' : c);
    }
}

  /**********************************************************************/
  /*-  look_up_prefix -- Compile x or x:y or x::y			*/
  /**********************************************************************/

  /**********************************************************************/
  /*-  end_of_package_name -- Search for next !\ed ':'			*/
  /**********************************************************************/

static Vm_Uch*
end_of_package_name(
    Vm_Uch* buf
) {
    Vm_Uch c    = '\0';
    Vm_Uch last = '\0';
    while (*buf) {
	last = (last=='\\' ? '\0' : c);
	c    = *buf++;
	/* We're looking for 'pkg:symbol' or 'pkg::symbol'.  */
	/* For the benefit of words like : :: on: default:   */
	/* and so forth, we ignore any colons ending symbol: */
	if (c      == ':'
        &&  last   != '\\'		      /* Ignore \: in a symbol      */
        &&  buf[0] != '\0'		      /* Ignore :  at end of symbol */
        && (buf[0] != ':' || buf[1] != '\0')  /* Ignore :: at end of symbol */
        ){
	    return buf-1;
	}
    }
    return NULL;
}

  /**********************************************************************/
  /*-  strip_backslashes -- Remove one layer of \s			*/
  /**********************************************************************/

#ifdef OLD
static Vm_Uch*
strip_backslashes(
    Vm_Uch*  buf
) {
    Vm_Uch*  cat = buf;
    Vm_Uch*  rat = buf;
    while (*rat) {
	if ((*cat = *rat++) == '\\')   *cat = *rat++;
	++cat;
    }
    return cat;
}
#endif

  /**********************************************************************/
  /*-  find_package_symbol -- TRUE iff of a:b or a::b form.		*/
  /**********************************************************************/

   /*********************************************************************/
   /*- find_package_symbol2 -- Do package ref given package.		*/
   /*********************************************************************/

Vm_Obj
find_package_symbol2(
    Vm_Uch* buf,
    Vm_Obj  pkg
){
    /* If we had a::b instead of a:b */
    /* then we are searching for an  */
    /* internal not external symbol: */
    Vm_Int internal_sym = (buf[0] == ':');
    Vm_Uch* buf2    = internal_sym ? buf+1 : buf;
    Vm_Uch  c;
    Vm_Uch* pc;
    process_string(&c,&pc,buf2,strlen(buf2), MUF_NO_DELIM);

    {   Vm_Obj  result  = (
	    internal_sym                         ?
	    sym_Find_Asciz(          pkg, buf2 ) :
	    sym_Find_Exported_Asciz( pkg, buf2 )
	);
	*pc = c;
	return result;
    }
}

  /**********************************************************************/
  /*-  find_package_symbol -- TRUE iff of a:b or a::b form.		*/
  /**********************************************************************/

   /*********************************************************************/
   /*- muf_Find_Package_Asciz -- Find named package.			*/
   /*********************************************************************/

    /********************************************************************/
    /*-muf_Find_Package -- Find named package.				*/
    /********************************************************************/

#ifndef MUF_FIND_PACKAGE_BUFSIZE
#define MUF_FIND_PACKAGE_BUFSIZE 4096
#endif

Vm_Obj
muf_Find_Package(
    Vm_Obj name
){
    Vm_Uch buf[MUF_FIND_PACKAGE_BUFSIZE];
    Vm_Unt u = stg_Get_Bytes( buf, MUF_FIND_PACKAGE_BUFSIZE, name, 0 );
    if (u-(unsigned)1 > (unsigned)(MUF_FIND_PACKAGE_BUFSIZE-6)) {
	MUQ_WARN("Bad package name length: %d", (int)u );
    }
    buf[u] = '\0';
    return muf_Find_Package_Asciz( buf );
}

    /********************************************************************/
    /*-muf_find_package_in_lib -- Find named package.			*/
    /********************************************************************/

static Vm_Obj
muf_find_package_in_lib(
    Vm_Obj  lib,
    Vm_Uch* name
){
    /* Over all packages in @$s.lib: */
    Vm_Obj key;
    for(key  = OBJ_NEXT(lib,OBJ_FIRST,OBJ_PROP_PUBLIC);
	key != OBJ_NOT_FOUND;
	key  = OBJ_NEXT(lib,key,OBJ_PROP_PUBLIC)
    ){
	/* Find the key's value: */
	Vm_Obj pkg = OBJ_GET( lib, key, OBJ_PROP_PUBLIC );

	/* We're only interested in packages: */
	if (OBJ_IS_OBJ(      pkg)
	&&  OBJ_IS_CLASS_PKG(pkg)
	){
	    /* Check the name of the package: */
	    Vm_Obj pkg_name ;
	    Vm_Obj nicknames;
	    {   Pkg_P p   = PKG_P(pkg);
		pkg_name  = p->o.objname;
		nicknames = p->nicknames;
	    }

	    if (!obj_StrNeql( name, pkg_name ))   return pkg;

	    /* Check all nicknames of package: */
	    if (OBJ_IS_OBJ(nicknames)) {
		Vm_Obj key;
		for(key  = OBJ_NEXT(nicknames,OBJ_FIRST,OBJ_PROP_PUBLIC);
		    key != OBJ_NOT_FOUND;
		    key  = OBJ_NEXT( nicknames,key,OBJ_PROP_PUBLIC)
		){
		    if (!obj_StrNeql( name, key ))   return pkg;
    }   }   }   }

    return (Vm_Obj)FALSE;
}

    /********************************************************************/
    /*-muf_Find_Package_Asciz -- Find named package.			*/
    /********************************************************************/

Vm_Obj
muf_Find_Package_Asciz(
    Vm_Uch* name
){
    /* Locate @$s.lib, which gives all 'known' packages: */
    Vm_Obj pkg;
    Vm_Obj lib = JOB_P(job_RunState.job)->lib;
    if (!OBJ_IS_OBJ(lib)) {
	MUQ_WARN("@$s.lib isn't an object?!");
    }

    if (pkg = muf_find_package_in_lib(    lib, name))   return pkg;
    if (pkg = muf_find_package_in_lib(obj_Lib, name))   return pkg;

    return (Vm_Obj)FALSE;
}

   /*********************************************************************/
   /*- find_package_symbol -- TRUE iff of a:b or a::b form.		*/
   /*********************************************************************/



static Vm_Obj
find_package_symbol(
    Vm_Obj  muf,
    Vm_Uch* buf
){
    /* Check for !\ !initial : or ::      */
    Vm_Uch* colon   = end_of_package_name( buf );

    if (!colon)   return FALSE;

    if (*colon != ':')   warn(muf,"muf.c: look_up_prefix: internal err");

    /* Special case for keywords: */
    if (colon == buf)   return sym_Alloc_Asciz_Keyword( colon+1 );

    *colon = '\0';

    /* Locate package with given name: */
    {   Vm_Uch c;
        Vm_Uch*pc;
        process_string(&c,&pc,buf,strlen(buf), MUF_NO_DELIM);

        /* Find package with given name/nickname: */
        {   Vm_Obj pkg = muf_Find_Package_Asciz( buf );
	    if    (pkg) {
	        Vm_Obj sym = find_package_symbol2( colon+1, pkg );
	        if (!sym) warn(muf,"No such symbol: %s:%s",buf,colon+1);
		*pc = c;
	        return sym;
    }	}   }

    warn(muf,"No package '%s' in @$s.lib!", buf );

    return FALSE;	/* Just to quiet compilers. */
}

static Vm_Int
do_package_symbol(
    Vm_Obj  muf,
    Vm_Uch* buf,
    Vm_Int  mode	/* MODE_* bitbag.	*/
) {
    /* Special case for '#': */
/*buggo, this will be broken right now*/
    if (buf[0] == '#'
    &&  buf[1] == ':'
    ){
	/* Create and return uninterned symbol: */
	Vm_Obj name = stg_From_Asciz( buf+2 );
	Vm_Obj sym  = sym_Make();
        {   Sym_P s = SYM_P(sym);
	    s->name = name;
	    vm_Dirty(sym);
        }

	if (!is_user_global_check( muf, sym, mode|MODE_QUOTE )) {
	    warn(muf,"muf.c:look_up_prefix:internal err");
	}

	return TRUE;
    }

    {   Vm_Obj sym = find_package_symbol( muf, buf );
	if (!sym)   return FALSE;
	if (!is_user_global_check( muf, sym, mode )) {
	    warn(muf,"muf.c:look_up_prefix:internal err");
    }	}
    return TRUE;
}

static void
look_up_prefix(
    Vm_Obj  muf,
    Vm_Uch* buf,
    Vm_Int  mode	/* MODE_* bitbag.	*/
) {


    /* Delegate handling of a:b and a::b constructions:  */
    if (do_package_symbol(muf,buf,mode)) return;

    {   /* Remove one layer of \s: */
	Vm_Uch c;
	Vm_Uch*pc;
        process_string(&c,&pc,buf,strlen(buf), MUF_NO_DELIM);

	/************************************/
	/* Look up appropriately, ignoring  */
	/* mufprims[] and fn possibilities  */
	/* if remaining string is nonempty. */
	/*				    */
	/* We used to search prims first    */
	/* because it was a pain having     */
	/* '-->' be a user variable when    */
	/* compiling 05-C-mufcompile.muf.   */
	/*				    */
	/* But I got sick of having         */
	/*  12 -> job  job                  */
	/* interpret the second job as the  */
	/* prim instead of the local var,   */
	/* so I put is_user() first again.  */
	/*				    */
	/* Unfortunately, this left no way  */
	/* for x-lispread to use muf prims  */
	/* like 'if' while also including   */
	/* the lisp package (which has an   */
	/* 'if' of its own), so I finally   */
	/* settled on searching user locals */
	/* first, then prims, then user     */
	/* globals:                         */
	/************************************/
	if (is_user_local(muf,buf,mode)) {
	    *pc = c;
            return;
	}
	if (is_prim( muf, buf, mode )) {
	    *pc = c;
            return;
	}
	if (is_user_global(muf,buf,mode)) {
	    *pc = c;
            return;
	}

	/* If this is a "--> x", create x */
        /* and do an assignment into it:  */
	if (!(mode & MODE_SUBEX) && (mode & MODE_SET)) {
	    /* Deposit a store-to-symbol, creating  */
	    /* symbol in current package if it does */
	    /* not already exist:                   */

	    /* Deposit code to load symbol on stack: */	
	    asm_Const( ASM, sym_Alloc_Asciz( JOB_P(jS.job)->package, buf, 0 ));

	    /* Deposit code to store to symbol: */
	    if      (mode & MODE_FN   )do_op(muf, JOB_OP_SET_SYMBOL_FUNCTION );
	    else if (mode & MODE_CONST)do_op(muf, JOB_OP_SET_SYMBOL_CONSTANT );
	    else                       do_op(muf, JOB_OP_SET_SYMBOL_VALUE    );

	    *pc = c;
	    return;
	}

	/* If this is a "'x", create x:  */
	if (!(mode & MODE_SUBEX) && (mode & MODE_GET) && (mode & MODE_QUOTE)) {

	    /* Deposit code to load symbol on stack: */	
	    asm_Const( ASM, sym_Alloc_Asciz( JOB_P(jS.job)->package, buf, 0 ));
	    *pc = c;
	    return;
	}

	warn(muf,"Undefined identifier: '%s'", buf );
    }
}

  /**********************************************************************/
  /*-  end_of_subexpression -- Search for next matching !\ed '>'	*/
  /**********************************************************************/

static Vm_Uch*
end_of_subexpression(
    Vm_Uch* buf
) {
    Vm_Uch c = '\0';
    Vm_Uch last;
    Vm_Int depth = 1;
    for (;;) {
	last = c;
	c    = *buf++;
	if (!c)   return NULL;
	if (c == '['   &&   last != '\\'   &&   *buf != '\0')   ++depth;
	if (c == ']'   &&   last != '\\'   &&   last != '\0')   --depth;
	if (!depth)   return buf-1;
    }
}

  /**********************************************************************/
  /*-  compile_path -- Compile load/store from symbol or path.		*/
  /**********************************************************************/
static void
compile_path(
    Vm_Obj  muf,
    Vm_Uch* buf,
    Vm_Int  mode	/* MODE_* bitbag.	*/
) {
    /*************************************************************/
    /* Things we can have here:                                  */
    /* --------------------------------------------------------- */
    /*  prim:     hardwired control structure in mufprims[].     */
    /*  local:    function or local-var offset on SYMBOLS stack. */
    /*  global:   internal symbol in current package. (fn | var) */
    /*  global:   external symbol in 'used'  package. (fn | var) */
    /*  global:   :-qualified external package ref.   (fn | var) */
    /*  global:  ::-qualified internal package ref.   (fn | var) */
    /*  path:     {any var above|~|@|.|}/id                      */
    /*  path:     {any var above|~|@|.|/}[id]                    */
    /* --------------------------------------------------------- */
    /* mufprim[] prims we dispatch to associated C function;     */
    /* Any function, we compile as prim or call, as appropriate; */
    /* Any pathless constant var value, we compile immediate ld; */
    /* Any pathless variable var value, we compile symbol load;  */
    /* Any var with /id, we resolve as getVal with constant key.*/
    /* Any var with [id] we resolve as getVal with variable key.*/
    /*************************************************************/

    /**************************************/
    /* Basic algorithm:                   */
    /* ================                   */
    /*                                    */
    /*look_up_prefix:                     */
    /* Check for !\ !initial : or ::      */
    /* Remove one layer of \s             */
    /* Look up appropriately, ignoring    */
    /*   mufprims[] and fn possibilities  */
    /*   if remaining string is nonempty. */
    /* Generate code to put value on stack*/
    /*                                    */
    /*compile_path:                       */
    /* Special-case int & float consts    */
    /* Special-case leading / @/ ~/ ./    */
    /* Otherwise find first $ [ . <eostr> */
    /* Look_up_prefix.                    */
    /* while !<eostr> {                   */
    /*   set prop to PUBLIC               */
    /*   if $ {                           */
    /*     Find next [ . <eostr>          */
    /*     set prop to HIDDEN/ADMINS/etc  */
    /*     according to whether inter-    */
    /*     vening chars are a prefix of   */
    /*     "hidden"/"admins"...           */
    /*     (error if not prefix of one)   */
    /*     step to the [ . <eostr>.       */
    /*   }                                */
    /*   if [ {                           */
    /*     scan to matching !\ ]          */
    /*     compile substring recursively  */
    /*     step past the ]                */
    /*   } else if . {                    */
    /*     scan to next !\ . [ <eostr>    */
    /*     compile const-load of string   */
    /*     step TO next !\ . [ <eostr>    */
    /*   }                                */
    /*   compile get-`prop`-value         */
    /* }                                  */
    /**************************************/
    
    Vm_Int need_root = FALSE;

    /* If buf is a number, compile an appropriate load-constant: */
    if (isdigit(*buf) && is_number(muf,buf))   return;
    if (*buf=='-'     && is_number(muf,buf))   return;
    if (*buf=='.'     && is_number(muf,buf))   return;
    if (*buf=='"'     && is_string(muf,buf))   return;
    /* BUGGO.  Should support all constants here: */
    /* "abc" 'a' 'a                               */

    /* If buf has one of the magic prefixes */
    /*     @. ~. 			    */
    /*    $ @$ ~$ .$                        */
    /* compile an appropriate load-constant */
    /* and eat the prefix:                  */
    if (buf[0] == '.' 
    ||  buf[0] == '$'
    ){
	do_op( muf, JOB_OP_ROOT);
        if      (buf[1] == '\0')   return;
    } else if   (buf[1] == '\0'){
	if      (buf[0] == '@' ){ do_op( muf, JOB_OP_JOB        ); return; }
/*	else if (buf[0] == '~' ){ do_op( muf, JOB_OP_ACTING_USER); return; } */
	else {			  need_root = TRUE;			   }
    } else if   (buf[1] == '.' || buf[1] == '$' || buf[1] == '['){
	if      (buf[0] == '@' ){ do_op( muf, JOB_OP_JOB        );  ++buf; }
/*	else if (buf[0] == '~' ){ do_op( muf, JOB_OP_ACTING_USER);  ++buf; } */
	else {			  need_root = TRUE;			   }
    } else if   (buf[0] == 'm' && buf[1] == 'e' &&
        (buf[2] == '\0' || buf[2] == '.' || buf[2] == '[' || buf[2] == '$')
    ){
	do_op( muf, JOB_OP_ACTING_USER);
        buf += 2;
    } else {
	need_root = TRUE;
    }

    /* If buf didn't have a leading / @/ ~/ ./   */
    /* then it starts s/ or p:s/ or such, and    */
    /* we need to find symbol 's' and compile    */
    /* a load from it:                           */
    if (need_root) {
	Vm_Uch* xend = end_of_prefix( buf+1, *buf );
	Vm_Uch  c    = *xend;
	*xend        = '\0';
	if (c) look_up_prefix( muf, buf,(mode&~MODE_SET)|MODE_GET|MODE_SUBEX);
	else   look_up_prefix( muf, buf, mode                               );
	*xend        = c;
	buf	     = xend;
    }

    /* Now we loop over all the noninitial parts */
    /* of the path.  These differ from the	 */
    /* initial part in that un[]ed parts are     */
    /* treated as keyword constants rather than  */
    /* variable names:                           */
    while (*buf) {

	/* Figure out whether we are about to read */
	/* the public, hidden, admins, system, or  */
	/* method part of the object.  We do this  */
	/* by assuming PUBLIC unless prefix is one */
	/* of $h[idden] $s[system]...              */
	Vm_Int get_val = JOB_OP_PUBLIC_GET_VAL;
	Vm_Int set_val = JOB_OP_PUBLIC_SET_VAL;
	Vm_Int del_val = JOB_OP_PUBLIC_DEL_KEY;
	if (buf[0] == '$') {
	    Vm_Uch *key = "public"; /* Just to quiet compilers. */
	    switch (buf[1]) {
	    case 'a': case 'A':
		key = "admins";
		get_val = JOB_OP_ADMINS_GET_VAL;
		set_val = JOB_OP_ADMINS_SET_VAL;
		del_val = JOB_OP_ADMINS_DEL_KEY;
		break;
	    case 'h': case 'H':
		key = "hidden";
		get_val = JOB_OP_HIDDEN_GET_VAL;
		set_val = JOB_OP_HIDDEN_SET_VAL;
		del_val = JOB_OP_HIDDEN_DEL_KEY;
		break;
#ifdef OLD
	    case 'm': case 'M':
		key = "method";
		get_val = JOB_OP_METHOD_GET_VAL;
		set_val = JOB_OP_METHOD_SET_VAL;
		del_val = JOB_OP_METHOD_DEL_KEY;
		break;
#endif
	    case 'p': case 'P':
		key = "public";
		get_val = JOB_OP_PUBLIC_GET_VAL;
		set_val = JOB_OP_PUBLIC_SET_VAL;
		del_val = JOB_OP_PUBLIC_DEL_KEY;
		break;
	    case 's': case 'S':
		key = "system";
		get_val = JOB_OP_SYSTEM_GET_VAL;
		set_val = JOB_OP_SYSTEM_SET_VAL;
		del_val = JOB_OP_SYSTEM_DEL_KEY;
		break;
	    default:
		warn(muf,"muf.c:compile_path: bad $ field '%s'",buf);
	    }
	    {   Vm_Int i;
		++buf;
		for (i = 0;   i < 6;  ++i) {
		    if (!isalpha(buf[i]))  break;
#ifdef CASE_INSENSITIVE
		    if (tolower(buf[i]) != key[i]) {
#else
		    if (        buf[i]  != key[i]) {
#endif
			warn(muf,"muf.c:compile_path: bad $ field '%s'",buf-1);
		}   }
		buf += i;
	}   }

	/* We're now compiling either  */
        /* a /xxx or a [xxx] pathpart: */
	if (*buf == '[') {

	    /* Locate matching ']': */
	    Vm_Uch* new_end = end_of_subexpression( buf+1 );
	    Vm_Uch  c;
	    if (!new_end) warn(muf,"Unmatched '[': %s", buf );

	    /* Compile subexpression recursively: */
	    c        = *new_end;
	    *new_end = '\0';
	    compile_path( muf, buf+1, MODE_GET );
	    *new_end = c;
	    buf      = new_end+1;

	} else {

	    /* Find end of /xxx component: */
	    Vm_Uch* new_end = end_of_prefix( buf+1, *buf );
	    Vm_Uch  c       = *new_end;
	    if (*buf != '.') {
                warn(muf,"muf.c:compile_path: invalid path");
	    }

	    /* Compile load-constant of xxx string: */
	    *new_end        = '\0';
	    do_const( muf, sym_Alloc_Asciz_Keyword( buf+1 ) );
	    *new_end        = c;
	    buf             = new_end;
	}

	/* We now have a key on the stack,  */
	/* on top of the object it indexes. */
	/* Wrap up by compiling a getVal   */
	/* from appropriate area of object: */
	if     ((mode & MODE_GET) || *buf)   do_op( muf, get_val );
	else if (mode & MODE_SET)            do_op( muf, set_val );
	else if (mode & MODE_DEL)            do_op( muf, del_val );
	else warn(muf,"muf.c:compile_path");
    }
}

/************************************************************************/
/*-    process_string -- Convert \n \0 etc, return final len		*/
/************************************************************************/

static Vm_Int
process_string(
    Vm_Uch* pc,
    Vm_Uch**ppc,
    Vm_Uch* buf,
    Vm_Unt  len,
    Vm_Int  delim	/* '  or " or MUF_NO_DELIM  */
) {
    Vm_Int   chars_dropped = 0;

    /* Strip off first and last '"' chars, */
    /* plus expand \n etc correctly:       */
    {   Vm_Uch* cat = buf;
        Vm_Uch* rat = buf;
        if (*rat == delim) {
	     /* Step over opening '"' */
	    ++rat;
	    --len;
	    ++chars_dropped;
	}
	while (len --> 0) {	
	    Vm_Uch c = *rat++;
	    if (c != '\\') {
		*cat++ = c;
	    } else {
		--len;
		++chars_dropped;
		switch (c = *rat++) {
		case '0':  *cat++ = '\0';	break;
		case 'a':  *cat++ = '\a';	break;
		case 'b':  *cat++ = '\b';	break;
		case 'e':  *cat++ = '\033';	break;
		case 'f':  *cat++ = '\f';	break;
		case 'n':  *cat++ = '\n';	break;
		case 'r':  *cat++ = '\r';	break;
		case 't':  *cat++ = '\t';	break;
		case 'v':  *cat++ = '\v';	break;
		default:   *cat++ =   c ;	break;
		}
	    }	
	}

	/* Drop final delimiter on strings and char constants: */
	if (rat > buf+1  &&  rat[-1] == delim) {
	    ++chars_dropped;
	}

	/* Compute final length: */
	rat -= chars_dropped;
	len  = rat - buf;

	/* Drop a null at end, since we do  */
	/* tend to make asciz calls on buf: */
	*ppc =  rat;
	*pc  = *rat;
	*rat = '\0';
    }
    return len;
}

/************************************************************************/
/*-    stg_compile -- Compile reference to string.			*/
/************************************************************************/

static void
stg_compile(
    Vm_Obj muf
) {
    /* Copy string into buffer where it is */
    /* easier to  work with.  This puts an */
    /* ugly finite limit on strings; Need  */
    /* to come back and find something a   */
    /* bit nicer here someday:             */
    Vm_Uch   buf[ MUF_MAX_STR ];
    Vm_Int   len;
    if (!(len = copy_token_to_buffer(buf,MUF_MAX_STR,muf))) {
	warn(muf,"String const too long");
    }

    /* Strip off first and last '"' chars, */
    /* plus expand \n etc correctly:       */
    {   Vm_Uch c;
        Vm_Uch*pc;
	len = process_string( &c, &pc, buf, len, '"' );

	/* Create a stg instance,  */
	/* deposit a load-constant */
	/* instruction for it:     */
	do_const(muf,stg_From_Buffer( buf, len ));

	*pc = c;	/* Probably not needed.	*/
    }
}



#undef  MAX_ID
#define MAX_ID 256
static void
assemble_token(
    Vm_Obj   muf
) {
/*  Vm_Int     got_const    = FALSE;	  */
/*  Vm_Int     got_stack_op = FALSE;	  */
/*  Vm_Unt     stack_op;		  */
/*  Vm_Unt     beg = OBJ_TO_UNT(BEG)	; */
/*  Vm_Unt     end = OBJ_TO_UNT(END)	; */
/*  Vm_Obj     stg = STR		; */
    Vm_Obj     typ = TYP		;

    switch (typ) {

    case MUF_TYPE_STR:
	stg_compile( muf );
	return;

    case MUF_TYPE_HQ:
    case MUF_TYPE_QFN:
    case MUF_TYPE_FLT:
    case MUF_TYPE_INT:
    case MUF_TYPE_ID :
    case MUF_TYPE_CHR:
	{   Vm_Uch buf[ MAX_ID ];
	    if (!copy_token_to_lc_buffer(buf,MAX_ID,muf)) {
		warn(muf,"Token too long");
	    }
	    switch (typ) {

	    case MUF_TYPE_INT:
		do_const(muf,OBJ_FROM_INT((Vm_Int)   atol(buf)));
		return;

	    case MUF_TYPE_FLT:
		do_const(muf,OBJ_FROM_FLOAT((Vm_Flt) atof(buf)));
		return;

	    case MUF_TYPE_QFN:
		compile_path(
		    muf, buf+1, MODE_GET|MODE_QUOTE
		);
		return;

	    case MUF_TYPE_HQ:
		compile_path(
		    muf, buf+2, MODE_GET|MODE_FN
		);
		return;

	    case MUF_TYPE_ID:
		compile_path(
		    muf, buf  , MODE_GET
		);
		return;

	    case MUF_TYPE_CHR:
		do_const(muf,OBJ_FROM_CHAR( atoc(muf,buf) ));
		return;
	    }
	}
	break;

    default:
	warn(muf,"Bad token type");
    }
}
#undef MAX_ID


/************************************************************************/
/*-    fn_fill -- Slot source, bytecodes and constants into our fn.	*/
/************************************************************************/

static void
fn_fill(
    Vm_Obj   muf
) {
    /* Find fn proper: */
    Vm_Obj fn         = FN;
    Vm_Obj asm        = ASM;

    /* Find source code for fn: */
    Vm_Obj stg        = STR;

    /* Build actual executable: */
    Vm_Obj fn_name = FN_NAME;
    /* Plug source into fn: */
    if (stg_Is_Stg(fn_name)) {
        Fun_P  p          = FUN_P(fn);
	p->source         = stg;
	p->o.objname      = fn_name;
	vm_Dirty(fn);
    } else {
        Fun_P  p          = FUN_P(fn);
	p->source         = stg;
	vm_Dirty(fn);
    }
    switch (fn_name) {
    case OBJ_FROM_CHAR('p'):
	ASM_P(asm)->flavor = job_Kw_Promise;
	vm_Dirty(asm);
	break;
    case OBJ_FROM_CHAR('t'):
	ASM_P(asm)->flavor = job_Kw_Thunk;
	vm_Dirty(asm);
	break;
    default:
	;
    }
    asm_Cfn_Build( asm, fn, ARITY, FORCE!=OBJ_NIL );
 
    #ifdef USEFUL_WHEN_DEBUGGING
    {   Vm_Uch buf[8192];
	fun_Sprint(buf,buf+8192,fn);
        fprintf(stdout,
	    "\nfn_fill: Compiled fn %" VM_X " (arity %x exe %x): %s",
	    fn,
	    (int)FUN_P(fn)->arity,
	    (int)FUN_P(fn)->executable,
	    buf
	);
    }
    #endif
}

/************************************************************************/
/*-    lvar_offset_old -- Return offset of local var, never creating it.*/
/************************************************************************/

static Vm_Int
lvar_offset_old(
    Vm_Obj   muf,
    Vm_Uch*  varname
) {
    /****************************************/
    /* Search symbols stack for variable.   */
    /* If found and within local scope,     */
    /* use existing variable, else          */
    /* create a new var by that name:  	    */
    /****************************************/
    Vm_Obj val          = symbol_value_local( muf, varname );
    Vm_Obj typed_offset = OBJ_TO_INT( val );
    if (val == OBJ_NOT_FOUND) {
	warn(muf,"No local variable '%s'.",varname);
    }
    if (!OBJ_IS_INT(val)
    ||  TYPE( typed_offset ) != LOCAL_VAR
    ){
	warn(muf,"Can't redefine '%s'.",varname);
    }
    return OFFSET( typed_offset );
}

/************************************************************************/
/*-    lvar_offset -- Return offset of local var, creating if need be.	*/
/************************************************************************/

static Vm_Int
lvar_offset(
    Vm_Obj   muf,
    Vm_Uch*  varname
) {
    /****************************************/
    /* Search symbols stack for variable.   */
    /* If found and within local scope,     */
    /* use existing variable, else          */
    /* else create a new var by that name:  */
    /****************************************/
    Vm_Obj val          = symbol_value_local( muf, varname );
    Vm_Obj typed_offset = OBJ_TO_INT( val );
    Vm_Int offset;
    if (val != OBJ_NOT_FOUND) {
	if (!OBJ_IS_INT(val)
	||  TYPE( typed_offset ) != LOCAL_VAR
	){
	    warn(muf,"Can't redefine '%s'.",varname);
	}
	offset = OFFSET( typed_offset );

    } else {

	/* Create and assign to local variable: */
	offset = asm_Var_Next( ASM, stg_From_Asciz(varname) );
	symbol_push(
	    muf,
	    stg_From_Asciz( varname ),
	    OBJ_FROM_INT(   TYPED_OFFSET( LOCAL_VAR, offset )   )
	);
    }
    return offset;
}

/************************************************************************/
/*-    next_token -- Find next token in stg.				*/
/************************************************************************/

 /***********************************************************************/
 /*-   skip_whitespace							*/
 /***********************************************************************/

static Vm_Int
skip_whitespace(
    struct next_token_state * p
) {
    Vm_Obj stg = p->stg;
    Vm_Unt u   = OBJ_TO_UNT( p->beg );
    Vm_Uch c;

    /* Skip leading whitespace: */
    p->lin = p->lot;
    do {
	if (!stg_Get_Byte( &c, stg, u++ )) {
	    p->end = OBJ_FROM_UNT(--u);
	    p->beg = OBJ_FROM_UNT(--u);
	    return FALSE;
	}
	if (c=='\n') {
	    p->lot = OBJ_FROM_INT( OBJ_TO_INT(p->lot)+1 );
	}
    } while (isspace(c));

    p->beg = OBJ_FROM_UNT(--u);
    p->end = OBJ_FROM_UNT(  u);

    return TRUE;
}

 /***********************************************************************/
 /*-   skip_comment							*/
 /***********************************************************************/

static Vm_Int
skip_comment(
    struct next_token_state * p
) {
    Vm_Obj stg = p->stg;
    Vm_Unt u   = OBJ_TO_UNT( p->beg );
    Vm_Uch last_c;
    Vm_Uch c   = '(';
    Vm_Int lot = OBJ_TO_INT( p->lot );
    p->lin     = p->lot;

    /* Skip leading comment: */
    do {
	last_c = c;
	if (!stg_Get_Byte( &c, stg, ++u ))   warn(p->muf,"Unclosed comment");
	if (c=='\n')   ++lot;
    } while (c != ')' || !isspace(last_c));

    p->beg = OBJ_FROM_UNT(u  );
    p->end = OBJ_FROM_UNT(u+1);
    p->typ = MUF_TYPE_CMT   ;
    p->lot = OBJ_FROM_INT( lot );

    return TRUE;
}

 /***********************************************************************/
 /*-   scan_string							*/
 /***********************************************************************/

static Vm_Int
scan_string(
    struct next_token_state * p
) {
    Vm_Obj stg = p->stg;
    Vm_Unt u   = OBJ_TO_UNT( p->beg );
    Vm_Uch c   = '"';
    Vm_Uch last= '\0';
    Vm_Int lot = OBJ_TO_INT( p->lot );
    p->lin     = p->lot;
    do {
	last = (last=='\\' ? '\0' : c);
	if (!stg_Get_Byte( &c, stg, ++u ))   warn(p->muf,"Unclosed string");
	if (c=='\n')   ++lot;
    } while (c != '"' || last == '\\');

    p->end = OBJ_FROM_UNT(u+1);
    p->typ = MUF_TYPE_STR     ;
    p->lot = OBJ_FROM_INT( lot );

    return TRUE;
}

 /***********************************************************************/
 /*-   scan_char							*/
 /***********************************************************************/

static Vm_Int
scan_char(
    struct next_token_state * p
) {
    Vm_Obj stg = p->stg;
    Vm_Unt u   = OBJ_TO_UNT( p->beg );
    Vm_Uch c   = '\'';
    Vm_Uch last= '\0';
    Vm_Int len = 0;

    /* This one is a bit amusing.  Trying for compatability with */
    /* multiple traditions, we want to allow all of:             */
    /*   ' '    character constant				 */
    /*   'a'    character constant				 */
    /*   '\n'   character constant				 */
    /*   'a     quoted reference to symbol named a.              */
    /* We used to allow ': for anonymous fns, too :).		 */
    for (;;) {
	last = (last=='\\' ? '\0' : c);
	if (!stg_Get_Byte( &c, stg, ++u ))  break;
	if (last != '\\') {
            if (c == '\'' || (isspace(c)&&len))    break;
            ++len;	  /* The '&&len' above handles ' '.	 */
	}
    }

    if (c != '\'')   --u;	/* Don't include final blank/missingchar */
    p->end = OBJ_FROM_UNT(u+1);

    if      (c=='\'')               p->typ = MUF_TYPE_CHR;
    else                            p->typ = MUF_TYPE_QFN;

    return TRUE;
}

 /***********************************************************************/
 /*-   scan_number							*/
 /***********************************************************************/

static Vm_Int
scan_number(
    struct next_token_state * p
) {
    Vm_Obj stg = p->stg;
    Vm_Unt u   = OBJ_TO_UNT( p->beg );
    Vm_Uch c		  = '\0';	/* So 'last' gets initialized. */
    Vm_Uch last		  = '\0';
    Vm_Int seen_decimal   = FALSE;
    Vm_Int seen_digit     = FALSE;
    Vm_Int seen_forbidden = FALSE;

    for (;;) {
	last = (last=='\\' ? '\0' : c);

	if (!stg_Get_Byte( &c, stg, u++ ))   break;
        if (isspace(c) && last != '\\')      break;

	if (c == '.'   && last != '\\')  seen_decimal = TRUE;
	if (isdigit(c) && last != '\\')  seen_digit   = TRUE;

        if (!isxdigit(c)
	&&  c != '-'
	&&  c != '+'
	&&  c != '.'
	||  last == '\\'
	){
	    seen_forbidden = TRUE;
	}
    }

    p->end = OBJ_FROM_UNT(--u);

    /* We'll treat invalid numberish things as  */
    /* identifiers, else we'll be simpleminded:	*/
    /* Anything without a '.' is an int;	*/
    /* Anything else without a 'D'/'d' is flt;	*/
    /* Anything else is double.			*/
    /* The 'D' isn't C-compatible, but we want	*/
    /* folks defaulting to float, not double:	*/
    {   Vm_Obj typ;

	/* First test is mostly for "1+" and "1-" ops: */
	if      (last == '-' || last == '+'   )   typ = MUF_TYPE_ID ;
	else if (!seen_digit || seen_forbidden)   typ = MUF_TYPE_ID ;
	else if (!seen_decimal                )   typ = MUF_TYPE_INT;
	else if (last == 'D' || last == 'd'   )   typ = MUF_TYPE_DBL;
	else                                      typ = MUF_TYPE_FLT;

        p->typ = typ;
    }

    return TRUE;
}

 /***********************************************************************/
 /*-   scan_id								*/
 /***********************************************************************/

static Vm_Int
scan_id(
    struct next_token_state * p
) {
    Vm_Obj stg = p->stg;
    Vm_Unt u0  = OBJ_TO_UNT( p->beg );
    Vm_Unt u   = u0;

    Vm_Uch c0;
    Vm_Uch c   = '\0';
    Vm_Int last= '\0';
    if (!stg_Get_Byte( &c0, stg, u ))   return FALSE;

    do {
	last = (last=='\\' ? '\0' : c);
	if (!stg_Get_Byte( &c, stg, u++ ))   break;
    } while (!isspace(c) || last=='\\');

    /* Check for '(', start-of-comment id: */
    if (u-u0 == 2 && c0=='(') 	return skip_comment(p);

    p->end = OBJ_FROM_UNT(--u);
    p->typ = MUF_TYPE_ID      ;

    return TRUE;
}

 /***********************************************************************/
 /*-   scan_sharp							*/
 /***********************************************************************/

static Vm_Int
scan_sharp(
    struct next_token_state * p
) {
    Vm_Obj stg = p->stg;
    Vm_Unt u0  = OBJ_TO_UNT( p->beg );
    Vm_Unt u   = u0;

    Vm_Uch c0;
    Vm_Uch c1;
    Vm_Uch c    = '\0';
    Vm_Uch last = '\0';
    Vm_Int lot  = OBJ_TO_INT( p->lin );
    p->lin      = p->lot;
    if (!stg_Get_Byte( &c0, stg, u++ ))   return FALSE;
    if (!stg_Get_Byte( &c1, stg, u   )) {
	/* As part of making "# " a  */
        /* comment-to-end-of-line,   */
	/* allow "#" at end of line: */
	p->beg = OBJ_FROM_UNT(u  );
	p->end = OBJ_FROM_UNT(u+1);
	p->typ = MUF_TYPE_CMT   ;
	return TRUE;
    }

    /* Commonlisp classifies symbols starting */
    /* with # according to their second char: */
    switch (c1) {

    case '\'':
	do {
	    last = (last=='\\' ? '\0' : c);
	    if (!stg_Get_Byte( &c, stg, u++ ))   break;
	} while (!isspace(c) || last=='\\');
	p->end = OBJ_FROM_UNT(--u);
	p->typ = MUF_TYPE_HQ      ;
	return TRUE;

    case '\n':
    case ' ':
	/* Commonlisp defines "# " as signalling an error, */
	/* but we use it as a comment-to-end-of-line:      */

	/* Skip leading comment: */
	for (;;) {
	    if (!stg_Get_Byte( &c, stg, u++ ))   break;
	    if (c=='\n') { ++lot; break; }
	}

	p->beg = OBJ_FROM_UNT(u-1);
	p->end = OBJ_FROM_UNT(u  );
	p->typ = MUF_TYPE_CMT   ;
	p->lot = OBJ_FROM_INT( lot );

	return TRUE;
	

    default:
        warn(p->muf,"Unsupported syntax: #%c.",(int)c1);
    }
    return FALSE;
}

 /***********************************************************************/
 /*-   next_token2 -- 							*/
 /***********************************************************************/

static Vm_Int
next_token2(
    struct next_token_state * p
) {
    Vm_Obj  stg = p->stg;
    Vm_Uch  c;

    p->beg = p->end;

    /* Over all tokens until we hit nonspace noncomment: */
    for (;;) {
	Vm_Int result;

	/* Skip to something nonboring: */
	if (!skip_whitespace( p ))    return FALSE;

	/* Figure type and length of token: */
	if (!stg_Get_Byte( &c, stg, OBJ_TO_UNT(p->beg) ))   return FALSE;
	if      (c == '#')    result = scan_sharp(  p );
	else if (c == '"')    result = scan_string( p );
	else if (c == '\'')   result =  scan_char(  p );
	else if (isdigit(c)
	||  c == '+'
	||  c == '-'
	||  c == '.'
	){
	                      result = scan_number( p );
	} else {
	                      result = scan_id(     p );
	}
	/* Return unless it was a comment: */
	if (p->typ != MUF_TYPE_CMT)   return result;

	/* Start next loop at end of comment: */
	p->beg = p->end;
    }
}

 /***********************************************************************/
 /*-   next_token -- Find next token in stg.				*/
 /***********************************************************************/

static Vm_Int
next_token(
    Vm_Obj   muf
) {
    Vm_Obj lin = LINE;
    struct next_token_state p;

    /* Package up the state we need: */
    p.stg = STR;
    p.beg = BEG;
    p.end = END;
    p.typ = TYP;	/* Just to have it initialized. */
    p.lin = lin;
    p.lot = lin;
    p.muf = muf;

    {   /* Make someone else do all the work: */
	Vm_Int result = next_token2( &p );

	/* Return possibly changed parts of state: */
	vec_Set(muf, MUF_OFF_BEG, p.beg );
	vec_Set(muf, MUF_OFF_END, p.end );
	vec_Set(muf, MUF_OFF_TYP, p.typ );

	if (p.lot != lin) {
	    Vm_Obj asm     = ASM;
	    Vm_Int fn_line = FN_LINE;

	    /* Set assembler to appropriate line number: */
	    ASM_P(asm)->line_in_fn = OBJ_FROM_INT(
		(OBJ_TO_INT(p.lin) - OBJ_TO_INT(fn_line))
	    );
	    vm_Dirty(asm);

	    vec_Set(muf, MUF_OFF_LINE, p.lot );
	}

	return result;
    }
}

/************************************************************************/
/*-    nesting   -- Count number of nested structures open.		*/
/************************************************************************/

static Vm_Int
nesting(
    Vm_Obj muf
) {
    Vm_Obj*  s = job_RunState.s;
    Vm_Obj*  b = job_RunState.s_bot + OBJ_TO_UNT( SP );
    Vm_Int   n = 0;
    for (;   s > b;   --s) {

        if (job_Type0[*s&0xFF] == JOB_TYPE_i) {

	    switch (TAG(OBJ_FROM_INT(*s))) {
	    case COLN:
	    case ORIG:
	    case DEST_TOP:
		++n;
		break;
    }   }   }
    return n;
}

/************************************************************************/
/*-    find_tag -- Find offset of given tag in data stack.		*/
/************************************************************************/

static Vm_Int
find_tag(
    Vm_Int* loc,	/* Location of entry found, in [-INF,0]	*/
    Vm_Unt  desired_tag
) {
    /* Various sanity checks: */
    register Vm_Obj* s = jS.s;
    register Vm_Int  i = s - jS.s_bot;

    for ( ;   i --> 0;   --s) {
	register Vm_Unt v = OBJ_TO_UNT(*s);
	if (TAG(v) == desired_tag) {
	    *loc = s - jS.s;
	    return TRUE;
    }   }

    /* Not found: */
    return FALSE;
}

/************************************************************************/
/*-    pop -- Pop tagged label, check that tag is correct, return label.*/
/************************************************************************/

static Vm_Unt
pop(
    Vm_Obj muf,
    Vm_Unt desired_tag
) {
    /* Various sanity checks: */
    for (;;) {
	Vm_Unt bot = OBJ_TO_UNT( SP );
	Vm_Unt sp  = job_RunState.s - job_RunState.s_bot;
	Vm_Unt tag = TAG(  OBJ_TO_INT( *job_RunState.s ) );
	Vm_Unt lbl = LABEL(OBJ_TO_INT( *job_RunState.s ) );

	/* Check for nothing available on stack: */
	if (sp <= bot) {
	    warn(muf,"No match for closing control structure");
	}

	/* Check for something completely senseless pushed on stack: */
	if (job_Type0[*job_RunState.s&0xFF] != JOB_TYPE_i
	|| !TAG_IS_VALID(tag)
	){
	    warn(muf,"Junk pushed on data stack during compilation");
	}

	/* Check for something reasonable but unwanted on stack: */
	if (tag == desired_tag) {

	    /* Return label stripped of tagbits: */
	    --job_RunState.s;
	    return lbl;
	}

	/* Check for VAR_BIND, which is implicitly scoped: */
	if (tag == VAR_BIND) {
	    do_op( muf, JOB_OP_POP_VAR_BINDING );
	    --job_RunState.s;
	    continue;
	}

	/* Check for FUN_BIND, which is implicitly scoped: */
	if (tag == FUN_BIND) {
	    do_op( muf, JOB_OP_POP_FUN_BINDING );
	    --job_RunState.s;
	    continue;
	}

        warn(muf,"Mismatched control structure");
    }
}

/************************************************************************/
/*-    pop_after  -- Pop a label id for an after{    off data stack.	*/
/************************************************************************/

static Vm_Unt
pop_after(
    Vm_Obj muf
) {
    return pop( muf, AFTER );
}

/************************************************************************/
/*-    pop_always -- Pop a label id for an alwaysDo off data stack.	*/
/************************************************************************/

static Vm_Unt
pop_always(
    Vm_Obj muf
) {
    return pop( muf, ALWAYS );
}

/************************************************************************/
/*-    pop_catch  -- Pop a label id for a catch{ off stack.		*/
/************************************************************************/

static void
pop_catch(
    Vm_Obj muf
) {
    pop( muf, CATCH );
}

/************************************************************************/
/*-    pop_goto -- Pop a label id for a tag{ off stack.			*/
/************************************************************************/

static void
pop_goto(
    Vm_Obj muf
) {
    pop( muf, GOTO );
}

/************************************************************************/
/*-    pop_gotop -- Pop a label id for a tag{ off stack.		*/
/************************************************************************/

static Vm_Unt
pop_gotop(
    Vm_Obj muf
) {
    return pop( muf, GOTOP );
}

/************************************************************************/
/*-    pop_gobot -- Pop a label id for a tag{ off stack.		*/
/************************************************************************/

static void
pop_gobot(
    Vm_Obj muf
) {
    pop( muf, GOBOT );
}

/************************************************************************/
/*-    pop_coln   -- Pop a fn-start marker          off data stack.	*/
/************************************************************************/

static void
pop_coln(
    Vm_Obj muf
) {
    /* Vm_Unt top = */ pop( muf, COLN );
}


#ifdef UNUSED_HMM

/************************************************************************/
/*-    pop_dest   -- Pop a label id                  off data stack.	*/
/************************************************************************/

static Vm_Unt
pop_dest(
    Vm_Obj muf
) {
    Vm_Unt top = pop( muf, DEST_TOP );
    Vm_Unt bot = pop( muf, DEST_BOT );
    Vm_Unt xit = pop( muf, DEST_XIT );
    return top;
}

#endif

/************************************************************************/
/*-    pop_handlers -- Pop a HANLDERS at end of ]withHandlersDo{ ... }*/
/************************************************************************/

static void
pop_handlers(
    Vm_Obj muf
) {
    pop( muf, HANDLERS );
}

/************************************************************************/
/*-    pop_lbrk   -- Pop a marker for [ ... | scope.			*/
/************************************************************************/

static void
pop_lbrk(
    Vm_Obj muf
) {
    pop( muf, LBRK );
}

/************************************************************************/
/*-    pop_lock -- Pop a LOCK at end of withLockDo{ ... } construct.	*/
/************************************************************************/

static void
pop_lock(
    Vm_Obj muf
) {
    pop( muf, LOCK );
}

/************************************************************************/
/*-    pop_restart -- Pop a RESTART at end of withRestartDo{ ... }	*/
/************************************************************************/

static void
pop_restart(
    Vm_Obj muf
) {
    pop( muf, RESTART );
}

/************************************************************************/
/*-    pop_privs -- Pop a PRIVS at end of omnipotently-do{ ... }.	*/
/************************************************************************/

static void
pop_privs(
    Vm_Obj muf
) {
    pop( muf, PRIVS );
}

/************************************************************************/
/*-    pop_user -- Pop a USER at end of asMeDo{ ... } construct.	*/
/************************************************************************/

static void
pop_user(
    Vm_Obj muf
) {
    pop( muf, USER );
}

/************************************************************************/
/*-    pop_fun_bind  -- Pop a =>fn binding marker       off data stack.	*/
/************************************************************************/

static void
pop_fun_bind(
    Vm_Obj muf
) {
    /* Vm_Unt top = */ pop( muf, FUN_BIND );
}

/************************************************************************/
/*-    pop_var_bind  -- Pop a => binding marker        off data stack.	*/
/************************************************************************/

static void
pop_var_bind(
    Vm_Obj muf
) {
    /* Vm_Unt top = */ pop( muf, VAR_BIND );
}

/************************************************************************/
/*-    pop_orig   -- Pop a label id used by a branch off data stack.	*/
/************************************************************************/

static Vm_Unt
pop_orig(
    Vm_Obj muf
) {
    return pop( muf, ORIG );
}

/************************************************************************/
/*-    pop_case -- Pop a var offset used by a 'case' off data stack.	*/
/************************************************************************/

static Vm_Unt
pop_case(
    Vm_Obj muf
) {
    return pop( muf, CASE );
}

/************************************************************************/
/*-    push_after -- Push label id used by an after  onto data stack.	*/
/************************************************************************/

static void
push_after(
    Vm_Unt orig
) {
    push( AFTER, orig );
}

/************************************************************************/
/*-    push_always-- Push label id used by an always onto data stack.	*/
/************************************************************************/

static void
push_always(
    Vm_Unt orig
) {
    push( ALWAYS, orig );
}

/************************************************************************/
/*-    push_dest  -- Push label id                   onto data stack.	*/
/************************************************************************/

static void
push(
    Vm_Unt tag,
    Vm_Unt label
) {
    /* Push label id with an added orig/dest opcode: */
    job_Guarantee_Headroom( 1 );
    ++job_RunState.s;
   *job_RunState.s = OBJ_FROM_INT(TAGGED_LABEL(tag,label));
}

static void
push_dest(
    Vm_Unt top,
    Vm_Unt bot,
    Vm_Unt xit
) {
    /* We push so 'top' winds up on top, and 'xit' on bottom: */
    push( DEST_XIT, xit );
    push( DEST_BOT, bot );
    push( DEST_TOP, top );
}

/************************************************************************/
/*-    push_handlers -- Pushed to mark a ]withHandlersDo{...} scope.	*/
/************************************************************************/

static void
push_handlers(
    void
) {
    push( HANDLERS, 0 );
}

/************************************************************************/
/*-    push_orig  -- Push label id used by a branch  onto data stack.	*/
/************************************************************************/

static void
push_orig(
    Vm_Unt orig
) {
    push( ORIG, orig );
}

/************************************************************************/
/*-    push_lbrk  -- Push marker for [ ... | scope.			*/
/************************************************************************/

static void
push_lbrk( void ) {
    push( LBRK, 0 );
}

/************************************************************************/
/*-    push_lock  -- Pushed to mark a withLockDo{...} scope.		*/
/************************************************************************/

static void
push_lock(
    void
) {
    push( LOCK, 0 );
}

/************************************************************************/
/*-    push_restart  -- Pushed to mark a withRestartDo{...} scope.	*/
/************************************************************************/

static void
push_restart(
    void
) {
    push( RESTART, 0 );
}

/************************************************************************/
/*-    push_privs -- Pushed to mark a omnipotently-do{...} scope.	*/
/************************************************************************/

static void
push_privs(
    void
) {
    push( PRIVS, 0 );
}

/************************************************************************/
/*-    push_user  -- Pushed to mark a asMeDo{...} scope.		*/
/************************************************************************/

static void
push_user(
    void
) {
    push( USER, 0 );
}

/************************************************************************/
/*-    push_case -- Push var offset used by a 'case{' onto data stack.	*/
/************************************************************************/

static void
push_case(
    Vm_Unt Case
) {
    push( CASE, Case );
}

/************************************************************************/
/*-    push_catch -- Push label id for a catch{ on data stack.		*/
/************************************************************************/

static void
push_catch(
    void
) {
    push( CATCH, 0 );
}

/************************************************************************/
/*-    push_goto -- Push label id for a tag{ on data stack.		*/
/************************************************************************/

static void
push_goto(
    void
) {
    push( GOTO, 0 );
}

/************************************************************************/
/*-    push_gotop -- Push label id for a tag{ on data stack.		*/
/************************************************************************/

static void
push_gotop(
    Vm_Unt id
) {
    push( GOTOP, id );
}

/************************************************************************/
/*-    push_gobot -- Push label id for a tag{ on data stack.		*/
/************************************************************************/

static void
push_gobot(
    void
) {
    push( GOBOT, 0 );
}

/************************************************************************/
/*-    push_coln  -- Push start-of-fn marker onto data stack.		*/
/************************************************************************/

static void
push_coln(
    void
) {
    push( COLN, 0 );
}

/************************************************************************/
/*-    push_fun_bind -- Pushed to mark a exp =>fn symbol scope.		*/
/************************************************************************/

static void
push_fun_bind(
    void
) {
    push( FUN_BIND, 0 );
}

/************************************************************************/
/*-    push_var_bind -- Pushed to mark a exp => symbol scope.		*/
/************************************************************************/

static void
push_var_bind(
    void
) {
    push( VAR_BIND, 0 );
}

/************************************************************************/
/*-    symbol_push -- Push symbol and value on symbols stack.		*/
/************************************************************************/

static void
symbol_push(
    Vm_Obj muf,
    Vm_Obj symbol,
    Vm_Obj value
) {
    /* Push  'symbol' and 'value' on symbols stack: */
    Vm_Obj    symbols= SYMBOLS  ;
    stk_Push( symbols, value   );
    stk_Push( symbols, symbol  );
}

/************************************************************************/
/*-    symbol_value -- Get symbol val or OBJ_NOT_FOUND.			*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static Vm_Obj
symbol_value(
    Vm_Obj  muf,
    Vm_Uch* symbol
) {
    /* Search symbols stack for symbol: */
    Vm_Unt loc;
    if (stk_Get_Key_P_Asciz( &loc, SYMBOLS, symbol )) {

	/* Found symbol, return its value: */
	return stk_Get( SYMBOLS, loc-1 );
    }
    return OBJ_NOT_FOUND;
}
#endif

/************************************************************************/
/*-    symbol_value_local -- Get intra-fn symbol val or OBJ_NOT_FOUND.	*/
/************************************************************************/

static Vm_Obj
symbol_value_local(
    Vm_Obj  muf,
    Vm_Uch* symbol
) {
    /* Search symbols stack for symbol: */
    Vm_Int loc;
    if (stk_Get_Key_P_Asciz( &loc, SYMBOLS, symbol )) {

	/* Return it iff it's in current fn: */
	Vm_Int base = OBJ_TO_INT( SYMBOLS_SP );
	if (loc > base)   return stk_Get( SYMBOLS, loc-1 );
    }
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    toptag -- Return type of top stack entry.			*/
/************************************************************************/

static Vm_Unt
toptag(
    Vm_Obj muf
) {
    /* Various sanity checks: */

    Vm_Unt bot = OBJ_TO_UNT( SP );
    Vm_Unt sp  = job_RunState.s - job_RunState.s_bot;
    Vm_Unt tag = TAG(  OBJ_TO_INT( *job_RunState.s ) );
/*  Vm_Unt lbl = LABEL(OBJ_TO_INT( *job_RunState.s ) ); */

    /* Check for nothing available on stack: */
    if (sp <= bot)   warn(muf,"No match for closing control structure");

    /* Check for something unknown pushed on stack,   */
    /* presumably by user-implemented control structs */
    /* or such:                                       */
    if (job_Type0[*job_RunState.s&0xFF] != JOB_TYPE_i
    || !TAG_IS_VALID(tag)
    ){
	return 0;
    }

    return tag;
}

/************************************************************************/
/*-    warn -- Issue error message.					*/
/************************************************************************/

#ifndef MUF_MAX_WARN
#define MUF_MAX_WARN 2048
#endif

static void
warn(
    Vm_Obj  muf,
    Vm_Uch *format,
    ...
) {
    va_list args;
    Vm_Uch buf1[MUF_MAX_WARN];
    Vm_Uch buf2[MUF_MAX_WARN];
    buf1[0] = '\0';

    /* We first deposit whatever identifying information */
    /* we have about the source code location of the     */
    /* error, then we append the error message proper:   */

    {   Vec_P v = VEC_P(muf);
	if (OBJ_IS_INT( v->slot[MUF_OFF_LINE])
	&&  OBJ_TO_INT( v->slot[MUF_OFF_LINE]) > 0
	){
	    sprintf( buf2, "Line %d: ", (int)(OBJ_TO_INT(v->slot[MUF_OFF_LINE]) +1) );
	    strcat( buf1, buf2   );
    }	}

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
/*-    invariants -- Sanity check on muf.				*/
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
