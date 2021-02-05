/*--   job.h -- Header for job.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_JOB_H
#define INCLUDED_JOB_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "cfn.h"
#include "obj.h"
#include "rex.h"
#include "vm.h"
#include "jobprims.h"
#include "joq.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a job: */
#define JOB_P(o) ((Job_Header)vm_Loc(o))

/* Max slots in a ]signal block.  Signal blocks */
/* may wind up going out as a datagram, we'd    */
/* prefer not to spam the interface with huge   */
/* datagrams, and signals aren't intended for   */
/* file transfer or such, so we deliberately    */
/* keep this limit pretty low:                  */
#ifndef JOB_SIGNAL_BLOCK_MAX
#define JOB_SIGNAL_BLOCK_MAX (128)
#endif

/* Changing this will break stuff */
/* unless you're -very- thorough: */
#define JOB_PRIORITY_LEVELS 3

/* Max number of queues job can be in at once. */
/* Should be at least three: ps q, run q and   */
/* doz q for timing out:                       */
#define JOB_QUEUE_MEMBERSHIP_MAX (16)

/* Number of above slots reserved for special  */
/* purposes.  Currently this is four:          */
/* One for the ~%s/ps jobqueue, and            */
/* one for the    /ps jobqueue, and            */
/* one for the jobset jobqueue, and            */
/* one for the /etc/doz sleep jobqueue.        */
/* NOTE: joq_Dequeue() assumes JOB_QUEUE_DOZ   */
/* is last in this list:                       */
#define JOB_QUEUE_PS             (0)
#define JOB_QUEUE_GLOBAL_PS      (1)
#define JOB_QUEUE_JOBSET         (2)
#define JOB_QUEUE_DOZ            (3)
#define JOB_QUEUE_MEMBERSHIP_MIN (4)

/* Values for job 'privs' word: */
#define JOB_PRIVS_OMNIPOTENT 0x04 /* True to disable most security checks.*/
#define JOB_PRIVS_SAY    0x08	/* True if executing say/pose/whisper	*/

#define JOB_IS_OMNIPOTENT (job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
#define JOB_IS_SAY  (job_RunState.j.privs & JOB_PRIVS_SAY)

/* Macro itemizing all priv bits which confer special */
/* powers, so we can clear them all easily:           */
#define JOB_PRIVS_ALL_POWERS       (JOB_PRIVS_OMNIPOTENT)

/* Macro itemizing all priv bits which impose special */
/* restrictions, so we can set them all easily:       */
#define JOB_PRIVS_ALL_RESTRICTIONS (JOB_PRIVS_SAY)


/* Horrible constant, shouldn't exist.   */
/* Max string etc length '.' can handle: */
#ifndef JOB_MAX_LINE
#define JOB_MAX_LINE 0x1000
#endif

/* Parameters for job_P_Fork(): */
#define JOB_FORK_JOB	  (1)
#define JOB_FORK_JOBSET	  (2)
#define JOB_FORK_SESSION  (3)

/* Macros to go from a loopstack frame to adjacent ones: */
#define JOB_PREV_STACKFRAME(l) \
    ((Vm_Obj*) (((Vm_Uch*)l) - (Vm_Int)(*(Vm_Obj*)l)))
#define JOB_NEXT_STACKFRAME(l) \
    ((Vm_Obj*) (((Vm_Uch*)l) + (Vm_Int)(*(Vm_Obj*)l)))
/* Number of non-boundary-tag Vm_Obj slots in stackframe: */
#define JOB_SIZE_STACKFRAME(l) \
    ((Vm_Int)((((Vm_Unt)(*(Vm_Obj*)l))/sizeof(Vm_Obj))-2))

/* Define a convenience macro which converts */
/* a pointer to top of a HANDLING stackframe */
/* into a pointer to the opcode word of the  */
/* corresponding HANDLERS stackframe:        */
#undef  JOB_HANDLERS_OPCODE
#define JOB_HANDLERS_OPCODE(l) ((Vm_Obj*) (((Vm_Uch*)(jS.l_bot)) + l[-2]))

/* Size of internal job hashtable used for   */
/* resolving special bindings and such:	     */
#define JOB_HASHTAB_MAX	(64)


/* Macro to test that n data stack args are available.	*/
/* Explicit cast to Vm_Uch* and multiplication by	*/
/* sizeof(Vm_Obj) is probably faster than risking	*/
/* the compiler doing a divide by sizeof(Vm_Obj).	*/
/* Casting to Vm_Unt is a fast way of making		*/
/* negative arguments ("-1 pick", say) fail:		*/
#define JOB_DATA_NEEDED_FAST(n,x)      		\
    {   if ((Vm_Unt)(				\
	        (Vm_Uch*)jSs              -	\
                (Vm_Uch*)job_RunState.s_bot	\
            ) 					\
            < 					\
	    (Vm_Unt)((n) * sizeof(Vm_Obj))	\
        ){					\
	    x;					\
	    job_UNDERFLOW(JOB_PRIM_ARGS);	\
	    return;				\
    }	}	    
	
#define JOB_RESERVED_SLOTS 32



/************************************************************************/
/*-    types								*/


/************************************************************************/
/*-    Job_A_State -- Core state of a job.				*/

struct Job_A_State_Rec {

/* buggo, actual_user doesn't seem to get used   */
/* enough to justify including it in core state: */
    Vm_Obj      actual_user;	/* User for whom work is being done.	*/
    Vm_Obj      acting_user;	/* User whose permissions we possess.	*/

/* buggo? What justifies having these in core    */
/* state of job??                                */
    Vm_Obj	data_stack;	/* Data stack proper.			*/
    Vm_Obj	loop_stack;	/* Loop stack proper.			*/

    Vm_Obj	group;		/* Group user is acting as.		*/

/* buggo? It would be really nice pre-beta to expand  */
/* these into a small hashtable of binding links,     */
/* say 64-128 long, so as to speed up access to       */
/* special variables.  Among other things, this would */
/* make me feel better about turning all CommonLisp-  */
/* defined "standard" global variables into per-job   */
/* special variable bindings, which would nicely      */
/* maximize both sanity and standard conformance.     */
/* If we presume all jobs get squished at server      */
/* restart, however, we may be able to get away with  */
/* doing this hack post-beta.                         */
    Vm_Obj	function_bindings;/* Function bindings on loop stack.	*/
    Vm_Obj	variable_bindings;/* Variable bindings on loop stack.	*/
    Vm_Obj	ephemeral_lists;  /* Ephemeral lists   on loop stack.	*/
    Vm_Obj	ephemeral_objects;/* Ephemeral objects on loop stack.	*/
    Vm_Obj	ephemeral_structs;/* Ephemeral structs on loop stack.	*/
    Vm_Obj	ephemeral_vectors;/* Ephemeral vectors on loop stack.	*/

    /* Unused, but reserved for above improvement: */
    Vm_Obj	binding_hashtab[ JOB_HASHTAB_MAX ];

    Vm_Obj      privs;		/* OMNIPOTENT, SAY, ...			*/
};
typedef struct Job_A_State_Rec  Job_A_State;
typedef struct Job_A_State_Rec*   Job_State;



/************************************************************************/
/*-    Job_RunState -- Structure for an executing job.			*/

/* Structure to hold currently executing job: */
struct Job_RunState_Rec {

    Vm_Unt	ops;		/* Bytecodes executed this tick. 	*/

    /* Our canonical hard pointers into bigbuf -- all objects		*/
    /* which vm.c must lock into ram:					*/
    Vm_Obj*	v;		/*  Local variables vector ram address.	*/
    Vm_Obj*	k;		/*  Local constants vector ram address.	*/
    Vm_Int	instruction_len;/* Length in bytes of current instr.	*/
    Vm_Uch*	pc;		/* Somewhere in fn_code.		*/
    Vm_Obj*	l;		/* Loop stack stack pointer.		*/
    Vm_Obj*	l_bot;		/* Loop stack lower limit.		*/
    Vm_Obj*	l_top;		/* Loop stack upper limit.		*/
    Vm_Obj*	s;		/* Data stack stack pointer.		*/
    Vm_Obj*	s_bot;		/* Data stack lower limit.		*/
    Vm_Obj*	s_top;		/* Data stack upper limit.		*/
    Vm_Obj*	s_0;		/* Data stack slot zero.		*/

    Vm_Obj	data_vector;	/* Data stack vector.			*/
    Vm_Obj	loop_vector;	/* Loop stack vector.			*/

    Vm_Unt	bytes_owned;	/* Bytes owned by active_user. 		*/
    Vm_Unt	byte_quota;	/* Bytes permitted by active_user.	*/
    Vm_Unt	objects_owned;	/* Objects owned by  active_user. 	*/
    Vm_Unt	object_quota;	/* Objects permitted active_user. 	*/

    Vm_Obj	now;		/* Current system time.			*/
    Vm_Obj	job;		/* Current job.				*/
    Vm_Obj	x_obj;		/* Current compiledFunction.		*/
    Job_A_State j;		/* Image of job state.			*/
};
typedef struct Job_RunState_Rec  Job_A_RunState;
typedef struct Job_RunState_Rec*   Job_RunState;

struct Rex_Job_Rec job_Rex;


/************************************************************************/
/*-    Job_Header_Rec -- Our refinement of Obj_Header_Rec		*/

struct Job_Header_Rec {
    Obj_A_Header	o;

/* Needed still: */
/* setgid stuff? */
/* bytes allocated? */
/* db reads/writes? */
    /* Job queue stuff.  Keep these at top, matching usr.c: */

    #undef M
    #define M JOB_QUEUE_MEMBERSHIP_MAX
    Joq_A_Link  link[M];	/* Job queue links.			*/
    #undef M

    /* 0 normally, 1 while doing a |readAnyStreamPacket:		*/
    Vm_Obj	doing_promiscuous_read;
    /* t or nil      while doing a |readAnyStreamPacket:		*/
    Vm_Obj	promiscuous_no_fragments;

    Vm_Obj	pid;		/* Integer ID assigned by server.	*/
#ifdef OLD
    Vm_Obj	until_sec;	/* Sleep-until date for sleeping jobs.	*/
    Vm_Obj	until_nsec;	/* Subsecond resolution for above.	*/
#else
    Vm_Obj	until_msec;	/* Sleep-until date for sleeping jobs.	*/
#endif
/* buggo, should zap this and */
/* add a stackframe which can */
/* accomodate multiple queues */
/* to which job should return */
    Vm_Obj	q_pre_stop;	/* Queue in which stopped job was.	*/

    Vm_Obj	priority;	/* Integer, 0->JOB_PRIORITY_LEVELS-1.	*/


    Vm_Obj	owner;		/* User object owning job.		*/

    /* Job accounting: */
    Vm_Obj	op_count;	/* Bytecodes executed.		 	*/
    Vm_Obj	parent;		/* Job that fork()ed us.		*/
    Vm_Obj	job_set;	/* Job set of which we are a member.	*/



    /* Core job state: */
    Job_A_State j;

    /* Random state: */
    Vm_Obj	random_state_high_half;	/* Currently unused, but we	*/
    Vm_Obj	random_state_low_half;	/* should use these someday.	*/

    Vm_Obj	stack_bottom;	/* Data stack lower limit.		*/
    Vm_Obj	frame_base;	/* Int offset into loop stack.		*/

    Vm_Obj	self;		/* Currently executing object.		*/
    Vm_Obj	class;		/* Obj of last method (for send-super).	*/

    Vm_Obj	root_obj;	/* Root object for process.		*/
    Vm_Obj	here_obj;	/* 'Current directory'.			*/

    Vm_Obj	package;	/* Current package.			*/
    Vm_Obj	lib;		/* Known   packages.			*/
    Vm_Obj	readtable;	/* Lisp readtable.			*/

    Vm_Obj	standard_input;	/* Three streams corresponding to unix	*/
    Vm_Obj	standard_output;/* stdin/stdout/stderr.			*/
    Vm_Obj	error_output;	/*					*/
    Vm_Obj	trace_output;	/* More streams matching CommonLisp.	*/
    Vm_Obj	terminal_io;	/*                                  	*/
    Vm_Obj	query_io;	/*                                  	*/
    Vm_Obj	debug_io;	/*                                  	*/

    Vm_Obj	muqnet_io;	/* Strictly for transparent networking	*/

    Vm_Obj	do_error;       /* Fn to invoke on server-detected errs.*/
    Vm_Obj	do_signal;	/* Fn which ]signal should run.		*/
    Vm_Obj	report_event;   /* Defaults to ]reportEvent.		*/
    Vm_Obj	debugger_hook;	/* Fn which ]invokeDebugger should run.*/
    Vm_Obj	debugger;	/* Fn which ]invokeDebugger should run.*/
    Vm_Obj	do_break;	/* Fn which break            should run.*/
    Vm_Obj	break_on_signal;/* Non-NIL runs debugger on all signals.*/
    Vm_Obj	break_disable;  /* non-NIL turns all breaks into no-ops.*/
    Vm_Obj	break_enable;   /* non-NIL allows ]error/]cerror breaks.*/

    /* Compiler instance (not program) in use by shell. */
    /* This is so user can set compiler's notion of the */
    /* current line number, and such:                   */
    Vm_Obj	compiler;

    /* As a hack to reduce garbage generation during    */      
    /* compiles, we can keep one spare unused assembler */
    /* around. This provides a standard spot to keep it:*/
    Vm_Obj	spare_assembler;
    Vm_Obj	spare_compile_message_stream;

    /* Place to put the value given to 'endJob': */
    Vm_Obj	end_job;

    Vm_Obj      read_nil_from_dead_streams;
    Vm_Obj      kill_standard_output_on_exit;

    Vm_Obj	task;    	    /* Support for ASYNCH package	*/

    struct Rex_Job_Rec rex;	    /* Support for regular expression.	*/

    /* yyparse support.  This is ugly but I don't want to take time */
    /* to dream up and implement something better at the moment:    */
    Vm_Obj      yylhs;
    Vm_Obj      yylen;
    Vm_Obj      yydefred;
    Vm_Obj      yydgoto;
    Vm_Obj      yysindex;
    Vm_Obj      yyrindex;
    Vm_Obj      yygindex;
    Vm_Obj      YYTABLESIZE;
    Vm_Obj      yytable;
    Vm_Obj      yycheck;
    Vm_Obj      YYFINAL;
    Vm_Obj      YYMAXTOKEN;
    Vm_Obj      yyname;
    Vm_Obj      yyrule;
    Vm_Obj      yyaction;

    Vm_Obj      yyss;	/* State stack -- central data structure.   */
    Vm_Obj      yyvs;	/* Value stack, parallel to state stack.    */
    Vm_Obj      yyval;	/* ACTIONS put rule value in this variable. */
    Vm_Obj      yylval;	/* LEXER puts token value in this variable. */
    Vm_Obj      yydebug;/* Set true for vebose logging of parsing.  */
    Vm_Obj      yyinput;/* String being parsed.			    */
    Vm_Obj      yycursor;/*Offset in previous.			    */
    Vm_Obj      yyreadfn;/*Function to supply next line to read.    */
    Vm_Obj      yyprompt;/*If non-nil, should prompt for input.     */

