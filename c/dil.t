@example  @c
/*--   dil.c -- DIrectory Leafs: b-trees for Muq propdirs.		*/
/*--   din.c -- DIrectory Nodes.					*/
/*									*/
/*	Hashed btrees, used in hsh.t (Hash) objects.			*/
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
/* Created:      98Jan03						*/
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
/* Vm_Obj newtree = dil_Del( Vm_Obj tree, Vm_Obj key );      		*/
/*  Remove key from tree, if present.               			*/
/*                                                  			*/
/* Vm_Obj val = dil_Get( Vm_Obj tree, Vm_Obj key );                	*/
/*  Look up value of key in btree, NULL if missing. 			*/
/*                                                  			*/
/* Vm_Obj newtree = dil_Set( Vm_Obj tree, Vm_Obj key, Vm_Obj val );  	*/
/*  Insert new key+val pair in tree.                			*/
/*  If key already exists, resets its value.        			*/
/*                                                  			*/
/* nextKey = dil_Next( tree, key );              	    			*/
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

struct Dil_Slot_Rec dil_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_FROM_UNT( (Vm_Int)0 ),	/* Prefer NIL, but compiler won't allow it. */
    OBJ_FROM_UNT( (Vm_Int)0 )	/* Prefer NIL, but compiler won't allow it. */
};

struct Din_Slot_Rec din_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_NULL_DIL
};

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void dil_doTypes(void){
}
Obj_A_Module_Summary dil_Module_Summary = {
   "dil",
    dil_doTypes,
    dil_Startup,
    dil_Linkup,
    dil_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property dil_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};
static Obj_A_Special_Property din_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

static void     for_new_dil(     Vm_Obj, Vm_Unt );
static void     for_new_din(     Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_dil(  Vm_Unt );
static Vm_Unt   sizeof_din(  Vm_Unt );

Obj_A_Hardcoded_Class dil_Hardcoded_Class = {
    OBJ_FROM_BYT3('d','i','l'),
    "HashedBtreeLeaf",
    sizeof_dil,
    for_new_dil,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { dil_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class din_Hardcoded_Class = {
    OBJ_FROM_BYT3('d','i','n'),
    "HashedBtreeNode",
    sizeof_din,
    for_new_din,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { din_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};


/************************************************************************/
/*-    dil_copy								*/
/************************************************************************/

static Vm_Obj
dil_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_DIL, 0 );
    Dil_P d;
    Dil_P s;
    vm_Loc2( (void**)&d, (void**)&s, nu, me );
    d->slots_used = s->slots_used;
    {   int   i;
	for (i = DIL_SLOTS; i --> 0; ) d->slot[i] = s->slot[i];
    }
    vm_Dirty(nu);
    return nu;
}

/************************************************************************/
/*-    din_copy								*/
/************************************************************************/

/* buggo, this can take unbounded time, so it should be in-db, not inserver: */
static Vm_Obj
din_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_DIN, 0 );
    Vm_Obj su;
    int    s;
    DIN_P(nu)->slots_used = su = DIN_P(me)->slots_used;
    vm_Dirty(nu);
    s  = (int) OBJ_TO_INT( su );	
    {   int  i;
	for (i = 0;   i < s;   ++i) {
	    struct Din_Slot_Rec r   = DIN_P(me)->slot[i];
	    Vm_Obj o = r.leaf;
	    if (OBJ_IS_OBJ(o)) {
		if      (OBJ_IS_CLASS_DIL(o)) r.leaf = dil_copy(o);
		else if (OBJ_IS_CLASS_DIL(o)) r.leaf = din_copy(o);
	    }
	    DIN_P(nu)->slot[i] = r;
	    vm_Dirty(nu);
    }	}

    return nu;
}

/************************************************************************/
/*-    dil_Copy								*/
/************************************************************************/


Vm_Obj
dil_Copy(
    Vm_Obj me
) {
    if (me == OBJ_NULL_DIL)   return OBJ_NULL_DIL;
    if (!OBJ_IS_OBJ(me)) {
	MUQ_WARN("Bad 'me' value in dil_Copy");
    }
    if (OBJ_IS_CLASS_DIL(me)) {
	return dil_copy( me );
    } else if (OBJ_IS_CLASS_DIN(me)) {
	return din_copy( me );
    }
    MUQ_WARN("Bad 'me' value in dil_Copy");
    return me;	/* Purely to pacify compilers. */
}

