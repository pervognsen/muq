
/*--   mil.h -- Header for mil.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_MIL_H
#define INCLUDED_MIL_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifdef TORTURE_TEST

#ifndef MIL_SLOTS
#define MIL_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#ifndef MIN_SLOTS
#define MIN_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#else

/* The following size-in-slots numbers are picked to make a full    */
/* record just less than 512 bytes, reducing internal fragmentation */
/* in our octave-based disk storage system:                         */

#ifndef MIL_SLOTS
#define MIL_SLOTS 29	/* Must be odd.	*/
#endif

#ifndef MIN_SLOTS
#define MIN_SLOTS 29	/* Must be odd.	*/
#endif

#endif

/* Basic macro to locate a node/leaf: */
#define MIN_P(o) ((Min_Header)vm_Loc(o))
#define MIL_P(o) ((Mil_Header)vm_Loc(o))

/* This mask clears the high and low bit, leaving us with a */
/* Vm_Obj which is both positive (high bit zero) and an     */
/* integer (low bit zero):                                  */
#define MIL_TO_INT_MASK (((~((Vm_Unt)0))>>1)&~OBJ_INTMASK)


/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Mil_Slot_Rec {
    Vm_Obj   key;
    Vm_Obj   val;
};
typedef struct Mil_Slot_Rec* Mil_Slot;

struct Min_Slot_Rec {
    Vm_Obj   key;  	/* <= all hashes in leaf    */
    Vm_Obj   leaf;
};
typedef struct Min_Slot_Rec* Min_Slot;

struct Mil_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Mil_Slot_Rec slot[ MIL_SLOTS ];
};
typedef struct Mil_Header_Rec Mil_A_Header;
typedef struct Mil_Header_Rec*  Mil_Header;
typedef struct Mil_Header_Rec*  Mil_P;

/* Our refinements of Obj_Header_Rec: */
struct Min_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Min_Slot_Rec slot[ MIN_SLOTS ];
};
typedef struct Min_Header_Rec Min_A_Header;
typedef struct Min_Header_Rec*  Min_Header;
typedef struct Min_Header_Rec*  Min_P;




/************************************************************************/
/*-    externs								*/

extern void	mil_Startup(  void              );
extern void	mil_Linkup(   void              );
extern void	mil_Shutdown( void              );

extern Vm_Obj	mil_Alloc(    void		);
extern Vm_Obj   mil_Copy(      Vm_Obj           );
extern Vm_Obj   mil_Hash(      Vm_Obj		);
extern Vm_Obj	mil_Get(Vm_Obj, Vm_Obj	);
extern void     mil_Mark(     Vm_Obj            );
extern void     min_Mark(     Vm_Obj            );
extern void	mil_Test(     void              );
extern Vm_Obj   mil_First(    Vm_Obj		);
extern Vm_Int	mil_FirstInSubtree( Vm_Obj*, Vm_Obj );
extern Vm_Obj	mil_Set(     Vm_Obj, Vm_Obj,Vm_Obj, Vm_Unt );
extern Vm_Obj	mil_Del(  Vm_Obj, Vm_Obj 	);
extern Vm_Obj	mil_Next( Vm_Obj, Vm_Obj	);
#ifdef OLD
extern Vm_Obj   mil_Import(   FILE* );
extern void     mil_Export(   FILE*, Vm_Obj );

extern Vm_Int	mil_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	mil_Print(     FILE*,Vm_Uch*,Vm_Obj);
#endif

extern Obj_A_Module_Summary  mil_Module_Summary;
extern Obj_A_Hardcoded_Class mil_Hardcoded_Class;
extern Obj_A_Hardcoded_Class min_Hardcoded_Class;



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_MIL_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

