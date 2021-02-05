@example  @c
/*--   cfn.c -- Compiled FuNction objects for Muq.			*/
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
/* Created:      93Feb01						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-1995, by Jeff Prothero.				*/
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
/* JEFF PROTHERO DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
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

#define SIZEOF_CFN(n) \
 (sizeof(Cfn_A_Header) + ((n)-1) * sizeof(Vm_Obj))



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static Vm_Uch* cfn_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  cfn_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  cfn_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  cfn_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* cfn_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  cfn_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  cfn_import(   FILE*, Vm_Int , Vm_Int, Vm_Int );
static void    cfn_export(   FILE*, Vm_Obj , Vm_Int );
static Vm_Obj  cfn_reverse( Vm_Obj o );

static Vm_Obj  get_mos_key( Vm_Obj );

static void cfn_prop_table_init(void);

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void cfn_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_THUNK ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_THUNK");
    }
    mod_Type_Summary[ OBJ_TYPE_THUNK ] = &cfn_Type_Summary;

    if (mod_Type_Summary[ OBJ_TYPE_CFN ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_CFN");
    }
    mod_Type_Summary[ OBJ_TYPE_CFN ] = &cfn_Type_Summary;
}
Obj_A_Module_Summary cfn_Module_Summary = {
   "cfn",
    cfn_doTypes,
    cfn_Startup,
    cfn_Linkup,
    cfn_Shutdown
};

Obj_A_Type_Summary cfn_Type_Summary = {    OBJ_FROM_BYT2('P','T'),
    cfn_sprintX,
    cfn_sprintX,
    cfn_sprintX,
    cfn_for_del,
    cfn_for_get,
    cfn_g_asciz,
    cfn_for_set,
    cfn_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    cfn_reverse,
    get_mos_key,
    cfn_import,
    cfn_export,
    "CompiledFunction",
    KEY_LAYOUT_COMPILED_FUNCTION,
    OBJ_0
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    cfn_Alloc -- Allocate a new executable.				*/
/************************************************************************/

Vm_Obj
cfn_Alloc(
    Vm_Unt n,	/* Number of cells to allocate in vec[].	*/
    Vm_Uch tags /* OBJ_K_CFN or OBJ_K_THUNK */
) {
    /* jS.job is FALSE only briefly during initial bootstrap: */
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    Vm_Obj x = vm_Malloc( SIZEOF_CFN(n), VM_DBFILE(pkg), tags );
    Cfn_P  p = CFN_P(x);

    job_RunState.bytes_owned   += SIZEOF_CFN(n);

    /* Clear the stack to all zeros: */
    {   Vm_Unt i;
	for   (i = n;   i --> 0;   ) {
	    p->vec[i] = OBJ_FROM_INT( 0 );
    }	}

    p->is_a   = cfn_Type_Summary.builtin_class;
    p->src    = OBJ_FROM_INT( 0);
    p->bitbag = CFN_SET_CONSTS(OBJ_0,0);

    /* Mark compiled-functions as being read-only: */
    vm_Set_Constbit( x );

    vm_Dirty(x);
    return  x;
}



/************************************************************************/
/*-    cfn_Len -- Return length of executable.				*/
/************************************************************************/

Vm_Int
cfn_Len(
    Vm_Obj o
) {
    Vm_Obj* v = &CFN_P(o)->vec[0];
    Vm_Obj* e = (Vm_Obj*) ((Vm_Uch*)(vm_Loc(o))+vm_Len(o));
    return e-v;
}



/************************************************************************/
/*-    cfn_Dup -- Return duplicate of given cfn.			*/
/************************************************************************/

Vm_Obj
cfn_Dup(
    Vm_Obj cfn
) {
    return obj_Dup(cfn);
}

/************************************************************************/
/*-    cfn_Sprint  -- Debug dump of cfn state, multi-line format.	*/
/************************************************************************/

Vm_Uch*
cfn_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  cfn
) {
    Cfn_P  s   = CFN_P(cfn);
    int    i   = (int)CFN_CONSTS( s->bitbag );
    while (i --> 0) {
	Vm_Obj*  j = &s->vec[i];
	buf  = lib_Sprint(buf,lim, "%d: ", i );
	buf += job_Sprint_Vm_Obj( buf,lim, *j, /* quote_strings: */ TRUE );
	buf  = lib_Sprint(buf,lim, "\n" );
    }
    return buf;
}

