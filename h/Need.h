
/*--   Need.h -- Supply and missing and needed prototypes.		*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_NEED_H
#define INCLUDED_NEED_H


/* See bottom of this file for source acknowlegement and such. 		*/



/************************************************************************/
/*-    Definitions for potentially missing macros.			*/

/* $Id: need_proto.h,v 1.2 1994/04/18 16:24:08 joel Exp $ */


/* #ifdef	NEED_HOWMANY_DEF */
/* #define howmany howmany(x, y)	(((x)+((y)-1))/(y)) */
/* #endif */

#ifdef	NEED_LOCKSH_DEF
/* Above NEED is misfiring on Dec OSF/1 v1.3a;  */
/* add extra #ifndefs to prevent redefinitions: */
#ifndef LOCK_SH
#define LOCK_SH 	1	/* shared lock */
#endif
#ifndef LOCK_EX
#define LOCK_EX 	2	/* exclusive lock */
#endif
#ifndef LOCK_NB
#define LOCK_NB 	4	/* dont block when locking */
#endif
#ifndef LOCK_NB
#define LOCK_UN 	8	/* unlock */
#endif
#endif




/************************************************************************/
/*-    Declarations for potentially missing externs.			*/

#ifdef	NEED_OPTARG
extern char* optarg;
#endif

#ifdef	NEED_OPTERR
extern int opterr;
#endif

#ifdef	NEED_OPTIND
extern int optind;
#endif




/************************************************************************/
/*-    Declarations for potentially missing prototypes.			*/

/* Ones provided by Cynbe.						*/
/* These need to match the TRL_PROTO_CHECK()s in c/Configure.in		*/
/* and the #undef NEED*s in c/Config.h.top				*/

/* Believe it or not, SunOS 4.x appears to have managed */
/* to omit prototypes for almost all the stdio.h fns:   */





#ifdef NEED__FILBUF_PROTO
extern int _filbuf(FILE*);
#endif

#ifdef NEED__FLSBUF_PROTO
extern int _flsbuf(unsigned,FILE*);
#endif

#ifdef NEED_ACCEPT_PROTO
struct sockaddr;
extern int accept (int s, struct sockaddr *addr, int *addrlen);
#endif

#ifdef NEED_BCOPY_PROTO
    /* On NeXTStep 3.2, bcopy is a macro, and */
    /* trying to provide a prototype gives us */
    /* a fatal compile error:                 */
    #ifndef bcopy
        extern int bcopy (const void *src, void *dst, int length);
    #endif
#endif

#ifdef NEED_BIND_PROTO
struct sockaddr;
extern int bind (int s, const struct sockaddr *name, int namelen);
#endif

#ifdef NEED_BZERO_PROTO
/* Next line is because we only need bzero if memset  */
/* doesn't appear to be around, otherwise bzero is in */
/* fact a macro expanding into memset, which messes   */
/* up this prototype pretty badly:                    */
#if !STDC_HEADERS && !HAVE_STRING_H
extern void bzero (void *b, int length);
#endif
#endif

#ifdef NEED_CRYPT_PROTO
/* extern char* crypt(char*,char*); */
#endif

#ifdef NEED_FCLOSE_PROTO
extern int fclose(FILE *);
#endif

#ifdef NEED_DRAND48_PROTO
extern double
drand48(void);
#endif

#ifdef NEED_FFLUSH_PROTO
extern int fflush(FILE *);
#endif

#ifdef NEED_FGETC_PROTO
extern int fgetc(FILE *);
#endif

#ifdef NEED_FPRINTF_PROTO
extern int fprintf(FILE*, const char*, ... );
#endif

#ifdef NEED_FPUTC_PROTO
extern int fputc( int, FILE* );
#endif

#ifdef NEED_FPUTS_PROTO
extern int fputs( const char*, FILE* );
#endif

#ifdef NEED_FREAD_PROTO
extern size_t fread(void * , size_t , size_t , FILE *);
#endif

#ifdef NEED_FSCANF_PROTO
extern int fscanf( FILE*, const char*, ... );
#endif

#ifdef NEED_FWRITE_PROTO
extern size_t fwrite( const void*, size_t, size_t, FILE * );
#endif

