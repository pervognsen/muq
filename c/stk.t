@example  @c
/*--   stk.c -- loop, data and garden variety STacKs for Muq.		*/
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

/* Tunable parameters: */

/* Stuff you shouldn't need to fiddle with: */

/* Concise access to user record: */
#undef  Q
#define Q(o) STK_P(o)



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_stk( Vm_Unt );
static void     stk_grow(   Vm_Obj );
static Vm_Int   stk_grow_p( Vm_Obj );

static Vm_Obj   stk_x_del( Vm_Obj, Vm_Obj, Vm_Int );
static Vm_Obj   stk_x_get( Vm_Obj, Vm_Obj, Vm_Int );
static Vm_Uch*  stk_x_set( Vm_Obj, Vm_Obj, Vm_Obj, Vm_Int );
static Vm_Obj   stk_x_nxt( Vm_Obj, Vm_Obj, Vm_Int );

static Vm_Obj	stk_vector(	 Vm_Obj  );

static Vm_Obj	stk_set_vector(  Vm_Obj, Vm_Obj );
static Vm_Obj	stk_set_length(  Vm_Obj, Vm_Obj );



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property stk_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"vector"	, stk_vector	, stk_set_vector },
    {0,"length"	, stk_Length	, stk_set_length },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class stk_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','t','k'),
    "Stack",
    sizeof_stk,
    for_new,
    stk_x_del,
    stk_x_get,
    obj_X_Get_Asciz,
    stk_x_set,
    stk_x_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { stk_system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

Obj_A_Hardcoded_Class lst_Hardcoded_Class = {
    OBJ_FROM_BYT3('l','s','t'),
    "LoopStack",
    sizeof_stk,
    for_new,
    stk_x_del,
    stk_x_get,
    obj_X_Get_Asciz,
    stk_x_set,
    stk_x_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { stk_system_properties, stk_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

Obj_A_Hardcoded_Class dst_Hardcoded_Class = {
    OBJ_FROM_BYT3('d','s','t'),
    "DataStack",
    sizeof_stk,
    for_new,
    stk_x_del,
    stk_x_get,
    obj_X_Get_Asciz,
    stk_x_set,
    stk_x_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { stk_system_properties, stk_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void stk_doTypes(void){}
Obj_A_Module_Summary stk_Module_Summary = {
   "stk",
    stk_doTypes,
    stk_Startup,
    stk_Linkup,
    stk_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    stk_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
stk_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    stk_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
stk_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    stk_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
stk_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

}


#ifdef OLD

/************************************************************************/
/*-    stk_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
stk_Import(
    FILE* fd
) {
    MUQ_FATAL ("stk_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    stk_Export -- Write object into textfile.			*/
/************************************************************************/

void
stk_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("stk_Export unimplemented");
}


#endif


/************************************************************************/
/*-    stk_Dup -- Return duplicate of stack.				*/
/************************************************************************/

Vm_Obj
stk_Dup(
    Vm_Obj stack
) {
    Vm_Obj stk = obj_Dup( stack );
    Vm_Obj vec = vm_Dup( STK_P(stk)->vector, VM_DBFILE(stk) );
    STK_P(stk)->vector = vec;
    vm_Dirty(stk);
    return stk;
}



/************************************************************************/
/*-    stk_Length -- Get length.					*/
/************************************************************************/

Vm_Obj
stk_Length(
    Vm_Obj stk
) {
    return STK_P(stk)->length;
}



/************************************************************************/
/*-    stk_x_del -- Delete given 'key'.				       	*/
/************************************************************************/

static Vm_Obj
stk_x_del (
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    /* Stacks do not support this concept at all: */
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    stk_x_get -- Get value for given 'key'.			       	*/
/************************************************************************/

static Vm_Obj
stk_x_get (
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    if (propdir != OBJ_PROP_PUBLIC
    ||  !OBJ_IS_INT(key)
    ){
	return obj_X_Get( obj, key, propdir );
    }
    {   Vm_Unt len = OBJ_TO_UNT( STK_P(obj)->length );
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
	return stk_Get( obj, (Vm_Int) n );
    }
}



/************************************************************************/
/*-    stk_x_set -- Set value for given 'key'.			       	*/
/************************************************************************/

static Vm_Uch*
stk_x_set (
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
    {   Vm_Unt len = OBJ_TO_UNT( STK_P(obj)->length );
	Vm_Unt n   = (Vm_Unt) OBJ_TO_INT(key);

	if (n >= len) {
	    Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	    if (m >= len)   return "Attempt to set nonexistent stack slot.";
	    n = m;
	}
	stk_Set( obj, (Vm_Int)n, val );
	return NULL;
    }
}



/************************************************************************/
/*-    stk_x_nxt -- Next key after given 'key'.			       	*/
/************************************************************************/

static Vm_Obj
stk_x_nxt(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    Vm_Int len = OBJ_TO_INT( STK_P(obj)->length );
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
/*-    stk_Get -- Get nth entry						*/
/************************************************************************/

Vm_Obj
stk_Get(
    Vm_Obj stk,
    Vm_Int n
) {
    Vm_Obj vec = STK_P(stk)->vector;
    Vm_Int len = OBJ_TO_UNT( STK_P(stk)->length );
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
/*-    stk_Get_Int -- Do array-fetch from 'stk', return Vm_Int.		*/
/************************************************************************/

Vm_Int
stk_Get_Int(
    Vm_Obj stk,
    Vm_Unt loc
) {
    Vm_Obj c = stk_Get(stk,loc);
    if (!OBJ_IS_INT(c)) {
	MUQ_WARN ("Need int");
    }
    return OBJ_TO_INT(c);
}



/************************************************************************/
/*-    stk_Got_Headroom -- TRUE if 'n' free slots above sp.		*/
/************************************************************************/

Vm_Int
stk_Got_Headroom(
    Vm_Obj stk,
    Vm_Int n
) {
    /* Make sure there's room enough on stack: */
    Vm_Int len = OBJ_TO_UNT( STK_P(stk)->length );
    for (;;) {
	Vm_Int slots = vec_Len( STK_P(stk)->vector );
	if (len+n < slots)      return TRUE;
	if (!stk_grow_p(stk))   return FALSE;
    }
}



/************************************************************************/
/*-    stk_Set -- Set nth entry						*/
/************************************************************************/

void
stk_Set(
    Vm_Obj stk,
    Vm_Int n,
    Vm_Obj val
) {
    Vm_Obj vec = STK_P(stk)->vector;
    Vm_Int len = OBJ_TO_UNT( STK_P(stk)->length );
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
/*-    stk_Set_Int -- Set nth entry					*/
/************************************************************************/

void
stk_Set_Int(
    Vm_Obj stk,
    Vm_Int n,
    Vm_Int val
) {
    stk_Set( stk, n, OBJ_FROM_INT( val ) );
}



/************************************************************************/
/*-    stk_Reset -- Reset to empty					*/
/************************************************************************/

void
stk_Reset(
    Vm_Obj stk
) {
    Vm_Int len;
    {   Stk_P s    = STK_P(stk);
	len        = OBJ_TO_INT( s->length );
	s->length  = OBJ_FROM_INT(0);
	vm_Dirty(stk);
    }
    {   Vm_Obj vec = STK_P(stk)->vector;
	Vec_P  v   = VEC_P(vec);
	Vm_Int i   = len;
	while (i --> 0) v->slot[i] = OBJ_FROM_INT(0);
	vm_Dirty(vec);
    }
}



/************************************************************************/
/*-    stk_Empty_P -- TRUE iff empty					*/
/************************************************************************/

Vm_Int
stk_Empty_P(
    Vm_Obj stk
) {
    return STK_P(stk)->length == 0;
}



/************************************************************************/
/*-    stk_Push_Block -- Push a block of values on stack.		*/
/************************************************************************/

void
stk_Push_Block(
    Vm_Obj stk,
    Vm_Unt num
) {
    Vm_Int log_len = OBJ_TO_INT( STK_P(stk)->length );
    Vm_Obj vec;
    Vm_Int vec_len;
    for (;;) {
        vec     = STK_P(stk)->vector;
        vec_len = vec_Len(vec);
	if (log_len+num <= vec_len)   break;
	if (!stk_grow_p(stk)) {
	    MUQ_WARN("]push: Can't grow stack enough.");
	}
    }

    {   Vec_P  v = VEC_P(vec);
	Vm_Unt i;
	for (i = 0;   i < num;   ++i) {
	    v->slot[ log_len+i ] = jS.s[ (-1-num) + i ];
    }	}
    vm_Dirty(vec);

    STK_P(stk)->length = OBJ_FROM_INT( log_len+num );
    vm_Dirty(stk);
}



/************************************************************************/
/*-    stk_Push -- Push a value on stack.				*/
/************************************************************************/

void
stk_Push(
    Vm_Obj stk,
    Vm_Obj val
) {
    Vm_Obj vec     = STK_P(stk)->vector;
    Vm_Int vec_len = vec_Len(vec);
    Vm_Int log_len = OBJ_TO_INT( STK_P(stk)->length );
    if (log_len == vec_len) {
        stk_grow( stk );
	vec = STK_P(stk)->vector;
    }
    VEC_P(vec)->slot[ log_len++ ] = val;
    vm_Dirty(vec);
    STK_P(stk)->length = OBJ_FROM_INT( log_len );
    vm_Dirty(stk);
}



/************************************************************************/
/*-    stk_Pull -- Pull a value off stack.				*/
/************************************************************************/

Vm_Obj
stk_Pull(
    Vm_Obj stk
) {
    Vm_Obj vec     = STK_P(stk)->vector;
/*  Vm_Int vec_len = vec_Len(vec); */
    Vm_Int log_len = OBJ_TO_INT( STK_P(stk)->length );
    if (log_len == 0) 	MUQ_WARN ("pull: stack is empty.");
    {   Vec_P  v   = VEC_P(vec);
	Vm_Obj val = v->slot[ --log_len ];
	v->slot[ log_len ] = OBJ_FROM_INT(0); /* To allow garbage collection.*/
	vm_Dirty(vec);
	STK_P(stk)->length = OBJ_FROM_INT( log_len );
	vm_Dirty(stk);
	return val;
    }
}



/************************************************************************/
/*-    stk_Sprint1  -- Debug dump of stk state, one-line format.	*/
/************************************************************************/

Vm_Uch*
stk_Sprint1(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  stk
) {
    Vm_Int len;
    Vm_Obj vec;
    {   Stk_P  s   = STK_P(stk);
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
		if (buf+2 >= lim)  MUQ_WARN ("stk_Sprint1: buffer overflow");
		*buf++ = ' ';
	    }
	    buf += job_Sprint_Vm_Obj( buf, lim, v->slot[i], TRUE );
    }	}
    *buf = '\0';
    return buf;
}



/************************************************************************/
/*-    stk_Get_Key_P_Asciz -- Return 0/1 and loc of 'sym' in 'stk'.	*/
/************************************************************************/

Vm_Int
stk_Get_Key_P_Asciz(
    Vm_Int*	loc,
    Vm_Obj	stk,
    Vm_Uch*	sym
) {
    /* Search in sp-to-0 order, to get most recent val first:	*/
    Vm_Obj vec;
    Vm_Int len;
    {   Stk_P s= STK_P(stk);
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
/*-    stk_Get_Key_P -- Return FALSE or TRUE and loc of 'c'   in 'stk'.	*/
/************************************************************************/

Vm_Int
stk_Get_Key_P(
    Vm_Int*	loc,
    Vm_Obj	stk,
    Vm_Obj	c
) {
    /* Search in sp-to-0 order, to get most recent val first:	*/
    Vm_Obj vec;
    Vm_Int len;
    {   Stk_P s= STK_P(stk);
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
/*-    stk_Delete -- Delete all instances of given value from stack.	*/
/************************************************************************/

void
stk_Delete(
    Vm_Obj	stk,
    Vm_Obj	c
) {
    /* Search in 0-to-sp order, to facilitate deletions:	*/
    Vm_Obj vec;
    Vm_Int len;
    {   Stk_P s= STK_P(stk);
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
	STK_P(stk)->length = OBJ_FROM_INT(cat - v->slot);
	vm_Dirty(stk);
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
	STK_P(stk)->length = OBJ_FROM_INT(cat);
	vm_Dirty(stk);
    }
}


/************************************************************************/
/*-    stk_Delete_Bth -- Delete nth slot from bottom of stack.		*/
/************************************************************************/

void
stk_Delete_Bth(
    Vm_Obj	stk,
    Vm_Unt	u
) {
    Vm_Obj vec;
    Vm_Unt len;
    {   Stk_P s= STK_P(stk);
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
	STK_P(stk)->length = OBJ_FROM_INT(len - 1);
	vm_Dirty(stk);
    }
}

/************************************************************************/
/*-    stk_Delete_Nth -- Delete nth slot from top of stack.		*/
/************************************************************************/

void
stk_Delete_Nth(
    Vm_Obj	stk,
    Vm_Unt	u
) {
    Vm_Obj vec;
    Vm_Unt len;
    {   Stk_P s= STK_P(stk);
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
	STK_P(stk)->length = OBJ_FROM_INT(len - 1);
	vm_Dirty(stk);
    }
}





/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new stk object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Create stack vector: */
    Vm_Obj stack =vec_Alloc( STK_SIZE_DEFAULT, OBJ_FROM_INT(0) );

    /* Initialize ourself: */
    {   Stk_P s 	= STK_P(o);
    /*	s->maxlen	= OBJ_NIL; */
	s->vector	= stack;
	s->length	= OBJ_FROM_INT(0);
	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_stk -- Return size of stack.				*/
/************************************************************************/

static Vm_Unt
sizeof_stk(
    Vm_Unt size
) {
    return sizeof( Stk_A_Header );
}




/************************************************************************/
/*-    stk_grow_p -- Maybe double size of stack.			*/
/************************************************************************/

static Vm_Int
stk_grow_p(
    Vm_Obj stk
) {
    Vm_Obj vec = STK_P(stk)->vector;
    Vm_Int len = vec_Len( vec );
    Vm_Int new_len = 2*len;
    if (   new_len > STK_SIZE_MAX) {
        return FALSE;
    }
    vec = vec_SizedDup( vec, new_len );
    STK_P(stk)->vector = vec;
    vm_Dirty(stk);
    return TRUE;
}



/************************************************************************/
/*-    stk_grow -- Double size of stack.				*/
/************************************************************************/

static void
stk_grow(
    Vm_Obj stk
) {
    if (!stk_grow_p(stk))   MUQ_WARN ("push: stack overflow");
}




/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    stk_vector							*/
/************************************************************************/

static Vm_Obj
stk_vector(
    Vm_Obj o
) {
    return STK_P(o)->vector;
}



/************************************************************************/
/*-    stk_set_length             					*/
/************************************************************************/

static Vm_Obj
stk_set_length(
    Vm_Obj o,
    Vm_Obj v
) {
    /* STK(o)->length = v; */
    /* vm_Dirty(o);        */

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    stk_set_vector             					*/
/************************************************************************/

static Vm_Obj
stk_set_vector(
    Vm_Obj o,
    Vm_Obj v
) {
    /* STK(o)->vector = v; */
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