    Vm_Obj      reserved_slot[ JOB_RESERVED_SLOTS ];
};
typedef struct Job_Header_Rec Job_A_Header;
typedef struct Job_Header_Rec*  Job_Header;
typedef struct Job_Header_Rec*  Job_P;





/************************************************************************/
/*-    externs								*/

extern void       job_Startup( void              );
extern void       job_Linkup(  void              );
extern void       job_Shutdown(void              );
#ifdef OLD
extern Vm_Obj     job_Import(   FILE* );
extern void       job_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Int     job_Now(      void );
extern Vm_Obj	  job_Code_Signature( void );

extern void       job_P_Join( void );
extern void       job_P_Make_From_Keysvals_Block( void );
extern void       job_P_Get_Substring( void );
extern void       job_P_Get_Substring_Block( void );
extern void       job_P_Add_Muf_Source( void );
extern void       job_Fatal( Vm_Uch *format, ... );

#ifndef SOMETIMES_USEFUL
extern void	  job_P_Debug_Print( void );
extern void	  job_P_Dil_Test( void );
#endif

extern void	  job_Print_Here( FILE*, Vm_Obj, Vm_Int );
extern void	  job_Print_Global_Variables( FILE*, Vm_Obj );
extern void	  job_Print_Jobs( FILE* );
extern void       job_Print1( Vm_Uch*, Vm_Obj* );
extern Vm_Int     job_Is_Idle(void);
extern Vm_Int     job_Got_Headroom(       Vm_Unt );
extern void       job_Guarantee_Headroom( Vm_Unt );
extern void       job_Guarantee_N_Args(   Vm_Unt );
extern void       job_Must_Be_Root(       void   );
extern void       job_Must_Control_With_Err_Msg(Vm_Obj,Vm_Uch*);
extern void       job_Must_Control(       Vm_Int );
extern void       job_Must_Control_Object(Vm_Int );
extern void       job_Must_Scry(          Vm_Int );
extern void       job_Must_Scry_Object(   Vm_Int );
extern void       job_Call(               Vm_Obj );
extern void       job_Calla(              Vm_Obj );
extern void       job_LispCall(           Vm_Obj );
#ifdef OLD
extern void       job_P_Call_Method(      void   );
#endif

extern void       job_Strftime( Vm_Uch*,Vm_Int,Vm_Uch*,Vm_Int);

extern Vm_Obj     job_Path_Get_Unrooted( Vm_Obj, Vm_Int );
extern Vm_Obj     job_Path_Get_Unrooted_Asciz( Vm_Uch*, Vm_Int );

extern void       job_Path_Set_Unrooted( Vm_Obj, Vm_Obj );
extern void       job_Path_Set_Unrooted_Asciz( Vm_Uch*, Vm_Obj );

extern Vm_Obj     job_Symbol_Function( Vm_Obj );
extern Vm_Obj     job_Symbol_Value(    Vm_Obj );
extern Vm_Obj     job_Symbol_Boundp(   Vm_Obj );

extern void	  job_Make(		Vm_Int);
extern Vm_Obj     job_Make_Job(         Vm_Int, Vm_Obj);

#ifndef NEW_HEADER
extern char*      job_Debyte_Muqnet_Header(Vm_Obj*,Vm_Obj*,Vm_Obj*,Vm_Obj*,Vm_Obj*,Vm_Int*,Vm_Int*,Vm_Int*);
#else
extern char*      job_Debyte_Muqnet_Header(Vm_Obj*,Vm_Obj*,Vm_Obj*,Vm_Obj*,Vm_Int*,Vm_Int*,Vm_Int*);
#endif

extern void job_P_Public_Del_Key(            void);
extern void job_P_Public_Del_Key_P(          void);
extern void job_P_Public_Get_Key_P(          void);
extern void job_P_Public_Get_First_Key(      void);
extern void job_P_Public_Get_Keys_By_Prefix( void);
extern void job_P_Public_Get_Next_Key(       void);
extern void job_P_Public_Get_Val(            void);
extern void job_P_Public_Get_Val_P(          void);
extern void job_P_Public_Keysvals_Block(     void);
extern void job_P_Public_Keys_Block(         void);
extern void job_P_Public_Set_From_Block(     void);
extern void job_P_Public_Set_From_Keysvals_Block(void);
extern void job_P_Public_Set_Val(            void);
extern void job_P_Public_Set_Vals_Block(     void);
extern void job_P_Public_Vals_Block(	     void );

extern void job_P_Hidden_Del_Key(            void);
extern void job_P_Hidden_Del_Key_P(          void);
extern void job_P_Hidden_Get_Key_P(          void);
extern void job_P_Hidden_Get_First_Key(      void);
extern void job_P_Hidden_Get_Keys_By_Prefix( void);
extern void job_P_Hidden_Get_Next_Key(       void);
extern void job_P_Hidden_Get_Val(            void);
extern void job_P_Hidden_Get_Val_P(          void);
extern void job_P_Hidden_Keysvals_Block(     void);
extern void job_P_Hidden_Keys_Block(         void);
extern void job_P_Hidden_Set_From_Block(     void);
extern void job_P_Hidden_Set_From_Keysvals_Block(void);
extern void job_P_Hidden_Set_Val(            void);
extern void job_P_Hidden_Set_Vals_Block(     void);
extern void job_P_Hidden_Vals_Block(	     void );

extern void job_P_Admins_Del_Key(            void);
extern void job_P_Admins_Del_Key_P(          void);
extern void job_P_Admins_Get_Key_P(          void);
extern void job_P_Admins_Get_First_Key(      void);
extern void job_P_Admins_Get_Keys_By_Prefix( void);
extern void job_P_Admins_Get_Next_Key(       void);
extern void job_P_Admins_Get_Val(            void);
extern void job_P_Admins_Get_Val_P(          void);
extern void job_P_Admins_Keysvals_Block(     void);
extern void job_P_Admins_Keys_Block(         void);
extern void job_P_Admins_Set_From_Block(     void);
extern void job_P_Admins_Set_From_Keysvals_Block(void);
extern void job_P_Admins_Set_Val(            void);
extern void job_P_Admins_Set_Vals_Block(     void);
extern void job_P_Admins_Vals_Block(	     void );

extern void job_P_System_Del_Key(            void);
extern void job_P_System_Del_Key_P(          void);
extern void job_P_System_Get_Key_P(          void);
extern void job_P_System_Get_First_Key(      void);
extern void job_P_System_Get_Keys_By_Prefix( void);
extern void job_P_System_Get_Next_Key(       void);
extern void job_P_System_Get_Val(            void);
extern void job_P_System_Get_Val_P(          void);
extern void job_P_System_Keysvals_Block(     void);
extern void job_P_System_Keys_Block(         void);
extern void job_P_System_Set_From_Block(     void);
extern void job_P_System_Set_From_Keysvals_Block(void);
extern void job_P_System_Set_Val(            void);
extern void job_P_System_Set_Vals_Block(     void);
extern void job_P_System_Vals_Block(	     void );

#ifdef OLD
extern void job_P_Method_Del_Key(            void);
extern void job_P_Method_Del_Key_P(          void);
extern void job_P_Method_Get_First_Key(      void);
extern void job_P_Method_Get_Key_P(          void);
extern void job_P_Method_Get_Keys_By_Prefix( void);
extern void job_P_Method_Get_Next_Key(       void);
extern void job_P_Method_Get_Val(            void);
extern void job_P_Method_Get_Val_P(          void);
extern void job_P_Method_Keysvals_Block(     void);
extern void job_P_Method_Keys_Block(         void);
extern void job_P_Method_Set_From_Block(     void);
extern void job_P_Method_Set_From_Keysvals_Block(void);
extern void job_P_Method_Set_Val(            void);
extern void job_P_Method_Set_Vals_Block(     void);
extern void job_P_Method_Vals_Block(	     void );
#endif

extern void job_P_Muqnet_Del_Key(            void);
extern void job_P_Muqnet_Del_Key_P(          void);
extern void job_P_Muqnet_Get_First_Key(      void);
extern void job_P_Muqnet_Get_Key_P(          void);
extern void job_P_Muqnet_Get_Keys_By_Prefix( void);
extern void job_P_Muqnet_Get_Next_Key(       void);
extern void job_P_Muqnet_Get_Val(            void);
extern void job_P_Muqnet_Get_Val_P(          void);
extern void job_P_Muqnet_Keysvals_Block(     void);
extern void job_P_Muqnet_Keys_Block(         void);
extern void job_P_Muqnet_Set_From_Block(     void);
extern void job_P_Muqnet_Set_From_Keysvals_Block(void);
extern void job_P_Muqnet_Set_Val(            void);
extern void job_P_Muqnet_Set_Vals_Block(     void);
extern void job_P_Muqnet_Vals_Block(	     void );


