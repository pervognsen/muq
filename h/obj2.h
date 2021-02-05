
/*--   obj2.h -- Secondary header for obj.c -- which see.		*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_OBJ2_H
#define INCLUDED_OBJ2_H


/* This file is separate from obj.h because jobbuild.c needs to	 */
/* include it, but jobbuild.c cannot include obj.h because obj.h */
/* includes jobprims.h, the output from jobbuild.c, and having   */
/* jobbuild.c include it's own output as input is a bad idea.	 */


/************************************************************************/
/*-    Macros to categorize our sortapointer format.			*/


/************************************************************************/
/*-    Overview on layout copied from obj.c:Overview:                   */

/* (See "Vm_Obj Tagbits" node in manual.)	*/

/* Remember to update job_P_ConstantP() */
/* when adding new constant types:      */

#define OBJ_TYPE_MAX  				 32
#define OBJ_TYPE_F64    		((Vm_Unt)31)
#define OBJ_TYPE_F32    		((Vm_Unt)30)
#define OBJ_TYPE_I32    		((Vm_Unt)29)
#define OBJ_TYPE_I16    		((Vm_Unt)28)
#define OBJ_TYPE_I01    		((Vm_Unt)27)
#define OBJ_TYPE_BYTN      		((Vm_Unt)26)
#define OBJ_TYPE_BYT7      		((Vm_Unt)25)
#define OBJ_TYPE_BYT6      		((Vm_Unt)24)
#define OBJ_TYPE_BYT5      		((Vm_Unt)23)
#define OBJ_TYPE_BYT4      		((Vm_Unt)22)
#define OBJ_TYPE_BYT3      		((Vm_Unt)21)
#define OBJ_TYPE_BYT2      		((Vm_Unt)20)
#define OBJ_TYPE_BYT1      		((Vm_Unt)19)
#define OBJ_TYPE_BYT0      		((Vm_Unt)18)
#define OBJ_TYPE_FLOAT    		((Vm_Unt)17)
#define OBJ_TYPE_INT      		((Vm_Unt)16)
#define OBJ_TYPE_THUNK    		((Vm_Unt)15)
#define OBJ_TYPE_CFN      		((Vm_Unt)14)
#define OBJ_TYPE_OBJ      		((Vm_Unt)13)
#define OBJ_TYPE_CONS     		((Vm_Unt)12)
#define OBJ_TYPE_SYMBOL   		((Vm_Unt)11)
#define OBJ_TYPE_CHAR     		((Vm_Unt)10)
#define OBJ_TYPE_STRUCT   		((Vm_Unt)9)
#define OBJ_TYPE_VEC      		((Vm_Unt)8)
#define OBJ_TYPE_BIGNUM   		((Vm_Unt)7)
#define OBJ_TYPE_BOTTOM    		((Vm_Unt)6)
#define OBJ_TYPE_BLK       		((Vm_Unt)5)
#define OBJ_TYPE_EPHEMERAL_LIST 	((Vm_Unt)4)
#define OBJ_TYPE_EPHEMERAL_VECTOR 	((Vm_Unt)3)
#define OBJ_TYPE_EPHEMERAL_STRUCT 	((Vm_Unt)2)
#define OBJ_TYPE_SPECIAL   		((Vm_Unt)1)

/* Macro to map pointer to one of above: */
#define OBJ_TYPE(o)   obj_Pointer_Type[ (o) & OBJ_MAXMASK ]

/* Macro to decide if we can do an integer obj_Neql: */
#define OBJ_INT_COMPARE_OK(o)   obj_Int_Compare_Ok[ (o) & OBJ_MAXMASK ]

/* NOTE: The +/- optimization in jobbuild.c:fast_prim_write()	*/
/* depends on ints being encoded by zero tags.			*/

#define OBJ_VEC_BITS    ((Vm_Unt)0)
#define OBJ_BYTN_BITS   ((Vm_Unt)1)

/* We use four lengths of tags */
/* at bottom of Vm_Obj vals:   */
#define OBJ_INT_SHIFT   (2)  /* Only on integers.            */
#define OBJ_MIN_SHIFT   (5)  /* On all non-immediate values. */
#define OBJ_MID_SHIFT   (8)  /* On most immediate values.    */
#define OBJ_MAX_SHIFT  (11)  /* SPECIAL and EPHEMERAL values.*/

