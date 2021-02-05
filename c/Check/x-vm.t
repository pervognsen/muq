@example  @c
/*--   x-vm.c -- eXerciser for vm.c.					*/
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
/* Created:      93Jan05						*/
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
/*-    Globals								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static        countObjects(   void );
static Vm_Obj car( Vm_Obj );
static Vm_Obj cdr( Vm_Obj );
static Vm_Obj cons( Vm_Obj, Vm_Obj );
static void   startup(  void );
void   usage(    void );
static void   muq_shutdown( void );	/* NEXTSTEP preempts 'shutdown' */
static void   test1(    FILE*);
static void   test2(    FILE*);
static void   test3(    FILE*);
static void   test4(    FILE*,Vm_Int  );
static void   test5(    FILE*);
static Vm_Obj tree_build(Vm_Unt);
static void   tree_free( Vm_Obj);




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
    int       argC,
    Vm_Chr**  argV
) {
    main_ArgV = (Vm_Uch**)argV;
    main_ArgC =           argC;

    if (argC != 1)   usage();

    startup();

    test1(stdout);
    test2(stdout);
    test3(stdout);
    test4(stdout, sizeof(Vm_Int) );	/* Small octave.	*/
    test4(stdout,       0x100 );	/* Large octave.	*/
    test5(stdout);

    muq_shutdown();

    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    all_ptrs -- fn to find all pointers in an obj			*/
/************************************************************************/

static void all_ptrs(
    Vm_Obj cell,
    void(*fn)(Vm_Obj)
) {
    Vm_Obj o;
    if    (o = car(cell))   fn(o);    
    if    (o = cdr(cell))   fn(o);    
}


/************************************************************************/
/*-    car -- Lisp 'car' operator.					*/
/************************************************************************/

static Vm_Obj car(
    Vm_Obj cell
) {
    Vm_Obj*p    = (Vm_Obj*) vm_Loc( cell );
    return p[0];
}



/************************************************************************/
/*-    cdr -- Lisp 'cdr' operator.					*/
/************************************************************************/

static Vm_Obj cdr(
    Vm_Obj cell
) {
    Vm_Obj*p    = (Vm_Obj*) vm_Loc( cell );
    return p[1];
}



/************************************************************************/
/*-    cons -- Lisp 'cons' operator.					*/
/************************************************************************/

static Vm_Obj cons(
    Vm_Obj car,
    Vm_Obj cdr
) {
    Vm_Obj cell = vm_Malloc( 2* sizeof(Vm_Obj) );
    Vm_Obj*p    = (Vm_Obj*) vm_Loc( cell );
    p[0] = car;
    p[1] = cdr;
    return cell;
}



/************************************************************************/
/*-    countObjects -- Count number of live objects in virtual memory.	*/
/************************************************************************/

static int
countObjects( void ) {

    Vm_Int    i = 0;
    Vm_Obj o = vm_First();;
    vm_Invariants( stdout, "co1" );
    for ( ;   o;   o = vm_Next(o))    ++i;
    vm_Invariants( stdout, "co2" );
    return i;
}



/************************************************************************/
/*-    startup								*/
/************************************************************************/

static void startup( void ) {

    vm_Nuke_Db_At_Startup = TRUE;
    vm_Startup();
    vm_Linkup();
}



/************************************************************************/
/*-    muq_shutdown							*/
/************************************************************************/

static void muq_shutdown(void) {
    vm_Shutdown();
}



/************************************************************************/
/*-    test1 -- Basic object malloc()/fill/length/free() exercising.	*/
/************************************************************************/

/* How big to make tests: */
#undef  N
#define N (128)

static void test1(
    FILE* f
) {

    /* Create a few objects: */
    Vm_Obj o[ N ];
    Vm_Int    i;
    printf("test1...\n");
    for (i = N;  i --> 0; ) {
        vm_Invariants( stdout, "t1.0" );
        o[i] = vm_Malloc(i);
        vm_Invariants( stdout, "t1.1" );
    }
    
    /* Check count of valid objects in vm, */
    /* remembering that length-zero object */
    /* doesn't actually exist:             */
    if ((i = countObjects()) != N-1) {
	err(f,"test1","Created %d objects, only found %d\n",N,i);
    }

    /* Check lengths of objects: */
    vm_Invariants( stdout, "t1.2" );
    for (i = N;  i --> 0; ) {
	Vm_Int len = vm_Len( o[i] );
        vm_Invariants( stdout, "t1.3" );
	if (len !=  i) {
	    err(f,"test1","Obj %d (Vm_Obj %x) len is %d, not %d\n",i,o[i],len,i);
    }   }	    

    /* Set contents of objects: */
    for (i = N;   i --> 0;  ) {
        Vm_Int j;
	Vm_Chr* p = vm_Loc( o[i] );
        vm_Invariants( stdout, "t1.3" );
	for (j = i;   j --> 0;   )    p[j] = (Vm_Chr) j;
        vm_Invariants( stdout, "t1.4" );
    }
    /* Recheck lengths of objects: */
    for (i = N;  i --> 0; ) {
	Vm_Int len = vm_Len( o[i] );
        vm_Invariants( stdout, "t1.4" );
	if (len !=  i) {
	    err(f,"test1"," Obj %d (Vm_Obj %x) len now %d, was %d\n",i,o[i],len,i);
    }   }	    

    /* Check contents of objects: */
    for (i = N;   i --> 0;  ) {
        Vm_Int j;
	Vm_Chr* p = vm_Loc( o[i] );
        vm_Invariants( stdout, "t1.5" );
	for (j = i;   j --> 0;   ) {
	    if (p[j] != (Vm_Chr) j) {
		err(f,
		    "test1","obj%d[%d] now %d not %d\n",
		    i,
		    j,
		    p[j],
		    (Vm_Chr)j
		);
    }   }   }

    /* Recycle all objects created: */
    for (i = N;  i --> 0; ) {
        vm_Invariants( stdout, "t1.6" );
        vm_Free( o[i] );
        vm_Invariants( stdout, "t1.7" );
    }

    /* Check count of valid objects in vm: */
    if (i = countObjects()) {
	err(f, "test1","Should be zero objects, found %d\n",i);
    }
}
#undef  N



/************************************************************************/
/*-    test2 -- Test compaction of empty buffer.			*/
/************************************************************************/

static void test2(
    FILE* f
) {

    /* Shrink bigbuf and figure out how big it is: */
    Vm_Unt bigbuf_size = vm_Resize_Bigbuf(1);

    /* Create and delete lots of objects, so vm.c */
    /* is forced to compact several times:	  */
    Vm_Int i;
    printf("test2...\n");
    for (i = bigbuf_size;   i --> 0;  ) {
        vm_Invariants( stdout, "t2.0" );
	vm_Free( vm_Malloc( 0 ));
        vm_Invariants( stdout, "t2.1" );
    }

    /* Check count of valid objects in vm: */
    if (i = countObjects()) {
	err(f, "test2","Should be zero objects, found %d\n",i);
    }
}



/************************************************************************/
/*-    test3 -- Test compaction of nonempty buffer.			*/
/************************************************************************/

#undef  N
#define N (12)

static void test3(
    FILE* f
) {

    /* Shrink bigbuf and figure out how big it is: */
    Vm_Unt bigbuf_size = vm_Resize_Bigbuf(1);

    /* Track how many objects we've created.  This test */
    /* is designed to stay in physical memory, so we    */
    /* don't create more than N:                        */
    Vm_Int count = 0;
    Vm_Int vec[ N ];

    /* Create and delete lots of objects, so vm.c */
    /* is forced to compact several times:	  */
    Vm_Int i;
    printf("test3...\n");
    for (i = bigbuf_size / 10;   i --> 0;  ) {

	Vm_Obj o = vm_Malloc( (i % 7)+1 );
        vm_Invariants( stdout, "t3.0" );

	if ((i & 0xF)  ||  count == N)   vm_Free( o );
	else 	                         vec[ count++ ] = o;

        vm_Invariants( stdout, "t3.1" );
    }

    /* Check count of valid objects in vm: */
    if ((i = countObjects())   !=   count) {
	err(f, "test3","Should be %d objects, found %d\n",count,i);
    }

    /* Recycle our objects: */
    for (i = count;   i --> 0;   ) {
        vm_Invariants( stdout, "t3.2" );
        vm_Free( vec[i] );
        vm_Invariants( stdout, "t3.3" );
    }

    /* Check count of valid objects in vm: */
    if (i = countObjects()) {
	err(f, "test3","Should be zero objects, found %d\n",i);
    }
}
#undef  N



/************************************************************************/
/*-    test4 -- Test swapping to/from disk.				*/
/************************************************************************/

static void test4(
    FILE* f,
    Vm_Int objsiz
) {

    /* Shrink bigbuf and figure out how big it is: */
    Vm_Unt bigbuf_size = vm_Resize_Bigbuf(1);

    /* Create enough objsiz objects to overflow bigbuf: */
    Vm_Int i;
    Vm_Int    objcount = (bigbuf_size / objsiz) + 16;
    Vm_Obj*     vec = malloc( objcount * sizeof(Vm_Obj) );

    printf("test4(%d)...\n",objsiz);

    /* Zero vm.c's internal counters: */
    vm_Object_Reads  = 0;
    vm_Object_Sends = 0;

    if (!vec) {
	err(f,"test4","(%d): out of ram\n",objsiz);
	exit(1);
    }
    for (i = objcount;   i --> 0;  ) {
        vm_Invariants( stdout, "t4.0" );
	vec[i] = vm_Malloc( sizeof(Vm_Int) );
        vm_Invariants( stdout, "t4.1" );
	* (Vm_Int*) vm_Loc( vec[i] )   =   ~i;
        vm_Invariants( stdout, "t4.2" );
    }

    /* Check count of valid objects in vm: */
    if ((i = countObjects())   !=   objcount) {
	err(f, "test4","Should be %d objects, found %d\n",countObjects,i);
    }

    /* Check contents of our objects: */
    for (i = objcount;   i --> 0;  ) {

	Vm_Int  v;
	if ((v = * (Vm_Int*) vm_Loc( vec[i] ))   !=   ~i) {
	    err(f,
		"test4","obj %d id %x hold %x, should be %x\n",
		i, vec[i], v, ~i
	    );
        }
        vm_Invariants( stdout, "t4.3" );
	if ((v = vm_Len( vec[i] ))   !=   sizeof(Vm_Int)) {
	    err(f,
		"test4","obj %d id %x len is %d, should be %d\n",
		i, vec[i], v, sizeof(Vm_Int)
	    );
	}
        vm_Invariants( stdout, "t4.4" );
    }

    /* Closedown and re-open vm.c to flush bitmap */
    /* index to disk and then re-read it:         */
    vm_Root = vec[0];	/* We'll test that Root save/restores correctly */
    vm_Invariants( stdout, "t4.5" );
    vm_Preshutdown();
    vm_Root =     0;
    vm_Nuke_Db_At_Startup = FALSE;
    vm_Restartup();
    vm_Invariants( stdout, "t4.6" );
    if (vm_Root != vec[0]) {
	err(f,
	    "test4","vm_Root restored as %x, should be %x\n",
	    vm_Root, vec[0]
	);
    }


    /* Recheck contents of our objects: */
    for (i = objcount;   i --> 0;  ) {

	Vm_Int  v;
	if ((v = * (Vm_Int*) vm_Loc( vec[i] ))   !=   ~i) {
	    err(f,
		"test4","obj %d id %x hold %x, should be %x\n",
		i, vec[i], v, ~i
	    );
        }
        vm_Invariants( stdout, "t4.7" );
	if ((v = vm_Len( vec[i] ))   !=   sizeof(Vm_Int)) {
	    err(f,
		"test4","obj %d id %x len is %d, should be %d\n",
		i, vec[i], v, sizeof(Vm_Int)
	    );
	}
        vm_Invariants( stdout, "t4.8" );
    }

    /* Recycle our objects: */
    for (i = objcount;   i --> 0;   ) {
        vm_Invariants( stdout, "t4.9" );
        vm_Free( vec[i] );
        vm_Invariants( stdout, "t4.a" );
    }

    /* Check count of valid objects in vm: */
    if (i = countObjects()) {
	err(f, "test4","Should be zero objects, found %d\n",i);
    }

    free( vec );
}



/************************************************************************/
/*-    test5 -- Test garbage collection / backup			*/
/************************************************************************/

static void test5(
    FILE* f
) {
    Vm_Obj tree;
    Vm_Int objcount;

    /* Shrink bigbuf and figure out how big it is: */
    /* Vm_Unt bigbuf_size = */ vm_Resize_Bigbuf(1);

    /* Create a nice size tree: */
    tree = tree_build(8);
    objcount = 511;
    vm_Invariants( stdout, "t5.0" );

    printf("test5()...\n");

    /* Verify tree's existence: */
    {   Vm_Int i;
	if ((i = countObjects())   !=   objcount) {
	    err(f, "test5","Should be %d objects, found %d\n",countObjects,i);
    }	}
    vm_Invariants( stdout, "t5.1" );

    /* Do a few backup/garbageCollects: */
    {   Vm_Int  i;
	for (i = 10;   i --> 0;   ) {
	    Vm_Obj* roots[2];
	    roots[0] = &tree;
	    roots[1] = NULL;
            for (
		vm_Backup_Start( all_ptrs, roots );
		vm_Backup_Continue();
	    );
	    vm_Invariants( stdout, "t5.1" );
    }   }

    /* Verify tree's existence: */
    {   Vm_Int i;
	if ((i = countObjects())   !=   objcount) {
	    err(f, "test5","Should be %d objects, found %d\n",countObjects,i);
    }	}
    vm_Invariants( stdout, "t5.2" );

    /* Recycle tree: */
    tree_free( tree );
    vm_Invariants( stdout, "t5.3" );

    /* Verify its nonexistence: */
    {   Vm_Int i;
	if ((i = countObjects())   !=   0) {
	    err(f, "test5","Should be %d objects, found %d\n",0,i);
    }	}

    vm_Invariants( stdout, "t5.4" );

}



/************************************************************************/
/*-    tree_build -- build tree N deep.					*/
/************************************************************************/

static Vm_Obj tree_build(
    Vm_Unt n
) {
    if (!n)   return cons(0,0);
    return cons( tree_build(n-1), tree_build(n-1) );
}



/************************************************************************/
/*-    tree_free -- free() tree.					*/
/************************************************************************/

static void tree_free(
    Vm_Obj o
) {
    if (!o)   return;
    tree_free( car( o ) );
    tree_free( cdr( o ) );
    vm_Free( o );
}



/************************************************************************/
/*-    usage								*/
/************************************************************************/

void usage(void) {
    fprintf( stderr, "usage: x_vm\n" );
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
