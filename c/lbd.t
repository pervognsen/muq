@example  @c
/*--   lbd.c -- LamBDa-lists for Muq CLOS classes.			*/
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

Lambda list objects support processing of CommonLisp-style
argument blocks.  The compiler processes a declaration like

  (defun my-fun (req1 (req1 1.3) &key key1 (key2 "xx")))

into a lambda list instance recording the facts that
there are two required arguments, the second having
a default value of 1.3, and two keyword arguments named
:key1 and :key2, the second having a default value of
"xx".

When 'my-fun' is actually called, the apply-clos-lambda-list
prim can then relatively efficiently extract the appropriate
values from the argblock, and set the corresponding local
variables appropriately.


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
static Vm_Unt   sizeof_lbd( Vm_Unt );

static Vm_Obj	lbd_required_args( Vm_Obj	   );
static Vm_Obj	lbd_optional_args( Vm_Obj	   );
static Vm_Obj	lbd_keyword_args(  Vm_Obj	   );
static Vm_Obj	lbd_total_args(	   Vm_Obj	   );
static Vm_Obj	lbd_allow_other_keywords(   Vm_Obj	   );
static Vm_Obj	lbd_set_allow_other_keywords(   Vm_Obj,Vm_Obj	   );

static Vm_Obj	lbd_set_never(              Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property lbd_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"requiredArgs",		lbd_required_args,	lbd_set_never	},
    {0,"optionalArgs",		lbd_optional_args,	lbd_set_never	},
    {0,"keywordArgs",		lbd_keyword_args,	lbd_set_never	},
    {0,"totalArgs",		lbd_total_args,		lbd_set_never	},
    {0,"allowOtherKeywords",	lbd_allow_other_keywords,lbd_set_allow_other_keywords	},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class lbd_Hardcoded_Class = {
    OBJ_FROM_BYT3('l','b','d'),
    "LambdaList",
    sizeof_lbd,
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
    { lbd_system_properties, lbd_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void lbd_doTypes(void){}
Obj_A_Module_Summary lbd_Module_Summary = {
   "lbd",
    lbd_doTypes,
    lbd_Startup,
    lbd_Linkup,
    lbd_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    lbd_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
lbd_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    lbd_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
lbd_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    lbd_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
lbd_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    lbd_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
lbd_Import(
    FILE* fd
) {
    MUQ_FATAL ("lbd_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    lbd_Export -- Write object into textfile.			*/
/************************************************************************/

void
lbd_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("lbd_Export unimplemented");
}


#endif



/************************************************************************/
/*-    lbd_For_New -- Initialize new lbd object.			*/
/************************************************************************/

void
lbd_For_New(
    Vm_Obj o,
    Vm_Unt required_args,
    Vm_Unt optional_args,
    Vm_Unt keyword_args,
    Vm_Unt local_vars

) {
    /* Initialize ourself: */
    Vm_Unt total_args = required_args + optional_args + keyword_args;
    Lbd_P s 	      = LBD_P(o);

    /* Initialize the basic scalar fields: */
    s->required_args	   = OBJ_FROM_UNT( required_args );
    s->optional_args	   = OBJ_FROM_UNT( optional_args );
    s->keyword_args	   = OBJ_FROM_UNT( keyword_args  );
    s->total_args	   = OBJ_FROM_UNT( total_args    );
    s->allow_other_keywords= OBJ_T;

    {   int i;
	for (i = LBD_RESERVED_SLOTS;  i --> 0; ) s->reserved_slot[i] = OBJ_FROM_INT(0);
    }

    /* Initialize the slot descriptions: */
    {   Vm_Unt i;
	for (i = 0;   i < total_args;   ++i) {
	    Lbd_Slot_P p   = &s->slot[i];
	    p->name        = OBJ_FROM_BYT1('?');
	    p->initval     = OBJ_NIL;
	    p->initform    = OBJ_FROM_INT(0);
    }   }

    vm_Dirty(o);
}







/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new lbd object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt slots
) {
    /*************************************************/
    /* We can't do anything useful here, because our */
    /* standard obj_Alloc() protocol only passes one */
    /* size parameter through, but we need to ones   */
    /* for required_args, optional_args, and         */
    /* keyword_args.  So we depend on whoever is     */
    /* calling obj_Alloc() remembering to call our   */
    /* lbd_For_New() function right after.           */
    /*************************************************/
}



/************************************************************************/
/*-    sizeof_lbd -- Return size of structure definition.		*/
/************************************************************************/

static Vm_Unt
sizeof_lbd(
    Vm_Unt slots
) {
    /* Structure definitions are variable-size: */
    return (
        (   sizeof( Lbd_A_Header )
	-   sizeof( Lbd_A_Slot   )
        )
        + slots * sizeof( Lbd_A_Slot )
    );
}





/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    lbd_required_args						*/
/************************************************************************/

static Vm_Obj
lbd_required_args(
    Vm_Obj o
) {
    return LBD_P(o)->required_args;
}

/************************************************************************/
/*-    lbd_optional_args						*/
/************************************************************************/

static Vm_Obj
lbd_optional_args(
    Vm_Obj o
) {
    return LBD_P(o)->optional_args;
}

/************************************************************************/
/*-    lbd_keyword_args							*/
/************************************************************************/

static Vm_Obj
lbd_keyword_args(
    Vm_Obj o
) {
    return LBD_P(o)->keyword_args;
}

/************************************************************************/
/*-    lbd_total_args							*/
/************************************************************************/

static Vm_Obj
lbd_total_args(
    Vm_Obj o
) {
    Lbd_P  p  = LBD_P(o);

    Vm_Int ra = OBJ_TO_INT( p->required_args );
    Vm_Int oa = OBJ_TO_INT( p->optional_args );
    Vm_Int ka = OBJ_TO_INT( p->keyword_args );

    return OBJ_FROM_INT( ra + oa + ka );
}

/************************************************************************/
/*-    lbd_allow_other_keywords						*/
/************************************************************************/

static Vm_Obj
lbd_allow_other_keywords(
    Vm_Obj o
) {
    return LBD_P(o)->allow_other_keywords;
}

/************************************************************************/
/*-    lbd_set_allow_other_keywords    					*/
/************************************************************************/

static Vm_Obj
lbd_set_allow_other_keywords(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_T || v == OBJ_NIL) {
	LBD_P(o)->allow_other_keywords = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    lbd_set_never             					*/
/************************************************************************/

static Vm_Obj
lbd_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
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
