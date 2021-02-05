@example  @c
/*--   sil.c -- Sorted dIrectory Leafs: b-trees for Muq propdirs.	*/
/*--   sin.c -- Sorted dIrectory Nodes.					*/
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
/* Vm_Obj newtree = sil_Del( Vm_Obj tree, Vm_Obj key );      		*/
/*  Remove key from tree, if present.               			*/
/*                                                  			*/
/* Vm_Obj val = sil_Get( Vm_Obj tree, Vm_Obj key );                	*/
/*  Look up value of key in btree, NULL if missing. 			*/
/*                                                  			*/
/* Vm_Obj newtree = sil_Set( Vm_Obj tree, Vm_Obj key, Vm_Obj val );  	*/
/*  Insert new key+val pair in tree.                			*/
/*  If key already exists, resets its value.        			*/
/*                                                  			*/
/* nextKey = sil_Next( tree, key );              	    		*/
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

struct Sil_Slot_Rec sil_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_FROM_UNT( (Vm_Int)0 )	/* Prefer NIL, but compiler won't allow it. */
};

struct Sin_Slot_Rec sin_nil = {
    OBJ_FROM_UNT( (Vm_Int)0 ),
    OBJ_NULL_SIL
};

/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void sil_doTypes(void){
}
Obj_A_Module_Summary sil_Module_Summary = {
   "sil",
    sil_doTypes,
    sil_Startup,
    sil_Linkup,
    sil_Shutdown
};

/* Description of standard-header system properties: */
static Obj_A_Special_Property sil_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};
static Obj_A_Special_Property sin_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