#ifdef NEED_GETHOSTNAME_PROTO
extern int gethostname( char*name, int namelen );
#endif

#ifdef NEED_MEMMOVE_PROTO
extern void* memmove( void *s1, const void *s2, size_t n );
#endif

#ifdef NEED_MEMSET_PROTO
extern void *memset (void* s, int c, size_t n );
#endif

#ifdef NEED_PCLOSE_PROTO
extern int pclose( FILE* );
#endif

#ifdef NEED_PRINTF_PROTO
extern int printf( const char* , ... );
#endif

#ifdef NEED_PUTS_PROTO
extern int puts( const char* );
#endif

#ifdef NEED_REMOVE_PROTO
extern int remove( const char* );
#endif

#ifdef NEED_RENAME_PROTO
extern int rename( const char *from, const char *to );
#endif

#ifdef NEED_REWIND_PROTO
extern void rewind( FILE *stream );
#endif

#ifdef NEED_GETRUSAGE_PROTO
struct rusage;
extern int getrusage( int, struct rusage* ); /* SunOS provides no header*/
#endif

#ifdef NEED_RANDOM_PROTO
extern long
random(void);
#endif

#ifdef NEED_SBRK_PROTO
extern void*
sbrk(int);
#endif

#ifdef NEED_SRAND48_PROTO
extern void
srand48(long);
#endif

#ifdef NEED_SRANDOM_PROTO
extern int
srandom(int);
#endif

#ifdef NEED_SSCANF_PROTO
extern int sscanf( const char*, const char*, ... );
#endif

#ifdef NEED_STRCASECMP_PROTO
extern int strcasecmp( const char*, const char* );
#endif

#ifdef NEED_SYSCONF_PROTO
extern long sysconf( int );
#endif

#ifdef NEED_SYSTEM_PROTO
extern int system( const char *string );
#endif

#ifdef NEED_TIME_PROTO
extern time_t time (time_t *tloc);
#endif

#ifdef NEED_TIMES_PROTO
struct tms;
extern clock_t times (struct tms* );
#endif

#ifdef NEED_TOLOWER_PROTO
extern int tolower (int c);
#endif

#ifdef NEED_TOUPPER_PROTO
extern int toupper (int c);
#endif

#ifdef NEED_VSPRINTF_PROTO
extern int vsprintf(char*, const char*, /* va_list */ char* );
#endif

#ifdef NEED_LISTEN_PROTO
extern int listen (int s, int backlog);
#endif

#ifdef NEED_SETSOCKOPT_PROTO
extern int
setsockopt(int s, int level, int optname, const void *optval, int optlen);
#endif

#ifdef NEED_SHUTDOWN_PROTO
extern int shutdown (int s, int how);
#endif

/* Originals: */

#ifdef	NEED_SELECT_PROTO
struct fd_set;
struct timeval;
extern int select(int,struct fd_set*,struct fd_set*,struct fd_set*,struct timeval*);
#endif

#ifdef	NEED_VSYSLOG_PROTO
#include <stdarg.h>
extern void vsyslog(int, const char*, va_list);
#endif

#ifdef	NEED_GETTIMEOFDAY_PROTO
#ifdef OFTEN_CORRECT
struct timezone;
struct timeval;
extern int gettimeofday(struct timeval*, struct timezone*);
#else
/* I'm not sure all systems with gettimeofday in fact */
/* have struct timezone* defined.  We're careful to   */
/* only use the struct timeval* argument, but to set  */
/* the second argument to something safe just in case */
/* it does get used. 95Mar31CrT                       */
struct timeval;
extern int gettimeofday(struct timeval*, char*);
#endif
#endif

#ifdef	NEED_STRFTIME_PROTO
struct tm;
extern size_t strftime(char*,size_t,const char*,const struct tm*);
#endif

#ifdef	NEED_LOCALTIME_PROTO
struct tm;
struct tm* localtime(const time_t* clock);
#endif

#ifdef	NEED_SETITIMER_PROTO
#ifdef ITIMER_REAL
struct itimerval;
extern int setitimer(int,struct itimerval*,struct itimerval*);
#endif /* ITIMER_REAL */
#endif

