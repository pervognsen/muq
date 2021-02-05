@example  @c
/*--   mtd.c -- MeTHods for Muq Object System support.			*/
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
/* Created:      96Mar03						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1997, by Jeff Prothero.				*/
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
static Vm_Unt   sizeof_mtd( Vm_Unt );

static Vm_Obj	mtd_qualifier(      Vm_Obj	   );
static Vm_Obj	mtd_method_fn(      Vm_Obj	   );
static Vm_Obj	mtd_generic_fn(     Vm_Obj	   );
static Vm_Obj	mtd_lambda_list(    Vm_Obj	   );
static Vm_Obj	mtd_required_args(  Vm_Obj	   );


static Vm_Obj	mtd_set_qualifier(          Vm_Obj, Vm_Obj );
static Vm_Obj	mtd_set_method_fn(          Vm_Obj, Vm_Obj );
static Vm_Obj	mtd_set_generic_fn(         Vm_Obj, Vm_Obj );
static Vm_Obj	mtd_set_lambda_list(        Vm_Obj, Vm_Obj );
static Vm_Obj	mtd_set_never(              Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property mtd_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"qualifier",		mtd_qualifier,		mtd_set_qualifier},
    {0,"methodFunction",	mtd_method_fn,		mtd_set_method_fn},
    {0,"genericFunction",	mtd_generic_fn,		mtd_set_generic_fn},
    {0,"lambdaList",		mtd_lambda_list,	mtd_set_lambda_list},
    {0,"requiredArgs",		mtd_required_args,	mtd_set_never	},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class mtd_Hardcoded_Class = {
    OBJ_FROM_BYT3('m','t','d'),
    "Method",
    sizeof_mtd,
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
    { mtd_system_properties, mtd_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void mtd_doTypes(void){}
Obj_A_Module_Summary mtd_Module_Summary = {
   "mtd",
    mtd_doTypes,
    mtd_Startup,
    mtd_Linkup,
    mtd_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    mtd_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
mtd_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    mtd_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
mtd_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    mtd_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
mtd_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    mtd_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
mtd_Import(
    FILE* fd
) {
    MUQ_FATAL ("mtd_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    mtd_Export -- Write object into textfile.			*/
/************************************************************************/

void
mtd_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("mtd_Export unimplemented");
}


#endif







/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new mtd object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt slots
) {
    /* Initialize ourself: */
    Mtd_P s 	    	= MTD_P(o);

    /* Initialize the basic scalar fields: */
    s->flags 	  	   = OBJ_FROM_INT(0);
    s->qualifier   	   = OBJ_NIL;
    s->method_fn    	   = OBJ_NIL;
    s->generic_fn    	   = OBJ_NIL;
    s->lambda_list    	   = OBJ_NIL;
    s->required_args  	   = OBJ_FROM_UNT( slots );

    {   int i;
	for (i = MTD_RESERVED_SLOTS;  i --> 0; ) s->reserved_slot[i] = OBJ_FROM_INT(0);
    }

    /* Initialize the slot descriptions: */
    {   Vm_Unt i;
	for (i = 0;   i < slots;   ++i) {
	    Mtd_Slot_P p   = &s->slot[i];
	    p->op	   = OBJ_FROM_INT(0);
	    p->arg	   = OBJ_NIL;
    }   }

    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_mtd -- Return size of structure definition.		*/
/************************************************************************/

static Vm_Unt
sizeof_mtd(
    Vm_Unt slots
) {
    /* Structure definitions are variable-size: */
    return (
        (   sizeof( Mtd_A_Header )
	-   sizeof( Mtd_A_Slot )
        )
        + slots * sizeof( Mtd_A_Slot )
    );
}






/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    mtd_qualifier							*/
/************************************************************************/

static Vm_Obj
mtd_qualifier(
    Vm_Obj o
) {
    return MTD_P(o)->qualifier;
}

/************************************************************************/
/*-    mtd_method_fn							*/
/************************************************************************/

static Vm_Obj
mtd_method_fn(
    Vm_Obj o
) {
    return MTD_P(o)->method_fn;
}

/************************************************************************/
/*-    mtd_generic_fn							*/
/************************************************************************/

static Vm_Obj
mtd_generic_fn(
    Vm_Obj o
) {
    return MTD_P(o)->generic_fn;
}

/************************************************************************/
/*-    mtd_lambda_list							*/
/************************************************************************/

static Vm_Obj
mtd_lambda_list(
    Vm_Obj o
) {
    return MTD_P(o)->lambda_list;
}

/************************************************************************/
/*-    mtd_required_args						*/
/************************************************************************/

static Vm_Obj
mtd_required_args(
    Vm_Obj o
) {
    return MTD_P(o)->required_args;
}

/************************************************************************/
/*-    mtd_set_never             					*/
/************************************************************************/

static Vm_Obj
mtd_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mtd_qualifier             					*/
/************************************************************************/

static Vm_Obj
mtd_set_qualifier(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_SYMBOL(v)) {
	MTD_P(o)->qualifier = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mtd_method_fn             					*/
/************************************************************************/

static Vm_Obj
mtd_set_method_fn(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_CFN(v)) {
	MTD_P(o)->method_fn = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}


/************************************************************************/
/*-    mtd_generic_fn             					*/
/************************************************************************/

static Vm_Obj
mtd_set_generic_fn(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_CFN(v)) {
	MTD_P(o)->generic_fn = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}


/************************************************************************/
/*-    mtd_lambda_list             					*/
/************************************************************************/

static Vm_Obj
mtd_set_lambda_list(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_LBD(v)) {
	MTD_P(o)->lambda_list = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/




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