static void     for_new_sil(     Vm_Obj, Vm_Unt );
static void     for_new_sin(     Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_sil(  Vm_Unt );
static Vm_Unt   sizeof_sin(  Vm_Unt );

Obj_A_Hardcoded_Class sil_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','i','l'),
    "SortedBtreeLeaf",
    sizeof_sil,
    for_new_sil,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { sil_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class sin_Hardcoded_Class = {
    OBJ_FROM_BYT3('s','i','n'),
    "SortedBtreeNode",
    sizeof_sin,
    for_new_sin,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { sin_system_properties, NULL, NULL, NULL /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};

/************************************************************************/
/*-    sil_PrintLeaf							*/
/************************************************************************/

float f;
void
sil_PrintLeaf(
    Vm_Obj n,
    Vm_Int depth
) {
#ifdef JUNQUE
  /*    int buf[100];
    int i;
    for (i = 100; i --> 0; ) buf[i]=-1; */
#endif
    Vm_Int i;
    printf("%*s leaf %" VM_X " slots_used %d\n",(int)depth,"",n,(int) OBJ_TO_INT( SIL_P(n)->slots_used ));
    for (i = 0;  i < OBJ_TO_INT( SIL_P(n)->slots_used ); ++i) {
        Vm_Uch buf[ 320 ];
        job_Sprint_Vm_Obj( buf, buf+320, SIL_P(n)->slot[i].key, /*quotestrings:*/TRUE );
	printf("%*s key %" VM_X " val %" VM_X " %s\n",(int)depth+2,"",SIL_P(n)->slot[i].key,SIL_P(n)->slot[i].val,buf);
    }
}

/************************************************************************/
/*-    sil_PrintNode							*/
/************************************************************************/

void
sil_PrintNode(
    Vm_Obj n,
    Vm_Int depth
) {
    if (n == OBJ_NULL_SIL) { printf("%*s NULL\n",(int)depth,""); return; }
    if (OBJ_IS_CLASS_SIL(n)) {
	sil_PrintLeaf( n, depth );
    } else {
	Vm_Int i;
	printf("%*s node %" VM_X "\n",(int)depth,"",n);
	for (i = 0;  i < OBJ_TO_UNT( SIN_P(n)->slots_used ); ++i) {
Vm_Obj key = SIN_P(n)->slot[i].key;
char buf[2048];
if (stg_Is_Stg(key)) {
Vm_Int len = stg_Len( key );
if (len >= 2040) len = 2040;
stg_Get_Bytes( (Vm_Uch*)buf, len, key, 0 );
buf[len]=0;
} else {
buf[0]=0;
}
	    printf("%*s key %" VM_X " kid %" VM_X " %s\n",(int)depth+2,"",SIN_P(n)->slot[i].key,SIN_P(n)->slot[i].leaf,buf);
	}
	for (i = 0;  i < OBJ_TO_UNT( SIN_P(n)->slots_used ); ++i) {
	    sil_PrintNode( SIN_P(n)->slot[i].leaf, depth+4 );
	}
    }
}

/************************************************************************/
/*-    sil_copy								*/
/************************************************************************/

static Vm_Obj
sil_copy(
    Vm_Obj me
) {
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_SIL, 0 );
    Sil_P d;
    Sil_P s;
    vm_Loc2( (void**)&d, (void**)&s, nu, me );
    d->slots_used = s->slots_used;
    {   int   i;
	for (i = SIL_SLOTS; i --> 0; ) d->slot[i] = s->slot[i];
    }
    vm_Dirty(nu);
    return nu;
}

/************************************************************************/
/*-    sin_copy								*/
/************************************************************************/

/* buggo, this can take unbounded time, so it should be in-db, not inserver: */
static Vm_Obj
sin_copy(
    Vm_Obj me
){
    Vm_Obj nu = obj_Alloc( OBJ_CLASS_A_SIN, 0 );
    Vm_Obj su;
    int    s;
    SIN_P(nu)->slots_used = su = SIN_P(me)->slots_used;
    vm_Dirty(nu);
    s  = (int) OBJ_TO_INT( su );	
    {   int  i;
	for (i = 0;   i < s;   ++i) {
	    struct Sin_Slot_Rec r   = SIN_P(me)->slot[i];
	    Vm_Obj o = r.leaf;
	    if (OBJ_IS_OBJ(o)) {
		if      (OBJ_IS_CLASS_SIL(o)) r.leaf = sil_copy(o);
		else if (OBJ_IS_CLASS_SIL(o)) r.leaf = sin_copy(o);
	    }
	    SIN_P(nu)->slot[i] = r;
	    vm_Dirty(nu);
    }	}

    return nu;
}

/************************************************************************/
/*-    sil_Copy								*/
/************************************************************************/


Vm_Obj
sil_Copy(
    Vm_Obj me
) {
    if (me == OBJ_NULL_SIL)   return OBJ_NULL_SIL;
    if (!OBJ_IS_OBJ(me)) {
	MUQ_WARN("Bad 'me' value in sil_Copy");
    }
    if (OBJ_IS_CLASS_SIL(me)) {
	return sil_copy( me );
    } else if (OBJ_IS_CLASS_SIN(me)) {
	return sin_copy( me );
    }
    MUQ_WARN("Bad 'me' value in sil_Copy");
    return me;	/* Purely to pacify compilers. */
}

/************************************************************************/
/*-    splitWhileInsertingInLeaf					*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingInLeaf(
    Vm_Obj me,
    Sil_Slot s
) {

    Vm_Int slots_used = OBJ_TO_INT( SIL_P(me)->slots_used );
    struct Sil_Slot_Rec tmp;

    /* Insert 's' into 'me' in sorted order: */
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
	Vm_Obj h = SIL_P(me)->slot[i].key;
	Vm_Int cmp = obj_Neql( s->key, h );
	if (cmp < 0) {
	    /* Swap me and slot[i]: */
	    tmp         = *s;
	    *s          = SIL_P(me)->slot[i];
	    SIL_P(me)->slot[i] = tmp;	    			vm_Dirty(me);
	} else {
	    if (cmp == 0){
	        /* Our key is already present, we can just  */
	        /* set the value slot rather than inserting */
	        /* a new key-val pair into leaf:            */ 
		SIL_P(me)->slot[i].val = s->val;		vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    }
	}
    }
    if (slots_used < SIL_SLOTS) {
        /* Leaf isn't full, we can complete the   */
        /* insertion operation by appending final */
        /* key-val pair:                          */
	SIL_P(me)->slot[ slots_used ] = *s;
	SIL_P(me)->slots_used = OBJ_FROM_UNT( slots_used +1 );	vm_Dirty(me);
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
	    OBJ_CLASS_A_SIL,
	    0,
	    VM_DBFILE(me)
	);

	/* Pick split point -- midpoint.	  */
	Vm_Int   m =(SIL_SLOTS/2);
	tmp.key  = OBJ_FROM_INT( (Vm_Unt)0 );
	tmp.val  = OBJ_FROM_INT( (Vm_Unt)0 );
	/* Over all slots in nu to be filled from me: */
	for (i = 0; i < SIL_SLOTS-m;  ++i) {
	    Vm_Int j = i + m;
	    SIL_P(nu)->slot[ i ] = SIL_P(me)->slot[ j ]; 			vm_Dirty(nu);
	    SIL_P(me)->slot[ j ] = tmp;	/* Clear free slots */			vm_Dirty(me);
	}
	SIL_P(nu)->slot[ SIL_SLOTS-m ] = *s;	 				vm_Dirty(nu);
	SIL_P(me)->slots_used = OBJ_FROM_UNT( m                         );	vm_Dirty(me);
	SIL_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((SIL_SLOTS+1)-m) );	vm_Dirty(nu);

	return nu;
    }
}

