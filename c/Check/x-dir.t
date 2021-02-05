@example  @c
/*--   x-dir.c -- eXerciser for dir.c.					*/
/* This file is formatted for emacs' outline-minor-mode.		*/




/************************************************************************/
/*-    Dedication and Copyright.					*/

/************************************************************************/
/*									*/
/*		For Firiss:  Aefrit, a friend.				*/
/*									*/
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      93Jan23						*/
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

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* How big to make tests.  Keep SCALE smaller than sqrt(MAXINT):	*/
#undef  SCALE
#define SCALE (128)

/* Whether to be fairly verbose about test progress: */
#ifndef VERBOSE
#define VERBOSE (0)
#endif

#if DIR_COMPILE_SET
#define xxx_Startup    set_Startup
#define xxx_Linkup     set_Linkup
#define xxx_Shutdown   set_Shutdown
#define xxx_Alloc      set_Alloc
#define xxx_Del	       set_Del
#define xxx_Invariants set_Invariants
#define xxx_Free       set_Free
#define xxx_Get	       set_Get
#define xxx_Set	       set_Set
#define xxx_First      set_First
#define xxx_Next       set_Next
#define xxx_Print      set_Print
#else
#define xxx_Startup    map_Startup
#define xxx_Linkup     map_Linkup
#define xxx_Shutdown   map_Shutdown
#define xxx_Alloc      map_Alloc
#define xxx_Del	       map_Del
#define xxx_Invariants map_Invariants
#define xxx_Free       map_Free
#define xxx_Get	       map_Get
#define xxx_Set	       map_Set
#define xxx_First      map_First
#define xxx_Next       map_Next
#define xxx_Print      map_Print
#endif



/************************************************************************/
/*-    Globals								*/



/************************************************************************/
/*-    Statics								*/

static countEntries(  Vm_Obj );
static countObjects(  void );
static void startup(  void );
       void usage(    void );
static void muq_shutdown( void );	/* NEXTSTEP preempts 'shutdown' */
static void test1(FILE*,Vm_Int);




/************************************************************************/
/*-    --- Public fns ---						*/


/************************************************************************/
/*-    main								*/

Vm_Int   main_ArgC;
Vm_Uch** main_ArgV;

