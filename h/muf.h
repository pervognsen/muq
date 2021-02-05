
/*--   muf.h -- Header for mufc -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_MUF_H
#define INCLUDED_MUF_H


/* Get Vm_Obj declaration: */
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Token types returned by the lexer:	*/
#define MUF_TYPE_QFN		OBJ_FROM_BYT3('q','f','n')
#define MUF_TYPE_FLT		OBJ_FROM_BYT3('f','l','t')
#define MUF_TYPE_DBL		OBJ_FROM_BYT3('d','b','l')
#define MUF_TYPE_INT		OBJ_FROM_BYT3('i','n','t')
#define MUF_TYPE_STR		OBJ_FROM_BYT3('s','t','r')
#define MUF_TYPE_CHR		OBJ_FROM_BYT3('c','h','r')
#define MUF_TYPE_ID		OBJ_FROM_BYT2('i','d')
#define MUF_TYPE_CMT		OBJ_FROM_BYT3('c','m','t')
#define MUF_TYPE_HQ		OBJ_FROM_BYT2('#','\'')


/************************************************************************/
/*-    types								*/

/* Define fields in our state vector: */
#define MUF_OFF_ASM	    (0)	/* Our assembler.			*/
#define MUF_OFF_SYMBOLS	    (1)	/* Stack of local symbols.		*/
#define MUF_OFF_SYMBOLS_SP  (2)	/* Saved stackpointer for above.	*/
#define MUF_OFF_CONTAINER   (3)	/* Context for fn we're nested in, else */
				/* OBJ_FROM_INT(0)			*/

    /* Source for tokens to assemble: */
#define MUF_OFF_STR	    (4)	/* Str containing source.		*/

    /* State stuff for muf_Fun_Assemble: */
#define MUF_OFF_SP	    (5)	/* Depth of data stack at start of fn.  */
#define MUF_OFF_BEG	    (6)	/* First byte in   current token in stg.*/
#define MUF_OFF_END	    (7)	/* First byte past current token in stg.*/
#define MUF_OFF_TYP	    (8)	/* Token type (MUF_TYPE_ID etc).	*/
#define MUF_OFF_FN_LINE	    (9)	/* Line number in file where fn starts.	*/
#define MUF_OFF_FN_NAME	   (10)	/* Name of fn being compiled else OBJ_FROM_INT('a'/'t'/0).*/
#define MUF_OFF_FN	   (11)	/* Fn being compiled.			*/
#define MUF_OFF_FN_BEG	   (12)	/* First byte in fn being compiled.	*/
#define MUF_OFF_QVARS	   (13)	/* Number of quoted vars in afn/thunk.	*/
#define MUF_OFF_ARITY	   (14)	/* Declared arity of fn.		*/
#define MUF_OFF_FORCE	   (15)	/* TRUE to force arity of fn.		*/
#define MUF_OFF_LINE	   (16)	/* Line number in file.			*/
#define MUF_OFF_MAX	   (17)	/* Total number of slots.		*/



/************************************************************************/
/*-    externs								*/

extern void    muf_Startup(  void );
extern void    muf_Linkup(   void );
extern void    muf_Shutdown( void );
#ifdef OLD
extern Vm_Obj  muf_Import(   FILE* );
extern void    muf_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj  muf_Alloc( Vm_Obj );
extern void    muf_Source_Add( Vm_Obj, Vm_Obj );
extern Vm_Obj  muf_Find_Package( Vm_Obj );
extern Vm_Obj  muf_Find_Package_Asciz( Vm_Uch* );
extern void    muf_Continue_Compile( Vm_Obj );
extern void    muf_Read_Next_Muf_Token(Vm_Int*,Vm_Int*,Vm_Obj*,Vm_Unt,Vm_Obj);
extern void    muf_Reset( Vm_Obj,   Vm_Obj );
extern void    muf_Set_Line_Number( Vm_Obj, Vm_Obj );

extern Obj_A_Module_Summary muf_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_MUF_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

