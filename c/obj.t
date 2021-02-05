@example  @c
/* buggo: allocating an extremely large anything currently crashes us. */
/*--   obj.c -- Object system functionality.				*/
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
/* Created:      93Jan04						*/
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

/* This has moved to "Vm_Obj Tagbits" node in muqimp.texi.		*/



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"
#include "Version.h"

/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Size of buf big enough to handle */
/* any special prop name in muq:    */
#ifndef OBJ_MAX_SPECIALPROP_NAME
#define OBJ_MAX_SPECIALPROP_NAME	(64)
#endif

/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static Vm_Unt sizeof_obj(      Vm_Unt );
static void   for_new(         Vm_Obj, Vm_Unt );
static void   initialize_obj_pointer_type( void );
static void   initialize_obj_immediate( void );
static void   obj_sort_system_properties_table( Obj_Special_Property );
static Vm_Obj maybe_rebuild_keyword_package(void);

#ifdef CURRENTLY_UNUSED
static void   obj_startup(  void              );
static void   obj_linkup(   void              );
static void   obj_shutdown( void              );
#endif

static Vm_Uch*obj_type_bad_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj obj_type_bad_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj obj_type_bad_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj obj_type_bad_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch*obj_type_bad_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj obj_type_bad_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj obj_type_bad_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void   obj_type_bad_export(  FILE*, Vm_Obj, Vm_Int );

static Vm_Uch*obj_type_obj_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj obj_type_obj_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void   obj_type_obj_export(  FILE*, Vm_Obj, Vm_Int );
static Vm_Obj obj_type_obj_hash(    Vm_Obj );

static void   obj_enqueue_exported_subobject( Vm_Obj );
static void   obj_export_any( FILE*, Vm_Obj, Vm_Int );

static Vm_Obj  obj_x_del(     Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  obj_x_get(     Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  obj_x_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* obj_x_set(     Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  obj_x_next(    Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  obj_x_key(     Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int, Vm_Int );
static Vm_Obj  obj_reverse(   Vm_Obj );

static Vm_Obj  bad_get_mos_key(	   Vm_Obj );
static Vm_Obj  typ_get_mos_key(    Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Exported for OBJ_FLOAT_VAL macro: */
Job_An_Any obj_Kludge;
Job_An_Any obj_Kludge2;

Obj_Export_Stats obj_Export_Stats;

/* Directory in which to look for       */
/* servers -- "/usr/people/pat/muq/srv" */
/* would be a typical value.            */
Vm_Uch* obj_Srv_Dir = NULL;	/* Set by lib_Validate_Srv_Directory() */

Vm_Unt obj_Date_Of_Next_Backup  = 0;/* Initialized in muq.t */
Vm_Unt obj_Date_Of_Last_Backup  = 0;
Vm_Unt obj_Date_Of_Last_Garbage_Collect = 0;
Vm_Unt obj_Millisecs_For_Last_Garbage_Collect = 0;
Vm_Unt obj_Millisecs_For_Last_Backup = 0;
Vm_Unt obj_Millisecs_Between_Backups = 0;
Vm_Int obj_Garbage_Collects = 0;

Vm_Int obj_Quick_Start = TRUE;
Vm_Int obj_Write_Pid_File = TRUE;
Vm_Int obj_Ignore_Server_Signature = FALSE;
Vm_Int obj_No_Environment = FALSE;
Vm_Uch obj_Allowed_Outbound_Net_Ports[0x1FFF];
Vm_Uch obj_Root_Allowed_Outbound_Net_Ports[0x1FFF];

/* The below numbers correspond to:                   */
/*     7 echo                                         */
/*     9 discard			              */
/*    13 daytime			              */
/*    19 chargen (character generator)	              */
/*    20 ftp-data			              */
/*    21 ftp				              */
/*    23 telnet				              */
/*    37 time				              */
/*    53 domain (Domain Namserver system)             */
/*    70 gopher				              */
/*    79 finger				              */
/*    80 wwweb				              */
/*   113 auth -- in.authd: maps port# to login name   */
/*   119 nntp				              */
/*   123 ntp				              */
/*   194 irc				              */
/*   517 talk				              */
/*   518 ntalk				              */
/*   532 netnews			              */
/*   750 kerberos			              */
/*   ... plus various numbers culled from a mudlist   */
/*       minus significant conflicts with RFC 1700.   */
/*  8080 wwweb				              */
#ifndef OBJ_ALLOWED_OUTBOUND_NET_PORTS
#define OBJ_ALLOWED_OUTBOUND_NET_PORTS                                \
 "7,9,13,19,20,21,23,37,53,70,79,80,113,119,123,194,517,518,532,750," \
 "1234,1701,1812,1863,1908,1919,1941,1963,1969,"              \
 "1973,1984,2000,2001,2002,2010,2069,2093,2095,"              \
 "2113,2150,2222,2283,2345,2444,2477,2508,2525,"              \
 "2700,2777,2779,2800,2994,2999,3000,3011,3019,"              \
 "3026,3056,3287,3456,3500,3742,3754,3779,4000,"              \
 "4001,4004,4040,4080,4201,4242,4321,4402,4441,"              \
 "4444,4445,4567,4711,5000,5150,5195,5440,5454,"              \
 "5555,5757,6123,6239,6250,6666,6669,6715,6789,"              \
 "6886,6889,6969,6970,6971,6972,6996,6999,"                   \
 "7000-17006,17008-65535"
#endif
#ifndef OBJ_ROOT_ALLOWED_OUTBOUND_NET_PORTS
#define OBJ_ROOT_ALLOWED_OUTBOUND_NET_PORTS \
    OBJ_ALLOWED_OUTBOUND_NET_PORTS          \
    ",25"
/* The above numbers correspond to:         */
/*    25 smtp (email)			    */
#endif

/************************************************************************/
/*-    system_properties[]						*/
/************************************************************************/

Obj_A_Special_Property system_properties[] = {

    /* We keep these in a header file */
    /* for the sake of other classes: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

/************************************************************************/
/*-    obj_Hardcoded_Dum_Class						*/
/************************************************************************/

Obj_A_Hardcoded_Class obj_Hardcoded_Dum_Class = {
    OBJ_FROM_BYT3('d','u','m'),
    "Dummy",
    sizeof_obj,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Bad_Hash,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class obj_Hardcoded_Obj_Class = {
    OBJ_FROM_BYT3('o','b','j'),
    "Plain",
    sizeof_obj,
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
    { system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

/************************************************************************/
/*-    obj_Module_Summary						*/
/************************************************************************/

static void obj_doTypes(void){
    /* At present we get called twice, once each for 'dum' */
    /* and 'obj' entries in mod_Module_Summary[].  It may  */
    /* be this should be considered a bug and fixed, but   */
    /* for now we'll just tolerate it:                     */
    if (mod_Type_Summary[ OBJ_TYPE_OBJ ] != &obj_Type_Bad_Summary
    &&  mod_Type_Summary[ OBJ_TYPE_OBJ ] != &obj_Type_Obj_Summary
    ){
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_OBJ");
    }
    mod_Type_Summary[ OBJ_TYPE_OBJ ] = &obj_Type_Obj_Summary;
}

Obj_A_Module_Summary obj_Module_Summary = {
   "obj",
    obj_doTypes,
    obj_Startup,
    obj_Linkup,
    obj_Shutdown,
};

/************************************************************************/
/*-    obj_Type_Obj_Summary						*/
/************************************************************************/

Obj_A_Type_Summary  obj_Type_Obj_Summary = {    OBJ_FROM_BYT3('o','b','j'),
    obj_type_obj_sprintX,
    obj_type_obj_sprintX,
    obj_type_obj_sprintX,
    obj_x_del,
    obj_x_get,
    obj_x_g_asciz,
    obj_x_set,
    obj_x_next,
    obj_x_key,
    obj_type_obj_hash,
    obj_reverse,
    typ_get_mos_key,
    obj_type_obj_import,
    obj_type_obj_export,
    "",
    OBJ_0,
    OBJ_0
};

/************************************************************************/
/*-    obj_Pointer_Type[] -- map from pointer lower bits to type.	*/
/************************************************************************/

Vm_Int obj_Pointer_Type[ 1 << OBJ_MAX_SHIFT /* Currently 1024 */ ];

/************************************************************************/
/*-    obj_Immediate[] -- map from pointer lower bits to TRUE/FALSE.	*/
/************************************************************************/

/* Will be TRUE iff it is safe to do fixnum obj_Neql() compare: */
Vm_Uch obj_Immediate[ 1 << OBJ_MAX_SHIFT /* Currently 1024 */ ];

/************************************************************************/
/*-    obj_Propdir_Name[] -- name of each propdir type			*/
/************************************************************************/

Vm_Uch* obj_Propdir_Name[ OBJ_PROP_MAX ] = {
    "system",
    "public",
    "hidden",
    "admins"
};

/************************************************************************/
/*-    obj_Type_Bad_Summary --						*/
/************************************************************************/

Obj_A_Type_Summary obj_Type_Bad_Summary = {    OBJ_FROM_BYT1('?'),
    obj_type_bad_sprintX,
    obj_type_bad_sprintX,
    obj_type_bad_sprintX,
    obj_type_bad_for_del,
    obj_type_bad_for_get,
    obj_type_bad_g_asciz,
    obj_type_bad_for_set,
    obj_type_bad_for_nxt,
    obj_X_Key,
    obj_Bad_Hash,
    obj_Dummy_Reverse,
    bad_get_mos_key,
    obj_type_bad_import,
    obj_type_bad_export,
    "",
    OBJ_0,
    OBJ_0
};

/************************************************************************/
/*-    obj_GC_Root[] -- Global pointers to frequently used objects.	*/
/************************************************************************/

/* See obj.h for explanation of contents: */
Vm_Obj obj_GC_Root[ OBJ_GC_ROOTS ];

/***********************************************/
/* The following variables publish information */
/* gathered by the interim garbage collector.  */
/* These variables are likely to vanish when   */
/* the production garbage collector appears.   */
/***********************************************/
Vm_Unt obj_Objs_Recovered = 0;
Vm_Unt obj_Objs_Remaining = 0;
Vm_Unt obj_Byts_Recovered = 0;
Vm_Unt obj_Byts_Remaining = 0;

Vm_Unt obj_Bytes_Between_Garbage_Collections = (
       OBJ_BYTES_BETWEEN_GARBAGE_COLLECTIONS
);

Vm_Unt obj_Stackframes_Popped_After_Loop_Stack_Overflow = (
       OBJ_STACKFRAMES_POPPED_AFTER_LOOP_STACK_OVERFLOW
);

Vm_Unt obj_Stackslots_Popped_After_Data_Stack_Overflow = (
       OBJ_STACKSLOTS_POPPED_AFTER_DATA_STACK_OVERFLOW
);

/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    obj_Startup -- Start-of-world code.				*/
/************************************************************************/

 /***********************************************************************/
 /*-   build_root_root							*/
 /***********************************************************************/

static Vm_Obj
build_root_root(
    void
) {
    /****************************************************/
    /* In a completely blank system, need to create	*/
    /* g*d and the root object.  Appropriately enough,	*/
    /* g*d has to exist before anything else can be	*/
    /* created:						*/
    /****************************************************/

    /**************/
    /* Create G*d */
    /**************/

    Vm_Obj gname;
    Vm_Int siz = (*mod_Hardcoded_Class[OBJ_CLASS_A_ROT]->sizeof_obj)(0);
    Vm_Obj g_d = vm_Malloc( siz, 0, OBJ_K_OBJ );

    /* Make g*d the current user: */
    job_RunState.j.acting_user = g_d;
    job_RunState.j.actual_user = g_d;

    /* That establishes enough state for regular */
    /* code to finish initializing g*d:		 */
    g_d = obj_Init( g_d, OBJ_CLASS_A_ROT, siz, 0 );

    {   Usr_P g = USR_P(g_d);

	/* And a name: */
	g->o.objname	= gname = stg_From_Asciz("root");

	/* Give god nice big quotas too: */
	g->object_quota	= USR_ROOT_OBJECT_QUOTA;
	g->byte_quota	= USR_ROOT_BYTE_QUOTA;

	/* Set all of gods privilege bits: */
        g->priv_bits    = OBJ_FROM_INT( ~0 );

	vm_Dirty(g_d);
    }
/* buggo, need to initialize jS.bytes_* jS.objects_* */

    /* Can now create root obj normally: */
    {   Vm_Obj dbf = obj_Alloc( OBJ_CLASS_A_DBF, 0 );
        vm_Set_Root(0,dbf);
        OBJ_P(vm_Root(0))->objname = stg_From_Asciz(vm_DbId_To_Asciz(0));
        vm_Dirty(dbf);
    }

    return g_d;
}

 /***********************************************************************/
 /*-   build_nul_and_muqnet						*/
 /***********************************************************************/

static void
build_nul_and_muqnet(
    Vm_Obj g_d
) {
    Vm_Obj nul; /* Null user, to run thunks etc under.	*/
    Vm_Obj net; /* Muqnet identity.		 	*/

    /* Keyword object needs to exist next, */
    /* to allocate the keywords we use as  */
    /* property names:                     */
/*  obj_Lib_Keyword = maybe_rebuild_keyword_package();  */

    /* Create null user for when we need to clear	*/
    /* job_RunState.acting_user/actual_user to		*/
    /* something harmless, but still want them set	*/
    /* to a valid user object:				*/
    nul = obj_Alloc( OBJ_CLASS_A_USR, 0 );

    /* Create muqnet user so muqnet daemon can have an identity */
    /* separate from that of root (even though it in fact runs  */
    /* as root):                                                */
    net = obj_Alloc( OBJ_CLASS_A_USR, 0 );

    /* Create /u/ to hold all users, */
    /* and put g_d, nul and pat in it: */
    {   Vm_Obj u = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
	OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("u"),  u, OBJ_PROP_PUBLIC );
	OBJ_SET( u	  , stg_From_Asciz("root"),       g_d, OBJ_PROP_PUBLIC );
	OBJ_SET( u	  , stg_From_Asciz("nul"),        nul, OBJ_PROP_PUBLIC );

        OBJ_P( u )->objname = OBJ_FROM_BYT2('/','u'    );              vm_Dirty( u );
        OBJ_P(nul)->objname = OBJ_FROM_BYT3('n','u','l');              vm_Dirty(nul);
    }

    obj_Quick_Start = FALSE;
}

 /***********************************************************************/
 /*-   create_env							*/
 /***********************************************************************/

#ifndef OBJ_MAX_ENV_STRING
#define OBJ_MAX_ENV_STRING 1000
#endif

static void
create_env(
    void
) {

    /* Create object to hold environment: */
    Vm_Obj env = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );

    /* Declare standard array containing */
    /* unix environment:                 */
    extern char** environ;

    if (!obj_No_Environment) {

        /* Over all strings in unix environment: */
	Vm_Uch   buf[ OBJ_MAX_ENV_STRING+1 ];
	char** e;

	for   (e = environ;  *e;   ++e) {

	    /* Find first '=' in string: */
	    char* eq = strchr( *e, '=' );

	    /* Silently ignore environment strings with */
	    /* no '=' or a name inconveniently long:    */
	    if (eq) {
		Vm_Int len = eq-*e;
		if (len < OBJ_MAX_ENV_STRING) {
		    strncpy( buf, *e, len );
		    buf[ len ] = '\0';
		    OBJ_SET(
			env,
			stg_From_Asciz( buf  ),
			stg_From_Asciz( eq+1 ),
			OBJ_PROP_PUBLIC
		    );
    }   }   }   }

    /* Save environment as /env: */
    OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("env"), env, OBJ_PROP_PUBLIC );
    OBJ_P(env)->objname = stg_From_Asciz(".env");  vm_Dirty(env);
}

 /***********************************************************************/
 /*-   find_all_system_property_keywords				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-  find_system_property_keywords					*/
  /**********************************************************************/

static void
find_system_property_keywords(
    Obj_Special_Property table
) {
    /* Count number of entries in table: */
    Vm_Int i = 0;
    if (table==NULL)   return;
    for (i = 0;   table[ i ].name;   ++i) {
        table[ i ].keyword  = sym_Alloc_Asciz_Keyword( table[ i ].name );
    }
}

  /**********************************************************************/
  /*-  find_all_system_property_keywords				*/
  /**********************************************************************/

static void
find_all_system_property_keywords(
    void
) {

    Vm_Int     i;
    for       (i = OBJ_CLASS_MAX;   i --> 0;   ) {
	Vm_Int j;
	for   (j = OBJ_PROP_MAX ;   j --> 0;   ) {
	    find_system_property_keywords(
		mod_Hardcoded_Class[i]->propdir[j]
	    );
	}
    }
}

 /***********************************************************************/
 /*-   sort_system_properties_tables					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-  sort_system_properties_table					*/
  /**********************************************************************/

static void
obj_sort_system_properties_table(
    Obj_Special_Property table
) {
    /* Count number of entries in table: */
    Vm_Int block_size = 0;
    if (table==NULL)   return;
    while (table[ block_size ].name)  ++block_size;
    if (block_size <= 1)   return;

    /* Heapsort following Knuth.  Heapsort's best case is */
    /* about half as fast as Quicksort's best case, but	  */
    /* Heapsort's worst case is much the same as its best */
    /* case, while Quicksort's worst case is disastrous.  */
    /* Following the Numerical Recipes authors, I prefer  */
    /* consistently good performance to erratically    	  */
    /* excellent performance for general use.	       	  */
    {   /********************************************************/
	/* Definition:  We say part of the block is a 'heap' if */
	/* b[i] >= b[i/2] for all i,i/2 in the part.            */
        /*						        */
        /* Heapsort starts with two pointers 'left', 'roit'     */
	/* set so the block looks like:                         */
        /*						        */
	/*   untouched-half 'left' untouched-half 'roit'        */
        /*						        */
	/* It then advances 'left' to the left, one step at a   */
        /* time, re-establishing the heap property on all block */
        /* entries between 'left' and 'roit' after each move.   */
        /* While this is running, the block looks like:	        */
        /*						        */
	/*   untouched-part 'left' heap-part 'roit'             */
        /*						        */
        /* When this phase is complete, the block looks like:   */
        /*						        */
	/*   'left' heap-part 'roit'                            */
        /*						        */
        /* Heapsort then advances 'roit' one step at a time,    */
        /* replacing block[roit] by the greatest element in the */
        /* heap part (heap[0]), then inserting block[roit] in   */
        /* the heap.						*/
        /* While this is running, the block looks like:	        */
        /*						        */
	/*   'left' heap-part 'roit' sorted-part                */
        /*						        */
        /* When this phase is complete, the block looks like:   */
        /*						        */
	/*   'left' 'roit' sorted-part                          */
        /*						        */
        /* and we return, mission completed.                    */
        /********************************************************/


	/* Define comparison between two records: */
	#undef  LESS
#ifdef OLD
	#define LESS(x,y) ((x).keyword < (y).keyword)
#else
	#define LESS(x,y) (obj_Neql((x).keyword,(y).keyword) < 0)
#endif

	/* 'SIFT-UP':  Insert 'key' into the heap area 'twixt */
	/* 'left' and 'roit'.   There is currently a hole at  */
	/* 'left'.  If 'key' is greater than either child of  */
	/* the hole, we can simple put 'key' in the hole;     */
	/* otherwise, we fill the hole with the greatest of   */
	/* hole's two kids and then start over, trying to put */
	/* 'key' in the new hole just created:                */
	#undef  SIFT_UP
	#define SIFT_UP							    \
	{   Vm_Int hole = left;						    \
	    for (;;) {							    \
		Vm_Int R    = (hole+1)<<1;	/* Right kid of hole. */    \
		Vm_Int L    = R-1;		/* Left  kid of hole. */    \
		Vm_Int maxkid;			/* Max   kid of hole. */    \
									    \
		/* If kids L,R don't exist, can just put 'tmp' in hole: */  \
		if (L >= roit)            {  b[hole] = tmp;  break; }	    \
									    \
		/* Set maxkid to largest of hole's two kids, L and R:   */  \
		maxkid = (R < roit && LESS( b[L], b[R] )) ? R : L;	    \
									    \
		/* If 'tmp' > maxkid, put 'tmp' in hole and stop: */	    \
		if (LESS( b[maxkid], tmp )) { b[hole] = tmp; break; }	    \
									    \
		/* Biggest kid fills hole, loop to fill new hole: */	    \
		b[hole] = b[maxkid];					    \
		hole    = maxkid;					    \
        }   }\

	/* Find block, initialize 'left' and 'roit': */
        Obj_Special_Property b = table;      /* Base of our block. */
	Vm_Int  left = block_size/2 +1;	     /* Heap is slots k:   */
	Vm_Int  roit = block_size     ;	     /* left <= k < roit.  */
        Obj_A_Special_Property tmp    ;      /* Record in motion!  */

	/* Heap-build followed by heap-unbuild phases: */
	while (left-->0) { tmp = b[left];                 SIFT_UP; }  ++left;
	while (roit-->1) { tmp = b[roit]; b[roit] = b[0]; SIFT_UP; }
    }
}

  /**********************************************************************/
  /*-  sort_system_properties_tables					*/
  /**********************************************************************/

static void
sort_system_properties_tables(
    void
) {
    Vm_Int     i;
    for       (i = OBJ_CLASS_MAX;   i --> 0;   ) {
	Vm_Int j;
	for   (j = OBJ_PROP_MAX ;   j --> 0;   ) {
	    obj_sort_system_properties_table(
		mod_Hardcoded_Class[i]->propdir[j]
	    );
	}
    }
}

  /**********************************************************************/
  /*-  validate_hardwired_class_and_key_objects				*/
  /**********************************************************************/

static void
validate_hardwired_class_and_key_objects(
    void
) {
    Vm_Obj class_standard_class;
    Vm_Obj key_standard_class;

    Vm_Obj class_t;
    Vm_Obj key_t;
    Vm_Int i;

    /* First, verify that class t exists, */
    /* since we need it as parent for all */
    /* of the others:                     */
    {   Vm_Obj sym = lib_Validate_Symbol( "t", obj_Lib_Muf );

	/* Make sure class object exists: */
	Vm_Obj cdf = sym_Type(sym);
	if (!OBJ_IS_OBJ(cdf) || !OBJ_IS_CLASS_CDF(cdf)) {
	    Vm_Obj name = stg_From_Asciz( "t" );
	    cdf = obj_Alloc( OBJ_CLASS_A_CDF, 0 );
	    sym_Set_Type(sym,cdf);
	    CDF_P(cdf)->o.objname = name;
	    vm_Dirty(cdf);
	}

	/* Make sure class object points to */
	/* mosKey for valid builtin class: */
	{   Vm_Obj key = CDF_P(cdf)->key;
	    if (!OBJ_IS_OBJ(key) || !OBJ_IS_CLASS_KEY(key)) {
		key  = key_Alloc(
		    cdf,	/* mos_class		*/
		    0,		/* unshared_slots	*/
		    0,		/* shared_slots		*/
		    0,		/* mos_parents		*/
		    1,		/* mos_ancestors	*/
		    0,		/* slotargs		*/
		    0,		/* methargs		*/
		    0,		/* initargs		*/
		    0,		/* object_methods	*/
		    0		/* class_methods	*/
		);

		job_Set_Mos_Key_Ancestor( key, 0, cdf );

		KEY_P(key)->o.objname = stg_From_Asciz( "t" );
		vm_Dirty(key);

		CDF_P(cdf)->key = key;
		vm_Dirty(cdf);
	    }
	    class_t = cdf;
	    key_t   = key;
	}
    }

    /* Class standardClass is likewise    */
    /* needed as a parent for our classes: */
    {   Vm_Obj sym = lib_Validate_Symbol( "standardClass", obj_Lib_Muf );

	/* Make sure class object exists: */
	Vm_Obj cdf = sym_Type(sym);
	if (!OBJ_IS_OBJ(cdf) || !OBJ_IS_CLASS_CDF(cdf)) {
	    Vm_Obj name = stg_From_Asciz( "standardClass" );
	    cdf = obj_Alloc( OBJ_CLASS_A_CDF, 0 );
	    sym_Set_Type(sym,cdf);
	    CDF_P(cdf)->o.objname = name;
	    vm_Dirty(cdf);
	}

	/* Make sure class object points to */
	/* mosKey for valid builtin class: */
	{   Vm_Obj key = CDF_P(cdf)->key;
	    if (!OBJ_IS_OBJ(key) || !OBJ_IS_CLASS_KEY(key)) {
		key  = key_Alloc(
		    cdf,	/* mos_class		*/
		    0,		/* unshared_slots	*/
		    0,		/* shared_slots		*/
		    1,		/* mos_parents		*/
		    2,		/* mos_ancestors	*/
		    0,		/* slotargs		*/
		    0,		/* methargs		*/
		    0,		/* initargs		*/
		    0,		/* object_methods	*/
		    0		/* class_methods	*/
		);

		job_Set_Mos_Key_Parent(   key, 0, class_t   );

		job_Set_Mos_Key_Ancestor( key, 0, cdf       );
		job_Set_Mos_Key_Ancestor( key, 1, class_t   );

		KEY_P(key)->o.objname = stg_From_Asciz( "standardClass" );
		vm_Dirty(key);

		CDF_P(cdf)->key = key;
		vm_Dirty(cdf);
	    }
	    class_standard_class = cdf;
	    key_standard_class   = key;
	}
    }

    /* Over all hardwired classes c: */
    for   (i = OBJ_CLASS_MAX;   i --> 0;   ) {
	Obj_Hardcoded_Class c = mod_Hardcoded_Class[i];

	/* Find/create matching muf: symbol: */
	Vm_Obj sym = lib_Validate_Symbol( c->fullname, obj_Lib_Muf );

	/* Make sure class object exists: */
	Vm_Obj cdf = sym_Type(sym);
	if (!OBJ_IS_OBJ(cdf) || !OBJ_IS_CLASS_CDF(cdf)) {
	    Vm_Obj name = stg_From_Asciz( c->fullname );
	    cdf = obj_Alloc( OBJ_CLASS_A_CDF, 0 );
	    sym_Set_Type(sym,cdf);
	    CDF_P(cdf)->o.objname = name;
	    vm_Dirty(cdf);
	}

	/* Make sure class object points to */
	/* mosKey for valid builtin class: */
	{   Vm_Obj key = CDF_P(cdf)->key;
	    if (!OBJ_IS_OBJ(key) || !OBJ_IS_CLASS_KEY(key)) {
		Vm_Obj name = CDF_P(cdf)->o.objname;
		key  = key_Alloc(
		    cdf,	/* mos_class		*/
		    0,		/* unshared_slots	*/
		    0,		/* shared_slots		*/
		    2,		/* mos_parents		*/
		    3,		/* mos_ancestors	*/
		    0,		/* slotargs		*/
		    0,		/* methargs		*/
		    0,		/* initargs		*/
		    0,		/* object_methods	*/
		    0		/* class_methods	*/
		);

		job_Set_Mos_Key_Parent(   key, 0, class_standard_class );
		job_Set_Mos_Key_Parent(   key, 1, class_t              );

		job_Set_Mos_Key_Ancestor( key, 0, cdf                  );
		job_Set_Mos_Key_Ancestor( key, 1, class_standard_class );
		job_Set_Mos_Key_Ancestor( key, 2, class_t              );
                job_Link_Mos_Key_To_Ancestor( key, 1 );

		KEY_P(key)->o.objname = name;
		KEY_P(key)->layout    = KEY_LAYOUT_BUILT_IN;
		vm_Dirty(key);

		CDF_P(cdf)->key = key;
		vm_Dirty(cdf);
	    }
	    c->builtin_class = cdf;
	}
    }
}

  /**********************************************************************/
  /*-  validate_hardwired_type_and_key_objects				*/
  /**********************************************************************/

static void
validate_hardwired_type_and_key_objects(
    void
) {
    /* Over all hardwired types c: */
    Vm_Int i;
    for   (i = OBJ_TYPE_MAX;   i --> 0;   ) {
	Obj_Type_Summary c = mod_Type_Summary[i];

	/* If a built-in class is named: */
	if (*c->fullname) {

	    /* Find/create matching muf: symbol: */
	    Vm_Obj sym = lib_Validate_Symbol( c->fullname, obj_Lib_Lisp );

	    /* If class object exists: */
	    Vm_Obj cdf = sym_Type(sym);
	    if (OBJ_IS_OBJ(cdf) && OBJ_IS_CLASS_CDF(cdf)) {

	        /* If class object points to */
	        /* mosKey for valid class:  */
	        Vm_Obj key = CDF_P(cdf)->key;
	        c->builtin_class = cdf;
	        if (OBJ_IS_OBJ(key) && OBJ_IS_CLASS_KEY(key)) {

		    /* Set storage class as specified: */
		    if (KEY_P(key)->layout != c->layout) {
			KEY_P(key)->layout  = c->layout;
			vm_Dirty(key);
		    }
		}
	    }
	}
    }
}

 /***********************************************************************/
 /*-   maybe_rebuild_event_propdir -- Create .e if bogus.		*/
 /***********************************************************************/

static Vm_Obj
maybe_rebuild_event_propdir(
    void
) {
    /* Make sure .e exists: */
    Vm_Obj evt = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("e"), OBJ_PROP_PUBLIC );
    if (evt==OBJ_NOT_FOUND || !OBJ_IS_OBJ(evt)) {
	evt = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
	OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("e"), evt, OBJ_PROP_PUBLIC );
	OBJ_P(evt)->objname = stg_From_Asciz(".e");  vm_Dirty(evt);

	/* If we had to create .e, quickstarting */
	/* isn't a practical idea:               */
	obj_Quick_Start = FALSE;
    }

    return evt;
}

 /***********************************************************************/
 /*-   maybe_rebuild_folkBy_hashName -- .folkBy.hashName		*/
 /***********************************************************************/

static Vm_Obj
maybe_rebuild_folkBy_hashName(
    void
) {
    /* Make sure .folkBy. exists: */
    Vm_Obj uby = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("folkBy"), OBJ_PROP_PUBLIC );
    if (uby==OBJ_NOT_FOUND || !OBJ_IS_OBJ(uby)) {
	uby = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
	OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("folkBy"), uby, OBJ_PROP_PUBLIC );
	OBJ_P(uby)->objname = stg_From_Asciz(".folkBy");  vm_Dirty(uby);
    }
    {   Vm_Obj hnm = OBJ_GET( uby, sym_Alloc_Asciz_Keyword("hashName"), OBJ_PROP_PUBLIC );
        if (hnm==OBJ_NOT_FOUND || !OBJ_IS_OBJ(hnm)) {
	    hnm = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
	    OBJ_SET( uby, sym_Alloc_Asciz_Keyword("hashName"), hnm, OBJ_PROP_PUBLIC );
	    OBJ_P(hnm)->objname = stg_From_Asciz(".folkBy.hashName");  vm_Dirty(hnm);
	}
	return hnm;
    }
}

 /***********************************************************************/
 /*-   maybe_rebuild_etc_rc2_d -- Create .etc.rc2D. if bogus.		*/
 /***********************************************************************/

static Vm_Obj
maybe_rebuild_etc_rc2_d(
    void
) {
    /* Make sure .etc.rc2D exists: */
    Vm_Obj rc2d = OBJ_GET( obj_Etc, sym_Alloc_Asciz_Keyword("rc2D"), OBJ_PROP_PUBLIC );
    if (rc2d==OBJ_NOT_FOUND || !OBJ_IS_OBJ(rc2d)) {
	rc2d = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
	OBJ_SET( obj_Etc, sym_Alloc_Asciz_Keyword("rc2D"), rc2d, OBJ_PROP_PUBLIC );
	OBJ_P(rc2d)->objname = stg_From_Asciz(".etc.rc2D");  vm_Dirty(rc2d);

	/* If we had to create .etc.rc2D, quickstarting */
	/* isn't a practical idea:                      */
	obj_Quick_Start = FALSE;
    }

    return rc2d;
}

 /***********************************************************************/
 /*-   maybe_rebuild_lib_propdir -- Create .lib if missing or bogus.	*/
 /***********************************************************************/

static Vm_Obj
maybe_rebuild_lib_propdir(
    void
) {
    /* Make sure .lib exists: */
    Vm_Obj lib = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("lib"), OBJ_PROP_PUBLIC );
    if (lib==OBJ_NOT_FOUND || !OBJ_IS_OBJ(lib)) {
	lib = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
	OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("lib"), lib, OBJ_PROP_PUBLIC );
	OBJ_P(lib)->objname = stg_From_Asciz(".lib");  vm_Dirty(lib);

	/* Enter keyword package into .lib: */
	OBJ_SET(
	    lib,
	    stg_From_Asciz("keyword"),
	    obj_Lib_Keyword,
	    OBJ_PROP_PUBLIC
	);

	/* If we had to create .lib, quickstarting */
	/* isn't a practical idea:                 */
	obj_Quick_Start = FALSE;
    }

    return lib;
}

 /***********************************************************************/
 /*-   maybe_rebuild_db_propdir -- Create .db if missing or bogus.	*/
 /***********************************************************************/

