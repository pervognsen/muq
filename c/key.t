@example  @c
/*--   key.c -- Class Definition Guts for Muq MOS classes.		*/
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
/* Created:      96Feb24						*/
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

 (See cdf.t)

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
static Vm_Unt   sizeof_key( Vm_Unt );

static Vm_Obj	key_layout(        Vm_Obj	   );
static Vm_Obj	key_mos_class(     Vm_Obj	   );
static Vm_Obj	key_newer_key(     Vm_Obj	   );
static Vm_Obj	key_unshared_slots( Vm_Obj	   );
static Vm_Obj	key_shared_slots(   Vm_Obj	   );
static Vm_Obj	key_mos_parents(   Vm_Obj	   );
static Vm_Obj	key_mos_ancestors( Vm_Obj	   );
static Vm_Obj	key_initargs(       Vm_Obj	   );
static Vm_Obj	key_object_methods( Vm_Obj	   );
static Vm_Obj	key_class_methods(  Vm_Obj	   );

static Vm_Obj	key_compiler(       Vm_Obj	   );
static Vm_Obj	key_source(         Vm_Obj	   );
static Vm_Obj	key_file_name(      Vm_Obj	   );
static Vm_Obj	key_fn_line(        Vm_Obj	   );
static Vm_Obj	key_assertion(      Vm_Obj	   );
static Vm_Obj	key_documentation(  Vm_Obj	   );
static Vm_Obj	key_predicate(      Vm_Obj	   );
static Vm_Obj	key_print_function( Vm_Obj	   );
static Vm_Obj	key_metaclass(      Vm_Obj	   );
static Vm_Obj	key_created_an_instance( Vm_Obj	   );

static Vm_Obj	key_conc_name(      Vm_Obj	   );
static Vm_Obj	key_constructor(    Vm_Obj	   );
static Vm_Obj	key_copier(         Vm_Obj	   );
static Vm_Obj	key_abstract(       Vm_Obj	   );
static Vm_Obj	key_type(           Vm_Obj	   );
static Vm_Obj	key_named(          Vm_Obj	   );
static Vm_Obj	key_initial_offset( Vm_Obj	   );
static Vm_Obj	key_export(         Vm_Obj	   );
static Vm_Obj	key_fertile(        Vm_Obj	   );


