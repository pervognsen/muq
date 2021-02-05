@example  @c
/*--   mss.c -- MeSsage Streams for Muq.				*/
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

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_mss( Vm_Unt );

static Vm_Obj	mss_allow_reads(            Vm_Obj        );
static Vm_Obj	mss_allow_writes(           Vm_Obj        );
static Vm_Obj	mss_column(                 Vm_Obj        );
static Vm_Obj	mss_byte(                   Vm_Obj        );
static Vm_Obj	mss_line(                   Vm_Obj        );
static Vm_Obj	mss_dead(                   Vm_Obj        );
static Vm_Obj	mss_twin(                   Vm_Obj        );
static Vm_Obj	mss_buffer_length(          Vm_Obj        );
static Vm_Obj	mss_max_packet(             Vm_Obj        );
static Vm_Obj	mss_input_string(           Vm_Obj        );
static Vm_Obj	mss_input_string_cursor(    Vm_Obj        );
static Vm_Obj	mss_input_substitute(       Vm_Obj        );
static Vm_Obj	mss_set_allow_reads(  Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_allow_writes( Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_column(       Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_byte(         Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_line(         Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_dead(         Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_twin(         Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_never(        Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_input_string( Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_input_string_cursor( Vm_Obj, Vm_Obj );
static Vm_Obj	mss_set_input_substitute( Vm_Obj, Vm_Obj );

#ifdef CURRENTLY_UNUSED
static Vm_Int   mss_is_empty(      Vm_Obj            );
#endif


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property mss_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"allowReads"	, mss_allow_reads      , mss_set_allow_reads	},
    {0,"allowWrites"	, mss_allow_writes     , mss_set_allow_writes	},
    {0,"bufferLength"	, mss_buffer_length    , mss_set_never		},
    {0,"column" 	, mss_column           , mss_set_column		},
    {0,"byte"	 	, mss_byte             , mss_set_byte		},
    {0,"line"	 	, mss_line             , mss_set_line		},
    {0,"dead"		, mss_dead	       , mss_set_dead		},
    {0,"maxPacket"	, mss_max_packet       , mss_set_never		},
    {0,"twin"		, mss_twin	       , mss_set_twin		},
    {0,"inputString"	, mss_input_string     , mss_set_input_string	},
    {0,"inputStringCursor", mss_input_string_cursor, mss_set_input_string_cursor	},
    {0,"inputSubstitute", mss_input_substitute , mss_set_input_substitute	},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class mss_Hardcoded_Class = {
    OBJ_FROM_BYT3('m','s','s'),
    "MessageStream",
    sizeof_mss,
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
    { mss_system_properties, mss_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void mss_doTypes(void){}
Obj_A_Module_Summary mss_Module_Summary = {
   "mss",
    mss_doTypes,
    mss_Startup,
    mss_Linkup,
    mss_Shutdown,
};



/************************************************************************/
/*-    Overview                          				*/
/************************************************************************/

/************************************************************************

Message streams are circular streams of 'messages' stored in an array
within an object.  Each message consists of a Vm_Obj address
indicating the source or destination for the message, plus the Vm_Obj
message itself, which is typically a string but may be any of the
usual suspects storable on stacks and in variables and properties.

Message streams play in Muq much the same role that [optionally
named] pipes play in unix: they are

 (1)  abstraction operators,
 (2)  communication channels,
 (3)  synchronization mechanisms, and 
 (4)  addresses allowing de/multiplexing,

since (respectively)

 (1)  Muq jobs frequently just filter from their input message
      stream to their output message stream without worrying further
      about their environment, allowing them to be used as modular
      components much like unix filters;
 (2)  Message streams allow stable storage of a bounded amount of
      data awaiting further processing;
 (3)  Jobs attempting to read/write an empty/full message stream
      transparently block until there is data/room permitting
      them to proceed;
 (4)  Many jobs may read or write a single message stream.

 ************************************************************************/




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    mss_Need_Power_Of_Two -- Check given number is a power of two.	*/
/************************************************************************/

void
mss_Need_Power_Of_Two(
    Vm_Uch* name,
    Vm_Int  value
) {
    Vm_Unt  bits = 0;
    Vm_Unt  v    = (Vm_Unt) value;
    while  (v > 1) {
	v >>= 1;
	++bits;
    }
    if (value != (1 << bits)) {
	MUQ_FATAL ("'%s' x=%" VM_X ", which is not a power of 2!", name, value );
    }
}    



/************************************************************************/
/*-    mss_Is_Empty -- True or False.					*/
/************************************************************************/

Vm_Int
mss_Is_Empty(
    Vm_Obj     obj
) {
    Mss_P  q = MSS_P(obj);

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(obj) || !OBJ_IS_CLASS_MSS(obj)) {
	MUQ_FATAL ("Needed mss!0");
    }
    #endif

    return q->src == q->dst;
}



/************************************************************************/
/*-    mss_Is_Full -- Any slots free? (TRUE or FALSE.)			*/
/************************************************************************/

Vm_Int
mss_Is_Full(
    Vm_Obj     obj
) {
    Mss_P     q   = MSS_P(obj);

    Vm_Int mask   = OBJ_TO_INT( q->len ) -1;
    Vm_Int  dst   = OBJ_TO_INT( q->dst )   ;
    Vm_Int  src   = OBJ_TO_INT( q->src )   ;

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(obj) || !OBJ_IS_CLASS_MSS(obj)) {
	MUQ_FATAL ("Needed mss!1");
    }
    #endif

    return (dst+1 & mask) == src;
}



/************************************************************************/
/*-    mss_Can_Accept -- Can this send be done?				*/
/************************************************************************/

Vm_Int
mss_Can_Accept(
    Vm_Obj     obj,
    Vm_Obj     who,
    Vm_Obj     tag,
    Vm_Obj*    buf,
    Vm_Int     buflen
) {
    Mss_P       q = MSS_P( obj );

    Vm_Int    src = OBJ_TO_INT( q->src );
    Vm_Int    dst = OBJ_TO_INT( q->dst );
    Vm_Int   mask = OBJ_TO_INT( q->len ) -1;

    Vm_Int  s_src = OBJ_TO_INT( q->vector_src );
    Vm_Int  s_dst = OBJ_TO_INT( q->vector_dst );
    Vm_Int  s_len = OBJ_TO_INT( q->vector_len );
/*  Vm_Int s_mask = s_len -1; */

    /* Figure free space in vector: */
    Vm_Int s_full = (s_src <= s_dst) ? (s_dst-s_src) : ((s_dst+s_len)-s_src);
    Vm_Int s_free = s_len - (s_full +1 ); /* +1: Can't let fill completely. */

    return (dst+1 & mask) != src   &&   s_free >= buflen;
}



/************************************************************************/
/*-    mss_Peek -- Return first src/msg pair, but leave in buf.		*/
/************************************************************************/

Vm_Int
mss_Peek(
    Mss_Msg    msg,
    Vm_Obj     obj
) {
    Mss_P      q  = MSS_P(obj);

    /* Locate buf within obj: */
    Vm_Int  src   = OBJ_TO_INT( q->src );
    Vm_Int  dst   = OBJ_TO_INT( q->dst );

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(obj) || !OBJ_IS_CLASS_MSS(obj)) {
	MUQ_FATAL ("Needed mss!2");
    }
    #endif

    /* If stream is empty, return FALSE: */
    if (src == dst)   return FALSE;

    /* Read src/msg from our buf slot: */
    *msg	 = q->buf[ src ];

    return TRUE;
}



/************************************************************************/
/*-    mss_Scan_Token -- Figure length of a token.			*/
/************************************************************************/

/********************************************************/
/* This is a compiler support function.  The idea is	*/
/* to return a number of characters at once (for a	*/
/* potential performance win) while also logging	*/
/* those chars in a token buffer (token_stg) in the	*/
/* stream, so that later the compiler can fetch all	*/
/* the source for a given function in a single		*/
/* operation.						*/
/* 							*/
/* We need to return the byte offset of the		*/
/* token start to facilitate this later fetch,		*/
/* and we need to return the line offset of the		*/
/* token start to facilitate diagnostics.		*/
/********************************************************/

Vm_Int			/* Number of chars returned.			*/
mss_Scan_Token(
    Vm_Int*    byteloc,	/* Byte offset of first returned char in stream.*/
    Vm_Int*    lineloc,	/* Line offset of first returned char in stream.*/
    Vm_Uch*    buf,	/* Buffer in which we return chars.		*/
    Vm_Int     buflen,	/* Maximum number of chars to return.		*/
    Vm_Obj     mss,	/* Message stream to read.			*/
    Vm_Int   (*done)( Vm_Int )	/* Termination condition.		*/
) {
    Mss_A_Msg  msg;

    Mss_P      q  = MSS_P( mss );

    Vm_Int  src   = OBJ_TO_INT( q->src );
    Vm_Int  dst   = OBJ_TO_INT( q->dst );
    Vm_Int mask   = OBJ_TO_INT( q->len ) -1;

    /* Remember whether stream was full: */
    Vm_Int mss_was_full = (((src + 1) & mask) == dst);

    Vm_Int chars_read = 0;
    Vm_Obj vector =             q->vector      ;
    Vm_Int  v_src = OBJ_TO_INT( q->vector_src );
/*  Vm_Int  v_dst = OBJ_TO_INT( q->vector_dst ); */
    Vm_Int  v_len = OBJ_TO_INT( q->vector_len );
    Vm_Int v_mask = v_len -1;

    Vm_Int  col   = OBJ_TO_INT( q->column );
    Vm_Int  line  = OBJ_TO_INT( q->line   );
    Vm_Int  byte  = OBJ_TO_INT( q->byte   );

#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
    printf("mss_Scan_Token/top mss x=%llx:\n",mss);
    printf("    src    x=%llx\n",OBJ_TO_INT( q->src        ) );
    printf("    dst    x=%llx\n",OBJ_TO_INT( q->dst        ) );
    printf("    col    x=%llx\n",OBJ_TO_INT( q->column     ) );
    printf("    vector x=%llx\n",vector );
    printf("    v_src  x=%llx\n",OBJ_TO_INT( q->vector_src ) );
    printf("    v_dst  x=%llx\n",OBJ_TO_INT( q->vector_dst ) );
    printf("    v_len  x=%llx\n",v_len  );
    printf("    t_src  x=%llx\n",OBJ_TO_INT( q->token_src ) );
    printf("    t_dst  x=%llx\n",OBJ_TO_INT( q->token_dst ) );
    printf("    line   x=%llx\n",OBJ_TO_INT( q->line      ) );
    printf("    byte   x=%llx\n",OBJ_TO_INT( q->byte      ) );
}
#endif
    *byteloc = byte;
    *lineloc = line;

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	MUQ_FATAL ("Needed mss!3");
    }
    #endif

    if (buflen < 1) MUQ_WARN("mss_Scan_Token: need buflen > 0");


    /* Over as many packets as it takes: */
    for (;;) {

        Vm_Int len;

        /* If there is no packet available to satisfy   */
        /* the request, maybe put current job to sleep: */
        if (src == dst){

	    /* If we've read no characters, we should */
	    /* empty the buffer, to free up space in  */
            /* the stream.  But if we have read chars */
	    /* we need to leave them there so we can  */
	    /* re-read them when restarted:           */
	    if (!chars_read) {
		/* Update stream state: */
		q->src        = OBJ_FROM_INT(   src );
		q->vector_src = OBJ_FROM_INT( v_src );
		q->column     = OBJ_FROM_INT(   col );
		vm_Dirty( mss );
		q->line       = OBJ_FROM_INT( line       );
		q->byte       = OBJ_FROM_INT( byte + chars_read );
		vm_Dirty( mss );
	    }

	    mss_Readsleep( mss );	/* Doesn't return. */
        }

        /* Read src/msg from our inbuf slot: */
        msg = q->buf[ src ];
#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
    printf("mss_Scan_Token/msg mss x=%llx:\n",mss);
    printf("   msg.loc d=%d\n",(int)(OBJ_TO_INT(msg.vec_loc)));
    printf("   msg.len d=%d\n",(int)(OBJ_TO_INT(msg.vec_len)));
}
#endif
        len = OBJ_TO_INT( msg.vec_len );

	/* Ignore all but 'txt' packets,       */
	/* and text packets with no text left: */
	if (msg.tag == OBJ_FROM_BYT3('t','x','t')
	&&  col < len
	){

	    /* Copy message chars into buffer: */
            Vm_Int loc = OBJ_TO_INT(msg.vec_loc);
	    Vm_Int i;
	    for (i = col;   i < len;   ++i) {

		Vec_P  v = VEC_P( vector );
		Vm_Obj*t = &v->slot[0];
		Vm_Obj o = t[ loc + i  &  v_mask ];

		if (OBJ_IS_CHAR(o)) {

		    Vm_Int c   = OBJ_TO_CHAR( o );
		    Vm_Int end = done(c);

                    if (end != MSS_END_TOKEN_WITH_PREV_CHAR) {
			buf[ chars_read++ ] = c;
			if (c == '\n') ++line;
			if (chars_read == buflen) {
			    end = MSS_END_TOKEN_WITH_THIS_CHAR;
		    }   }

		    if (end) {

			Vm_Int token_src;
			Vm_Int token_dst;

			q  = MSS_P( mss ); /* Above VEC_P() trashed q. */

			token_src  = OBJ_TO_INT( q->token_src  );
			token_dst  = OBJ_TO_INT( q->token_dst  );
#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
    printf("mss_Scan_Token/mid mss x=%llx:\n",mss);
    printf("    t_src  x=%llx\n",token_src  );
    printf("    t_dst  x=%llx\n",token_dst  );
}
if (job_Reserved) {
 int i;
 printf("mss_Scan_Token/mid mss x=%llx read %d values:\n",mss,(int)chars_read);
 for (i = 0;   i < len; ++i) {
    printf(" %d: %c\n",i,buf[i]);
 }
}
#endif


			/* If mss was full before our read, */
			/* any jobs waiting to write to it  */
			/* should be moved to /etc/run:     */
			if (mss_was_full) {
			    if (q->q_out != OBJ_FROM_INT(0)) {
				joq_Run_Queue( q->q_out );
				q  = MSS_P( mss );
			}   }

			/* Save read chars in token log: */
			{   Vm_Obj stg = q->token_stg;
			    
			    /* Create new log if it doesn't exist: */
			    if (!OBJ_IS_BYTN(stg)) {
				stg = stg_From_Spec( 0, MSS_MAX_TOKEN_STRING );
				q  = MSS_P( mss );
				q->token_stg = stg;
				vm_Dirty( mss );
			    }

			    /* Do the actual copy to log: */
			    {   Vm_Int lim = stg_Len( stg );
			        Stg_P  s   = STG_P(   stg );
				Vm_Int tmask= lim-1;
				Vm_Int b;

				/* Shouldn't be needed, */
				/* but cheap insurance: */
				token_src &= tmask;
				token_dst &= tmask;

				for (b = 0;   b < chars_read;   ++b) {
				    s->byte[ token_dst ] = buf[ b ];
				    token_dst = token_dst+1 & tmask;
				    if (token_dst == token_src) {
					token_src = token_src+1 & tmask;
				    }
				}
			    }
			    vm_Dirty( stg );
			}

			q  = MSS_P( mss );
			q->token_src  = OBJ_FROM_INT( token_src  );
			q->token_dst  = OBJ_FROM_INT( token_dst  );
			q->column     = OBJ_FROM_INT( i+(end-1)  );
			q->src        = OBJ_FROM_INT( src        );
			q->vector_src = OBJ_FROM_INT( v_src      );
			q->line       = OBJ_FROM_INT( line       );
			q->byte       = OBJ_FROM_INT( byte + chars_read );
			vm_Dirty( mss );

#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
    printf("mss_Scan_Token/bot mss x=%llx:\n",mss);
    printf("    src    x=%llx\n",OBJ_TO_INT( q->src        ) );
    printf("    dst    x=%llx\n",OBJ_TO_INT( q->dst        ) );
    printf("    col    x=%llx\n",OBJ_TO_INT( q->column     ) );
    printf("    vector x=%llx\n",vector );
    printf("    v_src  x=%llx\n",OBJ_TO_INT( q->vector_src ) );
    printf("    v_dst  x=%llx\n",OBJ_TO_INT( q->vector_dst ) );
    printf("    v_len  x=%llx\n",v_len  );
    printf("    t_src  x=%llx\n",OBJ_TO_INT( q->token_src ) );
    printf("    t_dst  x=%llx\n",OBJ_TO_INT( q->token_dst ) );
    printf("    line   x=%llx\n",OBJ_TO_INT( q->line      ) );
    printf("    byte   x=%llx\n",OBJ_TO_INT( q->byte      ) );
}
#endif
			return chars_read;
		    }
		}
	    }

	    q  = MSS_P( mss ); /* Above VEC_P() may have trashed q. */
	}

	/* Mark our slot as read: */
	src   = src+1 & mask;

	/* Mark values as deleted from buffer: */
	v_src = v_src+len & v_mask;

	/* Set column to zero: */
	col = 0;
#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
    printf("mss_Scan_Token/bot II mss x=%llx:\n",mss);
    printf("    src    x=%llx\n",OBJ_TO_INT( q->src        ) );
    printf("    dst    x=%llx\n",OBJ_TO_INT( q->dst        ) );
    printf("    col    x=%llx\n",OBJ_TO_INT( q->column     ) );
    printf("    vector x=%llx\n",vector );
    printf("    v_src  x=%llx\n",OBJ_TO_INT( q->vector_src ) );
    printf("    v_dst  x=%llx\n",OBJ_TO_INT( q->vector_dst ) );
    printf("    v_len  x=%llx\n",v_len  );
    printf("    t_src  x=%llx\n",OBJ_TO_INT( q->token_src ) );
    printf("    t_dst  x=%llx\n",OBJ_TO_INT( q->token_dst ) );
    printf("    line   x=%llx\n",OBJ_TO_INT( q->line      ) );
    printf("    byte   x=%llx\n",OBJ_TO_INT( q->byte      ) );
}
#endif
    }
}



/************************************************************************/
/*-    mss_Read_Token -- Read token chars.				*/
/************************************************************************/

Vm_Int 			/* Number of chars read.			*/
mss_Read_Token(
    Vm_Uch*    buf,	/* Buffer in which we return chars.		*/
    Vm_Int     buflen,	/* Maximum number of chars to return.		*/
    Vm_Obj     mss,	/* Message stream to read.			*/
    Vm_Int     start,	/* Offset to start at.				*/
    Vm_Int     stop	/* Offset to stop at.				*/
) {
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	MUQ_FATAL ("Needed mss!3");
    }
    #endif

    if (buflen < stop-start) MUQ_WARN("mss_Read_Token: buffer overflow");


    {   Mss_P      q  = MSS_P( mss );
	Vm_Int  byte  = OBJ_TO_INT( q->byte   );

    	Vm_Int token_src = OBJ_TO_INT( q->token_src  );
	Vm_Int token_dst = OBJ_TO_INT( q->token_dst  );

	Vm_Obj stg = q->token_stg;

	Vm_Int lim = stg_Len( stg );
	Stg_P  s   = STG_P(   stg );
	Vm_Int tmask= lim-1;
	Vm_Int bytes_in_buffer;
	Vm_Int src_byt;

	/* Shouldn't be needed, */
	/* but cheap insurance: */
	token_src &= tmask;
	token_dst &= tmask;

	/* Figure number of bytes in buffer: */
	if (token_src <= token_dst) {
	    bytes_in_buffer =  token_dst      - token_src;
	} else {
	    bytes_in_buffer = (token_dst+lim) - token_src;
	}

	/* Figure offset of first byte in buffer: */	
	src_byt = byte - bytes_in_buffer;

	/* Sanity check: */
	if (start < src_byt
        || stop > byte
	){
	    MUQ_WARN("readTokenChars: token not in buffer");
	}

	{   Vm_Int chars = stop-start;
	    Vm_Int src   = token_src + (start - src_byt) & tmask;
	    Vm_Int i;
	    for (i = 0;   i < chars;   ++i) {
		buf[ i ] = s->byte[ src ];
		src = src+1 & tmask;
	    }
	    return chars;
	}
    }
}



