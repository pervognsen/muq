@example  @c
/*--   sel.c -- Sorted sEt Leafs: b-trees for Muq propdirs.		*/
/*--   sen.c -- Sorted sEt Nodes.					*/
/*									*/
/* Sorted Btrees with keys but no values, for storing sets.		*/
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
/* Vm_Obj newtree = sel_Del( Vm_Obj tree, Vm_Obj key );      		*/
/*  Remove key from tree, if present.               			*/
/*                                                  			*/
/* Vm_Obj val = sel_Get( Vm_Obj tree, Vm_Obj key );                	*/
/*  Look up value of key in btree, NULL if missing. 			*/
/*                                                  			*/
/* Vm_Obj newtree = sel_Set( Vm_Obj tree, Vm_Obj key, Vm_Obj val );  	*/
/*  Insert new key+val pair in tree.                			*/
/*  If key already exists, resets its value.        			*/
/*                                                  			*/
/* nextKey = sel_Next( tree, key );              	    		*/
/*  Return next key, else NULL.	                    			*/
/*                                                  			*/
/************************************************************************/

/************************************************************************/
/*-    Observation							*/
/*                                                  			*/
/*  Philosophy is like cotton candy for the mind:	  		*/
/*    There is less there than meets the eye,   			*/
/*    it isn't terribly good for you,                			*/
/*    too much will probably make you sick and        			*/
/*    you wouldn't make anything permanent out of it			*/
/*    -- but you could live awhile on it if you had to,  		*/
/*    and it is sure fun to share with your kids!              		*/
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

struct Sel_Slot_Rec sel_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 )	/* Prefer NIL, but compiler won't allow it. */
};

struct Sen_Slot_Rec sen_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_NULL_SEL
};

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void sel_doTypes(void){
}
Obj_A_Module_Summary sel_Module_Summary = {
   "sel",
    sel_doTypes,
    sel_Startup,
    sel_Linkup,
    sel_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property sel_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};
static Obj_A_Special_Property sen_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

static void     for_new_sel(     Vm_Obj, Vm_Unt );
static void     for_new_sen(     Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_sel(  Vm_Unt );
static Vm_Unt   sizeof_sen(  Vm_Unt );

Obj_A_Hardcoded_Class sel_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','e','l'),
    "SortedSetLeaf",
    sizeof_sel,
    for_new_sel,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { sel_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class sen_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','e','n'),
    "SortedSetNode",
    sizeof_sen,
    for_new_sen,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { sen_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};


/************************************************************************/
/*-    sel_copy								*/
/************************************************************************/

static Vm_Obj
sel_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_SEL, 0 );
    Sel_P d;
    Sel_P s;
    vm_Loc2( (void**)&d, (void**)&s, nu, me );
    d->slots_used = s->slots_used;
    {   int   i;
	for (i = SEL_SLOTS; i --> 0; ) d->slot[i] = s->slot[i];
    }
    vm_Dirty(nu);
    return nu;
}

/************************************************************************/
/*-    sen_copy								*/
/************************************************************************/

/* buggo, this can take unbounded time, so it should be in-db, not inserver: */
static Vm_Obj
sen_copy(
    Vm_Obj me
){
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_SEN, 0 );
    Vm_Obj su;
    int    s;
    SEN_P(nu)->slots_used = su = SEN_P(me)->slots_used;
    vm_Dirty(nu);
    s  = (int) OBJ_TO_INT( su );	
    {   int  i;
	for (i = 0;   i < s;   ++i) {
	    struct Sen_Slot_Rec r   = SEN_P(me)->slot[i];
	    Vm_Obj o = r.leaf;
	    if (OBJ_IS_OBJ(o)) {
		if      (OBJ_IS_CLASS_SEL(o)) r.leaf = sel_copy(o);
		else if (OBJ_IS_CLASS_SEL(o)) r.leaf = sen_copy(o);
	    }
	    SEN_P(nu)->slot[i] = r;
	    vm_Dirty(nu);
    }	}

    return nu;
}

