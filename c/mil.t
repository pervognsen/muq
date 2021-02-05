@example  @c
/*--   mil.c -- monoval dIrectory Leafs: btrees for virtual symbol slots*/
/*--   min.c -- monoval dIrectory Nodes.				*/
/*									*/
/* This tree type does NOT protect KEYS against garbage			*/
/* collection.	It is ONLY used by dbf objects, to store the		*/
/* type and proplist virtual slots associated with a symbol.		*/
/*									*/
/* If the keys were protected against garbage collection, this		*/
/* would prevent any symbol with such values from ever being		*/
/* garbage collected.							*/
/*									*/
/* A special hack in the garbage collector recycles the values		*/
/* for a symbol when that symbol is garbage collected.			*/
/*									*/
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
/* Created:      99Jul27						*/
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
/* INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	*/
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

/************************************************************************/
/* Main entrypoints are:                            			*/
/*                                                  			*/
/* Vm_Obj newtree = mil_Del( Vm_Obj tree, Vm_Obj key );      		*/
/*  Remove key from tree, if present.               			*/
/*                                                  			*/
/* Vm_Obj v0 = mil_Get(Vm_Obj*v2,Vm_Obj*v3, Vm_Obj tree, Vm_Obj key ); 	*/
/*  Look up value of key in btree, NULL if missing. 			*/
/*                                                  			*/
/* Vm_Obj newtree = mil_Set( Vm_Obj tree, Vm_Obj key, Vm_Obj v0,v1,v2);	*/
/*  Insert new key+val pair in tree.                			*/
/*  If key already exists, resets its value.        			*/
/*                                                  			*/
/* nextKey = mil_Next( tree, key );              	    		*/
/*  Return next key, else NULL.	                    			*/
/*                                                  			*/
/************************************************************************/


/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"

/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/************************************************************************/
/*-    Statics								*/
/************************************************************************/

struct Mil_Slot_Rec mil_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_FROM_UNT( (Vm_Int)0 )	/* Prefer NIL, but compiler won't allow it. */
};

struct Min_Slot_Rec min_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_NULL_MIL
};

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void mil_doTypes(void){
}
Obj_A_Module_Summary mil_Module_Summary = {
   "mil",
    mil_doTypes,
    mil_Startup,
    mil_Linkup,
    mil_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property mil_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};
static Obj_A_Special_Property min_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

