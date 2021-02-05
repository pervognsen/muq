@example  @c
/*--   prx.c -- binary semaphores (LOcKs) for Muq.			*/
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
/* Created:      95Apr25						*/
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
/*-    Overview								*/
/************************************************************************/

/************************************************************************


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

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_prx( Vm_Unt );

static Vm_Obj	prx_guest(	  Vm_Obj         );

static Vm_Obj	prx_i0(		  Vm_Obj         );
static Vm_Obj	prx_i1(		  Vm_Obj         );
static Vm_Obj	prx_i2(		  Vm_Obj         );

static Vm_Obj   prx_hash(         Vm_Obj	 );

static Vm_Obj prx_set_never( Vm_Obj, Vm_Obj );

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property prx_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    {0,"guest",prx_guest, prx_set_never },

    {0,"i0",  prx_i0	, prx_set_never },
    {0,"i1",  prx_i1	, prx_set_never },
    {0,"i2",  prx_i2	, prx_set_never },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class prx_Hardcoded_Class = {
    OBJ_FROM_BYT3('p','r','x'),
    "Proxy",
    sizeof_prx,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    prx_hash,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { prx_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void prx_doTypes(void){}
Obj_A_Module_Summary prx_Module_Summary = {
   "prx",
    prx_doTypes,
    prx_Startup,
    prx_Linkup,
    prx_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    prx_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
prx_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    prx_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
prx_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    prx_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
prx_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    prx_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
prx_Import(
    FILE* fd
) {
    MUQ_FATAL ("prx_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    prx_Export -- Write object into textfile.			*/
/************************************************************************/

void
prx_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("prx_Export unimplemented");
}


#endif








/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new prx object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    {   Prx_P s 	= PRX_P(o);

	s->guest	= OBJ_FROM_INT( 0 );

	s->i0		= OBJ_FROM_INT( 0 );
	s->i1		= OBJ_FROM_INT( 0 );
	s->i2		= OBJ_FROM_INT( 0 );

	{   int i;
	    for (i = PRX_RESERVED_SLOTS;  i --> 0; ) s->reserved_slot[i] = OBJ_FROM_INT(0);
	}

	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_prx -- Return size of proxy.				*/
/************************************************************************/

static Vm_Unt
sizeof_prx(
    Vm_Unt size
) {
    return sizeof( Prx_A_Header );
}


static Vm_Obj
prx_hash(
    Vm_Obj o
) {
    Vm_Uch buf[ 3 * VM_INTBYTES ];
    {   Prx_P p = PRX_P(o);
	Vm_Int i;

	i       = OBJ_FROM_INT( p->i0   );
	buf[0*VM_INTBYTES + 0] = ((i >>  0) & 0xFF);
	buf[0*VM_INTBYTES + 1] = ((i >>  8) & 0xFF);
	buf[0*VM_INTBYTES + 2] = ((i >> 16) & 0xFF);
	buf[0*VM_INTBYTES + 3] = ((i >> 24) & 0xFF);
        #if VM_INTBYTES > 4
	buf[0*VM_INTBYTES + 4] = ((i >> 32) & 0xFF);
	buf[0*VM_INTBYTES + 5] = ((i >> 40) & 0xFF);
	buf[0*VM_INTBYTES + 6] = ((i >> 48) & 0xFF);
	buf[0*VM_INTBYTES + 7] = ((i >> 56) & 0xFF);
	#endif

	i       = OBJ_FROM_INT( p->i1   );
	buf[1*VM_INTBYTES + 0] = ((i >>  0) & 0xFF);
	buf[1*VM_INTBYTES + 1] = ((i >>  8) & 0xFF);
	buf[1*VM_INTBYTES + 2] = ((i >> 16) & 0xFF);
	buf[1*VM_INTBYTES + 3] = ((i >> 24) & 0xFF);
        #if VM_INTBYTES > 4
	buf[1*VM_INTBYTES + 4] = ((i >> 32) & 0xFF);
	buf[1*VM_INTBYTES + 5] = ((i >> 40) & 0xFF);
	buf[1*VM_INTBYTES + 6] = ((i >> 48) & 0xFF);
	buf[1*VM_INTBYTES + 7] = ((i >> 56) & 0xFF);
	#endif

	i       = OBJ_FROM_INT( p->i2   );
	buf[2*VM_INTBYTES + 0] = ((i >>  0) & 0xFF);
	buf[2*VM_INTBYTES + 1] = ((i >>  8) & 0xFF);
	buf[2*VM_INTBYTES + 2] = ((i >> 16) & 0xFF);
	buf[2*VM_INTBYTES + 3] = ((i >> 24) & 0xFF);
        #if VM_INTBYTES > 4
	buf[2*VM_INTBYTES + 4] = ((i >> 32) & 0xFF);
	buf[2*VM_INTBYTES + 5] = ((i >> 40) & 0xFF);
	buf[2*VM_INTBYTES + 6] = ((i >> 48) & 0xFF);
	buf[2*VM_INTBYTES + 7] = ((i >> 56) & 0xFF);
	#endif

    }
    {   Vm_Int result = sha_InsecureHash( buf, 3 * VM_INTBYTES );
        return result;
    }
}



/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    prx_guest							*/
/************************************************************************/

static Vm_Obj
prx_guest(
    Vm_Obj o
) {
    return PRX_P(o)->guest;
}



/************************************************************************/
/*-    prx_i0								*/
/************************************************************************/

static Vm_Obj
prx_i0(
    Vm_Obj o
) {
    return PRX_P(o)->i0;
}

/************************************************************************/
/*-    prx_i1								*/
/************************************************************************/

static Vm_Obj
prx_i1(
    Vm_Obj o
) {
    return PRX_P(o)->i1;
}

/************************************************************************/
/*-    prx_i2								*/
/************************************************************************/

static Vm_Obj
prx_i2(
    Vm_Obj o
) {
    return PRX_P(o)->i2;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    prx_set_never	 						*/
/************************************************************************/

static Vm_Obj
prx_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
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
