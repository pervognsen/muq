
/*--   cfg.h -- Header for cfg.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_CFG_H
#define INCLUDED_CFG_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define CFG_P(o) ((Cfg_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

struct Cfg_Header_Rec {
    Obj_A_Header	o;
};
typedef struct Cfg_Header_Rec Cfg_A_Header;
typedef struct Cfg_Header_Rec*  Cfg_Header;
typedef struct Cfg_Header_Rec*  Cfg_P;



/************************************************************************/
/*-    externs								*/

extern int        cfg_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    cfg_Sprint(  Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       cfg_Startup( void			);
extern void       cfg_Linkup(  void			);
extern void       cfg_Shutdown(void			);
#ifdef SOON
extern Vm_Obj     cfg_Import(   FILE* );
extern void       cfg_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj     cfg_Alloc( Vm_Unt		);
extern Vm_Obj     cfg_Dup(       Vm_Obj         );

extern Obj_A_Hardcoded_Class cfg_Hardcoded_Class;
extern Obj_A_Module_Summary  cfg_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_CFG_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

