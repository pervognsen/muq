/*--   i32.h -- Header for i32.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_I32_H
#define INCLUDED_I32_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a vector: */
#define I32_P(o) ((I32_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, vectors have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* vector contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct I32_Header_Rec {
    Vm_Int32 slot[1];	/* Array of 32-bit integer values.	*/
};
typedef struct I32_Header_Rec I32_A_Header;
typedef struct I32_Header_Rec*  I32_Header;
typedef struct I32_Header_Rec*  I32_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    i32_Invariants(FILE*,char*,Vm_Obj);
extern void   i32_Print(     FILE*,char*,Vm_Obj);
extern void   i32_Startup( void              );
extern void   i32_Linkup(  void              );
extern void   i32_Shutdown(void              );

extern Vm_Obj i32_Alloc(      Vm_Unt, Vm_Obj        );
extern Vm_Obj i32_Dup(        Vm_Obj		    );
extern Vm_Int i32_Get_Key_P(  Vm_Int*,Vm_Obj,Vm_Obj );
extern Vm_Int i32_Get_Key_P_Asciz( Vm_Int*,Vm_Obj,Vm_Uch*);
extern Vm_Int i32_Len(        Vm_Obj		    );
extern Vm_Obj i32_Push_Obj(   Vm_Obj, Vm_Obj        );
extern void   i32_Set(        Vm_Obj, Vm_Unt, Vm_Obj);
extern Vm_Obj i32_SizedDup(   Vm_Obj, Vm_Unt	    );

extern Vm_Obj i32_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    i32_Type_Summary;
extern Obj_A_Module_Summary  i32_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_I32_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

