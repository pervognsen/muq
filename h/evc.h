/*--   evc.h -- Header for evc.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_EVC_H
#define INCLUDED_EVC_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate an ephemeral vector: */
#define EVC_P(r,o) \
 ((Evc_Header)(job_RunState.l_bot+job_Ephemeral_Vector_Loc((r),(o))))



/************************************************************************/
/*-    types								*/

struct Evc_Header_Rec {
    Vm_Obj owner;	/* Creator of vector.			*/
    Vm_Obj is_a;
    Vm_Obj slot[1];	/* Array of vector values.		*/
};
typedef struct Evc_Header_Rec Evc_A_Header;
typedef struct Evc_Header_Rec*  Evc_Header;
typedef struct Evc_Header_Rec*  Evc_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    evc_Invariants(FILE*,char*,Vm_Obj);
extern void   evc_Print(     FILE*,char*,Vm_Obj);
extern void   evc_Startup( void              );
extern void   evc_Linkup(  void              );
extern void   evc_Shutdown(void              );

extern Vm_Obj evc_Alloc(      Vm_Unt, Vm_Obj        );
extern Vm_Obj evc_Dup(        Vm_Obj		    );
extern Vm_Int evc_Get_Key_P(  Vm_Int*,Vm_Obj,Vm_Obj );
extern Vm_Int evc_Get_Key_P_Asciz( Vm_Int*,Vm_Obj,Vm_Uch*);
extern Vm_Int evc_Len(        Vm_Obj		    );
extern Vm_Obj evc_Push_Obj(   Vm_Obj, Vm_Obj        );
extern void   evc_Set(        Vm_Obj, Vm_Unt, Vm_Obj);
extern Vm_Obj evc_SizedDup(   Vm_Obj, Vm_Unt	    );

extern Vm_Obj evc_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    evc_Type_Summary;
extern Obj_A_Module_Summary  evc_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_EVC_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

