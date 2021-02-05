@example  @c
/*--   sym.c -- SYMbols for Muq.					*/
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
/* Kuranes says, "We're doing some weird stuff, interestingly enough	*/
/* we're not using Muq as a MUD, really."				*/
/*   -- 94Sep08:12:29 (first present-tense reference to using Muq).	*/     
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

static Vm_Uch* sym_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  sym_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  sym_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  sym_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* sym_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  sym_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  sym_import(   FILE*, Vm_Int , Vm_Int, Vm_Int );
static void    sym_export(   FILE*, Vm_Obj , Vm_Int );

static Vm_Obj  get_mos_key( Vm_Obj );
static void    sym_prop_table_init( void );

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void sym_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_SYMBOL ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_SYMBOL");
    }
    mod_Type_Summary[ OBJ_TYPE_SYMBOL ] = &sym_Type_Summary;
}
Obj_A_Module_Summary sym_Module_Summary = {
   "sym",
    sym_doTypes,
    sym_Startup,
    sym_Linkup,
    sym_Shutdown
};

Obj_A_Type_Summary sym_Type_Summary = {    OBJ_FROM_BYT1('S'),
    sym_sprintX,
    sym_sprintX,
    sym_sprintX,
    sym_for_del,
    sym_for_get,
    sym_g_asciz,
    sym_for_set,
    sym_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    get_mos_key,
    sym_import,
    sym_export,
    /* 98Mar08CrT: Changing next to "Symbol" results in an eventual           */
    /* coredump with bad dbref on last test in x-mos.  I've no clue why and   */
    /* don't want to spend more than the halfday I already have on it, so I'm */
    /* leaving it "symbol" for now (buggo?).  See also "integer" in int.t --  */
    /* this appears to be the only other such case.                           */
    "symbol",
    
    OBJ_0
};

/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    sym_Make -- Create an uninterned symbol.				*/
/************************************************************************/

Vm_Obj
sym_Make(
    void
) {
    /* jS.job is FALSE only briefly during initial bootstrap: */
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    Vm_Obj new	= vm_Malloc( sizeof(Sym_A_Header), VM_DBFILE(pkg), OBJ_K_SYMBOL );
    Sym_P  s    = SYM_P(new);
    s->name	= OBJ_NIL;
    s->value	= OBJ_FROM_BOTTOM(0);
    s->function	= OBJ_NIL;
    s->package	= pkg;
    vm_Dirty(new);
    sym_Set_Type(    new,OBJ_NIL);
    sym_Set_Proplist(new,OBJ_NIL);
    

    job_RunState.bytes_owned += sizeof(Sym_A_Header);

    return new;
}

/************************************************************************/
/*-    sym_Alloc -- Find/create a symbol.				*/
/************************************************************************/

