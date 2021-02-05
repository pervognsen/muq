@example  @c
/*--   lib.c -- library of vars and fns with no other obvious home.	*/
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
/* Created:      93Sep04						*/
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
/* From: Jean Marie Diaz <ambar@cygnus.com>				*/
/* Date: Wed, 12 Oct 1994 16:42:45 -0700				*/
/*									*/
/*  Write your code, release it, and let people vote with their feet.	*/
/*  Talk is cheap.	-- AMBAR					*/
/************************************************************************/



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* This exists so "muq -m" can tell lib_db_init which */
/* muf libraries should be loaded when initializing a */
/* fresh db. Optional modules can add their libraries */
/* to this in their Startup():                        */
Vm_Uch*  lib_Optional_Muf_Libraries = "";

/* Same as above, except for selfcheck code: */
Vm_Uch*  lib_Optional_Muf_Selfcheck_Libraries = "";


/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    lib_Log_String -- Write string to logfile.			*/
/************************************************************************/

#ifndef LIB_LOGFILE_REOPEN_INTERVAL
#define LIB_LOGFILE_REOPEN_INTERVAL (60000)
#endif

FILE*    lib_Logfile 	 = NULL;	/* Initialized by z-muq.t.	*/
char*    lib_Logfilename = NULL;	/* Initialized by z-muq.t.	*/
Vm_Unt	 lib_Logfile_Last_Reopened = 0;

void
lib_Log_String(
    Vm_Uch* string
) {
    Vm_Uch jobbuf[32];
    Vm_Uch nambuf[32];
    Vm_Uch datbuf[32];
    Vm_Uch buffer[8192*2];

    /* Ignore if no logfile specified on commandline: */
    if (!lib_Logfilename)   return;

    /* Re-open about once per minute, so that if someone re-names the	*/
    /* logfile by hand, we start using the new one.			*/
    /* Renaming automatically from within the server would be a bit	*/
    /* tricky if multiple servers are writing to the same logfile.	*/
    if (job_RunState.now - lib_Logfile_Last_Reopened > LIB_LOGFILE_REOPEN_INTERVAL) {
	fclose( lib_Logfile );
	lib_Logfile = fopen(lib_Logfilename,"a");
	lib_Logfile_Last_Reopened = job_RunState.now;
    }

    /* Avoid eternally trying to open an impossible logfile:		*/
    if (!lib_Logfile) {
	lib_Logfilename = NULL;
	return;
    }

    /* Copy current time into datbuf[]: */
    {   
        #if MUQ_REPEATABLE
        Vm_Int dat  = 0;
	#else
        Vm_Int dat  = job_Now();
	#endif
	Vm_Int msec = dat % 1000;
	job_Strftime( datbuf, 32, "%Y/%m/%d/%H:%M:%S", dat );
	sprintf(nambuf,".%03d",(int)msec);
	strcat(datbuf,nambuf);
    }

    /* Copy user's name into nambuf[]: */
    if (!jS.j.actual_user
    ||  !OBJ_IS_OBJ( jS.j.actual_user)
    ||  !OBJ_IS_FOLK(jS.j.actual_user)
    ){
	sprintf( nambuf, "%010" VM_X, jS.j.actual_user );
	if (!jS.j.actual_user)   nambuf[0] = '\0';
    } else {
	Vm_Obj nam;
	nam = USR_P(jS.j.actual_user)->nick_name;
	if (!stg_Is_Stg(nam)) {
	    sprintf( nambuf, "%010" VM_X, jS.j.actual_user );
	} else {
	    Vm_Int len;
	    len = stg_Get_Bytes( nambuf, (Vm_Int)30, nam, (Vm_Int)0 );
	    nambuf[len] = '\0';
	}
    }

    /* Set up job number -- blank if none: */
    sprintf(jobbuf,"%016" VM_X, job_RunState.job );
    if (!job_RunState.job)   jobbuf[0] = '\0';

    /* Write log line prefix: */
    sprintf(
	buffer,
	"date:%s"
	" muq:%03" VM_D
	".%03"     VM_D
	".%03"     VM_D
	".%03"     VM_D
        ":%05"     VM_D
        #ifdef NAME_IS_MORE_USEFUL
        " user:%010" VM_X
	#endif
	" job:%16s"
        " user:%-16s"
        #ifdef MAYBE_SOMETIME
        " x:%" VM_X " pc:%03" VM_X " l:%02" VM_X " s:%" VM_X 
        #endif
	" msg: ",
	datbuf,
	sys_Ip0,
	sys_Ip1,
	sys_Ip2,
	sys_Ip3,
	sys_Muq_Port,
        #ifdef NAME_IS_MORE_USEFUL
	jS.j.actual_user,
	#endif
	jobbuf,
	nambuf
        #ifdef MAYBE_SOMETIME
	,job_RunState.x_obj,
	(Vm_Unt)(job_RunState.pc-x0),
	(Vm_Unt)(job_RunState.l-job_RunState.l_bot),
	(Vm_Unt)(job_RunState.s-job_RunState.s_bot)
        #endif
    );

    /* Write the line to the logfile.  It is important to do this     */
    /* as one single write call, since Unix guarantees that single    */
    /* writes are atomic -- with multiple servers writing to a single */
    /* logfile, we could get a mess otherwise:                        */
    strcat( buffer, string );
    /* Make sure line ends with a newline: */
    {   int i = strlen(buffer)-1;
	if (buffer[i  ] != '\n') {
	    buffer[i+1]  = '\n';
	    buffer[i+2]  = '\0';
	    ++i;
    	}
	/* Add an extra newline every 4th line or so: */
	{   static int count = 0;
	    if (!(++count & 3)) {
		buffer[i+1]  = '\n';
		buffer[i+2]  = '\0';
	    }
	}
    }
    fputs( buffer, lib_Logfile );
    fflush(        lib_Logfile );
}

