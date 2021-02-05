@example  @c
/* CommonLisp Package functions:

export        { name -> } (If inherited and not present, is imported first.)
findPackage  { name -> package }
inPackage    Selects current package.
intern        { name package -> } Return possibly inherited/created symbol.
package-name  Returns name of package
package-nicknames { package -> [nicknames] }
package-use-list  Returns list of packages used by package.
package-used-by-list  Returns list of packages using package.
package-shadowing-symbols Returns list of declared shadowing symbols.
deletePackage
list-all-packages Yup.
rename-package    Changes package's name.
usePackage	  { name -> } Checks for aliasing.  Imports extern symbols.
import            { 'abc:def -> } (error if distinct 'def' is accessable)
do-symbols
do-external-symbols
do-all-symbols
with-package-iterator
makePackage
symbolPackage { symbol -> package }

"Dangerous":
unintern
unexport	{ name -> }
shadow
shadowing-import { 'abc:def -> } (NO error if distinct 'def' is accessable)
                 Any existing 'def' is first uninterned.
unusePackage

Package properties:
internal symbols
exported symbols
name
nicknames
shadowingSymbols: these silently win all name conflicts
usedPackages

Package notation
editor:buffer
editor::hidden-buffer
Symbols should be printed with qualifier if not interned in current pkg.


Standard packages:
keyword



 */



/************************************************************************/
/*--   pkg.c -- PacKage objects for Muq.				*/
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
/* Created:      94Feb13						*/
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

#if MUQ_DEBUG
static Vm_Int   invariants(FILE*,Vm_Uch*,Vm_Obj);
#endif

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_pkg( Vm_Unt );

static Vm_Obj	pkg_nicknames(	           Vm_Obj );
static Vm_Obj	pkg_shadowing_symbols(     Vm_Obj );
static Vm_Obj	pkg_used_packages(         Vm_Obj );
static Vm_Obj	pkg_set_nicknames(         Vm_Obj, Vm_Obj );
static Vm_Obj	pkg_set_shadowing_symbols( Vm_Obj, Vm_Obj );
static Vm_Obj	pkg_set_used_packages(     Vm_Obj, Vm_Obj );

Vm_Obj  pkg_X_Del( Vm_Obj, Vm_Obj, Vm_Int 	 );
Vm_Obj  pkg_X_Get( Vm_Obj, Vm_Obj, Vm_Int 	 );
Vm_Obj  pkg_X_Get_Asciz( Vm_Obj, Vm_Uch*, Vm_Int  );
Vm_Obj  pkg_X_Next( Vm_Obj, Vm_Obj, Vm_Int 	 );
Vm_Uch* pkg_X_Set( Vm_Obj, Vm_Obj, Vm_Obj, Vm_Int );

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property pkg_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"nicknames"	  , pkg_nicknames        , pkg_set_nicknames	    },
    {0,"shadowingSymbols", pkg_shadowing_symbols, pkg_set_shadowing_symbols},
    {0,"usedPackages"    , pkg_used_packages    , pkg_set_used_packages    },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class pkg_Hardcoded_Class = {
    OBJ_FROM_BYT3('p','k','g'),
    "Package",
    sizeof_pkg,
    for_new,
    pkg_X_Del,
    pkg_X_Get,
    pkg_X_Get_Asciz,
    pkg_X_Set,
    pkg_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { pkg_system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void pkg_doTypes(void){}
Obj_A_Module_Summary pkg_Module_Summary = {
   "pkg",
    pkg_doTypes,
    pkg_Startup,
    pkg_Linkup,
    pkg_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    pkg_Sprint  -- Debug dump of pkg state, multi-line format.	*/
/************************************************************************/

Vm_Uch* pkg_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  pkg
) {
#ifdef SOMETIME
    Pkg_P  s   = PKG_P(pkg);
    Vm_Int sp  = OBJ_TO_INT(s->sp);
    Vm_Int i;
    Vm_Int lo  = (s->fn == OBJ_FROM_INT(2))  ?  2  :  0;
    for (i = sp;   i >= lo;   --i) {
	Vm_Obj*  j = &s->stack[i];
	Vm_Obj   o = *j;
	buf  = lib_Sprint(buf,lim, "%d: ", i-lo );
	buf += job_Sprint_Vm_Obj( buf,lim, *j, /* quote_strings: */ TRUE );
	buf  = lib_Sprint(buf,lim, "\n" );
    }
#endif
    return buf;
}




/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    pkg_Startup -- start-of-world stuff.				*/
/************************************************************************/

void pkg_Startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    pkg_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void pkg_Linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    pkg_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void pkg_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}


#ifdef OLD

/************************************************************************/
/*-    pkg_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj pkg_Import(
    FILE* fd
) {
    MUQ_FATAL ("pkg_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    pkg_Export -- Write object into textfile.			*/
/************************************************************************/

void pkg_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("pkg_Export unimplemented");
}