extern void       job_P_Acting_User(            void );
extern void       job_P_Actual_User(            void );
extern void       job_P_Aeq(                    void );
extern void       job_P_Age(                    void );
extern void       job_P_Agt(                    void );
extern void       job_P_Ale(                    void );
extern void       job_P_Alpha_Char_P(           void );
extern void       job_P_Alphanumeric_P(         void );
extern void       job_P_Alt(                    void );
extern void       job_P_And_Bits(               void );
extern void       job_P_Ane(                    void );
extern void       job_P_Applicable_Method_P(    void );
extern void       job_P_Apply_Lambda_List(      void );
extern void       job_P_Apply_Read_Lambda_List( void );
extern void       job_P_Apply_Print_Lambda_List(void );
extern void       job_P_Aref(			void );
extern void       job_P_Array_P(		void );
extern void       job_P_Aset(			void );
extern void       job_P_Assemble_After(         void );
extern void       job_P_Assemble_After_Child(   void );
extern void       job_P_Assemble_Always_Do(     void );
extern void       job_P_Assemble_Beq(           void );
extern void       job_P_Assemble_Bne(           void );
extern void       job_P_Assemble_Bra(           void );
extern void       job_P_Assemble_Call(          void );
extern void       job_P_Assemble_Calla(         void );
extern void       job_P_Assemble_Catch(         void );
extern void       job_P_Assemble_Tag(           void );
extern void       job_P_Assemble_Constant(      void );
extern void       job_P_Assemble_Constant_Slot( void );
extern void       job_P_Assemble_Label(         void );
extern void       job_P_Assemble_Label_Get(     void );
extern void       job_P_Assemble_Line_In_Fn(    void );
extern void       job_P_Assemble_Nth_Constant_Get( void );
extern void       job_P_Assemble_Variable_Get(  void );
extern void       job_P_Assemble_Variable_Set(  void );
extern void       job_P_Assemble_Variable_Slot( void );
extern void       job_P_Assembler_P(            void );
extern void       job_P_Backslashes_To_Highbit(	void );
extern void       job_P_Bad(                    void );
extern void       job_P_Bias(                   void );
extern void       job_P_Bignum_P(               void );
extern void       job_P_Bits(                   void );
extern void       job_P_Blanch_Protectframe(    void );
extern void       job_P_Block_Break(            void );
extern void       job_P_Block_Length(           void );
extern void       job_P_Block_P(                void );
extern void       job_P_Bound_P(                void );
extern void       job_P_Bracket_Position_In_Block( void );
extern void       job_P_Break(                  void );
extern void       job_P_Btree_Get(              void );
extern void       job_P_Btree_Set(              void );
extern void       job_P_Btree_Delete(           void );
extern void       job_P_Btree_First(            void );
extern void       job_P_Btree_Next(             void );
extern void       job_P_Clamp(                  void );
extern void       job_P_Copy_Btree(             void );
extern void       job_P_Call(                   void );
extern void       job_P_Callable_P(             void );
extern void       job_P_Caseless_Eq(            void );
extern void       job_P_Caseless_Find_Last_Substring_P( void );
extern void       job_P_Caseless_Find_Substring_P(      void );
extern void       job_P_Caseless_Find_Next_Substring_P( void );
extern void       job_P_Caseless_Find_Previous_Substring_P( void );
extern void       job_P_Caseless_Ge(            void );
extern void       job_P_Caseless_Gt(            void );
extern void       job_P_Caseless_Le(            void );
extern void       job_P_Caseless_Lt(            void );
extern void       job_P_Caseless_Ne(            void );
extern void       job_P_Caseless_Substring_P(   void );
extern void       job_P_Char_P(                 void );
extern void       job_P_Char_Position_In_Block( void );
extern void       job_P_Char_To_Int(            void );
extern void       job_P_Char_To_Int_Block(      void );
extern void       job_P_Char_To_String(         void );
extern void       job_P_Chars2_To_Int(          void );
extern void       job_P_Chars4_To_Int(          void );
extern void       job_P_Int_To_Dbname(          void );
extern void       job_P_Ints3_To_Dbref(         void );
extern void       job_P_Dbref_To_Ints3(         void );
extern void       job_P_Dbname_To_Int(          void );
extern void       job_P_Class(                  void );
extern void       job_P_Mos_Class_P(		void );
extern void       job_P_Mos_Key_P(		void );
extern void       job_P_Mos_Key_Unshared_Slots_Match_P(void );
extern void       job_P_Mos_Object_P(		void );
extern void       job_P_Mos_Key_Parents_Block( 	void );
extern void       job_P_Mos_Key_Precedence_List_Block( void );
extern void       job_P_Link_Mos_Key_To_Ancestor( void );
extern void       job_P_Unlink_Mos_Key_From_Ancestor( void );
extern void       job_P_Nearly_Equal(		void );
extern void       job_P_Next_Mos_Key_Link(	void );
extern void       job_P_Copy(                   void );
extern void       job_P_Copy_Job(               void );
extern void       job_P_Copy_Job_Set(           void );
extern void       job_P_Copy_Cfn(               void );
extern void       job_P_Copy_Mos_Key_Slot(      void );
extern void       job_P_Copy_Session(           void );
extern void       job_P_Copy_Structure(		void );
extern void       job_P_Copy_Structure_Contents(void );
extern void       job_P_CommaLs(                void );
extern void       job_P_CommaLsa(               void );
extern void       job_P_Compiled_Function_Bytecodes(   void );
extern void       job_P_Compiled_Function_Constants(   void );
extern void       job_P_Compiled_Function_Disassembly( void );
extern void       job_P_Compiled_Function_P(    void );
extern void       job_P_Cons(                   void );
extern void       job_P_Cons_P(                 void );
extern void       job_P_Continue_Muf_Compile(   void );
extern void       job_P_Controlp(               void );
extern void       job_P_Control_Char_P(         void );
extern void       job_P_Cross_Product(          void );
extern void       job_P_Current_Compiled_Function( void );
extern void       job_P_Data_Stack_P(           void );
extern void       job_P_Debyte(                 void );
extern void       job_P_Debyte_Muqnet_Header(   void );
extern void       job_P_Delete(                 void );
extern void       job_P_Delete_Bth(             void );
extern void       job_P_Delete_Nth(             void );
extern void       job_P_Depth(                  void );
extern void       job_P_Distance(               void );
extern void       job_P_Div(                    void );
extern void       job_P_Do_C_Backslashes(	void );
extern void       job_P_Dot_Product(            void );
extern void       job_P_Downcase(               void );
extern void       job_P_Downcase_Block(         void );
extern void       job_P_Drop_Single_Quotes(     void );
extern void       job_P_Dup_Arg_Block(          void );
extern void       job_P_Dup_Args_Into_Block(    void );
extern void       job_P_Dup_Block(              void );
extern void       job_P_Dup_Bth(                void );
extern void       job_P_Dup_First_Arg_Block(    void );
extern void       job_P_Dup_Nth(                void );
extern void       job_P_Dup_Nth_Arg_Block(      void );
extern void       job_P_Enbyte(                 void );
extern void       job_P_End_P(                  void );
extern void       job_P_Ephemeral_Cons(         void );
extern void       job_P_Error_If_Ephemeral(     void );
extern void       job_P_Pop_Nth_From_Block(     void );
extern void       job_P_Pop_Nth_And_Block(      void );
extern void       job_P_Push_Block(    		void );
extern void       job_P_Push_Nth_Into_Block(    void );
extern void       job_P_Position_In_Block(      void );
extern void       job_P_Position_In_Stack_P(    void );
extern void       job_P_Secure_Hash(		void );
extern void       job_P_Secure_Hash_Binary(	void );
extern void       job_P_Secure_Hash_Block(	void );
extern void       job_P_Secure_Digest_Block(	void );
extern void       job_P_Secure_Digest_Check_Block(void );
extern void       job_P_Secure_Hash_Fixnum(	void );
extern void       job_P_Set_Bth(                void );
extern void       job_P_Set_Local_Vars(         void );
extern void       job_P_Set_Nth(                void );
extern void       job_P_Set_Nth_In_Block(       void );
extern void       job_P_Signed_Digest_Block(	void );
extern void       job_P_Signed_Digest_Check_Block(void);
extern void       job_P_Stack_To_Block(         void );
extern void       job_P_Digit_Char_P(           void );
extern void       job_P_Hash_P(			void );
extern void       job_P_Index_P(		void );
extern void       job_P_Plain_P(		void );
extern void       job_P_Double_Block(           void );
extern void       job_P_Drop_Keys_Block(        void );
extern void       job_P_Drop_Vals_Block(        void );
extern void       job_P_Egcd(                   void );
extern void       job_P_Empty_P(                void );
extern void       job_P_End_Block(              void );
extern void       job_P_End_Job(                void );
extern void	  job_P_Ephemeral_P(		void );
extern void       job_P_Exec(                   void );
extern void       job_P_Expand_C_String_Escapes(void );
extern void       job_P_Explode_Bounded_String_Line( void );
extern void       job_P_Explode_Number(         void );
extern void       job_P_Explode_Symbol(         void );
extern void       job_P_Fbm(			void );
extern void       job_P_Find_Mos_Key_Class_Method( void );
extern void       job_P_Find_Mos_Key_Object_Method( void );
extern void       job_P_Find_Last_Substring_P(  void );
#ifdef OLD
extern void       job_P_Find_Method(            void );
extern void       job_P_Find_Method_P(          void );
#endif
extern void       job_P_Find_Substring_P(       void );
extern void       job_P_Find_Symbol_P(          void );
extern void       job_P_Find_Next_Substring_P(  void );
extern void       job_P_Find_Previous_Substring_P( void );
extern void       job_P_Find_Mos_Key_Slot(	void );
extern void       job_P_Finish_Assembly(        void );
extern void       job_P_Finish_Promise_Assembly(void );
extern void       job_P_Finish_Thunk_Assembly(  void );
extern void       job_P_Fixnum_P(               void );
extern void       job_P_Float_P(                void );
extern void       job_P_Flush(                  void );
extern void       job_P_Flush_Stream(           void );
extern void       job_P_Function_P(             void );
extern void       job_P_Gain(                   void );
extern void       job_P_Gammacorrect(           void );
extern void       job_P_Gcd(                    void );
extern void       job_P_Ged_Val_Block(          void );
extern void       job_P_Gep_Val_Block(          void );
extern void       job_P_Get_All_Active_Handlers(void );
extern void       job_P_Insert_Mos_Key_Class_Method( void );
extern void       job_P_Insert_Mos_Key_Object_Method( void );
extern void       job_P_Delete_Mos_Key_Class_Method( void );
extern void       job_P_Delete_Mos_Key_Object_Method( void );
extern void       job_P_Generate_Diffie_Hellman_Key_Pair(   void );
extern void       job_P_Generate_Diffie_Hellman_Shared_Secret(   void );
extern void       job_P_Get_Mos_Key_Ancestor(   void );
extern void       job_P_Get_Mos_Key_Ancestor_P( void );
extern void       job_P_Get_Mos_Key_Class_Method( void );
extern void       job_P_Get_Mos_Key_Initarg(  void );
extern void       job_P_Get_Mos_Key_Metharg(  void );
extern void       job_P_Get_Mos_Key_Slotarg(  void );
extern void       job_P_Get_Mos_Key_Object_Method( void );
extern void       job_P_Get_Mos_Key_Parent(   void );
extern void       job_P_Get_Mos_Key_Slot_Property(void );
extern void       job_P_Get_Here(               void );
extern void       job_P_Get_Lambda_Slot_Property( void );
extern void       job_P_Get_Macro_Character(    void );
extern void       job_P_Get_Method_Slot(	void );
extern void       job_P_Get_Mos_Key(            void );
extern void       job_P_Get_Muqnet_Io(          void );
extern void       job_P_Get_Nth_Restart(        void );
extern void       job_P_Get_Restart(            void );
extern void       job_P_Get_Private_Val(        void );
extern void       job_P_Get_Private_Val_P(      void );
extern void       job_P_Get_Substring(          void );
extern void       job_P_Get_System_Val(         void );
extern void       job_P_Get_System_Val_P(       void );
extern void       job_P_Get_Admins_Val(         void );
extern void       job_P_Get_Admins_Val_P(       void );
extern void       job_P_Get_Socket_Char_Event(  void);
extern void       job_P_Get_Val_Block(		void );
extern void       job_P_Get_Nth_Structure_Slot(	void );
extern void       job_P_Get_Named_Structure_Slot(void );
extern void       job_P_Gnoise(                 void );
extern void       job_P_Graphic_Char_P(         void );
extern void       job_P_Hash(                   void );
extern void       job_P_Hex_Digit_Char_P(       void );
extern void       job_P_Int_To_Char(            void );
extern void       job_P_Int_To_Chars2(          void );
extern void       job_P_Int_To_Chars4(          void );
extern void       job_P_Int_To_Char_Block(      void );
extern void       job_P_Integer_P(              void );
extern void	  job_P_Is_An_Array(		void );
extern void	  job_P_Is_An_Assembler(	void );
extern void	  job_P_Is_Callable(		void );
extern void	  job_P_Is_A_Char(		void );
extern void	  job_P_Is_A_Mos_Class(		void );
extern void	  job_P_Is_A_Mos_Key(		void );
extern void	  job_P_Is_A_Mos_Object(	void );
extern void	  job_P_Is_A_Compiled_Function(	void );
extern void	  job_P_Is_A_Cons(		void );
extern void	  job_P_Is_A_Constant(		void );
extern void	  job_P_Is_A_Data_Stack(	void );
extern void	  job_P_Is_A_Float(		void );
extern void	  job_P_Is_A_Function(		void );
extern void	  job_P_Is_A_Hash(		void );
extern void	  job_P_Is_An_Index(		void );
extern void	  job_P_Is_An_Integer(		void );
extern void	  job_P_Is_A_Job(		void );
extern void	  job_P_Is_A_Job_Queue(		void );
extern void	  job_P_Is_A_Job_Set(		void );
extern void	  job_P_Is_A_Keyword(		void );
extern void	  job_P_Is_A_Lambda_List(	void );
extern void	  job_P_Is_A_List(		void );
extern void	  job_P_Is_A_Lock(		void );
extern void	  job_P_Is_A_Loop_Stack(	void );
extern void	  job_P_Is_A_Method(		void );
extern void	  job_P_Is_A_Number(		void );
extern void	  job_P_Is_A_Package(		void );
extern void	  job_P_Is_A_Plain(		void );
extern void	  job_P_Is_A_Message_Stream(	void );
extern void	  job_P_Is_A_Session(		void );
extern void	  job_P_Is_A_Set(		void );
extern void	  job_P_Is_A_Socket(		void );
extern void	  job_P_Is_A_Stream(		void );
extern void       job_P_Is_A_Structure(		void );
extern void	  job_P_Is_A_Stack(		void );
extern void	  job_P_Is_A_String(		void );
extern void	  job_P_Is_A_Symbol(		void );
extern void	  job_P_Is_A_Table(		void );
extern void	  job_P_Is_A_User(		void );
extern void	  job_P_Is_A_Vector(		void );
extern void	  job_P_Is_A_Vector_I01(	void );
extern void	  job_P_Is_A_Vector_I08(	void );
extern void	  job_P_Is_A_Vector_I16(	void );
extern void	  job_P_Is_A_Vector_I32(	void );
extern void	  job_P_Is_A_Vector_F32(	void );
extern void	  job_P_Is_A_Vector_F64(	void );
extern void	  job_P_Is_Ephemeral(		void );
extern void       job_P_Is_This_Mos_Class(	void );
extern void       job_P_Is_This_Structure(	void );
extern void       job_P_Job(                    void );
extern void       job_P_Job_P(                  void );
extern void       job_P_Job_Is_Alive_P(         void );
extern void       job_P_Join_Block(             void );
extern void       job_P_Join_Blocks(            void );
extern void       job_P_Keyword_P(              void );
extern void       job_P_Kitchen_Sinks(          void );
extern void	  job_P_Lambda_List_P(		void );
extern void       job_P_Lbrk_P(                 void );
extern void       job_P_Lcm(                    void );
extern void       job_P_Length2(                void );
extern void       job_P_List_P(                 void );
extern void       job_P_Lock_P(                 void );
extern void	  job_P_Magnitude(		void );
extern void	  job_P_Method_P(		void );
extern void	  job_P_Methods_Match_P(	void );
extern void	  job_P_Mix(			void );
extern void       job_P_Mod(                    void );
extern void	  job_P_Nonce_11000A(		void );
extern void	  job_P_Nonce_00100A(		void );
extern void	  job_P_Nonce_00110A(		void );
extern void	  job_P_Nonce_00010A(		void );
extern void	  job_P_Normalize(		void );
extern void       job_P_Not_Bits(               void );
extern void       job_P_Omnipotent_P(           void );
extern void       job_P_Ray_Hits_Sphere_At(     void );
extern void       job_P_Ray_Hits_Spheres_At(    void );
extern void       job_P_Root_P(                 void );
extern void       job_P_Root_Write_Stream(      void );
extern void       job_P_Root_Change_Owner(	void );
extern void       job_P_Root_All_Active_Sockets(void );
extern void       job_P_Close_Socket(		void );
extern void       job_P_Open_Socket(		void );
extern void       job_P_Root_Popen_Socket(	void );
extern void       job_P_Listen_On_Socket(	void );
extern void       job_P_Root_Log_Print(         void );
extern void       job_P_Root_Log_String(        void );
extern void       job_P_Loop_Stack_P(           void );
extern void       job_P_Lower_Case_P(           void );
extern void       job_P_Make_Assembler(         void );
extern void       job_P_Make_Bignum(            void );
extern void       job_P_Exptmod(                void );

extern void       job_P_Make_Array(             void );
extern void       job_P_Make_Hashed_Btree(      void );
extern void       job_P_Make_Sorted_Btree(      void );
extern void       job_P_Make_Mos_Class(         void );
extern void       job_P_Make_Mos_Key(           void );
extern void       job_P_Make_Ephemeral_List(    void );
extern void       job_P_Make_Ephemeral_Vector(  void );
extern void       job_P_Make_Ephemeral_Vector_From_Block( void );
extern void       job_P_Make_Fn(                void );
extern void       job_P_Make_Vector_From_Block( void );
extern void       job_P_Make_Vector_I01_From_Block( void );
extern void       job_P_Make_Vector_I08_From_Block( void );
extern void       job_P_Make_Vector_I16_From_Block( void );
extern void       job_P_Make_Vector_I32_From_Block( void );
extern void       job_P_Make_Vector_F32_From_Block( void );
extern void       job_P_Make_Vector_F64_From_Block( void );
extern void       job_P_Make_From_KeysvalsBlock(void );
extern void       job_P_Make_Hash(              void );
extern void       job_P_Make_Index(             void );
extern void       job_P_Make_Index3D(           void );
extern void       job_P_Make_Job_Queue(         void );
extern void       job_P_Make_Lambda_List(       void );
extern void       job_P_Make_Lock(              void );
extern void       job_P_Make_Method(            void );
extern void       job_P_Make_Muf(               void );
extern void       job_P_Make_Number(            void );
extern void       job_P_Make_Package(           void );
extern void       job_P_Make_Plain(             void );
extern void       job_P_Make_Message_Stream(    void );
extern void       job_P_Make_Set(               void );
extern void       job_P_Make_Stream(            void );
extern void       job_P_Make_Stack(             void );
extern void       job_P_Make_String(            void );
extern void       job_P_Make_Table(             void );
extern void       job_P_Make_Vector(            void );
extern void       job_P_Make_Vector_I01(        void );
extern void       job_P_Make_Vector_I08(        void );
extern void       job_P_Make_Vector_I16(        void );
extern void       job_P_Make_Vector_I32(        void );
extern void       job_P_Make_Vector_F32(        void );
extern void       job_P_Make_Vector_F64(        void );
extern void       job_P_Make_Structure(		void );
extern void       job_P_Make_Symbol(            void );
extern void       job_P_Make_Symbol_Block(      void );
extern void       job_P_Muc_Token_Value_In_String(void );
extern void       job_P_Next_Muc_Token_In_String(void );
extern void       job_P_Number_P(               void );
extern void       job_P_Or_Bits(                void );
extern void       job_P_Over(                   void );
extern void       job_P_Package_P(              void );
extern void       job_P_Message_Stream_P(       void );
extern void       job_P_Mult(                   void );
extern void       job_P_Neg(                    void );
extern void       job_P_Plus(                   void );
extern void       job_P_Shift_Bits(             void );
extern void       job_P_Smoothstep(             void );
extern void       job_P_Spline(                 void );
extern void       job_P_Step(                   void );
extern void       job_P_Sub(                    void );
extern void       job_P_Pop_Block(              void );
extern void       job_P_Pop_Catchframe(         void );
extern void       job_P_Pop_From_Block(         void );
extern void       job_P_Pop_Ephemeral_List(     void );
extern void       job_P_Pop_Ephemeral_Struct(   void );
extern void       job_P_Pop_Ephemeral_Vector(   void );
extern void       job_P_Pop_Fun_Binding(        void );
extern void       job_P_Pop_Handlersframe(      void );
extern void       job_P_Pop_User_Frame(         void );
extern void       job_P_Pop_Lockframe(          void );
extern void       job_P_Pop_Privs_Frame(        void );
extern void       job_P_Pop_Restartframe(       void );
extern void       job_P_Pop_Tagframe(           void );
extern void       job_P_Pop_Tagtopframe(        void );
extern void       job_P_Pop_Unwindframe(        void );
extern void       job_P_Pop_Var_Binding(        void );
extern void       job_P_Popp_From_Block(        void );
extern void       job_P_Potential_Number_P(	void );
extern void       job_P_Print(                  void );
extern void       job_P_Print1(                 void );
extern void       job_P_Print1_Data_Stack(      void );
extern void       job_P_Print_String(           void );
extern void       job_P_Print_Time(		void );
extern void       job_P_Program_Counter_To_Line_Number(	void );
extern void       job_P_Proxy_Info(		void );
extern void       job_P_Pull(                   void );
extern void       job_P_Punctuation_P(          void );
extern void       job_P_Push(                   void );
extern void       job_P_Push_Fun_Binding(       void );
extern void       job_P_Push_Into_Block(        void );
extern void       job_P_Push_User_Me_Frame(     void );
extern void       job_P_Push_Var_Binding(       void );
extern void       job_P_Remote_P(               void );
extern void       job_P_Root_Push_User_Frame(   void );
extern void       job_P_Root_Push_Privs_Omnipotent_Frame(  void );
extern void       job_P_Push_Handlersframe(     void );
extern void       job_P_Push_Lockframe(         void );
extern void       job_P_Push_Lockframe_Child(   void );
extern void       job_P_Push_Restartframe(      void );
extern void       job_P_Push_Tagtopframe(       void );
extern void       job_P_Queue_Job(              void );
extern void       job_P_Random(                 void );