/************************************************************************/
/*-    lib_Log_Printf -- Write formatted output to logfile.		*/
/************************************************************************/

void
lib_Log_Printf(
    Vm_Uch* format, ...
) {
    va_list args;
    Vm_Uch buffer[8192];

    /* Append logged output proper: */
    va_start(args, format);
    vsprintf(buffer, format, args);
    va_end(args);

    lib_Log_String( buffer );

}



/************************************************************************/
/*-    lib_Malloc -- Wrapper for malloc(), checks for err returns.	*/
/************************************************************************/

void*
lib_Malloc(
    Vm_Int bytes
) {
    void*  result = malloc( bytes );
    if   (!result) MUQ_FATAL ("Couldn't malloc %" VM_D " bytes of ram!",bytes);

    MUQ_NOTE_RANDOM_BITS( *(Vm_Unt*)&result );

    return result;
}



/************************************************************************/
/*-    lib_Note_All_Muf_Libraries -- for "muq -m".			*/
/************************************************************************/


/************************************************************************/
/*-    note_muf_library -- for "muq -M" and "muq -m".			*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
static void note_muf_library(
    Vm_Uch** libs_so_far,
    Vm_Uch*  libname
) {
    /* Tell "muq -M" about new library to search: */
    Vm_Uch* new_liblist = lib_Malloc( strlen(libname)+strlen(*libs_so_far)+2 );
    strcpy( new_liblist, *libs_so_far );
    strcat( new_liblist, " "          );
    strcat( new_liblist, libname      );
    free( *libs_so_far );
    *libs_so_far = new_liblist;
}
#endif



void
lib_Note_All_Muf_Libraries(
    void
){



    /* Make sure note_muf_library() can free() liblists: */

    lib_Optional_Muf_Libraries           = (Vm_Uch*) malloc(1);
    lib_Optional_Muf_Selfcheck_Libraries = (Vm_Uch*) malloc(1);

   *lib_Optional_Muf_Libraries           = '\0';
   *lib_Optional_Muf_Selfcheck_Libraries = '\0';



    /* Include patches for optional modules: */
    #define  MODULES_MUQ_C_NOTE_ALL_MUF_LIBRARIES
    #include "Modules.h"
    #undef   MODULES_MUQ_C_NOTE_ALL_MUF_LIBRARIES
}



/************************************************************************/
/*-    lib_Sprint -- Append asciz string to buffer.			*/
/************************************************************************/

Vm_Uch*
lib_Sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,

    Vm_Uch *format, ...
) {
    va_list args;
    Vm_Uch buffer[8192];
    va_start(args, format);
    vsprintf(buffer, format, args);
    va_end(args);
    {   Vm_Int  len = strlen( buffer );
	if (buf+len+2 >= lim)  MUQ_WARN ("lib_Sprint: buffer overflow");
	strcpy( buf, buffer );
	return buf+len;
    }
}



