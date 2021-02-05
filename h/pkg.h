
/*--   pkg.h -- Header for pkg.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_PKG_H
#define INCLUDED_PKG_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define PKG_P(o) ((Pkg_Header)vm_Loc(o))

#define PKG_RESERVED_SLOTS 8

/************************************************************************/
/*-    types								*/

struct Pkg_Header_Rec {
    Obj_A_Header  o;
    Vm_Obj        nicknames;
    Vm_Obj        used_packages;
    Vm_Obj        shadowing_symbols;

    Vm_Obj        propdir[ OBJ_PROP_MAX ];

    Vm_Obj        reserved_slot[ PKG_RESERVED_SLOTS ];
};
typedef struct Pkg_Header_Rec Pkg_A_Header;
typedef struct Pkg_Header_Rec*  Pkg_Header;
typedef struct Pkg_Header_Rec*  Pkg_P;



/************************************************************************/
/*-    externs								*/

extern int        pkg_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    pkg_Sprint(    Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       pkg_Startup( void			);
extern void       pkg_Linkup(  void			);
extern void       pkg_Shutdown(void			);
#ifdef OLD
extern Vm_Obj     pkg_Import(   FILE* );
extern void       pkg_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj     pkg_Alloc( Vm_Unt		);
extern Vm_Obj     pkg_Dup(       Vm_Obj         );

extern Vm_Int     pkg_Knows_Symbol( Vm_Obj, Vm_Obj );

extern Obj_A_Hardcoded_Class pkg_Hardcoded_Class;
extern Obj_A_Module_Summary  pkg_Module_Summary;
extern Vm_Obj  pkg_X_Get_Asciz( Vm_Obj, Vm_Uch*, Vm_Int  );




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_PKG_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