/************************************************************************/
/*-    dil_Hash								*/
/************************************************************************/


Vm_Obj
dil_Hash(
    Vm_Obj key
) {
    /* Immediate values are their own hashes.    */
    /* Most objects are also their own hashes -- */
    /* objects which compare by address rather   */
    /* than contents. Non-immediate values which */
    /* compare by value rather than address do   */
    /* need to be hashed, however -- strings in  */
    /* particular:                               */
    
    return (*mod_Type_Summary[ OBJ_TYPE(key) ]->do_hash)( key ) & DIL_TO_INT_MASK;
}

/************************************************************************/
/*-    dil_Hash_Asciz							*/
/************************************************************************/


Vm_Obj
dil_Hash_Asciz(
    Vm_Uch* key
) {
    Vm_Int  result = sha_InsecureHash(key,strlen(key));
    return  result & DIL_TO_INT_MASK;
}

/************************************************************************/
/*-    splitWhileInsertingInLeaf					*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingInLeaf(
    Vm_Obj me,
    Dil_Slot s
) {

    Vm_Int slots_used = OBJ_TO_INT( DIL_P(me)->slots_used );
    struct Dil_Slot_Rec tmp;

    /* Insert 's' into 'me' in sorted order: */
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	Vm_Obj h = DIL_P(me)->slot[i].hash;
	if (s->hash   < h) {
	    /* Swap me and slot[i]: */
	    tmp         = *s;
	    *s          = DIL_P(me)->slot[i];
	    DIL_P(me)->slot[i] = tmp;	    			vm_Dirty(me);
	} else {
	    if (s->hash  == h
	    && !obj_Neql( s->key, DIL_P(me)->slot[i].key )
	    ){
	        /* Our key is already present, we can just  */
	        /* set the value slot rather than inserting */
	        /* a new key-val-hash triple into leaf:     */ 
		DIL_P(me)->slot[i].val = s->val;		vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    }
	}
    }
    if (slots_used < DIL_SLOTS) {
        /* Leaf isn't full, we can complete the   */
        /* insertion operation by appending final */
        /* key-val-hash triple:                   */
	DIL_P(me)->slot[ slots_used ] = *s;
	DIL_P(me)->slots_used = OBJ_FROM_UNT( slots_used +1 );	vm_Dirty(me);
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
	    OBJ_CLASS_A_DIL,
	    0,
	    VM_DBFILE(me)
	);

	/* Pick split point.  This will be the	  */
	/* midpoint barring hash collisions:      */
	Vm_Int   m;	/* 'm'iddle -- split point */
	for  (m =(DIL_SLOTS/2);
	      m < DIL_SLOTS-1  &&  DIL_P(me)->slot[m].hash==DIL_P(me)->slot[m-1].hash;
	      m++
	);
	for  (;
	      m > 1  &&  DIL_P(me)->slot[m].hash == DIL_P(me)->slot[m-1].hash;
	      m--
	);
	if (DIL_P(me)->slot[m].hash == DIL_P(me)->slot[m-1].hash) {
	    MUQ_WARN("Too many hash collisions");
	}

	tmp.hash = OBJ_FROM_UNT( (Vm_Unt)0 );
	tmp.key  = OBJ_FROM_INT( (Vm_Unt)0 );
	tmp.val  = OBJ_FROM_INT( (Vm_Unt)0 );
	/* Over all slots in nu to be filled from me: */
	for (i = 0; i < DIL_SLOTS-m;  ++i) {
	    Vm_Int j = i + m;
	    DIL_P(nu)->slot[ i ] = DIL_P(me)->slot[ j ]; 			vm_Dirty(nu);
	    DIL_P(me)->slot[ j ] = tmp;	/* Clear free slots */			vm_Dirty(me);
	}
	DIL_P(nu)->slot[ DIL_SLOTS-m ] = *s;	 				vm_Dirty(nu);
	DIL_P(me)->slots_used = OBJ_FROM_UNT( m                         );	vm_Dirty(me);
	DIL_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((DIL_SLOTS+1)-m) );	vm_Dirty(nu);

	return nu;
    }
}