static Vm_Obj
maybe_rebuild_db_propdir(
    void
) {
    /* Make sure .db exists: */
    Vm_Obj db = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("db"), OBJ_PROP_PUBLIC );
    if (db==OBJ_NOT_FOUND || !OBJ_IS_OBJ(db)) {
	db = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
	OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("db"), db, OBJ_PROP_PUBLIC );
	OBJ_P(db)->objname = stg_From_Asciz(".db");  vm_Dirty(db);

	/* "KEYW" dbfile has already been created: */
	OBJ_SET(
	    db,
	    stg_From_Asciz("KEYW"),
	    vm_Root(vm_Asciz_To_DbId("KEYW")),
	    OBJ_PROP_PUBLIC
	);

	/* "ROOTDB" dbfile has already been created: */
	OBJ_SET(
	    db,
	    stg_From_Asciz(vm_DbId_To_Asciz(0)),
	    vm_Root(0),
	    OBJ_PROP_PUBLIC
	);


	/* If we had to create .db, quickstarting */
	/* isn't a practical idea:                */
	obj_Quick_Start = FALSE;
    }

    return db;
}

 /***********************************************************************/
 /*-   maybe_rebuild_keyword_package -- 				*/
 /***********************************************************************/

static Vm_Obj
maybe_rebuild_keyword_package(
    void
) {
    /* Make sure KEYW dbfile exists and is mounted: */
    Vm_Unt dbfile = vm_Asciz_To_DbId("KEYW");
    if (!vm_Db_Is_Mounted(dbfile)
    &&  !vm_Make_Db( dbfile)
    ){
	MUQ_FATAL("Couldn't make or mount KEYWord db?!");
    }

    {   /* This one presents a classic little bootstrap problem: */
	/* we use keywords as our standard keys, so we can't     */
	/* find the keyword package 'til we've found the keyword */
	/* package!  We dodge this problem by also storing the   */
	/* keyword package under the string "key" in the admins  */
	/* area on the root object:                              */
	Vm_Obj key = obj_Admins_Get( vm_Root(0), OBJ_FROM_BYT3('k','e','y') );
	if (key==OBJ_NOT_FOUND
	|| !OBJ_IS_OBJ(key)
	|| !OBJ_IS_CLASS_PKG(key)
	){
	    Vm_Obj name = stg_From_Asciz( "keyword" );
	    Vm_Obj dbf  = obj_Alloc_In_Dbfile( OBJ_CLASS_A_DBF, 0, dbfile );
	    key         = obj_Alloc_In_Dbfile( OBJ_CLASS_A_PKG, 0, dbfile );
	    PKG_P(key)->o.objname = name;  vm_Dirty(key);
	    obj_Admins_Set( vm_Root(0), OBJ_FROM_BYT3('k','e','y'), key );

	    DBF_P(dbf)->o.objname = stg_From_Asciz(vm_DbId_To_Asciz(dbfile));
            vm_Set_Root(dbfile,dbf);    vm_Dirty(dbf);
	}

	return key;
    }
}

 /***********************************************************************/
 /*-   maybe_rebuild_package -- "  .lib.xxx               ".	        */
 /***********************************************************************/

  /**********************************************************************/
  /*-  maybe_install_nickname						*/
  /**********************************************************************/

static void
maybe_install_nickname(
    Vm_Obj  pkg,
    Vm_Uch* nickname
) {
    if (!nickname)   return;

    {   Vm_Obj pn = PKG_P(pkg)->nicknames;
	if (OBJ_IS_OBJ(pn)) {
	    Vm_Obj nn = stg_From_Asciz( nickname );
	    OBJ_SET( pn, nn, nn, OBJ_PROP_PUBLIC );
    }   }
}

#ifdef CURRENTLY_UNUSED
static Vm_Obj
maybe_rebuild_package(
    Vm_Uch* name,
    Vm_Uch* nickname0,
    Vm_Uch* nickname1
) {
    /* Make sure /lib/xxx/ exists: */
    Vm_Obj obj = OBJ_GET_ASCIZ( obj_Lib, name, OBJ_PROP_PUBLIC );
    if (obj==OBJ_NOT_FOUND
    || !OBJ_IS_OBJ(obj)
    || !OBJ_IS_CLASS_PKG(obj)
    ){
        Vm_Obj nm = stg_From_Asciz(name);
	obj = obj_Alloc( OBJ_CLASS_A_PKG, 0 );
        PKG_P(obj)->o.objname = nm;  vm_Dirty(obj);
	OBJ_SET( obj_Lib, nm, obj, OBJ_PROP_PUBLIC );

	maybe_install_nickname( obj, nickname0 );
	maybe_install_nickname( obj, nickname1 );
    }

    return obj;
}
#endif

 /***********************************************************************/
 /*-   establish_dbfile -- 					        */
 /***********************************************************************/

static void
establish_dbfile(
    Vm_Uch* dbname
) {
    /* Make sure dbfile exists and is mounted: */
    Vm_Unt dbfile = vm_Asciz_To_DbId(dbname);
    if (!vm_Db_Is_Mounted(dbfile)
    &&  !vm_Make_Db( dbfile)
    ){
	MUQ_FATAL("Couldn't make or mount db?!");
    }
}

 /***********************************************************************/
 /*-   maybe_rebuild_dbfile -- 					        */
 /***********************************************************************/

static Vm_Obj
maybe_rebuild_dbfile(
    Vm_Uch* dbname,
    Vm_Uch* name,
    Vm_Uch* nickname0,
    Vm_Uch* nickname1
) {
    /* Make sure dbfile exists and is mounted: */
    Vm_Unt dbfile = vm_Asciz_To_DbId(dbname);

    {   /* Make sure .lib[name] exists: */
	Vm_Obj obj = OBJ_GET_ASCIZ( obj_Lib, name, OBJ_PROP_PUBLIC );
	if (obj==OBJ_NOT_FOUND
	|| !OBJ_IS_OBJ(obj)
	|| !OBJ_IS_CLASS_PKG(obj)
	){
	    Vm_Obj nm = stg_From_Asciz(name);
	    Vm_Obj dbf= obj_Alloc_In_Dbfile( OBJ_CLASS_A_DBF, 0, dbfile );
	    obj       = obj_Alloc_In_Dbfile( OBJ_CLASS_A_PKG, 0, dbfile );
	    PKG_P(obj)->o.objname = nm;  vm_Dirty(obj);
	    OBJ_SET( obj_Lib, nm, obj, OBJ_PROP_PUBLIC );

	    DBF_P(dbf)->o.objname = stg_From_Asciz(vm_DbId_To_Asciz(dbfile));
            vm_Set_Root(dbfile,dbf);    vm_Dirty(dbf);

	    maybe_install_nickname( obj, nickname0 );
	    maybe_install_nickname( obj, nickname1 );

	    /* Keep .db[] updated: */
	    OBJ_SET( obj_Db, stg_From_Asciz(dbname), vm_Root(dbfile), OBJ_PROP_PUBLIC );
	}

	return obj;
    }
}

 /***********************************************************************/
 /*-   maybe_initialize_users_packages --				*/
 /***********************************************************************/

static void
maybe_initialize_users_packages(
    Vm_Obj usr
){
    {   Vm_Obj lib = USR_P(usr)->lib;
        if (lib != obj_Lib		/* What usr objects should have.   */
	&&  lib != OBJ_FROM_INT(0)	/* Root winds up this way at first.*/
        ){
            return;
    }   }

    /* Remember current user: */
    {   Vm_Obj old_actual_user = job_RunState.j.actual_user;
        Vm_Obj old_acting_user = job_RunState.j.acting_user;

	/* Set 'usr' to be current user, so s/he */
	/* will own the lib/ we're creating:     */
	job_RunState.j.actual_user = usr;
	job_RunState.j.acting_user = usr;

	/* Create a private lib/ propdir: */
	{   Vm_Obj lib = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );

	    /* Create a private scratch package: */
	    Vm_Obj pkg = obj_Alloc( OBJ_CLASS_A_PKG, 0 );

	    /* Find name of 'usr': */
	    Vm_Obj nam = OBJ_P(usr)->objname;

	    /* Construct and install nice name for lib/: */
	    Vm_Uch nambuf[ 1024 ];
	    Vm_Uch buf[    2048 ];
	    Vm_Obj path;
	    if (stg_Is_Stg(nam)) {
		Vm_Int len = stg_Len( nam );
		if (len > 1023) len = 1023;
		if (len != stg_Get_Bytes( nambuf , len, nam, 0 )){
	            MUQ_WARN ("obj.t:maybe_initialize_users_packages: internal error");
		}
	        nambuf[len]='\0';
	    } else {
		strcpy( nambuf, "(someone)" );
	    }
	    sprintf(buf, ".u[\"%s\"]$s.lib", nambuf );
	    path = stg_From_Asciz(buf);
	    OBJ_P(lib)->objname = path;        vm_Dirty(lib);

	    /* Name scratch package after user: */
	    OBJ_P(pkg)->objname = nam;         vm_Dirty(pkg);

	    /* Enter lib/ into 'usr':  */
	    USR_P(usr)->lib = lib;             vm_Dirty(usr);

	    /* Make scratch package user's default package: */
	    USR_P(usr)->default_package	= pkg; vm_Dirty(usr);

	    /* Enter scratch package into new lib/: */
	    OBJ_SET( lib, nam, pkg, OBJ_PROP_PUBLIC );

	    /* Enter /lib/* into new lib/: */
	    {   Vm_Obj key;
		for(key  = OBJ_NEXT( obj_Lib, OBJ_FIRST, OBJ_PROP_PUBLIC );
		    key != OBJ_NOT_FOUND;
		    key  = OBJ_NEXT(  obj_Lib, key, OBJ_PROP_PUBLIC )
		){
		    /* Find the key's value: */
		    Vm_Obj pkg = OBJ_GET( obj_Lib, key, OBJ_PROP_PUBLIC );

		    /* We're only interested in packages: */
		    if (OBJ_IS_OBJ(      pkg)
		    &&  OBJ_IS_CLASS_PKG(pkg)
		    ){
			OBJ_SET( lib, key, pkg, OBJ_PROP_PUBLIC );
	}   }   }   }

	/* Restore original user: */
	job_RunState.j.actual_user = old_actual_user;
        job_RunState.j.acting_user = old_acting_user;
    }
}


 /***********************************************************************/
 /*-   validate_lib_constant -- Validate .lib.muf.nil &tc.		*/
 /***********************************************************************/

static Vm_Obj
validate_lib_constant(
    Vm_Obj  pkg,
    Vm_Uch* key
) {
    Vm_Obj sym = sym_Find_Exported_Asciz( pkg, key );
    if (!sym || !OBJ_IS_SYMBOL(sym)) {
	Vm_Obj nam = stg_From_Asciz(          key );
	sym = sym_Make();
	OBJ_SET( pkg, nam, sym, OBJ_PROP_HIDDEN );
	OBJ_SET( pkg, nam, sym, OBJ_PROP_PUBLIC );
	{   Sym_P s = SYM_P(sym);
	    s->name    = nam;
	    s->value   = sym;
	    s->function= SYM_CONSTANT_FLAG;
	    s->package = pkg;
	    vm_Dirty(sym);
	}
    }
    return sym;
}


 /***********************************************************************/
 /*-   validate_borrowed_symbol -- Symbol from one package in another	*/
 /***********************************************************************/

static void
validate_borrowed_symbol(
    Vm_Obj  dst_pkg,
    Vm_Obj  src_pkg,
    Vm_Uch* key
) {
    Vm_Obj src = sym_Find_Exported_Asciz( src_pkg, key );
    Vm_Obj dst = sym_Find_Exported_Asciz( dst_pkg, key );
    if (!src || !OBJ_IS_SYMBOL(src))   MUQ_FATAL ("internal err");
    if (!dst || !OBJ_IS_SYMBOL(dst)) {
	Vm_Obj nam = SYM_P(src)->name;
	OBJ_SET( dst_pkg, nam, src, OBJ_PROP_HIDDEN );
	OBJ_SET( dst_pkg, nam, src, OBJ_PROP_PUBLIC );
    }
}

 /***********************************************************************/
 /*-   obj_Byteswap_8bit_Obj -- 					*/
 /***********************************************************************/

Vm_Obj
obj_Byteswap_8bit_Obj(
    Vm_Obj o
) {
    /* This is a particularly easy case: */
    return OBJ_NIL;
}

 /***********************************************************************/
 /*-   obj_Byteswap_16bit_Obj -- 					*/
 /***********************************************************************/

Vm_Obj
obj_Byteswap_16bit_Obj(
    Vm_Obj o
) {
    Vm_Int   i = vm_Len(o)/sizeof(Vm_Unt16);	
    Vm_Unt16*p = (Vm_Unt16*)vm_Loc(o);
    while   (i --> 0)   p[i] = vm_Reverse16( p[i] );
    return OBJ_NIL;
}

 /***********************************************************************/
 /*-   obj_Byteswap_32bit_Obj -- 					*/
 /***********************************************************************/

Vm_Obj
obj_Byteswap_32bit_Obj(
    Vm_Obj o
) {
    Vm_Int   i = vm_Len(o)/sizeof(Vm_Unt32);	
    Vm_Unt32*p = (Vm_Unt32*)vm_Loc(o);
    while   (i --> 0)   p[i] = vm_Reverse32( p[i] );
    return OBJ_NIL;
}

 /***********************************************************************/
 /*-   obj_Byteswap_64bit_Obj -- 					*/
 /***********************************************************************/

Vm_Obj
obj_Byteswap_64bit_Obj(
    Vm_Obj o
) {
    Vm_Int i = vm_Len(o)/sizeof(Vm_Obj);	
    Vm_Obj*p = (Vm_Obj*)vm_Loc(o);
    while (i --> 0)   p[i] = vm_Reverse64( p[i] );
    return OBJ_NIL;
}

 /***********************************************************************/
 /*-   obj_byteswap_one_db -- 						*/
 /***********************************************************************/

static void
obj_byteswap_one_db(
    Vm_Db  db
) {
    Vm_Obj o;
    for   (o = vm_First(db);   o;   o = vm_Next(o,db)) {
/*printf("obj_byteswap_one_db: db %s obj o x=%llx OBJ_TYPE(o) x=%llx\n",vm_DbId_To_Asciz( db->dbfile ), o, OBJ_TYPE(o));*/
	(*mod_Type_Summary[ OBJ_TYPE(o) ]->reverse)( o );
    }
}

 /***********************************************************************/
 /*-   obj_byteswap_everything -- 					*/
 /***********************************************************************/

static void
obj_byteswap_everything(
    void
) {
    /* Nada as yet. */
    Vm_Db  db;
    for   (db = vm_Root_Db;   db;   db = db->next) {
	obj_byteswap_one_db( db );
    }
}

 /***********************************************************************/
 /*-   obj_Startup -- Start-of-world code.				*/
 /***********************************************************************/

