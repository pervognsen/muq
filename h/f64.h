/*--   f64.h -- Header for f64.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_F64_H
#define INCLUDED_F64_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a vector: */
#define F64_P(o) ((F64_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, vectors have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* vector contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct F64_Header_Rec {
    Vm_Flt64 slot[1];	/* Array of 64-bit float values.	*/
};
typedef struct F64_Header_Rec F64_A_Header;
typedef struct F64_Header_Rec*  F64_Header;
typedef struct F64_Header_Rec*  F64_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    f64_Invariants(FILE*,char*,Vm_Obj);
extern void   f64_Print(     FILE*,char*,Vm_Obj);
extern void   f64_Startup( void              );
extern void   f64_Linkup(  void              );
extern void   f64_Shutdown(void              );

extern Vm_Obj f64_Alloc(      Vm_Unt, Vm_Obj        );
extern Vm_Obj f64_Dup(        Vm_Obj		    );
extern Vm_Int f64_Get_Key_P(  Vm_Int*,Vm_Obj,Vm_Obj );
extern Vm_Int f64_Get_Key_P_Asciz( Vm_Int*,Vm_Obj,Vm_Uch*);
extern Vm_Int f64_Len(        Vm_Obj		    );
extern Vm_Obj f64_Push_Obj(   Vm_Obj, Vm_Obj        );
extern void   f64_Set(        Vm_Obj, Vm_Unt, Vm_Obj);
extern Vm_Obj f64_SizedDup(   Vm_Obj, Vm_Unt	    );

extern Vm_Obj f64_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    f64_Type_Summary;
extern Obj_A_Module_Summary  f64_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_F64_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