extern void       job_P_Unread_Token_Char(      void );
extern void       job_P_Read_Token_Char(        void );
extern void       job_P_Read_Token_Chars(       void );
extern void       job_P_Scan_Token_To_Char(     void );
extern void       job_P_Scan_Token_To_Chars(    void );
extern void       job_P_Scan_Token_To_Char_Pair(void );
extern void       job_P_Scan_Token_To_Whitespace(void );
extern void       job_P_Scan_Token_To_Nonwhitespace(void );
extern void       job_P_Scan_Lisp_String_Token( void );
extern void       job_P_Scan_Lisp_Token(        void );
extern void       job_P_Swap_Blocks(            void );
extern void       job_P_Classify_Lisp_Token(    void );

extern void       job_P_Read_Any_Stream_Packet( void );
/*extern void       job_P_Read_Lisp_Chars(        void );*/
/*extern void       job_P_Read_Lisp_Comment(      void );*/
extern void       job_P_Read_Lisp_String(       void );
extern void       job_P_Read_Byte(              void );
extern void       job_P_Read_Char(              void );
extern void       job_P_Read_Value(             void );
extern void       job_P_Read_Line(              void );
extern void       job_P_Read_Next_Muf_Token(    void );
extern void       job_P_Read_Stream(            void );
extern void       job_P_Read_Stream_Byte(       void );
extern void       job_P_Read_Stream_Char(       void );
extern void       job_P_Read_Stream_Value(      void );
extern void       job_P_Read_Stream_Packet(     void );
extern void       job_P_Replace_Substrings(     void );
extern void       job_P_Reset(                  void );
extern void       job_P_Return(                 void );
extern void       job_P_Reverse_Block(          void );
extern void       job_P_Reverse_Keysvals_Block( void );
extern void       job_P_Rex_Begin(		void );
extern void       job_P_Rex_Close_Paren(	void );
extern void       job_P_Rex_Done_P(		void );
extern void       job_P_Rex_End(		void );
extern void       job_P_Rex_Get_Cursor(		void );
extern void       job_P_Rex_Match_Char_Class(	void );
extern void       job_P_Rex_Match_Dot(		void );
extern void       job_P_Rex_Match_String(	void );
extern void       job_P_Rex_Match_Wordboundary(	void );
extern void       job_P_Rex_Match_Wordchar(	void );
extern void       job_P_Rex_Match_Whitespace(	void );
extern void       job_P_Rex_Match_Digit(	void );
extern void       job_P_Rex_Match_Nonwordboundary(void );
extern void       job_P_Rex_Match_Nonwordchar(	void );
extern void       job_P_Rex_Match_Nonwhitespace(void );
extern void       job_P_Rex_Match_Nondigit(	void );
extern void       job_P_Rex_Match_Previous_Match(void );
extern void       job_P_Rex_Cancel_Paren(	void );
extern void       job_P_Rex_Get_Paren(		void );
extern void       job_P_Rex_Open_Paren(		void );
extern void       job_P_Rex_Set_Cursor(		void );
extern void       job_P_Root(                   void );
extern void       job_P_Root_Collect_Garbage(   void );
extern void       job_P_Root_Do_Backup(		void );
extern void       job_P_Rot(                    void );
extern void       job_P_Rotate_Block(           void );
extern void       job_P_Rplaca(                 void );
extern void       job_P_Rplacd(                 void );
extern void       job_P_Select_Message_Streams( void );
extern void       job_P_Self(                   void );
extern void       job_P_Seq_Block(              void );
extern void       job_P_Set_Mos_Key_Ancestor( void );
extern void       job_P_Set_Mos_Key_Class_Method( void );
extern void       job_P_Set_Mos_Key_Initarg(  void );
extern void       job_P_Set_Mos_Key_Metharg(  void );
extern void       job_P_Set_Mos_Key_Slotarg(  void );
extern void       job_P_Set_Mos_Key_Object_Method( void );
extern void       job_P_Set_Mos_Key_Parent(   void );
extern void       job_P_Set_Mos_Key_Slot_Property( void );
extern void       job_P_Set_Here(               void );
extern void       job_P_Set_Lambda_Slot_Property( void );
extern void       job_P_Set_Macro_Character(    void );
extern void       job_P_Set_Method_Slot(	void );
extern void       job_P_Set_Muf_Line_Number(    void );
extern void       job_P_Set_Private_Val(        void );
extern void       job_P_Set_System_Val(         void );
extern void       job_P_Set_Admins_Val(         void );
extern void       job_P_Set_Val_Block(          void );
extern void       job_P_Set_Socket_Char_Event(  void );
extern void       job_P_Set_Nth_Structure_Slot(	void );
extern void       job_P_Set_Named_Structure_Slot(void );
extern void       job_P_Set_P(                  void );
extern void       job_P_Shift_And_Pop(          void );
extern void       job_P_Shift_2_And_Pop(        void );
extern void       job_P_Shift_3_And_Pop(        void );
extern void       job_P_Shift_4_And_Pop(        void );
extern void       job_P_Shift_5_And_Pop(        void );
extern void       job_P_Shift_6_And_Pop(        void );
extern void       job_P_Shift_7_And_Pop(        void );
extern void       job_P_Shift_8_And_Pop(        void );
extern void       job_P_Shift_9_And_Pop(        void );
extern void       job_P_Shift_From_Block(       void );
extern void       job_P_Shiftp_From_Block(      void );
extern void       job_P_Shiftp_N_From_Block(    void );
extern void       job_P_Signal(                 void );
extern void       job_P_Sleep_Job(              void );
extern void       job_P_Sort_Block(             void );
extern void       job_P_Sort_Keysvals_Block(    void );
extern void       job_P_Sort_Pairs_Block(       void );
extern void       job_P_Stack_P(                void );
extern void       job_P_Start_Muf_Compile(      void );
extern void       job_P_Start_Block(            void );
extern void       job_P_Stream_P(               void );
extern void       job_P_Streq_Block(            void );
extern void       job_P_String_P(               void );
extern void       job_P_String_To_Keyword(      void );
extern void       job_P_String_To_Chars(        void );
extern void       job_P_String_To_Int(          void );
extern void       job_P_String_To_Ints(         void );
extern void       job_P_Structure_P(		void );
extern void       job_P_Switch_Job(             void );
extern void       job_P_Table_P(		void );
extern void       job_P_This_Mos_Class_P(	void );
extern void       job_P_This_Structure_P(	void );
extern void       job_P_Tr_Block(		void );
extern void       job_P_Truly_Random_Fixnum(	void );
extern void       job_P_Truly_Random_Integer(	void );
extern void       job_P_Tsort_Block(            void );
extern void       job_P_Tsort_Mos_Block(	void );
extern void       job_P_Turbulence(		void );
extern void       job_P_Unbind_Symbol(          void );
extern void       job_P_Unpull(                 void );
extern void       job_P_Unpush(                 void );
extern void       job_P_Unshift_Into_Block(     void );
extern void       job_P_Unread_Char(            void );
extern void       job_P_Unread_Stream_Char(     void );
extern void       job_P_Unsort_Block(           void );
extern void       job_P_Upcase(                 void );
extern void       job_P_Upcase_Block(           void );

extern void	  job_P_Block_In_Package(	void );
extern void	  job_P_Block_Make_Package(	void );
extern void	  job_P_Block_Make_Proxy(	void );
extern void	  job_P_Block_Rename_Package(	void );
extern void	  job_P_Delete_Package(		void );
extern void	  job_P_Export(			void );
extern void	  job_P_Find_Package(		void );
extern void	  job_P_Import(			void );
extern void	  job_P_In_Package(		void );
extern void       job_P_Intern(			void );
extern void       job_P_Unexport(		void );
extern void       job_P_Unintern(		void );
extern void       job_P_Unuse_Package(		void );
extern void       job_P_Use_Package(		void );

extern void 	  job_P_Reserved_00(		void );
extern void 	  job_P_Reserved_01(		void );
extern void 	  job_P_Reserved_02(		void );
extern void 	  job_P_Reserved_03(		void );
extern void 	  job_P_Reserved_04(		void );
extern void 	  job_P_Reserved_05(		void );
extern void 	  job_P_Reserved_06(		void );
extern void 	  job_P_Reserved_07(		void );
extern void 	  job_P_Reserved_08(		void );
extern void 	  job_P_Reserved_09(		void );

extern void 	  job_P_Reserved_10(		void );
extern void 	  job_P_Reserved_11(		void );
extern void 	  job_P_Reserved_12(		void );
extern void 	  job_P_Reserved_13(		void );
extern void 	  job_P_Reserved_14(		void );
extern void 	  job_P_Reserved_15(		void );
extern void 	  job_P_Reserved_16(		void );
extern void 	  job_P_Reserved_17(		void );
extern void 	  job_P_Reserved_18(		void );
extern void 	  job_P_Reserved_19(		void );

extern void 	  job_P_Reserved_20(		void );
extern void 	  job_P_Reserved_21(		void );
extern void 	  job_P_Reserved_22(		void );
extern void 	  job_P_Reserved_23(		void );
extern void 	  job_P_Reserved_24(		void );
extern void 	  job_P_Reserved_25(		void );
extern void 	  job_P_Reserved_26(		void );
extern void 	  job_P_Reserved_27(		void );
extern void 	  job_P_Reserved_28(		void );
extern void 	  job_P_Reserved_29(		void );

extern void 	  job_P_Reserved_30(		void );
extern void 	  job_P_Reserved_31(		void );
extern void 	  job_P_Reserved_32(		void );
extern void 	  job_P_Reserved_33(		void );
extern void 	  job_P_Reserved_34(		void );
extern void 	  job_P_Reserved_35(		void );
extern void 	  job_P_Reserved_36(		void );
extern void 	  job_P_Reserved_37(		void );
extern void 	  job_P_Reserved_38(		void );
extern void 	  job_P_Reserved_39(		void );

extern void 	  job_P_Reserved_40(		void );
extern void 	  job_P_Reserved_41(		void );
extern void 	  job_P_Reserved_42(		void );
extern void 	  job_P_Reserved_43(		void );
extern void 	  job_P_Reserved_44(		void );
extern void 	  job_P_Reserved_45(		void );
extern void 	  job_P_Reserved_46(		void );
extern void 	  job_P_Reserved_47(		void );
extern void 	  job_P_Reserved_48(		void );
extern void 	  job_P_Reserved_49(		void );

extern void 	  job_P_Reserved_50(		void );
extern void 	  job_P_Reserved_51(		void );
extern void 	  job_P_Reserved_52(		void );
extern void 	  job_P_Reserved_53(		void );
extern void 	  job_P_Reserved_54(		void );
extern void 	  job_P_Reserved_55(		void );
extern void 	  job_P_Reserved_56(		void );
extern void 	  job_P_Reserved_57(		void );
extern void 	  job_P_Reserved_58(		void );
extern void 	  job_P_Reserved_59(		void );

extern void 	  job_P_Reserved_60(		void );
extern void 	  job_P_Reserved_61(		void );


extern void       job_P_Glut_Init_Display_Mode( void );
extern void       job_P_Glut_Create_Window(     void );
extern void       job_P_Gl_Clear(               void );
extern void       job_P_Glut_Swap_Buffers(      void );
extern void       job_P_Gl_Enable(              void );
extern void       job_P_Gl_Matrix_Mode(         void );

extern void       job_P_Glu_Perspective(        void );
extern void       job_P_Glu_Lookat(             void );

extern void	  job_P_Glu_Ortho2D(		void	);
extern void	  job_P_Glu_Pick_Matrix(	void	);
extern void	  job_P_Glu_Project(		void	);
extern void	  job_P_Glu_Un_Project(		void	);
extern void	  job_P_Glu_Error_String(	void	);
extern void	  job_P_Glu_Scale_Image(	void	);
extern void	  job_P_Glu_Build1D_Mipmaps(	void	);
extern void	  job_P_Glu_Build2D_Mipmaps(	void	);
extern void	  job_P_Glu_New_Quadric(	void	);
extern void	  job_P_Glu_Delete_Quadric(	void	);
extern void	  job_P_Glu_Quadric_Draw_Style(	void	);
extern void	  job_P_Glu_Quadric_Orientation(void	);
extern void	  job_P_Glu_Quadric_Normals(	void	);
extern void	  job_P_Glu_Quadric_Texture(	void	);
extern void	  job_P_Glu_Quadric_Callback(	void	);
extern void	  job_P_Glu_Cylinder(		void	);
extern void	  job_P_Glu_Sphere(		void	);
extern void	  job_P_Glu_Disk(		void	);
extern void	  job_P_Glu_Partial_Disk(	void	);
extern void	  job_P_Glu_New_Nurbs_Renderer(	void	);
extern void	  job_P_Glu_Delete_Nurbs_Renderer(void	);
extern void	  job_P_Glu_Load_Sampling_Matrices(void	);
extern void	  job_P_Glu_Nurbs_Property(	void	);
extern void	  job_P_Glu_Get_Nurbs_Property(	void	);
extern void	  job_P_Glu_Begin_Curve(	void	);
extern void	  job_P_Glu_End_Curve(		void	);
extern void	  job_P_Glu_Nurbs_Curve(	void	);
extern void	  job_P_Glu_Begin_Surface(	void	);
extern void	  job_P_Glu_End_Surface(	void	);
extern void	  job_P_Glu_Nurbs_Surface(	void	);
extern void	  job_P_Glu_Begin_Trim(		void	);
extern void	  job_P_Glu_End_Trim(		void	);
extern void	  job_P_Glu_Pwl_Curve(		void	);
extern void	  job_P_Glu_Nurbs_Callback(	void	);
extern void	  job_P_Glu_New_Tess(		void	);
extern void	  job_P_Glu_Tess_Callback(	void	);
extern void	  job_P_Glu_Delete_Tess(	void	);
extern void	  job_P_Glu_Begin_Polygon(	void	);
extern void	  job_P_Glu_End_Polygon(	void	);
extern void	  job_P_Glu_Next_Contour(	void	);
extern void	  job_P_Glu_Tess_Vertex(	void	);
extern void	  job_P_Glu_Get_String(		void	);

