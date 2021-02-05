@example  @c
/*--   usq.c -- USer Queues for Muq.					*/
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
/* Created:      95May22						*/
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
static Vm_Unt   sizeof_usq(  Vm_Unt );

static Vm_Obj	usq_next(    Vm_Obj );
static Vm_Obj	usq_prev(    Vm_Obj );

static Vm_Obj	usq_set_never( Vm_Obj, Vm_Obj );
static Vm_Obj   usq_get_prev( FILE*, Vm_Uch*, Vm_Obj );
static Vm_Obj   usq_get_next( FILE*, Vm_Uch*, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void usq_doTypes(void){}
Obj_A_Module_Summary usq_Module_Summary = {
   "usq",
    usq_doTypes,
    usq_Startup,
    usq_Linkup,
    usq_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property usq_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"next"    , usq_next	, usq_set_never },
    {0,"previous", usq_prev	, usq_set_never },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class usq_Hardcoded_Class = {
    OBJ_FROM_BYT3('u','s','q'),
    "UserQueue",
    sizeof_usq,
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
    { usq_system_properties, usq_system_properties, NULL, NULL },
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
/*-    usq_Dequeue -- Remove 'usr' from its queue.			*/
/************************************************************************/

void
usq_Dequeue(
    Vm_Obj usr
) {
    Vm_Obj next;
    Vm_Obj prev;

    /* Find objects before and after us in queue. */
    /* Either or both of these may be the queue   */
    /* header vector:                             */
    {   Usr_P  u = USR_P( usr );
        next = u->next;
        prev = u->prev;

        u->next = OBJ_FROM_INT(0);
        u->prev = OBJ_FROM_INT(0);
    }

    /* Do					*/
    /*   next->prev = prev;			*/
    /*   prev->next = next;			*/
    /* This is a bit messy because next/prev	*/
    /* can be either users or the queue hdr:   */

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(      next)
    ){
	MUQ_FATAL ("Needed obj");
    }
    if (!OBJ_IS_OBJ(      prev)
    ){
	MUQ_FATAL ("Needed obj");
    }
    #endif

    if (OBJ_IS_CLASS_USQ(next)) {
	USQ_P(next)->prev = prev;	vm_Dirty(next);
    } else {
	USR_P(next)->prev = prev;	vm_Dirty(next);

	#if MUQ_IS_PARANOID
	if (!OBJ_ISA_USR(next)
        ){
	    MUQ_FATAL ("Needed usr");
	}
	#endif
    }

    if (OBJ_IS_CLASS_USQ(prev)) {
	USQ_P(prev)->next = next;	vm_Dirty(next);
    } else {
	USR_P(prev)->next = next;	vm_Dirty(prev);

	#if MUQ_IS_PARANOID
	if (!OBJ_ISA_USR(prev)
        ){
	    MUQ_FATAL ("Needed usr");
	}
	#endif
    }
}



/************************************************************************/
/*-    usq_Enqueue -- Insert currently unqueued usr 'u' into 'q'.	*/
/************************************************************************/

void
usq_Enqueue(
    Vm_Obj u
) {
    Vm_Obj q = obj_Etc_Usr;

    /* Do				*/
    /*   p       = q->prev;		*/
    /*   u->prev = p;			*/
    /*   u->next = q;			*/
    /*   q->prev = u;			*/
    /*   p->next = u;			*/
    /* This is a bit messy because p	*/
    /* can be either obj or queue hdr:  */

    Vm_Obj p = USQ_P(q)->prev;
    {   Usr_P up   = USR_P( u );
	up->prev = p;
	up->next = q;
	vm_Dirty(  u );
    }

    USQ_P(q)->prev = u; vm_Dirty(q);

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(      p)
    ){
	MUQ_FATAL ("Needed obj");
    }
    #endif

    if (OBJ_IS_CLASS_USQ(p)) {

	USQ_P(p)->next = u; vm_Dirty(p);

    } else {
        Usr_P pp   = USR_P( p );
        #if MUQ_IS_PARANOID
	if (!OBJ_ISA_USR(p)
	){
	    MUQ_FATAL ("Needed usr");
	}
	#endif
	pp->next = u;
	vm_Dirty(  p );
    }
}



/************************************************************************/
/*-    usq_Requeue -- Move 'usr' to 'queue'.				*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
void
usq_Requeue(
    Vm_Obj queue,
    Vm_Obj usr
) {
    usq_Dequeue(        usr );
    usq_Enqueue( queue, usr );
}
#endif


/************************************************************************/
/*-    usq_Reset -- Reset usq to empty.					*/
/************************************************************************/

