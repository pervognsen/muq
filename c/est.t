@example  @c

/*--   est.c -- Ephemeral STructure support for Muq.			*/
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

static Vm_Uch* est_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  est_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  est_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  est_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* est_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  est_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  est_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void    est_export(  FILE*, Vm_Obj, Vm_Int );

static Vm_Obj  get_mos_key( Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void est_doTypes(void){
    if (mod_Type_Summary[OBJ_TYPE_EPHEMERAL_STRUCT] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_EPHEMERAL_STRUCT");
    }
    mod_Type_Summary[ OBJ_TYPE_EPHEMERAL_STRUCT ] = &est_Type_Summary;
}
Obj_A_Module_Summary est_Module_Summary = {
   "est",
    est_doTypes,
    est_Startup,
    est_Linkup,
    est_Shutdown
};

Obj_A_Type_Summary est_Type_Summary = {    OBJ_FROM_BYT2('E','C'),
    est_sprintX,
    est_sprintX,
    est_sprintX,
    est_for_del,
    est_for_get,
    est_g_asciz,
    est_for_set,
    est_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Dummy_Reverse,
    get_mos_key,
    est_import,
    est_export,
    "",
    OBJ_0,
    OBJ_0
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    est_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
est_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    est_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
est_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    est_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
est_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}




/************************************************************************/
/*-    est_Invariants -- Sanity check on est.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
est_Invariants(
    FILE* errlog,
    char* title,
    Vm_Obj est
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, est );
#endif
    return errs;
}


/************************************************************************/
/*-    est_Get -- Get value of 'n'th slot in 'est'.			*/
/************************************************************************/

Vm_Obj
est_Get(
    Vm_Obj est,
    Vm_Unt n
) {
    Vm_Unt len;
    Est_P p  = EST_P((Vm_Int*)&len,est);

    if (n >= len) {   /* Using Vm_Unt saves us >= 0 check. */
	return OBJ_NOT_FOUND;
    }

    return p->slot[n];  
}



/************************************************************************/
/*-    est_Len -- Return number of slots in 'est'.			*/
/************************************************************************/

Vm_Int
est_Len(
    Vm_Obj	est
) {
    Vm_Int len;
    (void) EST_P((Vm_Int*)&len,est);
    return len;
}



/************************************************************************/
/*-    est_Set -- Set value of 'n'th slot in 'est' to 'val'.		*/
/************************************************************************/

void
est_Set(
    Vm_Obj est,
    Vm_Unt n,
    Vm_Obj val
) {
    Vm_Unt len;
    Est_P p = EST_P((Vm_Int*)&len,est);

    if (n >= len) {   /* Using Vm_Unt saves us >= 0 check. */
	MUQ_WARN ("Can't set slot %d in %d-slot struct", (int)n, (int)len );
    }

    p->slot[n] = val;
}



/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    est_sprintX -- Debug dump of est state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
est_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    #ifdef MUQ_VERBOSE
    return  lib_Sprint( buf, lim, "#<est %" VM_X ">", obj );
    #else
    {   Vm_Uch buf2[ 33 ];
	Vm_Int len;
	Vm_Obj key = EST_P(&len,obj)->is_a;
	Vm_Obj nam = KEY_P(key)->o.objname;
	if (!stg_Is_Stg(nam)) {
	    return  lib_Sprint( buf, lim, "#<ephemeral struct>" );
	}
	len = stg_Get_Bytes( buf2, 32, nam, 0 );
	buf2[len] = '\0';
	return  lib_Sprint( buf, lim, "#<an ephemeral %s>", buf2 );
    }
    #endif
}



/************************************************************************/
/*-    est_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
est_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    est_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
est_for_get(
    Vm_Obj obj,
    Vm_Obj sym,
    Vm_Int propdir
) {
    if (propdir == OBJ_PROP_SYSTEM) {
	Vm_Int len;
	/* Buggo, should deduce owner from stack layout. */