/************************************************************************/
/*-    mss_Read_Value -- Maybe read value from stream packet.		*/
/************************************************************************/

Vm_Int /* TRUE iff value sucessfully read. */
mss_Read_Value(
    Vm_Obj* who,	/* Sender of packet.	*/
    Vm_Obj* tag,	/* Tag for packer.	*/
    Vm_Obj* val,	/* Next val from packet.*/
    Vm_Obj  obj		/* Stream to read.	*/
) {
    /*****************************************************/
    /* The idea here is to support functionality similar */
    /* to unix/c "getchar()" by returning one value from */
    /* the next packet to read, advancing 'column' to    */
    /* mark our place.                                   */
    /*****************************************************/

    /* Loop until we find a packet containing */
    /* a value we can return, or else run out */
    /* of packets:                            */
    for (;;) {
        Mss_P      q  = MSS_P( obj );
        if (q->src == q->dst) {

	    /* Stream empty: */
	    return FALSE;

	} else {

	    /* Stream not empty: */
	    Vm_Unt  col   = OBJ_TO_UNT( q->column           );
            Vm_Int  src   = OBJ_TO_INT( q->src              );
	    Vm_Obj  vec   =             q->vector            ;
	    Vm_Unt  loc   = OBJ_TO_UNT( q->buf[src].vec_loc );
	    Vm_Unt  len   = OBJ_TO_UNT( q->buf[src].vec_len );
	    if (col < len) {

		/* Found a value to return: */
		q->column = OBJ_FROM_INT( col+1 );
		vm_Dirty(obj);
		*who = q->buf[src].who;
		*tag = q->buf[src].tag;
		*val = VEC_P(vec)->slot[ loc + col ];
		return TRUE;

	    } else {

		/* No values in this packet,  */
		/* so discard this packet and */
		/* try next one (if any):     */
		Mss_A_Msg  dummy;
		mss_Read(
		    NULL,    /* buf                              */
		    0,       /* buflen                           */
		    OBJ_NIL, /* Allow reading incomplete packets */
		    &dummy,
		    obj,
		    TRUE     /* ok_to_block			 */
		);
	    }
	}
    }
}

