/* might add "gethostid()" in here sometime... */
/* also  add "gethostname()". */
/* and mebbe "getdomainname()". */
/* Comer's book covers the nameserver library fns nicely, */
/* but we definitely want those in a separate process... */
@example  @c
/*--   sys.c -- SYStem interface objects for Muq.			*/
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
/* Created:      94Mar04						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1995, by Jeff Prothero.				*/
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
static Vm_Unt   sizeof_sys( Vm_Unt );

static Vm_Obj	sys_hostname(                Vm_Obj          );
static Vm_Obj	sys_dns_name(                Vm_Obj          );
static Vm_Obj	sys_dns_addr(                Vm_Obj          );
static Vm_Obj	sys_ip0(                     Vm_Obj          );
static Vm_Obj	sys_ip1(                     Vm_Obj          );
static Vm_Obj	sys_ip2(                     Vm_Obj          );
static Vm_Obj	sys_ip3(                     Vm_Obj          );
static Vm_Obj	sys_pid(                     Vm_Obj          );
static Vm_Obj	sys_page_size(               Vm_Obj          );
#if VM_INTBYTES > 4
static Vm_Obj   sys_millisecs_since_1970(    Vm_Obj          );
#else
static Vm_Obj	sys_secs_since_1970(         Vm_Obj          );
#endif
static Vm_Obj	sys_date_usecs(              Vm_Obj          );

static Vm_Obj	sys_usermode_cpu_secs(            Vm_Obj          );
static Vm_Obj	sys_usermode_cpu_nsecs(           Vm_Obj          );
static Vm_Obj	sys_sysmode_cpu_secs(             Vm_Obj          );
static Vm_Obj	sys_sysmode_cpu_nsecs(            Vm_Obj          );
static Vm_Obj	sys_max_rss(                      Vm_Obj          );
static Vm_Obj	sys_muq_port(                     Vm_Obj          );
static Vm_Obj	sys_page_reclaims(                Vm_Obj          );
static Vm_Obj	sys_page_faults(                  Vm_Obj          );
static Vm_Obj	sys_swapouts(                     Vm_Obj          );
static Vm_Obj	sys_block_reads(                  Vm_Obj          );
static Vm_Obj	sys_block_writes(                 Vm_Obj          );
static Vm_Obj	sys_voluntary_ctxt_switches(      Vm_Obj          );
static Vm_Obj	sys_involuntary_ctxt_switches(    Vm_Obj          );
static Vm_Obj	sys_end_of_data_segment(	  Vm_Obj          );

static Vm_Obj	sys_set_never(               Vm_Obj, Vm_Obj );
static Vm_Obj	sys_set_muq_port(            Vm_Obj, Vm_Obj );
static Vm_Obj	sys_set_ip0(                 Vm_Obj, Vm_Obj );
static Vm_Obj	sys_set_ip1(                 Vm_Obj, Vm_Obj );
static Vm_Obj	sys_set_ip2(                 Vm_Obj, Vm_Obj );
static Vm_Obj	sys_set_ip3(                 Vm_Obj, Vm_Obj );

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

Vm_Int   sys_Ip0 = 127;
Vm_Int   sys_Ip1 =   0;
Vm_Int   sys_Ip2 =   0;
Vm_Int   sys_Ip3 =   1;

Vm_Int   sys_Muq_Port = 30000;

/* Description of standard-header system properties: */
static Obj_A_Special_Property sys_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

/* Special properties on this class: */
{0,"hostName"	, sys_hostname          , sys_set_never },
{0,"dnsName"	, sys_dns_name          , sys_set_never },
{0,"dnsAddress", sys_dns_addr          , sys_set_never },
{0,"muqPort"   , sys_muq_port          , sys_set_muq_port },
{0,"ip0"	, sys_ip0               , sys_set_ip0   },
{0,"ip1"	, sys_ip1               , sys_set_ip1   },
{0,"ip2"	, sys_ip2               , sys_set_ip2   },
{0,"ip3"	, sys_ip3               , sys_set_ip3   },
{0,"pageSize"	, sys_page_size         , sys_set_never },
{0,"pid"	, sys_pid               , sys_set_never },
#if VM_INTBYTES > 4
{0,"millisecsSince1970",sys_millisecs_since_1970, sys_set_never },
#else
{0,"secsSince1970",sys_secs_since_1970, sys_set_never },
#endif
{0,"dateMicroseconds",sys_date_usecs   , sys_set_never },

