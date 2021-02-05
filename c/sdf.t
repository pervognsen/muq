@example  @c
/*--   sdf.c -- Structure DeFinitions for Muq.				*/
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
/* Created:      95Sep17						*/
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
static Vm_Unt   sizeof_sdf( Vm_Unt );

static Vm_Obj	sdf_conc_name(      Vm_Obj	   );
static Vm_Obj	sdf_constructor(    Vm_Obj	   );
static Vm_Obj	sdf_copier(         Vm_Obj	   );
static Vm_Obj	sdf_type(           Vm_Obj	   );
static Vm_Obj	sdf_named(          Vm_Obj	   );
static Vm_Obj	sdf_initial_offset( Vm_Obj	   );
static Vm_Obj	sdf_export(         Vm_Obj	   );

static Vm_Obj	sdf_compiler(       Vm_Obj	   );
static Vm_Obj	sdf_source(         Vm_Obj	   );
static Vm_Obj	sdf_file_name(      Vm_Obj	   );
static Vm_Obj	sdf_fn_line(        Vm_Obj	   );
static Vm_Obj	sdf_unshared_slots( Vm_Obj	   );
static Vm_Obj	sdf_include(        Vm_Obj	   );
static Vm_Obj	sdf_assertion(      Vm_Obj	   );
static Vm_Obj	sdf_predicate(      Vm_Obj	   );
static Vm_Obj	sdf_print_function( Vm_Obj	   );
static Vm_Obj	sdf_created_an_instance( Vm_Obj	   );

