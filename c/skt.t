@example  @c
/* ftp.psy.uq.oz.au in /pub/Crypto -- public SSL layer */
/* Build SSLeay (the library) and SSLtelnet */
/*--   skt.c -- Socket objects for Muq.					*/
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
/* Created:      93Aug26						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-1996, by Jeff Prothero.				*/
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
/*-    Epigram								*/
/************************************************************************/

/*
 *             "For Zeus, who guided men to think,
 *              has laid it down, that wisdom comes
 *              alone through suffering."
 *                                  -- Aeschylus
 */

/************************************************************************/
/*-    Quote								*/
/************************************************************************/

/*
 * "[We want] the  WIN32 layer to be fairly mediocre in performance
 *  and feature coverage.  We want it to be just good/cheap/timely
 *  enough to get a lot of people to use it. [...] we don't want it
 *  to work too well."
 *    -- internal Microsoft 1996 email from the Bristol vs MS trial.
 */

/************************************************************************/
/*-    Quote								*/
/************************************************************************/

/*
 * "All the best people in life seem to like Linux."
 *       -- Steve Wozniak
 */

/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/************************************************************************

This module implements almost all of Muq's communication with the
external world.  Each skt (socket) instance implements one
bidirectional stream of bytes/strings headed to and from the Muq.
Normally these are mostly tcp connections, but we also treat the
controlling console (for example) as just an additional type of
socket, and in additional we support udp sockets, sockets listening
for new tcp connections, and sockets talking to local unix processes
via pipes.

The important components of a skt are:

   Internal information telling the skt what sort of socket it is.
   A dst_byt buffer for raw bytes read from net;
   A dst_msg_q buffer for net->muq text
   A src_msg_q buffer for muq->net text;
   A src_byt buffer for raw bytes headed for net;
   Any private state required.

The dst_byt buffer is primarily a place in which to assemble a complete
line, since socket input arrives in unpredictable size pieces; when a
full line is assembled (or buffer limit is reached), the line is
copied to the in-db buffer in dst_msg_q.

The src_byt buffer is primarily a place in which to do such filtering
as expanding '\n' chars to "\r\n" sequences before write()ing.

Since all net I/O _has_ to go through this module, we keep it
as policy-free as practical; things such as welcome messages, site
registration, connect logging and so forth should ideally all be
handled internally by easy-to-customize in-db muq code.

 ************************************************************************/

/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Tunable parameters: */

/* Maximum number of live streams to support. */
/* Buggo, should allow unlimited number.     */
#ifndef SKT_MAX_STREAMS
#define SKT_MAX_STREAMS (2048)
#endif

/* Bytesize of our input buffers.  This is	*/
/* basically the longest input line allowed:	*/
/* Needs to be at least half MSS_MAX_MSG_VECTOR */
/* to avoid possible deadlock:                  */
#define SKT_DST_BYT_SIZ (MSS_MAX_MSG_VECTOR)

/* Bytesize of our output buffers: */
/* Needs to be at least half MSS_MAX_MSG_VECTOR */
/* to avoid possible deadlock:                  */
#define SKT_SRC_BYT_SIZ (MSS_MAX_MSG_VECTOR)



/* Default job-control strings: */

#ifndef SKT_STP_SEQ
#define SKT_STP_SEQ "@Z"
#endif

#ifndef SKT_INT_SEQ
#define SKT_INT_SEQ "@Q"
#endif

#ifndef SKT_QIT_SEQ
#define SKT_QIT_SEQ "@D"
#endif




/* Stuff you shouldn't need to fiddle with: */

/* Names for the TELNET protocol commands we need: */
#define SKT_TELNET_SUBOPTION_END   240 /* "SE" */
#define SKT_TELNET_DATA_MARK       242 /* The data stream part of a Synch. */
                                       /*  This should always be accompanied */
                                       /* by a TCP Urgent notification. */
#define SKT_TELNET_SUBOPTION_BEGIN 250 /* "SB" */
#define SKT_TELNET_IS_A_COMMAND    255
#define SKT_TELNET_ERASE_CHAR      247
#define SKT_TELNET_ERASE_LINE      248



/* 'src_filters' and 'dst_filters' bits. */
/* Must NOT use 0x01, since we're using  */
/* in-db format ints for the bitmaps and */
/* must not step on the type bit:        */
#define SKT_FILTER_NONE		(0x00)	/* Allow full 8bit binary. 	*/
#define SKT_PASS_NONPRINTING	(0x02)	/* 7-bit ascii w/o ESC etc.	*/
#define SKT_FILTER_BY_LINES	(0x04)	/* Attempt to read whole lines.	*/
#define SKT_FILTER_CRNL		(0x08)	/* Translate \r\n <--> \n.	*/
#define SKT_JOB_CONTROL		(0x10)	/* @Q @Z @D processing.		*/
#define SKT_TELNET_PROTOCOL	(0x20)	/* IAC processing.		*/

/* The traditional muck filtering: */
#ifndef SKT_FILTER_TRADITIONAL
#define SKT_FILTER_TRADITIONAL	( \
    SKT_FILTER_CRNL		| \
    SKT_FILTER_BY_LINES		| \
    SKT_TELNET_PROTOCOL		| \
    SKT_JOB_CONTROL		)
#endif


/* Values for b->skt_state, used when */
/* shutting down a subprocess:        */
#ifdef OLD
#define SKT_OPEN             0
#define SKT_CLOSED           1
#define SKT_SENT_HUP         2
#define SKT_SENT_KILL9       3
#define SKT_READ_NET_EOF     4
#else
#define SKT_OPEN                0
#define SKT_CLOSED              1
#define SKT_DRAINING_OUTPUT     2
#define SKT_WAITING_TO_READ_EOF 3
#define SKT_SENT_HUP            4
#define SKT_SENT_KILL           5
#define SKT_DRAINING_INPUT      6
#endif

#ifndef SKT_OUTDRAIN_MILLISECONDS
#define SKT_OUTDRAIN_MILLISECONDS 600000
#endif

#ifndef SKT_EOFWAIT_MILLISECONDS
#define SKT_EOFWAIT_MILLISECONDS 600000
#endif

#ifndef SKT_HUPWAIT_MILLISECONDS
#define SKT_HUPWAIT_MILLISECONDS 600000
#endif

#ifndef SKT_KILLWAIT_MILLISECONDS
#define SKT_KILLWAIT_MILLISECONDS 600000
#endif

#ifndef SKT_INDRAIN_MILLISECONDS
#define SKT_INDRAIN_MILLISECONDS 600000
#endif


/****************************************************/
/* The skt_state Transition Diagram looks like:     */
/*						    */
/* Note: Receiving a SIGCHLD signal indicating that */
/* our child process has died does not directly     */
/* change our skt_state, we just set that_pid == 0. */
/* This is because I'm presuming there may still be */
/* kernel-buffered output from the child waiting to */
/* be read at that point, and that we'll get an EOF */
/* in due course when we reach the end of it. Thus, */
/* the only change we need to make is to remember   */
/* not to bother trying to kill the child.          */
/*						    */
/* Note: UDP, BAT and TTY sockets have a much	    */
/* simpler transition diagram:  We just nuke 	    */
/* them as soon as we get a reason to close them,   */
/* without waiting to flush anything either         */
/* direction.  Possibly this is a bit too brutal...   

     UNDEFINED
         |muf open
         V
       OPEN
         +------>------------------------------------->+
         |After muf close or      After reading net EOF|
         |finding dead input mss                       |
         V					       |
   DRAINING_OUTPUT				       |
         |After OUTDRAIN_MILLISECONDS or empty outbuf, |
         |and then closing output		       |
         V					       |
   WAITING_TO_READ_EOF				       V
         +------>-------------->+		       |
         |After reading EOF or  |After EOFWAIT_MSECS   |
         |after EOFWAIT_MSECS   |and then sending HUP  |
         |when that_pid==0      V		       |
         V                   SENT_HUP		       |
         +<--------------<------+		       |
         |  After reading EOF   |After HUPWAIT_MSECS   |
         |  or if that_pid==0   |and then sending KILL |
         |                      V		       |
         V                  SENT_KILL		       V
         +<--------------<------+<--------------<------+
         |  After reading EOF or
         |  or if that_pid==0 or
         |  after KILLWAIT_MILLISECONDS
         |  and then closing input
         V
   DRAINING_INPUT
         |After INDRAIN_MILLISECONDS or empty inbuffer
         V
       CLOSED
	 |As soon as CLOSED is noticed
         V
     UNDEFINED


/*   skt_state of a dead socket is undefined --  */
/*   the variable doesn't exist.                 */
/*						 */
/*   In all transitions to state UNDEFINED,	 */
/*   if skt->kill_stdout_on_exit is set, Muq	 */
/*   sets skt%S/standardOutput%S/dead.  This    */
/*   allows jobs reading from a socket to keep	 */
/*   processing until they read NIL, and thus	 */
/*   finish all output from the socket before	 */
/*   closing down.				 */
/*						 */
/* UNDEFINED -> OPEN				 */
/*   skt_Activate, called whenever a socket is	 */
/*   opened in some way, sets skt_state to       */
/*   SKT_OPEN.	 The socket stays in this state	 */
/*   until it is time to start shutting down.    */
/*   Completion of socket shutdown is marked     */
/*   by setting skt_state to SKT_CLOSED, at      */
/*   which point it is ok to free the buffer     */
/*   and mark the socket as dead:  Other states  */
/*   mark intermediate stages in the shutdown.   */
/*						 */
/* OPEN -> UNDEFINED				 */
/*   When a MUF call closes a socket and there	 */
/*   is no associated (popen()ed) unix process,	 */
/*   the socket is immediately closed, buffers	 */
/*   freed, and the socket marked dead.		 */
/*						 */
/* OPEN -> CLOSED				 */
/*   When Muq reads an EOF from a socket,	 */
/*   it will normally mark the socket as	 */
/*   CLOSED via skt_usually_start_closing_socket()*/
/*   (This also sends an internal muq broken-pipe*/
/*   signal to the session_leader.) An exception */
/*   is type==BAT sockets which are reading a    */
/*   sequence of files:  If more files remain,   */
/*   such a socket just opens the next file.     */
/*     Muq will also mark an OPEN socket as      */
/*   CLOSED if it encounters any write error     */
/*   other than EWOULDBLOCK.			 */
/*						 */
/* CLOSED -> UNDEFINED				 */
/*   When Muq notices (during a Maybe_Do_Some_IO */
/*   call) that a socket is CLOSED, it recycles  */
/*   the buffer and marks the socket dead.	 */
/*						 */
/* OPEN -> SENT_HUP				 */
/*   When a MUF call closes a socket and there	 */
/*   is an associated (popen()ed) unix process,	 */
/*   Muq sends a HUP (hang-up) signal to that	 */
/*   process to tell it to exit, and sets 	 */
/*   skt_state to SENT_HUP.			 */
/*						 */
/* SENT_HUP -> READ_NET_EOF			 */
/*   Normally, a subprocess should respond to    */
/*   a HUP signal by wrapping up and exiting,    */
/*   which should result in job.t getting a      */
/*   SIGCHLD signal and calling skt_Child_Changed*/
/*   which will in turn set skt_state to         */
/*   READ_NET_EOF. (skt_Child_Changed() will     */
/*   will set skt_state to READ_NET_EOF both     */
/*   both when the child exits voluntarily, and  */
/*   when it is killed by a signal, but records  */
/*   the difference by setting either exit_status*/
/*   or last_signal.)                            */
/*						 */
/* SENT_HUP -> SENT_KILL9			 */
/*   When Muq notices (during a Maybe_Do_Some_IO */
/*   call) that MILLISECONDS_OF_GRACE msecs have */
/*   elapsed since sending the subprocess a HUP  */
/*   (hang-up) signal, it sends a KILL signal    */
/*   and enters SENT_KILL9 state.  This is an    */
/*   abnormal error-recovery path used when      */
/*   the above SENT_HUP -> READ_NET_EOF          */
/*   fails to happen as expected.                */
/*						 */
/* SENT_KILL9 -> READ_NET_EOF			 */
/*   Normally, a subprocess should respond to    */
/*   a KILL signal by immediately dying:  There  */
/*   is no way for a process to catch this       */
/*   signal.  job.t:sig_chld() should then get a */
/*   SIGCHLD signal and call skt_Child_Changed   */
/*   which will in turn set skt_state to         */
/*   READ_NET_EOF.				 */
/*						 */
/* READ_NET_EOF -> UNDEFINED		 	 */
/*   When Muq notices (during a Maybe_Do_Some_IO */
/*   call) that a socket has READ_NET_EOF,       */
/*   it recycles the buffer and marks the socket */
/*   dead.					 */
/*						 */
/* SENT_KILL9 -> UNDEFINED			 */
/*   When Muq notices (during a Maybe_Do_Some_IO */
/*   call) that MILLISECONDS_OF_GRACE msecs have */
/*   elapsed since sending the subprocess a KILL */
/*   (hang-up) signal, it goes ahead and recycles*/
/*   the buffer and marks the socket as dead     */
/*   even in the absence of a SIGCHLD confirming */
/*   death of child.  This is an abnormal        */
/*   error-recovery path which one hopes not to  */
/*   see often, but I've seen instances of unix  */
/*   processes which are not zombies but which   */
/*   ignore KILL signals for hours on end, on    */
/*   a very lightly loaded machine...            */
/*************************************************/


/* We give subprocesses awhile to exit    */
/* after sending them HUP, but eventually */
/* nuke them with a kill -9.  Define how  */
/* many seconds they get between the two: */
#ifdef OLD
#ifndef SKT_MILLISECONDS_OF_GRACE
#define SKT_MILLISECONDS_OF_GRACE 30000
#endif
#endif


/************************************************************************/
/*-    Types								*/
/************************************************************************/

/* Type containing an internet address (32 bits): */
typedef unsigned long Skt_ip_addr;

/* 'src' == muq -> net. */
/* 'dst' == muq <- net. */

/* Type of an input buffer: */
struct Skt_buffer_rec {
    struct Skt_buffer_rec * next;
    Vm_Obj		    skt;	/* Our obj half.		*/
    Vm_Int		    skt_state;	/* SKT_OPEN/CLOSED/SENT_HUP...	*/
    Vm_Int		    started_waiting_at; /*Time state was entered*/
    Vm_Int		    discard_netbound_data;/* TRUE/FALSE.	*/
    Vm_Obj		    typ;	/* Same as typ in skt proper.	*/

    /* These are mirrors of the in-db */
    /* fields of the same name:       */
    Vm_Obj		    src_filters;/* in SKT_FILTER_*.		*/
    Vm_Obj		    dst_filters;/* in SKT_FILTER_*.		*/

    Vm_Int		    n;		/* Our slot in skt_buffer_ary[].*/

    Vm_Int		    src_nxt;	/* First invalid src_byt[] idx.	*/
    Vm_Uch 		    src_byt[ SKT_SRC_BYT_SIZ ];

    Vm_Int		    dst_nxt;	/* First invalid dst_byt[] idx.	*/
    Vm_Uch 		    dst_byt[ SKT_DST_BYT_SIZ ];

    Vm_Int		    src_fd;	/* Fd to write.			*/
    Vm_Int		    dst_fd;	/* Fd to read.			*/
					/* src_fd==dst_fd for sockets.	*/
    Vm_Int		    this_port;	/* Port on near end of connect.	*/
    Vm_Int		    that_port;	/* Port on far  end of connect.	*/

    Vm_Int		    that_pid;	/* Child pid for pipe sockets.	*/

    Vm_Int		    last_errno;	/* 0 or errno from last I/O err */
    Vm_Int		    error_count;

    /* Some tweakable timeout constants: */
    Vm_Int outdrain_milliseconds;
    Vm_Int eofwait_milliseconds;
    Vm_Int hupwait_milliseconds;
    Vm_Int killwait_milliseconds;
    Vm_Int indrain_milliseconds;


    /* Current plans (RFC 1752) seem to be for  */
    /* 16-byte IP addresses in the next major   */
    /* TCP/IP release. So we reserve space here */
    /* for four four-byte values but at present */
    /* use only that_ip[3]:                     */
    Vm_Unt		    that_ip[4];	/* Internet address for far end.*/

    /* Machine which sent last UDP datagram recvfrom'd net: */
    Vm_Int		    recv_port;
    Vm_Unt		    recv_ip[4];

    Vm_Uch*		    prefix;	/* Prefix to all output.	*/
    Vm_Uch*		    suffix;	/* Suffix to all output.	*/
};
typedef struct Skt_buffer_rec Skt_a_buffer;
typedef struct Skt_buffer_rec*  Skt_buffer;



/************************************************************************/
/*-    Statics								*/
/************************************************************************/


#if MUQ_DEBUG
static Vm_Int   invariants(FILE*,char*,Vm_Obj);
#endif

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_skt( Vm_Unt );
static Vm_Unt   buf_alloc(  Vm_Obj, Vm_Obj );
static Vm_Int   buf_first_nl( Vm_Uch*, Vm_Uch* );
static Vm_Int   doing_metadata( Vm_Int*, Skt_buffer );
#ifdef CURRENTLY_UNUSED
static void     buf_logically_close( Vm_Unt );
#endif
static void     buf_physically_close_all_marked_sockets( void );
static void     buf_physically_close_one_socket( Skt_buffer );
#ifdef CURRENTLY_UNUSED
static void     buf_physically_close_all_sockets( void );
#endif
static void     buf_reset( Vm_Unt );

#ifdef OLD
static Vm_Int   kill_nonprinting_chars( Vm_Uch*, Vm_Int );
#endif
static Vm_Int   nl_to_crnl( Vm_Uch*, Vm_Int );
static Vm_Int   ff_to_ffff( Vm_Uch*, Vm_Int );

static Vm_Obj	skt_last_error(     Vm_Obj  );
static Vm_Obj	skt_last_errno(     Vm_Obj  );
static Vm_Obj	skt_error_count(    Vm_Obj  );

static Vm_Obj	skt_by_lines_i(     Vm_Obj  );
static Vm_Obj	skt_filter_cr_i(    Vm_Obj  );
static Vm_Obj	skt_filter_cr_o(    Vm_Obj  );
static Vm_Obj	skt_kill_stdout_on_exit( Vm_Obj );
static Vm_Obj	skt_pass_nonprint_from_net( Vm_Obj  );
static Vm_Obj	skt_pass_nonprint_to_net(   Vm_Obj  );
static Vm_Obj	skt_session(	    Vm_Obj  );
static Vm_Obj	skt_type(           Vm_Obj  );
static Vm_Obj	skt_this_port(      Vm_Obj  );
static Vm_Obj	skt_that_port(      Vm_Obj  );
static Vm_Obj	skt_that_address(   Vm_Obj  );
static Vm_Obj	skt_ip0(       	    Vm_Obj  );
static Vm_Obj	skt_ip1(            Vm_Obj  );
static Vm_Obj	skt_ip2(            Vm_Obj  );
static Vm_Obj	skt_ip3(            Vm_Obj  );
static Vm_Obj	skt_closed_by(      Vm_Obj  );
static Vm_Obj	skt_exit_status(    Vm_Obj  );
static Vm_Obj	skt_last_signal(    Vm_Obj  );
static Vm_Obj	skt_discard_netbound_data( Vm_Obj  );
static Vm_Obj	skt_standard_input( Vm_Obj  );
static Vm_Obj	skt_standard_output(Vm_Obj  );
static Vm_Obj	skt_out_of_band_input(Vm_Obj);
static Vm_Obj	skt_out_of_band_output(Vm_Obj);
static Vm_Obj	skt_telnet_protocol(Vm_Obj  );
static Vm_Obj	skt_out_of_band_job(Vm_Obj  );
static Vm_Obj	skt_telnet_option_handler(Vm_Obj);
static Vm_Obj	skt_telnet_option_lock(Vm_Obj);
static Vm_Obj	skt_this_telnet_state(Vm_Obj);
static Vm_Obj	skt_that_telnet_state(Vm_Obj);
static Vm_Obj	skt_that_pid(         Vm_Obj);
static Vm_Obj	skt_fd_to_read(     Vm_Obj  );
static Vm_Obj	skt_fd_to_write(    Vm_Obj  );

static Vm_Obj	skt_outdrain_milliseconds( Vm_Obj  );
static Vm_Obj	skt_eofwait_milliseconds(  Vm_Obj  );
static Vm_Obj	skt_hupwait_milliseconds(  Vm_Obj  );
static Vm_Obj	skt_killwait_milliseconds( Vm_Obj  );
static Vm_Obj	skt_indrain_milliseconds(  Vm_Obj  );

static Vm_Obj	skt_set_outdrain_milliseconds( Vm_Obj,Vm_Obj  );
static Vm_Obj	skt_set_eofwait_milliseconds(  Vm_Obj,Vm_Obj  );
static Vm_Obj	skt_set_hupwait_milliseconds(  Vm_Obj,Vm_Obj  );
static Vm_Obj	skt_set_killwait_milliseconds( Vm_Obj,Vm_Obj  );
static Vm_Obj	skt_set_indrain_milliseconds(  Vm_Obj,Vm_Obj  );

