@example  @c
/* buggo: need to change 'nth' to just plain 'get' on an */
/* integer key. */


/*--   i32.c -- vectors of 32-bit integers for Muq.			*/
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
/* Created:      99Aug22						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 2000, by Jeff Prothero.				*/
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
/* Please send bug reports/fixes etc to bugs@muq.org.			*/
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

static Vm_Uch* i32_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  i32_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  i32_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  i32_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* i32_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  i32_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  i32_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void    i32_export(  FILE*, Vm_Obj, Vm_Int );
static Vm_Obj  get_mos_key( Vm_Obj );



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void i32_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_I32 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_I32");
    }
    mod_Type_Summary[ OBJ_TYPE_I32 ] = &i32_Type_Summary;
}
Obj_A_Module_Summary i32_Module_Summary = {
   "i32",
    i32_doTypes,
    i32_Startup,
    i32_Linkup,
    i32_Shutdown
};

Obj_A_Type_Summary i32_Type_Summary = {    OBJ_FROM_BYT1('V'),
    i32_sprintX,
    i32_sprintX,
    i32_sprintX,
    i32_for_del,
    i32_for_get,
    i32_g_asciz,
    i32_for_set,
    i32_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_32bit_Obj,
    get_mos_key,
    i32_import,
    i32_export,
    "VectorI32",
    KEY_LAYOUT_VECTOR_I32,
    OBJ_0
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    i32_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
i32_Startup(
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    i32_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
i32_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    i32_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
i32_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}




/************************************************************************/
/*-    i32_Invariants -- Sanity check on i32.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
i32_Invariants(
    FILE* errlog,
    char* title,
    Vm_Obj i32
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, i32 );
#endif
    return errs;
}




/************************************************************************/
/*-    i32_Alloc -- Return a new 'n'-slot i32tor.			*/
/************************************************************************/

Vm_Obj
i32_Alloc(
    Vm_Unt n,
    Vm_Obj a
) {
    /* jS.job is FALSE only briefly during initial bootstrap: */
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    Vm_Int siz = sizeof(I32_A_Header) + (n-1) * sizeof(Vm_Int32);
    Vm_Obj o = vm_Malloc( siz, VM_DBFILE(pkg), OBJ_K_I32 );

    /* Initializing the vector is presumably wasted effort  */
    /* most of the time, but makes debugging more pleasant: */
    Vm_Int32 v = OBJ_TO_UNT(a);
    I32_P    p = I32_P( o );
    Vm_Unt u;
    for   (u = n;   u --> 0;   ) {
	p->slot[u] = v;
    }
    vm_Dirty(o);

    job_RunState.bytes_owned += siz;

    return o;
}



/************************************************************************/
/*-    i32_Dup -- Return exact duplicate of 'v'.			*/
/************************************************************************/

Vm_Obj
i32_Dup(
    Vm_Obj o
) {
    return obj_Dup(o);
}



/************************************************************************/
/*-    i32_Get_Key_P -- Return 0/1 and loc of 'obj' in 'i32'.		*/
/************************************************************************/

Vm_Int
i32_Get_Key_P(
    Vm_Int*	loc,
    Vm_Obj	i32,
    Vm_Obj	obj
) {
    /* Search in sp-to-0 order, to get most recent val first:	*/
    
    if (!OBJ_IS_INT(obj)) {
	return FALSE;
    } else {
	Vm_Int32 i = OBJ_TO_INT(obj);
	I32_P  p = I32_P( i32 );
	Vm_Int u;
	for   (u = i32_Len(i32);   u --> 0;   ) {
	    if (p->slot[u] == i) { *loc = u; return TRUE; }
	}
	return FALSE;    
    }
}



/************************************************************************/
/*-    i32_Get_Key_P_Asciz -- Return 0/1 and loc of 'str' in 'i32'.	*/
/************************************************************************/

Vm_Int
i32_Get_Key_P_Asciz(
    Vm_Int*	loc,
    Vm_Obj	i32,
    Vm_Uch*	str
) {
    return FALSE;    
}



/************************************************************************/
/*-    i32_Get -- Get value of 'n'th slot in 'i32'.			*/
/************************************************************************/

Vm_Obj
i32_Get(
    Vm_Obj i32,
    Vm_Unt n
) {
    I32_P p    = I32_P(i32);
    Vm_Unt len = i32_Len( i32 );

    if (n >= len) {   /* Using Vm_Unt saves us >= 0 check. */
	/* Allow negative indexing also: */
	Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	if (m >= len)   return OBJ_NOT_FOUND;
	n = m;
    }

    return OBJ_FROM_UNT( p->slot[n] );
}



/************************************************************************/
/*-    i32_Len -- Return number of slots in 'i32'.			*/
/************************************************************************/

Vm_Int
i32_Len(
    Vm_Obj	i32
) {
    return (
        (   vm_Len(i32)   -   (sizeof(I32_A_Header) - sizeof(Vm_Int32))   )
        /
        sizeof(Vm_Int32)
    );
}



/************************************************************************/
/*-    i32_Push_Obj -- Push 'val' on 'i32'.				*/
/************************************************************************/

Vm_Obj
i32_Push_Obj(
    Vm_Obj old,
    Vm_Obj val
) {
    Vm_Obj len     = i32_Len(old);
    Vm_Obj new     = i32_SizedDup( old, len+1 );
    i32_Set( new, len, val );
    return new;
}



/************************************************************************/
/*-    i32_Set -- Set value of 'n'th slot in 'i32' to 'val'.		*/
/************************************************************************/

void
i32_Set(
    Vm_Obj i32,
    Vm_Unt n,
    Vm_Obj val
) {
    Vm_Unt len = i32_Len( i32 );
    I32_P  p   = I32_P(   i32 );

    if (!OBJ_IS_INT(val)) MUQ_WARN("May only store integers in vectorI32 objects");

    if (n >= len) {   /* Using Vm_Unt saves us >= 0 check. */
	/* Allow negative indexing also: */
	Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	if (m >= len)  MUQ_WARN ("Can't set slot %d in %d-slot i32", (int)n, (int)len );
	n = m;
    }

    p->slot[n] = OBJ_TO_INT(val);
    vm_Dirty(i32);
}



/************************************************************************/
/*-    i32_SizedDup -- Return resized copy 'old' with 'newslots'.	*/
/************************************************************************/

Vm_Obj
i32_SizedDup(
    Vm_Obj old,
    Vm_Unt newslots
) {
    Vm_Obj new = obj_SizedDup(
        old,
        sizeof(I32_A_Header)   +   (newslots-1) * sizeof(Vm_Int32)
    );
    Vm_Int old_len = vm_Len( old );
    Vm_Int new_len = vm_Len( new );
    if (new_len > old_len) {
	/* Zero out new bytes,  not least to */
	/* keep garbage collector from going */
	/* bananas over uninitialized slots: */
	Vm_Uch* p = vm_Loc(new);
	bzero( p+old_len, new_len-old_len );
    }
    return new;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    i32_sprintX -- Debug dump of i32 state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
i32_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    #ifdef MUQ_VERBOSE
    return  lib_Sprint( buf, lim, "#<i32 %" VM_X ">", obj );
    #else
    return  lib_Sprint( buf, lim, "#<i32>" );
    #endif
}



/************************************************************************/
/*-    i32_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
i32_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    i32_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
i32_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (!OBJ_IS_INT(key))   return OBJ_NOT_FOUND;
    return i32_Get( obj, (Vm_Unt)OBJ_TO_INT(key) );
}



/************************************************************************/
/*-    i32_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
i32_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    i32_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
i32_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    if (!OBJ_IS_INT(key)) {
	return   "May not 'set' non-integer properties on 32-bit vectors.";
    }
    i32_Set( obj, OBJ_TO_UNT(key), val );
    return NULL;
}



/************************************************************************/
/*-    i32_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
i32_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Int len = i32_Len( obj );
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
    Vm_Obj cdf = i32_Type_Summary.builtin_class;
    Vm_Obj key;

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(cdf) || !OBJ_IS_CLASS_CDF(cdf)) {
	MUQ_WARN("lst:get_mos_key internal err0");
    }
    #endif

    key = CDF_P(cdf)->key;

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(key) || !OBJ_IS_CLASS_KEY(key)) {
	MUQ_WARN("lst:get_mos_key internal err1");
    }
    #endif

    return key;
}

/************************************************************************/
/*-    i32_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj
i32_import(
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
	MUQ_FATAL ("i32_Import: bad input!\n");
    }    

    /* Make/find i32 to hold result: */
    n = (pass
	? obj_Import_Hashtab_Val( o )
	: i32_Alloc( m, OBJ_FROM_INT(0) )
    );
    if (!pass)   obj_Import_Hashtab_Enter( n, o );

    /* Handle any ownership info: */
    if (have) {
	if (pass && read) {
/* buggo, net1/net2 not dealt with. */
	    vm_Dirty(n);
    }   }

    /* Read items in object: */
    {   Vm_Int i;
	for (i = 0;   i < m;   ++i) {
	    Vm_Obj val = obj_Import_Any( fd, pass, have, read );
	    if (pass)   i32_Set( n, i, val );
    }   }
    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    /* Read end-of-object: */
    if (fgetc(fd) != '\n') MUQ_FATAL ("i32_Import: bad input!\n");

    ++obj_Export_Stats->objects_in_file;

    return n;
}



/************************************************************************/
/*-    i32_export -- Write object into textfile.			*/
/************************************************************************/

static void
i32_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
    Vm_Int len = i32_Len(o);
    fprintf( fd, "V:%" VM_X ":%" VM_D "\n", o, len );
    {   I32_P  p = I32_P(o);
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
    Vm_Obj i32
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
