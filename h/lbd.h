
/*--   lbd.h -- Header for lbd.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_LBD_H
#define INCLUDED_LBD_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a lbd: */
#define LBD_P(o) ((Lbd_Header)vm_Loc(o))

/* Maximum supported number of slots in a lambdaList: */
#ifndef LBD_MAX_SLOTS
#define LBD_MAX_SLOTS ((Vm_Unt)1024)
#endif

/* Maximum supported number of local vars in a lambdaList: */
#ifndef LBD_MAX_VARS
#define LBD_MAX_VARS ((Vm_Unt)1024)
#endif

#define LBD_RESERVED_SLOTS 4

/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Lbd_Slot_Rec {
    Vm_Obj name;	/* String for req/opt args, keyword for keyword args.*/
    Vm_Obj initval;	/* Default value of slot.			*/
    Vm_Obj initform;	/* Zero, else form yielding default value.	*/
};
typedef struct Lbd_Slot_Rec Lbd_A_Slot;
typedef struct Lbd_Slot_Rec*  Lbd_Slot;
typedef struct Lbd_Slot_Rec*  Lbd_Slot_P;

/* Our refinement of Obj_Header_Rec: */
struct Lbd_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj required_args;       /* Number of required args in slot[].	*/
    Vm_Obj optional_args;       /* Number of optional args in slot[].	*/
    Vm_Obj keyword_args;        /* Length of keyword  args in slot[].	*/
    Vm_Obj total_args;          /* Total              args in slot[].	*/
    Vm_Obj allow_other_keywords;/* T or NIL				*/

    Vm_Obj reserved_slot[ LBD_RESERVED_SLOTS ];

    Lbd_A_Slot slot[1];
    /* required args come first, then, optional, then keyword. */
};
typedef struct Lbd_Header_Rec Lbd_A_Header;
typedef struct Lbd_Header_Rec*  Lbd_Header;
typedef struct Lbd_Header_Rec*  Lbd_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   lbd_Startup( void              );
extern void   lbd_Linkup(  void              );
extern void   lbd_Shutdown(void              );
#ifdef OLD
extern Vm_Obj lbd_Import(   FILE* );
extern void   lbd_Export(   FILE*, Vm_Obj );
#endif


extern void lbd_For_New( Vm_Obj, Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt );

extern Obj_A_Hardcoded_Class lbd_Hardcoded_Class;
extern Obj_A_Module_Summary  lbd_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_LBD_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

