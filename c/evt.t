@example  @c
/*--   evt.c -- events for Muq.						*/
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
/* Created:      95Apr02						*/
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
/*     "Writers, like surgeons, must have the courage to cut.		*/
/*     It's a cruel art :)"  -- Jerrold Prothero			*/
/*              (Goes double for hackers! -- Cynbe)			*/
/************************************************************************/


/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/************************************************************************

The stuff in this file is currently just scaffolding to make the
bootstrapping of an empty db run smoothly -- the entire file could
be dropped from a production server concerned only with running
pre-existing dbs.

 ************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Tunable parameters: */

/* Stuff you shouldn't need to fiddle with: */



/************************************************************************/
/*-    Statics								*/
/************************************************************************/



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Table of predefined event types: */
static struct Evt_Predefined_Event_Type {
    Vm_Chr* parent;	/* Parent class of event.           */
    Vm_Chr* name;       /* Standard name for event.         */
    Vm_Chr* parent2;	/* Additional parent event, if any. */
} evt_Predefined_Event_Type[] = {

    { "arithmeticError", "divisionByZero",		NULL },
    { "arithmeticError", "floatingPointOverflow",	NULL },
    { "arithmeticError", "floatingPointUnderflow",	NULL },

    { "cellError", "unboundVariable",		NULL },
    { "cellError", "undefinedFunction",	NULL },

    { "event", "seriousEvent",	NULL },
    { "event", "simpleEvent",	NULL },
    { "event", "warning",		NULL },
    { "event", "printJobs",	NULL },

    { "error", "arithmeticError",	NULL },
    { "error", "cellError",		NULL },
    { "error", "controlError",		NULL },
    { "error", "fileError",		NULL },
    { "error", "packageError",		NULL },
    { "error", "programError",		NULL },
    { "error", "simpleError",		"simpleEvent" },
    { "error", "streamError",		NULL },
    { "error", "typeError",		NULL },

    { "error", "serverError",   	NULL },

    { "seriousEvent", "abort",		NULL },
    { "seriousEvent", "debug",		NULL },
    { "seriousEvent", "error",		NULL },
    { "seriousEvent", "kill",		NULL },
    { "seriousEvent", "storageEvent",	NULL },

    { "streamError", "endOfFile", NULL },

    { "typeError", "simpleTypeError", "simpleEvent" },

    { "warning", "simpleWarning", 		  "simpleEvent" },
    { "warning", "brokenPipeWarning",		  NULL },
    { "warning", "readFromDeadStreamWarning", NULL },
    { "warning", "writeToDeadStreamWarning",  NULL },
    { "warning", "urgentCharacterWarning",	  NULL },

    { NULL, "event", NULL },

    /* End-of-array sentinel: */
    { NULL, NULL, NULL },
};

