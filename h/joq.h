
/*--   joq.h -- Header for joq.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_JOQ_H
#define INCLUDED_JOQ_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a joq: */
#define JOQ_P(o) ((Joq_Header)vm_Loc(o))


/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Record containing one full queue pointer, */
/* comprising a  jo[bq] pointer plus a slot  */
/* number within jo[bq] object:              */
struct Joq_Pointer_Rec {
    Vm_Obj	o;	/* Job/joq we point to. */
    Vm_Obj	i;	/* Slot inside job/joq. */
};
typedef struct Joq_Pointer_Rec Joq_A_Pointer;
typedef struct Joq_Pointer_Rec*  Joq_Pointer;

/* Record containing one link in a job queue */
/* doubly-linked list.  This record type is  */
/* mainly used in job.h link[] array:        */
struct Joq_Link_Rec {
    Joq_A_Pointer next; /* Next in linklist.    */
    Joq_A_Pointer prev; /* Prev in linklist.    */
    Vm_Obj	  this;	/* Job queue we are in.	*/
};
typedef struct Joq_Link_Rec Joq_A_Link;
typedef struct Joq_Link_Rec*  Joq_Link;

/* Our refinement of Obj_Header_Rec: */
struct Joq_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj kind;
    Vm_Obj part_of;
    Joq_A_Link link;
};
typedef struct Joq_Header_Rec Joq_A_Header;
typedef struct Joq_Header_Rec*  Joq_Header;
typedef struct Joq_Header_Rec*  Joq_P;




/************************************************************************/
/*-    externs								*/

extern void	joq_Startup(  void              );
extern void	joq_Linkup(   void              );
extern void	joq_Shutdown( void              );
#ifdef OLD
extern Vm_Obj   joq_Import(   FILE* );
extern void     joq_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Int	joq_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	joq_Print(     FILE*,Vm_Uch*,Vm_Obj);

extern Vm_Obj	joq_Alloc(   Vm_Obj, Vm_Obj );
extern void     joq_Unlink(  Vm_Obj, Vm_Obj );
extern void     joq_Link(    Vm_Obj, Vm_Obj, Vm_Unt );
extern void	joq_Dequeue( Vm_Obj );
extern void     joq_Desleep( void );
extern void	joq_Enqueue( Vm_Obj, Vm_Obj );
extern void	joq_Ensleep( Vm_Obj, Vm_Int );
extern void	joq_Resleep( Vm_Obj         );
extern Vm_Int   joq_Is_A_Joq(Vm_Obj );
extern void     joq_Reset(   Vm_Obj );
extern void	joq_Requeue( Vm_Obj, Vm_Obj );
extern void     joq_Pause_Job( Vm_Obj );
extern void	joq_Run_Job( Vm_Obj );
extern void	joq_Run_Queue( Vm_Obj );
extern void     joq_Run_Message_Stream_Read_Queue( Vm_Obj, Vm_Obj );
extern void     joq_Dump( Vm_Uch* );
extern Vm_Int   joq_Eq( Joq_Link, Joq_Link );
extern void     joq_Kind( FILE*, Vm_Uch*, Vm_Obj, Vm_Obj );
extern Joq_A_Link joq_Get_Link( Joq_Pointer );

extern Obj_A_Hardcoded_Class joq_Hardcoded_Class;
extern Obj_A_Module_Summary  joq_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_JOQ_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