static void     for_new_mil(     Vm_Obj, Vm_Unt );
static void     for_new_min(     Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_mil(  Vm_Unt );
static Vm_Unt   sizeof_min(  Vm_Unt );

Obj_A_Hardcoded_Class mil_Hardcoded_Class = {
    OBJ_FROM_BYT3('t','i','l'),
    "TriValBtreeLeaf",
    sizeof_mil,
    for_new_mil,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { mil_system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class min_Hardcoded_Class = {
    OBJ_FROM_BYT3('t','i','n'),
    "TriValBtreeNode",
    sizeof_min,
    for_new_min,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { min_system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};


/************************************************************************/
/*-    mil_copy								*/
/************************************************************************/

static Vm_Obj
mil_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_MIL, 0 );
    Mil_P d;
    Mil_P s;
    vm_Loc2( (void**)&d, (void**)&s, nu, me );
    d->slots_used = s->slots_used;
    {   int   i;
	for (i = MIL_SLOTS; i --> 0; ) d->slot[i] = s->slot[i];
    }
    vm_Dirty(nu);
    return nu;
}

/************************************************************************/
/*-    min_copy								*/
/************************************************************************/

/* buggo, this can take unbounded time, so it should be in-db, not inserver: */
static Vm_Obj
min_copy(
    Vm_Obj me
){
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_MIN, 0 );
    Vm_Obj su;
    int    s;
    MIN_P(nu)->slots_used = su = MIN_P(me)->slots_used;
    vm_Dirty(nu);
    s  = (int) OBJ_TO_INT( su );	
    {   int  i;
	for (i = 0;   i < s;   ++i) {
	    struct Min_Slot_Rec r   = MIN_P(me)->slot[i];
	    Vm_Obj o = r.leaf;
	    if (OBJ_IS_OBJ(o)) {
		if      (OBJ_IS_CLASS_MIL(o)) r.leaf = mil_copy(o);
		else if (OBJ_IS_CLASS_MIL(o)) r.leaf = min_copy(o);
	    }
	    MIN_P(nu)->slot[i] = r;
	    vm_Dirty(nu);
    }	}

    return nu;
}

/************************************************************************/
/*-    mil_Copy								*/
/************************************************************************/


Vm_Obj
mil_Copy(
    Vm_Obj me
) {
    if (me == OBJ_NULL_MIL)   return OBJ_NULL_MIL;
    if (!OBJ_IS_OBJ(me)) {
	MUQ_WARN("Bad 'me' value in mil_Copy");
    }
    if (OBJ_IS_CLASS_MIL(me)) {
	return mil_copy( me );
    } else if (OBJ_IS_CLASS_MIN(me)) {
	return min_copy( me );
    }
    MUQ_WARN("Bad 'me' value in mil_Copy");
    return me;	/* Purely to pacify compilers. */
}

/************************************************************************/
/*-    splitWhileInsertingInLeaf					*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingInLeaf(
    Vm_Obj me,
    Mil_Slot s
) {

    Vm_Int slots_used = OBJ_TO_INT( MIL_P(me)->slots_used );
    struct Mil_Slot_Rec tmp;

    /* Insert 's' into 'me' in sorted order: */
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	Vm_Obj h = MIL_P(me)->slot[i].key;
	if (s->key < h) {
	    /* Swap me and slot[i]: */
	    tmp         = *s;
	    *s          = MIL_P(me)->slot[i];
	    MIL_P(me)->slot[i] = tmp;	    			vm_Dirty(me);
	} else {
	    if (s->key == h){
	        /* Our key is already present, we can just  */
	        /* set the value slot rather than inserting */
	        /* a new key-val pair into leaf:            */ 
		MIL_P(me)->slot[i].val  = s->val;
		vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    }
	}
    }
    if (slots_used < MIL_SLOTS) {
        /* Leaf isn't full, we can complete the   */
        /* insertion operation by appending final */
        /* key-val pair:                          */
	MIL_P(me)->slot[ slots_used ] = *s;
	MIL_P(me)->slots_used = OBJ_FROM_UNT( slots_used +1 );	vm_Dirty(me);
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
	Vm_Obj   nu    = obj_Alloc_In_Dbfile(
	    OBJ_CLASS_A_MIL,
	    0,
	    VM_DBFILE(me)
	);

	/* Pick split point -- midpoint.	  */
	Vm_Int   m =(MIL_SLOTS/2);
	tmp.key  = OBJ_FROM_INT( (Vm_Unt)0 );
	tmp.val  = OBJ_FROM_INT( (Vm_Unt)0 );
	/* Over all slots in nu to be filled from me: */
	for (i = 0; i < MIL_SLOTS-m;  ++i) {
	    Vm_Int j = i + m;
	    MIL_P(nu)->slot[ i ] = MIL_P(me)->slot[ j ]; 			vm_Dirty(nu);
	    MIL_P(me)->slot[ j ] = tmp;	/* Clear free slots */			vm_Dirty(me);
	}
	MIL_P(nu)->slot[ MIL_SLOTS-m ] = *s;	 				vm_Dirty(nu);
	MIL_P(me)->slots_used = OBJ_FROM_UNT( m                         );	vm_Dirty(me);
	MIL_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((MIL_SLOTS+1)-m) );	vm_Dirty(nu);

	return nu;
    }
}

/************************************************************************/
/*-    findSlotFor							*/
/************************************************************************/

static Vm_Int
findSlotFor(
    Vm_Obj me,
    Mil_Slot s
) {
    Vm_Int i;
    for   (i = OBJ_TO_INT( MIN_P(me)->slots_used );   --i > 0;   ) {
	if (s->key >= MIN_P(me)->slot[i].key)  break;
    }
    return i;
}

