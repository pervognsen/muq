
/* --- Start hardwired Muq-specific additions to Config.h --- */

/* #define 'AC_FCNTL_SET_NONBLOCKING' as */
/* local set-nonblocking fcntl opcode:   */
#ifdef                                   FNONBLOCK
    #define     AC_FCNTL_SET_NONBLOCKING FNONBLOCK /* Preferred Posix name. */
#else
    #ifdef                               O_NDELAY
        #define AC_FCNTL_SET_NONBLOCKING O_NDELAY  /* Sys5 name.  */
    #else
        #define AC_FCNTL_SET_NONBLOCKING FNDELAY   /* BSD name.   */
    #endif
#endif

/* (Nonblockingmagic Whitefire uses in Fuzzball */
/* 5.x just for possible future reference:)     */
#ifdef CRIB
#if defined(O_NONBLOCK) && !defined(ULTRIX)
    #define	    AC_FCNTL_SET_NONBLOCKING O_NONBLOCK	/* POSIX */
#else
    #ifdef FNDELAY 	           
	#define     AC_FCNTL_SET_NONBLOCKING FNDELAY	/* SunOS */
    #else
	#ifdef O_NDELAY 	
	    #define AC_FCNTL_SET_NONBLOCKING O_NDELAY	/* SysV */
	#endif
    #endif
#endif
#endif

#undef HAVE_X11
#undef HAVE_GETRUSAGE
#undef HAVE_RUSAGE_RU_STIME_TV_USEC
#undef HAVE_RUSAGE_RU_STIME_TV_NSEC
#undef HAVE_RUSAGE_RU_UTIME_TV_USEC
#undef HAVE_RUSAGE_RU_UTIME_TV_NSEC
#undef HAVE_ZERO_SETPGRP_ARGS

/* So far, 1 system in 6 has getpagesize(): */
/* DO NOT EDIT THIS STUFF IN Config.h.in!   */
/* It is automatically generated from       */
/* muq/c/acconfig.h, edit the latter.       */
#undef NEED__FILBUF_PROTO	/* Need.h stuff. */
#undef NEED__FLSBUF_PROTO	/* Need.h stuff. */
#undef NEED_ACCEPT_PROTO	/* Need.h stuff. */
#undef NEED_BCOPY_PROTO		/* Need.h stuff. */
#undef NEED_BIND_PROTO		/* Need.h stuff. */
#undef NEED_BZERO_PROTO		/* Need.h stuff. */
#undef NEED_CONNECT_PROTO	/* Need.h stuff. */
#undef NEED_CRYPT_PROTO		/* Need.h stuff. */
#undef NEED_DRAND48_PROTO	/* Need.h stuff. */
#undef NEED_FCLOSE_PROTO	/* Need.h stuff. */
#undef NEED_FFLUSH_PROTO	/* Need.h stuff. */
#undef NEED_FGETC_PROTO		/* Need.h stuff. */
#undef NEED_FPRINTF_PROTO	/* Need.h stuff. */
#undef NEED_FPUTC_PROTO		/* Need.h stuff. */
#undef NEED_FPUTS_PROTO		/* Need.h stuff. */
#undef NEED_FREAD_PROTO		/* Need.h stuff. */
#undef NEED_FSCANF_PROTO	/* Need.h stuff. */
#undef NEED_FWRITE_PROTO	/* Need.h stuff. */
#undef NEED_GETDTABLESIZE_PROTO	/* Need.h stuff. */
#undef NEED_GETHOSTNAME_PROTO	/* Need.h stuff. */
#undef NEED_GETPAGESIZE_PROTO	/* Need.h stuff. */
#undef NEED_GETRUSAGE_PROTO	/* Need.h stuff. */
#undef NEED_GETSOCKNAME_PROTO	/* Need.h stuff. */
#undef NEED_GETTIMEOFDAY_PROTO	/* Need.h stuff. */
#undef NEED_LISTEN_PROTO	/* Need.h stuff. */
#undef NEED_MEMMOVE_PROTO	/* Need.h stuff. */
#undef NEED_MEMSET_PROTO	/* Need.h stuff. */
#undef NEED_PCLOSE_PROTO	/* Need.h stuff. */
#undef NEED_PRINTF_PROTO	/* Need.h stuff. */
#undef NEED_PUTS_PROTO		/* Need.h stuff. */
#undef NEED_RANDOM_PROTO	/* Need.h stuff. */
#undef NEED_RECVFROM_PROTO	/* Need.h stuff. */
#undef NEED_REMOVE_PROTO	/* Need.h stuff. */
#undef NEED_RENAME_PROTO	/* Need.h stuff. */
#undef NEED_REWIND_PROTO	/* Need.h stuff. */
#undef NEED_SBRK_PROTO		/* Need.h stuff. */
#undef NEED_SELECT_PROTO	/* Need.h stuff. */
#undef NEED_SENDTO_PROTO	/* Need.h stuff. */
#undef NEED_SETSOCKOPT_PROTO	/* Need.h stuff. */
#undef NEED_SHUTDOWN_PROTO	/* Need.h stuff. */
#undef NEED_SOCKET_PROTO	/* Need.h stuff. */
#undef NEED_SRAND48_PROTO	/* Need.h stuff. */
#undef NEED_SRANDOM_PROTO	/* Need.h stuff. */
#undef NEED_SSCANF_PROTO	/* Need.h stuff. */
#undef NEED_STRCASECMP_PROTO	/* Need.h stuff. */
#undef NEED_SYSCONF_PROTO	/* Need.h stuff. */
#undef NEED_SYSTEM_PROTO	/* Need.h stuff. */
#undef NEED_TIME_PROTO		/* Need.h stuff. */
#undef NEED_TIMES_PROTO		/* Need.h stuff. */
#undef NEED_TOLOWER_PROTO	/* Need.h stuff. */
#undef NEED_TOUPPER_PROTO	/* Need.h stuff. */
#undef NEED_VSPRINTF_PROTO	/* Need.h stuff. */

/* --- End hardwired Muq-specific additions to Config.h --- */
@TOP@

/* Define if this system has libm.a  */
#undef HAVE_LIBM
#undef HAVE_LIBGLUT
#undef HAVE_LIBGTK