void
obj_Startup(
    void
) {
    int swap;

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    /* Track which types have been installed: */
    {   int  i;
	for (i = OBJ_TYPE_MAX;   i --> 0;  ) {
	    mod_Type_Summary[i] = &obj_Type_Bad_Summary;
    }	}

    /* Set up basic type table(s): */
    {   Obj_Module_Summary *p;
	for (p = mod_Module_Summary;   *p;   ++p) {
	    (*p)->doTypes();
        }
    }

    obj_Select_Outbound_Ports( 
	obj_Allowed_Outbound_Net_Ports,
	OBJ_ALLOWED_OUTBOUND_NET_PORTS
    );
    obj_Select_Outbound_Ports( 
	obj_Root_Allowed_Outbound_Net_Ports,
	OBJ_ROOT_ALLOWED_OUTBOUND_NET_PORTS
    );

    /* Start up virtual memory: */
    swap = vm_Startup();

    /* Set up obj_Pointer_Type[]: */
    initialize_obj_pointer_type();

    if (swap) obj_byteswap_everything();

    /* Set up obj_Immediate[]: */
    initialize_obj_immediate();

    /* Need strings set up defined before build_root_root_nul_and_pat, */
    /* else attempting to store BYT3 (&tc) vals into propdirs fails    */
    /* in dil_Hash due to not finding BYT3 do_hash function:	       */
    stg_Startup();
    dil_Startup();
    sil_Startup();
    dbf_Startup();

    obj_NoteRandomBits( (Vm_Unt)getpid() );
    obj_NoteDateAsRandomBits();


    /* Root object needs to exist: */
    if (!vm_Root(0)) {
	Vm_Obj g_d = build_root_root();

	/* Keyword package needs to exist so that  */
	/* sym_Alloc_Asciz_Keyword() can make/find */
	/* the property names we use below:        */
	obj_Lib_Keyword = maybe_rebuild_keyword_package();

	sym_Startup();	/* Nearly identical problem to stg_Startup.	*/

	build_nul_and_muqnet( g_d );

    } else {

	/* Keyword package needs to exist so that  */
	/* sym_Alloc_Asciz_Keyword() can make/find */
	/* the property names we use below:        */
	obj_Lib_Keyword = maybe_rebuild_keyword_package();

#ifdef SOON
	sym_Startup();	/* Nearly identical problem to stg_Startup.	*/
#endif
    }



    /* Make sure .u, .u["root"] and .u["nul"] exist, set up obj_U*: */
    {   Vm_Obj u;
        Vm_Obj g_d;
        Vm_Obj nul;

        do {
	    u   = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("u"), OBJ_PROP_PUBLIC );
	    if  (u == OBJ_NOT_FOUND) build_nul_and_muqnet(build_root_root());
        } while (u == OBJ_NOT_FOUND);
	obj_U = u;

        do {
	    g_d = OBJ_GET( u      , stg_From_Asciz("root"), OBJ_PROP_PUBLIC );
	    if  (g_d == OBJ_NOT_FOUND) build_nul_and_muqnet(build_root_root());
        } while (g_d == OBJ_NOT_FOUND);
	obj_U_Root = g_d;

        do {
	    nul = OBJ_GET( u      , stg_From_Asciz("nul"), OBJ_PROP_PUBLIC );
	    if  (nul == OBJ_NOT_FOUND) build_nul_and_muqnet(build_root_root());
        } while (nul == OBJ_NOT_FOUND);
	obj_U_Nul = nul;
    }

    /* Make sure .etc exists: */
    {   Vm_Obj etc = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("etc"), OBJ_PROP_PUBLIC );
        if (etc==OBJ_NOT_FOUND || !OBJ_IS_OBJ(etc)) {
            etc = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
	    OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("etc"), etc, OBJ_PROP_PUBLIC );
            OBJ_P(etc)->objname = stg_From_Asciz(".etc");  vm_Dirty(etc);

	    /* Remember server instruction set signature: */
	    OBJ_SET(
		etc,
		sym_Alloc_Asciz_Keyword("serverSignature"),
		job_Code_Signature(),
		OBJ_PROP_PUBLIC
	    );
	    vm_Dirty( etc );
    	}
	obj_Etc = etc;
    }

    /* Make Root the current user: */
    job_RunState.j.acting_user = obj_U_Root;
    job_RunState.j.actual_user = obj_U_Root;

    /* Set up .env with contents of unix environment: */
    create_env();

    establish_dbfile( "MUF"  );
    establish_dbfile( "LISP" );
    establish_dbfile( "QNET" );

    /* Make sure .db exists: */
    obj_Db	  = maybe_rebuild_db_propdir();

    /* Make sure .lib propdir exists, and within it */
    /* the .lib.msh .lib.mud and .lib.muf packages: */
    obj_Lib       = maybe_rebuild_lib_propdir();
    obj_Lib_Muf   = maybe_rebuild_dbfile( "MUF", "muf","stdMuf","muf0" );
    obj_Lib_Lisp  = maybe_rebuild_dbfile( "LISP","lisp","cl", "commonLisp" );
    obj_Lib_Muqnet= maybe_rebuild_dbfile( "QNET","muqnet", NULL, NULL );
    obj_Err	  = maybe_rebuild_event_propdir();
    maybe_rebuild_etc_rc2_d();

    /* Check that serverSignature matches: */
    {   Vm_Obj server_signature = OBJ_GET(
	    obj_Etc,
	    sym_Alloc_Asciz_Keyword("serverSignature"),
	    OBJ_PROP_PUBLIC
	);
	if (server_signature != job_Code_Signature()) {
	    if (!obj_Ignore_Server_Signature) {
		MUQ_FATAL (
		    "db doesn't match server!  "
		    "(Do \'muq --ignore-signature' to run anyway.)"
		);
	    }

	    /* Remember new server instruction set signature: */
	    OBJ_SET(
		obj_Etc,
		sym_Alloc_Asciz_Keyword("serverSignature"),
		job_Code_Signature(),
		OBJ_PROP_PUBLIC
	    );
	    vm_Dirty( obj_Etc );

	    /* Better check everything else: */
	    obj_Quick_Start = FALSE;
	}
    }

    /* Make sure .lib.lisp.nil (and .t) are valid   */
    /* and set obj_Lib_Muf_Nil (and t) to them.  We */
    /* make their home the lisp package for better  */
    /* compatibility with the commonlisp spec:      */
    obj_Lib_Muf_Nil = validate_lib_constant( obj_Lib_Lisp, "nil" );
    obj_Lib_Muf_T   = validate_lib_constant( obj_Lib_Lisp, "t"   );

    /* We also want nil and t in the muf package:   */
    validate_borrowed_symbol(   obj_Lib_Muf, obj_Lib_Lisp, "nil" );
    validate_borrowed_symbol(   obj_Lib_Muf, obj_Lib_Lisp, "t"   );

    obj_FolkBy_HashName = maybe_rebuild_folkBy_hashName();

    /* Give all our users private lib/s and */
    /* give them private default packages:  */
    maybe_initialize_users_packages( obj_U_Root   );
    maybe_initialize_users_packages( obj_U_Nul    );

    /* For each hardwired class, look up the keyword  */
    /* corresponding to each special property name:   */
    find_all_system_property_keywords();

    /* For each hardwired class, sort all its special */
    /* properties into order:                         */
    sort_system_properties_tables();

    /* For each hardwired class, validate the class   */
    /* and key obects corresponding to it:            */
    validate_hardwired_class_and_key_objects();

    /* Start up the various modules: */
    {   Obj_Module_Summary *p;
	for (p = mod_Module_Summary;   *p;   ++p)   (*p)->startup();
    }

    /* Can't do this until the above has */
    /* filled in mod_Type_Summary[]:     */
    validate_hardwired_type_and_key_objects( );

    /* BUGGO: Various objects created early on  */
    /* have invalid is_a pointers 'cause the    */
    /* relevant class object didn't exist yet.  */
    /* Need to to a proper inventory of them at */  
    /* at some point here.  For now, the case   */
    /* that's screwing me up is root itself:    */
    OBJ_P(obj_U_Root)->is_a = mod_Hardcoded_Class[ OBJ_CLASS_A_ROT ]->builtin_class;
}

/************************************************************************/
/*-    obj_Linkup -- Start-of-world code.				*/
/************************************************************************/

void
obj_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    /* Link up virtual memory: */
    vm_Linkup();

    /* Link up the various modules: */
    {   Obj_Module_Summary *p;
	for (p = mod_Module_Summary;   *p;   ++p) {
	    (*p)->linkup();
	}
    }
}

/************************************************************************/
/*-    obj_Shutdown -- End-of-world code.				*/
/************************************************************************/

void
obj_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    /* Currently muq_Shutdown needs to be saved early, */
    /* because it updates obj_Muq.  If this proves     */
    /* common, maybe we'll have to move to a two-phase */
    /* shutdown sequence similar to our two-phase      */
    /* startup sequence...?			       */	
    muq_Shutdown();

    /* Shut down the various modules: */
    {   Obj_Module_Summary *p;
	for (p = mod_Module_Summary;   *p;   ++p) {
	    (*p)->shutdown();
	}
    }

    vm_Shutdown();
}

/************************************************************************/
/*-    obj_Outbound_Port_Is_Allowed					*/
/************************************************************************/

Vm_Int
obj_Outbound_Port_Is_Allowed(
    Vm_Uch map[ 0x1FFF ], /* obj_[Root_]Allowed_Outbound_Net_Ports	*/
    Vm_Unt port 	  /* 4201 or such.                    		*/
) {
    if (port > 0xFFFF)   return FALSE;
    return (map[ port >> 3 ] & (1 << (port & 7))) != 0;
}

/************************************************************************/
/*-    obj_Select_Outbound_Ports					*/
/************************************************************************/

 /***********************************************************************/
 /*-   obj_mark_port_as_allowed						*/
 /***********************************************************************/

static void
obj_mark_port_as_allowed(
    Vm_Uch map[ 0x1FFF ], /* obj_[Root_]Allowed_Outbound_Net_Ports	*/
    Vm_Int i
) {
    map[ i >> 3 ] |= (1 << (i & 7));
}

 /***********************************************************************/
 /*-   obj_Select_Outbound_Ports					*/
 /***********************************************************************/

void
obj_Select_Outbound_Ports(
    Vm_Uch map[ 0x1FFF ], /* obj_[Root_]Allowed_Outbound_Net_Ports	*/
    Vm_Uch* ports	  /* "18,4000-5000" or such.                    */
) {
    extern void usage( void );
    Vm_Int i;
    if (ports[0] != '+') {
	for (i = 0x2000; i --> 0; ) map[i] = 0;
    } else {
	++ports;
    }
    while (*ports) {
	Vm_Int a = 0;
	Vm_Int b = 0;
	if (!isdigit(*ports))   usage();
	while (isdigit(*ports))   a = a*10 + (*ports++ - '0');
	if (*ports != '-') {
	    obj_mark_port_as_allowed( map, a );
	} else {
	    ++ports;
	    if (!isdigit(*ports))   usage();
	    while (isdigit(*ports))   b = b*10 + (*ports++ - '0');
	    if (a > b)   usage();
	    for (i = a;   i <= b;   ++i)   obj_mark_port_as_allowed( map, i );
	}
	if (*ports == ',')   ++ports;
    }
}

/************************************************************************/
/*-    obj_Mark_Header							*/
/************************************************************************/

void
obj_Mark_Header(
    Vm_Obj o
) {
    /* We avoid local variables to save stack */
    /* space at expense of execution speed:   */
    obj_Mark( OBJ_P(o)->flagwrd );
    obj_Mark( OBJ_P(o)->is_a    );
    obj_Mark( OBJ_P(o)->objname );
}

/************************************************************************/
/*-    obj_Mark -- Recursively mark all objects reachable from 'o'.	*/
/************************************************************************/

void
obj_Mark(
    Vm_Obj o
) {
    Vm_Int i;	/* Due to potentially deep recursion, we minimize # vars. */

    switch (OBJ_TYPE(o)) {

	/* Ephemerals have no separate store,         */
	/* just what they borrow from the loop stack. */
    case OBJ_TYPE_EPHEMERAL_LIST:
    case OBJ_TYPE_EPHEMERAL_STRUCT:
    case OBJ_TYPE_EPHEMERAL_VECTOR:
    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_FLOAT:
    case OBJ_TYPE_INT:
    case OBJ_TYPE_CHAR:
    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:
    case OBJ_TYPE_BYT6:
    case OBJ_TYPE_BYT5:
    case OBJ_TYPE_BYT4:
    #endif
    case OBJ_TYPE_BYT3:
    case OBJ_TYPE_BYT2:
    case OBJ_TYPE_BYT1:
    case OBJ_TYPE_BYT0:
    case OBJ_TYPE_BOTTOM:
    case OBJ_TYPE_BLK:
	/* No actual storage, just return: */
	return;

    case OBJ_TYPE_OBJ:
        switch (OBJ_CLASS(o)) {
	case OBJ_CLASS_A_TIL:  til_Mark(o);   return;
	case OBJ_CLASS_A_TIN:  tin_Mark(o);   return;
	case OBJ_CLASS_A_MIL:  mil_Mark(o);   return;
	case OBJ_CLASS_A_MIN:  min_Mark(o);   return;
#ifndef STICKY
	case OBJ_CLASS_A_PIL:  pil_Mark(o);   return;
#endif
	case OBJ_CLASS_A_PIN:  pin_Mark(o);   return;
	}
	/* FALLTHROUGH */
    case OBJ_TYPE_VEC:
    case OBJ_TYPE_CONS:
    case OBJ_TYPE_STRUCT:
    case OBJ_TYPE_SYMBOL:
	/* These consist entirely of pointers, */
	/* so we can treat them all alike:     */
	if  (vm_Get_Markbit(o))   return;
	else vm_Set_Markbit(o);
	for (i = vm_Len(o)/sizeof(Vm_Obj);   i --> 0; ) {
	    obj_Mark( ((Vm_Obj*)vm_Loc(o))[i] );
	}
	return;

    case OBJ_TYPE_THUNK:
    case OBJ_TYPE_CFN:
	/* These contain pointers followed by binary data: */
	if  (vm_Get_Markbit(o))   return;
	else vm_Set_Markbit(o);
	obj_Mark( CFN_P(o)->is_a    );
	obj_Mark( CFN_P(o)->src     );
	for(i = &CFN_P(o)->vec[CFN_CONSTS(CFN_P(o)->bitbag)]-&CFN_P(o)->vec[0];
	    i --> 0;
	){
	    obj_Mark( CFN_P(o)->vec[ i ] );
	}
	return;

    case OBJ_TYPE_BIGNUM:
	/* These contain pointers followed by binary data: */
	if  (vm_Get_Markbit(o))   return;
	else vm_Set_Markbit(o);
	obj_Mark( BNM_P(o)->is_a    );
	return;

    case OBJ_TYPE_BYTN:
    case OBJ_TYPE_I16:
    case OBJ_TYPE_I32:
    case OBJ_TYPE_F32:
    case OBJ_TYPE_F64:
        /* These contain no pointers at all but need to be marked: */
	if  (vm_Get_Markbit(o))   return;
	else vm_Set_Markbit(o);
	return;

    default:
	MUQ_FATAL ("internal err");
    }
}

/************************************************************************/
/*-    obj_Collect_Garbage -- "Temporary" mark-and-sweep hack.		*/
/************************************************************************/

void
obj_Collect_Garbage(
    void
) {
    if (!muq_Is_In_Daemon_Mode) {
	fprintf(stderr,"Garbage collect starting...");
    }

    obj_NoteDateAsRandomBits();
    obj_Date_Of_Last_Garbage_Collect = job_Now();

    DBF_P(vm_Root(0))->date_of_last_garbage_collect = OBJ_FROM_UNT(obj_Date_Of_Last_Garbage_Collect);
    vm_Dirty(vm_Root(0));

    /* Make sure job.c's cached state is */
    /* written into the db, so we have a */
    /* self-consistent, complete db:     */
    if (jS.job)   job_State_Update();

    /* Run through the db clearing the mark bits  */
    /* everywhere:                                */
    vm_Clear_Markbits();

    /* Recursive 'mark' pass setting userbits */
    /* on all reachable objects:              */
    {   Vm_Db  db;
        Vm_Int i;
	for (i = OBJ_GC_ROOTS;   i --> 0;  )  obj_Mark( obj_GC_Root[i] );

	/* Currently, skt.c has some roots too: */
	skt_Mark();
/* buggo, should really mark the builtin_class pointers */
/* in hardcoded classes and types here, also. */

        for  (db = vm_Root_Db;   db;   db = db->next) {
	    obj_Mark( db->s.root );
	}
    }

    /* Sweep pass recycling all unmarked objects: */
    obj_Objs_Recovered = 0;
    obj_Objs_Remaining = 0;
    obj_Byts_Recovered = 0;
    obj_Byts_Remaining = 0;
    {   Vm_Db db;
        for  (db = vm_Root_Db;   db;   db = db->next) {
	    Vm_Obj o;
	    for(o = vm_First(db);   o;   o = vm_Next(o,db)) {
		if (vm_Get_Markbit(o)) {
		    obj_Objs_Remaining ++;
		    obj_Byts_Remaining += vm_Len(o);
		} else {
		    obj_Objs_Recovered ++;
		    obj_Byts_Recovered += vm_Len(o);

		    /* Free any related objects: */
		    {   Vm_Unt dbfile = VM_DBFILE(o);
			Vm_Obj dbf    = vm_Root(dbfile);
			Vm_Obj til;
			Vm_Obj type_mil;
			Vm_Obj prop_mil;
			Vm_Obj pdir_pil[ OBJ_PROP_MAX ];
			Vm_Obj n;
			int    i;
			{   Dbf_P  p  = DBF_P(dbf);
			    for (i = OBJ_PROP_MAX; i --> 0; ) {
			        pdir_pil[i] = p->propdir_pil[i];
			    }
			    til       = p->netinfo_til;
			    type_mil  = p->symbol_type_mil;
			    prop_mil  = p->symbol_proplist_mil;
			}
			n = mil_Del(type_mil,o);
			if ((n = mil_Del(type_mil,o)) != type_mil) { DBF_P(dbf)->symbol_type_mil     = n; vm_Dirty(dbf); }
			if ((n = mil_Del(prop_mil,o)) != prop_mil) { DBF_P(dbf)->symbol_proplist_mil = n; vm_Dirty(dbf); }
			/* buggo, it would be more efficient to */
			/* do above two only if o is a symbol.  */
			for (i = OBJ_PROP_MAX; i --> 0; ) {
			    if ((n = pil_Del(pdir_pil[i],o)) != pdir_pil[i]) {
				DBF_P(dbf)->propdir_pil[i] = n; vm_Dirty(dbf);
			    }
			}
			/* Free network info for object: */
			if ((n = til_Del( til, o )) != til){ DBF_P(dbf)->netinfo_til = n; vm_Dirty(dbf); }
		    }

		    /* Free unmarked object proper: */
		    vm_Free(o);
    }   }   }   }

    ++obj_Garbage_Collects;
    obj_Millisecs_For_Last_Garbage_Collect = (
	job_Now() - obj_Date_Of_Last_Garbage_Collect
    );
    DBF_P(vm_Root(0))->millisecs_for_last_garbage_collect = (
	OBJ_FROM_UNT(obj_Millisecs_For_Last_Garbage_Collect)
    );
    DBF_P(vm_Root(0))->garbage_collects_done = (
	OBJ_FROM_UNT( OBJ_TO_UNT(DBF_P(vm_Root(0))->garbage_collects_done) +1 )
    );
    vm_Dirty(vm_Root(0));

    lib_Log_Printf(
	"%" VM_D "-millisec garbage collect #%" VM_D " recovered %" VM_D " objects %" VM_D " bytes, left %" VM_D " objects, %" VM_D " bytes\n",
	obj_Millisecs_For_Last_Garbage_Collect,
        obj_Garbage_Collects,
	obj_Objs_Recovered,
	obj_Byts_Recovered,
	obj_Objs_Remaining,
	obj_Byts_Remaining
    );

    vm_Total_Bytes_Allocated_Since_Last_Garbage_Collection = 0;

    if (!muq_Is_In_Daemon_Mode) {
	fprintf(stderr," complete.\n");
    }
}

