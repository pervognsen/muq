@example  @c
/*--   ssn.c -- SeSsioN objects for Muq.				*/
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
/* Created:      93Oct24						*/
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

Our ssn class is modelled directly on BSD 'session' data structure.  A
muq ssn represents the set of activities engaged in by one user coming
in via one (usually net) connection.  Having ssns as explicit,
discrete structures makes it practical to detatch a session from one
terminal and attach it to another, and serves as a central organizing
structure on which to hang things.

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

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_ssn( Vm_Unt );

static Vm_Obj	ssn_session_leader(       Vm_Obj     );
static Vm_Obj	ssn_skt(                  Vm_Obj     );
static Vm_Obj	ssn_next_jobset(          Vm_Obj     );
static Vm_Obj	ssn_prev_jobset(          Vm_Obj     );
static Vm_Obj	ssn_set_session_leader(   Vm_Obj, Vm_Obj );
static Vm_Obj	ssn_set_skt(              Vm_Obj, Vm_Obj );
static Vm_Obj	ssn_set_never(            Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property ssn_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"nextJobset"      , ssn_next_jobset       , ssn_set_never	     },
    {0,"previousJobset"  , ssn_prev_jobset       , ssn_set_never	     },
    {0,"socket"           , ssn_skt	          , ssn_set_skt		     },
    {0,"sessionLeader"   , ssn_session_leader    , ssn_set_session_leader   },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class ssn_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','s','n'),
    "Session",
    sizeof_ssn,
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
    { ssn_system_properties, ssn_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void ssn_doTypes(void){}
Obj_A_Module_Summary ssn_Module_Summary = {
   "ssn",
    ssn_doTypes,
    ssn_Startup,
    ssn_Linkup,
    ssn_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    ssn_Startup -- start-of-world stuff.				*/
/************************************************************************/

void ssn_Startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    jbs_Startup();
    obj_Startup();
}



/************************************************************************/
/*-    ssn_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void ssn_Linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    ssn_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void ssn_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}


#ifdef OLD

/************************************************************************/
/*-    ssn_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj ssn_Import(
    FILE* fd
) {
    MUQ_FATAL ("ssn_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    ssn_Export -- Write object into textfile.			*/
/************************************************************************/

void ssn_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("ssn_Export unimplemented");
}


#endif

/************************************************************************/
/*-    ssn_Invariants -- Sanity check on ssn.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int ssn_Invariants (
    FILE* errlog,
    char* title,
    Vm_Obj ssn
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, ssn );
#endif
    return errs;
}



/************************************************************************/
/*-    ssn_Del -- Delete given pid from session.			*/
/************************************************************************/

void
ssn_Del(
    Vm_Obj ssn,
    Vm_Obj jbs
) {
#ifdef OLD
    /* Remove jobset: */
    OBJ_DEL( ssn, jbs, OBJ_PROP_PUBLIC );

#else
    ssn_Unlink_Jobset( ssn, jbs );
#endif
}


/************************************************************************/
/*-    ssn_Link_Jobset -- Add given jobset to session.			*/
/************************************************************************/

void
ssn_Link_Jobset(
    Vm_Obj ssn,
    Vm_Obj jbs
) {
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(ssn) || !OBJ_IS_CLASS_SSN(ssn)) MUQ_FATAL("ssn_Link.0");
    if (!OBJ_IS_OBJ(jbs) || !OBJ_IS_CLASS_JBS(jbs)) MUQ_FATAL("ssn_Link.1");
    if (JBS_P(jbs)->session != OBJ_FROM_INT(0)) MUQ_FATAL("ssn_Link.2");
    #endif

    {   Vm_Obj s_next;
	{   Ssn_P s = SSN_P(ssn);

	    s_next  = s->next_jobset;

	    s->next_jobset = jbs;
	    vm_Dirty(ssn);
	}

        #if MUQ_IS_PARANOID
	if (!OBJ_IS_OBJ(s_next))   MUQ_FATAL("ssn_Link.3");
	#endif

	if (OBJ_IS_CLASS_JBS(s_next)) {
	    Jbs_P j        = JBS_P(s_next);
	    j->prev_jobset = jbs;
	    vm_Dirty(s_next);
	} else {
	    Ssn_P s = SSN_P(s_next);

	    #if MUQ_IS_PARANOID
	    if (!OBJ_IS_CLASS_SSN(s_next))   MUQ_FATAL("ssn_Link.4");
	    #endif

	    s->prev_jobset = jbs;
	    vm_Dirty(s_next);
	}

	{   Jbs_P j = JBS_P(jbs);

	    j->next_jobset = s_next;
	    j->prev_jobset = ssn;
	    j->session     = ssn;
	    vm_Dirty(jbs);
	}
    }
}