{0,"usermodeCpuNanoseconds",sys_usermode_cpu_nsecs	, sys_set_never	},
{0,"usermodeCpuSeconds",sys_usermode_cpu_secs	, sys_set_never	},
{0,"sysmodeCpuNanoseconds",sys_sysmode_cpu_nsecs	, sys_set_never	},
{0,"sysmodeCpuSeconds", sys_sysmode_cpu_secs	, sys_set_never	},
{0,"maxRss"		, sys_max_rss		, sys_set_never	},
{0,"pageReclaims"	, sys_page_reclaims	, sys_set_never	},
{0,"pageFaults"	, sys_page_faults	, sys_set_never	},
{0,"swapOuts"		, sys_swapouts		, sys_set_never	},
{0,"blockReads"	, sys_block_reads	, sys_set_never	},
{0,"blockWrites"	, sys_block_writes	, sys_set_never	},
{0,"voluntaryContextSwitches", sys_voluntary_ctxt_switches, sys_set_never},
{0,"involuntaryContextSwitches",sys_involuntary_ctxt_switches,sys_set_never},
{0,"endOfDataSegment",sys_end_of_data_segment, sys_set_never	},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class sys_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','y','s'),
    "SystemInterface",
    sizeof_sys,
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
    { sys_system_properties, sys_system_properties, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void sys_doTypes(void){}
Obj_A_Module_Summary sys_Module_Summary = {
   "sys",
    sys_doTypes,
    sys_Startup,
    sys_Linkup,
    sys_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/




/************************************************************************/
/*-    sys_Sprint  -- Debug dump of sys state, multi-line format.	*/
/************************************************************************/

Vm_Uch*
sys_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  sys
) {
#ifdef SOMETIME
    Sys_P  s   = SYS_P(sys);
    Vm_Int sp  = OBJ_TO_INT(s->sp);
    Vm_Int i;
    Vm_Int lo  = (s->fn == OBJ_FROM_INT(2))  ?  2  :  0;
    for (i = sp;   i >= lo;   --i) {
	Vm_Obj*  j = &s->stack[i];
	Vm_Obj   o = *j;
	buf  = lib_Sprint(buf,lim, "%d: ", (int)(i-lo) );
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
/*-    sys_Startup -- start-of-world stuff.				*/
/************************************************************************/


 /***********************************************************************/
 /*-   maybe_reinsert_slash_sys -- Validate /sys.			*/
 /***********************************************************************/

static Vm_Obj
maybe_reinsert_slash_sys(
    void
){

    Vm_Obj sys = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("sys"), OBJ_PROP_PUBLIC );
    if (sys==OBJ_NOT_FOUND || !OBJ_IS_CLASS_SYS(sys)) {
	sys  = obj_Alloc( OBJ_CLASS_A_SYS, 0 );
        OBJ_SET( vm_Root(0), sym_Alloc_Asciz_Keyword("sys"), sys, OBJ_PROP_PUBLIC );
        OBJ_P(sys)->objname = stg_From_Asciz("/sys");  vm_Dirty(sys);
    }
    return sys;
}

 /***********************************************************************/
 /*-   set_host_name_and_ip_address					*/
 /***********************************************************************/

static void
note_host_name_and_ip_address(
    Vm_Obj sys
){
    Vm_Uch           hostname[ 256 ];
    Vm_Uch           dns_addr[ 256 ];
    if (gethostname( hostname, 256 )) {
	strcpy(      hostname, "localhost" );
    }
    hostname[255] = '\0';	/* Cheap insurance. */
    SYS_P(sys)->hostname = stg_From_Asciz( hostname );   vm_Dirty(sys);

    sys_Muq_Port  = OBJ_TO_INT( SYS_P(sys)->muq_port );

    {   struct hostent* host = gethostbyname( hostname );
	if (host
	/* Both of these tests should always be true */
	/* until the next-generation IP arrives:     */
        #ifdef AF_INET
	&&  host->h_addrtype == AF_INET
	#endif
        #ifdef PF_INET
	&&  host->h_addrtype == PF_INET
	#endif
	&&  host->h_length   == 4
        ){
	    sys_Ip0 = (unsigned char) host->h_addr[0];
	    sys_Ip1 = (unsigned char) host->h_addr[1];
	    sys_Ip2 = (unsigned char) host->h_addr[2];
	    sys_Ip3 = (unsigned char) host->h_addr[3];
	    {   Sys_P p = SYS_P(sys);
		p->ip0 = OBJ_FROM_INT( sys_Ip0 );
		p->ip1 = OBJ_FROM_INT( sys_Ip1 );
		p->ip2 = OBJ_FROM_INT( sys_Ip2 );
		p->ip3 = OBJ_FROM_INT( sys_Ip3 );
		vm_Dirty(sys);
	    }
	}
	sprintf( dns_addr, "%d.%d.%d.%d", (int)sys_Ip0, (int)sys_Ip1, (int)sys_Ip2, (int)sys_Ip3 );
	SYS_P(sys)->dns_addr = stg_From_Asciz( dns_addr );   vm_Dirty(sys);

	{   u_long our_addr = (
		(sys_Ip0 << 24) |
		(sys_Ip1 << 16) |
		(sys_Ip2 <<  8) |
		(sys_Ip3      )
	    );
	    u_long net_addr = htonl( our_addr );
	    host = gethostbyaddr(
		(char*)(&net_addr),
		4,	/* length in bytes of above */
		#ifdef AF_INET
		AF_INET
		#else
		#ifdef PF_INET
		PF_INET
		#else
		2	/* Broken headers -- make rational guess. */
		#endif
		#endif
	    );
	    if (host) {
		SYS_P(sys)->dns_name = stg_From_Asciz( (Vm_Uch*)host->h_name );
	    } else {
		SYS_P(sys)->dns_name = SYS_P(sys)->dns_addr;
	    }
	    vm_Dirty(sys);
	}
    }    
}

 /***********************************************************************/
 /*-   sys_Startup -- start-of-world stuff.				*/
 /***********************************************************************/



void
sys_Startup(
    void
){
    Vm_Obj sys;

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    sys = maybe_reinsert_slash_sys();
    note_host_name_and_ip_address( sys );
}



/************************************************************************/
/*-    sys_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
sys_Linkup(
    void
){

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    sys_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
sys_Shutdown(
    void
){

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}


#ifdef SOON

/************************************************************************/
/*-    sys_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
sys_Import(
    FILE* fd
) {
    MUQ_FATAL ("sys_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    sys_Export -- Write object into textfile.			*/
/************************************************************************/

void
sys_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("sys_Export unimplemented");
}


#endif

/************************************************************************/
/*-    sys_Invariants -- Sanity check on sys.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
sys_Invariants(
    FILE*   errlog,
    Vm_Uch* title,
    Vm_Obj  sys
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, sys );
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
/*-    for_new -- Initialize new sys object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Sys_P p = SYS_P(o);
    p->hostname = OBJ_NIL;
    p->dns_name = OBJ_NIL;
    p->dns_addr = OBJ_NIL;
    p->muq_port = OBJ_FROM_INT( 30000 );
    {   int i;
	for (i = SYS_RESERVED_SLOTS;  i --> 0; ) p->reserved_slot[i] = OBJ_FROM_INT(0);
    }
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_sys -- Return size of package.				*/
/************************************************************************/

static Vm_Unt
sizeof_sys(
    Vm_Unt size
){
    return sizeof( Sys_A_Header );
}






/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE*   f,
    Vm_Uch* t,
    Vm_Obj  sys
) {
/*buggo*/
    return 0; /* Pacify gcc. */
}

