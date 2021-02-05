@example  @c
/*--   x-dil.c -- eXerciser for dil.c.					*/
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
/* Created:      98Jan16						*/
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
    for (i = 0;  i < OBJ_TO_INT( DIL_P(n)->slots_used ); ++i) {
	printf("%*s key %" VM_X " val %" VM_X " hash %" VM_X "\n",(int)depth+2,"",DIL_P(n)->slot[i].key,DIL_P(n)->slot[i].val,DIL_P(n)->slot[i].hash);
    }
}

/************************************************************************/
/*-    printNode							*/
/************************************************************************/

void printNode( Vm_Obj n, Vm_Int depth ) {
    if (n == OBJ_NULL_DIL) { printf("%*s NULL\n",(int)depth,""); return; }
    if (OBJ_IS_CLASS_DIL(n)) {
	printLeaf( n, depth );
    } else {
	Vm_Int i;
	printf("%*s node %" VM_X "\n",(int)depth,"",n);
	for (i = 0;  i < OBJ_TO_UNT( DIN_P(n)->slots_used ); ++i) {
	    printf("%*s hash %" VM_X " kid %" VM_X "\n",(int)depth+2,"",DIN_P(n)->slot[i].hash,DIN_P(n)->slot[i].leaf);
	}
	for (i = 0;  i < OBJ_TO_UNT( DIN_P(n)->slots_used ); ++i) {
	    printNode( DIN_P(n)->slot[i].leaf, depth+4 );
	}
    }
}

/************************************************************************/
/*-    validateLeaf							*/
/************************************************************************/