/*	if (sym == job_Kw_Owner)  return EST_P(obj)->owner; */
	if (sym == job_Kw_Is_A)   return EST_P(&len,obj)->is_a;
	return OBJ_NOT_FOUND;
    }
    if (propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;
    if (!OBJ_IS_SYMBOL(sym))          return OBJ_NOT_FOUND;

    {   Vm_Int len;
        Key_P k = KEY_P( EST_P(&len,obj)->is_a );
	Vm_Unt slots = OBJ_TO_UNT( k->total_slots );
	Key_Sym sa = (Key_Sym)(((Vm_Obj*)k) + OBJ_TO_INT(k->sym_loc));
	Vm_Unt u;
	for (u = 0;   u < slots;  ++u) {
	    if (sa[u].symbol == sym) {
#ifdef OLD
		return EST_P(&len,obj)->slot[u];
#else
		Vm_Obj val;
		if (!job_Read_Structure_Slot( &val, obj, u )) {
		    return OBJ_NOT_FOUND;
		}
		return val;
#endif
    }	}   }

    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    est_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
est_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    est_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
est_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_PUBLIC)   return NULL;
    if (!OBJ_IS_SYMBOL(key))          return NULL;

    {   Vm_Int len;
        Key_P k = KEY_P( EST_P(&len,obj)->is_a );
	Key_Sym sa = (Key_Sym)(((Vm_Obj*)k) + OBJ_TO_INT(k->sym_loc));
	Vm_Unt slots = OBJ_TO_UNT( k->total_slots );
	Vm_Unt u;
	for (u = 0;   u < slots;  ++u) {
	    if (sa[u].symbol == key) {
		if (!job_Write_Structure_Slot( obj, u, val )) {
		    return "You may not modify that structure slot";
		}
		return NULL;
    }	}   }

    return "No such property on this struct";
}

/************************************************************************/
/*-    est_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
est_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (propdir == OBJ_PROP_SYSTEM) {
	if (key == OBJ_FIRST)   return job_Kw_Is_A;
/*	if (key == job_Kw_Is_A) return job_Kw_Owner; */
	return OBJ_NOT_FOUND;
    }
    if (propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;
    if (key==OBJ_FIRST) {
	Vm_Int len;
        Key_P k = KEY_P( EST_P(&len,obj)->is_a );
	Key_Sym sa = (Key_Sym)(((Vm_Obj*)k) + OBJ_TO_INT(k->sym_loc));
	return sa[0].symbol;
    }
    if (!OBJ_IS_SYMBOL(key))          return OBJ_NOT_FOUND;

    {   Vm_Int len;
        Key_P k = KEY_P( EST_P(&len,obj)->is_a );
	Key_Sym sa = (Key_Sym)(((Vm_Obj*)k) + OBJ_TO_INT(k->sym_loc));
	Vm_Unt slots = OBJ_TO_UNT( k->total_slots );
	Vm_Unt u;
	for (u = 0;   u+1 < slots;  ++u) {
	    if (sa[u].symbol == key) {
		return sa[u+1].symbol;
    }	}   }

    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    get_mos_key -- Find key object for this structure		*/
/************************************************************************/

static Vm_Obj
get_mos_key(
    Vm_Obj obj
) {
    /* We deliberately do not call */
    /* job_Maybe_Update_Struct():  */
    /* expanding ephemerals would  */
    /* take some coding, and they  */
    /* presumably don't live long  */
    /* enough to justify it:       */

    Vm_Int len;
    return EST_P(&len,obj)->is_a;
}

/************************************************************************/
/*-    est_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj
est_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
#ifdef SOMEDAY
    /* Read old name of object: */
    Vm_Int m;
    Vm_Obj n;
    Vm_Obj o;
    if (2 != fscanf(fd, "%" VM_X ":%" VM_D, &o, &m )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("est_Import: bad input!\n");
    }    

    /* Make/find est to hold result: */
    n = (pass
	? obj_Import_Hashtab_Val( o )
	: est_alloc( m )
    );
    if (!pass)   obj_Import_Hashtab_Enter( n, o );

    /* Handle any ownership info: */
    if (have) {
	Vm_Obj own     = obj_Import_Any( fd, pass, have, read );
	if (pass && read) {
	    Vm_Int len;
	    EST_P(&len,n)->owner = own;
/* buggo, net1/net2 not dealt with. */
	    vm_Dirty(n);
    }   }

    /* Read items in object: */
    {   Vm_Int i;
	for (i = 0;   i < m;   ++i) {
	    Vm_Obj val = obj_Import_Any( fd, pass, have, read );
	    if (pass)   est_Set( n, i, val );
    }   }
    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    /* Read end-of-object: */
    if (fgetc(fd) != '\n') MUQ_FATAL ("est_Import: bad input!\n");

    ++obj_Export_Stats->objects_in_file;

    return n;
#else
    return OBJ_NIL;
#endif
}



/************************************************************************/
/*-    est_export -- Write object into textfile.			*/
/************************************************************************/

static void
est_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
#ifdef SOMEDAY
    Vm_Int len = est_Len(o);
    fprintf( fd, "V:%" VM_X ":%" VM_D "\n", o, len );
    {   Vm_Int len;
        Est_P  p = EST_P(&len,o);
	Vm_Int i;
	if (write_owners)  obj_Export_Subobj( fd, p->owner, write_owners );
	for (i = 0;   i < len;   ++i) {
	    obj_Export_Subobj(                fd, p->slot[i], write_owners );
    }	}
    fputc( '\n', fd );
#endif
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    char* t,
    Vm_Obj est
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