/************************************************************************/
/*-    mss_Unread_Value -- Maybe restore value to stream packet.	*/
/************************************************************************/

void
mss_Unread_Value(
    Vm_Obj mss
) {
    /* Assume that an mss_Read_Value was done */
    /* recently, and try to undo its effect.  */
    /* We're not obligated to undo more than  */
    /* one deep:                              */
    Mss_P   q   = MSS_P( mss );
    Vm_Unt  col = OBJ_TO_UNT( q->column );
    if (col) {
	q->column = OBJ_FROM_UNT( col-1 );
	vm_Dirty(mss);
    }
}

/************************************************************************/
/*-    mss_Unread_Token_Char -- Maybe restore value to stream packet.	*/
/************************************************************************/

Vm_Int
mss_Unread_Token_Char(
    Vm_Obj mss
) {
    /* Like mss_Unread_Value, but we also */
    /* want to unwind the token buffer:   */
    Mss_P  q   = MSS_P( mss );
    Vm_Unt col        = OBJ_TO_UNT( q->column     );
    Vm_Unt byte       = OBJ_TO_UNT( q->byte       );
    Vm_Unt line       = OBJ_TO_UNT( q->line       );
    Vm_Int token_src  = OBJ_TO_INT( q->token_src  );
    Vm_Int token_dst  = OBJ_TO_INT( q->token_dst  );
    Vm_Obj stg        =             q->token_stg   ;
    Vm_Int c;

    /* Sanity checks: */
    if (!col				/* Didn't just do read. */
    ||  !OBJ_IS_BYTN( q->token_stg )	/* No token buffer.	*/
    ||  token_src == token_dst		/* Empty token buffer.	*/
    ){
        MUQ_WARN("Couldn't unreadTokenChar");
    }

    /* See if we just unread a newline: */
    {   Vm_Int lim    = stg_Len( stg );
	Vm_Int tmask  = lim-1;
	Vm_Int newdst = token_dst-1 & tmask;
	c = STG_P(stg)->byte[ newdst  ];
/*printf("mss_Unread_Token_Char unreading newline..\n");*/
	if (c == '\n')  --line;
	token_dst = newdst;
        q   = MSS_P( mss );
    }

    /* Update appropriate fields: */
    q->column    = OBJ_FROM_UNT( col -1    );
    q->byte      = OBJ_FROM_UNT( byte-1    );
    q->line      = OBJ_FROM_UNT( line      );
    q->token_dst = OBJ_FROM_UNT( token_dst );
    vm_Dirty(mss);

    return c;
}

