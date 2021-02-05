@example  @c
/*--   wdw.c -- GLUT windows for Muq.					*/
/*- This file is formatted for outline-minor-mode in emacs19.		*/
/*-^C^O^A shows All of file.						*/
/* ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	*/
/* ^C^O^T hides all Text. (Leaves all headings.)			*/
/* ^C^O^I shows Immediate children of node.				*/
/* ^C^O^S Shows all of a node.						*/
/* ^C^O^D hiDes all of a node.						*/
/* ^HFoutline-mode gives more details.					*/
/* (Or do ^HI and read emacs:outline mode.)				*/

/************************************************************************/
/*-    Dedication and Copyright.					*/
/************************************************************************/

/************************************************************************/
/*									*/
/*		For Firiss:  Aefrit, a friend.				*/
/*									*/
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      95Apr25						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1996, by Jeff Prothero.				*/
/*									*/
/* This program is free software; you may use, distribute and/or modify	*/
/* it under the terms of the GNU Library General Public License as      */
/* published by	the Free Software Foundation; either version 2, or (at  */
/* your option)	any later version FOR NONCOMMERCIAL PURPOSES.		*/
/*									*/
/*  COMMERCIAL operation allowable at $100/CPU/YEAR.			*/
/*  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		*/
/*  Other commercial arrangements NEGOTIABLE.				*/
/*  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			*/
/*									*/
/*   This program is distributed in the hope that it will be useful,	*/
/*   but WITHOUT ANY WARRANTY; without even the implied warranty of	*/
/*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	*/
/*   GNU Library General Public License for more details.		*/
/*									*/
/*   You should have received the GNU Library General Public License	*/
/*   along with this program (COPYING.LIB); if not, write to:		*/
/*      Free Software Foundation, Inc.					*/
/*      675 Mass Ave, Cambridge, MA 02139, USA.				*/
/*									*/
/* Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
/* INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	*/
/* NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	*/
/* CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	*/
/* OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		*/
/* NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	*/
/* WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.			*/
/*									*/
/* Please send bug reports/fixes etc to bugs@@muq.org.			*/
/************************************************************************/



/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/************************************************************************


 ************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Tunable parameters: */

/* Stuff you shouldn't need to fiddle with: */



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_wdw( Vm_Unt );

static Vm_Obj	wdw_glut_button_box_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_dials_func(		Vm_Obj	);
static Vm_Obj	wdw_glut_display_func(		Vm_Obj	);
static Vm_Obj	wdw_glut_entry_func(		Vm_Obj	);
static Vm_Obj	wdw_glut_keyboard_func(	  	Vm_Obj	);
static Vm_Obj	wdw_glut_keyboard_up_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_motion_func(	  	Vm_Obj	);
static Vm_Obj	wdw_glut_mouse_func(	  	Vm_Obj	);
static Vm_Obj	wdw_glut_passive_motion_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_reshape_func(		Vm_Obj	);
static Vm_Obj	wdw_glut_spaceball_button_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_spaceball_motion_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_spaceball_rotate_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_special_func(		Vm_Obj	);
static Vm_Obj	wdw_glut_special_up_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_tablet_button_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_tablet_motion_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_visibility_func(	Vm_Obj	);
static Vm_Obj	wdw_glut_window_status_func(	Vm_Obj	);
static Vm_Obj	wdw_id(			  	Vm_Obj	);