#endif

/************************************************************************/
/*-    pkg_Invariants -- Sanity check on pkg.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
pkg_Invariants (
    FILE*   errlog,
    Vm_Uch* title,
    Vm_Obj  pkg
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, pkg );
#endif
    return errs;
}

/************************************************************************/
/*-    pkg_Knows_Symbol -- TRUE iff symbol is accessable in pkg.	*/
/************************************************************************/

Vm_Int
pkg_Knows_Symbol(
    Vm_Obj pkg,
    Vm_Obj sym
) {
    Vm_Obj s_pkg;
    Vm_Obj s_nam;
    {   Sym_P s = SYM_P(sym);
        s_pkg   = s->package;
        s_nam   = s->name;
    }

    /* Simplest case: Is symbol interned in pkg? */
    if (s_pkg == pkg)                  return TRUE;

    /* If symbol is actually present in package, */
    /* it is accessable:                         */
    if (sym_Find( pkg, s_nam ) == sym) return TRUE;

    /* If symbol is exported by any of the pkgs	 */
    /* used by our package, it is accessable;	 */
    {   Vm_Obj use = PKG_P( pkg )->used_packages;
	Vm_Obj key;
	if (!OBJ_IS_OBJ(use))   return FALSE;
	for(key=OBJ_NEXT(use,OBJ_FIRST,OBJ_PROP_PUBLIC);
	    key!=OBJ_NOT_FOUND;
	    key=OBJ_NEXT(use,key,OBJ_PROP_PUBLIC)) {

	    /* Find the key's value: */
	    Vm_Obj pkg = OBJ_GET( use, key, OBJ_PROP_PUBLIC );

	    /* We're only interested in packages: */
	    if (OBJ_IS_OBJ(      pkg)
	    &&  OBJ_IS_CLASS_PKG(pkg)
	    ){
	        if (sym == sym_Find_Exported( pkg, s_nam )) {
		    return TRUE;
    }   }   }   }

    return FALSE;
}


/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    pkg_X_Del -- Delete value for given 'key'.		       	*/
/************************************************************************/

Vm_Obj
pkg_X_Del(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    Vm_Int c = OBJ_CLASS(obj);

    /* Try to keep propdir blocks in same db as parent  */
    /* object.  A less clumsy and unreliable hack would */
    /* be a distinct improvement:                       */ 
    if (mod_Hardcoded_Class[c]->propdir[propdir] != NULL
    &&  OBJ_IS_SYMBOL(key)
    ){
	/* Ignore 'delete' if it is for a special-prop value: */
	Vm_Int i;
	for (i = 0;  mod_Hardcoded_Class[c]->propdir[propdir][i].name;  ++i) {
	    Obj_Special_Property p;
	    p = &mod_Hardcoded_Class[c]->propdir[propdir][i];
	    if (p->keyword == key) {
		Vm_Obj result = p->for_get( obj );
		return result;
    }   }   }

    /* If key is in propdir, remove it: */
    {   Vm_Obj v;
    
	Vm_Obj olddir = PKG_P(obj)->propdir[propdir];

	v          = job_Btree_Get( olddir, key );
	if (v != OBJ_NOT_FOUND) {
	    Vm_Obj newdir = job_Btree_Del( olddir, key );
	    if (newdir != olddir) {
		PKG_P(obj)->propdir[propdir] = newdir;
		vm_Dirty(obj);
	    }
	}
        return v;
    }

    /* Decidedly do not search our */
    /* parents and delete in them. */
}

/************************************************************************/
/*-    pkg_X_Get -- Get value for given 'key'.			       	*/
/************************************************************************/