/************************************************************************/
/*-    mss_Readjoq -- Return input jobqueue, maybe creating it.		*/
/************************************************************************/

Vm_Obj
mss_Readjoq(
    Vm_Obj obj
) {
    Mss_P q = MSS_P(obj);

    /* Create "in" job queue if it doesn't exist: */
    Vm_Obj joq = q->q_in;
    if (joq == OBJ_FROM_INT(0)) {
	joq = joq_Alloc(obj, OBJ_FROM_BYT2('i','n'));/* Create joq.    */
	q   = MSS_P( obj );			     /* May have moved.*/
	q->q_in = joq;
	vm_Dirty(obj);
    }
    return joq;
}

/************************************************************************/
/*-    mss_Readsleep -- Put job to sleep on input jobqueue for stream.	*/
/************************************************************************/

void
mss_Readsleep(
    Vm_Obj obj
) {
    Vm_Obj joq = mss_Readjoq( obj );

    /* Move current job to job queue, */
    /* then switch to next job:       */
    joq_Requeue( joq, job_RunState.job );
    job_End_Timeslice();	/* Doesn't return. */
}

/************************************************************************/
/*-    mss_Read -- Maybe read packet from stream.			*/
/************************************************************************/

Vm_Int
mss_Read(
    Vm_Obj*    buf,
    Vm_Int     buflen,
    Vm_Obj     no_fragments,/* OBJ_NIL to allow reading incomplete packets */
    Mss_Msg    msg,
    Vm_Obj     mss,
    Vm_Int     ok_to_block
) {
    Mss_P      q  = MSS_P( mss );

    Vm_Int  src   = OBJ_TO_INT( q->src );
    Vm_Int  dst   = OBJ_TO_INT( q->dst );
    Vm_Int mask   = OBJ_TO_INT( q->len ) -1;

    /* Remember whether stream was full: */
    Vm_Int mss_was_full = (((src + 1) & mask) == dst);

    Vm_Int values_transferred = 0;
    Vm_Int    col = OBJ_TO_INT( q->column     );
    Vm_Obj vector =             q->vector      ;
    Vm_Int  v_src = OBJ_TO_INT( q->vector_src );
/*  Vm_Int  v_dst = OBJ_TO_INT( q->vector_dst ); */
    Vm_Int  v_len = OBJ_TO_INT( q->vector_len );
    Vm_Int v_mask = v_len -1;

#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
    printf("mss_Read/top mss x=%llx:\n",mss);
    printf("    src    x=%llx\n",OBJ_TO_INT( q->src        ) );
    printf("    dst    x=%llx\n",OBJ_TO_INT( q->dst        ) );
    printf("    col    x=%llx\n",OBJ_TO_INT( q->column     ) );
    printf("    vector x=%llx\n",vector );
    printf("    v_src  x=%llx\n",OBJ_TO_INT( q->vector_src ) );
    printf("    v_dst  x=%llx\n",OBJ_TO_INT( q->vector_dst ) );
    printf("    v_len  x=%llx\n",v_len  );
    printf("    t_src  x=%llx\n",OBJ_TO_INT( q->token_src ) );
    printf("    t_dst  x=%llx\n",OBJ_TO_INT( q->token_dst ) );
    printf("    line   x=%llx\n",OBJ_TO_INT( q->line      ) );
    printf("    byte   x=%llx\n",OBJ_TO_INT( q->byte      ) );
}
#endif
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	MUQ_FATAL ("Needed mss!3");
    }
    #endif

    /* If there is no packet available to satisfy   */
    /* the request, maybe put current job to sleep: */
    if (src == dst
    ||  (no_fragments==OBJ_T && q->buf[src].done==OBJ_NIL)
    ){
/*if (src==dst) printf("src==dst\n");*/
/*else printf("no_fragments==OBJ_T && q->buf[src].done==OBJ_NIL\n");*/
	if (!ok_to_block)   return -1;
	mss_Readsleep( mss );	/* Doesn't return. */
    }

    /* Read src/msg from our inbuf slot: */
    *msg	 = q->buf[ src ];