void validateLeaf( Vm_Obj node, Vm_Obj min, Vm_Obj max ) {
    Vm_Int slots_used = OBJ_TO_UNT( DIL_P(node)->slots_used );
    int  i;
    for (i = 0;   i < slots_used;  ++i) {
        if (DIL_P(node)->slot[i].key == OBJ_FROM_INT(0)) {
	    printf("***** validateLeaf2: %" VM_X " key %d is null\n",node,i);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
        if (DIL_P(node)->slot[i].val == OBJ_FROM_INT(0)) {
	    printf("***** validateLeaf2: %" VM_X " val %d is null\n",node,i);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
        if (DIL_P(node)->slot[i].hash != dil_Hash(DIL_P(node)->slot[i].key)) {
	    printf("***** validateLeaf2: %" VM_X " hash %d (%" VM_X ") doesn't match hash (%" VM_X ") of key (%" VM_X ")\n",
node,i,DIL_P(node)->slot[i].hash,dil_Hash(DIL_P(node)->slot[i].key),DIL_P(node)->slot[i].key);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
	if (DIL_P(node)->slot[i].hash < min) {
	    printf("***** validateLeaf2: %" VM_X " hash %d (%" VM_X ") is below minimum %" VM_X "\n",node,i,DIL_P(node)->slot[i].hash,min);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
	if (DIL_P(node)->slot[i].hash >= max) {
	    printf("***** validateLeaf2: %" VM_X " hash %d (%" VM_X ") is above maximum %" VM_X "\n",node,i,DIL_P(node)->slot[i].hash,max);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
    }
    for (i = 1;   i < slots_used;  ++i) {
	if (DIL_P(node)->slot[i].hash < DIL_P(node)->slot[i-1].hash) {
	    printf("***** validateLeaf2: %" VM_X " hash %d is out of order\n",node,i);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
    }
}

/************************************************************************/
/*-    validateNode							*/
/************************************************************************/

void validateNode( Vm_Obj node, Vm_Obj min, Vm_Obj max ) {
    Vm_Int slots_used = OBJ_TO_UNT( DIN_P(node)->slots_used );
    int  i;
    for (i = 0;   i < slots_used;  ++i) {
        if (DIN_P(node)->slot[i].leaf == OBJ_NULL_DIL) {
	    printf("***** validateNode: %" VM_X " leaf %d is NULL\n",node,i);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
	if (DIN_P(node)->slot[i].hash < min) {
	    printf("***** validateNode: %" VM_X " hash %d is below minimum\n",node,i);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
	if (DIN_P(node)->slot[i].hash >= max) {
	    printf("***** validateNode: %" VM_X " hash %d is above maximum\n",node,i);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
    }
    for (i = 1;   i < slots_used;  ++i) {
	if (DIN_P(node)->slot[i].hash < DIN_P(node)->slot[i-1].hash) {
	    printf("***** validateNode: %" VM_X " hash %d is out of order\n",node,i);
            printNode( obj_Dil_Test_Slot, 0 );
	    exit(1);
	}
    }
    for (i = 0;   i < slots_used;  ++i) {
        if (OBJ_IS_CLASS_DIN( DIN_P(node)->slot[i].leaf )) {
	    if (i < slots_used-1) {
		validateNode(
		    DIN_P(node)->slot[i  ].leaf,
		    DIN_P(node)->slot[i  ].hash,
		    DIN_P(node)->slot[i+1].hash
		);
	    } else {
		validateNode(
		    DIN_P(node)->slot[i  ].leaf,
		    DIN_P(node)->slot[i  ].hash,
		    max
		);
	    }
	} else {
	    if (i < slots_used-1) {
		validateLeaf(
		    DIN_P(node)->slot[i  ].leaf,
		    DIN_P(node)->slot[i  ].hash,
		    DIN_P(node)->slot[i+1].hash
		);
	    } else {
		validateLeaf(
		    DIN_P(node)->slot[i  ].leaf,
		    DIN_P(node)->slot[i  ].hash,
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
    if (node == OBJ_NULL_DIL) return;
    if (OBJ_IS_CLASS_DIL(node)) {
	Vm_Int slots_used = OBJ_TO_INT( DIL_P(node)->slots_used );
	if (slots_used==(Vm_Int)0) return;
	min = DIL_P(node)->slot[            0 ].hash;
	max = DIL_P(node)->slot[ slots_used-1 ].hash;
	validateLeaf( node, (Vm_Int)0, ((Vm_Unt)~0)>>1 );
    } else {
	Vm_Int slots_used = OBJ_TO_INT( DIN_P(node)->slots_used );
	if (slots_used==(Vm_Int)0) return;
	min = DIN_P(node)->slot[            0 ].hash;
	max = DIN_P(node)->slot[ slots_used-1 ].hash;
	validateNode( node, (Vm_Int)0, ((Vm_Unt)~0)>>1 );
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
	x   = dil_Get( tree, key );
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
	if ((x=dil_Get( tree, key )) != OBJ_NOT_FOUND) {
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
	tree = dil_Set( tree, key, val, (Vm_Unt)0 );
    }
    
    /* Verify the sets did what we expected: */
    printf("test(%d) set-readback checks...\n",(int)lim);
    for (i = 0;  i < lim;  ++i) {
	makeDecKey(buf,i);
	makeHexKey(byf,i);
	key = stg_From_Asciz( buf );
	val = stg_From_Asciz( byf );
	x = dil_Get( tree, key );
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
	tree = dil_Set( tree, key, val, (Vm_Unt)0 );
    }
    
    /* Verify the restoration: */
    printf("test(%d) set-readback checks...\n",(int)lim);
    for (i = j = 0;  i < lim;  ++i, j = (j+k)%lim) {
	makeDecKey(buf,j);
	makeDecKey(byf,j);
	key = stg_From_Asciz( buf );
	val = stg_From_Asciz( byf );
	x = dil_Get( tree, key );
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
    if (tree!=OBJ_NULL_DIL && dil_FirstInSubtree( &x, tree )) {
        key = x;
	for (i = 0;  i < lim;  ++i) {
	    Vm_Obj lastx=x;
	    Vm_Obj v=dil_Get( tree, x );
	    if (v == OBJ_NOT_FOUND) {
		printf("***** test2d(%d)/dil_Next('%" VM_X "') -- no val'?!\n",(int)lim,x);
		printNode( tree, 0 );
		exit(1);
	    }	
	    if (v == OBJ_FROM_BYT0) {
		printf("***** test2d(%d)/dil_Next('%" VM_X "') -- no val==\"\"'?!\n",(int)lim,x);
		printNode( tree, 0 );
		exit(1);
	    }
	    tree = dil_Set( tree, x, OBJ_FROM_BYT0, (Vm_Unt)0 );
	    if ((x=dil_Next(tree,x))==OBJ_NOT_FOUND) {
		if (i != lim-1) {
		    printf("***** test2d(%d): dil_Next('%" VM_X "') == OBJ_NOT_FOUND'?!\n",(int)lim,lastx);
		    printNode( tree, 0 );
		    exit(1);
		}
	    } else {
		if (i == lim-1) {
		    printf("***** test2d(%d): dil_Next('%" VM_X "') != OBJ_NOT_FOUND'?!\n",(int)lim,lastx);
		    printNode( tree, 0 );
		    exit(1);
		}
	    }
	}
	x = key;
	for (i = 0;  i < lim;  ++i) {
	    Vm_Obj lastx=x;
	    Vm_Obj v=dil_Get( tree, x );
	    if (v==OBJ_NOT_FOUND) {
		printf("***** test2d(%d)/dil_Next('%" VM_X "') -- no val'?!\n",(int)lim,x);
		printNode( tree, 0 );
		exit(1);
	    }	
	    if (v!=OBJ_FROM_BYT0) {
		printf("***** test2d(%d)/dil_Next('%" VM_X "') -- val != \"\"?!\n",(int)lim,x);
		printNode( tree, 0 );
		exit(1);
	    }	
	    if ((x=dil_Next(tree,x))==OBJ_NOT_FOUND) {
		if (i != lim-1) {
		    printf("***** test2d(%d): dil_Next('%" VM_X "') == OBJ_NOT_FOUNDL'?!\n",(int)lim,lastx);
		    printNode( tree, 0 );
		    exit(1);
		}
	    } else {
		if (i == lim-1) {
		    printf("***** test2d(%d): dil_Next('%" VM_X "') != OBJ_NOT_FOUND'?!\n",(int)lim,lastx);
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
        obj_Dil_Test_Slot = dil_Del( obj_Dil_Test_Slot, key );
        validateTree( obj_Dil_Test_Slot );
    }
    if (obj_Dil_Test_Slot != OBJ_NULL_DIL) {
	printf("***** test2d(%d step %d): Tree not empty after deleting everything\n",(int)lim,(int)k);
        printNode( obj_Dil_Test_Slot, 0 );
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
    obj_Dil_Test_Slot = OBJ_NULL_DIL;
    for  (k = 1;   k < lim;   k += 2) {
        printf("test(%d) stepsize %d...\n",(int)lim,(int)k);
	for  (i = j = 0;   i < lim;   ++i, j = (j+k)%lim) {
	    makeDecKey(buf,j);
	    x = stg_From_Asciz( buf );
	    obj_Dil_Test_Slot = dil_Set( obj_Dil_Test_Slot, x, x, (Vm_Unt)0 );
	}
	validateTree( obj_Dil_Test_Slot );
	check( obj_Dil_Test_Slot, lim, k, makeDecKey, makeHexKey );
    }
    printf("test(%d) done.\n",(int)lim);
}

/************************************************************************/
/*-    dil_Test								*/
/************************************************************************/

void dil_Test(
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

printf("x-dil/main top\n");
    if (argC != 1)   usage();

    #if VERBOSE
    printf("\n%s: initializing...\n",argV[0]);
    #endif

    startup();

    dil_Test();

    muq_shutdown();

printf("x-dil/main, bot\n");
    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/


/************************************************************************/
/*-    startup								*/

static void startup( void ) {

printf("x-dil/startup, top\n");
    obj_Startup();
    obj_Linkup();
printf("x-dil/startup, bot\n");

}



/************************************************************************/
/*-    muq_shutdown							*/

static void muq_shutdown(void) {

printf("x-dil/shutdown, top\n");
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
