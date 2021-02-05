@example  @c
/*--   d3l.c -- DIrectory Leafs: b-trees for Muq propdirs.		*/
/*--   d3n.c -- DIrectory Nodes.					*/
/*									*/
/*	Hashed btrees, used in hsh.t (Hash) objects.			*/
/*									*/
/*- This file is formatted for outline-minor-mode in emacs19.		*/
/*-^C^O^A shows All of file.						*/
/* ^C^O^Q Quickfolds entire file. (Leaves only top-level head3ngs.)	*/
/* ^C^O^T hides all Text. (Leaves all head3ngs.)			*/
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
/* Created:      99Nov05						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 2000, by Jeff Prothero.				*/
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
/* JEFF PROTHERO DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
/* INCLUD3NG ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	*/
/* NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	*/
/* CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	*/
/* OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		*/
/* NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	*/
/* WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.			*/
/*									*/
/* Please send bug reports/fixes etc to cynbe@@muq.org.			*/
/************************************************************************/


/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/*
   This is intended to become a general-purpose 3D indexing
   datastructure, the 3D equivalent of B-trees.

   It should support an API like:

      Insert a bounding sphere plus a value for that sphere.

      Find all values within a given sphere.
      Find all values containing a given sphere.
      Find all values intersecting a given sphere.

   Unresolved:

      Should we be able to delete an object without giving
      its bounding sphere?

      Should we be able to ask what the bounding sphere for
      a given object is?

   If so, we need a conventional B-tree mapping values to
   spheres, as well, no?

   At the moment I'm undecided as to whether the basic algorithm
   should be a R-tree or R*-tree, or whether it should be a
   Morton-keyed B-tree.

   Initially I only knew about R-trees.

   When I discovered Morton and Peano &tc keys, using a standard B-tree
   algorithm together with an added key construction algorithm
   sounded very good.

   After looking at it for an afternoon or so, however, the key
   construction algorithm looks messy, and in the general case the
   keys look too big to store explicitly, and so slow to construct
   as to negate any speed advantage.  Also, I still haven't figured
   out the exact key construction algorithm *blush*.  So I'm leaning
   back to R-trees.

*/

/************************************************************************/
/* Main entrypoints are:                            			*/
/*                                                  			*/
/************************************************************************/


/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"

/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Vm_Flt format has 11 bits exponent, 52 bits mantissa: */
#define MANTISSA_BITS ((Vm_Int)52)
#define MANTISSA_MASK ((((Vm_Int)1)<<MANTISSA_BITS)-((Vm_*Int)1))
#define EXPONENT_BITS ((Vm_Int)11)
#define EXPONENT_MASK ((((Vm_Int)1)<<EXPONENT_BITS)-((Vm_*Int)1))
#define D3L_KEY_WORDS ((1<<11) >> VM_LOG2_INTBITS) /* +2? */

/************************************************************************/
/*-    Types								*/
/************************************************************************/

struct D3l_bit_interleaved_key {
    Vm_Int key[ D3L_KEY_WORDS ];
};

/************************************************************************/
/*-    Statics								*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
struct D3l_Slot_Rec d3l_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_FROM_UNT( (Vm_Int)0 ),	/* Prefer NIL, but compiler won't allow it. */
    OBJ_FROM_UNT( (Vm_Int)0 )	/* Prefer NIL, but compiler won't allow it. */
};

struct D3n_Slot_Rec d3n_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_NULL_D3L
};

static void
make_bit_interleaved_key(
    struct D3l_bit_interleaved_key * result,
    Vm_Obj x,
    Vm_Obj y,
    Vm_Obj z
);
#endif


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void d3l_doTypes(void){
}
Obj_A_Module_Summary d3l_Module_Summary = {
   "d3l",
    d3l_doTypes,
    d3l_Startup,
    d3l_Linkup,
    d3l_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property d3l_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};
static Obj_A_Special_Property d3n_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

