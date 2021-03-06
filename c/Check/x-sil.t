@example  @c
/*--   x-sil.c -- eXerciser for sil.c.					*/
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
/* Created:      98Mar06						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1999, by Jeff Prothero.				*/
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
/* Please send bug reports/fixes etc to bugs@muq.org.			*/
/************************************************************************/




/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/


/************************************************************************/
/*-    Globals								*/



/************************************************************************/
/*-    Statics								*/

static void startup(  void );
       void usage(    void );
static void muq_shutdown( void );	/* NEXTSTEP preempts 'shutdown' */


/************************************************************************/
/*-    printLeaf							*/
/************************************************************************/

void printLeaf( Vm_Obj n, Vm_Int depth ) {
    Vm_Int i;
    printf("%*s leaf %" VM_X "\n",(int)depth,"",n);
    for (i = 0;  i < OBJ_TO_INT( SIL_P(n)->slots_used ); ++i) {
	printf("%*s key %" VM_X " val %" VM_X " \n",(int)depth+2,"",SIL_P(n)->slot[i].key,SIL_P(n)->slot[i].val);
    }
}

/************************************************************************/
/*-    printNode							*/
/************************************************************************/

void printNode( Vm_Obj n, Vm_Int depth ) {
    if (n == OBJ_NULL_SIL) { printf("%*s NULL\n",(int)depth,""); return; }
    if (OBJ_IS_CLASS_SIL(n)) {
	printLeaf( n, depth );
    } else {
	Vm_Int i;
	printf("%*s node %" VM_X "\n",(int)depth,"",n);
	for (i = 0;  i < OBJ_TO_UNT( SIN_P(n)->slots_used ); ++i) {
	    printf("%*s key %" VM_X " kid %" VM_X "\n",(int)depth+2,"",SIN_P(n)->slot[i].key,SIN_P(n)->slot[i].leaf);
	}
	for (i = 0;  i < OBJ_TO_UNT( SIN_P(n)->slots_used ); ++i) {
	    printNode( SIN_P(n)->slot[i].leaf, depth+4 );
	}
    }
}

/************************************************************************/
/*-    validateLeaf							*/
/************************************************************************/

