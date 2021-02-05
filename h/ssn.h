
/*--   ssn.h -- Header for ssn.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_SSN_H
#define INCLUDED_SSN_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a session: */
#define SSN_P(o) ((Ssn_Header)vm_Loc(o))

#define SSN_RESERVED_SLOTS 4

/************************************************************************/
/*-    types								*/

/* Our refinement of Obj_Header_Rec: */
struct Ssn_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj session_leader;	/* Job to which to send HUP signals.	*/
    Vm_Obj skt;			/* Net connection running session.	*/
    Vm_Obj next_jobset;
    Vm_Obj prev_jobset;

    Vm_Obj reserved_slot[ SSN_RESERVED_SLOTS ];
};
typedef struct Ssn_Header_Rec Ssn_A_Header;
typedef struct Ssn_Header_Rec*  Ssn_Header;
typedef struct Ssn_Header_Rec*  Ssn_P;



/************************************************************************/
/*-    externs								*/

extern int    ssn_Invariants(FILE*,char*,Vm_Obj);
extern void   ssn_Print(     FILE*,char*,Vm_Obj);
extern void   ssn_Startup( void              );
extern void   ssn_Linkup(  void              );
extern void   ssn_Shutdown(void              );
extern Vm_Obj ssn_Import(   FILE* );
extern void   ssn_Export(   FILE*, Vm_Obj );

extern void   ssn_Del( Vm_Obj, Vm_Obj );

extern void   ssn_Link_Jobset( Vm_Obj, Vm_Obj );
extern void   ssn_Unlink_Jobset( Vm_Obj, Vm_Obj );

extern Obj_A_Hardcoded_Class ssn_Hardcoded_Class;
extern Obj_A_Module_Summary  ssn_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_SSN_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

