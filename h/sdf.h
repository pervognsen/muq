
/*--   sdf.h -- Header for sdf.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_SDF_H
#define INCLUDED_SDF_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a sdf: */
#define SDF_P(o) ((Sdf_Header)vm_Loc(o))

/* Maximum supported number of slots in a struct: */
#ifndef SDF_MAX_SLOTS
#define SDF_MAX_SLOTS ((Vm_Unt)1024)
#endif

/* Maximum supported depth of :include nesting: */
#ifndef SDF_MAX_INCLUDE_DEPTH
#define SDF_MAX_INCLUDE_DEPTH ((Vm_Unt)128)
#endif

/* Bits for the Slot->flags field: */
#define SDF_FLAG_ROOT_MAY_READ    OBJ_FROM_INT(1)
#define SDF_FLAG_ROOT_MAY_WRITE   OBJ_FROM_INT(2)
#define SDF_FLAG_USER_MAY_READ    OBJ_FROM_INT(4)
#define SDF_FLAG_USER_MAY_WRITE   OBJ_FROM_INT(8)
#define SDF_FLAG_AUTHOR_MAY_READ  OBJ_FROM_INT(16)
#define SDF_FLAG_AUTHOR_MAY_WRITE OBJ_FROM_INT(32)
#define SDF_FLAG_WORLD_MAY_READ   OBJ_FROM_INT(64)
#define SDF_FLAG_WORLD_MAY_WRITE  OBJ_FROM_INT(128)

#ifndef SDF_FLAGS_DEFAULT
#define SDF_FLAGS_DEFAULT (	 \
	SDF_FLAG_ROOT_MAY_READ  |\
	SDF_FLAG_ROOT_MAY_WRITE |\
	SDF_FLAG_USER_MAY_READ  |\
	SDF_FLAG_USER_MAY_WRITE |\
        SDF_FLAG_WORLD_MAY_READ );
#endif

/************************************************************************/
/*-    types								*/
/************************************************************************/

struct Sdf_Slot_Rec {
    Vm_Obj keyword;	/* Keyword with name of slot.	*/
    Vm_Obj initform;	/* Fn returning init val, or nil*/
    Vm_Obj initval;	/* Default value for slot.	*/
    Vm_Obj type;	/* Currently ignored.		*/
    Vm_Obj documentation;/* Explanation of slot.	*/
    Vm_Obj flags;	/* See SDF_FLAG_* #defines	*/
    Vm_Obj get_function;/* Fn to read this slot.	*/
    Vm_Obj set_function;/* Fn to write this slot.	*/
    Vm_Obj value;	/* Unused -- shared slots maybe */
};
typedef struct Sdf_Slot_Rec Sdf_A_Slot;
typedef struct Sdf_Slot_Rec*  Sdf_Slot;
typedef struct Sdf_Slot_Rec*  Sdf_Slot_P;

/* Our refinement of Obj_Header_Rec: */
struct Sdf_Header_Rec {
    Obj_A_Header	o;

    /* Included to be parallel with fun.h: */
    Vm_Obj compiler;
    Vm_Obj source;
    Vm_Obj file_name;	    /* Source file function was compiled from.	*/
    Vm_Obj fn_line;	    /* Line number in above on which fn started.*/

    Vm_Obj created_an_instance;  /* NIL until first instance created.	*/
    Vm_Obj predicate;	    /* Function testing type of instances.	*/
    Vm_Obj assertion;	    /* Function verifying type of instances.	*/
    Vm_Obj print_function;  /* Function printing instances.		*/

    Vm_Obj conc_name;	    /* String prefix for accessor fns.		*/
    Vm_Obj constructor;	    /* Function constructing instances.		*/
    Vm_Obj copier;	    /* Function copying instances.		*/
    Vm_Obj type;	    /* Currently ignored.			*/
    Vm_Obj named;	    /* Currently ignored.			*/
    Vm_Obj initial_offset;  /* Currently ignored.			*/
    Vm_Obj export;	    /* NIL, or T to export all struct symbols.	*/

    Vm_Obj metaclass;	    /* Currently unused:	 		*/
    Vm_Obj documentation;   /* String specified by :documention option.	*/

    Vm_Obj signature;	    /* Currently unused;  Intention is that it	*/
  			    /* be a hash value such that identical	*/
  			    /* signatures justify one in treating two	*/
			    /* structure definitions as identical.	*/
			    /* This will probably be important in	*/
			    /* distributed operation.			*/

    Vm_Obj mos_class;
    Vm_Obj next_key;
    Vm_Obj total_slots;	       /* Number of slots in slot[] 		*/

    Vm_Obj unshared_slots;  /* Number of slots in instances: 		*/

    Vm_Obj superclass_loc;     /* Start  of direct superclass list.	*/
    Vm_Obj superclass_len;     /* Length of direct superclass list.	*/

    Vm_Obj precedence_loc;     /* Start  of precedence list.		*/
    Vm_Obj precedence_len;     /* Length of precedence list.		*/

    Vm_Obj initarg_loc;        /* Start  of initargs list.		*/
    Vm_Obj initarg_len;        /* Length of initargs list.		*/

    Vm_Obj objectmethods_loc;  /* Start  of (eql obj) method list.	*/
    Vm_Obj objectmethods_len;  /* Length of (eql obj) method list.	*/

    Vm_Obj classmethods_loc;   /* Start  of 'class    method list.	*/
    Vm_Obj classmethods_len;   /* Length of 'class    method list.	*/

    Sdf_A_Slot slot[1];	    /* Actually "Sdf_A_Slot slot[slot_count];"	*/
};
typedef struct Sdf_Header_Rec Sdf_A_Header;
typedef struct Sdf_Header_Rec*  Sdf_Header;
typedef struct Sdf_Header_Rec*  Sdf_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   sdf_Startup( void              );
extern void   sdf_Linkup(  void              );
extern void   sdf_Shutdown(void              );
#ifdef OLD
extern Vm_Obj sdf_Import(   FILE* );
extern void   sdf_Export(   FILE*, Vm_Obj );
#endif

extern Obj_A_Hardcoded_Class sdf_Hardcoded_Class;
extern Obj_A_Module_Summary  sdf_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_SDF_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