extern void	  job_P_Gl_Clear_Index(	void );
extern void	  job_P_Gl_Clear_Color(	void );
extern void	  job_P_Gl_Clear(	void );
extern void	  job_P_Gl_Index_Mask(	void );
extern void	  job_P_Gl_Color_Mask(	void );
extern void	  job_P_Gl_Alpha_Func(	void );
extern void	  job_P_Gl_Blend_Func(	void );
extern void	  job_P_Gl_Logic_Op(	void );
extern void	  job_P_Gl_Cull_Face(	void );
extern void	  job_P_Gl_Front_Face(	void );
extern void	  job_P_Gl_Point_Size(	void );
extern void	  job_P_Gl_Line_Width(	void );
extern void	  job_P_Gl_Line_Stipple(	void );
extern void	  job_P_Gl_Polygon_Mode(	void );
extern void	  job_P_Gl_Polygon_Offset(	void );
extern void	  job_P_Gl_Polygon_Stipple(	void );
extern void	  job_P_Gl_Get_Polygon_Stipple(	void );
extern void	  job_P_Gl_Edge_Flag(	void );
extern void	  job_P_Gl_Edge_Flagv(	void );
extern void	  job_P_Gl_Scissor(	void );
extern void	  job_P_Gl_Clip_Plane(	void );
extern void	  job_P_Gl_Get_Clip_Plane(	void );
extern void	  job_P_Gl_Draw_Buffer(	void );
extern void	  job_P_Gl_Read_Buffer(	void );
extern void	  job_P_Gl_Enable(	void );
extern void	  job_P_Gl_Disable(	void );
extern void	  job_P_Gl_Is_Enabled(	void );
extern void       job_P_Gla_Disable(    void );
extern void       job_P_Gla_Enable(     void );
extern void	  job_P_Gl_Enable_Client_State(	void );
extern void	  job_P_Gl_Disable_Client_State(	void );
extern void	  job_P_Gl_Get_Boolean(		void );
extern void	  job_P_Gl_Get_Double(		void );
extern void	  job_P_Gl_Get_Float(		void );
extern void	  job_P_Gl_Get_Integer(		void );
extern void	  job_P_Gl_Get_Boolean_Block(	void );
extern void	  job_P_Gl_Get_Double_Block(	void );
extern void	  job_P_Gl_Get_Float_Block(	void );
extern void	  job_P_Gl_Get_Integer_Block(	void );
extern void	  job_P_Gl_Get_Booleanv(	void );
extern void	  job_P_Gl_Get_Doublev(		void );
extern void	  job_P_Gl_Get_Floatv(		void );
extern void	  job_P_Gl_Get_Integerv(	void );
extern void	  job_P_Gl_Push_Attrib(	void );
extern void	  job_P_Gl_Pop_Attrib(	void );
extern void	  job_P_Gl_Push_Client_Attrib(	void );
extern void	  job_P_Gl_Pop_Client_Attrib(	void );
extern void	  job_P_Gl_Render_Mode(	void );
extern void	  job_P_Gl_Get_Error(	void );
extern void	  job_P_Gl_Get_String(	void );
extern void	  job_P_Gl_Finish(	void );
extern void	  job_P_Gl_Flush(	void );
extern void	  job_P_Gl_Hint(	void );
extern void	  job_P_Gl_Clear_Depth(	void );
extern void	  job_P_Gl_Depth_Func(	void );
extern void	  job_P_Gl_Depth_Mask(	void );
extern void	  job_P_Gl_Depth_Range(	void );
extern void	  job_P_Gl_Clear_Accum(	void );
extern void	  job_P_Gl_Accum(	void );
extern void	  job_P_Gl_Matrix_Mode(	void );
extern void	  job_P_Gl_Ortho(	void );
extern void	  job_P_Gl_Frustum(	void );
extern void	  job_P_Gl_Viewport(	void );
extern void	  job_P_Gl_Push_Matrix(	void );
extern void	  job_P_Gl_Pop_Matrix(	void );
extern void	  job_P_Gl_Load_Identity(	void );
extern void	  job_P_Gl_Load_Matrixd(	void );
extern void	  job_P_Gl_Load_Matrixf(	void );
extern void	  job_P_Gl_Mult_Matrixd(	void );
extern void	  job_P_Gl_Mult_Matrixf(	void );
extern void	  job_P_Gl_Rotated(	void );
extern void	  job_P_Gl_Rotatef(	void );
extern void	  job_P_Gl_Scaled(	void );
extern void	  job_P_Gl_Scalef(	void );
extern void	  job_P_Gl_Translated(	void );
extern void	  job_P_Gl_Translatef(	void );
extern void	  job_P_Gl_Is_List(	void );
extern void	  job_P_Gl_Delete_Lists(	void );
extern void	  job_P_Gl_Gen_Lists(	void );
extern void	  job_P_Gl_New_List(	void );
extern void	  job_P_Gl_End_List(	void );
extern void	  job_P_Gl_Call_List(	void );
extern void	  job_P_Gl_Call_Lists(	void );
extern void	  job_P_Gl_List_Base(	void );
extern void	  job_P_Gl_Begin(	void );
extern void	  job_P_Gl_End(	void );
extern void	  job_P_Gl_Vertex2D(	void );
extern void	  job_P_Gl_Vertex2F(	void );
extern void	  job_P_Gl_Vertex2I(	void );
extern void	  job_P_Gl_Vertex2S(	void );
extern void	  job_P_Gl_Vertex3D(	void );
extern void	  job_P_Gl_Vertex3F(	void );
extern void	  job_P_Gl_Vertex3I(	void );
extern void	  job_P_Gl_Vertex3S(	void );
extern void	  job_P_Gl_Vertex4D(	void );
extern void	  job_P_Gl_Vertex4F(	void );
extern void	  job_P_Gl_Vertex4I(	void );
extern void	  job_P_Gl_Vertex4S(	void );
extern void	  job_P_Gl_Vertex2Dv(	void );
extern void	  job_P_Gl_Vertex2Fv(	void );
extern void	  job_P_Gl_Vertex2Iv(	void );
extern void	  job_P_Gl_Vertex2Sv(	void );
extern void	  job_P_Gl_Vertex3Dv(	void );
extern void	  job_P_Gl_Vertex3Fv(	void );
extern void	  job_P_Gl_Vertex3Iv(	void );
extern void	  job_P_Gl_Vertex3Sv(	void );
extern void	  job_P_Gl_Vertex4Dv(	void );
extern void	  job_P_Gl_Vertex4Fv(	void );
extern void	  job_P_Gl_Vertex4Iv(	void );
extern void	  job_P_Gl_Vertex4Sv(	void );
extern void	  job_P_Gl_Normal3B(	void );
extern void	  job_P_Gl_Normal3D(	void );
extern void	  job_P_Gl_Normal3F(	void );
extern void	  job_P_Gl_Normal3I(	void );
extern void	  job_P_Gl_Normal3S(	void );
extern void	  job_P_Gl_Normal3Bv(	void );
extern void	  job_P_Gl_Normal3Dv(	void );
extern void	  job_P_Gl_Normal3Fv(	void );
extern void	  job_P_Gl_Normal3Iv(	void );
extern void	  job_P_Gl_Normal3Sv(	void );
extern void	  job_P_Gl_Indexd(	void );
extern void	  job_P_Gl_Indexf(	void );
extern void	  job_P_Gl_Indexi(	void );
extern void	  job_P_Gl_Indexs(	void );
extern void	  job_P_Gl_Indexub(	void );
extern void	  job_P_Gl_Indexdv(	void );
extern void	  job_P_Gl_Indexfv(	void );
extern void	  job_P_Gl_Indexiv(	void );
extern void	  job_P_Gl_Indexsv(	void );
extern void	  job_P_Gl_Indexubv(	void );
extern void	  job_P_Gl_Color3B(	void );
extern void	  job_P_Gl_Color3D(	void );
extern void	  job_P_Gl_Color3F(	void );
extern void	  job_P_Gl_Color3I(	void );
extern void	  job_P_Gl_Color3S(	void );
extern void	  job_P_Gl_Color3Ub(	void );
extern void	  job_P_Gl_Color3Ui(	void );
extern void	  job_P_Gl_Color3Us(	void );
extern void	  job_P_Gl_Color4B(	void );
extern void	  job_P_Gl_Color4D(	void );
extern void	  job_P_Gl_Color4F(	void );
extern void	  job_P_Gl_Color4I(	void );
extern void	  job_P_Gl_Color4S(	void );
extern void	  job_P_Gl_Color4Ub(	void );
extern void	  job_P_Gl_Color4Ui(	void );
extern void	  job_P_Gl_Color4Us(	void );
extern void	  job_P_Gl_Color3Bv(	void );
extern void	  job_P_Gl_Color3Dv(	void );
extern void	  job_P_Gl_Color3Fv(	void );
extern void	  job_P_Gl_Color3Iv(	void );
extern void	  job_P_Gl_Color3Sv(	void );
extern void	  job_P_Gl_Color3Ubv(	void );
extern void	  job_P_Gl_Color3Uiv(	void );
extern void	  job_P_Gl_Color3Usv(	void );
extern void	  job_P_Gl_Color4Bv(	void );
extern void	  job_P_Gl_Color4Dv(	void );
extern void	  job_P_Gl_Color4Fv(	void );
extern void	  job_P_Gl_Color4Iv(	void );
extern void	  job_P_Gl_Color4Sv(	void );
extern void	  job_P_Gl_Color4Ubv(	void );
extern void	  job_P_Gl_Color4Uiv(	void );
extern void	  job_P_Gl_Color4Usv(	void );
extern void	  job_P_Gl_Tex_Coord1D(	void );
extern void	  job_P_Gl_Tex_Coord1F(	void );
extern void	  job_P_Gl_Tex_Coord1I(	void );
extern void	  job_P_Gl_Tex_Coord1S(	void );
extern void	  job_P_Gl_Tex_Coord2D(	void );
extern void	  job_P_Gl_Tex_Coord2F(	void );
extern void	  job_P_Gl_Tex_Coord2I(	void );
extern void	  job_P_Gl_Tex_Coord2S(	void );
extern void	  job_P_Gl_Tex_Coord3D(	void );
extern void	  job_P_Gl_Tex_Coord3F(	void );
extern void	  job_P_Gl_Tex_Coord3I(	void );
extern void	  job_P_Gl_Tex_Coord3S(	void );
extern void	  job_P_Gl_Tex_Coord4D(	void );
extern void	  job_P_Gl_Tex_Coord4F(	void );
extern void	  job_P_Gl_Tex_Coord4I(	void );
extern void	  job_P_Gl_Tex_Coord4S(	void );
extern void	  job_P_Gl_Tex_Coord1Dv(	void );
extern void	  job_P_Gl_Tex_Coord1Fv(	void );
extern void	  job_P_Gl_Tex_Coord1Iv(	void );
extern void	  job_P_Gl_Tex_Coord1Sv(	void );
extern void	  job_P_Gl_Tex_Coord2Dv(	void );
extern void	  job_P_Gl_Tex_Coord2Fv(	void );
extern void	  job_P_Gl_Tex_Coord2Iv(	void );
extern void	  job_P_Gl_Tex_Coord2Sv(	void );
extern void	  job_P_Gl_Tex_Coord3Dv(	void );
extern void	  job_P_Gl_Tex_Coord3Fv(	void );
extern void	  job_P_Gl_Tex_Coord3Iv(	void );
extern void	  job_P_Gl_Tex_Coord3Sv(	void );
extern void	  job_P_Gl_Tex_Coord4Dv(	void );
extern void	  job_P_Gl_Tex_Coord4Fv(	void );
extern void	  job_P_Gl_Tex_Coord4Iv(	void );
extern void	  job_P_Gl_Tex_Coord4Sv(	void );
extern void	  job_P_Gl_Raster_Pos2D(	void );
extern void	  job_P_Gl_Raster_Pos2F(	void );
extern void	  job_P_Gl_Raster_Pos2I(	void );
extern void	  job_P_Gl_Raster_Pos2S(	void );
extern void	  job_P_Gl_Raster_Pos3D(	void );
extern void	  job_P_Gl_Raster_Pos3F(	void );
extern void	  job_P_Gl_Raster_Pos3I(	void );
extern void	  job_P_Gl_Raster_Pos3S(	void );
extern void	  job_P_Gl_Raster_Pos4D(	void );
extern void	  job_P_Gl_Raster_Pos4F(	void );
extern void	  job_P_Gl_Raster_Pos4I(	void );
extern void	  job_P_Gl_Raster_Pos4S(	void );
extern void	  job_P_Gl_Raster_Pos2Dv(	void );
extern void	  job_P_Gl_Raster_Pos2Fv(	void );
extern void	  job_P_Gl_Raster_Pos2Iv(	void );
extern void	  job_P_Gl_Raster_Pos2Sv(	void );
extern void	  job_P_Gl_Raster_Pos3Dv(	void );
extern void	  job_P_Gl_Raster_Pos3Fv(	void );
extern void	  job_P_Gl_Raster_Pos3Iv(	void );
extern void	  job_P_Gl_Raster_Pos3Sv(	void );
extern void	  job_P_Gl_Raster_Pos4Dv(	void );
extern void	  job_P_Gl_Raster_Pos4Fv(	void );
extern void	  job_P_Gl_Raster_Pos4Iv(	void );
extern void	  job_P_Gl_Raster_Pos4Sv(	void );
extern void	  job_P_Gl_Rectd(	void );
extern void	  job_P_Gl_Rectf(	void );
extern void	  job_P_Gl_Recti(	void );
extern void	  job_P_Gl_Rects(	void );
extern void	  job_P_Gl_Rectdv(	void );
extern void	  job_P_Gl_Rectfv(	void );
extern void	  job_P_Gl_Rectiv(	void );
extern void	  job_P_Gl_Rectsv(	void );
extern void	  job_P_Gl_Vertex_Pointer(	void );
extern void	  job_P_Gl_Normal_Pointer(	void );
extern void	  job_P_Gl_Color_Pointer(	void );
extern void	  job_P_Gl_Index_Pointer(	void );
extern void	  job_P_Gl_Tex_Coord_Pointer(	void );
extern void	  job_P_Gl_Edge_Flag_Pointer(	void );
extern void	  job_P_Gl_Get_Pointerv(	void );
extern void	  job_P_Gl_Array_Element(	void );
extern void	  job_P_Gl_Draw_Arrays(	void );
extern void	  job_P_Gl_Draw_Elements(	void );
extern void	  job_P_Gl_Interleaved_Arrays(	void );
extern void	  job_P_Gl_Shade_Model(	void );
extern void	  job_P_Gl_Lightf(	void );
extern void	  job_P_Gl_Lighti(	void );
extern void	  job_P_Gl_Lightfv(	void );
extern void	  job_P_Gl_Lightiv(	void );
extern void	  job_P_Gl_Get_Lightfv(	void );
extern void	  job_P_Gl_Get_Lightiv(	void );
extern void	  job_P_Gl_Light_Modelf(	void );
extern void	  job_P_Gl_Light_Modeli(	void );
extern void	  job_P_Gl_Light_Modelfv(	void );
extern void	  job_P_Gl_Light_Modeliv(	void );
extern void	  job_P_Gl_Materialf(	void );
extern void	  job_P_Gl_Materiali(	void );
extern void	  job_P_Gl_Materialfv(	void );
extern void	  job_P_Gl_Materialiv(	void );
extern void	  job_P_Gl_Get_Materialfv(	void );
extern void	  job_P_Gl_Get_Materialiv(	void );
extern void	  job_P_Gl_Color_Material(	void );
extern void	  job_P_Gl_Pixel_Zoom(	void );
extern void	  job_P_Gl_Pixel_Storef(	void );
extern void	  job_P_Gl_Pixel_Storei(	void );
extern void	  job_P_Gl_Pixel_Transferf(	void );
extern void	  job_P_Gl_Pixel_Transferi(	void );
extern void	  job_P_Gl_Pixel_Mapfv(	void );
extern void	  job_P_Gl_Pixel_Mapuiv(	void );
extern void	  job_P_Gl_Pixel_Mapusv(	void );
extern void	  job_P_Gl_Get_Pixel_Mapfv(	void );
extern void	  job_P_Gl_Get_Pixel_Mapuiv(	void );
extern void	  job_P_Gl_Get_Pixel_Mapusv(	void );
extern void	  job_P_Gl_Bitmap(	void );
extern void	  job_P_Gl_Read_Pixels(	void );
extern void	  job_P_Gl_Draw_Pixels(	void );
extern void	  job_P_Gl_Copy_Pixels(	void );
extern void	  job_P_Gl_Stencil_Func(	void );
extern void	  job_P_Gl_Stencil_Mask(	void );
extern void	  job_P_Gl_Stencil_Op(	void );
extern void	  job_P_Gl_Clear_Stencil(	void );
extern void	  job_P_Gl_Tex_Gend(	void );
extern void	  job_P_Gl_Tex_Genf(	void );
extern void	  job_P_Gl_Tex_Geni(	void );
extern void	  job_P_Gl_Tex_Gendv(	void );
extern void	  job_P_Gl_Tex_Genfv(	void );
extern void	  job_P_Gl_Tex_Geniv(	void );
extern void	  job_P_Gl_Get_Tex_Gendv(	void );
extern void	  job_P_Gl_Get_Tex_Genfv(	void );
extern void	  job_P_Gl_Get_Tex_Geniv(	void );
extern void	  job_P_Gl_Tex_Envf(	void );
extern void	  job_P_Gl_Tex_Envi(	void );
extern void	  job_P_Gl_Tex_Envfv(	void );
extern void	  job_P_Gl_Tex_Enviv(	void );
extern void	  job_P_Gl_Get_Tex_Envfv(	void );
extern void	  job_P_Gl_Get_Tex_Enviv(	void );
extern void	  job_P_Gl_Tex_Parameterf(	void );
extern void	  job_P_Gl_Tex_Parameteri(	void );
extern void	  job_P_Gl_Tex_Parameterfv(	void );
extern void	  job_P_Gl_Tex_Parameteriv(	void );
extern void	  job_P_Gl_Get_Tex_Parameterfv(	void );
extern void	  job_P_Gl_Get_Tex_Parameteriv(	void );
extern void	  job_P_Gl_Get_Tex_Level_Parameterfv(	void );
extern void	  job_P_Gl_Get_Tex_Level_Parameteriv(	void );
extern void	  job_P_Gl_Tex_Image1D(	void );
extern void	  job_P_Gl_Tex_Image2D(	void );
extern void	  job_P_Gl_Get_Tex_Image(	void );
extern void	  job_P_Gl_Gen_Textures(	void );
extern void	  job_P_Gl_Delete_Textures(	void );
extern void	  job_P_Gl_Bind_Texture(	void );
extern void	  job_P_Gl_Prioritize_Textures(	void );
extern void	  job_P_Gl_Are_Textures_Resident(	void );
extern void	  job_P_Gl_Is_Texture(	void );
extern void	  job_P_Gl_Tex_Sub_Image1D(	void );
extern void	  job_P_Gl_Tex_Sub_Image2D(	void );
extern void	  job_P_Gl_Copy_Tex_Image1D(	void );
extern void	  job_P_Gl_Copy_Tex_Image2D(	void );
extern void	  job_P_Gl_Copy_Tex_Sub_Image1D(	void );
extern void	  job_P_Gl_Copy_Tex_Sub_Image2D(	void );
extern void	  job_P_Gl_Map1D(	void );
extern void	  job_P_Gl_Map1F(	void );
extern void	  job_P_Gl_Map2D(	void );
extern void	  job_P_Gl_Map2F(	void );
extern void	  job_P_Gl_Get_Mapdv(	void );
extern void	  job_P_Gl_Get_Mapfv(	void );
extern void	  job_P_Gl_Get_Mapiv(	void );
extern void	  job_P_Gl_Eval_Coord1D(	void );
extern void	  job_P_Gl_Eval_Coord1F(	void );
extern void	  job_P_Gl_Eval_Coord1Dv(	void );
extern void	  job_P_Gl_Eval_Coord1Fv(	void );
extern void	  job_P_Gl_Eval_Coord2D(	void );
extern void	  job_P_Gl_Eval_Coord2F(	void );
extern void	  job_P_Gl_Eval_Coord2Dv(	void );
extern void	  job_P_Gl_Eval_Coord2Fv(	void );
extern void	  job_P_Gl_Map_Grid1D(	void );
extern void	  job_P_Gl_Map_Grid1F(	void );
extern void	  job_P_Gl_Map_Grid2D(	void );
extern void	  job_P_Gl_Map_Grid2F(	void );
extern void	  job_P_Gl_Eval_Point1(	void );
extern void	  job_P_Gl_Eval_Point2(	void );
extern void	  job_P_Gl_Eval_Mesh1(	void );
extern void	  job_P_Gl_Eval_Mesh2(	void );
extern void	  job_P_Gl_Fogf(	void );
extern void	  job_P_Gl_Fogi(	void );
extern void	  job_P_Gl_Fogfv(	void );
extern void	  job_P_Gl_Fogiv(	void );
extern void	  job_P_Gl_Feedback_Buffer(	void );
extern void	  job_P_Gl_Pass_Through(	void );
extern void	  job_P_Gl_Select_Buffer(	void );
extern void	  job_P_Gl_Init_Names(	void );
extern void	  job_P_Gl_Load_Name(	void );
extern void	  job_P_Gl_Push_Name(	void );
extern void	  job_P_Gl_Pop_Name(	void );
extern void	  job_P_Gl_Draw_Range_Elements(	void );
extern void	  job_P_Gl_Tex_Image3D(	void );
extern void	  job_P_Gl_Tex_Sub_Image3D(	void );
extern void	  job_P_Gl_Copy_Tex_Sub_Image3D(	void );

