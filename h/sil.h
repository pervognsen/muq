
/*--   sil.h -- Header for sil.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_SIL_H
#define INCLUDED_SIL_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifdef TORTURE_TEST

#ifndef SIL_SLOTS
#define SIL_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#ifndef SIN_SLOTS
#define SIN_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#else

/* The following size-in-slots numbers are picked to make a full    */
/* record just less than 512 bytes, reducing internal fragmentation */
/* in our octave-based disk storage system:                         */

#ifndef SIL_SLOTS
#define SIL_SLOTS 29	/* Must be odd.	*/
#endif

#ifndef SIN_SLOTS
#define SIN_SLOTS 29	/* Must be odd.	*/
#endif

#endif

/* Basic macro to locate a node/leaf: */
#define SIN_P(o) ((Sin_Header)vm_Loc(o))
#define SIL_P(o) ((Sil_Header)vm_Loc(o))

/* This mask clears the high and low bit, leaving us with a */
/* Vm_Obj which is both positive (high bit zero) and an     */
/* integer (low bit zero):                                  */
#define SIL_TO_INT_MASK (((~((Vm_Unt)0))>>1)&~OBJ_INTMASK)


/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Sil_Slot_Rec {
    Vm_Obj   key;
    Vm_Obj   val;
};
typedef struct Sil_Slot_Rec* Sil_Slot;

struct Sin_Slot_Rec {
    Vm_Obj   key;  	/* <= all hashes in leaf    */
    Vm_Obj   leaf;
};
typedef struct Sin_Slot_Rec* Sin_Slot;

struct Sil_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Sil_Slot_Rec slot[ SIL_SLOTS ];
};
typedef struct Sil_Header_Rec Sil_A_Header;
typedef struct Sil_Header_Rec*  Sil_Header;
typedef struct Sil_Header_Rec*  Sil_P;

/* Our refinements of Obj_Header_Rec: */
struct Sin_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Sin_Slot_Rec slot[ SIN_SLOTS ];
};
typedef struct Sin_Header_Rec Sin_A_Header;
typedef struct Sin_Header_Rec*  Sin_Header;
typedef struct Sin_Header_Rec*  Sin_P;




/************************************************************************/
/*-    externs								*/

extern void	sil_Startup(  void              );
extern void	sil_Linkup(   void              );
extern void	sil_Shutdown( void              );

extern Vm_Obj	sil_Alloc(    void		);
extern Vm_Obj   sil_Copy(      Vm_Obj           );
extern Vm_Obj   sil_Hash(      Vm_Obj		);
extern Vm_Obj	sil_Get(       Vm_Obj, Vm_Obj	);
extern Vm_Obj   sil_Get_Asciz( Vm_Obj me, Vm_Uch* akey );
extern void	sil_Test(     void              );
extern Vm_Obj   sil_First( Vm_Obj		);
extern Vm_Int	sil_FirstInSubtree( Vm_Obj*, Vm_Obj );
extern Vm_Obj	sil_Set(     Vm_Obj, Vm_Obj, Vm_Obj, Vm_Unt );
extern Vm_Obj	sil_Del(  Vm_Obj, Vm_Obj 	);
extern Vm_Obj	sil_Next( Vm_Obj, Vm_Obj	);

extern void     sil_PrintNode( Vm_Obj n, Vm_Int depth );

#ifdef OLD
extern Vm_Obj   sil_Import(   FILE* );
extern void     sil_Export(   FILE*, Vm_Obj );

extern Vm_Int	sil_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	sil_Print(     FILE*,Vm_Uch*,Vm_Obj);
#endif

extern Obj_A_Module_Summary  sil_Module_Summary;

extern Obj_A_Hardcoded_Class sil_Hardcoded_Class;
extern Obj_A_Hardcoded_Class sin_Hardcoded_Class;

extern Obj_A_Hardcoded_Class pil_Hardcoded_Class;
extern Obj_A_Hardcoded_Class pin_Hardcoded_Class;



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_SIL_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

