@example  @c
/*--   joq.c -- JOb Queues for Muq.					*/
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
/* Created:      93Sep04						*/
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
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/


#if MUQ_DEBUG
static Vm_Int   invariants(FILE*,Vm_Uch*,Vm_Obj);
#endif

static void     for_new(     Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_joq(  Vm_Unt );

static Vm_Obj	joq_next(    Vm_Obj );
static Vm_Obj	joq_prev(    Vm_Obj );
static Vm_Obj	joq_part_of( Vm_Obj );
static Vm_Obj	joq_kind(    Vm_Obj );

static Vm_Obj	joq_set_never( Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void joq_doTypes(void){}
Obj_A_Module_Summary joq_Module_Summary = {
   "joq",
    joq_doTypes,
    joq_Startup,
    joq_Linkup,
    joq_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property joq_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"next"    , joq_next	, joq_set_never },
    {0,"previous", joq_prev	, joq_set_never },
    {0,"partOf" , joq_part_of	, joq_set_never },
    {0,"kind"    , joq_kind	, joq_set_never },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class joq_Hardcoded_Class = {
    OBJ_FROM_BYT3('j','o','q'),
    "JobQueue",
    sizeof_joq,
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
    { joq_system_properties, joq_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};



/************************************************************************/
/*-    Overview                          				*/
/************************************************************************/

/************************************************************************


 ************************************************************************/




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    joq_Alloc -- Create and return empty job queue.			*/
/************************************************************************/

Vm_Obj
joq_Alloc(
    Vm_Obj     part_of,
    Vm_Obj     name
) {
    Vm_Obj q = obj_Alloc_In_Dbfile( OBJ_CLASS_A_JOQ, 0, VM_DBFILE(part_of) );
    {   Joq_P j = JOQ_P( q );
	j->o.objname = name;
	j->part_of   = part_of;
	vm_Dirty(q);
    }
/*printf("joq_Alloc(%" VM_X ")...\n",q);*/
    return q;
}



/************************************************************************/
/*-    joq_Dequeue -- Remove 'job' from its queue.			*/
/************************************************************************/

void
joq_Unlink(
    Vm_Obj job,
    Vm_Unt s	/* Slot within job. */
) {
    Joq_A_Link link;

    #if MUQ_IS_PARANOID
    if (s >= (Vm_Unt)JOB_QUEUE_MEMBERSHIP_MAX) MUQ_FATAL ("joq_Unlink");
    #endif

    /* Find objects before and after us in queue. */
    /* Either or both of these may be the queue   */
    /* header vector:                             */
    {   Job_P  j = JOB_P( job );
        link     = j->link[s];
	
	#if MUQ_IS_PARANOID
	if (link.this == OBJ_FROM_INT(0)) MUQ_FATAL ("joq_Unlink2");
	#endif
	j->link[s].this = OBJ_FROM_INT(0);
	vm_Dirty(job);
    }
/* {Vm_Obj joq = link.this;	 */
/* Joq_P j = JOQ_P(joq);	 */
/* switch (j->kind) {	 */
/* case OBJ_FROM_BYT3('r','u','n'):	 */
/* printf("joq_Unlink: itsa RUN queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT3('i','/','o'):	 */
/* printf("joq_Unlink: itsa IO queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT3('p','o','z'):	 */
/* printf("joq_Unlink: itsa POZ queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT3('d','o','z'):	 */
/* printf("joq_Unlink: itsa DOZ queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT3('h','l','t'):	 */
/* printf("joq_Unlink: itsa HLT queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT2('p','s'):	 */
/* printf("joq_Unlink: itsa PS queue\n");	 */
/* break;	 */
/* default:	 */
/* printf("joq_Unlink: kind x=%x\n",(int)j->kind);	 */
/* }}	 */

    /* Do					*/
    /*   next->prev = prev;			*/
    /*   prev->next = next;			*/
    /* This is a bit messy because next/prev	*/
    /* can be either objects or the queue hdr:  */

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ( link.next.o )
    ){
	MUQ_FATAL ("Needed obj");
    }
    if (!OBJ_IS_OBJ( link.prev.o )
    ){
	MUQ_FATAL ("Needed obj");
    }
    #endif

    if (OBJ_IS_CLASS_JOQ( link.next.o )) {
	Joq_P n = JOQ_P(link.next.o);
	n->link.prev = link.prev;
	vm_Dirty(link.next.o);
    } else {

	#if MUQ_IS_PARANOID
	if (!OBJ_IS_CLASS_JOB(link.next.o)
        ){
	    MUQ_FATAL ("Needed job");
	}
	#endif

	{   Vm_Unt i = OBJ_TO_INT( link.next.i );
	    Job_P  n = JOB_P(link.next.o);
	    n->link[i].prev   = link.prev;
	    vm_Dirty(link.next.o);

	    #if MUQ_IS_PARANOID
	    if (i >= JOB_QUEUE_MEMBERSHIP_MAX) MUQ_FATAL ("joq_unlink3");
	    #endif
	}
    }

    if (OBJ_IS_CLASS_JOQ(link.prev.o)) {
	Joq_P p = JOQ_P(link.prev.o);
	p->link.next = link.next;
	vm_Dirty(link.prev.o);
    } else {

	#if MUQ_IS_PARANOID
	if (!OBJ_IS_CLASS_JOB(link.prev.o)
        ){
	    MUQ_FATAL ("Needed job");
	}
	#endif

	{   Vm_Unt i = OBJ_TO_INT( link.prev.i );
	    Job_P p = JOB_P(link.prev.o);
	    p->link[i].next = link.next;
	    vm_Dirty(link.prev.o);

	    #if MUQ_IS_PARANOID
	    if (i >= JOB_QUEUE_MEMBERSHIP_MAX) MUQ_FATAL ("joq_unlink4");
	    #endif
	}
    }
}
void
joq_Dequeue(
    Vm_Obj job
) {
    Vm_Obj this[ JOB_QUEUE_MEMBERSHIP_MAX ];

    /* If 'job' is the currently running job, unpublish it: */
    if (job == job_RunState.job) {
	job_State_Unpublish();
    }

    {   Vm_Int i;
	{   Job_P  j = JOB_P( job );
	    for (i = JOB_QUEUE_MEMBERSHIP_MAX;   i --> JOB_QUEUE_DOZ; ) {
		this[i] = j->link[i].this;
	}   }
	for (i = JOB_QUEUE_MEMBERSHIP_MAX;   i --> JOB_QUEUE_DOZ; ) {
	    if (this[i] != OBJ_FROM_INT(0)) {
		joq_Unlink( job, i );
    }   }   }
}


/************************************************************************/
/*-    joq_Desleep -- Move all appropriate sleeping jobs to /etc/run.	*/
/************************************************************************/

void
joq_Desleep(
    void
) {
    /* Find current time: */
    Vm_Unt now     = OBJ_TO_UNT( jS.now );

    /* Iterate over .etc.doz, waking all */
    /* jobs ths with ths->until_nsec < now: */

    Joq_A_Pointer this;
    Joq_A_Pointer next;
/*int done_header = FALSE;*/
    for (this = JOQ_P( obj_Etc_Doz )->link.next;
        !OBJ_IS_CLASS_JOQ(this.o);
	 this = next
    ){

	/* Fetch this->q_next and this->until_sec: */
	Vm_Unt wake_at;
	Vm_Unt i = OBJ_TO_UNT(this.i);
	#if MUQ_IS_PARANOID
	if (!OBJ_IS_CLASS_JOB( this.o )){
	    MUQ_FATAL ("Needed job");
	}
	if (i >= JOB_QUEUE_MEMBERSHIP_MAX) MUQ_FATAL ("joq_Desleep2");
	#endif
	{   Job_P j  = JOB_P( this.o );
	    wake_at  = OBJ_TO_UNT( j->until_msec );
/*if (!done_header) {*/
/*printf("joq_Desleep/aaa\n");*/
/*done_header = TRUE;*/
/*}*/
/*if (wake_at < now) printf("joq_Desleep/bbb: wake_at %lld now %lld -- %lld OVERDUE\n",wake_at,now,now-wake_at);*/
/*else               printf("joq_Desleep/bbb: wake_at %lld now %lld -- %lld left\n",wake_at,now,wake_at-now);*/
	    next     = j->link[i].next;
	}

	/* If 'this' is to wake before 'now', move it to /etc/run, */
	/* otherwise, since sleep queue is sorted by wake time, no */
	/* point in checking any more jobs:                        */
#ifdef PRODUCTION
	if (wake_at > now) return;
        joq_Run_Job( this.o );
#else
	if (wake_at < now)   joq_Run_Job( this.o );
#endif
	
    }
/*if (done_header)printf("joq_Desleep/zzz\n");*/
}



/************************************************************************/
/*-    joq_Enqueue -- Insert currently unqueued job 'j' into 'q'.	*/
/************************************************************************/

 /***********************************************************************/
 /*-   joq_Link -- Insert currently unqueued job 'j' into 'q', slot 'i' */
 /***********************************************************************/

void
joq_Link(
    Vm_Obj joq,
    Vm_Obj job,
    Vm_Unt i
) {
    /* Do				*/
    /*   p         = joq->prev;		*/
    /*   job->next = joq;		*/
    /*   job->prev = p;			*/
    /*   joq->prev = job;		*/
    /*   p  ->next = job;		*/
    /* This is a bit messy because p	*/
    /* can be either obj or queue hdr:  */

    Vm_Obj        owner;
    Joq_A_Pointer prev;
    Vm_Int        kind;

    #if MUQ_IS_PARANOID
    if (i >= JOB_QUEUE_MEMBERSHIP_MAX) MUQ_FATAL ("joq_Link0");
    #endif

    {   Joq_P q    = JOQ_P( joq );

	prev       = q->link.prev;
	kind       = q->kind     ;

	q->link.prev.o = job            ;
	q->link.prev.i = OBJ_FROM_UNT(i);

	owner      = obj_Owner(joq);

	vm_Dirty( joq )          ;
    }

    {   Job_P j    = JOB_P( job );

        #if MUQ_IS_PARANOID
	if (j->link[JOB_QUEUE_PS].this == OBJ_FROM_INT(0)){
	    MUQ_WARN ("Attempt to requeue dead job.");
	}
	#endif

        #if MUQ_IS_PARANOID
	if (!OBJ_IS_INT(j->link[i].this)) {
	    MUQ_WARN ("Attempt to reuse in-use queue slot.");
	}
	#endif

	j->link[i].prev   = prev;
	j->link[i].next.o = joq;
	j->link[i].next.i = OBJ_FROM_UNT(0);
	j->link[i].this   = joq;
	vm_Dirty( job );
    }

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(prev.o)
    ){
	MUQ_FATAL ("Needed obj");
    }
    #endif

    if (OBJ_IS_CLASS_JOQ(prev.o)) {

	Joq_P q = JOQ_P(prev.o);
	q->link.next.o = job;
	q->link.next.i = OBJ_FROM_UNT(i);
	vm_Dirty(prev.o);

    } else {

    /*   p         = joq->prev;		*/
    /*   p  ->next = job;		*/

        #if MUQ_IS_PARANOID
	if (!OBJ_IS_CLASS_JOB(prev.o)
	){
	    MUQ_FATAL ("Needed job");
	}
	#endif
        {   Vm_Unt pi  = OBJ_TO_UNT( prev.i );
            Job_P  j   = JOB_P(      prev.o );
	    j->link[pi].next.o = job;
	    j->link[pi].next.i = OBJ_FROM_UNT(i);
	    vm_Dirty(   prev.o );
    }   }

    /* Each time we enter a job into a run queue, */
    /* if the owner isn't in the user queue, put  */
    /* it there:                                  */
/* switch (kind) {	 */
/* case OBJ_FROM_BYT3('r','u','n'):	 */
/* printf("joq_Link: itsa RUN queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT3('i','/','o'):	 */
/* printf("joq_Link: itsa IO queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT3('p','o','z'):	 */
/* printf("joq_Link: itsa POZ queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT3('d','o','z'):	 */
/* printf("joq_Link: itsa DOZ queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT3('h','l','t'):	 */
/* printf("joq_Link: itsa HLT queue\n");	 */
/* break;	 */
/* case OBJ_FROM_BYT2('p','s'):	 */
/* printf("joq_Link: itsa PS queue\n");	 */
/* break;	 */
/* default:	 */
/* printf("joq_Link: kind x=%x\n",(int)kind);	 */
/* }	 */
    if (kind == OBJ_FROM_BYT3('r','u','n')) {
	if (USR_P(owner)->next == OBJ_FROM_INT(0)) {
	    usq_Enqueue( owner );
	}
    }
}

 /***********************************************************************/
 /*-   joq_Enqueue -- Insert currently unqueued job 'j' into 'q'.	*/
 /***********************************************************************/

void
joq_Enqueue(
    Vm_Obj joq,
    Vm_Obj job
) {
/* printf("joq_Enqueue(%" VM_X " -> %" VM_X ")\n",job,joq); */

    {   Job_P j = JOB_P( job );
	Vm_Unt i;
	for(i = JOB_QUEUE_MEMBERSHIP_MIN;
	    i < JOB_QUEUE_MEMBERSHIP_MAX;
	    i++
	){
	    if (j->link[i].this == OBJ_FROM_INT(0)) {
		joq_Link( joq, job, i );
	        return;
    }	}   }

    MUQ_WARN (
	"Job cannot be in more than %d joq queues",
	(int)(JOB_QUEUE_MEMBERSHIP_MAX - JOB_QUEUE_MEMBERSHIP_MIN)
    );
}


/************************************************************************/
/*-    joq_Ensleep -- Set wake time, then Resleep() 'job'.		*/
/************************************************************************/

void
joq_Ensleep(
    Vm_Obj job,
    Vm_Int secs
) {
    /* Figure time at which to wake 'job': */
    Vm_Int now     = job_Now();
    Vm_Int wake_at = now + secs;

    /* Save it in 'job': */
    {   JOB_P(job)->until_msec = OBJ_FROM_UNT( wake_at );
	vm_Dirty(job);
    }

    joq_Resleep( job );
}



/************************************************************************/
/*-    joq_Resleep -- Insert currently unqueued 'job' into /etc/doz.	*/
/************************************************************************/

void
joq_Resleep(
    Vm_Obj job
) {
    Vm_Int wake_at = OBJ_TO_UNT( JOB_P(job)->until_msec );

    /* Find correct place to insert ourself in sleep queue: */
    Vm_Int prv_w_a = (Vm_Int) (((Vm_Unt)~0) >> 1);	/* wake_at=MAX_INT; */
    Joq_A_Pointer next = JOQ_P(obj_Etc_Doz)->link.next;
    Joq_A_Pointer prev; prev.o = obj_Etc_Doz; prev.i = OBJ_FROM_INT(0);
    while (OBJ_IS_CLASS_JOB( next.o )) {

	/* Fetch nxt->q_next and nxt->q_until: */
	Vm_Int nxt_w_a;
	Joq_A_Pointer nxt_nxt;
	{   Vm_Unt i = OBJ_TO_UNT( next.i );
	    Job_P  j = JOB_P(      next.o );
	    nxt_w_a  = OBJ_TO_INT( j->until_msec );
	    nxt_nxt  =             j->link[i].next;
	}

	/* If we are to wake after 'prv', */
	/* we've found the spot at which  */
	/* to insert ourself:	      */
	if (wake_at > prv_w_a)   break;

	#if MUQ_IS_PARANOID
	if (!OBJ_IS_OBJ(      next.o)
	||  !OBJ_IS_CLASS_JOB(next.o)
	){
	    MUQ_FATAL ("Needed job");
	}
	#endif

	/* Move one step around queue: */
	prev    = next;	    
	prv_w_a = nxt_w_a;	    
	next    = nxt_nxt;
    }

    /************************************************/
    /* At this point, 'prev' and 'next' are the two */
    /* objects between which we should insert	    */
    /* ourself.  Either or both may be the queue    */
    /* header.  We need to do:			    */
    /*   prev->next = job;			    */
    /*   next->prev = job;			    */
    /*   job ->next = nxt;			    */
    /*   job ->prev = prv;			    */
    /************************************************/
    #undef I
    #define I(i) OBJ_TO_UNT(i)
    if (OBJ_IS_CLASS_JOQ(prev.o)) {
	Joq_P    j = JOQ_P(prev.o);
	Joq_Link l = &j->link;
	l->next.o  = job;
	l->next.i  = OBJ_FROM_UNT( JOB_QUEUE_DOZ );
	vm_Dirty(prev.o);
    } else {
	Job_P    j = JOB_P(prev.o);
	Joq_Link l = &j->link[ I(prev.i) ];
	l->next.o  = job;
	l->next.i  = OBJ_FROM_UNT( JOB_QUEUE_DOZ );
	vm_Dirty(prev.o);

	#if MUQ_IS_PARANOID
	if (!OBJ_IS_OBJ(      prev.o)
	||  !OBJ_IS_CLASS_JOB(prev.o)
	){
	    MUQ_FATAL ("Needed job");
	}
	#endif
    }
    if (OBJ_IS_CLASS_JOQ(next.o)) {
	Joq_P    j = JOQ_P(next.o);
	Joq_Link l = &j->link;
	l->prev.o  = job;
	l->prev.i  = OBJ_FROM_UNT( JOB_QUEUE_DOZ );
	vm_Dirty(next.o);
    } else {
	Job_P    j =       JOB_P(next.o);
	Joq_Link l = &j->link[ I(next.i) ];
	l->prev.o  = job;
	l->prev.i  = OBJ_FROM_UNT( JOB_QUEUE_DOZ );
	vm_Dirty(next.o);

	#if MUQ_IS_PARANOID
	if (!OBJ_IS_OBJ(      next.o)
	||  !OBJ_IS_CLASS_JOB(next.o)
	){
	    MUQ_FATAL ("Needed job");
	}
	#endif
    }
    {   Job_P j   = JOB_P( job );
	Joq_Link l = &j->link[ JOB_QUEUE_DOZ ];
	l->next = next;
	l->prev = prev;
	l->this = obj_Etc_Doz;
	vm_Dirty(job);
    }
}



/************************************************************************/
/*-    joq_Is_A_Joq -- TRUE iff 'joq' is a 4-vector.			*/
/************************************************************************/

Vm_Int
joq_Is_A_Joq(
    Vm_Obj joq
) {
    return     OBJ_IS_OBJ(joq)   &&   OBJ_IS_CLASS_JOQ(joq);
}



/************************************************************************/
/*-    joq_Requeue -- Move 'job' to 'queue'.				*/
/************************************************************************/

void
joq_Requeue(
    Vm_Obj queue,
    Vm_Obj job
) {
    joq_Dequeue(        job );
    joq_Enqueue( queue, job );
}



/************************************************************************/
/*-    joq_Reset -- Reset queue to empty.				*/
/************************************************************************/

void
joq_Reset(
    Vm_Obj o
) {
    {   Joq_P s 	= JOQ_P(o);
	s->link.next.o	= o;
	s->link.next.i	= OBJ_FROM_INT(0);
	s->link.prev.o	= o;
	s->link.prev.i	= OBJ_FROM_INT(0);
	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    joq_Pause_Job -- Move given job to pauseQueue.			*/
/************************************************************************/

void
joq_Pause_Job(
    Vm_Obj job
) {
    /* Move job to pause queue: */
    Vm_Obj usr = JOB_P(job)->owner;
    Vm_Obj q   = USR_P(usr)->pause_q;
    joq_Requeue( q, job );
}

/************************************************************************/
/*-    joq_Run_Job -- Schedule given job to run.			*/
/************************************************************************/

void
joq_Run_Job(
    Vm_Obj job
) {
    /* Move job to run queue: */
    Vm_Unt priority;
    Vm_Obj usr;
    Vm_Obj q;
    {   Job_P j  = JOB_P(job);
	usr      = j->owner;
	priority = OBJ_TO_INT( j->priority );
	/* If job was in a |readAnyStreamPacket */
	/* wait, mark it as no longer being so:    */
	if (j->doing_promiscuous_read == OBJ_FROM_INT(1)) {
	    j->doing_promiscuous_read =  OBJ_FROM_INT(0);
	    vm_Dirty(job);
	}
    }
    #if MUQ_IS_PARANOID
    if (priority >= JOB_PRIORITY_LEVELS)   MUQ_FATAL ("joq_Run_Job");
    #endif
    q = USR_P(usr)->run_q[ priority ];
    joq_Requeue( q, job );
}

/************************************************************************/
/*-    joq_Run_Queue -- Empty given queue into run queue.		*/
/************************************************************************/

void
joq_Run_Queue(
    Vm_Obj joq
) {
    /* Over all jobs in 'queue': */
    Joq_A_Pointer this;
    Joq_A_Pointer next;
    for (
	/* The correctness of this depends on */
	/* our never allowing the same job in */
	/* the same queue more than once:     */
	this = JOQ_P(joq)->link.next;
	OBJ_IS_CLASS_JOB(this.o);
        this = next
    ){
	Vm_Obj job = this.o;
	Job_P  j   = JOB_P(job);
	Vm_Int i   = OBJ_TO_INT(this.i);
        next       = j->link[i].next;

	/* Move job to run queue: */
	joq_Run_Job( job );
    }

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_CLASS_JOQ(this.o)) MUQ_FATAL("Bad joq");
    #endif
}

/************************************************************************/
/*-    joq_Run_Message_Stream_Read_Queue -- 				*/
/************************************************************************/

void
joq_Run_Message_Stream_Read_Queue(
    Vm_Obj joq,
    Vm_Obj mss
) {
    /*************************************/
    /* This is just like joq_Run_Queue() */
    /* except that we have the extra mss */
    /* argument and must do specialCase */
    /* stuff for |readAnyStreamPacket */
    /* jobs:                             */
    /*************************************/

    /* Over all jobs in 'queue': */
    Joq_A_Pointer this;
    Joq_A_Pointer next;
    for (
	this = JOQ_P(joq)->link.next;
	OBJ_IS_CLASS_JOB(this.o);
        this = next
    ){
	Vm_Obj job = this.o;
	Job_P  j   = JOB_P(job);
	Vm_Int i   = OBJ_TO_INT(this.i);
        next       = j->link[i].next;

	/* Most jobs we can just pass */
	/* to joq_Run_Job(), but for  */
	/* jobs in the middle of a    */
        /* |readAnyStreamPacket    */
	/* call, we must ensure that  */
	/* they get dequeued only if  */
	/* the read can complete, and */
	/* in fact only after the     */
	/* read has been completed:   */
	if (j->doing_promiscuous_read == OBJ_FROM_INT(0)) {

	    /* Move job to run queue: */
	    joq_Run_Job( job );

	} else {

	    /* Read can complete only if the  */
	    /* stream is not empty, and if    */
	    /* the job doesn't want fragments */
	    /* then the next packet must be   */
	    /* marked 'done':                 */
	    Vm_Int no_frag= j->promiscuous_no_fragments;
	    Vm_Int frag_ok= (no_frag == OBJ_NIL);
	    Mss_P   m     = MSS_P( mss );
	    Vm_Int  src   = OBJ_TO_INT( m->src );
	    Vm_Int  dst   = OBJ_TO_INT( m->dst );
	    Vm_Int frag   = (m->buf[src].done==OBJ_NIL);
	    if (src!=dst
	    && (frag_ok || !frag)
	    ){
		job_Do_Promiscuous_Read( mss, job, no_frag );
	    }
	}
    }

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_CLASS_JOQ(this.o)) MUQ_FATAL("Bad joq");
    #endif
}



/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    joq_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
joq_Startup (
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    joq_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
joq_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    joq_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
joq_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    joq_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
joq_Import(
    FILE* fd
) {
    MUQ_FATAL ("joq_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    joq_Export -- Write object into textfile.			*/
/************************************************************************/

void joq_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("joq_Export unimplemented");
}


#endif

/************************************************************************/
/*-    joq_Invariants -- Sanity check on joq.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

Vm_Int
joq_Invariants (
    FILE* errlog,
    Vm_Uch* title,
    Vm_Obj job
) {
    Vm_Int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, job );
#endif
    return errs;
}




/************************************************************************/
/*-    joq_Dump -- Ascii print of job queues.				*/
/************************************************************************/

void
joq_Dump (
    Vm_Uch* title
) {
    Vm_Obj ps = USR_P(obj_U_Root)->ps_q;
    Joq_A_Pointer this = JOQ_P(ps)->link.next;
    printf("joq_Dump/%s...\n",title);
    while (!OBJ_IS_CLASS_JOQ(this.o)) {
	Job_P j = JOB_P(this.o);
	Vm_Int i;
	printf("\njob %" VM_X " slot %" VM_D ":\n",this.o,OBJ_TO_UNT(this.i));
	for(i = 0;
	    i < JOB_QUEUE_MEMBERSHIP_MAX;
	    i++
	){
	    if (j->link[i].this != OBJ_FROM_INT(0)) {
		Joq_A_Pointer n, p;  /* MIPS cc disallows combining */
		n = j->link[i].next; /* these three statements for  */
		p = j->link[i].prev; /* some presumably good reason.*/
		printf(" > link[%" VM_D "].next.o/i x=%" VM_X "/%" VM_X "\n",i,n.o,OBJ_TO_INT(n.i));
		printf("   link[%" VM_D "].prev.o/i x=%" VM_X "/%" VM_X "\n",i,p.o,OBJ_TO_INT(p.i));
		printf("   link[%" VM_D "].this x=%" VM_X,i,j->link[i].this);
		{   Vm_Obj nam = JOQ_P(j->link[i].this)->o.objname;
		    Vm_Uch buf[ 132 ];
		    buf[ stg_Get_Bytes(buf,132,nam,0) ] = '\0';
		    printf("  (%s)\n",buf);
		}
	    }
	}
        this = JOB_P(this.o)->link[ OBJ_TO_UNT(this.i) ].next;
    }
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    joq_Get_Link -- Fetch a link in job queue.			*/
/************************************************************************/

Joq_A_Link
joq_Get_Link(
    Joq_Pointer p
){
    Vm_Obj o =             p->o  ;
    Vm_Unt i = OBJ_TO_UNT( p->i );

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(o)) {
	MUQ_FATAL ("joq_Get_Link: bad link obj type.0");
    }
    #endif

    if (OBJ_IS_CLASS_JOQ(o)) {
	#if MUQ_IS_PARANOID
	if (i != 0) {
	    MUQ_FATAL ("joq_Get_Link: bad link offset %d %x",(int)i,(int)i);
	}
	#endif

	return JOQ_P(o)->link;
    }

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_CLASS_JOB(o)) {
        MUQ_FATAL ("joq_Get_Link: bad link obj type.1");
    }
    #endif

    #if MUQ_IS_PARANOID
    if (i >= JOB_QUEUE_MEMBERSHIP_MAX) {
	MUQ_FATAL ("joq_Get_Link: bad link offset");
    }
    #endif

    return JOB_P(o)->link[i];
}

/************************************************************************/
/*-    joq_next								*/
/************************************************************************/

static Vm_Obj
joq_next(
    Vm_Obj o
) {
    return JOQ_P(o)->link.next.o;
}

/************************************************************************/
/*-    joq_prev								*/
/************************************************************************/

static Vm_Obj
joq_prev(
    Vm_Obj o
) {
    return JOQ_P(o)->link.prev.o;
}

/************************************************************************/
/*-    joq_part_of							*/
/************************************************************************/

static Vm_Obj
joq_part_of(
    Vm_Obj o
) {
    return JOQ_P(o)->part_of;
}

/************************************************************************/
/*-    joq_kind								*/
/************************************************************************/

static Vm_Obj
joq_kind(
    Vm_Obj o
) {
    return JOQ_P(o)->kind;
}

/************************************************************************/
/*-    joq_set_never	 						*/
/************************************************************************/

static Vm_Obj
joq_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}







/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/

/************************************************************************/
/*-    for_new -- Initialize new joq object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    {   Joq_P s 	= JOQ_P(o);
	s->link.next.o	= o;
	s->link.prev.o	= o;
	s->link.next.i	= OBJ_FROM_INT(0);
	s->link.prev.i	= OBJ_FROM_INT(0);
	s->part_of	= OBJ_NIL;
	s->kind		= OBJ_FROM_BYT3('i','/','o');
	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_joq -- Return size of jobQueue.				*/
/************************************************************************/

static Vm_Unt
sizeof_joq(
    Vm_Unt size
) {
    return sizeof( Joq_A_Header );
}






/************************************************************************/
/*-    invariants -- Sanity check on joq.				*/
/************************************************************************/

#if MUQ_DEBUG

Vm_Int
joq_Eq(
    Joq_Link a,
    Joq_Link b
){
    return (
        a->prev.o == b->prev.o   &&
        a->prev.i == b->prev.i   &&
        a->next.o == b->next.o   &&
        a->next.i == b->next.i   &&
        a->this   == b->this
    );
}

static void
joq_must_eq(
    FILE* f,
    Vm_Uch* t,
    Joq_Link a,
    Joq_Link b
){
    if (!joq_Eq( a, b )) {
	fprintf(f,"%s: joq garbled\n",t);
	fprintf(f,"a->prev.o/i x=%" VM_X "/%" VM_X "\n",a->prev.o,a->prev.i);
	fprintf(f,"b->prev.o/i x=%" VM_X "/%" VM_X "\n",b->prev.o,a->prev.i);
	fprintf(f,"a->next.o/i x=%" VM_X "/%" VM_X "\n",a->next.o,a->next.i);
	fprintf(f,"b->next.o/i x=%" VM_X "/%" VM_X "\n",b->next.o,a->next.i);
	fprintf(f,"a->this x=%" VM_X "\n",a->this);
	fprintf(f,"b->this x=%" VM_X "\n",b->this);
	{   Vm_Obj kind = JOQ_P(a->this)->kind;
	    fprintf(f,"a->this->kind c=");
	    fputc(OBJ_BYT0(kind),f);
	    fputc(OBJ_BYT1(kind),f);
	    fputc(OBJ_BYT2(kind),f);
	    fprintf(f,"\n");
	}
	{   Vm_Obj kind = JOQ_P(b->this)->kind;
	    fprintf(f,"b->this->kind c=");
	    fputc(OBJ_BYT0(kind),f);
	    fputc(OBJ_BYT1(kind),f);
	    fputc(OBJ_BYT2(kind),f);
	    fprintf(f,"\n");
	}
	fprintf(f,"obj_Etc_Usr x=%" VM_X "\n",obj_Etc_Usr);
	fprintf(f,"obj_Etc_Doz x=%" VM_X "\n",obj_Etc_Doz);
	fprintf(f,"job_RunState.job x=%" VM_X "\n",job_RunState.job);
	{   Usr_A_Header u = *USR_P(obj_U_Root);
	    Vm_Unt i;
	    for (i = 0; i < JOB_PRIORITY_LEVELS; ++i) {
	        fprintf(f,"root->run_q[%d] x=%" VM_X "\n",(int)i,u.run_q[i]);
	    }	
	    fprintf(f,"root->ps_q x=%" VM_X "\n",u.ps_q);
	    fprintf(f,"root->pause_q x=%" VM_X "\n",u.pause_q);
	    fprintf(f,"root->halt_q x=%" VM_X "\n",u.halt_q);
	}
	abort();
    }
}

void
joq_Kind(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj joq,
    Vm_Obj kind
) {
    if (JOQ_P(joq)->kind != kind) {
	Vm_Obj kind2 = JOQ_P(joq)->kind;
	fprintf(f,"%s: wrong joq.kind:",t);
	fputc(OBJ_BYT0(kind2),f);
	fputc(OBJ_BYT1(kind2),f);
	fputc(OBJ_BYT2(kind2),f);
	fprintf(f," != ");
	fputc(OBJ_BYT0(kind),f);
	fputc(OBJ_BYT1(kind),f);
	fputc(OBJ_BYT2(kind),f);
	fprintf(f,"\n");
	fprintf(f,"joq x=%" VM_X "\n",joq);
	abort();
    }
}

static Vm_Int
invariants(
    FILE* f,
    Vm_Uch* t,
    Vm_Obj joq
) {
    if (!OBJ_IS_OBJ(joq)
    ||  !OBJ_IS_CLASS_JOQ(joq)
    ){
	fprintf(f,"%s: joq not a joq!\n",t);
	abort();
    }

    {   /* Check invariants for given job queue: */
	Joq_A_Link orig = JOQ_P(joq)->link;
	Vm_Obj     kind = JOQ_P(joq)->kind;
	Joq_A_Link this; this = orig; /* gcc won't let us combine here. */

	/* Sanity-check joq.kind: */
	switch (kind) {
	case OBJ_FROM_BYT3('i','/','o'):
	case OBJ_FROM_BYT3('r','u','n'):
	case OBJ_FROM_BYT3('d','o','z'):
	case OBJ_FROM_BYT3('p','o','z'):
	case OBJ_FROM_BYT3('h','l','t'):
	case OBJ_FROM_BYT2('p','s'):
	    break;
	default:
	    fprintf(f,"%s: bad joq.kind: '",t);
	    fputc(OBJ_BYT0(kind),f);
	    fputc(OBJ_BYT1(kind),f);
	    fputc(OBJ_BYT2(kind),f);
	    fprintf(f,"'\n");
	    abort();
	}

	/* Check pointers in each link in job queue: */
	for (;;) {
	    Joq_A_Link    prev;
	    Joq_A_Link    prevnext;
	    /* gcc refuses to let us following initialize preceding: */
	    prev     = joq_Get_Link( &this.prev );
	    prevnext = joq_Get_Link( &prev.next );
	    joq_must_eq( f,t, &prevnext, &this );

	    this = joq_Get_Link( &this.next );
	    if (joq_Eq( &this, &orig )) break;

	    if (this.this == OBJ_FROM_INT(0)) {
		fprintf(f,"%s: in-use link marked 'free'\n",t);
		abort();
	    }

	    /* For all jobs in run queues, check */
	    /* that owner is in obj_Etc_Usr:     */
	    if (kind == OBJ_FROM_BYT3('r','u','n')) {
		Vm_Obj owner = obj_Owner(prev.next.o);
		if (!OBJ_IS_OBJ(owner)
		||  !OBJ_ISA_USR(owner)
		){
		    fprintf(f,"%s: job owner not a user\n",t);
		    abort();
		}
		usq_Must_Contain (f,t, obj_Etc_Usr, owner );
	    }
	}
    }

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