/****************************************************************************************/
/* Some useful notes on next-generation garbage collection:				*/
/*											*/
/* From: Miroslav Silovic <silovic@zesoi.fer.hr>					*/
/* Date: 09 Dec 1999 13:31:37 +0100							*/
/* In-Reply-To: Cynbe ru Taren's message of "Wed, 8 Dec 1999 15:46:51 -0600"		*/
/* Message-ID: <7eyab49txy.fsf@zesoi.fer.hr>						*/
/* Lines: 97										*/
/* X-Mailer: Gnus v5.5/XEmacs 20.4 - "Emerald"						*/
/* Subject: [MUD-Dev] Garbage Collection						*/
/* Reply-To: mud-dev@kanga.nu								*/
/* Sender: mud-dev-admin@kanga.nu							*/
/* Errors-To: mud-dev-admin@kanga.nu							*/
/* X-Mailman-Version: 1.1								*/
/* Precedence: bulk									*/
/* List-Id: The MUD-Dev list discusses MUD game and server design, development, 	*/
/*		and implementation. <mud-dev.kanga.nu> 					*/
/* X-BeenThere: mud-dev@kanga.nu							*/
/* Status: RO										*/
/* 											*/
/* Cynbe ru Taren <cynbe@muq.org> writes:						*/
/* 											*/
/* > In Muq, I'm currently using a plain-jane mark-and-sweep monolithic			*/
/* > gc I hacked together one weekend just to have something rather than		*/
/* > nothing.										*/
/* 											*/
/* Hmm. :) Problem with mark&sweep is bad realtime performance. You can			*/
/* look to 1-2 seconds pause per 10MB allocated. Not too bad unless you			*/
/* have *lots* of active objects or are running realtime combat. See			*/
/* BattleTech MUSHes for realtime combat example (and the ammount of			*/
/* annoyance 1 second lag can cause).							*/
/* 											*/
/* > I've been contemplating going to a two-generation system and/or			*/
/* > implementing Dijkstra's three-color incremental algorithm.				*/
/* 											*/
/* Generational GC tends to require the same infrastructure as tricolor			*/
/* (i.e. write barrier).								*/
/* 											*/
/* > Is there prior mud art with other approaches?  Are there working			*/
/* > systems or good references I should be boning up on before proceeding?		*/
/* 											*/
/* No MUD systems that I know of, but there are plenty of programming			*/
/* languages implementations that use good GC systems. Note that GC has			*/
/* one serious drawback: it tends to touch all the pages it scans. While		*/
/* it's possible to check whether the page is on swap (and then try and			*/
/* be clever about scanning the pointers from it), GCs in general don't			*/
/* do this, and so GC systems don't perform well when the machine begins		*/
/* to thrash.										*/
/* 											*/
/* My favorite GC implementations are Hans Boehm's (major problem: uses			*/
/* VM tricks to handle generationality), rscheme's (check				*/
/* www.rscheme.org) and the one in TOM (incremental, nongenerational for		*/
/* now, and with very clean interface to the object system that allows			*/
/* objects a good degree of control over the way they get collected).			*/
/* 											*/
/* So here are the MUD/GC issues:							*/
/* 											*/
/*  - Using well-implemented GC results in a code that doesn't have to			*/
/* worry at all about memory bugs - you probably want conservative stack		*/
/* scanning if you're doing *any* embedded C, but you can almost always			*/
/* scan heap exactly. Also, you can use circular datastructures without			*/
/* limits, work with graphs in a general manner (refcounting tends to			*/
/* break with general graphs) and keep all the memory issues separate			*/
/* from your object system (i.e. no worries where/when					*/
/* constructors/destructors get called). You also have symmetry between			*/
/* objects pointed from stack and the objects pointed from heap - this is		*/
/* VERY helpful for design. Note that GC may treat stack and heap			*/
/* pointers differently, the symmetry is in the GC interface.				*/
/* 											*/
/*  - Write barrier... This is problematic part. In C, calling write			*/
/* barrier for heap objects means you have to do					*/
/* 											*/
/* 	GC_ASSIGN_POINTER(object->foo, another_object);					*/
/* 											*/
/* or											*/
/* 											*/
/* 	object->foo = another_object;							*/
/* 	GC_LINK(object, another object);						*/
/* 											*/
/* (you need to know inter-generational pointers in gengc, that's what			*/
/* the second parameter is for).							*/
/* 											*/
/* rather than just									*/
/* 											*/
/* 	object->foo = another_object;							*/
/* 											*/
/* This is easy to forget. C++ with some templates has trivial workaround		*/
/* (just implement write barrier into assignment operator) but will tend		*/
/* to call write barrier WAY too often. Alternatively one could probably		*/
/* program a lint-like utility to statically check for this problem.			*/
/* 											*/
/*  - swap interaction. This topic, to put it plainly, sucks. One way to		*/
/* treat this problem is to treat parts of your object tree as separate			*/
/* systems and collect them using distributed GC technique - it handles			*/
/* one hard problem by turning it into another hard (but more researched)		*/
/* problem.										*/
/* 											*/
/*  - one-bit refcounting: Some datastructures are VERY transient in			*/
/* nature - strings, for instance, or closures when you use them just to		*/
/* avoid enumerators. To handle them, you give them one bit refcount: You		*/
/* know when these will disappear from stack, so you can use a single-bit		*/
/* flag that checks whether this object is referenced from heap. If no,			*/
/* once it disappears from the local scope, you can kill it. This doesn't		*/
/* suffer from threading interactions typical for refcounting, and can			*/
/* drastically increase performance if you allocate your strings on a			*/
/* GC'ed heap.										*/
/* 											*/
/*  - distributed gc: This becomes relevant if you're running your mud on		*/
/* several servers. I haven't thought much about it, apart from noting			*/
/* that TOM supports somewhat limited form of it (read: VERY				*/
/* fault-intolerant).									*/
/* 											*/
/* More information on this topic: ftp://ftp.cs.utexas.edu/pub/garbage/			*/
/* 											*/
/* 											*/
/* -- 											*/
/* How to eff the ineffable?								*/
/* _______________________________________________					*/
/* MUD-Dev maillist  -  MUD-Dev@kanga.nu						*/
/* http://www.kanga.nu/lists/listinfo/mud-dev						*/
/* 											*/
/* 											*/
/* "The Garbage Collection Page":http://www.cs.ukc.ac.uk/people/staff/rej/gc.html	*/
/* Boehm's mostly-parallel: http://www.harlequin.com/mm/reference/bib/full.html#bds91	*/
/* 											*/
/* Comparative Performance Evaluation of Garbage Collection Algorithms.			*/
/* ftp://ftp.cs.colorado.edu/pub/misc/zorn-phd-thesis.ps				*/
/* 											*/
/* 											*/
/* 											*/
/* 											*/
/* ___________________________________________________________________________________	*/
/* 											*/
/* 	MONOLITHIC IN-RAM (generational) MARK-AND-SWEEP GARBAGE COLLECTION		*/
/* 											*/
/* I think maybe it suffices to have two bits per bigbuf object:			*/
/* 											*/
/*   OLD,  which is 0 for newly created bigbuf objects, 1 for swapped-in ones.		*/
/*   MARK, which is used during actual gc runs.						*/
/* 											*/
/* We probably have enough bigbuf header bits to use one as a MARK bit:			*/
/* Doing so is likely to be a bit faster than using the regular MARK bitmap		*/
/* bit, since access to a header bit will be significantly faster.			*/
/* 											*/
/* The crucial invariant is that no OLD==0 object is referenced by a pointer		*/
/* on disk:  This means that any OLD==0 object unreferenced by pointers in ram		*/
/* can be garbage collected.								*/
/* 											*/
/* We can maintain this invariant just by setting OLD==1 on all objects in ram		*/
/* referenced by any object being written to disk, while doing the write.		*/
/* 											*/
/* This should be sufficient to allow us to collect a sizable fraction of short-	*/
/* lived garbage strings &tc without having to touch disk.				*/
/* 											*/
/* The actual mark-and-sweep should be quite vanilla, excepting that we can		*/
/* ignore all gc roots which are on disk, and every OLD==1 object in ram is		*/
/* a root.										*/
/* 											*/
/* The obvious time to do in-ram gc is when bigbuf is full and we're thinking		*/
/* about dumping objects to disk to free up space in it.				*/
/* 											*/
/* 											*/
/* 											*/
/* ___________________________________________________________________________________	*/
/* 											*/
/* 	INCREMENTAL FULL-DB MARK-AND-SWEEP GARBAGE COLLECTION				*/
/* 											*/
/* For a first-time-around hack, the simplest approach appears to me to be:		*/
/* 											*/
/* o  Use the usual 3-color algorithm, with colors MARKED, QUEUED, REST.		*/
/*    The colors need to be in global vm.t bitmaps to avoid horrible thrashing.		*/
/*    (We can probably use spare bits in the UNIQUE or TAGBITS bytemaps.)		*/
/* 											*/
/* o  We start out by coloring every root QUEUED.					*/
/* 											*/
/* o  For every QUEUED object O in ram, we then color QUEUED every REST object		*/
/*    reachable from O, then color O MARKED.  We iterate this to quiescence.		*/
/*    This takes no longer than our in-ram monolithic gc, and leaves no QUEUED		*/
/*    objects in ram.  By definition. no MARKED object can directly reference a REST	*/
/*    object, so we can leave any ram-resident REST objects in the hash table without	*/
/*    problem.										*/
/* 											*/
/* o  Our invariant is now the absence of in-ram QUEUED objects.  We may maintain	*/
/*    it by, every time we read a QUEUED object into ram, repeating the above step	*/
/*    to quiescience again.								*/
/* 											*/
/* o  We may now allow mutator execution to continue, subject to the above processing	*/
/*    at diskread time.									*/
/* 											*/
/* o  To drive the gc to completion, we need to systematically work through the		*/
/*    QUEUED objects.									*/
/*         One way of doing this is during idle time.  We probably want			*/
/*    to read the QUEUED object into a separate buffer, or be careful to delete it	*/
/*    it from bigbuf as soon as marked, to avoid having incremental gc disturb the	*/
/*    in-ram working set.								*/
/* 	   Another way of doing this is to do one (or a few) such steps for each	*/
/*    object read into bigbuf by the mutator -- this will keep the global gc chugging	*/
/*    along even in the absence of idle time.						*/
/* 											*/
/* o  As usual, when no QUEUED objects remain, all REST objects may be marked FREE.	*/
/* 											*/
/* o  Interaction with gen-0 garbage collects taking place during full gc:		*/
/*    Need to avoid objects being marked FREE by gen-0 while REST by full gc,		*/
/*    then being allocated, then being marked FREE by full gc when actually in use.	*/
/*    It should suffice to have gen-0 change any REST colored objects it recovers to	*/
/*    MARKED (or a fourth color) in order to prevent this.				*/
/* 											*/
/* 											*/
/* 											*/
/* ___________________________________________________________________________________	*/
/* 											*/
/* Might want to consider segregating the ram-cache, either by using multiple		*/
/* buffers, or else by using both ends of the existing buffer.				*/
/* 											*/
/* For example, segregating old read-only objects might save the gen-0 gc some work,	*/
/* since it is impossible for any of them to refer to a newly created object.		*/
/* 											*/
/* Similarly, the gen-0 collector might be able to benefit from the DIRTY bit:		*/
/* Clean, old objects might as well be read-only, in that they cannot refer to		*/
/* freshly created objects.  Doing this would overload the DIRTY bit somewhat --	*/
/* we'd have to be careful that cleaning the object by writing it to disk did not	*/
/* foul up the gen-0 garbage collector's invariants.  Would we need a second DIRTY	*/
/* bit (CHANGED_SINCE_LOADED? CHANGED_SINCE_GEN0_CG?) to make this work?  Or?		*/
/* 											*/
/****************************************************************************************/


/************************************************************************/
/*-    obj_Dump_State -- Human-readable debug display of heap.		*/
/************************************************************************/

void
obj_Dump_State(
    void
) {
    Vm_Db db;
    for  (db = vm_Root_Db;   db;   db = db->next) {
	Vm_Obj o;
	for   (o = vm_First(db);   o;   o = vm_Next(o,db)) {
	    fprintf(stdout,
		"db '%s'   obj %" VM_X "   len %" VM_X,
		vm_DbId_To_Asciz( VM_DBFILE(o) ),
		o,
		vm_Len(o)
	    );
	    if (OBJ_TYPE(o)==OBJ_TYPE_OBJ) {
	        fprintf(stdout,
		    "   class '%s'",
	            mod_Hardcoded_Class[ OBJ_CLASS(o) ]->fullname
		);
	    } else {
		fprintf(stdout,
		    "   type '%s'",
		    mod_Type_Summary[ OBJ_TYPE(o) ]->fullname
		);
	    }
	    fprintf(stdout,
		":"
	    );

	    if (OBJ_TYPE(o)==OBJ_TYPE_BYTN) {

	        Vm_Int len = vm_Len(o);
		Vm_Uch*p   = (Vm_Uch*) vm_Loc(o);
	        Vm_Int i;
		for (i = 0;  i < len;   ++i) {
		    int c = p[i];
		    if (!(i & (Vm_Unt)0x3F)) {
			fprintf(stdout,
			    "\n  "
			);
		    }
		    if (c >= ' ' && c < 127) {
			fprintf(stdout,
			    "%c",
			    c
			);
		    } else {
			fprintf(stdout,
			    "\%02x",
			    c
			);
		    }
		}
		fprintf(stdout,
		    "\n"
		);

	    } else if (OBJ_TYPE(o)==OBJ_TYPE_BIGNUM) {

	        /* This case is a quick hack to avoid publishing */
	        /* private keys and such in the dumps.  The idea */
	        /* is not to defeat Black Hats (who can easily   */
	        /* comment this out and recompile) but rather to */
	        /* prevent absentminded White Hats from emailing */
	        /* this information in a debug dump:             */
	        Vm_Int len = (vm_Len(o)+(VM_INTBYTES-1)) >> VM_LOG2_INTBYTES;
/*		Vm_Unt*p   = (Vm_Unt*) vm_Loc(o);	*/
	        Vm_Int i;
		fprintf(stdout,
		    "\n"
		);
		for (i = 0;  i < len;   ++i) {
/*		    Vm_Unt u = p[i];			*/
		    int j;
		    for (j = 0;  j < VM_INTBYTES;  ++j) {
/*			int c = (u >> (8*j)) & 0xFF;	*/
			fprintf(stdout,
			    " xx"
/*			    c				*/
			);
		    }
		    fprintf(stdout,
			"\n"
		    );
		}
		fprintf(stdout,
		    "\n"
		);

	    } else {

	        Vm_Int len = (vm_Len(o)+(VM_INTBYTES-1)) >> VM_LOG2_INTBYTES;
		Vm_Unt*p   = (Vm_Unt*) vm_Loc(o);
	        Vm_Int i;
		fprintf(stdout,
		    "\n"
		);
		for (i = 0;  i < len;   ++i) {
		    Vm_Unt u = p[i];
		    int j;
		    for (j = 0;  j < VM_INTBYTES;  ++j) {
			int c = (u >> (8*j)) & 0xFF;
			fprintf(stdout,
			    " %02x",
			    c
			);
		    }
		    fprintf(stdout,
			"\n"
		    );
		}
		fprintf(stdout,
		    "\n"
		);
	    }
        }
    }
}

/************************************************************************/
/*-    obj_For_All_Pointers_In_Db -- 					*/
/************************************************************************/

void
obj_For_All_Pointers_In_Db(
    void (*fn)( void*fa, Vm_Obj o, Vm_Int count ),
    void  *fa,
    Vm_Db  db
) {
    Vm_Obj o;
    for   (o = vm_First(db);   o;   o = vm_Next(o,db)) {

	switch (OBJ_TYPE(o)) {

	    /* Ephemerals have no separate store,         */
	    /* just what they borrow from the loop stack. */
	case OBJ_TYPE_EPHEMERAL_LIST:
	case OBJ_TYPE_EPHEMERAL_STRUCT:
	case OBJ_TYPE_EPHEMERAL_VECTOR:
	case OBJ_TYPE_SPECIAL:
	case OBJ_TYPE_FLOAT:
	case OBJ_TYPE_INT:
	case OBJ_TYPE_CHAR:
	#if VM_INTBYTES > 4
	case OBJ_TYPE_BYT7:
	case OBJ_TYPE_BYT6:
	case OBJ_TYPE_BYT5:
	case OBJ_TYPE_BYT4:
	#endif
	case OBJ_TYPE_BYT3:
	case OBJ_TYPE_BYT2:
	case OBJ_TYPE_BYT1:
	case OBJ_TYPE_BYT0:
	case OBJ_TYPE_BOTTOM:
	case OBJ_TYPE_BLK:
	case OBJ_TYPE_BYTN:
	case OBJ_TYPE_I16:
	case OBJ_TYPE_I32:
	case OBJ_TYPE_F32:
	case OBJ_TYPE_F64:
	    /* No pointers, nada to do: */
	    break;

	case OBJ_TYPE_OBJ:
	case OBJ_TYPE_VEC:
	case OBJ_TYPE_CONS:
	case OBJ_TYPE_STRUCT:
	case OBJ_TYPE_SYMBOL:
	    /* These consist entirely of pointers, */
	    /* so we can treat them all alike:     */
	    fn( fa, o, vm_Len(o)/sizeof(Vm_Obj) );
	    break;

	case OBJ_TYPE_THUNK:
	case OBJ_TYPE_CFN:
	    /* These contain pointers followed by binary data: */
	    fn( fa, o, (&CFN_P(o)->vec[CFN_CONSTS(CFN_P(o)->bitbag)]-&CFN_P(o)->vec[0]) +2 );
	    break;

	case OBJ_TYPE_BIGNUM:
	    /* These contain pointers followed by binary data: */
	    fn( fa, o, 1 );
	    break;

	default:
	    MUQ_FATAL ("internal err");
	}
    }
}

/************************************************************************/
/*-    obj_For_All_Pointers_In_Server -- 				*/
/************************************************************************/

void
obj_For_All_Pointers_In_Server(
    void (*fn)( void*fa, Vm_Obj o, Vm_Int count ),
    void  *fa
) {
    Vm_Db db;
    for  (db = vm_Root_Db;   db;   db = db->next) {
	obj_For_All_Pointers_In_Db( fn, fa, db );
    }
}

/************************************************************************/
/*-    obj_null_out_all_pointers_in_block -- 				*/
/************************************************************************/

#ifdef VERBOSE
static int ints_seen = 0;
static int floats_seen = 0;
static int chars_seen = 0;
static int byteis_seen = 0;
static int bytens_seen = 0;
static int objs_seen = 0;
static int vecs_seen = 0;
static int cons_seen = 0;
static int structs_seen = 0;
static int symbols_seen = 0;
static int thunks_seen = 0;
static int cfns_seen = 0;
static int bignums_seen = 0;

static int calls_to_vm_pointer_is_broken = 0;
static int calls_to_null_out_all_pointers_in_block = 0;
#endif

static void
obj_null_out_all_pointers_in_block(
    void* dummy,
    Vm_Obj o,
    Vm_Int count
) {
    Vm_Int  i;
#ifdef VERBOSE
++calls_to_null_out_all_pointers_in_block;
#endif
    for (i = 0;   i < count;   ++i) {

        /* Fetch i'th pointer from block: */
	Vm_Obj p = ((Vm_Obj*)vm_Loc( o ))[ i ];

	/* Ignore immediate values &tc: */
#ifdef VERBOSE
switch (OBJ_TYPE(p)) {
case OBJ_TYPE_EPHEMERAL_LIST:
case OBJ_TYPE_EPHEMERAL_STRUCT:
case OBJ_TYPE_EPHEMERAL_VECTOR:
case OBJ_TYPE_SPECIAL:
case OBJ_TYPE_FLOAT: ++floats_seen; break;
case OBJ_TYPE_INT:   ++ints_seen;  break;
case OBJ_TYPE_CHAR:  ++chars_seen;  break;
case OBJ_TYPE_BYT7:
case OBJ_TYPE_BYT6:
case OBJ_TYPE_BYT5:
case OBJ_TYPE_BYT4:
case OBJ_TYPE_BYT3:
case OBJ_TYPE_BYT2:
case OBJ_TYPE_BYT1:
case OBJ_TYPE_BYT0: ++byteis_seen;  break;
case OBJ_TYPE_BOTTOM:
case OBJ_TYPE_BLK:
case OBJ_TYPE_BYTN: ++bytens_seen;  break;
case OBJ_TYPE_I16:
case OBJ_TYPE_I32:
case OBJ_TYPE_F32:
case OBJ_TYPE_F64:
case OBJ_TYPE_OBJ: ++objs_seen;  break;
case OBJ_TYPE_VEC: ++vecs_seen;  break;
case OBJ_TYPE_CONS: ++cons_seen;  break;
case OBJ_TYPE_STRUCT: ++structs_seen;   break;
case OBJ_TYPE_SYMBOL: ++symbols_seen;  break;
case OBJ_TYPE_THUNK:  ++thunks_seen;  break;
case OBJ_TYPE_CFN:    ++cfns_seen;  break;
case OBJ_TYPE_BIGNUM: ++bignums_seen;  break;
}
#endif
	switch (OBJ_TYPE(p)) {

	    /* Ephemerals have no separate store,         */
	    /* just what they borrow from the loop stack. */
	case OBJ_TYPE_EPHEMERAL_LIST:
	case OBJ_TYPE_EPHEMERAL_STRUCT:
	case OBJ_TYPE_EPHEMERAL_VECTOR:
	case OBJ_TYPE_SPECIAL:
	case OBJ_TYPE_FLOAT:
	case OBJ_TYPE_INT:
	case OBJ_TYPE_CHAR:
	#if VM_INTBYTES > 4
	case OBJ_TYPE_BYT7:
	case OBJ_TYPE_BYT6:
	case OBJ_TYPE_BYT5:
	case OBJ_TYPE_BYT4:
	#endif
	case OBJ_TYPE_BYT3:
	case OBJ_TYPE_BYT2:
	case OBJ_TYPE_BYT1:
	case OBJ_TYPE_BYT0:
	case OBJ_TYPE_BOTTOM:
	case OBJ_TYPE_BLK:
	    /* Not pointers, just return: */
	    break;

	case OBJ_TYPE_BYTN:
	case OBJ_TYPE_I16:
	case OBJ_TYPE_I32:
	case OBJ_TYPE_F32:
	case OBJ_TYPE_F64:
	case OBJ_TYPE_OBJ:
	case OBJ_TYPE_VEC:
	case OBJ_TYPE_CONS:
	case OBJ_TYPE_STRUCT:
	case OBJ_TYPE_SYMBOL:
	case OBJ_TYPE_THUNK:
	case OBJ_TYPE_CFN:
	case OBJ_TYPE_BIGNUM:
	    /* Really is a pointer, hence can be broken: */
#ifdef VERBOSE
++calls_to_vm_pointer_is_broken;
#endif
	    if (!vm_Is_Valid( p )) {
		((Vm_Obj*)vm_Loc( o ))[ i ] = OBJ_NIL;
#ifdef VERBOSE
printf("obj_null_out_all_pointers_in_block(): broken pointer %llx at %llx[%lld] nulled out\n",p,o,i);
#endif
	    }
	    break;

	default:
	    MUQ_FATAL ("internal err");
	}
    }
}

/************************************************************************/
/*-    obj_Null_Out_Broken_Pointers_In_Db -- 				*/
/************************************************************************/

void
obj_Null_Out_Broken_Pointers_In_Db(
    Vm_Db  db
) {
#ifdef VERBOSE
calls_to_vm_pointer_is_broken = 0;
calls_to_null_out_all_pointers_in_block = 0;

ints_seen = 0;
floats_seen = 0;
chars_seen = 0;
byteis_seen = 0;
bytens_seen = 0;
objs_seen = 0;
vecs_seen = 0;
cons_seen = 0;
structs_seen = 0;
symbols_seen = 0;
thunks_seen = 0;
cfns_seen = 0;
bignums_seen = 0;
#endif
    obj_For_All_Pointers_In_Db( obj_null_out_all_pointers_in_block, NULL, db );

#ifdef VERBOSE
printf("obj_Null_Out_Broken_Pointers_In_Db(): calls_to_vm_pointer_is_broken d=%d\n",calls_to_vm_pointer_is_broken);
printf("obj_Null_Out_Broken_Pointers_In_Db(): calls_to_null_out_all_pointers_in_block d=%d\n",calls_to_null_out_all_pointers_in_block);

printf("ints_seen d=%d\n",ints_seen);
printf("floats_seen d=%d\n",floats_seen);
printf("chars_seen d=%d\n",chars_seen);
printf("byteis_seen d=%d\n",byteis_seen);
printf("bytens_seen d=%d\n",bytens_seen);
printf("objs_seen d=%d\n",objs_seen);
printf("vecs_seen d=%d\n",vecs_seen);
printf("cons_seen d=%d\n",cons_seen);
printf("structs_seen d=%d\n",structs_seen);
printf("symbols_seen d=%d\n",symbols_seen);
printf("thunks_seen d=%d\n",thunks_seen);
printf("cfns_seen d=%d\n",cfns_seen);
printf("bignums_seen d=%d\n",bignums_seen);
#endif
}

/************************************************************************/
/*-    obj_Null_Out_All_Broken_Pointers -- 				*/
/************************************************************************/

void
obj_Null_Out_All_Broken_Pointers(
    void
) {
#ifdef VERBOSE
calls_to_vm_pointer_is_broken = 0;
calls_to_null_out_all_pointers_in_block = 0;

ints_seen = 0;
floats_seen = 0;
chars_seen = 0;
byteis_seen = 0;
bytens_seen = 0;
objs_seen = 0;
vecs_seen = 0;
cons_seen = 0;
structs_seen = 0;
symbols_seen = 0;
thunks_seen = 0;
cfns_seen = 0;
bignums_seen = 0;
#endif
    obj_For_All_Pointers_In_Server( obj_null_out_all_pointers_in_block, NULL );

#ifdef VERBOSE
printf("obj_Null_Out_All_Broken_Pointers(): calls_to_vm_pointer_is_broken d=%d\n",calls_to_vm_pointer_is_broken);
printf("obj_Null_Out_All_Broken_Pointers(): calls_to_null_out_all_pointers_in_block d=%d\n",calls_to_null_out_all_pointers_in_block);

printf("ints_seen d=%d\n",ints_seen);
printf("floats_seen d=%d\n",floats_seen);
printf("chars_seen d=%d\n",chars_seen);
printf("byteis_seen d=%d\n",byteis_seen);
printf("bytens_seen d=%d\n",bytens_seen);
printf("objs_seen d=%d\n",objs_seen);
printf("vecs_seen d=%d\n",vecs_seen);
printf("cons_seen d=%d\n",cons_seen);
printf("structs_seen d=%d\n",structs_seen);
printf("symbols_seen d=%d\n",symbols_seen);
printf("thunks_seen d=%d\n",thunks_seen);
printf("cfns_seen d=%d\n",cfns_seen);
printf("bignums_seen d=%d\n",bignums_seen);
#endif
}

/************************************************************************/
/*-    obj_Do_Backup -- Temporary monolithic backup hack.		*/
/************************************************************************/

void
obj_Do_Backup(
    void
) {
    Vm_Obj job = jS.job;

    if (!muq_Is_In_Daemon_Mode) {
	fprintf(stderr,"Backup starting...\n");
    }

    obj_Date_Of_Last_Backup = job_Now();
    MUQ_P(obj_Muq)->date_of_last_backup = OBJ_FROM_UNT(obj_Date_Of_Last_Backup);
    vm_Dirty(obj_Muq);

    /* Make sure job.c's cached state is */
    /* written into the db, so we have a */
    /* self-consistent, complete db:     */
    if (job)   job_State_Unpublish();

    /* Actually do the backup: */
    {   /* Preserve the existing asynch flag.  At present */
        /* this is moot because it is always FALSE, but   */
        /* it is good programming practice:               */
        Vm_Int asynch = vm_Compress_Files_Asynchronously;

	/* Select ansychronous compression of the saved   */
        /* db files, to reduce time the Muq server is     */
        /* locked up doing backup:                        */
/* Buggo, commented out for now because there appears to  */
/* be a race condition between completion of shutdown and */
/* re-startup when we do this.  Need to check/change the  */
/* logic so that we create new backup files but do not    */
/* need to compress -or- decompress the RUNNING dbfiles   */
/* here.                                                  */
#ifdef SOON
        vm_Compress_Files_Asynchronously = TRUE;
#endif

        vm_Preshutdown();    vm_Nuke_Db_At_Startup = FALSE;
        vm_Restartup();

	/* Restore previous asynch flag setting:          */
        vm_Compress_Files_Asynchronously = asynch;
    }

    if (job)   job_State_Publish( job );

    {   Vm_Unt millisecs_between_backups = OBJ_TO_UNT(MUQ_P(obj_Muq)->millisecs_between_backups);
        Vm_Unt date_of_next_backup       = OBJ_TO_UNT(MUQ_P(obj_Muq)->date_of_next_backup      );
	if (millisecs_between_backups <= 0) {
            MUQ_P(obj_Muq)->date_of_next_backup = OBJ_FROM_UNT(0);
	    vm_Dirty(obj_Muq);
	} else {
	    do {
		date_of_next_backup  += millisecs_between_backups;
                MUQ_P(obj_Muq)->date_of_next_backup = OBJ_FROM_UNT(date_of_next_backup);
		vm_Dirty(obj_Muq);
	    } while (date_of_next_backup < OBJ_TO_UNT( job_RunState.now ));
	}
    }

    obj_Millisecs_For_Last_Backup = (
	job_Now() - obj_Date_Of_Last_Backup
    );
    MUQ_P(obj_Muq)->millisecs_for_last_backup = (
	OBJ_FROM_UNT(obj_Millisecs_For_Last_Backup)
    );
    vm_Dirty(obj_Muq);
    lib_Log_Printf(
	"%" VM_D "-millisec backup done\n",
	obj_Millisecs_For_Last_Backup
    );

    if (!muq_Is_In_Daemon_Mode) {
	fprintf(stderr,"Backup complete.\n");
    }
}

