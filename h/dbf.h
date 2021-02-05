
/*--   dbf.h -- Header for dbf.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_DBF_H
#define INCLUDED_DBF_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a dbf: */
#define DBF_P(o) ((Dbf_Header)vm_Loc(o))

#define DBF_RESERVED_SLOTS 40

/************************************************************************/
/*-    types								*/

struct Dbf_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj bytes_between_garbage_collections;
    Vm_Obj date_of_last_garbage_collect;
    Vm_Obj millisecs_for_last_garbage_collect;
    Vm_Obj objs_recovered_in_last_garbage_collect;
    Vm_Obj byts_recovered_in_last_garbage_collect;
    Vm_Obj garbage_collects_done;
    Vm_Obj owner;	/* Owner for space quota purposes.   */

    Vm_Obj netinfo_til;
    Vm_Obj symbol_type_mil;
    Vm_Obj symbol_proplist_mil;

    Vm_Obj propdir_pil[ OBJ_PROP_MAX ];

    Vm_Obj reserved_slot[ DBF_RESERVED_SLOTS ];
};
typedef struct Dbf_Header_Rec Dbf_A_Header;
typedef struct Dbf_Header_Rec*  Dbf_Header;
typedef struct Dbf_Header_Rec*  Dbf_P;



/************************************************************************/
/*-    externs								*/

extern int        dbf_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    dbf_Sprint(  Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       dbf_Startup( void			);
extern void       dbf_Linkup(  void			);
extern void       dbf_Shutdown(void			);
#ifdef SOON
extern Vm_Obj     dbf_Import(   FILE* );
extern void       dbf_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj     dbf_Alloc( Vm_Unt		);
extern Vm_Obj     dbf_Dup(       Vm_Obj         );

extern Obj_A_Hardcoded_Class dbf_Hardcoded_Class;
extern Obj_A_Module_Summary  dbf_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_DBF_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

