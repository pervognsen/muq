@example  @c

/*--   Socktest.c -- Test host socket performance.			*/
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
/* Please send bug reports/fixes etc to cynbe@@muq.org.			*/
/************************************************************************/

/************************************************************************/
/* This little hack is intended primarily to see whether the		*/
/* discouragingly high roundTrip latencies which I'm seeing in		*/
/* muq/pkg/Check/xx-muqnet2 are inherent in the host OS kernel udp	*/
/* code or are due to some characteristic of Muq itself, by constructing*/
/* a simple pair of jobs which do nothing but echo via upd loopback.	*/
/*									*/
/* I compile and run it by doing in muq/c one of			*/
/*    make socktest1							*/
/************************************************************************/

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <time.h>
#include <malloc.h>

/* Number of roundTrips to do during test: */
#define TRIPS 40000

/* Sockets to use: */
#define PARENT_PORT 45454
#define CHILD_PORT  45455

#define READ  0
#define WRITE 1
void
main( int argc, char**argv) {
    int sockfd;
    struct sockaddr_in serv_addr;

    int pid;
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

    /* Fork off child: */
    pid = fork();
    if (0 > pid) {
	fprintf(stderr, "Couldn't fork?!\n");
	exit(1);
    }

    if (!pid) {
	/* Child: */
	int i;


        if ((sockfd = socket( AF_INET, SOCK_DGRAM, 0 )) < 0) {
	    fprintf(stderr,"Can't open socket!\n");
	    exit(1);
	}
	bzero((char*)&serv_addr, sizeof(serv_addr) );
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl( INADDR_ANY );
	serv_addr.sin_port	= htons( CHILD_PORT );
	if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr))<0){
	    fprintf(stderr,"can't bind address");
	}


	if (bytes) {
	    char* p = (char*)malloc(bytes); 
	    printf("%d bytes of ram allocated...\n",bytes);
	    for (i = 0; i < bytes; ++i) p[i]=0;
	    printf("%d bytes of ram zeroed...\n",bytes);
	}

	for (i = TRIPS;   i --> 0;   ) {
	    int n, clilen;
	    char mesg[128];
	    struct sockaddr addr;
	    clilen = sizeof(struct sockaddr);
	    n = recvfrom(sockfd,mesg,128,0,&addr,&clilen);
	    if (n < 0) {
		fprintf(stderr,"Recvfrom err\n");
		exit(1);
	    }
	    if (n != sendto( sockfd, mesg, n, 0, &addr, clilen )) {
		fprintf(stderr,"Sendto error\n");
		exit(1);
	    }
	}
	exit(0); 

    } else {
	/* Parent: */
	int sec;
	char buf[1];
	char buf2[1024];
	int i;
	buf[0] = '\n';

        /* Without this sleep(), the first call to recvfrom  */
	/* crashes.  I don't grok why, but evidently we need */
	/* to give the child time to get set up before we    */
        /* try to recieve from it...?  Or perhaps the error  */
	/* is really from the sendto(), but only reported    */
	/* when we do the recvfrom()?  Anyhow.		     */
        sleep(2);
        if ((sockfd = socket( AF_INET, SOCK_DGRAM, 0 )) < 0) {
	    fprintf(stderr,"Can't open socket!\n");
	    exit(1);
	}
	bzero((char*)&serv_addr, sizeof(serv_addr) );
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl( INADDR_ANY );
	serv_addr.sin_port	= htons( PARENT_PORT );
	if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr))<0){
	    fprintf(stderr,"can't bind address");
	}

	sec = time(NULL);
	for (i = TRIPS;   i --> 0;   ) {
	    int n;
	    struct sockaddr_in addr;
	    struct sockaddr_in junk;
	    int    len;
	    bzero((char*)&addr,sizeof(struct sockaddr_in));
	    addr.sin_family = AF_INET;
	    addr.sin_addr.s_addr = inet_addr("127.0.0.1");
	    addr.sin_port = htons(CHILD_PORT);

	    if (1 != sendto(sockfd,buf,1,0,(struct sockaddr*)&addr,sizeof(struct sockaddr_in))){
		fprintf(stderr,"sendto error\n");
		exit(1);
	    }
	    n = recvfrom(sockfd,buf2,1024,0, (struct sockaddr*)&junk, (int*)&len );
	    if (n != 1) {
		fprintf(stderr,"recvfrom error n d=%d\n",n);
		perror("Error was:");
		exit(1);
	    }
	}
	{   int end = time(NULL);
	    printf("%d loops, %d secs => %g secs/loop\n",
		TRIPS,
	        end-sec,
		(float)(end-sec)/(float)TRIPS
	    );
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

