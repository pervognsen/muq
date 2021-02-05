@example  @c
/*--   muq.c -- server interface objects for Muq.			*/
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
/* Created:      94Mar04						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1995, by Jeff Prothero.				*/
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

#ifndef MUQ_MILLISECS_BETWEEN_BACKUPS
#define MUQ_MILLISECS_BETWEEN_BACKUPS (60*60*1000)
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
static Vm_Unt   sizeof_muq( Vm_Unt );

static Vm_Obj   muq_version(                 Vm_Obj		);
static Vm_Obj   muq_next_pid(                Vm_Obj		);
#ifdef CURRENTLY_UNUSED
static Vm_Obj   muq_vm_octave_file_path(     Vm_Obj		);
#endif
static Vm_Obj	muq_allow_user_logging(      Vm_Obj		);
static Vm_Obj	muq_backups_done(            Vm_Obj		);
static Vm_Obj	muq_banned(		     Vm_Obj		);
static Vm_Obj	muq_blocks_recovered_in_last_garbage_collect( Vm_Obj	);
static Vm_Obj	muq_bytes_recovered_in_last_garbage_collect( Vm_Obj	);
static Vm_Obj	muq_millisecs_between_backups(    Vm_Obj	);
static Vm_Obj	muq_date_of_next_backup(          Vm_Obj	);
static Vm_Obj	muq_date_of_last_backup(          Vm_Obj	);
static Vm_Obj	muq_date_of_last_garbage_collect( Vm_Obj	);
static Vm_Obj	muq_debug(			  Vm_Obj	);
static Vm_Obj	muq_glut_io(			  Vm_Obj	);
static Vm_Obj	muq_glut_job(			  Vm_Obj	);
static Vm_Obj	muq_glut_menu_status_func(	  Vm_Obj	);
static Vm_Obj	muq_glut_idle_func(	 	  Vm_Obj	);
static Vm_Obj	muq_glut_timer_func(	 	  Vm_Obj	);
static Vm_Obj	muq_glut_menus(		 	  Vm_Obj	);
static Vm_Obj	muq_glut_windows(	 	  Vm_Obj	);
static Vm_Obj	muq_millisecs_for_last_backup(         Vm_Obj	);
static Vm_Obj	muq_millisecs_for_last_garbage_collect(Vm_Obj	);
static Vm_Obj	muq_garbage_collects(        Vm_Obj		);
static Vm_Obj	muq_logarithmic_backups(	Vm_Obj	);
static Vm_Obj	muq_max_bytecodes_per_timeslice(	Vm_Obj	);
static Vm_Obj	muq_max_microseconds_to_sleep_in_idle_select(	Vm_Obj	);
static Vm_Obj	muq_max_microseconds_to_sleep_in_busy_select(	Vm_Obj	);
static Vm_Obj	muq_microseconds_to_sleep_per_timeslice(	Vm_Obj	);
static Vm_Obj	muq_muqnet_job(			  Vm_Obj	);
static Vm_Obj	muq_muqnet_socket(		  Vm_Obj	);
static Vm_Obj	muq_muqnet_io(			  Vm_Obj	);
static Vm_Obj	muq_next_guest_rank(		  Vm_Obj	);
static Vm_Obj	muq_next_user_rank(		  Vm_Obj	);
static Vm_Obj	muq_server_name(		  Vm_Obj	);
static Vm_Obj	muq_default_user_server_1(	  Vm_Obj	);
static Vm_Obj	muq_default_user_server_2(	  Vm_Obj	);
static Vm_Obj	muq_default_user_server_3(	  Vm_Obj	);
static Vm_Obj	muq_default_user_server_4(	  Vm_Obj	);

