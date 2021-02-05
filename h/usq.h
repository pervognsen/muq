
/*--   usq.h -- Header for usq.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_USQ_H
#define INCLUDED_USQ_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a usq: */
#define USQ_P(o) ((Usq_Header)vm_Loc(o))

#ifdef OLD
/* Offsets into job queues, which are */
/* physically implemented as 4-vecs:  */
#define USQ_NEXT	(0)
#define USQ_PREV	(1)
#define USQ_OWNER	(2)
#define USQ_NAME	(3)
#endif

#define USQ_RESERVED_SLOTS 2

/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Our refinement of Obj_Header_Rec: */
struct Usq_Header_Rec {
    Obj_A_Header o;

    Vm_Obj next;
    Vm_Obj prev;

    Vm_Obj reserved_slot[ USQ_RESERVED_SLOTS ];
};
typedef struct Usq_Header_Rec Usq_A_Header;
typedef struct Usq_Header_Rec*  Usq_Header;
typedef struct Usq_Header_Rec*  Usq_P;




/************************************************************************/
/*-    externs								*/

extern void	usq_Startup(  void              );
extern void	usq_Linkup(   void              );
extern void	usq_Shutdown( void              );
#ifdef OLD
extern Vm_Obj   usq_Import(   FILE* );
extern void     usq_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Int	usq_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	usq_Print(     FILE*,Vm_Uch*,Vm_Obj);
extern void     usq_Must_Contain (FILE*,Vm_Uch*,Vm_Obj,Vm_Obj);

extern void	usq_Dequeue( Vm_Obj );
extern void	usq_Enqueue( Vm_Obj );
#ifdef MAYBE_SOMEDAY
extern void	usq_Requeue( Vm_Obj, Vm_Obj );
#endif
extern void	usq_Reset(   Vm_Obj );

extern Obj_A_Hardcoded_Class usq_Hardcoded_Class;
extern Obj_A_Module_Summary  usq_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_USQ_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

