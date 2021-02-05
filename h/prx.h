
/*--   prx.h -- Header for prx.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_PRX_H
#define INCLUDED_PRX_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a prx: */
#define PRX_P(o) ((Prx_Header)vm_Loc(o))

#define PRX_RESERVED_SLOTS 2

/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Our refinement of Obj_Header_Rec: */
struct Prx_Header_Rec {
    Obj_A_Header o;

    /* Owner of proxied object, a Guest object: */
    Vm_Obj guest;

    /* Dbref of proxied object, */
    /* as 3 fixnum integer, in	*/
    /* dbrefToInts3 format:   */
    Vm_Obj i0;
    Vm_Obj i1;
    Vm_Obj i2;

    /* We may wish to put type information here sometime, say: */
    Vm_Obj reserved_slot[ PRX_RESERVED_SLOTS ];
};
typedef struct Prx_Header_Rec Prx_A_Header;
typedef struct Prx_Header_Rec*  Prx_Header;
typedef struct Prx_Header_Rec*  Prx_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   prx_Startup( void              );
extern void   prx_Linkup(  void              );
extern void   prx_Shutdown(void              );
#ifdef OLD
extern Vm_Obj prx_Import(   FILE* );
extern void   prx_Export(   FILE*, Vm_Obj );
#endif

extern Obj_A_Hardcoded_Class prx_Hardcoded_Class;
extern Obj_A_Module_Summary  prx_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_PRX_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