static Vm_Obj	skt_set_by_lines_i( Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_filter_cr_i(Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_filter_cr_o(Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_kill_stdout_on_exit(Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_pass_nonprint_from_net( Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_pass_nonprint_to_net( Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_session(    Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_standard_input(     Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_standard_output(    Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_out_of_band_input(       Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_out_of_band_output(      Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_discard_netbound_data( Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_telnet_protocol(    Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_out_of_band_job(         Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_telnet_option_handler(Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_telnet_option_lock( Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_this_telnet_state(  Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_that_telnet_state(  Vm_Obj, Vm_Obj );
static Vm_Obj	skt_set_never(      Vm_Obj, Vm_Obj );



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property skt_system_properties[] = {

    /* Include properties require on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"discardNetboundData", skt_discard_netbound_data, skt_set_discard_netbound_data},
    {0,"errorCount"	   , skt_error_count	, skt_set_never		},
    {0,"killStandardOutputOnExit",skt_kill_stdout_on_exit, skt_set_kill_stdout_on_exit },
    {0,"lastErrno"	   , skt_last_errno	, skt_set_never		},
    {0,"lastError"	   , skt_last_error	, skt_set_never		},
    {0,"nlToNetCrnl"    , skt_filter_cr_o	, skt_set_filter_cr_o	},
    {0,"netCrnlToNl"    , skt_filter_cr_i	, skt_set_filter_cr_i	},
    {0,"passNonprintingFromNet", skt_pass_nonprint_from_net, skt_set_pass_nonprint_from_net},
    {0,"passNonprintingToNet",skt_pass_nonprint_to_net, skt_set_pass_nonprint_to_net},
    {0,"inputByLines"    , skt_by_lines_i     , skt_set_by_lines_i	},
    {0,"session"           , skt_session        , skt_set_session	},
    {0,"standardInput"    , skt_standard_input , skt_set_standard_input},
    {0,"standardOutput"   , skt_standard_output, skt_set_standard_output},
    {0,"outOfBandJob"   , skt_out_of_band_job, skt_set_out_of_band_job},
    {0,"outOfBandInput" , skt_out_of_band_input, skt_set_out_of_band_input},
    {0,"outOfBandOutput", skt_out_of_band_output,skt_set_out_of_band_output},
    {0,"telnetOptionHandler",skt_telnet_option_handler,skt_set_telnet_option_handler},
    {0,"telnetOptionLock", skt_telnet_option_lock,skt_set_telnet_option_lock},
    {0,"telnetProtocol"   , skt_telnet_protocol, skt_set_telnet_protocol},
    {0,"thisTelnetState" , skt_this_telnet_state,skt_set_this_telnet_state},
    {0,"thatTelnetState" , skt_that_telnet_state,skt_set_that_telnet_state},
    {0,"thatPid"          , skt_that_pid       , skt_set_never		},
    {0,"thisPort"         , skt_this_port	, skt_set_never		},
    {0,"thatPort"         , skt_that_port	, skt_set_never		},
    {0,"closedBy"         , skt_closed_by	, skt_set_never		},
    {0,"exitStatus"       , skt_exit_status	, skt_set_never		},
    {0,"lastSignal"       , skt_last_signal	, skt_set_never		},
    {0,"thatAddress"      , skt_that_address	, skt_set_never		},
    {0,"ip0"		   , skt_ip0		, skt_set_never		},
    {0,"ip1"		   , skt_ip1		, skt_set_never		},
    {0,"ip2"		   , skt_ip2		, skt_set_never		},
    {0,"ip3"		   , skt_ip3		, skt_set_never		},
    {0,"type"	           , skt_type		, skt_set_never		},
    {0,"fdToRead"        , skt_fd_to_read	, skt_set_never		},
    {0,"fdToWrite"       , skt_fd_to_write	, skt_set_never		},

    {0,"outdrainMilliseconds" , skt_outdrain_milliseconds, skt_set_outdrain_milliseconds},
    {0,"eofwaitMilliseconds"  , skt_eofwait_milliseconds , skt_set_eofwait_milliseconds },
    {0,"hupwaitMilliseconds"  , skt_hupwait_milliseconds , skt_set_hupwait_milliseconds },
    {0,"killwaitMilliseconds" , skt_killwait_milliseconds, skt_set_killwait_milliseconds},
    {0,"indrainMilliseconds"  , skt_indrain_milliseconds , skt_set_indrain_milliseconds },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class skt_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','k','t'),
    "Socket",
    sizeof_skt,
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
    { skt_system_properties, skt_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void skt_doTypes(void){}
Obj_A_Module_Summary skt_Module_Summary = {
   "skt",
    skt_doTypes,
    skt_Startup,
    skt_Linkup,
    skt_Shutdown,
};

/* Set TRUE by z-muq.t before making the */
/* final skt_Maybe_Do_Some_IO() call.    */
/* This lets us skip useless work at     */
/* shutdown, such as sending signals to  */
/* jobs that will never run again.  At   */
/* one point we were crashing due to     */
/* trying to signal no longer runnable   */
/* jobs...                               */
Vm_Int skt_Is_Closing_Down = FALSE;

/* Count of select calls made, published */
/* by muq.t, mostly for debugging:       */
Vm_Int skt_Select_Calls_Made;

/* More such counts: */
Vm_Int skt_Blocking_Select_Calls_Made;
Vm_Int skt_Nonblocking_Select_Calls_Made;
Vm_Int skt_Select_Calls_Interrupted;
Vm_Int skt_Select_Calls_With_No_Io;

/* Our array and list of input buffers: */
static Skt_buffer skt_buffer_ary[ SKT_MAX_STREAMS ];
static Skt_buffer skt_buffer_lst = NULL; /* See also skt_listeners. */

/* Our linklist of ports we're listening on: */
static Skt_buffer skt_listeners  = NULL;

/* Our linklist of ports we're doing UDP on: */
static Skt_buffer skt_udp_sockets = NULL;



/* Maximum known fd, needed because select()    */
/* wants a (0,max) range of fds to check:	*/
static Vm_Int skt_max_known_descriptor = 0;

static Vm_Int skt_need_to_close_some_sockets = FALSE;


/* This is a quick, ugly hack to let z_muf */
/* redirect a series of files through an   */
/* skt to support running test suites.     */
/* List of files for SKT_TYPE_BAT skt      */
/* to read:                                */
Vm_Uch** skt_Bat_Files;
jmp_buf  skt_Bat_Longjmp_Buf;

/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    skt_Maybe_Do_Some_IO -- Service network sockets (etc).		*/
/************************************************************************/

static Vm_Int did_some_io;	/* Private to this fold.		*/
static Vm_Int did_a_select;	/* Private to this fold.		*/


 /***********************************************************************/
 /*-   skt_read_tcp_message_streams -- skt->src_msg_q to b->src_byt[].	*/
 /***********************************************************************/

/********************************************/
/* Here we translate text headed for tcp    */
/* ports into binary form suitable to write,*/
/* by copying contents of mss objects into  */
/* byte buffers, expanding \n to \r\n and   */
/* removing nonprinting characters and so   */
/* forth as we do so:                       */
/********************************************/

  /**********************************************************************/
  /*-  skt_read_a_tcp_message_stream -- skt->src_msg_q to b->src_byt[].	*/
  /**********************************************************************/

static void
skt_read_a_tcp_message_stream(
    Skt_buffer b,
    Vm_Int     telnet	/* TRUE to do oob_input, FALSE for standard_input */
) {
    Vm_Obj obj_buf[ MSS_MAX_MSG_VECTOR ];

    Vm_Obj skt             = b->skt;
    Vm_Obj input  = (
	telnet                        ?
	SKT_P(skt)->out_of_band_input :
	SKT_P(skt)->standard_input
    );

    /* Haven't removed any text from this skt's src_msg_q yet: */
    Vm_Int read_from_input = FALSE;

/*printf("skt_read_a_tcp_message_stream/top: input x=%x\n",input);*/
    /* If skt hasn't been initialized yet, */
    /* input may not exist:       */
    if (!OBJ_IS_OBJ(       input )
    ||  !OBJ_IS_CLASS_MSS( input )
    ){
	return;
    }

    /* Check for dead input stream: */
    if (MSS_P(input)->dead != OBJ_NIL) {
/*printf("skt_read_a_tcp_message_stream/top: input x=%x is DEAD\n",input);*/

	/* Start closing down socket: */
	if (b->skt_state == SKT_OPEN) {
/*printf("skt_read_a_tcp_message_stream() --> DRAINING_OUTPUT\n");*/
	    b->skt_state  = SKT_DRAINING_OUTPUT;
	    b->started_waiting_at = OBJ_TO_INT( job_RunState.now );
	}
	return;
    }

    /* While more than one byte of space left */
    /* in src_byt and text left in src_msg_q: */
    for (;;) {

	/* Break if less than two bytes of free space: */
	Mss_A_Msg msg;
	Vm_Int buf_bytes_free = SKT_SRC_BYT_SIZ - b->src_nxt;
/*printf("skt_read_a_tcp_message_stream/luptop: buf_bytes_free x=%x\n",buf_bytes_free);*/
/*printf("skt_read_a_tcp_message_stream/luptop: b->src_nxt x=%x\n",b->src_nxt);*/
	if (buf_bytes_free <= 1)           break;

	/* Break if no text to read: */
	if (!mss_Peek( &msg, input )) {
/*printf("skt_read_a_tcp_message_stream/lup: no text to read\n");*/
	    break;
	}

	{   Vm_Int src_bytes  = OBJ_TO_INT( msg.vec_len );
	    Vm_Int bytes      = buf_bytes_free;

	    if (b->src_filters & (SKT_FILTER_CRNL|SKT_TELNET_PROTOCOL)) {
		/* Fill up to half of remaining buffer space */
		/* (since \n -> \r\n expansion may double    */
		/* size of copied string):                   */
		bytes >>= 1;
	    }

	    /* Break if msg is too big to fit in buffer: */
	    if (src_bytes > bytes) {
/*printf("skt_read_a_tcp_message_stream/lup: msg too big to fit\n");*/
		break;
	    }

	    /* Copy message: */
	    if (bytes > MSS_MAX_MSG_VECTOR)   bytes = MSS_MAX_MSG_VECTOR;
	    bytes = mss_Read(
		obj_buf,	/* Where to put values.	  */
		bytes,		/* Max values to put.	  */
		OBJ_NIL,	/* Allow reading partial packets. */
		&msg,
		input,
		TRUE		/* ok_to_block		  */
	    );

	    /* Copy values from obj_buf[] to */
	    /* b->src_byt[], converting from */
	    /* Vm_Obj to Vm_Uch as we go and */
	    /* dropping non-char values:     */
	    {   Vm_Int cat = 0;
		Vm_Int rat = 0;
		Vm_Uch*dst = &b->src_byt[ b->src_nxt ];
		Vm_Obj val;
		if (!b->discard_netbound_data) {
		    while (rat < bytes) {
			val = obj_buf[ rat++ ];
			if (OBJ_IS_CHAR(val)) dst[ cat++ ] = OBJ_TO_CHAR(val);
		    }
		}
		bytes = cat;
	    }
	    read_from_input = TRUE;

	    if (!telnet) {
		/* Maybe expand \n -> \r\n: */
		if (b->src_filters & SKT_FILTER_CRNL) {
		    bytes    = nl_to_crnl( &b->src_byt[ b->src_nxt ], bytes );
		}

		/* Maybe expand FF -> FF FF: */
		if (b->src_filters & SKT_TELNET_PROTOCOL) {
		    bytes    = ff_to_ffff( &b->src_byt[ b->src_nxt ], bytes );
		}

		/* Maybe filter various chars: */
/* buggo? This looks like the correct place to do */
/* this, and that it isn't being done at present. */
#ifdef OLD
		if (!(b->src_filters & SKT_PASS_NONPRINTING)) {
/*printf("skt_read_tcp_message_streams killing nonprints (%x->fltrs %x)...\n",b,b->src_filters);*/
		    bytes    = kill_nonprinting_chars(
			&b->src_byt[ b->src_nxt ], bytes
		    );
		}
#endif
	    }

	    /* Remember new buffer length: */
	    b->src_nxt  += bytes;
	}
    }

    /* Wake any jobs that might have */
    /* been waiting for output room: */
    if (read_from_input) {
	Vm_Obj q_out = MSS_P( input )->q_out;
	if (q_out != OBJ_FROM_INT(0)) {
	    joq_Run_Queue( q_out );
	}
    }
}

  /**********************************************************************/
  /*-  skt_read_tcp_message_streams -- skt->src_msg_q to b->src_byt[].	*/
  /**********************************************************************/

static void
skt_read_tcp_message_streams(
    void
) {
    /* Over all active tcp streams: */
    Skt_buffer b;
    for (b = skt_buffer_lst;   b;   b = b->next) {

	if (b->src_filters & SKT_TELNET_PROTOCOL) {
	    skt_read_a_tcp_message_stream( b, /*telnet:*/ TRUE  );
	}

	skt_read_a_tcp_message_stream( b, /*telnet:*/ FALSE );
    }
}

 /***********************************************************************/
 /*-   skt_read_udp_message_streams -- skt->src_msg_q to b->src_byt[].	*/
 /***********************************************************************/

/********************************************/
/* Here we translate text headed for udp    */
/* ports into binary form suitable to write,*/
/* by copying contents of mss objects into  */
/* byte buffers, expanding \n to \r\n and   */
/* removing nonprinting characters and so   */
/* forth as we do so:                       */
/********************************************/

static void
skt_read_udp_message_streams(
    void
) {
    Vm_Obj obj_buf[ MSS_MAX_MSG_VECTOR ];

    /* Over all active udp streams: */
    Skt_buffer b;
    for (b = skt_udp_sockets;   b;   b = b->next) {

        Vm_Obj skt             = b->skt;
	Vm_Obj standard_input  = SKT_P(skt)->standard_input;

	/* Haven't removed any text from this skt's src_msg_q yet: */
	Vm_Int read_from_stdin = FALSE;

	/* If skt hasn't been initialized yet, */
	/* standard_input may not exist:       */
	if (!OBJ_IS_OBJ(       standard_input )
	||  !OBJ_IS_CLASS_MSS( standard_input )
	){
	    continue;
	}

	/* We need to maintain datagram boundaries, */
	/* and our buffer structure isn't currently */
	/* set up to do this, so for now at least   */
	/* we limit buffer to holding one datagram: */
	if (b->src_nxt)   continue;
	{
	    Mss_A_Msg msg;
	    Vm_Int buf_bytes_free = SKT_SRC_BYT_SIZ;

	    /* Break if no text to read from: */
	    if (!mss_Peek( &msg, standard_input ))   break;

	    {   Vm_Int bytes      = buf_bytes_free >> 1;
		Vm_Int src_bytes  = OBJ_TO_INT( msg.vec_len );

		/* If we're doing \n -> \r\n expansion,  */
		/* treat buffer as half as big, since in */
		/* the worst case (datagram of nothing   */
		/* but '\n's) we'll need double the ram: */
		if (b->src_filters & SKT_FILTER_CRNL)   bytes >>= 1;

		/* Drop datagram  if too big to fit in buffer: */
/* buggo, be nice to issue an error message somehow. */
/* But the sending job doesn't even have to exist!   */
/* Maybe should write something to logfile?          */
		if (src_bytes > bytes) {
		    bytes = mss_Read(
			NULL,		/* Where to put values.	  */
			0,		/* Max values to put.	  */
			OBJ_T,		/* Disallow reading partial packets. */
			&msg,
			standard_input,
			TRUE		/* ok_to_block		  */
		    );
		} else {
		    /* Copy message: */
		    if (bytes > MSS_MAX_MSG_VECTOR) {
			bytes = MSS_MAX_MSG_VECTOR;
		    }
		    bytes = mss_Read(
			obj_buf,	/* Where to put values.	  */
			bytes,		/* Max values to put.	  */
			OBJ_T,		/* Disallow reading partial packets. */
			&msg,
			standard_input,
			TRUE		/* ok_to_block		  */
		    );
		}
		/* Copy values from obj_buf[] to */
		/* b->src_byt[], converting from */
		/* Vm_Obj to Vm_Uch as we go and */
		/* dropping non-char values,     */
		/* except that we need to catch  */
		/* :ip0 :ip1 :ip2 :ip3 :port     */
		/* keywords when they have int   */
		/* values:                       */
		{   Vm_Int cat = 0;
		    Vm_Int rat = 0;
		    Vm_Int seen_ip0  = FALSE;
		    Vm_Int seen_ip1  = FALSE;
		    Vm_Int seen_ip2  = FALSE;
		    Vm_Int seen_ip3  = FALSE;
		    Vm_Int seen_port = FALSE;
		    Vm_Uch*dst = &b->src_byt[ b->src_nxt ];
		    Vm_Obj val;
		    Vm_Int ip3;
		    if (!b->discard_netbound_data) {
			while (rat < bytes) {

			    val = obj_buf[ rat++ ];

			    if (OBJ_IS_CHAR(val)) {

				dst[ cat++ ] = OBJ_TO_CHAR(val);

			    } else if (OBJ_IS_SYMBOL(val)) {

				if (!seen_ip0
				&& val == job_Kw_Ip0
				&& OBJ_IS_INT(obj_buf[rat])
				){
				    seen_ip0 = TRUE;
				    val = (OBJ_TO_INT(obj_buf[rat++])&0xFF) << 24;
				    ip3 = (b->that_ip[3]             &~0xFF000000);
				    b->that_ip[3] = (ip3 | val);

				} else if (!seen_ip1
				&& val == job_Kw_Ip1
				&& OBJ_IS_INT(obj_buf[rat])
				){
				    seen_ip1 = TRUE;
				    val = (OBJ_TO_INT(obj_buf[rat++])& 0xFF) << 16;
				    ip3 = (b->that_ip[3]             &~0x00FF0000);
				    b->that_ip[3] = (ip3 | val);

				} else if (!seen_ip2
				&& val == job_Kw_Ip2
				&& OBJ_IS_INT(obj_buf[rat])
				){
				    seen_ip2 = TRUE;
				    val = (OBJ_TO_INT(obj_buf[rat++])& 0xFF) <<  8;
				    ip3 = (b->that_ip[3]             &~0x0000FF00);
				    b->that_ip[3] = (ip3 | val);

				} else if (!seen_ip3
				&& val == job_Kw_Ip3
				&& OBJ_IS_INT(obj_buf[rat])
				){
				    seen_ip3 = TRUE;
				    val = (OBJ_TO_INT(obj_buf[rat++])& 0xFF);
				    ip3 = (b->that_ip[3]             &~0x000000FF);
				    b->that_ip[3] = (ip3 | val);

				} else if (!seen_port
				&& val == job_Kw_Port
				&& OBJ_IS_INT(obj_buf[rat])
				){
				    seen_port    = TRUE;
				    b->that_port = OBJ_TO_INT(obj_buf[rat++]);
				}
			    }
			}
		    }
		    bytes = cat;
		}
		read_from_stdin = TRUE;

		/* Maybe expand \n -> \r\n: */
		if (b->src_filters & SKT_FILTER_CRNL) {
		    bytes    = nl_to_crnl( &b->src_byt[ b->src_nxt ], bytes );
		}

#ifdef OLD
/* buggo? This looks like the correct place to do */
/* this, and that it isn't being done at present. */
		/* Maybe filter various chars: */
		if (!(b->src_filters & SKT_PASS_NONPRINTING)) {
		    bytes    = kill_nonprinting_chars(
			&b->src_byt[ b->src_nxt ], bytes
		    );
		}
#endif

		/* Remember new buffer length: */
		b->src_nxt  += bytes;
            }
        }

	/* Wake any jobs that might have */
	/* been waiting for output room: */
	if (read_from_stdin) {
	    Vm_Obj q_out = MSS_P( standard_input )->q_out;
	    if (q_out != OBJ_FROM_INT(0)) {
		joq_Run_Queue( q_out );
	    }
	}
    } /* All stream buffers */
}



 /***********************************************************************/
 /*-   skt_maybe_do_some_socket_io --					*/
 /***********************************************************************/


 /***********************************************************************/
 /*-   skt_handle_closing_socket --					*/
 /***********************************************************************/

static void
skt_handle_closing_socket(
    Skt_buffer b
){
    /*****************************************/
    /* See the skt_state Transition Diagram. */
    /*****************************************/

    /* Handle popen()ed subjobs which */
    /* are being closed down:         */
    Vm_Int now = OBJ_TO_INT( job_RunState.now );

#ifndef OLD
    switch (b->skt_state) {

    case SKT_DRAINING_OUTPUT:
/*printf("skt_handle_closing_socket closing b->src_fd d=%d (SRV) %x\n",b->src_fd,b->skt);*/
	if (b->src_fd == -1) {
	    /* No output channel at all, so */
	    /* we want to skip closing it   */
	    /* and waiting to read an EOF   */
	    /* back in response, and just   */
	    /* send a HUP immediately.      */
	    b->skt_state = SKT_WAITING_TO_READ_EOF;

	    /* A hack so we'll send HUP without */
	    /* first waiting SKT_EOFWAIT_MILLISECONDS:  */
	    b->started_waiting_at = (now - b->eofwait_milliseconds) +1;
	    skt_handle_closing_socket( b );
	    return;
	}
	if ( - b->started_waiting_at > b->outdrain_milliseconds
	|| !b->src_nxt       /* Output buffer empty.      */
	){
	    if (b->src_fd != -1) {
		if (b->typ == SKT_TYPE_SRV) {
		    /* Pipes have separate fd for each   */
		    /* direction, so a simple close()    */
		    /* suffices to close only output:    */
/*printf("skt_handle_closing_socket closing b->src_fd d=%d (SRV) %x\n",b->src_fd,b->skt);*/
		    close( b->src_fd );
		} else {
		    /* Sockets have a single fd for both */
		    /* directions, so a simple close()   */
		    /* won't close only output. But with */
		    /* shutdown() we can close half:     */
		    shutdown( b->src_fd, 1 ); /* 0==input_only 2==both. */
/*printf("skt_handle_closing_socket closing b->src_fd d=%d (!SRV) %x\n",b->src_fd,b->skt);*/
/*printf("skt_handle_closing_socket         b->dst_fd d=%d %x\n",b->dst_fd,b->skt);*/
	    }	}

	    /* Remember that we've closed output: */
	    b->src_fd = -1;

	    /* If we have an input channel, wait  */
	    /* to get an EOF on it.  If we do not */
	    /* have an input, we -still- need to  */
	    /* go to this state, so that we'll    */
	    /* kill the child process if we don't */
	    /* get a SIGCHLD announcing its death */
	    /* in a timely manner:                */
/*printf("skt_handle_closing_socket: DRAINING_OUTPUT -> WAITING_TO_READ_EOF %x\n",b->skt);*/
	    b->skt_state = SKT_WAITING_TO_READ_EOF;

	    b->started_waiting_at = now;
	}
	return;

    case SKT_WAITING_TO_READ_EOF:
	if (now - b->started_waiting_at > b->eofwait_milliseconds) {
	    if (!b->that_pid) {
/*printf("skt_handle_closing_socket: WAITING_TO_READ_EOF -> DRAINING_INPUT %x\n",b->skt);*/
		b->skt_state = SKT_DRAINING_INPUT;
		b->started_waiting_at = now;
		return;
	    }
	    kill( b->that_pid, SIGHUP );
/*printf("skt_handle_closing_socket: WAITING_TO_READ_EOF -> SENT_HUP %x\n",b->skt);*/
	    b->skt_state = SKT_SENT_HUP;
	    b->started_waiting_at = now;
	}
	return;

    case SKT_SENT_HUP:
	if (!b->that_pid) {
/*printf("skt_handle_closing_socket: SENT_HUP -> DRAINING_INPUT %x\n",b->skt);*/
	    b->skt_state = SKT_DRAINING_INPUT;
	    b->started_waiting_at = now;
	    return;
	}
	if (now - b->started_waiting_at > b->hupwait_milliseconds) {
/*printf("skt_handle_closing_socket: SENT_HUP -> SENT_KILL %x\n",b->skt);*/
	    kill( b->that_pid, SIGKILL );
	    b->skt_state = SKT_SENT_KILL;
	    b->started_waiting_at = now;
	}
	return;

    case SKT_SENT_KILL:
	if (!b->that_pid) {
/*printf("skt_handle_closing_socket: SENT_KILL -> DRAINING_INPUT I %x\n",b->skt);*/
	    b->skt_state = SKT_DRAINING_INPUT;
	    b->started_waiting_at = now;
	    return;
	}
	if (now - b->started_waiting_at > b->killwait_milliseconds) {
	    if (b->dst_fd != -1) {
/*printf("skt_handle_closing_socket/SENT_KILL: closed b->dst_fd d=%d\n",b->dst_fd);*/
		close( b->dst_fd );
		b->dst_fd = -1;
	    }
/*printf("skt_handle_closing_socket: SENT_KILL -> DRAINING_INPUT II %x\n",b->skt);*/
	    b->skt_state = SKT_DRAINING_INPUT;
	    b->started_waiting_at = now;
	}
	return;

    case SKT_DRAINING_INPUT:
	if (now - b->started_waiting_at > b->indrain_milliseconds
	|| !b->dst_nxt   /* input buffer empty */
	){  
/*printf("skt_handle_closing_socket: now d=%d b->started_waiting_at d=%d time(NULL) d=%d\n",now,b->started_waiting_at,time(NULL));*/
/*printf("skt_handle_closing_socket: DRAINING_INPUT -> CLOSED %x\n",b->skt);*/
/*if (now - b->started_waiting_at > b->indrain_milliseconds)*/
/*printf("  because %d second wait-time is up (%d bytes left)\n",b->indrain_milliseconds,b->dst_nxt);*/
/*else*/
/*printf("  because buffer now empty\n");*/
	    b->skt_state = SKT_CLOSED;
	    b->started_waiting_at = now;
/*printf("  skt_handle_closing_socket: DRAINING_INPUT -> CLOSED setting skt_need_to_close_some_sockets=TRUE\n");*/
	    skt_need_to_close_some_sockets = TRUE;
	}
	return;

    case SKT_CLOSED:
/*printf("skt_handle_closing_socket: CLOSED %x\n",b->skt);*/
	/* We leave actual physical closure to        */
	/* buf_physically_close_all_marked_sockets(): */
	return;

    default:
	MUQ_FATAL ("skt_handle_closing_socket");
    }
#else
    switch (b->skt_state) {

    case SKT_SENT_HUP:
	if (now - b->started_waiting_at > SKT_MILLISECONDS_OF_GRACE) {
	    /* No more Mr Nice Guy: */
	    if (b->that_pid) kill( b->that_pid, SIGKILL );
	    b->closed = SKT_SENT_KILL9;
	    b->started_waiting_at = now;
	}
	break;

    case SKT_SENT_KILL9:
	if (now - b->started_waiting_at <= SKT_MILLISECONDS_OF_GRACE) {
	    break;
	}
	/* Weirdness -- even a kill -9 isn't  */
	/* having any effect.  Wash our hands */
	/* of it by   FALLING THROUGH:        */
    case SKT_READ_NET_EOF:
#ifdef OLD
	{   Skt_P s = SKT_P(b->skt);
	    s->typ   = SKT_TYPE_EOF;
	    s->buf_no= OBJ_FROM_INT(-1);
	    vm_Dirty(b->skt);
	}
#endif
/*printf("skt_handle_closing_socket calling buf_physically_close_one_socket...\n");*/
	buf_physically_close_one_socket( b );
    }
#endif
}

 /***********************************************************************/
 /*-   skt_pick_sockets_to_select --					*/
 /***********************************************************************/

static void
skt_pick_sockets_to_select(
    fd_set *sockets_to_read,
    fd_set *sockets_to_write,
    fd_set *sockets_to_check	/* For exceptional conditions. */
) {

    /****************************************************/
    /* The focal point of this module is the select()	*/
    /* call which picks which socket to read() or	*/
    /* write() next, if any.  select() needs to know	*/
    /* which sockets we are _willing_ to read() or	*/
    /* write currently, and takes a pair of bitmaps	*/
    /* (skt_sockets_to_read and skt_sockets_to_write)	*/
    /* which contain this information.			*/
    /*							*/
    /* Here we fill in these bitmaps:			*/
    /****************************************************/

    /* First, zero out all bitmaps: */
    FD_ZERO( sockets_to_read  );
    FD_ZERO( sockets_to_write );
    FD_ZERO( sockets_to_check );

/*printf("skt_pick_sockets_to_select...\n");*/
    /* We're willing to read on all listen ports */
    /* unless the mss for that port is full:     */
    {   Skt_buffer b;
	for (b = skt_listeners;   b;   b = b->next) {
	    if (!mss_Is_Full( SKT_P(b->skt)->standard_output )) {
/*printf("picking listener %d to read...\n",b->dst_fd);*/
		FD_SET( b->dst_fd, sockets_to_read );
    }   }   }

    /* We're willing to read a UDP socket only   */
    /* if the buffer is empty, since we support  */
    /* only one packet at a time in the buffer:  */
    {   Skt_buffer b;
	for (b = skt_udp_sockets; b;   b = b->next) {
#ifdef OLD
	    if (!b->dst_nxt   &&   b->skt_state == SKT_OPEN) {
#else
	    if (!b->dst_nxt   &&   b->dst_fd != -1) {
#endif
/*printf("picking UDP %d to read...\n",b->dst_fd);*/
		FD_SET( b->dst_fd, sockets_to_read );
    }   }   }

    /* We can write a UDP socket iff the buffer  */
    /* is not empty, since it must then contain  */
    /* exactly one datagram to send:             */
    {   Skt_buffer b;
	for (b = skt_udp_sockets; b;   b = b->next) {
	    if (b->src_nxt > 0   &&   b->src_fd != -1) {
/*printf("picking UDP %d to write...\n",b->src_fd);*/
		FD_SET( b->src_fd, sockets_to_write );
    }   }   }

    /* We're always willing to read on an  */
    /* open tcp, unless dst_byt[] is full  */
    /* or it is in DRAINING_INPUT CLOSED   */
    /* state -- reading them leads to      */
    /* busywait loops:                     */
    /* Over all active i/o streams: */
    {   Skt_buffer b;
        Skt_buffer b_next;
        for (b = skt_buffer_lst;   b;   b = b_next) {
	    b_next = b->next;	/* b may get deleted. */
/*printf("skt_pick_sockets_to_select: b (%p)->skt_state %x\n",b,b->skt_state);*/
            if (b->skt_state != SKT_OPEN) {
/*printf("skt_pick_sockets_to_select: b (%p)->skt_state %x so calling handle_closing_socket\n",b,b->skt_state);*/
		skt_handle_closing_socket( b );
		if (b->skt_state == SKT_CLOSED
		||  b->skt_state == SKT_DRAINING_INPUT
		){
		    continue;
		}
	    }
/*printf("skt_pick_sockets_to_select: b (%p)->dst_nxt x=%x\n",b,b->dst_nxt);*/
/*printf("skt_pick_sockets_to_select: b (%p)->dst_fd  x=%x\n",b,b->dst_fd);*/
	    if (b->dst_nxt < SKT_DST_BYT_SIZ
	    &&  b->dst_fd != -1
	    ){
/*printf("picking TCP %d to read...\n",b->dst_fd);*/
		FD_SET( b->dst_fd, sockets_to_read );
    }   }   }

    /* We're always willing to write to  */
    /* a tcp, unless src_byt[] is empty: */
    /* Over all active i/o streams: */
    {   Skt_buffer b;
        for (b = skt_buffer_lst;   b;   b = b->next) {
	    if (b->src_nxt > 0
            &&  b->src_fd != -1
	    ){
/*printf("picking TCP %d to write...\n",b->src_fd);*/
		FD_SET( b->src_fd, sockets_to_write );
    }   }   }
}



 /***********************************************************************/
 /*-   skt_Select_Sockets --						*/
 /***********************************************************************/

/************************************************************************/
/* From popiel@hollerith.colorado.edu  Thu Dec  8 13:54:12 1994		*/
/*									*/
/* First off, note that the value returned by select() (to indicate	*/
/* the number of active file descriptors) varies from OS to OS; many	*/
/* OSs return the number separate descriptors active, while others	*/
/* return the sum of the number of bits set in the in/out parameters	*/
/* indicating which descriptors are active for each of read, write,	*/
/* or exception (possibly counting a single descriptor more than	*/
/* once).								*/
/************************************************************************/

Vm_Int
skt_Select_Sockets(
    fd_set *sockets_to_read,
    fd_set *sockets_to_write,
    fd_set *sockets_to_check,
    Vm_Int  usec	/* Max microseconds to sleep during select(). */
) {
    #ifdef SOMETIMES_USEFUL
    Vm_Int start_date = job_Now();
    #endif

    /* Translate time-to-sleep into select-compatible form: */

    struct timeval    max_sleep;
    max_sleep.tv_sec  = usec / 1000000;
    max_sleep.tv_usec = usec % 1000000;

    /* Om... */
    ++skt_Select_Calls_Made;
    if (usec)      ++skt_Blocking_Select_Calls_Made;
    else	++skt_Nonblocking_Select_Calls_Made;
    did_a_select = TRUE;
/*if (usec)printf("%lld skt_Select_Sockets usec lld=%lld\n",sys_Muq_Port,usec);*/
    if (-1 == select(
	    /* The three (void*)s below are because HP/UX (for example) */
	    /* has a select() prototype declaring the args as (int*)    */
	    /* instead of (fd_set*), POSIX or no POSIX.  By casting to	*/
	    /* (void*) we avoid compiletime warnings about these args:	*/
	    skt_max_known_descriptor+1,	/* Check fds less than this.	*/
	    (void*) sockets_to_read,	/* Ok to read from these fds.	*/
	    (void*) sockets_to_write,	/* Ok to write to  these fds.	*/
	    (void*) NULL,		/* Ignore exceptional conditions*/
	   &max_sleep			/* Block up to this long waiting*/
    )   ) {				/* for input. (NULL==forever.)	*/
	/* Ick, something went wrong.	*/
	/* If it was just a signal	*/
	/* happening to hit while we	*/
	/* were in select(), ignore	*/
	/* it, else we'd best die:	*/
	if (errno == EINTR) {
/*if (usec)printf("skt_Select_Sockets back I\n");*/
	    ++skt_Select_Calls_Interrupted;
	    return FALSE;
	}
/*printf("skt_max_known_descriptor d=%d\n",skt_max_known_descriptor);*/
        #ifdef HAVE_STRERROR
	MUQ_FATAL ("Err during select(): %s",strerror(errno));
        #else
	MUQ_FATAL ("Err %d during select()",errno);
	#endif
    }
/*if (usec)printf("skt_Select_Sockets back II\n");*/

    #ifdef SOMETIMES_USEFUL
    {   Vm_Int end_date = job_Now();
	Vm_Int duration = end_date-start_date;
	if (duration > 10) {
	    lib_Log_Printf(
		"skt_Select_Sockets: Spent %" VM_D " millisecs in select().\n",
		duration
	    );
	}
    }
    #endif

    return TRUE;
}



 /***********************************************************************/
 /*-   skt_do_selected_sockets --					*/
 /***********************************************************************/


  /**********************************************************************/
  /*-  skt_accept_connect_request --					*/
  /**********************************************************************/


   /*********************************************************************/
   /*- skt_set_fd_nonblocking --					*/
   /*********************************************************************/

static void
skt_set_fd_nonblocking(
    Vm_Int fd
) {
    Vm_Int err = fcntl( fd, F_SETFL, AC_FCNTL_SET_NONBLOCKING );
    if    (err == -1) {
        MUQ_FATAL ("Couldn't set socket nonblocking!");
    }
}

   /*********************************************************************/
   /*- skt_accept_connect_request --					*/
   /*********************************************************************/

static void
skt_accept_connect_request(
    Skt_buffer r
) {
    /* Ignore connect if the message stream */
    /* designated to receive new connects  */
    /* is full:                            */
    if (!mss_Is_Full( SKT_P(r->skt)->standard_output )) {

	/* Accept the connection reqest, getting back */
	/* a new fd on which to communicate:	  */
	struct sockaddr_in         server_address;
	struct sockaddr_in         client_address;
	int    addr_size = sizeof( client_address );
	Vm_Int fd        = accept(
	    r->dst_fd,
	    (struct sockaddr*) &client_address,
	    &addr_size
	);
	if (fd == -1) {
	    /************************************************/
	    /* This should normally be due to		    */
	    /* errno==EMFILE: per-process fd table full; or */
	    /* errno==ENFILE: system      fd table full; or */
	    /* errno==EINTR : signal in middle of accept(): */
	    /************************************************/
	    if (errno != EMFILE
	    &&  errno != ENFILE
	    &&  errno != EINTR
	    #ifdef ECONNRESET
	    &&  errno != ECONNRESET
	    #endif
	    ){
		#ifdef HAVE_STRERROR
		MUQ_FATAL ("Err during accept(): %s",strerror(errno));
		#else
		MUQ_FATAL ("Err %d during accept()",errno);
		#endif
	    }
	    return;
	}
        obj_NoteDateAsRandomBits();

	/* Record local port number too, just in */
	/* case someone looks at the property:   */
	addr_size = sizeof( server_address );
	if (0 > getsockname(
		r->dst_fd,
		(struct sockaddr*) &server_address,
		&addr_size
	    )
	) {
	    r->last_errno = errno;
	    ++ r->error_count;

	    MUQ_WARN ("getsockname() failed");
	}

	skt_set_fd_nonblocking( fd );

	/* Create a skt+buffer pair: */
	/* Buggo? Should we create the socket in some particular dbfile? */
	{   Vm_Obj skt = obj_Alloc( OBJ_CLASS_A_SKT, 0 );
	    skt_Activate( skt,
		SKT_TYPE_TCP,	/* Type of skt (network).	*/
		fd,		/* The write() fd for this skt.	*/
		fd		/* The read()  fd for this skt.	*/
	    );

	    /* Record client_address info: */
	    {   Skt_buffer b = skt_buffer_ary[OBJ_TO_INT(SKT_P(skt)->buf_no)];
		b->this_port = (Vm_Unt) ntohs(server_address.sin_port);
		b->that_port = (Vm_Unt) ntohs(client_address.sin_port);
		b->that_ip[3]= (Vm_Unt) ntohl(client_address.sin_addr.s_addr);

		lib_Log_Printf(
		    "TCP    CONNECT from %d,%d.%d.%d:%d (local port %d)\n",
		    (int)(b->that_ip[3] >> 24 & 0xFF),
		    (int)(b->that_ip[3] >> 16 & 0xFF),
		    (int)(b->that_ip[3] >>  8 & 0xFF),
		    (int)(b->that_ip[3] >>  0 & 0xFF),
		    (int)b->that_port,
		    (int)b->this_port
		);
	    }

	    /* Mail socket to port listener msg stream: */
	    {   Vm_Obj obj_buf[ 4 ];
		obj_buf[ 0 ] = OBJ_FROM_CHAR('n');
		obj_buf[ 1 ] = OBJ_FROM_CHAR('e');
		obj_buf[ 2 ] = OBJ_FROM_CHAR('w');
		mss_Send(
		    SKT_P(r->skt)->standard_output,
		    skt,
		    OBJ_FROM_BYT3('t','x','t'),
		    OBJ_T,
		    obj_buf,
		    3
		);
	    }
	}

	did_some_io = TRUE;
    }
}



  /**********************************************************************/
  /*-  skt_read_tcp_socket --						*/
  /**********************************************************************/


   /*********************************************************************/
   /*- skt_signal_broken_pipe --					*/
   /*********************************************************************/

static void
skt_signal_broken_pipe(
    Skt_buffer b
) {
    /**********************************************/
    /* Send session leader a warning signal that  */
    /* the socket is being closed.  This lets the */
    /* session leader clean up, kill jobs, mark   */
    /* the user logged out, or whatever.          */
    /**********************************************/

    Vm_Obj job;
    Vm_Obj skt = b->skt;
    Vm_Obj ssn = SKT_P(skt)->session;
    if (OBJ_IS_OBJ(ssn) && OBJ_IS_CLASS_SSN(ssn)
    && (job = SSN_P(ssn)->session_leader)
    &&  OBJ_IS_OBJ(job) && OBJ_IS_CLASS_JOB(job)
    &&  job_Is_Alive(job)
    ) {
	Vm_Obj argblock[ 4 ];
	argblock[0] = job_Kw_Event;
	argblock[1] = obj_Err_Broken_Pipe_Warning;
	argblock[2] = job_Kw_Socket;
	argblock[3] = skt;
        job_Signal_Job( job, argblock, 4 );
    }
}

   /*********************************************************************/
   /*- skt_usually_start_closing_socket --				*/
   /*********************************************************************/

static void
skt_usually_start_closing_socket(
    Skt_buffer b
) {
    /* Normally, we just mark socket for closing and return: */
    Vm_Obj typ = SKT_P( b->skt )->typ;
    if (b->skt_state != SKT_OPEN) {
        if (b->skt_state == SKT_WAITING_TO_READ_EOF) {
            b->skt_state  = SKT_DRAINING_INPUT;
	}
	return;
    }
    if (typ != SKT_TYPE_BAT) {
#ifdef OLD
        SKT_P(b->skt)->typ = SKT_TYPE_EOF;
	vm_Dirty(b->skt);
	b->skt_state = SKT_CLOSED;
#else
/*printf("skt_usually_start_closing_socket: OPEN -> DRAINING_INPUT\n");*/
	b->skt_state          = SKT_DRAINING_INPUT;
	b->started_waiting_at = OBJ_TO_INT( job_RunState.now );
#endif
	return;
    }

    /* This particular skt is configured to read */
    /* the concatenation of a sequence of files: */
    if (!*skt_Bat_Files) {
#ifdef OLD
        SKT_P(   b->skt)->typ = SKT_TYPE_EOF;
	vm_Dirty(b->skt);
	b->skt_state = SKT_CLOSED;
	skt_need_to_close_some_sockets = TRUE;
#else
	/* No more files left to open: */
/*printf(">>> Out of bat files setting state to SKT_DRAINING_INPUT at now d=%d time(NULL) d=%d\n",OBJ_TO_INT( job_RunState.now ),time(NULL));*/
#ifdef OLD        
	b->skt_state          = SKT_DRAINING_INPUT;
	b->started_waiting_at = OBJ_TO_INT( job_RunState.now );
#else
        /* The above, alas, results in the output side being */
        /* closed as well as the input side. (buggo) I think */
        /* we probably should have logic to allowing closing */
        /* the two sides more independently.  For now, I'm   */
        /* just skipping this.  I do set dst_fd to -1, which */
	/* prevents busy-waiting behavior due to infinite    */
	/* attempts to read from the fd:		     */
	b->dst_fd = -1;
#endif
#endif
	return;
    }

    /* Close last file and open next: */
    close( b->dst_fd );
    b->dst_fd = open( *skt_Bat_Files, O_RDONLY );
    if (b->dst_fd == -1) {
	b->last_errno = errno;
	++ b->error_count;
	fprintf(stderr,"Couldn't open '%s'!\n",*skt_Bat_Files);
/* buggo... shouldn't be exit(1)ing in production system. */
	exit(1);
    }

    if (skt_max_known_descriptor < b->dst_fd) {
        skt_max_known_descriptor = b->dst_fd;
    }

    ++skt_Bat_Files;
}


   /*********************************************************************/
   /*- skt_append_net_input -- and massage control chars, newlines &tc	*/
   /*********************************************************************/

static void
skt_append_net_input(
    Skt_buffer b,
    Vm_Int n_read
) {
    Vm_Uch* cat = &b->dst_byt[ b->dst_nxt          ];
    Vm_Uch* rat = cat;
    Vm_Uch* lim = &b->dst_byt[ b->dst_nxt + n_read ];
    Skt_P   p   = SKT_P(b->skt);
    while (rat < lim) {
	Vm_Unt i = *rat++;
	Vm_Obj c = p->char_event[i];
	if (c == OBJ_FROM_INT(0)) {
	    *cat++ = i;
	    continue;
	} else {
	    Vm_Obj ssn;
	    Vm_Obj job;

	    /* Character has been marked as */
	    /* a special interrupt.  Signal */
	    /* it to sessionLeader and     */
	    /* remove it from buffer:       */
	    #if MUQ_IS_PARANOID
	    if (!OBJ_IS_OBJ(       c )
/*	    ||  !OBJ_IS_CLASS_CDT( c ) */
	    ){
		MUQ_FATAL ("Need cdt.");
	    }
	    #endif

	    /* Find session leader: */
	    if ((ssn = p->session)
	    &&   OBJ_IS_OBJ(ssn) && OBJ_IS_CLASS_SSN(ssn)
	    &&  (job = SSN_P(ssn)->session_leader)
	    &&   OBJ_IS_OBJ(job) && OBJ_IS_CLASS_JOB(job)
	    ){
		Vm_Obj argblock[4];
		argblock[0] = job_Kw_Event;
		argblock[1] = c;
		argblock[2] = job_Kw_Character;
		argblock[3] = OBJ_FROM_INT(i);
		job_Signal_Job( job, argblock, 4 );
	    }

	    /* skt may have moved: */
	    p = SKT_P(b->skt);
	}
    }
    n_read = cat - &b->dst_byt[ b->dst_nxt ];

    /* If user wants \r\n -> \n */
    /* conversion, do it now:   */
    if (b->dst_filters & SKT_FILTER_CRNL) {
	Vm_Uch* cat = &b->dst_byt[ b->dst_nxt          ];
	Vm_Uch* rat = cat;
	Vm_Uch* lim = &b->dst_byt[ b->dst_nxt + n_read ];
	Vm_Int  i   = ' ';
	while (rat < lim) {
	    Vm_Int j= *rat++;
	    if (j != '\n' || i != '\r') *cat++   = j;
	    else                         cat[-1] = j;
	    i = j;
	}
	n_read = cat - &b->dst_byt[ b->dst_nxt ];
    }

    /* We don't kill nonprinting chars at this */
    /* point because it would also string out  */
    /* TELNET protocol stuff before it could   */
    /* be processed and dispatched.            */
    b->dst_nxt += n_read;
}

   /*********************************************************************/
   /*- skt_read_udp_socket --						*/
   /*********************************************************************/

static void
skt_read_udp_socket(
    Skt_buffer b
) {
    /* Figure free chars available in buffer. */
    /* Since we only read if buffer is empty, */
    /* this is same as buffer size:           */
    Vm_Int left   = SKT_DST_BYT_SIZ;

    /* Read a datagram from net: */
    struct sockaddr_in  whofrom;
    int                 who_len = sizeof(whofrom);
    Vm_Int n_read = recvfrom(
	b->dst_fd,	/* Socket to read from.			*/
	b->dst_byt,	/* Buffer to read into.			*/
	left,		/* Max bytes to read.			*/
	0,		/* MSG_OOB | MSG_PEEK 			*/
	(struct sockaddr*) &whofrom,
	&who_len
    );
/*fprintf(stderr,"skt_read_udp_socket: %" VM_D " bytes\n",n_read);*/

    if (n_read < 0) {
	b->last_errno = errno;
	++ b->error_count;
    }

    /* Ignore errors: */
    if (n_read < 0)   return;
    obj_NoteDateAsRandomBits();

    /* Reading any data from net clears */
    /* the Abort Output flag:           */
    b->discard_netbound_data = FALSE;

    /* Note address of packet sender: */
    b->recv_port  = (Vm_Int) ntohs( whofrom.sin_port        );
    b->recv_ip[3] = (Vm_Unt) ntohl( whofrom.sin_addr.s_addr );
#ifdef DEBUG_AID
fprintf(stderr,"skt_read_udp_socket( %d.%d.%d.%d:%d ): %d bytes\n",(int)((b->recv_ip[3]>>24)&0xFF),(int)((b->recv_ip[3]>>16)&0xFF),(int)((b->recv_ip[3]>> 8)&0xFF),(int)((b->recv_ip[3]>> 0)&0xFF),(int)b->recv_port,(int)n_read);
{Vm_Int i;for (i = 0;  i < n_read; ++i) {
int byte = b->dst_byt[i];
if (byte < ' ' || byte > 126) fprintf(stderr,"<%02x>",byte);
else			      fprintf(stderr,"%c",byte);}
fprintf(stderr,"\n");}
#endif
    did_some_io = TRUE;

    skt_append_net_input( b, n_read );
}



  /**********************************************************************/
  /*-  skt_write_udp_socket --						*/
  /**********************************************************************/

static void
skt_write_udp_socket(
    Skt_buffer b
) {
    /* Figure chars available to write. */
    register Vm_Int to_write = b->src_nxt;

    /* Write the socket: */
    {   struct sockaddr_in who_to;
        Vm_Int n_written;

	memset( &who_to, 0, sizeof(who_to) );
	who_to.sin_family      = AF_INET;
	who_to.sin_addr.s_addr = htonl( b->that_ip[3] );
	who_to.sin_port        = htons( b->that_port  );
        n_written = sendto(
	    b->src_fd,
	    &b->src_byt[0],
	    to_write,
	    0,		/* MSG_OOB | MSG_DONTROUTE	*/
	    (struct sockaddr*) &who_to,
	    sizeof( who_to )
	);
#ifdef DEBUG_AID
fprintf(stderr,"skt_write_udp_socket( %d.%d.%d.%d:%d ): %d bytes\n",(int)((b->that_ip[3]>>24)&0xFF),(int)((b->that_ip[3]>>16)&0xFF),(int)((b->that_ip[3]>> 8)&0xFF),(int)((b->that_ip[3]>> 0)&0xFF),(int)b->that_port,(int)n_written);
{Vm_Int i;for (i = 0;  i < n_written; ++i) {
int byte = b->src_byt[i];
if (byte < ' ' || byte > 126) fprintf(stderr,"<%02x>",byte);
else			      fprintf(stderr,"%c",byte);}
fprintf(stderr,"\n");}
#endif

	if (n_written < 0) {
	    b->last_errno = errno;
	    ++ b->error_count;
	}

	/* Ignore errors: */
	if (n_written < 0)   return;

	did_some_io = TRUE;

	/* Delete written string from src_byt[]: */
	b->src_nxt  = 0;
    }
}

   /*********************************************************************/
   /*- skt_read_tcp_socket --						*/
   /*********************************************************************/

static void
skt_read_tcp_socket(
    Vm_Int i
) {
    /* Find our buffer: */
    Skt_buffer b;
    for (b = skt_buffer_lst;   ;   b = b->next) {
	
	MUQ_NOTE_RANDOM_BITS( *(Vm_Int*)&b );

	if (!b) MUQ_FATAL ("skt_read_tcp_socket: internal err");
	if (b->dst_fd == i)   break;
    }

    {   /* Figure free chars available in buffer: */
	Vm_Int left   = SKT_DST_BYT_SIZ - b->dst_nxt;

	/* Read as much as we can from net: */
	Vm_Int n_read = read( b->dst_fd, &b->dst_byt[b->dst_nxt], left );

/*{int i; printf("skt_read_tcp_socket: %d-byte Block read: '",n_read);*/
/*for (i =0 ; i < n_read; ++i) printf("%c",b->dst_byt[b->dst_nxt+i]);*/
/*printf("'\n");}*/
	/* If we didn't get anything, usually mark socket to be closed: */
/*printf("skt_read_tcp_socket: n_read d=%d\n",n_read);*/
	if (n_read <= 0)  {
/*printf("skt_read_tcp_socket: calling usually_start_closing_socket...\n");*/
	    if (n_read < 0) {
		b->last_errno = errno;
		++ b->error_count;
	    }

	    skt_usually_start_closing_socket( b );
	    return;
	}
        obj_NoteDateAsRandomBits();
	did_some_io = TRUE;

	/* Reading any data from net clears */
	/* the Abort Output flag:           */
	b->discard_netbound_data = FALSE;

	/* Merge into buffer, also doing     */
	/* control character processing &tc: */
	skt_append_net_input( b, n_read );
    }

}



  /**********************************************************************/
  /*-  skt_write_tcp_socket --						*/
  /**********************************************************************/

static void
skt_write_tcp_socket(
    Vm_Int i
) {
    /* Find our buffer: */
    Skt_buffer b;
    for (b = skt_buffer_lst;   ;   b = b->next) {

	MUQ_NOTE_RANDOM_BITS( *(Vm_Int*)&b );

	if (!b) MUQ_FATAL ("skt_write_tcp_socket: internal err");
	if (b->src_fd == i)   break;
    }

    /* Figure chars available to write. */
    /* In some modes, user wants only   */
    /* complete lines:                  */
    {   register Vm_Int to_write = b->src_nxt;

/* BUGGO? I don't see where outbound filtering */
/* of nonprinting chars is done, currently. */
        #ifdef OLD
	if (!(b->src_filters & SKT_PASS_NONPRINTING)) {
	    register Vm_Uch* t = &b->src_byt[0];
	    while (to_write
	    &&   t[ to_write-1 ] != '\n'
	    ){
		--to_write;
	    }
	    b->src_nxt = to_write;
	}
        #endif

	/* Write the socket: */
	{   Vm_Int n_written = write( b->src_fd, &b->src_byt[0], to_write );
/*printf("skt_write_tcp_socket: %d bytes written\n",n_written);*/
/*{int i = 0;for (; i < n_written; ++i) printf("%d '%c'\n",b->src_byt[i],b->src_byt[i]);}*/
/*printf("\n");*/

	    if (n_written < 0) {
		b->last_errno = errno;
		++ b->error_count;
	    }

	    /* Close socket on any write error but blockage: */
	    if (n_written < 0
	    &&  errno != EWOULDBLOCK
	    ) {
#ifdef OLD
		b->skt_state = SKT_CLOSED;
		SKT_P(   b->skt)->typ = SKT_TYPE_EOF;
		vm_Dirty(b->skt);
	 	skt_need_to_close_some_sockets = TRUE;
#else
/*printf("skt_write_tcp_socket: OPEN -> DRAINING_INPUT\n");*/
		b->skt_state          = SKT_DRAINING_INPUT;
		b->started_waiting_at = OBJ_TO_INT( job_RunState.now );
#endif
		return;
	    }
	    did_some_io = TRUE;

	    /* Delete written string from src_byt[]: */
	    b->src_nxt -= n_written;
	    memmove( &b->src_byt[0], &b->src_byt[n_written], b->src_nxt );
    }   }
}

  /**********************************************************************/
  /*-  skt_do_selected_sockets --					*/
  /**********************************************************************/

static void
skt_do_selected_sockets(
    fd_set *sockets_to_read,
    fd_set *sockets_to_write,
    fd_set *sockets_to_check
) {
    /* A read on a listen port is a special case: */
    {   Skt_buffer b;
	for (b = skt_listeners;   b;   b = b->next) {
	    if (FD_ISSET(b->dst_fd,sockets_to_read)){

		/* Maybe accept connect and   */
		/* mail new skt to designated */
		/* listener:                  */
		skt_accept_connect_request(b);

		/* Prevent skt_read_tcp_socket() */
		/* being called on this fd:  */
		FD_CLR(b->dst_fd,sockets_to_read);
    }	}   }

    /* A read on a UDP port is a special case: */
    {   Skt_buffer b;
	for (b = skt_udp_sockets;   b;   b = b->next) {
	    if (FD_ISSET(b->dst_fd,sockets_to_read)){

		skt_read_udp_socket(b);

		/* Prevent skt_read_tcp_socket() */
		/* being called on this fd:  */
		FD_CLR(b->dst_fd,sockets_to_read);
    }	}   }

    /* A write to a UDP port is a special case: */
    {   Skt_buffer b;
	for (b = skt_udp_sockets;   b;   b = b->next) {
	    if (FD_ISSET(b->dst_fd,sockets_to_write)){

		skt_write_udp_socket(b);

		/* Prevent skt_write_tcp_socket() */
		/* being called on this fd:  */
		FD_CLR(b->dst_fd,sockets_to_write);
    }	}   }

    /* Do any socket tcp i/o we can: */
    {   Vm_Int i;
	for   (i = skt_max_known_descriptor+1;   i --> 0;  ) {
	    if (FD_ISSET( i, sockets_to_read  ))   skt_read_tcp_socket(i);
	    if (FD_ISSET( i, sockets_to_write ))  skt_write_tcp_socket(i);
    }	}
}

  /**********************************************************************/
  /*-  skt_maybe_do_some_socket_io --					*/
  /**********************************************************************/

void
skt_maybe_do_some_socket_io(
    Vm_Int usec
) {

    /* Bitmaps of which sockets we are interested	*/
    /* in reading from or writing to:		*/
    fd_set to_read;
    fd_set to_write;
    fd_set to_check;

    skt_pick_sockets_to_select( &to_read, &to_write, &to_check );
    if (!skt_Select_Sockets(    &to_read, &to_write, &to_check, usec )) return;
    skt_do_selected_sockets(    &to_read, &to_write, &to_check );
}


 /***********************************************************************/
 /*-   skt_write_tcp_message_streams -- b->dst_byt[] to skt->dst_msg_q.	*/
 /***********************************************************************/

static void
skt_write_tcp_message_streams(
    void
) {
    /* 96May28: Phased out output_was_empty  */
    /* because the new |scan-token-* and     */
    /* |read-token-* functions can block on  */
    /* read even when stream is not empty.   */
    /*  Anyhow, output_was_empty was just a  */
    /* minor efficiency hack to avoid calling*/
    /* joq_Run_Message_Stream_Read_Queue when*/
    /* unneeded/unproductive, so we should be*/
    /* ok without it...                      */

    Vm_Obj obj_buf[ MSS_MAX_MSG_VECTOR ];

    /* Over all active tcp stream sockets: */
    Skt_buffer b;
    for (b = skt_buffer_lst;   b;   b = b->next) {

	/* Figure out how many bytes, if any,   */
	/* job is willing to accept from us.    */
	/* Most jobs only want complete lines:  */

	/* Figure out where our stg objects are */
	/* supposed to be going:  If our output */
	/* has been redirected, we want to      */
	/* respect that:                        */
	Vm_Int progress = TRUE;
	Vm_Obj standard_output;
	Vm_Obj out_of_band_output;
	Vm_Obj output;
/*	Vm_Int output_was_empty; */
	Vm_Int woken_out_of_band_output = FALSE;
	Vm_Int woken_standard_output = FALSE;
	{   Skt_P p = SKT_P(b->skt);
	    out_of_band_output = p->out_of_band_output;
	    standard_output    = p->standard_output;
	}
	if (out_of_band_output == OBJ_FROM_INT(0)) {
	    out_of_band_output =  standard_output;
	}

	while (progress) {

	    /* Pick maximum number of contiguous    */
	    /* bytes we can write to it, and        */
	    /* figure out whether they should be    */
	    /* going to standard_output or          */
	    /* out_of_band_output:                  */
	    Vm_Int segment_len;
	    progress = FALSE;
	    if (doing_metadata(	&segment_len, b )) {

		/* We have a TELNET command  */
		/* segment_len long ready to */
		/* send. Send all or none of */
		/* it:                       */
		output = out_of_band_output;
/*		output_was_empty = mss_Is_Empty( output ); */

		/* Copy values from dst_byt[] to */
		/* obj_buf[], converting from    */
		/* Vm_Uch to Vm_Obj as we go:    */
		if (segment_len > MSS_MAX_MSG_VECTOR) {
		    segment_len = MSS_MAX_MSG_VECTOR;
		}
		{   Vm_Int cat  = 0;
		    Vm_Int rat  = 0;
		    Vm_Uch*src  = &b->dst_byt[0];
		    Vm_Int last = 0;
		    Vm_Int this;

		    /* We copy nonprinting chars to the telnet  */
		    /* port even if we're not supposed to be    */
		    /* copying them to standard_output, since   */
		    /* telnet is an inherently binary protocol: */
		    for (;  rat < segment_len;  last = this) {
			this = src[ rat++ ];
			if (last == SKT_TELNET_IS_A_COMMAND
			&&  this == SKT_TELNET_IS_A_COMMAND
			){
			    this =  0; /* Not an IAS, Just a quoted 0xFF */
			} else {
			    obj_buf[   cat++ ] = OBJ_FROM_CHAR(this);
		    }   }

		    /* Break if insufficient   */
		    /* space in stream buffer: */
		    if (!mss_Can_Accept(
			/*obj*/ output,
			/*who*/ b->skt,
			/*tag*/ OBJ_FROM_BYT3('t','x','t'),
			/*buf*/ obj_buf,
			/*len*/ cat
		    )){
			break;
		    }

		    /* Write it to stream: */
		    mss_Send(
			/*obj*/ output,
			/*who*/ b->skt,
			/*tag*/ OBJ_FROM_BYT3('t','x','t'),
			/*don*/ OBJ_T,
			/*buf*/ obj_buf,
			/*len*/ cat
		    );
		    progress         = TRUE;

		    /* Delete that chunk of string from dst_byt[]: */
		    b->dst_nxt -= segment_len;
/* buggo, I think I've seen reports that some */
/* memmove()s are broken.  Prolly should test */
/* for this in autoconfig file.               */
		    memmove(
			&b->dst_byt[           0 ],
			&b->dst_byt[ segment_len ],
			 b->dst_nxt
		    );
		}

		/* Wake any jobs that might have */
		/* been waiting for input:       */
		if (/* output_was_empty && */
		   !woken_out_of_band_output
                ){
		    Vm_Obj q_in = MSS_P( output )->q_in;
		    if (q_in != OBJ_FROM_INT(0)) {
			joq_Run_Message_Stream_Read_Queue( q_in, output );
		    }
		    woken_out_of_band_output = TRUE;
		}

		continue;
	    }

	    /* Treat zero-bytes-transferrable */
	    /* as a special case:             */
	    if (!segment_len)   break;

	    /* We're doing vanilla user data, */
	    /* not TELNET metadata:           */
	    output  = standard_output;

	    /* If skt hasn't been initialized */
	    /* yet, output may not exist:     */
	    if (!OBJ_IS_OBJ(       output )
	    ||  !OBJ_IS_CLASS_MSS( output )
	    ){
		break;
	    }
/*	    output_was_empty = mss_Is_Empty( output ); */

	    /* Copy as much as practical */
	    /* from dst_byt[] to stream: */
	    while (!mss_Is_Full( output )) {
		Vm_Int line_len  = segment_len;

		/* If user wants just complete lines, */
		/* scan for next \n in buffer:        */
		if (b->dst_filters & SKT_FILTER_BY_LINES) {
		    Vm_Int dst_nl_offset = buf_first_nl(
			&b->dst_byt[        0 ],
			&b->dst_byt[ line_len ]
		    );
		    if (dst_nl_offset != -1) {
			/* Found a complete line: */
			line_len = dst_nl_offset +1;
		    } else {
			/* Line is incomplete, don't send it */
			/* unless forced by full buffer:     */
			if (b->dst_nxt < SKT_DST_BYT_SIZ)   line_len = 0;
		}   }

		/* If we have no buffered input  */
		/* we want to deliver to stream: */
		if (!line_len)   break;

		/* Don't try to send more than a */
		/* stream can hold in one chunk: */
		if (line_len > MSS_MAX_MSG_VECTOR) {
		    line_len = MSS_MAX_MSG_VECTOR;
		}

		/* Copy values from dst_byt[] to */
		/* obj_buf[], converting from    */
		/* Vm_Uch to Vm_Obj as we go:    */
		{   Vm_Int cat = 0;
		    Vm_Int rat = 0;
		    Vm_Uch*src = &b->dst_byt[0];
		    Vm_Int last = 0;
		    Vm_Int this;

		    if (!(b->dst_filters & SKT_TELNET_PROTOCOL)) {
		        if (b->dst_filters & SKT_PASS_NONPRINTING) {
			    /* Straight copy: */
			    for (;  rat < line_len;  ) {
				this = src[ rat++ ];
				obj_buf[ cat++ ] = OBJ_FROM_CHAR(this);
			    }
			} else {
			    /* Copy printing chars: */
			    for (;  rat < line_len;  ) {
				this = src[ rat++ ];
				if (isprint(this) || isspace(this)) {
				    obj_buf[ cat++ ] = OBJ_FROM_CHAR(this);
			}   }   }
		    } else {
		        if (b->dst_filters & SKT_PASS_NONPRINTING) {
			    /* Copy, collapsing IAC-IAC -> IAC: */
			    for (;  rat < line_len;   last = this) {
				this = src[ rat++ ];
				if (last == SKT_TELNET_IS_A_COMMAND
				&&  this == SKT_TELNET_IS_A_COMMAND
				){
				    this =  0; /* Not IAS, just quoted 0xFF */
				} else {
				    obj_buf[ cat++ ] = OBJ_FROM_CHAR(this);
			    }	}
			} else {
			    /* Copy printing characters,  */
			    /* collapsing IAC-IAC -> IAC: */
			    for (;  rat < line_len;   last = this) {
				this = src[ rat++ ];
				if (last == SKT_TELNET_IS_A_COMMAND
				&&  this == SKT_TELNET_IS_A_COMMAND
				){
				    this =  0; /* Not IAS, just quoted 0xFF */
				} else {
				    if (isprint(this) || isspace(this)) {
					obj_buf[ cat++ ] = OBJ_FROM_CHAR(this);
		    }   }   }   }   }

		    /* Break if insufficient   */
		    /* space in stream buffer: */
		    if (!mss_Can_Accept(
			/*obj*/ output,
			/*who*/ b->skt,
			/*tag*/ OBJ_FROM_BYT3('t','x','t'),
			/*buf*/ obj_buf,
			/*len*/ cat
		    )){
			break;
		    }

		    /* Write it to stream: */
		    mss_Send(
			/*obj*/ output,
			/*who*/ b->skt,
			/*tag*/ OBJ_FROM_BYT3('t','x','t'),
			/*don*/ OBJ_T,
			/*buf*/ obj_buf,
			/*len*/ cat
		    );
		    progress         = TRUE;

		    /* Delete that chunk of string from dst_byt[]: */
/* printf("skt_write_tcp_message_streams copying to stream: '");*/
/* {Vm_Int i;for (i=0;i<line_len;++i)printf("%c",b->dst_byt[i]);}*/
/* printf("skt_write_tcp_message_streams left in buffer: '");*/
/* {Vm_Int i;for (i=line_len;i<b->dst_nxt;++i)printf("%c",b->dst_byt[i]);}*/
/* printf("'\n");*/
		    segment_len -= line_len;
		    b->dst_nxt  -= line_len;
		    memmove(
			&b->dst_byt[        0 ],
			&b->dst_byt[ line_len ],
			 b->dst_nxt
		    );

		    /* Wake any jobs that might have */
		    /* been waiting for input:       */
/* buggo? Doesn't mss_Send above already */
/* do any needed waking of waiting jobs? */
		    if (/* output_was_empty && */
		       !woken_standard_output
                    ){
			Vm_Obj q_in = MSS_P( output )->q_in;
			if (q_in != OBJ_FROM_INT(0)) {
			    joq_Run_Message_Stream_Read_Queue( q_in, output );
			}
			woken_standard_output = TRUE;
		    }
	        }
	    }   /* while mss not full */
	} /* progress   */
    } /* skt_buffer_lst */
}


 /***********************************************************************/
 /*-   skt_write_udp_message_streams -- b->dst_byt[] to skt->dst_msg_q.	*/
 /***********************************************************************/

static void
skt_write_udp_message_streams(
    void
) {
    Vm_Obj obj_buf[ MSS_MAX_MSG_VECTOR ];

    /* Over all active udp stream sockets: */
    Skt_buffer b;
    for (b = skt_udp_sockets;   b;   b = b->next) {

	/* Figure out how many bytes, if any,   */
	/* job is willing to accept from us.    */
	/* Most jobs only want complete lines:  */

	/* Figure out where our stg objects are */
	/* supposed to be going:  If our output */
	/* has been redirected, we want to      */
	/* respect that:                        */
	Vm_Obj standard_output  = SKT_P(b->skt)->standard_output;
	Vm_Int wrote_to_stdout  = FALSE;
	Vm_Int stdout_was_empty;

	/* If skt hasn't been initialized yet,  */
	/* standard_output may not exist:       */
	if (!OBJ_IS_OBJ(       standard_output )
	||  !OBJ_IS_CLASS_MSS( standard_output )
	){
	    continue;
	}
	stdout_was_empty = mss_Is_Empty( standard_output );

	/* Copy datagram from dst_byt[] to mss: */
	while (!mss_Is_Full( standard_output )) {
	    Vm_Int line_len  = b->dst_nxt;
/* buggo, we should likely be discarding oversize */
/* datagrams if we weren't asked to line-block them. */
	    if (b->dst_filters & SKT_FILTER_BY_LINES) {
		Vm_Int dst_nl_offset = buf_first_nl(
		    &b->dst_byt[          0 ],
		    &b->dst_byt[ b->dst_nxt ]
		);
		if (dst_nl_offset != -1) {
		    line_len = dst_nl_offset +1;
		} else {
		    /* Even if job specifies line blocking, */
		    /* we send to it if buffer is full:     */
		    if (b->dst_nxt < SKT_DST_BYT_SIZ)   line_len = 0;
	    }   }

	    /* If we have any buffered input */
	    /* awaiting delivery to mss:     */
	    if (!line_len) {
		break;
	    }

	    /* Copy values from dst_byt[] to */
	    /* obj_buf[], converting from    */
	    /* Vm_Uch to Vm_Obj as we go.    */
	    /* Remember that we need 10 slots*/
	    /* to hold return address for    */
	    /* datagram:                     */
	    if (line_len > MSS_MAX_MSG_VECTOR-10) {
		line_len = MSS_MAX_MSG_VECTOR-10;
	    }
	    {   Vm_Int cat = 0;
		Vm_Int rat = 0;
		Vm_Uch*src = &b->dst_byt[0];
		Vm_Int val;
		Vm_Int ip   = b->recv_ip[3];
		Vm_Obj ip0  = OBJ_FROM_INT( (ip >> 24) & 0xFF );
		Vm_Obj ip1  = OBJ_FROM_INT( (ip >> 16) & 0xFF );
		Vm_Obj ip2  = OBJ_FROM_INT( (ip >>  8) & 0xFF );
		Vm_Obj ip3  = OBJ_FROM_INT( (ip      ) & 0xFF );
		Vm_Obj port = OBJ_FROM_INT( b->recv_port      );
		obj_buf[cat++] = job_Kw_Ip0 ;  obj_buf[cat++] = ip0 ;
		obj_buf[cat++] = job_Kw_Ip1 ;  obj_buf[cat++] = ip1 ;
		obj_buf[cat++] = job_Kw_Ip2 ;  obj_buf[cat++] = ip2 ;
		obj_buf[cat++] = job_Kw_Ip3 ;  obj_buf[cat++] = ip3 ;
		obj_buf[cat++] = job_Kw_Port;  obj_buf[cat++] = port;
		if (b->dst_filters & SKT_PASS_NONPRINTING) {
		    while (rat < line_len) {
			val = src[ rat++ ];
			obj_buf[   cat++ ] = OBJ_FROM_CHAR(val);
		    }
		} else {
		    while (rat < line_len) {
			val = src[ rat++ ];
			if (isprint(val) || isspace(val)) {
			    obj_buf[   cat++ ] = OBJ_FROM_CHAR(val);
		}   }   }

		/* Break if insufficient   */
		/* space in stream buffer: */
		if (!mss_Can_Accept(
		    /*obj*/ standard_output,
		    /*who*/ b->skt,
		    /*tag*/ OBJ_FROM_BYT3('t','x','t'),
		    /*buf*/ obj_buf,
		    /*len*/ line_len+10
		)){
		    break;
		}

		/* Write it to stream: */
		mss_Send(
		    /*obj*/ standard_output,
		    /*who*/ b->skt,
		    /*tag*/ OBJ_FROM_BYT3('t','x','t'),
		    /*don*/ OBJ_T,
		    /*buf*/ obj_buf,
#ifdef OLD
		    /*len*/ line_len+10
#else
		    /*len*/ cat
#endif
		);
	    }
	    wrote_to_stdout  = TRUE;

	    /* Delete that chunk of string from dst_byt[]: */
	    b->dst_nxt -= line_len;
	    memmove(
		&b->dst_byt[        0 ],
		&b->dst_byt[ line_len ],
		 b->dst_nxt
	    );

    	}   /* while mss not full */

	/* Wake any jobs that might have */
	/* been waiting for input:       */
	if (stdout_was_empty && wrote_to_stdout) {
	    Vm_Obj q_in = MSS_P( standard_output )->q_in;
	    if (q_in != OBJ_FROM_INT(0)) {
		joq_Run_Message_Stream_Read_Queue( q_in, standard_output );
	    }
	}
    } /* skt_buffer_lst */
}


 /***********************************************************************/
 /*-   skt_Maybe_Do_Some_IO -- Service network sockets (etc).		*/
 /***********************************************************************/

Vm_Int
skt_Maybe_Do_Some_IO(
    Vm_Int usec	/* Max microseconds to sleep in select(). */
) {
/*fprintf(stderr,"skt_Maybe_Do_Some_IO(%d)/A...\n",usec);*/
    did_some_io  = FALSE;
    did_a_select = FALSE;

/*printf("skt_Maybe_Do_Some_IO(%d)/B...\n",usec);*/
    skt_read_tcp_message_streams( );	/* Make bytes from netbound text.*/
/*printf("skt_Maybe_Do_Some_IO(%d)/C...\n",usec);*/
    skt_read_udp_message_streams( );	/* Make bytes from netbound text.*/
/*printf("skt_Maybe_Do_Some_IO(%d)/D...\n",usec);*/
    skt_maybe_do_some_socket_io( usec );/* Read/write net sockets.	 */
/*printf("skt_Maybe_Do_Some_IO(%d)/E...\n",usec);*/
    skt_write_tcp_message_streams();
/*printf("skt_Maybe_Do_Some_IO(%d)/F...\n",usec);*/
    skt_write_udp_message_streams();
/*printf("skt_Maybe_Do_Some_IO(%d)/G...\n",usec);*/

    if (skt_need_to_close_some_sockets) {
/*printf("skt_Maybe_Do_Some_IO(%d) closing some sockets...\n",usec);*/
	buf_physically_close_all_marked_sockets();
    }

/*printf("skt_Maybe_Do_Some_IO(%d)/Z...\n",usec);*/
    if (did_a_select && !did_some_io)  ++skt_Select_Calls_With_No_Io;
    return   did_some_io;
}



/************************************************************************/
/*-    skt_Activate -- Set type of new skt, start it running.		*/
/************************************************************************/

void
skt_Activate(
    Vm_Obj skt,
    Vm_Obj typ,		/* SKT_TYPE_TTY etc.			*/

    Vm_Int src_fd,	/* File descriptor/socket to write.	*/
    Vm_Int dst_fd	/* File descriptor/socket to read.	*/
) {
    Skt_buffer b;

/*printf("skt_Activate( skt %x type %x src_fd d=%d dst_fd d=%d\n",skt,typ,src_fd,dst_fd);*/
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(       skt )
    ||  !OBJ_IS_CLASS_SKT( skt )
    ){
	MUQ_FATAL ("Need skt.");
    }
    #endif

    {   Vm_Int buf_no;
	Skt_P  q   = SKT_P(skt);
	if (q->buf_no != OBJ_FROM_INT(-1)) {
	    MUQ_WARN ("Cannot open already-open socket.");
	}
	buf_no	   = buf_alloc( skt, typ    );
	q->buf_no  = OBJ_FROM_INT(   buf_no );
	q->typ     = typ;
        q->closed_by	= OBJ_NIL;
        q->exit_status	= OBJ_NIL;
        q->last_signal	= OBJ_NIL;
	b	   = skt_buffer_ary[ buf_no ];
	vm_Dirty(skt);
    }
    b->dst_fd	= dst_fd;
    b->src_fd	= src_fd;

    /* As a mildly ugly but convenient */
    /* kludge, if output is on TTY,    */
    /* disable CR insert/delete stuff: */
    if (typ == SKT_TYPE_TTY
    ||  typ == SKT_TYPE_BAT
    ){
	skt_set_filter_cr_i( skt, OBJ_NIL );
	skt_set_filter_cr_o( skt, OBJ_NIL );
    }

    if (skt_max_known_descriptor < dst_fd) {
        skt_max_known_descriptor = dst_fd;
    }
    if (skt_max_known_descriptor < src_fd) {
        skt_max_known_descriptor = src_fd;
    }
}


/************************************************************************/
/*-    skt_Nth_Active_Socket --	support for rootAllActiveSockets[	*/
/************************************************************************/

Vm_Obj
skt_Nth_Active_Socket(
    Vm_Int n
) {
    /***********************************/
    /* I don't expect this call to be  */
    /* a performance issue, so we use  */
    /* an O(N) approach instead of     */
    /* an O(1) approach. If it becomes */
    /* a problem we can cache a pointer*/
    /* to where we left off and care-  */
    /* fully invalidate it whenever we */
    /* modify the lists, and tricky    */
    /* stuff like that.                */
    /***********************************/
    Skt_buffer b = skt_buffer_lst;
    for (b = skt_buffer_lst ; b; b = b->next)   if (!n--) return b->skt;
    for (b = skt_listeners  ; b; b = b->next)   if (!n--) return b->skt;
    for (b = skt_udp_sockets; b; b = b->next)   if (!n--) return b->skt;
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    skt_Child_Changed --						*/
/************************************************************************/

 /***********************************************************************/
 /*-   skt_from_pid -- Map child pid to socket.				*/
 /***********************************************************************/

static Vm_Obj
skt_from_pid(
    Vm_Int pid
) {
    /* Find our buffer: */
    Skt_buffer b;
    for (b = skt_buffer_lst;   b;   b = b->next) {
	if (!b) MUQ_FATAL ("skt_read_tcp_socket: internal err");
	if (b->that_pid == pid)   return b->skt;
    }
    return OBJ_FROM_INT(0);
}

 /***********************************************************************/
 /*-   skt_Child_Changed --						*/
 /***********************************************************************/

void
skt_Child_Changed(
    Vm_Int child_pid,
    Vm_Int new_status
) {
    Vm_Obj skt;

    /**********************************/
    /* This function gets called from */
    /* job.t:sig_chld() in response   */
    /* to a SIG_CHLD interrupt, which */
    /* typically means that a sub-    */
    /* process we've forked off has   */
    /* exited, and that we need to    */
    /* close down the pipes leading   */
    /* to it, mark the socket closed, */
    /* and good stuff like that.      */
    /**********************************/

    if (WIFSTOPPED( new_status )) {
	/* Some signal has stopped the subjob. */
        /* Maybe someone is debugging it?      */
	/* int signal = WSTOPSIG( new_status ) */
	/* would give the signal that stopped  */
	/* it, but we'll ignore this for now:  */
	return;
    }

    if (WIFEXITED( new_status )) {

	/**********************************/
	/* Child called exit() or _exit() */
	/**********************************/

	/* Record its exit status: */
	if (skt = skt_from_pid( child_pid )) {
	    Skt_P  s = SKT_P( skt );
	    Vm_Int n = OBJ_TO_INT( s->buf_no );
	    s->closed_by   = job_Kw_Exit;
	    s->exit_status = OBJ_FROM_INT( WEXITSTATUS( new_status ) );
	    vm_Dirty(skt);

	    /* If the socket has a buffer, */
	    /* mark it for closure.  (It   */
	    /* -should- have a buffer...)  */
	    if (s->typ != SKT_TYPE_EOF
    	    && n >= 0
	    ){
		/* Note that deleting b from its */
		/* linklist would be very risky, */
		/* since we've been called by an */
		/* asynchronous signal function  */
		/* and have no idea what list    */
		/* operation might be going on.  */
		Skt_buffer b = skt_buffer_ary[ n ];
#ifdef OLD
		b->skt_state = SKT_READ_NET_EOF;
#else
		b->that_pid  = 0;
#endif
	    }
	}
	return;
    }

    if (WIFSIGNALED( new_status )) {

	/********************************/
	/* Child was killed by a signal */
	/********************************/

	/* Record the signal that killed it: */
	if (skt = skt_from_pid( child_pid )) {
	    Skt_P  s = SKT_P( skt );
	    Vm_Int n = OBJ_TO_INT( s->buf_no );

	    /* Don't record signal as being */
	    /* cause of death if we sent it */
	    /* ourself:                     */
	    if (s->closed_by == OBJ_NIL) {
		s->closed_by   = job_Kw_Signal;
		s->last_signal = OBJ_FROM_INT( WTERMSIG( new_status ) );
		vm_Dirty(skt);
	    }

	    /* If the socket has a buffer, */
	    /* mark it for closure.  (It   */
	    /* -should- have a buffer...)  */
	    if (s->typ != SKT_TYPE_EOF
    	    && n >= 0
	    ){
		Skt_buffer b = skt_buffer_ary[ n ];
#ifdef OLD
		b->skt_state = SKT_READ_NET_EOF;
#else
		b->that_pid  = 0;
#endif
	    }
	}
	return;
    }
}

/************************************************************************/
/*-    skt_Close --							*/
/************************************************************************/

void
skt_Close(
    Vm_Obj socket
) {
#ifdef OLD
    /* Locate buffer for given socket: */
    Skt_buffer b;
    {   Skt_P  s = SKT_P(socket);
	Vm_Int n = OBJ_TO_INT( s->buf_no );
	/* Make reclosing an already-closed skt a no-op: */
	if (n == -1)   return;
	b        = skt_buffer_ary[ n ];
	/* Closing a popen()ed socket is a special case: */
	if (b->typ==SKT_TYPE_SRV) {
	    if (b->that_pid) {
		kill( b->that_pid, SIGHUP );
		b->started_waiting_at = OBJ_TO_INT( job_RunState.now );
		b->skt_state      = SKT_SENT_HUP;
		s->closed_by      = job_Kw_Close;
		vm_Dirty(socket);
		return;
	    }
	}
        s->typ   = SKT_TYPE_EOF;
	s->buf_no= OBJ_FROM_INT(-1);
	vm_Dirty(socket);
    }
/*printf("skt_Close/old calling physically_close_one_socket...\n");*/
    buf_physically_close_one_socket( b );
#else
    /* Locate buffer for given socket: */
    Skt_buffer b;
    Skt_P  s = SKT_P(socket);
    Vm_Int n = OBJ_TO_INT( s->buf_no );
    /* Make reclosing an already-closed skt a no-op: */
    if (n == -1)   return;
    b            = skt_buffer_ary[ n ];
/*printf("skt_Close: socket x=%x n d=%d b->skt x=%x\n",socket,n,b->skt);*/

    switch (b->typ) {

    case SKT_TYPE_EOF:
	/* ?! */
	break;

    case SKT_TYPE_TCP:
    case SKT_TYPE_SRV:
	/* Start closing process by giving socket  */
	/* SKT_OUTDRAIN_MILLISECONDS to read any        */
	/* remaining output to it:                 */
/*printf("skt_Close: OPEN -> DRAINING_OUTPUT\n");*/
	b->skt_state = SKT_DRAINING_OUTPUT;
	b->started_waiting_at = OBJ_TO_INT( job_RunState.now );
        break;

    case SKT_TYPE_BAT:
    case SKT_TYPE_TTY:
    case SKT_TYPE_UDP:
    case SKT_TYPE_EAR:
#ifdef OLD
        s->typ   = SKT_TYPE_EOF;
	s->buf_no= OBJ_FROM_INT(-1);
	vm_Dirty(socket);
#endif
/*printf("skt_Close calling buf_physically_close_one_socket...\n");*/
	buf_physically_close_one_socket( b );
	break;

    default:
	MUQ_FATAL("skt_Close");
    }

#endif
}

/************************************************************************/
/*-    skt_Popen --							*/
/************************************************************************/

 /***********************************************************************/
 /*-   skt_parse_commandline --						*/
 /***********************************************************************/

#ifndef SKT_MAX_ARG
#define SKT_MAX_ARG 256
#endif

static Vm_Int
skt_parse_commandline(
    Vm_Uch** argV,
    Vm_Int*  argC,
    Vm_Int   maxarg,
    Vm_Uch*  cmd
) {
    /* Over all arguments: */
    for (*argC = 0;   *argC < maxarg;   ++*argC) {

	/* Strip leading space on argument: */
	while (*cmd && !isgraph(*cmd))  ++cmd;
	if (!*cmd)   return TRUE;

	/* Find end of argument: */
	if (*cmd != '"') {

	    /* Remember start of argument: */
	    argV[ *argC ] = cmd;

	    while (*cmd && isgraph(*cmd))  ++cmd;
	    if (!*cmd) { ++*argC;  return TRUE; }
	} else {
	    Vm_Int last = '\0';

	    /* Remember start of argument: */
	    argV[ *argC ] = ++cmd;

	    for (;  ;  ++cmd) {
		if (!*cmd)   return FALSE;
		if (*cmd == '"' && last != '\\')   break;
		last = (last=='\\' ? '\0' : *cmd);
	    }
	}
	*cmd++ = '\0';
    }
    return FALSE;
}

 /***********************************************************************/
 /*-   skt_exec --							*/
 /***********************************************************************/

struct skt_exec_rec {
    int from_fd;
    int into_fd;
    int child_pid;
};

/* Defs to make the pipe()-created */
/* fd pairs more intelligible:     */
#undef READ_END
#undef WRITE_END
#define READ_END  0
#define WRITE_END 1

static struct skt_exec_rec
skt_exec(
    Vm_Obj  skt,
    Vm_Uch* srv,
    Vm_Uch**argV,
    Vm_Int  pipe_into_child,
    Vm_Int  pipe_from_child
) {
    int into_child[2];	/* fd pair for pipe via which we write to  child. */
    int from_child[2];  /* fd pair for pipe via which we read from child. */
    int child_pid;
    if (pipe_into_child) {
	if (0 > pipe(into_child)) {
/*	    b->last_errno = errno; */
/*	    ++ b->error_count; */
	    MUQ_WARN("Couldn't open pipe into child");
	}
    }
    if (pipe_from_child) {
	if (0 > pipe(from_child)) {
/*	    b->last_errno = errno; */
/*	    ++ b->error_count; */
	    MUQ_WARN("Couldn't open pipe from child");
	}
    }
    child_pid = fork();
    if (0 > child_pid) {
/*	b->last_errno = errno; */
/*	++ b->error_count; */
	MUQ_WARN("Couldn't fork child");
    }
    if (!child_pid) {
	int fd;
	int i;

	/********************/
	/* We are the child */
	/********************/

	/* Set up stdin for new process: */
	if (pipe_into_child) {
	    close( into_child[WRITE_END] );
	    fd = into_child[READ_END];
	} else {
	    fd = open( "/dev/null", O_RDONLY );
	}
	if (fd != STDIN_FILENO) {
	    dup2( fd, STDIN_FILENO );
	    close(fd);
	}

	/* Set up stdout for new process: */
	if (pipe_from_child) {
	    close( from_child[READ_END] );
	    fd = from_child[WRITE_END];
	} else {
	    fd = open( "/dev/null", O_WRONLY );
	}
	if (fd != STDOUT_FILENO) {
	    dup2( fd, STDOUT_FILENO );
	    close(fd);
	}

	/* Set up stderr for new process: */
	fd = open( "/dev/tty", O_WRONLY );
	if (fd != STDERR_FILENO) {
	    dup2( fd, STDERR_FILENO );
	    close(fd);
	}

	/* Close fds other than stdin/out/err: */
	for (i = STDERR_FILENO+1;  i < skt_max_known_descriptor;  ++i) {
	    close(i);
	}

	/* Exec the server: */
	execv( srv, (Vm_Chr**)argV );

	/* Should never return: Can't */
	/* easily signal an error if  */
	/* it does:                   */
	_exit(0x7F);
    }

    /*********************/
    /* We are the parent */
    /*********************/

    {   struct skt_exec_rec result;

	result.child_pid = child_pid;

	if (pipe_into_child) {
	    close( into_child[READ_END] );
	    result.into_fd = into_child[ WRITE_END ];

	    /* Track max descriptor, for socket() calls: */
	    if (skt_max_known_descriptor < result.into_fd) {
		skt_max_known_descriptor = result.into_fd;
	}   }

	if (pipe_from_child) {
	    close( from_child[ WRITE_END ] );
	    result.from_fd = from_child[ READ_END ];

	    /* Track max descriptor, for socket() calls: */
	    if (skt_max_known_descriptor < result.from_fd) {
		skt_max_known_descriptor = result.from_fd;
	}   }

	return result;
    }
}
#undef READ_END
#undef WRITE_END

 /***********************************************************************/
 /*-   skt_Popen --							*/
 /***********************************************************************/

void
skt_Popen(
    Vm_Obj skt,
    Vm_Uch*cmd,
    Vm_Int pipe_into_child,
    Vm_Int pipe_from_child
) {
    #ifndef  LIB_PATH_MAX
    #define  LIB_PATH_MAX 512
    #endif /*LIB_PATH_MAX*/

    #ifndef  LIB_FILE_MAX
    #define  LIB_FILE_MAX  32
    #endif /*LIB_FILE_MAX*/

    Vm_Uch          srv[ LIB_PATH_MAX + LIB_FILE_MAX ];
    Vm_Uch* lim = & srv[ LIB_PATH_MAX + LIB_FILE_MAX ];
    Vm_Uch* src;
    Vm_Uch* dst;

    /* Crack the commandline: */
    Vm_Uch* argV[ SKT_MAX_ARG ];
    Vm_Int  argC = 0;
    if (!skt_parse_commandline( argV, &argC, SKT_MAX_ARG-1, cmd )) {
	MUQ_WARN("Invalid popen commandline");
    }
    argV[argC] = NULL;

    strcpy( srv, obj_Srv_Dir  );
    src = cmd;
    dst = srv + strlen( srv );

    *dst++ = '/';
    for (;;) {
	Vm_Uch c = *src++;
	if (!c || isspace(c))   break;
	if (dst+1 == lim)   MUQ_WARN(":popen program name too long");
	*dst++ = c;
    }
    *dst++ = '\0';
    *src++ = '\0';

    {   /* See if we can find the indicated file: */
	struct stat statbuf;

	/* Owner-executable bit: */
	#ifdef S_IXUSR
	#define  IS_EXECUTABLE(m) (m & S_IXUSR)
	#else
	#define  IS_EXECUTABLE(m) (m & 0100)
	#endif

	if (-1 == stat( srv, &statbuf )) {
	    MUQ_WARN("Cannot find '%s'",srv);
	} else if (!S_ISREG(statbuf.st_mode)) {
	    MUQ_WARN("%s is not a regular file",srv);
	} else if (!IS_EXECUTABLE(statbuf.st_mode)) {
	    MUQ_WARN("%s is not executable",srv);
	} else {
	    /* Coast looks clear! */
	    struct skt_exec_rec result;
	    result = skt_exec(
		skt,
		srv,
		argV,
		pipe_into_child,
		pipe_from_child
	    );

	    /* Squirrel away pipe-fd info in  */
	    /* our own buffer datastructures: */
	    skt_Activate(
		skt,
		SKT_TYPE_SRV,
		pipe_into_child ? result.into_fd : -1,	/* fd to write	*/
		pipe_from_child ? result.from_fd : -1	/* fd to read	*/
	    );
	    {   Skt_buffer b = skt_buffer_ary[OBJ_TO_INT(SKT_P(skt)->buf_no)];
		b->that_pid  = result.child_pid;
	    }
	}
    }
}

/************************************************************************/
/*-    skt_Open --							*/
/************************************************************************/

 /***********************************************************************/
 /*-   skt_crack_address --						*/
 /***********************************************************************/

static void
skt_crack_address(
    struct sockaddr_in*	address,
    Vm_Uch* hostname
) {
    if (!isdigit(*hostname)) {
	/* "prep.ai.mit.edu" type hostname: */
	Vm_Int start_date    = job_Now();
	struct hostent* host = gethostbyname( hostname );
	Vm_Int end_date      = job_Now();
	Vm_Int duration      = end_date-start_date;
	if (duration > 10) {
	    lib_Log_Printf(
		"skt_crack_address: gethostbyname took %" VM_D " millisecs.\n",
		duration
	    );
	}
	if (!host) MUQ_WARN ("Bad hostname");
	memcpy( host->h_addr, &address->sin_addr.s_addr, host->h_length );
    } else {
	/* "18.159.0.42" type hostname: */
/* buggo, should check for inet_aton() and use it */
/* instead of in_addr() when present: */
	address->sin_addr.s_addr = inet_addr( hostname );
	if (address->sin_addr.s_addr == INADDR_NONE) {
	    MUQ_WARN ("Bad host address");
	}
    }
}

 /***********************************************************************/
 /*-   skt_Open --							*/
 /***********************************************************************/

void
skt_Open(
    Vm_Obj skt,
    Vm_Uch*hostname,
    Vm_Int address_family,	/* Always AF_INET at present		*/
    Vm_Int protocol,		/* SOCK_STREAM or SOCK_DGRAM		*/
    Vm_Int interface,		/* Always INADDR_ANY at present.	*/
    Vm_Unt that_port		/* 4201 or such.			*/
) {
    Vm_Obj typ = 0;		/* Initialized just to quiet compilers.	*/
    Vm_Int n;
    Vm_Obj oob_input;
    Vm_Obj oob_output;
    {   Skt_P  s      = SKT_P(skt);
        n             = OBJ_TO_INT( s->buf_no );
        oob_input  = s->out_of_band_input;
        oob_output = s->out_of_band_output;
    }

    switch (protocol) {
    case SOCK_DGRAM:   typ = SKT_TYPE_UDP;	break;
    case SOCK_STREAM:  typ = SKT_TYPE_TCP;	break;
    default:
        #if MUQ_IS_PARANOID
	MUQ_FATAL ("skt_Open");
	#endif
	;
    }

    /* Make opening an already-open skt a no-no: */
    if (n != -1)   MUQ_WARN("Socket is already open");

    {	/* Open the actual unix socket: */
	Vm_Int 			fd;
	struct sockaddr_in	that;
	struct sockaddr_in	this;
	memset( &that, 0, sizeof(that) );
	that.sin_family = address_family;
	that.sin_port = htons( that_port );

	skt_crack_address( &that, hostname );

	fd = socket( address_family, protocol, 0 );
	if (fd < 0) MUQ_WARN ("Couldn't open internet socket");

	switch (protocol) {

	case SOCK_DGRAM:
	    memset( &this, 0, sizeof(this) );
	    this.sin_family      = address_family;
	    this.sin_addr.s_addr = htonl( INADDR_ANY );
	    this.sin_port        = htons( 0 /*=any*/ );
/*fprintf(stderr,"skt_Open/SOCK_DGRAM: %d.%d.%d.%d:%d\n",*/
/*((this.sin_addr.s_addr>>24)&0xFF),*/
/*((this.sin_addr.s_addr>>16)&0xFF),*/
/*((this.sin_addr.s_addr>> 8)&0xFF),*/
/*((this.sin_addr.s_addr>> 0)&0xFF),*/
/*0*/
/*);*/
	    if (0 > bind(fd, (struct sockaddr*)&this, sizeof(this))) {
/*		b->last_errno = errno;	*/
/*		++ b->error_count;	*/
		MUQ_WARN ("Couldn't bind udp socket");
	    }
	    break;

	case SOCK_STREAM:
	    if (0 > connect(fd, (struct sockaddr*)&that, sizeof(that))) {
/*		b->last_errno = errno; */
/*		++ b->error_count; */
		MUQ_WARN ("Couldn't connect to that address+port");
	    }
	    break;
	}

	/* Record local port number too, just in */
	/* case someone looks at the property:   */
	{   int size = sizeof( this );
	    if (0 > getsockname( fd, (struct sockaddr*) &this, &size )) {
/*		b->last_errno = errno; */
/*		++ b->error_count; */
		MUQ_WARN ("getsockname() failed");
	    }
	}

	/* Squirrel away internet-socket info in     */
	/* our own socket and buffer datastructures: */
	skt_Activate(
	    skt,
	    typ,		/* SKT_TYPE_UDP or SKT_TYPE_TCP		*/
	    fd,			/* fd to write				*/
	    fd			/* fd to read				*/
	);
	{   Skt_buffer b  = skt_buffer_ary[ OBJ_TO_INT( SKT_P(skt)->buf_no ) ];
	    b->this_port  = (Vm_Int) ntohs( this.sin_port        );
	    b->that_port  = that_port;
	    b->that_ip[3] = (Vm_Unt) ntohl( that.sin_addr.s_addr );

	    if (oob_output==OBJ_NIL) b->dst_filters &= ~SKT_TELNET_PROTOCOL;
	    else                     b->dst_filters |=  SKT_TELNET_PROTOCOL;

	    if (oob_input==OBJ_NIL)  b->src_filters &= ~SKT_TELNET_PROTOCOL;
	    else                     b->src_filters |=  SKT_TELNET_PROTOCOL;
	}
    }
}

/************************************************************************/
/*-    skt_Listen -- Start listening on a port.				*/
/************************************************************************/


 /***********************************************************************/
 /*-   open_listen_port -- 						*/
 /***********************************************************************/

static Vm_Int
open_listen_port(
    Vm_Int vm_address_family,	/* Currently always AF_INET.	*/
    Vm_Int vm_protocol,		/* SOCK_STREAM or SOCK_DGRAM.	*/
    Vm_Int vm_interfaces,	/* Currently always INADDR_ANY.	*/
    Vm_Int vm_port		/* 4201 or whatever.		*/
) {
    /* Convert typically 64-bit parameters into */
    /* typically 32-bit form more likley to be  */
    /* congenial to socket() & kin:             */
    int  address_family = (int) vm_address_family;
    int  protocol       = (int) vm_protocol;
    int  interfaces     = (int) vm_interfaces;
    int  port           = (int) vm_port;

    /********************************************************************/
    /* Unix Network Programming (W Richard Stevens, ISBN 0-13-949876-1) */
    /* is a good intro to network programming.  6.5 covers socket()...  */
    /********************************************************************/

    /* Announce we want to use a TCP bidirectional stream. */
    /* This doesn't connect anything to anything yet, just */
    /* declares our intentions:                            */
    int fd = socket(
	address_family,	/* Address Family InterNET, not unix/XNS/...	*/
	protocol,	/* SOCK_STREAM (TCP) vs SOCK_DGRAM (UDP)...	*/
	0		/* Generic procotol, not ICMP like ping, say...	*/
    );
    if (fd == -1)   MUQ_WARN ("Couldn't listen on port %d.", (int)port );

    /* Specify that our listen port can be reused: */
    if (protocol == SOCK_STREAM) {
	int option = TRUE;
	if (-1 == setsockopt(
	        fd,
	        SOL_SOCKET,	/* Protocol level to handle this call.	*/
	        SO_REUSEADDR,	/* Option to set.			*/
	        (char*) &option,/* Value to set for option.		*/
	        sizeof( option )/* More useful in other calls to ths fn!*/
	)   ) {
	    MUQ_WARN ("Couldn't set listen port %d reusable?!", (int)port );
    }	}

/*if (protocol == SOCK_DGRAM) fprintf(stderr,"open_listen_port: port %d\n",(int)port);*/
    /* Specify actual port on which to listen: */
    {   struct sockaddr_in listen_address;
	(void)bzero( (void*)&listen_address, sizeof(listen_address) );
	listen_address.sin_family	= address_family;
	/* Allow connects from any internet interface on host machine: */
	listen_address.sin_addr.s_addr	= htonl( interfaces );
	listen_address.sin_port		= htons( port       );
        if (-1 == bind(
	        fd,
		(struct sockaddr*) &listen_address,
		sizeof(             listen_address )
	)   ) {
	    MUQ_WARN ("Couldn't bind listen port %d (%s)!", port, strerror(errno) );
    }	}

    /* Actually start listening: */
    if (protocol == SOCK_STREAM) {
	listen(
	    fd,
	    5	/* Max connections to queue. (Maximum number allowed.)	*/
	);
    }

    /* Track max descriptor, for socket() calls: */
    if (skt_max_known_descriptor < fd) {
        skt_max_known_descriptor = fd;
    }

    return (Vm_Int)fd;
}

 /***********************************************************************/
 /*-   skt_Listen -- Start listening on a port.				*/
 /***********************************************************************/

void
skt_Listen(
    Vm_Obj skt,
    Vm_Int address_family,	/* Typically AF_INET.		*/
    Vm_Int protocol,		/* Typically SOCK_STREAM.	*/
    Vm_Int interfaces,		/* Typically INADDR_ANY.	*/
    Vm_Int port
) {
    /* Fail if we're already using that port: */
    Skt_buffer r;
    for (r = skt_listeners;   r;   r = r->next) {
	if (r->this_port == port) {
	    MUQ_WARN ("Already have a listener on port %d", (int)port );
    }   }
    for (r = skt_udp_sockets; r;   r = r->next) {
	if (r->this_port == port) {
	    MUQ_WARN ("listen conflicts with open udp port %d", (int)port );
    }   }
    for (r = skt_buffer_lst;  r;   r = r->next) {
	if (r->this_port == port) {
	    MUQ_WARN ("listen conflicts with open tcp port %d", (int)port );
    }   }

    /* Start listening: */
    {   int fd = open_listen_port(
	    address_family,	/* Typically AF_INET.		*/
	    protocol,		/* Typically SOCK_STREAM.	*/
	    interfaces,		/* Typically INADDR_ANY.	*/
	    port
	);

	Vm_Int typ = (protocol == SOCK_STREAM) ? SKT_TYPE_EAR : SKT_TYPE_UDP;

	skt_Activate(
	    skt,
	    typ,	/* type					*/
	    fd,		/* fd to write -- not used by listeners	*/
	    fd		/* fd to read				*/
	);
	r = skt_buffer_ary[ OBJ_TO_INT( SKT_P(skt)->buf_no ) ];
	r->this_port	= port;
    }
}



/************************************************************************/
/*-    skt_Mark -- Mark all local garbage collection roots.		*/
/************************************************************************/

void
skt_Mark(
    void
) {
    Skt_buffer                b;
    for (b = skt_listeners ;  b; b = b->next)   obj_Mark( b->skt );
    for (b = skt_buffer_lst;  b; b = b->next)   obj_Mark( b->skt );
    for (b = skt_udp_sockets; b; b = b->next)   obj_Mark( b->skt );
}

/************************************************************************/
/*-    skt_All_Sockets -- Iterate over all open sockets.		*/
/************************************************************************/

int
skt_All_Sockets(
    int (*fn)( void*, Vm_Obj),
    void*  fa
) {
    Skt_buffer                b;
    for (b = skt_listeners ;  b; b = b->next)   if (!fn( fa, b->skt )) return FALSE;
    for (b = skt_buffer_lst;  b; b = b->next)   if (!fn( fa, b->skt )) return FALSE;
    for (b = skt_udp_sockets; b; b = b->next)   if (!fn( fa, b->skt )) return FALSE;
    return TRUE;
}

/************************************************************************/
/*-    skt_Replace -- Replace one skt instance with another.		*/
/************************************************************************/

void
skt_Replace(
    Vm_Obj new,
    Vm_Obj old
) {
    /****************************************************************/
    /* This function was introduced because during login the socket */
    /* and associated message streams need to be owned by root (or  */
    /* perhaps some other system user) and after login is complete  */
    /* they need to be owned by the logged-in user.  In the current */
    /* implementation ownership of an object is determined by which */
    /* dbfile the object is in, so changing ownership means making  */
    /* a duplicate of the object in a new dbfile.  Since skt keeps  */
    /* links between the heap Socket object and its internal binary */
    /* tables, we need a function to update them appropriately. Us: */
    /****************************************************************/
    Skt_buffer b = skt_buffer_ary[OBJ_TO_INT(SKT_P(old)->buf_no)];
    b->skt       = new;
}




/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    skt_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
skt_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    skt_Select_Calls_Made = 0;
}



/************************************************************************/
/*-    skt_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
skt_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    skt_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
skt_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

}


#ifdef OLD

/************************************************************************/
/*-    skt_Import -- Read  object from stringfile.			*/
/************************************************************************/

Vm_Obj
skt_Import(
    FILE* fd
) {
    MUQ_FATAL ("skt_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    skt_Export -- Write object into stringfile.			*/
/************************************************************************/

void
skt_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("skt_Export unimplemented");
}


#endif

/************************************************************************/
/*-    skt_Invariants -- Sanity check on skt.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
skt_Invariants(
    FILE* errlog,
    char* title,
    Vm_Obj skt
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, skt );
#endif
    return errs;
}




/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new skt object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    Skt_P q 		= SKT_P(o);

    q->typ		= SKT_TYPE_TTY;
    q->buf_no		= OBJ_FROM_INT( -1 );
    q->session		= OBJ_FROM_INT(0);

    q->src_filters      = SKT_FILTER_TRADITIONAL;
    q->dst_filters      = SKT_FILTER_TRADITIONAL;

    q->standard_input	= OBJ_FROM_INT(0);
    q->standard_output	= OBJ_FROM_INT(0);

    q->out_of_band_input= OBJ_FROM_INT(0);
    q->out_of_band_output=OBJ_FROM_INT(0);

    q->this_telnet_state= OBJ_FROM_INT(0);
    q->that_telnet_state= OBJ_FROM_INT(0);

    q->telnet_option_handler= OBJ_FROM_INT(0);
    q->telnet_option_lock   = OBJ_FROM_INT(0);

    q->out_of_band_job	= OBJ_FROM_INT(0);

    q->closed_by	= OBJ_NIL;
    q->exit_status	= OBJ_NIL;
    q->last_signal	= OBJ_NIL;

    q->kill_standard_output_on_exit = OBJ_FROM_INT(0);

    {   Vm_Int i;
	for (i = SKT_CHAR_EVENT_MAX;   i --> 0;  ) {
	    q->char_event[ i ] = OBJ_FROM_INT(0);
    }	}

    {   int i;
	for (i = SKT_RESERVED_SLOTS;  i --> 0; ) q->reserved_slot[i] = OBJ_FROM_INT(0);
    }

    vm_Dirty(o);
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    char* t,
    Vm_Obj skt
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif



/************************************************************************/
/*-    sizeof_skt -- Return size of input/output stream.		*/
/************************************************************************/

static Vm_Unt
sizeof_skt(
    Vm_Unt size
) {
    return sizeof( Skt_A_Header );
}







/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    skt_last_errno							*/
/************************************************************************/

static Vm_Obj
skt_last_errno(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return OBJ_NIL;

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_NIL;

    return OBJ_FROM_INT( skt_buffer_ary[ n ]->last_errno );
}

/************************************************************************/
/*-    skt_error_count							*/
/************************************************************************/

static Vm_Obj
skt_error_count(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return OBJ_NIL;

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_NIL;

    return OBJ_FROM_INT( skt_buffer_ary[ n ]->last_errno );
}

/************************************************************************/
/*-    skt_last_error							*/
/************************************************************************/

static Vm_Obj
skt_last_error(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return OBJ_NIL;

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_NIL;

    {   Vm_Int err_no = skt_buffer_ary[ n ]->last_errno;
	if (!err_no)   return OBJ_FROM_BYT0;
	#ifdef HAVE_STRERROR
	return stg_From_Asciz( strerror( err_no ) );
	#else
	{   Vm_Uch   buf[ 64 ];
	    sprintf( buf, "Error #%d", err_no );
	    return stg_From_Asciz( buf );
	}
	#endif
    }
}

/************************************************************************/
/*-    skt_session							*/
/************************************************************************/

static Vm_Obj
skt_session(
    Vm_Obj o
) {
    return SKT_P(o)->session;
}



/************************************************************************/
/*-    skt_standard_input						*/
/************************************************************************/

static Vm_Obj
skt_standard_input(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->standard_input;
    if (s == OBJ_FROM_INT(0)) {
	s =  OBJ_NIL;
    }
    return s;
}




/************************************************************************/
/*-    skt_standard_output						*/
/************************************************************************/

static Vm_Obj
skt_standard_output(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->standard_output;
    if (s == OBJ_FROM_INT(0)) {
	s =  OBJ_NIL;
    }
    return s;
}



/************************************************************************/
/*-    skt_out_of_band_job						*/
/************************************************************************/

static Vm_Obj
skt_out_of_band_job(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->out_of_band_job;
    if (s == OBJ_FROM_INT(0)) {
        s =  OBJ_NIL;
    }
    return s;
}



/************************************************************************/
/*-    skt_telnet_option_handler					*/
/************************************************************************/

static Vm_Obj
skt_telnet_option_handler(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->telnet_option_handler;
    if (s == OBJ_FROM_INT(0)) {
        s =  OBJ_NIL;
    }
    return s;
}



/************************************************************************/
/*-    skt_telnet_option_lock						*/
/************************************************************************/

static Vm_Obj
skt_telnet_option_lock(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->telnet_option_lock;
    if (s == OBJ_FROM_INT(0)) {
        s =  OBJ_NIL;
    }
    return s;
}



/************************************************************************/
/*-    skt_out_of_band_input						*/
/************************************************************************/

static Vm_Obj
skt_out_of_band_input(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->out_of_band_input;
    if (s == OBJ_FROM_INT(0)) {
        s =  OBJ_NIL;
    }
    return s;
}



/************************************************************************/
/*-    skt_out_of_band_output						*/
/************************************************************************/

static Vm_Obj
skt_out_of_band_output(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->out_of_band_output;
    if (s == OBJ_FROM_INT(0)) {
        s =  OBJ_NIL;
    }
    return s;
}



/************************************************************************/
/*-    skt_this_telnet_state						*/
/************************************************************************/

static Vm_Obj
skt_this_telnet_state(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->this_telnet_state;
    if (s == OBJ_FROM_INT(0)) {
        s =  OBJ_NIL;
    }
    return s;
}



/************************************************************************/
/*-    skt_that_telnet_state						*/
/************************************************************************/

static Vm_Obj
skt_that_telnet_state(
    Vm_Obj o
) {
    Vm_Obj s = SKT_P(o)->that_telnet_state;
    if (s == OBJ_FROM_INT(0)) {
        s =  OBJ_NIL;
    }
    return s;
}



/************************************************************************/
/*-    skt_closed_by							*/
/************************************************************************/

static Vm_Obj
skt_closed_by(
    Vm_Obj o
) {
    return SKT_P(o)->closed_by;
}



/************************************************************************/
/*-    skt_exit_status							*/
/************************************************************************/

static Vm_Obj
skt_exit_status(
    Vm_Obj o
) {
    return SKT_P(o)->exit_status;
}



/************************************************************************/
/*-    skt_last_signal							*/
/************************************************************************/

static Vm_Obj
skt_last_signal(
    Vm_Obj o
) {
    return SKT_P(o)->last_signal;
}



/************************************************************************/
/*-    skt_that_pid							*/
/************************************************************************/

static Vm_Obj
skt_that_pid(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Only SRVer SKTs have an associated pid: */
    if (p->typ!=SKT_TYPE_SRV)   return OBJ_NIL;

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_NIL;

    return OBJ_FROM_INT( skt_buffer_ary[ n ]->that_pid );
}



/************************************************************************/
/*-    skt_telnet_protocol						*/
/************************************************************************/

static Vm_Obj
skt_telnet_protocol(
    Vm_Obj o
) {
    /* For now at least, the TELNET_PROTOCOL bits */
    /* on dst_filters and src_filters are always  */
    /* set to the same value:                     */
    return (
       (SKT_P(o)->dst_filters & SKT_TELNET_PROTOCOL)   ?
	OBJ_T					       :
	OBJ_NIL
    );
}



/************************************************************************/
/*-    skt_discard_netbound_data       					*/
/************************************************************************/

static Vm_Obj
skt_discard_netbound_data(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return OBJ_NIL;

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_NIL;

    return (
	skt_buffer_ary[ n ]->discard_netbound_data  ?
	OBJ_T					:
	OBJ_NIL
    );
}

/************************************************************************/
/*-    skt_filter_cr_i	              					*/
/************************************************************************/

static Vm_Obj
skt_filter_cr_i(
    Vm_Obj o
) {
    return (
       (SKT_P(o)->dst_filters & SKT_FILTER_CRNL)   ?
	OBJ_T					   :
	OBJ_NIL
    );
}

/************************************************************************/
/*-    skt_filter_cr_o	              					*/
/************************************************************************/

static Vm_Obj
skt_filter_cr_o(
    Vm_Obj o
) {
    return (
       (SKT_P(o)->src_filters & SKT_FILTER_CRNL)   ?
	OBJ_T					   :
	OBJ_NIL
    );
}

/************************************************************************/
/*-    skt_by_lines_i              					*/
/************************************************************************/

static Vm_Obj
skt_by_lines_i(
    Vm_Obj o
) {
    return (
       (SKT_P(o)->dst_filters & SKT_FILTER_BY_LINES)   ?
	OBJ_T					       :
	OBJ_NIL
    );
}

 /***********************************************************************/
 /*-    skt_kill_stdout_on_exit						*/
 /***********************************************************************/

static Vm_Obj
skt_kill_stdout_on_exit(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( SKT_P(o)->kill_standard_output_on_exit != OBJ_0 );
}

/************************************************************************/
/*-    skt_pass_nonprint_from_net      					*/
/************************************************************************/

static Vm_Obj
skt_pass_nonprint_from_net(
    Vm_Obj o
) {
    return (
       (SKT_P(o)->dst_filters & SKT_PASS_NONPRINTING)   ?
	OBJ_T						:
	OBJ_NIL
    );
}



/************************************************************************/
/*-    skt_pass_nonprint_to_net        					*/
/************************************************************************/

static Vm_Obj
skt_pass_nonprint_to_net(
    Vm_Obj o
) {
    return (
        (SKT_P(o)->src_filters & SKT_PASS_NONPRINTING)  ?
	OBJ_T						:
	OBJ_NIL
    );
}



/************************************************************************/
/*-    skt_type		              					*/
/************************************************************************/

static Vm_Obj
skt_type(
    Vm_Obj o
) {
    switch (SKT_P(o)->typ) {
    case SKT_TYPE_BAT: return job_Kw_Batch;
    case SKT_TYPE_TTY: return job_Kw_Tty;
    case SKT_TYPE_TCP: return job_Kw_Tcp;
    case SKT_TYPE_UDP: return job_Kw_Udp;
    case SKT_TYPE_EOF: return job_Kw_Eof;
    case SKT_TYPE_EAR: return job_Kw_Ear;
    case SKT_TYPE_SRV: return job_Kw_Popen;
    default:
	MUQ_FATAL("skt_type: internal err");
	return 0; /* To quiet compilers. */
    }
}



/************************************************************************/
/*-    skt_this_port	              					*/
/************************************************************************/

static Vm_Obj
skt_this_port(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return OBJ_FROM_INT(0);

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_FROM_INT(0);

    /* Port info is potentially somewhat private: */
    if (jS.j.acting_user != obj_Owner(o)
    && (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    ||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
    ){
	/* Note however that users can scan for open */
        /* ports by repeatedly trying to open them,  */
        /* observing when a port comes into use, and */
	/* deducing the probable user of the port    */
	/* from other information. If this becomes a */
	/* a privacy issue, may need to sleep job    */
	/* for a second after a failed open or such. */
	return OBJ_FROM_INT(0);
    }

    return OBJ_FROM_INT( skt_buffer_ary[ n ]->this_port );
}



/************************************************************************/
/*-    skt_that_port	              					*/
/************************************************************************/

static Vm_Obj
skt_that_port(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return OBJ_FROM_INT(0);

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_FROM_INT(0);

    /* Port info is potentially somewhat private: */
    if (jS.j.acting_user != obj_Owner(o)
    && (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    ||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
    ){
	return OBJ_FROM_INT(0);
    }

    return OBJ_FROM_INT( skt_buffer_ary[ n ]->that_port );
}



/************************************************************************/
/*-    skt_ip0		              					*/
/************************************************************************/

 /***********************************************************************/
 /*-   skt_ipn		              					*/
 /***********************************************************************/

static Vm_Obj
skt_ipn(
    Vm_Obj o,
    Vm_Int shift
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return OBJ_FROM_INT(0);

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_FROM_INT(0);

    /* Port info is potentially somewhat private: */
    if (jS.j.acting_user != obj_Owner(o)
    && (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    ||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
    ){
	return OBJ_FROM_INT(0);
    }

    {	Vm_Unt ip = skt_buffer_ary[ n ]->that_ip[3];
	return OBJ_FROM_INT( (ip >> shift) & 0xFF );
    }
}

 /***********************************************************************/
 /*-   skt_ip0		              					*/
 /***********************************************************************/

static Vm_Obj
skt_ip0(
    Vm_Obj o
) {
    return skt_ipn( o, 24 );
}

/************************************************************************/
/*-    skt_ip1		              					*/
/************************************************************************/

static Vm_Obj
skt_ip1(
    Vm_Obj o
) {
    return skt_ipn( o, 16 );
}


/************************************************************************/
/*-    skt_ip2		              					*/
/************************************************************************/

static Vm_Obj
skt_ip2(
    Vm_Obj o
) {
    return skt_ipn( o, 8 );
}


/************************************************************************/
/*-    skt_ip3		              					*/
/************************************************************************/

static Vm_Obj
skt_ip3(
    Vm_Obj o
) {
    return skt_ipn( o, 0 );
}


/************************************************************************/
/*-    skt_that_address	              					*/
/************************************************************************/

static Vm_Obj
skt_that_address(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return OBJ_FROM_BYT0;

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return OBJ_FROM_BYT0;

    /* Port info is potentially somewhat private: */
    if (jS.j.acting_user != obj_Owner(o)
    && (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    ||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
    ){
	return OBJ_FROM_BYT0;
    }

    {   Vm_Uch buf[ 132 ];
	Vm_Unt ip = skt_buffer_ary[ n ]->that_ip[3];
	if (!ip) return OBJ_FROM_BYT0;
	sprintf(
	    buf,
	    "%d.%d.%d.%d",
	    (int)((ip >> 24) & 0xFF),
	    (int)((ip >> 16) & 0xFF),
	    (int)((ip >>  8) & 0xFF),
	    (int)((ip      ) & 0xFF)
	);
	return stg_From_Asciz( buf );
    }
}



/************************************************************************/
/*-    skt_fd_to_read	              					*/
/************************************************************************/

static Vm_Obj
skt_fd_to_read(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* FD info is potentially somewhat private: */
    if (jS.j.acting_user != obj_Owner(o)
    && (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    ||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
    ){
	return OBJ_NIL;
    }

    /* Dead SKTs and unopened SKTs */
    /* have no associated buffer:  */
    if (p->typ==SKT_TYPE_EOF || n < 0)   return OBJ_NIL;

    return OBJ_FROM_INT( skt_buffer_ary[ n ]->src_fd );
}

/************************************************************************/
/*-    skt_fd_to_write	              					*/
/************************************************************************/

static Vm_Obj
skt_fd_to_write(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* FD info is potentially somewhat private: */
    if (jS.j.acting_user != obj_Owner(o)
    && (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    ||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
    ){
	return OBJ_NIL;
    }

    /* Dead SKTs and unopened SKTs */
    /* have no associated buffer:  */
    if (p->typ==SKT_TYPE_EOF || n < 0)   return OBJ_NIL;

    return OBJ_FROM_INT( skt_buffer_ary[ n ]->dst_fd );
}

/************************************************************************/
/*-    skt_outdrain_milliseconds            				*/
/************************************************************************/

static Vm_Obj
skt_outdrain_milliseconds(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs and unopened SKTs */
    /* have no associated buffer:  */
    if (p->typ==SKT_TYPE_EOF || n < 0) {
	return OBJ_FROM_INT( SKT_OUTDRAIN_MILLISECONDS );
    }
    return OBJ_FROM_INT( skt_buffer_ary[ n ]->outdrain_milliseconds );
}

/************************************************************************/
/*-    skt_eofwait_milliseconds            				*/
/************************************************************************/

static Vm_Obj
skt_eofwait_milliseconds(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs and unopened SKTs */
    /* have no associated buffer:  */
    if (p->typ==SKT_TYPE_EOF || n < 0) {
	return OBJ_FROM_INT( SKT_EOFWAIT_MILLISECONDS );
    }
    return OBJ_FROM_INT( skt_buffer_ary[ n ]->eofwait_milliseconds );
}

/************************************************************************/
/*-    skt_hupwait_milliseconds            				*/
/************************************************************************/

static Vm_Obj
skt_hupwait_milliseconds(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs and unopened SKTs */
    /* have no associated buffer:  */
    if (p->typ==SKT_TYPE_EOF || n < 0) {
	return OBJ_FROM_INT( SKT_HUPWAIT_MILLISECONDS );
    }
    return OBJ_FROM_INT( skt_buffer_ary[ n ]->hupwait_milliseconds );
}

/************************************************************************/
/*-    skt_killwait_milliseconds            				*/
/************************************************************************/

static Vm_Obj
skt_killwait_milliseconds(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs and unopened SKTs */
    /* have no associated buffer:  */
    if (p->typ==SKT_TYPE_EOF || n < 0) {
	return OBJ_FROM_INT( SKT_KILLWAIT_MILLISECONDS );
    }
    return OBJ_FROM_INT( skt_buffer_ary[ n ]->killwait_milliseconds );
}

/************************************************************************/
/*-    skt_indrain_milliseconds            				*/
/************************************************************************/

static Vm_Obj
skt_indrain_milliseconds(
    Vm_Obj o
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Dead SKTs and unopened SKTs */
    /* have no associated buffer:  */
    if (p->typ==SKT_TYPE_EOF || n < 0) {
	return OBJ_FROM_INT( SKT_INDRAIN_MILLISECONDS );
    }
    return OBJ_FROM_INT( skt_buffer_ary[ n ]->indrain_milliseconds );
}

/************************************************************************/
/*-    skt_set_outdrain_milliseconds					*/
/************************************************************************/

static Vm_Obj
skt_set_outdrain_milliseconds(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );
    Vm_Int s = OBJ_TO_UNT( v );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)                  return (Vm_Obj) 0;
    if (!OBJ_IS_INT(v))         return (Vm_Obj) 0;
   
    skt_buffer_ary[ n ]->outdrain_milliseconds = s;

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    skt_set_eofwait_milliseconds					*/
/************************************************************************/

static Vm_Obj
skt_set_eofwait_milliseconds(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );
    Vm_Int s = OBJ_TO_UNT( v );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)                  return (Vm_Obj) 0;
    if (!OBJ_IS_INT(v))         return (Vm_Obj) 0;
   
    skt_buffer_ary[ n ]->eofwait_milliseconds = s;

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    skt_set_hupwait_milliseconds					*/
/************************************************************************/

static Vm_Obj
skt_set_hupwait_milliseconds(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );
    Vm_Int s = OBJ_TO_UNT( v );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)                  return (Vm_Obj) 0;
    if (!OBJ_IS_INT(v))         return (Vm_Obj) 0;
   
    skt_buffer_ary[ n ]->hupwait_milliseconds = s;

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    skt_set_killwait_milliseconds					*/
/************************************************************************/

static Vm_Obj
skt_set_killwait_milliseconds(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );
    Vm_Int s = OBJ_TO_UNT( v );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)                  return (Vm_Obj) 0;
    if (!OBJ_IS_INT(v))         return (Vm_Obj) 0;
   
    skt_buffer_ary[ n ]->killwait_milliseconds = s;

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    skt_set_indrain_milliseconds					*/
/************************************************************************/

static Vm_Obj
skt_set_indrain_milliseconds(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );
    Vm_Int s = OBJ_TO_UNT( v );

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)                  return (Vm_Obj) 0;
    if (!OBJ_IS_INT(v))         return (Vm_Obj) 0;
   
    skt_buffer_ary[ n ]->indrain_milliseconds = s;

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    skt_set_session							*/
/************************************************************************/

static Vm_Obj
skt_set_session(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_SSN(v)) {
	SKT_P(o)->session = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_standard_input						*/
/************************************************************************/

static Vm_Obj
skt_set_standard_input(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	SKT_P(o)->standard_input = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_standard_output						*/
/************************************************************************/

static Vm_Obj
skt_set_standard_output(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	SKT_P(o)->standard_output = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_out_of_band_job						*/
/************************************************************************/

static Vm_Obj
skt_set_out_of_band_job(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL) {
	SKT_P(o)->out_of_band_job = OBJ_FROM_INT(0);
	vm_Dirty(o);
    } else if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_JOB(v)) {
	SKT_P(o)->out_of_band_job = v;
	vm_Dirty(o);
    }

    return (Vm_Obj) 0;
}


/************************************************************************/
/*-    skt_set_telnet_option_handler					*/
/************************************************************************/

static Vm_Obj
skt_set_telnet_option_handler(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL) {
	SKT_P(o)->telnet_option_handler = OBJ_FROM_INT(0);
	vm_Dirty(o);
    } else if (OBJ_IS_VEC(v)) {
	SKT_P(o)->telnet_option_handler = v;
	vm_Dirty(o);
    }

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_telnet_option_lock					*/
/************************************************************************/

static Vm_Obj
skt_set_telnet_option_lock(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL) {
	SKT_P(o)->telnet_option_lock = OBJ_FROM_INT(0);
	vm_Dirty(o);
    } else if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_LOK(v)) {
	SKT_P(o)->telnet_option_lock = v;
	vm_Dirty(o);
    }

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_out_of_band_input					*/
/************************************************************************/

static Vm_Obj
skt_set_out_of_band_input(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL) {
	SKT_P(o)->out_of_band_input = OBJ_FROM_INT(0);
	vm_Dirty(o);
    } else if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	SKT_P(o)->out_of_band_input = v;
	vm_Dirty(o);
    }

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_out_of_band_output					*/
/************************************************************************/

static Vm_Obj
skt_set_out_of_band_output(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL) {
	SKT_P(o)->out_of_band_output = OBJ_FROM_INT(0);
	vm_Dirty(o);
    } else if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	SKT_P(o)->out_of_band_output = v;
	vm_Dirty(o);
    }

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_this_telnet_state					*/
/************************************************************************/

static Vm_Obj
skt_set_this_telnet_state(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL) {
	SKT_P(o)->this_telnet_state = OBJ_FROM_INT(0);
	vm_Dirty(o);
    } else if (OBJ_IS_BYTN(v) && stg_Len(v)==256) {
	SKT_P(o)->this_telnet_state = v;
	vm_Dirty(o);
    }

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_that_telnet_state					*/
/************************************************************************/

static Vm_Obj
skt_set_that_telnet_state(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL) {
	SKT_P(o)->that_telnet_state = OBJ_FROM_INT(0);
	vm_Dirty(o);
    } else if (OBJ_IS_BYTN(v) && stg_Len(v)==256) {
	SKT_P(o)->that_telnet_state = v;
	vm_Dirty(o);
    }

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_telnet_protocol						*/
/************************************************************************/

static Vm_Obj
skt_set_telnet_protocol(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Set bits as requested.  We use two   */
    /* on the offchance we'll someday want  */
    /* to allow separate control of inbound */
    /* and outbound TELNET protocol process */
    /* -ing, but currently always set them  */
    /* together:                            */
    if (v==OBJ_T  ) {
	p->dst_filters |= SKT_TELNET_PROTOCOL;
	p->src_filters |= SKT_TELNET_PROTOCOL;
    }
    if (v==OBJ_NIL) {
	p->dst_filters &=~SKT_TELNET_PROTOCOL;
	p->src_filters &=~SKT_TELNET_PROTOCOL;
    }

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return (Vm_Obj) 0;

    /* Mirror bit in nonsoftvirtual memory: */
    skt_buffer_ary[ n ]->dst_filters = p->dst_filters;
    skt_buffer_ary[ n ]->src_filters = p->src_filters;

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_filter_cr_i             					*/
/************************************************************************/

static Vm_Obj
skt_set_filter_cr_i(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Set bit as requested: */
    if (v==OBJ_T  )   p->dst_filters |= SKT_FILTER_CRNL;
    if (v==OBJ_NIL)   p->dst_filters &=~SKT_FILTER_CRNL;

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return (Vm_Obj) 0;

    /* Mirror bit in nonsoftvirtual memory: */
    skt_buffer_ary[ n ]->dst_filters = p->dst_filters;

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_filter_cr_o             					*/
/************************************************************************/

static Vm_Obj
skt_set_filter_cr_o(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Set bit as requested: */
    if (v==OBJ_T  )   p->src_filters |= SKT_FILTER_CRNL;
    if (v==OBJ_NIL)   p->src_filters &=~SKT_FILTER_CRNL;

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return (Vm_Obj) 0;

    /* Mirror bit in nonsoftvirtual memory: */
    skt_buffer_ary[ n ]->src_filters = p->src_filters;

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_discard_netbound_data   					*/
/************************************************************************/

static Vm_Obj
skt_set_discard_netbound_data(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );
    Vm_Int discard = (v != OBJ_NIL);
    Skt_buffer b;

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;

    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return (Vm_Obj) 0;

    b = skt_buffer_ary[ n ];
    b->discard_netbound_data = discard;

    if (discard) {
	/* Discard any data already in buffer: */
	b->src_nxt = 0;
    }

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_by_lines_i             					*/
/************************************************************************/

static Vm_Obj
skt_set_by_lines_i(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Set bit as requested: */
    if (v==OBJ_T  )   p->dst_filters |= SKT_FILTER_BY_LINES;
    if (v==OBJ_NIL)   p->dst_filters &=~SKT_FILTER_BY_LINES;

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return (Vm_Obj) 0;

    /* Mirror bit in nonsoftvirtual memory: */
    skt_buffer_ary[ n ]->dst_filters = p->dst_filters;

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_pass_nonprint_from_net  					*/
/************************************************************************/

static Vm_Obj
skt_set_pass_nonprint_from_net(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Set bit as requested: */
    if (v==OBJ_T  )  p->dst_filters |= SKT_PASS_NONPRINTING;
    if (v==OBJ_NIL)  p->dst_filters &=~SKT_PASS_NONPRINTING;

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return (Vm_Obj) 0;

    /* Mirror bit in nonsoftvirtual memory: */
    skt_buffer_ary[ n ]->dst_filters = p->dst_filters;

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    skt_set_pass_nonprint_to_net    					*/
/************************************************************************/

static Vm_Obj
skt_set_pass_nonprint_to_net(
    Vm_Obj o,
    Vm_Obj v
) {
    Skt_P  p = SKT_P(o);
    Vm_Int n = OBJ_TO_INT( p->buf_no );

    /* Set bit as requested: */
    if (v==OBJ_T  )  p->src_filters |= SKT_PASS_NONPRINTING;
    if (v==OBJ_NIL)  p->src_filters &=~SKT_PASS_NONPRINTING;

    /* Dead SKTs have no associated buffer: */
    if (p->typ==SKT_TYPE_EOF)   return (Vm_Obj) 0;
    /* Unopened SKTs likewise have no associated buffer: */
    if (n < 0)   return (Vm_Obj) 0;

    /* Mirror bit in nonsoftvirtual memory: */
    skt_buffer_ary[ n ]->src_filters = p->src_filters;

    return (Vm_Obj) 0;
}


 /***********************************************************************/
 /*-    skt_set_kill_stdout_on_exit					*/
 /***********************************************************************/

static Vm_Obj
skt_set_kill_stdout_on_exit(
    Vm_Obj o,
    Vm_Obj v
) {
    SKT_P(o)->kill_standard_output_on_exit = OBJ_FROM_INT( v != OBJ_NIL );
    vm_Dirty(o);
    return (Vm_Obj) 0;
}


/************************************************************************/
/*-    skt_set_never             					*/
/************************************************************************/

static Vm_Obj
skt_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    kill_nonprinting_chars -- Remove chars with high bit set etc.	*/
/************************************************************************/

/* Returns new length of buffer.			 */

#ifdef OLD
static Vm_Int
kill_nonprinting_chars(
    Vm_Uch* buf,
    Vm_Int  len
) {
    register Vm_Int  i   = len;
    register Vm_Uch* cat = buf;
    register Vm_Uch* rat = buf;
    while (i --> 0) {
        register int c = *rat++;

	if (isprint(c) || isspace(c))   *cat++ = c;
    }

    return cat - buf;
}
#endif



/************************************************************************/
/*-    ff_to_ffff -- Expand \377 s to \377\377 s in buffer (for TELNET)	*/
/************************************************************************/

/* Returns new length of buffer.			 */
/* MAKE SURE YOU HAVE ROOM FOR BUFFER TO DOUBLE IN SIZE! */
/* (This is the worst case, obviously.			 */

static Vm_Int
ff_to_ffff(
    Vm_Uch* buf,
    Vm_Int  len
) {
    /* Count number of FF in buffer: */
    register Vm_Int  i   = len;
    register Vm_Int  ffs = 0;
    register Vm_Uch* cat = buf;
    register Vm_Uch* rat = buf;
    while (i --> 0)   if (*cat++ == 0xFF)   ++ffs;

    /* Expand FFs: */
    rat = buf+len;
    cat = rat+ffs;
    for (i = len;   i --> 0;   ) {
	if ((*--cat = *--rat) == 0xFF)   *--cat = 0xFF;
    }

    return len + ffs;
}



/************************************************************************/
/*-    nl_to_crnl -- Expand \n s to \r\n s in a buffer.			*/
/************************************************************************/

/* Returns new length of buffer.			 */
/* MAKE SURE YOU HAVE ROOM FOR BUFFER TO DOUBLE IN SIZE! */
/* (This is the worst case, obviously.			 */

static Vm_Int
nl_to_crnl(
    Vm_Uch* buf,
    Vm_Int  len
) {
    /* Count number of newlines in buffer: */
    register Vm_Int  i   = len;
    register Vm_Int  nls = 0;
    register Vm_Uch* cat = buf;
    register Vm_Uch* rat = buf;
    while (i --> 0)   if (*cat++ == '\n')   ++nls;

    /* Expand newlines: */
    rat = buf+len;
    cat = rat+nls;
    for (i = len;   i --> 0;   ) {
	if ((*--cat = *--rat) == '\n')   *--cat = '\r';
    }

    return len + nls;
}



/************************************************************************/
/*-    buf_alloc -- Return integer skt_buffer[] index.			*/
/************************************************************************/

static Vm_Unt
buf_alloc(
    Vm_Obj skt,
    Vm_Obj typ		/* SKT_TYPE_EAR or such.	*/
) {
    Skt_buffer* buffer_list = NULL; /* Initialized just to quiet compilers. */
    Vm_Unt n;
    Vm_Obj dst_filters;
    Vm_Obj src_filters;
    {   Skt_P p = SKT_P(skt);
	dst_filters = p->dst_filters;
	src_filters = p->src_filters;
    }

    switch (typ) {

    case SKT_TYPE_SRV:
    case SKT_TYPE_TTY:
    case SKT_TYPE_TCP:
    case SKT_TYPE_BAT: buffer_list = &skt_buffer_lst;	break;

    case SKT_TYPE_UDP: buffer_list = &skt_udp_sockets;	break;

    case SKT_TYPE_EAR: buffer_list = &skt_listeners;	break;

    case SKT_TYPE_EOF:
    default:
	MUQ_FATAL("skt:buf_alloc: internal err");
    }

    for   (n = SKT_MAX_STREAMS;   n --> 0; ) {
	if (!skt_buffer_ary[ n ]) {

	    Skt_buffer b = (Skt_buffer) lib_Malloc( sizeof( Skt_a_buffer ) );
	    skt_buffer_ary[n] = b;
	    b->skt            = skt;
	    b->skt_state      = SKT_OPEN;
	    b->started_waiting_at = 0;
	    b->discard_netbound_data = FALSE;
	    b->typ	      = typ;
	    b->src_filters    = src_filters;
	    b->dst_filters    = dst_filters;
	    b->n              = n;
	    b->src_fd         = 0;
	    b->dst_fd         = 0;
	    b->this_port      = 0;
	    b->that_port      = 0;
	    b->that_ip[0]     = 0;
	    b->that_ip[1]     = 0;
	    b->that_ip[2]     = 0;
	    b->that_ip[3]     = 0;

	    b->that_pid       = 0;

	    b->last_errno     = 0;
	    b->error_count    = 0;

	    b->recv_port      = 0;
	    b->recv_ip[0]     = 0;
	    b->recv_ip[1]     = 0;
	    b->recv_ip[2]     = 0;
	    b->recv_ip[3]     = 0;

	    b->prefix	      = NULL;	/* Prefix to all output.	*/
	    b->suffix	      = NULL;	/* Suffix to all output.	*/
	    b->next           = *buffer_list;

	    b->outdrain_milliseconds	= SKT_OUTDRAIN_MILLISECONDS;
	    b->eofwait_milliseconds  = SKT_EOFWAIT_MILLISECONDS;
	    b->hupwait_milliseconds  = SKT_HUPWAIT_MILLISECONDS;
	    b->killwait_milliseconds = SKT_KILLWAIT_MILLISECONDS;
	    b->indrain_milliseconds  = SKT_INDRAIN_MILLISECONDS;

	    *buffer_list      = b;
	    buf_reset( n );
	    return n;
	}
    }
    MUQ_FATAL ("out of socket buffers! Expand SKT_MAX_STREAMS.");
    return 0; /* Pacify gcc. */
}



/************************************************************************/
/*-    buf_first_nl -- Return offset of first newline in buffer else -1.*/
/************************************************************************/

static Vm_Int
buf_first_nl(
    Vm_Uch* buf,
    Vm_Uch* end
) {
    register Vm_Uch* cat = buf;
    register Vm_Uch* lim = end;
    while (cat < lim) 	if (*cat++ == '\n')   return (cat - buf) -1;
    return -1;
}



/************************************************************************/
/*-    doing_metadata -- Return offset of first byte past segment end	*/
/************************************************************************/

/* BUGGO: This fn has a very serious performance bug.               */
/* A quick gprof analysis of muq compiling its libraries            */
/* suggests that something like half the CPU time is spent          */
/* in doing_metadata() and vicinity: Each time we process output,   */
/* doing_metadata() winds up counting through 4096 or so bytes      */
/* of buffer, of which we use less than 1K.  Furthermore, our       */
/* parent routine does a memmove() of almost the entire buffer	    */
/* contents after processing each line.                             */
/*   It would be much prettier if we made the buffer be circular,   */
/* so we don't have to shuffle the entire thing on each operation,  */
/* and also cached the results of the last doing_metadata() call so */
/* as to not have to re-do most of it again on the next call.       */
/*   LATER: Well, using memchr() papers over the problem pretty     */
/* effectively on Linux/x86, but we should still fix it sometime.   */
static Vm_Int
doing_metadata(
    Vm_Int*    segment_len,
    Skt_buffer b
) {
    /****************************************/
    /* Pick output stream to use, maximum   */
    /* number of contiguous bytes we can    */
    /* write to it, and state in which to   */
    /* begin scan.                          */
    /****************************************/
    for (;;) {
	register Vm_Uch* cat = &b->dst_byt[          0 ];
	register Vm_Uch* lim = &b->dst_byt[ b->dst_nxt ];
	register Vm_Int  last= 0;
	register Vm_Int  this;

	/* If we're not doing TELNET protocol   */
	/* processing we always write to stdout:*/
	if (!(b->dst_filters & SKT_TELNET_PROTOCOL)
	||  !(b->dst_nxt)
	){
	    *segment_len = b->dst_nxt;
	    return FALSE;
	}

	/* Treat one byte in buffer as special case: */
	if (b->dst_nxt == 1) {
	    *segment_len = (b->dst_byt[0] != SKT_TELNET_IS_A_COMMAND);
	    return FALSE;
	}

	/* We are doing TELNET protocol      */
	/* processing.  See if we have an    */
	/* escape sequence at start of buf:  */

	if (b->dst_byt[ 0 ] != SKT_TELNET_IS_A_COMMAND
	||  b->dst_byt[ 1 ] == SKT_TELNET_IS_A_COMMAND
	){
	    /* We're doing vanilla user data.     */

	    /* Count bytes up to the next TELNET  */
	    /* command (excluding IAC-IAC pairs): */
#ifndef NEW
	    for (;  cat < lim;  ++cat) {
	        /* When I switched to using this memchr() call */
	        /* instead of a by-hand loop, it chopped the   */
	        /* Muq library install time from 3 minutes to  */
	        /* 2 on my 48Meg ram 100MHz Pentium laptop:    */
	        /* This function is obviously a hotspot, which */
	        /* it really has no business being. 97Dec28CrT */
	        Vm_Uch* newcat = memchr(cat,SKT_TELNET_IS_A_COMMAND,lim-cat);
	        if (!newcat) {
		    cat  = lim;
		    this = 0;
		    last = cat[-1];
		    break;
	        } else {
		    cat  = newcat+1;
		    if (cat == lim) {
			this = 0;
			last = cat[-1];
			break;
		    } else {
			this = cat[ 0];
			last = cat[-1];
		    }
	        }
#else
	    for(;
		cat < lim;
		++cat, last=this
	    ){
                #if MUQ_IS_PARANOID
		if (cat <  &b->dst_byt[               0 ]
		||  cat >= &b->dst_byt[ SKT_DST_BYT_SIZ ]
		){
		    MUQ_FATAL("doing_metadata");
		}
		#endif
		this = *cat;
#endif
		if (last == SKT_TELNET_IS_A_COMMAND) {

		    switch (this) {

		    case SKT_TELNET_IS_A_COMMAND:
			this = 0; /* Not really an IAC, just a quoted 0xFF */
			continue;

		    case SKT_TELNET_ERASE_LINE:
			{   Vm_Int  bytes_zapped;
			    Vm_Uch* beg = b->dst_byt;
			    Vm_Uch* eol = cat-1;
			    while (eol > beg && eol[-1] >= ' ')   --eol;
			    memmove( eol, cat+1, lim-(cat+1) );
			    bytes_zapped= (cat+1)-eol;
			    cat        -= bytes_zapped;
			    lim        -= bytes_zapped;
			    b->dst_nxt -= bytes_zapped;
			}
			continue;

		    case SKT_TELNET_ERASE_CHAR:
			if (b->dst_nxt == 2) {
			    memmove( cat-1, cat+1, lim-(cat+1) );
			    cat        -= 2;
			    lim        -= 2;
			    b->dst_nxt -= 2;
			} else {
			    memmove( cat-2, cat+1, lim-(cat+1) );
			    cat        -= 3;
			    lim        -= 3;
			    b->dst_nxt -= 3;
			}
			continue;

		    default:
			/* Everything up to last */
			/* byte is fair game:    */
			*segment_len = --cat - b->dst_byt;
			return FALSE;
		    }
		}
	    }

	    /* If very last byte is an  */
	    /* IAC, we must not copy it */
	    /* yet:                     */
	    if (last == SKT_TELNET_IS_A_COMMAND)   --cat;
	    *segment_len = cat - b->dst_byt;
	    return FALSE;
	}

	/* OK, we've got a TELNET command. */
	/* These are all two bytes except  */
	/* for IAC SB ... IAC SE strings   */
	/* and 3-byte DO/DONT/WILL/WONT:   */
	if (b->dst_byt[ 1 ] < SKT_TELNET_SUBOPTION_BEGIN) {
	    if (b->dst_byt[1] == SKT_TELNET_ERASE_CHAR
	    ||  b->dst_byt[1] == SKT_TELNET_ERASE_LINE
	    ){
		/* This command arrived too late */
		/* to handle.  Just ignore it:   */
		b->dst_nxt -= 2;
		memmove( b->dst_byt, b->dst_byt+2, b->dst_nxt );
		continue;
	    }
	    *segment_len = 2;
	    return TRUE;
	}
	if (b->dst_byt[ 1 ] > SKT_TELNET_SUBOPTION_BEGIN) {
	    if (b->dst_nxt == 2) {
		/* Don't have all of command in */
		/* buffer yet, need to wait for */
		/* 3rd byte to arrive from net: */
		*segment_len = 0;
		return FALSE;
	    }
	    *segment_len = 3;
	    return TRUE;
	}

	/* Count number of bytes in string.  */
	/* If it is incomplete, return zero  */
	/* as number of processable bytes,   */
	/* unless we have a buffer overflow: */
	for(;
	    cat < lim;
	    ++cat, last=this
	){
	    this = *cat;
	    if (last == SKT_TELNET_IS_A_COMMAND) {
		if (this == SKT_TELNET_IS_A_COMMAND) {
		    this = 0; /* Not really an IAC, just a quoted 0xFF */
		    continue;
		}
		if (this == SKT_TELNET_SUBOPTION_END) {
		    /* Everything up to next */
		    /* byte is fair game:    */
		    *segment_len = ++cat - b->dst_byt;
		    return TRUE;
		}
	    }
	}

	/* Option isn't complete. */

	/* If it's a bufferful, send it anyhow: */
	if (cat - b->dst_byt >= MSS_MAX_MSG_VECTOR) {
	    *segment_len = MSS_MAX_MSG_VECTOR;
	    return TRUE;
	}

	/* Wait for rest of option substring: */
	*segment_len = 0;
	return FALSE;
    }
}



/************************************************************************/
/*-    buf_logically_close -- Mark buffer/socket to be closed.		*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static void
buf_logically_close(
    Vm_Unt n
) {
    #if MUQ_IS_PARANOID
    if (n > SKT_MAX_STREAMS
    ||  !skt_buffer_ary[n]
    ){
	MUQ_FATAL ("Internal err.");
    }
    if (skt_buffer_ary[n]->skt_state == SKT_CLOSED) {
	MUQ_FATAL ("Logical close on non-open skt!");

    }
    #endif

    /************************************************/
    /* After re/writing tinyMuck2.3, Dave Moore's   */
    /* advice was to physically close sockets in    */
    /* only one execution context, and merely	    */
    /* set a flag elsewhere.  This reduces the      */
    /* number of bugs due to deleting a buffer from */
    /* a linklist while someone is traversing that  */
    /* linklist (for example).  Sounds reasonable:  */
    /************************************************/
    skt_buffer_ary[n]->skt_state   = SKT_CLOSED;
    skt_need_to_close_some_sockets = TRUE;
}
#endif



/************************************************************************/
/*-    buf_physically_close_all_marked_sockets --			*/
/************************************************************************/


/************************************************************************/
/*-    buf_physically_close_one_socket --				*/
/************************************************************************/

static void
buf_physically_close_one_socket(
    Skt_buffer b
) {
    /* Tell session leader socket is now closed. */
    /* But not if we're shutting down and leader */
    /* can never run again anyhow:               */
    if (!skt_Is_Closing_Down) {
	skt_signal_broken_pipe( b );
    }
/*printf("buf_physically_close_one_socket(%p)/back from signal...\n",b);*/

    if (b->typ == SKT_TYPE_TCP) {
	lib_Log_Printf(
	    "TCP disconnect from %d,%d.%d.%d:%d (local port %d)\n",
	    (int)(b->that_ip[3] >> 24 & 0xFF),
	    (int)(b->that_ip[3] >> 16 & 0xFF),
	    (int)(b->that_ip[3] >>  8 & 0xFF),
	    (int)(b->that_ip[3] >>  0 & 0xFF),
	    (int)b->that_port,
	    (int)b->this_port
	);
    }

    switch (b->typ) {

    case SKT_TYPE_SRV:
/*printf("buf_physically_close_one_socket(%p)/SRV...\n",b);*/
	/* We may have pipes either or both directions: */
	if (b->src_fd != -1)   close( b->src_fd );
	if (b->dst_fd != -1)   close( b->dst_fd );
	break;

    case SKT_TYPE_BAT:
/*printf("buf_physically_close_one_socket(%p)/BAT...\n",b);*/
	/* For BAT files, b->src_fd is stdout,  */
	/* simplifies debugging if we don't     */
	/* close it, so we only do b->dst_fd:   */
	if (b->dst_fd != -1)   close( b->dst_fd );
	break;

    default:
	/* Shut down both directions on socket: */
	shutdown( b->src_fd, 2 ); /* 0==input_only 1==output_only.	*/
    }

    /* Mark socket as EOF, and maybe */
    /* mark output stream as dead:   */
    {   Skt_P s   = SKT_P(b->skt);
	s->typ    = SKT_TYPE_EOF;
	s->buf_no = OBJ_FROM_INT(-1);

	vm_Dirty(b->skt);
	if (s->kill_standard_output_on_exit != OBJ_FROM_INT(0)) {
	    Vm_Obj mss = s->standard_output;
	    if (OBJ_IS_OBJ(mss) && OBJ_IS_CLASS_MSS(mss)) {
		MSS_P(mss)->dead = OBJ_T;
		vm_Dirty(mss);
    }   }   }

    /* Free all ram associated with socket, */
    /* and clear known pointers to such:    */
    if (b->prefix)   free( b->prefix );
    if (b->suffix)   free( b->suffix );
    skt_buffer_ary[ b->n ] = NULL;

    /* Delete b from buffer linklist: */
    switch (b->typ) {

    case SKT_TYPE_EAR:
	if (skt_listeners == b) {
	    skt_listeners  = b->next;
	} else {
	    Skt_buffer p;
	    /* Should we consider a doubly linked list? */
	    for (p = skt_listeners;   p->next != b;   p = p->next);
	    p->next = b->next;
	}
	break;

    case SKT_TYPE_UDP:
	if (skt_udp_sockets == b) {
	    skt_udp_sockets  = b->next;
	} else {
	    Skt_buffer p;
	    for (p = skt_udp_sockets;   p->next != b;   p = p->next);
	    p->next = b->next;
	}
	break;

     default:
	if (skt_buffer_lst == b) {
	    skt_buffer_lst  = b->next;
	} else {
	    Skt_buffer p;
	    for (p = skt_buffer_lst;   p->next != b;   p = p->next);
	    p->next = b->next;
	}
    }
    free( b );
}



static void
buf_physically_close_all_marked_sockets(
    void
) {

    /* Over all existing skt buffers: */
    Skt_buffer b;
    Skt_buffer b_next;
/*printf("buf_physically_close_all_marked_sockets/top...\n");*/
    for(b = skt_buffer_lst;   b;   b = b_next) {

	MUQ_NOTE_RANDOM_BITS( *(Vm_Int*)&b );

	/* Note next buffer, since we may */
	/* recycle it before returning to */
	/* top of loop:			  */
	b_next = b->next;

	/* If buffer/socket is scheduled to be closed, */
	/* ... close socket, free() buffer.            */
	if (b->skt_state == SKT_CLOSED) {
/*printf("buf_physically_close_all_marked_sockets calling buf_physically_close_one_socket...\n");*/
	    buf_physically_close_one_socket( b );
	}
    }
/*printf("buf_physically_close_all_marked_sockets/done\n");*/

    skt_need_to_close_some_sockets = FALSE;
}



/************************************************************************/
/*-    buf_physically_close_all_sockets --				*/
/************************************************************************/


/************************************************************************/
/*-    buf_logically_close_all_sockets --				*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static void
buf_logically_close_all_sockets(
    void
) {

    Skt_buffer b;
    for (b = skt_buffer_lst;   b;   b = b->next) {
	b->skt_state = SKT_CLOSED;
    }
    skt_need_to_close_some_sockets = TRUE;
}
#endif



#ifdef CURRENTLY_UNUSED
static void
buf_physically_close_all_sockets(
    void
) {
    buf_logically_close_all_sockets();
    buf_physically_close_all_marked_sockets();
}
#endif



/************************************************************************/
/*-    buf_reset -- Set buffer 'n' to empty.				*/
/************************************************************************/

static void
buf_reset(
    Vm_Unt n
) {
    #if MUQ_IS_PARANOID
    if (n > SKT_MAX_STREAMS
    ||  !skt_buffer_ary[n]
    ){
	MUQ_FATAL ("Internal err.");
    }
    #endif

    {   Skt_buffer b = skt_buffer_ary[ n ];
	b->src_nxt	 =  0;
	b->dst_nxt	 =  0;
    }
}



/*
Weird connect comment:
> In <8874@bacon.IMSI.COM> jordan@IMSI.COM (Jordan Hayes) writes:
>
> >When select() returns for writing, call connect() again.  If it worked,
> >you'll get -1 and errno == EISCONN; if it didn't work, you'll get errno
> >== EINVAL you should call getsockopt(fd, SOL_SOCKET, SO_ERROR, ...) to
> >retrieve the reason it failed.
>
> The man pages I've checked (IRIX 4.0.5H, IRIX 4.0.1, SunOS 4.1.1) say
> nothing about returning EINVAL in errno for a second connect() on a
> socket which previously failed to connect().  In fact, the only thing
> they say about a second connect() is:
>
>      Generally, stream sockets may successfully connect() only once;
>      datagram sockets may use connect() multiple times to  change
>      their  association.
>
> I hope you're right, because that looks like a good method.  But I
> can't find anything about detecting a failed (first) connect().
>
> --
*/
/* Possibly handy someday comment: */
#ifdef never
/* Date: Thu, 28 Dec 1995 00:06:03 -0800 (PST)
 * From: Mark Crispin <MRC@cac.washington.edu>
 * Subject: re: experience with flock vs semget vs lockf
 * To: David Gordon <gordon@tahoma.mbt.washington.edu>
 * Cc: netsys group <netsys@atmos.washington.edu>
 * In-Reply-To: <9512272307.AA06810@tahoma.mbt.washington.edu>
 * Message-Id: <MailManager.820137963.22494.mrc@Ikkoku-Kan.Panda.COM>
 * Mime-Version: 1.0
 * Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
 */

On BSD flavors of Unix, you want to use flock().  There are two problems:
1) no-op on NFS (but locking NFS files is a lost cause anyway)
2) promoting a lock from shared to exclusive *releases* the shared lock before
grabbing the exclusive lock.  [In other words, if process A has a shared lock,
process B is blocked waiting for the lock to go exclusive, and process A
attempts to promote to exclusive, what will happen is that process B will get
the exclusive lock, probably not what you wanted!!]  The same thing happens if
you demote from exclusive to shared.  To work around this, you need another
lock (either as a guard during promotion/demotion).

On SVR4 flavors of Unix, you want to use fcntl().  There are problems here
too:
1) it tries to work on NFS, but uses the fragile lockd/statd mechanism which
does not work well (and eventually *will* deadlock all locks systemwide if you
beat on it enough).  Best not to do it at all.
2) if you get a lock, and then open() the same file again (with a new
descriptor), then the lock gets blown away (***BAD*** bug).

lockf() is just a C library function that calls fcntl(), but is less
functional (it does not provide shared locking).

My suggestion is to use flock() along with the following emulator on SVR4.
Except for the open() problem mentioned above, it is identical to BSD flock()
in behavior, including being a no-op on NFS.  Do not use the one that is
supplied on AIX, it does not make the check to no-op NFS files.

#include <sys/types.h>
#include <errno.h>
#include <unistd.h>		/* if you are a POSIX app */
#include <fcntl.h>
#include <stat.h>
#include <ustat.h>

#define LOCK_SH 1		/* shared lock */
#define LOCK_EX 2		/* exclusive lock */
#define LOCK_NB 4		/* don't block when locking */
#define LOCK_UN 8		/* unlock */


/* Emulator for BSD flock() call
 * Accepts: file descriptor
 *	    operation bitmask
 * Returns: 0 if successful, -1 if failure
 */

int flock (int fd,int operation)
{
  struct stat sbuf;
  struct ustat usbuf;
  struct flock fl;
				/* lock applies to entire file */
  fl.l_whence = fl.l_start = fl.l_len = 0;
  fl.l_pid = getpid ();		/* shouldn't be necessary */
  switch (operation & ~LOCK_NB){/* translate to fcntl() operation */
  case LOCK_EX:			/* exclusive */
    fl.l_type = F_WRLCK;
    break;
  case LOCK_SH:			/* shared */
    fl.l_type = F_RDLCK;
    break;
  case LOCK_UN:			/* unlock */
    fl.l_type = F_UNLCK;
    break;
  default:			/* default */
    errno = EINVAL;
    return -1;
  }
				/* ftinode should be -1 if NFS */
  return ((!fstat (fd,&sbuf) && !ustat (sbuf.st_dev,&usbuf) &&
	   !++usbuf.f_tinode) ? NIL :
	    fcntl (fd,(operation & LOCK_NB) ? F_SETLK : F_SETLKW,&fl);
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



