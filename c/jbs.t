@example  @c
/*--   jbs.c -- Job SeT objects for Muq.				*/
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
/*-    Quote								*/
/************************************************************************/

/************************************************************************/
/*									*/
/*									*/
/*		Those who do not understand Unix			*/
/*		are condemned to reinvent it, poorly.			*/
/*									*/
/*                                            -- Henry Spencer		*/
/*									*/
/************************************************************************/

/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/************************************************************************/
/*

Our jbs class is modelled directly on BSD's process-group data
structure.  A muq jbs represents a set of related jobs, such as a
pipeline running in foreground or background.  Jbss (and ssns) exist
largely in order to implement job control.

The central jobset properties are:
  ~session  session to which jobset belongs.
  ~leader   job which is logical leader of set.
   <ints>   all jobs in set, filed under pid.

 ************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Concise access to user record: */
#undef  U
#define U(o) JBS_P(o)



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

#if MUQ_DEBUG
static Vm_Int   invariants(FILE*,char*,Vm_Obj);
#endif

static void     for_new(      Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_jbs(   Vm_Unt );
#ifdef OLD
static Vm_Int   jbs_is_empty( Vm_Obj );
#endif

static Vm_Obj	jbs_jobset_leader(    Vm_Obj         );
static Vm_Obj	jbs_session(          Vm_Obj         );
static Vm_Obj	jbs_job_queue(        Vm_Obj         );
static Vm_Obj	jbs_set_jobset_leader(Vm_Obj, Vm_Obj );
static Vm_Obj	jbs_set_job_queue(    Vm_Obj, Vm_Obj );
static Vm_Obj	jbs_set_session(      Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property jbs_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"jobQueue"      , jbs_job_queue      , jbs_set_job_queue	},
    {0,"jobsetLeader"  , jbs_jobset_leader  , jbs_set_jobset_leader	},
    {0,"session"        , jbs_session	     , jbs_set_session		},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class jbs_Hardcoded_Class = {
    OBJ_FROM_BYT3('j','b','s'),
    "JobSet",
    sizeof_jbs,
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
    { jbs_system_properties, jbs_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void jbs_doTypes(void){}
Obj_A_Module_Summary jbs_Module_Summary = {
   "jbs",
    jbs_doTypes,
    jbs_Startup,
    jbs_Linkup,
    jbs_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    jbs_Startup -- start-of-world stuff.				*/
/************************************************************************/

void jbs_Startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    job_Startup();
    obj_Startup();
}



/************************************************************************/
/*-    jbs_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void jbs_Linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    jbs_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void jbs_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}


#ifdef OLD

/************************************************************************/
/*-    jbs_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj jbs_Import(
    FILE* fd
) {
    MUQ_FATAL ("jbs_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    jbs_Export -- Write object into textfile.			*/
/************************************************************************/

void jbs_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("jbs_Export unimplemented");
}


#endif

/************************************************************************/
/*-    jbs_Invariants -- Sanity check on jbs.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int jbs_Invariants (
    FILE* errlog,
    char* title,
    Vm_Obj jbs
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, jbs );
#endif
    return errs;
}



/************************************************************************/
/*-    jbs_Del -- Delete given job from jobset.				*/
/************************************************************************/

#ifdef OLD
void
jbs_Del(
    Vm_Obj jbs,
    Vm_Obj pid
) {
    /* Find job: */
    Vm_Obj job = OBJ_GET( jbs, pid, OBJ_PROP_PUBLIC );
    if (job == OBJ_NOT_FOUND)   return;

    /* Remove job: */
    OBJ_DEL( jbs, pid, OBJ_PROP_PUBLIC );

    /* If job was jobset leader, we could nuke  */
    /* leader pointer, to let garbage collector */
    /* recycle it, but this could result in two */
    /* jobsets with same id in session, which   */
    /* seems a dubious concept.  So we don't.   */

    /* If that was last job in jobset, we can   */
    /* remove jobset from its session:          */
    if (jbs_is_empty( jbs )) {
	Vm_Obj leader  = JBS_P(jbs)->jobset_leader;
	Vm_Obj pid     = JOB_P(leader)->pid;
	Vm_Obj session = JBS_P(jbs)->session;
	ssn_Del( session, pid );
    }
}
#else
void
jbs_Del(
    Vm_Obj jbs,
    Vm_Obj job
) {
    Vm_Obj joq;
    Vm_Obj leader;
    Vm_Obj session;
    {   Jbs_P j = JBS_P(jbs);
	joq     = j->job_queue;
	leader  = j->jobset_leader;
	session = j->session;
    }

    /* Remove job from jobset's jobqueue:: */
    joq_Unlink( job, JOB_QUEUE_JOBSET );

    #ifdef MAYBE_POOR_IDEA
    /* This clobbers jobset pid */
    /* reporting in [root-]pj:  */
    /* If job was jobset leader, we nuke  */
    /* leader pointer, to let garbage     */
    /* collector recycle it:              */
    if (job == leader) {
	JBS_P(jbs)->jobset_leader = OBJ_FROM_INT(0);
    }
    #endif

    /* If that was last job in jobset, we can   */
    /* remove jobset from its session:          */
    {   Vm_Obj next = JOQ_P(joq)->link.next.o;
        if (!OBJ_IS_OBJ(next) || !OBJ_IS_CLASS_JOB(next)) {
	    Vm_Obj session = JBS_P(jbs)->session;
	    ssn_Del( session, jbs );
    }   }
}
#endif




/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new jbs object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Vm_Obj joq = obj_Alloc( OBJ_CLASS_A_JOQ, 0 );
    {   Jbs_P  jbs	    = JBS_P(o);
	jbs->jobset_leader  = OBJ_FROM_INT(0);
	jbs->job_queue      = joq;
	jbs->session        = OBJ_FROM_INT(0);
	jbs->next_jobset    = o;
	jbs->prev_jobset    = o;
	{   int i;
	    for (i = JBS_RESERVED_SLOTS;  i --> 0; ) jbs->reserved_slot[i] = OBJ_FROM_INT(0);
	}
	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int invariants(
    FILE* f,
    char* t,
    Vm_Obj jbs
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif





/************************************************************************/
/*-    --- static property fns ---					*/
/************************************************************************/



/************************************************************************/
/*-    jbs_jobset_leader              					*/
/************************************************************************/

static Vm_Obj jbs_jobset_leader(
    Vm_Obj o
) {
/*buggo*/
    return U(o)->jobset_leader;
}



/************************************************************************/
/*-    jbs_job_queue             					*/
/************************************************************************/

static Vm_Obj
jbs_job_queue(
    Vm_Obj o
) {
    return JBS_P(o)->job_queue;
}

/************************************************************************/
/*-    jbs_session	              					*/
/************************************************************************/

static Vm_Obj jbs_session(
    Vm_Obj o
) {
/*buggo*/
    return U(o)->session;
}



/************************************************************************/
/*-    jbs_set_jobset_leader           					*/
/************************************************************************/

static Vm_Obj jbs_set_jobset_leader(
    Vm_Obj o,
    Vm_Obj v
) {
/*buggo*/
    U(o)->jobset_leader = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    jbs_set_job_queue             					*/
/************************************************************************/

static Vm_Obj
jbs_set_job_queue(
    Vm_Obj o,
    Vm_Obj v
) {
#ifdef MAYBE_SOMEDAY
    /* Not sure whether we should allow this: */
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_JOQ(v)) {
        JBS_P(o)->job_queue = v;
        vm_Dirty(o);
    }
#endif

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    jbs_set_session	             					*/
/************************************************************************/

static Vm_Obj
jbs_set_session(
    Vm_Obj o,
    Vm_Obj v
) {
/*buggo*/
    U(o)->session = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    sizeof_jbs -- Return size of user object.			*/
/************************************************************************/

static Vm_Unt
sizeof_jbs(
    Vm_Unt size
) {
    return sizeof( Jbs_A_Header );
}



/************************************************************************/
/*-    jbs_is_empty -- Return TRUE iff no jobs left in jobset.		*/
/************************************************************************/

#ifdef OLD
static Vm_Int
jbs_is_empty(
    Vm_Obj jbs
) {
    Vm_Obj first_job_pid = OBJ_NEXT( jbs, OBJ_FROM_INT(-1), OBJ_PROP_PUBLIC );
    return !OBJ_IS_INT( first_job_pid );
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
