/*--   vec.h -- Header for vec.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_VEC_H
#define INCLUDED_VEC_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a vector: */
#define VEC_P(o) ((Vec_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, vectors have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* vector contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct Vec_Header_Rec {
    Vm_Obj slot[1];	/* Array of vector values.		*/
};
typedef struct Vec_Header_Rec Vec_A_Header;
typedef struct Vec_Header_Rec*  Vec_Header;
typedef struct Vec_Header_Rec*  Vec_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    vec_Invariants(FILE*,char*,Vm_Obj);
extern void   vec_Print(     FILE*,char*,Vm_Obj);
extern void   vec_Startup( void              );
extern void   vec_Linkup(  void              );
extern void   vec_Shutdown(void              );

extern Vm_Obj vec_Alloc(      Vm_Unt, Vm_Obj        );
extern Vm_Obj vec_Dup(        Vm_Obj		    );
extern Vm_Int vec_Get_Key_P(  Vm_Int*,Vm_Obj,Vm_Obj );
extern Vm_Int vec_Get_Key_P_Asciz( Vm_Int*,Vm_Obj,Vm_Uch*);
extern Vm_Int vec_Is_All_Floats( Vm_Obj vec	    );
extern Vm_Int vec_Len(        Vm_Obj		    );
extern Vm_Obj vec_Push_Obj(   Vm_Obj, Vm_Obj        );
extern void   vec_Set(        Vm_Obj, Vm_Unt, Vm_Obj);
extern Vm_Obj vec_SizedDup(   Vm_Obj, Vm_Unt	    );

extern Vm_Obj vec_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    vec_Type_Summary;
extern Obj_A_Module_Summary  vec_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_VEC_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