Vm_Obj
sym_Alloc(
    Vm_Obj name,
    Vm_Obj dflt  /* obj_Lib_Muf, obj_Lib_Lisp or 0 */
) {
    /* NOTE:  If you change the sequence of packages */
    /* searched by this fn, please also update       */
    /* muf.t:is_user_global() and sym_Alloc_Asciz(). */

    /* Find current package: */
    Vm_Obj pkg = JOB_P(jS.job)->package;

    /* Find value of stg in pkg: */
    Vm_Obj sym = OBJ_GET( pkg, name, OBJ_PROP_HIDDEN );
#ifdef VERBOSE
if (name== OBJ_FROM_BYT4('a','b','r','t')) {
printf("sym_Alloc( %" VM_X ",\"abrt\" ): sym x=%" VM_X "\n",pkg,sym);
}
#endif

    if (!OBJ_IS_SYMBOL(sym)) {
	/* See if symbol is exported by any */
	/* package used by current package: */
	Vm_Obj use = PKG_P( pkg )->used_packages;
	Vm_Obj key;
	if (OBJ_IS_OBJ(use)) {
	    for(key  = OBJ_NEXT(use,OBJ_FIRST,OBJ_PROP_PUBLIC);
		key != OBJ_NOT_FOUND;
		key  = OBJ_NEXT(use,key,OBJ_PROP_PUBLIC)
	    ){
		/* Find the key's value: */
		Vm_Obj pkg = OBJ_GET( use, key, OBJ_PROP_PUBLIC );

		/* We're only interested in packages: */
		if (OBJ_IS_OBJ(      pkg)
		&&  OBJ_IS_CLASS_PKG(pkg)
		){
		    if (sym = sym_Find_Exported( pkg, name )) {
                        break;
    }   }   }   }   }

    if (!OBJ_IS_SYMBOL(sym) && dflt) {
	/* Do a final hardwired search of dflt pkg.   */
	/* This isn't logically necessary, but avoids */
	/* users getting hung up with no packages     */
	/* selected and no way to select one (say):   */
	if (OBJ_IS_OBJ(      dflt)
	&&  OBJ_IS_CLASS_PKG(dflt)
	){
	    sym = sym_Find_Exported( dflt, name );
    }	}

    /* If not found or not a symbol, create */
    /* a symbol and enter it into package:  */
    if (!OBJ_IS_SYMBOL(sym)) {
        /* Check that acting user controls package: */
	job_Must_Control_With_Err_Msg(
	    pkg,
	    "You don't own this package, so you can't create syms in it."
	);
	{   Vm_Obj new	= vm_Malloc( sizeof(Sym_A_Header), VM_DBFILE(pkg), OBJ_K_SYMBOL );
	    Sym_P  s	= SYM_P(new);
	    s->name	= name;
	    s->value	= OBJ_FROM_BOTTOM(0);
	    s->function	= OBJ_NIL;
	    s->package	= pkg;
	    vm_Dirty(new);
	    sym_Set_Type(    new,OBJ_NIL);
	    sym_Set_Proplist(new,OBJ_NIL);

	    job_RunState.bytes_owned += sizeof(Sym_A_Header);

	    OBJ_SET( pkg, name, new, OBJ_PROP_HIDDEN );
	    sym = new;
    }   }
    return sym;
}

/************************************************************************/
/*-    sym_Alloc_Asciz -- Find/create a symbol.				*/
/************************************************************************/

Vm_Obj
sym_Alloc_Asciz(
    Vm_Obj  pkg,
    Vm_Uch* name,
    Vm_Obj  dflt	/* obj_Lib_Muf, obj_Lib_Lisp or 0 */
) {
    /* NOTE:  If you change the sequence of packages */
    /* searched by this fn, please also update       */
    /* muf.t:is_user_global() and sym_Alloc().       */

    /* Find value of stg in pkg: */
    Vm_Obj sym = OBJ_GET_ASCIZ( pkg, name, OBJ_PROP_HIDDEN );
/*if (!strcmp(name,"muf")) {*/
/*printf("sym_Alloc_Asciz( %" VM_X ",\"muf\" ): sym x=%" VM_X "\n",pkg,sym);*/
/*}*/
/*if (!strcmp(name,"abrt")) {*/
/*printf("sym_Alloc_Asciz( %" VM_X ",\"abrt\" ): sym x=%" VM_X "\n",pkg,sym);*/
/*}*/

    if (!OBJ_IS_SYMBOL(sym)) {
	/* See if symbol is exported by any */
	/* package used by current package: */
	Vm_Obj use = PKG_P( pkg )->used_packages;
	Vm_Obj key;
	if (OBJ_IS_OBJ(use)) {
	    for(key  = OBJ_NEXT(use,OBJ_FIRST,OBJ_PROP_PUBLIC);
		key != OBJ_NOT_FOUND;
		key  = OBJ_NEXT(use,key,OBJ_PROP_PUBLIC)
	    ){
		/* Find the key's value: */
		Vm_Obj pkg = OBJ_GET( use, key, OBJ_PROP_PUBLIC );

		/* We're only interested in packages: */
		if (OBJ_IS_OBJ(      pkg)
		&&  OBJ_IS_CLASS_PKG(pkg)
		){
		    if (sym = sym_Find_Exported_Asciz( pkg, name ))  break;
    }   }   }   }

    if (!OBJ_IS_SYMBOL(sym) && dflt) {
	/* Do final hardwired search of say /lib/muf. */
	/* This isn't logically necessary, but avoids */
	/* users getting hung up with no packages     */
	/* selected and no way to select one:         */
	if (OBJ_IS_OBJ(      dflt)
	&&  OBJ_IS_CLASS_PKG(dflt)
	){
	    sym = sym_Find_Exported_Asciz( dflt, name );
    }	}

    /* If not found or not a symbol, create */
    /* a symbol and enter it into package:  */
    if (!OBJ_IS_SYMBOL(sym)) {
        /* Check that acting user controls package: */
	job_Must_Control_With_Err_Msg(
	    pkg,
	    "You don't own this package, so you can't create syms in it."
	);
	{   Vm_Obj new	= vm_Malloc( sizeof(Sym_A_Header), VM_DBFILE(pkg), OBJ_K_SYMBOL );
	    Vm_Obj nam	= stg_From_Asciz( name );
	    Sym_P  s	= SYM_P(new);
	    s->name	= nam;
	    s->value	= OBJ_FROM_BOTTOM(0);
	    s->function	= OBJ_NIL;
	    s->package	= pkg;
	    vm_Dirty(new);
	    sym_Set_Type(    new,OBJ_NIL);
	    sym_Set_Proplist(new,OBJ_NIL);

	    job_RunState.bytes_owned += sizeof(Sym_A_Header);

	    OBJ_SET( pkg, nam, new, OBJ_PROP_HIDDEN );
	    sym = new;
    }   }
    return sym;
}