/************************************************************************/
/*-    ssn_Unlink_Jobset -- Remove given jobset from session.		*/
/************************************************************************/

void
ssn_Unlink_Jobset(
    Vm_Obj ssn,
    Vm_Obj jbs
) {
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(ssn) || !OBJ_IS_CLASS_SSN(ssn)) MUQ_FATAL("ssn_Unlink.0");
    if (!OBJ_IS_OBJ(jbs) || !OBJ_IS_CLASS_JBS(jbs)) MUQ_FATAL("ssn_Unlink.1");
    if (JBS_P(jbs)->session != ssn) MUQ_FATAL("ssn_Unlink.2");
    #endif

    {   Vm_Obj j_next;
	Vm_Obj j_prev;
	{   Jbs_P j = JBS_P(jbs);

	    j_next  = j->next_jobset;
	    j_prev  = j->prev_jobset;

	    j->next_jobset = jbs;
	    j->prev_jobset = jbs;
	    j->session     = OBJ_FROM_INT(0);
	    vm_Dirty(jbs);
	}

        #if MUQ_IS_PARANOID
	if (!OBJ_IS_OBJ(j_next))   MUQ_FATAL("ssn_Unlink.3");
	if (!OBJ_IS_OBJ(j_prev))   MUQ_FATAL("ssn_Unlink.4");
	#endif

	if (OBJ_IS_CLASS_JBS(j_next)) {
	    JBS_P(j_next)->prev_jobset = j_prev;   vm_Dirty(j_next);
	} else {
	    #if MUQ_IS_PARANOID
	    if (!OBJ_IS_CLASS_SSN(j_next))   MUQ_FATAL("ssn_Unlink.5");
	    #endif

	    SSN_P(j_next)->prev_jobset = j_prev;   vm_Dirty(j_next);
	}

	if (OBJ_IS_CLASS_JBS(j_prev)) {
	    JBS_P(j_prev)->next_jobset = j_next;   vm_Dirty(j_prev);
	} else {
	    #if MUQ_IS_PARANOID
	    if (!OBJ_IS_CLASS_SSN(j_prev))   MUQ_FATAL("ssn_Unlink.6");
	    #endif

	    SSN_P(j_prev)->next_jobset = j_next;   vm_Dirty(j_prev);
	}

    }
}




/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new ssn object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    {   Ssn_P  ssn     	        = SSN_P(o);
        ssn->skt		= OBJ_FROM_INT(0);
        ssn->session_leader	= OBJ_FROM_INT(0);
        ssn->next_jobset        = o;
        ssn->prev_jobset        = o;

	{   int i;
	    for (i = SSN_RESERVED_SLOTS;  i --> 0; ) ssn->reserved_slot[i] = OBJ_FROM_INT(0);
	}

        vm_Dirty(o);
    }
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    char* t,
    Vm_Obj ssn
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif




/************************************************************************/
/*-    ssn_skt		              					*/
/************************************************************************/

static Vm_Obj
ssn_skt(
    Vm_Obj o
) {
/*buggo*/
    return SSN_P(o)->skt;
}


/************************************************************************/
/*-    ssn_next_jobset              					*/
/************************************************************************/

static Vm_Obj
ssn_next_jobset(
    Vm_Obj o
) {
    return SSN_P(o)->next_jobset;
}



/************************************************************************/
/*-    ssn_prev_jobset              					*/
/************************************************************************/

static Vm_Obj
ssn_prev_jobset(
    Vm_Obj o
) {
    return SSN_P(o)->prev_jobset;
}



/************************************************************************/
/*-    ssn_session_leader	       					*/
/************************************************************************/

static Vm_Obj
ssn_session_leader(
    Vm_Obj o
) {
    return SSN_P(o)->session_leader;
}



/************************************************************************/
/*-    ssn_set_skt	             					*/
/************************************************************************/

static Vm_Obj
ssn_set_skt(
    Vm_Obj o,
    Vm_Obj v
) {
    SSN_P(o)->skt = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    ssn_set_never		       					*/
/************************************************************************/

static Vm_Obj
ssn_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
/*  SSN_P(o)->session_leader = v; */
/*  vm_Dirty(o); */
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}


/************************************************************************/
/*-    ssn_set_session_leader	       					*/
/************************************************************************/

static Vm_Obj
ssn_set_session_leader(
    Vm_Obj o,
    Vm_Obj v
) {
    SSN_P(o)->session_leader = v;
    vm_Dirty(o);
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    sizeof_ssn -- Return size of object.				*/
/************************************************************************/

static Vm_Unt
sizeof_ssn(
    Vm_Unt size
) {
    return sizeof( Ssn_A_Header );
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
