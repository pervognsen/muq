
/*--   stm.h -- Header for stm.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_STM_H
#define INCLUDED_STM_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stm: */
#define STM_P(o) ((Stm_Header)vm_Loc(o))

/* Default number of slots for a stream: */
#define STM_SIZE_DEFAULT (0x4)

/* Max number of slots for a stack.    */
/* Mainly, need to avoid over-running  */
/* max size allowed by vm diskfiles or */
/* thrashing bigbuf with huge objs:    */
#define STM_SIZE_MAX (4096)



/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Our refinement of Obj_Header_Rec: */
struct Stm_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj vector;	/* Vector we store stuff in.		*/
    Vm_Obj cat;		/* Where to pull from.			*/
    Vm_Obj rat;		/* Where to push to.			*/
};
typedef struct Stm_Header_Rec Stm_A_Header;
typedef struct Stm_Header_Rec*  Stm_Header;
typedef struct Stm_Header_Rec*  Stm_P;

/****************************************************************/
/* Truths: 							*/
/* 'cat' and 'rat' always point to valid offsets in 'vector';	*/
/* If 'cat'=='rat' the stream is empty;				*/
/* If 'cat'!='rat' then						*/
/*     vector[cat] holds valid data, next item to 'pull';	*/
/*     vector[rat] is empty, next slot to 'push' into.		*/
/* fi								*/
/* After a 'pull', cat is incremented mod vector len.		*/
/* After a 'push', rat is incremented mod vector len.		*/
/*								*/
/* Theorem:							*/
/* There is always at least one empty slot in 'vector'.		*/
/****************************************************************/


/************************************************************************/
/*-    externs								*/

extern void   stm_Startup(  void );
extern void   stm_Linkup(   void );
extern void   stm_Shutdown( void );
#ifdef OLD
extern Vm_Obj stm_Import(   FILE* );
extern void   stm_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj stm_Length( Vm_Obj  );
extern Vm_Obj stm_Nth( Vm_Obj, Vm_Unt  );
extern void   stm_Set_Nth( Vm_Obj, Vm_Unt, Vm_Obj );
extern void   stm_Reset( Vm_Obj );
extern Vm_Int stm_Empty_P( Vm_Obj );
extern void   stm_Push(   Vm_Obj, Vm_Obj );
extern Vm_Obj stm_Pull(   Vm_Obj         );
extern Vm_Obj stm_Unpush( Vm_Obj         );
extern void   stm_Unpull( Vm_Obj, Vm_Obj );

extern Obj_A_Hardcoded_Class stm_Hardcoded_Class;
extern Obj_A_Module_Summary  stm_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_STM_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