/************************************************************************/
/*-    findSlotFor							*/
/************************************************************************/

static Vm_Int
findSlotFor(
    Vm_Obj me,
    Sil_Slot s
) {
    Vm_Int i;
    for   (i = OBJ_TO_INT( SIN_P(me)->slots_used );   --i > 0;   ) {
	if (obj_Neql( s->key, SIN_P(me)->slot[i].key) >= 0)  break;
    }
    return i;
}

/************************************************************************/
/*-    findSlotFor_Asciz						*/
/************************************************************************/

static Vm_Int
findSlotFor_Asciz(
    Vm_Obj me,
    Vm_Uch*key
) {
    Vm_Int i;
    for   (i = OBJ_TO_INT( SIN_P(me)->slots_used );   --i > 0;   ) {
	if (obj_StrNeql( key, SIL_P(me)->slot[i].key ) >= 0)  break;
    }
    return i;
}

/************************************************************************/
/*-    splitWhileInsertingSlot						*/
/************************************************************************/

static Vm_Obj
splitWhileInsertingSlot(
    Vm_Obj   me,
    Sil_Slot s
) {
    if (OBJ_IS_CLASS_SIL(me)) {
	return splitWhileInsertingInLeaf( me, s );
    } else {
	Vm_Obj nu;
	struct Sin_Slot_Rec ss;
	struct Sin_Slot_Rec tmp;
        Vm_Int    meSlot = findSlotFor(me,s);
        Vm_Obj    mynod  = SIN_P(me)->slot[meSlot].leaf;
	nu = splitWhileInsertingSlot( mynod, s );
	if (nu == OBJ_FROM_INT(0))   return OBJ_FROM_INT(0); /* Child didn't split. */
	if (OBJ_IS_CLASS_SIL(nu))   ss.key = SIL_P(nu)->slot[0].key;
	else                        ss.key = SIN_P(nu)->slot[0].key;
	ss.leaf = nu;
	{   Vm_Int slots_used = OBJ_TO_UNT( SIN_P(me)->slots_used );
	    Vm_Int    i;
	    for   (i = meSlot+1;   i < slots_used;   ++i) {
		/* Swap me and slot[i]: */
		tmp         = ss;
		ss          = SIN_P(me)->slot[i];
		SIN_P(me)->slot[i] = tmp;		                           vm_Dirty(me);
	    }
	    if (slots_used < SIN_SLOTS) {
		SIN_P(me)->slot[ slots_used ] = ss;			           vm_Dirty(me);
		SIN_P(me)->slots_used = OBJ_FROM_UNT( slots_used+1 );	           vm_Dirty(me);
		return OBJ_FROM_INT(0);
	    } else {
		Vm_Obj nu = obj_Alloc_In_Dbfile(
		    OBJ_CLASS_A_SIN,
		    0,
		    VM_DBFILE(me)
		);
		/* Split available slots evenly between   */
		/* two nodes, leaving each containing one */
		/* more full than empty slot.  (Remember  */
		/* that a full node has an odd number of  */
		/* of slots, and we have one more than a  */
		/* nodefull of slots.)                    */
		for (i = 0; i   < SIN_SLOTS/2;  ++i) {
		    Vm_Int j = i + ((SIN_SLOTS/2)+1);
		    SIN_P(nu)->slot[ i ] = SIN_P(me)->slot[ j ];	           vm_Dirty(nu);
		    SIN_P(me)->slot[ j ] = sin_nil;	/* Clear free slots */	   vm_Dirty(me);
		    
		}
		SIN_P(nu)->slot[ SIN_SLOTS/2 ] = ss;	                           vm_Dirty(nu);
		SIN_P(me)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((SIN_SLOTS/2)+1) ); vm_Dirty(me);
		SIN_P(nu)->slots_used = OBJ_FROM_UNT( (Vm_Unt)((SIN_SLOTS/2)+1) ); vm_Dirty(nu);
		return nu;
	    }
	}
    }
}

