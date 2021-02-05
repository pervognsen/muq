@example  @c
/*--   pil.c -- Propdir dIrectory Leafs: b-trees for Muq propdirs.	*/
/*--   pin.c -- Propdir dIrectory Nodes.				*/
/*									*/
/* This tree type does NOT protect KEYS against garbage			*/
/* collection.	It is ONLY used by DBF objects to associate		*/
/* objects (keys) with propdirs (vals).					*/
/*									*/
/* If the keys were protected against garbage collection, this		*/
/* would prevent any object with such values from ever being		*/
/* garbage collected.							*/
/*									*/
/* A special hack in the garbage collector recycles the propdir		*/
/* for an object when the object is garbage collected.			*/
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
/* Created:      98Mar05						*/
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
/* Vm_Obj newtree = pil_Del( Vm_Obj tree, Vm_Obj key );      		*/
/*  Remove key from tree, if present.               			*/
/*                                                  			*/
/* Vm_Obj val = pil_Get( Vm_Obj tree, Vm_Obj key );                	*/
/*  Look up value of key in btree, NULL if missing. 			*/
/*                                                  			*/
/* Vm_Obj newtree = pil_Set( Vm_Obj tree, Vm_Obj key, Vm_Obj val );  	*/
/*  Insert new key+val pair in tree.                			*/
/*  If key already exists, resets its value.        			*/
/*                                                  			*/
/* nextKey = pil_Next( tree, key );              	    		*/
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

struct Pil_Slot_Rec pil_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_FROM_UNT( (Vm_Int)0 )	/* Prefer NIL, but compiler won't allow it. */
};

struct Pin_Slot_Rec pin_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_NULL_PIL
};

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void pil_doTypes(void){
}
Obj_A_Module_Summary pil_Module_Summary = {
   "pil",
    pil_doTypes,
    pil_Startup,
    pil_Linkup,
    pil_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property pil_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};
static Obj_A_Special_Property pin_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

