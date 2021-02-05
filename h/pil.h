
/*--   pil.h -- Header for pil.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_PIL_H
#define INCLUDED_PIL_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifdef TORTURE_TEST

#ifndef PIL_SLOTS
#define PIL_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#ifndef PIN_SLOTS
#define PIN_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#else

/* The following size-in-slots numbers are picked to make a full    */
/* record just less than 512 bytes, reducing internal fragmentation */
/* in our octave-based disk storage system:                         */

#ifndef PIL_SLOTS
#define PIL_SLOTS 29	/* Must be odd.	*/
#endif

#ifndef PIN_SLOTS
#define PIN_SLOTS 29	/* Must be odd.	*/
#endif

#endif

/* Basic macro to locate a node/leaf: */
#define PIN_P(o) ((Pin_Header)vm_Loc(o))
#define PIL_P(o) ((Pil_Header)vm_Loc(o))

/* This mask clears the high and low bit, leaving us with a */
/* Vm_Obj which is both positive (high bit zero) and an     */
/* integer (low bit zero):                                  */
#define PIL_TO_INT_MASK (((~((Vm_Unt)0))>>1)&~OBJ_INTMASK)


/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Pil_Slot_Rec {
    Vm_Obj   key;
    Vm_Obj   val;
};
typedef struct Pil_Slot_Rec* Pil_Slot;

struct Pin_Slot_Rec {
    Vm_Obj   key;  	/* <= all hashes in leaf    */
    Vm_Obj   leaf;
};
typedef struct Pin_Slot_Rec* Pin_Slot;

struct Pil_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Pil_Slot_Rec slot[ PIL_SLOTS ];
};
typedef struct Pil_Header_Rec Pil_A_Header;
typedef struct Pil_Header_Rec*  Pil_Header;
typedef struct Pil_Header_Rec*  Pil_P;

/* Our refinements of Obj_Header_Rec: */
struct Pin_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Pin_Slot_Rec slot[ PIN_SLOTS ];
};
typedef struct Pin_Header_Rec Pin_A_Header;
typedef struct Pin_Header_Rec*  Pin_Header;
typedef struct Pin_Header_Rec*  Pin_P;




/************************************************************************/
/*-    externs								*/

extern void	pil_Startup(  void              );
extern void	pil_Linkup(   void              );
extern void	pil_Shutdown( void              );

extern Vm_Obj	pil_Alloc(    void		);
extern Vm_Obj   pil_Copy(      Vm_Obj           );
extern Vm_Obj   pil_Hash(      Vm_Obj		);
extern void     pil_Mark(     Vm_Obj            );
extern void     pin_Mark(     Vm_Obj            );
extern Vm_Obj	pil_Get(       Vm_Obj, Vm_Obj	);
extern void	pil_Test(     void              );
extern Vm_Obj   pil_First( Vm_Obj		);
extern Vm_Int	pil_FirstInSubtree( Vm_Obj*, Vm_Obj );
extern Vm_Obj	pil_Set(     Vm_Obj, Vm_Obj, Vm_Obj, Vm_Unt );
extern Vm_Obj	pil_Del(  Vm_Obj, Vm_Obj 	);
extern Vm_Obj	pil_Next( Vm_Obj, Vm_Obj	);
#ifdef OLD
extern Vm_Obj   pil_Import(   FILE* );
extern void     pil_Export(   FILE*, Vm_Obj );

extern Vm_Int	pil_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	pil_Print(     FILE*,Vm_Uch*,Vm_Obj);
#endif

extern Obj_A_Module_Summary  pil_Module_Summary;

extern Obj_A_Hardcoded_Class pil_Hardcoded_Class;
extern Obj_A_Hardcoded_Class pin_Hardcoded_Class;




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_PIL_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

