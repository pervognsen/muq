/*--   eob.h -- Header for eob.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_EOB_H
#define INCLUDED_EOB_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate an ephemeral object: */
#define EOB_P(r,o) \
 ((Eob_Header)(job_RunState.l_bot+job_Ephemeral_Object_Loc((r),(o))))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, vectors have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* vector contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct Eob_Header_Rec {
    Vm_Obj owner;
    Vm_Obj key;		/* Pointer to class key.		*/
    Vm_Obj slot[1];	/* Array of vector values.		*/
};
typedef struct Eob_Header_Rec Eob_A_Header;
typedef struct Eob_Header_Rec*  Eob_Header;
typedef struct Eob_Header_Rec*  Eob_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern Vm_Int eob_Invariants(FILE*,char*,Vm_Obj);
extern void   eob_Print(     FILE*,char*,Vm_Obj);
extern void   eob_Startup( void              );
extern void   eob_Linkup(  void              );
extern void   eob_Shutdown(void              );

extern Vm_Obj eob_Alloc(      Vm_Unt, Vm_Obj        );
extern Vm_Obj eob_Dup(        Vm_Obj		    );
extern Vm_Int eob_Get_Key_P(  Vm_Int*,Vm_Obj,Vm_Obj );
extern Vm_Int eob_Get_Key_P_Asciz( Vm_Int*,Vm_Obj,Vm_Uch*);
extern Vm_Int eob_Len(        Vm_Obj		    );
extern Vm_Obj eob_Push_Obj(   Vm_Obj, Vm_Obj        );
extern void   eob_Set(        Vm_Obj, Vm_Unt, Vm_Obj);
extern Vm_Obj eob_SizedDup(   Vm_Obj, Vm_Unt	    );

extern Vm_Obj eob_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    eob_Type_Summary;
extern Obj_A_Module_Summary  eob_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_EOB_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