/* 2-, 5-, 8- and 11-bit bitmasks: */
#define OBJ_INTMASK     ((((Vm_Unt)1)<<OBJ_INT_SHIFT)-(Vm_Unt)1)
#define OBJ_MINMASK     ((((Vm_Unt)1)<<OBJ_MIN_SHIFT)-(Vm_Unt)1)
#define OBJ_MIDMASK     ((((Vm_Unt)1)<<OBJ_MID_SHIFT)-(Vm_Unt)1)
#define OBJ_MAXMASK     ((((Vm_Unt)1)<<OBJ_MAX_SHIFT)-(Vm_Unt)1)

#define OBJ_K_FLOAT 		OBJ_MINMASK /* Code depends on 5-bit tail being all-1s. */
#define OBJ_K_BIGNUM    	((Vm_Unt)0x01D)
#define OBJ_K_STRUCT    	((Vm_Unt)0x01B)
#define OBJ_K_THUNK     	((Vm_Unt)0x019)
#define OBJ_K_CFN       	((Vm_Unt)0x017)
#define OBJ_K_OBJ       	((Vm_Unt)0x015)
#define OBJ_K_CONS      	((Vm_Unt)0x013)
#define OBJ_K_SYMBOL    	((Vm_Unt)0x011)
#define OBJ_K_VEC       	((Vm_Unt)0x00F)
#define OBJ_K_F64       	((Vm_Unt)0x00D)
#define OBJ_K_F32       	((Vm_Unt)0x00B)
#define OBJ_K_I32       	((Vm_Unt)0x009)
#define OBJ_K_I16       	((Vm_Unt)0x007)
#define OBJ_K_BYTN      	((Vm_Unt)0x005)
#define OBJ_K_I01       	((Vm_Unt)0x003)

#define OBJ_K_BYT0      	((Vm_Unt)0x0E1)
#define OBJ_K_BYT1      	((Vm_Unt)0x1E1)
#define OBJ_K_BYT2      	((Vm_Unt)0x2E1)
#define OBJ_K_BYT3      	((Vm_Unt)0x0C1)
#define OBJ_K_BYT4      	((Vm_Unt)0x4E1)
#define OBJ_K_BYT5      	((Vm_Unt)0x5E1)
#define OBJ_K_BYT6      	((Vm_Unt)0x6E1)
#define OBJ_K_BYT7      	((Vm_Unt)0x0A1)
#define OBJ_K_BOTTOM    	((Vm_Unt)0x061)
#define OBJ_K_EPHEMERAL_VECTOR 	((Vm_Unt)0x441)
#define OBJ_K_EPHEMERAL_STRUCT 	((Vm_Unt)0x341)
/*#define OBJ_K_EPHEMERAL_OBJECT 	((Vm_Unt)0x241)*/
#define OBJ_K_EPHEMERAL_LIST 	((Vm_Unt)0x141)
#define OBJ_K_SPECIAL   	((Vm_Unt)0x041)
#define OBJ_K_BLK       	((Vm_Unt)0x021)
#define OBJ_K_CHAR      	((Vm_Unt)0x001)

