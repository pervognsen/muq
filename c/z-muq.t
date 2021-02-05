@example  @c
/*--   z-muq.c -- Trivial app to run muf interactively.			*/
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
/* Created:      93Mar06						*/
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
/*  Contact cynbe@eskimo.com for a COMMERCIAL LICENSE.			*/
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
/* Please send bug reports/fixes etc to bugs@eskimo.com.		*/
/************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"


/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#ifndef ZMUQ_BATCH_FN
#define ZMUQ_BATCH_FN ""
#endif

#ifndef ZMUQ_INTERACTIVE_FN
#define ZMUQ_INTERACTIVE_FN ""
#endif

/* Max length we let a user type in for a line: */
#define ZMUQ_LINELENGTH_MAX	4096

/* Max number of files we execute from commandline: */
#define ZMUQ_MUFFILES_MAX	 128



/* Just to maybe enhance portability */
/* on nonPOSIX systems w/o unistd.h: */

#ifndef STDIN_FILENO
#define STDIN_FILENO	0
#endif

#ifndef STDOUT_FILENO
#define STDOUT_FILENO	1
#endif

#ifndef STDERR_FILENO
#define STDERR_FILENO	2
#endif



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

void usage( void );

static Vm_Uch  zmuq_batch_fn[       ZMUQ_LINELENGTH_MAX ] = ZMUQ_BATCH_FN;
static Vm_Uch  zmuq_interactive_fn[ ZMUQ_LINELENGTH_MAX ] = ZMUQ_INTERACTIVE_FN;
static Vm_Uch* zmuq_files[ ZMUQ_MUFFILES_MAX ];
static Vm_Int  zmuq_file = 0;

Vm_Int   main_ArgC;
Vm_Uch** main_ArgV;
static Vm_Uch*      allowed_outbound_net_ports = NULL;
static Vm_Uch* root_allowed_outbound_net_ports = NULL;
static Vm_Uch* srvdir = NULL;
static int dump_state = FALSE;


/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static Vm_Obj create_TTY_skt(void);
static void execute_files( void );
static void make_job( Vm_Obj, Vm_Obj );
static void read_eval_print_loop( Vm_Uch*, Vm_Obj, Vm_Obj );
static void startup(  Vm_Uch* );
/* NEXTSTEP 3.2 has a 'shutdown', so avoid that name: */
static void muq_shutdown( void );
static void crack_big_option( Vm_Uch* );
static Vm_Obj package_symbol( Vm_Uch* );
static void daemon_setup( void );



/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    main								*/
/************************************************************************/

