/*--   obj.h -- Header for obj.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_OBJ_H
#define INCLUDED_OBJ_H


#include "vm.h"
#include "jobprims.h"


/************************************************************************/
/*-    #defines								*/


#ifndef OBJ_MIN_STACKFRAMES_POPPED_AFTER_LOOP_STACK_OVERFLOW
#define OBJ_MIN_STACKFRAMES_POPPED_AFTER_LOOP_STACK_OVERFLOW (Vm_Unt)2 /* No special reasoning, no */
#endif
#ifndef OBJ_STACKFRAMES_POPPED_AFTER_LOOP_STACK_OVERFLOW
#define OBJ_STACKFRAMES_POPPED_AFTER_LOOP_STACK_OVERFLOW (Vm_Unt)10
#endif

#ifndef OBJ_MIN_STACKSLOTS_POPPED_AFTER_DATA_STACK_OVERFLOW
#define OBJ_MIN_STACKSLOTS_POPPED_AFTER_DATA_STACK_OVERFLOW (Vm_Unt)16  /* No special reasoning, no */
#endif
#ifndef OBJ_STACKSLOTS_POPPED_AFTER_DATA_STACK_OVERFLOW
#define OBJ_STACKSLOTS_POPPED_AFTER_DATA_STACK_OVERFLOW (Vm_Unt)256
#endif


/************************************************************************/
/*-    Max # of non-object types -- dimension of mod_Type_Summary[].	*/

/* THIS CALCULATION IS OBSOLETE: */
/* There can be, with current encodings, at most 27 types:      */
/*  1 int type with       *********0 tag;			*/
/* 15 explicit types with *****????1 tags;			*/
/*  7 implicit types with **???00001 tags.			*/
/*  4 implicit types with ??01000001 tags.			*/
/* (See "Vm_Obj Tagbits" in the manual.)			*/
/* This array is filled out by the various xxx_Startup()s:	*/



/************************************************************************/
/*-    Types of properties stored on objects:				 */

#define OBJ_PROP_SYSTEM		((Vm_Unt)0)
#define OBJ_PROP_PUBLIC		((Vm_Unt)1)
#define OBJ_PROP_HIDDEN		((Vm_Unt)2)
#define OBJ_PROP_ADMINS		((Vm_Unt)3)
#define OBJ_PROP_MAX		((Vm_Unt)4)
/* NB: Keep obj.c:obj_Propdir_Name[] in synch with above. */

/* We use two bits in object pointers  */
/* to distinguish whether the pointer  */
/* addresses the pubic, hidden, system */
/* or administrator section:           */
#define OBJ_SECTION_BITS  2
#define OBJ_SECTION_SHIFT VM_TAGBITS
#define OBJ_SECTION_MASK  ((1<<OBJ_SECTION_BITS)-1)
#define OBJ_SECTION(o) (((o) >> OBJ_SECTION_SHIFT) & OBJ_SECTION_MASK)
#define OBJ_SECTION_SET(o,i) \
    ((((o)&~(OBJ_SECTION_MASK << OBJ_SECTION_SHIFT)) \
  |  (((i)&OBJ_SECTION_MASK))<<OBJ_SECTION_SHIFT))




/************************************************************************/
/*-    Macro to make obj_Neql() less inscrutable to use: */

#define OBJ_LESS(x,y) ((Vm_Int)0>obj_Neql((x),(y)))




/************************************************************************/
/*-    Macros read/write our various fields.				*/

/* Basic macro to locate an object: */
#define OBJ_P(o) ((Obj_Header)vm_Loc(o))



/************************************************************************/
/*-    Macros related to object 'flagwrd'.				*/

#include "obj2.h"
/* 94Jul21 note: Following info is obsolete. CrT */
/********************************************************/
/* Flagwrd contains (most- to least-sig-bit order):	*/
/*   8 bits of type					*/
/*   8 bits reserved for future use	   		*/
/*   7 bits of default property rwx privileges		*/
/*   1 bit  reserved for future use	   		*/
/*   7 bits of object           rwx privileges		*/
/*   1 bit  of type-int tag in lower two bits		*/
/* -------------------------------------------          */
/*  32 bits						*/
/********************************************************/