static void evt_doTypes(void){}
Obj_A_Module_Summary evt_Module_Summary = {
    "evt",
    evt_doTypes,
    evt_Startup,
    evt_Linkup,
    evt_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    evt_Startup -- start-of-world stuff.				*/
/************************************************************************/

 /***********************************************************************/
 /*-   validate_event_dir -- Validate /event			*/
 /***********************************************************************/

static void
validate_event_dir(
    void
){
    struct Evt_Predefined_Event_Type * p;
    struct Evt_Predefined_Event_Type * tab = (
           evt_Predefined_Event_Type
    );

    /* Make sure all named events exist */
    /* and are of the appropriate type:     */
    for (p = tab;   p->name;   ++p) {
	Vm_Obj key = sym_Alloc_Asciz_Keyword(p->name);
	Vm_Obj nam = SYM_P(key)->name;
	Vm_Obj evt = OBJ_GET( obj_Err, key, OBJ_PROP_PUBLIC );
        if (evt==OBJ_NOT_FOUND
	|| !OBJ_IS_OBJ(evt)
#ifdef OLD
	|| !OBJ_IS_CLASS_EVT(evt)
#endif
	){
#ifdef OLD
            evt = obj_Alloc( OBJ_CLASS_A_EVT, 0 );
#else
            evt = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
#endif
	    OBJ_SET( obj_Err, key, evt, OBJ_PROP_PUBLIC );
            OBJ_P(evt)->objname = nam;  vm_Dirty(evt);
    	}
    }

    /* Make sure all named events have */
    /* the specified parents:              */
#ifdef OLD
    for (p = tab;   p->name;   ++p) {
	if (p->parent) {
	    Vm_Obj us_key = sym_Alloc_Asciz_Keyword(p->name);
	    Vm_Obj us     = OBJ_GET( obj_Err, us_key, OBJ_PROP_PUBLIC );
	    Vm_Obj pa_key = sym_Alloc_Asciz_Keyword(p->parent);
	    Vm_Obj pa     = OBJ_GET( obj_Err, pa_key, OBJ_PROP_PUBLIC );
	    if (pa==OBJ_NOT_FOUND
	    || !OBJ_IS_OBJ(pa)
	    || !OBJ_IS_CLASS_EVT(pa)
	    ){
		MUQ_FATAL( "evt:validate_event_dir()/%s", p->parent );
	    }
	    if (p->parent2) {
		Vm_Obj ma_key = sym_Alloc_Asciz_Keyword(p->parent2);
		Vm_Obj ma     = OBJ_GET( obj_Err, ma_key, OBJ_PROP_PUBLIC );
		Vm_Obj vec    = vec_Alloc( 2, OBJ_NIL );
		if (ma==OBJ_NOT_FOUND
		|| !OBJ_IS_OBJ(ma)
		|| !OBJ_IS_CLASS_EVT(ma)
		){
		    MUQ_FATAL( "evt:validate_event_dir()/%s", p->parent2 );
		}
		vec_Set(vec,0,pa);
		vec_Set(vec,1,ma);
		pa = vec;
	    }
	    OBJ_P(us)->parents = pa; vm_Dirty(us);
	}
    }
#endif
}


 /***********************************************************************/
 /*-   validate_lib_muf_do_signal -- Validate /lib/muf/doSignal	*/
 /***********************************************************************/

static Vm_Obj
validate_lib_muf_do_signal(
    void
){
    Vm_Obj cfn;

    /* Guarantee that a symbol is exported for the prim: */
    Vm_Chr*nam = "doSignal";
    Vm_Obj sym = sym_Find_Exported_Asciz( obj_Lib_Muf, nam );
    if (!sym || !OBJ_IS_SYMBOL(sym)) {
	Vm_Obj key = stg_From_Asciz( nam );
	sym = sym_Make();
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_PUBLIC );
	/* All symbols in a package must be  in hidden area; */
	/* In addition, we export by putting in public area: */
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_HIDDEN );
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_PUBLIC );
	{   Sym_P s = SYM_P(sym);
	    s->name    = key;
	    vm_Dirty(sym);
    }   }

    /* With luck, symbol has a compiledFunction as 'function' value: */
    cfn = SYM_P(sym)->function;
    if (OBJ_IS_CFN(cfn)) {
	return sym;
    }
    return OBJ_NIL;
}

 /***********************************************************************/
 /*-   validate_lib_muf_report_event -- Validate /lib/muf/reportEvent	*/
 /***********************************************************************/

static Vm_Obj
validate_lib_muf_report_event(
    void
){
    Vm_Obj cfn;

    /* Guarantee that a symbol is exported for the prim: */
    Vm_Chr*nam = "reportEvent";
    Vm_Obj sym = sym_Find_Exported_Asciz( obj_Lib_Muf, nam );
    if (!sym || !OBJ_IS_SYMBOL(sym)) {
	Vm_Obj key = stg_From_Asciz( nam );
	sym = sym_Make();
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_PUBLIC );
	/* All symbols in a package must be  in hidden area; */
	/* In addition, we export by putting in public area: */
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_HIDDEN );
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_PUBLIC );
	{   Sym_P s = SYM_P(sym);
	    s->name    = key;
	    vm_Dirty(sym);
    }   }

    /* With luck, symbol has a compiledFunction as 'function' value: */
    cfn = SYM_P(sym)->function;
    if (OBJ_IS_CFN(cfn)) {
	return sym;
    }
    return OBJ_NIL;
}


 /***********************************************************************/
 /*-   validate_lib_muf_do_error -- Validate /lib/muf/doError		*/
 /***********************************************************************/

