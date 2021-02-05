
/*--   key.h -- Header for key.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_KEY_H
#define INCLUDED_KEY_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a key: */
#define KEY_P(o) ((Key_Header)vm_Loc(o))

/* Maximum supported number of slots in a struct: */
#ifndef KEY_MAX_SLOTS
#define KEY_MAX_SLOTS ((Vm_Unt)1024)
#endif


/* Maximum supported depth of :include nesting: */
#ifndef KEY_MAX_INCLUDE_DEPTH
#define KEY_MAX_INCLUDE_DEPTH ((Vm_Unt)128)
#endif

/* Bits for the Slot->flags field: */
#define KEY_FLAG_SHARED           OBJ_FROM_INT(0x0001)
#define KEY_FLAG_INHERITED        OBJ_FROM_INT(0x0002)
#define KEY_FLAG_UNUSED4          OBJ_FROM_INT(0x0004)
#define KEY_FLAG_UNUSED8          OBJ_FROM_INT(0x0008)

#define KEY_FLAG_ROOT_MAY_READ    OBJ_FROM_INT(0x0010)
#define KEY_FLAG_USER_MAY_READ    OBJ_FROM_INT(0x0020)
#define KEY_FLAG_CLASS_MAY_READ   OBJ_FROM_INT(0x0040)
#define KEY_FLAG_WORLD_MAY_READ   OBJ_FROM_INT(0x0080)

#define KEY_FLAG_ROOT_MAY_WRITE   OBJ_FROM_INT(0x0100)
#define KEY_FLAG_USER_MAY_WRITE   OBJ_FROM_INT(0x0200)
#define KEY_FLAG_CLASS_MAY_WRITE  OBJ_FROM_INT(0x0400)
#define KEY_FLAG_WORLD_MAY_WRITE  OBJ_FROM_INT(0x0800)

/* These are currently unused, but functional */
/* programming styles are gaining ground, and */
/* it is typical of them to allow setting a   */
/* value only once.  By initializing a slot   */
/* to unbound, and then allowing stores to it */
/* only if unbound, we can support this style */
/* to some extent.  This isn't implemented    */
/* yet, but we reserve these bits to signal   */
/* this mode:                                 */
#define KEY_FLAG_ROOT_MAY_INIT    OBJ_FROM_INT(0x1000)
#define KEY_FLAG_USER_MAY_INIT    OBJ_FROM_INT(0x2000)
#define KEY_FLAG_CLASS_MAY_INIT   OBJ_FROM_INT(0x4000)
#define KEY_FLAG_WORLD_MAY_INIT   OBJ_FROM_INT(0x8000)

/* Note: If a slot is SHARED, it may also be  */
/* INHERITED, in which case the 'value' field */
/* points to the class with the slot, rather  */
/* instead of holding the slot value proper.  */

#ifndef KEY_FLAGS_DEFAULT
#define KEY_FLAGS_DEFAULT (	 \
	KEY_FLAG_ROOT_MAY_READ  |\
	KEY_FLAG_ROOT_MAY_WRITE |\
	KEY_FLAG_USER_MAY_READ  |\
	KEY_FLAG_USER_MAY_WRITE |\
        KEY_FLAG_WORLD_MAY_READ );
#endif

/* Values for the 'layout' field of a class: */
#define KEY_LAYOUT_BUILT_IN          OBJ_FROM_INT(0)
#define KEY_LAYOUT_STRUCTURE         OBJ_FROM_INT(1)
#define KEY_LAYOUT_MOS_KEY           OBJ_FROM_INT(2)
#define KEY_LAYOUT_FIXNUM            OBJ_FROM_INT(3)
#define KEY_LAYOUT_SHORT_FLOAT       OBJ_FROM_INT(4)
#define KEY_LAYOUT_STACKBLOCK        OBJ_FROM_INT(5)
#define KEY_LAYOUT_BOTTOM            OBJ_FROM_INT(6)
#define KEY_LAYOUT_COMPILED_FUNCTION OBJ_FROM_INT(7)
#define KEY_LAYOUT_CHARACTER         OBJ_FROM_INT(8)
#define KEY_LAYOUT_CONS              OBJ_FROM_INT(9)
#define KEY_LAYOUT_SPECIAL           OBJ_FROM_INT(10)
#define KEY_LAYOUT_SYMBOL            OBJ_FROM_INT(11)
#define KEY_LAYOUT_BIGNUM            OBJ_FROM_INT(12)
#define KEY_LAYOUT_CALLSTACK         OBJ_FROM_INT(13)
#define KEY_LAYOUT_VECTOR            OBJ_FROM_INT(14)
#define KEY_LAYOUT_STRING            OBJ_FROM_INT(15)
#define KEY_LAYOUT_VECTOR_I01        OBJ_FROM_INT(16)
#define KEY_LAYOUT_VECTOR_I16        OBJ_FROM_INT(17)
#define KEY_LAYOUT_VECTOR_I32        OBJ_FROM_INT(18)
#define KEY_LAYOUT_VECTOR_F32        OBJ_FROM_INT(19)
#define KEY_LAYOUT_VECTOR_F64        OBJ_FROM_INT(20)

