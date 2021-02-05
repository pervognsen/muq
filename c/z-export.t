@example  @c
/* buggo: need to add 'a' version letter to major compound formats. */


/*--   z_export.c -- Export sub/tree of db as an ascii flatfile.	*/
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
/* Created:      94Feb21						*/
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

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include <sys/stat.h>
#include <sys/types.h>

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#define MUQ_EXPORT_FILE_FORMAT_VERSION "1.0"



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Globals								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void export(   FILE*, Vm_Chr*, Vm_Int );
static void startup(  Vm_Chr* );
static void lib_shutdown( void );	/* NEXTSTEP preempts 'shutdown' */
static void usage(    void );




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
    Vm_Int  i;
    Vm_Chr* subtree = NULL;
    Vm_Chr* db      = NULL;
    Vm_Int  write_owners = 0;

    for (i = 1;   i < argC;   ++i) {
	Vm_Chr* arg = argV[i];
	switch (*arg++) {
	case '-':
	    switch (*arg) {

	    case 'd':
		if (db || ++i == argC)   usage();
		db = argV[i];
		break;

	    case 'o':
		write_owners = -1;
		break;

	    case 't':
		if (subtree || ++i == argC)   usage();
		subtree = argV[i];
		break;

	    default:
		usage();
	    }
	    break;

	case '+':
	    switch (*arg) {

	    case 'o':
		write_owners =  1;
		break;

	    default:
		usage();
	    }
	    break;
	default:
            if (db)   usage();
	    db = argV[i];
	    continue;
	}
    }
    if (!subtree)   subtree = "/.";

    /* Default to writing ownership information  */
    /* only when exporting entire db, if neither */
    /* +o nor -o option was specified:           */
    switch (write_owners) {
    case -1:
	write_owners = FALSE;
	break;
    case  1:
	write_owners = TRUE ;
	break;
    case  0:
	write_owners = (!strcmp( subtree, "/" ) ||  !strcmp( subtree, "/."  ));
	break;
    }

    startup( db );
    export( stdout, subtree, write_owners );
    lib_shutdown();

    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    export								*/
/************************************************************************/

static void export(
    FILE*   fd,
    Vm_Chr* subtree,
    Vm_Int  write_owners
) {
    Vm_Obj root = job_Path_Get_Unrooted_Asciz( subtree, /*may_fail:*/FALSE );
    if    (root == OBJ_NOT_FOUND) {
	fprintf(stderr,"Aborted: no such object in db: %s\n", subtree );
	exit(1);
    }

    /* Write a file header: */
    {   time_t  now = time(NULL);
	Vm_Chr  year[   6 ];
	Vm_Chr  date[ 256 ];
	Vm_Chr  when[ 256 ];
	cftime( year, "%Y", &now );
	cftime( date, "14,163,39%%c,%%c%y:%h:%d:%H:%M:%S", &now );
	sprintf(when, date, year[0], year[1] );

	/* Identify file type: */
	fputs( "MUQ\n", fd );

	/* Write header table.  When reading, we */
	/* scan this as an unordered environment */
	/* table:                                */
	fprintf(fd, "format %s\n", MUQ_EXPORT_FILE_FORMAT_VERSION );
	fprintf(fd, "owners %s\n", write_owners ? "yes" : "no" );
	fprintf(fd, "root %s\n", subtree );
	fprintf(fd, "date %s\n", when );

	/* Blank line to mark end of table: */
	fputc( '\n', fd );
    }

    /* Write subtree rooted at 'root': */
    {   Obj_A_Export_Stats stats;
	obj_Export_Tree( fd, root, &stats, write_owners );
	fprintf( stderr,
	    "%d thing%s containing %d items written.\n",
	    (int)stats.objects_in_file,
	   (stats.objects_in_file == 1) ? "" : "s",
	    (int)stats.items_in_file
	);
    }

    fclose( fd );
}



/************************************************************************/
/*-    startup								*/
/************************************************************************/

static void startup(
    Vm_Chr* db
) {
    /* If user specified db dir, pass to vm.c: */
    if (db) {
        vm_Octave_File_Path = db;
    }

    obj_Startup();
    obj_Linkup();
}



/************************************************************************/
/*-    lib_shutdown							*/
/************************************************************************/

static void lib_shutdown(void) {

    obj_Shutdown();
}



/************************************************************************/
/*-    usage								*/
/************************************************************************/

static void usage(void) {

    fprintf( stderr, "usage: lib_export [-t /u/xx] [-d db] [+o] [-o]\n" );
    fprintf( stderr, " -d db        Db to use (defaults 'vm').\n");
    fprintf( stderr, " -t /u/xx     Tree to save (default: /).\n");
    fprintf( stderr, " -o           Do not write ownership info.\n");
    fprintf( stderr, " +o           Do     write ownership info.\n");

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
