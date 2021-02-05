@example  @c
/*--   dbf.c -- server interface objects for Muq.			*/
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
/* Created:      99May04						*/
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

#ifndef DBF_MILLISECS_BETWEEN_BACKUPS
#define DBF_MILLISECS_BETWEEN_BACKUPS (60*60*1000)
#endif

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
static Vm_Unt   sizeof_dbf( Vm_Unt );

static Vm_Obj dbf_x_next(  Vm_Obj obj,  Vm_Obj key, Vm_Int propdir );
static Vm_Obj dbf_x_get_asciz( Vm_Obj  obj, Vm_Uch* key, Vm_Int  propdir );
static Vm_Uch*dbf_x_set( Vm_Obj obj, Vm_Obj key, Vm_Obj val, Vm_Int propdir );
static Vm_Obj dbf_x_key( Vm_Obj obj, Vm_Obj key,  Vm_Obj val, Vm_Int forward, Vm_Int propdir );
static Vm_Obj dbf_x_get( Vm_Obj obj, Vm_Obj key, Vm_Int propdir );
static Vm_Obj dbf_x_del( Vm_Obj obj, Vm_Obj key, Vm_Int propdir );

#ifdef CURRENTLY_UNUSED
static Vm_Obj   dbf_vm_octave_file_path(     Vm_Obj		);
#endif

static Vm_Obj	dbf_blocks_recovered_in_last_garbage_collect( Vm_Obj	);
static Vm_Obj	dbf_bytes_recovered_in_last_garbage_collect( Vm_Obj	);
static Vm_Obj	dbf_date_of_last_garbage_collect( Vm_Obj	);
static Vm_Obj	dbf_millisecs_for_last_garbage_collect(Vm_Obj	);
static Vm_Obj	dbf_garbage_collects(        Vm_Obj		);


static Vm_Obj   dbf_vm_object_loads(         Vm_Obj          );
static Vm_Obj   dbf_vm_object_saves(         Vm_Obj          );
static Vm_Obj   dbf_vm_object_makes(         Vm_Obj          );
static Vm_Obj	dbf_bytes_between_gcs(       Vm_Obj          );
static Vm_Obj	dbf_bytes_since_last_gc(     Vm_Obj          );
static Vm_Obj	dbf_vm_bytes_in_useful_data(	  Vm_Obj          );
static Vm_Obj	dbf_vm_bytes_lost_in_used_blocks( Vm_Obj          );
static Vm_Obj	dbf_vm_bytes_in_free_blocks(      Vm_Obj          );
static Vm_Obj	dbf_vm_free_blocks(               Vm_Obj          );
static Vm_Obj	dbf_vm_used_blocks(               Vm_Obj          );


static Vm_Obj	dbf_set_never(                    Vm_Obj, Vm_Obj );
static Vm_Obj	dbf_set_garbage_collects(         Vm_Obj, Vm_Obj );
static Vm_Obj	dbf_set_bytes_between_gcs(        Vm_Obj, Vm_Obj );




/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property dbf_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"


