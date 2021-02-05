@example  @c
/* buggo: need to change 'nth' to just plain 'get' on an */
/* integer key. */


/*--   evc.c -- Ephemeral VeCtor support for Muq.			*/
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
/* Created:      95Sep28						*/
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

/************************************************************************/
/*

 ************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

#if MUQ_DEBUG
static Vm_Int   invariants(FILE*,char*,Vm_Obj);
#endif

static Vm_Uch* evc_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  evc_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  evc_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  evc_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* evc_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  evc_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  evc_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void    evc_export(  FILE*, Vm_Obj, Vm_Int );

static Vm_Obj  get_mos_key( Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void evc_doTypes(void){
    if (mod_Type_Summary[OBJ_TYPE_EPHEMERAL_VECTOR] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_EPHEMERAL_VECTOR");
    }
    mod_Type_Summary[ OBJ_TYPE_EPHEMERAL_VECTOR ] = &evc_Type_Summary;
}
Obj_A_Module_Summary evc_Module_Summary = {
   "evc",
    evc_doTypes,
    evc_Startup,
    evc_Linkup,
    evc_Shutdown
};

Obj_A_Type_Summary evc_Type_Summary = {    OBJ_FROM_BYT2('E','V'),
    evc_sprintX,
    evc_sprintX,
    evc_sprintX,
    evc_for_del,
    evc_for_get,
    evc_g_asciz,
    evc_for_set,
    evc_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Dummy_Reverse,
    get_mos_key,
    evc_import,
    evc_export,
    "Vector",
    KEY_LAYOUT_VECTOR,
    OBJ_0
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    evc_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
evc_Startup(
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    evc_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
evc_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    evc_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
evc_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}




/************************************************************************/
/*-    evc_Invariants -- Sanity check on evc.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
evc_Invariants(
    FILE* errlog,
    char* title,
    Vm_Obj evc
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, evc );
#endif
    return errs;
}




/************************************************************************/
/*-    evc_Get_Key_P -- Return 0/1 and loc of 'obj' in 'evc'.		*/
/************************************************************************/

Vm_Int
evc_Get_Key_P(
    Vm_Int*	loc,
    Vm_Obj	evc,
    Vm_Obj	obj
) {
    /* We can do fast pointer compares on  */
    /* everything but strings longer than  */
    /* three bytes:                        */
    if (!OBJ_IS_BYTN(obj)) {
	Vm_Int len;
	Evc_P  p = EVC_P( &len, evc );
	Vm_Int u;
	for   (u = len;   u --> 0;   ) {
	    if (p->slot[u] == obj) { *loc = u; return TRUE; }
	}
	return FALSE;    
    }

    /* Piffle. */
    {   Vm_Int u;
	Vm_Int len;
	(void) EVC_P( &len, evc );
	for   (u = len;   u --> 0;   ) {
	    Vm_Obj val = EVC_P(&len,evc)->slot[u];
	    if (OBJ_IS_BYTN(val) && !obj_Neql(obj,val) ) {
		*loc = u;
		return TRUE;
	}   }
	return FALSE;
    }
}



/************************************************************************/
/*-    evc_Get_Key_P_Asciz -- Return 0/1 and loc of 'str' in 'evc'.	*/
/************************************************************************/

Vm_Int
evc_Get_Key_P_Asciz(
    Vm_Int*	loc,
    Vm_Obj	evc,
    Vm_Uch*	str
) {
    /* Search in sp-to-0 order, to get most recent val first:	*/
    Vm_Int len;
    Vm_Int u;
    (void) EVC_P( &len, evc );
    for   (u = len;   u --> 0;   ) {
	Vm_Obj v = EVC_P( &len, evc )->slot[u];
	if (stg_Is_Stg(v) && !obj_StrNeql( str, v )){
	    *loc = u;
	    return TRUE;
    }   }
    return FALSE;    
}



/************************************************************************/
/*-    evc_Get -- Get value of 'n'th slot in 'evc'.			*/
/************************************************************************/

Vm_Obj
evc_Get(
    Vm_Obj evc,
    Vm_Unt n
) {
    Vm_Unt len;
    Evc_P p = EVC_P((Vm_Int*)&len,evc);

    if (n >= len) {   /* Using Vm_Unt saves us >= 0 check. */
	/* Allow negative indexing also: */
	Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	if (m >= len)   return OBJ_NOT_FOUND;
	n = m;
    }

    return p->slot[n];  
}



/************************************************************************/
/*-    evc_Len -- Return number of slots in 'evc'.			*/
/************************************************************************/

Vm_Int
evc_Len(
    Vm_Obj	evc
) {
    Vm_Int len;
    (void) EVC_P((Vm_Int*)&len,evc);
    return len;
}



/************************************************************************/
/*-    evc_Set -- Set value of 'n'th slot in 'evc' to 'val'.		*/
/************************************************************************/

void
evc_Set(
    Vm_Obj evc,
    Vm_Unt n,
    Vm_Obj val
) {
    Vm_Unt len;
    Evc_P p = EVC_P((Vm_Int*)&len,evc);

    if (n >= len) {   /* Using Vm_Unt saves us >= 0 check. */
	/* Allow negative indexing also: */
	Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	if (m >= len)  MUQ_WARN ("Can't set slot %d in %d-slot evc", (int)n, (int)len );
	n = m;
    }

    p->slot[n] = val;
}


/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    evc_sprintX -- Debug dump of evc state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
evc_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    #ifdef MUQ_VERBOSE
    return  lib_Sprint( buf, lim, "#<evc %" VM_X ">", obj );
    #else
    return  lib_Sprint( buf, lim, "#<ephemeral vector>" );
    #endif
}



/************************************************************************/
/*-    evc_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
evc_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    evc_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
evc_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (!OBJ_IS_INT(key))   return OBJ_NOT_FOUND;
    return evc_Get( obj, (Vm_Unt)OBJ_TO_INT(key) );
}



/************************************************************************/
/*-    evc_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
evc_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    evc_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
evc_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    if (!OBJ_IS_INT(key)) {
	return "May not 'set' non-integer properties on ephemeral vectors.";
    }
    evc_Set( obj, OBJ_TO_INT(key), val );
    return NULL;
}



/************************************************************************/
/*-    evc_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
evc_for_nxt(
    Vm_Obj evc,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Int len;
    (void) EVC_P(&len,evc);

    if (propdir != OBJ_PROP_PUBLIC)      return OBJ_NOT_FOUND;
    if (len     == 0)                    return OBJ_NOT_FOUND;
    if (0 < obj_Neql( OBJ_FROM_INT(0), key ))   return OBJ_FROM_INT(0);
    if (OBJ_IS_INT(key)) {
	Vm_Int k1 = OBJ_TO_INT(key) +1;
	if    (k1 < len)   return OBJ_FROM_INT(k1);
    }
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    get_mos_key -- Find key object for this structure		*/
/************************************************************************/

static Vm_Obj
get_mos_key(
    Vm_Obj obj
) {
    Vm_Int len;
    return EVC_P(&len,obj)->is_a;
}

/************************************************************************/
/*-    evc_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj
evc_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    MUQ_FATAL ("evc_import: unimplemented\n");
    return OBJ_NIL;
}



/************************************************************************/
/*-    evc_export -- Write object into textfile.			*/
/************************************************************************/

static void
evc_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
    MUQ_FATAL ("evc_export: unimplemented\n");
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    char* t,
    Vm_Obj evc
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif




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