/************************************************************************/
/*-    sel_Copy								*/
/************************************************************************/


Vm_Obj
sel_Copy(
    Vm_Obj me
) {
    if (me == OBJ_NULL_SEL)   return OBJ_NULL_SEL;
    if (!OBJ_IS_OBJ(me)) {
	MUQ_WARN("Bad 'me' value in sel_Copy");
    }
    if (OBJ_IS_CLASS_SEL(me)) {
	return sel_copy( me );
    } else if (OBJ_IS_CLASS_SEN(me)) {
	return sen_copy( me );
    }
    MUQ_WARN("Bad 'me' value in sel_Copy");
    return me;	/* Purely to pacify compilers. */
}

/************************************************************************/
/*-    splitWhileInsertingInLeaf					*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingInLeaf(
    Vm_Obj me,
    Sel_Slot s
) {

    Vm_Int slots_used = OBJ_TO_INT( SEL_P(me)->slots_used );
    struct Sel_Slot_Rec tmp;

    /* Insert 's' into 'me' in sorted order: */
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	Vm_Obj h = SEL_P(me)->slot[i].key;
	Vm_Int cmp = obj_Neql( s->key, h );
	if (cmp < 0) {
	    /* Swap me and slot[i]: */
	    tmp         = *s;
	    *s          = SEL_P(me)->slot[i];
	    SEL_P(me)->slot[i] = tmp;	    			vm_Dirty(me);
	} else {
	    if (cmp == 0){
	        /* Our key is already present, we can just  */
	        /* set the value slot rather than inserting */
	        /* a new key-val pair into leaf:            */ 
#ifdef OLD
		SEL_P(me)->slot[i].val = s->val;		vm_Dirty(me);
#endif
		return OBJ_FROM_INT(0);
	    }
	}
    }
    if (slots_used < SEL_SLOTS) {
        /* Leaf isn't full, we can complete the   */
        /* insertion operation by appending final */
        /* key-val pair:                          */
	SEL_P(me)->slot[ slots_used ] = *s;
	SEL_P(me)->slots_used = OBJ_FROM_UNT( slots_used +1 );	vm_Dirty(me);
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
	    OBJ_CLASS_A_SEL,
	    0,
	    VM_DBFILE(me)
	);

	/* Pick split point -- midpoint.	  */
	Vm_Int   m =(SEL_SLOTS/2);
	tmp.key  = OBJ_FROM_INT( (Vm_Unt)0 );
#ifdef OLD
	tmp.val  = OBJ_FROM_INT( (Vm_Unt)0 );
#endif
	/* Over all slots in nu to be filled from me: */
	for (i = 0; i < SEL_SLOTS-m;  ++i) {
	    Vm_Int j = i + m;
	    SEL_P(nu)->slot[ i ] = SEL_P(me)->slot[ j ]; 			vm_Dirty(nu);
	    SEL_P(me)->slot[ j ] = tmp;	/* Clear free slots */			vm_Dirty(me);
	}
	SEL_P(nu)->slot[ SEL_SLOTS-m ] = *s;	 				vm_Dirty(nu);
	SEL_P(me)->slots_used = OBJ_FROM_UNT( m                         );	vm_Dirty(me);
	SEL_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((SEL_SLOTS+1)-m) );	vm_Dirty(nu);

	return nu;
    }
}

/************************************************************************/
/*-    findSlotFor							*/
/************************************************************************/

static Vm_Int
findSlotFor(
    Vm_Obj me,
    Sel_Slot s
) {
    Vm_Int i;
    for   (i = OBJ_TO_INT( SEN_P(me)->slots_used );   --i > 0;   ) {
	if (obj_Neql( s->key, SEN_P(me)->slot[i].key) >= 0)  break;
    }
    return i;
}

