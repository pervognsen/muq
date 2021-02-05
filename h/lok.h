
/*--   lok.h -- Header for lok.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_LOK_H
#define INCLUDED_LOK_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a lok: */
#define LOK_P(o) ((Lok_Header)vm_Loc(o))

#define LOK_RESERVED_SLOTS 4

/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Our refinement of Obj_Header_Rec: */
struct Lok_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj held_by;	/* NIL or the job holding the lock.	*/
    Vm_Obj job_queue;	/* Jobs waiting to get lock.		*/

    Vm_Obj reserved_slot[ LOK_RESERVED_SLOTS ];
};
typedef struct Lok_Header_Rec Lok_A_Header;
typedef struct Lok_Header_Rec*  Lok_Header;
typedef struct Lok_Header_Rec*  Lok_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   lok_Startup( void              );
extern void   lok_Linkup(  void              );
extern void   lok_Shutdown(void              );
#ifdef OLD
extern Vm_Obj lok_Import(   FILE* );
extern void   lok_Export(   FILE*, Vm_Obj );
#endif

extern void   lok_Release( Vm_Obj );
extern void   lok_Reset( Vm_Obj );
extern Vm_Obj lok_Maybe_SendSleep_Job( Vm_Obj, Vm_Obj );

extern Obj_A_Hardcoded_Class lok_Hardcoded_Class;
extern Obj_A_Module_Summary  lok_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_LOK_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