/* Buggo: We should now be checking for the bottom TWO  */
/* bits zero here, not just the bottom bit.  But when I */
/* restore the commented-out code, we crash and burn in */
/* the regression test.  No clue why.  The only problem */
/* with the old code is that we can't introduce complex */
/* values with tagbits 10 until we get this fixed, so I */
/* am going to ignore it for now: 98Mar10CrT		*/
/* 98Mar11CrT: Consistently dies in packet round trip   */
/* timings -- could this be float related or ???        */
#define OBJ_IS_INT(o)     /*(((o)&OBJ_INTMASK)==(Vm_Unt)0x000) */ (((o)&(Vm_Unt)1)^(Vm_Unt)1)/* Faster:)*/
#define OBJ_IS_FLOAT(o)	    (((o)&OBJ_MINMASK)==OBJ_K_FLOAT)
#define OBJ_IS_DOUBLE(o)    (((o)&OBJ_MINMASK)==OBJ_K_DOUBLE)
#define OBJ_IS_STRUCT(o)    (((o)&OBJ_MINMASK)==OBJ_K_STRUCT)
#define OBJ_IS_THUNK(o)	    (((o)&OBJ_MINMASK)==OBJ_K_THUNK)
#define OBJ_IS_CFN(o)	    (((o)&OBJ_MINMASK)==OBJ_K_CFN)
#define OBJ_IS_OBJ(o)	    (((o)&OBJ_MINMASK)==OBJ_K_OBJ)
#define OBJ_IS_CONS(o)	    (((o)&OBJ_MINMASK)==OBJ_K_CONS)
#define OBJ_IS_SYMBOL(o)    (((o)&OBJ_MINMASK)==OBJ_K_SYMBOL)
#define OBJ_IS_VEC(o)	    (((o)&OBJ_MINMASK)==OBJ_K_VEC)
#define OBJ_IS_I01(o)	    (((o)&OBJ_MINMASK)==OBJ_K_I01)
#define OBJ_IS_BYTN(o)	    (((o)&OBJ_MINMASK)==OBJ_K_BYTN)
#define OBJ_IS_I08(o)	    (((o)&OBJ_MINMASK)==OBJ_K_BYTN) /* Yes, identical to BYTN, at least for now */
#define OBJ_IS_I16(o)	    (((o)&OBJ_MINMASK)==OBJ_K_I16)
#define OBJ_IS_I32(o)	    (((o)&OBJ_MINMASK)==OBJ_K_I32)
#define OBJ_IS_F32(o)	    (((o)&OBJ_MINMASK)==OBJ_K_F32)
#define OBJ_IS_F64(o)	    (((o)&OBJ_MINMASK)==OBJ_K_F64)

#define OBJ_IS_BIGNUM(o)    (((o)&OBJ_MINMASK)==OBJ_K_BIGNUM)
#ifdef OLD
#define OBJ_IS_PROXY(o)     (((o)&OBJ_MINMASK)==OBJ_K_PROXY)
#define OBJ_IS_BYT0(o)	    (((o)&OBJ_MIDMASK)==OBJ_K_BYT0)
#define OBJ_IS_BYT1(o)	    (((o)&OBJ_MIDMASK)==OBJ_K_BYT1)
#define OBJ_IS_BYT2(o)	    (((o)&OBJ_MIDMASK)==OBJ_K_BYT2)
#define OBJ_IS_BYT3(o)	    (((o)&OBJ_MIDMASK)==OBJ_K_BYT3)
#else
#define OBJ_IS_BYT0(o)	    (((o)&OBJ_MAXMASK)==OBJ_K_BYT0)
#define OBJ_IS_BYT1(o)	    (((o)&OBJ_MAXMASK)==OBJ_K_BYT1)
#define OBJ_IS_BYT2(o)	    (((o)&OBJ_MAXMASK)==OBJ_K_BYT2)
#define OBJ_IS_BYT3(o)	    (((o)&OBJ_MIDMASK)==OBJ_K_BYT3)
#define OBJ_IS_BYT4(o)	    (((o)&OBJ_MAXMASK)==OBJ_K_BYT4)
#define OBJ_IS_BYT5(o)	    (((o)&OBJ_MAXMASK)==OBJ_K_BYT5)
#define OBJ_IS_BYT6(o)	    (((o)&OBJ_MAXMASK)==OBJ_K_BYT6)
#define OBJ_IS_BYT7(o)	    (((o)&OBJ_MIDMASK)==OBJ_K_BYT7)
#endif
#define OBJ_IS_BOTTOM(o)    (((o)&OBJ_MAXMASK)==OBJ_K_BOTTOM)
#define OBJ_IS_SPECIAL(o)   (((o)&OBJ_MAXMASK)==OBJ_K_SPECIAL)
#define OBJ_IS_EPHEMERAL(o) ((((o)&OBJ_MIDMASK)==(OBJ_K_SPECIAL&OBJ_MIDMASK))&&(((o)&OBJ_MAXMASK)!=OBJ_K_SPECIAL))
#define OBJ_IS_EPHEMERAL_VECTOR(o) (((o)&OBJ_MAXMASK)==OBJ_K_EPHEMERAL_VECTOR)
#define OBJ_IS_EPHEMERAL_STRUCT(o) (((o)&OBJ_MAXMASK)==OBJ_K_EPHEMERAL_STRUCT)
#define OBJ_IS_EPHEMERAL_LIST(o)   (((o)&OBJ_MAXMASK)==OBJ_K_EPHEMERAL_LIST)
#define OBJ_IS_CHAR(o)      (((o)&OBJ_MIDMASK)==OBJ_K_CHAR)
#define OBJ_IS_BLK(o)       (((o)&OBJ_MAXMASK)==OBJ_K_BLK)



