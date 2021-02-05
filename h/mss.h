
/*--   mss.h -- Header for mss.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_MSS_H
#define INCLUDED_MSS_H



/* Get Vm_* declarations: */
#include "vm.h"


/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"
#include "mss.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate an skt: */
#define MSS_P(o) ((Mss_Header)vm_Loc(o))

/* Default msg_q size in slots. */
/* Must be a power of two:      */
#ifndef MSS_MAX_MSG_Q
#define MSS_MAX_MSG_Q (32)
#endif

/* Default vector size in slots. */
/* Must be a power of two:       */
#ifndef MSS_MAX_MSG_VECTOR
#define MSS_MAX_MSG_VECTOR (4096)
#endif


/* Default token history buffer size in bytes. */
/* Must be a power of two:       */
#ifndef MSS_MAX_TOKEN_STRING
#define MSS_MAX_TOKEN_STRING (4*4096)
#endif

/* Two values returned to mss_Scan_Token(). */
/* These are not arbitrary values:          */
#define MSS_END_TOKEN_WITH_PREV_CHAR 1
#define MSS_END_TOKEN_WITH_THIS_CHAR 2

#define MSS_RESERVED_SLOTS 8

/************************************************************************/
/*-    types								*/


/************************************************************************/
/*-    Mss_A_Msg -- message stream cells.				*/

struct Mss_A_Msg_Rec {
    Vm_Obj	who;		/* Obj msg is to/from.			*/
    Vm_Obj      tag;		/* Optional message type.		*/
    Vm_Obj      done;		/* T unless text may be appended.	*/
    Vm_Obj      vec_loc;	/* Offset in vector.			*/
    Vm_Obj      vec_len;	/* #values in vector for this packet.	*/
};
typedef struct Mss_A_Msg_Rec  Mss_A_Msg;
typedef struct Mss_A_Msg_Rec*   Mss_Msg;



/* Our refinement of Obj_Header_Rec: */
struct Mss_Header_Rec {
    Obj_A_Header	o;

    /* 'dead' can be set non-NIL to  */
    /* prevent further traffic going */
    /* through the stream:           */
    Vm_Obj      dead;

    /* We implement bidirectional    */
    /* streams by using a pair of    */
    /* unidirectional streams, with  */
    /* 'twin' fields connecting them:*/
    Vm_Obj	twin;

    /* Count of packets dropped due to overflow */
    /* since last successful write to stream:   */
    Vm_Obj	dropped_packets;

    Vm_Obj	allow_reads;
    Vm_Obj	allow_writes;

    Vm_Obj	column;		/* Current offset within current packet.*/
    Vm_Obj	line;		/* Lines/packets read.			*/
    Vm_Obj	byte;		/* Bytes read.				*/

    /* Message streams are circular, */
    /* and empty when src==dst.      */
    Vm_Obj	len;		/* Physical size-in-packets of stream.	*/

    Vm_Obj	dst;		/* Next packet slot to write.		*/
    Vm_Obj	src;		/* Next packet slot to read.		*/

    /* Message vectors are circular, */
    /* and empty when src==dst.	     */
    Vm_Obj	vector;		/* Vector instance holding Vm_Objs.	*/
    Vm_Obj	vector_dst;	/* Next vector slot to write.		*/
    Vm_Obj	vector_src;	/* Next vector slot to read.		*/
    Vm_Obj	vector_len;	/* Physical capacity-in-slots of vector.*/

    /* Token buffers are circular,   */
    /* and empty when src==dst.      */
    Vm_Obj	token_stg;	/* String instance holding token chars.	*/
    Vm_Obj	token_dst;	/* Next string byte to write.		*/
    Vm_Obj	token_src;	/* Next string byte to read.		*/


    Vm_Obj      q_in;		/* Jobs waiting to read  message stream.*/
    Vm_Obj      q_out;		/* Jobs waiting to write message stream.*/

    Vm_Obj	input_string;	/* Reserved for compiling from strings.	*/
    Vm_Obj	input_string_cursor;	/* "                          " */
    Vm_Obj	input_substitute;	/* "                          " */

    Vm_Obj      reserved_slot[ MSS_RESERVED_SLOTS ];

    Mss_A_Msg   buf[ MSS_MAX_MSG_Q ];
};
typedef struct Mss_Header_Rec Mss_A_Header;
typedef struct Mss_Header_Rec*  Mss_Header;
typedef struct Mss_Header_Rec*  Mss_P;




/************************************************************************/
/*-    externs								*/

extern void    mss_Startup(  void                  );
extern void    mss_Linkup(   void              	   );
extern void    mss_Shutdown( void                  );
#ifdef OLD
extern Vm_Obj  mss_Import(   FILE* );
extern void    mss_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Int  mss_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void    mss_Print(     FILE*,Vm_Uch*,Vm_Obj);

extern Vm_Int  mss_Is_Full(       Vm_Obj            );
extern Vm_Int  mss_Can_Accept( Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj*,Vm_Int);
extern void    mss_Maybe_SendSleep_Job(Vm_Obj,Vm_Int);
extern Vm_Int  mss_Send_Would_Block( Vm_Obj, Vm_Int );

extern Vm_Int  mss_Peek( Mss_Msg, Vm_Obj            );
extern Vm_Int  mss_Read(Vm_Obj*,Vm_Int,Vm_Obj,Mss_Msg,Vm_Obj,Vm_Int);
extern void    mss_Send(         Vm_Obj, Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj*,Vm_Int );

extern Vm_Int  mss_Is_Empty( Vm_Obj );
extern void    mss_Flush( Vm_Obj );

extern Vm_Obj  mss_Readjoq( Vm_Obj );
extern void    mss_Need_Power_Of_Two( Vm_Uch*, Vm_Int );
extern Vm_Int  mss_Read_Value(Vm_Obj*,Vm_Obj*,Vm_Obj*,Vm_Obj);
extern void    mss_Unread_Value( Vm_Obj );
extern void    mss_Readsleep( Vm_Obj );
extern Vm_Int  mss_Scan_Token(
    Vm_Int*,Vm_Int*,Vm_Uch*,Vm_Int,Vm_Obj, Vm_Int (*fn)(Vm_Int)
);
extern Vm_Int  mss_Unread_Token_Char( Vm_Obj );
extern Vm_Int  mss_Read_Token( Vm_Uch*, Vm_Int, Vm_Obj, Vm_Int, Vm_Int );
extern void    mss_Reset( Vm_Obj );
extern Obj_A_Hardcoded_Class mss_Hardcoded_Class;
extern Obj_A_Module_Summary  mss_Module_Summary;


/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_MSS_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