static Vm_Obj	wdw_set_glut_button_box_func(		Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_dials_func(		Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_display_func(		Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_entry_func(		Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_keyboard_func(	  	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_keyboard_up_func(	  	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_motion_func(	  	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_mouse_func(	  	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_passive_motion_func(	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_reshape_func(		Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_spaceball_button_func(	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_spaceball_motion_func(	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_spaceball_rotate_func(	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_special_func(		Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_special_up_func(		Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_tablet_button_func(	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_tablet_motion_func(	Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_visibility_func(		Vm_Obj, Vm_Obj	);
static Vm_Obj	wdw_set_glut_window_status_func(	Vm_Obj, Vm_Obj	);


static Vm_Obj wdw_set_never( Vm_Obj, Vm_Obj );

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property wdw_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

{0,"id",wdw_id,wdw_set_never},
{0,"glutButtonBoxFunc",wdw_glut_button_box_func,wdw_set_glut_button_box_func},
{0,"glutDialsFunc",wdw_glut_dials_func,wdw_set_glut_dials_func},
{0,"glutDisplayFunc",wdw_glut_display_func,wdw_set_glut_display_func},
{0,"glutEntryFunc",wdw_glut_entry_func,wdw_set_glut_entry_func},
{0,"glutKeyboardFunc",wdw_glut_keyboard_func,wdw_set_glut_keyboard_func},
{0,"glutKeyboardUpFunc",wdw_glut_keyboard_up_func,wdw_set_glut_keyboard_up_func},
{0,"glutMotionFunc",wdw_glut_motion_func,wdw_set_glut_motion_func},
{0,"glutMouseFunc",wdw_glut_mouse_func,wdw_set_glut_mouse_func},
{0,"glutPassiveMotionFunc",wdw_glut_passive_motion_func,wdw_set_glut_passive_motion_func},
{0,"glutReshapeFunc",wdw_glut_reshape_func,wdw_set_glut_reshape_func},
{0,"glutSpaceballButtonFunc",wdw_glut_spaceball_button_func,wdw_set_glut_spaceball_button_func},
{0,"glutSpaceballMotionFunc",wdw_glut_spaceball_motion_func,wdw_set_glut_spaceball_motion_func},
{0,"glutSpaceballRotateFunc",wdw_glut_spaceball_rotate_func,wdw_set_glut_spaceball_rotate_func},
{0,"glutSpecialFunc",wdw_glut_special_func,wdw_set_glut_special_func},
{0,"glutSpecialUpFunc",wdw_glut_special_up_func,wdw_set_glut_special_up_func},
{0,"glutTabletButtonFunc",wdw_glut_tablet_button_func,wdw_set_glut_tablet_button_func},
{0,"glutTabletMotionFunc",wdw_glut_tablet_motion_func,wdw_set_glut_tablet_motion_func},
{0,"glutVisibilityFunc",wdw_glut_visibility_func,wdw_set_glut_visibility_func},
{0,"glutWindowStatusFunc",wdw_glut_window_status_func,wdw_set_glut_window_status_func},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class wdw_Hardcoded_Class = {
    OBJ_FROM_BYT3('w','d','w'),
    "Window",
    sizeof_wdw,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { wdw_system_properties, wdw_system_properties, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void wdw_doTypes(void){}
Obj_A_Module_Summary wdw_Module_Summary = {
   "wdw",
    wdw_doTypes,
    wdw_Startup,
    wdw_Linkup,
    wdw_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    wdw_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
wdw_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    wdw_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
wdw_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    wdw_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
wdw_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    wdw_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
wdw_Import(
    FILE* fd
) {
    MUQ_FATAL ("wdw_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    wdw_Export -- Write object into textfile.			*/
/************************************************************************/

void
wdw_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("wdw_Export unimplemented");
}


#endif








/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new wdw object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    {   Wdw_P s 	= WDW_P(o);

	s->id				= OBJ_FROM_INT(0);

	s->glut_mouse_func		= OBJ_NIL;
	s->glut_motion_func		= OBJ_NIL;
	s->glut_passive_motion_func	= OBJ_NIL;
	s->glut_display_func		= OBJ_NIL;
	s->glut_reshape_func		= OBJ_NIL;
	s->glut_keyboard_func		= OBJ_NIL;
	s->glut_keyboard_up_func	= OBJ_NIL;
	s->glut_visibility_func		= OBJ_NIL;
	s->glut_entry_func		= OBJ_NIL;
	s->glut_special_func		= OBJ_NIL;
	s->glut_special_up_func		= OBJ_NIL;
	s->glut_spaceball_motion_func	= OBJ_NIL;
	s->glut_spaceball_rotate_func	= OBJ_NIL;
	s->glut_spaceball_button_func	= OBJ_NIL;
	s->glut_button_box_func		= OBJ_NIL;
	s->glut_dials_func		= OBJ_NIL;
	s->glut_tablet_motion_func	= OBJ_NIL;
	s->glut_tablet_button_func	= OBJ_NIL;
	s->glut_window_status_func	= OBJ_NIL;

	{   int i;
	    for (i = WDW_RESERVED_SLOTS;  i --> 0; ) s->reserved_slot[i] = OBJ_FROM_INT(0);
	}

	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_wdw -- Return size of proxy.				*/
/************************************************************************/

static Vm_Unt
sizeof_wdw(
    Vm_Unt size
) {
    return sizeof( Wdw_A_Header );
}


/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    wdw_id			       					*/
/************************************************************************/

static Vm_Obj
wdw_id(
    Vm_Obj o
) {
    return WDW_P(o)->id;
}

/************************************************************************/
/*-    wdw_glut_keyboard_func       					*/
/************************************************************************/

static Vm_Obj
wdw_glut_keyboard_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_keyboard_func;
}

/************************************************************************/
/*-    wdw_glut_keyboard_up_func       					*/
/************************************************************************/

static Vm_Obj
wdw_glut_keyboard_up_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_keyboard_up_func;
}

/************************************************************************/
/*-    wdw_glut_mouse_func       					*/
/************************************************************************/

static Vm_Obj
wdw_glut_mouse_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_mouse_func;
}

/************************************************************************/
/*-    wdw_glut_motion_func       					*/
/************************************************************************/

static Vm_Obj
wdw_glut_motion_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_motion_func;
}

/************************************************************************/
/*-    wdw_glut_passive_motion_func    					*/
/************************************************************************/

static Vm_Obj
wdw_glut_passive_motion_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_passive_motion_func;
}

/************************************************************************/
/*-    wdw_glut_display_func    					*/
/************************************************************************/

static Vm_Obj
wdw_glut_display_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_display_func;
}

/************************************************************************/
/*-    wdw_glut_rehape_func   						*/
/************************************************************************/

static Vm_Obj
wdw_glut_reshape_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_reshape_func;
}

/************************************************************************/
/*-    wdw_glut_visibility_func   					*/
/************************************************************************/

static Vm_Obj
wdw_glut_visibility_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_visibility_func;
}

/************************************************************************/
/*-    wdw_glut_entry_func   						*/
/************************************************************************/

static Vm_Obj
wdw_glut_entry_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_entry_func;
}

/************************************************************************/
/*-    wdw_glut_special_func   						*/
/************************************************************************/

static Vm_Obj
wdw_glut_special_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_special_func;
}

/************************************************************************/
/*-    wdw_glut_special_up_func   					*/
/************************************************************************/

static Vm_Obj
wdw_glut_special_up_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_special_up_func;
}

/************************************************************************/
/*-    wdw_glut_spaceball_motion_func   				*/
/************************************************************************/

static Vm_Obj
wdw_glut_spaceball_motion_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_spaceball_motion_func;
}

/************************************************************************/
/*-    wdw_glut_spaceball_rotate_func   				*/
/************************************************************************/

static Vm_Obj
wdw_glut_spaceball_rotate_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_spaceball_rotate_func;
}

/************************************************************************/
/*-    wdw_glut_spaceball_button_func   				*/
/************************************************************************/

static Vm_Obj
wdw_glut_spaceball_button_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_spaceball_button_func;
}

/************************************************************************/
/*-    wdw_glut_button_bot_func 	  				*/
/************************************************************************/

static Vm_Obj
wdw_glut_button_box_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_button_box_func;
}

/************************************************************************/
/*-    wdw_glut_dials_func 	 	 				*/
/************************************************************************/

static Vm_Obj
wdw_glut_dials_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_dials_func;
}

/************************************************************************/
/*-    wdw_glut_tablet_motion_func 	  				*/
/************************************************************************/

static Vm_Obj
wdw_glut_tablet_motion_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_tablet_motion_func;
}

/************************************************************************/
/*-    wdw_glut_tablet_button_func 	  				*/
/************************************************************************/

static Vm_Obj
wdw_glut_tablet_button_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_tablet_button_func;
}

/************************************************************************/
/*-    wdw_glut_window_status_func 	  				*/
/************************************************************************/

static Vm_Obj
wdw_glut_window_status_func(
    Vm_Obj o
) {
    return WDW_P(o)->glut_window_status_func;
}

/************************************************************************/
/*-    wdw_set_glut_keyboard_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_keyboard_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_keyboard_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_keyboard_up_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_keyboard_up_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_keyboard_up_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_mouse_func						*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_mouse_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_mouse_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_motion_func						*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_motion_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_motion_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_passive_motion_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_passive_motion_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_passive_motion_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_display_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_display_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_display_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_reshape_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_reshape_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_reshape_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_visibility_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_visibility_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_visibility_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_entry_func						*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_entry_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_entry_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_special_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_special_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_special_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_special_up_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_special_up_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_special_up_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_spaceball_motion_func				*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_spaceball_motion_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_spaceball_motion_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_spaceball_rotate_func				*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_spaceball_rotate_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_spaceball_rotate_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_spaceball_button_func				*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_spaceball_button_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_spaceball_button_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_button_box_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_button_box_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_button_box_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_dials_func						*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_dials_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_dials_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_tablet_motion_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_tablet_motion_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_tablet_motion_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_tablet_button_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_tablet_button_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_tablet_button_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_glut_window_status_func					*/
/************************************************************************/

static Vm_Obj
wdw_set_glut_window_status_func(
    Vm_Obj o,
    Vm_Obj v
) {
    WDW_P(o)->glut_tablet_button_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    wdw_set_never	 						*/
/************************************************************************/

static Vm_Obj
wdw_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    File variables							*/
/************************************************************************/
/*

Local variables:
mode: c
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

@end example