/************************************************************************/
/*-    sil_Set								*/
/************************************************************************/

Vm_Obj
sil_Set(
    Vm_Obj me,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Unt dbfile
) {
    Vm_Obj            nu;
    struct Sil_Slot_Rec tmp;
    tmp.key = key;
    tmp.val = val;
    if (me == OBJ_NULL_SIL) {
	me              = obj_Alloc_In_Dbfile( OBJ_CLASS_A_SIL, 0, dbfile );
	SIL_P(me)->slots_used  = OBJ_FROM_UNT( (Vm_Unt)1 );
	SIL_P(me)->slot[0]     = tmp;				vm_Dirty(me);
	return me;
    }
    if ((nu = splitWhileInsertingSlot( me, &tmp )) != OBJ_FROM_INT(0)) {
        Vm_Obj r       = obj_Alloc_In_Dbfile(OBJ_CLASS_A_SIN,0,VM_DBFILE(me));
	Vm_Obj h;
	if (OBJ_IS_CLASS_SIL(nu))   h = SIL_P(nu)->slot[0].key;
	else                        h = SIN_P(nu)->slot[0].key;
	{   Sin_P s = SIN_P(r);
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
    Vm_Int  slots_used = OBJ_TO_INT( SIL_P(me)->slots_used );
    Vm_Int  i;
    for    (i = slot;   i < slots_used-1;   ++i) {
	SIL_P(me)->slot[i] = SIL_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    SIL_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    SIL_P(me)->slot[ slots_used ] = sil_nil;			vm_Dirty(me);
   return  slots_used <= SIL_SLOTS/2;
}

/************************************************************************/
/*-    dropNodeSlot							*/
/************************************************************************/

static Vm_Int
dropNodeSlot(
    Vm_Obj me,
    Vm_Int slot
) {
    Vm_Int slots_used = OBJ_TO_INT( SIN_P(me)->slots_used );
    Vm_Int i;
    for   (i = slot;   i < slots_used-1;   ++i) {
	SIN_P(me)->slot[i] = SIN_P(me)->slot[i+1];		vm_Dirty(me);
    }
    --slots_used;
    SIN_P(me)->slots_used = OBJ_FROM_INT( slots_used );
    SIN_P(me)->slot[ slots_used ]= sin_nil;			vm_Dirty(me);
   return  slots_used <= SIN_SLOTS/2;
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

    Vm_Int slots_used = OBJ_TO_INT( SIN_P(me)->slots_used );

    struct Sil_Slot_Rec nul;
    nul.key  = OBJ_FROM_INT( 0 );
    nul.val  = OBJ_FROM_INT( 0 );

    if (slotA < 0 || slotB >= slots_used) {
	return FALSE;
    }

    {	Vm_Obj a  = SIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = SIN_P(me)->slot[ slotB ].leaf;
	
	/* mustBeLeaf(a); */
	/* mustBeLeaf(b); */

	{   Vm_Int aSlots = OBJ_TO_INT( SIL_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( SIL_P(b)->slots_used );
	    if (aSlots + bSlots > SIL_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int  i;
		for (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    SIL_P(a)->slot[i] = SIL_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    SIL_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    SIL_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);	
	    SIL_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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

    Vm_Int slots_used = OBJ_TO_INT( SIN_P(me)->slots_used );

    struct Sin_Slot_Rec nul;
    nul.key  = OBJ_FIRST;
    nul.leaf = OBJ_FROM_INT( 0 );

    /*mustBeNode(me)*/;
    if (slotA < 0 || slotB >= slots_used) {
        return FALSE;
    }

    {	Vm_Obj a  = SIN_P(me)->slot[ slotA ].leaf;
        Vm_Obj b  = SIN_P(me)->slot[ slotB ].leaf;

	/*mustBeNode(a);*/
	/*mustBeNode(b);*/

	{   Vm_Int aSlots = OBJ_TO_INT( SIN_P(a)->slots_used );
	    Vm_Int bSlots = OBJ_TO_INT( SIN_P(b)->slots_used );
	    if (aSlots + bSlots > SIN_SLOTS) {
		return FALSE;
	    }
	    {   Vm_Int i;
		for   (i = aSlots;   i < aSlots + bSlots;   ++i) {
		    SIN_P(a)->slot[i] = SIN_P(b)->slot[i-aSlots]; vm_Dirty(a);
		    SIN_P(b)->slot[i-aSlots] = nul;               vm_Dirty(b);
	        }
	    }
	    SIN_P(a)->slots_used = OBJ_FROM_INT( aSlots+bSlots ); vm_Dirty(a);
	    SIN_P(b)->slots_used = OBJ_FROM_INT(             0 ); vm_Dirty(b);
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
    Sil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( SIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_Neql( s->key, SIL_P(me)->slot[i].key )) {
	    return dropLeafSlot( me, i );
	}
    }
    return OBJ_TO_INT( SIL_P(me)->slots_used ) <= (SIL_SLOTS/2);
}

/************************************************************************/
/*-    deleteInNode							*/
/************************************************************************/

static Vm_Int
deleteInNode(
    Vm_Obj me,
    Sil_Slot s
) {
    Vm_Int meSlot = findSlotFor(me,s);
    Vm_Obj kid    = SIN_P(me)->slot[ meSlot ].leaf;
    if (OBJ_IS_CLASS_SIL(kid)) {
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
    return OBJ_TO_INT( SIN_P(me)->slots_used ) <= (SIN_SLOTS/2);
}

/************************************************************************/
/*-    sil_Del								*/
/************************************************************************/

Vm_Obj
sil_Del(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Sil_Slot_Rec tmp;
    tmp.key = key;
    tmp.val = OBJ_FROM_INT( (Vm_Int)0 );
    if (me == OBJ_NULL_SIL) return OBJ_NULL_SIL;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SIL(me)
    &&	!OBJ_IS_CLASS_SIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in sil_Del");
    }
    if (OBJ_IS_CLASS_SIL(me)) {
        deleteInLeaf( me, &tmp );
	/* An empty leaf node can be discarded: */
	if (OBJ_TO_UNT( SIL_P(me)->slots_used ) == (Vm_Unt)0) {
	    return OBJ_NULL_SIL;
	}
    } else {
        deleteInNode( me, &tmp );
	/* An internal node with just one child can be discarded: */
	if (OBJ_TO_UNT( SIN_P(me)->slots_used ) == (Vm_Unt)1) {
	    return SIN_P(me)->slot[0].leaf;
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
    Sil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( SIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_Neql( s->key, SIL_P(me)->slot[i].key )) {
	    return SIL_P(me)->slot[i].val;
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
    Sil_Slot s,
    Vm_Uch* key
) {
    Vm_Int slots_used = OBJ_TO_INT( SIL_P(me)->slots_used );
    Vm_Int i;
    for   (i = 0;   i < slots_used;   ++i) {
        if (!obj_StrNeql( key, SIL_P(me)->slot[i].key )) {
	    return SIL_P(me)->slot[i].val;
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
    Sil_Slot s
) {
    if (OBJ_IS_CLASS_SIL(me)) {
        return findInLeaf( me, s );
    } else {
        Vm_Int meSlot = findSlotFor( me, s );
	Vm_Obj oe     = SIN_P(me)->slot[ meSlot ].leaf;
	return         valb( oe, s );
    }
}

/************************************************************************/
/*-    valb_asciz							*/
/************************************************************************/

static Vm_Obj
valb_asciz(
    Vm_Obj me,
    Sil_Slot s,
    Vm_Uch* key
) {
    if (OBJ_IS_CLASS_SIL(me)) {
        return findInLeaf_Asciz( me, s, key );
    } else {
        Vm_Int meSlot = findSlotFor_Asciz( me, key );
	Vm_Obj oe     = SIN_P(me)->slot[ meSlot ].leaf;
	return         valb_asciz( oe, s, key );
    }
}

/************************************************************************/
/*-    sil_Alloc							*/
/************************************************************************/

Vm_Obj
sil_Alloc(
    void
) {
    return OBJ_NULL_SIL;
}

/************************************************************************/
/*-    sil_Get								*/
/************************************************************************/

Vm_Obj
sil_Get(
    Vm_Obj me,
    Vm_Obj key
) {
    struct Sil_Slot_Rec tmp;
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me == OBJ_NULL_SIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SIL(me)
    &&	!OBJ_IS_CLASS_SIN(me))
    ){
        Vm_Uch buf[ 32 ];
        job_Sprint_Vm_Obj( buf, buf+32, me, /*quotestrings:*/TRUE );
	MUQ_FATAL("Bad 'me' value in sil_Get %s",buf);
    }
    return valb( me, &tmp );
}

/************************************************************************/
/*-    sil_Get_Asciz							*/
/************************************************************************/

Vm_Obj
sil_Get_Asciz(
    Vm_Obj me,
    Vm_Uch* key
) {

    struct Sil_Slot_Rec tmp;

    if (strlen(key) < VM_INTBYTES) {	
        /* Encode string as an immediate value */
        /* and then use the vanilla sil_Get(): */
	return sil_Get( me, stg_From_Asciz(key) );
    }
    tmp.key = OBJ_FROM_INT(0);
    tmp.val = OBJ_FROM_INT(0);
    if (me == OBJ_NULL_SIL)   return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SIL(me)
    &&	!OBJ_IS_CLASS_SIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in sil_Get_Asciz");
    }
    return valb_asciz( me, &tmp, key );
}

/************************************************************************/
/*-    sil_FirstInSubtree						*/
/************************************************************************/

Vm_Int
sil_FirstInSubtree(
    Vm_Obj* result,
    Vm_Obj me
) {
    if (OBJ_IS_CLASS_SIL(me)) {
	if (OBJ_TO_INT(SIL_P(me)->slots_used)==(Vm_Int)0)   return FALSE;
	*result = SIL_P(me)->slot[0].key;
	return TRUE;
    }
    return sil_FirstInSubtree( result, SIN_P(me)->slot[0].leaf );
}

/************************************************************************/
/*-    sil_First							*/
/************************************************************************/

Vm_Obj
sil_First(
    Vm_Obj me
) {
    Vm_Obj result;
    if (me==OBJ_NULL_SIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SIL(me)
    &&	!OBJ_IS_CLASS_SIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in sil_First");
    }
    if (sil_FirstInSubtree( &result, me )) {
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
    Sil_Slot s
) {
    /*mustBeLeaf(me);*/
    {   Vm_Int slots_used = OBJ_TO_INT( SIL_P(me)->slots_used );
	Vm_Int d;
	Vm_Int i;
	for   (i = 0;   i < slots_used;   ++i) {
	    d = obj_Neql( s->key, SIL_P(me)->slot[i].key );
	    if (d < 0) {
	        *result = SIL_P(me)->slot[i].key;
		return TRUE;
	    }
	    if (!d) {
	        if (i+1 == slots_used)  return FALSE;
	        *result = SIL_P(me)->slot[i+1].key;
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
    Sil_Slot s
) {
    Vm_Int slots_used = OBJ_TO_INT( SIN_P(me)->slots_used );
    Vm_Int meSlot     = findSlotFor(me,s);
    Vm_Obj oe         = SIN_P(me)->slot[ meSlot ].leaf;
    /*mustBeNode(me);*/
    if (OBJ_IS_CLASS_SIL(oe)) {
	if (nextInLeaf( result, oe, s ))   return TRUE;
	if (meSlot+1 < slots_used) {
	    return sil_FirstInSubtree( result, SIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    } else {
	if (nextInNode( result, oe, s ))          return TRUE;
	if (meSlot+1 < slots_used) {
	    return sil_FirstInSubtree( result, SIN_P(me)->slot[ meSlot+1 ].leaf );
	}
	return FALSE;
    }
}

/************************************************************************/
/*-    sil_Next								*/
/************************************************************************/

Vm_Obj
sil_Next(
    Vm_Obj me,
    Vm_Obj key
) {
    Vm_Obj  result;
    struct Sil_Slot_Rec tmp;
    if (key==OBJ_FIRST)   return sil_First( me );
    tmp.key = key;
    tmp.val = OBJ_FROM_INT(0);
    if (me==OBJ_NULL_SIL) return OBJ_NOT_FOUND;
    if (!OBJ_IS_OBJ(me)
    || (!OBJ_IS_CLASS_SIL(me)
    &&	!OBJ_IS_CLASS_SIN(me))
    ){
	MUQ_FATAL("Bad 'me' value in sil_Del");
    }
    if (OBJ_IS_CLASS_SIL(me)) {
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
/*-    sil_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
sil_Startup (
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    if (sizeof(Sil_A_Header) > 512
    || sizeof(Sil_A_Header)+2*sizeof(struct Sil_Slot_Rec) < 512
    ){
        printf("*****  sizeof Sil_A_Header d=%d\n",sizeof(Sil_A_Header));
    }


    if (sizeof(Sin_A_Header) > 512
    || sizeof(Sin_A_Header)+2*sizeof(struct Sin_Slot_Rec) < 512
    ){
        printf("*****  sizeof Sin_A_Header d=%d\n",sizeof(Sin_A_Header));
    }

    obj_Sil_Test_Slot = OBJ_NULL_SIL;
}



/************************************************************************/
/*-    sil_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
sil_Linkup (
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    sil_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
sil_Shutdown(
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
/*-    for_new_sil -- Initialize new sil object.			*/
/************************************************************************/

static void
for_new_sil(
    Vm_Obj o,
    Vm_Unt size
) {
    /* Initialize ourself: */
    int   i;
    Sil_P s 	= SIL_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = SIL_SLOTS;   i --> 0;   )   s->slot[i] = sil_nil;
    vm_Dirty(o);
}

static void
for_new_sin(
    Vm_Obj o,
    Vm_Unt size
) {
    int   i;
    Sin_P s 	= SIN_P(o);
    s->slots_used	= OBJ_FROM_UNT( (Vm_Unt)0 );
    for (i = SIN_SLOTS;   i --> 0;   )   s->slot[i] = sin_nil;
    vm_Dirty(o);
}



/************************************************************************/
/*-    sizeof_sil -- Return size of sorted-dir-leaf.			*/
/************************************************************************/

static Vm_Unt
sizeof_sil(
    Vm_Unt size
) {
    return sizeof( Sil_A_Header );
}

/************************************************************************/
/*-    sizeof_sin -- Return size of sin-node.				*/
/************************************************************************/

static Vm_Unt
sizeof_sin(
    Vm_Unt size
) {
    return sizeof( Sin_A_Header );
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