static Vm_Obj
validate_lib_muf_do_error(
    void
){
    Vm_Obj cfn;

    /* Guarantee that a symbol is exported for the prim: */
    Vm_Chr*nam = "doError";
    Vm_Obj sym = sym_Find_Exported_Asciz( obj_Lib_Muf, nam );
    if (!sym || !OBJ_IS_SYMBOL(sym)) {
	Vm_Obj key = stg_From_Asciz( nam );
	sym = sym_Make();
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_PUBLIC );
	/* All symbols in a package must be  in hidden area; */
	/* In addition, we export by putting in public area: */
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_HIDDEN );
	OBJ_SET( obj_Lib_Muf, key, sym, OBJ_PROP_PUBLIC );
	{   Sym_P s = SYM_P(sym);
	    s->name    = key;
	    vm_Dirty(sym);
    }   }

    /* With luck, symbol has a compiledFunction as 'function' value: */
    cfn = SYM_P(sym)->function;
    if (OBJ_IS_CFN(cfn)) {
	return sym;
    }
    return OBJ_NIL;
}


 /***********************************************************************/
 /*-   evt_Startup -- start-of-world stuff.				*/
 /***********************************************************************/

void
evt_Startup(
    void
) {

    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;

    obj_Startup();
    if (!obj_Quick_Start) {
	/* Create .e.warning &tc if missing: */
	validate_event_dir();
    }

    /* Set up a convenient pointer to .e.simpleEvent: */
    obj_Err_Simple_Event = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("simpleEvent"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.simpleError: */
    obj_Err_Simple_Error = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("simpleError"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.event: */
    obj_Err_Event = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("event"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.abort: */
    obj_Err_Abort = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("abort"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.kill: */
    obj_Err_Kill = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("kill"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.serverError: */
    obj_Err_Server_Error = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("serverError"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.seriousEvent: */
    obj_Err_Serious_Event = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("seriousEvent"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.brokenPipeWarning: */
    obj_Err_Broken_Pipe_Warning = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("brokenPipeWarning"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.readFromDeadStreamWarning: */
    obj_Err_Read_From_Dead_Stream_Warning = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("readFromDeadStreamWarning"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.writeToDeadStreamWarning: */
    obj_Err_Write_To_Dead_Stream_Warning = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("writeToDeadStreamWarning"),
	OBJ_PROP_PUBLIC
    );
    /* ... and .e.urgentCharacterWarning: */
    obj_Err_Urgent_Character_Warning = OBJ_GET(
	obj_Err,
	sym_Alloc_Asciz_Keyword("urgentCharacterWarning"),
	OBJ_PROP_PUBLIC
    );

    /******************************************/
    /* Create .lib.muf.]doSignal if missing.  */
    /* in principle, this function could be   */
    /* written in a library to be loaded, but */
    /* it is so fundamental to operation of   */
    /* Muq that I prefer to have it in-db     */
    /* "immediately" upon db creation.        */
    /*                                        */
    /* ]doSignal needs .lib.muf.childOf?      */
    /* which needs .lib.muf.childOf2? so we   */
    /* may need to create those also:         */
    /******************************************/
    {   Vm_Obj o;
	o = validate_lib_muf_do_signal();
	obj_Lib_Muf_Do_Signal = o;
	o = validate_lib_muf_do_error();
	obj_Lib_Muf_Do_Error  = o;
	o = validate_lib_muf_report_event();
	obj_Lib_Muf_Report_Event = o;
    }
}



/************************************************************************/
/*-    evt_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
evt_Linkup(
    void
) {

    static int done_linkup  = FALSE;
    if        (done_linkup)   return;
    done_linkup		    = TRUE;
}



/************************************************************************/
/*-    evt_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
evt_Shutdown(
    void
) {
    static int done_shutdown = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	     = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    evt_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
evt_Import(
    FILE* fd
) {
    MUQ_FATAL ("evt_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    evt_Export -- Write object into textfile.			*/
/************************************************************************/

void
evt_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("evt_Export unimplemented");
}


#endif






/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/





/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    --- Static fns ---						*/
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