#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
    printf("mss_Read/msg mss x=%llx:\n",mss);
    printf("   msg.loc d=%d\n",(int)(OBJ_TO_INT(msg->vec_loc)));
    printf("   msg.len d=%d\n",(int)(OBJ_TO_INT(msg->vec_len)));
}
#endif

    /* Copy message values into buffer: */
    {   /* Error if string is too long for buffer: */
        Vm_Int len = OBJ_TO_INT(msg->vec_len);
        Vm_Int loc = OBJ_TO_INT(msg->vec_loc);
	Vec_P  v   = VEC_P( vector );
	Vm_Obj*t   = &v->slot[0];

	/* Respect q->column, skip */
	/* over that many values:  */
	if (col
        &&  len >= col
        ){
	    len -= col;
	    loc += col;
	    if (loc >= v_len) {
		loc -= v_len;
	    }
	}

	/* If buflen==0, our caller wants us */
	/* to discard the packet contents:   */
	if (buflen) {
	    if (len > buflen) MUQ_WARN("msg too long to read?!");
	    if (len+loc <= v_len) {
		memcpy( buf, t+loc, len*sizeof(Vm_Obj)  );
	    } else {
		Vm_Int len0 = v_len - loc ;
		Vm_Int len1 =   len - len0;
		memcpy( buf     , t+loc, len0*sizeof(Vm_Obj) );
		memcpy( buf+len0, t    , len1*sizeof(Vm_Obj) );
	    }
#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
 int i;
 printf("mss_Read/mid mss x=%llx read %d values:\n",mss,(int)len);
 for (i = 0;   i < len; ++i) {
    Vm_Obj o = buf[i];
    if (OBJ_IS_CHAR(o)) printf(" %d: %c\n",i,(char)OBJ_TO_CHAR(o));
 }
}
#endif
	    values_transferred = len;

	    q  = MSS_P( mss ); /* Above VEC_P() may have trashed q. */
	}

	/* Mark our slot as read: */
	q->src       = OBJ_FROM_INT( src+1 & mask );

	/* Mark values as deleted from buffer: */
	q->vector_src = OBJ_FROM_INT( v_src+len & v_mask );

	/* Set column to zero: */
	q->column = OBJ_FROM_INT(0);

	/* Increment line number: */
	q->line   = OBJ_FROM_INT( OBJ_TO_INT(q->line) +1 );
    }

    vm_Dirty( mss );



    /* If mss was full before our read, */
    /* any jobs waiting to write to it  */
    /* should be moved to /etc/run:     */
    if (mss_was_full) {
	if (q->q_out != OBJ_FROM_INT(0)) {
            joq_Run_Queue( q->q_out );
    }   }