static void     for_new_d3l(     Vm_Obj, Vm_Unt );
static void     for_new_d3n(     Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_d3l(  Vm_Unt );
static Vm_Unt   sizeof_d3n(  Vm_Unt );

Obj_A_Hardcoded_Class d3l_Hardcoded_Class = {
    OBJ_FROM_BYT3('d','3','l'),
    "Btree3DLeaf",
    sizeof_d3l,
    for_new_d3l,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { d3l_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class d3n_Hardcoded_Class = {
    OBJ_FROM_BYT3('d','3','n'),
    "Btree3DNode",
    sizeof_d3n,
    for_new_d3n,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { d3n_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};


/************************************************************************/
/*-    d3l_copy								*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Obj
d3l_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_D3L, 0 );
    D3l_P d;
    D3l_P s;
    vm_Loc2( (void**)&d, (void**)&s, nu, me );
    d->slots_used = s->slots_used;
    {   int   i;
	for (i = D3L_SLOTS; i --> 0; ) d->slot[i] = s->slot[i];
    }
    vm_Dirty(nu);
    return nu;
}
#endif

/************************************************************************/
/*-    d3n_copy								*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
/* buggo, this can take unbounded time, so it should be in-db, not inserver: */
static Vm_Obj
d3n_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_D3N, 0 );
    Vm_Obj su;
    int    s;
    D3N_P(nu)->slots_used = su = D3N_P(me)->slots_used;
    vm_Dirty(nu);
    s  = (int) OBJ_TO_INT( su );	
    {   int  i;
	for (i = 0;   i < s;   ++i) {
	    struct D3n_Slot_Rec r   = D3N_P(me)->slot[i];
	    Vm_Obj o = r.leaf;
	    if (OBJ_IS_OBJ(o)) {
		if      (OBJ_IS_CLASS_D3L(o)) r.leaf = d3l_copy(o);
		else if (OBJ_IS_CLASS_D3L(o)) r.leaf = d3n_copy(o);
	    }
	    D3N_P(nu)->slot[i] = r;
	    vm_Dirty(nu);
    }	}

    return nu;
}
#endif

/************************************************************************/
/*-    d3l_Copy								*/
/************************************************************************/


#ifdef MAYBE_SOMEDAY
Vm_Obj
d3l_Copy(
    Vm_Obj me
) {
    if (me == OBJ_NULL_D3L)   return OBJ_NULL_D3L;
    if (!OBJ_IS_OBJ(me)) {
	MUQ_WARN("Bad 'me' value in d3l_Copy");
    }
    if (OBJ_IS_CLASS_D3L(me)) {
	return d3l_copy( me );
    } else if (OBJ_IS_CLASS_D3N(me)) {
	return d3n_copy( me );
    }
    MUQ_WARN("Bad 'me' value in d3l_Copy");
    return me;	/* Purely to pacify compilers. */
}
#endif

/************************************************************************/
/*-    splitWhileInsertingInLeaf					*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Obj
splitWhileInsertingInLeaf(
    Vm_Obj me,
    D3l_Slot s
) {

    Vm_Int slots_used = OBJ_TO_INT( D3L_P(me)->slots_used );
    struct D3l_Slot_Rec tmp;

    /* Insert 's' into 'me' in sorted order: */
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	Vm_Obj h = D3L_P(me)->slot[i].hash;
	if (s->hash   < h) {
	    /* Swap me and slot[i]: */
	    tmp         = *s;
	    *s          = D3L_P(me)->slot[i];
	    D3L_P(me)->slot[i] = tmp;	    			vm_Dirty(me);
	} else {
	    if (s->hash  == h
	    && !obj_Neql( s->key, D3L_P(me)->slot[i].key )
	    ){
	        /* Our key is already present, we can just  */
	        /* set the value slot rather than inserting */
	        /* a new key-val-hash triple into leaf:     */ 
		D3L_P(me)->slot[i].val = s->val;		vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    }
	}
    }
    if (slots_used < D3L_SLOTS) {
        /* Leaf isn't full, we can complete the   */
        /* insertion operation by append3ng final */
        /* key-val-hash triple:                   */
	D3L_P(me)->slot[ slots_used ] = *s;
	D3L_P(me)->slots_used = OBJ_FROM_UNT( slots_used +1 );	vm_Dirty(me);
	return OBJ_FROM_INT(0);
    }
    {   /* Leaf is full, only way to complete the */
        /* insert operation is to allocate a new  */
        /* leaf and split leaf contents between   */
        /* the old and new leafs.                 */
        /*                                        */
        /* Split available slots evenly between   */
	/* two leafs, leaving each containing one */
	/* more full than empty slot.  (Remember  */
	/* that a full leaf has an odd number of  */
	/* of slots, and we have one more than a  */
	/* leaf-full of slots.)                   */
	/* Hash collisions motivate an exception: */
	/* We can't end the first block with the  */
	/* same hash value beginning the second   */
	/* block.  If all 32 values have the same */
	/* hash value, we fail.	 With a good hash */
        /* function (SHA-1), the chance of this   */
        /* happening should be negligible:        */
	Vm_Obj   nu    = obj_Alloc_In_Dbfile(
	    OBJ_CLASS_A_D3L,
	    0,
	    VM_DBFILE(me)
	);

	/* Pick split point.  This will be the	  */
	/* midpoint barring hash collisions:      */
	Vm_Int   m;	/* 'm'iddle -- split point */
	for  (m =(D3L_SLOTS/2);
	      m < D3L_SLOTS-1  &&  D3L_P(me)->slot[m].hash==D3L_P(me)->slot[m-1].hash;
	      m++
	);
	for  (;
	      m > 1  &&  D3L_P(me)->slot[m].hash == D3L_P(me)->slot[m-1].hash;
	      m--
	);
	if (D3L_P(me)->slot[m].hash == D3L_P(me)->slot[m-1].hash) {
	    MUQ_WARN("Too many hash collisions");
	}

	tmp.hash = OBJ_FROM_UNT( (Vm_Unt)0 );
	tmp.key  = OBJ_FROM_INT( (Vm_Unt)0 );
	tmp.val  = OBJ_FROM_INT( (Vm_Unt)0 );
	/* Over all slots in nu to be filled from me: */
	for (i = 0; i < D3L_SLOTS-m;  ++i) {
	    Vm_Int j = i + m;
	    D3L_P(nu)->slot[ i ] = D3L_P(me)->slot[ j ]; 			vm_Dirty(nu);
	    D3L_P(me)->slot[ j ] = tmp;	/* Clear free slots */			vm_Dirty(me);
	}
	D3L_P(nu)->slot[ D3L_SLOTS-m ] = *s;	 				vm_Dirty(nu);
	D3L_P(me)->slots_used = OBJ_FROM_UNT( m                         );	vm_Dirty(me);
	D3L_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((D3L_SLOTS+1)-m) );	vm_Dirty(nu);

	return nu;
    }
}
#endif