static void     for_new_pil(     Vm_Obj, Vm_Unt );
static void     for_new_pin(     Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_pil(  Vm_Unt );
static Vm_Unt   sizeof_pin(  Vm_Unt );

/* The only difference between pil/pin and sil/sin */
/* it that the garbage collector does not Mark()   */
/* the 'key' values in pil/pin:                    */
Obj_A_Hardcoded_Class pil_Hardcoded_Class = {
    OBJ_FROM_BYT3('p','i','l'),
    "PropdirBtreeLeaf",
    sizeof_pil,
    for_new_pil,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { pil_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class pin_Hardcoded_Class = {
    OBJ_FROM_BYT3('p','i','n'),
    "PropdirBtreeNode",
    sizeof_pin,
    for_new_pin,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { pin_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};


/************************************************************************/
/*-    pil_copy								*/
/************************************************************************/

static Vm_Obj
pil_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_PIL, 0 );
    Pil_P d;
    Pil_P s;
    vm_Loc2( (void**)&d, (void**)&s, nu, me );
    d->slots_used = s->slots_used;
    {   int   i;
	for (i = PIL_SLOTS; i --> 0; ) d->slot[i] = s->slot[i];
    }
    vm_Dirty(nu);
    return nu;
}

/************************************************************************/
/*-    pin_copy								*/
/************************************************************************/

/* buggo, this can take unbounded time, so it should be in-db, not inserver: */
static Vm_Obj
pin_copy(
    Vm_Obj me
){
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_PIN, 0 );
    Vm_Obj su;
    int    s;
    PIN_P(nu)->slots_used = su = PIN_P(me)->slots_used;
    vm_Dirty(nu);
    s  = (int) OBJ_TO_INT( su );	
    {   int  i;
	for (i = 0;   i < s;   ++i) {
	    struct Pin_Slot_Rec r   = PIN_P(me)->slot[i];
	    Vm_Obj o = r.leaf;
	    if (OBJ_IS_OBJ(o)) {
		if      (OBJ_IS_CLASS_PIL(o)) r.leaf = pil_copy(o);
		else if (OBJ_IS_CLASS_PIL(o)) r.leaf = pin_copy(o);
	    }
	    PIN_P(nu)->slot[i] = r;
	    vm_Dirty(nu);
    }	}

    return nu;
}

/************************************************************************/
/*-    pil_Copy								*/
/************************************************************************/


Vm_Obj
pil_Copy(
    Vm_Obj me
) {
    if (me == OBJ_NULL_PIL)   return OBJ_NULL_PIL;
    if (!OBJ_IS_OBJ(me)) {
	MUQ_WARN("Bad 'me' value in pil_Copy");
    }
    if (OBJ_IS_CLASS_PIL(me)) {
	return pil_copy( me );
    } else if (OBJ_IS_CLASS_PIN(me)) {
	return pin_copy( me );
    }
    MUQ_WARN("Bad 'me' value in pil_Copy");
    return me;	/* Purely to pacify compilers. */
}

/************************************************************************/
/*-    splitWhileInsertingInLeaf					*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingInLeaf(
    Vm_Obj me,
    Pil_Slot s
) {

    Vm_Int slots_used = OBJ_TO_INT( PIL_P(me)->slots_used );
    struct Pil_Slot_Rec tmp;

    /* Insert 's' into 'me' in sorted order: */
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	Vm_Obj h = PIL_P(me)->slot[i].key;
	Vm_Int cmp = obj_Neql( s->key, h );
	if (cmp < 0) {
	    /* Swap me and slot[i]: */
	    tmp         = *s;
	    *s          = PIL_P(me)->slot[i];
	    PIL_P(me)->slot[i] = tmp;	    			vm_Dirty(me);
	} else {
	    if (cmp == 0){
	        /* Our key is already present, we can just  */
	        /* set the value slot rather than inserting */
	        /* a new key-val pair into leaf:            */ 
		PIL_P(me)->slot[i].val = s->val;		vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    }
	}
    }
    if (slots_used < PIL_SLOTS) {
        /* Leaf isn't full, we can complete the   */
        /* insertion operation by appending final */
        /* key-val pair:                          */
	PIL_P(me)->slot[ slots_used ] = *s;
	PIL_P(me)->slots_used = OBJ_FROM_UNT( slots_used +1 );	vm_Dirty(me);
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
	    OBJ_CLASS_A_PIL,
	    0,
	    VM_DBFILE(me)
	);

	/* Pick split point -- midpoint.	  */
	Vm_Int   m =(PIL_SLOTS/2);
	tmp.key  = OBJ_FROM_INT( (Vm_Unt)0 );
	tmp.val  = OBJ_FROM_INT( (Vm_Unt)0 );
	/* Over all slots in nu to be filled from me: */
	for (i = 0; i < PIL_SLOTS-m;  ++i) {
	    Vm_Int j = i + m;
	    PIL_P(nu)->slot[ i ] = PIL_P(me)->slot[ j ]; 			vm_Dirty(nu);
	    PIL_P(me)->slot[ j ] = tmp;	/* Clear free slots */			vm_Dirty(me);
	}
	PIL_P(nu)->slot[ PIL_SLOTS-m ] = *s;	 				vm_Dirty(nu);
	PIL_P(me)->slots_used = OBJ_FROM_UNT( m                         );	vm_Dirty(me);
	PIL_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((PIL_SLOTS+1)-m) );	vm_Dirty(nu);

	return nu;
    }
}

/************************************************************************/
/*-    findSlotFor							*/
/************************************************************************/

static Vm_Int
findSlotFor(
    Vm_Obj me,
    Pil_Slot s
) {
    Vm_Int i;
    for   (i = OBJ_TO_INT( PIN_P(me)->slots_used );   --i > 0;   ) {
	if (obj_Neql( s->key, PIN_P(me)->slot[i].key) >= 0)  break;
    }
    return i;
}