/* Define the hardwired object classes we recognize: */
#define OBJ_CLASS_A_ROT	        ((Vm_Unt)1)
#define OBJ_CLASS_A_USR		((Vm_Unt)2)
#define OBJ_CLASS_A_GST		((Vm_Unt)3)
#define OBJ_CLASS_A_FN		((Vm_Unt)4)
#define OBJ_CLASS_A_ASM		((Vm_Unt)5)
#define OBJ_CLASS_A_JOB	        ((Vm_Unt)6)
#define OBJ_CLASS_A_OBJ	        ((Vm_Unt)7)
#define OBJ_CLASS_A_SKT	        ((Vm_Unt)8)
#define OBJ_CLASS_A_MSS	       ((Vm_Unt) 9)
#define OBJ_CLASS_A_SSN	       ((Vm_Unt)10)
#define OBJ_CLASS_A_JBS	       ((Vm_Unt)11)
#define OBJ_CLASS_A_STK	       ((Vm_Unt)12)
#define OBJ_CLASS_A_LST	       ((Vm_Unt)13)
#define OBJ_CLASS_A_DST	       ((Vm_Unt)14)
#define OBJ_CLASS_A_STM	       ((Vm_Unt)15)
#define OBJ_CLASS_A_PKG	       ((Vm_Unt)16)
#define OBJ_CLASS_A_SYS	       ((Vm_Unt)17)
#define OBJ_CLASS_A_MUQ	       ((Vm_Unt)18)
#define OBJ_CLASS_A_LOK	       ((Vm_Unt)19)
#define OBJ_CLASS_A_PRX	       ((Vm_Unt)20)
#define OBJ_CLASS_A_CFG	       ((Vm_Unt)21)
#define OBJ_CLASS_A_JOQ	       ((Vm_Unt)22)
#define OBJ_CLASS_A_USQ	       ((Vm_Unt)23)
#define OBJ_CLASS_A_CDF	       ((Vm_Unt)24)
#define OBJ_CLASS_A_KEY	       ((Vm_Unt)25)
#define OBJ_CLASS_A_MTD	       ((Vm_Unt)26)
#define OBJ_CLASS_A_LBD	       ((Vm_Unt)27)
#define OBJ_CLASS_A_RDT	       ((Vm_Unt)28)
#define OBJ_CLASS_A_DIL	       ((Vm_Unt)29)
#define OBJ_CLASS_A_DIN	       ((Vm_Unt)30)
#define OBJ_CLASS_A_PIL	       ((Vm_Unt)31)
#define OBJ_CLASS_A_PIN	       ((Vm_Unt)32)
#define OBJ_CLASS_A_SIL	       ((Vm_Unt)33)
#define OBJ_CLASS_A_SIN	       ((Vm_Unt)34)
#define OBJ_CLASS_A_TIL	       ((Vm_Unt)35)
#define OBJ_CLASS_A_TIN	       ((Vm_Unt)36)
#define OBJ_CLASS_A_MIL	       ((Vm_Unt)37)
#define OBJ_CLASS_A_MIN	       ((Vm_Unt)38)
#define OBJ_CLASS_A_SEL	       ((Vm_Unt)39)
#define OBJ_CLASS_A_SEN	       ((Vm_Unt)40)
#define OBJ_CLASS_A_DBF	       ((Vm_Unt)41)
#define OBJ_CLASS_A_SET	       ((Vm_Unt)42)
#define OBJ_CLASS_A_NDX	       ((Vm_Unt)43)
#define OBJ_CLASS_A_N3D	       ((Vm_Unt)44)
#define OBJ_CLASS_A_HSH	       ((Vm_Unt)45)
#define OBJ_CLASS_A_ARY	       ((Vm_Unt)46)
#define OBJ_CLASS_A_TBL	       ((Vm_Unt)47)
#define OBJ_CLASS_A_WDW	       ((Vm_Unt)48)
#define OBJ_CLASS_A_D3L	       ((Vm_Unt)49)
#define OBJ_CLASS_A_D3N	       ((Vm_Unt)50)
#define OBJ_CLASS_MAX	       ((Vm_Unt)51)

/* Commented out because nobody is working */
/* on completing the X support:            */
/* #define OBJ_CLASS_A_XDP	       (31)*/
/* #define OBJ_CLASS_A_XFT	       (32)*/
/* #define OBJ_CLASS_A_XGC	       (33)*/
/* #define OBJ_CLASS_A_XSC	       (34)*/
/* #define OBJ_CLASS_A_XWD	       (35)*/
/* #define OBJ_CLASS_A_XCL	       (36)*/
/* #define OBJ_CLASS_A_XCM	       (37)*/
/* #define OBJ_CLASS_A_XCR	       (38)*/
/* #define OBJ_CLASS_A_XPX	       (39)*/

/* Define macros to get and set class field: */
#define OBJ_CLASS_SHIFT (24)
#define OBJ_CLASS_MASK  (((Vm_Unt)0xFF) << OBJ_CLASS_SHIFT)
#define OBJ_CLASS(o)    ((Vm_Unt)(OBJ_P(o)->flagwrd & OBJ_CLASS_MASK) >> OBJ_CLASS_SHIFT) 
#define OBJ_CLASS_REVERSE(o)    ((Vm_Unt)(vm_Reverse64(OBJ_P(o)->flagwrd) & OBJ_CLASS_MASK) >> OBJ_CLASS_SHIFT) 
#define OBJ_CLASS_SET(o,t) {					\
    Obj_Header p  = OBJ_P(o);					\
    Vm_Int     i  = p->flagwrd & ~OBJ_CLASS_MASK;		\
    i            |= (((Vm_Unt)t) << OBJ_CLASS_SHIFT) & OBJ_CLASS_MASK;	\
    p->flagwrd    = i;						\
}