extern void       job_P_Glut_Solid_Cube(        void );

extern void       job_P_Glut_Init_Display_Mode(        void );
extern void       job_P_Glut_Init_Display_String(      void );
extern void       job_P_Glut_Init_Window_Position(     void );
extern void       job_P_Glut_Init_Window_Size(         void );
extern void       job_P_Glut_Create_Sub_Window(        void );
extern void       job_P_Glut_Destroy_Window(           void );
extern void       job_P_Glut_Post_Redisplay(           void );
extern void       job_P_Glut_Post_Window_Redisplay(    void );
extern void       job_P_Glut_Get_Window(               void );
extern void       job_P_Glut_Set_Window(               void );
extern void       job_P_Glut_Set_Window_Title(         void );
extern void       job_P_Glut_Set_Icon_Title(           void );
extern void       job_P_Glut_Position_Window(          void );
extern void       job_P_Glut_Reshape_Window(           void );
extern void       job_P_Glut_Pop_Window(               void );
extern void       job_P_Glut_Push_Window(              void );
extern void       job_P_Glut_Iconify_Window(           void );
extern void       job_P_Glut_Show_Window(              void );
extern void       job_P_Glut_Hide_Window(              void );
extern void       job_P_Glut_Full_Screen(              void );
extern void       job_P_Glut_Set_Cursor(               void );
extern void       job_P_Glut_Warp_Pointer(             void );
extern void       job_P_Glut_Establish_Overlay(        void );
extern void       job_P_Glut_Remove_Overlay(           void );
extern void       job_P_Glut_Use_Layer(                void );
extern void       job_P_Glut_Post_Overlay_Redisplay(   void );
extern void       job_P_Glut_Window_Overlay_Redisplay( void );
extern void       job_P_Glut_Show_Overlay(             void );
extern void       job_P_Glut_Hide_Overlay(             void );
extern void       job_P_Glut_Set_Color(                void );
extern void       job_P_Glut_Get_Color(                void );
extern void       job_P_Glut_Copy_Colormap(            void );
extern void       job_P_Glut_Get(                      void );
extern void       job_P_Glut_Device_Get(               void );
extern void       job_P_Glut_Extension_Supported(      void );
extern void       job_P_Glut_Get_Modifiers(            void );
extern void       job_P_Glut_Layer_Get(                void );

extern void       job_P_Glut_Bitmap_Character(         void );
extern void       job_P_Glut_Bitmap_Width(             void );
extern void       job_P_Glut_Stroke_Character(         void );
extern void       job_P_Glut_Stroke_Width(             void );
extern void       job_P_Glut_Bitmap_Length(            void );
extern void       job_P_Glut_Stroke_Length(            void );

extern void       job_P_Glut_Wire_Sphere(              void );
extern void       job_P_Glut_Solid_Sphere(             void );
extern void       job_P_Glut_Wire_Cone(                void );
extern void       job_P_Glut_Solid_Cone(               void );
extern void       job_P_Glut_Wire_Cube(                void );
extern void       job_P_Glut_Solid_Cube(               void );
extern void       job_P_Glut_Wire_Torus(               void );
extern void       job_P_Glut_Solid_Torus(              void );
extern void       job_P_Glut_Wire_Dodecahedron(        void );
extern void       job_P_Glut_Solid_Dodecahedron(       void );
extern void       job_P_Glut_Wire_Teapot(              void );
extern void       job_P_Glut_Solid_Teapot(             void );
extern void       job_P_Glut_Wire_Octahedron(          void );
extern void       job_P_Glut_Solid_Octahedron(         void );
extern void       job_P_Glut_Wire_Tetrahedron(         void );
extern void       job_P_Glut_Solid_Tetrahedron(        void );
extern void       job_P_Glut_Wire_Icosahedron(         void );
extern void       job_P_Glut_Solid_Icosahedron(        void );
extern void       job_P_Glut_Video_Resize_Get(         void );
extern void       job_P_Glut_Setup_Video_Resizing(     void );
extern void       job_P_Glut_Stop_Video_Resizing(      void );
extern void       job_P_Glut_Video_Resize(             void );
extern void       job_P_Glut_Video_Pan(                void );
extern void       job_P_Glut_Ignore_Key_Repeat(        void );
extern void       job_P_Glut_Set_Key_Repeat(           void );
extern void       job_P_Glut_Game_Mode_String(         void );
extern void       job_P_Glut_Enter_Game_Mode(          void );
extern void       job_P_Glut_Leave_Game_Mode(          void );
extern void       job_P_Glut_Game_Mode_Get(            void );

extern void       job_P_Gluq_Draw_Quadruped(           void );
extern void       job_P_Gluq_Draw_Biped(               void );
extern void       job_P_Gluq_Draw_Face(                void );
extern void       job_P_Gluq_Draw_Terrain(             void );

extern void       job_P_Gluq_Events_Pending(           void );
extern void       job_P_Gluq_Event(                    void );
extern void       job_P_Gluq_Queue_Event(              void );
extern void       job_P_Gluq_Mouse_Position(           void );

extern void	  job_P_Glut_Reserved_00(	       void );
extern void	  job_P_Glut_Reserved_01(	       void );
extern void	  job_P_Glut_Reserved_02(	       void );
extern void	  job_P_Glut_Reserved_03(	       void );
extern void	  job_P_Glut_Reserved_04(	       void );
extern void	  job_P_Glut_Reserved_05(	       void );
extern void	  job_P_Glut_Reserved_06(	       void );
extern void	  job_P_Glut_Reserved_07(	       void );
extern void	  job_P_Glut_Reserved_08(	       void );
extern void	  job_P_Glut_Reserved_09(	       void );
extern void	  job_P_Glut_Reserved_10(	       void );
extern void	  job_P_Glut_Reserved_11(	       void );
extern void	  job_P_Glut_Reserved_12(	       void );
extern void	  job_P_Glut_Reserved_13(	       void );
extern void	  job_P_Glut_Reserved_14(	       void );
extern void	  job_P_Glut_Reserved_15(	       void );
extern void	  job_P_Glut_Reserved_16(	       void );
extern void	  job_P_Glut_Reserved_17(	       void );
extern void	  job_P_Glut_Reserved_18(	       void );
extern void	  job_P_Glut_Reserved_19(	       void );
extern void	  job_P_Glut_Reserved_20(	       void );
extern void	  job_P_Glut_Reserved_21(	       void );
extern void	  job_P_Glut_Reserved_22(	       void );
extern void	  job_P_Glut_Reserved_23(	       void );
extern void	  job_P_Glut_Reserved_24(	       void );
extern void	  job_P_Glut_Reserved_25(	       void );
extern void	  job_P_Glut_Reserved_26(	       void );
extern void	  job_P_Glut_Reserved_27(	       void );
extern void	  job_P_Glut_Reserved_28(	       void );
extern void	  job_P_Glut_Reserved_29(	       void );
extern void	  job_P_Glut_Reserved_30(	       void );
extern void	  job_P_Glut_Reserved_31(	       void );
extern void	  job_P_Glut_Reserved_32(	       void );
extern void	  job_P_Glut_Reserved_33(	       void );
extern void	  job_P_Glut_Reserved_34(	       void );
extern void	  job_P_Glut_Reserved_35(	       void );
extern void	  job_P_Glut_Reserved_36(	       void );
extern void	  job_P_Glut_Reserved_37(	       void );
extern void	  job_P_Glut_Reserved_38(	       void );
extern void	  job_P_Glut_Reserved_39(	       void );
extern void	  job_P_Glut_Reserved_40(	       void );
extern void	  job_P_Glut_Reserved_41(	       void );

