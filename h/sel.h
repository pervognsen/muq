				   
/*--   sel.h -- Header for sel.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_SEL_H
#define INCLUDED_SEL_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifdef TORTURE_TEST

#ifndef SEL_SLOTS
#define SEL_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#ifndef SEN_SLOTS
#define SEN_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#else

/* The following size-in-slots numbers are picked to make a full    */
/* record just less than 512 bytes, reducing internal fragmentation */
/* in our octave-based disk storage system:                         */

#ifndef SEL_SLOTS
#define SEL_SLOTS 59	/* Must be odd.	*/
#endif

#ifndef SEN_SLOTS
#define SEN_SLOTS 29	/* Must be odd.	*/
#endif

#endif

/* Basic macro to locate a node/leaf: */
#define SEN_P(o) ((Sen_Header)vm_Loc(o))
#define SEL_P(o) ((Sel_Header)vm_Loc(o))

/* This mask clears the high and low bit, leaving us with a */
/* Vm_Obj which is both positive (high bit zero) and an     */
/* integer (low bit zero):                                  */
#define SEL_TO_INT_MASK (((~((Vm_Unt)0))>>1)&~OBJ_INTMASK)


/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Sel_Slot_Rec {
    Vm_Obj   key;
#ifdef OLD
    Vm_Obj   val;
#endif
};
typedef struct Sel_Slot_Rec* Sel_Slot;

struct Sen_Slot_Rec {
    Vm_Obj   key;  	/* <= all hashes in leaf    */
    Vm_Obj   leaf;
};
typedef struct Sen_Slot_Rec* Sen_Slot;

struct Sel_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Sel_Slot_Rec slot[ SEL_SLOTS ];
};
typedef struct Sel_Header_Rec Sel_A_Header;
typedef struct Sel_Header_Rec*  Sel_Header;
typedef struct Sel_Header_Rec*  Sel_P;

/* Our refinements of Obj_Header_Rec: */
struct Sen_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Sen_Slot_Rec slot[ SEN_SLOTS ];
};
typedef struct Sen_Header_Rec Sen_A_Header;
typedef struct Sen_Header_Rec*  Sen_Header;
typedef struct Sen_Header_Rec*  Sen_P;




/************************************************************************/
/*-    externs								*/

extern void	sel_Startup(  void              );
extern void	sel_Linkup(   void              );
extern void	sel_Shutdown( void              );

extern Vm_Obj	sel_Alloc(    void		);
extern Vm_Obj   sel_Copy(      Vm_Obj           );
extern Vm_Obj   sel_Hash(      Vm_Obj		);
extern Vm_Obj	sel_Get(       Vm_Obj, Vm_Obj	);
extern Vm_Obj   sel_Get_Asciz( Vm_Obj me, Vm_Uch* akey );
extern void	sel_Test(     void              );
extern Vm_Obj   sel_First( Vm_Obj		);
extern Vm_Int	sel_FirstInSubtree( Vm_Obj*, Vm_Obj );
extern Vm_Obj	sel_Set(     Vm_Obj, Vm_Obj, Vm_Obj, Vm_Unt );
extern Vm_Obj	sel_Del(  Vm_Obj, Vm_Obj 	);
extern Vm_Obj	sel_Next( Vm_Obj, Vm_Obj	);
#ifdef OLD
extern Vm_Obj   sel_Import(   FILE* );
extern void     sel_Export(   FILE*, Vm_Obj );

extern Vm_Int	sel_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	sel_Print(     FILE*,Vm_Uch*,Vm_Obj);
#endif

extern Obj_A_Module_Summary  sel_Module_Summary;
extern Obj_A_Hardcoded_Class sel_Hardcoded_Class;
extern Obj_A_Hardcoded_Class sen_Hardcoded_Class;



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_SEL_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