/********************************************************/
/* NEVER USE ONE OF THE FOLLOWING MACROS WITHOUT FIRST  */
/* CHECKING THAT OBJ_IS_OBJ(o) IS TRUE!  ONLY WARNING!  */
/********************************************************/
/* Define convenience predicates on typefield.		*/
/* Could actually save a shift here if we wanted:	*/
#define OBJ_IS_CLASS_ROT(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_ROT)
#define OBJ_IS_CLASS_USR(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_USR)
#define OBJ_IS_CLASS_GST(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_GST)
#define OBJ_IS_CLASS_FN(o)      (OBJ_CLASS(o)==OBJ_CLASS_A_FN)
#define OBJ_IS_CLASS_OBJ(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_OBJ)
#define OBJ_IS_CLASS_DBF(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_DBF)
#define OBJ_IS_CLASS_JOB(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_JOB)
#define OBJ_IS_CLASS_ASM(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_ASM)
#define OBJ_IS_CLASS_SKT(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_SKT)
#define OBJ_IS_CLASS_MSS(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_MSS)
#define OBJ_IS_CLASS_SSN(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_SSN)
#define OBJ_IS_CLASS_JBS(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_JBS)
#define OBJ_IS_CLASS_STK(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_STK)
#define OBJ_IS_CLASS_DST(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_DST)
#define OBJ_IS_CLASS_LST(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_LST)
#define OBJ_IS_CLASS_STM(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_STM)
#define OBJ_IS_CLASS_PKG(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_PKG)
#define OBJ_IS_CLASS_SYS(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_SYS)
#define OBJ_IS_CLASS_MUQ(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_MUQ)
#define OBJ_IS_CLASS_LOK(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_LOK)
#define OBJ_IS_CLASS_EVT(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_EVT)
#define OBJ_IS_CLASS_PRX(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_PRX)
#define OBJ_IS_CLASS_CFG(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_CFG)
#define OBJ_IS_CLASS_JOQ(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_JOQ)
#define OBJ_IS_CLASS_USQ(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_USQ)
#define OBJ_IS_CLASS_CDF(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_CDF)
#define OBJ_IS_CLASS_KEY(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_KEY)
#define OBJ_IS_CLASS_MTD(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_MTD)
#define OBJ_IS_CLASS_LBD(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_LBD)
#define OBJ_IS_CLASS_RDT(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_RDT)
#define OBJ_IS_CLASS_DIL(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_DIL)
#define OBJ_IS_CLASS_DIN(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_DIN)
#define OBJ_IS_CLASS_PIL(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_PIL)
#define OBJ_IS_CLASS_PIN(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_PIN)
#define OBJ_IS_CLASS_SIL(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_SIL)
#define OBJ_IS_CLASS_SIN(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_SIN)
#define OBJ_IS_CLASS_TIL(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_TIL)
#define OBJ_IS_CLASS_TIN(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_TIN)
#define OBJ_IS_CLASS_MIL(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_MIL)
#define OBJ_IS_CLASS_MIN(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_MIN)
#define OBJ_IS_CLASS_SEL(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_SEL)
#define OBJ_IS_CLASS_SEN(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_SEN)
#define OBJ_IS_CLASS_SET(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_SET)
#define OBJ_IS_CLASS_NDX(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_NDX)
#define OBJ_IS_CLASS_N3D(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_N3D)
#define OBJ_IS_CLASS_HSH(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_HSH)
#define OBJ_IS_CLASS_ARY(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_ARY)
#define OBJ_IS_CLASS_TBL(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_TBL)
#define OBJ_IS_CLASS_WDW(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_WDW)
#define OBJ_IS_CLASS_D3L(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_D3L)
#define OBJ_IS_CLASS_D3N(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_D3N)

/* Commented out because nobody is working */
/* on completing the X support:            */
/*#define OBJ_IS_CLASS_XDP(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XDP)*/
/*#define OBJ_IS_CLASS_XFT(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XFT)*/
/*#define OBJ_IS_CLASS_XGC(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XGC)*/
/*#define OBJ_IS_CLASS_XSC(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XSC)*/
/*#define OBJ_IS_CLASS_XWD(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XWD)*/
/*#define OBJ_IS_CLASS_XCL(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XCL)*/
/*#define OBJ_IS_CLASS_XCM(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XCM)*/
/*#define OBJ_IS_CLASS_XCR(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XCR)*/
/*#define OBJ_IS_CLASS_XPX(o)     (OBJ_CLASS(o)==OBJ_CLASS_A_XPX)*/

/* Use ISA instead of IS when checking right-to-do stuff: */
#define OBJ_ISA_USR(o)    (OBJ_CLASS(o)<=OBJ_CLASS_A_USR)

/* Use this when remote users as well as local users are  */
/* acceptable:                                            */
#define OBJ_IS_FOLK(o)    (OBJ_CLASS(o)<=OBJ_CLASS_A_GST)

/* This variable controls interim garbage collection frequency: */
#ifndef OBJ_BYTES_BETWEEN_GARBAGE_COLLECTIONS
#define OBJ_BYTES_BETWEEN_GARBAGE_COLLECTIONS 500000
#endif


#include "obj2.h"



/************************************************************************/
/*-    types								*/


/************************************************************************/
/*-    Obj_Header/Obj_P -- universal object header struct		*/

/* We require every hardwired class to support certain	*/
/* fields, and implement this by defining a standard	*/
/* struct which every object class include as a header:	*/
struct Obj_Header_Rec {
    Vm_Obj flagwrd;	/* Int: Obj type and various flags.	*/
    Vm_Obj is_a;	/* Kind of object -- typically a cdf.	*/
    Vm_Obj objname;	/* Name of object.			*/

    /* Include fields for optional modules: */
    #define  MODULES_OBJ_H_OBJ_HEADER_REC
    #include "Modules.h"
    #undef   MODULES_OBJ_H_OBJ_HEADER_REC
};
typedef struct Obj_Header_Rec Obj_A_Header;
typedef struct Obj_Header_Rec*  Obj_Header;
typedef struct Obj_Header_Rec*  Obj_P;	/* Yes, I'm lazy.	*/



/************************************************************************/
/*-    Obj_Special_Property -- description of distinguished props	*/