/************************************************************************/
/*-    splitWhileInsertingSlot						*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingSlot(
    Vm_Obj   me,
    Pil_Slot s
) {
    if (OBJ_IS_CLASS_PIL(me)) {
	return splitWhileInsertingInLeaf( me, s );
    } else {
	Vm_Obj nu;
	struct Pin_Slot_Rec ss;
	struct Pin_Slot_Rec tmp;
        Vm_Int    meSlot = findSlotFor(me,s);
        Vm_Obj    mynod  = PIN_P(me)->slot[meSlot].leaf;
	nu = splitWhileInsertingSlot( mynod, s );
	if (nu == OBJ_FROM_INT(0))   return OBJ_FROM_INT(0);
	if (OBJ_IS_CLASS_PIL(nu))   ss.key = PIL_P(nu)->slot[0].key;
	else                        ss.key = PIN_P(nu)->slot[0].key;
	ss.leaf = nu;
	{   Vm_Int slots_used = OBJ_TO_UNT( PIN_P(me)->slots_used );
	    Vm_Int    i;
	    for   (i = meSlot+1;   i < slots_used;   ++i) {
		/* Swap me and slot[i]: */
		tmp         = ss;
		ss          = PIN_P(me)->slot[i];
		PIN_P(me)->slot[i] = tmp;		                           vm_Dirty(me);
	    }
	    if (slots_used < PIN_SLOTS) {
		PIN_P(me)->slot[ slots_used ] = ss;			           vm_Dirty(me);
		PIN_P(me)->slots_used = OBJ_FROM_UNT( slots_used+1 );	           vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    } else {
		Vm_Obj nu = obj_Alloc_In_Dbfile(
		    OBJ_CLASS_A_PIN,
		    0,
		    VM_DBFILE(me)
		);
		/* Split available slots evenly between   */
		/* two nodes, leaving each containing one */
		/* more full than empty slot.  (Remember  */
		/* that a full node has an odd number of  */
		/* of slots, and we have one more than a  */
		/* leaffull of slots.)                    */
		for (i = 0; i   < PIN_SLOTS/2;  ++i) {
		    Vm_Int j = i + ((PIN_SLOTS/2)+1);
		    PIN_P(nu)->slot[ i ] = PIN_P(me)->slot[ j ];	           vm_Dirty(nu);
		    PIN_P(me)->slot[ j ] = pin_nil;	/* Clear free slots */	   vm_Dirty(me);
		    
		}
		PIN_P(nu)->slot[ PIN_SLOTS/2 ] = ss;	                           vm_Dirty(nu);
		PIN_P(me)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((PIN_SLOTS/2)+1) ); vm_Dirty(me);
		PIN_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((PIN_SLOTS/2)+1) ); vm_Dirty(nu);
		return nu;
	    }
	}
    }
}

/************************************************************************/
/*-    pil_Set								*/
/************************************************************************/