/************************************************************************/
/*-    sym_Alloc_Asciz_Keyword -- Find/create a keyword.		*/
/************************************************************************/

Vm_Obj
sym_Alloc_Asciz_Keyword(
    Vm_Uch* name
) {
    /* Find value of stg in pkg: */
    Vm_Obj sym = pkg_X_Get_Asciz( obj_Lib_Keyword, name, OBJ_PROP_PUBLIC );

    /* If not found or not a symbol, create */
    /* a symbol and enter it into package:  */
    if (!OBJ_IS_SYMBOL(sym)) {
        Vm_Unt  dbfile  = VM_DBFILE(obj_Lib_Keyword);
	Vm_Obj new	= vm_Malloc( sizeof(Sym_A_Header), dbfile, OBJ_K_SYMBOL );
	Vm_Obj nam	= stg_From_Asciz_In_Db( name, dbfile );
	Sym_P  s	= SYM_P(new);
	s->name		= nam;
	s->value	= new;
	s->function	= SYM_CONSTANT_FLAG;
	s->package	= obj_Lib_Keyword;
	vm_Dirty(new);
	sym_Set_Type(    new,OBJ_NIL);
	sym_Set_Proplist(new,OBJ_NIL);

        job_RunState.bytes_owned += sizeof(Sym_A_Header);

	OBJ_SET( obj_Lib_Keyword, nam, new, OBJ_PROP_HIDDEN );
	OBJ_SET( obj_Lib_Keyword, nam, new, OBJ_PROP_PUBLIC );
	sym = new;
    }
#ifdef VERBOSE
printf("sym_Alloc_Asciz_Keyword(%s) returning %llx\n",name,sym);
#endif
    return sym;
}

/************************************************************************/
/*-    sym_Alloc_Keyword -- Find/create a keyword.			*/
/************************************************************************/

Vm_Obj
sym_Alloc_Keyword(
    Vm_Obj name
) {
    /* Find value of stg in pkg: */
    Vm_Obj sym = OBJ_GET( obj_Lib_Keyword, name, OBJ_PROP_PUBLIC );

    /* If not found or not a symbol, create */
    /* a symbol and enter it into package:  */
/* buggo, there are problems with random users creating */
/* keywords.  We want them charged for the space, but   */
/* we don't want them changing the name afterwards or   */
/* such.                                                */
    if (!OBJ_IS_SYMBOL(sym)) {
        Vm_Unt  dbfile  = VM_DBFILE(obj_Lib_Keyword);
	Vm_Obj new	= vm_Malloc( sizeof(Sym_A_Header), dbfile, OBJ_K_SYMBOL );
	Vm_Obj nam	= stg_Is_Stg(name) ? stg_Dup_In_Db(name,dbfile) : name;
	Sym_P  s	= SYM_P(new);
	s->name		= nam;
	s->value	= new;
	s->function	= SYM_CONSTANT_FLAG;
	s->package	= obj_Lib_Keyword;
	vm_Dirty(new);
	sym_Set_Type(    new,OBJ_NIL);
	sym_Set_Proplist(new,OBJ_NIL);

        job_RunState.bytes_owned += sizeof(Sym_A_Header);

	OBJ_SET( obj_Lib_Keyword, nam, new, OBJ_PROP_HIDDEN );
	OBJ_SET( obj_Lib_Keyword, nam, new, OBJ_PROP_PUBLIC );
	sym = new;
    }
    return sym;
}

/************************************************************************/
/*-    sym_Find -- Return symbol if defined in package else NULL.	*/
/************************************************************************/

