@example  @c
/*--   z_import.c -- Export sub/tree of db as an ascii flatfile.	*/
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
/* Created:      94Feb27						*/
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

#define MUQ_EXPORT_FILE_FORMAT_VERSION 1.0



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Globals								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void import( Vm_Chr*, Vm_Chr*, Vm_Int, Vm_Int );
static void startup(  Vm_Chr* );
static void muq_shutdown( void );	/* NEXTSTEP preempts 'shutdown' */
static void usage( void );




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
    Vm_Chr* infile  = NULL;
    Vm_Chr* db      = NULL;
    Vm_Int  ignore_owners = FALSE;

    for (i = 1;   i < argC;   ++i) {
	Vm_Chr* arg = argV[i];
	if (*arg++ != '-') {
            if (db)   usage();
	    db = argV[i];
	    continue;
	}
	switch (*arg) {

	case 'o':
	    ignore_owners = TRUE;
	    break;

	case 'd':
	    if (db || ++i == argC)   usage();
	    db      = argV[i];
	    break;

	case 'f':
	    if (infile || ++i == argC)   usage();
	    infile  = argV[i];
	    break;

	case 't':
	    if (subtree || ++i == argC)   usage();
	    subtree = argV[i];
	    break;

	default:
	    usage();
	}
    }
    if (! infile)   infile  = "import.muq";

    startup( db );
    import( infile, subtree, 0, ignore_owners );
    import( infile, subtree, 1, ignore_owners );
    muq_shutdown();

    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    import								*/
/************************************************************************/

