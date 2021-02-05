
/*--   ary.h -- Header for ary.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_ARY_H
#define INCLUDED_ARY_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a ary: */
#define ARY_P(o) ((Ary_Header)vm_Loc(o))

/* Default number of slots for a stack: */
#define ARY_SIZE_DEFAULT (0x10)

/* Max number of slots for a stack.    */
/* Mainly, need to avoid over-running  */
/* max size allowed by vm diskfiles or */
/* thrashing bigbuf with huge objs:    */
#ifndef ARY_SIZE_MAX
#define ARY_SIZE_MAX (4096)
#endif

#define ARY_MAX_RANK (7)



/************************************************************************/
/*-    types								*/

/* Our refinement of Obj_Header_Rec: */
struct Ary_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj vector;		/* Vector we store stuff in.		*/
    Vm_Obj length;		/* Stack pointer.			*/
    Vm_Obj rank;		/* Number of active dimensions.		*/
    Vm_Obj dim[ ARY_MAX_RANK ];	/* Number of active dimensions.		*/
};
typedef struct Ary_Header_Rec Ary_A_Header;
typedef struct Ary_Header_Rec*  Ary_Header;
typedef struct Ary_Header_Rec*  Ary_P;



/************************************************************************/
/*-    externs								*/

extern void   ary_Startup( void              );
extern void   ary_Linkup(  void              );
extern void   ary_Shutdown(void              );
#ifdef OLD
extern Vm_Obj ary_Import(   FILE* );
extern void   ary_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj ary_Dup( Vm_Obj );
extern Vm_Int ary_Get_Key_P( Vm_Int*, Vm_Obj, Vm_Obj	);
extern Vm_Int ary_Get_Key_P_Asciz( Vm_Int*, Vm_Obj, Vm_Uch* );
extern Vm_Obj ary_Length( Vm_Obj  );
extern Vm_Obj ary_Get( Vm_Obj, Vm_Int  );
extern Vm_Int ary_Get_Int( Vm_Obj, Vm_Unt );
extern Vm_Int ary_Got_Headroom( Vm_Obj, Vm_Int );
extern void   ary_Set( Vm_Obj, Vm_Int, Vm_Obj );
extern void   ary_Set_Int( Vm_Obj, Vm_Int, Vm_Int );
extern Vm_Uch* ary_Sprint1( Vm_Uch*,Vm_Uch*,Vm_Obj );
extern void   ary_Reset( Vm_Obj );
extern Vm_Int ary_Empty_P( Vm_Obj );
extern void   ary_Push_Block( Vm_Obj, Vm_Unt );
extern void   ary_Push(   Vm_Obj, Vm_Obj );
extern Vm_Obj ary_Pull(   Vm_Obj         );
extern void   ary_Delete( Vm_Obj, Vm_Obj );
extern void   ary_Delete_Nth( Vm_Obj, Vm_Unt );
extern void   ary_Delete_Bth( Vm_Obj, Vm_Unt );
extern Vm_Obj ary_Alloc(Vm_Unt n,Vm_Obj a);

extern Obj_A_Hardcoded_Class ary_Hardcoded_Class;
extern Obj_A_Module_Summary  ary_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_ARY_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

