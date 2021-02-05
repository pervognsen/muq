
/*--   fun2.h -- Header for fun.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_FUN2_H
#define INCLUDED_FUN2_H



/************************************************************************/
/*-    #defines								*/

/****************************************************/
/* We store the number of stackblocks and arguments */
/* accepted and returned by the function in 'arity' */
/* and use the following macros to pack and unpack  */
/* these. (Packing them all into one word is partly */
/* penny-ante space conservation but mostly a speed */
/* hack, so we can do efficient runtime checking of */
/* the arity of arguments that are functions.)	    */
/*						    */
/* The current layout looks like:                   */
/*						    */
/*   MSB 33222222222211111111110000000000 LSB	    */
/*       10987654321098765432109876543210	    */
/*        S-----Ss-----sB----Bb----bt--tI	    */
/*						    */
/* where:					    */
/*   I:       1-bit typetag identifying integers.   */
/*   t--t:    4-bit type (see FUN_ARITY_TYP_*).	    */
/*   b----b:  6-bit count of stackblocks accepted.  */
/*   B----B:  6-bit count of stackblocks returned.  */
/*   s-----s: 7-bit count of scalar args accepted.  */
/*   S-----S: 7-bit count of scalar args returned.  */
/****************************************************/

#ifndef OBJ_INT_SHIFT
#define OBJ_INT_SHIFT (1)
#endif

#ifndef OBJ_0
#define OBJ_0 (0)
#endif

/* NB: Following values are often inserted */
/* literally (as 0 or 1) for conciseness.  */
/* Please update fun_Type[Name]() if you   */
/* change this list:			   */
#define FUN_ARITY_TYP_NORMAL      (0)	/* Normal operator.		*/
#define FUN_ARITY_TYP_EXIT        (1)	/* Operator that doen't return.	*/
#define FUN_ARITY_TYP_BRANCH      (2)	/* Operator that hacks pc.	*/
#define FUN_ARITY_TYP_OTHER       (3)	/* Remaining special cases.	*/
#define FUN_ARITY_TYP_CALLI       (4)	/* For JOB_OP_CALLI.		*/
#define FUN_ARITY_TYP_Q           (5)	/* For { -> ? } ops.		*/
#define FUN_ARITY_TYP_START_BLOCK (6)	/* For JOB_OP_START_BLOCK.	*/
#define FUN_ARITY_TYP_END_BLOCK   (7)	/* For JOB_OP_END_BLOCK.	*/
#define FUN_ARITY_TYP_EAT_BLOCK   (8)	/* For ']' operator.		*/
#define FUN_ARITY_TYP_CALLA       (9)	/* For JOB_OP_CALLA.		*/
#define FUN_ARITY_TYP_CALL_METHOD (10)	/* For JOB_OP_CALL_METHOD.	*/

#define FUN_ARITY_TYP_MAX     0x0F
#define FUN_ARITY_BLK_GET_MAX 0x3F
#define FUN_ARITY_BLK_RET_MAX 0x3F
#define FUN_ARITY_ARG_GET_MAX 0x7F
#define FUN_ARITY_ARG_RET_MAX 0x7F

#define FUN_ARITY_TYP_GET_SHIFT ( 0+OBJ_INT_SHIFT)
#define FUN_ARITY_BLK_GET_SHIFT ( 4+OBJ_INT_SHIFT)
#define FUN_ARITY_BLK_RET_SHIFT (10+OBJ_INT_SHIFT)
#define FUN_ARITY_ARG_GET_SHIFT (16+OBJ_INT_SHIFT)
#define FUN_ARITY_ARG_RET_SHIFT (23+OBJ_INT_SHIFT)

#define FUN_ARITY_TYP_GET_MASK (FUN_ARITY_TYP_MAX    <<FUN_ARITY_TYP_GET_SHIFT)
#define FUN_ARITY_BLK_GET_MASK (FUN_ARITY_BLK_GET_MAX<<FUN_ARITY_BLK_GET_SHIFT)
#define FUN_ARITY_BLK_RET_MASK (FUN_ARITY_BLK_RET_MAX<<FUN_ARITY_BLK_RET_SHIFT)
#define FUN_ARITY_ARG_GET_MASK (FUN_ARITY_ARG_GET_MAX<<FUN_ARITY_ARG_GET_SHIFT)
#define FUN_ARITY_ARG_RET_MASK (FUN_ARITY_ARG_RET_MAX<<FUN_ARITY_ARG_RET_SHIFT)

#define FUN_ARITY_TYP_GET(o) \
    (((o) & FUN_ARITY_TYP_GET_MASK) >> FUN_ARITY_TYP_GET_SHIFT)
#define FUN_ARITY_BLK_GET(o) \
    (((o) & FUN_ARITY_BLK_GET_MASK) >> FUN_ARITY_BLK_GET_SHIFT)
#define FUN_ARITY_BLK_RET(o) \
    (((o) & FUN_ARITY_BLK_RET_MASK) >> FUN_ARITY_BLK_RET_SHIFT)
#define FUN_ARITY_ARG_GET(o) \
    (((o) & FUN_ARITY_ARG_GET_MASK) >> FUN_ARITY_ARG_GET_SHIFT)
#define FUN_ARITY_ARG_RET(o) \
    (((o) & FUN_ARITY_ARG_RET_MASK) >> FUN_ARITY_ARG_RET_SHIFT)

#define FUN_SET_ARITY_TYP(o,i) \
    (((o)& ~FUN_ARITY_TYP_GET_MASK)| \
    (((i)&FUN_ARITY_TYP_MAX    ) << FUN_ARITY_TYP_GET_SHIFT))
#define FUN_SET_ARITY_BLK_GET(o,i) \
    (((o)& ~FUN_ARITY_BLK_GET_MASK)| \
    (((i)&FUN_ARITY_BLK_RET_MAX) << FUN_ARITY_BLK_GET_SHIFT))
#define FUN_SET_ARITY_BLK_RET(o,i) \
    (((o)& ~FUN_ARITY_BLK_RET_MASK)| \
    (((i)&FUN_ARITY_BLK_RET_MAX) << FUN_ARITY_BLK_RET_SHIFT))
#define FUN_SET_ARITY_ARG_GET(o,i) \
    (((o)& ~FUN_ARITY_ARG_GET_MASK)| \
    (((i)&FUN_ARITY_ARG_GET_MAX) << FUN_ARITY_ARG_GET_SHIFT))
#define FUN_SET_ARITY_ARG_RET(o,i) \
    (((o)& ~FUN_ARITY_ARG_RET_MASK)| \
    (((i)&FUN_ARITY_ARG_RET_MAX) << FUN_ARITY_ARG_RET_SHIFT))

/* Args are BlocksIn, BlocksOut, ScalarsIn, ScalarsOut, TyPe: */
#define FUN_ARITY(bi,bo,si,so,tp)	\
  FUN_SET_ARITY_TYP(			\
    FUN_SET_ARITY_BLK_GET(		\
      FUN_SET_ARITY_BLK_RET(		\
        FUN_SET_ARITY_ARG_GET(		\
          FUN_SET_ARITY_ARG_RET( 	\
	     OBJ_0,			\
	     (so)			\
	  ), (si)			\
        ),   (bo)			\
      ),     (bi)			\
    ),       (tp)			\
  )





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_FUN2_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