static void import(
    Vm_Chr* filename,
    Vm_Chr* subtree,
    Vm_Int  pass,	/* 0 or 1.	*/
    Vm_Int  ignore_owners
) {
    /************************************************************/
    /* Since one of our design goals is to support fairly	*/
    /* large (hundreds of megabytes) dbs on machines which	*/
    /* may not support processes of that size, we import files  */
    /* using a two-pass algorithm:				*/
    /*								*/
    /* Pass 0 creates all the composite objects and enters into	*/
    /* a hashtable the mapping between the old object name	*/
    /* used in the file and the corresponding newly-created	*/
    /* object.							*/
    /*								*/
    /* Pass 1, with this mapping safely in hand, then rereads	*/
    /* the entire file, creating all atomic objects and filling	*/
    /* in all keyVal entries in the composite objects.		*/
    /************************************************************/
    Vm_Int have_owners = FALSE;	/* TRUE if input file has owner info.   */
    Vm_Int read_owners = FALSE; /* FALSE means ignore above if present. */
    FILE*  fd = fopen( filename, "r" );
    if  (!fd) {
	fprintf(stderr,"Aborted: couldn't open infile '%s'\n",filename);
	exit(1);
    }

    /* Read the file header: */
    {   Vm_Flt vsn = 1.0e6;
	Vm_Chr b[    1024 ];	
	Vm_Chr root[ 1024 ];	

	b[   0] = '\0';
	root[0] = '\0';

	/* Read and check file magic: */
	if (fgetc(fd) != 'M'
	||  fgetc(fd) != 'U'
	||  fgetc(fd) != 'Q'
	||  fgetc(fd) != '\n'
	){
	    fprintf(stderr,"'%s' isn't a MUQ-format file!\n", filename );
	    exit(1);
	}

	/* Scan header table: */
	for (;;) {

	    /* Read next line in header table: */
	    if (!fgets( b, 1024, fd )) {
		fprintf(stderr,"Unexpected EOF in %s file header!\n",filename);
		exit(1);
	    }

	    /* Blank line means end-of-table: */
	    if (*b == '\n')   break;

	    /* Branch on line type: */
	    {   Vm_Chr* p = strchr( b, ' ' );
		if (!p) {
		    fprintf(stderr,"Invalid header line: %s",b);
		    exit(1);
		}

		/* Null-terminate line type, */
		/* leaving p pointer to rest */
		/* of input line:            */
		*p++ = '\0';

		/* Overwrite terminal \n:    */		
		p[ strlen(p) -1 ] = '\0';

		if        (!strcmp( b, "format" )) {

		    if (1 != sscanf(p, "%" VM_G, &vsn )) {
			fprintf(stderr,"Cryptic 'format' value: %s",p);
			exit(1);
		    }

		} else if (!strcmp( b, "owners" )) {

		    if      (!strcmp(p, "yes" )) { have_owners = TRUE;  }
		    else if (!strcmp(p, "no"  )) { have_owners = FALSE; }
		    else {
			fprintf(stderr,"Cryptic 'owners' value: %s\n",p);
			exit(1);
		    }

		} else if (!strcmp( b, "root"   )) {

		    if (*p != '/') {
			fprintf(stderr,"Cryptic 'root' value: %s\n",p);
			exit(1);
		    }
		    strcpy( root, p );

		} else if (!strcmp( b, "date"   )) {

		    /* We ignore date. */

		} else {

		    fprintf(stderr,"Unrecognized header line type: %s\n",b);
		    exit(1);
	}   }	}

	if (vsn > MUQ_EXPORT_FILE_FORMAT_VERSION) {
	    fprintf(stderr,
		"Format of file '%s' is too modern for me to understand!\n",
		filename
	    );
	    exit(1);	    
	}

	/* Decide whether to ignore any    */
	/* ownership info present in file: */
	read_owners = have_owners;
	if (ignore_owners)   read_owners = FALSE;

	/* If user didn't explicitly specify a */
	/* load point, default to save point:  */
	if (!subtree)   subtree = root;

	/* Forget this is unix and tell	*/
	/* user what we're doing:	*/
	if (!pass) {
	    fprintf(stderr,
		"Loading file '%s', an archive of %s,\n",
		filename, root
	    );
	    fprintf(stderr,
		"which will be installed at %s in db '%s'.\n",
		subtree, vm_Octave_File_Path
	    );
	    fprintf(stderr,
		"File '%s' %s ownership information.\n",
		filename,
		have_owners ? "includes" : "does not include"
	    );
	    if (have_owners && !read_owners) {
		fputs( "Ownership info is being ignored.\n", stderr );
	    }
	    fputs( "...\n", stderr );
	}

	/* Read in subtree in file: */
	{   Obj_A_Export_Stats stats;
	    Vm_Obj tree = obj_Import_Tree(
		fd, &stats, pass, have_owners, read_owners
	    );
	    if (pass) {
		fputs( "Done: ", stderr );
		if (stats.objects_in_file) {
		    fprintf( stderr,
			"%d thing%s containing ",
			(int)stats.objects_in_file,
		       (stats.objects_in_file == 1) ? "" : "s"
		    );
		}
		fprintf( stderr, "%d items read.\n", (int)stats.items_in_file );
	    }
	    fclose( fd );

	    if (pass) {
		/* Attach subtree which was read, */
		/* at indicated mount point:      */

		/* If subtree is "/" or "/.", we want to  */
		/* just set vm_Root, otherwise we want to */
		/* use job_Path_Set to insert subtree at  */
		/* appropriate point:		      */
		if (!strcmp( "/" , subtree )
		||  !strcmp( "/.", subtree )
		){
		    vm_Root = tree;
		} else {
		    job_Path_Set_Unrooted_Asciz( subtree, tree );
    }   }   }   }
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
/*-    muq_shutdown							*/
/************************************************************************/

static void muq_shutdown(void) {

    obj_Shutdown();
}



/************************************************************************/
/*-    usage								*/
/************************************************************************/

static void usage(void) {

    fprintf( stderr, "usage: muq_import [-o][-t /u/xx][-d db][-f infile]\n" );
    fprintf( stderr, " -o          ignore ownership info in input file).\n");
    fprintf( stderr, " -d db       db to use (defaults 'vm').\n");
    fprintf( stderr, " -t /u/xx    db insert point for file (default: /).\n");
    fprintf( stderr, " -f infile   file to read (default: import.muq).\n");

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