Vm_Obj
pkg_X_Get(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    Vm_Int c = OBJ_CLASS(obj);

    if (mod_Hardcoded_Class[c]->propdir[propdir] != NULL
    &&  OBJ_IS_SYMBOL(key)
    ){

	/* Maybe return special-prop value: */
	Vm_Int i;
	for (i = 0;  mod_Hardcoded_Class[c]->propdir[propdir][i].name;  ++i) {
	    Obj_Special_Property p;
	    p = &mod_Hardcoded_Class[c]->propdir[propdir][i];
	    if (p->keyword == key) {
		Vm_Obj v = p->for_get( obj );
		if (v != OBJ_NOT_FOUND) {
		    return v;
		}
		break;
    }   }   }

    /* If key is in propdir, return that value: */
    {
	Vm_Obj dir    = PKG_P(obj)->propdir[propdir];

        Vm_Obj v      = job_Btree_Get( dir, key );

	if (v != OBJ_NOT_FOUND) {
	    return v;
	}
    }

    /* Failed to find value for key: */
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    pkg_X_Get_Asciz -- Get value for given 'key'.		       	*/
/************************************************************************/

Vm_Obj
pkg_X_Get_Asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    /************************************************************/
    /* If caller has read privs, then:				*/
    /*   If key is a system_prop, we maybe use that val.	*/
    /*   Else if key is in propdir, we use that val.		*/
    /* Else we fail.						*/
    /************************************************************/

    /* All hardwired properties are now keywords, */
    /* so pkg_X_Get_Asciz inherently doesn't have */
    /* to worry about hardwired properties.       */

    /* If key is in propdir, return that value: */
    {
	Vm_Obj dir    = PKG_P(obj)->propdir[propdir];

        Vm_Obj v      = job_Btree_Get_Asciz(dir,key);

	if    (v != OBJ_NOT_FOUND)   return v;
    }

    /* Failed to find value for key: */
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    pkg_X_Next -- Return next key in obj else OBJ_NOT_FOUND.      	*/
/************************************************************************/

Vm_Obj
pkg_X_Next(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Obj specialkey = 0;
    Vm_Obj regularkey = key;
    Vm_Int keytype    = OBJ_TYPE(key);
    Vm_Int c          = OBJ_CLASS(obj);

    /* See if there are special hardwired  */
    /* properties for this propdir on this */
    /* this class of object:               */

    /* Find next regular prop after 'key': */
    Vm_Obj dir    = PKG_P(obj)->propdir[propdir];

    regularkey        = job_Btree_Next( dir, regularkey );

    if (mod_Hardcoded_Class[c]->propdir[propdir] == NULL) {
	/*****************************************/
	/* No hardwired properties, just go with */
	/* whatever we actually find on the obj: */
	/*****************************************/
	return   regularkey;
    }

    /*************************************************/
    /* We have hardwired properties, need to return  */
    /* lesser of the next hardwired property and the */
    /* next normal property, where either or both    */
    /* may be absent:                                */
    /*************************************************/

    /* Find next special prop after 'key': */
    if (!OBJ_IS_SYMBOL(key)) {
	if (keytype < OBJ_TYPE_SYMBOL) {
	    specialkey = mod_Hardcoded_Class[c]->propdir[propdir][0].keyword;
	}
    } else {
	Vm_Int i;
	Vm_Obj t;

	for (i=0; t=mod_Hardcoded_Class[c]->propdir[propdir][i].keyword; ++i) {
	    if (obj_Neql( t , key) > 0) {
		specialkey = t;
		break;
       	    }
       	}
    }


    /* Return earliest of specialkey and regularkey: */
    if (specialkey != 0
    &&  regularkey != OBJ_NOT_FOUND
    ){
        if (obj_Neql( specialkey , regularkey) < 0) {
	    return specialkey;
	} else {
	    return regularkey;
	}
    } else {
	if (specialkey != 0)   return   specialkey;
	else                   return   regularkey  ;
    }
}

/************************************************************************/
/*-    pkg_X_Set -- Set 'key' to 'val' in 'obj'.			*/
/************************************************************************/

Vm_Uch*
pkg_X_Set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    /* Check hardcoded props: */
    Vm_Int c = OBJ_CLASS(obj);
    Vm_Int i;

    /* Try to keep propdir blocks in same db as parent  */
    /* object.  A less clumsy and unreliable hack would */
    /* be a distinct improvement:                       */ 

    if (mod_Hardcoded_Class[c]->propdir[propdir] != NULL
    &&  OBJ_IS_SYMBOL(key)
    ){
	/* buggo... should at least do binary search someday: */
	for (i = 0;  mod_Hardcoded_Class[c]->propdir[propdir][i].name;  ++i) {
	    Obj_Special_Property p;
	    p = &mod_Hardcoded_Class[c]->propdir[propdir][i];
	    if (p->keyword == key) {
		Vm_Obj v  = p->for_set( obj, val );
		if (   v != OBJ_NOT_FOUND) {
		     return NULL;
		}
		break;
    }   }   }

    {   /* Don't combine these lines, side-effect sequencing matters: */
        Vm_Obj olddir = PKG_P(obj)->propdir[propdir];

	Vm_Obj newdir = job_Btree_Set( olddir, key, val, VM_DBFILE(obj) );
        if (   newdir != olddir) {
	    PKG_P(obj)->propdir[propdir] = newdir;
	    vm_Dirty(obj);
        }
    }

    /* Buggo... should do this at actual change point: */
    vm_Dirty(obj);
    return NULL;
}