/* Special system properties on this class: */
{0,"blocksRecoveredInLastGarbageCollect", dbf_blocks_recovered_in_last_garbage_collect, dbf_set_never },
{0,"bytesRecoveredInLastGarbageCollect", dbf_bytes_recovered_in_last_garbage_collect, dbf_set_never },
{0,"bytesBetweenGarbageCollects",	dbf_bytes_between_gcs,	dbf_set_bytes_between_gcs },
{0,"bytesInFreeBlocks",dbf_vm_bytes_in_free_blocks,	dbf_set_never },
{0,"bytesInUsefulData", dbf_vm_bytes_in_useful_data,dbf_set_never },
{0,"bytesLostInUsedBlocks",dbf_vm_bytes_lost_in_used_blocks,dbf_set_never},
{0,"bytesSinceLastGarbageCollect",dbf_bytes_since_last_gc,dbf_set_never},
{0,"dbLoads"	, dbf_vm_object_loads   , dbf_set_never },
{0,"dbMakes"	, dbf_vm_object_makes   , dbf_set_never },
{0,"dbSaves"	, dbf_vm_object_saves   , dbf_set_never },
{0,"dateOfLastGarbageCollect", dbf_date_of_last_garbage_collect, dbf_set_never },
{0,"freeBlocks",	dbf_vm_free_blocks,		dbf_set_never },
{0,"garbageCollectsDone",dbf_garbage_collects,dbf_set_garbage_collects },
{0,"millisecsForLastGarbageCollect", dbf_millisecs_for_last_garbage_collect, dbf_set_never },
{0,"usedBlocks",  dbf_vm_used_blocks,		dbf_set_never },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class dbf_Hardcoded_Class = {
    OBJ_FROM_BYT3('d','b','f'),
    "Db",
    sizeof_dbf,
    for_new,

    dbf_x_del,
    dbf_x_get,
    dbf_x_get_asciz,
    dbf_x_set,
    dbf_x_next,
    dbf_x_key,

    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { dbf_system_properties, dbf_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void dbf_doTypes(void){}
Obj_A_Module_Summary dbf_Module_Summary = {
   "dbf",
    dbf_doTypes,
    dbf_Startup,
    dbf_Linkup,
    dbf_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/




/************************************************************************/
/*-    dbf_Sprint  -- Debug dump of dbf state, multi-line format.	*/
/************************************************************************/

Vm_Uch* dbf_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  dbf
) {
#ifdef SOMETIME
    Dbf_P  s   = DBF_P(dbf);
    Vm_Int sp  = OBJ_TO_INT(s->sp);
    Vm_Int i;
    Vm_Int lo  = (s->fn == OBJ_FROM_INT(2))  ?  2  :  0;
    for (i = sp;   i >= lo;   --i) {
	Vm_Obj*  j = &s->stack[i];
	Vm_Obj   o = *j;
	buf  = lib_Sprint(buf,lim, "%d: ", i-lo );
	buf += job_Sprint_Vm_Obj( buf,lim, *j, /* quote_strings: */ TRUE );
	buf  = lib_Sprint(buf,lim, "\n" );
    }
#endif
    return buf;
}




/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/



/************************************************************************/
/*-    dbf_Startup -- start-of-world stuff.				*/
/************************************************************************/


 /***********************************************************************/
 /*-    dbf_Startup -- start-of-world stuff.				*/
 /***********************************************************************/

void
dbf_Startup(
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

}



/************************************************************************/
/*-    dbf_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
dbf_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    dbf_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void dbf_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

}


#ifdef SOON

/************************************************************************/
/*-    dbf_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj dbf_Import(
    FILE* fd
) {
    MUQ_FATAL ("dbf_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    dbf_Export -- Write object into textfile.			*/
/************************************************************************/

void dbf_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("dbf_Export unimplemented");
}


#endif

/************************************************************************/
/*-    dbf_Invariants -- Sanity check on dbf.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int dbf_Invariants (
    FILE*   errlog,
    Vm_Uch* title,
    Vm_Obj  dbf
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, dbf );
#endif
    return errs;
}





/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/




/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/



/************************************************************************/
/*-    for_new -- Initialize new dbf object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Vm_Obj netinfo_til         = til_Alloc();

    Vm_Obj propdir_pil[ OBJ_PROP_MAX ];

    Vm_Obj symbol_type_mil     = mil_Alloc();
    Vm_Obj symbol_proplist_mil = mil_Alloc();

    Dbf_P  m;

    int  i;
    for (i = OBJ_PROP_MAX;   i --> 0;   ) {
        propdir_pil[i] = pil_Alloc();
    }
    
    m = DBF_P(o);

    m->o.objname                             = stg_From_Asciz(vm_DbId_To_Asciz(VM_DBFILE(o)));

    m->bytes_between_garbage_collections     = OBJ_FROM_INT(OBJ_BYTES_BETWEEN_GARBAGE_COLLECTIONS);
    m->date_of_last_garbage_collect          = OBJ_FROM_INT(0);
    m->millisecs_for_last_garbage_collect    = OBJ_FROM_INT(0);
    m->objs_recovered_in_last_garbage_collect= OBJ_FROM_INT(0);
    m->byts_recovered_in_last_garbage_collect= OBJ_FROM_INT(0);
    m->garbage_collects_done                 = OBJ_FROM_INT(0);
    m->owner                                 = jS.j.acting_user;
    m->netinfo_til                           = netinfo_til;
    m->symbol_type_mil                       = symbol_type_mil;
    m->symbol_proplist_mil                   = symbol_proplist_mil;

    for (i = OBJ_PROP_MAX;         i --> 0;   )   m->propdir_pil[i]   =  propdir_pil[i];
    for (i = DBF_RESERVED_SLOTS;   i --> 0;   )   m->reserved_slot[i] = OBJ_FROM_INT(0);

    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_dbf -- Return size of databasefile object.		*/
/************************************************************************/

static Vm_Unt
sizeof_dbf(
    Vm_Unt size
) {
    return sizeof( Dbf_A_Header );
}






/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int invariants(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj  dbf
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif




/************************************************************************/
/*-    --- Static propfns --						*/
/************************************************************************/

/************************************************************************/
/*-    dbf_x_get -- Get value for given 'key'.			       	*/
/************************************************************************/

static Vm_Obj
dbf_x_get(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    if (propdir != OBJ_PROP_HIDDEN)   return obj_X_Get( obj, key, propdir );
    return key;	/* Buggo, should check that it is valid key in correct db. */
}

/************************************************************************/
/*-    dbf_x_key -- 							*/
/************************************************************************/

static Vm_Obj
dbf_x_key(
    Vm_Obj obj,
    Vm_Obj key,	/* OBJ_NOT_FOUND else take 1st eligible key before/after it.*/
    Vm_Obj val, /* Accept only keys with this value. */
    Vm_Int forward, /* TRUE to search forward, FALSE to search backward. */
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_HIDDEN)   return obj_X_Key( obj, key, val, forward, propdir );
    return key;	/* Buggo, should check that it is valid key in correct db. */
}

/************************************************************************/
/*-    dbf_x_set -- 							*/
/************************************************************************/

static Vm_Uch*
dbf_x_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    if (propdir != OBJ_PROP_HIDDEN)   return obj_X_Set( obj, key, val, propdir );

    MUQ_WARN("May not set hidden properties on dbf objects");
    return NULL;	/* Just to quiet compilers. */
}

