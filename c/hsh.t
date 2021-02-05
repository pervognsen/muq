@example  @c

/************************************************************************/
/*--   hsh.c -- HaSHed-btree index objects for Muq.			*/
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
/* Created:      99Aug21						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 2000, by Jeff Prothero.				*/
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
static Vm_Int   invariants(FILE*,Vm_Uch*,Vm_Obj);
#endif

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_hsh( Vm_Unt );

Vm_Obj  hsh_X_Del( Vm_Obj, Vm_Obj, Vm_Int 	 );
Vm_Obj  hsh_X_Get( Vm_Obj, Vm_Obj, Vm_Int 	 );
Vm_Obj  hsh_X_Get_Asciz( Vm_Obj, Vm_Uch*, Vm_Int  );
Vm_Obj  hsh_X_Next( Vm_Obj, Vm_Obj, Vm_Int 	 );
Vm_Uch* hsh_X_Set( Vm_Obj, Vm_Obj, Vm_Obj, Vm_Int );

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property hsh_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class hsh_Hardcoded_Class = {
    OBJ_FROM_BYT3('h','s','h'),
    "Hash",
    sizeof_hsh,
    for_new,
    hsh_X_Del,
    hsh_X_Get,
    hsh_X_Get_Asciz,
    hsh_X_Set,
    hsh_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { hsh_system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void hsh_doTypes(void){}
Obj_A_Module_Summary hsh_Module_Summary = {
   "hsh",
    hsh_doTypes,
    hsh_Startup,
    hsh_Linkup,
    hsh_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    hsh_Startup -- start-of-world stuff.				*/
/************************************************************************/

void hsh_Startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    hsh_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void hsh_Linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    hsh_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void hsh_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}


#ifdef OLD

/************************************************************************/
/*-    hsh_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj hsh_Import(
    FILE* fd
) {
    MUQ_FATAL ("hsh_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    hsh_Export -- Write object into textfile.			*/
/************************************************************************/

void hsh_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("hsh_Export unimplemented");
}


#endif

/************************************************************************/
/*-    hsh_Invariants -- Sanity check on hsh.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
hsh_Invariants (
    FILE*   errlog,
    Vm_Uch* title,
    Vm_Obj  hsh
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, hsh );
#endif
    return errs;
}


/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    hsh_X_Del -- Delete value for given 'key'.		       	*/
/************************************************************************/

Vm_Obj
hsh_X_Del(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    Vm_Int c = OBJ_CLASS(obj);

    /* Try to keep propdir blocks in same db as parent  */
    /* object.  A less clumsy and unreliable hack would */
    /* be a distinct improvement:                       */ 
    if (mod_Hardcoded_Class[c]->propdir[propdir] != NULL
    &&  OBJ_IS_SYMBOL(key)
    ){
	/* Ignore 'delete' if it is for a special-prop value: */
	Vm_Int i;
	for (i = 0;  mod_Hardcoded_Class[c]->propdir[propdir][i].name;  ++i) {
	    Obj_Special_Property p;
	    p = &mod_Hardcoded_Class[c]->propdir[propdir][i];
	    if (p->keyword == key) {
		Vm_Obj result = p->for_get( obj );
		return result;
    }   }   }

    /* If key is in propdir, remove it: */
    {   Vm_Obj v;
    
	Vm_Obj olddir = HSH_P(obj)->propdir[propdir];

	v          = job_Btree_Get( olddir, key );
	if (v != OBJ_NOT_FOUND) {
	    Vm_Obj newdir = job_Btree_Del( olddir, key );
	    if (newdir != olddir) {
		HSH_P(obj)->propdir[propdir] = newdir;
		vm_Dirty(obj);
	    }
	}
        return v;
    }

    /* Decidedly do not search our */
    /* parents and delete in them. */
}

/************************************************************************/
/*-    hsh_X_Get -- Get value for given 'key'.			       	*/
/************************************************************************/



Vm_Obj
hsh_X_Get(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    Vm_Int c = OBJ_CLASS(obj);

    if (mod_Hardcoded_Class[c]->propdir[propdir] != NULL
    &&  OBJ_IS_SYMBOL(key)
    ){

	/* Maybe return special-prop value: */
	Vm_Int i;
	for (i = 0;  mod_Hardcoded_Class[c]->propdir[propdir][i].name;  ++i) {
	    Obj_Special_Property p;
	    p = &mod_Hardcoded_Class[c]->propdir[propdir][i];
	    if (p->keyword == key) {
		Vm_Obj v = p->for_get( obj );
		if (v != OBJ_NOT_FOUND) {
		    return v;
		}
		break;
    }   }   }

    /* If key is in propdir, return that value: */
    {
	Vm_Obj dir    = HSH_P(obj)->propdir[propdir];

        Vm_Obj v      = job_Btree_Get( dir, key );

	if (v != OBJ_NOT_FOUND) {
	    return v;
	}
    }

    /* Failed to find value for key: */
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    hsh_X_Get_Asciz -- Get value for given 'key'.		       	*/
/************************************************************************/

Vm_Obj
hsh_X_Get_Asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    /************************************************************/
    /* If caller has read privs, then:				*/
    /*   If key is a system_prop, we maybe use that val.	*/
    /*   Else if key is in propdir, we use that val.		*/
    /* Else we fail.						*/
    /************************************************************/

    /* All hardwired properties are now keywords, */
    /* so hsh_X_Get_Asciz inherently doesn't have */
    /* to worry about hardwired properties.       */

    /* If key is in propdir, return that value: */
    {
	Vm_Obj dir    = HSH_P(obj)->propdir[propdir];

        Vm_Obj v      = job_Btree_Get_Asciz(dir,key);

	if    (v != OBJ_NOT_FOUND)   return v;
    }

    /* Failed to find value for key: */
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    hsh_X_Next -- Return next key in obj else OBJ_NOT_FOUND.      	*/
/************************************************************************/

Vm_Obj
hsh_X_Next(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Obj specialkey = 0;
    Vm_Obj regularkey = key;
    Vm_Int keytype    = OBJ_TYPE(key);
    Vm_Int c          = OBJ_CLASS(obj);

    /* See if there are special hardwired  */
    /* properties for this propdir on this */
    /* this class of object:               */

    /* Find next regular prop after 'key': */
    Vm_Obj dir    = HSH_P(obj)->propdir[propdir];
/*printf("hsh_X_Next obj %llx key %llx propdir %llx  dir %llx\n",obj,key,propdir,dir);*/

    regularkey        = dil_Next( dir, regularkey );

    if (mod_Hardcoded_Class[c]->propdir[propdir] == NULL) {
	/*****************************************/
	/* No hardwired properties, just go with */
	/* whatever we actually find on the obj: */
	/*****************************************/
	return   regularkey;
    }

    /*************************************************/
    /* We have hardwired properties, need to return  */
    /* lesser of the next hardwired property and the */
    /* next normal property, where either or both    */
    /* may be absent:                                */
    /*************************************************/

    /* Find next special prop after 'key': */
    if (!OBJ_IS_SYMBOL(key)) {
	if (keytype < OBJ_TYPE_SYMBOL) {
	    specialkey = mod_Hardcoded_Class[c]->propdir[propdir][0].keyword;
	}
    } else {
	Vm_Int i;
	Vm_Obj t;

	for (i=0; t=mod_Hardcoded_Class[c]->propdir[propdir][i].keyword; ++i) {
	    if (obj_Neql( t , key) > 0) {
		specialkey = t;
		break;
    }  	}   }
/* buggo, this is probably very broken:  the hash table ordering will */
/* not match the system table ordering, and the implicit merge of the */
/* two orders done here will consequently result in skipped values or */
/* looping or such. The short-term fix is probably not to allow btree */
/* values in hash propdirs which have hardwired values. The long-term */
/* fix is likely to have the system table sorted by hash value instead*/
/* of key value on hash objects...?  But this requires getting obj.t  */
/* to deal with such special cases gracefully, and poking around to   */
/* see what this might break.                                         */


    /* Return earliest of specialkey and regularkey: */
    if (specialkey != 0
    &&  regularkey != OBJ_NOT_FOUND
    ){
        if (obj_Neql( specialkey , regularkey) < 0) {
	    return specialkey;
	} else {
	    return regularkey;
	}
    } else {
	if (specialkey != 0)   return   specialkey;
	else                   return   regularkey  ;
    }
}

/************************************************************************/
/*-    hsh_X_Set -- Set 'key' to 'val' in 'obj'.			*/
/************************************************************************/

Vm_Uch*
hsh_X_Set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    /* Check hardcoded props: */
    Vm_Int c = OBJ_CLASS(obj);
    Vm_Int i;

    /* Try to keep propdir blocks in same db as parent  */
    /* object.  A less clumsy and unreliable hack would */
    /* be a distinct improvement:                       */ 

    if (mod_Hardcoded_Class[c]->propdir[propdir] != NULL
    &&  OBJ_IS_SYMBOL(key)
    ){
	/* buggo... should at least do binary search someday: */
	for (i = 0;  mod_Hardcoded_Class[c]->propdir[propdir][i].name;  ++i) {
	    Obj_Special_Property p;
	    p = &mod_Hardcoded_Class[c]->propdir[propdir][i];
	    if (p->keyword == key) {
		Vm_Obj v  = p->for_set( obj, val );
		if (   v != OBJ_NOT_FOUND) {
		     return NULL;
		}
		break;
    }   }   }

    {   /* Don't combine these lines, side-effect sequencing matters: */
        Vm_Obj olddir = HSH_P(obj)->propdir[propdir];

	Vm_Obj newdir = job_Btree_Set( olddir, key, val, VM_DBFILE(obj) );
        if (   newdir != olddir) {
	    HSH_P(obj)->propdir[propdir] = newdir;
	    vm_Dirty(obj);
        }
    }

    /* Buggo... should do this at actual change point: */
    vm_Dirty(obj);
    return NULL;
}






/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new hsh object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Hsh_P p              = HSH_P(o);
    int i;
    for (i = OBJ_PROP_MAX;  i --> 0; ) {
	p->propdir[i] = dil_Alloc();
    }
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_hsh -- Return size of package.				*/
/************************************************************************/

static Vm_Unt
sizeof_hsh(
    Vm_Unt size
) {
    return sizeof( Hsh_A_Header );
}





/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int invariants(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj  hsh
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif




/************************************************************************/
/*-    --- Static propfns --						*/
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
