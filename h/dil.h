
/*--   dil.h -- Header for dil.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_DIL_H
#define INCLUDED_DIL_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifdef TORTURE_TEST

#ifndef DIL_SLOTS
#define DIL_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#ifndef DIN_SLOTS
#define DIN_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#else

/* The following size-in-slots numbers are picked to make a full    */
/* record just less than 512 bytes, reducing internal fragmentation */
/* in our octave-based disk storage system:                         */

#ifndef DIL_SLOTS
#define DIL_SLOTS 19	/* Must be odd.	*/
#endif

#ifndef DIN_SLOTS
#define DIN_SLOTS 29	/* Must be odd.	*/
#endif

#endif

/* Basic macro to locate a node/leaf: */
#define DIN_P(o) ((Din_Header)vm_Loc(o))
#define DIL_P(o) ((Dil_Header)vm_Loc(o))

/* This mask clears the high and low bit, leaving us with a */
/* Vm_Obj which is both positive (high bit zero) and an     */
/* integer (low bit zero):                                  */
#define DIL_TO_INT_MASK (((~((Vm_Unt)0))>>1)&~OBJ_INTMASK)


/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Dil_Slot_Rec {
    Vm_Obj   hash;  	/* Integer hash of next.    */
    Vm_Obj   key;
    Vm_Obj   val;
};
typedef struct Dil_Slot_Rec* Dil_Slot;

struct Din_Slot_Rec {
    Vm_Obj   hash;  	/* <= all hashes in leaf    */
    Vm_Obj   leaf;
};
typedef struct Din_Slot_Rec* Din_Slot;

struct Dil_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Dil_Slot_Rec slot[ DIL_SLOTS ];
};
typedef struct Dil_Header_Rec Dil_A_Header;
typedef struct Dil_Header_Rec*  Dil_Header;
typedef struct Dil_Header_Rec*  Dil_P;

/* Our refinements of Obj_Header_Rec: */
struct Din_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct Din_Slot_Rec slot[ DIN_SLOTS ];
};
typedef struct Din_Header_Rec Din_A_Header;
typedef struct Din_Header_Rec*  Din_Header;
typedef struct Din_Header_Rec*  Din_P;




/************************************************************************/
/*-    externs								*/

/*buggo: temp debug hack: */extern int dil_debug;

extern void	dil_Startup(  void              );
extern void	dil_Linkup(   void              );
extern void	dil_Shutdown( void              );

extern Vm_Obj	dil_Alloc(    void		);
extern Vm_Obj   dil_Copy(      Vm_Obj           );
extern Vm_Obj   dil_Hash(      Vm_Obj		);
extern Vm_Obj	dil_Get(       Vm_Obj, Vm_Obj	);
extern Vm_Obj   dil_Get_Asciz( Vm_Obj me, Vm_Uch* akey );
extern void	dil_Test(     void              );
extern Vm_Obj   dil_First( Vm_Obj		);
extern Vm_Int	dil_FirstInSubtree( Vm_Obj*, Vm_Obj );
extern Vm_Obj	dil_Set(     Vm_Obj, Vm_Obj, Vm_Obj, Vm_Unt );
extern Vm_Obj	dil_Del(  Vm_Obj, Vm_Obj 	);
extern Vm_Obj	dil_Next( Vm_Obj, Vm_Obj	);
#ifdef OLD
extern Vm_Obj   dil_Import(   FILE* );
extern void     dil_Export(   FILE*, Vm_Obj );

extern Vm_Int	dil_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	dil_Print(     FILE*,Vm_Uch*,Vm_Obj);
#endif

extern Obj_A_Module_Summary  dil_Module_Summary;
extern Obj_A_Hardcoded_Class dil_Hardcoded_Class;
extern Obj_A_Hardcoded_Class din_Hardcoded_Class;



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_DIL_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

