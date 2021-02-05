
/*--   cdf.h -- Header for cdf.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_CDF_H
#define INCLUDED_CDF_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a cdf: */
#define CDF_P(o) ((Cdf_Header)vm_Loc(o))


/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Our refinement of Obj_Header_Rec: */
struct Cdf_Header_Rec {
    Obj_A_Header	o;

    /* Included to be parallel with fun.h: */
    Vm_Obj key;
};
typedef struct Cdf_Header_Rec Cdf_A_Header;
typedef struct Cdf_Header_Rec*  Cdf_Header;
typedef struct Cdf_Header_Rec*  Cdf_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   cdf_Startup( void              );
extern void   cdf_Linkup(  void              );
extern void   cdf_Shutdown(void              );
#ifdef OLD
extern Vm_Obj cdf_Import(   FILE* );
extern void   cdf_Export(   FILE*, Vm_Obj );
#endif

extern void   cdf_Release( Vm_Obj );
extern void   cdf_Reset( Vm_Obj );
extern void   cdf_Maybe_SendSleep_Job( Vm_Obj );

extern Obj_A_Hardcoded_Class cdf_Hardcoded_Class;
extern Obj_A_Module_Summary  cdf_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_CDF_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