/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/
/************************************************************************/
/*-    cfn_Startup -- start-of-world stuff.				*/
/************************************************************************/

#define AS_ROOT			(1)
#define COMPILE_TIME		(2)
#define CONST_COUNT		(3)
#define GENERIC			(4)
#define KEPT_PROMISE		(5)
#define MOS_GENERIC	        (6)
#define NEVER_INLINE		(7)
#define OWNER			(8)
#define PLEASE_INLINE		(9)
#define PRIM		       (10)
#define PROMISE_OR_THUNK       (11)
#define PROMISE		       (12)
#define SOURCE		       (13)
#define THUNK		       (14)

static struct cfn_prop_rec {
    Vm_Obj  keyword;
    Vm_Uch* name;
    Vm_Int  action;
} cfn_prop_table[] = {
/* buggo, should kill the '?'s */
    {0, "asRoot?"		, AS_ROOT		},
    {0, "compileTime?"		, COMPILE_TIME		},
    {0, "constCount"		, CONST_COUNT		},
    {0, "generic?"		, GENERIC		},
    {0, "keptPromise?"		, KEPT_PROMISE		},
    {0, "mosGeneric?"		, MOS_GENERIC		},
    {0, "neverInline?"		, NEVER_INLINE		},
    {0, "owner"			, OWNER			},
    {0, "pleaseInline?"	, PLEASE_INLINE		},
    {0, "prim?"			, PRIM			},
    {0, "promiseOrThunk?"	, PROMISE_OR_THUNK	},
    {0, "promise?"		, PROMISE		},
    {0, "source"		, SOURCE		},
    {0, "thunk?"		, THUNK			},
    {0, NULL			, 0			}
};
static void
cfn_prop_table_init(
    void
){
    /* Find keyword for each property name: */
    {   struct cfn_prop_rec *p;
        for (p = cfn_prop_table;  p->name;   ++p) {
	    p->keyword = sym_Alloc_Asciz_Keyword( p->name );
    }	}

    {   struct cfn_prop_rec *p;
	struct cfn_prop_rec *q;
	for     (p = cfn_prop_table;  p->name;   ++p) {
	    for (q = p             ;  q->name;   ++q) {
		if (p->keyword > q->keyword) {
		    /* Many compilers disallow */
		    /* combining the next two: */
		    struct cfn_prop_rec t;t = *p;
		    *p = *q;
		    *q = t;
    }   }   }   }
}

void
cfn_Startup(
    void
) {
    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;

    cfn_prop_table_init();

    dil_Startup();
    obj_Startup();
}



/************************************************************************/
/*-    cfn_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
cfn_Linkup(
    void
) {
    static int done_linkup  = FALSE;
    if        (done_linkup)   return;
    done_linkup		    = TRUE;

    dil_Linkup();
    obj_Linkup();
}



/************************************************************************/
/*-    cfn_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
cfn_Shutdown(
    void
) {
    static int done_shutdown = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	     = TRUE;

    obj_Shutdown();
}



/************************************************************************/
/*-    cfn_Bytes_Of_Code -- Return number of bytes of code in cfn.	*/
/************************************************************************/

