@example  @c
/*--   jobpass.c -- Generate ../h/jobpass.h for jobbuild.cc		*/
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
/* Created:      93Feb04						*/
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
/*-	Grump								*/
/*									*/
/*	"Homo sapiens sapies":	"Wise wise man", a name the species	*/
/*	picked for itself -- presumably because the majority of its	*/
/*	members are neither.						*/
/*									*/
/************************************************************************/



/************************************************************************/
/*-    to do                                            		*/
/************************************************************************/
/*
OJ suggests using setitimer() instead, with ITIMER_VIRTUAL,
to time this sort of stuff, instead of counting seconds.
Count iterations of the loop in fixed amount of time instead
of time to do a fixed number of loops.  Possibly gives more
accuracy (if timing is done to better than 1-sec accuracy
this way, which it might be), and compensates for background
processes better.
*/


/************************************************************************/
/*-    #includes                                            		*/
/************************************************************************/

#include "Site-config.h"

#include "Config.h"
#include "Hax.h"	/* Portability stuff working with above.	*/
#include "Need.h"	/* Portability stuff working with above.	*/

#include "Defaults.h"



/************************************************************************/
/*-    #defines                                            		*/
/************************************************************************/

/* Minimum ticks to run test loops.	*/
#define MIN_TICKS_TO_RUN (500)

/* Name of file to create:		*/
#define JOBPASS_H "../h/jobpass.h"

/* What to do on fatal error:						*/
#ifndef JOB_FATAL
#define JOB_FATAL(x) {fprintf(stderr, (x));abort();}
#endif



/************************************************************************/
/*-    Statics                                            		*/
/************************************************************************/

static int parameters_are_faster( void );
static int test_parameters( int );
static int test_globals( int );
static void   test_tail_recursion( void );
static void   write_jobpass_h( int );




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    main								*/
/************************************************************************/