/************************************************************************/
/*-    obj_NoteRandomBits -- add entropy to muq_RandomState		*/
/************************************************************************/

void
obj_NoteRandomBits(
    Vm_Unt u
) {
    int i = muq_RandomState.i;
    #if MUQ_REPEATABLE
    #else
    muq_RandomState.slot[i] += OBJ_FROM_UNT( u );
    muq_RandomState.i        = (muq_RandomState.i+1) & (MUQ_RANDOM_STATE_SLOTS-1);
    #endif
}

/************************************************************************/
/*-    obj_NoteDateAsRandomBits -- add entropy to muq_RandomState	*/
/************************************************************************/

void
obj_NoteDateAsRandomBits(
    void
) {
    /********************************************************************/
    /* Some asynchronous event just happened and we're trying to	*/
    /* use it to help generate truly random numbers by adding		*/
    /* unpredictable bits into the muq_RandomState.slot[] array.	*/
    /*									*/
    /* Use the current time to microsecond accuracy if we have it,	*/
    /* else settle for the time to  second accuracy:			*/
    /********************************************************************/

    #ifdef HAVE_GETTIMEOFDAY
    obj_NoteRandomBits( sys_Date_Usecs() );
    #else
    obj_NoteRandomBits( job_Now()        );
    #endif
}

/************************************************************************/
/*-    obj_20TrueRandomBytes -- compute 128 truly (we hope) random bits	*/
/************************************************************************/

void
obj_20TrueRandomBytes(
    Vm_Uch digest[20]
) {
    int i = muq_RandomState.i-8;
    if (i < 0)  i = 0;
    #if MUQ_REPEATABLE
    muq_RandomState.slot[i] += OBJ_FROM_UNT(         1 );
    #else
    muq_RandomState.slot[i] += OBJ_FROM_UNT( job_Now() );
    #endif
    muq_RandomState.i        = (muq_RandomState.i+1) & (MUQ_RANDOM_STATE_SLOTS-1);
    sha_Digest( digest, (Vm_Uch*) &muq_RandomState.slot[i], 512 );
}

/************************************************************************/
/*-    obj_TrueRandom -- compute 128 truly (we hope) random bits	*/
/************************************************************************/

Vm_Unt
obj_TrueRandom(
    Vm_Unt*p
) {
    Vm_Uch digest[20];
    obj_20TrueRandomBytes( digest );

    {   Vm_Unt n1;
	Vm_Unt n2;
	#if   VM_INTBYTES==8
	    n1 = ((Vm_Unt)digest[ 7] << 56)
	       | ((Vm_Unt)digest[ 6] << 48)
	       | ((Vm_Unt)digest[ 5] << 40)
	       | ((Vm_Unt)digest[ 4] << 32)
	       | ((Vm_Unt)digest[ 3] << 24)
	       | ((Vm_Unt)digest[ 2] << 16)
	       | ((Vm_Unt)digest[ 1] <<  8)
	       | ((Vm_Unt)digest[ 0] <<  0)
	    ;
	    n2 = ((Vm_Unt)digest[15] << 56)
	       | ((Vm_Unt)digest[14] << 48)
	       | ((Vm_Unt)digest[13] << 40)
	       | ((Vm_Unt)digest[12] << 32)
	       | ((Vm_Unt)digest[11] << 24)
	       | ((Vm_Unt)digest[10] << 16)
	       | ((Vm_Unt)digest[ 9] <<  8)
	       | ((Vm_Unt)digest[ 8] <<  0)
	    ;
	#elif VM_INTBYTES==4
	    n1 = ((Vm_Unt)digest[ 3] << 24)
	       | ((Vm_Unt)digest[ 2] << 16)
	       | ((Vm_Unt)digest[ 1] <<  8)
	       | ((Vm_Unt)digest[ 0] <<  0)
	    ;
	    n2 = ((Vm_Unt)digest[ 7] << 24)
	       | ((Vm_Unt)digest[ 6] << 16)
	       | ((Vm_Unt)digest[ 5] <<  8)
	       | ((Vm_Unt)digest[ 4] <<  0)
	    ;
	#else
	    error "Unsupported value for VM_INTBYTES"
	#endif

	if (p != NULL) *p = n1;
	return              n2;
    }
}

/************************************************************************/
/*-    obj_Is_Atomic -- TRUE for pointerfree stuff: ints, floats...	*/
/************************************************************************/

Vm_Int
obj_Is_Atomic(
    Vm_Obj o
) {
    Vm_Int  typ = OBJ_TYPE( o );
    switch (typ) {

    case OBJ_TYPE_EPHEMERAL_LIST:
    case OBJ_TYPE_EPHEMERAL_STRUCT:
    case OBJ_TYPE_EPHEMERAL_VECTOR:
	/* obj_Is_Atomic() is only used in */
	/* import()/export() stuff, and    */
	/* for those purposes they can be  */
	/* regarded as atomic, since all   */
	/* that needs to be saved/restored */
	/* is the stack offset contained.  */

    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_FLOAT  :
    case OBJ_TYPE_INT    :
    case OBJ_TYPE_BOTTOM :
    case OBJ_TYPE_CHAR   :
    case OBJ_TYPE_BYT0   :
    case OBJ_TYPE_BYT1   :
    case OBJ_TYPE_BYT2   :
    case OBJ_TYPE_BYT3   :
    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT4   :
    case OBJ_TYPE_BYT5   :
    case OBJ_TYPE_BYT6   :
    case OBJ_TYPE_BYT7   :
    #endif
    case OBJ_TYPE_BYTN   :
    case OBJ_TYPE_BLK    :
	return TRUE;

    default:
	return FALSE;
    }
}

/************************************************************************/
/*-    obj_Eq_Via_Pointer_Is_Ok -- TRUE for ints, symbols and such.	*/
/************************************************************************/

/* This function returns FALSE unless */
/* a simple C '==' suffices to test   */
/* whether the value is MUF '=' to    */
/* some other value.                  */

Vm_Int
obj_Eq_Via_Pointer_Is_Ok(
    Vm_Obj o
) {
    return OBJ_TYPE( o ) != OBJ_TYPE_BYTN;
}

/************************************************************************/
/*-    obj_unportable_dbref -- TRUE if exchanging dbref makes no sense	*/
/************************************************************************/

Vm_Int
obj_unportable_dbref(
    Vm_Obj o
) {
    switch (OBJ_TYPE(o)) {
    case 0:
    case OBJ_TYPE_EPHEMERAL_LIST:
    case OBJ_TYPE_EPHEMERAL_STRUCT:
    case OBJ_TYPE_EPHEMERAL_VECTOR:
    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_BOTTOM:
    case OBJ_TYPE_BLK:
	return TRUE;
    }
    return FALSE;
}

/************************************************************************/
/*-    obj_Dbref_To_Ints3 -- Convert dbref to three integers.		*/
/************************************************************************/

void
obj_Dbref_To_Ints3(
    Vm_Unt *i0,
    Vm_Unt *i1,
    Vm_Unt *i2,
    Vm_Obj  o
) {
    #if MUQ_NET2_RESERVED_BITS < OBJ_INT_SHIFT
    error: Need MUQ_NET2_RESERVED_BITS > OBJ_INT_SHIFT
    #endif
    if (obj_unportable_dbref(o)) {
	MUQ_WARN("Makes no sense to do dbrefToInts3 on this value");
    }

    if (obj_Is_Atomic(o)) {
	*i0 = (o >> OBJ_INT_SHIFT);
	*i1 = 0;
	*i2 = (o & OBJ_INTMASK);
    } else {

	/* Fetch network info from til: */
	Vm_Unt dbfile = VM_DBFILE(o);
	Vm_Obj dbf    = vm_Root(dbfile);
	Vm_Obj til    = DBF_P(dbf)->netinfo_til;
	Vm_Obj dummy;
	Vm_Obj net2;
	Vm_Obj net1   = til_Get( &net2, &dummy, til, o );
	if (net1 == OBJ_NOT_FOUND) {
	    /* Fill in netinfo first time it is needed: */

	    Vm_Unt n1;
	    Vm_Unt n2 = obj_TrueRandom( &n1 );
	    Vm_Obj til2   = til_Set(
		til,
		o,
		(net1=OBJ_FROM_UNT( n1                           )),
		(net2=OBJ_FROM_UNT( n2 << MUQ_NET2_RESERVED_BITS )),
		OBJ_FROM_UNT( 0                            ),
		dbfile
	    );
	    if (til2 != til) {
		DBF_P(dbf)->netinfo_til = til2; vm_Dirty(dbf);
	    }
	}

	*i0 = (o >> OBJ_INT_SHIFT);
	*i1 = OBJ_TO_UNT( net1 );
	*i2 = (
	    ((OBJ_TO_UNT( net2 ) >> (MUQ_NET2_RESERVED_BITS-OBJ_INT_SHIFT)) & ~OBJ_INTMASK)
	    | (o&OBJ_INTMASK)
	);
    }
}

/************************************************************************/
/*-    obj_Ints3_To_Dbref -- Convert three integers back to a dbref.	*/
/************************************************************************/

/* This function is a security weakness, since users can   */
/* potentially use it to forge pointers to (say) strings   */
/* containing other user's private mail.  If you're not    */
/* running distributed applications, you may wish to kill  */
/* this primitive, or restrict use to root.  Distributed   */
/* applications need to be able to exchange pointers, in   */
/* general, and code on other servers can forge pointers   */
/* at will anyhow, so in a heavily distributed environment */
/* there is probably little point in restricting use of    */
/* this prim:                                              */

Vm_Obj
obj_Ints3_To_Dbref(
    Vm_Unt *ok,
    Vm_Unt  i0,
    Vm_Unt  i1,
    Vm_Unt  i2
) {
    Vm_Obj  o = (i0 << OBJ_INT_SHIFT) | (i2 & OBJ_INTMASK);
  
/* BUGGO: This fn currently won't detect scrambling */
/* of the five tagbits -- and I think doing so can  */
/* crash us.  We need to check the claims of the    */
/* tagbits against the ground truth in the object   */
/* itself, which should be possible now that we've  */
/* added explicit class slots everywhere... ?       */

    if (obj_unportable_dbref(o)) {
	*ok = FALSE;
	return OBJ_NIL;
    }
    if (obj_Is_Atomic(o)) {
	*ok = TRUE;
	return o;
    }
    if (!vm_Is_Valid(o)) {
	*ok = FALSE;
	return OBJ_NIL;
    } else {

        Vm_Unt dbfile = VM_DBFILE(o);
	Vm_Obj dbf    = vm_Root(dbfile);
	Vm_Obj til    = DBF_P(dbf)->netinfo_til;
	Vm_Obj net2;
	Vm_Obj net3;
	Vm_Obj net1   = til_Get( &net2, &net3, til, o );
	if (net1 == OBJ_NOT_FOUND) {
	    *ok = FALSE;
	    return OBJ_NIL;
	}
	net1 = OBJ_TO_UNT( net1 );
	net2 = OBJ_TO_UNT( net2 );
	if (net1 != i1)   return FALSE;
	if ((net2 >> MUQ_NET2_RESERVED_BITS)
	==  (  i2 >> OBJ_INT_SHIFT         )
	){
	    *ok = TRUE;
	    return o;
	} else {
	    *ok = FALSE;
	    return OBJ_NIL;
	}
    }
}


/************************************************************************/
/*-    obj_Export_Subobj -- 						*/
/************************************************************************/

void
obj_Export_Subobj(
    FILE*  fd,
    Vm_Obj obj,
    Vm_Int write_owners
) {
    ++obj_Export_Stats->items_in_file;

    /* Atomic objects can be represented by their value: */
    if (obj_Is_Atomic(obj)) {
	obj_export_any( fd, obj, write_owners );
	return;
    }

    /* Composite objects must be represented by a */
    /* reference to them, and we must remember to */
    /* save them out as well:                     */
    fprintf( fd, "r:%" VM_X "\n", obj );
    obj_enqueue_exported_subobject( obj );
}

/************************************************************************/
/*-    obj_Export -- Export generic OBJ_IS_OBJ(o)==TRUE value.		*/
/************************************************************************/

/************************************************************************/
/*-    obj_ignorable_prop -- TRUE iff we don't export this prop.	*/
/************************************************************************/

static Vm_Int
obj_ignorable_prop(
    Vm_Obj key,
    Vm_Int propdir
) {
    /* We only ignore props in SYSTEM propdir: */
    if (propdir != OBJ_PROP_SYSTEM)   return FALSE;

    /* We mainly want to ignore ownership information, */
    /* since we don't really want to restore it in     */
    /* general, and since it tends to force us to save */
    /* and all associated data out when all we really  */
    /* want is the data structure proper:              */
    /* buggo: can't we kill this stuff completely now? */
    if (!obj_StrNeql("owner"  ,  key))   return TRUE;
    if (!obj_StrNeql("changor",  key))   return TRUE;
    if (!obj_StrNeql("creator",  key))   return TRUE;

    return FALSE;
}



void
obj_Export(
    FILE*  fd,
    Vm_Obj obj,
    Vm_Int write_owners
) {
    /* Dig out 3-char class prefix: */
    Vm_Int kl = (OBJ_P(obj)->flagwrd & OBJ_CLASS_MASK) >> OBJ_CLASS_SHIFT;
    Vm_Obj nm = mod_Hardcoded_Class[kl]->name;
    Vm_Int c0 = OBJ_BYT0(nm);
    Vm_Int c1 = OBJ_BYT1(nm);
    Vm_Int c2 = OBJ_BYT2(nm);

    /* Start object: */
    fprintf(fd, "%c%c%c:a:%" VM_X "\n", (int)c0, (int)c1, (int)c2, obj );

    /* Cosmetic newline before first propdir: */
    fputc( '\n', fd );

    /* Over all propdirs in object: */
    {   Vm_Int p;
	for   (p = 0;   p < OBJ_PROP_MAX;   ++p) {

	    /* If propdir holds something: */
	    Vm_Obj key = OBJ_NEXT( obj, OBJ_FIRST, p );
	    if (key != OBJ_NOT_FOUND) {

		/* Print header for propdir: */
		fprintf( fd, "+%s+\n", obj_Propdir_Name[p] );

		/* Over all properties in propdir: */
		for (
		    ;
		    key != OBJ_NOT_FOUND;
		    key  = OBJ_NEXT(  obj, key, p )
		) {
		    if (write_owners || !obj_ignorable_prop( key, p )) {

			Vm_Obj val = OBJ_GET( obj, key, p );

			/* Write "start of keyval pair" line: */
			fputs( "|\n", fd );

			obj_Export_Subobj( fd, key, write_owners );
			obj_Export_Subobj( fd, val, write_owners );
     		}   }

		/* End of propdir: */
		fputc( '\n', fd );
    } 	}   }

    /* End of propdir list: */
    fputc( '\n', fd );
}

/************************************************************************/
/*-    obj_Export_Tree -- Export tree rooted at object to file 'fd'.	*/
/************************************************************************/

 /***********************************************************************/
 /*-   obj_export_queue --						*/
 /***********************************************************************/

/****************************************************************/
/* We need to export each referenced object once and only once.	*/
/* While I don't envision flatfile export being done frequently */
/* enough to be a prime performance focuse, I do expect it to   */
/* be used periodically to export the complete contents of dbs  */
/* of 100,000 -> 10,000,000 objects, so overly naive O(N^2)     */
/* code is likely a bad idea.                                   */
/*                                                              */
/* Consequently, we use a queue to track objects not yet done,  */
/* which can be built and traversed in O(N) time and space.     */
/*                                                              */
/* To track whether a given object is already in the queue, we  */
/* use a hashtable which is sized big enough to yield good      */
/* performance on dbs in the expected size range.  Each queue   */
/* node is also a hash bucket, threaded independently on qnext  */
/* and hnext.							*/
/****************************************************************/

struct obj_export_queue_node {
    Vm_Obj                         o;
    struct obj_export_queue_node * qnext;	/* Next in queue.	*/
    struct obj_export_queue_node * hnext;	/* Next in chain.	*/
};

typedef struct obj_export_queue_node Obj_a_oq;
typedef struct obj_export_queue_node * Obj_oq;

#define OBJ_EXPORT_HASHTAB_MAX  (0x40000)
#define OBJ_EXPORT_HASHTAB_MASK (OBJ_EXPORT_HASHTAB_MAX-1)
static Obj_oq* obj_export_hashtab;
static Obj_oq  obj_export_queue;
static Obj_oq  obj_export_queue_end;

 /***********************************************************************/
 /*-   obj_export_queue_alloc --					*/
 /***********************************************************************/

static void
obj_export_queue_alloc(
    void
) {

    /* Initialize work queue to empty: */
    obj_export_queue     = NULL;
    obj_export_queue_end = NULL;

    obj_export_hashtab = (Obj_oq*) malloc(
	OBJ_EXPORT_HASHTAB_MAX * sizeof( Obj_oq )
    );
    {   Vm_Int i = OBJ_EXPORT_HASHTAB_MAX;
	while (i --> 0)   obj_export_hashtab[i] = NULL;
    }
}

 /***********************************************************************/
 /*-   obj_export_queue_free --						*/
 /***********************************************************************/

static void
obj_export_queue_free(
    void
) {

    /* Recycle ram used by queue: */
    {   Obj_oq p;
	Obj_oq q;
	for  (p=obj_export_queue; p; p=q) { q=p->qnext; free(p); }
    }
    free( obj_export_hashtab );
}

 /***********************************************************************/
 /*-   obj_is_in_queue --						*/
 /***********************************************************************/

static Obj_oq
obj_is_in_queue(
    Vm_Obj o
) {
    Vm_Int chain = o & OBJ_EXPORT_HASHTAB_MASK;
    Obj_oq  q     = obj_export_hashtab[ chain ];
    for  (;   q;   q = q->hnext) {
	if (q->o == o)     return q;
    }
    return NULL;
}

 /***********************************************************************/
 /*-   obj_enqueue_exported_subobj --					*/
 /***********************************************************************/

static void
obj_enqueue_exported_subobject(
    Vm_Obj o
) {
    if (!obj_is_in_queue( o )) {
	Obj_oq q  = (Obj_oq) malloc( sizeof( Obj_a_oq ) );
	q->o     = o;
	q->qnext = NULL;
	if(!obj_export_queue_end) {
	    obj_export_queue_end        = q;
	    obj_export_queue            = q;
	} else {
	    obj_export_queue_end->qnext = q;
	    obj_export_queue_end        = q;
	}
	{   Vm_Int chain = o & OBJ_EXPORT_HASHTAB_MASK;
	    q->hnext = obj_export_hashtab[ chain ];
	    obj_export_hashtab[ chain ] = q;
	}
	++obj_Export_Stats->objects_in_file;
    }
}

 /***********************************************************************/
 /*-   obj_export_any -- Export one value of any type whatever.		*/
 /***********************************************************************/

static void
obj_export_any(
    FILE*   fd,
    Vm_Obj  obj,
    Vm_Int  write_owners
) {
    (*mod_Type_Summary[ OBJ_TYPE(obj) ]->export)( fd, obj, write_owners );
}



void
obj_Export_Tree(
    FILE*            fd,
    Vm_Obj           root,
    Obj_Export_Stats stats,
    Vm_Int           write_owners
) {
    obj_Export_Stats = stats;
    stats->objects_in_file  = 0;
    stats->items_in_file    = 0;

    obj_export_queue_alloc();

    /* Queue root object, then write out all queued objects: */
    if (obj_Is_Atomic( root ))   obj_Export_Subobj( fd, root, write_owners );
    else 			 obj_enqueue_exported_subobject( root      );

    {   Obj_oq q;
	for   (q = obj_export_queue;   q;   q = q->qnext) {
	    obj_export_any( fd, q->o, write_owners );
    }	}

    obj_export_queue_free();

    /* End of stream: */
    fputc( '\n', fd );
}

/************************************************************************/
/*-    obj_Import -- Import generic object.				*/
/************************************************************************/

Vm_Obj
obj_Import(
    FILE*  fd,
    Vm_Int kl,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    /* Read old id of object: */
    Vm_Uch c;
    Vm_Obj n;
    Vm_Obj o;
    if (2 != fscanf(fd, "%c:%" VM_X, &c, &o )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("obj_Import: bad input!");
    }
    if (c != 'a')   MUQ_FATAL ("obj_Import: unsupported file format.");

    /* Make/find obj to hold result: */
    n = (pass ? obj_Import_Hashtab_Val( o ) : obj_Alloc( kl, 0 ) );
    if (!pass)  obj_Import_Hashtab_Enter( n, o );

    /* Read cosmetic newline preceding first propdir: */
    if (fgetc(fd) != '\n')   MUQ_FATAL ("obj_Import: bad input!\n");

    /* Over all propdirs in file image of object: */
    for (;;) {
	/* Read propdir name, exit if no */
	/* more propdirs in this object: */
	Vm_Uch linebuf[ 132 ];
	Vm_Uch propdir[ 132 ];
	Vm_Int p;
	if (!fgets( linebuf, 132, fd )) {
	    MUQ_FATAL ("obj_Import: bad input!\n");
	}
	if (STRCMP( linebuf, == ,"\n" ))   break; /* End of propdir list */
	if (1 != sscanf(linebuf, "+%[^+]+", propdir )) {
	    MUQ_FATAL ("obj_Import: bad input!\n");
	}

	/* Translate ascii propdir name to int: */
	for (p = 0;   p < OBJ_PROP_MAX;   ++p) {
	    if (STRCMP( propdir, == ,obj_Propdir_Name[p]))   break;
	}
	if (p == OBJ_PROP_MAX) {
	    MUQ_FATAL ("obj_Import: unknown propdir type: '%s'\n",propdir);
	}

	/* Over all keyval pairs in propdir: */
	for (;;) {
	    if (!fgets( linebuf, 132, fd )) {
		MUQ_FATAL ("obj_Import: bad input!\n");
	    }
	    if (STRCMP(linebuf, == ,"\n" ))   break; /* End of keyval list */
	    if (STRCMP(linebuf, != ,"|\n"))MUQ_FATAL ("obj_Import: bad input!\n");
	    {   Vm_Obj key = obj_Import_Any( fd, pass, have, read );
		Vm_Obj val = obj_Import_Any( fd, pass, have, read );
		if (pass)   OBJ_SET( n, key, val, p );
    }   }   }

    if (pass && read) obj_Import_Bump_Bytes_Used(n);

    ++obj_Export_Stats->objects_in_file;

    return n;
}

/************************************************************************/
/*-    obj_Import_Bump_Bytes_Used -- Update accounting info.		*/
/************************************************************************/

void
obj_Import_Bump_Bytes_Used(
    Vm_Obj o
) {
    /* When importing a file, we create objects */
    /* before we know who owns them.  Here we   */
    /* need to charge 'o's owner for the bytes  */
    /* it occupies, and uncharge the current    */
    /* user (usually Root):                     */
/* buggo, not implemented yet */
/* NB: If 'o' is an object, we also need to reverse  */
/* charges on all blocks in propdirs, while updating */
/* ownership info as well. */
}