/************************************************************************/
/*-    findSlotFor							*/
/************************************************************************/

static Vm_Int
findSlotFor(
    Vm_Obj me,
    Dil_Slot s
) {
    Vm_Int i;
    for   (i = OBJ_TO_INT( DIN_P(me)->slots_used );   --i > 0;   ) {
	if (s->hash >= DIN_P(me)->slot[i].hash)  break;
    }
    return i;
}

/************************************************************************/
/*-    splitWhileInsertingSlot						*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingSlot(
    Vm_Obj   me,
    Dil_Slot s
) {
    if (OBJ_IS_CLASS_DIL(me)) {
	return splitWhileInsertingInLeaf( me, s );
    } else {
	Vm_Obj nu;
	struct Din_Slot_Rec ss;
	struct Din_Slot_Rec tmp;
        Vm_Int    meSlot = findSlotFor(me,s);
        Vm_Obj    mynod  = DIN_P(me)->slot[meSlot].leaf;
	nu = splitWhileInsertingSlot( mynod, s );
	if (nu == OBJ_FROM_INT(0))   return OBJ_FROM_INT(0);
	if (OBJ_IS_CLASS_DIL(nu))   ss.hash = DIL_P(nu)->slot[0].hash;
	else                        ss.hash = DIN_P(nu)->slot[0].hash;
	ss.leaf = nu;
	{   Vm_Int slots_used = OBJ_TO_UNT( DIN_P(me)->slots_used );
	    Vm_Int    i;
	    for   (i = meSlot+1;   i < slots_used;   ++i) {
		/* Swap me and slot[i]: */
		tmp         = ss;
		ss          = DIN_P(me)->slot[i];
		DIN_P(me)->slot[i] = tmp;		                           vm_Dirty(me);
	    }
	    if (slots_used < DIN_SLOTS) {
		DIN_P(me)->slot[ slots_used ] = ss;			           vm_Dirty(me);
		DIN_P(me)->slots_used = OBJ_FROM_UNT( slots_used+1 );	           vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    } else {
		Vm_Obj nu = obj_Alloc_In_Dbfile(
		    OBJ_CLASS_A_DIN,
		    0,
		    VM_DBFILE(me)
		);
		/* Split available slots evenly between   */
		/* two nodes, leaving each containing one */
		/* more full than empty slot.  (Remember  */
		/* that a full node has an odd number of  */
		/* of slots, and we have one more than a  */
		/* leaffull of slots.)                    */
		for (i = 0; i   < DIN_SLOTS/2;  ++i) {
		    Vm_Int j = i + ((DIN_SLOTS/2)+1);
		    DIN_P(nu)->slot[ i ] = DIN_P(me)->slot[ j ];	           vm_Dirty(nu);
		    DIN_P(me)->slot[ j ] = din_nil;	/* Clear free slots */	   vm_Dirty(me);
		    
		}
		DIN_P(nu)->slot[ DIN_SLOTS/2 ] = ss;	                           vm_Dirty(nu);
		DIN_P(me)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((DIN_SLOTS/2)+1) ); vm_Dirty(me);
		DIN_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((DIN_SLOTS/2)+1) ); vm_Dirty(nu);
		return nu;
	    }
	}
    }
}

/************************************************************************/
/*-    dil_Set								*/
/************************************************************************/