/************************************************************************/
/*-    Macros to extract/encode info from/to our sortapointer formats:	*/

#define OBJ_TO_BOTTOM(a)    ((Vm_Unt)(a)>>OBJ_MAX_SHIFT)
#define OBJ_TO_FLOAT(a)     (obj_Kludge .o=(a)&~OBJ_MIDMASK,obj_Kludge .r)
#define OBJ_TO_FLOAT2(a)    (obj_Kludge2.o=(a)&~OBJ_MIDMASK,obj_Kludge2.r)
#define OBJ_TO_INT(a)       ((Vm_Int)(a)>>OBJ_INT_SHIFT)
#define OBJ_TO_SPECIAL(a)          ((Vm_Unt)(a)>>OBJ_MAX_SHIFT)
#define OBJ_TO_EPHEMERAL_LIST(a)   ((Vm_Unt)(a)>>OBJ_MAX_SHIFT)
#define OBJ_TO_EPHEMERAL_STRUCT(a) ((Vm_Unt)(a)>>OBJ_MAX_SHIFT)
#define OBJ_TO_EPHEMERAL_VECTOR(a) ((Vm_Unt)(a)>>OBJ_MAX_SHIFT)
#define OBJ_TO_UNT(a)       ((Vm_Unt)(a)>>OBJ_INT_SHIFT)
#define OBJ_TO_CHAR(a)      ((Vm_Unt)(a)>>OBJ_MID_SHIFT)
#define OBJ_TO_BLK(a)       ((Vm_Unt)(a)>>OBJ_MAX_SHIFT)


#define OBJ_FROM_BOTTOM(a)    ((Vm_Obj)(((Vm_Unt)(a)<<OBJ_MAX_SHIFT)|OBJ_K_BOTTOM))
#define OBJ_FROM_FLOAT(a)     (obj_Kludge .r=(a),obj_Kludge .o|OBJ_K_FLOAT)
#define OBJ_FROM_FLOAT2(a)    (obj_Kludge2.r=(a),obj_Kludge2.o|OBJ_K_FLOAT)
#define OBJ_FROM_INT(a)       ((Vm_Obj)((a)<<OBJ_INT_SHIFT))
#define OBJ_FROM_SPECIAL(a)          ((Vm_Obj)(((Vm_Unt)(a)<<OBJ_MAX_SHIFT)|OBJ_K_SPECIAL))
#define OBJ_FROM_EPHEMERAL_LIST(a)   ((Vm_Obj)(((Vm_Unt)(a)<<OBJ_MAX_SHIFT)|OBJ_K_EPHEMERAL_LIST))
#define OBJ_FROM_EPHEMERAL_STRUCT(a) ((Vm_Obj)(((Vm_Unt)(a)<<OBJ_MAX_SHIFT)|OBJ_K_EPHEMERAL_STRUCT))
#define OBJ_FROM_EPHEMERAL_VECTOR(a) ((Vm_Obj)(((Vm_Unt)(a)<<OBJ_MAX_SHIFT)|OBJ_K_EPHEMERAL_VECTOR))
#define OBJ_FROM_BLK(a)       ((Vm_Obj)(((Vm_Unt)(a)<<OBJ_MAX_SHIFT)|OBJ_K_BLK))
#define OBJ_FROM_UNT(a)       ((Vm_Obj)((a)<<OBJ_INT_SHIFT))
#define OBJ_FROM_CHAR(a)      ((Vm_Obj)(((Vm_Unt)(a)<<OBJ_MID_SHIFT)|OBJ_K_CHAR))
#define OBJ_FROM_BOOL(a)      obj_GC_Root[!(a)]


#define OBJ_FROM_DOUBLE(a)  ((a)&~OBJ_MINMASK|OBJ_K_DOUBLE)
#define OBJ_FROM_I01(a)     ((a)&~OBJ_MINMASK|OBJ_K_I01)
#ifdef OLD
#define OBJ_FROM_I16(a)     ((a)&~OBJ_MINMASK|OBJ_K_I16)
#define OBJ_FROM_I32(a)     ((a)&~OBJ_MINMASK|OBJ_K_I32)
#define OBJ_FROM_F32(a)     ((a)&~OBJ_MINMASK|OBJ_K_F32)
#define OBJ_FROM_F64(a)     ((a)&~OBJ_MINMASK|OBJ_K_F64)
#endif

