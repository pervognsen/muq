/*--   clo.h -- Header for clo.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_CLO_H
#define INCLUDED_CLO_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a CLOS object: */
#define CLO_P(o) ((Clo_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, structs have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* struct contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct Clo_Header_Rec {
    Vm_Obj key;		/* Pointer to mos class key.	*/
    Vm_Obj slot[1];	/* Array of slot values.	*/
};
typedef struct Clo_Header_Rec Clo_A_Header;
typedef struct Clo_Header_Rec*  Clo_Header;
typedef struct Clo_Header_Rec*  Clo_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    clo_Invariants(FILE*,char*,Vm_Obj);
extern void   clo_Print(     FILE*,char*,Vm_Obj);
extern void   clo_Startup( void              );
extern void   clo_Linkup(  void              );
extern void   clo_Shutdown(void              );

extern Vm_Obj clo_Alloc(      Vm_Obj        	    );
extern Vm_Obj clo_Dup(        Vm_Obj		    );
extern Vm_Obj clo_Dup_Est(    Vm_Obj		    );
extern Vm_Int clo_Len(        Vm_Obj		    );
extern void   clo_Set(        Vm_Obj, Vm_Unt, Vm_Obj);

extern Vm_Obj clo_Get(        Vm_Obj, Vm_Unt	    );

extern Obj_A_Type_Summary    clo_Type_Summary;
extern Obj_A_Module_Summary  clo_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_CLO_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