/************************************************************************/
/*-    dbf_x_del -- Delete value for given 'key'.		       	*/
/************************************************************************/

static Vm_Obj
dbf_x_del(
    Vm_Obj  obj,
    Vm_Obj  key,
    Vm_Int  propdir
) {
    if (propdir != OBJ_PROP_HIDDEN)   return obj_X_Del( obj, key, propdir );
    MUQ_WARN("May not delete hidden properties on dbf objects");
    return OBJ_NOT_FOUND; /* Just to quiet compilers */
}

/************************************************************************/
/*-    dbf_x_get_asciz -- Return next key in obj else OBJ_NOT_FOUND.    */
/************************************************************************/

static Vm_Obj
dbf_x_get_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    if (propdir != OBJ_PROP_HIDDEN)   return obj_X_Get_Asciz( obj, key, propdir );
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    dbf_x_next -- Return next key in obj else OBJ_NOT_FOUND.      	*/
/************************************************************************/

static Vm_Obj
dbf_x_next(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Obj result;

    if (propdir != OBJ_PROP_HIDDEN)   return obj_X_Next( obj, key, propdir );

    if (key == OBJ_FIRST)  result = vm_First(      vm_Db( VM_DBFILE(obj) )  );
    else                   result = vm_Next(  key, vm_Db( VM_DBFILE(obj) )  );

    if (!result)  return OBJ_NOT_FOUND;
    return result;
}

/************************************************************************/
/*-    dbf_vm_object_makes        					*/
/************************************************************************/

static Vm_Obj dbf_vm_object_makes(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->object_creates );
}



/************************************************************************/
/*-    dbf_vm_object_saves        					*/
/************************************************************************/

static Vm_Obj dbf_vm_object_saves(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->object_sends );
}



/************************************************************************/
/*-    dbf_vm_object_loads        					*/
/************************************************************************/

