
/*--   sha.h -- Header for sha.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_SHA_H
#define INCLUDED_SHA_H



/************************************************************************/
/*-    #includes							*/

#include "vm.h"

/************************************************************************/
/*-    #defines								*/


/************************************************************************/
/*-    types								*/

struct Sha_Context_Record {
    Vm_Unt32 state[5];
    Vm_Unt32 count[2];	/* These two should prolly become one Vm_Unt64	*/
    Vm_Uch   buffer[64];
};
typedef struct Sha_Context_Record Sha_Context;



/************************************************************************/
/*-    externs								*/

extern void sha_Init(                      Sha_Context* );
extern void sha_Update(                    Sha_Context*, const Vm_Uch*, Vm_Int32 );
extern void sha_Final(  Vm_Uch digest[20], Sha_Context* );

extern void   sha_Digest( Vm_Uch  digest[20],Vm_Uch*, Vm_Unt );
extern void   sha_SignedDigest(  Vm_Uch digest[20], Vm_Uch signature[64],Vm_Uch*, Vm_Unt);
extern Vm_Int sha_InsecureHash(  Vm_Uch*, Vm_Unt );

#ifdef SOMETIME
extern void	sha_Startup(  void              );
extern void	sha_Linkup(   void              );
extern void	sha_Shutdown( void              );

extern Obj_A_Module_Summary  sha_Module_Summary;
#endif




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_SHA_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

