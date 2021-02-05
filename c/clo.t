@example  @c

/*--   clo.c -- CLass-defined Object support for Muq.			*/
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
/* Created:      95Sep24						*/
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

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static Vm_Chr* clo_sprintX( Vm_Chr*, Vm_Chr*, Vm_Obj, Vm_Int );
static Vm_Obj  clo_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  clo_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  clo_g_asciz( Vm_Obj, Vm_Chr*, Vm_Int );
static Vm_Chr* clo_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  clo_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  clo_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void    clo_export(  FILE*, Vm_Obj, Vm_Int );

static Vm_Obj  get_mos_key( Vm_Obj );
#endif



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void clo_doTypes(void){
/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
    if (mod_Type_Summary[ OBJ_TYPE_STRUCT ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_STRUCT");
    }
    mod_Type_Summary[ OBJ_TYPE_STRUCT ] = &stc_Type_Summary;
#endif
}
Obj_A_Module_Summary clo_Module_Summary = {
   "clo",
    clo_doTypes,
    clo_Startup,
    clo_Linkup,
    clo_Shutdown
};

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
Obj_A_Type_Summary clo_Type_Summary = {    OBJ_FROM_BYT1('O'),
    clo_sprintX,
    clo_sprintX,
    clo_sprintX,
    clo_for_del,
    clo_for_get,
    clo_g_asciz,
    clo_for_set,
    clo_for_nxt,
    obj_X_Key,
    get_mos_key,
    clo_import,
    clo_export,
    OBJ_0
};
#endif




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    clo_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
clo_Startup(
    void
) {
    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;

}



/************************************************************************/
/*-    clo_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
clo_Linkup(
    void
) {
    static int done_linkup  = FALSE;
    if        (done_linkup)   return;
    done_linkup		    = TRUE;

}



/************************************************************************/
/*-    clo_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
clo_Shutdown(
    void
) {

    static int done_shutdown = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	     = TRUE;
}




/************************************************************************/
/*-    clo_Invariants -- Sanity check on clo.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
clo_Invariants(
    FILE* errlog,
    char* title,
    Vm_Obj clo
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, clo );
#endif
    return errs;
}




/************************************************************************/
/*-    clo_Alloc -- Return a new 'n'-slot object.			*/
/************************************************************************/

 /***********************************************************************/
 /*-   clo_alloc -- Return a new 'n'-slot object.			*/
 /***********************************************************************/

static Vm_Obj
clo_alloc(
    Vm_Unt slots
) {
    Vm_Obj pkg = JOB_P(jS.job)->package;
    Vm_Int siz = sizeof(Clo_A_Header) + (slots-1) * sizeof(Vm_Obj);
    Vm_Obj o   = vm_Malloc( siz, VM_DBFILE(pkg), OBJ_K_STRUCT );
    job_RunState.bytes_owned += siz;
    return o;
}

 /***********************************************************************/
 /*-   clo_Alloc -- Return a new 'n'-slot struct.			*/
 /***********************************************************************/

Vm_Obj
clo_Alloc(
    Vm_Obj key
) {
    Vm_Unt slots;
    Vm_Obj ini[ KEY_MAX_SLOTS ];

    {   Key_P  p = KEY_P(key);
	Vm_Unt u;
	slots    = OBJ_TO_UNT( p->unshared_slots );
	for (u = 0;   u < slots;   ++u)   ini[u] = p->slot[u].initval;
    }
    {   Vm_Obj o   = clo_alloc( slots );
        Clo_P  p = CLO_P( o );
	Vm_Unt u;

	p->key = key;

	for (u = 0;   u < slots;   ++u)   p->slot[u] = ini[u];
	vm_Dirty(o);

/*printf("clo_Alloc returning %" VM_X "\n",o);*/
	return o;
    }
}



/************************************************************************/
/*-    clo_Dup -- Return exact duplicate of 'o'.			*/
/************************************************************************/

Vm_Obj
clo_Dup(
    Vm_Obj o
) {
/* buggo, no slot read priv enforcement. */
    return obj_Dup(o);
}



/************************************************************************/
/*-    clo_Dup_Est -- Return exact duplicate of 'o'.			*/
/************************************************************************/

Vm_Obj
clo_Dup_Est(
    Vm_Obj o
) {
    Vm_Int i;
    Vm_Int len;
    Est_P  p    = EST_P(&len,o);
    Vm_Obj clo  = clo_alloc(len);
    Clo_P  s    = CLO_P(clo);
    p           = EST_P(&len,o);
    s->key	= p->is_a;
    for (i = 0;   i < len;   ++i) {
/* buggo, no slot read priv enforcement. */
	s->slot[i] = p->slot[i];
    }
    vm_Dirty(clo);
    return clo;
}



/************************************************************************/
/*-    clo_Get -- Get value of 'n'th slot in 'clo'.			*/
/************************************************************************/

Vm_Obj
clo_Get(
    Vm_Obj clo,
    Vm_Unt slot
) {
    Vm_Obj val;
    Vm_Unt slots = clo_Len( clo );
/* buggo: This fn appears to be never referenced. */
/* Do we have a lot of these? Ditto clo_Set(). */
    if (slot >= slots) {   /* Using Vm_Unt saves us >= 0 check. */
	return OBJ_NOT_FOUND;
    }
    if (job_Read_Structure_Slot( &val, clo, slot )) {
	return val;
    }
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    clo_Len -- Return number of slots in 'clo'.			*/
/************************************************************************/

Vm_Int
clo_Len(
    Vm_Obj	clo
) {
    return (
        (   vm_Len(clo)   -   (sizeof(Clo_A_Header) - sizeof(Vm_Obj))   )
        /
        sizeof(Vm_Obj)
    );
}



/************************************************************************/
/*-    clo_Set -- Set value of 'n'th slot in 'clo' to 'val'.		*/
/************************************************************************/

void
clo_Set(
    Vm_Obj clo,
    Vm_Unt slot,
    Vm_Obj val
) {
    if (!job_Write_Structure_Slot( clo, slot, val )) {
	MUQ_WARN ("You may not modify that struct slot");
    }
}



/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    clo_sprintX -- Debug dump of clo state, multi-line format.	*/
/************************************************************************/

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static Vm_Chr*
clo_sprintX(
    Vm_Chr* buf,
    Vm_Chr* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    #ifdef MUQ_VERBOSE
    return  lib_Sprint( buf, lim, "#<struct %" VM_X ">", obj );
    #else
    {   Vm_Chr buf2[ 33 ];
	Vm_Obj key = CLO_P(obj)->clos_key;
	Vm_Obj nam = KEY_P(key)->o.objname;
	Vm_Int len;
	if (!stg_Is_Stg(nam)) {
	    return  lib_Sprint( buf, lim, "#<clos-object>" );
	}
	len = stg_Get_Bytes( buf2, 32, nam, 0 );
	buf2[len] = '\0';
	return  lib_Sprint( buf, lim, "#<a %s>", buf2 );
    }
    #endif
}
#endif



/************************************************************************/
/*-    clo_for_del -- Property delete code.				*/
/************************************************************************/

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static Vm_Obj
clo_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}
#endif



/************************************************************************/
/*-    clo_for_get -- Property fetch code.				*/
/************************************************************************/

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static Vm_Obj
clo_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (propdir == OBJ_PROP_SYSTEM) {
	if (key == job_Kw_Owner)  return CLO_P(obj)->owner;
	if (key == job_Kw_Kind)   return CLO_P(obj)->clos_key;
	return OBJ_NOT_FOUND;
    }
    if (propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;
    if (!OBJ_IS_SYMBOL(key))          return OBJ_NOT_FOUND;

    {   Key_P s = KEY_P( CLO_P(obj)->clos_key );
	Vm_Unt slots = OBJ_TO_UNT( s->slot_count );
	Vm_Unt u;
	for (u = 0;   u < slots;  ++u) {
	    if (s->slot[u].keyword == key) {
		Vm_Obj val;
		if (!job_Read_Structure_Slot( &val, obj, u )) {
		    return OBJ_NOT_FOUND;
		}
		return val;
    }	}   }

    return OBJ_NOT_FOUND;
}
#endif



/************************************************************************/
/*-    clo_g_asciz -- Property fetch code.				*/
/************************************************************************/

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static Vm_Obj
clo_g_asciz(
    Vm_Obj  obj,
    Vm_Chr* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}
#endif



/************************************************************************/
/*-    clo_for_set -- Property store code.				*/
/************************************************************************/

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static Vm_Chr*
clo_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_PUBLIC)   return NULL;
    if (!OBJ_IS_SYMBOL(key))          return NULL;

    {   Key_P s = KEY_P( CLO_P(obj)->clos_key );
	Vm_Unt slots = OBJ_TO_UNT( s->slot_count );
	Vm_Unt u;
	for (u = 0;   u < slots;  ++u) {
	    if (s->slot[u].keyword == key) {
		if (!job_Write_Structure_Slot( obj, u ), val ) {
		    return "You may not modify that structure slot";
		}
		return NULL;
    }	}   }

    return "No such property on this struct";
}
#endif


