
/*--   Hax.h -- Portability hacks for Muq.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_HAX_H
#define INCLUDED_HAX_H


/* These hacks are factored out of Muq.h so that files which		*/
/* cannot include Muq.h (principally jobbuild.h) can #include		*/
/* them rather than replicating them.					*/

/* NEXTSTEP 3.2's libc.h manages to define a value of TRUE that */
/* triggers parse errors whenever referenced.  Fix by defining  */
/* our own value before it can:                                 */
#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE  1
#endif

/* NEXTSTEP 3.2's libc.h buggously #imports stdio.h even if */
/* it already has been, overriding the macrodefs in stdio.h */
/* designed to stop this, and resulting in multiple-defs of */
/* struct _iobuf and such. Fix is to include libc.h FIRST:  */
#ifdef HAVE_LIBC_H

#include <libc.h> /* Where NEXTSTEP 3.2 keeps select(), open(), close()... */

#endif

#include <stdio.h>

#ifdef HAVE_STDARG_H
#include <stdarg.h>
#endif

#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

/************************************************************************/
/* Comments courtesy of GNU autoconfig:					*/
/* If a program may include both `time.h' and `sys/time.h', define	*/
/* `TIME_WITH_SYS_TIME'.  On some older systems, `sys/time.h'		*/
/* includes `time.h', but `time.h' is not protected against multiple	*/
/* inclusion, so programs should not explicitly include both files.	*/
/* This macro is useful in programs that use, for example, `struct	*/
/* timeval' or `struct timezone' as well as `struct tm'.  It is best	*/
/* used in conjunction with `HAVE_SYS_TIME_H'.				*/
/************************************************************************/
#ifdef TIME_WITH_SYS_TIME
    #include <sys/time.h>
    #include <time.h>
#else
    #ifdef HAVE_SYS_TIME_H
        #include <sys/time.h>
    #else
        #ifdef HAVE_TIME_H
            #include <time.h>
        #endif
    #endif
#endif

#ifdef HAVE_SYS_TIMES_H
#include <sys/times.h>
#endif

#ifdef HAVE_CTYPE_H
#include <ctype.h>
#endif

#ifdef HAVE_LIMITS_H
#include <limits.h>
#endif

#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif

#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h>	/* Irix 4.0.5H wants this for times() */
#endif

#ifdef HAVE_ERRNO_H
#include <errno.h>
#endif

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif

#ifdef HAVE_NETDB_H
#include <netdb.h>
#endif

#ifdef HAVE_SYS_WAIT_H
/* NB: 95Jun26 Pakrat report: <sys/wait.h> needs to be  */
/* before <netinet/in.h> on Linux in order to prevent a */
/* "redefinition of LITTLE_ENDIAN" warning:             */
#include <sys/wait.h>
#endif

#ifdef HAVE_NETINET_IN_H
#include <netinet/in.h>
#endif

#ifdef HAVE_ARPA_INET_H
/* NB: This needs to be after <netinet/in.h> on at */
/* least some unices.  (Advice from Leo Plotkin,   */
/* leo@dash.com.                                   */
#include <arpa/inet.h>
#endif

#ifdef HAVE_SIGNAL_H
#include <signal.h>
#endif

#ifdef HAVE_SYS_FILE_H
#include <sys/file.h>
#endif

#ifdef HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>
#endif

#ifdef HAVE_SYS_SOCKET_H
#include <sys/socket.h>
#endif

#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif

#ifdef HAVE_SETJMP_H
#include <setjmp.h>
#endif

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#ifndef MUQ_USE_RUSAGE
  #ifdef HAVE_SYS_RESOURCE_H
    #define MUQ_USE_RUSAGE TRUE
  #endif
#endif
#ifndef MUQ_USE_RUSAGE
  #ifdef HAVE_SYS_RUSAGE_H
    #define MUQ_USE_RUSAGE TRUE
  #endif
#endif
#ifndef   MUQ_USE_RUSAGE
  #define MUQ_USE_RUSAGE FALSE
#endif

#if MUQ_USE_RUSAGE

#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>	/* Irix  4.x puts 'struct rusage' here. */
#endif

#ifdef HAVE_SYS_RUSAGE_H
#include <sys/rusage.h>		/* SunOS 5.x puts 'struct rusage' here. */
#endif

#endif

#ifdef HAVE_SYS_SELECT_H
/* #if defined(_AIX) || defined(___AIX) */
#include <sys/select.h>
#endif


/* NEXTSTEP 3.2's libc.h buggously #imports stdio.h even if */
/* it already has been, overriding the macrodefs in stdio.h */
/* designed to stop this, and resulting in multiple-defs of */
/* struct _iobuf and such. Fix is to include libc.h FIRST:  */
#ifdef HAVE_LIBC_H
#include <libc.h> /* Where NEXTSTEP 3.2 keeps select(), open(), close()... */
#endif