static Vm_Obj	key_set_newer_key(          Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_never(              Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_compiler(           Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_source(             Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_file_name(          Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_fn_line(            Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_assertion(          Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_documentation(      Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_predicate(          Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_print_function(     Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_metaclass(          Vm_Obj, Vm_Obj );

static Vm_Obj	key_set_conc_name(          Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_constructor(        Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_copier(             Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_abstract(           Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_type(               Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_named(              Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_initial_offset(     Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_export(             Vm_Obj, Vm_Obj );
static Vm_Obj	key_set_fertile(            Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property key_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"layout",	      key_layout,	      key_set_never	},
    {0,"mosClass",	      key_mos_class,	      key_set_never	},
    {0,"newerKey",	      key_newer_key,	      key_set_newer_key	},
    {0,"unsharedSlots",       key_unshared_slots,     key_set_never	},
    {0,"sharedSlots",	      key_shared_slots,	      key_set_never	},
    {0,"mosParents",	      key_mos_parents,	      key_set_never	},
    {0,"mosAncestors",	      key_mos_ancestors,      key_set_never	},
    {0,"initargs",	      key_initargs,	      key_set_never	},
    {0,"objectMmethods",      key_object_methods,     key_set_never	},
    {0,"classMethods",	      key_class_methods,      key_set_never	},

    {0,"compiler",	      key_compiler,	      key_set_compiler},
    {0,"documentation",	      key_documentation,      key_set_documentation},
    {0,"source",	      key_source,	      key_set_source	},
    {0,"fileName",	      key_file_name,	      key_set_file_name},
    {0,"fnLine",	      key_fn_line,	      key_set_fn_line},
    {0,"assertion",	      key_assertion,	      key_set_assertion},
    {0,"predicate",	      key_predicate,	      key_set_predicate},
    {0,"printFunction",       key_print_function,     key_set_print_function},
    {0,"metaclass",	      key_metaclass,	      key_set_metaclass},
    {0,"createdAnInstance",   key_created_an_instance,key_set_never	},

    {0,"concName",		key_conc_name,		key_set_conc_name},
    {0,"constructor",		key_constructor,	key_set_constructor},
    {0,"copier",		key_copier,		key_set_copier	},
    {0,"abstract",		key_abstract,		key_set_abstract},
    {0,"type",			key_type,		key_set_type	},
    {0,"named",			key_named,		key_set_named	},
    {0,"initialOffset",		key_initial_offset,    key_set_initial_offset},
    {0,"export",		key_export,		key_set_export	},
    {0,"fertile",		key_fertile,		key_set_fertile	},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class key_Hardcoded_Class = {
    OBJ_FROM_BYT3('k','e','y'),
    "MosKey",
    sizeof_key,
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
    { key_system_properties, key_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void key_doTypes(void){}
Obj_A_Module_Summary key_Module_Summary = {
    "key",
    key_doTypes,
    key_Startup,
    key_Linkup,
    key_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    key_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
key_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    key_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
key_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    key_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
key_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    key_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
key_Import(
    FILE* fd
) {
    MUQ_FATAL ("key_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    key_Export -- Write object into textfile.			*/
/************************************************************************/

void
key_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("key_Export unimplemented");
}


#endif



/************************************************************************/
/*-    key_Alloc -- Create new key object.				*/
/************************************************************************/

Vm_Obj
key_Alloc(
    Vm_Obj mos_class,
    Vm_Unt unshared_slots,
    Vm_Unt   shared_slots,
    Vm_Unt parents,
    Vm_Int ancestors,
    Vm_Unt slotargs,
    Vm_Unt methargs,
    Vm_Unt initargs,
    Vm_Unt object_methods,
    Vm_Unt class_methods
) {
    Vm_Obj result;

    /* "Ancestors+1" because we use an extra */
    /* -1th ancestor slot to link a key into */
    /* a doubly-linked list with its kids:   */
    Vm_Unt extra_slots = (
        (  shared_slots + unshared_slots) * (sizeof(Key_A_Slot)/sizeof(Vm_Obj))
        + (shared_slots + unshared_slots) * (sizeof(Key_A_Sym )/sizeof(Vm_Obj))
	+ parents
        + (ancestors  )  * (sizeof(Key_A_Ancestor     )/sizeof(Vm_Obj))
        + (ancestors+1)  * (sizeof(Key_A_Link         )/sizeof(Vm_Obj))
        + slotargs
        + methargs
        + initargs       * (sizeof(Key_A_Initarg      )/sizeof(Vm_Obj))
        + object_methods * (sizeof(Key_A_Object_Method)/sizeof(Vm_Obj))
        + class_methods  * (sizeof(Key_A_Class_Method )/sizeof(Vm_Obj))
    );
    if (extra_slots >= KEY_MAX_SLOTS) {
	MUQ_WARN ("makeMosKey: Max size exceeded");
    }

    result = obj_Alloc( OBJ_CLASS_A_KEY, extra_slots );

    /* obj_Alloc() can't initialize properly 'cause the */
    /* single size argument we pass it isn't enough to  */
    /* let key.t:for_new() do its job, so now we call   */
    /* key_For_New() to complete initialization:        */
    key_For_New(
	result,
	mos_class,
	unshared_slots,
	  shared_slots,
	parents,
	ancestors,
	slotargs,
	methargs,
	initargs,
	object_methods,
	class_methods
    );

    return result;
}

/************************************************************************/
/*-    key_For_New -- Initialize new key object.			*/
/************************************************************************/

void
key_For_New(
    Vm_Obj o,
    Vm_Obj mos_class,
    Vm_Unt unshared_slots,
    Vm_Unt   shared_slots,
    Vm_Unt mos_parents,
    Vm_Int mos_ancestors,
    Vm_Unt slotargs,
    Vm_Unt methargs,
    Vm_Unt initargs,
    Vm_Unt object_methods,
    Vm_Unt class_methods
) {
    /* Initialize ourself: */
    Vm_Unt total_slots  = shared_slots + unshared_slots;
    Key_P s 	    	= KEY_P(o);
    Vm_Obj*      a     	= (Vm_Obj*) s;
    Key_Sym      s_ary;
    Vm_Obj*      p_ary;
    Key_Ancestor a_ary;
    Key_Link     l_ary;
    Vm_Obj*      i_ary;
    Vm_Obj*      m_ary;
    Vm_Obj*      g_ary;

    /* Initialize the basic scalar fields: */
    s->mos_class   	   = mos_class;
    s->newer_key    	   = OBJ_NIL;
    s->total_slots  	   = OBJ_FROM_UNT( total_slots    );
    s->unshared_slots	   = OBJ_FROM_UNT( unshared_slots );
    s->superclass_len      = OBJ_FROM_UNT( mos_parents    );
    s->precedence_len      = OBJ_FROM_UNT( mos_ancestors  );
    s->slotarg_len         = OBJ_FROM_UNT( slotargs       );
    s->metharg_len         = OBJ_FROM_UNT( methargs       );
    s->initarg_len         = OBJ_FROM_UNT( initargs       );
    s->objectmethods_len   = OBJ_FROM_UNT( object_methods );
    s->classmethods_len    = OBJ_FROM_UNT( class_methods  );
    s->created_an_instance = OBJ_NIL;

    s->layout	    	   = KEY_LAYOUT_STRUCTURE;

    s->compiler	    	   = OBJ_NIL;
    s->source	    	   = stg_From_Asciz("");
    s->file_name	   = OBJ_FROM_BYT0;
    s->fn_line	   	   = OBJ_FROM_INT(0);

    s->documentation       = OBJ_NIL;
    s->assertion	   = OBJ_FROM_BYT0;
    s->predicate	   = OBJ_FROM_BYT0;
    s->print_function      = OBJ_NIL;

    s->signature	   = OBJ_NIL;

    s->metaclass	   = OBJ_NIL;

    s->created_an_instance = OBJ_NIL;

    s->conc_name	   = OBJ_FROM_BYT0;
    s->constructor         = OBJ_FROM_BYT0;
    s->copier	    	   = OBJ_FROM_BYT0;
    s->abstract	    	   = OBJ_NIL;
    s->type	    	   = OBJ_NIL;
    s->named	    	   = OBJ_FROM_INT(0);
    s->initial_offset      = OBJ_FROM_INT(0);
    s->export	    	   = OBJ_NIL;
    s->fertile	    	   = OBJ_NIL;

    {   int i;
	for (i = KEY_RESERVED_SLOTS;  i --> 0; ) s->reserved_slot[i] = OBJ_FROM_INT(0);
    }


    /* Initialize the slot descriptions: */
    {   Vm_Unt i;
	for (i = 0;   i < total_slots;   ++i) {
	    Key_Slot_P p   = &s->slot[i];
	    p->initform    = OBJ_NIL;
	    p->initval     = OBJ_NIL;
	    p->type        = OBJ_T;
	    p->documentation=OBJ_NIL;
	    p->flags       = KEY_FLAGS_DEFAULT;
	    p->get_function= OBJ_NIL;
	    p->set_function= OBJ_NIL;
	    if (i >= unshared_slots)  p->flags |= KEY_FLAG_SHARED;
    }   }

    /* Locate and initialize the sym vector: */
    s_ary      = (Key_Sym) (&s->slot[ total_slots ]);
    s->sym_loc = OBJ_FROM_INT( ((Vm_Obj*)s_ary) - a );
    {   Vm_Unt i;
	for (i = 0;   i < total_slots;   ++i) {
	    s_ary[i].symbol      = OBJ_NIL;
    }   }

    /* Locate and initialize the parent vector: */
    p_ary  = (Vm_Obj*) (s_ary + total_slots);
    s->superclass_loc = OBJ_FROM_INT( p_ary - a );
    {   Vm_Unt i;
	for (i = 0;   i < mos_parents;   ++i)  p_ary[i] = OBJ_NIL;
    }

    /* Locate and initialize the ancestor vector: */
    a_ary  = (Key_Ancestor)(p_ary + mos_parents);
    s->precedence_loc = OBJ_FROM_INT( ((Vm_Obj*)a_ary) - a );
    {   /* Ancestor vector includes space for a */
	/* doubly-linked list of other children */
	/* of that ancestor, allowing a mosKey */
	/* to notify all of its subclasses when */
	/* it adds a slot or method or such:    */
	Vm_Int i;
	for (i = 0;   i < mos_ancestors;   ++i) {
	    a_ary[i].ancestor = OBJ_NIL;
	    a_ary[i].signature= OBJ_NIL;
	}
    }

    /* Locate and initialize the ancestor vector: */
    l_ary  = (Key_Link)(a_ary + mos_ancestors);
    l_ary++;	/* Reserve a -1th element. */
    s->link_loc = OBJ_FROM_INT( ((Vm_Obj*)l_ary) - a );
    {   /* Ancestor vector includes space for a */
	/* doubly-linked list of other children */
	/* of that ancestor, allowing a mosKey */
	/* to notify all of its subclasses when */
	/* it adds a slot or method or such:    */
	Vm_Int i;
	for (i = -1;   i < mos_ancestors;   ++i) {
	    l_ary[i].next     = o;
	    l_ary[i].prev     = o;
	    l_ary[i].next_slot= OBJ_FROM_INT(i);
	    l_ary[i].prev_slot= OBJ_FROM_INT(i);
	}
    }

    /* Locate and initialize the slotargs vector: */
    g_ary  = (Vm_Obj*)(l_ary + mos_ancestors);
    s->slotarg_loc = OBJ_FROM_INT( g_ary - a );
    {   Vm_Unt i;
	for (i = 0;   i < slotargs;   ++i) {
            g_ary[i] = OBJ_NIL;
	}
    }

    /* Locate and initialize the methargs vector: */
    m_ary  = (Vm_Obj*)(g_ary + slotargs);
    s->metharg_loc = OBJ_FROM_INT( m_ary - a );
    {   Vm_Unt i;
	for (i = 0;   i < methargs;   ++i) {
            m_ary[i] = OBJ_NIL;
	}
    }

    /* Locate and initialize the initargs vector: */
    i_ary  = (Vm_Obj*)(m_ary + methargs);
    s->initarg_loc = OBJ_FROM_INT( i_ary - a );
    {   Vm_Unt i;
	for (i = 0;   i < initargs;   ++i) {
            *i_ary++ = OBJ_NIL;
            *i_ary++ = OBJ_NIL;
	}
    }

    /* Locate and initialize the object-method vector: */
    s->objectmethods_loc = OBJ_FROM_INT( i_ary - a );
    {   Vm_Unt i;
	for (i = 0;   i < object_methods;   ++i) {
            *i_ary++ = OBJ_NIL;	/* Generic function */
            *i_ary++ = OBJ_NIL; /* method	    */
            *i_ary++ = OBJ_NIL; /* object	    */
	}
    }

    /* Locate and initialize the classMethod vector: */
    s->classmethods_loc = OBJ_FROM_INT( i_ary - a );
    {   Vm_Unt i;
	for (i = 0;   i < object_methods;   ++i) {
            *i_ary++ = OBJ_NIL;	/* Generic function */
            *i_ary++ = OBJ_NIL; /* method	    */
	}
    }

    vm_Dirty(o);


    #if MUQ_IS_PARANOID
    /* Check that we didn't clobber */
    /* store we don't own or such:  */
    {   Vm_Unt len = vm_Len(o) / sizeof( Vm_Obj );
	if (len
        !=  OBJ_TO_INT(s->classmethods_loc)
        +   (sizeof(Key_A_Class_Method)/sizeof(Vm_Obj))
        *   OBJ_TO_INT(s->classmethods_len)
        ){
	    MUQ_FATAL("key_For_New internal err");
	}
    }
    #endif
}


/************************************************************************/
/*-    key_Direct_Subclass_Of -- 					*/
/************************************************************************/

Vm_Int
key_Direct_Subclass_Of(
    Vm_Obj kid,
    Vm_Obj mom
) {
    Key_P  s 	    	  = KEY_P(kid);
    Vm_Unt superclass_loc = OBJ_TO_UNT( s->superclass_loc );
    Vm_Unt superclass_len = OBJ_TO_UNT( s->superclass_len );
    Vm_Obj*p_ary          = ((Vm_Obj*)s) + superclass_loc;
    Vm_Unt i;
    for (i = superclass_len;   i --> 0;   ) {
	if (p_ary[i] == mom)   return TRUE;
    }
    return FALSE;  
}




/************************************************************************/
/*-    key_Parents_List --	 					*/
/************************************************************************/

Vm_Int
key_Parents_List(
    Vm_Obj**      list,
    Vm_Obj        key
) {
    Key_P  s 	    	  = KEY_P(key);
    Vm_Unt superclass_loc = OBJ_TO_UNT( s->superclass_loc );
    *list                 = ((Vm_Obj*)s) + superclass_loc  ;
    return                  OBJ_TO_UNT( s->superclass_len );
}


/************************************************************************/
/*-    key_Ancestor_List --	 					*/
/************************************************************************/

Vm_Int
key_Ancestor_List(
    Key_Ancestor* list,
    Vm_Obj        key
) {
    Key_P  s 	    	  = KEY_P(key);
    Vm_Unt precedence_loc = OBJ_TO_UNT( s->precedence_loc );
    *list                 = (Key_Ancestor)(((Vm_Obj*)s) + precedence_loc);
    return                  OBJ_TO_UNT( s->precedence_len );
}

/************************************************************************/
/*-    key_Link_List --	 						*/
/************************************************************************/

#ifdef UNUSED
Vm_Int
key_Link_List(
    Key_Link* list,
    Vm_Obj    key
) {
    Key_P  s 	    = KEY_P(key);
    Vm_Unt link_loc = OBJ_TO_UNT( s->link_loc );
    *list           = (Key_Link)(((Vm_Obj*)s) + link_loc);
    return            OBJ_TO_UNT( s->precedence_len );
}
#endif




/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new key object.				*/
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
    /* for unshared_slots, shared_slots, parents,    */
    /* and ancestors.  So we depend on whoever is    */
    /* calling obj_Alloc() remembering to call our   */
    /* key_For_New() function right after.           */
    /*************************************************/
}



/************************************************************************/
/*-    sizeof_key -- Return size of structure definition.		*/
/************************************************************************/

static Vm_Unt
sizeof_key(
    Vm_Unt slots
) {
    /* Structure definitions are variable-size: */
    return (
        (   sizeof( Key_A_Header )
	-   sizeof( Key_A_Slot )
        )
        + slots * sizeof( Vm_Obj )
    );
}





/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    key_compiler							*/
/************************************************************************/

static Vm_Obj
key_compiler(
    Vm_Obj o
) {
    return KEY_P(o)->compiler;
}

/************************************************************************/
/*-    key_documentation						*/
/************************************************************************/

static Vm_Obj
key_documentation(
    Vm_Obj o
) {
    return KEY_P(o)->documentation;
}

/************************************************************************/
/*-    key_source							*/
/************************************************************************/

static Vm_Obj
key_source(
    Vm_Obj o
) {
    return KEY_P(o)->source;
}

/************************************************************************/
/*-    key_file_name							*/
/************************************************************************/

static Vm_Obj
key_file_name(
    Vm_Obj o
) {
    return KEY_P(o)->file_name;
}

/************************************************************************/
/*-    key_fn_line							*/
/************************************************************************/

static Vm_Obj
key_fn_line(
    Vm_Obj o
) {
    return KEY_P(o)->fn_line;
}

/************************************************************************/
/*-    key_assertion							*/
/************************************************************************/

static Vm_Obj
key_assertion(
    Vm_Obj o
) {
    return KEY_P(o)->assertion;
}

/************************************************************************/
/*-    key_predicate							*/
/************************************************************************/

static Vm_Obj
key_predicate(
    Vm_Obj o
) {
    return KEY_P(o)->predicate;
}

/************************************************************************/
/*-    key_print_function						*/
/************************************************************************/

static Vm_Obj
key_print_function(
    Vm_Obj o
) {
    return KEY_P(o)->print_function;
}

/************************************************************************/
/*-    key_metaclass							*/
/************************************************************************/

static Vm_Obj
key_metaclass(
    Vm_Obj o
) {
    return KEY_P(o)->metaclass;
}

/************************************************************************/
/*-    key_created_an_instance						*/
/************************************************************************/

static Vm_Obj
key_created_an_instance(
    Vm_Obj o
) {
    return KEY_P(o)->created_an_instance;
}

/************************************************************************/
/*-    key_layout							*/
/************************************************************************/

static Vm_Obj
key_layout(
    Vm_Obj o
) {
    switch (KEY_P(o)->layout) {

    case KEY_LAYOUT_BUILT_IN:	return job_Kw_Built_In;
    case KEY_LAYOUT_STRUCTURE:	return job_Kw_Structure;
    case KEY_LAYOUT_MOS_KEY:	return job_Kw_Mos_Key;
    case KEY_LAYOUT_FIXNUM:	return job_Kw_Fixnum;
    case KEY_LAYOUT_SHORT_FLOAT:return job_Kw_Short_Float;
    case KEY_LAYOUT_STACKBLOCK: return job_Kw_Stackblock;
    case KEY_LAYOUT_BOTTOM:     return job_Kw_Bottom;
    case KEY_LAYOUT_COMPILED_FUNCTION: return job_Kw_Compiled_Function;
    case KEY_LAYOUT_CHARACTER:  return job_Kw_Character;
    case KEY_LAYOUT_CONS:       return job_Kw_Cons;
    case KEY_LAYOUT_SPECIAL:    return job_Kw_Special;
    case KEY_LAYOUT_STRING:     return job_Kw_String;
    case KEY_LAYOUT_SYMBOL:     return job_Kw_Symbol;
    case KEY_LAYOUT_BIGNUM:     return job_Kw_Bignum;
    case KEY_LAYOUT_CALLSTACK:	return job_Kw_Callstack;
    case KEY_LAYOUT_VECTOR:	return job_Kw_Vector;
    case KEY_LAYOUT_VECTOR_I01:	return job_Kw_VectorI01;
    case KEY_LAYOUT_VECTOR_I16:	return job_Kw_VectorI16;
    case KEY_LAYOUT_VECTOR_I32:	return job_Kw_VectorI32;
    case KEY_LAYOUT_VECTOR_F32:	return job_Kw_VectorF32;
    case KEY_LAYOUT_VECTOR_F64:	return job_Kw_VectorF64;

    default:
	return OBJ_NIL;
    }
}
/* Buggo, we really should be using layout info in the */
/* garbage collector, but are currently not doing so.  */

/************************************************************************/
/*-    key_mos_class							*/
/************************************************************************/

static Vm_Obj
key_mos_class(
    Vm_Obj o
) {
    return KEY_P(o)->mos_class;
}

/************************************************************************/
/*-    key_newer_key							*/
/************************************************************************/

static Vm_Obj
key_newer_key(
    Vm_Obj o
) {
    return KEY_P(o)->newer_key;
}

/************************************************************************/
/*-    key_unshared_slots						*/
/************************************************************************/

static Vm_Obj
key_unshared_slots(
    Vm_Obj o
) {
    return KEY_P(o)->unshared_slots;
}

/************************************************************************/
/*-    key_shared_slots							*/
/************************************************************************/

static Vm_Obj
key_shared_slots(
    Vm_Obj o
) {
    Key_P c = KEY_P(o);
    return OBJ_FROM_INT(
        OBJ_TO_INT( c->total_slots ) - OBJ_TO_INT( c->unshared_slots )
    );
}

/************************************************************************/
/*-    key_mos_parents							*/
/************************************************************************/

static Vm_Obj
key_mos_parents(
    Vm_Obj o
) {
    return KEY_P(o)->superclass_len;
}

/************************************************************************/
/*-    key_mos_ancestors						*/
/************************************************************************/

static Vm_Obj
key_mos_ancestors(
    Vm_Obj o
) {
    return KEY_P(o)->precedence_len;
}

/************************************************************************/
/*-    key_initargs							*/
/************************************************************************/

static Vm_Obj
key_initargs(
    Vm_Obj o
) {
    return KEY_P(o)->initarg_len;
}

/************************************************************************/
/*-    key_object_methods						*/
/************************************************************************/

static Vm_Obj
key_object_methods(
    Vm_Obj o
) {
    return KEY_P(o)->objectmethods_len;
}

/************************************************************************/
/*-    key_class_methods						*/
/************************************************************************/

static Vm_Obj
key_class_methods(
    Vm_Obj o
) {
    return KEY_P(o)->classmethods_len;
}

/************************************************************************/
/*-    key_conc_name							*/
/************************************************************************/

static Vm_Obj
key_conc_name(
    Vm_Obj o
) {
    return KEY_P(o)->conc_name;
}

/************************************************************************/
/*-    key_constructor							*/
/************************************************************************/

static Vm_Obj
key_constructor(
    Vm_Obj o
) {
    return KEY_P(o)->constructor;
}

/************************************************************************/
/*-    key_copier							*/
/************************************************************************/

static Vm_Obj
key_copier(
    Vm_Obj o
) {
    return KEY_P(o)->copier;
}

/************************************************************************/
/*-    key_abstract							*/
/************************************************************************/

static Vm_Obj
key_abstract(
    Vm_Obj o
) {
    return KEY_P(o)->abstract;
}

/************************************************************************/
/*-    key_type								*/
/************************************************************************/

static Vm_Obj
key_type(
    Vm_Obj o
) {
    return KEY_P(o)->type;
}

/************************************************************************/
/*-    key_named							*/
/************************************************************************/

static Vm_Obj
key_named(
    Vm_Obj o
) {
    return KEY_P(o)->named;
}

/************************************************************************/
/*-    key_initial_offset						*/
/************************************************************************/

static Vm_Obj
key_initial_offset(
    Vm_Obj o
) {
    return KEY_P(o)->initial_offset;
}

/************************************************************************/
/*-    key_export							*/
/************************************************************************/

static Vm_Obj
key_export(
    Vm_Obj o
) {
    return KEY_P(o)->export;
}

/************************************************************************/
/*-    key_fertile							*/
/************************************************************************/

static Vm_Obj
key_fertile(
    Vm_Obj o
) {
    return KEY_P(o)->fertile;
}

/************************************************************************/
/*-    key_set_export             					*/
/************************************************************************/

static Vm_Obj
key_set_export(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->export = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_fertile             					*/
/************************************************************************/

static Vm_Obj
key_set_fertile(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->fertile = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_conc_name             					*/
/************************************************************************/

static Vm_Obj
key_set_conc_name(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->conc_name = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_constructor             					*/
/************************************************************************/

static Vm_Obj
key_set_constructor(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->constructor = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_copier             					*/
/************************************************************************/

static Vm_Obj
key_set_copier(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->copier = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_abstract             					*/
/************************************************************************/

static Vm_Obj
key_set_abstract(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->abstract = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_type	          					*/
/************************************************************************/

static Vm_Obj
key_set_type(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->type = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_named	          					*/
/************************************************************************/

static Vm_Obj
key_set_named(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->named = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_initial_offset         					*/
/************************************************************************/

static Vm_Obj
key_set_initial_offset(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->initial_offset = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_never             					*/
/************************************************************************/

static Vm_Obj
key_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_newer_key             					*/
/************************************************************************/

static Vm_Obj
key_set_newer_key(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_KEY(v)) {
	KEY_P(o)->newer_key = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_compiler             					*/
/************************************************************************/

static Vm_Obj
key_set_compiler(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->compiler = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_documentation           					*/
/************************************************************************/

static Vm_Obj
key_set_documentation(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->documentation = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_source             					*/
/************************************************************************/

static Vm_Obj
key_set_source(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->source = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_file_name             					*/
/************************************************************************/

static Vm_Obj
key_set_file_name(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->file_name = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_fn_line             					*/
/************************************************************************/

static Vm_Obj
key_set_fn_line(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->fn_line = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_assertion             					*/
/************************************************************************/

static Vm_Obj
key_set_assertion(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->assertion = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_predicate             					*/
/************************************************************************/

static Vm_Obj
key_set_predicate(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->predicate = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_print_function          					*/
/************************************************************************/

static Vm_Obj
key_set_print_function(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->print_function = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    key_set_metaclass	       					*/
/************************************************************************/

static Vm_Obj
key_set_metaclass(
    Vm_Obj o,
    Vm_Obj v
) {
    KEY_P(o)->metaclass = v;
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