#ifdef	NEED_GETHOSTNAME_PROTO
extern int gethostname(char*, int);
#endif

#ifdef	NEED_GETHOSTBYNAME_PROTO
struct hostent;
extern struct hostent* gethostbyname(const char*);
#endif

#ifdef	NEED_GETHOSTBYADDR_PROTO
struct hostent;
extern struct hostent* gethostbyaddr(const void*, int, int);
#endif

#ifdef	NEED_GETPAGESIZE_PROTO
extern int getpagesize(void);
#endif

#ifdef	NEED_SERVERBYNAME_PROTO
struct servent;
extern struct servent*	getservbyname(const char*, const char*);
#endif

#ifdef	NEED_CFSETOSPEED_PROTO
extern int cfsetospeed(const struct termios*, speed_t);
#endif

#ifdef	NEED_CFSETISPEED_PROTO
extern int cfsetispeed(const struct termios*, speed_t);
#endif

#ifdef	NEED_TCGETATTR_PROTO
extern int tcgetattr(int, struct termios*);
#endif

#ifdef	NEED_TCSETATTR_PROTO
extern int tcsetattr(int, int, const struct termios*);
#endif

#ifdef	NEED_TCSENDBREAK_PROTO
extern int tcsendbreak(int, int);
#endif

#ifdef	NEED_TCDRAIN_PROTO
extern int tcdrain(int);
#endif

#ifdef	NEED_TCFLUSH_PROTO
extern int tcflush(int, int);
#endif

#ifdef	NEED_TCFLOW_PROTO
extern int tcflow(int, int);
#endif

#ifdef	NEED_MKSTAMP_PROTO
extern int mkstemp(char *);
#endif

#ifdef	NEED_STRERROR_PROTO
extern char* strerror(int);
#endif

#ifdef	NEED_STRNCASECMP_PROTO
extern int strncasecmp(const char*, const char*, size_t);
#endif

#ifdef	NEED_STRCASECMP_PROTO
extern int strcasecmp(const char*, const char*);
#endif

#ifdef	NEED_STRDUP_PROTO
extern char* strdup(const char*);
#endif

#ifdef	NEED_MEMSET_PROTO
extern void* memset(void*, int, size_t);
#endif

#ifdef	NEED_RANDOM_PROTO
extern long random(void);
#endif

#ifdef	NEED_FLOOR_PROTO
extern double floor(double);
#endif

#ifdef	NEED_WAITPID_PROTO
extern pid_t waitpid(pid_t, int *, int);
#endif

#ifdef	NEED_SIGVEC_PROTO
extern int sigvec(int, const struct sigvec*, struct sigvec*);
#endif

#ifdef	NEED_SIGACTION_PROTO
extern int sigaction(int, const struct sigaction*, struct sigaction*);
#endif

#ifdef	NEED_CLOSE_PROTO
extern int close(int);
#endif

#ifdef	NEED_GETUID_PROTO
extern uid_t getuid(void);
#endif

#ifdef	NEED_GETEUID_PROTO
extern uid_t geteuid(void);
#endif

#ifdef	NEED_SETEUID_PROTO
extern int seteuid(uid_t);
#endif

#ifdef	NEED_SETEGID_PROTO
extern int setegid(gid_t);
#endif

#ifdef	NEED_TRUNCATE_PROTO
extern int ftruncate(int, off_t);
#endif

#ifdef	NEED_GETDTABLESIZE_PROTO
extern int getdtablesize(void);
#endif

#ifdef	NEED_UNLINK_PROTO
extern int unlink(const char*);
#endif

#ifdef	NEED_READ_PROTO
extern int read(int, const void*, unsigned int);
#endif

#ifdef	NEED_IOCTL_PROTO
extern int ioctl(int, int, ...);
#endif

#ifdef	NEED_FCHOWN_PROTO
extern int fchown(int, uid_t, gid_t);
#endif

#ifdef	NEED_MALLOC_PROTO
extern void* malloc(size_t);
#endif

#ifdef	NEED_REALLOC_PROTO
extern void* realloc(void*, size_t);
#endif

#ifdef	NEED_FREE_PROTO
extern void free(void*);
#endif

