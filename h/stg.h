
/*--   stg.h -- Header for stg.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_STG_H
#define INCLUDED_STG_H



/************************************************************************/
/*-    Macros								*/

/* Basic macro to locate a string: */
#define STG_P(o) ((Stg_P)vm_Loc(o))



/************************************************************************/
/*-    Types								*/

/* Stgs are 'owned' by the last person to store them */
/* into the db.  This maintains the invariant that   */
/* every explicitly allocated byte of storage is     */
/* 'owned' by some specific person.                  */
struct Stg_Header_Rec {
    Vm_Uch     byte[VM_INTBYTES];
};
typedef struct Stg_Header_Rec Stg_A_Header;
typedef struct Stg_Header_Rec*  Stg_Header;
typedef struct Stg_Header_Rec*  Stg_P;



/************************************************************************/
/*-    Externs								*/

extern void    stg_Startup( void               );
extern void    stg_Linkup(  void               );
extern void    stg_Shutdown(void               );

extern void    stg_Print  (FILE*,Vm_Uch*,Vm_Obj);
extern void    stg_Print1 (FILE*,Vm_Uch*,Vm_Obj);
extern Vm_Uch* stg_Sprint( Vm_Uch*, Vm_Uch*, Vm_Obj );

extern Vm_Obj stg_Concatenate(Vm_Obj,Vm_Obj		);
extern Vm_Obj stg_From_Asciz(Vm_Uch*			);
extern Vm_Obj stg_From_Buffer(Vm_Uch*,Vm_Int		);
extern Vm_Obj stg_From_Spec(  Vm_Int, Vm_Unt		);
extern Vm_Obj i08_Alloc(Vm_Int,Vm_Uch);
extern Vm_Obj stg_From_Buffer_In_Db(Vm_Uch*,Vm_Int,Vm_Unt);
extern Vm_Obj stg_From_Asciz_In_Db(Vm_Uch*,Vm_Unt);
extern Vm_Obj stg_Dup_In_Db(Vm_Obj,Vm_Unt);

extern Vm_Obj stg_From_StackBlock(Vm_Obj,Vm_Int		);
extern Vm_Int stg_Get_Byte(  Vm_Uch*, Vm_Obj, Vm_Unt	);
extern void   stg_Set_Byte(  Vm_Obj, Vm_Unt, Vm_Uch	);

extern Vm_Int stg_Get_Bytes( Vm_Uch*, Vm_Int, Vm_Obj, Vm_Int );
extern Vm_Int stg_Set_Bytes( Vm_Uch*, Vm_Int, Vm_Obj, Vm_Int );
extern Vm_Int stg_Is_Stg(    Vm_Obj			);
extern Vm_Unt stg_Len(       Vm_Obj			);

extern Obj_A_Type_Summary   stg_Type_Summary;
extern Obj_A_Module_Summary stg_Module_Summary;




/************************************************************************/
/*-    File variables */
#endif /* INCLUDED_STG_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

