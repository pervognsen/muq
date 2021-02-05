/*--   f32.h -- Header for f32.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_F32_H
#define INCLUDED_F32_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a vector: */
#define F32_P(o) ((F32_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, vectors have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* vector contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct F32_Header_Rec {
    Vm_Flt32 slot[1];	/* Array of 32-bit float values.	*/
};
typedef struct F32_Header_Rec F32_A_Header;
typedef struct F32_Header_Rec*  F32_Header;
typedef struct F32_Header_Rec*  F32_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    f32_Invariants(FILE*,char*,Vm_Obj);
extern void   f32_Print(     FILE*,char*,Vm_Obj);
extern void   f32_Startup( void              );
extern void   f32_Linkup(  void              );
extern void   f32_Shutdown(void              );

extern Vm_Obj f32_Alloc(      Vm_Unt, Vm_Obj        );
extern Vm_Obj f32_Dup(        Vm_Obj		    );
extern Vm_Int f32_Get_Key_P(  Vm_Int*,Vm_Obj,Vm_Obj );
extern Vm_Int f32_Get_Key_P_Asciz( Vm_Int*,Vm_Obj,Vm_Uch*);
extern Vm_Int f32_Len(        Vm_Obj		    );
extern Vm_Obj f32_Push_Obj(   Vm_Obj, Vm_Obj        );
extern void   f32_Set(        Vm_Obj, Vm_Unt, Vm_Obj);
extern Vm_Obj f32_SizedDup(   Vm_Obj, Vm_Unt	    );

extern Vm_Obj f32_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    f32_Type_Summary;
extern Obj_A_Module_Summary  f32_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_F32_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

