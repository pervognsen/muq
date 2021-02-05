@example  @c
/*--   cfg.c -- ConFiGuration interface objects for Muq.		*/
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
/* Created:      95May18						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1996, by Jeff Prothero.				*/
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
static Vm_Unt   sizeof_cfg( Vm_Unt );

static Vm_Obj   cfg_have_rusage_ru_stime_tv_usec( Vm_Obj );
static Vm_Obj   cfg_have_rusage_ru_stime_tv_nsec( Vm_Obj );
static Vm_Obj   cfg_have_rusage_ru_utime_tv_usec( Vm_Obj );
static Vm_Obj   cfg_have_rusage_ru_utime_tv_nsec( Vm_Obj );
static Vm_Obj   cfg_have_alloca( Vm_Obj );
static Vm_Obj   cfg_have_alloca_h( Vm_Obj );
static Vm_Obj   cfg_have_doprnt( Vm_Obj );
static Vm_Obj   cfg_have_tm_zone( Vm_Obj );
static Vm_Obj   cfg_have_tzname( Vm_Obj );
static Vm_Obj   cfg_have_vfork_h( Vm_Obj );
static Vm_Obj   cfg_have_vprintf( Vm_Obj );
static Vm_Obj   cfg_have_getrusage( Vm_Obj );
static Vm_Obj   cfg_have_libm( Vm_Obj );
static Vm_Obj   cfg_have_drand48( Vm_Obj );
static Vm_Obj   cfg_have_getpagesize( Vm_Obj );
static Vm_Obj   cfg_have_gettimeofday( Vm_Obj );
static Vm_Obj   cfg_have_memmove( Vm_Obj );
static Vm_Obj   cfg_have_memset( Vm_Obj );
static Vm_Obj   cfg_have_opengl( Vm_Obj );
static Vm_Obj   cfg_have_random( Vm_Obj );
static Vm_Obj   cfg_have_srand48( Vm_Obj );
static Vm_Obj   cfg_have_srandom( Vm_Obj );
static Vm_Obj   cfg_have_sysconf( Vm_Obj );
static Vm_Obj   cfg_have_arpa_inet_h( Vm_Obj );
static Vm_Obj   cfg_have_ctype_h( Vm_Obj );
static Vm_Obj   cfg_have_dirent_h( Vm_Obj );
static Vm_Obj   cfg_have_errno_h( Vm_Obj );
static Vm_Obj   cfg_have_fcntl_h( Vm_Obj );
static Vm_Obj   cfg_have_libc_h( Vm_Obj );
static Vm_Obj   cfg_have_limits_h( Vm_Obj );
static Vm_Obj   cfg_have_malloc_h( Vm_Obj );
static Vm_Obj   cfg_have_math_h( Vm_Obj );
static Vm_Obj   cfg_have_memory_h( Vm_Obj );
static Vm_Obj   cfg_have_ndir_h( Vm_Obj );
static Vm_Obj   cfg_have_netdb_h( Vm_Obj );
static Vm_Obj   cfg_have_netinet_in_h( Vm_Obj );
static Vm_Obj   cfg_have_setjmp_h( Vm_Obj );
static Vm_Obj   cfg_have_signal_h( Vm_Obj );
static Vm_Obj   cfg_have_stdarg_h( Vm_Obj );
static Vm_Obj   cfg_have_stdlib_h( Vm_Obj );
static Vm_Obj   cfg_have_string_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_dir_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_file_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_ioctl_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_ndir_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_param_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_resource_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_rusage_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_select_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_socket_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_stat_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_time_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_times_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_types_h( Vm_Obj );
static Vm_Obj   cfg_have_sys_wait_h( Vm_Obj );
static Vm_Obj   cfg_have_time_h( Vm_Obj );
static Vm_Obj   cfg_have_unistd_h( Vm_Obj );
static Vm_Obj   cfg_have_utime_h( Vm_Obj );
static Vm_Obj   cfg_have_x11( Vm_Obj );
static Vm_Obj   cfg_have_libc( Vm_Obj );
static Vm_Obj   cfg_have_libglut( Vm_Obj );
static Vm_Obj   cfg_have_libnsl( Vm_Obj );
static Vm_Obj   cfg_have_libsocket( Vm_Obj );
static Vm_Obj   cfg_have_libsun( Vm_Obj );

