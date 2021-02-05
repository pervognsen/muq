
/*--   cfn.h -- Header for cfn.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_CFN_H
#define INCLUDED_CFN_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define CFN_P(o) ((Cfn_Header)vm_Loc(o))

/* Macros to access bitbag field: */
#define CFN_TYPE_BITS (5)   		/* Number of bits in typefield.	*/
#define CFN_FLAG_BITS (4)   		/* Number of bitflags.		*/
#define CFN_BITS (CFN_TYPE_BITS+CFN_FLAG_BITS)
#define CFN_CONSTS_SHIFT (OBJ_INT_SHIFT+CFN_BITS)
#define CFN_TYPE_SHIFT OBJ_INT_SHIFT
#define CFN_TYPE_MASK (((1<<CFN_TYPE_BITS)-1)<<OBJ_INT_SHIFT)
#define CFN_TYPE(o) ((o)&CFN_TYPE_MASK)
#define CFN_SET_TYPE(o,i) (((o)&~CFN_TYPE_MASK) | ((i)<<CFN_TYPE_SHIFT))

/* Supported types of compiled functions. */
/* CFN_IS_PROMISE_OR_THUNK depends on     */
/* THUNK and PROMISE being 1st and 2nd:   */
#define CFN_TYPE_THUNK	      (0)	/* Evaluate-many-times thunk.	*/
#define CFN_TYPE_PROMISE      (1)	/* Evaluate-one-time thunk.	*/
#define CFN_TYPE_KEPTPROMISE  (2)	/* Above after evaluation.	*/
#define CFN_TYPE_FN	      (3)	/* Vanilla function.		*/
#define CFN_TYPE_LISPMACRO    (4)	/* Lisp compiletime function.	*/
#define CFN_TYPE_MUFMACRO     (5)	/* MUF  compiletime function.	*/
#define CFN_TYPE_PRIM         (6)	/* C-coded function, like '+.	*/
#define CFN_TYPE_GENERIC      (7)	/* Generic function.		*/
#define CFN_TYPE_MOS_GENERIC  (8)	/* MOS Generic function.	*/

/* Same, preshifted: */
#define CFN_T_THUNK	   (CFN_TYPE_THUNK	 << CFN_TYPE_SHIFT)
#define CFN_T_PROMISE      (CFN_TYPE_PROMISE	 << CFN_TYPE_SHIFT)
#define CFN_T_KEPTPROMISE  (CFN_TYPE_KEPTPROMISE << CFN_TYPE_SHIFT)
#define CFN_T_FN	   (CFN_TYPE_FN		 << CFN_TYPE_SHIFT)
#define CFN_T_LISPMACRO    (CFN_TYPE_LISPMACRO	 << CFN_TYPE_SHIFT)
#define CFN_T_MUFMACRO     (CFN_TYPE_MUFMACRO	 << CFN_TYPE_SHIFT)
#define CFN_T_PRIM         (CFN_TYPE_PRIM	 << CFN_TYPE_SHIFT)
#define CFN_T_GENERIC      (CFN_TYPE_GENERIC	 << CFN_TYPE_SHIFT)
#define CFN_T_MOS_GENERIC  (CFN_TYPE_MOS_GENERIC << CFN_TYPE_SHIFT)

/* Supported bitflags on compiled functions: */
#define CFN_PLEASE_INLINE_SHIFT (0)	/* Inlining requested.		*/
#define CFN_NEVER_INLINE_SHIFT  (1)	/* Inlining forbidden.		*/
#define CFN_AS_ROOT_SHIFT	(2)	/* Uses as-root{...} construct.	*/
#define CFN_UNUSED_SHIFT	(3)	/* Reserved.			*/

#define CFN_PLEASE_INLINE_MASK \
    (1<<( CFN_PLEASE_INLINE_SHIFT  +CFN_TYPE_SHIFT+CFN_TYPE_BITS))
#define CFN_NEVER_INLINE_MASK \
    (1<<( CFN_NEVER_INLINE_SHIFT   +CFN_TYPE_SHIFT+CFN_TYPE_BITS))
#define CFN_AS_ROOT_MASK \
    (1<<( CFN_AS_ROOT_SHIFT        +CFN_TYPE_SHIFT+CFN_TYPE_BITS))
#define CFN_UNUSED_MASK \
    (1<<( CFN_UNUSED_SHIFT         +CFN_TYPE_SHIFT+CFN_TYPE_BITS))