/************************************************************************/
/*-    obj_Import_Any -- Import one value of any type whatever.		*/
/************************************************************************/

/************************************************************************/
/*-    obj_import_ref -- Import reference to other object.		*/
/************************************************************************/

static Vm_Obj
obj_import_ref(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have, /* TRUE if input file has owner info.   */
    Vm_Int read  /* FALSE means ignore above if present. */
) {
    Vm_Int old;
    if (1 != fscanf(fd, "%" VM_X, &old )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("obj_import_ref: bad input");
    }

    ++obj_Export_Stats->items_in_file;

    return   pass ? obj_Import_Hashtab_Val(old) : OBJ_NIL;
}



Vm_Obj
obj_Import_Any(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have, /* TRUE if input file has owner info.   */
    Vm_Int read  /* FALSE means ignore above if present. */
) {
    /* Read ':'-terminated type field at start of line: */
    Vm_Uch  typ[ 4 ];
    Vm_Uch* t =  typ;
    Vm_Int  c;
    while ((c = fgetc(fd)) != ':') {
	if (c == '\n')   return (Vm_Obj) FALSE; /* End of file. */
	if (t >= &typ[4]) MUQ_FATAL ("obj.c:obj_Import_Any: bad file format.");
	*t++ = c;
    }
    *t = '\0';

    /* Nonatomic intra-object references are a special case: */
    if (STRCMP( "r", == ,typ))   return obj_import_ref( fd, pass, have, read );

    /* Hardwired nonobject types have */
    /* single-char type fields:       */
    if (strlen(typ) == 1) {

	Vm_Unt c = (Vm_Unt) typ[0];
	Vm_Int i = OBJ_TYPE_MAX;
	while (i --> 0) {
	    Vm_Obj nm = mod_Type_Summary[i]->name;
	    switch (OBJ_TYPE(nm)) {
            #if VM_INTBYTES > 4
	    case OBJ_TYPE_BYT7:
		if (OBJ_BYT6(nm) == c) {
		    return mod_Type_Summary[i]->import(fd,pass,have,read);
		}   /* Fall-through */
	    case OBJ_TYPE_BYT6:
		if (OBJ_BYT5(nm) == c) {
		    return mod_Type_Summary[i]->import(fd,pass,have,read);
		}   /* Fall-through */
	    case OBJ_TYPE_BYT5:
		if (OBJ_BYT4(nm) == c) {
		    return mod_Type_Summary[i]->import(fd,pass,have,read);
		}   /* Fall-through */
	    case OBJ_TYPE_BYT4:
		if (OBJ_BYT3(nm) == c) {
		    return mod_Type_Summary[i]->import(fd,pass,have,read);
		}   /* Fall-through */
	    #endif
	    case OBJ_TYPE_BYT3:
		if (OBJ_BYT2(nm) == c) {
		    return mod_Type_Summary[i]->import(fd,pass,have,read);
		}   /* Fall-through */
	    case OBJ_TYPE_BYT2:
		if (OBJ_BYT1(nm) == c) {
		    return mod_Type_Summary[i]->import(fd,pass,have,read);
		}   /* Fall-through */
	    case OBJ_TYPE_BYT1:
		if (OBJ_BYT0(nm) == c) {
		    return mod_Type_Summary[i]->import(fd,pass,have,read);
		}   /* Fall-through */
	    case OBJ_TYPE_BYT0:
		continue;
	    default:
		MUQ_FATAL ("obj_Import_Any: Error in mod_Type_Summary[]");
	    }
	}

    } else if (strlen(typ) == 3) {

	/* 3-char typefield means an object of some class: */
	Vm_Obj n = OBJ_FROM_BYT3( typ[0], typ[1], typ[2] );
	Vm_Int i;

	/* Over all defined classes: */
	for (i = OBJ_CLASS_MAX;   i --> 0;   ) {
	    if (mod_Hardcoded_Class[i]->name == n) {
		return (*mod_Hardcoded_Class[i]->import)(
		    fd, i, pass, have, read
		);
      	}   }
    }
    MUQ_FATAL ("obj_import_any: unsupported type %s\n", typ );
    return (Vm_Obj)0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_Import_Tree -- Import tree from                file 'fd'.	*/
/************************************************************************/

 /***********************************************************************/
 /*-   obj_import_hashtab --						*/
 /***********************************************************************/

/****************************************************************/
/* Objects in the input file are identified by old dbrefs, but	*/
/* we cannot in general give them the same dbref after loading	*/
/* them in, since (for example) it may already be in use.	*/
/*								*/
/* Obviously, we need to change all references to the old dbref	*/
/* for the object to the new dbref, as loading proceeds.  Here	*/
/* we implement a hashtable which maps from old dbrefs to new	*/
/* dbrefs:							*/
/****************************************************************/

#define OBJ_IMPORT_HASHTAB_MAX  (0x40000)
#define OBJ_IMPORT_HASHTAB_MASK (OBJ_IMPORT_HASHTAB_MAX-1)

struct obj_import_hashtab_node {
    Vm_Obj old;
    Vm_Obj new;
    struct obj_import_hashtab_node* next;
};
typedef struct obj_import_hashtab_node Obj_a_hn;
typedef struct obj_import_hashtab_node * Obj_hn;

static Obj_hn* obj_import_hashtab;

 /***********************************************************************/
 /*-   obj_import_hashtab_alloc --					*/
 /***********************************************************************/

static void
obj_import_hashtab_alloc(
    void
) {

    obj_import_hashtab = (Obj_hn*) malloc(
	OBJ_IMPORT_HASHTAB_MAX * sizeof( Obj_hn )
    );
    {   Vm_Int i = OBJ_IMPORT_HASHTAB_MAX;
	while (i --> 0)   obj_import_hashtab[i] = NULL;
    }
}

 /***********************************************************************/
 /*-   obj_import_hashtab_free --					*/
 /***********************************************************************/

static void
obj_import_hashtab_free(
     void
) {

    /* Recycle ram used by hashtab: */
    {   Vm_Int i = OBJ_IMPORT_HASHTAB_MAX;
	while (i --> 0) {
	    Obj_hn p;
	    Obj_hn q;
	    for  (p=obj_import_hashtab[i]; p; p=q) { q=p->next; free(p); }
    }   }
    free( obj_import_hashtab );
}



Vm_Obj
obj_Import_Tree(
    FILE*            fd,
    Obj_Export_Stats stats,
    Vm_Int	     pass,
    Vm_Int have_owners,	/* TRUE if input file has owner info.   */
    Vm_Int read_owners  /* FALSE means ignore above if present. */
) {
    obj_Export_Stats = stats;
    stats->objects_in_file  = 0;
    stats->items_in_file    = 0;

    if (!pass)   obj_import_hashtab_alloc();

    {   /* Read in root object: */
	Vm_Obj root = obj_Import_Any( fd, pass, have_owners, read_owners );

	/* Read in rest of objects in file: */
	while (obj_Import_Any( fd, pass, have_owners, read_owners ));

	/* Maybe free up our temporary data structure: */
	if (pass)   obj_import_hashtab_free();

	/* Done: */
	return root;
    }
}

/************************************************************************/
/*-    obj_Import_Hashtab_Val --					*/
/************************************************************************/

Vm_Obj
obj_Import_Hashtab_Val(
    Vm_Obj old
) {
    Vm_Int chain = old & OBJ_IMPORT_HASHTAB_MASK;
    Obj_hn q     = obj_import_hashtab[ chain ];
    for  (;   q;   q = q->next) {
	if (q->old == old)     return q->new;
    }
    MUQ_FATAL ("obj_Import_Hashtab_Val: reference to undefined object!\n");
    return old; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_Import_Hashtab_Enter --					*/
/************************************************************************/

void
obj_Import_Hashtab_Enter(
    Vm_Obj new,
    Vm_Obj old
) {
    Vm_Int chain = old & OBJ_IMPORT_HASHTAB_MASK;
    Obj_hn q = (Obj_hn) malloc( sizeof( Obj_a_hn ) );
    q->old   = old;
    q->new   = new;
    q->next  = obj_import_hashtab[ chain ];

    obj_import_hashtab[ chain ] = q;

    ++obj_Export_Stats->objects_in_file;
}

/************************************************************************/
/*-    obj_X_Key -- Find next key with given value.			*/
/************************************************************************/

/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/*****************************************************/
/* This function provides reverse keyVal mapping:   */
/* given an object and a val, it attempts to find a  */
/* key with that value.  On almost all object kinds, */
/* this is going to be much less efficient than the  */
/* usual key-to-val lookup, but it is something we   */
/* occasionally need to do. (The original motivation */
/* for the facility was the compilers need to search */
/* a stack for a given symbol, to implement block    */
/* structuring.)                                     */
/*                                                   */
/* Particular kinds of object may wish to provide    */
/* efficient implementations of this operation; the  */
/* purpose of this particular function is to provide */
/* a generic fallback implementation available to    */
/* all kinds of objects.                             */
/*****************************************************/



Vm_Obj
obj_X_Key(
    Vm_Obj obj,
    Vm_Obj key,	/* OBJ_NOT_FOUND else take 1st eligible key before/after it.*/
    Vm_Obj val, /* Accept only keys with this value. */
    Vm_Int forward, /* TRUE to search forward, FALSE to search backward. */
    Vm_Int propdir
){
    /* Possibly the most inscrutable fn in this file :) */
    Vm_Int typ      = OBJ_TYPE(obj);
    Vm_Obj last_key = OBJ_NOT_FOUND;
    Vm_Obj k        = OBJ_FIRST    ;
    for (
	k  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, k, propdir );
	k != OBJ_NOT_FOUND;
	k  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, k, propdir )
    ) {
	Vm_Obj v;
	v  = (*mod_Type_Summary[ typ ]->for_get)( obj, k, propdir );
	if (v == val) {
	    if (forward) {
		if      (key == OBJ_NOT_FOUND)   return k;
		else if (key == k            )   key = OBJ_NOT_FOUND;
	    } else {
		if      (key == OBJ_NOT_FOUND)   last_key = k;
		else if (key == k            )   return last_key;
    }   }   }
    return last_key;
}

/************************************************************************/
/*-    obj_Caseless_Neql -- Sort two objects a la strcmp().		*/
/************************************************************************/

/* Copys of obj_Neql which ignores case. */

