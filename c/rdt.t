@example  @c
/*--   rdt.c -- ReaD-Tables for Muq CommonLisp support.			*/
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
/* Created:      96Mar08						*/
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
static Vm_Unt   sizeof_rdt( Vm_Unt );

static Vm_Obj	rdt_readtable_case(     Vm_Obj	       );
static Vm_Obj	rdt_set_readtable_case( Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property rdt_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"readtableCase", rdt_readtable_case,	rdt_set_readtable_case},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class rdt_Hardcoded_Class = {
    OBJ_FROM_BYT3('r','d','t'),
    "ReadTable",
    sizeof_rdt,
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
    { rdt_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void rdt_doTypes(void){}
Obj_A_Module_Summary rdt_Module_Summary = {
   "rdt",
    rdt_doTypes,
    rdt_Startup,
    rdt_Linkup,
    rdt_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    rdt_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
rdt_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    rdt_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
rdt_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    rdt_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
rdt_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    rdt_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
rdt_Import(
    FILE* fd
) {
    MUQ_FATAL ("rdt_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    rdt_Export -- Write object into textfile.			*/
/************************************************************************/

void
rdt_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("rdt_Export unimplemented");
}


#endif



/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new rdt object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt dummy
) {
    Rdt_P  r = RDT_P(o);
    r->readtable_case = RDT_DOWNCASE;

    {   Vm_Int i;
	for (i = 0;   i < RDT_MAX_CHARS;   ++i) {
	    Rdt_Slot s = &r->slot[i];
	    s->kind = RDT_CONSTITUENT;
	    s->val  = OBJ_NIL;
	}
    }

    {   Vm_Int i;
	for (i = 0;   i <= ' ';   ++i) {
	    Rdt_Slot s = &r->slot[i];
	    s->kind = RDT_WHITESPACE;
	    s->val  = OBJ_NIL;
	}
    }

    r->slot[ '"' ].kind = RDT_TERMINATING_MACRO;
    r->slot[ '#' ].kind = RDT_NONTERMINATING_MACRO;
    r->slot[ '\''].kind = RDT_TERMINATING_MACRO;
    r->slot[ '(' ].kind = RDT_TERMINATING_MACRO;
    r->slot[ ')' ].kind = RDT_TERMINATING_MACRO;
    r->slot[ ',' ].kind = RDT_TERMINATING_MACRO;
    r->slot[ ';' ].kind = RDT_TERMINATING_MACRO;
    r->slot[ '\\'].kind = RDT_SINGLE_ESCAPE;
    r->slot[ '`' ].kind = RDT_TERMINATING_MACRO;
    r->slot[ '|' ].kind = RDT_MULTIPLE_ESCAPE;

    {   int i;
	for (i = RDT_RESERVED_SLOTS;  i --> 0; ) r->reserved_slot[i] = OBJ_FROM_INT(0);
    }

    vm_Dirty(o);

}



/************************************************************************/
/*-    sizeof_rdt -- Return size of structure definition.		*/
/************************************************************************/

static Vm_Unt
sizeof_rdt(
    Vm_Unt slots
) {
    /* Structure definitions are variable-size: */
    return sizeof( Rdt_A_Header );
}





/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    rdt_readtable_case						*/
/************************************************************************/

static Vm_Obj
rdt_readtable_case(
    Vm_Obj o
) {
    switch (RDT_P(o)->readtable_case) {
    case RDT_PRESERVE:  return job_Kw_Preserve;
    case RDT_DOWNCASE:  return job_Kw_Downcase;
    case RDT_UPCASE:    return job_Kw_Upcase;
    case RDT_INVERT:    return job_Kw_Invert;
    default:
        MUQ_FATAL("rdt_readtable_case");
    }
    return OBJ_FROM_INT(0); /* Just to quiet compilers. */
}

/************************************************************************/
/*-    rdt_set_readtable_case          					*/
/************************************************************************/

static Vm_Obj
rdt_set_readtable_case(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == job_Kw_Preserve) {
	RDT_P(o)->readtable_case = RDT_PRESERVE;
	vm_Dirty(o);
	return (Vm_Obj) 0;
    }
    if (v == job_Kw_Downcase) {
	RDT_P(o)->readtable_case = RDT_DOWNCASE;
	vm_Dirty(o);
	return (Vm_Obj) 0;
    }
    if (v == job_Kw_Invert) {
	RDT_P(o)->readtable_case = RDT_INVERT;
	vm_Dirty(o);
	return (Vm_Obj) 0;
    }
    if (v == job_Kw_Upcase) {
	RDT_P(o)->readtable_case = RDT_UPCASE;
	vm_Dirty(o);
	return (Vm_Obj) 0;
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
