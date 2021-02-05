
/*--   fun.h -- Header for fun.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_FUN_H
#define INCLUDED_FUN_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a function: */
#define FUN_P(o) ((Fun_Header)vm_Loc(o))

#include "fun2.h"

#define FUN_RESERVED_SLOTS 4

/************************************************************************/
/*-    types								*/

/* Our refinement of Obj_Header_Rec: */
struct Fun_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj compiler;
    Vm_Obj source;
    Vm_Obj doc;
    Vm_Obj executable;
    Vm_Obj arity;
    Vm_Obj file_name;	/* Source file function was compiled from.	*/
    Vm_Obj fn_line;	/* Line number in above on which fn started.	*/
    Vm_Obj line_numbers;/* Vector of line numbers for each bytecode.	*/
			/* 'line_numbers' is relative to line_number:	*/
			/* Bytecodes on first line in fn are line 0.	*/

    Vm_Obj local_variable_names;/* Vector of names of local vars in fn.	*/

    Vm_Obj specialized_parameters;
    Vm_Obj default_methods;	/* NIL or a mosKey for methods which	*/
				/* have t as specializer for first arg.	*/

    Vm_Obj  reserved_slot[ FUN_RESERVED_SLOTS ];
};
typedef struct Fun_Header_Rec Fun_A_Header;
typedef struct Fun_Header_Rec*  Fun_Header;
typedef struct Fun_Header_Rec*  Fun_P;



/************************************************************************/
/*-    externs								*/

extern int     fun_Invariants(FILE*,char*,Vm_Obj);
extern Vm_Uch* fun_Sprint(    Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void    fun_Startup(   void              );
extern void    fun_Linkup(    void              );
extern void    fun_Shutdown(  void              );
#ifdef OLD
extern Vm_Obj  fun_Import(   FILE* );
extern void    fun_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Uch* fun_Type(    Vm_Int);
extern Vm_Uch* fun_TypeName(Vm_Int);
extern Obj_A_Hardcoded_Class fun_Hardcoded_Class;
extern Obj_A_Module_Summary  fun_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_FUN_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