Vm_Int
cfn_Bytes_Of_Code(
    Vm_Obj x
) {
    /* We don't explicitly store the number of bytecodes  */
    /* in the executable, but we set the trailing pad     */
    /* bytes to FF, and usually end with a RET bytecode,  */
    /* which we keep not equal to FF, so we can deduce    */
    /* number of bytecodes:				      */
    Vm_Unt len = vm_Len(x);
    Cfn_P  p   = CFN_P(x);
    Vm_Int k   = CFN_CONSTS( p->bitbag );
    Vm_Uch*t   = (Vm_Uch*) &p->vec[ k ];
    Vm_Int n = ((Vm_Uch*)p + len)  -   t;
    while (n > 0   &&   t[n-1] == 0xFF)   --n;
    return n;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    cfn_sprintX -- Debug dump of cfn state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
cfn_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    Vm_Obj bb  = CFN_P(obj)->bitbag;
    if (CFN_IS_KEPTPROMISE(bb)) {
        #ifndef MUQ_VERBOSE
	return lib_Sprint( buf, lim, "#<keptPromise %" VM_X ">", obj );
	#else
	{   Vm_Uch tmp[30];
	    return lib_Sprint(
		buf, lim, "#<keptPromise%s>", obj_Name(tmp,30,obj)
	    );
    	}
	#endif
    }
    if (CFN_IS_PROMISE(bb)) {
        #ifndef MUQ_VERBOSE
	return lib_Sprint( buf, lim, "#<promise %" VM_X ">", obj );
	#else
	{   Vm_Uch tmp[30];
	    return lib_Sprint(
		buf, lim, "#<promise%s>", obj_Name(tmp,30,obj)
	    );
    	}
	#endif
    }
    if (CFN_IS_THUNK(  bb)) {
        #ifndef MUQ_VERBOSE
	return lib_Sprint( buf, lim, "#<thunk %" VM_X ">",   obj );
	#else
	{   Vm_Uch tmp[30];
	    return lib_Sprint(
		buf, lim, "#<thunk%s>", obj_Name(tmp,30,obj)
	    );
    	}
	#endif
    }
    #ifndef MUQ_VERBOSE
    {   Vm_Uch tmp[30];
        return lib_Sprint( buf, lim, "#<compiledFunction %s %" VM_X ">", obj_Name(tmp,30,obj), obj );
    }
    #else
    {   Vm_Uch tmp[30];
	return lib_Sprint( buf, lim, "#<compiledFunction %s>", obj_Name(tmp,30,obj) );
    }
    #endif
}



/************************************************************************/
/*-    cfn_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
cfn_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    cfn_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
cfn_for_get(
    Vm_Obj o,
    Vm_Obj key,
    Vm_Int propdir
) {
    struct cfn_prop_rec *p;

    if (propdir != OBJ_PROP_SYSTEM && propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;
    if (!OBJ_IS_SYMBOL(key))          return OBJ_NOT_FOUND;

    for (p = cfn_prop_table;  p->name;   ++p) {
        if (p->keyword == key) {
	    switch (p->action) {
	    case AS_ROOT:
		return OBJ_FROM_BOOL( CFN_IS_AS_ROOT(     CFN_P(o)->bitbag ));
	    case COMPILE_TIME:
		return OBJ_FROM_BOOL( CFN_IS_COMPILETIME( CFN_P(o)->bitbag ));
	    case CONST_COUNT:
		return OBJ_FROM_INT(  CFN_CONSTS(         CFN_P(o)->bitbag ));
	    case GENERIC:
		return OBJ_FROM_BOOL( CFN_IS_GENERIC(     CFN_P(o)->bitbag ));
	    case MOS_GENERIC:
		return OBJ_FROM_BOOL( CFN_IS_MOS_GENERIC( CFN_P(o)->bitbag ));
	    case KEPT_PROMISE:
		return OBJ_FROM_BOOL( CFN_IS_KEPTPROMISE( CFN_P(o)->bitbag ));
	    case NEVER_INLINE:
		return OBJ_FROM_BOOL( CFN_IS_NEVER_INLINE(CFN_P(o)->bitbag ));
	    case OWNER:
		return obj_Owner(o);
	    case PLEASE_INLINE:
		return OBJ_FROM_BOOL( CFN_IS_PLEASE_INLINE(CFN_P(o)->bitbag));
	    case PRIM:
		return OBJ_FROM_BOOL( CFN_IS_PRIM(        CFN_P(o)->bitbag ));
	    case PROMISE_OR_THUNK:
	       return OBJ_FROM_BOOL(CFN_IS_PROMISE_OR_THUNK(CFN_P(o)->bitbag));
	    case PROMISE:
		return OBJ_FROM_BOOL( CFN_IS_PROMISE(     CFN_P(o)->bitbag ));
	    case SOURCE:
		return CFN_P(o)->src;
	    case THUNK:
		return OBJ_FROM_BOOL( CFN_IS_THUNK(       CFN_P(o)->bitbag ));
	    default:
		MUQ_FATAL ("cfn_for_get: internal err");
    }	}   }

    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    cfn_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
cfn_g_asciz(
    Vm_Obj  o,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    cfn_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
cfn_for_set(
    Vm_Obj o,
    Vm_Obj k,
    Vm_Obj v,
    Vm_Int propdir
) {
    return   "May not 'set' this property on procedures.";
}

/************************************************************************/
/*-    cfn_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
cfn_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_SYSTEM && propdir != OBJ_PROP_PUBLIC)   return OBJ_NOT_FOUND;

    {   struct cfn_prop_rec *p;
        for (p = cfn_prop_table;  p->name;   ++p) {
	    if (p->keyword > key)   return p->keyword;
    }	}

    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    get_mos_key -- Find key object for this structure		*/
