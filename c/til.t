@example  @c
/*--   til.c -- Tri-val dIrectory Leafs: b-trees for Muq net info.	*/
/*--   tin.c -- Tri-val dIrectory Nodes.				*/
/*									*/
/* This tree type does NOT protect KEYS against garbage			*/
/* collection.	It is ONLY used by DBF objects to associate		*/
/* objects (keys) with the netinfo needed for objects which		*/
/* are known to remote Muq servers.					*/
/*									*/
/* If the keys were protected against garbage collection, this		*/
/* would prevent any object with such external references from		*/
/* ever being garbage collected.					*/
/*									*/
/* A special hack in the garbage collector recycles the netinfo		*/
/* for an object when the object is garbage collected.			*/
/*									*/
/* The netinfo is all immediate integers, so questions of		*/
/* marking the values during garbage collection do not arise.		*/
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
/* Vm_Obj newtree = til_Del( Vm_Obj tree, Vm_Obj key );      		*/
/*  Remove key from tree, if present.               			*/
/*                                                  			*/
/* Vm_Obj v0 = til_Get(Vm_Obj*v2,Vm_Obj*v3, Vm_Obj tree, Vm_Obj key ); 	*/
/*  Look up value of key in btree, NULL if missing. 			*/
/*                                                  			*/
/* Vm_Obj newtree = til_Set( Vm_Obj tree, Vm_Obj key, Vm_Obj v0,v1,v2);	*/
/*  Insert new key+val pair in tree.                			*/
/*  If key already exists, resets its value.        			*/
/*                                                  			*/
/* nextKey = til_Next( tree, key );              	    		*/
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

struct Til_Slot_Rec til_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_FROM_UNT( (Vm_Int)0 )	/* Prefer NIL, but compiler won't allow it. */
};

struct Tin_Slot_Rec tin_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_NULL_TIL
};

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void til_doTypes(void){
}
Obj_A_Module_Summary til_Module_Summary = {
   "til",
    til_doTypes,
    til_Startup,
    til_Linkup,
    til_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property til_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};
static Obj_A_Special_Property tin_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

