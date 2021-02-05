
/*--   hsh.h -- Header for hsh.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_HSH_H
#define INCLUDED_HSH_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define HSH_P(o) ((Hsh_Header)vm_Loc(o))

/************************************************************************/
/*-    types								*/

struct Hsh_Header_Rec {
    Obj_A_Header  o;
    Vm_Obj        propdir[ OBJ_PROP_MAX ];
};
typedef struct Hsh_Header_Rec Hsh_A_Header;
typedef struct Hsh_Header_Rec*  Hsh_Header;
typedef struct Hsh_Header_Rec*  Hsh_P;



/************************************************************************/
/*-    externs								*/

extern int        hsh_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    hsh_Sprint(    Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       hsh_Startup( void			);
extern void       hsh_Linkup(  void			);
extern void       hsh_Shutdown(void			);
#ifdef OLD
extern Vm_Obj     hsh_Import(   FILE* );
extern void       hsh_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj     hsh_Alloc( Vm_Unt		);
extern Vm_Obj     hsh_Dup(       Vm_Obj         );

extern Obj_A_Hardcoded_Class hsh_Hardcoded_Class;
extern Obj_A_Module_Summary  hsh_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_HSH_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

