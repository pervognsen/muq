
/*--   n3d.h -- Header for n3d.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_N3D_H
#define INCLUDED_N3D_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define N3D_P(o) ((N3d_Header)vm_Loc(o))

/************************************************************************/
/*-    types								*/

struct N3d_Header_Rec {
    Obj_A_Header  o;
    Vm_Obj        propdir[ OBJ_PROP_MAX ];
    Vm_Obj        rtree;
    Vm_Obj        reserved1;
    Vm_Obj        reserved2;
};
typedef struct N3d_Header_Rec N3d_A_Header;
typedef struct N3d_Header_Rec*  N3d_Header;
typedef struct N3d_Header_Rec*  N3d_P;



/************************************************************************/
/*-    externs								*/

extern int        n3d_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    n3d_Sprint(    Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       n3d_Startup( void			);
extern void       n3d_Linkup(  void			);
extern void       n3d_Shutdown(void			);
#ifdef OLD
extern Vm_Obj     n3d_Import(   FILE* );
extern void       n3d_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj     n3d_Alloc( Vm_Unt		);
extern Vm_Obj     n3d_Dup(       Vm_Obj         );

extern Obj_A_Hardcoded_Class n3d_Hardcoded_Class;
extern Obj_A_Module_Summary  n3d_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_N3D_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

