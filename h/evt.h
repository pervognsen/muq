
/*--   evt.h -- Header for evt.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_EVT_H
#define INCLUDED_EVT_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifdef OLD
/* Basic macro to locate a evt: */
#define EVT_P(o) ((Evt_Header)vm_Loc(o))
#endif


/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Our refinement of Obj_Header_Rec: */
#ifdef OLD
struct Evt_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj held_by;	/* NIL or the job holding the lock.	*/
    Vm_Obj job_queue;	/* Jobs waiting to get lock.		*/
};
typedef struct Evt_Header_Rec Evt_A_Header;
typedef struct Evt_Header_Rec*  Evt_Header;
typedef struct Evt_Header_Rec*  Evt_P;
#endif


/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   evt_Startup( void              );
extern void   evt_Linkup(  void              );
extern void   evt_Shutdown(void              );
#ifdef OLD
extern Vm_Obj evt_Import(   FILE* );
extern void   evt_Export(   FILE*, Vm_Obj );
#endif

extern void   evt_Release( Vm_Obj );
extern void   evt_Reset( Vm_Obj );
extern void   evt_Maybe_SendSleep_Job( Vm_Obj );

extern Obj_A_Module_Summary  evt_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_EVT_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