/************************************************************************/
/*-    lib_Find_Srv_Directory -- 					*/
/************************************************************************/

void
lib_Validate_Srv_Directory(
    Vm_Uch* dir		/* Something like "/var/people/pat/muq/srv"	*/
) {
    #ifndef  LIB_PATH_MAX
    #define  LIB_PATH_MAX 512
    #endif /*LIB_PATH_MAX*/

    #ifndef  LIB_FILE_MAX
    #define  LIB_FILE_MAX  32
    #endif /*LIB_FILE_MAX*/

    Vm_Uch buf[ LIB_PATH_MAX ];

    /* Ignore ridiculously long values: */
    if (strlen(dir) > LIB_PATH_MAX-LIB_FILE_MAX)   return;

    /* Make a local copy of name: */
    strcpy( buf, dir );

    {   /* Chop any trailing whitespace: */
	Vm_Int len = strlen(buf);
        while (len && !isgraph(buf[len-1])) {
	    buf[ --len ] = '\0';
    	}

	/* Chop any trailing '/': */
	if (len && buf[len-1]=='/')   buf[ --len ] = '\0';

	/* See if directory exists: */
	{   struct stat statbuf;	
	    if (-1 != stat( buf, &statbuf )
	    &&  S_ISDIR(statbuf.st_mode)
	    ){
		/* Cool, remember it for future reference: */
		obj_Srv_Dir = (Vm_Uch*) malloc(len+1);
		strcpy( obj_Srv_Dir, buf );
	    }
	}
    }
}

/************************************************************************/
/*-    lib_Find_Srv_Directory -- 					*/
/************************************************************************/

void
lib_Find_Srv_Directory(
    void
) {
    Vm_Uch buf[       2048 ];
    Vm_Uch buf2[      2048 ];

    struct stat statbuf;

    /* Extract the information from Muq-config.sh: */
    Vm_Uch* muqdir   = getenv("MUQDIR");
    if (muqdir) {
	strcpy( buf, muqdir );
    } else {
        Vm_Uch* home = getenv("HOME");
	if (home) {
	    strcpy( buf, home );
	    strcat( buf, "/muq/bin" );
	}
    }

    /* If we can find the muq/bin directory */
    /* and it -is- a directory:             */
    if (-1 != stat( buf, &statbuf )
    &&  S_ISDIR(statbuf.st_mode)
    ){
	/* Owner-executable bit: */
	#ifdef S_IXUSR
	#define  IS_EXECUTABLE(m) (m & S_IXUSR)
	#else
	#define  IS_EXECUTABLE(m) (m & 0100)
	#endif

	/* Great -- check for muq-config: */
	strcat( buf, "/muq-config" );
	if (-1 != stat( buf, &statbuf )
	&&  S_ISREG(      statbuf.st_mode)
	&&  IS_EXECUTABLE(statbuf.st_mode)
	){
	    /* Exists and is executable: */
	    FILE* fd;
	    strcat( buf, " srvdir" );
	    if (fd = popen( buf, "r" )) {
		if (fgets( buf2, 2000, fd )) {
		    lib_Validate_Srv_Directory( buf2 );
		}	    
		pclose(fd);
	    }
	}
    }
}

/************************************************************************/
/*-    lib_Validate_Symbol -- Make sure it exists and is exported.	*/
/************************************************************************/

Vm_Obj
lib_Validate_Symbol(
    Vm_Uch* name,
    Vm_Obj  lib   /* obj_Lib_Muf or obj_Lib_Lisp */
) {
    Vm_Obj sym = sym_Find_Exported_Asciz( lib, name );

    MUQ_NOTE_RANDOM_BITS( sym );

    if (!sym || !OBJ_IS_SYMBOL(sym)) {
	Vm_Obj key = stg_From_Asciz( name );
	sym = sym_Make();
	OBJ_SET( lib, key, sym, OBJ_PROP_PUBLIC );
	/* All symbols in a package must be  in hidden area; */
	/* In addition, we export by putting in public area: */
	OBJ_SET( lib, key, sym, OBJ_PROP_HIDDEN );
	OBJ_SET( lib, key, sym, OBJ_PROP_PUBLIC );
	{   Sym_P s = SYM_P(sym);
	    s->name    = key;
	    s->package = lib;
	    vm_Dirty(sym);
    }   }
    return sym;
}

/************************************************************************/
/*-    CrT_malloc code.							*/
/************************************************************************/

#include "CrT_malloc.t"



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