/************************************************************************/
/*-    clo_for_nxt -- Property fetch code.				*/
/************************************************************************/

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static Vm_Obj
clo_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (propdir == OBJ_PROP_SYSTEM) {
	if (key == OBJ_FIRST)   return job_Kw_Kind;
	if (key == job_Kw_Kind) return job_Kw_Owner;
	return OBJ_NOT_FOUND;
    }
    if (propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;
    if (key==OBJ_FIRST)   return KEY_P( CLO_P(obj)->clos_key )->slot[0].keyword;
    if (!OBJ_IS_SYMBOL(key))          return OBJ_NOT_FOUND;

    {   Key_P s = KEY_P( CLO_P(obj)->clos_key );
	Vm_Unt slots = OBJ_TO_UNT( s->slot_count );
	Vm_Unt u;
	for (u = 0;   u+1 < slots;  ++u) {
	    if (s->slot[u].keyword == key) {
		return s->slot[u+1].keyword;
    }	}   }

    return OBJ_NOT_FOUND;
}
#endif


/************************************************************************/
/*-    clo_import -- Read  object from textfile.			*/
/************************************************************************/

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static Vm_Obj
clo_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    /* Read old name of object: */
    Vm_Int m;
    Vm_Obj n;
    Vm_Obj o;
    if (2 != fscanf(fd, "%" VM_X ":%" VM_D, &o, &m )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("clo_Import: bad input!\n");
    }    

    /* Make/find clo to hold result: */
    n = (pass
	? obj_Import_Hashtab_Val( o )
	: clo_alloc( m )
    );
    if (!pass)   obj_Import_Hashtab_Enter( n, o );

    /* Handle any ownership info: */
    if (have) {
	Vm_Obj own     = obj_Import_Any( fd, pass, have, read );
	if (pass && read) {
	    CLO_P(n)->owner = own;
/* buggo, net1/net2 not dealt with. */
	    vm_Dirty(n);
    }   }

    /* Read items in object: */
    {   Vm_Int i;
	for (i = 0;   i < m;   ++i) {
	    Vm_Obj val = obj_Import_Any( fd, pass, have, read );
	    if (pass)   clo_Set( n, i, val );
    }   }
    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    /* Read end-of-object: */
    if (fgetc(fd) != '\n') MUQ_FATAL ("clo_Import: bad input!\n");

    ++obj_Export_Stats->objects_in_file;

    return n;
}
#endif


/************************************************************************/
/*-    clo_export -- Write object into textfile.			*/
/************************************************************************/

/* Seems STC has taken the slot we're sharing...? */
#ifdef HRM
static void
clo_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
    int len = (int)clo_Len(o);
    fprintf( fd, "V:%" VM_X ":%d\n", o, len );
    {   Clo_P  p = CLO_P(o);
	Vm_Int i;
	if (write_owners)  obj_Export_Subobj( fd, p->owner, write_owners );
	for (i = 0;   i < len;   ++i) {
	    obj_Export_Subobj(                fd, p->slot[i], write_owners );
    }	}
    fputc( '\n', fd );
}
#endif


/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    char* t,
    Vm_Obj clo
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