void validateLeaf( Vm_Obj node, Vm_Obj min, Vm_Obj max ) {
    Vm_Int slots_used = OBJ_TO_UNT( SIL_P(node)->slots_used );
    int  i;
    for (i = 0;   i < slots_used;  ++i) {
        if (SIL_P(node)->slot[i].key == OBJ_FROM_INT(0)) {
	    printf("***** validateLeaf2: %" VM_X " key %d is null\n",node,i);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
        if (SIL_P(node)->slot[i].val == OBJ_FROM_INT(0)) {
	    printf("***** validateLeaf2: %" VM_X " val %d is null\n",node,i);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
	if (obj_Neql( SIL_P(node)->slot[i].key, min ) < 0) {
	    printf("***** validateLeaf2: %" VM_X " key %d (%" VM_X ") is below minimum %" VM_X "\n",node,i,SIL_P(node)->slot[i].key,min);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
	if (max != OBJ_NIL && obj_Neql( SIL_P(node)->slot[i].key, max ) >= 0) {
	    printf("***** validateLeaf2: %" VM_X " key %d (%" VM_X ") is above maximum %" VM_X "\n",node,i,SIL_P(node)->slot[i].key,max);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
    }
    for (i = 1;   i < slots_used;  ++i) {
	if (obj_Neql( SIL_P(node)->slot[i].key, SIL_P(node)->slot[i-1].key) < 0) {
	    printf("***** validateLeaf2: %" VM_X " key %d is out of order\n",node,i);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
    }
}

/************************************************************************/
/*-    validateNode							*/
/************************************************************************/

void validateNode( Vm_Obj node, Vm_Obj min, Vm_Obj max ) {
    Vm_Int slots_used = OBJ_TO_UNT( SIN_P(node)->slots_used );
    int  i;
    for (i = 0;   i < slots_used;  ++i) {
        if (SIN_P(node)->slot[i].leaf == OBJ_NULL_SIL) {
	    printf("***** validateNode: %" VM_X " leaf %d is NULL\n",node,i);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
	if (obj_Neql( SIN_P(node)->slot[i].key, min ) < 0) {
	    printf("***** validateNode: %" VM_X " key %d is below minimum\n",node,i);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
	if (max != OBJ_NIL && obj_Neql( SIN_P(node)->slot[i].key, max ) >= 0) {
	    printf("***** validateNode: %" VM_X " key %d is above maximum\n",node,i);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
    }
    for (i = 1;   i < slots_used;  ++i) {
	if (obj_Neql( SIN_P(node)->slot[i].key, SIN_P(node)->slot[i-1].key) < 0) {
	    printf("***** validateNode: %" VM_X " key %d is out of order\n",node,i);
            printNode( obj_Sil_Test_Slot, 0 );
	    exit(1);
	}
    }
    for (i = 0;   i < slots_used;  ++i) {
        if (OBJ_IS_CLASS_SIN( SIN_P(node)->slot[i].leaf )) {
	    if (i < slots_used-1) {
		validateNode(
		    SIN_P(node)->slot[i  ].leaf,
		    SIN_P(node)->slot[i  ].key,
		    SIN_P(node)->slot[i+1].key
		);
	    } else {
		validateNode(
		    SIN_P(node)->slot[i  ].leaf,
		    SIN_P(node)->slot[i  ].key,
		    max
		);
	    }
	} else {
	    if (i < slots_used-1) {
		validateLeaf(
		    SIN_P(node)->slot[i  ].leaf,
		    SIN_P(node)->slot[i  ].key,
		    SIN_P(node)->slot[i+1].key
		);
	    } else {
		validateLeaf(
		    SIN_P(node)->slot[i  ].leaf,
		    SIN_P(node)->slot[i  ].key,
		    max
		);
	    }
	}
    }
}

/************************************************************************/
/*-    validateTree							*/
/************************************************************************/

void validateTree( Vm_Obj node ) {
    Vm_Obj min;
    Vm_Obj max;
    if (node == OBJ_NULL_SIL) return;
    if (OBJ_IS_CLASS_SIL(node)) {
	Vm_Int slots_used = OBJ_TO_INT( SIL_P(node)->slots_used );
	if (slots_used==(Vm_Int)0) return;
	min = SIL_P(node)->slot[            0 ].key;
	max = SIL_P(node)->slot[ slots_used-1 ].key;
	validateLeaf( node, OBJ_FIRST, OBJ_NIL );
    } else {
	Vm_Int slots_used = OBJ_TO_INT( SIN_P(node)->slots_used );
	if (slots_used==(Vm_Int)0) return;
	min = SIN_P(node)->slot[            0 ].key;
	max = SIN_P(node)->slot[ slots_used-1 ].key;
	validateNode( node, OBJ_FIRST, OBJ_NIL );
    }
}

/************************************************************************/
/*-    makeShortDecKey							*/
/************************************************************************/

void makeShortDecKey( Vm_Uch buf[ 200 ], Vm_Int val ) {
    sprintf( buf, "%" VM_D, val );
} 

/************************************************************************/
/*-    makeShortHexKey							*/
/************************************************************************/

void makeShortHexKey( Vm_Uch buf[ 200 ], Vm_Int val ) {
    sprintf( buf, "%" VM_X, val );
} 

/************************************************************************/
/*-    makeLongDecKey							*/
/************************************************************************/

void makeLongDecKey( Vm_Uch buf[ 200 ], Vm_Int val ) {
    /* Long enough to force BYTN rather than in-pointer string: */
    sprintf( buf, "abcdefghi:%" VM_D, val );
} 

/************************************************************************/
/*-    makeLongHexKey							*/
/************************************************************************/

void makeLongHexKey( Vm_Uch buf[ 200 ], Vm_Int val ) {
    /* Long enough to force BYTN rather than in-pointer string: */
    sprintf( buf, "abcdefghi:%" VM_X, val );
} 

/************************************************************************/
/*-    check								*/
/************************************************************************/

void check(
    Vm_Obj tree,
    Vm_Int lim,
    Vm_Int k,
    void (*makeDecKey)(Vm_Uch buf[ 200 ], Vm_Int val),
    void (*makeHexKey)(Vm_Uch buf[ 200 ], Vm_Int val)
) {
    
    char  buf[ 200 ];
    char  byf[ 200 ];
    Vm_Obj   key;
    Vm_Obj   val;
    Vm_Obj   x;
    Vm_Int   i;
    Vm_Int   j;

    /* Verify we can find everything in tree: */
    printf("test(%d) positive checks...\n",(int)lim);
    for (i = 0;  i < lim;  ++i) {
	makeDecKey(buf,i);
	key = stg_From_Asciz( buf );
	x   = sil_Get( tree, key );
	if (x==OBJ_NOT_FOUND) {
	    printf("***** test(%d): '%s' -> OBJ_NOT_FOUND'?!\n",(int)lim,buf);
            printNode( tree, 0 );
	    exit(1);
	}
	if (obj_Neql(x,key)) {
	    printf("***** test(%d): '%s' -> '%" VM_X "'?!\n",(int)lim,buf,x);
            printNode( tree, 0 );
	    exit(1);
	}
    }
    
    /* Verify we can't find stuff not in tree: */
    printf("test(%d) negative checks...\n",(int)lim);
    for (i = lim;  i < 2*lim;  ++i) {
	makeDecKey(buf,i);
	key = stg_From_Asciz( buf );
	if ((x=sil_Get( tree, key )) != OBJ_NOT_FOUND) {
	    printf("***** test(%d): '%s' -> '%" VM_X "'?!\n",(int)lim,buf,x);
            printNode( tree, 0 );
	    exit(1);
	}
    }

    /* Verify we can set everything in tree: */
    printf("test(%d) set checks...\n",(int)lim);
    for (i = 0;  i < lim;  ++i) {
	makeDecKey(buf,i);
	makeHexKey(byf,i);
	key = stg_From_Asciz( buf );
	val = stg_From_Asciz( byf );
	tree = sil_Set( tree, key, val, (Vm_Unt)0 );
    }
    
    /* Verify the sets did what we expected: */
    printf("test(%d) set-readback checks...\n",(int)lim);
    for (i = 0;  i < lim;  ++i) {
	makeDecKey(buf,i);
	makeHexKey(byf,i);
	key = stg_From_Asciz( buf );
	val = stg_From_Asciz( byf );
	x = sil_Get( tree, key );
	if (x == OBJ_NOT_FOUND) {
	    printf("***** test2d(%d): '%s' -> OBJ_NOT_FOUNDL'?!\n",(int)lim,buf);
            printNode( tree, 0 );
	    exit(1);
	}
	if (obj_Neql(x,val)) {
	    printf("***** test2d(%d): '%s' -> '%" VM_X "'?!\n",(int)lim,buf,x);
            printNode( tree, 0 );
	    exit(1);
	}
    }

    /* Restore everything to previous value: */
    printf("test(%d) set checks...\n",(int)lim);
    for (i = 0;  i < lim;  ++i) {
	makeDecKey(buf,i);
	makeDecKey(byf,i);
	key = stg_From_Asciz( buf );
	val = stg_From_Asciz( byf );
	tree = sil_Set( tree, key, val, (Vm_Unt)0 );
    }
    
    /* Verify the restoration: */
    printf("test(%d) set-readback checks...\n",(int)lim);
    for (i = j = 0;  i < lim;  ++i, j = (j+k)%lim) {
	makeDecKey(buf,j);
	makeDecKey(byf,j);
	key = stg_From_Asciz( buf );
	val = stg_From_Asciz( byf );
	x = sil_Get( tree, key );
	if (x == OBJ_NOT_FOUND) {
	    printf("***** test2d(%d): '%s' -> OBJ_NOT_FOUND'?!\n",(int)lim,buf);
            printNode( tree, 0 );
	    exit(1);
	}
	if (obj_Neql(x,val)) {
	    printf("***** test2d(%d): '%s' -> '%" VM_X "'?!\n",(int)lim,buf,x);
            printNode( tree, 0 );
	    exit(1);
	}
    }

    /* Verify 'next' returns expected value for everything in tree: */
    printf("test(%d) next checks...\n",(int)lim);
    if (tree!=OBJ_NULL_SIL && sil_FirstInSubtree( &x, tree )) {
        key = x;
	for (i = 0;  i < lim;  ++i) {
	    Vm_Obj lastx=x;
	    Vm_Obj v=sil_Get( tree, x );
	    if (v == OBJ_NOT_FOUND) {
		printf("***** test2d(%d)/sil_Next('%" VM_X "') -- no val'?!\n",(int)lim,x);
		printNode( tree, 0 );
		exit(1);
	    }	
	    if (v == OBJ_FROM_BYT0) {
		printf("***** test2d(%d)/sil_Next('%" VM_X "') -- no val==\"\"'?!\n",(int)lim,x);
		printNode( tree, 0 );
		exit(1);
	    }
	    tree = sil_Set( tree, x, OBJ_FROM_BYT0, (Vm_Unt)0 );
	    if ((x=sil_Next(tree,x))==OBJ_NOT_FOUND) {
		if (i != lim-1) {
		    printf("***** test2d(%d): sil_Next('%" VM_X "') == OBJ_NOT_FOUND'?!\n",(int)lim,lastx);
		    printNode( tree, 0 );
		    exit(1);
		}
	    } else {
		if (i == lim-1) {
		    printf("***** test2d(%d): sil_Next('%" VM_X "') != OBJ_NOT_FOUND'?!\n",(int)lim,lastx);
		    printNode( tree, 0 );
		    exit(1);
		}
	    }
	}
	x = key;
	for (i = 0;  i < lim;  ++i) {
	    Vm_Obj lastx=x;
	    Vm_Obj v=sil_Get( tree, x );
	    if (v==OBJ_NOT_FOUND) {
		printf("***** test2d(%d)/sil_Next('%" VM_X "') -- no val'?!\n",(int)lim,x);
		printNode( tree, 0 );
		exit(1);
	    }	
	    if (v!=OBJ_FROM_BYT0) {
		printf("***** test2d(%d)/sil_Next('%" VM_X "') -- val != \"\"?!\n",(int)lim,x);
		printNode( tree, 0 );
		exit(1);
	    }	
	    if ((x=sil_Next(tree,x))==OBJ_NOT_FOUND) {
		if (i != lim-1) {
		    printf("***** test2d(%d): sil_Next('%" VM_X "') == OBJ_NOT_FOUNDL'?!\n",(int)lim,lastx);
		    printNode( tree, 0 );
		    exit(1);
		}
	    } else {
		if (i == lim-1) {
		    printf("***** test2d(%d): sil_Next('%" VM_X "') != OBJ_NOT_FOUND'?!\n",(int)lim,lastx);
		    printNode( tree, 0 );
		    exit(1);
		}
	    }
	}
    }
    
    /* Delete everything in the tree: */
    printf("test(%d) deleting, BEFORE:\n",(int)lim);
    for (i = j = 0;  i < lim;  ++i, j = (j+k)%lim) {
	makeDecKey(buf,j);
	key = stg_From_Asciz( buf );
        obj_Sil_Test_Slot = sil_Del( obj_Sil_Test_Slot, key );
        validateTree( obj_Sil_Test_Slot );
    }
    if (obj_Sil_Test_Slot != OBJ_NULL_SIL) {
	printf("***** test2d(%d step %d): Tree not empty after deleting everything\n",(int)lim,(int)k);
        printNode( obj_Sil_Test_Slot, 0 );
	exit(1);
    }

    printf("test(%d) DONE\n",(int)lim);
}

/************************************************************************/
/*-    test								*/
/************************************************************************/

void test(
    Vm_Int lim,
    void (*makeDecKey)(Vm_Uch buf[ 200 ], Vm_Int val),
    void (*makeHexKey)(Vm_Uch buf[ 200 ], Vm_Int val)
) {

    /* Build the tree: */
    char  buf[ 200 ];
    Vm_Obj   x;
    Vm_Int   i;
    Vm_Int   j;
    Vm_Int   k;
    obj_Sil_Test_Slot = OBJ_NULL_SIL;
    for  (k = 1;   k < lim;   k += 2) {
        printf("test(%d) stepsize %d...\n",(int)lim,(int)k);
	for  (i = j = 0;   i < lim;   ++i, j = (j+k)%lim) {
	    makeDecKey(buf,j);
	    x = stg_From_Asciz( buf );
	    obj_Sil_Test_Slot = sil_Set( obj_Sil_Test_Slot, x, x, (Vm_Unt)0 );
	}
	validateTree( obj_Sil_Test_Slot );
	check( obj_Sil_Test_Slot, lim, k, makeDecKey, makeHexKey );
    }
    printf("test(%d) done.\n",(int)lim);
}

/************************************************************************/
/*-    sil_Test								*/
/************************************************************************/

void sil_Test(
    void
) {

    test(   0, makeShortDecKey, makeShortHexKey );	
    test(   1, makeShortDecKey, makeShortHexKey );
    test(   2, makeShortDecKey, makeShortHexKey );
    test(   8, makeShortDecKey, makeShortHexKey );
    test( 256, makeShortDecKey, makeShortHexKey );

    test(   0, makeLongDecKey, makeLongHexKey );	
    test(   1, makeLongDecKey, makeLongHexKey );
    test(   2, makeLongDecKey, makeLongHexKey );
    test(   8, makeLongDecKey, makeLongHexKey );
    test( 256, makeLongDecKey, makeLongHexKey );

/*  test(1024);	*/
/*  test(8192);	*/

    printf("Done!!\n");
}

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

printf("x-sil/main top\n");
    if (argC != 1)   usage();

    #if VERBOSE
    printf("\n%s: initializing...\n",argV[0]);
    #endif

    startup();

    sil_Test();

    muq_shutdown();

printf("x-sil/main, bot\n");
    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/


/************************************************************************/
/*-    startup								*/

static void startup( void ) {

printf("x-sil/startup, top\n");
    obj_Startup();
    obj_Linkup();
printf("x-sil/startup, bot\n");

}



/************************************************************************/
/*-    muq_shutdown							*/

static void muq_shutdown(void) {

printf("x-sil/shutdown, top\n");
    obj_Shutdown();

    putchar('\n');
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