/************************************************************************/
/* Most classes have a few properties which they require special	*/
/* treatment for.  Each class exports to obj.c an array describing	*/
/* all such properties.  Special treatment may consist of caching	*/
/* the property in the object record itself (instead of the propdir)	*/
/* and/or special treatment of fetch/store to/from the property.	*/
/* Here we define the structure which other classes use to describe	*/
/* such properties.							*/
/*									*/
/* If for_set() returns 0x0, obj.c will not store the			*/
/* property into the propdir.  (for_set() may or may not have		*/
/* stored a value into the object proper, obj.c doesn't care.)		*/
/*									*/
/* If for_get() returns OBJ_NOT_FOUND, obj.c will attempt to		*/
/* read the value normally from the propdir, otherwise it will		*/
/* return the given value.						*/
/************************************************************************/
struct Obj_Special_Property_Rec {
    Vm_Obj   keyword;				/* Name as a keyword.	*/
    Vm_Uch*  name;				/* Name of property.	*/
    Vm_Obj (*for_get)( Vm_Obj );		/* Get-filter fn.	*/
    Vm_Obj (*for_set)( Vm_Obj, Vm_Obj );	/* Set-filter fn.	*/
};
typedef struct Obj_Special_Property_Rec Obj_A_Special_Property;
typedef struct Obj_Special_Property_Rec*  Obj_Special_Property;



/************************************************************************/
/*-    Obj_Hardcoded_Class -- description of C-coded class		*/

/************************************************************************

Most Muq classes are softcoded in the application languages, but
for efficiency and/or security reasons, a few fundamental classes are
hardcoded in C.  Each such class needs to inform obj.c of any special
handling required, which it does by exporting a
Obj_Hardcoded_Class_Rec.

The 'sizeof_obj' function should return the size-in-bytes of the
object record.  (It is a function rather than a constant
primarily because Ansi C doesn't require sizeof(...) to be a
legal constant expression.)

The 'name' entry gives the 3-char class prefix ("stk" etc) as a string.
This is mostly used internally by the import/export code.

The 'fullname' entry gives the class name which is printed out to
users for debugging purposes and such.

The 'for_new' function should initialize any fields in the object
beyond the standard header fields.

The 'for_del' fn does delete-given-key              for this class.
The 'for_get' fn does get-val-of-key                for this class.
The 'for_set' fn does set-val-of-key                for this class.
The 'for_nxt' fn does getNextKey?                  for this class.
The 'for_key' fn does get-next-key-with-given-value for this class.
The 'do_hash' fn returns fixnum hash value          for this class.

The 'import'  fn does save-into-flat-textfile       for this class.
The 'export'  fn does load-from-flat-textfile       for this class.

The 'propdir' array pointers (one per propdir) lead to arrays
of Obj_Special_Property_Recs describing, for each propdir, the
properties to which the class assigns special semantics.

 ************************************************************************/

struct Obj_Hardcoded_Class_Rec {
    Vm_Obj   name;
    Vm_Uch*  fullname;
    Vm_Unt (*sizeof_obj)( Vm_Unt );
    void   (*for_new)( Vm_Obj, Vm_Unt );

