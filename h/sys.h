
/*--   sys.h -- Header for sys.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_SYS_H
#define INCLUDED_SYS_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a stack: */
#define SYS_P(o) ((Sys_Header)vm_Loc(o))

#define SYS_RESERVED_SLOTS 128

/************************************************************************/
/*-    types								*/

struct Sys_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj              hostname;
    Vm_Obj              dns_name;
    Vm_Obj              dns_addr;
    Vm_Obj              muq_port;
    Vm_Obj              ip0;
    Vm_Obj              ip1;
    Vm_Obj              ip2;
    Vm_Obj              ip3;
    Vm_Obj              reserved_slot[ 128 ];
};
typedef struct Sys_Header_Rec Sys_A_Header;
typedef struct Sys_Header_Rec*  Sys_Header;
typedef struct Sys_Header_Rec*  Sys_P;



/************************************************************************/
/*-    externs								*/

extern Vm_Int   sys_Ip0;
extern Vm_Int   sys_Ip1;
extern Vm_Int   sys_Ip2;
extern Vm_Int   sys_Ip3;

extern Vm_Int   sys_Muq_Port;


extern int        sys_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    sys_Sprint(  Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       sys_Startup( void			);
extern void       sys_Linkup(  void			);
extern void       sys_Shutdown(void			);
#ifdef SOON
extern Vm_Obj     sys_Import(   FILE* );
extern void       sys_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Int     sys_Date_Usecs( void );

extern Vm_Obj     sys_Alloc( Vm_Unt		);
extern Vm_Obj     sys_Dup(       Vm_Obj         );

extern Obj_A_Hardcoded_Class sys_Hardcoded_Class;
extern Obj_A_Module_Summary  sys_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_SYS_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