#ifdef OLD_DEBUG_STUFF
if (job_Reserved) {
    printf("mss_Read/bot mss x=%llx:\n",mss);
    printf("    src    x=%llx\n",OBJ_TO_INT( q->src        ) );
    printf("    dst    x=%llx\n",OBJ_TO_INT( q->dst        ) );
    printf("    col    x=%llx\n",OBJ_TO_INT( q->column     ) );
    printf("    vector x=%llx\n",vector );
    printf("    v_src  x=%llx\n",OBJ_TO_INT( q->vector_src ) );
    printf("    v_dst  x=%llx\n",OBJ_TO_INT( q->vector_dst ) );
    printf("    v_len  x=%llx\n",v_len  );
    printf("    t_src  x=%llx\n",OBJ_TO_INT( q->token_src ) );
    printf("    t_dst  x=%llx\n",OBJ_TO_INT( q->token_dst ) );
    printf("    line   x=%llx\n",OBJ_TO_INT( q->line      ) );
    printf("    byte   x=%llx\n",OBJ_TO_INT( q->byte      ) );
}
#endif
    return values_transferred;
}



/************************************************************************/
/*-    mss_Flush -- Mark last packet complete, if it isn't.		*/
/************************************************************************/

void
mss_Flush(
    Vm_Obj     mss
) {
    Mss_P       q = MSS_P( mss );

    Vm_Int    src = OBJ_TO_INT( q->src );
    Vm_Int    dst = OBJ_TO_INT( q->dst );
    Vm_Int   mask = OBJ_TO_INT( q->len ) -1;

    Vm_Int   last = (dst+mask & mask); /* Last packet in stream. */

    /* Nothing to do if no packets in stream: */
    if (src==dst)   return;

    /* If last packet is incomplete, mark it complete: */
    if (q->buf[last].done != OBJ_T) {
	q->buf[last].done  = OBJ_T;
	vm_Dirty(mss);

	/* If any readers were maybe waiting */
	/* for a complete packet, wake them: */
	if (q->q_in != OBJ_FROM_INT(0)) {
	    joq_Run_Message_Stream_Read_Queue( q->q_in, mss );
    }   }
}



/************************************************************************/
/*-    mss_Send_Would_Block -- TRUE iff attempt to write would block.	*/
/************************************************************************/

Vm_Int
mss_Send_Would_Block(
    Vm_Obj     mss,
    Vm_Int     values_to_write
) {
    Mss_P       q = MSS_P( mss );

    Vm_Int    src = OBJ_TO_INT( q->src );
    Vm_Int    dst = OBJ_TO_INT( q->dst );
    Vm_Int   mask = OBJ_TO_INT( q->len ) -1;
    Vm_Int  v_src = OBJ_TO_INT( q->vector_src );
    Vm_Int  v_dst = OBJ_TO_INT( q->vector_dst );
    Vm_Int  v_len = OBJ_TO_INT( q->vector_len );
/*  Vm_Int v_mask = v_len -1; */

    /* Figure free space in vector: */
    Vm_Int v_full = (v_src <= v_dst) ? (v_dst-v_src) : ((v_dst+v_len)-v_src);
    Vm_Int v_free = v_len - (v_full +1);
    Vm_Int result;

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	MUQ_FATAL ("Needed mss!4");
    }
    #endif

    /* Error if bytes_to_write can -never- fit, */
    /* remembering that we must always have one */
    /* unused slot in vector to avoid confusion */
    /* between full and empty vectors:          */
    if (values_to_write >= v_len) {
	MUQ_WARN ("Too many values for stream.");
    }

    result = ((dst+1 & mask) == src    ||  values_to_write > v_free);

    /* If stream is so full that it's messing writers up,   */
    /* mark first packet as complete, if it is not already: */
    if (result) {
	if (q->buf[src].done != OBJ_T) {
	    q->buf[src].done  = OBJ_T;
	    vm_Dirty(mss);

	    /* If any readers were maybe waiting */
	    /* for a complete packet, wake them: */
	    if (q->q_in != OBJ_FROM_INT(0)) {
		joq_Run_Message_Stream_Read_Queue( q->q_in, mss );
    }   }   }

    return result;
}



/************************************************************************/
/*-    mss_Maybe_SendSleep_Job -- Writesleep job if given mss is full.	*/
/************************************************************************/

void
mss_Maybe_SendSleep_Job(
    Vm_Obj     mss,
    Vm_Int     values_to_write
) {
    if (mss_Send_Would_Block( mss, values_to_write)) {

        Mss_P       q = MSS_P( mss );

	/* Create "out" job queue if it doesn't exist: */
	Vm_Obj joq = q->q_out;
	if (joq == OBJ_FROM_INT(0)) {
	    joq = joq_Alloc(mss,OBJ_FROM_BYT3('o','u','t'));/*Create joq.    */
	    q   = MSS_P( mss );		                    /*May have moved.*/
	    q->q_out = joq;
	    vm_Dirty(mss);
	}

	/* Move current job to job queue, */
        /* then switch to next job:       */
        joq_Requeue( joq, job_RunState.job );
	job_End_Timeslice();	/* Doesn't return. */
    }
}



/************************************************************************/
/*-    mss_Reset -- Reinitialize message stream.			*/
/************************************************************************/

void
mss_Reset(
    Vm_Obj o
) {
    Mss_P      p  = MSS_P(o);

    p->column       = OBJ_FROM_INT(0);
    p->line         = OBJ_FROM_INT(0);
    p->byte         = OBJ_FROM_INT(0);

    p->dst	  = OBJ_FROM_INT(   0 );
    p->src	  = OBJ_FROM_INT(   0 );

    p->vector_src = OBJ_FROM_INT( 0 );
    p->vector_dst = OBJ_FROM_INT( 0 );

    p->token_src  = OBJ_FROM_INT( 0 );
    p->token_dst  = OBJ_FROM_INT( 0 );

    p->q_in	  = OBJ_FROM_INT(   0 );
    p->q_out  = OBJ_FROM_INT(   0 );

    vm_Dirty( o );
}



/************************************************************************/
/*-    mss_Send -- Maybe append given src/msg pair to in_buf.		*/
/************************************************************************/