#endif




/************************************************************************/
/*-    --- Static propfns --						*/
/************************************************************************/




/************************************************************************/
/*-    sys_pid								*/
/************************************************************************/

static Vm_Obj
sys_pid(
    Vm_Obj o
) {
    return OBJ_FROM_UNT( (Vm_Unt) getpid() );
}



/************************************************************************/
/*-    sys_page_size           						*/
/************************************************************************/

static Vm_Obj
sys_page_size(
    Vm_Obj o
) {
    #ifdef HAVE_GETPAGESIZE
    return OBJ_FROM_INT( getpagesize() );
    #else
    return OBJ_FROM_INT( 0 );
    #endif
}


/************************************************************************/
/*-    sys_hostname           						*/
/************************************************************************/

static Vm_Obj
sys_hostname(
    Vm_Obj o
) {
    return SYS_P(o)->hostname;
}

/************************************************************************/
/*-    sys_dns_name           						*/
/************************************************************************/

static Vm_Obj
sys_dns_name(
    Vm_Obj o
) {
    return SYS_P(o)->dns_name;
}

/************************************************************************/
/*-    sys_dns_addr           						*/
/************************************************************************/

static Vm_Obj
sys_dns_addr(
    Vm_Obj o
) {
    return SYS_P(o)->dns_addr;
}

/************************************************************************/
/*-    sys_ip0/1/2/3           						*/
/************************************************************************/

static Vm_Obj sys_ip0( Vm_Obj o ) { return OBJ_FROM_INT( sys_Ip0 ); }
static Vm_Obj sys_ip1( Vm_Obj o ) { return OBJ_FROM_INT( sys_Ip1 ); }
static Vm_Obj sys_ip2( Vm_Obj o ) { return OBJ_FROM_INT( sys_Ip2 ); }
static Vm_Obj sys_ip3( Vm_Obj o ) { return OBJ_FROM_INT( sys_Ip3 ); }