    Vm_Obj (*for_del)( Vm_Obj, Vm_Obj , Vm_Int );
    Vm_Obj (*for_get)( Vm_Obj, Vm_Obj , Vm_Int );
    Vm_Obj (*g_asciz)( Vm_Obj, Vm_Uch*, Vm_Int );
    Vm_Uch*(*for_set)( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
    Vm_Obj (*for_nxt)( Vm_Obj, Vm_Obj , Vm_Int );
    Vm_Obj (*for_key)( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int, Vm_Int );
    Vm_Obj (*do_hash)( Vm_Obj );
    Vm_Obj (*reverse)( Vm_Obj );

    Vm_Obj (*get_mos_key)( Vm_Obj );

    Obj_Special_Property  propdir[ OBJ_PROP_MAX ];

    Vm_Obj (*import)(   FILE*, Vm_Int, Vm_Int, Vm_Int, Vm_Int );
    void   (*export)(   FILE*, Vm_Obj, Vm_Int );

    Vm_Obj builtin_class;	/* Filled in at startup time. */
};
typedef struct Obj_Hardcoded_Class_Rec Obj_A_Hardcoded_Class;
typedef struct Obj_Hardcoded_Class_Rec*  Obj_Hardcoded_Class;



/************************************************************************/
/*-    Obj_Module_Summary -- description of C-coded modules		*/

/************************************************************************

All C modules have certain potential needs, such as
executing specified code at startup time, linkup time, and
shutdown time.

Some of these modules may not implement a class, so the
class descriptions are not an appropriate place to list
these needs, hence we use a separate array and record type
for the purpose.

 ************************************************************************/

struct Obj_Module_Summary_Rec {
    Vm_Uch*		mod_name;	/* Used only for debugging. */
    void                (*doTypes)(  void );
    void                (*startup)(  void );
    void                (*linkup)(   void );
    void                (*shutdown)( void );
};
typedef struct Obj_Module_Summary_Rec Obj_A_Module_Summary;
typedef struct Obj_Module_Summary_Rec*  Obj_Module_Summary;



/************************************************************************/
/*-    Obj_Type_Summary -- description of C-coded elementary type	*/

struct Obj_Type_Summary_Rec {
    Vm_Obj name;
    Vm_Uch*(*sprintW)( Vm_Uch* buf, Vm_Uch* lim, Vm_Obj obj, Vm_Int quote );
    Vm_Uch*(*sprintL)( Vm_Uch* buf, Vm_Uch* lim, Vm_Obj obj, Vm_Int quote );
    Vm_Uch*(*sprintP)( Vm_Uch* buf, Vm_Uch* lim, Vm_Obj obj, Vm_Int quote );
    Vm_Obj (*for_del)( Vm_Obj, Vm_Obj , Vm_Int );
    Vm_Obj (*for_get)( Vm_Obj, Vm_Obj , Vm_Int );
    Vm_Obj (*g_asciz)( Vm_Obj, Vm_Uch*, Vm_Int );
    Vm_Uch*(*for_set)( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
    Vm_Obj (*for_nxt)( Vm_Obj, Vm_Obj , Vm_Int );
    Vm_Obj (*for_key)( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int, Vm_Int );
    Vm_Obj (*do_hash)( Vm_Obj );
    Vm_Obj (*reverse)( Vm_Obj );
    Vm_Obj (*get_mos_key)( Vm_Obj );
    Vm_Obj (*import)(  FILE* , Vm_Int , Vm_Int, Vm_Int );
    void   (*export)(  FILE* , Vm_Obj , Vm_Int );

    Vm_Uch* fullname;		/* Name of builtin_class.	*/
    Vm_Obj  layout;		/* One of KEY_LAYOUT_*		*/
    Vm_Obj builtin_class;	/* Filled in at startup time.	*/
};
typedef struct Obj_Type_Summary_Rec Obj_A_Type_Summary;
typedef struct Obj_Type_Summary_Rec*  Obj_Type_Summary;



/************************************************************************/
/*-    Obj_Export_Stats -- parameter type for obj_Export_Tree		*/

struct Obj_Export_Stats_Rec {
    Vm_Int objects_in_file;
    Vm_Int items_in_file;
};
typedef struct Obj_Export_Stats_Rec Obj_A_Export_Stats;
typedef struct Obj_Export_Stats_Rec * Obj_Export_Stats;





/************************************************************************/
/*-    externs								*/

extern Job_An_Any obj_Kludge;
extern Job_An_Any obj_Kludge2;
extern Obj_A_Type_Summary obj_Type_Bad_Summary;
extern Obj_A_Type_Summary obj_Type_Obj_Summary;
extern Obj_Export_Stats obj_Export_Stats;
extern Vm_Int  obj_Write_Pid_File;
extern Vm_Int  obj_Ignore_Server_Signature;
extern Vm_Int  obj_No_Environment;
extern Vm_Int  obj_Quick_Start;
extern Vm_Unt  obj_Date_Of_Last_Backup;
extern Vm_Unt  obj_Date_Of_Last_Garbage_Collect;

#ifdef OLD
extern Vm_Unt  obj_Date_Of_Next_Backup;	/* Initialized in muq.t */
#endif

extern Vm_Unt  obj_Date_Of_Next_Backup;
extern Vm_Unt  obj_Millisecs_For_Last_Backup;
extern Vm_Unt  obj_Millisecs_Between_Backups;
extern Vm_Unt  obj_Millisecs_For_Last_Garbage_Collect;
extern Vm_Int  obj_Garbage_Collects;

extern Vm_Uch* obj_Srv_Dir;
extern Vm_Uch  obj_Allowed_Outbound_Net_Ports[0x1FFF];
extern Vm_Uch  obj_Root_Allowed_Outbound_Net_Ports[0x1FFF];
extern Vm_Int  obj_Outbound_Port_Is_Allowed(Vm_Uch map[0x1FFF],Vm_Unt);
extern void    obj_Select_Outbound_Ports( Vm_Uch map[ 0x1FFF ], Vm_Uch* );
extern Vm_Obj  obj_Owner(Vm_Obj);
extern void    obj_DoTypes(void);
extern void    obj_Startup(void);
extern void    obj_Linkup(void);
extern void    obj_Shutdown(void);
extern void    obj_Mark(Vm_Obj);
extern void    obj_Collect_Garbage(void);
void           obj_Mark_Header(Vm_Obj);
extern void    obj_Do_Backup(void);
extern Vm_Obj  obj_Ints3_To_Dbref( Vm_Unt*, Vm_Unt, Vm_Unt, Vm_Unt );
extern void    obj_Dbref_To_Ints3( Vm_Unt*, Vm_Unt*, Vm_Unt*, Vm_Obj );
extern void    obj_NoteRandomBits( Vm_Unt );
extern void    obj_NoteDateAsRandomBits( void );
extern void    obj_20TrueRandomBytes( Vm_Uch digest[20] );
extern Vm_Unt  obj_TrueRandom( Vm_Unt* );
#ifdef OLD
extern void    obj_Initialize_Net1_And_Net2( Obj_P );
#endif
extern Vm_Int  obj_Is_Atomic( Vm_Obj );
extern Vm_Obj  obj_Import(        FILE*, Vm_Int, Vm_Int, Vm_Int, Vm_Int );
extern Vm_Obj  obj_Import_Any(    FILE*, Vm_Int, Vm_Int, Vm_Int);
extern void    obj_Import_Hashtab_Enter( Vm_Obj, Vm_Obj );
extern void    obj_Export_Subobj( FILE*, Vm_Obj, Vm_Int );
extern void    obj_Export(        FILE*, Vm_Obj, Vm_Int );
extern void    obj_Export_Tree(   FILE*, Vm_Obj, Obj_Export_Stats, Vm_Int );
extern Vm_Obj  obj_Import_Tree(   FILE*,Obj_Export_Stats,Vm_Int,Vm_Int,Vm_Int);
extern Vm_Obj  obj_Import_Hashtab_Val( Vm_Obj );
extern void    obj_Import_Bump_Bytes_Used( Vm_Obj );
extern Vm_Int  obj_Eq_Via_Pointer_Is_Ok(   Vm_Obj );
extern void    obj_For_All_Pointers_In_Server(  void (*fn)( void*fa, Vm_Obj o, Vm_Int count ),  void  *fa );
extern void    obj_Null_Out_All_Broken_Pointers( void );
extern void    obj_Null_Out_Broken_Pointers_In_Db( Vm_Db  db );

extern Vm_Int  obj_Caseless_StrCmp( Vm_Uch*, Vm_Int,Vm_Uch*, Vm_Int );
extern Vm_Int  obj_Caseless_Neql(Vm_Obj,Vm_Obj);
extern Vm_Int  obj_Neql(Vm_Obj,Vm_Obj);
extern Vm_Int  obj_StrNeql(Vm_Uch*,Vm_Obj);
extern Vm_Int  obj_StrCmp(Vm_Uch*,Vm_Int,Vm_Uch*,Vm_Int);
extern Vm_Uch* obj_Name(Vm_Uch*, Vm_Int, Vm_Obj);

extern Vm_Obj  obj_Alloc(    Vm_Unt, Vm_Unt                 );
extern Vm_Obj  obj_Alloc_In_Dbfile( Vm_Unt, Vm_Unt, Vm_Unt  );

extern Vm_Obj  obj_Init(     Vm_Obj, Vm_Unt, Vm_Int, Vm_Unt );
extern Vm_Obj  obj_Dup_In_Dbfile(  Vm_Obj, Vm_Unt                   );
extern Vm_Obj  obj_Dup(            Vm_Obj	                    );
extern Vm_Obj  obj_SizedDup(       Vm_Obj, Vm_Unt                   );
extern Vm_Obj  obj_Get_Mos_Key(	Vm_Obj	);
extern Vm_Obj  obj_Type_Get_Mos_Key( Vm_Obj );
extern void    obj_Dump_State( void );

extern void    obj_Set(      Vm_Obj,Vm_Obj,Vm_Obj );
extern Vm_Obj  obj_Get(      Vm_Obj,Vm_Obj 	  );
extern Vm_Obj  obj_Get_Asciz(Vm_Obj,Vm_Uch*	  );
extern void    obj_Del(      Vm_Obj,Vm_Obj        );
extern Vm_Obj  obj_First(    Vm_Obj               );
extern Vm_Obj  obj_Next(     Vm_Obj,Vm_Obj        );

extern void    obj_Hidden_Set(      Vm_Obj,Vm_Obj,Vm_Obj );
extern Vm_Obj  obj_Hidden_Get(      Vm_Obj,Vm_Obj 	 );
extern Vm_Obj  obj_Hidden_Get_Asciz(Vm_Obj,Vm_Uch*	 );
extern void    obj_Hidden_Del(      Vm_Obj,Vm_Obj        );
extern Vm_Obj  obj_Hidden_First(    Vm_Obj               );
extern Vm_Obj  obj_Hidden_Next(     Vm_Obj,Vm_Obj        );

extern void    obj_System_Set(      Vm_Obj,Vm_Obj,Vm_Obj );
extern Vm_Obj  obj_System_Get(      Vm_Obj,Vm_Obj 	 );
extern Vm_Obj  obj_System_Get_Asciz(Vm_Obj,Vm_Uch*	 );
extern void    obj_System_Del(      Vm_Obj,Vm_Obj        );
extern Vm_Obj  obj_System_First(    Vm_Obj               );
extern Vm_Obj  obj_System_Next(     Vm_Obj,Vm_Obj        );

extern void    obj_Admins_Set(      Vm_Obj,Vm_Obj,Vm_Obj );
extern Vm_Obj  obj_Admins_Get(      Vm_Obj,Vm_Obj 	 );
extern Vm_Obj  obj_Admins_Get_Asciz(Vm_Obj,Vm_Uch*	 );
extern void    obj_Admins_Del(      Vm_Obj,Vm_Obj        );
extern Vm_Obj  obj_Admins_First(    Vm_Obj               );
extern Vm_Obj  obj_Admins_Next(     Vm_Obj,Vm_Obj        );

#ifdef OLD
extern void    obj_Method_Set(      Vm_Obj,Vm_Obj,Vm_Obj );
extern Vm_Obj  obj_Method_Get(      Vm_Obj,Vm_Obj 	 );
extern Vm_Obj  obj_Method_Get_Asciz(Vm_Obj,Vm_Uch*	 );
extern void    obj_Method_Del(      Vm_Obj,Vm_Obj        );
extern Vm_Obj  obj_Method_First(    Vm_Obj               );
extern Vm_Obj  obj_Method_Next(     Vm_Obj,Vm_Obj        );
#endif

extern Vm_Obj  obj_X_First( Vm_Obj, Vm_Int 		 );
extern Vm_Obj  obj_X_Key( Vm_Obj, Vm_Obj, Vm_Obj, Vm_Int, Vm_Int );
extern Vm_Obj  obj_X_Del( Vm_Obj, Vm_Obj, Vm_Int 	 );
extern Vm_Obj  obj_X_Get( Vm_Obj, Vm_Obj, Vm_Int 	 );
extern Vm_Obj  obj_X_Get_Asciz( Vm_Obj, Vm_Uch*, Vm_Int  );
extern Vm_Obj  obj_X_Next( Vm_Obj, Vm_Obj, Vm_Int 	 );
extern Vm_Uch* obj_X_Set( Vm_Obj, Vm_Obj, Vm_Obj, Vm_Int );

extern Vm_Obj obj_X_Get_With_Inheritance(Vm_Obj*,Vm_Int*,Vm_Obj,Vm_Obj,Vm_Int);
extern Vm_Obj obj_X_Get_Asciz_With_Inheritance( Vm_Obj*,Vm_Int*,Vm_Obj,Vm_Uch*,Vm_Int);

extern void    obj_Free(     Vm_Obj               );

extern Vm_Obj  obj_False_Fn( void );
extern Vm_Obj  obj_True_Fn(  void );

extern Vm_Obj  obj_Bad_Hash( Vm_Obj ); /* A transitional hack */
extern Vm_Obj  obj_Hash_Immediate( Vm_Obj );
extern Vm_Obj  obj_Byteswap_8bit_Obj(  Vm_Obj );
extern Vm_Obj  obj_Byteswap_16bit_Obj( Vm_Obj );
extern Vm_Obj  obj_Byteswap_32bit_Obj( Vm_Obj );
extern Vm_Obj  obj_Byteswap_64bit_Obj( Vm_Obj );

extern Vm_Obj  obj_Myclass( Vm_Obj );
extern Vm_Obj  obj_Creator( Vm_Obj );
extern Vm_Obj  obj_Created( Vm_Obj );
extern Vm_Obj  obj_Changor( Vm_Obj );
extern Vm_Obj  obj_Changed( Vm_Obj );
extern Vm_Obj  obj_Owner(   Vm_Obj );
extern Vm_Obj  obj_Objname( Vm_Obj );
extern Vm_Obj  obj_Parents( Vm_Obj );
extern Vm_Obj  obj_Is_A(    Vm_Obj );
extern Vm_Obj  obj_Dbname(  Vm_Obj );

extern Vm_Obj  obj_Set_Myclass( Vm_Obj, Vm_Obj );
extern Vm_Obj  obj_Set_Creator( Vm_Obj, Vm_Obj );
extern Vm_Obj  obj_Set_Created( Vm_Obj, Vm_Obj );
extern Vm_Obj  obj_Set_Changor( Vm_Obj, Vm_Obj );
extern Vm_Obj  obj_Set_Changed( Vm_Obj, Vm_Obj );
#ifdef OLD
extern Vm_Obj  obj_Set_Owner(   Vm_Obj, Vm_Obj );
#endif
extern Vm_Obj  obj_Set_Objname( Vm_Obj, Vm_Obj );
extern Vm_Obj  obj_Set_Parents( Vm_Obj, Vm_Obj );
extern Vm_Obj  obj_Set_Is_A(    Vm_Obj, Vm_Obj );
extern Vm_Obj  obj_Set_Never(   Vm_Obj, Vm_Obj );

extern Vm_Int obj_Pointer_Type[];
extern Vm_Uch obj_Int_Compare_Ok[ 1 << OBJ_MAX_SHIFT /* Currently 1024 */ ];

extern Vm_Uch* obj_Propdir_Name[ OBJ_PROP_MAX ];

extern Obj_A_Hardcoded_Class obj_Hardcoded_Dum_Class;
extern Obj_A_Hardcoded_Class obj_Hardcoded_Obj_Class;
extern Obj_A_Hardcoded_Class obj_Hardcoded_Map_Class;
extern Obj_A_Hardcoded_Class obj_Hardcoded_Set_Class;

extern Obj_A_Module_Summary obj_Module_Summary;

extern Vm_Obj obj_Dummy_Reverse( Vm_Obj );

/*************************************************/
/* The following array contains all Vm_Obj vals  */
/* preserved by the interpreter between bytecode */
/* instructions, meaning that it is one set of   */
/* root pointers the garbage collector needs.    */
/*						 */
/* (The 'vm_Root' variable exported by vm.c is   */
/* another root. Currently, skt.c also has some	 */
/* roots of its own which skt_Mark() marks.)	 */
/*						 */
/* Note that the job.c:job_RunState record does  */
/* contain Vm_Obj fields, but that if we call    */
/* job_State_Update() before starting garbage    */
/* collection, everything in job_RunState can be */
/* reached via the current job, which can be     */
/* reached via obj_Etc_Run below, hence we don't */
/* need to include the job_RunState fields in    */
/* obj_GC_Root[].                                */
/*************************************************/
/* For readability and convenience, we #define	 */
/* names for the various obj_GC_Root[] slots so  */
/* that code can regard them as independent      */
/* global variables.  With any modern compiler,  */
/* they should be just as efficient as global    */
/* variables, too. obj_U_Root refers to /u/Root, */
/* and so forth.  OBJ_FROM_BOOL depends on	 */
/* obj_Lib_Muf_T and ...Nil being respectively	 */
/* first and second in obj_GC_Root[]:		 */
#define obj_Lib_Muf_T				obj_GC_Root[ 0]
#define obj_Lib_Muf_Nil				obj_GC_Root[ 1]
#define obj_Etc					obj_GC_Root[ 2]
#define obj_U					obj_GC_Root[ 3]
#define obj_U_Root				obj_GC_Root[ 4]
#define obj_U_Nul				obj_GC_Root[ 5]
#define obj_Etc_Bad				obj_GC_Root[ 6]
#define obj_Etc_Doz				obj_GC_Root[ 7]
#define obj_Etc_Stp				obj_GC_Root[ 8]
#define obj_Etc_Usr				obj_GC_Root[ 9]
#define obj_Etc_Jb0				obj_GC_Root[10]
#define obj_Lib					obj_GC_Root[11]
#define obj_Lib_Lisp				obj_GC_Root[12]
#define obj_Lib_Keyword				obj_GC_Root[13]
#define obj_Lib_Muf				obj_GC_Root[14]
#define obj_Muq					obj_GC_Root[15] /* muq.t */
#define obj_Ps					obj_GC_Root[16]
#define obj_Who					obj_GC_Root[17]
#define obj_Err					obj_GC_Root[18]
#define obj_Err_Abort				obj_GC_Root[19]
#define obj_Err_Broken_Pipe_Warning		obj_GC_Root[20]
#define obj_Err_Event				obj_GC_Root[21]
#define obj_Err_Kill				obj_GC_Root[22]
#define obj_Err_Read_From_Dead_Stream_Warning	obj_GC_Root[23]
#define obj_Err_Serious_Event			obj_GC_Root[24]
#define obj_Err_Simple_Event			obj_GC_Root[25]
#define obj_Err_Simple_Error			obj_GC_Root[26]
#define obj_Err_Server_Error			obj_GC_Root[27]
#define obj_Err_Urgent_Character_Warning	obj_GC_Root[28]
#define obj_Err_Write_To_Dead_Stream_Warning	obj_GC_Root[29]
#define obj_Lib_Muf_Do_Error			obj_GC_Root[30] /* cdt.t */
#define obj_Lib_Muf_Do_Signal			obj_GC_Root[31] /* cdt.t */
#define obj_Lib_Muf_Compile_Muf_File		obj_GC_Root[33] /* muf.t */
#define obj_Lib_Muf_Abrt        		obj_GC_Root[33] /* muf.t */
#define obj_Lib_Muf_Write_Stream_By_Lines	obj_GC_Root[34] /* muf.t */
#define obj_Lib_Muf_Apply_Lambda_List_Slowly	obj_GC_Root[35] /* muf.t */
#define obj_Lib_Muf_Do_Structure_Initforms	obj_GC_Root[36] /* muf.t */
#define obj_Lib_Muf_Class_T			obj_GC_Root[37] /* muf.t */
#define obj_Lib_Muf_List_Delete			obj_GC_Root[38] /* muf.t */
#define obj_Lib_Muf_Maybe_Write_Stream_Packet 	obj_GC_Root[39]
#define obj_Lib_Muf_Report_Event		obj_GC_Root[40]
#define obj_Lib_Muqnet                          obj_GC_Root[41]
#define obj_Lib_Muqnet_Maybe_Write_Stream_Packet obj_GC_Root[42]
#define obj_Lib_Muqnet_Del_Key			obj_GC_Root[43]
#define obj_Lib_Muqnet_Del_Key_P 	    	obj_GC_Root[44]
#define obj_Lib_Muqnet_Get_Key_P 	    	obj_GC_Root[45]
#define obj_Lib_Muqnet_Get_First_Key 	    	obj_GC_Root[46]
#define obj_Lib_Muqnet_Get_Keys_By_Prefix    	obj_GC_Root[47]
#define obj_Lib_Muqnet_Get_Next_Key      	obj_GC_Root[48]
#define obj_Lib_Muqnet_Get_Val           	obj_GC_Root[49]
#define obj_Lib_Muqnet_Get_Val_P         	obj_GC_Root[50]
#define obj_Lib_Muqnet_Keysvals_Block        	obj_GC_Root[51]
#define obj_Lib_Muqnet_Keys_Block        	obj_GC_Root[52]
#define obj_Lib_Muqnet_Set_From_Block        	obj_GC_Root[53]
#define obj_Lib_Muqnet_Set_From_Keysvals_Block	obj_GC_Root[54]
#define obj_Lib_Muqnet_Set_Val			obj_GC_Root[55]
#define obj_Lib_Muqnet_Vals_Block		obj_GC_Root[56]
#define obj_FolkBy_HashName			obj_GC_Root[57]
#define obj_Db					obj_GC_Root[58]
#define obj_Dil_Test_Slot			obj_GC_Root[59]
#define obj_Sil_Test_Slot			obj_GC_Root[60]
#define obj_Til_Test_Slot			obj_GC_Root[61]
#define obj_Sel_Test_Slot			obj_GC_Root[62]
#define obj_Mil_Test_Slot			obj_GC_Root[63]
#define obj_Pil_Test_Slot			obj_GC_Root[64]
#define OBJ_GC_ROOTS                    	            65
extern Vm_Obj obj_GC_Root[ OBJ_GC_ROOTS ];



extern Vm_Unt obj_Stackframes_Popped_After_Loop_Stack_Overflow;
extern Vm_Unt obj_Stackslots_Popped_After_Data_Stack_Overflow;


/***********************************************/
/* The following variables publish information */
/* gathered by the interim garbage collector.  */
/* These variables are likely to vanish when   */
/* the production garbage collector appears.   */
/***********************************************/
extern Vm_Unt obj_Objs_Recovered;
extern Vm_Unt obj_Objs_Remaining;
extern Vm_Unt obj_Byts_Recovered;
extern Vm_Unt obj_Byts_Remaining;
/* This variable controls interim garbage collection frequency: */
extern Vm_Unt obj_Bytes_Between_Garbage_Collections;

/* Include patches for optional modules: */
#define  MODULES_OBJ_H
#include "Modules.h"
#undef   MODULES_OBJ_H


/************************************************************************/
/*-    File variables */
#endif /* INCLUDED_OBJ_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

