
/*--   tbl.h -- Header for tbl.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_TBL_H
#define INCLUDED_TBL_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a tbl: */
#define TBL_P(o) ((Tbl_Header)vm_Loc(o))

/* Default number of slots for a stack: */
#define TBL_SIZE_DEFAULT (0x10)

/* Max number of slots for a stack.    */
/* Mainly, need to avoid over-running  */
/* max size allowed by vm diskfiles or */
/* thrashing bigbuf with huge objs:    */
#ifndef TBL_SIZE_MAX
#define TBL_SIZE_MAX (4096)
#endif

#define TBL_MAX_RANK (7)



/************************************************************************/
/*-    types								*/

/* Our refinement of Obj_Header_Rec: */
struct Tbl_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj vector;		/* Vector we store stuff in.		*/
    Vm_Obj length;		/* Stack pointer.			*/
    Vm_Obj rank;		/* Number of active dimensions.		*/
    Vm_Obj dim[ TBL_MAX_RANK ];	/* Number of active dimensions.		*/
};
typedef struct Tbl_Header_Rec Tbl_A_Header;
typedef struct Tbl_Header_Rec*  Tbl_Header;
typedef struct Tbl_Header_Rec*  Tbl_P;



/************************************************************************/
/*-    externs								*/

extern void   tbl_Startup( void              );
extern void   tbl_Linkup(  void              );
extern void   tbl_Shutdown(void              );
#ifdef OLD
extern Vm_Obj tbl_Import(   FILE* );
extern void   tbl_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj tbl_Dup( Vm_Obj );
extern Vm_Int tbl_Get_Key_P( Vm_Int*, Vm_Obj, Vm_Obj	);
extern Vm_Int tbl_Get_Key_P_Asciz( Vm_Int*, Vm_Obj, Vm_Uch* );
extern Vm_Obj tbl_Length( Vm_Obj  );
extern Vm_Obj tbl_Get( Vm_Obj, Vm_Int  );
extern Vm_Int tbl_Get_Int( Vm_Obj, Vm_Unt );
extern Vm_Int tbl_Got_Headroom( Vm_Obj, Vm_Int );
extern void   tbl_Set( Vm_Obj, Vm_Int, Vm_Obj );
extern void   tbl_Set_Int( Vm_Obj, Vm_Int, Vm_Int );
extern Vm_Uch* tbl_Sprint1( Vm_Uch*,Vm_Uch*,Vm_Obj );
extern void   tbl_Reset( Vm_Obj );
extern Vm_Int tbl_Empty_P( Vm_Obj );
extern void   tbl_Push_Block( Vm_Obj, Vm_Unt );
extern void   tbl_Push(   Vm_Obj, Vm_Obj );
extern Vm_Obj tbl_Pull(   Vm_Obj         );
extern void   tbl_Delete( Vm_Obj, Vm_Obj );
extern void   tbl_Delete_Nth( Vm_Obj, Vm_Unt );
extern void   tbl_Delete_Bth( Vm_Obj, Vm_Unt );
extern Vm_Obj tbl_Alloc(Vm_Unt n,Vm_Obj a);

extern Obj_A_Hardcoded_Class tbl_Hardcoded_Class;
extern Obj_A_Module_Summary  tbl_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_TBL_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

