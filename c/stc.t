@example  @c

/*--   stc.c -- STruCture support for Muq.				*/
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

static Vm_Uch* stc_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  stc_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  stc_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  stc_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* stc_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  stc_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  stc_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void    stc_export(  FILE*, Vm_Obj, Vm_Int );

static Vm_Obj  get_mos_key( Vm_Obj );



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void stc_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_STRUCT ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_STRUCT");
    }
    mod_Type_Summary[ OBJ_TYPE_STRUCT ] = &stc_Type_Summary;
}
Obj_A_Module_Summary stc_Module_Summary = {
   "stc",
    stc_doTypes,
    stc_Startup,
    stc_Linkup,
    stc_Shutdown
};

Obj_A_Type_Summary stc_Type_Summary = {    OBJ_FROM_BYT1('C'),
    stc_sprintX,
    stc_sprintX,
    stc_sprintX,
    stc_for_del,
    stc_for_get,
    stc_g_asciz,
    stc_for_set,
    stc_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    get_mos_key,
    stc_import,
    stc_export,
    "",
    OBJ_0,
    OBJ_0
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    stc_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
stc_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    stc_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
stc_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    stc_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
stc_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}




/************************************************************************/
/*-    stc_Invariants -- Sanity check on stc.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
stc_Invariants(
    FILE* errlog,
    char* title,
    Vm_Obj stc
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, stc );
#endif
    return errs;
}




/************************************************************************/
/*-    stc_Alloc -- Return a new 'n'-slot struct.			*/
/************************************************************************/

 /***********************************************************************/
 /*-   stc_alloc -- Return a new 'n'-slot struct.			*/
 /***********************************************************************/

static Vm_Obj
stc_alloc(
    Vm_Unt slots
) {
    Vm_Obj pkg = JOB_P(jS.job)->package;
    Vm_Int siz = sizeof(Stc_A_Header) + (slots-1) * sizeof(Vm_Obj);
    Vm_Obj o   = vm_Malloc( siz, VM_DBFILE(pkg), OBJ_K_STRUCT );
    job_RunState.bytes_owned += siz;
    return o;
}

 /***********************************************************************/
 /*-   stc_Alloc -- Return a new 'n'-slot struct.			*/
 /***********************************************************************/

Vm_Obj
stc_Alloc(
    Vm_Obj key
) {
    Vm_Unt slots;
    Vm_Obj ini[ KEY_MAX_SLOTS ];

    {   Key_P  k = KEY_P(key);
	Vm_Unt u;
	slots    = OBJ_TO_UNT( k->unshared_slots );
	for (u = 0;   u < slots;   ++u)   ini[u] = k->slot[u].initval;
    }
    {   Vm_Obj o   = stc_alloc( slots );
        Stc_P  p = STC_P( o );
	Vm_Unt u;

	p->is_a  = key;

	for (u = 0;   u < slots;   ++u)   p->slot[u] = ini[u];
	vm_Dirty(o);

	return o;
    }
}



/************************************************************************/
/*-    stc_Dup -- Return exact duplicate of 'o'.			*/
/************************************************************************/

Vm_Obj
stc_Dup(
    Vm_Obj old
) {
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
/* buggo, no slot read priv enforcement. */
    Vm_Int len = vm_Len( old );
    /* Buggo? Are we leaking private data from original */
    /* to copying user here? */
    Vm_Obj new = vm_SizedDup( old, len, VM_DBFILE(pkg) );
    if (len) {
	jS.bytes_owned    += len;
    }

    return new;
}



/************************************************************************/
/*-    stc_Dup_Est -- Return exact duplicate of Ephemeral STruct 'o'.	*/
/************************************************************************/