static Vm_Obj	muq_set_banned(                Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_glut_io(               Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_glut_job(              Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_glut_menu_status_func( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_glut_idle_func(        Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_glut_timer_func(       Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_next_guest_rank( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_next_user_rank( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_next_pid( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_max_bytecodes_per_timeslice( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_max_microseconds_to_sleep_in_idle_select( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_max_microseconds_to_sleep_in_busy_select( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_microseconds_to_sleep_per_timeslice( Vm_Obj, Vm_Obj );

static Vm_Obj   muq_running_as_daemon(       Vm_Obj          );
static Vm_Obj   muq_select_calls_made(       Vm_Obj          );
static Vm_Obj   muq_select_calls_interrupted(Vm_Obj          );
static Vm_Obj   muq_select_calls_with_no_io( Vm_Obj          );
static Vm_Obj   muq_blocking_select_calls_made(       Vm_Obj          );
static Vm_Obj   muq_nonblocking_select_calls_made(       Vm_Obj          );
static Vm_Obj   muq_reserved(                Vm_Obj          );
static Vm_Obj   muq_srvdir(                  Vm_Obj          );
static Vm_Obj   muq_logBytecodes(            Vm_Obj          );
static Vm_Obj   muq_logDaemonStuff(          Vm_Obj          );
static Vm_Obj   muq_logWarnings(             Vm_Obj          );
static Vm_Obj   muq_vm_object_loads(         Vm_Obj          );
static Vm_Obj   muq_vm_object_saves(         Vm_Obj          );
static Vm_Obj   muq_vm_object_makes(         Vm_Obj          );
static Vm_Obj	muq_vm_bigbuf_size(          Vm_Obj          );
static Vm_Obj	muq_bytes_between_gcs(       Vm_Obj          );
static Vm_Obj	muq_bytes_since_last_gc(     Vm_Obj          );
static Vm_Obj	muq_stackframes_popped_after_loop_stack_overflow(Vm_Obj);
static Vm_Obj	muq_stackslots_popped_after_data_stack_overflow(Vm_Obj);
static Vm_Obj	muq_vm_bytes_in_useful_data(	  Vm_Obj          );
static Vm_Obj	muq_vm_bytes_lost_in_used_blocks( Vm_Obj          );
static Vm_Obj	muq_vm_bytes_in_free_blocks(      Vm_Obj          );
static Vm_Obj	muq_vm_free_blocks(               Vm_Obj          );
static Vm_Obj	muq_vm_used_blocks(               Vm_Obj          );
static Vm_Obj	muq_consecutive_backups_to_keep(  Vm_Obj          );

static Vm_Obj   muq_creation_date(                Vm_Obj          );
static Vm_Obj   muq_session_start_date(           Vm_Obj          );
static Vm_Obj   muq_server_restarts(              Vm_Obj          );
static Vm_Obj   muq_runtime_in_previous_sessions( Vm_Obj          );


static Vm_Obj	muq_set_allow_user_logging(       Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_default_user_server_1(    Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_default_user_server_2(    Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_default_user_server_3(    Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_default_user_server_4(    Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_debug(			  Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_muqnet_job(               Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_muqnet_io(                Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_muqnet_socket(            Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_server_name(              Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_never(                    Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_date_of_next_backup(      Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_millisecs_between_backups(Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_garbage_collects(         Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_logarithmic_backups(	  Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_blocking_select_calls_made(        Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_nonblocking_select_calls_made(        Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_reserved(                 Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_select_calls_made(        Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_select_calls_with_no_io(  Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_select_calls_interrupted( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_stackframes_popped_after_loop_stack_overflow( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_stackslots_popped_after_data_stack_overflow( Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_logBytecodes(             Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_logDaemonStuff(           Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_logWarnings(              Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_vm_bigbuf_size(           Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_bytes_between_gcs(        Vm_Obj, Vm_Obj );
static Vm_Obj	muq_set_consecutive_backups_to_keep(Vm_Obj,Vm_Obj);

static Vm_Obj   muq_set_creation_date(                Vm_Obj,Vm_Obj   );
static Vm_Obj   muq_set_session_start_date(           Vm_Obj,Vm_Obj   );
static Vm_Obj   muq_set_server_restarts(              Vm_Obj,Vm_Obj   );
static Vm_Obj   muq_set_runtime_in_previous_sessions( Vm_Obj,Vm_Obj   );

static Vm_Obj muqnet_socket = OBJ_FROM_INT(0);
static Vm_Obj muqnet_io     = OBJ_FROM_INT(0);
static Vm_Obj muqnet_job    = OBJ_FROM_INT(0);
static Vm_Obj glut_job      = OBJ_FROM_INT(0);



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

Vm_Obj muq_Glut_Io = FALSE;

Vm_Int muq_Is_In_Daemon_Mode = FALSE;

Vm_Int muq_Debug = FALSE;	/* Hack for nonce server debug support. */

/* Random state, where it can be accessed quickly and efficiently: */
struct Muq_Random_State_Rec muq_RandomState;

/* Description of standard-header system properties: */
static Obj_A_Special_Property muq_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

/* Special system properties on this class: */
{0,"allowUserLogging", muq_allow_user_logging, muq_set_allow_user_logging },
{0,"backupsDone", muq_backups_done, muq_set_never },
{0,"banned",muq_banned,muq_set_banned},
{0,"blocksRecoveredInLastGarbageCollect", muq_blocks_recovered_in_last_garbage_collect, muq_set_never },
{0,"bytesRecoveredInLastGarbageCollect", muq_bytes_recovered_in_last_garbage_collect, muq_set_never },
{0,"bytesBetweenGarbageCollects",	muq_bytes_between_gcs,	muq_set_bytes_between_gcs },
{0,"bytesInFreeBlocks",muq_vm_bytes_in_free_blocks,	muq_set_never },
{0,"bytesInUsefulData", muq_vm_bytes_in_useful_data,muq_set_never },
{0,"bytesLostInUsedBlocks",muq_vm_bytes_lost_in_used_blocks,muq_set_never},
{0,"bytesSinceLastGarbageCollect",muq_bytes_since_last_gc,muq_set_never},
{0,"consecutiveBackupsToKeep",muq_consecutive_backups_to_keep,muq_set_consecutive_backups_to_keep},
{0,"creationDate",muq_creation_date,muq_set_creation_date},
{0,"dbBufSize", muq_vm_bigbuf_size    , muq_set_vm_bigbuf_size  },
{0,"dbLoads"	, muq_vm_object_loads   , muq_set_never },
{0,"dbMakes"	, muq_vm_object_makes   , muq_set_never },
{0,"dbSaves"	, muq_vm_object_saves   , muq_set_never },
{0,"dateOfLastBackup", muq_date_of_last_backup, muq_set_never },
{0,"dateOfLastGarbageCollect", muq_date_of_last_garbage_collect, muq_set_never },
{0,"dateOfNextBackup", muq_date_of_next_backup, muq_set_date_of_next_backup },
{0,"debug", muq_debug, muq_set_debug },
{0,"defaultUserServer1", muq_default_user_server_1, muq_set_default_user_server_1 },
{0,"defaultUserServer2", muq_default_user_server_2, muq_set_default_user_server_2 },
{0,"defaultUserServer3", muq_default_user_server_3, muq_set_default_user_server_3 },
{0,"defaultUserServer4", muq_default_user_server_4, muq_set_default_user_server_4 },
{0,"freeBlocks",	muq_vm_free_blocks,		muq_set_never },
{0,"glutIo",muq_glut_io,muq_set_glut_io},
{0,"glutJob",muq_glut_job,muq_set_glut_job},
{0,"glutMenuStatusFunc",muq_glut_menu_status_func,muq_set_glut_menu_status_func},
{0,"glutIdleFunc",muq_glut_idle_func,muq_set_glut_idle_func},
{0,"glutTimerFunc",muq_glut_timer_func,muq_set_glut_timer_func},
{0,"glutMenus",muq_glut_menus,muq_set_never},
{0,"glutWindows",muq_glut_windows,muq_set_never},
{0,"garbageCollects",muq_garbage_collects,muq_set_garbage_collects },
{0,"logarithmicBackups",muq_logarithmic_backups,muq_set_logarithmic_backups },
{0,"logBytecodes",	   muq_logBytecodes,	muq_set_logBytecodes },
{0,"logDaemonStuff",	   muq_logDaemonStuff,	muq_set_logDaemonStuff },
{0,"logWarnings",	   muq_logWarnings,	muq_set_logWarnings },
{0,"maxBytecodesPerTimeslice",muq_max_bytecodes_per_timeslice,muq_set_max_bytecodes_per_timeslice},
{0,"maxMicrosecondsToSleepInIdleSelect",muq_max_microseconds_to_sleep_in_idle_select,muq_set_max_microseconds_to_sleep_in_idle_select},
{0,"maxMicrosecondsToSleepInBusySelect",muq_max_microseconds_to_sleep_in_busy_select,muq_set_max_microseconds_to_sleep_in_busy_select},
{0,"microsecondsToSleepPerTimeslice",muq_microseconds_to_sleep_per_timeslice,muq_set_microseconds_to_sleep_per_timeslice},
{0,"muqnetJob",muq_muqnet_job,muq_set_muqnet_job},
{0,"muqnetIo",muq_muqnet_io,muq_set_muqnet_io},
{0,"muqnetSocket",muq_muqnet_socket,muq_set_muqnet_socket},
{0,"nextPid",muq_next_pid,muq_set_next_pid},
{0,"nextGuestRank",muq_next_guest_rank,muq_set_next_guest_rank},
{0,"nextUserRank",muq_next_user_rank,muq_set_next_user_rank},
{0,"millisecsBetweenBackups", muq_millisecs_between_backups, muq_set_millisecs_between_backups },
{0,"millisecsForLastBackup", muq_millisecs_for_last_backup, muq_set_never },
{0,"millisecsForLastGarbageCollect", muq_millisecs_for_last_garbage_collect, muq_set_never },
{0,"stackframesPoppedAfterLoopStackOverflow",muq_stackframes_popped_after_loop_stack_overflow,muq_set_stackframes_popped_after_loop_stack_overflow },
{0,"blockingSelectCallsMade",muq_blocking_select_calls_made,muq_set_blocking_select_calls_made },
{0,"nonblockingSelectCallsMade",muq_nonblocking_select_calls_made,muq_set_nonblocking_select_calls_made },
{0,"reserved",	   muq_reserved,	muq_set_reserved },
{0,"runningAsDaemon",	   muq_running_as_daemon,	muq_set_never },
{0,"runtimeInPreviousSessions",muq_runtime_in_previous_sessions,muq_set_runtime_in_previous_sessions },
{0,"selectCallsMade",muq_select_calls_made,muq_set_select_calls_made },
{0,"selectCallsInterrupted",muq_select_calls_interrupted,muq_set_select_calls_interrupted },
{0,"selectCallsWithNoIo",muq_select_calls_with_no_io,muq_set_select_calls_with_no_io },
{0,"serverName",muq_server_name,muq_set_server_name },
{0,"serverRestarts",muq_server_restarts,muq_set_server_restarts },
{0,"sessionStartDate",muq_session_start_date,muq_set_session_start_date },
{0,"stackslotsPoppedAfterDataStackOverflow",muq_stackslots_popped_after_data_stack_overflow,muq_set_stackslots_popped_after_data_stack_overflow },
{0,"srvdir",	   muq_srvdir,		muq_set_never },
{0,"usedBlocks",  muq_vm_used_blocks,		muq_set_never },
{0,"version"     , muq_version,muq_set_never},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class muq_Hardcoded_Class = {
    OBJ_FROM_BYT3('m','u','q'),
    "MuqInterface",
    sizeof_muq,
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
    { muq_system_properties, muq_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void muq_doTypes(void){}
Obj_A_Module_Summary muq_Module_Summary = {
   "muq",
    muq_doTypes,
    muq_Startup,
    muq_Linkup,
    muq_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/




/************************************************************************/
/*-    muq_Sprint  -- Debug dump of muq state, multi-line format.	*/
/************************************************************************/

Vm_Uch* muq_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  muq
) {
#ifdef SOMETIME
    Muq_P  s   = MUQ_P(muq);
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
/*-    muq_Startup -- start-of-world stuff.				*/
/************************************************************************/


 /***********************************************************************/
 /*-    maybe_reinsert_slash_muq -- Validate /muq.			*/
 /***********************************************************************/

static Vm_Obj
maybe_reinsert_slash_muq(
    void
) {
    Vm_Obj muq = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("muq"), OBJ_PROP_PUBLIC );
    if (muq==OBJ_NOT_FOUND || !OBJ_IS_CLASS_MUQ(muq)) {
	muq  = obj_Alloc( OBJ_CLASS_A_MUQ, 0 );
        OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("muq"), muq, OBJ_PROP_PUBLIC );
        OBJ_P(muq)->objname = stg_From_Asciz("/muq");  vm_Dirty(muq);
    }
    return muq;
}

 /***********************************************************************/
 /*-    muq_Startup -- start-of-world stuff.				*/
 /***********************************************************************/

void
muq_Startup(
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Muq = maybe_reinsert_slash_muq();

    {   Vm_Obj now = OBJ_FROM_UNT( job_Now() );
        Muq_P  m   = MUQ_P(obj_Muq);
	obj_Millisecs_Between_Backups = OBJ_TO_UNT( m->millisecs_between_backups );
	obj_Date_Of_Next_Backup       = OBJ_TO_UNT( m->date_of_next_backup       );
	obj_Bytes_Between_Garbage_Collections = (
	    OBJ_TO_UNT(m->bytes_between_garbage_collects)
        );

        muq_Glut_Io                   = m->glut_io;
        muq_RandomState               = m->randomState;
	muq_RandomState.i	      = OBJ_TO_INT( muq_RandomState.i );

        m->session_start_date	 	= now;
        m->server_restarts		= OBJ_FROM_INT( OBJ_TO_UNT(m->server_restarts) + (Vm_Unt)1 );
    }

    /* Make sure glut_windows vector length in db matches */
    /* the compiled-in value for the server, then clear   */
    /* it to all NIL:                                     */
    {   Vm_Obj glut_windows = MUQ_P(obj_Muq)->glut_windows;
	if (!OBJ_IS_VEC(glut_windows)
        || vec_Len(glut_windows) != (WDW_MAX_ACTIVE_WINDOWS+1)
	){
	    glut_windows = vec_Alloc( (WDW_MAX_ACTIVE_WINDOWS+1), OBJ_NIL );
	    MUQ_P(obj_Muq)->glut_windows = glut_windows; vm_Dirty(obj_Muq);
	}
        {   Vec_P v = VEC_P(glut_windows);
            Vm_Int i;
	    for (i = 0;   i <= WDW_MAX_ACTIVE_WINDOWS;   ++i) {
		v->slot[i] = OBJ_NIL;
	    }
	} 
    }
    /* Make sure glut_menus vector length in db matches   */
    /* the compiled-in value for the server, then clear   */
    /* it to all NIL:                                     */
    {   Vm_Obj glut_menus = MUQ_P(obj_Muq)->glut_menus;
	if (!OBJ_IS_VEC(glut_menus)
        || vec_Len(glut_menus) != (WDW_MAX_ACTIVE_WINDOWS+1)
	){
	    glut_menus = vec_Alloc( (WDW_MAX_ACTIVE_WINDOWS+1), OBJ_NIL );
	    MUQ_P(obj_Muq)->glut_menus = glut_menus; vm_Dirty(obj_Muq);
	}
        {   Vec_P v = VEC_P(glut_menus);
            Vm_Int i;
	    for (i = 0;   i <= WDW_MAX_ACTIVE_WINDOWS;   ++i) {
		v->slot[i] = OBJ_NIL;
	    }
	} 
    }
}



/************************************************************************/
/*-    muq_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
muq_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;


}



/************************************************************************/
/*-    muq_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void muq_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    {   Vm_Unt now = job_Now();
        Muq_P m = MUQ_P(obj_Muq);
        m->randomState          = muq_RandomState;
	m->randomState.i	= OBJ_FROM_INT( muq_RandomState.i );

        m->runtime_in_previous_sessions	= OBJ_FROM_UNT(
	    OBJ_TO_UNT( m->runtime_in_previous_sessions )
	    + (now - OBJ_TO_UNT( m->session_start_date ))
	);
    }
}


#ifdef SOON

/************************************************************************/
/*-    muq_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj muq_Import(
    FILE* fd
) {
    MUQ_FATAL ("muq_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    muq_Export -- Write object into textfile.			*/
/************************************************************************/

void muq_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("muq_Export unimplemented");
}


#endif

/************************************************************************/
/*-    muq_Invariants -- Sanity check on muq.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int muq_Invariants (
    FILE*   errlog,
    Vm_Uch* title,
    Vm_Obj  muq
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, muq );
#endif
    return errs;
}


/************************************************************************/
/*-    muq_Mark -- Mark all local garbage collection roots.		*/
/************************************************************************/

void
muq_Mark(
    void
) {
    obj_Mark( glut_job      );
    obj_Mark( muqnet_io     );
    obj_Mark( muqnet_job    );
    obj_Mark( muqnet_socket );
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/




/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/



/************************************************************************/
/*-    for_new -- Initialize new muq object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Vm_Obj glut_windows = vec_Alloc( (WDW_MAX_ACTIVE_WINDOWS+1), OBJ_NIL );
    Vm_Obj glut_menus   = vec_Alloc( (WDW_MAX_ACTIVE_WINDOWS+1), OBJ_NIL );
    Vm_Obj now          = OBJ_FROM_UNT( job_Now() );
    
    Muq_P  m = MUQ_P(o);

    m->banned 		     = OBJ_NIL;
    m->log_daemon_stuff	     = OBJ_NIL;
    m->next_pid 	     = OBJ_FROM_INT(0);
    m->next_user_rank	     = OBJ_FROM_INT(1000);
    m->next_guest_rank	     = OBJ_FROM_INT(1000000);
    m->millisecs_between_backups = OBJ_FROM_INT( MUQ_MILLISECS_BETWEEN_BACKUPS );
    m->date_of_next_backup       = OBJ_FROM_INT( MUQ_MILLISECS_BETWEEN_BACKUPS + job_Now() );
    m->date_of_last_backup       = OBJ_FROM_INT(0);
    m->millisecs_for_last_backup = OBJ_FROM_INT(0);

    m->creation_date			= now;
    m->session_start_date	 	= now;
    m->server_restarts		 	= OBJ_FROM_INT(0);
    m->runtime_in_previous_sessions	= OBJ_FROM_INT(0);

    m->bytes_between_garbage_collects = (
	OBJ_FROM_UNT( OBJ_BYTES_BETWEEN_GARBAGE_COLLECTIONS )
    );

    m->default_user_server_1     = OBJ_NIL;
    m->default_user_server_2     = OBJ_NIL;
    m->default_user_server_3     = OBJ_NIL;
    m->default_user_server_4     = OBJ_NIL;

    m->server_name       	 = OBJ_NIL;

    m->glut_io       	         = OBJ_NIL;

    m->glut_menu_status_func     = OBJ_NIL;
    m->glut_idle_func	         = OBJ_NIL;
    m->glut_timer_func	         = OBJ_NIL;

    m->glut_windows	         = glut_windows;
    m->glut_menus	         = glut_menus;

    m->allow_user_logging  	 = OBJ_T;

    {   Vm_Int i;
	for (i = MUQ_RESERVED_SLOTS;      i --> 0;   )     m->reserved_slot[i] = OBJ_FROM_INT(0);
    }

    {   Vm_Int i;
	for (i = MUQ_RANDOM_STATE_SLOTS;  i --> 0;   )     m->randomState.slot[i] = OBJ_FROM_INT(0);
	m->randomState.i = OBJ_FROM_INT(0);
    }

    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_muq -- Return size of package.				*/
/************************************************************************/

static Vm_Unt
sizeof_muq(
    Vm_Unt size
) {
    return sizeof( Muq_A_Header );
}






/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int invariants(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj  muq
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif




/************************************************************************/
/*-    --- Static propfns --						*/
/************************************************************************/




/************************************************************************/
/*-    muq_reserved	        					*/
/************************************************************************/

static Vm_Obj
muq_reserved(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( !!job_Reserved );
}



/************************************************************************/
/*-    muq_srvdir	        					*/
/************************************************************************/

static Vm_Obj
muq_srvdir(
    Vm_Obj o
) {
    if (!obj_Srv_Dir)   return OBJ_NIL;
    return stg_From_Asciz( obj_Srv_Dir );
}

/************************************************************************/
/*-    muq_banned	        					*/
/************************************************************************/

static Vm_Obj
muq_banned(
    Vm_Obj o
) {
    return MUQ_P(o)->banned;
}

/************************************************************************/
/*-    muq_logBytecodes        						*/
/************************************************************************/

static Vm_Obj
muq_logBytecodes(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( !!job_Log_Bytecodes );
}

/************************************************************************/
/*-    muq_logDaemonStuff      						*/
/************************************************************************/

static Vm_Obj
muq_logDaemonStuff(
    Vm_Obj o
) {
    return MUQ_P(o)->log_daemon_stuff;
}

/************************************************************************/
/*-    muq_logWarnings        						*/
/************************************************************************/

static Vm_Obj
muq_logWarnings(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( !!job_Log_Warnings );
}



/************************************************************************/
/*-    muq_version	        					*/
/************************************************************************/

static Vm_Obj
muq_version(
    Vm_Obj o
) {
    return stg_From_Asciz( VERSION );
}



/************************************************************************/
/*-    muq_default_user_server_1       					*/
/************************************************************************/

static Vm_Obj
muq_default_user_server_1(
    Vm_Obj o
) {
    return MUQ_P(obj_Muq)->default_user_server_1;
}


/************************************************************************/
/*-    muq_default_user_server_2       					*/
/************************************************************************/

static Vm_Obj
muq_default_user_server_2(
    Vm_Obj o
) {
    return MUQ_P(obj_Muq)->default_user_server_2;
}


/************************************************************************/
/*-    muq_default_user_server_3       					*/
/************************************************************************/

static Vm_Obj
muq_default_user_server_3(
    Vm_Obj o
) {
    return MUQ_P(obj_Muq)->default_user_server_3;
}


/************************************************************************/
/*-    muq_default_user_server_4       					*/
/************************************************************************/

static Vm_Obj
muq_default_user_server_4(
    Vm_Obj o
) {
    return MUQ_P(obj_Muq)->default_user_server_4;
}



/************************************************************************/
/*-    muq_glut_io        						*/
/************************************************************************/

static Vm_Obj
muq_glut_io(
    Vm_Obj o
) {
    return muq_Glut_Io ? muq_Glut_Io : OBJ_NIL;
}



/************************************************************************/
/*-    muq_next_guest_rank        					*/
/************************************************************************/

static Vm_Obj
muq_next_guest_rank(
    Vm_Obj o
) {
    return MUQ_P(o)->next_guest_rank;
}

/************************************************************************/
/*-    muq_next_user_rank        					*/
/************************************************************************/

static Vm_Obj
muq_next_user_rank(
    Vm_Obj o
) {
    return MUQ_P(o)->next_user_rank;
}

/************************************************************************/
/*-    muq_next_pid	        					*/
/************************************************************************/

static Vm_Obj
muq_next_pid(
    Vm_Obj o
) {
    return MUQ_P(o)->next_pid;
}



/************************************************************************/
/*-    muq_glut_job	        					*/
/************************************************************************/

static Vm_Obj
muq_glut_job(
    Vm_Obj o
) {
    return glut_job;
}

/************************************************************************/
/*-    muq_muqnet_job	        					*/
/************************************************************************/

static Vm_Obj
muq_muqnet_job(
    Vm_Obj o
) {
    return muqnet_job;
}

/************************************************************************/
/*-    muq_glut_menu_status_func       					*/
/************************************************************************/

static Vm_Obj
muq_glut_menu_status_func(
    Vm_Obj o
) {
    return MUQ_P(o)->glut_menu_status_func;
}

/************************************************************************/
/*-    muq_glut_idle_func       					*/
/************************************************************************/

static Vm_Obj
muq_glut_idle_func(
    Vm_Obj o
) {
    return MUQ_P(o)->glut_idle_func;
}

/************************************************************************/
/*-    muq_glut_timer_func       					*/
/************************************************************************/

static Vm_Obj
muq_glut_timer_func(
    Vm_Obj o
) {
    return MUQ_P(o)->glut_timer_func;
}

/************************************************************************/
/*-    muq_glut_menus		       					*/
/************************************************************************/

static Vm_Obj
muq_glut_menus(
    Vm_Obj o
) {
    return MUQ_P(o)->glut_menus;
}

/************************************************************************/
/*-    muq_glut_windows		       					*/
/************************************************************************/

static Vm_Obj
muq_glut_windows(
    Vm_Obj o
) {
    return MUQ_P(o)->glut_windows;
}





/************************************************************************/
/*-    muq_muqnet_socket        					*/
/************************************************************************/

static Vm_Obj
muq_muqnet_socket(
    Vm_Obj o
) {
    return muqnet_socket;
}

/************************************************************************/
/*-    muq_muqnet_io        						*/
/************************************************************************/

static Vm_Obj
muq_muqnet_io(
    Vm_Obj o
) {
    return muqnet_io;
}



/************************************************************************/
/*-    muq_vm_object_makes        					*/
/************************************************************************/

static Vm_Obj muq_vm_object_makes(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Object_Creates(0) );
}



/************************************************************************/
/*-    muq_vm_object_saves        					*/
/************************************************************************/

static Vm_Obj muq_vm_object_saves(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Object_Sends(0) );
}



/************************************************************************/
/*-    muq_vm_object_loads        					*/
/************************************************************************/

static Vm_Obj muq_vm_object_loads(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Object_Reads(0) );
}



/************************************************************************/
/*-    muq_vm_octave_file_path        					*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static Vm_Obj muq_vm_octave_file_path(
    Vm_Obj o
) {
    return stg_From_Asciz( vm_Octave_File_Path );
}
#endif



/************************************************************************/
/*-    muq_vm_bigbuf_size              					*/
/************************************************************************/

static Vm_Obj muq_vm_bigbuf_size(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Resize_Bigbuf(0) );
}



/************************************************************************/
/*-    muq_allow_user_logging      					*/
/************************************************************************/

static Vm_Obj
muq_allow_user_logging(
    Vm_Obj o
) {
    return MUQ_P(o)->allow_user_logging;
}

/************************************************************************/
/*-    muq_creation_date	      					*/
/************************************************************************/

static Vm_Obj
muq_creation_date(
    Vm_Obj o
) {
    return MUQ_P(o)->creation_date;
}

/************************************************************************/
/*-    muq_session_start_date	      					*/
/************************************************************************/

static Vm_Obj
muq_session_start_date(
    Vm_Obj o
) {
    return MUQ_P(o)->session_start_date;
}

/************************************************************************/
/*-    muq_server_restarts	      					*/
/************************************************************************/

static Vm_Obj
muq_server_restarts(
    Vm_Obj o
) {
    return MUQ_P(o)->server_restarts;
}

/************************************************************************/
/*-    muq_runtime_in_previus_sessions 					*/
/************************************************************************/

static Vm_Obj
muq_runtime_in_previous_sessions(
    Vm_Obj o
) {
    return MUQ_P(o)->runtime_in_previous_sessions;
}




/************************************************************************/
/*-    muq_backups_done	          					*/
/************************************************************************/

static Vm_Obj
muq_backups_done(
    Vm_Obj o
) {
    return OBJ_FROM_INT( vm_Backups_Done(0) );
}



/************************************************************************/
/*-    muq_bytes_between_gcs          					*/
/************************************************************************/

static Vm_Obj
muq_bytes_between_gcs(
    Vm_Obj o
) {
    return OBJ_FROM_INT( obj_Bytes_Between_Garbage_Collections );
}



/************************************************************************/
/*-    muq_bytes_since_last_gc          				*/
/************************************************************************/

static Vm_Obj
muq_bytes_since_last_gc(
    Vm_Obj o
) {
    return OBJ_FROM_INT( vm_Bytes_Allocated_Since_Last_Garbage_Collection(0) );
}

/************************************************************************/
/*-    muq_garbage_collects	          				*/
/************************************************************************/

static Vm_Obj
muq_garbage_collects(
    Vm_Obj o
) {
    return OBJ_FROM_INT( obj_Garbage_Collects );
}

/************************************************************************/
/*-    muq_date_of_last_backup	        				*/
/************************************************************************/

static Vm_Obj
muq_date_of_last_backup(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( obj_Date_Of_Last_Backup );
}

/************************************************************************/
/*-    muq_date_of_last_garbage_collect        				*/
/************************************************************************/

static Vm_Obj
muq_date_of_last_garbage_collect(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( obj_Date_Of_Last_Garbage_Collect );
}

/************************************************************************/
/*-    muq_date_of_next_backup	        				*/
/************************************************************************/

static Vm_Obj
muq_date_of_next_backup(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( obj_Date_Of_Next_Backup );
}

/************************************************************************/
/*-    muq_debug		        				*/
/************************************************************************/

static Vm_Obj
muq_debug(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( muq_Debug );
}

/************************************************************************/
/*-    muq_millisecs_between_backups	        			*/
/************************************************************************/

static Vm_Obj
muq_millisecs_between_backups(
    Vm_Obj o
) {
    return OBJ_FROM_INT( obj_Millisecs_Between_Backups );
}

/************************************************************************/
/*-    muq_millisecs_for_last_backup		       			*/
/************************************************************************/

static Vm_Obj
muq_millisecs_for_last_backup(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( obj_Millisecs_For_Last_Backup );
}

/************************************************************************/
/*-    muq_millisecs_for_last_garbage_collect       			*/
/************************************************************************/

static Vm_Obj
muq_millisecs_for_last_garbage_collect(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( obj_Millisecs_For_Last_Garbage_Collect );
}

/************************************************************************/
/*-    muq_blocks_recovered_in_last_garbage_collect			*/
/************************************************************************/

static Vm_Obj
muq_blocks_recovered_in_last_garbage_collect(
    Vm_Obj o
) {
    return OBJ_FROM_INT( obj_Objs_Recovered );
}

/************************************************************************/
/*-    muq_bytes_recovered_in_last_garbage_collect			*/
/************************************************************************/

static Vm_Obj
muq_bytes_recovered_in_last_garbage_collect(
    Vm_Obj o
) {
    return OBJ_FROM_INT( obj_Byts_Recovered );
}

/************************************************************************/
/*-    muq_running_as_daemon						*/
/************************************************************************/

static Vm_Obj
muq_running_as_daemon(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( !!muq_Is_In_Daemon_Mode );
}

/************************************************************************/
/*-    muq_select_calls_interrupted          				*/
/************************************************************************/

static Vm_Obj
muq_select_calls_interrupted(
    Vm_Obj o
) {
    return OBJ_FROM_INT( skt_Select_Calls_Interrupted );
}

/************************************************************************/
/*-    muq_select_calls_with_no_io          				*/
/************************************************************************/

static Vm_Obj
muq_select_calls_with_no_io(
    Vm_Obj o
) {
    return OBJ_FROM_INT( skt_Select_Calls_With_No_Io );
}

/************************************************************************/
/*-    muq_select_calls_made	          				*/
/************************************************************************/

static Vm_Obj
muq_select_calls_made(
    Vm_Obj o
) {
    return OBJ_FROM_INT( skt_Select_Calls_Made );
}

/************************************************************************/
/*-    muq_server_name		          				*/
/************************************************************************/

static Vm_Obj
muq_server_name(
    Vm_Obj o
) {
    return MUQ_P(o)->server_name;
}

/************************************************************************/
/*-    muq_blocking_select_calls_made          				*/
/************************************************************************/

static Vm_Obj
muq_blocking_select_calls_made(
    Vm_Obj o
) {
    return OBJ_FROM_INT( skt_Blocking_Select_Calls_Made );
}

/************************************************************************/
/*-    muq_nonblocking_select_calls_made       				*/
/************************************************************************/

static Vm_Obj
muq_nonblocking_select_calls_made(
    Vm_Obj o
) {
    return OBJ_FROM_INT( skt_Nonblocking_Select_Calls_Made );
}

/************************************************************************/
/*-    muq_stackframes_popped_after_loop_stack_overflow			*/
/************************************************************************/

static Vm_Obj
muq_stackframes_popped_after_loop_stack_overflow(
    Vm_Obj o
) {
    return OBJ_FROM_INT( obj_Stackframes_Popped_After_Loop_Stack_Overflow );
}


/************************************************************************/
/*-    muq_stackslots_popped_after_data_stack_overflow			*/
/************************************************************************/

static Vm_Obj
muq_stackslots_popped_after_data_stack_overflow(
    Vm_Obj o
) {
    return OBJ_FROM_INT( obj_Stackslots_Popped_After_Data_Stack_Overflow );
}


/************************************************************************/
/*-    muq_max_bytecodes_per_timeslice					*/
/************************************************************************/

static Vm_Obj
muq_max_bytecodes_per_timeslice(
    Vm_Obj o
) {
    return OBJ_FROM_INT( job_Max_Bytecodes_Per_Timeslice );
}

/************************************************************************/
/*-    muq_logarithmic_backups						*/
/************************************************************************/

static Vm_Obj
muq_logarithmic_backups(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( vm_Logarithmic_Backups != 0 );
}

/************************************************************************/
/*-    muq_microseconds_to_sleep_per_timeslice				*/
/************************************************************************/

static Vm_Obj
muq_microseconds_to_sleep_per_timeslice(
    Vm_Obj o
) {
    return OBJ_FROM_INT( job_Microseconds_To_Sleep_Per_Timeslice );
}

/************************************************************************/
/*-    muq_max_microseconds_to_sleep_in_busy_select			*/
/************************************************************************/

static Vm_Obj
muq_max_microseconds_to_sleep_in_busy_select(
    Vm_Obj o
) {
    return OBJ_FROM_INT( job_Max_Microseconds_To_Sleep_In_Busy_Select );
}

/************************************************************************/
/*-    muq_max_microseconds_to_sleep_in_idle_select			*/
/************************************************************************/

static Vm_Obj
muq_max_microseconds_to_sleep_in_idle_select(
    Vm_Obj o
) {
    return OBJ_FROM_INT( job_Max_Microseconds_To_Sleep_In_Idle_Select );
}

/************************************************************************/
/*-    muq_vm_bytes_in_useful_data					*/
/************************************************************************/

static Vm_Obj
muq_vm_bytes_in_useful_data(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Bytes_In_Useful_Data(0) );
}



/************************************************************************/
/*-    muq_vm_bytes_lost_in_used_blocks					*/
/************************************************************************/

static Vm_Obj
muq_vm_bytes_lost_in_used_blocks(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Bytes_Lost_In_Used_Blocks(0) );
}



/************************************************************************/
/*-    muq_vm_bytes_in_free_blocks					*/
/************************************************************************/

static Vm_Obj
muq_vm_bytes_in_free_blocks(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Bytes_In_Free_Blocks(0) );
}



/************************************************************************/
/*-    muq_consecutive_backups_to_keep					*/
/************************************************************************/

static Vm_Obj
muq_consecutive_backups_to_keep(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Consecutive_Backups_To_Keep(0) );
}



/************************************************************************/
/*-    muq_vm_free_blocks						*/
/************************************************************************/

static Vm_Obj
muq_vm_free_blocks(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Free_Blocks(0) );
}



/************************************************************************/
/*-    muq_vm_used_blocks						*/
/************************************************************************/

static Vm_Obj
muq_vm_used_blocks(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( vm_Used_Blocks(0) );
}




/************************************************************************/
/*-    muq_set_allow_user_logging					*/
/************************************************************************/

static Vm_Obj
muq_set_allow_user_logging(
    Vm_Obj o,
    Vm_Obj v
) {
    MUQ_P(o)->allow_user_logging = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_banned							*/
/************************************************************************/

static Vm_Obj
muq_set_banned(
    Vm_Obj o,
    Vm_Obj v
) {
    MUQ_P(o)->banned = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_default_user_server_1					*/
/************************************************************************/

static Vm_Obj
muq_set_default_user_server_1(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->default_user_server_1 = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_default_user_server_2					*/
/************************************************************************/

static Vm_Obj
muq_set_default_user_server_2(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->default_user_server_2 = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_default_user_server_3					*/
/************************************************************************/

static Vm_Obj
muq_set_default_user_server_3(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->default_user_server_3 = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_default_user_server_4					*/
/************************************************************************/

static Vm_Obj
muq_set_default_user_server_4(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->default_user_server_4 = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_glut_io							*/
/************************************************************************/

static Vm_Obj
muq_set_glut_io(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL
    || (OBJ_IS_OBJ(v)  &&  OBJ_IS_CLASS_MSS(v))
    ){
	muq_Glut_Io = v;
	MUQ_P(o)->glut_io = v; vm_Dirty(o);
    }

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_glut_menu_status_func					*/
/************************************************************************/

static Vm_Obj
muq_set_glut_menu_status_func(
    Vm_Obj o,
    Vm_Obj v
) {
    MUQ_P(o)->glut_menu_status_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_glut_idle_func						*/
/************************************************************************/

static Vm_Obj
muq_set_glut_idle_func(
    Vm_Obj o,
    Vm_Obj v
) {
    MUQ_P(o)->glut_idle_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_glut_timer_func						*/
/************************************************************************/

static Vm_Obj
muq_set_glut_timer_func(
    Vm_Obj o,
    Vm_Obj v
) {
    MUQ_P(o)->glut_timer_func = v; vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_next_guest_rank						*/
/************************************************************************/

static Vm_Obj
muq_set_next_guest_rank(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->next_guest_rank = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_next_user_rank						*/
/************************************************************************/

static Vm_Obj
muq_set_next_user_rank(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->next_user_rank = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_next_pid							*/
/************************************************************************/

static Vm_Obj
muq_set_next_pid(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->next_pid = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_creation_date						*/
/************************************************************************/

static Vm_Obj
muq_set_creation_date(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->creation_date = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_session_start_date					*/
/************************************************************************/

static Vm_Obj
muq_set_session_start_date(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->session_start_date = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_server_restarts						*/
/************************************************************************/

static Vm_Obj
muq_set_server_restarts(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->server_restarts = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_runtime_in_previous_sessions				*/
/************************************************************************/

static Vm_Obj
muq_set_runtime_in_previous_sessions(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	MUQ_P(o)->runtime_in_previous_sessions = v; vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_glut_job							*/
/************************************************************************/

static Vm_Obj
muq_set_glut_job(
    Vm_Obj o,
    Vm_Obj v
) {
/* BUGGO? Can random users create their own instance of */
/* muq or sys and then fiddle important system values like */
/* these? */
    if (OBJ_IS_OBJ(       v )
    &&  OBJ_IS_CLASS_JOB( v )
    ){
	muqnet_job = v; /* vm_Dirty(o); */
    }

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_muqnet_job						*/
/************************************************************************/

static Vm_Obj
muq_set_muqnet_job(
    Vm_Obj o,
    Vm_Obj v
) {
/* BUGGO? Can random users create their own instance of */
/* muq or sys and then fiddle important system values like */
/* these? */
    if (OBJ_IS_OBJ(       v )
    &&  OBJ_IS_CLASS_JOB( v )
    ){
	muqnet_job = v; /* vm_Dirty(o); */
    }

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_muqnet_io						*/
/************************************************************************/

static Vm_Obj
muq_set_muqnet_io(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(       v )
    &&  OBJ_IS_CLASS_MSS( v )
    ){
	muqnet_io = v; /* vm_Dirty(o); */
    }

    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_muqnet_socket						*/
/************************************************************************/

static Vm_Obj
muq_set_muqnet_socket(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(       v )
    &&  OBJ_IS_CLASS_SKT( v )
    ){
	muqnet_socket = v; /* vm_Dirty(o); */
    }

    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_date_of_next_backup					*/
/************************************************************************/

#ifdef OLD
static Vm_Obj
muq_set_date_of_next_backup(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Unt i;
    if (OBJ_IS_INT(v)
    && (i = OBJ_TO_UNT(v))
    ){
	obj_Date_Of_Next_Backup = i;
	MUQ_P(o)->date_of_next_backup = v;	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}
#endif

/************************************************************************/
/*-    muq_set_logarithmic_backups					*/
/************************************************************************/

static Vm_Obj
muq_set_logarithmic_backups(
    Vm_Obj o,
    Vm_Obj v
) {
    vm_Set_Logarithmic_Backups(0,(v != OBJ_NIL));
    return (Vm_Obj) 0;
}


/************************************************************************/
/*-    muq_set_bytes_between_gcs					*/
/************************************************************************/

static Vm_Obj
muq_set_bytes_between_gcs(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && (i = OBJ_TO_INT(v))
    &&  i > 0
    ){
        MUQ_P(o)->bytes_between_garbage_collects = OBJ_FROM_UNT(i);
	vm_Dirty(o);

	obj_Bytes_Between_Garbage_Collections = i;
    }
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_never	 						*/
/************************************************************************/

static Vm_Obj
muq_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_stackframes_popped_after_loop_stack_overflow		*/
/************************************************************************/

static Vm_Obj
muq_set_stackframes_popped_after_loop_stack_overflow(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	Vm_Int  to_pop = OBJ_TO_INT(v);
	if (to_pop >= OBJ_MIN_STACKFRAMES_POPPED_AFTER_LOOP_STACK_OVERFLOW) {
	    obj_Stackframes_Popped_After_Loop_Stack_Overflow = to_pop;
    }   }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_stackslots_popped_after_data_stack_overflow		*/
/************************************************************************/

static Vm_Obj
muq_set_stackslots_popped_after_data_stack_overflow(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	Vm_Int  to_pop = OBJ_TO_INT(v);
	if (to_pop >= OBJ_MIN_STACKSLOTS_POPPED_AFTER_DATA_STACK_OVERFLOW) {
	    obj_Stackslots_Popped_After_Data_Stack_Overflow = to_pop;
    }   }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_max_bytecodes_per_timeslice				*/
/************************************************************************/

static Vm_Obj
muq_set_max_bytecodes_per_timeslice(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	Vm_Int  codes = OBJ_TO_INT(v);
	if (0 < codes) {
	    job_Max_Bytecodes_Per_Timeslice = codes;
    }   }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_microseconds_to_sleep_per_timeslice			*/
/************************************************************************/

static Vm_Obj
muq_set_microseconds_to_sleep_per_timeslice(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	/* Sleeping more than a 100msec per timeslice */
	/* is silly, and probably a typo or thinko:   */
	Vm_Int   usec = OBJ_TO_INT(v);
	if (0 <= usec && usec <= 100*1000) {
	    job_Microseconds_To_Sleep_Per_Timeslice = usec;
    }   }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_max_microseconds_to_sleep_in_busy_select			*/
/************************************************************************/

static Vm_Obj
muq_set_max_microseconds_to_sleep_in_busy_select(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	Vm_Int   usec = OBJ_TO_INT(v);
	if (0 <= usec) {
	    job_Max_Microseconds_To_Sleep_In_Busy_Select = usec;
    }   }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_max_microseconds_to_sleep_in_idle_select			*/
/************************************************************************/

static Vm_Obj
muq_set_max_microseconds_to_sleep_in_idle_select(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	Vm_Int   usec = OBJ_TO_INT(v);
	if (0 <= usec) {
	    job_Max_Microseconds_To_Sleep_In_Idle_Select = usec;
    }   }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_date_of_next_backup					*/
/************************************************************************/

static Vm_Obj
muq_set_date_of_next_backup(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Unt i;
    if (OBJ_IS_INT(v)
    && (i = OBJ_TO_UNT(v))
    ){
	MUQ_P(o)->date_of_next_backup = v;	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_debug							*/
/************************************************************************/

static Vm_Obj
muq_set_debug(
    Vm_Obj o,
    Vm_Obj v
) {
    muq_Debug = (v != OBJ_NIL);
    return (Vm_Obj) 0;
}


/************************************************************************/
/*-    muq_set_millisecs_between_backups				*/
/************************************************************************/

#ifndef MUQ_SHORTEST_SANE_INTERVAL_BETWEEN_BACKUPS
#define MUQ_SHORTEST_SANE_INTERVAL_BETWEEN_BACKUPS (60000)
#endif

static Vm_Obj
muq_set_millisecs_between_backups(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && (i = OBJ_TO_INT(v))
    &&  i >= 0
    ){
	/* Try to defend wizards against finger-slips, */
	/* since recovering from setting this value to */
	/* 1 may take quite awhile.   You can #define  */
	/* this value as zero in muq/h/Site-config.h   */
	/* if such handholding offends you:	       */
	if (i
	&&  i < MUQ_SHORTEST_SANE_INTERVAL_BETWEEN_BACKUPS
	){
	    i = MUQ_SHORTEST_SANE_INTERVAL_BETWEEN_BACKUPS;
	}

	obj_Millisecs_Between_Backups = i;
	MUQ_P(o)->millisecs_between_backups = OBJ_FROM_INT(i);	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_garbage_collects       					*/
/************************************************************************/

static Vm_Obj
muq_set_garbage_collects(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	obj_Garbage_Collects = OBJ_TO_INT(v);
    }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_reserved							*/
/************************************************************************/

static Vm_Obj
muq_set_reserved(
    Vm_Obj o,
    Vm_Obj v
) {
    job_Reserved = (v != OBJ_NIL);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_select_calls_made       					*/
/************************************************************************/

static Vm_Obj
muq_set_select_calls_made(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	skt_Select_Calls_Made = OBJ_TO_INT(v);
    }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_select_calls_interrupted					*/
/************************************************************************/

static Vm_Obj
muq_set_select_calls_interrupted(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	skt_Select_Calls_Interrupted = OBJ_TO_INT(v);
    }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_select_calls_with_no_io					*/
/************************************************************************/

static Vm_Obj
muq_set_select_calls_with_no_io(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	skt_Select_Calls_With_No_Io = OBJ_TO_INT(v);
    }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_server_name						*/
/************************************************************************/

static Vm_Obj
muq_set_server_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if (stg_Is_Stg(v)) {
	MUQ_P(o)->server_name = v;	vm_Dirty(o);
    }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_nonblocking_select_calls_made				*/
/************************************************************************/

static Vm_Obj
muq_set_nonblocking_select_calls_made(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	skt_Nonblocking_Select_Calls_Made = OBJ_TO_INT(v);
    }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_blocking_select_calls_made				*/
/************************************************************************/

static Vm_Obj
muq_set_blocking_select_calls_made(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	skt_Select_Calls_Made = OBJ_TO_INT(v);
    }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_logBytecodes						*/
/************************************************************************/

static Vm_Obj
muq_set_logBytecodes(
    Vm_Obj o,
    Vm_Obj v
) {
    job_Log_Bytecodes = (v != OBJ_NIL);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_logDaemonStuff						*/
/************************************************************************/

static Vm_Obj
muq_set_logDaemonStuff(
    Vm_Obj o,
    Vm_Obj v
) {
    MUQ_P(o)->log_daemon_stuff = OBJ_FROM_BOOL( v != OBJ_NIL );
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_logWarnings						*/
/************************************************************************/

static Vm_Obj
muq_set_logWarnings(
    Vm_Obj o,
    Vm_Obj v
) {
    job_Log_Warnings = (v != OBJ_NIL);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    muq_set_vm_bigbuf_size          					*/
/************************************************************************/

static Vm_Obj muq_set_vm_bigbuf_size(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	Vm_Int  size = OBJ_TO_INT(v);
	if (0 < size)   vm_Resize_Bigbuf( (unsigned) size );
    }
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    muq_set_consecutive_backups_to_keep				*/
/************************************************************************/

static Vm_Obj
muq_set_consecutive_backups_to_keep(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && (i = OBJ_TO_INT(v))
    &&  i > 1
    ){
	vm_Set_Consecutive_Backups_To_Keep(0,i);
    }
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