/************************************************************************/
/*-    findSlotFor							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
findSlotFor(
    Vm_Obj me,
    D3l_Slot s
) {
    Vm_Int i;
    for   (i = OBJ_TO_INT( D3N_P(me)->slots_used );   --i > 0;   ) {
	if (s->hash >= D3N_P(me)->slot[i].hash)  break;
    }
    return i;
}
#endif

/************************************************************************/
/*-    splitWhileInsertingSlot						*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Obj
splitWhileInsertingSlot(
    Vm_Obj   me,
    D3l_Slot s
) {
    if (OBJ_IS_CLASS_D3L(me)) {
	return splitWhileInsertingInLeaf( me, s );
    } else {
	Vm_Obj nu;
	struct D3n_Slot_Rec ss;
	struct D3n_Slot_Rec tmp;
        Vm_Int    meSlot = findSlotFor(me,s);
        Vm_Obj    mynod  = D3N_P(me)->slot[meSlot].leaf;
	nu = splitWhileInsertingSlot( mynod, s );
	if (nu == OBJ_FROM_INT(0))   return OBJ_FROM_INT(0);
	if (OBJ_IS_CLASS_D3L(nu))   ss.hash = D3L_P(nu)->slot[0].hash;
	else                        ss.hash = D3N_P(nu)->slot[0].hash;
	ss.leaf = nu;
	{   Vm_Int slots_used = OBJ_TO_UNT( D3N_P(me)->slots_used );
	    Vm_Int    i;
	    for   (i = meSlot+1;   i < slots_used;   ++i) {
		/* Swap me and slot[i]: */
		tmp         = ss;
		ss          = D3N_P(me)->slot[i];
		D3N_P(me)->slot[i] = tmp;		                           vm_Dirty(me);
	    }
	    if (slots_used < D3N_SLOTS) {
		D3N_P(me)->slot[ slots_used ] = ss;			           vm_Dirty(me);
		D3N_P(me)->slots_used = OBJ_FROM_UNT( slots_used+1 );	           vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    } else {
		Vm_Obj nu = obj_Alloc_In_Dbfile(
		    OBJ_CLASS_A_D3N,
		    0,
		    VM_DBFILE(me)
		);
		/* Split available slots evenly between   */
		/* two nodes, leaving each containing one */
		/* more full than empty slot.  (Remember  */
		/* that a full node has an odd number of  */
		/* of slots, and we have one more than a  */
		/* leaffull of slots.)                    */
		for (i = 0; i   < D3N_SLOTS/2;  ++i) {
		    Vm_Int j = i + ((D3N_SLOTS/2)+1);
		    D3N_P(nu)->slot[ i ] = D3N_P(me)->slot[ j ];	           vm_Dirty(nu);
		    D3N_P(me)->slot[ j ] = d3n_nil;	/* Clear free slots */	   vm_Dirty(me);
		    
		}
		D3N_P(nu)->slot[ D3N_SLOTS/2 ] = ss;	                           vm_Dirty(nu);
		D3N_P(me)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((D3N_SLOTS/2)+1) ); vm_Dirty(me);
		D3N_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((D3N_SLOTS/2)+1) ); vm_Dirty(nu);
		return nu;
	    }
	}
    }
}
#endif