Vm_Obj
stc_Dup_Est(
    Vm_Obj o
) {
    Vm_Int i;
    Vm_Int len;
    Est_P  p   = EST_P(&len,o);
    Vm_Obj stc = stc_alloc(len);
    Stc_P  s   = STC_P(stc);
    p          = EST_P(&len,o);
    s->is_a    = p->is_a;
    for (i = 0;   i < len;   ++i) {
/* buggo, no slot read priv enforcement. */
	s->slot[i] = p->slot[i];
    }
    vm_Dirty(stc);
    return stc;
}



/************************************************************************/
/*-    stc_Get -- Get value of 'n'th slot in 'stc'.			*/
/************************************************************************/

#ifdef UNUSED
Vm_Obj
stc_Get(
    Vm_Obj stc,
    Vm_Unt slot
) {
    Vm_Obj val;
    Vm_Unt slots = stc_Len( stc );
/* buggo: This fn appears to be never referenced. */
/* Do we have a lot of these? Ditto stc_Set(). */
    if (slot >= slots) {   /* Using Vm_Unt saves us >= 0 check. */
	return OBJ_NOT_FOUND;
    }
    if (job_Read_Structure_Slot( &val, stc, slot )) {
	return val;
    }
    return OBJ_NOT_FOUND;
}
#endif



/************************************************************************/
/*-    stc_Len -- Return number of slots in 'stc'.			*/
/************************************************************************/

Vm_Int
stc_Len(
    Vm_Obj	stc
) {
    return (
        (   vm_Len(stc)   -   (sizeof(Stc_A_Header) - sizeof(Vm_Obj))   )
        /
        sizeof(Vm_Obj)
    );
}



/************************************************************************/
/*-    stc_Set -- Set value of 'n'th slot in 'stc' to 'val'.		*/
/************************************************************************/

void
stc_Set(
    Vm_Obj stc,
    Vm_Unt slot,
    Vm_Obj val
) {
    if (!job_Write_Structure_Slot( stc, slot, val )) {
	MUQ_WARN ("You may not modify that struct slot");
    }
}



/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    stc_sprintX -- Debug dump of stc state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
stc_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    #ifdef MUQ_VERBOSE
    return  lib_Sprint( buf, lim, "#<struct %x>", obj );
    #else
    {   Vm_Uch buf2[ 33 ];
	Vm_Obj key = STC_P(obj)->is_a;
	Vm_Obj nam = KEY_P(key)->o.objname;
	Vm_Int len;
	if (!stg_Is_Stg(nam)) {
	    return  lib_Sprint( buf, lim, "#<struct>" );
	}
	len = stg_Get_Bytes( buf2, 32, nam, 0 );
	buf2[len] = '\0';
#ifdef PRODUCTION
	return  lib_Sprint( buf, lim, "#<a %s>", buf2 );
#else
	return  lib_Sprint( buf, lim, "#<a %s %" VM_X ">", buf2, obj );
#endif
    }
    #endif
}