void
mss_Send(
    Vm_Obj     mss,
    Vm_Obj     who,
    Vm_Obj     tag,
    Vm_Obj     done,
    Vm_Obj*    buf,
    Vm_Int     buflen
) {
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	MUQ_FATAL ("Needed mss!5");
    }
    #endif

    /* If message stream is full, put current job to sleep: */
    mss_Maybe_SendSleep_Job( mss, buflen );

    {   Mss_P      q  = MSS_P( mss );

	Vm_Int  src   = OBJ_TO_INT( q->src );
	Vm_Int  dst   = OBJ_TO_INT( q->dst );
	Vm_Int mask   = OBJ_TO_INT( q->len ) -1;

	Vm_Obj vector =             q->vector      ;
/*	Vm_Int  v_src = OBJ_TO_INT( q->vector_src ); */
	Vm_Int  v_dst = OBJ_TO_INT( q->vector_dst );
	Vm_Int  v_len = OBJ_TO_INT( q->vector_len );
	Vm_Int v_mask = v_len -1;
	Vm_Int new_v_dst;
	Vm_Int prv    = (dst + mask) & mask;

	/* Remember whether stream was empty: */
	Vm_Int mss_was_empty = (src == dst);
	Vm_Int completed_a_packet = FALSE;


        /* Write msg into buffer: */
	if (mss_was_empty
	||  q->buf[ prv ].who  != who
	||  q->buf[ prv ].tag  != tag
	||  q->buf[ prv ].done != OBJ_NIL
	){
	    /* If previous packet wasn't done, */
	    /* mark it as done.  If it was     */
	    /* already done, or doesn't exist, */
	    /* no harm done:                   */
	    q->buf[ prv ].done    = OBJ_T;

	    /* May not concatenate this packet  */
	    /* onto last packet, so write a new */
	    /* packet:                          */
	    q->buf[ dst ].who     = who;
	    q->buf[ dst ].tag     = tag;
	    q->buf[ dst ].done    = done;
	    q->buf[ dst ].vec_loc = OBJ_FROM_INT( v_dst  );
	    q->buf[ dst ].vec_len = OBJ_FROM_INT( buflen );
	    new_v_dst      = v_dst+buflen & v_mask;
	    q->vector_dst  = OBJ_FROM_INT( new_v_dst );   

	    /* Mark our slot as written: */
	    q->dst        = OBJ_FROM_INT( dst+1 & mask );
	    vm_Dirty( mss );
	} else {

	    /* Concatenate this packet */
	    /* onto previous packet:   */
	    Vm_Int prvlen = OBJ_TO_INT( q->buf[ prv ].vec_len );
	    q->buf[ prv ].done    = done;
	    q->buf[ prv ].vec_len = OBJ_FROM_INT( prvlen+buflen );
	    new_v_dst      = v_dst+buflen & v_mask;
	    q->vector_dst  = OBJ_FROM_INT( new_v_dst );   

	    if (done == OBJ_T)  completed_a_packet = TRUE;

	    vm_Dirty( mss );
	}

        /* Write msg into buffer: */
	{   Vec_P   v = VEC_P( vector );
	    Vm_Obj* p = &v->slot[0];
	    if (new_v_dst >= v_dst) {
		memcpy( &p[v_dst], buf, buflen*sizeof(Vm_Obj) );
	    } else {
		/* We wrapped around end of string, */
		/* so we need to copy the two parts */
		/* separately:                      */
		Vm_Int len0 = v_len  - v_dst;
		Vm_Int len1 = buflen - len0 ;
		memcpy( p+v_dst, buf     , len0*sizeof(Vm_Obj) );
		memcpy( p      , buf+len0, len1*sizeof(Vm_Obj) );
	    }	    
	}


	/* If mss was empty before our write, */
	/* any jobs waiting to read from it   */
	/* should be moved to /etc/run:       */
	if (mss_was_empty || completed_a_packet){
	    q  = MSS_P( mss ); /* Above VEC_P may have invalidated 'q'. */
	    if (q->q_in != OBJ_FROM_INT(0)) {
		joq_Run_Message_Stream_Read_Queue( q->q_in, mss );
    }   }   }
}




/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    mss_Startup -- start-of-world stuff.				*/
/************************************************************************/

void mss_Startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

}



/************************************************************************/
/*-    mss_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void mss_Linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

}



/************************************************************************/
/*-    mss_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void mss_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

}



#ifdef OLD

/************************************************************************/
/*-    mss_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj mss_Import(
    FILE* fd
) {
    MUQ_FATAL ("mss_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    mss_Export -- Write object into textfile.			*/
/************************************************************************/

void mss_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("mss_Export unimplemented");
}


#endif

/************************************************************************/
/*-    mss_Invariants -- Sanity check on mss.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

Vm_Int mss_Invariants (
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
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    invariants -- Sanity check on mss.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int invariants(
    FILE* f,
    Vm_Uch* t,
    Vm_Obj mss
) {
#ifdef SOON
buggo
#endif
    return 0; /* Pacify gcc. */
}

#endif



/************************************************************************/
/*-    for_new -- Initialize message stream.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Vm_Obj     v = vec_Alloc( MSS_MAX_MSG_VECTOR, OBJ_FROM_INT(0) );

    {   Mss_P      p  = MSS_P(o);
	Vm_Obj     n  = OBJ_FROM_INT( MSS_MAX_MSG_Q );

	p->dead	  = OBJ_NIL;
	p->twin	  = o;

	p->dropped_packets = OBJ_FROM_INT(0);

	p->allow_reads  = OBJ_NIL;
	p->allow_writes = OBJ_NIL;

	p->column       = OBJ_FROM_INT(0);
	p->line         = OBJ_FROM_INT(0);
	p->byte         = OBJ_FROM_INT(0);

	p->len	  =                 n  ;

	p->dst	  = OBJ_FROM_INT(   0 );
	p->src	  = OBJ_FROM_INT(   0 );

	p->vector     = v;
	p->vector_src = OBJ_FROM_INT( 0 );
	p->vector_dst = OBJ_FROM_INT( 0 );
	p->vector_len = OBJ_FROM_INT( MSS_MAX_MSG_VECTOR );

	p->token_stg  = OBJ_NIL;
	p->token_src  = OBJ_FROM_INT( 0 );
	p->token_dst  = OBJ_FROM_INT( 0 );

	p->q_in	  = OBJ_FROM_INT(   0 );
	p->q_out  = OBJ_FROM_INT(   0 );

	p->input_string		= OBJ_NIL;
	p->input_string_cursor	= OBJ_FROM_INT(   0 );
	p->input_substitute	= OBJ_NIL;

	{   int i;
	    for (i = MSS_RESERVED_SLOTS;  i --> 0; ) p->reserved_slot[i] = OBJ_FROM_INT(0);
	}

	vm_Dirty( o );
    }

    #if MUQ_IS_PARANOID
    mss_Need_Power_Of_Two( "msg q len", MSS_MAX_MSG_Q      );
    mss_Need_Power_Of_Two( "msg v len", MSS_MAX_MSG_VECTOR );
    #endif
}



/************************************************************************/
/*-    sizeof_mss -- Return size of message stream.			*/
/************************************************************************/