Vm_Obj
pil_Set(
    Vm_Obj me,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Unt dbfile
) {
    Vm_Obj            nu;
    struct Pil_Slot_Rec tmp;
    tmp.key = key;
    tmp.val = val;
    if (me == OBJ_NULL_PIL) {
	me              = obj_Alloc_In_Dbfile( OBJ_CLASS_A_PIL, 0, dbfile );
	PIL_P(me)->slots_used  = OBJ_FROM_UNT( (Vm_Unt)1 );
	PIL_P(me)->slot[0]     = tmp;				vm_Dirty(me);
	return me;
    }
    if ((nu = splitWhileInsertingSlot( me, &tmp )) != OBJ_FROM_INT(0)) {
        Vm_Obj r       = obj_Alloc_In_Dbfile(OBJ_CLASS_A_PIN,0,VM_DBFILE(me));
	Vm_Obj h;
	if (OBJ_IS_CLASS_PIL(nu))   h = PIL_P(nu)->slot[0].key;
	else                        h = PIN_P(nu)->slot[0].key;
	{   Pin_P s = PIN_P(r);
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
    Vm_Int  slots_used = OBJ_TO_INT( PIL_P(me)->slots_used );
    Vm_Int  i;
    for    (i = slot;   i < slots_used-1;   ++i) {
	PIL_P(me)->slot[i] = PIL_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    PIL_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    PIL_P(me)->slot[ slots_used ] = pil_nil;			vm_Dirty(me);
   return  slots_used <= PIL_SLOTS/2;
}

/************************************************************************/
/*-    dropNodeSlot							*/
/************************************************************************/

static Vm_Int
dropNodeSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int slots_used = OBJ_TO_INT( PIN_P(me)->slots_used );
    Vm_Int i;
    for   (i = slot;   i < slots_used-1;   ++i) {
	PIN_P(me)->slot[i] = PIN_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    PIN_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    PIN_P(me)->slot[ slots_used ]= pin_nil;			vm_Dirty(me);
   return  slots_used <= PIN_SLOTS/2;
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

    Vm_Int slots_used = OBJ_TO_INT( PIN_P(me)->slots_used );

    struct Pil_Slot_Rec nul;
    nul.key  = OBJ_FROM_INT( 0 );
    nul.val  = OBJ_FROM_INT( 0 );

    if (slotA < 0 || slotB >= slots_used) {
	return FALSE;
    }

    {	Vm_Obj a  = PIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = PIN_P(me)->slot[ slotB ].leaf;
	
	/* mustBeLeaf(a); */
	/* mustBeLeaf(b); */

	{   Vm_Int aSlots = OBJ_TO_INT( PIL_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( PIL_P(b)->slots_used );
	    if (aSlots + bSlots > PIL_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int  i;
		for (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    PIL_P(a)->slot[i] = PIL_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    PIL_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    PIL_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);	
	    PIL_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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

    Vm_Int slots_used = OBJ_TO_INT( PIN_P(me)->slots_used );

    struct Pin_Slot_Rec nul;
    nul.key  = OBJ_FIRST;
    nul.leaf = OBJ_FROM_INT( 0 );

    /*mustBeNode(me)*/;
    if (slotA < 0 || slotB >= slots_used) {
        return FALSE;
    }

    {	Vm_Obj a  = PIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = PIN_P(me)->slot[ slotB ].leaf;

	/*mustBeNode(a);*/
	/*mustBeNode(b);*/

	{   Vm_Int aSlots = OBJ_TO_INT( PIN_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( PIN_P(b)->slots_used );
	    if (aSlots + bSlots > PIN_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int i;
		for   (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    PIN_P(a)->slot[i] = PIN_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    PIN_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    PIN_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);
	    PIN_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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
    Pil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( PIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_Neql( s->key, PIL_P(me)->slot[i].key )) {
	    return dropLeafSlot( me, i );
	}
    }
    return OBJ_TO_INT( PIL_P(me)->slots_used ) <= (PIL_SLOTS/2);
}

/************************************************************************/
/*-    deleteInNode							*/
/************************************************************************/

static Vm_Int
deleteInNode(
    Vm_Obj me,
    Pil_Slot s
) {
    Vm_Int meSlot = findSlotFor(me,s);
    Vm_Obj kid    = PIN_P(me)->slot[ meSlot ].leaf;
    if (OBJ_IS_CLASS_PIL(kid)) {
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
    return OBJ_TO_INT( PIN_P(me)->slots_used ) <= (PIN_SLOTS/2);
}

/************************************************************************/
/*-    pil_Del								*/
/************************************************************************/

Vm_Obj
pil_Del(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Pil_Slot_Rec tmp;
    tmp.key = key;
    tmp.val = OBJ_FROM_INT( (Vm_Int)0 );
    if (me == OBJ_NULL_PIL) return OBJ_NULL_PIL;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_PIL(me)
    &&	!OBJ_IS_CLASS_PIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in pil_Del");
    }
    if (OBJ_IS_CLASS_PIL(me)) {
        deleteInLeaf( me, &tmp );
	/* An empty leaf node can be discarded: */
	if (OBJ_TO_UNT( PIL_P(me)->slots_used ) == (Vm_Unt)0) {
	    return OBJ_NULL_PIL;
	}
    } else {
        deleteInNode( me, &tmp );
	/* An internal node with just one child can be discarded: */
	if (OBJ_TO_UNT( PIN_P(me)->slots_used ) == (Vm_Unt)1) {
	    return PIN_P(me)->slot[0].leaf;
	}
    }
    return me;
}

/************************************************************************/
/*-    findInLeaf							*/
/************************************************************************/

static Vm_Obj
findInLeaf(
    Vm_Obj me,
    Pil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( PIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_Neql( s->key, PIL_P(me)->slot[i].key )) {
	    return PIL_P(me)->slot[i].val;
	}
    }
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    findInLeaf_Asciz							*/
/************************************************************************/

static Vm_Obj
findInLeaf_Asciz(
    Vm_Obj me,
    Pil_Slot s,
    Vm_Uch* key
) {
    Vm_Int slots_used = OBJ_TO_INT( PIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_StrNeql( key, PIL_P(me)->slot[i].key )) {
	    return PIL_P(me)->slot[i].val;
	}
    }
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    valb								*/
/************************************************************************/

static Vm_Obj
valb(
    Vm_Obj me,
    Pil_Slot s
) {
    if (OBJ_IS_CLASS_PIL(me)) {
        return findInLeaf( me, s );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = PIN_P(me)->slot[ meSlot ].leaf;
	return         valb( oe, s );
    }
}

/************************************************************************/
/*-    valb_asciz							*/
/************************************************************************/

static Vm_Obj
valb_asciz(
    Vm_Obj me,
    Pil_Slot s,
    Vm_Uch* key
) {
    if (OBJ_IS_CLASS_PIL(me)) {
        return findInLeaf_Asciz( me, s, key );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = PIN_P(me)->slot[ meSlot ].leaf;
	return         valb_asciz( oe, s, key );
    }
}

/************************************************************************/
/*-    pil_Alloc							*/
/************************************************************************/

Vm_Obj
pil_Alloc(
    void
) {
    return OBJ_NULL_PIL;
}

/************************************************************************/
/*-    pil_Mark								*/
/************************************************************************/

void
pil_Mark(
    Vm_Obj o
) {
    if  (vm_Get_Markbit(o))   return;
    else vm_Set_Markbit(o);

    /* Mark all header info: */
    obj_Mark_Header(o);
    obj_Mark( PIL_P(o)->slots_used );

    /* For each slot in node... */
    {   int i;
        for (i = (int)OBJ_TO_INT( PIL_P(o)->slots_used );   i --> 0;   ) {
	    /* ... mark val but not key: */
	    obj_Mark( PIL_P(o)->slot[i].val );
	}
    }
}

/************************************************************************/
/*-    pin_Mark								*/
/************************************************************************/

void
pin_Mark(
    Vm_Obj o
) {
    /* We use PIL trees to track the propdirs associated     */
    /* with an object, if any.  When the object is recycled, */
    /* we want to recycle the associated propdirs also.      */
    /* For that to work, we must keep the PIL tree itself    */
    /* from preventing garbage collection of the object. So  */
    /* the point of this function is to do needed Mark()ing  */
    /* of leaf nodes without marking the key nodes:          */
    /*  Currently the only pil trees are those in            */
    /* dbf->propdir_pil[ OBJ_PROP_MAX ]			     */

    if  (vm_Get_Markbit(o))   return;
    else vm_Set_Markbit(o);

    /* Mark all header info: */
    obj_Mark_Header(o);
    obj_Mark( PIN_P(o)->slots_used );

    /* For each slot in node... */
    {   int i;
        for (i = (int)OBJ_TO_INT( PIN_P(o)->slots_used );   i --> 0;   ) {
	    /* ... mark leaf but not key: */
	    obj_Mark( PIN_P(o)->slot[i].leaf );
	}
    }
}

/************************************************************************/
/*-    pil_Get								*/
/************************************************************************/

Vm_Obj
pil_Get(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Pil_Slot_Rec tmp;
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me == OBJ_NULL_PIL) return OBJ_NULL_SIL;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_PIL(me)
    &&	!OBJ_IS_CLASS_PIN(me))
    ){
        Vm_Uch buf[ 32 ];
        job_Sprint_Vm_Obj( buf, buf+32, me, /*quotestrings:*/TRUE );
	MUQ_FATAL("Bad 'me' value in pil_Get %s",buf);
    }
    {   Vm_Obj result = valb( me, &tmp );
	if (result == OBJ_NOT_FOUND) {
	    result =  OBJ_NULL_SIL;
	}
	return result;
    }
}

/************************************************************************/
/*-    pil_FirstInSubtree						*/
/************************************************************************/

Vm_Int
pil_FirstInSubtree(
    Vm_Obj* result,
    Vm_Obj me
) {
    if (OBJ_IS_CLASS_PIL(me)) {
	if (OBJ_TO_INT(PIL_P(me)->slots_used)==(Vm_Int)0)   return FALSE;
	*result = PIL_P(me)->slot[0].key;
	return TRUE;
    }
    return pil_FirstInSubtree( result, PIN_P(me)->slot[0].leaf );
}

/************************************************************************/
/*-    pil_First							*/
/************************************************************************/

Vm_Obj
pil_First(
    Vm_Obj me
) {
    Vm_Obj result;
    if (me==OBJ_NULL_PIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_PIL(me)
    &&	!OBJ_IS_CLASS_PIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in pil_First");
    }
    if (pil_FirstInSubtree( &result, me )) {
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
    Pil_Slot s
) {
    /*mustBeLeaf(me);*/
    {   Vm_Int slots_used = OBJ_TO_INT( PIL_P(me)->slots_used );
	Vm_Int i;
	for   (i = 0;   i < slots_used;   ++i) {
	    if (!obj_Neql( s->key, PIL_P(me)->slot[i].key )) {
	        if (i+1 == slots_used)  return FALSE;
	        *result = PIL_P(me)->slot[i+1].key;
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
    Pil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( PIN_P(me)->slots_used );
    Vm_Int meSlot     = findSlotFor(me,s);
    Vm_Obj oe         = PIN_P(me)->slot[ meSlot ].leaf;
    /*mustBeNode(me);*/
    if (OBJ_IS_CLASS_PIL(oe)) {
	if (nextInLeaf( result, oe, s ))   return TRUE;
	if (meSlot+1 < slots_used) {
	    return pil_FirstInSubtree( result, PIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    } else {
	if (nextInNode( result, oe, s ))          return TRUE;
	if (meSlot+1 < slots_used) {
	    return pil_FirstInSubtree( result, PIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    }
}

/************************************************************************/
/*-    pil_Next								*/
/************************************************************************/

Vm_Obj
pil_Next(
    Vm_Obj me,
    Vm_Obj key
) {
    Vm_Obj  result;
    struct Pil_Slot_Rec tmp;
    if (key==OBJ_FIRST)   return pil_First( me );
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me==OBJ_NULL_PIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_PIL(me)
    &&	!OBJ_IS_CLASS_PIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in pil_Del");
    }
    if (OBJ_IS_CLASS_PIL(me)) {
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
/*-    pil_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
pil_Startup (
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    if (sizeof(Pil_A_Header) > 512
    || sizeof(Pil_A_Header)+2*sizeof(struct Pil_Slot_Rec) < 512
    ){
        printf("*****  sizeof Pil_A_Header d=%d\n",sizeof(Pil_A_Header));
    }


    if (sizeof(Pin_A_Header) > 512
    || sizeof(Pin_A_Header)+2*sizeof(struct Pin_Slot_Rec) < 512
    ){
        printf("*****  sizeof Pin_A_Header d=%d\n",sizeof(Pin_A_Header));
    }

    obj_Pil_Test_Slot = OBJ_NULL_PIL;
}



/************************************************************************/
/*-    pil_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
pil_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    pil_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
pil_Shutdown(
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
/*-    for_new_pil -- Initialize new pil object.			*/
/************************************************************************/

static void
for_new_pil(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    int   i;
    Pil_P s 	= PIL_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = PIL_SLOTS;   i --> 0;   )   s->slot[i] = pil_nil;
    vm_Dirty(o);
}

static void
for_new_pin(
    Vm_Obj o,
    Vm_Unt size
) {
    int   i;
    Pin_P s 	= PIN_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = PIN_SLOTS;   i --> 0;   )   s->slot[i] = pin_nil;
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_pil -- Return size of sorted-dir-leaf.			*/
/************************************************************************/

static Vm_Unt
sizeof_pil(
    Vm_Unt size
) {
    return sizeof( Pil_A_Header );
}

/************************************************************************/
/*-    sizeof_pin -- Return size of pin-node.				*/
/************************************************************************/

static Vm_Unt
sizeof_pin(
    Vm_Unt size
) {
    return sizeof( Pin_A_Header );
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
