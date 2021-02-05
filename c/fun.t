@example  @c
/* buggo: Need to add 'compiled-by' field to fn. */


/*--   fun.c -- FUNction objects for Muq.				*/
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

static Vm_Unt   sizeof_fun( Vm_Unt );
static void     for_new(    Vm_Obj, Vm_Unt );

static Vm_Obj	fun_arity(          	    Vm_Obj  );
static Vm_Obj	fun_compiler(       	    Vm_Obj  );
static Vm_Obj	fun_executable(     	    Vm_Obj  );
static Vm_Obj	fun_source(         	    Vm_Obj  );
static Vm_Obj	fun_file_name(      	    Vm_Obj  );
static Vm_Obj	fun_line_numbers(   	    Vm_Obj  );
static Vm_Obj	fun_fn_line(      	    Vm_Obj  );
static Vm_Obj	fun_local_variable_names(   Vm_Obj  );
static Vm_Obj	fun_specialized_parameters( Vm_Obj  );
static Vm_Obj	fun_default_methods(        Vm_Obj  );

static Vm_Obj	fun_set_default_methods(       Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_specialized_parameters(Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_local_variable_names(  Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_arity(                 Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_compiler(              Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_executable(            Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_file_name(             Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_line_numbers(          Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_fn_line(               Vm_Obj, Vm_Obj );
static Vm_Obj	fun_set_source(                Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property fun_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"arity"         , fun_arity          , fun_set_arity		},
    {0,"compiler"      , fun_compiler       , fun_set_compiler		},
    {0,"defaultMethods", fun_default_methods, fun_set_default_methods	},
    {0,"executable"    , fun_executable     , fun_set_executable	},
    {0,"fileName"      , fun_file_name      , fun_set_file_name	},
    {0,"fnLine"        , fun_fn_line        , fun_set_fn_line		},
    {0,"lineNumbers"   , fun_line_numbers   , fun_set_line_numbers	},
    {0,"localVariableNames", fun_local_variable_names, fun_set_local_variable_names	},
    {0,"source"         , fun_source         , fun_set_source		},
    {0,"specializedParameters", fun_specialized_parameters, fun_set_specialized_parameters},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class fun_Hardcoded_Class = {
    OBJ_FROM_BYT3('f','u','n'),
    "Function",
    sizeof_fun,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { fun_system_properties, fun_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void fun_doTypes(void){}
Obj_A_Module_Summary fun_Module_Summary = {
   "fun",
    fun_doTypes,
    fun_Startup,
    fun_Linkup,
    fun_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    fun_Startup -- start-of-world stuff.				*/
/************************************************************************/

void fun_Startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    fun_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void fun_Linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    fun_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void fun_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}


#ifdef OLD

/************************************************************************/
/*-    fun_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj fun_Import(
    FILE* fd
) {
    MUQ_FATAL ("fun_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    fun_Export -- Write object into textfile.			*/
/************************************************************************/

void fun_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("fun_Export unimplemented");
}


#endif

/************************************************************************/
/*-    fun_Invariants -- Sanity check on fn.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int fun_Invariants (
    FILE* errlog,
    char* title,
    Vm_Obj fn
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, fn );
#endif
    return errs;
}



/************************************************************************/
/*-    fun_Sprint -- Debug dump of fn state.				*/
/************************************************************************/

Vm_Uch*
fun_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  fn
) {
    buf = lib_Sprint( buf,lim, "source: "            );
    buf = stg_Sprint( buf,lim, FUN_P(fn)->source     );
    buf = lib_Sprint( buf,lim, "\nconstants:\n"      );
    buf = cfn_Sprint( buf,lim, FUN_P(fn)->executable );
    buf = lib_Sprint( buf,lim, "code bytes:"         );

    {   Vm_Obj x   = FUN_P(fn)->executable;
    /*	Vm_Unt len = vm_Len(x); */
	Cfn_P  p   = CFN_P(x);
	Vm_Uch*t   = (Vm_Uch*) &p->vec[ CFN_CONSTS(p->bitbag) ];
	Vm_Int u;

	Vm_Int n = cfn_Bytes_Of_Code(x);
	for   (u = 0;   u < n;   ++u) {
	    if (!(u & 0xF))   buf = lib_Sprint(buf,lim, "\n%02x:", (int)u  );
	    buf                   = lib_Sprint(buf,lim, " %02x", (int)(t[u]) );
	}
	buf = lib_Sprint( buf,lim, "\n" );

	/* Disassemble code as well: */
	buf = lib_Sprint( buf,lim, "code disassembly:\n" );
	buf = asm_Sprint_Code_Disassembly( buf,lim, t, t+n );
    }
    buf = lib_Sprint( buf,lim, "\n" );
    return buf;
}

/************************************************************************/
/*-    fun_Type -- Vm_Int->Vm_Uch* mapping: "NORMAL" etc.		*/
/************************************************************************/

Vm_Uch*
fun_Type(
    Vm_Int typ
) {
    static Vm_Uch* table[11] = {
        "NORMAL",
        "EXIT",
        "BRANCH",
        "OTHER",
        "CALLI",
        "CALL",
        "START_BLOCK",
        "END_BLOCK",
        "EAT_BLOCK",
        "CALLA",
        "CALL_METHOD"
    };
    if ((Vm_Unt)typ >= 11) MUQ_FATAL ("fun_Type");
    return table[typ];
}


/************************************************************************/
/*-    fun_TypeName -- Vm_Int->Vm_Uch* mapping: "?" etc.		*/
/************************************************************************/

Vm_Uch*
fun_TypeName(
    Vm_Int typ
) {
    static Vm_Uch* table[10] = {
        "",
        " ?",
        " >",
        " x",
        " CALLI",
        " CALL",
        " [",
        " |",
        " ]",
        " CALLA"
    };
    if ((Vm_Unt)typ >= 10) MUQ_FATAL ("fun_TypeName");
    return table[typ];
}




/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int invariants(
    FILE* f,
    char* t,
    Vm_Obj fn
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif



/************************************************************************/
/*-    for_new -- Initialize new fun.					*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Vm_Obj source =  stg_From_Asciz("");
    Fun_P p  = FUN_P(o);

    p->source                 = source;
    p->compiler               = OBJ_NIL;
    p->file_name              = OBJ_FROM_BYT0;
    p->fn_line                = OBJ_FROM_INT(0);

    p->line_numbers           = OBJ_NIL;
    p->local_variable_names   = OBJ_NIL;

    p->specialized_parameters = OBJ_NIL;
    p->default_methods	      = OBJ_NIL;

    p->executable             = obj_Etc_Bad;
    p->arity                  = OBJ_FROM_INT(0);

    {   int i;
	for (i = FUN_RESERVED_SLOTS;  i --> 0; ) p->reserved_slot[i] = OBJ_FROM_INT(0);
    }

    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_fun -- Return size of generic object.			*/
/************************************************************************/

static Vm_Unt
sizeof_fun(
    Vm_Unt size
) {
    return sizeof( Fun_A_Header );
}






/************************************************************************/
/*-    --- Static propfns --						*/
/************************************************************************/


/************************************************************************/
/*-    fun_arity	              					*/
/************************************************************************/

static Vm_Obj
fun_arity(
    Vm_Obj o
) {
    return FUN_P(o)->arity;
}



/************************************************************************/
/*-    fun_compiler	              					*/
/************************************************************************/

static Vm_Obj
fun_compiler(
    Vm_Obj o
) {
    return FUN_P(o)->compiler;
}



/************************************************************************/
/*-    fun_executable	              					*/
/************************************************************************/

static Vm_Obj
fun_executable(
    Vm_Obj o
) {
    return FUN_P(o)->executable;
}



/************************************************************************/
/*-    fun_file_name	              					*/
/************************************************************************/

static Vm_Obj
fun_file_name(
    Vm_Obj o
) {
    return FUN_P(o)->file_name;
}



/************************************************************************/
/*-    fun_fn_line	              					*/
/************************************************************************/

static Vm_Obj
fun_fn_line(
    Vm_Obj o
) {
    return FUN_P(o)->fn_line;
}



/************************************************************************/
/*-    fun_line_numbers	              					*/
/************************************************************************/

static Vm_Obj
fun_line_numbers(
    Vm_Obj o
) {
    return FUN_P(o)->line_numbers;
}



/************************************************************************/
/*-    fun_local_variable_names        					*/
/************************************************************************/

static Vm_Obj
fun_local_variable_names(
    Vm_Obj o
) {
    return FUN_P(o)->local_variable_names;
}



/************************************************************************/
/*-    fun_source	              					*/
/************************************************************************/

static Vm_Obj
fun_source(
    Vm_Obj o
) {
    return FUN_P(o)->source;
}

/************************************************************************/
/*-    fun_specialized_parameters      					*/
/************************************************************************/

static Vm_Obj
fun_specialized_parameters(
    Vm_Obj o
) {
    return FUN_P(o)->specialized_parameters;
}


/************************************************************************/
/*-    fun_default_methods      					*/
/************************************************************************/

static Vm_Obj
fun_default_methods(
    Vm_Obj o
) {
    return FUN_P(o)->default_methods;
}


/************************************************************************/
/*-    fun_set_arity             					*/
/************************************************************************/

static Vm_Obj
fun_set_arity(
    Vm_Obj o,
    Vm_Obj v
) {
    #ifdef MAYBE_SOMEDAY
    FUN_P(o)->arity = v;
    vm_Dirty(o);
    #endif

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    fun_set_compiler             					*/
/************************************************************************/

static Vm_Obj
fun_set_compiler(
    Vm_Obj o,
    Vm_Obj v
) {
    #ifdef MAYBE_SOMEDAY
    FUN_P(o)->compiler = v;
    vm_Dirty(o);
    #endif

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    fun_set_executable             					*/
/************************************************************************/

static Vm_Obj
fun_set_executable(
    Vm_Obj o,
    Vm_Obj v
) {
    FUN_P(o)->executable = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    fun_set_file_name            					*/
/************************************************************************/

static Vm_Obj
fun_set_file_name(
    Vm_Obj o,
    Vm_Obj v
) {
    FUN_P(o)->file_name = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    fun_set_fn_line            					*/
/************************************************************************/

static Vm_Obj
fun_set_fn_line(
    Vm_Obj o,
    Vm_Obj v
) {
    FUN_P(o)->fn_line = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    fun_set_line_numbers            					*/
/************************************************************************/

static Vm_Obj
fun_set_line_numbers(
    Vm_Obj o,
    Vm_Obj v
) {
    #ifdef MAYBE_SOMEDAY
    FUN_P(o)->line_numbers = v;
    vm_Dirty(o);
    #endif

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    fun_set_local_variable_names    					*/
/************************************************************************/

static Vm_Obj
fun_set_local_variable_names(
    Vm_Obj o,
    Vm_Obj v
) {
    #ifdef MAYBE_SOMEDAY
    FUN_P(o)->local_variable_names = v;
    vm_Dirty(o);
    #endif

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    fun_set_source             					*/
/************************************************************************/

static Vm_Obj
fun_set_source(
    Vm_Obj o,
    Vm_Obj v
) {
    FUN_P(o)->source = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    fun_set_specialized_parameters  					*/
/************************************************************************/

static Vm_Obj
fun_set_specialized_parameters(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL || OBJ_IS_INT(v)) {
	FUN_P(o)->specialized_parameters = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    fun_set_default_methods  					*/
/************************************************************************/

static Vm_Obj
fun_set_default_methods(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL || (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_KEY(v))) {
	FUN_P(o)->default_methods = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
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