Vm_Obj
sym_Find(
    Vm_Obj  pkg,
    Vm_Obj  name
) {
#ifdef DUBIOUS /* This check results in inability to print a::y */
/* without triggering an exception, including in debug listings: */
    /* Check that acting user controls package: */
    job_Must_Control_With_Err_Msg(
	pkg,
	"You don't own this package, so you can't use private symbols in it."
    );
#endif
    {   /* Find value of stg in pkg: */
	Vm_Obj sym = OBJ_GET( pkg, name, OBJ_PROP_HIDDEN );

	if (OBJ_IS_SYMBOL(sym))    return          sym  ;
	else                       return (Vm_Obj) FALSE;
    }
}

/************************************************************************/
/*-    sym_Find_Asciz -- Return symbol if defined in package else NULL.	*/
/************************************************************************/

Vm_Obj
sym_Find_Asciz(
    Vm_Obj  pkg,
    Vm_Uch* name
) {
    /* Check that acting user controls package: */
    job_Must_Control_With_Err_Msg(
	pkg,
	"You don't own this package, so you mayn't use private symbols in it."
    );
    {   /* Find value of stg in pkg: */
	Vm_Obj sym = OBJ_GET_ASCIZ( pkg, name, OBJ_PROP_HIDDEN );

	if (OBJ_IS_SYMBOL(sym))    return sym;
    }

    {   /* See if symbol is exported by any */
	/* package used by current package: */
	Vm_Obj use = PKG_P( pkg )->used_packages;
	Vm_Obj key;
	if (OBJ_IS_OBJ(use)) {
	    for(key  = OBJ_NEXT(use,OBJ_FIRST,OBJ_PROP_PUBLIC);
		key != OBJ_NOT_FOUND;
		key  = OBJ_NEXT(use,key,OBJ_PROP_PUBLIC)
	    ){
		/* Find the key's value: */
		Vm_Obj pkg = OBJ_GET( use, key, OBJ_PROP_PUBLIC );

		/* We're only interested in packages: */
		if (OBJ_IS_OBJ(      pkg)
		&&  OBJ_IS_CLASS_PKG(pkg)
		){
		    Vm_Obj sym = sym_Find_Exported_Asciz( pkg, name );
		    if (sym)   return sym;
    }   }   }   }

    return (Vm_Obj) FALSE;
}

/************************************************************************/
/*-    sym_Alloc_Full_Asciz -- Return symbol else NULL.			*/
/************************************************************************/

Vm_Obj
sym_Alloc_Full_Asciz(
    Vm_Obj  pkg,
    Vm_Uch* name
) {
    /* This function differs from sym_Find_Full_Asciz   */
    /* only in that it supports package qualifiers too: */
    Vm_Uch* p = name;
    for (p = name; *p; ++p) {
	if (*p == ':') {

	    /* Special case for keywords: */
	    if (p == name)  return sym_Alloc_Asciz_Keyword( name+1 );

	    *p = '\0';
	    pkg = muf_Find_Package_Asciz( name );
	    if (!pkg) MUQ_WARN("No such package: '%s'",name);
	    if (p[1] == ':') {
		return sym_Alloc_Asciz( pkg, &p[2], 0 );
	    } else {
		Vm_Obj sym = sym_Alloc_Asciz( pkg, &p[1], 0 );
		Vm_Obj nam = SYM_P(sym)->name;
		OBJ_SET( pkg, nam, sym, OBJ_PROP_PUBLIC );
		return sym;
	    }
	}
    }
    return sym_Alloc_Asciz( pkg, name, 0 );
}

/************************************************************************/
/*-    sym_Find_Exported -- Return exported symbol else NULL.		*/
/************************************************************************/

Vm_Obj
sym_Find_Exported(
    Vm_Obj pkg,
    Vm_Obj name
) {
    /* Find value of stg in pkg: */
    Vm_Obj sym = OBJ_GET( pkg, name, OBJ_PROP_PUBLIC );
    if (OBJ_IS_SYMBOL(sym))    return          sym  ;
    else                       return (Vm_Obj) FALSE;
}

/************************************************************************/
/*-    sym_Find_Exported_Asciz -- Return exported symbol else NULL.	*/
/************************************************************************/

