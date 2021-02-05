
/*--   sym.h -- Header for sym.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_SYM_H
#define INCLUDED_SYM_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define SYM_P(o) ((Sym_Header)vm_Loc(o))

/* Special value stored in sym->function */
/* to flag it as being a constant:       */
#define SYM_CONSTANT_FLAG OBJ_FROM_INT(0)

/* Test whether symbol is a constant: */
#define SYM_IS_CONSTANT(sym) (SYM_P(sym)->function==SYM_CONSTANT_FLAG)



/************************************************************************/
/*-    types								*/

struct Sym_Header_Rec {
    Vm_Obj     package;	/* Needed to print out symbol properly.	   */
    Vm_Obj     value;
    Vm_Obj     function;
    Vm_Obj     name;
    /* NB: Two additional virtual fields are supported: */
    /* 'type' and 'proplist'.  To save space, they are  */
    /* stored in btrees hung off the relevant dbf obj.  */
};
typedef struct Sym_Header_Rec Sym_A_Header;
typedef struct Sym_Header_Rec*  Sym_Header;
typedef struct Sym_Header_Rec*  Sym_P;



/************************************************************************/
/*-    externs								*/

extern void       sym_Startup( void			);
extern void       sym_Linkup(  void			);
extern void       sym_Shutdown(void			);

extern Vm_Obj     sym_Make(             void            );
extern Vm_Obj     sym_Alloc(		Vm_Obj,Vm_Obj	);
extern Vm_Obj     sym_Alloc_Asciz(Vm_Obj,Vm_Uch*,Vm_Obj	);
extern Vm_Obj     sym_Alloc_Keyword(      Vm_Obj        );
extern Vm_Obj     sym_Alloc_Asciz_Keyword(Vm_Uch*	);
extern Vm_Obj     sym_Alloc_Full_Asciz( Vm_Obj,Vm_Uch*  );
extern Vm_Obj     sym_Find(               Vm_Obj,Vm_Obj	);
extern Vm_Obj	  sym_Find_Asciz(         Vm_Obj,Vm_Uch*);
extern Vm_Obj     sym_Find_Exported(      Vm_Obj,Vm_Obj );
extern Vm_Obj	  sym_Find_Exported_Asciz(Vm_Obj,Vm_Uch*);

extern Vm_Obj     sym_Proplist(Vm_Obj);
extern void       sym_Set_Proplist(Vm_Obj,Vm_Obj);
extern Vm_Obj     sym_Type(Vm_Obj);
extern void       sym_Set_Type(Vm_Obj,Vm_Obj);

extern Obj_A_Type_Summary   sym_Type_Summary;
extern Obj_A_Module_Summary sym_Module_Summary;



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_SYM_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

