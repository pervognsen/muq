@example  @c
/*--   lok.c -- binary semaphores (LOcKs) for Muq.			*/
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
/* Created:      94Nov19 +- a couple.					*/
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
/*-    Epigram.								*/
/************************************************************************/

/* "No boom today.  Boom tomorrow.  There's *always* a boom tomorrow."	*/
/* -- Lieut-Cmdr. Susan Ivanova, second in command of Babylon 5.	*/


/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/************************************************************************


 ************************************************************************/

/************************************************************************/
/*-    To-do?								*/
/************************************************************************/

/* Apparently some problems in the last Mars lander were traced to	*/
/* a situation in which a low-priority task wound up holding a lock	*/
/* needed by a high-priority task, but was effectively stalled by	*/
/* a long-running medium-priority task.  This was reportedly studied	*/
/* years ago under the rubric "priority inversion", with the solution	*/
/* being to have jobs inherit the priority of jobs waiting on locks	*/
/* which they hold. (Got that? :)  Might be worth implementing for	*/
/* Muq locks at some point?						*/




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

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_lok( Vm_Unt );

static Vm_Obj	lok_held_by(	  Vm_Obj         );
static Vm_Obj	lok_set_held_by(  Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property lok_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"heldBy", lok_held_by	, lok_set_held_by },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class lok_Hardcoded_Class = {
    OBJ_FROM_BYT3('l','o','k'),
    "Lock",
    sizeof_lok,
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
    { lok_system_properties, lok_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void lok_doTypes(void){}
Obj_A_Module_Summary lok_Module_Summary = {
   "lok",
    lok_doTypes,
    lok_Startup,
    lok_Linkup,
    lok_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    lok_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
lok_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    lok_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
lok_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    lok_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
lok_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    lok_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
lok_Import(
    FILE* fd
) {
    MUQ_FATAL ("lok_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    lok_Export -- Write object into textfile.			*/
/************************************************************************/

void
lok_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("lok_Export unimplemented");
}


#endif


/************************************************************************/
/*-    lok_Release-- Mark lock as free, wake any queued jobs.		*/
/************************************************************************/

void
lok_Release(
    Vm_Obj lok
) {
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(lok)
    ||  !OBJ_IS_CLASS_LOK(lok)
    ){
	MUQ_FATAL ("job_release_lock: needed lock!");
    }
    #endif
    
    {   Vm_Obj joq;

	/* Mark lock as free: */
	{   Lok_P l    = LOK_P(lok);
	    l->held_by = OBJ_NIL;
	    joq        = l->job_queue;
	    vm_Dirty(lok);
	}

	/* If it has a valid jobqueue: */
	if (joq != OBJ_FROM_INT(0)) {	

	    /* Run any jobs waiting on semaphore: */
            joq_Run_Queue( joq );
	}
    }
}

/************************************************************************/
/*-    lok_Maybe_SendSleep_Job -- Sleep job if given lock is taken.	*/
/************************************************************************/

Vm_Obj
lok_Maybe_SendSleep_Job(
    Vm_Obj     obj,
    Vm_Obj     op /* Either JOB_STACKFRAME_LOCK or JOB_STACKFRAME_LOCK_CHILD */
) {
    Lok_P      q  = LOK_P( obj );

    Vm_Obj held_by= q->held_by;

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(obj) || !OBJ_IS_CLASS_LOK(obj)) {
	MUQ_FATAL ("Needed lok!4");
    }
    #endif

    /* If we already own lock, return, */
    /* remembering that we should push */
    /* a NULL rather than LOCK frame:  */
    if (held_by == job_RunState.job) {
        return JOB_STACKFRAME_NULL;
    }

    /* If lock is taken, put current job to sleep: */
    if (held_by != OBJ_NIL) {

	/* Create job_queue if it doesn't exist: */
	Vm_Obj joq = q->job_queue;
	if (joq == OBJ_FROM_INT(0)) {
	    joq = joq_Alloc(obj,OBJ_FROM_BYT3('o','u','t'));/*Create joq.    */
	    q   = LOK_P( obj );		                    /*May have moved.*/
	    q->job_queue = joq;
	    vm_Dirty(obj);
	}

	/* Move current job to job queue, */
        /* then switch to next job:       */
        joq_Requeue( joq, job_RunState.job );
	job_End_Timeslice();	/* Doesn't return. */
    }

    return op;
}



/************************************************************************/
/*-    lok_Reset -- Reset to empty					*/
/************************************************************************/

void
lok_Reset(
    Vm_Obj lok
) {
}







/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new lok object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    {   Lok_P s 	= LOK_P(o);
	s->held_by	= OBJ_NIL;
	s->job_queue	= OBJ_FROM_INT( 0 );

	{   int i;
	    for (i = LOK_RESERVED_SLOTS;  i --> 0; ) s->reserved_slot[i] = OBJ_FROM_INT(0);
	}

	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_lok -- Return size of lock.				*/
/************************************************************************/

static Vm_Unt
sizeof_lok(
    Vm_Unt size
) {
    return sizeof( Lok_A_Header );
}





/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    lok_held_by							*/
/************************************************************************/

static Vm_Obj
lok_held_by(
    Vm_Obj o
) {
    return LOK_P(o)->held_by;
}



/************************************************************************/
/*-    lok_set_held_by             					*/
/************************************************************************/

static Vm_Obj
lok_set_held_by(
    Vm_Obj o,
    Vm_Obj v
) {
    /* LOK(o)->held_by = v; */
    /* vm_Dirty(o);         */

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



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