/************************************************************************/
/*-    pkg_nicknames							*/
/************************************************************************/

static Vm_Obj
pkg_nicknames(
    Vm_Obj o
) {
    return PKG_P(o)->nicknames;
}



/************************************************************************/
/*-    pkg_shadowing_symbols						*/
/************************************************************************/

static Vm_Obj
pkg_shadowing_symbols(
    Vm_Obj o
) {
    return PKG_P(o)->shadowing_symbols;
}



/************************************************************************/
/*-    pkg_used_packages						*/
/************************************************************************/

static Vm_Obj
pkg_used_packages(
    Vm_Obj o
) {
    return PKG_P(o)->used_packages;
}



/************************************************************************/
/*-    pkg_set_nicknames						*/
/************************************************************************/

static Vm_Obj pkg_set_nicknames(
    Vm_Obj o,
    Vm_Obj v
) {
    PKG_P(o)->nicknames = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    pkg_set_shadowing_symbols					*/
/************************************************************************/

static Vm_Obj pkg_set_shadowing_symbols(
    Vm_Obj o,
    Vm_Obj v
) {
    PKG_P(o)->shadowing_symbols = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    pkg_set_used_packages						*/
/************************************************************************/

static Vm_Obj pkg_set_used_packages(
    Vm_Obj o,
    Vm_Obj v
) {
    PKG_P(o)->used_packages = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}




/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new pkg object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Vm_Obj orig_package      = jS.job ? JOB_P(jS.job)->package : OBJ_0;
    Vm_Unt dbfile            = VM_DBFILE( o );
    Vm_Obj nicknames         = obj_Alloc_In_Dbfile(OBJ_CLASS_A_OBJ,0,dbfile);
    Vm_Obj used_packages     = obj_Alloc_In_Dbfile(OBJ_CLASS_A_OBJ,0,dbfile);
    Vm_Obj shadowing_symbols = obj_Alloc_In_Dbfile(OBJ_CLASS_A_OBJ,0,dbfile);
    if (jS.job) {
      JOB_P(jS.job)->package = o;  /* So below strings are in same dbfile. */
    }
    {   Pkg_P p              = PKG_P(o);
	p->nicknames         = nicknames;
	p->used_packages     = used_packages;
	p->shadowing_symbols = shadowing_symbols;
	{   int i;
	    for (i = PKG_RESERVED_SLOTS;  i --> 0; ) {
                p->reserved_slot[i] = OBJ_FROM_INT(0);
            }
	    for (i = OBJ_PROP_MAX;  i --> 0; ) {
                p->propdir[i] = sil_Alloc();
            }
	}
	vm_Dirty(o);
    }
    {   Vm_Obj name = stg_From_Asciz("nicknames");
	OBJ_P(nicknames        )->objname = name; vm_Dirty(nicknames        );
    }
    {   Vm_Obj name = stg_From_Asciz("used_packages");
	OBJ_P(used_packages    )->objname = name; vm_Dirty(used_packages    );
    }
    {   Vm_Obj name = stg_From_Asciz("shadowing_symbols");
	OBJ_P(shadowing_symbols)->objname = name; vm_Dirty(shadowing_symbols);
    }
    if (jS.job)   JOB_P(jS.job)->package  = orig_package; 
}



/************************************************************************/
/*-    sizeof_pkg -- Return size of package.				*/
/************************************************************************/

static Vm_Unt
sizeof_pkg(
    Vm_Unt size
) {
    return sizeof( Pkg_A_Header );
}





/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int invariants(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj  pkg
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif




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