/************************************************************************/
/*-    d3l_Set								*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
Vm_Obj
d3l_Set(
    Vm_Obj me,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Unt dbfile
) {
    Vm_Obj            nu;
    struct D3l_Slot_Rec tmp;
    tmp.hash= d3l_Hash(key);
    tmp.key = key;
    tmp.val = val;

    if (me == OBJ_NULL_D3L) {
	me              = obj_Alloc_In_Dbfile( OBJ_CLASS_A_D3L, 0, dbfile );
	D3L_P(me)->slots_used  = OBJ_FROM_UNT( (Vm_Unt)1 );
	D3L_P(me)->slot[0]     = tmp;				vm_Dirty(me);
	return me;
    }
    if ((nu = splitWhileInsertingSlot( me, &tmp )) != OBJ_FROM_INT(0)) {
        Vm_Obj r       = obj_Alloc_In_Dbfile(OBJ_CLASS_A_D3N,0,VM_DBFILE(me));
	Vm_Obj h;
	if (OBJ_IS_CLASS_D3L(nu))   h = D3L_P(nu)->slot[0].hash;
	else                        h = D3N_P(nu)->slot[0].hash;
	{   D3n_P s = D3N_P(r);
	    s->slots_used  = OBJ_FROM_UNT( (Vm_Unt)2 );
	    s->slot[0].hash= OBJ_FROM_UNT( (Vm_Unt)0 );
	    s->slot[0].leaf= me;
	    s->slot[1].hash= h;
	    s->slot[1].leaf= nu;
	}
	vm_Dirty(r);
	return r;
    }
    return me;
}
#endif

/************************************************************************/
/*-    dropLeafSlot							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
dropLeafSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int  slots_used = OBJ_TO_INT( D3L_P(me)->slots_used );
    Vm_Int  i;
    for    (i = slot;   i < slots_used-1;   ++i) {
	D3L_P(me)->slot[i] = D3L_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    D3L_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    D3L_P(me)->slot[ slots_used ] = d3l_nil;			vm_Dirty(me);
   return  slots_used <= D3L_SLOTS/2;
}
#endif

/************************************************************************/
/*-    dropNodeSlot							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
dropNodeSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int slots_used = OBJ_TO_INT( D3N_P(me)->slots_used );
    Vm_Int i;
    for   (i = slot;   i < slots_used-1;   ++i) {
	D3N_P(me)->slot[i] = D3N_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    D3N_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    D3N_P(me)->slot[ slots_used ]= d3n_nil;			vm_Dirty(me);
   return  slots_used <= D3N_SLOTS/2;
}
#endif

/************************************************************************/
/*-    mergedLeafs							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
mergedLeafs(
    Vm_Obj me,
    Vm_Int slotA,
    Vm_Int slotB
) {

    Vm_Int slots_used = OBJ_TO_INT( D3N_P(me)->slots_used );

    struct D3l_Slot_Rec nul;
    nul.hash = OBJ_FROM_UNT( 0 );
    nul.key  = OBJ_FROM_INT( 0 );
    nul.val  = OBJ_FROM_INT( 0 );

    if (slotA < 0 || slotB >= slots_used) {
	return FALSE;
    }

    {	Vm_Obj a  = D3N_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = D3N_P(me)->slot[ slotB ].leaf;
	
	/* mustBeLeaf(a); */
	/* mustBeLeaf(b); */

	{   Vm_Int aSlots = OBJ_TO_INT( D3L_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( D3L_P(b)->slots_used );
	    if (aSlots + bSlots > D3L_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int  i;
		for (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    D3L_P(a)->slot[i] = D3L_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    D3L_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    D3L_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);	
	    D3L_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
	}
    }

    return TRUE;
}
#endif

