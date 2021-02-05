
/*--   rdt.h -- Header for rdt.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_RDT_H
#define INCLUDED_RDT_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a rdt: */
#define RDT_P(o) ((Rdt_Header)vm_Loc(o))

/* # Chars in our readtable: */
#define RDT_MAX_CHARS ((Vm_Unt)256)

/* CommonLisp semantic character types: */
#define RDT_ILLEGAL              OBJ_FROM_INT(1)
#define RDT_WHITESPACE           OBJ_FROM_INT(2)
#define RDT_CONSTITUENT          OBJ_FROM_INT(3)
#define RDT_SINGLE_ESCAPE        OBJ_FROM_INT(4)
#define RDT_MULTIPLE_ESCAPE      OBJ_FROM_INT(5)
#define RDT_TERMINATING_MACRO    OBJ_FROM_INT(6)
#define RDT_NONTERMINATING_MACRO OBJ_FROM_INT(7)
#define RDT_DISPATCHING_MACRO    OBJ_FROM_INT(8)


/* Values for readtable_case field: */
#define RDT_PRESERVE	OBJ_FROM_INT(0)
#define RDT_UPCASE	OBJ_FROM_INT(1)
#define RDT_DOWNCASE	OBJ_FROM_INT(2)
#define RDT_INVERT	OBJ_FROM_INT(3)

#define RDT_RESERVED_SLOTS 16


/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Rdt_Slot_Rec {
    Vm_Obj kind;	/* One of the above semantic char types		*/
    Vm_Obj val;		/* cfn for non/term macros;			*/
			/* readtable for dispatching macros		*/
};
typedef struct Rdt_Slot_Rec Rdt_A_Slot;
typedef struct Rdt_Slot_Rec*  Rdt_Slot;
typedef struct Rdt_Slot_Rec*  Rdt_Slot_P;

/* Our refinement of Obj_Header_Rec: */
struct Rdt_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj readtable_case;      /* Number of required args in slot[].	*/

    Vm_Obj reserved_slot[ RDT_RESERVED_SLOTS ];

    Rdt_A_Slot slot[256];	/* One for each char.			*/
    /* required args come first, then, optional, then keyword. */
};
typedef struct Rdt_Header_Rec Rdt_A_Header;
typedef struct Rdt_Header_Rec*  Rdt_Header;
typedef struct Rdt_Header_Rec*  Rdt_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   rdt_Startup( void              );
extern void   rdt_Linkup(  void              );
extern void   rdt_Shutdown(void              );
#ifdef OLD
extern Vm_Obj rdt_Import(   FILE* );
extern void   rdt_Export(   FILE*, Vm_Obj );
#endif


extern Obj_A_Hardcoded_Class rdt_Hardcoded_Class;
extern Obj_A_Module_Summary  rdt_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_RDT_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

