@example  @c
/* To do: */
/* Implement unpush and unpull. */
/* Prolly have item 0 be next item to pull, */
/* since stream hacking tends to revolve around the pull end. */


/*--   stm.c -- garden variety Streams for Muq.				*/
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
/* Created:      94Feb10						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1995, by Jeff Prothero.				*/
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

/* Max number of slots for a stream.   */
/* Mainly, need to avoid over-running  */
/* max size allowed by vm diskfiles or */
/* thrashing bigbuf with huge objs:    */
#ifndef STM_SIZE_MAX
#define STM_SIZE_MAX (4096)
#endif





/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_stm( Vm_Unt );

static Vm_Obj	stm_vector(	 Vm_Obj  );

static Vm_Obj   stm_x_del(     Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj   stm_x_get(     Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Uch*  stm_x_set(     Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj   stm_x_nxt(     Vm_Obj, Vm_Obj , Vm_Int );

static Vm_Obj	stm_set_vector(  Vm_Obj, Vm_Obj );
static Vm_Obj	stm_set_length(  Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property stm_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"vector"	, stm_vector	, stm_set_vector },
    {0,"length"	, stm_Length	, stm_set_length },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class stm_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','t','m'),
    "Stream",
    sizeof_stm,
    for_new,
    stm_x_del,
    stm_x_get,
    obj_X_Get_Asciz,
    stm_x_set,
    stm_x_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { stm_system_properties, stm_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void stm_doTypes(void){}
Obj_A_Module_Summary stm_Module_Summary = {
   "stm",
    stm_doTypes,
    stm_Startup,
    stm_Linkup,
    stm_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    stm_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
stm_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    stm_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
stm_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    stm_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
stm_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

}


#ifdef OLD

/************************************************************************/
/*-    stm_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
stm_Import(
    FILE* fd
) {
    MUQ_FATAL ("stm_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    stm_Export -- Write object into textfile.			*/
/************************************************************************/

void
stm_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("stm_Export unimplemented");
}


#endif


/************************************************************************/
/*-    stm_Length							*/
/************************************************************************/

Vm_Obj
stm_Length(
    Vm_Obj o
) {
    Vm_Int cat;
    Vm_Int rat;
    Vm_Obj vec;
    {   Stm_P q = STM_P(o);
	cat = OBJ_TO_INT( q->cat );
	rat = OBJ_TO_INT( q->rat );
	vec = q->vector;
    }
    if (cat <= rat)   return OBJ_FROM_INT( rat-cat );
    {   Vm_Int len = vec_Len( vec );
	return OBJ_FROM_INT( (len-cat) + rat );
    }    
}



/************************************************************************/
/*-    stm_Nth -- Get nth entry						*/
/************************************************************************/

Vm_Obj
stm_Nth(
    Vm_Obj stm,
    Vm_Unt n
) {
    Vm_Unt cat;
    Vm_Unt rat;
    Vm_Obj vec;
    Vm_Unt len;
    Vm_Unt vlen;
    {   Stm_P q = STM_P(stm);
	cat = OBJ_TO_INT( q->cat );
	rat = OBJ_TO_INT( q->rat );
	vec = q->vector;
    }
    vlen = vec_Len( vec );
    if (cat <= rat) {
	len = rat-cat;
     } else {
	len = (vlen-cat) + rat;
    }    
    if (n >= len)   MUQ_WARN ("stream has no %dth element.",(int)n);
    n += cat;
    if (n >= vlen) n -= vlen;
    return VEC_P(vec)->slot[n];
}



/************************************************************************/
/*-    stm_Set_Nth -- Set nth entry					*/
/************************************************************************/

void
stm_Set_Nth(
    Vm_Obj stm,
    Vm_Unt n,
    Vm_Obj val
) {
    Vm_Unt cat;
    Vm_Unt rat;
    Vm_Obj vec;
    Vm_Unt len;
    Vm_Unt vlen;
    {   Stm_P q = STM_P(stm);
	cat = OBJ_TO_INT( q->cat );
	rat = OBJ_TO_INT( q->rat );
	vec = q->vector;
    }
    vlen = vec_Len( vec );
    if (cat <= rat) {
	len = rat-cat;
     } else {
	len = (vlen-cat) + rat;
    }    
    if (n >= len)   MUQ_WARN ("stream has no %dth element.",(int)n);
    n += cat;
    if (n >= vlen) n -= vlen;
    VEC_P(vec)->slot[n] = val;
    vm_Dirty(vec);
}



/************************************************************************/
/*-    stm_Reset -- Reset to empty					*/
/************************************************************************/

void
stm_Reset(
    Vm_Obj stm
) {
    {   Stm_P q = STM_P(stm);
	q->cat  = OBJ_FROM_INT(0);
	q->rat  = OBJ_FROM_INT(0);
	vm_Dirty(stm);
    }
    {	Vm_Obj vec = STM_P(stm)->vector;
	Vm_Int i   = vec_Len(vec);
	Vec_P  v   = VEC_P(vec);
	while (i --> 0) v->slot[i] = OBJ_FROM_INT(0);
	vm_Dirty(vec);
    }
}



/************************************************************************/
/*-    stm_Empty_P -- TRUE iff empty					*/
/************************************************************************/

Vm_Int
stm_Empty_P(
    Vm_Obj stm
) {
    Stm_P  q = STM_P(stm);
    return q->cat == q->rat;
}



/************************************************************************/
/*-    stm_Push -- Push a value on stream.				*/
/************************************************************************/

void
stm_Push(
    Vm_Obj stm,
    Vm_Obj val
) {
    Vm_Int cat;
    Vm_Int rat;
    Vm_Obj vec;
    {   Stm_P s = STM_P(stm);
	cat = OBJ_TO_INT( s->cat );
	rat = OBJ_TO_INT( s->rat );
	vec = s->vector;
    }

    {   /* Decide where to put new value, make sure it's empty: */
	Vm_Int len = vec_Len(vec);
	Vm_Int nxt = rat+1;
	if (nxt == len)   nxt = 0;
	if (nxt == cat) {

	    /* Stream is full.  Try expanding it: */
	    Vm_Int new_len = 2*len;
	    if (   new_len > STM_SIZE_MAX) {
		MUQ_WARN ("push: stream is full.");
	    }
	    vec = vec_SizedDup( vec, new_len );

	    /* Vector has been expanded, now we  */
	    /* slide everything from 'cat' to    */
            /* old end of vector down into new   */
            /* space just allocated:             */
	    {   Vec_P v = VEC_P(vec);
		Vm_Int i;
		for (i = cat;   i < len;   ++i) {
		    v->slot[i+len] = v->slot[i];
		}
		vm_Dirty(vec);
	    }
	    if (rat == len-1) {
		rat += len;
	    }
	    cat += len;
	    len  = new_len;

	    /* Install new vector, 'cat' and 'rat' vals: */
	    {   Stm_P s   = STM_P(stm);
		s->vector = vec;
		s->cat    = OBJ_FROM_INT(cat);
		/* Rat will be updated below. */
		vm_Dirty(stm);
	    }
	}

	/* Store val into slot, advance rat: */
	VEC_P(vec)->slot[rat] = val;	             vm_Dirty(vec);
	STM_P(stm)->rat       = OBJ_FROM_INT(nxt);   vm_Dirty(stm);
    }
}



/************************************************************************/
/*-    stm_Pull -- Pull a value off stream.				*/
/************************************************************************/

Vm_Obj
stm_Pull(
    Vm_Obj stm
) {
    Vm_Int cat;
    Vm_Int rat;
    Vm_Int nxt;
    Vm_Obj vec;
    Vm_Obj val;
    Vm_Int len;
    {   Stm_P q = STM_P(stm);
	cat = OBJ_TO_INT( q->cat );
	rat = OBJ_TO_INT( q->rat );
	vec = q->vector;
    }
    len = vec_Len( vec );

    /* Check for stream empty: */
    if (cat==rat)   MUQ_WARN ("pull: stream is empty.");

    /* Fetch value, advance cat: */
    {   Vec_P v = VEC_P( vec );
	val = v->slot[cat];
	v->slot[cat] = OBJ_FROM_INT(0);	/* Promote garbage collection. */
	vm_Dirty(vec);
    }
    nxt = cat+1;
    if (nxt == len)   nxt = 0;
    STM_P(stm)->cat = OBJ_FROM_INT(nxt);
    vm_Dirty(stm);

    return val;
}




/************************************************************************/
/*-    stm_Unpull -- Unpull a value onto stream.			*/
/************************************************************************/

void
stm_Unpull(
    Vm_Obj stm,
    Vm_Obj val
) {
    Vm_Int cat;
    Vm_Int rat;
    Vm_Obj vec;
    {   Stm_P s = STM_P(stm);
	cat = OBJ_TO_INT( s->cat );
	rat = OBJ_TO_INT( s->rat );
	vec = s->vector;
    }

    {   /* Decide where to put new value, make sure it is empty: */
	Vm_Int len = vec_Len(vec);
	Vm_Int prv = cat;
	if (prv == 0)   prv = len;
	--prv;
	if (prv == rat) {

	    /* Stream is full.  Try expanding it: */
	    Vm_Int new_len = 2*len;
	    if (   new_len > STM_SIZE_MAX) {
		MUQ_WARN ("unpull: stream is full.");
	    }
	    vec = vec_SizedDup( vec, new_len );

	    /* Vector has been expanded, now we  */
	    /* slide everything from 'cat' to    */
            /* old end of vector down into new   */
            /* space just allocated:             */
	    {   Vec_P v = VEC_P(vec);
		Vm_Int i;
		for (i = cat;   i < len;   ++i) {
		    v->slot[i+len] = v->slot[i];
		}
		vm_Dirty(vec);
	    }
	    if (rat == len-1) {
		rat += len;
	    }
	    cat += len;
	    prv  = cat-1;
	    len  = new_len;

	    /* Install new vector and 'rat' val: */
	    {   Stm_P s   = STM_P(stm);
		s->vector = vec;
		s->rat    = OBJ_FROM_INT(rat);
		vm_Dirty(stm);
	    }
	}

	/* Retreat cat, store val into slot: */
        cat		      = prv;
	STM_P(stm)->cat       = OBJ_FROM_INT(cat);   vm_Dirty(stm);
	VEC_P(vec)->slot[cat] = val;	             vm_Dirty(vec);
    }
}



/************************************************************************/
/*-    stm_Unpush -- Unpush a value from stream.			*/
/************************************************************************/

Vm_Obj
stm_Unpush(
    Vm_Obj stm
) {
    Vm_Int cat;
    Vm_Int rat;
    Vm_Obj vec;
    Vm_Obj val;
    Vm_Int len;
    {   Stm_P q = STM_P(stm);
	cat = OBJ_TO_INT( q->cat );
	rat = OBJ_TO_INT( q->rat );
	vec = q->vector;
    }
    len = vec_Len( vec );

    /* Check for stream empty: */
    if (cat==rat)   MUQ_WARN ("unpush: stream is empty.");

    /* Fetch value, retreat rat: */
    if (rat == 0)   rat = len;
    --rat;
    STM_P(stm)->rat = OBJ_FROM_INT(rat);
    vm_Dirty(stm);
    {   Vec_P v = VEC_P( vec );
	val = v->slot[rat];
	v->slot[rat] = OBJ_FROM_INT(0);	/* Promote garbage collection. */
	vm_Dirty(vec);
    }

    return val;
}




/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new stm object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Create stream vector: */
    Vm_Obj vec = vec_Alloc( STM_SIZE_DEFAULT, OBJ_FROM_INT(0) );

    /* Initialize ourself: */
    {   Stm_P s 	= STM_P(o);
	s->vector	= vec;
	s->cat		= OBJ_FROM_INT(0);
	s->rat		= OBJ_FROM_INT(0);
	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_stm -- Return size of stack.				*/
/************************************************************************/

static Vm_Unt
sizeof_stm(
    Vm_Unt size
) {
    return sizeof( Stm_A_Header );
}







/************************************************************************/
/*-    stm_x_del -- Delete given 'key'.				       	*/
/************************************************************************/

static Vm_Obj
stm_x_del (
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    /* Streams do not support this concept at all: */
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    stm_x_get -- Get value for given 'key'.			       	*/
/************************************************************************/

static Vm_Obj
stm_x_get (
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    if (propdir != OBJ_PROP_PUBLIC
    ||  !OBJ_IS_INT(key)
    ){
	return OBJ_GET( obj, key, propdir );
    }
    {   Vm_Unt len = OBJ_TO_UNT( stm_Length( obj ) );
	Vm_Unt n   = (Vm_Unt) OBJ_TO_INT(key);

	if (n >= len) {
	    Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	    if (m >= len)   return OBJ_NOT_FOUND;
	    n = m;
	}
	return stm_Nth( obj, (Vm_Int) n );
    }
}



/************************************************************************/
/*-    stm_x_set -- Set value for given 'key'.			       	*/
/************************************************************************/

static Vm_Uch*
stm_x_set (
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Obj  val,
    Vm_Int  propdir
) {
    if (propdir != OBJ_PROP_PUBLIC
    ||  !OBJ_IS_INT(key)
    ){
	return OBJ_SET( obj, key, val, propdir );
    }
    {   Vm_Unt len = OBJ_TO_UNT( stm_Length( obj ) );
	Vm_Unt n   = (Vm_Unt) OBJ_TO_INT(key);

	if (n >= len) {
	    Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	    if (m >= len)   return "Attempt to set nonexistent stream slot.";
	    n = m;
	}
	stm_Set_Nth( obj, (Vm_Int)n, val );
	return NULL;
    }
}



/************************************************************************/
/*-    stm_x_nxt -- Next key after given 'key'.			       	*/
/************************************************************************/

static Vm_Obj
stm_x_nxt(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    Vm_Int len = OBJ_TO_INT( stm_Length( obj ) );
    Vm_Obj nxt = OBJ_NEXT( obj, key, propdir );
    if (propdir == OBJ_PROP_PUBLIC   &&   len) {
	if (nxt == OBJ_NOT_FOUND
	||  0 < obj_Neql( nxt, OBJ_FROM_INT(0) )
	){  Vm_Int k1  = OBJ_TO_INT(key) +1;
	    if (!OBJ_IS_INT(key))   return OBJ_FROM_INT( 0);
	    if (k1 < 0)             return OBJ_FROM_INT( 0);
	    if (k1 < len)           return OBJ_FROM_INT(k1);
    }	}
    return nxt;
}




/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    stm_vector							*/
/************************************************************************/

static Vm_Obj
stm_vector(
    Vm_Obj o
) {
    return STM_P(o)->vector;
}



/************************************************************************/
/*-    stm_set_length             					*/
/************************************************************************/

static Vm_Obj
stm_set_length(
    Vm_Obj o,
    Vm_Obj v
) {
    /* STM(o)->length = v; */
    /* vm_Dirty(o);        */

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    stm_set_vector             					*/
/************************************************************************/

static Vm_Obj
stm_set_vector(
    Vm_Obj o,
    Vm_Obj v
) {
    /* STM(o)->vector = v; */
    /* vm_Dirty(o);        */

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