/************************************************************************/
/*-    mergedNodes							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
mergedNodes(
    Vm_Obj me,
    Vm_Int slotA,
    Vm_Int slotB
) {

    Vm_Int slots_used = OBJ_TO_INT( D3N_P(me)->slots_used );

    struct D3n_Slot_Rec nul;
    nul.hash = OBJ_FROM_UNT( 0 );
    nul.leaf = OBJ_FROM_INT( 0 );

    /*mustBeNode(me)*/;
    if (slotA < 0 || slotB >= slots_used) {
        return FALSE;
    }

    {	Vm_Obj a  = D3N_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = D3N_P(me)->slot[ slotB ].leaf;

	/*mustBeNode(a);*/
	/*mustBeNode(b);*/

	{   Vm_Int aSlots = OBJ_TO_INT( D3N_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( D3N_P(b)->slots_used );
	    if (aSlots + bSlots > D3N_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int i;
		for   (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    D3N_P(a)->slot[i] = D3N_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    D3N_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    D3N_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);
	    D3N_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
	}
    }
    return TRUE;
}
#endif

/************************************************************************/
/*-    deleteInLeaf							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
deleteInLeaf(
    Vm_Obj me,
    D3l_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( D3L_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	if (s->hash == D3L_P(me)->slot[i].hash
	&&	!obj_Neql( s->key, D3L_P(me)->slot[i].key )    
	){
	    return dropLeafSlot( me, i );
	}
    }
    return OBJ_TO_INT( D3L_P(me)->slots_used ) <= (D3L_SLOTS/2);
}
#endif

/************************************************************************/
/*-    deleteInNode							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
deleteInNode(
    Vm_Obj me,
    D3l_Slot s
 ) {
    Vm_Int meSlot = findSlotFor(me,s);
    Vm_Obj kid    = D3N_P(me)->slot[ meSlot ].leaf;
    if (OBJ_IS_CLASS_D3L(kid)) {
	Vm_Int mostlyEmpty = deleteInLeaf( kid, s );
	if (mostlyEmpty) {
	    if (mergedLeafs( me, meSlot-1, meSlot   )) {
		return dropNodeSlot( me, meSlot );
	    }
	    if (mergedLeafs( me, meSlot  , meSlot+1 )) {
		return dropNodeSlot( me, meSlot+1 );
	    }
	}
    } else {
        Vm_Int mostlyEmpty = deleteInNode( kid, s );
	if (mostlyEmpty) {
	    if (mergedNodes( me, meSlot-1, meSlot   )) {
		return dropNodeSlot( me, meSlot );
	    }
	    if (mergedNodes( me, meSlot  , meSlot+1 )) {
		return dropNodeSlot( me, meSlot+1 );
	    }
	}
    }
    return OBJ_TO_INT( D3N_P(me)->slots_used ) <= (D3N_SLOTS/2);
}
#endif

/************************************************************************/
/*-    d3l_Del								*/
/************************************************************************/

Vm_Obj
d3l_Del(
    Vm_Obj me,
    Vm_Obj key
) {
#ifdef MAYBE_SOMEDAY
    struct D3l_Slot_Rec tmp;
    tmp.hash= d3l_Hash(key);
    tmp.key = key;
    tmp.val = OBJ_FROM_INT( (Vm_Int)0 );
    if (me == OBJ_NULL_D3L) return OBJ_NULL_D3L;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_D3L(me)
    &&	!OBJ_IS_CLASS_D3N(me))
    ){
	MUQ_FATAL("Bad 'me' value in d3l_Del");
    }
    if (OBJ_IS_CLASS_D3L(me)) {
        deleteInLeaf( me, &tmp );
	/* An empty leaf node can be discarded: */
	if (OBJ_TO_UNT( D3L_P(me)->slots_used ) == (Vm_Unt)0) {
	    return OBJ_NULL_D3L;
	}
    } else {
        deleteInNode( me, &tmp );
	/* An internal node with just one child can be discarded: */
	if (OBJ_TO_UNT( D3N_P(me)->slots_used ) == (Vm_Unt)1) {
	    return D3N_P(me)->slot[0].leaf;
	}
    }
    return me;