/************************************************************************/
/*-    splitWhileInsertingSlot						*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingSlot(
    Vm_Obj   me,
    Sel_Slot s
) {
    if (OBJ_IS_CLASS_SEL(me)) {
	return splitWhileInsertingInLeaf( me, s );
    } else {
	Vm_Obj nu;
	struct Sen_Slot_Rec ss;
	struct Sen_Slot_Rec tmp;
        Vm_Int    meSlot = findSlotFor(me,s);
        Vm_Obj    mynod  = SEN_P(me)->slot[meSlot].leaf;
	nu = splitWhileInsertingSlot( mynod, s );
	if (nu == OBJ_FROM_INT(0))   return OBJ_FROM_INT(0);
	if (OBJ_IS_CLASS_SEL(nu))   ss.key = SEL_P(nu)->slot[0].key;
	else                        ss.key = SEN_P(nu)->slot[0].key;
	ss.leaf = nu;
	{   Vm_Int slots_used = OBJ_TO_UNT( SEN_P(me)->slots_used );
	    Vm_Int    i;
	    for   (i = meSlot+1;   i < slots_used;   ++i) {
		/* Swap me and slot[i]: */
		tmp         = ss;
		ss          = SEN_P(me)->slot[i];
		SEN_P(me)->slot[i] = tmp;		                           vm_Dirty(me);
	    }
	    if (slots_used < SEN_SLOTS) {
		SEN_P(me)->slot[ slots_used ] = ss;			           vm_Dirty(me);
		SEN_P(me)->slots_used = OBJ_FROM_UNT( slots_used+1 );	           vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    } else {
		Vm_Obj nu = obj_Alloc_In_Dbfile(
		    OBJ_CLASS_A_SEN,
		    0,
		    VM_DBFILE(me)
		);
		/* Split available slots evenly between   */
		/* two nodes, leaving each containing one */
		/* more full than empty slot.  (Remember  */
		/* that a full node has an odd number of  */
		/* of slots, and we have one more than a  */
		/* leaffull of slots.)                    */
		for (i = 0; i   < SEN_SLOTS/2;  ++i) {
		    Vm_Int j = i + ((SEN_SLOTS/2)+1);
		    SEN_P(nu)->slot[ i ] = SEN_P(me)->slot[ j ];	           vm_Dirty(nu);
		    SEN_P(me)->slot[ j ] = sen_nil;	/* Clear free slots */	   vm_Dirty(me);
		    
		}
		SEN_P(nu)->slot[ SEN_SLOTS/2 ] = ss;	                           vm_Dirty(nu);
		SEN_P(me)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((SEN_SLOTS/2)+1) ); vm_Dirty(me);
		SEN_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((SEN_SLOTS/2)+1) ); vm_Dirty(nu);
		return nu;
	    }
	}
    }
}

/************************************************************************/
/*-    sel_Set								*/
/************************************************************************/

