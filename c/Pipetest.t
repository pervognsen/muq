@example  @c

/*--   Pipetest.c -- Test host context switch performance.		*/
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
/* Created:      97Jan19						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1998, by Jeff Prothero.				*/
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
/* Please send bug reports/fixes etc to cynbe@eskimo.com.		*/
/************************************************************************/

/************************************************************************/
/* This little hack is intended primarily to see whether the		*/
/* discouragingly high roundTrip latencies which I'm seeing in		*/
/* muq/pkg/Check/xx-muqnet2 are inherent in the host OS kernel		*/
/* or are due to some characteristic of Muq itself, by constructing	*/
/* a simple pair of jobs which do nothing but echo via pipes.		*/
/*									*/
/* The answer to the question seems to be that Linux can do thousands	*/
/* of context switches per second, so the six-round-trip-per-second	*/
/* bottleneck I'm seeing must be due to something other than OS context	*/
/* switch latency times.  (Inflating process sizes to 10Meg each	*/
/* doesn't seem to affect performance either.)				*/
/*									*/
/* I compile and run it by doing in muq/c one of			*/
/*    make pipetest1							*/
/*    make pipetest2							*/
/************************************************************************/

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>
#include <malloc.h>

/* Number of roundTrips to do during test: */
#define TRIPS 40000

#define READ  0
#define WRITE 1
void
main( int argc, char**argv) {
    int pid;
    int pipe1[2];
    int pipe2[2];
    int bytes;

    /* Handle commandline args: */
    if (argc != 2) {
	printf("usage: context1 bytes\n");
	exit(1);
    }

    sscanf( argv[1], "%d", &bytes );
    if (bytes) {
	int i;
	char* p = (char*)malloc(bytes); 
	printf("%d bytes of ram allocated...\n",bytes);
	for (i = 0; i < bytes; ++i) p[i]=0;
	printf("%d bytes of ram zeroed...\n",bytes);
    }

    /* Create pipes: */
    if (0 > pipe( pipe1 )
    ||  0 > pipe( pipe2 )
    ){
	fprintf(stderr, "Couldn't open the pipes?!\n");
	exit(1);
    } 

    /* Fork off child: */
    pid = fork();
    if (0 > pid) {
	fprintf(stderr, "Couldn't fork?!\n");
	exit(1);
    }

    if (!pid) {
	/* Child: */
	char buf[1];
	int i;
	if (bytes) {
	    char* p = (char*)malloc(bytes); 
	    printf("%d bytes of ram allocated...\n",bytes);
	    for (i = 0; i < bytes; ++i) p[i]=0;
	    printf("%d bytes of ram zeroed...\n",bytes);
	}
	for (i = TRIPS;   i --> 0;   ) {
	    read(  pipe1[READ ], buf, 1 );
	    write( pipe2[WRITE], buf, 1 );
	}
	exit(0); 

    } else {
 	/* Parent: */
	int sec = time(NULL);
	char buf[1];
	int i;
	buf[0] = '\n';
	for (i = TRIPS;   i --> 0;   ) {
	    write( pipe1[WRITE], buf, 1 );
	    read(  pipe2[READ ], buf, 1 );
	}
	{   int end = time(NULL);
	    printf("%d loops, %d secs\n",TRIPS,end-sec);
	    exit(0); 
	}
    }
    exit(0);
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