Vm_Obj
sym_Find_Exported_Asciz(
    Vm_Obj  pkg,
    Vm_Uch* name
) {
    /* Find value of stg in pkg: */
    Vm_Obj sym = OBJ_GET_ASCIZ( pkg, name, OBJ_PROP_PUBLIC );

    /* If not found or not a symbol, create */
    /* a symbol and enter it into package:  */
    if (OBJ_IS_SYMBOL(sym))    return          sym  ;
    else                       return (Vm_Obj) FALSE;
}

/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/

/************************************************************************/
/*-    sym_Startup -- start-of-world stuff.				*/
/************************************************************************/

#define FUNCTION	(1)
#define NAME		(2)
#define PACKAGE		(3)
#define PROPLIST	(4)
#define TYPE		(5)
#define VALUE		(6)

static struct sym_prop_rec {
    Vm_Obj  keyword;
    Vm_Uch* name;
    Vm_Int  action;
} sym_prop_table[] = {
    {0, "function"		, FUNCTION		},
    {0, "name"			, NAME			},
    {0, "package"		, PACKAGE		},
    {0, "proplist"		, PROPLIST		},
    {0, "type"			, TYPE			},
    {0, "value"			, VALUE			},

    /* End-of-array sentinel: */
    {0, NULL			, 0			}
};

static void
sym_prop_table_init(
    void
){
    /* Find keyword for each property name: */
    {   struct sym_prop_rec *p;
        for (p = sym_prop_table;  p->name;   ++p) {
	    p->keyword = sym_Alloc_Asciz_Keyword( p->name );
    }	}

    {   struct sym_prop_rec *p;
	struct sym_prop_rec *q;
	for     (p = sym_prop_table;  p->name;   ++p) {
	    for (q = p             ;  q->name;   ++q) {
		if (p->keyword > q->keyword) {
		    /* Many compilers disallow */
		    /* combining the next two: */
		    struct sym_prop_rec t;t = *p;
		    *p = *q;
		    *q = t;
    }   }   }   }
}

void
sym_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    sym_prop_table_init();
}

/************************************************************************/
/*-    sym_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
sym_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}

/************************************************************************/
/*-    sym_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
sym_Shutdown(
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
/*-    sym_sprintX -- Debug dump of sym state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
sym_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    Vm_Obj pkg;
    Vm_Obj nam;
    Vm_Obj fun;
    {   Sym_P s = SYM_P(obj);
	pkg     = s->package;
	nam     = s->name;
	fun     = s->function;
    }
    if (!OBJ_IS_OBJ(pkg)
    ||  !OBJ_IS_CLASS_PKG(pkg)
    ){
	/* Special format to print uninterned symbols: */
	buf = lib_Sprint( buf, lim, "#:" );
    } else if (pkg == obj_Lib_Keyword) {
	/* Special format to print keywords: */
	buf = lib_Sprint( buf, lim, ":" );
    } else {
	Vm_Obj current_pkg = JOB_P(job_RunState.job)->package;

	/* Print leading quote for symbol */
	/* name, except on constants:     */
	if (fun != SYM_CONSTANT_FLAG) {
	    buf = lib_Sprint( buf, lim, "'"  );
	}

/*if (job_Trace_Bytecodes) {
printf("sym_sprintX: obj x=%" VM_X "\n",obj);
printf("             pkg x=%" VM_X "\n",pkg);
printf("             nam x=%" VM_X "\n",nam);
printf("             fun x=%" VM_X "\n",fun);
printf("     obj_Lib_Muf x=%" VM_X "\n",obj_Lib_Muf);
printf("     current_pkg x=%" VM_X "\n",current_pkg);
printf("         OBJ_NIL x=%" VM_X "\n",OBJ_NIL);
printf("           OBJ_T x=%" VM_X "\n",OBJ_T);
}*/
	/* If symbol is not accessable in current   */
	/* package,  prefix name with package name: */
	if (!pkg_Knows_Symbol( current_pkg, obj )
	&&   obj != OBJ_NIL		/* Silly special cases because I */
	&&   obj != OBJ_T		/* got sick of seeing "lisp:nil" */
	){
	    buf += job_Sprint_Vm_Obj( buf, lim, OBJ_P(pkg)->objname, FALSE );

	    /* Need '::' iff symbol isn't exported from package: */
	    if (sym_Find_Exported( pkg, nam )) {
		buf = lib_Sprint( buf, lim, ":"   );
	    } else {
		buf = lib_Sprint( buf, lim, "::"  );
    }   }   }

    buf  +=  job_Sprint_Vm_Obj( buf, lim, SYM_P(obj)->name,    FALSE );

