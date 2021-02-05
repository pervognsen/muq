/*--   stc.h -- Header for stc.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_STC_H
#define INCLUDED_STC_H


#include <stdio.h>
#include "vm.h"
#include "obj.h"


/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a struct: */
#define STC_P(o) ((Stc_Header)vm_Loc(o))



/************************************************************************/
/*-    types								*/

/* In at least some implementations, structs have	*/
/* header information in addition to just an array of	*/
/* Vm_Obj slots.  By always using a struct to access	*/
/* struct contents, we make it fairly easy to compile	*/
/* code with or without such overhead:			*/
struct Stc_Header_Rec {
    Vm_Obj is_a;	/* Pointer to struct definition.	*/
    Vm_Obj slot[1];	/* Array of struct values.		*/
};
typedef struct Stc_Header_Rec Stc_A_Header;
typedef struct Stc_Header_Rec*  Stc_Header;
typedef struct Stc_Header_Rec*  Stc_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    externs								*/

extern int    stc_Invariants(FILE*,char*,Vm_Obj);
extern void   stc_Print(     FILE*,char*,Vm_Obj);
extern void   stc_Startup( void              );
extern void   stc_Linkup(  void              );
extern void   stc_Shutdown(void              );

extern Vm_Obj stc_Alloc(      Vm_Obj        	    );
extern Vm_Obj stc_Dup(        Vm_Obj		    );
extern Vm_Obj stc_Dup_Est(    Vm_Obj		    );
extern Vm_Int stc_Len(        Vm_Obj		    );
extern void   stc_Set(        Vm_Obj, Vm_Unt, Vm_Obj);

#ifdef UNUSED
extern Vm_Obj stc_Get(        Vm_Obj, Vm_Unt	    );
#endif

extern Obj_A_Type_Summary    stc_Type_Summary;
extern Obj_A_Module_Summary  stc_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_STC_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

