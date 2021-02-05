@example  @c
/*--   x-obj.c -- eXerciser for obj.c.					*/
/* This file is formatted for emacs' outline-minor-mode.		*/




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
/* Created:      93Feb15						*/
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
/* Please send bug reports/fixes etc to bugs@@muq.org.			*/
/************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* What to do on fatal error:						*/
#ifndef JOB_FATAL
#define JOB_FATAL(x) {fprintf(stderr, (x));abort();}
#endif

/* Size for the buffers we put code/string in: */
#define BUF_MAX (0x8000)



/************************************************************************/
/*-    Types								*/
/************************************************************************/

struct Buf_rec {
    Vm_Chr  byte0[ BUF_MAX ];
    Vm_Chr* bytei;
};
typedef struct Buf_rec A_Buf;
typedef struct Buf_rec*  Buf;



/************************************************************************/
/*-    Globals								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void startup(  void );
void usage( void );
static void muq_shutdown( void );	/* NEXTSTEP preempts 'shutdown' */
static void test1(FILE*);




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    main								*/
/************************************************************************/

Vm_Int   main_ArgC;
Vm_Uch** main_ArgV;

int
main(
    int    argc,
    char** argv
) {
    main_ArgV = (Vm_Uch**)argv;
    main_ArgC =           argc;

    if (argc != 1)   usage();

    startup();
    test1( stdout );
    muq_shutdown();

    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/



/************************************************************************/
/*-    startup								*/
/************************************************************************/

static void startup( void ) {

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
/*-    test1 								*/
/************************************************************************/

static void test1(
    FILE* f
) {
    /* Test that vm_Root is nonzero: */
    if (!vm_Root) {
	err(f,"test1", "vm_Root is zero!");
	return;
    }

    /* Test that vm_Root is an object: */
    if (!OBJ_IS_OBJ(vm_Root(0))) {
	err(f,"test1","vm_Root (%x) is not an object!",vm_Root);
	return;
    }

    /* Test that vm_Root is a generic object: */
    if (!OBJ_IS_OBJ(vm_Root(0)) || !OBJ_IS_CLASS_DBF(vm_Root(0))) {
	err(f,"test1","vm_Root (%x) is not a databasefile object!",vm_Root(0));
	return;
    }

    
    {   /* Test that /u/ exists: */
        Vm_Obj u = obj_Get( vm_Root(0), sym_Alloc_Asciz_Keyword("u") );
	if (u == OBJ_NOT_FOUND) {
	    err(f,"test1","/u does not exist!");
	    return;
	}

	/* Test that /u/ is an object: */
	if (!OBJ_IS_OBJ(u)) {
	    err(f,"test1","/u/ (%x) is not an object!",u);
	    return;
	}

	/* Test that /u/ is a generic object: */
	if (!OBJ_IS_OBJ(u) || !OBJ_IS_CLASS_OBJ(u)) {
	    err(f,"test1","/u/ (%x) is not a generic object!",u);
	    return;
	}

        /* Test that /u/root exists: */
	{   Vm_Obj root = obj_Get( u, stg_From_Asciz( "root" ) );
	    if (root == OBJ_NOT_FOUND) {
		err(f,"test1","/usr/root does not exist!");
		return;
	    }

	    /* Test that /u/root is an object: */
	    if (!OBJ_IS_OBJ(root)) {
		err(f,"test1","/u/root (%x) is not an object!",root);
		return;
	    }

	    /* Test that /u/toot is indeed: */
	    if (!OBJ_IS_OBJ(root) || !OBJ_IS_CLASS_ROT(root)) {
		err(f,"test1","/u/root (%x) is not a root!",root);
		return;
	    }
    }   }

    printf("test1: Done.\n");
}



/************************************************************************/
/*-    usage								*/
/************************************************************************/

void usage(void) {

    fprintf( stderr, "usage: x_obj\n" );
    exit(1);
}




/************************************************************************/
/*-    File variables							*/
/************************************************************************/
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

@end example