static Vm_Obj	sdf_set_compiler(           Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_source(             Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_file_name(          Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_fn_line(            Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_never(              Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_assertion(          Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_predicate(          Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_print_function(     Vm_Obj, Vm_Obj );

static Vm_Obj	sdf_set_conc_name(          Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_constructor(        Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_copier(             Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_type(               Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_named(              Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_initial_offset(     Vm_Obj, Vm_Obj );
static Vm_Obj	sdf_set_export(             Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property sdf_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"concName",		sdf_conc_name,		sdf_set_conc_name},
    {0,"constructor",		sdf_constructor,	sdf_set_constructor},
    {0,"copier",		sdf_copier,		sdf_set_copier	},
    {0,"type",			sdf_type,		sdf_set_type	},
    {0,"named",			sdf_named,		sdf_set_named	},
    {0,"initialOffset",	sdf_initial_offset,    sdf_set_initial_offset},
    {0,"export",		sdf_export,		sdf_set_export	},

    {0,"compiler",		sdf_compiler,		sdf_set_compiler},
    {0,"source",		sdf_source,		sdf_set_source	},
    {0,"fileName",		sdf_file_name,		sdf_set_file_name},
    {0,"fnLine",		sdf_fn_line,		sdf_set_fn_line},
    {0,"unsharedSlots",	sdf_unshared_slots,	sdf_set_never	},
    {0,"include",		sdf_include,		sdf_set_never	},
    {0,"assertion",		sdf_assertion,		sdf_set_assertion},
    {0,"predicate",		sdf_predicate,		sdf_set_predicate},
    {0,"printFunction",	sdf_print_function,    sdf_set_print_function},
    {0,"createdAnInstance",	sdf_created_an_instance,sdf_set_never	},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class sdf_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','d','f'),
    "StructureDefinition",
    sizeof_sdf,
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
    { sdf_system_properties, sdf_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void sdf_doTypes(void){}
Obj_A_Module_Summary sdf_Module_Summary = {
   "sdf",
    sdf_doTypes,
    sdf_Startup,
    sdf_Linkup,
    sdf_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    sdf_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
sdf_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    sdf_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
sdf_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    sdf_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
sdf_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    sdf_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
sdf_Import(
    FILE* fd
) {
    MUQ_FATAL ("sdf_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    sdf_Export -- Write object into textfile.			*/
/************************************************************************/

void
sdf_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("sdf_Export unimplemented");
}


#endif








/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new sdf object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt slots
) {
    /* Initialize ourself: */
    {   Vm_Obj source =  stg_From_Asciz("");
	Sdf_P s 	    = SDF_P(o);
	Vm_Int loc	    = (
	    ((Vm_Obj*)(&s->slot[slots])) -
	    ((Vm_Obj*)( s             ))
	);

	s->compiler	    = OBJ_NIL;
	s->source	    = source;
	s->file_name	    = OBJ_FROM_BYT0;
	s->fn_line	    = OBJ_FROM_INT(0);

	s->unshared_slots   = OBJ_FROM_INT(slots);
	s->total_slots      = OBJ_FROM_INT(slots);

	s->conc_name	    = OBJ_FROM_BYT0;
	s->constructor      = OBJ_FROM_BYT0;
	s->copier	    = OBJ_FROM_BYT0;
	s->type	    	    = OBJ_NIL;
	s->named	    = OBJ_FROM_INT(0);
	s->initial_offset   = OBJ_FROM_INT(0);
	s->export	    = OBJ_NIL;

	s->documentation    = OBJ_NIL;
	s->metaclass        = OBJ_NIL;
	s->mos_class        = OBJ_NIL;
	s->next_key         = OBJ_NIL;
    
        s->signature	    = OBJ_NIL;

	s->assertion	    = OBJ_FROM_BYT0;
	s->predicate	    = OBJ_FROM_BYT0;
	s->print_function   = OBJ_NIL;

	s->superclass_len   = OBJ_FROM_INT(1);
	s->superclass_loc   = OBJ_FROM_INT(loc);

	s->precedence_loc   = OBJ_FROM_INT(loc);
	s->precedence_len   = OBJ_FROM_INT(0);

	s->initarg_loc	    = OBJ_FROM_INT(loc);
	s->initarg_len	    = OBJ_FROM_INT(0);

	s->objectmethods_loc= OBJ_FROM_INT(loc);
	s->objectmethods_len= OBJ_FROM_INT(0);

	s->classmethods_loc = OBJ_FROM_INT(loc);
	s->classmethods_len = OBJ_FROM_INT(0);

	s->created_an_instance = OBJ_NIL;

	{   Vm_Unt i;
	    for (i = 0;   i < slots;   ++i) {
		Sdf_Slot_P p   = &s->slot[i];
		p->keyword     = OBJ_NIL;
		p->initform    = OBJ_NIL;
		p->initval     = OBJ_NIL;
		p->type        = OBJ_T;
		p->documentation=OBJ_NIL;
		p->flags       = SDF_FLAGS_DEFAULT;
		p->get_function= OBJ_NIL;
		p->set_function= OBJ_NIL;
		p->value       = OBJ_NIL;
	}   }

	((Vm_Obj*)s)[loc]      = OBJ_NIL;

	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_sdf -- Return size of structure definition.		*/
/************************************************************************/

static Vm_Unt
sizeof_sdf(
    Vm_Unt slots
) {
    /* Structure definitions are variable-size: */
    return (
        sizeof( Sdf_A_Header )
        +   (slots-1) * sizeof( Sdf_A_Slot )
        +   sizeof( Vm_Obj )
    );
}






/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    sdf_compiler							*/
/************************************************************************/

static Vm_Obj
sdf_compiler(
    Vm_Obj o
) {
    return SDF_P(o)->compiler;
}

/************************************************************************/
/*-    sdf_export							*/
/************************************************************************/

static Vm_Obj
sdf_export(
    Vm_Obj o
) {
    return SDF_P(o)->export;
}

/************************************************************************/
/*-    sdf_source							*/
/************************************************************************/

static Vm_Obj
sdf_source(
    Vm_Obj o
) {
    return SDF_P(o)->source;
}

/************************************************************************/
/*-    sdf_file_name							*/
/************************************************************************/

static Vm_Obj
sdf_file_name(
    Vm_Obj o
) {
    return SDF_P(o)->file_name;
}

/************************************************************************/
/*-    sdf_fn_line							*/
/************************************************************************/

static Vm_Obj
sdf_fn_line(
    Vm_Obj o
) {
    return SDF_P(o)->fn_line;
}

/************************************************************************/
/*-    sdf_unshared_slots						*/
/************************************************************************/

static Vm_Obj
sdf_unshared_slots(
    Vm_Obj o
) {
    return SDF_P(o)->unshared_slots;
}

/************************************************************************/
/*-    sdf_conc_name							*/
/************************************************************************/

static Vm_Obj
sdf_conc_name(
    Vm_Obj o
) {
    return SDF_P(o)->conc_name;
}

/************************************************************************/
/*-    sdf_include							*/
/************************************************************************/

static Vm_Obj
sdf_include(
    Vm_Obj o
) {
    Sdf_P  p   = SDF_P(o);
    Vm_Int loc = OBJ_TO_INT( p->superclass_loc );
    Vm_Int len = OBJ_TO_INT( p->superclass_len );
    if (len < 1) MUQ_WARN("No superclass");
    return ((Vm_Obj*)(p))[loc];
}

/************************************************************************/
/*-    sdf_constructor							*/
/************************************************************************/

static Vm_Obj
sdf_constructor(
    Vm_Obj o
) {
    return SDF_P(o)->constructor;
}

/************************************************************************/
/*-    sdf_copier							*/
/************************************************************************/

static Vm_Obj
sdf_copier(
    Vm_Obj o
) {
    return SDF_P(o)->copier;
}

/************************************************************************/
/*-    sdf_assertion							*/
/************************************************************************/

static Vm_Obj
sdf_assertion(
    Vm_Obj o
) {
    return SDF_P(o)->assertion;
}

/************************************************************************/
/*-    sdf_predicate							*/
/************************************************************************/

static Vm_Obj
sdf_predicate(
    Vm_Obj o
) {
    return SDF_P(o)->predicate;
}

/************************************************************************/
/*-    sdf_print_function						*/
/************************************************************************/

static Vm_Obj
sdf_print_function(
    Vm_Obj o
) {
    return SDF_P(o)->print_function;
}

/************************************************************************/
/*-    sdf_type								*/
/************************************************************************/

static Vm_Obj
sdf_type(
    Vm_Obj o
) {
    return SDF_P(o)->type;
}

/************************************************************************/
/*-    sdf_named							*/
/************************************************************************/

static Vm_Obj
sdf_named(
    Vm_Obj o
) {
    return SDF_P(o)->named;
}

/************************************************************************/
/*-    sdf_initial_offset						*/
/************************************************************************/

static Vm_Obj
sdf_initial_offset(
    Vm_Obj o
) {
    return SDF_P(o)->initial_offset;
}

/************************************************************************/
/*-    sdf_created_an_instance						*/
/************************************************************************/

static Vm_Obj
sdf_created_an_instance(
    Vm_Obj o
) {
    return SDF_P(o)->created_an_instance;
}

/************************************************************************/
/*-    sdf_set_never             					*/
/************************************************************************/

static Vm_Obj
sdf_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_compiler             					*/
/************************************************************************/

static Vm_Obj
sdf_set_compiler(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->compiler = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_export             					*/
/************************************************************************/

static Vm_Obj
sdf_set_export(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->export = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_source             					*/
/************************************************************************/

static Vm_Obj
sdf_set_source(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->source = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_file_name             					*/
/************************************************************************/

static Vm_Obj
sdf_set_file_name(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->file_name = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_fn_line             					*/
/************************************************************************/

static Vm_Obj
sdf_set_fn_line(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->fn_line = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_conc_name             					*/
/************************************************************************/

static Vm_Obj
sdf_set_conc_name(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->conc_name = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_constructor             					*/
/************************************************************************/

static Vm_Obj
sdf_set_constructor(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->constructor = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_copier             					*/
/************************************************************************/

static Vm_Obj
sdf_set_copier(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->copier = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_assertion             					*/
/************************************************************************/

static Vm_Obj
sdf_set_assertion(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->assertion = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_predicate             					*/
/************************************************************************/

static Vm_Obj
sdf_set_predicate(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->predicate = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_print_function          					*/
/************************************************************************/

static Vm_Obj
sdf_set_print_function(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->print_function = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_type	          					*/
/************************************************************************/

static Vm_Obj
sdf_set_type(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->type = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_named	          					*/
/************************************************************************/

static Vm_Obj
sdf_set_named(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->named = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sdf_set_initial_offset         					*/
/************************************************************************/

static Vm_Obj
sdf_set_initial_offset(
    Vm_Obj o,
    Vm_Obj v
) {
    SDF_P(o)->initial_offset = v;
    vm_Dirty(o);

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