static void     for_new_til(     Vm_Obj, Vm_Unt );
static void     for_new_tin(     Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_til(  Vm_Unt );
static Vm_Unt   sizeof_tin(  Vm_Unt );

Obj_A_Hardcoded_Class til_Hardcoded_Class = {
    OBJ_FROM_BYT3('t','i','l'),
    "TriValBtreeLeaf",
    sizeof_til,
    for_new_til,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { til_system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class tin_Hardcoded_Class = {
    OBJ_FROM_BYT3('t','i','n'),
    "TriValBtreeNode",
    sizeof_tin,
    for_new_tin,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { tin_system_properties, NULL, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};


/************************************************************************/
/*-    til_copy								*/
/************************************************************************/

static Vm_Obj
til_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_TIL, 0 );
    Til_P d;
    Til_P s;
    vm_Loc2( (void**)&d, (void**)&s, nu, me );
    d->slots_used = s->slots_used;
    {   int   i;
	for (i = TIL_SLOTS; i --> 0; ) d->slot[i] = s->slot[i];
    }
    vm_Dirty(nu);
    return nu;
}

/************************************************************************/
/*-    tin_copy								*/
/************************************************************************/

/* buggo, this can take unbounded time, so it should be in-db, not inserver: */
static Vm_Obj
tin_copy(
    Vm_Obj me
){
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_TIN, 0 );
    Vm_Obj su;
    int    s;
    TIN_P(nu)->slots_used = su = TIN_P(me)->slots_used;
    vm_Dirty(nu);
    s  = (int) OBJ_TO_INT( su );	
    {   int  i;
	for (i = 0;   i < s;   ++i) {
	    struct Tin_Slot_Rec r   = TIN_P(me)->slot[i];
	    Vm_Obj o = r.leaf;
	    if (OBJ_IS_OBJ(o)) {
		if      (OBJ_IS_CLASS_TIL(o)) r.leaf = til_copy(o);
		else if (OBJ_IS_CLASS_TIL(o)) r.leaf = tin_copy(o);
	    }
	    TIN_P(nu)->slot[i] = r;
	    vm_Dirty(nu);
    }	}

    return nu;
}

/************************************************************************/
/*-    til_Copy								*/
/************************************************************************/


Vm_Obj
til_Copy(
    Vm_Obj me
) {
    if (me == OBJ_NULL_TIL)   return OBJ_NULL_TIL;
    if (!OBJ_IS_OBJ(me)) {
	MUQ_WARN("Bad 'me' value in til_Copy");
    }
    if (OBJ_IS_CLASS_TIL(me)) {
	return til_copy( me );
    } else if (OBJ_IS_CLASS_TIN(me)) {
	return tin_copy( me );
    }
    MUQ_WARN("Bad 'me' value in til_Copy");
    return me;	/* Purely to pacify compilers. */
}

/************************************************************************/
/*-    splitWhileInsertingInLeaf					*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingInLeaf(
    Vm_Obj me,
    Til_Slot s
) {

    Vm_Int slots_used = OBJ_TO_INT( TIL_P(me)->slots_used );
    struct Til_Slot_Rec tmp;

    /* Insert 's' into 'me' in sorted order: */
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	Vm_Obj h = TIL_P(me)->slot[i].key;
	if (s->key < h) {
	    /* Swap me and slot[i]: */
	    tmp         = *s;
	    *s          = TIL_P(me)->slot[i];
	    TIL_P(me)->slot[i] = tmp;	    			vm_Dirty(me);
	} else {
	    if (s->key == h){
	        /* Our key is already present, we can just  */
	        /* set the value slot rather than inserting */
	        /* a new key-val pair into leaf:            */ 
		TIL_P(me)->slot[i].val  = s->val;
		TIL_P(me)->slot[i].val2 = s->val2;
		TIL_P(me)->slot[i].val3 = s->val3;
		vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    }
	}
    }
    if (slots_used < TIL_SLOTS) {
        /* Leaf isn't full, we can complete the   */
        /* insertion operation by appending final */
        /* key-val pair:                          */
	TIL_P(me)->slot[ slots_used ] = *s;
	TIL_P(me)->slots_used = OBJ_FROM_UNT( slots_used +1 );	vm_Dirty(me);
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
	    OBJ_CLASS_A_TIL,
	    0,
	    VM_DBFILE(me)
	);

	/* Pick split point -- midpoint.	  */
	Vm_Int   m =(TIL_SLOTS/2);
	tmp.key  = OBJ_FROM_INT( (Vm_Unt)0 );
	tmp.val  = OBJ_FROM_INT( (Vm_Unt)0 );
	tmp.val2 = OBJ_FROM_INT( (Vm_Unt)0 );
	tmp.val3 = OBJ_FROM_INT( (Vm_Unt)0 );
	/* Over all slots in nu to be filled from me: */
	for (i = 0; i < TIL_SLOTS-m;  ++i) {
	    Vm_Int j = i + m;
	    TIL_P(nu)->slot[ i ] = TIL_P(me)->slot[ j ]; 			vm_Dirty(nu);
	    TIL_P(me)->slot[ j ] = tmp;	/* Clear free slots */			vm_Dirty(me);
	}
	TIL_P(nu)->slot[ TIL_SLOTS-m ] = *s;	 				vm_Dirty(nu);
	TIL_P(me)->slots_used = OBJ_FROM_UNT( m                         );	vm_Dirty(me);
	TIL_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((TIL_SLOTS+1)-m) );	vm_Dirty(nu);

	return nu;
    }
}

/************************************************************************/
/*-    findSlotFor							*/
/************************************************************************/

static Vm_Int
findSlotFor(
    Vm_Obj me,
    Til_Slot s
) {
    Vm_Int i;
    for   (i = OBJ_TO_INT( TIN_P(me)->slots_used );   --i > 0;   ) {
	if (s->key >= TIN_P(me)->slot[i].key)  break;
    }
    return i;
}

