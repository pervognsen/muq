@example  @c
/*--   ary.c -- loop, data and garden variety STacKs for Muq.		*/
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
/* Created:      99Aug23						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 2000, by Jeff Prothero.				*/
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

/* Concise access to user record: */
#undef  Q
#define Q(o) ARY_P(o)



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_ary( Vm_Unt );
static void     ary_grow(   Vm_Obj );
static Vm_Int   ary_grow_p( Vm_Obj );

static Vm_Obj   ary_x_del( Vm_Obj, Vm_Obj, Vm_Int );
static Vm_Obj   ary_x_get( Vm_Obj, Vm_Obj, Vm_Int );
static Vm_Uch*  ary_x_set( Vm_Obj, Vm_Obj, Vm_Obj, Vm_Int );
static Vm_Obj   ary_x_nxt( Vm_Obj, Vm_Obj, Vm_Int );

static Vm_Obj	ary_vector(	 Vm_Obj  );

static Vm_Obj	ary_set_vector(  Vm_Obj, Vm_Obj );
static Vm_Obj	ary_set_length(  Vm_Obj, Vm_Obj );



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property ary_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"vector"	, ary_vector	, ary_set_vector },
    {0,"length"	, ary_Length	, ary_set_length },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class ary_Hardcoded_Class = {
    OBJ_FROM_BYT3('a','r','y'),
    "Array",
    sizeof_ary,
    for_new,
    ary_x_del,
    ary_x_get,
    obj_X_Get_Asciz,
    ary_x_set,
    ary_x_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Dummy_Reverse,
    obj_Get_Mos_Key,
    { ary_system_properties, ary_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void ary_doTypes(void){}
Obj_A_Module_Summary ary_Module_Summary = {
   "ary",
    ary_doTypes,
    ary_Startup,
    ary_Linkup,
    ary_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    ary_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
ary_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    ary_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
ary_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    ary_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
ary_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

}


#ifdef OLD

/************************************************************************/
/*-    ary_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
ary_Import(
    FILE* fd
) {
    MUQ_FATAL ("ary_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    ary_Export -- Write object into textfile.			*/
/************************************************************************/

void
ary_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("ary_Export unimplemented");
}


#endif


/************************************************************************/
/*-    ary_Alloc -- Return a new 'n'-slot array.			*/
/************************************************************************/

Vm_Obj
ary_Alloc(
    Vm_Unt n,
    Vm_Obj a
) {
    /* jS.job is FALSE only briefly during initial bootstrap: */
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    Vm_Int siz = sizeof(Ary_A_Header);
    Vm_Obj o = vm_Malloc( siz, VM_DBFILE(pkg), OBJ_K_OBJ );

MUQ_WARN("ary_Alloc unimplemented");
    return o;
}



/************************************************************************/
/*-    ary_Dup -- Return duplicate of stack.				*/
/************************************************************************/

Vm_Obj
ary_Dup(
    Vm_Obj stack
) {
    Vm_Obj ary = obj_Dup( stack );
    Vm_Obj vec = vm_Dup( ARY_P(ary)->vector, VM_DBFILE(ary) );
    ARY_P(ary)->vector = vec;
    vm_Dirty(ary);
    return ary;
}



/************************************************************************/
/*-    ary_Length -- Get length.					*/
/************************************************************************/

Vm_Obj
ary_Length(
    Vm_Obj ary
) {
    return ARY_P(ary)->length;
}



/************************************************************************/
/*-    ary_x_del -- Delete given 'key'.				       	*/
/************************************************************************/

static Vm_Obj
ary_x_del (
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    /* Stacks do not support this concept at all: */
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    ary_x_get -- Get value for given 'key'.			       	*/
/************************************************************************/

static Vm_Obj
ary_x_get (
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    if (propdir != OBJ_PROP_PUBLIC
    ||  !OBJ_IS_INT(key)
    ){
	return obj_X_Get( obj, key, propdir );
    }
    {   Vm_Unt len = OBJ_TO_UNT( ARY_P(obj)->length );
	Vm_Unt n   = (Vm_Unt) OBJ_TO_INT(key);

	/* A bit of weird hacking so that,   */
	/* while indices 0,1,2... access the */
	/* stack starting at the bottom, the */
        /* indices -1,-2,-3... access the    */
	/* stack starting at the top:        */
	if (n >= len) {
	    Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	    if (m >= len)   return OBJ_NOT_FOUND;
	    n = m;
	}
	return ary_Get( obj, (Vm_Int) n );
    }
}



/************************************************************************/
/*-    ary_x_set -- Set value for given 'key'.			       	*/
/************************************************************************/

static Vm_Uch*
ary_x_set (
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Obj  val,
    Vm_Int  propdir
) {
    if (propdir != OBJ_PROP_PUBLIC
    ||  !OBJ_IS_INT(key)
    ){
	return obj_X_Set( obj, key, val, propdir );
    }
    {   Vm_Unt len = OBJ_TO_UNT( ARY_P(obj)->length );
	Vm_Unt n   = (Vm_Unt) OBJ_TO_INT(key);

	if (n >= len) {
	    Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	    if (m >= len)   return "Attempt to set nonexistent stack slot.";
	    n = m;
	}
	ary_Set( obj, (Vm_Int)n, val );
	return NULL;
    }
}



/************************************************************************/
/*-    ary_x_nxt -- Next key after given 'key'.			       	*/
/************************************************************************/

static Vm_Obj
ary_x_nxt(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    Vm_Int len = OBJ_TO_INT( ARY_P(obj)->length );
    Vm_Obj nxt = obj_X_Next( obj, key, propdir );
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
/*-    ary_Get -- Get nth entry						*/
/************************************************************************/

Vm_Obj
ary_Get(
    Vm_Obj ary,
    Vm_Int n
) {
    Vm_Obj vec = ARY_P(ary)->vector;
    Vm_Int len = OBJ_TO_UNT( ARY_P(ary)->length );
    if (n >= 0) {
        if (n >= len) {
	    MUQ_WARN ("stack has no %dth element.",(int)n);
	}
	return VEC_P(vec)->slot[ n ];
    } else {
        if (-n > len) {
	    MUQ_WARN ("stack has no %dth element.",(int)n);
	}
        return VEC_P(vec)->slot[ len+n ];
    }
}



/************************************************************************/
/*-    ary_Get_Int -- Do array-fetch from 'ary', return Vm_Int.		*/
/************************************************************************/

Vm_Int
ary_Get_Int(
    Vm_Obj ary,
    Vm_Unt loc
) {
    Vm_Obj c = ary_Get(ary,loc);
    if (!OBJ_IS_INT(c)) {
	MUQ_WARN ("Need int");
    }
    return OBJ_TO_INT(c);
}



/************************************************************************/
/*-    ary_Got_Headroom -- TRUE if 'n' free slots above sp.		*/
/************************************************************************/

Vm_Int
ary_Got_Headroom(
    Vm_Obj ary,
    Vm_Int n
) {
    /* Make sure there's room enough on stack: */
    Vm_Int len = OBJ_TO_UNT( ARY_P(ary)->length );
    for (;;) {
	Vm_Int slots = vec_Len( ARY_P(ary)->vector );
	if (len+n < slots)      return TRUE;
	if (!ary_grow_p(ary))   return FALSE;
    }
}



/************************************************************************/
/*-    ary_Set -- Set nth entry						*/
/************************************************************************/

void
ary_Set(
    Vm_Obj ary,
    Vm_Int n,
    Vm_Obj val
) {
    Vm_Obj vec = ARY_P(ary)->vector;
    Vm_Int len = OBJ_TO_UNT( ARY_P(ary)->length );
    if (n >= 0) {
        if (n >= len)   MUQ_WARN ("stack has no %dth element.",(int)n);
	VEC_P(vec)->slot[     n ] = val;
    } else {
        if (-n > len)   MUQ_WARN ("stack has no %dth element.",(int)n);
        VEC_P(vec)->slot[ len+n ] = val;
    }
    vm_Dirty(vec);
}



/************************************************************************/
/*-    ary_Set_Int -- Set nth entry					*/
/************************************************************************/

void
ary_Set_Int(
    Vm_Obj ary,
    Vm_Int n,
    Vm_Int val
) {
    ary_Set( ary, n, OBJ_FROM_INT( val ) );
}



/************************************************************************/
/*-    ary_Reset -- Reset to empty					*/
/************************************************************************/

void
ary_Reset(
    Vm_Obj ary
) {
    Vm_Int len;
    {   Ary_P s    = ARY_P(ary);
	len        = OBJ_TO_INT( s->length );
	s->length  = OBJ_FROM_INT(0);
	vm_Dirty(ary);
    }
    {   Vm_Obj vec = ARY_P(ary)->vector;
	Vec_P  v   = VEC_P(vec);
	Vm_Int i   = len;
	while (i --> 0) v->slot[i] = OBJ_FROM_INT(0);
	vm_Dirty(vec);
    }
}



/************************************************************************/
/*-    ary_Empty_P -- TRUE iff empty					*/
/************************************************************************/

Vm_Int
ary_Empty_P(
    Vm_Obj ary
) {
    return ARY_P(ary)->length == 0;
}



/************************************************************************/
/*-    ary_Push_Block -- Push a block of values on stack.		*/
/************************************************************************/

void
ary_Push_Block(
    Vm_Obj ary,
    Vm_Unt num
) {
    Vm_Int log_len = OBJ_TO_INT( ARY_P(ary)->length );
    Vm_Obj vec;
    Vm_Int vec_len;
    for (;;) {
        vec     = ARY_P(ary)->vector;
        vec_len = vec_Len(vec);
	if (log_len+num <= vec_len)   break;
	if (!ary_grow_p(ary)) {
	    MUQ_WARN("]push: Can't grow stack enough.");
	}
    }

    {   Vec_P  v = VEC_P(vec);
	Vm_Unt i;
	for (i = 0;   i < num;   ++i) {
	    v->slot[ log_len+i ] = jS.s[ (-1-num) + i ];
    }	}
    vm_Dirty(vec);

    ARY_P(ary)->length = OBJ_FROM_INT( log_len+num );
    vm_Dirty(ary);
}



/************************************************************************/
/*-    ary_Push -- Push a value on stack.				*/
/************************************************************************/

void
ary_Push(
    Vm_Obj ary,
    Vm_Obj val
) {
    Vm_Obj vec     = ARY_P(ary)->vector;
    Vm_Int vec_len = vec_Len(vec);
    Vm_Int log_len = OBJ_TO_INT( ARY_P(ary)->length );
    if (log_len == vec_len) {
        ary_grow( ary );
	vec = ARY_P(ary)->vector;
    }
    VEC_P(vec)->slot[ log_len++ ] = val;
    vm_Dirty(vec);
    ARY_P(ary)->length = OBJ_FROM_INT( log_len );
    vm_Dirty(ary);
}



/************************************************************************/
/*-    ary_Pull -- Pull a value off stack.				*/
/************************************************************************/

Vm_Obj
ary_Pull(
    Vm_Obj ary
) {
    Vm_Obj vec     = ARY_P(ary)->vector;
/*  Vm_Int vec_len = vec_Len(vec); */
    Vm_Int log_len = OBJ_TO_INT( ARY_P(ary)->length );
    if (log_len == 0) 	MUQ_WARN ("pull: stack is empty.");
    {   Vec_P  v   = VEC_P(vec);
	Vm_Obj val = v->slot[ --log_len ];
	v->slot[ log_len ] = OBJ_FROM_INT(0); /* To allow garbage collection.*/
	vm_Dirty(vec);
	ARY_P(ary)->length = OBJ_FROM_INT( log_len );
	vm_Dirty(ary);
	return val;
    }
}



/************************************************************************/
/*-    ary_Sprint1  -- Debug dump of ary state, one-line format.	*/
/************************************************************************/

Vm_Uch*
ary_Sprint1(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  ary
) {
    Vm_Int len;
    Vm_Obj vec;
    {   Ary_P  s   = ARY_P(ary);
	len =  OBJ_TO_INT( s->length );
	vec =              s->vector;
    }
    {   Vec_P  v   = VEC_P(vec);
	Vm_Int i;
	Vm_Int lo  = (v->slot[0] == OBJ_FROM_BOTTOM(0))  ?  2  :  0;
	if (len > 40) {
	    lo = len - 30;
    	    buf = lib_Sprint( buf, lim, "... " );
	}
	for (i = lo;   i < len;   ++i) {
	    if (i != lo) {
		if (buf+2 >= lim)  MUQ_WARN ("ary_Sprint1: buffer overflow");
		*buf++ = ' ';
	    }
	    buf += job_Sprint_Vm_Obj( buf, lim, v->slot[i], TRUE );
    }	}
    *buf = '\0';
    return buf;
}



/************************************************************************/
/*-    ary_Get_Key_P_Asciz -- Return 0/1 and loc of 'sym' in 'ary'.	*/
/************************************************************************/

Vm_Int
ary_Get_Key_P_Asciz(
    Vm_Int*	loc,
    Vm_Obj	ary,
    Vm_Uch*	sym
) {
    /* Search in sp-to-0 order, to get most recent val first:	*/
    Vm_Obj vec;
    Vm_Int len;
    {   Ary_P s= ARY_P(ary);
	vec    =             s->vector;
	len    = OBJ_TO_INT( s->length );
    }
    {   Vm_Int u = len;	  	/* Number of cells to search.	*/
	while (u --> 0) {
	    Vm_Obj  v = VEC_P(vec)->slot[u]; /* Cell to search.	*/
	    if (stg_Is_Stg(v) && !obj_StrNeql(sym,v)){
		*loc = u;
		return TRUE;
    }   }   }
    return FALSE;
}



/************************************************************************/
/*-    ary_Get_Key_P -- Return FALSE or TRUE and loc of 'c'   in 'ary'.	*/
/************************************************************************/

Vm_Int
ary_Get_Key_P(
    Vm_Int*	loc,
    Vm_Obj	ary,
    Vm_Obj	c
) {
    /* Search in sp-to-0 order, to get most recent val first:	*/
    Vm_Obj vec;
    Vm_Int len;
    {   Ary_P s= ARY_P(ary);
	vec    =             s->vector;
	len    = OBJ_TO_INT( s->length );
    }

    /* We can do fast pointer compares on  */
    /* everything but strings longer than  */
    /* seven bytes and proxies:            */
    if (!OBJ_IS_BYTN(c)
    && (!OBJ_IS_OBJ(c) || !OBJ_IS_CLASS_PRX(c))
    ){
	Vec_P    v = VEC_P(vec);
	Vm_Int   u = len;		/* Number of cells to search.	*/
	Vm_Obj*  j = &v->slot[len-1];	/* First     cell  to search.	*/
	for (;   u --> 0;   --j) {
	    if (*j == c) {
		*loc = u;
		return TRUE;
	}   }
	return FALSE;
    }

    /* Rmph. We're reduced to honesty: */
    {   Vm_Int   u = len;		/* Number of cells to search.	*/
	while (u --> 0) {
	    /* We need to re-locate vec each cycle */
	    /* because obj_Neql may invalidate our */
	    /* address for it.  We could buffer a  */
	    /* few entries in a C buffer, if we    */
	    /* wanted to speed this up a bit:      */
	    Vm_Obj val = VEC_P(vec)->slot[u];
	    if (  (OBJ_IS_BYTN(val)
               || (OBJ_IS_OBJ(val) && OBJ_IS_CLASS_PRX(val))
               )
            && !obj_Neql(c,val)
            ){
		*loc = u;
		return TRUE;
	}   }
	return FALSE;
    }
}

/************************************************************************/
/*-    ary_Delete -- Delete all instances of given value from stack.	*/
/************************************************************************/

void
ary_Delete(
    Vm_Obj	ary,
    Vm_Obj	c
) {
    /* Search in 0-to-sp order, to facilitate deletions:	*/
    Vm_Obj vec;
    Vm_Int len;
    {   Ary_P s= ARY_P(ary);
	vec    =             s->vector;
	len    = OBJ_TO_INT( s->length );
    }

    /* We can do fast pointer compares on  */
    /* everything but strings longer than  */
    /* seven bytes, and proxies:           */
    if (!OBJ_IS_BYTN(c)
    && (!OBJ_IS_OBJ(c) || !OBJ_IS_CLASS_PRX(c))
    ){
	Vec_P    v   = VEC_P(vec);
	Vm_Int   u   = len;		/* Number of cells left to search.*/
	Vm_Obj*  rat = &v->slot[0];	/* Next      cell  to search.	  */
	Vm_Obj*  cat = rat;		/* Next      cell  to fill.	  */
	for (;   u --> 0;   ++rat) {
	    if (*rat != c) {
		*cat++ = *rat;
	}   }
	vm_Dirty(vec);
	ARY_P(ary)->length = OBJ_FROM_INT(cat - v->slot);
	vm_Dirty(ary);
	return;
    }

    /* Rmph. We're reduced to honesty: */
    {   Vm_Int   u = len;	/* Number of cells to search.	*/
        Vm_Int rat = 0;		/* Next      cell  to examine.	*/
        Vm_Int cat = 0;		/* Next      cell  to fill.	*/
	while (u --> 0) {
	    /* We need to re-locate vec each cycle */
	    /* because obj_Neql may invalidate our */
	    /* address for it.  We could buffer a  */
	    /* few entries in a C buffer, if we    */
	    /* wanted to speed this up a bit:      */
	    Vm_Obj val = VEC_P(vec)->slot[rat++];
	    if (  (OBJ_IS_BYTN(val)
               || (OBJ_IS_OBJ(val) && OBJ_IS_CLASS_PRX(val))
               )
            && obj_Neql(c,val)
            ){
		VEC_P(vec)->slot[cat++] = val;
		vm_Dirty(vec);
	}   }
	ARY_P(ary)->length = OBJ_FROM_INT(cat);
	vm_Dirty(ary);
    }
}


/************************************************************************/
/*-    ary_Delete_Bth -- Delete nth slot from bottom of stack.		*/
/************************************************************************/

void
ary_Delete_Bth(
    Vm_Obj	ary,
    Vm_Unt	u
) {
    Vm_Obj vec;
    Vm_Unt len;
    {   Ary_P s= ARY_P(ary);
	vec    =             s->vector;
	len    = OBJ_TO_UNT( s->length );
    }
    if (u >= len)   MUQ_WARN("deleteBth: No %d-th entry",(int)u);


    {   Vec_P    v   = VEC_P(vec);
	Vm_Int   i   = len-u;		/* Number of cells to move.	*/
	Vm_Obj*  cat = &v->slot[u];	/* Next      cell  to fill.	*/
	Vm_Obj*  rat = cat+1;		/* Next      cell  to copy.	*/
	while (--i > 0)   *cat++ = *rat++;
	vm_Dirty(vec);
	ARY_P(ary)->length = OBJ_FROM_INT(len - 1);
	vm_Dirty(ary);
    }
}

/************************************************************************/
/*-    ary_Delete_Nth -- Delete nth slot from top of stack.		*/
/************************************************************************/

void
ary_Delete_Nth(
    Vm_Obj	ary,
    Vm_Unt	u
) {
    Vm_Obj vec;
    Vm_Unt len;
    {   Ary_P s= ARY_P(ary);
	vec    =             s->vector;
	len    = OBJ_TO_UNT( s->length );
    }
    if (u >= len)   MUQ_WARN("deleteNth: No %d-th entry",(int)u);


    {   Vec_P    v   = VEC_P(vec);
	Vm_Int   i   = len-u;		/* Number of cells left to search.*/
	Vm_Obj*  rat = &v->slot[len-u];	/* Next      cell  to fill.	  */
	Vm_Obj*  cat = rat-1;		/* Next      cell  to copy.	  */
	while (--i > 0)   *cat++ = *rat++;
	vm_Dirty(vec);
	ARY_P(ary)->length = OBJ_FROM_INT(len - 1);
	vm_Dirty(ary);
    }
}





/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new ary object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Create stack vector: */
    Vm_Obj stack =vec_Alloc( ARY_SIZE_DEFAULT, OBJ_FROM_INT(0) );

    /* Initialize ourself: */
    {   Ary_P s 	= ARY_P(o);
	s->vector	= stack;
	s->rank		= OBJ_FROM_INT(1);
	s->length	= OBJ_FROM_INT(0);
	{   int i;
	    for (i = ARY_MAX_RANK;   i --> 0;  )   s->dim[i] = OBJ_FROM_INT(0);
	}
	s->dim[0] = OBJ_FROM_INT(size);
	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_ary -- Return size of stack.				*/
/************************************************************************/

static Vm_Unt
sizeof_ary(
    Vm_Unt size
) {
    return sizeof( Ary_A_Header );
}




/************************************************************************/
/*-    ary_grow_p -- Maybe double size of stack.			*/
/************************************************************************/

static Vm_Int
ary_grow_p(
    Vm_Obj ary
) {
    Vm_Obj vec = ARY_P(ary)->vector;
    Vm_Int len = vec_Len( vec );
    Vm_Int new_len = 2*len;
    if (   new_len > ARY_SIZE_MAX) {
        return FALSE;
    }
    vec = vec_SizedDup( vec, new_len );
    ARY_P(ary)->vector = vec;
    vm_Dirty(ary);
    return TRUE;
}



/************************************************************************/
/*-    ary_grow -- Double size of stack.				*/
/************************************************************************/

static void
ary_grow(
    Vm_Obj ary
) {
    if (!ary_grow_p(ary))   MUQ_WARN ("push: stack overflow");
}




/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    ary_vector							*/
/************************************************************************/

static Vm_Obj
ary_vector(
    Vm_Obj o
) {
    return ARY_P(o)->vector;
}



/************************************************************************/
/*-    ary_set_length             					*/
/************************************************************************/

static Vm_Obj
ary_set_length(
    Vm_Obj o,
    Vm_Obj v
) {
    /* ARY(o)->length = v; */
    /* vm_Dirty(o);        */

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    ary_set_vector             					*/
/************************************************************************/

static Vm_Obj
ary_set_vector(
    Vm_Obj o,
    Vm_Obj v
) {
    /* ARY(o)->vector = v; */
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