Vm_Int
obj_Caseless_Neql(
    Vm_Obj a,
    Vm_Obj b
) {
    Vm_Int typ_a;
    Vm_Int len_a =0;
    Vm_Uch buf_a[VM_INTBYTES];

    Vm_Int typ_b;
    Vm_Int len_b =0;
    Vm_Uch buf_b[VM_INTBYTES];

    switch (typ_a = OBJ_TYPE(a)) {

    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_THUNK  :
    case OBJ_TYPE_CFN    :
    case OBJ_TYPE_FLOAT  :
    case OBJ_TYPE_INT    :
    case OBJ_TYPE_BIGNUM :
    case OBJ_TYPE_OBJ    :
    case OBJ_TYPE_CONS   :
    case OBJ_TYPE_SYMBOL :
    case OBJ_TYPE_CHAR   :
    case OBJ_TYPE_BLK    :
    case OBJ_TYPE_VEC    :
    case OBJ_TYPE_I16    :
    case OBJ_TYPE_I32    :
    case OBJ_TYPE_F32    :
    case OBJ_TYPE_F64    :
    case OBJ_TYPE_BYTN   :	break;

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7   :	++len_a; buf_a[6] = OBJ_BYT6(a);
    case OBJ_TYPE_BYT6   :	++len_a; buf_a[5] = OBJ_BYT5(a);
    case OBJ_TYPE_BYT5   :	++len_a; buf_a[4] = OBJ_BYT4(a);
    case OBJ_TYPE_BYT4   :	++len_a; buf_a[3] = OBJ_BYT3(a);
    #endif
    case OBJ_TYPE_BYT3   :	++len_a; buf_a[2] = OBJ_BYT2(a);
    case OBJ_TYPE_BYT2   :	++len_a; buf_a[1] = OBJ_BYT1(a);
    case OBJ_TYPE_BYT1   :	++len_a; buf_a[0] = OBJ_BYT0(a);
    case OBJ_TYPE_BYT0   :	typ_a = OBJ_TYPE_BYT0;	      break;

    default		 :	MUQ_FATAL ("internal error");
    }



    switch (typ_b=OBJ_TYPE(b)) {

    case OBJ_TYPE_CHAR:
	if (typ_a == typ_b) {
	    return tolower(OBJ_TO_CHAR(a))-tolower(OBJ_TO_CHAR(b));
	}
        return typ_a - typ_b;

    case OBJ_TYPE_BLK:
/* buggo? comparing a BLK val should likely be an error. */
    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_THUNK:
    case OBJ_TYPE_CFN:
    case OBJ_TYPE_SYMBOL:
	if (typ_a == typ_b)    return a-b;
        return typ_a - typ_b;

    case OBJ_TYPE_OBJ:
	if (typ_a == typ_b
	&& OBJ_IS_CLASS_PRX(a)
	&& OBJ_IS_CLASS_PRX(b)
        ){
	    /* Proxies we -do- want to compare by contents: */
	    Prx_P pa;
	    Prx_P pb;
	    vm_Loc2( (void**)&pa, (void**)&pb, a, b );
	    if (pa->guest   != pb->guest)     return (Vm_Int)(pa->guest -pb->guest);
	    if (pa->i0      != pb->i0)        return (Vm_Int)(pa->i0      - pb->i0);
	    if (pa->i1      != pb->i1)        return (Vm_Int)(pa->i1      - pb->i1);
	    if (pa->i2      != pb->i2)        return (Vm_Int)(pa->i2      - pb->i2);
	    return 0;
	}
	/* FALL-THROUGH */

    case OBJ_TYPE_CONS:
    case OBJ_TYPE_VEC:
    case OBJ_TYPE_I16:
    case OBJ_TYPE_I32:
    case OBJ_TYPE_F32:
    case OBJ_TYPE_F64:
	/* Note that we do _not_ want to compare objects  */
	/* or vectors by value, because they are side-    */
        /* effectable.  The concept of a side-effectable  */
	/* value includes having an identity which is     */
	/* independent of its contents, and of not being  */
	/* equal to any other object.  To me, currently:  */
        if (typ_a != typ_b)   return typ_a - typ_b;
	return a - b;

    case OBJ_TYPE_FLOAT:
	{   float f = OBJ_TO_FLOAT(b);
	    switch (typ_a) {
	    case OBJ_TYPE_FLOAT: return (int)(     OBJ_TO_FLOAT(a) - f);
	    case OBJ_TYPE_INT  : return (int)((float)OBJ_TO_INT(a) - f);
	    default	       : return      typ_a - typ_b;
	}   }

    case OBJ_TYPE_BIGNUM:
	{   switch (typ_a) {
/* buggo, not handling float to bignum comparisons sensibly yet. */
/*	    case OBJ_TYPE_FLOAT : return (int)(OBJ_TO_FLOAT(   a) - (float) i); */
	    case OBJ_TYPE_INT   : return bnm_NeqlIB(OBJ_TO_INT(a),          b);
	    case OBJ_TYPE_BIGNUM: return bnm_NeqlBB(           a,           b);
	    default	        : return       typ_a - typ_b;
	}   }


    case OBJ_TYPE_INT:
	{   int i = OBJ_TO_INT(b);
	    switch (typ_a) {
	    case OBJ_TYPE_FLOAT : return (int)(OBJ_TO_FLOAT(a) - (float)i);
	    case OBJ_TYPE_INT   : return       OBJ_TO_INT(  a) -        i ;
	    case OBJ_TYPE_BIGNUM: return bnm_NeqlBI(        a,          i);
	    default	        : return       typ_a - typ_b;
	}   }

    case OBJ_TYPE_BYTN:
	switch (typ_a) {

	case OBJ_TYPE_BYTN:
	    {   Stg_P pa;	Vm_Unt len_a = stg_Len(a);
		Stg_P pb;	Vm_Unt len_b = stg_Len(b);
		vm_Loc2( (void**)&pa, (void**)&pb, a, b );
		return obj_Caseless_StrCmp( pa->byte,len_a, pb->byte,len_b );
	    }

	case OBJ_TYPE_BYT0:
	    {   Vm_Unt  len_b = stg_Len( b );
	        Stg_P   pb    = STG_P(   b );
		return obj_Caseless_StrCmp( buf_a,len_a, pb->byte,len_b );
	    }

	default:
	    return   typ_a - typ_b;
	}

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:	++len_b; buf_b[6] = OBJ_BYT6(b);
    case OBJ_TYPE_BYT6:	++len_b; buf_b[5] = OBJ_BYT5(b);
    case OBJ_TYPE_BYT5:	++len_b; buf_b[4] = OBJ_BYT4(b);
    case OBJ_TYPE_BYT4:	++len_b; buf_b[3] = OBJ_BYT3(b);
    #endif
    case OBJ_TYPE_BYT3:	++len_b; buf_b[2] = OBJ_BYT2(b);
    case OBJ_TYPE_BYT2:	++len_b; buf_b[1] = OBJ_BYT1(b);
    case OBJ_TYPE_BYT1:	++len_b; buf_b[0] = OBJ_BYT0(b);
    case OBJ_TYPE_BYT0:
	switch (typ_a) {

	case OBJ_TYPE_BYTN:
	    {   Vm_Unt  len_a = stg_Len( a );
	        Stg_P   pa    = STG_P(   a );
		return obj_Caseless_StrCmp( pa->byte,len_a, buf_b,len_b );
	    }

	case OBJ_TYPE_BYT0:
	    return obj_Caseless_StrCmp( buf_a,len_a, buf_b,len_b );

	default:
	    return   typ_a - typ_b;
	}

    default		 :	MUQ_FATAL ("internal error");
    }
    return 0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_Caseless_StrCmp -- Compare two strings, given lengths.	*/
/************************************************************************/

Vm_Int
obj_Caseless_StrCmp(
    Vm_Uch* p_a, Vm_Int a_len,
    Vm_Uch* p_b, Vm_Int b_len
) {
    /* Most time-critical variables first: */
    register Vm_Sch  a;
    register Vm_Sch  b;
    register Vm_Sch* pa = (Vm_Sch*)p_a-1;
    register Vm_Sch* pb = (Vm_Sch*)p_b-1;
    register Vm_Int  i;
    if (a_len < b_len) {
	for (i = a_len+1;   --i;   ) {
	    a = tolower(*++pa);
	    b = tolower(*++pb);
	    if (a != b)  return a - b;
	}
	return -*++pb;
    } else {
	for (i = b_len+1;   --i;   ) {
	    a = tolower(*++pa);
	    b = tolower(*++pb);
	    if (a != b)  return a - b;
	}
	return a_len > b_len ? *++pa : 0;
    }
}

/************************************************************************/
/*-    obj_Neql -- Sort two objects a la strcmp().			*/
/************************************************************************/

/************************************************************************/
/* We return:								*/
/*    + if a >  b,							*/
/*    0 if a == b,							*/
/*    - if a <  b							*/
/* Style of comparison is driven by types of a and b:			*/
/* Byte sequences are compared  a la strcmp()				*/
/* Floats/ints/doubles are compared numerically, in all combinations.	*/
/* Otherwise, if a and b are of same type, pointer comparison is done	*/
/* Otherwise, an arbitrary ordering of types is used:			*/
/*     byteseqs < vectors < objs < numbers.				*/
/* (The tagbit encodings are selected to facilitate this sort.)		*/
/************************************************************************/

static Vm_Int
obj_neql(
    Vm_Obj a,
    Vm_Obj b
) {
    Vm_Int typ_a;
    Vm_Int len_a =0;
    Vm_Uch buf_a[VM_INTBYTES];

    Vm_Int typ_b;
    Vm_Int len_b =0;
    Vm_Uch buf_b[VM_INTBYTES];

    switch (typ_a = OBJ_TYPE(a)) {

    case OBJ_TYPE_BLK    :
/* buggo, BLK here should likely be an error */
    case OBJ_TYPE_EPHEMERAL_LIST:
    case OBJ_TYPE_EPHEMERAL_STRUCT:
    case OBJ_TYPE_EPHEMERAL_VECTOR:
    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_THUNK  :
    case OBJ_TYPE_CFN    :
    case OBJ_TYPE_FLOAT  :
    case OBJ_TYPE_INT    :
    case OBJ_TYPE_BIGNUM :
    case OBJ_TYPE_OBJ    :
    case OBJ_TYPE_STRUCT :
    case OBJ_TYPE_CONS   :
    case OBJ_TYPE_SYMBOL :
    case OBJ_TYPE_CHAR   :
    case OBJ_TYPE_VEC    :
    case OBJ_TYPE_I16    :
    case OBJ_TYPE_I32    :
    case OBJ_TYPE_F32    :
    case OBJ_TYPE_F64    :
    case OBJ_TYPE_BYTN   :	break;

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7   :	++len_a; buf_a[6] = OBJ_BYT6(a);
    case OBJ_TYPE_BYT6   :	++len_a; buf_a[5] = OBJ_BYT5(a);
    case OBJ_TYPE_BYT5   :	++len_a; buf_a[4] = OBJ_BYT4(a);
    case OBJ_TYPE_BYT4   :	++len_a; buf_a[3] = OBJ_BYT3(a);
    #endif
    case OBJ_TYPE_BYT3   :	++len_a; buf_a[2] = OBJ_BYT2(a);
    case OBJ_TYPE_BYT2   :	++len_a; buf_a[1] = OBJ_BYT1(a);
    case OBJ_TYPE_BYT1   :	++len_a; buf_a[0] = OBJ_BYT0(a);
    case OBJ_TYPE_BYT0   :	typ_a = OBJ_TYPE_BYT0;	      break;

    default		 :	MUQ_FATAL ("internal error");
    }



    switch (typ_b=OBJ_TYPE(b)) {

    case OBJ_TYPE_BLK    :
/* buggo, BLK here should likely be an error */
    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_THUNK:
    case OBJ_TYPE_CFN:
    case OBJ_TYPE_CHAR:
    case OBJ_TYPE_SYMBOL:
	if (typ_a == typ_b)    return a-b;
        if (typ_a != typ_b)   return typ_a - typ_b;
	return a - b;

    case OBJ_TYPE_OBJ:
	if (typ_a == typ_b
	&& OBJ_IS_CLASS_PRX(a)
	&& OBJ_IS_CLASS_PRX(b)
        ){
	    /* Proxies we -do- want to compare by contents: */
	    Prx_P pa;
	    Prx_P pb;
	    vm_Loc2( (void**)&pa, (void**)&pb, a, b );
	    if (pa->guest   != pb->guest)     return (Vm_Int)(pa->guest -pb->guest);
	    if (pa->i0      != pb->i0)        return (Vm_Int)(pa->i0      - pb->i0);
	    if (pa->i1      != pb->i1)        return (Vm_Int)(pa->i1      - pb->i1);
	    if (pa->i2      != pb->i2)        return (Vm_Int)(pa->i2      - pb->i2);
	    return 0;
	}
	/* FALL-THROUGH */
    case OBJ_TYPE_EPHEMERAL_LIST:
    case OBJ_TYPE_EPHEMERAL_STRUCT:
    case OBJ_TYPE_EPHEMERAL_VECTOR:
    case OBJ_TYPE_STRUCT:
    case OBJ_TYPE_CONS:
    case OBJ_TYPE_VEC:
    case OBJ_TYPE_I16:
    case OBJ_TYPE_I32:
    case OBJ_TYPE_F32:
    case OBJ_TYPE_F64:
	/* Note that we do _not_ want to compare objects  */
	/* or vectors by value, because they are side-    */
        /* effectable.  The concept of a side-effectable  */
	/* value includes having an identity which is     */
	/* independent of its contents, and of not being  */
	/* equal to any other object.  To me, currently:  */
        if (typ_a != typ_b)   return typ_a - typ_b;
	return a - b;

    case OBJ_TYPE_FLOAT:
	{   Vm_Flt f = OBJ_TO_FLOAT(b);
	    switch (typ_a) {
	    case OBJ_TYPE_FLOAT:
		{   Vm_Flt g =  OBJ_TO_FLOAT(a) - f;
		    if    (g < 0.0)   return -1;
		    return g > 0.0;
		}
	    case OBJ_TYPE_INT  :
		{   Vm_Flt g =  (Vm_Flt)OBJ_TO_INT(a) - f;
		    if    (g < 0.0)   return -1;
		    return g > 0.0;
		}
	    default	       : return         typ_a - typ_b;
	}   }

    case OBJ_TYPE_BIGNUM:
	{   switch (typ_a) {
/* buggo, not handling float to bignum comparisons sensibly yet. */
/*	    case OBJ_TYPE_FLOAT : return (Vm_Int)(OBJ_TO_FLOAT(   a) - (float) i); */
	    case OBJ_TYPE_INT   : return bnm_NeqlIB(OBJ_TO_INT(a),          b);
	    case OBJ_TYPE_BIGNUM: return bnm_NeqlBB(           a,           b);
	    default	        : return       typ_a - typ_b;
	}   }


    case OBJ_TYPE_INT:
	{   Vm_Int i = OBJ_TO_INT(b);
	    switch (typ_a) {
	    case OBJ_TYPE_FLOAT :
		{   Vm_Flt f =  OBJ_TO_FLOAT(a) - (Vm_Flt)i;
		    if    (f < 0.0)   return -1;
		    return f > 0.0;
		}
	    case OBJ_TYPE_INT   : return       OBJ_TO_INT(  a) -        i ;
	    case OBJ_TYPE_BIGNUM: return bnm_NeqlBI(        a,          i);
	    default	        : return       typ_a - typ_b;
	}   }

    case OBJ_TYPE_BYTN:
	switch (typ_a) {

	case OBJ_TYPE_BYTN:
	    {   Stg_P pa;	Vm_Unt len_a = stg_Len(a);
		Stg_P pb;	Vm_Unt len_b = stg_Len(b);
		vm_Loc2( (void**)&pa, (void**)&pb, a, b );
		return obj_StrCmp( pa->byte,len_a, pb->byte,len_b );
	    }

	case OBJ_TYPE_BYT0:
	    {   Vm_Unt  len_b = stg_Len( b );
	        Stg_P   pb    = STG_P(   b );
		return obj_StrCmp( buf_a,len_a, pb->byte,len_b );
	    }

	default:
	    return   typ_a - typ_b;
	}

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:	++len_b; buf_b[6] = OBJ_BYT6(b);
    case OBJ_TYPE_BYT6:	++len_b; buf_b[5] = OBJ_BYT5(b);
    case OBJ_TYPE_BYT5:	++len_b; buf_b[4] = OBJ_BYT4(b);
    case OBJ_TYPE_BYT4:	++len_b; buf_b[3] = OBJ_BYT3(b);
    #endif
    case OBJ_TYPE_BYT3:	++len_b; buf_b[2] = OBJ_BYT2(b);
    case OBJ_TYPE_BYT2:	++len_b; buf_b[1] = OBJ_BYT1(b);
    case OBJ_TYPE_BYT1:	++len_b; buf_b[0] = OBJ_BYT0(b);
    case OBJ_TYPE_BYT0:
	switch (typ_a) {

	case OBJ_TYPE_BYTN:
	    {   Vm_Unt  len_a = stg_Len( a );
	        Stg_P   pa    = STG_P(   a );
		return obj_StrCmp( pa->byte,len_a, buf_b,len_b );
	    }

	case OBJ_TYPE_BYT0:
	    return obj_StrCmp( buf_a,len_a, buf_b,len_b );

	default:
	    return   typ_a - typ_b;
	}

    default		 :	MUQ_FATAL ("internal error");
    }
    return 0; /* Pacify gcc. */
}

/* This would be a good function to inline */
/* on compilers supporting that:           */
Vm_Int
obj_Neql(
    Vm_Obj a,
    Vm_Obj b
) {
#ifdef ALAS_PROBABLY_NEVER
    if (OBJ_IMMEDIATE(a) & OBJ_IMMEDIATE(b)) {
	return   a - b;
    }
    /************************************************/
    /* It would be nice to do most comparisons      */
    /* quickly per the above code, but doing it     */
    /* it correctly is more work than I have time   */
    /* for just now.  Constraints to be met include */
    /* o OBJ_FIRST must sort before everything else.*/
    /* o Integers must sort arithmetically.         */
    /* o Floats   must sort arithmetically.         */
    /* o Ints vs floats must sort arithmetically.   */
    /* o Strings must sort by ascii collating order.*/
    /* o Transitivity: if a<b and & b<c then a<c.   */
    /*                                              */
    /* This is one case where having the tagbits at */
    /* the high end of the word would help a bit -- */
    /* but that would slow down fixnum arithmetic.  */
    /************************************************/
#endif
    /* Put the rest of the logic in a separate fn   */
    /* because compilers often do a better job of   */
    /* optimizing a small, simple function, and     */
    /* also in anticipation of inlining:            */
    return obj_neql(a,b);
}

/************************************************************************/
/*-    obj_StrNeql -- Sort asciz string and object a la strcmp().	*/
/************************************************************************/

static Vm_Int
obj_strNeql(
    Vm_Uch*buf_a,
    Vm_Obj b
) {
    Vm_Int typ_a=OBJ_TYPE_BYT0;
    Vm_Int len_a=strlen(buf_a);

    Vm_Int typ_b;
    Vm_Int len_b =0;
    Vm_Uch buf_b[VM_INTBYTES];

    switch (typ_b = OBJ_TYPE(b)) {

    case OBJ_TYPE_BYTN:
	{   Vm_Unt  len_b = stg_Len( b );
	    Vm_Uch* pb    = &STG_P(  b )->byte[0];
	    return obj_StrCmp( buf_a,len_a, pb,len_b );
	}

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:	++len_b; buf_b[6] = OBJ_BYT6(b);
    case OBJ_TYPE_BYT6:	++len_b; buf_b[5] = OBJ_BYT5(b);
    case OBJ_TYPE_BYT5:	++len_b; buf_b[4] = OBJ_BYT4(b);
    case OBJ_TYPE_BYT4:	++len_b; buf_b[3] = OBJ_BYT3(b);
    #endif
    case OBJ_TYPE_BYT3:	++len_b; buf_b[2] = OBJ_BYT2(b);
    case OBJ_TYPE_BYT2:	++len_b; buf_b[1] = OBJ_BYT1(b);
    case OBJ_TYPE_BYT1:	++len_b; buf_b[0] = OBJ_BYT0(b);
    case OBJ_TYPE_BYT0:
	return obj_StrCmp( buf_a,len_a, buf_b,len_b );

    default:
	return typ_a - typ_b;
    }
}

Vm_Int
obj_StrNeql(
    Vm_Uch*a,
    Vm_Obj b
) {
    switch (strlen(a)) {

    #if VM_INTBYTES > 4
    case 7:	return obj_Neql( OBJ_FROM_BYT7( a[0], a[1], a[2], a[3], a[4], a[5], a[6]), b );
    case 6:	return obj_Neql( OBJ_FROM_BYT6( a[0], a[1], a[2], a[3], a[4], a[5]      ), b );
    case 5:	return obj_Neql( OBJ_FROM_BYT5( a[0], a[1], a[2], a[3], a[4]            ), b );
    case 4:	return obj_Neql( OBJ_FROM_BYT4( a[0], a[1], a[2], a[3]                  ), b );
    #endif
    case 3:	return obj_Neql( OBJ_FROM_BYT3( a[0], a[1], a[2]                        ), b );
    case 2:	return obj_Neql( OBJ_FROM_BYT2( a[0], a[1]                              ), b );
    case 1:	return obj_Neql( OBJ_FROM_BYT1( a[0]                                    ), b );
    case 0:	return obj_Neql( OBJ_FROM_BYT0                                           , b );
    }
    return obj_strNeql(a,b);
}

/************************************************************************/
/*-    obj_StrCmp -- Compare two strings, given lengths.		*/
/************************************************************************/

Vm_Int
obj_StrCmp(
    Vm_Uch* p_a, Vm_Int a_len,
    Vm_Uch* p_b, Vm_Int b_len
) {
    /* Most time-critical variables first: */
    register Vm_Sch  a;
    register Vm_Sch  b;
    register Vm_Sch* pa = (Vm_Sch*)p_a-1;
    register Vm_Sch* pb = (Vm_Sch*)p_b-1;
    register Vm_Int  i;
    if (a_len < b_len) {
	for (i = a_len+1;   --i;   ) { a = *++pa; b = *++pb;  if (a != b)  return a - b; }
	return -*++pb;
    } else {
	for (i = b_len+1;   --i;   ) { a = *++pa; b = *++pb;  if (a != b)  return a - b; }
	return a_len > b_len ? *++pa : 0;
    }
}

/************************************************************************/
/*-    obj_Alloc_In_Dbfile -- Allocate a new object in given dbfile.   	*/
/************************************************************************/

Vm_Obj
obj_Alloc_In_Dbfile(
    Vm_Unt obj_type,
    Vm_Unt obj_size,
    Vm_Unt dbfile
) {
    #if MUQ_IS_PARANOID
    if (obj_type >= OBJ_CLASS_MAX)   MUQ_FATAL ("obj_Alloc: internal err");
    #endif


    /* Allocate and initialize object of appropriate size: */
    {   Vm_Int bytesize = (*mod_Hardcoded_Class[ obj_type ]->sizeof_obj)( obj_size );
	job_RunState.bytes_owned   += bytesize;
	job_RunState.objects_owned += 1;
        return obj_Init(
	    vm_Malloc( bytesize, dbfile, OBJ_K_OBJ ),
	    obj_type,
	    bytesize,
	    obj_size
	);
    }
}

/************************************************************************/
/*-    obj_Alloc -- Allocate a new object.			       	*/
/************************************************************************/

Vm_Obj
obj_Alloc(
    Vm_Unt obj_type,
    Vm_Unt obj_size
) {
    Vm_Obj pkg      = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    Vm_Unt dbfile   = VM_DBFILE(pkg);

    return obj_Alloc_In_Dbfile(
        obj_type,
        obj_size,
        dbfile
    );
}

/************************************************************************/
/*-    obj_Dup_In_Dbfile -- Return copy of 'obj' in given dbfile.   	*/
/************************************************************************/

Vm_Obj
obj_Dup_In_Dbfile(
    Vm_Obj old,
    Vm_Unt dbfile
) {
    Vm_Int len = vm_Len( old );
    Vm_Obj new = vm_SizedDup( old, len, dbfile );
    if (len) {
	jS.bytes_owned    += len;
    }

/* buggo: virtual slots, in particular propdirs, may need copying...? */

    return new;
}

/************************************************************************/
/*-    obj_Dup -- Return exact copy of 'obj'.			       	*/
/************************************************************************/

Vm_Obj
obj_Dup(
    Vm_Obj old
) {
    /* Buggo? Are we ever leaking private data */
    /* from original to copying user here?     */
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    return obj_Dup_In_Dbfile( old, VM_DBFILE(pkg) );
}

/************************************************************************/
/*-    obj_SizedDup -- Return resized copy of 'obj'.		       	*/
/************************************************************************/

Vm_Obj
obj_SizedDup(
    Vm_Obj old,
    Vm_Unt len
) {
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    /* Buggo? Are we leaking private data from original */
    /* to copying user here? */
    Vm_Obj new = vm_SizedDup( old, len, VM_DBFILE(pkg) );
    if (len) {
	jS.bytes_owned    += len;
    }
    return new;
}

/************************************************************************/
/*-    obj_Free -- Recycle an obj instance.			       	*/
/************************************************************************/

void
obj_Free (
    Vm_Obj job
) {
#ifdef SOON
buggo
    vm_Free(  job );
#endif
}

/************************************************************************/
/*-    obj_Init -- Initializes a new object.				*/
/************************************************************************/

Vm_Obj
obj_Init(
    Vm_Obj o,
    Vm_Unt obj_type,	/* OBJ_CLASS_A_ROT or such.	*/
    Vm_Int bytesize,
    Vm_Unt obj_size
) {
    /* Do generic object initialization: */

    {   Vm_Obj flags = (obj_type << OBJ_CLASS_SHIFT) & OBJ_CLASS_MASK;

	{   Obj_P  p = OBJ_P(o);

	    /* Do one last hack on our randombits, just to keep    */
	    /* consecutively created objects from having identical */
	    /* net1 and net2 fields.  It would be nice to have a   */
	    /* really high-quality source of random bits here --   */
	    /* Intel should really put something onchip sometime:  */
	    MUQ_NOTE_RANDOM_BITS( *(Vm_Int*)&jS.pc );
	    MUQ_NOTE_RANDOM_BITS( *(Vm_Int*)&jS.s  );

	    job_RunState.bytes_owned += bytesize;
	    p->flagwrd	= flags;
	    p->objname	= OBJ_FROM_BYT1('_');
	    p->is_a	= mod_Hardcoded_Class[ obj_type ]->builtin_class;

	    /******************************************/
	    /* Zero all bytes in object after generic */
	    /* object header.  This is a good idea in */
	    /* general for simplifying debugging, and */
	    /* in particular sets all remaining slots */
	    /* to OBJ_FROM_INT(0), which keeps the    */
	    /* garbage collector from crashing if one */
	    /* of our classes doesn't initialize a    */
	    /* slot:                                  */
	    /******************************************/
	    if (bytesize > (Vm_Int)sizeof(Obj_A_Header) ) {
		bzero(
		    &((Vm_Uch*)p)[ sizeof(Obj_A_Header) ],
		    bytesize - sizeof(Obj_A_Header)
		);
	    }

	    /* Include code to initialize fields for optional modules: */
	    #define  MODULES_OBJ_C_OBJ_INIT
	    #include "Modules.h"
	    #undef   MODULES_OBJ_C_OBJ_INIT

	    vm_Dirty(o);
    }	}


    /* Do any class-specific initialization: */
    (*mod_Hardcoded_Class[ obj_type ]->for_new)( o, obj_size );

    return o;
}

/************************************************************************/
/*-    obj_Get_Mos_Key -- Return class object				*/
/************************************************************************/

Vm_Obj
obj_Get_Mos_Key(
    Vm_Obj obj
) {
    Vm_Obj cdf = OBJ_P(obj)->is_a;
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(cdf) || !OBJ_IS_CLASS_CDF(cdf)) {
	MUQ_WARN("obj_Get_Mos_Key: cdf isn't a");
    }
    #endif
    return CDF_P(cdf)->key;
}

/************************************************************************/
/*-    obj_Name -- Blank-precede name of object, else empty str.	*/
/************************************************************************/

Vm_Uch*
obj_Name(
    Vm_Uch* buf,
    Vm_Int  len,
    Vm_Obj  obj
) {
    if (OBJ_IS_THUNK(obj)
    ||  OBJ_IS_CFN(  obj)
    ){
        obj = CFN_P(obj)->src;
    }
    buf[0] = '\0';
    if (OBJ_IS_OBJ(obj)) {
	Vm_Obj nm;
	nm = OBJ_P(obj)->objname;
	if (stg_Is_Stg(nm)) {
	    Vm_Int  i = stg_Get_Bytes( buf+1, len-2, nm, 0 );
	    if     (i) {
		buf[i+1] = '\0';
	        buf[ 0 ] =  ' ';
    }	}   }
    return buf;
}

/************************************************************************/
/*-    obj_Del -- Remove 'key'[-val pair] from obj.		       	*/
/************************************************************************/

void
obj_Del(
    Vm_Obj obj,
    Vm_Obj key
) {
    obj_X_Del( obj, key, OBJ_PROP_PUBLIC );
}

/************************************************************************/
/*-    obj_First -- Get first key in obj else OBJ_NOT_FOUND.	   	*/
/************************************************************************/

Vm_Obj
obj_First(
    Vm_Obj obj
) {
    return obj_X_First( obj, OBJ_PROP_PUBLIC );
}

/************************************************************************/
/*-    obj_Get -- Get value for given 'key'.			       	*/
/************************************************************************/

Vm_Obj
obj_Get(
    Vm_Obj  obj,
    Vm_Obj  key
) {
    return obj_X_Get( obj, key, OBJ_PROP_PUBLIC );
}

/************************************************************************/
/*-    obj_Get_Asciz -- Get value for given 'key'.		       	*/
/************************************************************************/

Vm_Obj
obj_Get_Asciz(
    Vm_Obj  obj,
    Vm_Uch* key
) {
    return obj_X_Get_Asciz( obj, key, OBJ_PROP_PUBLIC );
}

/************************************************************************/
/*-    obj_Next -- Return next key in obj else OBJ_NOT_FOUND.      	*/
/************************************************************************/

Vm_Obj
obj_Next(
    Vm_Obj obj,
    Vm_Obj key
) {
    return obj_X_Next( obj, key, OBJ_PROP_PUBLIC );
}

/************************************************************************/
/*-    obj_Set -- Set 'key' to 'val' in 'obj'.				*/
/************************************************************************/

void
obj_Set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val
) {
    obj_X_Set( obj, key, val, OBJ_PROP_PUBLIC );
}


/************************************************************************/
/*-    obj_Hidden_Del -- Remove 'key'[-val pair] from obj.		*/
/************************************************************************/

void
obj_Hidden_Del(
    Vm_Obj obj,
    Vm_Obj key
) {
    obj_X_Del( obj, key, OBJ_PROP_HIDDEN );
}

/************************************************************************/
/*-    obj_Hidden_First -- Get first key in obj else OBJ_NOT_FOUND.	*/
/************************************************************************/

Vm_Obj
obj_Hidden_First (
    Vm_Obj obj
) {
    return obj_X_First( obj, OBJ_PROP_HIDDEN );
}

/************************************************************************/
/*-    obj_Hidden_Get -- Get value for given 'key'.			*/
/************************************************************************/

Vm_Obj
obj_Hidden_Get(
    Vm_Obj  obj,
    Vm_Obj  key
) {
    return obj_X_Get( obj, key, OBJ_PROP_HIDDEN );
}

/************************************************************************/
/*-    obj_Hidden_Get_Asciz -- Get value for given 'key'.		*/
/************************************************************************/

Vm_Obj
obj_Hidden_Get_Asciz (
    Vm_Obj  obj,
    Vm_Uch* key
) {
    return obj_X_Get_Asciz( obj, key, OBJ_PROP_HIDDEN );
}

/************************************************************************/
/*-    obj_Hidden_Next -- Return next key in obj else OBJ_NOT_FOUND.   */
/************************************************************************/

Vm_Obj
obj_Hidden_Next(
    Vm_Obj obj,
    Vm_Obj key
) {
    return obj_X_Next( obj, key, OBJ_PROP_HIDDEN );
}

/************************************************************************/
/*-    obj_Hidden_Set -- Set 'key' to 'val' in 'obj'.			*/
/************************************************************************/

void
obj_Hidden_Set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val
) {
    obj_X_Set( obj, key, val, OBJ_PROP_HIDDEN );
}


/************************************************************************/
/*-    obj_System_Del -- Remove 'key'[-val pair] from obj.		*/
/************************************************************************/

void
obj_System_Del(
    Vm_Obj obj,
    Vm_Obj key
) {
    obj_X_Del( obj, key, OBJ_PROP_SYSTEM );
}

/************************************************************************/
/*-    obj_System_First -- Get first key in obj else OBJ_NOT_FOUND.	*/
/************************************************************************/

Vm_Obj
obj_System_First (
    Vm_Obj obj
) {
    return obj_X_First( obj, OBJ_PROP_SYSTEM );
}

/************************************************************************/
/*-    obj_System_Get -- Get value for given 'key'.			*/
/************************************************************************/

Vm_Obj
obj_System_Get (
    Vm_Obj  obj,
    Vm_Obj  key
) {
    return obj_X_Get( obj, key, OBJ_PROP_SYSTEM );
}

/************************************************************************/
/*-    obj_System_Get_Asciz -- Get value for given 'key'.		*/
/************************************************************************/

Vm_Obj
obj_System_Get_Asciz (
    Vm_Obj  obj,
    Vm_Uch* key
) {
    return obj_X_Get_Asciz( obj, key, OBJ_PROP_SYSTEM );
}

/************************************************************************/
/*-    obj_System_Next -- Return next key in obj else OBJ_NOT_FOUND.   */
/************************************************************************/

Vm_Obj
obj_System_Next(
    Vm_Obj obj,
    Vm_Obj key
) {
    return obj_X_Next( obj, key, OBJ_PROP_SYSTEM );
}

/************************************************************************/
/*-    obj_System_Set -- Set 'key' to 'val' in 'obj'.			*/
/************************************************************************/

void
obj_System_Set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val
) {
    obj_X_Set( obj, key, val, OBJ_PROP_SYSTEM );
}


/************************************************************************/
/*-    obj_Admins_Del -- Remove 'key'[-val pair] from obj.		*/
/************************************************************************/

void
obj_Admins_Del(
    Vm_Obj obj,
    Vm_Obj key
) {
    obj_X_Del( obj, key, OBJ_PROP_ADMINS );
}

/************************************************************************/
/*-    obj_Admins_First -- Get first key in obj else OBJ_NOT_FOUND.	*/
/************************************************************************/

Vm_Obj
obj_Admins_First(
    Vm_Obj obj
) {
    return obj_X_First( obj, OBJ_PROP_ADMINS );
}

/************************************************************************/
/*-    obj_Admins_Get -- Get value for given 'key'.			*/
/************************************************************************/

Vm_Obj
obj_Admins_Get(
    Vm_Obj  obj,
    Vm_Obj  key
) {
    return obj_X_Get( obj, key, OBJ_PROP_ADMINS );
}

/************************************************************************/
/*-    obj_Admins_Get_Asciz -- Get value for given 'key'.		*/
/************************************************************************/

Vm_Obj
obj_Admins_Get_Asciz(
    Vm_Obj  obj,
    Vm_Uch* key
) {
    return obj_X_Get_Asciz( obj, key, OBJ_PROP_ADMINS );
}

/************************************************************************/
/*-    obj_Admins_Next -- Return next key in obj else OBJ_NOT_FOUND.   */
/************************************************************************/

Vm_Obj
obj_Admins_Next(
    Vm_Obj obj,
    Vm_Obj key
) {
    return obj_X_Next( obj, key, OBJ_PROP_ADMINS );
}

/************************************************************************/
/*-    obj_Admins_Set -- Set 'key' to 'val' in 'obj'.			*/
/************************************************************************/

void
obj_Admins_Set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val
) {
    obj_X_Set( obj, key, val, OBJ_PROP_ADMINS );
}


/************************************************************************/
/*-    obj_X_First -- Get first key in obj else OBJ_NOT_FOUND.	   	*/
/************************************************************************/

Vm_Obj
obj_X_First(
    Vm_Obj obj,
    Vm_Int propdir
) {
    Vm_Int c = OBJ_CLASS(obj);

    /* See if there are special hardwired  */
    /* properties for this propdir on this */
    /* this class of object:               */
    if (mod_Hardcoded_Class[c]->propdir[propdir] == NULL) {

        /*****************************************/
	/* No hardwired properties, just go with */
	/* whatever we actually find on the obj: */
        /*****************************************/

        /* Find first regular prop on object: */
        Vm_Unt dbfile = VM_DBFILE(obj);
	Vm_Obj dbf    = vm_Root(dbfile);
	Vm_Obj pil    = DBF_P(dbf)->propdir_pil[propdir];
	Vm_Obj dir    = pil_Get( pil, obj );

	return   job_Btree_First( dir );
    }

    {   /*************************************************/
	/* We have hardwired properties, need to return  */
        /* lesser of the next hardwired property and the */
	/* next normal property, where either or both    */
        /* may be absent:                                */
        /*************************************************/
        Vm_Unt dbfile = VM_DBFILE(obj);
	Vm_Obj dbf    = vm_Root(dbfile);
	Vm_Obj pil    = DBF_P(dbf)->propdir_pil[propdir];
	Vm_Obj dir    = pil_Get( pil, obj );

        Vm_Obj regularkey = job_Btree_First( dir );
        Vm_Obj specialkey = mod_Hardcoded_Class[c]->propdir[propdir][0].keyword;
    
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
}

/************************************************************************/
/*-    obj_X_Del -- Delete value for given 'key'.		       	*/
/************************************************************************/

Vm_Obj
obj_X_Del(
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
    
        Vm_Unt dbfile = VM_DBFILE(obj);
	Vm_Obj dbf    = vm_Root(dbfile);
	Vm_Obj pil    = DBF_P(dbf)->propdir_pil[propdir];
	Vm_Obj olddir = pil_Get( pil, obj );

	v          = job_Btree_Get( olddir, key );
	if (v != OBJ_NOT_FOUND) {
	    Vm_Obj newdir = job_Btree_Del( olddir, key );
	    if (newdir != olddir) {

	        Vm_Obj pil2   = pil_Set( pil, obj, newdir, dbfile );
		if (pil != pil2) {
		    DBF_P(dbf)->propdir_pil[propdir] = pil2;
		    vm_Dirty(dbf);
		}
	    }
	}
        return v;
    }

    /* Decidedly do not search our */
    /* parents and delete in them. */
}