void
usq_Reset(
    Vm_Obj usq
) {
    Usq_P q = USQ_P(usq);
    q->next = usq;
    q->prev = usq;
    vm_Dirty(usq);
}



/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    usq_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
usq_Startup(
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;


}



/************************************************************************/
/*-    usq_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
usq_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;


}



/************************************************************************/
/*-    usq_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
usq_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    usq_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
usq_Import(
    FILE* fd
) {
    MUQ_FATAL ("usq_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    usq_Export -- Write object into textfile.			*/
/************************************************************************/

void usq_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("usq_Export unimplemented");
}


#endif

/************************************************************************/
/*-    usq_Invariants -- Sanity check on usq.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

Vm_Int
usq_Invariants (
    FILE*   errlog,
    Vm_Uch* title,
    Vm_Obj  usq
) {
    Vm_Int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, usq );
#endif
    return errs;
}

/************************************************************************/
/*-    usq_Must_Contain -- Check on usq contents.			*/
/************************************************************************/

void
usq_Must_Contain (
    FILE*   errlog,
    Vm_Uch* title,
    Vm_Obj  usq,
    Vm_Obj  usr
) {
    /* Check invariants for given user queue: */
    Vm_Obj this = usq;

    /* Check pointers in each link in user queue: */
    do {
	this = usq_get_next( errlog, title, this );
	if  (this == usr)   return;
    } while (this != usq);

    fprintf(errlog,"%s: usr missing from usq!\n",title);
    abort();
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    usq_next								*/
/************************************************************************/

static Vm_Obj
usq_next(
    Vm_Obj o
) {
    return USQ_P(o)->next;
}

/************************************************************************/
/*-    usq_prev								*/
/************************************************************************/

static Vm_Obj
usq_prev(
    Vm_Obj o
) {
    return USQ_P(o)->prev;
}

/************************************************************************/
/*-    usq_set_never	 						*/
/************************************************************************/

static Vm_Obj
usq_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}







/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/

/************************************************************************/
/*-    for_new -- Initialize new usq object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    {   Usq_P s	= USQ_P(o);
	s->next	= o;
	s->prev	= o;
	{   int i;
	    for (i = USQ_RESERVED_SLOTS;  i --> 0; ) s->reserved_slot[i] = OBJ_FROM_INT(0);
	}
	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_usq -- Return size of jobQueue.				*/
/************************************************************************/

static Vm_Unt
sizeof_usq(
    Vm_Unt size
) {
    return sizeof( Usq_A_Header );
}







/************************************************************************/
/*-    invariants -- Sanity check on usq.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Obj
usq_get_next(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj  this
){
    if (!OBJ_IS_OBJ(this)) {
	fprintf(f,"%s: bad usq element!\n",t);
	abort();
    }
    if (OBJ_ISA_USR(this)) {
	return USR_P(this)->next;
    }
    if (!OBJ_IS_CLASS_USQ(this)) {
	fprintf(f,"%s: bad usq element!\n",t);
	abort();
    }
    return USQ_P(this)->next;
}
static Vm_Obj
usq_get_prev(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj  this
){
    if (!OBJ_IS_OBJ(this)) {
	fprintf(f,"%s: bad usq element!\n",t);
	abort();
    }
    if (OBJ_ISA_USR(this)) {
	return USR_P(this)->prev;
    }
    if (!OBJ_IS_CLASS_USQ(this)) {
	fprintf(f,"%s: bad usq element!\n",t);
	abort();
    }
    return USQ_P(this)->prev;
}

static Vm_Int
invariants(
    FILE* f,
    Vm_Uch* t,
    Vm_Obj usq
) {
    if (!OBJ_IS_OBJ(usq)
    ||  !OBJ_IS_CLASS_USQ(usq)
    ){
	fprintf(f,"%s: usq not a usq!\n",t);
	abort();
    }

    joq_Invariants( f,t, obj_Etc_Doz );
    joq_Kind(f,t, obj_Etc_Doz,  OBJ_FROM_BYT3('d','o','z') );
    usr_Invariants(f,t, obj_U_Root );

    {   /* Check invariants for given user queue: */
	Vm_Obj this = usq;

	/* Check pointers in each link in user queue: */
	for (;;) {
	    Vm_Obj  prev     = usq_get_prev( f,t, this );
	    Vm_Obj  prevnext = usq_get_next( f,t, prev );
	    if (prevnext != this) {
		fprintf(f,"%s: bad usq link!\n",t);
		abort();
	    }

	    this = usq_get_next( f,t, this );
	    if (this == usq) break;
	
	    /* Check invariants on user: */
	    usr_Invariants( f,t, this );
	} 
    }
    
    return 0;
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
