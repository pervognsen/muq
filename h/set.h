
/*--   set.h -- Header for set.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_SET_H
#define INCLUDED_SET_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define SET_P(o) ((Set_Header)vm_Loc(o))

/************************************************************************/
/*-    types								*/

struct Set_Header_Rec {
    Obj_A_Header  o;
    Vm_Obj        propdir[ OBJ_PROP_MAX ];
};
typedef struct Set_Header_Rec Set_A_Header;
typedef struct Set_Header_Rec*  Set_Header;
typedef struct Set_Header_Rec*  Set_P;



/************************************************************************/
/*-    externs								*/

extern int        set_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    set_Sprint(    Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       set_Startup( void			);
extern void       set_Linkup(  void			);
extern void       set_Shutdown(void			);
#ifdef OLD
extern Vm_Obj     set_Import(   FILE* );
extern void       set_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj     set_Alloc( Vm_Unt		);
extern Vm_Obj     set_Dup(       Vm_Obj         );

extern Obj_A_Hardcoded_Class set_Hardcoded_Class;
extern Obj_A_Module_Summary  set_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_SET_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