/************************************************************************/
/*-    obj_X_Get -- Get value for given 'key'.			       	*/
/************************************************************************/



Vm_Obj
obj_X_Get(
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
        Vm_Unt dbfile = VM_DBFILE(obj);
	Vm_Obj dbf    = vm_Root(dbfile);
	Vm_Obj pil    = DBF_P(dbf)->propdir_pil[propdir];
	Vm_Obj dir    = pil_Get( pil, obj );

        Vm_Obj v      = job_Btree_Get( dir, key );

	if (v != OBJ_NOT_FOUND) {
	    return v;
	}
    }

    /* Failed to find value for key: */
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    obj_X_Get_Asciz -- Get value for given 'key'.		       	*/
/************************************************************************/

Vm_Obj
obj_X_Get_Asciz(
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
    /* so obj_X_Get_Asciz inherently doesn't have */
    /* to worry about hardwired properties.       */

    /* If key is in propdir, return that value: */
    {   Vm_Unt dbfile = VM_DBFILE(obj);
	Vm_Obj dbf    = vm_Root(dbfile);
	Vm_Obj pil    = DBF_P(dbf)->propdir_pil[propdir];
	Vm_Obj dir    = pil_Get( pil, obj );

        Vm_Obj v      = job_Btree_Get_Asciz(dir,key);

#ifdef VERBOSE
if (STRCMP(key, == ,"function")) sil_PrintNode( dir, 0);
#endif
	if    (v != OBJ_NOT_FOUND)   return v;
    }

    /* Failed to find value for key: */
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    obj_X_Next -- Return next key in obj else OBJ_NOT_FOUND.      	*/
/************************************************************************/

Vm_Obj
obj_X_Next(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Obj specialkey = 0;
    Vm_Obj regularkey = key;
    Vm_Int keytype    = OBJ_TYPE(key);
    Vm_Int c          = OBJ_CLASS(obj);

    /* Find next regular prop after 'key': */
    Vm_Unt dbfile = VM_DBFILE(obj);
    Vm_Obj dbf    = vm_Root(dbfile);
    Vm_Obj pil    = DBF_P(dbf)->propdir_pil[propdir];
    Vm_Obj dir    = pil_Get( pil, obj );

    regularkey        = job_Btree_Next( dir, regularkey );

    /* See if there are special hardwired  */
    /* properties for this propdir on this */
    /* this class of object:               */

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
       	    }
       	}
    }


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
/*-    obj_X_Set -- Set 'key' to 'val' in 'obj'.			*/
/************************************************************************/

Vm_Uch*
obj_X_Set(
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
        Vm_Unt dbfile = VM_DBFILE(obj);
	Vm_Obj dbf    = vm_Root(dbfile);
	Vm_Obj pil    = DBF_P(dbf)->propdir_pil[propdir];
	Vm_Obj olddir = pil_Get( pil, obj );

	Vm_Obj newdir = job_Btree_Set( olddir, key, val, VM_DBFILE(obj) );
        if (   newdir != olddir) {
	    Vm_Obj pil2   = pil_Set( pil, obj, newdir, dbfile );
	    if (pil != pil2) {
		DBF_P(dbf)->propdir_pil[propdir] = pil2;
		vm_Dirty(dbf);
	    }
        }
    }

    /* Buggo... should do this at actual change point: */
    vm_Dirty(obj);
    return NULL;
}


/************************************************************************/
/*-    obj_False_Fn -- Return 0x0.				       	*/
/************************************************************************/

Vm_Obj
obj_False_Fn(
    void
) {

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    obj_True_Fn -- Return OBJ_FROM_INT( 0x1 ).		       	*/
/************************************************************************/

Vm_Obj
obj_True_Fn(
    void
) {

    return (Vm_Obj) OBJ_FROM_INT( 0x1 );
}


/************************************************************************/
/*-    obj_Owner -- Locate owner of object.				*/
/************************************************************************/

Vm_Obj
obj_Owner(
    Vm_Obj obj
) {
    Vm_Unt dbfile = VM_DBFILE(obj);
    Vm_Obj dbf    = vm_Root(dbfile);
    Vm_Obj owner  = DBF_P(dbf)->owner;
    return owner;
}


/************************************************************************/
/*-    obj_Myclass          						*/
/************************************************************************/

/* buggo? Does this property have a reason to exist? */
/* If so, should it be renamed? */
Vm_Obj
obj_Myclass(
    Vm_Obj o
) {
    return mod_Hardcoded_Class[ OBJ_CLASS(o) ]->name;
}

/************************************************************************/
/*-    obj_Objname          						*/
/************************************************************************/

Vm_Obj
obj_Objname(
    Vm_Obj o
) {
    return OBJ_P(o)->objname;
}

/************************************************************************/
/*-    obj_Is_A          						*/
/************************************************************************/

Vm_Obj
obj_Is_A(
    Vm_Obj o
) {
    return OBJ_P(o)->is_a;
}

/************************************************************************/
/*-    obj_Dbname	       						*/
/************************************************************************/

Vm_Obj
obj_Dbname(
    Vm_Obj o
) {
    return stg_From_Asciz( vm_DbId_To_Asciz( VM_DBFILE(o) ) );
}

/************************************************************************/
/*-    obj_Set_Myclass        						*/
/************************************************************************/

Vm_Obj
obj_Set_Myclass(
    Vm_Obj o,
    Vm_Obj v
) {
    /* Doesn't seem safe to allow setting this. */
/*    OBJ_CLASS_SET(o,v); */
/*    vm_Dirty(o);*/
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    obj_Set_Objname        						*/
/************************************************************************/

Vm_Obj
obj_Set_Objname(
    Vm_Obj o,
    Vm_Obj v
) {
    OBJ_P(o)->objname = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    obj_Set_Is_A        						*/
/************************************************************************/

Vm_Obj
obj_Set_Is_A(
    Vm_Obj o,
    Vm_Obj v
) {
/*  OBJ_P(o)->is_a = v; */
/*  vm_Dirty(o);	*/
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    obj_Set_Never        						*/
/************************************************************************/

Vm_Obj
obj_Set_Never(
    Vm_Obj o,
    Vm_Obj v
) {
    MUQ_WARN ("You may not modify that struct slot");
/*  OBJ_P(o)->is_a = v; */
/*  vm_Dirty(o);	*/
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    obj_Bad_Hash        						*/
/************************************************************************/

Vm_Obj
obj_Bad_Hash(
    Vm_Obj o
) {
    MUQ_WARN("Hash not implemented for obj %" VM_X,o);
    return OBJ_FROM_INT(0);
}

/************************************************************************/
/*-    obj_Hash_Immediate      						*/
/************************************************************************/

Vm_Obj
obj_Hash_Immediate(
    Vm_Obj o
) {
    return o & ((~((Vm_Unt)0))<<OBJ_INT_SHIFT);
}

/************************************************************************/
/*-    obj_Dummy_Reverse      						*/
/************************************************************************/

Vm_Obj
obj_Dummy_Reverse(
    Vm_Obj o
) {
    MUQ_FATAL("obj_Dummy_Reverse called");
    return OBJ_NIL;  /* Just to quiet compilers. */
}


/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- dummy for_new fn.					*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* nothing to do */
}

/************************************************************************/
/*-    initialize_obj_pointer_type -- fill in array			*/
/************************************************************************/

static void
initialize_obj_pointer_type(
    void
) {

    Vm_Int i;
    for   (i = (1 << OBJ_MAX_SHIFT);   i --> 0;  ) {

	Vm_Int t = 0;

        if      (OBJ_IS_FLOAT(           i))	t = OBJ_TYPE_FLOAT           ;
        else if (OBJ_IS_INT(             i))	t = OBJ_TYPE_INT             ;
        else if (OBJ_IS_BIGNUM(		 i))	t = OBJ_TYPE_BIGNUM	     ;
        else if (OBJ_IS_BOTTOM(          i))	t = OBJ_TYPE_BOTTOM          ;
        else if (OBJ_IS_THUNK(           i))	t = OBJ_TYPE_THUNK           ;
        else if (OBJ_IS_CFN(             i))	t = OBJ_TYPE_CFN             ;
        else if (OBJ_IS_OBJ(             i))	t = OBJ_TYPE_OBJ             ;
        else if (OBJ_IS_CONS(            i))	t = OBJ_TYPE_CONS            ;
        else if (OBJ_IS_VEC(             i))	t = OBJ_TYPE_VEC             ;
        else if (OBJ_IS_BYTN(            i))	t = OBJ_TYPE_BYTN            ;
        else if (OBJ_IS_BYT0(            i))	t = OBJ_TYPE_BYT0            ;
        else if (OBJ_IS_BYT1(            i))	t = OBJ_TYPE_BYT1            ;
        else if (OBJ_IS_BYT2(            i))	t = OBJ_TYPE_BYT2            ;
        else if (OBJ_IS_BYT3(            i))	t = OBJ_TYPE_BYT3            ;
        #if VM_INTBYTES > 4
        else if (OBJ_IS_BYT4(            i))	t = OBJ_TYPE_BYT4            ;
        else if (OBJ_IS_BYT5(            i))	t = OBJ_TYPE_BYT5            ;
        else if (OBJ_IS_BYT6(            i))	t = OBJ_TYPE_BYT6            ;
        else if (OBJ_IS_BYT7(            i))	t = OBJ_TYPE_BYT7            ;
        #endif
        else if (OBJ_IS_SPECIAL(         i))	t = OBJ_TYPE_SPECIAL         ;
        else if (OBJ_IS_CHAR(            i))	t = OBJ_TYPE_CHAR            ;
        else if (OBJ_IS_SYMBOL(          i))	t = OBJ_TYPE_SYMBOL          ;
        else if (OBJ_IS_BLK(             i))	t = OBJ_TYPE_BLK             ;
        else if (OBJ_IS_STRUCT(          i))	t = OBJ_TYPE_STRUCT          ;
        else if (OBJ_IS_EPHEMERAL_LIST(  i))	t = OBJ_TYPE_EPHEMERAL_LIST  ;
        else if (OBJ_IS_EPHEMERAL_STRUCT(i))	t = OBJ_TYPE_EPHEMERAL_STRUCT;
        else if (OBJ_IS_EPHEMERAL_VECTOR(i))	t = OBJ_TYPE_EPHEMERAL_VECTOR;
        else if (OBJ_IS_I01(		 i))	t = OBJ_TYPE_I01             ;
        else if (OBJ_IS_I16(		 i))	t = OBJ_TYPE_I16             ;
        else if (OBJ_IS_I32(		 i))	t = OBJ_TYPE_I32             ;
        else if (OBJ_IS_F32(		 i))	t = OBJ_TYPE_F32             ;
        else if (OBJ_IS_F64(		 i))	t = OBJ_TYPE_F64             ;

	obj_Pointer_Type[ i ] = t;
    }
}

/************************************************************************/
/*-    initialize_obj_immediate -- fill in array			*/
/************************************************************************/

static void
initialize_obj_immediate(
    void
) {
    /*************************************************/
    /* This function sets up the table which decides */
    /* which cases we can order quickly via a fixnum */
    /* subtract.                                     */
    /*						     */
    /* BYTNs of course usually have to be compared   */
    /* byte by byte for string ordering.             */
    /*						     */
    /* OBJs cannot be blindly compared as fixnums    */
    /* because PROXY objects must be ordered by      */
    /* contents.                                     */
    /*						     */
    /* Naturally, floats must be ordered as floats,  */
    /* not ints, and bignums must be ordered by      */
    /* contents, not address:                        */
    /*						     */
    /*************************************************/

    Vm_Int i;
    for   (i = (1 << OBJ_MAX_SHIFT);   i --> 0;  ) {

	Vm_Uch t = 0;

        if      (OBJ_IS_INT(             i))	t = 1;
        else if (OBJ_IS_BOTTOM(          i))	t = 1;
        else if (OBJ_IS_THUNK(           i))	t = 1;
        else if (OBJ_IS_CFN(             i))	t = 1;
        else if (OBJ_IS_CONS(            i))	t = 1;
        else if (OBJ_IS_VEC(             i))	t = 1;
        else if (OBJ_IS_BYT0(            i))	t = 1;
        else if (OBJ_IS_BYT1(            i))	t = 1;
        else if (OBJ_IS_BYT2(            i))	t = 1;
        else if (OBJ_IS_BYT3(            i))	t = 1;
        #if VM_INTBYTES > 4
        else if (OBJ_IS_BYT4(            i))	t = 1;
        else if (OBJ_IS_BYT5(            i))	t = 1;
        else if (OBJ_IS_BYT6(            i))	t = 1;
        else if (OBJ_IS_BYT7(            i))	t = 1;
        #endif
        else if (OBJ_IS_SPECIAL(         i))	t = 1;
        else if (OBJ_IS_CHAR(            i))	t = 1;
        else if (OBJ_IS_SYMBOL(          i))	t = 1;
        else if (OBJ_IS_BLK(             i))	t = 1;
        else if (OBJ_IS_STRUCT(          i))	t = 1;
        else if (OBJ_IS_EPHEMERAL_LIST(  i))	t = 1;
        else if (OBJ_IS_EPHEMERAL_STRUCT(i))	t = 1;
        else if (OBJ_IS_EPHEMERAL_VECTOR(i))	t = 1;
        else if (OBJ_IS_I16(		 i))	t = 1;
        else if (OBJ_IS_I32(		 i))	t = 1;
        else if (OBJ_IS_F32(		 i))	t = 1;
        else if (OBJ_IS_F64(		 i))	t = 1;

	obj_Immediate[ i ] = t;
    }
}

/************************************************************************/
/*-    sizeof_obj -- Return size of generic object.			*/
/************************************************************************/

static Vm_Unt
sizeof_obj(
    Vm_Unt size
) {
    return sizeof( Obj_A_Header );
}

/************************************************************************/
/*-    obj_Type_Get_Mos_Key -- Return class object			*/
/************************************************************************/
Vm_Obj
obj_Type_Get_Mos_Key(
    Vm_Obj obj
) {
    Vm_Obj cdf = mod_Type_Summary[ OBJ_TYPE(obj) ]->builtin_class;
    if (!OBJ_IS_OBJ(cdf) || !OBJ_IS_CLASS_CDF(cdf)) {
	if (OBJ_IS_OBJ(cdf) && OBJ_IS_CLASS_KEY(cdf))   return cdf;
	MUQ_WARN("obj_Type_Get_Mos_Key internal err");
    }
    return CDF_P(cdf)->key;
}
/************************************************************************/
/*-    typ_get_mos_key -- Return class object				*/
/************************************************************************/
static Vm_Obj
typ_get_mos_key(
    Vm_Obj obj
) {
    return mod_Hardcoded_Class[OBJ_CLASS(obj)]->get_mos_key( obj );
}
/************************************************************************/
/*-    bad_get_mos_key -- Return class object				*/
/************************************************************************/
static Vm_Obj
bad_get_mos_key(
    Vm_Obj obj
) {
MUQ_WARN("bad/get_mos_key unimplemented");
    return OBJ_NIL;
}




#ifdef UNUSED

/************************************************************************/
/*-    get_system_prop -- Get value for given 'key' else OBJ_NOT_FOUND.*/
/************************************************************************/

static Vm_Obj
get_system_prop(
    Vm_Obj  obj,
    Vm_Obj  key
) {
    /* Maybe return special-prop value: */
    Vm_Int c = OBJ_CLASS(obj);
    Vm_Int i;
    for   (i = 0;  mod_Hardcoded_Class[c]->system_property[i].name;  ++i) {
	Obj_Special_Property p;
	p = &mod_Hardcoded_Class[c]->system_property[i];
	if (p->keyword == key) {
	    Vm_Obj v = p->for_get( obj );
	    if (v != OBJ_NOT_FOUND) {
		return v;
	    }
	    break;
    }   }
    return OBJ_NOT_FOUND;
}


#endif
#ifdef UNUSED

/************************************************************************/
/*-    get_parental_prop -- Get value for given 'key'.			*/
/************************************************************************/

static Vm_Obj
get_parental_prop(
    Vm_Obj  obj,
    Vm_Obj  key
) {
    /* Search our parents: */
    Vm_Obj p = OBJ_P(obj)->parents;
    Vm_Int t = OBJ_TYPE(p);

    /* Single parent: */
    if (t == OBJ_TYPE_OBJ) {
	return OBJ_GET( p, key, OBJ_PROP_PUBLIC );
    }

    /* Multiple parents: */
    if (t == OBJ_TYPE_VEC) {
	Vm_Int len = vec_Len(p);
	Vm_Int i;
	for   (i = 0;   i < len;   ++i) {
	    Vm_Obj pp = vec_Get( p, i    );
	    Vm_Obj v  = OBJ_GET( pp, key, OBJ_PROP_PUBLIC );
	    if (v != OBJ_NOT_FOUND)   return v;
    }   }

    /* Failed to find value for key: */
    return OBJ_NOT_FOUND;
}


#endif

/************************************************************************/
/*-    obj_startup -- dummy.						*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static void   obj_startup( void ) {}
#endif

/************************************************************************/
/*-    obj_linkup -- dummy.						*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static void   obj_linkup( void ) {}
#endif

/************************************************************************/
/*-    obj_shutdown -- dummy.						*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static void   obj_shutdown( void ) {}
#endif


/************************************************************************/
/*-    obj_x_del -- Dispatch to class-specific 'delKey' fn.		*/
/************************************************************************/

static Vm_Obj
obj_x_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Int c = OBJ_CLASS(obj);
    return mod_Hardcoded_Class[c]->for_del( obj, key, propdir );
}

/************************************************************************/
/*-    obj_x_get -- Dispatch to class-specific 'get' fn.		*/
/************************************************************************/

static Vm_Obj
obj_x_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Int c = OBJ_CLASS(obj);
    return mod_Hardcoded_Class[c]->for_get( obj, key, propdir );
}

/************************************************************************/
/*-    obj_x_g_asciz -- Dispatch to class-specific 'g_asciz' fn.	*/
/************************************************************************/

static Vm_Obj
obj_x_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    Vm_Int c = OBJ_CLASS(obj);
    return mod_Hardcoded_Class[c]->g_asciz( obj, key, propdir );
}

/************************************************************************/
/*-    obj_x_set -- Dispatch to class-specific 'set' fn.		*/
/************************************************************************/

static Vm_Uch*
obj_x_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    Vm_Int c = OBJ_CLASS(obj);
    return mod_Hardcoded_Class[c]->for_set( obj, key, val, propdir );
}

/************************************************************************/
/*-    obj_x_next -- Dispatch to class-specific 'next' fn.		*/
/************************************************************************/

static Vm_Obj
obj_x_next(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Int c = OBJ_CLASS(obj);
    return mod_Hardcoded_Class[c]->for_nxt( obj, key, propdir );
}

/************************************************************************/
/*-    obj_x_key -- Dispatch to class-specific 'key' fn.		*/
/************************************************************************/

static Vm_Obj
obj_x_key(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int forward,
    Vm_Int propdir
) {
    Vm_Int c = OBJ_CLASS(obj);
    return mod_Hardcoded_Class[c]->for_key( obj, key, val, forward, propdir );
}

/************************************************************************/
/*-    obj_reverse -- Dispatch to class-specific 'reverse' fn.		*/
/************************************************************************/

static Vm_Obj
obj_reverse(
    Vm_Obj obj
) {
    Vm_Int c = OBJ_CLASS_REVERSE(obj);
/*printf("obj_reverse: obj x=%llx c x=%llx\n",obj,c);*/
    return mod_Hardcoded_Class[c]->reverse( obj );
}

/************************************************************************/
/*-    obj_type_obj_sprintX						*/
/************************************************************************/

static Vm_Uch*
obj_type_obj_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  quote
) {
    Vm_Uch tmp[30];
    return lib_Sprint(
	buf,lim,
        #ifdef MUQ_VERBOSE
	  "#<%s %" VM_X ">",
	  mod_Hardcoded_Class[ OBJ_CLASS(obj) ]->fullname,
	  obj
	#else
#ifdef PRODUCTION
	  "#<%s%s>",
	  mod_Hardcoded_Class[ OBJ_CLASS(obj) ]->fullname,
	  obj_Name(tmp,30,obj)
#else
	  "#<%s%s %" VM_X ">",
	  mod_Hardcoded_Class[ OBJ_CLASS(obj) ]->fullname,
	  obj_Name(tmp,30,obj),
	  obj
#endif
	#endif
    );
}

/************************************************************************/
/*-    obj_type_obj_import						*/
/************************************************************************/

static Vm_Obj
obj_type_obj_import(
    FILE* fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    MUQ_WARN ("Internal err: Attempted to import a bad type.");
    return (Vm_Obj)0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_type_obj_hash						*/
/************************************************************************/

static Vm_Obj
obj_type_obj_hash(
    Vm_Obj obj
) {
    Vm_Int obj_typ = (OBJ_P(obj)->flagwrd & OBJ_CLASS_MASK) >> OBJ_CLASS_SHIFT;
    return (*mod_Hardcoded_Class[ obj_typ ]->do_hash)( obj );
}


/************************************************************************/
/*-    obj_type_obj_export						*/
/************************************************************************/

static void
obj_type_obj_export(
    FILE*  fd,
    Vm_Obj obj,
    Vm_Int write_owners
) {
    Vm_Int obj_typ = (OBJ_P(obj)->flagwrd & OBJ_CLASS_MASK) >> OBJ_CLASS_SHIFT;
    (*mod_Hardcoded_Class[ obj_typ ]->export)( fd, obj, write_owners );
}


/************************************************************************/
/*-    obj_type_bad_sprintX						*/
/************************************************************************/

static Vm_Uch*
obj_type_bad_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj obj,
    Vm_Int quote
) {
    MUQ_WARN ("Internal err: Attempted to sprint bad type.");
    return (Vm_Obj)0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_type_bad_for_del						*/
/************************************************************************/

static Vm_Obj
obj_type_bad_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    MUQ_WARN ("Internal err: Attempted to delKey from bad type.");
    return (Vm_Obj)0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_type_bad_for_get						*/
/************************************************************************/

static Vm_Obj
obj_type_bad_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    MUQ_WARN ("Internal err: Attempted to get-prop from bad type.");
    return (Vm_Obj)0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_type_bad_g_asciz						*/
/************************************************************************/

static Vm_Obj
obj_type_bad_g_asciz(
    Vm_Obj obj,
    Vm_Uch*key,
    Vm_Int propdir
) {
    MUQ_WARN ("Internal err: Attempted to get-asciz-prop from bad type.");
    return (Vm_Obj)0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_type_bad_for_set						*/
/************************************************************************/

static Vm_Uch*
obj_type_bad_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    return   "Internal err: Attempted to set-prop on bad type.";
}

/************************************************************************/
/*-    obj_type_bad_for_nxt						*/
/************************************************************************/

static Vm_Obj
obj_type_bad_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    MUQ_WARN ("Internal err: Attempted to get-next-prop from bad type.");
    return (Vm_Obj)0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_type_bad_import						*/
/************************************************************************/

static Vm_Obj
obj_type_bad_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    MUQ_WARN ("Internal err: Attempted to import a bad type.");
    return (Vm_Obj)0; /* Pacify gcc. */
}

/************************************************************************/
/*-    obj_type_bad_export						*/
/************************************************************************/

static void
obj_type_bad_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int i
) {
    MUQ_WARN ("Internal err: Attempted to export a bad type.");
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