/************************************************************************/

static Vm_Obj
get_mos_key(
    Vm_Obj obj
) {
    Vm_Obj cdf = CFN_P(obj)->is_a;

    /* We do this because the bootstrap process   */
    /* probably creates compiled-functions before */
    /* class compiledFunction exists. Should fix */
    /* fix this if so, sometime, then kill this:  */
    if (OBJ_IS_OBJ(cdf) && OBJ_IS_CLASS_CDF(cdf)) {
	Vm_Obj key = CDF_P(cdf)->key;
        if (OBJ_IS_OBJ(key) && OBJ_IS_CLASS_KEY(key)) {
	    return key;
	}
    }

    return CDF_P(cfn_Type_Summary.builtin_class)->key;
}

/************************************************************************/
/*-    cfn_reverse -- 							*/
/************************************************************************/

static Vm_Obj
cfn_reverse(
    Vm_Obj o
) {
    Vm_Int k = CFN_CONSTS( vm_Reverse64( CFN_P(o)->bitbag ) );
    Vm_Int i = &CFN_P(o)->vec[k] - (Vm_Obj*)CFN_P(o);
    Vm_Obj*p = (Vm_Obj*)(vm_Loc(o));
/*printf("cfn_reverse: o x=%llx CFN_P(o)->bitbag x=%llx\n",o,CFN_P(o)->bitbag);*/
/*printf("cfn_reverse: o x=%llx vm_Reverse64( CFN_P(o)->bitbag ) x=%llx\n",o,vm_Reverse64( CFN_P(o)->bitbag ));*/
/*printf("cfn_reverse: o x=%llx CFN_CONSTS( vm_Reverse64( CFN_P(o)->bitbag ) ) x=%llx\n",o,CFN_CONSTS( vm_Reverse64( CFN_P(o)->bitbag ) ));*/
    while (i --> 0)   p[i] = vm_Reverse64( p[i] );
    return OBJ_NIL;
}


/************************************************************************/
/*-    cfn_import -- Read  object from textfile.			*/
/************************************************************************/

#ifndef CFN_MAX_INSTRUCTION_LINE
#define CFN_MAX_INSTRUCTION_LINE (132)
#endif