#define S0 (VM_INTBITS-8)
#define S1 (VM_INTBITS-16)
#define S2 (VM_INTBITS-24)
#define S3 (VM_INTBITS-32)
#define S4 (VM_INTBITS-40)
#define S5 (VM_INTBITS-48)
#define S6 (VM_INTBITS-56)
#define OBJ_BYT0(a)   (((Vm_Unt)(a)>>S0)&(Vm_Unt)0xFF)
#define OBJ_BYT1(a)   (((Vm_Unt)(a)>>S1)&(Vm_Unt)0xFF)
#define OBJ_BYT2(a)   (((Vm_Unt)(a)>>S2)&(Vm_Unt)0xFF)
#define OBJ_BYT3(a)   (((Vm_Unt)(a)>>S3)&(Vm_Unt)0xFF)
#define OBJ_BYT4(a)   (((Vm_Unt)(a)>>S4)&(Vm_Unt)0xFF)
#define OBJ_BYT5(a)   (((Vm_Unt)(a)>>S5)&(Vm_Unt)0xFF)
#define OBJ_BYT6(a)   (((Vm_Unt)(a)>>S6)&(Vm_Unt)0xFF)
#define OBJ_FROM_BYT0                                (OBJ_K_BYT0) 
#define OBJ_FROM_BYT1(a)  ((Vm_Obj)(((Vm_Unt)(a)<<S0)|OBJ_K_BYT1))
#define OBJ_FROM_BYT2(a0,a1) \
  ((((Vm_Unt)(a0)&(Vm_Unt)0xFF)<<S0) \
  |(((Vm_Unt)(a1)&(Vm_Unt)0xFF)<<S1) \
  |OBJ_K_BYT2)
#define OBJ_FROM_BYT3(a0,a1,a2) \
  ((((Vm_Unt)(a0)&(Vm_Unt)0xFF)<<S0) \
  |(((Vm_Unt)(a1)&(Vm_Unt)0xFF)<<S1) \
  |(((Vm_Unt)(a2)&(Vm_Unt)0xFF)<<S2) \
  |OBJ_K_BYT3)
#define OBJ_FROM_BYT4(a0,a1,a2,a3) \
  ((((Vm_Unt)(a0)&(Vm_Unt)0xFF)<<S0) \
  |(((Vm_Unt)(a1)&(Vm_Unt)0xFF)<<S1) \
  |(((Vm_Unt)(a2)&(Vm_Unt)0xFF)<<S2) \
  |(((Vm_Unt)(a3)&(Vm_Unt)0xFF)<<S3) \
  |OBJ_K_BYT4)
#define OBJ_FROM_BYT5(a0,a1,a2,a3,a4) \
  ((((Vm_Unt)(a0)&(Vm_Unt)0xFF)<<S0) \
  |(((Vm_Unt)(a1)&(Vm_Unt)0xFF)<<S1) \
  |(((Vm_Unt)(a2)&(Vm_Unt)0xFF)<<S2) \
  |(((Vm_Unt)(a3)&(Vm_Unt)0xFF)<<S3) \
  |(((Vm_Unt)(a4)&(Vm_Unt)0xFF)<<S4) \
  |OBJ_K_BYT5)
#define OBJ_FROM_BYT6(a0,a1,a2,a3,a4,a5) \
  ((((Vm_Unt)(a0)&(Vm_Unt)0xFF)<<S0) \
  |(((Vm_Unt)(a1)&(Vm_Unt)0xFF)<<S1) \
  |(((Vm_Unt)(a2)&(Vm_Unt)0xFF)<<S2) \
  |(((Vm_Unt)(a3)&(Vm_Unt)0xFF)<<S3) \
  |(((Vm_Unt)(a4)&(Vm_Unt)0xFF)<<S4) \
  |(((Vm_Unt)(a5)&(Vm_Unt)0xFF)<<S5) \
  |OBJ_K_BYT6)
