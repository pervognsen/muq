
/*--   stk.h -- Header for stk.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_STK_H
#define INCLUDED_STK_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stk: */
#define STK_P(o) ((Stk_Header)vm_Loc(o))

/* Default number of slots for a stack: */
#define STK_SIZE_DEFAULT (0x10)

/* Max number of slots for a stack.    */
/* Mainly, need to avoid over-running  */
/* max size allowed by vm diskfiles or */
/* thrashing bigbuf with huge objs:    */
#ifndef STK_SIZE_MAX
#define STK_SIZE_MAX (4096)
#endif


/************************************************************************/
/*-    types								*/

/* Our refinement of Obj_Header_Rec: */
struct Stk_Header_Rec {
    Obj_A_Header	o;
/*  Vm_Obj maxlen;	/  Currently unused.			*/
    Vm_Obj vector;	/* Vector we store stuff in.		*/
    Vm_Obj length;	/* Stack pointer.			*/
};
typedef struct Stk_Header_Rec Stk_A_Header;
typedef struct Stk_Header_Rec*  Stk_Header;
typedef struct Stk_Header_Rec*  Stk_P;



/************************************************************************/
/*-    externs								*/

extern void   stk_Startup( void              );
extern void   stk_Linkup(  void              );
extern void   stk_Shutdown(void              );
#ifdef OLD
extern Vm_Obj stk_Import(   FILE* );
extern void   stk_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj stk_Dup( Vm_Obj );
extern Vm_Int stk_Get_Key_P( Vm_Int*, Vm_Obj, Vm_Obj	);
extern Vm_Int stk_Get_Key_P_Asciz( Vm_Int*, Vm_Obj, Vm_Uch* );
extern Vm_Obj stk_Length( Vm_Obj  );
extern Vm_Obj stk_Get( Vm_Obj, Vm_Int  );
extern Vm_Int stk_Get_Int( Vm_Obj, Vm_Unt );
extern Vm_Int stk_Got_Headroom( Vm_Obj, Vm_Int );
extern void   stk_Set( Vm_Obj, Vm_Int, Vm_Obj );
extern void   stk_Set_Int( Vm_Obj, Vm_Int, Vm_Int );
extern Vm_Uch* stk_Sprint1( Vm_Uch*,Vm_Uch*,Vm_Obj );
extern void   stk_Reset( Vm_Obj );
extern Vm_Int stk_Empty_P( Vm_Obj );
extern void   stk_Push_Block( Vm_Obj, Vm_Unt );
extern void   stk_Push(   Vm_Obj, Vm_Obj );
extern Vm_Obj stk_Pull(   Vm_Obj         );
extern void   stk_Delete( Vm_Obj, Vm_Obj );
extern void   stk_Delete_Nth( Vm_Obj, Vm_Unt );
extern void   stk_Delete_Bth( Vm_Obj, Vm_Unt );

extern Obj_A_Hardcoded_Class stk_Hardcoded_Class;
extern Obj_A_Hardcoded_Class lst_Hardcoded_Class;
extern Obj_A_Hardcoded_Class dst_Hardcoded_Class;
extern Obj_A_Module_Summary  stk_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_STK_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

