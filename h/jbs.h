
/*--   jbs.h -- Header for jbs.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_JBS_H
#define INCLUDED_JBS_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a session: */
#define JBS_P(o) ((Jbs_Header)vm_Loc(o))

#define JBS_RESERVED_SLOTS 4


/************************************************************************/
/*-    types								*/

/* Our refinement of Obj_Header_Rec: */
struct Jbs_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj session;		/* Session of which jobset is part.	*/
    Vm_Obj jobset_leader;	/* Jobset leader (a job).		*/
    Vm_Obj job_queue;		/* Queue holding all jobs in jobset.	*/
    Vm_Obj next_jobset;		/* Next jobset in session.		*/
    Vm_Obj prev_jobset;		/* Prev jobset in session.		*/

    Vm_Obj reserved_slot[ JBS_RESERVED_SLOTS ];
};
typedef struct Jbs_Header_Rec Jbs_A_Header;
typedef struct Jbs_Header_Rec*  Jbs_Header;
typedef struct Jbs_Header_Rec*  Jbs_P;



/************************************************************************/
/*-    externs								*/

extern int    jbs_Invariants(FILE*,char*,Vm_Obj);
extern void   jbs_Print(     FILE*,char*,Vm_Obj);
extern void   jbs_Startup( void              );
extern void   jbs_Linkup(  void              );
extern void   jbs_Shutdown(void              );
#ifdef OLD
extern Vm_Obj jbs_Import(   FILE* );
extern void   jbs_Export(   FILE*, Vm_Obj );
#endif

extern void   jbs_Del( Vm_Obj, Vm_Obj );

extern Obj_A_Hardcoded_Class jbs_Hardcoded_Class;
extern Obj_A_Module_Summary  jbs_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_JBS_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