Vm_Obj
sel_Set(
    Vm_Obj me,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Unt dbfile
) {
    Vm_Obj            nu;
    struct Sel_Slot_Rec tmp;
    tmp.key = key;
#ifdef OLD
    tmp.val = val;
#endif
    if (me == OBJ_NULL_SEL) {
	me              = obj_Alloc_In_Dbfile( OBJ_CLASS_A_SEL, 0, dbfile );
	SEL_P(me)->slots_used  = OBJ_FROM_UNT( (Vm_Unt)1 );
	SEL_P(me)->slot[0]     = tmp;				vm_Dirty(me);
	return me;
    }
    if ((nu = splitWhileInsertingSlot( me, &tmp )) != OBJ_FROM_INT(0)) {
        Vm_Obj r       = obj_Alloc_In_Dbfile(OBJ_CLASS_A_SEN,0,VM_DBFILE(me));
	Vm_Obj h;
	if (OBJ_IS_CLASS_SEL(nu))   h = SEL_P(nu)->slot[0].key;
	else                        h = SEN_P(nu)->slot[0].key;
	{   Sen_P s = SEN_P(r);
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
    Vm_Int  slots_used = OBJ_TO_INT( SEL_P(me)->slots_used );
    Vm_Int  i;
    for    (i = slot;   i < slots_used-1;   ++i) {
	SEL_P(me)->slot[i] = SEL_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    SEL_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    SEL_P(me)->slot[ slots_used ] = sel_nil;			vm_Dirty(me);
   return  slots_used <= SEL_SLOTS/2;
}

/************************************************************************/
/*-    dropNodeSlot							*/
/************************************************************************/

static Vm_Int
dropNodeSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int slots_used = OBJ_TO_INT( SEN_P(me)->slots_used );
    Vm_Int i;
    for   (i = slot;   i < slots_used-1;   ++i) {
	SEN_P(me)->slot[i] = SEN_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    SEN_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    SEN_P(me)->slot[ slots_used ]= sen_nil;			vm_Dirty(me);
   return  slots_used <= SEN_SLOTS/2;
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

    Vm_Int slots_used = OBJ_TO_INT( SEN_P(me)->slots_used );

    struct Sel_Slot_Rec nul;
    nul.key  = OBJ_FROM_INT( 0 );
#ifdef OLD
    nul.val  = OBJ_FROM_INT( 0 );
#endif

    if (slotA < 0 || slotB >= slots_used) {
	return FALSE;
    }

    {	Vm_Obj a  = SEN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = SEN_P(me)->slot[ slotB ].leaf;
	
	/* mustBeLeaf(a); */
	/* mustBeLeaf(b); */

	{   Vm_Int aSlots = OBJ_TO_INT( SEL_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( SEL_P(b)->slots_used );
	    if (aSlots + bSlots > SEL_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int  i;
		for (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    SEL_P(a)->slot[i] = SEL_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    SEL_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    SEL_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);	
	    SEL_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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

    Vm_Int slots_used = OBJ_TO_INT( SEN_P(me)->slots_used );

    struct Sen_Slot_Rec nul;
    nul.key  = OBJ_FIRST;
    nul.leaf = OBJ_FROM_INT( 0 );

    /*mustBeNode(me)*/;
    if (slotA < 0 || slotB >= slots_used) {
        return FALSE;
    }

    {	Vm_Obj a  = SEN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = SEN_P(me)->slot[ slotB ].leaf;

	/*mustBeNode(a);*/
	/*mustBeNode(b);*/

	{   Vm_Int aSlots = OBJ_TO_INT( SEN_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( SEN_P(b)->slots_used );
	    if (aSlots + bSlots > SEN_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int i;
		for   (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    SEN_P(a)->slot[i] = SEN_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    SEN_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    SEN_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);
	    SEN_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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
    Sel_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( SEL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_Neql( s->key, SEL_P(me)->slot[i].key )) {
	    return dropLeafSlot( me, i );
	}
    }
    return OBJ_TO_INT( SEL_P(me)->slots_used ) <= (SEL_SLOTS/2);
}

/************************************************************************/
/*-    deleteInNode							*/
/************************************************************************/

static Vm_Int
deleteInNode(
    Vm_Obj me,
    Sel_Slot s
) {
    Vm_Int meSlot = findSlotFor(me,s);
    Vm_Obj kid    = SEN_P(me)->slot[ meSlot ].leaf;
    if (OBJ_IS_CLASS_SEL(kid)) {
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
    return OBJ_TO_INT( SEN_P(me)->slots_used ) <= (SEN_SLOTS/2);
}

/************************************************************************/
/*-    sel_Del								*/
/************************************************************************/

Vm_Obj
sel_Del(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Sel_Slot_Rec tmp;
    tmp.key = key;
#ifdef OLD
    tmp.val = OBJ_FROM_INT( (Vm_Int)0 );
#endif
    if (me == OBJ_NULL_SEL) return OBJ_NULL_SEL;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SEL(me)
    &&	!OBJ_IS_CLASS_SEN(me))
    ){
	MUQ_FATAL("Bad 'me' value in sel_Del");
    }
    if (OBJ_IS_CLASS_SEL(me)) {
        deleteInLeaf( me, &tmp );
	/* An empty leaf node can be discarded: */
	if (OBJ_TO_UNT( SEL_P(me)->slots_used ) == (Vm_Unt)0) {
	    return OBJ_NULL_SEL;
	}
    } else {
        deleteInNode( me, &tmp );
	/* An internal node with just one child can be discarded: */
	if (OBJ_TO_UNT( SEN_P(me)->slots_used ) == (Vm_Unt)1) {
	    return SEN_P(me)->slot[0].leaf;
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
    Sel_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( SEL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_Neql( s->key, SEL_P(me)->slot[i].key )) {
#ifdef OLD
	    return SEL_P(me)->slot[i].val;
#else
	    return OBJ_T;
#endif
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
    Sel_Slot s,
    Vm_Uch* key
) {
    Vm_Int slots_used = OBJ_TO_INT( SEL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_StrNeql( key, SEL_P(me)->slot[i].key )) {
#ifdef OLD
	    return SEL_P(me)->slot[i].val;
#else
	    return OBJ_T;
#endif
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
    Sel_Slot s
) {
    if (OBJ_IS_CLASS_SEL(me)) {
        return findInLeaf( me, s );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = SEN_P(me)->slot[ meSlot ].leaf;
	return         valb( oe, s );
    }
}

/************************************************************************/
/*-    valb_asciz							*/
/************************************************************************/

static Vm_Obj
valb_asciz(
    Vm_Obj me,
    Sel_Slot s,
    Vm_Uch* key
) {
    if (OBJ_IS_CLASS_SEL(me)) {
        return findInLeaf_Asciz( me, s, key );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = SEN_P(me)->slot[ meSlot ].leaf;
	return         valb_asciz( oe, s, key );
    }
}

/************************************************************************/
/*-    sel_Alloc							*/
/************************************************************************/

Vm_Obj
sel_Alloc(
    void
) {
    return OBJ_NULL_SEL;
}

/************************************************************************/
/*-    sel_Get								*/
/************************************************************************/

Vm_Obj
sel_Get(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Sel_Slot_Rec tmp;
    tmp.key = key;
#ifdef OLD
    tmp.val = OBJ_FROM_INT(0);
#endif
    if (me == OBJ_NULL_SEL) return OBJ_NIL;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SEL(me)
    &&	!OBJ_IS_CLASS_SEN(me))
    ){
        Vm_Uch buf[ 32 ];
        job_Sprint_Vm_Obj( buf, buf+32, me, /*quotestrings:*/TRUE );
	MUQ_FATAL("Bad 'me' value in sel_Get %s",buf);
    }
    {   Vm_Obj result = valb( me, &tmp );
	if    (result==OBJ_NOT_FOUND) result = OBJ_NIL;
        return result;
    }
}

/************************************************************************/
/*-    sel_Get_Asciz							*/
/************************************************************************/

Vm_Obj
sel_Get_Asciz(
    Vm_Obj me,
    Vm_Uch* key
) {

    struct Sel_Slot_Rec tmp;
    if (strlen(key) < VM_INTBYTES) {	
        /* Encode string as an immediate value */
        /* and then use the vanilla sel_Get(): */
	return sel_Get( me, stg_From_Asciz(key) );
    }
    tmp.key = OBJ_FROM_INT(0);
#ifdef OLD
    tmp.val = OBJ_FROM_INT(0);
#endif
    if (me == OBJ_NULL_SEL)   return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SEL(me)
    &&	!OBJ_IS_CLASS_SEN(me))
    ){
	MUQ_FATAL("Bad 'me' value in sel_Get_Asciz");
    }
    {   Vm_Obj result = valb_asciz( me, &tmp, key );
	if    (result==OBJ_NOT_FOUND) result = OBJ_NIL;
        return result;
    }
}

/************************************************************************/
/*-    sel_FirstInSubtree						*/
/************************************************************************/

Vm_Int
sel_FirstInSubtree(
    Vm_Obj* result,
    Vm_Obj me
) {
    if (OBJ_IS_CLASS_SEL(me)) {
	if (OBJ_TO_INT(SEL_P(me)->slots_used)==(Vm_Int)0)   return FALSE;
	*result = SEL_P(me)->slot[0].key;
	return TRUE;
    }
    return sel_FirstInSubtree( result, SEN_P(me)->slot[0].leaf );
}

/************************************************************************/
/*-    sel_First							*/
/************************************************************************/

Vm_Obj
sel_First(
    Vm_Obj me
) {
    Vm_Obj result;
    if (me==OBJ_NULL_SEL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SEL(me)
    &&	!OBJ_IS_CLASS_SEN(me))
    ){
	MUQ_FATAL("Bad 'me' value in sel_First");
    }
    if (sel_FirstInSubtree( &result, me )) {
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
    Sel_Slot s
) {
    /*mustBeLeaf(me);*/
    {   Vm_Int slots_used = OBJ_TO_INT( SEL_P(me)->slots_used );
	Vm_Int i;
	for   (i = 0;   i < slots_used;   ++i) {
	    if (!obj_Neql( s->key, SEL_P(me)->slot[i].key )) {
	        if (i+1 == slots_used)  return FALSE;
	        *result = SEL_P(me)->slot[i+1].key;
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
    Sel_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( SEN_P(me)->slots_used );
    Vm_Int meSlot     = findSlotFor(me,s);
    Vm_Obj oe         = SEN_P(me)->slot[ meSlot ].leaf;
    /*mustBeNode(me);*/
    if (OBJ_IS_CLASS_SEL(oe)) {
	if (nextInLeaf( result, oe, s ))   return TRUE;
	if (meSlot+1 < slots_used) {
	    return sel_FirstInSubtree( result, SEN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    } else {
	if (nextInNode( result, oe, s ))          return TRUE;
	if (meSlot+1 < slots_used) {
	    return sel_FirstInSubtree( result, SEN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    }
}

/************************************************************************/
/*-    sel_Next								*/
/************************************************************************/

Vm_Obj
sel_Next(
    Vm_Obj me,
    Vm_Obj key
) {
    Vm_Obj  result;
    struct Sel_Slot_Rec tmp;
    if (key==OBJ_FIRST)   return sel_First( me );
    tmp.key = key;
#ifdef OLD
    tmp.val = OBJ_FROM_INT(0);
#endif
    if (me==OBJ_NULL_SEL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SEL(me)
    &&	!OBJ_IS_CLASS_SEN(me))
    ){
	MUQ_FATAL("Bad 'me' value in sel_Del");
    }
    if (OBJ_IS_CLASS_SEL(me)) {
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
/*-    sel_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
sel_Startup (
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    if (sizeof(Sel_A_Header) > 512
    || sizeof(Sel_A_Header)+2*sizeof(struct Sel_Slot_Rec) < 512
    ){
        printf("*****  sizeof Sel_A_Header d=%d\n",sizeof(Sel_A_Header));
    }


    if (sizeof(Sen_A_Header) > 512
    || sizeof(Sen_A_Header)+2*sizeof(struct Sen_Slot_Rec) < 512
    ){
        printf("*****  sizeof Sen_A_Header d=%d\n",sizeof(Sen_A_Header));
    }

    obj_Sel_Test_Slot = OBJ_NULL_SEL;
}



/************************************************************************/
/*-    sel_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
sel_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    sel_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
sel_Shutdown(
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
/*-    for_new_sel -- Initialize new sel object.			*/
/************************************************************************/

static void
for_new_sel(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    int   i;
    Sel_P s 	= SEL_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = SEL_SLOTS;   i --> 0;   )   s->slot[i] = sel_nil;
    vm_Dirty(o);
}

static void
for_new_sen(
    Vm_Obj o,
    Vm_Unt size
) {
    int   i;
    Sen_P s 	= SEN_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = SEN_SLOTS;   i --> 0;   )   s->slot[i] = sen_nil;
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_sel -- Return size of sorted-dir-leaf.			*/
/************************************************************************/

static Vm_Unt
sizeof_sel(
    Vm_Unt size
) {
    return sizeof( Sel_A_Header );
}

/************************************************************************/
/*-    sizeof_sen -- Return size of sen-node.				*/
/************************************************************************/

static Vm_Unt
sizeof_sen(
    Vm_Unt size
) {
    return sizeof( Sen_A_Header );
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
