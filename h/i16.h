/*--   i16.h -- Header for i16.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_I16_H
#define INCLUDED_I16_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a vector: */
#define I16_P(o) ((I16_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, vectors have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* vector contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct I16_Header_Rec {
    Vm_Int16 slot[1];	/* Array of 16-bit integer values.	*/
};
typedef struct I16_Header_Rec I16_A_Header;
typedef struct I16_Header_Rec*  I16_Header;
typedef struct I16_Header_Rec*  I16_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    i16_Invariants(FILE*,char*,Vm_Obj);
extern void   i16_Print(     FILE*,char*,Vm_Obj);
extern void   i16_Startup( void              );
extern void   i16_Linkup(  void              );
extern void   i16_Shutdown(void              );

extern Vm_Obj i16_Alloc(      Vm_Unt, Vm_Obj        );
extern Vm_Obj i16_Dup(        Vm_Obj		    );
extern Vm_Int i16_Get_Key_P(  Vm_Int*,Vm_Obj,Vm_Obj );
extern Vm_Int i16_Get_Key_P_Asciz( Vm_Int*,Vm_Obj,Vm_Uch*);
extern Vm_Int i16_Len(        Vm_Obj		    );
extern Vm_Obj i16_Push_Obj(   Vm_Obj, Vm_Obj        );
extern void   i16_Set(        Vm_Obj, Vm_Unt, Vm_Obj);
extern Vm_Obj i16_SizedDup(   Vm_Obj, Vm_Unt	    );

extern Vm_Obj i16_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    i16_Type_Summary;
extern Obj_A_Module_Summary  i16_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_I16_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

