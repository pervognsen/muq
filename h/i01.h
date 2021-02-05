/*--   i01.h -- Header for i01.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_I01_H
#define INCLUDED_I01_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a vector: */
#define I01_P(o) ((I01_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, vectors have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* vector contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct I01_Header_Rec {
    Vm_Uch slot[1];	/* First byte is length in bits mod 8.	*/
};
typedef struct I01_Header_Rec I01_A_Header;
typedef struct I01_Header_Rec*  I01_Header;
typedef struct I01_Header_Rec*  I01_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    i01_Invariants(FILE*,char*,Vm_Obj);
extern void   i01_Print(     FILE*,char*,Vm_Obj);
extern void   i01_Startup( void              );
extern void   i01_Linkup(  void              );
extern void   i01_Shutdown(void              );

extern Vm_Obj i01_Alloc(      Vm_Unt, Vm_Obj        );
extern Vm_Obj i01_Dup(        Vm_Obj		    );
extern Vm_Int i01_Get_Key_P(  Vm_Int*,Vm_Obj,Vm_Obj );
extern Vm_Int i01_Get_Key_P_Asciz( Vm_Int*,Vm_Obj,Vm_Uch*);
extern Vm_Int i01_Len(        Vm_Obj		    );
extern Vm_Obj i01_Push_Obj(   Vm_Obj, Vm_Obj        );
extern void   i01_Set(        Vm_Obj, Vm_Unt, Vm_Obj);
extern Vm_Obj i01_SizedDup(   Vm_Obj, Vm_Unt	    );

extern Vm_Obj i01_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    i01_Type_Summary;
extern Obj_A_Module_Summary  i01_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_I01_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