#define KEY_RESERVED_SLOTS 16

/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Key_Ancestor_Rec and Key_Link_Rec are */
/* logically a single record. I've split */
/* them into two records stored in two   */
/* arrays because this makes scanning    */
/* the list of ancestor names faster --  */
/* they become consecutive memory entries*/
/* and the cache prefetch works with us  */
/* instead of against us.                */
struct Key_Ancestor_Rec {
    Vm_Obj ancestor;	/* A cdf object.	*/
    Vm_Obj signature;	    /* Currently unused;  Intention is that it	*/
  			    /* be a hash value such that identical	*/
  			    /* signatures justify one in treating two	*/
			    /* class definitions as identical.		*/
			    /* This will probably be important in	*/
			    /* distributed operation.			*/

};
typedef struct Key_Ancestor_Rec Key_A_Ancestor;
typedef struct Key_Ancestor_Rec*  Key_Ancestor;

/* buggo, need to rip this doubly-linked list out */
/* and replace with a vector in each ancestor of  */
/* all its decendants. This has the advantage not */
/* primarily of taking 1/4 as much space, but of  */
/* working better in a distributed environment    */
/* where the descendants may be on other machines */
struct Key_Link_Rec {
    Vm_Obj next;	/* A mosKey object.	*/
    Vm_Obj prev;	/* A mosKey object.	*/
    Vm_Obj next_slot;	/* Integer slot number.	*/
    Vm_Obj prev_slot;	/* Integer slot number.	*/
};
typedef struct Key_Link_Rec Key_A_Link;
typedef struct Key_Link_Rec*  Key_Link;

/**************************************************/
/* Note:					  */
/*						  */
/* ->  In unshared slots, initform and initval	  */
/*     have the indicated interpretations.  	  */
/*						  */
/* ->  In shared slots which are not inherited,   */
/*     initval is in fact the value of the slot.  */
/*						  */
/* ->  In shared slots which are inherited,	  */
/*     initval gives the mosKey containing val,  */
/*     initform gives the slotNumber in mosKey. */
/**************************************************/
struct Key_Slot_Rec {
    Vm_Obj initform;	/* Fn returning init val, or nil*/
    Vm_Obj initval;	/* Default value for slot.	*/
    Vm_Obj type;	/* Currently ignored.		*/
    Vm_Obj documentation;/* Documentation on slot.	*/
    Vm_Obj flags;	/* See KEY_FLAG_* #defines	*/
    Vm_Obj get_function;/* Fn to read this slot.	*/
    Vm_Obj set_function;/* Fn to write this slot.	*/
/*  Vm_Obj value;	/  Value of slot, if shared	*/
};			/* here, else class holding val	*/
typedef struct Key_Slot_Rec Key_A_Slot;
typedef struct Key_Slot_Rec*  Key_Slot;
typedef struct Key_Slot_Rec*  Key_Slot_P;

struct Key_Sym_Rec {
    Vm_Obj symbol;	/* Keyword with name of slot.	*/
};			/* here, else class holding val	*/
typedef struct Key_Sym_Rec Key_A_Sym;
typedef struct Key_Sym_Rec*  Key_Sym;
typedef struct Key_Sym_Rec*  Key_Sym_P;

struct Key_Initarg_Rec {
    Vm_Obj initarg;	/* Parameter name for slot val.	*/
    Vm_Obj keyword;	/* Keyword with name of slot.	*/
};
typedef struct Key_Initarg_Rec Key_A_Initarg;
typedef struct Key_Initarg_Rec*  Key_Initarg;
typedef struct Key_Initarg_Rec*  Key_Initarg_P;

struct Key_Object_Method_Rec {
    Vm_Obj argument_number;	/* Code assumes this field is first.	*/
    Vm_Obj generic_function;
    Vm_Obj method;
    Vm_Obj object;
};
typedef struct Key_Object_Method_Rec Key_A_Object_Method;
typedef struct Key_Object_Method_Rec*  Key_Object_Method;

struct Key_Class_Method_Rec {
    Vm_Obj argument_number;	/* Code assumes this field is first.	*/
    Vm_Obj generic_function;
    Vm_Obj method;
/* buggo, prolly need to add a method_qualifier field  */
/* so we can find before/around/after methods quickly? */
/* or can we do the needed work at defmethod time, so  */
/* the runtimes don't need to worry about it?          */
};
typedef struct Key_Class_Method_Rec Key_A_Class_Method;
typedef struct Key_Class_Method_Rec*  Key_Class_Method;