/************************************************************************/
/*-    sys_millisecs_since_1970          				*/
/************************************************************************/

static Vm_Obj
#if VM_INTBYTES > 4
sys_millisecs_since_1970(
#else
sys_secs_since_1970(
#endif
    Vm_Obj o
) {
    return OBJ_FROM_INT( job_Now() );
}



/************************************************************************/
/*-    sys_Date_Usecs	          					*/
/************************************************************************/

#ifdef HAVE_GETTIMEOFDAY
typedef int (*Sys_Get_Time_Of_Day_Type)( struct timeval *, char* );
static Vm_Int
sys_date_usecs2(
    Sys_Get_Time_Of_Day_Type get_time_of_day
) {
    struct timeval t;
    struct timeval tz[2];/* At least as big as struct timezone. */
    if (get_time_of_day( &t, (char*)tz )) {
	/* Call failed for some reason: */
	return (Vm_Int)0;
    }
/*printf("sys_date_usecs2(): t.tv_sec x=%x t.tv_usec x=%x t.tv_sec d=%d t.tv_usec d=%d\n",t.tv_sec,t.tv_usec,t.tv_sec,t.tv_usec);*/
    return (Vm_Int)t.tv_usec;
}
#endif

Vm_Int
sys_Date_Usecs(
    void
) {
    #ifdef HAVE_GETTIMEOFDAY
    /* This is messy:  On some system gettimeofday takes */
    /* a single 'struct timeval *' argument, and on some */
    /* it takes a second 'struct timezone*' argument.  I */
    /* don't know how to test for this in Configure,  so */
    /* this code is designed to work either way, keeping */
    /* the compiler quiet to boot:                       */
    return sys_date_usecs2(
	(Sys_Get_Time_Of_Day_Type) gettimeofday
    );
    #else
    return (Vm_Int)0;
    #endif
}

static Vm_Obj
sys_date_usecs(
    Vm_Obj o
) {
    return OBJ_FROM_INT( sys_Date_Usecs() );
}



/************************************************************************/
/*-    sys_usermode_cpu_nsecs          					*/
/************************************************************************/

static Vm_Obj
sys_usermode_cpu_nsecs(
    Vm_Obj o
) {
    #if   defined(HAVE_GETRUSAGE) && defined(HAVE_RUSAGE_RU_UTIME_TV_USEC)
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) (1000 * r.ru_utime.tv_usec) );
    #elif defined(HAVE_GETRUSAGE) && defined(HAVE_RUSAGE_RU_UTIME_TV_NSEC)
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) (       r.ru_utime.tv_nsec) );
    #else
    return OBJ_FROM_INT( 0 );
    #endif
}



/************************************************************************/
/*-    sys_usermode_cpu_secs           					*/
/************************************************************************/

static Vm_Obj
sys_usermode_cpu_secs(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_utime.tv_sec );
    #else
    return OBJ_FROM_INT( 0 );
    #endif
}



/************************************************************************/
/*-    sys_sysmode_cpu_nsecs           					*/
/************************************************************************/

static Vm_Obj
sys_sysmode_cpu_nsecs(
    Vm_Obj o
) {
    #if   defined(HAVE_GETRUSAGE) && defined(HAVE_RUSAGE_RU_STIME_TV_USEC)
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) (1000 * r.ru_stime.tv_usec) );
    #elif defined(HAVE_GETRUSAGE) && defined(HAVE_RUSAGE_RU_STIME_TV_NSEC)
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) (       r.ru_stime.tv_nsec) );
    #else
    return OBJ_FROM_INT( 0 );
    #endif
}



/************************************************************************/
/*-    sys_sysmode_cpu_secs           					*/
/************************************************************************/

static Vm_Obj
sys_sysmode_cpu_secs(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_stime.tv_sec );
    #else
    return OBJ_FROM_INT( 0 );
    #endif
}



/************************************************************************/
/*-    sys_max_rss	           					*/
/************************************************************************/

static Vm_Obj
sys_max_rss(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) (r.ru_maxrss*1024) );
    #else
    return OBJ_FROM_INT( 1 );
    #endif
}



/************************************************************************/
/*-    sys_muq_port	           					*/
/************************************************************************/

static Vm_Obj
sys_muq_port(
    Vm_Obj o
) {
    return OBJ_FROM_INT( sys_Muq_Port );
}



/************************************************************************/
/*-    sys_page_reclaims           					*/
/************************************************************************/