/************************************************************************/
/*-    splitWhileInsertingSlot						*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingSlot(
    Vm_Obj   me,
    Til_Slot s
) {
    if (OBJ_IS_CLASS_TIL(me)) {
	return splitWhileInsertingInLeaf( me, s );
    } else {
	Vm_Obj nu;
	struct Tin_Slot_Rec ss;
	struct Tin_Slot_Rec tmp;
        Vm_Int    meSlot = findSlotFor(me,s);
        Vm_Obj    mynod  = TIN_P(me)->slot[meSlot].leaf;
	nu = splitWhileInsertingSlot( mynod, s );
	if (nu == OBJ_FROM_INT(0))   return OBJ_FROM_INT(0);
	if (OBJ_IS_CLASS_TIL(nu))   ss.key = TIL_P(nu)->slot[0].key;
	else                        ss.key = TIN_P(nu)->slot[0].key;
	ss.leaf = nu;
	{   Vm_Int slots_used = OBJ_TO_UNT( TIN_P(me)->slots_used );
	    Vm_Int    i;
	    for   (i = meSlot+1;   i < slots_used;   ++i) {
		/* Swap me and slot[i]: */
		tmp         = ss;
		ss          = TIN_P(me)->slot[i];
		TIN_P(me)->slot[i] = tmp;		                           vm_Dirty(me);
	    }
	    if (slots_used < TIN_SLOTS) {
		TIN_P(me)->slot[ slots_used ] = ss;			           vm_Dirty(me);
		TIN_P(me)->slots_used = OBJ_FROM_UNT( slots_used+1 );	           vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    } else {
		Vm_Obj nu = obj_Alloc_In_Dbfile(
		    OBJ_CLASS_A_TIN,
		    0,
		    VM_DBFILE(me)
		);
		/* Split available slots evenly between   */
		/* two nodes, leaving each containing one */
		/* more full than empty slot.  (Remember  */
		/* that a full node has an odd number of  */
		/* of slots, and we have one more than a  */
		/* leaffull of slots.)                    */
		for (i = 0; i   < TIN_SLOTS/2;  ++i) {
		    Vm_Int j = i + ((TIN_SLOTS/2)+1);
		    TIN_P(nu)->slot[ i ] = TIN_P(me)->slot[ j ];	           vm_Dirty(nu);
		    TIN_P(me)->slot[ j ] = tin_nil;	/* Clear free slots */	   vm_Dirty(me);
		    
		}
		TIN_P(nu)->slot[ TIN_SLOTS/2 ] = ss;	                           vm_Dirty(nu);
		TIN_P(me)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((TIN_SLOTS/2)+1) ); vm_Dirty(me);
		TIN_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((TIN_SLOTS/2)+1) ); vm_Dirty(nu);
		return nu;
	    }
	}
    }
}

/************************************************************************/
/*-    til_Set								*/
/************************************************************************/

