/*--   ecn.h -- Header for ecn.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_ECN_H
#define INCLUDED_ECN_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate an ephemeral cons cell: */
#define ECN_P(r,o) \
 ((Ecn_Header)(job_RunState.l_bot+job_Ephemeral_List_Loc((r),(o))))



/************************************************************************/
/*-    types								*/

/**********************************************/
/* Decided not to include an is_a field here: */
/*					      */
/* 1) The added overhead is a lot more (50%)  */
/*    than in the case of regular cons cells; */
/*					      */
/* 2) Anyone who really wants to subclass Cons*/
/*    can always use non-emphemeral cells --  */
/*    ephemerals are just an efficiency hack; */
/*					      */
/* 3) Having to do mod-3 instead of &1 in     */
/*    job_Ephemeral_List_Loc() is an awful    */
/*    efficiency hit for little return.       */
/*					      */
/**********************************************/

struct Ecn_Header_Rec {
    Vm_Obj car;
    Vm_Obj cdr;
};
typedef struct Ecn_Header_Rec Ecn_A_Header;
typedef struct Ecn_Header_Rec*  Ecn_Header;
typedef struct Ecn_Header_Rec*  Ecn_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    ecn_Invariants(FILE*,char*,Vm_Obj);
extern void   ecn_Print(     FILE*,char*,Vm_Obj);
extern void   ecn_Startup( void              );
extern void   ecn_Linkup(  void              );
extern void   ecn_Shutdown(void              );

extern Vm_Obj ecn_Alloc(      Vm_Obj, Vm_Obj   	    );
extern Vm_Obj ecn_Dup(        Vm_Obj		    );
extern Vm_Int ecn_Len(        Vm_Obj		    );
extern void   ecn_Set(        Vm_Obj, Vm_Unt, Vm_Obj);

extern Vm_Obj ecn_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    ecn_Type_Summary;
extern Obj_A_Module_Summary  ecn_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_ECN_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