Vm_Obj
dil_Set(
    Vm_Obj me,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Unt dbfile
) {
    Vm_Obj            nu;
    struct Dil_Slot_Rec tmp;
    tmp.hash= dil_Hash(key);
    tmp.key = key;
    tmp.val = val;

    if (me == OBJ_NULL_DIL) {
	me              = obj_Alloc_In_Dbfile( OBJ_CLASS_A_DIL, 0, dbfile );
	DIL_P(me)->slots_used  = OBJ_FROM_UNT( (Vm_Unt)1 );
	DIL_P(me)->slot[0]     = tmp;				vm_Dirty(me);
	return me;
    }
    if ((nu = splitWhileInsertingSlot( me, &tmp )) != OBJ_FROM_INT(0)) {
        Vm_Obj r       = obj_Alloc_In_Dbfile(OBJ_CLASS_A_DIN,0,VM_DBFILE(me));
	Vm_Obj h;
	if (OBJ_IS_CLASS_DIL(nu))   h = DIL_P(nu)->slot[0].hash;
	else                        h = DIN_P(nu)->slot[0].hash;
	{   Din_P s = DIN_P(r);
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

/************************************************************************/
/*-    dropLeafSlot							*/
/************************************************************************/

static Vm_Int
dropLeafSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int  slots_used = OBJ_TO_INT( DIL_P(me)->slots_used );
    Vm_Int  i;
    for    (i = slot;   i < slots_used-1;   ++i) {
	DIL_P(me)->slot[i] = DIL_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    DIL_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    DIL_P(me)->slot[ slots_used ] = dil_nil;			vm_Dirty(me);
   return  slots_used <= DIL_SLOTS/2;
}

/************************************************************************/
/*-    dropNodeSlot							*/
/************************************************************************/

static Vm_Int
dropNodeSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int slots_used = OBJ_TO_INT( DIN_P(me)->slots_used );
    Vm_Int i;
    for   (i = slot;   i < slots_used-1;   ++i) {
	DIN_P(me)->slot[i] = DIN_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    DIN_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    DIN_P(me)->slot[ slots_used ]= din_nil;			vm_Dirty(me);
   return  slots_used <= DIN_SLOTS/2;
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

    Vm_Int slots_used = OBJ_TO_INT( DIN_P(me)->slots_used );

    struct Dil_Slot_Rec nul;
    nul.hash = OBJ_FROM_UNT( 0 );
    nul.key  = OBJ_FROM_INT( 0 );
    nul.val  = OBJ_FROM_INT( 0 );

    if (slotA < 0 || slotB >= slots_used) {
	return FALSE;
    }

    {	Vm_Obj a  = DIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = DIN_P(me)->slot[ slotB ].leaf;
	
	/* mustBeLeaf(a); */
	/* mustBeLeaf(b); */

	{   Vm_Int aSlots = OBJ_TO_INT( DIL_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( DIL_P(b)->slots_used );
	    if (aSlots + bSlots > DIL_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int  i;
		for (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    DIL_P(a)->slot[i] = DIL_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    DIL_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    DIL_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);	
	    DIL_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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

    Vm_Int slots_used = OBJ_TO_INT( DIN_P(me)->slots_used );

    struct Din_Slot_Rec nul;
    nul.hash = OBJ_FROM_UNT( 0 );
    nul.leaf = OBJ_FROM_INT( 0 );

    /*mustBeNode(me)*/;
    if (slotA < 0 || slotB >= slots_used) {
        return FALSE;
    }

    {	Vm_Obj a  = DIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = DIN_P(me)->slot[ slotB ].leaf;

	/*mustBeNode(a);*/
	/*mustBeNode(b);*/

	{   Vm_Int aSlots = OBJ_TO_INT( DIN_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( DIN_P(b)->slots_used );
	    if (aSlots + bSlots > DIN_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int i;
		for   (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    DIN_P(a)->slot[i] = DIN_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    DIN_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    DIN_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);
	    DIN_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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
    Dil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( DIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	if (s->hash == DIL_P(me)->slot[i].hash
	&&	!obj_Neql( s->key, DIL_P(me)->slot[i].key )    
	){
	    return dropLeafSlot( me, i );
	}
    }
    return OBJ_TO_INT( DIL_P(me)->slots_used ) <= (DIL_SLOTS/2);
}

/************************************************************************/
/*-    deleteInNode							*/
/************************************************************************/

static Vm_Int
deleteInNode(
    Vm_Obj me,
    Dil_Slot s
 ) {
    Vm_Int meSlot = findSlotFor(me,s);
    Vm_Obj kid    = DIN_P(me)->slot[ meSlot ].leaf;
    if (OBJ_IS_CLASS_DIL(kid)) {
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
    return OBJ_TO_INT( DIN_P(me)->slots_used ) <= (DIN_SLOTS/2);
}

/************************************************************************/
/*-    dil_Del								*/
/************************************************************************/

Vm_Obj
dil_Del(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Dil_Slot_Rec tmp;
    tmp.hash= dil_Hash(key);
    tmp.key = key;
    tmp.val = OBJ_FROM_INT( (Vm_Int)0 );
    if (me == OBJ_NULL_DIL) return OBJ_NULL_DIL;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_DIL(me)
    &&	!OBJ_IS_CLASS_DIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in dil_Del");
    }
    if (OBJ_IS_CLASS_DIL(me)) {
        deleteInLeaf( me, &tmp );
	/* An empty leaf node can be discarded: */
	if (OBJ_TO_UNT( DIL_P(me)->slots_used ) == (Vm_Unt)0) {
	    return OBJ_NULL_DIL;
	}
    } else {
        deleteInNode( me, &tmp );
	/* An internal node with just one child can be discarded: */
	if (OBJ_TO_UNT( DIN_P(me)->slots_used ) == (Vm_Unt)1) {
	    return DIN_P(me)->slot[0].leaf;
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
    Dil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( DIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	if (s->hash == DIL_P(me)->slot[i].hash
	&&	!obj_Neql( s->key, DIL_P(me)->slot[i].key )    
	){
	    return DIL_P(me)->slot[i].val;
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
    Dil_Slot s,
    Vm_Uch* key
) {
    Vm_Int slots_used = OBJ_TO_INT( DIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	if (s->hash == DIL_P(me)->slot[i].hash
	&&	!obj_StrNeql( key, DIL_P(me)->slot[i].key )    
	){
	    return DIL_P(me)->slot[i].val;
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
    Dil_Slot s
) {
    if (OBJ_IS_CLASS_DIL(me)) {
        return findInLeaf( me, s );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = DIN_P(me)->slot[ meSlot ].leaf;
	return         valb( oe, s );
    }
}

/************************************************************************/
/*-    valb_asciz							*/
/************************************************************************/

static Vm_Obj
valb_asciz(
    Vm_Obj me,
    Dil_Slot s,
    Vm_Uch* key
) {
    if (OBJ_IS_CLASS_DIL(me)) {
        return findInLeaf_Asciz( me, s, key );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = DIN_P(me)->slot[ meSlot ].leaf;
	return         valb_asciz( oe, s, key );
    }
}

/************************************************************************/
/*-    dil_Alloc							*/
/************************************************************************/

Vm_Obj
dil_Alloc(
    void
) {
    /* Buggo? OBJ_NULL_DIL has no dbfile info associated    */
    /* with it, which ultimately means that job_P_Btree_Set */
    /* sometimes has to guess what dbfile to use.           */
    return OBJ_NULL_DIL;
}

/************************************************************************/
/*-    dil_Get								*/
/************************************************************************/

Vm_Obj
dil_Get(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Dil_Slot_Rec tmp;
    tmp.hash= dil_Hash(key);
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me == OBJ_NULL_DIL) {
        return OBJ_NOT_FOUND;
    }
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_DIL(me)
    &&	!OBJ_IS_CLASS_DIN(me))
    ){
        Vm_Uch buf[ 32 ];
        job_Sprint_Vm_Obj( buf, buf+32, me, /*quotestrings:*/TRUE );
	MUQ_FATAL("Bad 'me' value in dil_Get %s",buf);
    }
    return valb( me, &tmp );
}

/************************************************************************/
/*-    dil_Get_Asciz							*/
/************************************************************************/

Vm_Obj
dil_Get_Asciz(
    Vm_Obj me,
    Vm_Uch* key
) {

    struct Dil_Slot_Rec tmp;
    if (strlen(key) < VM_INTBYTES) {	
        /* Encode string as an immediate value */
        /* and then use the vanilla dil_Get(): */
	return dil_Get( me, stg_From_Asciz(key) );
    }
    tmp.hash= dil_Hash_Asciz(key);
    tmp.key = OBJ_FROM_INT(0);
    tmp.val = OBJ_FROM_INT(0);
    if (me == OBJ_NULL_DIL)   return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_DIL(me)
    &&	!OBJ_IS_CLASS_DIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in dil_Get_Asciz");
    }
    return valb_asciz( me, &tmp, key );
}

/************************************************************************/
/*-    dil_FirstInSubtree						*/
/************************************************************************/

Vm_Int
dil_FirstInSubtree(
    Vm_Obj* result,
    Vm_Obj me
) {
    if (OBJ_IS_CLASS_DIL(me)) {
	if (OBJ_TO_INT(DIL_P(me)->slots_used)==(Vm_Int)0)   return FALSE;
	*result = DIL_P(me)->slot[0].key;
	return TRUE;
    }
    return dil_FirstInSubtree( result, DIN_P(me)->slot[0].leaf );
}

/************************************************************************/
/*-    dil_First							*/
/************************************************************************/

Vm_Obj
dil_First(
    Vm_Obj me
) {
    Vm_Obj result;
    if (me==OBJ_NULL_DIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_DIL(me)
    &&	!OBJ_IS_CLASS_DIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in dil_First");
    }
    if (dil_FirstInSubtree( &result, me )) {
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
    Dil_Slot s
) {
    /*mustBeLeaf(me);*/
    {   Vm_Int slots_used = OBJ_TO_INT( DIL_P(me)->slots_used );
	Vm_Int i;
	for   (i = 0;   i < slots_used;   ++i) {
	    if (s->hash == DIL_P(me)->slot[i].hash
	    &&	!obj_Neql( s->key, DIL_P(me)->slot[i].key )    
	    ){
	        if (i+1 == slots_used)  return FALSE;
	        *result = DIL_P(me)->slot[i+1].key;
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
    Dil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( DIN_P(me)->slots_used );
    Vm_Int meSlot     = findSlotFor(me,s);
    Vm_Obj oe         = DIN_P(me)->slot[ meSlot ].leaf;
    /*mustBeNode(me);*/
    if (OBJ_IS_CLASS_DIL(oe)) {
	if (nextInLeaf( result, oe, s ))   return TRUE;
	if (meSlot+1 < slots_used) {
	    return dil_FirstInSubtree( result, DIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    } else {
	if (nextInNode( result, oe, s ))          return TRUE;
	if (meSlot+1 < slots_used) {
	    return dil_FirstInSubtree( result, DIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    }
}

/************************************************************************/
/*-    dil_Next								*/
/************************************************************************/

Vm_Obj
dil_Next(
    Vm_Obj me,
    Vm_Obj key
) {
    Vm_Obj  result;
    struct Dil_Slot_Rec tmp;
    if (key==OBJ_FIRST)   return dil_First( me );
    tmp.hash= dil_Hash(key);
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me==OBJ_NULL_DIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_DIL(me)
    &&	!OBJ_IS_CLASS_DIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in dil_Del");
    }
    if (OBJ_IS_CLASS_DIL(me)) {
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
/*-    dil_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
dil_Startup (
    void
) {
    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;

    if (sizeof(Dil_A_Header) > 512
    || sizeof(Dil_A_Header)+2*sizeof(struct Dil_Slot_Rec) < 512
    ){
        printf("*****  sizeof Dil_A_Header d=%d\n",sizeof(Dil_A_Header));
    }


    if (sizeof(Din_A_Header) > 512
    || sizeof(Din_A_Header)+2*sizeof(struct Din_Slot_Rec) < 512
    ){
        printf("*****  sizeof Din_A_Header d=%d\n",sizeof(Din_A_Header));
    }

    obj_Dil_Test_Slot = OBJ_NULL_DIL;
}



/************************************************************************/
/*-    dil_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
dil_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    dil_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
dil_Shutdown(
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
/*-    for_new_dil -- Initialize new dil object.			*/
/************************************************************************/

static void
for_new_dil(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    int   i;
    Dil_P s 	= DIL_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = DIL_SLOTS;   i --> 0;   )   s->slot[i] = dil_nil;
    vm_Dirty(o);
}

static void
for_new_din(
    Vm_Obj o,
    Vm_Unt size
) {
    int   i;
    Din_P s 	= DIN_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = DIN_SLOTS;   i --> 0;   )   s->slot[i] = din_nil;
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_dil -- Return size of dir-leaf.				*/
/************************************************************************/

static Vm_Unt
sizeof_dil(
    Vm_Unt size
) {
    return sizeof( Dil_A_Header );
}

/************************************************************************/
/*-    sizeof_din -- Return size of dir-node.				*/
/************************************************************************/

static Vm_Unt
sizeof_din(
    Vm_Unt size
) {
    return sizeof( Din_A_Header );
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
