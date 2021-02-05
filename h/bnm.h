
/*--   bnm.h -- Header for bnm.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_BNM_H
#define INCLUDED_BNM_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a string: */
#define BNM_P(o) ((Bnm_P)vm_Loc(o))

#define BNM_DIFFIE_HELLMAN_PRIVATE_KEY	 (1)
#define BNM_DIFFIE_HELLMAN_SHARED_SECRET (2)


#define BNM_THE_NEGATIVE_FIXNUM_WITH_NO_MATCHING_POSITIVE_FIXNUM \
    (((Vm_Int)(~((~((Vm_Unt)0))>>1)))>>OBJ_INT_SHIFT)

/************************************************************************/
/*-    types								*/

#define BNM_HEADER_REC(name,siz)							\
struct name {										\
    Vm_Obj   is_a;									\
    Vm_Int32 private;									\
    Vm_Int32 sign;									\
    Vm_Unt   physicalLength;/* Actual length of slot[]				*/	\
    Vm_Unt   length;	/* Logical length of slot[] -- may be less than above	*/	\
    Vm_Unt   slot[siz];									\
}

BNM_HEADER_REC(Bnm_Header_Rec,1);

typedef struct Bnm_Header_Rec Bnm_A_Header;
typedef struct Bnm_Header_Rec*  Bnm_Header;
typedef struct Bnm_Header_Rec*  Bnm_P;



/************************************************************************/
/*-    externs								*/

extern Obj_A_Type_Summary    bnm_Type_Summary;
extern Obj_A_Module_Summary  bnm_Module_Summary;

extern Vm_Obj bnm_Alloc( Vm_Unt, Vm_Unt );
extern Vm_Obj bnm_Alloc_Asciz( Vm_Uch*  );

extern void bnm_Print( Vm_Uch* ); /* buggo, strictly temp debug hack */
extern Vm_Obj bnm_Add( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Mult( Vm_Obj, Vm_Obj, Bnm_P );
extern Vm_Obj bnm_MultBI(Vm_Obj,Vm_Obj );
extern Vm_Obj bnm_MultII(Vm_Int,Vm_Int );
extern Vm_Obj bnm_AddBI(Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_AddII(Vm_Int, Vm_Int );
extern int    bnm_Bits(      Vm_Obj );
extern int    bnm_VmuntBits( Vm_Unt );
extern Vm_Obj bnm_Sub( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_SubBI( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_SubIB( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_SubII( Vm_Int, Vm_Int );
extern Vm_Obj bnm_Div( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_DivBI( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_DivIB( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Mod( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_ModBI( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_ModIB( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Divmod( Vm_Obj*, Vm_Obj, Vm_Obj, Bnm_P, Bnm_P );
extern Vm_Obj bnm_Egcd(   Vm_Obj*, Vm_Obj*, Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_EgcdBI( Vm_Obj*, Vm_Obj*, Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_EgcdIB( Vm_Obj*, Vm_Obj*, Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_EgcdII( Vm_Obj*, Vm_Obj*, Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_BgcdBI(Vm_Obj,Vm_Obj );
extern Vm_Obj bnm_Bgcd( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Pow(  Vm_Obj, Vm_Unt, Bnm_P );
extern Vm_Obj bnm_PowI( Vm_Obj, Vm_Unt );
extern Vm_Obj bnm_Neg( Vm_Obj         );
extern Vm_Int bnm_NeqlBB(Vm_Obj,Vm_Obj);
extern Vm_Int bnm_NeqlBI(Vm_Obj,Vm_Int);
extern Vm_Int bnm_NeqlIB(Vm_Int,Vm_Obj);
extern Vm_Obj bnm_TrulyRandomInteger( Vm_Unt );
extern Vm_Obj bnm_Logand( Vm_Obj, Vm_Obj, Bnm_P );
extern Vm_Obj bnm_LogandBI( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Logior(  Vm_Obj, Vm_Obj, Bnm_P );
extern Vm_Obj bnm_LogiorBI( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Logxor( Vm_Obj, Vm_Obj, Bnm_P );
extern Vm_Obj bnm_LogxorBI( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Lognot( Vm_Obj );
extern Vm_Obj bnm_Equal( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Morethan( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Leftshift( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_LeftshiftII( Vm_Int, Vm_Int );
extern Vm_Obj bnm_Rightshift( Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Exptmod(  Vm_Obj, Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Generate_Diffie_Hellman_Key_Pair( Vm_Obj*, Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Generate_Diffie_Hellman_Shared_Secret( Vm_Obj, Vm_Obj, Vm_Obj );
extern Vm_Obj bnm_Dup( Vm_Obj );
extern Vm_Obj bnm_Smallest_Positive_Bignum( void );



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_BNM_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

