
/*--   lst.h -- Header for lst.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_LST_H
#define INCLUDED_LST_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a cons cell: */
#define LST_P(o) ((Lst_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

struct Lst_Header_Rec {
    Vm_Obj     car;
    Vm_Obj     cdr;
};
typedef struct Lst_Header_Rec Lst_A_Header;
typedef struct Lst_Header_Rec*  Lst_Header;
typedef struct Lst_Header_Rec*  Lst_P;



/************************************************************************/
/*-    externs								*/

extern void       lst_Startup( void			);
extern void       lst_Linkup(  void			);
extern void       lst_Shutdown(void			);

extern Vm_Obj     lst_Alloc( Vm_Obj, Vm_Obj		);

extern Obj_A_Type_Summary   lst_Type_Summary;
extern Obj_A_Module_Summary lst_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_LST_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

