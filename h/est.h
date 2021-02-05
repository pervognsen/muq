/*--   est.h -- Header for est.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_EST_H
#define INCLUDED_EST_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate an ephemeral struct: */
#define EST_P(r,o) \
 ((Est_Header)(job_RunState.l_bot+job_Ephemeral_Struct_Loc((r),(o))))



/************************************************************************/
/*-    types								*/

struct Est_Header_Rec {
    Vm_Obj owner;	/* Creator of struct.			*/
    Vm_Obj is_a;	/* Pointer to struct definition.	*/
    Vm_Obj slot[1];	/* Array of struct values.		*/
};
typedef struct Est_Header_Rec Est_A_Header;
typedef struct Est_Header_Rec*  Est_Header;
typedef struct Est_Header_Rec*  Est_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    est_Invariants(FILE*,char*,Vm_Obj);
extern void   est_Print(     FILE*,char*,Vm_Obj);
extern void   est_Startup( void              );
extern void   est_Linkup(  void              );
extern void   est_Shutdown(void              );

extern Vm_Obj est_Alloc(      Vm_Obj, Vm_Obj   	    );
extern Vm_Obj est_Dup(        Vm_Obj		    );
extern Vm_Int est_Len(        Vm_Obj		    );
extern void   est_Set(        Vm_Obj, Vm_Unt, Vm_Obj);

extern Vm_Obj est_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    est_Type_Summary;
extern Obj_A_Module_Summary  est_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_EST_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