static Vm_Obj
cfn_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    /* Read old id of object: */
    Vm_Uch c;	/* Export format.	*/
    int k;	/* Number of constants. */
    int l;	/* Number of cells.	*/
    Vm_Obj n;	/* New name of proc.	*/
    Vm_Obj o;	/* Old name of proc.	*/
    if (4 != fscanf(fd, "%c:%" VM_X ":%d:%d", &c, &o, &k, &l )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("cfn_import: bad input!");
    }
    if (c != 'a')   MUQ_FATAL ("cfn_Import: unsupported file format.");
    
    /* Make/find obj to hold result: */
    n = (pass ? obj_Import_Hashtab_Val( o ) : cfn_Alloc( l, OBJ_K_CFN ) );
    if (!pass)  obj_Import_Hashtab_Enter( n, o );

    /* Read source object: */
    {   Vm_Obj s = obj_Import_Any( fd, pass, have, read );
	if (pass) {
	    CFN_P(n)->src = s;
	    vm_Dirty(n);
    }	}

    /* Read bitbag: */
    {   Vm_Obj i = obj_Import_Any( fd, pass, have, read );
	if (pass) {
	    CFN_P(n)->bitbag = i;
	    vm_Dirty(n);
    }   }

    /* Read all constants in object: */
    {   Vm_Int i;
	for (i = 0;   i < k;   ++i) {
	    Vm_Obj x = obj_Import_Any( fd, pass, have, read );
	    if (pass) {
		CFN_P(n)->vec[i] = x;
		vm_Dirty(n);
    }	}   }

    /* Read and assemble all instructions in object: */
    {   Vm_Uch  buf[   CFN_MAX_INSTRUCTION_LINE ];
	Vm_Uch  instr[ CFN_MAX_INSTRUCTION_LINE ];
	Vm_Int  instr_len;
	Vm_Int  u = (Vm_Uch*)(&CFN_P(n)->vec[k]) - (Vm_Uch*)(CFN_P(n));
	#if MUQ_IS_PARANOID
	Vm_Int  u0 = u;
	#endif
	Vm_Int  z = (Vm_Uch*)(&CFN_P(n)->vec[l]) - (Vm_Uch*)(CFN_P(n));
	for (;;) {
	    if (!fgets( buf, CFN_MAX_INSTRUCTION_LINE, fd )) {
		MUQ_FATAL ("cfn_import: unexpected EOF!");
	    }

	    /* Check for end of assembly code for procedure: */
	    if (STRCMP( buf, == ,"\n"))   break;

	    /* Decode assembly into bytecode sequence: */
	    instr_len = asm_Assemble_Instruction(
		instr, CFN_MAX_INSTRUCTION_LINE, buf
	    );

	    #if MUQ_IS_PARANOID
	    /* Verify that instruction begins on expected offset: */
	    if (pass) {
		int adr;
		if (1 != sscanf(buf, "%x", &adr)) {
		    MUQ_FATAL ("cfn_import: missing instruction address!");
		}
		if (adr != u-u0) {
		    MUQ_FATAL (
			"cfn_import: bad instruction address! %x vs %x",
			adr, (int)(u-u0)
		    );
	    }   }
	    #endif

	    /* Copy instruction into procedure: */
	    if (pass) {
		Vm_Uch* p = (Vm_Uch*) CFN_P(n);
		Vm_Int  i;
		for (i = 0;   i < instr_len;  ++i) {
		    p[ u+i ] = instr[ i ];
		}
		u += i;
		vm_Dirty(n);
		if (u > z) MUQ_FATAL ("cfn_import: bytecodes overflowed obj!");
        }   }

	/* Fill any trailing pad bytes with */
	/* 0xFF to aid code disassembly:    */
	if (pass) {
	    Vm_Uch* p = (Vm_Uch*) CFN_P(n);
	    Vm_Int  i;
	    for (i = u;   i < z;  ++i) {
		p[ i ] = 0xFF;
	    }
	    vm_Dirty(n);
    }   }

    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    ++obj_Export_Stats->objects_in_file;

    return n;
}



/************************************************************************/
/*-    cfn_export -- Write object into textfile.			*/
/************************************************************************/

static void
cfn_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
    /* Look up number of constants in procedure: */
    int constants = (int)CFN_CONSTS( CFN_P(o)->bitbag );

    /* Compute total number of cells in procedure */
    /* this is the number cfn_import need to give */
    /* to cfn_Alloc() when recreating us):        */
    int cells_len;
    {   Vm_Int  len = vm_Len(o);
	Cfn_P   p   = CFN_P(o);
	Vm_Obj* top = &p->vec[ 0 ];
	Vm_Obj* lim = (Vm_Obj*)((Vm_Uch*)p + len);
	cells_len   = lim-top;
    }

    fprintf( fd, "P:a:%" VM_X ":%d:%d\n", o, constants, cells_len );

    obj_Export_Subobj( fd, CFN_P(o)->src   , write_owners );   
    obj_Export_Subobj( fd, CFN_P(o)->bitbag, write_owners );   

    {	Vm_Int i;
	for (i = 0;   i < constants;   ++i) {
	    obj_Export_Subobj( fd, CFN_P(o)->vec[i], write_owners );
    }	}

    /* Print disassembly of the code: */
    {	Vm_Int n   = cfn_Bytes_Of_Code(o);
	Vm_Uch*t   = (Vm_Uch*) &CFN_P(o)->vec[ constants ];
	Vm_Uch buf[ 100000 ];
	asm_Sprint_Code_Disassembly( buf,buf+100000, t, t+n );
	fputs( buf, fd );
    }
    fputc( '\n', fd );
}




/************************************************************************/
/*-    --- Standard static fns ---					*/
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