/************************************************************************/
/*-    stc_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
stc_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    stc_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
stc_for_get(
    Vm_Obj obj,
    Vm_Obj sym,
    Vm_Int propdir
) {
    if (propdir == OBJ_PROP_SYSTEM) {
	if (sym == job_Kw_Owner)  return obj_Owner(obj);
	if (sym == job_Kw_Is_A)   return STC_P(obj)->is_a;
	if (sym == job_Kw_Dbname) return obj_Dbname(obj);
	return OBJ_NOT_FOUND;
    }
    if (propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;
    if (!OBJ_IS_SYMBOL(sym))          return OBJ_NOT_FOUND;

    {   Key_P k = KEY_P( STC_P(obj)->is_a );
	Key_Sym sa = (Key_Sym)(((Vm_Obj*)k) + OBJ_TO_INT(k->sym_loc));
	Vm_Unt slots = OBJ_TO_UNT( k->total_slots );
	Vm_Unt u;
	for (u = 0;   u < slots;  ++u) {
	    if (sa[u].symbol == sym) {
		Vm_Obj val;
		if (!job_Read_Structure_Slot( &val, obj, u )) {
		    return OBJ_NOT_FOUND;
		}
		return val;
    }	}   }

    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    stc_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
stc_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    stc_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
stc_for_set(
    Vm_Obj obj,
    Vm_Obj sym,
    Vm_Obj val,
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_PUBLIC)   return NULL;
    if (!OBJ_IS_SYMBOL(sym))          return NULL;

    {   Key_P k = KEY_P( STC_P(obj)->is_a );
	Key_Sym sa = (Key_Sym)(((Vm_Obj*)k) + OBJ_TO_INT(k->sym_loc));
	Vm_Unt slots = OBJ_TO_UNT( k->total_slots );
	Vm_Unt u;
	for (u = 0;   u < slots;  ++u) {
	    if (sa[u].symbol == sym) {
		if (!job_Write_Structure_Slot( obj, u, val )) {
		    return "You may not modify that structure slot";
		}
		return NULL;
    }	}   }

    return "No such property on this struct";
}


/************************************************************************/
/*-    stc_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
stc_for_nxt(
    Vm_Obj obj,
    Vm_Obj sym,
    Vm_Int propdir
) {
    if (propdir == OBJ_PROP_SYSTEM) {
	if (sym == OBJ_FIRST)   return job_Kw_Is_A;
	if (sym == job_Kw_Is_A) return job_Kw_Owner;
	return OBJ_NOT_FOUND;
    }
    if (propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;
    if (sym==OBJ_FIRST) {
	Key_P k = KEY_P( STC_P(obj)->is_a );
	Key_Sym sa = (Key_Sym)(((Vm_Obj*)k) + OBJ_TO_INT(k->sym_loc));
	return sa[0].symbol;
    }
    if (!OBJ_IS_SYMBOL(sym))          return OBJ_NOT_FOUND;

    {   Key_P k = KEY_P( STC_P(obj)->is_a );
	Key_Sym sa = (Key_Sym)(((Vm_Obj*)k) + OBJ_TO_INT(k->sym_loc));
	Vm_Unt slots = OBJ_TO_UNT( k->total_slots );
	Vm_Unt u;
	for (u = 0;   u+1 < slots;  ++u) {
	    if (sa[u].symbol == sym) {
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
    obj = job_Maybe_Update_Struct( obj );
    return STC_P(obj)->is_a;
}

/************************************************************************/
/*-    stc_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj
stc_import(
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
	MUQ_FATAL ("stc_Import: bad input!\n");
    }    

    /* Make/find stc to hold result: */
    n = (pass
	? obj_Import_Hashtab_Val( o )
	: stc_alloc( m )
    );
    if (!pass)   obj_Import_Hashtab_Enter( n, o );

    /* Handle any ownership info: */
    if (have) {
	obj_Import_Any( fd, pass, have, read );
	if (pass && read) {
/* buggo, net1/net2 not dealt with. */
	    vm_Dirty(n);
    }   }

    /* Read items in object: */
    {   Vm_Int i;
	for (i = 0;   i < m;   ++i) {
	    Vm_Obj val = obj_Import_Any( fd, pass, have, read );
	    if (pass)   stc_Set( n, i, val );
    }   }
    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    /* Read end-of-object: */
    if (fgetc(fd) != '\n') MUQ_FATAL ("stc_Import: bad input!\n");

    ++obj_Export_Stats->objects_in_file;

    return n;
}



/************************************************************************/
/*-    stc_export -- Write object into textfile.			*/
/************************************************************************/

static void
stc_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
    Vm_Int len = stc_Len(o);
    fprintf( fd, "V:%" VM_X ":%" VM_D "\n", o, len );
    {   Stc_P  p = STC_P(o);
	Vm_Int i;
	for (i = 0;   i < len;   ++i) {
	    obj_Export_Subobj(                fd, p->slot[i], write_owners );
    }	}
    fputc( '\n', fd );
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    char* t,
    Vm_Obj stc
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