static Vm_Unt
sizeof_mss(
    Vm_Unt size
) {
    return sizeof( Mss_A_Header );
}




/************************************************************************/
/*-    mss_allow_reads	             					*/
/************************************************************************/

static Vm_Obj
mss_allow_reads(
    Vm_Obj o
) {
    return MSS_P(o)->allow_reads;
}

/************************************************************************/
/*-    mss_allow_writes	             					*/
/************************************************************************/

static Vm_Obj
mss_allow_writes(
    Vm_Obj o
) {
    return MSS_P(o)->allow_writes;
}

/************************************************************************/
/*-    mss_column	             					*/
/************************************************************************/

static Vm_Obj
mss_column(
    Vm_Obj o
) {
    return MSS_P(o)->column;
}

/************************************************************************/
/*-    mss_byte		             					*/
/************************************************************************/

static Vm_Obj
mss_byte(
    Vm_Obj o
) {
    return MSS_P(o)->byte;
}

/************************************************************************/
/*-    mss_line		             					*/
/************************************************************************/

static Vm_Obj
mss_line(
    Vm_Obj o
) {
    return MSS_P(o)->line;
}

/************************************************************************/
/*-    mss_dead		             					*/
/************************************************************************/

static Vm_Obj
mss_dead(
    Vm_Obj o
) {
    return MSS_P(o)->dead;
}

/************************************************************************/
/*-    mss_twin		             					*/
/************************************************************************/

static Vm_Obj
mss_twin(
    Vm_Obj o
) {
    return MSS_P(o)->twin;
}

/************************************************************************/
/*-    mss_buffer_length              					*/
/************************************************************************/

static Vm_Obj
mss_buffer_length(
    Vm_Obj o
) {
    return MSS_P(o)->len;
}

/************************************************************************/
/*-    mss_input_string              					*/
/************************************************************************/

static Vm_Obj
mss_input_string(
    Vm_Obj o
) {
    return MSS_P(o)->input_string;
}

/************************************************************************/
/*-    mss_input_string_cursor         					*/
/************************************************************************/

static Vm_Obj
mss_input_string_cursor(
    Vm_Obj o
) {
    return MSS_P(o)->input_string_cursor;
}

/************************************************************************/
/*-    mss_input_substitute            					*/
/************************************************************************/

static Vm_Obj
mss_input_substitute(
    Vm_Obj o
) {
    return MSS_P(o)->input_substitute;
}

/************************************************************************/
/*-    mss_max_packet              					*/
/************************************************************************/

static Vm_Obj
mss_max_packet(
    Vm_Obj o
) {
    return OBJ_FROM_INT( OBJ_TO_INT( MSS_P(o)->vector_len ) -1 );
}

/************************************************************************/
/*-    mss_set_allow_reads 						*/
/************************************************************************/

static Vm_Obj
mss_set_allow_reads(
    Vm_Obj o,
    Vm_Obj v
) {
    MSS_P(o)->allow_reads = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_allow_writes 						*/
/************************************************************************/

static Vm_Obj
mss_set_allow_writes(
    Vm_Obj o,
    Vm_Obj v
) {
    MSS_P(o)->allow_writes = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_column	 						*/
/************************************************************************/

static Vm_Obj
mss_set_column(
    Vm_Obj o,
    Vm_Obj v
) {
    /* Ignore if not integer value: */
    if (OBJ_IS_INT(v)) {

	/* Ignore if stream is empty: */
	Mss_P  p = MSS_P(o);
	if (p->src != p->dst) {

	    /* Ignore if invalid offset into 'src' packet: */
	    Vm_Int src = OBJ_TO_INT( p->src );
	    Vm_Unt max = OBJ_TO_UNT( p->buf[ src ].vec_len );
	    Vm_Unt val = OBJ_TO_UNT(v);
	    if (val <= max) {

		/* Set column as given: */
		p->column = v;
		vm_Dirty(o);
    }   }   }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_byte	 						*/
/************************************************************************/

static Vm_Obj
mss_set_byte(
    Vm_Obj o,
    Vm_Obj v
) {
    /* Ignore if not integer value: */
    if (OBJ_IS_INT(v)) {

	Mss_P  p = MSS_P(o);

	/* Set byte as given: */
	p->byte = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_line	 						*/
/************************************************************************/

static Vm_Obj
mss_set_line(
    Vm_Obj o,
    Vm_Obj v
) {
    /* Ignore if not integer value: */
    if (OBJ_IS_INT(v)) {

	Mss_P  p = MSS_P(o);

	/* Set line as given: */
	p->line = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_dead	 						*/
/************************************************************************/

static Vm_Obj
mss_set_dead(
    Vm_Obj o,
    Vm_Obj v
) {
    MSS_P(o)->dead = OBJ_FROM_BOOL( v != OBJ_NIL );
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_twin	 						*/
/************************************************************************/

static Vm_Obj
mss_set_twin(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
        MSS_P(o)->twin = v;
        vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_input_string 						*/
/************************************************************************/

static Vm_Obj
mss_set_input_string(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL || stg_Is_Stg(v)) {
        MSS_P(o)->input_string = v;
        MSS_P(o)->input_string_cursor = OBJ_FROM_INT(0);
        vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_input_string_cursor					*/
/************************************************************************/

static Vm_Obj
mss_set_input_string_cursor(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL || OBJ_IS_INT(v)) {
        MSS_P(o)->input_string_cursor = v;
        vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_input_substitute						*/
/************************************************************************/

static Vm_Obj
mss_set_input_substitute(
    Vm_Obj o,
    Vm_Obj v
) {
  /*    if (v == OBJ_NIL || stg_Is_Stg(v)) { */
        MSS_P(o)->input_substitute = v;
        vm_Dirty(o);
  /*    } */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    mss_set_never	 						*/
/************************************************************************/

static Vm_Obj
mss_set_never(
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
