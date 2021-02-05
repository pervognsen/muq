
/*--   mtd.h -- Header for mtd.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_MTD_H
#define INCLUDED_MTD_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a mtd: */
#define MTD_P(o) ((Mtd_Header)vm_Loc(o))

/* Maximum supported number of slots in a struct: */
#ifndef MTD_MAX_SLOTS
#define MTD_MAX_SLOTS ((Vm_Unt)1024)
#endif

#define MTD_RESERVED_SLOTS 4

/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Mtd_Slot_Rec {
    Vm_Obj op;		/* An int: 0==NIL, 1==:instance 2==:class	*/
    Vm_Obj arg;		/* class if op==:class, obj if op==:instance	*/
};
typedef struct Mtd_Slot_Rec Mtd_A_Slot;
typedef struct Mtd_Slot_Rec*  Mtd_Slot;
typedef struct Mtd_Slot_Rec*  Mtd_Slot_P;

/* Our refinement of Obj_Header_Rec: */
struct Mtd_Header_Rec {
    Obj_A_Header	o;

/* buggo, should use flags word, to implement   */
/* an AS-CLASS flag that       */
/* results in method_fn executing with actingUser */
/* set to owner of class of first argument.        */
    Vm_Obj flags;
    Vm_Obj qualifier;	/* NIL, :before :after or :around */
    Vm_Obj method_fn;	/* Implements method.		  */
    Vm_Obj generic_fn;	/* Generic fn to which we belong. */
    Vm_Obj lambda_list;

    Vm_Obj reserved_slot[ MTD_RESERVED_SLOTS ];

    Vm_Obj required_args;
    Mtd_A_Slot slot[1];	    /* Actually "Mtd_A_Slot slot[required_args];" */
};
typedef struct Mtd_Header_Rec Mtd_A_Header;
typedef struct Mtd_Header_Rec*  Mtd_Header;
typedef struct Mtd_Header_Rec*  Mtd_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   mtd_Startup( void              );
extern void   mtd_Linkup(  void              );
extern void   mtd_Shutdown(void              );
#ifdef OLD
extern Vm_Obj mtd_Import(   FILE* );
extern void   mtd_Export(   FILE*, Vm_Obj );
#endif


extern Obj_A_Hardcoded_Class mtd_Hardcoded_Class;
extern Obj_A_Module_Summary  mtd_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_MTD_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