Vm_Obj
til_Set(
    Vm_Obj me,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Obj val2,
    Vm_Obj val3,
    Vm_Unt dbfile
) {
    Vm_Obj            nu;
    struct Til_Slot_Rec tmp;
    tmp.key  = key;
    tmp.val  = val;
    tmp.val2 = val2;
    tmp.val3 = val3;
    if (me == OBJ_NULL_TIL) {
	me              = obj_Alloc_In_Dbfile( OBJ_CLASS_A_TIL, 0, dbfile );
	TIL_P(me)->slots_used  = OBJ_FROM_UNT( (Vm_Unt)1 );
	TIL_P(me)->slot[0]     = tmp;				vm_Dirty(me);
	return me;
    }
    if ((nu = splitWhileInsertingSlot( me, &tmp )) != OBJ_FROM_INT(0)) {
        Vm_Obj r       = obj_Alloc_In_Dbfile(OBJ_CLASS_A_TIN,0,VM_DBFILE(me));
	Vm_Obj h;
	if (OBJ_IS_CLASS_TIL(nu))   h = TIL_P(nu)->slot[0].key;
	else                        h = TIN_P(nu)->slot[0].key;
	{   Tin_P s = TIN_P(r);
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
    Vm_Int  slots_used = OBJ_TO_INT( TIL_P(me)->slots_used );
    Vm_Int  i;
    for    (i = slot;   i < slots_used-1;   ++i) {
	TIL_P(me)->slot[i] = TIL_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    TIL_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    TIL_P(me)->slot[ slots_used ] = til_nil;			vm_Dirty(me);
    return  slots_used <= TIL_SLOTS/2;
}

/************************************************************************/
/*-    dropNodeSlot							*/
/************************************************************************/

static Vm_Int
dropNodeSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int slots_used = OBJ_TO_INT( TIN_P(me)->slots_used );
    Vm_Int i;
    for   (i = slot;   i < slots_used-1;   ++i) {
	TIN_P(me)->slot[i] = TIN_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    TIN_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    TIN_P(me)->slot[ slots_used ]= tin_nil;			vm_Dirty(me);
    return  slots_used <= TIN_SLOTS/2;
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

    Vm_Int slots_used = OBJ_TO_INT( TIN_P(me)->slots_used );

    struct Til_Slot_Rec nul;
    nul.key  = OBJ_FROM_INT( 0 );
    nul.val  = OBJ_FROM_INT( 0 );

    if (slotA < 0 || slotB >= slots_used) {
	return FALSE;
    }

    {	Vm_Obj a  = TIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = TIN_P(me)->slot[ slotB ].leaf;
	
	/* mustBeLeaf(a); */
	/* mustBeLeaf(b); */

	{   Vm_Int aSlots = OBJ_TO_INT( TIL_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( TIL_P(b)->slots_used );
	    if (aSlots + bSlots > TIL_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int  i;
		for (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    TIL_P(a)->slot[i] = TIL_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    TIL_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    TIL_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);	
	    TIL_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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

    Vm_Int slots_used = OBJ_TO_INT( TIN_P(me)->slots_used );

    struct Tin_Slot_Rec nul;
    nul.key  = OBJ_FIRST;
    nul.leaf = OBJ_FROM_INT( 0 );

    /*mustBeNode(me)*/;
    if (slotA < 0 || slotB >= slots_used) {
        return FALSE;
    }

    {	Vm_Obj a  = TIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = TIN_P(me)->slot[ slotB ].leaf;

	/*mustBeNode(a);*/
	/*mustBeNode(b);*/

	{   Vm_Int aSlots = OBJ_TO_INT( TIN_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( TIN_P(b)->slots_used );
	    if (aSlots + bSlots > TIN_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int i;
		for   (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    TIN_P(a)->slot[i] = TIN_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    TIN_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    TIN_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);
	    TIN_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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
    Til_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( TIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (s->key == TIL_P(me)->slot[i].key) {
	    return dropLeafSlot( me, i );
	}
    }
    return OBJ_TO_INT( TIL_P(me)->slots_used ) <= (TIL_SLOTS/2);
}

/************************************************************************/
/*-    deleteInNode							*/
/************************************************************************/

static Vm_Int
deleteInNode(
    Vm_Obj me,
    Til_Slot s
) {
    Vm_Int meSlot = findSlotFor(me,s);
    Vm_Obj kid    = TIN_P(me)->slot[ meSlot ].leaf;
    if (OBJ_IS_CLASS_TIL(kid)) {
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
    return OBJ_TO_INT( TIN_P(me)->slots_used ) <= (TIN_SLOTS/2);
}

/************************************************************************/
/*-    til_Del								*/
/************************************************************************/

Vm_Obj
til_Del(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Til_Slot_Rec tmp;
    tmp.key = key;
    tmp.val = OBJ_FROM_INT( (Vm_Int)0 );
    if (me == OBJ_NULL_TIL) return OBJ_NULL_TIL;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_TIL(me)
    &&	!OBJ_IS_CLASS_TIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in til_Del");
    }
    if (OBJ_IS_CLASS_TIL(me)) {
        deleteInLeaf( me, &tmp );
	/* An empty leaf node can be discarded: */
	if (OBJ_TO_UNT( TIL_P(me)->slots_used ) == (Vm_Unt)0) {
	    return OBJ_NULL_TIL;
	}
    } else {
        deleteInNode( me, &tmp );
	/* An internal node with just one child can be discarded: */
	if (OBJ_TO_UNT( TIN_P(me)->slots_used ) == (Vm_Unt)1) {
	    return TIN_P(me)->slot[0].leaf;
	}
    }
    return me;
}

/************************************************************************/
/*-    findInLeaf							*/
/************************************************************************/

static struct Til_Slot_Rec TIL_NOT_FOUND = {
    OBJ_NOT_FOUND,
    OBJ_NOT_FOUND,
    OBJ_NOT_FOUND,
    OBJ_NOT_FOUND
};

static struct Til_Slot_Rec
findInLeaf(
    Vm_Obj me,
    Til_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( TIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (s->key == TIL_P(me)->slot[i].key) {
	    return TIL_P(me)->slot[i];
	}
    }
    return TIL_NOT_FOUND;
}

/************************************************************************/
/*-    valb								*/
/************************************************************************/

static struct Til_Slot_Rec
valb(
    Vm_Obj me,
    Til_Slot s
) {
    if (OBJ_IS_CLASS_TIL(me)) {
        return findInLeaf( me, s );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = TIN_P(me)->slot[ meSlot ].leaf;
	return         valb( oe, s );
    }
}

/************************************************************************/
/*-    til_Alloc							*/
/************************************************************************/

Vm_Obj
til_Alloc(
    void
) {
    return OBJ_NULL_TIL;
}

/************************************************************************/
/*-    til_Get								*/
/************************************************************************/

Vm_Obj
til_Get(
    Vm_Obj*v2,
    Vm_Obj*v3,
    Vm_Obj me,
    Vm_Obj key
) {
    struct Til_Slot_Rec tmp;
    /* Convert key to int, so it can still be garbage collected: */
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me == OBJ_NULL_TIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_TIL(me)
    &&	!OBJ_IS_CLASS_TIN(me))
    ){
        Vm_Uch buf[ 32 ];
        job_Sprint_Vm_Obj( buf, buf+32, me, /*quotestrings:*/TRUE );
	MUQ_FATAL("Bad 'me' value in til_Get %s",buf);
    }
    tmp  = valb( me, &tmp );
    *v2  = tmp.val2;
    *v3  = tmp.val3;
    return tmp.val;
}

/************************************************************************/
/*-    til_Mark								*/
/************************************************************************/

void
til_Mark(
    Vm_Obj o
) {
    vm_Set_Markbit(o);
}

/************************************************************************/
/*-    tin_Mark								*/
/************************************************************************/

void
tin_Mark(
    Vm_Obj o
) {
    /* We use TIL trees to track the network info associated */
    /* with an object, if any.  When the object is recycled, */
    /* we want to recycle the associated network info also.  */
    /* For that to work, we must keep the TIL tree itself    */
    /* from preventing garbage collection of the object. So  */
    /* the point of this function is to do needed Mark()ing  */
    /* of leaf nodes without marking the key nodes:          */

    if  (vm_Get_Markbit(o))   return;
    else vm_Set_Markbit(o);

    /* Mark all header info: */
    obj_Mark_Header(o);
    obj_Mark( TIN_P(o)->slots_used );

    /* For each slot in node... */
    {   int i;
        for (i = (int)OBJ_TO_INT( TIN_P(o)->slots_used );   i --> 0;   ) {
	    /* ... mark leaf but not key: */
	    obj_Mark( TIN_P(o)->slot[i].leaf );
	}
    }
}

/************************************************************************/
/*-    til_FirstInSubtree						*/
/************************************************************************/

Vm_Int
til_FirstInSubtree(
    Vm_Obj* result,
    Vm_Obj me
) {
    if (OBJ_IS_CLASS_TIL(me)) {
	if (OBJ_TO_INT(TIL_P(me)->slots_used)==(Vm_Int)0)   return FALSE;
	*result = TIL_P(me)->slot[0].key;
	return TRUE;
    }
    return til_FirstInSubtree( result, TIN_P(me)->slot[0].leaf );
}

/************************************************************************/
/*-    til_First							*/
/************************************************************************/

Vm_Obj
til_First(
    Vm_Obj me
) {
    Vm_Obj result;
    if (me==OBJ_NULL_TIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_TIL(me)
    &&	!OBJ_IS_CLASS_TIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in til_First");
    }
    if (til_FirstInSubtree( &result, me )) {
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
    Til_Slot s
) {
    /*mustBeLeaf(me);*/
    {   Vm_Int slots_used = OBJ_TO_INT( TIL_P(me)->slots_used );
	Vm_Int i;
	for   (i = 0;   i < slots_used;   ++i) {
	    if (s->key == TIL_P(me)->slot[i].key) {
	        if (i+1 == slots_used)  return FALSE;
	        *result = TIL_P(me)->slot[i+1].key;
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
    Til_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( TIN_P(me)->slots_used );
    Vm_Int meSlot     = findSlotFor(me,s);
    Vm_Obj oe         = TIN_P(me)->slot[ meSlot ].leaf;
    /*mustBeNode(me);*/
    if (OBJ_IS_CLASS_TIL(oe)) {
	if (nextInLeaf( result, oe, s ))   return TRUE;
	if (meSlot+1 < slots_used) {
	    return til_FirstInSubtree( result, TIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    } else {
	if (nextInNode( result, oe, s ))          return TRUE;
	if (meSlot+1 < slots_used) {
	    return til_FirstInSubtree( result, TIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    }
}

/************************************************************************/
/*-    til_Next								*/
/************************************************************************/

Vm_Obj
til_Next(
    Vm_Obj me,
    Vm_Obj key
) {
    Vm_Obj  result;
    struct Til_Slot_Rec tmp;
    if (key==OBJ_FIRST)   return til_First( me );
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me==OBJ_NULL_TIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_TIL(me)
    &&	!OBJ_IS_CLASS_TIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in til_Del");
    }
    if (OBJ_IS_CLASS_TIL(me)) {
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
/*-    til_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
til_Startup (
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    if (sizeof(Til_A_Header) > 512
    || sizeof(Til_A_Header)+2*sizeof(struct Til_Slot_Rec) < 512
    ){
        printf("*****  sizeof Til_A_Header d=%d\n",sizeof(Til_A_Header));
    }

    if (sizeof(Tin_A_Header) > 512
    || sizeof(Tin_A_Header)+2*sizeof(struct Tin_Slot_Rec) < 512
    ){
        printf("*****  sizeof Tin_A_Header d=%d\n",sizeof(Tin_A_Header));
    }
    obj_Til_Test_Slot = OBJ_NULL_TIL;
}



/************************************************************************/
/*-    til_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
til_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    til_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
til_Shutdown(
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
/*-    for_new_til -- Initialize new til object.			*/
/************************************************************************/

static void
for_new_til(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    int   i;
    Til_P s 	= TIL_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = TIL_SLOTS;   i --> 0;   )   s->slot[i] = til_nil;
    vm_Dirty(o);
}

static void
for_new_tin(
    Vm_Obj o,
    Vm_Unt size
) {
    int   i;
    Tin_P s 	= TIN_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = TIN_SLOTS;   i --> 0;   )   s->slot[i] = tin_nil;
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_til -- Return size of sorted-dir-leaf.			*/
/************************************************************************/

static Vm_Unt
sizeof_til(
    Vm_Unt size
) {
    return sizeof( Til_A_Header );
}

/************************************************************************/
/*-    sizeof_tin -- Return size of tin-node.				*/
/************************************************************************/

static Vm_Unt
sizeof_tin(
    Vm_Unt size
) {
    return sizeof( Tin_A_Header );
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