#define OBJ_FROM_BYT7(a0,a1,a2,a3,a4,a5,a6) \
  ((((Vm_Unt)(a0)&(Vm_Unt)0xFF)<<S0) \
  |(((Vm_Unt)(a1)&(Vm_Unt)0xFF)<<S1) \
  |(((Vm_Unt)(a2)&(Vm_Unt)0xFF)<<S2) \
  |(((Vm_Unt)(a3)&(Vm_Unt)0xFF)<<S3) \
  |(((Vm_Unt)(a4)&(Vm_Unt)0xFF)<<S4) \
  |(((Vm_Unt)(a5)&(Vm_Unt)0xFF)<<S5) \
  |(((Vm_Unt)(a6)&(Vm_Unt)0xFF)<<S6) \
  |OBJ_K_BYT7)

/* Macro to decide if Vm_Int will fit inside Vm_Obj: */
#define OBJ_CAN_HOLD_INT(i) (i == ((i << OBJ_INT_SHIFT) >> OBJ_INT_SHIFT))

/* Macro for dummy arguments: */
#define OBJ_DUMMY OBJ_FROM_INT((Vm_Unt)0)

#define OBJ_FIRST       OBJ_FROM_SPECIAL((Vm_Unt)0) /* Value which sorts before all other values. */
#define OBJ_NOT_FOUND   OBJ_FROM_SPECIAL((Vm_Unt)1) /* Value to return when search fails.         */
#define OBJ_BLOCK_START OBJ_FROM_SPECIAL((Vm_Unt)2) /* Value for [ to push on stack.              */
#define OBJ_ERROR_TAG   OBJ_FROM_SPECIAL((Vm_Unt)3) /* For catch-errors{ ...throw-error }.	  */
#define OBJ_NULL_DIL    OBJ_FROM_SPECIAL((Vm_Unt)4) /* For empty btrees.			  */
#define OBJ_NULL_SIL    OBJ_FROM_SPECIAL((Vm_Unt)5) /* For empty sorted btrees.			  */
#define OBJ_NULL_TIL    OBJ_FROM_SPECIAL((Vm_Unt)6) /* For empty 3-val btrees.		  	  */
#define OBJ_NULL_SEL    OBJ_FROM_SPECIAL((Vm_Unt)7) /* For empty 0-val btrees.		  	  */
#define OBJ_NULL_MIL    OBJ_FROM_SPECIAL((Vm_Unt)8) /* For empty 1-val btrees.		  	  */
#define OBJ_NULL_PIL    OBJ_FROM_SPECIAL((Vm_Unt)9) /* For empty 1-val btrees.		  	  */
#define OBJ_NULL_D3L    OBJ_FROM_SPECIAL((Vm_Unt)108) /* For empty 3D btrees.		  	  */

/* Generic FALSE, TRUE values: */
#define OBJ_0     OBJ_FROM_INT((Vm_Unt)0)
#define OBJ_NIL   OBJ_FROM_BOOL((Vm_Unt)0)
#define OBJ_TRUE  OBJ_FROM_BOOL((Vm_Unt)1)
#define OBJ_T     OBJ_FROM_BOOL((Vm_Unt)1)
#define OBJ_YES   OBJ_FROM_BYT3('y','e','s')
#define OBJ_NO    OBJ_FROM_BYT2('n','o')

/* ONLY use these if OBJ_IS_OBJ(obj) is true! */
#define OBJ_DEL(obj,key,propdir)       (*mod_Type_Summary[ OBJ_TYPE(obj) ]->for_del)( obj, key,      propdir )
#define OBJ_NEXT(obj,key,propdir)      (*mod_Type_Summary[ OBJ_TYPE(obj) ]->for_nxt)( obj, key,      propdir )
#define OBJ_GET(obj,key,propdir)       (*mod_Type_Summary[ OBJ_TYPE(obj) ]->for_get)( obj, key,      propdir )
#define OBJ_SET(obj,key,val,propdir)   (*mod_Type_Summary[ OBJ_TYPE(obj) ]->for_set)( obj, key, val, propdir )
#define OBJ_GET_ASCIZ(obj,key,propdir) (*mod_Type_Summary[ OBJ_TYPE(obj) ]->g_asciz)( obj, key,      propdir )




/************************************************************************/
/*-    File variables */
#endif /* INCLUDED_OBJ2_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

