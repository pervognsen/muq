
/*--   d3l.h -- Header for d3l.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_D3L_H
#define INCLUDED_D3L_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifdef TORTURE_TEST

#ifndef D3L_SLOTS
#define D3L_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#ifndef D3N_SLOTS
#define D3N_SLOTS 5	/* Intended to torture-test the code more extensively.	*/
#endif

#else

/* The following size-in-slots numbers are picked to make a full    */
/* record just less than 512 bytes, reducing internal fragmentation */
/* in our octave-based disk storage system:                         */

#ifndef D3L_SLOTS
#define D3L_SLOTS 19	/* Must be odd.	*/
#endif

#ifndef D3N_SLOTS
#define D3N_SLOTS 29	/* Must be odd.	*/
#endif

#endif

/* Basic macro to locate a node/leaf: */
#define D3N_P(o) ((D3n_Header)vm_Loc(o))
#define D3L_P(o) ((D3l_Header)vm_Loc(o))

/************************************************************************/
/*-    types								*/
/************************************************************************/

struct D3l_Sphere_Rec {
    Vm_Obj   x;		/* Center of bounding sphere, x coord	*/
    Vm_Obj   y;		/* Center of bounding sphere, y coord	*/
    Vm_Obj   z;		/* Center of bounding sphere, z coord	*/
    Vm_Obj   r;		/* Radius of bounding sphere		*/
};
struct D3l_Slot_Rec {
    Vm_Obj                val;
    struct D3l_Sphere_Rec s;
};
typedef struct D3l_Slot_Rec* D3l_Slot;

struct D3n_Slot_Rec {
    Vm_Obj                leaf;
    struct D3l_Sphere_Rec s;
};
typedef struct D3n_Slot_Rec* D3n_Slot;

struct D3l_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct D3l_Slot_Rec slot[ D3L_SLOTS ];
};
typedef struct D3l_Header_Rec D3l_A_Header;
typedef struct D3l_Header_Rec*  D3l_Header;
typedef struct D3l_Header_Rec*  D3l_P;

/* Our refinements of Obj_Header_Rec: */
struct D3n_Header_Rec {
    Obj_A_Header	o;
    Vm_Obj 		slots_used;
    struct D3n_Slot_Rec slot[ D3N_SLOTS ];
};
typedef struct D3n_Header_Rec D3n_A_Header;
typedef struct D3n_Header_Rec*  D3n_Header;
typedef struct D3n_Header_Rec*  D3n_P;




/************************************************************************/
/*-    externs								*/

/*buggo: temp debug hack: */extern int d3l_debug;

extern void	d3l_Startup(  void              );
extern void	d3l_Linkup(   void              );
extern void	d3l_Shutdown( void              );

extern Vm_Obj	d3l_Alloc(    void		);
extern Vm_Obj   d3l_Copy(      Vm_Obj           );
extern Vm_Obj   d3l_Hash(      Vm_Obj		);
extern Vm_Obj	d3l_Get(       Vm_Obj, Vm_Obj	);
extern Vm_Obj   d3l_Get_Asciz( Vm_Obj me, Vm_Uch* akey );
extern void	d3l_Test(     void              );
extern Vm_Obj   d3l_First( Vm_Obj		);
extern Vm_Int	d3l_FirstInSubtree( Vm_Obj*, Vm_Obj );
extern Vm_Obj	d3l_Set(     Vm_Obj, Vm_Obj, Vm_Obj, Vm_Unt );
extern Vm_Obj	d3l_Del(  Vm_Obj, Vm_Obj 	);
extern Vm_Obj	d3l_Next( Vm_Obj, Vm_Obj	);
#ifdef OLD
extern Vm_Obj   d3l_Import(   FILE* );
extern void     d3l_Export(   FILE*, Vm_Obj );

extern Vm_Int	d3l_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void	d3l_Print(     FILE*,Vm_Uch*,Vm_Obj);
#endif

extern Obj_A_Module_Summary  d3l_Module_Summary;
extern Obj_A_Hardcoded_Class d3l_Hardcoded_Class;
extern Obj_A_Hardcoded_Class d3n_Hardcoded_Class;



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_D3L_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