static Vm_Obj	cfg_set_never(             Vm_Obj, Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header cfgtem properties: */
static Obj_A_Special_Property cfg_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

/* Special properties on this class: */

{0,"haveAlloca",cfg_have_alloca, cfg_set_never },
{0,"haveAllocaH",cfg_have_alloca_h, cfg_set_never },
{0,"haveArpaInetH",cfg_have_arpa_inet_h, cfg_set_never },
{0,"haveCtypeH",cfg_have_ctype_h, cfg_set_never },
{0,"haveDirentH",cfg_have_dirent_h, cfg_set_never },
{0,"haveDoprnt",cfg_have_doprnt, cfg_set_never },
{0,"haveDrand48",cfg_have_drand48, cfg_set_never },
{0,"haveErrnoH",cfg_have_errno_h, cfg_set_never },
{0,"haveFcntlH",cfg_have_fcntl_h, cfg_set_never },
{0,"haveGetpagesize",cfg_have_getpagesize, cfg_set_never },
{0,"haveGetrusage",cfg_have_getrusage, cfg_set_never },
{0,"haveGettimeofday",cfg_have_gettimeofday, cfg_set_never },
{0,"haveLibc",cfg_have_libc, cfg_set_never },
{0,"haveLibcH",cfg_have_libc_h, cfg_set_never },
{0,"haveLibglut",cfg_have_libglut, cfg_set_never },
{0,"haveLibm",cfg_have_libm, cfg_set_never },
{0,"haveLibnsl",cfg_have_libnsl, cfg_set_never },
{0,"haveLibsocket",cfg_have_libsocket, cfg_set_never },
{0,"haveLibsun",cfg_have_libsun, cfg_set_never },
{0,"haveLimitsH",cfg_have_limits_h, cfg_set_never },
{0,"haveMallocH",cfg_have_malloc_h, cfg_set_never },
{0,"haveMathH",cfg_have_math_h, cfg_set_never },
{0,"haveMemmove",cfg_have_memmove, cfg_set_never },
{0,"haveMemoryH",cfg_have_memory_h, cfg_set_never },
{0,"haveMemset",cfg_have_memset, cfg_set_never },
{0,"haveNdirH",cfg_have_ndir_h, cfg_set_never },
{0,"haveNetdbH",cfg_have_netdb_h, cfg_set_never },
{0,"haveNetinetInH",cfg_have_netinet_in_h, cfg_set_never },
{0,"haveOpenGL",cfg_have_opengl, cfg_set_never },
{0,"haveRandom",cfg_have_random, cfg_set_never },
{0,"haveRusageRuStimeTvNsec",cfg_have_rusage_ru_stime_tv_nsec, cfg_set_never },
{0,"haveRusageRuStimeTvUsec",cfg_have_rusage_ru_stime_tv_usec, cfg_set_never },
{0,"haveRusageRuUtimeTvNsec",cfg_have_rusage_ru_utime_tv_nsec, cfg_set_never },
{0,"haveRusageRuUtimeTvUsec",cfg_have_rusage_ru_utime_tv_usec, cfg_set_never },
{0,"haveSetjmpH",cfg_have_setjmp_h, cfg_set_never },
{0,"haveSignalH",cfg_have_signal_h, cfg_set_never },
{0,"haveSrand48",cfg_have_srand48, cfg_set_never },
{0,"haveSrandom",cfg_have_srandom, cfg_set_never },
{0,"haveStdargH",cfg_have_stdarg_h, cfg_set_never },
{0,"haveStdlibH",cfg_have_stdlib_h, cfg_set_never },
{0,"haveStringH",cfg_have_string_h, cfg_set_never },
{0,"haveSysDirH",cfg_have_sys_dir_h, cfg_set_never },
{0,"haveSysFileH",cfg_have_sys_file_h, cfg_set_never },
{0,"haveSysIoctlH",cfg_have_sys_ioctl_h, cfg_set_never },
{0,"haveSysNdirH",cfg_have_sys_ndir_h, cfg_set_never },
{0,"haveSysParamH",cfg_have_sys_param_h, cfg_set_never },
{0,"haveSysResourceH",cfg_have_sys_resource_h, cfg_set_never },
{0,"haveSysRusageH",cfg_have_sys_rusage_h, cfg_set_never },
{0,"haveSysSelectH",cfg_have_sys_select_h, cfg_set_never },
{0,"haveSysSocketH",cfg_have_sys_socket_h, cfg_set_never },
{0,"haveSysStatH",cfg_have_sys_stat_h, cfg_set_never },
{0,"haveSysTimeH",cfg_have_sys_time_h, cfg_set_never },
{0,"haveSysTimesH",cfg_have_sys_times_h, cfg_set_never },
{0,"haveSysTypesH",cfg_have_sys_types_h, cfg_set_never },
{0,"haveSysWaitH",cfg_have_sys_wait_h, cfg_set_never },
{0,"haveSysconf",cfg_have_sysconf, cfg_set_never },
{0,"haveTimeH",cfg_have_time_h, cfg_set_never },
{0,"haveTmZone",cfg_have_tm_zone, cfg_set_never },
{0,"haveTzname",cfg_have_tzname, cfg_set_never },
{0,"haveUnistdH",cfg_have_unistd_h, cfg_set_never },
{0,"haveUtimeH",cfg_have_utime_h, cfg_set_never },
{0,"haveVforkH",cfg_have_vfork_h, cfg_set_never },
{0,"haveVprintf",cfg_have_vprintf, cfg_set_never },
{0,"haveX11",cfg_have_x11, cfg_set_never },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class cfg_Hardcoded_Class = {
    OBJ_FROM_BYT3('c','f','g'),
    "MuqConfiguration",
    sizeof_cfg,
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
    { cfg_system_properties, cfg_system_properties, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};


static void cfg_doTypes(void){}
Obj_A_Module_Summary cfg_Module_Summary = {
    "cfg",
    cfg_doTypes,
    cfg_Startup,
    cfg_Linkup,
    cfg_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/




/************************************************************************/
/*-    cfg_Sprint  -- Debug dump of cfg state, multi-line format.	*/
/************************************************************************/

Vm_Uch*
cfg_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  cfg
) {
#ifdef SOMETIME
    Cfg_P  s   = CFG_P(cfg);
    int sp  = (int)OBJ_TO_INT(s->sp);
    int i;
    int lo  = (s->fn == OBJ_FROM_INT(2))  ?  2  :  0;
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
/*-    cfg_Startup -- start-of-world stuff.				*/
/************************************************************************/


/************************************************************************/
/*-    maybe_reinsert_slash_cfg -- Validate /cfg.			*/
/************************************************************************/

static void
maybe_reinsert_slash_cfg( void ) {

    Vm_Obj cfg = obj_Get( vm_Root(0), sym_Alloc_Asciz_Keyword("cfg") );
    if (cfg==OBJ_NOT_FOUND || !OBJ_IS_CLASS_CFG(cfg)) {
	cfg  = obj_Alloc( OBJ_CLASS_A_CFG, 0 );
        OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("cfg"), cfg, OBJ_PROP_PUBLIC );
        OBJ_P(cfg)->objname = stg_From_Asciz("/cfg");  vm_Dirty(cfg);
    }
}



void
cfg_Startup(
    void
){
    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;

    maybe_reinsert_slash_cfg();
}



/************************************************************************/
/*-    cfg_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
cfg_Linkup(
    void
){

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		     = TRUE;
}



/************************************************************************/
/*-    cfg_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
cfg_Shutdown(
    void
){

    static int done_shutdown = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	     = TRUE;
}


#ifdef SOON

/************************************************************************/
/*-    cfg_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
cfg_Import(
    FILE* fd
) {
    MUQ_FATAL ("cfg_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    cfg_Export -- Write object into textfile.			*/
/************************************************************************/

void
cfg_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("cfg_Export unimplemented");
}


#endif

/************************************************************************/
/*-    cfg_Invariants -- Sanity check on cfg.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
cfg_Invariants(
    FILE*   errlog,
    Vm_Uch* title,
    Vm_Obj  cfg
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, cfg );
#endif
    return errs;
}


/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/




/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/



/************************************************************************/
/*-    for_new -- Initialize new cfg object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
}



/************************************************************************/
/*-    sizeof_cfg -- Return size of package.				*/
/************************************************************************/

static Vm_Unt
sizeof_cfg(
    Vm_Unt size
){
    return sizeof( Cfg_A_Header );
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj  cfg
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif





/************************************************************************/
/*-    --- Static propfns --						*/
/************************************************************************/




/************************************************************************/
/*-    cfg_have_rusage_ru_stime_tv_usec					*/
/************************************************************************/

static Vm_Obj
cfg_have_rusage_ru_stime_tv_usec(
    Vm_Obj o
) {
#ifdef HAVE_RUSAGE_RU_STIME_TV_USEC
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_rusage_ru_stime_tv_nsec					*/
/************************************************************************/

static Vm_Obj
cfg_have_rusage_ru_stime_tv_nsec(
    Vm_Obj o
) {
#ifdef HAVE_RUSAGE_RU_STIME_TV_NSEC
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_rusage_ru_utime_tv_usec					*/
/************************************************************************/

static Vm_Obj
cfg_have_rusage_ru_utime_tv_usec(
    Vm_Obj o
) {
#ifdef HAVE_RUSAGE_RU_UTIME_TV_USEC
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_rusage_ru_utime_tv_nsec					*/
/************************************************************************/

static Vm_Obj
cfg_have_rusage_ru_utime_tv_nsec(
    Vm_Obj o
) {
#ifdef HAVE_RUSAGE_RU_UTIME_TV_NSEC
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_alloca							*/
/************************************************************************/

static Vm_Obj
cfg_have_alloca(
    Vm_Obj o
) {
#ifdef HAVE_ALLOCA
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_alloca_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_alloca_h(
    Vm_Obj o
) {
#ifdef HAVE_ALLOCA_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_doprnt							*/
/************************************************************************/

static Vm_Obj
cfg_have_doprnt(
    Vm_Obj o
) {
#ifdef HAVE_DOPRNT
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_tm_zone							*/
/************************************************************************/

static Vm_Obj
cfg_have_tm_zone(
    Vm_Obj o
) {
#ifdef HAVE_TM_ZONE
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_tzname							*/
/************************************************************************/

static Vm_Obj
cfg_have_tzname(
    Vm_Obj o
) {
#ifdef HAVE_TZNAME
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_vfork_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_vfork_h(
    Vm_Obj o
) {
#ifdef HAVE_VFORK_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_vprintf							*/
/************************************************************************/

static Vm_Obj
cfg_have_vprintf(
    Vm_Obj o
) {
#ifdef HAVE_VPRINTF
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_x11							*/
/************************************************************************/

static Vm_Obj
cfg_have_x11(
    Vm_Obj o
) {
#ifdef HAVE_X11
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_libm							*/
/************************************************************************/

static Vm_Obj
cfg_have_libm(
    Vm_Obj o
) {
#ifdef HAVE_LIBM
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_drand48							*/
/************************************************************************/

static Vm_Obj
cfg_have_drand48(
    Vm_Obj o
) {
#ifdef HAVE_DRAND48
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_getpagesize						*/
/************************************************************************/

static Vm_Obj
cfg_have_getpagesize(
    Vm_Obj o
) {
#ifdef HAVE_GETPAGESIZE
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_getrusage						*/
/************************************************************************/

static Vm_Obj
cfg_have_getrusage(
    Vm_Obj o
) {
#ifdef HAVE_GETRUSAGE
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_gettimeofday						*/
/************************************************************************/

static Vm_Obj
cfg_have_gettimeofday(
    Vm_Obj o
) {
#ifdef HAVE_GETTIMEOFDAY
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_memmove							*/
/************************************************************************/

static Vm_Obj
cfg_have_memmove(
    Vm_Obj o
) {
#ifdef HAVE_MEMMOVE
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_memset							*/
/************************************************************************/

static Vm_Obj
cfg_have_memset(
    Vm_Obj o
) {
#ifdef HAVE_MEMSET
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_opengl							*/
/************************************************************************/

static Vm_Obj
cfg_have_opengl(
    Vm_Obj o
) {
#ifdef HAVE_OPENGL
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_random							*/
/************************************************************************/

static Vm_Obj
cfg_have_random(
    Vm_Obj o
) {
#ifdef HAVE_RANDOM
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_srand48							*/
/************************************************************************/

static Vm_Obj
cfg_have_srand48(
    Vm_Obj o
) {
#ifdef HAVE_SRAND48
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_srandom							*/
/************************************************************************/

static Vm_Obj
cfg_have_srandom(
    Vm_Obj o
) {
#ifdef HAVE_SRANDOM
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sysconf							*/
/************************************************************************/

static Vm_Obj
cfg_have_sysconf(
    Vm_Obj o
) {
#ifdef HAVE_SYSCONF
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_arpa_inet_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_arpa_inet_h(
    Vm_Obj o
) {
#ifdef HAVE_ARPA_INET_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_ctype_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_ctype_h(
    Vm_Obj o
) {
#ifdef HAVE_CTYPE_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_dirent_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_dirent_h(
    Vm_Obj o
) {
#ifdef HAVE_DIRENT_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_errno_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_errno_h(
    Vm_Obj o
) {
#ifdef HAVE_ERRNO_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_fcntl_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_fcntl_h(
    Vm_Obj o
) {
#ifdef HAVE_FCNTL_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_libc_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_libc_h(
    Vm_Obj o
) {
#ifdef HAVE_LIBC_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_limits_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_limits_h(
    Vm_Obj o
) {
#ifdef HAVE_LIMITS_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_malloc_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_malloc_h(
    Vm_Obj o
) {
#ifdef HAVE_MALLOC_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_math_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_math_h(
    Vm_Obj o
) {
#ifdef HAVE_MATH_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_memory_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_memory_h(
    Vm_Obj o
) {
#ifdef HAVE_MEMORY_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_ndir_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_ndir_h(
    Vm_Obj o
) {
#ifdef HAVE_NDIR_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_netdb_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_netdb_h(
    Vm_Obj o
) {
#ifdef HAVE_NETDB_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_netinet_in_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_netinet_in_h(
    Vm_Obj o
) {
#ifdef HAVE_NETINET_IN_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_setjmp_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_setjmp_h(
    Vm_Obj o
) {
#ifdef HAVE_SETJMP_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_signal_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_signal_h(
    Vm_Obj o
) {
#ifdef HAVE_SIGNAL_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_stdarg_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_stdarg_h(
    Vm_Obj o
) {
#ifdef HAVE_STDARG_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_stdlib_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_stdlib_h(
    Vm_Obj o
) {
#ifdef HAVE_STDLIB_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_string_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_string_h(
    Vm_Obj o
) {
#ifdef HAVE_STRING_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_dir_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_dir_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_DIR_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_file_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_file_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_FILE_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_ioctl_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_ioctl_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_IOCTL_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_ndir_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_ndir_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_NDIR_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_param_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_param_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_PARAM_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_resource_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_resource_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_RESOURCE_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_rusage_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_rusage_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_RUSAGE_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_select_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_select_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_SELECT_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_socket_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_socket_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_SOCKET_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_stat_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_stat_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_STAT_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_time_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_time_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_TIME_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_times_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_times_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_TIMES_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_types_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_types_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_TYPES_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_sys_wait_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_sys_wait_h(
    Vm_Obj o
) {
#ifdef HAVE_SYS_WAIT_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_time_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_time_h(
    Vm_Obj o
) {
#ifdef HAVE_TIME_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_unistd_h						*/
/************************************************************************/

static Vm_Obj
cfg_have_unistd_h(
    Vm_Obj o
) {
#ifdef HAVE_UNISTD_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_utime_h							*/
/************************************************************************/

static Vm_Obj
cfg_have_utime_h(
    Vm_Obj o
) {
#ifdef HAVE_UTIME_H
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_libc							*/
/************************************************************************/

static Vm_Obj
cfg_have_libc(
    Vm_Obj o
) {
#ifdef HAVE_LIBC
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_libglut							*/
/************************************************************************/

static Vm_Obj
cfg_have_libglut(
    Vm_Obj o
) {
#ifdef HAVE_LIBGLUT
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_libnsl							*/
/************************************************************************/

static Vm_Obj
cfg_have_libnsl(
    Vm_Obj o
) {
#ifdef HAVE_LIBNSL
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_libsocket						*/
/************************************************************************/

static Vm_Obj
cfg_have_libsocket(
    Vm_Obj o
) {
#ifdef HAVE_LIBSOCKET
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}

/************************************************************************/
/*-    cfg_have_libsun							*/
/************************************************************************/

static Vm_Obj
cfg_have_libsun(
    Vm_Obj o
) {
#ifdef HAVE_LIBSUN
    return OBJ_T;
#else
    return OBJ_NIL;
#endif
}



/************************************************************************/
/*-    cfg_set_never	 						*/
/************************************************************************/

static Vm_Obj
cfg_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
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