extern Job_Slow_Prim * job_OpenGL_Table3;
extern Job_Slow_Prim * job_OpenGL_Table4;

extern void       job_P_Abc_Abbc_Block(         void );
extern void       job_P_Chop_String(            void );
extern void       job_P_Constantp(              void );
extern void       job_P_Delete_Arg_Block(       void );
extern void       job_P_Delete_Nonchars_Block(  void );
extern void       job_P_Extract(                void );
extern void       job_P_Folk_P(        		void );
extern void       job_P_Glue_Strings_Block(     void );
extern void       job_P_Goto(                   void );
extern void       job_P_Guest_P(                void );
extern void       job_P_Invoke_Handler(         void );
extern void       job_P_Job_Queue_Contents(     void );
extern void       job_P_Job_Queues(             void );
extern void       job_P_Job_Queue_P(            void );
extern void       job_P_Job_Set_P(              void );
extern void       job_P_Kill_Job_Messily(       void );
extern void       job_P_Session_P(              void );
extern void       job_P_Socket_P(               void );
extern void       job_P_String_To_Words(        void );
extern void       job_P_Subclass_Of_P(          void );
extern void       job_P_Substring_P(            void );
extern void       job_P_Symbol_P(               void );
extern void       job_P_Symbol_Name(            void );
extern void       job_P_Symbol_Package(         void );
extern void       job_P_Set_Symbol_Constant(    void );
extern void       job_P_Set_Symbol_Plist(       void );
extern void       job_P_Set_Symbol_Type(        void );
extern void       job_P_Simple_Error(           void );
extern void       job_P_String_Downcase(        void );
extern void       job_P_String_Mixedcase(       void );
extern void       job_P_String_Upcase(          void );
extern void       job_P_Subblock(               void );
extern void       job_P_Symbol_Plist(           void );
extern void       job_P_Symbol_Type(            void );
extern void       job_P_Throw(                  void );
extern void       job_P_To_Delimited_String(    void );
extern void       job_P_To_String(              void );
extern void       job_P_Trim_String(            void );
extern void       job_P_Uniq_Block(             void );
extern void       job_P_Uniq_Keysvals_Block(    void );
extern void       job_P_Uniq_Pairs_Block(       void );
extern void       job_P_Unprint_Format_String(  void );
extern void       job_P_Unprint_String(         void );
extern void       job_P_Upper_Case_P(           void );
extern void       job_P_User_P(                 void );
extern void       job_P_Vals_Block(             void );
extern void       job_P_Vcnoise(                void );
extern void       job_P_Vector_P(               void );
extern void       job_P_Vector_I01_P(           void );
extern void       job_P_Vector_I08_P(           void );
extern void       job_P_Vector_I16_P(           void );
extern void       job_P_Vector_I32_P(           void );
extern void       job_P_Vector_F32_P(           void );
extern void       job_P_Vector_F64_P(           void );
extern void       job_P_Vnoise(                 void );
extern void       job_P_Whitespace_P(           void );
extern void       job_P_Wrap_String(            void );
extern void       job_P_Xor_Bits(               void );
extern void       job_P_Make_Socket(       	void );
extern void       job_P_Root_Make_Db(           void );
extern void       job_P_Root_Make_Guest(        void );
extern void       job_P_Root_Make_Guest_In_Dbfile(void);
extern void       job_P_Root_Make_User(         void );
extern void       job_P_Root_Export_Db(void);
extern void       job_P_Root_Import_Db(void);
extern void       job_P_Root_Remove_Db(void);
extern void       job_P_Root_Replace_Db(void);
extern void       job_P_Root_Mount_Database_File(void);
extern void       job_P_Root_Move_To_Dbfile(void);
extern void       job_P_Root_Shutdown(          void );
extern void       job_P_Root_Unmount_Database_File(void);
extern void       job_P_Root_Validate_Database_File(void );
extern void       job_P_Words_To_String(        void );
extern void       job_P_Write_Output_Stream(    void );
extern void       job_P_Write_Stream(           void );
extern void       job_P_Write_Stream_Packet(    void );
extern void       job_P_Root_Write_Stream_Packet(    void );
extern void       job_P_Maybe_Write_Stream_Packet( void );
extern void       job_P_Root_Maybe_Write_Stream_Packet( void );
extern void       job_P_Write_Substring_To_Stream( void );

extern void       job_P_Ceiling(		void );
extern void       job_P_Floor(			void );
extern void       job_P_Round(			void );
extern void       job_P_Truncate(		void );

extern void       job_P_Exp(			void );
extern void       job_P_Pow(			void );
extern void       job_P_Log(			void );
extern void       job_P_Log10(			void );
extern void       job_P_Sqrt(			void );
extern void       job_P_Abs(			void );
extern void       job_P_Ffloor(			void );
extern void       job_P_Fceiling(		void );
extern void       job_P_Acos(			void );
extern void       job_P_Asin(			void );
extern void       job_P_Atan(			void );
extern void       job_P_Atan2(			void );
extern void       job_P_Cos(			void );
extern void       job_P_Sin(			void );
extern void       job_P_Tan(			void );
extern void       job_P_Cosh(			void );
extern void       job_P_Sinh(			void );
extern void       job_P_Tanh(			void );

extern void       job_P_Count_Lines_In_String(	void );
extern void       job_P_Get_Line_From_String(	void );
extern void       job_P_Count_Stackframes(	void );
extern void       job_P_Get_Stackframe(		void );

extern void       job_ThunkN( 		      Vm_Int );

/* CommonLisp support/library fns: */
extern void       job_P_L_Read(			void );


/* CLX functions: */
/* Commented out because nobody is working */
/* on completing the X support:            */
#ifdef MAYBE_SOMEDAY
extern void       job_P_Close_Display(		void );
extern void       job_P_Color_P(		void );
extern void       job_P_Colormap_P(		void );
extern void       job_P_Cursor_P(		void );
extern void       job_P_Create_Gcontext(	void );
extern void       job_P_Create_Window(		void );
extern void       job_P_Destroy_Subwindows(	void );
extern void       job_P_Destroy_Window(		void );
extern void       job_P_Display_P(		void );
extern void       job_P_Display_Roots(		void );
extern void       job_P_Drawable_Border_Width(	void );
extern void       job_P_Drawable_Depth(		void );
extern void       job_P_Drawable_Display(	void );
extern void       job_P_Drawable_Height(	void );
extern void       job_P_Drawable_Width(		void );
extern void       job_P_Drawable_X(		void );
extern void       job_P_Drawable_Y(		void );
extern void       job_P_Draw_Glyphs(		void );
extern void       job_P_Draw_Image_Glyphs(	void );
extern void       job_P_Flush_Display(		void );
extern void       job_P_Font_Ascent(		void );
extern void       job_P_Font_Descent(		void );
extern void       job_P_Font_P(			void );
extern void       job_P_Gcontext_Background(	void );
extern void       job_P_Gcontext_Font(		void );
extern void       job_P_Gcontext_Foreground(	void );
extern void       job_P_Gcontext_P(		void );
extern void       job_P_Make_Event_Mask(	void );
extern void       job_P_Map_Window(		void );
extern void       job_P_Map_Subwindows(		void );
extern void       job_P_Open_Display(		void );
extern void       job_P_Open_Font(		void );
extern void       job_P_Pixmap_P(		void );
extern void       job_P_Query_Pointer(		void );
extern void       job_P_Screen_Black_Pixel(	void );
extern void       job_P_Screen_P(		void );
extern void       job_P_Screen_Root(		void );
extern void       job_P_Screen_White_Pixel(	void );
extern void       job_P_Text_Extents(		void );
extern void       job_P_Unmap_Subwindows(	void );
extern void       job_P_Unmap_Window(		void );
extern void       job_P_Window_P(		void );
#endif

extern Vm_Obj     job_Copy_Btree( Vm_Obj	 );
extern Vm_Obj     job_Btree_First(Vm_Obj	 );
extern Vm_Obj     job_Btree_Next( Vm_Obj, Vm_Obj );
extern Vm_Obj     job_Btree_Del(   Vm_Obj,Vm_Obj );
extern Vm_Obj     job_Btree_Set(   Vm_Obj,Vm_Obj,Vm_Obj,Vm_Unt);
extern Vm_Obj     job_Btree_Get(   Vm_Obj,Vm_Obj       );
extern Vm_Obj     job_Btree_Get_Asciz( Vm_Obj,Vm_Uch*  );

extern Vm_Obj     job_Get_Val_Block(Vm_Obj,Vm_Int);

extern void	  job_Guarantee_Ary_Arg( Vm_Int );
extern void	  job_Guarantee_Asm_Arg( Vm_Int );
extern void	  job_Guarantee_Bnm_Arg( Vm_Int );
extern void	  job_Guarantee_Blk_Arg( Vm_Int );
extern void       job_Guarantee_Btree_Arg(Vm_Int);
extern void	  job_Guarantee_Cdt_Arg( Vm_Int );
extern void       job_Guarantee_Char_Arg( Vm_Int );
extern void	  job_Guarantee_Cons_Arg( Vm_Int );
extern void	  job_Guarantee_Dbf_Arg( Vm_Int );
extern void	  job_Guarantee_Dst_Arg( Vm_Int );
extern void	  job_Guarantee_Double_Arg( Vm_Int );
extern void	  job_Guarantee_Cfn_Arg( Vm_Int );
extern void	  job_Guarantee_Ephemeral_Arg( Vm_Int );
extern void	  job_Guarantee_Float_Arg( Vm_Int );
extern void       job_Guarantee_IFloat_Arg(Vm_Int );
extern void       job_Guarantee_I01_Arg(Vm_Int);
extern void       job_Guarantee_I08_Arg(Vm_Int);
extern void       job_Guarantee_I16_Arg(Vm_Int);
extern void       job_Guarantee_I32_Arg(Vm_Int);
extern void       job_Guarantee_F32_Arg(Vm_Int);
extern void       job_Guarantee_F64_Arg(Vm_Int);
extern void	  job_Guarantee_I08_Len(Vm_Int,Vm_Int);
extern void       job_Guarantee_I16_Len(Vm_Int,Vm_Int);
extern void       job_Guarantee_I32_Len(Vm_Int,Vm_Int);
extern void       job_Guarantee_F32_Len(Vm_Int,Vm_Int);
extern void       job_Guarantee_F64_Len(Vm_Int,Vm_Int);
extern void	  job_Guarantee_Fn_Arg( Vm_Int );
extern void	  job_Guarantee_Folk_Arg( Vm_Int );
extern void	  job_Guarantee_Hash_Arg( Vm_Int );
extern void	  job_Guarantee_Index_Arg( Vm_Int );
extern void	  job_Guarantee_Plain_Arg( Vm_Int );
extern void	  job_Guarantee_Int_Arg( Vm_Int );
extern void	  job_Guarantee_Job_Arg( Vm_Int );
extern void	  job_Guarantee_Joq_Arg( Vm_Int );
extern void	  job_Guarantee_Jbs_Arg( Vm_Int );
extern void	  job_Guarantee_Lbd_Arg( Vm_Int );
extern void	  job_Guarantee_Lck_Arg( Vm_Int );
extern void       job_Guarantee_Mos_Arg( Vm_Int );
extern void	  job_Guarantee_Mss_Arg( Vm_Int );
extern void	  job_Guarantee_Mtd_Arg( Vm_Int );
extern void	  job_Guarantee_Muf_Arg( Vm_Int );
extern void	  job_Guarantee_Object_Arg( Vm_Int );
extern void	  job_Guarantee_Package_Arg( Vm_Int );
extern void	  job_Guarantee_Program_Arg( Vm_Int );
extern void	  job_Guarantee_Prx_Arg( Vm_Int );
extern void	  job_Guarantee_Cdf_Arg( Vm_Int );
extern void	  job_Guarantee_Key_Arg( Vm_Int );
extern void	  job_Guarantee_Ssn_Arg( Vm_Int );
extern void	  job_Guarantee_Set_Arg( Vm_Int );
extern void	  job_Guarantee_Clo_Arg( Vm_Int );
extern void	  job_Guarantee_Stc_Arg( Vm_Int );
extern void	  job_Guarantee_Stg_Arg( Vm_Int );
extern void	  job_Guarantee_Stk_Arg( Vm_Int );
extern void	  job_Guarantee_Stm_Arg( Vm_Int );
extern void	  job_Guarantee_Socket_Arg(  Vm_Int );
extern void	  job_Guarantee_Symbol_Arg( Vm_Int );
extern void	  job_Guarantee_Tbl_Arg( Vm_Int );
extern void	  job_Guarantee_Thunk_Arg( Vm_Int );
extern void	  job_Guarantee_User_Arg( Vm_Int );
extern void	  job_Guarantee_Vec_Arg( Vm_Int );

/* Commented out because nobody is working */
/* on completing the X support:            */
/* extern void       job_Guarantee_Xcl_Arg( Vm_Int ); */
/* extern void       job_Guarantee_Xcm_Arg( Vm_Int ); */
/* extern void       job_Guarantee_Xcr_Arg( Vm_Int ); */
/* extern void       job_Guarantee_Xdp_Arg( Vm_Int ); */
/* extern void       job_Guarantee_Xft_Arg( Vm_Int ); */
/* extern void       job_Guarantee_Xgc_Arg( Vm_Int ); */
/* extern void       job_Guarantee_Xpx_Arg( Vm_Int ); */
/* extern void       job_Guarantee_Xsc_Arg( Vm_Int ); */
/* extern void       job_Guarantee_Xwd_Arg( Vm_Int ); */

extern Vm_Int	  job_Guarantee_Nonempty_Stgblock( void );

extern Vm_Obj     job_Maybe_Update_Struct( Vm_Obj );

extern Vm_Obj     job_Will_Read_Message_Stream(Vm_Obj);
extern void       job_Will_Write_Message_Stream(Vm_Obj);