static Vm_Obj
sys_page_reclaims(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_minflt );
    #else
    return OBJ_FROM_INT( 1 );
    #endif
}



/************************************************************************/
/*-    sys_page_faults           					*/
/************************************************************************/

static Vm_Obj
sys_page_faults(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_majflt );
    #else
    return OBJ_FROM_INT( 1 );
    #endif
}



/************************************************************************/
/*-    sys_swapouts           						*/
/************************************************************************/

static Vm_Obj
sys_swapouts(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_nswap );
    #else
    return OBJ_FROM_INT( 1 );
    #endif
}



/************************************************************************/
/*-    sys_block_reads           					*/
/************************************************************************/

static Vm_Obj
sys_block_reads(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_inblock );
    #else
    return OBJ_FROM_INT( 1 );
    #endif
}



/************************************************************************/
/*-    sys_block_writes           					*/
/************************************************************************/

static Vm_Obj
sys_block_writes(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_oublock );
    #else
    return OBJ_FROM_INT( 1 );
    #endif
}



/************************************************************************/
/*-    sys_voluntary_ctxt_switches     					*/
/************************************************************************/

static Vm_Obj
sys_voluntary_ctxt_switches(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_nvcsw );
    #else
    return OBJ_FROM_INT( 1 );
    #endif
}



/************************************************************************/
/*-    sys_involuntary_ctxt_switches   					*/
/************************************************************************/

static Vm_Obj
sys_involuntary_ctxt_switches(
    Vm_Obj o
) {
    #ifdef HAVE_GETRUSAGE
    struct rusage r; /* = */ getrusage( RUSAGE_SELF, &r );
    return OBJ_FROM_INT( (Vm_Int) r.ru_nivcsw );
    #else
    return OBJ_FROM_INT( 1 );
    #endif
}



/************************************************************************/
/*-    sys_end_of_data_segment    					*/
/************************************************************************/

static Vm_Obj
sys_end_of_data_segment(
    Vm_Obj o
) {
    Vm_Uch* top = (Vm_Uch*)      0 ;	/* Got a better idea? */
    Vm_Uch* bot = (Vm_Uch*) sbrk(0);
    return OBJ_FROM_INT( (Vm_Int) (bot-top) );
}



/************************************************************************/
/*-    sys_set_never	 						*/
/************************************************************************/

static Vm_Obj
sys_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sys_set_ip0	 						*/
/************************************************************************/

static Vm_Obj
sys_set_ip0(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && ((i  = OBJ_TO_INT(v)) >= 0)
    &&  (i <= 0xFF)
    ){
	Vm_Obj sys = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("sys"), OBJ_PROP_PUBLIC );
	sys_Ip0 = i;
	SYS_P(sys)->ip0 = v;
	vm_Dirty(sys);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sys_set_ip1	 						*/
/************************************************************************/

static Vm_Obj
sys_set_ip1(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && ((i  = OBJ_TO_INT(v)) >= 0)
    &&  (i <= 0xFF)
    ){
	Vm_Obj sys = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("sys"), OBJ_PROP_PUBLIC );
	sys_Ip1 = i;
	SYS_P(sys)->ip1 = v;
	vm_Dirty(sys);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sys_set_ip2	 						*/
/************************************************************************/

static Vm_Obj
sys_set_ip2(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && ((i  = OBJ_TO_INT(v)) >= 0)
    &&  (i <= 0xFF)
    ){
	Vm_Obj sys = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("sys"), OBJ_PROP_PUBLIC );
	sys_Ip2 = i;
	SYS_P(sys)->ip2 = v;
	vm_Dirty(sys);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sys_set_ip3	 						*/
/************************************************************************/

static Vm_Obj
sys_set_ip3(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && ((i  = OBJ_TO_INT(v)) >= 0)
    &&  (i <= 0xFF)
    ){
	Vm_Obj sys = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("sys"), OBJ_PROP_PUBLIC );
	sys_Ip3 = i;
	SYS_P(sys)->ip3 = v;
	vm_Dirty(sys);
    }
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    sys_set_muq_port	 						*/
/************************************************************************/

static Vm_Obj
sys_set_muq_port(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int i;
    if (OBJ_IS_INT(v)
    && ((i  = OBJ_TO_INT(v)) >= 0)
    &&  (i <= 0xFFFF)
    ){
	Vm_Obj sys = OBJ_GET( vm_Root(0), sym_Alloc_Asciz_Keyword("sys"), OBJ_PROP_PUBLIC );
	sys_Muq_Port = i;
	SYS_P(sys)->muq_port = v;
	vm_Dirty(sys);
    }
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
