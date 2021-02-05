@example  @c
/*  to do: */

/* Implement ascii->html and html->ascii. */

/* "Guarantee_*_Arg" functions should be in relevant classes...? */

/* Put limits on number of processes/user, and amount of */
/* store allocation/process run, to catch bugs before they */
/* flood the disk. */

/* Use random number state in job state objects. */

/* Someday: Have fast non-jump ops skip updating instruction */
/* count to speed them up a bit.                             */


/*--   job.c -- Multithreaded-processes / bytecode-intepreter.		*/
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
/* Created:      93Feb01						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-1997, by Jeff Prothero.				*/
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
/* "It is easier to ask forgiveness than permission"			*/
/*   -- Grace Hopper							*/
/************************************************************************/

/************************************************************************/
/*-    Overview	of instruction dispatch					*/
/************************************************************************/

/************************************************************************/
/*

This module implements a simple multi-threaded bytecode
interpreter.

See manual node Job State for an overview of state kept.

Also see manual node Instruction Dispatch.
Also see manual node Job Queues.
Also see manual node Signals.
Also see manual node Job Control.

 ************************************************************************/

/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"
#include "jobprims.h"

/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/****************************************************/
/* We can't make our bytecodes/timeslice any bigger */
/* than JOB_OPS_COUNT_MASK, although we could make  */
/* it smaller if we wanted.  We don't want to make  */
/* this too large because it is also the minimum    */
/* number of free slots allowable on the data stack */
/* at the start of the timeslice:		    */
/*						    */
/* As a speed hack, we don't check for stack	    */
/* overflow during a timeslice on fast operations,  */
/* just limit them to pushing a maximum of one	    */
/* item each, so that no timeslice can push more    */
/* than MAX_BYTECODES items on the stack blindly.   */
/*						    */
/* Slow opcodes can push more items than this, but  */
/* they explicitly check for overflow.		    */
/****************************************************/

#define JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP (JOB_OPS_COUNT_MASK>>1)
#define jS job_RunState

#ifndef JOB_MICROSECONDS_TO_SLEEP_PER_TIMESLICE
#define JOB_MICROSECONDS_TO_SLEEP_PER_TIMESLICE      (           0)
#endif

#ifndef JOB_MAX_MICROSECONDS_TO_SLEEP_IN_BUSY_SELECT
#define JOB_MAX_MICROSECONDS_TO_SLEEP_IN_BUSY_SELECT (           0)
#endif

/* I set this at 1 sec so sleeping jobs have */
/* some chance of waking to 1-sec precision: */
#ifndef JOB_MAX_MICROSECONDS_TO_SLEEP_IN_IDLE_SELECT
#define JOB_MAX_MICROSECONDS_TO_SLEEP_IN_IDLE_SELECT (1*1000*1000)
#endif

/* Max bytecodes job_Run() should execute before returning: */
#ifndef JOB_MAX_BYTECODES_PER_TIMESLICE
#define JOB_MAX_BYTECODES_PER_TIMESLICE (0x100)
#endif

/* Eventually, there is no reason processes cannot */
/* continue running after a server restart.  This  */
/* would require restoring their I/O, in general,  */
/* which I haven't thought about yet, so currently */
/* we empty all job queues at startup:             */
#ifndef JOB_NUKE_ALL_JOBS_AT_STARTUP
#define JOB_NUKE_ALL_JOBS_AT_STARTUP TRUE
#endif

#if MUQ_IS_PARANOID
/* Any pair of a priori unlikely values: */
#define JOB_LONGJMP_BUF_PREGUARD  0x14566541
#define JOB_LONGJMP_BUF_POSTGUARD 0x65411456
#endif

/* Operation codes passed to throw(): */
#define JOB_GOTO   (0)
#define JOB_THROW  (1)
#define JOB_ENDJOB (2)
#define JOB_EXEC   (3)

/* for_new() and job_P_Exec() need to agree on */
/* number of dummy entries at bottom of stack, */
/* so we declare here, check in for_new() and  */
/* use blindly in job_P_Exec():                */
#define JOB_DUMMY_ENTRIES_AT_BOTTOM_OF_LOOP_STACK 6

/************************************************************************/
/*-    Statics								*/
/************************************************************************/

#if MUQ_DEBUG
static Vm_Int   invariants(FILE*,Vm_Uch*,Vm_Obj);
#endif

static Vm_Obj   job_make_ephemeral_struct( Vm_Obj );

void job_must_control( Vm_Obj );

static void job_x_p_del_key(   Vm_Int );
static void job_x_p_del_key_p( Vm_Int );
static void job_x_p_get_key_p( Vm_Int );
static void job_x_p_get_first_key( Vm_Int );
static void job_x_p_get_keys_by_prefix( Vm_Int );
static void job_x_p_get_next_key( Vm_Int );
static void job_x_p_get_val( Vm_Int );
static void job_x_p_get_val_p( Vm_Int );
static void job_x_p_keysvals_block( Vm_Int );
static void job_x_p_keys_block( Vm_Int );
static void job_x_p_set_from_block( Vm_Int );
static void job_x_p_set_from_keysvals_block( Vm_Int );
static void job_x_p_set_val( Vm_Int );
static void job_x_p_vals_block( Vm_Int );

static void     throw( Vm_Obj, Vm_Int );
static void     job_next( void );
static void     pop_thunkframe_normally(  Vm_Obj* );
static void     pop_thunkframe_during_error_recovery(  Vm_Obj* );
static void     job_end_job( Vm_Obj );
static void     push_user_frame( Vm_Obj );

static Vm_Unt   sizeof_job( Vm_Unt );
static void     for_new( Vm_Obj, Vm_Unt );

static Vm_Obj	job_acting_user(	 Vm_Obj );
static Vm_Obj	job_actual_user(	 Vm_Obj );
static Vm_Obj	job_task( 	 	 Vm_Obj );
static Vm_Obj	job_break_disable( 	 Vm_Obj );
static Vm_Obj	job_break_enable( 	 Vm_Obj );
static Vm_Obj	job_break_on_signal( 	 Vm_Obj );
static Vm_Obj	job_data_stack(	 	 Vm_Obj );
static Vm_Obj	job_doing_promiscuous_read(Vm_Obj);
static Vm_Obj	job_promiscuous_no_fragments(Vm_Obj);
static Vm_Obj	job_standard_output( 	 Vm_Obj );
static Vm_Obj	job_error_output(	 Vm_Obj );
static Vm_Obj	job_trace_output(	 Vm_Obj );
static Vm_Obj	job_terminal_io(	 Vm_Obj );
static Vm_Obj	job_query_io(		 Vm_Obj );
static Vm_Obj	job_debug_io(		 Vm_Obj );
static Vm_Obj	job_do_break(	 	 Vm_Obj );
static Vm_Obj	job_debugger(	 	 Vm_Obj );
static Vm_Obj	job_debugger_hook( 	 Vm_Obj );
static Vm_Obj	job_do_error(	 	 Vm_Obj );
static Vm_Obj	job_do_signal(	 	 Vm_Obj );
static Vm_Obj	job_ephemeral_lists(	 Vm_Obj );
static Vm_Obj	job_ephemeral_objects(	 Vm_Obj );
static Vm_Obj	job_ephemeral_structs(	 Vm_Obj );
static Vm_Obj	job_ephemeral_vectors(	 Vm_Obj );
static Vm_Obj	job_function_bindings(	 Vm_Obj );
static Vm_Obj	job_variable_bindings(	 Vm_Obj );
static Vm_Obj	job_group(               Vm_Obj );
static Vm_Obj	job_here_obj(	 	 Vm_Obj );
static Vm_Obj	job_job_set(	 	 Vm_Obj );
static Vm_Obj	job_kill_stdout_on_exit( Vm_Obj );
static Vm_Obj	job_lib(	 	 Vm_Obj );
static Vm_Obj	job_loop_stack(	 	 Vm_Obj );
static Vm_Obj	job_muqnet_io(		 Vm_Obj );
static Vm_Obj	job_op_count(		 Vm_Obj );
static Vm_Obj	job_package(	 	 Vm_Obj );
static Vm_Obj	job_parent(	 	 Vm_Obj );
static Vm_Obj	job_pid(	 	 Vm_Obj );
static Vm_Obj	job_priority(	 	 Vm_Obj );
#ifdef OLD
static Vm_Obj	job_q_until_sec( 	 Vm_Obj );
static Vm_Obj	job_q_until_nsec( 	 Vm_Obj );
#else
static Vm_Obj	job_q_until_msec( 	 Vm_Obj );
#endif
static Vm_Obj	job_read_nil(	 	 Vm_Obj );
static Vm_Obj	job_readtable(	 	 Vm_Obj );
static Vm_Obj	job_report_event( 	 Vm_Obj );
static Vm_Obj	job_root_obj(	 	 Vm_Obj );
static Vm_Obj	job_spare_assembler( 	 Vm_Obj );
static Vm_Obj	job_spare_compile_message_stream( 	 Vm_Obj );
static Vm_Obj	job_standard_input( 	 Vm_Obj );
static Vm_Obj	job_stack_bottom( 	 Vm_Obj );
static Vm_Obj	job_state(	 	 Vm_Obj );
static Vm_Obj	job_get_compiler( 	 Vm_Obj );
static Vm_Obj	job_get_end_job( 	 Vm_Obj );

static Vm_Obj	job_yylhs(		 Vm_Obj );
static Vm_Obj	job_yylen(		 Vm_Obj );
static Vm_Obj	job_yydefred(		 Vm_Obj );
static Vm_Obj	job_yydgoto(		 Vm_Obj );
static Vm_Obj	job_yysindex(		 Vm_Obj );
static Vm_Obj	job_yyrindex(		 Vm_Obj );
static Vm_Obj	job_yygindex(		 Vm_Obj );
static Vm_Obj	job_YYTABLESIZE(	 Vm_Obj );
static Vm_Obj	job_yytable(		 Vm_Obj );
static Vm_Obj	job_yycheck(		 Vm_Obj );
static Vm_Obj	job_YYFINAL(		 Vm_Obj );
static Vm_Obj	job_YYMAXTOKEN(		 Vm_Obj );
static Vm_Obj	job_yyname(		 Vm_Obj );
static Vm_Obj	job_yyrule(		 Vm_Obj );
static Vm_Obj	job_yyaction(		 Vm_Obj );

static Vm_Obj	job_yyss(		 Vm_Obj );
static Vm_Obj	job_yyvs(		 Vm_Obj );
static Vm_Obj	job_yyval(		 Vm_Obj );
static Vm_Obj	job_yylval(		 Vm_Obj );
static Vm_Obj	job_yydebug(		 Vm_Obj );
static Vm_Obj	job_yyinput(		 Vm_Obj );
static Vm_Obj	job_yycursor(		 Vm_Obj );
static Vm_Obj	job_yyreadfn(		 Vm_Obj );
static Vm_Obj	job_yyprompt(		 Vm_Obj );

static Vm_Obj	job_set_task( 	 	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_compiler(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_end_job(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_acting_user(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_actual_user(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_break_disable(   Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_break_enable(    Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_break_on_signal( Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_data_stack(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_do_break(        Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_debugger(        Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_debugger_hook(   Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_kill_stdout_on_exit(Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_read_nil(        Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_standard_output( Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_trace_output(    Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_terminal_io(     Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_query_io(        Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_debug_io(        Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_error_output(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_do_error(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_do_signal(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_ephemeral_lists(  Vm_Obj,Vm_Obj );
static Vm_Obj	job_set_ephemeral_objects(Vm_Obj,Vm_Obj );
static Vm_Obj	job_set_ephemeral_structs(Vm_Obj,Vm_Obj );
static Vm_Obj	job_set_ephemeral_vectors(Vm_Obj,Vm_Obj );
static Vm_Obj	job_set_function_bindings(Vm_Obj,Vm_Obj );
static Vm_Obj	job_set_variable_bindings(Vm_Obj,Vm_Obj );
static Vm_Obj	job_set_group(           Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_here_obj(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_job_set(         Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_lib(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_muqnet_io(       Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_never(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_op_count(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_package(         Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_parent(          Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_pid(             Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_priority(        Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_readtable(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_report_event(    Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_root_obj(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_spare_assembler( Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_spare_compile_message_stream( Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_standard_input(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_stack_bottom(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_state(		 Vm_Obj, Vm_Obj );

static Vm_Obj	job_set_yylhs(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yylen(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yydefred(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yydgoto(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yysindex(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyrindex(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yygindex(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_YYTABLESIZE(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yytable(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yycheck(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_YYFINAL(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_YYMAXTOKEN(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyname(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyrule(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyaction(	 Vm_Obj, Vm_Obj );

static Vm_Obj	job_set_yyss(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyvs(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyval(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yylval(		 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yydebug(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyinput(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yycursor(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyreadfn(	 Vm_Obj, Vm_Obj );
static Vm_Obj	job_set_yyprompt(	 Vm_Obj, Vm_Obj );

#if MUQ_IS_PARANOID
static void     job_check_for_setjmp_bug( void );
#endif

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

Vm_Int job_Max_Bytecodes_Per_Timeslice = (
       JOB_MAX_BYTECODES_PER_TIMESLICE
);

Vm_Int job_Max_Microseconds_To_Sleep_In_Busy_Select = (
       JOB_MAX_MICROSECONDS_TO_SLEEP_IN_BUSY_SELECT
);
Vm_Int job_Max_Microseconds_To_Sleep_In_Idle_Select = (
       JOB_MAX_MICROSECONDS_TO_SLEEP_IN_IDLE_SELECT
);

Vm_Int job_Microseconds_To_Sleep_Per_Timeslice  = (
       JOB_MICROSECONDS_TO_SLEEP_PER_TIMESLICE
);

Vm_Int job_Nuke_All_Jobs_At_Startup = (
       JOB_NUKE_ALL_JOBS_AT_STARTUP
);

Job_A_RunState job_RunState;

/* Description of standard-header system properties: */
static Obj_A_Special_Property job_system_properties[] = {

    /****************************************************/
    /* loop_stack and and data_stack are '@' because	*/
    /* I think having them '~' would likely open up	*/
    /* security/privacy holes when normal users peek	*/
    /* at stack contents of setuid-root'd functions.	*/
    /****************************************************/

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"doBreak",	 job_do_break,	 	  job_set_do_break	   },
    {0,"debugger",	 job_debugger,	 	  job_set_debugger	   },
    {0,"debuggerHook",  job_debugger_hook, 	  job_set_debugger_hook	   },
    {0,"doError",	 job_do_error,	 	  job_set_do_error	   },
    {0,"doSignal",	 job_do_signal,	 	  job_set_do_signal	   },

    {0,"compiler",	 job_get_compiler, 	  job_set_compiler	   },
    {0,"endJob",	 job_get_end_job, 	  job_set_end_job	   },
    {0,"actingUser",	 job_acting_user,	  job_set_acting_user	   },
    {0,"actualUser",	 job_actual_user,	  job_set_actual_user	   },
    {0,"breakDisable",  job_break_disable,	  job_set_break_disable    },
    {0,"breakEnable",   job_break_enable,	  job_set_break_enable	   },
    {0,"breakOnSignal",job_break_on_signal,	  job_set_break_on_signal  },
    {0,"dataStack",	 job_data_stack,	  job_set_data_stack	   },
    {0,"debugIo",       job_debug_io,            job_set_debug_io         },
    {0,"doingPromiscuousRead",job_doing_promiscuous_read,job_set_never   },
    {0,"promiscuousNoFragments",job_promiscuous_no_fragments,job_set_never},
    {0,"errorOutput", 	 job_error_output,        job_set_error_output	   },
    {0,"ephemeralList", job_ephemeral_lists,     job_set_ephemeral_lists  },
    {0,"ephemeralObjects",job_ephemeral_objects, job_set_ephemeral_objects},
    {0,"ephemeralStructs",job_ephemeral_structs, job_set_ephemeral_structs},
    {0,"ephemeralVectors",job_ephemeral_vectors, job_set_ephemeral_vectors},
    {0,"functionBindings",job_function_bindings, job_set_function_bindings},
    {0,"group",  	 job_group,	          job_set_group		   },
    {0,"here",		 job_here_obj,	 	  job_set_here_obj	   },
    {0,"jobSet",	 job_job_set,	 	  job_set_job_set	   },
    {0,"killStandardOutputOnExit",job_kill_stdout_on_exit, job_set_kill_stdout_on_exit },
    {0,"lib",		 job_lib,		  job_set_lib		   },
    {0,"loopStack",	 job_loop_stack,	  job_set_never		   },
    {0,"muqnetIo",      job_muqnet_io,            job_set_muqnet_io        },
    {0,"opCount",	 job_op_count,	  	  job_set_op_count	   },
    {0,"package",	 job_package, 	          job_set_package	   },
    {0,"parentJob",	 job_parent,	 	  job_set_parent	   },
    {0,"pid",		 job_pid,	 	  job_set_pid		   },
    {0,"priority",	 job_priority,	 	  job_set_priority	   },
    {0,"queryIo",       job_query_io,            job_set_query_io         },
    {0,"readNilFromDeadStreams",job_read_nil, job_set_read_nil	   },
    {0,"readtable"      ,job_readtable,           job_set_readtable	   },
    {0,"reportEvent"    ,job_report_event, 	  job_set_report_event     },
    {0,"task"           ,job_task,                job_set_task             },
    {0,"root",		 job_root_obj,	 	  job_set_root_obj	   },
#ifdef OLD
    {0,"sleepUntilSec", job_q_until_sec,  	  job_set_never		   },
    {0,"sleepUntilNsec",job_q_until_nsec,  	  job_set_never		   },
#else
    {0,"sleepUntilMillisec", job_q_until_msec, 	  job_set_never		   },
#endif
    {0,"spareAssembler",job_spare_assembler, 	  job_set_spare_assembler  },
    {0,"spareCompileMessageStream",job_spare_compile_message_stream,job_set_spare_compile_message_stream},
    {0,"stackBottom",	 job_stack_bottom, 	  job_set_stack_bottom	   },
    {0,"standardInput", job_standard_input,      job_set_standard_input   },
    {0,"standardOutput",job_standard_output,     job_set_standard_output  },
    {0,"state",	 	 job_state, 	          job_set_state		   },
    {0,"terminalIo",    job_terminal_io,         job_set_terminal_io      },
    {0,"traceOutput",   job_trace_output,        job_set_trace_output     },
    {0,"variableBindings",job_variable_bindings, job_set_variable_bindings},

    {0,"yylhs",job_yylhs, job_set_yylhs},
    {0,"yylen",job_yylen, job_set_yylen},
    {0,"yydefred",job_yydefred, job_set_yydefred},
    {0,"yydgoto",job_yydgoto, job_set_yydgoto},
    {0,"yysindex",job_yysindex, job_set_yysindex},
    {0,"yyrindex",job_yyrindex, job_set_yyrindex},
    {0,"yygindex",job_yygindex, job_set_yygindex},
    {0,"YYTABLESIZE",job_YYTABLESIZE, job_set_YYTABLESIZE},
    {0,"yytable",job_yytable, job_set_yytable},
    {0,"yycheck",job_yycheck, job_set_yycheck},
    {0,"YYFINAL",job_YYFINAL, job_set_YYFINAL},
    {0,"YYMAXTOKEN",job_YYMAXTOKEN, job_set_YYMAXTOKEN},
    {0,"yyname",job_yyname, job_set_yyname},
    {0,"yyrule",job_yyrule, job_set_yyrule},
    {0,"yyaction",job_yyaction, job_set_yyaction},

    {0,"yyss",job_yyss, job_set_yyss},
    {0,"yyvs",job_yyvs, job_set_yyvs},
    {0,"yyval",job_yyval, job_set_yyval},
    {0,"yylval",job_yylval, job_set_yylval},
    {0,"yydebug",job_yydebug, job_set_yydebug},
    {0,"yyinput",job_yyinput, job_set_yyinput},
    {0,"yycursor",job_yycursor, job_set_yycursor},
    {0,"yyreadfn",job_yyreadfn, job_set_yyreadfn},
    {0,"yyprompt",job_yyprompt, job_set_yyprompt},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class job_Hardcoded_Class = {
    OBJ_FROM_BYT3('j','o','b'),
    "Job",
    sizeof_job,
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
    { job_system_properties, job_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void job_doTypes(void){}
Obj_A_Module_Summary job_Module_Summary = {
   "job",
    job_doTypes,
    job_Startup,
    job_Linkup,
    job_Shutdown,
};

/* longjmp() buffer shared by job_Warn()/job_next() and job_Run(): */
#if MUQ_IS_PARANOID
static int     job_longjmp_buf_is_valid = FALSE;
static int     job_longjmp_buf_preguard;
#endif
static jmp_buf job_longjmp_buf;
#if MUQ_IS_PARANOID
static int     job_longjmp_buf_postguard;
#endif

/* Set this flag to TRUE to close down muq */
/* interpreter at end of this timeslice:   */
Vm_Int job_End_Of_Run = FALSE;


/* Set this flag to TRUE to schedule next  */
/* job, for example after moving current   */
/* job to a wait queue of some sort:       */
Vm_Int job_End_Of_Timeslice = FALSE;

/* Flag set/cleared by root-trace-on/root-trace-off */
/* which controls bytecode tracing when MUQ_TRACE   */
/* code is conditionally compiled into server:      */
Vm_Int job_Reserved = 0;
Vm_Int job_Bytecodes_Logged = 0;
Vm_Int job_Log_Bytecodes = FALSE;
Vm_Int job_Log_Warnings = TRUE;


/* Indirection pointers so we can switch OpenGL */
/* primitives on or off.  These are used by the */
/* SLO3 and SLO4 fast prims in place of the     */
/* tables themselves:                           */
Job_Slow_Prim * job_OpenGL_Table3 = job_Slow_Table3;
Job_Slow_Prim * job_OpenGL_Table4 = job_Slow_Table4;


/* Keywords: */

Vm_Obj job_Kw_Allocation;
Vm_Obj job_Kw_Class;
Vm_Obj job_Kw_Dbname;
Vm_Obj job_Kw_Documentation;
Vm_Obj job_Kw_Keyword;
Vm_Obj job_Kw_Inherited;
Vm_Obj job_Kw_Initform;
Vm_Obj job_Kw_Initarg;
Vm_Obj job_Kw_Instance;
Vm_Obj job_Kw_Is_A;
Vm_Obj job_Kw_Type;
Vm_Obj job_Kw_Get_Function;
Vm_Obj job_Kw_Set_Function;
Vm_Obj job_Kw_Root_May_Read;
Vm_Obj job_Kw_Root_May_Write;
Vm_Obj job_Kw_User_May_Read;
Vm_Obj job_Kw_User_May_Write;
Vm_Obj job_Kw_Class_May_Read;
Vm_Obj job_Kw_Class_May_Write;
Vm_Obj job_Kw_World_May_Read;
Vm_Obj job_Kw_World_May_Write;

Vm_Obj job_Kw_Acting_User;
Vm_Obj job_Kw_Actual_User;
Vm_Obj job_Kw_Address_Family;
Vm_Obj job_Kw_Any;
Vm_Obj job_Kw_Batch;
Vm_Obj job_Kw_Blocked_Signals;
Vm_Obj job_Kw_Car;
Vm_Obj job_Kw_Catch;
Vm_Obj job_Kw_Cdr;
Vm_Obj job_Kw_Character;
Vm_Obj job_Kw_Close;
Vm_Obj job_Kw_Mos_Generic;
Vm_Obj job_Kw_Commandline;
Vm_Obj job_Kw_Compiled_Function;
Vm_Obj job_Kw_Data;
Vm_Obj job_Kw_Datagram;
Vm_Obj job_Kw_Downcase;
Vm_Obj job_Kw_End_Job;
Vm_Obj job_Kw_Exec;
Vm_Obj job_Kw_Event;
Vm_Obj job_Kw_Ear;
Vm_Obj job_Kw_Eof;
Vm_Obj job_Kw_Ephemeral;
Vm_Obj job_Kw_Ephemeral_List;
Vm_Obj job_Kw_Ephemeral_Object;
Vm_Obj job_Kw_Ephemeral_Struct;
Vm_Obj job_Kw_Ephemeral_Vector;
Vm_Obj job_Kw_Eql;
Vm_Obj job_Kw_Exit;
Vm_Obj job_Kw_Format_String;
Vm_Obj job_Kw_Function;
Vm_Obj job_Kw_Function_Binding;
Vm_Obj job_Kw_Goto;
Vm_Obj job_Kw_Guest;
Vm_Obj job_Kw_Handlers;
Vm_Obj job_Kw_Handling;
Vm_Obj job_Kw_HashName;
Vm_Obj job_Kw_Host;
Vm_Obj job_Kw_Initform;
Vm_Obj job_Kw_Initval;
Vm_Obj job_Kw_Interactive_Function;
Vm_Obj job_Kw_Interfaces;
Vm_Obj job_Kw_Internet;
Vm_Obj job_Kw_Invert;
Vm_Obj job_Kw_Ip0;
Vm_Obj job_Kw_Ip1;
Vm_Obj job_Kw_Ip2;
Vm_Obj job_Kw_Ip3;
Vm_Obj job_Kw_I0;
Vm_Obj job_Kw_I1;
Vm_Obj job_Kw_I2;
Vm_Obj job_Kw_Job;
Vm_Obj job_Kw_Job_Queue;
Vm_Obj job_Kw_Jump;
Vm_Obj job_Kw_Junk;
Vm_Obj job_Kw_Kind;
Vm_Obj job_Kw_Lock;
Vm_Obj job_Kw_Lock_Child;
Vm_Obj job_Kw_Message_Stream;
Vm_Obj job_Kw_Name;
Vm_Obj job_Kw_Normal;
Vm_Obj job_Kw_Owner;
Vm_Obj job_Kw_Popen;
Vm_Obj job_Kw_Port;
Vm_Obj job_Kw_Preserve;
Vm_Obj job_Kw_Privileges;
Vm_Obj job_Kw_Program_Counter;
Vm_Obj job_Kw_Promise;
Vm_Obj job_Kw_Protect;
Vm_Obj job_Kw_Protect_Child;
Vm_Obj job_Kw_Protocol;
Vm_Obj job_Kw_Report_Function;
Vm_Obj job_Kw_Restart;
Vm_Obj job_Kw_Return;
Vm_Obj job_Kw_Return_Slot;
Vm_Obj job_Kw_Signal;
Vm_Obj job_Kw_Slot;
Vm_Obj job_Kw_Slots;
Vm_Obj job_Kw_Socket;
Vm_Obj job_Kw_Stack_Bottom;
Vm_Obj job_Kw_Stack_Depth;
Vm_Obj job_Kw_Stream;
Vm_Obj job_Kw_Symbol;
Vm_Obj job_Kw_Tag;
Vm_Obj job_Kw_Tagtop;
Vm_Obj job_Kw_Tcp;
Vm_Obj job_Kw_Test_Function;
Vm_Obj job_Kw_Throw;
Vm_Obj job_Kw_Thunk;
Vm_Obj job_Kw_Tmp_User;
Vm_Obj job_Kw_Tty;
Vm_Obj job_Kw_Udp;
Vm_Obj job_Kw_Upcase;
Vm_Obj job_Kw_User;
Vm_Obj job_Kw_Vanilla;
Vm_Obj job_Kw_Value;
Vm_Obj job_Kw_Variable_Binding;
Vm_Obj job_Kw_Variables;
Vm_Obj job_Kw_Why;

Vm_Obj job_Kw_Bignum;
Vm_Obj job_Kw_Built_In;
Vm_Obj job_Kw_Structure;
Vm_Obj job_Kw_Callstack;
Vm_Obj job_Kw_Vector;
Vm_Obj job_Kw_VectorI01;
Vm_Obj job_Kw_VectorI08;
Vm_Obj job_Kw_VectorI16;
Vm_Obj job_Kw_VectorI32;
Vm_Obj job_Kw_VectorF32;
Vm_Obj job_Kw_VectorF64;
Vm_Obj job_Kw_Mos_Key;
Vm_Obj job_Kw_Fixnum;
Vm_Obj job_Kw_Short_Float;
Vm_Obj job_Kw_Stackblock;
Vm_Obj job_Kw_Bottom;
Vm_Obj job_Kw_Compiled_Function;
Vm_Obj job_Kw_Character;
Vm_Obj job_Kw_Cons;
Vm_Obj job_Kw_Special;
Vm_Obj job_Kw_String;
Vm_Obj job_Kw_Symbol;

/* CLX Keywords: */
#ifdef HAVE_X11
Vm_Obj job_Kw_Arc_Mode;
Vm_Obj job_Kw_Background;
Vm_Obj job_Kw_Backing_Pixel;
Vm_Obj job_Kw_Backing_Planes;
Vm_Obj job_Kw_Backing_Store;
Vm_Obj job_Kw_Bit_Gravity;
Vm_Obj job_Kw_Border;
Vm_Obj job_Kw_Border_Width;
Vm_Obj job_Kw_Cap_Style;
Vm_Obj job_Kw_Clip_Mask;
Vm_Obj job_Kw_Clip_Ordering;
Vm_Obj job_Kw_Clip_X;
Vm_Obj job_Kw_Clip_Y;
Vm_Obj job_Kw_Colormap;
Vm_Obj job_Kw_Copy;
Vm_Obj job_Kw_Cursor;
Vm_Obj job_Kw_Dash_Offset;
Vm_Obj job_Kw_Dashes;
Vm_Obj job_Kw_Depth;
Vm_Obj job_Kw_Do_Not_Propagate_Mask;
Vm_Obj job_Kw_Drawable;
Vm_Obj job_Kw_Event_Mask;
Vm_Obj job_Kw_Exposures;
Vm_Obj job_Kw_Fill_Rule;
Vm_Obj job_Kw_Fill_Style;
Vm_Obj job_Kw_Font;
Vm_Obj job_Kw_Foreground;
Vm_Obj job_Kw_Function;
Vm_Obj job_Kw_Gravity;
Vm_Obj job_Kw_Height;
Vm_Obj job_Kw_Input_Only;
Vm_Obj job_Kw_Input_Output;
Vm_Obj job_Kw_Join_Style;
Vm_Obj job_Kw_Left_To_Right;
Vm_Obj job_Kw_Line_Style;
Vm_Obj job_Kw_Line_Width;
Vm_Obj job_Kw_Override_Redirect;
Vm_Obj job_Kw_Parent;
Vm_Obj job_Kw_Plane_Mask;
Vm_Obj job_Kw_Right_To_Left;
Vm_Obj job_Kw_Save_Under;
Vm_Obj job_Kw_Stipple;
Vm_Obj job_Kw_Subwindow_Mode;
Vm_Obj job_Kw_Tile;
Vm_Obj job_Kw_Ts_X;
Vm_Obj job_Kw_Ts_Y;
Vm_Obj job_Kw_Visual;
Vm_Obj job_Kw_Width;
Vm_Obj job_Kw_X;
Vm_Obj job_Kw_Y;

Vm_Obj job_Kw_Button_1_Motion;
Vm_Obj job_Kw_Button_2_Motion;
Vm_Obj job_Kw_Button_3_Motion;
Vm_Obj job_Kw_Button_4_Motion;
Vm_Obj job_Kw_Button_5_Motion;
Vm_Obj job_Kw_Button_Motion;
Vm_Obj job_Kw_Button_Press;
Vm_Obj job_Kw_Button_Release;
Vm_Obj job_Kw_Colormap_Change;
Vm_Obj job_Kw_Enter_Window;
Vm_Obj job_Kw_Exposure;
Vm_Obj job_Kw_Focus_Change;
Vm_Obj job_Kw_Key_Press;
Vm_Obj job_Kw_Key_Release;
Vm_Obj job_Kw_Keymap_State;
Vm_Obj job_Kw_Leave_Window;
Vm_Obj job_Kw_Owner_Grab_Button;
Vm_Obj job_Kw_Pointer_Motion;
Vm_Obj job_Kw_Pointer_Motion_Hint;
Vm_Obj job_Kw_Property_Change;
Vm_Obj job_Kw_Resize_Redirect;
Vm_Obj job_Kw_Structure_Notify;
Vm_Obj job_Kw_Substructure_Notify;
Vm_Obj job_Kw_Substructure_Redirect;
Vm_Obj job_Kw_Visibility_Change;
#endif


/************************************************************************/
/*-    Public fns, true prims for jobprims.c	 			*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_Make     -- Generic fork prim called by job_P_Make_*.	*/
 /***********************************************************************/

void
job_Make(
    Vm_Int what	/* One of JOB_FORK_JOB/JOBSET/SESSION/SKT. */
) {
    Vm_Obj name	= *jS.s; /* Goes in name field of new object.	   */

    /* Make sure we have space to push result on stack: */
    job_Guarantee_N_Args( 1 );

    /* Seize one stack location, and push a NIL on it: */
    *jS.s = OBJ_NIL;

    /* Update state of current job so job_Make_Job() has good data: */
    job_State_Update();

    /* Make a copy of it, and return job/jobset/session/skt top of stack: */
    {   Vm_Obj  result = job_Make_Job( what, name );
        *jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_P_Copy_Job -- Split current process, just like unix fork.	*/
 /***********************************************************************/

void job_P_Copy_Job( void ) { job_Make( JOB_FORK_JOB ); }

 /***********************************************************************/
 /*-    job_P_Copy_Job_Set -- Split current job+jbs.			*/
 /***********************************************************************/

void job_P_Copy_Job_Set( void ) { job_Make( JOB_FORK_JOBSET ); }

 /***********************************************************************/
 /*-    job_P_Copy_Session -- Split current job+jbs+ssn.		*/
 /***********************************************************************/

void job_P_Copy_Session( void ) { job_Make( JOB_FORK_SESSION ); }

 /***********************************************************************/
 /*-    job_Make_Job -- Fork current job, optionally jobset/sessions too.*/
 /***********************************************************************/

static Vm_Obj
job_issue_pid(
    void
) {
    if (!OBJ_IS_OBJ(obj_Muq) || !OBJ_IS_CLASS_MUQ(obj_Muq)) {
	/* Too early in initialization to */
	/* have access to obj_Muq so:     */
	return OBJ_FROM_INT(0);
    } else {
	Muq_P m     = MUQ_P( obj_Muq );
	Vm_Obj pid  = m->next_pid;
	m->next_pid = OBJ_FROM_INT( (Vm_Unt)(~0>>2) & (OBJ_TO_INT(pid)+1) );
	vm_Dirty( obj_Muq );
	return pid;
    }
}

Vm_Obj
job_Make_Job(
    Vm_Int what,	/* One of JOB_FORK_JOB/JOBSET/SESSION/SKT. */
    Vm_Obj name		/* Goes in name slot of new job.	   */
) {
    /* Locate current job, jobset, session and skt: */
    Vm_Obj old_job = jS.job;
    Vm_Obj new_job = obj_Dup( old_job );
    Vm_Obj job_set = OBJ_FROM_INT(0);	/* Just to quiet compilers. */
    Vm_Obj session = OBJ_FROM_INT(0);	/* Just to quiet compilers. */

    /* Find a suitable pid for new job: */
    Vm_Obj pid = job_issue_pid();

    OBJ_P(new_job)->objname = name;  vm_Dirty(new_job);

    /* Duplicate session/jobset/job as requested: */
    switch (what) {

    case JOB_FORK_JOB:
        job_set = JOB_P(old_job)->job_set;
	break;

    case JOB_FORK_JOBSET:
        job_set = JOB_P(old_job)->job_set;
	session = JBS_P(job_set)->session;
	job_set = obj_Alloc( OBJ_CLASS_A_JBS, 0 );
	/* Add new jobset to session: */
        OBJ_SET( session, job_set, job_set, OBJ_PROP_PUBLIC );
	/* Record jobset leader and session: */
	{   Jbs_P  jbs	        = JBS_P(job_set);
	    jbs->jobset_leader  = new_job;
            jbs->session        = session;
	    vm_Dirty(job_set);
	}
	break;

    case JOB_FORK_SESSION:
	session = obj_Alloc( OBJ_CLASS_A_SSN, 0 );
	job_set = obj_Alloc( OBJ_CLASS_A_JBS, 0 );

	/* Add new jobset to session: */
        ssn_Link_Jobset( session, job_set );

	/* Record session leader: */
	{   Ssn_P  ssn     	    = SSN_P(session);
	    ssn->session_leader	    = new_job;
	    vm_Dirty(session);
	}

	/* Record jobset leader and session: */
	{   Jbs_P  jbs	        = JBS_P(job_set);
	    jbs->jobset_leader  = new_job;
            jbs->session        = session;
	    vm_Dirty(job_set);
	}
	break;

    default:
	MUQ_FATAL ("job.c:job_Make_Job(): internal err");
    }


    /* Initialize new job appropriately: */
    {   Job_P p	    		= JOB_P(new_job);

	p->op_count		= OBJ_FROM_INT(0);

	p->parent		= old_job;

        p->job_set		= job_set;

	/* Must not let job-queue-membership  */
	/* info of parent propagate to child: */
        {   Vm_Int i;
	    for (i = JOB_QUEUE_MEMBERSHIP_MAX;   i --> 0; ) {
		Joq_Link l = &p->link[i];
		l->this		= OBJ_FROM_INT(0); /* This makes job unenqueueable */
		l->next.o	= OBJ_FROM_INT(0);
		l->prev.o	= OBJ_FROM_INT(0);
		l->next.i	= OBJ_FROM_INT(0);
		l->prev.i	= OBJ_FROM_INT(0);
        }   }

#ifdef OLD
	p->until_sec		= OBJ_FROM_INT(0);
	p->until_nsec		= OBJ_FROM_INT(0);
#else
	p->until_msec		= OBJ_FROM_INT(0);
#endif
	p->q_pre_stop		= OBJ_FROM_INT(0);

	p->muqnet_io		= OBJ_FROM_INT(0);

	p->pid			= pid;
	p->o.objname		= pid;

	p->spare_assembler	= OBJ_FROM_INT(0);
	p->spare_compile_message_stream	= OBJ_FROM_INT(0);

	vm_Dirty(new_job);
    }

    /* Build and insert our data and loop stacks: */
    {	Vm_Obj old_data = JOB_P(old_job)->j.data_stack;
	Vm_Obj new_data = stk_Dup( old_data );

	Vm_Obj old_loop = JOB_P(old_job)->j.loop_stack;
	Vm_Obj new_loop = stk_Dup( old_loop );

	{   Job_P j = JOB_P(new_job);
	    j->j.data_stack = new_data;
	    j->j.loop_stack = new_loop;
	    /* Make job runnable: */
	    j->link[JOB_QUEUE_PS].this = OBJ_FROM_INT(1);
	    vm_Dirty(new_job);
	}

	/* Child must not inherit locks held by     */
	/* parent, so convert all LOCK stackframes  */
	/* in childs loopstack to NULL stackframes. */
	/* Child must also not inherit }alwaysDo{} */
	/* clauses from parent, so also convert all */
	/* PROTECT stackframes in child to VANILLA: */
	{   Vm_Int sp  = OBJ_TO_INT( STK_P(new_loop)->length );
	    Vm_Obj vec = STK_P(new_loop)->vector;
	    Vec_P  v   = VEC_P(   vec );
	    register Vm_Obj* l = &v->slot[ sp -1 ];
	    Vm_Obj* n1 = NULL;	/* First NORMAL frame. */
	    while (*l) {
		if (l[-1] == JOB_STACKFRAME_LOCK) {
		    l[-1]  = JOB_STACKFRAME_NULL;
		}
		if (l[-1] == JOB_STACKFRAME_PROTECT) {
		    l[-1]  = JOB_STACKFRAME_VANILLA;
		}
		if (l[-1] == JOB_STACKFRAME_NORMAL && !n1) {
		    n1     = l;
		}
		l = JOB_PREV_STACKFRAME(l);
            }

	    #if MUQ_IS_PARANOID
	    if (!n1) MUQ_FATAL ("job_Make_Job internal err");
	    #endif

	    /* Make sure child task starts execution */
	    /* _after_ the copyJob instruction,     */
	    /* instead of executing it again ... !   */
	    n1 = JOB_PREV_STACKFRAME(n1);
	    n1[2] /* programCounter */ = (
		OBJ_FROM_INT( OBJ_TO_INT(n1[2]) + jS.instruction_len )
	    );

	    vm_Dirty(vec);
        }

	/* Similarly, parent must not retain any    */
        /* PROTECT_CHILD clauses after the fork,    */
	/* and must not inherit any child locks:     */
	{   Vm_Int sp  = OBJ_TO_INT( STK_P(old_loop)->length );
	    Vm_Obj vec = STK_P(old_loop)->vector;
	    Vec_P  v   = VEC_P(   vec );
	    register Vm_Obj* l = &v->slot[ sp -1 ];
	    while (*l) {
		if (l[-1] == JOB_STACKFRAME_LOCK_CHILD) {
		    l[-1]  = JOB_STACKFRAME_NULL;

		    /* Need to record lock as now being */
		    /* held by child:                   */
		    {   Vm_Int   i   = l - v->slot;
			Vm_Obj   lok = l[-2];
			LOK_P(   lok )->held_by = new_job;
			vm_Dirty(lok);

			/* Above may have trashed v and l: */
			v   = VEC_P(   vec );
	                l   = v->slot + i;
		}   }
		if (l[-1] == JOB_STACKFRAME_PROTECT_CHILD) {
		    l[-1]  = JOB_STACKFRAME_VANILLA;
		}
		l = JOB_PREV_STACKFRAME(l);
            }

	    vm_Dirty(vec);
    }   }

    /* Enter new job in jobset: */
    {   Vm_Obj joq = JBS_P(job_set)->job_queue;
	joq_Link( joq, new_job, JOB_QUEUE_JOBSET );
    }

    /* Enter job in global ps: */
    joq_Link( obj_Ps, new_job, JOB_QUEUE_GLOBAL_PS );

    /* Enter job in user's ps: */
    {   Vm_Obj ps = USR_P(jS.j.acting_user)->ps_q;
	joq_Link( ps, new_job, JOB_QUEUE_PS );
    }

    joq_Pause_Job( new_job );

    return new_job;
}

 /***********************************************************************/
 /*-    job_P_Bad -- A guaranteed bad opcode for /etc/exe.		*/
 /***********************************************************************/

void
job_P_Bad(
    void
) {
    MUQ_WARN ("Unimplemented opcode.");
}

 /***********************************************************************/
 /*-    job_P_Copy -- Return copy of arg.				*/
 /***********************************************************************/

void
job_P_Copy(
    void
) {
    Vm_Obj o = *jS.s;
    job_Guarantee_N_Args( 1 );

    /* What to do depends on type of argument: */
    switch (OBJ_TYPE(o)) {

    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_BLK:
	/* Attempting to copy BLK should be an      */
	/* error, perhaps?  Assembler typechecker   */
	/* should prevent it anyhow, usually.       */
    case OBJ_TYPE_FLOAT:
    case OBJ_TYPE_INT:
    case OBJ_TYPE_BYTN:
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
    case OBJ_TYPE_CHAR:
	/* For pure types, we have nothing to do: */
	return;

    case OBJ_TYPE_THUNK:
	/* For a thunk, we want to trigger   */
	/* computation of the thunk and then */
	/* re-execution of this instruction: */
	job_ThunkN( 0 );
	/* Shouldn't return: */
	#if MUQ_IS_PARANOID
	MUQ_FATAL ("job_P_Copy/Thunk");
	#endif

    case OBJ_TYPE_VEC:
	*jS.s = vec_Dup( *jS.s );
	return;

    case OBJ_TYPE_CFN:
/* Buggo? Dunno if we really wanna duplicate exes: */
	*jS.s = cfn_Dup( *jS.s );
	return;

    case OBJ_TYPE_OBJ:
/* BUGGO -- some things we don't wanna duplicate. */
/* like jobs, roots, users, avatars, data and     */
/* loop stacks... probably safer to check for	  */
/* what we _do_ allow cloning, and disallow	  */
/* everything else.				  */
/* BUGGO -- should copy only properties visible   */
/* to new owner of object.                        */
	*jS.s = obj_Dup( *jS.s );
	return;

    case OBJ_TYPE_SYMBOL:
    case OBJ_TYPE_CONS:
    case OBJ_TYPE_EPHEMERAL_LIST:
    case OBJ_TYPE_EPHEMERAL_STRUCT:
    case OBJ_TYPE_EPHEMERAL_VECTOR:
/* buggo, these cases aren't handled yet. */
/* not sure what some of them should do.  */
	MUQ_WARN ("Copy of this type not implemented");

    case OBJ_TYPE_BOTTOM:
    default:
	/* These types the user should never see: */
	MUQ_FATAL ("job_P_Copy");
    }
}

 /***********************************************************************/
 /*-    job_P_Copy_Cfn --						*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    Overview --							*/
 /***********************************************************************/

/*

This is the function which turns anonymous
functions into data constructors, allowing ': if
'x else 'y fi ; to internally store the values of
x and y for later retrieval.

We are called with stack looking like

  valN offsetN ... val1 offset1 2N cfn

and need to make a copy of 'cfn', then overwrite
the constants at offset1 etc within the copy with
the provided substitute values.  We leave 'cfn' on
the stack.

Since we don't trust user-written compilers, we
need to check that the given offsets are valid as
we do this.

 */


void
job_P_Copy_Cfn(
    void
) {

    Vm_Int n = OBJ_TO_INT( jS.s[-1] );

    /* Check for 'cfn' and 2N arguments: */
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Cfn_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );

    /* Check that 2N arguments also exist: */
    job_Guarantee_N_Args( n+2 );

    /* Construct and locate a duplicate of our cfn: */
    {   Vm_Obj cfn = cfn_Dup( jS.s[0] );
	Cfn_P  p   = CFN_P(cfn);

	/* Update indicated constants in it: */
	Vm_Unt max = CFN_CONSTS( p->bitbag );
	Vm_Int i;
        for   (i = 0;   i < n;   i += 2) {
	    Vm_Unt offset = OBJ_TO_UNT( jS.s[ -2 -i ] );
	    Vm_Obj value  =             jS.s[ -3 -i ]  ;
	    if (offset >= max) {
		MUQ_WARN ("job_Copy_Cfn: no offset %d!", (int)offset);
	    }
	    p->vec[ offset ] = value;
	}
	vm_Dirty(cfn);

	/* Pop given cfn and 2N args, push new cfn: */
	jS.s   -= n+1;	/* 2N args plus 2N itself.  */
	jS.s[0] = cfn;
    }
}

 /***********************************************************************/
 /*-    job_P_Count_Stackframes -- 					*/
 /***********************************************************************/

static Vm_Obj*
find_loopstack_top(
    Vm_Obj* owner,
    Vm_Obj  job
){
    if (job == jS.job) {

	/* Count frames on current stack.   */
	/* need to treat this as a separate */
	/* case because the info in the     */
	/* stack instance will be out of    */
	/* date, in general:                */
	*owner = jS.j.acting_user;
        return jS.l;
    } else {

        Vm_Obj lup = JOB_P(job)->j.loop_stack;
        Vm_Obj usr = JOB_P(job)->j.acting_user;
        Vm_Obj vec = STK_P(job)->vector;
	Vm_Int  sp = OBJ_TO_INT( STK_P( lup )->length );
	Vec_P  v   = VEC_P( vec );
	*owner     = usr;
        return       &v->slot[ sp  -1 ];
    }
}
static Vm_Int
count_stackframes(
    Vm_Obj job
){
    Vm_Obj owner;
    register Vm_Obj* l = find_loopstack_top(&owner,job);
    Vm_Obj i   = 0;

    while (*l) {
	l  = JOB_PREV_STACKFRAME(l);
	++i;
    }
    return i;
}
void
job_P_Count_Stackframes(
    void
) {
    Vm_Obj job = *jS.s;
    job_Guarantee_N_Args(    1 );
    job_Guarantee_Job_Arg(   0 );

    *jS.s = OBJ_FROM_INT( count_stackframes(job) );
}

 /***********************************************************************/
 /*-    job_P_Get_Stackframe -- 					*/
 /***********************************************************************/

static Vm_Obj*
find_nth_stackframe(
    Vm_Obj*owner,
    Vm_Obj job,
    Vm_Int n
){
    Vm_Obj usr;
    register Vm_Obj* l = find_loopstack_top(&usr,job);
    while (n --> 0) {
	if (l[-1] == JOB_STACKFRAME_USER
	||  l[-1] == JOB_STACKFRAME_TMP_USER
	){
	    usr = l[-2];
	}
	l  = JOB_PREV_STACKFRAME(l);
    }
    *owner = usr;
    return l;
}
void
job_P_Get_Stackframe(
    void
) {
    Vm_Int normal = FALSE;
    Vm_Int vars   = 0;

    Vm_Int n   = OBJ_TO_INT( jS.s[-1] );
    Vm_Obj job =             jS.s[ 0]  ;
    Vm_Int c;

    job_Guarantee_N_Args(    2 );
    job_Guarantee_Job_Arg(   0 );
    job_Guarantee_Int_Arg(  -1 );

    c = count_stackframes( job );
    if (n < 0 || n >= c) MUQ_WARN ("invalid getStackframe[ index %d",(int)n);

    {   Vm_Int  slots;
        Vm_Obj  owner;
        Vm_Obj* s;
        Vm_Obj* l = find_nth_stackframe( &owner, job, c-(n+1) );
	Vm_Obj* m = JOB_PREV_STACKFRAME(l);
	Vm_Int  i = l-m;

	/* Push everything for owner, push */
	/* only owner for anyone else:     */
	if (jS.j.acting_user == owner
	||((jS.j.privs & JOB_PRIVS_OMNIPOTENT)
        &&  OBJ_IS_CLASS_ROT(jS.j.acting_user))
	){
	    /* Two output slots for every value */
	    /* in normal block plus two for     */
	    /* owner plus two for delimiters:   */
	    slots = i*2;

	    /* NORMAL   frames have a variable  */
	    /* count as well:                   */
	    if (l[-1]==JOB_STACKFRAME_NORMAL
	    /* HANDLERS frames have a handler   */
	    /* count as well:                   */
	    ||  l[-1]==JOB_STACKFRAME_HANDLERS
	    ){
		slots += 2;
	    }
	    job_Guarantee_Headroom( slots );
	    /* Above may have moved stuff, so: */
	    l = find_nth_stackframe( &owner, job, c-(n+1) );
	    m = JOB_PREV_STACKFRAME(l);
	} else {
	    slots = 4;
	    job_Guarantee_Headroom( slots );
	    s    = jS.s -2;
	    *++s = OBJ_BLOCK_START;
	    *++s = job_Kw_Owner;
	    *++s = owner;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    jS.s = s;
	    return;
	}

	/* Find stackframe again, may have moved: */
        l = find_nth_stackframe( &owner, job, c-(n+1) );
        m = JOB_PREV_STACKFRAME(l) + 2;
	s    = jS.s -2;
	*++s = OBJ_BLOCK_START;
	*++s = job_Kw_Owner;
	*++s = owner;
	*++s = job_Kw_Kind;
	switch (l[-1]) {

	case JOB_STACKFRAME_NULL:
	    *++s = OBJ_NIL;
	    *++s = OBJ_FROM_BLK( 4 );
	    jS.s = s;
	    return;

	case JOB_STACKFRAME_NORMAL:
	    normal = TRUE;
	    *++s = job_Kw_Normal;
	    *++s = job_Kw_Program_Counter;	*++s = *m++;
	    *++s = job_Kw_Compiled_Function;	*++s = *m++;
	    vars = i - 5;
	    {	Vm_Int j;
		*++s = job_Kw_Variables;
		*++s = OBJ_FROM_INT(vars);
		for (j = 0;   j < vars;   ++j) {
		    *++s = OBJ_FROM_INT(j);	*++s = *m++;
		}
	    }
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_EPHEMERAL_LIST:
	    *++s = job_Kw_Ephemeral_List;
/* buggo: This hasn't been written yet */
	    {   Vm_Int slots = i - 4;
	    	Vm_Int j;
		*++s = job_Kw_Slots;
		*++s = OBJ_FROM_INT(slots);
		for (j = 0;   j < slots;   ++j) {
		    *++s = OBJ_FROM_INT(j); *++s = *m++;
		}
	    }
	    /* Step over ephemeral linklist */
	    /* just for consistency:        */
	    ++m;
	    *++s = OBJ_FROM_BLK( slots-4 );
	    break;

	case JOB_STACKFRAME_EPHEMERAL_STRUCT:
	    *++s = job_Kw_Ephemeral_Struct;
	    *++s = job_Kw_Is_A;
	    *++s = *++m;
	    {   Vm_Int slots = i - 6;
	    	Vm_Int j;
		*++s = job_Kw_Slots;
		*++s = OBJ_FROM_INT(slots);
		for (j = 0;   j < slots;   ++j) {
		    *++s = OBJ_FROM_INT(j); *++s = *++m;
		}
	    }
	    m += 2;
	    *++s = OBJ_FROM_BLK( slots-4 );
	    break;

	case JOB_STACKFRAME_EPHEMERAL_VECTOR:
	    *++s = job_Kw_Ephemeral_Vector;
	    *++s = job_Kw_Is_A;
	    *++s = *++m;
	    {   Vm_Int slots = i - 6;
	    	Vm_Int j;
		*++s = job_Kw_Slots;
		*++s = OBJ_FROM_INT(slots);
		for (j = 0;   j < slots;   ++j) {
		    *++s = OBJ_FROM_INT(j); *++s = *++m;
		}
	    }
	    m += 2;
	    *++s = OBJ_FROM_BLK( slots-4 );
	    break;

	case JOB_STACKFRAME_FUN_BIND:
	    *++s = job_Kw_Function_Binding;
	    *++s = job_Kw_Symbol;		*++s = *m++;
	    *++s = job_Kw_Function;		*++s = *m++;
	    *++s = job_Kw_Stack_Depth;		*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_VAR_BIND:
	    *++s = job_Kw_Variable_Binding;
	    *++s = job_Kw_Symbol;		*++s = *m++;
	    *++s = job_Kw_Value;		*++s = *m++;
	    *++s = job_Kw_Stack_Depth;		*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_BUSY_HANDLERS:
	    MUQ_FATAL ("job_P_Get_Stackframe: internal err0");
	case JOB_STACKFRAME_HANDLERS:
	    *++s = job_Kw_Handlers;
	    {   /* Compute number of handlers in frame: */
		Vm_Int i;
		Vm_Int handlers = (slots-8) >> 2;
		*++s = job_Kw_Handlers;
		*++s = OBJ_FROM_INT(handlers);
		for (i = 0;   i < handlers;   ++i) {
		    *++s = OBJ_FROM_INT((i<<1)+0);	*++s = *m++;
		    *++s = OBJ_FROM_INT((i<<1)+1);	*++s = *m++;
	    }	}
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_CATCH:
	    *++s = job_Kw_Catch;
	    *++s = job_Kw_Program_Counter;	*++s = *m++;
	    *++s = job_Kw_Stack_Depth;		*++s = *m++;
	    *++s = job_Kw_Tag;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_PROTECT:
	    *++s = job_Kw_Protect;
	    *++s = job_Kw_Program_Counter;	*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_PROTECT_CHILD:
	    *++s = job_Kw_Protect_Child;
	    *++s = job_Kw_Program_Counter;	*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_THROW:
	    *++s = job_Kw_Throw;
	    *++s = job_Kw_Tag;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_ENDJOB:
	    *++s = job_Kw_End_Job;
	    *++s = job_Kw_Junk;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_EXEC:
	    *++s = job_Kw_Exec;
	    *++s = job_Kw_Junk;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_RETURN:
	    *++s = job_Kw_Return;
	    *++s = job_Kw_Junk;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_JUMP:
	    *++s = job_Kw_Jump;
	    *++s = job_Kw_Program_Counter;	*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_VANILLA:
	    *++s = job_Kw_Vanilla;
	    *++s = job_Kw_Junk;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_THUNK:
	    *++s = job_Kw_Thunk;
	    *++s = job_Kw_Privileges;		*++s = *m++;
	    *++s = job_Kw_Acting_User;		*++s = *m++;
	    *++s = job_Kw_Actual_User;		*++s = *m++;
	    *++s = job_Kw_Stack_Bottom;		*++s = *m++;
	    *++s = job_Kw_Return_Slot;		*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_SIGNAL:
	    *++s = job_Kw_Signal;
	    *++s = job_Kw_Privileges;		*++s = *m++;
	    *++s = job_Kw_Acting_User;		*++s = *m++;
	    *++s = job_Kw_Stack_Depth;		*++s = *m++;
	    *++s = job_Kw_Job_Queue;		*++s = *m++;
	    *++s = job_Kw_Blocked_Signals;	*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_LOCK:
	    *++s = job_Kw_Lock;
	    *++s = job_Kw_Lock;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_LOCK_CHILD:
	    *++s = job_Kw_Lock_Child;
	    *++s = job_Kw_Lock;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_USER:
	    *++s = job_Kw_User;
	    *++s = job_Kw_Acting_User;		*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_TMP_USER:
	    *++s = job_Kw_Tmp_User;
	    *++s = job_Kw_Acting_User;		*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_PRIVS:
	    *++s = job_Kw_Privileges;
	    *++s = job_Kw_Privileges;		*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_TAG:
	    *++s = job_Kw_Tag;
	    *++s = job_Kw_Program_Counter;	*++s = *m++;
	    *++s = job_Kw_Tag;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_GOTO:
	    *++s = job_Kw_Goto;
	    *++s = job_Kw_Tag;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_TAGTOP:
	    *++s = job_Kw_Tagtop;
	    *++s = job_Kw_Stack_Depth;		*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_RESTART:
	    *++s = job_Kw_Restart;
	    *++s = job_Kw_Data;			*++s = *m++;
	    *++s = job_Kw_Report_Function;	*++s = *m++;
	    *++s = job_Kw_Interactive_Function;	*++s = *m++;
	    *++s = job_Kw_Test_Function;	*++s = *m++;
	    *++s = job_Kw_Function;		*++s = *m++;
	    *++s = job_Kw_Name;			*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	case JOB_STACKFRAME_HANDLING:
	    *++s = job_Kw_Handling;
	    *++s = job_Kw_Stack_Depth;		*++s = *m++;
	    *++s = OBJ_FROM_BLK( slots-2 );
	    break;

	default:
	    MUQ_FATAL ("job_P_Get_Stackframe: internal err1");
	}
	jS.s = s;
	#if MUQ_IS_PARANOID
	if (m+1 != l) {
	    MUQ_FATAL ("job_P_Get_Stackframe: internal err2");
	}
	#endif	

	if (normal) {
	    /* Program counter is saved relative to   */
	    /* constants pointer, for efficiency in   */
	    /* call/return, but this is confusing     */
	    /* to the user: Subtract bytes of const   */
	    /* data from it to produce a value with   */
	    /* zero as the pc for the 1st codebyte.   */

	    /* At this point, we have:                */
            /* 1 jS.s[ -2n -6 ] -> :programCounter   */
            /* 2 jS.s[ -2n -5 ] ->      pc            */
            /* 3 jS.s[ -2n -4 ] -> :compiledFunction */
            /* 4 jS.s[ -2n -3 ] ->      cfn           */
            /* 5 jS.s[ -2n -2 ] -> :variables         */
            /* 6 jS.s[ -2n -1 ] ->      count         */
            /*          ...           ...             */
            /* jS.s[     -2 ] ->      n-1             */
            /* jS.s[     -1 ] ->  val n-1             */
            /* jS.s[      0 ] ->  BLK                 */
	    Vm_Int org = -(2*vars+7);

	    #if MUQ_IS_PARANOID
	    if (jS.s[ org+1 ] != job_Kw_Program_Counter) {
		MUQ_FATAL ("job_P_Get_Stackframe: internal err3");
	    }
	    #endif	
	    jS.s[org+2] = OBJ_FROM_INT(
		OBJ_TO_INT(jS.s[org+2]) -
		CFN_CONSTS( CFN_P(jS.s[org+4])->bitbag ) * sizeof(Vm_Obj)
	    );
	}
    }
}


 /***********************************************************************/
 /*-    job_P_Set_Local_Vars -- ]setLocalVars				*/
 /***********************************************************************/

void
job_P_Set_Local_Vars(
    void
) {
    Vm_Int b = OBJ_TO_BLK( jS.s[ 0] );

    /* Sanity checks: */
    job_Guarantee_Blk_Arg(  0 );
    job_Guarantee_N_Args( b+2 );

    /* Check that we're not trying to set */
    /* more local variables than exist:   */
    {   /* Count number of local variables: */

        /* Find bottom of stackframe: */
        Vm_Obj* loc = jS.v - 3;

	/* Find first word past stackframe: */
	Vm_Int  stackframe_size_in_bytes = (Vm_Int)(*loc);
	Vm_Obj* lim = (Vm_Obj*)(((Vm_Uch*)loc)+stackframe_size_in_bytes);


	if (b > ((lim-jS.v)-2)) MUQ_WARN ("Not enough local vars!");
    }
    {   register Vm_Obj* src = jS.s - b;
        register Vm_Obj* dst = jS.v;
	register Vm_Int  i   = b;
	
	while (i >= 8) {
	    *dst++ = *src++;
	    *dst++ = *src++;
	    *dst++ = *src++;
	    *dst++ = *src++;

	    *dst++ = *src++;
	    *dst++ = *src++;
	    *dst++ = *src++;
	    *dst++ = *src++;

	    i -= 8;
	}
	while (i) {
	    *dst++ = *src++;
	    --i;
	}
    }

    /* Adjust stack depth: */
    jS.s -= b+2;
}

 /***********************************************************************/
 /*-    job_P_End_Job -- Terminate current thread.			*/
 /***********************************************************************/

void
job_P_End_Job(
    void
) {
    /* Require one argument.  Intended   */
    /* to be used similar to unix exit() */
    /* value, currently ignored:         */
    job_Guarantee_N_Args(  1 );

    /* Save given argument for possible  */
    /* later diagnostic inspection:      */
    JOB_P(jS.job)->end_job = *jS.s;
    vm_Dirty(jS.job);

    /* Overwrite stacktop with an empty  */
    /* stackblock for throw():           */
    *jS.s++ = OBJ_BLOCK_START;
    *jS.s   = OBJ_FROM_BLK(0);

    /* Execute all pending after{}always_do{}s: */
    throw( OBJ_NOT_FOUND, JOB_ENDJOB );

    /* Above will sometimes return, but */
    /* no further work will be needed.  */
}

 /***********************************************************************/
 /*-    job_P_Switch_Job -- Terminate current timeslice.		*/
 /***********************************************************************/

void
job_P_Switch_Job(
    void
) {
    /* Advance program counter to next instruction, */
    /* so we resume there rather than re-executing  */
    /* switchJob when we wake:                     */
    jS.pc             += jS.instruction_len;
    jS.instruction_len = 0; /* Probably not needed. */

    job_End_Timeslice();
}

 /***********************************************************************/
 /*-    job_P_Exec -- Like unix "exec"					*/
 /***********************************************************************/

void
job_P_Exec(
    void
) {
    Vm_Obj o = *jS.s;
    if (OBJ_IS_SYMBOL(o))   o = job_Symbol_Function(o);
    if (!OBJ_IS_CFN(o)) {
        MUQ_WARN ("Needed symbol or c-fn.");
    }

    /* The idea of random thunks or whatever doing */
    /* an exec makes me uncomfortable.  Let's keep */
    /* it to the owner of the job for now:         */
    if (jS.j.acting_user != jS.j.actual_user
    && (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    ||  !OBJ_IS_CLASS_ROT(jS.j.acting_user))
    ){
        MUQ_WARN ("Must control job to do 'exec'.");
    }

    /* Guarantee valid argblock: */
    {   Vm_Int size = OBJ_TO_BLK( jS.s[-1] );
	job_Guarantee_Blk_Arg( -1 );
	job_Guarantee_N_Args( size+3 );
    }

    /* Pop object-to-exec: */
    --jS.s;

    /* Save 'o' where we can find it:    */
    JOB_P(jS.job)->end_job = o;
    vm_Dirty(jS.job);

    /* Execute all pending after{}always_do{}s: */
    throw( OBJ_NOT_FOUND, JOB_EXEC );

    /********************************************/
    /* Above may or may not return; Either way, */
    /* throw() has taken care of calling our    */
    /* job_finish_exec() second half for us.    */
    /********************************************/
}
static void
job_finish_exec(
    void
) {
    /* Recover 'o' and restore end_job field: */
    Vm_Obj o = JOB_P(jS.job)->end_job;
    JOB_P(jS.job)->end_job = OBJ_FROM_INT(0);
    vm_Dirty(jS.job);

    /* Repeat check just to be safe: */
    if (!OBJ_IS_CFN(o)) {
        MUQ_WARN ("Needed symbol or c-fn.");
    }

    /* Uncomment for a handy debugging trace: */
    #ifndef MUQ_TRACE
    if (job_Log_Bytecodes /*= (++job_Bytecodes_Logged>JOB_TRACE_BYTECODES_FROM)*/) {
        Vm_Obj src = CFN_P(o)->src;
	if (OBJ_IS_OBJ(src) && OBJ_IS_CLASS_FN(src)) {
	    Vm_Obj nam = FUN_P(src)->o.objname;
	    if (stg_Is_Stg(nam)) {
		Vm_Int len = stg_Len(nam);
		if (len < 200) {
		    Vm_Uch buf [ 256 ];
		    Vm_Uch buf2[ 256 ];
		    if (len == stg_Get_Bytes( buf, len, nam, 0 )) {
			buf[len] = '\0';
			sprintf(buf2,"EXECing '%s'...\n",buf);
			lib_Log_String(buf2);
    }	}   }   }   }
    #endif

    /* Copy argblock to bottom of datastack: */
    {
	/* Locate data stack top: */
	Vm_Obj* os = jS.s_bot;
	Vm_Obj*  s = jS.s;
	Vm_Unt   i= OBJ_TO_BLK(*jS.s)+2;	/* Slots in block */

        /* Insure against bad block size -- should */
	/* not be possible, but one never knows:   */
	if (jS.s_bot + i < s+1) {

	    /* Copy return block to correct spot: */
	    s -= i;/* One below bottom of return block. */
	    while (i --> 0) *++os = *++s;

	    /* Remember new datastack top-of-stack: */
	    jS.s = os;
	}
    }

    /* Clear loop stack to empty: */
    jS.j.ephemeral_lists   = OBJ_FROM_INT(0);
    jS.j.ephemeral_objects = OBJ_FROM_INT(0);
    jS.j.ephemeral_structs = OBJ_FROM_INT(0);
    jS.j.ephemeral_vectors = OBJ_FROM_INT(0);
    jS.j.function_bindings = OBJ_FROM_INT(0);
    jS.j.variable_bindings = OBJ_FROM_INT(0);

    /* Push same initial stackframe pushed by for_new(): */
    jS.l = jS.l_bot + (JOB_DUMMY_ENTRIES_AT_BOTTOM_OF_LOOP_STACK-1);
    jS.l[ 0] = 5*sizeof(Vm_Obj);      /* Size-in-bytes of frame.   */
    jS.l[-1] = JOB_STACKFRAME_NORMAL; /* Stackframe type.          */
    jS.l[-2] = obj_Etc_Bad;           /* Dummy x_obj entry.        */
    jS.l[-3] = OBJ_FROM_INT(0);       /* Dummy pc    entry.        */
    jS.l[-4] = 5*sizeof(Vm_Obj);      /* Size-in-bytes of frame.   */
    jS.l[-5] = OBJ_FROM_INT( 0);      /* Bottom-of-stack sentinel. */

    /* Clear variable base pointer to reasonable value: */
    jS.v = jS.l -1;

    /* Hacks to neutralize job-call2()'s code to */
    /* save x_obj and pc, which make no sense in */
    /* an EXEC:                                  */
    jS.pc              = (Vm_Uch*)jS.k;
    jS.instruction_len = 0;
    jS.x_obj           = jS.v[-1];

    /* Execute call to given function: */
    job_Call2(o);
}

 /***********************************************************************/
 /*-    job_P_Call --							*/
 /***********************************************************************/

void
job_P_Call(
    void
) {
    job_Guarantee_N_Args( 1 );
    job_Call( *jS.s );
    --jS.s;
}
 /***********************************************************************/
 /*-    job_P_Make_Structure -- 					*/
 /***********************************************************************/

void
job_P_Make_Structure(
    void
) {
    /* Note that this function cannot be written in-db    */
    /* if it is to be able to allocate ephemeral structs  */
    /* for the currently executing function -- an in-db   */
    /* function would allocate them in its own stackframe */
    /* and pop them when returning.  We do, however, use  */
    /* an in-db function to evaluate initforms.           */
    Vm_Unt slots;
    Vm_Obj initform[ KEY_MAX_SLOTS ]; 
    Vm_Int ephemeral = FALSE;
    Vm_Obj vec;
    Vm_Obj key =             jS.s[  0 ]  ;
    Vm_Int len = OBJ_TO_BLK( jS.s[ -1 ] );

    if (OBJ_IS_SYMBOL(key))                        key = sym_Type(key);
    if (OBJ_IS_OBJ(key) && OBJ_IS_CLASS_CDF(key))  key = CDF_P(key)->key;
    if (!OBJ_IS_OBJ(key) || !OBJ_IS_CLASS_KEY(key)) {
	job_Guarantee_Key_Arg( 0 );
    }
    job_Guarantee_Blk_Arg( -1   );
    job_Guarantee_N_Args( len+3 );
    if (len & 1) {
	MUQ_WARN ("]makeStructure argblock length must be even.");
    }

    /* If first argument in block is :ephemeral   */
    /* and second is not NIL, create an ephemeral */
    /* (stack-allocated) structure, otherwise     */
    /* create a vanilla (heap-allocated) one:     */
    if (len
    &&  jS.s[ -1-len ] == job_Kw_Ephemeral
    &&  jS.s[   -len ] != OBJ_NIL
    ){
	ephemeral = TRUE;
    }

    /* Make a note of all :initform initializers. */
    /* These will need to be executed later at the*/
    /* muf level, unless the user has provided an */
    /* explicit value for the slot:               */
    {   Key_P  k = KEY_P(key);
	Vm_Unt u;
	if (k->abstract != OBJ_NIL) {
	    MUQ_WARN("May not create instance of abstract class.");
	}
	slots    = OBJ_TO_UNT( k->unshared_slots );
	for (u = 0;   u < slots;   ++u)   initform[u] = k->slot[u].initform;
    }

    /* Create new structure: */
    if (ephemeral) {
        /* Locate both struct and structDef: */
	Vm_Int arg;
	Vm_Int vlen;
	Est_P s;
	Key_P d;
	Key_Sym sa;	/* symbol array */
	vec = job_make_ephemeral_struct( key );
	d = vm_Loc( key );
	s = EST_P(&vlen,vec); /* Guaranteed not to invalidate 'd'. */
	slots = OBJ_TO_UNT( d->unshared_slots );
	sa    = (Key_Sym)(((Vm_Obj*)d) + OBJ_TO_INT(d->sym_loc));
	for (arg = 2;   arg < len;   arg += 2) {

	    /* Find offset of key/val pair on stack: */
	    Vm_Int k = arg-(len+1);
	    Vm_Int v = k+1;

	    /* Fetch key/val pair proper: */
	    Vm_Obj sym = jS.s[ k ];
	    Vm_Obj val = jS.s[ v ];

	    /* Find key in structure definition: */
	    Vm_Unt slot;
	    for (slot = 0;   /* slot < slots */;   ++slot) {
		if (slot == slots) {
		    MUQ_WARN ("Invalid ]makeStructure keyword");
		}
		if (sa[slot].symbol == sym) break;
	    }

	    s->slot[ slot] = val;
	    initform[slot] = OBJ_NIL;	/* Don't eval this slot's initform */
	}
	if (d->created_an_instance == OBJ_NIL) {
	    d->created_an_instance  = OBJ_T;   vm_Dirty(key);
	}
    } else {

        /* Locate both struct and struct-key: */
	Vm_Int arg;
	Stc_P s;
	Key_P d;
	Key_Sym sa;	/* symbol array */
        vec = stc_Alloc(                 key );
	vm_Loc2( (void**)&s, (void**)&d, vec, key );
	slots = OBJ_TO_UNT( d->unshared_slots );
	sa    = (Key_Sym)(((Vm_Obj*)d) + OBJ_TO_INT(d->sym_loc));
	for (arg = 0;   arg < len;   arg += 2) {

	    /* Find offset of key/val pair on stack: */
	    Vm_Int k = arg-(len+1);
	    Vm_Int v = k+1;

	    /* Fetch key/val pair proper: */
	    Vm_Obj sym = jS.s[ k ];
	    Vm_Obj val = jS.s[ v ];

	    /* Find key in structure definition: */
	    Vm_Unt slot;
	    for (slot = 0;   slot < slots;   ++slot) {
		if (sa[slot].symbol == sym) break;
	    }
	    if (sa[slot].symbol != sym) {
		if (sym == job_Kw_Ephemeral)   continue;
		MUQ_WARN ("Invalid ]makeStructure keyword");
	    }

	    s->slot[ slot] = val;
	    initform[slot] = OBJ_NIL;	/* Don't eval this slot's initform */
	}
	if (d->created_an_instance == OBJ_NIL) {
	    d->created_an_instance  = OBJ_T;   vm_Dirty(key);
	}
	vm_Dirty( vec );
    }	

    /* If there are any initforms which need  */
    /* evaluating, we need to fire up our muf */
    /* support fn ]doStructureInitforms:    */
    {   Vm_Int slot;
	Vm_Int blk = 0;
	for (slot = slots;   slot --> 0;   ) {
	    if (initform[slot] != OBJ_NIL)  blk += 2;
	}

	if (!blk) {
	    /* No initforms -- just  */
            /* return new structure: */
	    jS.s -= len+2;
	   *jS.s  = vec;
	    return;
	}

	/* Locate ]doStructureInitforms fn: */
        {   Vm_Obj sym  = obj_Lib_Muf_Do_Structure_Initforms;
	    Vm_Obj cfn  = SYM_P(sym)->function;
	    if (!OBJ_IS_CFN(cfn)) MUQ_WARN("]doStructureInitforms missing");

	    /* Push argument block: */
	    if (blk >= len)   job_Guarantee_Headroom( blk+1-len );
	    jS.s -= len+3;
	    *++jS.s = OBJ_BLOCK_START;
	    {   Vm_Int slot;
		for (slot = 0;   slot < slots;   ++slot) {
		    if (initform[slot] != OBJ_NIL) {
			*++jS.s = OBJ_FROM_INT(slot);
			*++jS.s = initform[    slot];
		    }
		}
		*++jS.s = OBJ_FROM_BLK( blk );
	    }
	    *++jS.s  = KEY_P(key)->mos_class;
	    *++jS.s  = vec;

	    /* Call ]doStructureInitforms: */
	    job_Call2(cfn);
	}
    }
}


void job_P_Muqnet_Del_Key(   void){MUQ_WARN("muqnetDelKey unimplemented");}
void job_P_Muqnet_Del_Key_P( void){MUQ_WARN("muqnet-del-key-p unimplemented");}
void job_P_Muqnet_Get_Key_P( void){MUQ_WARN("muqnet-get-key-p unimplemented");}
void job_P_Muqnet_Get_First_Key(void){MUQ_WARN("muqnetGetFirstKey? unimplemented");}
void job_P_Muqnet_Get_Keys_By_Prefix(void){MUQ_WARN("muqnet-get-keys-by-prefix unimplemented");}
void job_P_Muqnet_Get_Next_Key(void){MUQ_WARN("muqnetGetNextKey? unimplemented");}
void job_P_Muqnet_Get_Val(void){MUQ_WARN("muqnet-get-val unimplemented");}
void
job_P_Muqnet_Get_Val_P(
    void
){
    job_Guarantee_N_Args( 3 );
    /* 'key' can be absolutely anything. */
    /* 'obj' can now be absolutely anything also. */

    {	Vm_Obj dir    = jS.s[ 0];
	Vm_Obj key    = jS.s[-1];
	Vm_Obj obj    = jS.s[-2];
	Vm_Int typ    = OBJ_TYPE(obj);
	Vm_Unt propdir= OBJ_TO_UNT(dir);
        Vm_Obj us     = jS.j.acting_user;
        Vm_Obj result;

	if (!OBJ_IS_INT(dir)
	||  propdir >= OBJ_PROP_MAX
	){
	    --jS.s;
	    jS.s[ -1 ] = OBJ_NIL;
	    jS.s[  0 ] = OBJ_NIL;
	}

	/* Buggo?  If any of the for_get fns have MUQ_WARN  */
	/* calls, this could leave us running as obj_U_Nul. */
	/* We need to switch to obj_U_Nul to avoid remote   */
	/* users reading props with excessive privileges:   */
	jS.j.acting_user = obj_U_Nul;
	result = (*mod_Type_Summary[ typ ]->for_get)( obj, key, propdir );
	jS.j.acting_user = us;
	--jS.s;
	jS.s[ -1 ] = OBJ_FROM_BOOL( result != OBJ_NOT_FOUND );
	jS.s[  0 ] = (result == OBJ_NOT_FOUND) ? OBJ_NIL : result;
    }
}
void job_P_Muqnet_Keysvals_Block(void){MUQ_WARN("muqnet-keysvals-block unimplemented");}
void job_P_Muqnet_Keys_Block(void){MUQ_WARN("muqnet-keys-block unimplemented");}
void job_P_Muqnet_Set_From_Block(void){MUQ_WARN("muqnet-set-from-block unimplemented");}
void job_P_Muqnet_Set_From_Keysvals_Block(void){MUQ_WARN("muqnet-set-from-keysvals-block unimplemented");}
void job_P_Muqnet_Set_Val(void){MUQ_WARN("muqnet-set-val unimplemented");}
void job_P_Muqnet_Vals_Block(void){MUQ_WARN("muqnet-vals-block unimplemented");}

#undef  P
#define P OBJ_PROP_PUBLIC
#undef  O
#define O job_Must_Control(0)
#undef  I
#define I job_Must_Control(-1)
#undef  o
#define o job_Must_Scry(0)
#undef  i
#define i job_Must_Scry(-1)
#undef  R
#define R job_Must_Be_Root()
void job_P_Public_Del_Key(           void){I;job_x_p_del_key(           P);}
void job_P_Public_Del_Key_P(         void){I;job_x_p_del_key_p(         P);}
void job_P_Public_Get_Key_P(         void){  job_x_p_get_key_p(         P);}
void job_P_Public_Get_First_Key(     void){  job_x_p_get_first_key(     P);}
void job_P_Public_Get_Keys_By_Prefix(void){  job_x_p_get_keys_by_prefix(P);}
void job_P_Public_Get_Next_Key(      void){  job_x_p_get_next_key(      P);}
void job_P_Public_Get_Val(           void){  job_x_p_get_val(           P);}
void job_P_Public_Get_Val_P(         void){  job_x_p_get_val_p(         P);}
void job_P_Public_Keysvals_Block(    void){  job_x_p_keysvals_block(    P);}
void job_P_Public_Keys_Block(        void){  job_x_p_keys_block(        P);}
void job_P_Public_Set_From_Block(    void){  job_x_p_set_from_block(    P);}
void job_P_Public_Set_From_Keysvals_Block(void){job_x_p_set_from_keysvals_block(P);}
void job_P_Public_Set_Val(           void){I;job_x_p_set_val(           P);}
/*void job_P_Public_Set_Vals_Block(  void){  job_x_p_set_vals_block(    P);}*/
void job_P_Public_Vals_Block(        void){  job_x_p_vals_block(        P);}

#undef P
#define P OBJ_PROP_HIDDEN
void job_P_Hidden_Del_Key(           void){I;job_x_p_del_key(           P);}
void job_P_Hidden_Del_Key_P(         void){I;job_x_p_del_key_p(         P);}
void job_P_Hidden_Get_Key_P(         void){i;job_x_p_get_key_p(         P);}
void job_P_Hidden_Get_First_Key(     void){o;job_x_p_get_first_key(     P);}
void job_P_Hidden_Get_Keys_By_Prefix(void){i;job_x_p_get_keys_by_prefix(P);}
void job_P_Hidden_Get_Next_Key(      void){i;job_x_p_get_next_key(      P);}
void job_P_Hidden_Get_Val(           void){i;job_x_p_get_val(           P);}
void job_P_Hidden_Get_Val_P(         void){i;job_x_p_get_val_p(         P);}
void job_P_Hidden_Keysvals_Block(    void){o;job_x_p_keysvals_block(    P);}
void job_P_Hidden_Keys_Block(        void){o;job_x_p_keys_block(        P);}
void job_P_Hidden_Set_From_Block(    void){  job_x_p_set_from_block(    P);}
void job_P_Hidden_Set_From_Keysvals_Block(void){job_x_p_set_from_keysvals_block(P);}
void job_P_Hidden_Set_Val(           void){I;job_x_p_set_val(            P);}
/*void job_P_Hidden_Set_Vals_Block(     void){job_x_p_set_vals_block(     P);}*/
void job_P_Hidden_Vals_Block(        void){o;job_x_p_vals_block(         P);}


#undef P
#define P OBJ_PROP_SYSTEM
/* buggo, need to devise some protection for random */
/* values here while still allowing (e.g.) breakEnable to be set. */
void job_P_System_Del_Key(           void){  job_x_p_del_key(           P);}
void job_P_System_Del_Key_P(         void){  job_x_p_del_key_p(         P);}
void job_P_System_Get_Key_P(         void){  job_x_p_get_key_p(         P);}
void job_P_System_Get_First_Key(     void){  job_x_p_get_first_key(     P);}
void job_P_System_Get_Keys_By_Prefix(void){  job_x_p_get_keys_by_prefix(P);}
void job_P_System_Get_Next_Key(      void){  job_x_p_get_next_key(      P);}
void job_P_System_Get_Val(           void){  job_x_p_get_val(           P);}
void job_P_System_Get_Val_P(         void){  job_x_p_get_val_p(         P);}
void job_P_System_Keysvals_Block(    void){  job_x_p_keysvals_block(    P);}
void job_P_System_Keys_Block(        void){  job_x_p_keys_block(        P);}
void job_P_System_Set_From_Block(    void){  job_x_p_set_from_block(    P);}
void job_P_System_Set_From_Keysvals_Block(void){job_x_p_set_from_keysvals_block(P);}
void job_P_System_Set_Val(           void){  job_x_p_set_val(            P);}
/*void job_P_System_Set_Vals_Block(     void){job_x_p_set_vals_block(     P);}*/
void job_P_System_Vals_Block(        void){  job_x_p_vals_block(         P);}


#undef P
#define P OBJ_PROP_ADMINS
void job_P_Admins_Del_Key(           void){R;job_x_p_del_key(           P);}
void job_P_Admins_Del_Key_P(         void){R;job_x_p_del_key_p(         P);}
void job_P_Admins_Get_Key_P(         void){R;job_x_p_get_key_p(         P);}
void job_P_Admins_Get_First_Key(     void){R;job_x_p_get_first_key(     P);}
void job_P_Admins_Get_Keys_By_Prefix(void){R;job_x_p_get_keys_by_prefix(P);}
void job_P_Admins_Get_Next_Key(      void){R;job_x_p_get_next_key(      P);}
void job_P_Admins_Get_Val(           void){R;job_x_p_get_val(           P);}
void job_P_Admins_Get_Val_P(         void){R;job_x_p_get_val_p(         P);}
void job_P_Admins_Keysvals_Block(    void){R;job_x_p_keysvals_block(    P);}
void job_P_Admins_Keys_Block(        void){R;job_x_p_keys_block(        P);}
void job_P_Admins_Set_From_Block(    void){R;job_x_p_set_from_block(    P);}
void job_P_Admins_Set_From_Keysvals_Block(void){job_x_p_set_from_keysvals_block(P);}
void job_P_Admins_Set_Val(           void){R;job_x_p_set_val(            P);}
/*void job_P_Admins_Set_Vals_Block(  void){R;job_x_p_set_vals_block(     P);}*/
void job_P_Admins_Vals_Block(        void){R;job_x_p_vals_block(         P);}


#ifdef OLD
#undef P
#define P OBJ_PROP_METHOD
void job_P_Method_Del_Key(           void){I;job_x_p_del_key(           P);}
void job_P_Method_Del_Key_P(         void){I;job_x_p_del_key_p(         P);}
void job_P_Method_Get_Key_P(         void){  job_x_p_get_key_p(         P);}
void job_P_Method_Get_First_Key(     void){  job_x_p_get_first_key(     P);}
void job_P_Method_Get_Keys_By_Prefix(void){  job_x_p_get_keys_by_prefix(P);}
void job_P_Method_Get_Next_Key(      void){  job_x_p_get_next_key(      P);}
void job_P_Method_Get_Val(           void){  job_x_p_get_val(           P);}
void job_P_Method_Get_Val_P(         void){  job_x_p_get_val_p(         P);}
void job_P_Method_Keysvals_Block(    void){  job_x_p_keysvals_block(    P);}
void job_P_Method_Keys_Block(        void){  job_x_p_keys_block(        P);}
void job_P_Method_Set_From_Block(    void){  job_x_p_set_from_block(    P);}
void job_P_Method_Set_From_Keysvals_Block(void){job_x_p_set_from_keysvals_block(P);}
void job_P_Method_Set_Val(           void){I;job_x_p_set_val(           P);}
/*void job_P_Method_Set_Vals_Block(  void){  job_x_p_set_vals_block(    P);}*/
void job_P_Method_Vals_Block(        void){  job_x_p_vals_block(        P);}
#endif

#undef P
#undef O
#undef I
#undef o
#undef i
#undef R

 /***********************************************************************/
 /*-    job_x_p_del_key -- ( o key -> )					*/
 /***********************************************************************/

static void
job_x_p_del_key(
    Vm_Int propdir
) {
    job_Guarantee_N_Args(  2 );
    /* 'key' can be absolutely anything. */
    /* 'obj' can now be absolutely anything also. */

    {   Vm_Obj key    = jS.s[ 0];
	Vm_Obj obj    = jS.s[-1];
	Vm_Int typ    = OBJ_TYPE(obj);

	/* Support for transparent networking: */
        if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Del_Key)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
	}   }

	(*mod_Type_Summary[ typ ]->for_del)( obj, key, propdir );
        jS.s -= 2;
    }
}

 /***********************************************************************/
 /*-    job_x_p_del_key_p -- ( o val -> success val )			*/
 /***********************************************************************/

static void
job_x_p_del_key_p(
    Vm_Int propdir
) {
    job_Guarantee_N_Args(  2 );
    /* 'key' can be absolutely anything. */
    /* 'obj' can now be absolutely anything also. */

    {   Vm_Obj key    = jS.s[ 0];
	Vm_Obj obj    = jS.s[-1];
	Vm_Int typ    = OBJ_TYPE(obj);
        Vm_Obj result;

	/* Support for transparent networking: */
        if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Del_Key_P)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
	}   }

	result = (*mod_Type_Summary[ typ ]->for_del)( obj, key, propdir );
	if  (result == OBJ_NOT_FOUND) {
	    jS.s[-1] = OBJ_NIL;
	    jS.s[ 0] = OBJ_NIL;
	} else {       
	    jS.s[-1] = OBJ_TRUE;
	    jS.s[ 0] = result;
	}
    }
}

 /***********************************************************************/
 /*-    job_x_p_get_key_p -- ( o val -> success key )			*/
 /***********************************************************************/

static void
job_x_p_get_key_p(
    Vm_Int propdir
) {
    Vm_Obj v = jS.s[  0 ];
    Vm_Obj o = jS.s[ -1 ];
    job_Guarantee_N_Args(  2 );

    if (OBJ_IS_VEC(o)) {
	Vm_Int loc =                        0  ;
	Vm_Int suc = vec_Get_Key_P(&loc, o, v );
	jS.s[  0 ] = OBJ_FROM_UNT(        loc );
	jS.s[ -1 ] = OBJ_FROM_BOOL(       suc );
	return;
    }

    if (OBJ_IS_EPHEMERAL_VECTOR(o)) {
	Vm_Int loc =                        0  ;
	Vm_Int suc = evc_Get_Key_P(&loc, o, v );
	jS.s[  0 ] = OBJ_FROM_UNT(        loc );
	jS.s[ -1 ] = OBJ_FROM_BOOL(       suc );
	return;
    }

    if (OBJ_IS_OBJ(o)) {

	if (OBJ_IS_CLASS_STK(o)) {
	    Vm_Int loc =                        0  ;
	    Vm_Int suc = stk_Get_Key_P(&loc, o, v );
	    jS.s[  0 ] = OBJ_FROM_UNT(        loc );
	    jS.s[ -1 ] = OBJ_FROM_BOOL(       suc );
	    return;
	}

	/* Support for transparent networking: */
        if (OBJ_IS_CLASS_PRX(o)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Get_Key_P)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
    }	}   }

    MUQ_WARN ("getKey??: Don't know how to search that.");
}

 /***********************************************************************/
 /*-    job_x_p_get_first_key -- ( obj -- key success )			*/
 /***********************************************************************/

static void
job_x_p_get_first_key(
    Vm_Int propdir
) {
    job_Guarantee_N_Args( 1 );
    /* 'obj' can be absolutely anything. */

    {   Vm_Obj obj    = jS.s[0];
	Vm_Int typ    = OBJ_TYPE(obj);
	Vm_Obj key    = OBJ_FIRST;

	/* Support for transparent networking: */
        if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Get_First_Key)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
	}   }

	key = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir );
	/* Note that OBJ_NOT_FOUND should never be handed to user: */
	++jS.s;
	if (key == OBJ_NOT_FOUND) { jS.s[-1]=OBJ_NIL; jS.s[0]=OBJ_NIL; }
	else                      { jS.s[-1]=OBJ_TRUE ; jS.s[0]=key      ; }
    }
}

 /***********************************************************************/
 /*-    job_x_p_get_keys_by_prefix -- ( obj prefix -- keyblock )	*/
 /***********************************************************************/

/********************************************************/
/* This prim is designed to support user shells which   */
/* allow abbreviation of commands to any unique prefix, */
/* and such.  It returns all keys in the given object   */
/* which begin with the given prefix, and returns them  */
/* in a block.  Shells getting multiple return values   */
/* may just say "Huh?" in time-honored fashion, or may  */
/* list the different alternatives available.           */
/********************************************************/

#undef  MAX_KEY
#define MAX_KEY 8192
static void
job_x_p_get_keys_by_prefix(
    Vm_Int propdir
) {

    job_Guarantee_N_Args(      2 );
    job_Guarantee_Stg_Arg(     0 );
    job_Guarantee_Object_Arg( -1 ); /* 'obj' must have a propdir. */

    {   /* Fetch our arguments, copy prefix into asciz buf: */
	Vm_Obj obj = jS.s[ -1 ];
	Vm_Obj key = jS.s[  0 ];

	/* Support for transparent networking: */
        if (OBJ_IS_CLASS_PRX(obj)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Get_Keys_By_Prefix)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
	}   }

	/* If obj has a key exact matching prefix, */
	/* we return it as a length-one block:     */
	{   Vm_Obj result = OBJ_GET( obj, key, propdir );
	    if (result != OBJ_NOT_FOUND) {
		jS.s[ -1 ] = OBJ_BLOCK_START;
		jS.s[  0 ] = key;
		jS.s[  1 ] = OBJ_FROM_BLK(1);
		jS.s++;
		return;
	}   }

	/* Build up and return a block of   */
	/* all keys with 'key' as a prefix: */
	{   Vm_Uch prebuf[ MAX_KEY ];
	    Vm_Uch keybuf[ MAX_KEY ];
	    Vm_Int num = 0;
	    Vm_Int len = stg_Get_Bytes( prebuf, MAX_KEY, key, 0 );
	    if (len == MAX_KEY)   MUQ_WARN ("Prefix too long!");
	    prebuf[ len ] = '\0';

	    /* Initialize return value on stack to empty block: */
	    jS.s[-1] = OBJ_BLOCK_START;
	    jS.s[ 0] = OBJ_FROM_BLK(0);

	    /* Cycle over keys potentially matching our prefix: */
	    for (;;) {

		/* Done if no more keys in 'obj': */
		key = OBJ_NEXT( obj, key, propdir );
		if (key == OBJ_NOT_FOUND)   return;

		/* Done if 'prebuf' isn't a prefix of 'key': */
		{   Vm_Int klen = stg_Get_Bytes( keybuf, MAX_KEY, key, 0 );
		    if (klen == MAX_KEY)   MUQ_WARN ("Key too long!");
		    if (klen < len)   return;
		}
		if (memcmp( prebuf, keybuf, len ))   return;

		/* Add key to our return block: */
		job_Guarantee_Headroom( 1 );
		*++jS.s  = OBJ_FROM_BLK( ++num );
		jS.s[-1] = key;
    }	}   }
}

 /***********************************************************************/
 /*-    job_x_p_get_next_key -- ( obj key -- success key )		*/
 /***********************************************************************/

static void
job_x_p_get_next_key(
    Vm_Int propdir
) {
    job_Guarantee_N_Args( 2 );
    /* 'key' can be absolutely anything. */
    /* 'obj' can be absolutely anything also. */

    {   Vm_Obj key    = jS.s[ 0];
	Vm_Obj obj    = jS.s[-1];
	Vm_Int typ    = OBJ_TYPE(obj);
	Vm_Obj newkey;

	/* Support for transparent networking: */
        if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Get_Next_Key)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
	}   }

	newkey = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir );

	/* Note that  OBJ_NOT_FOUND should never be handed to user: */
	if (newkey == OBJ_NOT_FOUND) { jS.s[-1]=OBJ_NIL; jS.s[0]=OBJ_NIL; }
	else 			     { jS.s[-1]=OBJ_TRUE ; jS.s[0]=newkey;    }
    }
}

 /***********************************************************************/
 /*-    job_x_p_get_val -- Get 'obj'.'key's value in db.		*/
 /***********************************************************************/

static void
job_x_p_get_val(
    Vm_Int propdir
) {
    job_Guarantee_N_Args(  2 );
    /* 'key' can be absolutely anything. */
    /* 'obj' can now be absolutely anything also. */

    {   Vm_Obj key    = jS.s[ 0];
	Vm_Obj obj    = jS.s[-1];
	Vm_Int typ    = OBJ_TYPE(obj);
        Vm_Obj result;

	/* Support for transparent networking: */
        if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Get_Val)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
	}   }

	result = (*mod_Type_Summary[ typ ]->for_get)( obj, key, propdir );
	if  (result == OBJ_NOT_FOUND) {
	    Vm_Uch buf[ 32 ];
	    job_Sprint_Vm_Obj( buf, buf+32, key, /*quotestrings:*/TRUE );
	    MUQ_WARN ("No such property: %s",buf);
	}
	*--jS.s = result;
    }
}

 /***********************************************************************/
 /*-    job_x_p_get_val_p -- Get 'obj'.'key's value in db.		*/
 /***********************************************************************/

static void
job_x_p_get_val_p(
    Vm_Int propdir
) {
    job_Guarantee_N_Args(  2 );
    /* 'key' can be absolutely anything. */
    /* 'obj' can now be absolutely anything also. */

    {   Vm_Obj key    = jS.s[ 0];
	Vm_Obj obj    = jS.s[-1];
	Vm_Int typ    = OBJ_TYPE(obj);
        Vm_Obj result;

	/* Support for transparent networking: */
        if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Get_Val_P)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
	}   }

	result = (*mod_Type_Summary[ typ ]->for_get)( obj, key, propdir );
	jS.s[ -1 ] = OBJ_FROM_BOOL( result != OBJ_NOT_FOUND );
	jS.s[  0 ] = (result == OBJ_NOT_FOUND) ? OBJ_NIL : result;
    }
}

 /***********************************************************************/
 /*-    job_x_p_keysvals_block -- "keysvals[" operator.			*/
 /***********************************************************************/

static void
job_x_p_keysvals_block(
    Vm_Int propdir
) {
    Vm_Obj key   = OBJ_FIRST;
    Vm_Obj obj   = jS.s[0];
    Vm_Int typ   = OBJ_TYPE(obj);
    Vm_Int count = 0;
    job_Guarantee_N_Args(     1 );

    /* Support for transparent networking: */
    if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Keysvals_Block)->function;
	if (OBJ_IS_CFN(cfn)) {
	    *++jS.s = OBJ_FROM_INT(propdir);
	    job_Call2(cfn);
	    return;
    }   }

    *jS.s = OBJ_BLOCK_START;
    for (
	key  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir );
	key != OBJ_NOT_FOUND;
	key  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir )
    ) {
	Vm_Obj val;
	val = (*mod_Type_Summary[ typ ]->for_get)( obj, key, propdir );
	job_Guarantee_Headroom( 3 );
	*++jS.s = key; 	++count;
	*++jS.s = val; 	++count;
    }
    *++jS.s = OBJ_FROM_BLK( count );
}

 /***********************************************************************/
 /*-    job_x_p_keys_block -- "keys[" operator.				*/
 /***********************************************************************/

static void
job_x_p_keys_block(
    Vm_Int propdir
) {
    Vm_Obj key   = OBJ_FIRST;
    Vm_Obj obj   = jS.s[0];
    Vm_Int typ   = OBJ_TYPE(obj);
    Vm_Int count = 0;
    job_Guarantee_N_Args( 1 );

    /* Support for transparent networking: */
    if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Keys_Block)->function;
	if (OBJ_IS_CFN(cfn)) {
	    *++jS.s = OBJ_FROM_INT(propdir);
	    job_Call2(cfn);
	    return;
    }   }

    *jS.s = OBJ_BLOCK_START;
    for (
	key  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir );
	key != OBJ_NOT_FOUND;
	key  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir )
    ) {
	job_Guarantee_Headroom( 2 );
	*++jS.s = key;
	++count;
    }
    *++jS.s = OBJ_FROM_BLK( count );
}

 /***********************************************************************/
 /*-    job_x_p_set_from_block -- "]set" operator.			*/
 /***********************************************************************/

static void
job_x_p_set_from_block(
    Vm_Int propdir
) {
MUQ_WARN ("Set_From_Block unimplemented");
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_Int_Arg( -1 );

    /* Get size of block: */
    {/* register Vm_Obj typ =             jS.s[ 0]  ; */
	register Vm_Unt siz = OBJ_TO_INT( jS.s[-1] );
        job_Guarantee_N_Args( siz+2 );

	/* Create object to hold values */

	/* Pop block: */
	jS.s -= siz+2;
    }
}

 /***********************************************************************/
 /*-    job_x_p_set_from_keysvals_block -- "]keysvalsSet" operator.	*/
 /***********************************************************************/

static void
job_x_p_set_from_keysvals_block(
    Vm_Int propdir
) {
MUQ_FATAL ("Set_From_Keysvals_Block unimplemented");
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );

    /* Get size of block: */
    {   register Vm_Unt i = OBJ_TO_INT(*jS.s);
        job_Guarantee_N_Args( i+1 );

	/* Pop block: */
	jS.s -= i+1;
    }
}

 /***********************************************************************/
 /*-    job_x_p_set_val -- put 'val' in 'obj'.'key'.                    */
 /***********************************************************************/

static void
job_x_p_set_val(
    Vm_Int propdir
) {
    job_Guarantee_N_Args(  3 );
    /* 'key' can be absolutely anything. */
    /* 'obj' can be absolutely anything also. */
    /* 'val' can be absolutely anything. */

    {   Vm_Obj key    = jS.s[ 0];
	Vm_Obj obj    = jS.s[-1];
	Vm_Obj val    = jS.s[-2];
	Vm_Int typ    = OBJ_TYPE(obj);
	Vm_Uch*err;

	/* Support for transparent networking: */
	if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	    Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Set_Val)->function;
	    if (OBJ_IS_CFN(cfn)) {
		*++jS.s = OBJ_FROM_INT(propdir);
		job_Call2(cfn);
		return;
	}   }

	err = (*mod_Type_Summary[ typ ]->for_set)( obj, key, val, propdir );
	if (err) MUQ_WARN (err);
	jS.s         -= 3;
    }
}

 /***********************************************************************/
 /*-    job_x_p_vals_block -- "vals[" operator.				*/
 /***********************************************************************/

static void
job_x_p_vals_block(
    Vm_Int propdir
) {
    Vm_Obj key   = OBJ_FIRST;
    Vm_Obj obj   = jS.s[0];
    Vm_Int typ   = OBJ_TYPE(obj);
    Vm_Int count = 0;
    job_Guarantee_N_Args(     1 );

    /* Support for transparent networking: */
    if (typ == OBJ_TYPE_OBJ && OBJ_IS_CLASS_PRX(obj)) {
	Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Vals_Block)->function;
	if (OBJ_IS_CFN(cfn)) {
	    *++jS.s = OBJ_FROM_INT(propdir);
	    job_Call2(cfn);
	    return;
    }   }

    *jS.s = OBJ_BLOCK_START;
    for (
	key  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir );
	key != OBJ_NOT_FOUND;
	key  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir )
    ) {
	Vm_Obj val;
	val  = (*mod_Type_Summary[ typ ]->for_get)( obj, key, propdir );
	job_Guarantee_Headroom( 2 );
	*++jS.s = val;
	++count;
    }
    *++jS.s = OBJ_FROM_BLK( count );
}

 /***********************************************************************/
 /*-    job_P_Get_Nth_Restart -- 'getNthRestart'			*/
 /***********************************************************************/

void
job_P_Get_Nth_Restart(
    void
) {
    Vm_Int restart_wanted = OBJ_TO_INT( *jS.s );
    Vm_Int restarts_seen  = 0;

    job_Guarantee_Int_Arg( 0 );
    job_Guarantee_Headroom( 6 );

    {   register Vm_Obj* l = jS.l;
	register Vm_Obj* s = jS.s;

	for (;;) {
	    if (l[-1] == JOB_STACKFRAME_RESTART
	    &&  restarts_seen++ == restart_wanted
	    ){
	        l -= 8;
		s[0] = OBJ_FROM_INT((l+8)-jS.l_bot);
		s[1] = l[1]; /* Data value.		*/
		s[2] = l[2]; /* Report-fn value.	*/
		s[3] = l[3]; /* Interactive-fn value.	*/
		s[4] = l[4]; /* Test-fn value.		*/
		s[5] = l[5]; /* Fn value.		*/
		s[6] = l[6]; /* Name value.		*/
		jS.s = &s[6];
		return;
	    }
	    l = (Vm_Obj*) (((Vm_Uch*)l) - (Vm_Int)(*l));
	    if (!*l) {
		/* No such restart found.  Say so: */
		s[0] = OBJ_NIL;	/* Nothing found. */
		s[1] = OBJ_NIL; /* Dummy data value. */
		s[2] = OBJ_NIL; /* Dummy report-fn value. */
		s[3] = OBJ_NIL; /* Dummy interactive-fn value. */
		s[4] = OBJ_NIL; /* Dummy test-fn value. */
		s[5] = OBJ_NIL; /* Dummy fn value. */
		s[6] = OBJ_NIL; /* Dummy name value. */
		jS.s = &s[6];
		return;
    }	}   }
}

 /***********************************************************************/
 /*-    job_P_Get_Restart -- 'getRestart'				*/
 /***********************************************************************/

void
job_P_Get_Restart(
    void
) {
    Vm_Int restart_wanted = OBJ_TO_INT( *jS.s );

    job_Guarantee_Int_Arg( 0 );
    job_Guarantee_Headroom( 6 );

    {   register Vm_Obj* l = jS.l;
	register Vm_Obj* s = jS.s;

	for (;;) {
	    if (l-jS.l_bot == restart_wanted
	    && l[-1] == JOB_STACKFRAME_RESTART
	    ){
		l = (Vm_Obj*) (((Vm_Uch*)l) - (Vm_Int)(*l));
		++l;
	     /* s[0] = s[0]; /  Already correct.        */
		s[1] = l[1]; /* Data value.		*/
		s[2] = l[2]; /* Report-fn value.	*/
		s[3] = l[3]; /* Interactive-fn value.	*/
		s[4] = l[4]; /* Test-fn value.		*/
		s[5] = l[5]; /* Fn value.		*/
		s[6] = l[6]; /* Name value.		*/
		jS.s = &s[6];
		return;
	    }
	    l = (Vm_Obj*) (((Vm_Uch*)l) - (Vm_Int)(*l));
	    if (!*l) {
		/* No such restart found.  Say so: */
		s[0] = OBJ_NIL;	/* Nothing found. */
		s[1] = OBJ_NIL; /* Dummy report-fn value. */
		s[2] = OBJ_NIL; /* Dummy interactive-fn value. */
		s[3] = OBJ_NIL; /* Dummy test-fn value. */
		s[4] = OBJ_NIL; /* Dummy fn value. */
		s[5] = OBJ_NIL; /* Dummy name value. */
		jS.s = &s[5];
		return;
    }	}   }
}

 /***********************************************************************/
 /*-    job_Path_Get_Unrooted_Asciz					*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    #defines							*/
 /***********************************************************************/

#ifndef JOB_MAX_PATH
#define JOB_MAX_PATH (8192)
#endif

#undef  JOB_WARN
#define JOB_WARN(x) {if (may_fail) MUQ_WARN (x); else return OBJ_NOT_FOUND;}

 /***********************************************************************/
 /*-    job_path_get_rooted						*/
 /***********************************************************************/

static Vm_Obj
job_path_get_rooted(
    Vm_Obj  root,
    Vm_Uch* path,
    Vm_Int  may_fail
) {
    /* Break off '/'-delimited chunks of path and	*/
    /* step from object to object following them:	*/
    Vm_Uch key[ JOB_MAX_PATH ];
    Vm_Int propdir = OBJ_PROP_PUBLIC;
    register Vm_Uch*src = path;

    for (;;) {
	register Vm_Uch c;
	register Vm_Uch*dst;
	Vm_Int seen_backslash = FALSE;

	/* Copy next pathname component into 'key': */
	for (dst = key;   c = *dst++ = *src++;  ) {
	    if (c == '\\') {
		--dst;
		seen_backslash = TRUE;
		break;
	    }
	    if (c == '/' ) {
		if (src == path+1   ||   src[-2] != '\\') {
		    dst[-1] = '\0';
		    break;
	}   }   }

	/* Implement special hacks to access */
	/* the various parts of an object:   */
/* buggo... this stuff is very obsolete. Can the whole */
/* fn here be deleted as obsolete, or does it need fixing? */
	/* //  'hidden' part of object.      */
	/* /@/ 'admins' part of object.	     */
	/* /#/ 'system' part of object.	     */
	/* /:/ 'method' part of object.	     */
	if (propdir == OBJ_PROP_PUBLIC   &&   !seen_backslash   &&   c) {
	    if (!key[0])       { propdir = OBJ_PROP_HIDDEN;   continue; }
	    if (!key[1])       {
		if (*key=='@') { propdir = OBJ_PROP_ADMINS;   continue; }
		if (*key=='#') { propdir = OBJ_PROP_SYSTEM;   continue; }
#ifdef OLD
		if (*key==':') { propdir = OBJ_PROP_METHOD;   continue; }
#endif
	}   }
	if (!*key) {
	    JOB_WARN("No null pathname components allowed."); 
	}

/* buggo, this `12` stuff should be phased out: */
	/* Allow /a/`12`/c and /a/`1.2`/c escapes  */
	/* for including ints and floats in paths: */
	if (key[0] != '`'
        ||  dst[-2]!= '`'
        ){  
	    Vm_Int typ    = OBJ_TYPE(root);
	    /* Look up keyword corresponding to string: */
	    Vm_Obj kwd    = sym_Alloc_Asciz_Keyword( key );
	    root    = (*mod_Type_Summary[ typ ]->for_get)(root, kwd, propdir);
	    propdir = OBJ_PROP_PUBLIC;
	} else {
	    Vm_Obj key2;
	    if (!strchr(key,'.')) {
		/* Convert an integer: */
		key2 = OBJ_FROM_INT( atoi( key+1 ) );
	    } else {
		/* Convert a float: */
		key2 = OBJ_FROM_FLOAT( (float) atof( key+1 )  );
	    }
	    {   Vm_Int typ    = OBJ_TYPE(root);
	        root = (*mod_Type_Summary[ typ ]->for_get)(root,key2,propdir);
	    }
	    propdir = OBJ_PROP_PUBLIC;
	}
	if (root == OBJ_NOT_FOUND)  JOB_WARN("Invalid path");
	if (!c)   return root;
    }
}

 /***********************************************************************/
 /*-    job_path_get_via_current_package				*/
 /***********************************************************************/

/* Paths like "xyzzy/a/b/c" are taken to be relative to */
/* symbol "xyzzy" in the current package.  We need to   */
/* look it up.  Caller guarantees that 'path' begins    */
/* with a nonspecial (alpha or equivalent) char, but    */
/* not that it contains a slash:                        */

static Vm_Obj
job_path_get_via_current_package(
    Vm_Uch* path,
    Vm_Int may_fail
) {
    Vm_Uch  buf[ JOB_MAX_PATH ];
    Vm_Uch* slash = strchr( path, '/' );
    if (!slash) {

	/* Locate needed symbol in current package: */
	{   Vm_Obj s = sym_Find_Asciz( JOB_P(jS.job)->package, path );
	    if (s)   return job_Symbol_Value(s);
	    if (may_fail) MUQ_WARN ("No '%s' in current package", path );
	    else          return OBJ_NOT_FOUND;
	}

    } else {

	/* Copy symbol name (prefix up */
	/* to first '/') into buf[]:   */
	Vm_Int n = slash-path;
	if (n >= JOB_MAX_PATH) JOB_WARN("Path too long.");
	strncpy( buf, path, n );
	buf[n] = '\0';

	/* Locate needed symbol in current package: */
	{   Vm_Obj s = sym_Find_Asciz( JOB_P(jS.job)->package, buf );
	    if (s) {
		return job_path_get_rooted(
		    job_Symbol_Value(s),   path+n+1,   may_fail
		);
	    }
	    if (may_fail) {
	        MUQ_WARN ("Bad path %s: no '%s' in current package",path,buf);
    }   }   }
    return OBJ_NOT_FOUND;
}



Vm_Obj job_Path_Get_Unrooted_Asciz(
    Vm_Uch* path,
    Vm_Int  may_fail
) {
    /* First char of path is special, ala' unix:		*/
    /* First char == '/'   means start at vm_Root(0);		*/
    /* First char == '.'   means start at here;			*/
    /* First char == '@'   means start at job.			*/
    /* First char == '~'   means start at acting_user;		*/
    Vm_Obj root;
    switch (path[0]) {
    case '/':	root = vm_Root(0);if (!path[1])   return root;	break;
    case '~':	root = jS.j.acting_user;	++path;		break;
    case '.':   root = JOB_P(jS.job)->here_obj;	++path;		break;
    case '@':	root = jS.job;			++path;		break;
    default:
	/* This idea seems more likely   */
	/* to confuse than help novices: */
	#ifdef DUBIOUS
	if (path[0]=='m' && path[1]=='e' && (path[2]=='/' || !path[2])) {
	    root  = jS.j.actual_user;
	    path += 2;
	    break;
	}
	#endif
        return job_path_get_via_current_package( path, may_fail );
    }

    /* Special case for "/" "." "~" "@" "": */
    if (!*path)   return root;

    /* We support "~/x" etc but not "~x" (yet?): */
    if (*path++ != '/')  JOB_WARN("Missing '/' in path.");

    return job_path_get_rooted( root, path, may_fail );
}

 /***********************************************************************/
 /*-    job_Path_Get_Unrooted						*/
 /***********************************************************************/

Vm_Obj job_Path_Get_Unrooted(
    Vm_Obj path,
    Vm_Int may_fail	/* MUQ_WARN on errs if true else ret OBJ_NOT_FOUND */
) {
    Vm_Uch asciz_path[ JOB_MAX_PATH ];

    /* Read path into 'asciz_path': */
    Vm_Int len = stg_Get_Bytes( asciz_path, JOB_MAX_PATH, *jS.s, 0 );
    if (len <= 0           )   JOB_WARN("Path too short");
    if (len >= JOB_MAX_PATH)   JOB_WARN("Path too long");
    asciz_path[ len ] = '\0';

    return job_Path_Get_Unrooted_Asciz( asciz_path, may_fail );
}


#ifdef OLD

 /***********************************************************************/
 /*-    job_P_Path_Get -- Get "/a/b/c"'s value in db.			*/
 /***********************************************************************/

void
job_P_Path_Get(
    void
) {

    /* Path must be a stg: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Stg_Arg( 0 );

    *jS.s = job_Path_Get_Unrooted( *jS.s, /*may_fail:*/ TRUE );
}

 /***********************************************************************/
 /*-    job_P_Path_Get_P -- Get "/a/b/c"'s value in db.			*/
 /***********************************************************************/

void
job_P_Path_Get_P(
    void
) {

    /* Path must be a stg: */
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Stg_Arg(  0 );
    job_Guarantee_Headroom( 2 );

    {   Vm_Obj val = job_Path_Get_Unrooted( *jS.s, /*may_fail:*/ FALSE );
	if (val == OBJ_NOT_FOUND) {
	    *jS.s++ = OBJ_NIL;
	    *jS.s   = OBJ_NIL;
	} else {
	    *jS.s++ = OBJ_TRUE;
	    *jS.s   = val;
    }	}
}

 /***********************************************************************/
 /*-    job_P_Path_Set -- Set "/a/b/c"'s value in db.			*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    #defines							*/
 /***********************************************************************/

#ifndef JOB_MAX_PATH
#define JOB_MAX_PATH (8192)
#endif

 /***********************************************************************/
 /*-    job_path_set_rooted						*/
 /***********************************************************************/

static void
job_path_set_rooted(
    Vm_Obj  root,
    Vm_Uch* path,
    Vm_Obj  val
) {
    /* Break off '/'-delimited chunks of path and	*/
    /* step from object to object following them:	*/
    Vm_Uch key[ JOB_MAX_PATH ];
    register Vm_Uch*src = path;
    Vm_Int propdir = OBJ_PROP_PUBLIC;

    for (;;) {
	register Vm_Uch c;
	register Vm_Uch*dst;

	Vm_Int seen_backslash = FALSE;

	/* Copy next pathname component into 'key': */
	for (dst = key;   c = *dst++ = *src++;  ) {
	    if (c == '\\') {
		--dst;
		seen_backslash = TRUE;
		break;
	    }
	    if (c == '/' ) {
		if (src == path+1   ||   src[-2] != '\\') {
		    dst[-1] = '\0';
		    break;
	}   }   }

	if (propdir == OBJ_PROP_PUBLIC   &&   !seen_backslash   &&   c) {
	    if (!key[0])       { propdir = OBJ_PROP_HIDDEN;   continue; }
	    if (!key[1])       {
		if (*key=='@') { propdir = OBJ_PROP_ADMINS;   continue; }
		if (*key=='~') { propdir = OBJ_PROP_SYSTEM;   continue; }
		if (*key==':') { propdir = OBJ_PROP_METHOD;   continue; }
	}   }
	if (!*key) {
	    MUQ_WARN ("No null pathname components allowed.");
	}

/* Buggo, key-creation logic should be in a subfn: */
	if (c == '/') {
	    /* Nonfinal pathname component.  Step to */
            /* next object, creating it if missing:  */
	    Vm_Obj new_root;
	    if (key[0] != '`'
	    ||  dst[-2]!= '`'
	    ){  
		new_root = OBJ_GET_ASCIZ(
		    root,
		    sym_Alloc_Asciz_Keyword(key),
		    propdir
		);
	    } else {
		/* Allow /a/`12`/c and /a/`1.2`/c escapes  */
		/* for including ints and floats in paths: */
		Vm_Obj key2;
		if (!strchr(key,'.')) {
		    /* Convert an integer: */
		    key2 = OBJ_FROM_INT( atoi( key+1 ) );
		} else {
		    /* Convert a float: */
		    key2 = OBJ_FROM_FLOAT( (float) atof( key+1 )  );
		}
		new_root = OBJ_GET( root, key2, propdir );
	    }
	    if (new_root == OBJ_NOT_FOUND) {
		if (!OBJ_IS_OBJ(root)) {
		    MUQ_WARN ("Could not create path component %s",key);
		} else {
		    if (OBJ_IS_CLASS_PKG(root)) {
			if ((key[0] == '`' &&  dst[-2]== '`')
			|| propdir != OBJ_PROP_PUBLIC
			){
			    MUQ_WARN ("Couldn't make path component %s",key);
			}
			new_root = sym_Alloc_Asciz( root, key, 0 );
		    } else {
			Vm_Obj key2;
			if (key[0] != '`'
			||  dst[-2]!= '`'
			){
			    key2 = sym_Alloc_Asciz_Keyword( key );
			} else {
			    if (!strchr(key,'.')) {
				key2=OBJ_FROM_INT(         atoi(key+1));
			    } else {
				key2=OBJ_FROM_FLOAT((float)atof(key+1));
			}   }
			new_root = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
			{   Vm_Int typ  = OBJ_TYPE(root);
			    Vm_Uch* err = (*mod_Type_Summary[typ]->for_set)(
				root, key2, new_root, propdir
			    );
			    if (err) MUQ_WARN (err);
			}
		    }
		}
	    }
	    root    = new_root;
	    propdir = OBJ_PROP_PUBLIC;
	} else {
	    /* Final pathname component, do a set: */
	    Vm_Obj key2;
	    if (OBJ_IS_OBJ(root)
	    &&  OBJ_IS_CLASS_PKG(root)
            ){
		Vm_Obj sym = sym_Alloc_Asciz( root, key, 0 );
		SYM_P(sym)->value = val;
		vm_Dirty(sym);
		return;
	    }
	    if (key[0] != '`'
	    ||  dst[-2]!= '`'
	    ){
		key2 = sym_Alloc_Asciz_Keyword( key );
	    } else {
		if (!strchr(key,'.')) key2=OBJ_FROM_INT(         atoi(key+1));
		else 		      key2=OBJ_FROM_FLOAT((float)atof(key+1));
	    }
	    {   Vm_Int typ  = OBJ_TYPE(root);
		Vm_Uch* err = (*mod_Type_Summary[typ]->for_set)(
		    root, key2, val, propdir
		);
		if (err) MUQ_WARN (err);
	    }
	    return;
	}
    }
}

 /***********************************************************************/
 /*-    job_Path_Set_Unrooted_Asciz					*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    job_path_set_via_current_package				*/
 /***********************************************************************/

/* Paths like "xyzzy/a/b/c" are taken to be relative to */
/* symbol "xyzzy" in the current package.  We need to   */
/* look it up.  Caller guarantees that 'path' begins    */
/* with a nonspecial (alpha or equivalent) char, but    */
/* not that it contains a slash:                        */

static void
job_path_set_via_current_package(
    Vm_Uch* path,
    Vm_Obj  val
) {
    Vm_Uch  buf[ JOB_MAX_PATH ];
    Vm_Uch* slash = strchr( path, '/' );
    if (!slash) {

	/* Locate needed symbol in current package: */
	{   Vm_Obj s = sym_Find_Asciz( JOB_P(jS.job)->package, path );
	    if (s) {
		SYM_P(s)->value = val;
		vm_Dirty(s);
		return;
	    }
	    MUQ_WARN ("No '%s' in current package", path );
	}

    } else {

	/* Copy symbol name (prefix up */
	/* to first '/') into buf[]:   */
	Vm_Int n = slash-path;
	if (n >= JOB_MAX_PATH)   MUQ_WARN ("Path too long.");
	strncpy( buf, path, n );
	buf[n] = '\0';

	/* Locate needed symbol in current package: */
	{   Vm_Obj s = sym_Find_Asciz( JOB_P(jS.job)->package, buf );
	    if (s) {
		job_path_set_rooted( job_Symbol_Value(s), path+n+1, val );
		return;
	    }
	    MUQ_WARN ("Bad path %s: no '%s' in current package", path, buf );
	}
    }
}



void job_Path_Set_Unrooted_Asciz(
    Vm_Uch* path,
    Vm_Obj  val
) {
    /* First char of path is special, ala' unix:		*/
    /* First char == '/'   means start at vm_Root(0);		*/
    /* First char == '.'   means start at here;			*/
    /* First char == '@'   means start at job.			*/
    /* First char == '~'   means start at actual_user;		*/
    Vm_Obj root;
    switch (path[0]) {
    case '/':	root = vm_Root(0);				break;
    case '~':	root = jS.j.actual_user;	++path;		break;
    case '.':   root = JOB_P(jS.job)->here_obj;	++path;		break;
    case '@':	root = jS.job;			++path;		break;
    default:
	/* This idea seems more likely   */
	/* to confuse than help novices: */
	#ifdef DUBIOUS
	if (path[0]=='m' && path[1]=='e' && (path[2]=='/' || !path[2])) {
	    root  = jS.j.actual_user;
	    path += 2;
	    break;
	}
	#endif
        job_path_set_via_current_package( path, val );
	return;
    }

    /* We support "~/x" etc but not "~x" (yet?): */
    if (*path++ != '/')  MUQ_WARN ("Missing '/' in path.");

    job_path_set_rooted( root, path, val );
    return;
}

 /***********************************************************************/
 /*-    job_Path_Set_Unrooted						*/
 /***********************************************************************/

void job_Path_Set_Unrooted(
    Vm_Obj path,
    Vm_Obj val
) {
    Vm_Uch asciz_path[ JOB_MAX_PATH ];

    /* Read path into 'asciz_path': */
    Vm_Int len = stg_Get_Bytes( asciz_path, JOB_MAX_PATH, *jS.s, 0 );
    if (len <= 0           )   MUQ_WARN ("Path too short");
    if (len >= JOB_MAX_PATH)   MUQ_WARN ("Path too long");
    asciz_path[ len ] = '\0';

    job_Path_Set_Unrooted_Asciz( asciz_path, val );
    return;
}



void
job_P_Path_Set(
    void
) {

    /* Path must be a stg: */
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Stg_Arg( 0 );

    job_Path_Set_Unrooted( jS.s[0], jS.s[-1] );
    jS.s -= 2;
}


#endif

 /***********************************************************************/
 /*-    job_P_Pop_Catchframe --						*/
 /***********************************************************************/

void
job_P_Pop_Catchframe(
    void
) {
    job_Guarantee_Headroom( 3 );
    if (jS.l[-1] != JOB_STACKFRAME_CATCH) {
	MUQ_WARN ("POP_CATCHFRAME: No frame!");
    }

    /* Pop the catchframe: */
    jS.l = JOB_PREV_STACKFRAME(jS.l);

    /*********************************/
    /* Push a null block.  The only  */
    /* point of this is to give us a */
    /* consistent arity to keep the  */
    /* arity-checking logic happy    */
    /* since when we catch something */
    /* we return [ args | t          */
    /*********************************/

    /* Push a bottom-of-block marker:*/
    *++jS.s = OBJ_BLOCK_START;

    /* Push a top-of-block marker:   */
    *++jS.s = OBJ_FROM_BLK(0);

    /* Push a "nothing caught" flag: */
    *++jS.s = OBJ_NIL;
}

 /***********************************************************************/
 /*-    job_P_Pop_Tagframe --						*/
 /***********************************************************************/

void
job_P_Pop_Tagframe(
    void
) {
    if (jS.l[-1] != JOB_STACKFRAME_TAG) {
	MUQ_WARN ("POP_TAGFRAME: No frame!");
    }

    /* Pop the tagframe: */
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_Tagtopframe --					*/
 /***********************************************************************/

void
job_P_Pop_Tagtopframe(
    void
) {
    if (jS.l[-1] != JOB_STACKFRAME_TAGTOP) {
	MUQ_WARN ("POP_TAGTOPFRAME: No frame!");
    }

    /* Pop the tagframe: */
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_User_Frame -- Remove a USER stackframe.		*/
 /***********************************************************************/

void
job_P_Pop_User_Frame(
    void
) {
    /********************************************/
    /* This function is called at the end of a  */
    /* asMeDo{ ... } clause.  We need to      */
    /* restore old acting_user as we do so.     */
    /********************************************/
    if (jS.l[-1] != JOB_STACKFRAME_USER) {
	MUQ_WARN ("job_P_Pop_User_Frame: no USER frame found");
    }

    jS.j.acting_user = jS.l[-2];
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_Privs_Frame -- Remove a PRIVS stackframe.		*/
 /***********************************************************************/

void
job_P_Pop_Privs_Frame(
    void
) {
    /********************************************/
    /* This function is called at the end of a  */
    /* rootOmnipotentlyDo{ ... } clause.  We  */
    /* need to restore old privs as we do so.   */
    /********************************************/
    if (jS.l[-1] != JOB_STACKFRAME_PRIVS) {
	MUQ_WARN ("job_P_Pop_Privs_Frame: no PRIVS frame found");
    }

    jS.j.privs = jS.l[-2];
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Push_User_Me_Frame -- Deposit a USER stackframe.		*/
 /***********************************************************************/

static void
push_user_frame(
    Vm_Obj new_user
) {
    /********************************************/
    /* This function is called to start a       */
    /* asMeDo{ ... } clause. We need to push  */
    /* a USER frame and change jS.j.acting_user */
    /********************************************/

    {    register Vm_Obj* l = jS.l;

	/* Check for loop stack overflow: */
	if (l + 4 >= jS.l_top) {
	    job_Guarantee_Loop_Headroom( 4 );
	    l = jS.l;
	}

	/* Add a USER stackframe: */
	++l; *l = 4*sizeof(Vm_Obj);
	++l; *l = jS.j.acting_user;
	++l; *l = JOB_STACKFRAME_USER;
	++l; *l = 4*sizeof(Vm_Obj);

	/* Remember new loop topofstack: */
	jS.l = l;
    }

    /* Set new acting user: */
    jS.j.acting_user = new_user;
}

void
job_P_Push_User_Me_Frame(
    void
) {
    /********************************************/
    /* This function is called to start a       */
    /* asMeDo{ ... } clause. We need to push  */
    /* a USER frame and change jS.j.acting_user */
    /********************************************/
    push_user_frame( obj_Owner(jS.x_obj) );
}

 /***********************************************************************/
 /*-    job_P_Root_Push_User_Frame -- Deposit a USER stackframe.	*/
 /***********************************************************************/

void
job_P_Root_Push_User_Frame(
    void
) {
    /********************************************/
    /* This function is called to start a       */
    /* rootAsUserDo{ ... } clause. We push   */
    /* a USER frame and change jS.j.acting_user */
    /********************************************/
    job_Must_Be_Root();

    /* Validate stack argument: */
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Folk_Arg( 0 );

    {    register Vm_Obj* l = jS.l;

	/* Check for loop stack overflow: */
	if (l + 4 >= jS.l_top) {
	    job_Guarantee_Loop_Headroom( 4 );
	    l = jS.l;
	}

	/* Add a USER stackframe: */
	++l; *l = 4*sizeof(Vm_Obj);
	++l; *l = jS.j.acting_user;
	++l; *l = JOB_STACKFRAME_USER;
	++l; *l = 4*sizeof(Vm_Obj);

	/* Remember new loop topofstack: */
	jS.l = l;
    }

    /* Set new acting user: */
    jS.j.acting_user = *jS.s--;
}

 /***********************************************************************/
 /*-    job_P_Root_Push_Privs_Omnipotent_Frame -- Deposit a PRIVS frame.*/
 /***********************************************************************/

void
job_P_Root_Push_Privs_Omnipotent_Frame(
    void
) {
    /********************************************/
    /* This function is called to start a       */
    /* rootOmnipotentlyDo{ ... } clause. Push */
    /* a PRIVS frame and change jS.j.privs      */
    /********************************************/
    job_Must_Be_Root();

    {    register Vm_Obj* l = jS.l;

	/* Check for loop stack overflow: */
	if (l + 4 >= jS.l_top) {
	    job_Guarantee_Loop_Headroom( 4 );
	    l = jS.l;
	}

	/* Add a PRIVS stackframe: */
	++l; *l = 4*sizeof(Vm_Obj);
	++l; *l = jS.j.privs;
	++l; *l = JOB_STACKFRAME_PRIVS;
	++l; *l = 4*sizeof(Vm_Obj);

	/* Remember new loop topofstack: */
	jS.l = l;
    }

    /* Set new privs word: */
    jS.j.privs |= JOB_PRIVS_OMNIPOTENT;
}

 /***********************************************************************/
 /*-    job_P_Pop_Lockframe -- Do LOCK stackframe.			*/
 /***********************************************************************/

void
job_P_Pop_Lockframe(
    void
) {
    /********************************************/
    /* This function is called at the end of a  */
    /* with-lock{ ... } clause. We need to      */
    /* release the lock as we do so.            */
    /********************************************/
    if (jS.l[-1] != JOB_STACKFRAME_LOCK
    &&  jS.l[-1] != JOB_STACKFRAME_LOCK_CHILD
    ){
	/* When we fork, we NULL out the child's LOCK */
	/* stackframes, so we need to be prepared to  */
	/* accept and ignore one here:                */
        if (jS.l[-1] == JOB_STACKFRAME_NULL){
	    jS.l = JOB_PREV_STACKFRAME(jS.l);
	    return;
	}

	MUQ_WARN ("job_Pop_Lockframe: no lockframe found");
    }

    lok_Release( jS.l[-2] );
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Push_Lockframe -- Deposit a LOCK stackframe.		*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_push_lockframe -- Deposit a LOCK[_CHILD] stackframe.	*/
  /**********************************************************************/

static void
job_push_lockframe(
    Vm_Obj typ /* Either JOB_STACKFRAME_LOCK or JOB_STACKFRAME_LOCK_CHILD */
) {
    /********************************************/
    /* This function is called to start a       */
    /* with-lock{ ... } clause. We need to      */
    /* allocate the lock as we do so.           */
    /********************************************/
    job_Guarantee_N_Args(    1 );
    job_Guarantee_Lck_Arg(   0 );
    job_Must_Control_Object( 0 );

    /* Find the lock: */
    {   Vm_Obj lok = *jS.s;

	/* Sleep if it is taken: */
	Vm_Obj op  = lok_Maybe_SendSleep_Job( lok, typ );
	/* op will be JOB_STACKFRAME_NULL if we    */
	/* already hold the lock, but normally     */
	/* it will be JOB_STACKFRAME_LOCK[_CHILD]. */

	{   register Vm_Obj* l = jS.l;

	    /* Check for loop stack overflow: */
	    if (l + 4 >= jS.l_top) {
		job_Guarantee_Loop_Headroom( 4 );
		l = jS.l;
	    }

	    /* Add a LOCK (sometimes NULL) stackframe: */
	    ++l; *l = 4*sizeof(Vm_Obj);
	    ++l; *l = *jS.s;
	    ++l; *l = op;
	    ++l; *l = 4*sizeof(Vm_Obj);

	    jS.l = l;      /* Remember new loop  topofstack. */
	}

	/* Mark the lock as taken: */
	LOK_P(lok)->held_by = jS.job;
	vm_Dirty(lok);
    }
    --jS.s;
}

void
job_P_Push_Lockframe(
    void
) {
    job_push_lockframe( JOB_STACKFRAME_LOCK );
}

 /***********************************************************************/
 /*-    job_P_Push_Lockframe_Child -- Deposit a LOCK_CHILD stackframe.	*/
 /***********************************************************************/

void
job_P_Push_Lockframe_Child(
    void
) {
    job_push_lockframe( JOB_STACKFRAME_LOCK_CHILD );
}

 /***********************************************************************/
 /*-    job_P_Pop_Ephemeral_List -- Do EPHEMERAL_LIST stackframe.	*/
 /***********************************************************************/

void
job_P_Pop_Ephemeral_List(
    void
) {
    if (jS.l[-1] != JOB_STACKFRAME_EPHEMERAL_LIST) {
	MUQ_WARN ("job_Pop_Ephemeral: no EPHEMERAL-LIST frame found");
    }

    jS.j.ephemeral_lists = jS.l[-2];
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_Ephemeral_Struct -- Do EPHEMERAL_STRUCT stackframe.	*/
 /***********************************************************************/

void
job_P_Pop_Ephemeral_Struct(
    void
) {
    if (jS.l[-1] != JOB_STACKFRAME_EPHEMERAL_STRUCT) {
	MUQ_WARN ("job_Pop_Ephemeral: no EPHEMERAL-STRUCT frame found");
    }

    jS.j.ephemeral_structs = jS.l[-2];
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_Ephemeral_Vector -- Do EPHEMERAL_VECTOR stackframe.	*/
 /***********************************************************************/

void
job_P_Pop_Ephemeral_Vector(
    void
) {
    if (jS.l[-1] != JOB_STACKFRAME_EPHEMERAL_VECTOR) {
	MUQ_WARN ("job_Pop_Ephemeral_Vector: no EPHEMERAL-VECTOR frame found");
    }

    jS.j.ephemeral_vectors = jS.l[-2];
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_Fun_Binding -- Do FUN_BIND stackframe.		*/
 /***********************************************************************/

void
job_P_Pop_Fun_Binding(
    void
) {
    /********************************************/
    /* This function is called at the end of a  */
    /* ]with-restart{ ... } clause.             */
    /********************************************/
    if (jS.l[-1] != JOB_STACKFRAME_FUN_BIND) {
	MUQ_WARN ("job_Pop_Fun_Binding: no FUN_BIND frame found");
    }

    jS.j.function_bindings = jS.l[-2];
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_Var_Binding -- Do VAR_BIND stackframe.		*/
 /***********************************************************************/

void
job_P_Pop_Var_Binding(
    void
) {
    /********************************************/
    /* This function is called at the end of a  */
    /* ]with-restart{ ... } clause.             */
    /********************************************/
    if (jS.l[-1] != JOB_STACKFRAME_VAR_BIND) {
	MUQ_WARN ("job_Pop_Var_Binding: no VAR_BIND frame found");
    }

    jS.j.variable_bindings = jS.l[-2];
    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_Restartframe -- Do RESTART stackframe.		*/
 /***********************************************************************/

void
job_P_Pop_Restartframe(
    void
) {
    /********************************************/
    /* This function is called at the end of a  */
    /* ]with-restart{ ... } clause.             */
    /********************************************/
    if (jS.l[-1] != JOB_STACKFRAME_RESTART) {
	MUQ_WARN ("job_Pop_Restartframe: no restartframe found");
    }

    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_P_Pop_Handlersframe -- Do HANDLERS stackframe.		*/
 /***********************************************************************/

void
job_P_Pop_Handlersframe(
    void
) {
    /********************************************/
    /* This function is called at the end of a  */
    /* ]with-hanlders{ ... } clause.            */
    /********************************************/
    if (jS.l[-1] != JOB_STACKFRAME_HANDLERS) {
	MUQ_WARN ("job_Pop_Handlersframe: no restartframe found");
    }

    jS.l = JOB_PREV_STACKFRAME(jS.l);
}

 /***********************************************************************/
 /*-    job_Push_Restartframe -- Deposit a RESTART stackframe.		*/
 /***********************************************************************/

void
job_Push_Restartframe(
    Vm_Obj name,
    Vm_Obj function,
    Vm_Obj interactive_function,
    Vm_Obj test_function,
    Vm_Obj report_function,
    Vm_Obj data
) {
    register Vm_Obj* l = jS.l;

    /* Check for loop stack overflow: */
    if (l + 9 >= jS.l_top) {
	job_Guarantee_Loop_Headroom( 9 );
	l = jS.l;
    }

    /* Add a RESTART stackframe: */
    ++l; *l = 9*sizeof(Vm_Obj);
    ++l; *l = data;
    ++l; *l = report_function;
    ++l; *l = interactive_function;
    ++l; *l = test_function;
    ++l; *l = function;
    ++l; *l = name;
    ++l; *l = JOB_STACKFRAME_RESTART;
    ++l; *l = 9*sizeof(Vm_Obj);

    jS.l = l;      /* Remember new loop  topofstack. */
}

 /***********************************************************************/
 /*-    job_P_Push_Restartframe -- Implement top of ]withRestartDo{	*/
 /***********************************************************************/

void
job_P_Push_Restartframe(
    void
) {
    /********************************************/
    /* This function is called to start a       */
    /* with-restart{ ... } clause.              */
    /********************************************/

    /* Values to fill in from our keyval block: */
    Vm_Obj name                 = OBJ_NIL;
    Vm_Obj function             = OBJ_NIL;
    Vm_Obj interactive_function = OBJ_NIL;
    Vm_Obj test_function        = OBJ_NIL;
    Vm_Obj report_function      = OBJ_NIL;
    Vm_Obj data                 = OBJ_NIL;
    
    /* Pluck above vals from our keyval block: */
    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    Vm_Int i;

    job_Guarantee_Blk_Arg(   0 );

    if (size & 1) {
	MUQ_WARN ("]withRestartDo{ argblock length must be even.");
    }
    job_Guarantee_N_Args( size+2 );

    for (i = 0;   i < size;   i += 2) {

	Vm_Int key_index  = i-size;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Function      ) {
	    if (OBJ_IS_SYMBOL(val)
	    ||  OBJ_IS_CFN(val)
	    ){
		function = val;
	    } else {
		MUQ_WARN ("]withRestartDo{ :function arg must be a fn.");
	    }
        } else if (key == job_Kw_Interactive_Function) {
	    if (OBJ_IS_SYMBOL(val)
	    ||  OBJ_IS_CFN(val)
	    ){
		interactive_function = val;
	    } else {
		MUQ_WARN (
		    "]withRestartDo{ :interactive-function arg"
		    " must be NIL or a function"
		);
	    }
        } else if (key == job_Kw_Test_Function) {
	    if (OBJ_IS_SYMBOL(val)
	    ||  OBJ_IS_CFN(val)
	    ){
		test_function = val;
	    } else {
		MUQ_WARN (
		    "]withRestartDo{ :testFunction arg"
		    " must be NIL or a function"
		);
	    }
        } else if (key == job_Kw_Report_Function) {
	    if (OBJ_IS_SYMBOL(val)
	    ||  OBJ_IS_CFN(val)
	    ||  stg_Is_Stg(val)
	    ){
		report_function = val;
	    } else {
		MUQ_WARN (
		    "]withRestartDo{ :reportFunction arg"
		    " must be NIL, a string, or a compiledFunction"
		);
	    }
        } else if (key == job_Kw_Name          ) {
	    if (OBJ_IS_SYMBOL(val)) {
		name = val;
	    } else {
		MUQ_WARN ("]withRestartDo{ :name arg must be a symbol.");
	    }
        } else if (key == job_Kw_Data          ) {
	    data = val;
	} else {
	    MUQ_WARN ("Unrecognized ]withRestartDo{ keyword.");
    }	}	

    /* All restarts must supply :function value: */
    if (function == OBJ_NIL) {
	MUQ_WARN (
	    "]withRestartDo{ needs "
	    "a :function"
	);
    }

    /* Nameless functions must have report and interactive values: */
    if (name == OBJ_NIL) {
	if (interactive_function == OBJ_NIL) {
	    MUQ_WARN (
		"]withRestartDo{ :name -less restarts "
		"need an :interactive-function"
	    );
	}
    }
    if (interactive_function != OBJ_NIL) {
	if (report_function == OBJ_NIL) {
	    MUQ_WARN (
		"]withRestartDo{ restarts with :interactive-function "
		"need a :reportFunction"
	    );
	}
    }

    /* Fat city: */
    job_Push_Restartframe(
	name,
	function,
	interactive_function,
	test_function,
	report_function,
	data
    );
    
    /* Pop our keyval block and we're done: */
    jS.s -= size+2;
}

 /***********************************************************************/
 /*-    job_P_Push_Handlersframe -- Deposit a HANDLERS stackframe.	*/
 /***********************************************************************/

void
job_P_Push_Handlersframe(
    void
) {
    /********************************************/
    /* This function is called to start a       */
    /* ]with-handlers{ ... } clause.            */
    /********************************************/

    /* Pluck above vals from our keyval block: */
    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    Vm_Int i;

    job_Guarantee_Blk_Arg( 0 );

    if (size & 1) {
	MUQ_WARN ("]withHandlersDo{ argblock length must be even.");
    }
    job_Guarantee_N_Args( size+2 );

    /* Sanity-check our argument block before */
    /* beginning anything:                    */
    for (i = 0;   i < size;   i += 2) {

	Vm_Int cond_index  = i-size;
	Vm_Int func_index  = cond_index +1;
        Vm_Obj cond        = jS.s[ cond_index ];
        Vm_Obj func        = jS.s[ func_index ];

	if (!OBJ_IS_OBJ(cond)
/*	||  !OBJ_IS_CLASS_EVT(cond) */
	){
	    MUQ_WARN ("]withHandlersDo{ event must be a Event.");
        }
	if (!OBJ_IS_CFN(func)
	&&  !OBJ_IS_SYMBOL(func)
	){
	    MUQ_WARN (
		"]withHandlersDo{ function must be a compiledFunction."
	    );
    }   }

    /* Check for loop stack overflow: */
    if (jS.l + size + 3 >= jS.l_top) {
	job_Guarantee_Loop_Headroom( size + 3 );
    }

    /* Build the HANDLERS frame: */
    {   register Vm_Obj* l = jS.l;

	/* Push bottom of new stackframe: */
	++l; *l = (size+3)*sizeof(Vm_Obj);

	/* Push all the cond+func pairs: */
	for (i = 0;   i < size;   i += 2) {

	    Vm_Int cond_index  = i-size;
	    Vm_Int func_index  = cond_index +1;
	    Vm_Obj cond        = jS.s[ cond_index ];
	    Vm_Obj func        = jS.s[ func_index ];

	    ++l; *l = cond;
	    ++l; *l = func;
	}

	/* Finish off stackframe: */
	++l; *l = JOB_STACKFRAME_HANDLERS;
	++l; *l = (size+3)*sizeof(Vm_Obj);

        jS.l = l;      /* Remember new loop  topofstack. */
    }

    /* Pop our argblock and we're done: */
    jS.s -= size+2;
}


 /***********************************************************************/
 /*-    job_P_Pop_Unwindframe -- Do VANILLA/JUMP/RETURN/THROW stackframe.*/
 /***********************************************************************/

void
job_P_Pop_Unwindframe(
    void
) {
    /********************************************/
    /* This function is called at the end of an */
    /* }always_do{ ... } clause.  If the after{ */
    /* clause executed normally, it ended by    */
    /* changing it's PROTECT frame to a VANILLA */
    /* frame, which we now pop and continue.    */
    /*                                          */
    /* If a nonlocal exit occurred during the   */
    /* after{ clause, a special stackframe      */
    /* indicating the type of exit was pushed   */
    /* before executing our }always_do{ clause, */
    /* and we now need to pop that frame and    */
    /* continue the delayed nonlocal exit in    */
    /* question:                                */
    /********************************************/

    switch (jS.l[-1]) {

    case JOB_STACKFRAME_JUMP:
	jS.pc = ((Vm_Uch*)jS.k) + OBJ_TO_INT(jS.l[-2]);
        jS.l  = JOB_PREV_STACKFRAME(jS.l);

	/* jS.pc is now correct, so we don't want anyone */
	/* incrementing it before executing instruction: */
	jS.instruction_len = 0;
	return;

    case JOB_STACKFRAME_RETURN:
        jS.l  = JOB_PREV_STACKFRAME(jS.l);
	job_P_Return();
	return;

    case JOB_STACKFRAME_THROW:
        jS.l  = JOB_PREV_STACKFRAME(jS.l);
	throw( jS.l[ 2 ], JOB_THROW );	/* Doesn't return.	*/
	return;				/* Cheap insurance!	*/

    case JOB_STACKFRAME_GOTO:
        jS.l  = JOB_PREV_STACKFRAME(jS.l);
	throw( jS.l[ 2 ], JOB_GOTO );	/* Doesn't return.	*/
	return;				/* Cheap insurance!	*/

    case JOB_STACKFRAME_ENDJOB:
        jS.l  = JOB_PREV_STACKFRAME(jS.l);
	throw( jS.l[ 2 ], JOB_ENDJOB );	/* Sometimes returns.	*/
	return;

    case JOB_STACKFRAME_EXEC:
        jS.l  = JOB_PREV_STACKFRAME(jS.l);
	throw( jS.l[ 2 ], JOB_EXEC );	/* Sometimes returns.	*/
	return;

    case JOB_STACKFRAME_VANILLA:
        jS.l  = JOB_PREV_STACKFRAME(jS.l);
	return;

    default:
	MUQ_WARN ("job_Pop_Unwindframe: internal err");
    }
}

 /***********************************************************************/
 /*-    job_P_Program_Counter_To_Line_Number -- 			*/
 /***********************************************************************/

void
job_P_Program_Counter_To_Line_Number(
    void
) {
    Vm_Obj fn =             jS.s[  0 ]  ;
    Vm_Int pc = OBJ_TO_INT( jS.s[ -1 ] );
    /* Look up the line number corresponding to a given */
    /* program counter value.  There's no terribly good */
    /* reason to do this inserver, really, but it does  */
    /* help ensure that if we change the line number    */
    /* encoding technique used by asm, we can change    */
    /* the decoding technique too, in lockstep.         */
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Fn_Arg(   0 );
    job_Guarantee_Int_Arg( -1 );

    /* Fetch the line number info: */
    {   Vm_Obj vec = FUN_P(fn)->line_numbers;
	Vm_Int len;
	if (!OBJ_IS_VEC(vec)) {

	    /* Currently, BAD is on the bottom of the stack to catch */
	    /* overpops, and has no valid linenumber vector. For now */
	    /* we just return NIL to avoid crashing the debugger. We */
	    /* should think up a nicer fix by and by.		     */
	    #ifdef SOMEDAY
	    MUQ_WARN (
		"job_P_Program_Counter_To_Line_Number: Invalid line# vector"
	    );
	    #else
	    *--jS.s = OBJ_NIL;
	    return;
	    #endif
	}
	len = vec_Len(vec);
	if (pc < 0 || pc >= len) {
	    MUQ_WARN (
		"job_P_Program_Counter_To_Line_Number: Need 0 <= pc (%d) < %d",
		(int)pc,
		(int)len
	    );
	}
	{   Vm_Obj result = vec_Get( vec, pc );
	    *--jS.s = result;
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Return -- 						*/
 /***********************************************************************/

/* Any changes here likely require matching changes in CALL and EXECUTE: */

void
job_P_Return(
    void
) {
    register Vm_Obj* l = jS.l;

    /* Verify that we have a stackframe to return to: */
    /* Find current NORMAL stackframe: */
    for (;;) {
        if (l[-1] == JOB_STACKFRAME_NORMAL) break;
	l  = JOB_PREV_STACKFRAME(l);

        if (l[-1] == JOB_STACKFRAME_NORMAL) break;
	l  = JOB_PREV_STACKFRAME(l);

        if (l[-1] == JOB_STACKFRAME_NORMAL) break;
	l  = JOB_PREV_STACKFRAME(l);

	if (!*l) MUQ_WARN("return: Can't find current NORMAL frame?!");
    }
    /* Step past current NORMAL stackframe: */
    l  = JOB_PREV_STACKFRAME(l);
    /* Find next normal stackframe: */
    for (;;) {
        if (l[-1] == JOB_STACKFRAME_NORMAL) break;
	l  = JOB_PREV_STACKFRAME(l);

        if (l[-1] == JOB_STACKFRAME_NORMAL) break;
	l  = JOB_PREV_STACKFRAME(l);

        if (l[-1] == JOB_STACKFRAME_NORMAL) break;
	l  = JOB_PREV_STACKFRAME(l);

        if (l[-1] == JOB_STACKFRAME_NORMAL) break;
	l  = JOB_PREV_STACKFRAME(l);

	if (!*l) MUQ_WARN("return: No NORMAL frame to return to?!");
    }

    /* Process any CATCH (etc) frames nested on top of the    */
    /* NORMAL stackframe which we are attempting to RET from: */
    l = jS.l;
    while (l[-1] != JOB_STACKFRAME_NORMAL) {

        switch (l[-1]) {

        case JOB_STACKFRAME_PROTECT:
        case JOB_STACKFRAME_PROTECT_CHILD:
	    /* Funfun, stop RETURN long enough to */
	    /* execute the always_do clause which */
	    /* this stackframe marks as being  in */
	    /* force:				  */
	    /* Remember we need to continue RETURN: */
	    l[-1] = JOB_STACKFRAME_RETURN;
	    /* Jump to always_do clause: */
	    jS.pc = ((Vm_Uch*)jS.k) + OBJ_TO_INT( l[-2] );
	    /* jS.pc is now correct, so we don't want anyone */
	    /* incrementing it before executing instruction: */
	    jS.instruction_len = 0;
	    /* Remember new top of loop stack: */
            jS.l  = l;
	    return;

        case JOB_STACKFRAME_THROW:
            /* It's really a bit naughty to put a RETURN      */
            /* in a always_do clause... but we'll be nice and */
            /* silently continue the interrupted throw:       */
	    jS.l  = JOB_PREV_STACKFRAME(l);
	    throw( l[-2], JOB_THROW );
	    return;

        case JOB_STACKFRAME_GOTO:
            /* It's really a bit naughty to put a RETURN      */
            /* in a always_do clause... but we'll be nice and */
            /* silently continue the interrupted goto:        */
	    jS.l  = JOB_PREV_STACKFRAME(l);
	    throw( l[-2], JOB_GOTO );
	    return;

        case JOB_STACKFRAME_ENDJOB:
	    jS.l  = JOB_PREV_STACKFRAME(l);
	    throw( l[-2], JOB_ENDJOB );
	    return;

        case JOB_STACKFRAME_EXEC:
	    jS.l  = JOB_PREV_STACKFRAME(l);
	    throw( l[-2], JOB_EXEC );
	    return;

        case JOB_STACKFRAME_JUMP:
            /* Also naughty, but we'll continue the jump: */
	    jS.l  = JOB_PREV_STACKFRAME(l);
	    jS.pc = ((Vm_Uch*)jS.k) + OBJ_TO_INT(l[2]);
	    /* jS.pc is now correct, so we don't want anyone */
	    /* incrementing it before executing instruction: */
	    jS.instruction_len = 0;
	    return;

        case JOB_STACKFRAME_RETURN:
            /* Also naughty, but we'll continue the RETURN: */
	    l  = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_TAG:
	case JOB_STACKFRAME_NULL:
	case JOB_STACKFRAME_CATCH:
	case JOB_STACKFRAME_TAGTOP:
	case JOB_STACKFRAME_VANILLA:
        case JOB_STACKFRAME_RESTART:
        case JOB_STACKFRAME_HANDLING:
        case JOB_STACKFRAME_HANDLERS:
            /* Pop the stackframe, otherwise ignoring it: */
	    l  = JOB_PREV_STACKFRAME(l);
            break;

        case JOB_STACKFRAME_LOCK:
        case JOB_STACKFRAME_LOCK_CHILD:
	    /* We're returning out of a with-lock{...}, */
	    /* so release the lock:                     */
	    jS.l = JOB_PREV_STACKFRAME(l);
            lok_Release( jS.l[2] );
	    l = jS.l;
	    break;

        case JOB_STACKFRAME_TMP_USER:
	    /* Returning from a handler: */
	    /* FALLTHRU */
        case JOB_STACKFRAME_USER:
	    /* We're returning out of an  asMeDo{...}, */
	    /* or such, so restore previous user:        */
	    l = JOB_PREV_STACKFRAME(l);
            jS.j.acting_user = l[2];
	    break;

        case JOB_STACKFRAME_PRIVS:
	    /* We're returning out of an rootOmnipotentlyDo{...}, */
	    /* or such, so restore previous privs bitmask:          */
	    l = JOB_PREV_STACKFRAME(l);
            jS.j.privs = l[2];
	    break;

        case JOB_STACKFRAME_SIGNAL:
            MUQ_FATAL ("SIGNAL stackframe in impossible spot!");
        case JOB_STACKFRAME_THUNK:
            MUQ_FATAL ("THUNK stackframe in impossible spot!");

        case JOB_STACKFRAME_EPHEMERAL_LIST:
	    /* We're returning from a scope that pushed  */
	    /* an ephemeral, need to update linklist     */
	    /* head pointer jS.j.ephemeral_objects:      */
	    jS.j.ephemeral_lists = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

        case JOB_STACKFRAME_EPHEMERAL_STRUCT:
	    /* We're returning from a scope that pushed  */
	    /* an ephemeral, need to update linklist     */
	    /* head pointer jS.j.ephemeral_structs:      */
	    jS.j.ephemeral_structs = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

        case JOB_STACKFRAME_EPHEMERAL_VECTOR:
	    /* We're returning from a scope that pushed  */
	    /* an ephemeral, need to update linklist     */
	    /* head pointer jS.j.ephemeral_vectors:      */
	    jS.j.ephemeral_vectors = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

        case JOB_STACKFRAME_FUN_BIND:
	    /* We're returning from a scope that bound   */
	    /* a symbol, need to update binding linklist */
	    /* head pointer jS.j.function_bindings:      */
	    jS.j.function_bindings = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

        case JOB_STACKFRAME_VAR_BIND:
	    /* We're returning from a scope that bound   */
	    /* a symbol, need to update binding linklist */
	    /* head pointer jS.j.variable_bindings:      */
	    jS.j.variable_bindings = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

        default:
            MUQ_FATAL ("Bad stackframe type");
        }
    }

    l = JOB_PREV_STACKFRAME(l);
    jS.l = l;				/* Cache loopstack top */

    /* Find next NORMAL stackframe down on stack: */
    while (l[-1] != JOB_STACKFRAME_NORMAL) {

        switch (l[-1]) {

        case JOB_STACKFRAME_TAG:
        case JOB_STACKFRAME_GOTO:
        case JOB_STACKFRAME_JUMP:
        case JOB_STACKFRAME_LOCK:
        case JOB_STACKFRAME_LOCK_CHILD:
        case JOB_STACKFRAME_NULL:
        case JOB_STACKFRAME_USER:
        case JOB_STACKFRAME_THROW:
        case JOB_STACKFRAME_PRIVS:
        case JOB_STACKFRAME_CATCH:
        case JOB_STACKFRAME_EXEC:
        case JOB_STACKFRAME_ENDJOB:
        case JOB_STACKFRAME_RETURN:
        case JOB_STACKFRAME_TAGTOP:
        case JOB_STACKFRAME_PROTECT:
        case JOB_STACKFRAME_PROTECT_CHILD:
        case JOB_STACKFRAME_RESTART:
	case JOB_STACKFRAME_VANILLA:
        case JOB_STACKFRAME_HANDLERS:
        case JOB_STACKFRAME_FUN_BIND:
        case JOB_STACKFRAME_VAR_BIND:
        case JOB_STACKFRAME_EPHEMERAL_LIST:
        case JOB_STACKFRAME_EPHEMERAL_STRUCT:
        case JOB_STACKFRAME_EPHEMERAL_VECTOR:
            /* Step over the stackframe: */
	    l = JOB_PREV_STACKFRAME(l);
	    break;

        case JOB_STACKFRAME_TMP_USER:
	    /* Returning from a handler, */
	    /* so restore previous user: */
	    l = JOB_PREV_STACKFRAME(l);
            jS.j.acting_user = l[2];
	    /* We don't normally pop stuff sitting on */
	    /* top of the active NORMAL frame, but    */
	    /* TMP_USER stackframes are an exception: */
	    jS.l = l;
	    break;

        case JOB_STACKFRAME_THUNK:
	    /* Whee! we're returning from a THUNK! */
	    pop_thunkframe_normally( l );
	    l = JOB_PREV_STACKFRAME(l);
	    /* We don't normally pop stuff sitting on */
	    /* top of the active NORMAL frame, but    */
	    /* THUNK stackframes are an exception:    */
	    jS.l = l;
	    break;

        case JOB_STACKFRAME_HANDLING:
	    l = JOB_PREV_STACKFRAME(l);
	    /* We don't normally pop stuff sitting on */
	    /* top of the active NORMAL frame, but    */
	    /* HANDLING stackframes are an exception: */
	    jS.l = l;
	    break;

        default:
/* buggo: This is about where we should be handling  */
/* a return from the bottom NORMAL frame as a simple */
/* graceful end-of-job, no?                          */
            MUQ_FATAL ("Bad stack-frame type");
        }
    }

    /* Locate local variables within stackframe: */
    /* Locals are always four words */
    /* above top of previous frame: */
    l = JOB_PREV_STACKFRAME(l);
    jS.v = l + 4;

    /* Restore old state saved in NORMAL stackframe returned to: */
    {   register Vm_Obj x = jS.v[-1];     	/* Previous executable */
	register Vm_Obj*p = CFN_P(x)->vec;	/* Previous constants  */
        jS.k     = p;
        l        = jS.v-2; /* Enregister ptr. Done AFTER above CFN_P! :)  */
        jS.pc    = ((Vm_Uch*)p) + OBJ_TO_INT(*l); --l; /* Previous pc */
	/* jS.pc is now correct, so we don't want anyone */
	/* incrementing it before executing instruction: */
	jS.instruction_len = 0;

	/* It is important not to set jS.x_obj	*/
	/* until above CFN_P(o) call swaps it   */
        /* into ram for us:                     */
        jS.x_obj = x;
    }

    /* Uncomment for a handy debugging trace: */
    #ifndef MUQ_TRACE
    if (job_Log_Bytecodes /*= (++job_Bytecodes_Logged>JOB_TRACE_BYTECODES_FROM)*/) {
        Vm_Obj src = CFN_P(jS.x_obj)->src;
	if (OBJ_IS_OBJ(src) && OBJ_IS_CLASS_FN(src)) {
	    Vm_Obj nam = FUN_P(src)->o.objname;
	    if (stg_Is_Stg(nam)) {
		Vm_Int len = stg_Len(nam);
		if (len < 200) {
		    Vm_Uch buf[  256 ];
		    Vm_Uch buf2[ 256 ];
		    if (len == stg_Get_Bytes( buf, len, nam, 0 )) {
			buf[len] = '\0';
			sprintf(buf2,"Returning to '%s'...\n",buf);
			lib_Log_String(buf2);
    }	}   }   }   }
    #endif
}

 /***********************************************************************/
 /*-    job_P_Set_Here -- Set current working directory via path.	*/
 /***********************************************************************/

void
job_P_Set_Here(
    void
) {
/* buggo This should probably be mufcoded, not C-coded, eventually. 93Nov09CrT */
    Vm_Obj new_here = *jS.s;
    job_Guarantee_N_Args(  1 );
    if (stg_Is_Stg( new_here )) new_here = job_Path_Get_Unrooted(new_here,1);
    --jS.s;
    JOB_P(    jS.job )->here_obj = new_here;
    vm_Dirty( jS.job );
}



 /***********************************************************************/
 /*-    job_P_Signal -- Send given signal to given job.			*/
 /***********************************************************************/


  /**********************************************************************/
  /*-   job_Signal_Job -- Send given signal to given job.		*/
  /**********************************************************************/

void
job_Signal_Job(
    Vm_Obj  job,
    Vm_Obj* argblock,
    Vm_Unt  argcount
) {
    Vm_Obj old_len   = jS.instruction_len;
    Vm_Obj old_job   = jS.job;

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(job) || !OBJ_IS_CLASS_JOB(job)) {
	MUQ_FATAL ("job_Signal_Job: needed job");
    }
    #endif

    /* Ignore attempts to signal dead jobs: */
    if (!job_Is_Alive(job))   return;

    if (job != old_job) {

	/**********************************/
	/* Okie, need to make recipient   */
	/* job the currently running job, */
	/* then force a call to do_signal:*/
	/**********************************/

	/* Make recipient the active job: */
	if (old_job) job_State_Unpublish();
	joq_Run_Job(         job );
	job_State_Publish(   job );
    }



    /*********************************/
    /* At this point, we know that   */
    /* currently executing job is    */
    /* the one receiving the signal. */
    /*********************************/

    /* Find our ]doSignal function: */
    {   Vm_Obj do_signal = JOB_P(jS.job)->do_signal;

	/* Buggo, should be an arity check somewhere... */

	if (OBJ_IS_SYMBOL(do_signal)) {
	    do_signal = job_Symbol_Function(do_signal);
	}

	/* Do call only if do_signal */
	/* is a compiled function:   */    
	if (OBJ_IS_CFN(do_signal)) {

	    /* Ensure sufficient room to copy */
	    /* argblock onto recipient stack: */
/* buggo:  If we overflow the stack here when called */
/* from skt.t to signal a disconnect (say), I think  */
/* we may be toast.                                  */
	    job_Guarantee_Headroom( argcount+2 );

	    /* Copy argblock into recipient:  */
	    {   Vm_Unt  i;
		*++jS.s = OBJ_BLOCK_START;
		++jS.s;
		for (i = 0;   i < argcount;   ++i)   jS.s[i] = argblock[i];
		jS.s += argcount;
		*jS.s  = OBJ_FROM_BLK( argcount );
	    }



#ifdef NOT_COOL_YET /* buggo */
/* problem with this is that nobody is going to pop it yet: */
	    /* Switch actingUser to actualUser  */
	    /* so that ]doSignal function runs   */
	    /* in a more predictable environment: */
	    push_user_frame( jS.j.actual_user );
#endif

	    /* Execute call to ]doSignal fn:     */
	    job_Call( do_signal );
	}

	/* If we switched jobs, switch back:  */
	if (jS.job != old_job) {
	    job_State_Unpublish(         );
	    if (old_job) {
		joq_Run_Job(         old_job );
		job_State_Publish(   old_job );
		jS.instruction_len = old_len;
	    }
	}
    }
}

  /**********************************************************************/
  /*-   job_P_Signal -- Send given signal to given job.			*/
  /**********************************************************************/

void
job_P_Signal(
    void
) {
    Vm_Int i;

    Vm_Obj job       = OBJ_NIL;
    Vm_Obj event     = OBJ_NOT_FOUND;
    Vm_Int argcount  = OBJ_TO_BLK( jS.s[0] );
    Vm_Obj argblock[ JOB_SIGNAL_BLOCK_MAX ];

    job_Guarantee_Blk_Arg( 0 );
    if (argcount & 1) {
	MUQ_WARN ("]signal argblock length must be even.");
    }
    if (argcount > JOB_SIGNAL_BLOCK_MAX) {
	MUQ_WARN (
	    "]signal argblock length must be <= %d.",
	    (int)JOB_SIGNAL_BLOCK_MAX
	);
    }
    
    job_Guarantee_N_Args( argcount+2 );

    /* Scan argument block for :job and :event */
    for (i = 0;   i < argcount;   i += 2) {

	Vm_Int key_index  = i-argcount;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Job        ) {
	    job = val;
        } else if (key == job_Kw_Event ) {
	    event = val;
	} else if (!OBJ_IS_SYMBOL(key)) {
	    MUQ_WARN ("]signal keywords must be symbols.");
    }	}	

    if (job == OBJ_NIL)   job = jS.job;



    /* Sanity-check :job and :event values: */

    if (!OBJ_IS_OBJ(     job)
    || !OBJ_IS_CLASS_JOB(job)
    ){
	MUQ_WARN ("]signal :job arg must be a job.");
    }

    if (event == OBJ_NOT_FOUND) {
	MUQ_WARN ("Missing ]signal :event parameter.");
    }
    if (!OBJ_IS_OBJ(     event)
/*  || !OBJ_IS_CLASS_EVT(event) */
/*     Commented out above check when switching from old object  */
/*     system to MOS object system.  Could check that event      */
/*     is a class and a subclass of /etc/event, but it would     */
/*     be a bit expensive -- and do we really need that here?    */
    ){
	MUQ_WARN ("]signal :event arg must be an event.");
    }

#ifdef OLD
    /* Silently abort call if we're sending */
    /* signal to a job we have no right to  */
    /* be messing with:                     */
    if (job != jS.job) {
	if (!(jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	||  !OBJ_IS_CLASS_ROT(jS.j.acting_user)
	){
	    if (OBJ_P(job)->owner != jS.j.acting_user) {
		/* Pop arg block and return: */
		jS.s -= argcount+2;
		return;
        }   }

	/**********************************/
	/* Okie, need to make recipient   */
	/* job the currently running job, */
	/* copy argblock from sender's    */
	/* stack to recipient's stack,    */
	/* then force a call to do_signal:*/
	/**********************************/

	/* Mark argblock as popped        */
	/* from sending stack:            */
	jS.s -= argcount+2;

	{   /* Remember where argblock is:*/
	    Vm_Obj old_data_stack = jS.data_vector;
	    Vm_Int offset = jS.s - (Vm_Obj*)vm_Loc(old_data_stack);

	    /* Make recipient the active job: */
	    job_State_Unpublish(     );
	    joq_Run_Job(         job );
	    job_State_Publish(   job );

	    /* Ensure sufficient room to copy */
	    /* argblock onto recipient stack: */
	    job_Guarantee_Headroom( argcount+2 );

	    /* Copy argblock into recipient:  */
	    {   Vm_Obj* src = (Vm_Obj*)vm_Loc(old_data_stack)+offset;
		Vm_Int  i;
		for (i = 1;   i <= argcount+2;   ++i)   jS.s[i] = src[i];
		jS.s += argcount+2;
    }   }   }



    /*********************************/
    /* At this point, we know that   */
    /* currently executing job is    */
    /* the one receiving the signal. */
    /*********************************/

    /* Find our ]doSignal function: */
    {   Vm_Obj do_signal = JOB_P(jS.job)->do_signal;

	/* Buggo, should be an arity check somewhere... */

	if (OBJ_IS_SYMBOL(do_signal)) {
	    do_signal = job_Symbol_Function(do_signal);
	}

	/* Do call only if do_signal */
	/* is a compiled function:   */    
	if (!OBJ_IS_CFN(do_signal)) {

	    jS.s -= argcount+2;

	} else {

#ifdef NOT_COOL_YET /* buggo */
/* problem with this is that nobody is going to pop it yet: */
	    /* Switch actingUser to actualUser  */
	    /* so that ]doSignal function runs   */
	    /* in a more predictable environment: */
	    push_user_frame( jS.j.actual_user );
#endif

	    /* Execute call to ]doSignal fn:     */
	    job_Call( do_signal );
	}

	/* If we switched jobs, switch back:  */
	if (jS.job != old_job) {
	    job_State_Unpublish(         );
	    joq_Run_Job(         old_job );
	    job_State_Publish(   old_job );
	    jS.instruction_len = old_len;
	}
    }
#else

    /* Copy argument block into argblock[]: */
    for (i = 0;   i < argcount;   ++i) {
	argblock[i] = jS.s[ i-argcount ];
    }

    /* Pop the argblock: */
    jS.s -= argcount+2;

    /* Do the signal, if possible: */
    job_Signal_Job( job, argblock, argcount );
#endif
}

 /***********************************************************************/
 /*-    job_P_Queue_Job -- Move given job to given queue.		*/
 /***********************************************************************/

void
job_P_Queue_Job(
    void
) {
    Vm_Obj us  = jS.job;
    Vm_Obj job = jS.s[-1];
    Vm_Obj joq = jS.s[ 0];

    /* Require one argument.  Intended   */
    /* to be used similar to unix exit() */
    /* value, currently ignored:         */
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Job_Arg( -1 );
    job_Guarantee_Joq_Arg(  0 );
    job_must_control( job );
    job_must_control( joq );

    switch (JOQ_P(joq)->kind) {
    case OBJ_FROM_BYT2('p','s'    ):
	MUQ_WARN("May not 'queueJob' into a \"ps\" jobQueue");
	break;
    case OBJ_FROM_BYT3('d','o','z'):
	MUQ_WARN("May not 'queueJob' into a \"doz\" jobQueue");
	break;
    case OBJ_FROM_BYT3('r','u','n'):
	/* Each user has three run queues, so as to be able */
	/* to run jobs at three different priority levels.  */
	/* To make life simple for the in-db programmer, we */
	/* want to automatically put jobs in the proper run-*/
	/* queue when a runQueue is specified:             */
	{   Vm_Obj jb_owner;
	    Vm_Unt priority;
	    {   Job_P j     = JOB_P(job);
		priority    = OBJ_TO_INT( j->priority );
		jb_owner    =             j->owner;
	    }
	    #if MUQ_IS_PARANOID
	    if (priority >= (Vm_Unt)JOB_PRIORITY_LEVELS) {
		MUQ_FATAL ("job_P_Queue_Job: internal err");
	    }
	    #endif
	    joq = USR_P(jb_owner)->run_q[ priority ];
	}
	break;
    default:
	;
    }

    jS.s -= 2;
    if (job!=us) {
	joq_Requeue( joq, job );
    } else {

	/* Switching currently running job */
	/* to another queue.  Need to mark */
	/* current instruction as complete */
	/* before saving state:            */
	jS.pc += jS.instruction_len;
	jS.instruction_len = 0;

	joq_Requeue( joq, job );

	/* Can't continue execution if we've */
	/* been moved to a non-runqueue:     */
	job_next();
    }
}

 /***********************************************************************/
 /*-    job_P_Sleep_Job -- Sleep current job 'n' milliseconds.		*/
 /***********************************************************************/

void
job_P_Sleep_Job(
    void
) {
    /* Get number of milliseconds to sleep: */
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );

    /* Advance program counter to next instruction, */
    /* so we resume there rather than re-executing  */
    /* sleepJob when we wake:                      */
    jS.pc += jS.instruction_len;

    {   Vm_Int millisecs_to_sleep = OBJ_TO_INT( *jS.s-- );

	/* Move current job to /etc/doz: */
	Vm_Obj job = jS.job;
	joq_Dequeue(    job                     );
	joq_Ensleep(    job, millisecs_to_sleep );

	/* Switch to next runnable job: */
	job_next();
    }
}

 /***********************************************************************/
 /*-    job_P_Print1_Data_Stack -- "print1DataStack" operator.	*/
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Print1_Data_Stack(
    void
) {

    Vm_Uch buf[ MAX_STRING ];

    job_Guarantee_Headroom( 1 );

    job_State_Update();

    {   Vm_Uch*   end = stk_Sprint1(buf, buf+MAX_STRING, jS.j.data_stack );
        Vm_Obj    val = stg_From_Buffer( buf, end-buf );
	*++jS.s = val;
    }
}



 /***********************************************************************/
 /*-    job_P_Goto -- 							*/
 /***********************************************************************/

void
job_P_Goto(
    void
) {
    /* Check that we have a tag on stack: */
    job_Guarantee_N_Args(  1 );

    /* Pop tag off stack: */
    {   Vm_Obj o = *jS.s;
	--jS.s;

	/* Goto the tag: */
/* buggo: thunks should not be able to 'goto' to a */
/* catcher which does not belong to them.  This means */
/* that gotos should refuse to proceed */
/* past a THUNK stackframe. */
	throw( o, JOB_GOTO );
    }
}

 /***********************************************************************/
 /*-    job_P_Get_All_Active_Handlers -- "|getAllActiveHandlers["	*/
 /***********************************************************************/

void
job_P_Get_All_Active_Handlers(
    void
) {
/* buggo: A thunk should not be able to invoke */
/* handlers it did not establish, in general,  */
/* for security reasons.  This means that      */
/* thunk scope should probably be marked on    */
/* the loop stack, and respected by            */
/* job_P_Get_All_Active_Handlers().            */
/* However, must also consider the case of     */
/* signals received from other jobs (say)      */
/* while a thunk is executing: Don't want them */
/* wrecked by presence of thunk. Needs thought.*/
    /********************************************/
    /* We fetch all active handlers in a block, */
    /* rather than looping over a get-nth type  */
    /* function, because this reduces the work  */
    /* done from O(N^2) in the stack size to    */
    /* O(N) in the stack size.  Probably not a  */
    /* major issue most of the time, but it is  */
    /* little if any extra work to avoid the    */
    /* possible O(N^2) blowup.                  */
    /********************************************/

    /********************************************/
    /* We use a four-pass algorithm:            */
    /*                                          */
    /* Pass 1:  Change the opcode of all busy   */
    /*          handler sets from HANDLERS to   */
    /*          BUSY_HANDLERS.                  */
    /*                                          */
    /* Pass 2:  Count number of available       */
    /*          handlers, make sure enough      */
    /*          data stack space exists to      */
    /*          hold all our result values.     */
    /*          Allocate needed space, sliding  */
    /*          argblock up appropriately.      */
    /*                                          */
    /* Pass 3:  Copy available handlers into    */
    /*          return block on datastack.      */
    /*                                          */
    /* Pass 4:  Change the opcode of all busy   */
    /*          handler sets from BUSY_HANDLERS */
    /*          back to HANDLERS.               */
    /********************************************/


    register Vm_Obj* l;
    Vm_Int size = OBJ_TO_BLK( jS.s[0] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args( size+2 );



    /* Pass 1:  Change the opcode of all busy       */
    /* handler sets from HANDLERS to BUSY_HANDLERS. */
    for (l = jS.l;   *l;  l = JOB_PREV_STACKFRAME(l)) {
	if (l[-1] == JOB_STACKFRAME_HANDLING) {
	    #if MUQ_IS_PARANOID
	    if (*JOB_HANDLERS_OPCODE(l) != JOB_STACKFRAME_HANDLERS) {
		MUQ_FATAL( "|getAllActiveHandlers[ internal err");
	    }
	    #endif
	    *JOB_HANDLERS_OPCODE(l) = JOB_STACKFRAME_BUSY_HANDLERS;
    }	}



    /* Pass 2 */
    {
	/* Count number of available handlers.  */
	/* We actually count events plus        */
	/* handlers, rather than just handlers: */
        Vm_Int words_found = 0;
	for (l = jS.l;   *l;  l = JOB_PREV_STACKFRAME(l)) {
	    if (l[-1] == JOB_STACKFRAME_HANDLERS) {
		/* Number of interesting words in HANDLERS */
		/* frame is number of words in the frame   */
		/* minus three, for the two length words   */
		/* and the opcode word:                    */
		words_found += ((l - JOB_PREV_STACKFRAME(l)) -3);
     	}   }

	/* Make sure enough data stack space     */
	/* exists to hold all our result values. */
	/* We need space for all words found,    */
	/* plus two delimiter words for the      */
	/* result block holding them, plus three */
	/* words recording the size and location */
	/* of that return block for our caller:  */
	if (!job_Got_Headroom(words_found + 5)) {
	    /* Restore stack before signalling error: */
	    for (l = jS.l;   *l;  l = JOB_PREV_STACKFRAME(l)) {
		if (l[-1] == JOB_STACKFRAME_HANDLING) {
		    *JOB_HANDLERS_OPCODE(l) = JOB_STACKFRAME_HANDLERS;
	    }	}
	    job_Guarantee_Headroom( words_found + 5 );
	}

	/* Allocate needed space, sliding  */
	/* argblock up appropriately:      */
	{   /* Slide argblock to new position: */
	    register Vm_Int  i;
	    register Vm_Obj* s = jS.s;
	    l = s+words_found+2;
	    for (i = size+2;   i --> 0;)   *l-- = *s--;

	    /* Set up the three return values */
	    /* describing return block:       */
	    {   /* Compute the three values: */
	        Vm_Int k  = words_found >> 1;
		Vm_Int lo = (jS.s - jS.s_bot) - size;
	        Vm_Int hi = lo + k;

		/* Allocate space by bumping jS.s: */
		jS.s += words_found + 5;

		/* Save the three values on data stack: */
		jS.s[ 0 ] = OBJ_FROM_INT( k    );
		jS.s[-1 ] = OBJ_FROM_INT( hi-1 );
		jS.s[-2 ] = OBJ_FROM_INT( lo-1 );

		/* Set up top of result block marker: */
		jS.s_bot[ lo + words_found ] = OBJ_FROM_BLK( words_found );



		/* Pass 3: Copy available handlers */
		/* into return block on datastack: */
		{   Vm_Int pairs_copied = 0;
		    for (l = jS.l;   *l;  l = JOB_PREV_STACKFRAME(l)) {
			if (l[-1] == JOB_STACKFRAME_HANDLERS) {
			    Vm_Obj* p     = JOB_PREV_STACKFRAME(l);
			    Vm_Int  words = (l - p) -3;
			    p += 2;
			    for (i = 0;   i < words;   i += 2) {
				Vm_Obj event     = p[i  ];
				Vm_Obj handler   = (
				    OBJ_FROM_INT( &p[i+1] - jS.l_bot )
				);
				jS.s_bot[ lo+pairs_copied   ] = event  ;
				jS.s_bot[ lo+pairs_copied+k ] = handler;
				++pairs_copied;
    }   }   }   }   }   }   }



    /* Pass 4:  Change the opcode of all busy */
    /* handler sets from BUSY_HANDLERS back   */
    /* to HANDLERS:                           */
    for (l = jS.l;   *l;  l = JOB_PREV_STACKFRAME(l)) {
	if (l[-1] == JOB_STACKFRAME_HANDLING) {
	    *JOB_HANDLERS_OPCODE(l) = JOB_STACKFRAME_HANDLERS;
    }	}
}


 /***********************************************************************/
 /*-    job_P_Invoke_Handler --	Implement "]invokeHandler" operator.	*/
 /***********************************************************************/

void
job_P_Invoke_Handler(
    void
) {
    /*********************************************/
    /* This function is an inserver-prim mostly  */
    /* because I want the operation of invoking  */
    /* the function implementing the handler     */
    /* functionality to be atomically combined   */
    /* with the operation of dis-establishing    */
    /* the handler set in question, to avoid     */
    /* having a second signal to the same        */
    /* handler set sneak through in the window   */
    /* between the two operations.               */
    /*********************************************/

    /* Pluck above vals from our keyval block: */
    Vm_Int size = OBJ_TO_BLK( jS.s[-1] );
    Vm_Int h    = OBJ_TO_INT( jS.s[ 0] ); /* Loc of our handler. */

    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg(  0 );
    job_Guarantee_Blk_Arg( -1 );
    if (size & 1) {
	MUQ_WARN ("]invokeHandler argblock length must be even.");
    }
    job_Guarantee_N_Args( size+3 );

    {   register Vm_Obj* l = jS.l;
	Vm_Int no_handler;	/* Handler argument was garbage. */
	Vm_Unt offset; /* Opcode word of our handler set within stack */
        Vm_Obj handler_user = jS.j.acting_user; /* Who bound handler? */

	/* Find the relevant handler set, */
	/* and within it the handler fn   */
	/* which we are invoking.         */

        /* First, find correct handler set: */
        l = jS.l;
	{   register Vm_Obj* p = jS.l_bot + h;
	    while (*l && l > p) {
		/* Track effective user binding handler: */
		Vm_Obj op = l[-1];
		if (op==JOB_STACKFRAME_USER
		||  op==JOB_STACKFRAME_TMP_USER
		){
		    handler_user = l[-2];
		}
		l = JOB_PREV_STACKFRAME(l);
	    }
	    /* Check that p points into handler set. */
	    /* Note that it should not be possible   */
	    /* for the handler set to be busy, since */
	    /* even though a signal can slip into    */
	    /* the gap between ]signal finding the   */
	    /* handler via get-nth-signal and the    */
	    /* time ]invoke-signal is executed, any  */
	    /* such nested call must have also       */
	    /* returned by now.  This is why we do   */
	    /* not check for this.                   */

	    no_handler = (!*l
	    ||   (++l, l = JOB_NEXT_STACKFRAME(l), --l) <= p
	    ||   (*--l != JOB_STACKFRAME_HANDLERS)
	    );

	    /* Remember byte offset of handler set */
	    /* opcode word within loop stack:      */
	    offset = ((Vm_Uch*)l) - ((Vm_Uch*)jS.l_bot);
	}

	/* If we couldn't find the specified handler */
	/* at all, there must be a coding error, so  */
	/* we should signal an error:                */
	if (no_handler) {
	    MUQ_WARN ("]invokeHandler couldn't find that handler.");
	}

	/* Next, sanity-check handler: */
	{   Vm_Obj handler = jS.l_bot[h];

	    if (OBJ_IS_SYMBOL(handler)) {
		handler = job_Symbol_Function(handler);
	    }
	    if (!OBJ_IS_CFN(handler)) {
		MUQ_WARN (
		    "]invokeHandler: Handler isn't a compiledFunction"
		);
	    }

	    /* buggo, we're not yet checking that */
	    /* the handler is of arity [] -> []   */

	    /* Check for loop stack overflow,   */
	    /* wordcount computed as:           */
	    /* JOB_STACKFRAME_TMP_USER: 4 words */
	    /* JOB_STACKFRAME_HANDLING: 4 words */
	    /* JOB_STACKFRAME_NORMAL:   5 words */
	    if (jS.l + (4+4+5) >= jS.l_top) {
		job_Guarantee_Loop_Headroom( 4+4+5 );
	    }

	    
	    {   register Vm_Obj* l = jS.l;

		/* Build the TMP_USER frame: */
		++l; *l = 4*sizeof(Vm_Obj);
		++l; *l = jS.j.acting_user;
		++l; *l = JOB_STACKFRAME_TMP_USER;
		++l; *l = 4*sizeof(Vm_Obj);

		/* Note new actingUser: */
		jS.j.acting_user = handler_user;

		/* Build the HANDLING frame: */

		/* Push new stackframe.  We again use our   */
		/* slightly unclean trick of knowing that   */
		/* stack entries are more than a byte long  */
		/* and that our integer encoding is a zero  */
		/* bit at the low end, hence the byte       */
		/* difference between any two pointers into */
		/* the stack will look like a Muq integer:  */
		++l; *l = 4*sizeof(Vm_Obj);
		++l; *l = (Vm_Obj) offset;
		++l; *l = JOB_STACKFRAME_HANDLING;
		++l; *l = 4*sizeof(Vm_Obj);

		jS.l = l;      /* Remember new loop  topofstack. */
	    }

	    /* Pop our handler arg off data stack: */
	    --jS.s;

	    /* Invoke given handler on given argblock: */
	    job_Call2( handler );
	}
    }
}



 /***********************************************************************/
 /*-    job_P_Simple_Error --						*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_simple_error -- Find CATCHer for preformatted error msg it.	*/
  /**********************************************************************/

static void
job_simple_error(
    Vm_Obj msg
) {
    Vm_Obj o = JOB_P(jS.job)->do_error;
    if (OBJ_IS_SYMBOL(o) && o!=OBJ_NIL)   o = job_Symbol_Function(o);
    if (!OBJ_IS_CFN(o)) {
	/* Bad @$s.doError! Give up and kill job: */
	job_end_job( jS.job );
	job_next();
    } else {
	if (job_Got_Headroom(2))   jS.s += 2;
	jS.s[ 0] = msg;
	jS.s[-1] = obj_Err_Simple_Error;
	/* Leave PC pointed at current instruction: */
	jS.instruction_len = 0;
	job_Call2(o);
    }
}

  /**********************************************************************/
  /*-   job_P_Simple_Error --						*/
  /**********************************************************************/

void
job_P_Simple_Error(
    void
) {
    Vm_Obj msg = *jS.s;
    job_Guarantee_Stg_Arg(  0 );
    --jS.s;
    job_simple_error( msg );
}

 /***********************************************************************/
 /*-    job_P_Throw -- 							*/
 /***********************************************************************/

void
job_P_Throw(
    void
) {

    /* Check that we have a catch tag on stack: */
    job_Guarantee_N_Args(  1 );

    /* Pop tag off stack: */
    {   Vm_Obj o = *jS.s;
	--jS.s;

	/* Throw the tag: */
/* buggo: thunks should not be able to 'throw' to a   */
/* catcher which does not belong to them.  This means */
/* that non-error throws should refuse to proceed     */
/* past a THUNK stackframe.                           */
	throw( o, JOB_THROW );
    }
}

 /***********************************************************************/
 /*-    job_P_Kill_Job_Messily -- Delete from queue, never to run again.*/
 /***********************************************************************/

void
job_P_Kill_Job_Messily(
    void
) {
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Job_Arg( 0 );
    job_must_control( jS.s[0] );

    /************************************************/
    /* Note that, unlike job_P_End_Job(), we do NOT */
    /* do a throw(OBJ_NOT_FOUND,JOB_THROW):         */
    /* Root_Kill_Job is intended to stop runaway    */
    /* jobs DEAD, and such a throw() would allow    */
    /* the job to potentially keep running          */
    /* indefinitely.   On the other hand,           */
    /* job_P_End_Job() is intended for voluntary    */
    /* shutdown of a well-behaved job and wants to  */
    /* give all the after{}always_do{} clauses a    */
    /* chance to wrap up cleanly.                   */
    /************************************************/

    /* Dismantle indicated thread: */
    {   Vm_Obj job;
	job_end_job( job = *jS.s-- );

	/* Switch to next job if thread killed is us: */
	if (job == jS.job)   job_next();
    }
}

 /***********************************************************************/
 /*-    job_P_Root_Shutdown -- Shut down system.			*/
 /***********************************************************************/

void
job_P_Root_Shutdown(
    void
) {
    job_Must_Be_Root();

    job_State_Update();

    while (skt_Maybe_Do_Some_IO( 0 ));

    /* Jump back to file that started us, currently */
    /* z_muq.c:                                     */
    longjmp( skt_Bat_Longjmp_Buf, 1 );
}

/************************************************************************/
/*-    Public fns, CLX true prims.					*/
/************************************************************************/

 /***********************************************************************/
 /*-	no_x11								*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
#ifndef HAVE_X11
static void
no_x11(
    void
) {
    MUQ_WARN ("X11 window system not supported in this server.");
}
#endif
#endif

 /***********************************************************************/
 /*-	job_P_Close_Display						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Close_Display(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xdp_Arg(   0 );
    job_Must_Control_Object( 0 );
    xdp_Close_Display( *jS.s   );
    --jS.s;

    #endif
}
#endif

 /***********************************************************************/
 /*-    job_P_Color_P -- "color?"					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Color_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XCL(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-    job_P_Colormap_P -- "colormap?"					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Colormap_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XCM(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-    job_P_Cursor_P -- "cursor?"					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Cursor_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XCR(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-    job_P_Display_P -- "display?"					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Display_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XDP(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-    job_P_Font_P -- "font?"						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Font_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XFT(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-    job_P_Gcontext_P -- "gcontext?"					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Gcontext_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XGC(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-    job_P_Pixmap_P -- "pixmap?"					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Pixmap_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XPX(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-    job_P_Screen_P -- "screen?"					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Screen_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XSC(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-    job_P_Window_P -- "window?"					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Window_P(
    void
) {
    job_Guarantee_N_Args(1);
    *jS.s = OBJ_FROM_BOOL( OBJ_IS_OBJ(*jS.s) && OBJ_IS_CLASS_XWD(*jS.s) );
}
#endif

 /***********************************************************************/
 /*-	job_P_Create_Gcontext						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Create_Gcontext(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    /* Return value: */
    Vm_Obj gcontext;

    /* Supported keyword parameters: */
    Vm_Obj arc_mode		= OBJ_NIL;
    Vm_Obj background		= OBJ_NIL;
    Vm_Obj cap_style		= OBJ_NIL;
    Vm_Obj clip_mask		= OBJ_NIL;
    Vm_Obj clip_ordering	= OBJ_NIL;
    Vm_Obj clip_x		= OBJ_NIL;
    Vm_Obj clip_y		= OBJ_NIL;
    Vm_Obj dash_offset		= OBJ_NIL;
    Vm_Obj dashes		= OBJ_NIL;
    Vm_Obj drawable		= OBJ_NIL;
    Vm_Obj exposures		= OBJ_NIL;
    Vm_Obj fill_rule		= OBJ_NIL;
    Vm_Obj fill_style		= OBJ_NIL;
    Vm_Obj font			= OBJ_NIL;
    Vm_Obj foreground		= OBJ_NIL;
    Vm_Obj function		= OBJ_NIL;
    Vm_Obj join_style		= OBJ_NIL;
    Vm_Obj line_style		= OBJ_NIL;
    Vm_Obj line_width		= OBJ_NIL;
    Vm_Obj plane_mask		= OBJ_NIL;
    Vm_Obj stipple		= OBJ_NIL;
    Vm_Obj subwindow_mode	= OBJ_NIL;
    Vm_Obj tile			= OBJ_NIL;
    Vm_Obj ts_x			= OBJ_NIL;
    Vm_Obj ts_y			= OBJ_NIL;
 
    /* Make sure entire promised block is present: */
    Vm_Int i;
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(   block_len+2 );
    if (block_len & 1) {
	MUQ_WARN ("]create-gcontext argblock length must be even.");
    }

    /* Scan argument block for keywords: */
    for (i = 0;   i < block_len;   i += 2) {

	Vm_Int key_index  = i-block_len;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Arc_Mode) {
	} else if (key == job_Kw_Background) {
	    if (OBJ_IS_INT(val)) background=val;
	} else if (key == job_Kw_Cap_Style) {
	} else if (key == job_Kw_Clip_Mask) {
	} else if (key == job_Kw_Clip_Ordering) {
	} else if (key == job_Kw_Clip_X) {
	} else if (key == job_Kw_Clip_Y) {
	} else if (key == job_Kw_Dash_Offset) {
	} else if (key == job_Kw_Dashes) {
	} else if (key == job_Kw_Drawable) {
	    if (OBJ_IS_OBJ(val)&&OBJ_IS_CLASS_XWD(val)) drawable=val;
	} else if (key == job_Kw_Exposures) {
	} else if (key == job_Kw_Fill_Rule) {
	} else if (key == job_Kw_Fill_Style) {
	} else if (key == job_Kw_Font) {
	    if (OBJ_IS_OBJ(val)&&OBJ_IS_CLASS_XFT(val)) font=val;
	} else if (key == job_Kw_Foreground) {
	    if (OBJ_IS_INT(val)) foreground=val;
	} else if (key == job_Kw_Function) {
	} else if (key == job_Kw_Join_Style) {
	} else if (key == job_Kw_Line_Style) {
	} else if (key == job_Kw_Line_Width) {
	} else if (key == job_Kw_Plane_Mask) {
	} else if (key == job_Kw_Stipple) {
	} else if (key == job_Kw_Subwindow_Mode) {
	} else if (key == job_Kw_Tile) {
	} else if (key == job_Kw_Ts_X) {
	} else if (key == job_Kw_Ts_Y) {
	} else {
	    MUQ_WARN ("Unsupported ]create-gcontext keyword");
    }	}	

    if (drawable == OBJ_NIL) {
	MUQ_WARN ("Unsupported ':drawable' value in ]create-gcontext");
    }

    gcontext = xgc_Create_Gcontext(
	arc_mode,
	background,
	cap_style,
	clip_mask,
	clip_ordering,
	clip_x,
	clip_y,
	dash_offset,
	dashes,
	drawable,
	exposures,
	fill_rule,
	fill_style,
	font,
	foreground,
	function,
	join_style,
	line_style,
	line_width,
	plane_mask,
	stipple,
	subwindow_mode,
	tile,
	ts_x,
	ts_y
    );

    /* Pop block: */
    jS.s   -= block_len+2;

    /* Push result: */
    *++jS.s = gcontext;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Create_Window						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Create_Window(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    /* Return value: */
    Vm_Obj xwd;

    /* Supported keyword parameters: */
    Vm_Obj background		= OBJ_NIL;
    Vm_Obj backing_pixel	= OBJ_NIL;
    Vm_Obj backing_planes	= OBJ_NIL;
    Vm_Obj backing_store	= OBJ_NIL;
    Vm_Obj bit_gravity		= OBJ_NIL;
    Vm_Obj border		= OBJ_NIL;
    Vm_Obj border_width		= OBJ_FROM_INT(0);
    Vm_Obj class		= job_Kw_Copy;
    Vm_Obj colormap		= OBJ_NIL;
    Vm_Obj cursor		= OBJ_NIL;
    Vm_Obj depth		= OBJ_FROM_INT(0);
    Vm_Obj do_not_propagate_mask= OBJ_NIL;
    Vm_Obj event_mask		= OBJ_NIL;
    Vm_Obj gravity		= OBJ_NIL;
    Vm_Obj height		= OBJ_NIL;
    Vm_Obj override_redirect	= OBJ_NIL;
    Vm_Obj parent		= OBJ_NIL;
    Vm_Obj save_under		= OBJ_NIL;
    Vm_Obj visual		= job_Kw_Copy;
    Vm_Obj width		= OBJ_NIL;
    Vm_Obj x			= OBJ_NIL;
    Vm_Obj y			= OBJ_NIL;
 
    /* Make sure entire promised block is present: */
    Vm_Int i;
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(   block_len+2 );
    if (block_len & 1) {
	MUQ_WARN ("]create-window argblock length must be even.");
    }

    /* Scan argument block for keywords: */
    for (i = 0;   i < block_len;   i += 2) {

	Vm_Int key_index  = i-block_len;
	Vm_Int val_index  = key_index +1;
        Vm_Obj key        = jS.s[ key_index ];
        Vm_Obj val        = jS.s[ val_index ];

	if        (key == job_Kw_Background) {
	    if (OBJ_IS_INT(val))   background = val;
	} else if (key == job_Kw_Backing_Pixel) {
/*	    backing_pixel = val; */
	} else if (key == job_Kw_Backing_Planes) {
/*	    backing_planes = val; */
	} else if (key == job_Kw_Backing_Store) {
/*	    backing_store = val; */
	} else if (key == job_Kw_Bit_Gravity) {
/*	    bit_gravity = val; */
	} else if (key == job_Kw_Border) {
/*	    border = val; */
	} else if (key == job_Kw_Border_Width) {
/*	    border_width = val; */
	} else if (key == job_Kw_Class) {
	    class = val;
	} else if (key == job_Kw_Colormap) {
/*	    colormap = val; */
	} else if (key == job_Kw_Cursor) {
/*	    cursor = val; */
	} else if (key == job_Kw_Depth) {
/*	    depth = val; */
	} else if (key == job_Kw_Do_Not_Propagate_Mask) {
/*	    do_not_propagate_mask = val; */
	} else if (key == job_Kw_Event_Mask) {
	    if (OBJ_IS_INT(val))   event_mask = val;
	} else if (key == job_Kw_Gravity) {
/*	    gravity = val; */
	} else if (key == job_Kw_Height) {
	    if (OBJ_IS_INT(val))   height = val;
	} else if (key == job_Kw_Override_Redirect) {
/*	    override_redirect = val; */
	} else if (key == job_Kw_Parent) {
	    if (OBJ_IS_OBJ(val) && OBJ_IS_CLASS_XWD(val))  parent = val;
	} else if (key == job_Kw_Save_Under) {
/*	    save_under = val; */
	} else if (key == job_Kw_Visual) {
/*	    visual = val; */
	} else if (key == job_Kw_Width) {
	    if (OBJ_IS_INT(val))   width = val;
	} else if (key == job_Kw_X) {
	    if (OBJ_IS_INT(val))   x = val;
	} else if (key == job_Kw_Y) {
	    if (OBJ_IS_INT(val))   y = val;
	} else {
	    MUQ_WARN ("Unsupported ]create-window keyword");
    }	}	

    if (parent == OBJ_NIL) {
	MUQ_WARN ("Unsupported ':parent' value in ]create-window");
    }
    if (x == OBJ_NIL) {
	MUQ_WARN ("Unsupported ':x' value in ]create-window");
    }
    if (y == OBJ_NIL) {
	MUQ_WARN ("Unsupported ':y' value in ]create-window");
    }
    if (width == OBJ_NIL) {
	MUQ_WARN ("Unsupported ':width' value in ]create-window");
    }
    if (height == OBJ_NIL) {
	MUQ_WARN ("Unsupported ':height' value in ]create-window");
    }

    xwd = xwd_Create_Window(
        background,
        backing_pixel,
        backing_planes,
        backing_store,
        bit_gravity,
        border,
        border_width,
        class,
        colormap,
        cursor,
        depth,
        do_not_propagate_mask,
        event_mask,
        gravity,
        height,
        override_redirect,
        parent,
        save_under,
        visual,
        width,
        x,
        y
    );

    /* Pop block: */
    jS.s   -= block_len+2;

    /* Push result: */
    *++jS.s = xwd;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Destroy_Subwindows					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Destroy_Subwindows(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    xwd_Destroy_Subwindows( *jS.s );
    --jS.s;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Destroy_Window						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Destroy_Window(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    xwd_Destroy_Window( *jS.s );
    --jS.s;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Display_Roots						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Display_Roots(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    Vm_Obj display = *jS.s;

    job_Guarantee_Xdp_Arg(   0 );
    job_Must_Control_Object( 0 );
    {   Vm_Int count = xdp_Screen_Count( display );
	Vm_Int i;
	*jS.s = OBJ_BLOCK_START;
	for (i = 0;  i < count;  ++i) {
	    jS.s[1] = xdp_Screen_Of_Display( display, i );
	    ++jS.s;
	}
	*++jS.s   = OBJ_FROM_BLK(count);
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Drawable_Border_Width					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Drawable_Border_Width(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    {   Vm_Obj result = xwd_Drawable_Border_Width( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Drawable_Depth						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Drawable_Depth(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    {   Vm_Obj result = xwd_Drawable_Depth( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Drawable_Display						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Drawable_Display(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    {   Vm_Obj result = xwd_Drawable_Display( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Drawable_Height						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Drawable_Height(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    {   Vm_Obj result = xwd_Drawable_Height( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Drawable_Width						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Drawable_Width(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    {   Vm_Obj result = xwd_Drawable_Width( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Drawable_X						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Drawable_X(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    {   Vm_Obj result = xwd_Drawable_X( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Drawable_Y						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Drawable_Y(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    {   Vm_Obj result = xwd_Drawable_Y( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Draw_Glyphs						*/
 /***********************************************************************/

  /***********************************************************************/
  /*-	draw_glyphs							*/
  /***********************************************************************/

#ifdef HAVE_X11
static void
draw_glyphs(
    Vm_Int image
) {
    GC       gc;
    Vm_Obj   xdp;
    Vm_Obj   xsc;
    Display* display;
    Window   window;

    /* Mandatory arguments: */
    Vm_Obj drawable;
    Vm_Obj gcontext;
    Vm_Obj x;
    Vm_Obj y;
    Vm_Obj string;
    Vm_Uch buf[ MAX_STRING ];

    /* Make sure entire promised block is present: */
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(   block_len+2 );

    if (block_len != 5) {
	MUQ_WARN ("]draw%s-glyphs block must be length 5",
	    image ? "-image" : ""
	);
    }

    drawable = jS.s[ 0 - block_len ];
    gcontext = jS.s[ 1 - block_len ];
    x        = jS.s[ 2 - block_len ];
    y        = jS.s[ 3 - block_len ];
    string   = jS.s[ 4 - block_len ];

    if (!OBJ_IS_OBJ(drawable) || !OBJ_IS_CLASS_XWD(drawable)) {
	MUQ_WARN ("draw%s-glyphs drawable must be a window",
	    image ? "-image" : ""
	);
    }
    if (!OBJ_IS_OBJ(gcontext) || !OBJ_IS_CLASS_XGC(gcontext)) {
	MUQ_WARN ("draw%s-glyphs gcontext must be a gcontext",
	    image ? "-image" : ""
	);
    }
    if (!OBJ_IS_INT(x)) {
	MUQ_WARN ("draw%s-glyphs x must be an integer",
	    image ? "-image" : ""
	);
    }
    if (!OBJ_IS_INT(y)) {
	MUQ_WARN ("draw%s-glyphs y must be an integer",
	    image ? "-image" : ""
	);
    }
    if (!stg_Is_Stg(string)) {
	MUQ_WARN ("draw%s-glyphs sequence must be a string",
	    image ? "-image" : ""
	);
    }

#ifdef SOON
    /* Scan argument block for keywords: */
    {   Vm_Int i;
	for (i = 5;   i < block_len;   i += 2) {

	    Vm_Int key_index  = i-block_len;
	    Vm_Int val_index  = key_index +1;
	    Vm_Obj key        = jS.s[ key_index ];
	    Vm_Obj val        = jS.s[ val_index ];

	    if      (key==job_Kw_button_1_motion) m |= Button1MotionMask;
	    else if (key==job_Kw_button_2_motion) m |= Button2MotionMask;
	    else {
		MUQ_WARN ("Unsupported ]draw%s-glyphs keyword"
		    image ? "-image" : ""
		);
    }	}   }
#endif

    {   /* Load 'string' contents into buf[]: */
	Vm_Int len = stg_Len( string );
	if (len >= MAX_STRING)MUQ_WARN ("draw-image-glyphs: string too big");
	if (len != stg_Get_Bytes( buf , MAX_STRING, string, 0 )){
	    MUQ_WARN ("draw-image-glyphs: internal error");
	}

	/* Locate X11 display and window: */
	{   Xwd_P x = XWD_P(drawable);
	    window  = xwd_X11_Window[ OBJ_TO_INT( x->id ) ];
	    xsc     = x->screen;
	}
	xdp     = XSC_P(xsc)->display;
	display = xdp_Display[ OBJ_TO_INT( XDP_P(xdp)->id ) ];

	gc      = xgc_X11_Gcontext[ OBJ_TO_INT( XGC_P(gcontext)->id ) ];

	/* Do the draw: */
	if (image) {
	    XDrawImageString(
		display, window,
		gc,
		OBJ_TO_INT(x), OBJ_TO_INT(y),
		buf, len
	    );
	} else {
	    XDrawString(
		display, window,
		gc,
		OBJ_TO_INT(x), OBJ_TO_INT(y),
		buf, len
	    );
    }   }

    /* Pop block: */
    jS.s   -= block_len+2;

    /* Push results: */
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;
}
#endif

#ifdef MAYBE_SOMEDAY
void
job_P_Draw_Glyphs(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    draw_glyphs( FALSE );

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Draw_Image_Glyphs						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Draw_Image_Glyphs(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    draw_glyphs( TRUE );

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Font_Ascent						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Font_Ascent(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xft_Arg(   0 );
    job_Must_Control_Object( 0 );
    
    {   Vm_Obj result = xft_Font_Ascent( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Font_Descent						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Font_Descent(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xft_Arg(   0 );
    job_Must_Control_Object( 0 );
    
    {   Vm_Obj result = xft_Font_Descent( *jS.s );
	*jS.s = result;
    }

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Flush_Display						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Flush_Display(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xdp_Arg(   0 );
    job_Must_Control_Object( 0 );
    
    xdp_Flush_Display( jS.s[0] );
    --jS.s;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Gcontext_Background					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Gcontext_Background(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xgc_Arg(    0 );
    job_Must_Control_Object(  0 );
    *jS.s = xgc_Background(*jS.s);

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Gcontext_Font						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Gcontext_Font(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xgc_Arg(    0 );
    job_Must_Control_Object(  0 );
    *jS.s = xgc_Font(      *jS.s);

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Gcontext_Foreground					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Gcontext_Foreground(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xgc_Arg(    0 );
    job_Must_Control_Object(  0 );
    *jS.s = xgc_Foreground(*jS.s);

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Make_Event_Mask						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Make_Event_Mask(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    Vm_Int m = 0; /* Result mask. */

    /* Make sure entire promised block is present: */
    Vm_Int i;
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(   block_len+2 );

    /* Scan argument block for keywords: */
    for (i = 0;   i < block_len;   i++) {

	Vm_Int key_index  = i-block_len;
        Vm_Obj key        = jS.s[ key_index ];

	if      (key==job_Kw_Button_1_Motion) m |= Button1MotionMask;
        else if (key==job_Kw_Button_2_Motion) m |= Button2MotionMask;
        else if (key==job_Kw_Button_3_Motion) m |= Button3MotionMask;
        else if (key==job_Kw_Button_4_Motion) m |= Button4MotionMask;
        else if (key==job_Kw_Button_5_Motion) m |= Button5MotionMask;
        else if (key==job_Kw_Button_Motion  ) m |= ButtonMotionMask;
        else if (key==job_Kw_Button_Press   ) m |= ButtonPressMask;
        else if (key==job_Kw_Button_Release ) m |= ButtonReleaseMask;
        else if (key==job_Kw_Colormap_Change) m |= ColormapChangeMask;
        else if (key==job_Kw_Enter_Window   ) m |= EnterWindowMask;
        else if (key==job_Kw_Exposure       ) m |= ExposureMask;
        else if (key==job_Kw_Focus_Change   ) m |= FocusChangeMask;
        else if (key==job_Kw_Key_Press      ) m |= KeyPressMask;
        else if (key==job_Kw_Key_Release    ) m |= KeyReleaseMask;
        else if (key==job_Kw_Keymap_State   ) m |= KeymapStateMask;
        else if (key==job_Kw_Leave_Window   ) m |= LeaveWindowMask;
        else if (key==job_Kw_Owner_Grab_Button)m|= OwnerGrabButtonMask;
        else if (key==job_Kw_Pointer_Motion ) m |= PointerMotionMask;
        else if (key==job_Kw_Pointer_Motion_Hint)m|=PointerMotionHintMask;
        else if (key==job_Kw_Property_Change) m |= PropertyChangeMask;
        else if (key==job_Kw_Resize_Redirect) m |= ResizeRedirectMask;
        else if (key==job_Kw_Structure_Notify)m |= StructureNotifyMask;
        else if (key==job_Kw_Substructure_Notify)m|=SubstructureNotifyMask;
        else if (key==job_Kw_Substructure_Redirect)m|=SubstructureRedirectMask;
        else if (key==job_Kw_Visibility_Change)m|= VisibilityChangeMask;
	else {
	    MUQ_WARN ("Unsupported ]make-event-mask keyword");
    }	}	

    /* Pop block: */
    jS.s   -= block_len+2;

    /* Push result: */
    *++jS.s = OBJ_FROM_INT( m );

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Map_Window						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Map_Window(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    xwd_Map_Window( *jS.s );

    --jS.s;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Map_Subwindows						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Map_Subwindows(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    xwd_Map_Subwindows( *jS.s );

    --jS.s;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Open_Display						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Open_Display(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Must_Be_Root();
    job_Guarantee_Stg_Arg(0);
    *jS.s = xdp_Open_Display( *jS.s );

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Open_Font							*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Open_Font(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    Vm_Obj font;

    job_Guarantee_Stg_Arg(    0 );
    job_Guarantee_Xdp_Arg(   -1 );
    job_Must_Control_Object( -1 );
    
    font = xdp_Open_Font( jS.s[-1], jS.s[0] );
    *--jS.s = font;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Query_Pointer						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Query_Pointer(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    Vm_Obj window = *jS.s;

    Vm_Obj x, y, same_screen_p, child, mask, root_x, root_y, root;

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    job_Guarantee_Headroom( 7 );
    
    xwd_Query_Pointer( window,
	&x, &y,
	&same_screen_p, &child, &mask,
	&root_x, &root_y,
	&root
    );

    *  jS.s = x;
    *++jS.s = y;
    *++jS.s = same_screen_p;
    *++jS.s = child;
    *++jS.s = mask;
    *++jS.s = root_x;
    *++jS.s = root_y;
    *++jS.s = root;

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Screen_Black_Pixel					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Screen_Black_Pixel(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    Vm_Obj screen = *jS.s;

    job_Guarantee_Xsc_Arg(   0 );
    job_Must_Control_Object( 0 );

    *jS.s = xsc_Black_Pixel( screen );

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Screen_Root						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Screen_Root(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    Vm_Obj screen = *jS.s;

    job_Guarantee_Xsc_Arg(   0 );
    job_Must_Control_Object( 0 );

    *jS.s = xsc_Screen_Root( screen );

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Screen_White_Pixel					*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Screen_White_Pixel(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    Vm_Obj screen = *jS.s;

    job_Guarantee_Xsc_Arg(   0 );
    job_Must_Control_Object( 0 );

    *jS.s = xsc_White_Pixel( screen );

    #endif
}
#endif


 /***********************************************************************/
 /*-	job_P_Text_Extents						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Text_Extents(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    XFontStruct *f;
    Vm_Obj   xdp;
    Display* display;
    Vm_Uch buf[ MAX_STRING ];

    /* Mandatory arguments: */
    Vm_Obj xft;
    Vm_Obj txt;

    /* Make sure entire promised block is present: */
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(   block_len+2 );

    if (block_len != 2) {
	MUQ_WARN ("]text-extents block must be length 2");
    }

    xft = jS.s[ 0 - block_len ];
    txt = jS.s[ 1 - block_len ];

    if (!OBJ_IS_OBJ(xft) || !OBJ_IS_CLASS_XFT(xft)) {
	MUQ_WARN ("text-extents 'font' must be a font");
    }
    if (!stg_Is_Stg(txt)) {
	MUQ_WARN ("text-extents 'sequence' must be a string");
    }

    /* We currently accept 4 values and return 8: */
    job_Guarantee_Headroom( 4 );

#ifdef SOON
    /* Scan argument block for keywords: */
    {   Vm_Int i;
	for (i = 5;   i < block_len;   i += 2) {

	    Vm_Int key_index  = i-block_len;
	    Vm_Int val_index  = key_index +1;
	    Vm_Obj key        = jS.s[ key_index ];
	    Vm_Obj val        = jS.s[ val_index ];

	    if      (key==job_Kw_button_1_motion) m |= Button1MotionMask;
	    else if (key==job_Kw_button_2_motion) m |= Button2MotionMask;
	    else {
		MUQ_WARN ("Unsupported ]text-extents keyword");
    }	}   }
#endif

    {   /* Load 'txt' contents into buf[]: */
	Vm_Int len = stg_Len( txt );
	if (len >= MAX_STRING)MUQ_WARN ("text-extents: string too big");
	if (len != stg_Get_Bytes( buf , MAX_STRING, txt, 0 )){
	    MUQ_WARN ("text-extents: internal error");
	}

	/* Locate X11 display and font: */
	{   Xft_P x = XFT_P(xft);
	    xdp     = x->display;
	    f       = xft_X11_Font[ OBJ_TO_INT( x->id ) ];
	}

	display = xdp_Display[ OBJ_TO_INT( XDP_P(xdp)->id ) ];

	/* Query the server. */
	/* (The R5.02 CLX code contrives to sometimes do */
	/* this locally without querying the server.)    */
	{   int         direction;
	    int         ascent;
	    int         descent;
	    XCharStruct overall;
	    XQueryTextExtents(
		display, f->fid, buf, len,
		&direction, &ascent, &descent, &overall
	    );

	    /* Pop block: */
	    jS.s   -= block_len+2;

	    /* Push results: */
	    *++jS.s = OBJ_FROM_INT( overall.width    );
	    *++jS.s = OBJ_FROM_INT( ascent           );
	    *++jS.s = OBJ_FROM_INT( descent          );
	    *++jS.s = OBJ_FROM_INT( overall.lbearing );
	    *++jS.s = OBJ_FROM_INT( overall.rbearing );
	    *++jS.s = OBJ_FROM_INT( overall.ascent   );
	    *++jS.s = (
		direction==FontLeftToRight ?
		job_Kw_Left_To_Right       :
		job_Kw_Right_To_Left       
	    );
	    *++jS.s = OBJ_NIL;
    }	}

    #endif
}
#endif

 /***********************************************************************/
 /*-	job_P_Unmap_Subwindows						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Unmap_Subwindows(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    xwd_Unmap_Subwindows( *jS.s );
    --jS.s;

    #endif
}
#endif


 /***********************************************************************/
 /*-	job_P_Unmap_Window						*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_P_Unmap_Window(
    void
){
    #ifndef HAVE_X11
    no_x11();
    #else

    job_Guarantee_Xwd_Arg(   0 );
    job_Must_Control_Object( 0 );

    xwd_Unmap_Window( *jS.s );
    --jS.s;

    #endif
}
#endif




/************************************************************************/
/*-    Public fns, mostly print-related.				*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_Guarantee_Loop_Headroom -- Provide 'n' slots on loop stack.	*/
 /***********************************************************************/

void
job_Guarantee_Loop_Headroom(
    Vm_Int n
) {
    if (jS.l+n >= jS.l_top) {

	/* Insufficient room, time to expand. */

	/* Update loop_stack's internal sp, so */
	/* stk.c will know what size it is:    */
	{   Stk_P  s  = STK_P( jS.j.loop_stack );
	    s->length = OBJ_FROM_INT( 1 + jS.l - jS.l_bot );
	    vm_Dirty( jS.j.loop_stack );
	}

	/* Call stk to expand loop_stack appropriately: */
        {   Vm_Int fm = jS.v - jS.l_bot;	/* Remember stackframe offset. */
            Vm_Int ok = stk_Got_Headroom( jS.j.loop_stack, n );

	    {   /* Update hard pointers into loop_vector: */
		Vm_Int len;
		Vm_Int siz;
		Vm_Obj vec;
		{   Stk_P  s	= STK_P( jS.j.loop_stack );
		    len		= OBJ_TO_INT( s->length  );
		    vec		=             s->vector   ;
		}
		siz    = vec_Len( vec );
		{   Vec_P  v	= VEC_P( vec );
		    jS.l_bot = &v->slot[       0 ];
		    jS.l     = &v->slot[ len - 1 ];
		    jS.l_top = &v->slot[ siz - 1 ]; /* '-1' needed?*/
		    jS.v     = jS.l_bot + fm;
		 }

		/* Note new stack vector: */
		jS.loop_vector  = vec;
	    }
	    if (!ok)   job_Loop_Overflow();
    }   }
}

 /***********************************************************************/
 /*-    job_Got_Headroom -- True if we have 'n' free data stack slots	*/
 /***********************************************************************/

Vm_Int
job_Got_Headroom(
    Vm_Unt n
) {
    /**********************************************/
    /* Since we don't know how far we are through */
    /* the current timeslice, we have to provide  */
    /* room not only for the current slow opcode  */
    /* to push 'n' items, but potentially for     */
    /* JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP fast	  */
    /* opcodes to blindly push an item also:	  */
    /**********************************************/
    if (jS.s + (n + JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP)
    >=  jS.s_top
    ) {
	/* Insufficient room, time to expand. */

	/* Update data_stack's internal sp, so */
	/* stk.c will know what size it is:    */
	Vm_Int sbot   = (jS.s_bot - jS.s_0);
	{   Stk_P  s  = STK_P( jS.j.data_stack );
	    s->length = OBJ_FROM_INT( 1 + jS.s - jS.s_0 );
	    vm_Dirty( jS.j.data_stack );
	    vm_Dirty( jS.data_vector  ); /* Just in case otherfolks have it. */
	}

	/* Call stk to expand data_stack appropriately: */
        {   Vm_Int ok = stk_Got_Headroom(
		jS.j.data_stack,
	        n + JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP
            );

	    {   /* Update hard pointers into data_vector: */
		Vm_Int sp ;
		Vm_Int len;
		Vm_Obj vec;
		{   Stk_P  s	= STK_P( jS.j.data_stack );
		    sp		= OBJ_TO_INT( s->length );
		    vec		=             s->vector  ;
		}
		len    = vec_Len( vec );
		{   Vec_P  v	= VEC_P( vec );
		    jS.s_0   = &v->slot[       0 ];
		    jS.s_bot = &v->slot[ sbot    ];
		    jS.s     = &v->slot[ sp  - 1 ];
		    jS.s_top = &v->slot[ len - 1 ]; /* '-1' needed?*/
		 }

		/* Note new stack vector: */
		jS.data_vector  = vec;
	    }
	    if (!ok)   return FALSE;
    }   }
    return TRUE;
}

 /***********************************************************************/
 /*-    job_Guarantee_Headroom -- Provide 'n' slots on data stack.	*/
 /***********************************************************************/

void
job_Guarantee_Headroom(
    Vm_Unt n
) {
    if (!job_Got_Headroom(n)) {
	Vm_Int full_slots = jS.s - jS.s_bot;
        if (obj_Stackslots_Popped_After_Data_Stack_Overflow < full_slots) {
	    jS.s -= obj_Stackslots_Popped_After_Data_Stack_Overflow;
	} else {
	    jS.s  = jS.s_bot;
	}
        MUQ_WARN ("Data stack overflow");
    }
}

 /***********************************************************************/
 /*-    job_Run -- Run 'job' for 'lim' instructions max.		*/
 /***********************************************************************/

/* We return zero if no errors were encountered, */
/* else a diagnostic.				*/

static Vm_Int ops_initial;
static Vm_Int ops_left;
static Vm_Int ops_done_this_timeslice;

#ifdef PERFORMANCE_FIDDLING
Vm_Int jjj(int i) {
   int  j;
   for (j = 0;   j < i;) { ++j; --j; ++j; --j; ++j; }
   return j;
}
Vm_Int
job_Test(
   Vm_Int i
) {
time_t run_start = time(NULL);
    Vm_Int j = jjj(i);
{time_t run_stop = time(NULL);
time_t run_time = run_stop - run_start;
   printf(
     "\nNative C instr == %d   secs == %d   =>   MIPS == %f\n",
     (int)i, (int)run_time, ((float)i / (float)run_time) / 1000000.0
   );
}

    return j;
}
#endif

 /***********************************************************************/
 /*-    job_check_for_setjmp_bug -- See if setjmp is clobbering stuff.	*/
 /***********************************************************************/

#if MUQ_IS_PARANOID
static
void
job_check_for_setjmp_bug(
    void
) {

    /******************************************************/
    /* On one gcc 2.5.8 under SunOS 5.3, we appeared to   */
    /* be getting a setjmp() mismatched to <setjmp.h>,    */
    /* resulting in more than just the allocated jmp_buf  */
    /* getting set by setjmp(). This function is intended */
    /* to immediately catch any return of that bug:       */
    /******************************************************/

    /* Note that we cannot static-initialize pre/postguard, */
    /* that would move them to initialized storage, away    */
    /* from job_longjmp_buf:                                */
    job_longjmp_buf_preguard       = JOB_LONGJMP_BUF_PREGUARD ;
    job_longjmp_buf_postguard      = JOB_LONGJMP_BUF_POSTGUARD;

    setjmp( job_longjmp_buf );

    if (job_longjmp_buf_preguard  != JOB_LONGJMP_BUF_PREGUARD
    ||  job_longjmp_buf_postguard != JOB_LONGJMP_BUF_POSTGUARD
    ){
        MUQ_FATAL ("setjmp() is clobbering globals!");
    }
}
#endif

 /***********************************************************************/
 /*-    job_next_runnable -- Find next runnable job			*/
 /***********************************************************************/

static Vm_Obj
job_next_runnable(
    void
) {
    /* If owner of jS.job is in user queue, */
    /* remove and then insert again. This   */
    /* serves to rotate users through the   */
    /* user queue, implementing a round-    */
    /* robin by user scheduling. Obviously, */
    /* we can skip this when < 2 people are */
    /* in the queue:                        */
    if (OBJ_IS_OBJ(jS.job)
    &&  OBJ_IS_CLASS_JOB(jS.job)
    ){
        Vm_Obj usr = JOB_P(jS.job)->owner;
	Vm_Obj nxt = USR_P(usr)->next;
	Vm_Obj prv = USR_P(usr)->next;
	{   Usr_P u= USR_P(usr);
	    nxt    = u->next;
	    prv    = u->prev;
	}
	if (nxt != OBJ_FROM_INT(0)  /* Queue has > 0 entries. */
	&&  nxt != prv		    /* Queue has > 1 entry.   */
	){
	    #if MUQ_IS_PARANOID
	    if (!OBJ_IS_OBJ(nxt)
	    || (!OBJ_IS_CLASS_USQ(nxt)	&&
		!OBJ_ISA_USR(     nxt)
		)
	    ){
		MUQ_FATAL ("job_next_runnable/b");
	    }
	    #endif
	    usq_Dequeue( usr );
	    usq_Enqueue( usr );
	}
    }    

    /* Over all users in user queue, do: */
    /* If user has a runnable job, move  */
    /* job from front to back of run-    */
    /* queue (to implement round-robin   */
    /* alternation) and return it, else  */
    /* remove user from user queue:      */
    for (;;) {
	Vm_Obj q0;
	Vm_Obj q1;
	Vm_Obj q2;
	Vm_Obj j0;
	Vm_Obj j1;
	Vm_Obj j2;
	Vm_Int ts;

	/* If no users left in user queue, give up: */
	Vm_Obj usr = USQ_P(obj_Etc_Usr)->next;
	#if MUQ_IS_PARANOID
	if (!OBJ_IS_OBJ(usr)
	|| (!OBJ_IS_CLASS_USQ(usr)	&&
	    !OBJ_ISA_USR(     usr)
	    )
	){
	    MUQ_FATAL ("job_next_runnable/c");
	}
	#endif
	if (OBJ_IS_CLASS_USQ(usr)) {
	    return OBJ_NIL;
	}

	/* Fetch relevant info from this user, update timeslice: */
	{   /* Fetch relevant info from this user: */
	    Usr_P u = USR_P(usr);
	    q0 = u->run_q[0];
	    q1 = u->run_q[1];
	    q2 = u->run_q[2];
	    ts = OBJ_TO_INT( u->time_slice );
	    u->time_slice = OBJ_FROM_INT( ts+1 );
	    vm_Dirty(usr);
	}

	/* Run priority 0 job if available, else */
	/* run priority 1 job if available, else */
	/* run priority 2 job if available, but  */
	/* if a lower priority job is avalable,  */
	/* run it 1/8 of the time, just to avoid */
	/* disastrous lockups.  Yes, the code is */
	/* ugly -- got a prettier formulation?   */
	#undef  JOB
	#define JOB(j) (OBJ_IS_OBJ(j) && OBJ_IS_CLASS_JOB(j))
	#undef  DO
	#define DO(j,q) {joq_Requeue(q,j);return j;}
	j0 = JOQ_P(q0)->link.next.o;
	if (JOB(j0)) {
	    if (ts & 0x7) DO(j0,q0);
	    j1 = JOQ_P(q1)->link.next.o;
	    if (JOB(j1)) {
		if (ts & 0x3F) DO(j1,q1)
		j2 = JOQ_P(q2)->link.next.o;
		if (JOB(j2))   DO(j2,q2)
		else           DO(j1,q1)
	    }
	    j2 = JOQ_P(q2)->link.next.o;
	    if (JOB(j2)) DO(j2,q2)
	    else         DO(j0,q0)
	}
	j1 = JOQ_P(q1)->link.next.o;
	if (JOB(j1)) {
	    if (ts & 0x7) DO(j1,q1)
	    j2 = JOQ_P(q2)->link.next.o;
	    if (JOB(j2))  DO(j2,q2)
	    else          DO(j1,q1)
	}
	j2 = JOQ_P(q2)->link.next.o;
	if (JOB(j2)) {
	    DO(j2,q2)
	}

	/* No runnable jobs on this user, so */
	/* remove user from user queue, then */
	/* loop around to try next user:     */
	usq_Dequeue( usr );
    }
}

#ifdef NASTY
/* Some stuff handy for tracking down really */
/* nasty server bugs.  You put a call to     */
/* job_log_instruction() in JOB_NEXT and     */
/* job_run(), then when it blows up, call    */
/* job_print_instruction_log() to find out   */
/* what 127 instructions preceded the crash. */
/* The JOB_NEXT patch should look about like */
/* fputs("jS.pc=jSpc;jS.s=jSs;{extern void\\\n",fd);*/
/* fputs(" job_log_instruction(void);}\\\n",fd);    */

Vm_Int recent_pcs[ 128 ];
Vm_Uch recent_op0[ 128 ];
Vm_Uch recent_op1[ 128 ];
Vm_Uch recent_op2[ 128 ];
Vm_Uch recent_op2[ 128 ];
Vm_Int recent_s[   128 ];
Vm_Obj recent_x[   128 ];
Vm_Int xxslot = 0;
void job_log_instruction(void){
    recent_pcs[ xxslot ] =  jS.pc-(Vm_Uch*)vm_Loc(jS.x_obj);
    recent_op0[ xxslot ] =  jS.pc[0];
    recent_op1[ xxslot ] =  jS.pc[1];
    recent_op2[ xxslot ] =  jS.pc[2];
    recent_s  [ xxslot ] =  jS.s-jS.s_0;
    recent_x  [ xxslot ] =  jS.x_obj;
    xxslot = (xxslot+1)&0x7F;
}
void job_print_instruction_log(void){

    /* Print current address and opcode: */
    Cfn_P   x  = CFN_P( job_RunState.x_obj      );
    Vm_Uch* x0 = (Vm_Uch*) &x->vec[ CFN_CONSTS(x->bitbag) ]; /* Address zero in exe. */
    fprintf(
	stdout,
	"j:%" VM_X" x:%" VM_X " pc:%03" VM_X " l:%02" VM_X " s:%" VM_X ">: ",
	jS.job,
	jS.x_obj,
	(Vm_Unt)(jS.pc-x0),
	(Vm_Unt)(jS.l-jS.l_bot),
	(Vm_Unt)(jS.s-jS.s_bot)
    );

    jS.s = jS.s; job_State_Update();

    {   Vm_Uch buf[ MAX_STRING ];
        Vm_Uch*end = stk_Sprint1(buf, buf+MAX_STRING, jS.j.data_stack );
	*end = '\0';
	fputs(buf,stdout);
    }
    printf("\njob_run_count x=%" VM_X "\n",job_run_count);
    {   Vm_Int i; for (i = 0;   i < 128;   ++i) {
	xxslot = (xxslot+1)&0x7F;
	printf(
	    "%02" VM_X ": pc %03" VM_X" *pc %02" VM_X " %02" VM_X " %02" VM_X " x %08" VM_X " s %04" VM_X "\n",
	    i,	(Vm_Unt)
	    recent_pcs[xxslot],
	    recent_op0[xxslot],
	    recent_op1[xxslot],
	    recent_op2[xxslot],
	    recent_x  [xxslot],
	    recent_s  [xxslot]
        );
}   }
#endif

 /***********************************************************************/
 /*-    job_Is_Idle -- Muq run-awhile entrypoint from calling program.	*/
 /***********************************************************************/
#ifdef TEMP_DEBUG_HACK
void elapsed_time_check(char*what) {
if (job_Log_Bytecodes /*= (++job_Bytecodes_Logged>JOB_TRACE_BYTECODES_FROM)*/) {
static char* lastwhat="xxx";
static struct timeval before;
static struct timeval after;
static firsttime=TRUE;
gettimeofday(&after,NULL);
if (firsttime) {
  before=after;
}
{int  secdif = after.tv_sec -before.tv_sec ;
 int usecdif = after.tv_usec-before.tv_usec;
 usecdif += secdif*1000000;
 if (usecdif > 100) {
  printf("elapsed_time_check(%s): usecdif d=%d\n",lastwhat,usecdif);
}
}
before=after;
lastwhat=what;
}
}
#endif

/* The next is actually a parameter to job_Is_Idle. */
/* When it was a real parameter, gcc was warning    */
/* that the longjmp()s might clobber it, and rather */
/* than make it volatile -- I've heard of buggy C   */
/* compilers that mis-implement volatile -- I just  */
/* made it a global:                                */
Vm_Int job_Is_Idle_Usec = 0;
Vm_Int
job_Is_Idle( void 
) {
    ops_left            = job_Max_Bytecodes_Per_Timeslice  ;
    MUQ_NOTE_RANDOM_BITS( job_Max_Bytecodes_Per_Timeslice );

    /**********************************************/
    /* This fn is separate mostly to reduce the   */
    /* number of variables which longjmp() has    */
    /* an opportunity to trash somehow. Remember  */
    /* that longjmp() is allowed to trash all     */
    /* local variables not declared "volatile".   */
    /* Seems to me I've heard of C compilers that */
    /* go ahead and trash those too, just to be   */
    /* thorough ... *Grin*.			  */
    /**********************************************/

    job_End_Of_Timeslice = FALSE;

    /* Set up a longjmp() path back to us.  This */
    /* is used, e.g., by job_Warn(), which does  */
    /* appropriate error recovery before jumping */
    /* to us, so we just fall into the below     */
    /* loop whether or not this is an error      */
    /* return or regular return from setjmp():   */
    if (setjmp( job_longjmp_buf )) {
	/* job_Warn() or job_next() or job_schedule() */
        /* next() just longjmp()ed to us:             */
	ops_left                -= job_RunState.ops - ops_initial;
	ops_done_this_timeslice += job_RunState.ops - ops_initial;
	/* We're currently executing code, so we don't want */
	/* to sleep for a second or more just now just      */
	/* because there's no net I/O going on:             */
	job_Is_Idle_Usec = job_Max_Microseconds_To_Sleep_In_Busy_Select;
    }
    #if MUQ_IS_PARANOID
    job_longjmp_buf_is_valid = TRUE;
    #endif

    if (jS.job)   job_State_Unpublish();

    if (job_End_Of_Run) {
	return TRUE;
    }

    /* Maybe send/receive bytes via net sockets (etc): */
/* buggo, seems we should be checking how long until */
/* the next sleeping job wakes, and sleeping at most */
/* that long, but doesn't seem to be any such sort   */
/* of logic around at present.                       */
    (void) skt_Maybe_Do_Some_IO( job_Is_Idle_Usec );

    /* Update global 'now' variable.  We do this */
    /* here to avoid doing constant system calls */
    /* to find current time:                     */
    jS.now         = OBJ_FROM_UNT( job_Now() );

    /* Maybe do a backup: */
    {   Vm_Unt date_of_next_backup = OBJ_TO_UNT(MUQ_P(obj_Muq)->date_of_next_backup);
	if (date_of_next_backup
	&&  date_of_next_backup < OBJ_TO_UNT( jS.now )
	){
	    obj_Do_Backup();
	}
    }

    /* If any sleeping jobs are eligible */
    /* to run, move them to run queue:   */
    joq_Desleep();

    /* Return if run queue is empty, */
    /* otherwise publish first job:  */
    {   Vm_Obj nxt = job_next_runnable();
	if (nxt == OBJ_NIL) {
	    return TRUE;
	}
	job_State_Publish( nxt );
    }

    /* Run our process for awhile:  */
    while (
        !job_End_Of_Timeslice	&&
        ops_left > 0
    ) {
	/* Maybe do a garbage collection: */
	if (vm_Total_Bytes_Allocated_Since_Last_Garbage_Collection >
	    obj_Bytes_Between_Garbage_Collections
	){
	    vm_Set_Bytes_Allocated_Since_Last_Garbage_Collection(0,0);
	    obj_Collect_Garbage();
	}

	/*****************************************************/
	/* As a speed hack, we avoid checking for data stack */
	/* overflow during fast bytecodes by the simple	     */
	/* expedient of:				     */
	/*						     */
	/* 1) Executing no more than 			     */
        /*    JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP in a row;   */
	/*						     */
	/* 2) Pushing no more than one value in each;	     */
	/*						     */
	/* 3) Ensuring that we always have at least	     */
        /*    JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP free slots  */
	/*    on the stack at the top of each job_run loop.  */
	/*						     */
	/* Here is the check implementing (3), inlined from  */
	/* job_Got_Headroom():				     */
	/*****************************************************/
        if (jS.s + JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP   >=  jS.s_top) {
	    job_Guarantee_Headroom(0);
	}

	/* Set limit on number of bytecodes to execute: */
	if (ops_left > JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP) {
	    /* (Maybe) run max possible bytecodes this timeslice: */
	    ops_initial = JOB_OPS_COUNT_MASK - JOB_MAX_BYTECODES_PER_JOB_RUN_LOOP;
	} else {
	    /* Run at most requested number of bytecodes this timeslice: */
	    ops_initial = JOB_OPS_COUNT_MASK - ops_left;
	}

	job_RunState.ops = ops_initial;

        /* Switch on next line for a handy trace when debugging. */
	/* (See also JOB_NEXT in jobbuild.c) */
	#ifdef MUQ_TRACE
        if (job_Log_Bytecodes /*= (++job_Bytecodes_Logged>JOB_TRACE_BYTECODES_FROM)*/) {
            job_Print1(jS.pc,jS.s);
	}
	#endif

	((Job_Fast_Prim*)job_Fast_Table)[
	   *job_RunState.pc                     |
	   (job_Type1[job_RunState.s[-1]&0xFF]) |
	    job_Type0[job_RunState.s[ 0]&0xFF]
	](
            #if JOB_PASS_IN_PARAMETERS
	    job_RunState.s,
	    job_RunState.pc,
	    job_RunState.ops,
	    job_Fast_Table
            #endif
	);

	ops_left                -= job_RunState.ops - ops_initial;
	ops_done_this_timeslice += job_RunState.ops - ops_initial;
    }

    #if MUQ_IS_PARANOID
    job_longjmp_buf_is_valid = FALSE;
    #endif

    return FALSE;
}


#ifndef OLD

 /***********************************************************************/
 /*-    job_Print1   -- Print one-line state summary.			*/
 /***********************************************************************/

#if MUQ_DEBUG

void
job_Print1(
    Vm_Uch*  pc,
    Vm_Obj*  s
) {
    /* Print current address and opcode: */
    Cfn_P   x  = CFN_P( job_RunState.x_obj      );
    Vm_Uch* x0 = (Vm_Uch*) &x->vec[ CFN_CONSTS(x->bitbag) ]; /* Address zero in exe. */
    Vm_Uch buf0[ MAX_STRING+512 ];
    sprintf(buf0,
"(%" VM_D ") "
/*	"j:%" VM_X */ "x:%" VM_X " pc:%03" VM_X " l:%02" VM_X " s:%" VM_X ">: ",
++job_Bytecodes_Logged,
/*	jS.job, *//* Dropped 'cause lib_Log_String has it anyhow */
	jS.x_obj,
	(Vm_Unt) (pc-x0),
	(Vm_Unt) (jS.l-jS.l_bot),
	(Vm_Unt) (s-jS.s_bot)
    );
    sprintf(buf0+strlen(buf0),"%s\tstk:", asm_Disassemble_Opcode(pc) );

    #ifdef DELICATE_DEBUGGING_PROBLEM
    /* The following code provides less information */
    /* than the succeeding alternative code, but    */
    /* has the virtue of not disturbing activities  */
    /* in virtual memory, which can help when       */
    /* tracking down a pointer bug sensitive to any */
    /* change in the virtual memory trace.          */
    {   Vm_Obj*  p;
	Vm_Uch*buf = buf0+strlen(buf0)];
	Vm_Uch*lim = &buf0[ MAX_STRING ];
	for (p = jS.s_bot;   p <= s;   ++p) {
	    if (buf+2 >= lim)  MUQ_WARN ("job_Print1: buffer overflow");
	    *buf++ = ' ';
	    if (OBJ_IS_INT(*p)) {
		sprintf(buf," %" VM_D,OBJ_TO_INT(*p));
		buf += strlen(buf);
	    } else if (OBJ_IS_CFN(*p)) {
		sprintf(buf," <cfn %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_OBJ(*p)) {
		sprintf(buf," <obj %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_CONS(*p)) {
		sprintf(buf," <cons %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_SYMBOL(*p)) {
		sprintf(buf," <symbol %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_VEC(*p)) {
		sprintf(buf," <vec %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_BYTN(*p)) {
		sprintf(buf," <bytn %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_BYT0(*p)) {
		sprintf(buf," <byt0 %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_BYT1(*p)) {
		sprintf(buf," <byt1 %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_BYT2(*p)) {
		sprintf(buf," <byt2 %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_BYT3(*p)) {
		sprintf(buf," <byt3 %" VM_X ">",*p);
		buf += strlen(buf);
            #if VM_INTBYTES > 4
	    } else if (OBJ_IS_BYT4(*p)) {
		sprintf(buf," <byt4 %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_BYT5(*p)) {
		sprintf(buf," <byt5 %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_BYT6(*p)) {
		sprintf(buf," <byt6 %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_BYT7(*p)) {
		sprintf(buf," <byt7 %" VM_X ">",*p);
		buf += strlen(buf);
            #endif
	    } else if (OBJ_IS_BOTTOM(*p)) {
		sprintf(buf," <bottom>");
		buf += strlen(buf);
	    } else if (OBJ_IS_SPECIAL(*p)) {
		sprintf(buf," <special %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_EPHEMERAL_LIST(*p)) {
		sprintf(buf," <ephemeralCons %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_EPHEMERAL_OBJECT(*p)) {
		sprintf(buf," <ephemeral-object %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_EPHEMERAL_STRUCT(*p)) {
		sprintf(buf," <ephemeral-struct %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_EPHEMERAL_VECTOR(*p)) {
		sprintf(buf," <ephemeral-vector %" VM_X ">",*p);
		buf += strlen(buf);
	    } else if (OBJ_IS_CHAR(*p)) {
		sprintf(buf," '%c'",OBJ_TO_CHAR(*p));
		buf += strlen(buf);
	    } else if (OBJ_IS_BLK(*p)) {
		sprintf(buf," <blk %" VM_D ">",OBJ_TO_BLK(*p));
		buf += strlen(buf);
	    } else {
		sprintf(buf," <??? %" VM_X ">",*p);
		buf += strlen(buf);
	    }
	    *buf = '\0';
    	}
        lib_Log_String(buf0);
    }
    #else
    jS.s = s; job_State_Update();
    {   Vm_Uch*end = stk_Sprint1(buf0+strlen(buf0), buf0+MAX_STRING, jS.j.data_stack );
	*end = '\0';
	lib_Log_String(buf0);
    }
    #endif

/*  fputc( '\n', f ); */ /* lib_Log_String takes care of this */
}

#endif


#endif
 /***********************************************************************/
 /*-    job_Tprint_Vm_Obj -- Translate Vm_Obj to stg object, return stg.*/
 /***********************************************************************/

Vm_Obj
job_Tprint_Vm_Obj(
    Vm_Obj   j,
    Vm_Int   quote_strings
) {
    Vm_Uch buf[ JOB_MAX_LINE ];
    Vm_Int len = job_Sprint_Vm_Obj( buf, buf+JOB_MAX_LINE, j, quote_strings );
    return stg_From_Buffer( buf, len );
}

 /***********************************************************************/
 /*-    job_Print_Here -- List ~here, one line per prop.		*/
 /***********************************************************************/

#ifndef JOB_MAX_REASONABLE_KEY_NAME
#define JOB_MAX_REASONABLE_KEY_NAME (20)
#endif
void
job_Print_Here(
    FILE*  f,
    Vm_Obj here,
    Vm_Int all
) {
#ifdef SOON
    Vm_Int  keys_seen  = 0;
    Vm_Int  keys_shown = 0;
    fputc( '\n', f );
    if (OBJ_IS_OBJ( here )) {
	Vm_Obj  key  = obj_First_All( here );
	for ( ; key != OBJ_NOT_FOUND;   key = obj_Next_All( here, key )) {

	    /* Find the key's value: */
	    Vm_Obj val = OBJ_GET( here, key, OBJ_PROP_PUBLIC );

	    /* Print props starting with    */
	    /* '~'/'@'/'.' only when 'all': */
	    ++keys_seen;
	    if (all || !job_Is_Tilda_Atsign_Dot_Prop( key )) {

		/* Print key: */
		Vm_Int len = job_Print_Vm_Obj(f, key, /*quote_strings:*/TRUE);

		/* Print a nice separator: */
		{   Vm_Int i = JOB_MAX_REASONABLE_KEY_NAME - len;
		    while (i --> 0)   fputc( ' ', f );
		}

		/* Print val: */
		job_Print_Vm_Obj( f, val, /*quote_strings:*/TRUE );

		/* Newline: */
		fputc( '\n', f );

		if (!(++keys_shown % 5))   fputc( '\n', f );
	}   }

	if (keys_shown % 5)   fputc( '\n', f );
	job_Print_Vm_Obj( f, here, /*quote_strings:*/TRUE );
	if (keys_shown == keys_seen) {
	    fprintf(f, " has %d properties.\n", (int)keys_seen );
	} else {
	    fprintf(f,
		" has %d properties, %d displayed.\n",
	        (int)keys_seen, (int)keys_shown
	    );
	}

    } else if (OBJ_IS_CONS(here) || OBJ_IS_VEC(here)) {

	int i;
	int len = vec_Len( here );
	for (i = 0;   i < len;   ++i) {
	    Vm_Obj val = vec_Get( here, i );
	    fprintf(f, "%3d: ", i );
	    job_Print_Vm_Obj( f, val, /*quote_strings:*/TRUE );
	    fputc( '\n', f );
	}

    } else {
	job_Print_Vm_Obj( f, here, /*quote_strings:*/TRUE );
	fputc( '\n', f );
    }
#endif
}

 /***********************************************************************/
 /*-    job_Print_Jobs -- List /ps, one line per job.	       		*/
 /***********************************************************************/

void
job_Print_Jobs(
    FILE*  f
) {
#ifdef SOON
    Vm_Obj  pid = OBJ_NEXT( obj_Ps, OBJ_FIRST, OBJ_PROP_PUBLIC );
    fprintf(f,"PID PPID IS  OWNER\n");
    fprintf(f,"--- ---- --- -----\n");
    for ( ; pid != OBJ_NOT_FOUND;   pid = OBJ_NEXT( obj_Ps, pid, OBJ_PROP_PUBLIC )) {

	/* Job keys in /ps are integers (their pids). */
	/* We're not interested in other properties:  */
	if (OBJ_IS_INT( pid )) {

	    /* Find the job itself: */
	    Vm_Obj job = OBJ_GET( obj_Ps, pid, OBJ_PROP_PUBLIC );

	    /* Print PID for job: */
	    fprintf(f,"%3" VM_D, OBJ_TO_INT( pid ));

	    /* Make sure job IS a job: */
	    if ( !OBJ_IS_OBJ( job )   ||   !OBJ_IS_CLASS_JOB( job ) ) {
	        job_Print_Vm_Obj( f, job, /*quote_strings:*/TRUE );
	    } else {
		Vm_Obj mom = JOB_P(job)->parent;
		Vm_Obj joq = JOB_P(job)->q_this;
		Vm_Obj own = JOB_P(job)->o.creator;
		Vm_Obj is  = JOQ_P(joq)->o.objname;
	        if ( !OBJ_IS_OBJ( mom )   ||   !OBJ_IS_CLASS_JOB( mom ) ) {

		    /* Not a job, settle for printing its type: */
	            job_Print_Vm_Obj( f, mom, /*quote_strings:*/TRUE );

		} else {

	    	    /* Print PPID for job: */
	            fprintf(f,"%5" VM_D " ",OBJ_TO_INT(JOB_P(mom)->pid));
		}

		/* Print state of job:  run/doz/poz/stp/...  */
		/* This is just the name of the jobqueue it  */
		/* is in, except we make currently running   */
		/* job "RUN" instead of 'run':               */
		if (job == jS.job)   is = OBJ_FROM_BYT3('R','U','N');
	        job_Print_Vm_Obj( f, is, /*quote_strings:*/FALSE );

		/* Make sure owner of job is a USR object: */
	        fputc( ' ', f );
	        if ( !OBJ_IS_OBJ( own )   ||   !OBJ_ISA_USR( own ) ) {

		    /* Owner is something strange, just print it's type: */
	            job_Print_Vm_Obj( f, own, /*quote_strings:*/TRUE );

		} else {

		    /* Print name of owner of job: */
		    Vm_Obj nam = OBJ_P( own )->objname;
	            job_Print_Vm_Obj( f, nam, /*quote_strings:*/FALSE );
		}
            }
	    fputc( '\n', f );
    }   }
#endif
}

 /***********************************************************************/
 /*-    job_Sprint_Vm_Obj -- Translate Vm_Obj to human ascii.		*/
 /***********************************************************************/

Vm_Int
job_Sprint_Vm_Obj(
    Vm_Uch*  buf,
    Vm_Uch*  lim,	/* First char past end of 'buf'.	*/
    Vm_Obj   obj,
    Vm_Int   quote_strings
) {
    Vm_Uch* d   = buf;
    Vm_Int  typ = OBJ_TYPE(obj);
    *d = '\0';
    d = (*mod_Type_Summary[ typ ]->sprintW)( buf, lim, obj, quote_strings );
    *d = '\0';
    return d-buf;
}

 /***********************************************************************/
 /*-    job_Push_Int -- Push int on stack, with overflow check.		*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    job_Fatal -- Format an error message, coredump.			*/
 /***********************************************************************/

void
job_Fatal(
    Vm_Uch *format, ...
) {
    /* First, sprintf the error message */
    /* into a temporary buffer:         */
    va_list args;
    Vm_Uch buffer[8192];
    strcpy(buffer,"*****");	/* So we can grep logs for crashes. */
    va_start(args,     format);
    vsprintf(buffer+5, format, args);
    va_end(args);
    strcat(buffer,"\n");
    fputs(buffer,stderr);
    printf("job_Fatal(%s)...\n",buffer);
    abort();
}

 /***********************************************************************/
 /*-    job_End_Timeslice -- Switch to next runnable task.		*/
 /***********************************************************************/

/***********************************************/
/* Note: this fn is usually called because the */
/* current job has blocked waiting for some    */
/* resource.  If so, the caller should have    */
/* moved the job from /etc/run to the proper   */
/* wait queue, where it will stay until some-  */
/* one releases the resource and dumps all the */
/* jobs in that wait queue back into /etc/run. */
/*					       */
/* (Obviously, the interrupted instruction had */
/* better be restartable from this point!)     */
/***********************************************/

void
job_End_Timeslice(
    void
) {

    /* Tell job_Run() why we're longjmp()ing to it: */
    job_End_Of_Timeslice = TRUE;

    MUQ_NOTE_RANDOM_BITS( jS.j.actual_user );
    MUQ_NOTE_RANDOM_BITS( jS.j.acting_user );

    /* Jump back to job_Run(): */
    #if MUQ_IS_PARANOID
    if (!job_longjmp_buf_is_valid) MUQ_FATAL ("job_longjmp_buf invalid!");
    #endif
    longjmp( job_longjmp_buf, 1 );
}

 /***********************************************************************/
 /*-    job_Error -- Find CATCHer for preformatted error msg it.	*/
 /***********************************************************************/

void
job_Error(
    Vm_Uch *msg
) {
    Vm_Obj o = JOB_P(jS.job)->do_error;
    if (job_Log_Warnings)   lib_Log_String( msg );
    if (OBJ_IS_SYMBOL(o) && o!=OBJ_NIL)   o = job_Symbol_Function(o);
    if (!OBJ_IS_CFN(o)) {
	/* Bad @$s.doError! Give up and kill job: */
	job_end_job( jS.job );
	job_next();
    } else {
	if (job_Got_Headroom(2)) {
	    jS.s += 2;
	}
	jS.s[ 0] = stg_From_Asciz( msg );
	jS.s[-1] = obj_Err_Server_Error;
	/* Leave PC pointed at current instruction: */
	jS.instruction_len = 0;
	job_Call2(o);
    }

    /* Can't afford to 'return', since we */
    /* were called from some instruction  */
    /* that detected an error situation,  */
    /* so longjup back to job_Run():      */
    #if MUQ_IS_PARANOID
    if (!job_longjmp_buf_is_valid) MUQ_FATAL ("job_longjmp_buf invalid!");
    #endif
    longjmp( job_longjmp_buf, 1 );
}

 /***********************************************************************/
 /*-    job_Warn -- Format an error message, find CATCHer for it.	*/
 /***********************************************************************/

void
job_Warn(
    Vm_Uch *format, ...
) {
    /* First, sprintf the error message */
    /* into a temporary buffer:         */
    va_list args;
    Vm_Uch buffer[8192];
    va_start(args,   format);
    vsprintf(buffer, format, args);
    va_end(args);

    job_Error( buffer );
}

 /***********************************************************************/
 /*-    job_Guarantee_Xcl_Arg -- Error if arg 'n' isn't a xcl.		*/
 /***********************************************************************/


/* Commented out because nobody is working */
/* on completing the X support:            */
#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xcl_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XCL(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-color argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Xcm_Arg -- Error if arg 'n' isn't a xcm.		*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xcm_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XCM(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-colormap argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Xcr_Arg -- Error if arg 'n' isn't a xcr.		*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xcr_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XCR(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-cursor argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Xdp_Arg -- Error if arg 'n' isn't a xdp.		*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xdp_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XDP(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-display argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Xft_Arg -- Error if arg 'n' isn't a xft.		*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xft_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XFT(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-font argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Xgc_Arg -- Error if arg 'n' isn't a xwd.		*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xgc_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XGC(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-gcontext argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Xpx_Arg -- Error if arg 'n' isn't a xpx.		*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xpx_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XPX(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-pixmap argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Xsc_Arg -- Error if arg 'n' isn't a xsc.		*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xsc_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XSC(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-screen argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Xwd_Arg -- Error if arg 'n' isn't a xwd.		*/
 /***********************************************************************/

#ifdef MAYBE_SOMEDAY
void
job_Guarantee_Xwd_Arg(
    Vm_Int n
) {
    /* We trust caller to give us a valid offset: */
    register Vm_Obj*  c = &job_RunState.s[n];
    register Vm_Obj   o = *c;

    if (OBJ_IS_OBJ(o) && OBJ_IS_CLASS_XWD(o))   return;

    job_ThunkN(n);
    MUQ_WARN ("Needed x-window argument at top-of-stack[%d]", (int)n );
}
#endif

 /***********************************************************************/
 /*-    job_Guarantee_Nonempty_Stgblock -- Error if contains nonstring. */
 /***********************************************************************/

Vm_Int
job_Guarantee_Nonempty_Stgblock(
    void
) {
    /* We trust caller to give us a valid offset: */
    Vm_Obj   o = *jS.s;
    Vm_Int   i;
    Vm_Int   lim;
    
    if (!OBJ_IS_BLK(o)) {
	MUQ_WARN ("Needed block of strings at top-of-stack" );
    }
    /* Check that all elements of block are stgs. */
    /* Iterate from zeronear end of range so that */
    /* we will hit the underflow entries before   */
    /* overindexing stack:                        */
    for (i = 1, lim = OBJ_TO_BLK(o);   i <= lim;   ++i) {
	o = jS.s[-i];
        if (!stg_Is_Stg(o)) {
	    job_ThunkN(-i);
	    MUQ_WARN ("Needed string argument at top-of-stack[%d]", (int)-i );
    }	}
    return lim;
}

 /***********************************************************************/
 /*-    job_Must_Be_Root -- Error if acting_user isn't rootpriv.        */
 /***********************************************************************/

void
job_Must_Be_Root(
    void
) {
    if (OBJ_IS_CLASS_ROT(jS.j.acting_user)) return;
    MUQ_WARN ("@$s.actingUser must be .u[\"root\"] to do this instruction");
}

 /***********************************************************************/
 /*-    job_Controls_ -- 						*/
 /***********************************************************************/

Vm_Int
job_Controls(
    Vm_Obj  o
) {
    /* We say a job 'controls' an object if it is entitled */
    /* to modify that object.  Currently, a job controls   */
    /* an object if acting_user owns the object, or if     */
    /* the job is running with the OMNIPOTENT bit set:     */
    if ((jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(jS.j.acting_user)
    ){
        return TRUE;
    }

    switch (OBJ_TYPE(o)) {

    case OBJ_TYPE_SPECIAL:
    case OBJ_TYPE_FLOAT  :
    case OBJ_TYPE_INT    :
    case OBJ_TYPE_BOTTOM :
    case OBJ_TYPE_BYT0   :
    case OBJ_TYPE_BYT1   :
    case OBJ_TYPE_BYT2   :
    case OBJ_TYPE_BYT3   :
    #if VM_INTBYTES > 4
    case OBJ_TYPE_BYT4:
    case OBJ_TYPE_BYT5:
    case OBJ_TYPE_BYT6:
    case OBJ_TYPE_BYT7:
    #endif
    case OBJ_TYPE_CHAR   :
    case OBJ_TYPE_BLK    :
	/* Nobody can modify immediate types: */
	return FALSE;

    case OBJ_TYPE_THUNK  :
    case OBJ_TYPE_CFN    :
    case OBJ_TYPE_OBJ    :
    case OBJ_TYPE_CONS   :
    case OBJ_TYPE_VEC    :
    case OBJ_TYPE_BYTN   :
    case OBJ_TYPE_SYMBOL :
	if (obj_Owner(o) != jS.j.acting_user) {
	    return FALSE;
        }
    }
    return TRUE;
}

 /***********************************************************************/
 /*-    job_Must_Control -- Error if acting_user does't control object. */
 /***********************************************************************/

void
job_Must_Control_With_Err_Msg(
    Vm_Obj  o,
    Vm_Uch* err_msg
) {
    if (!job_Controls(o))   MUQ_WARN (err_msg);
}

void
job_must_control(
    Vm_Obj  o
) {
    job_Must_Control_With_Err_Msg( o, "You may not modify that." );
}

void
job_Must_Control(
    Vm_Int n
) {
    job_must_control( jS.s[n] );
}

 /***********************************************************************/
 /*-    job_Will_Read_Message_Stream -- Signal error if impermissable.  */
 /***********************************************************************/

Vm_Obj
job_Will_Read_Message_Stream(
    Vm_Obj  mss
) {
    /* Support bidirectional streams by redirecting */
    /* read operations to stream%s/twin:            */
    mss = MSS_P(mss)->twin;
    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	MUQ_FATAL ("Needed mss!");
    }
    #endif

    {   Mss_P m = MSS_P(mss);

	/* We trust that mss -is- a messageStream. */
	if ((jS.j.privs & JOB_PRIVS_OMNIPOTENT)
	&&   OBJ_IS_CLASS_ROT(jS.j.acting_user)
	){
	    return mss;
	}
	if (obj_Owner(mss) == jS.j.acting_user)    return mss;

	/* This check differs from normal privcheck */
	/* in extra permissions grantable via the   */
	/* mss%s/allowReads field:                 */
	{   Vm_Obj allow_reads = m->allow_reads;
	    if (allow_reads == OBJ_T
	    ||  allow_reads == jS.j.acting_user
	    ||  allow_reads == jS.job
	    ){
		return mss;
    }	}   }

    MUQ_WARN ("May not read from this messageStream");
    return mss; /* Only to quiet compilers. */
}

 /***********************************************************************/
 /*-    job_Will_Write_Message_Stream -- Signal error if impermissable. */
 /***********************************************************************/

void
job_Will_Write_Message_Stream(
    Vm_Obj  mss
) {
    Vm_Obj owner;
    Mss_P m = MSS_P(mss);

    if (m->dead != OBJ_NIL)   MUQ_WARN ("May not write to dead stream");

    /* We trust that mss -is- a messageStream. */
    if ((jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(jS.j.acting_user)
    ){
        return;
    }
    owner = obj_Owner(mss);
    if (owner == jS.j.acting_user)    return;

    /* We're unusually permissive here, also */
    /* allowing the operation if actual_user */
    /* owns the stream.  This is because it  */
    /* is such a pain to have all error      */
    /* messages issued under the influence   */
    /* of a rootAsUserDo{...} (say) lost  */
    /* due to inability to write the output  */
    /* message stream.  The infinite loop    */
    /* that results isn't pretty either :)   */
    if (owner == jS.j.actual_user)    return;

    /* This check differs from normal privcheck */
    /* in extra permissions grantable via the   */
    /* mss%s/allowWrites field:                */
    {   Vm_Obj allow_writes = m->allow_writes;
	if (allow_writes == OBJ_T
	||  allow_writes == jS.j.acting_user
	||  allow_writes == jS.job
	){
	    return;
    }	}

    MUQ_WARN ("May not write to this messageStream");
}

 /***********************************************************************/
 /*-    job_Must_Control_Object -- Error if acting_user does't control. */
 /***********************************************************************/

static void
job_must_control_object2(
    Vm_Obj  o,
    Vm_Uch* err_msg
) {
    /* Same as job_Must_Control(), except we are to assume */
    /* that argument has owner slot:                       */
    if ((jS.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(jS.j.acting_user)
    ){
        return;
    }
    if (obj_Owner(o) == jS.j.acting_user)    return;

    MUQ_WARN (err_msg);
}
void
job_Must_Control_Object(
    Vm_Int n
) {
    job_must_control_object2( jS.s[n], "You may not modify that." );
}

 /***********************************************************************/
 /*-    job_Must_Scry -- Read error if acting_user does't control obj.  */
 /***********************************************************************/

static void
job_must_scry(
    Vm_Obj o
) {
    job_Must_Control_With_Err_Msg( o, "You may not read that." );
}

void
job_Must_Scry(
    Vm_Int n
) {
    job_must_scry( jS.s[n] );
}

 /***********************************************************************/
 /*-    job_Must_Scry_Object -- Error if acting_user does't control.    */
 /***********************************************************************/

void
job_Must_Scry_Object(
    Vm_Int n
) {
    job_must_control_object2( jS.s[n], "You may not read that." );
}

/************************************************************************/
/*-    Public fns for jobprims.c, miscellaneous.			*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_Call -- 							*/
 /***********************************************************************/

/* Any changes here likely require matching changes in RETURN and EXECUTE: */

  /**********************************************************************/
  /*-   job_Call2 -- 							*/
  /**********************************************************************/
void
job_Call2(
    Vm_Obj o
) {
    /* Uncomment for a handy debugging trace: */
    #ifndef MUQ_TRACE
    if (job_Log_Bytecodes /*= (++job_Bytecodes_Logged>JOB_TRACE_BYTECODES_FROM)*/) {
        Vm_Obj src = CFN_P(o)->src;
	if (OBJ_IS_OBJ(src) && OBJ_IS_CLASS_FN(src)) {
	    Vm_Obj nam = FUN_P(src)->o.objname;
	    if (stg_Is_Stg(nam)) {
		Vm_Int len = stg_Len(nam);
		if (len < 200) {
		    Vm_Uch buf[  256 ];
		    Vm_Uch buf2[ 256 ];
		    if (len == stg_Get_Bytes( buf, len, nam, 0 )) {
			buf[len] = '\0';
			sprintf(buf2,"Invoking '%s'...\n",buf);
			lib_Log_String(buf2);
    }	}   }   }   }
    #endif

    {   /* Check for loop stack overflow: */
	register Vm_Obj* l = jS.l;
	if (l + 5 >= jS.l_top) {
	    job_Guarantee_Loop_Headroom( 5 );
	    l = jS.l;
	}

	/* Error checks complete, now we */
	/* can afford to change state:   */

	/* Update state in current NORMAL frame: */
	jS.v[-1]  = jS.x_obj;	/* Shouldn't really be needed. */
	jS.v[-2]  = OBJ_FROM_INT((jS.pc+jS.instruction_len) - (Vm_Uch*)jS.k);

	/* Push essential state on loop stack: */
        ++l;   *l = 5*sizeof(Vm_Obj);
	++l;   *l = OBJ_FROM_INT(0); /* Dummy pc for new function. */
	++l;   *l = o;  /* compiledFunction being called; */
	++l;   *l = JOB_STACKFRAME_NORMAL;
        ++l;   *l = 5*sizeof(Vm_Obj);
	jS.v      = l-1;    /* Remember new frame pointer.    */
	jS.l      = l;      /* Remember new loop  topofstack. */
    }
    {   /* Get address of executable: */
	register Cfn_P p = CFN_P(o);

	/* Set up pointer to new constants vector: */
	jS.k  =           &p->vec[        0 ];

	/* Set up new program counter: */
	jS.pc = (Vm_Uch*) &p->vec[ CFN_CONSTS(p->bitbag) ];
	/* jS.pc is now correct, so we don't want anyone */
	/* incrementing it before executing instruction: */
	jS.instruction_len = 0;

	/* It is important not to set jS.x_obj	*/
	/* until above CFN_P(o) call swaps it   */
        /* into ram for us:                     */
	jS.x_obj  = o;
    }
}

  /**********************************************************************/
  /*-   job_Call -- 							*/
  /**********************************************************************/
void
job_Call(
    Vm_Obj L2
) {
    Vm_Obj o = L2;

    if (OBJ_IS_SYMBOL(o))   o = job_Symbol_Function(o);

/* Buggo? Possibly we should be giving thunks */
/* a chance to evaluate INTO functions here?  */
/* that seems more consistent with general    */
/* thunk implicit-forcing semantics than does */
/* calling them directly as target function.  */
    if (!OBJ_IS_CFN(o) && !OBJ_IS_THUNK(o)) {
        MUQ_WARN ("Need symbol or c-fn!");
    }

    job_Call2(o);
}

  /**********************************************************************/
  /*-   job_LispCall -- 						*/
  /**********************************************************************/
void
job_LispCall(
    Vm_Obj L2
) {
    Vm_Obj o = L2;

    if (OBJ_IS_SYMBOL(o))   o = job_Symbol_Function(o);

MUQ_WARN("LispCall unimplemented");

    job_Call2(o);
}

 /***********************************************************************/
 /*-    job_Calla -- 							*/
 /***********************************************************************/

/* This function is designed to allow arity-safe */
/* calling of runtime-bound functions by the     */
/* simple expedient of storing the expected      */
/* arity in the constant vector, and checking it */
/* against the actual arity of the function just */
/* before calling it.  Our argument is an object */
/* format integer offset into the const vector,  */
/* giving the expected arity, while the function */
/* we are to call is on top of the stack.        */

void
job_Calla(
    Vm_Obj declared_arity
) {
    Vm_Obj o = *jS.s;

    if (OBJ_IS_SYMBOL(o))   o = job_Symbol_Function(o);

/* buggo... prolly wanna phase out 'fn' accepting, */
/* symbols now serve that purpose: */
/* LATER: Um, is this clear? Be nice to be able to have functions */
/* look like editable strings in some UI contexts, without any    */
/* explicit compilation phase -- just autocompile if binary is out */
/* of sync with source at compile time.  This should be easy if we */
/* indirect through fns -- it is practical indirecting through symbols? */
    /* We accept either fn or cfn as argument: */
/*  if (OBJ_IS_OBJ(o)) { */
/*	if (!OBJ_IS_CLASS_FN(o))   MUQ_WARN ("Need fn or cfn!"); */

	/* Fetch our executable from fn: */
/*	o = FUN_P(o)->executable; */
/*    } */
/* Buggo? Possibly we should be giving thunks */
/* a chance to evaluate INTO functions here?  */
/* that seems more consistent with general    */
/* thunk implicit-forcing semantics than does */
/* calling them directly as target function.  */
    if (!OBJ_IS_CFN(o) && !OBJ_IS_THUNK(o)) {
        MUQ_WARN ("Need fn or cfn!");
    }

    /* Locate source function for compiledFunction: */
    {   Vm_Obj fn = CFN_P(o)->src;
	#ifdef MUQ_IS_PARANOID
	if (!OBJ_IS_OBJ(fn) || !OBJ_IS_CLASS_FN(fn)) MUQ_FATAL ("job_Calla");
	#endif

	/* Check arity: */
	{   Vm_Obj   actual_arity = FUN_P(fn)->arity;
	    if (  actual_arity != declared_arity
	    &&  declared_arity != FUN_ARITY(0,0,0,0,FUN_ARITY_TYP_Q)
	    ){
		MUQ_WARN (
		    "call{...} mismatch: declared arity %x vs actual arity %x",
		    (int)declared_arity,
		    (int)actual_arity
		);
    }   }   }

    /* All systems go for calling: */
    job_Call2(o);
    --jS.s;
}

 /***********************************************************************/
 /*-    job_P_Read_Any_Stream_Packet --					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_read_packet --						*/
  /**********************************************************************/

static Vm_Int
job_read_packet(
    Vm_Obj no_fragments, 
    Vm_Obj mss,
    Vm_Int ok_to_block,
    Vm_Int args_to_pop
){
    Vm_Obj buf[ MSS_MAX_MSG_VECTOR ];
    Mss_A_Msg msg;
    Vm_Int values_read;
    values_read = mss_Read(
	buf,
	MSS_MAX_MSG_VECTOR,
	no_fragments,
	&msg,
	mss,
	ok_to_block
    );
    if (values_read == -1) return FALSE;
    jS.s -= args_to_pop;

    /* Copy values from obj[] to     */
    /* stack, wrapping a stackblock  */
    /* around it as we go:           */
    job_Guarantee_Headroom( values_read+2 );
    {   Vm_Int i;
	*++jS.s = OBJ_BLOCK_START;
	for (i = 0;  i < values_read;   ++i) {
	    *++jS.s = buf[i];
	}
	*++jS.s = OBJ_FROM_BLK(values_read);
    }		

    /* Add tag and who info: */
    *++jS.s = msg.tag;
    *++jS.s = msg.who;

    return TRUE;
}

  /**********************************************************************/
  /*-   job_read_any_packet --						*/
  /**********************************************************************/

static Vm_Int
job_read_any_packet(
    Vm_Obj no_fragments, 
    Vm_Obj mss
) {
    /* Same as job_read_packet()     */
    /* except we also return stream: */
    if (!job_read_packet( no_fragments, mss, /*ok_to_block:*/FALSE, 0 )) {
	return FALSE;
    }
    job_Guarantee_Headroom( 1 );
    *++jS.s = mss;
    return TRUE;
}

  /**********************************************************************/
  /*-   job_P_Read_Any_Stream_Packet --					*/
  /**********************************************************************/

void
job_P_Read_Any_Stream_Packet(
    void
) {
    /* Read from any of a given set of streams. */
    Vm_Obj job          = jS.job;
    Vm_Int secs         = OBJ_TO_INT( jS.s[  0 ] );
    Vm_Int no_fragments =             jS.s[ -1 ]  ;
    Vm_Int len          = OBJ_TO_BLK( jS.s[ -2 ] );
    Vm_Obj stream[ JOB_QUEUE_MEMBERSHIP_MAX ];

    if (jS.s[0]==OBJ_NIL) {
	secs = 0;
    } else {
	job_Guarantee_Int_Arg( 0 );
	if (secs < 1) {
	    MUQ_WARN ("|readAnyStreamPacket: 'secs' must be > 0 or NIL");
    }   }
    job_Guarantee_Blk_Arg(  -2 );
    job_Guarantee_N_Args( len+4);
    if (no_fragments != OBJ_NIL
    &&  no_fragments != OBJ_T
    ){
	MUQ_WARN ("'noFragments' must be t or nil");
    }

    /* We currently have a hardwired limit on the   */
    /* number of streams |readAnyStreamPacket    */
    /* can wait on.  The limit is mostly an         */
    /* efficiency hack, since it lets us allocate   */
    /* a fixed number of links directly in the job  */
    /* object, and avoid both having to look up a   */
    /* second object each time we un/link a job,    */
    /* and also having to de/allocate space for the */
    /* links.  Check blocksize against limit:       */
    if (len >= JOB_QUEUE_MEMBERSHIP_MAX - JOB_QUEUE_DOZ) {
	MUQ_WARN ("|readAnyStreamPacket: Too many streams");
    }

    /* Treat no streams and no time-out as a special case: */
    if (!(len|secs)) {
        jS.s -= len+4;
	*++jS.s = OBJ_BLOCK_START;
        *++jS.s = OBJ_FROM_BLK(0);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	return;
    }

    /* Check that we have rights to */
    /* read from all given streams: */
    {   Vm_Int i;
	for (i = len;   i --> 0;   ) {
	    Vm_Int index   = -3 -i;
	    Vm_Obj mss     = jS.s[ index ];
	    job_Guarantee_Mss_Arg( index );
	    (void) job_Will_Read_Message_Stream( mss );
    }   }

    /* Copy given streams to stream[] */
    /* and pop args off stack:        */
    {   Vm_Int i;
	for (i = len;   i --> 0;   ) {
	    Vm_Int index   = -3 -i;
	    stream[i]      = jS.s[ index ];
    }   }
    jS.s -= len+4;

    /* Check that all streams are distinct, */
    /* because having the same stream twice */
    /* would lead us to enter a single job  */
    /* into the same jobqueue twice, which  */
    /* could screw up joq_Run_Queue()'s     */
    /* queue traversal &tc.  To keep life   */
    /* simple for the application hacker    */
    /* we silently remove dups instead of   */
    /* signaling an error. Because I expect */
    /* 2-3 streams in general we use a dumb */
    /* shellsort instead of a heapsort or   */
    /* such:                                */
    {   Vm_Int i;
	Vm_Int j;
	for     (i = len;   i --> 0;   ) {
	    for (j = i  ;   j --> 0;   ) {
		if (stream[i] == stream[j]) {
		    stream[i] =  stream[--len];   break;
    }	}   }   }

    /* If any stream has a packet available, */
    /* read  and return it immediately:      */
    {   Vm_Int i;
	for (i = len;   i --> 0;   ) {
	    Vm_Obj mss = job_Will_Read_Message_Stream( stream[i] );
	    if (job_read_any_packet( no_fragments, mss ))   return;
    }   }

    /* Advance program counter to next instruction: */
    jS.pc += jS.instruction_len;
    jS.instruction_len = 0;

    /* Push correct results for timed-out case   */
    /* onto stack.  This avoids the need for     */
    /* much specialCase code in joq_Desleep().  */
    /* We do it even when there is no timeout    */
    /* given, just for consistency:              */
    *++jS.s = OBJ_BLOCK_START;
    *++jS.s = OBJ_FROM_BLK(0);
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;

    /* Remove us from run queue: */
    joq_Dequeue( job );

    /* Link us into read queue for each stream: */
    {   Vm_Int i;
	for (i = 0;   i < len;   ++i) {
	    Vm_Obj mss = job_Will_Read_Message_Stream( stream[i] );
	    Vm_Obj joq = mss_Readjoq( mss );
            joq_Link( joq, job, JOB_QUEUE_MEMBERSHIP_MIN + i );
    }   }

    /* If we have a timeout, link us into the    */
    /* doz queue, otherwise clear @$s.until-sec: */
    if (secs) {
	joq_Ensleep( job, secs );
    } else {
	Job_P j = JOB_P(job);
#ifdef OLD
	j->until_sec  = OBJ_FROM_INT(0);
	j->until_nsec = OBJ_FROM_INT(0);
#else
	j->until_msec  = OBJ_FROM_INT(0);
#endif
	vm_Dirty(job);
    }

    /* Mark job as being in the middle of doing a   */
    /*     |readAnyStreamPacket                  */
    /* We need this mostly so that when joq.t       */
    /* removes a job from a queue, it knows whether */
    /* to complete the |readAnyStreamPacket op   */
    /* by reading a packet and pushing the source   */
    /* stream identity onto the stack:              */
    {   Job_P j = JOB_P(job);
	j->doing_promiscuous_read   = OBJ_FROM_INT(1);
	j->promiscuous_no_fragments = no_fragments;
	vm_Dirty(job);
    }

    /* Switch to next job: */
    job_next();
}

  /**********************************************************************/
  /*-   job_P_Select_Message_Streams --					*/
  /**********************************************************************/

void
job_P_Select_Message_Streams(
    void
) {
  /* This is intended to be a closer analogue to Unix select(),    */
  /* accepting a block of input streams and a block of output      */
  /* streams and a time to wait, and returning a block of streams  */
  /* ready for input, a block of streams ready for output, and the */
  /* number of milliseconds actually waited                        */
    MUQ_WARN ("selectMessageStreams: Unimplemented");
}

 /***********************************************************************/
 /*-    job_Do_Promiscuous_Read --					*/
 /***********************************************************************/

void
job_Do_Promiscuous_Read(
    Vm_Obj mss,
    Vm_Obj job,
    Vm_Obj no_fragments
) {
    /********************************/
    /* This function gets called by */
    /* joq_Run_Queue() when a job   */
    /* which is in the middle of a  */
    /* |readAnyStreamPacket is   */
    /* discovered on a stream which */
    /* has received input.          */
    /*                              */
    /* Our caller guarantees the    */
    /* read can complete (unless    */
    /* the stack overflows).        */
    /********************************/

    /* Save current job, if any: */
    Vm_Obj old_len   = jS.instruction_len;
    Vm_Obj old_job   = jS.job;
    if (old_job) {
	job_State_Unpublish();
    }

    /* Install |readAnyStreamPacket job: */
    joq_Run_Job(         job );
    job_State_Publish(   job ); {

	/* Pop the default timeout return */
	/* values off the stack:          */
	jS.s -= 5;

	/* Do the read: */
/* buggo? Can't this crash us if we -do- overflow the stack? */
	job_read_any_packet( no_fragments, mss );

        /* Done with |readAnyStreamPacket job: */
    }   job_State_Unpublish();

    /* Restore any previous job: */
    if (old_job) {
	joq_Run_Job(         old_job );
	job_State_Publish(   old_job );
	jS.instruction_len = old_len;
    }
}



 /***********************************************************************/
 /*-    job_P_Read_Stream_Packet --					*/
 /***********************************************************************/

void
job_P_Read_Stream_Packet(
    void
) {
    /* Read from appropriate mss: */
    Vm_Obj mss          = jS.s[  0 ];
    Vm_Obj no_fragments = jS.s[ -1 ];

    job_Guarantee_N_Args(    2 );
    job_Guarantee_Mss_Arg(   0 );
    mss = job_Will_Read_Message_Stream( mss );

    if (no_fragments != OBJ_NIL
    &&  no_fragments != OBJ_T
    ){
	MUQ_WARN ("'noFragments' must be t or nil");
    }

    /* Maybe return [ | nil nil  */
    /* to indicate a dead stream: */
    if (MSS_P(mss)->dead != OBJ_NIL
    &&  mss_Is_Empty(mss)
    &&  JOB_P(jS.job)->read_nil_from_dead_streams != OBJ_0
    ){
	job_Guarantee_Headroom( 2 );
	*--jS.s = OBJ_BLOCK_START;
        *++jS.s = OBJ_FROM_BLK(0);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	return;
    }

    job_read_packet( no_fragments, mss, /*ok_to_block:*/TRUE, 2 );
}

 /***********************************************************************/
 /*-    job_P_Write_Stream_Packet --					*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_write_stream_packet --					*/
  /**********************************************************************/

static void
job_write_stream_packet(
    Vm_Int ok_to_block
) {
    Vm_Obj obj[ MSS_MAX_MSG_VECTOR ];

    /* Write to given mss: */
    Vm_Obj mss  =             jS.s[  0 ]  ;
    Vm_Obj done =             jS.s[ -1 ]  ;
    Vm_Obj tag  =             jS.s[ -2 ]  ;
    Vm_Int len  = OBJ_TO_BLK( jS.s[ -3 ] );

    job_Guarantee_N_Args(    3 );
    job_Guarantee_Blk_Arg(  -3 );
    job_Guarantee_N_Args( len+5);
    if (OBJ_IS_OBJ(mss) && OBJ_IS_CLASS_PRX(mss) && !ok_to_block) {
	/* Transparent networking support -- */
	/* call appropriate in-db fn instead */
	/* of executing normal in-db code:   */
	Vm_Obj cfn = SYM_P(obj_Lib_Muqnet_Maybe_Write_Stream_Packet)->function;
	if (OBJ_IS_CFN(cfn)) {
	    job_Call2(cfn);
	    return;
	}
    }
    if (OBJ_IS_STRUCT(mss) && !ok_to_block) {
	Vm_Obj cfn = SYM_P(obj_Lib_Muf_Maybe_Write_Stream_Packet)->function;
	if (OBJ_IS_CFN(cfn)) {
	    job_Call2(cfn);
	    return;
	}
    }
    job_Guarantee_Mss_Arg(   0 );
    job_Will_Write_Message_Stream( mss );

    if (done != OBJ_NIL && done != OBJ_T) MUQ_WARN ("'done' must be t or nil");
    if (len >= MSS_MAX_MSG_VECTOR) MUQ_WARN ("packet too large for stream");
	
    /* Copy block contents to obj[]: */
    {   Vm_Int i;
	for (i = 0;   i < len;   ++i) {
	    obj[i] = jS.s[ i-(len+3) ];
    }	}

    /* Send message: */
    if (ok_to_block
    || !mss_Send_Would_Block( mss, len )
    ){
	mss_Send(
	    mss,
	    jS.j.acting_user,
	    tag,
	    done,
	    obj, len
	);
    } else {
/* printf("job_write_stream_packet: DROPPING PACKET\n"); / debug printf only. */ 
    }

    --jS.s;
}

  /**********************************************************************/
  /*-   job_P_Write_Stream_Packet --					*/
  /**********************************************************************/

void
job_P_Write_Stream_Packet(
    void
) {
    job_write_stream_packet( /*ok_to_block:*/ TRUE );
}

 /***********************************************************************/
 /*-    job_P_Maybe_Write_Stream_Packet --				*/
 /***********************************************************************/

void
job_P_Maybe_Write_Stream_Packet(
    void
) {
    job_write_stream_packet( /*ok_to_block:*/ FALSE );
}

 /***********************************************************************/
 /*-    job_P_Root_Write_Stream_Packet --				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   job_root_write_stream_packet --					*/
  /**********************************************************************/

static void
job_root_write_stream_packet(
    Vm_Int ok_to_block
) {
    Vm_Obj obj[ MSS_MAX_MSG_VECTOR ];

    /* Write to given mss: */
    Vm_Obj mss  =             jS.s[  0 ]  ;
    Vm_Obj user =             jS.s[ -1 ]  ;
    Vm_Obj done =             jS.s[ -2 ]  ;
    Vm_Obj tag  =             jS.s[ -3 ]  ;
    Vm_Int len  = OBJ_TO_BLK( jS.s[ -4 ] );

    job_Must_Be_Root();

    job_Guarantee_N_Args(    3 );
    job_Guarantee_Mss_Arg(   0 );
/*  job_Guarantee_User_Arg( -1 ); *//* Killed to allow avatar 'who' args. */
    job_Guarantee_Blk_Arg(  -4 );
    job_Guarantee_N_Args( len+6);
    job_Will_Write_Message_Stream( mss );

    if (done != OBJ_NIL && done != OBJ_T) MUQ_WARN ("'done' must be t or nil");
    if (len >= MSS_MAX_MSG_VECTOR) MUQ_WARN ("packet too large for stream");
	
    /* Copy block contents to obj[]: */
    {   Vm_Int i;
	for (i = 0;   i < len;   ++i) {
	    obj[i] = jS.s[ i-(len+4) ];
    }	}

    /* Send message: */
    if (ok_to_block
    || !mss_Send_Would_Block( mss, len )
    ){
	mss_Send(
	    mss,
	    user,
	    tag,
	    done,
	    obj, len
	);
    }

    jS.s -= 2;
}

  /**********************************************************************/
  /*-   job_P_Root_Write_Stream_Packet --				*/
  /**********************************************************************/

void
job_P_Root_Write_Stream_Packet(
    void
) {
    job_root_write_stream_packet( /*ok_to_block:*/ TRUE );
}

 /***********************************************************************/
 /*-    job_P_Root_Maybe_Write_Stream_Packet --				*/
 /***********************************************************************/

void
job_P_Root_Maybe_Write_Stream_Packet(
    void
) {
    job_root_write_stream_packet( /*ok_to_block:*/ FALSE );
}

 /***********************************************************************/
 /*-    job_P_Read_Line --						*/
 /***********************************************************************/

void
job_P_Read_Line(
    void
) {

    /* Read from appropriate mss: */
/*  Vm_Obj src_obj = jS.job; */
    Vm_Obj mss     = JOB_P(jS.job)->standard_input;
    Mss_A_Msg msg;

    #if MUQ_IS_PARANOID
    if (!OBJ_IS_OBJ(mss) || !OBJ_IS_CLASS_MSS(mss)) {
	MUQ_FATAL ("Needed mss!");
    }
    #endif

    mss = job_Will_Read_Message_Stream( mss );

    if (MSS_P(mss)->dead != OBJ_NIL
    &&  mss_Is_Empty(mss)
    &&  JOB_P(jS.job)->read_nil_from_dead_streams != OBJ_0
    ){
	*jS.s = OBJ_NIL;
	return;
    }

    {   Vm_Uch buf[ MSS_MAX_MSG_VECTOR ];
        Vm_Obj obj[ MSS_MAX_MSG_VECTOR ];
	Vm_Int bytes_read;
	bytes_read = mss_Read(
	    obj,
	    MSS_MAX_MSG_VECTOR,
	    OBJ_T,
	    &msg,
	    mss,
	    TRUE	/* ok_to_block */
	);

	/* Copy values from obj[] to     */
	/* buf[], converting from        */
	/* Vm_Obj to Vm_Uch as we go and */
	/* dropping non-char values:     */
{	Vm_Int cat = 0;
        Vm_Int rat = 0;
	Vm_Uch*dst = (Vm_Uch*)buf;
	Vm_Obj val;
	while (rat < bytes_read) {
	    val = obj[ rat++ ];
	    if (OBJ_IS_CHAR(val)) dst[ cat++ ] = OBJ_TO_CHAR(val);
	}
	bytes_read = cat;

	*++jS.s = stg_From_Buffer( buf, bytes_read );
}
    }
}


 /***********************************************************************/
 /*-    job_P_Enbyte -- Convert block to pure-byte format.		*/
 /***********************************************************************/

/************************************************/
/* We need a little mini-language into which we */
/* code packets, so that job_P_Debyte can 'run' */
/* enbytten packages to produce a reasonable    */
/* reconstruction of the original.              */
/*						*/
/* I've picked:					*/
/*						*/
/* Opcodes 0x01 -> 0x0F: That many chars follow.*/
/* Opcodes 0x14 -> 0x7F: len 4-6F string follows*/
#if      VM_INTBYTES==4
/* Opcode  0x84:  4-byte imm value follows.	*/
#else /* VM_INTBYTES==8 */
/* Opcode  0x88:  8-byte imm value follows.	*/
#endif
/* Opcode  0x92: 18-byte pointer proxy follows. */
/* Opcodes 0x93-0xD0 unused.			*/
/* Opcodes 0xD1 -> 0xDF: 1-15 byte keyword.	*/
/* Opcode  0xFC User/Guest as 8-byte hashname.	*/
/* Opcode  0xFD <LEN> <SIGN> bignum follows:	*/
/*              <LEN> is a byte and gives       */
/*              number of 64-bit bignum words	*/
/*	        following.  Each word is, as	*/
/*		usual, in 'network' byte order,	*/
/*		most significant byte first.	*/
/*		We always send an integral	*/
/*		number of words.		*/
/*		<SIGN> is a byte, 0x01 or 0xFF	*/
/* Opcode  0xFE T				*/
/* Opcode  0xFF NIL				*/
/*						*/
/* Immediate values are in 'network' byte order,*/
/* most significant byte first.			*/
/*						*/
/* Pointer proxies are formatted as follows:    */
/*   Bytes  0-3  ip0 ip1 ip2 ip3  Host address.	*/
/*   Bytes  4-5  port-hi port-lo Host port.	*/
/*   Bytes  6-9  i0				*/
/*   Bytes 10-13 i1				*/
/*   Bytes 14-17 i2				*/
/* where i0,i1,i2 are the proxied pointer in	*/
/* dbrefToInts3 format.			*/
/************************************************/
#define JOB_ENBYTE_STRING	0x10
#define JOB_ENBYTE_IMMEDIATE	(0x80+VM_INTBYTES)
#define JOB_ENBYTE_PROXY_LEN	(4*VM_INTBYTES)
#define JOB_ENBYTE_PROXY	(0x80+JOB_ENBYTE_PROXY_LEN)
#define JOB_ENBYTE_K0		0xD0
#define JOB_ENBYTE_K1		0xD1
#define JOB_ENBYTE_K15		0xDF
#define JOB_ENBYTE_USER		0xFC
#define JOB_ENBYTE_BIGNUM	0xFD
#define JOB_ENBYTE_T		0xFE
#define JOB_ENBYTE_NIL		0xFF

void
job_P_Enbyte(
    void
){
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(   block_len+2 );

    {   /* Make an initial pass over the block figuring how many*/
	/* extra values we will need to insert to complete the	*/
	/* encoding:						*/
	Vm_Int  added_values = 0;
        Vm_Obj* p;
	for (p = jS.s - block_len;   p < jS.s;   ++p) {

	    switch (OBJ_TYPE(*p)) {

		/* Ephemerals have no separate store,         */
		/* just what they borrow from the loop stack. */
	    case OBJ_TYPE_EPHEMERAL_LIST:
	    case OBJ_TYPE_EPHEMERAL_STRUCT:
	    case OBJ_TYPE_EPHEMERAL_VECTOR:
	    case OBJ_TYPE_SPECIAL:
	    case OBJ_TYPE_BOTTOM:
	    case OBJ_TYPE_BLK:
		MUQ_WARN("|enbyte: Unexportable value");

	    case OBJ_TYPE_FLOAT:
	    case OBJ_TYPE_INT:
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
		/* We'll send all these as 4/8-byte */
		/* immediate values:		    */
		added_values += VM_INTBYTES;
		continue;

	    case OBJ_TYPE_BYTN:
		{   Vm_Int ip  = p - jS.s;
		    Vm_Int len = stg_Len(*p);
		    p = jS.s + ip;
		    if (len > 3
		    &&  len < 0x70
		    ){
			/* We'll send the string inline by */
			/* value instead of by reference:  */
			added_values += len;
			continue;
		}   }
		/* Send as 18-byte proxy: */
		added_values += JOB_ENBYTE_PROXY_LEN;
		continue;

	    case OBJ_TYPE_BIGNUM:
	        {   Bnm_P  bnm = BNM_P(*p);
		    Vm_Int len = bnm->length;
		    if (len < 256 && !bnm->private) {	
			added_values += 2 + len*VM_INTBYTES;
			continue;
		    }
		}
		/* Send as 18-byte proxy: */
		added_values += JOB_ENBYTE_PROXY_LEN;
		continue;

	    case OBJ_TYPE_SYMBOL:
		if (*p == OBJ_NIL
		||  *p == OBJ_T
		){
		    /* Send as special-base single-byte opcode */
		} else {
		    Vm_Int ip  = p - jS.s;
		    Vm_Obj sym = *p;
		    {   Sym_P s= SYM_P(sym);
			Vm_Obj nam;
			Vm_Int len;
			if (s->package == obj_Lib_Keyword
			&& (nam = s->name)
			&& stg_Is_Stg(nam)
			&& (len = stg_Len(nam))
			){
			    if (len && len <= 15) {
				/* Send via special keyword opcode: */
				added_values += len;
			    	p = jS.s + ip;
			    	continue;
			    } else if (len <= 255) {
				/* Send via special keyword opcode: */
				added_values += len+1;
			    	p = jS.s + ip;
			    	continue;
		    }   }   }

		    /* Send as 18-byte proxy: */
		    p = jS.s + ip;
		    added_values += JOB_ENBYTE_PROXY_LEN;
		}
		continue;

	    case OBJ_TYPE_OBJ:
		{   Vm_Int ip  = p - jS.s;
		    if (OBJ_IS_FOLK(*p)) {
			p = jS.s + ip;
			added_values += VM_INTBYTES;
			continue;
		    }
		    p = jS.s + ip;
		}
		/* fall through */

	    case OBJ_TYPE_VEC:
	    case OBJ_TYPE_CONS:
	    case OBJ_TYPE_STRUCT:
#ifdef OLD
	    case OBJ_TYPE_PROXY:
#endif
	    case OBJ_TYPE_THUNK:
	    case OBJ_TYPE_CFN:
		/* We'll send all these as 18-byte	*/
		/* proxies:				*/
		added_values += JOB_ENBYTE_PROXY_LEN;
		continue;

	    case OBJ_TYPE_CHAR:
		/* For space efficiency, we encode blocks */
		/* of chars instead of single chars: See  */
		/* how many chars (up to 0x7f) we have in */
		/* a row here:				  */
		{   Vm_Int run_len = 1;
		    while (OBJ_IS_CHAR(p[1])) {
			++p;
			if (++run_len == 0x0F)   break;
		    }
		    ++added_values;
		}
		continue;

	    default:
		MUQ_FATAL ("internal err");
	    }
	}

        /* Expand the block by the required amount, leaving	*/
	/* the extra space at the bottom (start) of the block:	*/
	job_Guarantee_Headroom( added_values );
	jS.s           += added_values;
       *jS.s            = OBJ_FROM_BLK( block_len + added_values );
	{   Vm_Obj* cat = jS.s - 1;
	    Vm_Obj* rat = cat  - added_values;
	    Vm_Int  i   = block_len;
	    while  (i --> 0) {
		*cat--  = *rat--;
	    }
	}

	/* Do the actual conversion: */
	{   Vm_Obj* cat = jS.s - (block_len + added_values);
	    Vm_Obj* rat = cat  + added_values;
	    while  (rat < jS.s) {
		switch (OBJ_TYPE(*rat)) {

		case OBJ_TYPE_FLOAT:
		case OBJ_TYPE_INT:
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
		    /* Handle 4/8-byte immediate value: */
		    *cat++ = OBJ_FROM_CHAR( JOB_ENBYTE_IMMEDIATE );


		    *cat++ = OBJ_FROM_CHAR( (*rat      ) & 0xFF );
		    *cat++ = OBJ_FROM_CHAR( (*rat >>  8) & 0xFF );
		    *cat++ = OBJ_FROM_CHAR( (*rat >> 16) & 0xFF );
		    *cat++ = OBJ_FROM_CHAR( (*rat >> 24) & 0xFF );

                    #if VM_INTBYTES > 4
		    *cat++ = OBJ_FROM_CHAR( (*rat >> 32) & 0xFF );
		    *cat++ = OBJ_FROM_CHAR( (*rat >> 40) & 0xFF );
		    *cat++ = OBJ_FROM_CHAR( (*rat >> 48) & 0xFF );
		    *cat++ = OBJ_FROM_CHAR( (*rat >> 56) & 0xFF );
                    #endif

		    ++rat;
		    continue;

		case OBJ_TYPE_BIGNUM:
		    {   Vm_Int icat = cat - jS.s;
			Vm_Int irat = rat - jS.s;
			Bnm_P  bnm  = BNM_P(*rat);
			Vm_Int len  = bnm->length;
			cat = jS.s + icat;
			rat = jS.s + irat;
			if (len < 256 && !bnm->private) {
			    Vm_Unt slot[256];
			    Vm_Unt sign = bnm->sign;
			    int  i;
			    for (i = 0;   i < len;   ++i)   slot[i] = bnm->slot[i];
			    cat = jS.s + icat;	/* Prolly unneeded, but */
			    rat = jS.s + irat;  /* cheap insurance...   */

			    /* We'll send the bignum inline by */
			    /* value instead of by reference:  */
			    *cat++ = OBJ_FROM_CHAR( JOB_ENBYTE_BIGNUM );
			    *cat++ = OBJ_FROM_CHAR( len               );
			    *cat++ = OBJ_FROM_CHAR( sign & 0xFF       );
			    for (i = 0;   i < len;   ++i) {


				*cat++ = OBJ_FROM_CHAR( (slot[i]      ) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (slot[i] >>  8) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (slot[i] >> 16) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (slot[i] >> 24) & 0xFF );

				#if VM_INTBYTES > 4
				*cat++ = OBJ_FROM_CHAR( (slot[i] >> 32) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (slot[i] >> 40) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (slot[i] >> 48) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (slot[i] >> 56) & 0xFF );
				#endif
			    }
			    ++rat;
			    continue;
		        }
		    }
		    goto proxy;

		case OBJ_TYPE_BYTN:
		    {   Vm_Int icat = cat - jS.s;
			Vm_Int irat = rat - jS.s;
			Vm_Int len  = stg_Len(*rat);
			cat = jS.s + icat;
			rat = jS.s + irat;
			if (len > 3
			&&  len < 0x70
			){
			    Vm_Int i;
			    Vm_Uch buf[ 0x70 ];
			    stg_Get_Bytes( buf, 0x70, *rat, 0 );
			    cat = jS.s + icat;	/* Prolly unneeded, but */
			    rat = jS.s + irat;  /* cheap insurance...   */

			    /* We'll send the string inline by */
			    /* value instead of by reference:  */
			    *cat++ = OBJ_FROM_CHAR( JOB_ENBYTE_STRING + len );
			    for (i = 0;   i < len;   ++i) {
				*cat++ = OBJ_FROM_CHAR( buf[i] );
			    }
			    ++rat;
			    continue;
		        }
		    }
		    goto proxy;

		case OBJ_TYPE_SYMBOL:
		    if (*rat == OBJ_NIL) {
			*cat++ = OBJ_FROM_CHAR( JOB_ENBYTE_NIL );
			++rat;
			continue;
		    } else if (*rat == OBJ_T) {
			*cat++ = OBJ_FROM_CHAR( JOB_ENBYTE_T   );
			++rat;
			continue;
		    } else if (OBJ_TYPE(*rat) == OBJ_TYPE_SYMBOL) {
			/* Send keywords as short immediate values: */
			Vm_Int icat = cat - jS.s;
			Vm_Int irat = rat - jS.s;

			Vm_Obj sym = *rat;
			{   Sym_P s= SYM_P(sym);
			    Vm_Obj nam;
			    Vm_Int len;
			    Vm_Uch buf[ 256 ];
			    if (s->package == obj_Lib_Keyword
			    && (nam = s->name)
			    && stg_Is_Stg(nam)
			    && (len = stg_Len(nam))
			    &&  len <= 255
			    ){
				Vm_Int i;
				/* Send via special keyword opcode: */
				if (len != stg_Get_Bytes( buf, 255, nam, 0 )) {
				    MUQ_WARN("enbyte: internal err");
				}

				cat = jS.s + icat;
				rat = jS.s + irat;

				if (len && len <= 15) {
				    *cat++ = OBJ_FROM_CHAR(JOB_ENBYTE_K0+len);
				} else {
				    *cat++ = OBJ_FROM_CHAR(JOB_ENBYTE_K0);
				    *cat++ = OBJ_FROM_CHAR(len);
				}
				for (i = 0;   i < len;   ++i) {
				    *cat++ = OBJ_FROM_CHAR( buf[i] );
				}

				++rat;
				continue;
			}   }
			cat = jS.s + icat;
			rat = jS.s + irat;
		    }
		    goto proxy;
		
		case OBJ_TYPE_OBJ:
		    {	Vm_Int icat = cat - jS.s;
			Vm_Int irat = rat - jS.s;
			if (OBJ_IS_FOLK(*rat)) {
			    Vm_Obj hash = USR_P(*rat)->hash_name;
			    cat = jS.s + icat;
			    rat = jS.s + irat;
			    if (OBJ_IS_INT(hash)) {
				/* Handle 4/8-byte immediate value: */
				*cat++ = OBJ_FROM_CHAR( JOB_ENBYTE_USER     );

				*cat++ = OBJ_FROM_CHAR( (hash      ) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (hash >>  8) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (hash >> 16) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (hash >> 24) & 0xFF );

				#if VM_INTBYTES > 4
				*cat++ = OBJ_FROM_CHAR( (hash >> 32) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (hash >> 40) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (hash >> 48) & 0xFF );
				*cat++ = OBJ_FROM_CHAR( (hash >> 56) & 0xFF );
				#endif

				++rat;
				continue;
			    }
			}
			cat = jS.s + icat;
			rat = jS.s + irat;
		    }

		    /* Proxy format again, but with the  */
		    /* info fished out of the proxy obj: */
		    if (OBJ_TYPE(*rat) == OBJ_TYPE_OBJ) {
			Vm_Int icat = cat - jS.s;
			Vm_Int irat = rat - jS.s;

		        if (!OBJ_IS_CLASS_PRX(*rat)) {

			    cat = jS.s + icat;
			    rat = jS.s + irat;
			    goto proxy;

			} else {

			    Vm_Unt hash = OBJ_TO_UNT( USR_P( PRX_P(*rat)->guest )->hash_name );
			    Prx_P p     = PRX_P(*rat);

			    Vm_Unt i0   = OBJ_TO_UNT( p->i0   );
			    Vm_Unt i1   = OBJ_TO_UNT( p->i1   );
			    Vm_Unt i2   = OBJ_TO_UNT( p->i2   );

			    cat = jS.s + icat;
			    rat = jS.s + irat;

			    *cat++ = OBJ_FROM_CHAR( JOB_ENBYTE_PROXY );


			    *cat++ = OBJ_FROM_CHAR( (hash      ) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (hash >>  8) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (hash >> 16) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (hash >> 24) & 0xFF );
			    #if VM_INTBYTES > 4
			    *cat++ = OBJ_FROM_CHAR( (hash >> 32) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (hash >> 40) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (hash >> 48) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (hash >> 56) & 0xFF );
			    #endif

			    *cat++ = OBJ_FROM_CHAR( (i0        ) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i0   >>  8) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i0   >> 16) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i0   >> 24) & 0xFF );
			    #if VM_INTBYTES > 4
			    *cat++ = OBJ_FROM_CHAR( (i0   >> 32) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i0   >> 40) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i0   >> 48) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i0   >> 56) & 0xFF );
			    #endif

			    *cat++ = OBJ_FROM_CHAR( (i1        ) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i1   >>  8) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i1   >> 16) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i1   >> 24) & 0xFF );
			    #if VM_INTBYTES > 4
			    *cat++ = OBJ_FROM_CHAR( (i1   >> 32) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i1   >> 40) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i1   >> 48) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i1   >> 56) & 0xFF );
			    #endif

			    *cat++ = OBJ_FROM_CHAR( (i2        ) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i2   >>  8) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i2   >> 16) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i2   >> 24) & 0xFF );
			    #if VM_INTBYTES > 4
			    *cat++ = OBJ_FROM_CHAR( (i2   >> 32) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i2   >> 40) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i2   >> 48) & 0xFF );
			    *cat++ = OBJ_FROM_CHAR( (i2   >> 56) & 0xFF );
			    #endif

			    ++rat;
			    continue;
			}
		    }
		    /* Never reached */

		case OBJ_TYPE_VEC:
		case OBJ_TYPE_CONS:
		case OBJ_TYPE_STRUCT:
		case OBJ_TYPE_THUNK:
		case OBJ_TYPE_CFN:
	        proxy:

		    /* We'll send all these as 18-byte	*/
		    /* proxies:				*/
		    *cat++ = OBJ_FROM_CHAR( JOB_ENBYTE_PROXY );

		    {   Vm_Unt i0 = 0;
			Vm_Unt i1 = 0;
			Vm_Unt i2 = 0;
			Vm_Unt ha = 0;
			{   Vm_Int icat = cat - jS.s;
			    Vm_Int irat = rat - jS.s;
			    Vm_Obj owner = obj_Owner(*rat);
			    obj_Dbref_To_Ints3( &i0, &i1, &i2, *rat );
			    if (OBJ_IS_OBJ(owner)
			    &&  OBJ_IS_FOLK(owner)
			    ){
				ha = OBJ_TO_INT( USR_P(owner)->hash_name );
			    }
			    cat = jS.s + icat;
			    rat = jS.s + irat;
			}
			*cat++ = OBJ_FROM_CHAR( (ha      ) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (ha >>  8) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (ha >> 16) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (ha >> 24) & 0xFF );
                        #if VM_INTBYTES==8
			*cat++ = OBJ_FROM_CHAR( (ha >> 32) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (ha >> 40) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (ha >> 48) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (ha >> 56) & 0xFF );
			#endif

			*cat++ = OBJ_FROM_CHAR( (i0      ) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i0 >>  8) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i0 >> 16) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i0 >> 24) & 0xFF );
                        #if VM_INTBYTES==8
			*cat++ = OBJ_FROM_CHAR( (i0 >> 32) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i0 >> 40) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i0 >> 48) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i0 >> 56) & 0xFF );
			#endif

			*cat++ = OBJ_FROM_CHAR( (i1      ) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i1 >>  8) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i1 >> 16) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i1 >> 24) & 0xFF );
                        #if VM_INTBYTES==8
			*cat++ = OBJ_FROM_CHAR( (i1 >> 32) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i1 >> 40) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i1 >> 48) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i1 >> 56) & 0xFF );
			#endif

			*cat++ = OBJ_FROM_CHAR( (i2      ) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i2 >>  8) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i2 >> 16) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i2 >> 24) & 0xFF );
                        #if VM_INTBYTES==8
			*cat++ = OBJ_FROM_CHAR( (i2 >> 32) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i2 >> 40) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i2 >> 48) & 0xFF );
			*cat++ = OBJ_FROM_CHAR( (i2 >> 56) & 0xFF );
			#endif
		    }

		    ++rat;
		    continue;

/* buggo? Is TYPE_PROXY still possible, or what? */
#ifdef OLD
		case OBJ_TYPE_PROXY:
#endif
		case OBJ_TYPE_CHAR:
		    {   Vm_Int run_len = 0;
			Vm_Obj*mat     = cat++;
			while (OBJ_IS_CHAR(*rat)) {
			    *cat++ = *rat++;
			    if (++run_len == 0x0F)   break;
			}
			*mat = OBJ_FROM_CHAR(run_len);
		    }
		    continue;

		case OBJ_TYPE_EPHEMERAL_LIST:
		case OBJ_TYPE_EPHEMERAL_STRUCT:
		case OBJ_TYPE_EPHEMERAL_VECTOR:
		case OBJ_TYPE_SPECIAL:
		case OBJ_TYPE_BOTTOM:
		case OBJ_TYPE_BLK:
		default:
		    MUQ_FATAL ("internal err");
		}
	    }
	}
    }
}

 /***********************************************************************/
 /*-    job_P_Debyte -- Convert block back from pure-byte format.	*/
 /***********************************************************************/

void
job_P_Debyte(
    void
){
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(   block_len+2 );

    /* Do a sanity-check pass verifying that the */
    /* block consists entirely of characters:    */
    {   Vm_Obj* p;
	for (p = jS.s - block_len;  p < jS.s;   ++p) {
	    if (!OBJ_IS_CHAR(*p)) {
		*++jS.s = stg_From_Asciz("Block contains non-char data");
		return;
	    }
	}
    }

    /* 'Execute' the block: */
    {   Vm_Obj* cat = jS.s - block_len;
	Vm_Obj* rat = cat;
	Vm_Obj* mat = rat;
	while  (rat < jS.s) {
	    int op = OBJ_TO_CHAR( *rat++ ) & 0xFF;
	    if (op < 0x10) {
		if (rat + op > jS.s) {
		    *++jS.s = stg_From_Asciz("Missing data for char-seq op");
		    return;
		}
		while (op --> 0) {
		    *cat++ = *rat++;
		}
		continue;
	    }
	    if (op >= 0x14
	    &&  op <= 0x7F
	    ){
		/* By-value string: */
		Vm_Int len  = op  - 0x10;
		Vm_Int i;
		Vm_Uch buf[ 0x70 ];
		if (rat + len > jS.s) {
		    *++jS.s = stg_From_Asciz("Missing data for imm-string op");
		    return;
		}
		for (i =  0;   i < len;   ++i) {
		    buf[i]  = OBJ_TO_CHAR( *rat++ );
		}
		{   Vm_Int icat = cat - jS.s;
		    Vm_Int irat = rat - jS.s;
		    Vm_Obj stg  = stg_From_Buffer( buf, len );
		    cat = jS.s + icat;
		    rat = jS.s + irat;
		    *cat++ = stg;
		    continue;
	        }
 	    }
	    if (op >= JOB_ENBYTE_K0
	    &&  op <= JOB_ENBYTE_K15
	    ){
		/* By-value keyword: */
		Vm_Int len  = op  - JOB_ENBYTE_K0;
		Vm_Int i;
		Vm_Uch buf[ 256 ];
		if (op == JOB_ENBYTE_K0) {
		    if (rat == jS.s) {
			*++jS.s = stg_From_Asciz("Missing data for K0 op");
			return;
		    }
		    len  = OBJ_TO_CHAR( *rat++ );
		}
		if (rat + len > jS.s) {
		    *++jS.s = stg_From_Asciz("Missing data for imm-keyword");
		    return;
		}
		for (i =  0;   i < len;   ++i) {
		    buf[i]  = OBJ_TO_CHAR( *rat++ );
		}
		buf[len] = '\0';
		{   Vm_Int icat = cat - jS.s;
		    Vm_Int irat = rat - jS.s;
		    Vm_Obj sym  = sym_Alloc_Asciz_Keyword( buf );
		    cat = jS.s + icat;
		    rat = jS.s + irat;
		    *cat++ = sym;
		    continue;
	    }   }

	    switch (op) {

	    case JOB_ENBYTE_T:
		    *cat++ = OBJ_T;
		    continue;

	    case JOB_ENBYTE_NIL:
		    *cat++ = OBJ_NIL;
		    continue;

	    case JOB_ENBYTE_IMMEDIATE:
		if (rat + VM_INTBYTES > jS.s) {
		    *++jS.s = stg_From_Asciz("Missing data for IMMEDIATE op");
		    return;
		}
		{   Vm_Obj o = (Vm_Obj)0;
		    o |= OBJ_TO_CHAR( *rat++ )      ;
		    o |= OBJ_TO_CHAR( *rat++ ) <<  8;
		    o |= OBJ_TO_CHAR( *rat++ ) << 16;
		    o |= OBJ_TO_CHAR( *rat++ ) << 24;
                    #if VM_INTBYTES==8
		    o |= OBJ_TO_CHAR( *rat++ ) << 32;
		    o |= OBJ_TO_CHAR( *rat++ ) << 40;
		    o |= OBJ_TO_CHAR( *rat++ ) << 48;
		    o |= OBJ_TO_CHAR( *rat++ ) << 56;
		    #endif

		    /* Another sanity check: */
		    switch (OBJ_TYPE(o)) {
		    case OBJ_TYPE_FLOAT:
		    case OBJ_TYPE_INT:
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
		    case OBJ_TYPE_CHAR:
			/* These types are ok */
			break;
		    default:
			/* Anything else is bogeaux: */
			*++jS.s = stg_From_Asciz("Bad data for IMMEDIATE op");
			return;
		    }			    
		    *cat++ = o;
		}
		continue;

	    case JOB_ENBYTE_USER:
		if (rat + VM_INTBYTES > jS.s) {
		    *++jS.s = stg_From_Asciz("Missing data for USER op");
		    return;
		}
		{   Vm_Obj o = (Vm_Obj)0;
		    o |= OBJ_TO_CHAR( *rat++ )      ;
		    o |= OBJ_TO_CHAR( *rat++ ) <<  8;
		    o |= OBJ_TO_CHAR( *rat++ ) << 16;
		    o |= OBJ_TO_CHAR( *rat++ ) << 24;
                    #if VM_INTBYTES==8
		    o |= OBJ_TO_CHAR( *rat++ ) << 32;
		    o |= OBJ_TO_CHAR( *rat++ ) << 40;
		    o |= OBJ_TO_CHAR( *rat++ ) << 48;
		    o |= OBJ_TO_CHAR( *rat++ ) << 56;
		    #endif

		    /* Another sanity check: */
		    if (OBJ_TYPE(o) != OBJ_TYPE_INT) {
			/* Anything else is bogeaux: */
			*++jS.s = stg_From_Asciz("Bad data for USER op");
			return;
		    }			    
		    {   /* Look up hashcode: */
		        Vm_Int icat = cat - jS.s;
		        Vm_Int irat = rat - jS.s;
			Vm_Obj owner= OBJ_GET( obj_FolkBy_HashName, o, OBJ_PROP_PUBLIC );
			/* If owner is unknown, return hashName as err value: */
			if (owner == OBJ_NOT_FOUND) {
			    *++jS.s =o;
			    return;
			} else {
			    if (OBJ_IS_OBJ(owner)) {
				if (!OBJ_IS_FOLK(owner)) {
				    *++jS.s =stg_From_Asciz("Object value in /folkBy/hashName not Guest or User");
				    return;
				}
			    } else {
				*++jS.s =stg_From_Asciz("Non-object value in /folkBy/hashName");
				return;
			    }
			}
			cat         = jS.s + icat;
			rat         = jS.s + irat;
			*cat++ = owner;
		    }
		}
		continue;

	    case JOB_ENBYTE_BIGNUM:
		if (rat + 1 > jS.s) {
		    *++jS.s = stg_From_Asciz("Missing data for BIGNUM op");
		}
		{   Vm_Unt len  = (Vm_Unt)OBJ_TO_CHAR( *rat++ ) & 0xFF;
		    if (rat + len + 1 > jS.s) {
			*++jS.s = stg_From_Asciz("Missing data for BIGNUM op");
		    }
		    {   Vm_Int sign = (OBJ_TO_CHAR( *rat++ ) & 0xFF) == 1 ? (Vm_Int)1 : (Vm_Int)-1;
		        Vm_Int icat = cat - jS.s;
		        Vm_Int irat = rat - jS.s;
			Vm_Obj bnm  = bnm_Alloc( len, (Vm_Int)0 );
			Bnm_P  b    = BNM_P(bnm);
			int    i;
			cat         = jS.s + icat;
			rat         = jS.s + irat;
			for (i = 0;   i < len;   ++i) {
			    Vm_Unt u   = (Vm_Unt)0;
			    u |= OBJ_TO_CHAR( *rat++ )      ;
			    u |= OBJ_TO_CHAR( *rat++ ) <<  8;
			    u |= OBJ_TO_CHAR( *rat++ ) << 16;
			    u |= OBJ_TO_CHAR( *rat++ ) << 24;
			    #if VM_INTBYTES==8
			    u |= OBJ_TO_CHAR( *rat++ ) << 32;
			    u |= OBJ_TO_CHAR( *rat++ ) << 40;
			    u |= OBJ_TO_CHAR( *rat++ ) << 48;
			    u |= OBJ_TO_CHAR( *rat++ ) << 56;
			    #endif
			    b->slot[i] = u;
			}
			b->sign     = sign;
			*cat++      = bnm;
		}   }
		continue;

	    case JOB_ENBYTE_PROXY:
		if (rat + (op-0x80) > jS.s) {
		    *++jS.s = stg_From_Asciz("Missing data for PROXY op");
		    return;
		}
		{

		    Vm_Int i0  = (Vm_Int)0;
		    Vm_Int i1  = (Vm_Int)0;
		    Vm_Int i2  = (Vm_Int)0;

		    Vm_Int ha  = (Vm_Int)0;	/* hash_name	*/

		    ha |= OBJ_TO_CHAR( *rat++ )      ;
		    ha |= OBJ_TO_CHAR( *rat++ ) <<  8;
		    ha |= OBJ_TO_CHAR( *rat++ ) << 16;
		    ha |= OBJ_TO_CHAR( *rat++ ) << 24;
                    #if VM_INTBYTES>4
		    ha |= OBJ_TO_CHAR( *rat++ ) << 32;
		    ha |= OBJ_TO_CHAR( *rat++ ) << 40;
		    ha |= OBJ_TO_CHAR( *rat++ ) << 48;
		    ha |= OBJ_TO_CHAR( *rat++ ) << 56;
		    #endif

		    i0 |= OBJ_TO_CHAR( *rat++ )      ;
		    i0 |= OBJ_TO_CHAR( *rat++ ) <<  8;
		    i0 |= OBJ_TO_CHAR( *rat++ ) << 16;
		    i0 |= OBJ_TO_CHAR( *rat++ ) << 24;
                    #if VM_INTBYTES>4
		    i0 |= OBJ_TO_CHAR( *rat++ ) << 32;
		    i0 |= OBJ_TO_CHAR( *rat++ ) << 40;
		    i0 |= OBJ_TO_CHAR( *rat++ ) << 48;
		    i0 |= OBJ_TO_CHAR( *rat++ ) << 56;
		    #endif

		    i1 |= OBJ_TO_CHAR( *rat++ )      ;
		    i1 |= OBJ_TO_CHAR( *rat++ ) <<  8;
		    i1 |= OBJ_TO_CHAR( *rat++ ) << 16;
		    i1 |= OBJ_TO_CHAR( *rat++ ) << 24;
                    #if VM_INTBYTES>4
		    i1 |= OBJ_TO_CHAR( *rat++ ) << 32;
		    i1 |= OBJ_TO_CHAR( *rat++ ) << 40;
		    i1 |= OBJ_TO_CHAR( *rat++ ) << 48;
		    i1 |= OBJ_TO_CHAR( *rat++ ) << 56;
		    #endif

		    i2 |= OBJ_TO_CHAR( *rat++ )      ;
		    i2 |= OBJ_TO_CHAR( *rat++ ) <<  8;
		    i2 |= OBJ_TO_CHAR( *rat++ ) << 16;
		    i2 |= OBJ_TO_CHAR( *rat++ ) << 24;
                    #if VM_INTBYTES>4
		    i2 |= OBJ_TO_CHAR( *rat++ ) << 32;
		    i2 |= OBJ_TO_CHAR( *rat++ ) << 40;
		    i2 |= OBJ_TO_CHAR( *rat++ ) << 48;
		    i2 |= OBJ_TO_CHAR( *rat++ ) << 56;
		    #endif

		    {   /* Look up hashcode: */
		        Vm_Int icat = cat - jS.s;
		        Vm_Int irat = rat - jS.s;
			Vm_Obj owner= OBJ_GET( obj_FolkBy_HashName, OBJ_FROM_INT(ha), OBJ_PROP_PUBLIC );
			Vm_Obj obj  = OBJ_NIL;
			/* If owner is unknown, return hashName as err value: */
			if (owner == OBJ_NOT_FOUND) {
			    *++jS.s =OBJ_FROM_INT(ha);
			    return;
			} else {
			    if (OBJ_IS_OBJ(owner)) {
				if (OBJ_ISA_USR(owner)) {
			            /* Owner is a native, try to reconstruct pointer: */
				    Vm_Int ok;
				    obj = obj_Ints3_To_Dbref( &ok, i0, i1, i2 );
				    if (!ok) {
					*++jS.s =stg_From_Asciz("Expired or broken dbref");
					return;
				    }
				} else if (OBJ_IS_CLASS_GST(owner)) {
			            /* Owner is a guest, build a proxy: */
				    obj = obj_Alloc( OBJ_CLASS_A_PRX, 0 );

				    {   Prx_P  p   = PRX_P( obj );

					p->guest   = owner;

					p->i0	   = OBJ_FROM_INT( i0   );
					p->i1	   = OBJ_FROM_INT( i1   );
					p->i2	   = OBJ_FROM_INT( i2   );
				    }
				} else {
				    *++jS.s =stg_From_Asciz("Object value in /folkBy/hashName not Guest or User");
				    return;
				}
			    } else {
				*++jS.s =stg_From_Asciz("Non-object value in /folkBy/hashName");
				return;
			    }
			}
			cat         = jS.s + icat;
			rat         = jS.s + irat;
			*cat++ = obj;
			continue;

		    }
		}
		continue;

	    default:
		*++jS.s = stg_From_Asciz("Unsupported opcode");
		return;
	    }
	}

	/* Update block size: */
	jS.s    = cat;
	*jS.s   = OBJ_FROM_BLK( cat-mat );

	/* Return success flag: */
	*++jS.s = OBJ_NIL;
    }
}

 /***********************************************************************/
 /*-    job_Debyte_Muqnet_Header -- Support function for next.		*/
 /***********************************************************************/

char*
job_Debyte_Muqnet_Header(
    Vm_Obj *to,
    Vm_Obj *from,
#ifndef NEW_HEADER
    Vm_Obj *fromVersion,
#endif
    Vm_Obj *opcode,
    Vm_Obj *randompad,
    Vm_Int *header_length,
    Vm_Int *bignum_offset,
    Vm_Int *bignum_length
){
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    /* Avoid returning uninitialized values for   */
    /* invalid headers -- I hate uninit-val bugs: */
    *to              = OBJ_FROM_INT(0);
    *from            = OBJ_FROM_INT(0);
#ifndef NEW_HEADER
    *fromVersion     = OBJ_FROM_INT(0);
#endif
    *opcode          = OBJ_FROM_INT(0);
    *randompad       = OBJ_FROM_INT(0);
    *bignum_offset   = 0;
    *bignum_length   = 0;
    *header_length   = 0;

    /* Do a sanity-check pass verifying that the */
    /* block consists entirely of characters:    */
    {   Vm_Obj* p;
	for (p = jS.s - block_len;  p < jS.s;   ++p) {
	    if (!OBJ_IS_CHAR(*p)) {
		return "Block contains non-char data";
	    }
	}
    }

    {   /* Maybe parse optional 'longname' argument: */
	Vm_Obj* start_of_header = jS.s - block_len;
	Vm_Obj* rat             = start_of_header;
        int op = OBJ_TO_CHAR( *rat++ ) & 0xFF;
	if (op == JOB_ENBYTE_BIGNUM) {
	    if (rat + 1 > jS.s) {
		return "Missing data for BIGNUM op";
	    }
	    {   Vm_Unt len  = (Vm_Unt)OBJ_TO_CHAR( *rat++ ) & 0xFF;
		if (rat + len + 1 > jS.s) {
		    return "Missing data for BIGNUM op";
		}
		*bignum_offset = jS.s-rat;
		*bignum_length = len;
		rat += len*VM_INTBYTES+1;	/* +1 for sign byte */
	    }
	    op = OBJ_TO_CHAR( *rat++ ) & 0xFF;
	} else {
	    *bignum_offset = 0;
	    *bignum_length = 0;
	}

	/* Parse mandatory 'from' arg: */
        if (op != JOB_ENBYTE_IMMEDIATE) {
	    return "debyteMuqHeader: needed IMMEDIATE";
	}
	if (rat + VM_INTBYTES > jS.s) {
	    return "Missing data for IMMEDIATE op";
	}
	{   Vm_Obj o = (Vm_Obj)0;
	    o |= OBJ_TO_CHAR( *rat++ )      ;
	    o |= OBJ_TO_CHAR( *rat++ ) <<  8;
	    o |= OBJ_TO_CHAR( *rat++ ) << 16;
	    o |= OBJ_TO_CHAR( *rat++ ) << 24;
	    #if VM_INTBYTES==8
	    o |= OBJ_TO_CHAR( *rat++ ) << 32;
	    o |= OBJ_TO_CHAR( *rat++ ) << 40;
	    o |= OBJ_TO_CHAR( *rat++ ) << 48;
	    o |= OBJ_TO_CHAR( *rat++ ) << 56;
	    #endif

	    /* Another sanity check: */
	    if (OBJ_TYPE(o) != OBJ_TYPE_INT) {
		return "Needed fixnum in header";
	    }			    
	    *from = o;
	}

#ifndef NEW_HEADER
	/* Parse mandatory 'fromVersion' arg: */
	op = OBJ_TO_CHAR( *rat++ ) & 0xFF;
        if (op != JOB_ENBYTE_IMMEDIATE) {
	    return "debyteMuqHeader: needed IMMEDIATE";
	}
	if (rat + VM_INTBYTES > jS.s) {
	    return "Missing data for IMMEDIATE op";
	}
	{   Vm_Obj o = (Vm_Obj)0;
	    o |= OBJ_TO_CHAR( *rat++ )      ;
	    o |= OBJ_TO_CHAR( *rat++ ) <<  8;
	    o |= OBJ_TO_CHAR( *rat++ ) << 16;
	    o |= OBJ_TO_CHAR( *rat++ ) << 24;
	    #if VM_INTBYTES==8
	    o |= OBJ_TO_CHAR( *rat++ ) << 32;
	    o |= OBJ_TO_CHAR( *rat++ ) << 40;
	    o |= OBJ_TO_CHAR( *rat++ ) << 48;
	    o |= OBJ_TO_CHAR( *rat++ ) << 56;
	    #endif

	    /* Another sanity check: */
	    if (OBJ_TYPE(o) != OBJ_TYPE_INT) {
		return "Needed fixnum in header";
	    }			    
	    *fromVersion = o;
	}
#endif

	/* Parse mandatory 'to' arg: */
	op = OBJ_TO_CHAR( *rat++ ) & 0xFF;
        if (op != JOB_ENBYTE_IMMEDIATE) {
	    return "debyteMuqHeader: needed IMMEDIATE";
	}
	if (rat + VM_INTBYTES > jS.s) {
	    return "Missing data for IMMEDIATE op";
	}
	{   Vm_Obj o = (Vm_Obj)0;
	    o |= OBJ_TO_CHAR( *rat++ )      ;
	    o |= OBJ_TO_CHAR( *rat++ ) <<  8;
	    o |= OBJ_TO_CHAR( *rat++ ) << 16;
	    o |= OBJ_TO_CHAR( *rat++ ) << 24;
	    #if VM_INTBYTES==8
	    o |= OBJ_TO_CHAR( *rat++ ) << 32;
	    o |= OBJ_TO_CHAR( *rat++ ) << 40;
	    o |= OBJ_TO_CHAR( *rat++ ) << 48;
	    o |= OBJ_TO_CHAR( *rat++ ) << 56;
	    #endif

	    /* Another sanity check: */
	    if (OBJ_TYPE(o) != OBJ_TYPE_INT) {
		return "Needed fixnum in header";
	    }			    
	    *to = o;
	}

	/* Parse mandatory 'randompad': */
	op = OBJ_TO_CHAR( *rat++ ) & 0xFF;
        if (op != JOB_ENBYTE_IMMEDIATE) {
	    return "debyteMuqHeader: needed IMMEDIATE";
	}
	if (rat + VM_INTBYTES > jS.s) {
	    return "Missing data for IMMEDIATE op";
	}
	{   Vm_Obj o = (Vm_Obj)0;
	    o |= OBJ_TO_CHAR( *rat++ )      ;
	    o |= OBJ_TO_CHAR( *rat++ ) <<  8;
	    o |= OBJ_TO_CHAR( *rat++ ) << 16;
	    o |= OBJ_TO_CHAR( *rat++ ) << 24;
	    #if VM_INTBYTES==8
	    o |= OBJ_TO_CHAR( *rat++ ) << 32;
	    o |= OBJ_TO_CHAR( *rat++ ) << 40;
	    o |= OBJ_TO_CHAR( *rat++ ) << 48;
	    o |= OBJ_TO_CHAR( *rat++ ) << 56;
	    #endif

	    /* Another sanity check: */
	    if (OBJ_TYPE(o) != OBJ_TYPE_INT) {
		return "Needed fixnum in header";
	    }			    
	    *randompad = o;
	}

	/* Parse mandatory 'opcode': */
	op = OBJ_TO_CHAR( *rat++ ) & 0xFF;
        if (op >= 0x10) {
	    return "debyteMuqHeader: needed CHAR SEQ";
	}
	if (rat + 1 > jS.s) {
	    return"Missing data for CHAR_SEQ op";
	}
	*opcode = OBJ_FROM_INT( OBJ_TO_CHAR( *rat++ ) );

	/* Return length of header: */
	*header_length = rat-start_of_header;

	/* Return success: */
	return NULL;
    }
}

 /***********************************************************************/
 /*-    job_P_Debyte_Muqnet_Header -- Extract + debyte packet header.	*/
 /***********************************************************************/

void
job_P_Debyte_Muqnet_Header(
    void
){
    Vm_Obj to          = OBJ_NIL;
    Vm_Obj from        = OBJ_NIL;
#ifndef NEW_HEADER
    Vm_Obj fromVersion = OBJ_NIL;
#endif
    Vm_Obj longname    = OBJ_NIL;
    Vm_Obj randompad   = OBJ_NIL;
    Vm_Obj opcode      = OBJ_NIL;
    Vm_Int header_length;
    Vm_Int bignum_offset;
    Vm_Unt bignum_length;
    Vm_Int block_len = OBJ_TO_BLK( jS.s[ 0 ] );
    job_Guarantee_Blk_Arg( 0 );
    job_Guarantee_N_Args(   block_len+2 );

    job_Guarantee_Headroom( 5 );

    /* Do the actual parse: */
    {   char* err = job_Debyte_Muqnet_Header(
	    &to,
	    &from,
#ifndef NEW_HEADER
	    &fromVersion,
#endif
	    &opcode,
	    &randompad,
	    &header_length,
	    &bignum_offset,
	    &bignum_length
	);
        if (err) {
	    *++jS.s = stg_From_Asciz(err);
	    *++jS.s = OBJ_NIL;
	    *++jS.s = OBJ_NIL;
	    *++jS.s = OBJ_NIL;
	    *++jS.s = OBJ_NIL;
	    return;
	}
    }

    if (bignum_length) {
	Vm_Obj* rat = jS.s - bignum_offset;
	Vm_Int sign = (
		(OBJ_TO_CHAR( *rat++ ) & 0xFF) == 1
		? (Vm_Int)1
		: (Vm_Int)-1
	);
	Vm_Int irat = rat - jS.s;
	Vm_Obj bnm  = bnm_Alloc( bignum_length, (Vm_Int)0 );
	Bnm_P  b    = BNM_P(bnm);
	int    i;
	rat         = jS.s + irat;
	for (i = 0;   i < bignum_length;   ++i) {
	    Vm_Unt u   = (Vm_Unt)0;
	    u |= OBJ_TO_CHAR( *rat++ )      ;
	    u |= OBJ_TO_CHAR( *rat++ ) <<  8;
	    u |= OBJ_TO_CHAR( *rat++ ) << 16;
	    u |= OBJ_TO_CHAR( *rat++ ) << 24;
	    #if VM_INTBYTES==8
	    u |= OBJ_TO_CHAR( *rat++ ) << 32;
	    u |= OBJ_TO_CHAR( *rat++ ) << 40;
	    u |= OBJ_TO_CHAR( *rat++ ) << 48;
	    u |= OBJ_TO_CHAR( *rat++ ) << 56;
	    #endif
	    b->slot[i] = u;
	}
	b->sign     = sign;
	longname    = bnm;
    }

    *++jS.s = OBJ_NIL;
#ifndef NEW_HEADER
    *++jS.s = fromVersion;
#endif
    *++jS.s = from;
    *++jS.s = to;
    *++jS.s = longname;
    *++jS.s = opcode;
    return;
}

 /***********************************************************************/
 /*-    job_Ephemeral_List_Loc -- Return offset of given list cell.	*/
 /***********************************************************************/

Vm_Int /* Vm_Obj* offset of object relative to l_bot. */
job_Ephemeral_List_Loc(
    Vm_Obj *owner, /* Returns owner here.                            */
    Vm_Obj  obj    /* We assume OBJ_IS_EPHEMERAL_LIST(o) to be true. */
) {
    /* Search loop stack for cons call at given offset.	*/
    /* If we find one, return it;  Otherwise, issue	*/
    /* an error message:				*/
    register Vm_Int offset = OBJ_TO_EPHEMERAL_LIST(obj);
    register Vm_Int link   = (Vm_Int) jS.j.ephemeral_lists;
    register Vm_Uch* l_bot = (Vm_Uch*)jS.l_bot;
    register Vm_Uch* l;
    register Vm_Uch* o = &l_bot[ offset ];
    while (link) {
	l = (Vm_Uch*)( &l_bot[ link ] );

	/* If looks like right frame: */
	if ((Vm_Uch*)JOB_PREV_STACKFRAME(l) < o) {

	    /* Figure number of slots in stackframe, */
	    /* subtracting off non-cons fields:      */           
	    Vm_Unt slots = JOB_SIZE_STACKFRAME(l) -3;

	    /* Figure offset of given ephemeral      */
	    /* relative to first cell in frame:      */
	    Vm_Unt loc   = (((Vm_Obj*)l)-4)-((Vm_Obj*)o);
	    
	    /* Sanity-check offset within frame: */
	    if ((loc > slots-2)
            ||  (loc & 1)
            ){
		MUQ_WARN ("Invalid ephemeralList pointer");
	    }

	    /* Return cell owner: */
	    *owner = *((((Vm_Obj*)l)-3)-slots);

	    /* Return in cell location in */
            /* position-independent form: */
	    return ((Vm_Obj*)o) - ((Vm_Obj*)l_bot);
	}
	link = (Vm_Int)(((Vm_Obj*)l)[-2]);
    }
    MUQ_WARN ("Invalid ephemeralList pointer");
    return 0; /* Just to quiet compilers. */
}

 /***********************************************************************/
 /*-    job_Ephemeral_Struct_Loc -- Return offset of given struct.	*/
 /***********************************************************************/

Vm_Int /* Vm_Obj* offset of structure relative to l_bot. */
job_Ephemeral_Struct_Loc(
    Vm_Int *len, /* We teturn length-in-slots here.                  */
    Vm_Obj  obj  /* We assume OBJ_IS_EPHEMERAL_STRUCT(o) to be true. */
) {
    /* Search loop stack for object at given offset.	*/
    /* If we find one, return it;  Otherwise, issue	*/
    /* an error message:				*/
    register Vm_Int offset = OBJ_TO_EPHEMERAL_STRUCT(obj);
    register Vm_Int link   = (Vm_Int) jS.j.ephemeral_structs;
    register Vm_Uch* l_bot = (Vm_Uch*)jS.l_bot;
    register Vm_Uch* l;
    while (link) {
	l = (Vm_Uch*)( &l_bot[ link ] );

	if (l-l_bot == offset) {
	    /* Found our stackframe.  We're pointing */
	    /* to the zerofar boundary tags for      */
	    /* stackframe, but we want to return a   */
	    /* pointer to the zeronearest word of    */
	    /* useful (non-boundary-tag) data in the */
	    /* stackframe, so:                       */

	    /* Return number of slots in struct:     */
	    *len = JOB_SIZE_STACKFRAME(l) -4;

	    /* Step to start of previous stackframe: */
	    l = (Vm_Uch*)JOB_PREV_STACKFRAME(l);

	    /* Step over two boundary tags to zero-  */
	    /* nearest data word:                    */
	    l += 2*sizeof(Vm_Obj);

	    /* Return in position-independent form:  */
	    return ((Vm_Obj*)l) - ((Vm_Obj*)l_bot);
	}
	link = (Vm_Int)(((Vm_Obj*)l)[-2]);
    }

    MUQ_WARN ("Invalid ephemeral-struct pointer");
    return 0; /* Just to quiet compilers. */
}

 /***********************************************************************/
 /*-    job_Ephemeral_Vector_Loc -- Return offset of given vector.	*/
 /***********************************************************************/

Vm_Int /* Vm_Obj* offset of vector relative to l_bot. */
job_Ephemeral_Vector_Loc(
    Vm_Int *len, /* We return length-in-slots here.                  */
    Vm_Obj  obj  /* We assume OBJ_IS_EPHEMERAL_VECTOR(o) to be true. */
) {
    /* Search loop stack for object at given offset.	*/
    /* If we find one, return it;  Otherwise, issue	*/
    /* an error message:				*/
    register Vm_Int offset = OBJ_TO_EPHEMERAL_VECTOR(obj);
    register Vm_Int link   = (Vm_Int) jS.j.ephemeral_vectors;
    register Vm_Uch* l_bot = (Vm_Uch*)jS.l_bot;
    register Vm_Uch* l;
    while (link) {
	l = (Vm_Uch*)( &l_bot[ link ] );

	if (l-l_bot == offset) {
	    /* Found our stackframe.  We're pointing */
	    /* to the zerofar boundary tags for      */
	    /* stackframe, but we want to return a   */
	    /* pointer to the zeronearest word of    */
	    /* useful (non-boundary-tag) data in the */
	    /* stackframe, so:                       */

	    /* Return number of slots in vector:     */
	    *len = JOB_SIZE_STACKFRAME(l) -4;

	    /* Step to start of previous stackframe: */
	    l = (Vm_Uch*) JOB_PREV_STACKFRAME(l);

	    /* Step over two boundary tags to zero-  */
	    /* nearest data word:                    */
	    l += 2*sizeof(Vm_Obj);

	    /* Return in position-independent form:  */
	    return ((Vm_Obj*)l) - ((Vm_Obj*)l_bot);
	}
	link = (Vm_Int)(((Vm_Obj*)l)[-2]);
    }
    MUQ_WARN ("Invalid ephemeral-vector pointer");
    return 0; /* Just to quiet compilers. */
}

 /***********************************************************************/
 /*-    job_Push_Catchframe --						*/
 /***********************************************************************/

void
job_Push_Catchframe(
    Vm_Unt offset
) {
    register Vm_Obj* l = jS.l;
    Vm_Unt saved_pc = (jS.pc - (Vm_Uch*)jS.k) + offset;

    /* Guarantee that we have enough room */
    /* to push a block consisting solely  */
    /* of an error string, and then a     */
    /* "Yes, we found an error" 1 on top: */
    job_Guarantee_Headroom(4);

    /* Catch tag: */
    job_Guarantee_N_Args(  1);

    /* Check for loop stack overflow: */
    if (l + 6 >= jS.l_top) {
        job_Guarantee_Loop_Headroom( 6 );
	l = jS.l;
    }

    /* Add a CATCH stackframe: */

    ++l; *l = 6*sizeof(Vm_Obj);
    ++l; *l = OBJ_FROM_INT(saved_pc);
    ++l; *l = OBJ_FROM_INT(((Vm_Uch*)(jS.s-1))-((Vm_Uch*)jS.s_bot));
    ++l; *l = *jS.s;
    ++l; *l = JOB_STACKFRAME_CATCH;
    ++l; *l = 6*sizeof(Vm_Obj);

    jS.l = l;      /* Remember new loop  topofstack. */
}

 /***********************************************************************/
 /*-    job_P_Ephemeral_Cons -- "ephemeralCons" function.		*/
 /***********************************************************************/

void
job_P_Ephemeral_Cons(
    void
) {
    Vm_Obj cdr = jS.s[ 0];
    Vm_Obj car = jS.s[-1];

    register Vm_Obj* l;
    Vm_Int offset;

    job_Guarantee_N_Args(  2 );

    /* Check for loop stack overflow: */
    l = jS.l;
    if (l + 7 >= jS.l_top) {
	job_Guarantee_Loop_Headroom( 7 );
	l = jS.l;
    }

    /* Add an EPHEMERAL_LIST stackframe: */
    ++l; *l = 7*sizeof(Vm_Obj);
    ++l; *l = jS.j.acting_user;		/* 'owner' field */
    ++l; *l = car;
    /* Note location of new ephemeral cons cell: */
    offset = ((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot;
    ++l; *l = cdr;
    ++l; *l = jS.j.ephemeral_lists;
    ++l; *l = JOB_STACKFRAME_EPHEMERAL_LIST;
    ++l; *l = 7*sizeof(Vm_Obj);

    jS.l  = l;      /* Remember new loop topofstack. */

    /* Add ephemeral list to */
    /* job's linklist of them: */
    jS.j.ephemeral_lists = (Vm_Obj) (((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot);

    /* Return a Vm_Obj handle  */
    /* for ephemeral list:   */
    *--jS.s = OBJ_FROM_EPHEMERAL_LIST( offset );
}

 /***********************************************************************/
 /*-    job_P_Make_Ephemeral_List -- ]e					*/
 /***********************************************************************/

void
job_P_Make_Ephemeral_List(
    void
) {
    register Vm_Obj* l = jS.l;
    Vm_Int depth = jS.s - jS.s_bot;
    Vm_Int values;
    Vm_Int slots;
    Vm_Int i;
    Vm_Obj prev = OBJ_NIL;
    Vm_Obj this;
    /* Find the '[' marking bottom of list: */
    for (i = 0;   i < depth;   ++i) {
	if (jS.s[-i] == OBJ_BLOCK_START)   break;
    }
    if (i == depth) MUQ_WARN ("]e found no matching [");

    /* Figure number of values between [ and ]e */
    values = i;

    /* Don't bother pushing empty   */
    /* ephemeral list stackframes: */
    if (!values) {
        *jS.s = prev;
	return;
    }

    /* Compute number of stack slots we'll need */
    /* for the complete ephemeral list -- two   */
    /* slots per cell, plus overhead:           */
    slots  = 2*values + 5;

    /* Make sure we have enough stack space:    */
    if (l + slots >= jS.l_top) {
	job_Guarantee_Loop_Headroom( slots );
	l = jS.l;
    }

    /* Add an EPHEMERAL_LIST stackframe: */
    ++l; *l = slots*sizeof(Vm_Obj);
    ++l; *l = jS.j.acting_user;		/* 'owner' field */
    for (i = 0;   i < values;   ++i) {
        ++l; *l = jS.s[-i];
	this = OBJ_FROM_EPHEMERAL_LIST( ((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot );
        ++l; *l = prev;
	prev = this;
    }
    ++l; *l = jS.j.ephemeral_lists;
    ++l; *l = JOB_STACKFRAME_EPHEMERAL_LIST;
    ++l; *l = slots*sizeof(Vm_Obj);

    jS.l  = l;      /* Remember new loop topofstack. */

    /* Add ephemeral list to */
    /* job's linklist of them: */
    jS.j.ephemeral_lists = (Vm_Obj) (((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot);

    /* Pop values: */
    jS.s -= values;

    /* Return a Vm_Obj handle  */
    /* for ephemeral list:   */
    *jS.s = prev;
}

 /***********************************************************************/
 /*-    job_make_ephemeral_struct -- EPHEMERAL_STRUCT stackframe.	*/
 /***********************************************************************/

static Vm_Obj
job_make_ephemeral_struct(
    Vm_Obj key
) {
    register Vm_Obj* l;
    Vm_Int offset;
    Vm_Unt slots;
    Vm_Unt frame;
    Vm_Unt u;
    Vm_Obj ini[ KEY_MAX_SLOTS ];

    {   Key_P  k = KEY_P(key);
	Vm_Unt u;
	slots    = OBJ_TO_UNT( k->unshared_slots );
	frame    = slots + 6;
	for (u = 0;   u < slots;   ++u)   ini[u] = k->slot[u].initval;
    }

    /* Check for loop stack overflow: */
    l = jS.l;
    if (l + frame >= jS.l_top) {
	job_Guarantee_Loop_Headroom( frame );
	l = jS.l;
    }

    /* Add a EPHEMERAL_STRUCT stackframe: */
    ++l; *l = frame*sizeof(Vm_Obj);
    ++l; *l = jS.j.acting_user;		/* 'owner' field */
    ++l; *l = key;			/* 'isA'  field */
    for (u = 0;   u < slots;   ++u) { ++l;  *l = ini[u]; }
    ++l; *l = jS.j.ephemeral_structs;
    ++l; *l = JOB_STACKFRAME_EPHEMERAL_STRUCT;
    ++l; *l = frame*sizeof(Vm_Obj);

    jS.l  = l;      /* Remember new loop topofstack. */

    /* Note location of new ephemeral vector: */
    offset = ((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot;

    /* Add ephemeral struct to */
    /* job's linklist of them: */
    jS.j.ephemeral_structs = (Vm_Obj) offset;

    /* Return a Vm_Obj handle  */
    /* for ephemeral struct:   */
    return OBJ_FROM_EPHEMERAL_STRUCT( offset );
}

 /***********************************************************************/
 /*-    job_P_Make_Ephemeral_Vector -- EPHEMERAL_VECTOR stackframe.	*/
 /***********************************************************************/

void
job_P_Make_Ephemeral_Vector(
    void
){
    register Vm_Obj* l = jS.l;
    Vm_Int offset;
    Vm_Unt length = OBJ_TO_UNT( jS.s[ 0] );
    Vm_Obj init   =             jS.s[-1]  ;
    job_Guarantee_N_Args(  2 );
    job_Guarantee_Int_Arg( 0 );

    /* Check for loop stack overflow: */
    if (l + (length+6) >= jS.l_top) {
	job_Guarantee_Loop_Headroom( length+6 );
	l = jS.l;
    }

    /* Add an EPHEMERAL_VECTOR stackframe: */
    ++l; *l = (length+6)*sizeof(Vm_Obj);
    ++l; *l = jS.j.acting_user;
    ++l; *l = evc_Type_Summary.builtin_class;
    {   register Vm_Int i;
	for (i = length+1;   --i > 0;   ) {
            ++l;
            *l = init;
    }   }
    ++l; *l = jS.j.ephemeral_vectors;
    ++l; *l = JOB_STACKFRAME_EPHEMERAL_VECTOR;
    ++l; *l = (length+6)*sizeof(Vm_Obj);

    jS.l  = l;      /* Remember new loop  topofstack. */

    /* Note location of new ephemeral vector: */
    offset = ((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot;

    /* Add ephemeral vector to */
    /* job's linklist of them: */
    jS.j.ephemeral_vectors = (Vm_Obj) offset;

    /* Return a Vm_Obj handle  */
    /* for ephemeral vector:   */
    *--jS.s = OBJ_FROM_EPHEMERAL_VECTOR( offset );
}

 /***********************************************************************/
 /*-    job_P_Make_Ephemeral_Vector_From_Block -- EPHEMERAL_VECTOR again*/
 /***********************************************************************/

void
job_P_Make_Ephemeral_Vector_From_Block(
    void
) {
    Vm_Int offset;
    Vm_Unt length  = OBJ_TO_BLK( jS.s[ 0 ] );

    register Vm_Obj* l = jS.l;
    job_Guarantee_N_Args(   length+2 );
    job_Guarantee_Blk_Arg( 0 );

    /* Check for loop stack overflow: */
    if (l + (length+6) >= jS.l_top) {
	job_Guarantee_Loop_Headroom( length+6 );
	l = jS.l;
    }

    /* Add an EPHEMERAL_VECTOR stackframe: */
    ++l; *l = (length+6)*sizeof(Vm_Obj);
    ++l; *l = jS.j.acting_user;
    ++l; *l = evc_Type_Summary.builtin_class;
    {   register Vm_Int i;
	for (i = length+1;   --i > 0;   ) {
            ++l;
            *l = jS.s[ -i ];
    }   }
    ++l; *l = jS.j.ephemeral_vectors;
    ++l; *l = JOB_STACKFRAME_EPHEMERAL_VECTOR;
    ++l; *l = (length+6)*sizeof(Vm_Obj);
    jS.l  = l;      /* Remember new loop  topofstack. */

    /* Note location of new ephemeral vector: */
    offset = ((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot;

    /* Add ephemeral vector to */
    /* job's linklist of them: */
    jS.j.ephemeral_vectors = (Vm_Obj) offset;

    /* Return a Vm_Obj handle  */
    /* for ephemeral vector:   */
    jS.s -= length+1;
    *jS.s = OBJ_FROM_EPHEMERAL_VECTOR( offset );
}

 /***********************************************************************/
 /*-    job_P_Push_Fun_Binding -- Deposit a FUN_BIND stackframe.	*/
 /***********************************************************************/

void
job_P_Push_Fun_Binding(
    void
) {
    register Vm_Obj* l = jS.l;
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Symbol_Arg( 0 );

    /* Check for loop stack overflow: */
    if (l + 6 >= jS.l_top) {
	job_Guarantee_Loop_Headroom( 6 );
	l = jS.l;
    }

    /* Add a FUN_BIND stackframe: */
    ++l; *l = 6*sizeof(Vm_Obj);
    ++l; *l = jS.s[ 0];
    ++l; *l = jS.s[-1];
    ++l; *l = jS.j.function_bindings;
    ++l; *l = JOB_STACKFRAME_FUN_BIND;
    ++l; *l = 6*sizeof(Vm_Obj);

    jS.l  = l;      /* Remember new loop  topofstack. */
    jS.s -= 2;

    jS.j.function_bindings = (Vm_Obj)(
	((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot
    );
}

 /***********************************************************************/
 /*-    job_P_Push_Var_Binding -- Deposit a VAR_BIND stackframe.	*/
 /***********************************************************************/

void
job_P_Push_Var_Binding(
    void
) {
    register Vm_Obj* l = jS.l;
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Symbol_Arg( 0 );

    /* Check for loop stack overflow: */
    if (l + 6 >= jS.l_top) {
	job_Guarantee_Loop_Headroom( 6 );
	l = jS.l;
    }

    /* Add a VAR_BIND stackframe: */
    ++l; *l = 6*sizeof(Vm_Obj);
    ++l; *l = jS.s[ 0];
    ++l; *l = jS.s[-1];
    ++l; *l = jS.j.variable_bindings;
    ++l; *l = JOB_STACKFRAME_VAR_BIND;
    ++l; *l = 6*sizeof(Vm_Obj);

    jS.l  = l;      /* Remember new loop  topofstack. */
    jS.s -= 2;

    jS.j.variable_bindings = (Vm_Obj)(
	((Vm_Uch*)l) - (Vm_Uch*)jS.l_bot
    );
}

 /***********************************************************************/
 /*-    job_P_Push_Tagtopframe -- Deposit a TAGTOP stackframe.		*/
 /***********************************************************************/

void
job_P_Push_Tagtopframe(
    void
) {
    register Vm_Obj* l = jS.l;

    /* Check for loop stack overflow: */
    if (l + 4 >= jS.l_top) {
	job_Guarantee_Loop_Headroom( 4 );
	l = jS.l;
    }

    /* Add a TAGTOP stackframe: */
    ++l; *l = 4*sizeof(Vm_Obj);
    ++l; *l = OBJ_FROM_INT(((Vm_Uch*)(jS.s))-((Vm_Uch*)jS.s_bot));
    ++l; *l = JOB_STACKFRAME_TAGTOP;
    ++l; *l = 4*sizeof(Vm_Obj);

    jS.l = l;      /* Remember new loop  topofstack. */
}

 /***********************************************************************/
 /*-    job_Push_Tagframe --						*/
 /***********************************************************************/
void
job_Push_Tagframe(
    Vm_Unt offset
) {
    register Vm_Obj* l = jS.l;
    Vm_Unt saved_pc = (jS.pc - (Vm_Uch*)jS.k) + offset;

    /* Guarantee that we have enough room */
    /* to push a block consisting solely  */
    /* of an error string, and then a     */
    /* "Yes, we found an error" 1 on top: */
    job_Guarantee_Headroom(3);

    /* Catch tag: */
    job_Guarantee_N_Args(  1);

    /* Check for loop stack overflow: */
    if (l + 5 >= jS.l_top) {
        job_Guarantee_Loop_Headroom( 5 );
	l = jS.l;
    }

    /* Add a TAG stackframe: */

    ++l; *l = 5*sizeof(Vm_Obj);
    ++l; *l = OBJ_FROM_INT(saved_pc);
    ++l; *l = *jS.s;
    ++l; *l = JOB_STACKFRAME_TAG;
    ++l; *l = 5*sizeof(Vm_Obj);

    jS.l = l;      /* Remember new loop  topofstack. */
}


 /***********************************************************************/
 /*-    job_Push_Errset --						*/
 /***********************************************************************/

void
job_Push_Errset(
    /* 'offset' gives the code address at which */
    /* execution should resume should this      */
    /* error catcher actually be activated:     */
    Vm_Unt offset
) {
    register Vm_Obj* l;
    Vm_Unt saved_pc = (jS.pc - (Vm_Uch*)jS.k) + offset;


    /* Guarantee that we have enough room */
    /* to push a block consisting solely  */
    /* of an error string, and then a     */
    /* "Yes, we found an error" 1 on top: */
    job_Guarantee_Headroom(3);

    /* Check for loop stack overflow: */
    l = jS.l;
    if (l + 6 >= jS.l_top) {
        job_Guarantee_Loop_Headroom( 6 );
	l = jS.l;
    }

    /* Add a CATCH stackframe: */

    ++l; *l = 6*sizeof(Vm_Obj);
    ++l; *l = OBJ_FROM_INT(saved_pc);
    ++l; *l = OBJ_FROM_INT(((Vm_Uch*)(jS.s))-((Vm_Uch*)jS.s_bot));
    ++l; *l = OBJ_ERROR_TAG;
    ++l; *l = JOB_STACKFRAME_CATCH;
    ++l; *l = 6*sizeof(Vm_Obj);

    jS.l = l;      /* Remember new loop  topofstack. */
}

 /***********************************************************************/
 /*-    job_Blanch_Protectframe -- Change PROTECT to VANILLA frame.	*/
 /***********************************************************************/

void
job_Blanch_Protectframe(
    /* 'offset' gives the code address at which */
    /* execution should resume should we want   */
    /* to skip the }alwaysDo{...} clause.  We  */
    /* want to skip the clause if the job did   */
    /* a fork in the after{...} clause, and we  */
    /* are the child, because we want the       */
    /* alwaysDo{...} clause executed exactly   */
    /* once.  The fork operators signal this    */
    /* situation by changing all PROTECT stack- */
    /* frames into VANILLA stackframes in the   */
    /* child job.                               */
    Vm_Unt offset
) {

    /* This function is called at the            */
    /* end of an always{ clause, to change the   */
    /* PROTECT frame which signals that special  */
    /* error handling is in force for the clause */
    /* to a VANILLA frame which signals that the */
    /* protected clause completed normally.	 */

    /* Skip the clause if frame is already VANILLA: */
    if (jS.l[-1] == JOB_STACKFRAME_VANILLA) {
	jS.pc += offset;
	return;
    }

    if (jS.l[-1] != JOB_STACKFRAME_PROTECT
    &&  jS.l[-1] != JOB_STACKFRAME_PROTECT_CHILD
    ){
	MUQ_WARN ("POP_PROTECTFRAME: No frame!");
    }

   jS.l[-1] = JOB_STACKFRAME_VANILLA;
}

 /***********************************************************************/
 /*-    job_Push_Protectframe --					*/
 /***********************************************************************/

void
job_Push_Protectframe(
    /* 'offset' gives the code address at which */
    /* execution should resume should this      */
    /* catcher actually be activated:           */
    Vm_Unt offset
) {
    register Vm_Obj* l = jS.l;
    Vm_Unt saved_pc = (jS.pc - (Vm_Uch*)jS.k) + offset;

    /* Check for loop stack overflow: */
    if (l + 4 >= jS.l_top) {
        job_Guarantee_Loop_Headroom( 4 );
	l = jS.l;
    }

    /* Add a PROTECT stackframe: */
    ++l; *l = 4*sizeof(Vm_Obj);
    ++l; *l = OBJ_FROM_UNT(saved_pc);
    ++l; *l = JOB_STACKFRAME_PROTECT;
    ++l; *l = 4*sizeof(Vm_Obj);

    jS.l = l;      /* Remember new loop  topofstack. */
}

 /***********************************************************************/
 /*-    job_Push_Protectchildframe --					*/
 /***********************************************************************/

void
job_Push_Protectchildframe(
    /* 'offset' gives the code address at which */
    /* execution should resume should this      */
    /* catcher actually be activated:           */
    Vm_Unt offset
) {
    register Vm_Obj* l = jS.l;
    Vm_Unt saved_pc = (jS.pc - (Vm_Uch*)jS.k) + offset;

    /* Check for loop stack overflow: */
    if (l + 4 >= jS.l_top) {
        job_Guarantee_Loop_Headroom( 4 );
	l = jS.l;
    }

    /* Add a PROTECT_CHILD stackframe: */
    ++l; *l = 4*sizeof(Vm_Obj);
    ++l; *l = OBJ_FROM_UNT(saved_pc);
    ++l; *l = JOB_STACKFRAME_PROTECT_CHILD;
    ++l; *l = 4*sizeof(Vm_Obj);

    jS.l = l;      /* Remember new loop  topofstack. */
}

 /***********************************************************************/
 /*-    job_Push_Signalframe --						*/
 /***********************************************************************/

#ifdef OLD
void
job_Push_Signalframe(
    Vm_Obj last_queue		/* Queue to return to on handler exit.	*/
) {
    /* Guarantee that we have enough room */
    /* to push two bottom-of-stack vals:  */
    job_Guarantee_Headroom(2);

    {    /* Check for loop stack overflow: */
	Vm_Obj old_blocked = JOB_P(jS.job)->blocked_signals;
	register Vm_Obj* l = jS.l;
	if (l + 8 >= jS.l_top) {
	    job_Guarantee_Loop_Headroom( 8 );
	    l = jS.l;
	}

	/* Add a SIGNAL stackframe: */
        *++l = 8*sizeof(Vm_Obj);
	*++l = jS.j.privs;
	*++l = jS.j.acting_user;
	*++l = OBJ_FROM_INT(jS.s_bot - jS.s_0); /* logical bottom of stack */
	*++l = last_queue;
	*++l = old_blocked;
	*++l = JOB_STACKFRAME_SIGNAL;
        *++l = 8*sizeof(Vm_Obj);

	jS.l = l;      /* Remember new loop  topofstack. */
    }

    /* Isolate handler stack data from      */
    /* data currently on stack, by pushing  */
    /* two bottom-of-stack entries and then */
    /* resetting logical bottom-of-stack:   */
    {   register Vm_Obj* s = jS.s;

	*++s = OBJ_FROM_BOTTOM(0);
	*++s = OBJ_FROM_BOTTOM(0);

	jS.s = s;
    }

    /* Set new logical bottom of stack: */
    jS.s_bot = jS.s;
}
#endif

 /***********************************************************************/
 /*-    job_Symbol_Function --						*/
 /***********************************************************************/

/* buggo: This fn should be inlined someday. */
Vm_Obj
job_Symbol_Function(
    Vm_Obj symbol	/* We trust this to be a valid symbol. */
) {
    /* Search loop stack for bindings of the given     */
    /* symbol.  If we find one, return it;  Otherwise, */
    /* return the value slot of the symbol.            */
    register Vm_Obj vb = jS.j.function_bindings;
    if (jS.j.function_bindings) {
	register Vm_Uch* lb = (Vm_Uch*)jS.l_bot;
	do{
	    register Vm_Obj* l  = (Vm_Obj*)( &lb[ vb ] );
	    if (l[-4]==symbol)   return l[-3];
	    vb = l[-2];
	} while (vb);
    }
    return SYM_P(symbol)->function;
}

 /***********************************************************************/
 /*-    job_Symbol_Value --						*/
 /***********************************************************************/

/* buggo: This fn should be inlined someday. */
Vm_Obj
job_Symbol_Value(
    Vm_Obj symbol	/* We trust this to be a valid symbol. */
) {
    /* Search loop stack for bindings of the given     */
    /* symbol.  If we find one, return it;  Otherwise, */
    /* return the value slot of the symbol.            */
    register Vm_Obj vb = jS.j.variable_bindings;
    if (jS.j.variable_bindings) {
	register Vm_Uch* lb = (Vm_Uch*)jS.l_bot;
	do{
	    register Vm_Obj* l  = (Vm_Obj*)( &lb[ vb ] );
	    if (l[-4]==symbol)   return l[-3];
	    vb = l[-2];
	} while (vb);
    }
    vb = SYM_P(symbol)->value;
    if (vb != OBJ_FROM_BOTTOM(0))   return vb;
    {   Vm_Uch buf[ 64 ];
	job_Sprint_Vm_Obj(
	    buf, buf+64,
	    SYM_P(symbol)->name,
	    /*quotestrings:*/FALSE
        );
	MUQ_WARN("Unbound symbol: %s",buf);
    }
    return OBJ_FROM_INT(0);	/* Just to quiet compilers. */
}

 /***********************************************************************/
 /*-    job_Symbol_Boundp --						*/
 /***********************************************************************/

Vm_Obj
job_Symbol_Boundp(
    Vm_Obj symbol	/* We trust this to be a valid symbol. */
) {
    /* Search loop stack for bindings of the given     */
    /* symbol.  If we find one, return it;  Otherwise, */
    /* return the value slot of the symbol.            */
    register Vm_Obj vb = jS.j.variable_bindings;
    if (jS.j.variable_bindings) {
	register Vm_Uch* lb = (Vm_Uch*)jS.l_bot;
	do{
	    register Vm_Obj* l  = (Vm_Obj*)( &lb[ vb ] );
	    if (l[-4]==symbol)   return OBJ_T;
	    vb = l[-2];
	} while (vb);
    }
    vb = SYM_P(symbol)->value;
    if (vb != OBJ_FROM_BOTTOM(0))   return OBJ_T;
    return OBJ_NIL;
}

 /***********************************************************************/
 /*-    job_Push_Thunkframe --						*/
 /***********************************************************************/

void
job_Push_Thunkframe(
    Vm_Int stack_offset
) {

    /* Guarantee that we have enough room */
    /* to push two bottom-of-stack vals:  */
    job_Guarantee_Headroom(2);

    {   /* Check for loop stack overflow: */
	register Vm_Obj* l = jS.l;
	if (l + 8 >= jS.l_top) {
	    job_Guarantee_Loop_Headroom( 8 );
	    l = jS.l;
	}

	/* Add a THUNK stackframe: */
        *++l = 8*sizeof(Vm_Obj);
	*++l = jS.j.privs;
	*++l = jS.j.acting_user;
	*++l = jS.j.actual_user;
	*++l = OBJ_FROM_INT(jS.s_bot - jS.s_0); /* logical bottom of stack */
	*++l = OBJ_FROM_INT(stack_offset);
	*++l = JOB_STACKFRAME_THUNK;
        *++l = 8*sizeof(Vm_Obj);

	jS.l = l;      /* Remember new loop  topofstack. */
    }

    /* Hack state to keep thunk from doing  */
    /* naughty things it has no right to do:*/
    jS.j.privs	     &= ~JOB_PRIVS_ALL_POWERS;       /* Clear all privileges */
    jS.j.privs       |=  JOB_PRIVS_ALL_RESTRICTIONS; /* Set all restrictions */
/* Buggo, need to worry about bytes_owned and objects_owned */
    jS.j.acting_user  = obj_U_Nul;
    jS.j.actual_user  = obj_U_Nul;

    /* Hack data stack to isolate thunk from*/
    /* data currently on stack, by pushing  */
    /* two bottom-of-stack entries and then */
    /* resetting logical bottom-of-stack:   */
    {   register Vm_Obj* s = jS.s;

	*++s = OBJ_FROM_BOTTOM(0);
	*++s = OBJ_FROM_BOTTOM(0);

	jS.s = s;
    }

    /* Set new logical bottom of stack: */
    jS.s_bot = jS.s;
}

 /***********************************************************************/
 /*-    job_State_Update -- Copy job_RunState stuff to current job.	*/
 /***********************************************************************/

void
job_State_Update(
    void
) {
    Vm_Int stack_bottom;
    /* buggo, not updating op_count* yet */

    /* Note pc offset: */
    jS.v[-2]    = OBJ_FROM_UNT( jS.pc - (Vm_Uch*)jS.k );

    /* Save new data and loop stack lengths, and note data stack bottom: */
    stack_bottom   = (jS.s_bot - jS.s_0);
    {   Vec_P  v   = VEC_P( jS.data_vector );
        Vm_Int len = 1 + (jS.s - v->slot);
	STK_P(    jS.j.data_stack  )->length = OBJ_FROM_INT(len);
	vm_Dirty( jS.j.data_stack  );
        vm_Dirty( jS.  data_vector );
    }

    {   Vec_P  v   = VEC_P( jS.loop_vector );
        Vm_Int len = 1 + (jS.l - v->slot);
	STK_P(    jS.j.loop_stack  )->length = OBJ_FROM_INT(len);
	vm_Dirty( jS.j.loop_stack  );
        vm_Dirty( jS.  loop_vector );
    }

    /* Copy our state from global cache job_RunState: */
    {   Job_P p = JOB_P( jS.job );

        /* Core state can be blindly copied: */
	p->j                 = jS.j;

	/* Hard pointers need to be converted to int offsets: */
	p->stack_bottom    = OBJ_FROM_UNT( stack_bottom  );
        p->frame_base      = OBJ_FROM_UNT( jS.v-jS.l_bot );

	ops_left                -= job_RunState.ops - ops_initial;
	ops_done_this_timeslice += job_RunState.ops - ops_initial;
	ops_initial              = job_RunState.ops;
	p->op_count = OBJ_FROM_UNT(
	    OBJ_TO_UNT(p->op_count) + ops_done_this_timeslice
	);
	ops_done_this_timeslice= 0;
	rex_Uncache( &p->rex );

	vm_Dirty( jS.job );
    }

    /* Update *_owned fields in acting_user: */
    {   Usr_P u = USR_P(                 jS.j.acting_user );

	u->bytes_owned   = OBJ_FROM_UNT( jS.bytes_owned   );
	u->objects_owned = OBJ_FROM_UNT( jS.objects_owned );

	vm_Dirty(                        jS.j.acting_user );
    }
}

 /***********************************************************************/
 /*-    job_State_Publish -- Copy job state to job_RunState		*/
 /***********************************************************************/

void
job_State_Publish(
    Vm_Obj job
) {
    /* Check for already published: */
    if (jS.job)      MUQ_FATAL ("Duplicate Publish!");

    /* Copy core state directly to */
    /* global cache job_RunState:  */
    {   Job_P p = JOB_P(job);
	jS.job  = job ;
	jS.j    = p->j;

	rex_Cache( &p->rex );
    }

    /* Update *_owned and *_quota   */
    /* fields from acting_user:	    */
    {   Usr_P u = USR_P( jS.j.acting_user );
	jS.byte_quota	 = OBJ_TO_UNT( u->byte_quota    );
	jS.bytes_owned	 = OBJ_TO_UNT( u->bytes_owned   );
	jS.object_quota  = OBJ_TO_UNT( u->object_quota  );
	jS.objects_owned = OBJ_TO_UNT( u->objects_owned );

	/* This is a little out of place here, */
	/* but it is a handy place to put it:  */
	#ifdef HAVE_OPENGL
	{   Vm_Int privs = OBJ_TO_UNT( u->priv_bits     );
	    if      (privs & USR_UNRESTRICTED_OPENGL) ogl_Select_OpenGL_Access_Level( OGL_UNRESTRICTED_OPENGL );
	    else if (privs & USR_AVATAR_OPENGL      ) ogl_Select_OpenGL_Access_Level(       OGL_AVATAR_OPENGL );
	    else                                      ogl_Select_OpenGL_Access_Level(           OGL_NO_OPENGL );
	}
	#endif
    }

    /* Lock data and loop stacks in ram: */

    jS.data_vector = STK_P( jS.j.data_stack )->vector;
    vm_Register_Hard_Pointer( &jS.data_vector, (void**)&jS.s     );
    vm_Register_Hard_Pointer( &jS.data_vector, (void**)&jS.s_bot );
    vm_Register_Hard_Pointer( &jS.data_vector, (void**)&jS.s_top );
    vm_Register_Hard_Pointer( &jS.data_vector, (void**)&jS.s_0   );

    jS.loop_vector = STK_P( jS.j.loop_stack )->vector;
    vm_Register_Hard_Pointer( &jS.loop_vector, (void**)&jS.v     );
    vm_Register_Hard_Pointer( &jS.loop_vector, (void**)&jS.l     );
    vm_Register_Hard_Pointer( &jS.loop_vector, (void**)&jS.l_bot );
    vm_Register_Hard_Pointer( &jS.loop_vector, (void**)&jS.l_top );



    /* Set up hard pointers into loop stack: */
    {   Vm_Unt frame = OBJ_TO_UNT( JOB_P(job)->frame_base );
	Vm_Unt vec   = jS.loop_vector;
	Vm_Unt len   = vec_Len( vec );
	Vm_Int  sp   = OBJ_TO_INT( STK_P( jS.j.loop_stack )->length );
	Vec_P  v     = VEC_P( vec );
        jS.l         = &v->slot[ sp  -1 ];
        jS.l_bot     = &v->slot[      0 ];
        jS.l_top     = &v->slot[ len -1 ]; /* Buggo? Is "-1" needed? */
        jS.v         = jS.l_bot + frame;
    }

    /* Lock in ram executable for current fn, */
    /* Set up pc and k hard pointers:	      */
    {
        Vm_Obj x  = jS.v[-1];
        Vm_Obj pc = jS.v[-2];

	jS.x_obj  = x;

	/* Register program counter: */
	vm_Register_Hard_Pointer( &jS.x_obj, (void**)&jS.pc );

	/* Register local-constants pointer: */
	vm_Register_Hard_Pointer( &jS.x_obj, (void**)&jS.k  );

	/* Initialize k: */
        jS.k  = &CFN_P( jS.x_obj )->vec[ 0 ];

        /* Initialize program counter to correct offset: */
        jS.pc    = ((Vm_Uch*)jS.k) + OBJ_TO_UNT( pc );

	/* jS.pc is now correct, so we don't want anyone */
	/* incrementing it before executing instruction: */
	jS.instruction_len = 0;
    }

    /* Set up hard pointers into data stack: */
    {   Vm_Int sbot= OBJ_TO_INT( JOB_P(job)->stack_bottom );
	Vm_Unt vec = jS.data_vector;
	Vm_Unt len = vec_Len( vec );
	Vm_Int  sp = OBJ_TO_INT( STK_P( jS.j.data_stack )->length );
	Vec_P  v   = VEC_P(   vec );
        jS.s_0     = &v->slot[      0 ];
        jS.s_bot   = &v->slot[ sbot   ];
        jS.s	   = &v->slot[ sp  -1 ];
        jS.s_top   = &v->slot[ len -1 ]; /* Buggo? Is "-1" needed? */

	/* As a fine point, note that the following check   */
        /* needs to be done -after- all of our              */
	/* vm_Register_Hard_Pointer() calls have been made, */
	/* else if the check fails, when we Unpublish we'll */
        /* wind up trying to Unregister pointers which were */
        /* never Registered, and crash the server:          */
	job_Guarantee_Headroom( 1 );	/* Yes, '1', not '0'. */
    }

    #if MUQ_IS_PARANOID
    /* As with above comment, this check needs to be made */
    /* -after- all vm_Register_Hard_Pointer()s are done:  */
    if (!OBJ_IS_CFN(jS.v[-1]))   MUQ_WARN ("Need executable");
    #endif



    /* 'now' isn't our responsibility... */



    ops_done_this_timeslice = 0;
}

 /***********************************************************************/
 /*-    job_State_Unpublish -- Copy job_RunState to job state		*/
 /***********************************************************************/

void
job_State_Unpublish(
    void
) {
    if (!jS.job)   MUQ_FATAL ("Duplicate Unpublish!");

    job_State_Update();

    /* Unlock objects. Fastest if opposite order from locking: */
    vm_Unregister_Hard_Pointer( (void**)&jS.l_top );
    vm_Unregister_Hard_Pointer( (void**)&jS.l_bot );
    vm_Unregister_Hard_Pointer( (void**)&jS.l     );

    vm_Unregister_Hard_Pointer( (void**)&jS.v     );

    vm_Unregister_Hard_Pointer( (void**)&jS.s_0   );
    vm_Unregister_Hard_Pointer( (void**)&jS.s_top );
    vm_Unregister_Hard_Pointer( (void**)&jS.s_bot );
    vm_Unregister_Hard_Pointer( (void**)&jS.s     );

    vm_Unregister_Hard_Pointer( (void**)&jS.k     );
    vm_Unregister_Hard_Pointer( (void**)&jS.pc    );

    /* buggo, need to dirty var vectors here soon (?) */


    /* Avoid unpublishing twice in succession: */
    jS.job = FALSE;
}

 /***********************************************************************/
 /*-    job_THUNK0 -- Evaluate thunk on top of data stack.		*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    Overview							*/
 /***********************************************************************/
/*
   Thunk0() is called when a fast prim that
cares about the type of its first stack arg
discovers that first stack arg is in fact a
thunk.

   Our job is to evaluate the thunk, replace
it with the resulting value, then transparently
restart the instruction.

*/


void
job_THUNK0(
    JOB_PRIM_ARGS_TYPED
) {
    /* We need an instruction length to	    */
    /* keep JOB_CACHE_ARGS happy. It gets   */
    /* used by job_Call to construct the    */
    /* return address.  Since we want the   */
    /* call to the thunk to return to the   */
    /* current instruction when done, we    */
    /* take the instruction length as zero: */
    #undef  ILEN
    #define ILEN 0
    JOB_CACHE_ARGS;

    /* Deposit a special stackframe to      */
    /* restore current context after thunk  */
    /* completes execution:                 */
    job_Push_Thunkframe(0);

    /* Implement normal call to thunk.      */
    /* Remember two underflow guards have   */
    /* been pushed on data stack by above:  */
    job_Call( jS.s[-2] );

    JOB_UNCACHE_ARGS;
}

 /***********************************************************************/
 /*-    job_THUNK1 -- Evaluate thunk below top of data stack.		*/
 /***********************************************************************/

void
job_THUNK1(
    JOB_PRIM_ARGS_TYPED
) {
    /* We need an instruction length to	    */
    /* keep JOB_CACHE_ARGS happy. It gets   */
    /* used by job_Call to construct the    */
    /* return address.  Since we want the   */
    /* call to the thunk to return to the   */
    /* current instruction when done, we    */
    /* take the instruction length as zero: */
    #undef  ILEN
    #define ILEN 0

    JOB_CACHE_ARGS;

    /* Deposit a special stackframe to      */
    /* store current context after thunk    */
    /* completes execution:                 */
    job_Push_Thunkframe(-1);

    /* Implement normal call to thunk.      */
    /* Remember two underflow guards have   */
    /* been pushed on data stack by above:  */
    job_Call( jS.s[-3] );

    JOB_UNCACHE_ARGS;
}

 /***********************************************************************/
 /*-    job_ThunkN -- Evaluate thunk for slow prim, if present.		*/
 /***********************************************************************/

/* If argument N is a thunk, we want to evaluate  */
/* the thunk at this point and retry current      */
/* instruction after replacing thunk by its       */
/* return value.  Otherwise, we do nothing.       */

void
job_ThunkN(
    Vm_Int n	/* Stack slot to check for thunk in, <= 0 */
) {
    register Vm_Obj*  c = &job_RunState.s[n];

    if (job_Type0[*c&0xFF] == JOB_TYPE_t){

	/* Deposit a special stackframe to      */
	/* store current context after thunk    */
	/* completes execution:                 */
	job_Push_Thunkframe( n );

	/* Implement normal call to thunk.      */
	/* Remember two underflow guards have   */
	/* been pushed on data stack by above.  */
	/* We want the thunk call to return	*/
	/* to the current instruction and	*/
	/* retry it, so we make the current	*/
	/* instruction look zero bytes long	*/
	/* for job_Call()'s benefit:		*/
	jS.instruction_len = 0;
	job_Call( jS.s[n-2] );

	/* longjmp() back to job_Run(), to escape */
	/* the prim function currently trying to  */
	/* execute.  This trades a slower thunk   */
        /* invocation for faster prim execution   */
	/* when no thunks are present: longjump() */
	/* is pretty slow, but we avoid having    */
	/* to check return value from Guarantee_* */
	/* fns in the prims:                      */
	/* (buggo? Might consider switching to	  */
	/* continuation passing style to get	  */
	/* around this, once we get gcc to	  */
	/* implement tail recursion.)		  */
	#if MUQ_IS_PARANOID
	if (!job_longjmp_buf_is_valid) MUQ_FATAL ("job_longjmp_buf invalid!");
	#endif
	longjmp( job_longjmp_buf, 1 );
    }
}

 /***********************************************************************/
 /*-    job_TIMESLICE_OVER -- Handle job reaching timeslice limit	*/
 /***********************************************************************/

void
job_TIMESLICE_OVER(
    JOB_PRIM_ARGS_TYPED
) {
    /* We need a dummy instruction length   */
    /* to keep JOB_CACHE_ARGS happy. It     */
    /* never gets used:                     */
    #undef  ILEN
    #define ILEN 0

    JOB_CACHE_ARGS;
}

 /***********************************************************************/
 /*-    job_UNIMPLEMENTED_OPCODE --					*/
 /***********************************************************************/

void
job_UNIMPLEMENTED_OPCODE(
    JOB_PRIM_ARGS_TYPED
) {
    /* We need a dummy instruction length   */
    /* to keep JOB_CACHE_ARGS happy. It     */
    /* never gets used:                     */
    #undef  ILEN
    #define ILEN 0

    JOB_CACHE_ARGS;
    MUQ_WARN ("Wrong argument type(s)");
}

 /***********************************************************************/
 /*-    job_UNDERFLOW -- Handle job underflowing data stack		*/
 /***********************************************************************/

void
job_UNDERFLOW(
    JOB_PRIM_ARGS_TYPED
) {
    /* We need a dummy instruction length   */
    /* to keep JOB_CACHE_ARGS happy. It     */
    /* never gets used:                     */
    #undef  ILEN
    #define ILEN 0

    JOB_CACHE_ARGS;
    MUQ_WARN ("Stack underflow");
}

 /***********************************************************************/
 /*-    job_Unimplemented_Slow_Opcode --				*/
 /***********************************************************************/

void
job_Unimplemented_Slow_Opcode(
    void
) {
    MUQ_WARN ("Bad secondary opcode");
}

 /***********************************************************************/
 /*-    job_Underflow -- Handle job underflowing data stack		*/
 /***********************************************************************/

void
job_Underflow(
    void
) {
    MUQ_WARN ("Stack underflow");
}

 /***********************************************************************/
 /*-    job_Code_Signature -- Hash job_Code[] contents			*/
 /***********************************************************************/

Vm_Obj
job_Code_Signature(
    void
) {
    /**********************************************/
    /* It would be nice to use a CRC, but I don't */
    /* have source to one right at hand just now. */
    /* The point of this function is to allow us  */
    /* to detect a mismatch between the db loaded */
    /* and the instruction set of the Muq server, */
    /* and signal a probable error rather than    */
    /* just crashing obscurely.  We store a hash  */
    /* of job_Code[] in the db, compute one for   */
    /* the server on the fly at startup, and then */
    /* compare the two.                           */
    /**********************************************/
    Vm_Obj signature = 0;
    Vm_Int i;
    for (i = JOB_CODE_MAX;  i --> 0;  ) {
	signature ^= (
	    job_Code[i].arity << (i & 0xF)  |
	    job_Code[i].arity >> (i & 0xF)
	);
    }
    return OBJ_FROM_UNT( signature );
}


 /***********************************************************************/
 /*-    Public fns, standard, startup/shutdown/etc.			*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    job_Startup -- start-of-world stuff.				*/
 /***********************************************************************/

  /**********************************************************************/
  /*-   ignore_fpe_signal -- Ignore SIGFPE (floating point exception).	*/
  /**********************************************************************/

static void
ignore_fpe_signal(
    void
) {
    if (signal( SIGFPE, SIG_IGN ) == SIG_ERR) {
	MUQ_FATAL (
	    "job.c:ignore_fpe_signal: Error ignoring SIGFPE?!"
	);	    
    }
}

  /**********************************************************************/
  /*-   ignore_pipe_signal -- Ignore SIGPIPE (write to broken pipe).	*/
  /**********************************************************************/

static void
ignore_pipe_signal(
    void
) {
    /* Added this 95Aug04 because Pakrat reported */
    /* Muq was occasionally dying with a "broken  */
    /* pipe" error, I think after telnet hangups: */
    if (signal( SIGPIPE, SIG_IGN ) == SIG_ERR) {
	MUQ_FATAL (
	    "job.c:ignore_pipe_signal: Error ignoring SIGPIPE?!"
	);	    
    }
}

  /**********************************************************************/
  /*-   catch_interrupt_signal -- Catch SIGINT ((^C).			*/
  /**********************************************************************/

   /*********************************************************************/
   /*-  sig_int --                                     			*/
   /*********************************************************************/

static RETSIGTYPE
sig_int(
    int signal_number
) {
    /* Reset handler so that repeated ^Cs won't */
    /* kill us before we can exit cleanly on    */
    /* SysV:                                    */
    signal( SIGINT, sig_int );

    /* We don't want to stop job in middle of a */
    /* virtual instruction or such, so we just  */
    /* set a flag, and close down next time     */
    /* execution gets to job_Run():             */
    job_End_Of_Run = TRUE;
}

   /*********************************************************************/
   /*-  sig_hup --                                     			*/
   /*********************************************************************/

static RETSIGTYPE
sig_hup(
    int signal_number
) {
    /* Reset handler so that repeated HUPs won't */
    /* kill us before we can exit cleanly on     */
    /* SysV.  This isn't as likely as getting    */
    /* multiple ^Cs, but it's cheap insurance:   */
    signal( SIGHUP, sig_hup );

    /* We don't want to stop job in middle of a */
    /* virtual instruction or such, so we just  */
    /* set a flag, and close down next time     */
    /* execution gets to job_Run():             */
    job_End_Of_Run = TRUE;
}

   /*********************************************************************/
   /*-  sig_term --                                    			*/
   /*********************************************************************/

static RETSIGTYPE
sig_term(
    int signal_number
) {
    /* Reset handler so that repeated TERMs won't */
    /* kill us before we can exit cleanly on      */
    /* SysV.  This isn't as likely as getting     */
    /* multiple ^Cs, but it's cheap insurance:    */
    signal( SIGTERM, sig_term );

    /* We don't want to stop job in middle of a */
    /* virtual instruction or such, so we just  */
    /* set a flag, and close down next time     */
    /* execution gets to job_Run():             */
    job_End_Of_Run = TRUE;
}

   /*********************************************************************/
   /*-  sig_chld --                                    			*/
   /*********************************************************************/

static RETSIGTYPE
sig_chld(
    int signal_number
) {
    /* Ask for news on our children. */
    /* Avoid blocking in waitpid():  */
    int status;
    int child_pid = waitpid(
	-1,			/* Wait for any child. */
	&status,
	WNOHANG			/* Don't block waiting.*/
    );

    /* Reset handler.  Irix manpages  */
    /* suggest that doing this before */
    /* doing the waitpid() can lead   */
    /* to an infinite loop:           */
    signal( SIGCHLD, sig_chld );

    /*   Negative child_pid indicates */
    /* an error of some sort.         */
    /*   Zero child_pid indicates no  */
    /* data available -- probably     */
    /* a spurious interrupt from a    */
    /* user loose with 'kill' or      */
    /* such.                          */
    /*   We ignore both cases:        */
    if (child_pid > 0) {
	skt_Child_Changed( child_pid, status );
    }
}

   /*********************************************************************/
   /*-  catch_SIGINT -- Catch SIGINT ((^C).				*/
   /*********************************************************************/

static void
catch_SIGINT(
    void
) {
    if (signal( SIGINT, sig_int ) == SIG_ERR) {
	MUQ_FATAL (
	    "job.c:catch_SIGINT: Error setting ^C handler?!"
	);	    
    }
}

   /*********************************************************************/
   /*-  catch_SIGHUP -- hangup						*/
   /*********************************************************************/

static void
catch_SIGHUP(
    void
) {
    if (signal( SIGHUP, sig_hup ) == SIG_ERR) {
	MUQ_FATAL (
	    "job.c:catch_SIGHUP: Error setting HUP handler?!"
	);	    
    }
}

   /*********************************************************************/
   /*-  catch_SIGTERM -- soft kill					*/
   /*********************************************************************/

static void
catch_SIGTERM(
    void
) {
    if (signal( SIGTERM, sig_term ) == SIG_ERR) {
	MUQ_FATAL (
	    "job.c:catch_SIGTERM: Error setting TERM handler?!"
	);	    
    }
}

   /*********************************************************************/
   /*-  catch_SIGCHLD -- Child status change				*/
   /*********************************************************************/

static void
catch_SIGCHLD(
    void
) {
    if (signal( SIGCHLD, sig_chld ) == SIG_ERR) {
	MUQ_FATAL (
	    "job.c:catch_SIGCHLD: Error setting CHLD handler?!"
	);	    
    }
}

  /**********************************************************************/
  /*-   maybe_rebuild_jb0 -- Validate /etc/jb0.				*/
  /**********************************************************************/

static Vm_Obj
maybe_rebuild_jb0(
    Vm_Int nukem
) {

    /* Make sure /etc/jb0 exists and contains a valid job.  */
    /* This job exists because lots of system code depends  */
    /* on there being a current job at all times, so we     */
    /* need a dummy to use during startup and such:         */
    Vm_Obj etc = obj_Etc;
    Vm_Obj jb0 = OBJ_GET( etc,     sym_Alloc_Asciz_Keyword("jb0"), OBJ_PROP_PUBLIC );
    if (/* nukem || */
        jb0==OBJ_NOT_FOUND
    || !OBJ_IS_OBJ(jb0)
    || !OBJ_IS_CLASS_JOB(jb0)
    ){
	/* The following is currently the only  */
	/* obj_Alloc( OBJ_CLASS_A_JOB ) call in */
	/* the server, hence the only time that */
	/* job.t:for_new() is invoked. Note we  */
	/* know that obj_Lib_Muf_Do_Signal is   */
	/* valid here, hence will get plugged   */
	/* into job0 and inherited by all other */
	/* jobs.                                */
	jb0 = obj_Alloc( OBJ_CLASS_A_JOB, 0 );
	OBJ_SET( etc, sym_Alloc_Asciz_Keyword("jb0"), jb0, OBJ_PROP_PUBLIC );
	OBJ_P(jb0)->objname = OBJ_FROM_BYT3('j','b','0');  vm_Dirty(jb0);
    }
    obj_Etc_Jb0 = jb0;

    /* Make /etc/jb0 the current job, so we */
    /* have a defined data stack etc:	    */
    jS.job = FALSE;
    job_State_Publish( jb0 );

    return jb0;
}

  /**********************************************************************/
  /*-   maybe_rebuild_ps_propdir -- Validate /ps.			*/
  /**********************************************************************/

#ifdef OLD
static Vm_Obj
maybe_rebuild_ps_propdir(
    Vm_Int nukem
) {
    Vm_Obj   ps  = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("ps"), OBJ_PROP_PUBLIC );

/* buggo: we should do cleanup on all jobs thus  */
/* nuked, including after{...}alwaysDo{...} and */
/* with-lock{...} processing.                    */

    if (nukem || ps==OBJ_NOT_FOUND || !OBJ_IS_OBJ(ps)) {
	/* fputs("job.c: recreating /ps.\n",stderr); */
	ps  = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
        OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("ps"), ps, OBJ_PROP_PUBLIC );
	OBJ_P(ps)->objname = OBJ_FROM_BYT3('/','p','s');  vm_Dirty(ps);
    }
    return   ps;
}
#else
static Vm_Obj
maybe_rebuild_ps_joq(
    Vm_Int nukem
) {
    Vm_Obj ps_kw = sym_Alloc_Asciz_Keyword("ps");
    Vm_Obj ps    = OBJ_GET( vm_Root(0), ps_kw, OBJ_PROP_PUBLIC );

    if (nukem
    || ps==OBJ_NOT_FOUND
    || !OBJ_IS_OBJ(ps)
    || !OBJ_IS_CLASS_JOQ(ps)
    ){
	/* fputs("job.c: recreating /ps.\n",stderr); */
	ps  = obj_Alloc( OBJ_CLASS_A_JOQ, 0 );
        OBJ_SET( vm_Root(0), ps_kw, ps, OBJ_PROP_PUBLIC );
	OBJ_P(ps)->objname = OBJ_FROM_BYT3('/','p','s');  vm_Dirty(ps);
    }
    return   ps;
}
#endif

  /**********************************************************************/
  /*-   rebuild_who_propdir -- Discard old /who, build empty one.	*/
  /**********************************************************************/

static Vm_Obj
rebuild_who_propdir(
    void
) {

    Vm_Obj   who = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );
    /* fputs("job.c: recreating /who.\n",stderr); */
    OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("who"), who, OBJ_PROP_PUBLIC );
    OBJ_P(who)->objname = stg_From_Asciz("/who");  vm_Dirty(who);
    return   who;
}

  /**********************************************************************/
  /*-   maybe_rebuild_usr_queue -- Validate .etc.usr.			*/
  /**********************************************************************/

static Vm_Obj
maybe_rebuild_usr_queue(
    Vm_Uch*nam
) {
    /* Make sure /etc/'nam' exists and is a usr queue: */
    Vm_Obj etc = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("etc"), OBJ_PROP_PUBLIC );
    Vm_Obj usq = OBJ_GET( etc,     sym_Alloc_Asciz_Keyword( nam )   , OBJ_PROP_PUBLIC );
    if (!OBJ_IS_OBJ(usq) || !OBJ_IS_CLASS_USQ(usq)) {
	/* fprintf(stderr,
	    "job.c: recreating /etc/%s.\n", nam
	); */
	usq = obj_Alloc( OBJ_CLASS_A_USQ, 0 );
	{   Vm_Obj n = stg_From_Asciz( nam );
	    USQ_P(usq)->o.objname = n; vm_Dirty(usq);
	}
	OBJ_SET( etc, sym_Alloc_Asciz_Keyword(nam), usq, OBJ_PROP_PUBLIC );
    }
    return usq;
}

  /**********************************************************************/
  /*-   maybe_rebuild_job_queue -- Validate /etc/run or /etc/doz or ...	*/
  /**********************************************************************/

static Vm_Obj
maybe_rebuild_job_queue(
    Vm_Uch*nam,
    Vm_Int nukem
) {
    /* Make sure /etc/'nam' exists and is a job queue: */
    Vm_Obj etc = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("etc"), OBJ_PROP_PUBLIC );
    Vm_Obj joq = OBJ_GET( etc,        sym_Alloc_Asciz_Keyword( nam ), OBJ_PROP_PUBLIC );
    if (nukem || !joq_Is_A_Joq(joq)) {
	/* fprintf(stderr,
	    "job.c: recreating /etc/%s.\n", nam
	); */
	joq = joq_Alloc(
	    etc,
	    OBJ_FROM_BYT3(nam[0],nam[1],nam[2])
	);
	if (STRCMP( nam, == ,"run" )) {
	    Joq_P j = JOQ_P(joq);
	    j->kind = OBJ_FROM_BYT3('r','u','n');
	    vm_Dirty(joq);
	}
	if (STRCMP( nam, == ,"doz" )) {
	    Joq_P j = JOQ_P(joq);
	    j->kind = OBJ_FROM_BYT3('d','o','z');
	    vm_Dirty(joq);
	}
	OBJ_SET( etc, sym_Alloc_Asciz_Keyword(nam), joq, OBJ_PROP_PUBLIC );
    }
    return joq;
}

  /**********************************************************************/
  /*-   job_enter_keywords -- Initialize handy global variables.	*/
  /**********************************************************************/

static void
job_enter_keywords(
    void
){
    job_Kw_Address_Family      = sym_Alloc_Asciz_Keyword( "addressFamily" );
    job_Kw_Any                 = sym_Alloc_Asciz_Keyword( "any"            );
    job_Kw_Character           = sym_Alloc_Asciz_Keyword( "character"      );
    job_Kw_Commandline	       = sym_Alloc_Asciz_Keyword( "commandline"    );
    job_Kw_Event               = sym_Alloc_Asciz_Keyword( "event"          );
    job_Kw_Function            = sym_Alloc_Asciz_Keyword( "function"       );
    job_Kw_Guest               = sym_Alloc_Asciz_Keyword( "guest"          );
    job_Kw_HashName            = sym_Alloc_Asciz_Keyword( "hashName"       );
    job_Kw_Host                = sym_Alloc_Asciz_Keyword( "host"           );
    job_Kw_Interactive_Function= sym_Alloc_Asciz_Keyword( "interactiveFunction");
    job_Kw_Interfaces          = sym_Alloc_Asciz_Keyword( "interfaces"     );
    job_Kw_Internet            = sym_Alloc_Asciz_Keyword( "internet"       );
    job_Kw_Ip0                 = sym_Alloc_Asciz_Keyword( "ip0"            );
    job_Kw_Ip1                 = sym_Alloc_Asciz_Keyword( "ip1"            );
    job_Kw_Ip2                 = sym_Alloc_Asciz_Keyword( "ip2"            );
    job_Kw_Ip3                 = sym_Alloc_Asciz_Keyword( "ip3"            );
    job_Kw_I0                  = sym_Alloc_Asciz_Keyword( "i0"             );
    job_Kw_I1                  = sym_Alloc_Asciz_Keyword( "i1"             );
    job_Kw_I2                  = sym_Alloc_Asciz_Keyword( "i2"             );
    job_Kw_Job                 = sym_Alloc_Asciz_Keyword( "job"            );
    job_Kw_Message_Stream      = sym_Alloc_Asciz_Keyword( "messageStream" );
    job_Kw_Name                = sym_Alloc_Asciz_Keyword( "name"           );
    job_Kw_Port                = sym_Alloc_Asciz_Keyword( "port"           );
    job_Kw_Protocol            = sym_Alloc_Asciz_Keyword( "protocol"       );
    job_Kw_Report_Function     = sym_Alloc_Asciz_Keyword( "reportFunction");
    job_Kw_Popen	       = sym_Alloc_Asciz_Keyword( "popen"          );
    job_Kw_Socket	       = sym_Alloc_Asciz_Keyword( "socket"         );
    job_Kw_Stream              = sym_Alloc_Asciz_Keyword( "stream"         );
    job_Kw_Test_Function       = sym_Alloc_Asciz_Keyword( "testFunction"  );
    job_Kw_Why                 = sym_Alloc_Asciz_Keyword( "why"            );

    job_Kw_Acting_User		= sym_Alloc_Asciz_Keyword( "actingUser");
    job_Kw_Actual_User		= sym_Alloc_Asciz_Keyword( "actualUser");
    job_Kw_Batch		= sym_Alloc_Asciz_Keyword( "batch"	);
    job_Kw_Blocked_Signals	= sym_Alloc_Asciz_Keyword( "blockedSignals");
    job_Kw_Car			= sym_Alloc_Asciz_Keyword( "car"	);
    job_Kw_Catch		= sym_Alloc_Asciz_Keyword( "catch"	);
    job_Kw_Cdr			= sym_Alloc_Asciz_Keyword( "cdr"	);
    job_Kw_Class		= sym_Alloc_Asciz_Keyword("class");
    job_Kw_Close		= sym_Alloc_Asciz_Keyword( "close"	);
    job_Kw_Mos_Generic		= sym_Alloc_Asciz_Keyword( "mosGeneric");
    job_Kw_Compiled_Function	= sym_Alloc_Asciz_Keyword("compiledFunction");
    job_Kw_Data			= sym_Alloc_Asciz_Keyword( "data"	);
    job_Kw_Datagram		= sym_Alloc_Asciz_Keyword( "datagram"	);
    job_Kw_Downcase		= sym_Alloc_Asciz_Keyword( "downcase"	);
    job_Kw_End_Job		= sym_Alloc_Asciz_Keyword( "endJob"	);
    job_Kw_Exec			= sym_Alloc_Asciz_Keyword( "exec"	);
    job_Kw_Ear			= sym_Alloc_Asciz_Keyword( "ear"	);
    job_Kw_Eof			= sym_Alloc_Asciz_Keyword( "eof"	);
    job_Kw_Ephemeral		= sym_Alloc_Asciz_Keyword( "ephemeral");
    job_Kw_Ephemeral_List	= sym_Alloc_Asciz_Keyword( "ephemeralList");
    job_Kw_Ephemeral_Object	= sym_Alloc_Asciz_Keyword( "ephemeralObject");
    job_Kw_Ephemeral_Struct	= sym_Alloc_Asciz_Keyword( "ephemeralStruct");
    job_Kw_Ephemeral_Vector	= sym_Alloc_Asciz_Keyword( "ephemeralVector");
    job_Kw_Eql			= sym_Alloc_Asciz_Keyword( "eql"	);
    job_Kw_Exit			= sym_Alloc_Asciz_Keyword( "exit"	);
    job_Kw_Format_String	= sym_Alloc_Asciz_Keyword( "formatString");
    job_Kw_Function_Binding	= sym_Alloc_Asciz_Keyword( "functionBinding");
    job_Kw_Goto			= sym_Alloc_Asciz_Keyword( "goto"	);
    job_Kw_Handlers		= sym_Alloc_Asciz_Keyword( "handlers"	);
    job_Kw_Handling		= sym_Alloc_Asciz_Keyword( "handling"	);
    job_Kw_Initform		= sym_Alloc_Asciz_Keyword( "initform"	);
    job_Kw_Initval		= sym_Alloc_Asciz_Keyword( "initval"	);
    job_Kw_Invert		= sym_Alloc_Asciz_Keyword( "invert"	);
    job_Kw_Job_Queue		= sym_Alloc_Asciz_Keyword( "jobQueue"	);
    job_Kw_Jump			= sym_Alloc_Asciz_Keyword( "jump"	);
    job_Kw_Junk			= sym_Alloc_Asciz_Keyword( "junk"	);
    job_Kw_Kind			= sym_Alloc_Asciz_Keyword( "kind"	);
    job_Kw_Lock			= sym_Alloc_Asciz_Keyword( "lock"	);
    job_Kw_Lock_Child		= sym_Alloc_Asciz_Keyword( "lockChild"	);
    job_Kw_Normal		= sym_Alloc_Asciz_Keyword( "normal"	);
    job_Kw_Owner		= sym_Alloc_Asciz_Keyword( "owner"	);
    job_Kw_Preserve		= sym_Alloc_Asciz_Keyword( "preserve"	);
    job_Kw_Privileges		= sym_Alloc_Asciz_Keyword( "privileges"	);
    job_Kw_Program_Counter	= sym_Alloc_Asciz_Keyword( "programCounter");
    job_Kw_Promise		= sym_Alloc_Asciz_Keyword( "promise"	);
    job_Kw_Protect		= sym_Alloc_Asciz_Keyword( "protect"	);
    job_Kw_Protect_Child	= sym_Alloc_Asciz_Keyword( "protectChild");
    job_Kw_Restart		= sym_Alloc_Asciz_Keyword( "restart"	);
    job_Kw_Return		= sym_Alloc_Asciz_Keyword( "return"	);
    job_Kw_Return_Slot		= sym_Alloc_Asciz_Keyword( "returnSlot");
    job_Kw_Signal		= sym_Alloc_Asciz_Keyword( "signal"	);
    job_Kw_Slot			= sym_Alloc_Asciz_Keyword( "slot"	);
    job_Kw_Slots		= sym_Alloc_Asciz_Keyword( "slots"	);
    job_Kw_Stack_Bottom		= sym_Alloc_Asciz_Keyword( "stackBottom");
    job_Kw_Stack_Depth		= sym_Alloc_Asciz_Keyword( "stackDepth");
    job_Kw_Symbol		= sym_Alloc_Asciz_Keyword( "symbol"	);
    job_Kw_Tag			= sym_Alloc_Asciz_Keyword( "tag"	);
    job_Kw_Tagtop		= sym_Alloc_Asciz_Keyword( "tagtop"	);
    job_Kw_Tcp			= sym_Alloc_Asciz_Keyword( "tcp"	);
    job_Kw_Throw		= sym_Alloc_Asciz_Keyword( "throw"	);
    job_Kw_Thunk		= sym_Alloc_Asciz_Keyword( "thunk"	);
    job_Kw_Tmp_User		= sym_Alloc_Asciz_Keyword( "tmp-user"	);
    job_Kw_Tty			= sym_Alloc_Asciz_Keyword( "tty"	);
    job_Kw_Udp			= sym_Alloc_Asciz_Keyword( "udp"	);
    job_Kw_Upcase		= sym_Alloc_Asciz_Keyword( "upcase"	);
    job_Kw_User			= sym_Alloc_Asciz_Keyword( "user"	);
    job_Kw_Vanilla		= sym_Alloc_Asciz_Keyword( "vanilla"	);
    job_Kw_Value		= sym_Alloc_Asciz_Keyword( "value"	);
    job_Kw_Variable_Binding	= sym_Alloc_Asciz_Keyword( "variableBinding");
    job_Kw_Variables		= sym_Alloc_Asciz_Keyword( "variables"	);

    job_Kw_Allocation		= sym_Alloc_Asciz_Keyword( "allocation");
    job_Kw_Dbname		= sym_Alloc_Asciz_Keyword( "dbname");
    job_Kw_Documentation	= sym_Alloc_Asciz_Keyword( "documentation");
    job_Kw_Keyword		= sym_Alloc_Asciz_Keyword( "keyword");
    job_Kw_Inherited		= sym_Alloc_Asciz_Keyword( "inherited");
    job_Kw_Initform		= sym_Alloc_Asciz_Keyword( "initform");
    job_Kw_Initarg		= sym_Alloc_Asciz_Keyword( "initarg");
    job_Kw_Instance		= sym_Alloc_Asciz_Keyword( "instance");
    job_Kw_Is_A			= sym_Alloc_Asciz_Keyword( "isA");
    job_Kw_Type			= sym_Alloc_Asciz_Keyword( "type");
    job_Kw_Get_Function		= sym_Alloc_Asciz_Keyword( "getFunction");
    job_Kw_Set_Function		= sym_Alloc_Asciz_Keyword( "setFunction");
    job_Kw_Root_May_Read	= sym_Alloc_Asciz_Keyword( "rootMayRead");
    job_Kw_Root_May_Write	= sym_Alloc_Asciz_Keyword( "rootMayWrite");
    job_Kw_User_May_Read	= sym_Alloc_Asciz_Keyword( "userMayRead");
    job_Kw_User_May_Write	= sym_Alloc_Asciz_Keyword( "userMayWrite");
    job_Kw_Class_May_Read	= sym_Alloc_Asciz_Keyword( "classMayRead");
    job_Kw_Class_May_Write	= sym_Alloc_Asciz_Keyword( "classMayWrite");
    job_Kw_World_May_Read	= sym_Alloc_Asciz_Keyword( "worldMayRead");
    job_Kw_World_May_Write	= sym_Alloc_Asciz_Keyword( "worldMayWrite");

    job_Kw_Built_In		= sym_Alloc_Asciz_Keyword( "builtIn");
    job_Kw_Bignum		= sym_Alloc_Asciz_Keyword( "bignum");
    job_Kw_Structure		= sym_Alloc_Asciz_Keyword( "structure");
    job_Kw_Callstack		= sym_Alloc_Asciz_Keyword( "callstack");
    job_Kw_Vector		= sym_Alloc_Asciz_Keyword( "vector");
    job_Kw_VectorI01		= sym_Alloc_Asciz_Keyword( "vectorI01");
    job_Kw_VectorI08		= sym_Alloc_Asciz_Keyword( "vectorI08");
    job_Kw_VectorI16		= sym_Alloc_Asciz_Keyword( "vectorI16");
    job_Kw_VectorI32		= sym_Alloc_Asciz_Keyword( "vectorI32");
    job_Kw_VectorF32		= sym_Alloc_Asciz_Keyword( "vectorF32");
    job_Kw_VectorF64		= sym_Alloc_Asciz_Keyword( "vectorF64");
    job_Kw_Mos_Key		= sym_Alloc_Asciz_Keyword( "mosKey");
    job_Kw_Fixnum		= sym_Alloc_Asciz_Keyword( "fixnum");
    job_Kw_Short_Float		= sym_Alloc_Asciz_Keyword( "shortFloat");
    job_Kw_Stackblock		= sym_Alloc_Asciz_Keyword( "stackblock");
    job_Kw_Bottom		= sym_Alloc_Asciz_Keyword( "bottom");
    job_Kw_Compiled_Function	= sym_Alloc_Asciz_Keyword("compiledFunction");
    job_Kw_Character		= sym_Alloc_Asciz_Keyword( "character" );
    job_Kw_Cons			= sym_Alloc_Asciz_Keyword( "cons" );
    job_Kw_Special		= sym_Alloc_Asciz_Keyword( "special" );
    job_Kw_String		= sym_Alloc_Asciz_Keyword( "string" );
    job_Kw_Symbol		= sym_Alloc_Asciz_Keyword( "symbol" );


    /* CLX Keywords: */
    #ifdef HAVE_X11
    job_Kw_Arc_Mode		= sym_Alloc_Asciz_Keyword("arcMode");
    job_Kw_Background		= sym_Alloc_Asciz_Keyword("background");
    job_Kw_Backing_Pixel	= sym_Alloc_Asciz_Keyword("backingPixel");
    job_Kw_Backing_Planes	= sym_Alloc_Asciz_Keyword("backingPlanes");
    job_Kw_Backing_Store	= sym_Alloc_Asciz_Keyword("backingStore");
    job_Kw_Bit_Gravity		= sym_Alloc_Asciz_Keyword("bitGravity");
    job_Kw_Border		= sym_Alloc_Asciz_Keyword("border");
    job_Kw_Border_Width		= sym_Alloc_Asciz_Keyword("borderWidth");
    job_Kw_Cap_Style		= sym_Alloc_Asciz_Keyword("capStyle");
    job_Kw_Clip_Mask		= sym_Alloc_Asciz_Keyword("clipMask");
    job_Kw_Clip_Ordering	= sym_Alloc_Asciz_Keyword("clipOrdering");
    job_Kw_Clip_X		= sym_Alloc_Asciz_Keyword("clipX");
    job_Kw_Clip_Y		= sym_Alloc_Asciz_Keyword("clipY");
    job_Kw_Colormap		= sym_Alloc_Asciz_Keyword("colormap");
    job_Kw_Copy			= sym_Alloc_Asciz_Keyword("copy");
    job_Kw_Cursor		= sym_Alloc_Asciz_Keyword("cursor");
    job_Kw_Dash_Offset		= sym_Alloc_Asciz_Keyword("dashOffset");
    job_Kw_Dashes		= sym_Alloc_Asciz_Keyword("dashes");
    job_Kw_Depth		= sym_Alloc_Asciz_Keyword("depth");
    job_Kw_Do_Not_Propagate_Mask= sym_Alloc_Asciz_Keyword("doNotPropagateMask");
    job_Kw_Drawable		= sym_Alloc_Asciz_Keyword("drawable");
    job_Kw_Event_Mask		= sym_Alloc_Asciz_Keyword("eventMask");
    job_Kw_Exposures		= sym_Alloc_Asciz_Keyword("exposures");
    job_Kw_Fill_Rule		= sym_Alloc_Asciz_Keyword("fillRule");
    job_Kw_Fill_Style		= sym_Alloc_Asciz_Keyword("fillStyle");
    job_Kw_Font			= sym_Alloc_Asciz_Keyword("font");
    job_Kw_Foreground		= sym_Alloc_Asciz_Keyword("foreground");
    job_Kw_Function		= sym_Alloc_Asciz_Keyword("function");
    job_Kw_Gravity		= sym_Alloc_Asciz_Keyword("gravity");
    job_Kw_Height		= sym_Alloc_Asciz_Keyword("height");
    job_Kw_Input_Only		= sym_Alloc_Asciz_Keyword("inputOnly");
    job_Kw_Input_Output		= sym_Alloc_Asciz_Keyword("inputOutput");
    job_Kw_Join_Style		= sym_Alloc_Asciz_Keyword("joinStyle");
    job_Kw_Left_To_Right	= sym_Alloc_Asciz_Keyword("leftToRight");
    job_Kw_Line_Style		= sym_Alloc_Asciz_Keyword("lineStyle");
    job_Kw_Line_Width		= sym_Alloc_Asciz_Keyword("lineWidth");
    job_Kw_Override_Redirect	= sym_Alloc_Asciz_Keyword("overrideRedirect");
    job_Kw_Parent		= sym_Alloc_Asciz_Keyword("parent");
    job_Kw_Plane_Mask		= sym_Alloc_Asciz_Keyword("planeMask");
    job_Kw_Right_To_Left	= sym_Alloc_Asciz_Keyword("rightToLeft");
    job_Kw_Save_Under		= sym_Alloc_Asciz_Keyword("saveUnder");
    job_Kw_Stipple		= sym_Alloc_Asciz_Keyword("stipple");
    job_Kw_Subwindow_Mode	= sym_Alloc_Asciz_Keyword("subwindowMode");
    job_Kw_Tile			= sym_Alloc_Asciz_Keyword("tile");
    job_Kw_Ts_X			= sym_Alloc_Asciz_Keyword("tsX");
    job_Kw_Ts_Y			= sym_Alloc_Asciz_Keyword("tsY");
    job_Kw_Visual		= sym_Alloc_Asciz_Keyword("visual");
    job_Kw_Width		= sym_Alloc_Asciz_Keyword("width");
    job_Kw_X			= sym_Alloc_Asciz_Keyword("x");
    job_Kw_Y			= sym_Alloc_Asciz_Keyword("y");

    job_Kw_Button_1_Motion	= sym_Alloc_Asciz_Keyword("button1motion");
    job_Kw_Button_2_Motion	= sym_Alloc_Asciz_Keyword("button2motion");
    job_Kw_Button_3_Motion	= sym_Alloc_Asciz_Keyword("button3motion");
    job_Kw_Button_4_Motion	= sym_Alloc_Asciz_Keyword("button4motion");
    job_Kw_Button_5_Motion	= sym_Alloc_Asciz_Keyword("button5motion");
    job_Kw_Button_Motion	= sym_Alloc_Asciz_Keyword("buttonMotion");
    job_Kw_Button_Press		= sym_Alloc_Asciz_Keyword("buttonPress");
    job_Kw_Button_Release	= sym_Alloc_Asciz_Keyword("buttonRelease");
    job_Kw_Colormap_Change	= sym_Alloc_Asciz_Keyword("colormapChange");
    job_Kw_Enter_Window		= sym_Alloc_Asciz_Keyword("enterWindow");
    job_Kw_Exposure		= sym_Alloc_Asciz_Keyword("exposure");
    job_Kw_Focus_Change		= sym_Alloc_Asciz_Keyword("focusChange");
    job_Kw_Key_Press		= sym_Alloc_Asciz_Keyword("keyPress");
    job_Kw_Key_Release		= sym_Alloc_Asciz_Keyword("keyRelease");
    job_Kw_Keymap_State		= sym_Alloc_Asciz_Keyword("keymapState");
    job_Kw_Leave_Window		= sym_Alloc_Asciz_Keyword("leaveWindow");
    job_Kw_Owner_Grab_Button	= sym_Alloc_Asciz_Keyword("ownerGrabButton");
    job_Kw_Pointer_Motion	= sym_Alloc_Asciz_Keyword("pointerMotion");
    job_Kw_Pointer_Motion_Hint	= sym_Alloc_Asciz_Keyword("pointerMotionHint");
    job_Kw_Property_Change	= sym_Alloc_Asciz_Keyword("propertyChange");
    job_Kw_Resize_Redirect	= sym_Alloc_Asciz_Keyword("resizeRedirect");
    job_Kw_Structure_Notify	= sym_Alloc_Asciz_Keyword("structureNotify");
    job_Kw_Substructure_Notify	= sym_Alloc_Asciz_Keyword("substructureNotify");
    job_Kw_Substructure_Redirect= sym_Alloc_Asciz_Keyword("substructureRedirect");
    job_Kw_Visibility_Change	= sym_Alloc_Asciz_Keyword("visibilityChange");


    #endif

}

  /**********************************************************************/
  /*-   job_Startup -- start-of-world stuff.				*/
  /**********************************************************************/
void
job_Startup(
    void
) {
    Vm_Int nukem = job_Nuke_All_Jobs_At_Startup;

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    rex_Init( &job_Rex );

    #if MUQ_IS_PARANOID
    job_check_for_setjmp_bug();
    #endif

    /* Manpage recommends initializing rand48(): */
    #ifdef HAVE_SRAND48
    srand48(1);
    #endif
    #ifdef HAVE_SRANDOM
    srandom(1);
    #endif

    /* get_offset() and jobbuild.c:sx_expr() */
    /* depend on two bytes/short.   This can */
    /* be fixed if we ever find a system     */
    /* where this isn't true...              */
    if (2 != sizeof(Vm_Sht)) {
	MUQ_FATAL ("2 != sizeof(Vm_Sht)");
    }

    /* Set ^C handler so we save db and exit, */
    /* rather than losing db each type I      */
    /* absent-mindedly type ^C to muq:        */
    catch_SIGINT();
    catch_SIGHUP();
    catch_SIGTERM();

    /* Catch SIGCHLD, so we don't accumulate  */
    /* zombie children:                       */
    catch_SIGCHLD();

    /* Set FPE to ignore FPE signals (we were */
    /* dying on Linux on fp overflow):        */ 
    ignore_fpe_signal();

    /* We were also dying of "broken pipe"s   */
    /* on Linux:                              */
    ignore_pipe_signal();

    vm_Startup();

    /* Make state nonrandom: */
    jS.now         = OBJ_FROM_UNT( job_Now() );

    obj_Startup();	/* Builds /etc			*/
    asm_Startup();	/* Builds /etc/exe		*/
    evt_Startup();	/* Builds /lib/muf/]doSignal	*/
    cfn_Startup();
    muf_Startup();
    usq_Startup();

    job_enter_keywords();

    /* Check .etc.usr exists and is a user queue */
    obj_Etc_Usr = maybe_rebuild_usr_queue( "usr" );

    /* Clean out run queues of all users in user */
    /* queue, and remove them from user queue:   */
    /* Kill all jobs owned by all users: */
    {   /* Over all users in .u: */
	Vm_Obj obj = obj_U;
	Vm_Obj key = OBJ_FIRST;
        Vm_Int typ = OBJ_TYPE(obj);
	Vm_Int propdir = OBJ_PROP_PUBLIC;
	for (
	    key  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir );
	    key != OBJ_NOT_FOUND;
	    key  = (*mod_Type_Summary[ typ ]->for_nxt)( obj, key, propdir )
	) {
	    Joq_A_Pointer this;
	    Vm_Obj ps;
	    Vm_Obj usr;
	    usr  = (*mod_Type_Summary[ typ ]->for_get)( obj, key, propdir );
	    if (!OBJ_IS_OBJ(usr) || !OBJ_ISA_USR(usr))   continue;

	    
	    {   /* Find queue of all active jobs for user: */
		Usr_P p = USR_P(usr);
		ps      = p->ps_q;

		/* Set active-job queue to empty: */
		p->next = OBJ_FROM_INT(0);
		p->prev = OBJ_FROM_INT(0);
		vm_Dirty(usr);
	    }

	    /* Kill all jobs that were in active-jobs queue: */
	    this = JOQ_P(ps)->link.next;
	    while (!OBJ_IS_CLASS_JOQ(this.o)) {
		Joq_A_Pointer next;
		next = JOB_P(this.o)->link[JOB_QUEUE_PS].next;
		job_end_job( this.o );
		this = next;
	    }

	    /* If user is in user queue, clear: */
	}
    }
    usq_Reset( obj_Etc_Usr );
	
    /* Check /etc/run /etc/doz /etc/pos /etc/stp */
    /* exist and are job queues:                 */
    obj_Etc_Doz = maybe_rebuild_job_queue( "doz", nukem );

    /* Create an empty /ps obj */
    /* to hold all live jobs:  */
    obj_Ps  = maybe_rebuild_ps_joq( nukem );

    /* Create an empty /who obj   */
    /* to hold all live sessions: */
    obj_Who = rebuild_who_propdir();

    /* Make sure /etc/jb0 exists, make it 'current job': */
    obj_Etc_Jb0 = maybe_rebuild_jb0( nukem );
}

 /***********************************************************************/
 /*-    job_Linkup -- start-of-world stuff.				*/
 /***********************************************************************/

void
job_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    vm_Linkup();
    obj_Linkup();

}

 /***********************************************************************/
 /*-    job_Shutdown -- end-of-world stuff.				*/
 /***********************************************************************/

void
job_Shutdown (
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    vm_Shutdown();
    obj_Shutdown();
}


#ifdef OLD

 /***********************************************************************/
 /*-    job_Import -- Read  object from textfile.			*/
 /***********************************************************************/

Vm_Obj job_Import(
    FILE* fd
) {
    MUQ_FATAL ("job_Import unimplemented");
    return OBJ_NIL;
}

 /***********************************************************************/
 /*-    job_Export -- Write object into textfile.			*/
 /***********************************************************************/

void job_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("job_Export unimplemented");
}


#endif

 /***********************************************************************/
 /*-    job_Invariants -- Sanity check on job.				*/
 /***********************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

Vm_Int job_Invariants (
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
/*-    Static fns, general.						*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_end_job -- Terminate current thread.			*/
 /***********************************************************************/

static void
job_end_job(
   Vm_Obj job
) {
    /* Special killStandardOutputOnExit hack    */
    /* to simplify construction of unixy pipelines: */
    {   Job_P j = JOB_P(job);
        if (j->kill_standard_output_on_exit != OBJ_0) {
	    Vm_Obj o = j->standard_output;
	    if (OBJ_IS_OBJ(       o )
	    &&  OBJ_IS_CLASS_MSS( o )
	    ){
		MSS_P(o)->dead = OBJ_T;
		vm_Dirty(o);
    }   }   }

    /* Delete job from any queue it is in: */
    joq_Dequeue( job );

    /* Delete job from ~%s/ps: */
    joq_Unlink( job, JOB_QUEUE_PS        );

    /* Delete job from /ps: */
    joq_Unlink( job, JOB_QUEUE_GLOBAL_PS );

    /* Delete job from its jobset: */
    jbs_Del( JOB_P(job)->job_set, job );

    /* Set job's status to "ded": */
    {   Job_P j   = JOB_P( job );
	Joq_Link l = & j->link[ JOB_QUEUE_PS ];
	l->this    = OBJ_FROM_INT(0);
	l->next.o  = OBJ_FROM_INT(0);
	l->prev.o  = OBJ_FROM_INT(0);
	vm_Dirty( job );
    }
}

 /***********************************************************************/
 /*-    job_next -- Schedule next task.					*/
 /***********************************************************************/

static void
job_next(
    void
) {
    /**************************************************/
    /* When arriving here, there is no valid current  */
    /* job, and the previous job has already been     */
    /* job_State_Unpublish()ed.                       */
    /**************************************************/


    /**************************************************/
    /* job_next() is usually called after some prim   */
    /* has invalidated the current job by killing it  */
    /* or putting it to sleep or whatever.            */
    /*                                                */
    /* If there is another job ready to run, we want  */
    /* to switch it in and return.                    */
    /*                                                */
    /* If there in no other job ready to run, we must */
    /* not return, since the next JOB_NEXT would      */
    /* fail to find a current job and likely crash,   */
    /* we instead longjmp() back to job_Run().        */
    /*                                                */
    /* (We try to avoid longjmp()ing needlessly,      */
    /* because it is abominably slow.)                */
    /**************************************************/
    /* If run queue is not empty, switch to next */
    /* task in it, and return:                   */
    Vm_Obj nxt = job_next_runnable();
    if (nxt != OBJ_NIL) {
	job_State_Publish( nxt );
	return;
    }

    longjmp( job_longjmp_buf, 1 );
}

 /***********************************************************************/
 /*-    pop_thunkframe_normally --					*/
 /***********************************************************************/

static void
pop_thunkframe_normally(
    Vm_Obj* stackframe_top
) {
    Vm_Int stack_offset;

    /* Restore pre-thunk loopstack state: */
    {
	/* Don't trust params to be fast: */
	register Vm_Obj* l = stackframe_top-1;

	/* Remember in which slot thunk result is to go: */
	stack_offset = OBJ_TO_INT(*--l);

	/* Restore old logical bottom of stack: */
	jS.s_bot        = jS.s_0 + OBJ_TO_INT( *--l );

	/* Restore pre-thunk privileges: */
	jS.j.actual_user= *--l;
/* Buggo, need to worry about bytes_owned and objects_owned */
	jS.j.acting_user= *--l;
	jS.j.privs	= *--l;

	/* Remember new top of loopstack.  This */
	/* only matters if error returns below  */
	/* are taken:                           */
	jS.l		=  l-2;
    }

    /* Check that we have right # of return   */
    /* values from the thunk, then slot them  */
    /* into correct spot in data stack,       */
    /* replacing the thunk there.  We also    */
    /* pop the two underflow guards now:      */
    {   register Vm_Obj*    s          = jS.s;
	register Vm_Obj     return_val = *s;
	register Vm_Int     vals       = 0;

	/* Count number of values actually returned: */
	while (!OBJ_IS_BOTTOM( *s ))   --s, ++vals;

	/* Pop both underflow guards: */
	s -= 2;

	/* Remember restored top-of-data-stack: */
	jS.s = s;

	/* Complain if actual return count is wrong: */
	if (vals != 1) {
	    if (!vals)   MUQ_WARN ("Thunk returned no value!");
	    else         MUQ_WARN ("Thunk returned %d values!",(int)vals);
	}

	/* Insert return value in correct spot: */
	s[ stack_offset ] = return_val;
    }
}

 /***********************************************************************/
 /*-    pop_thunkframe_during_error_recovery --				*/
 /***********************************************************************/

static void
pop_thunkframe_during_error_recovery(
    Vm_Obj* stackframe_top
) {
    /* Restore pre-thunk loopstack state: */
    {
	/* Don't trust params to be fast. */
	register Vm_Obj* l = stackframe_top-1;

	/* Forget which slot thunk result was supposed to go in: */
	--l;

	/* Restore old logical bottom of stack: */
	jS.s_bot        = jS.s_0 + OBJ_TO_INT( *--l );

	/* Restore pre-thunk privileges: */
	jS.j.actual_user= *--l;
/* Buggo, need to worry about bytes_owned and objects_owned */
	jS.j.acting_user= *--l;
	jS.j.privs	= *--l;

	/* Remember new top of loopstack.  This */
	/* only matters if error return below   */
	/* is taken:                            */
	jS.l		=  l-2;
    }

    /* Copy error block down, overwriting the	*/
    /* pair of underflow guards we had in place */
    /* during evaluation of the thunk:          */
    {   register Vm_Obj*    s          = jS.s;
	register Vm_Unt     i          = 0;
/* buggo? Should this be OBJ_TO_UNT()? */
	Vm_Unt              block_size = OBJ_TO_UNT(*s)+1;
	register Vm_Obj*    t          = s - block_size;

	/* Count number of values actually above underflow guards: */
	while (!OBJ_IS_BOTTOM( *--s ))   ++i;

	/* Discard the underflow guard pair: */
	s -= 2;
	#if MUQ_IS_PARANOID
	if (s <= jS.s_bot) {
	    MUQ_FATAL ("pop_thunkframe_during_error_recovery: missing guards");
	}
	#endif

	/* Complain if error block is supposedly larger */
	/* than actual number of values returned:       */
	if (i < block_size) {
	    jS.s = s;
	    MUQ_WARN (
		"Thunk error block size %d, but only %d vals on stack?!",
		(int)(block_size-1), (int)i
	    );
	}

	/* Set new top-of-data-stack: */
	jS.s = s + block_size;

	/* Copy error block down to correct spot: */
	for (i = block_size;   i --> 0;  )   *++s = *++t;
    }
}

 /***********************************************************************/
 /*-    throw -- Transfer control to appropriate CATCH frame.		*/
 /***********************************************************************/

 /***********************************************************************/
 /*-    throw_set_up_jSl_jSv_jSk_jSx_and_jSpc -- convenience function.	*/
 /***********************************************************************/

static void
throw_set_up_jSl_jSv_jSk_jSx_and_jSpc(
    Vm_Obj* next_l
) {
    register Vm_Obj* l = next_l;

    /* Locate next NORMAL stackframe.  */

    /* This may actually be the one    */
    /* currently executing, it doesn't */
    /* really matter to us:            */
    while (l[-1] != JOB_STACKFRAME_NORMAL) {
        if (!*l) {
	    MUQ_FATAL ("job.c:throw: No NORMAL stackframe found.");
	}
	l  = JOB_PREV_STACKFRAME(l);
    }

    /* We wait until now to actually munge */
    /* global state, for the sake of clean */
    /* error-trap state above:		   */
    jS.l    = next_l;

    /* Restore localVars framepointer: */
    l  = JOB_PREV_STACKFRAME(l);
    jS.v  = l+4;

    {	register Vm_Obj*  p;
	register Vm_Obj   x;
	register Vm_Int   pc;
	l += 3;
	x          = *l;  --l;               /*executable*/
	pc	   = OBJ_TO_INT(*l);	     /*l invalid after CFN_P */
	jS.k       = p   = CFN_P(x)->vec;    /*constants */
    	jS.pc      = ((Vm_Uch*)jS.k) + pc;

	/* jS.pc is now correct, so we don't want anyone */
	/* incrementing it before executing instruction: */
	jS.instruction_len = 0;

	/* It is important not to set jS.x_obj	*/
	/* until above CFN_P(x) call swaps it   */
        /* into ram for us:                     */
	jS.x_obj = x;
    }
}


/********************************************************/
/* throw() usually longjmp()s out rather than returning	*/
/* since it is often called as the final stage in	*/
/* recovering from an error situation somewhere in	*/
/* the interpreter, and we certainly don't want to	*/
/* return to, and continue, a function which just	*/
/* discovered an error.					*/
/*                                                      */
/* Two special cases:                                   */
/*                                                      */
/* If tag==OBJ_ERROR_TAG, we're doing error recovery,	*/
/* not a regular THROW.                                 */
/*                                                      */
/* If tag==OBJ_NOT_FOUND, we simply process the stack,  */
/* to execute all after{}always_do{} clauses, then do a */
/* normal return.  At time of writing, this is used     */
/* only to implement END-JOB.                           */
/*                                                      */
/********************************************************/

static void
throw(
    Vm_Obj tag,
    Vm_Int op	/* One of JOB_GOTO, JOB_THROW, JOB_ENDJOB, JOB_EXEC. */
) {
    /* The difference between a throw */
    /* and a nonlocal goto is mostly  */
    /* that throws carry an argblock  */
    /* along (& flag) and gotos don't:*/
    switch (op) {
    case JOB_GOTO:
	break;
    case JOB_EXEC:
    case JOB_ENDJOB:
    case JOB_THROW:
        /* Check that we have a block on stack: */
	job_Guarantee_N_Args(  1 );
	job_Guarantee_Blk_Arg( 0 );
	break;
    default:
	MUQ_FATAL ("throw: bad 'op' value");
    }


    {   register Vm_Obj* l = jS.l;
        Vm_Int last_normal = 0;
        Vm_Int last_tagtop = 0;
	Vm_Unt offset;

        /* Update pc in current NORMAL frame,  */
	/* just in case we wind up using it:   */
	jS.v[-2]  = OBJ_FROM_INT((jS.pc+jS.instruction_len) - (Vm_Uch*)jS.k);

	/* Make sure matching CATCH/TAG exists */
	/* before we actually start unwinding  */
	/* the stack:                          */
	if (tag != OBJ_NOT_FOUND) {
	    switch (op) {
	    case JOB_EXEC:
	    case JOB_ENDJOB:
		break;
	    case JOB_THROW:
		for (;;) {
		    if (l[-1] == JOB_STACKFRAME_CATCH
		    &&  l[-2] == tag
		    ){
			break;
		    }
		    l  = JOB_PREV_STACKFRAME(l);
		    if (!*l) {
/* buggo? Is this still correct? Do we wanna crash here? */
			if (tag == OBJ_ERROR_TAG) {
			    MUQ_FATAL ("throw: No errset found.");
			}
			MUQ_WARN("throw: Can't find matching CATCH frame");
		    }
		}
		break;

	    case JOB_GOTO:
		for (;;) {
		    if (l[-1] == JOB_STACKFRAME_TAG
		    &&  l[-2] == tag
		    ){
			break;
		    }
		    l  = JOB_PREV_STACKFRAME(l);
		    if (!*l) {
#ifdef PRODUCTION
			MUQ_WARN("throw: Can't find matching TAG frame");
#else
{   Vm_Uch buf[ 64 ];
    job_Sprint_Vm_Obj(
	buf, buf+64,
	tag,
	/*quotestrings:*/TRUE
    );
    MUQ_WARN("throw: Can't find matching TAG frame for goto tag '%s'",buf);
}
#endif
		    }
		}
		break;
	    default:
		MUQ_FATAL ("throw: bad 'op' value");
	    }
	}

        /* Unwind loop stack to our CATCH/TAG frame: */
        l = jS.l;
	for (;;) {

	    switch (l[-1]) {

	    case JOB_STACKFRAME_SIGNAL:
		/* To keep debugging from being too much  */
		/* of a nightmare, we don't allow throws  */
		/* to propagate out of a signal handler;  */
		/* We simply abort the signal handler and */
		/* continue execution normally:           */
		if (tag != OBJ_NOT_FOUND) {
/* buggo? Are we guaranteed last_normal is nonzero? */
		    #if MUQ_IS_PARANOID
		    if (!last_normal) {
			MUQ_FATAL ("job.t:throw/SIGNAL: internal err");
		    }
		    #endif
		    jS.l = jS.l_bot + last_normal;
		    job_P_Return();
		    longjmp( job_longjmp_buf, 1 );
		} else {
		    l  = JOB_PREV_STACKFRAME(l);
		}
		break;

	    case JOB_STACKFRAME_THUNK:
		/* A thunk has no business throwing to    */
		/* a catch it did not create itself, so   */
		/* if this isn't an error recovery throw: */
		if (tag != OBJ_ERROR_TAG) {
	            MUQ_WARN ("job.c:throw: No matching CATCH found!");
		}
		/* Restore prethunk evaluation context: */
		pop_thunkframe_during_error_recovery( l );
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_PROTECT:
	    case JOB_STACKFRAME_PROTECT_CHILD:
		/* Funfun, stop THROW long enough to	*/
		/* execute the always_do clause which	*/
		/* this stackframe marks as being in 	*/
		/* force:				*/
		offset = OBJ_TO_INT(l[-2]);

		/* Remember to continue THROW, and tag to throw: */
		switch (op) {
		case JOB_EXEC:   l[-1] = JOB_STACKFRAME_EXEC;	    break;
		case JOB_ENDJOB: l[-1] = JOB_STACKFRAME_ENDJOB;	    break;
		case JOB_GOTO:   l[-1] = JOB_STACKFRAME_GOTO;	    break;
		case JOB_THROW:  l[-1] = JOB_STACKFRAME_THROW;	    break;
		default:
		    MUQ_FATAL ("throw: bad 'op' value");
		}
		l[-2] = tag;

		throw_set_up_jSl_jSv_jSk_jSx_and_jSpc( l );
		jS.pc = ((Vm_Uch*)jS.k) + offset;/* Jump to always_do clause.*/
		/* jS.pc is now correct, so we don't want anyone */
		/* incrementing it before executing instruction: */
		jS.instruction_len = 0;
		#if MUQ_IS_PARANOID
		if (!job_longjmp_buf_is_valid) {
		    MUQ_FATAL ("job_longjmp_buf invalid!");
		}
		#endif
		longjmp( job_longjmp_buf, 1 );

	    case JOB_STACKFRAME_THROW:
		/**********************************************/
		/* This case seems to me to be most likely to */
		/* arise when an exception is encountered in  */
		/* an always_do clause which is already being */
		/* executed due to a previous exception.  The */
		/* most perspicuous action seems to me to be  */
		/* propagation of the original exception and  */
		/* silent flushing of the new one, since the  */
		/* programmer is most likely to find the      */
		/* original exception useful in debugging. CrT*/
		/**********************************************/
		jS.l  = JOB_PREV_STACKFRAME(l);
		throw( l[-2], JOB_THROW );	/* No return, of course.  */

	    case JOB_STACKFRAME_GOTO:
		jS.l  = JOB_PREV_STACKFRAME(l);
		throw( l[-2], JOB_GOTO );	/* No return, of course.  */

	    case JOB_STACKFRAME_ENDJOB:
		jS.l  = JOB_PREV_STACKFRAME(l);
		throw( l[-2], JOB_ENDJOB );	/* Sometimes returns.     */
		return;

	    case JOB_STACKFRAME_EXEC:
		jS.l  = JOB_PREV_STACKFRAME(l);
		throw( l[-2], JOB_EXEC );	/* Sometimes returns.     */
		return;

	    case JOB_STACKFRAME_JUMP:
		/* This case likely indicates an exception in */
		/* an always_do clause which was being run    */
		/* due to a routine 'break' past it.  Seems   */
		/* best to ignore the JUMP and propagate the  */
		/* exception:                                 */
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_RETURN:
		/* This case, similarly, likely indicates an  */
		/* exception in an always_do clause which was */
		/* being run due to a routine 'return' past   */
		/* it, seems best to ignore the RETURN and    */
		/* propagate the exception:		      */
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_NORMAL:
		last_normal = l - jS.l_bot;
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_LOCK:
	    case JOB_STACKFRAME_LOCK_CHILD:
		/* We're throwing out of a with-lock{...}, */
		/* so release the lock:                    */
		jS.l  = JOB_PREV_STACKFRAME(l);
		lok_Release( jS.l[2] );
		l = jS.l;
		break;

	    case JOB_STACKFRAME_NULL:
	    case JOB_STACKFRAME_VANILLA:
	    case JOB_STACKFRAME_RESTART:
	    case JOB_STACKFRAME_HANDLERS:
	    case JOB_STACKFRAME_HANDLING:
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_TMP_USER:
		/* Throwing out of a handler: */
		/* FALLTHRU */
	    case JOB_STACKFRAME_USER:
		/* We're throwing out of an  asMeDo{...}, */
		/* or such, so restore previous user:       */
		jS.j.acting_user = l[-2];
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_PRIVS:
		/* We're thrown out of an rootOmnipotentlyDo{...}, */
		/* or such, so restore previous privs bitmask:       */
		jS.j.privs = l[-2];
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_EPHEMERAL_LIST:
		/* We're returning from a scope that pushed  */
		/* an ephemeral, need to update linklist     */
		/* head pointer jS.j.ephemeral_lists:        */
		jS.j.ephemeral_lists = l[-2];
		l = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_EPHEMERAL_STRUCT:
		/* We're returning from a scope that pushed  */
		/* an ephemeral, need to update linklist     */
		/* head pointer jS.j.ephemeral_structs:      */
		jS.j.ephemeral_structs = l[-2];
		l = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_EPHEMERAL_VECTOR:
		/* We're returning from a scope that pushed  */
		/* an ephemeral, need to update linklist     */
		/* head pointer jS.j.ephemeral_vectors:      */
		jS.j.ephemeral_vectors = l[-2];
		l = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_FUN_BIND:
		/* We're returning from a scope that bound   */
		/* a symbol, need to update binding linklist */
		/* head pointer jS.j.function_bindings:      */
		jS.j.function_bindings = l[-2];
		l = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_VAR_BIND:
		/* We're returning from a scope that bound   */
		/* a symbol, need to update binding linklist */
		/* head pointer jS.j.variable_bindings:      */
		jS.j.variable_bindings = l[-2];
		l = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_TAGTOP:
		last_tagtop = l - jS.l_bot;
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_CATCH:
		if (l[-2] == tag   &&   op == JOB_THROW) {

		    /* Found an appropriate CATCH, */
                    /* set it up to run:           */

		    /* Get size of block to return, plus the [: */
		    register Vm_Obj* s;

		    register Vm_Unt   i= OBJ_TO_BLK(*jS.s)+1;

		    /* Get original top-of-data-stack value: */
		    Vm_Unt s_offset = OBJ_TO_INT(l[-3]);
		    register Vm_Obj* os;

		    /* Get pc offset at which to continue: */
		    Vm_Unt pc = OBJ_TO_INT(l[-4]);

		    /* Discard CATCH frame: */
		    l  = JOB_PREV_STACKFRAME(l);

		    throw_set_up_jSl_jSv_jSk_jSx_and_jSpc( l );

		    /* Impose some minimal level of sanity	*/
		    /* on return block size:			*/
		    /* Locate data stack top: */
		    os = (Vm_Obj*) (  ((Vm_Uch*)jS.s_bot) + s_offset  );
		    s= jS.s;
		    if (jS.s_bot + (i+1) > s) {
/*buggo -- this probably needs careful testing.*/
                        i = (s-1) - jS.s_bot;
	            }

		    /* Copy return block to correct spot: */
		    s -= i;/* Bottom of return block. */
		    os++;  /* Bottom of spot to which to copy return block.*/
		    if (os > s) {

			/* Sliding return block zerofar,  */
			/* need to start at zerofar  end: */
			Vm_Int oi = i;
			os += i;
			s  += i;
			i++;/* # of items to copy (i items plus [ plus |). */
/*buggo? Can this overflow stack?*/
			while (i --> 0) *os-- = *s--;
			s   = os+oi+1; /* Point s to new top of data stack. */
		    } else {
			/* Sliding return block zeroward, */
			/* need to start at zeronear end: */
			i++;  /* # of items to copy (i items plus i itself). */
			while (i --> 0) *os++ = *s++;
			s   = os-1;  /* Point s to new top of data stack. */
		    }

		    /* Push a TRUE on stack to show we _did_ catch an error: */
		    ++s;
		   *s = OBJ_TRUE;

		    /* Remember new datastack top-of-stack: */
		    jS.s    = s;



		    /* Restore pc: */
		    jS.pc = ((Vm_Uch*)jS.k) + pc;
		    /* jS.pc is now correct, so we don't want anyone */
		    /* incrementing it before executing instruction: */
		    jS.instruction_len = 0;

		    /* longjmp() back to job_Run():     */
		    #if MUQ_IS_PARANOID
		    if (!job_longjmp_buf_is_valid) {
			MUQ_FATAL ("job_longjmp_buf invalid!");
		    }
		    #endif
		    longjmp( job_longjmp_buf, 1 );
		}
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    case JOB_STACKFRAME_TAG:
		if (l[-2] == tag   &&   op == JOB_GOTO) {

		    /* Found an appropriate TAG, */
                    /* set it up to run:         */

		    /* For original top-of-data-stack value: */
		    register Vm_Obj* os;

		    /* Get pc offset at which to continue: */
		    Vm_Unt pc = OBJ_TO_INT(l[-3]);

		    if (!last_tagtop) {
			MUQ_WARN ("goto found no TAGTOP frame!");
		    }

		    /* Restore this block of TAG frames: */
		    l = jS.l_bot+last_tagtop;

		    /* Get original top-of-data-stack value: */
		    os = (Vm_Obj*) (
			((Vm_Uch*)jS.s_bot) + OBJ_TO_INT(l[-2])
		    );

		    /* Reset top of data stack to old value, */
		    /* except we never push garbage on while */
		    /* doing so.  See compileSemi for an    */
		    /* example of it making sense to return  */
		    /* with less than 'expected' on stack:   */
		    if (jS.s > os) {
			jS.s = os;     /* Must precede next! */
		    }
		    throw_set_up_jSl_jSv_jSk_jSx_and_jSpc( l );



		    /* Restore pc: */
		    jS.pc = ((Vm_Uch*)jS.k) + pc;
		    /* jS.pc is now correct, so we don't want anyone */
		    /* incrementing it before executing instruction: */
		    jS.instruction_len = 0;

		    /* longjmp() back to job_Run():     */
		    #if MUQ_IS_PARANOID
		    if (!job_longjmp_buf_is_valid) {
			MUQ_FATAL ("job_longjmp_buf invalid!");
		    }
		    #endif
		    longjmp( job_longjmp_buf, 1 );
		}
		l  = JOB_PREV_STACKFRAME(l);
		break;

	    default:
		/* This is the only case in which we return: */
		if (tag == OBJ_NOT_FOUND) {
		    switch (op) {
		    case JOB_GOTO:
			MUQ_FATAL ("throw: internal err1");
		    case JOB_THROW:
			return;
		    case JOB_EXEC:
			job_finish_exec();
			return;
		    case JOB_ENDJOB:
			/* Finish dismantling thread: */
			job_end_job( jS.job );

			/* Switch to next runnable job: */
			job_next();

			/* job_next() sometimes returns: */
			return;
		}   }

		/* Other exits should be caught at top now. */
		MUQ_FATAL ("throw: internal err2");
    }   }   }
}

 /***********************************************************************/
 /*-    job_Loop_Overflow -- Handle job overflowing loop stack		*/
 /***********************************************************************/

void
job_Loop_Overflow(
    void
) {
/* buggo: It is probably possible to maliciously crash  */
/* the interpreter here one way or another, maybe by    */
/* setting stackframesPoppedAfterLoopStackOverflow */
/* to minimum value and then doing (say) a VARS of a    */
/* large value, else by rigging overflow so that the    */
/* below pops a TAGTOP but not all the matching TAGS,   */
/* or some such thing.                                  */
    /* Try to pop a few frames in hope */
    /* of clearing enough space for    */
    /* error recovery to succeed:      */
    Vm_Int i;
    register Vm_Obj* l = jS.l;
    for(i = obj_Stackframes_Popped_After_Loop_Stack_Overflow;
	i --> 0;
    ){
	switch (l[-1]) {

	case JOB_STACKFRAME_NORMAL:
	    jS.l = l;
	    throw_set_up_jSl_jSv_jSk_jSx_and_jSpc( l );
	    l  = JOB_PREV_STACKFRAME(jS.l);
	    break;

	case JOB_STACKFRAME_LOCK:
	case JOB_STACKFRAME_LOCK_CHILD:
	    /* Release the lock: */
	    jS.l  = JOB_PREV_STACKFRAME(l);
	    lok_Release( jS.l[2] );
	    l = jS.l;
	    break;

	case JOB_STACKFRAME_TAG:
	case JOB_STACKFRAME_NULL:
	case JOB_STACKFRAME_CATCH:
	case JOB_STACKFRAME_SIGNAL:
	case JOB_STACKFRAME_RESTART:
	case JOB_STACKFRAME_HANDLERS:
	case JOB_STACKFRAME_HANDLING:
	    l  = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_TMP_USER:
	    /* Throwing out of a handler: */
	    /* FALLTHRU */
	case JOB_STACKFRAME_USER:
	    /* We're throwing out of an  asMeDo{...}, */
	    /* or such, so restore previous user:       */
	    jS.j.acting_user = l[-2];
	    l  = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_PRIVS:
	    /* We're thrown out of an rootOmnipotentlyDo{...}, */
	    /* or such, so restore previous privs bitmask:       */
	    jS.j.privs = l[-2];
	    l  = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_EPHEMERAL_LIST:
	    /* We're returning from a scope that pushed  */
	    /* an ephemeral, need to update linklist     */
	    /* head pointer jS.j.ephemeral_objects:      */
	    jS.j.ephemeral_lists = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_EPHEMERAL_STRUCT:
	    /* We're returning from a scope that pushed  */
	    /* an ephemeral, need to update linklist     */
	    /* head pointer jS.j.ephemeral_structs:      */
	    jS.j.ephemeral_structs = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_EPHEMERAL_VECTOR:
	    /* We're returning from a scope that pushed  */
	    /* an ephemeral, need to update linklist     */
	    /* head pointer jS.j.ephemeral_vectors:      */
	    jS.j.ephemeral_vectors = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_FUN_BIND:
	    /* We're returning from a scope that bound   */
	    /* a symbol, need to update binding linklist */
	    /* head pointer jS.j.function_bindings:      */
	    jS.j.function_bindings = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_VAR_BIND:
	    /* We're returning from a scope that bound   */
	    /* a symbol, need to update binding linklist */
	    /* head pointer jS.j.variable_bindings:      */
	    jS.j.variable_bindings = l[-2];
	    l = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_TAGTOP:
	    l  = JOB_PREV_STACKFRAME(l);
	    break;

	case JOB_STACKFRAME_RETURN:
	case JOB_STACKFRAME_JUMP:
	case JOB_STACKFRAME_GOTO:
	case JOB_STACKFRAME_EXEC:
	case JOB_STACKFRAME_ENDJOB:
	case JOB_STACKFRAME_THROW:
	case JOB_STACKFRAME_PROTECT:
	case JOB_STACKFRAME_PROTECT_CHILD:
	case JOB_STACKFRAME_THUNK:
	default:
	    /* Argh! Punt: */
	    jS.l = l;	/* Don't (.e.g,) release a lock twice. */
	    job_end_job( jS.job );
	    job_next();
	    longjmp( job_longjmp_buf, 1 );
    }   }
    jS.l = l;
    MUQ_WARN ("Recursion stack overflow");
}


/************************************************************************/
/*-    Static fns, standard.						*/
/************************************************************************/

 /***********************************************************************/
 /*-    for_new -- Initialize new job object.				*/
 /***********************************************************************/

/* The following code is normally used to */
/* initialize only the first job or two,  */
/* other jobs are created by job_Make_Job().  */

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Vm_Obj pid;
    Vm_Obj package;
    Vm_Obj lib;
    Vm_Obj do_break;
    Vm_Obj debugger;
    {   Usr_P u    = USR_P( jS.j.acting_user );
        package    = u->default_package;
        lib        = u->lib;
        debugger   = u->debugger;
        do_break   = u->do_break;
    }

    /* Find a suitable pid: */
    pid = job_issue_pid();

    {   Job_P p	    		= JOB_P(o);

	p->op_count		= OBJ_FROM_INT(0);

	p->job_set		= OBJ_FROM_INT(0);
	p->parent		= o;

        {   Vm_Int i;
	    for (i = JOB_QUEUE_MEMBERSHIP_MAX;   i --> 0; ) {
		Joq_Link l = &p->link[i];
		l->this		= OBJ_FROM_INT(0);
		l->next.o	= OBJ_FROM_INT(0);	/* These values make */
		l->prev.o	= OBJ_FROM_INT(0);	/* job unenqueueable */
		l->next.i	= OBJ_FROM_INT(0);
		l->prev.i	= OBJ_FROM_INT(0);
        }   }

	p->doing_promiscuous_read  = OBJ_FROM_INT(0);
	p->promiscuous_no_fragments= OBJ_FROM_INT(0);

#ifdef OLD
	p->until_sec		= OBJ_FROM_INT(0);
	p->until_nsec		= OBJ_FROM_INT(0);
#else
	p->until_msec		= OBJ_FROM_INT(0);
#endif
	p->q_pre_stop		= OBJ_FROM_INT(0);
	p->priority		= OBJ_FROM_INT(1);

	p->stack_bottom		= OBJ_FROM_INT(1);
	p->frame_base     	= OBJ_FROM_UNT(4);

	p->package		= package;
	p->lib			= lib;
	p->j.privs		= OBJ_FROM_INT(0);

	p->j.actual_user	= jS.j.actual_user;
	p->j.acting_user	= jS.j.acting_user;

	p->owner		= jS.j.actual_user;

	p->j.group		= OBJ_FROM_INT(0);

	p->j.ephemeral_objects	= OBJ_FROM_INT(0);
	p->j.ephemeral_structs	= OBJ_FROM_INT(0);
	p->j.ephemeral_vectors	= OBJ_FROM_INT(0);
	p->j.function_bindings	= OBJ_FROM_INT(0);
	p->j.variable_bindings	= OBJ_FROM_INT(0);

	{   Vm_Int i;
	    for (i = JOB_HASHTAB_MAX;   i --> 0;   ) {
		p->j.binding_hashtab[ i ] = OBJ_FROM_INT(0);
	}   }

	p->yyss			= OBJ_NIL;
	p->yyvs			= OBJ_NIL;
	p->yyval		= OBJ_NIL;
	p->yylval		= OBJ_NIL;
	p->yydebug		= OBJ_NIL;
	p->yyinput		= OBJ_NIL;
	p->yycursor		= OBJ_NIL;
	p->yyreadfn		= OBJ_NIL;
	p->yyprompt		= OBJ_NIL;

	p->yylhs		= OBJ_NIL;
	p->yylen		= OBJ_NIL;
	p->yydefred		= OBJ_NIL;
	p->yydgoto		= OBJ_NIL;
	p->yysindex		= OBJ_NIL;
	p->yyrindex		= OBJ_NIL;
	p->yygindex		= OBJ_NIL;
	p->YYTABLESIZE		= OBJ_NIL;
	p->yytable		= OBJ_NIL;
	p->yycheck		= OBJ_NIL;
	p->YYFINAL		= OBJ_NIL;
	p->YYMAXTOKEN		= OBJ_NIL;
	p->yyname		= OBJ_NIL;
	p->yyrule		= OBJ_NIL;
	p->yyaction		= OBJ_NIL;

	p->self			= jS.j.actual_user;
	p->class		= jS.j.actual_user;

	p->root_obj		= vm_Root(0);
	p->here_obj		= jS.j.actual_user;

	p->standard_input	= OBJ_FROM_INT(0);
	p->standard_output	= OBJ_FROM_INT(0);
	p->error_output		= OBJ_FROM_INT(0);
	p->trace_output		= OBJ_FROM_INT(0);
	p->debug_io		= OBJ_FROM_INT(0);
	p->query_io		= OBJ_FROM_INT(0);
	p->terminal_io		= OBJ_FROM_INT(0);

	p->muqnet_io		= OBJ_FROM_INT(0);

	p->pid			= pid;
	p->o.objname		= pid;

	p->do_error		= obj_Lib_Muf_Do_Error;
	p->do_signal		= obj_Lib_Muf_Do_Signal;
	p->report_event		= obj_Lib_Muf_Report_Event;

	p->break_disable	= OBJ_NIL;
	p->break_enable		= OBJ_NIL;
	p->break_on_signal	= OBJ_NIL;
	p->do_break		= do_break;
	p->debugger		= debugger;
	p->debugger_hook	= OBJ_NIL;

	p->random_state_high_half= OBJ_FROM_INT(13);
	p->random_state_low_half= OBJ_FROM_INT(17);

	p->compiler		= OBJ_FROM_INT(0);
	p->spare_assembler	= OBJ_FROM_INT(0);
	p->spare_compile_message_stream	= OBJ_FROM_INT(0);
	p->end_job		= OBJ_FROM_INT(0);
	p->read_nil_from_dead_streams   = OBJ_FROM_INT(0);
	p->kill_standard_output_on_exit = OBJ_FROM_INT(0);

	p->task			= OBJ_FROM_INT(0);

	{   int  i;
	    for (i = JOB_RESERVED_SLOTS;  i --> 0; ) p->reserved_slot[i] = OBJ_FROM_INT(0);
	}

	rex_Init( &p->rex );

	vm_Dirty(o);
    }

    /* Build our data and loop stacks: */
    {
	/* Build data stack.                                        */
	/* Don't combine these lines, side-effect sequence matters: */
	Vm_Obj s 	       = obj_Alloc( OBJ_CLASS_A_DST, 0 );
        JOB_P(o)->j.data_stack = s;
	vm_Dirty(o);
	/* '64' 'cause we normally need 32 minimum to function: */
	if (!stk_Got_Headroom( s, 64 )) MUQ_WARN ("Yikes!");

	/* First two locations are for	*/
	/* fast underflow checking:	*/
	stk_Push( s, OBJ_FROM_BOTTOM(0) );
	stk_Push( s, OBJ_FROM_BOTTOM(0) );
        /* CFN_P(s)->src = OBJ_FROM_INT(2); */

        /* Build loop stack: */
	s = obj_Alloc( OBJ_CLASS_A_LST, 0 );
        JOB_P(o)->j.loop_stack = s;
	vm_Dirty(o);
	if (!stk_Got_Headroom( s, 32 ))   MUQ_WARN ("Yikes!");/*32==any#*/
	stk_Push( s, OBJ_FROM_INT( 0)   ); /* Bottom-of-stack sentinel. */
	stk_Push( s, (5*sizeof(Vm_Obj)) ); /* Size-in-bytes of frame.   */
	stk_Push( s, OBJ_FROM_INT(0)    ); /* Dummy pc    entry.        */
	stk_Push( s, obj_Etc_Bad        ); /* Dummy x_obj entry.        */
	stk_Push( s, JOB_STACKFRAME_NORMAL );
	stk_Push( s, (5*sizeof(Vm_Obj)) ); /* Size-in-bytes of frame.   */
        #if MUQ_IS_PARANOID
	if (OBJ_TO_INT( stk_Length(s) )
        != JOB_DUMMY_ENTRIES_AT_BOTTOM_OF_LOOP_STACK
        ){
	    MUQ_FATAL ("job:for_new");
	}
	#endif
    }

    /* Allocate a readtable: */
    {   Vm_Obj r = obj_Alloc( OBJ_CLASS_A_RDT, 0 );
	JOB_P(o)->readtable = r;
	vm_Dirty(o);
    }
}

 /***********************************************************************/
 /*-    invariants -- Sanity check on job.				*/
 /***********************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    Vm_Uch* t,
    Vm_Obj job
) {
#ifdef SOON
buggo
#endif
    return 0; /* Pacify gcc. */
}

#endif

 /***********************************************************************/
 /*-    sizeof_job -- Return size of job object.			*/
 /***********************************************************************/

static Vm_Unt
sizeof_job(
    Vm_Unt size
) {
    return sizeof( Job_A_Header );
}



/************************************************************************/
/*-    Static fns, property						*/
/************************************************************************/

 /***********************************************************************/
 /*-    job_acting_user							*/
 /***********************************************************************/

static Vm_Obj
job_acting_user(
    Vm_Obj o
) {
    if (o==jS.job)   return jS.j.acting_user;
    return JOB_P(o)->j.acting_user;
}

 /***********************************************************************/
 /*-    job_actual_user							*/
 /***********************************************************************/

static Vm_Obj
job_actual_user(
    Vm_Obj o
) {
    if (o==jS.job)   return jS.j.actual_user;
    return JOB_P(o)->j.actual_user;
}

 /***********************************************************************/
 /*-    job_data_stack							*/
 /***********************************************************************/

static Vm_Obj
job_data_stack(
    Vm_Obj o
) {
    return JOB_P(o)->j.data_stack;
}

 /***********************************************************************/
 /*-    job_ephemeral_lists						*/
 /***********************************************************************/

static Vm_Obj
job_ephemeral_lists(
    Vm_Obj o
) {
    if (o==jS.job)   return jS.j.ephemeral_lists;
    return JOB_P(o)->j.ephemeral_lists;
}

 /***********************************************************************/
 /*-    job_ephemeral_objects						*/
 /***********************************************************************/

static Vm_Obj
job_ephemeral_objects(
    Vm_Obj o
) {
    if (o==jS.job)   return jS.j.ephemeral_objects;
    return JOB_P(o)->j.ephemeral_objects;
}

 /***********************************************************************/
 /*-    job_ephemeral_structs						*/
 /***********************************************************************/

static Vm_Obj
job_ephemeral_structs(
    Vm_Obj o
) {
    if (o==jS.job)   return jS.j.ephemeral_structs;
    return JOB_P(o)->j.ephemeral_structs;
}

 /***********************************************************************/
 /*-    job_ephemeral_vectors						*/
 /***********************************************************************/

static Vm_Obj
job_ephemeral_vectors(
    Vm_Obj o
) {
    if (o==jS.job)   return jS.j.ephemeral_vectors;
    return JOB_P(o)->j.ephemeral_vectors;
}

 /***********************************************************************/
 /*-    job_function_bindings						*/
 /***********************************************************************/

static Vm_Obj
job_function_bindings(
    Vm_Obj o
) {
    if (o==jS.job)   return jS.j.function_bindings;
    return JOB_P(o)->j.function_bindings;
}

/************************************************************************/
/*-    job_group          						*/
/************************************************************************/

static Vm_Obj
job_group(
    Vm_Obj o
) {
    return JOB_P(o)->j.group;
}



 /***********************************************************************/
 /*-    job_here_obj							*/
 /***********************************************************************/

static Vm_Obj
job_here_obj(
    Vm_Obj o
) {
    return JOB_P(o)->here_obj;
}

 /***********************************************************************/
 /*-    job_job_set							*/
 /***********************************************************************/

static Vm_Obj
job_job_set(
    Vm_Obj o
) {
    return JOB_P(o)->job_set;
}

 /***********************************************************************/
 /*-    job_lib								*/
 /***********************************************************************/

static Vm_Obj
job_lib(
    Vm_Obj o
) {
    return JOB_P(o)->lib;
}

 /***********************************************************************/
 /*-    job_loop_stack							*/
 /***********************************************************************/

static Vm_Obj
job_loop_stack(
    Vm_Obj o
) {
    return JOB_P(o)->j.loop_stack;
}

 /***********************************************************************/
 /*-    job_op_count							*/
 /***********************************************************************/

static Vm_Obj
job_op_count(
    Vm_Obj o
) {
    return JOB_P(o)->op_count;
}

 /***********************************************************************/
 /*-    job_package							*/
 /***********************************************************************/

static Vm_Obj
job_package(
    Vm_Obj o
) {
    return JOB_P(o)->package;
}

 /***********************************************************************/
 /*-    job_parent							*/
 /***********************************************************************/

static Vm_Obj
job_parent(
    Vm_Obj o
) {
    return JOB_P(o)->parent;
}

 /***********************************************************************/
 /*-    job_pid								*/
 /***********************************************************************/

static Vm_Obj
job_pid(
    Vm_Obj o
) {
    return JOB_P(o)->pid;
}

 /***********************************************************************/
 /*-    job_priority							*/
 /***********************************************************************/

static Vm_Obj
job_priority(
    Vm_Obj o
) {
    return JOB_P(o)->priority;
}

 /***********************************************************************/
 /*-    job_do_error							*/
 /***********************************************************************/

static Vm_Obj
job_do_error(
    Vm_Obj o
) {
    return JOB_P(o)->do_error;
}

 /***********************************************************************/
 /*-    job_do_signal							*/
 /***********************************************************************/

static Vm_Obj
job_do_signal(
    Vm_Obj o
) {
    return JOB_P(o)->do_signal;
}

 /***********************************************************************/
 /*-    job_break_disable						*/
 /***********************************************************************/

static Vm_Obj
job_break_disable(
    Vm_Obj o
) {
    return JOB_P(o)->break_disable;
}

 /***********************************************************************/
 /*-    job_break_enable						*/
 /***********************************************************************/

static Vm_Obj
job_break_enable(
    Vm_Obj o
) {
    return JOB_P(o)->break_enable;
}

 /***********************************************************************/
 /*-    job_break_on_signal						*/
 /***********************************************************************/

static Vm_Obj
job_break_on_signal(
    Vm_Obj o
) {
    return JOB_P(o)->break_on_signal;
}

 /***********************************************************************/
 /*-    job_do_break							*/
 /***********************************************************************/

static Vm_Obj
job_do_break(
    Vm_Obj o
) {
    return JOB_P(o)->do_break;
}

 /***********************************************************************/
 /*-    job_debugger							*/
 /***********************************************************************/

static Vm_Obj
job_debugger(
    Vm_Obj o
) {
    return JOB_P(o)->debugger;
}

 /***********************************************************************/
 /*-    job_debugger_hook						*/
 /***********************************************************************/

static Vm_Obj
job_debugger_hook(
    Vm_Obj o
) {
    return JOB_P(o)->debugger_hook;
}

 /***********************************************************************/
 /*-    job_kill_stdout_on_exit						*/
 /***********************************************************************/

static Vm_Obj
job_kill_stdout_on_exit(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( JOB_P(o)->kill_standard_output_on_exit != OBJ_0 );
}

 /***********************************************************************/
 /*-    job_read_nil							*/
 /***********************************************************************/

static Vm_Obj
job_read_nil(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( JOB_P(o)->read_nil_from_dead_streams != OBJ_0 );
}

 /***********************************************************************/
 /*-    job_readtable							*/
 /***********************************************************************/

static Vm_Obj
job_readtable(
    Vm_Obj o
) {
    return JOB_P(o)->readtable;
}

 /***********************************************************************/
 /*-    job_report_event						*/
 /***********************************************************************/

static Vm_Obj
job_report_event(
    Vm_Obj o
) {
    return JOB_P(o)->report_event;
}

 /***********************************************************************/
 /*-    job_task							*/
 /***********************************************************************/

static Vm_Obj
job_task(
    Vm_Obj o
) {
    return JOB_P(o)->task;
}

 /***********************************************************************/
 /*-    job_root_obj							*/
 /***********************************************************************/

static Vm_Obj
job_root_obj(
    Vm_Obj o
) {
    return JOB_P(o)->root_obj;
}

 /***********************************************************************/
 /*-    job_q_until_msec						*/
 /***********************************************************************/
static Vm_Obj
job_q_until_msec(
    Vm_Obj o
) {
    return JOB_P(o)->until_msec;
}
 /***********************************************************************/
 /*-    job_q_until_nsec						*/
 /***********************************************************************/

#ifdef OLD
static Vm_Obj
job_q_until_nsec(
    Vm_Obj o
) {
    return JOB_P(o)->until_nsec;
}
#endif

 /***********************************************************************/
 /*-    job_stack_bottom						*/
 /***********************************************************************/

static Vm_Obj
job_stack_bottom(
    Vm_Obj o
) {
    return JOB_P(o)->stack_bottom;
}

 /***********************************************************************/
 /*-    job_state							*/
 /***********************************************************************/

static Vm_Obj
job_state(
    Vm_Obj o
) {
    /* "~state" isn't really a property on the */
    /* job at all, it is the name of the queue */
    /* which the job is in.  It seems insecure */
    /* to let the user have direct access to   */
    /* job queues, however, so this pseudo-    */
    /* property is an alternative.             */

    Vm_Obj joq = JOB_P(o)->link[JOB_QUEUE_MEMBERSHIP_MIN].this;
    if (!joq_Is_A_Joq(joq))   return OBJ_FROM_BYT3('d','e','d');
    return   JOQ_P(joq)->o.objname;
}

 /***********************************************************************/
 /*-    job_error_output						*/
 /***********************************************************************/

static Vm_Obj
job_error_output(
    Vm_Obj o
) {
    return JOB_P(o)->error_output;
}

 /***********************************************************************/
 /*-    job_get_compiler						*/
 /***********************************************************************/

static Vm_Obj
job_get_compiler(
    Vm_Obj o
) {
    return JOB_P(o)->compiler;
}

 /***********************************************************************/
 /*-    job_get_end_job							*/
 /***********************************************************************/

static Vm_Obj
job_get_end_job(
    Vm_Obj o
) {
    return JOB_P(o)->end_job;
}

 /***********************************************************************/
 /*-    job_spare_assembler						*/
 /***********************************************************************/

static Vm_Obj
job_spare_assembler(
    Vm_Obj o
) {
    return JOB_P(o)->spare_assembler;
}

 /***********************************************************************/
 /*-    job_spare_compile_message_stream				*/
 /***********************************************************************/

static Vm_Obj
job_spare_compile_message_stream(
    Vm_Obj o
) {
    return JOB_P(o)->spare_compile_message_stream;
}

 /***********************************************************************/
 /*-    job_standard_input						*/
 /***********************************************************************/

static Vm_Obj
job_standard_input(
    Vm_Obj o
) {
    return JOB_P(o)->standard_input;
}

 /***********************************************************************/
 /*-    job_standard_output						*/
 /***********************************************************************/

static Vm_Obj
job_standard_output(
    Vm_Obj o
) {
    return JOB_P(o)->standard_output;
}

 /***********************************************************************/
 /*-    job_terminal_io							*/
 /***********************************************************************/

static Vm_Obj
job_terminal_io(
    Vm_Obj o
) {
    return JOB_P(o)->terminal_io;
}

 /***********************************************************************/
 /*-    job_query_io							*/
 /***********************************************************************/

static Vm_Obj
job_query_io(
    Vm_Obj o
) {
    return JOB_P(o)->query_io;
}

 /***********************************************************************/
 /*-    job_debug_io							*/
 /***********************************************************************/

static Vm_Obj
job_debug_io(
    Vm_Obj o
) {
    return JOB_P(o)->debug_io;
}

 /***********************************************************************/
 /*-    job_doing_promiscuous_read					*/
 /***********************************************************************/

static Vm_Obj
job_doing_promiscuous_read(
    Vm_Obj o
) {
    return OBJ_FROM_BOOL( OBJ_TO_INT( JOB_P(o)->doing_promiscuous_read ) );
}

 /***********************************************************************/
 /*-    job_muqnet_io							*/
 /***********************************************************************/

static Vm_Obj
job_muqnet_io(
    Vm_Obj o
) {
    return JOB_P(o)->muqnet_io;
}

 /***********************************************************************/
 /*-    job_promiscuous_no_fragments					*/
 /***********************************************************************/

static Vm_Obj
job_promiscuous_no_fragments(
    Vm_Obj o
) {
    return JOB_P(o)->promiscuous_no_fragments;
}

 /***********************************************************************/
 /*-    job_trace_output						*/
 /***********************************************************************/

static Vm_Obj
job_trace_output(
    Vm_Obj o
) {
    return JOB_P(o)->trace_output;
}

 /***********************************************************************/
 /*-    job_variable_bindings						*/
 /***********************************************************************/

static Vm_Obj
job_variable_bindings(
    Vm_Obj o
) {
    if (o==jS.job)   return jS.j.variable_bindings;
    return JOB_P(o)->j.variable_bindings;
}

 /***********************************************************************/
 /*-    job_yy*								*/
 /***********************************************************************/

static Vm_Obj job_yylhs(      Vm_Obj o) {   return JOB_P(o)->yylhs;        }
static Vm_Obj job_yylen(      Vm_Obj o) {   return JOB_P(o)->yylen;        }
static Vm_Obj job_yydefred(   Vm_Obj o) {   return JOB_P(o)->yydefred;     }
static Vm_Obj job_yydgoto(    Vm_Obj o) {   return JOB_P(o)->yydgoto;      }
static Vm_Obj job_yysindex(   Vm_Obj o) {   return JOB_P(o)->yysindex;     }
static Vm_Obj job_yyrindex(   Vm_Obj o) {   return JOB_P(o)->yyrindex;     }
static Vm_Obj job_yygindex(   Vm_Obj o) {   return JOB_P(o)->yygindex;     }
static Vm_Obj job_YYTABLESIZE(Vm_Obj o) {   return JOB_P(o)->YYTABLESIZE;  }
static Vm_Obj job_yytable(    Vm_Obj o) {   return JOB_P(o)->yytable;      }
static Vm_Obj job_yycheck(    Vm_Obj o) {   return JOB_P(o)->yycheck;      }
static Vm_Obj job_YYFINAL(    Vm_Obj o) {   return JOB_P(o)->YYFINAL;      }
static Vm_Obj job_YYMAXTOKEN( Vm_Obj o) {   return JOB_P(o)->YYMAXTOKEN;   }
static Vm_Obj job_yyname(     Vm_Obj o) {   return JOB_P(o)->yyname;       }
static Vm_Obj job_yyrule(     Vm_Obj o) {   return JOB_P(o)->yyrule;       }
static Vm_Obj job_yyaction(   Vm_Obj o) {   return JOB_P(o)->yyaction;     }
static Vm_Obj job_yyss(       Vm_Obj o) {   return JOB_P(o)->yyss;         }
static Vm_Obj job_yyvs(       Vm_Obj o) {   return JOB_P(o)->yyvs;         }
static Vm_Obj job_yyval(      Vm_Obj o) {   return JOB_P(o)->yyval;        }
static Vm_Obj job_yylval(     Vm_Obj o) {   return JOB_P(o)->yylval;       }
static Vm_Obj job_yydebug(    Vm_Obj o) {   return JOB_P(o)->yydebug;      }
static Vm_Obj job_yyinput(    Vm_Obj o) {   return JOB_P(o)->yyinput;      }
static Vm_Obj job_yycursor(   Vm_Obj o) {   return JOB_P(o)->yycursor;     }
static Vm_Obj job_yyreadfn(   Vm_Obj o) {   return JOB_P(o)->yyreadfn;     }
static Vm_Obj job_yyprompt(   Vm_Obj o) {   return JOB_P(o)->yyprompt;     }

 /***********************************************************************/
 /*-    job_set_acting_user						*/
 /***********************************************************************/

static Vm_Obj
job_set_acting_user(
    Vm_Obj o,
    Vm_Obj v
) {
/* buggo? Need to thing about security issues here */
/* Buggo, need to worry about bytes_owned and objects_owned */
    if (!OBJ_IS_CLASS_ROT(jS.j.acting_user)) {
        MUQ_WARN ("@$s.actingUser must be .u[\"root\"] to set @$s.actingUser");
    }
    if (!OBJ_IS_OBJ( v)
    ||  !OBJ_ISA_USR(v)
    ){
        MUQ_WARN ("@$s.actingUser cannot be set to non-user value");
    }
    JOB_P(o)->j.acting_user = v;
    vm_Dirty(o);
    if (o==jS.job) jS.j.acting_user = v;
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_actual_user						*/
 /***********************************************************************/

static Vm_Obj
job_set_actual_user(
    Vm_Obj o,
    Vm_Obj v
) {
    if (!OBJ_IS_CLASS_ROT(jS.j.acting_user)) {
        MUQ_WARN ("@$s.actingUser must be .u[\"root\"] to set @$s.actualUser");
    }
    if (!OBJ_IS_OBJ( v)
    ||  !OBJ_ISA_USR(v)
    ){
        MUQ_WARN ("@$s.actualUser cannot be set to non-user value");
    }
    JOB_P(o)->j.actual_user = v;
    vm_Dirty(o);
    if (o==jS.job) jS.j.actual_user = v;
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_data_stack						*/
 /***********************************************************************/

static Vm_Obj
job_set_data_stack(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_compiler						*/
 /***********************************************************************/

static Vm_Obj
job_set_compiler(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->compiler = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_end_job							*/
 /***********************************************************************/

static Vm_Obj
job_set_end_job(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_ephemeral_lists						*/
 /***********************************************************************/

static Vm_Obj
job_set_ephemeral_lists(
    Vm_Obj o,
    Vm_Obj v
) {
    /* I don't see any reason to allow this:   */
/*  JOB_P(o)->j.ephemeral_lists = v;           */
/*  vm_Dirty(o);                               */
/*  if (o==jS.job) jS.j.ephemeral_lists = v;   */
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_ephemeral_objects					*/
 /***********************************************************************/

static Vm_Obj
job_set_ephemeral_objects(
    Vm_Obj o,
    Vm_Obj v
) {
    /* I don't see any reason to allow this:   */
/*  JOB_P(o)->j.ephemeral_objects = v;         */
/*  vm_Dirty(o);                               */
/*  if (o==jS.job) jS.j.ephemeral_objects = v; */
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_ephemeral_structs					*/
 /***********************************************************************/

static Vm_Obj
job_set_ephemeral_structs(
    Vm_Obj o,
    Vm_Obj v
) {
    /* I don't see any reason to allow this:   */
/*  JOB_P(o)->j.ephemeral_structs = v;         */
/*  vm_Dirty(o);                               */
/*  if (o==jS.job) jS.j.ephemeral_structs = v; */
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_ephemeral_vectors					*/
 /***********************************************************************/

static Vm_Obj
job_set_ephemeral_vectors(
    Vm_Obj o,
    Vm_Obj v
) {
    /* I don't see any reason to allow this:   */
/*  JOB_P(o)->j.ephemeral_vectors = v;         */
/*  vm_Dirty(o);                               */
/*  if (o==jS.job) jS.j.ephemeral_vectors = v; */
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_function_bindings					*/
 /***********************************************************************/

static Vm_Obj
job_set_function_bindings(
    Vm_Obj o,
    Vm_Obj v
) {
    /* I don't see any reason to allow this:   */
/*  JOB_P(o)->j.function_bindings = v;         */
/*  vm_Dirty(o);                               */
/*  if (o==jS.job) jS.j.function_bindings = v; */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    job_set_group        						*/
/************************************************************************/

Vm_Obj
job_set_group(
    Vm_Obj o,
    Vm_Obj v
) {
/* BUGGO: Need some validity checks here...    */
/* BUGGO: May want to never set this directly, */
/* only via an as-group-do{ ... } construct.   */
    JOB_P(o)->j.group = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_here_obj						*/
 /***********************************************************************/

static Vm_Obj
job_set_here_obj(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->here_obj = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_job_set							*/
 /***********************************************************************/

static Vm_Obj
job_set_job_set(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->job_set = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_lib							*/
 /***********************************************************************/

static Vm_Obj
job_set_lib(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->lib = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_never							*/
 /***********************************************************************/

static Vm_Obj
job_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_op_count						*/
 /***********************************************************************/

static Vm_Obj
job_set_op_count(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_package							*/
 /***********************************************************************/

static Vm_Obj
job_set_package(
    Vm_Obj o,
    Vm_Obj v
) {
    if (!OBJ_IS_OBJ(v)
    ||  !OBJ_IS_CLASS_PKG(v)
    ){
	MUQ_WARN ("May not set anyjob$s.package to non-package value.");
    }
    JOB_P(o)->package = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_parent							*/
 /***********************************************************************/

static Vm_Obj
job_set_parent(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->parent = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_pid							*/
 /***********************************************************************/

static Vm_Obj
job_set_pid(
    Vm_Obj o,
    Vm_Obj v
) {
    /* We don't allow fiddling pids: */
    /* JOB_P(o)->pid = v;	*/
    /* vm_Dirty(o);		*/
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_priority						*/
 /***********************************************************************/

static Vm_Obj
job_set_priority(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)
    && ((Vm_Unt)(OBJ_TO_UNT(v)) < JOB_PRIORITY_LEVELS)
    ){
        JOB_P(o)->priority = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_do_error						*/
 /***********************************************************************/

static Vm_Obj
job_set_do_error(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->do_error = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_do_signal						*/
 /***********************************************************************/

static Vm_Obj
job_set_do_signal(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->do_signal = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_break_disable						*/
 /***********************************************************************/

static Vm_Obj
job_set_break_disable(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->break_disable = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_break_enable						*/
 /***********************************************************************/

static Vm_Obj
job_set_break_enable(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->break_enable = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_break_on_signal						*/
 /***********************************************************************/

static Vm_Obj
job_set_break_on_signal(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->break_on_signal = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_do_break						*/
 /***********************************************************************/

static Vm_Obj
job_set_do_break(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->do_break = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_debugger						*/
 /***********************************************************************/

static Vm_Obj
job_set_debugger(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->debugger = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_debugger_hook						*/
 /***********************************************************************/

static Vm_Obj
job_set_debugger_hook(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->debugger_hook = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_kill_stdout_on_exit					*/
 /***********************************************************************/

static Vm_Obj
job_set_kill_stdout_on_exit(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->kill_standard_output_on_exit = OBJ_FROM_INT( v != OBJ_NIL );
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_read_nil						*/
 /***********************************************************************/

static Vm_Obj
job_set_read_nil(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->read_nil_from_dead_streams = OBJ_FROM_INT( v != OBJ_NIL );
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_readtable						*/
 /***********************************************************************/

static Vm_Obj
job_set_readtable(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_RDT(v)) {
	JOB_P(o)->readtable = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_report_event						*/
 /***********************************************************************/

static Vm_Obj
job_set_report_event(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->report_event = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_task							*/
 /***********************************************************************/

static Vm_Obj
job_set_task(
    Vm_Obj o,
    Vm_Obj v
) {
    JOB_P(o)->task = v;    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_root_obj						*/
 /***********************************************************************/

static Vm_Obj
job_set_root_obj(
    Vm_Obj o,
    Vm_Obj v
) {
    job_Must_Be_Root();
    JOB_P(o)->root_obj = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_stack_bottom						*/
 /***********************************************************************/

static Vm_Obj
job_set_stack_bottom(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_state							*/
 /***********************************************************************/

static Vm_Obj
job_set_state(
    Vm_Obj o,
    Vm_Obj v
) {
    /* "~state" is a pseudoprop, so we */
    /* just ignore attempts to set it: */
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_error_output						*/
 /***********************************************************************/

static Vm_Obj
job_set_error_output(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	JOB_P(o)->error_output = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_spare_assembler						*/
 /***********************************************************************/

static Vm_Obj
job_set_spare_assembler(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL
    ||  OBJ_IS_OBJ(v) && OBJ_IS_CLASS_ASM(v)
    ){
	JOB_P(o)->spare_assembler = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_spare_compile_message_stream				*/
 /***********************************************************************/

static Vm_Obj
job_set_spare_compile_message_stream(
    Vm_Obj o,
    Vm_Obj v
) {
    if (v == OBJ_NIL
    ||  OBJ_IS_OBJ(v)
    ){
	JOB_P(o)->spare_compile_message_stream = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_standard_input						*/
 /***********************************************************************/

static Vm_Obj
job_set_standard_input(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	JOB_P(o)->standard_input = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_standard_output						*/
 /***********************************************************************/

static Vm_Obj
job_set_standard_output(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
        JOB_P(o)->standard_output = v;
        vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_terminal_io						*/
 /***********************************************************************/

static Vm_Obj
job_set_terminal_io(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	JOB_P(o)->terminal_io = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_query_io						*/
 /***********************************************************************/

static Vm_Obj
job_set_query_io(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	JOB_P(o)->query_io = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_debug_io						*/
 /***********************************************************************/

static Vm_Obj
job_set_debug_io(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	JOB_P(o)->debug_io = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_muqnet_io						*/
 /***********************************************************************/

static Vm_Obj
job_set_muqnet_io(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	JOB_P(o)->muqnet_io = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_trace_output						*/
 /***********************************************************************/

static Vm_Obj
job_set_trace_output(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_MSS(v)) {
	JOB_P(o)->trace_output = v;
	vm_Dirty(o);
    }
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_variable_bindings					*/
 /***********************************************************************/

static Vm_Obj
job_set_variable_bindings(
    Vm_Obj o,
    Vm_Obj v
) {
    /* I don't see any reason to allow this:   */
/*  JOB_P(o)->j.variable_bindings = v;         */
/*  vm_Dirty(o);                               */
/*  if (o==jS.job) jS.j.variable_bindings = v; */
    return (Vm_Obj) 0;
}

 /***********************************************************************/
 /*-    job_set_yy*							*/
 /***********************************************************************/

static Vm_Obj job_set_yylhs(      Vm_Obj o, Vm_Obj v) { JOB_P(o)->yylhs      = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yylen(      Vm_Obj o, Vm_Obj v) { JOB_P(o)->yylen      = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yydefred(   Vm_Obj o, Vm_Obj v) { JOB_P(o)->yydefred   = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yydgoto(    Vm_Obj o, Vm_Obj v) { JOB_P(o)->yydgoto    = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yysindex(   Vm_Obj o, Vm_Obj v) { JOB_P(o)->yysindex   = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyrindex(   Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyrindex   = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yygindex(   Vm_Obj o, Vm_Obj v) { JOB_P(o)->yygindex   = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_YYTABLESIZE(Vm_Obj o, Vm_Obj v) { JOB_P(o)->YYTABLESIZE= v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yytable(    Vm_Obj o, Vm_Obj v) { JOB_P(o)->yytable    = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yycheck(    Vm_Obj o, Vm_Obj v) { JOB_P(o)->yycheck    = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_YYFINAL(    Vm_Obj o, Vm_Obj v) { JOB_P(o)->YYFINAL    = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_YYMAXTOKEN( Vm_Obj o, Vm_Obj v) { JOB_P(o)->YYMAXTOKEN = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyname(     Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyname     = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyrule(     Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyrule     = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyaction(   Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyaction   = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyss(       Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyss       = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyvs(       Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyvs       = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyval(      Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyval      = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yylval(     Vm_Obj o, Vm_Obj v) { JOB_P(o)->yylval     = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yydebug(    Vm_Obj o, Vm_Obj v) { JOB_P(o)->yydebug    = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyinput(    Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyinput    = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yycursor(   Vm_Obj o, Vm_Obj v) { JOB_P(o)->yycursor   = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyreadfn(   Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyreadfn   = v; vm_Dirty(o);  return (Vm_Obj) 0; }
static Vm_Obj job_set_yyprompt(   Vm_Obj o, Vm_Obj v) { JOB_P(o)->yyprompt   = v; vm_Dirty(o);  return (Vm_Obj) 0; }


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
