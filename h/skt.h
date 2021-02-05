/*--   skt.h -- Header for skt.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_SKT_H
#define INCLUDED_SKT_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include <stdio.h>
#include "vm.h"
#include "obj.h"
#include "mss.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Basic macro to locate an skt: */
#define SKT_P(o) ((Skt_Header)vm_Loc(o))

/* Types of skts supported: */
#define SKT_TYPE_BAT OBJ_FROM_BYT3('b','a','t')	/* Stdin/out, batch fileset.*/
#define SKT_TYPE_TTY OBJ_FROM_BYT3('t','t','y')	/* Stdin/out, interactive.  */
#define SKT_TYPE_TCP OBJ_FROM_BYT3('t','c','p')	/* Net stream socket.	    */
#define SKT_TYPE_UDP OBJ_FROM_BYT3('u','d','p')	/* Net datagram socket.	    */
#define SKT_TYPE_EOF OBJ_FROM_BYT3('e','o','f')	/* Dead skt.		    */
#define SKT_TYPE_EAR OBJ_FROM_BYT3('e','a','r')	/* Listening skt.	    */
#define SKT_TYPE_SRV OBJ_FROM_BYT3('s','r','v')	/* Popen'd subserver.	    */

/* Number of slots specifying event to signal      */
/* when a char is detected in the input buffer.    */
/* We currently make this 256 so that any possible */
/* input byte can be signalled.                    */
#define SKT_CHAR_EVENT_MAX 256

#define SKT_RESERVED_SLOTS 16

/************************************************************************/
/*-    types								*/
/************************************************************************/

/********************************************************/
/* Naming conventions are derived from a job's view 	*/
/* of the world: 'src' is stuff being read from msss,	*/
/* and 'dst' is stuff being written to msss.		*/
/*							*/
/* An skt is regarded as a deviant job reading from	*/
/* and writing to msss -- it just happens that the	*/
/* intervening processing is done remotely instead of	*/
/* locally -- so 'src' is stuff	read by us by msss	*/
/* and headed for the net, while 'dst' is stuff we got	*/
/* from the net and are sending to msss.		*/
/********************************************************/

/* Our refinement of Obj_Header_Rec: */
struct Skt_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj typ;		/* One of SKT_TYPE_*.			*/
    Vm_Obj buf_no;	/* Our index in skt_buffer_ary.		*/

    Vm_Obj standard_input;  /* We read from this stream.	*/
    Vm_Obj standard_output; /* We write to  this stream.	*/

    Vm_Obj out_of_band_input; /* We read from this stream.	*/
    Vm_Obj out_of_band_output;/* We write to  this stream.	*/

    Vm_Obj out_of_band_job;   /* Job on above two streams.	*/

    Vm_Obj telnet_option_lock;   /* Lock for access to *telnet_state. */
    Vm_Obj telnet_option_handler;/* 256-slot vector of compiled-functions.*/
    Vm_Obj this_telnet_state;/* 256byte string of option states.*/
    Vm_Obj that_telnet_state;/* 256byte string of option states.*/

    Vm_Obj session;	    /* Session associated with netport.	*/

    Vm_Obj closed_by;	    /* :close :signal or :exit		*/
    Vm_Obj exit_status;	    /* NIL else an integer		*/
    Vm_Obj last_signal;     /* NIL else an integer		*/

    Vm_Obj dst_filters;	/* Bitmask.				*/
    Vm_Obj src_filters;	/* Bitmask.				*/

    Vm_Obj kill_standard_output_on_exit;

    Vm_Obj reserved_slot[ SKT_RESERVED_SLOTS ];

    /* Event to send when finding char: */
    Vm_Obj char_event[ SKT_CHAR_EVENT_MAX ];
};
typedef struct Skt_Header_Rec Skt_A_Header;
typedef struct Skt_Header_Rec*  Skt_Header;
typedef struct Skt_Header_Rec*  Skt_P;



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern Vm_Int skt_Maybe_Do_Some_IO( Vm_Int );
extern void   skt_Activate( Vm_Obj, Vm_Obj,   Vm_Int,Vm_Int        );
extern void   skt_Open(  Vm_Obj,Vm_Uch*,Vm_Int,Vm_Int,Vm_Int,Vm_Unt );
extern void   skt_Popen( Vm_Obj,Vm_Uch*,Vm_Int,Vm_Int );
extern void   skt_Listen(   Vm_Obj,    Vm_Int,Vm_Int,Vm_Int,Vm_Int );
extern void   skt_Close(    Vm_Obj );
extern void   skt_Child_Changed( Vm_Int, Vm_Int );
extern void   skt_Replace(Vm_Obj,Vm_Obj);

extern int    skt_Invariants(FILE*,char*,Vm_Obj);
extern void   skt_Print(     FILE*,char*,Vm_Obj);
extern void   skt_Startup( void              );
extern void   skt_Linkup(  void              );
extern void   skt_Shutdown(void              );
extern void   skt_Mark(void);
#ifdef OLD
extern Vm_Obj skt_Import(   FILE* );
extern void   skt_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Int skt_Select_Sockets( fd_set*,fd_set*,fd_set*,Vm_Int );
extern Vm_Obj skt_Nth_Active_Socket( Vm_Int );

extern Obj_A_Hardcoded_Class skt_Hardcoded_Class;
extern Obj_A_Module_Summary  skt_Module_Summary;

extern Vm_Uch** skt_Bat_Files;
extern Vm_Int   skt_Is_Closing_Down;
extern Vm_Int   skt_Select_Calls_Made;
extern Vm_Int skt_Blocking_Select_Calls_Made;
extern Vm_Int skt_Nonblocking_Select_Calls_Made;
extern Vm_Int skt_Select_Calls_Interrupted;
extern Vm_Int skt_Select_Calls_With_No_Io;
extern int    skt_All_Sockets( int (*fn)( void*, Vm_Obj),  void*  fa );

/* Spot for SKT_TYPE_BAT skts     */
/* to longjmp to at end of files: */
#include <setjmp.h>
extern jmp_buf  skt_Bat_Longjmp_Buf;





/************************************************************************/
/*-    File variables							*/
/************************************************************************/

#endif /* INCLUDED_SKT_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