#ifdef HAVE_X11

/**************************************************/
/* This stuff is cribbed from xdvi, recommended   */
/* as an example of using X11 in conjunction with */
/* gnu autoconfigure.  It's all a mystery to me:  */
/**************************************************/
#ifdef FOIL_X_WCHAR_T
#define wchar_t foil_x_defining_wchar_t
#define X_WCHAR
#endif

#include <X11/Xlib.h>	/* include Xfuncs.h, if available */
#include <X11/Xutil.h>	/* needed for XDestroyImage */
#include <X11/Xos.h>
#undef wchar_t

#ifndef	XlibSpecificationRelease
#define	XlibSpecificationRelease 0
#endif

#if	XlibSpecificationRelease >= 5
#include <X11/Xfuncs.h>
#endif

#ifndef	NOTOOL
#include <X11/Intrinsic.h>
#define	TOOLKIT
#else
#define	XtNumber(arr)	(sizeof(arr)/sizeof(arr[0]))
typedef	unsigned long	Pixel;
typedef	char		Boolean;
typedef	unsigned int	Dimension;
#undef	TOOLKIT
#undef	BUTTONS

#include <X11/cursorfont.h>
#include <X11/keysym.h>

#ifdef	TOOLKIT
#ifdef	OLD_X11_TOOLKIT
#include <X11/Atoms.h>
#else /* not OLD_X11_TOOLKIT */
#include <X11/Xatom.h>
#include <X11/StringDefs.h>
#endif /* not OLD_X11_TOOLKIT */
#include <X11/Shell.h>	/* needed for def. of XtNiconX */
#ifndef	XtSpecificationRelease
#define	XtSpecificationRelease	0
#endif
#if	XtSpecificationRelease >= 4
#include <X11/Xaw/Viewport.h>
#ifdef	BUTTONS
#include <X11/Xaw/Command.h>
#endif
#else	/* XtSpecificationRelease < 4 */
#define	XtPointer caddr_t
#include <X11/Viewport.h>
#ifdef	BUTTONS
#include <X11/Command.h>
#endif
#endif	/* XtSpecificationRelease */
#else	/* !TOOLKIT */
typedef	int		Position;
#endif	/* TOOLKIT */

#endif  /* NOTOOL */

#endif  /* HAVE_X11 */



#ifndef FALSE
#define FALSE (0)
#endif
#ifndef TRUE
#define TRUE  (1)
#endif

/**************************************************/
/* Following is the autoconfig-recommended recipe */
/* for string functions from the version 1.11 doc */
/* "Header Files" node, AC_STDC_HEADERS section,  */
/* except I have reversed their #defines so as to */
/* have the code using ansi C rather than BSD fn  */
/* names -- better habit for reader to acquire -- */
/* except for bzero which unfortunately can't be: */
/**************************************************/
#if STDC_HEADERS || HAVE_STRING_H
  #include <string.h>

  /* An ANSI string.h and pre-ANSI memory.h might conflict.  */
  #if !STDC_HEADERS && HAVE_MEMORY_H
    #include <memory.h>
  #endif /* not STDC_HEADERS and HAVE_MEMORY_H */

  /* On NeXTStep 3.2, following #undef suppresses a warning: */
  #undef  bzero
  #define bzero(s, n) memset ((s), 0, (n))

#else /* not STDC_HEADERS and not HAVE_STRING_H */

  /* memory.h and strings.h conflict on some systems.  */
  #include <strings.h>

  /* Haven't run into actual need for following */
  /* #undefs, but they can't hurt:              */

  #undef  strchr
  #define strchr index

  #undef  strchr
  #define strrchr rindex 

  #undef  memcpy
  #define memcpy(d, s, n) bcopy ((s), (d), (n))

  #undef  memcmp
  #define memcmp(s1, s2, n) bcmp ((s1), (s2), (n)) 

#endif /* not STDC_HEADERS and not HAVE_STRING_H */

/* Can't find a way to get NEXTSTEP 3.2 to  */
/* declare unlink(), so I just hardwire it: */
extern int unlink( const char *path );

/* The  INADDR_NONE constant is used with inet_addr().  */
/* Irix defines it in /usr/include/netinet/in.h.        */
/*							*/
/* Linux apparently defines it, since use of it doesn't */
/* draw a compile error, but I can't figure out where:  */
/* It shows up under /usr/src/linux* but not under	*/
/* /usr/include/* ?!					*/
/*							*/
/* Solaris appears to not define it at all.             */
/*							*/
/* Cover our portability bets by defining it if missing:*/
#ifndef INADDR_NONE
#define INADDR_NONE (-1)
#endif

#include "vm.h"


/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_HAX_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