#ifdef	NEED_STRTOUL_PROTO
extern unsigned long strtoul(const char*, char**, int);
#endif

#ifdef	NEED_CUSERID_PROTO
extern char* cuserid(char*);
#endif

#ifdef	NEED_GETOPT_PROTO
extern int getopt(int, char* const*, const char*);
#endif

#ifdef	NEED_GETSOCKNAME_PROTO
extern int getsockname(int, void*, int*);
#endif

#ifdef	NEED_ISATTY_PROTO
extern int isatty(int);
#endif

#ifdef	NEED_MKTEMP_PROTO
extern char* mktemp(char*);
#endif

#ifdef	NEED_POPEN_PROTO
extern FILE* popen(const char *, const char *);
#endif

#ifdef	NEED_PCLOSE_PROTO
extern int pclose(FILE*);
#endif

#ifdef	NEED_RECVFROM_PROTO
extern int recvfrom( int, void*, size_t, unsigned, void*, int*);
#endif

#ifdef	NEED_SENDTO_PROTO
extern int sendto( int, void*, size_t, unsigned, void*, int);
#endif

#ifdef	NEED_SYSLOG_PROTO
extern void syslog(int, const char*, ...);
#endif

#ifdef	NEED_CLOSELOG_PROTO
extern void closelog(void);
#endif

#ifdef	NEED_OPENLOG_PROTO
extern void openlog(const char*, int, int);
#endif

#ifdef	NEED_FCHMOD_PROTO
extern int fchmod(int, mode_t);
#endif

#ifdef	NEED_ENDPWENT_PROTO
extern void endpwent(void);
#endif

#ifdef	NEED_GETPERNAME_PROTO
extern int getpeername(int,void*,int*);
#endif

#ifdef	NEED_SOCKET_PROTO
extern int socket(int, int, int);
#endif

#ifdef	NEED_CONNECT_PROTO
extern int connect(int, const void*, int);
#endif

#ifdef	NEED_FLOCK_PROTO
extern int flock(int, int);
#endif

/* gcc thinks it owns the */
/* word 'asm';  Humor it: */
#ifdef __GNUC__
#define asm asmx
#endif




/************************************************************************/
/*-    Source acknowledgement &tc.					*/

/* This stuff arrived out of the blue via email in response to a comment */
/* to a gnu support mailing list.  I'm very happy to have it, and other- */
/* wise know only the following.  -- Jeff Prothero                      */

