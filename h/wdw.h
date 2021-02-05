
/*--   wdw.h -- Header for wdw.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_WDW_H
#define INCLUDED_WDW_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate a wdw: */
#define WDW_P(o) ((Wdw_Header)vm_Loc(o))

#define WDW_RESERVED_SLOTS 20

#define WDW_MAX_ACTIVE_WINDOWS 32
/* If you change WDW_MAX_ACTIVE_WINDOWS you will  */
/* need to edit olg.t:set_up_window_for_drawing() */

/************************************************************************/
/*-    types								*/
/************************************************************************/

/* Our refinement of Obj_Header_Rec: */
struct Wdw_Header_Rec {
    Obj_A_Header o;

    Vm_Obj id;

    Vm_Obj glut_display_func;
    Vm_Obj glut_reshape_func;
    Vm_Obj glut_mouse_func;
    Vm_Obj glut_motion_func;
    Vm_Obj glut_passive_motion_func;
    Vm_Obj glut_entry_func;
    Vm_Obj glut_keyboard_func;
    Vm_Obj glut_keyboard_up_func;   /* <-- */
    Vm_Obj glut_window_status_func; /* <-- */
    Vm_Obj glut_visibility_func;
    Vm_Obj glut_special_func;
    Vm_Obj glut_special_up_func;    /* <-- */
    Vm_Obj glut_button_box_func;
    Vm_Obj glut_dials_func;
    Vm_Obj glut_spaceball_motion_func;
    Vm_Obj glut_spaceball_rotate_func;
    Vm_Obj glut_spaceball_button_func;
    Vm_Obj glut_tablet_motion_func;
    Vm_Obj glut_tablet_button_func;

    Vm_Obj reserved_slot[ WDW_RESERVED_SLOTS ];
};
typedef struct Wdw_Header_Rec Wdw_A_Header;
typedef struct Wdw_Header_Rec*  Wdw_Header;
typedef struct Wdw_Header_Rec*  Wdw_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   wdw_Startup( void              );
extern void   wdw_Linkup(  void              );
extern void   wdw_Shutdown(void              );
#ifdef OLD
extern Vm_Obj wdw_Import(   FILE* );
extern void   wdw_Export(   FILE*, Vm_Obj );
#endif

extern Obj_A_Hardcoded_Class wdw_Hardcoded_Class;
extern Obj_A_Module_Summary  wdw_Module_Summary;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_WDW_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