/* Our refinement of Obj_Header_Rec: */
struct Key_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj layout;

    Vm_Obj compiler;
    Vm_Obj source;
    Vm_Obj file_name;	    /* Source file function was compiled from.	*/
    Vm_Obj fn_line;	    /* Line number in above on which fn started.*/

    Vm_Obj created_an_instance;  /* NIL until first instance created.	*/
    Vm_Obj predicate;	    /* Function testing type of instances.	*/
    Vm_Obj assertion;	    /* Function verifying type of instances.	*/
    Vm_Obj print_function;  /* Function printing instances.		*/

    /* Following imported from sdf: */
    Vm_Obj conc_name;	    /* String prefix for accessor fns.		*/
    Vm_Obj constructor;	    /* Function constructing instances.		*/
    Vm_Obj copier;	    /* Function copying instances.		*/
    Vm_Obj abstract;	    /* If non-NIL, may not create instances.	*/
    Vm_Obj type;	    /* Currently ignored.			*/
    Vm_Obj named;	    /* Currently ignored.			*/
    Vm_Obj initial_offset;  /* Currently ignored.			*/
    Vm_Obj export;	    /* NIL, or T to export all struct symbols.	*/
    Vm_Obj fertile;	    /* NIL, unless subclassing by others is ok.	*/

    Vm_Obj metaclass;	    /* Currently unused:	 		*/
    Vm_Obj documentation;   /* String specified by :documention option.	*/

    Vm_Obj signature;	    /* Currently unused;  Intention is that it	*/
  			    /* be a hash value such that identical	*/
  			    /* signatures justify one in treating two	*/
			    /* class definitions as identical.		*/
			    /* This will probably be important in	*/
			    /* distributed operation.			*/

    Vm_Obj mos_class;
    Vm_Obj newer_key;
    Vm_Obj unshared_slots;     /* Number of slots in instances 		*/
    Vm_Obj total_slots;	       /* Number of slots in slot[] 		*/
    Vm_Obj sym_loc;	       /* Start of slot symbol list. 		*/

    Vm_Obj superclass_loc;     /* Start  of direct superclass list.	*/
    Vm_Obj superclass_len;     /* Length of direct superclass list.	*/

    Vm_Obj precedence_loc;     /* Start  of ancestor name list.		*/
    Vm_Obj       link_loc;     /* Start  of ancestor link list.		*/
    Vm_Obj precedence_len;     /* Length of ancestor lists.		*/

    Vm_Obj slotarg_loc;        /* Start  of slot initarg name list.	*/
    Vm_Obj slotarg_len;        /* Length of slot initarg name list.	*/

    Vm_Obj metharg_loc;        /* Start  of method initarg name list.	*/
    Vm_Obj metharg_len;        /* Length of method initarg name list.	*/

    Vm_Obj initarg_loc;        /* Start  of initargs list.		*/
    Vm_Obj initarg_len;        /* Length of initargs list.		*/

    Vm_Obj objectmethods_loc;  /* Start  of (eql obj) method list.	*/
    Vm_Obj objectmethods_len;  /* Length of (eql obj) method list.	*/

    Vm_Obj classmethods_loc;   /* Start  of 'class    method list.	*/
    Vm_Obj classmethods_len;   /* Length of 'class    method list.	*/

    Vm_Obj reserved_slot[ KEY_RESERVED_SLOTS ];

    Key_A_Slot slot[1];	    /* Actually "Key_A_Slot slot[slot_count];"	*/

    /* Unshared slots come first in slot[], followed by shared slots.   */

    /* Superclass vector winds up here. */

    /* Ancestor list vector winds up here. */

    /* Ancestor link vector winds up here. */

    /* Initarg vector winds up here. */

    /* Object methods vector winds up here. */

    /* Class methods vector winds up here. */
};
typedef struct Key_Header_Rec Key_A_Header;
typedef struct Key_Header_Rec*  Key_Header;
typedef struct Key_Header_Rec*  Key_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   key_Startup( void              );
extern void   key_Linkup(  void              );
extern void   key_Shutdown(void              );
extern Vm_Int key_Direct_Subclass_Of( Vm_Obj, Vm_Obj );
extern Vm_Int key_Parents_List(    Vm_Obj**, Vm_Obj );
extern Vm_Int key_Ancestor_List( Key_Ancestor*, Vm_Obj );
#ifdef UNUSED
extern Vm_Int key_Link_List(     Key_Link*    , Vm_Obj );
#endif

extern Vm_Obj key_Alloc(Vm_Obj,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Int,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt);

#ifdef OLD
extern Vm_Obj key_Import(   FILE* );
extern void   key_Export(   FILE*, Vm_Obj );
#endif


extern void key_For_New( Vm_Obj, Vm_Obj, Vm_Unt,Vm_Unt,Vm_Unt,Vm_Int,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt );

extern Obj_A_Hardcoded_Class key_Hardcoded_Class;
extern Obj_A_Module_Summary  key_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_KEY_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

