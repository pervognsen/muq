
/*--   gfg.h -- Header for gfg.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_GFG_H
#define INCLUDED_GFG_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a gfg: */
#define GFG_P(o) ((Gfg_Header)vm_Loc(o))

/* Maximum supported number of slots in a struct: */
#ifndef GFG_MAX_SLOTS
#define GFG_MAX_SLOTS ((Vm_Unt)1024)
#endif

/* Maximum supported depth of :include nesting: */
#ifndef GFG_MAX_INCLUDE_DEPTH
#define GFG_MAX_INCLUDE_DEPTH ((Vm_Unt)128)
#endif

/* Bits for the Slot->flags field: */
#define GFG_FLAG_ROOT_MAY_READ    OBJ_FROM_INT(1)
#define GFG_FLAG_ROOT_MAY_WRITE   OBJ_FROM_INT(2)
#define GFG_FLAG_USER_MAY_READ    OBJ_FROM_INT(4)
#define GFG_FLAG_USER_MAY_WRITE   OBJ_FROM_INT(8)
#define GFG_FLAG_AUTHOR_MAY_READ  OBJ_FROM_INT(16)
#define GFG_FLAG_AUTHOR_MAY_WRITE OBJ_FROM_INT(32)
#define GFG_FLAG_WORLD_MAY_READ   OBJ_FROM_INT(64)
#define GFG_FLAG_WORLD_MAY_WRITE  OBJ_FROM_INT(128)
#define GFG_FLAG_SHARED           OBJ_FROM_INT(256)
#define GFG_FLAG_INHERITED        OBJ_FROM_INT(512)
/* Note: If a slot is SHARED, it may also be  */
/* INHERITED, in which case the 'value' field */
/* points to the class with the slot, rather  */
/* instead of holding the slot value proper.  */

#ifndef GFG_FLAGS_DEFAULT
#define GFG_FLAGS_DEFAULT (	 \
	GFG_FLAG_ROOT_MAY_READ  |\
	GFG_FLAG_ROOT_MAY_WRITE |\
	GFG_FLAG_USER_MAY_READ  |\
	GFG_FLAG_USER_MAY_WRITE |\
        GFG_FLAG_WORLD_MAY_READ );
#endif

/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Gfg_Slot_Rec {
    Vm_Obj keyword;	/* Keyword with name of slot.	*/
    Vm_Obj initform;	/* Default value for slot.	*/
    Vm_Obj type;	/* Currently ignored.		*/
    Vm_Obj documentation;/* Documentation on slot.	*/
    Vm_Obj flags;	/* See GFG_FLAG_* #defines	*/
    Vm_Obj get_function;/* Fn to read this slot.	*/
    Vm_Obj set_function;/* Fn to write this slot.	*/
    Vm_Obj value;	/* Value of slot, if shared.	*/
};
typedef struct Gfg_Slot_Rec Gfg_A_Slot;
typedef struct Gfg_Slot_Rec*  Gfg_Slot;
typedef struct Gfg_Slot_Rec*  Gfg_Slot_P;

struct Gfg_Initarg_Rec {
    Vm_Obj initarg;	/* Parameter name for slot val.	*/
    Vm_Obj keyword;	/* Keyword with name of slot.	*/
};
typedef struct Gfg_Initarg_Rec Gfg_A_Initarg;
typedef struct Gfg_Initarg_Rec*  Gfg_Initarg;
typedef struct Gfg_Initarg_Rec*  Gfg_Initarg_P;

/* Our refinement of Obj_Header_Rec: */
struct Gfg_Header_Rec {
    Obj_A_Header	o;

/* do-generic function needs to: */
/*   Find all applicable methods; */
/*   Sort all applicable methods by precedence. */
/*    We prolly need to stick them in a new stackframe  */
/*    which call-next-method can find...?               */
/*   Apply method combination on applicable methods.    */
/* Stuff we need in generic compiledFunction proper:   */
/*   Pointer to key. (First constant).                 */
/*   Code animating function:  It probably just         */
/*   pushes key on stack and calls some do-generic fn. */
/* Scalars we need here in key: */
/*   Name of function, presumably. */
/*   Method combination type.      */
/*   Lambda list, new methods must match before being added. */
/*   Pointer to generic function proper. */
/*   Count of methods in key. */
/* Lists we need here: */
/*   A list of methods in the generic function. */
/*   A list giving the order in which parameter specializers are examined */
/*    when sorting applicable methods by precedence. */


    Vm_Obj clos_class;
    Vm_Obj next_key;
    Vm_Obj total_slots;	       /* Number of slots in slot[] 		*/
    Vm_Obj unshared_slots;     /* Number of slots in instances 		*/

    Vm_Obj superclass_loc;     /* Start  of direct superclass list.	*/
    Vm_Obj superclass_len;     /* Length of direct superclass list.	*/

    Vm_Obj precedence_loc;     /* Start  of precedence list.		*/
    Vm_Obj precedence_len;     /* Length of precedence list.		*/

    Vm_Obj initarg_loc;        /* Start  of precedence list.		*/
    Vm_Obj initarg_len;        /* Length of precedence list.		*/

    Vm_Obj created_an_instance;  /* NIL until first instance created.	*/

    Gfg_A_Slot slot[1];	    /* Actually "Gfg_A_Slot slot[slot_count];"	*/
    /* Unshared slots come first in slot[], followed by shared slots.   */

    /* Superclass list winds up here. */

    /* Precedence list winds up here. */

    /* Initarg list winds up here. */
};
typedef struct Gfg_Header_Rec Gfg_A_Header;
typedef struct Gfg_Header_Rec*  Gfg_Header;
typedef struct Gfg_Header_Rec*  Gfg_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   gfg_Startup( void              );
extern void   gfg_Linkup(  void              );
extern void   gfg_Shutdown(void              );
#ifdef OLD
extern Vm_Obj gfg_Import(   FILE* );
extern void   gfg_Export(   FILE*, Vm_Obj );
#endif


extern void gfg_For_New( Vm_Obj, Vm_Obj, Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt );

extern Obj_A_Hardcoded_Class gfg_Hardcoded_Class;
extern Obj_A_Module_Summary  gfg_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_GFG_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