int
main(
    int       argC,
    Vm_Chr**  argV
) {
    int     want_interactive_session = FALSE;
    int     i;
    Vm_Uch* db = NULL;

    muq_Is_In_Daemon_Mode = FALSE;

    main_ArgV = (Vm_Uch**)argV;
    main_ArgC =           argC;

    /* Give ogl a crack at eating any  */
    /* commandline args it recognizes: */
    ogl_Startup();

    /* Process commandline args: */
    for (i = 1;   i < argC;   ++i) {
	Vm_Uch* arg = argV[i];
	if (*arg++ != '-') {
            if (db)   usage();
	    db = argV[i];
	    continue;
	}
	switch (*arg) {

	case 'b':
	    /* Initial size for vm.c's bigbuf[]: */
	    if (*++arg)        usage();
	    if (++i == argC)   usage();
	    arg = argV[i];
	    {   Vm_Int len = strlen( arg );
		Vm_Int multiplier = 1; /*Initialized only to quiet compilers.*/
		if (len < 2)   usage();
		switch (tolower( arg[ len-1 ] )) {
		case 'k': multiplier = (1 << 10);	break;
		case 'm': multiplier = (1 << 20);	break;
		default:
		    usage();
	        }
		{   Vm_Uch* t = arg;
		    for (t = arg;   t[1];   ++t)  if (! isdigit( * t)) usage();
		}
		vm_Initial_Bigbuf_Size = multiplier * atoi( arg );
	    }
	    break;

	case 'f':
	    if (*++arg)        usage();
	    if (++i == argC)   usage();
	    if (zmuq_file == ZMUQ_MUFFILES_MAX-1) {
		fprintf(stderr,
		    "More than %d -f files, increase ZMUQ_MUFFILES_MAX & recompile\n",
		    (int)ZMUQ_MUFFILES_MAX
		);
		exit(1);
	    }
	    zmuq_files[ zmuq_file++ ] = argV[i];
	    break;

	case 'd':
            muq_Is_In_Daemon_Mode = TRUE;
	    break;

	case 'i':
	    want_interactive_session = TRUE;
	    break;

	case 'm':
	    lib_Note_All_Muf_Libraries();
	    puts( lib_Optional_Muf_Libraries );
	    exit(0);

	case 'M':
	    lib_Note_All_Muf_Libraries();
	    puts( lib_Optional_Muf_Selfcheck_Libraries );
	    exit(0);

	case 'V':
	    printf( "%s\n", VERSION );
	    exit(0);

	case 'x':
	    if (*++arg)        usage();
	    if (++i == argC)   usage();
	    if (strlen(argV[i]) >= ZMUQ_LINELENGTH_MAX) {
		fprintf(stderr,
		    "-x arg > %d, increase ZMUQ_LINELENGTH_MAX & recompile\n",
		    (int)ZMUQ_LINELENGTH_MAX
		);
		exit(1);
	    }
	    strcpy( zmuq_batch_fn      , argV[i] );
	    strcpy( zmuq_interactive_fn, argV[i] );
	    break;

	case '-':
	    crack_big_option( arg-1 );	    
	    break;

	default:
	    usage();
	}
    }

    lib_Log_Printf( "MUQ STARTING. (pid %d)\n", getpid() );

    if (muq_Is_In_Daemon_Mode)   daemon_setup();

    if (!srvdir) {
	lib_Find_Srv_Directory();
    } else if (*srvdir) {
	lib_Validate_Srv_Directory( srvdir );
    }

    startup(db);

    if (allowed_outbound_net_ports) {
	obj_Select_Outbound_Ports( 
	    obj_Allowed_Outbound_Net_Ports,
	    allowed_outbound_net_ports
	);
    }
    if (root_allowed_outbound_net_ports) {
	obj_Select_Outbound_Ports( 
	    obj_Root_Allowed_Outbound_Net_Ports,
	    root_allowed_outbound_net_ports
	);
    }

    if (dump_state) {

	obj_Dump_State();

    } else {
	if (zmuq_file) {
	    execute_files();
	} else if (muq_Is_In_Daemon_Mode) {
	    read_eval_print_loop(
		zmuq_interactive_fn,
		package_symbol( "muf:initShell" ),
		0
	    );
	} else {
	    Vm_Obj skt = create_TTY_skt();
	    read_eval_print_loop(
		zmuq_interactive_fn,
		package_symbol( "muf:mufShell" ),
		skt
	    );
	}
    }

    muq_shutdown();

    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    add_session_to_skt -- Utility for create_*_skt.			*/
/************************************************************************/

static void
add_session_to_skt(
    Vm_Obj skt
) {
    /* Create new session: */
    Vm_Obj job     = job_Make_Job( JOB_FORK_SESSION, OBJ_FROM_BYT4('i','n','i','t') );
    Vm_Obj jobset  = JOB_P(job)->job_set;
    Vm_Obj session = JBS_P(jobset)->session;

    joq_Run_Job( job );

    /* Tell session what skt it is associated with: */
    {   Ssn_P ssn 	= SSN_P(session);
	ssn->skt	= skt;
	vm_Dirty(session);
    }

    {   /* Allocate a pair of msss to buffer   */
	/* I/O between session leader and skt: */
	Vm_Obj skt_to_job = obj_Alloc( OBJ_CLASS_A_MSS, 0 );
        Vm_Obj job_to_skt = obj_Alloc( OBJ_CLASS_A_MSS, 0 );

	/* Combine the two unidirectional message streams */
        /* into a  single  bidirectional  message stream  */
	/* by pointing their 'twin' fields to each other: */
	MSS_P(skt_to_job)->twin = job_to_skt; vm_Dirty(skt_to_job);
	MSS_P(job_to_skt)->twin = skt_to_job; vm_Dirty(job_to_skt);

	{   Job_P j	= JOB_P(job);
	    j->standard_input	= job_to_skt;
	    j->standard_output	= job_to_skt;
	    j->terminal_io	= job_to_skt;
	    j->query_io		= job_to_skt;
	    j->debug_io		= job_to_skt;
	    j->error_output	= job_to_skt;
	    j->trace_output	= job_to_skt;
	    vm_Dirty(job);
	}

	/* Point skt to appropriate message queues: */
	{   Skt_P q		= SKT_P(skt);
	    q->standard_input	= job_to_skt;
	    q->standard_output	= skt_to_job;

	    q->session		= session;
	    vm_Dirty(skt);
	}
    }
}


/************************************************************************/
/*-    crack_big_option -- Parse --xxx=yyy type commandline option.	*/
/************************************************************************/

#ifndef MAX_BIG_OPTION
#define MAX_BIG_OPTION 1024
#endif
void
crack_big_option(
    Vm_Uch* option
){
    Vm_Uch buf[ MAX_BIG_OPTION ];
    Vm_Uch*key;
    Vm_Uch*val;
    if (strlen( option ) > MAX_BIG_OPTION) {
	fprintf( stderr,
	    "Option too long.  "
	    "(Increase MAX_BIG_OPTION and recompile?)"
	    "Option: '%s'",
	    option
	);
	exit(1);
    }

    /* Copy option into temp buffer to avoid */
    /* diddling argv[], and crack into the   */
    /* --key=val halves:                     */
    strcpy( buf, option );
    key = buf+2;
    val = key;
    while (*val && *val != '=')  ++val;
    if (*val == '=') { *val = '\0'; ++val; }

    /* Interpret the option: */
    if (STRCMP( key, == ,"ignore-signature" )) {
	if (*val)   usage();
	obj_Ignore_Server_Signature = TRUE;
	return;
    }
    if (STRCMP( key, == ,"no-environment" )) {
	if (*val)   usage();
	obj_No_Environment = TRUE;
	return;
    }
    if (STRCMP( key, == ,"log-bytecodes" )) {
	if (*val)   usage();
	job_Log_Bytecodes = TRUE;
	return;
    }
    if (STRCMP( key, == ,"dump" )) {
	if (*val)   usage();
	dump_state = TRUE;
	return;
    }
    if (STRCMP( key, == ,"logfile" )) {
	if (!*val)   usage();
	if (lib_Logfile = fopen(val,"a")) {
	    lib_Logfilename = (Vm_Uch*) lib_Malloc( (Vm_Int) (strlen(val)+1) );
	    strcpy( lib_Logfilename, val );
	    return;
	} else {
	    #ifdef HAVE_STRERROR
	    printf(
		"Could not open logfile '%s: %s. Will do no logging.\n",
		val,
		strerror(errno)
	    );
	    #else
	    printf(
		"Could not open logfile '%s': errno %d -- will do no logging.\n",
		val,
		errno
	    );
	    #endif
	}
    }
    if (STRCMP( key, == ,"full-db-check" )) {
	if (*val)   usage();
	obj_Quick_Start = FALSE;
	return;
    }
    if (STRCMP( key, == ,"destports" )) {
	char*buf = (char*)malloc(strlen(val)+1);
	strcpy(buf,val);
	allowed_outbound_net_ports = buf;
	return;
    }
    if (STRCMP( key, == ,"rootdestports" )) {
	char*buf = (char*)malloc(strlen(val)+1);
	strcpy(buf,val);
	root_allowed_outbound_net_ports = buf;
	return;
    }
    if (STRCMP( key, == ,"no-pid-file" )) {
	if (*val)   usage();
	obj_Write_Pid_File = FALSE;
	return;
    }
    if (STRCMP( key, == ,"srvdir" )) {
	char*buf = (char*)malloc(strlen(val)+1);
	strcpy(buf,val);
	srvdir = buf;
	return;
    }
    usage();
}


/************************************************************************/
/*-    create_BAT_skt -- Create batch-mode  stdin/stdout skt.		*/
/************************************************************************/

Vm_Obj
create_BAT_skt(
    void
) {
    /* Allocate a new skt: */
    Vm_Obj skt  = obj_Alloc( OBJ_CLASS_A_SKT, 0 );

    /* Open first file to be batch-processed: */
    int fd = open( *skt_Bat_Files, O_RDONLY );
    if (fd == -1) {
	fprintf(stderr,"Couldn't open '%s'!\n",*skt_Bat_Files);
	exit(1);
    }
    ++skt_Bat_Files;

    /* Decorate skt with its own session,  */
    /* jobset and job, suitably connected: */
    add_session_to_skt( skt );
    
    /* Activate skt on fd/stdout: */
    skt_Activate( skt,
        SKT_TYPE_BAT,	/* Type of skt.					*/
        STDOUT_FILENO,	/* fd to write.					*/
        fd		/* fd to read.					*/
    );

    return skt;
}



/************************************************************************/
/*-    create_TTY_skt -- Create interactive stdin/stdout skt.		*/
/************************************************************************/

static Vm_Obj
create_TTY_skt(
    void
) {
    /* Allocate a new skt: */
    Vm_Obj skt = obj_Alloc( OBJ_CLASS_A_SKT, 0 );

    /* Decorate skt with its own session,  */
    /* jobset and job, suitably connected: */
    add_session_to_skt( skt );
    
    /* Activate skt on stdin/stdout: */
    skt_Activate( skt,
        SKT_TYPE_TTY,	/* Type of skt.					*/
        STDOUT_FILENO,	/* fd to write.					*/
        STDIN_FILENO	/* fd to read.					*/
    );

    return skt;
}



/************************************************************************/
/*-    daemon_setup							*/
/************************************************************************/

static void
daemon_setup(
    void
) {
    /************************************************/
    /* This is mostly following W Richard Stevens'  */
    /* recommendations in Unix Network Programming, */
    /* p72-85					    */
    /************************************************/

    #ifdef  SIGTTOU
    signal( SIGTTOU, SIG_IGN );
    #endif

    #ifdef  SIGTTIN
    signal( SIGTTIN, SIG_IGN );
    #endif

    #ifdef  SIGTSTP
    signal( SIGTSTP, SIG_IGN );
    #endif

    {   int childpid = fork();
	if (childpid < 0) {
	    fputs("Couldn't fork child?!\n",stderr);
	    exit(1);
	}
	if (childpid > 0)  exit(0);	/* Discard parent process. */


	/********************/
	/* We're the child. */
	/********************/

	#ifndef HAVE_ZERO_SETPGRP_ARGS		/* BSD */

	/* Get our own process group: */
	if (setpgrp(0, getpid()) == -1) {
	    fputs("Couldn't change process group\n",stderr);
	    exit(1);
	}

	/* Dissociate from controlling tty: */
	#ifdef TIOCNOTTY
	{   int fd = open("/dev/tty",O_RDWR);
	    if (fd >= 0) {
		ioctl( fd, TIOCNOTTY, (char*) NULL );
		close( fd );
	}   }
	#endif

	#else		/* SysV */

	/* Get our own process group: */
	if (setpgrp() == -1) {
	    fputs("Couldn't change process group\n",stderr);
	    exit(1);
	}

	/* Guard self from process group leader death: */
	signal( SIGHUP, SIG_IGN );

	childpid = fork();
	if (childpid < 0) {
	    fputs("Couldn't fork grandchild?!\n",stderr);
	    exit(1);
	}
	if (childpid > 0)  exit(0);	/* Discard original child. */

	#endif
    }

    /* Close open files.  Trying to deduce the   */
    /* max open file count is ridiculously hard, */
    /* so we just use the usual "20" number:     */
    {   int  fd;
	for (fd = 20;   fd --> 0;   ) {
	    close(fd);
    }	}

    /* Reset errno -- above closes prolly */
    /* generated some ignored errors.	  */
    errno = 0;

    /* Avoid problems due to unexpected file mode masks: */
    umask(0);
}

/************************************************************************/
/*-    execute_files							*/
/************************************************************************/

static void
execute_files(
    void
) {
    zmuq_files[ zmuq_file ] = NULL;
    skt_Bat_Files           = zmuq_files;

    {   Vm_Obj skt = create_BAT_skt();
	read_eval_print_loop(
	    zmuq_batch_fn,
	    obj_Lib_Muf_Compile_Muf_File,
	    skt
	);
    }
}



/************************************************************************/
/*-    make_job -- plug function into job, reset job			*/
/************************************************************************/

static void
make_job(
    Vm_Obj job,
    Vm_Obj executable
) {
    Vm_Obj loop_stack;
    Vm_Obj pc;

    {   Job_P p 	  	= JOB_P(job);

	p->j.privs		= OBJ_FROM_INT(0) /*| JOB_PRIVS_OMNIPOTENT*/;

	p->j.actual_user	= job_RunState.j.actual_user;
	p->j.acting_user	= job_RunState.j.acting_user;

	p->root_obj		= vm_Root(0);
	p->here_obj		= job_RunState.j.actual_user;

	loop_stack		= p->j.loop_stack;

	vm_Dirty(job);

        /* Counterproductive with new stackframe setup, methinks: */
	/* cfn_Reset( p->loop_stack ); */
    }

    /* Compute initial program counter value for fn: */
    {   /* Get address of executable: */
	register Cfn_P p = CFN_P(executable);

	/* Locate start of constants vector: */
	Vm_Uch* k0 = (Vm_Uch*) &(p->vec[                     0 ]);

	/* Locate end   of constants vector: */
	Vm_Uch* kn = (Vm_Uch*) &(p->vec[ CFN_CONSTS(p->bitbag) ]);

	/* Difference of above is initial pc: */
	pc = OBJ_FROM_UNT( kn - k0 );
    }

    {   Vm_Obj vec = STK_P( loop_stack )->vector;
	Vec_P    v = VEC_P( vec );
	Vm_Obj*  l = &v->slot[ 0 ];
	#if MUQ_IS_PARANOID
	if (*l) MUQ_FATAL ("z-muq.c:make_job internal err #1");
	#endif
	++l;
	#if MUQ_IS_PARANOID
	if (*l != (5*sizeof(Vm_Obj))) {
	    MUQ_FATAL ("z-muq.c:make_job internal err #2");
	}
	#endif
	l[1] = pc;
	l[2] = executable;
    }
}



/************************************************************************/
/*-    package_symbol -- look up "pkg:symbol"				*/
/************************************************************************/
static Vm_Obj
package_symbol(
    Vm_Uch* name
) {
    Vm_Obj pkg;
    Vm_Obj sym;
    Vm_Uch buf[ 4096 ];
    register Vm_Uch* t;
    strcpy( buf, name );
    for (t = buf;   *t != ':';   ++t) {
	if (!*t) {
	    fprintf(stderr,"Bad 'pkg:symbol' spec: %s\n",buf);
	    exit(1);
    }   }
    *t = '\0';
    pkg = muf_Find_Package_Asciz( buf );
    if (!pkg) {
	fprintf(stderr,"No such package: %s\n",buf);
	exit(1);
    }
    *t++ = ':';
    sym = sym_Find_Exported_Asciz( pkg, t );
    if (!sym) {
	fprintf(stderr,"No such symbol: %s\n",buf);
	exit(1);
    }
    return SYM_P(sym)->function;
}

/************************************************************************/
/*-    read_eval_print_loop						*/
/************************************************************************/

static Vm_Obj job;
static void
read_eval_print_loop(
    Vm_Uch* loop_name,
    Vm_Obj cfn,
    Vm_Obj skt
) {
    Vm_Obj ssn;
    Vm_Obj set;
    if (skt) {
	ssn = SKT_P(skt)->session;
	job = SSN_P(ssn)->session_leader;
    } else {
	/* Create new session: */
	job = job_Make_Job( JOB_FORK_SESSION, OBJ_FROM_BYT4('i','n','i','t') );
	set = JOB_P(job)->job_set;
	ssn = JBS_P(set)->session;

	joq_Run_Job( job );
    }
    if (*loop_name) {
	cfn = package_symbol( loop_name );
    }
    if (!OBJ_IS_CFN(cfn)) {
	fprintf(stderr, "Not a compiledFunction: %s\n", loop_name );
	exit(1);
    }
    make_job( job, cfn );

    /* Set console skt not to do \n -> \r\n translation on output: */
    if (skt) {
	obj_System_Set(
	    skt,
	    sym_Alloc_Asciz_Keyword("nl-to-crnl-on-output"),
	    OBJ_NIL
	);
    }

    {	/* Preserve state of currently running */
	/* job (which is normally /etc/jb0):   */
	Vm_Obj old_job = job_RunState.job;

	job_State_Unpublish();

	/* Currently we longjmp() back here from  */
	/* skt_usually_close_socket at the end of */
	/* a batch run, or from job.c:job_next()  */
        /* at the end of an interactive run:      */
	if (!setjmp( skt_Bat_Longjmp_Buf )) {
	    Vm_Int usec = job_Max_Microseconds_To_Sleep_In_Busy_Select;
	    job_State_Publish( job );

	    /* Interactive shells expect to find  */
	    /* an argument block on the stack, so */
	    /* reset data stack to empty and then */
	    /* push an argument block on it:      */
	    job_RunState.s    = job_RunState.s_bot;
	    {   Vm_Obj std_in = JOB_P(job_RunState.job)->standard_input;
		*++job_RunState.s = OBJ_BLOCK_START;
		*++job_RunState.s = std_in;
		*++job_RunState.s = OBJ_FROM_BLK(1);
	    }

	    /* This outer Muq loop.  If you have  */
	    /* additional application-specific    */
	    /* stuff which needs periodic         */
	    /* servicing, you can add it to this  */
	    /* loop. The two "job_Max_Microsecs*" */
	    /* variables are visible and settable */
	    /* in-db: It is better to modify them */
	    /* than to ignore them.  They control */
	    /* how long Muq will sit in a select()*/
	    /* call waiting for date from the net */
	    /* to arrive:  If you need to keep    */
	    /* periodic checks running in this    */
	    /* loop, you may want to keep them    */
	    /* low.                               */
	    while (!job_End_Of_Run) {
		job_Is_Idle_Usec = usec; /* Parameter to job_Is_Idle(). */
		if (job_Is_Idle()) {
		    usec = job_Max_Microseconds_To_Sleep_In_Idle_Select;
		} else {
		    usec = job_Max_Microseconds_To_Sleep_In_Busy_Select;
		}

		/* Some sysadmins just plain don't want  */
		/* Muq soaking up all their CPU cycles.  */
		/* Renicing the task is one way to try   */
		/* to control the problem; The following */
		/* provides a way to insert a mandatory  */
		/* sleep interval into every timeslice:  */
		if (job_Microseconds_To_Sleep_Per_Timeslice) {
		    skt_Select_Sockets(NULL,NULL,NULL,
		        job_Microseconds_To_Sleep_Per_Timeslice
		    );
		}
	    }
	}
	if (jS.job)   job_State_Unpublish();

	/* Restore previously running job: */
	job_State_Publish( old_job );

	/* Make a weak attempt to flush pending output. */
	/* This doesn't catch output hidden back in job */
	/* pipelines, nor wait for blocked sockets to   */
	/* clear:                                       */
	skt_Is_Closing_Down = TRUE;
	while (skt_Maybe_Do_Some_IO( 0 ));
    }
}



/************************************************************************/
/*-    startup								*/
/************************************************************************/

static void
startup(
    Vm_Uch* db
) {
    /* If user specified db dir, pass to vm.c: */
    if (db) {
        vm_Octave_File_Path = db;
    }

    obj_Startup();
    obj_Linkup();

    /* Maybe record our process id: */
    if (obj_Write_Pid_File) {
	Vm_Uch buf[ 1024 ];
	FILE* fd;
	sprintf( buf, "muq-%s.pid", vm_Octave_File_Path );
	if (!(fd = fopen( buf, "w" ))) {
	    fprintf( stderr,
		"***** Couldn't create '%s', continuing anyhow.\n",
		buf
	    );
	    obj_Write_Pid_File = FALSE; /* Don't try deleting it. */
	}
	fprintf(fd, "%d\n", (int)getpid() );
	fclose( fd );
    }
}



/************************************************************************/
/*-    muq_shutdown							*/
/************************************************************************/

static void
muq_shutdown(
    void
) {

    obj_Shutdown();

    /* Maybe unlink our process id file: */
    if (obj_Write_Pid_File) {
	Vm_Uch buf[ 1024 ];
	sprintf( buf, "muq-%s.pid", vm_Octave_File_Path );
	if (unlink( buf )) {
	    fprintf( stderr,
		"***** Couldn't unlink '%s'.\n",
		buf
	    );
	}
    }

    /* Maybe close our logfile: */
    if (lib_Logfile) {
	jS.j.actual_user = 0;	/* Keep lib_Log_Printf from crashing.	*/
        lib_Log_Printf( "STOPPING MUQ. (pid %d)\n", getpid() );
	fclose( lib_Logfile );
    }

    /* To avoid "qwest@betz:muq/c> " prompt run-on: */
/*    putchar('\n'); */
}



/************************************************************************/
/*-    usage								*/
/************************************************************************/

void usage(void) {

#define F(x) fprintf(stderr, x )
F("usage: muq [-m] [-M] [-V] [-f file]* [-x path] [-b <size>] [db]\n" );
F(" db   is db prefix to use -- defaults to 'muq'.\n");
F(" -M   List optional muf selfcheck libraries.\n");
F(" -m   List optional muf libraries.\n");
F(" -V   List server version.\n");
F(" -b 12K          Run with db ram buffer of twelve kilobytes.\n");
F(" -b 4M           Run with db ram buffer of four megabytes.\n");
F(" -f filename     Run given file of muf code.\n");
F(" -d              Run as a unix daemon, via muf:initShell and .etc.rc2.\n");
F(" -x pkg:symbol   Run (e.g.) muf:my-loop not muf:compileMufFile.\n");
F(" --destports=80,6064-64000  Which outbound net connects are allowed.\n");
F("   (ALLOWING ALL OUTBOUND PORTS POSES SERIOUS SECURITY PROBLEMS!)\n");
F(" --rootdestports=80,6064-64000  Outbound net connects root is allowed.\n");
F(" --full-db-check Force full db checking even if db looks ok.\n");
F(" --ignore-signature  Run even when db doesn't match server.\n");
F(" --logfile=xyzzy.log Log to given file.  (Otherwise, no logging.)\n");
F(" --no-environment    Do not load environment into .env.\n");
F(" --no-pid-file       Don't create a muq-vm.pid file.\n");
F(" --log-bytecodes     Start up with .muq.traceBytecodes == t.\n");
F(" --srvdir=$HOME/muq/srv Override muq/bin/Muq-config.sh srvdir setting.\n");
F(" --dump          Dump state as text to stdout and exit.\n");
#undef F

    exit(1);
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
