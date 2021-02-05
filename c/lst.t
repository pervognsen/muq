@example  @c
/*--   lst.c -- LiSTs for Muq -- cons cell stuff.			*/
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
/* Created:      94Feb14						*/
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

static Vm_Uch* lst_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  lst_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  lst_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  lst_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* lst_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  lst_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  lst_import( FILE*, Vm_Int, Vm_Int, Vm_Int );
static void    lst_export( FILE*, Vm_Obj, Vm_Int );

static Vm_Obj  get_mos_key( Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void lst_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_CONS ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_CONS");
    }
    mod_Type_Summary[ OBJ_TYPE_CONS ] = &lst_Type_Summary;
}
Obj_A_Module_Summary lst_Module_Summary = {
   "lst",
    lst_doTypes,
    lst_Startup,
    lst_Linkup,
    lst_Shutdown
};

Obj_A_Type_Summary lst_Type_Summary = {    OBJ_FROM_BYT1('L'),
    lst_sprintX,
    lst_sprintX,
    lst_sprintX,
    lst_for_del,
    lst_for_get,
    lst_g_asciz,
    lst_for_set,
    lst_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    get_mos_key,
    lst_import,
    lst_export,
    "Cons",
    KEY_LAYOUT_CONS,
    OBJ_0
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    lst_Alloc -- Allocate a new CONS cell.				*/
/************************************************************************/

Vm_Obj lst_Alloc(
    Vm_Obj car,
    Vm_Obj cdr
) {
    Vm_Obj pkg = JOB_P(jS.job)->package;
    Vm_Obj x = vm_Malloc( sizeof(Lst_A_Header), VM_DBFILE(pkg), OBJ_K_CONS );
    {   Lst_P  p = LST_P(x);
	p->car   = car;
	p->cdr   = cdr;
	vm_Dirty(x);
    }

    job_RunState.bytes_owned += sizeof ( Lst_A_Header );

    return   x;
}




/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/



/************************************************************************/
/*-    lst_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
lst_Startup(
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    lst_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
lst_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    lst_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
lst_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}





/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    lst_sprintX -- Debug dump of vec state, multi-line format.	*/
/************************************************************************/

static Vm_Uch* lst_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    #ifdef MUQ_VERBOSE
    return  lib_Sprint( buf, lim, "#<cons %" VM_X ">", obj );
    #else
    return  lib_Sprint( buf, lim, "#<cons>" );
    #endif
}



/************************************************************************/
/*-    lst_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
lst_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    lst_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
lst_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (key == job_Kw_Car)    return LST_P(obj)->car;
    if (key == job_Kw_Cdr)    return LST_P(obj)->cdr;
    if (key == job_Kw_Dbname) return obj_Dbname(obj);
    if (key == job_Kw_Owner)  return obj_Owner(obj);
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    lst_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj lst_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    lst_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
lst_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    if (propdir == OBJ_PROP_PUBLIC) {
        if (key==job_Kw_Car) {LST_P(obj)->car=val; vm_Dirty(obj); return NULL;}
        if (key==job_Kw_Cdr) {LST_P(obj)->cdr=val; vm_Dirty(obj); return NULL;}
    }
    return   "Can't set that property on a list cell.";
}



/************************************************************************/
/*-    lst_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
lst_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_PUBLIC)  return OBJ_NOT_FOUND;
    if (0 < obj_Neql( job_Kw_Car, key ))   return job_Kw_Car;
    if (0 < obj_Neql( job_Kw_Cdr, key ))   return job_Kw_Cdr;
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    get_mos_key -- Find key object for this structure		*/
/************************************************************************/

static Vm_Obj
get_mos_key(
    Vm_Obj obj
) {
    Vm_Obj cdf = lst_Type_Summary.builtin_class;
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
/*-    lst_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj
lst_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    /* Read old name of object: */
    Vm_Obj n;
    Vm_Obj o;
    if (1 != fscanf(fd, "%" VM_X, &o )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("lst_import: bad input");
    }
    
    /* Make/find cons cell to hold result: */
    n = (pass
	? obj_Import_Hashtab_Val( o )
	: lst_Alloc( OBJ_NIL, OBJ_NIL )
    );
    if (!pass)   obj_Import_Hashtab_Enter( n, o );

    /* Read items in object: */
    {
        Vm_Obj car =        obj_Import_Any( fd, pass, have, read );
	Vm_Obj cdr =        obj_Import_Any( fd, pass, have, read );
	Lst_P  p           = LST_P(n);
	p->car	           = car;
	p->cdr             = cdr;
	vm_Dirty(n);
    }
    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    /* Read end-of-object: */
    if (fgetc(fd) != '\n') MUQ_FATAL ("lst_Import: bad input!\n");

    ++obj_Export_Stats->objects_in_file;

    return n;
}



/************************************************************************/
/*-    lst_export -- Write object into textfile.			*/
/************************************************************************/

static void
lst_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
    fprintf( fd, "L:%" VM_X "\n", o );
    {   Lst_P p = LST_P(o);
	obj_Export_Subobj(                    fd, p->car  , write_owners );
	obj_Export_Subobj(                    fd, p->cdr  , write_owners );
	fputc( '\n', fd );
    }
}




/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/




/************************************************************************/
/*-    --- Static propfns --						*/
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