/* buggo, temp debug hack: */
buf = lib_Sprint( buf, lim, "(%llx)", obj );

    return buf;
}

/************************************************************************/
/*-    sym_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
sym_for_del(
    Vm_Obj obj,
    Vm_Obj key, 
    Vm_Int propdir
) {
    return OBJ_NIL;
}

/************************************************************************/
/*-    sym_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
sym_for_get(
    Vm_Obj obj,
    Vm_Obj key, 
    Vm_Int propdir
) {
    struct sym_prop_rec *p;

    if (propdir != OBJ_PROP_SYSTEM && propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;
    if (!OBJ_IS_SYMBOL(key))          return OBJ_NOT_FOUND;

    for (p = sym_prop_table;  p->name;   ++p) {
        if (p->keyword == key) {
	    switch (p->action) {
	    case FUNCTION:	return job_Symbol_Function(obj);
	    case NAME:		return SYM_P(obj)->name;
	    case PACKAGE:	return SYM_P(obj)->package;
	    case TYPE:		return sym_Type(    obj);
	    case PROPLIST:	return sym_Proplist(obj);
	    case VALUE:		return job_Symbol_Value(obj);
	    default:
		MUQ_FATAL ("sym_for_get: internal err");
    }	}   }

    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    sym_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
sym_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key, 
    Vm_Int  propdir
) {
    return OBJ_NIL;
}

/************************************************************************/
/*-    sym_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
sym_for_set(
    Vm_Obj o,
    Vm_Obj k,
    Vm_Obj v,
    Vm_Int propdir
) {
    if ((propdir == OBJ_PROP_SYSTEM || propdir == OBJ_PROP_PUBLIC)
    &&  OBJ_IS_SYMBOL(k)
    ){
	struct sym_prop_rec *p;
	for (p = sym_prop_table;  p->name;   ++p) {
	    if (p->keyword == k) {
		switch (p->action) {
		case FUNCTION:
		    SYM_P(o)->function = v;
		    vm_Dirty(o);
		    return NULL;
		case NAME:
		    /* "return SYM_P(obj)->name;" seems	*/
		    /* dubious since name in pkg would  */
		    /* not be updated, so:              */
		    return "May not set name of a symbol.";
		case PACKAGE:
		    return "May not set package of a symbol.";
		case PROPLIST:
		    sym_Set_Proplist(o,v);
		    return NULL;
		case TYPE:
		    sym_Set_Type(o,v);
		    return NULL;
		case VALUE:
		    SYM_P(o)->value = v;
		    vm_Dirty(o);
		    return NULL;
		default:
		    MUQ_FATAL ("sym_for_set: internal err");
    }	}   }   }

    return "May not 'set' this property on symbols.";
}

/************************************************************************/
/*-    sym_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
sym_for_nxt(
    Vm_Obj obj,
    Vm_Obj key, 
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_SYSTEM && propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;

    if (key==OBJ_FIRST)   return sym_prop_table->keyword;

    {   struct sym_prop_rec *p;
        for (p = sym_prop_table;  p->name;   ++p) {
	    if (p->keyword > key
	    /* Special case hack for unbound variables, */
	    /* so lss doesn't crash trying to list val: */
	    && (p->action != VALUE
	       || SYM_P(obj)->value != OBJ_FROM_BOTTOM(0)
	       )
	    ){
		return p->keyword;
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
    Vm_Obj cdf = sym_Type_Summary.builtin_class;

    /* We do this because the bootstrap process   */
    /* probably creates symbols before            */
    /* class symbol exists. Should fix            */
    /* fix this if so, sometime, then kill this:  */
    if (OBJ_IS_OBJ(cdf) && OBJ_IS_CLASS_CDF(cdf)) {
	Vm_Obj key = CDF_P(cdf)->key;
        if (OBJ_IS_OBJ(key) && OBJ_IS_CLASS_KEY(key)) {
	    return key;
	}
    }

    return CDF_P(sym_Type_Summary.builtin_class)->key;
}