/************************************************************************/
/*-    splitWhileInsertingSlot						*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingSlot(
    Vm_Obj   me,
    Mil_Slot s
) {
    if (OBJ_IS_CLASS_MIL(me)) {
	return splitWhileInsertingInLeaf( me, s );
    } else {
	Vm_Obj nu;
	struct Min_Slot_Rec ss;
	struct Min_Slot_Rec tmp;
        Vm_Int    meSlot = findSlotFor(me,s);
        Vm_Obj    mynod  = MIN_P(me)->slot[meSlot].leaf;
	nu = splitWhileInsertingSlot( mynod, s );
	if (nu == OBJ_FROM_INT(0))   return OBJ_FROM_INT(0);
	if (OBJ_IS_CLASS_MIL(nu))   ss.key = MIL_P(nu)->slot[0].key;
	else                        ss.key = MIN_P(nu)->slot[0].key;
	ss.leaf = nu;
	{   Vm_Int slots_used = OBJ_TO_UNT( MIN_P(me)->slots_used );
	    Vm_Int    i;
	    for   (i = meSlot+1;   i < slots_used;   ++i) {
		/* Swap me and slot[i]: */
		tmp         = ss;
		ss          = MIN_P(me)->slot[i];
		MIN_P(me)->slot[i] = tmp;		                           vm_Dirty(me);
	    }
	    if (slots_used < MIN_SLOTS) {
		MIN_P(me)->slot[ slots_used ] = ss;			           vm_Dirty(me);
		MIN_P(me)->slots_used = OBJ_FROM_UNT( slots_used+1 );	           vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    } else {
		Vm_Obj nu = obj_Alloc_In_Dbfile(
		    OBJ_CLASS_A_MIN,
		    0,
		    VM_DBFILE(me)
		);
		/* Split available slots evenly between   */
		/* two nodes, leaving each containing one */
		/* more full than empty slot.  (Remember  */
		/* that a full node has an odd number of  */
		/* of slots, and we have one more than a  */
		/* leaffull of slots.)                    */
		for (i = 0; i   < MIN_SLOTS/2;  ++i) {
		    Vm_Int j = i + ((MIN_SLOTS/2)+1);
		    MIN_P(nu)->slot[ i ] = MIN_P(me)->slot[ j ];	           vm_Dirty(nu);
		    MIN_P(me)->slot[ j ] = min_nil;	/* Clear free slots */	   vm_Dirty(me);
		    
		}
		MIN_P(nu)->slot[ MIN_SLOTS/2 ] = ss;	                           vm_Dirty(nu);
		MIN_P(me)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((MIN_SLOTS/2)+1) ); vm_Dirty(me);
		MIN_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((MIN_SLOTS/2)+1) ); vm_Dirty(nu);
		return nu;
	    }
	}
    }
}

/************************************************************************/
/*-    mil_Set								*/
/************************************************************************/

Vm_Obj
mil_Set(
    Vm_Obj me,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Unt dbfile
) {
    Vm_Obj            nu;
    struct Mil_Slot_Rec tmp;
    tmp.key  = key;
    tmp.val  = val;
    if (me == OBJ_NULL_MIL) {
	me              = obj_Alloc_In_Dbfile( OBJ_CLASS_A_MIL, 0, dbfile );
	MIL_P(me)->slots_used  = OBJ_FROM_UNT( (Vm_Unt)1 );
	MIL_P(me)->slot[0]     = tmp;				vm_Dirty(me);
	return me;
    }
    if ((nu = splitWhileInsertingSlot( me, &tmp )) != OBJ_FROM_INT(0)) {
        Vm_Obj r       = obj_Alloc_In_Dbfile(OBJ_CLASS_A_MIN,0,VM_DBFILE(me));
	Vm_Obj h;
	if (OBJ_IS_CLASS_MIL(nu))   h = MIL_P(nu)->slot[0].key;
	else                        h = MIN_P(nu)->slot[0].key;
	{   Min_P s = MIN_P(r);
	    s->slots_used  = OBJ_FROM_UNT( (Vm_Unt)2 );
	    s->slot[0].key = OBJ_FIRST;
	    s->slot[0].leaf= me;
	    s->slot[1].key = h;
	    s->slot[1].leaf= nu;
	}
	vm_Dirty(r);
	return r;
    }
    return me;
}

/************************************************************************/
/*-    dropLeafSlot							*/
/************************************************************************/

static Vm_Int
dropLeafSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int  slots_used = OBJ_TO_INT( MIL_P(me)->slots_used );
    Vm_Int  i;
    for    (i = slot;   i < slots_used-1;   ++i) {
	MIL_P(me)->slot[i] = MIL_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    MIL_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    MIL_P(me)->slot[ slots_used ] = mil_nil;			vm_Dirty(me);
    return  slots_used <= MIL_SLOTS/2;
}

/************************************************************************/
/*-    dropNodeSlot							*/
/************************************************************************/