extern Vm_Int     job_Gcd( Vm_Int, Vm_Int );
extern Vm_Int     job_Lcm( Vm_Int, Vm_Int );
extern Vm_Obj     job_Tprint_Vm_Obj(       Vm_Obj, Vm_Int );
extern Vm_Int     job_Sprint_Vm_Obj(Vm_Uch*,Vm_Uch*,Vm_Obj,Vm_Int);
extern void       job_Warn( Vm_Uch*, ... );
extern void       job_Error(Vm_Uch*);
extern void       job_Signal_Job( Vm_Obj, Vm_Obj*, Vm_Unt );

extern void       job_must_control( Vm_Obj );
extern void       job_Call2( Vm_Obj );

extern void	  job_Do_Promiscuous_Read( Vm_Obj, Vm_Obj, Vm_Obj );
extern void	  job_End_Timeslice( void );
extern void	  job_State_Publish( Vm_Obj );
extern void	  job_State_Unpublish( void );

extern Vm_Int     job_Invariants(FILE*,Vm_Uch*,Vm_Obj);
extern void       job_Print(     FILE*,Vm_Uch*,Vm_Obj);
extern Vm_Int     job_Is_Alive( Vm_Obj );
extern Vm_Int     job_Controls( Vm_Obj );



/* Functions called directly from job_Fast_Table[], */
/* which thus MUST have type JOB_PRIM_ARGS_TYPED.   */
/* (We try to avoid using such functions, in favor  */
/* of doing JOB_UNCACHE_ARGS before calling out-of  */
/* line prim code.)                                 */
extern void 	  job_THUNK0(               JOB_PRIM_ARGS_TYPED );
extern void 	  job_THUNK1(               JOB_PRIM_ARGS_TYPED );
extern void       job_UNDERFLOW(            JOB_PRIM_ARGS_TYPED );
extern void       job_UNIMPLEMENTED_OPCODE( JOB_PRIM_ARGS_TYPED );
extern void       job_TIMESLICE_OVER(       JOB_PRIM_ARGS_TYPED );


/* I am not at all sure all of these should be exported:  */
extern void       job_Needed_Int(     Vm_Int              );

extern void       job_Push_Restartframe( Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj );
extern void       job_Push_Tagframe(    Vm_Unt		  );
extern void       job_Push_Catchframe(  Vm_Unt		  );
extern void       job_Push_Errset(      Vm_Unt            );
extern void       job_Push_Protectframe(Vm_Unt            );
extern void       job_Push_Protectchildframe(Vm_Unt       );
extern void       job_Blanch_Protectframe(Vm_Unt          );
extern void       job_Push_Signalframe( Vm_Obj		  );
extern void       job_Push_Thunkframe(  Vm_Int            );
extern void       job_Guarantee_Loop_Headroom(Vm_Int );
extern void       job_Loop_Overflow( void            );
extern void       job_Underflow( void                );
extern void       job_State_Update(   void                );
extern void       job_Unimplemented_Slow_Opcode( void );
extern void       job_Divide_By_Zero( void );
extern Vm_Int     job_Ephemeral_List_Loc(   Vm_Obj*, Vm_Obj );
extern Vm_Int     job_Ephemeral_Struct_Loc( Vm_Int*, Vm_Obj );
extern Vm_Int     job_Ephemeral_Vector_Loc( Vm_Int*, Vm_Obj );
extern Vm_Int     job_Read_Structure_Slot( Vm_Obj*, Vm_Obj, Vm_Unt );
extern Vm_Int     job_Write_Structure_Slot(Vm_Obj , Vm_Unt, Vm_Obj );
extern void       job_Link_Mos_Key_To_Ancestor( Vm_Obj, Vm_Int );


extern void	  job_Set_Mos_Key_Parent(     Vm_Obj, Vm_Unt, Vm_Obj );
extern void       job_Set_Mos_Key_Ancestor( Vm_Obj, Vm_Unt, Vm_Obj );

extern void job_P_Self0( void );
extern void job_P_Self1( void );
extern void job_P_Self2( void );
extern void job_P_Self3( void );
extern void job_P_Self4( void );
extern void job_P_Self5( void );

extern int    job_nearly_equal( double a, double b );
extern int    job_neq_vectors(Vm_Obj,Vm_Obj);
extern Vm_Obj job_mod_vectors(Vm_Obj,Vm_Obj);
extern Vm_Obj job_div_vectors(Vm_Obj,Vm_Obj);
extern Vm_Obj job_mul_vectors(Vm_Obj,Vm_Obj);
extern Vm_Obj job_add_vectors(Vm_Obj,Vm_Obj);
extern Vm_Obj job_sub_vectors(Vm_Obj,Vm_Obj);
extern Vm_Obj job_neg_vector(Vm_Obj);

extern Vm_Int job_Max_Bytecodes_Per_Timeslice;
extern Vm_Int job_Max_Microseconds_To_Sleep_In_Busy_Select;
extern Vm_Int job_Max_Microseconds_To_Sleep_In_Idle_Select;
extern Vm_Int job_Microseconds_To_Sleep_Per_Timeslice;

#ifndef   JOB_LOG_BYTECODES_FROM
#define   JOB_LOG_BYTECODES_FROM 0
#endif /* JOB_LOG_BYTECODES_FROM */

#ifndef   JOB_LOG_BYTECODES_TO
#define   JOB_LOG_BYTECODES_TO   1000000000
#endif /* JOB_LOG_BYTECODES_TO   */

extern Vm_Int job_Reserved;
extern Vm_Int job_Bytecodes_Logged;
extern Vm_Int job_Log_Bytecodes;
extern Vm_Int job_Log_Warnings;

extern Obj_A_Hardcoded_Class job_Hardcoded_Class;
extern Obj_A_Module_Summary  job_Module_Summary;

extern Job_A_RunState job_RunState;

extern Vm_Int job_Randombits0;
extern Vm_Int job_Randombits1;

extern Vm_Int job_End_Of_Run;
extern Vm_Int job_End_Of_Timeslice;
extern Vm_Int job_Nuke_All_Jobs_At_Startup;
extern Vm_Int job_Is_Idle_Usec;

/* Keywords: */
extern Vm_Obj job_Kw_Address_Family;
extern Vm_Obj job_Kw_Allocation;
extern Vm_Obj job_Kw_Any;
extern Vm_Obj job_Kw_Batch;
extern Vm_Obj job_Kw_Car;
extern Vm_Obj job_Kw_Cdr;
extern Vm_Obj job_Kw_Character;
extern Vm_Obj job_Kw_Close;
extern Vm_Obj job_Kw_Commandline;
extern Vm_Obj job_Kw_Mos_Generic;
extern Vm_Obj job_Kw_Class;
extern Vm_Obj job_Kw_Class_May_Read;
extern Vm_Obj job_Kw_Class_May_Write;
extern Vm_Obj job_Kw_Datagram;
extern Vm_Obj job_Kw_Dbname;
extern Vm_Obj job_Kw_Documentation;
extern Vm_Obj job_Kw_Downcase;
extern Vm_Obj job_Kw_Ear;
extern Vm_Obj job_Kw_Eof;
extern Vm_Obj job_Kw_Ephemeral;
extern Vm_Obj job_Kw_Eql;
extern Vm_Obj job_Kw_Exit;
extern Vm_Obj job_Kw_Event;
extern Vm_Obj job_Kw_Format_String;
extern Vm_Obj job_Kw_Get_Function;
extern Vm_Obj job_Kw_Guest;
extern Vm_Obj job_Kw_HashName;
extern Vm_Obj job_Kw_Host;
extern Vm_Obj job_Kw_Inherited;
extern Vm_Obj job_Kw_Initform;
extern Vm_Obj job_Kw_Initval;
extern Vm_Obj job_Kw_Instance;
extern Vm_Obj job_Kw_Interfaces;
extern Vm_Obj job_Kw_Internet;
extern Vm_Obj job_Kw_Invert;
extern Vm_Obj job_Kw_Ip0;
extern Vm_Obj job_Kw_Ip1;
extern Vm_Obj job_Kw_Ip2;
extern Vm_Obj job_Kw_Ip3;
extern Vm_Obj job_Kw_I0;
extern Vm_Obj job_Kw_I1;
extern Vm_Obj job_Kw_I2;
extern Vm_Obj job_Kw_Is_A;
extern Vm_Obj job_Kw_Job;
extern Vm_Obj job_Kw_Message_Stream;
extern Vm_Obj job_Kw_Name;
extern Vm_Obj job_Kw_Owner;
extern Vm_Obj job_Kw_Popen;
extern Vm_Obj job_Kw_Port;
extern Vm_Obj job_Kw_Preserve;
extern Vm_Obj job_Kw_Promise;
extern Vm_Obj job_Kw_Protocol;
extern Vm_Obj job_Kw_Root_May_Read;
extern Vm_Obj job_Kw_Root_May_Write;
extern Vm_Obj job_Kw_Set_Function;
extern Vm_Obj job_Kw_Signal;
extern Vm_Obj job_Kw_Socket;
extern Vm_Obj job_Kw_Stream;
extern Vm_Obj job_Kw_Socket_Stream;
extern Vm_Obj job_Kw_Tcp;
extern Vm_Obj job_Kw_Thunk;
extern Vm_Obj job_Kw_Tty;
extern Vm_Obj job_Kw_Type;
extern Vm_Obj job_Kw_Udp;
extern Vm_Obj job_Kw_Upcase;
extern Vm_Obj job_Kw_User_May_Read;
extern Vm_Obj job_Kw_User_May_Write;
extern Vm_Obj job_Kw_Why;
extern Vm_Obj job_Kw_World_May_Read;
extern Vm_Obj job_Kw_World_May_Write;

extern Vm_Obj job_Kw_Bignum;
extern Vm_Obj job_Kw_Built_In;
extern Vm_Obj job_Kw_Structure;
extern Vm_Obj job_Kw_Callstack;
extern Vm_Obj job_Kw_Vector;
extern Vm_Obj job_Kw_VectorI01;
extern Vm_Obj job_Kw_VectorI08;
extern Vm_Obj job_Kw_VectorI16;
extern Vm_Obj job_Kw_VectorI32;
extern Vm_Obj job_Kw_VectorF32;
extern Vm_Obj job_Kw_VectorF64;
extern Vm_Obj job_Kw_Mos_Key;
extern Vm_Obj job_Kw_Fixnum;
extern Vm_Obj job_Kw_Short_Float;
extern Vm_Obj job_Kw_Stackblock;
extern Vm_Obj job_Kw_Bottom;
extern Vm_Obj job_Kw_Compiled_Function;
extern Vm_Obj job_Kw_Character;
extern Vm_Obj job_Kw_Cons;
extern Vm_Obj job_Kw_Special;
extern Vm_Obj job_Kw_String;
extern Vm_Obj job_Kw_Symbol;

/* CLX Keywords: */
#ifdef HAVE_X11
extern Vm_Obj job_Kw_Arc_Mode;
extern Vm_Obj job_Kw_Background;
extern Vm_Obj job_Kw_Backing_Pixel;
extern Vm_Obj job_Kw_Backing_Planes;
extern Vm_Obj job_Kw_Backing_Store;
extern Vm_Obj job_Kw_Bit_Gravity;
extern Vm_Obj job_Kw_Border;
extern Vm_Obj job_Kw_Border_Width;
extern Vm_Obj job_Kw_Cap_Style;
extern Vm_Obj job_Kw_Class;
extern Vm_Obj job_Kw_Clip_Mask;
extern Vm_Obj job_Kw_Clip_Ordering;
extern Vm_Obj job_Kw_Clip_X;
extern Vm_Obj job_Kw_Clip_Y;
extern Vm_Obj job_Kw_Colormap;
extern Vm_Obj job_Kw_Copy;
extern Vm_Obj job_Kw_Cursor;
extern Vm_Obj job_Kw_Dash_Offset;
extern Vm_Obj job_Kw_Dashes;
extern Vm_Obj job_Kw_Depth;
extern Vm_Obj job_Kw_Do_Not_Propagate_Mask;
extern Vm_Obj job_Kw_Drawable;
extern Vm_Obj job_Kw_Event_Mask;
extern Vm_Obj job_Kw_Exposures;
extern Vm_Obj job_Kw_Fill_Rule;
extern Vm_Obj job_Kw_Fill_Style;
extern Vm_Obj job_Kw_Font;
extern Vm_Obj job_Kw_Foreground;
extern Vm_Obj job_Kw_Function;
extern Vm_Obj job_Kw_Gravity;
extern Vm_Obj job_Kw_Height;
extern Vm_Obj job_Kw_Input_Only;
extern Vm_Obj job_Kw_Input_Output;
extern Vm_Obj job_Kw_Join_Style;
extern Vm_Obj job_Kw_Left_To_Right;
extern Vm_Obj job_Kw_Line_Style;
extern Vm_Obj job_Kw_Line_Width;
extern Vm_Obj job_Kw_Override_Redirect;
extern Vm_Obj job_Kw_Parent;
extern Vm_Obj job_Kw_Plane_Mask;
extern Vm_Obj job_Kw_Right_To_Left;
extern Vm_Obj job_Kw_Save_Under;
extern Vm_Obj job_Kw_Stipple;
extern Vm_Obj job_Kw_Subwindow_Mode;
extern Vm_Obj job_Kw_Tile;
extern Vm_Obj job_Kw_Ts_X;
extern Vm_Obj job_Kw_Ts_Y;
extern Vm_Obj job_Kw_Visual;
extern Vm_Obj job_Kw_Width;
extern Vm_Obj job_Kw_X;
extern Vm_Obj job_Kw_Y;

extern Vm_Obj job_Kw_Button_1_Motion;
extern Vm_Obj job_Kw_Button_2_Motion;
extern Vm_Obj job_Kw_Button_3_Motion;
extern Vm_Obj job_Kw_Button_4_Motion;
extern Vm_Obj job_Kw_Button_5_Motion;
extern Vm_Obj job_Kw_Button_Motion;
extern Vm_Obj job_Kw_Button_Press;
extern Vm_Obj job_Kw_Button_Release;
extern Vm_Obj job_Kw_Colormap_Change;
extern Vm_Obj job_Kw_Enter_Window;
extern Vm_Obj job_Kw_Exposure;
extern Vm_Obj job_Kw_Focus_Change;
extern Vm_Obj job_Kw_Key_Press;
extern Vm_Obj job_Kw_Key_Release;
extern Vm_Obj job_Kw_Keymap_State;
extern Vm_Obj job_Kw_Leave_Window;
extern Vm_Obj job_Kw_Owner_Grab_Button;
extern Vm_Obj job_Kw_Pointer_Motion;
extern Vm_Obj job_Kw_Pointer_Motion_Hint;
extern Vm_Obj job_Kw_Property_Change;
extern Vm_Obj job_Kw_Resize_Redirect;
extern Vm_Obj job_Kw_Structure_Notify;
extern Vm_Obj job_Kw_Substructure_Notify;
extern Vm_Obj job_Kw_Substructure_Redirect;
extern Vm_Obj job_Kw_Visibility_Change;

#endif


/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_JOB_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

