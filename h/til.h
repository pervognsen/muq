
/*--   til.h -- Header for til.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_TIL_H
#define INCLUDED_TIL_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifdef TORTURE_TEST

#ifndef TIL_SLOTS
#define TIL_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#ifndef TIN_SLOTS
#define TIN_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#else

/* The following size-in-slots numbers are picked to make a full    */
/* record just less than 512 bytes, reducing internal fragmentation */
/* in our octave-based disk storage system:                         */

#ifndef TIL_SLOTS
#define TIL_SLOTS 13	/* Must be odd.	*/
#endif

#ifndef TIN_SLOTS
#define TIN_SLOTS 29	/* Must be odd.	*/
#endif

#endif

/* Basic macro to locate a node/leaf: */
#define TIN_P(o) ((Tin_Header)vm_Loc(o))
#define TIL_P(o) ((Til_Header)vm_Loc(o))

/* This mask clears the high and low bit, leaving us with a */
/* Vm_Obj which is both positive (high bit zero) and an     */
/* integer (low bit zero):                                  */
#define TIL_TO_INT_MASK (((~((Vm_Unt)0))>>1)&~OBJ_INTMASK)


/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Til_Slot_Rec {
    Vm_Obj   key;
    Vm_Obj   val;
    Vm_Obj   val2;
    Vm_Obj   val3;
};
typedef struct Til_Slot_Rec* Til_Slot;

struct Tin_Slot_Rec {
    Vm_Obj   key;  	/* <= all hashes in leaf    */
    Vm_Obj   leaf;
};
typedef struct Tin_Slot_Rec* Tin_Slot;

struct Til_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Til_Slot_Rec slot[ TIL_SLOTS ];
};
typedef struct Til_Header_Rec Til_A_Header;
typedef struct Til_Header_Rec*  Til_Header;
typedef struct Til_Header_Rec*  Til_P;

/* Our refinements of Obj_Header_Rec: */
struct Tin_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Tin_Slot_Rec slot[ TIN_SLOTS ];
};
typedef struct Tin_Header_Rec Tin_A_Header;
typedef struct Tin_Header_Rec*  Tin_Header;
typedef struct Tin_Header_Rec*  Tin_P;




/************************************************************************/
/*-    externs								*/

extern void	til_Startup(  void              );
extern void	til_Linkup(   void              );
extern void	til_Shutdown( void              );

extern Vm_Obj	til_Alloc(    void		);
extern Vm_Obj   til_Copy(      Vm_Obj           );
extern Vm_Obj   til_Hash(      Vm_Obj		);
extern Vm_Obj	til_Get(Vm_Obj*,Vm_Obj*, Vm_Obj, Vm_Obj	);
extern void     til_Mark(     Vm_Obj            );
extern void     tin_Mark(     Vm_Obj            );
extern void	til_Test(     void              );
extern Vm_Obj   til_First(    Vm_Obj		);
extern Vm_Int	til_FirstInSubtree( Vm_Obj*, Vm_Obj );
extern Vm_Obj	til_Set(     Vm_Obj, Vm_Obj, Vm_Obj, Vm_Obj, Vm_Obj, Vm_Unt );
extern Vm_Obj	til_Del(  Vm_Obj, Vm_Obj 	);
extern Vm_Obj	til_Next( Vm_Obj, Vm_Obj	);
#ifdef OLD
extern Vm_Obj   til_Import(   FILE* );
extern void     til_Export(   FILE*, Vm_Obj );

extern Vm_Int	til_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	til_Print(     FILE*,Vm_Uch*,Vm_Obj);
#endif

extern Obj_A_Module_Summary  til_Module_Summary;
extern Obj_A_Hardcoded_Class til_Hardcoded_Class;
extern Obj_A_Hardcoded_Class tin_Hardcoded_Class;



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_TIL_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