#else
    MUQ_WARN("d3l_Del unimplemented");
    return OBJ_NIL; /* Just to quiet compilers */
#endif
}

/************************************************************************/
/*-    findInLeaf							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Obj
findInLeaf(
    Vm_Obj me,
    D3l_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( D3L_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	if (s->hash == D3L_P(me)->slot[i].hash
	&&	!obj_Neql( s->key, D3L_P(me)->slot[i].key )    
	){
	    return D3L_P(me)->slot[i].val;
	}
    }
    return OBJ_NOT_FOUND;
}
#endif

/************************************************************************/
/*-    valb								*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Obj
valb(
    Vm_Obj me,
    D3l_Slot s
) {
    if (OBJ_IS_CLASS_D3L(me)) {
        return findInLeaf( me, s );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = D3N_P(me)->slot[ meSlot ].leaf;
	return         valb( oe, s );
    }
}
#endif

/************************************************************************/
/*-    d3l_Alloc							*/
/************************************************************************/

Vm_Obj
d3l_Alloc(
    void
) {
    /* Buggo? OBJ_NULL_D3L has no dbfile info associated    */
    /* with it, which ultimately means that job_P_Btree_Set */
    /* sometimes has to guess what dbfile to use.           */
    return OBJ_NULL_D3L;
}

/************************************************************************/
/*-    d3l_Get								*/
/************************************************************************/

Vm_Obj
d3l_Get(
    Vm_Obj me,
    Vm_Obj key
) {
#ifdef MAYBE_SOMEDAY
    struct D3l_Slot_Rec tmp;
    tmp.hash= d3l_Hash(key);
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me == OBJ_NULL_D3L) {
        return OBJ_NOT_FOUND;
    }
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_D3L(me)
    &&	!OBJ_IS_CLASS_D3N(me))
    ){
        Vm_Uch buf[ 32 ];
        job_Sprint_Vm_Obj( buf, buf+32, me, /*quotestrings:*/TRUE );
	MUQ_FATAL("Bad 'me' value in d3l_Get %s",buf);
    }
    return valb( me, &tmp );
#else
    MUQ_WARN("d3l_Get unimplemented");
    return OBJ_NIL; /* Just to quiet compilers */
#endif
}

/************************************************************************/
/*-    d3l_FirstInSubtree						*/
/************************************************************************/

