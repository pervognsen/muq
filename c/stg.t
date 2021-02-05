@example  @c
/*--   stg.c -- Byte sequences.						*/
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
/* Created:      93Jan12						*/
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
/*                                                                     	*/
/*  	    	    	    	     	     	      	      	       	*/
/*  	    	    	    	     	     	      	      	       	*/
/*                                                                     	*/
/************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Max size string to create: */
#define STG_MAX (0x10000)



/************************************************************************/
/*-    types                                                            */
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static Vm_Uch* stg_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj  stg_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  stg_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  stg_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch* stg_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj  stg_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj  stg_hash(    Vm_Obj );
static Vm_Obj  stg_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void    stg_export(  FILE*, Vm_Obj, Vm_Int );

static Vm_Obj  get_mos_key( Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void stg_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_BYT0 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYT0");
    }
    mod_Type_Summary[ OBJ_TYPE_BYT0 ] = &stg_Type_Summary;

    if (mod_Type_Summary[ OBJ_TYPE_BYT1 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYT1");
    }
    mod_Type_Summary[ OBJ_TYPE_BYT1 ] = &stg_Type_Summary;

    if (mod_Type_Summary[ OBJ_TYPE_BYT2 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYT2");
    }
    mod_Type_Summary[ OBJ_TYPE_BYT2 ] = &stg_Type_Summary;

    if (mod_Type_Summary[ OBJ_TYPE_BYT3 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYT3");
    }
    mod_Type_Summary[ OBJ_TYPE_BYT3 ] = &stg_Type_Summary;

    #if VM_INTBYTES > 4
    if (mod_Type_Summary[ OBJ_TYPE_BYT4 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYT4");
    }
    mod_Type_Summary[ OBJ_TYPE_BYT4 ] = &stg_Type_Summary;

    if (mod_Type_Summary[ OBJ_TYPE_BYT5 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYT5");
    }
    mod_Type_Summary[ OBJ_TYPE_BYT5 ] = &stg_Type_Summary;

    if (mod_Type_Summary[ OBJ_TYPE_BYT6 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYT6");
    }
    mod_Type_Summary[ OBJ_TYPE_BYT6 ] = &stg_Type_Summary;

    if (mod_Type_Summary[ OBJ_TYPE_BYT7 ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYT7");
    }
    mod_Type_Summary[ OBJ_TYPE_BYT7 ] = &stg_Type_Summary;

    #endif

    if (mod_Type_Summary[ OBJ_TYPE_BYTN ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BYTN");
    }
    mod_Type_Summary[ OBJ_TYPE_BYTN ] = &stg_Type_Summary;
}
Obj_A_Module_Summary stg_Module_Summary = {
   "stg",
    stg_doTypes,
    stg_Startup,
    stg_Linkup,
    stg_Shutdown
};

Obj_A_Type_Summary stg_Type_Summary = {    OBJ_FROM_BYT1('t'),
    stg_sprintX,
    stg_sprintX,
    stg_sprintX,
    stg_for_del,
    stg_for_get,
    stg_g_asciz,
    stg_for_set,
    stg_for_nxt,
    obj_X_Key,
    stg_hash,
    obj_Byteswap_8bit_Obj,
    get_mos_key,
    stg_import,
    stg_export,
    "string",
    KEY_LAYOUT_STRING,
    OBJ_0
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    stg_Startup -- start-of-world stuff.				*/
/************************************************************************/

void stg_Startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

}



/************************************************************************/
/*-    stg_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void stg_Linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    stg_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void stg_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}




/************************************************************************/
/*-    stg_Sprint -- Debug dump of stg state.				*/
/************************************************************************/

Vm_Uch*
stg_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  stg
) {
    if (!stg_Is_Stg(stg))     MUQ_WARN ("stg_Sprint: needed stg!");
    {   Vm_Int len = stg_Len(stg);
	if (buf+len >= lim)   MUQ_WARN ("stg_Sprint: buffer overflow");
	if (len != stg_Get_Bytes( buf, len, stg, 0 )) {
	    MUQ_WARN ("stg_Sprint: internal err");
	}
	return buf+len;
    }
}



/************************************************************************/
/*-    stg_Concatenate -- return new string from given strings.		*/
/************************************************************************/

static Vm_Int
stg_to_buf(
    Vm_Uch* buf,
    Vm_Obj  stg
) {
    Vm_Int len = 0;
    switch (OBJ_TYPE(stg)) {
    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:	buf[6] = OBJ_BYT6(stg);	++len;	/*fallthrough*/
    case OBJ_TYPE_BYT6:	buf[5] = OBJ_BYT5(stg);	++len;	/*fallthrough*/
    case OBJ_TYPE_BYT5:	buf[4] = OBJ_BYT4(stg);	++len;	/*fallthrough*/
    case OBJ_TYPE_BYT4:	buf[3] = OBJ_BYT3(stg);	++len;	/*fallthrough*/
    #endif
    case OBJ_TYPE_BYT3:	buf[2] = OBJ_BYT2(stg);	++len;	/*fallthrough*/
    case OBJ_TYPE_BYT2:	buf[1] = OBJ_BYT1(stg);	++len;	/*fallthrough*/
    case OBJ_TYPE_BYT1:	buf[0] = OBJ_BYT0(stg);	++len;
    case OBJ_TYPE_BYT0:
        return len;
    }
    MUQ_FATAL ("stg_to_buf");
    return 0; /* Pacify gcc. */
}

static void
stg_copy(
    Vm_Obj dst,
    Vm_Obj src,
    Vm_Unt offset
) {
    switch (OBJ_TYPE(src)) {
    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:
    case OBJ_TYPE_BYT6:
    case OBJ_TYPE_BYT5:
    case OBJ_TYPE_BYT4:
    #endif
    case OBJ_TYPE_BYT3:
    case OBJ_TYPE_BYT2:
    case OBJ_TYPE_BYT1:
	{   Vm_Uch buf[ VM_INTBYTES ];
	    Vm_Int len = stg_to_buf( buf, src );
	    memcpy( &STG_P(dst)->byte[offset], buf, len );
	}
        vm_Dirty(dst);
	break;	    

    case OBJ_TYPE_BYT0:
	break;	    

    case OBJ_TYPE_BYTN:
	{   Stg_P dstloc;
	    Stg_P srcloc;
	    Vm_Int  len = stg_Len( src );
	    vm_Loc2( (void**)&dstloc, (void**)&srcloc, dst, src );
	    memcpy( &dstloc->byte[offset], &srcloc->byte[0], len );
	}
        vm_Dirty(dst);
	break;

    default:
        MUQ_FATAL ("stg_copy");
    }
}

Vm_Obj
stg_Concatenate(
    Vm_Obj stg0,
    Vm_Obj stg1
) {
    Vm_Unt len0 = stg_Len( stg0 );
    Vm_Unt len1 = stg_Len( stg1 );
    Vm_Unt len  = len0 + len1;
    if (len0 + len1 >= STG_MAX) {
        MUQ_WARN ("strcat: %d-byte string would be too long",(int)len);
    }
    if (len < VM_INTBYTES) {
        Vm_Uch buf[2*VM_INTBYTES];
	(void)stg_to_buf( buf     , stg0 );
	(void)stg_to_buf( buf+len0, stg1 );
	return stg_From_Buffer( buf, (Vm_Int)len );
    }
    {	/* Don't combine next two lines: */
	/* OBJ_FROM_BYTN double-expands. */
        Vm_Obj pkg = JOB_P(jS.job)->package;
	Vm_Int siz = (sizeof(Stg_A_Header)-VM_INTBYTES) + len;
	Vm_Obj stg = vm_Malloc( siz, VM_DBFILE(pkg), OBJ_K_BYTN );
	stg_copy( stg, stg0,    0 );
	stg_copy( stg, stg1, len0 );

        job_RunState.bytes_owned += siz;

        /* Mark strings as being read-only: */
	if (OBJ_IS_BYTN( stg ))  vm_Set_Constbit( stg );

        return stg;
    }
}



/************************************************************************/
/*-    stg_From_Asciz -- return new string from given asciz.		*/
/************************************************************************/

Vm_Obj
stg_From_Asciz(
    Vm_Uch* t
) {
    return stg_From_Buffer( t, strlen(t) );
}


/************************************************************************/
/*-    stg_From_Asciz_In_Db -- return new string from given asciz.	*/
/************************************************************************/

Vm_Obj
stg_From_Asciz_In_Db(
    Vm_Uch* t,
    Vm_Unt  dbfile
) {
    return stg_From_Buffer_In_Db( t, strlen(t), dbfile );
}



/************************************************************************/
/*-    stg_From_Buffer_In_Db -- return new string from given buffer+len	*/
/************************************************************************/

Vm_Obj
stg_From_Buffer_In_Db(
    Vm_Uch* t,
    Vm_Int  len,
    Vm_Unt  dbfile
) {
    Vm_Obj obj;
    switch (len) {
    case 0: obj = OBJ_FROM_BYT0			   ;	break;
    case 1: obj = OBJ_FROM_BYT1( t[0]		  );	break;
    case 2: obj = OBJ_FROM_BYT2( t[0], t[1]	  );	break;
    case 3: obj = OBJ_FROM_BYT3( t[0], t[1], t[2] );	break;
    #if VM_INTBYTES > 4
    case 4: obj = OBJ_FROM_BYT4( t[0],t[1],t[2],t[3]		    );	break;
    case 5: obj = OBJ_FROM_BYT5( t[0],t[1],t[2],t[3],t[4]	    );	break;
    case 6: obj = OBJ_FROM_BYT6( t[0],t[1],t[2],t[3],t[4],t[5]	    );	break;
    case 7: obj = OBJ_FROM_BYT7( t[0],t[1],t[2],t[3],t[4],t[5],t[6] );	break;
    #endif
    default:
	/* Don't combine next two lines: */
	/* OBJ_FROM_BYTN double-expands. */
	{   Vm_Int siz = (sizeof(Stg_A_Header)-VM_INTBYTES) + len;
	    obj = vm_Malloc( siz, dbfile, OBJ_K_BYTN );
	    memcpy( STG_P(obj)->byte, t, len );
            job_RunState.bytes_owned += siz;
	}
        /* Mark strings as being read-only: */
	if (OBJ_IS_BYTN( obj ))  vm_Set_Constbit( obj );
    }
    return obj;
}

/************************************************************************/
/*-    i08_Alloc -- return new byte vector from given buffer+len	*/
/************************************************************************/

Vm_Obj
i08_Alloc(
    Vm_Int  len,
    Vm_Uch  t
) {
    /* NB: i08_Alloc must return a writable vector.      */
    /* That is to say, a BYTN, not an immediate          */
    /* value like BYT3 or such, and not marked read-only */
    /* when/if we start supporting read-only strings:    */
    Vm_Int siz = (sizeof(Stg_A_Header)-VM_INTBYTES) + len;
    /* jS.job is FALSE only briefly during initial bootstrap: */
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    Vm_Obj obj = vm_Malloc( siz, VM_DBFILE(pkg), OBJ_K_BYTN );
    memset( STG_P(obj)->byte, t, len );
    job_RunState.bytes_owned += siz;

    return obj;
}

/************************************************************************/
/*-    stg_From_Buffer -- return new string from given buffer+len.	*/
/************************************************************************/

Vm_Obj
stg_From_Buffer(
    Vm_Uch* t,
    Vm_Int  len
) {
    /* jS.job is FALSE only briefly during initial bootstrap: */
    Vm_Obj pkg = jS.job ? JOB_P(jS.job)->package : OBJ_FROM_INT(0);
    return stg_From_Buffer_In_Db( t, len, VM_DBFILE(pkg) );
}

/************************************************************************/
/*-    stg_Dup_In_Db							*/
/************************************************************************/

Vm_Obj
stg_Dup_In_Db(
    Vm_Obj  stg,
    Vm_Unt  dbfile
) {
    /* Immediate values basically are native to all dbs: */
    if (OBJ_TYPE(stg) != OBJ_TYPE_BYTN)   return stg;

    {   Vm_Uch buf[ 2048 ];
	Vm_Int len = stg_Len(stg);
	if (len > 2048) MUQ_WARN("stg_Dup_In_Db: string too long");
	if (len != stg_Get_Bytes( buf, len, stg, 0 )) {
	    MUQ_WARN ("stg_Dup_In_Db: internal err");
	}
	return stg_From_Buffer_In_Db( buf, len, dbfile );
    }
}



/************************************************************************/
/*-    stg_From_Spec -- return new string from given length+initval.	*/
/************************************************************************/

Vm_Obj
stg_From_Spec(
    Vm_Int  val,
    Vm_Unt  len
) {
    Vm_Obj obj;
    switch (len) {
    case 0: obj = OBJ_FROM_BYT0			;	break;
    case 1: obj = OBJ_FROM_BYT1( val	       );	break;
    case 2: obj = OBJ_FROM_BYT2( val, val      );	break;
    case 3: obj = OBJ_FROM_BYT3( val, val, val );	break;
    #if VM_INTBYTES > 4
    case 4: obj = OBJ_FROM_BYT4( val,val,val,val	     );	break;
    case 5: obj = OBJ_FROM_BYT5( val,val,val,val,val	     );	break;
    case 6: obj = OBJ_FROM_BYT6( val,val,val,val,val,val     );	break;
    case 7: obj = OBJ_FROM_BYT7( val,val,val,val,val,val,val );	break;
    #endif
    default:
	/* Don't combine next two lines: */
	/* OBJ_FROM_BYTN double-expands. */
	if (len >= STG_MAX)   MUQ_WARN("String too long");
	{   Vm_Int siz = (sizeof(Stg_A_Header)-VM_INTBYTES) + len;
            Vm_Obj pkg = JOB_P(jS.job)->package;
	    obj = vm_Malloc( siz, VM_DBFILE(pkg), OBJ_K_BYTN );
	    memset( STG_P(obj)->byte, val, len );
            job_RunState.bytes_owned += siz;
	}
        /* Mark strings as being read-only: */
	if (OBJ_IS_BYTN( obj ))  vm_Set_Constbit( obj );
    }
    return obj;
}



/************************************************************************/
/*-    stg_Get_Byte  -- return 'n'th byte from 'o'.			*/
/************************************************************************/

/* TRUE iff n was valid: */

Vm_Int
stg_Get_Byte(
    Vm_Uch*b,	/* return value */
    Vm_Obj o,
    Vm_Unt n
) {
    switch (OBJ_TYPE(o)) {

    case OBJ_TYPE_BYTN:
        if (vm_Len(o)   >   n + (sizeof(Stg_A_Header)-VM_INTBYTES)) {
	    *b = STG_P(o)->byte[n];  return TRUE;
	}
	break;

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:	if (n==6) {*b = OBJ_BYT6(o); return TRUE; }/*fallthru*/
    case OBJ_TYPE_BYT6:	if (n==5) {*b = OBJ_BYT5(o); return TRUE; }/*fallthru*/
    case OBJ_TYPE_BYT5:	if (n==4) {*b = OBJ_BYT4(o); return TRUE; }/*fallthru*/
    case OBJ_TYPE_BYT4:	if (n==3) {*b = OBJ_BYT3(o); return TRUE; }/*fallthru*/
    #endif
    case OBJ_TYPE_BYT3:	if (n==2) {*b = OBJ_BYT2(o); return TRUE; }/*fallthru*/
    case OBJ_TYPE_BYT2:	if (n==1) {*b = OBJ_BYT1(o); return TRUE; }/*fallthru*/
    case OBJ_TYPE_BYT1:	if (n==0) {*b = OBJ_BYT0(o); return TRUE; }/*fallthru*/
    default:							   /*fallthru*/
	;
    }
    *b = 0;
    return FALSE;
}



/************************************************************************/
/*-    stg_Set_Byte  -- change 'n'th byte in 'o'.			*/
/************************************************************************/

/* TRUE iff n was valid: */

void
stg_Set_Byte(
    Vm_Obj o,
    Vm_Unt n,
    Vm_Uch b
) {
    Vm_Unt bytes = (Vm_Unt)(vm_Len(o) - (sizeof(Stg_A_Header)-VM_INTBYTES));

    switch (OBJ_TYPE(o)) {

    case OBJ_TYPE_BYTN:
        if (n > bytes) {
	    MUQ_WARN ("Cannot set %dth byte in length-%d string!",(int)n,(int)bytes);
	}
	STG_P(o)->byte[n] = b;
	return;

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:
    case OBJ_TYPE_BYT6:
    case OBJ_TYPE_BYT5:
    case OBJ_TYPE_BYT4:
    #endif
    case OBJ_TYPE_BYT3:
    case OBJ_TYPE_BYT2:
    case OBJ_TYPE_BYT1:
    default:
	MUQ_WARN ("May not modify in-pointer string");
    }
}



/************************************************************************/
/*-    stg_Get_Bytes -- Read <= 'max' bytes from 'stg'.'loc' to 'buf'.	*/
/************************************************************************/

/* Returns number of bytes read: */

Vm_Int
stg_Get_Bytes(
    Vm_Uch* buf,
    Vm_Int  max,
    Vm_Obj  stg,
    Vm_Int  loc
) {
    Vm_Uch  ourbuf[VM_INTBYTES];
    Vm_Uch* t = ourbuf;
    Vm_Int  len = 0;

    switch (OBJ_TYPE(stg)) {

    case OBJ_TYPE_BYTN:
	len =           vm_Len(stg) - (sizeof(Stg_A_Header)-VM_INTBYTES);
	t   = &STG_P(stg)->byte[0];
	break;

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:	ourbuf[6] = OBJ_BYT6(stg);  ++len; /*fallthrough*/
    case OBJ_TYPE_BYT6:	ourbuf[5] = OBJ_BYT5(stg);  ++len; /*fallthrough*/
    case OBJ_TYPE_BYT5:	ourbuf[4] = OBJ_BYT4(stg);  ++len; /*fallthrough*/
    case OBJ_TYPE_BYT4:	ourbuf[3] = OBJ_BYT3(stg);  ++len; /*fallthrough*/
    #endif
    case OBJ_TYPE_BYT3:	ourbuf[2] = OBJ_BYT2(stg);  ++len; /*fallthrough*/
    case OBJ_TYPE_BYT2:	ourbuf[1] = OBJ_BYT1(stg);  ++len; /*fallthrough*/
    case OBJ_TYPE_BYT1: ourbuf[0] = OBJ_BYT0(stg);  ++len; /*fallthrough*/
    default:
	;
    }

    /* 't' now points to contents of stg, */
    /* 'len' is length of stg.		  */

    {   Vm_Int bytes_avail   = len - loc;
	Vm_Int bytes_to_copy = bytes_avail > max   ?   max   :   bytes_avail;
	memcpy(  buf,  &t[ loc ],  bytes_to_copy  );
        return bytes_to_copy;
    }
}

/************************************************************************/
/*-    stg_Set_Bytes -- Read <= 'max' bytes from buf to 'stg'.'loc'.	*/
/************************************************************************/

/* Returns number of bytes read: */

Vm_Int
stg_Set_Bytes(
    Vm_Uch* buf,
    Vm_Int  max,
    Vm_Obj  stg,
    Vm_Int  loc
) {
    Vm_Uch  ourbuf[VM_INTBYTES];
    Vm_Uch* t = ourbuf;
    Vm_Int  len = 0;

    switch (OBJ_TYPE(stg)) {

    case OBJ_TYPE_BYTN:
	len =           vm_Len(stg) - (sizeof(Stg_A_Header)-VM_INTBYTES);
	t   = &STG_P(stg)->byte[0];
	break;

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:
    case OBJ_TYPE_BYT6:
    case OBJ_TYPE_BYT5:
    case OBJ_TYPE_BYT4:
    #endif
    case OBJ_TYPE_BYT3:
    case OBJ_TYPE_BYT2:
    case OBJ_TYPE_BYT1:
    default:
	MUQ_WARN("Cannot change val of immediate string");
    }

    /* 't' now points to contents of stg, */
    /* 'len' is length of stg.		  */

    {   Vm_Int bytes_avail   = len - loc;
	Vm_Int bytes_to_copy = bytes_avail > max   ?   max   :   bytes_avail;
	memcpy(  &t[ loc ],  buf,  bytes_to_copy  );	vm_Dirty(stg);
        return bytes_to_copy;
    }
}



/************************************************************************/
/*-    stg_Is_Stg -- TRUE iff 'stg' is a string.			*/
/************************************************************************/

Vm_Int
stg_Is_Stg(
    Vm_Obj  stg
) {
    register Vm_Obj t = stg;
    if (job_Type0[t&0xFF] == JOB_TYPE_o
    && (   OBJ_IS_BYTN( t )
       #if VM_INTBYTES > 4
       ||  OBJ_IS_BYT7( t )
       ||  OBJ_IS_BYT6( t )
       ||  OBJ_IS_BYT5( t )
       ||  OBJ_IS_BYT4( t )
       #endif
       ||  OBJ_IS_BYT3( t )
       ||  OBJ_IS_BYT2( t )
       ||  OBJ_IS_BYT1( t )
       ||  OBJ_IS_BYT0( t )
       )
    ){
        return TRUE;
    }
    return FALSE;
}



/************************************************************************/
/*-    stg_Len -- Return bytesize of 'o'.				*/
/************************************************************************/

Vm_Unt
stg_Len(
    Vm_Obj o
) {
    switch (OBJ_TYPE(o)) {
    case OBJ_TYPE_BYTN: 
	return vm_Len(o) - (sizeof(Stg_A_Header)-VM_INTBYTES);
    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:	return 7;
    case OBJ_TYPE_BYT6:	return 6;
    case OBJ_TYPE_BYT5:	return 5;
    case OBJ_TYPE_BYT4:	return 4;
    #endif
    case OBJ_TYPE_BYT3:	return 3;
    case OBJ_TYPE_BYT2:	return 2;
    case OBJ_TYPE_BYT1:	return 1;
    case OBJ_TYPE_BYT0:	return 0;
    default:
	MUQ_WARN ("stg_Len: internal err");
    }
    return 0; /* Pacify gcc. */
}




/************************************************************************/
/*-    --- General static fns ---					*/
/************************************************************************/


#undef  MAX_STRING
#define MAX_STRING 8192

/************************************************************************/
/*-    stg_hash -- Return hashtable key for string.			*/
/************************************************************************/

Vm_Obj
stg_hash(
    Vm_Obj o
) {
/*printf("stg_hash called...\n");*/
    switch (OBJ_TYPE(o)) {
    case OBJ_TYPE_BYTN: 
	{   Vm_Uch buf[ MAX_STRING ];
	    Vm_Int len = stg_Get_Bytes( buf, MAX_STRING, o, 0 );
	    if (len == MAX_STRING)   MUQ_WARN ("String too long to hash");
	    {   Vm_Int  result = sha_InsecureHash(buf,len);
/*
Vm_Int i;
printf("stg_hash(%" VM_X "):",o);
for (i = 0;  i < len;  ++i) printf("%02x",buf[i]);
printf(" -> %" VM_X "\n",result);
*/
	        return  result;
	    }
	}

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
    default:
	return o;
    }
    return 0; /* Pacify gcc. */
}

/************************************************************************/
/*-    stg_sprintX -- Debug dump of stg state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
stg_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  quote_strings
) {
    switch (OBJ_TYPE(obj)) {
    case OBJ_TYPE_BYTN:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	{   Vm_Uch b;
	    Vm_Unt u;
	    for   (u = 0;   stg_Get_Byte(&b,obj,u);   ++u) {
		buf = lib_Sprint( buf, lim, "%c", b );
	    }
	}
	if (quote_strings)   buf = lib_Sprint( buf, lim, "%c", '"' );
	break;

    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT7:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT0(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT1(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT2(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT3(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT4(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT5(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT6(obj) );
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	break;

    case OBJ_TYPE_BYT6:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT0(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT1(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT2(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT3(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT4(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT5(obj) );
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	break;

    case OBJ_TYPE_BYT5:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT0(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT1(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT2(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT3(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT4(obj) );
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	break;

    case OBJ_TYPE_BYT4:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT0(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT1(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT2(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT3(obj) );
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	break;

    #endif
    case OBJ_TYPE_BYT3:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT0(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT1(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT2(obj) );
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	break;

    case OBJ_TYPE_BYT2:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT0(obj) );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT1(obj) );
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	break;

    case OBJ_TYPE_BYT1:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	buf = lib_Sprint( buf, lim, "%c", (int)OBJ_BYT0(obj) );
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	break;

    case OBJ_TYPE_BYT0:
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	if (quote_strings)    buf = lib_Sprint( buf, lim, "%c", '"' );
	break;
    default:
	MUQ_WARN ("stg_sprintX: internal err.");
    }
    return buf;
}



/************************************************************************/
/*-    stg_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
stg_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    stg_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
stg_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Unt n   = (Vm_Unt) OBJ_TO_INT(key);
    Vm_Unt len = stg_Len( obj );
    if (!OBJ_IS_INT(key))   return OBJ_NOT_FOUND;

    if (n >= len) {
	Vm_Unt  m = (Vm_Int)n + (Vm_Int)len;
	if (m >= len)   return OBJ_NOT_FOUND;
	n = m;
    }
    {   Vm_Uch c;
	if (!stg_Get_Byte(&c, obj, n)) {
	    return OBJ_NOT_FOUND;
	}
	return OBJ_FROM_CHAR(c);
    }
}



/************************************************************************/
/*-    stg_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
stg_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    stg_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch*
stg_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
/* buggo, need a readOnly bit on strings */
/* sometime, checked for here. */
    if (!OBJ_IS_INT(key))    return "Strings only take integer keys";
    if (!OBJ_IS_CHAR(val))   return "String slots only take character values";
    {   Vm_Unt n   = (Vm_Unt) OBJ_TO_INT(key);
        stg_Set_Byte( obj, n, OBJ_TO_CHAR(val) );
	return NULL;
    }
}



/************************************************************************/
/*-    stg_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj
stg_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    Vm_Int len = stg_Len( obj );
    if (propdir != OBJ_PROP_PUBLIC)      return OBJ_NOT_FOUND;
    if (len     == 0)                    return OBJ_NOT_FOUND;
    if (0 < obj_Neql( OBJ_FROM_INT(0), key ))   return OBJ_FROM_INT(0);
    if (OBJ_IS_INT(key)) {
	Vm_Int k1 = OBJ_TO_INT(key) +1;
	if    (k1 < len)   return OBJ_FROM_INT(k1);
    }
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    get_mos_key -- Find key object for this structure		*/
/************************************************************************/

static Vm_Obj
get_mos_key(
    Vm_Obj obj
) {
    /* I suspect a lot of strings get built */
    /* before the class does.  Should fix   */
    /* this if so, and phase out this code, */
    /* at some point:                       */
    if (OBJ_TYPE(obj) == OBJ_TYPE_BYTN) {
        Vm_Obj cdf = stg_Type_Summary.builtin_class;
	if (OBJ_IS_OBJ(cdf) && OBJ_IS_CLASS_CDF(cdf)) {
	    Vm_Obj key = CDF_P(cdf)->key;
	    if (OBJ_IS_OBJ(key) && OBJ_IS_CLASS_KEY(key)) {
		return key;
    }	}   }

    return CDF_P(stg_Type_Summary.builtin_class)->key;
}

/************************************************************************/
/*-    stg_import -- Read  object from textfile.			*/
/************************************************************************/

#ifndef STG_IMPORT_INITIAL_SIZE
#define STG_IMPORT_INITIAL_SIZE 1024
#endif

static Vm_Obj
stg_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    static Vm_Uch* buf = NULL;
    static Vm_Int  siz = 0;
    if (!siz) {
	buf = (Vm_Uch*) malloc( STG_IMPORT_INITIAL_SIZE );
	siz =                   STG_IMPORT_INITIAL_SIZE  ;
	if (!buf)   MUQ_FATAL ("stg_Import: out of ram!\n");
    }

    {   /* Read length of stg: */
	Vm_Int len;
	if (1 != fscanf(fd, "%" VM_D ":", &len )
	||  0 > len
	){
	    MUQ_FATAL ("stg_Import: bad input.0");
	}

	/* Maybe expand buf to be big enough: */
	if (len > siz) {
	    buf = realloc( buf, len );
	    if (!buf)   MUQ_FATAL ("stg_Import: out of ram!\n");
	    siz = len;
	}

	/* Read stg in, followed by newline: */
	{   Vm_Int i;
	    for (i = 0;   i < len;   ++i) {	
		Vm_Int c = fgetc( fd );
		if (c == EOF) {
		    MUQ_FATAL ("stg_Import: premature end of file!\n");
		}
		buf[i] = c;		
	}   }
	if (fgetc( fd ) != '\n')   MUQ_FATAL ("stg_Import: bad input");

        /* Create and return stg instance: */
        ++obj_Export_Stats->items_in_file;
	return pass ? stg_From_Buffer( buf, len ) : OBJ_NIL;
    }
}



/************************************************************************/
/*-    stg_export -- Write object into textfile.			*/
/************************************************************************/

static void
stg_export(
    FILE* fd,
    Vm_Obj o,
    Vm_Int write_owners
) {
    Vm_Int len = stg_Len(o);
    fprintf(fd, "t:%d:", (int)len );
    {   Vm_Int i;
	for (i = 0;   i < len;   ++i) {
	    Vm_Uch c;
	    if (!stg_Get_Byte( &c, o, i )) {
		fputs("stg_Export: internal err",stderr);
		exit(1);
	    }
	    fputc( c, fd );
    }	}
    fputc( '\n', fd );
}


#ifdef OLD

/************************************************************************/
/*-    print  -- Dump state of stg in ascii form.			*/
/************************************************************************/

#if MUQ_DEBUG

static void
print(
    FILE* f,
    Vm_Obj stg
) {
    /* Dump 'stg', backslashing " and \ and */
    /* expanding nonprinters to \233 etc:   */
    Vm_Int i;
    for   (i = 0;   ;   ++i) {
        Vm_Uch c;
	if (!stg_Get_Byte( &c, stg, i ))   return;
	if (c < ' ' && c != '\t' && c != '\n') {
            fputc('^',f);
            fputc('@'+c,f);
	    continue;
	}
	if (c >= 0x7F) {
            Vm_Uch  buf[ 32 ];
	    sprintf(buf, "\\%03o", (int)c );
	    fputs(buf,f);
	    continue;
	}
	if (c == '"'
	||  c == '\\'
	){
	    fputc('\\',f);
	}
	fputc(c,f);
    }
}

#endif


#endif
#ifdef OLD

/************************************************************************/
/*-    print1 -- Dump state of stg in ascii form.			*/
/************************************************************************/

#if MUQ_DEBUG

static void
print1(
    FILE* f,
    Vm_Obj stg
) {
    /* Dump 'stg', expanding nonprinters to \233 etc:   */
    Vm_Int i;
    for   (i = 0;   ;   ++i) {
        Vm_Uch c;
	if (!stg_Get_Byte( &c, stg, i ))   return;
	if (c < ' ' && c != '\t' && c != '\n') {
            fputc('^',f);
            fputc('@'+c,f);
	    continue;
	}
	if (c >= 0x7F) {
            Vm_Uch  buf[ 32 ];
	    sprintf(buf, "\\%03o", (int)c );
	    fputs(buf,f);
	    continue;
	}
	fputc(c,f);
    }
}

#endif


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
