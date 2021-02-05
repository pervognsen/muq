/*--   asm.h -- Header for asm.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_ASM_H
#define INCLUDED_ASM_H


/* Get Vm_Obj declaration: */
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate an assembler: */
#define ASM_P(o) ((Asm_Header)vm_Loc(o))

#define ASM_RESERVED_SLOTS 8


/************************************************************************/
/*-    types								*/

/* Our refinement of Obj_Header_Rec: */
struct Asm_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj  constants;	/* Constants stack			*/
    Vm_Obj  labels   ;	/* Stack of jump targets.		*/
    Vm_Obj  bytecodes;	/* Bytecodes stack			*/
    Vm_Obj  linecodes;	/* One entry for each 'bytecodes' entry.*/
    Vm_Obj  local_vars; /* One entry for each fn-local variable.*/

    Vm_Obj  fn_name;     /* Compiler-provided debug info.	*/
    Vm_Obj  file_name;   /* Compiler-provided debug info.	*/
    Vm_Obj  fn_line;     /* Compiler-provided debug info.	*/
    Vm_Obj  line_in_fn;  /* Compiler-provided debug info.	*/
    Vm_Obj  next_label;  /* Count of labels allocated.		*/
    Vm_Obj  flavor;      /* NIL :thunk :promise or :mosGeneric */
    Vm_Obj  compile_time;   /* OBJ_NIL=no. */
    Vm_Obj  please_in_line; /* OBJ_NIL=no. */
    Vm_Obj  never_in_line;  /* OBJ_NIL=no. */
    Vm_Obj  save_debug_info;/* OBJ_NIL=no. */
    Vm_Obj  reserved_slot[ ASM_RESERVED_SLOTS ];
};
typedef struct Asm_Header_Rec Asm_A_Header;
typedef struct Asm_Header_Rec*  Asm_Header;
typedef struct Asm_Header_Rec*  Asm_P;



/************************************************************************/
/*-    externs								*/

extern int     asm_Invariants(FILE*,char*,Vm_Obj);
extern void    asm_Print(     FILE*,char*,Vm_Obj);
extern void    asm_Startup(  void );
extern void    asm_Linkup(   void );
extern void    asm_Shutdown( void );
extern void    asm_Reset( Vm_Obj );

extern Vm_Int  asm_Look_Up_Primcode( Vm_Int );
extern Vm_Int  asm_Nullary_To_Buf( Vm_Uch*, Vm_Unt );
extern void    asm_Branch(Vm_Obj,Vm_Unt,Vm_Unt );
#ifdef OLD
extern Vm_Obj  asm_Build_Generic(Vm_Obj,Vm_Obj,Vm_Obj );
#endif
extern void    asm_Call(        Vm_Obj, Vm_Obj );
extern void    asm_Calla(       Vm_Obj, Vm_Obj );
extern void    asm_Const(       Vm_Obj, Vm_Obj );
extern void    asm_ConstNth(    Vm_Obj, Vm_Unt );
extern Vm_Unt  asm_ConstSlot(   Vm_Obj );
extern void    asm_Const_Asciz( Vm_Obj, Vm_Uch* );
extern Vm_Uch* asm_Sprint_Code_Disassembly( Vm_Uch*,Vm_Uch*,Vm_Uch*,Vm_Uch* );
extern Vm_Int  asm_Assemble_Instruction( Vm_Uch*, Vm_Int, Vm_Uch* );
extern Vm_Uch* asm_Disassemble_Opcode(Vm_Uch*);
extern Vm_Obj  asm_Cfn_Build(   Vm_Obj, Vm_Obj, Vm_Obj, Vm_Int );
extern Vm_Unt  asm_Var_Next(    Vm_Obj,Vm_Obj);
extern void    asm_Nullary(     Vm_Obj,Vm_Unt);
extern void    asm_Label(       Vm_Obj,Vm_Unt);
extern Vm_Unt  asm_Label_Get(   Vm_Obj       );
extern void    asm_Line_In_Fn(  Vm_Obj,Vm_Obj);
extern Vm_Int  asm_Lookup_Primcode( Vm_Int   );
extern void    asm_Var(         Vm_Obj,Vm_Unt);
extern void    asm_Var_Set(     Vm_Obj,Vm_Unt);

extern Obj_A_Hardcoded_Class asm_Hardcoded_Class;
extern Obj_A_Module_Summary  asm_Module_Summary;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_ASM_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