int main( int argc, char** argv ) {
    test_tail_recursion();
    write_jobpass_h( parameters_are_faster() );
    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    parameters_are_faster						*/
/************************************************************************/

static int
parameters_are_faster(
    void
) {

    int  junk0 = 0;		/* Initialized only to quiet compilers. */
    int  junk1 = 0;		/* Initialized only to quiet compilers. */
    clock_t parameter_ticks =0;	/* Initialized only to quiet compilers. */
    clock_t global_ticks    =0;	/* Initialized only to quiet compilers. */
    #if defined(HAVE_SYSCONF) && defined( _SC_CLK_TCK )
    int      sc_clk_tck = sysconf( _SC_CLK_TCK );
    #else
        #ifdef CLK_TCK
        int  sc_clk_tck = CLK_TCK;
        #else
        int  sc_clk_tck = 60; /* Common val, and we don't care much. */
        #endif
    #endif
    int  log2_loops_to_do;
    for (   log2_loops_to_do = 0;

        parameter_ticks <  MIN_TICKS_TO_RUN   &&
        global_ticks    <  MIN_TICKS_TO_RUN;

	++log2_loops_to_do
    ) {
        struct tms start;
        struct tms stop;

	(void) times( &start );
	junk0 = test_parameters( 1 << log2_loops_to_do );
	(void) times( &stop  );
	parameter_ticks = stop.tms_utime - start.tms_utime;
	
	(void) times( &start );
	junk1 = test_globals(    1 << log2_loops_to_do );
	(void) times( &stop  );
	global_ticks    = stop.tms_utime - start.tms_utime;

	if (parameter_ticks + global_ticks > sc_clk_tck) {
	    printf(
		"%d: Parameters:globals runtime ratio: %3d:%3d ticks.\n",
		log2_loops_to_do, (int)parameter_ticks, (int)global_ticks
	    );
	}
    }

    /* Junk1 and 0 should always be equal, "(junk1-junk0)"	*/
    /* is merely designed to keep optimizing compilers from	*/
    /* eliminating our test code:				*/
    if (junk0 != junk1)   JOB_FATAL("junk0 != junk1?!");
    return (parameter_ticks < global_ticks) + (junk1-junk0);
}



/************************************************************************/
/*-    test_globals							*/
/************************************************************************/

static int pa;
static int pb;
static int pc;
static int pd;

static int
globals(
    void
) {

    pb += 3;
    pc += 5;
    pd += 7;
    if (!(--pa & 0x1F))   return pb+pc+pd;
    return globals();
}

static int
test_globals(
    int loops_to_do
) {
    pa = loops_to_do;
    pb = 0;
    pc = 0;
    pd = 0;
    for (;;) {
	int result = globals();
	if (!pa)   return result;
    }
}



/************************************************************************/
/*-    test_parameters							*/
/************************************************************************/

static int
parameters(
    int a,
    int b,
    int c,
    int d
) {
    b += 3;
    c += 5;
    d += 7;
    if (!(--a & 0x1F)) {
	pa = a;
	pb = b;
	pc = c;
	pd = d;
        return b+c+d;
    }
    return parameters( a, b, c, d );
}

static int
test_parameters(
    int loops_to_do
) {
    pa = loops_to_do;
    pb = 0;
    pc = 0;
    pd = 0;
    for (;;) {
	int result = parameters( pa, pb, pc, pd );
	if (!pa)   return result;
    }
}



/************************************************************************/
/*-    test_tail_recursion						*/
/************************************************************************/


/************************************/
/* Use two recursive functions to   */
/* detect braindead compilers that  */
/* only do tail recursion when a fn */
/* calls itself (e.g., gcc):        */
/************************************/
static int recursion_finis( Vm_Chr* );
static int recursion_mid_B( Vm_Chr*, int );
static int blind( int );

static int
recursion_mid_A(
    Vm_Chr*x,
    int a
) {
    if (a) return recursion_mid_B( x, a-1 );
    else   return recursion_finis( x      );
}

static int
recursion_mid_B(
    Vm_Chr*x,
    int a
) {
    if (a) return recursion_mid_A( x, a-1 );
    else   return recursion_finis( x      );
}

static int
recursion_finis(
    Vm_Chr*x
) {
    Vm_Chr   a;
    return blind( &a-x );
}

static int
blind(
    int i
) {
    return i;
}

static void
test_tail_recursion(
    void
) {
    Vm_Chr x;
    if (recursion_mid_A(&x,5) == recursion_mid_A(&x,6)) {
	puts("Congratulations, your compiler does tail recursion intelligently.\n");
    } else {
	puts("\nYour compiler is bungling tail recursion."		);
	puts("This will _not_ affect the correctness of Muq,"		);
	puts("but it may detectably slow down Muq."			);
	puts("You may want to see if your compiler has an"		);
	puts("option to enable tail-recursion optimization,"		);
	puts("and add it to COPTFLAGS in Makefile2[.in]"		);
	puts("(gcc -- through 2.7.0, at least -- has no such switch."	);
	puts("I've been told -O9 will do it, but haven't checked."	);
	puts("So far I've only seen the IBM AIX cc get it right.)\n"	);
    }
}



/************************************************************************/
/*-    write_jobpass_h							*/
/************************************************************************/

static void
write_jobpass_h(
    int parameters_are_faster
) {
    FILE* fd = fopen( JOBPASS_H, "w" );
    if (!fd) {
	fprintf(stderr,"Counldn't create %s\n", JOBPASS_H );
	exit(1);
    }
    fputs("#ifndef INCLUDED_JOBPASS_H\n",fd);
    fputs("#define INCLUDED_JOBPASS_H 1\n",fd);
    fprintf(fd,
	"/* Parameters are %s than globals on this machine,\t*/\n",
	parameters_are_faster ? "faster" : "slower"
    );
    fprintf(fd,
	"/* so we want to pass bytecode stuff in %s:\t*/\n",
	parameters_are_faster ? "parameters" : "globals"
    );
    fprintf(fd,
	"#define JOB_PASS_IN_PARAMETERS (%d)\n",
        parameters_are_faster
    );
    fprintf(fd,
	"#define JOB_PASS_SIZEOF_SHORT (%d)\n",
        sizeof(short)
    );
    fprintf(fd,
	"#define JOB_PASS_SIZEOF_INT (%d)\n",
        sizeof(int)
    );
    fprintf(fd,
	"#define JOB_PASS_SIZEOF_LONG (%d)\n",
        sizeof(long)
    );
    fprintf(fd,
	"#define JOB_PASS_SIZEOF_LONG_LONG (%d)\n",
#ifdef __GNUC__
        sizeof(long long)
#else
	0
#endif
    );
    fprintf(fd,
	"#define JOB_PASS_SIZEOF_FLOAT (%d)\n",
        sizeof(float)
    );
    fprintf(fd,
	"#define JOB_PASS_SIZEOF_DOUBLE (%d)\n",
        sizeof(double)
    );
    fputs("#endif /* INCLUDED_JOBPASS_H*/\n",fd);

    printf(
	"\nInterpreter will be configured to pass state via %ss.\n\n",
	parameters_are_faster ? "parameter" : "global"
    );
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