static Vm_Obj dbf_vm_object_loads(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->object_reads );
}



/************************************************************************/
/*-    dbf_vm_octave_file_path        					*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static Vm_Obj dbf_vm_octave_file_path(
    Vm_Obj o
) {
    return stg_From_Asciz( vm_Octave_File_Path );
}
#endif



/************************************************************************/
/*-    dbf_bytes_between_gcs          					*/
/************************************************************************/

static Vm_Obj
dbf_bytes_between_gcs(
    Vm_Obj o
) {
    return DBF_P(o)->bytes_between_garbage_collections;
}



/************************************************************************/
/*-    dbf_bytes_since_last_gc          				*/
/************************************************************************/

static Vm_Obj
dbf_bytes_since_last_gc(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->bytes_allocated_since_last_garbage_collection );
}

/************************************************************************/
/*-    dbf_garbage_collects	          				*/
/************************************************************************/

static Vm_Obj
dbf_garbage_collects(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->garbage_collects_completed );
}

/************************************************************************/
/*-    dbf_date_of_last_garbage_collect        				*/
/************************************************************************/

static Vm_Obj
dbf_date_of_last_garbage_collect(
    Vm_Obj o
) {
    return DBF_P(o)->date_of_last_garbage_collect;
}

/************************************************************************/
/*-    dbf_millisecs_for_last_garbage_collect       			*/
/************************************************************************/

static Vm_Obj
dbf_millisecs_for_last_garbage_collect(
    Vm_Obj o
) {
    return DBF_P(o)->millisecs_for_last_garbage_collect;
}

/************************************************************************/
/*-    dbf_blocks_recovered_in_last_garbage_collect			*/
/************************************************************************/

static Vm_Obj
dbf_blocks_recovered_in_last_garbage_collect(
    Vm_Obj o
) {
    return DBF_P(o)->objs_recovered_in_last_garbage_collect;
}

/************************************************************************/
/*-    dbf_bytes_recovered_in_last_garbage_collect			*/
/************************************************************************/

static Vm_Obj
dbf_bytes_recovered_in_last_garbage_collect(
    Vm_Obj o
) {
    return DBF_P(o)->byts_recovered_in_last_garbage_collect;
}

/************************************************************************/
/*-    dbf_vm_bytes_in_useful_data					*/
/************************************************************************/

static Vm_Obj
dbf_vm_bytes_in_useful_data(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->bytes_in_useful_data );
}



/************************************************************************/
/*-    dbf_vm_bytes_lost_in_used_blocks					*/
/************************************************************************/

static Vm_Obj
dbf_vm_bytes_lost_in_used_blocks(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->bytes_lost_in_used_blocks );
}



/************************************************************************/
/*-    dbf_vm_bytes_in_free_blocks					*/
/************************************************************************/

static Vm_Obj
dbf_vm_bytes_in_free_blocks(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->bytes_in_free_blocks );
}



/************************************************************************/
/*-    dbf_vm_free_blocks						*/
/************************************************************************/

static Vm_Obj
dbf_vm_free_blocks(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->free_blocks );
}



/************************************************************************/
/*-    dbf_vm_used_blocks						*/
/************************************************************************/

static Vm_Obj
dbf_vm_used_blocks(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Db_Stats(o)->used_blocks );
}




/************************************************************************/
/*-    dbf_set_bytes_between_gcs					*/
/************************************************************************/

static Vm_Obj
dbf_set_bytes_between_gcs(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && (i = OBJ_TO_INT(v))
    &&  i > 0
    ){
	obj_Bytes_Between_Garbage_Collections = i;
	DBF_P(o)->bytes_between_garbage_collections = OBJ_FROM_INT(i);	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    dbf_set_never	 						*/
/************************************************************************/

static Vm_Obj
dbf_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    dbf_set_garbage_collects       					*/
/************************************************************************/

static Vm_Obj
dbf_set_garbage_collects(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	obj_Garbage_Collects = OBJ_TO_INT(v);
	DBF_P(o)->garbage_collects_done = OBJ_FROM_INT(v);	vm_Dirty(o);
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