Vm_Int
d3l_FirstInSubtree(
    Vm_Obj* result,
    Vm_Obj me
) {
#ifdef MAYBE_SOMEDAY
    if (OBJ_IS_CLASS_D3L(me)) {
	if (OBJ_TO_INT(D3L_P(me)->slots_used)==(Vm_Int)0)   return FALSE;
	*result = D3L_P(me)->slot[0].key;
	return TRUE;
    }
    return d3l_FirstInSubtree( result, D3N_P(me)->slot[0].leaf );
#else
    MUQ_WARN("d3l_FirstInSubtree unimplemented");
    return OBJ_NIL; /* Just to quiet compilers */
#endif
}

/************************************************************************/
/*-    d3l_First							*/
/************************************************************************/

Vm_Obj
d3l_First(
    Vm_Obj me
) {
#ifdef MAYBE_SOMEDAY
    Vm_Obj result;
    if (me==OBJ_NULL_D3L) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_D3L(me)
    &&	!OBJ_IS_CLASS_D3N(me))
    ){
	MUQ_FATAL("Bad 'me' value in d3l_First");
    }
    if (d3l_FirstInSubtree( &result, me )) {
	return result;
    } else {
	return OBJ_NOT_FOUND;
    }
#else
    MUQ_WARN("d3l_First unimplemented");
    return OBJ_NIL; /* Just to quiet compilers */
#endif
}

/************************************************************************/
/*-    nextInLeaf							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
nextInLeaf(
    Vm_Obj* result,
    Vm_Obj me,
    D3l_Slot s
) {
    /*mustBeLeaf(me);*/
    {   Vm_Int slots_used = OBJ_TO_INT( D3L_P(me)->slots_used );
	Vm_Int i;
	for   (i = 0;   i < slots_used;   ++i) {
	    if (s->hash == D3L_P(me)->slot[i].hash
	    &&	!obj_Neql( s->key, D3L_P(me)->slot[i].key )    
	    ){
	        if (i+1 == slots_used)  return FALSE;
	        *result = D3L_P(me)->slot[i+1].key;
		return TRUE;
	    }
	}
	return FALSE;
    }
}
#endif

/************************************************************************/
/*-    nextInNode							*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
static Vm_Int
nextInNode(
    Vm_Obj* result,
    Vm_Obj me,
    D3l_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( D3N_P(me)->slots_used );
    Vm_Int meSlot     = findSlotFor(me,s);
    Vm_Obj oe         = D3N_P(me)->slot[ meSlot ].leaf;
    /*mustBeNode(me);*/
    if (OBJ_IS_CLASS_D3L(oe)) {
	if (nextInLeaf( result, oe, s ))   return TRUE;
	if (meSlot+1 < slots_used) {
	    return d3l_FirstInSubtree( result, D3N_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    } else {
	if (nextInNode( result, oe, s ))          return TRUE;
	if (meSlot+1 < slots_used) {
	    return d3l_FirstInSubtree( result, D3N_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    }
}
#endif

/************************************************************************/
/*-    d3l_Next								*/
/************************************************************************/

Vm_Obj
d3l_Next(
    Vm_Obj me,
    Vm_Obj key
) {
#ifdef MAYBE_SOMEDAY
    Vm_Obj  result;
    struct D3l_Slot_Rec tmp;
    if (key==OBJ_FIRST)   return d3l_First( me );
    tmp.hash= d3l_Hash(key);
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me==OBJ_NULL_D3L) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_D3L(me)
    &&	!OBJ_IS_CLASS_D3N(me))
    ){
	MUQ_FATAL("Bad 'me' value in d3l_Del");
    }
    if (OBJ_IS_CLASS_D3L(me)) {
        if (nextInLeaf( &result, me, &tmp )) {
	    return result;
	} else {
	    return OBJ_NOT_FOUND;
	}
    } else {
	if (nextInNode( &result, me, &tmp )) {
	    return result;
	} else {
	    return OBJ_NOT_FOUND;
	}
    }
#else
    MUQ_WARN("d3l_Next unimplemented");
    return OBJ_NIL; /* Just to quiet compilers */
#endif
}