static Vm_Int
dropNodeSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int slots_used = OBJ_TO_INT( MIN_P(me)->slots_used );
    Vm_Int i;
    for   (i = slot;   i < slots_used-1;   ++i) {
	MIN_P(me)->slot[i] = MIN_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    MIN_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    MIN_P(me)->slot[ slots_used ]= min_nil;			vm_Dirty(me);
    return  slots_used <= MIN_SLOTS/2;
}

/************************************************************************/
/*-    mergedLeafs							*/
/************************************************************************/

static Vm_Int
mergedLeafs(
    Vm_Obj me,
    Vm_Int slotA,
    Vm_Int slotB
) {

    Vm_Int slots_used = OBJ_TO_INT( MIN_P(me)->slots_used );

    struct Mil_Slot_Rec nul;
    nul.key  = OBJ_FROM_INT( 0 );
    nul.val  = OBJ_FROM_INT( 0 );

    if (slotA < 0 || slotB >= slots_used) {
	return FALSE;
    }

    {	Vm_Obj a  = MIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = MIN_P(me)->slot[ slotB ].leaf;
	
	/* mustBeLeaf(a); */
	/* mustBeLeaf(b); */

	{   Vm_Int aSlots = OBJ_TO_INT( MIL_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( MIL_P(b)->slots_used );
	    if (aSlots + bSlots > MIL_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int  i;
		for (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    MIL_P(a)->slot[i] = MIL_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    MIL_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    MIL_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);	
	    MIL_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
	}
    }

    return TRUE;
}

/************************************************************************/
/*-    mergedNodes							*/
/************************************************************************/

static Vm_Int
mergedNodes(
    Vm_Obj me,
    Vm_Int slotA,
    Vm_Int slotB
) {

    Vm_Int slots_used = OBJ_TO_INT( MIN_P(me)->slots_used );

    struct Min_Slot_Rec nul;
    nul.key  = OBJ_FIRST;
    nul.leaf = OBJ_FROM_INT( 0 );

    /*mustBeNode(me)*/;
    if (slotA < 0 || slotB >= slots_used) {
        return FALSE;
    }

    {	Vm_Obj a  = MIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = MIN_P(me)->slot[ slotB ].leaf;

	/*mustBeNode(a);*/
	/*mustBeNode(b);*/

	{   Vm_Int aSlots = OBJ_TO_INT( MIN_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( MIN_P(b)->slots_used );
	    if (aSlots + bSlots > MIN_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int i;
		for   (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    MIN_P(a)->slot[i] = MIN_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    MIN_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    MIN_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);
	    MIN_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
	}
    }
    return TRUE;
}

/************************************************************************/
/*-    deleteInLeaf							*/
/************************************************************************/

static Vm_Int
deleteInLeaf(
    Vm_Obj me,
    Mil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( MIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (s->key == MIL_P(me)->slot[i].key) {
	    return dropLeafSlot( me, i );
	}
    }
    return OBJ_TO_INT( MIL_P(me)->slots_used ) <= (MIL_SLOTS/2);
}

/************************************************************************/
/*-    deleteInNode							*/
/************************************************************************/

static Vm_Int
deleteInNode(
    Vm_Obj me,
    Mil_Slot s
) {
    Vm_Int meSlot = findSlotFor(me,s);
    Vm_Obj kid    = MIN_P(me)->slot[ meSlot ].leaf;
    if (OBJ_IS_CLASS_MIL(kid)) {
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
    return OBJ_TO_INT( MIN_P(me)->slots_used ) <= (MIN_SLOTS/2);
}

/************************************************************************/
/*-    mil_Del								*/
/************************************************************************/

Vm_Obj
mil_Del(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Mil_Slot_Rec tmp;
    tmp.key = key;
    tmp.val = OBJ_FROM_INT( (Vm_Int)0 );
    if (me == OBJ_NULL_MIL) return OBJ_NULL_MIL;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_MIL(me)
    &&	!OBJ_IS_CLASS_MIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in mil_Del");
    }
    if (OBJ_IS_CLASS_MIL(me)) {
        deleteInLeaf( me, &tmp );
	/* An empty leaf node can be discarded: */
	if (OBJ_TO_UNT( MIL_P(me)->slots_used ) == (Vm_Unt)0) {
	    return OBJ_NULL_MIL;
	}
    } else {
        deleteInNode( me, &tmp );
	/* An internal node with just one child can be discarded: */
	if (OBJ_TO_UNT( MIN_P(me)->slots_used ) == (Vm_Unt)1) {
	    return MIN_P(me)->slot[0].leaf;
	}
    }
    return me;
}

/************************************************************************/
/*-    findInLeaf							*/
/************************************************************************/

static struct Mil_Slot_Rec MIL_NOT_FOUND = {
    OBJ_NOT_FOUND,
    OBJ_NOT_FOUND,
};

static struct Mil_Slot_Rec
findInLeaf(
    Vm_Obj me,
    Mil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( MIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (s->key == MIL_P(me)->slot[i].key) {
	    return MIL_P(me)->slot[i];
	}
    }
    return MIL_NOT_FOUND;
}

/************************************************************************/
/*-    valb								*/
/************************************************************************/

static struct Mil_Slot_Rec
valb(
    Vm_Obj me,
    Mil_Slot s
) {
    if (OBJ_IS_CLASS_MIL(me)) {
        return findInLeaf( me, s );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = MIN_P(me)->slot[ meSlot ].leaf;
	return         valb( oe, s );
    }
}

/************************************************************************/
/*-    mil_Alloc							*/
/************************************************************************/

Vm_Obj
mil_Alloc(
    void
) {
    return OBJ_NULL_MIL;
}

/************************************************************************/
/*-    mil_Get								*/
/************************************************************************/

Vm_Obj
mil_Get(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Mil_Slot_Rec tmp;
    /* Convert key to int, so it can smill be garbage collected: */
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me == OBJ_NULL_MIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_MIL(me)
    &&	!OBJ_IS_CLASS_MIN(me))
    ){
        Vm_Uch buf[ 32 ];
        job_Sprint_Vm_Obj( buf, buf+32, me, /*quotestrings:*/TRUE );
	MUQ_FATAL("Bad 'me' value in mil_Get %s",buf);
    }
    tmp  = valb( me, &tmp );
    return tmp.val;
}

/************************************************************************/
/*-    mil_Mark								*/
/************************************************************************/

void
mil_Mark(
    Vm_Obj o
) {
    if  (vm_Get_Markbit(o))   return;
    else vm_Set_Markbit(o);

    /* Mark all header info: */
    obj_Mark_Header(o);
    obj_Mark( MIL_P(o)->slots_used );

    /* For each slot in node... */
    {   int i;
        for (i = (int)OBJ_TO_INT( MIL_P(o)->slots_used );   i --> 0;   ) {
	    /* ... mark val but not key: */
	    obj_Mark( MIL_P(o)->slot[i].val );
	}
    }
}

/************************************************************************/
/*-    min_Mark								*/
/************************************************************************/

void
min_Mark(
    Vm_Obj o
) {
    /* We use MIL trees to track the virtual slots associated*/
    /* with a symbol, if any.  When the object is recycled,  */
    /* we want to recycle the associated virtual slots also. */
    /* For that to work, we must keep the MIL tree itself    */
    /* from preventing garbage collection of the object. So  */
    /* the point of this function is to do needed Mark()ing  */
    /* of leaf nodes without marking the key nodes.          */
    /*  Currently the only mil trees are                     */
    /* dbf->symbol_type_mil				     */
    /* dbf->symbol_proplist_mil				     */

    if  (vm_Get_Markbit(o))   return;
    else vm_Set_Markbit(o);

    /* Mark all header info: */
    obj_Mark_Header(o);
    obj_Mark( MIN_P(o)->slots_used );

    /* For each slot in node... */
    {   int i;
        for (i = (int)OBJ_TO_INT( MIN_P(o)->slots_used );   i --> 0;   ) {
	    /* ... mark leaf but not key: */
	    obj_Mark( MIN_P(o)->slot[i].leaf );
	}
    }
}

/************************************************************************/
/*-    mil_FirstInSubtree						*/
/************************************************************************/

Vm_Int
mil_FirstInSubtree(
    Vm_Obj* result,
    Vm_Obj me
) {
    if (OBJ_IS_CLASS_MIL(me)) {
	if (OBJ_TO_INT(MIL_P(me)->slots_used)==(Vm_Int)0)   return FALSE;
	*result = MIL_P(me)->slot[0].key;
	return TRUE;
    }
    return mil_FirstInSubtree( result, MIN_P(me)->slot[0].leaf );
}

/************************************************************************/
/*-    mil_First							*/
/************************************************************************/

Vm_Obj
mil_First(
    Vm_Obj me
) {
    Vm_Obj result;
    if (me==OBJ_NULL_MIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_MIL(me)
    &&	!OBJ_IS_CLASS_MIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in mil_First");
    }
    if (mil_FirstInSubtree( &result, me )) {
	return result;
    } else {
	return OBJ_NOT_FOUND;
    }
}

/************************************************************************/
/*-    nextInLeaf							*/
/************************************************************************/

static Vm_Int
nextInLeaf(
    Vm_Obj* result,
    Vm_Obj me,
    Mil_Slot s
) {
    /*mustBeLeaf(me);*/
    {   Vm_Int slots_used = OBJ_TO_INT( MIL_P(me)->slots_used );
	Vm_Int i;
	for   (i = 0;   i < slots_used;   ++i) {
	    if (s->key == MIL_P(me)->slot[i].key) {
	        if (i+1 == slots_used)  return FALSE;
	        *result = MIL_P(me)->slot[i+1].key;
		return TRUE;
	    }
	}
	return FALSE;
    }
}

/************************************************************************/
/*-    nextInNode							*/
/************************************************************************/

static Vm_Int
nextInNode(
    Vm_Obj* result,
    Vm_Obj me,
    Mil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( MIN_P(me)->slots_used );
    Vm_Int meSlot     = findSlotFor(me,s);
    Vm_Obj oe         = MIN_P(me)->slot[ meSlot ].leaf;
    /*mustBeNode(me);*/
    if (OBJ_IS_CLASS_MIL(oe)) {
	if (nextInLeaf( result, oe, s ))   return TRUE;
	if (meSlot+1 < slots_used) {
	    return mil_FirstInSubtree( result, MIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    } else {
	if (nextInNode( result, oe, s ))          return TRUE;
	if (meSlot+1 < slots_used) {
	    return mil_FirstInSubtree( result, MIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    }
}

/************************************************************************/
/*-    mil_Next								*/
/************************************************************************/

Vm_Obj
mil_Next(
    Vm_Obj me,
    Vm_Obj key
) {
    Vm_Obj  result;
    struct Mil_Slot_Rec tmp;
    if (key==OBJ_FIRST)   return mil_First( me );
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me==OBJ_NULL_MIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_MIL(me)
    &&	!OBJ_IS_CLASS_MIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in mil_Del");
    }
    if (OBJ_IS_CLASS_MIL(me)) {
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
}

/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    mil_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
mil_Startup (
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    if (sizeof(Mil_A_Header) > 512
    || sizeof(Mil_A_Header)+2*sizeof(struct Mil_Slot_Rec) < 512
    ){
        printf("*****  sizeof Mil_A_Header d=%d\n",sizeof(Mil_A_Header));
    }

    if (sizeof(Min_A_Header) > 512
    || sizeof(Min_A_Header)+2*sizeof(struct Min_Slot_Rec) < 512
    ){
        printf("*****  sizeof Min_A_Header d=%d\n",sizeof(Min_A_Header));
    }
    obj_Mil_Test_Slot = OBJ_NULL_MIL;
}



/************************************************************************/
/*-    mil_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
mil_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    mil_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
mil_Shutdown(
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
/*-    for_new_mil -- Initialize new mil object.			*/
/************************************************************************/

static void
for_new_mil(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    int   i;
    Mil_P s 	= MIL_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = MIL_SLOTS;   i --> 0;   )   s->slot[i] = mil_nil;
    vm_Dirty(o);
}

static void
for_new_min(
    Vm_Obj o,
    Vm_Unt size
) {
    int   i;
    Min_P s 	= MIN_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = MIN_SLOTS;   i --> 0;   )   s->slot[i] = min_nil;
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_mil -- Return size of sorted-dir-leaf.			*/
/************************************************************************/

static Vm_Unt
sizeof_mil(
    Vm_Unt size
) {
    return sizeof( Mil_A_Header );
}

/************************************************************************/
/*-    sizeof_min -- Return size of min-node.				*/
/************************************************************************/

static Vm_Unt
sizeof_min(
    Vm_Unt size
) {
    return sizeof( Min_A_Header );
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