/************************************************************************/
/*-    sym_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj
sym_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    /* Read old name of object: */
    Vm_Obj n;
    Vm_Obj o;
    if (1 != fscanf(fd, "%" VM_X , &o )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("sym_import: bad input");
    }
    
    /* Make/find symbol cell to hold result: */
    n = pass ? obj_Import_Hashtab_Val(o) : sym_Make();
    if (!pass)   obj_Import_Hashtab_Enter( n, o );

    /* Read items in object: */
    {
	Vm_Obj fn    =        obj_Import_Any( fd, pass, have, read );
        Vm_Obj name  =        obj_Import_Any( fd, pass, have, read );
	Vm_Obj pkg   =        obj_Import_Any( fd, pass, have, read );
	Vm_Obj value =        obj_Import_Any( fd, pass, have, read );
	Vm_Obj typ   =        obj_Import_Any( fd, pass, have, read );
	Vm_Obj plst  =        obj_Import_Any( fd, pass, have, read );
	Sym_P  s           = SYM_P(n);
	s->function        = fn;
	s->name	           = name;
	s->package         = pkg;
	s->value           = value;
	vm_Dirty(n);
	sym_Set_Type(n,typ);
	sym_Set_Proplist(n,plst);
    }
    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    /* Read end-of-object: */
    if (fgetc(fd) != '\n') MUQ_FATAL ("sym_Import: bad input!\n");

    ++obj_Export_Stats->objects_in_file;

    return n;
}

/************************************************************************/
/*-    sym_export -- Write object into textfile.			*/
/************************************************************************/

static void
sym_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
    fprintf( fd, "S:%" VM_X "\n", o );
    {   Sym_P p = SYM_P(o);
	obj_Export_Subobj(                    fd, p->function    , write_owners );
	obj_Export_Subobj(                    fd, p->name        , write_owners );
	obj_Export_Subobj(                    fd, p->package     , write_owners );
	obj_Export_Subobj(                    fd, p->value       , write_owners );
	obj_Export_Subobj(                    fd, sym_Type(o)    , write_owners );
	obj_Export_Subobj(                    fd, sym_Proplist(o), write_owners );
	fputc( '\n', fd );
    }
}

/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/

/************************************************************************/
/*-    sym_Proplist -- 							*/
/************************************************************************/

Vm_Obj
sym_Proplist(
    Vm_Obj o
) {
    Vm_Unt dbfile = VM_DBFILE(o);
    Vm_Obj dbf    = vm_Root(dbfile);
    Vm_Obj mil    = DBF_P(dbf)->symbol_proplist_mil;
    Vm_Obj result = mil_Get( mil, o );
    if (result == OBJ_NOT_FOUND)  result = OBJ_NIL;
    return result;
}

/************************************************************************/
/*-    sym_Set_Proplist -- 						*/
/************************************************************************/

void
sym_Set_Proplist(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Unt dbfile = VM_DBFILE(o);
    Vm_Obj dbf    = vm_Root(dbfile);
    Vm_Obj mil    = DBF_P(dbf)->symbol_proplist_mil;
    Vm_Obj mil2;

    if (v == OBJ_NIL) 	mil2 = mil_Del( mil, o            );
    else                mil2 = mil_Set( mil, o, v, dbfile );

    if (mil2 != mil) {
	DBF_P(dbf)->symbol_proplist_mil = mil2;
	vm_Dirty(dbf);
    }
}

/************************************************************************/
/*-    sym_Type -- 							*/
/************************************************************************/

Vm_Obj
sym_Type(
    Vm_Obj o
) {
    Vm_Unt dbfile = VM_DBFILE(o);
    Vm_Obj dbf    = vm_Root(dbfile);
    Vm_Obj mil    = DBF_P(dbf)->symbol_type_mil;
    Vm_Obj result = mil_Get( mil, o );
    if (result == OBJ_NOT_FOUND)  result = OBJ_NIL;

    return result;
}

/************************************************************************/
/*-    sym_Set_Type -- 							*/
/************************************************************************/

void
sym_Set_Type(
    Vm_Obj o,
    Vm_Obj v
) {
/* New code: */
    Vm_Unt dbfile = VM_DBFILE(o);
    Vm_Obj dbf    = vm_Root(dbfile);
    Vm_Obj mil    = DBF_P(dbf)->symbol_type_mil;
    Vm_Obj mil2;

    if (v == OBJ_NIL) 	mil2 = mil_Del( mil, o            );
    else                mil2 = mil_Set( mil, o, v, dbfile );

    if (mil2 != mil) {
	DBF_P(dbf)->symbol_type_mil = mil2;
	vm_Dirty(dbf);
    }
}

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
