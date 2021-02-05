
/*--   ndx.h -- Header for ndx.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_NDX_H
#define INCLUDED_NDX_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define NDX_P(o) ((Ndx_Header)vm_Loc(o))

/************************************************************************/
/*-    types								*/

struct Ndx_Header_Rec {
    Obj_A_Header  o;
    Vm_Obj        propdir[ OBJ_PROP_MAX ];
};
typedef struct Ndx_Header_Rec Ndx_A_Header;
typedef struct Ndx_Header_Rec*  Ndx_Header;
typedef struct Ndx_Header_Rec*  Ndx_P;



/************************************************************************/
/*-    externs								*/

extern int        ndx_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    ndx_Sprint(    Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       ndx_Startup( void			);
extern void       ndx_Linkup(  void			);
extern void       ndx_Shutdown(void			);
#ifdef OLD
extern Vm_Obj     ndx_Import(   FILE* );
extern void       ndx_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj     ndx_Alloc( Vm_Unt		);
extern Vm_Obj     ndx_Dup(       Vm_Obj         );

extern Obj_A_Hardcoded_Class ndx_Hardcoded_Class;
extern Obj_A_Module_Summary  ndx_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_NDX_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