int
main(
    int       argC,
    Vm_Chr**  argV
) {
    main_ArgV = (Vm_Uch**)argV;
    main_ArgC =           argC;

    if (argC != 1)   usage();

    #if VERBOSE
    printf("\n%s: initializing...\n",argV[0]);
    #endif

    startup();

    /* Strides should be prime relative to SCALE: */
    {   Vm_Int stride;
        for (stride = 1;   stride < SCALE;   stride += 2) {
            test1( stdout, stride );
    }	}

    muq_shutdown();

    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/


/************************************************************************/
/*-    countEntries -- Count number of entries in map 'o'.		*/

static Vm_Int
countEntries(
    Vm_Obj o
) {

    Vm_Int    i = 0;
    Vm_Obj  k = xxx_First (o);
    xxx_Invariants ( stdout, "co1", o );
    for ( ;   k != OBJ_NOT_FOUND;   k = xxx_Next (o,k)) {
       ++i;
    }
    xxx_Invariants ( stdout, "co2", o );
    return i;
}



/************************************************************************/
/*-    countObjects -- Count number of live objects in virtual memory.	*/

static Vm_Int
countObjects( void ) {

    Vm_Int i = 0;
    Vm_Obj o = vm_First();;

    vm_Invariants( stdout, "co1" );
    for ( ;   o;   o = vm_Next(o))   ++i;
    vm_Invariants( stdout, "co2" );

    return i;
}




/************************************************************************/
/*-    startup								*/

static void startup( void ) {

    xxx_Startup ();
    xxx_Linkup ();
}



/************************************************************************/
/*-    muq_shutdown							*/

static void muq_shutdown(void) {

    xxx_Shutdown ();
    putchar('\n');
}



/************************************************************************/
/*-    test1 -- Basic map malloc/fill/length/free() exercising.		*/

static void test1(
    FILE* f,
    Vm_Int   stride
) {
    /* Count pre-existing objects: */
    Vm_Int    preexisting_objects = countObjects();

    /* Create a dir: */
    Vm_Obj m = xxx_Alloc ();

    /* Insert a few entries: */
    Vm_Int    i;
    printf("\rtest1: stride d= %d...",stride);
    fflush(stdout);
    #if VERBOSE
    printf("\ntest1: creating %d entries...\n",SCALE);
    #endif
    for (i = SCALE;   i --> 0;  ) {
	Vm_Int j = (i * stride) % SCALE;
	xxx_Invariants ( f, "t1.0", m );
	m = xxx_Set(
            m,
            OBJ_FROM_INT(j)
            #if !DIR_COMPILE_SET
          , OBJ_FROM_INT(j+100)
            #endif
        );
	xxx_Invariants ( f, "t1.1", m );
    }
    
    /* Check count of valid entries in map: */
    #if VERBOSE
    printf("test1: counting entries...\n");
    #endif
    if ((i = countEntries(m)) != SCALE) {
	err(f,"","test1: Created %d entries, found %d\n",SCALE,i);
    }

    /* Check vals of entries: */
    #if VERBOSE
    printf("test1: checking entry values...\n");
    #endif
    xxx_Invariants ( f, "t1.2", m );
    for (i = SCALE;   i --> 0;  ) {
	Vm_Int j = (i * stride) % SCALE;
	Vm_Obj val = xxx_Get ( m, OBJ_FROM_INT(j) );
        xxx_Invariants ( f, "t1.3", m );
	if (!val) {
	    err(f,"","test1: Entry %d in map %x not found!\n",j,m);
	    continue;
        }
        #if !DIR_COMPILE_SET
	if (OBJ_TO_INT(val) !=  j+100) {
	    err(f,"",
		"test1: Entry %d in map %x has val %d, not %d\n",
		j, m, OBJ_TO_INT(val), j+100
	    );
        }	    
        #endif
    }

    /* Set vals of entries: */
    #if !DIR_COMPILE_SET
    #if VERBOSE
    printf("test1: Setting entry values...\n");
    #endif
    for (i = SCALE;   i --> 0;  ) {
	Vm_Int j = (i * stride) % SCALE;
        xxx_Invariants ( f, "t1.3", m );
	m = xxx_Set (
            m, OBJ_FROM_INT(j), OBJ_FROM_INT(j+200)
        );
        xxx_Invariants ( f, "t1.4", m );
    }

    /* Recheck vals of entries: */
    #if VERBOSE
    printf("test1: Rechecking entry values...\n");
    #endif
    xxx_Invariants ( f, "t1.5", m );
    for (i = SCALE;   i --> 0;  ) {
	Vm_Int j = (i * stride) % SCALE;
	Vm_Obj val = xxx_Get ( m, OBJ_FROM_INT(j) );
        xxx_Invariants ( f, "t1.6", m );
	if (!val) {
	    err(f,"","test1: Entry %d in map %x not found!\n",j,m);
	    continue;
        }
	if (OBJ_TO_INT(val) !=  j+200) {
	    err(f,"",
               "test1: Entry %d in map %x has val %d, not %d\n",
               j, m, OBJ_TO_INT(val), j+200
            );
    }   }	    
    #endif

    /* Recycle all entries created: */
    #if VERBOSE
    printf("test1: Deleting entries...\n");
    #endif
    for (i = SCALE;   i --> 0;  ) {
	Vm_Int j = (i * stride) % SCALE;
        xxx_Invariants ( f, "t1.7", m );
        m = xxx_Del ( m, OBJ_FROM_INT(j) );
        xxx_Invariants ( f, "t1.8", m );
        vm_Invariants(  f, "t1.8" );
    }

    /* Check count of valid entries in dir: */
    #if VERBOSE
    printf("test1: Counting entries...\n");
    #endif
    if (i = countEntries(m)) {
	err(f, "","test1: Should be zero entries, found %d\n",i);
    }

    /* Recycle our dir: */
    xxx_Free ( m );

    /* Check count of valid objects in virtual memory: */
    #if VERBOSE
    printf("test1: Counting virtual memory objects...\n");
    #endif
    if ((i = countObjects()) != preexisting_objects) {
	err(f, "","test1: Should be %d virtual objects, found %d\n",
	    preexisting_objects, i
	);
    }
    #if VERBOSE
    printf("test1: Done.\n");
    #endif
}



/************************************************************************/
/*-    usage								*/

void
usage(
    void
) {

#if !DIR_COMPILE_SET
    fprintf( stderr, "usage: x_map\n" );
#else
    fprintf( stderr, "usage: x_set\n" );
#endif
    exit(1);
}




/************************************************************************/
/*-    File variables							*/
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

@end example
