@example  @c

/*--   ecn.c -- Ephemeral CoNs cells for Muq.				*/
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
/* Created:      95Oct08						*/
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

static Vm_Uch* ecn_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  ecn_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  ecn_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  ecn_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* ecn_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  ecn_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  ecn_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void    ecn_export(  FILE*, Vm_Obj, Vm_Int );

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void ecn_doTypes(void){
    if (mod_Type_Summary[OBJ_TYPE_EPHEMERAL_LIST] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_EPHEMERAL_LIST");
    }
    mod_Type_Summary[ OBJ_TYPE_EPHEMERAL_LIST ] = &ecn_Type_Summary;
}
Obj_A_Module_Summary ecn_Module_Summary = {
   "ecn",
    ecn_doTypes,
    ecn_Startup,
    ecn_Linkup,
    ecn_Shutdown
};

Obj_A_Type_Summary ecn_Type_Summary = {    OBJ_FROM_BYT2('E','N'),
    ecn_sprintX,
    ecn_sprintX,
    ecn_sprintX,
    ecn_for_del,
    ecn_for_get,
    ecn_g_asciz,
    ecn_for_set,
    ecn_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Dummy_Reverse,
    obj_Type_Get_Mos_Key,
    ecn_import,
    ecn_export,
    "Cons",
    KEY_LAYOUT_CONS,
    OBJ_0
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    ecn_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
ecn_Startup(
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    ecn_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
ecn_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    ecn_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
ecn_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}




/************************************************************************/
/*-    ecn_Invariants -- Sanity check on ecn.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
ecn_Invariants(
    FILE* errlog,
    char* title,
    Vm_Obj ecn
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, ecn );
#endif
    return errs;
}


/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    ecn_sprintX -- Debug dump of ecn state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
ecn_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    #ifdef MUQ_VERBOSE
    return  lib_Sprint( buf, lim, "#<ecn %" VM_X ">", obj );
    #else
    return  lib_Sprint( buf, lim, "#<ephemeralCons>" );
    #endif
}



/************************************************************************/
/*-    ecn_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
ecn_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    ecn_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
ecn_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Obj owner;
    if (key == job_Kw_Car)   return ECN_P(&owner,obj)->car;
    if (key == job_Kw_Cdr)   return ECN_P(&owner,obj)->cdr;
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    ecn_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
ecn_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    ecn_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
ecn_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    Vm_Obj owner;
    if (propdir == OBJ_PROP_PUBLIC) {
        if (key==job_Kw_Car) {ECN_P(&owner,obj)->car=val; return NULL;}
        if (key==job_Kw_Cdr) {ECN_P(&owner,obj)->cdr=val; return NULL;}
    }
    return   "Can't set that property on a list cell.";
}


/************************************************************************/
/*-    ecn_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
ecn_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_PUBLIC)  return OBJ_NOT_FOUND;
    if (0 < obj_Neql( job_Kw_Car, key ))   return job_Kw_Car;
    if (0 < obj_Neql( job_Kw_Cdr, key ))   return job_Kw_Cdr;
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    ecn_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj
ecn_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
#ifdef SOMEDAY
    /* Read old name of object: */
    Vm_Int m;
    Vm_Obj n;
    Vm_Obj o;
    if (2 != fscanf(fd, "%" VM_X ":%" VM_D, &o, &m )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("ecn_Import: bad input!\n");
    }    

    /* Make/find ecn to hold result: */
    n = (pass
	? obj_Import_Hashtab_Val( o )
	: ecn_alloc( m )
    );
    if (!pass)   obj_Import_Hashtab_Enter( n, o );

    /* Handle any ownership info: */
    if (have) {
	Vm_Obj own     = obj_Import_Any( fd, pass, have, read );
	if (pass && read) {
	    Vm_Int len;
	    ECN_P(&len,n)->owner = own;
/* buggo, net1/net2 not dealt with. */
	    vm_Dirty(n);
    }   }

    /* Read items in object: */
    {   Vm_Int i;
	for (i = 0;   i < m;   ++i) {
	    Vm_Obj val = obj_Import_Any( fd, pass, have, read );
	    if (pass)   ecn_Set( n, i, val );
    }   }
    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    /* Read end-of-object: */
    if (fgetc(fd) != '\n') MUQ_FATAL ("ecn_Import: bad input!\n");

    ++obj_Export_Stats->objects_in_file;

    return n;
#else
    return OBJ_NIL;
#endif
}



/************************************************************************/
/*-    ecn_export -- Write object into textfile.			*/
/************************************************************************/

static void
ecn_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
#ifdef SOMEDAY
    Vm_Int len = ecn_Len(o);
    fprintf( fd, "V:%" VM_X ":%" VM_D "\n", o, len );
    {   Vm_Int len;
        Ecn_P  p = ECN_P(&len,o);
	Vm_Int i;
	if (write_owners)  obj_Export_Subobj( fd, p->owner, write_owners );
	for (i = 0;   i < len;   ++i) {
	    obj_Export_Subobj(                fd, p->slot[i], write_owners );
    }	}
    fputc( '\n', fd );
#endif
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    char* t,
    Vm_Obj ecn
) {
/*buggo*/
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