#define CFN_CONSTS_MASK      (~0 << CFN_CONSTS_SHIFT)

#define CFN_IS_COMPILETIME(o)	   (CFN_TYPE(o)==CFN_T_MUFMACRO)
#define CFN_IS_THUNK(o)		   (CFN_TYPE(o)==CFN_T_THUNK)
#define CFN_IS_PROMISE(o)          (CFN_TYPE(o)==CFN_T_PROMISE)
#define CFN_IS_PROMISE_OR_THUNK(o) (CFN_TYPE(o)<=CFN_T_PROMISE)
#define CFN_IS_KEPTPROMISE(o)      (CFN_TYPE(o)==CFN_T_KEPTPROMISE)
#define CFN_IS_PRIM(o)             (CFN_TYPE(o)==CFN_T_PRIM)
#define CFN_IS_GENERIC(o)          (CFN_TYPE(o)==CFN_T_GENERIC)
#define CFN_IS_MOS_GENERIC(o)      (CFN_TYPE(o)==CFN_T_MOS_GENERIC)
#define CFN_IS_FN(o)		   (CFN_TYPE(o)==CFN_T_FN)
#define CFN_IS_AS_ROOT(o)          ((o) & CFN_AS_ROOT_MASK)
#define CFN_IS_NEVER_INLINE(o)     ((o) & CFN_NEVER_INLINE_MASK)
#define CFN_IS_PLEASE_INLINE(o)    ((o) & CFN_PLEASE_INLINE_MASK)

#define CFN_SET_COMPILETIME(o)  CFN_SET_TYPE((o),CFN_TYPE_MUFMACRO)
#define CFN_SET_THUNK(o)        CFN_SET_TYPE((o),CFN_TYPE_THUNK)
#define CFN_SET_PROMISE(o)      CFN_SET_TYPE((o),CFN_TYPE_PROMISE)
#define CFN_SET_KEPTPROMISE(o)  CFN_SET_TYPE((o),CFN_TYPE_KEPTPROMISE)
#define CFN_SET_PRIM(o)         CFN_SET_TYPE((o),CFN_TYPE_PRIM)
#define CFN_SET_GENERIC(o)      CFN_SET_TYPE((o),CFN_TYPE_GENERIC)
#define CFN_SET_MOS_GENERIC(o)  CFN_SET_TYPE((o),CFN_TYPE_MOS_GENERIC)
#define CFN_SET_FN(o)           CFN_SET_TYPE((o),CFN_TYPE_FN)
#define CFN_SET_AS_ROOT(o)       ((o) | CFN_AS_ROOT_MASK       )
#define CFN_SET_NEVER_INLINE(o)  ((o) | CFN_NEVER_INLINE_MASK  )
#define CFN_SET_PLEASE_INLINE(o) ((o) | CFN_PLEASE_INLINE_MASK )


#define CFN_CONSTS(o) (((Vm_Int)(o)) >> CFN_CONSTS_SHIFT)
#define CFN_SET_CONSTS(o,i) (((o)&CFN_CONSTS_MASK) | ((i)<<CFN_CONSTS_SHIFT))



/************************************************************************/
/*-    types								*/

struct Cfn_Header_Rec {
    Vm_Obj is_a;	/* Pointer to struct definition.	*/
    Vm_Obj     src;	/* Our source function.				*/
    Vm_Obj     bitbag;	/* Const count, compiletime/thunk/... flags	*/
    Vm_Obj     vec[ 1 ];
};
typedef struct Cfn_Header_Rec Cfn_A_Header;
typedef struct Cfn_Header_Rec*  Cfn_Header;
typedef struct Cfn_Header_Rec*  Cfn_P;



/************************************************************************/
/*-    externs								*/

extern int        cfn_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    cfn_Sprint(    Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       cfn_Startup( void			);
extern void       cfn_Linkup(  void			);
extern void       cfn_Shutdown(void			);
extern Vm_Int     cfn_Bytes_Of_Code(   Vm_Obj   );

extern Vm_Obj     cfn_Alloc( Vm_Unt, Vm_Uch	);
extern Vm_Obj     cfn_Dup(   Vm_Obj             );
extern Vm_Int     cfn_Len(   Vm_Obj             );

extern Obj_A_Type_Summary   cfn_Type_Summary;
extern Obj_A_Module_Summary cfn_Module_Summary;






/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_CFN_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