/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    d3l_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
d3l_Startup (
    void
) {
    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;

#ifdef MAYBE_SOMEDAY
    if (sizeof(D3l_A_Header) > 512
    || sizeof(D3l_A_Header)+2*sizeof(struct D3l_Slot_Rec) < 512
    ){
        printf("*****  sizeof D3l_A_Header d=%d\n",sizeof(D3l_A_Header));
    }


    if (sizeof(D3n_A_Header) > 512
    || sizeof(D3n_A_Header)+2*sizeof(struct D3n_Slot_Rec) < 512
    ){
        printf("*****  sizeof D3n_A_Header d=%d\n",sizeof(D3n_A_Header));
    }

    obj_D3l_Test_Slot = OBJ_NULL_D3L;
#endif
}



/************************************************************************/
/*-    d3l_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
d3l_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    d3l_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
d3l_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}

/************************************************************************/
/*-    --- Standard static fns ---					*/
/************************************************************************/

/************************************************************************/
/*-    for_new_d3l -- Initialize new d3l object.			*/
/************************************************************************/

static void
for_new_d3l(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
#ifdef MAYBE_SOMEDAY
    int   i;
    D3l_P s 	= D3L_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = D3L_SLOTS;   i --> 0;   )   s->slot[i] = d3l_nil;
#endif
    vm_Dirty(o);
}

static void
for_new_d3n(
    Vm_Obj o,
    Vm_Unt size
) {
#ifdef MAYBE_SOMEDAY
    int   i;
    D3n_P s 	= D3N_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = D3N_SLOTS;   i --> 0;   )   s->slot[i] = d3n_nil;
#endif
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_d3l -- Return size of dir-leaf.				*/
/************************************************************************/

static Vm_Unt
sizeof_d3l(
    Vm_Unt size
) {
    return sizeof( D3l_A_Header );
}

/************************************************************************/
/*-    sizeof_d3n -- Return size of dir-node.				*/
/************************************************************************/

static Vm_Unt
sizeof_d3n(
    Vm_Unt size
) {
    return sizeof( D3n_A_Header );
}

/************************************************************************/
/*-    --- static fns ---						*/
/************************************************************************/

#ifdef MAYBE_SOMEDAY
/************************************************************************/
/*-    bit_stretch_table						*/
/************************************************************************/

static Vm_Int bit_stretch_table[ 256 ];

/************************************************************************/
/*-    make_bit_interleaved_key						*/
/************************************************************************/

static void
interleave_one_coordinate(
    struct D3l_bit_interleaved_key * result,
    Vm_Obj x,
    Vm_Int coordNum
) {
    /* Extract mantissa and exponent from x: */
    Vm_Int mantissa = (x  & MANTISSA_MASK) >> OBJ_MIN_SHIFT;
    Vm_Int exponent = (x >> MANTISSA_BITS) &  EXPONENT_MASK;

    /* For each byte in mantissa: */
    int  byteNo;
    for (byteNo = 0;   byteNo < 6;   ++byteNo, mantissa >>= 8) {

	int byte = mantissa & 0xFF;

	/* Expand byte: */
	Vm_Int expansion = bit_stretch_table[ byte ];

	/* Figure overall bitshift for this byte: */
	int shift  = (exponent + byteNo*8) * 3  +  coordNum;

	/* Figure which word that puts us in: */
	int word   = shift >> VM_LOG2_INTBITS;

	/* Figure which offset that puts us at within word: */
	int offset = shift & ((1<<VM_LOG2_INTBITS)-1);

	/* Merge into interleaved key being built: */
	result->key[word] |= (expansion << offset);

	/* May have some overflow bits in next word: */
	result->key[word+1] |= (expansion >> (VM_INTBITS-offset));
    }
}

static void
make_bit_interleaved_key(
    struct D3l_bit_interleaved_key * result,
    Vm_Obj x,
    Vm_Obj y,
    Vm_Obj z
) {
    int i;

    /* Clear out key: */
    for (i = D3L_KEY_WORDS;   i --> 0;  )   result->key[i] = 0;

    /* Enter the three coordinates into it: */
    interleave_one_coordinate( result, x, 0 );
    interleave_one_coordinate( result, y, 1 );
    interleave_one_coordinate( result, z, 2 );
    
}
#endif

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