/*****************************************************************************/
/* From pinard%icule.UUCP@Lightning.McRCIM.McGill.EDU  Mon Jun 27 18:22:08 1994 */
/* X-VM-Attributes: [nil nil nil nil nil]                                   */
/* Posted-Date: Mon, 27 Jun 94 21:17 EDT				    */
/* Received-Date: Mon, 27 Jun 94 18:22:08 -0700				    */
/* Received: from Lightning.McRCIM.McGill.EDU by betz.biostr.washington.edu */
/*   (920330.SGI/Eno-0.1) id AA12197; Mon, 27 Jun 94 18:22:08 -0700         */
/* Received: from Chart.McRCIM.McGill.EDU by Lightning.McRCIM.McGill.EDU (8.6.4) with ESMTP */
/* 	id <199406280123.VAA17401@Lightning.McRCIM.McGill.EDU>; Mon, 27 Jun 1994 21:23:30 -0400 */
/* Received: from icule.UUCP by Chart.McRCIM.McGill.EDU  with UUCP          */
/*      (8.6.4//ident-1.0) id VAA26388; Mon, 27 Jun 1994 21:23:30 -0400     */
/* Received: by icule (Smail3.1.28.1 #1)                                    */
/*	id m0qIRny-00007YC; Mon, 27 Jun 94 21:17 EDT                        */
/* Message-Id: <m0qIRny-00007YC@icule>                                      */
/* In-Reply-To: <9406272031.AA11854@betz.biostr.washington.edu> (qwest@betz.biostr.washington.edu) */
/* From: pinard@iro.umontreal.ca (Francois Pinard)  	    	       	     */
/* To: qwest@betz.biostr.washington.edu	    	    	    	       	     */
/* Subject: Re: autoconfig is WONDERFUL!!!  	    	    	       	     */
/* Date: Mon, 27 Jun 94 21:17 EDT   	    	    	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/*    Last time around, most of them installed flawlessly!  	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* Yes, installation is far more comfortable than in the first days!   	     */
/*  	    	    	    	    	    	    	    	       	     */
/*    The thing I most miss is a simple way to detect whether a given  	     */
/*    function has been supplied a prototype...	    	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* I saved this message, in case I ever need it one day.  I thought it 	     */
/* could interest you too.  	    	    	    	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* >Resent-Date: Tue, 19 Apr 1994 08:48:15 +0100 (BDT)	    	       	     */
/* >Subject: autconf macro contribution - PROTO_CHECK	    	       	     */
/* >To: bug-gnu-utils@prep.ai.mit.edu	    	    	    	       	     */
/* >Date: Tue, 19 Apr 1994 08:48:15 +0100 (BDT)	    	    	       	     */
/* >From: Joel Rosi-Schwartz <root@filomena.co.uk>  	    	       	     */
/* >Reply-To: joel@filomena.co.uk   	    	    	    	       	     */
/* >Resent-From: bug-gnu-utils-request@prep.ai.mit.edu	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* I have attached a new macro that I am hopeful will be of 	       	     */
/* general use to to the community. The idea---and most of the	       	     */
/* hard work---comes from Sam Leffler's FlexFAX package; thanks	       	     */
/* again Sam. The idea is to locate and supply all of those 	       	     */
/* irritating prototype declarations that are missing on some	       	     */
/* systems. The contribution comes in three parts.  	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* actrl.m4    An autoconf macro the checks for the prototype and      	     */
/*          sets a flag if missing. e.g:    	    	    	       	     */
/*          TRL_PROTO_CHECK(cfsetispeed, termios.h  	    	       	     */
/*          sys/termios.h) Produces NEED_CFSETISPEED_PROTO  	       	     */
/*          if not located. 	    	    	    	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* need.h      A header file that ifdef's all of the	    	       	     */
/*          NEED_function_PROTO and declares the prototype  	       	     */
/*          if needed.	    	    	    	    	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* proto_check A list if calls to TRL_PROTO_CHECK for all of	       	     */
/*          the prototypes I have in need.h.  I have	    	       	     */
/*          supplied 60 and for sure there are more that    	       	     */
/*          could be done.  The ones I put in are the ones I	       	     */
/*          stole for FlexFAX's configure script (plagerism 	       	     */
/*          is the highest form of flattery ;-)	    	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* There are also a few #define macros and external var checks	       	     */
/* in need.h and proto_check which may prove useful.	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* While I have you on the line, I have a suggestion.  In   	       	     */
/* gnuplot a check is done for the X11 headers.  This puts  	       	     */
/* -I/usr/include on the search list.  This cause all of the	       	     */
/* hard, fine work of gcc fixincludes to go out the window. 	       	     */
/* Would it be possible to explicitly filter the addition of	       	     */
/* /usr/include, since they will be found in any case?	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* Thanks again for the fine system.	    	    	    	       	     */
/*  	    	    	    	    	    	    	    	       	     */
/* Cheers,  	    	    	    	    	    	    	       	     */
/* Joel	    	    	    	    	    	    	    	       	     */
/* --	    	    	    	    	    	    	    	       	     */
/*      ==================================================================   */
/*      ||        T E C H N E   R E S E A R C H    L I M I T E D        ||   */
/*      ||  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ||   */
/*      ||                     Joel Rosi-Schwartz                       ||   */
/*      ||   Hildorien House            +   Email: joel@filomena.co.uk  ||   */
/*      ||   12 Waverley Way            +                               ||   */
/*      ||   Finchampstead, Wokingham   +   Phone: +44 (734) 730.260    ||   */
/*      ||   Berkshire RG11 4YD (UK)    +   Fax:   +44 (734) 730.272    ||   */
/*      ==================================================================   */
/* ----  snip/snip  --------  cut here  -------------------------------------*/
/* (omitted--CrT)     	    	    	    	    	    	       	     */
/*****************************************************************************/




/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_NEED_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

