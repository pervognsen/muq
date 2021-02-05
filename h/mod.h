
/*--   mod.h -- Header for mod.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_MOD_H
#define INCLUDED_MOD_H



/************************************************************************/
/*-    externs								*/

extern Obj_Hardcoded_Class mod_Hardcoded_Class[];
extern Obj_Module_Summary  mod_Module_Summary[];
extern Obj_Type_Summary    mod_Type_Summary[];



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
